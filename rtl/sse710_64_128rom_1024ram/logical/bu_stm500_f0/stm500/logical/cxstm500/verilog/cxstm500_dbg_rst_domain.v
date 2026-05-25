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
//      Revision            : $Revision: 38886 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Wrapper for STM Debug reset domain.
//-----------------------------------------------------------------------------

module cxstm500_dbg_rst_domain
#(
  parameter        HWEVOBIF_PRESENT      = 1,             // HW Observation Interface present or not, 1 - present, 0 - not present
  parameter        DATA_FIFO_DEPTH       = 4,             // Depth of data FIFO. Valid values are 4, 8, 16, 32
  parameter        CHN_FIFO_DEPTH        = 4,             // Depth of channel FIFO. Valid Values are 4, 8, 16, 32
  parameter [31:0] HWEVOBIF_CONFIG_63_32 = 32'h0000_0000, // Edge/Level based HW Event detection (0 = Edge based, 1 = Level for interfaces HW63:HW32
  parameter [31:0] HWEVOBIF_CONFIG_31_0  = 32'h0000_0000, // Edge/Level based HW Event detection (0 = Edge based, 1 = Level for interfaces HW31:HW0
  parameter        STM_DATA_WIDTH        = 64             // Width of STM data path
)
(
  // TOP LEVEL INTERFACES
  // Clock and Reset
  input  wire                          CLK,                   // Clock
  input  wire                          STMRESETn,             // Reset

  // Debug APB Slave Interface
  input  wire                          PSELDBG,               // APB slave select
  input  wire                          PENABLEDBG,            // APB enable
  input  wire                          PWRITEDBG,             // APB write
  input  wire                          PADDRDBG31,            // APB internal vs external access select
  input  wire [11:2]                   PADDRDBG,              // APB address
  input  wire [31:0]                   PWDATADBG,             // APB write data
  output wire                          PREADYDBG,             // APB ready
  output wire                          PSLVERRDBG,            // APB slave error
  output wire [31:0]                   PRDATADBG,             // APB read data

  // ATB Master Interface
  input  wire                          ATREADYM,              // ATB ready
  input  wire                          AFVALIDM,              // ATB flush valid
  input  wire                          SYNCREQM,               // ATB synchronization request
  output wire                          ATVALIDM,              // ATB valid
  output wire [(STM_DATA_WIDTH/32):0]  ATBYTESM,              // ATB bytes

  output wire [STM_DATA_WIDTH-1:0]     ATDATAM,               // ATB data
  output wire [6:0]                    ATIDM,                 // ATB ID
  output wire                          AFREADYM,              // ATB flush ready

  // Hardware Event Observation Port
  input wire [STM_DATA_WIDTH-1:0]      HWEVENTS,              // Hardware Events
  output wire [7:0]                    HEEXTMUX,              // Hardware Event External Mux Select

  // Timestamp Port
  input wire [63:0]                    TSVALUE,               // Timestamp value

  // Authentication Interface
  input wire                           DBGEN,                 // Invasive debug enable
  input wire                           NIDEN,                 // Non-invasive debug enable
  input wire                           SPIDEN,                // Secure invasive debug enable
  input wire                           SPNIDEN,               // Secure non-invasive debug enable

  // Non-secure AXI access control
  input wire                           NSGUAREN,              // Enable non-secure guaranteed stimulus port accesses

  // Cross-Triggering Interface
  output wire                          TRIGOUTHETE,           // Trigger output event, matches using STMHETER
  output wire                          ASYNCOUT,              // Async sequence has been output event

  // Test Interface
  input wire                           DFTCLKCGEN,            // Force STM clock gates on in test mode

  // SIGNALS CROSSING INTO AXI RESET DOMAIN
  // AXI front end
  // TGU data Interface
  input  wire                          axi_tgu_valid_i,       // TGU Transfer Valid
  input  wire [7:0]                    axi_tgu_master_i,      // Master Number
  input  wire [15:0]                   axi_tgu_channel_i,     // STPv2 Channel Number
  input  wire [2:0]                    axi_tgu_packet_type_i, // STPv2 Packet Type
  input  wire [(STM_DATA_WIDTH/32):0]  axi_tgu_size_i,        // Payload Size
  input  wire [STM_DATA_WIDTH-1:0]     axi_tgu_payload_i,     // Payload
  input  wire [1:0]                    axi_tgu_ts_req_i,      // Timestamp Qualifier
  input  wire                          axi_tgu_fready_i,      // Data flush completed
  output wire                          axi_tgu_ready_o,       // TGU Transfer Ready
  output wire                          axi_tgu_timestamped_o, // Timestamp Indicator
  output wire                          axi_tgu_fvalid_o,      // Data flush request

  // Configuration and Status Interface
  input  wire                          axi_busy_i,            // Busy Status
  output wire                          axi_enable_o,          // STM Enable
  output wire [31:0]                   axi_sper_o,            // SPER value
  output wire [31:0]                   axi_spter_o,           // SPTER value
  output wire                          axi_singleshot_o,      // SPTE singleshot mode
  output wire                          axi_trigstatusspte_o,  // SPTE trigger status in singleshot mode
  output wire [11:0]                   axi_banksel_o,         // STMSPSCR.PORTSEL
  output wire [1:0]                    axi_portctl_o,         // STMSPSCR.PORTCTL
  output wire [7:0]                    axi_mastsel_o,         // STMSPMSCR.MASTSEL
  output wire                          axi_mastctl_o,         // STMSPMSCR.MASTCTL
  output wire [16:0]                   axi_overportsel_o,     // STMSPOVERRIDER.PORTSEL
  output wire                          axi_overts_o,          // Timestamp Override
  output wire [1:0]                    axi_overportctl_o,     // STMSPOVERRIDER.OVERCTL
  output wire [7:0]                    axi_overmastsel_o,     // STMSPMOVERRIDER.MASTSEL
  output wire                          axi_overmastctl_o,     // STMSPMOVERRIDER.MASTCTL
  output wire                          axi_tsen_o,            // Timestamping Enable
  output wire                          axi_buf_clr_o,         // AXI Buffer Clear

  // Trigger Interface
  input wire                           triggerspte_i,         // Trigger, matches using STMSPTER
  input wire                           triggersw_i,           // Trigger, writes to TRIG location

  // DMA front end
  // DMA control interface
  input  wire                          dma_busy_i,            // dma busy
  output wire                          dma_enable_o,          // dma request generation enable
  output wire [1:0]                    dma_sens_o,            // dma fifo sensitivity
  output wire [1:0]                    tgu_fifo_level_o,      // dma fifo sensitivity
  output wire                          tgu_fifo_full_o,       // TGU fifo full

  // Authentication Interface
  output wire                          dbgen_r_o,             // Invasive debug enable
  output wire                          niden_r_o,             // Non-invasive debug enable
  output wire                          spiden_r_o,            // Secure invasive debug enable
  output wire                          spniden_r_o,           // Secure non-invasive debug enable
  output wire                          nsguaren_r_o,          // Enable non-secure guaranteed stimulus port accesses

  // Integartion testing interface
  output wire                          itctl_o,               // integration mode
  output wire                          ittrigger_we_o,        // write to ITTRIGGER register
  output wire [1:0]                    pwdatadbg1_0_r_o,      // APB data 1:0

  // Q-Channel Interface
  input  wire                          STMQREQn,              //Quiscence Request

  output wire                          STMQACCEPTn,           //Quiscence Request Acknowledge
  output wire                          STMQDENY,              //Quiscence Request Deny
  output wire                          STMQACTIVE,            //STM Active

  input  wire                          PWAKEUP,               //APB Active Signal

  output wire                          qforcedeny_o           // Force Deny Override
  );

  // --------------------------------------------------------------------------
  // Global Nets
  // --------------------------------------------------------------------------
  wire                         clk_gated;
  wire                         apb_clk_req;
  wire                         stm_clk_req;
  wire                         reg_write_en;
  wire [11:2]                  paddrdbg_r;
  wire                         paddrdbg31_r;
  wire [31:0]                  pwdatadbg_r;
  wire                         hw_busy;
  wire                         tgu_busy;
  wire                         axi_forcets_ack;
  wire [31:0]                  read_data;
  wire                         axi_forcets;
  wire                         hw_enable;
  wire [STM_DATA_WIDTH-1:0]    hw_heer;
  wire [STM_DATA_WIDTH-1:0]    hw_heter;
  wire                         hw_singleshot;
  wire                         hw_trigstatushete;
  wire                         hw_errdetect;
  wire                         arb_atbtrigenspte;
  wire                         arb_atbtrigensw;
  wire                         arb_atbtrigenhete;
  wire                         arb_flushprinvdis;
  wire                         tgu_cfg_enable;
  wire [6:0]                   tgu_cfg_traceid;
  wire                         tgu_cfg_tsen;
  wire [31:0]                  tgu_cfg_tsfreqr;
  wire                         tgu_cfg_spcompen;
  wire                         tgu_cfg_hwcompen;
  wire                         tgu_cfg_asyncpe;
  wire                         tgu_cfg_fifoaf;
  wire                         tgu_cfg_freadyhigh;
  wire                         atvalidm_int;
  wire                         hw_tgu_valid;
  wire [7:0]                   hw_tgu_master;
  wire [15:0]                  hw_tgu_channel;
  wire [2:0]                   hw_tgu_packet_type;
  wire [(STM_DATA_WIDTH/32):0] hw_tgu_size;
  wire [STM_DATA_WIDTH-1:0]    hw_tgu_payload;
  wire [1:0]                   hw_tgu_ts_req;
  wire                         hw_tgu_ready;
  wire                         hw_tgu_fready;
  wire                         hw_tgu_fvalid;
  wire                         tgu_valid;
  wire [7:0]                   tgu_master;
  wire [15:0]                  tgu_channel;
  wire [2:0]                   tgu_packet_type;
  wire [(STM_DATA_WIDTH/32):0] tgu_size;
  wire [STM_DATA_WIDTH-1:0]    tgu_payload;
  wire [1:0]                   tgu_ts_req;
  wire                         tgu_ready;
  wire                         tgu_timestamped;
  wire                         tgu_fready;
  wire                         tgu_fvalid;
  wire                         asyncout_int;
  wire                         syncreq_int;
  wire                         stm_enable_syncreq;
  wire                         arb_trace_trigger;
  wire                         triggerhete;
  wire                         itctl;
  wire                         ittrigger_we;
  wire                         itatbdata0_we;
  wire                         itatbid_we;
  wire                         itatbctr0_we;
  wire                         dbgen_r;
  wire                         niden_r;
  wire                         spiden_r;
  wire                         spniden_r;
  wire                         nsguaren_r;
  wire                         auth_flush;
  wire [63:0]                  tsvalue_r;
  wire                         q_stopped;
  wire                         q_stop;
  wire                         q_flush;
  wire                         stmqaccept_n;
  wire                         qhwevoverride;
  wire                         qforcedeny;

  reg  [3:0]                   revand_reg;

  // --------------------------------------------------------------------------
  // Clock generation
  // --------------------------------------------------------------------------
  cxstm500_clk_module u_cxstm500_clk_module (
  .CLK            (CLK),
  .apb_clk_req_i  (apb_clk_req),
  .stm_clk_req_i  (stm_clk_req),
  .DFTCLKCGEN     (DFTCLKCGEN),
  .clk_gated      (clk_gated)
  );

  // --------------------------------------------------------------------------
  // Front End Interface
  // --------------------------------------------------------------------------
  generate
  if (HWEVOBIF_PRESENT == 1)
  begin : gen_hw_front_end
  // Hardware Event Observation Interfaces
  cxstm500_hweventif #(
    .HWEVOBIF_CONFIG_63_32 (HWEVOBIF_CONFIG_63_32),
    .HWEVOBIF_CONFIG_31_0  (HWEVOBIF_CONFIG_31_0),
    .STM_DATA_WIDTH        (STM_DATA_WIDTH)
  ) u_cxstm500_hweventif (
    .clk_gated            (clk_gated),
    .STMRESETn            (STMRESETn),
    .HWEVENTS             (HWEVENTS),
    .tgu_ready_i          (hw_tgu_ready),
    .tgu_fvalid_i         (hw_tgu_fvalid),
    .tgu_valid_o          (hw_tgu_valid),
    .tgu_master_o         (hw_tgu_master[7:0]),
    .tgu_channel_o        (hw_tgu_channel[15:0]),
    .tgu_packet_type_o    (hw_tgu_packet_type[2:0]),
    .tgu_size_o           (hw_tgu_size),
    .tgu_payload_o        (hw_tgu_payload[STM_DATA_WIDTH-1:0]),
    .tgu_ts_req_o         (hw_tgu_ts_req[1:0]),
    .tgu_fready_o         (hw_tgu_fready),
    .hw_enable_i          (hw_enable),
    .hw_tsen_i            (tgu_cfg_tsen),
    .hw_heer_i            (hw_heer[STM_DATA_WIDTH-1:0]),
    .hw_heter_i           (hw_heter[STM_DATA_WIDTH-1:0]),
    .hw_singleshot_i      (hw_singleshot),
    .hw_trigstatushete_i  (hw_trigstatushete),
    .hw_errdetect_i       (hw_errdetect),
    .hw_busy_o            (hw_busy),
    .triggerhete_o        (triggerhete),
    .TRIGOUTHETE          (TRIGOUTHETE),
    .dbgen_r_i            (dbgen_r),
    .niden_r_i            (niden_r),
    .itctl_i              (itctl),
    .ittrigger_we_i       (ittrigger_we),
    .pwdatadbg2_r_i       (pwdatadbg_r[2])
  );
  end
  else
  begin : gen_no_hw_front_end
    assign hw_tgu_valid            = 1'b0;
    assign hw_tgu_master[7:0]      = {8{1'b0}};
    assign hw_tgu_channel[15:0]    = {16{1'b0}};
    assign hw_tgu_packet_type[2:0] = {3{1'b0}};

    if(STM_DATA_WIDTH == 64)
      assign hw_tgu_size[(STM_DATA_WIDTH/32):0] = {3{1'b0}};


    assign hw_tgu_payload[STM_DATA_WIDTH-1:0] = {STM_DATA_WIDTH{1'b0}};
    assign hw_tgu_ts_req[1:0]                 = {2{1'b0}};
    assign hw_tgu_fready                      = 1'b0;
    assign triggerhete                        = 1'b0;
    assign hw_busy                            = 1'b0;
    assign TRIGOUTHETE                        = 1'b0;
  end
  endgenerate

  // Arbiter
  cxstm500_arbiter  #(
    .HWEVOBIF_PRESENT          (HWEVOBIF_PRESENT),
    .STM_DATA_WIDTH            (STM_DATA_WIDTH)
  ) u_cxstm500_arbiter (
    .clk_gated                 (clk_gated),
    .STMRESETn                 (STMRESETn),
    .axi_tgu_valid_i           (axi_tgu_valid_i),
    .axi_tgu_master_i          (axi_tgu_master_i[7:0]),
    .axi_tgu_channel_i         (axi_tgu_channel_i[15:0]),
    .axi_tgu_packet_type_i     (axi_tgu_packet_type_i[2:0]),
    .axi_tgu_size_i            (axi_tgu_size_i),
    .axi_tgu_payload_i         (axi_tgu_payload_i[STM_DATA_WIDTH-1:0]),
    .axi_tgu_ts_req_i          (axi_tgu_ts_req_i[1:0]),
    .axi_tgu_fready_i          (axi_tgu_fready_i),
    .axi_tgu_ready_o           (axi_tgu_ready_o),
    .axi_tgu_timestamped_o     (axi_tgu_timestamped_o),
    .axi_tgu_fvalid_o          (axi_tgu_fvalid_o),
    .axi_force_ts_req_i        (axi_forcets),
    .axi_force_ts_ack_o        (axi_forcets_ack),
    .hw_tgu_valid_i            (hw_tgu_valid),
    .hw_tgu_master_i           (hw_tgu_master[7:0]),
    .hw_tgu_channel_i          (hw_tgu_channel[15:0]),
    .hw_tgu_packet_type_i      (hw_tgu_packet_type[2:0]),
    .hw_tgu_size_i             (hw_tgu_size),
    .hw_tgu_payload_i          (hw_tgu_payload[STM_DATA_WIDTH-1:0]),
    .hw_tgu_ts_req_i           (hw_tgu_ts_req[1:0]),
    .hw_tgu_fready_i           (hw_tgu_fready),
    .hw_tgu_ready_o            (hw_tgu_ready),
    .hw_tgu_fvalid_o           (hw_tgu_fvalid),
    .tgu_valid_o               (tgu_valid),
    .tgu_master_o              (tgu_master[7:0]),
    .tgu_channel_o             (tgu_channel[15:0]),
    .tgu_packet_type_o         (tgu_packet_type[2:0]),
    .tgu_size_o                (tgu_size),
    .tgu_payload_o             (tgu_payload[STM_DATA_WIDTH-1:0]),
    .tgu_ts_req_o              (tgu_ts_req[1:0]),
    .tgu_fready_o              (tgu_fready),
    .tgu_timestamped_i         (tgu_timestamped),
    .tgu_ready_i               (tgu_ready),
    .tgu_fvalid_i              (tgu_fvalid),
    .triggerspte_i             (triggerspte_i),
    .triggersw_i               (triggersw_i),
    .triggerhete_i             (triggerhete),
    .arb_atbtrigenspte_i       (arb_atbtrigenspte),
    .arb_atbtrigensw_i         (arb_atbtrigensw),
    .arb_atbtrigenhete_i       (arb_atbtrigenhete),
    .arb_flushprinvdis_i       (arb_flushprinvdis),
    .tgu_trace_trigger_o       (arb_trace_trigger)
  );

  // --------------------------------------------------------------------------
  // Configuration
  // --------------------------------------------------------------------------

  // APB Slave Interface
  cxstm500_apbslvif u_cxstm500_apbslvif (
    .CLK                 (CLK),
    .STMRESETn           (STMRESETn),
    .PSELDBG             (PSELDBG),
    .PENABLEDBG          (PENABLEDBG),
    .PWRITEDBG           (PWRITEDBG),
    .PADDRDBG            (PADDRDBG[11:2]),
    .PADDRDBG31          (PADDRDBG31),
    .PWDATADBG           (PWDATADBG[31:0]),
    .read_data_i         (read_data[31:0]),
    .apb_clk_req_o       (apb_clk_req),
    .PREADYDBG           (PREADYDBG),
    .PRDATADBG           (PRDATADBG[31:0]),
    .paddrdbg_r_o        (paddrdbg_r[11:2]),
    .paddrdbg31_r_o      (paddrdbg31_r),
    .pwdatadbg_r_o       (pwdatadbg_r[31:0]),
    .reg_write_en_o      (reg_write_en),
    .DBGEN               (DBGEN),
    .NIDEN               (NIDEN),
    .SPIDEN              (SPIDEN),
    .SPNIDEN             (SPNIDEN),
    .NSGUAREN            (NSGUAREN),
    .dbgen_r_o           (dbgen_r),
    .niden_r_o           (niden_r),
    .spiden_r_o          (spiden_r),
    .spniden_r_o         (spniden_r),
    .nsguaren_r_o        (nsguaren_r),
    .auth_flush_o        (auth_flush),
    .q_stopped_i         (q_stopped),
    .q_stop_i            (q_stop)
  );

  // Register file

  // The Rev-And data (bits 7:4) are driven from a register so that it
  // can be easily changed in the netlist. Write enable based off
  // axi_buf_clr_o which is high for STMRESETn and low during normal
  // operation

  localparam STMPID3_REVAND = 4'h0; // Peripheral ID3 REVAND value

  always @(posedge CLK)
    begin
    if (axi_buf_clr_o)
      revand_reg[3:0] <= STMPID3_REVAND[3:0];
    end

  cxstm500_regfile  #(
    .HWEVOBIF_PRESENT     (HWEVOBIF_PRESENT),
    .STM_DATA_WIDTH       (STM_DATA_WIDTH)
  )
  u_cxstm500_regfile (
    .clk_gated            (clk_gated),
    .STMRESETn            (STMRESETn),
    .PSELDBG              (PSELDBG),
    .paddrdbg31_r_i       (paddrdbg31_r),
    .paddrdbg_r_i         (paddrdbg_r[11:2]),
    .pwdatadbg_r_i        (pwdatadbg_r[31:0]),
    .atvalidm_i           (atvalidm_int),
    .ATREADYM             (ATREADYM),
    .SYNCREQM             (SYNCREQM),
    .AFVALIDM             (AFVALIDM),
    .dbgen_r_i            (dbgen_r),
    .niden_r_i            (niden_r),
    .spiden_r_i           (spiden_r),
    .spniden_r_i          (spniden_r),
    .reg_write_en_i       (reg_write_en),
    .axi_busy_i           (axi_busy_i),
    .hw_busy_i            (hw_busy),
    .dma_busy_i           (dma_busy_i),
    .tgu_busy_i           (tgu_busy),
    .forcets_ack_i        (axi_forcets_ack),
    .triggerspte_i        (triggerspte_i),
    .triggerhete_i        (triggerhete),
    .tgu_cfg_sync_ack_i   (asyncout_int),
    .revand_i             (revand_reg),
    .TSVALUE              (TSVALUE[63:0]),
    .stm_clk_req_o        (stm_clk_req),
    .read_data_o          (read_data[31:0]),
    .axi_enable_o         (axi_enable_o),
    .axi_sper_o           (axi_sper_o[31:0]),
    .axi_spter_o          (axi_spter_o[31:0]),
    .axi_singleshot_o     (axi_singleshot_o),
    .axi_trigstatusspte_o (axi_trigstatusspte_o),
    .axi_banksel_o        (axi_banksel_o[11:0]),
    .axi_portctl_o        (axi_portctl_o[1:0]),
    .axi_mastsel_o        (axi_mastsel_o[7:0]),
    .axi_mastctl_o        (axi_mastctl_o),
    .axi_overportsel_o    (axi_overportsel_o[16:0]),
    .axi_overts_o         (axi_overts_o),
    .axi_overportctl_o    (axi_overportctl_o[1:0]),
    .axi_overmastsel_o    (axi_overmastsel_o[7:0]),
    .axi_overmastctl_o    (axi_overmastctl_o),
    .axi_forcets_o        (axi_forcets),
    .axi_buf_clr_o        (axi_buf_clr_o),
    .hw_enable_o          (hw_enable),
    .hw_heer_o            (hw_heer[STM_DATA_WIDTH-1:0]),
    .hw_heter_o           (hw_heter[STM_DATA_WIDTH-1:0]),
    .hw_heextmux_o        (HEEXTMUX[7:0]),
    .hw_singleshot_o      (hw_singleshot),
    .hw_trigstatushete_o  (hw_trigstatushete),
    .hw_errdetect_o       (hw_errdetect),
    .dma_enable_o         (dma_enable_o),
    .dma_sens_o           (dma_sens_o[1:0]),
    .arb_atbtrigenspte_o  (arb_atbtrigenspte),
    .arb_atbtrigensw_o    (arb_atbtrigensw),
    .arb_atbtrigenhete_o  (arb_atbtrigenhete),
    .arb_flushprinvdis_o  (arb_flushprinvdis),
    .tgu_cfg_enable_o     (tgu_cfg_enable),
    .tgu_cfg_traceid_o    (tgu_cfg_traceid[6:0]),
    .tgu_cfg_tsen_o       (tgu_cfg_tsen),
    .tgu_cfg_tsfreqr_o    (tgu_cfg_tsfreqr[31:0]),
    .tgu_cfg_spcompen_o   (tgu_cfg_spcompen),
    .tgu_cfg_hwcompen_o   (tgu_cfg_hwcompen),
    .tgu_cfg_asyncpe_o    (tgu_cfg_asyncpe),
    .tgu_cfg_fifoaf_o     (tgu_cfg_fifoaf),
    .tgu_cfg_freadyhigh_o (tgu_cfg_freadyhigh),
    .syncreq_o            (syncreq_int),
    .stm_enable_syncreq_o (stm_enable_syncreq),
    .tsvalue_o            (tsvalue_r[63:0]),
    .itctl_o              (itctl),
    .ittrigger_we_o       (ittrigger_we),
    .itatbdata0_we_o      (itatbdata0_we),
    .itatbid_we_o         (itatbid_we),
    .itatbctr0_we_o       (itatbctr0_we),
    .q_stopped_i          (q_stopped),
    .qhwevoverride_o      (qhwevoverride),
    .qforcedeny_o         (qforcedeny)
  );

  // --------------------------------------------------------------------------
  // Trace Generation Unit
  // --------------------------------------------------------------------------
  cxstm500_tgu #(
    .DATA_FIFO_DEPTH      (DATA_FIFO_DEPTH),
    .CHN_FIFO_DEPTH       (CHN_FIFO_DEPTH),
    .STM_DATA_WIDTH       (STM_DATA_WIDTH)
  )
  u_cxstm500_tgu (
    .clk_gated            (clk_gated),
    .STMRESETn            (STMRESETn),
    // TGU data interface
    .tgu_valid_i          (tgu_valid),
    .tgu_master_i         (tgu_master[7:0]),
    .tgu_channel_i        (tgu_channel[15:0]),
    .tgu_packet_type_i    (tgu_packet_type[2:0]),
    .tgu_size_i           (tgu_size[(STM_DATA_WIDTH/32):0]),
    .tgu_payload_i        (tgu_payload[STM_DATA_WIDTH-1:0]),
    .tgu_ts_req_i         (tgu_ts_req[1:0]),
    .tgu_fready_i         (tgu_fready),

    .tgu_ready_o          (tgu_ready),
    .tgu_timestamped_o    (tgu_timestamped),
    .tgu_fvalid_o         (tgu_fvalid),

    // Timestamp
    .tsvalue_i            (tsvalue_r[63:0]),

    // TGU configuration and status interface
    .tgu_cfg_enable_i     (tgu_cfg_enable),
    .tgu_cfg_traceid_i    (tgu_cfg_traceid[6:0]),
    .tgu_cfg_tsen_i       (tgu_cfg_tsen),
    .tgu_cfg_tsfreqr_i    (tgu_cfg_tsfreqr[31:0]),
    .tgu_cfg_spcompen_i   (tgu_cfg_spcompen),
    .tgu_cfg_hwcompen_i   (tgu_cfg_hwcompen),
    .tgu_cfg_asyncpe_i    (tgu_cfg_asyncpe),
    .tgu_cfg_fifoaf_i     (tgu_cfg_fifoaf),
    .tgu_cfg_freadyhigh_i (tgu_cfg_freadyhigh),
    .tgu_flush_i          (auth_flush),
    .tgu_busy_o           (tgu_busy),
    .tgu_fifo_level_o     (tgu_fifo_level_o[1:0]),
    .tgu_fifo_full_o      (tgu_fifo_full_o),

    // Trigger interface
    .tgu_trace_trigger_i  (arb_trace_trigger),

    // ATB interface
    .ATREADYM             (ATREADYM),
    .AFVALIDM             (AFVALIDM),
    .syncreq_i            (syncreq_int),
    .stm_enable_syncreq_i (stm_enable_syncreq),
    .atvalid_o            (atvalidm_int),
    .ATBYTESM             (ATBYTESM[(STM_DATA_WIDTH/32):0]),
    .ATDATAM              (ATDATAM[STM_DATA_WIDTH-1:0]),
    .ATIDM                (ATIDM[6:0]),
    .AFREADYM             (AFREADYM),

    // Cross-trigger
    .asyncout_o           (asyncout_int),

    // Integration testing
    .itctl_i              (itctl),
    .ittrigger_we_i       (ittrigger_we),
    .itatbdata0_we_i      (itatbdata0_we),
    .itatbid_we_i         (itatbid_we),
    .itatbctr0_we_i       (itatbctr0_we),
    .pwdatadbg10_0_r_i    (pwdatadbg_r[10:0]),

    //Q-Channel
    .q_stop_i             (q_stop),
    .q_stopped_i          (q_stopped),
    .q_flush_i            (q_flush),

    //Test Interface
    .DFTCLKCGEN           (DFTCLKCGEN)
  );

  // --------------------------------------------------------------------------
  // Q-Channel Low Power Interface
  // --------------------------------------------------------------------------

  cxstm500_stm_qchanif u_cxstm500_stm_qchanif (
    .CLK                 (CLK),
    .STMRESETn           (STMRESETn),

    .STMQREQn            (STMQREQn),
    .STMQACCEPTn         (stmqaccept_n),
    .STMQDENY            (STMQDENY),
    .STMQACTIVE          (STMQACTIVE),

    .PWAKEUP             (PWAKEUP),

    .apb_busy_i          (PSELDBG),
    .hw_busy_i           (hw_busy),
    .tgu_busy_i          (tgu_busy),
    .AFVALIDM            (AFVALIDM),
    .hw_enable_i         (hw_enable),
    .qhwevoverride_i     (qhwevoverride),
    .qforcedeny_i        (qforcedeny),
    .itctl_i             (itctl),

    .q_stopped_o         (q_stopped),
    .q_stop_o            (q_stop),
    .q_flush_o           (q_flush)

  );

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // Top level outputs
  assign ATVALIDM          = atvalidm_int;
  assign PSLVERRDBG        = 1'b0;
  assign ASYNCOUT          = asyncout_int;
  assign STMQACCEPTn       = stmqaccept_n;

  // Outputs crossing to AXI reset domain
  assign  dbgen_r_o        = dbgen_r;
  assign  niden_r_o        = niden_r;
  assign  spiden_r_o       = spiden_r;
  assign  spniden_r_o      = spniden_r;
  assign  nsguaren_r_o     = nsguaren_r;
  assign  itctl_o          = itctl;
  assign  ittrigger_we_o   = ittrigger_we;
  assign  axi_tsen_o       = tgu_cfg_tsen;
  assign  pwdatadbg1_0_r_o = pwdatadbg_r[1:0];

  assign  qforcedeny_o     = qforcedeny;



`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
  // This assertion is not applicable in integration mode.
  assert_next #(`OVL_ERROR,1,1,0,`OVL_ASSERT,"tgu_busy should not be re-asserted after STM is disabled and all frontends are idle")
    ovl_next_dbg_rst_tgu_busy_not_reasserted_after_stm_disabled (
      .clk         (CLK),
      .reset_n     (STMRESETn),
      .start_event (~itctl & ~tgu_cfg_enable & ~axi_busy_i & ~dma_busy_i & ~hw_busy & ~tgu_busy),
      .test_expr   (~(tgu_busy & ~tgu_cfg_enable))
    );

  // This assertion is not applicable in integration mode.
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"STM must not output spurious ATB transfers when disabled")
    ovl_never_dbg_rst_stm_output_when_disabled (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (~itctl & u_cxstm500_regfile.en_reg & ~u_cxstm500_regfile.busy_reg & atvalidm_int)
    );

  // Ensure PREADYDBG is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"PREADYDBG must be low during Q_STOPPED state")
    ovl_never_dbg_rst_preadydbg_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & PREADYDBG)
    );

  // Ensure ATVALID is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"ATVALID must be low during Q_STOPPED state")
    ovl_never_dbg_rst_atvalid_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & ATVALIDM)
    );

  // Ensure AFREADY is high during Q_STOPPED
  // NOTE: This OVL refers to QACCEPTn rather than the internal Q_STOPPED signal
  // to allow time for the afready to be registered to AFREADYM (STMQACCEPTn will
  // occur 1 cycle later than the internal transition into Q_STOPPED to accomodate
  // registered outputs)
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"AFREADYM must be high during Q_STOPPED state")
    ovl_never_dbg_rst_afready_high (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (~stmqaccept_n & ~AFREADYM)
    );

  // Ensure ASYNCOUT is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"ASYNCOUT must be low during Q_STOPPED state")
    ovl_never_dbg_rst_asyncout_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & ASYNCOUT)
    );

  // Ensure axi_tgu_ready_o is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"axi_tgu_ready_o must be low during Q_STOPPED state")
    ovl_never_dbg_rst_axi_tgu_ready_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & axi_tgu_ready_o)
    );

  // Ensure axi_tgu_fvalid_o is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"axi_tgu_fvalid_o must be low during Q_STOPPED state")
    ovl_never_dbg_rst_axi_tgu_fvalid_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & axi_tgu_fvalid_o)
    );

  // Ensure axi_tgu_ready_o is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"hw_tgu_ready must be low during Q_STOPPED state")
    ovl_never_dbg_rst_hw_tgu_ready_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & hw_tgu_ready)
    );

  // Ensure axi_tgu_fvalid_o is low during Q_STOPPED
  assert_never #(`OVL_ERROR,`OVL_ASSERT,"hw_tgu_fvalid must be low during Q_STOPPED state")
    ovl_never_dbg_rst_hw_tgu_fvalid_low (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .test_expr (q_stopped & hw_tgu_fvalid)
    );

`endif
endmodule  // cxstm500_dbg_rst_domain
