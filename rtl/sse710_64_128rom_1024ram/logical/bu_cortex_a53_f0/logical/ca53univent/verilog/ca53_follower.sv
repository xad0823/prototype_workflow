//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53dpu_params.v"
`include "ca53_dpu_dcu_defs.v"
`include "ca53_biu_scu_defs.v"

`define DPU_PATH u_ca53dpu
`define DCU_PATH u_ca53dcu
`define TLB_PATH u_ca53tlb

`define SIDEBAND_UNDEF 6'b000000

module ca53_follower `CA53_NORAM_PARAM_DECL;

  reg              [63:0] cycle_count;
  reg               [8:0] dpu_cp_op_ex1;
  reg               [8:0] dpu_cp_op_ex2;
  reg               [8:0] dpu_cp_op_wr;
  wire             [63:0] instr_count_wr;
  reg              [63:0] prev_instr_count_wr;
  reg              [63:0] instr_count_f4;
  reg              [63:0] instr_count_f5;
  reg              [63:0] instr_count_f5_reg;
  reg                     end_instr_f4;
  reg                     end_instr_f5;
  reg                     instr_in_progress;
  reg              [31:0] opcode0_ex1;
  reg              [31:0] opcode0_ex2;
  reg              [31:0] opcode0_iss;
  reg              [31:0] opcode0_wr;
  reg              [31:0] opcode0_wr_reg;
  reg              [31:0] opcode1_ex1;
  reg              [31:0] opcode1_ex2;
  reg              [31:0] opcode1_iss;
  reg              [31:0] opcode1_wr;
  reg              [31:0] opcode1_wr_reg;
 
  wire                    sideband_undef0_de;
  wire                    sideband_undef1_de;
  reg                     sideband_undef0_iss;
  reg                     sideband_undef0_ex1;
  reg                     sideband_undef0_ex2;
  reg                     sideband_undef0_wr;   
  reg                     sideband_undef1_iss;
  reg                     sideband_undef1_ex1;
  reg                     sideband_undef1_ex2;
  reg                     sideband_undef1_wr;

  wire                    sideband_hw_bkpt_vc0_de;
  reg                     sideband_hw_bkpt_vc0_iss;
  reg                     sideband_hw_bkpt_vc0_ex1;
  reg                     sideband_hw_bkpt_vc0_ex2;
  reg                     sideband_hw_bkpt_vc0_wr;   
   
  reg                     second_x64_ex1;
  reg                     second_x64_ex2;
  reg                     second_x64_wr;  
  reg                     size_instr1_wr;
  reg              [63:0] x64_addr;
  reg              [4:0]  dpu_length_ex1;
  reg              [4:0]  dpu_length_ex2;             
  reg              [4:0]  dpu_length_wr;
  reg                     instr_sample_f4;
  reg                     instr_sample_f5;

  wire                    aarch64_state;
  wire                    cc_pass_instr0_wr;
  wire                    cc_pass_instr1_wr;
  wire                    clk;
  wire              [7:0] gov_clusteridaff2;
  wire              [7:0] gov_clusteridaff1;
  wire             [31:0] cp_hcr;
  wire                    cp_valid_wr;
  wire             [31:0] cpsr_ret;
  wire              [1:0] cpu_id;
  wire                    dbg_halted;
  wire                    dcu_exclusive_dc3;
  wire             [63:0] dcu_ld_data_dc3;
  wire             [63:0] dcu_va_dc3;
  wire                    dcu_valid_dc3;
  wire                    dcu_dsc_dc3;
  wire             [39:0] dcu_pa_dc3;
  wire              [7:0] attrs_dc3; 
  wire                    ldar_stlr_dc3;
  wire                    ns_dsc_dc3;
  wire                    dcu_strex_okay_dc3;
  wire              [8:0] dpu_cp_op_iss;
  wire                    dpu_kill_wr;
  wire                    dpu_ready_wr;
  wire            [127:0] dpu_st_data_wr;
  wire              [4:0] dpu_length_iss;
  wire                    dcu_p_abort_dc3;
  wire                    dcu_wpt_hit_dc3;
  wire                    en_fpexc_reg_f5;
  wire                    en_fpscr_reg_f5;
  wire                    end_instr_wr;
  wire              [3:0] expt_state;
  wire                    first_x64_wr;
  wire                    flush_ret;
  wire                    slot0_br_flush_wr;
  wire             [35:0] icu_encoding0;
  wire             [35:0] icu_encoding1;
  wire             [63:0] instr0_addr_wr;
  wire             [63:0] instr1_addr_wr;
  wire                    instr_commit_wr;
  wire                    slot1_commit_wr;
  wire                    slot1_instr_sample_wr;
  wire             [47:0] iq_instr0_de;
  wire             [32:0] iq_instr0_dp;
  wire             [32:0] iq_instr0_common;
  wire              [1:0] iq_instr0_dp_pdtype;
  wire                    iq_instr0_is_dp;
  wire                    iq_instr0_is_fn;
  wire                    iq_instr0_is_ls;
  wire                    iq_instr0_is_other;
  wire             [32:0] iq_instr0_fn;
  wire              [1:0] iq_instr0_fn_pdtype;
  wire              [1:0] iq_instr0_pdtype;
  wire             [32:0] iq_instr0_ls;
  wire              [1:0] iq_instr0_ls_pdtype;
  wire                    iq_instr0_ls_br_taken;
  wire                    iq_instr0_common_br_taken;
  wire             [32:0] iq_instr0_other;
  wire              [1:0] iq_instr0_other_pdtype;
  wire                    iq_instr0_other_br_taken;
  wire                    iq_instr0_d0_de;
  wire              [5:0] iq_instr0_sideband_de;
  wire             [47:0] iq_instr1_de;
  wire              [1:0] isa_instr0_wr;
  wire              [1:0] isa_instr1_wr;
  wire                    thumb_instr1_wr;
  wire              [1:0] ls_size_wr;
  wire                    ls_store_wr;
  wire             [63:0] mcr_data_wr;
  wire             [63:0] mem_addr;
  wire  [`CA53_CPSR_RET_W-1:0] nxt_cpsr_ret;
  wire             [31:0] nxt_fpexc_f5;
  wire             [31:0] nxt_fpscr_f5;
  wire             [31:0] opcode0_de;
  wire             [31:0] opcode1_de;
  wire             [48:1] raw_pc_instr0_ex2;
  wire             [63:0] pc_instr0_ex2;
  wire             [63:0] pc_instr0_wr;
  wire              [3:0] psr_regfile_w0_mask_wr;
  wire                    psr_regfile_w1_en_wr;
  wire              [8:0] raw_cp_decode_wr;
  wire                    reset_n;
  wire              [5:0] rf_wr_addr_fw0_lo_f5;
  wire              [5:0] rf_wr_addr_fw0_hi_f5;
  wire              [5:0] rf_wr_addr_w0_wr;
  wire              [5:0] rf_wr_addr_w1_wr;
  wire              [5:0] rf_wr_addr_w2_wr;
  wire             [63:0] rf_wr_data_w0_wr;
  wire             [63:0] rf_wr_data_w1_wr;
  wire             [63:0] rf_wr_data_w2_wr;
  wire                    rf_wr_en_fw0_lo_f5;
  wire                    rf_wr_en_fw0_hi_f5;
  wire                    rf_wr_en_w0_wr;
  wire                    rf_wr_en_w1_wr;
  wire                    rf_wr_en_w2_wr;
  wire                    en_restore;
  wire                    rf_wr_64b_w0_wr;
  wire                    rf_wr_64b_w1_wr;
  wire                    rf_wr_64b_w2_wr;
  wire                    rf_wr_en_hi_wr;
  wire                    second_x64_iss;
  wire                    size_instr0_wr;
  wire                    size_instr1_ex2;
  wire                    ns_scr;
  wire                    cpsr_regfile_en_wr;
  wire                    stall_ex1_no_sfmac;
  wire                    stall_ex2_no_sfmac;
  wire                    stall_ex1_sfmac;
  wire                    stall_ex2_sfmac;   
  wire                    stall_iss;
  wire                    stall_wr;
  wire                    hvc_expt_wr;
  wire              [1:0] head_instr_wr;
  wire                    expt_quash_wr;
  wire                    expt_data_abort_wr;
  wire                    expt_instr_fault_wr;
  wire                    expt_debug_halt_wr;
  wire                    take_il_trap_iss;
  reg                     take_il_trap_ex1;
  reg                     take_il_trap_ex2;
  reg                     take_il_trap_wr;
  wire                    quash_no_dabort_wr;
  wire                    quash_slot0_wr;
  wire                    multi_valid_end_wr;
  wire                    multi_valid_head_wr;
  wire                    end_instr_no_quash_wr;
  wire                    expt_halt_continue;
  wire              [1:0] valid_instrs_wr;
  wire                    slot1_ls_wr;
  wire                    w0_slot1_ex2;
  reg                     w0_slot1_wr;
  wire                    instr_ended_f5_sample;
  wire                    async_expt_wr;
  reg                     async_expt_ret;

  wire expt_reset_wr;     
  wire expt_fiq_wr;       
  wire expt_vfiq_wr;     
  wire expt_irq_wr;       
  wire expt_virq_wr;      
  wire expt_imprecise_wr;
  wire expt_vimprecise_wr;
  wire expt_ext_halt_wr;
  wire expt_osuc_halt_wr;
  wire expt_ecc_reexec_wr;
  wire expt_pc_align_wr;
 
  reg expt_reset_ret;     
  reg expt_fiq_ret;       
  reg expt_vfiq_ret;     
  reg expt_irq_ret;       
  reg expt_virq_ret;      
  reg expt_imprecise_ret;
  reg expt_vimprecise_ret;
  reg expt_ext_halt_ret;
  reg expt_osuc_halt_ret;
  reg expt_ecc_reexec_ret;

   
  wire              [4:0] exception_mode_ret;
  wire                    nxt_cpsr_tbit_ret_pre;
  wire                    instr_sample_wr;
  wire                    mem_sample;
  wire                    int_reg_wr_sample;
  wire                    expt_sys_reg_sample;
  wire                    fpu_reg_wr_sample;
  wire                    sys_reg_wr_sample;
  wire                    insert_forceop_ret;
  wire              [4:0] cpsr_mode_ret;
  wire             [63:0] forceop_pc_ret;
  wire                    forceop_valid_wr;
  wire                    expt_slot1_wr;
   reg                    expt_slot1_ret;  

  wire             [3:0]                     rf_wr_en_fw0_f5;  
  wire             [3:0]                     rf_wr_en_fw1_f5;  
  wire             [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw0_f5;
  wire             [`CA53_FP_RF_WR_ADDR_W-1:0] rf_wr_addr_fw1_f5;

  wire             [63:0]                    rf_wr_data_fw1_f5;
  wire             [63:0]                    rf_wr_data_fw0_f5;

  wire             [20:0] rf_wr_ctl_fw0_neon_de;
  wire             [20:0] rf_wr_ctl_fw1_neon_de;
  reg              [20:0] rf_wr_ctl_fw0_neon_iss;
  reg              [20:0] rf_wr_ctl_fw1_neon_iss;
  reg              [20:0] rf_wr_ctl_fw0_neon_ex1;
  reg              [20:0] rf_wr_ctl_fw1_neon_ex1;
  reg              [20:0] rf_wr_ctl_fw0_neon_ex2;
  reg              [20:0] rf_wr_ctl_fw1_neon_ex2;
  reg              [20:0] rf_wr_ctl_fw0_neon_wr;
  reg              [20:0] rf_wr_ctl_fw1_neon_wr;
  reg              [20:0] rf_wr_ctl_fw0_neon_f4;
  reg              [20:0] rf_wr_ctl_fw1_neon_f4;
  reg              [20:0] rf_wr_ctl_fw0_neon_f5;
  reg              [20:0] rf_wr_ctl_fw1_neon_f5;

  wire                    slot1_fp_wr;
  wire              [1:0] fdivs_valid_f3;
  wire                    unflushable_sfdiv_iss;
  reg                     unflushable_sfdiv_ex1;
  reg                     unflushable_sfdiv_ex2;
  reg                     unflushable_sfdiv_wr;
  reg                     unflushable_sfdiv_f4;
  reg                     unflushable_sfdiv_f5;  
  wire              [1:0] unflushable_sfmac_iss;
  wire                    sample_unflushable_sfmac_iss;
  reg               [1:0] unflushable_sfmac_ex1;
  reg               [1:0] unflushable_sfmac_ex2;
  reg               [1:0] unflushable_sfmac_wr;
  reg               [1:0] unflushable_sfmac_f4;
  reg               [1:0] unflushable_sfmac_f5;
  
  reg              [63:0] sfmac_instr_count_ex1;
  reg              [63:0] sfmac_instr_count_ex2;
  reg              [63:0] sfmac_instr_count_wr;
  reg              [63:0] sfmac_instr_count_f4;
  reg              [63:0] sfmac_instr_count_f5;

  reg                     multi_cycle_in_progress;


  wire                    ttbcr_eae_s;
  wire                    ttbcr_eae_ns;

  wire                    cp_inst_dc3;
  wire                    pld_dc3;
  wire             [15:0] strobe_dc3;
  wire              [7:0] load_strobe_dc3;

  wire                    div_in_ex2;
  wire                    dual_iss_w1_hazard_ex2;
  wire                    flushed_div_ex2;
  reg                     flushed_div_wr;
  
  wire                    dpu_valid_branch_instr_wr;
  wire                    slot1_branch_wr;
  wire                    slot0_branch_wr;
  wire     [`CA53_LS_INSTR_TYPE_W-1:0] ls_instr_type_wr; 
  wire                    in_halt;
  wire                    enter_halt_wr;
  reg                     enter_halt_ret;
  
  wire                    aes_op_merged_iss;
  reg                     aes_op_merged_ex1;
  reg                     aes_op_merged_ex2;
  reg                     aes_op_merged_wr;
  
  assign clk                          = `DPU_PATH.clk;
  assign reset_n                      = `DPU_PATH.reset_n;

  assign cpu_id                       = `DPU_PATH.cpu_id_i;
  assign gov_clusteridaff2            = `DPU_PATH.gov_clusteridaff2_i;
  assign gov_clusteridaff1            = `DPU_PATH.gov_clusteridaff1_i;
  
  assign end_instr_wr                 = `DPU_PATH.end_instr_wr;
  assign valid_instrs_wr              = `DPU_PATH.valid_instrs_wr;
  assign raw_pc_instr0_ex2            = `DPU_PATH.u_dpu_ctl.pc_instr0_ex2;
  assign pc_instr0_wr                 = `DPU_PATH.u_dpu_ctl.pc_instr0_wr;
  assign cc_pass_instr0_wr            = `DPU_PATH.cc_pass_instr0_wr;
  assign cc_pass_instr1_wr            = `DPU_PATH.cc_pass_instr1_wr;
  assign isa_instr0_wr                = `DPU_PATH.isa_instr0_wr;
  assign aarch64_state                = `DPU_PATH.aarch64_state;
  assign size_instr0_wr               = `DPU_PATH.size_instr0_wr;
  assign size_instr1_ex2              = `DPU_PATH.size_instr1_ex2;
  assign iq_instr0_dp                 = `DPU_PATH.u_dpu_de.iq_instr0_dp;
  assign iq_instr0_common             = `DPU_PATH.u_dpu_de.iq_instr0_common;
  assign iq_instr0_dp_pdtype          = `DPU_PATH.u_dpu_de.iq_instr0_dp_pdtype;
  assign iq_instr0_ls                 = `DPU_PATH.u_dpu_de.iq_instr0_ls;
  assign iq_instr0_ls_pdtype          = `DPU_PATH.u_dpu_de.iq_instr0_ls_pdtype;
  assign iq_instr0_ls_br_taken        = `DPU_PATH.u_dpu_de.iq_instr0_ls_br_taken;
  assign iq_instr0_common_br_taken    = `DPU_PATH.u_dpu_de.iq_instr0_common_br_taken;
  assign iq_instr0_other              = `DPU_PATH.u_dpu_de.iq_instr0_other;
  assign iq_instr0_other_pdtype       = `DPU_PATH.u_dpu_de.iq_instr0_other_pdtype;
  assign iq_instr0_other_br_taken     = `DPU_PATH.u_dpu_de.iq_instr0_other_br_taken;
  assign iq_instr0_fn                 = `DPU_PATH.u_dpu_de.iq_instr0_fn;
  assign iq_instr0_fn_pdtype          = `DPU_PATH.u_dpu_de.iq_instr0_fn_pdtype;
  assign iq_instr0_pdtype             = `DPU_PATH.u_dpu_de.iq_instr0_pdtype;
  assign iq_instr0_is_dp              = `DPU_PATH.u_dpu_de.iq_instr0_is_dp;
  assign iq_instr0_is_ls              = `DPU_PATH.u_dpu_de.iq_instr0_is_ls;
  assign iq_instr0_is_other           = `DPU_PATH.u_dpu_de.iq_instr0_is_other;
  assign iq_instr0_is_fn              = `DPU_PATH.u_dpu_de.iq_instr0_is_fn;
  assign iq_instr0_d0_de              = `DPU_PATH.u_dpu_de.u_iq.iq_instr0_d0_de;
  assign iq_instr0_sideband_de        = `DPU_PATH.u_dpu_de.iq_instr0_sideband;
  assign iq_instr1_de                 = `DPU_PATH.u_dpu_de.u_iq.iq_instr1_common_de;
  assign aes_op_merged_iss            = `DPU_PATH.u_dpu_de.aes_op_merged_iss;
  assign stall_iss                    = `DPU_PATH.u_dpu_ctl.stall_iss;
  assign stall_ex1_no_sfmac           = `DPU_PATH.u_dpu_ctl.stall_ex1_no_sfmac;
  assign stall_ex2_no_sfmac           = `DPU_PATH.u_dpu_ctl.stall_ex2_no_sfmac;
  assign stall_ex1_sfmac              = `DPU_PATH.u_dpu_ctl.stall_ex1_sfmac;
  assign stall_ex2_sfmac              = `DPU_PATH.u_dpu_ctl.stall_ex2_sfmac;
  assign slot1_fp_wr                  = `DPU_PATH.u_dpu_ctl.slot1_fp_wr;
  assign stall_wr                     = `DPU_PATH.u_dpu_ctl.stall_wr;
  assign flush_ret                    = `DPU_PATH.u_dpu_ctl.flush_ret;
  assign thumb_instr1_wr              = `DPU_PATH.u_dpu_ctl.thumb_instr1_wr;
  assign slot0_br_flush_wr            = `DPU_PATH.slot0_br_flush_wr;
  assign expt_halt_continue           = `DPU_PATH.u_dpu_dbg.in_halt;
  assign head_instr_wr                = `DPU_PATH.u_dpu_ctl.head_instr_wr;
  assign expt_data_abort_wr           = (`DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_DATA) |
                                        (`DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_WPT);
  assign expt_instr_fault_wr          = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_INSTR_FAULT;
  assign expt_pc_align_wr             = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_PC_ALIGNMENT;  
  assign expt_ecc_reexec_wr           = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_ECC_REEXEC;  
  assign take_il_trap_iss             = `DPU_PATH.u_dpu_ctl.u_dpu_early_exception.take_il_trap_iss;
  assign enter_halt_wr                = `DPU_PATH.u_dpu_ctl.u_dpu_exception.enter_halt_wr;
  assign expt_quash_wr                = `DPU_PATH.u_dpu_ctl.expt_quash_wr;
  assign quash_slot0_wr               = `DPU_PATH.u_dpu_ctl.quash_slot0_wr;
generate if (NEON_FP) begin
  assign fdivs_valid_f3               = `DPU_PATH.u_dpu_ctl.FPU1.fdivs_valid_f3[1:0]; 
  assign unflushable_sfdiv_iss        = `DPU_PATH.u_dpu_ctl.FPU1.unflushable_sfdiv_iss;
  assign unflushable_sfmac_iss        = `DPU_PATH.u_dpu_ctl.FPU1.unflushable_sfmac_iss[1:0];
end else begin
  assign fdivs_valid_f3               = 2'b00; 
  assign unflushable_sfdiv_iss        = 1'b0;
  assign unflushable_sfmac_iss        = 2'b00;
end endgenerate
  assign sample_unflushable_sfmac_iss = unflushable_sfmac_iss != 2'b0;
  assign div_in_ex2                   = `DPU_PATH.u_dpu_ctl.div_in_ex2;
  assign dual_iss_w1_hazard_ex2       = `DPU_PATH.u_dpu_ctl.dual_iss_w1_hazard_ex2;
  assign cpsr_ret                     = `DPU_PATH.cpsr_ret;
  assign ns_scr                       = `DPU_PATH.ns_scr;
  assign rf_wr_en_w0_wr               = `DPU_PATH.rf_wr_en_w0_wr;
  assign rf_wr_en_w1_wr               = `DPU_PATH.rf_wr_en_w1_wr;
  assign rf_wr_en_w2_wr               = `DPU_PATH.rf_wr_en_w2_wr;
  assign en_restore                   = `DPU_PATH.u_dpu_ctl.en_restore;
  assign rf_wr_64b_w0_wr              = `DPU_PATH.rf_wr_64b_w0_wr;
  assign rf_wr_64b_w1_wr              = `DPU_PATH.rf_wr_64b_w1_wr;
  assign rf_wr_64b_w2_wr              = `DPU_PATH.rf_wr_64b_w2_wr;
  assign rf_wr_en_hi_wr               = `DPU_PATH.rf_wr_en_hi_wr;
  assign rf_wr_addr_w0_wr             = `DPU_PATH.rf_wr_addr_w0_wr;
  assign rf_wr_addr_w1_wr             = `DPU_PATH.rf_wr_addr_w1_wr;
  assign rf_wr_addr_w2_wr             = `DPU_PATH.rf_wr_addr_w2_wr;
  assign rf_wr_data_w0_wr             = `DPU_PATH.rf_wr_data_w0_wr;
  assign rf_wr_data_w1_wr             = `DPU_PATH.rf_wr_data_w1_wr;
  assign rf_wr_data_w2_wr             = `DPU_PATH.rf_wr_data_w2_wr;
  assign nxt_cpsr_ret                 = `DPU_PATH.u_dpu_cpsr.u_psr_rf.nxt_cpsr_ret_i;
  assign cpsr_regfile_en_wr           = `DPU_PATH.u_dpu_cpsr.u_psr_rf.cpsr_regfile_en_wr_i;
  assign dpu_cp_op_iss                = `DPU_PATH.dpu_cp_op_iss_o;
  assign cp_valid_wr                  = `DPU_PATH.u_dpu_cp.cp_valid_wr;
  assign raw_cp_decode_wr             = `DPU_PATH.u_dpu_cp.raw_cp_decode_wr;
  assign mcr_data_wr                  = `DPU_PATH.u_dpu_cp.mcr_data_wr;
  assign cp_hcr                       = `DPU_PATH.u_dpu_cp.cp_hcr;
  assign first_x64_wr                 = `DPU_PATH.first_x64_wr;
  assign second_x64_iss               = `DPU_PATH.second_x64_iss;
  assign dpu_length_iss               = `DPU_PATH.dpu_length_iss_o;
  assign dpu_ready_wr                 = `DPU_PATH.dpu_ready_wr_o;
  assign dpu_kill_wr                  = `DPU_PATH.dpu_kill_wr_o;
  assign dcu_valid_dc3                = `DPU_PATH.dcu_valid_dc3_i;
  assign dcu_va_dc3                   = `DPU_PATH.dcu_va_dc3_i;
  assign ls_store_wr                  = `DPU_PATH.ls_store_wr;
  assign ls_size_wr                   = `DPU_PATH.ls_size_wr;
  assign dcu_ld_data_dc3              = `DPU_PATH.dcu_ld_data_dc3_i;
  assign dpu_st_data_wr               = `DPU_PATH.dpu_st_data_wr_o;
  assign dcu_p_abort_dc3              = `DPU_PATH.dcu_p_abort_dc3_i;
  assign dcu_wpt_hit_dc3              = `DPU_PATH.dcu_wpt_hit_dc3_i; 
  assign ls_instr_type_wr             = `DPU_PATH.ls_instr_type_wr;
  assign expt_state                   = `DPU_PATH.u_dpu_ctl.u_dpu_exception.current_state;
  assign hvc_expt_wr                  = (`DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_type_wr == `CA53_EXPT_TYPE_CALL) &
                                        ((`DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_ec_wr == 6'h12) |
                                         (`DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_ec_wr == 6'h16));
  assign end_instr_no_quash_wr        = `DPU_PATH.u_dpu_ctl.end_instr_no_quash_wr;

  assign insert_forceop_ret                 = `DPU_PATH.u_dpu_ctl.u_dpu_exception.insert_forceop_ret_o;  
  assign forceop_pc_ret                     = `DPU_PATH.u_dpu_ctl.u_dpu_exception.forceop_pc_ret_o;
  assign forceop_valid_wr                   = `DPU_PATH.u_dpu_ctl.u_dpu_exception.forceop_valid_wr_o;  

  assign dpu_valid_branch_instr_wr    = `DPU_PATH.dpu_valid_branch_instr_wr;
  assign slot1_branch_wr              = `DPU_PATH.slot1_branch_wr;
  
  assign expt_slot1_wr                = `DPU_PATH.u_dpu_ctl.expt_slot1_wr_o;
  
  assign slot1_ls_wr                  = `DPU_PATH.u_dpu_ctl.slot1_ls_wr;
  assign w0_slot1_ex2                 = `DPU_PATH.u_dpu_ctl.w0_slot1_ex2;

  assign ttbcr_eae_s                  = `TLB_PATH.u_tlb_cp_regs.ttbcr_eae_s_o;
  assign ttbcr_eae_ns                 = `TLB_PATH.u_tlb_cp_regs.ttbcr_eae_ns_o; 

  assign cp_inst_dc3                  = `DCU_PATH.u_lspipe.cp_inst_dc3;
  assign pld_dc3                      = `DCU_PATH.u_lspipe.pld_dc3;
  assign load_strobe_dc3              = `DCU_PATH.u_lspipe.load_strobe_dc3;
  assign strobe_dc3                   = `DCU_PATH.u_lspipe.strobe_dc3;
  assign dcu_pa_dc3                   = `DCU_PATH.u_lspipe.dcu_pa_dc3;
  assign ns_dsc_dc3                   = `DCU_PATH.u_lspipe.ns_dsc_dc3;
  assign dcu_strex_okay_dc3           = `DCU_PATH.u_lspipe.dcu_strex_okay_dc3_o;
  assign attrs_dc3                    = `DCU_PATH.u_lspipe.attrs_dc3;
  assign ldar_stlr_dc3                = `DCU_PATH.u_lspipe.ldar_stlr_dc3;

  assign expt_reset_wr           = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_reset ;     
  assign expt_fiq_wr             = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_fiq ;       
  assign expt_vfiq_wr            = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_vfiq ;      
  assign expt_irq_wr             = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_irq ;       
  assign expt_virq_wr            = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_virq ;      
  assign expt_imprecise_wr       = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_imprecise ; 
  assign expt_vimprecise_wr      = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_vimprecise ;
  assign expt_ext_halt_wr        = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_ext_halt ; 
  assign expt_osuc_halt_wr       = `DPU_PATH.u_dpu_ctl.u_dpu_exception.expt_osuc_halt ;
 
  assign in_halt                 = `DPU_PATH.in_halt;
 
  assign async_expt_wr                = expt_reset_wr |
                                        expt_fiq_wr |
                                        expt_vfiq_wr |
                                        expt_irq_wr |
                                        expt_virq_wr |
                                        expt_imprecise_wr |
                                        expt_vimprecise_wr |
                                        expt_ext_halt_wr;

  assign exception_mode_ret    = `DPU_PATH.u_dpu_ctl.u_dpu_exception.exception_mode_ret;
  assign nxt_cpsr_tbit_ret_pre = `DPU_PATH.u_dpu_cpsr.nxt_cpsr_tbit_ret_pre;
 

   
  // The instruction in Wr will commit
  assign instr_commit_wr = head_instr_wr[0] & (~stall_wr | expt_quash_wr);

  assign multi_valid_end_wr = end_instr_no_quash_wr & ~stall_wr;

  assign multi_valid_head_wr = cc_pass_instr0_wr & head_instr_wr[0] & ~end_instr_no_quash_wr & ~stall_wr;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      multi_cycle_in_progress <= 1'b0;
    else if (expt_halt_continue)
      multi_cycle_in_progress <= 1'b0;
    else if (multi_valid_end_wr | expt_quash_wr)
      multi_cycle_in_progress <= 1'b0;
    else if (multi_valid_head_wr)
      multi_cycle_in_progress <= 1'b1;

  assign quash_no_dabort_wr = expt_quash_wr & ~expt_data_abort_wr & ~hvc_expt_wr;








  
  
generate if (NEON_FP) begin
  assign rf_wr_en_fw0_f5              = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_en_fw0_f5_i;  
  assign rf_wr_en_fw1_f5              = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_en_fw1_f5_i;  
  assign rf_wr_addr_fw0_f5            = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_addr_fw0_f5_i;
  assign rf_wr_addr_fw1_f5            = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_addr_fw1_f5_i;
  assign rf_wr_data_fw0_f5            = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_data_fw0_f5;
  assign rf_wr_data_fw1_f5            = `DPU_PATH.FPU1.u_dpu_fp.rf_wr_data_fw1_f5;
  assign rf_wr_ctl_fw0_neon_de        = `DPU_PATH.u_dpu_de.NEON1.u_dec0_neon.rf_wr_ctl_fw0_neon[20:0];
  assign rf_wr_ctl_fw1_neon_de        = `DPU_PATH.u_dpu_de.NEON1.u_dec0_neon.rf_wr_ctl_fw1_neon[20:0];
end else begin
  assign rf_wr_en_fw0_f5              = 4'b0;  
  assign rf_wr_en_fw1_f5              = 4'b0;  
  assign rf_wr_addr_fw0_f5            = `CA53_FP_RF_WR_ADDR_W'b0;
  assign rf_wr_addr_fw1_f5            = `CA53_FP_RF_WR_ADDR_W'b0;
  assign rf_wr_data_fw0_f5            = 63'b0;
  assign rf_wr_data_fw1_f5            = 63'b0;
  assign rf_wr_ctl_fw0_neon_de        = 21'b0;
  assign rf_wr_ctl_fw1_neon_de        = 21'b0;
end endgenerate


  assign iq_instr0_de = {iq_instr0_sideband_de[5:0], 
                         iq_instr0_is_fn, iq_instr0_is_other, iq_instr0_is_ls, iq_instr0_is_dp, 
                         iq_instr0_common_br_taken, 
                         iq_instr0_pdtype[1:0],
                         1'b0,
                         iq_instr0_d0_de,
                         iq_instr0_common[32:0]};

  assign pc_instr0_ex2 = { {16{raw_pc_instr0_ex2[48]}}, raw_pc_instr0_ex2[47:1], 1'b0};
  assign slot0_branch_wr = dpu_valid_branch_instr_wr & ~slot1_branch_wr;
  assign isa_instr1_wr = {isa_instr0_wr[1], thumb_instr1_wr};

  assign instr0_addr_wr = instr_addr(pc_instr0_wr, isa_instr0_wr);

  assign instr1_addr_wr = instr_addr(slot0_branch_wr ? (pc_instr0_ex2 - (size_instr1_wr ? 4 : 2))
                                                     : (pc_instr0_wr  + (size_instr0_wr ? 4 : 2)), isa_instr1_wr);


  assign opcode0_de     = pfb_to_raw_encoding(iq_instr0_de, aarch64_state, dbg_halted);
  assign opcode1_de     = pfb_to_raw_encoding(iq_instr1_de, aarch64_state, dbg_halted);

  assign sideband_undef0_de = iq_instr0_de[47:42] == `SIDEBAND_UNDEF && iq_instr0_de[37] == 1'b0;
  assign sideband_undef1_de = iq_instr1_de[47:42] == `SIDEBAND_UNDEF && iq_instr1_de[37] == 1'b0;

  //See DPU_IQ_Format tab of Instruction transform spreadsheet
  assign sideband_hw_bkpt_vc0_de =  (iq_instr0_de[47:26] & 22'b111111_1111_1_0_1_1_1_1111_111)  == 22'b000000_0100_1_0_0_0_0_1110_110;

`ifndef TEST_PLUSARGS
  `define TEST_PLUSARGS(name, loc) loc = $test$plusargs(name)
`endif

  initial begin
    $display("univent follower module: %m");
    cycle_count <= 64'd0;
    prev_instr_count_wr = 64'd0;
    instr_in_progress = 1'b0;
  end


  
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      instr_in_progress <= 1'b0;
    else if (end_instr_wr & ~stall_wr | flush_ret)
      instr_in_progress <= 1'b0;
    else if (instr_commit_wr)
      instr_in_progress <= 1'b1;
  
  always @(posedge clk)
    if (dcu_valid_dc3 & dpu_ready_wr & first_x64_wr)
      x64_addr <= dcu_va_dc3;
  
  assign mem_addr = second_x64_wr ? x64_addr : dcu_va_dc3;
  assign instr_sample_wr = instr_commit_wr && !async_expt_wr;
   

  
  //Trigger event to capture info on slot 1 instructions that are issued alongside a multicycle instructio
  //in slot0.
  assign slot1_commit_wr  =  head_instr_wr[1] & ~head_instr_wr[0] & ~stall_wr & ~quash_slot0_wr;
   
  assign slot1_instr_sample_wr =  slot1_commit_wr && !async_expt_wr;


   
  assign mem_sample = dcu_valid_dc3 & dpu_ready_wr & ((valid_instrs_wr[1] & slot1_ls_wr) ? cc_pass_instr1_wr : cc_pass_instr0_wr) & ~dpu_kill_wr  & ~(cp_valid_wr & (ls_instr_type_wr != `CA53_LS_INSTR_DCZVA))  & (~cp_inst_dc3 | (ldar_stlr_dc3 & (dcu_p_abort_dc3|dcu_wpt_hit_dc3))) & ~pld_dc3;
  assign int_reg_wr_sample = rf_wr_en_w0_wr | rf_wr_en_w1_wr | rf_wr_en_w2_wr;
  
  
  //If we see end_instr_f5, or a flush, then that instruction (and all previous ones) are done with (apart from
  //the special cases related to long latency fp reg updates). If we see sample_instr_f5, then all previous
  //instructions are done with (same caveat).
  wire [63:0] instr_done_count_f5;  
  assign instr_ended_f5_sample = end_instr_f5 && (~stall_wr | flush_ret) | instr_sample_f5;    
  assign instr_done_count_f5 = end_instr_f5 && (~stall_wr | flush_ret) ? instr_count_f5 : instr_count_f5 - 1;
   
  

  assign fpu_reg_wr_sample = (rf_wr_en_fw0_f5 != 4'h0) || (rf_wr_en_fw1_f5 != 4'h0) || en_fpexc_reg_f5;


   

  assign sys_reg_wr_sample = ((cp_valid_wr & raw_cp_decode_wr[8]) || (dcu_valid_dc3 & dpu_ready_wr & cp_valid_wr & ls_store_wr & (ls_instr_type_wr != `CA53_LS_INSTR_DCZVA))) & ~stall_wr;

  assign flushed_div_ex2   = dual_iss_w1_hazard_ex2 & div_in_ex2;
   
  assign instr_count_wr = instr_sample_wr ? prev_instr_count_wr + 1 : prev_instr_count_wr;
 
         
  always @(posedge clk) begin
     
    prev_instr_count_wr <= instr_count_wr; 
    
    if (~stall_iss) begin
      opcode0_iss <= opcode0_de;
      opcode1_iss <= opcode1_de;
      sideband_undef0_iss <= sideband_undef0_de;
      sideband_undef1_iss <= sideband_undef1_de;
      sideband_hw_bkpt_vc0_iss <= sideband_hw_bkpt_vc0_de; 
      rf_wr_ctl_fw0_neon_iss <= rf_wr_ctl_fw0_neon_de;
      rf_wr_ctl_fw1_neon_iss <= rf_wr_ctl_fw1_neon_de;
    end
    if (~stall_ex1_no_sfmac) begin
      opcode0_ex1 <= opcode0_iss;
      opcode1_ex1 <= opcode1_iss;
      sideband_undef0_ex1 <= sideband_undef0_iss;
      sideband_undef1_ex1 <= sideband_undef1_iss;
      sideband_hw_bkpt_vc0_ex1 <= sideband_hw_bkpt_vc0_iss; 
      dpu_cp_op_ex1 <= dpu_cp_op_iss;
      second_x64_ex1 <= second_x64_iss;
      rf_wr_ctl_fw0_neon_ex1 <= rf_wr_ctl_fw0_neon_iss;
      rf_wr_ctl_fw1_neon_ex1 <= rf_wr_ctl_fw1_neon_iss;
      dpu_length_ex1 <= dpu_length_iss;
      unflushable_sfdiv_ex1 <= unflushable_sfdiv_iss;
      take_il_trap_ex1 <= take_il_trap_iss;
      aes_op_merged_ex1 <= aes_op_merged_iss;
    end // if (~stall_ex1_no_sfmac)
    if (~stall_ex1_sfmac) begin
       unflushable_sfmac_ex1 <= unflushable_sfmac_iss;
       sfmac_instr_count_ex1 <= instr_count_f4;
    end
    if (~stall_ex2_no_sfmac) begin
      opcode0_ex2 <= opcode0_ex1;
      opcode1_ex2 <= opcode1_ex1;
      sideband_undef0_ex2 <= sideband_undef0_ex1;
      sideband_undef1_ex2 <= sideband_undef1_ex1;
      sideband_hw_bkpt_vc0_ex2 <= sideband_hw_bkpt_vc0_ex1; 
      dpu_cp_op_ex2 <= dpu_cp_op_ex1;
      second_x64_ex2 <= second_x64_ex1;
      rf_wr_ctl_fw0_neon_ex2 <= rf_wr_ctl_fw0_neon_ex1;
      rf_wr_ctl_fw1_neon_ex2 <= rf_wr_ctl_fw1_neon_ex1;
      dpu_length_ex2 <= dpu_length_ex1;
      unflushable_sfdiv_ex2 <= unflushable_sfdiv_ex1;
      take_il_trap_ex2 <= take_il_trap_ex1;
      aes_op_merged_ex2 <= aes_op_merged_ex1;
    end // if (~stall_ex2_no_sfmac)
    if (~stall_ex2_sfmac) begin
      unflushable_sfmac_ex2 <= unflushable_sfmac_ex1;
      sfmac_instr_count_ex2 <= sfmac_instr_count_ex1;
    end
    if (~stall_wr | flush_ret) begin
      opcode0_wr  <= opcode0_ex2;
      opcode1_wr  <= opcode1_ex2;
      sideband_undef0_wr <= sideband_undef0_ex2;
      sideband_undef1_wr <= sideband_undef1_ex2;
      sideband_hw_bkpt_vc0_wr <= sideband_hw_bkpt_vc0_ex2; 
      size_instr1_wr <= size_instr1_ex2;
      dpu_cp_op_wr <= dpu_cp_op_ex2;
      second_x64_wr <= second_x64_ex2;
      instr_count_f4 <= instr_count_wr;
      instr_count_f5 <= instr_count_f4;
      instr_count_f5_reg <= instr_count_f5;
      instr_sample_f4 <= instr_sample_wr;
      instr_sample_f5 <= instr_sample_f4;
      end_instr_f4   <= end_instr_wr;
      end_instr_f5   <= end_instr_f4;
      dpu_length_wr <= dpu_length_ex2;
      rf_wr_ctl_fw0_neon_wr <= rf_wr_ctl_fw0_neon_ex2;
      rf_wr_ctl_fw1_neon_wr <= rf_wr_ctl_fw1_neon_ex2;
      rf_wr_ctl_fw0_neon_f4 <= rf_wr_ctl_fw0_neon_wr;
      rf_wr_ctl_fw1_neon_f4 <= rf_wr_ctl_fw1_neon_wr;
      rf_wr_ctl_fw0_neon_f4 <= rf_wr_ctl_fw0_neon_wr;
      rf_wr_ctl_fw1_neon_f4 <= rf_wr_ctl_fw1_neon_wr;
      rf_wr_ctl_fw0_neon_f5 <= rf_wr_ctl_fw0_neon_f4;
      rf_wr_ctl_fw1_neon_f5 <= rf_wr_ctl_fw1_neon_f4;
      unflushable_sfdiv_wr <= unflushable_sfdiv_ex2;
      unflushable_sfdiv_f4 <= unflushable_sfdiv_wr;
      unflushable_sfdiv_f5 <= unflushable_sfdiv_f4;
      unflushable_sfmac_wr <= unflushable_sfmac_ex2;
      unflushable_sfmac_f4 <= unflushable_sfmac_wr;
      unflushable_sfmac_f5 <= unflushable_sfmac_f4;
      sfmac_instr_count_wr <= sfmac_instr_count_ex2;
      sfmac_instr_count_f4 <= sfmac_instr_count_wr;
      sfmac_instr_count_f5 <= sfmac_instr_count_f4;
      flushed_div_wr       <= flushed_div_ex2;
      w0_slot1_wr          <= w0_slot1_ex2;
      take_il_trap_wr <= take_il_trap_ex2;
      aes_op_merged_wr <= aes_op_merged_ex2;
    end
    
    opcode0_wr_reg  <= opcode0_wr;
    opcode1_wr_reg  <= opcode1_wr;
  end


//Reconstruct versions of register file write enables which don't take account of dual issue hazarding, so we can trace
//register updates for slot0 instructions even if these have a WAW hazard with the instruction in slot1.
   wire nxt_rf_wr_en_w0_unsupressed_wr;
   wire nxt_rf_wr_en_w1_unsupressed_wr;
   reg  raw_rf_wr_en_w0_unsupressed_wr;
   reg  raw_rf_wr_en_w1_unsupressed_wr;
   wire rf_wr_en_w0_unsupressed_wr;
   wire rf_wr_en_w1_unsupressed_wr;


   assign nxt_rf_wr_en_w0_unsupressed_wr = `DPU_PATH.u_dpu_ctl.raw_rf_wr_en_w0_ex2 & ((`DPU_PATH.u_dpu_ctl.valid_instrs_ex2[1] & w0_slot1_ex2) ? `DPU_PATH.u_dpu_ctl.cc_pass_instr1_ex2_i : (`DPU_PATH.u_dpu_ctl.valid_instrs_ex2[0] & `DPU_PATH.u_dpu_ctl.cc_pass_instr0_ex2_i));
   assign nxt_rf_wr_en_w1_unsupressed_wr =     `DPU_PATH.u_dpu_ctl.rf_wr_en_w1_ex2;
   
   always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      raw_rf_wr_en_w0_unsupressed_wr            <= 1'b0;
      raw_rf_wr_en_w1_unsupressed_wr            <= 1'b0;
    end
    else if (~stall_wr | flush_ret) begin
      raw_rf_wr_en_w0_unsupressed_wr            <= nxt_rf_wr_en_w0_unsupressed_wr;
      raw_rf_wr_en_w1_unsupressed_wr            <= nxt_rf_wr_en_w1_unsupressed_wr;
    end
   
   // W0 is either slot0 or slot1, so need to surpress if for slot 1
   assign rf_wr_en_w0_unsupressed_wr = (raw_rf_wr_en_w0_unsupressed_wr                   & ~`DPU_PATH.u_dpu_ctl.quash_wr       & ~`DPU_PATH.u_dpu_ctl.slot0_br_flush_wr_i & `DPU_PATH.u_dpu_ctl.pre_valid_instrs_wr[0] & ~`DPU_PATH.u_dpu_ctl.stall_wr) | `DPU_PATH.u_dpu_ctl.en_restore;
   // W1 always belongs to slot 0, so never have to surpress on branch
   assign rf_wr_en_w1_unsupressed_wr = (raw_rf_wr_en_w1_unsupressed_wr | `DPU_PATH.u_dpu_ctl.reenable_w1_wr) & ~`DPU_PATH.u_dpu_ctl.quash_slot0_wr &                        `DPU_PATH.u_dpu_ctl.pre_valid_instrs_wr[0] & ~`DPU_PATH.u_dpu_ctl.stall_wr;
////////////////////////////////////


//Reconstruct architectural PSR values
   wire   [31:0]   nxt_cpsr_ret_full;
   assign nxt_cpsr_ret_full =  {nxt_cpsr_ret[`CA53_CPSR_RET_NZCVQ_BITS],
                                nxt_cpsr_ret[`CA53_CPSR_RET_IT_LOW_BITS],
                                3'b0,
                                nxt_cpsr_ret[21:0]};




//Reconstruct write enables and register update values for register updates associated with exceptions.
//See comments in ca53dpu_cp.v for details of how the various registers map to each other.  
   wire            expt_en_esr_el2;
   assign          expt_en_esr_el2 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL2];
   wire            expt_en_hsr;
   assign          expt_en_hsr = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HSR];
   wire [31:0]     nxt_cp_esr_el2;
   assign          nxt_cp_esr_el2 =  `DPU_PATH.u_dpu_cp.nxt_cp_esr_el2;

   wire            expt_en_hpfar;
   assign          expt_en_hpfar = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HPFAR];
   wire [31:0]     nxt_cp_hpfar_rd; 
   assign          nxt_cp_hpfar_rd  = { `DPU_PATH.u_dpu_cp.nxt_cp_hpfar[31:4], {4{1'b0}} };

   wire   [31:0]         expt_dfsr_full;
   assign                expt_dfsr_full = `DPU_PATH.u_dpu_cp.expt_dfsr_full;
   wire   [31:0]         nxt_cp_esr_el1;
   assign                nxt_cp_esr_el1 = `DPU_PATH.u_dpu_cp.nxt_cp_esr_el1;
   wire   [31:0]         nxt_cp_esr_el3;
   assign                nxt_cp_esr_el3 = `DPU_PATH.u_dpu_cp.nxt_cp_esr_el3;   
   wire                  expt_en_dfsr_ns;
   assign                expt_en_dfsr_ns = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR] & `DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;
   wire                  expt_en_dfsr_s;  
   assign                expt_en_dfsr_s  = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFSR] & ~`DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;
   wire                  expt_en_esr_el1; 
   assign                expt_en_esr_el1 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL1];
   wire                  expt_en_esr_el3; 
   assign                expt_en_esr_el3 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_ESR_EL3];
   
   wire                  expt_en_ifsr_s;
   assign                expt_en_ifsr_s =  `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFSR] & ~ `DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;

 
   wire [31:0]           nxt_ifsr_s_rd;
   assign                nxt_ifsr_s_rd =  {{19{1'b0}},     // [31:13]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[8],     // [12]
                                           1'b0,           // [11]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[7:6],   // [10:9]
                                           3'b000,         // [8:6]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[5:0]};  // [5:0]
   wire                  expt_en_ifsr_ns;
   assign                expt_en_ifsr_ns =  `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFSR] & `DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;                   
   wire [31:0]           nxt_ifsr_ns_rd;
   assign                nxt_ifsr_ns_rd =  {{19{1'b0}},     // [31:13]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[8],     // [12]
                                           1'b0,           // [11]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[7:6],   // [10:9]
                                           3'b000,         // [8:6]
                                           `DPU_PATH.u_dpu_cp.nxt_cp_ifsr[5:0]};  // [5:0]

   wire [63:0]           nxt_cp_far_el1;
   assign                nxt_cp_far_el1 = {`DPU_PATH.u_dpu_cp.nxt_cp_far_el1_upper, `DPU_PATH.u_dpu_cp.nxt_cp_far_el1_lower};
   wire [31:0]           nxt_dfar_ns;
   assign                nxt_dfar_ns   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el1_lower;
   wire [31:0]           nxt_ifar_ns;
   assign                nxt_ifar_ns   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el1_upper;
   wire                  expt_en_far_el1; 
   assign                expt_en_far_el1 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL1];
   wire                  expt_en_dfar_ns; 
   assign                expt_en_dfar_ns = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFAR] &  `DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;
   wire                  expt_en_ifar_ns; 
   assign                expt_en_ifar_ns = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR] &  `DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;   
   
   wire [63:0]           nxt_cp_far_el2;
   assign                nxt_cp_far_el2 = {`DPU_PATH.u_dpu_cp.nxt_cp_far_el2_upper, `DPU_PATH.u_dpu_cp.nxt_cp_far_el2_lower};
   wire [31:0]           nxt_dfar_s;
   assign                nxt_dfar_s   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el2_lower;
   wire [31:0]           nxt_ifar_s;
   assign                nxt_ifar_s   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el2_upper;  
   wire [31:0]           nxt_hdfar;
   assign                nxt_hdfar   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el2_lower;
   wire [31:0]           nxt_hifar;
   assign                nxt_hifar   =  `DPU_PATH.u_dpu_cp.nxt_cp_far_el2_upper;
   wire                  expt_en_far_el2; 
   assign                expt_en_far_el2 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL2];      
   wire                  expt_en_dfar_s; 
   assign                expt_en_dfar_s = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_DFAR] &  ~`DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;
   wire                  expt_en_ifar_s; 
   assign                expt_en_ifar_s = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_IFAR] &  ~`DPU_PATH.u_dpu_cp.expt_aa32_uses_el1_esr_wr_i;
   wire                  expt_en_hdfar;
   assign                expt_en_hdfar = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HDFAR];
   wire                  expt_en_hifar;
   assign                expt_en_hifar = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_HIFAR];

   wire [63:0]           nxt_far_el3;
   assign                nxt_far_el3 = `DPU_PATH.u_dpu_cp.nxt_cp_far_el3;
   wire                  expt_en_far_el3;
   assign                expt_en_far_el3 = `DPU_PATH.u_dpu_cp.expt_fault_reg_en_wr_i[`CA53_FAULT_REG_EN_FAR_EL3];
   
   wire [31:0]           nxt_scr;
   assign nxt_scr = {{18{1'b0}},                         // [31:14] RAZ
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_twe,    // [13]    TWE
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_twi,    // [12]    TWI
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_st,     // [11]    ST
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_rw,     // [10]    RW
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_sif,    // [9]     SIF
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_hce,    // [8]     HCE
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_smd,    // [7]     SCD (AA32)/SMD (AA64)
                                          1'b0,          // [6]     RAZ
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_aw,     // [5]     AW
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_fw,     // [4]     FW
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_ea,     // [3]     EA
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_fiq,    // [2]     FIQ
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_irq,    // [1]     IRQ
                   `DPU_PATH.u_dpu_cp.nxt_cp_scr_ns};    // [0]     NS
   
   wire                  expt_en_scr;
   assign                expt_en_scr = `DPU_PATH.u_dpu_cp.expt_mon_mode_clear_ns_i;

   wire         [63:0]    nxt_hcr_el2;
   assign                 nxt_hcr_el2 = {{30{1'b0}},
                         `DPU_PATH.u_dpu_cp.cp_hcr_id,      // 33    ID
                         `DPU_PATH.u_dpu_cp.cp_hcr_cd,      // 32    CD
                         `DPU_PATH.u_dpu_cp.cp_hcr_rw,      // 31    RW
                         `DPU_PATH.u_dpu_cp.cp_hcr_trvm,    // 30    TRVM
                                            1'b0,           // 29    HCD - RES0 if EL3 implemented
                         `DPU_PATH.u_dpu_cp.cp_hcr_tdz,     // 28    TDZ
                         `DPU_PATH.u_dpu_cp.cp_hcr_tge,     // 27    TGE
                         `DPU_PATH.u_dpu_cp.cp_hcr_tvm,     // 26    TVM
                         `DPU_PATH.u_dpu_cp.cp_hcr_ttlb,    // 25    TTLB
                         `DPU_PATH.u_dpu_cp.cp_hcr_tpu,     // 24    TPU
                         `DPU_PATH.u_dpu_cp.cp_hcr_tpc,     // 23    TPC
                         `DPU_PATH.u_dpu_cp.cp_hcr_tsw,     // 22    TSW
                         `DPU_PATH.u_dpu_cp.cp_hcr_tacr,    // 21    TACR
                         `DPU_PATH.u_dpu_cp.cp_hcr_tidcp,   // 20    TIDCP
                         `DPU_PATH.u_dpu_cp.cp_hcr_tsc,     // 19    TSC
                         `DPU_PATH.u_dpu_cp.cp_hcr_tid3,    // 18    TID3
                         `DPU_PATH.u_dpu_cp.cp_hcr_tid2,    // 17    TID2
                         `DPU_PATH.u_dpu_cp.cp_hcr_tid1,    // 16    TID1
                         `DPU_PATH.u_dpu_cp.cp_hcr_tid0,    // 15    TID0
                         `DPU_PATH.u_dpu_cp.cp_hcr_twe,     // 14    TWE
                         `DPU_PATH.u_dpu_cp.cp_hcr_twi,     // 13    TWI
                         `DPU_PATH.u_dpu_cp.cp_hcr_dc,      // 12    DC
                         `DPU_PATH.u_dpu_cp.cp_hcr_bsu,     // 11:10 BSU
                         `DPU_PATH.u_dpu_cp.cp_hcr_fb,      // 9     FB
                         `DPU_PATH.u_dpu_cp.nxt_cp_hcr_va,      // 8     VA
                         `DPU_PATH.u_dpu_cp.cp_hcr_vi,      // 7     VI
                         `DPU_PATH.u_dpu_cp.cp_hcr_vf,      // 6     VF
                         `DPU_PATH.u_dpu_cp.cp_hcr_amo,     // 5     AMO
                         `DPU_PATH.u_dpu_cp.cp_hcr_imo,     // 4     IMO
                         `DPU_PATH.u_dpu_cp.cp_hcr_fmo,     // 3     FMO
                         `DPU_PATH.u_dpu_cp.cp_hcr_ptw,     // 2     PTW
                         1'b1,                              // 1     SWIO
                         `DPU_PATH.u_dpu_cp.cp_hcr_vm};     // 0     VM
   wire                   expt_en_hcr_el2;
   assign                 expt_en_hcr_el2 = `DPU_PATH.u_dpu_cp.clear_virtual_ea_i;



   //We need to pipeline all the expt reg write info to ret, as it is needed by the follower after
   //the InsertForceopRet event which is used to determine where to attach the reg write (i.e.
   //whether the expt is from slot0, slot1 or asynchronous)

   reg        expt_en_hsr_ret       ;
   reg [31:0] nxt_cp_esr_el2_ret    ;
   reg        expt_en_esr_el2_ret   ;
   reg        expt_en_hpfar_ret     ;
   reg [31:0] nxt_cp_hpfar_rd_ret   ;
   reg        expt_en_dfsr_s_ret    ;
   reg        expt_en_dfsr_ns_ret   ;
   reg [31:0] expt_dfsr_full_ret    ;
   reg        expt_en_esr_el1_ret   ;
   reg [31:0] nxt_cp_esr_el1_ret    ;
   reg        expt_en_esr_el3_ret   ;
   reg [31:0] nxt_cp_esr_el3_ret    ;
   reg        expt_en_ifsr_s_ret    ;
   reg [31:0] nxt_ifsr_s_rd_ret     ;
   reg        expt_en_ifsr_ns_ret   ;
   reg [31:0] nxt_ifsr_ns_rd_ret    ;
   reg        expt_en_far_el1_ret   ;
   reg [63:0] nxt_cp_far_el1_ret    ;
   reg        expt_en_dfar_ns_ret   ;
   reg [31:0] nxt_dfar_ns_ret       ;
   reg        expt_en_ifar_ns_ret   ;
   reg [31:0] nxt_ifar_ns_ret       ;
   reg        expt_en_far_el2_ret   ;
   reg [63:0] nxt_cp_far_el2_ret    ;
   reg        expt_en_hdfar_ret     ;
   reg [31:0] nxt_hdfar_ret         ;
   reg        expt_en_hifar_ret     ;
   reg [31:0] nxt_hifar_ret         ;
   reg        expt_en_dfar_s_ret    ;
   reg [31:0] nxt_dfar_s_ret        ;
   reg        expt_en_ifar_s_ret    ;
   reg [31:0] nxt_ifar_s_ret        ;
   reg        expt_en_far_el3_ret   ;
   reg [63:0] nxt_far_el3_ret       ;
   reg        expt_en_scr_ret       ;
   reg [31:0] nxt_scr_ret           ;
   reg        expt_en_hcr_el2_ret   ;
   reg [63:0] nxt_hcr_el2_ret       ; 
   
   always @(posedge clk) begin
     //Don't want to pipeline these conditional on stall_wr or flust_ret
     //Exception will alwasy be in ret on cycle after detection in wr.
     //See ca53dpu_exception.v
     expt_en_hsr_ret       <= expt_en_hsr      ;
     nxt_cp_esr_el2_ret    <= nxt_cp_esr_el2   ;
     expt_en_esr_el2_ret   <= expt_en_esr_el2  ;
     expt_en_hpfar_ret     <= expt_en_hpfar    ;
     nxt_cp_hpfar_rd_ret   <= nxt_cp_hpfar_rd  ;
     expt_en_dfsr_s_ret    <= expt_en_dfsr_s   ;
     expt_dfsr_full_ret    <= expt_dfsr_full   ;
     expt_en_dfsr_ns_ret   <= expt_en_dfsr_ns  ;
     expt_en_esr_el1_ret   <= expt_en_esr_el1  ;
     nxt_cp_esr_el1_ret    <= nxt_cp_esr_el1   ;
     expt_en_esr_el3_ret   <= expt_en_esr_el3  ;
     nxt_cp_esr_el3_ret    <= nxt_cp_esr_el3   ;
     expt_en_ifsr_s_ret    <= expt_en_ifsr_s   ;
     nxt_ifsr_s_rd_ret     <= nxt_ifsr_s_rd    ;
     expt_en_ifsr_ns_ret   <= expt_en_ifsr_ns  ;
     nxt_ifsr_ns_rd_ret    <= nxt_ifsr_ns_rd   ;
     expt_en_far_el1_ret   <= expt_en_far_el1  ;
     nxt_cp_far_el1_ret    <= nxt_cp_far_el1   ;
     expt_en_dfar_ns_ret   <= expt_en_dfar_ns  ;
     nxt_dfar_ns_ret       <= nxt_dfar_ns      ;
     expt_en_ifar_ns_ret   <= expt_en_ifar_ns  ;
     nxt_ifar_ns_ret       <= nxt_ifar_ns      ;
     expt_en_far_el2_ret   <= expt_en_far_el2  ;
     nxt_cp_far_el2_ret    <= nxt_cp_far_el2   ;
     expt_en_hdfar_ret     <= expt_en_hdfar    ;
     nxt_hdfar_ret         <= nxt_hdfar        ;
     expt_en_hifar_ret     <= expt_en_hifar    ;
     nxt_hifar_ret         <= nxt_hifar        ;
     expt_en_dfar_s_ret    <= expt_en_dfar_s   ;
     nxt_dfar_s_ret        <= nxt_dfar_s       ;
     expt_en_ifar_s_ret    <= expt_en_ifar_s   ;
     nxt_ifar_s_ret        <= nxt_ifar_s       ;
     expt_en_far_el3_ret   <= expt_en_far_el3  ;
     nxt_far_el3_ret       <= nxt_far_el3      ;
     expt_en_scr_ret       <= expt_en_scr      ;
     nxt_scr_ret           <= nxt_scr          ;
     expt_en_hcr_el2_ret   <= expt_en_hcr_el2  ;
     nxt_hcr_el2_ret       <= nxt_hcr_el2      ;

     expt_slot1_ret       <= expt_slot1_wr;
     async_expt_ret       <= async_expt_wr;
     expt_reset_ret       <= expt_reset_wr;      
     expt_fiq_ret         <= expt_fiq_wr;        
     expt_vfiq_ret        <= expt_vfiq_wr;       
     expt_irq_ret         <= expt_irq_wr;        
     expt_virq_ret        <= expt_virq_wr;       
     expt_imprecise_ret   <= expt_imprecise_wr;  
     expt_vimprecise_ret  <= expt_vimprecise_wr;
     expt_ext_halt_ret    <= expt_ext_halt_wr;
     expt_osuc_halt_ret   <= expt_osuc_halt_wr;   
     expt_ecc_reexec_ret  <= expt_ecc_reexec_wr;
     enter_halt_ret       <= enter_halt_wr;
   end // always @ (posedge clk)
   
  assign expt_sys_reg_sample =    expt_en_hsr_ret        |
                                  expt_en_esr_el2_ret    |
                                  expt_en_hpfar_ret      |
                                  expt_en_dfsr_s_ret     |
                                  expt_en_dfsr_ns_ret    |
                                  expt_en_esr_el1_ret    |
                                  expt_en_esr_el3_ret    |
                                  expt_en_ifsr_s_ret     |
                                  expt_en_ifsr_ns_ret    |
                                  expt_en_far_el1_ret    |
                                  expt_en_dfar_ns_ret    |
                                  expt_en_ifar_ns_ret    |
                                  expt_en_far_el2_ret    |
                                  expt_en_hdfar_ret      |
                                  expt_en_hifar_ret      |
                                  expt_en_dfar_s_ret     |
                                  expt_en_ifar_s_ret     |
                                  expt_en_far_el3_ret    |
                                  expt_en_scr_ret        |
                                  expt_en_hcr_el2_ret;


//Construct next spsr values
`define PSR_RF_PATH `DPU_PATH.u_dpu_cpsr.u_psr_rf

   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_svc;
   wire [31:0]                     spsr_svc_full;
   wire                            spsr_svc_sample;
   
   assign spsr_svc[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_svc_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_svc[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_svc_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_svc[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_svc_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_SS_BITS];
   assign spsr_svc[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_svc_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_IL_BITS];
   assign spsr_svc[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_svc_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_GE_BITS];

   assign spsr_svc[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_svc_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_svc[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_svc_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_E_BITS];
   assign spsr_svc[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_svc_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_A_BITS];

   assign spsr_svc[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_svc_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_I_BITS];
   assign spsr_svc[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_svc_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_F_BITS];
   assign spsr_svc[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_svc_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_T_BITS];     
   assign spsr_svc[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_svc_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_svc[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_svc_full = {spsr_svc[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_svc[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          spsr_svc[`CA53_SPSR_RET_SS_BITS],
                          spsr_svc[`CA53_SPSR_RET_IL_BITS],
                          spsr_svc[`CA53_SPSR_RET_GE_BITS],
                          spsr_svc[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_svc[`CA53_SPSR_RET_E_BITS],
                          spsr_svc[`CA53_SPSR_RET_A_BITS],
                          spsr_svc[`CA53_SPSR_RET_I_BITS],
                          spsr_svc[`CA53_SPSR_RET_F_BITS],
                          spsr_svc[`CA53_SPSR_RET_T_BITS],
                          spsr_svc[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_svc_sample = |`PSR_RF_PATH.spsr_svc_mask;
   

   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_abt;
   wire [31:0]                     spsr_abt_full;
   wire                            spsr_abt_sample;
   
   assign spsr_abt[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_abt_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_abt[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_abt_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_abt[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_abt_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_SS_BITS];
   assign spsr_abt[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_abt_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_IL_BITS];
   assign spsr_abt[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_abt_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_GE_BITS];

   assign spsr_abt[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_abt_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_abt[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_abt_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_E_BITS];
   assign spsr_abt[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_abt_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_A_BITS];

   assign spsr_abt[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_abt_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_I_BITS];
   assign spsr_abt[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_abt_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_F_BITS];
   assign spsr_abt[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_abt_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_T_BITS];     
   assign spsr_abt[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_abt_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_abt[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_abt_full = {spsr_abt[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_abt[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          1'b0,
                          spsr_abt[`CA53_SPSR_RET_IL_BITS],
                          spsr_abt[`CA53_SPSR_RET_GE_BITS],
                          spsr_abt[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_abt[`CA53_SPSR_RET_E_BITS],
                          spsr_abt[`CA53_SPSR_RET_A_BITS],
                          spsr_abt[`CA53_SPSR_RET_I_BITS],
                          spsr_abt[`CA53_SPSR_RET_F_BITS],
                          spsr_abt[`CA53_SPSR_RET_T_BITS],
                          spsr_abt[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_abt_sample = |`PSR_RF_PATH.spsr_abt_mask;
   

   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_und;
   wire [31:0]                     spsr_und_full;
   wire                            spsr_und_sample;
   
   assign spsr_und[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_und_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_und[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_und_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_und[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_und_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_SS_BITS];
   assign spsr_und[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_und_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_IL_BITS];
   assign spsr_und[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_und_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_GE_BITS];

   assign spsr_und[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_und_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_und[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_und_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_E_BITS];
   assign spsr_und[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_und_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_A_BITS];

   assign spsr_und[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_und_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_I_BITS];
   assign spsr_und[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_und_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_F_BITS];
   assign spsr_und[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_und_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_T_BITS];     
   assign spsr_und[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_und_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_und[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_und_full = {spsr_und[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_und[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          1'b0,
                          spsr_und[`CA53_SPSR_RET_IL_BITS],
                          spsr_und[`CA53_SPSR_RET_GE_BITS],
                          spsr_und[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_und[`CA53_SPSR_RET_E_BITS],
                          spsr_und[`CA53_SPSR_RET_A_BITS],
                          spsr_und[`CA53_SPSR_RET_I_BITS],
                          spsr_und[`CA53_SPSR_RET_F_BITS],
                          spsr_und[`CA53_SPSR_RET_T_BITS],
                          spsr_und[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_und_sample = |`PSR_RF_PATH.spsr_und_mask;


   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_irq;
   wire [31:0]                     spsr_irq_full;
   wire                            spsr_irq_sample;
   
   assign spsr_irq[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_irq_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_irq[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_irq_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_irq[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_irq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_SS_BITS];
   assign spsr_irq[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_irq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_IL_BITS];
   assign spsr_irq[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_irq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_GE_BITS];

   assign spsr_irq[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_irq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_irq[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_irq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_E_BITS];
   assign spsr_irq[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_irq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_A_BITS];

   assign spsr_irq[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_irq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_I_BITS];
   assign spsr_irq[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_irq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_F_BITS];
   assign spsr_irq[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_irq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_T_BITS];     
   assign spsr_irq[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_irq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_irq[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_irq_full = {spsr_irq[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_irq[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          1'b0,
                          spsr_irq[`CA53_SPSR_RET_IL_BITS],
                          spsr_irq[`CA53_SPSR_RET_GE_BITS],
                          spsr_irq[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_irq[`CA53_SPSR_RET_E_BITS],
                          spsr_irq[`CA53_SPSR_RET_A_BITS],
                          spsr_irq[`CA53_SPSR_RET_I_BITS],
                          spsr_irq[`CA53_SPSR_RET_F_BITS],
                          spsr_irq[`CA53_SPSR_RET_T_BITS],
                          spsr_irq[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_irq_sample = |`PSR_RF_PATH.spsr_irq_mask;

   
   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_fiq;
   wire [31:0]                     spsr_fiq_full;
   wire                            spsr_fiq_sample;
   
   assign spsr_fiq[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_fiq_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_fiq_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_fiq[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_fiq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_SS_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_fiq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_IL_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_fiq_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_GE_BITS];

   assign spsr_fiq[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_fiq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_fiq[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_fiq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_E_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_fiq_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_A_BITS];

   assign spsr_fiq[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_fiq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_I_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_fiq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_F_BITS];
   assign spsr_fiq[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_fiq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_T_BITS];     
   assign spsr_fiq[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_fiq_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_fiq[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_fiq_full = {spsr_fiq[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_fiq[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          1'b0,
                          spsr_fiq[`CA53_SPSR_RET_IL_BITS],
                          spsr_fiq[`CA53_SPSR_RET_GE_BITS],
                          spsr_fiq[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_fiq[`CA53_SPSR_RET_E_BITS],
                          spsr_fiq[`CA53_SPSR_RET_A_BITS],
                          spsr_fiq[`CA53_SPSR_RET_I_BITS],
                          spsr_fiq[`CA53_SPSR_RET_F_BITS],
                          spsr_fiq[`CA53_SPSR_RET_T_BITS],
                          spsr_fiq[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_fiq_sample = |`PSR_RF_PATH.spsr_fiq_mask;

 
   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_mon;
   wire [31:0]                     spsr_mon_full;
   wire                            spsr_mon_sample;
   
   assign spsr_mon[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_mon_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_mon[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_mon_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_mon[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_mon_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_SS_BITS];
   assign spsr_mon[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_mon_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_IL_BITS];
   assign spsr_mon[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_mon_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_GE_BITS];

   assign spsr_mon[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_mon_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_mon[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_mon_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_E_BITS];
   assign spsr_mon[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_mon_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_A_BITS];

   assign spsr_mon[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_mon_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_I_BITS];
   assign spsr_mon[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_mon_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_F_BITS];
   assign spsr_mon[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_mon_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_T_BITS];     
   assign spsr_mon[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_mon_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_mon[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_mon_full = {spsr_mon[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_mon[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          spsr_mon[`CA53_SPSR_RET_SS_BITS],
                          spsr_mon[`CA53_SPSR_RET_IL_BITS],
                          spsr_mon[`CA53_SPSR_RET_GE_BITS],
                          spsr_mon[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_mon[`CA53_SPSR_RET_E_BITS],
                          spsr_mon[`CA53_SPSR_RET_A_BITS],
                          spsr_mon[`CA53_SPSR_RET_I_BITS],
                          spsr_mon[`CA53_SPSR_RET_F_BITS],
                          spsr_mon[`CA53_SPSR_RET_T_BITS],
                          spsr_mon[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_mon_sample = |`PSR_RF_PATH.spsr_mon_mask;

 
   wire [`CA53_SPSR_RET_W - 1 : 0] spsr_hyp;
   wire [31:0]                     spsr_hyp_full;
   wire                            spsr_hyp_sample;
   
   assign spsr_hyp[`CA53_SPSR_RET_NZCVQ_BITS] = `PSR_RF_PATH.spsr_hyp_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_NZCVQ_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_NZCVQ_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_IT_LOW_BITS] = `PSR_RF_PATH.spsr_hyp_mask[3] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_LOW_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_IT_LOW_BITS];
   
   assign spsr_hyp[`CA53_SPSR_RET_SS_BITS] = `PSR_RF_PATH.spsr_hyp_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_SS_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_SS_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_IL_BITS] = `PSR_RF_PATH.spsr_hyp_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IL_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_IL_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_GE_BITS] = `PSR_RF_PATH.spsr_hyp_mask[2] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_GE_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_GE_BITS];

   assign spsr_hyp[`CA53_SPSR_RET_IT_HICM_BITS] = `PSR_RF_PATH.spsr_hyp_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_IT_HICM_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_IT_HICM_BITS]; 
   assign spsr_hyp[`CA53_SPSR_RET_E_BITS] = `PSR_RF_PATH.spsr_hyp_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_E_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_E_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_A_BITS] = `PSR_RF_PATH.spsr_hyp_mask[1] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_A_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_A_BITS];

   assign spsr_hyp[`CA53_SPSR_RET_I_BITS] = `PSR_RF_PATH.spsr_hyp_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_I_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_I_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_F_BITS] = `PSR_RF_PATH.spsr_hyp_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_F_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_F_BITS];
   assign spsr_hyp[`CA53_SPSR_RET_T_BITS] = `PSR_RF_PATH.spsr_hyp_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_T_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_T_BITS];     
   assign spsr_hyp[`CA53_SPSR_RET_MODE_BITS] = `PSR_RF_PATH.spsr_hyp_mask[0] ? `PSR_RF_PATH.nxt_spsr_ret_i[`CA53_SPSR_RET_MODE_BITS] : `PSR_RF_PATH.spsr_hyp[`CA53_SPSR_RET_MODE_BITS];     
 
   assign spsr_hyp_full = {spsr_hyp[`CA53_SPSR_RET_NZCVQ_BITS],
                          spsr_hyp[`CA53_SPSR_RET_IT_LOW_BITS],
                          3'b0,
                          spsr_hyp[`CA53_SPSR_RET_SS_BITS],
                          spsr_hyp[`CA53_SPSR_RET_IL_BITS],
                          spsr_hyp[`CA53_SPSR_RET_GE_BITS],
                          spsr_hyp[`CA53_SPSR_RET_IT_HICM_BITS],
                          spsr_hyp[`CA53_SPSR_RET_E_BITS],
                          spsr_hyp[`CA53_SPSR_RET_A_BITS],
                          spsr_hyp[`CA53_SPSR_RET_I_BITS],
                          spsr_hyp[`CA53_SPSR_RET_F_BITS],
                          spsr_hyp[`CA53_SPSR_RET_T_BITS],
                          spsr_hyp[`CA53_SPSR_RET_MODE_BITS]};

   assign spsr_hyp_sample = |`PSR_RF_PATH.spsr_hyp_mask;

//trigger sampling of cpsr/spsr data
  wire  psr_sample;
  assign psr_sample = cpsr_regfile_en_wr|spsr_svc_sample|spsr_abt_sample|spsr_und_sample|spsr_irq_sample|spsr_fiq_sample|spsr_mon_sample|spsr_hyp_sample;
   
//trace PAR updates due to address translation operations
  wire ats_par_sample;
  assign ats_par_sample = ((`DCU_PATH.dcu_cp_reg_en_dc3_o == `CA53_CP15_V2P_PAR) &&  `DCU_PATH.dcu_cp_reg_write_dc3_o == 1'b1);
  wire [63:0] dcu_cp_reg_data;
  assign dcu_cp_reg_data = `DCU_PATH.dcu_cp_reg_data_o;


//Functions for reconstructing the opcodes.
function [31:0] pfb_to_raw_encoding;   
  input [47:0] pfb_encoding;
  input        aarch64_state;
  input        dbg_halted;
     
  reg   [39:0] icb_encoding_for_reconstruction;


        //We don't have to worry about encodings that indicate prefetch abort or hardware breakpoints, since the encoding will 
        //not be sampled for tarmac/univent in those cases. 
         
    case ({aarch64_state, pfb_encoding[36]})
      2'b00: begin // A32
        // A32
        if (pfb_encoding[47:27] == 21'b000000_0100_1_00_1_1_1110_11) begin //BKPT (the underscores match the lines in the spreadsheet)
          icb_encoding_for_reconstruction = 40'hebe000_0000;

        end else begin
          icb_encoding_for_reconstruction = { 
                                               pfb_encoding[32:29],                                        /* cond[ 3: 0]                 */ 
                                               pfb_encoding[15: 0],                                        /* encoding[15: 0]             */ 
                                               (pfb_encoding[36:35] == 2'b01)? 1'b1: 1'b0,                 /* ARM only                    */ 
                                               pfb_encoding[47:42],                                        /* Sideband                    */ 
                                               pfb_encoding[28:16]                                         /* encoding[28:16]             */ 
                                               };
        end

        if (icb_encoding_for_reconstruction[18:13] == `SIDEBAND_UNDEF) begin
          // We need first to check if the original encoding was undef or unpred
          pfb_to_raw_encoding[31:28] = icb_encoding_for_reconstruction[39:36];
          pfb_to_raw_encoding[27:0]  = {icb_encoding_for_reconstruction[11:0],icb_encoding_for_reconstruction[35:20]};
        end else begin
          // normal case
          pfb_to_raw_encoding[31:0] = t32_to_a32(icb_encoding_for_reconstruction);
        end
                
      end
      2'b01: begin // Thumb
        if (pfb_encoding[47:27] == 21'b000000_0100_1_00_1_1_1110_11) begin //BKPT (the underscores match the lines in the spreadsheet)
          icb_encoding_for_reconstruction = 40'h00_0000_be00;
            
        end else if (pfb_encoding[36:35] == 2'b11) begin // T16

          icb_encoding_for_reconstruction = ({ 
                                                  20'h0_0000,                                                                           
                                                  1'h0,                                               /* t16 or t32b                 */ 
                                                  3'b000,                                             /* t16 sideband: to do         */ 
                                                  pfb_encoding[15: 0]                                     /* encoding[15: 0]             */ 
                                               });
          if (pfb_encoding[47:42] == `SIDEBAND_UNDEF) begin

          casez (pfb_encoding[28:16])
            // BLX UNPREDICTABLE
            13'b0011111111???,
            // CMP UNPREDICTABLE
            13'b00101?1111???,
            13'b001011????111: icb_encoding_for_reconstruction[15: 0] = { 3'b010, pfb_encoding[28:16] };
            // POP, PUSH UNPREDICTABLE
            13'b1?10000000000,
            // IT UNPREDICTABLE
            13'b1111111111???,
            13'b11111111101??,
            13'b111111111001?,
            13'b1111111110001,
            13'b1111111101??1,
            13'b1111111101?1?,
            13'b11111111011??,
            13'b111111110011?,
            13'b1111111100101,
            13'b1111111100011,
            // UNDEFINED
            13'b1011011?1????,
            13'b10110?0??????,
            13'b10110?100????,
            13'b101110???????,
            13'b1011110??????,
            13'b10111110?????,
            13'b101111111????,
            13'b1011?1110????,
            13'b11000????????,
            13'b1101010??????: icb_encoding_for_reconstruction[15: 0] = { 3'b101, pfb_encoding[28:16] };
            // UNDEFINED
            13'b11110????????: icb_encoding_for_reconstruction[15: 0] = { 3'b110, pfb_encoding[28:16] };
            endcase
          end 

          if (pfb_encoding[28:16] != 13'd0) begin
            // translate T32 which will set icb_encoding_for_reconstruction[15:0]
            icb_encoding_for_reconstruction = undo_t16_to_t32(pfb_encoding);
          end
          
          if (icb_encoding_for_reconstruction[15:0] == 16'h0000)
            pfb_to_raw_encoding[31:0] = {16'h0000,16'h0000};
          else
            pfb_to_raw_encoding[31:0] = {16'h0000,icb_encoding_for_reconstruction[15:0]};

          
        end else begin //T32
          
          icb_encoding_for_reconstruction =  { 
                                               1'h0,                                               /* t16 or t32b                 */ 
                                               3'b000,                                             /* t16 sideband: to do         */ 
                                               pfb_encoding[15: 0],                                    /* encoding[15: 0]             */ 
                                               1'h1,                                               /* t32a                        */ 
                                               pfb_encoding[47:42],                                    /* sideband                    */ 
                                               pfb_encoding[28:16]                                     /* encoding[28:16]             */ 
                                               };

          pfb_to_raw_encoding[31:0]= {3'b111,icb_encoding_for_reconstruction[12:0],icb_encoding_for_reconstruction[35:20]};                 
        end
      end
      2'b10: begin //A64 
        if (pfb_encoding[47:27] == 21'b000000_0100_1_00_1_1_1110_11) begin //BKPT (the underscores match the lines in the spreadsheet)
          icb_encoding_for_reconstruction = {4'b0000,          // sf, m, n, d
                                             8'b10111110,      // t32[15:8]
                                             pfb_encoding[7:0],    // t32[7:0] (imm8l)
                                             1'b0,             // arm only
                                             6'b100111,   // sidbeband
                                             5'b00000,         // t32[28:24]
                                             pfb_encoding[15:8]};  // t32[23:16] (imm8h)          
        end else begin
          icb_encoding_for_reconstruction = { 
                                              pfb_encoding[32:29],                                        /* sf,m,m,d                    */ 
                                              pfb_encoding[15: 0],                                        /* encoding[15: 0]             */ 
                                              (pfb_encoding[36:35] == 2'b01)? 1'b1: 1'b0,                 /* ARM only                    */ 
                                              pfb_encoding[47:42],                                        /* Sideband                    */ 
                                              pfb_encoding[28:16]                                         /* encoding[28:16]             */ 
                                              };
        end
        
        if (icb_encoding_for_reconstruction[18:13] == `SIDEBAND_UNDEF) begin
          // We need first to check if the original encoding was undef or unpred
          pfb_to_raw_encoding[31:28] = icb_encoding_for_reconstruction[39:36];
          pfb_to_raw_encoding[27:0]  = {icb_encoding_for_reconstruction[11:0],icb_encoding_for_reconstruction[35:20]};
        end else begin
          // normal case
          pfb_to_raw_encoding[31:0] = t32_to_a64(icb_encoding_for_reconstruction);
        end
 
      end
    endcase

endfunction
`undef SIDEBAND_UNDEF 


  
function [63:0] instr_addr;
     input [63:0] pc;
     input [ 1:0] isa;
     case (isa)
       2'b00: begin // A32
         instr_addr = (pc - 8) & 64'hFFFFFFFF;
       end
       2'b01: begin // Thumb
         instr_addr = (pc - 4) & 64'hFFFFFFFF;
       end
       2'b10: begin // A64
         instr_addr = pc;
       end
     endcase
endfunction

  


`include "ca53_follower_reconstruct.v"



`ifdef CORTEXA53_UNIVENT_DPI_CAPTURE
 
reg tarmac_enable;
string time_string;
   
import "DPI-C" context function void ca53_finish();
import "DPI-C" context function int ca53_declare(input string defn);
import "DPI-C" context function void ca53_probe(longint probe);
import "DPI-C" context function void ca53_activate(int cpid, longint now);
import "DPI-C" context function void ca53_set_time_unit(input string time_string);
   
initial begin
   if ($test$plusargs("ca53_tarmac_enable")) begin
     //x -> 1 transition gives posedge to trigger ca53_declare calls. Need to use non-blocking assignment 
     // to give a delta cycle delay as at least one simulator doesn't treat this as a posedge if there is no delay.
     tarmac_enable <= 1;
     #1
     $swrite(time_string, "%t", 0);
     ca53_set_time_unit(time_string);  
   end else begin
     $display("CA53 tarmac built, but not enabled. (Use +ca53_tarmac_enable to enable)");
     tarmac_enable <= 0;
   end  
end 
         
final begin
   if (tarmac_enable) begin
     ca53_finish();
     $display("ca53_finish called");
   end
end 
   
`include "generated_dpi_capture_points.sv"
`endif

endmodule // ca53_follower


`undef DPU_PATH
`undef DCU_PATH
`undef TLB_PATH
`undef PSR_RF_PATH


`define CA53_UNDEFINE
`include "ca53_biu_scu_defs.v"
`include "ca53_dpu_dcu_defs.v"
`include "ca53dpu_params.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE

