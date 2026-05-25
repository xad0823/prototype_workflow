//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
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
// Abstract : Top level of the Instruction Fetch Unit
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53_dcu_ifu_defs.v"

module ca53ifu `CA53_IFU_PARAM_DECL
  (
   input wire                                clk,
   input wire                                reset_n,
   input wire                                DFTSE,
   input wire                                DFTRAMHOLD,
   //
   // GOV Interface
   //
   input  wire                               gov_mbist_req_i,              // global MBIST req
   output wire                               ifu_wfx_ready_o,              // dormant or shut-down mode entry is permitted
   //
   // DPU Interface
   //
   input wire                                dpu_iq_full_i,                // Instruction Q full
   input wire                                dpu_iq_part_full_i,           // Instruction Q almost full
   input wire                                dpu_fe_valid_wr_i,            // wr valid fetch address
   input wire                         [48:1] dpu_fe_addr_opa_wr_i,         // wr a operand
   input wire                         [27:1] dpu_fe_addr_opb_wr_i,         // wr b operand
   input wire                          [1:0] dpu_fe_isa_wr_i,              // wr isa
   input wire                                dpu_pred_br_ex2_i,            // branch in ex2
   input wire                         [12:3] dpu_br_addr_ex2_i,            // branch address in ex2
   input wire                                dpu_pred_br_wr_i,             // branch prediction result
   input wire                                dpu_mispred_wr_i,             // mispredicted branch
   input wire                                dpu_br_taken_wr_i,            // taken branch
   input wire                                dpu_br_return_wr_i,           // type return
   input wire                                dpu_br_call_wr_i,             // type call
   input wire                                dpu_fe_valid_ret_i,           // ret valid fetch address
   input wire                         [63:0] dpu_fe_addr_opa_ret_i,        // ret a operand
   input wire                         [17:1] dpu_fe_addr_opb_ret_i,        // ret b operand
   input wire                          [1:0] dpu_fe_isa_ret_i,             // ret isa
   input wire                          [7:0] dpu_fe_itstate_ret_i,         // ret IT state
   input wire                                dpu_fe_context_sync_ret_i,    // ret force is context sync
   input wire                                dpu_btac_ret_i,               // type btac
   input wire                                dpu_halt_ifu_i,               // halt request
   input wire                                dpu_mmu_on_i,                 // mmu on
   input wire                                dpu_ipa_to_pa_en_i,           // virtualization
   input wire                          [1:0] dpu_exception_level_i,        // exception levels
   input wire                          [3:1] dpu_aarch64_at_el_i,          // AArch64 at each exception level
   input wire                                dpu_flush_i_utlb_i,           // flush
   input wire                         [31:0] dpu_dacr_i,                   // page attributes
   input wire                                dpu_sif_only_i,               // secure attribute
   input wire                                dpu_ns_state_i,               // non-secure state
   input wire                                dpu_default_cacheable_i,      // cacheability attribute
   input wire                                dpu_icache_on_i,              // ICache ON
   input wire                                dpu_kill_wr_i,                // Ignore DCU cp15 op
   input wire                                dpu_sctlr_itd_i,              // IT mode 1'b0 = v7, 1'b1 v8
   input wire                                dpu_throttle_enable_i,        // Enable the throttle predictor
   input wire                         [31:0] dpu_dbg_ins_i,                // debug instruction
   input wire                                dpu_dbg_valid_i,              // debug request
   input wire                                dpu_reset_catch_pending_i,    // reset catch event pending
   input wire                                dpu_expt_catch_pending_i,     // exception catch event pending
   output wire                        [47:0] ifu_instr0_if3_o,             // instruction 0 from fetch Q
   output wire                        [47:0] ifu_instr1_if3_o,             // instruction 1 from fetch Q
   output wire                         [1:0] ifu_instr_valid_if3_o,        // instruction enable
   output wire                               ifu_early_two_valid_if3_o,    // early instruction enable
   output wire                        [48:0] ifu_pred_addr_if4_o,          // ret / btac packet
   output wire                               ifu_pred_addr_valid_if4_o,    // ret / btac packet available
   output wire                        [31:1] ifu_ifar_o,                   // fault address
   output wire                         [6:0] ifu_ifsr_o,                   // fault state
   output wire                         [1:0] ifu_ifsr_stage2_o,            // fault stage
   output wire                               ifu_ifsr_lpae_o,              // fault lpae
   output wire                        [27:0] ifu_hpfar_o,                  // hypervizer fault address
   output wire                               ifu_evnt_ic_lf_o,             // line fill event register
   output wire                               ifu_evnt_ic_access_o,         // instruction cache access event register
   output wire                               ifu_evnt_ic_miss_wait_o,      // instruction cache miss & wait
   output wire                               ifu_evnt_iutlb_miss_wait_o,   // instruction micro-TLB miss & wait
   output wire                               ifu_evnt_throttle_o,          // instruction cache throttle has occured
   output wire                               ifu_evnt_pdc_valid_o,         // pre-decode event register
   output wire                               ifu_dbg_ready_o,              // debug entry is permitted
   output wire                               ifu_pty_valid_o,              // Parity error valid
   output wire                               ifu_pty_ramid_o,              // Parity error RAM ID
   output wire                               ifu_pty_way_bank_id_o,        // Parity error way or bank ID
   output wire                        [11:0] ifu_pty_index_o,              // Parity error index
   //
   // TLB Interface
   //
   input wire                                tlb_i_utlb_enable_i,          // data enable
   input wire                                tlb_i_utlb_might_enable_i,    // speculative enable
   input wire                                tlb_i_utlb_valid_i,           // data valid
   input wire                                tlb_i_utlb_lpae_i,            // lpae type
   input wire                         [96:0] tlb_i_utlb_data_i,            // data
   input wire                                tlb_i_utlb_flush_i,           // abort
   input wire                          [1:0] tlb_d_tcr_el1_tbi_i,          // TCR_EL1 top byte ignored
   input wire                                tlb_d_tcr_el2_tbi0_i,         // TCR_EL2 top byte ignored
   input wire                                tlb_d_tcr_el3_tbi0_i,         // TCR_EL3 top byte ignored
   input wire                                tlb_lpae_mode_i,              // lpae mode
   input wire                          [3:0] tlb_bkpt_hit_if2_i,           // breakpoint
   input wire                          [1:0] tlb_vcr_hit_if2_i,            // vector catch
   output wire                               ifu_utlb_miss_req_o,          // request for new data
   output wire                         [2:0] ifu_outstanding_lfb_o,        // outstanding accesses for an IFU request
   output wire                        [63:0] ifu_va_if2_o,                 // va address
   output wire                               ifu_cp_dbg_valid_o,           // CP15 returned data
   output wire                        [31:0] ifu_cp_dbg_1_o,               // CP15 returned data bus 1
   output wire                        [31:0] ifu_cp_dbg_0_o,               // CP15 returned data bus 0
   //
   // BIU Interface
   //
   input wire                                biu_i_arready_i,             // axi read address ready
   input wire                          [1:0] biu_i_rid_i,                 // read data ID
   input wire                                biu_i_rvalid_i,              // read data valid
   input wire                        [127:0] biu_i_rdata_i,               // read data
   input wire                          [2:0] biu_i_rresp_i,               // error response
   input wire                          [1:0] biu_i_rchunk_i,              // which line is returned
   output wire                               ifu_arvalid_o,               // axi read address valid
   output wire                         [1:0] ifu_arid_o,                  // ID
   output wire                        [39:0] ifu_araddr_o,                // read address
   output wire                         [1:0] ifu_arlen_o,                 // burst length
   output wire                         [7:0] ifu_attrs_o,                 // attributes
   output wire                         [1:0] ifu_arprot_o,                // protection
   output wire                               ifu_rready_o,                // data ready
   output wire     [(`CA53_IDATA_RAM_W-1):0] ifu_mbist_out_data_mb6_o,    // mbist data out
   //
   // DCU Interface
   //
   input wire                                dcu_cp_valid_ifu_i,          // cp15 operation request cp type
   input wire                                dcu_dvm_valid_ifu_i,         // dvm type
   input wire                          [2:0] dcu_cp_op_ifu_i,             // type
   input wire                         [39:0] dcu_cp_addr_ifu_i,           // address
   input wire                                dcu_cp_ns_i,                 // non-secure state
   output wire                               ifu_cp_ack_o,                // cp15 operation completed
   output wire                               ifu_valid_if2_o,             // indicate active valid requests
   //
   // IC RAM Interface
   //
   input wire                          [2:0] ic_size_i,                   // Cache size
   input wire       [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata0_i,          // read data 0
   input wire       [(`CA53_ITAG_RAM_W-1):0] ic_tagram_rdata1_i,          // read data 1
   input wire      [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata0_i,         // read data 0
   input wire      [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata1_i,         // read data 1
   output wire                         [1:0] ic_tagram_en_o,              // tag enable
   output wire                               ic_tagram_wr_o,              // write/not read
   output wire      [(`CA53_ITAG_RAM_W-1):0] ic_tagram_wdata_o,           // write data
   output wire                         [8:0] ic_tagram_addr_o,            // address
   output wire                         [3:0] ic_dataram_en_o,             // data enable
   output wire                               ic_dataram_wr_o,             // write / not read
   output wire                        [11:0] ic_dataram_addr0_o,          // address
   output wire                        [11:0] ic_dataram_addr1_o,          // address
   output wire     [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb0_o,          // 20-bit write enable
   output wire     [(`CA53_IDATA_WEN_W-1):0] ic_dataram_strb1_o,          // 20-bit write enable
   output wire     [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata0_o,         // write data
   output wire     [(`CA53_IDATA_RAM_W-1):0] ic_dataram_wdata1_o,         // write data
   //
   // BTAC RAM Interface
   //
   input wire   [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_rdata_i,       // Stage-0 read data
   input wire   [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_rdata_i,       // Stage-1 read data
   output wire                               btac_stg0_ram_en_o,          // Stage-0 enable
   output wire                               btac_stg0_ram_wr_o,          // Stage-0 write/not read
   output wire  [(`CA53_BTAC_RAM_S0D_W-1):0] btac_stg0_ram_wdata_o,       // Stage-0 write data
   output wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr_o,        // Stage-0 address
   output wire                               btac_stg1_ram_en_o,          // Stage-1 enable
   output wire                               btac_stg1_ram_wr_o,          // Stage-1 write/not read
   output wire  [(`CA53_BTAC_RAM_S1D_W-1):0] btac_stg1_ram_wdata_o,       // Stage-1 write data
   output wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr_o         // Stage-1 address
   );

  // -----------------------------
  // wire declarations
  // -----------------------------
  wire                       icb_busy_if1;
  wire                [79:0] icb_data_if2;
  wire                [79:0] icb_lfb_data_if2;
  wire                       icb_hit_if2;
  wire                       icb_lfb_hit_if2;
  wire                       icb_dbg_hit_if2;
  wire                 [1:0] icb_way_if2;
  wire                       icb_pdc_hazard_if2;
  wire                       icb_ext_abort_if2;
  wire                 [1:0] icb_ext_abort_type_if2;
  wire                 [3:0] icb_parity_err_if2;
  wire                 [2:0] icb_mbist_en;
  wire                       icb_pdc_valid_if2;
  wire                [39:0] icb_pdc_data_if2;
  wire                       icb_flush_btic;
  wire                       icb_cacheable_if2;

  wire                [14:2] pfb_va_if1;
  wire                       pfb_first_if1;
  wire                       pfb_valid_if1;
  wire                       pfb_force_if1;
  wire                       pfb_utlb_hit_if2;
  wire                 [1:0] pfb_state_if2;
  wire                [39:4] pfb_pa_if2;
  wire                       pfb_kill_if2;
  wire                 [7:0] pfb_attributes_if2;
  wire                       pfb_priv_if2;
  wire                       pfb_ns_dsc_if2;
  wire                [79:0] pfb_mbist_data;
  wire                [28:0] pfb_pdc_data_if3;
  wire                [18:0] pfb_pdc_ctl_if3;
  wire                [63:0] pfb_va_if2;
  wire                 [1:0] pfb_valid_buffers;
  wire                       pfb_dbg_a64_state;
  wire                       pfb_in_debug_or_wfx;
  wire                       pfb_context_sync;

  wire                       ifu_arvalid;
  wire                 [1:0] ifu_arid;
  wire                [39:0] ifu_araddr;
  wire                 [1:0] ifu_arlen;
  wire                 [7:0] ifu_attrs;
  wire                 [1:0] ifu_arprot;
  wire                       ifu_rready;

  wire               [159:0] pd_data;
  wire                       pd_data_req;
  wire                 [1:0] cp15_busy_if1;
  wire                 [1:0] cp15_active;
  wire                 [1:0] cp15_hazard_ack;
  wire                       cp15_pty_ack;
  wire                 [1:0] cp15_tag_en;
  wire                       cp15_tag_wr;
  wire                 [1:0] cp15_data_en;
  wire                       cp15_data_wr;
  wire                [11:0] cp15_addr;
  wire               [159:0] lfb_data;
  wire                       lfb_data_way;
  wire                 [1:0] lfb_tagram_en_if0;
  wire                 [8:0] lfb_tagram_addr_if0;
  wire                       lfb_tagram_wr_if0;
  wire                [30:0] lfb_tagram_wdata_if0;
  wire                       lfb_dataram_en_if0;
  wire                       lfb_dataram_wr_if0;
  wire                [11:0] lfb_dataram_addr0_if0;
  wire                [11:0] lfb_dataram_addr1_if0;
  wire                 [3:0] lfb_dataram_strb0_if0;
  wire                 [3:0] lfb_dataram_strb1_if0;
  wire                       ctl_pfb_valid_if1;
  wire                       ctl_lfb_alloc;
  wire                [14:1] ctl_pfb_va_if3;
  wire                [39:4] ctl_pfb_pa_if3;
  wire                 [7:0] ctl_pfb_attributes_if3;
  wire                       ctl_pfb_ns_dsc_if3;
  wire                       ctl_pfb_priv_if3;
  wire                       ctl_seq_miss_if3;
  wire                       ctl_stall_pfb;
  wire                       ctl_valid_if2;
  wire                       ctl_stall_lfb_pd0;
  wire                       ctl_stall_lfb_if0;
  wire                       ctl_stall_if3;
  wire                       ctl_stall_pdc;
  wire                       ctl_stall_tag_cp15;
  wire                       ctl_stall_tag_cp15_if1;
  wire                       ctl_stall_data_cp15_if1;
  wire                       ctl_stall_data_cp15;
  wire                       ctl_cache_on_if2;
  wire                       ctl_hit_f_if3;
  wire                       ctl_cp15_active_if3;
  wire                       ctl_pty_inv_req;
  wire                [14:6] ctl_pty_inv_addr;
  wire                       ctl_pd_ack;
  wire                       ctl_start_lfb;
  wire                       ctl_lfb_activate;
  wire                       ctl_lfb_speculative;
  wire                       ctl_random_way;
  wire                 [1:0] ctl_tag_valid_if3;
  wire                 [1:0] ctl_almost_hit_if3;
  wire                       ctl_mbist_req;
  wire                 [1:0] ctl_mbist_btac_en_mb4;
  wire                 [6:0] ctl_mbist_btac_addr_mb4;
  wire                       ctl_mbist_btac_wr_mb4;
  wire                [58:0] ctl_mbist_btac_wdata_mb4;
  wire                       pdc_req;
  wire                 [3:0] pdc_en_if0;
  wire                [14:3] pdc_addr0_if0;
  wire                [14:3] pdc_addr1_if0;
  wire               [159:0] pdc_wdata_if0;
  wire                 [7:0] pdc_strb_if0;

  wire                 [7:0] lfb_pd_0;
  wire                 [7:0] lfb_pd_1;
  wire                 [7:0] lfb_pd_2;
  wire                       lfb_hit_raw;
  wire                       lfb_hit_past;
  wire                       lfb_hit_pres;
  wire                       lfb_hit_fut;
  wire                       lfb_hit_ppf;
  wire                 [2:0] lfb_hit_resp;
  wire                 [1:0] lfb_hit_way;
  wire                       lfb_hit_cacheable;
  wire                       lfb_can_hit_pd1;
  wire                 [1:0] lfb_available;
  wire                       lfb_in_progress;
  wire                       lfb_comp_hazard;

  //------------------------------------------------------------------------------
  // Prefetch Block
  //------------------------------------------------------------------------------

  ca53ifu_pf `CA53_IFU_PARAM_INST u_ca53ifu_pf
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .DFTSE                            (DFTSE),
     .DFTRAMHOLD                       (DFTRAMHOLD),
     .dpu_iq_full_i                    (dpu_iq_full_i),
     .dpu_iq_part_full_i               (dpu_iq_part_full_i),
     .dpu_fe_valid_wr_i                (dpu_fe_valid_wr_i),
     .dpu_fe_addr_opa_wr_i             (dpu_fe_addr_opa_wr_i[48:1]),
     .dpu_fe_addr_opb_wr_i             (dpu_fe_addr_opb_wr_i[27:1]),
     .dpu_fe_isa_wr_i                  (dpu_fe_isa_wr_i[1:0]),
     .dpu_br_addr_ex2_i                (dpu_br_addr_ex2_i[12:3]),
     .dpu_pred_br_ex2_i                (dpu_pred_br_ex2_i),
     .dpu_exception_level_i            (dpu_exception_level_i[1:0]),
     .dpu_aarch64_at_el3_i             (dpu_aarch64_at_el_i[3]),
     .dpu_dacr_i                       (dpu_dacr_i),
     .dpu_pred_br_wr_i                 (dpu_pred_br_wr_i),
     .dpu_mispred_wr_i                 (dpu_mispred_wr_i),
     .dpu_br_taken_wr_i                (dpu_br_taken_wr_i),
     .dpu_br_return_wr_i               (dpu_br_return_wr_i),
     .dpu_br_call_wr_i                 (dpu_br_call_wr_i),
     .dpu_fe_valid_ret_i               (dpu_fe_valid_ret_i),
     .dpu_fe_context_sync_ret_i        (dpu_fe_context_sync_ret_i),
     .dpu_fe_addr_opa_ret_i            (dpu_fe_addr_opa_ret_i[63:0]),
     .dpu_fe_addr_opb_ret_i            (dpu_fe_addr_opb_ret_i[17:1]),
     .dpu_fe_isa_ret_i                 (dpu_fe_isa_ret_i[1:0]),
     .dpu_fe_itstate_ret_i             (dpu_fe_itstate_ret_i[7:0]),
     .dpu_btac_ret_i                   (dpu_btac_ret_i),
     .dpu_halt_ifu_i                   (dpu_halt_ifu_i),
     .dpu_mmu_on_i                     (dpu_mmu_on_i),
     .dpu_ipa_to_pa_en_i               (dpu_ipa_to_pa_en_i),
     .dpu_flush_i_utlb_i               (dpu_flush_i_utlb_i),
     .dpu_sif_only_i                   (dpu_sif_only_i),
     .dpu_ns_state_i                   (dpu_ns_state_i),
     .dpu_default_cacheable_i          (dpu_default_cacheable_i),
     .dpu_sctlr_itd_i                  (dpu_sctlr_itd_i),
     .dpu_throttle_enable_i            (dpu_throttle_enable_i),
     .dpu_reset_catch_pending_i        (dpu_reset_catch_pending_i),
     .dpu_expt_catch_pending_i         (dpu_expt_catch_pending_i),
     .tlb_i_utlb_enable_i              (tlb_i_utlb_enable_i),
     .tlb_i_utlb_might_enable_i        (tlb_i_utlb_might_enable_i),
     .tlb_i_utlb_valid_i               (tlb_i_utlb_valid_i),
     .tlb_i_utlb_lpae_i                (tlb_i_utlb_lpae_i),
     .tlb_i_utlb_data_i                (tlb_i_utlb_data_i[96:0]),
     .tlb_i_utlb_flush_i               (tlb_i_utlb_flush_i),
     .tlb_tcr_el1_tbi_i                (tlb_d_tcr_el1_tbi_i),
     .tlb_tcr_el2_tbi0_i               (tlb_d_tcr_el2_tbi0_i),
     .tlb_tcr_el3_tbi0_i               (tlb_d_tcr_el3_tbi0_i),
     .tlb_lpae_mode_i                  (tlb_lpae_mode_i),
     .tlb_bkpt_hit_if2_i               (tlb_bkpt_hit_if2_i[3:0]),
     .tlb_vcr_hit_if2_i                (tlb_vcr_hit_if2_i[1:0]),
     .icb_busy_if1_i                   (icb_busy_if1),
     .icb_data_if2_i                   (icb_data_if2[79:0]),
     .icb_lfb_data_if2_i               (icb_lfb_data_if2[79:0]),
     .icb_hit_if2_i                    (icb_hit_if2),
     .icb_lfb_hit_if2_i                (icb_lfb_hit_if2),
     .icb_dbg_hit_if2_i                (icb_dbg_hit_if2),
     .icb_way_if2_i                    (icb_way_if2[1:0]),
     .icb_pdc_hazard_if2_i             (icb_pdc_hazard_if2),
     .icb_ext_abort_if2_i              (icb_ext_abort_if2),
     .icb_ext_abort_type_if2_i         (icb_ext_abort_type_if2),
     .icb_parity_err_if2_i             (icb_parity_err_if2),
     .icb_pdc_data_if2_i               (icb_pdc_data_if2[39:0]),
     .icb_flush_btic_i                 (icb_flush_btic),
     .icb_cacheable_if2_i              (icb_cacheable_if2),
     .icb_mbist_en_i                   (icb_mbist_en),
     .icb_pdc_valid_if2_i              (icb_pdc_valid_if2),
     .btac_stg0_ram_rdata_i            (btac_stg0_ram_rdata_i[49:0]),
     .btac_stg1_ram_rdata_i            (btac_stg1_ram_rdata_i[58:0]),
     .ctl_mbist_req_i                  (ctl_mbist_req),
     .ctl_mbist_btac_en_mb4_i          (ctl_mbist_btac_en_mb4[1:0]),
     .ctl_mbist_btac_addr_mb4_i        (ctl_mbist_btac_addr_mb4[6:0]),
     .ctl_mbist_btac_wr_mb4_i          (ctl_mbist_btac_wr_mb4),
     .ctl_mbist_btac_wdata_mb4_i       (ctl_mbist_btac_wdata_mb4[58:0]),
     .lfb_in_progress_i                (lfb_in_progress),
     // Outputs
     .ifu_instr0_if3_o                 (ifu_instr0_if3_o[47:0]),
     .ifu_instr1_if3_o                 (ifu_instr1_if3_o[47:0]),
     .ifu_instr_valid_if3_o            (ifu_instr_valid_if3_o[1:0]),
     .ifu_early_two_valid_if3_o        (ifu_early_two_valid_if3_o),
     .ifu_pred_addr_if4_o              (ifu_pred_addr_if4_o[48:0]),
     .ifu_pred_addr_valid_if4_o        (ifu_pred_addr_valid_if4_o),
     .ifu_ifar_o                       (ifu_ifar_o[31:1]),
     .ifu_hpfar_o                      (ifu_hpfar_o[27:0]),
     .ifu_ifsr_o                       (ifu_ifsr_o[6:0]),
     .ifu_ifsr_stage2_o                (ifu_ifsr_stage2_o[1:0]),
     .ifu_ifsr_lpae_o                  (ifu_ifsr_lpae_o),
     .ifu_evnt_ic_miss_wait_o          (ifu_evnt_ic_miss_wait_o),
     .ifu_evnt_iutlb_miss_wait_o       (ifu_evnt_iutlb_miss_wait_o),
     .ifu_utlb_miss_req_o              (ifu_utlb_miss_req_o),
     .ifu_evnt_throttle_o              (ifu_evnt_throttle_o),
     .ifu_valid_if2_o                  (ifu_valid_if2_o),
     .pfb_first_if1_o                  (pfb_first_if1),
     .pfb_valid_if1_o                  (pfb_valid_if1),
     .pfb_va_if1_o                     (pfb_va_if1[14:2]),
     .pfb_force_if1_o                  (pfb_force_if1),
     .pfb_utlb_hit_if2_o               (pfb_utlb_hit_if2),
     .pfb_state_if2_o                  (pfb_state_if2[1:0]),
     .pfb_kill_if2_o                   (pfb_kill_if2),
     .pfb_attributes_if2_o             (pfb_attributes_if2[7:0]),
     .pfb_priv_if2_o                   (pfb_priv_if2),
     .pfb_va_if2_o                     (pfb_va_if2[63:0]),
     .pfb_pa_if2_o                     (pfb_pa_if2[39:4]),
     .pfb_ns_dsc_if2_o                 (pfb_ns_dsc_if2),
     .pfb_pdc_data_if3_o               (pfb_pdc_data_if3[28:0]),
     .pfb_pdc_ctl_if3_o                (pfb_pdc_ctl_if3[18:0]),
     .pfb_valid_buffers_o              (pfb_valid_buffers[1:0]),
     .pfb_mbist_data_o                 (pfb_mbist_data[79:0]),
     .pfb_dbg_a64_state_o              (pfb_dbg_a64_state),
     .pfb_in_debug_or_wfx_o            (pfb_in_debug_or_wfx),
     .pfb_context_sync_o               (pfb_context_sync),
     .btac_stg0_ram_en_o               (btac_stg0_ram_en_o),
     .btac_stg0_ram_wr_o               (btac_stg0_ram_wr_o),
     .btac_stg0_ram_wdata_o            (btac_stg0_ram_wdata_o[49:0]),
     .btac_stg0_ram_addr_o             (btac_stg0_ram_addr_o[6:0]),
     .btac_stg1_ram_en_o               (btac_stg1_ram_en_o),
     .btac_stg1_ram_wr_o               (btac_stg1_ram_wr_o),
     .btac_stg1_ram_wdata_o            (btac_stg1_ram_wdata_o[58:0]),
     .btac_stg1_ram_addr_o             (btac_stg1_ram_addr_o[6:0])
    );


  //----------------------------------------------------------------------------
  // Instruction Cache Block
  //----------------------------------------------------------------------------

  // ICB control
  ca53ifu_ctl `CA53_IFU_PARAM_INST u_ca53ifu_ctl
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .DFTRAMHOLD                       (DFTRAMHOLD),
     .dpu_icache_on_i                  (dpu_icache_on_i),
     .dpu_flush_i_utlb_i               (dpu_flush_i_utlb_i),
     .tlb_i_utlb_flush_i               (tlb_i_utlb_flush_i),
     .pfb_va_if1_i                     (pfb_va_if1[14:2]),
     .pfb_first_if1_i                  (pfb_first_if1),
     .pfb_force_if1_i                  (pfb_force_if1),
     .pfb_valid_if1_i                  (pfb_valid_if1),
     .pfb_utlb_hit_if2_i               (pfb_utlb_hit_if2),
     .pfb_state_if2_i                  (pfb_state_if2[1:0]),
     .pfb_ns_dsc_if2_i                 (pfb_ns_dsc_if2),
     .pfb_va_if2_i                     (pfb_va_if2[14:1]),
     .pfb_pa_if2_i                     (pfb_pa_if2[39:4]),
     .pfb_kill_if2_i                   (pfb_kill_if2),
     .pfb_attributes_if2_i             (pfb_attributes_if2[7:0]),
     .pfb_priv_if2_i                   (pfb_priv_if2),
     .pfb_mbist_data_i                 (pfb_mbist_data[79:0]),
     .gov_mbist_req_i                  (gov_mbist_req_i),
     .mbist_sel_i                      (dcu_cp_addr_ifu_i[34]),
     .mbist_cfg_mb3_i                  (dcu_cp_addr_ifu_i[33]),
     .mbist_read_en_mb3_i              (dcu_cp_addr_ifu_i[32]),
     .mbist_write_en_mb3_i             (dcu_cp_addr_ifu_i[31]),
     .mbist_be_mb3_i                   (dcu_cp_addr_ifu_i[30:27]),
     .mbist_array_mb3_i                (dcu_cp_addr_ifu_i[24:18]),
     .mbist_addr_mb3_i                 (dcu_cp_addr_ifu_i[17:6]),
     .ifu_arvalid_i                    (ifu_arvalid),
     .biu_i_arready_i                  (biu_i_arready_i),
     .biu_i_rdata_i                    (biu_i_rdata_i[(`CA53_IDATA_RAM_W-1):0]),
     .ic_tagram_rdata0_i               (ic_tagram_rdata0_i[(`CA53_ITAG_RAM_W-1):0]),
     .ic_tagram_rdata1_i               (ic_tagram_rdata1_i[(`CA53_ITAG_RAM_W-1):0]),
     .ic_dataram_rdata0_i              (ic_dataram_rdata0_i[(`CA53_IDATA_RAM_W-1):0]),
     .ic_dataram_rdata1_i              (ic_dataram_rdata1_i[(`CA53_IDATA_RAM_W-1):0]),
     .ic_size_i                        (ic_size_i[2:0]),
     .cp15_busy_if1_i                  (cp15_busy_if1[1:0]),
     .cp15_active_i                    (cp15_active[1:0]),
     .cp15_pty_ack_i                   (cp15_pty_ack),
     .cp15_tag_en_i                    (cp15_tag_en[1:0]),
     .cp15_tag_wr_i                    (cp15_tag_wr),
     .cp15_data_en_i                   (cp15_data_en[1:0]),
     .cp15_data_wr_i                   (cp15_data_wr),
     .cp15_addr_i                      (cp15_addr[11:0]),
     .lfb_tagram_en_if0_i              (lfb_tagram_en_if0[1:0]),
     .lfb_tagram_addr_if0_i            (lfb_tagram_addr_if0[8:0]),
     .lfb_tagram_wr_if0_i              (lfb_tagram_wr_if0),
     .lfb_tagram_wdata_if0_i           (lfb_tagram_wdata_if0[30:0]),
     .lfb_dataram_en_if0_i             (lfb_dataram_en_if0),
     .lfb_dataram_wr_if0_i             (lfb_dataram_wr_if0),
     .lfb_dataram_addr0_if0_i          (lfb_dataram_addr0_if0[11:0]),
     .lfb_dataram_addr1_if0_i          (lfb_dataram_addr1_if0[11:0]),
     .lfb_dataram_strb0_if0_i          (lfb_dataram_strb0_if0[3:0]),
     .lfb_dataram_strb1_if0_i          (lfb_dataram_strb1_if0[3:0]),
     .lfb_data_i                       (lfb_data[159:0]),
     .lfb_data_way_i                   (lfb_data_way),
     .lfb_hit_raw_i                    (lfb_hit_raw),
     .lfb_hit_past_i                   (lfb_hit_past),
     .lfb_hit_pres_i                   (lfb_hit_pres),
     .lfb_hit_fut_i                    (lfb_hit_fut),
     .lfb_hit_ppf_i                    (lfb_hit_ppf),
     .lfb_hit_resp_i                   (lfb_hit_resp[2:0]),
     .lfb_hit_way_i                    (lfb_hit_way[1:0]),
     .lfb_hit_cacheable_i              (lfb_hit_cacheable),
     .lfb_can_hit_pd1_i                (lfb_can_hit_pd1),
     .lfb_available_i                  (lfb_available),
     .lfb_in_progress_i                (lfb_in_progress),
     .lfb_comp_hazard_i                (lfb_comp_hazard),
     .icb_dbg_hit_if2_i                (icb_dbg_hit_if2),
     .pdc_req_i                        (pdc_req),
     .pdc_en_if0_i                     (pdc_en_if0[3:0]),
     .pdc_addr0_if0_i                  (pdc_addr0_if0[14:3]),
     .pdc_addr1_if0_i                  (pdc_addr1_if0[14:3]),
     .pdc_wdata_if0_i                  (pdc_wdata_if0[159:0]),
     .pdc_strb_if0_i                   (pdc_strb_if0[7:0]),
     // Outputs
     .ic_tagram_en_o                   (ic_tagram_en_o[1:0]),
     .ic_tagram_wr_o                   (ic_tagram_wr_o),
     .ic_tagram_wdata_o                (ic_tagram_wdata_o[(`CA53_ITAG_RAM_W-1):0]),
     .ic_tagram_addr_o                 (ic_tagram_addr_o[8:0]),
     .ic_dataram_en_o                  (ic_dataram_en_o[3:0]),
     .ic_dataram_wr_o                  (ic_dataram_wr_o),
     .ic_dataram_addr0_o               (ic_dataram_addr0_o[11:0]),
     .ic_dataram_addr1_o               (ic_dataram_addr1_o[11:0]),
     .ic_dataram_strb0_o               (ic_dataram_strb0_o[(`CA53_IDATA_WEN_W-1):0]),
     .ic_dataram_strb1_o               (ic_dataram_strb1_o[(`CA53_IDATA_WEN_W-1):0]),
     .ic_dataram_wdata0_o              (ic_dataram_wdata0_o[(`CA53_IDATA_RAM_W-1):0]),
     .ic_dataram_wdata1_o              (ic_dataram_wdata1_o[(`CA53_IDATA_RAM_W-1):0]),
     .icb_flush_btic_o                 (icb_flush_btic),
     .icb_cacheable_if2_o              (icb_cacheable_if2),
     .icb_busy_if1_o                   (icb_busy_if1),
     .icb_data_if2_o                   (icb_data_if2[79:0]),
     .icb_lfb_data_if2_o               (icb_lfb_data_if2[79:0]),
     .icb_hit_if2_o                    (icb_hit_if2),
     .icb_lfb_hit_if2_o                (icb_lfb_hit_if2),
     .icb_way_if2_o                    (icb_way_if2[1:0]),
     .icb_pdc_hazard_if2_o             (icb_pdc_hazard_if2),
     .icb_ext_abort_if2_o              (icb_ext_abort_if2),
     .icb_ext_abort_type_if2_o         (icb_ext_abort_type_if2),
     .icb_parity_err_if2_o             (icb_parity_err_if2),
     .icb_mbist_en_o                   (icb_mbist_en),
     .ifu_dbg_ready_o                  (ifu_dbg_ready_o),
     .ifu_wfx_ready_o                  (ifu_wfx_ready_o),
     .ifu_evnt_ic_access_o             (ifu_evnt_ic_access_o),
     .ifu_mbist_out_data_mb6_o         (ifu_mbist_out_data_mb6_o[(`CA53_IDATA_RAM_W-1):0]),
     .ifu_pty_valid_o                  (ifu_pty_valid_o),
     .ifu_pty_ramid_o                  (ifu_pty_ramid_o),
     .ifu_pty_way_bank_id_o            (ifu_pty_way_bank_id_o),
     .ifu_pty_index_o                  (ifu_pty_index_o[11:0]),
     .ctl_pfb_valid_if1_o              (ctl_pfb_valid_if1),
     .ctl_lfb_alloc_o                  (ctl_lfb_alloc),
     .ctl_pfb_va_if3_o                 (ctl_pfb_va_if3[14:1]),
     .ctl_pfb_pa_if3_o                 (ctl_pfb_pa_if3[39:4]),
     .ctl_pfb_attributes_if3_o         (ctl_pfb_attributes_if3[7:0]),
     .ctl_pfb_ns_dsc_if3_o             (ctl_pfb_ns_dsc_if3),
     .ctl_pfb_priv_if3_o               (ctl_pfb_priv_if3),
     .ctl_stall_pfb_o                  (ctl_stall_pfb),
     .ctl_valid_if2_o                  (ctl_valid_if2),
     .ctl_stall_lfb_pd0_o              (ctl_stall_lfb_pd0),
     .ctl_stall_lfb_if0_o              (ctl_stall_lfb_if0),
     .ctl_stall_if3_o                  (ctl_stall_if3),
     .ctl_stall_pdc_o                  (ctl_stall_pdc),
     .ctl_stall_tag_cp15_o             (ctl_stall_tag_cp15),
     .ctl_stall_tag_cp15_if1_o         (ctl_stall_tag_cp15_if1),
     .ctl_stall_data_cp15_if1_o        (ctl_stall_data_cp15_if1),
     .ctl_stall_data_cp15_o            (ctl_stall_data_cp15),
     .ctl_cache_on_if2_o               (ctl_cache_on_if2),
     .ctl_seq_miss_if3_o               (ctl_seq_miss_if3),
     .ctl_hit_f_if3_o                  (ctl_hit_f_if3),
     .ctl_cp15_active_if3_o            (ctl_cp15_active_if3),
     .ctl_pty_inv_req_o                (ctl_pty_inv_req),
     .ctl_pty_inv_addr_o               (ctl_pty_inv_addr[14:6]),
     .ctl_pd_ack_o                     (ctl_pd_ack),
     .ctl_start_lfb_o                  (ctl_start_lfb),
     .ctl_lfb_activate_o               (ctl_lfb_activate),
     .ctl_lfb_speculative_o            (ctl_lfb_speculative),
     .ctl_random_way_o                 (ctl_random_way),
     .ctl_tag_valid_if3_o              (ctl_tag_valid_if3),
     .ctl_almost_hit_if3_o             (ctl_almost_hit_if3),
     .ctl_mbist_req_o                  (ctl_mbist_req),
     .ctl_mbist_btac_en_mb4_o          (ctl_mbist_btac_en_mb4[1:0]),
     .ctl_mbist_btac_addr_mb4_o        (ctl_mbist_btac_addr_mb4[6:0]),
     .ctl_mbist_btac_wr_mb4_o          (ctl_mbist_btac_wr_mb4),
     .ctl_mbist_btac_wdata_mb4_o       (ctl_mbist_btac_wdata_mb4[58:0])
    );

  // Pre-decode correction
  ca53ifu_pdc u_ca53ifu_pdc
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .pfb_pdc_data_if3_i               (pfb_pdc_data_if3[28:0]),
     .pfb_pdc_req_if3_i                (pfb_pdc_ctl_if3[0]),
     .pfb_pdc_addr_if3_i               (pfb_pdc_ctl_if3[14:1]),
     .pfb_pdc_way_low_if3_i            (pfb_pdc_ctl_if3[16:15]),
     .pfb_pdc_way_high_if3_i           (pfb_pdc_ctl_if3[18:17]),
     .pfb_valid_buffers_i              (pfb_valid_buffers[1:0]),
     .icb_pdc_hazard_if2_i             (icb_pdc_hazard_if2),
     .ctl_stall_pdc_i                  (ctl_stall_pdc),
     .ctl_seq_miss_if3_i               (ctl_seq_miss_if3),
     .ctl_stall_pfb_i                  (ctl_stall_pfb),
     .ctl_valid_if2_i                  (ctl_valid_if2),
     // Outputs
     .icb_pdc_valid_if2_o              (icb_pdc_valid_if2),
     .pd_pdc_data_o                    (icb_pdc_data_if2[39:0]),
     .pdc_req_o                        (pdc_req),
     .pdc_en_if0_o                     (pdc_en_if0[3:0]),
     .pdc_addr0_if0_o                  (pdc_addr0_if0[14:3]),
     .pdc_addr1_if0_o                  (pdc_addr1_if0[14:3]),
     .pdc_wdata_if0_o                  (pdc_wdata_if0[159:0]),
     .pdc_strb_if0_o                   (pdc_strb_if0[7:0])
    );

  // Pre-decode
  ca53ifu_pd u_ca53ifu_pd
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .DFTSE                            (DFTSE),
     .lfb_pd_0_i                       (lfb_pd_0[7:0]),
     .lfb_pd_1_i                       (lfb_pd_1[7:0]),
     .lfb_pd_2_i                       (lfb_pd_2[7:0]),
     .biu_i_rvalid_i                   (biu_i_rvalid_i),
     .biu_i_rdata_i                    (biu_i_rdata_i[127:0]),
     .biu_i_rchunk_i                   (biu_i_rchunk_i[1:0]),
     .biu_i_rid_i                      (biu_i_rid_i[1:0]),
     .ifu_rready_i                     (ifu_rready),
     .dpu_dbg_ins_i                    (dpu_dbg_ins_i[31:0]),
     .dpu_dbg_valid_i                  (dpu_dbg_valid_i),
     .ctl_pd_ack_i                     (ctl_pd_ack),
     .a64_state_i                      (pfb_dbg_a64_state),
     .pfb_in_debug_or_wfx_i            (pfb_in_debug_or_wfx),
     // Outputs
     .pd_data_o                        (pd_data[159:0]),
     .pd_data_req_o                    (pd_data_req)

    );

  // Linefill buffer
  ca53ifu_lfb u_ca53ifu_lfb
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .DFTSE                            (DFTSE),
     .biu_i_arready_i                  (biu_i_arready_i),
     .biu_i_rid_i                      (biu_i_rid_i[1:0]),
     .biu_i_rvalid_i                   (biu_i_rvalid_i),
     .biu_i_rresp_i                    (biu_i_rresp_i[2:0]),
     .biu_i_rchunk_i                   (biu_i_rchunk_i[1:0]),
     .pd_data_i                        (pd_data[159:0]),
     .pd_req_i                         (pd_data_req),
     .dpu_dbg_valid_i                  (dpu_dbg_valid_i),
     .ctl_pfb_valid_if1_i              (ctl_pfb_valid_if1),
     .pfb_first_if1_i                  (pfb_first_if1),
     .ctl_lfb_alloc_i                  (ctl_lfb_alloc),
     .ctl_pfb_va_if3_i                 (ctl_pfb_va_if3[14:1]),
     .ctl_pfb_pa_if3_i                 (ctl_pfb_pa_if3[39:4]),
     .ctl_pfb_attributes_if3_i         (ctl_pfb_attributes_if3[7:0]),
     .ctl_pfb_ns_dsc_if3_i             (ctl_pfb_ns_dsc_if3),
     .ctl_pfb_priv_if3_i               (ctl_pfb_priv_if3),
     .ctl_stall_pfb_i                  (ctl_stall_pfb),
     .ctl_stall_lfb_pd0_i              (ctl_stall_lfb_pd0),
     .ctl_stall_lfb_if0_i              (ctl_stall_lfb_if0),
     .ctl_stall_if3_i                  (ctl_stall_if3),
     .ctl_start_lfb_i                  (ctl_start_lfb),
     .ctl_lfb_activate_i               (ctl_lfb_activate),
     .ctl_lfb_speculative_i            (ctl_lfb_speculative),
     .ctl_random_way_i                 (ctl_random_way),
     .ctl_tag_valid_if3_i              (ctl_tag_valid_if3),
     .ctl_almost_hit_if3_i             (ctl_almost_hit_if3),
     .ctl_cache_on_if2_i               (ctl_cache_on_if2),
     .ctl_hit_f_if3_i                  (ctl_hit_f_if3),
     .ic_size_i                        (ic_size_i[2:0]),
     .pfb_pa_if2_i                     (pfb_pa_if2[39:12]),
     .pfb_va_if2_i                     (pfb_va_if2[14:4]),
     .pfb_attributes_if2_i             (pfb_attributes_if2),
     .pfb_ns_dsc_if2_i                 (pfb_ns_dsc_if2),
     .pfb_state_if2_i                  (pfb_state_if2[1:0]),
     .pfb_force_if1_i                  (pfb_force_if1),
     .pfb_kill_if2_i                   (pfb_kill_if2),
     .pfb_utlb_hit_if2_i               (pfb_utlb_hit_if2),
     .pfb_in_debug_or_wfx_i            (pfb_in_debug_or_wfx),
     .pfb_context_sync_i               (pfb_context_sync),
     .cp15_active_i                    (cp15_active[1]),
     .ctl_cp15_active_if3_i            (ctl_cp15_active_if3),
     .cp15_addr_i                      (cp15_addr[8:3]),
     .cp15_hazard_ack_i                (cp15_hazard_ack[1:0]),
     // Outputs
     .ifu_evnt_ic_lf_o                 (ifu_evnt_ic_lf_o),
     .ifu_arvalid_o                    (ifu_arvalid),
     .ifu_arid_o                       (ifu_arid[1:0]),
     .ifu_araddr_o                     (ifu_araddr[39:0]),
     .ifu_arlen_o                      (ifu_arlen[1:0]),
     .ifu_attrs_o                      (ifu_attrs[7:0]),
     .ifu_arprot_o                     (ifu_arprot[1:0]),
     .ifu_rready_o                     (ifu_rready),
     .lfb_tagram_en_if0_o              (lfb_tagram_en_if0[1:0]),
     .lfb_tagram_addr_if0_o            (lfb_tagram_addr_if0[8:0]),
     .lfb_tagram_wr_if0_o              (lfb_tagram_wr_if0),
     .lfb_tagram_wdata_if0_o           (lfb_tagram_wdata_if0[30:0]),
     .lfb_dataram_en_if0_o             (lfb_dataram_en_if0),
     .lfb_dataram_wr_if0_o             (lfb_dataram_wr_if0),
     .lfb_dataram_addr0_if0_o          (lfb_dataram_addr0_if0[11:0]),
     .lfb_dataram_addr1_if0_o          (lfb_dataram_addr1_if0[11:0]),
     .lfb_dataram_strb0_if0_o          (lfb_dataram_strb0_if0[3:0]),
     .lfb_dataram_strb1_if0_o          (lfb_dataram_strb1_if0[3:0]),
     .lfb_data_o                       (lfb_data[159:0]),
     .lfb_data_way_o                   (lfb_data_way),
     .lfb_pd_0_o                       (lfb_pd_0[7:0]),
     .lfb_pd_1_o                       (lfb_pd_1[7:0]),
     .lfb_pd_2_o                       (lfb_pd_2[7:0]),
     .lfb_hit_raw_o                    (lfb_hit_raw),
     .lfb_hit_past_o                   (lfb_hit_past),
     .lfb_hit_pres_o                   (lfb_hit_pres),
     .lfb_hit_fut_o                    (lfb_hit_fut),
     .lfb_hit_ppf_o                    (lfb_hit_ppf),
     .lfb_hit_resp_o                   (lfb_hit_resp[2:0]),
     .lfb_hit_way_o                    (lfb_hit_way[1:0]),
     .lfb_hit_cacheable_o              (lfb_hit_cacheable),
     .icb_dbg_hit_if2_o                (icb_dbg_hit_if2),
     .lfb_can_hit_pd1_o                (lfb_can_hit_pd1),
     .lfb_in_progress_o                (lfb_in_progress),
     .ifu_outstanding_lfb_o            (ifu_outstanding_lfb_o),
     .lfb_comp_hazard_o                (lfb_comp_hazard),
     .lfb_available_o                  (lfb_available)
    );

  // CP15
  ca53ifu_cp15 `CA53_IFU_PARAM_INST u_ca53ifu_cp15
    (// Inputs
     .clk                              (clk),
     .reset_n                          (reset_n),
     .dpu_kill_wr_i                    (dpu_kill_wr_i),
     .dcu_cp_valid_i                   (dcu_cp_valid_ifu_i),
     .dcu_dvm_valid_i                  (dcu_dvm_valid_ifu_i),
     .dcu_cp_op_i                      (dcu_cp_op_ifu_i[2:0]),
     .dcu_cp_addr_ifu_i                (dcu_cp_addr_ifu_i[39:0]),
     .dcu_cp_ns_i                      (dcu_cp_ns_i),
     .ctl_pty_inv_req_i                (ctl_pty_inv_req),
     .ctl_pty_inv_addr_i               (ctl_pty_inv_addr[14:6]),
     .ic_size_i                        (ic_size_i[2:0]),
     .ic_tagram_rdata0_i               (ic_tagram_rdata0_i[(`CA53_ITAG_RAM_W-1):0]),
     .ic_tagram_rdata1_i               (ic_tagram_rdata1_i[(`CA53_ITAG_RAM_W-1):0]),
     .ic_dataram_rdata0_i              (ic_dataram_rdata0_i[(`CA53_IDATA_RAM_W-1):0]),
     .ic_dataram_rdata1_i              (ic_dataram_rdata1_i[(`CA53_IDATA_RAM_W-1):0]),
     .ctl_stall_tag_cp15_i             (ctl_stall_tag_cp15),
     .ctl_stall_tag_cp15_if1_i         (ctl_stall_tag_cp15_if1),
     .ctl_stall_data_cp15_i            (ctl_stall_data_cp15),
     .ctl_stall_data_cp15_if1_i        (ctl_stall_data_cp15_if1),
     .ctl_mbist_req_i                  (ctl_mbist_req),
     // Outputs
     .ifu_cp_ack_o                     (ifu_cp_ack_o),
     .ifu_cp_dbg_valid_o               (ifu_cp_dbg_valid_o),
     .ifu_cp_dbg_0_o                   (ifu_cp_dbg_0_o[31:0]),
     .ifu_cp_dbg_1_o                   (ifu_cp_dbg_1_o[31:0]),
     .cp15_busy_if1_o                  (cp15_busy_if1[1:0]),
     .cp15_active_o                    (cp15_active[1:0]),
     .cp15_hazard_ack_o                (cp15_hazard_ack[1:0]),
     .cp15_pty_ack_o                   (cp15_pty_ack),
     .cp15_tag_en_o                    (cp15_tag_en[1:0]),
     .cp15_tag_wr_o                    (cp15_tag_wr),
     .cp15_data_en_o                   (cp15_data_en[1:0]),
     .cp15_data_wr_o                   (cp15_data_wr),
     .cp15_addr_o                      (cp15_addr[11:0])
    );


  // Output assignments
  assign ifu_arvalid_o          = ifu_arvalid;
  assign ifu_arid_o             = ifu_arid;
  assign ifu_araddr_o           = ifu_araddr;
  assign ifu_arlen_o            = ifu_arlen;
  assign ifu_attrs_o            = ifu_attrs;
  assign ifu_arprot_o           = ifu_arprot;
  assign ifu_rready_o           = ifu_rready;
  assign ifu_va_if2_o           = pfb_va_if2[63:0];
  assign ifu_evnt_pdc_valid_o   = icb_pdc_valid_if2;

  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  wire                            ovl_wait_for_lfb_if2;
  wire                            ovl_icb_busy_end;
  wire                            push_rqst;
  wire                     [18:0] pdc_mask;
  wire                            ovl_icb_busy_if2;
  wire                            pop_rqst;
  wire                            ovl_wait_for_lfb_end;

  reg                      [2:0] rqst_cnt;
  reg                            pfb_alive;
  reg                            ovl_icb_busy;
  reg                            ovl_wait_for_lfb;

  reg                            icb_busy_if1_reg;
  reg                      [7:0] pfb_attributes_if2_reg;
  reg                      [2:0] icb_mbist_en_reg;
  reg                     [18:0] pfb_pdc_ctl_if3_reg;
  reg                            pfb_priv_if2_reg;
  reg                            pfb_first_if1_reg;
  reg                     [14:3] pfb_va_if1_reg;
  reg                      [1:0] pfb_state_if2_reg;
  reg  [(`CA53_IDATA_RAM_W-1):0] icb_data_if2_reg;
  reg                     [14:3] pfb_va_if2_reg;
  reg                            push_rqst_reg;
  reg                            pfb_utlb_hit_if2_reg;
  reg                     [28:0] pfb_pdc_data_if3_reg;
  reg                            pfb_valid_if1_reg;
  reg                            icb_pdc_valid_if2_reg;
  reg                            pfb_ns_dsc_if2_reg;
  reg                     [39:4] pfb_pa_if2_reg;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
  begin
    icb_busy_if1_reg       <= 1'b0;
    pfb_attributes_if2_reg <= {8{1'b0}};
    icb_mbist_en_reg       <= 3'b000;
    pfb_pdc_ctl_if3_reg    <= {19{1'b0}};
    pfb_priv_if2_reg       <= 1'b0;
    pfb_first_if1_reg      <= 1'b0;
    pfb_va_if1_reg         <= {12{1'b0}};
    pfb_state_if2_reg      <= 2'b00;
    icb_data_if2_reg       <= {`CA53_IDATA_RAM_W{1'b0}};
    pfb_va_if2_reg         <= {12{1'b0}};
    push_rqst_reg          <= 1'b0;
    pfb_utlb_hit_if2_reg   <= 1'b0;
    pfb_pdc_data_if3_reg   <= {29{1'b0}};
    pfb_valid_if1_reg      <= 1'b0;
    icb_pdc_valid_if2_reg  <= 1'b0;
    pfb_ns_dsc_if2_reg     <= 1'b0;
    pfb_pa_if2_reg         <= {36{1'b0}};
  end
  else
  begin
    icb_data_if2_reg       <= icb_data_if2;
    icb_pdc_valid_if2_reg  <= icb_pdc_valid_if2;
    icb_mbist_en_reg       <= icb_mbist_en;
    icb_busy_if1_reg       <= icb_busy_if1;
    pfb_va_if1_reg         <= pfb_va_if1[14:3];
    pfb_first_if1_reg      <= pfb_first_if1;
    pfb_valid_if1_reg      <= pfb_valid_if1;
    pfb_utlb_hit_if2_reg   <= pfb_utlb_hit_if2;
    pfb_state_if2_reg      <= pfb_state_if2;
    pfb_ns_dsc_if2_reg     <= pfb_ns_dsc_if2;
    pfb_va_if2_reg         <= pfb_va_if2[14:3];
    pfb_pa_if2_reg         <= pfb_pa_if2;
    pfb_attributes_if2_reg <= pfb_attributes_if2;
    pfb_priv_if2_reg       <= pfb_priv_if2;
    pfb_pdc_ctl_if3_reg    <= pfb_pdc_ctl_if3;
    pfb_pdc_data_if3_reg   <= pfb_pdc_data_if3;
    push_rqst_reg          <= push_rqst;
  end


  // To prevent the need to reset registers in the RTL to get
  // OVLs working correctly after reset we wait until at least one
  // transaction has been signalled.

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    pfb_alive <= 1'b0;
  else
    pfb_alive <= pfb_alive | pfb_valid_if1;


  // ------------------------------------------------------
  // Interface signals
  // ------------------------------------------------------

  // Inputs to the Pre Fetch from the Instruction Cache
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_hit_if2 X or Z")
  u_ovl_intf_x_3 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_hit_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_lfb_hit_if2 X or Z")
  u_ovl_intf_x_4 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_lfb_hit_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_dbg_hit_if2 X or Z")
  u_ovl_intf_x_5 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_dbg_hit_if2));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "icb_way_if2 X or Z")
  u_ovl_intf_x_6 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icb_hit_if2 | icb_lfb_hit_if2),
    .test_expr (icb_way_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_ext_abort_if2 X or Z")
  u_ovl_intf_x_7 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_ext_abort_if2));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "icb_ext_abort_type_if2 X or Z")
  u_ovl_intf_x_8 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icb_ext_abort_if2),
    .test_expr (icb_ext_abort_type_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_pdc_valid_if2 X or Z")
  u_ovl_intf_x_9 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_pdc_valid_if2));

  assert_never_unknown #(`OVL_FATAL, 40, `OVL_ASSERT, "icb_pdc_data_if2 X or Z")
  u_ovl_intf_x_10 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (icb_pdc_valid_if2),
    .test_expr (icb_pdc_data_if2));

  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "icb_mbist_en X or Z")
  u_ovl_intf_x_11 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_mbist_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_busy_if1 X or Z")
  u_ovl_intf_x_12 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_busy_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_flush_btic X or Z")
  u_ovl_intf_x_13 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_flush_btic));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "icb_cacheable_if2 X or Z")
  u_ovl_intf_x_14 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (icb_cacheable_if2));


  // Outputs from the Pre Fetch to the Instruction Cache

  assert_never_unknown #(`OVL_FATAL, 13, `OVL_ASSERT, "pfb_va_if1 X or Z")
  u_ovl_intf_x_15 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_valid_if1),
    .test_expr (pfb_va_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_first_if1 X or Z")
  u_ovl_intf_x_16 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_valid_if1),
    .test_expr (pfb_first_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_valid_if1 X or Z")
  u_ovl_intf_x_17 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (pfb_valid_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_force_if1 X or Z")
  u_ovl_intf_x_18 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (pfb_force_if1));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_utlb_hit_if2 X or Z")
  u_ovl_intf_x_19 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_alive),
    .test_expr (pfb_utlb_hit_if2));

  assert_never_unknown #(`OVL_FATAL, 2, `OVL_ASSERT, "pfb_state_if2 X or Z")
  u_ovl_intf_x_20 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_alive),
    .test_expr (pfb_state_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_ns_dsc_if2 X or Z")
  u_ovl_intf_x_21 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_utlb_hit_if2),
    .test_expr (pfb_ns_dsc_if2));

  assert_never_unknown #(`OVL_FATAL, 12, `OVL_ASSERT, "pfb_va_if2 X or Z")
  u_ovl_intf_x_22 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (pfb_va_if2[14:3]));

  assert_never_unknown #(`OVL_FATAL, 36, `OVL_ASSERT, "pfb_pa_if2 X or Z")
  u_ovl_intf_x_23 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_utlb_hit_if2),
    .test_expr (pfb_pa_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_kill_if2 X or Z")
  u_ovl_intf_x_24 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (pfb_kill_if2));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "pfb_attributes_if2 X or Z")
  u_ovl_intf_x_25 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_utlb_hit_if2),
    .test_expr (pfb_attributes_if2));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pfb_priv_if2 X or Z")
  u_ovl_intf_x_26 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_utlb_hit_if2),
    .test_expr (pfb_priv_if2));

  assert_never_unknown #(`OVL_FATAL, 19, `OVL_ASSERT, "pfb_pdc_ctl_if3 & (pdc_mask) X or Z")
  u_ovl_intf_x_27 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (1'b1),
    .test_expr (pfb_pdc_ctl_if3 & (pdc_mask)));

  assert_never_unknown #(`OVL_FATAL, 29, `OVL_ASSERT, "pfb_pdc_data_if3 X or Z")
  u_ovl_intf_x_28 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (pfb_pdc_ctl_if3[0]),
    .test_expr (pfb_pdc_data_if3));

  assert_never_unknown #(`OVL_FATAL, 80, `OVL_ASSERT, "pfb_mbist_data X or Z")
  u_ovl_intf_x_29 (
    .clk       (clk),
    .reset_n   (reset_n),
    .qualifier (|icb_mbist_en_reg),
    .test_expr (pfb_mbist_data));


  assign pdc_mask  = { {17{pfb_pdc_ctl_if3[0]}},1'b1 };
  // ------------------------------------------------------
  // Fetch interface description
  // ------------------------------------------------------
  // icb_flush_btic:
  // used by the Pre Fetch to flush logic which is cache sensitive

  // icb_busy_if1:
  // During cp15 operation any Pre Fetch cacheable request must stall in order
  // to give the cp15 time to complete. During this period the Pre Fetch must
  // be aware of the fact that it cannot move to if2

  // icb_data_if2:
  // This bus carries between one and four complete instructions from
  // the ICB to the PFB.  The instructions can only come from the
  // instruction cache and the bus is always signalled in the if2
  // stage and is only valid when the icb_hit_if2 signal is asserted.
  //
  // The bus does not signal pre-decoded instructions that had to go
  // back through the pre-decode process because of an error.

  // icb_lfb_data_if2:
  // This bus is similar in intent to the icb_data_if2, but instead
  // carries instructions from the line fill buffer to the Pre Fetch when
  // a cache miss has occurred.  The reason for muxing the LFB with the
  // instruction cache in the Pre Fetch rather than the Instruction Cache is so that we
  // can do other muxing at the same time, but hide their timing
  // penalty.
  //
  // If we are in debug state this bus carries the predecoded debug
  // instructions from the Instruction Cache to the Pre Fetch.

  // icb_hit_if2:
  // This signal is asserted when an instruction cache hit occurs.  It
  // indicates to the Pre Fetch that the instruction bus is now valid.  The
  // outstanding request in the Pre Fetch will stall in the if2 pipeline
  // stage until either there is a cache/LFB hit, there is an AXI
  // abort or a force occurs in the Pre Fetch.
  //
  // If pfb_kill_if2 is signalled the icb_hit_if2 signal can still
  // occur which doesn't matter as either an abort will be clocked
  // into if3 or all of the valid signals will be cleared.  Trying to
  // suppress the icb_hit_if2 signal with pfb_kill_if2 would affect
  // timing with no clear functional benefit.
  //
  // It is not possible for the icb_hit_if2 signal to be asserted in
  // the same cycle as icb_lfb_hit_if2.

  // icb_lfb_hit_if2:
  // This signal is asserted when a line fill buffer hit occurs.  It
  // indicates to the Pre Fetch that the line fill buffer bus is now valid.
  // The outstanding request in the Pre Fetch will stall in the if2 pipeline
  // stage until either there is a cache/LFB hit, there is an AXI
  // abort or a force occurs in the Pre Fetch.
  //
  // If pfb_kill_if2 is signalled the icb_hit_if2 signal can still
  // occur which doesn't matter as either an abort will be clocked
  // into if3 or all of the valid signals will be cleared.  Trying to
  // suppress the icb_lfb_hit_if2 signal with pfb_kill_if2 would
  // affect timing with no clear functional benefit.
  //
  // It is not possible for the icb_hit_if2 signal to be asserted in
  // the same cycle as icb_lfb_hit_if2.

  // icb_dbg_hit_if2:
  // If the processor is in debug state, this signal is used to
  // indicate to the Pre Fetch that there is valid debug data on the line
  // fill buffer bus.
  // It is not possible for the icb_hit_if2 signal to be asserted in
  // the same cycle as icb_dbg_hit_if2.
  // It is not possible for the icb_lfb_hit_if2 signal to be asserted in
  // the same cycle as icb_dbg_hit_if2.
  // It is not possible for a PFB request (pfb_valid_if1) to be asserted
  // in the same cycle as icb_dbg_hit_if2.
  // It is not possible for a PFB pre decoder correction request (pfb_pdc_ctl_if3[0])
  // to be asserted in the same cycle as icb_dbg_hit_if2.
  // It is not possible for an mbist request (icb_mbist_en) to be
  // asserted in the same cycle as icb_dbg_hit_if2.

  // icb_way_if2:
  // This signal indicates which cache way the fetch hit.  If a
  // pre-decode error is detected this information is used to ensure
  // the corrected error is written back to the cache way that the
  // fetch originated from. It is a zero one hot encoding.

  // icb_ext_abort_if2:
  // Indicates to the Pre Fetch that a fetch abort has occurred due to an AXI
  // error.  This is always signalled to the Pre Fetch in the if2 stage
  // where the associated transaction is stalled waiting for data.
  // The Pre Fetch will immediately unstall and process the abort in the if3
  // stage.

  // icb_ext_abort_type_if2:
  // When the icb_ext_abort_if2 signal is asserted the
  // icb_ext_abort_type_if2 indicates what type of AXI error occurred
  // (decode or slave).
  // 2'b00 = SLAVE
  // 2'b01 = DECODE
  // 2'b10 = ECC

  // pfb_va_if1:
  // The Pre Fetch provides a fully formed (no further modification
  // required) address in the if1 stage for use in addressing the
  // instruction RAMs and for the main TLB.  The address is only valid
  // if the pfb_valid_if1 signal is asserted.  This is a virtual
  // address only and the Instruction Cache only needs bits 14:3.

  // pfb_first_if1:
  // The access is either the first non-sequential fetch (due to a
  // force caused by a branch/return) or a sequential fetch that
  // crosses a cache line boundary.  This signal is only valid when
  // the pfb_valid_if1 signal is asserted, but can be asserted when
  // the pfb_valid_if1 signal is not asserted due to a micro-TLB miss
  // or an incomplete fetch.

  // pfb_valid_if1:
  // Indicates that there is a valid request in the if1 stage.  The
  // Pre Fetch assumes that a read request takes priority over all other Instruction Cache
  // operations so there is no if1 stage stalling mechanism from the
  // Instruction Cache to the Pre Fetch.  If the previous request in the if2 stage misses
  // the instruction cache then the if1 stage will stall.  However,
  // the Pre Fetch will continue to signal pfb_valid_if1 during the stall so
  // the Instruction Cache is responsible for suppressing the enable into the RAMs
  // until the previous request has been completed.
  //
  // Furthermore, the pfb_valid_if1 signal is too timing critical to
  // factor in the uTLB hit/miss evaluation.  The pfb_valid_if1 signal
  // is asserted speculatively and if a uTLB miss occurs then the Pre Fetch
  // pipeline will not move from if1 into if2, but the Instruction Cache will accept
  // the request.  Therefore the Instruction Cache will have to then suppress this
  // request in the if2 stage which it does if the pfb_utlb_hit_if2
  // signal is not asserted.
  //
  // Finally, if the Instruction Cache signals that it is busy due a CP15 operation
  // the pfb_valid_if1 signal will remain asserted, but the request
  // will be stalled in if1.

  // pfb_force_if1:
  // Indicates that the Pre Fetch was forced on the previous cycle either by
  // the DPU (exception or branch mis-predict) or from the Pre Fetch due to
  // branch prediction in the if3 stage.  The signal will only be
  // asserted for a single cycle for each force, but because there can
  // be multiple back-to-back forces it can be asserted for
  // consecutive cycles (e.g. Pre Fetch if3 force, followed by DPU Wr branch
  // mispredict, followed by DPU Ret imprecise abort).

  // pfb_utlb_hit_if2:
  // If a valid request is made in the if1 stage with the
  // pfb_valid_if1 signal and the request subsequently missed the uTLB
  // the Pre Fetch must tell the Instruction Cache to suppress the request in the if2
  // stage by not asserting the pfb_utlb_hit_if2 signal.
  //
  // This signal stays high during a cache miss stall until a hit
  // (icb_hit_if2 or icb_lfb_hit_if2) occurs.
  //
  // If the access is sequential (ie pfb_first_if1 was low in the if1 stage)
  // then pfb_utlb_hit_if2 must be high in the if2 stage.
  //
  // For a uTLB miss, once the correct TLB entry has been fetched the request
  // will be issued again.

  // pfb_state_if2:
  // The architectural state of the processor for comparison with the
  // architectural state stored in the tag that indicates what state
  // the cache line was pre-decoded in.  The pfb_state_if2 signal must hold
  // its value while the request is in if2.

  // pfb_ns_dsc_if2:
  // The security state stored in the micro-TLB for comparison with
  // the security state stored in the tag.  The pfb_ns_dsc_if2 signal must
  // hold its value while the request is in if2.

  // pfb_va_if2:
  // The virtual address bus in if2.  This bus comes directly from
  // registers.

  // pfb_pa_if2:
  // The pfb_pa_if2 signal provides the complete address for the
  // instruction tag compare.  If a cache miss occurs the address is
  // used by the Instruction Cache for predecoding the incoming instructions from
  // main memory - the Instruction Cache needs to know which is the critical first
  // word to start pre-decoding from.
  // This signal holds its value until a hit (icb_hit_if2 or icb_lfb_hit_if2)
  // occurs.

  // pfb_kill_if2:
  // The outstanding request issued in the if1 stage should be killed
  // due to either a force, TLB abort or because the Pre Fetch is stopped
  // pending entry to debug or a predicted branch is occurring whose
  // destination can not be calculated.

  // pfb_attributes_if2:
  // The pfb_attributes bus signals the cacheable/shareable attributes
  // of the request signalled in if2.  This signal is only valid if the
  // pfb_valid_if1 signal was valid in the cycle before  and the uTLB hit.
  // This signal holds its value until a hit (icb_hit_if2 or icb_lfb_hit_if2)
  // occurs.
  // See cortexa53params for the encoding.
  //
  // pfb_priv_if2:
  // The pfb_priv states whether the request is privileged rather than
  // user-mode. It is only valid if the pfb_valid_if1 signal was valid in the
  // cycle before and the uTLB hit.
  // This signal holds its value until a hit (icb_hit_if2 or icb_lfb_hit_if2)
  // occurs.

  // ------------------------------------------------------
  // Pre-decode error correction interface description
  // ------------------------------------------------------

  // icb_pdc_valid_if2:
  // Indicates to the Pre Fetch that an error has been corrected.  This
  // should be signalled for one-cycle only!  If it isn't then held
  // state inside the Pre Fetch can become invalid.
  //
  // Single cycle behaviour can be enforced by using the
  // pfb_pdc_ctl_if3[0] signal for suppression once the icb_valid_if2
  // signal is asserted.  For example, something like:
  // icb_pdc_valid_if2 = pfb_pdc_ctl_if3[0] & error_fixed;
  //
  // If the DPU signals a force to the Pre Fetch while the Instruction Cache is attempting
  // to fix a pre-decode error the Pre Fetch will ignore the response from
  // the Instruction Cache (indeed, pfb_pdc_ctl_if3[0] will be deasserted on a force).

  // icb_pdc_data_if2:
  // Corrected instruction from the Instruction Cache to the Pre Fetch.  Whatever is on
  // this bus when the icb_pdc_valid_if2 is signalled will be clocked
  // into the Pre Fetch.

  // pfb_pdc_ctl_if3[0]:
  // Indicates to the Instruction Cache that a pre-decode error has occurred and that
  // the data on the pfb_pdc_data_if3 bus requires another pass
  // through the pre-decoder.  This signal will remain asserted until
  // the fixed instruction is passed back to the Pre Fetch.

  // pfb_pdc_ctl_if3[14:1]:
  // Virtual address of the instruction that has a pre-decode error.
  // The Instruction Cache requires this in order to write the fixed instruction
  // back to the instruction cache. Since it could cross a fetch
  // boundary within the same cache line, it could take two cycles to
  // write.  Because the instruction is aligned to 16-bit boundaries
  // the address must be [14:1]

  // pfb_pdc_ctl_if3[16:15]
  // pfb_pdc_ctl_if3[18:17]
  // Instruction cache way that the fetch originated from so that the
  // Instruction Cache knows which cache way to write the error back too.
  // It is a zero one hot encoding
  // When the instruction to correct spun across two cache lines the
  // way can be different hence pfb_pdc_ctl_if3[16:15] represent
  // the first half word and pfb_pdc_ctl_if3[18:17] the second one.
  // A value of zero during a request refers to a non cacheable request
  // or a request that we do not want to put in to the cache due to
  // the risk of corruption (e.g. if the MMU has been turned off/on
  // and fetches from different PAs have occurred we don't want to over-
  // write a new value in the cache with an old value on a PDC correction).

  // pfb_pdc_data_if3:
  // Holds the instruction with the pre-decode error.  The instruction
  // is always in Thumb-32 format and the Pre Fetch recreates the original
  // 32-bit format fetched from main memory (T32B[31:16],T32A[15:0]).

  // ------------------------------------------------------
  // Signal generation for OVLs
  // ------------------------------------------------------

  // we need to create a window to mimic the fact that the Pre Fetch while is waiting for
  // an lfb_hit to come back will hold the if2 signals.
  assign ovl_wait_for_lfb_if2 = pfb_valid_if1_reg & ~ovl_wait_for_lfb & ~ovl_wait_for_lfb_end & pfb_utlb_hit_if2 & ~pfb_kill_if2;
  assign ovl_wait_for_lfb_end = icb_hit_if2 | icb_lfb_hit_if2 | pfb_kill_if2 | pfb_force_if1;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_wait_for_lfb <= 1'b0;
  else
    ovl_wait_for_lfb <= (ovl_wait_for_lfb & ~ovl_wait_for_lfb_end) | ovl_wait_for_lfb_if2;



  // Track whether a request is valid or not.
  // This can then be used to control the hit inputs
  assign push_rqst  = pfb_valid_if1 & (~(ovl_wait_for_lfb | ovl_wait_for_lfb_if2) | ovl_wait_for_lfb_end);
  assign pop_rqst   = (icb_hit_if2 | icb_lfb_hit_if2 | pfb_kill_if2 | (pfb_force_if1 & rqst_cnt != 3'b000) | (~pfb_utlb_hit_if2 & push_rqst_reg));


  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    rqst_cnt <= 3'b000;
  else
    rqst_cnt <= ((push_rqst & pop_rqst) ? rqst_cnt :  ((push_rqst) ? (rqst_cnt + 3'b001) : ((pop_rqst) ? (rqst_cnt - 3'b001) : rqst_cnt)));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive  => ~((rqst_cnt == 4'h3 & pfb_utlb_hit_if2) | rqst_cnt == 4'h4 | rqst_cnt == 4'h5 | rqst_cnt == 4'h6 | rqst_cnt == 4'h7)")
  u_ovl_intf_assert_30 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive ),
    .consequent_expr (~((rqst_cnt == 4'h3 & pfb_utlb_hit_if2) | rqst_cnt == 4'h4 | rqst_cnt == 4'h5 | rqst_cnt == 4'h6 | rqst_cnt == 4'h7)));


  // ------------------------------------------------------
  // MBIST data bus
  // ------------------------------------------------------
  // During an MBIST operation we are going to re use the icb_data_if2 bus
  // in order to save some registers. An enable signal will tell the PFB when
  // to read the data and register it back to the ICB in the next cycle

  // Assertions for icb_mbist_en:
  //
  // Enable signal during MBIST operation to signal that valid data
  // is available. MBIST ops are in isolation but they could start in the middle of any op.
  // Nevertheless when an MBIST read op is undergoing no ICB hit can be seen because the PFB req must
  // have gone down few cycles before

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_mbist_en[0] => ~icb_hit_if2")
  u_ovl_intf_assume_31 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_mbist_en[0]),
    .consequent_expr (~icb_hit_if2));

  // icb_mbist_en[2:1] indicate that MBIST data is coming from the BTAC {stage1,
  // stage0} RAMs rather than icb_data_if2.  If either of these bits are set
  // then icb_mbist_en[0] must also be set.
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "(|icb_mbist_en[2:1]) => icb_mbist_en[0]")
  u_ovl_intf_31a (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_mbist_en[2] | icb_mbist_en[1]),
    .consequent_expr (icb_mbist_en[0]));

  // icb_mbist_en[2:1] are one-hot because MBIST data can come from at most one
  // BTAC RAM
  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "icb_mbist_en[2:1] should be zero or one-hot")
  u_ovl_intf_31b (
    .clk         (clk),
    .reset_n     (reset_n),
    .test_expr   (icb_mbist_en[2:1]));

  // Assertions for pfb_mbist_data:
  //
  // Data bus contains the MBIST data for non-BTAC reads one cycle later it has
  // been seen in icb_data_if2

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_mbist_en[0]@1 & ~icb_mbist_en[1]@1 & ~icb_mbist_en[2]@1 => pfb_mbist_data == icb_data_if2@1")
  u_ovl_intf_assert_32 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_mbist_en_reg[0] & ~icb_mbist_en_reg[1] & ~icb_mbist_en_reg[2]),
    .consequent_expr (pfb_mbist_data == icb_data_if2_reg));


  // ------------------------------------------------------
  // Fetch interface OVLs
  // ------------------------------------------------------

  // Guidance for OVLs:
  // - When is the signal valid?
  // - When is the signal not valid?
  // - When does the signal change?
  // - When does the signal remain the same?
  // - Can the signal be asserted for consecutive cycles?


  // Assertions for pfb_first_if1:
  //
  // If the pfb_first_if1 signal is not asserted the virtual address must
  // increment sequentially.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_valid_if1 & ~pfb_first_if1  => ((pfb_va_if1[14:3] == pfb_va_if1[14:3]@1 + 1'b1) | (pfb_va_if1[14:3] == pfb_va_if1[14:3]@1))")
  u_ovl_intf_assert_33 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_valid_if1 & ~pfb_first_if1 ),
    .consequent_expr (((pfb_va_if1[14:3] == pfb_va_if1_reg[14:3] + 1'b1) | (pfb_va_if1[14:3] == pfb_va_if1_reg[14:3]))));


  // Assertions for pfb_valid_if1:
  //
  // The pfb_valid_if1 signal will be deasserted after a micro-TLB miss unless a
  // force occurred in the same cycle.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_valid_if1@1 & ~pfb_utlb_hit_if2 & ~pfb_kill_if2  => ~pfb_valid_if1")
  u_ovl_intf_assert_34 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_valid_if1_reg & ~pfb_utlb_hit_if2 & ~pfb_kill_if2 ),
    .consequent_expr (~pfb_valid_if1));


  // Assertions for pfb_utlb_hit_if2:
  //
  // Once asserted the pfb_utlb_hit_if2 signal can only change on the cycle after
  // pfb_valid_if1.  It will be asserted on a hit when a request was made on the
  // previous cycle and will remain asserted until the next miss occurs unless the caches have changed.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & (pfb_utlb_hit_if2 ^ pfb_utlb_hit_if2@1)  => pfb_valid_if1@1")
  u_ovl_intf_assert_35 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & (pfb_utlb_hit_if2 ^ pfb_utlb_hit_if2_reg) ),
    .consequent_expr (pfb_valid_if1_reg));


  // Assertions for pfb_state_if2:
  //
  // The pfb_state_if2 bus should only change on the first cycle of a fetch
  // (actually, it should only change on a flush, but there is no way to
  // prove this on the interface).
  // State encoding allowed :
  // 1'b0 ARM
  // 1'b1 Thumb

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & (pfb_state_if2 != pfb_state_if2@1) & pfb_valid_if1@1 & ~pfb_kill_if2  => pfb_first_if1@1")
  u_ovl_intf_assert_36 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & (pfb_state_if2 != pfb_state_if2_reg) & pfb_valid_if1_reg & ~pfb_kill_if2 ),
    .consequent_expr (pfb_first_if1_reg));


  // Assertions for pfb_ns_dsc_if2:
  //
  // The pfb_ns_dsc_if2 signal should only change on the first cycle of a fetch
  // (actually, it should only change on a flush, but there is no way to prove
  // this on the interface).

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & (pfb_ns_dsc_if2 != pfb_ns_dsc_if2@1) & pfb_utlb_hit_if2  => pfb_first_if1@1")
  u_ovl_intf_assert_37 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & (pfb_ns_dsc_if2 != pfb_ns_dsc_if2_reg) & pfb_utlb_hit_if2 ),
    .consequent_expr (pfb_first_if1_reg));


  // Assertions for pfb_pa_if2:
  //
  // The pfb_pa_if2 bus should only change when pfb_first_if1 is asserted.
  //
  // If a 4K page has been hit pfb_pa_if2[11:3] should be the same as the virtual
  // address from the previous cycle.  If a 1MB page has been hit pfb_pa_if2[19:3]
  // should be the same as the virtual address from the previous cycle.  However,
  // we don't have a page signal on the output so just check pfb_pa_if2[11:3].

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_valid_if1@1 & pfb_utlb_hit_if2 & ~pfb_first_if1@1  => (pfb_pa_if2[39:12] == pfb_pa_if2[39:12]@1)")
  u_ovl_intf_assert_38 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_valid_if1_reg & pfb_utlb_hit_if2 & ~pfb_first_if1_reg ),
    .consequent_expr ((pfb_pa_if2[39:12] == pfb_pa_if2_reg[39:12])));

  // Assertions for pfb_kill_if2:
  //
  // The pfb_kill_if2 signal can only be asserted on the cycle after a new
  // request.
  //
  // If the pfb_force_if1 signal is asserted on the same cycle as the
  // pfb_valid_if1 signal then the pfb_kill_if2 signal will be asserted on the
  // next cycle.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_kill_if2  => pfb_valid_if1@1")
  u_ovl_intf_assert_41 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_kill_if2 ),
    .consequent_expr (pfb_valid_if1_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_valid_if1@1 & pfb_force_if1  => pfb_kill_if2")
  u_ovl_intf_assert_43 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_valid_if1_reg & pfb_force_if1 ),
    .consequent_expr (pfb_kill_if2));



  // Assertions for pfb_attributes_if2:
  //
  // The pfb_attributes_if2 bus should only change on the first cycle of a fetch
  // (actually, it should only change on a flush, but there is no way to prove
  // this on the interface).
  //
  // The pfb_attributes_if2 bus should only present the indicated encodings,
  // unless the pfb_kill_if2 signal is asserted in which case the attributes
  // bus may indicate invalid encodings.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & (pfb_attributes_if2 != pfb_attributes_if2@1) & pfb_utlb_hit_if2  => pfb_first_if1@1")
  u_ovl_intf_assert_44 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & (pfb_attributes_if2 != pfb_attributes_if2_reg) & pfb_utlb_hit_if2 ),
    .consequent_expr (pfb_first_if1_reg));


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Unused attributes passed to the ICB")
  u_ovl_intf_assert_45 (
                        .clk       (clk),
                        .reset_n   (reset_n),
                        .antecedent_expr (pfb_alive & pfb_valid_if1_reg & ~pfb_kill_if2 & pfb_utlb_hit_if2),
                        .consequent_expr (~`CA53_MEM_UNUSED(pfb_attributes_if2)));


  // Assertions for pfb_priv_if2:
  //
  // Once a request reaches the if2 stage the pfb_priv_if2 signal must
  // hold its value

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & pfb_valid_if1@1 & pfb_utlb_hit_if2 & ovl_wait_for_lfb  => (pfb_priv_if2 == pfb_priv_if2@1)")
  u_ovl_intf_assert_49 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & pfb_valid_if1_reg & pfb_utlb_hit_if2 & ovl_wait_for_lfb ),
    .consequent_expr ((pfb_priv_if2 == pfb_priv_if2_reg)));



  // Assertions for stalling:
  //
  // Whilst the Pre Fetch is stalled in the if2 cycle, its signals must remain
  // constant.
  //
  // For the same if2 Pre Fetch stall, if valid was high, the if1 signals must
  // also remain constant.
  //
  // Kill can only be high during the first if2 cycle. It can never stay
  // high during a stall, as we cannot stall if kill was asserted.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_pa_if2         == pfb_pa_if2@1")
  u_ovl_intf_assert_50 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_pa_if2         == pfb_pa_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_state_if2      == pfb_state_if2@1")
  u_ovl_intf_assert_51 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_state_if2      == pfb_state_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_attributes_if2 == pfb_attributes_if2@1")
  u_ovl_intf_assert_52 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_attributes_if2 == pfb_attributes_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_ns_dsc_if2     == pfb_ns_dsc_if2@1")
  u_ovl_intf_assert_53 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_ns_dsc_if2     == pfb_ns_dsc_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_priv_if2       == pfb_priv_if2@1")
  u_ovl_intf_assert_54 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_priv_if2       == pfb_priv_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_utlb_hit_if2 & pfb_utlb_hit_if2@1")
  u_ovl_intf_assert_55 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_utlb_hit_if2 & pfb_utlb_hit_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb  => pfb_va_if2         == pfb_va_if2@1")
  u_ovl_intf_assert_56 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb ),
    .consequent_expr (pfb_va_if2[14:3]   == pfb_va_if2_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb & pfb_valid_if1@1 & ~pfb_kill_if2  => pfb_first_if1 == pfb_first_if1@1")
  u_ovl_intf_assert_57 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb & pfb_valid_if1_reg & ~pfb_kill_if2 ),
    .consequent_expr (pfb_first_if1 == pfb_first_if1_reg));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ovl_wait_for_lfb & pfb_valid_if1@1 & ~pfb_kill_if2  => pfb_va_if1    == pfb_va_if1@1")
  u_ovl_intf_assert_58 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (ovl_wait_for_lfb & pfb_valid_if1_reg & ~pfb_kill_if2 ),
    .consequent_expr (pfb_va_if1[14:3]    == pfb_va_if1_reg));


  // Assertions for the icb_hit_if2:
  //
  // The icb_hit_if2 signal can only be asserted if pfb_valid_if1 was signalled
  // in the last cycle.
  //
  // It is not possible for the icb_hit_if2 and icb_lfb_hit_if2 to occur
  // in the same cycle.
  //
  // If a request is made that hits in micro-TLB, isn't killed and stalls (due to
  // a cache miss) then a cache hit is no longer possible.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_hit_if2  => pfb_valid_if1@1")
  u_ovl_intf_assume_59 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_hit_if2 ),
    .consequent_expr (pfb_valid_if1_reg));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "~(icb_hit_if2 & icb_lfb_hit_if2)")
  u_ovl_intf_assume_60 (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (~(icb_hit_if2 & icb_lfb_hit_if2)));


  // we need to create a window to mimic the fact that during a CP15 operation
  // any cacheable request will be ignored. This can only happen if dpu_icache_on
  // is changing in the middle of the CP15. Because we do not have access to
  // dpu_icache_on we suppress the check during that scenario.
  assign ovl_icb_busy_if2  = ovl_wait_for_lfb_if2 & icb_busy_if1_reg;
  assign ovl_icb_busy_end  = ovl_wait_for_lfb_end;

  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_icb_busy <= 1'b0;
  else
    ovl_icb_busy <= (ovl_icb_busy & ~ovl_icb_busy_end) | ovl_icb_busy_if2;


  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_valid_if1@1 & ovl_wait_for_lfb & ~ovl_icb_busy  => ~icb_hit_if2")
  u_ovl_intf_assume_61 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_valid_if1_reg & ovl_wait_for_lfb & ~ovl_icb_busy ),
    .consequent_expr (~icb_hit_if2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive == 1'b0  => icb_hit_if2 == 1'b0")
  u_ovl_intf_assume_62 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive == 1'b0 ),
    .consequent_expr (icb_hit_if2 == 1'b0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rqst_cnt == 3'b000  => icb_hit_if2 == 1'b0")
  u_ovl_intf_assume_63 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (rqst_cnt == 3'b000 ),
    .consequent_expr (icb_hit_if2 == 1'b0));


  // Assertions for icb_lfb_hit_if2:

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive == 1'b0  => icb_lfb_hit_if2 == 1'b0")
  u_ovl_intf_assume_64 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive == 1'b0 ),
    .consequent_expr (icb_lfb_hit_if2 == 1'b0));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "rqst_cnt == 3'b000  => icb_lfb_hit_if2 == 1'b0")
  u_ovl_intf_assume_65 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (rqst_cnt == 3'b000 ),
    .consequent_expr (icb_lfb_hit_if2 == 1'b0));


  // Assertions for icb_dbg_hit_if2:
  //
  // It is not possible for the icb_hit_if2 signal to be asserted in
  // the same cycle as icb_dbg_hit_if2.
  //
  // It is not possible for the icb_lfb_hit_if2 signal to be asserted in
  // the same cycle as icb_dbg_hit_if2.
  //
  // It is not possible for a PFB request (pfb_valid_if1) to be asserted
  // in the same cycle as icb_dbg_hit_if2.
  //
  // It is not possible for a PFB pre decoder correction request (pfb_pdc_ctl_if3[0])
  // to be asserted in the same cycle as icb_dbg_hit_if2.
  //
  // It is not possible for an mbist request (icb_mbist_en) to be
  // asserted in the same cycle as icb_dbg_hit_if2.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_dbg_hit_if2  => ~icb_hit_if2")
  u_ovl_intf_assume_66 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_dbg_hit_if2 ),
    .consequent_expr (~icb_hit_if2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_dbg_hit_if2  => ~icb_lfb_hit_if2")
  u_ovl_intf_assume_67 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_dbg_hit_if2 ),
    .consequent_expr (~icb_lfb_hit_if2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_dbg_hit_if2  => ~(pfb_valid_if1@1 & ~pfb_kill_if2)")
  u_ovl_intf_assume_68 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_dbg_hit_if2 ),
    .consequent_expr (~(pfb_valid_if1_reg & ~pfb_kill_if2)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_dbg_hit_if2  => ~pfb_pdc_ctl_if3[0]")
  u_ovl_intf_assert_69 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_dbg_hit_if2 ),
    .consequent_expr (~pfb_pdc_ctl_if3[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_dbg_hit_if2  => ~icb_mbist_en[0]")
  u_ovl_intf_assume_70 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_dbg_hit_if2 ),
    .consequent_expr (~icb_mbist_en[0]));

  // Assertions for icb_way_if2:
  //
  // The icb_way_if2 bus is assumed to be zero one-hot

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_way_if2[1]  => ~icb_way_if2[0]")
  u_ovl_intf_assume_72 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_way_if2[1] ),
    .consequent_expr (~icb_way_if2[0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_way_if2[0]  => ~icb_way_if2[1]")
  u_ovl_intf_assume_73 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_way_if2[0] ),
    .consequent_expr (~icb_way_if2[1]));


  // Assertions for icb_ext_abort_if2:
  //
  // If a request has an AXI error then the cache hit signal will not be asserted
  //
  // The icb_ext_abort_if2 can only be asserted if a valid request was made, but
  // not yet completed.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_ext_abort_if2  => ~icb_hit_if2")
  u_ovl_intf_assume_74 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_ext_abort_if2 ),
    .consequent_expr (~icb_hit_if2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_ext_abort_if2  => icb_lfb_hit_if2 | (pfb_kill_if2 & push_rqst@1) | (~pfb_utlb_hit_if2 & push_rqst@1)")
  u_ovl_intf_assume_75 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_ext_abort_if2 ),
    .consequent_expr (icb_lfb_hit_if2 | (pfb_kill_if2 & push_rqst_reg) | (~pfb_utlb_hit_if2 & push_rqst_reg)));


  // Assertions for icb_ext_abort_type_if2:
  //
  // None beyond the basic X/Z check.


  // Assertions for icb_busy_if1:
  //
  // When the icb_busy is asserted any pfb_valid outstanding plus
  // any pfb_valid coming at the same cycle must complete, but
  // after that no new pfb_valid are allowed.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_alive & icb_busy_if1@1  => ~pfb_valid_if1")
  u_ovl_intf_assert_76 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_alive & icb_busy_if1_reg ),
    .consequent_expr (~pfb_valid_if1));


  // ------------------------------------------------------
  // Pre-decode error correction interface OVLs
  // ------------------------------------------------------

  // Assertions for pfb_pdc_ctl_if3[0]:
  //
  // The pfb_pdc_data_if3 bus should remain the same while the pfb_pdc_ctl_if3[0]
  // signal is asserted.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[0]@1 & ~icb_pdc_valid_if2@1  => pfb_pdc_data_if3 == pfb_pdc_data_if3@1")
  u_ovl_intf_assert_77 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3_reg[0] & ~icb_pdc_valid_if2_reg ),
    .consequent_expr (pfb_pdc_data_if3 == pfb_pdc_data_if3_reg));


  // Assertions for pfb_pdc_ctl_if3[14:1]:
  //
  // The  pfb_pdc_ctl_if3[14:1] bus should remain the same while the pfb_pdc_ctl_if3[0]
  // signal is asserted.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] &  pfb_pdc_ctl_if3[0]@1 & ~icb_pdc_valid_if2@1  => pfb_pdc_ctl_if3[14:1] == pfb_pdc_ctl_if3[14:1]@1")
  u_ovl_intf_assert_78 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] &  pfb_pdc_ctl_if3_reg[0] & ~icb_pdc_valid_if2_reg ),
    .consequent_expr (pfb_pdc_ctl_if3[14:1] == pfb_pdc_ctl_if3_reg[14:1]));


  // Assertions for pfb_pdc_ctl_if3[18:15]:
  //
  // Way for predecode errors can only be one hot within their half word

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[15]  => ~pfb_pdc_ctl_if3[16]")
  u_ovl_intf_assert_79 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[15] ),
    .consequent_expr (~pfb_pdc_ctl_if3[16]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[16]  => ~pfb_pdc_ctl_if3[15]")
  u_ovl_intf_assert_80 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[16] ),
    .consequent_expr (~pfb_pdc_ctl_if3[15]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[17]  => ~pfb_pdc_ctl_if3[18]")
  u_ovl_intf_assert_81 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[17] ),
    .consequent_expr (~pfb_pdc_ctl_if3[18]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[18]  => ~pfb_pdc_ctl_if3[17]")
  u_ovl_intf_assert_82 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[18] ),
    .consequent_expr (~pfb_pdc_ctl_if3[17]));


  // The pfb_pdc_ctl_if3[18:15] bus should remain the same while the pfb_pdc_ctl_if3[0]
  // signal is asserted.

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[0]@1 & ~icb_pdc_valid_if2@1  => pfb_pdc_ctl_if3[16:15] == pfb_pdc_ctl_if3[16:15]@1")
  u_ovl_intf_assert_83 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3_reg[0] & ~icb_pdc_valid_if2_reg ),
    .consequent_expr (pfb_pdc_ctl_if3[16:15] == pfb_pdc_ctl_if3_reg[16:15]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3[0]@1 & ~icb_pdc_valid_if2@1  => pfb_pdc_ctl_if3[18:17] == pfb_pdc_ctl_if3[18:17]@1")
  u_ovl_intf_assert_84 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3[0] & pfb_pdc_ctl_if3_reg[0] & ~icb_pdc_valid_if2_reg ),
    .consequent_expr (pfb_pdc_ctl_if3[18:17] == pfb_pdc_ctl_if3_reg[18:17]));


  // Assertions for icb_pdc_valid_if2:
  //
  // The predecode error corrected signal (icb_pdc_valid_if2) should only
  // be asserted for one cycle.
  //
  // The ack must be a pulse

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_pdc_valid_if2@1  => ~icb_pdc_valid_if2")
  u_ovl_intf_assume_85 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_pdc_valid_if2_reg ),
    .consequent_expr (~icb_pdc_valid_if2));

  // back to back pdc requests are not allowed

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_pdc_valid_if2@1  => ~pfb_pdc_ctl_if3[0]")
  u_ovl_intf_assert_86 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_pdc_valid_if2_reg ),
    .consequent_expr (~pfb_pdc_ctl_if3[0]));

  // The ack must always go high after a request

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "icb_pdc_valid_if2  => pfb_pdc_ctl_if3[0]@1")
  u_ovl_intf_assume_87 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (icb_pdc_valid_if2 ),
    .consequent_expr (pfb_pdc_ctl_if3_reg[0]));


  // a pre decoder error request and a PFB request in the previous cycle and a PFB request in this cycle
  // imply that the predecode error is not on a fetch line boundary

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "pfb_pdc_ctl_if3[0]@1 & pfb_pdc_ctl_if3[0] & ~icb_pdc_valid_if2@1 & pfb_valid_if1@1 & ~ovl_wait_for_lfb & (pfb_pdc_ctl_if3[2:1]@1 == 2'b11)  => ~pfb_valid_if1")
  u_ovl_intf_assert_88 (
    .clk       (clk),
    .reset_n   (reset_n),
    .antecedent_expr (pfb_pdc_ctl_if3_reg[0] & pfb_pdc_ctl_if3[0] & ~icb_pdc_valid_if2_reg & pfb_valid_if1_reg & ~ovl_wait_for_lfb & (pfb_pdc_ctl_if3_reg[2:1] == 2'b11) ),
    .consequent_expr (~pfb_valid_if1));

  // debug_catch: If dpu_reset_catch_pending or dpu_reset_catch_pending is set we should not send an external request
  reg ovl_reg_ifu_arvalid;
  reg ovl_reg_debug_catch;
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_reg_ifu_arvalid  <= 1'b0;
    ovl_reg_debug_catch  <= 1'b0;
  end else begin
    ovl_reg_ifu_arvalid  <= ifu_arvalid_o;
    ovl_reg_debug_catch  <= dpu_reset_catch_pending_i | dpu_expt_catch_pending_i;
  end
  assert_never  #(`OVL_FATAL, `OVL_ASSERT, "debug_catch asserted and external request sent")
  ovl_debug_catch (.clk       (clk),
                   .reset_n   (reset_n),
                   .test_expr (ovl_reg_debug_catch & ifu_arvalid_o & ~ovl_reg_ifu_arvalid));


  // Exception level from TLB
  // we need to capture the exception level at the time the request was made
  reg [1:0] ovl_el;
  reg       ovl_ns;
  wire      ovl_uTLB_miss_req;
  reg       ovl_prev_utlb_miss_req;
  // register uTLB miss req
  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_prev_utlb_miss_req <= 1'b0;
  else
    ovl_prev_utlb_miss_req <= ifu_utlb_miss_req_o;
  // decide when a request to TLB has started
  assign ovl_uTLB_miss_req = ifu_utlb_miss_req_o & ~ovl_prev_utlb_miss_req;
  // capturing the EL at the time of the request was made
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_el <= 2'b00;
    ovl_ns <= 1'b0;
  end else if (ovl_uTLB_miss_req) begin
    ovl_el <= dpu_exception_level_i;
    ovl_ns <= dpu_ns_state_i;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU EL == EL3 and AArch64 and TLB EL != EL3")
  u_ovl_tlb_el_3 (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (tlb_i_utlb_enable_i & tlb_i_utlb_valid_i & ovl_el == `CA53_EL3 & dpu_aarch64_at_el_i[3]),
                  .consequent_expr (tlb_i_utlb_data_i[67:66] == `CA53_EL3));
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU EL == EL2 and TLB EL != EL2")
  u_ovl_tlb_el_2 (.clk             (clk),
                  .reset_n         (reset_n),
                  .antecedent_expr (tlb_i_utlb_enable_i & tlb_i_utlb_valid_i & ovl_el == `CA53_EL2),
                  .consequent_expr (tlb_i_utlb_data_i[67:66] == `CA53_EL2));
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "DPU EL != EL2 and DPU EL != EL3 in AArch64 and TLB EL != EL0")
  u_ovl_tlb_el_0 (.clk       (clk),
                  .reset_n    (reset_n),
                  .antecedent_expr (tlb_i_utlb_enable_i & tlb_i_utlb_valid_i & ~(ovl_el == `CA53_EL2) & ~(ovl_el == `CA53_EL3 & dpu_aarch64_at_el_i[3])),
                  .consequent_expr (tlb_i_utlb_data_i[67:66] == `CA53_EL0));
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "TLB fault stage2 can only be in non secure and EL < EL2")
  u_ovl_tlb_constraint_0 (.clk       (clk),
                          .reset_n    (reset_n),
                          .antecedent_expr (tlb_i_utlb_enable_i & ~tlb_i_utlb_valid_i & tlb_i_utlb_data_i[80]),
                          .consequent_expr ((ovl_el < `CA53_EL2) & ovl_ns));
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "TLB Execute always s2 clear can only be in non secure and EL < EL2")
  u_ovl_tlb_constraint_1 (.clk       (clk),
                          .reset_n    (reset_n),
                          .antecedent_expr (tlb_i_utlb_enable_i & tlb_i_utlb_valid_i & ~tlb_i_utlb_data_i[94]),
                          .consequent_expr ((ovl_el < `CA53_EL2) & ovl_ns));

  reg ovl_in_debug_state;
  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    ovl_in_debug_state <= 1'b0;
  else if (dpu_fe_valid_ret_i)
    ovl_in_debug_state <= dpu_halt_ifu_i;

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "While in debug we do not expect breakpoints or vector catch")
  u_ovl_tlb_constraint_2 (.clk       (clk),
                          .reset_n    (reset_n),
                          .antecedent_expr (ovl_in_debug_state),
                          .consequent_expr ((tlb_bkpt_hit_if2_i == 4'b0000) & (tlb_vcr_hit_if2_i == 2'b00)));

  // while mbist asserted only a force from ret will arrive never a force from wr
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "MBIST set and force from WR seen")
  u_ovl_mbist_constraint_0 (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (gov_mbist_req_i & dpu_fe_valid_wr_i));

  assert_never #(`OVL_FATAL, `OVL_ASSERT, "MBIST set and debug enter seen")
  u_ovl_mbist_constraint_1 (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr (gov_mbist_req_i & dpu_fe_valid_ret_i & dpu_halt_ifu_i));

  // Out of reset until first force from ret only inval all operations are allowed
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only INVAL ALL ops are allowed before first force from Ret")
  u_ovl_cp15_constraint_0 (.clk       (clk),
                           .reset_n    (reset_n),
                           .antecedent_expr (~pfb_alive & (dcu_cp_valid_ifu_i | dcu_dvm_valid_ifu_i)),
                           .consequent_expr (dcu_cp_op_ifu_i == `CA53_CP_ICACHE_INV_ALL));

`endif //  `ifdef ARM_ASSERT_ON


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_dcu_ifu_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
