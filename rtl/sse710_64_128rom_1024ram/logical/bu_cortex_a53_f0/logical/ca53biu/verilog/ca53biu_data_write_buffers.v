//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : BIU data write buffers and write response interfaces
//-----------------------------------------------------------------------------
//
// Overview
// -------
// DCU/STB write data is buffered in this module before it is forwarded to the SCU.
// Other features:
//  o BIU write response
//  o DCU ECC data correction
//  o DCU data re-ordering due to the corkscrew memory arrangement

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_data_write_buffers #(parameter CPU_CACHE_PROTECTION = 1'b0)
  (
   //----------------------------------------------------------------------------
   // Clock and Reset
   //----------------------------------------------------------------------------

   input  wire                          clk,
   input  wire                          reset_n,
   input  wire                          DFTSE,

   //----------------------------------------------------------------------------
   // MBIST
   //----------------------------------------------------------------------------

   input  wire                          biu_mbist_req_i,
   input  wire [`DCU_MBIST_ARRAY_W-1:0] biu_mbist_array_i,
   input  wire [63:0]                   dcu_mbist_out_data_mb6_i,
   input  wire [6:0]                    dcu_mbist_data_checkbits_mb6_i,
   input  wire [116:0]                  tlb_mbist_out_data_mb6_i,
   input  wire [`CA53_IDATA_RAM_W-1:0]  ifu_mbist_out_data_mb6_i,

   //------------------------------------------------------------------------------
   // DCU Interface
   //------------------------------------------------------------------------------

   input  wire [55:0]                   dcu_ecc_syndrome_m3_i,
   input  wire                          dcu_ecc_fatal_m3_i,
   input  wire                          dcu_snoop_dw_active_i,
   input  wire                          dcu_snoop_valid_m2_i,
   input  wire [255:0]                  dcu_snoop_data_m2_i,
   input  wire [1:0]                    dcu_snoop_chunk_m2_i,
   input  wire [1:0]                    dcu_snoop_rotate_m2_i,
   input  wire [3:0]                    dcu_snoop_l2db_id_m2_i,
   input  wire                          dcu_snoop_last_m2_i,
   output wire                          biu_strex_bresp_valid_o,
   output wire [1:0]                    biu_strex_bresp_o,

   //-----------------------------------------------------------------------------
   // STB Interface
   //-----------------------------------------------------------------------------

   input  wire                          stb_biu_write_req_i,
   input  wire [3:0]                    stb_biu_write_l2dbid_i,
   input  wire [1:0]                    stb_biu_write_chunk_i,
   input  wire [127:0]                  stb_biu_write_data_i,
   input  wire [15:0]                   stb_biu_write_bls_i,
   input  wire                          stb_biu_write_last_i,
   output wire                          biu_stb_write_accept_o,
   input  wire                          stb_biu_write_req_active_i,

   //------------------------------------------------------------------------------
   // SCU Interface
   //------------------------------------------------------------------------------

   output wire                          biu_dw_valid_o,
   output wire [3:0]                    biu_dw_l2db_id_o,
   output wire [3:0]                    biu_dw_chunks_valid_o,
   output wire                          biu_dw_last_o,
   output wire [255:0]                  biu_dw_data_o,
   output wire [31:0]                   biu_dw_strb_o,
   output wire                          biu_dw_err_o,
   output wire                          biu_dw_fatal_o,
   input  wire                          scu_db_excl_valid_i,
   input  wire [1:0]                    scu_db_excl_resp_i,
   input  wire                          scu_db_decerr_i,
   input  wire                          scu_db_slverr_i,

   //------------------------------------------------------------------------------
   // BIU Write imprecise aborts
   //------------------------------------------------------------------------------

   output wire                          write_imp_abort_o,
   output wire                          write_imp_fault_o,

   //-----------------------------------------------------------------------------
   // Gov Management
   //-----------------------------------------------------------------------------

   output wire                          wbuf_valid_o
  );

  //-----------------------------------------------------------------------------
  // Registers
  //-----------------------------------------------------------------------------

  reg                              clk_enable;
  reg                              wbuf_valid;
  reg                              wbuf_last;
  reg  [15:0]                      wbuf_strb;
  reg  [3:0]                       wbuf_l2db_id;
  reg  [1:0]                       wbuf_chunk;
  reg  [1:0]                       wbuf_rotate;
  reg  [3:0]                       wbuf_ecc_repair_bit_rotate;
  reg                              wbuf_dcu_src;
  reg  [127:0]                     wbuf_data_0;
  reg  [127:0]                     wbuf_data_1;
  reg  [255:0]                     wbuf_data_rotate;
  reg                              biu_strex_bresp_valid;
  reg  [1:0]                       biu_strex_bresp;
  reg                              scu_db_decerr;
  reg                              scu_db_slverr;
  reg                              wbuf_mbist_odd_bank_sel_rst_0;
  reg                              wbuf_mbist_odd_bank_sel_rst_1;
  reg                              wbuf_mbist_even_bank_sel_rst_0;
  reg                              wbuf_mbist_even_bank_sel_rst_1;
  reg                              wbuf_func_or_dcu_mbist_sel;
  reg                              biu_dw_fatal;

  //-----------------------------------------------------------------------------
  // Wires
  //-----------------------------------------------------------------------------

  wire                             clk_dw;
  wire                             next_clk_enable;
  wire                             wbuf_data_0_en;
  wire                             wbuf_data_1_en;
  wire                             next_wbuf_valid;
  wire [127:0]                     next_wbuf_data_0;
  wire [127:0]                     next_wbuf_data_1;
  wire                             next_wbuf_last;
  wire [15:0]                      next_wbuf_strb;
  wire [3:0]                       next_wbuf_l2db_id;
  wire [1:0]                       next_wbuf_chunk;
  wire [1:0]                       next_wbuf_rotate;
  wire [3:0]                       next_wbuf_ecc_repair_bit_rotate;
  wire                             next_wbuf_dcu_src;
  wire [255:0]                     wbuf_repair_bit_ecc;
  wire [255:0]                     wbuf_data;
  wire [255:0]                     wbuf_data_ecc_rotate;
  wire [255:0]                     wbuf_data_dcu_mbist;
  wire [255:0]                     wbuf_data_or_dcu_data_mbist;
  wire [255:0]                     wbuf_repair_ecc_rotate;
  wire [1:0]                       dcu_mbist_rotate;
  wire [127:0]                     stb_biu_write_data_or_dcu_ifu_tlb_mbist;
  wire                             next_wbuf_mbist_odd_bank_sel;
  wire                             next_wbuf_mbist_even_bank_sel;
  wire                             next_wbuf_func_or_dcu_mbist_sel;
  wire                             next_biu_dw_fatal;

  //-----------------------------------------------------------------------------
  // Intermediate clock gate
  //-----------------------------------------------------------------------------

  // Avoid clocking data write registers when there is no possibility of data
  // being written either by STB or DCU snoop.
  // The clock must be active also the cycle after the write occurs to the SCU
  // in order to clear the corresponding transaction flags, if needed.
  // The clock is enabled during the MBIST mode, too.

  assign next_clk_enable = stb_biu_write_req_active_i |
                           dcu_snoop_dw_active_i      |
                           wbuf_valid                 |
                           biu_mbist_req_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      clk_enable <= 1'b0;
    end else begin
      clk_enable <= next_clk_enable;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_dw (.clk_i         (clk),
                                              .clk_enable_i  (clk_enable),
                                              .clk_senable_i (DFTSE),
                                              .clk_gated_o   (clk_dw));

  //-----------------------------------------------------------------------------
  // biu_stb_write_accept_o computation
  //-----------------------------------------------------------------------------

  // The DCU data path has priority over STB data write
  // o the DCU write data channel cannot be back-pressured as data could be lost in that case
  // o the dcu_snoop_valid_m2_i is required early in the clock cycle as it is factorized into
  //   the biu_stb_write_accept_o equation

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_stb_write_accept_o = ~dcu_snoop_valid_m2_i;

  //-----------------------------------------------------------------------------
  // Write buffers computation
  //-----------------------------------------------------------------------------

  assign next_wbuf_valid = biu_mbist_req_i | dcu_snoop_valid_m2_i | stb_biu_write_req_i;

  // next wbuf_data[127:0]:
  //  o DCU data[127:0]   when dcu_snoop_valid_m2_i or biu_mbist_req_i when MBIST for DCU data path enabled
  //  o STB data transfer when stb_biu_write_req_i & ~stb_biu_write_chunk_i[0] or IFU/TLB MIST MB6 data out

  assign wbuf_data_0_en = biu_mbist_req_i | dcu_snoop_valid_m2_i | (stb_biu_write_req_i & ~stb_biu_write_chunk_i[0]);

  // MUX the STB data write w/ DCU_TAG_MBIST/DCU_DIRTY_MBIST/IFU_MBIST/TLB_MIST data out

  assign stb_biu_write_data_or_dcu_ifu_tlb_mbist = ~biu_mbist_req_i                                     ? stb_biu_write_data_i                                        :
                                                   `CA53_BIU_MBIST_ARRAY_FOR_IFU(biu_mbist_array_i)     ? {{(128-`CA53_IDATA_RAM_W){1'b0}}, ifu_mbist_out_data_mb6_i} :
                                                   `CA53_BIU_MBIST_ARRAY_FOR_TLB(biu_mbist_array_i)     ? {{11{1'b0}}, tlb_mbist_out_data_mb6_i}                      :
                                                   `CA53_BIU_MBIST_ARRAY_FOR_DCU_TAG(biu_mbist_array_i) ? {{95{1'b0}}, dcu_mbist_out_data_mb6_i[63:31]}               :
                                                                                                          {{64{1'b0}}, dcu_mbist_out_data_mb6_i};

  // MUX the DCU with STB/DCU_MBIST/IFU_MBIST/TLB_MBIST data out

  assign next_wbuf_data_0 = ((~biu_mbist_req_i & dcu_snoop_valid_m2_i)                                |
                             ( biu_mbist_req_i & `CA53_BIU_MBIST_ARRAY_FOR_DCU_DATA(biu_mbist_array_i))) ? dcu_snoop_data_m2_i[127:0] :
                                                                                                           stb_biu_write_data_or_dcu_ifu_tlb_mbist;

  // next wbuf_data[255:128]:
  //  o DCU data[255:128]  when dcu_snoop_valid_m2_i or biu_mbist_req_i when MBIST for DCU data path enabled
  //  o STB data transfer  when stb_biu_write_req_i & stb_biu_write_chunk_i[0]

  assign wbuf_data_1_en    = biu_mbist_req_i | dcu_snoop_valid_m2_i | (stb_biu_write_req_i & stb_biu_write_chunk_i[0]);

  assign next_wbuf_data_1  = (biu_mbist_req_i | dcu_snoop_valid_m2_i) ? dcu_snoop_data_m2_i[255:128] :
                                                                        stb_biu_write_data_i;

  assign next_wbuf_l2db_id = dcu_snoop_valid_m2_i ? dcu_snoop_l2db_id_m2_i :
                                                    stb_biu_write_l2dbid_i;

  // next_wbuf_strb:
  // o dcu_mbist_data_checkbits_mb6_i when biu_mbist_req_i
  // o STB strobes in functional mode
  // o DCU's strobes are always 32'hFFFFFFFF

  assign next_wbuf_strb = biu_mbist_req_i ? {{9{1'b0}}, dcu_mbist_data_checkbits_mb6_i} :
                                            stb_biu_write_bls_i;

  // next_wbuf_dcu_src:
  // o select if DCU data path is being used

  assign next_wbuf_dcu_src = ~biu_mbist_req_i & dcu_snoop_valid_m2_i;

  // next_wbuf_chunk:
  //  o chunk ID of the lower quadword when DCU data transfer
  //  o chunk ID when STB data transfer

  assign next_wbuf_chunk = dcu_snoop_valid_m2_i ? dcu_snoop_chunk_m2_i :
                                                  stb_biu_write_chunk_i;

  // next_wbuf_rotate:
  //  o number of dwords to rotate right when DCU data transfer
  //  o 2'b00 when STB data transfer or MBIST enabled

  assign dcu_mbist_rotate = (`CA53_BIU_MBIST_ARRAY_FOR_BANK0(biu_mbist_array_i) | `CA53_BIU_MBIST_ARRAY_FOR_BANK1(biu_mbist_array_i)) ? 2'b00 :
                            (`CA53_BIU_MBIST_ARRAY_FOR_BANK2(biu_mbist_array_i) | `CA53_BIU_MBIST_ARRAY_FOR_BANK3(biu_mbist_array_i)) ? 2'b01 :
                            (`CA53_BIU_MBIST_ARRAY_FOR_BANK4(biu_mbist_array_i) | `CA53_BIU_MBIST_ARRAY_FOR_BANK5(biu_mbist_array_i)) ? 2'b10 :
                                                                                                                                        2'b11;

  assign next_wbuf_rotate = (~biu_mbist_req_i & dcu_snoop_valid_m2_i)                                 ? dcu_snoop_rotate_m2_i :
                            (biu_mbist_req_i & `CA53_BIU_MBIST_ARRAY_FOR_DCU_DATA(biu_mbist_array_i)) ? dcu_mbist_rotate      :
                                                                                                        2'b00;

  // next_wbuf_last:
  //  o last beat(s) transferred by STB or DCU

  assign next_wbuf_last = dcu_snoop_valid_m2_i ? dcu_snoop_last_m2_i :
                                                 stb_biu_write_last_i;


  // MBIST wbuf selection computation

  assign next_wbuf_mbist_odd_bank_sel    = `CA53_BIU_MBIST_ARRAY_FOR_BANK1(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK3(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK5(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK7(biu_mbist_array_i  );

  assign next_wbuf_mbist_even_bank_sel   = `CA53_BIU_MBIST_ARRAY_FOR_BANK0(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK2(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK4(biu_mbist_array_i) |
                                           `CA53_BIU_MBIST_ARRAY_FOR_BANK6(biu_mbist_array_i  );

  assign next_wbuf_func_or_dcu_mbist_sel = ~biu_mbist_req_i                                     |
                                           ~`CA53_BIU_MBIST_ARRAY_FOR_DCU_DATA(biu_mbist_array_i);

  // BIU write buffers valid qualifier

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_valid <= 1'b0;
    end else begin
      wbuf_valid <= next_wbuf_valid;
    end

  // BIU write buffers storage

  always @(posedge clk_dw)
    begin
      if (next_wbuf_valid) begin
        wbuf_last                  <= next_wbuf_last;
        wbuf_strb                  <= next_wbuf_strb;
        wbuf_l2db_id               <= next_wbuf_l2db_id;
        wbuf_chunk                 <= next_wbuf_chunk;
        wbuf_rotate                <= next_wbuf_rotate;
        wbuf_dcu_src               <= next_wbuf_dcu_src;
      end
    end

  always @(posedge clk_dw)
    begin
      if (wbuf_data_0_en) begin
        wbuf_data_0 <= next_wbuf_data_0;
      end
    end

  always @(posedge clk_dw)
    begin
      if (wbuf_data_1_en) begin
        wbuf_data_1 <= next_wbuf_data_1;
      end
    end

  // BIU write buffers MBIST selection registers.
  // Duplicated the MBIST selection DFFs in order to minimize the DRC impact caused
  // by the big fanout and thus ease the timing closure.
  // In order to avoid the duplicated DFFs removal during the synthesis,
  // either DFFs with different reset values are used or the DFFs data-in/out are inverted.

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_mbist_odd_bank_sel_rst_0 <= 1'b0;
    end else begin
      wbuf_mbist_odd_bank_sel_rst_0 <= next_wbuf_mbist_odd_bank_sel;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_mbist_odd_bank_sel_rst_1 <= 1'b1;
    end else begin
      wbuf_mbist_odd_bank_sel_rst_1 <= next_wbuf_mbist_odd_bank_sel;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_mbist_even_bank_sel_rst_0 <= 1'b0;
    end else begin
      wbuf_mbist_even_bank_sel_rst_0 <= next_wbuf_mbist_even_bank_sel;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_mbist_even_bank_sel_rst_1 <= 1'b1;
    end else begin
      wbuf_mbist_even_bank_sel_rst_1 <= next_wbuf_mbist_even_bank_sel;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      wbuf_func_or_dcu_mbist_sel <= 1'b0;
    end else begin
      wbuf_func_or_dcu_mbist_sel <= next_wbuf_func_or_dcu_mbist_sel;
    end

  //-----------------------------------------------------------------------------
  // Write buffers data output assembly
  //-----------------------------------------------------------------------------

  assign wbuf_data = {wbuf_data_1, wbuf_data_0};

  // ECC data correction section

generate if (CPU_CACHE_PROTECTION) begin : gen_biu_ecc_repair_bit_01
  // next_wbuf_ecc_repair_bit_rotate:
  //  o number of dwords to rotate right when DCU data transfer (one-hot encoding)
  //  o 4'b0000 when STB data transfer or MBIST enabled

  assign next_wbuf_ecc_repair_bit_rotate = (~biu_mbist_req_i & dcu_snoop_valid_m2_i)  ? (4'h1 << dcu_snoop_rotate_m2_i) :
                                                                                        4'b0000;

  always @(posedge clk_dw)
    begin
      if (next_wbuf_valid) begin
        wbuf_ecc_repair_bit_rotate <= next_wbuf_ecc_repair_bit_rotate;
      end
    end

  // Perform ECC repair bit computation, if ECC enabled
  // Note: STB/MBIST data passes XOR-ed w/ zero

  genvar  index_i;
  for (index_i = 0; index_i < 8; index_i = index_i + 1) begin : gen_biu_ecc_correct_02
    ca53_ecc_repair32 u_biu_ca53_ecc_repair32 (
      .syndrome_i   (dcu_ecc_syndrome_m3_i[index_i*7 +: 7]),
      .repair_bit_o (wbuf_repair_bit_ecc[index_i*32 +: 32])
    );
  end
end endgenerate

  // The DCU MBIST data/ECC checkbits are assembled on the output of the write buffers.
  // For the bank selection of the DCU MBIST data, the functional DCU corkscrew re-order
  // is shared for the double words, while the word re-ordering uses a dedicated level
  // done in parallel with the ECC logic.

  assign wbuf_data_dcu_mbist[255:192] = wbuf_mbist_odd_bank_sel_rst_0 ? {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[255:224]} :
                                                                        {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[223:192]};

  assign wbuf_data_dcu_mbist[191:128] = wbuf_mbist_odd_bank_sel_rst_1 ? {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[191:160]} :
                                                                        {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[159:128]};

  assign wbuf_data_dcu_mbist[127:64]  = ~wbuf_mbist_even_bank_sel_rst_0 ? {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[127:96]} :
                                                                          {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[95:64]};

  assign wbuf_data_dcu_mbist[63:0]    = ~wbuf_mbist_even_bank_sel_rst_1 ? {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[63:32]} :
                                                                          {{25{1'b0}}, wbuf_strb[6:0], wbuf_data[31:0]};

  // Mux the WBUF data w/ DCU MBIST first stage rotation

  assign wbuf_data_or_dcu_data_mbist = wbuf_func_or_dcu_mbist_sel ? wbuf_data :
                                                                    wbuf_data_dcu_mbist;

  // DCU corkscrew memory data re-ordering

  always @*
    case (wbuf_rotate)
      2'b00   : wbuf_data_rotate =  wbuf_data_or_dcu_data_mbist;
      2'b01   : wbuf_data_rotate = {wbuf_data_or_dcu_data_mbist[63:0],  wbuf_data_or_dcu_data_mbist[255:64]};
      2'b10   : wbuf_data_rotate = {wbuf_data_or_dcu_data_mbist[127:0], wbuf_data_or_dcu_data_mbist[255:128]};
      2'b11   : wbuf_data_rotate = {wbuf_data_or_dcu_data_mbist[191:0], wbuf_data_or_dcu_data_mbist[255:192]};
      default : wbuf_data_rotate = {256{1'bx}};
    endcase

generate if (CPU_CACHE_PROTECTION) begin : gen_biu_ecc_repair_bit_rotate_01
  // Perform rotation for the ECC correction bits

  assign wbuf_repair_ecc_rotate = (wbuf_repair_bit_ecc                                        & {256{wbuf_ecc_repair_bit_rotate[0]}}) |
                                  ({wbuf_repair_bit_ecc[63:0],  wbuf_repair_bit_ecc[255:64]}  & {256{wbuf_ecc_repair_bit_rotate[1]}}) |
                                  ({wbuf_repair_bit_ecc[127:0], wbuf_repair_bit_ecc[255:128]} & {256{wbuf_ecc_repair_bit_rotate[2]}}) |
                                  ({wbuf_repair_bit_ecc[191:0], wbuf_repair_bit_ecc[255:192]} & {256{wbuf_ecc_repair_bit_rotate[3]}}  );

  // Apply the ECC correction bits on the data (STB/MBIST data path are XOR-ed w/ zero)

  assign wbuf_data_ecc_rotate = wbuf_repair_ecc_rotate ^ wbuf_data_rotate;

end else begin : gen_biu_ecc_repair_bit_rotate_01_else
  // ECC disabled

  assign wbuf_data_ecc_rotate = wbuf_data_rotate;
end endgenerate

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_dw_valid_o        = wbuf_valid;
  assign biu_dw_l2db_id_o      = wbuf_l2db_id;
  assign biu_dw_chunks_valid_o = wbuf_dcu_src ? {{2{wbuf_chunk[1]}}, {2{~wbuf_chunk[1]}}} :
                                                (4'h1 << wbuf_chunk[1:0]);
  assign biu_dw_last_o         = wbuf_last;
  assign biu_dw_data_o         = wbuf_data_ecc_rotate;
  assign biu_dw_strb_o         = {32{wbuf_dcu_src}} | {{16{wbuf_chunk[0]}} & wbuf_strb, {16{~wbuf_chunk[0]}} & wbuf_strb};

generate if (CPU_CACHE_PROTECTION) begin : gen_biu_ecc_output_01
  // ECC correction enabled
  // In order to ease the timing closure on the ECC fatal path, the following approach is used:
  // o speculative data error sent to the the SCU, if the ECC syndrome is different than zero;
  // o registered version of the ECC fatal error sent to the SCU next clock cycle.

  assign next_biu_dw_fatal = wbuf_valid & wbuf_dcu_src & dcu_ecc_fatal_m3_i;

  always @(posedge clk)
    begin
      biu_dw_fatal <= next_biu_dw_fatal;
    end

  assign biu_dw_err_o   = wbuf_dcu_src & (|dcu_ecc_syndrome_m3_i);
  assign biu_dw_fatal_o = biu_dw_fatal;
end else begin : gen_biu_ecc_output_01_else
  // ECC disabled

  assign biu_dw_err_o   = 1'b0;
  assign biu_dw_fatal_o = 1'b0;
end endgenerate

  //-----------------------------------------------------------------------------
  // BIU write response interface
  //-----------------------------------------------------------------------------

  // Write exclusive resp

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      biu_strex_bresp_valid <= 1'b0;
    end else begin
      biu_strex_bresp_valid <= scu_db_excl_valid_i;
    end

  always @(posedge clk)
    begin
      biu_strex_bresp <= scu_db_excl_resp_i;
    end

  // Write imprecise aborts

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      scu_db_decerr <= 1'b0;
      scu_db_slverr <= 1'b0;
    end else begin
      scu_db_decerr <= scu_db_decerr_i;
      scu_db_slverr <= scu_db_slverr_i;
    end

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign biu_strex_bresp_valid_o = biu_strex_bresp_valid;
  assign biu_strex_bresp_o       = biu_strex_bresp;
  assign write_imp_abort_o       = scu_db_decerr | scu_db_slverr;
  assign write_imp_fault_o       = scu_db_decerr;

  //-----------------------------------------------------------------------------
  // Gov Management
  //-----------------------------------------------------------------------------

  //-----------------------------------------------------------------------------
  // Output Assignments
  //-----------------------------------------------------------------------------

  assign wbuf_valid_o = wbuf_valid;

`ifdef ARM_ASSERT_ON
  // ----------------------------------------------------------------------------
  // ARMAUTO assertions
  // ----------------------------------------------------------------------------

  /* ARMAUTO_X */
  assert_never_unknown   #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: next_wbuf_valid")
  u_ovl_x_next_wbuf_valid (.clk       (clk_dw),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (next_wbuf_valid));

  assert_never_unknown  #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wbuf_data_0_en")
  u_ovl_x_wbuf_data_0_en (.clk       (clk_dw),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (wbuf_data_0_en));

  assert_never_unknown  #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wbuf_data_1_en")
  u_ovl_x_wbuf_data_1_en (.clk       (clk_dw),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (wbuf_data_1_en));

  //-----------------------------------------------------------------------------
  // Other assertions
  //-----------------------------------------------------------------------------

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_dw_valid must never be unknown")
  u_ovl_dw_buffers_01   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_dw_valid_o));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "biu_dw_strb_o are all asserted when DCU data is being transferred")
  u_ovl_dw_buffers_02   (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (biu_dw_valid_o & wbuf_dcu_src & ~biu_mbist_req_i),
                         .consequent_expr (biu_dw_strb_o == {32{1'b1}}));

  assert_implication   #(`OVL_FATAL, `OVL_ASSERT, "biu_dw_data_o does not match wbuf_data for STB data path")
  u_ovl_dw_buffers_03   (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (biu_dw_valid_o & ~wbuf_dcu_src & ~biu_mbist_req_i),
                         .consequent_expr (({{8{biu_dw_strb_o[31]}},
                                             {8{biu_dw_strb_o[30]}},
                                             {8{biu_dw_strb_o[29]}},
                                             {8{biu_dw_strb_o[28]}},
                                             {8{biu_dw_strb_o[27]}},
                                             {8{biu_dw_strb_o[26]}},
                                             {8{biu_dw_strb_o[25]}},
                                             {8{biu_dw_strb_o[24]}},
                                             {8{biu_dw_strb_o[23]}},
                                             {8{biu_dw_strb_o[22]}},
                                             {8{biu_dw_strb_o[21]}},
                                             {8{biu_dw_strb_o[20]}},
                                             {8{biu_dw_strb_o[19]}},
                                             {8{biu_dw_strb_o[18]}},
                                             {8{biu_dw_strb_o[17]}},
                                             {8{biu_dw_strb_o[16]}},
                                             {8{biu_dw_strb_o[15]}},
                                             {8{biu_dw_strb_o[14]}},
                                             {8{biu_dw_strb_o[13]}},
                                             {8{biu_dw_strb_o[12]}},
                                             {8{biu_dw_strb_o[11]}},
                                             {8{biu_dw_strb_o[10]}},
                                             {8{biu_dw_strb_o[9]}},
                                             {8{biu_dw_strb_o[8]}},
                                             {8{biu_dw_strb_o[7]}},
                                             {8{biu_dw_strb_o[6]}},
                                             {8{biu_dw_strb_o[5]}},
                                             {8{biu_dw_strb_o[4]}},
                                             {8{biu_dw_strb_o[3]}},
                                             {8{biu_dw_strb_o[2]}},
                                             {8{biu_dw_strb_o[1]}},
                                             {8{biu_dw_strb_o[0]}} } &
                                            biu_dw_data_o) ==
                                           ({{8{wbuf_strb[15] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[14] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[13] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[12] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[11] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[10] &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[9]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[8]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[7]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[6]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[5]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[4]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[3]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[2]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[1]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[0]  &  wbuf_chunk[0]}},
                                             {8{wbuf_strb[15] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[14] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[13] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[12] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[11] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[10] & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[9]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[8]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[7]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[6]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[5]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[4]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[3]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[2]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[1]  & ~wbuf_chunk[0]}},
                                             {8{wbuf_strb[0]  & ~wbuf_chunk[0]}} } &
                                            wbuf_data)));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "biu_strex_bresp_valid should never be unknown")
  u_ovl_dw_buffers_04   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (biu_strex_bresp_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "scu_db_decerr should never be unknown")
  u_ovl_dw_buffers_05   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (scu_db_decerr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "scu_db_slverr should never be unknown")
  u_ovl_dw_buffers_06   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (scu_db_slverr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "The clock enable must never be unknown")
  u_ovl_dw_buffers_07   (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (clk_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The clock must be enabled when there is a potential access to the data write registers")
  u_ovl_dw_buffers_08 (.clk             (clk),
                       .reset_n         (reset_n),
                       .antecedent_expr ((stb_biu_write_req_i | dcu_snoop_valid_m2_i)),
                       .consequent_expr (clk_enable));

`endif

`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53biu_defs.v"
`undef CA53_UNDEFINE

endmodule // ca53biu_data_write_buffers
