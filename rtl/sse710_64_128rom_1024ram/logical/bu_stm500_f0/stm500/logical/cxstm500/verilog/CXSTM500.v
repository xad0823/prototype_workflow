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
//      Revision            : $Revision: 38826 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Top Level Module for STM
//-----------------------------------------------------------------------------

module CXSTM500 #(
   parameter        HWEVOBIF_PRESENT = 1,                   // Valid Values: 0 or 1
   parameter        AXI_ID_WIDTH = 24,                      // Valid Values: 2 - 24
   parameter        DATA_FIFO_DEPTH = 32,                   // Valid Values: 4/8/16/32
   parameter        CHN_FIFO_DEPTH = 32,                    // Valid Values: 4/8/16/32
   parameter [31:0] HWEVOBIF_CONFIG_63_32 = 32'h0000_0000,  // 0 indicates edge detection, 1 indicates level detection, 1 bit per event
   parameter [31:0] HWEVOBIF_CONFIG_31_0 = 32'h0000_0000    // 0 indicates edge detection, 1 indicates level detection, 1 bit per event
 )
  (
  // --------------------------------------------------------------------------
  // Clocks and Resets
  // --------------------------------------------------------------------------
  input wire                     CLK,          // STM Clock
  input wire                     ARESETn,      // AXI Reset
  input wire                     STMRESETn,    // STM Reset
  // --------------------------------------------------------------------------
  // AXI Slave Interface
  // --------------------------------------------------------------------------
  // AR Channel
  input wire [AXI_ID_WIDTH-1:0]  ARIDS,        // Read Address ID
  input wire [31:0]              ARADDRS,      // Read Address
  input wire [7:0]               ARLENS,       // Read Burst Length
  input wire [2:0]               ARSIZES,      // Read Burst Size
  input wire [1:0]               ARBURSTS,     // Read Burst Type
  input wire                     ARLOCKS,      // Read Lock Type
  input wire [3:0]               ARCACHES,     // Read Cache Type
  input wire [2:0]               ARPROTS,      // Read Protection Type
  input wire                     ARVALIDS,     // Read Address Valid
  output wire                    ARREADYS,     // Read Address Ready

  // R Channel
  input  wire                    RREADYS,      // Read Data Ready
  output wire [AXI_ID_WIDTH-1:0] RIDS,         // Read Data ID
  output wire [63:0]             RDATAS,       // Read Data
  output wire [1:0]              RRESPS,       // Read Response
  output wire                    RLASTS,       // Read Data Last
  output wire                    RVALIDS,      // Read Data Valid

  // AW Channel
  input wire [AXI_ID_WIDTH-1:0]  AWIDS,        // Write Address ID
  input wire [31:0]              AWADDRS,      // Write Address
  input wire [7:0]               AWLENS,       // Write Burst Length
  input wire [2:0]               AWSIZES,      // Write Burst Size
  input wire [1:0]               AWBURSTS,     // Write Burst Type
  input wire                     AWLOCKS,      // Write Lock Type
  input wire [3:0]               AWCACHES,     // Write Cache Type
  input wire [2:0]               AWPROTS,      // Write Protection Type
  input wire                     AWVALIDS,     // Write Address Valid
  output wire                    AWREADYS,     // Write Address Ready

  // W Channel
  input wire [63:0]              WDATAS,       // Write Data
  input wire [7:0]               WSTRBS,       // Write Strobes
  input wire                     WLASTS,       // Write Data Last
  input wire                     WVALIDS,      // Write Data Valid
  output wire                    WREADYS,      // Write Data Ready

  // B Channel
  input wire                     BREADYS,      // Write Response Ready
  output wire [AXI_ID_WIDTH-1:0] BIDS,         // Write Response ID
  output wire [1:0]              BRESPS,       // Write Response
  output wire                    BVALIDS,      // Write Response Valid

  // --------------------------------------------------------------------------
  // Debug APB Slave Interface
  // --------------------------------------------------------------------------
  input wire                     PSELDBG,      // APB slave select
  input wire                     PENABLEDBG,   // APB enable
  input wire                     PWRITEDBG,    // APB write
  input wire                     PADDRDBG31,   // APB internal vs external access select
  input wire [11:2]              PADDRDBG,     // APB address
  input wire [31:0]              PWDATADBG,    // APB write data
  output wire                    PREADYDBG,    // APB ready
  output wire                    PSLVERRDBG,   // APB slave error
  output wire [31:0]             PRDATADBG,    // APB read data

  // --------------------------------------------------------------------------
  // ATB Master Interface
  // --------------------------------------------------------------------------
  input wire                     ATREADYM,     // ATB ready
  input wire                     AFVALIDM,     // ATB flush valid
  input wire                     SYNCREQM,     // ATB synchronization request
  output wire                    ATVALIDM,     // ATB valid
  output wire [2:0]              ATBYTESM,     // ATB bytes
  output wire [63:0]             ATDATAM,      // ATB data
  output wire [6:0]              ATIDM,        // ATB ID
  output wire                    AFREADYM,     // ATB flush ready

  // --------------------------------------------------------------------------
  // Hardware Event Observation Port
  // --------------------------------------------------------------------------
  input wire  [63:0]             HWEVENTS,     // Hardware Events
  output wire [7:0]              HEEXTMUX,     // Hardware Event External Multiplexor Control

  // --------------------------------------------------------------------------
  // DMA Peripheral Request Interface
  // --------------------------------------------------------------------------
  input wire                     DRREADY,      // DMA Request Ready
  input wire                     DAVALID,      // DMA Acknowledge Valid
  input wire [1:0]               DATYPE,       // DMA Acknowledge Type
  output wire                    DRVALID,      // DMA Request Valid
  output wire [1:0]              DRTYPE,       // DMA Request Type
  output wire                    DRLAST,       // DMA Last Request
  output wire                    DAREADY,      // DMA Acknowledge Ready

  // --------------------------------------------------------------------------
  // Timestamp Port
  // --------------------------------------------------------------------------
  input wire [63:0]              TSVALUE,      // Timestamp value

  // --------------------------------------------------------------------------
  // Authentication Interface
  // --------------------------------------------------------------------------
  input wire                     DBGEN,        // Invasive debug enable
  input wire                     NIDEN,        // Non-invasive debug enable
  input wire                     SPIDEN,       // Secure invasive debug enable
  input wire                     SPNIDEN,      // Secure non-invasive debug enable

  // --------------------------------------------------------------------------
  // Non-secure AXI access control
  // --------------------------------------------------------------------------
  input wire                     NSGUAREN,     // Enable non-secure guaranteed stimulus port accesses

  // --------------------------------------------------------------------------
  // Cross-Triggering Interface
  // --------------------------------------------------------------------------
  output wire                    TRIGOUTSPTE,  // Trigger output event, matches using STMSPTER
  output wire                    TRIGOUTSW,    // Trigger output event, writes to TRIG location
  output wire                    TRIGOUTHETE,  // Trigger output event, matches using STMHETER
  output wire                    ASYNCOUT,     // Async sequence has been output event

  // --------------------------------------------------------------------------
  // Test Interface
  // --------------------------------------------------------------------------
  input wire                     DFTCLKCGEN,   // Force STM clock gates on in test mode

  //---------------------------------------------------------------------------
  // AXI Q-Channel Interface
  //---------------------------------------------------------------------------
  input  wire                    AXIQREQn,     //Quiscence Request
  output wire                    AXIQACCEPTn,  //Quiscence Request Acknowledge
  output wire                    AXIQDENY,     //Quiscence Request Deny
  output wire                    AXIQACTIVE,   //STM Active
  input  wire                    AWAKEUP,      //AXI Active Signal

  //---------------------------------------------------------------------------
  // STM Q-Channel Interface
  //---------------------------------------------------------------------------
  input  wire                    STMQREQn,     //Quiscence Request
  output wire                    STMQACCEPTn,  //Quiscence Request Acknowledge
  output wire                    STMQDENY,     //Quiscence Request Deny
  output wire                    STMQACTIVE,   //STM Active
  input  wire                    PWAKEUP       //APB Active Signal
);

  // --------------------------------------------------------------------------
  // Local Parameters
  // --------------------------------------------------------------------------

  localparam STM_DATA_WIDTH = 64;

  // Prevent the STM from being configured with Data FIFO depth less than
  // the Channel FIFO depth by defining the effective Data FIFO depth
  localparam DATA_FIFO_DEPTH_EFF = (DATA_FIFO_DEPTH < CHN_FIFO_DEPTH) ? CHN_FIFO_DEPTH
                                                                      : DATA_FIFO_DEPTH;

  // --------------------------------------------------------------------------
  // Global Nets
  // --------------------------------------------------------------------------
  wire [1:0]                   pwdatadbg1_0_r;
  wire                         axi_busy;
  wire                         dma_busy;
  wire                         axi_enable;
  wire [31:0]                  axi_sper;
  wire [31:0]                  axi_spter;
  wire                         axi_singleshot;
  wire                         axi_trigstatusspte;
  wire [11:0]                  axi_banksel;
  wire [1:0]                   axi_portctl;
  wire [7:0]                   axi_mastsel;
  wire                         axi_mastctl;
  wire [16:0]                  axi_overportsel;
  wire                         axi_overts;
  wire [1:0]                   axi_overportctl;
  wire [7:0]                   axi_overmastsel;
  wire                         axi_overmastctl;
  wire                         axi_tsen;
  wire                         axi_buf_clr;
  wire                         dma_enable;
  wire [1:0]                   dma_sens;
  wire [1:0]                   tgu_fifo_level;
  wire                         tgu_fifo_full;
  wire                         axi_tgu_valid;
  wire [7:0]                   axi_tgu_master;
  wire [15:0]                  axi_tgu_channel;
  wire [2:0]                   axi_tgu_packet_type;
  wire [(STM_DATA_WIDTH/32):0] axi_tgu_size;
  wire [STM_DATA_WIDTH-1:0]    axi_tgu_payload;
  wire [1:0]                   axi_tgu_ts_req;
  wire                         axi_tgu_ready;
  wire                         axi_tgu_timestamped;
  wire                         axi_tgu_fready;
  wire                         axi_tgu_fvalid;
  wire                         triggerspte;
  wire                         triggersw;
  wire                         itctl;
  wire                         ittrigger_we;
  wire                         dbgen_r;
  wire                         niden_r;
  wire                         spiden_r;
  wire                         spniden_r;
  wire                         nsguaren_r;
  wire [STM_DATA_WIDTH-1:0]    hwevents_int;
  wire [7:0]                   hweventmux_int;
  wire                         qforcedeny;

  //----------------------------------------------------------------------------
  // AXI reset domain
  //----------------------------------------------------------------------------
  cxstm500_axi_rst_domain
  #(
    .AXI_ID_WIDTH           (AXI_ID_WIDTH),
    .STM_DATA_WIDTH         (STM_DATA_WIDTH)
  )
  u_cxstm500_axi_rst_domain
  (
  // TOP LEVEL INTERFACES
  .CLK                    (CLK),
  .ARESETn                (ARESETn),

  // AXI
  .AWIDS                  (AWIDS[AXI_ID_WIDTH-1:0]),
  .AWVALIDS               (AWVALIDS),
  .AWADDRS                (AWADDRS[31:0]),
  .AWSIZES                (AWSIZES[2:0]),
  .AWLENS                 (AWLENS[7:0]),
  .AWBURSTS               (AWBURSTS[1:0]),
  .AWPROTS                (AWPROTS),
  .AWREADYS               (AWREADYS),

  .WVALIDS                (WVALIDS),
  .WDATAS                 (WDATAS[STM_DATA_WIDTH-1:0]),
  .WLASTS                 (WLASTS),
  .WREADYS                (WREADYS),
  .WSTRBS                 (WSTRBS),
  .BREADYS                (BREADYS),
  .BVALIDS                (BVALIDS),
  .BIDS                   (BIDS[AXI_ID_WIDTH-1:0]),
  .BRESPS                 (BRESPS[1:0]),

  .ARVALIDS               (ARVALIDS),
  .ARIDS                  (ARIDS[AXI_ID_WIDTH-1:0]),
  .ARLENS                 (ARLENS[7:0]),
  .ARREADYS               (ARREADYS),

  .RREADYS                (RREADYS),
  .RVALIDS                (RVALIDS),
  .RIDS                   (RIDS[AXI_ID_WIDTH-1:0]),
  .RDATAS                 (RDATAS[STM_DATA_WIDTH-1:0]),
  .RRESPS                 (RRESPS[1:0]),
  .RLASTS                 (RLASTS),

  .TRIGOUTSPTE            (TRIGOUTSPTE),
  .TRIGOUTSW              (TRIGOUTSW),

  // DMA
  .DRREADY                (DRREADY),
  .DAVALID                (DAVALID),
  .DATYPE                 (DATYPE[1:0]),
  .DRVALID                (DRVALID),
  .DRTYPE                 (DRTYPE[1:0]),
  .DRLAST                 (DRLAST),
  .DAREADY                (DAREADY),

  // SIGNALS CROSSING INTO AXI RESET DOMAIN
  .axi_tgu_valid_o        (axi_tgu_valid),
  .axi_tgu_ready_i        (axi_tgu_ready),
  .axi_tgu_master_o       (axi_tgu_master[7:0]),
  .axi_tgu_channel_o      (axi_tgu_channel[15:0]),
  .axi_tgu_packet_type_o  (axi_tgu_packet_type[2:0]),
  .axi_tgu_size_o         (axi_tgu_size),
  .axi_tgu_payload_o      (axi_tgu_payload[STM_DATA_WIDTH-1:0]),
  .axi_tgu_ts_req_o       (axi_tgu_ts_req[1:0]),
  .axi_tgu_fready_o       (axi_tgu_fready),
  .axi_tgu_timestamped_i  (axi_tgu_timestamped),
  .axi_tgu_fvalid_i       (axi_tgu_fvalid),

  .axi_enable_i           (axi_enable),
  .axi_sper_i             (axi_sper[31:0]),
  .axi_spter_i            (axi_spter[31:0]),
  .axi_singleshot_i       (axi_singleshot),
  .axi_trigstatusspte_i   (axi_trigstatusspte),
  .axi_banksel_i          (axi_banksel[11:0]),
  .axi_portctl_i          (axi_portctl[1:0]),
  .axi_mastsel_i          (axi_mastsel[7:0]),
  .axi_mastctl_i          (axi_mastctl),
  .axi_overportsel_i      (axi_overportsel[16:0]),
  .axi_overts_i           (axi_overts),
  .axi_overportctl_i      (axi_overportctl[1:0]),
  .axi_overmastsel_i      (axi_overmastsel[7:0]),
  .axi_overmastctl_i      (axi_overmastctl),
  .axi_tsen_i             (axi_tsen),
  .axi_buf_clr_i          (axi_buf_clr),
  .axi_busy_o             (axi_busy),

  .triggerspte_o          (triggerspte),
  .triggersw_o            (triggersw),

  .dma_enable_i           (dma_enable),
  .dma_sens_i             (dma_sens[1:0]),
  .tgu_fifo_level_i       (tgu_fifo_level[1:0]),
  .tgu_fifo_full_i        (tgu_fifo_full),
  .dma_busy_o             (dma_busy),

  .dbgen_r_i              (dbgen_r),
  .niden_r_i              (niden_r),
  .spiden_r_i             (spiden_r),
  .spniden_r_i            (spniden_r),

  .nsguaren_r_i           (nsguaren_r),

  .itctl_i                (itctl),
  .ittrigger_we_i         (ittrigger_we),
  .pwdatadbg1_0_r_i       (pwdatadbg1_0_r),

  .AXIQREQn               (AXIQREQn),
  .AXIQACCEPTn            (AXIQACCEPTn),
  .AXIQDENY               (AXIQDENY),
  .AXIQACTIVE             (AXIQACTIVE),

  .AWAKEUP                (AWAKEUP),

  .qforcedeny_i           (qforcedeny)
  );

  //Disconnect HW Event Interface if not present
  generate
    if (HWEVOBIF_PRESENT) begin : gen_hw_intf
      assign hwevents_int = HWEVENTS;

      if (STM_DATA_WIDTH == 64)
        assign HEEXTMUX = hweventmux_int;

    end else begin : gen_no_hw_intf
      assign hwevents_int = {STM_DATA_WIDTH{1'b0}};
      assign HEEXTMUX = 8'h00;
    end
  endgenerate


  //----------------------------------------------------------------------------
  // Debug reset domain
  //----------------------------------------------------------------------------
  cxstm500_dbg_rst_domain #(
    .HWEVOBIF_PRESENT      (HWEVOBIF_PRESENT),
    .DATA_FIFO_DEPTH       (DATA_FIFO_DEPTH_EFF),
    .CHN_FIFO_DEPTH        (CHN_FIFO_DEPTH),
    .HWEVOBIF_CONFIG_63_32 (HWEVOBIF_CONFIG_63_32),
    .HWEVOBIF_CONFIG_31_0  (HWEVOBIF_CONFIG_31_0),
    .STM_DATA_WIDTH        (STM_DATA_WIDTH)
  )
  u_cxstm500_dbg_rst_domain
  (
  // TOP LEVEL INTERFACES
  .CLK                 (CLK),
  .STMRESETn           (STMRESETn),

  .PSELDBG             (PSELDBG),
  .PENABLEDBG          (PENABLEDBG),
  .PWRITEDBG           (PWRITEDBG),
  .PADDRDBG            (PADDRDBG[11:2]),
  .PADDRDBG31          (PADDRDBG31),
  .PWDATADBG           (PWDATADBG[31:0]),
  .PREADYDBG           (PREADYDBG),
  .PRDATADBG           (PRDATADBG[31:0]),
  .PSLVERRDBG          (PSLVERRDBG),

  .ATREADYM            (ATREADYM),
  .AFVALIDM            (AFVALIDM),
  .SYNCREQM            (SYNCREQM),
  .ATVALIDM            (ATVALIDM),
  .ATDATAM             (ATDATAM[STM_DATA_WIDTH-1:0]),
  .ATIDM               (ATIDM[6:0]),
  .AFREADYM            (AFREADYM),
  .ATBYTESM            (ATBYTESM[(STM_DATA_WIDTH/32):0]),

  .HWEVENTS            (hwevents_int),
  .HEEXTMUX            (hweventmux_int),

  .TSVALUE             (TSVALUE[63:0]),

  .DBGEN               (DBGEN),
  .NIDEN               (NIDEN),
  .SPIDEN              (SPIDEN),
  .SPNIDEN             (SPNIDEN),

  .NSGUAREN            (NSGUAREN),

  .TRIGOUTHETE         (TRIGOUTHETE),

  .ASYNCOUT            (ASYNCOUT),

  .DFTCLKCGEN          (DFTCLKCGEN),

  //SIGNALS CROSSING INTO AXI RESET DOMAIN
  .axi_tgu_valid_i       (axi_tgu_valid),
  .axi_tgu_master_i      (axi_tgu_master[7:0]),
  .axi_tgu_channel_i     (axi_tgu_channel[15:0]),
  .axi_tgu_packet_type_i (axi_tgu_packet_type[2:0]),
  .axi_tgu_size_i        (axi_tgu_size),
  .axi_tgu_payload_i     (axi_tgu_payload[STM_DATA_WIDTH-1:0]),
  .axi_tgu_ts_req_i      (axi_tgu_ts_req[1:0]),
  .axi_tgu_fready_i      (axi_tgu_fready),
  .axi_tgu_ready_o       (axi_tgu_ready),
  .axi_tgu_timestamped_o (axi_tgu_timestamped),
  .axi_tgu_fvalid_o      (axi_tgu_fvalid),

  .axi_busy_i            (axi_busy),
  .axi_enable_o          (axi_enable),
  .axi_sper_o            (axi_sper[31:0]),
  .axi_spter_o           (axi_spter[31:0]),
  .axi_singleshot_o      (axi_singleshot),
  .axi_trigstatusspte_o  (axi_trigstatusspte),
  .axi_banksel_o         (axi_banksel[11:0]),
  .axi_portctl_o         (axi_portctl[1:0]),
  .axi_mastsel_o         (axi_mastsel[7:0]),
  .axi_mastctl_o         (axi_mastctl),
  .axi_overportsel_o     (axi_overportsel[16:0]),
  .axi_overts_o          (axi_overts),
  .axi_overportctl_o     (axi_overportctl[1:0]),
  .axi_overmastsel_o     (axi_overmastsel[7:0]),
  .axi_overmastctl_o     (axi_overmastctl),
  .axi_tsen_o            (axi_tsen),
  .axi_buf_clr_o         (axi_buf_clr),

  .triggerspte_i         (triggerspte),
  .triggersw_i           (triggersw),

  .dma_busy_i            (dma_busy),
  .dma_enable_o          (dma_enable),
  .dma_sens_o            (dma_sens[1:0]),
  .tgu_fifo_level_o      (tgu_fifo_level[1:0]),
  .tgu_fifo_full_o       (tgu_fifo_full),

  .dbgen_r_o             (dbgen_r),
  .niden_r_o             (niden_r),
  .spiden_r_o            (spiden_r),
  .spniden_r_o           (spniden_r),
  .nsguaren_r_o          (nsguaren_r),

  .itctl_o               (itctl),
  .ittrigger_we_o        (ittrigger_we),
  .pwdatadbg1_0_r_o      (pwdatadbg1_0_r[1:0]),

  .STMQREQn              (STMQREQn),
  .STMQACCEPTn           (STMQACCEPTn),
  .STMQDENY              (STMQDENY),
  .STMQACTIVE            (STMQACTIVE),

  .PWAKEUP               (PWAKEUP),

  .qforcedeny_o          (qforcedeny)
  );


`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  integer data_fifo_depth_sig;
  assign data_fifo_depth_sig = DATA_FIFO_DEPTH;
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"Illegal DATA FIFO depth - only 4, 8, 16 or 32 allowed")
    ovl_never_illegal_data_fifo_depth (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (!((data_fifo_depth_sig ==  4) ||
                    (data_fifo_depth_sig ==  8) ||
                    (data_fifo_depth_sig == 16) ||
                    (data_fifo_depth_sig == 32)))
    );

  integer channel_fifo_depth_sig;
  assign channel_fifo_depth_sig = CHN_FIFO_DEPTH;
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"Illegal CHANNEL FIFO depth - only 4, 8, 16 or 32 allowed")
    ovl_never_illegal_channel_fifo_depth (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (!((channel_fifo_depth_sig ==  4) ||
                    (channel_fifo_depth_sig ==  8) ||
                    (channel_fifo_depth_sig == 16) ||
                    (channel_fifo_depth_sig == 32)))
    );

  assert_never #(`OVL_ERROR,`OVL_ASSERT,"DATA FIFO depth must be equal or larger then CHANNEL FIFO depth")
    ovl_never_data_fifo_greater_than_channel_fifo (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (data_fifo_depth_sig < channel_fifo_depth_sig)
    );

  assert_never #(`OVL_ERROR,`OVL_ASSERT,"STM_DATA_WIDTH must be 32 or 64 bits")
    ovl_never_illegal_stm_data_width (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (!((STM_DATA_WIDTH == 32) | (STM_DATA_WIDTH == 64)))
    );


`endif

endmodule // CXSTM500

