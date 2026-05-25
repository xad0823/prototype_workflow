//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 17:05:58 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283841 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------
// Abstract : Instruction pre-decode
//-----------------------------------------------------------------------------

module ca53ifu_pd
  (
   // Clocks and resets
   input wire          clk,
   input wire          reset_n,
   input wire          DFTSE,
   input wire  [7:0]   lfb_pd_0_i,
   input wire  [7:0]   lfb_pd_1_i,
   input wire  [7:0]   lfb_pd_2_i,

   // BIU interface
   input wire          biu_i_rvalid_i,
   input wire [127:0]  biu_i_rdata_i,
   input wire [1:0]    biu_i_rchunk_i,
   input wire [1:0]    biu_i_rid_i,

   //IFU
   input wire          ifu_rready_i,
   input wire          pfb_in_debug_or_wfx_i,

   // DPU interface
   input wire [31:0]   dpu_dbg_ins_i,
   input wire          dpu_dbg_valid_i,
   input wire          ctl_pd_ack_i,
   input wire          a64_state_i,

   // Pre-decode - LFB interface
   output wire [159:0] pd_data_o,
   output wire         pd_data_req_o

);

  // -----------------------------
  // Local Param
  // -----------------------------
  localparam [1:0] A32_STATE = 2'b00;
  localparam [1:0] A64_STATE = 2'b10;
  localparam [1:0] T32_STATE = 2'b01;

  // -----------------------------
  // wire declarations
  // -----------------------------
  wire        clk_pd;
  wire        clk_dbg;

  wire        pd_a32_data_en;
  wire        pd_a64_data_en;
  wire        pd_t32_data_en;
  wire [1:0]  pd_pcoffset_sl;
  wire [1:0]  pd_pcoffset_sh;

  wire        pd_data_req_pd1;
  wire [79:0] pd_data_sl;
  wire [79:0] pd_data_sh;

  wire        nxt_clk_en_pd;
  wire        dbg_data_req;
  wire [39:0] dbg_data;

  // -----------------------------
  // Reg declarations
  // -----------------------------
  reg       clk_en_pd;

  reg       pd_a32_en;
  reg       pd_t32_en;
  reg       pd_a64_en;

  reg       chunk_match;
  reg [1:0] pd_pcoffset;
  reg       pc_offset_level;

  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------

  // Create an enable term for the architectural clock gating.
  // First of all there is nothing we can do for PDC since they are
  // combinatorially set in if3 and there are no registers available
  // hence we need to keep the thumb pre-decoder for slice low always on.
  // Anything else can be gated off using the lfb enable terms, we cannot
  // use the rvalid signal since they will not clear the signals at the end
  // hence we need to use lfb info which goes high during the address handshake
  // Because it goes high during the address handshake we can safely register that
  assign nxt_clk_en_pd = lfb_pd_0_i[0] | lfb_pd_1_i[0] | lfb_pd_2_i[0];

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      clk_en_pd <= 1'b0;
    else
      clk_en_pd <= nxt_clk_en_pd;

  ca53_cell_inter_clkgate u_inter_clkgate_pd (.clk_i         (clk),
                                              .clk_enable_i  (clk_en_pd),
                                              .clk_senable_i (DFTSE),
                                              .clk_gated_o   (clk_pd));

  ca53_cell_inter_clkgate u_inter_clkgate_dbg (.clk_i         (clk),
                                               .clk_enable_i  (pfb_in_debug_or_wfx_i),
                                               .clk_senable_i (DFTSE),
                                               .clk_gated_o   (clk_dbg));

  //This is how the lfb entry has been defined where 'i' is chosen based on the biu_i_rid.
  //--------------------------------------------------------------------------------------
  // lfb_pd[i][0]   = Enable. Set during the address handshake of the corresponding lfb_entry.
  //                          Clear one cycle after last data item has arrived for the corresponding lfb_entry, it is also cleared during abandon.
  // lfb_pd[i][2:1] = PC offset. represent PC location (pa_if2[2:1])
  // lfb_pd[i][5:3] = Fetch Line. Represent the fetch line requested by the lfb_entry   (pa_if2[5:3])
  // lfb_pd[i][7:6] = State. Represent architectural state of the lfb entry.
  always @(*)
    begin
      case (biu_i_rid_i)
        2'b00 : begin
          pd_a32_en = lfb_pd_0_i[0] & (lfb_pd_0_i[7:6] == A32_STATE);
          pd_t32_en = lfb_pd_0_i[0] & (lfb_pd_0_i[7:6] == T32_STATE);
          pd_a64_en = lfb_pd_0_i[0] & (lfb_pd_0_i[7:6] == A64_STATE);

          chunk_match     = lfb_pd_0_i[5:4] == biu_i_rchunk_i[1:0];
          pc_offset_level = lfb_pd_0_i[3];
          pd_pcoffset     = lfb_pd_0_i[2:1];
        end

        2'b01 : begin
          pd_a32_en = lfb_pd_1_i[0] & (lfb_pd_1_i[7:6] == A32_STATE);
          pd_t32_en = lfb_pd_1_i[0] & (lfb_pd_1_i[7:6] == T32_STATE);
          pd_a64_en = lfb_pd_1_i[0] & (lfb_pd_1_i[7:6] == A64_STATE);

          chunk_match     = lfb_pd_1_i[5:4] == biu_i_rchunk_i[1:0];
          pc_offset_level = lfb_pd_1_i[3];
          pd_pcoffset     = lfb_pd_1_i[2:1];
        end

        2'b10 : begin
          pd_a32_en = lfb_pd_2_i[0] & (lfb_pd_2_i[7:6] == A32_STATE);
          pd_t32_en = lfb_pd_2_i[0] & (lfb_pd_2_i[7:6] == T32_STATE);
          pd_a64_en = lfb_pd_2_i[0] & (lfb_pd_2_i[7:6] == A64_STATE);

          chunk_match     = lfb_pd_2_i[5:4] == biu_i_rchunk_i[1:0];
          pc_offset_level = lfb_pd_2_i[3];
          pd_pcoffset     = lfb_pd_2_i[2:1];
        end
        // 2'b11 illegal value cover by assertion

        default :begin
          pd_a32_en = 1'bx;
          pd_t32_en = 1'bx;
          pd_a64_en = 1'bx;

          chunk_match     = 1'bx;
          pc_offset_level = 1'bx;
          pd_pcoffset     = 2'bxx;
        end
      endcase
    end

  // Enable generation
  assign pd_a32_data_en = pd_a32_en & (biu_i_rvalid_i & ifu_rready_i);
  assign pd_t32_data_en = pd_t32_en & (biu_i_rvalid_i & ifu_rready_i);
  assign pd_a64_data_en = pd_a64_en & (biu_i_rvalid_i & ifu_rready_i);

  // Important point to note is that when pc_offset_level is high then
  // pd_pcoffset_sh_o should follow pd_pcoffset[1:0] otherwise
  // pd_pcoffset_sl_o should follow pd_pcoffset[1:0].
  assign pd_pcoffset_sl = pd_pcoffset[1:0] & {2{~pc_offset_level & chunk_match}};
  assign pd_pcoffset_sh = pd_pcoffset[1:0] & {2{ pc_offset_level & chunk_match}};

  // Functionality for debug
 ca53ifu_pd_debug_dec u_ca53ifu_pd_debug_dec(
  .clk             (clk_dbg),
  .reset_n         (reset_n),
  .a64_state_i     (a64_state_i),
  .dpu_dbg_ins_i   (dpu_dbg_ins_i[31:0]),
  .dpu_dbg_valid_i (dpu_dbg_valid_i),
  .dbg_data_o      (dbg_data[39:0]),
  .dbg_data_req_o  (dbg_data_req) );

  ca53ifu_pd_slice u_ca53ifu_pd_slice_low (
    // Inputs
    .clk                    (clk_pd),
    .reset_n                (reset_n),
    .pd_a32_data_en_i       (pd_a32_data_en),
    .pd_a64_data_en_i       (pd_a64_data_en),
    .pd_t32_data_en_0_i     (pd_t32_data_en),
    .pd_t32_data_en_1_i     (pd_t32_data_en),
    .pd_pcoffset_i          (pd_pcoffset_sl),
    .ifu_rready_i           (ifu_rready_i),
    .biu_i_rdata_i          (biu_i_rdata_i[63:0]),
    .ctl_pd_ack_i           (ctl_pd_ack_i),
    .dbg_data_i             (dbg_data[39:0]),
    .dbg_data_req_i         (dbg_data_req),
    // Outputs
    .pd_data_req_pd1_o      (pd_data_req_pd1),
    .pd_data_o              (pd_data_sl));

  ca53ifu_pd_slice u_ca53ifu_pd_slice_high (
    // Inputs
    .clk                    (clk_pd),
    .reset_n                (reset_n),
    .pd_a32_data_en_i       (pd_a32_data_en),
    .pd_a64_data_en_i       (pd_a64_data_en),
    .pd_t32_data_en_0_i     (pd_t32_data_en),
    .pd_t32_data_en_1_i     (pd_t32_data_en),
    .pd_pcoffset_i          (pd_pcoffset_sh),
    .ifu_rready_i           (ifu_rready_i),
    .biu_i_rdata_i          (biu_i_rdata_i[127:64]),
    .ctl_pd_ack_i           (ctl_pd_ack_i),
    .dbg_data_i             ({40{1'b0}}),
    .dbg_data_req_i         (1'b0),
    // Outputs
    .pd_data_req_pd1_o      (),  // Not connected because request is handled by the 'low' slice
    .pd_data_o              (pd_data_sh[79:0]));

  // Final output assignment
  assign pd_data_o     = {pd_data_sh,pd_data_sl};
  assign pd_data_req_o =  pd_data_req_pd1;

  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Illegal RID value in PD")
  ovl_pd_state             (.clk        (clk),
                            .reset_n    (reset_n),
                            .test_expr  (biu_i_rid_i == 2'b11 & biu_i_rvalid_i & ifu_rready_i));


`endif

endmodule

/*ARMAUTO_UNDEF*/
/*END*/

