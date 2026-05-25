//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2015-02-13 22:49:38 +0000 (Fri, 13 Feb 2015) $
//
//      Revision            : $Revision: 301903 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : DPU specific CP15 registers
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_cp `CA53_DPU_PARAM_DECL (
  // Inputs
  input  wire                             clk,
  input  wire                             reset_n,
  input  wire                             po_reset_n,
  input  wire                             DFTSE,
  input  wire                             aarch64_state_i,
  input  wire                      [1:0]  dpu_exception_level_i,
  input  wire                             stall_iss_i,
  input  wire                             stall_wr_i,
  input  wire                             flush_wr_i,
  input  wire                             flush_ret_i,
  input  wire                             expt_quash_wr_i,
  input  wire                             cc_pass_instr0_wr_i,
  input  wire                             cp_valid_de_i,
  input  wire                      [8:0]  cp_decode_de_i,
  input  wire                             fp_serialise_de_i,
  input  wire                     [63:0]  dcu_ld_data_dc3_i,
  input  wire                     [63:0]  dbg_cp_rd_data_i,
  input  wire                     [63:0]  pmu_cp_rd_data_i,
  input  wire                     [31:0]  psr_cp_rd_data_i,
  input  wire                     [63:0]  st0_data_wr_i,
  input  wire                             expt_mon_mode_clear_ns_i,
  input  wire [`CA53_FAULT_REG_EN_W-1:0]  expt_fault_reg_en_wr_i,
  input  wire                             expt_fault_reg_sel_wr_i,
  input  wire                             expt_aa32_uses_el1_esr_wr_i,
  input  wire                     [12:0]  expt_ifsr_wr_i,
  input  wire                     [12:0]  expt_dfsr_wr_i,
  input  wire                     [63:0]  expt_far_data_wr_i,
  input  wire                     [27:0]  expt_hpfar_data_wr_i,
  input  wire                     [31:0]  expt_esr_data_wr_i,
  input  wire                     [39:2]  gov_rvbaraddr_i,
  input  wire                             gov_aa64naa32_i,
  input  wire                             gov_cryptodisable_i,
  input  wire                             gov_giccdisable_i,
  input  wire                             gov_cfgend_i,
  input  wire                             gov_cfgte_i,
  input  wire                             gov_vinithi_i,
  input  wire                      [3:0]  l2_size_i,
  input  wire                      [2:0]  ic_size_i,
  input  wire                      [2:0]  dc_size_i,
  input  wire                      [7:0]  gov_clusteridaff2_i,
  input  wire                      [7:0]  gov_clusteridaff1_i,
  input  wire                      [1:0]  cpu_id_i,
  input  wire                      [3:0]  ctr_cwg_i,
  input  wire                      [3:0]  ctr_erg_i,
  input  wire                             in_halt_i,
  input  wire                             clear_virtual_ea_i,
  input  wire                             expt_serr_pending_i,
  input  wire                             expt_irq_pending_i,
  input  wire                             expt_fiq_pending_i,
  input  wire                             ns_state_i,
  input  wire                     [39:18] gov_periphbase_i,
  input  wire [`CA53_FP_CFLAG_SRC_W-1:0]  fp0_cflag_src_f5_i,
  input  wire [`CA53_FP_CFLAG_SRC_W-1:0]  fp1_cflag_src_f5_i,
  input  wire [`CA53_FP_XFLAG_SRC_W-1:0]  fp0_xflag_src_f5_i,
  input  wire [`CA53_FP_XFLAG_SRC_W-1:0]  fp1_xflag_src_f5_i,
  input  wire                      [3:0]  fp_cflags_add0_f5_i,
  input  wire                      [3:0]  fp_cflags_add1_f5_i,
  input  wire       [`CA53_XFLAGS_W-1:0]  fp_xflags_add0_f5_i,
  input  wire       [`CA53_XFLAGS_W-1:0]  fp_xflags_add1_f5_i,
  input  wire       [`CA53_XFLAGS_W-1:0]  fp_xflags_mul0_f5_i,
  input  wire       [`CA53_XFLAGS_W-1:0]  fp_xflags_mul1_f5_i,
  input  wire                             spec_cpsr_mode_mon_iss_i,
  input  wire                             dpu_fe_valid_ret_i,
  input  wire                             dcu_ecc_fatal_i,
  input  wire                             dcu_ecc_valid_i,
  input  wire                      [1:0]  dcu_ecc_ramid_i,
  input  wire                      [2:0]  dcu_ecc_way_bank_id_i,
  input  wire                     [10:0]  dcu_ecc_index_i,
  input  wire                             tlb_pty_valid_i,
  input  wire                      [1:0]  tlb_pty_way_bank_id_i,
  input  wire                      [7:0]  tlb_pty_index_i,
  input  wire                             ifu_pty_valid_i,
  input  wire                             ifu_pty_ramid_i,
  input  wire                             ifu_pty_way_bank_id_i,
  input  wire                     [11:0]  ifu_pty_index_i,
  // Outputs
  output wire                     [63:0]  mcr_data_wr_o,
  output wire                     [63:0]  mrc_data_wr_o,
  output wire                             cp_valid_ex2_o,
  output wire                             nxt_cp_valid_wr_o,
  output wire                             cp_valid_wr_o,
  output wire                             raw_cp_valid_wr_o,
  output wire                      [8:0]  raw_cp_decode_wr_o,
  output wire                     [15:0]  cp15_pmu_access_wr_o,
  output wire                             dpu_icache_on_o,
  output wire                             dpu_l1deien_o,
  output wire                             dpu_disable_dmb_o,
  output wire                             dpu_disable_device_split_throttle_o,
  output wire                      [2:0]  dpu_enable_data_prefetch_o,
  output wire                      [1:0]  dpu_enable_data_prefetch_streams_o,
  output wire                             dpu_data_prefetch_stride_detect_o,
  output wire                             dpu_disable_data_prefetch_stores_pattern_o,
  output wire                             dpu_disable_data_prefetch_readunique_o,
  output wire                             dpu_disable_no_allocate_o,
  output wire                      [1:0]  dpu_ramode_cnt_l1_o,
  output wire                      [1:0]  dpu_ramode_cnt_l2_o,
  output wire                     [21:0]  dpu_periphbase_o,
  output wire                             dpu_smp_en_o,
  output wire                             disable_dual_issue_o,
  output wire                             disable_fp_dual_issue_o,
  output wire                             force_clean_to_invalidate_o,
  output wire                             fp_serialize_iss_o,
  output wire                             mrc_instr_ex1_o,
  output wire                             mrc_instr_ex2_o,
  output wire                             mrc_instr_wr_o,
  output wire                             cptr_el3_tcpac_o,
  output wire                             cptr_el3_tfp_o,
  output wire                             hcr_trvm_o,
  output wire                             hcr_tdz_o,
  output wire                             hcr_fb_o,
  output wire                      [1:0]  hcr_bsu_o,
  output wire                             hcr_twi_o,
  output wire                             hcr_twe_o,
  output wire                             hcr_tid0_o,
  output wire                             hcr_tid1_o,
  output wire                             hcr_tid2_o,
  output wire                             hcr_tid3_o,
  output wire                             hcr_tsc_o,
  output wire                             hcr_tidcp_o,
  output wire                             hcr_tacr_o,
  output wire                             hcr_tsw_o,
  output wire                             hcr_tpc_o,
  output wire                             hcr_tpu_o,
  output wire                             hcr_ttlb_o,
  output wire                             hcr_tvm_o,
  output wire                             hcr_tge_o,
  output wire                             hcr_va_o,
  output wire                             hcr_vi_o,
  output wire                             hcr_vf_o,
  output wire                             hcr_amo_o,
  output wire                             hcr_imo_o,
  output wire                             hcr_fmo_o,
  output wire                             hdcr_tdra_o,
  output wire                             hdcr_tdosa_o,
  output wire                             hdcr_tda_o,
  output wire                             hdcr_tde_o,
  output wire                             hdcr_tpm_o,
  output wire                             hdcr_tpmcr_o,
  output wire                             hdcr_hpme_o,
  output wire                      [4:0]  hdcr_hpmn_o,
  output wire                             mdcr_el3_tdosa_o,
  output wire                             mdcr_el3_tda_o,
  output wire                             mdcr_el3_tpm_o,
  output wire                     [13:0]  hstr_trap_cp15_o,
  output wire                             sctlr_endian_el3_o,
  output wire                             sctlr_endian_el1_o,
  output wire                             sctlr_endian_el2_o,
  output wire                             sctlr_el1_e0e_o,
  output wire                             sctlr_el3_itd_o,
  output wire                             sctlr_el2_itd_o,
  output wire                             sctlr_el1_itd_o,
  output wire                             sctlr_ns_hivecs_o,
  output wire                             sctlr_s_hivecs_o,
  output wire                             sctlr_align_check_o,
  output wire                      [3:0]  sctlr_sa_at_el_o,
  output reg                              sctlr_ntwe_o,
  output reg                              sctlr_ntwi_o,
  output reg                              sctlr_cp15ben_o,
  output reg                              sctlr_sed_o,
  output wire                             sctlr_el1_uct_o,
  output wire                             sctlr_el1_uci_o,
  output wire                             sctlr_el1_uma_o,
  output wire                             sctlr_el1_dze_o,
  output reg                              dpu_hivecs_o,
  output wire                             dpu_dcache_on_o,
  output wire                             dpu_s2_dcache_on_o,
  output wire                             dpu_default_cacheable_o,
  output wire                             dpu_ipa_to_pa_en_o,
  output wire                             dpu_pr_tablewalk_o,
  output wire                             dpu_mmu_on_o,
  output wire                             dpu_mmu_on_el1_o,
  output wire                             dpu_mmu_on_el2_o,
  output wire                             dpu_mmu_on_el3_o,
  output wire                             dpu_dcache_on_el1_o,
  output wire                             dpu_dcache_on_el2_o,
  output wire                             dpu_dcache_on_el3_o,
  output wire                      [3:1]  aarch64_at_el_o,
  output wire                     [39:2]  rvbaraddr_o,
  output wire                             hsctlr_te_o,
  output wire                             dpu_warmrstreq_o,
  output wire                             sctlr_ns_te_o,
  output wire                             sctlr_s_te_o,
  output wire                             dpu_sctlr_wxn_el1_o,
  output wire                             dpu_sctlr_wxn_el2_o,
  output wire                             dpu_sctlr_wxn_el3_o,
  output wire                             dpu_sctlr_uwxn_el1_o,
  output wire                             dpu_sctlr_uwxn_el3_o,
  output wire                             dpu_sctlr_itd_o,
  output wire                             dpu_throttle_enable_o,
  output wire                     [63:5]  cp_vbar_el3_o,
  output wire                     [63:5]  cp_vbar_el1_o,
  output wire                     [31:5]  cp_mvbar_o,
  output wire                     [63:5]  cp_hvbar_o,
  output wire                             dpu_sif_only_o,
  output wire                             scr_twi_o,
  output wire                             scr_twe_o,
  output wire                             scr_st_o,
  output wire                             scr_hce_o,
  output wire                             scr_smd_o,
  output wire                             scr_aw_o,
  output wire                             scr_fw_o,
  output wire                             scr_ea_o,
  output wire                             scr_fiq_o,
  output wire                             scr_irq_o,
  output wire                             ns_scr_o,
  output wire                             nxt_ns_scr_o,
  output wire                             wr_scr_o,
  output wire                             ns_state_de_o,
  output wire                             dpu_tex_remap_enable_el3_o,
  output wire                             dpu_tex_remap_enable_el1_o,
  output wire                             dpu_access_flag_enable_el3_o,
  output wire                             dpu_access_flag_enable_el1_o,
  output wire                     [31:0]  dpu_dacr_o,
  output wire                     [31:0]  dpu_dacr_ns_o,
  output wire                             dpu_dacr_mmu_on_o,
  output wire                             flush_d_utlb_o,
  output wire                             flush_i_utlb_o,
  output wire                             tlb_abandon_o,
  output wire                      [1:0]  cp_sder_o,
  output wire                             cp_icimvau_o,
  output wire                      [2:0]  dpu_cpuectlr_cpu_ret_delay_o,
  output wire                      [2:0]  dpu_cpuectlr_neon_ret_delay_o,
  output wire                             cp_fpexc_en_o,
  output wire                      [3:0]  cp_fpsr_cflags_o,
  output wire                             cp_fpcr_ahp_o,
  output wire                             cp_fpcr_dn_o,
  output wire                             cp_fpcr_fz_o,
  output wire                      [1:0]  cp_fpcr_rmode_o,
  output wire                             cp_mdcr_el3_sdd_o,
  output wire                      [1:0]  cp_mdcr_el3_spd32_o,
  output wire                             cp_mdcr_el3_spme_o,
  output wire                             cp_mdcr_el3_epmad_o,
  output wire                             cp_mdcr_el3_edad_o,
  output wire                             cpuactlr_el3_o,
  output wire                             cpuectlr_el3_o,
  output wire                             l2ctlr_el3_o,
  output wire                             l2ectlr_el3_o,
  output wire                             l2actlr_el3_o,
  output wire                             cpuactlr_el2_o,
  output wire                             cpuectlr_el2_o,
  output wire                             l2ctlr_el2_o,
  output wire                             l2ectlr_el2_o,
  output wire                             l2actlr_el2_o,
  output wire                       [1:0] expt_cpacr_el1_fpen_o,
  output wire                             expt_cpacr_asedis_o,
  output wire                             expt_cptr_el2_tfp_o,
  output wire                             expt_hcptr_tase_o,
  output wire                             expt_cptr_el2_tcpac_o,
  output reg                              cp_trap_fp_o,
  output reg                              cp_trap_neon_o,
  output wire                             cryptodisable_o,
  output wire                             giccdisable_o,
  output wire                             evnt_mem_err_ifu_o,
  output wire                             evnt_mem_err_dcu_o,
  output wire                             evnt_mem_err_tlb_o
);

  // -------------------------------
  // Local parameter declarations
  // -------------------------------

  localparam PMN_NUMBER  = `CA53_NUM_PMN;
  localparam WIDTHL2     = L2_CACHE ? 2 : 1;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg                 dpu_l1deien;
  reg                 dpu_disable_dmb;
  reg                 dpu_disable_device_split_throttle;
  reg                 dpu_throttle_disable;
  reg          [2:0]  dpu_enable_data_prefetch;
  reg          [1:0]  dpu_enable_data_prefetch_streams;
  reg                 dpu_data_prefetch_stride_detect;
  reg                 dpu_disable_data_prefetch_stores_pattern;
  reg                 dpu_disable_data_prefetch_readunique;
  reg                 dpu_disable_no_allocate;
  reg          [1:0]  dpu_ramode_cnt_l1;
  reg          [1:0]  dpu_ramode_cnt_l2;
  reg                 dpu_smp_en;
  reg          [2:0]  cpu_ret;
  reg                 l2actlr_el3;
  reg                 l2ectlr_el3;
  reg                 l2ctlr_el3;
  reg                 cpuectlr_el3;
  reg                 cpuactlr_el3;
  reg                 l2actlr_el2;
  reg                 l2ectlr_el2;
  reg                 l2ctlr_el2;
  reg                 cpuectlr_el2;
  reg                 cpuactlr_el2;
  reg                 force_clean_to_invalidate;
  reg                 disable_dual_issue;
  reg                 disable_fp_dual_issue;
  reg         [11:0]  ca53_ecoid_data;
  reg  [WIDTHL2-1:0]  cp_cssr;
  reg  [WIDTHL2-1:0]  cp_cssr_ns;
  reg         [31:0]  cp_vpidr;
  reg                 cp_vmpidr_u;
  reg                 cp_vmpidr_mt;
  reg          [7:0]  cp_vmpidr_aff3;
  reg          [7:0]  cp_vmpidr_aff2;
  reg          [7:0]  cp_vmpidr_aff1;
  reg          [7:0]  cp_vmpidr_aff0;
  reg                 cp_scr_twe;
  reg                 cp_scr_twi;
  reg                 cp_scr_st;
  reg                 cp_scr_rw;
  reg                 cp_scr_sif;
  reg                 cp_scr_hce;
  reg                 cp_scr_smd;
  reg                 cp_scr_aw;
  reg                 cp_scr_fw;
  reg                 cp_scr_ea;
  reg                 cp_scr_fiq;
  reg                 cp_scr_irq;
  reg                 cp_scr_ns;
  reg                 cp_sctlr_el2_te;
  reg                 cp_sctlr_el2_ee;
  reg                 cp_sctlr_el2_wxn;
  reg                 cp_sctlr_el2_i;
  reg                 cp_sctlr_el2_sed;
  reg                 cp_sctlr_el2_itd;
  reg                 cp_sctlr_el2_cp15ben;
  reg                 cp_sctlr_el2_sa;
  reg                 cp_sctlr_el2_c;
  reg                 cp_sctlr_el2_a;
  reg                 cp_sctlr_el2_m;
  reg         [13:0]  cp_hstr;
  reg         [31:0]  cp_esr_el2;
  reg         [31:0]  cp_esr_el3;
  reg         [31:4]  cp_hpfar;
  reg         [63:5]  cp_hvbar;
  reg         [63:0]  cp_htpidr;
  reg         [63:0]  cp_tpidr_el3;
  reg         [1:0]   cp_sder;
  reg         [63:5]  cp_vbar;
  reg         [63:5]  cp_vbar_ns;
  reg         [31:5]  cp_mvbar;
  reg         [31:0]  cp_tpidrurw;
  reg         [63:0]  cp_tpidrurw_ns;
  reg         [31:0]  cp_tpidruro;
  reg         [63:0]  cp_tpidruro_ns;
  reg         [31:0]  cp_tpidrprw;
  reg         [63:0]  cp_tpidrprw_ns;
  reg                 cp_rmr_el3_aa64;
  reg                 cp_rmr_el3_rr;
  reg                 cp_sctlr_el3_te;
  reg                 cp_sctlr_el3_afe;
  reg                 cp_sctlr_el3_tre;
  reg                 cp_sctlr_el3_ee;
  reg                 cp_sctlr_el3_uwxn;
  reg                 cp_sctlr_el3_wxn;
  reg                 cp_sctlr_el3_ntwe;
  reg                 cp_sctlr_el3_ntwi;
  reg                 cp_sctlr_el3_v;
  reg                 cp_sctlr_el3_i;
  reg                 cp_sctlr_el3_sed;
  reg                 cp_sctlr_el3_itd;
  reg                 cp_sctlr_el3_cp15ben;
  reg                 cp_sctlr_el3_sa;
  reg                 cp_sctlr_el3_c;
  reg                 cp_sctlr_el3_a;
  reg                 cp_sctlr_el3_m;
  reg                 cp_sctlr_el1_te;
  reg                 cp_sctlr_el1_afe;
  reg                 cp_sctlr_el1_tre;
  reg                 cp_sctlr_el1_ee;
  reg                 cp_sctlr_el1_uwxn;
  reg                 cp_sctlr_el1_wxn;
  reg                 cp_sctlr_el1_v;
  reg                 cp_sctlr_el1_i;
  reg                 cp_sctlr_el1_c;
  reg                 cp_sctlr_el1_a;
  reg                 cp_sctlr_el1_m;
  reg                 cp_sctlr_el1_uci;
  reg                 cp_sctlr_el1_e0e;
  reg                 cp_sctlr_el1_ntwe;
  reg                 cp_sctlr_el1_ntwi;
  reg                 cp_sctlr_el1_uct;
  reg                 cp_sctlr_el1_dze;
  reg                 cp_sctlr_el1_uma;
  reg                 cp_sctlr_el1_sed;
  reg                 cp_sctlr_el1_itd;
  reg                 cp_sctlr_el1_cp15ben;
  reg                 cp_sctlr_el1_sa0;
  reg                 cp_sctlr_el1_sa;
  reg                 cp_hdcr_tdra;
  reg                 cp_hdcr_tdosa;
  reg                 cp_hdcr_tda;
  reg                 cp_hdcr_tde;
  reg                 cp_hdcr_hpme;
  reg                 cp_hdcr_tpm;
  reg                 cp_hdcr_tpmcr;
  reg          [4:0]  cp_hdcr_hpmn;
  reg                 cp_mdcr_el3_epmad;
  reg                 cp_mdcr_el3_edad;
  reg                 cp_mdcr_el3_spme;
  reg                 cp_mdcr_el3_sdd;
  reg          [1:0]  cp_mdcr_el3_spd32;
  reg                 cp_mdcr_el3_tdosa;
  reg                 cp_mdcr_el3_tda;
  reg                 cp_mdcr_el3_tpm;
  reg                 cptr_el3_tcpac;
  reg         [31:0]  cp_dacr;
  reg         [31:0]  cp_dacr_ns;
  reg         [31:0]  cp_esr_el1;
  reg          [8:0]  cp_ifsr;
  reg          [8:0]  cp_ifsr_ns;
  reg         [63:0]  cp_far_el1;
  reg         [63:0]  cp_far_el2;
  reg         [63:0]  cp_far_el3;
  reg         [39:2]  rvbaraddr;
  reg                 cp_hcr_id;
  reg                 cp_hcr_cd;
  reg                 cp_hcr_rw;
  reg                 cp_hcr_trvm;
  reg                 cp_hcr_tdz;
  reg                 cp_hcr_tge;
  reg                 cp_hcr_tvm;
  reg                 cp_hcr_ttlb;
  reg                 cp_hcr_tpu;
  reg                 cp_hcr_tpc;
  reg                 cp_hcr_tsw;
  reg                 cp_hcr_tacr;
  reg                 cp_hcr_tidcp;
  reg                 cp_hcr_tsc;
  reg                 cp_hcr_tid3;
  reg                 cp_hcr_tid2;
  reg                 cp_hcr_tid1;
  reg                 cp_hcr_tid0;
  reg                 cp_hcr_twe;
  reg                 cp_hcr_twi;
  reg                 cp_hcr_dc;
  reg          [1:0]  cp_hcr_bsu;
  reg                 cp_hcr_fb;
  reg                 cp_hcr_va;
  reg                 cp_hcr_vi;
  reg                 cp_hcr_vf;
  reg                 cp_hcr_amo;
  reg                 cp_hcr_imo;
  reg                 cp_hcr_fmo;
  reg                 cp_hcr_ptw;
  reg                 cp_hcr_vm;
  reg         [15:0]  cp15_pmu_access_wr;
  reg                 aarch64_at_el3;
  reg                 last_dpu_mmu_on;
  reg                 tlb_abandon;
  reg                 ns_state_de;
  reg                 last_ns_state;
  reg                 last_cp_hcr_vm;
  reg                 last_sctlr_dcache_on;
  reg                 last_sctlr_itd;
  reg                 s2_dcache_on;
  reg         [39:18] periphbase;
  reg                 cp_valid_iss;
  reg                 cp_valid_ex1;
  reg                 cp_valid_ex2;
  reg                 raw_cp_valid_wr;
  reg          [8:0]  cp_decode_iss;
  reg          [8:0]  cp_decode_ex1;
  reg          [8:0]  cp_decode_ex2;
  reg          [8:0]  raw_cp_decode_wr;
  reg                 raw_fp_serialise_iss;
  reg          [7:0]  clusteridaff2;
  reg          [7:0]  clusteridaff1;
  reg                 cptr_el2_tcpac;
  reg          [1:0]  hcr_bsu;
  reg                 hcr_fb;
  reg                 hcr_amo;
  reg                 hcr_imo;
  reg                 hcr_fmo;
  reg                 raw_local_state_en;
  reg                 load_initial;
  reg                 last_load_initial;
  reg                 load_initial_cold;
  reg                 raw_flush_utlb;
  reg                 cp15_clock_en;
  reg                 cp15_ctl_clock_en;
  reg                 sctlr_icache_on;
  reg                 sctlr_dcache_on;
  reg                 sctlr_align_check;
  reg                 sctlr_itd;
  reg                 dpu_mmu_on;
  reg                 giccdisable;
  reg           [1:0] cpu_id_rs;
  reg           [3:0] ctr_cwg_rs;
  reg           [3:0] ctr_erg_rs;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire         [2:0]  dpu_simd_ret;
  wire        [31:0]  nxt_cp_far_el1_upper;
  wire        [31:0]  nxt_cp_far_el1_lower;
  wire                cp_far_el1_upper_en;
  wire                cp_far_el1_lower_en;
  wire        [31:0]  nxt_cp_far_el2_upper;
  wire        [31:0]  nxt_cp_far_el2_lower;
  wire                cp_far_el2_upper_en;
  wire                cp_far_el2_lower_en;
  wire        [63:0]  nxt_cp_far_el3;
  wire                cp_far_el3_en;
  wire                clk_cp15;
  wire                clk_cp15_ctl;
  wire        [31:0]  cp_sctlr_el2;
  wire                nxt_cp_sctlr_el2_te;
  wire                nxt_cp_sctlr_el2_ee;
  wire                nxt_cp_sctlr_el2_wxn;
  wire                nxt_cp_sctlr_el2_i;
  wire                nxt_cp_sctlr_el2_sed;
  wire                nxt_cp_sctlr_el2_itd;
  wire                nxt_cp_sctlr_el2_cp15ben;
  wire                nxt_cp_sctlr_el2_sa;
  wire                nxt_cp_sctlr_el2_c;
  wire                nxt_cp_sctlr_el2_a;
  wire                nxt_cp_sctlr_el2_m;
  wire                cp_sctlr_el2_en;
  wire        [63:0]  cp_cpuactlr;
  wire        [31:0]  cp_cpuectlr;
  wire        [31:0]  cp_actlr_el3;
  wire        [31:0]  cp_actlr_el2;
  wire                cp_hcr_en;
  wire                cp_hcr_va_en;
  wire                cp_hcr2_en;
  wire                nxt_cp_hcr_va;
  wire                nxt_cp_hcr_id;
  wire                nxt_cp_hcr_cd;
  wire        [31:0]  cp_midr;
  wire         [3:0]  cp_ctr_cwg;
  wire         [3:0]  cp_ctr_erg;
  wire        [31:0]  cp_ctr;
  wire        [31:0]  cp_mpidr;
  wire        [31:0]  cp_revidr;
  wire                cp_dczid_el0_dzp;
  wire        [31:0]  cp_dczid_el0;
  wire        [31:0]  cp_hcr;
  wire        [31:0]  cp_hcr2;
  wire        [63:0]  cp_hcr_el2;
  wire        [31:0]  cp_idpfr0;
  wire        [31:0]  cp_idpfr1;
  wire        [31:0]  cp_iddfr;
  wire        [31:0]  cp_idmfr0;
  wire        [31:0]  cp_idmfr1;
  wire        [31:0]  cp_idmfr2;
  wire        [31:0]  cp_idmfr3;
  wire        [31:0]  cp_idifr0;
  wire        [31:0]  cp_idifr1;
  wire        [31:0]  cp_idifr2;
  wire        [31:0]  cp_idifr3;
  wire        [31:0]  cp_idifr4;
  wire        [31:0]  cp_idifr5;
  wire        [31:0]  cp_fpsid;
  wire        [31:0]  cp_mvfr0;
  wire        [31:0]  cp_mvfr1;
  wire        [31:0]  cp_mvfr2;
  wire        [63:0]  cp_aa64pfr0;
  wire        [63:0]  cp_aa64pfr1;
  wire        [63:0]  cp_aa64dfr0;
  wire        [63:0]  cp_aa64dfr1;
  wire        [63:0]  cp_aa64afr0;
  wire        [63:0]  cp_aa64afr1;
  wire        [63:0]  cp_aa64isar0;
  wire        [63:0]  cp_aa64isar1;
  wire        [63:0]  cp_aa64mmfr0;
  wire        [63:0]  cp_aa64mmfr1;
  wire        [63:0]  cp_cpumerrsr;
  wire        [31:0]  cp_scr;
  wire        [15:0]  cp15_pmu_access_ex2;
  wire                nxt_cp_scr_twe;
  wire                nxt_cp_scr_twi;
  wire                nxt_cp_scr_st;
  wire                nxt_cp_scr_rw;
  wire                nxt_cp_scr_sif;
  wire                nxt_cp_scr_hce;
  wire                nxt_cp_scr_smd;
  wire                nxt_cp_scr_aw;
  wire                nxt_cp_scr_fw;
  wire                nxt_cp_scr_ea;
  wire                nxt_cp_scr_fiq;
  wire                nxt_cp_scr_irq;
  wire                nxt_cp_scr_ns;
  wire                cp_scr_en;
  wire        [31:0]  cp_ccsidr;
  wire        [31:0]  cp_clidr;
  wire        [31:0]  cp_vmpidr;
  wire        [63:0]  cp_vmpidr_el2;
  wire        [31:0]  cp_mdcr_el3;
  wire        [31:0]  cp_hcptr;
  wire        [31:0]  cptr_el3;
  wire        [31:0]  cp_hstr_rd;
  wire        [31:0]  cp_hdcr;
  wire        [31:0]  nxt_cp_esr_el2;
  wire                cp_esr_el1_en;
  wire                cp_esr_el3_en;
  wire                cp_hvbar_en_lo;
  wire                cp_htpidr_en_lo;
  wire                cp_tpidrurw_ns_en_lo;
  wire                cp_tpidruro_ns_en_lo;
  wire                cp_tpidrprw_ns_en_lo;
  wire                cp_vbar_en_lo;
  wire                cp_vbar_ns_en_lo;
  wire        [31:4]  nxt_cp_hpfar;
  wire        [31:0]  cp_hpfar_rd;
  wire        [31:0]  cp_hvbar_rd;
  wire        [63:0]  cp_vbar_el2;
  wire        [31:0]  cp_sder_rd;
  wire        [31:0]  cp_fpexc_rd;
  wire        [31:0]  cp_fpsr_rd;
  wire        [31:0]  cp_fpcr_rd;
  wire        [31:0]  cp_fpscr_rd;
  wire        [31:0]  cp_nsacr_rd;
  wire        [63:0]  cp_vbar_el3;
  wire        [31:0]  cp_vbar_rd;
  wire        [31:0]  cp_vbar_ns_rd;
  wire        [63:0]  cp_vbar_el1;
  wire        [31:0]  cp_mvbar_rd;
  wire        [63:0]  cp_rvbar_el3;
  wire        [31:0]  cp_isr;
  wire        [31:0]  cp_cbar;
  wire        [63:0]  cp_cbar_el1;
  wire        [31:0]  cp_sctlr_el3;
  wire        [31:0]  cp_sctlr_el1;
  wire                cp_sctlr_el3_en;
  wire                nxt_cp_sctlr_el3_te;
  wire                nxt_cp_sctlr_el3_afe;
  wire                nxt_cp_sctlr_el3_tre;
  wire                nxt_cp_sctlr_el3_ee;
  wire                nxt_cp_sctlr_el3_uwxn;
  wire                nxt_cp_sctlr_el3_wxn;
  wire                nxt_cp_sctlr_el3_ntwe;
  wire                nxt_cp_sctlr_el3_ntwi;
  wire                nxt_cp_sctlr_el3_v;
  wire                nxt_cp_sctlr_el3_i;
  wire                nxt_cp_sctlr_el3_sed;
  wire                nxt_cp_sctlr_el3_itd;
  wire                nxt_cp_sctlr_el3_cp15ben;
  wire                nxt_cp_sctlr_el3_sa;
  wire                nxt_cp_sctlr_el3_c;
  wire                nxt_cp_sctlr_el3_a;
  wire                nxt_cp_sctlr_el3_m;
  wire                cp_sctlr_el1_en;
  wire                nxt_cp_sctlr_el1_te;
  wire                nxt_cp_sctlr_el1_afe;
  wire                nxt_cp_sctlr_el1_tre;
  wire                nxt_cp_sctlr_el1_uci;
  wire                nxt_cp_sctlr_el1_ee;
  wire                nxt_cp_sctlr_el1_e0e;
  wire                nxt_cp_sctlr_el1_uwxn;
  wire                nxt_cp_sctlr_el1_wxn;
  wire                nxt_cp_sctlr_el1_ntwe;
  wire                nxt_cp_sctlr_el1_ntwi;
  wire                nxt_cp_sctlr_el1_uct;
  wire                nxt_cp_sctlr_el1_dze;
  wire                nxt_cp_sctlr_el1_v;
  wire                nxt_cp_sctlr_el1_i;
  wire                nxt_cp_sctlr_el1_uma;
  wire                nxt_cp_sctlr_el1_sed;
  wire                nxt_cp_sctlr_el1_itd;
  wire                nxt_cp_sctlr_el1_cp15ben;
  wire                nxt_cp_sctlr_el1_sa0;
  wire                nxt_cp_sctlr_el1_sa;
  wire                nxt_cp_sctlr_el1_c;
  wire                nxt_cp_sctlr_el1_a;
  wire                nxt_cp_sctlr_el1_m;
  wire        [31:0]  cp_cpacr;
  wire        [31:0]  nxt_cp_esr_el1;
  wire        [31:0]  expt_dfsr_full;
  wire        [31:0]  nxt_cp_esr_el3;
  wire         [8:0]  nxt_cp_ifsr;
  wire        [31:0]  cp_ifsr_rd;
  wire        [31:0]  cp_ifsr_ns_rd;
  wire                cp_valid_iss_en;
  wire                cp_valid_en;
  wire                nxt_cp_valid_iss;
  wire                nxt_cp_valid_ex1;
  wire                nxt_cp_valid_ex2;
  wire                nxt_cp_valid_wr;
  wire                cp_decode_iss_en;
  wire                cp_decode_ex2_en;
  wire                cp_decode_wr_en;
  wire                cp_valid_wr;
  wire                sel_ns_reg;
  wire                rd_cp15_crn0_midr;
  wire                rd_cp15_crn0_ctr;
  wire                rd_cp15_crn0_mpidr;
  wire                rd_cp15_crn0_revidr;
  wire                rd_cp15_crn0_dczid_el0;
  wire                rd_cp15_crn0_id_pfr0;
  wire                rd_cp15_crn0_id_pfr1;
  wire                rd_cp15_crn0_id_dfr0;
  wire                rd_cp15_crn0_id_mmfr0;
  wire                rd_cp15_crn0_id_mmfr1;
  wire                rd_cp15_crn0_id_mmfr2;
  wire                rd_cp15_crn0_id_mmfr3;
  wire                rd_cp15_crn0_id_isar0;
  wire                rd_cp15_crn0_id_isar1;
  wire                rd_cp15_crn0_id_isar2;
  wire                rd_cp15_crn0_id_isar3;
  wire                rd_cp15_crn0_id_isar4;
  wire                rd_cp15_crn0_id_isar5;
  wire                rd_cp15_crn0_id_mvfr0;
  wire                rd_cp15_crn0_id_mvfr1;
  wire                rd_cp15_crn0_id_mvfr2;
  wire                rd_cp15_crn0_id_aa64pfr0;
  wire                rd_cp15_crn0_id_aa64pfr1;
  wire                rd_cp15_crn0_id_aa64dfr0;
  wire                rd_cp15_crn0_id_aa64dfr1;
  wire                rd_cp15_crn0_id_aa64afr0;
  wire                rd_cp15_crn0_id_aa64afr1;
  wire                rd_cp15_crn0_id_aa64isar0;
  wire                rd_cp15_crn0_id_aa64isar1;
  wire                rd_cp15_crn0_id_aa64mmfr0;
  wire                rd_cp15_crn0_id_aa64mmfr1;
  wire                rd_cp15_crn0_id_ccsidr;
  wire                rd_cp15_crn0_id_clidr;
  wire                rd_cp15_crn0_csselr_s;
  wire                rd_cp15_crn0_csselr_ns;
  wire                rd_cp15_crn0_vpidr;
  wire                rd_cp15_crn0_vmpidr;
  wire                rd_cp15_crn0_vmpidr_el2;
  wire                rd_cp15_crn1_sctlr_s;
  wire                rd_cp15_crn1_sctlr_ns;
  wire                rd_cp15_crn1_sctlr_el1;
  wire                rd_cp15_crn1_sctlr_el3;
  wire                rd_cp15_crn1_cpuactlr;
  wire                rd_cp15_crn1_cpuectlr;
  wire                rd_cp15_crn1_actlr_el3;
  wire                rd_cp15_crn1_actlr_el2;
  wire                rd_cp15_crn1_cpacr;
  wire                rd_cp15_crn1_scr;
  wire                rd_cp15_crn1_hsctlr;
  wire                rd_cp15_crn1_sctlr_el2;
  wire                rd_cp15_crn1_hcr;
  wire                rd_cp15_crn1_hcr_el2;
  wire                rd_cp15_crn1_hcr2;
  wire                rd_cp15_crn1_hdcr;
  wire                rd_cp15_crn1_mdcr_el3;
  wire                rd_cp15_crn1_hcptr;
  wire                rd_cp15_crn1_cptr_el3;
  wire                rd_cp15_crn1_hstr;
  wire                rd_cp15_crn1_sder;
  wire                rd_cp15_crn1_nsacr;
  wire                rd_cp15_crn3_dacr_s;
  wire                rd_cp15_crn3_dacr_ns;
  wire                rd_cp15_crn4_fpsr;
  wire                rd_cp15_crn4_fpcr;
  wire                rd_cp15_crn5_fpexc;
  wire                rd_cp15_crn5_dfsr_s;
  wire                rd_cp15_crn5_dfsr_ns;
  wire                rd_cp15_crn5_ifsr_s;
  wire                rd_cp15_crn5_ifsr_ns;
  wire                rd_cp15_crn5_esr_el1;
  wire                rd_cp15_crn5_esr_el2;
  wire                rd_cp15_crn5_esr_el3;
  wire                rd_cp15_crn6_dfar_s;
  wire                rd_cp15_crn6_dfar_ns;
  wire                rd_cp15_crn6_far_el1;
  wire                rd_cp15_crn6_far_el2;
  wire                rd_cp15_crn6_far_el3;
  wire                rd_cp15_crn6_ifar_s;
  wire                rd_cp15_crn6_ifar_ns;
  wire                rd_cp15_crn6_hdfar;
  wire                rd_cp15_crn6_hifar;
  wire                rd_cp15_crn6_hpfar;
  wire                rd_cp15_crn6_rvbar_el3;
  wire                rd_cp15_crn12_vbar_s;
  wire                rd_cp15_crn12_vbar_ns;
  wire                rd_cp15_crn12_vbar_el1;
  wire                rd_cp15_crn12_vbar_el2;
  wire                rd_cp15_crn12_vbar_el3;
  wire                rd_cp15_crn12_rmr_el3;
  wire                rd_cp15_crn12_mvbar;
  wire                rd_cp15_crn12_isr;
  wire                rd_cp15_crn12_hvbar;
  wire                rd_cp15_crn13_htpidr;
  wire                rd_cp15_crn13_tpidr_el2;
  wire                rd_cp15_crn13_tpidr_el3;
  wire                rd_cp15_crn13_tpidrurw_s;
  wire                rd_cp15_crn13_tpidrurw_ns;
  wire                rd_cp15_crn13_tpidr_el0;
  wire                rd_cp15_crn13_tpidruro_s;
  wire                rd_cp15_crn13_tpidruro_ns;
  wire                rd_cp15_crn13_tpidrro_el0;
  wire                rd_cp15_crn13_tpidrprw_s;
  wire                rd_cp15_crn13_tpidrprw_ns;
  wire                rd_cp15_crn13_tpidr_el1;
  wire                rd_cp15_cbar;
  wire                rd_cp15_cbar_el1;
  wire                rd_cp15_external;
  wire                rd_cp10_fpsid;
  wire                rd_cp10_fpscr;
  wire                rd_cp15_cpumerrsr;
  wire                wr_cp15_crn0_revidr;
  wire                wr_cp15_crn0_csselr_s;
  wire                wr_cp15_crn0_csselr_ns;
  wire                wr_cp15_crn0_vpidr;
  wire                wr_cp15_crn0_vmpidr;
  wire                wr_cp15_crn0_vmpidr_el2;
  wire                wr_cp15_crn1_sctlr_s;
  wire                wr_cp15_crn1_sctlr_ns;
  wire                wr_cp15_crn1_sctlr_el1;
  wire                wr_cp15_crn1_sctlr_el3;
  wire                wr_cp15_crn1_cpuactlr;
  wire                wr_cp15_crn1_cpuectlr;
  wire                wr_cp15_crn1_actlr_el3;
  wire                wr_cp15_crn1_actlr_el2;
  wire                wr_cp15_crn1_cpacr;
  wire                wr_cp15_crn1_scr;
  wire                wr_cp15_crn1_hsctlr;
  wire                wr_cp15_crn1_sctlr_el2;
  wire                wr_cp15_crn1_hcr;
  wire                wr_cp15_crn1_hcr_el2;
  wire                wr_cp15_crn1_hcr2;
  wire                wr_cp15_crn1_hdcr;
  wire                wr_cp15_crn1_mdcr_el3;
  wire                wr_cp15_crn1_hcptr;
  wire                wr_cp15_crn1_cptr_el3;
  wire                wr_cp15_crn1_hstr;
  wire                wr_cp15_crn1_sder;
  wire                wr_cp15_crn1_nsacr;
  wire                wr_cp15_crn3_dacr_s;
  wire                wr_cp15_crn3_dacr_ns;
  wire                wr_cp15_crn4_fpsr;
  wire                wr_cp15_crn4_fpcr;
  wire                wr_cp15_crn5_fpexc;
  wire                wr_cp15_crn5_dfsr_s;
  wire                wr_cp15_crn5_dfsr_ns;
  wire                wr_cp15_crn5_ifsr_s;
  wire                wr_cp15_crn5_ifsr_ns;
  wire                wr_cp15_crn5_esr_el1;
  wire                wr_cp15_crn5_esr_el2;
  wire                wr_cp15_crn5_esr_el3;
  wire                wr_cp15_crn6_dfar_s;
  wire                wr_cp15_crn6_dfar_ns;
  wire                wr_cp15_crn6_far_el1;
  wire                wr_cp15_crn6_far_el2;
  wire                wr_cp15_crn6_far_el3;
  wire                wr_cp15_crn6_ifar_s;
  wire                wr_cp15_crn6_ifar_ns;
  wire                wr_cp15_crn6_hdfar;
  wire                wr_cp15_crn6_hifar;
  wire                wr_cp15_crn6_hpfar;
  wire                wr_cp15_crn7_icimvau;
  wire                wr_cp15_crn12_vbar_s;
  wire                wr_cp15_crn12_vbar_ns;
  wire                wr_cp15_crn12_vbar_el1;
  wire                wr_cp15_crn12_vbar_el2;
  wire                wr_cp15_crn12_vbar_el3;
  wire                wr_cp15_crn12_rmr_el3;
  wire                wr_cp15_crn12_mvbar;
  wire                wr_cp15_crn12_hvbar;
  wire                wr_cp15_crn13_htpidr;
  wire                wr_cp15_crn13_tpidr_el2;
  wire                wr_cp15_crn13_tpidr_el3;
  wire                wr_cp15_crn13_tpidrurw_s;
  wire                wr_cp15_crn13_tpidrurw_ns;
  wire                wr_cp15_crn13_tpidr_el0;
  wire                wr_cp15_crn13_tpidruro_s;
  wire                wr_cp15_crn13_tpidruro_ns;
  wire                wr_cp15_crn13_tpidrro_el0;
  wire                wr_cp15_crn13_tpidrprw_s;
  wire                wr_cp15_crn13_tpidrprw_ns;
  wire                wr_cp15_crn13_tpidr_el1;
  wire                wr_cp10_fpscr;
  wire        [63:0]  cp_read_data_int_wr;
  wire        [63:0]  cp_read_data_ext_wr;
  wire        [63:0]  mcr_data_wr;
  wire        [63:0]  mrc_data_wr;
  wire                nxt_tlb_abandon;
  wire                cptr_el2_tfp;
  wire                cptr_el2_tfp_rd;
  wire                hcptr_tcp11;
  wire                hcptr_tase;
  wire                hcptr_tase_rd;
  wire                cptr_el3_tfp;
  wire                nsacr_cp10;
  wire                nsacr_cp11;
  wire                nsacr_nsasedis;
  wire                nsfpudis;
  wire                nsasedis;
  wire         [1:0]  cpacr_el1_fpen_rd;
  wire         [1:0]  cpacr_cp11_rd;
  wire                cpacr_asedis_rd;
  wire                cpacr_asedis;
  wire                cp_fpexc_en;
  wire                flush_utlb;
  wire                nxt_flush_utlb;
  wire                cp_ccsidr_instr_sel;
  wire                ns_not_hyp;
  wire         [1:0]  nxt_hcr_bsu;
  wire                nxt_hcr_fb;
  wire                nxt_hcr_amo;
  wire                nxt_hcr_imo;
  wire                nxt_hcr_fmo;
  wire                nxt_s2_dcache_on;
  wire                nxt_local_state_en;
  wire                cp_vmpidr_en;
  wire                cp_vmpidr_aff3_en;
  wire                nxt_cp_vmpidr_u;
  wire                nxt_cp_vmpidr_mt;
  wire         [7:0]  nxt_cp_vmpidr_aff3;
  wire         [7:0]  nxt_cp_vmpidr_aff2;
  wire         [7:0]  nxt_cp_vmpidr_aff1;
  wire         [7:0]  nxt_cp_vmpidr_aff0;
  wire                local_state_en;
  wire                aarch64_at_el2;
  wire                aarch64_at_el1;
  wire                nxt_cp15_clock_en;
  wire                nxt_cp15_ctl_clock_en;
  wire                nxt_cp_rmr_el3_aa64;
  wire                cp_rmr_el3_aa64_en;
  wire        [31:0]  cp_rmr;
  wire                cryptodisable;
  wire        [31:0]  cp_csselr;
  wire        [31:0]  cp_csselr_ns;
  wire                dpu_icache_on;
  wire                nxt_cp_trap_fp;
  wire                nxt_cp_trap_neon;
  wire         [3:0]  l2_size;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Intermediate clock gate
  // ------------------------------------------------------

  // CP15 registers that are only written using MCR instructions can be
  // gated using an intermediate clock gate
  assign nxt_cp15_clock_en = nxt_cp_valid_wr | load_initial | last_load_initial;

  // CP15 pipeline can be gated if there's nothing in it
  assign nxt_cp15_ctl_clock_en = nxt_cp_valid_iss | cp_valid_iss | cp_valid_ex1 | cp_valid_ex2 | raw_cp_valid_wr;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      cp15_clock_en     <= 1'b1;
      cp15_ctl_clock_en <= 1'b1;
    end else begin
      cp15_clock_en     <= nxt_cp15_clock_en;
      cp15_ctl_clock_en <= nxt_cp15_ctl_clock_en;
    end

  ca53_cell_inter_clkgate u_inter_clkgate_cp15 (
    .clk_i         (clk),
    .clk_enable_i  (cp15_clock_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_cp15)
  );

  ca53_cell_inter_clkgate u_inter_clkgate_cp15_ctl (
    .clk_i         (clk),
    .clk_enable_i  (cp15_ctl_clock_en),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_cp15_ctl)
  );

  // ------------------------------------------------------
  // Create buses
  // ------------------------------------------------------

  assign mcr_data_wr = {64{raw_cp_valid_wr}} & st0_data_wr_i[63:0];
  assign mrc_data_wr = cp_read_data_int_wr[63:0] |
                       cp_read_data_ext_wr[63:0] |
                       dbg_cp_rd_data_i[63:0]    |
                       pmu_cp_rd_data_i[63:0]    |
                       { {32{1'b0}}, psr_cp_rd_data_i[31:0]};

  // ---------------------------------------------------------
  // Initialise registers on reset
  // ---------------------------------------------------------

  // The reset values of some CP15 registers depend on top-level inputs.
  // Therefore the load_initial register is reset to 1, then used as an
  // enable to load these values in on the first clock cycle during reset.
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      load_initial <= 1'b1;
    else if (load_initial)
      load_initial <= 1'b0;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      last_load_initial <= 1'b0;
    else
      last_load_initial <= load_initial;

  // load_initial_cold is only used on a cold (power-on) reset
  always @(posedge clk_cp15 or negedge po_reset_n)
    if (~po_reset_n)
      load_initial_cold <= 1'b1;
    else if (load_initial_cold)
      load_initial_cold <= 1'b0;

  // ---------------------------------------------------------
  // Revision field, ID and static config registers
  // ---------------------------------------------------------

  always @(posedge clk_cp15)
    if (load_initial) begin
      clusteridaff2   <= gov_clusteridaff2_i;
      clusteridaff1   <= gov_clusteridaff1_i;
      giccdisable     <= gov_giccdisable_i;
      cpu_id_rs       <= cpu_id_i;
      ctr_cwg_rs      <= ctr_cwg_i;
      ctr_erg_rs      <= ctr_erg_i;
    end

generate if (L2_CACHE) begin : L2_CACHE_PRESENT0
  reg [3:0] l2_size_rs;

  always @(posedge clk_cp15)
    if (load_initial)
      l2_size_rs <= l2_size_i;

  assign l2_size = l2_size_rs;

end else begin : L2_CACHE_PRESENT0_STUBS
  assign l2_size = {4{1'b0}};
end endgenerate

generate if (CRYPTO) begin : g_cryptodisable
  reg cryptodisable_rs;

  always @(posedge clk_cp15)
    if (load_initial)
      cryptodisable_rs <= gov_cryptodisable_i;

  assign cryptodisable = cryptodisable_rs;
end else begin : g_cryptodisable_stubs
  assign cryptodisable = 1'b1;
end endgenerate

  // ------------------------------------------------------
  // CP Decode pipeline
  // ------------------------------------------------------

  assign nxt_cp_valid_iss = cp_valid_de_i & ~flush_wr_i;
  assign nxt_cp_valid_ex1 = cp_valid_iss  & ~flush_wr_i & ~stall_iss_i;
  assign nxt_cp_valid_ex2 = cp_valid_ex1  & ~flush_wr_i;
  assign nxt_cp_valid_wr  = cp_valid_ex2  & ~flush_wr_i;

  // Valid pipeline
  assign cp_valid_iss_en = ~stall_iss_i | flush_wr_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cp_valid_iss    <= 1'b0;
    else if (cp_valid_iss_en)
      cp_valid_iss    <= nxt_cp_valid_iss;

  assign cp_valid_en = ~stall_wr_i | flush_wr_i;

  always @(posedge clk_cp15_ctl or negedge reset_n)
    if (~reset_n) begin
      cp_valid_ex1    <= 1'b0;
      cp_valid_ex2    <= 1'b0;
      raw_cp_valid_wr <= 1'b0;
    end else if (cp_valid_en) begin
      cp_valid_ex1    <= nxt_cp_valid_ex1;
      cp_valid_ex2    <= nxt_cp_valid_ex2;
      raw_cp_valid_wr <= nxt_cp_valid_wr;
    end

  // Decode pipeline
  assign cp_decode_iss_en = nxt_cp_valid_iss & ~stall_iss_i;
  assign cp_decode_ex2_en = nxt_cp_valid_ex2 & ~stall_wr_i;
  assign cp_decode_wr_en  = nxt_cp_valid_wr  & ~stall_wr_i;

  always @(posedge clk)
    if (cp_decode_iss_en) begin
      cp_decode_iss        <= cp_decode_de_i[8:0];
      raw_fp_serialise_iss <= fp_serialise_de_i;
    end

  always @(posedge clk_cp15_ctl)
    if (nxt_cp_valid_ex1)
      cp_decode_ex1 <= cp_decode_iss[8:0];

  always @(posedge clk_cp15_ctl)
    if (cp_decode_ex2_en)
      cp_decode_ex2 <= cp_decode_ex1[8:0];

  always @(posedge clk_cp15_ctl)
    if (cp_decode_wr_en) begin
      raw_cp_decode_wr   <= cp_decode_ex2[8:0];
      cp15_pmu_access_wr <= cp15_pmu_access_ex2;
    end

  // Qualify CP decode
  assign cp_valid_wr = raw_cp_valid_wr & cc_pass_instr0_wr_i & ~flush_ret_i & ~expt_quash_wr_i;

  // Indicate to the ctl unit that an instruction accessing the FPSR/FPSCR is
  // in Iss, and should stall until any outstanding flag writes have occurred
  assign fp_serialize_iss_o = cp_valid_iss & raw_fp_serialise_iss;

  // Indicate to the ctl unit that the MRC instruction is valid
  assign mrc_instr_ex1_o = cp_valid_ex1 & ~cp_decode_ex1[8];
  assign mrc_instr_ex2_o = cp_valid_ex2 & ~cp_decode_ex2[8];

  // Indicate to ETM interface that the CP instruction is either MCR or MRC
  assign mrc_instr_wr_o = raw_cp_valid_wr & ~raw_cp_decode_wr[8];

  // If EL3 is AArch32, then secure banked registers are accessed when the NS
  // bit is clear, and the nonsecure banked registers are accessed when NS is set
  // IF EL3 is AArch64, then there is no banking and the nonsecure copy is always
  // accessed from AArch32
  assign sel_ns_reg = aarch64_at_el3 | cp_scr_ns;

  // ------------------------------------------------------
  // Enable generation (Ex2 Stage, PMU)
  // ------------------------------------------------------

  // Create a one-hot bus for the PMU counters to ease timing pressure
  assign cp15_pmu_access_ex2[15:0] = {(cp_decode_ex2[7:0] == `CA53_CRN9_PMCR),        // [15]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMNCNTENSET), // [14]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMNCNTENCLR), // [13]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMOVSR),      // [12]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMOVSSET),    // [11]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMSWINC),     // [10]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMSELR),      // [ 9]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMCCNTR),     // [ 8]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMCCNTR_64),  // [ 7]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMXEVTYPER),  // [ 6]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMXEVCNTR),   // [ 5]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMUSERENR),   // [ 4]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMINTENSET),  // [ 3]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMINTENCLR),  // [ 2]
                                      (cp_decode_ex2[7:0] == `CA53_CRN9_PMCEID0),     // [ 1]
                                      (cp_decode_ex2[7:0] == `CA53_CRN14_PMCCFILTR)}; // [ 0]

  // ------------------------------------------------------
  // Read enable generation (Wr Stage)
  // ------------------------------------------------------

  assign rd_cp15_crn0_midr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_MIDR});
  assign rd_cp15_crn0_ctr             = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_CTR});
  assign rd_cp15_crn0_mpidr           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_MPIDR});
  assign rd_cp15_crn0_revidr          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_REVIDR});
  assign rd_cp15_crn0_dczid_el0       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_DCZID_EL0});
  assign rd_cp15_crn0_id_pfr0         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_PFR0});
  assign rd_cp15_crn0_id_pfr1         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_PFR1});
  assign rd_cp15_crn0_id_dfr0         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_DFR0});
  assign rd_cp15_crn0_id_mmfr0        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_MMFR0});
  assign rd_cp15_crn0_id_mmfr1        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_MMFR1});
  assign rd_cp15_crn0_id_mmfr2        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_MMFR2});
  assign rd_cp15_crn0_id_mmfr3        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_MMFR3});
  assign rd_cp15_crn0_id_isar0        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR0});
  assign rd_cp15_crn0_id_isar1        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR1});
  assign rd_cp15_crn0_id_isar2        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR2});
  assign rd_cp15_crn0_id_isar3        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR3});
  assign rd_cp15_crn0_id_isar4        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR4});
  assign rd_cp15_crn0_id_isar5        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_ISAR5});
  assign rd_cp15_crn0_id_mvfr0        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_MVFR0_EL1});
  assign rd_cp15_crn0_id_mvfr1        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_MVFR1_EL1});
  assign rd_cp15_crn0_id_mvfr2        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_MVFR2_EL1});
  assign rd_cp15_crn0_id_aa64pfr0     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64PFR0_EL1});
  assign rd_cp15_crn0_id_aa64pfr1     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64PFR1_EL1});
  assign rd_cp15_crn0_id_aa64dfr0     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64DFR0_EL1});
  assign rd_cp15_crn0_id_aa64dfr1     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64DFR1_EL1});
  assign rd_cp15_crn0_id_aa64afr0     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64AFR0_EL1});
  assign rd_cp15_crn0_id_aa64afr1     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64AFR1_EL1});
  assign rd_cp15_crn0_id_aa64isar0    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64ISAR0_EL1});
  assign rd_cp15_crn0_id_aa64isar1    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64ISAR1_EL1});
  assign rd_cp15_crn0_id_aa64mmfr0    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64MMFR0_EL1});
  assign rd_cp15_crn0_id_aa64mmfr1    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_AA64MMFR1_EL1});
  assign rd_cp15_crn0_id_ccsidr       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_CCSIDR});
  assign rd_cp15_crn0_id_clidr        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_ID_CLIDR});
  assign rd_cp15_crn0_csselr_s        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_CSSELR}) & ~sel_ns_reg;
  assign rd_cp15_crn0_csselr_ns       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_CSSELR}) &  sel_ns_reg;
  assign rd_cp15_crn0_vpidr           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_VPIDR});
  assign rd_cp15_crn0_vmpidr          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_VMPIDR}) & ~aarch64_state_i;
  assign rd_cp15_crn0_vmpidr_el2      = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN0_VMPIDR}) &  aarch64_state_i;
  assign rd_cp15_crn1_sctlr_s         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SCTLR})  & ~sel_ns_reg;
  assign rd_cp15_crn1_sctlr_ns        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SCTLR})  &  sel_ns_reg;
  assign rd_cp15_crn1_sctlr_el1       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SCTLR_EL1});
  assign rd_cp15_crn1_sctlr_el3       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SCTLR_EL3});
  assign rd_cp15_crn1_cpuactlr        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_CPUACTLR});
  assign rd_cp15_crn1_cpuectlr        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_CPUECTLR});
  assign rd_cp15_crn1_actlr_el3       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_ACTLR_EL3});
  assign rd_cp15_crn1_actlr_el2       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_ACTLR_EL2});
  assign rd_cp15_crn1_cpacr           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_CPACR});
  assign rd_cp15_crn1_scr             = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SCR});
  assign rd_cp15_crn1_hsctlr          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HSCTLR}) & ~aarch64_state_i;
  assign rd_cp15_crn1_sctlr_el2       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HSCTLR}) &  aarch64_state_i;
  assign rd_cp15_crn1_hcr             = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HCR}) & ~aarch64_state_i;
  assign rd_cp15_crn1_hcr_el2         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HCR}) &  aarch64_state_i;
  assign rd_cp15_crn1_hcr2            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HCR2});
  assign rd_cp15_crn1_hdcr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HDCR});
  assign rd_cp15_crn1_mdcr_el3        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_MDCR_EL3});
  assign rd_cp15_crn1_hcptr           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HCPTR});
  assign rd_cp15_crn1_cptr_el3        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_CPTR_EL3});
  assign rd_cp15_crn1_hstr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_HSTR});
  assign rd_cp15_crn1_sder            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_SDER});
  assign rd_cp15_crn1_nsacr           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN1_NSACR});
  assign rd_cp15_crn3_dacr_s          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN3_DACR}) & ~sel_ns_reg;
  assign rd_cp15_crn3_dacr_ns         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN3_DACR}) &  sel_ns_reg;
  assign rd_cp15_crn4_fpsr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN4_FPSR});
  assign rd_cp15_crn4_fpcr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN4_FPCR});
  assign rd_cp15_crn5_fpexc           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_FPEXC});
  assign rd_cp15_crn5_dfsr_s          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_DFSR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn5_dfsr_ns         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_DFSR}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn5_ifsr_s          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_IFSR}) & ~sel_ns_reg;
  assign rd_cp15_crn5_ifsr_ns         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_IFSR}) &  sel_ns_reg;
  assign rd_cp15_crn5_esr_el1         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_DFSR}) &  aarch64_state_i;
  assign rd_cp15_crn5_esr_el2         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_ESR_EL2});
  assign rd_cp15_crn5_esr_el3         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN5_ESR_EL3});
  assign rd_cp15_crn6_dfar_s          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_DFAR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn6_dfar_ns         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_DFAR}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn6_far_el1         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_DFAR})               &  aarch64_state_i;
  assign rd_cp15_crn6_far_el2         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_FAR_EL2});
  assign rd_cp15_crn6_far_el3         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_FAR_EL3});
  assign rd_cp15_crn6_ifar_s          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_IFAR}) & ~sel_ns_reg;
  assign rd_cp15_crn6_ifar_ns         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_IFAR}) &  sel_ns_reg;
  assign rd_cp15_crn6_hdfar           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_HDFAR});
  assign rd_cp15_crn6_hifar           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_HIFAR});
  assign rd_cp15_crn6_hpfar           = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN6_HPFAR});
  assign rd_cp15_crn6_rvbar_el3       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_RVBAR_EL3});
  assign rd_cp15_crn12_vbar_s         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_VBAR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn12_vbar_ns        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_VBAR}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn12_vbar_el1       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_VBAR}) &  aarch64_state_i;
  assign rd_cp15_crn12_rmr_el3        = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_RMR_EL3});
  assign rd_cp15_crn12_mvbar          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_MVBAR});
  assign rd_cp15_crn12_isr            = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_ISR});
  assign rd_cp15_crn12_hvbar          = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_HVBAR}) & ~aarch64_state_i;
  assign rd_cp15_crn12_vbar_el2       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_HVBAR}) &  aarch64_state_i;
  assign rd_cp15_crn12_vbar_el3       = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN12_VBAR_EL3});
  assign rd_cp15_crn13_htpidr         = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_HTPIDR}) & ~aarch64_state_i;
  assign rd_cp15_crn13_tpidr_el2      = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_HTPIDR}) &  aarch64_state_i;
  assign rd_cp15_crn13_tpidr_el3      = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDR_EL3});
  assign rd_cp15_crn13_tpidrurw_s     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURW}) & ~sel_ns_reg;
  assign rd_cp15_crn13_tpidrurw_ns    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURW}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn13_tpidr_el0      = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURW})               &  aarch64_state_i;
  assign rd_cp15_crn13_tpidruro_s     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURO}) & ~sel_ns_reg;
  assign rd_cp15_crn13_tpidruro_ns    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURO}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn13_tpidrro_el0    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRURO}) &                aarch64_state_i;
  assign rd_cp15_crn13_tpidrprw_s     = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRPRW}) & ~sel_ns_reg;
  assign rd_cp15_crn13_tpidrprw_ns    = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRPRW}) &  sel_ns_reg & ~aarch64_state_i;
  assign rd_cp15_crn13_tpidr_el1      = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN13_TPIDRPRW})               &  aarch64_state_i;
  assign rd_cp15_cbar                 = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CP15_CBAR}) & ~aarch64_state_i;
  assign rd_cp15_cbar_el1             = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CP15_CBAR}) &  aarch64_state_i;
  assign rd_cp15_external             = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CP15_MRC_EXTERNAL});
  assign rd_cp10_fpsid                = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_VFP_FPSID});
  assign rd_cp10_fpscr                = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_VFP_FPSCR});

  // ------------------------------------------------------
  // Write enable generation (Wr Stage)
  // ------------------------------------------------------

  assign wr_cp15_crn0_revidr          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_REVIDR});
  assign wr_cp15_crn0_csselr_s        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_CSSELR}) & ~sel_ns_reg;
  assign wr_cp15_crn0_csselr_ns       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_CSSELR}) &  sel_ns_reg;
  assign wr_cp15_crn0_vpidr           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_VPIDR});
  assign wr_cp15_crn0_vmpidr          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_VMPIDR}) & ~aarch64_state_i;
  assign wr_cp15_crn0_vmpidr_el2      = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN0_VMPIDR}) &  aarch64_state_i;
  assign wr_cp15_crn1_sctlr_s         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SCTLR})  & ~sel_ns_reg;
  assign wr_cp15_crn1_sctlr_ns        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SCTLR})  &  sel_ns_reg;
  assign wr_cp15_crn1_sctlr_el1       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SCTLR_EL1});
  assign wr_cp15_crn1_sctlr_el3       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SCTLR_EL3});
  assign wr_cp15_crn1_cpuactlr        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_CPUACTLR});
  assign wr_cp15_crn1_cpuectlr        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_CPUECTLR});
  assign wr_cp15_crn1_actlr_el3       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_ACTLR_EL3});
  assign wr_cp15_crn1_actlr_el2       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_ACTLR_EL2});
  assign wr_cp15_crn1_cpacr           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_CPACR});
  assign wr_cp15_crn1_scr             = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SCR});
  assign wr_cp15_crn1_hsctlr          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HSCTLR}) & ~aarch64_state_i;
  assign wr_cp15_crn1_sctlr_el2       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HSCTLR}) &  aarch64_state_i;
  assign wr_cp15_crn1_hcr             = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HCR}) & ~aarch64_state_i;
  assign wr_cp15_crn1_hcr_el2         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HCR}) &  aarch64_state_i;
  assign wr_cp15_crn1_hcr2            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HCR2});
  assign wr_cp15_crn1_hdcr            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HDCR});
  assign wr_cp15_crn1_mdcr_el3        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_MDCR_EL3});
  assign wr_cp15_crn1_hcptr           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HCPTR});
  assign wr_cp15_crn1_cptr_el3        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_CPTR_EL3});
  assign wr_cp15_crn1_hstr            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_HSTR});
  assign wr_cp15_crn1_sder            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_SDER});
  assign wr_cp15_crn1_nsacr           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN1_NSACR});
  assign wr_cp15_crn3_dacr_s          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN3_DACR}) & ~sel_ns_reg;
  assign wr_cp15_crn3_dacr_ns         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN3_DACR}) &  sel_ns_reg;
  assign wr_cp15_crn4_fpsr            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN4_FPSR});
  assign wr_cp15_crn4_fpcr            = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN4_FPCR});
  assign wr_cp15_crn5_fpexc           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_FPEXC});
  assign wr_cp15_crn5_dfsr_s          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_DFSR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn5_dfsr_ns         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_DFSR}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn5_ifsr_s          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_IFSR}) & ~sel_ns_reg;
  assign wr_cp15_crn5_ifsr_ns         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_IFSR}) &  sel_ns_reg;
  assign wr_cp15_crn5_esr_el1         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_DFSR}) &  aarch64_state_i;
  assign wr_cp15_crn5_esr_el2         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_ESR_EL2});
  assign wr_cp15_crn5_esr_el3         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN5_ESR_EL3});
  assign wr_cp15_crn6_dfar_s          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_DFAR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn6_dfar_ns         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_DFAR}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn6_far_el1         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_DFAR})               &  aarch64_state_i;
  assign wr_cp15_crn6_far_el2         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_FAR_EL2});
  assign wr_cp15_crn6_far_el3         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_FAR_EL3});
  assign wr_cp15_crn6_ifar_s          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_IFAR}) & ~sel_ns_reg;
  assign wr_cp15_crn6_ifar_ns         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_IFAR}) &  sel_ns_reg;
  assign wr_cp15_crn6_hdfar           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_HDFAR});
  assign wr_cp15_crn6_hifar           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_HIFAR});
  assign wr_cp15_crn6_hpfar           = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN6_HPFAR});
  assign wr_cp15_crn7_icimvau         =               (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN7_ICIMVAU});
  assign wr_cp15_crn12_vbar_s         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_VBAR}) & ~sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn12_vbar_ns        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_VBAR}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn12_vbar_el1       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_VBAR}) &  aarch64_state_i;
  assign wr_cp15_crn12_mvbar          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_MVBAR});
  assign wr_cp15_crn12_hvbar          = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_HVBAR}) & ~aarch64_state_i;
  assign wr_cp15_crn12_vbar_el2       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_HVBAR}) &  aarch64_state_i;
  assign wr_cp15_crn12_vbar_el3       = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_VBAR_EL3});
  assign wr_cp15_crn12_rmr_el3        = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN12_RMR_EL3});
  assign wr_cp15_crn13_htpidr         = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_HTPIDR}) & ~aarch64_state_i;
  assign wr_cp15_crn13_tpidr_el2      = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_HTPIDR}) &  aarch64_state_i;
  assign wr_cp15_crn13_tpidr_el3      = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDR_EL3});
  assign wr_cp15_crn13_tpidrurw_s     = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURW}) & ~sel_ns_reg;
  assign wr_cp15_crn13_tpidrurw_ns    = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURW}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn13_tpidr_el0      = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURW})               &  aarch64_state_i;
  assign wr_cp15_crn13_tpidruro_s     = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURO}) & ~sel_ns_reg;
  assign wr_cp15_crn13_tpidruro_ns    = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURO}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn13_tpidrro_el0    = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRURO}) &                aarch64_state_i;
  assign wr_cp15_crn13_tpidrprw_s     = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRPRW}) & ~sel_ns_reg;
  assign wr_cp15_crn13_tpidrprw_ns    = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRPRW}) &  sel_ns_reg & ~aarch64_state_i;
  assign wr_cp15_crn13_tpidr_el1      = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN13_TPIDRPRW})               &  aarch64_state_i;
  assign wr_cp10_fpscr                = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_VFP_FPSCR});

  // ------------------------------------------------------
  // ID Code Register (MIDR & MIDR_EL1)
  // ------------------------------------------------------

  assign cp_midr = `CA53_IDCR_READ_VALUE;

  // ------------------------------------------------------
  // Cache Type Register (CTR & CTR_EL0)
  // ------------------------------------------------------

  // The CWG and ERG fields of the CTR can be overridden, to
  // support systems with heterogeneous cache line lengths
  
  assign cp_ctr_cwg = (ctr_cwg_rs >= `CA53_CTR_CWG) ? ctr_cwg_rs : `CA53_CTR_CWG;
  assign cp_ctr_erg = (ctr_erg_rs >= `CA53_CTR_ERG) ? ctr_erg_rs : `CA53_CTR_ERG;

  assign cp_ctr = {1'b1,                // RES1
                   3'b000,              // RES0
                   cp_ctr_cwg,          // CWG
                   cp_ctr_erg,          // ERG
                   `CA53_CTR_DMINLINE,  // DminLine
                   `CA53_CTR_L1IP,      // L1Ip
                   10'h000,             // RES0
                   `CA53_CTR_IMINLINE   // IminLine
                  };

  // ------------------------------------------------------
  // TCM Type Register
  // ------------------------------------------------------
  // Read As Zero

  // ------------------------------------------------------
  // TLB Type Register
  // ------------------------------------------------------
  // Read As Zero

  // ------------------------------------------------------
  // Multiprocessor ID Register (MPIDR & MPIDR_EL1)
  // ------------------------------------------------------

  // The top 32 bits of Arch64 MPIDR_EL1 are tied to zero so returns the same value as AArch32 MPIDR
  assign cp_mpidr = `CA53_MPIDR_READ_VALUE(clusteridaff2, clusteridaff1, cpu_id_rs);

  // ------------------------------------------------------
  // Revision ID Register (REVIDR & REVIDR_EL1)
  // ------------------------------------------------------

  // Note: This register can never actually be written, but a write enable is
  //       generated in order to prevent synthesis optimising away the flops
  
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      ca53_ecoid_data <= 12'h180;
    else if (wr_cp15_crn0_revidr)
      ca53_ecoid_data <= mcr_data_wr[11:0];

  assign cp_revidr = { {20{1'b0}}, ca53_ecoid_data};

  // ------------------------------------------------------
  // Data Cache Zero ID Register (DCZID_EL0)
  // ------------------------------------------------------

  assign cp_dczid_el0_dzp = ((dpu_exception_level_i == 2'b00) & ~cp_sctlr_el1_dze) |
                            (~dpu_exception_level_i[1] & ns_state_i & cp_hcr_tdz);

  assign cp_dczid_el0 = { {27{1'b0}}, cp_dczid_el0_dzp, 4'h4}; // 64-byte blocks

  // ------------------------------------------------------
  // CPU ID Attribute Registers
  // ------------------------------------------------------

  assign cp_idpfr0    = `CA53_ID_PFR0_READ_VALUE;
  assign cp_idpfr1    = `CA53_ID_PFR1_READ_VALUE(giccdisable);
  assign cp_iddfr     = `CA53_ID_DFR0_READ_VALUE;
  assign cp_idmfr0    = `CA53_ID_MMFR0_READ_VALUE;
  assign cp_idmfr1    = `CA53_ID_MMFR1_READ_VALUE;
  assign cp_idmfr2    = `CA53_ID_MMFR2_READ_VALUE;
  assign cp_idmfr3    = `CA53_ID_MMFR3_READ_VALUE;
  assign cp_idifr0    = `CA53_ID_ISAR0_READ_VALUE;
  assign cp_idifr1    = `CA53_ID_ISAR1_READ_VALUE;
  assign cp_idifr2    = `CA53_ID_ISAR2_READ_VALUE;
  assign cp_idifr3    = `CA53_ID_ISAR3_READ_VALUE;
  assign cp_idifr4    = `CA53_ID_ISAR4_READ_VALUE;
  assign cp_idifr5    = `CA53_ID_ISAR5_READ_VALUE(cryptodisable);

  assign cp_fpsid     = `CA53_FPSID_READ_VALUE;
  assign cp_mvfr0     = `CA53_MVFR0_READ_VALUE;
  assign cp_mvfr1     = `CA53_MVFR1_READ_VALUE;
  assign cp_mvfr2     = `CA53_MVFR2_READ_VALUE;

  assign cp_aa64pfr0  = `CA53_AA64PFR0_READ_VALUE(giccdisable);
  assign cp_aa64pfr1  = `CA53_AA64PFR1_READ_VALUE;
  assign cp_aa64dfr0  = `CA53_AA64DFR0_READ_VALUE;
  assign cp_aa64dfr1  = `CA53_AA64DFR1_READ_VALUE;
  assign cp_aa64afr0  = `CA53_AA64AFR0_READ_VALUE;
  assign cp_aa64afr1  = `CA53_AA64AFR1_READ_VALUE;
  assign cp_aa64isar0 = `CA53_AA64ISAR0_READ_VALUE(cryptodisable);
  assign cp_aa64isar1 = `CA53_AA64ISAR1_READ_VALUE;
  assign cp_aa64mmfr0 = `CA53_AA64MMFR0_READ_VALUE;
  assign cp_aa64mmfr1 = `CA53_AA64MMFR1_READ_VALUE;

  // ------------------------------------------------------
  // Cache Level ID Register (CLIDR & CLIDR_EL1)
  // ------------------------------------------------------

  assign cp_clidr = `CA53_CLIDR_READ_VALUE;

  // ------------------------------------------------------
  // Virtualization Processor ID Register (VPIDR)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_vpidr <= `CA53_IDCR_READ_VALUE;
    else if (wr_cp15_crn0_vpidr)
      cp_vpidr <= mcr_data_wr[31:0];

  // ------------------------------------------------------
  // Virtualization Multiprocessor ID Register (VMPIDR & VMPIDR_EL2)
  // ------------------------------------------------------

  assign nxt_cp_vmpidr_u    = load_initial ? 1'b0                    : mcr_data_wr[30];
  assign nxt_cp_vmpidr_mt   = load_initial ? 1'b0                    : mcr_data_wr[24];
  assign nxt_cp_vmpidr_aff3 = load_initial ? 8'h00                   : mcr_data_wr[39:32];
  assign nxt_cp_vmpidr_aff2 = load_initial ? clusteridaff2           : mcr_data_wr[23:16];
  assign nxt_cp_vmpidr_aff1 = load_initial ? clusteridaff1           : mcr_data_wr[15:8];
  assign nxt_cp_vmpidr_aff0 = load_initial ? {6'h00, cpu_id_rs[1:0]} : mcr_data_wr[7:0];

  assign cp_vmpidr_en       = load_initial | wr_cp15_crn0_vmpidr | wr_cp15_crn0_vmpidr_el2;
  assign cp_vmpidr_aff3_en  = load_initial |                       wr_cp15_crn0_vmpidr_el2;

  always @(posedge clk_cp15)
    if (cp_vmpidr_en) begin
      cp_vmpidr_u    <= nxt_cp_vmpidr_u;
      cp_vmpidr_mt   <= nxt_cp_vmpidr_mt;
      cp_vmpidr_aff0 <= nxt_cp_vmpidr_aff0;
      cp_vmpidr_aff1 <= nxt_cp_vmpidr_aff1;
      cp_vmpidr_aff2 <= nxt_cp_vmpidr_aff2;
    end

  always @(posedge clk_cp15)
    if (cp_vmpidr_aff3_en)
      cp_vmpidr_aff3 <= nxt_cp_vmpidr_aff3;

  assign cp_vmpidr     = {1'b1, cp_vmpidr_u, {5{1'b0}}, cp_vmpidr_mt, cp_vmpidr_aff2, cp_vmpidr_aff1, cp_vmpidr_aff0};

  assign cp_vmpidr_el2 = {24'h00_0000, cp_vmpidr_aff3, 1'b1, cp_vmpidr_u, {5{1'b0}}, cp_vmpidr_mt, cp_vmpidr_aff2, cp_vmpidr_aff1, cp_vmpidr_aff0};

  // ------------------------------------------------------
  // Cache Size Selection Register (CSSELR & CSSELR_EL1)
  // ------------------------------------------------------

generate if (L2_CACHE) begin : L2_CACHE_PRESENT1

  // Secure CSSELR
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_cssr <= 2'b00;
    else if (wr_cp15_crn0_csselr_s)
      cp_cssr <= mcr_data_wr[1:0];

  assign cp_csselr = {{30{1'b0}}, cp_cssr};

  // Non-secure CSSELR
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_cssr_ns <= 2'b00;
    else if (wr_cp15_crn0_csselr_ns)
      cp_cssr_ns <= mcr_data_wr[1:0];

  assign cp_csselr_ns = {{30{1'b0}}, cp_cssr_ns};
end else begin : L2_CACHE_PRESENT1_STUBS

  // Secure CSSELR
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_cssr <= 1'b0;
    else if (wr_cp15_crn0_csselr_s)
      cp_cssr <= mcr_data_wr[0];

  assign cp_csselr = {{31{1'b0}}, cp_cssr};

  // Non-secure CSSELR
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_cssr_ns <= 1'b0;
    else if (wr_cp15_crn0_csselr_ns)
      cp_cssr_ns <= mcr_data_wr[0];

  assign cp_csselr_ns = {{31{1'b0}}, cp_cssr_ns};
end endgenerate

  // ------------------------------------------------------
  // Reset Management Register (RMR_EL3/RMR)
  // ------------------------------------------------------

  assign nxt_cp_rmr_el3_aa64 = load_initial_cold ? gov_aa64naa32_i : mcr_data_wr[0];
  assign cp_rmr_el3_aa64_en  = load_initial_cold | wr_cp15_crn12_rmr_el3;

  always @(posedge clk_cp15)
    if (cp_rmr_el3_aa64_en)
      cp_rmr_el3_aa64 <= nxt_cp_rmr_el3_aa64;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_rmr_el3_rr  <= 1'b0;
    else if (wr_cp15_crn12_rmr_el3)
      cp_rmr_el3_rr  <= mcr_data_wr[1];

  // This register forms the dpu_aarch64_at_el top level output, which
  // cannot be X because of x-propagation into other units. Therefore
  // the register is reset to zero, even though it is not valid until
  // after it has been loaded.
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      aarch64_at_el3 <= 1'b0;
    else if (last_load_initial)
      aarch64_at_el3 <= cp_rmr_el3_aa64;

  assign cp_rmr = {{30{1'b0}}, cp_rmr_el3_rr, cp_rmr_el3_aa64};

  // ------------------------------------------------------
  // EL3 System Control Register (SCTLR_EL3/SCTLR.S)
  // ------------------------------------------------------

  assign nxt_cp_sctlr_el3_te      = load_initial ? gov_cfgte_i   : mcr_data_wr[30];
  assign nxt_cp_sctlr_el3_afe     = load_initial ? 1'b0          : mcr_data_wr[29];
  assign nxt_cp_sctlr_el3_tre     = load_initial ? 1'b0          : mcr_data_wr[28];
  assign nxt_cp_sctlr_el3_ee      = load_initial ? gov_cfgend_i  : mcr_data_wr[25];
  assign nxt_cp_sctlr_el3_uwxn    = load_initial ? 1'b0          : mcr_data_wr[20];
  assign nxt_cp_sctlr_el3_wxn     = load_initial ? 1'b0          : mcr_data_wr[19];
  assign nxt_cp_sctlr_el3_ntwe    = load_initial ? 1'b1          : mcr_data_wr[18];
  assign nxt_cp_sctlr_el3_ntwi    = load_initial ? 1'b1          : mcr_data_wr[16];
  assign nxt_cp_sctlr_el3_v       = load_initial ? gov_vinithi_i : mcr_data_wr[13];
  assign nxt_cp_sctlr_el3_i       = load_initial ? 1'b0          : mcr_data_wr[12];
  assign nxt_cp_sctlr_el3_sed     = load_initial ? 1'b0          : mcr_data_wr[8];
  assign nxt_cp_sctlr_el3_itd     = load_initial ? 1'b0          : mcr_data_wr[7];
  assign nxt_cp_sctlr_el3_cp15ben = load_initial ? 1'b1          : mcr_data_wr[5];
  assign nxt_cp_sctlr_el3_sa      = load_initial ? 1'b1          : mcr_data_wr[3];
  assign nxt_cp_sctlr_el3_c       = load_initial ? 1'b0          : mcr_data_wr[2];
  assign nxt_cp_sctlr_el3_a       = load_initial ? 1'b0          : mcr_data_wr[1];
  assign nxt_cp_sctlr_el3_m       = load_initial ? 1'b0          : mcr_data_wr[0];

  assign cp_sctlr_el3_en = load_initial | wr_cp15_crn1_sctlr_s | wr_cp15_crn1_sctlr_el3;

  always @(posedge clk_cp15)
    if (cp_sctlr_el3_en) begin
      cp_sctlr_el3_te      <= nxt_cp_sctlr_el3_te;
      cp_sctlr_el3_afe     <= nxt_cp_sctlr_el3_afe;
      cp_sctlr_el3_tre     <= nxt_cp_sctlr_el3_tre;
      cp_sctlr_el3_ee      <= nxt_cp_sctlr_el3_ee;
      cp_sctlr_el3_uwxn    <= nxt_cp_sctlr_el3_uwxn;
      cp_sctlr_el3_wxn     <= nxt_cp_sctlr_el3_wxn;
      cp_sctlr_el3_ntwe    <= nxt_cp_sctlr_el3_ntwe;
      cp_sctlr_el3_ntwi    <= nxt_cp_sctlr_el3_ntwi;
      cp_sctlr_el3_v       <= nxt_cp_sctlr_el3_v;
      cp_sctlr_el3_i       <= nxt_cp_sctlr_el3_i;
      cp_sctlr_el3_sed     <= nxt_cp_sctlr_el3_sed;
      cp_sctlr_el3_itd     <= nxt_cp_sctlr_el3_itd;
      cp_sctlr_el3_cp15ben <= nxt_cp_sctlr_el3_cp15ben;
      cp_sctlr_el3_sa      <= nxt_cp_sctlr_el3_sa;
      cp_sctlr_el3_c       <= nxt_cp_sctlr_el3_c;
      cp_sctlr_el3_a       <= nxt_cp_sctlr_el3_a;
      cp_sctlr_el3_m       <= nxt_cp_sctlr_el3_m;
    end

  assign cp_sctlr_el3 = {1'b0,                 // 31    RES0
                         cp_sctlr_el3_te,      // 30    TE
                         cp_sctlr_el3_afe,     // 29    Access Flag
                         cp_sctlr_el3_tre,     // 28    TEX Remap
                         1'b0,                 // 27    RES0 (NMFI removed in ARMv8)
                         1'b0,                 // 26    UCI (RES0 at EL3)
                         cp_sctlr_el3_ee,      // 25    EE
                         1'b0,                 // 24    E0E (RES0 at EL3)
                         2'b11,                // 23:22 RES1
                         1'b0,                 // 21    RES0 (FI removed in ARMv8)
                         cp_sctlr_el3_uwxn,    // 20    UWXN
                         cp_sctlr_el3_wxn,     // 19    WXN
                         cp_sctlr_el3_ntwe,    // 18    NTWE
                         1'b0,                 // 17    RES0 (HA removed in ARMv8)
                         cp_sctlr_el3_ntwi,    // 16    NTWI
                         1'b0,                 // 15    UCT (RES0 at EL3)
                         1'b0,                 // 14    DZE (RES0 at EL3)
                         cp_sctlr_el3_v,       // 13    V
                         cp_sctlr_el3_i,       // 12    I
                         1'b1,                 // 11    RES1 (Z removed in ARMv8)
                         1'b0,                 // 10    RES0 (SW removed in ARMv8)
                         1'b0,                 //  9    UMA (RES0 at EL3)
                         cp_sctlr_el3_sed,     //  8    SED
                         cp_sctlr_el3_itd,     //  7    ITD
                         1'b0,                 //  6    THEE
                         cp_sctlr_el3_cp15ben, //  5    CP15BEN
                         1'b1,                 //  4    SA0 (RES1 at EL3)
                         cp_sctlr_el3_sa,      //  3    SA
                         cp_sctlr_el3_c,       //  2    C
                         cp_sctlr_el3_a,       //  1    A
                         cp_sctlr_el3_m};      //  0    M

  // ------------------------------------------------------
  // EL2 System Control Register (SCTLR_EL2/HSCTLR)
  // ------------------------------------------------------

  assign nxt_cp_sctlr_el2_te      = load_initial ? gov_cfgte_i   : mcr_data_wr[30];
  assign nxt_cp_sctlr_el2_ee      = load_initial ? gov_cfgend_i  : mcr_data_wr[25];
  assign nxt_cp_sctlr_el2_wxn     = load_initial ? 1'b0          : mcr_data_wr[19];
  assign nxt_cp_sctlr_el2_i       = load_initial ? 1'b0          : mcr_data_wr[12];
  assign nxt_cp_sctlr_el2_sed     = load_initial ? 1'b0          : mcr_data_wr[8];
  assign nxt_cp_sctlr_el2_itd     = load_initial ? 1'b0          : mcr_data_wr[7];
  assign nxt_cp_sctlr_el2_cp15ben = load_initial ? 1'b1          : mcr_data_wr[5];
  assign nxt_cp_sctlr_el2_sa      = load_initial ? 1'b1          : mcr_data_wr[3];
  assign nxt_cp_sctlr_el2_c       = load_initial ? 1'b0          : mcr_data_wr[2];
  assign nxt_cp_sctlr_el2_a       = load_initial ? 1'b0          : mcr_data_wr[1];
  assign nxt_cp_sctlr_el2_m       = load_initial ? 1'b0          : mcr_data_wr[0];

  assign cp_sctlr_el2_en = load_initial | wr_cp15_crn1_hsctlr | wr_cp15_crn1_sctlr_el2;

  always @(posedge clk_cp15)
    if (cp_sctlr_el2_en) begin
      cp_sctlr_el2_te      <= nxt_cp_sctlr_el2_te;
      cp_sctlr_el2_ee      <= nxt_cp_sctlr_el2_ee;
      cp_sctlr_el2_wxn     <= nxt_cp_sctlr_el2_wxn;
      cp_sctlr_el2_i       <= nxt_cp_sctlr_el2_i;
      cp_sctlr_el2_sed     <= nxt_cp_sctlr_el2_sed;
      cp_sctlr_el2_itd     <= nxt_cp_sctlr_el2_itd;
      cp_sctlr_el2_cp15ben <= nxt_cp_sctlr_el2_cp15ben;
      cp_sctlr_el2_sa      <= nxt_cp_sctlr_el2_sa;
      cp_sctlr_el2_c       <= nxt_cp_sctlr_el2_c;
      cp_sctlr_el2_a       <= nxt_cp_sctlr_el2_a;
      cp_sctlr_el2_m       <= nxt_cp_sctlr_el2_m;
    end

  assign cp_sctlr_el2 = {1'b0,                  // 31
                         cp_sctlr_el2_te,       // 30    TE
                         4'hc,                  // 29:26
                         cp_sctlr_el2_ee,       // 25    EE
                         5'h0c,                 // 24:20
                         cp_sctlr_el2_wxn,      // 19    WXN
                         4'ha,                  // 18:15
                         2'b00,                 // 14:13
                         cp_sctlr_el2_i,        // 12    I
                         3'b100,                // 11:9
                         cp_sctlr_el2_sed,      //  8    SED
                         cp_sctlr_el2_itd,      //  7    ITD
                         1'b0,                  //  6
                         cp_sctlr_el2_cp15ben,  //  5    CP15BEN
                         1'b1,                  //  4
                         cp_sctlr_el2_sa,       //  3    SA
                         cp_sctlr_el2_c,        //  2    C
                         cp_sctlr_el2_a,        //  1    A
                         cp_sctlr_el2_m};       //  0    MMU

  // ------------------------------------------------------
  // EL1 System Control Register (SCTLR_EL1/SCTLR.NS)
  // ------------------------------------------------------

  assign nxt_cp_sctlr_el1_te      = load_initial ? gov_cfgte_i   : mcr_data_wr[30];
  assign nxt_cp_sctlr_el1_afe     = load_initial ? 1'b0          : mcr_data_wr[29];
  assign nxt_cp_sctlr_el1_tre     = load_initial ? 1'b0          : mcr_data_wr[28];
  assign nxt_cp_sctlr_el1_uci     = load_initial ? 1'b0          : mcr_data_wr[26];
  assign nxt_cp_sctlr_el1_ee      = load_initial ? gov_cfgend_i  : mcr_data_wr[25];
  assign nxt_cp_sctlr_el1_e0e     = load_initial ? 1'b0          : mcr_data_wr[24];
  assign nxt_cp_sctlr_el1_uwxn    = load_initial ? 1'b0          : mcr_data_wr[20];
  assign nxt_cp_sctlr_el1_wxn     = load_initial ? 1'b0          : mcr_data_wr[19];
  assign nxt_cp_sctlr_el1_ntwe    = load_initial ? 1'b1          : mcr_data_wr[18];
  assign nxt_cp_sctlr_el1_ntwi    = load_initial ? 1'b1          : mcr_data_wr[16];
  assign nxt_cp_sctlr_el1_uct     = load_initial ? 1'b0          : mcr_data_wr[15];
  assign nxt_cp_sctlr_el1_dze     = load_initial ? 1'b0          : mcr_data_wr[14];
  assign nxt_cp_sctlr_el1_v       = load_initial ? gov_vinithi_i : mcr_data_wr[13];
  assign nxt_cp_sctlr_el1_i       = load_initial ? 1'b0          : mcr_data_wr[12];
  assign nxt_cp_sctlr_el1_uma     = load_initial ? 1'b0          : mcr_data_wr[9];
  assign nxt_cp_sctlr_el1_sed     = load_initial ? 1'b0          : mcr_data_wr[8];
  assign nxt_cp_sctlr_el1_itd     = load_initial ? 1'b0          : mcr_data_wr[7];
  assign nxt_cp_sctlr_el1_cp15ben = load_initial ? 1'b1          : mcr_data_wr[5];
  assign nxt_cp_sctlr_el1_sa0     = load_initial ? 1'b1          : mcr_data_wr[4];
  assign nxt_cp_sctlr_el1_sa      = load_initial ? 1'b1          : mcr_data_wr[3];
  assign nxt_cp_sctlr_el1_c       = load_initial ? 1'b0          : mcr_data_wr[2];
  assign nxt_cp_sctlr_el1_a       = load_initial ? 1'b0          : mcr_data_wr[1];
  assign nxt_cp_sctlr_el1_m       = load_initial ? 1'b0          : mcr_data_wr[0];

  assign cp_sctlr_el1_en = load_initial | wr_cp15_crn1_sctlr_ns | wr_cp15_crn1_sctlr_el1;

  always @(posedge clk_cp15)
    if (cp_sctlr_el1_en) begin
      cp_sctlr_el1_te      <= nxt_cp_sctlr_el1_te;
      cp_sctlr_el1_afe     <= nxt_cp_sctlr_el1_afe;
      cp_sctlr_el1_tre     <= nxt_cp_sctlr_el1_tre;
      cp_sctlr_el1_uci     <= nxt_cp_sctlr_el1_uci;
      cp_sctlr_el1_ee      <= nxt_cp_sctlr_el1_ee;
      cp_sctlr_el1_e0e     <= nxt_cp_sctlr_el1_e0e;
      cp_sctlr_el1_uwxn    <= nxt_cp_sctlr_el1_uwxn;
      cp_sctlr_el1_wxn     <= nxt_cp_sctlr_el1_wxn;
      cp_sctlr_el1_ntwe    <= nxt_cp_sctlr_el1_ntwe;
      cp_sctlr_el1_ntwi    <= nxt_cp_sctlr_el1_ntwi;
      cp_sctlr_el1_uct     <= nxt_cp_sctlr_el1_uct;
      cp_sctlr_el1_dze     <= nxt_cp_sctlr_el1_dze;
      cp_sctlr_el1_v       <= nxt_cp_sctlr_el1_v;
      cp_sctlr_el1_i       <= nxt_cp_sctlr_el1_i;
      cp_sctlr_el1_uma     <= nxt_cp_sctlr_el1_uma;
      cp_sctlr_el1_sed     <= nxt_cp_sctlr_el1_sed;
      cp_sctlr_el1_itd     <= nxt_cp_sctlr_el1_itd;
      cp_sctlr_el1_cp15ben <= nxt_cp_sctlr_el1_cp15ben;
      cp_sctlr_el1_sa0     <= nxt_cp_sctlr_el1_sa0;
      cp_sctlr_el1_sa      <= nxt_cp_sctlr_el1_sa;
      cp_sctlr_el1_c       <= nxt_cp_sctlr_el1_c;
      cp_sctlr_el1_a       <= nxt_cp_sctlr_el1_a;
      cp_sctlr_el1_m       <= nxt_cp_sctlr_el1_m;
    end

  assign cp_sctlr_el1 = {1'b0 ,                 // 31    RES0
                         cp_sctlr_el1_te,       // 30    TE
                         cp_sctlr_el1_afe,      // 29    Access Flag
                         cp_sctlr_el1_tre,      // 28    TEX Remap
                         1'b0,                  // 27    RES0 (NMFI removed in ARMv8)
                         cp_sctlr_el1_uci,      // 26    UCI
                         cp_sctlr_el1_ee,       // 25    EE
                         cp_sctlr_el1_e0e,      // 24    E0E
                         2'b11,                 // 23:22 RES1
                         1'b0,                  // 21    RES0 (FI removed in ARMv8)
                         cp_sctlr_el1_uwxn,     // 20    UWXN
                         cp_sctlr_el1_wxn,      // 19    WXN
                         cp_sctlr_el1_ntwe,     // 18    nTWE
                         1'b0,                  // 17    RES0 (HA removed in ARMv8)
                         cp_sctlr_el1_ntwi,     // 16    NTWI
                         cp_sctlr_el1_uct,      // 15    UCT
                         cp_sctlr_el1_dze,      // 14    DZE
                         cp_sctlr_el1_v,        // 13    V
                         cp_sctlr_el1_i,        // 12    I
                         1'b1,                  // 11    RES1 (Z removed in ARMv8)
                         1'b0,                  // 10    RES0 (SW removed in ARMv8)
                         cp_sctlr_el1_uma,      //  9    UMA
                         cp_sctlr_el1_sed,      //  8    SED
                         cp_sctlr_el1_itd,      //  7    ITD
                         1'b0,                  //  6    THEE
                         cp_sctlr_el1_cp15ben,  //  5    CP15BEN
                         cp_sctlr_el1_sa0,      //  4    SA0
                         cp_sctlr_el1_sa,       //  3    SA
                         cp_sctlr_el1_c,        //  2    C
                         cp_sctlr_el1_a,        //  1    A
                         cp_sctlr_el1_m};       //  0    MMU

  // ------------------------------------------------------
  // CPU Auxiliary Control Register (CPUACTLR / CPUACTLR_EL1)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      force_clean_to_invalidate                 <= 1'b0;
      disable_fp_dual_issue                     <= 1'b0;
      disable_dual_issue                        <= 1'b0;
      dpu_ramode_cnt_l2                         <= 2'b01;
      dpu_ramode_cnt_l1                         <= 2'b00;
      dpu_disable_no_allocate                   <= 1'b1;
      dpu_disable_data_prefetch_readunique      <= 1'b0;
      dpu_disable_data_prefetch_stores_pattern  <= 1'b0;
      dpu_throttle_disable                      <= 1'b0;
      dpu_enable_data_prefetch_streams          <= 2'b01;
      dpu_disable_device_split_throttle         <= 1'b1;
      dpu_data_prefetch_stride_detect           <= 1'b0;
      dpu_enable_data_prefetch                  <= 3'b101;
      dpu_disable_dmb                           <= 1'b0;
    end else if (wr_cp15_crn1_cpuactlr) begin
      force_clean_to_invalidate                 <= mcr_data_wr[44];
      disable_fp_dual_issue                     <= mcr_data_wr[30];
      disable_dual_issue                        <= mcr_data_wr[29];
      dpu_ramode_cnt_l2                         <= mcr_data_wr[28:27];
      dpu_ramode_cnt_l1                         <= mcr_data_wr[26:25];
      dpu_disable_no_allocate                   <= mcr_data_wr[24];
      dpu_disable_data_prefetch_readunique      <= mcr_data_wr[23];
      dpu_disable_data_prefetch_stores_pattern  <= mcr_data_wr[22];
      dpu_throttle_disable                      <= mcr_data_wr[21];
      dpu_enable_data_prefetch_streams          <= mcr_data_wr[20:19];
      dpu_disable_device_split_throttle         <= mcr_data_wr[18];
      dpu_data_prefetch_stride_detect           <= mcr_data_wr[17];
      dpu_enable_data_prefetch                  <= mcr_data_wr[15:13];
      dpu_disable_dmb                           <= mcr_data_wr[10];
    end

  // The L1DEIEN field is implemented for the CPU_CACHE_PROTECTION
  // configurations, only.

generate if (CPU_CACHE_PROTECTION) begin : CPU_ERR_INJECT_CONFIG
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      dpu_l1deien <= 1'b0;
    end else if (wr_cp15_crn1_cpuactlr) begin
      dpu_l1deien <= mcr_data_wr[6];
    end
end else begin : NO_CPU_ERR_INJECT_CONFIG
  wire zero;

  // Tie off used for configurable logic.
  assign zero = 1'b0;

  always @*
    begin
      dpu_l1deien = zero;
    end
end endgenerate

  assign cp_cpuactlr = { {19{1'b0}},                              // 63:45
                        force_clean_to_invalidate,                // 44     DCCFI
                        {13{1'b0}},                               // 43:31
                        disable_fp_dual_issue,                    // 30     DFPDIS
                        disable_dual_issue,                       // 29     DIDIS
                        dpu_ramode_cnt_l2,                        // 28:27
                        dpu_ramode_cnt_l1,                        // 26:25
                        dpu_disable_no_allocate,                  // 24
                        dpu_disable_data_prefetch_readunique,     // 23
                        dpu_disable_data_prefetch_stores_pattern, // 22
                        dpu_throttle_disable,                     // 21
                        dpu_enable_data_prefetch_streams,         // 20:19
                        dpu_disable_device_split_throttle,        // 18
                        dpu_data_prefetch_stride_detect,          // 17
                        1'b0,                                     // 16
                        dpu_enable_data_prefetch,                 // 15:13  L1PCTL
                        2'b00,                                    // 12:11
                        dpu_disable_dmb,                          // 10     DODMBS
                        3'b000,                                   //  9: 7  RES0
                        dpu_l1deien,                              //  6     L1DEIEN
                        6'h00};                                   //  5: 0  RES0

  // ------------------------------------------------------
  // CPU Extended Control Register (CPUECTLR / CPUECTLR_EL1)
  // ------------------------------------------------------
  // SMP enable bit which must be accessible both by the secure side and also the
  // non-secure side by an NSACR over ride.  This allows the processor to be moved
  // from SMP to AMP for power down by software that does not have access to the
  // secure side.

generate if (NEON_FP) begin : ECTLR
  reg [2:0] simd_ret;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      simd_ret      <= 3'b000;
    end else if (wr_cp15_crn1_cpuectlr) begin
      simd_ret      <= mcr_data_wr[5:3];
    end

  assign dpu_simd_ret = simd_ret;
end else begin : ECTLR_STUBS
  assign dpu_simd_ret = 3'b000;
end endgenerate

always @(posedge clk_cp15 or negedge reset_n)
  if (~reset_n) begin
    dpu_smp_en    <= 1'b0;
    cpu_ret       <= 3'b000;
  end else if (wr_cp15_crn1_cpuectlr) begin
    dpu_smp_en    <= mcr_data_wr[6];
    cpu_ret       <= mcr_data_wr[2:0];
  end

  assign cp_cpuectlr = {25'h0000000,    // 31:7
                        dpu_smp_en,     //  6     SMPEN
                        dpu_simd_ret,   //  5: 3  SIMD_RET
                        cpu_ret};       //  2: 0  CPU_RET

  // ------------------------------------------------------
  // CP15 Aux Control Register EL3 (ACTLR Secure / ACTLR_EL3)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      l2actlr_el3   <= 1'b0;
      l2ectlr_el3   <= 1'b0;
      l2ctlr_el3    <= 1'b0;
      cpuectlr_el3  <= 1'b0;
      cpuactlr_el3  <= 1'b0;
    end else if (wr_cp15_crn1_actlr_el3) begin
      l2actlr_el3   <= mcr_data_wr[6];
      l2ectlr_el3   <= mcr_data_wr[5];
      l2ctlr_el3    <= mcr_data_wr[4];
      cpuectlr_el3  <= mcr_data_wr[1];
      cpuactlr_el3  <= mcr_data_wr[0];
    end

  assign cp_actlr_el3 = {25'h000_0000,   // 31:7 Res0
                         l2actlr_el3,    //  6   L2ACTLR
                         l2ectlr_el3,    //  5   L2ECTLR
                         l2ctlr_el3,     //  4   L2CTLR
                         2'b00,          //  3:2 Res0
                         cpuectlr_el3,   //  1   CPUECTLR
                         cpuactlr_el3};  //  0   CPUACTLR

  // ------------------------------------------------------
  // CP15 Aux Control Register EL2 (HACTLR / ACTLR_EL2)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      l2actlr_el2   <= 1'b0;
      l2ectlr_el2   <= 1'b0;
      l2ctlr_el2    <= 1'b0;
      cpuectlr_el2  <= 1'b0;
      cpuactlr_el2  <= 1'b0;
    end else if (wr_cp15_crn1_actlr_el2) begin
      l2actlr_el2   <= mcr_data_wr[6];
      l2ectlr_el2   <= mcr_data_wr[5];
      l2ctlr_el2    <= mcr_data_wr[4];
      cpuectlr_el2  <= mcr_data_wr[1];
      cpuactlr_el2  <= mcr_data_wr[0];
    end

  assign cp_actlr_el2 = {25'h000_0000,   // 31:7 Res0
                         l2actlr_el2,    //  6   L2ACTLR
                         l2ectlr_el2,    //  5   L2ECTLR
                         l2ctlr_el2,     //  4   L2CTLR
                         2'b00,          //  3:2 Res0
                         cpuectlr_el2,   //  1   CPUECTLR
                         cpuactlr_el2};  //  0   CPUACTLR

  // ------------------------------------------------------
  // Coprocessor Access Control Register (CPACR & CPACR_EL1)
  // ------------------------------------------------------

generate if (NEON_FP) begin : FPU2
  reg [1:0] cpacr_el1_fpen_internal;
  reg [1:0] cpacr_cp11;
  reg       cpacr_asedis_internal;
  wire      cpacr_cp11_en;
  wire      cpacr_asedis_en;

  // If access is set for either CP10 or CP11, then force access for both.
  // It is unpredictable to set them to different values. If the reserved value
  // of 2'b10 is written then force to no access.

  // If access for CP10 and CP11 are different, or set to the value 2'b10,
  // this is UNPREDICTABLE (In AArch64 the value 2'b10 is equivalent to 2'b00)
  // Handle this by using the CP10 value (The CP11 value can be read and written,
  // but does not affect anything) and treating 2'b10 as 2'b00
  assign cpacr_cp11_en = wr_cp15_crn1_cpacr & ~nsfpudis;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cpacr_cp11              <= 2'b00;
      cpacr_el1_fpen_internal <= 2'b00;
    end else if (cpacr_cp11_en) begin
      cpacr_cp11              <= mcr_data_wr[23:22];
      cpacr_el1_fpen_internal <= mcr_data_wr[21:20];
    end

  // The ASE (Neon) disable bit
  assign cpacr_asedis_en = wr_cp15_crn1_cpacr & ~nsasedis;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cpacr_asedis_internal <= 1'b0;
    else if (cpacr_asedis_en)
      cpacr_asedis_internal <= mcr_data_wr[31];

  assign cpacr_el1_fpen_rd = cpacr_el1_fpen_internal & {2{~nsfpudis}};
  assign cpacr_cp11_rd     = cpacr_cp11              & {2{~nsfpudis}};
  assign cpacr_asedis_rd   = cpacr_asedis_internal   |     nsasedis;
  assign cpacr_asedis      = cpacr_asedis_internal;
end else begin : FPU2_STUBS
  assign cpacr_el1_fpen_rd = 2'b00;
  assign cpacr_cp11_rd     = 2'b00;
  assign cpacr_asedis_rd   = 1'b0;
  assign cpacr_asedis      = 1'b0;
end endgenerate

  assign cp_cpacr = {cpacr_asedis_rd,   // [31]    ASEDis
                     1'b0,              // [30]    D32Dis
                     1'b0,              // [29]    RAZ
                     1'b0,              // [28]    TTA - RES0
                     {4{1'b0}},         // [27:24] RAZ
                     cpacr_cp11_rd,     // [23:22] CP11
                     cpacr_el1_fpen_rd, // [21:20] CP10
                     {20{1'b0}}};       // [19:0]  RAZ

  // ------------------------------------------------------
  // Secure Configuration Register (SCR & SCR_EL3)
  // ------------------------------------------------------

  // If the processor is in monitor mode then the NS bit is cleared
  // if an exception is taken.
  assign nxt_cp_scr_twe = expt_mon_mode_clear_ns_i ? cp_scr_twe : mcr_data_wr[13];
  assign nxt_cp_scr_twi = expt_mon_mode_clear_ns_i ? cp_scr_twi : mcr_data_wr[12];
  assign nxt_cp_scr_st  = expt_mon_mode_clear_ns_i ? cp_scr_st  : mcr_data_wr[11];
  assign nxt_cp_scr_rw  = expt_mon_mode_clear_ns_i ? cp_scr_rw  : mcr_data_wr[10];
  assign nxt_cp_scr_sif = expt_mon_mode_clear_ns_i ? cp_scr_sif : mcr_data_wr[9];
  assign nxt_cp_scr_hce = expt_mon_mode_clear_ns_i ? cp_scr_hce : mcr_data_wr[8];
  assign nxt_cp_scr_smd = expt_mon_mode_clear_ns_i ? cp_scr_smd : mcr_data_wr[7];
  assign nxt_cp_scr_aw  = expt_mon_mode_clear_ns_i ? cp_scr_aw  : mcr_data_wr[5];
  assign nxt_cp_scr_fw  = expt_mon_mode_clear_ns_i ? cp_scr_fw  : mcr_data_wr[4];
  assign nxt_cp_scr_ea  = expt_mon_mode_clear_ns_i ? cp_scr_ea  : mcr_data_wr[3];
  assign nxt_cp_scr_fiq = expt_mon_mode_clear_ns_i ? cp_scr_fiq : mcr_data_wr[2];
  assign nxt_cp_scr_irq = expt_mon_mode_clear_ns_i ? cp_scr_irq : mcr_data_wr[1];

  // Writes to the SCR.NS bit from Secure privileged modes other than monitor
  // are ignored if HCR.TGE = 1
  //
  // As the nxt_cp_scr_ns signal is used in the CPSR and Exception logic (and not
  // just written to the register block below), have the cp_scr_ns as a default term.
  assign nxt_cp_scr_ns  = expt_mon_mode_clear_ns_i ? 1'b0 :
                          wr_cp15_crn1_scr         ? (mcr_data_wr[0] & ~(~aarch64_at_el3 & cp_hcr_tge & ~spec_cpsr_mode_mon_iss_i)) :
                                                     cp_scr_ns;

  assign cp_scr_en = wr_cp15_crn1_scr | expt_mon_mode_clear_ns_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      cp_scr_twe <= 1'b0;
      cp_scr_twi <= 1'b0;
      cp_scr_st  <= 1'b0;
      cp_scr_rw  <= 1'b0;
      cp_scr_sif <= 1'b0;
      cp_scr_hce <= 1'b0;
      cp_scr_smd <= 1'b0;
      cp_scr_aw  <= 1'b0;
      cp_scr_fw  <= 1'b0;
      cp_scr_ea  <= 1'b0;
      cp_scr_fiq <= 1'b0;
      cp_scr_irq <= 1'b0;
      cp_scr_ns  <= 1'b0;
    end else if (cp_scr_en) begin
      cp_scr_twe <= nxt_cp_scr_twe;
      cp_scr_twi <= nxt_cp_scr_twi;
      cp_scr_st  <= nxt_cp_scr_st;
      cp_scr_rw  <= nxt_cp_scr_rw;
      cp_scr_sif <= nxt_cp_scr_sif;
      cp_scr_hce <= nxt_cp_scr_hce;
      cp_scr_smd <= nxt_cp_scr_smd;
      cp_scr_aw  <= nxt_cp_scr_aw;
      cp_scr_fw  <= nxt_cp_scr_fw;
      cp_scr_ea  <= nxt_cp_scr_ea;
      cp_scr_fiq <= nxt_cp_scr_fiq;
      cp_scr_irq <= nxt_cp_scr_irq;
      cp_scr_ns  <= nxt_cp_scr_ns;
    end

  assign cp_scr = {{18{1'b0}},    // [31:14] RAZ
                   cp_scr_twe,    // [13]    TWE
                   cp_scr_twi,    // [12]    TWI
                   cp_scr_st,     // [11]    ST
                   cp_scr_rw,     // [10]    RW
                   cp_scr_sif,    // [9]     SIF
                   cp_scr_hce,    // [8]     HCE
                   cp_scr_smd,    // [7]     SCD (AA32)/SMD (AA64)
                   1'b0,          // [6]     RAZ
                   cp_scr_aw,     // [5]     AW
                   cp_scr_fw,     // [4]     FW
                   cp_scr_ea,     // [3]     EA
                   cp_scr_fiq,    // [2]     FIQ
                   cp_scr_irq,    // [1]     IRQ
                   cp_scr_ns};    // [0]     NS

  // EL2 is at AArch64 if EL3 is AArch64 and SCR_EL3.RW is set
  assign aarch64_at_el2 = aarch64_at_el3 & cp_scr_rw;

  // ------------------------------------------------------
  // Hyp Configuration Register (HCR, HCR2 & HCR_EL2)
  // ------------------------------------------------------

  assign nxt_cp_hcr_va  = (wr_cp15_crn1_hcr | wr_cp15_crn1_hcr_el2) & mcr_data_wr[8];
  assign nxt_cp_hcr_id  = wr_cp15_crn1_hcr_el2 ? mcr_data_wr[33] : mcr_data_wr[1];
  assign nxt_cp_hcr_cd  = wr_cp15_crn1_hcr_el2 ? mcr_data_wr[32] : mcr_data_wr[0];

  assign cp_hcr_en    = wr_cp15_crn1_hcr_el2 | wr_cp15_crn1_hcr;
  assign cp_hcr_va_en = wr_cp15_crn1_hcr_el2 | wr_cp15_crn1_hcr | clear_virtual_ea_i;
  assign cp_hcr2_en   = wr_cp15_crn1_hcr_el2 | wr_cp15_crn1_hcr2;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      cp_hcr_va <= 1'b0;
    else if (cp_hcr_va_en)
      cp_hcr_va <= nxt_cp_hcr_va;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cp_hcr_rw    <= 1'b0;
      cp_hcr_trvm  <= 1'b0;
      cp_hcr_tdz   <= 1'b0;
      cp_hcr_tge   <= 1'b0;
      cp_hcr_tvm   <= 1'b0;
      cp_hcr_ttlb  <= 1'b0;
      cp_hcr_tpu   <= 1'b0;
      cp_hcr_tpc   <= 1'b0;
      cp_hcr_tsw   <= 1'b0;
      cp_hcr_tacr  <= 1'b0;
      cp_hcr_tidcp <= 1'b0;
      cp_hcr_tsc   <= 1'b0;
      cp_hcr_tid3  <= 1'b0;
      cp_hcr_tid2  <= 1'b0;
      cp_hcr_tid1  <= 1'b0;
      cp_hcr_tid0  <= 1'b0;
      cp_hcr_twe   <= 1'b0;
      cp_hcr_twi   <= 1'b0;
      cp_hcr_dc    <= 1'b0;
      cp_hcr_bsu   <= 2'b00;
      cp_hcr_fb    <= 1'b0;
      cp_hcr_vi    <= 1'b0;
      cp_hcr_vf    <= 1'b0;
      cp_hcr_amo   <= 1'b0;
      cp_hcr_imo   <= 1'b0;
      cp_hcr_fmo   <= 1'b0;
      cp_hcr_ptw   <= 1'b0;
      cp_hcr_vm    <= 1'b0;
    end else if (cp_hcr_en) begin
      cp_hcr_rw    <= mcr_data_wr[31];
      cp_hcr_trvm  <= mcr_data_wr[30];
      cp_hcr_tdz   <= mcr_data_wr[28];
      cp_hcr_tge   <= mcr_data_wr[27];
      cp_hcr_tvm   <= mcr_data_wr[26];
      cp_hcr_ttlb  <= mcr_data_wr[25];
      cp_hcr_tpu   <= mcr_data_wr[24];
      cp_hcr_tpc   <= mcr_data_wr[23];
      cp_hcr_tsw   <= mcr_data_wr[22];
      cp_hcr_tacr  <= mcr_data_wr[21];
      cp_hcr_tidcp <= mcr_data_wr[20];
      cp_hcr_tsc   <= mcr_data_wr[19];
      cp_hcr_tid3  <= mcr_data_wr[18];
      cp_hcr_tid2  <= mcr_data_wr[17];
      cp_hcr_tid1  <= mcr_data_wr[16];
      cp_hcr_tid0  <= mcr_data_wr[15];
      cp_hcr_twe   <= mcr_data_wr[14];
      cp_hcr_twi   <= mcr_data_wr[13];
      cp_hcr_dc    <= mcr_data_wr[12];
      cp_hcr_bsu   <= mcr_data_wr[11:10];
      cp_hcr_fb    <= mcr_data_wr[9];
      cp_hcr_vi    <= mcr_data_wr[7];
      cp_hcr_vf    <= mcr_data_wr[6];
      cp_hcr_amo   <= mcr_data_wr[5];
      cp_hcr_imo   <= mcr_data_wr[4];
      cp_hcr_fmo   <= mcr_data_wr[3];
      cp_hcr_ptw   <= mcr_data_wr[2];
      cp_hcr_vm    <= mcr_data_wr[0];
    end

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cp_hcr_id    <= 1'b0;
      cp_hcr_cd    <= 1'b0;
    end else if (cp_hcr2_en) begin
      cp_hcr_id    <=  nxt_cp_hcr_id;
      cp_hcr_cd    <=  nxt_cp_hcr_cd;
    end

  assign cp_hcr2 = {{30{1'b0}},
                    cp_hcr_id,      // 1    ID
                    cp_hcr_cd};     // 0    CD

  assign cp_hcr =  {cp_hcr_rw,      // 31    RW
                    cp_hcr_trvm,    // 30    TRVM
                    1'b0,           // 29    HCD - RES0 if EL3 implemented
                    cp_hcr_tdz,     // 28    TDZ
                    cp_hcr_tge,     // 27    TGE
                    cp_hcr_tvm,     // 26    TVM
                    cp_hcr_ttlb,    // 25    TTLB
                    cp_hcr_tpu,     // 24    TPU
                    cp_hcr_tpc,     // 23    TPC
                    cp_hcr_tsw,     // 22    TSW
                    cp_hcr_tacr,    // 21    TACR
                    cp_hcr_tidcp,   // 20    TIDCP
                    cp_hcr_tsc,     // 19    TSC
                    cp_hcr_tid3,    // 18    TID3
                    cp_hcr_tid2,    // 17    TID2
                    cp_hcr_tid1,    // 16    TID1
                    cp_hcr_tid0,    // 15    TID0
                    cp_hcr_twe,     // 14    TWE
                    cp_hcr_twi,     // 13    TWI
                    cp_hcr_dc,      // 12    DC
                    cp_hcr_bsu,     // 11:10 BSU
                    cp_hcr_fb,      // 9     FB
                    cp_hcr_va,      // 8     VA
                    cp_hcr_vi,      // 7     VI
                    cp_hcr_vf,      // 6     VF
                    cp_hcr_amo,     // 5     AMO
                    cp_hcr_imo,     // 4     IMO
                    cp_hcr_fmo,     // 3     FMO
                    cp_hcr_ptw,     // 2     PTW
                    1'b1,           // 1     SWIO - RES1 as has no effect
                    cp_hcr_vm};     // 0     VM

  assign cp_hcr_el2 = {{30{1'b0}},
                       cp_hcr_id,      // 33    ID
                       cp_hcr_cd,      // 32    CD
                       cp_hcr_rw,      // 31    RW
                       cp_hcr_trvm,    // 30    TRVM
                       1'b0,           // 29    HCD - RES0 if EL3 implemented
                       cp_hcr_tdz,     // 28    TDZ
                       cp_hcr_tge,     // 27    TGE
                       cp_hcr_tvm,     // 26    TVM
                       cp_hcr_ttlb,    // 25    TTLB
                       cp_hcr_tpu,     // 24    TPU
                       cp_hcr_tpc,     // 23    TPC
                       cp_hcr_tsw,     // 22    TSW
                       cp_hcr_tacr,    // 21    TACR
                       cp_hcr_tidcp,   // 20    TIDCP
                       cp_hcr_tsc,     // 19    TSC
                       cp_hcr_tid3,    // 18    TID3
                       cp_hcr_tid2,    // 17    TID2
                       cp_hcr_tid1,    // 16    TID1
                       cp_hcr_tid0,    // 15    TID0
                       cp_hcr_twe,     // 14    TWE
                       cp_hcr_twi,     // 13    TWI
                       cp_hcr_dc,      // 12    DC
                       cp_hcr_bsu,     // 11:10 BSU
                       cp_hcr_fb,      // 9     FB
                       cp_hcr_va,      // 8     VA
                       cp_hcr_vi,      // 7     VI
                       cp_hcr_vf,      // 6     VF
                       cp_hcr_amo,     // 5     AMO
                       cp_hcr_imo,     // 4     IMO
                       cp_hcr_fmo,     // 3     FMO
                       cp_hcr_ptw,     // 2     PTW
                       1'b1,           // 1     SWIO - RES1 as has no effect
                       cp_hcr_vm};     // 0     VM

  // EL1 is at AArch64 if EL2 is AArch64 and HCR_EL2.RW is set and SCR_EL3.NS is set
  // or if EL3 is AArch64 and SCR_EL3.RW is set and SCR_EL3.NS is not set

  assign aarch64_at_el1 = cp_scr_ns ? (aarch64_at_el2 & cp_hcr_rw)
                                    : (aarch64_at_el3 & cp_scr_rw);

  // ------------------------------------------------------
  // Monitor Debug Configuration Register (HDCR & MDCR_EL2)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cp_hdcr_tdra  <= 1'b0;
      cp_hdcr_tdosa <= 1'b0;
      cp_hdcr_tda   <= 1'b0;
      cp_hdcr_tde   <= 1'b0;
      cp_hdcr_hpme  <= 1'b0;
      cp_hdcr_tpm   <= 1'b0;
      cp_hdcr_tpmcr <= 1'b0;
      cp_hdcr_hpmn  <= PMN_NUMBER[4:0];
    end else if (wr_cp15_crn1_hdcr) begin
      cp_hdcr_tdra  <= mcr_data_wr[11];
      cp_hdcr_tdosa <= mcr_data_wr[10];
      cp_hdcr_tda   <= mcr_data_wr[9];
      cp_hdcr_tde   <= mcr_data_wr[8];
      cp_hdcr_hpme  <= mcr_data_wr[7];
      cp_hdcr_tpm   <= mcr_data_wr[6];
      cp_hdcr_tpmcr <= mcr_data_wr[5];
      cp_hdcr_hpmn  <= mcr_data_wr[4:0];
    end

  assign cp_hdcr = {{20{1'b0}},
                    cp_hdcr_tdra,      // 11    TDRA
                    cp_hdcr_tdosa,     // 10    TDOSA
                    cp_hdcr_tda,       //  9    TDA
                    cp_hdcr_tde,       //  8    TDE
                    cp_hdcr_hpme,      //  7    HPME
                    cp_hdcr_tpm,       //  6    TPM
                    cp_hdcr_tpmcr,     //  5    TPMCR
                    cp_hdcr_hpmn};     //  4:0  HPMN

  // ------------------------------------------------------
  // Monitor Debug Configuration Register (MDCR_EL3)
  // Secure Debug Configuration Register  (SDCR)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cp_mdcr_el3_epmad <= 1'b0;
      cp_mdcr_el3_edad  <= 1'b0;
      cp_mdcr_el3_spme  <= 1'b0;
      cp_mdcr_el3_sdd   <= 1'b0;
      cp_mdcr_el3_spd32 <= 2'b00;
      cp_mdcr_el3_tdosa <= 1'b0;
      cp_mdcr_el3_tda   <= 1'b0;
      cp_mdcr_el3_tpm   <= 1'b0;
    end else if (wr_cp15_crn1_mdcr_el3) begin
      cp_mdcr_el3_epmad <= mcr_data_wr[21];
      cp_mdcr_el3_edad  <= mcr_data_wr[20];
      cp_mdcr_el3_spme  <= mcr_data_wr[17];
      cp_mdcr_el3_sdd   <= mcr_data_wr[16];
      cp_mdcr_el3_spd32 <= mcr_data_wr[15:14];
      cp_mdcr_el3_tdosa <= mcr_data_wr[10];
      cp_mdcr_el3_tda   <= mcr_data_wr[9];
      cp_mdcr_el3_tpm   <= mcr_data_wr[6];
    end

  assign cp_mdcr_el3 = {{10{1'b0}},
                        cp_mdcr_el3_epmad, // 21    EPMAD
                        cp_mdcr_el3_edad,  // 20    EDAD
                        2'b00,             // 19:18 RES0
                        cp_mdcr_el3_spme,  // 17    SPME
                        cp_mdcr_el3_sdd,   // 16    SDD
                        cp_mdcr_el3_spd32, // 15:14 SPD32
                        3'b000,            // 13:11 RES0
                        cp_mdcr_el3_tdosa, // 10    TDOSA
                        cp_mdcr_el3_tda,   //  9    TDA
                        2'b00,             //  8:7  RES0
                        cp_mdcr_el3_tpm,   //  6    TPM
                        6'b000000};        //  5:0  RES0

  // ------------------------------------------------------
  // Hyp Coprocessor Trap Register (HCPTR & CPTR_EL2)
  // ------------------------------------------------------

generate if (NEON_FP) begin : FPU3
  reg  cptr_el2_tfp_internal;
  reg  hcptr_tcp11_internal;
  reg  hcptr_tase_internal;
  wire hcptr_tcp11_en;
  wire hcptr_tase_en;

  // It is UNPREDICTABLE for TCP10 and TCP11 to have different values here
  // Always use TCP10 if they are different
  assign hcptr_tcp11_en = wr_cp15_crn1_hcptr & ~nsfpudis;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      hcptr_tcp11_internal  <= 1'b0;
      cptr_el2_tfp_internal <= 1'b0;
    end else if (hcptr_tcp11_en) begin
      hcptr_tcp11_internal  <= mcr_data_wr[11];
      cptr_el2_tfp_internal <= mcr_data_wr[10];
    end

  assign hcptr_tcp11     = hcptr_tcp11_internal  | nsfpudis;

  assign cptr_el2_tfp_rd = cptr_el2_tfp_internal | nsfpudis;
  assign cptr_el2_tfp    = cptr_el2_tfp_internal;

  // Trap Advanced SIMD Extension usage bit
  assign hcptr_tase_en = wr_cp15_crn1_hcptr & ~nsasedis;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      hcptr_tase_internal <= 1'b0;
    else if (hcptr_tase_en)
      hcptr_tase_internal <= mcr_data_wr[15];

  assign hcptr_tase_rd = hcptr_tase_internal | nsasedis;
  assign hcptr_tase    = hcptr_tase_internal;
end else begin : FPU3_STUBS
  assign cptr_el2_tfp    = 1'b1;
  assign cptr_el2_tfp_rd = 1'b1;
  assign hcptr_tcp11     = 1'b1;
  assign hcptr_tase_rd   = 1'b1;
  assign hcptr_tase      = 1'b1;
end endgenerate

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cptr_el2_tcpac <= 1'b0;
    else if (wr_cp15_crn1_hcptr)
      cptr_el2_tcpac <= mcr_data_wr[31];

  assign cp_hcptr = {cptr_el2_tcpac,  // 31      TCPAC
                     {10{1'b0}},      // 30:21
                     1'b0,            // 20      TTA - RES0
                     {4{1'b0}},       // 19:16
                     hcptr_tase_rd,   // 15      TASE
                     1'b0,            // 14      RES0
                     {2{1'b1}},       // 13:12   RES1
                     hcptr_tcp11,     // 11
                     cptr_el2_tfp_rd, // 10      TTP
                     {10{1'b1}}};     //  9: 0   RES1

  // ------------------------------------------------------
  // EL3 Coprocessor Trap Register (CPTR_EL3)
  // ------------------------------------------------------

generate if (NEON_FP) begin : FPU6
  reg cptr_el3_tfp_internal;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cptr_el3_tfp_internal <= 1'b0;
    else if (wr_cp15_crn1_cptr_el3)
      cptr_el3_tfp_internal <= mcr_data_wr[10];

  assign cptr_el3_tfp = cptr_el3_tfp_internal;

end else begin : FPU6STUBS
  assign cptr_el3_tfp = 1'b1;
end endgenerate

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cptr_el3_tcpac <= 1'b0;
    else if (wr_cp15_crn1_cptr_el3)
      cptr_el3_tcpac <= mcr_data_wr[31];

  assign cptr_el3 = {cptr_el3_tcpac,      // 31    TCPAC
                     {10{1'b0}},          // 30:21 RES0
                     1'b0,                // 20    TTA - RES0
                     {4{1'b0}},           // 19:16 RES0
                     {5{1'b0}},           // 15:11 RES0
                     cptr_el3_tfp,        // 10    TFP
                     {10{1'b0}}};         //  9: 0 RES0

  // ------------------------------------------------------
  // Hyp System Trap Register (HSTR)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_hstr <= {14{1'b0}};
    else if (wr_cp15_crn1_hstr)
      cp_hstr <= {mcr_data_wr[15], mcr_data_wr[13:5], mcr_data_wr[3:0]};

  assign cp_hstr_rd = {{14{1'b0}},
                       1'b0,          // 17   TJDBX
                       1'b0,          // 16   TTEE
                       cp_hstr[13],   // 15   T15
                       1'b0,          // 14   SBZP
                       cp_hstr[12:4], // 13:5 T13-T15
                       1'b0,          // 4    SBZP
                       cp_hstr[3:0]}; // 3:0  T3-T0

  // ------------------------------------------------------
  // Hypervisor/EL2 Exception Syndrome Register (HSR & ESR_EL2)
  // ------------------------------------------------------

  assign nxt_cp_esr_el2 = expt_fault_reg_sel_wr_i ? expt_esr_data_wr_i : mcr_data_wr[31:0];

  always @(posedge clk)
    if (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL2] | expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HSR] | wr_cp15_crn5_esr_el2)
      cp_esr_el2 <= nxt_cp_esr_el2;

  // ------------------------------------------------------
  // Hyp IPA Fault Address Register (HPFAR & HPFAR_EL2)
  // ------------------------------------------------------

  assign nxt_cp_hpfar = expt_fault_reg_sel_wr_i ? expt_hpfar_data_wr_i : mcr_data_wr[31:4];

  always @(posedge clk)
    if (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HPFAR] | wr_cp15_crn6_hpfar)
      cp_hpfar <= nxt_cp_hpfar;

  assign cp_hpfar_rd  = { cp_hpfar[31:4], {4{1'b0}} };

  // ------------------------------------------------------
  // Hyp Vector Base Address Register (HVBAR & VBAR_EL2)
  // ------------------------------------------------------

  assign cp_hvbar_en_lo = wr_cp15_crn12_hvbar | wr_cp15_crn12_vbar_el2;

  always @(posedge clk_cp15)
    if (cp_hvbar_en_lo)
      cp_hvbar[31:5] <= mcr_data_wr[31:5];

  always @(posedge clk_cp15)
    if (wr_cp15_crn12_vbar_el2)
      cp_hvbar[63:32] <= mcr_data_wr[63:32];

  assign cp_hvbar_rd = {cp_hvbar[31:5], {5{1'b0}}};

  // Bits 11:5 are not used by AArch64 VBAR_EL2 but must be present as used by AArch32 HVBAR
  assign cp_vbar_el2 = {cp_hvbar[63:5], {5{1'b0}}};

  // ------------------------------------------------------
  // Hyp Software Thread and Process ID Register (HTPIDT & TPIDR_EL2)
  // ------------------------------------------------------

  assign cp_htpidr_en_lo = wr_cp15_crn13_htpidr | wr_cp15_crn13_tpidr_el2;

  always @(posedge clk_cp15)
    if (cp_htpidr_en_lo)
      cp_htpidr[31:0] <= mcr_data_wr[31:0];

  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidr_el2)
      cp_htpidr[63:32] <= mcr_data_wr[63:32];

  // ------------------------------------------------------
  // Thread and Process ID Register (TPIDR_EL3)
  // ------------------------------------------------------

  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidr_el3)
      cp_tpidr_el3[63:0] <= mcr_data_wr[63:0];

  // ------------------------------------------------------
  // Secure Debug Enable Register (SDER & SDER32_EL3)
  // ------------------------------------------------------

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_sder <= {2{1'b0}};
    else if (wr_cp15_crn1_sder)
      cp_sder <= mcr_data_wr[1:0];

  assign cp_sder_rd = {{30{1'b0}}, cp_sder[1:0]};

  // ------------------------------------------------------
  // Floating-Point Exception Control register (FPEXC & FPEXC32_EL2)
  // ------------------------------------------------------

generate if (NEON_FP) begin : g_fpexc
  reg cp_fpexc_en_reg;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_fpexc_en_reg <= {1'b0};
    else if (wr_cp15_crn5_fpexc)
      cp_fpexc_en_reg <= mcr_data_wr[30];

  assign cp_fpexc_en = cp_fpexc_en_reg;
end else begin : g_fpexc_stubs
  assign cp_fpexc_en = 1'b0;
end endgenerate

  assign cp_fpexc_rd = {1'b0, cp_fpexc_en, 30'h00000700};

  // ------------------------------------------------------
  // Floating-Point Status and Control register (FPSCR) - AArch32
  // Floating-Point Status Register (FPSR) - AArch64
  // Floating-Point Control Register (FPCR) - AArch64
  // ------------------------------------------------------

generate if (NEON_FP) begin : g_fpscr
  reg                 [3:0] cp_fpsr_cflags;
  reg  [`CA53_XFLAGS_W-1:0] cp_fpsr_xflags;
  reg                       cp_fpcr_ahp;
  reg                       cp_fpcr_dn;
  reg                       cp_fpcr_fz;
  reg                 [1:0] cp_fpcr_rmode;

  wire [`CA53_XFLAGS_W-1:0] mcr_xflags;
  wire                [3:0] nxt_cp_fpsr_cflags;
  wire [`CA53_XFLAGS_W-1:0] nxt_cp_fpsr_xflags;
  wire                      en_cp_fpsr;
  wire                      en_cp_fpcr;

  assign nxt_cp_fpsr_cflags = (wr_cp15_crn4_fpsr | wr_cp10_fpscr) ? mcr_data_wr[`CA53_FPSCR_ARCH_NZCV_BITS] :
                              fp1_cflag_src_f5_i                  ? fp_cflags_add1_f5_i                     :
                              fp0_cflag_src_f5_i                  ? fp_cflags_add0_f5_i                     :
                                                                    cp_fpsr_cflags;

  assign mcr_xflags[`CA53_XFLAGS_QC_BITS]  = mcr_data_wr[`CA53_FPSCR_ARCH_QC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_IDC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_IDC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_IXC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_IXC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_UFC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_UFC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_OFC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_OFC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_DZC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_DZC_BITS];
  assign mcr_xflags[`CA53_XFLAGS_IOC_BITS] = mcr_data_wr[`CA53_FPSCR_ARCH_IOC_BITS];

  assign nxt_cp_fpsr_xflags = (wr_cp15_crn4_fpsr | wr_cp10_fpscr) ? mcr_xflags
                                                                  : (cp_fpsr_xflags                                                  |
                                                                     ({`CA53_XFLAGS_W{fp0_xflag_src_f5_i[0]}} & fp_xflags_mul0_f5_i) |
                                                                     ({`CA53_XFLAGS_W{fp0_xflag_src_f5_i[1]}} & fp_xflags_add0_f5_i) |
                                                                     ({`CA53_XFLAGS_W{fp1_xflag_src_f5_i[0]}} & fp_xflags_mul1_f5_i) |
                                                                     ({`CA53_XFLAGS_W{fp1_xflag_src_f5_i[1]}} & fp_xflags_add1_f5_i));

  assign en_cp_fpsr = wr_cp15_crn4_fpsr | wr_cp10_fpscr | fp0_cflag_src_f5_i | fp1_cflag_src_f5_i | (|fp0_xflag_src_f5_i) | (|fp1_xflag_src_f5_i);
  assign en_cp_fpcr = wr_cp15_crn4_fpcr | wr_cp10_fpscr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      cp_fpsr_cflags <= 4'b0000;
      cp_fpsr_xflags <= {`CA53_XFLAGS_W{1'b0}};
    end else if (en_cp_fpsr) begin
      cp_fpsr_cflags <= nxt_cp_fpsr_cflags;
      cp_fpsr_xflags <= nxt_cp_fpsr_xflags;
    end

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      cp_fpcr_ahp   <= 1'b0;
      cp_fpcr_dn    <= 1'b0;
      cp_fpcr_fz    <= 1'b0;
      cp_fpcr_rmode <= 2'b00;
    end else if (en_cp_fpcr) begin
      cp_fpcr_ahp   <= mcr_data_wr[`CA53_FPSCR_ARCH_AHP_BITS];
      cp_fpcr_dn    <= mcr_data_wr[`CA53_FPSCR_ARCH_DN_BITS];
      cp_fpcr_fz    <= mcr_data_wr[`CA53_FPSCR_ARCH_FZ_BITS];
      cp_fpcr_rmode <= mcr_data_wr[`CA53_FPSCR_ARCH_RMODE_BITS];
    end

  assign cp_fpsr_rd = {cp_fpsr_cflags,
                       cp_fpsr_xflags[`CA53_XFLAGS_QC_BITS],
                       {19{1'b0}},
                       cp_fpsr_xflags[`CA53_XFLAGS_IDC_BITS],
                       2'b00,
                       cp_fpsr_xflags[`CA53_XFLAGS_IXC_BITS],
                       cp_fpsr_xflags[`CA53_XFLAGS_UFC_BITS],
                       cp_fpsr_xflags[`CA53_XFLAGS_OFC_BITS],
                       cp_fpsr_xflags[`CA53_XFLAGS_DZC_BITS],
                       cp_fpsr_xflags[`CA53_XFLAGS_IOC_BITS]};

  assign cp_fpcr_rd = {5'b00000,
                       cp_fpcr_ahp,
                       cp_fpcr_dn,
                       cp_fpcr_fz,
                       cp_fpcr_rmode,
                       2'b00,         // Stride - RAZ
                       1'b0,
                       3'b000,        // LEN - RAZ
                       1'b0,          // IDE - RAZ
                       2'b00,
                       1'b0,          // IXE - RAZ
                       1'b0,          // UFE - RAZ
                       1'b0,          // OFE - RAZ
                       1'b0,          // DZE - RAZ
                       1'b0,          // IOE - RAZ
                       {8{1'b0}} };

  assign cp_fpscr_rd = {cp_fpsr_cflags,
                        cp_fpsr_xflags[`CA53_XFLAGS_QC_BITS],
                        cp_fpcr_ahp,
                        cp_fpcr_dn,
                        cp_fpcr_fz,
                        cp_fpcr_rmode,
                        2'b00,         // Stride - RAZ
                        1'b0,
                        3'b000,        // LEN - RAZ
                        1'b0,          // IDE - RAZ
                        2'b00,
                        1'b0,          // IXE - RAZ
                        1'b0,          // UFE - RAZ
                        1'b0,          // OFE - RAZ
                        1'b0,          // DZE - RAZ
                        1'b0,          // IOE - RAZ
                        cp_fpsr_xflags[`CA53_XFLAGS_IDC_BITS],
                        2'b00,
                        cp_fpsr_xflags[`CA53_XFLAGS_IXC_BITS],
                        cp_fpsr_xflags[`CA53_XFLAGS_UFC_BITS],
                        cp_fpsr_xflags[`CA53_XFLAGS_OFC_BITS],
                        cp_fpsr_xflags[`CA53_XFLAGS_DZC_BITS],
                        cp_fpsr_xflags[`CA53_XFLAGS_IOC_BITS]};

  assign cp_fpsr_cflags_o     = cp_fpsr_cflags;

  assign cp_fpcr_ahp_o        = cp_fpcr_ahp;
  assign cp_fpcr_dn_o         = cp_fpcr_dn;
  assign cp_fpcr_fz_o         = cp_fpcr_fz;
  assign cp_fpcr_rmode_o      = cp_fpcr_rmode;
end else begin : g_fpscr_stubs
  assign cp_fpsr_rd           = {32{1'b0}};
  assign cp_fpcr_rd           = {32{1'b0}};
  assign cp_fpscr_rd          = {32{1'b0}};

  assign cp_fpsr_cflags_o     = {4{1'b0}};

  assign cp_fpcr_ahp_o        = 1'b0;
  assign cp_fpcr_dn_o         = 1'b0;
  assign cp_fpcr_fz_o         = 1'b0;
  assign cp_fpcr_rmode_o      = 2'b00;
end endgenerate

  // ------------------------------------------------------
  // Non-Secure Access Control Register (NSACR)
  // ------------------------------------------------------

generate if (NEON_FP) begin : FPU4
  reg nsacr_cp10_internal;
  reg nsacr_cp11_internal;
  reg nsacr_nsasedis_internal;

  // It is UNPREDICTABLE for cp10 and cp11 to have different values here
  // Always use the cp10 if they are different
  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n) begin
      nsacr_cp10_internal     <= 1'b0;
      nsacr_cp11_internal     <= 1'b0;
      nsacr_nsasedis_internal <= 1'b0;
    end else if (wr_cp15_crn1_nsacr) begin
      nsacr_cp10_internal     <= mcr_data_wr[10];
      nsacr_cp11_internal     <= mcr_data_wr[11];
      nsacr_nsasedis_internal <= mcr_data_wr[15];
    end

  assign nsacr_cp10     = nsacr_cp10_internal     |  aarch64_at_el3;
  assign nsacr_cp11     = nsacr_cp11_internal     |  aarch64_at_el3;
  assign nsacr_nsasedis = nsacr_nsasedis_internal & ~aarch64_at_el3;

  assign nsfpudis       = ns_state_i & ~nsacr_cp10;
  assign nsasedis       = ns_state_i &  nsacr_nsasedis;
end else begin : FPU4_STUBS
  assign nsacr_cp10     = aarch64_at_el3;
  assign nsacr_cp11     = aarch64_at_el3;
  assign nsacr_nsasedis = 1'b0;
  assign nsfpudis       = 1'b0;
  assign nsasedis       = 1'b0;
end endgenerate

  assign cp_nsacr_rd = {{16{1'b0}},     // RAZ
                        nsacr_nsasedis, // Non-secure ASE disable
                        1'b0,           // Non-secure D32 disable
                        {2{1'b0}},      // RAZ
                        nsacr_cp11,     // CP11
                        nsacr_cp10,     // CP10
                        {10{1'b0}}};    // RAZ

  // ------------------------------------------------------
  // Domain Access Control Register (DACR & DACR32_EL2)
  // ------------------------------------------------------

  // Secure DACR
  always @(posedge clk_cp15)
    if (wr_cp15_crn3_dacr_s)
      cp_dacr <= mcr_data_wr[31:0];

  // Non-Secure DACR
  always @(posedge clk_cp15)
    if (wr_cp15_crn3_dacr_ns)
      cp_dacr_ns <= mcr_data_wr[31:0];

  // ------------------------------------------------------
  // EL1 Exception Syndrome Register (ESR_EL1)/DFSR.NS
  // ------------------------------------------------------

  assign expt_dfsr_full = {{18{1'b0}},            // [31:14]
                           expt_dfsr_wr_i[12:8],  // [13:9]
                           1'b0,                  // [8]
                           expt_dfsr_wr_i[7:0]};  // [7:0]

  assign nxt_cp_esr_el1 = ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL1]}} & expt_esr_data_wr_i) |
                          ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR]}}    & expt_dfsr_full)     |
                          ({32{~expt_fault_reg_sel_wr_i}}                           & mcr_data_wr[31:0]);

  assign cp_esr_el1_en  = wr_cp15_crn5_dfsr_ns | wr_cp15_crn5_esr_el1 |
                          (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR] & expt_aa32_uses_el1_esr_wr_i) |
                          expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL1];

  always @(posedge clk)
    if (cp_esr_el1_en)
      cp_esr_el1 <= nxt_cp_esr_el1;

  // ------------------------------------------------------
  // EL3 Exception Syndrome Register (ESR_EL3)/DFSR.S
  // ------------------------------------------------------

  assign nxt_cp_esr_el3 = ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL3]}} & expt_esr_data_wr_i) |
                          ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR]}}    & expt_dfsr_full)     |
                          ({32{~expt_fault_reg_sel_wr_i}}                           & mcr_data_wr[31:0]);

  assign cp_esr_el3_en  = wr_cp15_crn5_dfsr_s | wr_cp15_crn5_esr_el3 |
                          (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR] & ~expt_aa32_uses_el1_esr_wr_i) |
                          expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL3];

  always @(posedge clk)
    if (cp_esr_el3_en)
      cp_esr_el3 <= nxt_cp_esr_el3;

  // ------------------------------------------------------
  // Instruction Fault Status Register (IFSR & IFSR32_EL2)
  // ------------------------------------------------------

  assign nxt_cp_ifsr[8]   = (wr_cp15_crn5_ifsr_s | wr_cp15_crn5_ifsr_ns) ? mcr_data_wr[12]   : expt_ifsr_wr_i[12];
  assign nxt_cp_ifsr[7:6] = (wr_cp15_crn5_ifsr_s | wr_cp15_crn5_ifsr_ns) ? mcr_data_wr[10:9] : expt_ifsr_wr_i[10:9];
  assign nxt_cp_ifsr[5:0] = (wr_cp15_crn5_ifsr_s | wr_cp15_crn5_ifsr_ns) ? mcr_data_wr[5:0]  : expt_ifsr_wr_i[5:0];

  // Secure IFSR
  always @(posedge clk)
    if (wr_cp15_crn5_ifsr_s | (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFSR] & ~expt_aa32_uses_el1_esr_wr_i))
      cp_ifsr <= nxt_cp_ifsr;

  assign cp_ifsr_rd = {{19{1'b0}},     // [31:13]
                       cp_ifsr[8],     // [12]
                       1'b0,           // [11]
                       cp_ifsr[7:6],   // [10:9]
                       3'b000,         // [8:6]
                       cp_ifsr[5:0]};  // [5:0]

  // Non-secure IFSR
  always @(posedge clk)
    if (wr_cp15_crn5_ifsr_ns | (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFSR] & expt_aa32_uses_el1_esr_wr_i))
      cp_ifsr_ns <= nxt_cp_ifsr;

  assign cp_ifsr_ns_rd = {{19{1'b0}},        // [31:13]
                          cp_ifsr_ns[8],     // [12]
                          1'b0,              // [11]
                          cp_ifsr_ns[7:6],   // [10:9]
                          3'b000,            // [8:6]
                          cp_ifsr_ns[5:0]};  // [5:0]

  // ------------------------------------------------------
  // EL1 Fault Address Register (FAR_EL1)/DFAR.NS/IFAR.NS
  // ------------------------------------------------------
  // The AA64 FAR_EL1 is mapped to the AA32 non-secure DFAR and IFAR:
  //       |----------------+---------------|
  // AA64: | FAR_EL1[63:32] | FAR_EL1[31:0] |
  //       |----------------+---------------|
  // AA32: | IFAR.NS[31:0]  | DFAR.NS[31:0] |
  //       |----------------+---------------|
  //
  // Note that accessing one of the AA32 registers mapped on to the
  // upper or lower FAR_EL1 must not affect the bits in the other half
  // of the AA64 register.

  assign nxt_cp_far_el1_upper  = ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL1]}} & expt_far_data_wr_i[63:32]) |
                                 ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR]}}    & expt_far_data_wr_i[31:0])  |
                                 ({32{wr_cp15_crn6_far_el1}}                               & mcr_data_wr[63:32])        |
                                 ({32{wr_cp15_crn6_ifar_ns}}                               & mcr_data_wr[31:0]);

  assign nxt_cp_far_el1_lower  = expt_fault_reg_sel_wr_i ? expt_far_data_wr_i[31:0] // Correct for DFAR if AA32 exception
                                                         : mcr_data_wr[31:0];       // Correct for DFAR/FAR_EL1

  assign cp_far_el1_upper_en = wr_cp15_crn6_ifar_ns | wr_cp15_crn6_far_el1 |
                               (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR] & expt_aa32_uses_el1_esr_wr_i) |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL1];

  assign cp_far_el1_lower_en = wr_cp15_crn6_dfar_ns | wr_cp15_crn6_far_el1 |
                               (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFAR] & expt_aa32_uses_el1_esr_wr_i) |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL1];

  always @(posedge clk)
    if (cp_far_el1_upper_en)
      cp_far_el1[63:32] <= nxt_cp_far_el1_upper;

  always @(posedge clk)
    if (cp_far_el1_lower_en)
      cp_far_el1[31:0]  <= nxt_cp_far_el1_lower;

  // ------------------------------------------------------
  // EL2 Fault Address Register (FAR_EL2/HDFAR/HIFAR/DFAR.S/IFAR.S)
  // ------------------------------------------------------
  // The AA64 FAR_EL2 is mapped to the AA32 HDFAR and HIFAR, which in
  // turn are mapped on to the secure DFAR and IFAR:
  //                |----------------+---------------|
  // AA64:          | FAR_EL2[63:32] | FAR_EL2[31:0] |
  //                |----------------+---------------|
  // AA32 Hyp Mode: | HIFAR[31:0]    | HDFAR[31:0]   |
  //                |----------------+---------------|
  // AA32 Mon Mode: | IFAR.S[31:0]   | DFAR.S[31:0]  |
  //                |----------------+---------------|
  //
  // Note that accessing one of the AA32 registers mapped on to the
  // upper or lower FAR_EL1 must not affect the bits in the other half
  // of the AA64 register.

  assign nxt_cp_far_el2_upper = ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL2]}} & expt_far_data_wr_i[63:32]) |
                                ({32{expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HIFAR] |
                                     expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR]}}    & expt_far_data_wr_i[31:0])  |
                                 ({32{wr_cp15_crn6_far_el2}}                              & mcr_data_wr[63:32])        |
                                 ({32{wr_cp15_crn6_hifar | wr_cp15_crn6_ifar_s}}          & mcr_data_wr[31:0]);

  assign nxt_cp_far_el2_lower = expt_fault_reg_sel_wr_i ? expt_far_data_wr_i[31:0]
                                                        : mcr_data_wr[31:0];

  assign cp_far_el2_upper_en = wr_cp15_crn6_ifar_s | wr_cp15_crn6_hifar | wr_cp15_crn6_far_el2 |
                               (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR] & ~expt_aa32_uses_el1_esr_wr_i) |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HIFAR] |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL2];

  assign cp_far_el2_lower_en = wr_cp15_crn6_dfar_s | wr_cp15_crn6_hdfar | wr_cp15_crn6_far_el2 |
                               (expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFAR] & ~expt_aa32_uses_el1_esr_wr_i) |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HDFAR] |
                               expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL2];

  always @(posedge clk)
    if (cp_far_el2_upper_en)
      cp_far_el2[63:32] <= nxt_cp_far_el2_upper;

  always @(posedge clk)
    if (cp_far_el2_lower_en)
      cp_far_el2[31:0]  <= nxt_cp_far_el2_lower;

  // ------------------------------------------------------
  // EL3 Fault Address Register (FAR_EL3)
  // ------------------------------------------------------
  // This an AA64 register which does not map on to any AA32 register

  assign nxt_cp_far_el3 = expt_fault_reg_sel_wr_i ? expt_far_data_wr_i
                                                  : mcr_data_wr;

  assign cp_far_el3_en = wr_cp15_crn6_far_el3 | expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL3];

  always @(posedge clk)
    if (cp_far_el3_en)
      cp_far_el3 <= nxt_cp_far_el3;

  // ------------------------------------------------------
  // EL1 CPU Memory Error Syndrome Register (CPUMERRSR_EL1)
  // ------------------------------------------------------
  // This is an AA64 register which is mapped to the AA32 CPUMERRSR

generate if (CPU_CACHE_PROTECTION) begin : CPU_CACHE_PROTECTION_CONFIG

  // ---------------------------------
  // Declarations
  // ---------------------------------

  reg         cp_cpumerrsr_ftl;
  reg   [7:0] cp_cpumerrsr_other_err_cnt;
  reg   [3:0] cp_cpumerrsr_ramid;
  reg   [7:0] cp_cpumerrsr_repeat_err_cnt;
  reg         cp_cpumerrsr_vld;
  reg   [2:0] cp_cpumerrsr_way_bank_id;
  reg  [11:0] cp_cpumerrsr_index;
  reg         dcu_ecc_fatal_rs;
  reg         dcu_ecc_valid_rs;
  reg   [1:0] dcu_ecc_ramid_rs;
  reg   [2:0] dcu_ecc_way_bank_id_rs;
  reg  [10:0] dcu_ecc_index_rs;
  reg         tlb_pty_valid_rs;
  reg   [1:0] tlb_pty_way_bank_id_rs;
  reg   [7:0] tlb_pty_index_rs;
  reg         ifu_pty_valid_rs;
  reg         ifu_pty_ramid_rs;
  reg         ifu_pty_way_bank_id_rs;
  reg  [11:0] ifu_pty_index_rs;

  wire        cpumerrsr_same_bank;
  wire        cp_cpumerrsr_wr;
  wire        cp_cpumerrsr_en;
  wire        cp_cpumerrsr_data_rs_en;
  wire        cp_cpumerrsr_valid_rs_en;
  wire        dcu_ecc_fatal_valid_rs;
  wire        nxt_cp_cpumerrsr_ftl;
  wire  [7:0] nxt_cp_cpumerrsr_other_err_cnt;
  wire  [3:0] nxt_cp_cpumerrsr_ramid;
  wire  [7:0] nxt_cp_cpumerrsr_repeat_err_cnt;
  wire        nxt_cp_cpumerrsr_vld;
  wire [2:0]  nxt_cp_cpumerrsr_way_bank_id;
  wire [11:0] nxt_cp_cpumerrsr_index;

  // Register slice parity/ECC information from DCU/TLB/IFU before generating error information for the CPUMERRSR
  assign cp_cpumerrsr_valid_rs_en = dcu_ecc_valid_i | dcu_ecc_valid_rs | tlb_pty_valid_i | tlb_pty_valid_rs | ifu_pty_valid_i | ifu_pty_valid_rs;
  assign cp_cpumerrsr_data_rs_en  = dcu_ecc_valid_i |                    tlb_pty_valid_i |                    ifu_pty_valid_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      dcu_ecc_valid_rs <= 1'b0;
      tlb_pty_valid_rs <= 1'b0;
      ifu_pty_valid_rs <= 1'b0;
    end
    else if (cp_cpumerrsr_valid_rs_en) begin
      dcu_ecc_valid_rs <= dcu_ecc_valid_i;
      tlb_pty_valid_rs <= tlb_pty_valid_i;
      ifu_pty_valid_rs <= ifu_pty_valid_i;
    end

  always @(posedge clk)
    if (cp_cpumerrsr_data_rs_en) begin 
      dcu_ecc_fatal_rs       <= dcu_ecc_fatal_i;
      dcu_ecc_ramid_rs       <= dcu_ecc_ramid_i[1:0];
      dcu_ecc_way_bank_id_rs <= dcu_ecc_way_bank_id_i[2:0];
      dcu_ecc_index_rs       <= dcu_ecc_index_i[10:0];
      tlb_pty_way_bank_id_rs <= tlb_pty_way_bank_id_i[1:0];
      tlb_pty_index_rs       <= tlb_pty_index_i[7:0];
      ifu_pty_ramid_rs       <= ifu_pty_ramid_i;
      ifu_pty_way_bank_id_rs <= ifu_pty_way_bank_id_i;
      ifu_pty_index_rs       <= ifu_pty_index_i[11:0];
    end

  // Qualify DCU fatal indicator with valid before use
  assign dcu_ecc_fatal_valid_rs = dcu_ecc_fatal_rs & dcu_ecc_valid_rs;

  // System write indication
  assign cp_cpumerrsr_wr = cp_valid_wr & (raw_cp_decode_wr[8:0] == {1'b1, `CA53_CRN15_CPUMERRSR});

  // Combine system enable and ECC update enable.  Prevent further updates once a fatal is indicated so that a fatal is sticky
  assign cp_cpumerrsr_en = cp_cpumerrsr_wr | ((dcu_ecc_valid_rs |
                                               tlb_pty_valid_rs |
                                               ifu_pty_valid_rs) & ~cp_cpumerrsr_ftl);

  // [63] - Fatal : Clear on a system write, Set on a fatal error
  assign nxt_cp_cpumerrsr_ftl = ~cp_cpumerrsr_wr & dcu_ecc_fatal_valid_rs;

  // [47:40] - Other Error Count : Clear on a system write, Clear on first memory error, Increment on any error that isn't tracked by 'Repeat Error Count' field
  assign cpumerrsr_same_bank = (// DCU ECC Error
                                (dcu_ecc_valid_rs &
                                 (cp_cpumerrsr_ramid            == {2'b01, dcu_ecc_ramid_rs}) &
                                 (cp_cpumerrsr_way_bank_id[2:0] == dcu_ecc_way_bank_id_rs[2:0])) |
                                // TLB Parity Error
                                (tlb_pty_valid_rs &
                                 (cp_cpumerrsr_ramid            == 4'b1100) &
                                 (cp_cpumerrsr_way_bank_id[1:0] == tlb_pty_way_bank_id_rs[1:0])) |
                                // IFU Parity Error
                                (ifu_pty_valid_rs &
                                 (cp_cpumerrsr_ramid            == {3'b000, ifu_pty_ramid_rs}) &
                                 (cp_cpumerrsr_way_bank_id[0]   == ifu_pty_way_bank_id_rs)));

  assign nxt_cp_cpumerrsr_other_err_cnt = {8{~cp_cpumerrsr_wr}} & {8{cp_cpumerrsr_vld}} &                                 (cp_cpumerrsr_other_err_cnt[7:0]  + {{7{1'b0}}, ~cpumerrsr_same_bank});

  // [39:32] - Repeat Error Count : Clear on a system write, first memory error or fatal, Increment on any error to the same RAM/Way/Bank ID
  assign nxt_cp_cpumerrsr_repeat_err_cnt = {8{~cp_cpumerrsr_wr}} & {8{cp_cpumerrsr_vld}} & {8{~dcu_ecc_fatal_valid_rs}} & (cp_cpumerrsr_repeat_err_cnt[7:0] + {{7{1'b0}},  cpumerrsr_same_bank});

  // [31] - Valid : Clear on a write, Set on a valid ECC update
  assign nxt_cp_cpumerrsr_vld            = ~cp_cpumerrsr_wr;

  // [30:24] - RAM ID : Recirculate once valid, unless there's been a fatal error.  Note that [30:29] are constant
  //
  // 0h00 : 5'b00000 - L1 Instruction Tag RAM
  // 0h01 : 5'b00001 - L1 Instruction Data RAM
  // 0h08 : 5'b01000 - L1 Data Tag RAM
  // 0h09 : 5'b01001 - L1 Data Data RAM
  // 0h0A : 5'b01010 - L1 Data Dirty RAM
  // 0h18 : 5'b11000 - TLB RAM
  //
  // Note that bit [2] is redundant
  assign nxt_cp_cpumerrsr_ramid          = {4{~cp_cpumerrsr_wr}} & ((cp_cpumerrsr_vld & ~dcu_ecc_fatal_valid_rs) ? cp_cpumerrsr_ramid       : (dcu_ecc_valid_rs ? {2'b01, dcu_ecc_ramid_rs} :
                                                                                                                                               tlb_pty_valid_rs ?  4'b1100                  :
                                                                                                                                                                  {3'b000, ifu_pty_ramid_rs}));

  // [20:18] - Way/Bank ID : Recirculate once valid, unless there's been a fatal error
  assign nxt_cp_cpumerrsr_way_bank_id    = {3{~cp_cpumerrsr_wr}} & ((cp_cpumerrsr_vld & ~dcu_ecc_fatal_valid_rs) ? cp_cpumerrsr_way_bank_id : (dcu_ecc_valid_rs ?         dcu_ecc_way_bank_id_rs[2:0]  :
                                                                                                                                               tlb_pty_valid_rs ? {1'b0,  tlb_pty_way_bank_id_rs[1:0]} :
                                                                                                                                                                  {2'b00, ifu_pty_way_bank_id_rs}));

  // [11:0] - Index : Recirculate once valid, unless there's been a fatal error
  assign nxt_cp_cpumerrsr_index          = {12{~cp_cpumerrsr_wr}} & ((cp_cpumerrsr_vld & ~dcu_ecc_fatal_valid_rs) ? cp_cpumerrsr_index       : (dcu_ecc_valid_rs ? {1'b0,  dcu_ecc_index_rs[10:0]} :
                                                                                                                                                tlb_pty_valid_rs ? {4'h0,  tlb_pty_index_rs[7:0]} :
                                                                                                                                                                           ifu_pty_index_rs[11:0]));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      cp_cpumerrsr_ftl            <=    1'b0;
      cp_cpumerrsr_other_err_cnt  <= {8{1'b0}};
      cp_cpumerrsr_repeat_err_cnt <= {8{1'b0}};
      cp_cpumerrsr_vld            <=    1'b0;
    end
    else if (cp_cpumerrsr_en) begin
      cp_cpumerrsr_ftl            <= nxt_cp_cpumerrsr_ftl;
      cp_cpumerrsr_other_err_cnt  <= nxt_cp_cpumerrsr_other_err_cnt;
      cp_cpumerrsr_repeat_err_cnt <= nxt_cp_cpumerrsr_repeat_err_cnt;
      cp_cpumerrsr_vld            <= nxt_cp_cpumerrsr_vld;
    end

  always @(posedge clk)
    if (cp_cpumerrsr_en) begin
      cp_cpumerrsr_ramid          <= nxt_cp_cpumerrsr_ramid;
      cp_cpumerrsr_way_bank_id    <= nxt_cp_cpumerrsr_way_bank_id;
      cp_cpumerrsr_index          <= nxt_cp_cpumerrsr_index;
    end

  // Read path
  assign rd_cp15_cpumerrsr = (raw_cp_decode_wr[8:0] == {1'b0, `CA53_CRN15_CPUMERRSR});
  assign cp_cpumerrsr      = {cp_cpumerrsr_ftl,
                              {15{1'b0}},
                              cp_cpumerrsr_other_err_cnt,
                              cp_cpumerrsr_repeat_err_cnt,
                              cp_cpumerrsr_vld,
                              2'b00,                   // Constant bits of RAM ID
                              cp_cpumerrsr_ramid[3:2], // Variable bits of RAM ID
                              1'b0,                    // Constant bits of RAM ID
                              cp_cpumerrsr_ramid[1:0], // Variable bits of RAM ID
                              {3{1'b0}},
                              cp_cpumerrsr_way_bank_id,
                              {6{1'b0}},
                              cp_cpumerrsr_index};

  // Event signals
  assign evnt_mem_err_ifu_o = ifu_pty_valid_rs;
  assign evnt_mem_err_dcu_o = dcu_ecc_valid_rs;
  assign evnt_mem_err_tlb_o = tlb_pty_valid_rs;

end else begin : NO_CPU_CACHE_PROTECTION_CONFIG
  assign rd_cp15_cpumerrsr  = 1'b0;
  assign cp_cpumerrsr       = {64{1'b0}};
  assign evnt_mem_err_ifu_o = 1'b0;
  assign evnt_mem_err_dcu_o = 1'b0;
  assign evnt_mem_err_tlb_o = 1'b0;
end endgenerate

  // ------------------------------------------------------
  // User Read Only Thread and Process ID Register (TPIDRURW & TPIDR_EL0)
  // ------------------------------------------------------

  // Secure TPIDRURW
  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidrurw_s)
      cp_tpidrurw <= mcr_data_wr[31:0];

  // Non-secure TPIDRURW
  assign cp_tpidrurw_ns_en_lo = wr_cp15_crn13_tpidrurw_ns | wr_cp15_crn13_tpidr_el0;

  always @(posedge clk_cp15)
    if (cp_tpidrurw_ns_en_lo)
      cp_tpidrurw_ns[31:0] <= mcr_data_wr[31:0];

  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidr_el0)
      cp_tpidrurw_ns[63:32] <= mcr_data_wr[63:32];

  // ------------------------------------------------------
  // User Read Only Thread and Process ID Register
  // ------------------------------------------------------

  // Secure TPIDRURO
  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidruro_s)
      cp_tpidruro <= mcr_data_wr[31:0];

  // Non-secure TPIDRURO and TPIFRRO_EL0
  assign cp_tpidruro_ns_en_lo = wr_cp15_crn13_tpidruro_ns | wr_cp15_crn13_tpidrro_el0;

  always @(posedge clk_cp15)
    if (cp_tpidruro_ns_en_lo)
      cp_tpidruro_ns[31:0]  <= mcr_data_wr[31:0];

  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidrro_el0)
      cp_tpidruro_ns[63:32] <= mcr_data_wr[63:32];

  // ------------------------------------------------------
  // Privileged Only Thread and Process ID Register (TPIDRPRW & TPIDR_EL1)
  // ------------------------------------------------------

  // Secure TPIDRPRW
  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidrprw_s)
      cp_tpidrprw <= mcr_data_wr[31:0];

  // Non-secure TPIDRPRW
  assign cp_tpidrprw_ns_en_lo = wr_cp15_crn13_tpidrprw_ns | wr_cp15_crn13_tpidr_el1;

  always @(posedge clk_cp15)
    if (cp_tpidrprw_ns_en_lo)
      cp_tpidrprw_ns[31:0] <= mcr_data_wr[31:0];

  always @(posedge clk_cp15)
    if (wr_cp15_crn13_tpidr_el1)
      cp_tpidrprw_ns[63:32] <= mcr_data_wr[63:32];

  // ------------------------------------------------------
  // Vector Base Address Register (VBAR)
  // ------------------------------------------------------

  // Secure VBAR and VBAR_EL3
  assign cp_vbar_en_lo = wr_cp15_crn12_vbar_s | wr_cp15_crn12_vbar_el3;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_vbar[31:5] <= {27{1'b0}};
    else if (cp_vbar_en_lo)
      cp_vbar[31:5] <= mcr_data_wr[31:5];

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_vbar[63:32] <= {32{1'b0}};
    else if (wr_cp15_crn12_vbar_el3)
      cp_vbar[63:32] <= mcr_data_wr[63:32];

  assign cp_vbar_rd     = {cp_vbar[31:5], {5{1'b0}}};

  // Bits 11:5 are not used by AArch64 VBAR_EL3. They are accessible so that VBAR_EL3
  // has the same bit access as VBAR_EL1 and VBAR_EL2
  assign cp_vbar_el3 = {cp_vbar[63:5], {5{1'b0}}};

  // Non-secure VBAR and VBAR_EL1
  assign cp_vbar_ns_en_lo = wr_cp15_crn12_vbar_ns | wr_cp15_crn12_vbar_el1;

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_vbar_ns[31:5] <= {27{1'b0}};
    else if (cp_vbar_ns_en_lo)
      cp_vbar_ns[31:5] <= mcr_data_wr[31:5];

  always @(posedge clk_cp15 or negedge reset_n)
    if (~reset_n)
      cp_vbar_ns[63:32] <= {32{1'b0}};
    else if (wr_cp15_crn12_vbar_el1)
      cp_vbar_ns[63:32] <= mcr_data_wr[63:32];

  assign cp_vbar_ns_rd =  {cp_vbar_ns[31:5], {5{1'b0}}};

  // Bits 11:5 are not used by AArch64 VBAR_EL1 but must be present as used by AArch32 VBAR
  assign cp_vbar_el1 = {cp_vbar_ns[63:5], {5{1'b0}}};

  // ------------------------------------------------------
  // Monitor Vector Base Address Register (MVBAR)
  // ------------------------------------------------------

  always @(posedge clk_cp15)
    if (wr_cp15_crn12_mvbar)
      cp_mvbar[31:5] <= mcr_data_wr[31:5];

  assign cp_mvbar_rd = {cp_mvbar[31:5], {5{1'b0}}};

  // ------------------------------------------------------
  // Reset Vector Base Address Register (RVBAR_EL3)
  // ------------------------------------------------------

  always @(posedge clk_cp15)
    if (load_initial)
      rvbaraddr[39:2] <= gov_rvbaraddr_i[39:2];

  assign cp_rvbar_el3 = {{24{1'b0}}, rvbaraddr[39:2], 2'b00};

  assign rvbaraddr_o = rvbaraddr;

  // ------------------------------------------------------
  // Interrupt Status Register (ISR)
  // ------------------------------------------------------

  // When an interrupt is virtualised, return the appropriate HCR bit instead
  // of the actual hardware status for a non-secure read
  assign cp_isr = { {23{1'b0}},
                   expt_serr_pending_i,
                   expt_irq_pending_i,
                   expt_fiq_pending_i,
                   {6{1'b0}} };

  // ------------------------------------------------------
  // Cache Size ID Register (CCSIDR & CCSIDR_EL1)
  // ------------------------------------------------------

  // The select that chooses between instruction and data is dependent
  // on the banked CSSR register
  assign cp_ccsidr_instr_sel = (ns_state_i | aarch64_at_el3) ? cp_cssr_ns[0] : cp_cssr[0];

generate if (L2_CACHE) begin : L2_CACHE_PRESENT2
  wire cp_ccsidr_l2_sel;

  // The select that chooses between data Level1 and Level2 is dependent
  // on the banked CSSR register
  assign cp_ccsidr_l2_sel = (ns_state_i | aarch64_at_el3) ? cp_cssr_ns[1] : cp_cssr[1];

  assign cp_ccsidr = cp_ccsidr_l2_sel    ? `CA53_CCSIDR_L2_READ_VALUE (l2_size) :
                     cp_ccsidr_instr_sel ? `CA53_CCSIDR_L1I_READ_VALUE(ic_size_i) :
                                           `CA53_CCSIDR_L1D_READ_VALUE(dc_size_i);
end else begin : L2_CACHE_PRESENT2_STUBS
  assign cp_ccsidr = cp_ccsidr_instr_sel ? `CA53_CCSIDR_L1I_READ_VALUE(ic_size_i) :
                                           `CA53_CCSIDR_L1D_READ_VALUE(dc_size_i);
end endgenerate

  // ------------------------------------------------------
  // Configuration Base Address register
  // ------------------------------------------------------

  always @(posedge clk_cp15)
    if (last_load_initial)
      periphbase[39:18] <= gov_periphbase_i[39:18];

  // Format of the CBAR register differs between AArch32 and AArch64
  assign cp_cbar = {periphbase[31:18], {10{1'b0}}, periphbase[39:32]};

  assign cp_cbar_el1 = { {24{1'b0}}, periphbase[39:18], {18{1'b0}} };

  assign dpu_periphbase_o = periphbase[39:18];

  // ------------------------------------------------------
  // Final read mux
  // ------------------------------------------------------
  // For synthesis timing purposes, this read mux is realised as OR gate.
  // The output from each register is sampled through an AND gate and only one
  // register is enabled at any time.  When the register is selected, the
  // outputs of the register are sent to the final OR gate.  This means that
  // the default behaviour of the logic is to drive zeros when not selected.

  assign cp_read_data_int_wr = ({{32{1'b0}},((cp_midr              & {32{rd_cp15_crn0_midr}})                                   |
                                             (cp_ctr               & {32{rd_cp15_crn0_ctr}})                                    |
                                             (cp_mpidr             & {32{rd_cp15_crn0_mpidr}})                                  |
                                             (cp_revidr            & {32{rd_cp15_crn0_revidr}})                                 |
                                             (cp_dczid_el0         & {32{rd_cp15_crn0_dczid_el0}})                              |
                                             (cp_ccsidr            & {32{rd_cp15_crn0_id_ccsidr}})                              |
                                             (cp_clidr             & {32{rd_cp15_crn0_id_clidr}})                               |
                                             (cp_vpidr             & {32{rd_cp15_crn0_vpidr}})                                  |
                                             (cp_vmpidr            & {32{rd_cp15_crn0_vmpidr}})                                 |
                                             (cp_csselr            & {32{rd_cp15_crn0_csselr_s}})                               |
                                             (cp_csselr_ns         & {32{rd_cp15_crn0_csselr_ns}})                              |
                                             (cp_idpfr0            & {32{rd_cp15_crn0_id_pfr0}})                                |
                                             (cp_idpfr1            & {32{rd_cp15_crn0_id_pfr1}})                                |
                                             (cp_iddfr             & {32{rd_cp15_crn0_id_dfr0}})                                |
                                             (cp_idmfr0            & {32{rd_cp15_crn0_id_mmfr0}})                               |
                                             (cp_idmfr1            & {32{rd_cp15_crn0_id_mmfr1}})                               |
                                             (cp_idmfr2            & {32{rd_cp15_crn0_id_mmfr2}})                               |
                                             (cp_idmfr3            & {32{rd_cp15_crn0_id_mmfr3}})                               |
                                             (cp_idifr0            & {32{rd_cp15_crn0_id_isar0}})                               |
                                             (cp_idifr1            & {32{rd_cp15_crn0_id_isar1}})                               |
                                             (cp_idifr2            & {32{rd_cp15_crn0_id_isar2}})                               |
                                             (cp_idifr3            & {32{rd_cp15_crn0_id_isar3}})                               |
                                             (cp_idifr4            & {32{rd_cp15_crn0_id_isar4}})                               |
                                             (cp_idifr5            & {32{rd_cp15_crn0_id_isar5}})                               |
                                             (cp_mvfr0             & {32{rd_cp15_crn0_id_mvfr0}})                               |
                                             (cp_mvfr1             & {32{rd_cp15_crn0_id_mvfr1}})                               |
                                             (cp_mvfr2             & {32{rd_cp15_crn0_id_mvfr2}})                               |
                                             (cp_scr               & {32{rd_cp15_crn1_scr}})                                    |
                                             (cp_sctlr_el2         & {32{rd_cp15_crn1_hsctlr}})                                 |
                                             (cp_sctlr_el2         & {32{rd_cp15_crn1_sctlr_el2}})                              |
                                             (cp_hcr               & {32{rd_cp15_crn1_hcr}})                                    |
                                             (cp_hcr2              & {32{rd_cp15_crn1_hcr2}})                                   |
                                             (cp_hdcr              & {32{rd_cp15_crn1_hdcr}})                                   |
                                             (cp_mdcr_el3          & {32{rd_cp15_crn1_mdcr_el3}})                               |
                                             (cp_hcptr             & {32{rd_cp15_crn1_hcptr}})                                  |
                                             (cptr_el3             & {32{rd_cp15_crn1_cptr_el3}})                               |
                                             (cp_hstr_rd           & {32{rd_cp15_crn1_hstr}})                                   |
                                             (cp_sder_rd           & {32{rd_cp15_crn1_sder}})                                   |
                                             (cp_nsacr_rd          & {32{rd_cp15_crn1_nsacr}})                                  |
                                             (cp_sctlr_el3         & {32{rd_cp15_crn1_sctlr_s}})                                |
                                             (cp_sctlr_el3         & {32{rd_cp15_crn1_sctlr_el3}})                              |
                                             (cp_sctlr_el1         & {32{rd_cp15_crn1_sctlr_ns}})                               |
                                             (cp_sctlr_el1         & {32{rd_cp15_crn1_sctlr_el1}})                              |
                                             (cp_cpuectlr          & {32{rd_cp15_crn1_cpuectlr}})                               |
                                             (cp_actlr_el3         & {32{rd_cp15_crn1_actlr_el3}})                              |
                                             (cp_actlr_el2         & {32{rd_cp15_crn1_actlr_el2}})                              |
                                             (cp_cpacr             & {32{rd_cp15_crn1_cpacr}})                                  |
                                             (cp_dacr              & {32{rd_cp15_crn3_dacr_s}})                                 |
                                             (cp_dacr_ns           & {32{rd_cp15_crn3_dacr_ns}})                                |
                                             (cp_fpsr_rd           & {32{rd_cp15_crn4_fpsr}})                                   |
                                             (cp_fpcr_rd           & {32{rd_cp15_crn4_fpcr}})                                   |
                                             (cp_fpexc_rd          & {32{rd_cp15_crn5_fpexc}})                                  |
                                             (cp_esr_el1           & {32{rd_cp15_crn5_dfsr_ns | rd_cp15_crn5_esr_el1}})         |
                                             (cp_esr_el3           & {32{rd_cp15_crn5_dfsr_s  | rd_cp15_crn5_esr_el3}})         |
                                             (cp_ifsr_rd           & {32{rd_cp15_crn5_ifsr_s}})                                 |
                                             (cp_ifsr_ns_rd        & {32{rd_cp15_crn5_ifsr_ns}})                                |
                                             (cp_esr_el2           & {32{rd_cp15_crn5_esr_el2}})                                |
                                             (cp_far_el2[31:0]     & {32{rd_cp15_crn6_dfar_s | rd_cp15_crn6_hdfar}})            |
                                             (cp_far_el1[31:0]     & {32{rd_cp15_crn6_dfar_ns}})                                |
                                             (cp_far_el2[63:32]    & {32{rd_cp15_crn6_ifar_s | rd_cp15_crn6_hifar}})            |
                                             (cp_far_el1[63:32]    & {32{rd_cp15_crn6_ifar_ns}})                                |
                                             (cp_hpfar_rd          & {32{rd_cp15_crn6_hpfar}})                                  |
                                             (cp_hvbar_rd          & {32{rd_cp15_crn12_hvbar}})                                 |
                                             (cp_vbar_rd           & {32{rd_cp15_crn12_vbar_s}})                                |
                                             (cp_vbar_ns_rd        & {32{rd_cp15_crn12_vbar_ns}})                               |
                                             (cp_mvbar_rd          & {32{rd_cp15_crn12_mvbar}})                                 |
                                             (cp_isr               & {32{rd_cp15_crn12_isr}})                                   |
                                             (cp_rmr               & {32{rd_cp15_crn12_rmr_el3}})                               |
                                             (cp_htpidr[31:0]      & {32{rd_cp15_crn13_htpidr}})                                |
                                             (cp_tpidrurw          & {32{rd_cp15_crn13_tpidrurw_s}})                            |
                                             (cp_tpidrurw_ns[31:0] & {32{rd_cp15_crn13_tpidrurw_ns}})                           |
                                             (cp_tpidruro          & {32{rd_cp15_crn13_tpidruro_s}})                            |
                                             (cp_tpidruro_ns[31:0] & {32{rd_cp15_crn13_tpidruro_ns}})                           |
                                             (cp_tpidrprw          & {32{rd_cp15_crn13_tpidrprw_s}})                            |
                                             (cp_tpidrprw_ns[31:0] & {32{rd_cp15_crn13_tpidrprw_ns}})                           |
                                             (cp_cbar              & {32{rd_cp15_cbar}})                                        |
                                             (cp_fpsid             & {32{rd_cp10_fpsid}})                                       |
                                             (cp_fpscr_rd          & {32{rd_cp10_fpscr}}))})                                    |
                                            ((cp_aa64pfr0          & {64{rd_cp15_crn0_id_aa64pfr0}})                            | //64-bit registers
                                             (cp_aa64pfr1          & {64{rd_cp15_crn0_id_aa64pfr1}})                            |
                                             (cp_aa64dfr0          & {64{rd_cp15_crn0_id_aa64dfr0}})                            |
                                             (cp_aa64dfr1          & {64{rd_cp15_crn0_id_aa64dfr1}})                            |
                                             (cp_aa64afr0          & {64{rd_cp15_crn0_id_aa64afr0}})                            |
                                             (cp_aa64afr1          & {64{rd_cp15_crn0_id_aa64afr1}})                            |
                                             (cp_aa64isar0         & {64{rd_cp15_crn0_id_aa64isar0}})                           |
                                             (cp_aa64isar1         & {64{rd_cp15_crn0_id_aa64isar1}})                           |
                                             (cp_aa64mmfr0         & {64{rd_cp15_crn0_id_aa64mmfr0}})                           |
                                             (cp_aa64mmfr1         & {64{rd_cp15_crn0_id_aa64mmfr1}})                           |
                                             (cp_vmpidr_el2        & {64{rd_cp15_crn0_vmpidr_el2}})                             |
                                             (cp_hcr_el2           & {64{rd_cp15_crn1_hcr_el2}})                                |
                                             (cp_cpuactlr          & {64{rd_cp15_crn1_cpuactlr}})                               |
                                             (cp_far_el1           & {64{rd_cp15_crn6_far_el1}})                                |
                                             (cp_far_el2           & {64{rd_cp15_crn6_far_el2}})                                |
                                             (cp_far_el3           & {64{rd_cp15_crn6_far_el3}})                                |
                                             (cp_rvbar_el3         & {64{rd_cp15_crn6_rvbar_el3}})                              |
                                             (cp_vbar_el1          & {64{rd_cp15_crn12_vbar_el1}})                              |
                                             (cp_vbar_el2          & {64{rd_cp15_crn12_vbar_el2}})                              |
                                             (cp_vbar_el3          & {64{rd_cp15_crn12_vbar_el3}})                              |
                                             (cp_tpidruro_ns       & {64{rd_cp15_crn13_tpidrro_el0}})                           |
                                             (cp_tpidrurw_ns       & {64{rd_cp15_crn13_tpidr_el0}})                             |
                                             (cp_tpidrprw_ns       & {64{rd_cp15_crn13_tpidr_el1}})                             |
                                             (cp_htpidr            & {64{rd_cp15_crn13_tpidr_el2}})                             |
                                             (cp_tpidr_el3         & {64{rd_cp15_crn13_tpidr_el3}})                             |
                                             (cp_cbar_el1          & {64{rd_cp15_cbar_el1}})                                    |
                                             (cp_cpumerrsr         & {64{rd_cp15_cpumerrsr}}));



  // If the MRC operation reads registers outside of the DPU the result
  // is read from the DCU load data bus
  assign cp_read_data_ext_wr = {64{rd_cp15_external}} & dcu_ld_data_dc3_i[63:0];

  //-------------------------------------------------------
  // SCTLR signal muxing
  //-------------------------------------------------------
  // Select between different SCTLRs to drive system control signals

  always @*
    case (dpu_exception_level_i)
      `CA53_EL3: begin
        sctlr_icache_on   = cp_sctlr_el3_i;
        sctlr_dcache_on   = cp_sctlr_el3_c;
        sctlr_align_check = cp_sctlr_el3_a;
        sctlr_itd         = cp_sctlr_el3_itd;
        sctlr_ntwe_o      = 1'b1; // Does not apply at EL3
        sctlr_ntwi_o      = 1'b1; // Does not apply at EL3
        sctlr_cp15ben_o   = cp_sctlr_el3_cp15ben;
        sctlr_sed_o       = cp_sctlr_el3_sed;
        dpu_mmu_on        = cp_sctlr_el3_m;
        dpu_hivecs_o      = cp_sctlr_el3_v;
      end
      `CA53_EL2: begin
        sctlr_icache_on   = cp_sctlr_el2_i;
        sctlr_dcache_on   = cp_sctlr_el2_c;
        sctlr_align_check = cp_sctlr_el2_a;
        sctlr_itd         = cp_sctlr_el2_itd;
        sctlr_ntwe_o      = 1'b1; // Does not apply at EL2
        sctlr_ntwi_o      = 1'b1; // Does not apply at EL2
        sctlr_cp15ben_o   = cp_sctlr_el2_cp15ben;
        sctlr_sed_o       = cp_sctlr_el2_sed;
        dpu_mmu_on        = cp_sctlr_el2_m;
        dpu_hivecs_o      = 1'b0; // Ignored by TLB in EL2
      end
      `CA53_EL1: begin
        sctlr_icache_on   = cp_sctlr_el1_i;
        sctlr_dcache_on   = cp_sctlr_el1_c;
        sctlr_align_check = cp_sctlr_el1_a;
        sctlr_itd         = cp_sctlr_el1_itd;
        sctlr_ntwe_o      = 1'b1; // Does not apply at EL1
        sctlr_ntwi_o      = 1'b1; // Does not apply at EL2
        sctlr_cp15ben_o   = cp_sctlr_el1_cp15ben;
        sctlr_sed_o       = cp_sctlr_el1_sed;
        dpu_mmu_on        = cp_sctlr_el1_m;
        dpu_hivecs_o      = cp_sctlr_el1_v;
      end
      `CA53_EL0: begin
        // When EL3 is AA32, Secure EL0 uses SCTLR.S (i.e. SCTLR_EL3), otherwise use SCTLR_EL1
        case ({ns_state_i, aarch64_at_el3})
          2'b00: begin  // Secure EL0 with AA32 EL3
            sctlr_icache_on   = cp_sctlr_el3_i;
            sctlr_dcache_on   = cp_sctlr_el3_c;
            sctlr_align_check = cp_sctlr_el3_a;
            sctlr_itd         = cp_sctlr_el3_itd;
            sctlr_ntwe_o      = cp_sctlr_el3_ntwe;
            sctlr_ntwi_o      = cp_sctlr_el3_ntwi;
            sctlr_cp15ben_o   = cp_sctlr_el3_cp15ben;
            sctlr_sed_o       = cp_sctlr_el3_sed;
            dpu_mmu_on        = cp_sctlr_el3_m;
            dpu_hivecs_o      = cp_sctlr_el3_v;
          end
          2'b01,        // Secure EL0 with AA64 EL3
          2'b10,        // non-secure EL0
          2'b11: begin  // non-secure EL0
            sctlr_icache_on   = cp_sctlr_el1_i;
            sctlr_dcache_on   = cp_sctlr_el1_c;
            sctlr_align_check = cp_sctlr_el1_a;
            sctlr_itd         = cp_sctlr_el1_itd;
            sctlr_ntwe_o      = cp_sctlr_el1_ntwe;
            sctlr_ntwi_o      = cp_sctlr_el1_ntwi;
            sctlr_cp15ben_o   = cp_sctlr_el1_cp15ben;
            sctlr_sed_o       = cp_sctlr_el1_sed;
            dpu_mmu_on        = cp_sctlr_el1_m & ~(cp_hcr_tge & ns_state_i);
            dpu_hivecs_o      = cp_sctlr_el1_v;
          end
          default: begin
            sctlr_icache_on   = 1'bx;
            sctlr_dcache_on   = 1'bx;
            sctlr_align_check = 1'bx;
            sctlr_itd         = 1'bx;
            sctlr_ntwe_o      = 1'bx;
            sctlr_ntwi_o      = 1'bx;
            sctlr_cp15ben_o   = 1'bx;
            sctlr_sed_o       = 1'bx;
            dpu_mmu_on        = 1'bx;
            dpu_hivecs_o      = 1'bx;
          end
        endcase
      end
      default: begin
        sctlr_icache_on   = 1'bx;
        sctlr_dcache_on   = 1'bx;
        sctlr_align_check = 1'bx;
        sctlr_itd         = 1'bx;
        sctlr_ntwe_o      = 1'bx;
        sctlr_ntwi_o      = 1'bx;
        sctlr_cp15ben_o   = 1'bx;
        sctlr_sed_o       = 1'bx;
        dpu_mmu_on        = 1'bx;
        dpu_hivecs_o      = 1'bx;
      end
    endcase

  // Simpler term used for DACR, as doesn't apply in Hyp or AArch64

  assign dpu_dacr_o        = (last_ns_state | aarch64_at_el3) ? cp_dacr_ns                                       : cp_dacr;
  assign dpu_dacr_mmu_on_o = (last_ns_state | aarch64_at_el3) ? (cp_sctlr_el1_m & ~(cp_hcr_tge & last_ns_state)) : cp_sctlr_el3_m;


  // Combine SCTLR.I bit with HCR signals to determine final I cache on signal
  assign dpu_icache_on = (sctlr_icache_on | (cp_hcr_dc & ns_not_hyp)) &
                         ~(cp_hcr_id & (cp_hcr_vm | cp_hcr_dc) & ns_not_hyp);

  // ------------------------------------------------------
  // State propagation registers
  // ------------------------------------------------------

  // Local re-registering of state is required both to detect state changes that require
  // a micro-TLB flush and to improve timing on signals in the main decoders or signals
  // such as DCache-on.  We over-enable using the flush_utlb signal to prevent corner
  // cases that could result in the flush signal being constantly asserted.
  assign nxt_tlb_abandon  = wr_cp15_crn1_hsctlr | wr_cp15_crn1_sctlr_s | wr_cp15_crn1_sctlr_ns | wr_cp15_crn1_hcr | wr_cp15_crn1_hcr2 |
                            wr_cp15_crn1_sctlr_el2 | wr_cp15_crn1_sctlr_el3 | wr_cp15_crn1_sctlr_el1 | wr_cp15_crn1_hcr_el2 |
                            wr_cp15_crn1_scr | expt_mon_mode_clear_ns_i;

  // To improve power a clock gate enable is generated, but it is not realistic for this
  // to be applied to every register.
  assign nxt_local_state_en = load_initial | (raw_cp_valid_wr & raw_cp_decode_wr[8]) | flush_wr_i | flush_utlb | in_halt_i;

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      last_ns_state      <= 1'b0;
      ns_state_de        <= 1'b1;
      tlb_abandon        <= 1'b0;
      raw_local_state_en <= 1'b1;
    end else begin
      last_ns_state      <= ns_state_i;
      ns_state_de        <= ns_state_i;
      tlb_abandon        <= nxt_tlb_abandon;
      raw_local_state_en <= nxt_local_state_en;
    end

  assign local_state_en = raw_local_state_en | flush_wr_i;

  // Hypervisor mode traps used by the main decoders.  Since any change to the security
  // state or entry/exit from HYP mode or debug state change requires a pipeline flush
  // there is time to register these signals before they are used in the decoders.
  assign ns_not_hyp        = ns_state_i & (dpu_exception_level_i < `CA53_EL2);

  // HCR
  assign nxt_hcr_fb        = cp_hcr_fb     &    ns_not_hyp;
  assign nxt_hcr_bsu       = cp_hcr_bsu    & {2{ns_not_hyp}};
  // - AMO, IMO, FMO for GIC need to factor in HCR.TGE
  assign nxt_hcr_amo       = cp_hcr_amo | cp_hcr_tge;
  assign nxt_hcr_imo       = cp_hcr_imo | cp_hcr_tge;
  assign nxt_hcr_fmo       = cp_hcr_fmo | cp_hcr_tge;

  assign nxt_s2_dcache_on = ~(cp_hcr_cd & (cp_hcr_vm | cp_hcr_dc));

  always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      last_sctlr_dcache_on     <= 1'b0;
      last_dpu_mmu_on          <= 1'b0;
      last_cp_hcr_vm           <= 1'b0;
      hcr_bsu                  <= 2'b00;
      hcr_fb                   <= 1'b0;
      hcr_amo                  <= 1'b0;
      hcr_imo                  <= 1'b0;
      hcr_fmo                  <= 1'b0;
      s2_dcache_on             <= 1'b0;
    end else if (local_state_en) begin
      last_sctlr_dcache_on     <= sctlr_dcache_on;
      last_dpu_mmu_on          <= dpu_mmu_on;
      last_cp_hcr_vm           <= cp_hcr_vm;
      hcr_bsu                  <= nxt_hcr_bsu;
      hcr_fb                   <= nxt_hcr_fb;
      hcr_amo                  <= nxt_hcr_amo;
      hcr_imo                  <= nxt_hcr_imo;
      hcr_fmo                  <= nxt_hcr_fmo;
      s2_dcache_on             <= nxt_s2_dcache_on;
    end

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      last_sctlr_itd  <= 1'b0;
    else if (dpu_fe_valid_ret_i)
      last_sctlr_itd  <= sctlr_itd;

  // ------------------------------------------------------
  // Flush micro-TLB
  // ------------------------------------------------------

  assign nxt_flush_utlb = (wr_cp15_crn1_scr       |
                           wr_cp15_crn1_sctlr_s   |
                           wr_cp15_crn1_sctlr_ns  |
                           wr_cp15_crn1_hsctlr    |
                           wr_cp15_crn1_sctlr_el1 |
                           wr_cp15_crn1_sctlr_el2 |
                           wr_cp15_crn1_sctlr_el3 |
                           wr_cp15_crn1_hcr       |
                           wr_cp15_crn1_hcr2      |
                           wr_cp15_crn1_hcr_el2   |
                           wr_cp15_crn3_dacr_s    |
                           wr_cp15_crn3_dacr_ns);

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      raw_flush_utlb <= 1'b0;
    else
      raw_flush_utlb <= nxt_flush_utlb;

  assign flush_utlb = (last_ns_state ^ ns_state_i) | raw_flush_utlb;

  // ------------------------------------------------------
  // Exception decoder control signals
  // ------------------------------------------------------
  //
  // Create signals for use in the Iss stage exception decoder
  assign expt_cpacr_el1_fpen_o = cpacr_el1_fpen_rd;
  assign expt_cpacr_asedis_o   = (cpacr_asedis   & ~aarch64_state_i & ~aarch64_at_el1) | nsasedis;
  assign expt_cptr_el2_tfp_o   = (cptr_el2_tfp   & ns_state_i)                         | nsfpudis;
  assign expt_hcptr_tase_o     = (hcptr_tase     & ns_state_i       & ~aarch64_at_el2) | nsasedis;
  assign expt_cptr_el2_tcpac_o = (cptr_el2_tcpac & ns_state_i);

  // Determine if FP/Neon instructions will cause traps at the current
  // exception level, so that slot 1 issue of these instructions can be
  // suppressed
  assign nxt_cp_trap_fp   = ((dpu_exception_level_i == `CA53_EL0) & (cpacr_el1_fpen_rd != 2'b11))             |
                            ((dpu_exception_level_i == `CA53_EL1) & ~cpacr_el1_fpen_rd[0])                    |
                            ((dpu_exception_level_i == `CA53_EL3) & ~cpacr_el1_fpen_rd[0] & ~aarch64_state_i) |
                            (~cp_fpexc_en & ~aarch64_state_i & ~aarch64_at_el1)                               |
                            (cptr_el2_tfp & ns_state_i)                                                       | 
                            nsfpudis                                                                          |
                            cptr_el3_tfp;

  // Only considers terms other than those above
  assign nxt_cp_trap_neon = ((dpu_exception_level_i != `CA53_EL2) & cpacr_asedis & ~aarch64_state_i & ~aarch64_at_el1) |
                            (hcptr_tase & ns_state_i & ~aarch64_at_el2)                                                | 
                            nsasedis;

  always @(posedge clk) begin
    cp_trap_fp_o   <= nxt_cp_trap_fp;
    cp_trap_neon_o <= nxt_cp_trap_neon;
  end

  //-------------------------------------------------------
  // Connect Internal Signals to Outputs.
  //-------------------------------------------------------

  assign mcr_data_wr_o                              = mcr_data_wr;
  assign mrc_data_wr_o                              = mrc_data_wr;
  assign cp_valid_ex2_o                             = cp_valid_ex2;
  assign nxt_cp_valid_wr_o                          = nxt_cp_valid_wr;
  assign cp_valid_wr_o                              = cp_valid_wr;
  assign raw_cp_valid_wr_o                          = raw_cp_valid_wr;
  assign raw_cp_decode_wr_o                         = raw_cp_decode_wr;
  assign cp15_pmu_access_wr_o                       = cp15_pmu_access_wr;
  assign force_clean_to_invalidate_o                = force_clean_to_invalidate;
  assign disable_dual_issue_o                       = disable_dual_issue;
  assign disable_fp_dual_issue_o                    = disable_fp_dual_issue;
  assign dpu_l1deien_o                              = dpu_l1deien;
  assign dpu_disable_dmb_o                          = dpu_disable_dmb;
  assign dpu_disable_device_split_throttle_o        = dpu_disable_device_split_throttle;
  assign dpu_enable_data_prefetch_o                 = dpu_enable_data_prefetch;
  assign dpu_enable_data_prefetch_streams_o         = dpu_enable_data_prefetch_streams;
  assign dpu_data_prefetch_stride_detect_o          = dpu_data_prefetch_stride_detect;
  assign dpu_disable_data_prefetch_stores_pattern_o = dpu_disable_data_prefetch_stores_pattern;
  assign dpu_disable_data_prefetch_readunique_o     = dpu_disable_data_prefetch_readunique;
  assign dpu_disable_no_allocate_o                  = dpu_disable_no_allocate;
  assign dpu_ramode_cnt_l1_o                        = dpu_ramode_cnt_l1;
  assign dpu_ramode_cnt_l2_o                        = dpu_ramode_cnt_l2;
  assign dpu_smp_en_o                               = dpu_smp_en;
  assign dpu_icache_on_o                            = dpu_icache_on;
  assign flush_d_utlb_o                             = flush_utlb;
  assign flush_i_utlb_o                             = flush_utlb;
  assign tlb_abandon_o                              = tlb_abandon;
  assign dpu_access_flag_enable_el3_o               = cp_sctlr_el3_afe;
  assign dpu_access_flag_enable_el1_o               = cp_sctlr_el1_afe;
  assign dpu_tex_remap_enable_el1_o                 = cp_sctlr_el1_tre;
  assign dpu_tex_remap_enable_el3_o                 = cp_sctlr_el3_tre;
  assign dpu_dcache_on_o                            = last_sctlr_dcache_on;
  assign dpu_s2_dcache_on_o                         = s2_dcache_on;
  assign dpu_mmu_on_o                               = last_dpu_mmu_on;
  assign dpu_mmu_on_el1_o                           = cp_sctlr_el1_m & ~(cp_hcr_tge & cp_scr_ns);
  assign dpu_mmu_on_el2_o                           = cp_sctlr_el2_m;
  assign dpu_mmu_on_el3_o                           = cp_sctlr_el3_m;
  assign dpu_dcache_on_el1_o                        = cp_sctlr_el1_c;
  assign dpu_dcache_on_el2_o                        = cp_sctlr_el2_c;
  assign dpu_dcache_on_el3_o                        = cp_sctlr_el3_c;
  assign dpu_default_cacheable_o                    = cp_hcr_dc;
  assign dpu_ipa_to_pa_en_o                         = last_cp_hcr_vm;
  assign dpu_pr_tablewalk_o                         = cp_hcr_ptw;
  assign dpu_dacr_ns_o                              = cp_dacr_ns;
  assign dpu_sctlr_wxn_el1_o                        = cp_sctlr_el1_wxn;
  assign dpu_sctlr_wxn_el2_o                        = cp_sctlr_el2_wxn;
  assign dpu_sctlr_wxn_el3_o                        = cp_sctlr_el3_wxn;
  assign dpu_sctlr_uwxn_el1_o                       = cp_sctlr_el1_uwxn;
  assign dpu_sctlr_uwxn_el3_o                       = cp_sctlr_el3_uwxn;
  assign dpu_sctlr_itd_o                            = last_sctlr_itd;
  assign dpu_throttle_enable_o                      = ~dpu_throttle_disable;
  assign cptr_el3_tcpac_o                           = cptr_el3_tcpac;
  assign cptr_el3_tfp_o                             = cptr_el3_tfp;
  assign hcr_trvm_o                                 = cp_hcr_trvm;
  assign hcr_tdz_o                                  = cp_hcr_tdz;
  assign hcr_fb_o                                   = hcr_fb;
  assign hcr_bsu_o                                  = hcr_bsu;
  assign hcr_twi_o                                  = cp_hcr_twi;
  assign hcr_twe_o                                  = cp_hcr_twe;
  assign hcr_tid0_o                                 = cp_hcr_tid0;
  assign hcr_tid1_o                                 = cp_hcr_tid1;
  assign hcr_tid2_o                                 = cp_hcr_tid2;
  assign hcr_tid3_o                                 = cp_hcr_tid3;
  assign hcr_tsc_o                                  = cp_hcr_tsc;
  assign hcr_tidcp_o                                = cp_hcr_tidcp;
  assign hcr_tacr_o                                 = cp_hcr_tacr;
  assign hcr_tsw_o                                  = cp_hcr_tsw;
  assign hcr_tpc_o                                  = cp_hcr_tpc;
  assign hcr_tpu_o                                  = cp_hcr_tpu;
  assign hcr_ttlb_o                                 = cp_hcr_ttlb;
  assign hcr_tvm_o                                  = cp_hcr_tvm;
  assign hcr_tge_o                                  = cp_hcr_tge;
  assign hcr_va_o                                   = cp_hcr_va;
  assign hcr_vi_o                                   = cp_hcr_vi;
  assign hcr_vf_o                                   = cp_hcr_vf;
  assign hcr_amo_o                                  = hcr_amo;  // Use registered versions of AMO, IMO, FMO with HCR.TGE factored in
  assign hcr_imo_o                                  = hcr_imo;
  assign hcr_fmo_o                                  = hcr_fmo;
  assign hdcr_tdra_o                                = cp_hdcr_tdra  | cp_hdcr_tde | cp_hcr_tge;
  assign hdcr_tdosa_o                               = cp_hdcr_tdosa | cp_hdcr_tde | cp_hcr_tge;
  assign hdcr_tda_o                                 = cp_hdcr_tda   | cp_hdcr_tde | cp_hcr_tge;
  assign hdcr_tde_o                                 = cp_hdcr_tde | cp_hcr_tge;
  assign hdcr_tpm_o                                 = cp_hdcr_tpm;
  assign hdcr_tpmcr_o                               = cp_hdcr_tpmcr;
  assign hdcr_hpme_o                                = cp_hdcr_hpme;
  assign hdcr_hpmn_o                                = cp_hdcr_hpmn;
  assign mdcr_el3_tdosa_o                           = cp_mdcr_el3_tdosa;
  assign mdcr_el3_tda_o                             = cp_mdcr_el3_tda;
  assign mdcr_el3_tpm_o                             = cp_mdcr_el3_tpm;
  assign hstr_trap_cp15_o                           = cp_hstr[13:0];
  assign sctlr_ns_hivecs_o                          = cp_sctlr_el1_v;
  assign sctlr_s_hivecs_o                           = cp_sctlr_el3_v;
  assign sctlr_sa_at_el_o                           = {cp_sctlr_el3_sa, cp_sctlr_el2_sa, cp_sctlr_el1_sa, cp_sctlr_el1_sa0};
  assign sctlr_align_check_o                        = sctlr_align_check;
  assign sctlr_endian_el3_o                         = cp_sctlr_el3_ee;
  assign sctlr_endian_el1_o                         = cp_sctlr_el1_ee;
  assign sctlr_endian_el2_o                         = cp_sctlr_el2_ee;
  assign sctlr_el1_e0e_o                            = cp_sctlr_el1_e0e;
  assign sctlr_el3_itd_o                            = cp_sctlr_el3_itd;
  assign sctlr_el2_itd_o                            = cp_sctlr_el2_itd;
  assign sctlr_el1_itd_o                            = cp_sctlr_el1_itd;
  assign sctlr_el1_uct_o                            = cp_sctlr_el1_uct;
  assign sctlr_el1_uci_o                            = cp_sctlr_el1_uci;
  assign sctlr_el1_uma_o                            = cp_sctlr_el1_uma;
  assign sctlr_el1_dze_o                            = cp_sctlr_el1_dze;
  assign sctlr_ns_te_o                              = cp_sctlr_el1_te;
  assign sctlr_s_te_o                               = cp_sctlr_el3_te;
  assign hsctlr_te_o                                = cp_sctlr_el2_te;
  assign aarch64_at_el_o                            = {aarch64_at_el3, aarch64_at_el2, aarch64_at_el1};
  assign dpu_warmrstreq_o                           = cp_rmr_el3_rr;
  assign cp_vbar_el3_o                              = cp_vbar[63:5];
  assign cp_vbar_el1_o                              = cp_vbar_ns[63:5];
  assign cp_mvbar_o                                 = cp_mvbar[31:5];
  assign cp_hvbar_o                                 = cp_hvbar[63:5];
  assign dpu_sif_only_o                             = cp_scr_sif & ~ns_state_i;
  assign scr_twi_o                                  = cp_scr_twi;
  assign scr_twe_o                                  = cp_scr_twe;
  assign scr_st_o                                   = cp_scr_st;
  assign scr_hce_o                                  = cp_scr_hce;
  assign scr_smd_o                                  = cp_scr_smd;
  assign scr_aw_o                                   = cp_scr_aw;
  assign scr_fw_o                                   = cp_scr_fw;
  assign scr_ea_o                                   = cp_scr_ea;
  assign scr_fiq_o                                  = cp_scr_fiq;
  assign scr_irq_o                                  = cp_scr_irq;
  assign ns_scr_o                                   = cp_scr_ns;
  assign nxt_ns_scr_o                               = nxt_cp_scr_ns;
  assign wr_scr_o                                   = wr_cp15_crn1_scr;
  assign ns_state_de_o                              = ns_state_de;
  assign cp_sder_o                                  = cp_sder[1:0];
  assign cp_icimvau_o                               = wr_cp15_crn7_icimvau & raw_cp_valid_wr;
  assign dpu_cpuectlr_cpu_ret_delay_o               = cpu_ret[2:0];
  assign dpu_cpuectlr_neon_ret_delay_o              = dpu_simd_ret[2:0];
  assign cp_fpexc_en_o                              = cp_fpexc_en;
  assign cp_mdcr_el3_sdd_o                          = cp_mdcr_el3_sdd;
  assign cp_mdcr_el3_spd32_o                        = cp_mdcr_el3_spd32;
  assign cp_mdcr_el3_spme_o                         = cp_mdcr_el3_spme;
  assign cp_mdcr_el3_epmad_o                        = cp_mdcr_el3_epmad;
  assign cp_mdcr_el3_edad_o                         = cp_mdcr_el3_edad;
  assign cpuactlr_el3_o                             = cpuactlr_el3;
  assign cpuectlr_el3_o                             = cpuectlr_el3;
  assign l2ctlr_el3_o                               = l2ctlr_el3;
  assign l2ectlr_el3_o                              = l2ectlr_el3;
  assign l2actlr_el3_o                              = l2actlr_el3;
  assign cpuactlr_el2_o                             = cpuactlr_el2;
  assign cpuectlr_el2_o                             = cpuectlr_el2;
  assign l2ctlr_el2_o                               = l2ctlr_el2;
  assign l2ectlr_el2_o                              = l2ectlr_el2;
  assign l2actlr_el2_o                              = l2actlr_el2;
  assign cryptodisable_o                            = cryptodisable;
  assign giccdisable_o                              = giccdisable;

//------------------------------------------------------------------------------
// OVL Assertions
//------------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn0_vpidr")
  u_ovl_x_wr_cp15_crn0_vpidr (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_cp15_crn0_vpidr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_decode_ex2_en")
  u_ovl_x_cp_decode_ex2_en (.clk       (clk_cp15_ctl),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp_decode_ex2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_decode_iss_en")
  u_ovl_x_cp_decode_iss_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp_decode_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_decode_wr_en")
  u_ovl_x_cp_decode_wr_en (.clk       (clk_cp15_ctl),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_decode_wr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_esr_el1_en")
  u_ovl_x_cp_esr_el1_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_esr_el1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_esr_el3_en")
  u_ovl_x_cp_esr_el3_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_esr_el3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_far_el1_lower_en")
  u_ovl_x_cp_far_el1_lower_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (cp_far_el1_lower_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_far_el1_upper_en")
  u_ovl_x_cp_far_el1_upper_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (cp_far_el1_upper_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_far_el2_lower_en")
  u_ovl_x_cp_far_el2_lower_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (cp_far_el2_lower_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_far_el2_upper_en")
  u_ovl_x_cp_far_el2_upper_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (cp_far_el2_upper_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_far_el3_en")
  u_ovl_x_cp_far_el3_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_far_el3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_hcr2_en")
  u_ovl_x_cp_hcr2_en (.clk       (clk_cp15),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (cp_hcr2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_hcr_en")
  u_ovl_x_cp_hcr_en (.clk       (clk_cp15),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (cp_hcr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_hcr_va_en")
  u_ovl_x_cp_hcr_va_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (cp_hcr_va_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_htpidr_en_lo")
  u_ovl_x_cp_htpidr_en_lo (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_htpidr_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_hvbar_en_lo")
  u_ovl_x_cp_hvbar_en_lo (.clk       (clk_cp15),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (cp_hvbar_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_rmr_el3_aa64_en")
  u_ovl_x_cp_rmr_el3_aa64_en (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (cp_rmr_el3_aa64_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_scr_en")
  u_ovl_x_cp_scr_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (cp_scr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_sctlr_el1_en")
  u_ovl_x_cp_sctlr_el1_en (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_sctlr_el1_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_sctlr_el2_en")
  u_ovl_x_cp_sctlr_el2_en (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_sctlr_el2_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_sctlr_el3_en")
  u_ovl_x_cp_sctlr_el3_en (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_sctlr_el3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_tpidrprw_ns_en_lo")
  u_ovl_x_cp_tpidrprw_ns_en_lo (.clk       (clk_cp15),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (cp_tpidrprw_ns_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_tpidruro_ns_en_lo")
  u_ovl_x_cp_tpidruro_ns_en_lo (.clk       (clk_cp15),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (cp_tpidruro_ns_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_tpidrurw_ns_en_lo")
  u_ovl_x_cp_tpidrurw_ns_en_lo (.clk       (clk_cp15),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (cp_tpidrurw_ns_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_valid_en")
  u_ovl_x_cp_valid_en (.clk       (clk_cp15_ctl),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (cp_valid_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_valid_iss_en")
  u_ovl_x_cp_valid_iss_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp_valid_iss_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_vbar_en_lo")
  u_ovl_x_cp_vbar_en_lo (.clk       (clk_cp15),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (cp_vbar_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_vbar_ns_en_lo")
  u_ovl_x_cp_vbar_ns_en_lo (.clk       (clk_cp15),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp_vbar_ns_en_lo));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_vmpidr_aff3_en")
  u_ovl_x_cp_vmpidr_aff3_en (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (cp_vmpidr_aff3_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_vmpidr_en")
  u_ovl_x_cp_vmpidr_en (.clk       (clk_cp15),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (cp_vmpidr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: last_load_initial")
  u_ovl_x_last_load_initial (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (last_load_initial));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial")
  u_ovl_x_load_initial (.clk       (clk_cp15),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (load_initial));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_cold")
  u_ovl_x_load_initial_cold (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (load_initial_cold));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: local_state_en")
  u_ovl_x_local_state_en (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (local_state_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nxt_cp_valid_ex1")
  u_ovl_x_nxt_cp_valid_ex1 (.clk       (clk_cp15_ctl),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (nxt_cp_valid_ex1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn0_csselr_ns")
  u_ovl_x_wr_cp15_crn0_csselr_ns (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn0_csselr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn0_csselr_s")
  u_ovl_x_wr_cp15_crn0_csselr_s (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn0_csselr_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn12_mvbar")
  u_ovl_x_wr_cp15_crn12_mvbar (.clk       (clk_cp15),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_cp15_crn12_mvbar));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn12_rmr_el3")
  u_ovl_x_wr_cp15_crn12_rmr_el3 (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn12_rmr_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn12_vbar_el1")
  u_ovl_x_wr_cp15_crn12_vbar_el1 (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn12_vbar_el1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn12_vbar_el2")
  u_ovl_x_wr_cp15_crn12_vbar_el2 (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn12_vbar_el2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn12_vbar_el3")
  u_ovl_x_wr_cp15_crn12_vbar_el3 (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn12_vbar_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidr_el0")
  u_ovl_x_wr_cp15_crn13_tpidr_el0 (.clk       (clk_cp15),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (wr_cp15_crn13_tpidr_el0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidr_el1")
  u_ovl_x_wr_cp15_crn13_tpidr_el1 (.clk       (clk_cp15),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (wr_cp15_crn13_tpidr_el1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidr_el2")
  u_ovl_x_wr_cp15_crn13_tpidr_el2 (.clk       (clk_cp15),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (wr_cp15_crn13_tpidr_el2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidr_el3")
  u_ovl_x_wr_cp15_crn13_tpidr_el3 (.clk       (clk_cp15),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (wr_cp15_crn13_tpidr_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidrprw_s")
  u_ovl_x_wr_cp15_crn13_tpidrprw_s (.clk       (clk_cp15),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (wr_cp15_crn13_tpidrprw_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidrro_el0")
  u_ovl_x_wr_cp15_crn13_tpidrro_el0 (.clk       (clk_cp15),
                                     .reset_n   (reset_n),
                                     .qualifier (1'b1),
                                     .test_expr (wr_cp15_crn13_tpidrro_el0));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidruro_s")
  u_ovl_x_wr_cp15_crn13_tpidruro_s (.clk       (clk_cp15),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (wr_cp15_crn13_tpidruro_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn13_tpidrurw_s")
  u_ovl_x_wr_cp15_crn13_tpidrurw_s (.clk       (clk_cp15),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (wr_cp15_crn13_tpidrurw_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_actlr_el2")
  u_ovl_x_wr_cp15_crn1_actlr_el2 (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn1_actlr_el2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_actlr_el3")
  u_ovl_x_wr_cp15_crn1_actlr_el3 (.clk       (clk_cp15),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (wr_cp15_crn1_actlr_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_cptr_el3")
  u_ovl_x_wr_cp15_crn1_cptr_el3 (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn1_cptr_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_cpuactlr")
  u_ovl_x_wr_cp15_crn1_cpuactlr (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn1_cpuactlr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_cpuectlr")
  u_ovl_x_wr_cp15_crn1_cpuectlr (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn1_cpuectlr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_hcptr")
  u_ovl_x_wr_cp15_crn1_hcptr (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_cp15_crn1_hcptr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_hdcr")
  u_ovl_x_wr_cp15_crn1_hdcr (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_cp15_crn1_hdcr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_hstr")
  u_ovl_x_wr_cp15_crn1_hstr (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_cp15_crn1_hstr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_mdcr_el3")
  u_ovl_x_wr_cp15_crn1_mdcr_el3 (.clk       (clk_cp15),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (wr_cp15_crn1_mdcr_el3));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_nsacr")
  u_ovl_x_wr_cp15_crn1_nsacr (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_cp15_crn1_nsacr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn1_sder")
  u_ovl_x_wr_cp15_crn1_sder (.clk       (clk_cp15),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (wr_cp15_crn1_sder));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn3_dacr_ns")
  u_ovl_x_wr_cp15_crn3_dacr_ns (.clk       (clk_cp15),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (wr_cp15_crn3_dacr_ns));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn3_dacr_s")
  u_ovl_x_wr_cp15_crn3_dacr_s (.clk       (clk_cp15),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (wr_cp15_crn3_dacr_s));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_cp15_crn5_fpexc")
  u_ovl_x_wr_cp15_crn5_fpexc (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (wr_cp15_crn5_fpexc));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: dpu_fe_valid_ret_i")
  u_ovl_x_dpu_fe_valid_ret_i (.clk       (clk_cp15),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (dpu_fe_valid_ret_i));

  generate if (NEON_FP) begin : ovl_neon

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_cp_fpcr")
  u_ovl_x_en_cp_fpcr (.clk       (clk_cp15),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (g_fpscr.en_cp_fpcr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_cp_fpsr")
  u_ovl_x_en_cp_fpsr (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (g_fpscr.en_cp_fpsr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpacr_cp11_en")
  u_ovl_x_cpacr_cp11_en (.clk       (clk_cp15),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (FPU2.cpacr_cp11_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cpacr_asedis_en")
  u_ovl_x_cpacr_asedis_en (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (FPU2.cpacr_asedis_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hcptr_tase_en")
  u_ovl_x_hcptr_tase_en (.clk       (clk_cp15),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (FPU3.hcptr_tase_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hcptr_tcp11_en")
  u_ovl_x_hcptr_tcp11_en (.clk       (clk_cp15),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (FPU3.hcptr_tcp11_en));
  end endgenerate

  generate if (CPU_CACHE_PROTECTION) begin : ovl_ecc

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cpumerrsr_valid_rs_en")
  u_ovl_x_cp_cpumerrsr_valid_rs_en (.clk       (clk_cp15),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (CPU_CACHE_PROTECTION_CONFIG.cp_cpumerrsr_valid_rs_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cpumerrsr_data_rs_en")
  u_ovl_x_cp_cpumerrsr_data_rs_en (.clk       (clk_cp15),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (CPU_CACHE_PROTECTION_CONFIG.cp_cpumerrsr_data_rs_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_cpumerrsr_en")
  u_ovl_x_cp_cpumerrsr_en (.clk       (clk_cp15),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (CPU_CACHE_PROTECTION_CONFIG.cp_cpumerrsr_en));

  end endgenerate

  //----------------------------------------------------------------------------
  // OVL_ASSERT: I-Cache size mask is illegal value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"I-Cache size mask is illegal value")
    ovl_icache_size_ill (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (cp_valid_wr & rd_cp15_crn0_id_ccsidr),
                         .consequent_expr ((ic_size_i == 3'b000) |
                                           (ic_size_i == 3'b001) |
                                           (ic_size_i == 3'b011) |
                                           (ic_size_i == 3'b111)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // OVL_ASSERT: D-Cache size mask is illegal value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"D-Cache size mask is illegal value")
    ovl_dcache_size_ill (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (cp_valid_wr & rd_cp15_crn0_id_ccsidr),
                         .consequent_expr ((dc_size_i == 3'b000) |
                                           (dc_size_i == 3'b001) |
                                           (dc_size_i == 3'b011) |
                                           (dc_size_i == 3'b111)));
  // OVL_ASSERT_END

generate if (L2_CACHE) begin : g_ovl_l2size
  //----------------------------------------------------------------------------
  // OVL_ASSERT: L2 Cache size mask is illegal value
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"L2 Cache size mask is illegal value")
    ovl_l2cache_size_ill (.clk             (clk),
                          .reset_n         (reset_n),
                          .antecedent_expr (cp_valid_wr & rd_cp15_crn0_id_ccsidr),
                          .consequent_expr ((l2_size == 4'b0000) |
                                            (l2_size == 4'b0001) |
                                            (l2_size == 4'b0011) |
                                            (l2_size == 4'b0111) |
                                            (l2_size == 4'b1111)));
  // OVL_ASSERT_END
end endgenerate

  //----------------------------------------------------------------------------
  // OVL_ASSERT: REVIDR can never be written
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"REVIDR written")
    ovl_revidr_written (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr (wr_cp15_crn0_revidr));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.2.b Access for Banked CP15 registers is allowed when
  // ns-bit is zero and in privileged modes.
  // OVL_ASSERT: ovl_tz_cp15_reg_secure_access, ovl_tz_cp15_reg_nsecure_access
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  wire secure_cp15_rd = (rd_cp15_crn0_csselr_s    | rd_cp15_crn1_sctlr_s     |
                         rd_cp15_crn5_dfsr_s      | rd_cp15_crn5_ifsr_s      |
                         rd_cp15_crn6_dfar_s      | rd_cp15_crn6_ifar_s      |
                         rd_cp15_crn12_vbar_s     | rd_cp15_crn13_tpidrurw_s |
                         rd_cp15_crn13_tpidruro_s | rd_cp15_crn13_tpidrprw_s) & cp_valid_wr;

  wire nsecure_cp15_rd = (rd_cp15_crn0_csselr_ns   | rd_cp15_crn1_sctlr_ns     |
                         rd_cp15_crn5_dfsr_ns      | rd_cp15_crn5_ifsr_ns      |
                         rd_cp15_crn6_dfar_ns      | rd_cp15_crn6_ifar_ns      |
                         rd_cp15_crn12_vbar_ns     | rd_cp15_crn13_tpidrurw_ns |
                         rd_cp15_crn13_tpidruro_ns | rd_cp15_crn13_tpidrprw_ns) & cp_valid_wr;

  wire secure_cp15_rd_wr = wr_cp15_crn0_csselr_s    | wr_cp15_crn1_sctlr_s     |
                           wr_cp15_crn5_dfsr_s      | wr_cp15_crn5_ifsr_s      |
                           wr_cp15_crn6_dfar_s      | wr_cp15_crn6_ifar_s      |
                           wr_cp15_crn12_vbar_s     | wr_cp15_crn13_tpidrurw_s |
                           wr_cp15_crn13_tpidruro_s | wr_cp15_crn13_tpidrprw_s |
                           secure_cp15_rd;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Access for Secure banked CP15 registers is allowed when ns-bit is zero and in privileged modes")
    ovl_tz_cp15_reg_secure_access (.clk             (clk),
                                   .reset_n         (reset_n),
                                   .antecedent_expr (secure_cp15_rd_wr),
                                   .consequent_expr (aarch64_state_i | (~aarch64_at_el3 & ~cp_scr_ns)));


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Access for Non-Secure banked CP15 registers is allowed when ns-bit is one and in privileged modes")
    ovl_tz_cp15_reg_nsecure_access (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .antecedent_expr ((wr_cp15_crn0_csselr_ns   | wr_cp15_crn1_sctlr_ns     |
                                                      wr_cp15_crn5_dfsr_ns      | wr_cp15_crn5_ifsr_ns      |
                                                      wr_cp15_crn6_dfar_ns      | wr_cp15_crn6_ifar_ns      |
                                                      wr_cp15_crn12_vbar_ns     | wr_cp15_crn13_tpidrurw_ns |
                                                      wr_cp15_crn13_tpidruro_ns | wr_cp15_crn13_tpidrprw_ns |
                                                      nsecure_cp15_rd) & ~aarch64_state_i),
                                    .consequent_expr (cp_scr_ns | aarch64_at_el3));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.2.c Access for Secure-Only CP15 registers is allowed
  // when ns-bit is zero and in privileged modes.
  // OVL_ASSERT: ovl_tz_secure_only_cp15_reg_access
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Access for  Secure-Only CP15 registers is allowed when ns-bit is one and in privileged modes")
    ovl_tz_el3_only_cp15_reg_access (.clk             (clk),
                                     .reset_n         (reset_n),
                                     .antecedent_expr ((cp_valid_wr & (rd_cp15_crn1_scr | rd_cp15_crn12_mvbar | rd_cp15_crn1_actlr_el3)) |
                                                       wr_cp15_crn1_scr | wr_cp15_crn1_nsacr | wr_cp15_crn12_mvbar | wr_cp15_crn1_actlr_el3),
                                     .consequent_expr (~ns_state_i & (dpu_exception_level_i == `CA53_EL3)));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Access for  Secure-Only CP15 registers is allowed when ns-bit is one and in privileged modes")
    ovl_tz_secure_only_cp15_reg_access (.clk             (clk),
                                        .reset_n         (reset_n),
                                        .antecedent_expr ((cp_valid_wr & rd_cp15_crn1_sder) | wr_cp15_crn1_sder),
                                        .consequent_expr (~ns_state_i & (dpu_exception_level_i != `CA53_EL0)));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.2.d Writes to asedis are ignored in Non-Secure state
  // when NSACR[15] (nsasedis) is asserted
  // OVL_ASSERT: ovl_tz_asedis_ns_wr_disable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  generate if (NEON_FP) begin : NEON5
    reg ovl_asedis;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      ovl_asedis <= 1'b0;
    else
      ovl_asedis <= FPU2.cpacr_asedis_internal;

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Writes to asedis are ignored in Non-Secure state when NSACR[15]=1'b1")
    ovl_tz_asedis_ns_wr_disable (.clk             (clk),
                                 .reset_n         (reset_n),
                                 .antecedent_expr (ns_state_i & nsacr_nsasedis),
                                 .consequent_expr (FPU2.cpacr_asedis_internal == ovl_asedis));
  end endgenerate

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Asedis has fixed value of one when in Non-Secure state and NSACR[15]=1'b1")
    ovl_tz_asedis_ns_fixed_value (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (ns_state_i & nsacr_nsasedis),
                                  .consequent_expr (cpacr_asedis_rd == 1'b1));
  // OVL_ASSERT_END

  //----------------------------------------------------------------------------
  // TrustZone OVL: 4.2.2.d Coprocessors 10 & 11 can be accessed only in secure
  // state when CPACR[23:20] (fpudis) are asserted
  // OVL_ASSERT: ovl_tz_fpudis_ns_wr_disable
  //----------------------------------------------------------------------------
  // OVL_ASSERT_RTL
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"Coprocessors 10 & 11 can be accessed only in secure state when CPACR[23:20] (fpudis) are asserted")
    ovl_tz_fpudis_ns_wr_disable (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .test_expr (ns_state_i & wr_cp15_crn1_cpacr & (nsacr_cp10==2'b11)));

  // OVL_ASSERT_END

`endif

endmodule // ca53dpu_cp

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
