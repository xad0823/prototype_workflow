//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2012, 2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   CORTEX-M3 Processor Integration Level (PIL) for CoreSight SoC
//
//------------------------------------------------------------------------------

module css600_cortexm3integrationcs #(
  //----------------------------------------------------------------------------
  // Parameters
  //
  //   The user-configurable parameters are as follows, and are declared in the
  //   order given.
  //
  //   1. MPU_PRESENT
  //
  //        MPU present or not.  Set to 1 to include the MPU, or 0 to exclude
  //        the MPU.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //
  //   2. NUM_IRQ
  //
  //        Number of interrupts.
  //
  //        Valid values:  1 to 240
  //        Default value: 16
  //
  //
  //   3. LVL_WIDTH
  //
  //        Interrupt priority width.
  //
  //        Valid values:  3 to 8
  //        Default value: 3
  //
  //
  //   4. TRACE_LVL
  //
  //        Trace support level.
  //
  //        Valid values:
  //          0 => No trace. No ETM, ITM or DWT triggers and
  //               counters.
  //          1 => Standard trace. ITM and DWT triggers and
  //               counters, but no ETM.
  //          2 => Full trace. Standard trace plus ETM.
  //          3 => Full trace plus HTM port.
  //
  //          This parameter does not affect watchpoints, and
  //          must be 0 if DBG_LEVEL is 0.
  //
  //        Default value: 1
  //
  //
  //   5. DEBUG_LVL
  //
  //        Debug support level.
  //
  //        Valid values:
  //          0 => No debug.  No DAP, breakpoints,
  //               watchpoints, flash patch or halting debug.
  //          1 => Minimum debug.  2 breakpoints,
  //               1 watchpoint, no flash patch.
  //          2 => Full debug minus DWT data matching.
  //          3 => Full debug plus DWT data matching.
  //
  //          When DBG_LEVEL = 1, only one comparator is
  //          implemented in the DWT and this therefore only
  //          allows one watchpoint but also only one trigger
  //          for trace.
  //
  //          Halting debug includes halt, step, MASKINTS,
  //          SNAPSTALL, DbgTmp register and associated
  //          transfer logic and vector catch.
  //
  //          DBG_LEVEL < 3 removes the DATAVADDR0,
  //          DATAVADDR1, DATAVSIZE and DATAVMATCH registers
  //          which are present in the DWT Function
  //          Register 1.
  //
  //        Default value: 3
  //
  //
  //
  //   6. CLKGATE_PRESENT
  //
  //        Architectural clock gating instantiated.  Set to 1 to include, or 0
  //        to not.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //
  //   7. RESET_ALL_REGS
  //
  //        Reset all registers.  Set to 1 to apply reset to all registers, even
  //        if not functionally required.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //   8. WIC_PRESENT
  //
  //        WIC present or not.  Set to 1 to include the WIC, or 0 to exclude
  //        the WIC.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //
  //   9. WIC_LINES
  //
  //        Number of available WIC lines.
  //
  //        Valid values:  3 to 243
  //
  //          If 3, WICMASKNMI, WICMASKMON and WICMASKRXEV are
  //          driven.  If more than 3, WICMASKISR is also
  //          driven.
  //
  //        Default value: 3
  //
  //   10. BB_PRESENT
  //
  //        Bit banding present or not.  Set to 1 to include the bit banding
  //        logic, or 0 to exclude it.
  //
  //        Valid values:  0, 1
  //        Default value: 1
  //
  //   11. CONST_AHB_CTRL
  //
  //        Constant AHB control information during wait-stated transfers.
  //        Set to 1 to include the required logic, or 0 to exclude it.
  //
  //        Note: setting CONST_AHB_CTRL decreases performance in wait-stated
  //              systems. Please see the IIM for more information.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //   12. ETM_PRESENT
  //
  //        ETM present or not.  Set to 1 to include the ETM, or 0 to exclude
  //        the ETM.
  //
  //        Note: Cortex-M3 processor can be licensed with ETM and without ETM
  //              so a designer might not have access to the Cortex-M3 ETM.
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //   13.  OBSERVATION
  //
  //        Allows some of the internal control signals to be exported from
  //        within the processor if set to 1
  //
  //        Valid values:  0, 1
  //        Default value: 0
  //
  //   14. EXTRA_ROM_ENTRY
  //
  //       Allow the user to specify a single entry in the PIL ROM table which
  //       will point to a ROM Table or debug component on the PPB bus (or other interface)
  //
  //        Valid values:  0 to 32'hFFFFFFFF (lower 2 bits should be 00, or 11)
  //        Default value: 0x000000000
  //
  //
  //
  //----------------------------------------------------------------------------

  parameter MPU_PRESENT     = 0,
  parameter NUM_IRQ         = 16,
  parameter LVL_WIDTH       = 3,
  parameter TRACE_LVL       = 1,
  parameter DEBUG_LVL       = 3,
  parameter CLKGATE_PRESENT = 0,
  parameter RESET_ALL_REGS  = 0,
  parameter WIC_PRESENT     = 0,
  parameter WIC_LINES       = 3,
  parameter BB_PRESENT      = 1,
  parameter CONST_AHB_CTRL  = 0,
  parameter ETM_PRESENT     = 0,
  parameter OBSERVATION     = 0,
  parameter EXTRA_ROM_ENTRY = 32'h00000000

)
(

  // ------------------------------------------------
  // Inputs
  // ------------------------------------------------
  // Resets
  input  wire           po_reset_n,         // Power on reset - reset processor and debug. Synchronous to f_clk and h_clk
  input  wire           sys_reset_n,        // System reset   - reset processor only. Synchronous to f_clk and h_clk
  input  wire           dap_reset_n,        // DAP reset      - reset DAP bus interface in AHB-AP
  input  wire           cti_reset_n,        // CTI reset      - Synchronous to f_clk and h_clk

  // Configuration - system
  input  wire           big_end,            // Big Endian - select when exiting system reset
  input  wire           mpu_disable,        // Disable MPU functionality
  input  wire           d_not_i_trans,      // I-CODE & D-CODE merging configuration.
                                            // Set to 1 when using cm3_code_mux to merge I-CODE and D-CODE
                                            // This disable I-CODE from generating a transfer when D-CODE bus need a transfer

  // Configuration - debug
  input  wire           dbgen,              // Halting Debug Enable
  input  wire           niden,              // Non-invasive debug enable for ETM
  input  wire           fix_master_type,    // Override HMASTER for AHB-AP accesses
  input  wire           etm_fifo_full_en,   // Enable ETM FIFIO FULL feature (stall processor when ETM FIFO is full)


  // Configuration - test
  input  wire           dftrstdisable,      // Reset bypass - disable internal generated reset for testing (e.g. ATPG)
  input  wire           dftcgen,            // Architectural Clock gating bypass - disable internal clock gating for testing (e.g. ATPG)
  input  wire           dftse,              // Scan enable

  // Clocks
  input  wire           f_clk,              // Free running clock - NVIC, SysTick, debug
  input  wire           h_clk,              // System clock - AHB, processor
  input  wire           dap_clk,            // DAP / AHB-AP bus interface clock (can be async to system clock)
  input  wire           cti_clk,            // CTI clock - Synchronous to f_clk and h_clk
                                            // it is separated so that it can be gated off when no debugger is attached

  // I-CODE Bus inputs
  input  wire           hready_i,           // I-CODE bus ready
  input  wire [31:0]    hrdata_i,           // I-CODE bus read data
  input  wire           hresp_i,            // I-CODE bus response
  input  wire           flush_i,            // Flush instruction buffer

  // D-CODE Bus inputs
  input  wire           hready_d,           // D-CODE bus ready
  input  wire [31:0]    hrdata_d,           // D-CODE bus read data
  input  wire           hresp_d,            // D-CODE bus response
  input  wire           ex_resp_d,          // D-CODE bus exclusive response

  // System Bus inputs
  input  wire           hready_sys,         // System bus ready
  input  wire [31:0]    hrdata_sys,         // System bus read data
  input  wire           hresp_sys,          // System bus response
  input  wire           ex_resp_sys,        // System bus exclusive response

  // Private Peripheral Bus (PPB) inputs
  input  wire           pready_extppb,      // PPB bus ready
  input  wire           pslverr_extppb,     // PPB bus slave error
  input  wire [31:0]    prdata_extppb,      // PPB bus read data

  // APB slave interface from the DP
  input  wire           dp_abort,           // Abort to terminate downstream cycles
  input  wire           psel_dp,            // APB slave select
  input  wire           penable_dp,         // APB transaction timing signal
  input  wire           pwrite_dp,          // APB write line
  input  wire [11:0]    paddr_dp,           // APB transfer address
  input  wire [31:0]    pwdata_dp,          // APB write data

  // ATB (Trace bus)
  input  wire           atready_etm,        // Transfer destination ready for ETM
  input  wire           atready_itm,        // Transfer destination ready for ITM

  // Cross Trigger Interface (CTI) for debug synchronisation
  input  wire [3:0]     channel_in,         // Debug channel input for CTM

  // Other inputs
  input  wire [239:0]   irq,                // Interrupts
  input  wire           int_nmi,            // Non-maskable Interrupt
  input  wire           rxev,               // Receive Event input

  input  wire           st_clk,             // External reference clock for SysTick (Not really a clock, it is sampled by DFF)
  input  wire [25:0]    st_calib,           // Calibration info for SysTick

  input  wire           sleep_hold_req_n,   // Extend Sleep request
  input  wire           wic_en_req,         // Enable WIC interface function

  input  wire [31:0]    aux_fault,          // Auxiliary Fault Status Register inputs (1 cycle pulse)

  input  wire           ext_dbg_req,        // External Debug Request
  input  wire           dbg_restart,        // Debug Restart request
                                            // In multi-core systems normally this can be tied low as the CTI
                                            // inside this module handle the debug restart request.

  input  wire [47:0]    ts_valueb,          // Binary coded timestamp value for trace
  input  wire           ts_clk_change,      // Timestamp clock ratio change
  input  wire           dbgen_ap,           // Enable DAP (AHB-AP) interface for memory accesses

  // ------------------------------------------------
  // Outputs
  // ------------------------------------------------

  // AHB I-Code bus
  output wire [31:0]    haddr_i,            // I-CODE bus address
  output wire [1:0]     htrans_i,           // I-CODE bus transfer type
  output wire [2:0]     hsize_i,            // I-CODE bus transfer size
  output wire           hwrite_i,           // I-CODE bus write not read (tied to 0)
  output wire [2:0]     hburst_i,           // I-CODE bus burst length
  output wire [3:0]     hprot_i,            // I-CODE bus protection
  output wire [1:0]     mem_attr_i,         // I-CODE bus memory attributes
  output wire [31:0]    hwdata_i,           // I-CODE bus write data (tied to 0)

  // AHB D-Code bus
  output wire [31:0]    haddr_d,            // D-CODE bus address
  output wire [1:0]     htrans_d,           // D-CODE bus transfer type
  output wire [2:0]     hsize_d,            // D-CODE bus transfer size
  output wire           hwrite_d,           // D-CODE bus write not read
  output wire [2:0]     hburst_d,           // D-CODE bus burst length
  output wire [3:0]     hprot_d,            // D-CODE bus protection
  output wire [1:0]     mem_attr_d,         // D-CODE bus memory attributes
  output wire [1:0]     hmaster_d,          // D-CODE bus master
  output wire [31:0]    hwdata_d,           // D-CODE bus write data
  output wire           ex_req_d,           // D-CODE bus exclusive request

  // AHB System bus
  output wire [31:0]    haddr_sys,          // System bus address
  output wire [1:0]     htrans_sys,         // System bus transfer type
  output wire [2:0]     hsize_sys,          // System bus transfer size
  output wire           hwrite_sys,         // System bus write not read
  output wire [2:0]     hburst_sys,         // System bus burst length
  output wire [3:0]     hprot_sys,          // System bus protection
  output wire           hmast_lock_sys,     // System bus lock
  output wire [1:0]     mem_attr_sys,       // System bus memory attributes
  output wire [1:0]     hmaster_sys,        // System bus master
  output wire [31:0]    hwdata_sys,         // System bus write data
  output wire           ex_req_sys,         // System bus exclusive request

  // Private Peripheral Bus (PPB) outputs
  output wire           psel_extppb,        // External PPB PSEL transfer control
  output wire [30:0]    paddr_extppb,       // PPB address
  output wire           paddr31_extppb,     // PPB address bit 31. It indicates debugger accesses.
  output wire           pwrite_extppb,      // PPB write control
  output wire           penable_extppb,     // PPB transfer enable control
  output wire [31:0]    pwdata_extppb,      // PPB write data

  // APB slave interface from the DP
  output wire           pready_dp,          // APB ready response
  output wire           pslverr_dp,         // APB slave error response
  output wire [31:0]    prdata_dp,          // APB read data

  // Cross Trigger Interface (CTI) for debug synchronisation
  output wire [3:0]     channel_out,        // CTI: debug event channel out for CTM
  output wire [1:0]     cti_int,            // CTI: Interrupts from CTI
  output wire [7:0]     cti_asicctrl,       // CTI: ASIC auxiliary control from CTI
                                            // Leave it open if unused
  // Controls
  output wire           sys_reset_req,      // System Reset Request
  output wire           txev,               // Transmit Event
  output wire           sleep_hold_ack_n,   // Acknowledge for sleep_hold_req_n

  output wire           wic_wakeup,         // Wake up request from WIC to PMU
  output wire           wic_en_ack,         // Acknowledge for wic_en_req - WIC operation deep sleep mode
  output wire [WIC_LINES-1:0] wic_sense,    // sensitivity list from WIC (optional, for testing)

  // Status
  output wire           halted,             // The processor is halted
  output wire           lockup,             // The processor is locked up
  output wire           sleeping,           // The processor is in sleep mode (sleep/deep sleep)
  output wire           sleepdeep,          // The processor is in deep sleep mode
  output wire [7:0]     curr_pri,           // Current exception priority

  output wire [8:0]     etm_int_num,        // Current exception number
  output wire [2:0]     etm_int_stat,       // Exception/Interrupt activation status
  output wire           etm_fifo_full,      // ETM FIFO is full

  output wire           trc_ena,            // Trace is Enabled (from SCB->DEMCR)
  output wire           etm_en,             // ETM is enabled

  // Hint signals
  output wire [3:0]     brch_stat,          // Branch State

  output wire           dbg_restarted,      // Debug Restart interface handshaking

  // ATB interface for ETM
  output wire [6:0]     atid_etm,           // ID value for trace source
  output wire           atvalid_etm,        // Transfer data valid
  output wire [7:0]     atdata_etm,         // Transfer data
  output wire           atbytes_etm,        // Transfer size (fixed to 1'b0, byte)

  output wire           afready_etm,        // ATB flush ready

  // ATB interface for ITM
  output wire [6:0]     atid_itm,           // ID value for trace source
  output wire           atvalid_itm,        // Transfer data valid
  output wire [7:0]     atdata_itm,         // Transfer data
  output wire           atbytes_itm,        // Transfer size (fixed to 1'b0, byte)

  output wire           afready_itm,        // ATB flush ready

  output wire           etm_trigger_out,    // Trigger output from ETM (to TPIU)
  output wire           etm_dbg_req,        // Debug request from ETM

  // Observation
  output wire [148:0]   internal_state,     // Observation of internal state

  // CoreSight AHB Trace Macrocell (HTM) bus capture interface
  output wire [31:0]    haddr_htm,          // HTM data HADDR
  output wire [1:0]     htrans_htm,         // HTM data HTRANS
  output wire [2:0]     hsize_htm,          // HTM data HSIZE
  output wire [2:0]     hburst_htm,         // HTM data HBURST
  output wire [3:0]     hprot_htm,          // HTM data HPROT
  output wire [31:0]    hwdata_htm,         // HTM data HWDATA
  output wire           hwrite_htm,         // HTM data HWRITE
  output wire [31:0]    hrdata_htm,         // HTM data HRDATA
  output wire           hready_htm,         // HTM data HREADY
  output wire           hresp_htm           // HTM data HRESP

);

  //----------------------------------------------------------------------------
  // Internal wires and registers
  //----------------------------------------------------------------------------

  // CTI
  wire [7:0]            cti_event_in;
  wire [7:0]            cti_event_out;

  wire                  cti_debug_req;      // Debug request from CTI
  wire                  cti_debug_restart;  // Debug restart request from CTI
  wire                  int_debug_restart;  // Debug restart request to Cortex-M3


  reg                   last_halted;
  wire                  dbg_restarted_mux;

  // Private Peripheral Segment
  wire                  psel_ppb;           // PPB APB select

  wire                  pready_ppb;         // PPB APB ready
  wire [31:0]           prdata_ppb;         // PPB APB read data
  wire                  pslverr_ppb;        // PPB APB response

  wire                  psel_etm;           // APB Select for ETM
  wire                  psel_cti;           // APB Select for CTI
  wire                  psel_rom;           // APB Select for ROM Table

  wire [31:0]           prdata_cti;         // APB Read data from CTI
  wire [31:0]           prdata_etm;         // APB Read data from ETM
  wire [31:0]           prdata_rom;         // APB Read data from ROM Table

  wire                  pready_cti;         // PPB APB ready
  wire                  pslverr_cti;        // PPB PPB APB resposne

  wire [30:0]           paddr_ppb;          // PPB address
  wire                  paddr31_ppb;        // PPB address bit 31. It indicates debugger accesses.
  wire                  pwrite_ppb;         // PPB write control
  wire                  penable_ppb;        // PPB transfer enable control
  wire [31:0]           pwdata_ppb;         // PPB write data

  // DAP interface to debug system (AHB-AP)
  wire [31:0]           dap_addr_ahb_ap;    // DAP-address for Cortex-M3
  wire [7:0]            dap_addr;           // DAP bus address to AHB-AP
                                            // Note: Only 8-bits
  wire                  dap_sel;            // DAP bus select
  wire                  dap_enable;         // Enable for DAP bus transfer
  wire                  dap_write;          // Write control for DAP bus
  wire                  dap_abort;          // Abort an on going transfer on DAP bus
  wire [31:0]           dap_wdata;          // Write data
  wire [31:0]           dap_rdata;          // Read data from AHB-AP
  wire                  dap_ready;          // Bus Ready from AHB-AP
  wire                  dap_slv_err;        // Bus response from AHB-AP

  // ETM
  wire [3:0]            etm_trigger;        // DWT generated trigger
  wire [3:0]            etm_trig_i_not_d;   // DWT generates trigger on PC match
  wire [31:1]           etm_ia;             // Instruction Address
  wire                  etm_ivalid;         // Instruction data is valid
  wire                  etm_istall;         // Stall IVALID from prev. cycle
  wire                  etm_dvalid;         // Data Matches are valid
  wire                  etm_fold;           // 2 instructions this cycle
  wire                  etm_cancel;         // Previous started instruction did not complete
  wire                  etm_ccfail;         // Instruction failed condition code
  wire                  etm_branch;         // Instruction is Branch
  wire                  etm_indirect_branch;// Instruction is indirect branch
  wire                  etm_isb;            // Instruction is ISB
  wire                  etm_flush;          // Pipe flush hint
  wire                  etm_find_br;        // Flush indirect branch
  wire                  etm_power_up;       // The ETM is powered-up
  wire [1:0]            etm_max_ext_in;     // Maximum width of ETM EXT IN
  wire [1:0]            etm_ext_in;         // ETM EXT IN (event)

  // WIC
  wire                  wic_load;           // Load IRQ/MON/NMI/RXEV sensitivity list
  wire                  wic_clear;          // Clear WIC sensitivity list
  wire [WIC_LINES-1:0]  wic_pend;           // IRQ/NMI/RXEV pended by WIC
  wire [239:0]          wic_mask_isr;       // WIC IRQ sensitivity list
  wire                  wic_mask_mon;       // WIC DBG MON sensitivity
  wire                  wic_mask_nmi;       // WIC NMI sensitivity
  wire                  wic_mask_rxev;      // WIC RXEV sensitivity
  wire [WIC_LINES-1:0]  wic_mask;           // sensitivity list from core
  wire [WIC_LINES-1:0]  wic_int;            // IRQ/NMI/RXEV input to WIC
  wire [239:0]          wic_irq_pend;       // IRQ component of wic_pend
  wire                  wic_mon_pend;       // DBG MON component of wic_pend
  wire                  wic_nmi_pend;       // NMI  pended by WIC
  wire                  wic_rxev_pend;      // RXEV pended by WIC
  wire                  wic_ds_req_n;       // WIC mode request to core
  wire                  wic_ds_ack_n;       // WIC mode acknowledge from core

  // ROM Table
  wire [31:0]           int_prdata_rom;
  wire                  pready_rom;
  wire                  pslverr_rom;

  // ETM
  wire                  int_etm_trigger_out;

  // WIC
  wire                  mst_wic_en;         // Logic removal term
  wire                  int_wake_up;        // Wake-up request from WIC
  wire                  int_wic_en_ack;     // WIC mode acknowledge from WIC
  wire [239:0]          int_int_isr;        // Incoming IRQs OR'd with WIC pended IRQs
  wire                  int_int_nmi;        // Incoming NMI  OR'd with WIC pended NMI
  wire                  int_rxev;           // Incoming RXEV OR'd with WIC pended RXEV
  wire                  int_ext_dbg_req;    // Incoming ext_dbg_req OR'd with WIC pended ext_dbg_req
  wire [242:0]          int_wic_int;        // expanded WICINT
  wire [242:0]          int_wic_mask;       // sensitivity list from core
  wire [WIC_LINES:0]    int_wic_pend;       // IRQ/NMI/RXEV pended by WIC
  wire [241:0]          int_wic_irq_pend;   // IRQ component of wic_pend (internal version)

  wire [9:0]            vect_addr;          // Reserved signal
  wire                  vect_addr_en;       // Reserved signal
  wire                  stk_align_init;     // Reserved signal - tied high
  wire [5:0]            ppb_lock;           // Reserved signal

  // Internal hresp signals
  wire [1:0]            hresp_htm_int;      // Internal HTM hresp

  // ---------------------------------------------------------------------------
  // Start of Main code
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Processor instantiation
  // ---------------------------------------------------------------------------

  CORTEXM3 #(
    .MPU_PRESENT        (MPU_PRESENT),
    .NUM_IRQ            (NUM_IRQ),
    .LVL_WIDTH          (LVL_WIDTH),
    .TRACE_LVL          (TRACE_LVL),
    .DEBUG_LVL          (DEBUG_LVL),
    .CLKGATE_PRESENT    (CLKGATE_PRESENT),
    .RESET_ALL_REGS     (RESET_ALL_REGS),
    .WIC_PRESENT        (WIC_PRESENT),
    .WIC_LINES          (WIC_LINES),
    .BB_PRESENT         (BB_PRESENT),
    .CONST_AHB_CTRL     (CONST_AHB_CTRL),
    .OBSERVATION        (OBSERVATION)
  ) u_cortexm3 (
    // Inputs
    .PORESETn           (po_reset_n),
    .SYSRESETn          (sys_reset_n),
    .DAPRESETn          (dap_reset_n),
    .RSTBYPASS          (dftrstdisable),
    .CGBYPASS           (dftcgen),

    .FCLK               (f_clk),
    .HCLK               (h_clk),
    .DAPCLKEN           (1'b1),
    .DAPCLK             (dap_clk),

    .BIGEND             (big_end),
    .FIXMASTERTYPE      (fix_master_type),
    .DNOTITRANS         (d_not_i_trans),
    .MPUDISABLE         (mpu_disable),
    .DBGEN              (dbgen),
    .DAPEN              (dbgen_ap),
    .STKALIGNINIT       (stk_align_init),   // Reserved signal - tied high for AAPCS compliant
    .VECTADDR           (vect_addr),        // Reserved signal - tied low
    .VECTADDREN         (vect_addr_en),     // Reserved signal - tied low
    .PPBLOCK            (ppb_lock),         // Reserved signal - tied low

    .INTNMI             (int_int_nmi),
    .INTISR             (int_int_isr),
    .RXEV               (int_rxev),

    .SLEEPHOLDREQn      (sleep_hold_req_n),
    .WICDSREQn          (wic_ds_req_n),

    .STCLK              (st_clk),
    .STCALIB            (st_calib),
    .AUXFAULT           (aux_fault),

    .EDBGRQ             (int_ext_dbg_req),
    .DBGRESTART         (int_debug_restart),// Debug restart request from CTI

    .HREADYI            (hready_i),
    .HRDATAI            (hrdata_i),
    .HRESPI             ({1'b0, hresp_i}),
    .IFLUSH             (flush_i),

    .HREADYD            (hready_d),
    .HRDATAD            (hrdata_d),
    .HRESPD             ({1'b0, hresp_d}),
    .EXRESPD            (ex_resp_d),

    .HREADYS            (hready_sys),
    .HRDATAS            (hrdata_sys),
    .HRESPS             ({1'b0, hresp_sys}),
    .EXRESPS            (ex_resp_sys),

    .PRDATA             (prdata_ppb),
    .PREADY             (pready_ppb),
    .PSLVERR            (pslverr_ppb),

    .DAPADDR            (dap_addr_ahb_ap),  // From SWJ-DP. Only lowest 7-bits are used.
    .DAPSEL             (dap_sel),
    .DAPENABLE          (dap_enable),
    .DAPWRITE           (dap_write),
    .DAPABORT           (dap_abort),
    .DAPWDATA           (dap_wdata),

    .TPIUACTV           (1'b0),
    .TPIUBAUD           (1'b0),
    .TSVALUEB           (ts_valueb),
    .TSCLKCHANGE        (ts_clk_change),
    .ETMPWRUP           (etm_power_up),
    .ETMFIFOFULL        (etm_fifo_full),

    .ATREADY            (atready_itm),

    .SE                 (dftse),

    // Outputs

    .HADDRI             (haddr_i),
    .HTRANSI            (htrans_i),
    .HSIZEI             (hsize_i),
    .HBURSTI            (hburst_i),
    .HPROTI             (hprot_i),
    .MEMATTRI           (mem_attr_i),

    .HADDRD             (haddr_d),
    .HTRANSD            (htrans_d),
    .HSIZED             (hsize_d),
    .HBURSTD            (hburst_d),
    .HPROTD             (hprot_d),
    .HMASTERD           (hmaster_d),
    .MEMATTRD           (mem_attr_d),
    .EXREQD             (ex_req_d),
    .HWRITED            (hwrite_d),
    .HWDATAD            (hwdata_d),

    .HADDRS             (haddr_sys),
    .HTRANSS            (htrans_sys),
    .HWRITES            (hwrite_sys),
    .HSIZES             (hsize_sys),
    .HBURSTS            (hburst_sys),
    .HPROTS             (hprot_sys),
    .MEMATTRS           (mem_attr_sys),
    .HMASTLOCKS         (hmast_lock_sys),
    .HMASTERS           (hmaster_sys),
    .HWDATAS            (hwdata_sys),
    .EXREQS             (ex_req_sys),

    .PADDR31            (paddr31_ppb),
    .PADDR              (paddr_ppb[19:2]),
    .PSEL               (psel_ppb),
    .PENABLE            (penable_ppb),
    .PWRITE             (pwrite_ppb),
    .PWDATA             (pwdata_ppb),

    .DAPREADY           (dap_ready),
    .DAPSLVERR          (dap_slv_err),
    .DAPRDATA           (dap_rdata),

    .SYSRESETREQ        (sys_reset_req),
    .TXEV               (txev),
    .SLEEPING           (sleeping),
    .SLEEPDEEP          (sleepdeep),
    .SLEEPHOLDACKn      (sleep_hold_ack_n),
    .BRCHSTAT           (brch_stat),
    .CURRPRI            (curr_pri),

    .WICDSACKn          (wic_ds_ack_n),
    .WICLOAD            (wic_load),
    .WICCLEAR           (wic_clear),
    .WICMASKISR         (wic_mask_isr),
    .WICMASKMON         (wic_mask_mon),
    .WICMASKNMI         (wic_mask_nmi),
    .WICMASKRXEV        (wic_mask_rxev),

    .LOCKUP             (lockup),
    .HALTED             (halted),
    .DBGRESTARTED       (dbg_restarted),

    .INTERNALSTATE      (internal_state),

    .TRCENA             (trc_ena),
    .DSYNC              (),

    .ATVALID            (atvalid_itm),
    .ATIDITM            (atid_itm),
    .ATDATA             (atdata_itm),
    .AFREADY            (afready_itm),

    .ETMTRIGGER         (etm_trigger),
    .ETMTRIGINOTD       (etm_trig_i_not_d),
    .ETMIVALID          (etm_ivalid),
    .ETMISTALL          (etm_istall),
    .ETMDVALID          (etm_dvalid),
    .ETMFOLD            (etm_fold),
    .ETMCANCEL          (etm_cancel),
    .ETMIA              (etm_ia[31:1]),
    .ETMICCFAIL         (etm_ccfail),
    .ETMIBRANCH         (etm_branch),
    .ETMIINDBR          (etm_indirect_branch),
    .ETMISB             (etm_isb),
    .ETMINTSTAT         (etm_int_stat),
    .ETMINTNUM          (etm_int_num),
    .ETMFLUSH           (etm_flush),
    .ETMFINDBR          (etm_find_br),

    .HTMDHADDR          (haddr_htm),
    .HTMDHTRANS         (htrans_htm),
    .HTMDHSIZE          (hsize_htm),
    .HTMDHBURST         (hburst_htm),
    .HTMDHPROT          (hprot_htm),
    .HTMDHWDATA         (hwdata_htm),
    .HTMDHRDATA         (hrdata_htm),
    .HTMDHWRITE         (hwrite_htm),
    .HTMDHREADY         (hready_htm),
    .HTMDHRESP          (hresp_htm_int)
  );

  // Reserved signals that must always be tied to 1
  assign stk_align_init = 1'b1;

  // Reserved signals that must always be tied to 0
  assign ppb_lock       = 6'b000000;
  assign vect_addr      = 10'b0000000000;
  assign vect_addr_en   = 1'b0;

  // Tied off signals
  assign atbytes_etm    = 1'b0;             // Cortex-M3 ETM ATB is 8-bit
  assign atbytes_itm    = 1'b0;             // Cortex-M3 ITM ATB is 8-bit

  assign hwrite_i       = 1'b0;             // I-CODE bus never generates write
  assign hwdata_i       = {32{1'b0}};

  // Debug restart signal connections
  assign int_debug_restart  = dbg_restart | cti_debug_restart;

  // Only one bit of hresp is exported
  assign hresp_htm      = hresp_htm_int[0];

  // ---------------------------------------------------------------------------
  // WIC instantiation
  // ---------------------------------------------------------------------------

  // Example WIC from Cortex-M3 deliverable
  // You can replace it with a design with asynchronous operation for
  // interrupt detection when all clocks are stopped.
  cm3_wic #(
    .WIC_PRESENT (WIC_PRESENT),
    .WIC_LINES   (WIC_LINES)
  ) u_cm3_wic (
    // Inputs
    .FCLK           (f_clk),
    .RESETn         (sys_reset_n),
    .WICLOAD        (wic_load),
    .WICCLEAR       (wic_clear),
    .WICINT         (wic_int),
    .WICMASK        (wic_mask),
    .WICENREQ       (wic_en_req),
    .WICDSACKn      (wic_ds_ack_n),
    // Outputs
    .WAKEUP         (int_wake_up),
    .WICSENSE       (wic_sense),
    .WICPEND        (wic_pend),
    .WICDSREQn      (wic_ds_req_n),
    .WICENACK       (int_wic_en_ack)
  );

  // Remove filler bits from WicMask to fit WIC port
  assign int_wic_mask       = {wic_mask_isr, wic_mask_mon, wic_mask_nmi, wic_mask_rxev};
  assign wic_mask           = int_wic_mask[WIC_LINES-1:0];

  // Select incoming IRQs/EDBGRQ/NMI/RXEV used by WIC
  assign int_wic_int        = {irq, ext_dbg_req, int_nmi, rxev};
  assign wic_int            = int_wic_int[WIC_LINES-1:0];

  // Split WicPend into component IRQs/NMI/RXEV/EDBGRQ
  // the IRQ part is a bit more complex as it need to expand to 240 bits
  // add dummy MSB to WicPend to facilitate indexing
  assign int_wic_pend       = {1'b0, wic_pend};
  // Add padding bit
  assign int_wic_irq_pend   = {{244-WIC_LINES{1'b0}}, int_wic_pend[WIC_LINES:3]};
  // Extract bits
  assign wic_irq_pend       = mst_wic_en ? int_wic_irq_pend[239:0] : {240{1'b0}};

  assign wic_mon_pend       = mst_wic_en ? int_wic_pend[2]         : 1'b0;
  assign wic_nmi_pend       = mst_wic_en ? int_wic_pend[1]         : 1'b0;
  assign wic_rxev_pend      = mst_wic_en ? int_wic_pend[0]         : 1'b0;

  assign int_int_isr        = irq                       | wic_irq_pend;
  assign int_int_nmi        = int_nmi                   | wic_nmi_pend;
  assign int_rxev           = (rxev & (~wic_sense[0]))  | wic_rxev_pend;
  assign int_ext_dbg_req    = ext_dbg_req | etm_dbg_req | wic_mon_pend | cti_debug_req;

  // WIC not present logic removal terms
  assign mst_wic_en         = (WIC_PRESENT != 0) ? 1'b1           : 1'b0;
  assign wic_wakeup         = (WIC_PRESENT != 0) ? int_wake_up    : 1'b0;
  assign wic_en_ack         = (WIC_PRESENT != 0) ? int_wic_en_ack : 1'b0;


  //----------------------------------------------------------------------------
  // DAP <=> APB4 interface
  //----------------------------------------------------------------------------

  css600_apv1adapter
    u_css600_apv1adapter (
    // Clock and reset inputs
    .clk            (dap_clk),
    .reset_n        (dap_reset_n),
    // Abort input signal from DP
    .dp_abort       (dp_abort),
    // APB slave interface from the DP
    .psel_s         (psel_dp),
    .penable_s      (penable_dp),
    .pwrite_s       (pwrite_dp),
    .paddr_s        (paddr_dp),
    .pwdata_s       (pwdata_dp),
    .pready_s       (pready_dp),
    .pslverr_s      (pslverr_dp),
    .prdata_s       (prdata_dp),
    // ABP/DAP bus master interface to the v1 AP
    .dapsel_m       (dap_sel),
    .dapenable_m    (dap_enable),
    .dapwrite_m     (dap_write),
    .dapcaddr_m     (dap_addr),
    .dapwdata_m     (dap_wdata),
    .dapready_m     (dap_ready),
    .dapslverr_m    (dap_slv_err),
    .daprdata_m     (dap_rdata),
    .dapabort_m     (dap_abort)
  );

  // Form DAP address
  assign dap_addr_ahb_ap = {8'h00, 16'h0000, dap_addr[7:0]};

  //----------------------------------------------------------------------------
  // ETM instantiation - if ETM_PRESENT and TRACE_LVL set accordingly
  //----------------------------------------------------------------------------

  generate
    if (ETM_PRESENT == 1) begin: gen_etm

      // Wires only present if ETM is present
      wire        int_etm_dbg_req;
      wire        int_etm_fifo_full;
      wire        int_etm_power_up;
      wire        int_etm_en;
      wire [31:0] int_prdata_etm;
      wire [7:0]  int_atdata_etm;
      wire        int_atvalid_etm;
      wire        int_afready_etm;
      wire [6:0]  int_atid_etm;

      // ETM instantiation
      //------------------

      // ETM must be clocked only when core is clocked and if ETM interface is active.
      CM3ETM #(
       .TRACE_LVL       (TRACE_LVL),
       .CLKGATE_PRESENT (CLKGATE_PRESENT),
       .RESET_ALL_REGS  (RESET_ALL_REGS)
      ) u_cm3_etm (
        // Inputs
        .FCLK           (h_clk),
        .PORESETn       (po_reset_n),
        .NIDEN          (niden),
        .FIFOFULLEN     (etm_fifo_full_en),
        .ETMIA          (etm_ia[31:1]),
        .ETMIVALID      (etm_ivalid),
        .ETMISTALL      (etm_istall),
        .ETMDVALID      (etm_dvalid),
        .ETMFOLD        (etm_fold),
        .ETMCANCEL      (etm_cancel),
        .ETMICCFAIL     (etm_ccfail),
        .ETMIBRANCH     (etm_branch),
        .ETMIINDBR      (etm_indirect_branch),
        .ETMISB         (etm_isb),
        .ETMINTSTAT     (etm_int_stat),
        .ETMINTNUM      (etm_int_num),
        .COREHALT       (halted),
        .EXTIN          (etm_ext_in),
        .MAXEXTIN       (etm_max_ext_in),
        .DWTMATCH       (etm_trigger),
        .DWTINOTD       (etm_trig_i_not_d),
        .ATREADYM       (atready_etm),
        .PSEL           (psel_etm),
        .PENABLE        (penable_ppb),
        .PADDR          (paddr_ppb[11:2]),
        .PWRITE         (pwrite_ppb),
        .PWDATA         (pwdata_ppb),
        .TSVALUEB       (ts_valueb),
        .TSCLKCHANGE    (ts_clk_change),
        .CGBYPASS       (dftcgen),
        .SE             (dftse),
        // Outputs
        .ETMPWRUP       (int_etm_power_up),
        .ETMEN          (int_etm_en),
        .PRDATA         (int_prdata_etm),
        .ATDATAM        (int_atdata_etm[7:0]),
        .ATVALIDM       (int_atvalid_etm),
        .AFREADYM       (int_afready_etm),
        .ETMTRIGOUT     (int_etm_trigger_out),
        .ATIDM          (int_atid_etm),
        .ETMDBGRQ       (int_etm_dbg_req),
        .FIFOFULL       (int_etm_fifo_full)
      );

      // Logic to remove ETM according to the value of TRACE_LVL
      //--------------------------------------------------------

      assign etm_dbg_req     = (TRACE_LVL > 1) ? int_etm_dbg_req     : 1'b0;
      assign etm_fifo_full   = (TRACE_LVL > 1) ? int_etm_fifo_full   : 1'b0;
      assign etm_power_up    = (TRACE_LVL > 1) ? int_etm_power_up    : 1'b0;
      assign etm_en          = (TRACE_LVL > 1) ? int_etm_en          : 1'b0;
      assign prdata_etm      = (TRACE_LVL > 1) ? int_prdata_etm      : {32{1'b0}};
      assign atdata_etm      = (TRACE_LVL > 1) ? int_atdata_etm      : {8{1'b0}};
      assign atvalid_etm     = (TRACE_LVL > 1) ? int_atvalid_etm     : 1'b0;
      assign afready_etm     = (TRACE_LVL > 1) ? int_afready_etm     : 1'b1;
      assign etm_trigger_out = (TRACE_LVL > 1) ? int_etm_trigger_out : 1'b0;
      assign atid_etm        = (TRACE_LVL > 1) ? int_atid_etm        : {7{1'b0}};

    end else begin: gen_no_etm

      // ETM_PRESENT isn't set to 1, don't include it
      //---------------------------------------------

      assign etm_dbg_req     = 1'b0;
      assign etm_fifo_full   = 1'b0;
      assign etm_power_up    = 1'b0;
      assign etm_en          = 1'b0;
      assign prdata_etm      = {32{1'b0}};
      assign atdata_etm      = {8{1'b0}};
      assign atvalid_etm     = 1'b0;
      assign afready_etm     = 1'b1;
      assign etm_trigger_out = 1'b0;
      assign atid_etm        = {7{1'b0}};

    end

  endgenerate

  assign etm_max_ext_in  = 2'b10;


  // ---------------------------------------------------------------------------
  // CTI
  // ---------------------------------------------------------------------------

  // CoreSight Cross Trigger Interface
  css600_cti #(
   .NUM_EVENT_SLAVES    (8),                // Number of trigger inputs, 1-32
   .NUM_EVENT_MASTERS   (8),                // Number of trigger outputs, 1-32
   .SW_HANDSHAKE        (32'h0000_003D),    // Bitmap to enable software handshake
   .EXT_MUX_NUM         (0),                // Number of external multiplexors, 0-31
   .FF_SYNC_DEPTH       (2),                // 2/3 deep synchroniser for clk_qreq_n
   .EVENT_IN_LEVEL      (32'h0000_00F0)     // Bitmap to enable edge detect on event_in
  ) u_css600_cti (
    // Clock and Reset interface
    .clk                (cti_clk),
    .reset_n            (cti_reset_n),
    // LPI interface
    .clk_qreq_n         (1'b1),
    .clk_qaccept_n      (),
    .clk_qdeny          (),
    .clk_qactive        (),
    // APB interface
    .pwakeup_s          (1'b1),
    .psel_s             (psel_cti),
    .penable_s          (penable_ppb),
    .pwrite_s           (pwrite_ppb),
    .paddr_s            (paddr_ppb[11:0]),
    .pwdata_s           (pwdata_ppb[31:0]),
    .prdata_s           (prdata_cti[31:0]),
    .pready_s           (pready_cti),
    .pslverr_s          (pslverr_cti),
    // Trigger interface
    .event_in           (cti_event_in),
    .event_out          (cti_event_out),
    // Channel interface
    .channel_in         (channel_in),
    .channel_out        (channel_out),
    // Authentication interface
    .dbgen              (dbgen),
    .niden              (niden),
    // Miscellaneous interface
    .asicctrl           (cti_asicctrl),
    // Tie-off pins
    .tinidensel         ({8{1'b1}}),
    .todbgensel         (8'hF3),
    .devaff             ({64{1'b0}})
  );

  always @(posedge cti_clk or negedge cti_reset_n)
    if (!cti_reset_n)
      last_halted      <= 1'b0;
    else
      last_halted      <= halted;

  // EVENT_IN_LEVEL set to 1 for bits 7:4.
  assign cti_event_in[0]    = halted & ~last_halted;
  assign cti_event_in[3:1]  = 3'b000;           // Unused
  assign cti_event_in[6:4]  = etm_trigger[2:0]; // Trigger from DWT to ETM (4 bits, only lowest 3 bits are used)
  assign cti_event_in[7]    = etm_trigger_out;

  css600_pulsesyncbridgeslv_qactive_only #(
    .WIDTH         (1)
  ) u_css600_pulsesyncbridgeslv_qactive_only (
    // Clock & Reset
    .clk_s              (cti_clk),
    .reset_s_n          (cti_reset_n),
    // Pulse Signal
    .pulse_in           (cti_event_out[7]),
    // CDC Handshake Signals
    .pulse_req          (cti_debug_restart),
    .pulse_ack          (dbg_restarted_mux),
    // Clock LPI
    .clk_s_qactive      ()
  );

  assign dbg_restarted_mux    = (halted) ? ~dbg_restarted : cti_debug_restart;

  // SW_HANDSHAKE set to 1 for bits 5:2 and 0.
  // cti_event_out[7] connected to u_css600_pulseasyncbridgeslv
  // cti_event_out[6] not connected
  assign etm_ext_in[1:0] = cti_event_out[5:4]; // Handled by software
  assign cti_int[1:0]    = cti_event_out[3:2]; // Interrupt request to top level
                                               // Clear by software write to CTI Interrupt Ack Register
  // cti_event_out[1] not connected
  assign cti_debug_req        = cti_event_out[0]; // Clear by software write to CTI Interrupt Ack Register

  // ---------------------------------------------------------------------------
  // PPB bus slave multiplexer
  // ---------------------------------------------------------------------------

  // PPB address padding
  assign paddr_ppb[1:0]   = 2'b00;        // PPB support APB3 - Always aligned, word size
  assign paddr_ppb[30:20] = {11{1'b0}};   // Unused address bits

  // Address decoding
  // ETM : 0xE0041000
  assign psel_etm    = (TRACE_LVL > 1) ? (psel_ppb & (paddr_ppb[19:12]==8'h41)) : 1'b0;
  // CTI : 0xE0042000
  assign psel_cti    = (DEBUG_LVL > 0) ? (psel_ppb & (paddr_ppb[19:12]==8'h42)) : 1'b0;
  // ROM table : 0xE00FF000
  assign psel_rom    = psel_ppb & (paddr_ppb[19:12]==8'hFF);
  // External : 0xE0040000-0xE0040FFF,0xE0043000 - 0xE00FEFFF
  assign psel_extppb = psel_ppb & ~(psel_etm | psel_cti | psel_rom);
  // Note: Normally 0xE0040000-0xE0040FFF is for Cortex-M3 TPIU

  // Read data mux
  assign prdata_ppb         = ({32{psel_etm}}    & prdata_etm    ) |
                              ({32{psel_cti}}    & prdata_cti    ) |
                              ({32{psel_rom}}    & prdata_rom    ) |
                              ({32{psel_extppb}} & prdata_extppb ) ;
  // Ready mux
  assign pready_ppb         = (psel_etm                          ) |
                              (psel_cti          & pready_cti    ) |
                              (psel_rom          & pready_rom    ) |
                              (psel_extppb       & pready_extppb ) ;
  // Respond mux (only external PPB has error response)
  assign pslverr_ppb        = (psel_cti          & pslverr_cti   ) |
                              (psel_rom          & pslverr_rom   ) |
                              (psel_extppb       & pslverr_extppb) ;

  // Name changes for the external ports
  assign paddr_extppb       = paddr_ppb;
  assign paddr31_extppb     = paddr31_ppb;
  assign penable_extppb     = penable_ppb;
  assign pwrite_extppb      = pwrite_ppb;
  assign pwdata_extppb      = pwdata_ppb;

  // ---------------------------------------------------------------------------
  // ROM table instantiation
  // ---------------------------------------------------------------------------

  css600_apbrom #(
   .FF_SYNC_DEPTH           (2),
   .SYSMEM                  (1),
   .NUM_ENTRIES             (8),
   .NUM_SYSPWRUP_MASTERS    (1),
   .NUM_DBGPWRUP_MASTERS    (1),
   .TIE_OFF_PRESENT         (0),

   // ROM table entries for debug components inside the Cortex-M3 processor.
   // ----------------------------------------------------------------------

   // NVIC (0x000)
   .ROM_ENTRY0              (32'hFFF0F003),
   // DWT  (0x004)
   .ROM_ENTRY1              (32'hFFF02003),
   // FPB  (0x008)
   .ROM_ENTRY2              (32'hFFF03003),
   // ITM  (0x00C)
   .ROM_ENTRY3              ((TRACE_LVL > 0) ? 32'hFFF01003 : 32'hFFF01002),

   // The ROM table entires here are the debug components in the PIL level
   // --------------------------------------------------------------------
   // - ETM : Embedded Trace Macrocell
   // - CTI : Cross Trigger Interface
   // If the PIL design is modified, this section may also need to be updated.

   // TPIU (0x010)
   //   This location is reserved for the Cortex-M3 TPIU for the original
   //   Cortex-M3 Integration in default configuration (single processor)
   //   Since the PIL does not contain the TPIU, the LSB is set to 0.
   .ROM_ENTRY4              (32'hFFF41002),

   // ETM  (0x014)
   //   The PIL may or may not contain the ETM. This is dependent on the
   //   TRACE_LVL and ETM_PRESENT verilog parameters. The address value of the
   //   ETM is fixed by the internal address decoder on the PPB.
   .ROM_ENTRY5              (((ETM_PRESENT == 1) && (TRACE_LVL > 1)) ? 32'hFFF42003 : 32'hFFF42002),

   // CTI  (0x018) - always there if debug is present
   //   The PIL contains the CTI module for debug event communication.
   //   The address value of the ETM is fixed by the internal address
   //   decoder on the PPB.
   .ROM_ENTRY6              (32'hFFF43003),

   // Customer-definable ROM entry
   // ----------------------------

   // EXTRA_ROM_ENTRY (0x01C)
   .ROM_ENTRY7              (EXTRA_ROM_ENTRY)

  ) u_css600_apbrom (
   // Clock and reset inputs
   .clk                     (h_clk),
   .reset_n                 (po_reset_n),
   // APB slave interfaces
   .psel_s                  (psel_rom),
   .penable_s               (penable_ppb),
   .pwrite_s                (pwrite_ppb),
   .paddr_s                 (paddr_ppb[11:0]),
   .pwdata_s                (32'h00000000),
   .pready_s                (pready_rom),
   .pslverr_s               (pslverr_rom),
   .prdata_s                (int_prdata_rom),
   // Tie-off configuration signals
   .revision                (4'h1),         // Rev 1 - SoC-600 version
   .part_number             (12'h4c5),      // M3 PIL
   .jep106_id               (11'h23b),      // Arm
   .eco_rev_and             (4'b0000),
   .entry_present           (8'b0000000)    // Unused
  );

  // Debug logic removal terms (ROM table)
  assign prdata_rom = (DEBUG_LVL > 0) ? int_prdata_rom : {32{1'b0}};


endmodule
