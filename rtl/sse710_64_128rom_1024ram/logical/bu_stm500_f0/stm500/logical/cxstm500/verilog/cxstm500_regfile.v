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
//      Revision            : $Revision: 38886 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      CXSTM500 registers
//-----------------------------------------------------------------------------

module cxstm500_regfile #(
  parameter          HWEVOBIF_PRESENT = 1, // HW Event IF presence
  parameter          STM_DATA_WIDTH = 64   // STM Datapath width
  )
  (
  // Inputs
  input wire         clk_gated,            // gated clock
  input wire         STMRESETn,            // asynchronous reset
  input wire         PSELDBG,              // APB PSEL
  input wire         paddrdbg31_r_i,       // APB internal vs external access select, registered
  input wire  [11:2] paddrdbg_r_i,         // APB address, registered
  input wire  [31:0] pwdatadbg_r_i,        // APB write data, registered
  input wire         atvalidm_i,           // ATB valid
  input wire         ATREADYM,             // ATB ready
  input wire         SYNCREQM,             // ATB SYNCREQ (external syncreq)
  input wire         AFVALIDM,             // ATB flush valid
  input wire         dbgen_r_i,            // Invasive debug enable
  input wire         niden_r_i,            // Non-invasive debug enable
  input wire         spiden_r_i,           // Secure invasive debug enable
  input wire         spniden_r_i,          // Secure non-invasive debug enable
  input wire         reg_write_en_i,       // write enable from APB i/f
  input wire         axi_busy_i,           // AXI front end busy
  input wire         hw_busy_i,            // HW front end busy
  input wire         dma_busy_i,           // DMA request busy
  input wire         tgu_busy_i,           // TGU busy
  input wire         forcets_ack_i,        // force timestamp acknowledge
  input wire         triggerspte_i,        // SPTE trigger
  input wire         triggerhete_i,        // HETE trigger
  input wire         tgu_cfg_sync_ack_i,   // sync sequence output acknowledge
  input wire   [3:0] revand_i,             // REVAND bits

  // Timestamp
  input wire  [63:0] TSVALUE,              // Timestamp value

  // Outputs
  // clock generation
  output wire        stm_clk_req_o,        // clock request

  // APB interface
  output wire [31:0] read_data_o,          // read data for APB i/f

  // AXI control interface
  output wire        axi_enable_o,         // AXI front end enable
  output wire [31:0] axi_sper_o,           // stimulus port enable
  output wire [31:0] axi_spter_o,          // stimulus port trigger enable
  output wire        axi_singleshot_o,     // SPTE singleshot mode
  output wire        axi_trigstatusspte_o, // SPTE trigger status in singleshot mode
  output wire [11:0] axi_banksel_o,        // stimulus port bank (port group) sel
  output wire [1:0]  axi_portctl_o,        // stimulus port bank control
  output wire [7:0]  axi_mastsel_o,        // stimulus port master (port group) sel
  output wire        axi_mastctl_o,        // stimulus port master control
  output wire [16:0] axi_overportsel_o,    // stimulus port override port select
  output wire        axi_overts_o,         // overide timestamp
  output wire [1:0]  axi_overportctl_o,    // stimulus port override port control
  output wire [7:0]  axi_overmastsel_o,    // master override port select
  output wire        axi_overmastctl_o,    // master override port control
  output wire        axi_forcets_o,        // force timestamp request
  output wire        axi_buf_clr_o,        // AXI Buffer Clear

  // HW control interface
  output wire                      hw_enable_o,          // HW front end enable
  output wire [STM_DATA_WIDTH-1:0] hw_heer_o,            // HW Event enable
  output wire [STM_DATA_WIDTH-1:0] hw_heter_o,           // hw trigger enable
  output wire [7:0]                hw_heextmux_o,        // HW Event External Mux
  output wire                      hw_singleshot_o,      // HETE singleshot mode
  output wire                      hw_trigstatushete_o,  // HETE trigger status in singleshot mode
  output wire                      hw_errdetect_o,       // hw error detection enable

  // DMA control interface
  output wire        dma_enable_o,         // dma request generation enable
  output wire [1:0]  dma_sens_o,           // dma fifo sensitivity

  // Arbiter control interface
  output wire        arb_atbtrigenspte_o,  // enable ATB tigger generation from SPTE(ATID=0x7D)
  output wire        arb_atbtrigensw_o,    // enable ATB tigger generation from SW(ATID=0x7D)
  output wire        arb_atbtrigenhete_o,  // enable ATB tigger generation from HETE(ATID=0x7D)
  output wire        arb_flushprinvdis_o,  // disable priority inversion between AXI/HW after AXI is flushed

  // TGU control interface
  output wire        tgu_cfg_enable_o,     // TGU enable
  output wire [6:0]  tgu_cfg_traceid_o,    // ATB ID
  output wire        tgu_cfg_tsen_o,       // timestamp enable
  output wire [31:0] tgu_cfg_tsfreqr_o,    // timestamp frequency
  output wire        tgu_cfg_spcompen_o,   // compresion enable for AXI stimulus
  output wire        tgu_cfg_hwcompen_o,   // compresion enable for HW stimulus
  output wire        tgu_cfg_asyncpe_o,    // priority escalation for sync request
  output wire        tgu_cfg_fifoaf_o,     // enable fifo auto-fulsh
  output wire        tgu_cfg_freadyhigh_o, // control for driving AFREADY high
  output wire        syncreq_o,            // synchronization request
  output wire        stm_enable_syncreq_o, // synchronization request due to STM enable pulse

  // Timestamp
  output wire [63:0] tsvalue_o,            // Timestamp value (registered here for timing)

  // Integartion testing interface
  output wire        itctl_o,              // integration mode
  output wire        ittrigger_we_o,       // write to ITTRIGGER register
  output wire        itatbdata0_we_o,      // write to ITATBDATA0 register
  output wire        itatbid_we_o,         // write to ITATBID register
  output wire        itatbctr0_we_o,       // write to ITATBCTR0 register

  // Q-Channel Configuration
  input  wire        q_stopped_i,          // Q-Channel Stopped
  output wire        qhwevoverride_o,      // Override QACTIVE asserted on HW IF Enable
  output wire        qforcedeny_o          // Override Q-Channel to always DENY
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------

  //  Register Addresses
  //---------------------

  // DMA request control register addresses
  localparam STMDMASTARTR_ADDR   = 12'hC04;    // DMA Transfer Start Register
  localparam STMDMASTOPR_ADDR    = 12'hC08;    // DMA Transfer Stop Register
  localparam STMDMASTATR_ADDR    = 12'hC0C;    // DMA Transfer Status Register
  localparam STMDMACTLR_ADDR     = 12'hC10;    // DMA Control Register
  localparam STMDMAIDR_ADDR      = 12'hCFC;    // DMA ID Register

  // Hardware event control register addresses
  localparam STMHEER_ADDR        = 12'hD00;    // Hardware Event Enable Register
  localparam STMHETER_ADDR       = 12'hD20;    // Hardware Event Trigger Enable Register
  localparam STMHEBSR_ADDR       = 12'hD60;    // Hardware Event Bank Select Register
  localparam STMHEMCR_ADDR       = 12'hD64;    // Hardware Event Main Control Register
  localparam STMHEEXTMUXR_ADDR   = 12'hD68;    // Hardware Event External Multiplex Control Register
  localparam STMHEMASTR_ADDR     = 12'hDF4;    // Hardware Event Master Number Register
  localparam STMHEFEAT1R_ADDR    = 12'hDF8;    // Hardware Event Features 1 Register
  localparam STMHEIDR_ADDR       = 12'hDFC;    // Hardware Event ID Register

  // Stimulus port control register addresses
  localparam STMSPER_ADDR        = 12'hE00;    // Stimulus Port Enable Register
  localparam STMSPTER_ADDR       = 12'hE20;    // Stimulus Port Trigger Enable Register
  localparam STMSPSCR_ADDR       = 12'hE60;    // Stimulus Port Select Configuration Register
  localparam STMSPMSCR_ADDR      = 12'hE64;    // Stimulus Port Master Select Configuration Register
  localparam STMSPOVERRIDER_ADDR = 12'hE68;    // Stimulus Port Override Register
  localparam STMSPMOVERRIDER_ADDR= 12'hE6C;    // Stimulus Port Master Override Register
  localparam STMSPTRIGCSR_ADDR   = 12'hE70;    // Stimulus Port Trigger Control and Status Register

  // Primary control and status register addresses
  localparam STMTCSR_ADDR        = 12'hE80;    // Trace Control and Status Register
  localparam STMTSSTIMR_ADDR     = 12'hE84;    // Timestamp Stimulus Register
  localparam STMTSFREQR_ADDR     = 12'hE8C;    // Timestamp Frequency Register
  localparam STMSYNCR_ADDR       = 12'hE90;    // Synchronisation Control Register
  localparam STMAUXCR_ADDR       = 12'hE94;    // Auxiliary Control Register

  // Identification register addresses
  localparam STMFEAT1R_ADDR      = 12'hEA0;    // Features 1 Register
  localparam STMFEAT2R_ADDR      = 12'hEA4;    // Features 2 Register
  localparam STMFEAT3R_ADDR      = 12'hEA8;    // Features 3 Register

  // Integration Registers
  localparam STMITTRIGGER_ADDR   = 12'hEE8;    // Trigger Register
  localparam STMITATBDATA0_ADDR  = 12'hEEC;    // ATB Data 0 Register
  localparam STMITATBCTR2_ADDR   = 12'hEF0;    // ATB Control 2 Register
  localparam STMITATBID_ADDR     = 12'hEF4;    // ATB Identification Register
  localparam STMITATBCTR0_ADDR   = 12'hEF8;    // ATB Control 0 Register

  // CoreSight Management register addresses
  localparam STMITCTL_ADDR       = 12'hF00;    // Integration Mode Control Register
  localparam STMCLAIMSET_ADDR    = 12'hFA0;    // Claim Tag Set Register
  localparam STMCLAIMCLR_ADDR    = 12'hFA4;    // Claim Tag Clear Register
  localparam STMLAR_ADDR         = 12'hFB0;    // Lock Access Register
  localparam STMLSR_ADDR         = 12'hFB4;    // Lock Status Register
  localparam STMAUTHSTATUS_ADDR  = 12'hFB8;    // Authentication Status Register
  localparam STMDEVARCH_ADDR     = 12'hFBC;    // Device Architecture Register
  localparam STMDEVID_ADDR       = 12'hFC8;    // Device Configuration Register
  localparam STMDEVTYPE_ADDR     = 12'hFCC;    // Device Type register

  localparam STMPID0_ADDR        = 12'hFE0;    // Peripheral ID0 register
  localparam STMPID1_ADDR        = 12'hFE4;    // Peripheral ID1 register
  localparam STMPID2_ADDR        = 12'hFE8;    // Peripheral ID2 register
  localparam STMPID3_ADDR        = 12'hFEC;    // Peripheral ID3 register
  localparam STMPID4_ADDR        = 12'hFD0;    // Peripheral ID4 register
  localparam STMPID5_ADDR        = 12'hFD4;    // Peripheral ID5 register
  localparam STMPID6_ADDR        = 12'hFD8;    // Peripheral ID6 register
  localparam STMPID7_ADDR        = 12'hFDC;    // Peripheral ID7 register

  localparam STMCID0_ADDR        = 12'hFF0;    // Component ID0 register
  localparam STMCID1_ADDR        = 12'hFF4;    // Component ID1 register
  localparam STMCID2_ADDR        = 12'hFF8;    // Component ID2 register
  localparam STMCID3_ADDR        = 12'hFFC;    // Component ID3 register

  //  Register Read Only Values
  //----------------------------

  // Read Only Register Field Values
  localparam STMDMAIDR_DMAVENDSPEC = 4'h0;
  localparam STMDMAIDR_DMACLASSREV = 4'h0;
  localparam STMDMAIDR_DMACLASS    = 4'h2;       // DMA control

  localparam STMHEMASTR_HEMAST     = 16'h0080;   // STPv2 master number of HW event trace

  localparam STMHEFEAT1R_HEEXTMUXSIZE = 3'b011;  // Width of HEEXTMUX
  localparam STMHEFEAT1R_NUMHE_64  = 9'h40;      // 64 hardware events
  localparam STMHEFEAT1R_HECOMP    = 2'b11;      // data compression for HW events supported
  localparam STMHEFEAT1R_HEMASTR   = 1'b0;       // STMHEMASTR is read-only
  localparam STMHEFEAT1R_HEERR     = 1'b1;       // HW error detection implemented
  localparam STMHEFEAT1R_HETER     = 1'b1;       // STMHETER implemneted

  localparam STMHEIDR_HEVENDSPEC    = 4'h0;
  localparam STMHEIDR_HECLASSREV_64 = 4'h1;      // ClassRev Value for 64 bit STM datapath
  localparam STMHEIDR_HECLASS       = 4'h1;      // HW event control

  localparam STMTCSR_SYNCEN        = 1'b1;       // RAO as STMSYNCR is implemented

  localparam STMFEAT1R_SWOEN       = 2'b01;      // STMTCSR.SWOEN not implemented
  localparam STMFEAT1R_SYNCEN      = 2'b10;      // STMTCSR.SYNCEN implemented as RAO
  localparam STMFEAT1R_HWTEN       = 2'b01;      // STMTCSR>HWTEN not implemented
  localparam STMFEAT1R_TSPRESCALE  = 2'b01;      // timestamp prescale not implemented
  localparam STMFEAT1R_TRIGCTL     = 2'b10;      // multi-shot and single-shot triggers supported
  localparam STMFEAT1R_TRACEBUS    = 4'b0001;    // ATB plus ATB trigger
  localparam STMFEAT1R_SYNC        = 2'b11;      // STMSYNCR implemented with MODE control
  localparam STMFEAT1R_FORCETS     = 1'b1;       // STMTSSTIMR bit [0] implemented
  localparam STMFEAT1R_TSFREQ      = 1'b1;       // STMTSFREQR is read-write
  localparam STMFEAT1R_TS          = 2'b01;      // absolute timestamps implemented
  localparam STMFEAT1R_PROT        = 4'b0001;    // STPv2 protocol

  localparam STMFEAT2R_STYPE       = 2'b01;      // only extended stimulus port implemented
  localparam STMFEAT2R_DSIZE_64    = 4'b0001;    // 64-bit data
  localparam STMFEAT2R_SPTRTYPE    = 2'b10;      // both invariant timing and guaranteed transactions are supported
  localparam STMFEAT2R_PRIVMASK    = 2'b01;      // STMPRIVMASKR not implemented
  localparam STMFEAT2R_SPOVERRIDE  = 1'b1;       // STMOVERRIDER implemented
  localparam STMFEAT2R_SPCOMP      = 2'b11;      // data compression support is programmable
  localparam STMFEAT2R_SPER        = 1'b0;       // STMSPER is implemented
  localparam STMFEAT2R_SPTER       = 2'b10;      // STMSPTER is implemented

  localparam STMFEAT3R_NUMMAST     = 16'h007F;   // STMSPTER is implemented

  localparam STMCLAIMTAG           = 4'hF;       // 4 claim tag bits implemented

  localparam STMLSR_8BIT           = 1'b0;       // Lock access 8 bit
  localparam STMLSR_PRESENT        = 1'b1;       // Lock access present

  localparam STMDEVARCH            = 32'h47710A63; //Device Architecture Register Value

  localparam STMDEVID_NUMSP        = 17'h10000;  // DEVID, number of stimulus ports implemented

  localparam STMDEVTYPE            = 8'h63;      // DEVTYPE

  localparam STMPID0_64            = 8'h63;      // Peripheral ID0 value (STM 64 bit datapath)

  localparam STMPID1               = 8'hB9;      // Peripheral ID1 value
  localparam STMPID2_64            = 8'h1B;      // Peripheral ID2 value (STM 64 bit datapath)
  localparam STMPID3_CUSTOM        = 4'h0;       // Peripheral ID3 value
  localparam STMPID4               = 8'h04;      // Peripheral ID4 value
  localparam STMPID5               = 8'h00;      // Peripheral ID5 value
  localparam STMPID6               = 8'h00;      // Peripheral ID6 value
  localparam STMPID7               = 8'h00;      // Peripheral ID7 value

  localparam STMCID0               = 8'h0D;      // Component ID0 value
  localparam STMCID1               = 8'h90;      // Component ID1 value
  localparam STMCID2               = 8'h05;      // Component ID2 value
  localparam STMCID3               = 8'hB1;      // Component ID3 value


  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire        stm_clk_req;
  wire        reg_p_write;

  // Register Selects
  wire        dmastartr_sel;
  wire        dmastopr_sel;
  wire        dmastatr_sel;
  wire        dmactlr_sel;
  wire        dmaidr_sel;

  wire        heer_sel;
  wire        heter_sel;
  wire        hebsr_sel;
  wire        hemcr_sel;
  wire        heextmuxr_sel;
  wire        hemastr_sel;
  wire        hefeat1r_sel;
  wire        heidr_sel;

  wire        sper_sel;
  wire        spter_sel;
  wire        spscr_sel;
  wire        spmscr_sel;
  wire        spoverrider_sel;
  wire        spmoverrider_sel;
  wire        trigcsr_sel;

  wire        tcsr_sel;
  wire        tsstimr_sel;
  wire        tsfreqr_sel;
  wire        syncr_sel;
  wire        auxcr_sel;

  wire        stmfeat1r_sel;
  wire        stmfeat2r_sel;
  wire        stmfeat3r_sel;

  wire        ittrigger_sel;
  wire        itatbdata0_sel;
  wire        itatbctr2_sel;
  wire        itatbid_sel;
  wire        itatbctr0_sel;

  wire        itctl_sel;
  wire        claimset_sel;
  wire        claimclr_sel;
  wire        lar_sel;
  wire        lsr_sel;
  wire        authstatus_sel;
  wire        devarch_sel;
  wire        devid_sel;
  wire        devtype_sel;

  wire        periphid0_sel;
  wire        periphid1_sel;
  wire        periphid2_sel;
  wire        periphid3_sel;
  wire        periphid4_sel;
  wire        periphid5_sel;
  wire        periphid6_sel;
  wire        periphid7_sel;

  wire        compid0_sel;
  wire        compid1_sel;
  wire        compid2_sel;
  wire        compid3_sel;

  // Write Enables
  wire        dma_enable_we;
  wire        dmactlr_we;

  wire        heer_we;
  wire        heter_we;
  wire        hebsr_we;
  wire        hemcr_we;
  wire        heextmuxr_we;
  wire        trigclearhete;
  wire        trigstatushete_we;

  wire        sper_we;
  wire        spter_we;
  wire        spscr_we;
  wire        spmscr_we;
  wire        spoverrider_we;
  wire        spmoverrider_we;
  wire        trigcsr_we;
  wire        trigclearspte;
  wire        trigstatusspte_we;

  wire        tcsr_we;
  wire        forcets_we;
  wire        tsfreqr_we;
  wire        syncr_we;
  wire        auxcr_we;

  wire        ittrigger_we;
  wire        itatbdata0_we;
  wire        itatbid_we;
  wire        itatbctr0_we;
  wire        itcl_we;
  wire        claim_tag_we;
  wire        lar_we;

  // Register Read Data Buses
  wire [31:0] dmastatr_rd_data;
  wire [31:0] dmactlr_rd_data;
  wire [31:0] dmaidr_rd_data;

  wire [31:0] heer_rd_data;
  wire [31:0] heter_rd_data;
  wire [31:0] hebsr_rd_data;
  wire [31:0] hemcr_rd_data;
  wire [31:0] heextmuxr_rd_data;
  wire [31:0] hemastr_rd_data;
  wire [31:0] hefeat1r_rd_data;
  wire [31:0] heidr_rd_data;

  wire [31:0] sper_rd_data;
  wire [31:0] spter_rd_data;
  wire [31:0] spscr_rd_data;
  wire [31:0] spmscr_rd_data;
  wire [31:0] spoverrider_rd_data;
  wire [31:0] spmoverrider_rd_data;
  wire [31:0] trigcsr_rd_data;

  wire [31:0] tcsr_rd_data;
  wire [31:0] tsfreqr_rd_data;
  wire [31:0] syncr_rd_data;
  wire [31:0] auxcr_rd_data;

  wire [31:0] stmfeat1r_rd_data;
  wire [31:0] stmfeat2r_rd_data;
  wire [31:0] stmfeat3r_rd_data;

  wire [31:0] itatbctr2_rd_data;
  wire [31:0] itctl_rd_data;

  wire [31:0] claimset_rd_data;
  wire [31:0] claimclr_rd_data;
  wire [31:0] lsr_rd_data;
  wire [31:0] authstatus_rd_data;
  wire [31:0] devarch_rd_data;
  wire [31:0] devid_rd_data;
  wire [31:0] devtype_rd_data;

  wire [31:0] periphid0_rd_data;
  wire [31:0] periphid1_rd_data;
  wire [31:0] periphid2_rd_data;
  wire [31:0] periphid3_rd_data;
  wire [31:0] periphid4_rd_data;
  wire [31:0] periphid5_rd_data;
  wire [31:0] periphid6_rd_data;
  wire [31:0] periphid7_rd_data;

  wire [31:0] compid0_rd_data;
  wire [31:0] compid1_rd_data;
  wire [31:0] compid2_rd_data;
  wire [31:0] compid3_rd_data;

  reg  [31:0] read_data;
  wire [45:0] read_mux_ctl;

  wire        dmastart;
  wire        dmastop;
  wire        stm_disable;
  wire        nxt_dma_enable;
  wire        nxt_trigstatushete;
  wire        nxt_forcets;
  wire        nxt_trigstatusspte;
  wire [3:0]  nxt_claim_tag;
  wire        nxt_dev_unlocked;
  wire        busy;
  wire        stm_enabled_pulse;
  wire        sync_enabled;
  wire        sync_cnt_reload;
  wire [11:3] nxt_sync_cnt;
  wire        sync_cnt_we;
  wire        sync_cnt_tc;
  wire        sync_cnt_aux_reload;
  reg  [15:0] sync_cnt_aux_reload_value;
  wire [15:0] nxt_sync_aux_cnt;
  wire        sync_cnt_aux_we;
  wire        sync_cnt_aux_tc;
  wire        sync_flag_int_we;
  wire        sync_flag_ext_we;
  wire        sync_combined;
  wire        sync_merged;
  wire        int_sync_req;
  wire        ext_sync_req;
  wire        nxt_sync_flag_int;
  wire        nxt_sync_flag_ext;
  wire        nxt_itcl;
  wire        en_we;
  wire        inreg_we;
  wire        sec_invasive;
  wire        nsec_invasive;
  wire        sec_noninvasive;
  wire        nsec_noninvasive;

  wire        stm_enabled_sync_we;
  wire        stm_enabled_sync;
  wire        nxt_stm_enabled_sync;
  wire        axi_buf_clr_we;
  wire        sync_reg_mode_we;
  wire        tsvalue_we;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg        dma_enable_reg;
  reg [1:0]  dma_sens_reg;

  reg [STM_DATA_WIDTH-1:0] heer_reg;
  reg [STM_DATA_WIDTH-1:0] heter_reg;
  reg                      hebsr_reg;
  reg [2:0]                hemcr_reg;
  reg [7:0]                heextmuxr_reg;
  reg                      atbtrigenhete_reg;
  reg                      trigctlhete_reg;
  reg                      trigstatushete_reg;

  reg [31:0] sper_reg;
  reg [31:0] spter_reg;
  reg [11:0] banksel_reg;
  reg [1:0]  portctl_reg;
  reg [7:0]  mastsel_reg;
  reg        mastctl_reg;
  reg [16:0] overportsel_reg;
  reg        overts_reg;
  reg [1:0]  overportctl_reg;
  reg [7:0]  overmastsel_reg;
  reg        overmastctl_reg;
  reg [6:0]  traceid_reg;
  reg        sp_compen_reg;
  reg        tsen_reg;
  reg        busy_reg;
  reg        en_reg;
  reg        en_dly_reg;
  reg        forcets_reg;
  reg        atbtrigenspte_reg;
  reg        atbtrigensw_reg;
  reg        trigctlspte_reg;
  reg        trigstatusspte_reg;
  reg [31:0] tsfreqr_reg;
  reg        tsfreqr_sync_reg;
  reg [12:3] syncr_reg;
  reg        flushprinvdis_reg;
  reg        asyncpe_reg;
  reg        fifoaf_reg;
  reg        clkon_reg;
  reg        freadyhigh_reg;
  reg        itctl_reg;
  reg  [3:0] claim_tag_reg;
  reg        device_unlocked_reg;
  reg        sync_enabled_reg;
  reg [11:3] sync_cnt_reg;
  reg [15:0] sync_cnt_aux_reg;
  reg        syncr_sync_reg;
  reg        syncreq_reg;
  reg        sync_flag_int_reg;
  reg        sync_flag_ext_reg;
  reg [63:0] tsvalue_reg;
  reg        axi_buf_clr_reg;

  reg         afvalid_reg;
  reg         atready_reg;
  reg         atvalid_reg;

  reg qhwevoverride_reg;
  reg qforcedeny_reg;
  reg stm_enabled_sync_reg;
  reg sync_reg_mode;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  // Re-timing of top level ports
  assign inreg_we = en_reg | itctl_reg;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
    begin
      afvalid_reg <= 1'b0;
      atready_reg <= 1'b0;
      atvalid_reg <= 1'b0;
    end
    else if (inreg_we)
    begin
      afvalid_reg <= AFVALIDM;
      atready_reg <= ATREADYM;
      atvalid_reg <= atvalidm_i;
    end
  end

  // APB address decode
  assign dmastartr_sel    = (paddrdbg_r_i[11:2] == STMDMASTARTR_ADDR[11:2]);
  assign dmastopr_sel     = (paddrdbg_r_i[11:2] == STMDMASTOPR_ADDR[11:2]);
  assign dmastatr_sel     = (paddrdbg_r_i[11:2] == STMDMASTATR_ADDR[11:2]);
  assign dmactlr_sel      = (paddrdbg_r_i[11:2] == STMDMACTLR_ADDR[11:2]);
  assign dmaidr_sel       = (paddrdbg_r_i[11:2] == STMDMAIDR_ADDR[11:2]);

  generate
  if (HWEVOBIF_PRESENT == 1)
  begin : gen_addr_decode_hw
    assign heer_sel         = (paddrdbg_r_i[11:2] == STMHEER_ADDR[11:2]);
    assign heter_sel        = (paddrdbg_r_i[11:2] == STMHETER_ADDR[11:2]);
    assign hemcr_sel        = (paddrdbg_r_i[11:2] == STMHEMCR_ADDR[11:2]);
    assign hemastr_sel      = (paddrdbg_r_i[11:2] == STMHEMASTR_ADDR[11:2]);
    assign hefeat1r_sel     = (paddrdbg_r_i[11:2] == STMHEFEAT1R_ADDR[11:2]);
    assign heidr_sel        = (paddrdbg_r_i[11:2] == STMHEIDR_ADDR[11:2]);

    if (STM_DATA_WIDTH == 64) begin
      assign hebsr_sel      = (paddrdbg_r_i[11:2] == STMHEBSR_ADDR[11:2]);
      assign heextmuxr_sel  = (paddrdbg_r_i[11:2] == STMHEEXTMUXR_ADDR[11:2]);
    end

  end
  else
  begin : gen_addr_decode_no_hw
    assign heer_sel         = 1'b0;
    assign heter_sel        = 1'b0;
    assign hemcr_sel        = 1'b0;
    assign hemastr_sel      = 1'b0;
    assign hefeat1r_sel     = 1'b0;
    assign heidr_sel        = 1'b0;

    if (STM_DATA_WIDTH == 64) begin
      assign hebsr_sel      = 1'b0;
      assign heextmuxr_sel  = 1'b0;
    end

  end
  endgenerate

  assign sper_sel         = (paddrdbg_r_i[11:2] == STMSPER_ADDR[11:2]);
  assign spter_sel        = (paddrdbg_r_i[11:2] == STMSPTER_ADDR[11:2]);
  assign spscr_sel        = (paddrdbg_r_i[11:2] == STMSPSCR_ADDR[11:2]);
  assign spmscr_sel       = (paddrdbg_r_i[11:2] == STMSPMSCR_ADDR[11:2]);
  assign spoverrider_sel  = (paddrdbg_r_i[11:2] == STMSPOVERRIDER_ADDR[11:2]);
  assign spmoverrider_sel = (paddrdbg_r_i[11:2] == STMSPMOVERRIDER_ADDR[11:2]);

  assign tcsr_sel         = (paddrdbg_r_i[11:2] == STMTCSR_ADDR[11:2]);
  assign tsstimr_sel      = (paddrdbg_r_i[11:2] == STMTSSTIMR_ADDR[11:2]);
  assign trigcsr_sel      = (paddrdbg_r_i[11:2] == STMSPTRIGCSR_ADDR[11:2]);
  assign tsfreqr_sel      = (paddrdbg_r_i[11:2] == STMTSFREQR_ADDR[11:2]);
  assign syncr_sel        = (paddrdbg_r_i[11:2] == STMSYNCR_ADDR[11:2]);
  assign auxcr_sel        = (paddrdbg_r_i[11:2] == STMAUXCR_ADDR[11:2]);

  assign stmfeat1r_sel    = (paddrdbg_r_i[11:2] == STMFEAT1R_ADDR[11:2]);
  assign stmfeat2r_sel    = (paddrdbg_r_i[11:2] == STMFEAT2R_ADDR[11:2]);
  assign stmfeat3r_sel    = (paddrdbg_r_i[11:2] == STMFEAT3R_ADDR[11:2]);

  assign ittrigger_sel    = (paddrdbg_r_i[11:2] == STMITTRIGGER_ADDR[11:2]);
  assign itatbdata0_sel   = (paddrdbg_r_i[11:2] == STMITATBDATA0_ADDR[11:2]);
  assign itatbctr2_sel    = (paddrdbg_r_i[11:2] == STMITATBCTR2_ADDR[11:2]);
  assign itatbid_sel      = (paddrdbg_r_i[11:2] == STMITATBID_ADDR[11:2]);
  assign itatbctr0_sel    = (paddrdbg_r_i[11:2] == STMITATBCTR0_ADDR[11:2]);

  assign itctl_sel        = (paddrdbg_r_i[11:2] == STMITCTL_ADDR[11:2]);
  assign claimset_sel     = (paddrdbg_r_i[11:2] == STMCLAIMSET_ADDR[11:2]);
  assign claimclr_sel     = (paddrdbg_r_i[11:2] == STMCLAIMCLR_ADDR[11:2]);
  assign lar_sel          = (paddrdbg_r_i[11:2] == STMLAR_ADDR[11:2]);
  assign lsr_sel          = (paddrdbg_r_i[11:2] == STMLSR_ADDR[11:2]);
  assign authstatus_sel   = (paddrdbg_r_i[11:2] == STMAUTHSTATUS_ADDR[11:2]);

  generate
    if (STM_DATA_WIDTH == 64)
      assign devarch_sel    = (paddrdbg_r_i[11:2] == STMDEVARCH_ADDR[11:2]);
  endgenerate

  assign devid_sel        = (paddrdbg_r_i[11:2] == STMDEVID_ADDR[11:2]);
  assign devtype_sel      = (paddrdbg_r_i[11:2] == STMDEVTYPE_ADDR[11:2]);

  assign periphid0_sel    = (paddrdbg_r_i[11:2] == STMPID0_ADDR[11:2]);
  assign periphid1_sel    = (paddrdbg_r_i[11:2] == STMPID1_ADDR[11:2]);
  assign periphid2_sel    = (paddrdbg_r_i[11:2] == STMPID2_ADDR[11:2]);
  assign periphid3_sel    = (paddrdbg_r_i[11:2] == STMPID3_ADDR[11:2]);
  assign periphid4_sel    = (paddrdbg_r_i[11:2] == STMPID4_ADDR[11:2]);
  assign periphid5_sel    = (paddrdbg_r_i[11:2] == STMPID5_ADDR[11:2]);
  assign periphid6_sel    = (paddrdbg_r_i[11:2] == STMPID6_ADDR[11:2]);
  assign periphid7_sel    = (paddrdbg_r_i[11:2] == STMPID7_ADDR[11:2]);

  assign compid0_sel      = (paddrdbg_r_i[11:2] == STMCID0_ADDR[11:2]);
  assign compid1_sel      = (paddrdbg_r_i[11:2] == STMCID1_ADDR[11:2]);
  assign compid2_sel      = (paddrdbg_r_i[11:2] == STMCID2_ADDR[11:2]);
  assign compid3_sel      = (paddrdbg_r_i[11:2] == STMCID3_ADDR[11:2]);

  // Writes are enabled when device is unlocked or it is a debugger access
  assign reg_p_write = reg_write_en_i & (device_unlocked_reg | paddrdbg31_r_i);

  //---------------------------------------------------------------------------
  // DMA Transfer Start Register (STMDMASTARTR)
  // DMA Transfer Stop Register (STMDMASTOPR)
  //---------------------------------------------------------------------------
  assign dmastart = dmastartr_sel & pwdatadbg_r_i[0];
  assign dmastop = dmastopr_sel  & pwdatadbg_r_i[0];
  assign stm_disable = tcsr_sel  & ~pwdatadbg_r_i[0];
  assign dma_enable_we = reg_p_write & (dmastart | dmastop | stm_disable);

  // On transfer start write dma_enable_reg is set
  // On transfer stop write dma_enable_reg is clear
  assign nxt_dma_enable = dmastart;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      dma_enable_reg <= 1'b0;
    else if(dma_enable_we)
      dma_enable_reg <= nxt_dma_enable;
  end

  //---------------------------------------------------------------------------
  // DMA Transfer Status Register (STMDMASTATR)
  //---------------------------------------------------------------------------
  assign dmastatr_rd_data[31:0] = {{31{1'b0}},     // 31:1
                                   dma_busy_i      // 0
                                  };

  //---------------------------------------------------------------------------
  // DMA Control Register (STMDMACTLR)
  //---------------------------------------------------------------------------
  assign dmactlr_we        = reg_p_write & dmactlr_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      dma_sens_reg[1:0] <= {2{1'b0}};
    else if(dmactlr_we)
      dma_sens_reg[1:0] <= pwdatadbg_r_i[3:2];
  end

  assign dmactlr_rd_data[31:0] = {{28{1'b0}},        // 31:4
                                  dma_sens_reg[1:0], // 3:2
                                  2'b00              // 1:0
                                 };

  //---------------------------------------------------------------------------
  // DMA ID Register (STMDMAIDR)
  //---------------------------------------------------------------------------
  assign dmaidr_rd_data[31:0] = {{20{1'b0}},                  // 31:12
                                 STMDMAIDR_DMAVENDSPEC[3:0],  // 11:8
                                 STMDMAIDR_DMACLASSREV[3:0],  // 7:4
                                 STMDMAIDR_DMACLASS[3:0]      // 3:0
                                };

  //---------------------------------------------------------------------------
  //  Hardware Event Enable Register (STMHEER)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmheer
      assign heer_we = reg_p_write & heer_sel;

      if (STM_DATA_WIDTH == 64) begin : gen_stmheer_64
        always @(posedge clk_gated) begin

          if(heer_we & hebsr_reg)
            heer_reg[63:32] <= pwdatadbg_r_i[31:0];

          else if(heer_we) //Else implies ~hebsr_reg
            heer_reg[31:0] <= pwdatadbg_r_i[31:0];

        end

        assign heer_rd_data[31:0] = hebsr_reg ? heer_reg[63:32] : heer_reg[31:0];

      end


    end
    else begin : gen_no_stmheer //Else no HW Event Interface

      assign heer_rd_data[31:0]     = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  //  Hardware Event Trigger Enable Register (STMHETER)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmheter
      assign heter_we = reg_p_write & heter_sel;

      if (STM_DATA_WIDTH == 64) begin : gen_stmheter_64
        always @(posedge clk_gated)

          if(heter_we & hebsr_reg)
            heter_reg[63:32] <= pwdatadbg_r_i[31:0];

          else if(heter_we) //Else implies ~hebsr_reg
            heter_reg[31:0] <= pwdatadbg_r_i[31:0];

        assign heter_rd_data[31:0] = hebsr_reg ? heter_reg[63:32] : heter_reg[31:0];

      end


    end else begin : gen_no_stmheter //Else no HW IF
      assign heter_rd_data[31:0]    = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event Bank Select Register (STMHEBSR)
  //---------------------------------------------------------------------------
  generate
    if ((HWEVOBIF_PRESENT == 1) & (STM_DATA_WIDTH == 64)) begin : gen_stmhebsr_64
      assign hebsr_we = reg_p_write & hebsr_sel;

      always @(posedge clk_gated or negedge STMRESETn) begin
        if (~STMRESETn)
          hebsr_reg <= 1'b0;
        else if(hebsr_we)
          hebsr_reg <= pwdatadbg_r_i[0];
      end

      assign hebsr_rd_data[31:0] = {{31{1'b0}},     //31:1
                                     hebsr_reg   //0
                                    };

    end else begin : gen_no_stmhebsr
      assign hebsr_rd_data[31:0] = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event Master Control Register (STMHEMCR)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmhemcr
      assign hemcr_we = reg_p_write & hemcr_sel;

      always @(posedge clk_gated)
        if(hemcr_we)
          hemcr_reg[2:1] <= pwdatadbg_r_i[2:1];

      always @(posedge clk_gated or negedge STMRESETn) begin
        if (!STMRESETn) begin
          atbtrigenhete_reg <= 1'b0;
          trigctlhete_reg   <= 1'b0;
          hemcr_reg[0]      <= 1'b0;
        end else if (hemcr_we) begin
          atbtrigenhete_reg <= pwdatadbg_r_i[7];
          trigctlhete_reg   <= pwdatadbg_r_i[4];
          hemcr_reg[0]      <= pwdatadbg_r_i[0];
        end
      end

    // Trigger status is cleared on:
    // - write 1'b1 to STMHEMCR.TRIGCLEAR (bit 6)
    // - write 1'b0 to STMHEMCR.TRIGCTL (bit 4) - multi-shot mode
    // Trigger status is set on "match using STMHETER" trigger in single-shot mode
    assign trigclearhete      = hemcr_we & (pwdatadbg_r_i[6] | ~pwdatadbg_r_i[4]);
    assign trigstatushete_we  = trigclearhete | triggerhete_i;
    assign nxt_trigstatushete = ~trigclearhete & triggerhete_i & trigctlhete_reg;

    always @(posedge clk_gated or negedge STMRESETn)
    begin
      if (!STMRESETn)
        trigstatushete_reg <= 1'b0;
      else if(trigstatushete_we)
        trigstatushete_reg <= nxt_trigstatushete;
    end

    assign hemcr_rd_data[31:0] = {{24{1'b0}},         // 31:8
                                  atbtrigenhete_reg,  // 7
                                  1'b0,               // 6
                                  trigstatushete_reg, // 5
                                  trigctlhete_reg,    // 4
                                  1'b0,               // 3
                                  hemcr_reg[2:0]      // 2:0
                                 };

    end else begin : gen_no_stmhemcr //Else no HW IF
      assign hemcr_rd_data[31:0]    = {32{1'b0}};
    end

  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event External Multiplex Control Register (STMHEEXTMUXR)
  //---------------------------------------------------------------------------
  generate
    if ((HWEVOBIF_PRESENT == 1) & (STM_DATA_WIDTH == 64)) begin : gen_stmheextmuxr_64
      assign heextmuxr_we = reg_p_write & heextmuxr_sel;

      always @(posedge clk_gated or negedge STMRESETn) begin
        if (~STMRESETn)
          heextmuxr_reg[7:0] <= 8'b0;
        else if(heextmuxr_we)
          heextmuxr_reg[7:0] <= pwdatadbg_r_i[7:0];
      end

      assign heextmuxr_rd_data[31:0] = {{24{1'b0}},         //31:8
                                        heextmuxr_reg[7:0]  //7:0
                                       };

    end else begin : gen_no_stmheextmuxr
      assign heextmuxr_rd_data[31:0] = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event Master Number Register (STMHEMASTR)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmhemastr
      assign hemastr_rd_data[31:0] = {{16{1'b0}},             // 31:16
                                      STMHEMASTR_HEMAST[15:0] // 15:0
                                     };

    end else begin : gen_no_stmhemastr //Else no HW IF
      assign hemastr_rd_data[31:0]  = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event Features 1 Register (STMHEFEAT1R)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmhefeat1r
      if (STM_DATA_WIDTH == 64)
        assign hefeat1r_rd_data[31:0] = {1'b0,                           // 31
                                         STMHEFEAT1R_HEEXTMUXSIZE[2:0],  // 30:28
                                         {4{1'b0}},                      // 27:24
                                         STMHEFEAT1R_NUMHE_64[8:0],      // 23:15
                                         {9{1'b0}},                      // 14:6
                                         STMHEFEAT1R_HECOMP[1:0],        // 5:4
                                         STMHEFEAT1R_HEMASTR,            // 3
                                         STMHEFEAT1R_HEERR,              // 2
                                         1'b0,                           // 1
                                         STMHEFEAT1R_HETER               // 0
                                        };
    end else begin : gen_no_stmhefeat1r //Else no HW IF
      assign hefeat1r_rd_data[31:0] = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Hardware Event ID Register (STMHEIDR)
  //---------------------------------------------------------------------------
  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_stmheidr
      if (STM_DATA_WIDTH == 64)
        assign heidr_rd_data[31:0] = {{20{1'b0}},                  // 31:12
                                      STMHEIDR_HEVENDSPEC[3:0],    // 11:8
                                      STMHEIDR_HECLASSREV_64[3:0], // 7:4
                                      STMHEIDR_HECLASS   [3:0]     // 3:0
                                     };

    end else begin : gen_nostmheidr
      assign heidr_rd_data[31:0] = {32{1'b0}};

    end
  endgenerate

  //---------------------------------------------------------------------------
  // Stimulus Port Enable Register (STMSPER)
  //---------------------------------------------------------------------------
  assign sper_we        = reg_p_write & sper_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      sper_reg[31:0] <= {32{1'b0}};
    else if(sper_we)
      sper_reg[31:0] <= pwdatadbg_r_i[31:0];
  end

  assign sper_rd_data[31:0] = sper_reg[31:0];

  //---------------------------------------------------------------------------
  // Stimulus Port Trigger Enable Register (STMSPTER)
  //---------------------------------------------------------------------------
  assign spter_we = reg_p_write & spter_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      spter_reg[31:0] <= {32{1'b0}};
    else if(spter_we)
      spter_reg[31:0] <= pwdatadbg_r_i[31:0];
  end

  assign spter_rd_data[31:0] = spter_reg [31:0];

  //---------------------------------------------------------------------------
  // Stimulus Port Select Configuration Register (STMSPSCR)
  //---------------------------------------------------------------------------
  assign spscr_we = reg_p_write & spscr_sel;

  always @(posedge clk_gated)
    if(spscr_we)
      banksel_reg[11:0] <= pwdatadbg_r_i[31:20];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      portctl_reg[1:0]  <= {2{1'b0}};
    else if(spscr_we)
      portctl_reg[1:0]  <= pwdatadbg_r_i[1:0];
  end

  assign spscr_rd_data[31:0] = {banksel_reg[11:0], // 31:20
                                {18{1'b0}},        // 19:2
                                portctl_reg[1:0]   // 1:0
                               };

  //---------------------------------------------------------------------------
  // Stimulus Port Master Select Configuration Register (STMSPMSCR)
  //---------------------------------------------------------------------------
  assign spmscr_we = reg_p_write & spmscr_sel;

  always @(posedge clk_gated)
    if(spmscr_we)
      mastsel_reg[7:0] <= pwdatadbg_r_i[22:15];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      mastctl_reg  <= 1'b0;
    else if(spmscr_we)
      mastctl_reg  <= pwdatadbg_r_i[0];
  end

  assign spmscr_rd_data[31:0] = {{9{1'b0}},         // 31:23
                                 mastsel_reg[7:0],  // 22:15
                                 {14{1'b0}},        // 14:1
                                 mastctl_reg        // 0
                                };

  //---------------------------------------------------------------------------
  // Stimulus Port Override Register (STMSPOVERRIDER)
  //---------------------------------------------------------------------------
  assign spoverrider_we = reg_p_write & spoverrider_sel;

  always @(posedge clk_gated)
    if(spoverrider_we)
      overportsel_reg[16:0] <= pwdatadbg_r_i[31:15];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
    begin
      overts_reg            <= 1'b0;
      overportctl_reg[1:0]  <= {2{1'b0}};
    end
    else if(spoverrider_we)
    begin
      overts_reg            <= pwdatadbg_r_i[2];
      overportctl_reg[1:0]  <= pwdatadbg_r_i[1:0];
    end
  end

  assign spoverrider_rd_data[31:0] = {overportsel_reg[16:0], // 31:15
                                      {12{1'b0}},            // 14:3
                                      overts_reg,            // 2
                                      overportctl_reg[1:0]   // 1:0
                                     };

  //---------------------------------------------------------------------------
  // Stimulus Port Master Override Register (STMSPMOVERRIDER)
  //---------------------------------------------------------------------------
  assign spmoverrider_we = reg_p_write & spmoverrider_sel;

  always @(posedge clk_gated)
    if(spmoverrider_we)
      overmastsel_reg[7:0] <= pwdatadbg_r_i[22:15];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      overmastctl_reg  <= 1'b0;
    else if(spmoverrider_we)
      overmastctl_reg  <= pwdatadbg_r_i[0];
  end

  assign spmoverrider_rd_data[31:0] = {{9{1'b0}},             // 31:23
                                       overmastsel_reg[7:0],  // 22:15
                                       {14{1'b0}},            // 14:1
                                       overmastctl_reg        // 0
                                      };

  //---------------------------------------------------------------------------
  // Trigger Control and Status Register (STMSPTRIGCSR)
  //---------------------------------------------------------------------------
  assign trigcsr_we = reg_p_write & trigcsr_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
    begin
      atbtrigensw_reg    <= 1'b0;
      atbtrigenspte_reg  <= 1'b0;
      trigctlspte_reg    <= 1'b0;
    end
    else if(trigcsr_we)
    begin
      atbtrigensw_reg    <= pwdatadbg_r_i[4];
      atbtrigenspte_reg  <= pwdatadbg_r_i[3];
      trigctlspte_reg    <= pwdatadbg_r_i[0];
    end
  end

  // Trigger status is cleared on:
  // - write 1'b1 to STMSPTRIGCSR.TRIGCLEAR (bit 2)
  // - write 1'b0 to STMSPTRIGCSR.TRIGCTL (bit 0) - multi-shot mode set
  // Trigger status is set on "match using STMSPTER" trigger in single-shot mode
  assign trigclearspte      =  trigcsr_we & (pwdatadbg_r_i[2] | ~pwdatadbg_r_i[0]);
  assign trigstatusspte_we  =  trigclearspte | triggerspte_i;
  assign nxt_trigstatusspte = ~trigclearspte & triggerspte_i & trigctlspte_reg;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      trigstatusspte_reg <= 1'b0;
    else if(trigstatusspte_we)
      trigstatusspte_reg <= nxt_trigstatusspte;
  end

  assign trigcsr_rd_data[31:0] = {{27{1'b0}},            // 31:5
                                  atbtrigensw_reg,       // 4
                                  atbtrigenspte_reg,     // 3
                                  1'b0,                  // 2
                                  trigstatusspte_reg,    // 1
                                  trigctlspte_reg        // 0
                                 };

  //---------------------------------------------------------------------------
  // Trace Control and Status Register (STMTCSR)
  //---------------------------------------------------------------------------
  assign tcsr_we = reg_p_write & tcsr_sel;

  always @(posedge clk_gated)
    if(tcsr_we)
      traceid_reg[6:0] <= pwdatadbg_r_i[22:16];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
    begin
      sp_compen_reg    <= 1'b0;
      tsen_reg         <= 1'b0;
    end
    else if(tcsr_we)
    begin
      sp_compen_reg    <= pwdatadbg_r_i[5];
      tsen_reg         <= pwdatadbg_r_i[1];
    end
  end

  assign en_we  = reg_p_write & tcsr_sel;
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      en_reg           <= 1'b0;
    else if(en_we)
      en_reg           <= pwdatadbg_r_i[0];
  end

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      en_dly_reg <= 1'b0;
    else
      en_dly_reg <= en_reg;
  end
  assign stm_enabled_pulse = en_reg & ~en_dly_reg;

  // Busy is set when either of sub-blocks is busy
  assign busy = axi_busy_i | hw_busy_i | dma_busy_i | tgu_busy_i;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      busy_reg <= 1'b0;
    else
      busy_reg <= busy;
  end


  assign tcsr_rd_data[31:0] = {{8{1'b0}},         // 31:24
                               busy,              // 23
                               traceid_reg[6:0],  // 22:16
                               {10{1'b0}},        // 15:6
                               sp_compen_reg,     // 5
                               {2{1'b0}},         // 4:3
                               STMTCSR_SYNCEN,    // 2
                               tsen_reg,          // 1
                               en_reg             // 0
                              };

  //---------------------------------------------------------------------------
  // Timestamp Stimulus Register (STMTSSTIMR)
  // Force timestamp stimulus for AXI is set on write 1'b1 to STMTSSTIMR.FORCETS (bit) when timestamping is enabled
  // and is cleared with acknowledge from AXI i/f
  // Set has priority over clear
  //---------------------------------------------------------------------------
  assign forcets_we  = (tsen_reg & reg_p_write & tsstimr_sel & pwdatadbg_r_i[0]) | forcets_ack_i;
  assign nxt_forcets =  tsen_reg & reg_p_write & tsstimr_sel & pwdatadbg_r_i[0];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      forcets_reg <= 1'b0;
    else if(forcets_we)
      forcets_reg <= nxt_forcets;
  end

  //---------------------------------------------------------------------------
  // Timestamp Frequency  Register (STMTSFREQR)
  //---------------------------------------------------------------------------
  assign tsfreqr_we = reg_p_write & tsfreqr_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      tsfreqr_reg[31:0] <= {32{1'b0}};
    else if(tsfreqr_we)
      tsfreqr_reg[31:0] <= pwdatadbg_r_i[31:0];
  end

  assign tsfreqr_rd_data[31:0] = tsfreqr_reg[31:0];

  // Do a synchronization requets on writes to STMTSFREQR
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      tsfreqr_sync_reg <= 1'b0;
    else
      tsfreqr_sync_reg <= tsfreqr_we;
  end

  //---------------------------------------------------------------------------
  // Synchronization Control Register (STMSYNCR)
  //---------------------------------------------------------------------------
  assign syncr_we = reg_p_write & syncr_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      syncr_reg[12:3]  <= {10{1'b0}};
    else if(syncr_we)
      syncr_reg[12:3]  <= pwdatadbg_r_i[12:3];
  end

  assign syncr_rd_data[31:0] = {{19{1'b0}},        // 31:13
                                syncr_reg[12:3],   // 12:3
                                3'b000             // 2:0
                               };

  // Do a synchrobization requets on writes to STMSYNCR
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      syncr_sync_reg <= 1'b0;
    else
      syncr_sync_reg <= syncr_we;
  end
  // Synchronization Counter is enabled if there's non-zero value in STMSYNCR
  assign sync_enabled = |(syncr_reg[12:3]);
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      sync_enabled_reg  <= 1'b0;
    else if(sync_cnt_we)
      sync_enabled_reg  <= sync_enabled;
  end


  // Reload synchronization counter on:
  // 1. terminal count in mode 0
  // 2. teminal count in mode 1
  // 3. ASYNCOUT
  // 4. SYNCR write
  // 5. STM enable
  assign sync_cnt_reload    = (~syncr_reg[12] & sync_cnt_tc & sync_enabled_reg)                   |
                              ( syncr_reg[12] & sync_cnt_tc & sync_cnt_aux_tc & sync_enabled_reg) |
                              tgu_cfg_sync_ack_i                                                  |
                              syncr_sync_reg                                                      |
                              stm_enabled_pulse;
  // Synchronization Counter does approximate count i.e. each ATB transaction counts 8 bytes, hence bits 2:0 of STMSYNCR are ignored
  assign nxt_sync_cnt[11:3] = sync_cnt_reload ? ({9{~syncr_reg[12]}} & syncr_reg[11:3]) : (sync_cnt_reg[11:3] - {{8{1'b0}}, 1'b1});
  assign sync_cnt_we        = sync_cnt_reload |
                              (atvalid_reg & atready_reg & sync_enabled_reg);
  always @(posedge clk_gated)
  begin
    if(sync_cnt_we)
      sync_cnt_reg[11:3]  <= nxt_sync_cnt[11:3];
  end

  assign sync_cnt_tc = ~(|sync_cnt_reg[11:3]);

  // Mode 1 STMSYNCR sync value decode

  always @*
  begin
    case (syncr_reg[11:7])
      5'h1B: sync_cnt_aux_reload_value[15:0] = 16'h8000;
      5'h1A: sync_cnt_aux_reload_value[15:0] = 16'h4000;
      5'h19: sync_cnt_aux_reload_value[15:0] = 16'h2000;
      5'h18: sync_cnt_aux_reload_value[15:0] = 16'h1000;
      5'h17: sync_cnt_aux_reload_value[15:0] = 16'h0800;
      5'h16: sync_cnt_aux_reload_value[15:0] = 16'h0400;
      5'h15: sync_cnt_aux_reload_value[15:0] = 16'h0200;
      5'h14: sync_cnt_aux_reload_value[15:0] = 16'h0100;
      5'h13: sync_cnt_aux_reload_value[15:0] = 16'h0080;
      5'h12: sync_cnt_aux_reload_value[15:0] = 16'h0040;
      5'h11: sync_cnt_aux_reload_value[15:0] = 16'h0020;
      5'h10: sync_cnt_aux_reload_value[15:0] = 16'h0010;
      5'h0F: sync_cnt_aux_reload_value[15:0] = 16'h0008;
      5'h0E: sync_cnt_aux_reload_value[15:0] = 16'h0004;
      5'h0D: sync_cnt_aux_reload_value[15:0] = 16'h0002;
      5'h0C: sync_cnt_aux_reload_value[15:0] = 16'h0001;
      5'h0B,
      5'h0A,
      5'h09,
      5'h08,
      5'h07,
      5'h06,
      5'h05,
      5'h04,
      5'h03,
      5'h02,
      5'h01,
      5'h00,
      5'h1C,
      5'h1D,
      5'h1E,
      5'h1F: sync_cnt_aux_reload_value[15:0] = 16'h0001;
      // unreachable, X propagation only
      // VCS coverage off
      default: sync_cnt_aux_reload_value[15:0] = {16{1'bx}};
      // VCS coverage on
    endcase
  end

  // Reload auxiliary synchronization counter, used in Mode 1 on:
  // 1. teminal count in mode 1
  // 2. ASYNCOUT
  // 3. SYNCR write
  // 4. STM enable
  assign sync_cnt_aux_reload    = (syncr_reg[12] & sync_cnt_aux_tc & sync_cnt_tc & sync_enabled_reg) |
                                  tgu_cfg_sync_ack_i                                                 |
                                  syncr_sync_reg                                                     |
                                  stm_enabled_pulse;
  assign nxt_sync_aux_cnt[15:0] = sync_cnt_aux_reload ?  (sync_cnt_aux_reload_value[15:0]) : (sync_cnt_aux_reg[15:0] - {{15{1'b0}}, 1'b1});

  assign sync_cnt_aux_we        = sync_cnt_aux_reload |
                                  (sync_cnt_tc & syncr_reg[12] & atvalid_reg & atready_reg & sync_enabled_reg);

  always @(posedge clk_gated)
  begin
    if(sync_cnt_aux_we)
      sync_cnt_aux_reg[15:0]  <= nxt_sync_aux_cnt[15:0];
  end

  assign sync_cnt_aux_tc = ~(|sync_cnt_aux_reg[15:0]);

  // STM Enable SYNC generation
  // - A SYNC packet must be generated on STM enable, but only if (NIDEN | DBGEN) is set
  // - A SYNC packet must be generated on exiting Q_STOPPED, but only if STM enable and (NIDEN | DBGEN) is set
  // Edge detection on combined signals to produce sync
  assign nxt_stm_enabled_sync = en_reg & ~q_stopped_i & nsec_noninvasive;
  assign stm_enabled_sync_we = nxt_stm_enabled_sync ^ stm_enabled_sync_reg;

  always @(posedge clk_gated or negedge STMRESETn) begin
    if (!STMRESETn)
      stm_enabled_sync_reg <= 1'b0;
    else if (stm_enabled_sync_we)
      stm_enabled_sync_reg <= nxt_stm_enabled_sync;
  end

  assign stm_enabled_sync = nxt_stm_enabled_sync & ~stm_enabled_sync_reg;

  //Flopped syncr_reg[12] to generate internal sync with correct value
  assign sync_reg_mode_we = syncr_reg[12] ^ sync_reg_mode;

  always @(posedge clk_gated or negedge STMRESETn) begin
    if(!STMRESETn)
      sync_reg_mode <= 1'b0;
    else if (sync_reg_mode_we)
      sync_reg_mode <= syncr_reg[12];
  end

  // Internal sync request = terminal count of sync counters
  assign int_sync_req = sync_enabled_reg & sync_cnt_tc & (~sync_reg_mode | sync_reg_mode & sync_cnt_aux_tc);

  // Register external sync request (SYNCREQM input) for timing purpose
  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      syncreq_reg <= 1'b0;
    else
      syncreq_reg <= SYNCREQM;
  end

  // External sync request
  assign ext_sync_req = syncreq_reg;

  // Internal and external sync request combining logic
  // Flags:
  //   flag is set upon request active
  //   flag is cleared when combined sync is generated after request from another source
  assign nxt_sync_flag_int = int_sync_req | stm_enabled_sync;
  assign sync_flag_int_we  = int_sync_req | (ext_sync_req & sync_flag_ext_reg) | stm_enabled_sync;
  always @(posedge clk_gated)
  begin
    if(sync_flag_int_we)
      sync_flag_int_reg <= nxt_sync_flag_int;
  end

  assign nxt_sync_flag_ext = ext_sync_req | stm_enabled_sync;
  assign sync_flag_ext_we  = ext_sync_req | (int_sync_req & sync_flag_int_reg) | stm_enabled_sync;
  always @(posedge clk_gated)
  begin
    if(sync_flag_ext_we)
      sync_flag_ext_reg <= nxt_sync_flag_ext;
  end

  // Combined sync is generated when input request and associated flag are set
  // and there's no sync request already in control FIFO
  // and TGU is enabled
  assign sync_merged = ((ext_sync_req & sync_flag_ext_reg) | (int_sync_req & sync_flag_int_reg));

  // Combine all sources of SYNC request
  assign sync_combined = sync_merged | tsfreqr_sync_reg | syncr_sync_reg | stm_enabled_sync;

  //---------------------------------------------------------------------------
  // Auxiliary Control Register (STMAUXCR)
  //---------------------------------------------------------------------------
  assign auxcr_we = reg_p_write & auxcr_sel;

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
    begin
      qhwevoverride_reg <= 1'b0;
      qforcedeny_reg    <= 1'b0;
      freadyhigh_reg    <= 1'b0;
      clkon_reg         <= 1'b0;
      flushprinvdis_reg <= 1'b0;
      asyncpe_reg       <= 1'b0;
      fifoaf_reg        <= 1'b0;
    end
    else if(auxcr_we)
    begin
      qhwevoverride_reg <= pwdatadbg_r_i[7];
      qforcedeny_reg    <= pwdatadbg_r_i[6];
      freadyhigh_reg    <= pwdatadbg_r_i[4];
      clkon_reg         <= pwdatadbg_r_i[3];
      flushprinvdis_reg <= pwdatadbg_r_i[2];
      asyncpe_reg       <= pwdatadbg_r_i[1];
      fifoaf_reg        <= pwdatadbg_r_i[0];
    end
  end

  assign auxcr_rd_data[31:0] = {{24{1'b0}},        // 31:8
                                qhwevoverride_reg, // 7
                                qforcedeny_reg,    // 6
                                1'b0,              // 5
                                freadyhigh_reg,    // 4
                                clkon_reg,         // 3
                                flushprinvdis_reg, // 2
                                asyncpe_reg,       // 1
                                fifoaf_reg         // 0
                               };

  //---------------------------------------------------------------------------
  // Features 1 Register (STMFEAT1R)
  //---------------------------------------------------------------------------
  assign stmfeat1r_rd_data[31:0] = {{8{1'b0}},                  // 31:24
                                    STMFEAT1R_SWOEN[1:0],       // 23:22
                                    STMFEAT1R_SYNCEN[1:0],      // 21:20
                                    STMFEAT1R_HWTEN[1:0],       // 19:18
                                    STMFEAT1R_TSPRESCALE[1:0],  // 17:16
                                    STMFEAT1R_TRIGCTL[1:0],     // 15:14
                                    STMFEAT1R_TRACEBUS[3:0],    // 13:10
                                    STMFEAT1R_SYNC[1:0],        // 9:8
                                    STMFEAT1R_FORCETS,          // 7
                                    STMFEAT1R_TSFREQ,           // 6
                                    STMFEAT1R_TS[1:0],          // 5:4
                                    STMFEAT1R_PROT[3:0]         // 3:0
                                   };

  //---------------------------------------------------------------------------
  // Features 2 Register (STMFEAT2R)
  //---------------------------------------------------------------------------
  generate
    if (STM_DATA_WIDTH == 64)
      assign stmfeat2r_rd_data[31:0] = {{14{1'b0}},              // 31:18
                                        STMFEAT2R_STYPE[1:0],    // 17:16
                                        STMFEAT2R_DSIZE_64[3:0],    // 15:12
                                        1'b0,                    // 11
                                        STMFEAT2R_SPTRTYPE[1:0], // 10:9
                                        STMFEAT2R_PRIVMASK[1:0], // 8:7
                                        STMFEAT2R_SPOVERRIDE,    // 6
                                        STMFEAT2R_SPCOMP[1:0],   // 5:4
                                        1'b0,                    // 3
                                        STMFEAT2R_SPER,          // 2
                                        STMFEAT2R_SPTER[1:0]     // 1:0
                                       };
  endgenerate

  //---------------------------------------------------------------------------
  // Features 2 Register (STMFEAT3R)
  //---------------------------------------------------------------------------
  assign stmfeat3r_rd_data[31:0] = {{16{1'b0}},              // 31:16
                                    STMFEAT3R_NUMMAST[15:0]  // 15:0
                                   };


  //---------------------------------------------------------------------------
  // Integration Mode Trigger Register (ITTRIGGER) - 0xEE8
  //---------------------------------------------------------------------------
  assign ittrigger_we = reg_p_write & ittrigger_sel;

  //---------------------------------------------------------------------------
  // Integration Mode ATB Data0 Register (ITATBDATA0) - 0xEEC
  //---------------------------------------------------------------------------
  assign itatbdata0_we = reg_p_write & itatbdata0_sel;

  //---------------------------------------------------------------------------
  // Integration Mode ATB Control2 Register (ITATBCTR2) - 0xEF0
  //---------------------------------------------------------------------------
  assign itatbctr2_rd_data[31:0] = {{30{1'b0}},   // 31:2
                                     afvalid_reg, // 1
                                     atready_reg  // 0
                                   };

  //---------------------------------------------------------------------------
  // Integration Mode ATB Identification Register (ITATBID) - 0xEF4
  //---------------------------------------------------------------------------
  assign itatbid_we = reg_p_write & itatbid_sel;

  //---------------------------------------------------------------------------
  // Integration Mode ATB Control0 Register (ITATBCTR0) - 0xEF8
  //---------------------------------------------------------------------------
  assign itatbctr0_we = reg_p_write & itatbctr0_sel;

  //---------------------------------------------------------------------------
  // Integration Mode Control Register (ITCTRL)
  //---------------------------------------------------------------------------
  assign itcl_we  = reg_p_write & itctl_sel;
  assign nxt_itcl = pwdatadbg_r_i[0];

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      itctl_reg <= 1'b0;
    else if(itcl_we)
      itctl_reg <= nxt_itcl;
   end

  assign itctl_rd_data[31:0] = {{31{1'b0}},  // 31:1
                                itctl_reg    // 0
                               };

  //---------------------------------------------------------------------------
  // Claim Tag Set Register (CLAIMSET)
  // Claim Tag Clear Register (CLAIMCLR)
  //---------------------------------------------------------------------------
  assign claim_tag_we = reg_p_write & (claimset_sel | claimclr_sel);

  // On claim set write claim_tag_reg is ORed with APB write data
  // On claim clear write claim_tag_reg is ANDed with inverted APB write data
  assign nxt_claim_tag[3:0] = claimset_sel ?
                             (claim_tag_reg[3:0] |  pwdatadbg_r_i[3:0]):
                             (claim_tag_reg[3:0] & ~pwdatadbg_r_i[3:0]);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      claim_tag_reg[3:0] <= {4{1'b0}};
    else if(claim_tag_we)
      claim_tag_reg[3:0] <= nxt_claim_tag[3:0];
  end

  assign claimset_rd_data[31:0] = {{28{1'b0}},         // 31:4
                                   STMCLAIMTAG[3:0]       // 3:0
                                  };
  assign claimclr_rd_data[31:0] = {{28{1'b0}},         // 31:4
                                   claim_tag_reg[3:0]  // 3:0
                                  };
  //---------------------------------------------------------------------------
  // Lock Access Register (LAR)
  // Write to LAR is only enabled when the PADDRDBG31 is low
  //---------------------------------------------------------------------------
  assign lar_we = reg_write_en_i & lar_sel & ~paddrdbg31_r_i;

  assign nxt_dev_unlocked = (pwdatadbg_r_i[31:0] == 32'hC5ACCE55);

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      device_unlocked_reg <= 1'b0;
    else if(lar_we)
      device_unlocked_reg <= nxt_dev_unlocked;
  end

  //---------------------------------------------------------------------------
  // Lock Status Register (LSR)
  //---------------------------------------------------------------------------
  assign lsr_rd_data = paddrdbg31_r_i ? {32{1'b0}} :
                                        {{29{1'b0}},            // 31:3
                                         STMLSR_8BIT,              // 2
                                         ~device_unlocked_reg,  // 1
                                         STMLSR_PRESENT            // 0
                                        };

  //---------------------------------------------------------------------------
  // Authentication Status Register (AUTHSTATUS)
  //---------------------------------------------------------------------------

  // Authentication signals decode
  // Table 9-2 and Table 3-7 CoreSight Architecture
  assign sec_invasive     = spiden_r_i & dbgen_r_i;
  assign nsec_invasive    = dbgen_r_i;
  assign sec_noninvasive  = (spniden_r_i | spiden_r_i) & (niden_r_i | dbgen_r_i);
  assign nsec_noninvasive = niden_r_i | dbgen_r_i;

  assign authstatus_rd_data[31:0] = {{24{1'b0}},       // 31:8
                                     1'b1,             // 7
                                     sec_noninvasive,  // 6
                                     1'b1,             // 5
                                     sec_invasive,     // 4
                                     1'b1,             // 3
                                     nsec_noninvasive, // 2
                                     1'b1,             // 1
                                     nsec_invasive     // 0
                                    };

  //---------------------------------------------------------------------------
  // Device Architecture Register (DEVARCH)
  //---------------------------------------------------------------------------
  generate
    if (STM_DATA_WIDTH == 64)
      assign devarch_rd_data[31:0] = STMDEVARCH[31:0];
  endgenerate

  //---------------------------------------------------------------------------
  // Device Configuration Register (DEVID)
  //---------------------------------------------------------------------------
  assign devid_rd_data[31:0] = {{15{1'b0}},           // 31:17
                                STMDEVID_NUMSP[16:0]  // 16:0
                               };

  //---------------------------------------------------------------------------
  // Device Type Identifier Register (DEVTYPE)
  //---------------------------------------------------------------------------
  assign devtype_rd_data[31:0] = {{24{1'b0}},      // 31:8
                                  STMDEVTYPE[7:0]  // 7:0
                                 };

  //---------------------------------------------------------------------------
  // Peripheral ID0 Register (PID0)
  //---------------------------------------------------------------------------
  generate
    if (STM_DATA_WIDTH == 64)
      assign periphid0_rd_data[31:0] = {{24{1'b0}},      // 31:8
                                        STMPID0_64[7:0]  // 7:0
                                       };
  endgenerate

  //---------------------------------------------------------------------------
  // Peripheral ID1 Register (PID1)
  //---------------------------------------------------------------------------
  assign periphid1_rd_data[31:0] = {{24{1'b0}},    // 31:8
                                    STMPID1[7:0]   // 7:0
                                   };

  //---------------------------------------------------------------------------
  // Peripheral ID2 Register (PID2)
  //---------------------------------------------------------------------------
  generate
    if (STM_DATA_WIDTH == 64)
      assign periphid2_rd_data[31:0] = {{24{1'b0}},       // 31:8
                                        STMPID2_64[7:0]   // 7:0
                                       };
  endgenerate

  //---------------------------------------------------------------------------
  // Peripheral ID3 Register (PID3)
  //---------------------------------------------------------------------------
  assign periphid3_rd_data[31:0] = {{24{1'b0}},             // 31:8
                                    revand_i[3:0],          // 7:4
                                    STMPID3_CUSTOM[3:0]     // 3:0
                                   };

  //---------------------------------------------------------------------------
  // Peripheral ID4 Register (PID4)
  //---------------------------------------------------------------------------
  assign periphid4_rd_data[31:0] = {{24{1'b0}},    // 31:8
                                    STMPID4[7:0]   // 7:0
                                   };

  //---------------------------------------------------------------------------
  // Peripheral ID5 Register (PID5)
  //---------------------------------------------------------------------------
  assign periphid5_rd_data[31:0] = {{24{1'b0}},    // 31:8
                                    STMPID5[7:0]   // 7:0
                                   };

  //---------------------------------------------------------------------------
  // Peripheral ID6 Register (PID6)
  //---------------------------------------------------------------------------
  assign periphid6_rd_data[31:0] = {{24{1'b0}},    // 31:8
                                    STMPID6[7:0]   // 7:0
                                   };

  //---------------------------------------------------------------------------
  // Peripheral ID7 Register (PID7)
  //---------------------------------------------------------------------------
  assign periphid7_rd_data[31:0] = {{24{1'b0}},    // 31:8
                                    STMPID7[7:0]   // 7:0
                                   };


  //---------------------------------------------------------------------------
  // Component ID0 Register (CID0)
  //---------------------------------------------------------------------------
  assign compid0_rd_data[31:0]  = {{24{1'b0}},    // 31:8
                                   STMCID0[7:0]   // 7:0
                                  };

  //---------------------------------------------------------------------------
  // Component ID1 Register (CID1)
  //---------------------------------------------------------------------------
  assign compid1_rd_data[31:0]  = {{24{1'b0}},    // 31:8
                                   STMCID1[7:0]   // 7:0
                                  };

  //---------------------------------------------------------------------------
  // Component ID2 Register (CID2)
  //---------------------------------------------------------------------------
  assign compid2_rd_data[31:0]  = {{24{1'b0}},    // 31:8
                                   STMCID2[7:0]   // 7:0
                                  };

  //---------------------------------------------------------------------------
  // Component ID3 Register (CID3)
  //---------------------------------------------------------------------------
  assign compid3_rd_data[31:0]  = {{24{1'b0}},    // 31:8
                                   STMCID3[7:0]   // 7:0
                                  };



  //---------------------------------------------------------------------------
  // Clock is requested when STM is enabled or it is busy
  // deleyed en_reg is present because of busy registering and case
  // when data (AXI or HW) is one cycle before en_reg goes low
  // Clock is also on in integration mode and when it is forced with STMAUXCR.CLKON
  //---------------------------------------------------------------------------
  assign stm_clk_req = en_reg | en_dly_reg | busy_reg | clkon_reg | itctl_reg;


  //---------------------------------------------------------------------------
  // Register timestamp on input for timing reasons
  //---------------------------------------------------------------------------

  assign tsvalue_we = tsen_reg | tgu_busy_i | hw_busy_i | axi_busy_i;

  always @(posedge clk_gated)
  begin
    if (tsvalue_we)
      tsvalue_reg[63:0] <= TSVALUE[63:0];
  end

  //---------------------------------------------------------------------------
  // APB read data mux
  //---------------------------------------------------------------------------
  generate
    if (STM_DATA_WIDTH == 64) begin : gen_read_mux_64
      assign read_mux_ctl[45:0] = {compid3_sel,
                                   compid2_sel,
                                   compid1_sel,
                                   compid0_sel,
                                   periphid7_sel,
                                   periphid6_sel,
                                   periphid5_sel,
                                   periphid4_sel,
                                   periphid3_sel,
                                   periphid2_sel,
                                   periphid1_sel,
                                   periphid0_sel,
                                   devtype_sel,
                                   devid_sel,
                                   devarch_sel,
                                   authstatus_sel,
                                   lsr_sel,
                                   claimclr_sel,
                                   claimset_sel,
                                   itctl_sel,
                                   itatbctr2_sel,
                                   stmfeat3r_sel,
                                   stmfeat2r_sel,
                                   stmfeat1r_sel,
                                   auxcr_sel,
                                   syncr_sel,
                                   tsfreqr_sel,
                                   tcsr_sel,
                                   trigcsr_sel,
                                   spmoverrider_sel,
                                   spoverrider_sel,
                                   spmscr_sel,
                                   spscr_sel,
                                   spter_sel,
                                   sper_sel,
                                   heidr_sel,
                                   hefeat1r_sel,
                                   hemastr_sel,
                                   heextmuxr_sel,
                                   hemcr_sel,
                                   hebsr_sel,
                                   heter_sel,
                                   heer_sel,
                                   dmaidr_sel,
                                   dmactlr_sel,
                                   dmastatr_sel
                                   };

      always @* begin
        case (read_mux_ctl[45:0])
          46'h00_00_00_00_00_00: read_data[31:0] = {32{1'b0}};
          46'h00_00_00_00_00_01: read_data[31:0] = dmastatr_rd_data[31:0];
          46'h00_00_00_00_00_02: read_data[31:0] = dmactlr_rd_data[31:0];
          46'h00_00_00_00_00_04: read_data[31:0] = dmaidr_rd_data[31:0];
          46'h00_00_00_00_00_08: read_data[31:0] = heer_rd_data[31:0];
          46'h00_00_00_00_00_10: read_data[31:0] = heter_rd_data[31:0];
          46'h00_00_00_00_00_20: read_data[31:0] = hebsr_rd_data[31:0];
          46'h00_00_00_00_00_40: read_data[31:0] = hemcr_rd_data[31:0];
          46'h00_00_00_00_00_80: read_data[31:0] = heextmuxr_rd_data[31:0];
          46'h00_00_00_00_01_00: read_data[31:0] = hemastr_rd_data[31:0];
          46'h00_00_00_00_02_00: read_data[31:0] = hefeat1r_rd_data[31:0];
          46'h00_00_00_00_04_00: read_data[31:0] = heidr_rd_data[31:0];
          46'h00_00_00_00_08_00: read_data[31:0] = sper_rd_data[31:0];
          46'h00_00_00_00_10_00: read_data[31:0] = spter_rd_data[31:0];
          46'h00_00_00_00_20_00: read_data[31:0] = spscr_rd_data[31:0];
          46'h00_00_00_00_40_00: read_data[31:0] = spmscr_rd_data[31:0];
          46'h00_00_00_00_80_00: read_data[31:0] = spoverrider_rd_data[31:0];
          46'h00_00_00_01_00_00: read_data[31:0] = spmoverrider_rd_data[31:0];
          46'h00_00_00_02_00_00: read_data[31:0] = trigcsr_rd_data[31:0];
          46'h00_00_00_04_00_00: read_data[31:0] = tcsr_rd_data[31:0];
          46'h00_00_00_08_00_00: read_data[31:0] = tsfreqr_rd_data[31:0];
          46'h00_00_00_10_00_00: read_data[31:0] = syncr_rd_data[31:0];
          46'h00_00_00_20_00_00: read_data[31:0] = auxcr_rd_data[31:0];
          46'h00_00_00_40_00_00: read_data[31:0] = stmfeat1r_rd_data[31:0];
          46'h00_00_00_80_00_00: read_data[31:0] = stmfeat2r_rd_data[31:0];
          46'h00_00_01_00_00_00: read_data[31:0] = stmfeat3r_rd_data[31:0];
          46'h00_00_02_00_00_00: read_data[31:0] = itatbctr2_rd_data[31:0];
          46'h00_00_04_00_00_00: read_data[31:0] = itctl_rd_data[31:0];
          46'h00_00_08_00_00_00: read_data[31:0] = claimset_rd_data[31:0];
          46'h00_00_10_00_00_00: read_data[31:0] = claimclr_rd_data[31:0];
          46'h00_00_20_00_00_00: read_data[31:0] = lsr_rd_data[31:0];
          46'h00_00_40_00_00_00: read_data[31:0] = authstatus_rd_data[31:0];
          46'h00_00_80_00_00_00: read_data[31:0] = devarch_rd_data[31:0];
          46'h00_01_00_00_00_00: read_data[31:0] = devid_rd_data[31:0];
          46'h00_02_00_00_00_00: read_data[31:0] = devtype_rd_data[31:0];
          46'h00_04_00_00_00_00: read_data[31:0] = periphid0_rd_data[31:0];
          46'h00_08_00_00_00_00: read_data[31:0] = periphid1_rd_data[31:0];
          46'h00_10_00_00_00_00: read_data[31:0] = periphid2_rd_data[31:0];
          46'h00_20_00_00_00_00: read_data[31:0] = periphid3_rd_data[31:0];
          46'h00_40_00_00_00_00: read_data[31:0] = periphid4_rd_data[31:0];
          46'h00_80_00_00_00_00: read_data[31:0] = periphid5_rd_data[31:0];
          46'h01_00_00_00_00_00: read_data[31:0] = periphid6_rd_data[31:0];
          46'h02_00_00_00_00_00: read_data[31:0] = periphid7_rd_data[31:0];
          46'h04_00_00_00_00_00: read_data[31:0] = compid0_rd_data[31:0];
          46'h08_00_00_00_00_00: read_data[31:0] = compid1_rd_data[31:0];
          46'h10_00_00_00_00_00: read_data[31:0] = compid2_rd_data[31:0];
          46'h20_00_00_00_00_00: read_data[31:0] = compid3_rd_data[31:0];
          // all other cases are illegal, read mux control is zero or one hot, assertion present - uzovl_0
          // VCS coverage off
          default: read_data[31:0] = {32{1'bx}};
          // VCS coverage on
        endcase
      end

    end

  endgenerate

  //----------------------------------------------------------------------------
  // STM Reset Behaviour
  //----------------------------------------------------------------------------

  //When STMRESETn is asserted the TGU and TGU SKID Buffers in the AXI Interface
  //must be flushed to ensure the accepted packets are dropped as part of the
  //reset (the AXI will prevent further packets from being accepted since the
  //STM will be disabled)

  //axi_buf_clr_we ensures axi_buf_clr_reg is flopped only once after reset
  //to minimise idle power
  assign axi_buf_clr_we = (axi_buf_clr_reg == 1'b1);

  always @(posedge clk_gated or negedge STMRESETn)
    begin
      if (~STMRESETn)
        axi_buf_clr_reg <= 1'b1;
      else if (axi_buf_clr_we)
        axi_buf_clr_reg <= 1'b0;
    end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  // APB read data
  assign read_data_o[31:0]  = read_data[31:0];

  // Clock request
  assign stm_clk_req_o = stm_clk_req;

  // AXI control interface
  // AXI is enabled when STM is enabled
  assign axi_enable_o = en_reg;
  // port enable control
  assign axi_sper_o[31:0]    = sper_reg[31:0];
  assign axi_spter_o[31:0]   = spter_reg[31:0];
  assign axi_banksel_o[11:0] = banksel_reg[11:0];
  assign axi_portctl_o[1:0]  = portctl_reg[1:0];
  assign axi_mastsel_o[7:0]  = mastsel_reg[7:0];
  assign axi_mastctl_o       = mastctl_reg;
  // override enable control
  assign axi_overportsel_o[16:0] = overportsel_reg[16:0];
  assign axi_overts_o            = overts_reg;
  assign axi_overportctl_o[1:0]  = overportctl_reg[1:0];
  assign axi_overmastsel_o[7:0]  = overmastsel_reg[7:0];
  assign axi_overmastctl_o       = overmastctl_reg;
  // force timestamp
  assign axi_forcets_o = forcets_reg;
  // buffer clear
  assign axi_buf_clr_o = axi_buf_clr_reg;
  // trigger enable
  assign axi_singleshot_o     = trigctlspte_reg;
  assign axi_trigstatusspte_o = trigstatusspte_reg;

  generate
  if (HWEVOBIF_PRESENT == 1)
  begin : gen_hw_output
    // HW control interface
    // HW is enabled when STM is enabled and STMHEMCR.HWEN is set
    assign hw_enable_o = en_reg & hemcr_reg[0];
    // event enable control
    assign hw_heer_o[STM_DATA_WIDTH-1:0]     = heer_reg[STM_DATA_WIDTH-1:0];
    assign hw_heter_o[STM_DATA_WIDTH-1:0]    = heter_reg[STM_DATA_WIDTH-1:0];
    assign hw_heextmux_o[7:0]  = heextmuxr_reg[7:0];
    assign hw_singleshot_o     = trigctlhete_reg;
    assign hw_trigstatushete_o = trigstatushete_reg;
    // error detection control
    assign hw_errdetect_o = hemcr_reg[2];
    // hw event compression control
    assign tgu_cfg_hwcompen_o = hemcr_reg[1];
  end
  else
  begin : gen_no_hw_output
    // HW control interface
    assign hw_enable_o = 1'b0;
    // event enable control
    assign hw_heer_o[STM_DATA_WIDTH-1:0]     = {STM_DATA_WIDTH{1'b0}};
    assign hw_heter_o[STM_DATA_WIDTH-1:0]    = {STM_DATA_WIDTH{1'b0}};
    assign hw_heextmux_o[7:0]  = {8{1'b0}};
    assign hw_singleshot_o     = 1'b0;
    assign hw_trigstatushete_o = 1'b0;
    // error detection control
    assign hw_errdetect_o = 1'b0;
    // hw event compression control
    assign tgu_cfg_hwcompen_o = 1'b0;
  end
  endgenerate

  // DMA control interface
  // DMA is enabled when STM is enabled and DMA transfer has been started
  assign dma_enable_o = en_reg & dma_enable_reg;
  // fifo level sensitivity
  assign dma_sens_o[1:0] = dma_sens_reg[1:0];

  // TGU control interface
  assign tgu_cfg_enable_o = en_reg;
  // atb controls
  assign tgu_cfg_traceid_o[6:0] = traceid_reg[6:0];
  // timestamp control
  assign tgu_cfg_tsen_o = tsen_reg;
  assign tgu_cfg_tsfreqr_o[31:0] = tsfreqr_reg[31:0];
  // compression control
  assign tgu_cfg_spcompen_o = sp_compen_reg;
  // synchronization request (only when STM is enabled, not in Q_STOPPED, and (NIDEN | DBGEN)
  assign syncreq_o = sync_combined & en_reg & ~q_stopped_i & nsec_noninvasive;
  assign stm_enable_syncreq_o = stm_enabled_sync;
  // auxiliary controls
  assign tgu_cfg_asyncpe_o    = asyncpe_reg;
  assign tgu_cfg_fifoaf_o     = fifoaf_reg;
  assign tgu_cfg_freadyhigh_o = freadyhigh_reg;

  // timesatmp value
  assign tsvalue_o[63:0] = tsvalue_reg[63:0];

  // Arbiter control interface
  assign arb_atbtrigenspte_o = atbtrigenspte_reg;
  assign arb_atbtrigensw_o   = atbtrigensw_reg;

  generate
    if (HWEVOBIF_PRESENT == 1) begin : gen_hw_arb_output
       assign arb_atbtrigenhete_o = atbtrigenhete_reg;
       assign arb_flushprinvdis_o = flushprinvdis_reg;

    end else begin : gen_no_hw_arb_output
       assign arb_atbtrigenhete_o = 1'b0;
       assign arb_flushprinvdis_o = 1'b0;

    end
  endgenerate

  // Integration testing
  assign itctl_o         = itctl_reg;
  assign ittrigger_we_o  = ittrigger_we;
  assign itatbdata0_we_o = itatbdata0_we;
  assign itatbid_we_o    = itatbid_we;
  assign itatbctr0_we_o  = itatbctr0_we;

  assign qhwevoverride_o = qhwevoverride_reg;
  assign qforcedeny_o    = qforcedeny_reg;


  generate
  if (HWEVOBIF_PRESENT == 0)
  begin : gen_unused
    wire unused_ok;
    assign unused_ok = &{1'b0,
                         triggerhete_i,
                         1'b0};
  end
  endgenerate


`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  generate
    if (STM_DATA_WIDTH == 64) begin : gen_ovl_read_mux_64
      assert_zero_one_hot #(`OVL_FATAL,46,`OVL_ASSERT,"Output read mux control must be one hot")
        ovl_zero_one_hot_regfile_read_mux (
          .clk       (clk_gated),
          .reset_n   (STMRESETn),
          .test_expr (read_mux_ctl[45:0])
        );
    end
  endgenerate

  assert_never #(`OVL_WARNING,`OVL_ASSERT,"TRACEID should not be changed when STM is enabled")
    ovl_never_regfile_traceid_stable (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr ((traceid_reg[6:0] != pwdatadbg_r_i[22:16]) & tcsr_we & en_reg)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "inreg_we is X")
    ovl_never_unknown_regfile_inreg_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (inreg_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "stm_clk_req is X")
    ovl_never_unknown_regfile_stm_clk_req (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (stm_clk_req)
    );

  assert_never_unknown #(`OVL_FATAL, 18, `OVL_ASSERT, "reg write_enables are X")
    ovl_never_unknown_regfile_write_enables (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr ({dma_enable_we,
                   dmactlr_we,
                   sper_we,
                   spter_we,
                   spscr_we,
                   spmscr_we,
                   spoverrider_we,
                   spmoverrider_we,
                   tcsr_we,
                   en_we,
                   forcets_we,
                   trigcsr_we,
                   tsfreqr_we,
                   syncr_we,
                   auxcr_we,
                   itcl_we,
                   claim_tag_we,
                   lar_we}
      )
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trigstatusspte_we is X")
    ovl_never_unknown_regfile_trigstatusspte_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (trigstatusspte_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "sync_cnt_we is X")
    ovl_never_unknown_regfile_sync_cnt_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (sync_cnt_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "sync_cnt_aux_we is X")
    ovl_never_unknown_regfile_sync_cnt_aux_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (sync_cnt_aux_we)
    );

  assert_never_unknown #(`OVL_FATAL, 16, `OVL_ASSERT, "sync_cnt_aux_reload_value is X")
    ovl_never_unknown_regfile_sync_cnt_aux_reload_value (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (sync_cnt_aux_reload_value)
    );

  generate
  if (HWEVOBIF_PRESENT == 1) begin : gen_hw_ovl
    if (STM_DATA_WIDTH == 64) begin : gen_hw_ovl_64
      assert_never_unknown #(`OVL_FATAL, 5, `OVL_ASSERT, "HW reg write_enables are X")
        ovl_never_unknown_regfile_hw_write_enables (
          .clk       (clk_gated),
          .reset_n   (STMRESETn),
          .qualifier (1'b1),
          .test_expr ({heer_we,
                       heter_we,
                       hemcr_we,
                       hebsr_we,
                       heextmuxr_we}
          )
        );
    end

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "trigstatushete_we is X")
    ovl_never_unknown_regfile_trigstatushete_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (trigstatushete_we)
    );

  end
  endgenerate

`endif

endmodule // cxstm500_regfile
