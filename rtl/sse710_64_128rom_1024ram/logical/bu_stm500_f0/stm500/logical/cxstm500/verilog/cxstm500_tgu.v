//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Wrapper block for STM Trace Generation Unit and ATB Master,
//      instantiating trace generation, FIFOs, ATB Master and status sub-blocks
//-----------------------------------------------------------------------------

module cxstm500_tgu #(
  // Configuration Parameters
  parameter DATA_FIFO_DEPTH   = 4,         // Depth of data FIFO. Valid values are 4, 8, 16, 32
  parameter CHN_FIFO_DEPTH    = 4,         // Depth of channel FIFO. Valid Values are 4, 8, 16, 32
  parameter STM_DATA_WIDTH    = 64         // Width of STM data path

  )
  (
  // Clock and Reset
  input wire                          clk_gated,            // gated clock
  input wire                          STMRESETn,            // asynchronous reset

  // TGU data interface
  input wire                          tgu_valid_i,          // TGU data transaction valid
  input wire [7:0]                    tgu_master_i,         // TGU data transaction master number
  input wire [15:0]                   tgu_channel_i,        // TGU data transaction channel number
  input wire [2:0]                    tgu_packet_type_i,    // TGU data transaction type
  input wire [(STM_DATA_WIDTH/32):0]  tgu_size_i,           // TGU data transaction size
  input wire [STM_DATA_WIDTH-1:0]     tgu_payload_i,        // TGU data transaction payload
  input wire [1:0]                    tgu_ts_req_i,         // TGU data transaction timestamp request
  input wire                          tgu_fready_i,         // TGU data flush completed

  output wire                         tgu_ready_o,          // TGU data transaction ready
  output wire                         tgu_timestamped_o,    // TGU data transaction has been timestamped
  output wire                         tgu_fvalid_o,         // TGU data flush request

  // Timestamp
  input wire [63:0]                   tsvalue_i,            // Timestamp value

  // TGU configuration and status interface
  input wire                          tgu_cfg_enable_i,     // TGU enable
  input wire [6:0]                    tgu_cfg_traceid_i,    // ID for ATB
  input wire                          tgu_cfg_tsen_i,       // timestamp enable
  input wire [31:0]                   tgu_cfg_tsfreqr_i,    // timestamp frequency
  input wire                          tgu_cfg_spcompen_i,   // compresion enable for AXI stimulus
  input wire                          tgu_cfg_hwcompen_i,   // compresion enable for HW stimulus
  input wire                          tgu_cfg_asyncpe_i,    // priority escalation for sync request
  input wire                          tgu_cfg_fifoaf_i,     // enable fifo auto-flush
  input wire                          tgu_cfg_freadyhigh_i, // control for driving AFREADY high
  input wire                          tgu_flush_i,          // Local flush request

  output wire                         tgu_busy_o,           // TGU busy
  output wire [1:0]                   tgu_fifo_level_o,     // fifo level: 00 < 25%, 01 < 50%, 10 < 75%, 11 > 75%
  output wire                         tgu_fifo_full_o,      // TGU fifo full

  // Trace trigger interface
  input wire                          tgu_trace_trigger_i,  // Trace trigger input

  // ATB interface
  input  wire                         ATREADYM,             // ATB ready
  input  wire                         AFVALIDM,             // ATB flush valid
  input  wire                         syncreq_i,            // ATB synchronization request
  input  wire                         stm_enable_syncreq_i, // STM Enable synchronization request

  output wire                         atvalid_o,            // ATB valid
  output wire [(STM_DATA_WIDTH/32):0] ATBYTESM,             // ATB bytes
  output wire [STM_DATA_WIDTH-1:0]    ATDATAM,              // ATB data
  output wire [6:0]                   ATIDM,                // ATB ID
  output wire                         AFREADYM,             // ATB flush ready

  // Cross-trigger
  output wire                         asyncout_o,           // async sequence has been output

  // Integartion testing interface
  input wire                          itctl_i,              // integration mode
  input wire                          ittrigger_we_i,       // write to ITTRIGGER register
  input wire                          itatbdata0_we_i,      // write to ITATBDATA0 register
  input wire                          itatbid_we_i,         // write to ITATBID register
  input wire                          itatbctr0_we_i,       // write to ITATBCTR0 register
  input wire [10:0]                   pwdatadbg10_0_r_i,    // APB data 10:0

  // Q-Channel
  input wire                          q_stop_i,             // Q-Channel STOPPED or STOPPING
  input wire                          q_stopped_i,          // Q-Channel STOPPED
  input wire                          q_flush_i,            // Q-Channel initiated autoflush

  // Test Interface
  input wire                          DFTCLKCGEN            // Force FIFO clock gate on in test mode
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam EXTTS_FIFO_DEPTH  = 3;    // Depth of timestamp fifo
  localparam CTRL_FIFO_WIDTH   = 4;    // Control fifo width
  localparam DATA_FIFO_WIDTH   = (STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+28); // Data fifo width (plus LSB of timestamp)
  localparam CH_FIFO_WIDTH     = 27;   // Channel fifo width
  localparam EXTTS_FIFO_WIDTH  = 50;   // Timestamp fifo width (MSB of timestamp)

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                             ctrl_in_valid;
  wire [CTRL_FIFO_WIDTH-1:0]       ctrl_in_data;
  wire                             ctrl_out_ready;
  wire                             ctrl_in_ready;
  wire                             ctrl_out_valid;
  wire [CTRL_FIFO_WIDTH-1:0]       ctrl_out_data;
  wire                             data_in_valid;
  wire [DATA_FIFO_WIDTH-1:0]       data_in_data;
  wire                             data_out_ready;
  wire                             data_in_ready;
  wire                             data_out_valid;
  wire [DATA_FIFO_WIDTH-1:0]       data_out_data;
  wire                             ch_in_valid;
  wire [CH_FIFO_WIDTH-1:0]         ch_in_data;
  wire                             ch_out_ready;
  wire                             ch_in_ready;
  wire                             ch_out_valid;
  wire [CH_FIFO_WIDTH-1:0]         ch_out_data;
  wire                             extts_in_valid;
  wire [EXTTS_FIFO_WIDTH-1:0]      extts_in_data;
  wire                             extts_out_ready;
  wire                             extts_in_ready;
  wire                             extts_out_valid;
  wire [EXTTS_FIFO_WIDTH-1:0]      extts_out_data;
  wire                             asyncout_int;
  wire                             packer_done;
  wire                             packets_valid;
  wire [1:0]                       pack_sequence;
  wire [2:0]                       packer_request;
  wire [59:0]                      async1_packet;
  wire [3:0]                       async1_packet_size;
  wire [35:0]                      async2_packet;
  wire [3:0]                       async2_packet_size;
  wire [59:0]                      async3_packet;
  wire [3:0]                       async3_packet_size;
  wire [35:0]                      mc_packet;
  wire [3:0]                       mc_packet_size;
  wire [(STM_DATA_WIDTH+27):0]     data_packet;
  wire [((STM_DATA_WIDTH/32)+2):0] data_packet_size;
  wire [47:0]                      extts_packet;
  wire [3:0]                       extts_packet_size;
  wire                             flush_req;
  wire                             tracegen_busy;
  wire                             atb_busy;
  wire                             tgu_busy;
  wire                             tgu_fifo_empty;
  wire                             afreadym_int;
  wire                             fifo_clk_gated;
  wire                             tracegen_clk_req;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  cxstm500_fifo_clk_module u_cxstm500_fifo_clk_module (
  .clk_gated           (clk_gated),
  .fifo_empty_i        (tgu_fifo_empty),
  .data_valid_i        (tracegen_clk_req),
  .DFTCLKCGEN          (DFTCLKCGEN),
  .fifo_clk_gated      (fifo_clk_gated)
  );

  // TGU interface, sync insertion and FIFO write
  cxstm500_tgu_tracegen u_cxstm500_tgu_tracegen (
  // Clock and Reset
  .clk_gated             (clk_gated),
  .STMRESETn             (STMRESETn),
  .tgu_valid_i           (tgu_valid_i),
  .tgu_master_i          (tgu_master_i[7:0]),
  .tgu_channel_i         (tgu_channel_i[15:0]),
  .tgu_packet_type_i     (tgu_packet_type_i[2:0]),
  .tgu_size_i            (tgu_size_i[(STM_DATA_WIDTH/32):0]),
  .tgu_payload_i         (tgu_payload_i[STM_DATA_WIDTH-1:0]),
  .tgu_ts_req_i          (tgu_ts_req_i[1:0]),
  .tgu_fready_i          (tgu_fready_i),
  .tgu_ready_o           (tgu_ready_o),
  .tgu_timestamped_o     (tgu_timestamped_o),
  .tgu_fvalid_o          (tgu_fvalid_o),
  .tsvalue_i             (tsvalue_i[63:0]),
  .syncreq_i             (syncreq_i),
  .stm_enable_syncreq_i  (stm_enable_syncreq_i),
  .asyncout_i            (asyncout_int),
  .ctrl_in_ready_i       (ctrl_in_ready),
  .ctrl_in_valid_o       (ctrl_in_valid),
  .ctrl_in_data_o        (ctrl_in_data[CTRL_FIFO_WIDTH-1:0]),
  .data_in_ready_i       (data_in_ready),
  .data_in_valid_o       (data_in_valid),
  .data_in_data_o        (data_in_data[(STM_DATA_WIDTH+(STM_DATA_WIDTH/32)+27):0]),
  .ch_in_ready_i         (ch_in_ready),
  .ch_in_valid_o         (ch_in_valid),
  .ch_in_data_o          (ch_in_data[CH_FIFO_WIDTH-1:0]),
  .extts_in_ready_i      (extts_in_ready),
  .extts_in_valid_o      (extts_in_valid),
  .extts_in_data_o       (extts_in_data[EXTTS_FIFO_WIDTH-1:0]),
  .tgu_cfg_enable_i      (tgu_cfg_enable_i),
  .tgu_cfg_tsen_i        (tgu_cfg_tsen_i),
  .tgu_cfg_spcompen_i    (tgu_cfg_spcompen_i),
  .tgu_cfg_hwcompen_i    (tgu_cfg_hwcompen_i),
  .tracegen_clk_req_o    (tracegen_clk_req),
  .tracegen_busy_o       (tracegen_busy),
  .tgu_cfg_asyncpe_i     (tgu_cfg_asyncpe_i),
  .AFVALIDM              (AFVALIDM),
  .afreadym_i            (afreadym_int),
  .q_stop_i              (q_stop_i),
  .q_stopped_i           (q_stopped_i)
  );

  // FIFOs
  // Control FIFO
  // Bit-fileds
  //  3  - flush marker
  //  2  - extended timestamp needed
  //  1  - master/channel packet needed
  //  0 TYPE
  //    0 - use control FIFO only
  //    1 - use data from other FIFOs
  cxstm500_tgu_fifo #(
    .DATA_WIDTH          (CTRL_FIFO_WIDTH),
    .FIFO_DEPTH          (DATA_FIFO_DEPTH)
    ) u_ctrl_fifo
    (
    .clk_gated           (fifo_clk_gated),
    .STMRESETn           (STMRESETn),
    .fifoin_valid_i      (ctrl_in_valid),
    .fifoin_data_i       (ctrl_in_data[CTRL_FIFO_WIDTH-1:0]),
    .fifoout_ready_i     (ctrl_out_ready),
    .fifoin_ready_o      (ctrl_in_ready),
    .fifoout_valid_o     (ctrl_out_valid),
    .fifoout_data_o      (ctrl_out_data[CTRL_FIFO_WIDTH-1:0])
    );

  // Data FIFO
  // Bit-fields
  //
  //  32-bit STM | 64-bit STM
  //---------------------------------
  //  60:57      | 93:89 - data packet size
  //  56         | 88    - extended opcode
  //  55:52      | 87:84 - packet opcode
  //  51:20      | 83:20 - data
  //  19:16      | 19:16 - timestamp size
  //  15:0       | 15:0  - LSB timestamp

  cxstm500_tgu_fifo #(
    .DATA_WIDTH          (DATA_FIFO_WIDTH),
    .FIFO_DEPTH          (DATA_FIFO_DEPTH)
    ) u_data_fifo
    (
    .clk_gated           (fifo_clk_gated),
    .STMRESETn           (STMRESETn),
    .fifoin_valid_i      (data_in_valid),
    .fifoin_data_i       (data_in_data[DATA_FIFO_WIDTH-1:0]),
    .fifoout_ready_i     (data_out_ready),
    .fifoin_ready_o      (data_in_ready),
    .fifoout_valid_o     (data_out_valid),
    .fifoout_data_o      (data_out_data[DATA_FIFO_WIDTH-1:0])
    );

  // Channel FIFO
  // Bit-fileds
  //  26:24 - MC type
  //  23:16 - channel number
  //  7:0   - master number

  cxstm500_tgu_fifo #(
    .DATA_WIDTH          (CH_FIFO_WIDTH),
    .FIFO_DEPTH          (CHN_FIFO_DEPTH)
    ) u_ch_fifo
    (
    .clk_gated           (fifo_clk_gated),
    .STMRESETn           (STMRESETn),
    .fifoin_valid_i      (ch_in_valid),
    .fifoin_data_i       (ch_in_data[CH_FIFO_WIDTH-1:0]),
    .fifoout_ready_i     (ch_out_ready),
    .fifoin_ready_o      (ch_in_ready),
    .fifoout_valid_o     (ch_out_valid),
    .fifoout_data_o      (ch_out_data[CH_FIFO_WIDTH-1:0])
    );

  // MSB bits of timestamp FIFO
  // Bit-fileds
  //  49:48 - extended timestamp size
  //  47:0  - MSB timestamp
  cxstm500_tgu_fifo #(
    .DATA_WIDTH          (EXTTS_FIFO_WIDTH),
    .FIFO_DEPTH          (EXTTS_FIFO_DEPTH)
    ) u_ext_ts_fifo
    (
    .clk_gated         (fifo_clk_gated),
    .STMRESETn           (STMRESETn),
    .fifoin_valid_i      (extts_in_valid),
    .fifoin_data_i       (extts_in_data[EXTTS_FIFO_WIDTH-1:0]),
    .fifoout_ready_i     (extts_out_ready),
    .fifoin_ready_o      (extts_in_ready),
    .fifoout_valid_o     (extts_out_valid),
    .fifoout_data_o      (extts_out_data[EXTTS_FIFO_WIDTH-1:0])
    );

  // FIFO read, STPv2 packet building
  cxstm500_tgu_packetgen #(
    .STM_DATA_WIDTH        (STM_DATA_WIDTH)
  )
  u_cxstm500_tgu_packetgen
  (
    .clk_gated           (clk_gated),
    .STMRESETn             (STMRESETn),
    .tgu_cfg_tsfreqr_i     (tgu_cfg_tsfreqr_i),
    .ctrl_out_valid_i      (ctrl_out_valid),
    .ctrl_out_data_i       (ctrl_out_data[CTRL_FIFO_WIDTH-1:0]),
    .ctrl_out_ready_o      (ctrl_out_ready),
    .data_out_data_i       (data_out_data[DATA_FIFO_WIDTH-1:0]),
    .data_out_ready_o      (data_out_ready),
    .ch_out_data_i         (ch_out_data[CH_FIFO_WIDTH-1:0]),
    .ch_out_ready_o        (ch_out_ready),
    .extts_out_data_i      (extts_out_data[EXTTS_FIFO_WIDTH-1:0]),
    .extts_out_ready_o     (extts_out_ready),
    .packer_done_i         (packer_done),
    .packets_valid_o       (packets_valid),
    .pack_sequence_o       (pack_sequence[1:0]),
    .packer_request_o      (packer_request[2:0]),
    .async1_packet_o       (async1_packet[59:0]),
    .async1_packet_size_o  (async1_packet_size[3:0]),
    .async2_packet_o       (async2_packet[35:0]),
    .async2_packet_size_o  (async2_packet_size[3:0]),
    .async3_packet_o       (async3_packet[59:0]),
    .async3_packet_size_o  (async3_packet_size[3:0]),
    .mc_packet_o           (mc_packet[35:0]),
    .mc_packet_size_o      (mc_packet_size[3:0]),
    .data_packet_o         (data_packet[(STM_DATA_WIDTH+27):0]),
    .data_packet_size_o    (data_packet_size[((STM_DATA_WIDTH/32)+2):0]),
    .extts_packet_o        (extts_packet[47:0]),
    .extts_packet_size_o   (extts_packet_size[3:0]),
    .flush_req_o           (flush_req),
    .asyncout_o            (asyncout_int),
    .itctl_i               (itctl_i),
    .ittrigger_we_i        (ittrigger_we_i),
    .pwdatadbg3_r_i        (pwdatadbg10_0_r_i[3])
    );

  // Packing, alignment and ATB interface
  cxstm500_tgu_atbmast #(
    .STM_DATA_WIDTH        (STM_DATA_WIDTH)
  )
  u_cxstm500_tgu_atbmast
  (
    .clk_gated           (clk_gated),
    .STMRESETn             (STMRESETn),
    .tgu_cfg_enable_i      (tgu_cfg_enable_i),
    .tgu_cfg_traceid_i     (tgu_cfg_traceid_i[6:0]),
    .tgu_cfg_fifoaf_i      (tgu_cfg_fifoaf_i),
    .tgu_fifo_empty_i      (tgu_fifo_empty),
    .tgu_cfg_freadyhigh_i  (tgu_cfg_freadyhigh_i),
    .tgu_flush_i           (tgu_flush_i),
    .tgu_busy_i            (tgu_busy),
    .atb_busy_o            (atb_busy),
    .packets_valid_i       (packets_valid),
    .pack_sequence_i       (pack_sequence[1:0]),
    .packer_request_i      (packer_request[2:0]),
    .async1_packet_i       (async1_packet[59:0]),
    .async1_packet_size_i  (async1_packet_size[3:0]),
    .async2_packet_i       (async2_packet[35:0]),
    .async2_packet_size_i  (async2_packet_size[3:0]),
    .async3_packet_i       (async3_packet[59:0]),
    .async3_packet_size_i  (async3_packet_size[3:0]),
    .mc_packet_i           (mc_packet[35:0]),
    .mc_packet_size_i      (mc_packet_size[3:0]),
    .data_packet_i         (data_packet[(STM_DATA_WIDTH+27):0]),
    .data_packet_size_i    (data_packet_size[((STM_DATA_WIDTH/32)+2):0]),
    .extts_packet_i        (extts_packet[47:0]),
    .extts_packet_size_i   (extts_packet_size[3:0]),
    .flush_req_i           (flush_req),
    .packer_done_o         (packer_done),
    .tgu_trace_trigger_i   (tgu_trace_trigger_i),
    .ATREADYM              (ATREADYM),
    .AFVALIDM              (AFVALIDM),
    .atvalid_o             (atvalid_o),
    .ATBYTESM              (ATBYTESM),
    .ATDATAM               (ATDATAM),
    .ATIDM                 (ATIDM),
    .afreadym_o            (afreadym_int),
    .itctl_i               (itctl_i),
    .itatbdata0_we_i       (itatbdata0_we_i),
    .itatbid_we_i          (itatbid_we_i),
    .itatbctr0_we_i        (itatbctr0_we_i),
    .pwdatadbg10_0_r_i     (pwdatadbg10_0_r_i[10:0]),
    .q_stopped_i           (q_stopped_i),
    .q_flush_i             (q_flush_i)
    );

  // TGU status
  cxstm500_tgu_status #(
    .FIFO_DEPTH          (DATA_FIFO_DEPTH)
    ) u_cxstm500_tgu_status
    (
    .clk_gated           (clk_gated),
    .STMRESETn           (STMRESETn),
    .fifoin_valid_i      (ctrl_in_valid),
    .fifoin_ready_i      (ctrl_in_ready),
    .fifoout_valid_i     (ctrl_out_valid),
    .fifoout_ready_i     (ctrl_out_ready),
    .tgu_valid_i         (tgu_valid_i),
    .tracegen_busy_i     (tracegen_busy),
    .atb_busy_i          (atb_busy),
    .tgu_busy_o          (tgu_busy),
    .tgu_fifo_level_o    (tgu_fifo_level_o[1:0]),
    .tgu_fifo_empty_o    (tgu_fifo_empty),
    .tgu_fifo_full_o     (tgu_fifo_full_o)
  );

  // Cross-trigger
  assign asyncout_o  = asyncout_int;

  // Status
  assign tgu_busy_o  = tgu_busy | ctrl_in_valid;

  // Flush ready
  assign AFREADYM    = afreadym_int;

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
  integer fifo_fill;
  integer i;
  always @*
  begin
      fifo_fill = 0;
      for (i=0; i < DATA_FIFO_DEPTH; i=i+1)
        if (u_ctrl_fifo.array_valid_reg[i]) fifo_fill = fifo_fill + 1;
  end

  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Fifo level is wrong")
    ovl_always_tgu_correct_fifo_level (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (fifo_fill == u_cxstm500_tgu_status.fifo_level_reg)
    );

  wire ovl_data_needed;
  assign ovl_data_needed = ctrl_out_data[0];
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when data is needed data FIFO must be valid")
    ovl_never_tgu_fifo_valid_when_data_needed (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (ctrl_out_valid & ovl_data_needed & ~data_out_valid)
    );

 wire ovl_extts_needed;
 assign ovl_extts_needed = ctrl_out_data[2] & ctrl_out_data[0];
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when extts is needed extts FIFO must be valid")
    ovl_never_tgu_valid_when_extts_needed (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (ctrl_out_valid & ovl_extts_needed & ~extts_out_valid)
    );

  wire [3:0]  ovl_stpv2_opcode;
  generate
    if (STM_DATA_WIDTH == 64) begin : gen_opcode_check_64
      assign ovl_stpv2_opcode = data_out_data[87:84];

      assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal data opcode")
        ovl_never_tgu_illegal_data_opcode_64 (
        .clk       (clk_gated),
        .reset_n   (STMRESETn),
        .test_expr (data_out_valid & (ovl_stpv2_opcode[3:0]==4'h0))
      );

    end


  endgenerate


  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Illegal MC type opcode")
    ovl_never_tgu_illegal_mc_opcode (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (ch_out_valid & ((ch_out_data[26:24]==3'b000)|(ch_out_data[26:24]==3'b110)|(ch_out_data[26:24]==3'b111)))
    );

  wire ovl_mc_needed;
  assign ovl_mc_needed = ctrl_out_data[1] & ctrl_out_data[0];
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"when channel is needed channel FIFO must be valid")
    ovl_never_tgu_valid_when_channel_needed (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (ctrl_out_valid & ovl_mc_needed & ~ch_out_valid)
    );

  // This assertion is not applicable in integration mode.
  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"ASYNCOUT should be one clock cycle pulse")
    ovl_next_tgu_asyncout_one_clock_pulse (
      .clk         (clk_gated),
      .reset_n     (STMRESETn),
      .start_event (~itctl_i & asyncout_int),
      .test_expr   (~asyncout_int)
    );

`endif

endmodule // cxstm500_tgu
