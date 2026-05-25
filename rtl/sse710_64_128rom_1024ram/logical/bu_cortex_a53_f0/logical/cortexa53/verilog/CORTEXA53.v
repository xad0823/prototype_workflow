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
//      Checked In          : $Date: 2012-05-08 10:27:34 +0100 (Tue, 08 May 2012) $
//
//      Revision            : $Revision: 208754 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Information: CortexA53 Top Level
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53scu_defs.v"

module CORTEXA53 (
 // Clock Signals
 input   wire                                        CLKIN,
 // Reset Signals
 input   wire  [  3: 0]                              nCPUPORESET,
 input   wire  [  3: 0]                              nCORERESET,
 output  wire  [  3: 0]                              WARMRSTREQ,
 input   wire                                        nL2RESET,
 input   wire                                        L2RSTDISABLE,
 // Configuration Signals
 input   wire  [  3: 0]                              CFGEND,
 input   wire  [  3: 0]                              VINITHI,
 input   wire  [  3: 0]                              CFGTE,
 input   wire  [  3: 0]                              CP15SDISABLE,
 input   wire  [  7: 0]                              CLUSTERIDAFF1,
 input   wire  [  7: 0]                              CLUSTERIDAFF2,
 input   wire  [  3: 0]                              AA64nAA32,
 input   wire  [ 39: 2]                              RVBARADDR0,
 input   wire  [ 39: 2]                              RVBARADDR1,
 input   wire  [ 39: 2]                              RVBARADDR2,
 input   wire  [ 39: 2]                              RVBARADDR3,
 input   wire  [  3: 0]                              CRYPTODISABLE,
 // Interrupt Signals
 input   wire  [  3: 0]                              nFIQ,
 input   wire  [  3: 0]                              nIRQ,
 input   wire  [  3: 0]                              nSEI,
 input   wire  [  3: 0]                              nVFIQ,
 input   wire  [  3: 0]                              nVIRQ,
 input   wire  [  3: 0]                              nVSEI,
 input   wire  [  3: 0]                              nREI,
 output  wire  [  3: 0]                              nVCPUMNTIRQ,
 input   wire  [ 39:18]                              PERIPHBASE,
 input   wire                                        GICCDISABLE,
 input   wire                                        ICDTVALID,
 output  wire                                        ICDTREADY,
 input   wire  [ 15: 0]                              ICDTDATA,
 input   wire                                        ICDTLAST,
 input   wire  [  1: 0]                              ICDTDEST,
 output  wire                                        ICCTVALID,
 input   wire                                        ICCTREADY,
 output  wire  [ 15: 0]                              ICCTDATA,
 output  wire                                        ICCTLAST,
 output  wire  [  1: 0]                              ICCTID,
 // Generic Timer Signals
 input   wire  [ 63: 0]                              CNTVALUEB,
 input   wire                                        CNTCLKEN,
 output  wire  [  3: 0]                              nCNTPNSIRQ,
 output  wire  [  3: 0]                              nCNTPSIRQ,
 output  wire  [  3: 0]                              nCNTVIRQ,
 output  wire  [  3: 0]                              nCNTHPIRQ,
 // Power Management Signals (Non-Retention)
 input   wire                                        CLREXMONREQ,
 output  wire                                        CLREXMONACK,
 input   wire                                        EVENTI,
 output  wire                                        EVENTO,
 output  wire  [  3: 0]                              STANDBYWFI,
 output  wire  [  3: 0]                              STANDBYWFE,
 output  wire                                        STANDBYWFIL2,
 input   wire                                        L2FLUSHREQ,
 output  wire                                        L2FLUSHDONE,
 output  wire  [  3: 0]                              SMPEN,
 // Power Management Signals (Retention)
 output  wire  [  3: 0]                              CPUQACTIVE,
 input   wire  [  3: 0]                              CPUQREQn,
 output  wire  [  3: 0]                              CPUQDENY,
 output  wire  [  3: 0]                              CPUQACCEPTn,
 output  wire  [  3: 0]                              NEONQACTIVE,
 input   wire  [  3: 0]                              NEONQREQn,
 output  wire  [  3: 0]                              NEONQDENY,
 output  wire  [  3: 0]                              NEONQACCEPTn,
 output  wire                                        L2QACTIVE,
 input   wire                                        L2QREQn,
 output  wire                                        L2QDENY,
 output  wire                                        L2QACCEPTn,
 // L2 Error Signals
 output  wire                                        nINTERRIRQ,
 // ACE and Skyros Interface Signals
 output  wire                                        nEXTERRIRQ,
 input   wire                                        BROADCASTCACHEMAINT,
 input   wire                                        BROADCASTINNER,
 input   wire                                        BROADCASTOUTER,
 input   wire                                        SYSBARDISABLE,
 // ACE Interface; Clock and Configuration Signals
 input   wire                                        ACLKENM,
 input   wire                                        ACINACTM,
 output  wire [  7: 0]                               RDMEMATTR,
 output  wire [  7: 0]                               WRMEMATTR,
 // ACE Interface; Write Address Channel Signals
 input   wire                                        AWREADYM,
 output  wire                                        AWVALIDM,
 output  wire  [  4: 0]                              AWIDM,
 output  wire  [ 43: 0]                              AWADDRM,
 output  wire  [  7: 0]                              AWLENM,
 output  wire  [  2: 0]                              AWSIZEM,
 output  wire  [  1: 0]                              AWBURSTM,
 output  wire  [  1: 0]                              AWBARM,
 output  wire  [  1: 0]                              AWDOMAINM,
 output  wire                                        AWLOCKM,
 output  wire  [  3: 0]                              AWCACHEM,
 output  wire  [  2: 0]                              AWPROTM,
 output  wire  [  2: 0]                              AWSNOOPM,
 output  wire                                        AWUNIQUEM,
 // ACE Interface; Write Data Channel Signals
 input   wire                                        WREADYM,
 output  wire                                        WVALIDM,
 output  wire  [  4: 0]                              WIDM,
 output  wire  [127: 0]                              WDATAM,
 output  wire  [ 15: 0]                              WSTRBM,
 output  wire                                        WLASTM,
 // ACE Interface; Write Response Channel Signals
 output  wire                                        BREADYM,
 input   wire                                        BVALIDM,
 input   wire  [  4: 0]                              BIDM,
 input   wire  [  1: 0]                              BRESPM,
 // ACE Interface; Read Address Channel Signals
 input   wire                                        ARREADYM,
 output  wire                                        ARVALIDM,
 output  wire  [  5: 0]                              ARIDM,
 output  wire  [ 43: 0]                              ARADDRM,
 output  wire  [  7: 0]                              ARLENM,
 output  wire  [  2: 0]                              ARSIZEM,
 output  wire  [  1: 0]                              ARBURSTM,
 output  wire  [  1: 0]                              ARBARM,
 output  wire  [  1: 0]                              ARDOMAINM,
 output  wire                                        ARLOCKM,
 output  wire  [  3: 0]                              ARCACHEM,
 output  wire  [  2: 0]                              ARPROTM,
 output  wire  [  3: 0]                              ARSNOOPM,
 // ACE Interface; Read Data Channel Signals
 output  wire                                        RREADYM,
 input   wire                                        RVALIDM,
 input   wire  [  5: 0]                              RIDM,
 input   wire  [127: 0]                              RDATAM,
 input   wire  [  3: 0]                              RRESPM,
 input   wire                                        RLASTM,
 // ACE Interface; Coherency Address Channel Signals
 output  wire                                        ACREADYM,
 input   wire                                        ACVALIDM,
 input   wire  [ 43: 0]                              ACADDRM,
 input   wire  [  2: 0]                              ACPROTM,
 input   wire  [  3: 0]                              ACSNOOPM,
 // ACE Interface; Coherency Response Channel Signals
 input   wire                                        CRREADYM,
 output  wire                                        CRVALIDM,
 output  wire  [  4: 0]                              CRRESPM,
 // ACE Interface; Coherency Data Channel Signals
 input   wire                                        CDREADYM,
 output  wire                                        CDVALIDM,
 output  wire  [127: 0]                              CDDATAM,
 output  wire                                        CDLASTM,
 // ACE Interface; Read/Write Acknowledge Signals
 output  wire                                        RACKM,
 output  wire                                        WACKM,
 // APB Interface Signals
 input   wire                                        nPRESETDBG,
 input   wire                                        PCLKENDBG,
 input   wire                                        PSELDBG,
 input   wire  [ 21: 2]                              PADDRDBG,
 input   wire                                        PADDRDBG31,
 input   wire                                        PENABLEDBG,
 input   wire                                        PWRITEDBG,
 input   wire  [ 31: 0]                              PWDATADBG,
 output  wire  [ 31: 0]                              PRDATADBG,
 output  wire                                        PREADYDBG,
 output  wire                                        PSLVERRDBG,
 // Miscellaneous Debug Signals
 input   wire  [ 39:12]                              DBGROMADDR,
 input   wire                                        DBGROMADDRV,
 output  wire  [  3: 0]                              DBGACK,
 output  wire  [  3: 0]                              nCOMMIRQ,
 output  wire  [  3: 0]                              COMMRX,
 output  wire  [  3: 0]                              COMMTX,
 input   wire  [  3: 0]                              EDBGRQ,
 input   wire  [  3: 0]                              DBGEN,
 input   wire  [  3: 0]                              NIDEN,
 input   wire  [  3: 0]                              SPIDEN,
 input   wire  [  3: 0]                              SPNIDEN,
 output  wire  [  3: 0]                              DBGRSTREQ,
 output  wire  [  3: 0]                              DBGNOPWRDWN,
 input   wire  [  3: 0]                              DBGPWRDUP,
 output  wire  [  3: 0]                              DBGPWRUPREQ,
 input   wire                                        DBGL1RSTDISABLE,
 // ATB Interface Signals
 input   wire                                        ATCLKEN,
 input   wire                                        ATREADYM0,
 input   wire                                        ATREADYM1,
 input   wire                                        ATREADYM2,
 input   wire                                        ATREADYM3,
 input   wire                                        AFVALIDM0,
 input   wire                                        AFVALIDM1,
 input   wire                                        AFVALIDM2,
 input   wire                                        AFVALIDM3,
 output  wire  [ 31: 0]                              ATDATAM0,
 output  wire  [ 31: 0]                              ATDATAM1,
 output  wire  [ 31: 0]                              ATDATAM2,
 output  wire  [ 31: 0]                              ATDATAM3,
 output  wire                                        ATVALIDM0,
 output  wire                                        ATVALIDM1,
 output  wire                                        ATVALIDM2,
 output  wire                                        ATVALIDM3,
 output  wire  [  1: 0]                              ATBYTESM0,
 output  wire  [  1: 0]                              ATBYTESM1,
 output  wire  [  1: 0]                              ATBYTESM2,
 output  wire  [  1: 0]                              ATBYTESM3,
 output  wire                                        AFREADYM0,
 output  wire                                        AFREADYM1,
 output  wire                                        AFREADYM2,
 output  wire                                        AFREADYM3,
 output  wire  [  6: 0]                              ATIDM0,
 output  wire  [  6: 0]                              ATIDM1,
 output  wire  [  6: 0]                              ATIDM2,
 output  wire  [  6: 0]                              ATIDM3,
 // Miscellaneous ETM Signals
 input   wire                                        SYNCREQM0,
 input   wire                                        SYNCREQM1,
 input   wire                                        SYNCREQM2,
 input   wire                                        SYNCREQM3,
 input   wire  [ 63: 0]                              TSVALUEB,
 // CTI Interface Signals
 input   wire  [  3: 0]                              CTICHIN,
 input   wire  [  3: 0]                              CTICHOUTACK,
 output  wire  [  3: 0]                              CTICHOUT,
 output  wire  [  3: 0]                              CTICHINACK,
 input   wire                                        CISBYPASS,
 input   wire  [  3: 0]                              CIHSBYPASS,
 output  wire  [  3: 0]                              CTIIRQ,
 input   wire  [  3: 0]                              CTIIRQACK,
 // PMU Signals
 output  wire  [  3: 0]                              nPMUIRQ,
 output  wire  [ 29: 0]                              PMUEVENT0,
 output  wire  [ 29: 0]                              PMUEVENT1,
 output  wire  [ 29: 0]                              PMUEVENT2,
 output  wire  [ 29: 0]                              PMUEVENT3,
 // DFT Signals
 input   wire                                        DFTSE,
 input   wire                                        DFTRSTDISABLE,
 input   wire                                        DFTRAMHOLD,
 input   wire                                        DFTMCPHOLD,
 // MBIST Interface Signals
 input   wire                                        MBISTREQ,
 input   wire                                        nMBISTRESET
);

  // -----------------------------
  // Local Params declarations
  // -----------------------------
  localparam NUM_CPUS = 4;
  localparam NEON_FP = 1;
  localparam CRYPTO = 1;
  localparam LEGACY_V7_DEBUG_MAP = 0;
  localparam SCU_CACHE_PROTECTION = 1;
  localparam CPU_CACHE_PROTECTION = 1;
  localparam ACP = 0;
  localparam L2_CACHE = 1;
  localparam ACE = 1;
  localparam [2:0] L1_DCACHE_SIZE = 3'b111;
  localparam [2:0] L1_ICACHE_SIZE = 3'b111;
  localparam [3:0] L2_CACHE_SIZE = 4'b0111;
  localparam [0:0] L2_INPUT_LATENCY = 1'b0;
  localparam [0:0] L2_OUTPUT_LATENCY = 1'b0;

  // -----------------------------
  // Variable declarations
  // -----------------------------

  genvar cpu;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [(`CA53_AFVALIDM_PKDED_W-1):0]     afvalidm;
  wire [(`CA53_AFREADYM_PKDED_W-1):0]     afreadym;
  wire [(`CA53_ATBYTESM_PKDED_W-1):0]     atbytesm;
  wire [(`CA53_ATDATAM_PKDED_W-1):0]      atdatam;
  wire [(`CA53_ATIDM_PKDED_W-1):0]        atidm;
  wire [(`CA53_ATREADYM_PKDED_W-1):0]     atreadym;
  wire [(`CA53_ATVALIDM_PKDED_W-1):0]     atvalidm;
  wire [(`CA53_ARACTIVE_PKDED_W-1):0]     biu_ar_active;
  wire [(`CA53_ARADDR_PKDED_W-1):0]       biu_ar_addr;
  wire [(`CA53_ARATTRS_PKDED_W-1):0]      biu_ar_attrs;
  wire [(`CA53_ARID_PKDED_W-1):0]         biu_ar_id;
  wire [(`CA53_ARLEN_PKDED_W-1):0]        biu_ar_len;
  wire [(`CA53_ARLOCK_PKDED_W-1):0]       biu_ar_lock;
  wire [(`CA53_ARPRIV_PKDED_W-1):0]       biu_ar_priv;
  wire [(`CA53_ARSIZE_PKDED_W-1):0]       biu_ar_size;
  wire [(`CA53_ARTYPE_PKDED_W-1):0]       biu_ar_type;
  wire [(`CA53_ARVALID_PKDED_W-1):0]      biu_ar_valid;
  wire [(`CA53_ARWAY_PKDED_W-1):0]        biu_ar_way;
  wire [(`CA53_DRCREDIT_PKDED_W-1):0]     biu_dr_credit;
  wire [(`CA53_DWCHUNKS_PKDED_W-1):0]     biu_dw_chunks_valid;
  wire [(`CA53_DWDATA_PKDED_W-1):0]       biu_dw_data;
  wire [(`CA53_DWERR_PKDED_W-1):0]        biu_dw_err;
  wire [(`CA53_DWFATAL_PKDED_W-1):0]      biu_dw_fatal;
  wire [(`CA53_DWL2DB_PKDED_W-1):0]       biu_dw_l2db_id;
  wire [(`CA53_DWLAST_PKDED_W-1):0]       biu_dw_last;
  wire [(`CA53_DWSTRB_PKDED_W-1):0]       biu_dw_strb;
  wire [(`CA53_DWVALID_PKDED_W-1):0]      biu_dw_valid;
  wire [NUM_CPUS-1:0]                     biu_wfx_ready;
  wire [NUM_CPUS-1:0]                     clk_cpu;
  wire [3:0]                              ctr_cwg;
  wire [3:0]                              ctr_erg;
  wire [(`CA53_ACREADY_PKDED_W-1):0]      dcu_ac_ready;
  wire [NUM_CPUS-1:0]                     dcu_excl_mon_cleared;
  wire [(`CA53_CPADDR_PKDED_W-1):0]       dcu_cp_gov_addr;
  wire [NUM_CPUS-1:0]                     dcu_cp_gov_ns;
  wire [NUM_CPUS-1:0]                     dcu_cp_gov_req;
  wire [(`CA53_CPSEL_PKDED_W-1):0]        dcu_cp_gov_sel;
  wire [(`CA53_CPDATA_PKDED_W-1):0]       dcu_cp_gov_wdata;
  wire [NUM_CPUS-1:0]                     dcu_cp_gov_wenable;
  wire [(`CA53_CRDIRTY_PKDED_W-1):0]      dcu_cr_dirty;
  wire [(`CA53_CRID_PKDED_W-1):0]         dcu_cr_id;
  wire [(`CA53_CRAGE_PKDED_W-1):0]        dcu_cr_age;
  wire [(`CA53_CRALLOC_PKDED_W-1):0]      dcu_cr_alloc;
  wire [(`CA53_CRMIG_PKDED_W-1):0]        dcu_cr_migratory;
  wire [(`CA53_CRVALID_PKDED_W-1):0]      dcu_cr_valid;
  wire [(`CA53_DVM_COMP_PKDED_W-1):0]     dcu_dvm_complete;
  wire [NUM_CPUS-1:0]                     dcu_wfx_ready;
  wire [NUM_CPUS-1:0]                     dpu_commrx;
  wire [NUM_CPUS-1:0]                     dpu_commtx;
  wire [NUM_CPUS-1:0]                     dpu_dbgack;
  wire [NUM_CPUS-1:0]                     dpu_dbgnopwrdwn;
  wire [NUM_CPUS-1:0]                     dpu_dbgrstreq;
  wire [NUM_CPUS-1:0]                     dpu_dbgtrigger;
  wire [(`CA53_RET_CTL_PKDED_W-1):0]      dpu_cpuectlr_cpu_ret_delay;
  wire [(`CA53_RET_CTL_PKDED_W-1):0]      dpu_cpuectlr_neon_ret_delay;
  wire [(`CA53_EXCP_LEV_PKDED_W-1):0]     dpu_exception_level;
  wire [NUM_CPUS-1:0]                     dpu_aarch64_at_el3;
  wire [NUM_CPUS-1:0]                     dpu_dscr_halted;
  wire [NUM_CPUS-1:0]                     dpu_ncommirq;
  wire [NUM_CPUS-1:0]                     dpu_neon_active;
  wire [NUM_CPUS-1:0]                     dpu_npmuirq;
  wire [(`CA53_PMUEVNT_CPU_PKDED_W-1):0]  dpu_pmuevent;
  wire [(`CA53_PRDATADBG_PKDED_W-1):0]    dpu_prdatadbg;
  wire [NUM_CPUS-1:0]                     dpu_preadydbg;
  wire [NUM_CPUS-1:0]                     dpu_pslverrdbg;
  wire [NUM_CPUS-1:0]                     dpu_clr_event_register;
  wire [NUM_CPUS-1:0]                     dpu_wfi_req;
  wire [NUM_CPUS-1:0]                     dpu_wfe_req;
  wire [NUM_CPUS-1:0]                     dpu_sev_req;
  wire [NUM_CPUS-1:0]                     dpu_imp_abort_pending;
  wire [NUM_CPUS-1:0]                     dpu_irq_masked;
  wire [NUM_CPUS-1:0]                     dpu_fiq_masked;
  wire [NUM_CPUS-1:0]                     dpu_irq_pended;
  wire [NUM_CPUS-1:0]                     dpu_fiq_pended;
  wire [NUM_CPUS-1:0]                     dpu_hcr_el2_fmo;
  wire [NUM_CPUS-1:0]                     dpu_hcr_el2_imo;
  wire [NUM_CPUS-1:0]                     dpu_hcr_el2_amo;
  wire [NUM_CPUS-1:0]                     dpu_monitor_mode;
  wire [NUM_CPUS-1:0]                     dpu_rei_level_ack;
  wire [NUM_CPUS-1:0]                     dpu_scr_el3_fiq;
  wire [NUM_CPUS-1:0]                     dpu_scr_el3_irq;
  wire [NUM_CPUS-1:0]                     dpu_scr_el3_ns;
  wire [NUM_CPUS-1:0]                     dpu_sei_level_ack;
  wire [NUM_CPUS-1:0]                     dpu_sei_masked;
  wire [NUM_CPUS-1:0]                     dpu_sei_pended;
  wire [NUM_CPUS-1:0]                     dpu_vsei_level_ack;
  wire [NUM_CPUS-1:0]                     dpu_virq_pended;
  wire [NUM_CPUS-1:0]                     dpu_vfiq_pended;
  wire [NUM_CPUS-1:0]                     dpu_vsei_pended;
  wire [NUM_CPUS-1:0]                     dpu_virq_masked;
  wire [NUM_CPUS-1:0]                     dpu_vfiq_masked;
  wire [NUM_CPUS-1:0]                     dpu_vsei_masked;
  wire [NUM_CPUS-1:0]                     dpu_dbg_double_lock_set;
  wire [NUM_CPUS-1:0]                     dpu_ns_state;
  wire [NUM_CPUS-1:0]                     dpu_smp_en;
  wire [NUM_CPUS-1:0]                     dpu_warmrstreq;
  wire [NUM_CPUS-1:0]                     etm_afreadym;
  wire [(`CA53_ATBYTESM_PKDED_W-1):0]     etm_atbytesm;
  wire [(`CA53_ATDATAM_PKDED_W-1):0]      etm_atdatam;
  wire [(`CA53_ATIDM_PKDED_W-1):0]        etm_atidm;
  wire [NUM_CPUS-1:0]                     etm_atvalidm;
  wire [(`CA53_PRDATADBG_PKDED_W-1):0]    etm_prdatadbg;
  wire [NUM_CPUS-1:0]                     etm_preadydbg;
  wire [(`CA53_ETMEXT_PKDED_W-1):0]       etm_extout;
  wire [NUM_CPUS-1:0]                     etm_oslock;
  wire [NUM_CPUS-1:0]                     gic_fiq;
  wire [NUM_CPUS-1:0]                     gic_irq;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el1_ns_sre;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el1_s_sre;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el2_enable;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el2_sre;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el3_enable;
  wire [NUM_CPUS-1:0]                     gic_icc_sre_el3_sre;
  wire [NUM_CPUS-1:0]                     gic_ich_hcr_el2_tall0;
  wire [NUM_CPUS-1:0]                     gic_ich_hcr_el2_tall1;
  wire [NUM_CPUS-1:0]                     gic_ich_hcr_el2_tc;
  wire [NUM_CPUS-1:0]                     gic_vfiq;
  wire [NUM_CPUS-1:0]                     gic_virq;
  wire [NUM_CPUS-1:0]                     gov_aa64naa32;
  wire [(`CA53_AFVALIDM_PKDED_W-1):0]     gov_afvalidm;
  wire [NUM_CPUS-1: 0]                    gov_atclken;
  wire [(`CA53_ATREADYM_PKDED_W-1):0]     gov_atreadym;
  wire [NUM_CPUS-1:0]                     gov_cfgend;
  wire [NUM_CPUS-1:0]                     gov_cfgte;
  wire [  7:0]                            gov_clusteridaff1;
  wire [  7:0]                            gov_clusteridaff2;
  wire [NUM_CPUS-1:0]                     gov_cntp_kernel_access;
  wire [NUM_CPUS-1:0]                     gov_cntp_usr_access;
  wire [NUM_CPUS-1:0]                     gov_cntv_usr_access;
  wire [NUM_CPUS-1:0]                     gov_stall_dsb;
  wire [NUM_CPUS-1:0]                     gov_cp_ack;
  wire [(`CA53_CPDATA_PKDED_W-1):0]       gov_cp_rdata;
  wire [ 63:0]                            gov_tsvalueb;
  wire [NUM_CPUS-1:0]                     gov_cp15sdisable;
  wire [NUM_CPUS-1:0]                     gov_cryptodisable;
  wire [NUM_CPUS-1:0]                     gov_dbgen;
  wire [NUM_CPUS-1:0]                     gov_dbgpwrupreq;
  wire [NUM_CPUS-1:0]                     gov_dbgl1rstdisable;
  wire [NUM_CPUS-1:0]                     gov_dbgrestart;
  wire [ 39:12]                           gov_dbgromaddr;
  wire                                    gov_dbgromaddrv;
  wire [(`CA53_ETMEXT_PKDED_W-1):0]       gov_extin;
  wire [NUM_CPUS-1:0]                     gov_edbgrq;
  wire [NUM_CPUS-1:0]                     gov_edecr_osuce;
  wire [NUM_CPUS-1:0]                     gov_edecr_rce;
  wire [NUM_CPUS-1:0]                     gov_edecr_ss;
  wire                                    gov_giccdisable;
  wire [NUM_CPUS-1:0]                     gov_edlsr_slk;
  wire [NUM_CPUS-1:0]                     gov_pmlsr_slk;
  wire [NUM_CPUS-1:0]                     gov_etmpdsr_rd;
  wire [NUM_CPUS-1:0]                     gov_int_active;
  wire [NUM_CPUS-1:0]                     gov_niden;
  wire [(`CA53_PADDRDBG_PKDED_W-1):0]     gov_paddrdbg;
  wire [NUM_CPUS-1:0]                     gov_paddrdbg31;
  wire [NUM_CPUS-1:0]                     gov_pcnt_kernel_access;
  wire [NUM_CPUS-1:0]                     gov_pcnt_usr_access;
  wire [NUM_CPUS-1:0]                     gov_penabledbg;
  wire [ 39:18]                           gov_periphbase;
  wire [NUM_CPUS-1:0]                     gov_pseldbg_dbg;
  wire [NUM_CPUS-1:0]                     gov_pseldbg_pmu;
  wire [NUM_CPUS-1:0]                     gov_pseldbg_etm;
  wire [(`CA53_PWDATADBG_PKDED_W-1):0]    gov_pwdatadbg;
  wire [NUM_CPUS-1:0]                     gov_pwritedbg;
  wire [NUM_CPUS-1:0]                     gov_rei_level_req;
  wire [(`CA53_RVBARADDR_PKDED_W-1):0]    gov_rvbaraddr;
  wire [NUM_CPUS-1:0]                     gov_mbistreq_cpu;
  wire [NUM_CPUS-1:0]                     gov_sei_level_req;
  wire [NUM_CPUS-1:0]                     gov_smpen;
  wire [NUM_CPUS-1:0]                     gov_spiden;
  wire [NUM_CPUS-1:0]                     gov_spniden;
  wire [NUM_CPUS-1:0]                     gov_stall_neon;
  wire [NUM_CPUS-1:0]                     gov_standbywfe;
  wire [NUM_CPUS-1:0]                     gov_standbywfi;
  wire [(`CA53_SYNCREQM_PKDED_W-1):0]     gov_syncreqm;
  wire [NUM_CPUS-1:0]                     gov_vcnt_usr_access;
  wire [NUM_CPUS-1:0]                     gov_vinithi;
  wire [NUM_CPUS-1:0]                     gov_vsei_level_req;
  wire [NUM_CPUS-1:0]                     gov_wfx_drain_req;
  wire [NUM_CPUS-1:0]                     gov_wfx_wake;
  wire [NUM_CPUS-1:0]                     ifu_wfx_ready;
  wire [(`CA53_L1DC_SIZE_W-1):0]          l1_dc_size;
  wire [`CA53_L2_SIZE_W-1:0]              l2_size;
  wire                                    mbistack0;
  wire                                    mbistack1;
  wire [(`CA53_MBIST0_ADDR_W-1):0]        mbistaddr0;
  wire [(`CA53_MBIST1_ADDR_W-1):0]        mbistaddr1;
  wire [(`CA53_MBIST0_RAMARRAY_W-1):0]    mbistarray0;
  wire [(`CA53_MBIST1_RAMARRAY_W-1):0]    mbistarray1;
  wire [(`CA53_MBIST0_BE_W-1):0]          mbistbe0;
  wire [(`CA53_MBIST1_BE_W-1):0]          mbistbe1;
  wire                                    mbistcfg0;
  wire                                    mbistcfg1;
  wire [(`CA53_MBIST0_DATA_W-1):0]        mbistindata0;
  wire [(`CA53_MBIST1_DATA_W-1):0]        mbistindata1;
  wire [(`CA53_MBIST0_DATA_W-1):0]        mbistoutdata0;
  wire [(`CA53_MBIST1_DATA_W-1):0]        mbistoutdata1;
  wire                                    mbistreaden0;
  wire                                    mbistreaden1;
  wire                                    mbistwriteen0;
  wire                                    mbistwriteen1;
  wire [(`CA53_PMUEVNT_PKDED_W-1):0]      pmuevent;
  wire [NUM_CPUS-1:0]                     po_reset_n_cpu;
  wire [NUM_CPUS-1:0]                     reset_n_cpu;
  wire [(`CA53_RVBARADDR_PKDED_W-1):0]    rvbaraddr;
  wire [(`CA53_ACADDR_PKDED_W-1):0]       scu_ac_addr;
  wire [(`CA53_ACID_PKDED_W-1):0]         scu_ac_id;
  wire [(`CA53_ACL2DB_PKDED_W-1):0]       scu_ac_l2db_id;
  wire [(`CA53_ACSNOOP_PKDED_W-1):0]      scu_ac_snoop;
  wire [(`CA53_ACVALID_PKDED_W-1):0]      scu_ac_valid;
  wire [(`CA53_ACWAY_PKDED_W-1):0]        scu_ac_way;
  wire [(`CA53_ARCREDIT_PKDED_W-1):0]     scu_ar_credit;
  wire [(`CA53_ARBLOCK_PKDED_W-1):0]      scu_ar_block;
  wire                                    scu_ext_ac_ready;
  wire [(`CA53_SCU_EXT_ADDR_W-1):0]       scu_ext_aw_addr;
  wire [(`CA53_ACE_AWBAR_W-1):0]          scu_ext_aw_bar;
  wire [(`CA53_ACE_AWBURST_W-1):0]        scu_ext_aw_burst;
  wire [(`CA53_ACE_AWCACHE_W-1):0]        scu_ext_aw_cache;
  wire [(`CA53_ACE_AWDOMAIN_W-1):0]       scu_ext_aw_domain;
  wire [(`CA53_SCU_EXT_WID_W-1):0]        scu_ext_aw_id;
  wire [(`CA53_ACE_AWLEN_W-1):0]          scu_ext_aw_len;
  wire                                    scu_ext_aw_lock;
  wire [(`CA53_ACE_AWPROT_W-1):0]         scu_ext_aw_prot;
  wire [(`CA53_ACE_AWSIZE_W-1):0]         scu_ext_aw_size;
  wire [(`CA53_ACE_AWSNOOP_W-1):0]        scu_ext_aw_snoop;
  wire                                    scu_ext_aw_unique;
  wire                                    scu_ext_aw_valid;
  wire [7:0]                              scu_ext_wrmemattr;
  wire                                    scu_ext_cd_valid;
  wire [(`CA53_ACE_CRRESP_W-1):0]         scu_ext_cr_resp;
  wire                                    scu_ext_cr_valid;
  wire                                    scu_ext_db_ready;
  wire [(`CA53_SCU_EXT_DATA_W-1):0]       scu_ext_dw_data;
  wire [(`CA53_SCU_EXT_WID_W-1):0]        scu_ext_dw_id;
  wire                                    scu_ext_dw_last;
  wire [(`CA53_SCU_EXT_STRB_W-1):0]       scu_ext_dw_strb;
  wire                                    scu_ext_dw_valid;
  wire                                    scu_ext_rack;
  wire                                    scu_ext_wack;
  wire [NUM_CPUS-1:0]                     scu_broadcastinner;
  wire [(`CA53_DBDECERR_PKDED_W-1):0]     scu_db_decerr;
  wire [(`CA53_DBEXCLRSP_PKDED_W-1):0]    scu_db_excl_resp;
  wire [(`CA53_DBEXCLVAL_PKDED_W-1):0]    scu_db_excl_valid;
  wire [(`CA53_DBSLVERR_PKDED_W-1):0]     scu_db_slverr;
  wire [(`CA53_DRCHUNK_PKDED_W-1):0]      scu_dr_chunk;
  wire [(`CA53_DRDATA_PKDED_W-1):0]       scu_dr_data;
  wire [(`CA53_DRID_PKDED_W-1):0]         scu_dr_id;
  wire [(`CA53_DRRESP_PKDED_W-1):0]       scu_dr_resp;
  wire [(`CA53_DRVALID_PKDED_W-1):0]      scu_dr_valid;
  wire [(`CA53_RRID_PKDED_W-1):0]         scu_rr_id;
  wire [(`CA53_RRL2DB_PKDED_W-1):0]       scu_rr_l2db_id;
  wire [(`CA53_RRRESP_PKDED_W-1):0]       scu_rr_resp;
  wire [(`CA53_RRVALID_PKDED_W-1):0]      scu_rr_valid;
  wire [(`CA53_DVM_COMP_PKDED_W-1):0]     scu_dvm_complete;
  wire [(`CA53_REQBUFS_BUSY_PKDED_W-1):0] scu_reqbufs_busy;
  wire [(`CA53_DRAIN_STB_PKDED_W-1):0]    scu_drain_stb;
  wire [(`CA53_EVDONE_PKDED_W-1):0]       scu_ev_done;
  wire [(`CA53_SCU_EXT_ADDR_W-1):0]       scu_ext_ar_addr;
  wire [(`CA53_ACE_ARBAR_W-1):0]          scu_ext_ar_bar;
  wire [(`CA53_ACE_ARBURST_W-1):0]        scu_ext_ar_burst;
  wire [(`CA53_ACE_ARCACHE_W-1):0]        scu_ext_ar_cache;
  wire [(`CA53_ACE_ARDOMAIN_W-1):0]       scu_ext_ar_domain;
  wire [(`CA53_SCU_EXT_RID_W-1):0]        scu_ext_ar_id;
  wire [(`CA53_ACE_ARLEN_W-1):0]          scu_ext_ar_len;
  wire                                    scu_ext_ar_lock;
  wire [(`CA53_ACE_ARPROT_W-1):0]         scu_ext_ar_prot;
  wire [(`CA53_ACE_ARSIZE_W-1):0]         scu_ext_ar_size;
  wire [(`CA53_ACE_ARSNOOP_W-1):0]        scu_ext_ar_snoop;
  wire                                    scu_ext_ar_valid;
  wire [7:0]                              scu_ext_rdmemattr;
  wire [(`CA53_SCU_EXT_DATA_W-1):0]       scu_ext_cd_data;
  wire                                    scu_ext_cd_last;
  wire                                    scu_ext_dr_ready;
  wire                                    scu_txsactive;
  wire                                    scu_rxlinkactiveack;
  wire                                    scu_txlinkactivereq;
  wire                                    scu_txreqflitpend;
  wire                                    scu_txreqflitv;
  wire [99:0]                             scu_txreqflit;
  wire [7:0]                              scu_reqmemattr;
  wire                                    scu_txrspflitpend;
  wire                                    scu_txrspflitv;
  wire [44:0]                             scu_txrspflit;
  wire                                    scu_txdatflitpend;
  wire                                    scu_txdatflitv;
  wire [193:0]                            scu_txdatflit;
  wire                                    scu_rxsnplcrdv;
  wire                                    scu_rxrsplcrdv;
  wire                                    scu_rxdatlcrdv;
  wire                                    scu_acp_awready;
  wire                                    scu_acp_wready;
  wire                                    scu_acp_bvalid;
  wire [4:0]                              scu_acp_bid;
  wire [1:0]                              scu_acp_bresp;
  wire                                    scu_acp_arready;
  wire                                    scu_acp_rvalid;
  wire [4:0]                              scu_acp_rid;
  wire [127:0]                            scu_acp_rdata;
  wire [1:0]                              scu_acp_rresp;
  wire                                    scu_acp_rlast;
  wire [NUM_CPUS-1:0]                     scu_evnt_bus_acc_rd;
  wire [NUM_CPUS-1:0]                     scu_evnt_bus_acc_wr;
  wire [NUM_CPUS-1:0]                     scu_evnt_eviction;
  wire [NUM_CPUS-1:0]                     scu_evnt_bus_cycle;
  wire [NUM_CPUS-1:0]                     scu_evnt_l2_access;
  wire [NUM_CPUS-1:0]                     scu_evnt_l2_refill;
  wire [NUM_CPUS-1:0]                     scu_evnt_l2_wb;
  wire [NUM_CPUS-1:0]                     scu_evnt_snooped_data;
  wire [(`CA53_LEAVERAM_PKDED_W-1):0]     scu_leave_ramode;
  wire [NUM_CPUS-1:0]                     syncreqm;
  wire [NUM_CPUS-1:0]                     stb_wfx_ready;
  wire [NUM_CPUS-1:0]                     tlb_wfx_ready;
  wire [NUM_CPUS-1:0]                     etm_wfx_ready;
  wire [NUM_CPUS-1:0]                     gov_event_reg;
  wire                                   ACLKENS;
  wire                                   AINACTS;
  wire                                   AWREADYS;
  wire                                   AWVALIDS;
  wire [  4: 0]                          AWIDS;
  wire [ 39: 0]                          AWADDRS;
  wire [  7: 0]                          AWLENS;
  wire [  3: 0]                          AWCACHES;
  wire [  1: 0]                          AWUSERS;
  wire [  2: 0]                          AWPROTS;
  wire                                   WREADYS;
  wire                                   WVALIDS;
  wire [127: 0]                          WDATAS;
  wire [ 15: 0]                          WSTRBS;
  wire                                   WLASTS;
  wire                                   BREADYS;
  wire                                   BVALIDS;
  wire [  4: 0]                          BIDS;
  wire [  1: 0]                          BRESPS;
  wire                                   ARREADYS;
  wire                                   ARVALIDS;
  wire [  4: 0]                          ARIDS;
  wire [ 39: 0]                          ARADDRS;
  wire [  7: 0]                          ARLENS;
  wire [  3: 0]                          ARCACHES;
  wire [  1: 0]                          ARUSERS;
  wire [  2: 0]                          ARPROTS;
  wire                                   RREADYS;
  wire                                   RVALIDS;
  wire [  4: 0]                          RIDS;
  wire [127: 0]                          RDATAS;
  wire [  1: 0]                          RRESPS;
  wire                                   RLASTS;
  wire                                   SCLKEN;
  wire                                   SINACT;
  wire [  6: 0]                          NODEID;
  wire                                   RXSACTIVE;
  wire                                   RXLINKACTIVEREQ;
  wire                                   TXLINKACTIVEACK;
  wire                                   TXREQLCRDV;
  wire                                   TXRSPLCRDV;
  wire                                   TXDATLCRDV;
  wire                                   RXSNPFLITPEND;
  wire                                   RXSNPFLITV;
  wire [ 64: 0]                          RXSNPFLIT;
  wire                                   RXRSPFLITPEND;
  wire                                   RXRSPFLITV;
  wire [ 44: 0]                          RXRSPFLIT;
  wire                                   RXDATFLITPEND;
  wire                                   RXDATFLITV;
  wire [193: 0]                          RXDATFLIT;
  wire [  1: 0]                          SAMADDRMAP0;
  wire [  1: 0]                          SAMADDRMAP1;
  wire [  1: 0]                          SAMADDRMAP2;
  wire [  1: 0]                          SAMADDRMAP3;
  wire [  1: 0]                          SAMADDRMAP4;
  wire [  1: 0]                          SAMADDRMAP5;
  wire [  1: 0]                          SAMADDRMAP6;
  wire [  1: 0]                          SAMADDRMAP7;
  wire [  1: 0]                          SAMADDRMAP8;
  wire [  1: 0]                          SAMADDRMAP9;
  wire [  1: 0]                          SAMADDRMAP10;
  wire [  1: 0]                          SAMADDRMAP11;
  wire [  1: 0]                          SAMADDRMAP12;
  wire [  1: 0]                          SAMADDRMAP13;
  wire [  1: 0]                          SAMADDRMAP14;
  wire [  1: 0]                          SAMADDRMAP15;
  wire [ 39:24]                          SAMMNBASE;
  wire [  6: 0]                          SAMMNNODEID;
  wire [  6: 0]                          SAMHNI0NODEID;
  wire [  6: 0]                          SAMHNI1NODEID;
  wire [  6: 0]                          SAMHNF0NODEID;
  wire [  6: 0]                          SAMHNF1NODEID;
  wire [  6: 0]                          SAMHNF2NODEID;
  wire [  6: 0]                          SAMHNF3NODEID;
  wire [  6: 0]                          SAMHNF4NODEID;
  wire [  6: 0]                          SAMHNF5NODEID;
  wire [  6: 0]                          SAMHNF6NODEID;
  wire [  6: 0]                          SAMHNF7NODEID;
  wire [  2: 0]                          SAMHNFMODE;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // If Cortex-A53 is being used in a coherent system with other processors
  // using different cache line lengths, the CWG and ERG fields of the CTR can
  // be overridden in partner implementations by changing the two assignments
  // below.
  assign ctr_cwg        = `CA53_CTR_CWG;
  assign ctr_erg        = `CA53_CTR_ERG;

  // ------------------------------------------------------
  // Tie off any absent signals in current configuration
  // ------------------------------------------------------

  assign ACLKENS        =      1'b0;
  assign AINACTS        =      1'b0;
  assign AWVALIDS       =      1'b0;
  assign AWIDS          = {  5{1'b0}};
  assign AWADDRS        = { 40{1'b0}};
  assign AWLENS         = {  8{1'b0}};
  assign AWCACHES       = {  4{1'b0}};
  assign AWUSERS        = {  2{1'b0}};
  assign AWPROTS        = {  3{1'b0}};
  assign WVALIDS        =      1'b0;
  assign WDATAS         = {128{1'b0}};
  assign WSTRBS         = { 16{1'b0}};
  assign WLASTS         =      1'b0;
  assign BREADYS        =      1'b0;
  assign ARVALIDS       =      1'b0;
  assign ARIDS          = {  5{1'b0}};
  assign ARADDRS        = { 40{1'b0}};
  assign ARLENS         = {  8{1'b0}};
  assign ARCACHES       = {  4{1'b0}};
  assign ARUSERS        = {  2{1'b0}};
  assign ARPROTS        = {  3{1'b0}};
  assign RREADYS        =      1'b0;
  assign SCLKEN          =      1'b0;
  assign SINACT          =      1'b0;
  assign NODEID          = {  7{1'b0}};
  assign RXSACTIVE       =      1'b0;
  assign RXLINKACTIVEREQ =      1'b0;
  assign TXLINKACTIVEACK =      1'b0;
  assign TXREQLCRDV      =      1'b0;
  assign TXRSPLCRDV      =      1'b0;
  assign TXDATLCRDV      =      1'b0;
  assign RXSNPFLITPEND   =      1'b0;
  assign RXSNPFLITV      =      1'b0;
  assign RXSNPFLIT       = { 65{1'b0}};
  assign RXRSPFLITPEND   =      1'b0;
  assign RXRSPFLITV      =      1'b0;
  assign RXRSPFLIT       = { 45{1'b0}};
  assign RXDATFLITPEND   =      1'b0;
  assign RXDATFLITV      =      1'b0;
  assign RXDATFLIT       = {194{1'b0}};
  assign SAMADDRMAP0     = {  2{1'b0}};
  assign SAMADDRMAP1     = {  2{1'b0}};
  assign SAMADDRMAP2     = {  2{1'b0}};
  assign SAMADDRMAP3     = {  2{1'b0}};
  assign SAMADDRMAP4     = {  2{1'b0}};
  assign SAMADDRMAP5     = {  2{1'b0}};
  assign SAMADDRMAP6     = {  2{1'b0}};
  assign SAMADDRMAP7     = {  2{1'b0}};
  assign SAMADDRMAP8     = {  2{1'b0}};
  assign SAMADDRMAP9     = {  2{1'b0}};
  assign SAMADDRMAP10    = {  2{1'b0}};
  assign SAMADDRMAP11    = {  2{1'b0}};
  assign SAMADDRMAP12    = {  2{1'b0}};
  assign SAMADDRMAP13    = {  2{1'b0}};
  assign SAMADDRMAP14    = {  2{1'b0}};
  assign SAMADDRMAP15    = {  2{1'b0}};
  assign SAMMNBASE       = { 16{1'b0}};
  assign SAMMNNODEID     = {  7{1'b0}};
  assign SAMHNI0NODEID   = {  7{1'b0}};
  assign SAMHNI1NODEID   = {  7{1'b0}};
  assign SAMHNF0NODEID   = {  7{1'b0}};
  assign SAMHNF1NODEID   = {  7{1'b0}};
  assign SAMHNF2NODEID   = {  7{1'b0}};
  assign SAMHNF3NODEID   = {  7{1'b0}};
  assign SAMHNF4NODEID   = {  7{1'b0}};
  assign SAMHNF5NODEID   = {  7{1'b0}};
  assign SAMHNF6NODEID   = {  7{1'b0}};
  assign SAMHNF7NODEID   = {  7{1'b0}};
  assign SAMHNFMODE      = {  3{1'b0}};

  // Misc
  assign l1_dc_size     = L1_DCACHE_SIZE;
  
  // ------------------------------------------------------
  // Instantiate CPUs
  // ------------------------------------------------------

  generate for  (cpu = 0; cpu < NUM_CPUS; cpu = cpu + 1) begin : g_ca53_cpu
    ca53_cpu `CA53_CPU_PARAM_INST u_ca53_cpu (
      // Inputs
      .clk                           (clk_cpu[cpu]),
      .reset_n_cpu                   (reset_n_cpu[cpu]),
      .po_reset_n_cpu                (po_reset_n_cpu[cpu]),
      .DFTSE                         (DFTSE),
      .DFTRAMHOLD                    (DFTRAMHOLD),
      .DFTRSTDISABLE                 (DFTRSTDISABLE),
      .scu_ar_credit_i               (scu_ar_credit[cpu]),
      .scu_ar_block_i                (scu_ar_block[cpu]),
      .scu_dr_valid_i                (scu_dr_valid[cpu]),
      .scu_dr_id_i                   (scu_dr_id[((`CA53_DRID_W * (cpu+1))-1): (`CA53_DRID_W * cpu)]),
      .scu_dr_resp_i                 (scu_dr_resp[((`CA53_DRRESP_W * (cpu+1))-1): (`CA53_DRRESP_W * cpu)]),
      .scu_dr_chunk_i                (scu_dr_chunk[((`CA53_DRCHUNK_W * (cpu+1))-1): (`CA53_DRCHUNK_W * cpu)]),
      .scu_dr_data_i                 (scu_dr_data[((`CA53_DRDATA_W * (cpu+1))-1): (`CA53_DRDATA_W * cpu)]),
      .scu_rr_valid_i                (scu_rr_valid[cpu]),
      .scu_rr_id_i                   (scu_rr_id[((`CA53_RRID_W * (cpu+1))-1): (`CA53_RRID_W * cpu)]),
      .scu_rr_resp_i                 (scu_rr_resp[((`CA53_RRRESP_W * (cpu+1))-1): (`CA53_RRRESP_W * cpu)]),
      .scu_rr_l2db_id_i              (scu_rr_l2db_id[((`CA53_RRL2DB_W * (cpu+1))-1): (`CA53_RRL2DB_W * cpu)]),
      .scu_ev_done_i                 (scu_ev_done[((`CA53_EVDONE_W * (cpu+1))-1): (`CA53_EVDONE_W * cpu)]),
      .scu_db_excl_valid_i           (scu_db_excl_valid[cpu]),
      .scu_db_excl_resp_i            (scu_db_excl_resp[((`CA53_DBEXCLRSP_W * (cpu+1))-1): (`CA53_DBEXCLRSP_W * cpu)]),
      .scu_db_decerr_i               (scu_db_decerr[((`CA53_DBDECERR_W * (cpu+1))-1): (`CA53_DBDECERR_W * cpu)]),
      .scu_db_slverr_i               (scu_db_slverr[((`CA53_DBSLVERR_W * (cpu+1))-1): (`CA53_DBSLVERR_W * cpu)]),
      .scu_ac_valid_i                (scu_ac_valid[((`CA53_ACVALID_W * (cpu+1))-1): (`CA53_ACVALID_W * cpu)]),
      .scu_ac_id_i                   (scu_ac_id[((`CA53_ACID_W * (cpu+1))-1): (`CA53_ACID_W * cpu)]),
      .scu_ac_l2db_id_i              (scu_ac_l2db_id[((`CA53_ACL2DB_W * (cpu+1))-1): (`CA53_ACL2DB_W * cpu)]),
      .scu_ac_snoop_i                (scu_ac_snoop[((`CA53_ACSNOOP_W * (cpu+1))-1): (`CA53_ACSNOOP_W * cpu)]),
      .scu_ac_addr_i                 (scu_ac_addr[((`CA53_ACADDR_W * (cpu+1))-1): (`CA53_ACADDR_W * cpu)]),
      .scu_ac_way_i                  (scu_ac_way[((`CA53_ACWAY_W * (cpu+1))-1): (`CA53_ACWAY_W * cpu)]),
      .scu_dvm_complete_i            (scu_dvm_complete[((`CA53_DVM_COMP_W * (cpu+1))-1): (`CA53_DVM_COMP_W * cpu)]),
      .scu_reqbufs_busy_i            (scu_reqbufs_busy[((`CA53_REQBUFS_BUSY_W * (cpu+1))-1): (`CA53_REQBUFS_BUSY_W * cpu)]),
      .scu_drain_stb_i               (scu_drain_stb[((`CA53_DRAIN_STB_W * (cpu+1))-1): (`CA53_DRAIN_STB_W * cpu)]),
      .scu_leave_ramode_i            (scu_leave_ramode[((`CA53_LEAVERAM_W * (cpu+1))-1): (`CA53_LEAVERAM_W * cpu)]),
      .scu_evnt_l2_access_i          (scu_evnt_l2_access[cpu]),
      .scu_evnt_l2_refill_i          (scu_evnt_l2_refill[cpu]),
      .scu_evnt_l2_wb_i              (scu_evnt_l2_wb[cpu]),
      .scu_evnt_snooped_data_i       (scu_evnt_snooped_data[cpu]),
      .scu_evnt_bus_cycle_i          (scu_evnt_bus_cycle[cpu]),
      .scu_evnt_bus_acc_rd_i         (scu_evnt_bus_acc_rd[cpu]),
      .scu_evnt_bus_acc_wr_i         (scu_evnt_bus_acc_wr[cpu]),
      .scu_evnt_eviction_i           (scu_evnt_eviction[cpu]),
      .gic_irq_i                     (gic_irq[cpu]),
      .gic_fiq_i                     (gic_fiq[cpu]),
      .gic_virq_i                    (gic_virq[cpu]),
      .gic_vfiq_i                    (gic_vfiq[cpu]),
      .gov_sei_level_req_i           (gov_sei_level_req[cpu]),
      .gov_vsei_level_req_i          (gov_vsei_level_req[cpu]),
      .gov_rei_level_req_i           (gov_rei_level_req[cpu]),
      .gov_int_active_i              (gov_int_active[cpu]),
      .gic_icc_sre_el1_ns_sre_i      (gic_icc_sre_el1_ns_sre[cpu]),
      .gic_icc_sre_el1_s_sre_i       (gic_icc_sre_el1_s_sre[cpu]),
      .gic_icc_sre_el2_enable_i      (gic_icc_sre_el2_enable[cpu]),
      .gic_icc_sre_el2_sre_i         (gic_icc_sre_el2_sre[cpu]),
      .gic_icc_sre_el3_enable_i      (gic_icc_sre_el3_enable[cpu]),
      .gic_icc_sre_el3_sre_i         (gic_icc_sre_el3_sre[cpu]),
      .gic_ich_hcr_el2_tall0_i       (gic_ich_hcr_el2_tall0[cpu]),
      .gic_ich_hcr_el2_tall1_i       (gic_ich_hcr_el2_tall1[cpu]),
      .gic_ich_hcr_el2_tc_i          (gic_ich_hcr_el2_tc[cpu]),
      .gov_pseldbg_dbg_i             (gov_pseldbg_dbg[cpu]),
      .gov_pseldbg_pmu_i             (gov_pseldbg_pmu[cpu]),
      .gov_pseldbg_etm_i             (gov_pseldbg_etm[cpu]),
      .gov_paddrdbg_i                (gov_paddrdbg[((`CA53_PADDRDBG_W * (cpu+1))-1): (`CA53_PADDRDBG_W * cpu)]),
      .gov_paddrdbg31_i              (gov_paddrdbg31[cpu]),
      .gov_penabledbg_i              (gov_penabledbg[cpu]),
      .gov_pwdatadbg_i               (gov_pwdatadbg[((`CA53_PWDATADBG_W * (cpu+1))-1): (`CA53_PWDATADBG_W * cpu)]),
      .gov_pwritedbg_i               (gov_pwritedbg[cpu]),
      .gov_dbgen_i                   (gov_dbgen[cpu]),
      .gov_spiden_i                  (gov_spiden[cpu]),
      .gov_niden_i                   (gov_niden[cpu]),
      .gov_spniden_i                 (gov_spniden[cpu]),
      .gov_edbgrq_i                  (gov_edbgrq[cpu]),
      .gov_dbgrestart_i              (gov_dbgrestart[cpu]),
      .gov_dbgromaddr_i              (gov_dbgromaddr[39:12]),
      .gov_dbgromaddrv_i             (gov_dbgromaddrv),
      .gov_dbgpwrupreq_i             (gov_dbgpwrupreq[cpu]),
      .gov_dbgl1rstdisable_i         (gov_dbgl1rstdisable[cpu]),
      .gov_extin_i                   (gov_extin[((`CA53_ETMEXT_W * (cpu+1))-1): (`CA53_ETMEXT_W * cpu)]),
      .gov_edecr_osuce_i             (gov_edecr_osuce[cpu]),
      .gov_edecr_rce_i               (gov_edecr_rce[cpu]),
      .gov_edecr_ss_i                (gov_edecr_ss[cpu]),
      .gov_edlsr_slk_i               (gov_edlsr_slk[cpu]),
      .gov_pmlsr_slk_i               (gov_pmlsr_slk[cpu]),
      .gov_etmpdsr_rd_i              (gov_etmpdsr_rd[cpu]),
      .gov_stall_dsb_i               (gov_stall_dsb[cpu]),
      .gov_cp_ack_i                  (gov_cp_ack[cpu]),
      .gov_cp_rdata_i                (gov_cp_rdata[((`CA53_CPDATA_W * (cpu+1))-1): (`CA53_CPDATA_W * cpu)]),
      .gov_atclken_i                 (gov_atclken[cpu]),
      .gov_atreadym_i                (gov_atreadym[((`CA53_ATREADYM_W * (cpu+1))-1): (`CA53_ATREADYM_W * cpu)]),
      .gov_afvalidm_i                (gov_afvalidm[((`CA53_AFVALIDM_W * (cpu+1))-1): (`CA53_AFVALIDM_W * cpu)]),
      .gov_syncreqm_i                (gov_syncreqm[((`CA53_SYNCREQM_W * (cpu+1))-1): (`CA53_SYNCREQM_W * cpu)]),
      .gov_tsvalueb_i                (gov_tsvalueb[63:0]),
      .gov_pcnt_kernel_access_i      (gov_pcnt_kernel_access[cpu]),
      .gov_pcnt_usr_access_i         (gov_pcnt_usr_access[cpu]),
      .gov_vcnt_usr_access_i         (gov_vcnt_usr_access[cpu]),
      .gov_cntp_usr_access_i         (gov_cntp_usr_access[cpu]),
      .gov_cntv_usr_access_i         (gov_cntv_usr_access[cpu]),
      .gov_cntp_kernel_access_i      (gov_cntp_kernel_access[cpu]),
      .gov_rvbaraddr_i               (gov_rvbaraddr[((`CA53_RVBARADDR_W * (cpu+1))-1): (`CA53_RVBARADDR_W * cpu)]),
      .gov_aa64naa32_i               (gov_aa64naa32[cpu]),
      .gov_cryptodisable_i           (gov_cryptodisable[cpu]),
      .gov_cp15sdisable_i            (gov_cp15sdisable[cpu]),
      .gov_cfgend_i                  (gov_cfgend[cpu]),
      .gov_vinithi_i                 (gov_vinithi[cpu]),
      .gov_cfgte_i                   (gov_cfgte[cpu]),
      .gov_clusteridaff1_i           (gov_clusteridaff1[7:0]),
      .gov_clusteridaff2_i           (gov_clusteridaff2[7:0]),
      .gov_mbist_req_i               (gov_mbistreq_cpu[cpu]),
      .cpu_id_i                      (cpu[1:0]),
      .ctr_cwg_i                     (ctr_cwg[3:0]),
      .ctr_erg_i                     (ctr_erg[3:0]),
      .gov_periphbase_i              (gov_periphbase[39:18]),
      .gov_giccdisable_i             (gov_giccdisable),
      .gov_event_reg_i               (gov_event_reg[cpu]),
      .gov_wfx_drain_req_i           (gov_wfx_drain_req[cpu]),
      .gov_wfx_wake_i                (gov_wfx_wake[cpu]),
      .gov_standbywfi_i              (gov_standbywfi[cpu]),
      .gov_standbywfe_i              (gov_standbywfe[cpu]),
      .l2_size_i                     (l2_size[3:0]),
      .scu_broadcastinner_i          (scu_broadcastinner[cpu]),
      // Outputs
      .biu_ar_active_o               (biu_ar_active[((`CA53_ARACTIVE_W * (cpu+1))-1): (`CA53_ARACTIVE_W * cpu)]),
      .biu_ar_valid_o                (biu_ar_valid[((`CA53_ARVALID_W * (cpu+1))-1): (`CA53_ARVALID_W * cpu)]),
      .biu_ar_id_o                   (biu_ar_id[((`CA53_ARID_W * (cpu+1))-1): (`CA53_ARID_W * cpu)]),
      .biu_ar_type_o                 (biu_ar_type[((`CA53_ARTYPE_W * (cpu+1))-1): (`CA53_ARTYPE_W * cpu)]),
      .biu_ar_attrs_o                (biu_ar_attrs[((`CA53_ARATTRS_W * (cpu+1))-1): (`CA53_ARATTRS_W * cpu)]),
      .biu_ar_way_o                  (biu_ar_way[((`CA53_ARWAY_W * (cpu+1))-1): (`CA53_ARWAY_W * cpu)]),
      .biu_ar_addr_o                 (biu_ar_addr[((`CA53_ARADDR_W * (cpu+1))-1): (`CA53_ARADDR_W * cpu)]),
      .biu_ar_len_o                  (biu_ar_len[((`CA53_ARLEN_W * (cpu+1))-1): (`CA53_ARLEN_W * cpu)]),
      .biu_ar_size_o                 (biu_ar_size[((`CA53_ARSIZE_W * (cpu+1))-1): (`CA53_ARSIZE_W * cpu)]),
      .biu_ar_lock_o                 (biu_ar_lock[((`CA53_ARLOCK_W * (cpu+1))-1): (`CA53_ARLOCK_W * cpu)]),
      .biu_ar_priv_o                 (biu_ar_priv[((`CA53_ARPRIV_W * (cpu+1))-1): (`CA53_ARPRIV_W * cpu)]),
      .biu_dr_credit_o               (biu_dr_credit[((`CA53_DRCREDIT_W * (cpu+1))-1): (`CA53_DRCREDIT_W * cpu)]),
      .biu_dw_valid_o                (biu_dw_valid[((`CA53_DWVALID_W * (cpu+1))-1): (`CA53_DWVALID_W * cpu)]),
      .biu_dw_l2db_id_o              (biu_dw_l2db_id[((`CA53_DWL2DB_W * (cpu+1))-1): (`CA53_DWL2DB_W * cpu)]),
      .biu_dw_chunks_valid_o         (biu_dw_chunks_valid[((`CA53_DWCHUNKS_W * (cpu+1))-1): (`CA53_DWCHUNKS_W * cpu)]),
      .biu_dw_last_o                 (biu_dw_last[((`CA53_DWLAST_W * (cpu+1))-1): (`CA53_DWLAST_W * cpu)]),
      .biu_dw_strb_o                 (biu_dw_strb[((`CA53_DWSTRB_W * (cpu+1))-1): (`CA53_DWSTRB_W * cpu)]),
      .biu_dw_data_o                 (biu_dw_data[((`CA53_DWDATA_W * (cpu+1))-1): (`CA53_DWDATA_W * cpu)]),
      .biu_dw_err_o                  (biu_dw_err[((`CA53_DWERR_W * (cpu+1))-1): (`CA53_DWERR_W * cpu)]),
      .biu_dw_fatal_o                (biu_dw_fatal[((`CA53_DWFATAL_W * (cpu+1))-1): (`CA53_DWFATAL_W * cpu)]),
      .dcu_ac_ready_o                (dcu_ac_ready[((`CA53_ACREADY_W * (cpu+1))-1): (`CA53_ACREADY_W * cpu)]),
      .dcu_cr_valid_o                (dcu_cr_valid[((`CA53_CRVALID_W * (cpu+1))-1): (`CA53_CRVALID_W * cpu)]),
      .dcu_cr_id_o                   (dcu_cr_id[((`CA53_CRID_W * (cpu+1))-1): (`CA53_CRID_W * cpu)]),
      .dcu_cr_dirty_o                (dcu_cr_dirty[((`CA53_CRDIRTY_W * (cpu+1))-1): (`CA53_CRDIRTY_W * cpu)]),
      .dcu_cr_age_o                  (dcu_cr_age[((`CA53_CRAGE_W * (cpu+1))-1): (`CA53_CRAGE_W * cpu)]),
      .dcu_cr_alloc_o                (dcu_cr_alloc[((`CA53_CRALLOC_W * (cpu+1))-1): (`CA53_CRALLOC_W * cpu)]),
      .dcu_cr_migratory_o            (dcu_cr_migratory[((`CA53_CRMIG_W * (cpu+1))-1): (`CA53_CRMIG_W * cpu)]),
      .dcu_dvm_complete_o            (dcu_dvm_complete[((`CA53_DVM_COMP_W * (cpu+1))-1): (`CA53_DVM_COMP_W * cpu)]),
      .dpu_prdatadbg_o               (dpu_prdatadbg[((`CA53_PRDATADBG_W * (cpu+1))-1): (`CA53_PRDATADBG_W * cpu)]),
      .dpu_preadydbg_o               (dpu_preadydbg[cpu]),
      .dpu_pslverrdbg_o              (dpu_pslverrdbg[cpu]),
      .dpu_dbgack_o                  (dpu_dbgack[cpu]),
      .dpu_dbgtrigger_o              (dpu_dbgtrigger[cpu]),
      .dpu_commrx_o                  (dpu_commrx[cpu]),
      .dpu_commtx_o                  (dpu_commtx[cpu]),
      .dpu_ncommirq_o                (dpu_ncommirq[cpu]),
      .dpu_dbgrstreq_o               (dpu_dbgrstreq[cpu]),
      .dpu_dbgnopwrdwn_o             (dpu_dbgnopwrdwn[cpu]),
      .etm_atdatam_o                 (etm_atdatam[((`CA53_ATDATAM_W * (cpu+1))-1): (`CA53_ATDATAM_W * cpu)]),
      .etm_atvalidm_o                (etm_atvalidm[cpu]),
      .etm_atbytesm_o                (etm_atbytesm[((`CA53_ATBYTESM_W * (cpu+1))-1): (`CA53_ATBYTESM_W * cpu)]),
      .etm_afreadym_o                (etm_afreadym[cpu]),
      .etm_atidm_o                   (etm_atidm[((`CA53_ATIDM_W * (cpu+1))-1): (`CA53_ATIDM_W * cpu)]),
      .etm_prdatadbg_o               (etm_prdatadbg[((`CA53_PRDATADBG_W * (cpu+1))-1): (`CA53_PRDATADBG_W * cpu)]),
      .etm_preadydbg_o               (etm_preadydbg[cpu]),
      .etm_extout_o                  (etm_extout[((`CA53_ETMEXT_W * (cpu+1))-1): (`CA53_ETMEXT_W * cpu)]),
      .etm_oslock_o                  (etm_oslock[cpu]),
      .dcu_excl_mon_cleared_o        (dcu_excl_mon_cleared[cpu]),
      .dcu_cp_gov_addr_o             (dcu_cp_gov_addr[((`CA53_CPADDR_W * (cpu+1))-1): (`CA53_CPADDR_W * cpu)]),
      .dcu_cp_gov_ns_o               (dcu_cp_gov_ns[cpu]),
      .dcu_cp_gov_req_o              (dcu_cp_gov_req[cpu]),
      .dcu_cp_gov_sel_o              (dcu_cp_gov_sel[((`CA53_CPSEL_W * (cpu+1))-1): (`CA53_CPSEL_W * cpu)]),
      .dcu_cp_gov_wdata_o            (dcu_cp_gov_wdata[((`CA53_CPDATA_W * (cpu+1))-1): (`CA53_CPDATA_W * cpu)]),
      .dcu_cp_gov_wenable_o          (dcu_cp_gov_wenable[cpu]),
      .dpu_warmrstreq_o              (dpu_warmrstreq[cpu]),
      .dpu_smp_en_o                  (dpu_smp_en[cpu]),
      .dpu_sev_req_o                 (dpu_sev_req[cpu]),
      .dpu_clr_event_register_o      (dpu_clr_event_register[cpu]),
      .dpu_exception_level_o         (dpu_exception_level[((`CA53_EXCP_LEV_W * (cpu+1))-1): (`CA53_EXCP_LEV_W * cpu)]),
      .dpu_aarch64_at_el3_o          (dpu_aarch64_at_el3[cpu]),
      .dpu_dscr_halted_o             (dpu_dscr_halted[cpu]),
      .dpu_hcr_el2_fmo_o             (dpu_hcr_el2_fmo[cpu]),
      .dpu_hcr_el2_imo_o             (dpu_hcr_el2_imo[cpu]),
      .dpu_hcr_el2_amo_o             (dpu_hcr_el2_amo[cpu]),
      .dpu_monitor_mode_o            (dpu_monitor_mode[cpu]),
      .dpu_scr_el3_fiq_o             (dpu_scr_el3_fiq[cpu]),
      .dpu_scr_el3_irq_o             (dpu_scr_el3_irq[cpu]),
      .dpu_scr_el3_ns_o              (dpu_scr_el3_ns[cpu]),
      .dpu_rei_level_ack_o           (dpu_rei_level_ack[cpu]),
      .dpu_sei_level_ack_o           (dpu_sei_level_ack[cpu]),
      .dpu_vsei_level_ack_o          (dpu_vsei_level_ack[cpu]),
      .dpu_wfi_req_o                 (dpu_wfi_req[cpu]),
      .dpu_wfe_req_o                 (dpu_wfe_req[cpu]),
      .dpu_irq_pended_o              (dpu_irq_pended[cpu]),
      .dpu_fiq_pended_o              (dpu_fiq_pended[cpu]),
      .dpu_sei_pended_o              (dpu_sei_pended[cpu]),
      .dpu_irq_masked_o              (dpu_irq_masked[cpu]),
      .dpu_fiq_masked_o              (dpu_fiq_masked[cpu]),
      .dpu_sei_masked_o              (dpu_sei_masked[cpu]),
      .dpu_virq_pended_o             (dpu_virq_pended[cpu]),
      .dpu_vfiq_pended_o             (dpu_vfiq_pended[cpu]),
      .dpu_vsei_pended_o             (dpu_vsei_pended[cpu]),
      .dpu_virq_masked_o             (dpu_virq_masked[cpu]),
      .dpu_vfiq_masked_o             (dpu_vfiq_masked[cpu]),
      .dpu_vsei_masked_o             (dpu_vsei_masked[cpu]),
      .dpu_dbg_double_lock_set_o     (dpu_dbg_double_lock_set[cpu]),
      .dpu_ns_state_o                (dpu_ns_state[cpu]),
      .stb_wfx_ready_o               (stb_wfx_ready[cpu]),
      .biu_wfx_ready_o               (biu_wfx_ready[cpu]),
      .dcu_wfx_ready_o               (dcu_wfx_ready[cpu]),
      .ifu_wfx_ready_o               (ifu_wfx_ready[cpu]),
      .tlb_wfx_ready_o               (tlb_wfx_ready[cpu]),
      .etm_wfx_ready_o               (etm_wfx_ready[cpu]),
      .dpu_imp_abort_pending_o       (dpu_imp_abort_pending[cpu]),
      .dpu_cpuectlr_cpu_ret_delay_o  (dpu_cpuectlr_cpu_ret_delay[((`CA53_RET_CTL_W * (cpu+1))-1): (`CA53_RET_CTL_W * cpu)]),
      .dpu_cpuectlr_neon_ret_delay_o (dpu_cpuectlr_neon_ret_delay[((`CA53_RET_CTL_W * (cpu+1))-1): (`CA53_RET_CTL_W * cpu)]),
      .dpu_neon_active_o             (dpu_neon_active[cpu]),
      .gov_stall_neon_i              (gov_stall_neon[cpu]),
      .dpu_npmuirq_o                 (dpu_npmuirq[cpu]),
      .dpu_pmuevent_o                (dpu_pmuevent[((`CA53_PMUEVNT_CPU_W * (cpu+1))-1): (`CA53_PMUEVNT_CPU_W * cpu)])
    );  // u_ca53_cpu
  end endgenerate

  // ------------------------------------------------------
  // Pack buses for the L2 memory system
  // ------------------------------------------------------

  assign rvbaraddr[((`CA53_RVBARADDR_W *1)-1):(`CA53_RVBARADDR_W *0)] = RVBARADDR0;
  assign rvbaraddr[((`CA53_RVBARADDR_W *2)-1):(`CA53_RVBARADDR_W *1)] = RVBARADDR1;
  assign rvbaraddr[((`CA53_RVBARADDR_W *3)-1):(`CA53_RVBARADDR_W *2)] = RVBARADDR2;
  assign rvbaraddr[((`CA53_RVBARADDR_W *4)-1):(`CA53_RVBARADDR_W *3)] = RVBARADDR3;
  assign atreadym[0]                                                  = ATREADYM0;
  assign atreadym[1]                                                  = ATREADYM1;
  assign atreadym[2]                                                  = ATREADYM2;
  assign atreadym[3]                                                  = ATREADYM3;
  assign afvalidm[0]                                                  = AFVALIDM0;
  assign afvalidm[1]                                                  = AFVALIDM1;
  assign afvalidm[2]                                                  = AFVALIDM2;
  assign afvalidm[3]                                                  = AFVALIDM3;
  assign syncreqm[0]                                                  = SYNCREQM0;
  assign syncreqm[1]                                                  = SYNCREQM1;
  assign syncreqm[2]                                                  = SYNCREQM2;
  assign syncreqm[3]                                                  = SYNCREQM3;

  // ------------------------------------------------------
  // SCU-L2
  // ------------------------------------------------------

  ca53_l2 `CA53_L2_PARAM_INST u_ca53_l2 (
    /*ARMAUTO*/
    // Inputs
    .CLKIN                         (CLKIN),
    .DFTSE                         (DFTSE),
    .DFTRSTDISABLE                 (DFTRSTDISABLE),
    .DFTRAMHOLD                    (DFTRAMHOLD),
    .DFTMCPHOLD                    (DFTMCPHOLD),
    .ncpuporeset                   (nCPUPORESET[NUM_CPUS-1:0]),
    .ncorereset                    (nCORERESET[NUM_CPUS-1:0]),
    .nl2reset                      (nL2RESET),
    .nmbistreset                   (nMBISTRESET),
    .l2rstdisable_i                (L2RSTDISABLE),
    .cfgend_i                      (CFGEND[NUM_CPUS-1:0]),
    .vinithi_i                     (VINITHI[NUM_CPUS-1:0]),
    .cfgte_i                       (CFGTE[NUM_CPUS-1:0]),
    .cp15sdisable_i                (CP15SDISABLE[NUM_CPUS-1:0]),
    .clusteridaff1_i               (CLUSTERIDAFF1[  7:0]),
    .clusteridaff2_i               (CLUSTERIDAFF2[  7:0]),
    .etm_oslock_i                  (etm_oslock[NUM_CPUS-1:0]),
    .aa64naa32_i                   (AA64nAA32[NUM_CPUS-1:0]),
    .rvbaraddr_i                   (rvbaraddr[(`CA53_RVBARADDR_PKDED_W-1):0]),
    .cryptodisable_i               (CRYPTODISABLE[NUM_CPUS-1:0]),
    .nfiq_i                        (nFIQ[NUM_CPUS-1:0]),
    .nirq_i                        (nIRQ[NUM_CPUS-1:0]),
    .nsei_i                        (nSEI[NUM_CPUS-1:0]),
    .nrei_i                        (nREI[NUM_CPUS-1:0]),
    .nvfiq_i                       (nVFIQ[NUM_CPUS-1:0]),
    .nvirq_i                       (nVIRQ[NUM_CPUS-1:0]),
    .nvsei_i                       (nVSEI[NUM_CPUS-1:0]),
    .periphbase_i                  (PERIPHBASE[ 39:18]),
    .giccdisable_i                 (GICCDISABLE),
    .icdtvalid_i                   (ICDTVALID),
    .icdtdata_i                    (ICDTDATA[ 15:0]),
    .icdtlast_i                    (ICDTLAST),
    .icdtdest_i                    (ICDTDEST[  1:0]),
    .icctready_i                   (ICCTREADY),
    .cntvalueb_i                   (CNTVALUEB[ 63:0]),
    .cntclken_i                    (CNTCLKEN),
    .tsvalueb_i                    (TSVALUEB[ 63:0]),
    .clrexmonreq_i                 (CLREXMONREQ),
    .eventi_i                      (EVENTI),
    .l2flushreq_i                  (L2FLUSHREQ),
    .cpuqreqn_i                    (CPUQREQn[NUM_CPUS-1:0]),
    .neonqreqn_i                   (NEONQREQn[NUM_CPUS-1:0]),
    .l2qreqn_i                     (L2QREQn),
    .broadcastcachemaint_i         (BROADCASTCACHEMAINT),
    .broadcastinner_i              (BROADCASTINNER),
    .broadcastouter_i              (BROADCASTOUTER),
    .aclkenm_i                     (ACLKENM),
    .acinactm_i                    (ACINACTM),
    .sysbardisable_i               (SYSBARDISABLE),
    .awreadym_i                    (AWREADYM),
    .wreadym_i                     (WREADYM),
    .bvalidm_i                     (BVALIDM),
    .bidm_i                        (BIDM[`CA53_SCU_EXT_WID_W-1:0]),
    .brespm_i                      (BRESPM[`CA53_ACE_BRESP_W-1:0]),
    .arreadym_i                    (ARREADYM),
    .rvalidm_i                     (RVALIDM),
    .ridm_i                        (RIDM[`CA53_SCU_EXT_RID_W-1:0]),
    .rdatam_i                      (RDATAM[`CA53_SCU_EXT_DATA_W-1:0]),
    .rrespm_i                      (RRESPM[`CA53_ACE_RRESP_W-1:0]),
    .rlastm_i                      (RLASTM),
    .acvalidm_i                    (ACVALIDM),
    .acaddrm_i                     (ACADDRM[`CA53_SCU_EXT_ADDR_W-1:0]),
    .acprotm_i                     (ACPROTM[`CA53_ACE_ACPROT_W-1:0]),
    .acsnoopm_i                    (ACSNOOPM[`CA53_ACE_ACSNOOP_W-1:0]),
    .crreadym_i                    (CRREADYM),
    .cdreadym_i                    (CDREADYM),
    .sclken_i                      (SCLKEN),
    .sinact_i                      (SINACT),
    .nodeid_i                      (NODEID[6:0]),
    .rxsactive_i                   (RXSACTIVE),
    .rxlinkactivereq_i             (RXLINKACTIVEREQ),
    .txlinkactiveack_i             (TXLINKACTIVEACK),
    .txreqlcrdv_i                  (TXREQLCRDV),
    .txrsplcrdv_i                  (TXRSPLCRDV),
    .txdatlcrdv_i                  (TXDATLCRDV),
    .rxsnpflitpend_i               (RXSNPFLITPEND),
    .rxsnpflitv_i                  (RXSNPFLITV),
    .rxsnpflit_i                   (RXSNPFLIT[64:0]),
    .rxrspflitpend_i               (RXRSPFLITPEND),
    .rxrspflitv_i                  (RXRSPFLITV),
    .rxrspflit_i                   (RXRSPFLIT[44:0]),
    .rxdatflitpend_i               (RXDATFLITPEND),
    .rxdatflitv_i                  (RXDATFLITV),
    .rxdatflit_i                   (RXDATFLIT[193:0]),
    .samaddrmap0_i                 (SAMADDRMAP0[1:0]),
    .samaddrmap1_i                 (SAMADDRMAP1[1:0]),
    .samaddrmap2_i                 (SAMADDRMAP2[1:0]),
    .samaddrmap3_i                 (SAMADDRMAP3[1:0]),
    .samaddrmap4_i                 (SAMADDRMAP4[1:0]),
    .samaddrmap5_i                 (SAMADDRMAP5[1:0]),
    .samaddrmap6_i                 (SAMADDRMAP6[1:0]),
    .samaddrmap7_i                 (SAMADDRMAP7[1:0]),
    .samaddrmap8_i                 (SAMADDRMAP8[1:0]),
    .samaddrmap9_i                 (SAMADDRMAP9[1:0]),
    .samaddrmap10_i                (SAMADDRMAP10[1:0]),
    .samaddrmap11_i                (SAMADDRMAP11[1:0]),
    .samaddrmap12_i                (SAMADDRMAP12[1:0]),
    .samaddrmap13_i                (SAMADDRMAP13[1:0]),
    .samaddrmap14_i                (SAMADDRMAP14[1:0]),
    .samaddrmap15_i                (SAMADDRMAP15[1:0]),
    .sammnbase_i                   (SAMMNBASE[39:24]),
    .sammnnodeid_i                 (SAMMNNODEID[6:0]),
    .samhni0nodeid_i               (SAMHNI0NODEID[6:0]),
    .samhni1nodeid_i               (SAMHNI1NODEID[6:0]),
    .samhnf0nodeid_i               (SAMHNF0NODEID[6:0]),
    .samhnf1nodeid_i               (SAMHNF1NODEID[6:0]),
    .samhnf2nodeid_i               (SAMHNF2NODEID[6:0]),
    .samhnf3nodeid_i               (SAMHNF3NODEID[6:0]),
    .samhnf4nodeid_i               (SAMHNF4NODEID[6:0]),
    .samhnf5nodeid_i               (SAMHNF5NODEID[6:0]),
    .samhnf6nodeid_i               (SAMHNF6NODEID[6:0]),
    .samhnf7nodeid_i               (SAMHNF7NODEID[6:0]),
    .samhnfmode_i                  (SAMHNFMODE[2:0]),
    .aclkens_i                     (ACLKENS),
    .ainacts_i                     (AINACTS),
    .awvalids_i                    (AWVALIDS),
    .awids_i                       (AWIDS[  4:0]),
    .awaddrs_i                     (AWADDRS[ 39:0]),
    .awlens_i                      (AWLENS[  7:0]),
    .awcaches_i                    (AWCACHES[  3:0]),
    .awusers_i                     (AWUSERS[  1:0]),
    .awprots_i                     (AWPROTS[  2:0]),
    .wvalids_i                     (WVALIDS),
    .wdatas_i                      (WDATAS[127:0]),
    .wstrbs_i                      (WSTRBS[ 15:0]),
    .wlasts_i                      (WLASTS),
    .breadys_i                     (BREADYS),
    .arvalids_i                    (ARVALIDS),
    .arids_i                       (ARIDS[  4:0]),
    .araddrs_i                     (ARADDRS[ 39:0]),
    .arlens_i                      (ARLENS[  7:0]),
    .arcaches_i                    (ARCACHES[  3:0]),
    .arusers_i                     (ARUSERS[  1:0]),
    .arprots_i                     (ARPROTS[  2:0]),
    .rreadys_i                     (RREADYS),
    .npresetdbg_i                  (nPRESETDBG),
    .pclkendbg_i                   (PCLKENDBG),
    .pseldbg_i                     (PSELDBG),
    .paddrdbg_i                    (PADDRDBG[ 21: 2]),
    .paddrdbg31_i                  (PADDRDBG31),
    .penabledbg_i                  (PENABLEDBG),
    .pwritedbg_i                   (PWRITEDBG),
    .pwdatadbg_i                   (PWDATADBG[ 31:0]),
    .dpu_prdatadbg_i               (dpu_prdatadbg[(`CA53_PRDATADBG_PKDED_W-1):0]),
    .dpu_preadydbg_i               (dpu_preadydbg[NUM_CPUS-1: 0]),
    .dpu_pslverrdbg_i              (dpu_pslverrdbg[NUM_CPUS-1: 0]),
    .etm_prdatadbg_i               (etm_prdatadbg[(`CA53_PRDATADBG_PKDED_W-1):0]),
    .etm_preadydbg_i               (etm_preadydbg[NUM_CPUS-1: 0]),
    .etm_extout_i                  (etm_extout[(`CA53_ETMEXT_PKDED_W-1):0]),
    .dcu_excl_mon_cleared_i        (dcu_excl_mon_cleared[NUM_CPUS-1: 0]),
    .dcu_cp_gov_addr_i             (dcu_cp_gov_addr[(`CA53_CPADDR_PKDED_W-1):0]),
    .dcu_cp_gov_ns_i               (dcu_cp_gov_ns[NUM_CPUS-1: 0]),
    .dcu_cp_gov_req_i              (dcu_cp_gov_req[NUM_CPUS-1: 0]),
    .dcu_cp_gov_sel_i              (dcu_cp_gov_sel[(`CA53_CPSEL_PKDED_W-1):0]),
    .dcu_cp_gov_wdata_i            (dcu_cp_gov_wdata[(`CA53_CPDATA_PKDED_W-1):0]),
    .dcu_cp_gov_wenable_i          (dcu_cp_gov_wenable[NUM_CPUS-1: 0]),
    .dbgromaddr_i                  (DBGROMADDR[ 39:12]),
    .dbgromaddrv_i                 (DBGROMADDRV),
    .edbgrq_i                      (EDBGRQ[NUM_CPUS-1:0]),
    .dbgen_i                       (DBGEN[NUM_CPUS-1:0]),
    .spiden_i                      (SPIDEN[NUM_CPUS-1:0]),
    .niden_i                       (NIDEN[NUM_CPUS-1:0]),
    .spniden_i                     (SPNIDEN[NUM_CPUS-1:0]),
    .dbgpwrdup_i                   (DBGPWRDUP[NUM_CPUS-1:0]),
    .dbgl1rstdisable_i             (DBGL1RSTDISABLE),
    .atclken_i                     (ATCLKEN),
    .atreadym_i                    (atreadym[(`CA53_ATREADYM_PKDED_W-1):0]),
    .afvalidm_i                    (afvalidm[(`CA53_AFVALIDM_PKDED_W-1):0]),
    .etm_atdatam_i                 (etm_atdatam[(`CA53_ATDATAM_PKDED_W-1):0]),
    .etm_atvalidm_i                (etm_atvalidm[(`CA53_ATVALIDM_PKDED_W-1):0]),
    .etm_atbytesm_i                (etm_atbytesm[(`CA53_ATBYTESM_PKDED_W-1):0]),
    .etm_afreadym_i                (etm_afreadym[(`CA53_AFREADYM_PKDED_W-1):0]),
    .etm_atidm_i                   (etm_atidm[(`CA53_ATIDM_PKDED_W-1):0]),
    .syncreqm_i                    (syncreqm[(`CA53_SYNCREQM_PKDED_W-1):0]),
    .ctichin_i                     (CTICHIN[3:0]),
    .ctichoutack_i                 (CTICHOUTACK[3:0]),
    .ctiirqack_i                   (CTIIRQACK[NUM_CPUS-1:0]),
    .cisbypass_i                   (CISBYPASS),
    .cihsbypass_i                  (CIHSBYPASS[3:0]),
    .dpu_warmrstreq_i              (dpu_warmrstreq[NUM_CPUS-1:0]),
    .dpu_dbgtrigger_i              (dpu_dbgtrigger[NUM_CPUS-1:0]),
    .dpu_dbgack_i                  (dpu_dbgack[NUM_CPUS-1:0]),
    .dpu_commrx_i                  (dpu_commrx[NUM_CPUS-1:0]),
    .dpu_commtx_i                  (dpu_commtx[NUM_CPUS-1:0]),
    .dpu_ncommirq_i                (dpu_ncommirq[NUM_CPUS-1:0]),
    .dpu_dbgrstreq_i               (dpu_dbgrstreq[NUM_CPUS-1:0]),
    .dpu_dbgnopwrdwn_i             (dpu_dbgnopwrdwn[NUM_CPUS-1:0]),
    .dpu_clr_event_register_i      (dpu_clr_event_register[NUM_CPUS-1:0]),
    .dpu_exception_level_i         (dpu_exception_level[(`CA53_EXCP_LEV_PKDED_W-1):0]),
    .dpu_aarch64_at_el3_i          (dpu_aarch64_at_el3[NUM_CPUS-1:0]),
    .dpu_dscr_halted_i             (dpu_dscr_halted[NUM_CPUS-1:0]),
    .dpu_hcr_el2_fmo_i             (dpu_hcr_el2_fmo[NUM_CPUS-1:0]),
    .dpu_hcr_el2_imo_i             (dpu_hcr_el2_imo[NUM_CPUS-1:0]),
    .dpu_hcr_el2_amo_i             (dpu_hcr_el2_amo[NUM_CPUS-1:0]),
    .dpu_monitor_mode_i            (dpu_monitor_mode[NUM_CPUS-1:0]),
    .dpu_rei_level_ack_i           (dpu_rei_level_ack[NUM_CPUS-1:0]),
    .dpu_scr_el3_fiq_i             (dpu_scr_el3_fiq[NUM_CPUS-1:0]),
    .dpu_scr_el3_irq_i             (dpu_scr_el3_irq[NUM_CPUS-1:0]),
    .dpu_scr_el3_ns_i              (dpu_scr_el3_ns[NUM_CPUS-1:0]),
    .dpu_sei_level_ack_i           (dpu_sei_level_ack[NUM_CPUS-1:0]),
    .dpu_vsei_level_ack_i          (dpu_vsei_level_ack[NUM_CPUS-1:0]),
    .dpu_wfi_req_i                 (dpu_wfi_req[NUM_CPUS-1:0]),
    .dpu_wfe_req_i                 (dpu_wfe_req[NUM_CPUS-1:0]),
    .dpu_irq_pended_i              (dpu_irq_pended[NUM_CPUS-1:0]),
    .dpu_fiq_pended_i              (dpu_fiq_pended[NUM_CPUS-1:0]),
    .dpu_sei_pended_i              (dpu_sei_pended[NUM_CPUS-1:0]),
    .dpu_irq_masked_i              (dpu_irq_masked[NUM_CPUS-1:0]),
    .dpu_fiq_masked_i              (dpu_fiq_masked[NUM_CPUS-1:0]),
    .dpu_sei_masked_i              (dpu_sei_masked[NUM_CPUS-1:0]),
    .dpu_virq_pended_i             (dpu_virq_pended[NUM_CPUS-1:0]),
    .dpu_vfiq_pended_i             (dpu_vfiq_pended[NUM_CPUS-1:0]),
    .dpu_vsei_pended_i             (dpu_vsei_pended[NUM_CPUS-1:0]),
    .dpu_virq_masked_i             (dpu_virq_masked[NUM_CPUS-1:0]),
    .dpu_vfiq_masked_i             (dpu_vfiq_masked[NUM_CPUS-1:0]),
    .dpu_vsei_masked_i             (dpu_vsei_masked[NUM_CPUS-1:0]),
    .dpu_dbg_double_lock_set_i     (dpu_dbg_double_lock_set[NUM_CPUS-1:0]),
    .dpu_ns_state_i                (dpu_ns_state[NUM_CPUS-1:0]),
    .stb_wfx_ready_i               (stb_wfx_ready[NUM_CPUS-1:0]),
    .biu_wfx_ready_i               (biu_wfx_ready[NUM_CPUS-1:0]),
    .dcu_wfx_ready_i               (dcu_wfx_ready[NUM_CPUS-1:0]),
    .ifu_wfx_ready_i               (ifu_wfx_ready[NUM_CPUS-1:0]),
    .tlb_wfx_ready_i               (tlb_wfx_ready[NUM_CPUS-1:0]),
    .etm_wfx_ready_i               (etm_wfx_ready[NUM_CPUS-1:0]),
    .dpu_imp_abort_pending_i       (dpu_imp_abort_pending[NUM_CPUS-1:0]),
    .dpu_cpuectlr_cpu_ret_delay_i  (dpu_cpuectlr_cpu_ret_delay[(`CA53_RET_CTL_PKDED_W-1):0]),
    .dpu_cpuectlr_neon_ret_delay_i (dpu_cpuectlr_neon_ret_delay[(`CA53_RET_CTL_PKDED_W-1):0]),
    .dpu_neon_active_i             (dpu_neon_active[NUM_CPUS-1: 0]),
    .dpu_npmuirq_i                 (dpu_npmuirq[NUM_CPUS-1:0]),
    .dpu_pmuevent_i                (dpu_pmuevent[(`CA53_PMUEVNT_CPU_PKDED_W-1):0]),
    .dpu_smp_en_i                  (dpu_smp_en[NUM_CPUS-1:0]),
    .dpu_sev_req_i                 (dpu_sev_req[NUM_CPUS-1:0]),
    .biu_ar_active_i               (biu_ar_active[(`CA53_ARACTIVE_PKDED_W-1):0]),
    .biu_ar_valid_i                (biu_ar_valid[(`CA53_ARVALID_PKDED_W-1):0]),
    .biu_ar_id_i                   (biu_ar_id[(`CA53_ARID_PKDED_W-1):0]),
    .biu_ar_type_i                 (biu_ar_type[(`CA53_ARTYPE_PKDED_W-1):0]),
    .biu_ar_attrs_i                (biu_ar_attrs[(`CA53_ARATTRS_PKDED_W-1):0]),
    .biu_ar_way_i                  (biu_ar_way[(`CA53_ARWAY_PKDED_W-1):0]),
    .biu_ar_addr_i                 (biu_ar_addr[(`CA53_ARADDR_PKDED_W-1):0]),
    .biu_ar_len_i                  (biu_ar_len[(`CA53_ARLEN_PKDED_W-1):0]),
    .biu_ar_size_i                 (biu_ar_size[(`CA53_ARSIZE_PKDED_W-1):0]),
    .biu_ar_lock_i                 (biu_ar_lock[(`CA53_ARLOCK_PKDED_W-1):0]),
    .biu_ar_priv_i                 (biu_ar_priv[(`CA53_ARPRIV_PKDED_W-1):0]),
    .biu_dr_credit_i               (biu_dr_credit[(`CA53_DRCREDIT_PKDED_W-1):0]),
    .biu_dw_valid_i                (biu_dw_valid[(`CA53_DWVALID_PKDED_W-1):0]),
    .biu_dw_l2db_id_i              (biu_dw_l2db_id[(`CA53_DWL2DB_PKDED_W-1):0]),
    .biu_dw_chunks_valid_i         (biu_dw_chunks_valid[(`CA53_DWCHUNKS_PKDED_W-1):0]),
    .biu_dw_last_i                 (biu_dw_last[(`CA53_DWLAST_PKDED_W-1):0]),
    .biu_dw_strb_i                 (biu_dw_strb[(`CA53_DWSTRB_PKDED_W-1):0]),
    .biu_dw_data_i                 (biu_dw_data[(`CA53_DWDATA_PKDED_W-1):0]),
    .biu_dw_err_i                  (biu_dw_err[(`CA53_DWERR_PKDED_W-1):0]),
    .biu_dw_fatal_i                (biu_dw_fatal[(`CA53_DWFATAL_PKDED_W-1):0]),
    .dcu_ac_ready_i                (dcu_ac_ready[(`CA53_ACREADY_PKDED_W-1):0]),
    .dcu_cr_valid_i                (dcu_cr_valid[(`CA53_CRVALID_PKDED_W-1):0]),
    .dcu_cr_id_i                   (dcu_cr_id[(`CA53_CRID_PKDED_W-1):0]),
    .dcu_cr_dirty_i                (dcu_cr_dirty[(`CA53_CRDIRTY_PKDED_W-1):0]),
    .dcu_cr_age_i                  (dcu_cr_age[(`CA53_CRAGE_PKDED_W-1):0]),
    .dcu_cr_alloc_i                (dcu_cr_alloc[(`CA53_CRALLOC_PKDED_W-1):0]),
    .dcu_cr_migratory_i            (dcu_cr_migratory[(`CA53_CRMIG_PKDED_W-1):0]),
    .dcu_dvm_complete_i            (dcu_dvm_complete[(`CA53_DVM_COMP_PKDED_W-1):0]),
    .mbistreq_i                    (MBISTREQ),
    .mbistaddr0_i                  (mbistaddr0[(`CA53_MBIST0_ADDR_W-1): 0]),
    .mbistaddr1_i                  (mbistaddr1[(`CA53_MBIST1_ADDR_W-1): 0]),
    .mbistindata0_i                (mbistindata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .mbistindata1_i                (mbistindata1[(`CA53_MBIST1_DATA_W-1): 0]),
    .mbistwriteen0_i               (mbistwriteen0),
    .mbistwriteen1_i               (mbistwriteen1),
    .mbistreaden0_i                (mbistreaden0),
    .mbistreaden1_i                (mbistreaden1),
    .mbistarray0_i                 (mbistarray0[(`CA53_MBIST0_RAMARRAY_W-1):0]),
    .mbistarray1_i                 (mbistarray1[(`CA53_MBIST1_RAMARRAY_W-1):0]),
    .mbistbe0_i                    (mbistbe0[(`CA53_MBIST0_BE_W-1):0]),
    .mbistbe1_i                    (mbistbe1[(`CA53_MBIST1_BE_W-1):0]),
    .mbistcfg0_i                   (mbistcfg0),
    .mbistcfg1_i                   (mbistcfg1),
    .l1_dc_size_i                  (l1_dc_size[(`CA53_L1DC_SIZE_W-1):0]),
    // Outputs
    .clk_cpu                       (clk_cpu[NUM_CPUS-1:0]),
    .reset_n_cpu                   (reset_n_cpu[NUM_CPUS-1:0]),
    .po_reset_n_cpu                (po_reset_n_cpu[NUM_CPUS-1:0]),
    .warmrstreq_o                  (WARMRSTREQ[NUM_CPUS-1:0]),
    .gov_cfgend_o                  (gov_cfgend[NUM_CPUS-1:0]),
    .gov_vinithi_o                 (gov_vinithi[NUM_CPUS-1:0]),
    .gov_cfgte_o                   (gov_cfgte[NUM_CPUS-1:0]),
    .gov_cp15sdisable_o            (gov_cp15sdisable[NUM_CPUS-1:0]),
    .gov_clusteridaff1_o           (gov_clusteridaff1[  7:0]),
    .gov_clusteridaff2_o           (gov_clusteridaff2[  7:0]),
    .gov_aa64naa32_o               (gov_aa64naa32[NUM_CPUS-1:0]),
    .gov_rvbaraddr_o               (gov_rvbaraddr[(`CA53_RVBARADDR_PKDED_W-1):0]),
    .gov_cryptodisable_o           (gov_cryptodisable[NUM_CPUS-1:0]),
    .gov_stall_neon_o              (gov_stall_neon[NUM_CPUS-1:0]),
    .gic_irq_o                     (gic_irq[NUM_CPUS-1:0]),
    .gic_fiq_o                     (gic_fiq[NUM_CPUS-1:0]),
    .gic_virq_o                    (gic_virq[NUM_CPUS-1:0]),
    .gic_vfiq_o                    (gic_vfiq[NUM_CPUS-1:0]),
    .gov_sei_level_req_o           (gov_sei_level_req[NUM_CPUS-1:0]),
    .gov_vsei_level_req_o          (gov_vsei_level_req[NUM_CPUS-1:0]),
    .gov_rei_level_req_o           (gov_rei_level_req[NUM_CPUS-1:0]),
    .gov_int_active_o              (gov_int_active[NUM_CPUS-1:0]),
    .gic_icc_sre_el1_ns_sre_o      (gic_icc_sre_el1_ns_sre[NUM_CPUS-1: 0]),
    .gic_icc_sre_el1_s_sre_o       (gic_icc_sre_el1_s_sre[NUM_CPUS-1: 0]),
    .gic_icc_sre_el2_enable_o      (gic_icc_sre_el2_enable[NUM_CPUS-1: 0]),
    .gic_icc_sre_el2_sre_o         (gic_icc_sre_el2_sre[NUM_CPUS-1: 0]),
    .gic_icc_sre_el3_enable_o      (gic_icc_sre_el3_enable[NUM_CPUS-1: 0]),
    .gic_icc_sre_el3_sre_o         (gic_icc_sre_el3_sre[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tall0_o       (gic_ich_hcr_el2_tall0[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tall1_o       (gic_ich_hcr_el2_tall1[NUM_CPUS-1: 0]),
    .gic_ich_hcr_el2_tc_o          (gic_ich_hcr_el2_tc[NUM_CPUS-1: 0]),
    .nvcpumntirq_o                 (nVCPUMNTIRQ[NUM_CPUS-1:0]),
    .gov_periphbase_o              (gov_periphbase[ 39:18]),
    .gov_giccdisable_o             (gov_giccdisable),
    .icdtready_o                   (ICDTREADY),
    .icctvalid_o                   (ICCTVALID),
    .icctdata_o                    (ICCTDATA[ 15:0]),
    .icctlast_o                    (ICCTLAST),
    .icctid_o                      (ICCTID[  1:0]),
    .gov_standbywfi_o              (gov_standbywfi[NUM_CPUS-1:0]),
    .gov_standbywfe_o              (gov_standbywfe[NUM_CPUS-1:0]),
    .standbywfi_o                  (STANDBYWFI[NUM_CPUS-1:0]),
    .standbywfe_o                  (STANDBYWFE[NUM_CPUS-1:0]),
    .standbywfil2_o                (STANDBYWFIL2),
    .gov_wfx_drain_req_o           (gov_wfx_drain_req[NUM_CPUS-1:0]),
    .gov_wfx_wake_o                (gov_wfx_wake[NUM_CPUS-1:0]),
    .clrexmonack_o                 (CLREXMONACK),
    .evento_o                      (EVENTO),
    .gov_mbistreq_cpu_o            (gov_mbistreq_cpu[NUM_CPUS-1:0]),
    .gov_event_reg_o               (gov_event_reg[NUM_CPUS-1:0]),
    .ncntpsirq_o                   (nCNTPSIRQ[NUM_CPUS-1:0]),
    .ncntpnsirq_o                  (nCNTPNSIRQ[NUM_CPUS-1:0]),
    .ncnthpirq_o                   (nCNTHPIRQ[NUM_CPUS-1:0]),
    .ncntvirq_o                    (nCNTVIRQ[NUM_CPUS-1:0]),
    .gov_smpen_o                   (gov_smpen[NUM_CPUS-1:0]),
    .cpuqactive_o                  (CPUQACTIVE[NUM_CPUS-1:0]),
    .cpuqdeny_o                    (CPUQDENY[NUM_CPUS-1:0]),
    .cpuqacceptn_o                 (CPUQACCEPTn[NUM_CPUS-1:0]),
    .neonqactive_o                 (NEONQACTIVE[NUM_CPUS-1:0]),
    .neonqdeny_o                   (NEONQDENY[NUM_CPUS-1:0]),
    .neonqacceptn_o                (NEONQACCEPTn[NUM_CPUS-1:0]),
    .l2qactive_o                   (L2QACTIVE),
    .l2qdeny_o                     (L2QDENY),
    .l2qacceptn_o                  (L2QACCEPTn),
    .l2flushdone_o                 (L2FLUSHDONE),
    .nexterrirq_o                  (nEXTERRIRQ),
    .ninterrirq_o                  (nINTERRIRQ),
    .scu_broadcastinner_o          (scu_broadcastinner[NUM_CPUS-1:0]),
    .scu_ext_ar_valid_o            (scu_ext_ar_valid),
    .scu_ext_ar_addr_o             (scu_ext_ar_addr[(`CA53_SCU_EXT_ADDR_W-1):0]),
    .scu_ext_ar_len_o              (scu_ext_ar_len[(`CA53_ACE_ARLEN_W-1):0]),
    .scu_ext_ar_size_o             (scu_ext_ar_size[(`CA53_ACE_ARSIZE_W-1):0]),
    .scu_ext_ar_burst_o            (scu_ext_ar_burst[(`CA53_ACE_ARBURST_W-1):0]),
    .scu_ext_ar_lock_o             (scu_ext_ar_lock),
    .scu_ext_ar_cache_o            (scu_ext_ar_cache[(`CA53_ACE_ARCACHE_W-1):0]),
    .scu_ext_ar_prot_o             (scu_ext_ar_prot[(`CA53_ACE_ARPROT_W-1):0]),
    .scu_ext_ar_domain_o           (scu_ext_ar_domain[(`CA53_ACE_ARDOMAIN_W-1):0]),
    .scu_ext_ar_snoop_o            (scu_ext_ar_snoop[(`CA53_ACE_ARSNOOP_W-1):0]),
    .scu_ext_ar_bar_o              (scu_ext_ar_bar[(`CA53_ACE_ARBAR_W-1):0]),
    .scu_ext_ar_id_o               (scu_ext_ar_id[(`CA53_SCU_EXT_RID_W-1):0]),
    .scu_ext_rdmemattr_o           (scu_ext_rdmemattr[7:0]),
    .scu_ext_dr_ready_o            (scu_ext_dr_ready),
    .scu_ext_aw_valid_o            (scu_ext_aw_valid),
    .scu_ext_aw_addr_o             (scu_ext_aw_addr[(`CA53_SCU_EXT_ADDR_W-1):0]),
    .scu_ext_aw_len_o              (scu_ext_aw_len[(`CA53_ACE_AWLEN_W-1):0]),
    .scu_ext_aw_size_o             (scu_ext_aw_size[(`CA53_ACE_AWSIZE_W-1):0]),
    .scu_ext_aw_burst_o            (scu_ext_aw_burst[(`CA53_ACE_AWBURST_W-1):0]),
    .scu_ext_aw_lock_o             (scu_ext_aw_lock),
    .scu_ext_aw_cache_o            (scu_ext_aw_cache[(`CA53_ACE_AWCACHE_W-1):0]),
    .scu_ext_aw_prot_o             (scu_ext_aw_prot[(`CA53_ACE_AWPROT_W-1):0]),
    .scu_ext_aw_id_o               (scu_ext_aw_id[(`CA53_SCU_EXT_WID_W-1):0]),
    .scu_ext_aw_domain_o           (scu_ext_aw_domain[(`CA53_ACE_AWDOMAIN_W-1):0]),
    .scu_ext_aw_snoop_o            (scu_ext_aw_snoop[(`CA53_ACE_AWSNOOP_W-1):0]),
    .scu_ext_aw_bar_o              (scu_ext_aw_bar[(`CA53_ACE_AWBAR_W-1):0]),
    .scu_ext_aw_unique_o           (scu_ext_aw_unique),
    .scu_ext_wrmemattr_o           (scu_ext_wrmemattr[7:0]),
    .scu_ext_dw_strb_o             (scu_ext_dw_strb[(`CA53_SCU_EXT_STRB_W-1):0]),
    .scu_ext_dw_data_o             (scu_ext_dw_data[(`CA53_SCU_EXT_DATA_W-1):0]),
    .scu_ext_dw_id_o               (scu_ext_dw_id[(`CA53_SCU_EXT_WID_W-1):0]),
    .scu_ext_dw_last_o             (scu_ext_dw_last),
    .scu_ext_dw_valid_o            (scu_ext_dw_valid),
    .scu_ext_db_ready_o            (scu_ext_db_ready),
    .scu_ext_ac_ready_o            (scu_ext_ac_ready),
    .scu_ext_cr_valid_o            (scu_ext_cr_valid),
    .scu_ext_cr_resp_o             (scu_ext_cr_resp[(`CA53_ACE_CRRESP_W-1):0]),
    .scu_ext_cd_valid_o            (scu_ext_cd_valid),
    .scu_ext_cd_data_o             (scu_ext_cd_data[(`CA53_SCU_EXT_DATA_W-1):0]),
    .scu_ext_cd_last_o             (scu_ext_cd_last),
    .scu_ext_rack_o                (scu_ext_rack),
    .scu_ext_wack_o                (scu_ext_wack),
    .scu_txsactive_o               (scu_txsactive),
    .scu_rxlinkactiveack_o         (scu_rxlinkactiveack),
    .scu_txlinkactivereq_o         (scu_txlinkactivereq),
    .scu_txreqflitpend_o           (scu_txreqflitpend),
    .scu_txreqflitv_o              (scu_txreqflitv),
    .scu_txreqflit_o               (scu_txreqflit[99:0]),
    .scu_reqmemattr_o              (scu_reqmemattr[7:0]),
    .scu_txrspflitpend_o           (scu_txrspflitpend),
    .scu_txrspflitv_o              (scu_txrspflitv),
    .scu_txrspflit_o               (scu_txrspflit[44:0]),
    .scu_txdatflitpend_o           (scu_txdatflitpend),
    .scu_txdatflitv_o              (scu_txdatflitv),
    .scu_txdatflit_o               (scu_txdatflit[193:0]),
    .scu_rxsnplcrdv_o              (scu_rxsnplcrdv),
    .scu_rxrsplcrdv_o              (scu_rxrsplcrdv),
    .scu_rxdatlcrdv_o              (scu_rxdatlcrdv),
    .gov_pseldbg_dbg_o             (gov_pseldbg_dbg[NUM_CPUS-1:0]),
    .gov_pseldbg_pmu_o             (gov_pseldbg_pmu[NUM_CPUS-1:0]),
    .gov_pseldbg_etm_o             (gov_pseldbg_etm[NUM_CPUS-1:0]),
    .gov_paddrdbg_o                (gov_paddrdbg[(`CA53_PADDRDBG_PKDED_W-1):0]),
    .gov_paddrdbg31_o              (gov_paddrdbg31[NUM_CPUS-1:0]),
    .gov_penabledbg_o              (gov_penabledbg[NUM_CPUS-1:0]),
    .gov_pwritedbg_o               (gov_pwritedbg[NUM_CPUS-1:0]),
    .gov_pwdatadbg_o               (gov_pwdatadbg[(`CA53_PWDATADBG_PKDED_W-1):0]),
    .scu_acp_awready_o             (scu_acp_awready),
    .scu_acp_wready_o              (scu_acp_wready),
    .scu_acp_bvalid_o              (scu_acp_bvalid),
    .scu_acp_bid_o                 (scu_acp_bid[  4:0]),
    .scu_acp_bresp_o               (scu_acp_bresp[  1:0]),
    .scu_acp_arready_o             (scu_acp_arready),
    .scu_acp_rvalid_o              (scu_acp_rvalid),
    .scu_acp_rid_o                 (scu_acp_rid[  4:0]),
    .scu_acp_rdata_o               (scu_acp_rdata[127:0]),
    .scu_acp_rresp_o               (scu_acp_rresp[  1:0]),
    .scu_acp_rlast_o               (scu_acp_rlast),
    .prdatadbg_o                   (PRDATADBG[ 31:0]),
    .preadydbg_o                   (PREADYDBG),
    .pslverrdbg_o                  (PSLVERRDBG),
    .ncommirq_o                    (nCOMMIRQ[NUM_CPUS-1:0]),
    .dbgack_o                      (DBGACK[NUM_CPUS-1:0]),
    .commrx_o                      (COMMRX[NUM_CPUS-1:0]),
    .commtx_o                      (COMMTX[NUM_CPUS-1:0]),
    .dbgrstreq_o                   (DBGRSTREQ[NUM_CPUS-1:0]),
    .dbgnopwrdwn_o                 (DBGNOPWRDWN[NUM_CPUS-1:0]),
    .gov_dbgpwrupreq_o             (gov_dbgpwrupreq[NUM_CPUS-1:0]),
    .dbgpwrupreq_o                 (DBGPWRUPREQ[NUM_CPUS-1:0]),
    .gov_dbgl1rstdisable_o         (gov_dbgl1rstdisable[NUM_CPUS-1:0]),
    .gov_extin_o                   (gov_extin[(`CA53_ETMEXT_PKDED_W-1):0]),
    .gov_edecr_osuce_o             (gov_edecr_osuce[NUM_CPUS-1:0]),
    .gov_edecr_rce_o               (gov_edecr_rce[NUM_CPUS-1:0]),
    .gov_edecr_ss_o                (gov_edecr_ss[NUM_CPUS-1:0]),
    .gov_edlsr_slk_o               (gov_edlsr_slk[NUM_CPUS-1:0]),
    .gov_pmlsr_slk_o               (gov_pmlsr_slk[NUM_CPUS-1:0]),
    .gov_etmpdsr_rd_o              (gov_etmpdsr_rd[NUM_CPUS-1:0]),
    .gov_dbgromaddr_o              (gov_dbgromaddr[ 39:12]),
    .gov_dbgromaddrv_o             (gov_dbgromaddrv),
    .gov_edbgrq_o                  (gov_edbgrq[NUM_CPUS-1:0]),
    .gov_dbgen_o                   (gov_dbgen[NUM_CPUS-1:0]),
    .gov_spiden_o                  (gov_spiden[NUM_CPUS-1:0]),
    .gov_niden_o                   (gov_niden[NUM_CPUS-1:0]),
    .gov_spniden_o                 (gov_spniden[NUM_CPUS-1:0]),
    .gov_dbgrestart_o              (gov_dbgrestart[NUM_CPUS-1:0]),
    .gov_stall_dsb_o               (gov_stall_dsb[NUM_CPUS-1:0]),
    .gov_cp_ack_o                  (gov_cp_ack[NUM_CPUS-1:0]),
    .gov_cp_rdata_o                (gov_cp_rdata[(`CA53_CPDATA_PKDED_W-1):0]),
    .gov_pcnt_kernel_access_o      (gov_pcnt_kernel_access[NUM_CPUS-1:0]),
    .gov_pcnt_usr_access_o         (gov_pcnt_usr_access[NUM_CPUS-1:0]),
    .gov_vcnt_usr_access_o         (gov_vcnt_usr_access[NUM_CPUS-1:0]),
    .gov_cntp_usr_access_o         (gov_cntp_usr_access[NUM_CPUS-1:0]),
    .gov_cntv_usr_access_o         (gov_cntv_usr_access[NUM_CPUS-1:0]),
    .gov_cntp_kernel_access_o      (gov_cntp_kernel_access[NUM_CPUS-1:0]),
    .gov_tsvalueb_o                (gov_tsvalueb[63:0]),
    .gov_atclken_o                 (gov_atclken[NUM_CPUS-1: 0]),
    .gov_atreadym_o                (gov_atreadym[(`CA53_ATREADYM_PKDED_W-1):0]),
    .gov_afvalidm_o                (gov_afvalidm[(`CA53_AFVALIDM_PKDED_W-1):0]),
    .atdatam_o                     (atdatam[(`CA53_ATDATAM_PKDED_W-1):0]),
    .atvalidm_o                    (atvalidm[(`CA53_ATVALIDM_PKDED_W-1):0]),
    .atbytesm_o                    (atbytesm[(`CA53_ATBYTESM_PKDED_W-1):0]),
    .afreadym_o                    (afreadym[(`CA53_AFREADYM_PKDED_W-1):0]),
    .atidm_o                       (atidm[(`CA53_ATIDM_PKDED_W-1):0]),
    .gov_syncreqm_o                (gov_syncreqm[(`CA53_SYNCREQM_PKDED_W-1):0]),
    .npmuirq_o                     (nPMUIRQ[NUM_CPUS-1:0]),
    .pmuevent_o                    (pmuevent[(`CA53_PMUEVNT_PKDED_W-1):0]),
    .scu_ar_credit_o               (scu_ar_credit[(`CA53_ARCREDIT_PKDED_W-1):0]),
    .scu_ar_block_o                (scu_ar_block[(`CA53_ARBLOCK_PKDED_W-1):0]),
    .scu_dr_valid_o                (scu_dr_valid[(`CA53_DRVALID_PKDED_W-1):0]),
    .scu_dr_id_o                   (scu_dr_id[(`CA53_DRID_PKDED_W-1):0]),
    .scu_dr_resp_o                 (scu_dr_resp[(`CA53_DRRESP_PKDED_W-1):0]),
    .scu_dr_chunk_o                (scu_dr_chunk[(`CA53_DRCHUNK_PKDED_W-1):0]),
    .scu_dr_data_o                 (scu_dr_data[(`CA53_DRDATA_PKDED_W-1):0]),
    .scu_rr_valid_o                (scu_rr_valid[(`CA53_RRVALID_PKDED_W-1):0]),
    .scu_rr_id_o                   (scu_rr_id[(`CA53_RRID_PKDED_W-1):0]),
    .scu_rr_resp_o                 (scu_rr_resp[(`CA53_RRRESP_PKDED_W-1):0]),
    .scu_rr_l2db_id_o              (scu_rr_l2db_id[(`CA53_RRL2DB_PKDED_W-1):0]),
    .scu_ev_done_o                 (scu_ev_done[(`CA53_EVDONE_PKDED_W-1):0]),
    .scu_db_excl_valid_o           (scu_db_excl_valid[(`CA53_DBEXCLVAL_PKDED_W-1):0]),
    .scu_db_excl_resp_o            (scu_db_excl_resp[(`CA53_DBEXCLRSP_PKDED_W-1):0]),
    .scu_db_decerr_o               (scu_db_decerr[(`CA53_DBDECERR_PKDED_W-1):0]),
    .scu_db_slverr_o               (scu_db_slverr[(`CA53_DBSLVERR_PKDED_W-1):0]),
    .scu_leave_ramode_o            (scu_leave_ramode[(`CA53_LEAVERAM_PKDED_W-1):0]),
    .scu_ac_valid_o                (scu_ac_valid[(`CA53_ACVALID_PKDED_W-1):0]),
    .scu_ac_id_o                   (scu_ac_id[(`CA53_ACID_PKDED_W-1):0]),
    .scu_ac_l2db_id_o              (scu_ac_l2db_id[(`CA53_ACL2DB_PKDED_W-1):0]),
    .scu_ac_snoop_o                (scu_ac_snoop[(`CA53_ACSNOOP_PKDED_W-1):0]),
    .scu_ac_addr_o                 (scu_ac_addr[(`CA53_ACADDR_PKDED_W-1):0]),
    .scu_ac_way_o                  (scu_ac_way[(`CA53_ACWAY_PKDED_W-1):0]),
    .scu_dvm_complete_o            (scu_dvm_complete[(`CA53_DVM_COMP_PKDED_W-1):0]),
    .scu_reqbufs_busy_o            (scu_reqbufs_busy[(`CA53_REQBUFS_BUSY_PKDED_W-1):0]),
    .scu_drain_stb_o               (scu_drain_stb[(`CA53_DRAIN_STB_PKDED_W-1):0]),
    .scu_evnt_l2_access_o          (scu_evnt_l2_access[NUM_CPUS-1:0]),
    .scu_evnt_l2_refill_o          (scu_evnt_l2_refill[NUM_CPUS-1:0]),
    .scu_evnt_l2_wb_o              (scu_evnt_l2_wb[NUM_CPUS-1:0]),
    .scu_evnt_snooped_data_o       (scu_evnt_snooped_data[NUM_CPUS-1:0]),
    .scu_evnt_bus_cycle_o          (scu_evnt_bus_cycle[NUM_CPUS-1:0]),
    .scu_evnt_bus_acc_rd_o         (scu_evnt_bus_acc_rd[NUM_CPUS-1:0]),
    .scu_evnt_bus_acc_wr_o         (scu_evnt_bus_acc_wr[NUM_CPUS-1:0]),
    .scu_evnt_eviction_o           (scu_evnt_eviction[NUM_CPUS-1:0]),
    .l2_size_o                     (l2_size[`CA53_L2_SIZE_W-1:0]),
    .ctichout_o                    (CTICHOUT[3:0]),
    .ctichinack_o                  (CTICHINACK[3:0]),
    .ctiirq_o                      (CTIIRQ[NUM_CPUS-1: 0]),
    .mbistack0_o                   (mbistack0),
    .mbistack1_o                   (mbistack1),
    .mbistoutdata0_o               (mbistoutdata0[(`CA53_MBIST0_DATA_W-1): 0]),
    .mbistoutdata1_o               (mbistoutdata1[(`CA53_MBIST1_DATA_W-1): 0])
  );  // u_ca53_l2

  // ------------------------------------------------------
  // Top level output assignments
  // ------------------------------------------------------

  // ACP

  // ACE
  assign RDMEMATTR        = scu_ext_rdmemattr;
  assign WRMEMATTR        = scu_ext_wrmemattr;
  assign CDDATAM          = scu_ext_cd_data;
  assign CDLASTM          = scu_ext_cd_last;
  assign ARVALIDM         = scu_ext_ar_valid;
  assign ARADDRM          = scu_ext_ar_addr;
  assign ARLENM           = scu_ext_ar_len;
  assign ARSIZEM          = scu_ext_ar_size;
  assign ARBURSTM         = scu_ext_ar_burst;
  assign ARLOCKM          = scu_ext_ar_lock;
  assign ARCACHEM         = scu_ext_ar_cache;
  assign ARPROTM          = scu_ext_ar_prot;
  assign ARSNOOPM         = scu_ext_ar_snoop;
  assign ARDOMAINM        = scu_ext_ar_domain;
  assign ARBARM           = scu_ext_ar_bar;
  assign ARIDM            = scu_ext_ar_id;
  assign RREADYM          = scu_ext_dr_ready;
  assign AWVALIDM         = scu_ext_aw_valid;
  assign AWADDRM          = scu_ext_aw_addr;
  assign AWLENM           = scu_ext_aw_len;
  assign AWSIZEM          = scu_ext_aw_size;
  assign AWBURSTM         = scu_ext_aw_burst;
  assign AWLOCKM          = scu_ext_aw_lock;
  assign AWCACHEM         = scu_ext_aw_cache;
  assign AWPROTM          = scu_ext_aw_prot;
  assign AWSNOOPM         = scu_ext_aw_snoop;
  assign AWUNIQUEM        = scu_ext_aw_unique;
  assign AWDOMAINM        = scu_ext_aw_domain;
  assign AWBARM           = scu_ext_aw_bar;
  assign AWIDM            = scu_ext_aw_id;
  assign WSTRBM           = scu_ext_dw_strb;
  assign WDATAM           = scu_ext_dw_data;
  assign WIDM             = scu_ext_dw_id;
  assign WLASTM           = scu_ext_dw_last;
  assign WVALIDM          = scu_ext_dw_valid;
  assign BREADYM          = scu_ext_db_ready;
  assign ACREADYM         = scu_ext_ac_ready;
  assign CRVALIDM         = scu_ext_cr_valid;
  assign CRRESPM          = scu_ext_cr_resp;
  assign CDVALIDM         = scu_ext_cd_valid;
  assign RACKM            = scu_ext_rack;
  assign WACKM            = scu_ext_wack;

  // Skyros

  // SMP Enable
  assign SMPEN            = gov_smpen;

  // ATB & PMUEVENT
  assign ATDATAM0  = atdatam[((`CA53_ATDATAM_W   *1)-1):(`CA53_ATDATAM_W  *0)];
  assign ATDATAM1  = atdatam[((`CA53_ATDATAM_W   *2)-1):(`CA53_ATDATAM_W  *1)];
  assign ATDATAM2  = atdatam[((`CA53_ATDATAM_W   *3)-1):(`CA53_ATDATAM_W  *2)];
  assign ATDATAM3  = atdatam[((`CA53_ATDATAM_W   *4)-1):(`CA53_ATDATAM_W  *3)];
  assign ATVALIDM0 = atvalidm[0];
  assign ATVALIDM1 = atvalidm[1];
  assign ATVALIDM2 = atvalidm[2];
  assign ATVALIDM3 = atvalidm[3];
  assign ATBYTESM0 = atbytesm[((`CA53_ATBYTESM_W *1)-1):(`CA53_ATBYTESM_W *0)];
  assign ATBYTESM1 = atbytesm[((`CA53_ATBYTESM_W *2)-1):(`CA53_ATBYTESM_W *1)];
  assign ATBYTESM2 = atbytesm[((`CA53_ATBYTESM_W *3)-1):(`CA53_ATBYTESM_W *2)];
  assign ATBYTESM3 = atbytesm[((`CA53_ATBYTESM_W *4)-1):(`CA53_ATBYTESM_W *3)];
  assign AFREADYM0 = afreadym[((`CA53_AFREADYM_W *1)-1):(`CA53_AFREADYM_W *0)];
  assign AFREADYM1 = afreadym[((`CA53_AFREADYM_W *2)-1):(`CA53_AFREADYM_W *1)];
  assign AFREADYM2 = afreadym[((`CA53_AFREADYM_W *3)-1):(`CA53_AFREADYM_W *2)];
  assign AFREADYM3 = afreadym[((`CA53_AFREADYM_W *4)-1):(`CA53_AFREADYM_W *3)];
  assign ATIDM0    = atidm[((`CA53_ATIDM_W       *1)-1):(`CA53_ATIDM_W    *0)];
  assign ATIDM1    = atidm[((`CA53_ATIDM_W       *2)-1):(`CA53_ATIDM_W    *1)];
  assign ATIDM2    = atidm[((`CA53_ATIDM_W       *3)-1):(`CA53_ATIDM_W    *2)];
  assign ATIDM3    = atidm[((`CA53_ATIDM_W       *4)-1):(`CA53_ATIDM_W    *3)];
  assign PMUEVENT0 = pmuevent[((`CA53_PMUEVNT_W  *1)-1):(`CA53_PMUEVNT_W  *0)];
  assign PMUEVENT1 = pmuevent[((`CA53_PMUEVNT_W  *2)-1):(`CA53_PMUEVNT_W  *1)];
  assign PMUEVENT2 = pmuevent[((`CA53_PMUEVNT_W  *3)-1):(`CA53_PMUEVNT_W  *2)];
  assign PMUEVENT3 = pmuevent[((`CA53_PMUEVNT_W  *4)-1):(`CA53_PMUEVNT_W  *3)];

  // ------------------------------------------------------
  // MBIST Controller Instantiations
  // ------------------------------------------------------
  //
  // MBIST controllers are to be added by the partner at implementation time
  // in the following section and using the defined MBIST interfaces.

  // Tie-offs that must be replaced by the MBIST controllers
  assign mbistaddr0    = {`CA53_MBIST0_ADDR_W{1'b0}};
  assign mbistaddr1    = {`CA53_MBIST1_ADDR_W{1'b0}};
  assign mbistindata0  = {`CA53_MBIST0_DATA_W{1'b0}};
  assign mbistindata1  = {`CA53_MBIST1_DATA_W{1'b0}};
  assign mbistwriteen0 = 1'b0;
  assign mbistwriteen1 = 1'b0;
  assign mbistreaden0  = 1'b0;
  assign mbistreaden1  = 1'b0;
  assign mbistarray0   = {`CA53_MBIST0_RAMARRAY_W{1'b0}};
  assign mbistarray1   = {`CA53_MBIST1_RAMARRAY_W{1'b0}};
  assign mbistbe0      = {`CA53_MBIST0_BE_W{1'b0}};
  assign mbistbe1      = {`CA53_MBIST1_BE_W{1'b0}};
  assign mbistcfg0     = 1'b0;
  assign mbistcfg1     = 1'b0;

endmodule // CORTEXA53_unconfigured

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53scu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
