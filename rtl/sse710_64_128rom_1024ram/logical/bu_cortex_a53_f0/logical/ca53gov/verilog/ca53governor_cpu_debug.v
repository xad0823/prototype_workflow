//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2015 ARM Limited.
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
// Description: Debug over power down wrapper
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_cpu_debug `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                CLKIN,
  input  wire                                DFTSE,
  input  wire                                npresetdbg_gov,
  input  wire                                po_reset_n_gov,
  input  wire                                gov_dbgen_i,
  input  wire                                gov_niden_i,
  input  wire                                gov_spiden_i,
  input  wire                                gov_spniden_i,
  input  wire                                dbgpwrdup_i,
  input  wire                                apb_dec_pseldbg_dbg_i,
  input  wire                                apb_dec_pseldbg_pmu_i,
  input  wire                                apb_dec_pseldbg_etm_i,
  input  wire                                apb_dec_pseldbg_cti_i,
  input  wire [ 11: 2]                       apb_bridge_paddrdbg_i,
  input  wire                                apb_bridge_paddrdbg31_i,
  input  wire                                apb_bridge_pwritedbg_i,
  input  wire [ 31: 0]                       apb_bridge_pwdatadbg_i,
  input  wire                                dpu_preadydbg_i,
  input  wire                                dpu_pslverrdbg_i,
  input  wire [ 31: 0]                       dpu_prdatadbg_i,
  input  wire                                etm_preadydbg_i,
  input  wire [ 31: 0]                       etm_prdatadbg_i,
  input  wire                                cti_preadydbg_i,
  input  wire [ 31: 0]                       cti_prdatadbg_i,
  input  wire [  1: 0]                       cpu_id_i,
  input  wire [  7: 0]                       clusteridaff1_rs_i,
  input  wire [  7: 0]                       clusteridaff2_rs_i,
  input  wire                                gov_cryptodisable_i,
  input  wire                                gov_giccdisable_i,
  input  wire                                etm_oslock_rs_i,
  input  wire                                dpu_dscr_halted_i,
  input  wire                                cpu_in_retention_i,
  // Outputs
  output wire                                gov_pseldbg_dbg_o,
  output wire                                gov_pseldbg_pmu_o,
  output wire                                gov_pseldbg_etm_o,
  output wire                                gov_pseldbg_cti_o,
  output wire                                gov_penabledbg_o,
  output wire [ 11: 2]                       gov_paddrdbg_o,
  output wire                                gov_paddrdbg31_o,
  output wire                                gov_pwritedbg_o,
  output wire [ 31: 0]                       gov_pwdatadbg_o,
  output wire                                gov_edecr_osuce_o,
  output wire                                gov_edecr_rce_o,
  output wire                                gov_edecr_ss_o,
  output wire                                gov_edlsr_slk_o,
  output wire                                gov_pmlsr_slk_o,
  output wire                                gov_etmpdsr_rd_o,
  output wire                                gov_dbgpwrupreq_o,
  output wire                                dbgpwrupreq_o,
  output wire                                preadydbg_gov_o,
  output wire                                pslverrdbg_gov_o,
  output wire [ 31: 0]                       prdatadbg_gov_o
);

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                                  apb_clk_en;
  reg                                  apb_active;
  reg                                  apb_strobe;
  reg                                  dbgpwrdup_rs;
  reg                                  dbgpwrupreq;
  reg                                  edlsr_slk;
  reg                                  pmlsr_slk;
  reg                                  etmlsr_slk;
  reg                                  edecr_ss;
  reg                                  edecr_rce;
  reg                                  edecr_osuce;
  reg                                  edprcr_corepurq;
  reg                                  etmpdcr_etmpurq;
  reg [31:0]                           prdatadbg;
  reg                                  preadydbg;
  reg                                  pslverrdbg;
  reg                                  pwritedbg_rs;
  reg [11:2]                           paddrdbg_rs;
  reg                                  paddrdbg31_rs;
  reg [31:0]                           pwdatadbg_rs;
  reg                                  pseldbg_dbg_rs;
  reg                                  pseldbg_pmu_rs;
  reg                                  pseldbg_etm_rs;
  reg                                  pseldbg_cti_rs;
  reg                                  penabledbg;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                 clk_apb;
  wire                                 nxt_apb_clk_en;
  wire                                 apb_dbg_rd_req;
  wire                                 apb_dbg_wr_strobe;
  wire                                 apb_etm_rd_req;
  wire                                 apb_etm_wr_strobe;
  wire                                 apb_interface_en;
  wire                                 apb_pmu_rd_req;
  wire                                 apb_pmu_wr_strobe;
  wire                                 apb_cti_rd_req;
  wire                                 apb_strobe_en;
  wire                                 apb_wr_edecr;
  wire                                 apb_wr_edprcr;
  wire                                 apb_wr_edlar;
  wire                                 apb_wr_pmlar;
  wire                                 apb_wr_etmlar;
  wire                                 apb_wr_etmpdcr;
  wire                                 clear_apb_strobe;
  wire [31:0]                          edecr_rd;
  wire [31:0]                          edprcr_rd;
  wire [31:0]                          edprsr_rd;
  wire [31:0]                          midr_rd;
  wire [63:0]                          id_aa64pfr0_rd;
  wire [63:0]                          id_aa64pfr1_rd;
  wire [63:0]                          id_aa64dfr0_rd;
  wire [63:0]                          id_aa64dfr1_rd;
  wire [63:0]                          id_aa64isar0_rd;
  wire [63:0]                          id_aa64isar1_rd;
  wire [63:0]                          id_aa64mmfr0_rd;
  wire [63:0]                          id_aa64mmfr1_rd;
  wire [31:0]                          edlsr_rd;
  wire [31:0]                          devarch_rd;
  wire [31:0]                          dbgauthstatus_rd;
  wire [31:0]                          devaff0_rd;
  wire [31:0]                          devaff1_rd;
  wire [31:0]                          devid0_rd;
  wire [31:0]                          devid1_rd;
  wire [31:0]                          devid2_rd;
  wire [31:0]                          eddevtype_rd;
  wire [31:0]                          edpid0_rd;
  wire [31:0]                          edpid1_rd;
  wire [31:0]                          edpid2_rd;
  wire [31:0]                          edpid3_rd;
  wire [31:0]                          edpid4_rd;
  wire [39:0]                          dbg_peripheral_id;
  wire [31:0]                          pmlsr_rd;
  wire [31:0]                          pmauthstatus_rd;
  wire [31:0]                          pmdevarch_rd;
  wire [31:0]                          pmdevtype_rd;
  wire [31:0]                          pmpid0_rd;
  wire [31:0]                          pmpid1_rd;
  wire [31:0]                          pmpid2_rd;
  wire [31:0]                          pmpid3_rd;
  wire [31:0]                          pmpid4_rd;
  wire [39:0]                          pmu_peripheral_id;
  wire                                 prdatadbg_en;
  wire [31:0]                          etmpdcr_rd;
  wire [31:0]                          etmpdsr_rd;
  wire [31:0]                          etmlsr_rd;
  wire [31:0]                          etmdevarch_rd;
  wire [31:0]                          etmdevtype_rd;
  wire [31:0]                          etmpid0_rd;
  wire [31:0]                          etmpid1_rd;
  wire [31:0]                          etmpid2_rd;
  wire [31:0]                          etmpid3_rd;
  wire [31:0]                          etmpid4_rd;
  wire [39:0]                          etm_peripheral_id;
  wire [31:0]                          ctiauthstatus_rd;
  wire [31:0]                          ctipid0_rd;
  wire [31:0]                          ctipid1_rd;
  wire [31:0]                          ctipid2_rd;
  wire [31:0]                          ctipid3_rd;
  wire [31:0]                          ctipid4_rd;
  wire [39:0]                          cti_peripheral_id;
  wire                                 gov_dbgpwrupreq;
  wire                                 nxt_apb_active;
  wire                                 nxt_lock_set;
  wire [31:0]                          nxt_prdatadbg;
  wire                                 nxt_preadydbg;
  wire                                 nxt_pslverrdbg;
  wire [31:0]                          prdatadbg_wrp;
  wire                                 set_apb_strobe;
  wire                                 core_register;
  wire                                 core_preadydbg;
  wire                                 nxt_pseldbg_dbg_rs;
  wire                                 nxt_pseldbg_pmu_rs;
  wire                                 nxt_pseldbg_etm_rs;
  wire                                 nxt_pseldbg_cti_rs;
  wire                                 nxt_penabledbg;
  wire                                 edecr_ss_en;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Generate a gated clock for the debug APB interface
  assign nxt_apb_clk_en = apb_dec_pseldbg_dbg_i |
                          apb_dec_pseldbg_pmu_i |
                          apb_dec_pseldbg_etm_i |
                          apb_dec_pseldbg_cti_i;

  always @(posedge CLKIN or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      apb_clk_en <= 1'b0;
    else
      apb_clk_en <= nxt_apb_clk_en;

  ca53_cell_inter_clkgate u_inter_clkgate_apb (
    .clk_i         (CLKIN),
    .clk_enable_i  (apb_clk_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_apb)
  );

  // Register the top-level authentication inputs
  always @(posedge CLKIN or negedge po_reset_n_gov)
    if (~po_reset_n_gov)
      dbgpwrdup_rs <= 1'b0;
    else
      dbgpwrdup_rs <= dbgpwrdup_i;

  // An APB transaction starts with PSEL going high, and ends when the core asserts PREADY
  assign nxt_apb_active = (apb_dec_pseldbg_dbg_i |
                           apb_dec_pseldbg_pmu_i |
                           apb_dec_pseldbg_etm_i |
                           apb_dec_pseldbg_cti_i) & ~preadydbg;

  assign nxt_pseldbg_dbg_rs = apb_dec_pseldbg_dbg_i & ~preadydbg & core_register & dbgpwrdup_rs & ~(penabledbg & dpu_preadydbg_i & ~cpu_in_retention_i);
  assign nxt_pseldbg_pmu_rs = apb_dec_pseldbg_pmu_i & ~preadydbg & core_register & dbgpwrdup_rs & ~(penabledbg & dpu_preadydbg_i & ~cpu_in_retention_i);
  assign nxt_pseldbg_etm_rs = apb_dec_pseldbg_etm_i & ~preadydbg & core_register & dbgpwrdup_rs & ~(penabledbg & etm_preadydbg_i & ~cpu_in_retention_i);
  assign nxt_pseldbg_cti_rs = apb_dec_pseldbg_cti_i & ~preadydbg &                                ~(penabledbg & cti_preadydbg_i);

  assign nxt_penabledbg = apb_active & (pseldbg_dbg_rs | pseldbg_pmu_rs | pseldbg_etm_rs | pseldbg_cti_rs) & ~(penabledbg & core_preadydbg) & ~preadydbg;

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov) begin
      apb_active      <= 1'b0;
      pseldbg_dbg_rs  <= 1'b0;
      pseldbg_pmu_rs  <= 1'b0;
      pseldbg_etm_rs  <= 1'b0;
      pseldbg_cti_rs  <= 1'b0;
      penabledbg      <= 1'b0;
    end else begin
      apb_active      <= nxt_apb_active;
      pseldbg_dbg_rs  <= nxt_pseldbg_dbg_rs;
      pseldbg_pmu_rs  <= nxt_pseldbg_pmu_rs;
      pseldbg_etm_rs  <= nxt_pseldbg_etm_rs;
      pseldbg_cti_rs  <= nxt_pseldbg_cti_rs;
      penabledbg      <= nxt_penabledbg;
    end

  // Register inputs on APB interface
  assign apb_interface_en = nxt_apb_active & ~apb_active;

  always @(posedge clk_apb)
    if (apb_interface_en) begin
      pwritedbg_rs    <= apb_bridge_pwritedbg_i;
      paddrdbg_rs     <= apb_bridge_paddrdbg_i;
      paddrdbg31_rs   <= apb_bridge_paddrdbg31_i;
      pwdatadbg_rs    <= apb_bridge_pwdatadbg_i;
    end

  // Ready signal generation
  assign core_preadydbg = ((pseldbg_dbg_rs |
                            pseldbg_pmu_rs) & dpu_preadydbg_i & ~cpu_in_retention_i) |
                          ( pseldbg_etm_rs  & etm_preadydbg_i & ~cpu_in_retention_i) |
                          ( pseldbg_cti_rs  & cti_preadydbg_i);

  assign nxt_preadydbg = (core_register & dbgpwrdup_rs) ? (penabledbg & core_preadydbg)
                                                        : pseldbg_cti_rs ? (penabledbg & cti_preadydbg_i)
                                                                         : (apb_active & ~preadydbg);

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      preadydbg <= 1'b0;
    else if (apb_active)
      preadydbg <= nxt_preadydbg;

  // Signal to indicate rising edge of PREADYDBG, used to enable access side-effects
  assign set_apb_strobe   = nxt_preadydbg & apb_active;
  assign clear_apb_strobe = apb_strobe;
  assign apb_strobe_en    = set_apb_strobe | clear_apb_strobe;

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      apb_strobe <= 1'b0;
    else if (apb_strobe_en)
      apb_strobe <= set_apb_strobe;

  assign apb_dbg_rd_req    = apb_active & apb_dec_pseldbg_dbg_i & ~pwritedbg_rs;
  assign apb_pmu_rd_req    = apb_active & apb_dec_pseldbg_pmu_i & ~pwritedbg_rs;
  assign apb_etm_rd_req    = apb_active & apb_dec_pseldbg_etm_i & ~pwritedbg_rs;
  assign apb_cti_rd_req    = apb_active & apb_dec_pseldbg_cti_i & ~pwritedbg_rs;

  assign apb_dbg_wr_strobe = apb_strobe & apb_dec_pseldbg_dbg_i &  pwritedbg_rs;
  assign apb_pmu_wr_strobe = apb_strobe & apb_dec_pseldbg_pmu_i &  pwritedbg_rs;
  assign apb_etm_wr_strobe = apb_strobe & apb_dec_pseldbg_etm_i &  pwritedbg_rs;

  // Generate PSLVERR when an access to most of the registers from the external debug interface
  // is requested and the OS lock is set or double lock is set or the core is powered down.
  // Return error even when debug logic in core domain is currently in reset to avoid system lock ups.
  // Return error for external debug access to ETM when OS lock is set except management registers
  assign nxt_pslverrdbg = (core_register & (dbgpwrdup_rs ? ((pseldbg_dbg_rs | pseldbg_pmu_rs) & dpu_pslverrdbg_i)
                                                         : (~(apb_dec_pseldbg_dbg_i & ((paddrdbg_rs[11:2] == `CA53_DBG_EDPRCR) |
                                                                                       (paddrdbg_rs[11:2] == `CA53_DBG_EDPRSR)))))) |
                           (apb_dec_pseldbg_etm_i & ((apb_bridge_paddrdbg_i[11:2] == `CA53_DBG_CLAIMSET) |
                                                     (apb_bridge_paddrdbg_i[11:2] == `CA53_DBG_CLAIMCLR) |
                                                     (((apb_bridge_paddrdbg_i[11:8] != 4'b0011)|
                                                       (apb_bridge_paddrdbg_i[7]    == 1'b1   ))  &
                                                      (apb_bridge_paddrdbg_i[11:2] < 10'h3C0))) & etm_oslock_rs_i & apb_bridge_paddrdbg31_i);

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      pslverrdbg <= 1'b0;
    else if (set_apb_strobe)
      pslverrdbg <= nxt_pslverrdbg;

  // ------------------------------------------------------
  // Address decoding
  // ------------------------------------------------------

  assign core_register = (apb_dec_pseldbg_dbg_i & ((((apb_bridge_paddrdbg_i[11:2] < 10'h340) | (apb_bridge_paddrdbg_i[11:7] == 5'h1C)) &
                                                    (apb_bridge_paddrdbg_i[11:2] != `CA53_DBG_EDECR))    |
                                                   (apb_bridge_paddrdbg_i[11:2] == `CA53_DBG_CLAIMSET)   |
                                                   (apb_bridge_paddrdbg_i[11:2] == `CA53_DBG_CLAIMCLR))) |
                         (apb_dec_pseldbg_pmu_i & (apb_bridge_paddrdbg_i[11:2] < 10'h3A0))             |
                         (apb_dec_pseldbg_etm_i & (((apb_bridge_paddrdbg_i[11:2] < 10'h3EA) & (~etm_oslock_rs_i | ~apb_bridge_paddrdbg31_i) &
                                                    (apb_bridge_paddrdbg_i[11:2] != `CA53_ETM_PDCR)) |
                                                   (apb_bridge_paddrdbg_i[11:2] == `CA53_ETM_PDSR)   |
                                                   (apb_bridge_paddrdbg_i[11:2] == `CA53_ETM_OSLAR)  |
                                                   (apb_bridge_paddrdbg_i[11:2] == `CA53_ETM_OSLSR)));

  assign prdatadbg_wrp = // External debug registers
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_EDECR)          & apb_dbg_rd_req}} & edecr_rd)                |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_EDPRCR)         & apb_dbg_rd_req}} & edprcr_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_EDPRSR)         & apb_dbg_rd_req}} & edprsr_rd)               |
                         // Processor IDs (RO)
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_MIDR)           & apb_dbg_rd_req}} & midr_rd)                 |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64PFR0lo)  & apb_dbg_rd_req}} & id_aa64pfr0_rd[31: 0])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64PFR0hi)  & apb_dbg_rd_req}} & id_aa64pfr0_rd[63:32])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64DFR0lo)  & apb_dbg_rd_req}} & id_aa64dfr0_rd[31: 0])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64DFR0hi)  & apb_dbg_rd_req}} & id_aa64dfr0_rd[63:32])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64ISAR0lo) & apb_dbg_rd_req}} & id_aa64isar0_rd[31: 0])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64ISAR0hi) & apb_dbg_rd_req}} & id_aa64isar0_rd[63:32])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64MMFR0lo) & apb_dbg_rd_req}} & id_aa64mmfr0_rd[31: 0])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64MMFR0hi) & apb_dbg_rd_req}} & id_aa64mmfr0_rd[63:32])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64PFR1lo)  & apb_dbg_rd_req}} & id_aa64pfr1_rd[31: 0])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64PFR1hi)  & apb_dbg_rd_req}} & id_aa64pfr1_rd[63:32])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64DFR1lo)  & apb_dbg_rd_req}} & id_aa64dfr1_rd[31: 0])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64DFR1hi)  & apb_dbg_rd_req}} & id_aa64dfr1_rd[63:32])   |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64ISAR1lo) & apb_dbg_rd_req}} & id_aa64isar1_rd[31: 0])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64ISAR1hi) & apb_dbg_rd_req}} & id_aa64isar1_rd[63:32])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64MMFR1lo) & apb_dbg_rd_req}} & id_aa64mmfr1_rd[31: 0])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_ID_AA64MMFR1hi) & apb_dbg_rd_req}} & id_aa64mmfr1_rd[63:32])  |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_LSR)            & apb_dbg_rd_req}} & edlsr_rd)                |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVAFF0)        & apb_dbg_rd_req}} & devaff0_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVAFF1)        & apb_dbg_rd_req}} & devaff1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_AUTHSTATUS)     & apb_dbg_rd_req}} & dbgauthstatus_rd)        |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVARCH)        & apb_dbg_rd_req}} & devarch_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVID)          & apb_dbg_rd_req}} & devid0_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVID1)         & apb_dbg_rd_req}} & devid1_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVID2)         & apb_dbg_rd_req}} & devid2_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_DEVTYPE)        & apb_dbg_rd_req}} & eddevtype_rd)            |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_PID4)           & apb_dbg_rd_req}} & edpid4_rd)               |
                         // DBGPID5-DBGPID7 are reserved and RAZ
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_PID0)           & apb_dbg_rd_req}} & edpid0_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_PID1)           & apb_dbg_rd_req}} & edpid1_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_PID2)           & apb_dbg_rd_req}} & edpid2_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_PID3)           & apb_dbg_rd_req}} & edpid3_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_CID0)           & apb_dbg_rd_req}} & `CA53_COMP0ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_CID1)           & apb_dbg_rd_req}} & `CA53_COMP1ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_CID2)           & apb_dbg_rd_req}} & `CA53_COMP2ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_DBG_CID3)           & apb_dbg_rd_req}} & `CA53_COMP3ID_RD_VAL)    |
                         // PMU registers
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_LSR)            & apb_pmu_rd_req}} & pmlsr_rd)                |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_DEVAFF0)        & apb_pmu_rd_req}} & devaff0_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_DEVAFF1)        & apb_pmu_rd_req}} & devaff1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_AUTHSTATUS)     & apb_pmu_rd_req}} & pmauthstatus_rd)         |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_DEVARCH)        & apb_pmu_rd_req}} & pmdevarch_rd)            |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_DEVTYPE)        & apb_pmu_rd_req}} & pmdevtype_rd)            |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_PID4)           & apb_pmu_rd_req}} & pmpid4_rd)               |
                         // DBGPID5-DBGPID7 are reserved and RAZ
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_PID0)           & apb_pmu_rd_req}} & pmpid0_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_PID1)           & apb_pmu_rd_req}} & pmpid1_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_PID2)           & apb_pmu_rd_req}} & pmpid2_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_PID3)           & apb_pmu_rd_req}} & pmpid3_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_CID0)           & apb_pmu_rd_req}} & `CA53_COMP0ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_CID1)           & apb_pmu_rd_req}} & `CA53_COMP1ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_CID2)           & apb_pmu_rd_req}} & `CA53_COMP2ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_PMU_CID3)           & apb_pmu_rd_req}} & `CA53_COMP3ID_RD_VAL)    |
                         // CTI registers
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_AUTHSTATUS_ADD) & apb_cti_rd_req}} & ctiauthstatus_rd)        |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_DEVAFF0)        & apb_cti_rd_req}} & devaff0_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_DEVAFF1)        & apb_cti_rd_req}} & devaff1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_COMPONID3_ADD)  & apb_cti_rd_req}} & `CA53_CTI_COMPONID3_VAL) |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_COMPONID2_ADD)  & apb_cti_rd_req}} & `CA53_CTI_COMPONID2_VAL) |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_COMPONID1_ADD)  & apb_cti_rd_req}} & `CA53_CTI_COMPONID1_VAL) |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_COMPONID0_ADD)  & apb_cti_rd_req}} & `CA53_CTI_COMPONID0_VAL) |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_PERIPHID4_ADD)  & apb_cti_rd_req}} & ctipid4_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_PERIPHID3_ADD)  & apb_cti_rd_req}} & ctipid3_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_PERIPHID2_ADD)  & apb_cti_rd_req}} & ctipid2_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_PERIPHID1_ADD)  & apb_cti_rd_req}} & ctipid1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_CTI_PERIPHID0_ADD)  & apb_cti_rd_req}} & ctipid0_rd)              |
                         // ETM registers
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PDCR)           & apb_etm_rd_req}} & etmpdcr_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PDSR)           & apb_etm_rd_req}} & etmpdsr_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_DEVAFF0)        & apb_etm_rd_req}} & devaff0_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_DEVAFF1)        & apb_etm_rd_req}} & devaff1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_LSR)            & apb_etm_rd_req}} & etmlsr_rd)               |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_AUTHSTATUS)     & apb_etm_rd_req}} & pmauthstatus_rd)         |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_DEVARCH)        & apb_etm_rd_req}} & etmdevarch_rd)           |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_DEVTYPE)        & apb_etm_rd_req}} & etmdevtype_rd)           |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PID4)           & apb_etm_rd_req}} & etmpid4_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PID0)           & apb_etm_rd_req}} & etmpid0_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PID1)           & apb_etm_rd_req}} & etmpid1_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PID2)           & apb_etm_rd_req}} & etmpid2_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_PID3)           & apb_etm_rd_req}} & etmpid3_rd)              |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_CID0)           & apb_etm_rd_req}} & `CA53_COMP0ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_CID1)           & apb_etm_rd_req}} & `CA53_COMP1ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_CID2)           & apb_etm_rd_req}} & `CA53_COMP2ID_RD_VAL)    |
                         ({32{(paddrdbg_rs[11:2] == `CA53_ETM_CID3)           & apb_etm_rd_req}} & `CA53_COMP3ID_RD_VAL);

  // PRDATA generation
  assign nxt_prdatadbg  = ({32{(pseldbg_dbg_rs |
                                pseldbg_pmu_rs) & dbgpwrdup_rs}} & dpu_prdatadbg_i) |
                          ({32{ pseldbg_etm_rs  & dbgpwrdup_rs}} & etm_prdatadbg_i) |
                          ({32{ pseldbg_cti_rs }}                & cti_prdatadbg_i) |
                                                                   prdatadbg_wrp;

  assign prdatadbg_en = set_apb_strobe & ~pwritedbg_rs;

  always @(posedge clk_apb)
    if (prdatadbg_en)
      prdatadbg <= nxt_prdatadbg;

  // Write enables
  assign apb_wr_edecr   = (paddrdbg_rs[11:2] == `CA53_DBG_EDECR)  & apb_dbg_wr_strobe & ~(edlsr_slk & ~paddrdbg31_rs);
  assign apb_wr_edprcr  = (paddrdbg_rs[11:2] == `CA53_DBG_EDPRCR) & apb_dbg_wr_strobe & ~(edlsr_slk & ~paddrdbg31_rs);
  assign apb_wr_edlar   = (paddrdbg_rs[11:2] == `CA53_DBG_LAR)    & apb_dbg_wr_strobe &               ~paddrdbg31_rs;

  assign apb_wr_pmlar   = (paddrdbg_rs[11:2] == `CA53_PMU_LAR)    & apb_pmu_wr_strobe &               ~paddrdbg31_rs;

  assign apb_wr_etmlar  = (paddrdbg_rs[11:2] == `CA53_ETM_LAR)    & apb_etm_wr_strobe &                ~paddrdbg31_rs;
  assign apb_wr_etmpdcr = (paddrdbg_rs[11:2] == `CA53_ETM_PDCR)   & apb_etm_wr_strobe & ~(etmlsr_slk & ~paddrdbg31_rs);

  //
  // ------------------------------------------------------
  // External debug registers
  // ------------------------------------------------------
  //

  // ------------------------------------------------------
  // EDECR: Execution Control Register
  // ------------------------------------------------------

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov) begin
      edecr_rce   <= 1'b0;
      edecr_osuce <= 1'b0;
    end
    else if (apb_wr_edecr) begin
      edecr_rce   <= pwdatadbg_rs[1];
      edecr_osuce <= pwdatadbg_rs[0];
    end

  assign edecr_ss_en = apb_wr_edecr & dpu_dscr_halted_i;

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      edecr_ss <= 1'b0;
    else if (edecr_ss_en)
      edecr_ss <= pwdatadbg_rs[2];

  assign edecr_rd = {{29{1'b0}},   // 31:3 RES0
                     edecr_ss,     //  2   SS
                     edecr_rce,    //  1   RCE
                     edecr_osuce}; //  0   OSUCE

  // ------------------------------------------------------
  // EDPRCR: Power/Reset Control Register
  // ------------------------------------------------------

  // Only COREPURQ, bit [3] is implemented in this wrapper
  // Other bits are implemented within the CPU

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      edprcr_corepurq <= 1'b0;
    else if (apb_wr_edprcr)
      edprcr_corepurq <= pwdatadbg_rs[3];

  assign edprcr_rd = {28'h0000000, edprcr_corepurq, 3'b000};

  // ------------------------------------------------------
  // EDPRSR: Processor Status Register (RO)
  // ------------------------------------------------------

  // Reads are handled in this wrapper when the CPU is
  // powered down, otherwise the value returned by the CPU
  // is used

  // When returned by this wrapper
  // PU, bit [0] is zero
  // SPD, bit [1] is one
  // Other bits are UNKNOWN and RAZ
  assign edprsr_rd = {32{~dbgpwrdup_rs}} & 32'h00000002;

  // ------------------------------------------------------
  // ID registers
  // ------------------------------------------------------

  assign midr_rd         = `CA53_IDCR_READ_VALUE;
  assign id_aa64pfr0_rd  = `CA53_AA64PFR0_READ_VALUE(gov_giccdisable_i);
  assign id_aa64pfr1_rd  = `CA53_AA64PFR1_READ_VALUE;
  assign id_aa64dfr0_rd  = `CA53_AA64DFR0_READ_VALUE;
  assign id_aa64dfr1_rd  = `CA53_AA64DFR1_READ_VALUE;
  assign id_aa64isar0_rd = `CA53_AA64ISAR0_READ_VALUE(gov_cryptodisable_i);
  assign id_aa64isar1_rd = `CA53_AA64ISAR1_READ_VALUE;
  assign id_aa64mmfr0_rd = `CA53_AA64MMFR0_READ_VALUE;
  assign id_aa64mmfr1_rd = `CA53_AA64MMFR1_READ_VALUE;

  // ------------------------------------------------------
  // EDLAR: Lock Access Register
  // ------------------------------------------------------

  assign nxt_lock_set = pwdatadbg_rs != 32'hC5ACCE55;

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      edlsr_slk <= 1'b1;
    else if (apb_wr_edlar)
      edlsr_slk <= nxt_lock_set;

  // ------------------------------------------------------
  // EDLSR: Lock Status Register (memory-mapped only)
  // ------------------------------------------------------

  assign edlsr_rd = paddrdbg31_rs ? 32'h00000000 : {30'h00000000, edlsr_slk, 1'b1};

  // ------------------------------------------------------
  // DEVAFF1:0 Device Affinity Register
  // ------------------------------------------------------

  assign devaff0_rd = `CA53_MPIDR_READ_VALUE(clusteridaff2_rs_i, clusteridaff1_rs_i, cpu_id_i);
  assign devaff1_rd = 32'h0000_0000;

  // ------------------------------------------------------
  // DBGAUTHSTATUS: Authentication Status register
  // ------------------------------------------------------

  assign dbgauthstatus_rd[31:8] = 24'h000000;
  assign dbgauthstatus_rd[7]    = 1'b1;
  assign dbgauthstatus_rd[6]    = (gov_niden_i | gov_dbgen_i) & (gov_spniden_i | gov_spiden_i);
  assign dbgauthstatus_rd[5]    = 1'b1;
  assign dbgauthstatus_rd[4]    = gov_dbgen_i & gov_spiden_i;
  assign dbgauthstatus_rd[3]    = 1'b1;
  assign dbgauthstatus_rd[2]    = gov_niden_i | gov_dbgen_i;
  assign dbgauthstatus_rd[1]    = 1'b1;
  assign dbgauthstatus_rd[0]    = gov_dbgen_i;

  // ------------------------------------------------------
  // DEVARCH: Device Architecture register (RO)
  // ------------------------------------------------------

  assign devarch_rd = `CA53_EDDEVARCH_READ_VALUE;

  // ------------------------------------------------------
  // DEVID0, DEVID1: Device ID registers (RO)
  // ------------------------------------------------------

  assign devid0_rd = `CA53_EDDEVID_READ_VALUE;
  assign devid1_rd = `CA53_EDDEVID1_READ_VALUE;
  assign devid2_rd = `CA53_EDDEVID2_READ_VALUE;

  // ------------------------------------------------------
  // EDDEVTYPE: Device Type register (RO)
  // ------------------------------------------------------

  assign eddevtype_rd = `CA53_EDDEVTYPE_READ_VALUE;

  // ------------------------------------------------------
  // EDPID0-EDPID4: Peripheral ID Registers (RO)
  // ------------------------------------------------------

  assign dbg_peripheral_id[39:0] = {4'h0,                 // Block count - 1 4KB block
                                    4'h4,                 // JEP continuation code - ARM
                                    `CA53_PERPH_REV_AND,  // RevAnd
                                    4'h0,                 // Customer modified - no
                                    `CA53_PERPH_REVISION, // Revision
                                    1'b1,                 // Uses JEP ID code
                                    7'h3B,                // JEP ID code - ARM
                                    `CA53_PART_NUM_11_8,
                                    `CA53_PART_NUM_7_0};  // ARM part number

  assign edpid0_rd = {24'h000000, dbg_peripheral_id[ 7: 0]};
  assign edpid1_rd = {24'h000000, dbg_peripheral_id[15: 8]};
  assign edpid2_rd = {24'h000000, dbg_peripheral_id[23:16]};
  assign edpid3_rd = {24'h000000, dbg_peripheral_id[31:24]};
  assign edpid4_rd = {24'h000000, dbg_peripheral_id[39:32]};

  //
  // ------------------------------------------------------
  // PMU registers
  // ------------------------------------------------------
  //

  // ------------------------------------------------------
  // PMLAR: Lock Access Register
  // ------------------------------------------------------

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      pmlsr_slk <= 1'b1;
    else if (apb_wr_pmlar)
      pmlsr_slk <= nxt_lock_set;

  // ------------------------------------------------------
  // PMLSR: Lock Status Register (memory-mapped only)
  // ------------------------------------------------------

  assign pmlsr_rd = paddrdbg31_rs ? 32'h00000000 : {30'h00000000, pmlsr_slk, 1'b1};

  // ------------------------------------------------------
  // PMAUTHSTATUS: Authentication Status register (also ETM reg)
  // ------------------------------------------------------

  assign pmauthstatus_rd[31:8] = 24'h000000;
  assign pmauthstatus_rd[7]    = 1'b1;
  assign pmauthstatus_rd[6]    = (gov_niden_i | gov_dbgen_i) & (gov_spniden_i | gov_spiden_i);
  assign pmauthstatus_rd[5]    = 1'b0;
  assign pmauthstatus_rd[4]    = 1'b0;
  assign pmauthstatus_rd[3]    = 1'b1;
  assign pmauthstatus_rd[2]    = gov_niden_i | gov_dbgen_i;
  assign pmauthstatus_rd[1]    = 1'b0;
  assign pmauthstatus_rd[0]    = 1'b0;

  // ------------------------------------------------------
  // PMDEVARCH: Device Architecture register (RO)
  // ------------------------------------------------------

  assign pmdevarch_rd = `CA53_PMDEVARCH_READ_VALUE;

  // ------------------------------------------------------
  // PMDEVTYPE: Device Type register (RO)
  // ------------------------------------------------------

  assign pmdevtype_rd = `CA53_PMDEVTYPE_READ_VALUE;

  // ------------------------------------------------------
  // PMPID0-PMPID4: Peripheral ID Registers (RO)
  // ------------------------------------------------------

  assign pmu_peripheral_id[39:0] = {4'h0,                 // Block count - 1 4KB block
                                    4'h4,                 // JEP continuation code - ARM
                                    `CA53_PERPH_REV_AND,  // RevAnd
                                    4'h0,                 // Customer modified - no
                                    `CA53_PERPH_REVISION, // Revision
                                    1'b1,                 // Uses JEP ID code
                                    7'h3B,                // JEP ID code - ARM
                                    `CA53_PMU_PART_NUM};  // ARM part number

  assign pmpid0_rd = {24'h000000, pmu_peripheral_id[ 7: 0]};
  assign pmpid1_rd = {24'h000000, pmu_peripheral_id[15: 8]};
  assign pmpid2_rd = {24'h000000, pmu_peripheral_id[23:16]};
  assign pmpid3_rd = {24'h000000, pmu_peripheral_id[31:24]};
  assign pmpid4_rd = {24'h000000, pmu_peripheral_id[39:32]};

  // ------------------------------------------------------
  // ETM registers
  // ------------------------------------------------------

  // ------------------------------------------------------
  // ETMPDCR: Power Down Control Register
  // ------------------------------------------------------
  // ETMPDCR[3] and EDPRCR[3] are ored together as an output

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      etmpdcr_etmpurq <= 1'b0;
    else if (apb_wr_etmpdcr)
      etmpdcr_etmpurq <= pwdatadbg_rs[3];

  assign etmpdcr_rd = {28'h0000000, etmpdcr_etmpurq, 3'b000};

  // ------------------------------------------------------
  // ETMPDSR: Power Down Status Register
  // ------------------------------------------------------
  // Only bit 0 is implemented in this wrapper

  assign etmpdsr_rd = {{31{1'b0}}, dbgpwrdup_rs};

  // ------------------------------------------------------
  // ETMLAR: Lock Access Register
  // ------------------------------------------------------

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      etmlsr_slk <= 1'b1;
    else if (apb_wr_etmlar)
      etmlsr_slk <= nxt_lock_set;

  // ------------------------------------------------------
  // ETMAUTHSTATUS: Authentification Status Register
  // ------------------------------------------------------

  // Same as PMU Authentication Status

  // ------------------------------------------------------
  // ETMLSR: Lock Status Register (memory-mapped only)
  // ------------------------------------------------------

  assign etmlsr_rd = paddrdbg31_rs ? 32'h00000000 : {30'h00000000, etmlsr_slk, 1'b1};

  // ------------------------------------------------------
  // ETMDEVARCH: Device Architecture register (RO)
  // ------------------------------------------------------

  assign etmdevarch_rd = {4'h4,                           // JEP continuation code - ARM
                          7'h3b,                          // JEP ID code - ARM
                          1'b1,                           // Present
                          4'h0,                           // Arch revision
                          4'h4,                           // Arch version ETMv4
                          12'hA13};                       // Arch part ETMv4

  // ------------------------------------------------------
  // ETMDEVTYPE: Device Type register (RO)
  // ------------------------------------------------------

  assign etmdevtype_rd = 32'h00000013;

  // ------------------------------------------------------
  // ETMPID0-ETMPID4: Peripheral ID Registers (RO)
  // ------------------------------------------------------

  assign etm_peripheral_id[39:0] = {4'h0,                 // Block count - 1 4KB block
                                    4'h4,                 // JEP continuation code - ARM
                                    `CA53_PERPH_REV_AND,  // RevAnd
                                    4'h0,                 // Customer modified - no
                                    `CA53_PERPH_REVISION, // Revision
                                    1'b1,                 // Uses JEP ID code
                                    7'h3B,                // JEP ID code - ARM
                                    `CA53_ETM_PART_NUM};  // ARM part number

  assign etmpid0_rd = {24'h000000, etm_peripheral_id[ 7: 0]};
  assign etmpid1_rd = {24'h000000, etm_peripheral_id[15: 8]};
  assign etmpid2_rd = {24'h000000, etm_peripheral_id[23:16]};
  assign etmpid3_rd = {24'h000000, etm_peripheral_id[31:24]};
  assign etmpid4_rd = {24'h000000, etm_peripheral_id[39:32]};

  // ------------------------------------------------------
  // CTIAUTHSTATUS: Authentication Status register
  // ------------------------------------------------------
  // CTIAUTHSTATUS.{SNID,SID} are RAZ, because the CTI does not
  // itself provide secure authentication.

  assign ctiauthstatus_rd[31:8] = 24'h000000;
  assign ctiauthstatus_rd[7:6]  = 2'b00;
  assign ctiauthstatus_rd[5:4]  = 2'b00;
  assign ctiauthstatus_rd[3]    = 1'b1;
  assign ctiauthstatus_rd[2]    = gov_niden_i | gov_dbgen_i;
  assign ctiauthstatus_rd[1]    = 1'b1;
  assign ctiauthstatus_rd[0]    = gov_dbgen_i;

  // ------------------------------------------------------
  // CTIPID0-CTIPID4: Peripheral ID Registers (RO)
  // ------------------------------------------------------

  assign cti_peripheral_id[39:0] = {4'h0,                 // Block count - 1 4KB block
                                    4'h4,                 // JEP continuation code - ARM
                                    `CA53_PERPH_REV_AND,  // RevAnd
                                    4'h0,                 // Customer modified - no
                                    `CA53_PERPH_REVISION, // Revision
                                    1'b1,                 // Uses JEP ID code
                                    7'h3B,                // JEP ID code - ARM
                                    `CA53_CTI_PART_NUM};  // ARM part number

  assign ctipid0_rd = {24'h000000, cti_peripheral_id[ 7: 0]};
  assign ctipid1_rd = {24'h000000, cti_peripheral_id[15: 8]};
  assign ctipid2_rd = {24'h000000, cti_peripheral_id[23:16]};
  assign ctipid3_rd = {24'h000000, cti_peripheral_id[31:24]};
  assign ctipid4_rd = {24'h000000, cti_peripheral_id[39:32]};

  // ------------------------------------------------------
  // Register Top-Level Outputs
  // ------------------------------------------------------

  // Combine the core and ETM power up requests.  Send the un-registered
  // version to the CPU, but register before use as a top-level output.
  assign gov_dbgpwrupreq = edprcr_corepurq | etmpdcr_etmpurq;

  always @(posedge clk_apb or negedge npresetdbg_gov)
    if (~npresetdbg_gov)
      dbgpwrupreq <= 1'b0;
    else
      dbgpwrupreq <= gov_dbgpwrupreq;

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign gov_edecr_osuce_o    = edecr_osuce;
  assign gov_edecr_rce_o      = edecr_rce;
  assign gov_edecr_ss_o       = edecr_ss;
  assign gov_edlsr_slk_o      = edlsr_slk;
  assign gov_pmlsr_slk_o      = pmlsr_slk;
  assign gov_etmpdsr_rd_o     = ~etmlsr_slk | paddrdbg31_rs;
  assign gov_pseldbg_dbg_o    = pseldbg_dbg_rs;
  assign gov_pseldbg_pmu_o    = pseldbg_pmu_rs;
  assign gov_pseldbg_etm_o    = pseldbg_etm_rs;
  assign gov_pseldbg_cti_o    = pseldbg_cti_rs;
  assign gov_penabledbg_o     = penabledbg;
  assign gov_paddrdbg_o       = paddrdbg_rs;
  assign gov_paddrdbg31_o     = paddrdbg31_rs;
  assign gov_pwritedbg_o      = pwritedbg_rs;
  assign gov_pwdatadbg_o      = pwdatadbg_rs;
  assign gov_dbgpwrupreq_o    = gov_dbgpwrupreq;
  assign dbgpwrupreq_o        = dbgpwrupreq;

  assign pslverrdbg_gov_o     = pslverrdbg;
  assign preadydbg_gov_o      = preadydbg;
  assign prdatadbg_gov_o      = prdatadbg;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // Automatic X-Checks on register enables
  //----------------------------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: edecr_ss_en")
  u_ovl_x_edecr_ss_en (.clk       (clk_apb),
                       .reset_n   (npresetdbg_gov),
                       .qualifier (1'b1),
                       .test_expr (edecr_ss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_active")
  u_ovl_x_apb_active (.clk       (CLKIN),
                      .reset_n   (npresetdbg_gov),
                      .qualifier (1'b1),
                      .test_expr (apb_active));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_interface_en")
  u_ovl_x_apb_interface_en (.clk       (CLKIN),
                            .reset_n   (npresetdbg_gov),
                            .qualifier (1'b1),
                            .test_expr (apb_interface_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_strobe_en")
  u_ovl_x_apb_strobe_en (.clk       (CLKIN),
                         .reset_n   (npresetdbg_gov),
                         .qualifier (1'b1),
                         .test_expr (apb_strobe_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_edecr")
  u_ovl_x_apb_wr_edecr (.clk       (CLKIN),
                        .reset_n   (po_reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (apb_wr_edecr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_edlar")
  u_ovl_x_apb_wr_edlar (.clk       (CLKIN),
                        .reset_n   (po_reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (apb_wr_edlar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_edprcr")
  u_ovl_x_apb_wr_edprcr (.clk       (CLKIN),
                         .reset_n   (po_reset_n_gov),
                         .qualifier (1'b1),
                         .test_expr (apb_wr_edprcr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_etmlar")
  u_ovl_x_apb_wr_etmlar (.clk       (CLKIN),
                         .reset_n   (po_reset_n_gov),
                         .qualifier (1'b1),
                         .test_expr (apb_wr_etmlar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_etmpdcr")
  u_ovl_x_apb_wr_etmpdcr (.clk       (CLKIN),
                          .reset_n   (po_reset_n_gov),
                          .qualifier (1'b1),
                          .test_expr (apb_wr_etmpdcr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: apb_wr_pmlar")
  u_ovl_x_apb_wr_pmlar (.clk       (CLKIN),
                        .reset_n   (po_reset_n_gov),
                        .qualifier (1'b1),
                        .test_expr (apb_wr_pmlar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: prdatadbg_en")
  u_ovl_x_prdatadbg_en (.clk       (CLKIN),
                        .reset_n   (npresetdbg_gov),
                        .qualifier (1'b1),
                        .test_expr (prdatadbg_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: set_apb_strobe")
  u_ovl_x_set_apb_strobe (.clk       (CLKIN),
                          .reset_n   (npresetdbg_gov),
                          .qualifier (1'b1),
                          .test_expr (set_apb_strobe));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
