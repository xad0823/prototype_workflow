//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2014 ARM Limited.
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
//      Wrapper for STM AXI reset domain.
//-----------------------------------------------------------------------------

module cxstm500_axi_rst_domain
#(
  parameter   AXI_ID_WIDTH = 8,   // AXI ID width, set when stitching with interconnect
  parameter   STM_DATA_WIDTH = 64 // STM Data width
)
(
  // TOP LEVEL INTERFACES
  // Clock and Reset
  input wire                          CLK,                   // AXI Clock
  input wire                          ARESETn,               // AXI Reset

  // AMBA3 AXI Interface
  // AW channel
  input wire [AXI_ID_WIDTH-1:0]       AWIDS,                 // Write Address ID
  input wire                          AWVALIDS,              // Write Address Valid
  input wire [31:0]                   AWADDRS,               // Write Address
  input wire [2:0]                    AWSIZES,               // Write Size
  input wire [7:0]                    AWLENS,                // Burst Length
  input wire [1:0]                    AWBURSTS,              // Write Burst Type
  input wire [2:0]                    AWPROTS,               // Write Authentication
  output wire                         AWREADYS,              // Write Address Ready

  // W channel
  input wire                          WVALIDS,               // Write Data Valid
  input wire [STM_DATA_WIDTH-1:0]     WDATAS,                // Write Data
  input wire [(STM_DATA_WIDTH/8)-1:0] WSTRBS,                // Write Strobes
  input wire                          WLASTS,                // Write Data Last
  output wire                         WREADYS,               // Write Data Ready

  // B channel
  input wire                          BREADYS,               // Write Response Ready
  output wire                         BVALIDS,               // Write Response Valid
  output wire [AXI_ID_WIDTH-1:0]      BIDS,                  // Write Response ID
  output wire [1:0]                   BRESPS,                // Write Response

  // AR channel
  input wire                          ARVALIDS,              // Read Address Valid
  input wire [AXI_ID_WIDTH-1:0]       ARIDS,                 // Read Address ID
  input wire [7:0]                    ARLENS,                // Read Burst Length
  output wire                         ARREADYS,              // Read Address Ready

  // R channel
  input wire                          RREADYS,               // Read Data Ready
  output wire                         RVALIDS,               // Read Data Valid
  output wire [AXI_ID_WIDTH-1:0]      RIDS,                  // Read Data ID
  output wire [STM_DATA_WIDTH-1:0]    RDATAS,                // Read Data
  output wire [1:0]                   RRESPS,                // Read Response
  output wire                         RLASTS,                // Read Data Last

  // Trigger Interface
  output wire                         TRIGOUTSPTE,           // Trigger output event, matches using STMSPTER
  output wire                         TRIGOUTSW,             // Trigger output event, writes to TRIG location

  // DMA Peripheral Request Interface
  input  wire                         DRREADY,               // DMA Request Ready
  input  wire                         DAVALID,               // DMA Acknowledge Valid
  input  wire [1:0]                   DATYPE,                // DMA Acknowledge Type
  output wire                         DRVALID,               // DMA Request Valid
  output wire [1:0]                   DRTYPE,                // DMA Request Type
  output wire                         DRLAST,                // DMA Last Request
  output wire                         DAREADY,               // DMA Acknowledge Ready

  // SIGNALS CROSSING INTO DEBUG RESET DOMAIN
  // TGU data Interface
  input wire                          axi_tgu_ready_i,       // TGU Transfer Ready
  input wire                          axi_tgu_timestamped_i, // Timestamp Indicator
  input wire                          axi_tgu_fvalid_i,      // Data flush request
  output wire                         axi_tgu_valid_o,       // TGU Transfer Valid
  output wire [7:0]                   axi_tgu_master_o,      // Master Number
  output wire [15:0]                  axi_tgu_channel_o,     // STPv2 Channel Number
  output wire [2:0]                   axi_tgu_packet_type_o, // STPv2 Packet Type
  output wire [(STM_DATA_WIDTH/32):0] axi_tgu_size_o,        // Payload Size
  output wire [STM_DATA_WIDTH-1:0]    axi_tgu_payload_o,     // Payload
  output wire [1:0]                   axi_tgu_ts_req_o,      // Timestamp Qualifier
  output wire                         axi_tgu_fready_o,      // Data flush completed

  // Configuration and Status Interface
  input wire                          axi_enable_i,          // STM Enable
  input wire [31:0]                   axi_sper_i,            // SPER value
  input wire [31:0]                   axi_spter_i,           // SPTER value
  input wire                          axi_singleshot_i,      // SPTE singleshot mode
  input wire                          axi_trigstatusspte_i,  // SPTE trigger status in singleshot mode
  input wire [11:0]                   axi_banksel_i,         // STMSPSCR.PORTSEL
  input wire [1:0]                    axi_portctl_i,         // STMSPSCR.PORTCTL
  input wire [7:0]                    axi_mastsel_i,         // STMSPMSCR.MASTSEL
  input wire                          axi_mastctl_i,         // STMSPMSCR.MASTCTL
  input wire [16:0]                   axi_overportsel_i,     // STMSPOVERRIDER.PORTSEL
  input wire                          axi_overts_i,          // Timestamp Override
  input wire [1:0]                    axi_overportctl_i,     // STMSPOVERRIDER.OVERCTL
  input wire [7:0]                    axi_overmastsel_i,     // STMSPMOVERRIDER.MASTSEL
  input wire                          axi_overmastctl_i,     // STMSPMOVERRIDER.MASTCTL
  input wire                          axi_tsen_i,            // Timestamping Enable
  input wire                          axi_buf_clr_i,         // AXI Buffer Clear
  output wire                         axi_busy_o,            // Busy Status

  // Trigger Interface
  output wire                         triggerspte_o,         // Trigger, matches using STMSPTER
  output wire                         triggersw_o,           // Trigger, writes to TRIG location

  // DMA control interface
  input  wire                         dma_enable_i,          // dma request generation enable
  input  wire [1:0]                   dma_sens_i,            // dma fifo sensitivity
  input  wire [1:0]                   tgu_fifo_level_i,      // dma fifo sensitivity
  input  wire                         tgu_fifo_full_i,       // TGU fifo full
  output wire                         dma_busy_o,            // dma busy

  // Authentication Interface
  input wire                          dbgen_r_i,             // Invasive debug enable
  input wire                          niden_r_i,             // Non-invasive debug enable
  input wire                          spiden_r_i,            // Secure invasive debug enable
  input wire                          spniden_r_i,           // Secure non-invasive debug enable
  input wire                          nsguaren_r_i,          // Enable non-secure guaranteed stimulus port accesses

  // Integartion testing interface
  input wire                          itctl_i,               // integration mode
  input wire                          ittrigger_we_i,        // write to ITTRIGGER register
  input wire [1:0]                    pwdatadbg1_0_r_i,      // APB data 1:0

  // Q-Channel Interface
  input  wire                         AXIQREQn,              // Quiescence Request

  output wire                         AXIQACCEPTn,           // Quiescence Request Acknowledge
  output wire                         AXIQDENY,              // Quiescence Request Deny
  output wire                         AXIQACTIVE,            // STM Active

  input  wire                         AWAKEUP,               // AXI Active Signal

  input wire                          qforcedeny_i           // Force Deny Override
  );


  // --------------------------------------------------------------------------
  // Wires
  // --------------------------------------------------------------------------

  wire axi_busy_qchan;
  wire dma_busy_qchan;
  wire q_stop;
  wire q_stopped;

  // --------------------------------------------------------------------------
  // Front End Interfaces
  // --------------------------------------------------------------------------

  // AXI Slave Interface
  cxstm500_axislvif
  #(
    .AXI_ID_WIDTH           (AXI_ID_WIDTH),
    .STM_DATA_WIDTH         (STM_DATA_WIDTH)
  )
  u_cxstm500_axislvif
  (
    .CLK                    (CLK),
    .ARESETn                (ARESETn),

    .AWIDS                  (AWIDS),
    .AWVALIDS               (AWVALIDS),
    .AWREADYS               (AWREADYS),
    .AWADDRS                (AWADDRS[31:0]),
    .AWSIZES                (AWSIZES[2:0]),
    .AWLENS                 (AWLENS),
    .AWBURSTS               (AWBURSTS[1:0]),
    .AWPROTS                (AWPROTS),

    .WVALIDS                (WVALIDS),
    .WREADYS                (WREADYS),
    .WDATAS                 (WDATAS[STM_DATA_WIDTH-1:0]),
    .WSTRBS                 (WSTRBS),
    .WLASTS                 (WLASTS),

    .BVALIDS                (BVALIDS),
    .BREADYS                (BREADYS),
    .BIDS                   (BIDS[AXI_ID_WIDTH-1:0]),
    .BRESPS                 (BRESPS[1:0]),

    .ARVALIDS               (ARVALIDS),
    .ARREADYS               (ARREADYS),
    .ARIDS                  (ARIDS[AXI_ID_WIDTH-1:0]),
    .ARLENS                 (ARLENS),

    .RVALIDS                (RVALIDS),
    .RREADYS                (RREADYS),
    .RIDS                   (RIDS[AXI_ID_WIDTH-1:0]),
    .RDATAS                 (RDATAS[STM_DATA_WIDTH-1:0]),
    .RRESPS                 (RRESPS[1:0]),
    .RLASTS                 (RLASTS),

    .tgu_valid_o            (axi_tgu_valid_o),
    .tgu_ready_i            (axi_tgu_ready_i),
    .tgu_master_o           (axi_tgu_master_o[7:0]),
    .tgu_channel_o          (axi_tgu_channel_o[15:0]),
    .tgu_packet_type_o      (axi_tgu_packet_type_o[2:0]),
    .tgu_size_o             (axi_tgu_size_o),
    .tgu_payload_o          (axi_tgu_payload_o[STM_DATA_WIDTH-1:0]),
    .tgu_ts_req_o           (axi_tgu_ts_req_o[1:0]),
    .tgu_fready_o           (axi_tgu_fready_o),
    .tgu_timestamped_i      (axi_tgu_timestamped_i),
    .tgu_fvalid_i           (axi_tgu_fvalid_i),

    .axi_enable_i           (axi_enable_i),
    .axi_sper_i             (axi_sper_i[31:0]),
    .axi_spter_i            (axi_spter_i[31:0]),
    .axi_singleshot_i       (axi_singleshot_i),
    .axi_trigstatusspte_i   (axi_trigstatusspte_i),
    .axi_banksel_i          (axi_banksel_i[11:0]),
    .axi_portctl_i          (axi_portctl_i[1:0]),
    .axi_mastsel_i          (axi_mastsel_i[7:0]),
    .axi_mastctl_i          (axi_mastctl_i),
    .axi_overportsel_i      (axi_overportsel_i[16:0]),
    .axi_overts_i           (axi_overts_i),
    .axi_overportctl_i      (axi_overportctl_i[1:0]),
    .axi_overmastsel_i      (axi_overmastsel_i[7:0]),
    .axi_overmastctl_i      (axi_overmastctl_i),
    .axi_tsen_i             (axi_tsen_i),
    .axi_buf_clr_i          (axi_buf_clr_i),
    .axi_busy_q_channel_o   (axi_busy_qchan),
    .axi_busy_stm_o         (axi_busy_o),

    .triggerspte_o          (triggerspte_o),
    .TRIGOUTSPTE            (TRIGOUTSPTE),
    .triggersw_o            (triggersw_o),
    .TRIGOUTSW              (TRIGOUTSW),

    .dbgen_r_i              (dbgen_r_i),
    .niden_r_i              (niden_r_i),
    .spiden_r_i             (spiden_r_i),
    .spniden_r_i            (spniden_r_i),

    .nsguaren_r_i           (nsguaren_r_i),

    .itctl_i                (itctl_i),
    .ittrigger_we_i         (ittrigger_we_i),
    .pwdatadbg1_0_r_i       (pwdatadbg1_0_r_i[1:0]),

    .q_stop_i               (q_stop)
  );

  // DMA Peripheral Request Interface
  cxstm500_dmaif u_cxstm500_dmaif (
    .CLK                 (CLK),
    .ARESETn             (ARESETn),
    .DRREADY             (DRREADY),
    .DAVALID             (DAVALID),
    .DATYPE              (DATYPE[1:0]),
    .DRVALID             (DRVALID),
    .DRTYPE              (DRTYPE[1:0]),
    .DRLAST              (DRLAST),
    .DAREADY             (DAREADY),
    .dma_enable_i        (dma_enable_i),
    .dma_sens_i          (dma_sens_i[1:0]),
    .tgu_fifo_level_i    (tgu_fifo_level_i[1:0]),
    .tgu_fifo_full_i     (tgu_fifo_full_i),
    .dma_busy_o          (dma_busy_o),
    .dma_busy_qchan_o    (dma_busy_qchan),
    .q_stop_i            (q_stop)
  );

  //Q-Channel Low Power Interface
  cxstm500_axi_qchanif u_cxstm500_axi_qchanif (
    .CLK                 (CLK),
    .ARESETn             (ARESETn),

    .AXIQREQn            (AXIQREQn),
    .AXIQACCEPTn         (AXIQACCEPTn),
    .AXIQDENY            (AXIQDENY),
    .AXIQACTIVE          (AXIQACTIVE),

    .AWAKEUP             (AWAKEUP),

    .axi_busy_i          (axi_busy_qchan),
    .dma_busy_i          (dma_busy_qchan),
    .qforcedeny_i        (qforcedeny_i),

    .q_stop_o            (q_stop),
    .q_stopped_o         (q_stopped)
  );

  `ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // Ensure AWREADY is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"AWREADY must be low during Q_STOPPED state")
    ovl_never_dbg_rst_awready_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & AWREADYS)
    );

  // Ensure WREADY is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"WREADY must be low during Q_STOPPED state")
    ovl_never_dbg_rst_wready_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & WREADYS)
    );

  // Ensure ARREADY is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"ARREADY must be low during Q_STOPPED state")
    ovl_never_dbg_rst_arready_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & ARREADYS)
    );

  // Ensure RVALID is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"RVALID must be low during Q_STOPPED state")
    ovl_never_dbg_rst_rvalid_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & RVALIDS)
    );

  // Ensure BVALID is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"BVALID must be low during Q_STOPPED state")
    ovl_never_dbg_rst_bvalid_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & BVALIDS)
    );

  // Ensure DRVALID is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"DRVALID must be low during Q_STOPPED state")
    ovl_never_dbg_rst_drvalid_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & DRVALID)
    );

  // Ensure DAREADY is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"DAREADY must be low during Q_STOPPED state")
    ovl_never_dbg_rst_daready_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & DAREADY)
    );

  // Ensure TRIGOUTSPTE is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"TRIGOUTSPTE must be low during Q_STOPPED state")
    ovl_never_dbg_rst_trigoutspte_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & TRIGOUTSPTE)
    );

  // Ensure TRIGOUTSW is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"TRIGOUTSW must be low during Q_STOPPED state")
    ovl_never_dbg_rst_trigoutsw_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & TRIGOUTSW)
    );

  // Ensure axi_tgu_valid_o is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"axi_tgu_valid_o must be low during Q_STOPPED state")
    ovl_never_dbg_rst_axi_tgu_valid_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & axi_tgu_valid_o)
    );

  // Ensure axi_busy is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"axi_busy must be low during Q_STOPPED state")
    ovl_never_dbg_rst_axi_busy_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & axi_busy_qchan)
    );

  // Ensure dma_busy is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"dma_busy must be low during Q_STOPPED state")
    ovl_never_dbg_rst_dma_busy_low (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (q_stopped & dma_busy_qchan)
    );

`endif


endmodule
