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
//
// Overview
// ========
// Top level of CortexA53 ETM (Embedded Trace Macrocell)
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm (

    //Clock, reset signals
    input  wire         clk,                       //clock for ETM main logic (from architectural clock gate)
    input  wire         po_reset_n,                // Power on reset signal (active low)
    input  wire         gov_atclken_i,             //clk edge qualifier for ATB interface

    // ATB interface
    output wire         etm_atvalidm_o,            //ATB Valid
    input  wire         gov_atreadym_i,            //ATB Ready
    output wire         etm_afreadym_o,            //ATB Flush response
    input  wire         gov_afvalidm_i,            //ATB Flush request
    output wire  [31:0] etm_atdatam_o,             //ATB Data
    output wire  [1:0]  etm_atbytesm_o,            //ATB Size of valid data
    output wire  [6:0]  etm_atidm_o,               //ATB Trace stream ID
    input  wire         gov_syncreqm_i,            //Synchronization request from trace sink

    //APB interface
    input  wire         gov_pseldbg_etm_i,          //APB select
    input  wire         gov_penabledbg_i,           //APB enable
    input  wire  [31:0] gov_pwdatadbg_i,            //APB write data
    input  wire  [11:2] gov_paddrdbg_i,             //APB address
    input  wire         gov_pwritedbg_i,            //APB read/write control
    input  wire         gov_etmpdsr_rd_i,           //SW unlocked or external access
    output wire  [31:0] etm_prdatadbg_o,            //APB read data
    output wire         etm_preadydbg_o,            //APB control


    //Core interface
    output wire         etm_stall_cpu_o,            //CPU stall request driven from FIFO depth
    output wire         etm_if_en_o,                //Enable for core's ETM interface, indicating to core that trace is desired
    output wire         etm_wfx_ready_o,            //ETM is read for WFx state
    input  wire         gov_wfx_drain_req_i,        //Governor request for ETM to drain all its data
    input  wire         dpu_wpt_valid_i,            //Qualifier for other signals on this interface
    input  wire  [63:1] dpu_wpt_addr_i,             //virtual address (instruction or exception preferred return address)
    input  wire  [63:1] dpu_wpt_target_addr_opa_i,  //Target virtual address opA (add with opB)
    input  wire  [27:1] dpu_wpt_target_addr_opb_i,  //Target virtual address opB
    input  wire         dpu_wpt_advance_i,          //Low if exceptoion is back-to-back with no execution in between
    input  wire         dpu_wpt_range_i,            //Low if reset/debug/prohibited since last waypoint
    input  wire  [31:0] tlb_context_id_i,           //Target Context ID
    input  wire   [7:0] tlb_vmid_i,                 //Target VMID
    input  wire   [1:0] tlb_d_tcr_el1_tbi_i,        //For tagged address calculation
    input  wire         tlb_d_tcr_el2_tbi0_i,       //For tagged address calculation
    input  wire         tlb_d_tcr_el3_tbi0_i,       //For tagged address calculation
       
    input  wire   [2:0] dpu_wpt_type_i,             //Waypoint type
    input  wire         dpu_wpt_link_i,             //Waypoint is a branch with link instruction
    input  wire         dpu_wpt_taken_i,            //Branch taken
    input  wire   [1:0] dpu_wpt_target_isa_i,       //A64, A32 or T32
    input  wire         dpu_wpt_t32_nt16_i,         //Waypoint is 32 bit instruction
    input  wire   [3:0] dpu_wpt_exception_type_i,   //Exception type
    input  wire         dpu_wpt_non_secure_i,       //Waypoint target has NS bit set
    input  wire   [3:0] dpu_wpt_exlevel_i,          //Waypoint exception level
    input  wire         dpu_wpt_prohibited_i,       //Waypoint target is trace prohibited region


    //CTI, miscellaneous signals
    input  wire         DFTSE,                      //Scan enable
    input  wire   [3:0] gov_extin_i,                //CTI event inputs
    input  wire  [25:0] dpu_pmuevent_i,             //PMU event inputs
    output wire   [3:0] etm_extout_o,               //Event outputs to CTI
    input  wire  [63:0] gov_tsvalueb_i,             //Timestamp value
    output wire         etm_oslock_o,               //OS lock signal
    input  wire         gov_dbgen_i,                //Invasive debug enable
    input  wire         gov_niden_i                 //Non-invasive debug enable

     );

  //
  /*ARMAUTO*/
  // The following wires were automatically generated
  // to interconnect instantiations where appropriate.
  wire         [16:0] apb_pwdatadbg_16to0;
  wire                apb_pwdatadbg_31;
  wire                async_req_t4;
  wire                at_active_state;
  wire                at_idle_ack;
  wire                atb_afvalid;
  wire                atb_atready;
  wire                atb_reg_ack;
  wire                auxctlr_frc_afready_reg;
  wire                auxctlr_frc_auth_noflush_reg;
  wire                auxctlr_frc_idleack_reg;
  wire                auxctlr_frc_ovflow_reg;
  wire                auxctlr_frc_sync_delay_reg;
  wire                auxctlr_frc_ts_nodelay_reg;
  wire                bb_en_t2;
  wire                bb_mode_reg;
  wire          [3:0] bb_range_reg;
  wire                branch_broadcast_reg;
  wire         [11:0] cc_threshold_reg;
  wire          [3:0] cid_comp_mask_reg;
  wire         [31:0] cid_comp_value_reg;
  wire                cid_match_t2;
  wire                clk_gated;
  wire                clk_reg_req;
  wire         [48:0] comp0_addr_reg;
  wire          [1:0] comp0_context_reg;
  wire          [2:0] comp0_exlevel_ns_reg;
  wire          [2:0] comp0_exlevel_s_reg;
  wire                comp0_match_t2;
  wire         [48:0] comp1_addr_reg;
  wire          [1:0] comp1_context_reg;
  wire          [2:0] comp1_exlevel_ns_reg;
  wire          [2:0] comp1_exlevel_s_reg;
  wire                comp1_match_t2;
  wire         [48:0] comp2_addr_reg;
  wire          [1:0] comp2_context_reg;
  wire          [2:0] comp2_exlevel_ns_reg;
  wire          [2:0] comp2_exlevel_s_reg;
  wire                comp2_match_t2;
  wire         [48:0] comp3_addr_reg;
  wire          [1:0] comp3_context_reg;
  wire          [2:0] comp3_exlevel_ns_reg;
  wire          [2:0] comp3_exlevel_s_reg;
  wire                comp3_match_t2;
  wire         [48:0] comp4_addr_reg;
  wire          [1:0] comp4_context_reg;
  wire          [2:0] comp4_exlevel_ns_reg;
  wire          [2:0] comp4_exlevel_s_reg;
  wire                comp4_match_t2;
  wire         [48:0] comp5_addr_reg;
  wire          [1:0] comp5_context_reg;
  wire          [2:0] comp5_exlevel_ns_reg;
  wire          [2:0] comp5_exlevel_s_reg;
  wire                comp5_match_t2;
  wire         [48:0] comp6_addr_reg;
  wire          [1:0] comp6_context_reg;
  wire          [2:0] comp6_exlevel_ns_reg;
  wire          [2:0] comp6_exlevel_s_reg;
  wire                comp6_match_t2;
  wire         [48:0] comp7_addr_reg;
  wire          [1:0] comp7_context_reg;
  wire          [2:0] comp7_exlevel_ns_reg;
  wire          [2:0] comp7_exlevel_s_reg;
  wire                comp7_match_t2;
  wire                context_id_reg;
  wire                core_at_main_run_t2;
  wire          [4:0] counter0_cntevent_reg;
  wire                counter0_control_write;
  wire         [15:0] counter0_reload_reg;
  wire          [4:0] counter0_rldevent_reg;
  wire                counter0_rldself_reg;
  wire         [15:0] counter0_value;
  wire                counter0_write;
  wire                counter0_zero_t3;
  wire                counter1_cntchain_reg;
  wire          [4:0] counter1_cntevent_reg;
  wire                counter1_control_write;
  wire         [15:0] counter1_reload_reg;
  wire          [4:0] counter1_rldevent_reg;
  wire                counter1_rldself_reg;
  wire         [15:0] counter1_value;
  wire                counter1_write;
  wire                counter1_zero_t3;
  wire                cycle_counting_reg;
  wire          [6:0] etm_atidm_reg;
  wire          [3:0] etm_extout;
  wire                etm_if_en;
  wire                etm_os_lock_trace;
  wire                etm_oslock;
  wire                etm_wfx_ready;
  wire          [4:0] event0_sel_reg;
  wire          [4:0] event1_sel_reg;
  wire          [4:0] event2_sel_reg;
  wire          [4:0] event3_sel_reg;
  wire                event_atbtrig_en_reg;
  wire          [3:0] event_enable_reg;
  wire                event_trigger_req_t3;
  wire         [22:2] evt_resources_t2;
  wire          [3:0] extin_rsrc_t2;
  wire          [4:0] extin_sel0_reg;
  wire          [4:0] extin_sel1_reg;
  wire          [4:0] extin_sel2_reg;
  wire          [4:0] extin_sel3_reg;
  wire                fifo_8bytes_t6;
  wire          [1:0] fifo_bytes;
  wire         [31:0] fifo_data;
  wire                fifo_empty;
  wire                fifo_flush_ack;
  wire                fifo_flush_req;
  wire                fifo_idle_ack;
  wire                fifo_idle_req_t2;
  wire                fifo_level28_t7;
  wire                fifo_overflow;
  wire                fifo_ready;
  wire                fifo_valid;
  wire                gov_wfx_drain_req_t2;
  wire                int_test_enable;
  wire                istall_reg;
  wire                low_power_override_flush;
  wire                lp_override_reg;
  wire          [4:0] num_bytes_t5;
  wire          [2:0] num_first8_t5;
  wire                ovfl_req_t2;
  wire        [203:0] pack_fifo_in_t5;
  wire                range0_excl_t2;
  wire                range0_match_t2;
  wire                range1_excl_t2;
  wire                range1_match_t2;
  wire                range2_excl_t2;
  wire                range2_match_t2;
  wire                range3_excl_t2;
  wire                range3_match_t2;
  wire                resource_active_t2;
  wire                resource_active_t3;
  wire                resource_active_t4;
  wire                resource_active_t5;
  wire                return_stack_en_reg;
  wire          [3:0] seq_resource_t2;
  wire          [4:0] seq_rst_reg;
  wire          [1:0] seq_state_t2;
  wire          [4:0] seq_transition_b0_reg;
  wire          [4:0] seq_transition_b1_reg;
  wire          [4:0] seq_transition_b2_reg;
  wire          [4:0] seq_transition_f0_reg;
  wire          [4:0] seq_transition_f1_reg;
  wire          [4:0] seq_transition_f2_reg;
  wire                seq_write;
  wire          [3:0] ssc_arc_reg;
  wire                ssc_resource_t2;
  wire                ssc_rst_reg;
  wire          [7:0] ssc_sac_reg;
  wire                ssc_status_t2;
  wire                ssc_write;
  wire          [1:0] stall_level_reg;
  wire          [4:0] sync_period_reg;
  wire                sync_req_t2;
  wire                timestamp_en_reg;
  wire                trace_active_1st_wpt_t4;
  wire                trace_enable_reg;
  wire                trace_overflow;
  wire                trace_req_t0;
  wire          [3:0] traced_event_t3;
  wire                trcgen_idle_ack;
  wire          [2:0] trcrsctlr10_group_reg;
  wire                trcrsctlr10_inv_reg;
  wire                trcrsctlr10_pairinv_reg;
  wire          [7:0] trcrsctlr10_select_reg;
  wire          [2:0] trcrsctlr11_group_reg;
  wire                trcrsctlr11_inv_reg;
  wire          [7:0] trcrsctlr11_select_reg;
  wire          [2:0] trcrsctlr12_group_reg;
  wire                trcrsctlr12_inv_reg;
  wire                trcrsctlr12_pairinv_reg;
  wire          [7:0] trcrsctlr12_select_reg;
  wire          [2:0] trcrsctlr13_group_reg;
  wire                trcrsctlr13_inv_reg;
  wire          [7:0] trcrsctlr13_select_reg;
  wire          [2:0] trcrsctlr14_group_reg;
  wire                trcrsctlr14_inv_reg;
  wire                trcrsctlr14_pairinv_reg;
  wire          [7:0] trcrsctlr14_select_reg;
  wire          [2:0] trcrsctlr15_group_reg;
  wire                trcrsctlr15_inv_reg;
  wire          [7:0] trcrsctlr15_select_reg;
  wire          [2:0] trcrsctlr2_group_reg;
  wire                trcrsctlr2_inv_reg;
  wire                trcrsctlr2_pairinv_reg;
  wire          [7:0] trcrsctlr2_select_reg;
  wire          [2:0] trcrsctlr3_group_reg;
  wire                trcrsctlr3_inv_reg;
  wire          [7:0] trcrsctlr3_select_reg;
  wire          [2:0] trcrsctlr4_group_reg;
  wire                trcrsctlr4_inv_reg;
  wire                trcrsctlr4_pairinv_reg;
  wire          [7:0] trcrsctlr4_select_reg;
  wire          [2:0] trcrsctlr5_group_reg;
  wire                trcrsctlr5_inv_reg;
  wire          [7:0] trcrsctlr5_select_reg;
  wire          [2:0] trcrsctlr6_group_reg;
  wire                trcrsctlr6_inv_reg;
  wire                trcrsctlr6_pairinv_reg;
  wire          [7:0] trcrsctlr6_select_reg;
  wire          [2:0] trcrsctlr7_group_reg;
  wire                trcrsctlr7_inv_reg;
  wire          [7:0] trcrsctlr7_select_reg;
  wire          [2:0] trcrsctlr8_group_reg;
  wire                trcrsctlr8_inv_reg;
  wire                trcrsctlr8_pairinv_reg;
  wire          [7:0] trcrsctlr8_select_reg;
  wire          [2:0] trcrsctlr9_group_reg;
  wire                trcrsctlr9_inv_reg;
  wire          [7:0] trcrsctlr9_select_reg;
  wire                trcstatr_idle;
  wire                trcstatr_pmstable;
  wire          [4:0] ts_event_reg;
  wire                ts_event_t2;
  wire                ts_output_en_pend_t3;
  wire                viewinst_en_t2;
  wire          [4:0] viewinst_event_reg;
  wire          [3:0] viewinst_exc_ranges_reg;
  wire          [2:0] viewinst_exlevel_ns_reg;
  wire          [2:0] viewinst_exlevel_s_reg;
  wire                viewinst_idle_req_t2;
  wire          [3:0] viewinst_inc_ranges_reg;
  wire                viewinst_sstatus;
  wire          [7:0] viewinst_start_cmp_reg;
  wire          [7:0] viewinst_stop_cmp_reg;
  wire                viewinst_trcerr_reg;
  wire                viewinst_trcreset_reg;
  wire                viewinst_write;
  wire          [7:0] vmid_comp_value_reg;
  wire                vmid_match_t2;
  wire                vmid_reg;
  wire                wfx_resource_t3;
  wire                wpt_aarch64_t2;
  wire         [63:1] wpt_addr_t1;
  wire                wpt_adv_t1;
  wire                wpt_adv_t2;
  wire         [31:0] wpt_context_id_t2;
  wire                wpt_dbg_entry_t2;
  wire                wpt_dbg_exit_t2;
  wire          [3:0] wpt_exlevel_t2;
  wire                wpt_non_secure_t2;
  wire                wpt_prohibited_t2;
  wire                wpt_range_t1;
  wire         [63:1] wpt_target_pc_t2;
  wire          [2:0] wpt_type_t1;
  wire                wpt_valid_t1;
  wire                wpt_valid_t2;
  wire          [7:0] wpt_vmid_t2;
  wire                write_at_id;
  wire                write_ir_atb_data;
  wire                write_ir_atb_out;
        /*END*/


  // -----------------------------
  // Mid-level clock gating for ETM
  // -----------------------------
  ca53etm_clk u_ca53etm_clk (
  /*ARMAUTO*/
    // Inputs
    .clk               (clk),
    .po_reset_n        (po_reset_n),
    .DFTSE             (DFTSE),
    .gov_pseldbg_etm_i (gov_pseldbg_etm_i),
    .gov_penabledbg_i  (gov_penabledbg_i),
    .etm_if_en_i       (etm_if_en),
    .trcstatr_idle_i   (trcstatr_idle),
    // Outputs
    .clk_gated_o       (clk_gated),
    .clk_reg_req_o     (clk_reg_req)
  );  // u_ca53etm_clk
  

  ca53etm_apb u_apb(
  /*ARMAUTO*/
    // Inputs
    .clk_gated                      (clk_gated),
    .po_reset_n                     (po_reset_n),
    .clk_reg_req_i                  (clk_reg_req),
    .gov_pwdatadbg_i                (gov_pwdatadbg_i[31:0]),
    .gov_paddrdbg_i                 (gov_paddrdbg_i[11:2]),
    .gov_pwritedbg_i                (gov_pwritedbg_i),
    .gov_etmpdsr_rd_i               (gov_etmpdsr_rd_i),
    .atb_reg_ack_i                  (atb_reg_ack),
    .atb_afvalid_i                  (atb_afvalid),
    .atb_atready_i                  (atb_atready),
    .etm_atidm_reg_i                (etm_atidm_reg[6:0]),
    .trcstatr_idle_i                (trcstatr_idle),
    .trcstatr_pmstable_i            (trcstatr_pmstable),
    .viewinst_sstatus_i             (viewinst_sstatus),
    .counter0_value_i               (counter0_value[15:0]),
    .counter1_value_i               (counter1_value[15:0]),
    .seq_state_t2_i                 (seq_state_t2[1:0]),
    .ssc_status_t2_i                (ssc_status_t2),
    // Outputs
    .etm_prdatadbg_o                (etm_prdatadbg_o[31:0]),
    .etm_preadydbg_o                (etm_preadydbg_o),
    .int_test_enable_o              (int_test_enable),
    .write_at_id_o                  (write_at_id),
    .write_ir_atb_out_o             (write_ir_atb_out),
    .write_ir_atb_data_o            (write_ir_atb_data),
    .apb_pwdatadbg_31_o             (apb_pwdatadbg_31),
    .apb_pwdatadbg_16to0_o          (apb_pwdatadbg_16to0[16:0]),
    .istall_reg_o                   (istall_reg),
    .stall_level_reg_o              (stall_level_reg[1:0]),
    .trace_enable_reg_o             (trace_enable_reg),
    .etm_if_en_o                    (etm_if_en),
    .etm_oslock_o                   (etm_oslock),
    .etm_os_lock_trace_o            (etm_os_lock_trace),
    .vmid_reg_o                     (vmid_reg),
    .return_stack_en_reg_o          (return_stack_en_reg),
    .timestamp_en_reg_o             (timestamp_en_reg),
    .context_id_reg_o               (context_id_reg),
    .cycle_counting_reg_o           (cycle_counting_reg),
    .branch_broadcast_reg_o         (branch_broadcast_reg),
    .lp_override_reg_o              (lp_override_reg),
    .event_atbtrig_en_reg_o         (event_atbtrig_en_reg),
    .event_enable_reg_o             (event_enable_reg[3:0]),
    .cc_threshold_reg_o             (cc_threshold_reg[11:0]),
    .sync_period_reg_o              (sync_period_reg[4:0]),
    .bb_mode_reg_o                  (bb_mode_reg),
    .bb_range_reg_o                 (bb_range_reg[3:0]),
    .viewinst_write_o               (viewinst_write),
    .viewinst_start_cmp_reg_o       (viewinst_start_cmp_reg[7:0]),
    .viewinst_stop_cmp_reg_o        (viewinst_stop_cmp_reg[7:0]),
    .viewinst_event_reg_o           (viewinst_event_reg[4:0]),
    .viewinst_exlevel_ns_reg_o      (viewinst_exlevel_ns_reg[2:0]),
    .viewinst_exlevel_s_reg_o       (viewinst_exlevel_s_reg[2:0]),
    .viewinst_trcerr_reg_o          (viewinst_trcerr_reg),
    .viewinst_trcreset_reg_o        (viewinst_trcreset_reg),
    .viewinst_exc_ranges_reg_o      (viewinst_exc_ranges_reg[3:0]),
    .viewinst_inc_ranges_reg_o      (viewinst_inc_ranges_reg[3:0]),
    .ts_event_reg_o                 (ts_event_reg[4:0]),
    .comp0_addr_reg_o               (comp0_addr_reg[48:0]),
    .comp1_addr_reg_o               (comp1_addr_reg[48:0]),
    .comp2_addr_reg_o               (comp2_addr_reg[48:0]),
    .comp3_addr_reg_o               (comp3_addr_reg[48:0]),
    .comp4_addr_reg_o               (comp4_addr_reg[48:0]),
    .comp5_addr_reg_o               (comp5_addr_reg[48:0]),
    .comp6_addr_reg_o               (comp6_addr_reg[48:0]),
    .comp7_addr_reg_o               (comp7_addr_reg[48:0]),
    .comp0_exlevel_s_reg_o          (comp0_exlevel_s_reg[2:0]),
    .comp0_exlevel_ns_reg_o         (comp0_exlevel_ns_reg[2:0]),
    .comp0_context_reg_o            (comp0_context_reg[1:0]),
    .comp1_exlevel_s_reg_o          (comp1_exlevel_s_reg[2:0]),
    .comp1_exlevel_ns_reg_o         (comp1_exlevel_ns_reg[2:0]),
    .comp1_context_reg_o            (comp1_context_reg[1:0]),
    .comp2_exlevel_s_reg_o          (comp2_exlevel_s_reg[2:0]),
    .comp2_exlevel_ns_reg_o         (comp2_exlevel_ns_reg[2:0]),
    .comp2_context_reg_o            (comp2_context_reg[1:0]),
    .comp3_exlevel_s_reg_o          (comp3_exlevel_s_reg[2:0]),
    .comp3_exlevel_ns_reg_o         (comp3_exlevel_ns_reg[2:0]),
    .comp3_context_reg_o            (comp3_context_reg[1:0]),
    .comp4_exlevel_s_reg_o          (comp4_exlevel_s_reg[2:0]),
    .comp4_exlevel_ns_reg_o         (comp4_exlevel_ns_reg[2:0]),
    .comp4_context_reg_o            (comp4_context_reg[1:0]),
    .comp5_exlevel_s_reg_o          (comp5_exlevel_s_reg[2:0]),
    .comp5_exlevel_ns_reg_o         (comp5_exlevel_ns_reg[2:0]),
    .comp5_context_reg_o            (comp5_context_reg[1:0]),
    .comp6_exlevel_s_reg_o          (comp6_exlevel_s_reg[2:0]),
    .comp6_exlevel_ns_reg_o         (comp6_exlevel_ns_reg[2:0]),
    .comp6_context_reg_o            (comp6_context_reg[1:0]),
    .comp7_exlevel_s_reg_o          (comp7_exlevel_s_reg[2:0]),
    .comp7_exlevel_ns_reg_o         (comp7_exlevel_ns_reg[2:0]),
    .comp7_context_reg_o            (comp7_context_reg[1:0]),
    .cid_comp_value_reg_o           (cid_comp_value_reg[31:0]),
    .cid_comp_mask_reg_o            (cid_comp_mask_reg[3:0]),
    .vmid_comp_value_reg_o          (vmid_comp_value_reg[7:0]),
    .counter0_reload_reg_o          (counter0_reload_reg[15:0]),
    .counter1_reload_reg_o          (counter1_reload_reg[15:0]),
    .counter0_cntevent_reg_o        (counter0_cntevent_reg[4:0]),
    .counter1_cntevent_reg_o        (counter1_cntevent_reg[4:0]),
    .counter0_rldself_reg_o         (counter0_rldself_reg),
    .counter1_rldself_reg_o         (counter1_rldself_reg),
    .counter1_cntchain_reg_o        (counter1_cntchain_reg),
    .counter0_rldevent_reg_o        (counter0_rldevent_reg[4:0]),
    .counter1_rldevent_reg_o        (counter1_rldevent_reg[4:0]),
    .counter0_write_o               (counter0_write),
    .counter1_write_o               (counter1_write),
    .counter0_control_write_o       (counter0_control_write),
    .counter1_control_write_o       (counter1_control_write),
    .seq_transition_b0_reg_o        (seq_transition_b0_reg[4:0]),
    .seq_transition_f0_reg_o        (seq_transition_f0_reg[4:0]),
    .seq_transition_b1_reg_o        (seq_transition_b1_reg[4:0]),
    .seq_transition_f1_reg_o        (seq_transition_f1_reg[4:0]),
    .seq_transition_b2_reg_o        (seq_transition_b2_reg[4:0]),
    .seq_transition_f2_reg_o        (seq_transition_f2_reg[4:0]),
    .seq_rst_reg_o                  (seq_rst_reg[4:0]),
    .seq_write_o                    (seq_write),
    .ssc_rst_reg_o                  (ssc_rst_reg),
    .ssc_arc_reg_o                  (ssc_arc_reg[3:0]),
    .ssc_sac_reg_o                  (ssc_sac_reg[7:0]),
    .ssc_write_o                    (ssc_write),
    .event0_sel_reg_o               (event0_sel_reg[4:0]),
    .event1_sel_reg_o               (event1_sel_reg[4:0]),
    .event2_sel_reg_o               (event2_sel_reg[4:0]),
    .event3_sel_reg_o               (event3_sel_reg[4:0]),
    .extin_sel0_reg_o               (extin_sel0_reg[4:0]),
    .extin_sel1_reg_o               (extin_sel1_reg[4:0]),
    .extin_sel2_reg_o               (extin_sel2_reg[4:0]),
    .extin_sel3_reg_o               (extin_sel3_reg[4:0]),
    .trcrsctlr2_select_reg_o        (trcrsctlr2_select_reg[7:0]),
    .trcrsctlr2_group_reg_o         (trcrsctlr2_group_reg[2:0]),
    .trcrsctlr2_inv_reg_o           (trcrsctlr2_inv_reg),
    .trcrsctlr2_pairinv_reg_o       (trcrsctlr2_pairinv_reg),
    .trcrsctlr3_select_reg_o        (trcrsctlr3_select_reg[7:0]),
    .trcrsctlr3_group_reg_o         (trcrsctlr3_group_reg[2:0]),
    .trcrsctlr3_inv_reg_o           (trcrsctlr3_inv_reg),
    .trcrsctlr4_select_reg_o        (trcrsctlr4_select_reg[7:0]),
    .trcrsctlr4_group_reg_o         (trcrsctlr4_group_reg[2:0]),
    .trcrsctlr4_inv_reg_o           (trcrsctlr4_inv_reg),
    .trcrsctlr4_pairinv_reg_o       (trcrsctlr4_pairinv_reg),
    .trcrsctlr5_select_reg_o        (trcrsctlr5_select_reg[7:0]),
    .trcrsctlr5_group_reg_o         (trcrsctlr5_group_reg[2:0]),
    .trcrsctlr5_inv_reg_o           (trcrsctlr5_inv_reg),
    .trcrsctlr6_select_reg_o        (trcrsctlr6_select_reg[7:0]),
    .trcrsctlr6_group_reg_o         (trcrsctlr6_group_reg[2:0]),
    .trcrsctlr6_inv_reg_o           (trcrsctlr6_inv_reg),
    .trcrsctlr6_pairinv_reg_o       (trcrsctlr6_pairinv_reg),
    .trcrsctlr7_select_reg_o        (trcrsctlr7_select_reg[7:0]),
    .trcrsctlr7_group_reg_o         (trcrsctlr7_group_reg[2:0]),
    .trcrsctlr7_inv_reg_o           (trcrsctlr7_inv_reg),
    .trcrsctlr8_select_reg_o        (trcrsctlr8_select_reg[7:0]),
    .trcrsctlr8_group_reg_o         (trcrsctlr8_group_reg[2:0]),
    .trcrsctlr8_inv_reg_o           (trcrsctlr8_inv_reg),
    .trcrsctlr8_pairinv_reg_o       (trcrsctlr8_pairinv_reg),
    .trcrsctlr9_select_reg_o        (trcrsctlr9_select_reg[7:0]),
    .trcrsctlr9_group_reg_o         (trcrsctlr9_group_reg[2:0]),
    .trcrsctlr9_inv_reg_o           (trcrsctlr9_inv_reg),
    .trcrsctlr10_select_reg_o       (trcrsctlr10_select_reg[7:0]),
    .trcrsctlr10_group_reg_o        (trcrsctlr10_group_reg[2:0]),
    .trcrsctlr10_inv_reg_o          (trcrsctlr10_inv_reg),
    .trcrsctlr10_pairinv_reg_o      (trcrsctlr10_pairinv_reg),
    .trcrsctlr11_select_reg_o       (trcrsctlr11_select_reg[7:0]),
    .trcrsctlr11_group_reg_o        (trcrsctlr11_group_reg[2:0]),
    .trcrsctlr11_inv_reg_o          (trcrsctlr11_inv_reg),
    .trcrsctlr12_select_reg_o       (trcrsctlr12_select_reg[7:0]),
    .trcrsctlr12_group_reg_o        (trcrsctlr12_group_reg[2:0]),
    .trcrsctlr12_inv_reg_o          (trcrsctlr12_inv_reg),
    .trcrsctlr12_pairinv_reg_o      (trcrsctlr12_pairinv_reg),
    .trcrsctlr13_select_reg_o       (trcrsctlr13_select_reg[7:0]),
    .trcrsctlr13_group_reg_o        (trcrsctlr13_group_reg[2:0]),
    .trcrsctlr13_inv_reg_o          (trcrsctlr13_inv_reg),
    .trcrsctlr14_select_reg_o       (trcrsctlr14_select_reg[7:0]),
    .trcrsctlr14_group_reg_o        (trcrsctlr14_group_reg[2:0]),
    .trcrsctlr14_inv_reg_o          (trcrsctlr14_inv_reg),
    .trcrsctlr14_pairinv_reg_o      (trcrsctlr14_pairinv_reg),
    .trcrsctlr15_select_reg_o       (trcrsctlr15_select_reg[7:0]),
    .trcrsctlr15_group_reg_o        (trcrsctlr15_group_reg[2:0]),
    .trcrsctlr15_inv_reg_o          (trcrsctlr15_inv_reg),
    .auxctlr_frc_afready_reg_o      (auxctlr_frc_afready_reg),
    .auxctlr_frc_ovflow_reg_o       (auxctlr_frc_ovflow_reg),
    .auxctlr_frc_ts_nodelay_reg_o   (auxctlr_frc_ts_nodelay_reg),
    .auxctlr_frc_sync_delay_reg_o   (auxctlr_frc_sync_delay_reg),
    .auxctlr_frc_idleack_reg_o      (auxctlr_frc_idleack_reg),
    .auxctlr_frc_auth_noflush_reg_o (auxctlr_frc_auth_noflush_reg)
  );  // u_apb

        ca53etm_cmp u_cmp(
        /*ARMAUTO*/
          // Inputs
          .clk_gated              (clk_gated),
          .po_reset_n             (po_reset_n),
          .wpt_valid_t1_i         (wpt_valid_t1),
          .wpt_valid_t2_i         (wpt_valid_t2),
          .wpt_adv_t1_i           (wpt_adv_t1),
          .wpt_range_t1_i         (wpt_range_t1),
          .wpt_type_t1_i          (wpt_type_t1[2:0]),
          .wpt_addr_t1_i          (wpt_addr_t1[63:1]),
          .wpt_target_pc_t2_i     (wpt_target_pc_t2[63:1]),
          .wpt_context_id_t2_i    (wpt_context_id_t2[31:0]),
          .wpt_vmid_t2_i          (wpt_vmid_t2[7:0]),
          .wpt_aarch64_t2_i       (wpt_aarch64_t2),
          .wpt_non_secure_t2_i    (wpt_non_secure_t2),
          .wpt_exlevel_t2_i       (wpt_exlevel_t2[3:0]),
          .wpt_prohibited_t2_i    (wpt_prohibited_t2),
          .wfx_resource_t3_i      (wfx_resource_t3),
          .resource_active_t2_i   (resource_active_t2),
          .comp0_addr_reg_i       (comp0_addr_reg[48:0]),
          .comp0_exlevel_s_reg_i  (comp0_exlevel_s_reg[2:0]),
          .comp0_exlevel_ns_reg_i (comp0_exlevel_ns_reg[2:0]),
          .comp0_context_reg_i    (comp0_context_reg[1:0]),
          .comp1_addr_reg_i       (comp1_addr_reg[48:0]),
          .comp1_exlevel_s_reg_i  (comp1_exlevel_s_reg[2:0]),
          .comp1_exlevel_ns_reg_i (comp1_exlevel_ns_reg[2:0]),
          .comp1_context_reg_i    (comp1_context_reg[1:0]),
          .comp2_addr_reg_i       (comp2_addr_reg[48:0]),
          .comp2_exlevel_s_reg_i  (comp2_exlevel_s_reg[2:0]),
          .comp2_exlevel_ns_reg_i (comp2_exlevel_ns_reg[2:0]),
          .comp2_context_reg_i    (comp2_context_reg[1:0]),
          .comp3_addr_reg_i       (comp3_addr_reg[48:0]),
          .comp3_exlevel_s_reg_i  (comp3_exlevel_s_reg[2:0]),
          .comp3_exlevel_ns_reg_i (comp3_exlevel_ns_reg[2:0]),
          .comp3_context_reg_i    (comp3_context_reg[1:0]),
          .comp4_addr_reg_i       (comp4_addr_reg[48:0]),
          .comp4_exlevel_s_reg_i  (comp4_exlevel_s_reg[2:0]),
          .comp4_exlevel_ns_reg_i (comp4_exlevel_ns_reg[2:0]),
          .comp4_context_reg_i    (comp4_context_reg[1:0]),
          .comp5_addr_reg_i       (comp5_addr_reg[48:0]),
          .comp5_exlevel_s_reg_i  (comp5_exlevel_s_reg[2:0]),
          .comp5_exlevel_ns_reg_i (comp5_exlevel_ns_reg[2:0]),
          .comp5_context_reg_i    (comp5_context_reg[1:0]),
          .comp6_addr_reg_i       (comp6_addr_reg[48:0]),
          .comp6_exlevel_s_reg_i  (comp6_exlevel_s_reg[2:0]),
          .comp6_exlevel_ns_reg_i (comp6_exlevel_ns_reg[2:0]),
          .comp6_context_reg_i    (comp6_context_reg[1:0]),
          .comp7_addr_reg_i       (comp7_addr_reg[48:0]),
          .comp7_exlevel_s_reg_i  (comp7_exlevel_s_reg[2:0]),
          .comp7_exlevel_ns_reg_i (comp7_exlevel_ns_reg[2:0]),
          .comp7_context_reg_i    (comp7_context_reg[1:0]),
          .cid_comp_value_reg_i   (cid_comp_value_reg[31:0]),
          .cid_comp_mask_reg_i    (cid_comp_mask_reg[3:0]),
          .vmid_comp_value_reg_i  (vmid_comp_value_reg[7:0]),
          .ssc_rst_reg_i          (ssc_rst_reg),
          .ssc_arc_reg_i          (ssc_arc_reg[3:0]),
          .ssc_sac_reg_i          (ssc_sac_reg[7:0]),
          .ssc_write_i            (ssc_write),
          .apb_pwdatadbg_31_i     (apb_pwdatadbg_31),
          // Outputs
          .comp0_match_t2_o       (comp0_match_t2),
          .comp1_match_t2_o       (comp1_match_t2),
          .comp2_match_t2_o       (comp2_match_t2),
          .comp3_match_t2_o       (comp3_match_t2),
          .comp4_match_t2_o       (comp4_match_t2),
          .comp5_match_t2_o       (comp5_match_t2),
          .comp6_match_t2_o       (comp6_match_t2),
          .comp7_match_t2_o       (comp7_match_t2),
          .range0_match_t2_o      (range0_match_t2),
          .range1_match_t2_o      (range1_match_t2),
          .range2_match_t2_o      (range2_match_t2),
          .range3_match_t2_o      (range3_match_t2),
          .range0_excl_t2_o       (range0_excl_t2),
          .range1_excl_t2_o       (range1_excl_t2),
          .range2_excl_t2_o       (range2_excl_t2),
          .range3_excl_t2_o       (range3_excl_t2),
          .cid_match_t2_o         (cid_match_t2),
          .vmid_match_t2_o        (vmid_match_t2),
          .ssc_status_t2_o        (ssc_status_t2),
          .ssc_resource_t2_o      (ssc_resource_t2)
        );  // u_cmp

        ca53etm_viewinst u_viewinst(
        /*ARMAUTO*/
        // TEMPLATE s/^apb_pwdatadbg_([0-9]+)to([0-9])$/apb_pwdatadbg_16to0[${1}:${2}]/
        // TEMPLATE s/^apb_pwdatadbg_([0-9]+)$/apb_pwdatadbg_16to0[${1}]/
          // Inputs
          .clk_gated                      (clk_gated),
          .po_reset_n                     (po_reset_n),
          .viewinst_write_i               (viewinst_write),
          .viewinst_event_reg_i           (viewinst_event_reg[4:0]),
          .viewinst_exlevel_ns_reg_i      (viewinst_exlevel_ns_reg[2:0]),
          .viewinst_exlevel_s_reg_i       (viewinst_exlevel_s_reg[2:0]),
          .viewinst_inc_ranges_reg_i      (viewinst_inc_ranges_reg[3:0]),
          .viewinst_exc_ranges_reg_i      (viewinst_exc_ranges_reg[3:0]),
          .viewinst_stop_cmp_reg_i        (viewinst_stop_cmp_reg[7:0]),
          .viewinst_start_cmp_reg_i       (viewinst_start_cmp_reg[7:0]),
          .apb_pwdatadbg_9_i              (apb_pwdatadbg_16to0[9]),
          .bb_mode_reg_i                  (bb_mode_reg),
          .bb_range_reg_i                 (bb_range_reg[3:0]),
          .evt_resources_t2_i             (evt_resources_t2[22:2]),
          .comp0_match_t2_i               (comp0_match_t2),
          .comp1_match_t2_i               (comp1_match_t2),
          .comp2_match_t2_i               (comp2_match_t2),
          .comp3_match_t2_i               (comp3_match_t2),
          .comp4_match_t2_i               (comp4_match_t2),
          .comp5_match_t2_i               (comp5_match_t2),
          .comp6_match_t2_i               (comp6_match_t2),
          .comp7_match_t2_i               (comp7_match_t2),
          .range0_match_t2_i              (range0_match_t2),
          .range1_match_t2_i              (range1_match_t2),
          .range2_match_t2_i              (range2_match_t2),
          .range3_match_t2_i              (range3_match_t2),
          .range0_excl_t2_i               (range0_excl_t2),
          .range1_excl_t2_i               (range1_excl_t2),
          .range2_excl_t2_i               (range2_excl_t2),
          .range3_excl_t2_i               (range3_excl_t2),
          .wpt_valid_t1_i                 (wpt_valid_t1),
          .wpt_valid_t2_i                 (wpt_valid_t2),
          .wpt_adv_t2_i                   (wpt_adv_t2),
          .wpt_exlevel_t2_i               (wpt_exlevel_t2[3:0]),
          .wpt_non_secure_t2_i            (wpt_non_secure_t2),
          .wpt_dbg_entry_t2_i             (wpt_dbg_entry_t2),
          .wpt_dbg_exit_t2_i              (wpt_dbg_exit_t2),
          .wpt_prohibited_t2_i            (wpt_prohibited_t2),
          .trace_enable_reg_i             (trace_enable_reg),
          .etm_oslock_i                   (etm_oslock),
          .gov_dbgen_i                    (gov_dbgen_i),
          .gov_niden_i                    (gov_niden_i),
          .auxctlr_frc_idleack_reg_i      (auxctlr_frc_idleack_reg),
          .auxctlr_frc_auth_noflush_reg_i (auxctlr_frc_auth_noflush_reg),
          .gov_wfx_drain_req_t2_i         (gov_wfx_drain_req_t2),
          .trcgen_idle_ack_i              (trcgen_idle_ack),
          .lp_override_reg_i              (lp_override_reg),
          .trace_overflow_i               (trace_overflow),
          .fifo_idle_ack_i                (fifo_idle_ack),
          .at_idle_ack_i                  (at_idle_ack),
          .at_active_state_i              (at_active_state),
          // Outputs
          .viewinst_en_t2_o               (viewinst_en_t2),
          .viewinst_sstatus_o             (viewinst_sstatus),
          .trace_active_1st_wpt_t4_o      (trace_active_1st_wpt_t4),
          .bb_en_t2_o                     (bb_en_t2),
          .viewinst_idle_req_t2_o         (viewinst_idle_req_t2),
          .resource_active_t2_o           (resource_active_t2),
          .trace_req_t0_o                 (trace_req_t0),
          .wfx_resource_t3_o              (wfx_resource_t3),
          .fifo_idle_req_t2_o             (fifo_idle_req_t2),
          .core_at_main_run_t2_o          (core_at_main_run_t2),
          .trcstatr_idle_o                (trcstatr_idle),
          .etm_wfx_ready_o                (etm_wfx_ready)
        );  // u_viewinst

        ca53etm_resources u_resources(
        /*ARMAUTO*/
          // Inputs
          .clk_gated                 (clk_gated),
          .po_reset_n                (po_reset_n),
          .resource_active_t2_i      (resource_active_t2),
          .extin_rsrc_t2_i           (extin_rsrc_t2[3:0]),
          .counter0_zero_t3_i        (counter0_zero_t3),
          .counter1_zero_t3_i        (counter1_zero_t3),
          .seq_resource_t2_i         (seq_resource_t2[3:0]),
          .ssc_resource_t2_i         (ssc_resource_t2),
          .comp0_match_t2_i          (comp0_match_t2),
          .comp1_match_t2_i          (comp1_match_t2),
          .comp2_match_t2_i          (comp2_match_t2),
          .comp3_match_t2_i          (comp3_match_t2),
          .comp4_match_t2_i          (comp4_match_t2),
          .comp5_match_t2_i          (comp5_match_t2),
          .comp6_match_t2_i          (comp6_match_t2),
          .comp7_match_t2_i          (comp7_match_t2),
          .range0_match_t2_i         (range0_match_t2),
          .range1_match_t2_i         (range1_match_t2),
          .range2_match_t2_i         (range2_match_t2),
          .range3_match_t2_i         (range3_match_t2),
          .cid_match_t2_i            (cid_match_t2),
          .vmid_match_t2_i           (vmid_match_t2),
          .trcrsctlr2_select_reg_i   (trcrsctlr2_select_reg[7:0]),
          .trcrsctlr2_group_reg_i    (trcrsctlr2_group_reg[2:0]),
          .trcrsctlr2_inv_reg_i      (trcrsctlr2_inv_reg),
          .trcrsctlr2_pairinv_reg_i  (trcrsctlr2_pairinv_reg),
          .trcrsctlr3_select_reg_i   (trcrsctlr3_select_reg[7:0]),
          .trcrsctlr3_group_reg_i    (trcrsctlr3_group_reg[2:0]),
          .trcrsctlr3_inv_reg_i      (trcrsctlr3_inv_reg),
          .trcrsctlr4_select_reg_i   (trcrsctlr4_select_reg[7:0]),
          .trcrsctlr4_group_reg_i    (trcrsctlr4_group_reg[2:0]),
          .trcrsctlr4_inv_reg_i      (trcrsctlr4_inv_reg),
          .trcrsctlr4_pairinv_reg_i  (trcrsctlr4_pairinv_reg),
          .trcrsctlr5_select_reg_i   (trcrsctlr5_select_reg[7:0]),
          .trcrsctlr5_group_reg_i    (trcrsctlr5_group_reg[2:0]),
          .trcrsctlr5_inv_reg_i      (trcrsctlr5_inv_reg),
          .trcrsctlr6_select_reg_i   (trcrsctlr6_select_reg[7:0]),
          .trcrsctlr6_group_reg_i    (trcrsctlr6_group_reg[2:0]),
          .trcrsctlr6_inv_reg_i      (trcrsctlr6_inv_reg),
          .trcrsctlr6_pairinv_reg_i  (trcrsctlr6_pairinv_reg),
          .trcrsctlr7_select_reg_i   (trcrsctlr7_select_reg[7:0]),
          .trcrsctlr7_group_reg_i    (trcrsctlr7_group_reg[2:0]),
          .trcrsctlr7_inv_reg_i      (trcrsctlr7_inv_reg),
          .trcrsctlr8_select_reg_i   (trcrsctlr8_select_reg[7:0]),
          .trcrsctlr8_group_reg_i    (trcrsctlr8_group_reg[2:0]),
          .trcrsctlr8_inv_reg_i      (trcrsctlr8_inv_reg),
          .trcrsctlr8_pairinv_reg_i  (trcrsctlr8_pairinv_reg),
          .trcrsctlr9_select_reg_i   (trcrsctlr9_select_reg[7:0]),
          .trcrsctlr9_group_reg_i    (trcrsctlr9_group_reg[2:0]),
          .trcrsctlr9_inv_reg_i      (trcrsctlr9_inv_reg),
          .trcrsctlr10_select_reg_i  (trcrsctlr10_select_reg[7:0]),
          .trcrsctlr10_group_reg_i   (trcrsctlr10_group_reg[2:0]),
          .trcrsctlr10_inv_reg_i     (trcrsctlr10_inv_reg),
          .trcrsctlr10_pairinv_reg_i (trcrsctlr10_pairinv_reg),
          .trcrsctlr11_select_reg_i  (trcrsctlr11_select_reg[7:0]),
          .trcrsctlr11_group_reg_i   (trcrsctlr11_group_reg[2:0]),
          .trcrsctlr11_inv_reg_i     (trcrsctlr11_inv_reg),
          .trcrsctlr12_select_reg_i  (trcrsctlr12_select_reg[7:0]),
          .trcrsctlr12_group_reg_i   (trcrsctlr12_group_reg[2:0]),
          .trcrsctlr12_inv_reg_i     (trcrsctlr12_inv_reg),
          .trcrsctlr12_pairinv_reg_i (trcrsctlr12_pairinv_reg),
          .trcrsctlr13_select_reg_i  (trcrsctlr13_select_reg[7:0]),
          .trcrsctlr13_group_reg_i   (trcrsctlr13_group_reg[2:0]),
          .trcrsctlr13_inv_reg_i     (trcrsctlr13_inv_reg),
          .trcrsctlr14_select_reg_i  (trcrsctlr14_select_reg[7:0]),
          .trcrsctlr14_group_reg_i   (trcrsctlr14_group_reg[2:0]),
          .trcrsctlr14_inv_reg_i     (trcrsctlr14_inv_reg),
          .trcrsctlr14_pairinv_reg_i (trcrsctlr14_pairinv_reg),
          .trcrsctlr15_select_reg_i  (trcrsctlr15_select_reg[7:0]),
          .trcrsctlr15_group_reg_i   (trcrsctlr15_group_reg[2:0]),
          .trcrsctlr15_inv_reg_i     (trcrsctlr15_inv_reg),
          // Outputs
          .resource_active_t3_o      (resource_active_t3),
          .resource_active_t4_o      (resource_active_t4),
          .resource_active_t5_o      (resource_active_t5),
          .evt_resources_t2_o        (evt_resources_t2[22:2])
        );  // u_resources

        ca53etm_derived_res u_derived_res(
        /*ARMAUTO*/
          // Inputs
          .clk_gated                (clk_gated),
          .po_reset_n               (po_reset_n),
          .resource_active_t2_i     (resource_active_t2),
          .resource_active_t3_i     (resource_active_t3),
          .resource_active_t4_i     (resource_active_t4),
          .resource_active_t5_i     (resource_active_t5),
          .trace_req_t0_i           (trace_req_t0),
          .apb_pwdatadbg_16to0_i    (apb_pwdatadbg_16to0[16:0]),
          .evt_resources_t2_i       (evt_resources_t2[22:2]),
          .counter0_reload_reg_i    (counter0_reload_reg[15:0]),
          .counter1_reload_reg_i    (counter1_reload_reg[15:0]),
          .counter0_cntevent_reg_i  (counter0_cntevent_reg[4:0]),
          .counter1_cntevent_reg_i  (counter1_cntevent_reg[4:0]),
          .counter0_rldself_reg_i   (counter0_rldself_reg),
          .counter1_rldself_reg_i   (counter1_rldself_reg),
          .counter1_cntchain_reg_i  (counter1_cntchain_reg),
          .counter0_rldevent_reg_i  (counter0_rldevent_reg[4:0]),
          .counter1_rldevent_reg_i  (counter1_rldevent_reg[4:0]),
          .counter0_write_i         (counter0_write),
          .counter1_write_i         (counter1_write),
          .counter0_control_write_i (counter0_control_write),
          .counter1_control_write_i (counter1_control_write),
          .seq_transition_b0_reg_i  (seq_transition_b0_reg[4:0]),
          .seq_transition_f0_reg_i  (seq_transition_f0_reg[4:0]),
          .seq_transition_b1_reg_i  (seq_transition_b1_reg[4:0]),
          .seq_transition_f1_reg_i  (seq_transition_f1_reg[4:0]),
          .seq_transition_b2_reg_i  (seq_transition_b2_reg[4:0]),
          .seq_transition_f2_reg_i  (seq_transition_f2_reg[4:0]),
          .seq_rst_reg_i            (seq_rst_reg[4:0]),
          .seq_write_i              (seq_write),
          .event0_sel_reg_i         (event0_sel_reg[4:0]),
          .event1_sel_reg_i         (event1_sel_reg[4:0]),
          .event2_sel_reg_i         (event2_sel_reg[4:0]),
          .event3_sel_reg_i         (event3_sel_reg[4:0]),
          .gov_extin_i              (gov_extin_i[3:0]),
          .dpu_pmuevent_i           (dpu_pmuevent_i[25:0]),
          .extin_sel0_reg_i         (extin_sel0_reg[4:0]),
          .extin_sel1_reg_i         (extin_sel1_reg[4:0]),
          .extin_sel2_reg_i         (extin_sel2_reg[4:0]),
          .extin_sel3_reg_i         (extin_sel3_reg[4:0]),
          .ts_event_reg_i           (ts_event_reg[4:0]),
          // Outputs
          .trcstatr_pmstable_o      (trcstatr_pmstable),
          .counter0_value_o         (counter0_value[15:0]),
          .counter1_value_o         (counter1_value[15:0]),
          .counter0_zero_t3_o       (counter0_zero_t3),
          .counter1_zero_t3_o       (counter1_zero_t3),
          .seq_state_t2_o           (seq_state_t2[1:0]),
          .seq_resource_t2_o        (seq_resource_t2[3:0]),
          .etm_extout_o             (etm_extout[3:0]),
          .extin_rsrc_t2_o          (extin_rsrc_t2[3:0]),
          .ts_event_t2_o            (ts_event_t2)
        );  // u_derived_res

        ca53etm_trace_gen u_trace_gen(
        /*ARMAUTO*/
          // Inputs
          .clk_gated                    (clk_gated),
          .po_reset_n                   (po_reset_n),
          .etm_os_lock_trace_i          (etm_os_lock_trace),
          .gov_wfx_drain_req_i          (gov_wfx_drain_req_i),
          .viewinst_en_t2_i             (viewinst_en_t2),
          .trace_active_1st_wpt_t4_i    (trace_active_1st_wpt_t4),
          .sync_req_t2_i                (sync_req_t2),
          .gov_tsvalueb_i               (gov_tsvalueb_i[63:0]),
          .ts_event_t2_i                (ts_event_t2),
          .dpu_wpt_valid_i              (dpu_wpt_valid_i),
          .dpu_wpt_addr_i               (dpu_wpt_addr_i[63:1]),
          .dpu_wpt_target_addr_opa_i    (dpu_wpt_target_addr_opa_i[63:1]),
          .dpu_wpt_target_addr_opb_i    (dpu_wpt_target_addr_opb_i[27:1]),
          .tlb_context_id_i             (tlb_context_id_i[31:0]),
          .tlb_vmid_i                   (tlb_vmid_i[7:0]),
          .tlb_d_tcr_el1_tbi_i          (tlb_d_tcr_el1_tbi_i[1:0]),
          .tlb_d_tcr_el2_tbi0_i         (tlb_d_tcr_el2_tbi0_i),
          .tlb_d_tcr_el3_tbi0_i         (tlb_d_tcr_el3_tbi0_i),
          .dpu_wpt_type_i               (dpu_wpt_type_i[2:0]),
          .dpu_wpt_link_i               (dpu_wpt_link_i),
          .dpu_wpt_taken_i              (dpu_wpt_taken_i),
          .dpu_wpt_target_isa_i         (dpu_wpt_target_isa_i[1:0]),
          .dpu_wpt_t32_nt16_i           (dpu_wpt_t32_nt16_i),
          .dpu_wpt_exception_type_i     (dpu_wpt_exception_type_i[3:0]),
          .dpu_wpt_non_secure_i         (dpu_wpt_non_secure_i),
          .dpu_wpt_exlevel_i            (dpu_wpt_exlevel_i[3:0]),
          .dpu_wpt_prohibited_i         (dpu_wpt_prohibited_i),
          .dpu_wpt_advance_i            (dpu_wpt_advance_i),
          .dpu_wpt_range_i              (dpu_wpt_range_i),
          .return_stack_en_reg_i        (return_stack_en_reg),
          .timestamp_en_reg_i           (timestamp_en_reg),
          .cycle_counting_reg_i         (cycle_counting_reg),
          .cc_threshold_reg_i           (cc_threshold_reg[11:0]),
          .context_id_reg_i             (context_id_reg),
          .vmid_reg_i                   (vmid_reg),
          .branch_broadcast_reg_i       (branch_broadcast_reg),
          .bb_en_t2_i                   (bb_en_t2),
          .sync_period_reg_i            (sync_period_reg[4:0]),
          .auxctlr_frc_ovflow_reg_i     (auxctlr_frc_ovflow_reg),
          .viewinst_idle_req_t2_i       (viewinst_idle_req_t2),
          .trace_req_t0_i               (trace_req_t0),
          .core_at_main_run_t2_i        (core_at_main_run_t2),
          .wfx_resource_t3_i            (wfx_resource_t3),
          .fifo_overflow_i              (fifo_overflow),
          .fifo_empty_i                 (fifo_empty),
          .fifo_8bytes_t6_i             (fifo_8bytes_t6),
          .fifo_level28_t7_i            (fifo_level28_t7),
          .fifo_flush_req_i             (fifo_flush_req),
          .etm_extout_i                 (etm_extout[3:0]),
          .event_enable_reg_i           (event_enable_reg[3:0]),
          .event_atbtrig_en_reg_i       (event_atbtrig_en_reg),
          .lp_override_reg_i            (lp_override_reg),
          .auxctlr_frc_sync_delay_reg_i (auxctlr_frc_sync_delay_reg),
          .auxctlr_frc_ts_nodelay_reg_i (auxctlr_frc_ts_nodelay_reg),
          .viewinst_trcerr_reg_i        (viewinst_trcerr_reg),
          .viewinst_trcreset_reg_i      (viewinst_trcreset_reg),
          // Outputs
          .wpt_valid_t1_o               (wpt_valid_t1),
          .wpt_valid_t2_o               (wpt_valid_t2),
          .wpt_adv_t1_o                 (wpt_adv_t1),
          .wpt_adv_t2_o                 (wpt_adv_t2),
          .wpt_range_t1_o               (wpt_range_t1),
          .wpt_type_t1_o                (wpt_type_t1[2:0]),
          .wpt_addr_t1_o                (wpt_addr_t1[63:1]),
          .wpt_target_pc_t2_o           (wpt_target_pc_t2[63:1]),
          .wpt_context_id_t2_o          (wpt_context_id_t2[31:0]),
          .wpt_vmid_t2_o                (wpt_vmid_t2[7:0]),
          .wpt_aarch64_t2_o             (wpt_aarch64_t2),
          .wpt_non_secure_t2_o          (wpt_non_secure_t2),
          .wpt_exlevel_t2_o             (wpt_exlevel_t2[3:0]),
          .wpt_prohibited_t2_o          (wpt_prohibited_t2),
          .wpt_dbg_entry_t2_o           (wpt_dbg_entry_t2),
          .wpt_dbg_exit_t2_o            (wpt_dbg_exit_t2),
          .async_req_t4_o               (async_req_t4),
          .ovfl_req_t2_o                (ovfl_req_t2),
          .traced_event_t3_o            (traced_event_t3[3:0]),
          .event_trigger_req_t3_o       (event_trigger_req_t3),
          .ts_output_en_pend_t3_o       (ts_output_en_pend_t3),
          .gov_wfx_drain_req_t2_o       (gov_wfx_drain_req_t2),
          .trcgen_idle_ack_o            (trcgen_idle_ack),
          .low_power_override_flush_o   (low_power_override_flush),
          .trace_overflow_o             (trace_overflow),
          .num_bytes_t5_o               (num_bytes_t5[4:0]),
          .pack_fifo_in_t5_o            (pack_fifo_in_t5[203:0]),
          .num_first8_t5_o              (num_first8_t5[2:0])
        );  // u_trace_gen


        ca53etm_fifo u_fifo(
        /*ARMAUTO*/
          // Inputs
          .clk_gated              (clk_gated),
          .po_reset_n             (po_reset_n),
          .pack_fifo_in_t5_i      (pack_fifo_in_t5[203:0]),
          .num_bytes_t5_i         (num_bytes_t5[4:0]),
          .num_first8_t5_i        (num_first8_t5[2:0]),
          .ts_output_en_pend_t3_i (ts_output_en_pend_t3),
          .ovfl_req_t2_i          (ovfl_req_t2),
          .async_req_t4_i         (async_req_t4),
          .fifo_idle_req_t2_i     (fifo_idle_req_t2),
          .traced_event_t3_i      (traced_event_t3[3:0]),
          .fifo_ready_i           (fifo_ready),
          .fifo_flush_req_i       (fifo_flush_req),
          .istall_reg_i           (istall_reg),
          .stall_level_reg_i      (stall_level_reg[1:0]),
          // Outputs
          .etm_stall_cpu_o        (etm_stall_cpu_o),
          .fifo_overflow_o        (fifo_overflow),
          .fifo_empty_o           (fifo_empty),
          .fifo_8bytes_t6_o       (fifo_8bytes_t6),
          .fifo_level28_t7_o      (fifo_level28_t7),
          .fifo_data_o            (fifo_data[31:0]),
          .fifo_bytes_o           (fifo_bytes[1:0]),
          .fifo_valid_o           (fifo_valid),
          .fifo_flush_ack_o       (fifo_flush_ack),
          .fifo_idle_ack_o        (fifo_idle_ack)
        );  // u_fifo


  ca53etm_traceout u_traceout(
  /*ARMAUTO*/
  // TEMPLATE s/^apb_pwdatadbg_([0-9]+)to([0-9])$/apb_pwdatadbg_16to0/
  // TEMPLATE s/^apb_pwdatadbg_([0-9]+)$/apb_pwdatadbg_16to0/
    // Inputs
    .clk_gated                  (clk_gated),
    .gov_atclken_i              (gov_atclken_i),
    .po_reset_n                 (po_reset_n),
    .fifo_valid_i               (fifo_valid),
    .fifo_bytes_i               (fifo_bytes[1:0]),
    .fifo_data_i                (fifo_data[31:0]),
    .fifo_flush_ack_i           (fifo_flush_ack),
    .fifo_idle_ack_i            (fifo_idle_ack),
    .event_trigger_req_t3_i     (event_trigger_req_t3),
    .gov_atreadym_i             (gov_atreadym_i),
    .gov_afvalidm_i             (gov_afvalidm_i),
    .gov_syncreqm_i             (gov_syncreqm_i),
    .auxctlr_frc_afready_reg_i  (auxctlr_frc_afready_reg),
    .write_ir_atb_out_o         (write_ir_atb_out),
    .write_ir_atb_data_i        (write_ir_atb_data),
    .write_at_id_i              (write_at_id),
    .int_test_enable_i          (int_test_enable),
    .apb_pwdatadbg_6to0_i       (apb_pwdatadbg_16to0[6:0]),
    .apb_pwdatadbg_9to8_i       (apb_pwdatadbg_16to0[9:8]),
    .core_at_main_run_t2_i      (core_at_main_run_t2),
    .low_power_override_flush_i (low_power_override_flush),
    // Outputs
    .fifo_ready_o               (fifo_ready),
    .fifo_flush_req_o           (fifo_flush_req),
    .at_active_state_o          (at_active_state),
    .at_idle_ack_o              (at_idle_ack),
    .etm_atvalidm_o             (etm_atvalidm_o),
    .etm_atbytesm_o             (etm_atbytesm_o[1:0]),
    .etm_atdatam_o              (etm_atdatam_o[31:0]),
    .etm_afreadym_o             (etm_afreadym_o),
    .etm_atidm_o                (etm_atidm_o[6:0]),
    .etm_atidm_reg_o            (etm_atidm_reg[6:0]),
    .sync_req_t2_o              (sync_req_t2),
    .atb_reg_ack_o              (atb_reg_ack),
    .atb_afvalid_o              (atb_afvalid),
    .atb_atready_o              (atb_atready)
  );  // u_traceout
//-----------------------------------------------------------------------------
// Output Assignments
//-----------------------------------------------------------------------------
  assign etm_oslock_o    = etm_oslock;
  assign etm_if_en_o     = etm_if_en;
  assign etm_wfx_ready_o = etm_wfx_ready;
  assign etm_extout_o    = etm_extout;
//-----------------------------------------------------------------------------
// Assertions
//-----------------------------------------------------------------------------
`ifdef CA53_SVA_ON

`include "ca53etm_val_defs.v"
localparam SVA_CA53_ETM_ST_EMPTY  =2'b00;
localparam CA53_ETM_ST_FIFO_FLUSH =3'b101;


// Suppress assertions when etm is in integration mode

  wire sva_atclk_en;
  assign sva_atclk_en = u_traceout.gov_atclken_i;

  reg sva_int_test_enable_q;
  always @ (posedge clk or negedge po_reset_n)
  begin
    if  (!po_reset_n) begin
      sva_int_test_enable_q <=  1'b1;
    end
    else if (sva_atclk_en) begin
      sva_int_test_enable_q <=  int_test_enable;
    end
  end

// ETM has entered idle state
  wire sva_et_idle;
  assign sva_et_idle = (etm_wfx_ready_o & gov_wfx_drain_req_t2) |                 // WFI/WFE
                        (trcstatr_idle);                                // Trace is disabled

// no valid fifo data when progbit is in idle state
  usva_valid_fifo_bytes_idle_ack: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    ~$past(auxctlr_frc_idleack_reg) & sva_et_idle |-> (num_bytes_t5[4:0] == {5{1'b0}}))
    `SVA_FATAL("Fifo valid bytes seen when etm is in idle state");

// no fifo valid when etm is in idle state
  usva_valid_fifo_valid_idle_ack: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    ~$past(auxctlr_frc_idleack_reg) & sva_et_idle |-> ~fifo_valid)
    `SVA_FATAL("Fifo valid seen when etm is in idle state");

// ATVALIDM must not be asserted when etm is in idle state
  usva_atvalidm_not_wfx: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    (~$past(auxctlr_frc_idleack_reg) & etm_wfx_ready_o & gov_wfx_drain_req_t2) |-> ~ etm_atvalidm_o)
    `SVA_FATAL("ATVALIDM is asserted when etm is in WFX idle");

  usva_atvalidm_not_idle: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    (trcstatr_idle & ~sva_int_test_enable_q) |-> ~ etm_atvalidm_o)
    `SVA_FATAL("ATVALIDM is asserted when etm is reporting idle state");

// AFREADYM must be asserted when etm is in idle state
  usva_afreadym_idle_ack: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    (sva_et_idle & ~sva_int_test_enable_q & ~$past(auxctlr_frc_idleack_reg)) |-> etm_afreadym_o)
    `SVA_FATAL("AFREADYM is not asserted when etm is in idle state");

// Idle State machine in fifo_flush -> no new data into fifo
   usva_flush_state_no_data: assert property (@(posedge clk) disable iff (!po_reset_n)
     (~u_viewinst.idle_removed & u_viewinst.idle_state_t1 == 3'b101) |-> (num_bytes_t5 == 5'h00))
     `SVA_FATAL("Data input to fifo whilst in drain state");

// Idle State machine in idle_flush -> no fifo flush request
   usva_flush_req_idle: assert property (@(posedge clk) disable iff (!po_reset_n)
     (~u_viewinst.idle_removed & u_viewinst.idle_state_t1 == 3'b000) |-> ~fifo_flush_req)
     `SVA_FATAL("Fifo flush outstanding but ETM is idle");

//NIDEN
//when NIDEN is disabled, no trace is generated, including event packet and event timestamp
  usva_ap_etm_niden_disabled:  assert property (@(posedge clk) disable iff (!po_reset_n)
        u_viewinst.auth_notrace[*12] |=> ~|num_bytes_t5)
    `SVA_FATAL("trace generated during NIDEN is disabled");

  usva_ap_etm_niden_inactive:  assert property (@(posedge clk) disable iff (!po_reset_n)
                                     $past($rose(u_viewinst.auth_notrace),2)  |=> ~u_trace_gen.trace_active_t3 | ~$past(u_viewinst.auth_notrace))
    `SVA_FATAL("NIDEN must result in trace inactive");

// Check ATIDM does not change during a transaction
  reg           sva_atvalidm_q;
  reg           sva_atreadym_q;
  reg   [6:0]   sva_atidm_q;


  wire          sva_start_trans;
  wire          sva_end_trans;
  wire          sva_in_trans;
  reg           sva_in_trans_q;

  assign sva_start_trans = sva_atclk_en & etm_atvalidm_o & (~sva_atvalidm_q | (sva_atvalidm_q & sva_atreadym_q));

  assign sva_end_trans = sva_atclk_en & etm_atvalidm_o & gov_atreadym_i;

  assign sva_in_trans = (sva_start_trans & ~sva_end_trans) | (sva_in_trans_q & ~sva_end_trans);

  always @ (posedge clk or negedge po_reset_n)
  begin
    if  (!po_reset_n) begin
      sva_atvalidm_q    <=  1'b0;
      sva_atreadym_q    <=  1'b0;
      sva_atidm_q       <=  {7{1'b0}};
      sva_in_trans_q    <=  1'b0;
    end
    else if (sva_atclk_en) begin
      sva_atvalidm_q    <=  etm_atvalidm_o;
      sva_atreadym_q    <=  gov_atreadym_i;
      sva_atidm_q       <=  etm_atidm_o;
      sva_in_trans_q    <=  sva_in_trans;
    end
  end

  usva_atidchange: assert property (@(posedge clk) disable iff (!po_reset_n | int_test_enable)
    !(trace_enable_reg & sva_in_trans_q & |(etm_atidm_o ^ sva_atidm_q)))
    `SVA_FATAL("ATIDM changed during a transaction");


//------------------------------------------------------------------
//Check ETM ATCLK domain signals only change when atclken is valid
//------------------------------------------------------------------
// register the ETM output ATCLK signals on every clock cycle
  reg           sva_atvalidm_stable_q;
  reg           sva_afreadym_stable_q;
  reg  [31:0]   sva_atdatam_stable_q;
  reg   [1:0]   sva_atbytesm_stable_q;
  reg   [6:0]   sva_atidm_stable_q;

  always @ (posedge clk or negedge po_reset_n)
  begin
    if  (!po_reset_n) begin
      sva_atvalidm_stable_q    <=  1'b0;
      sva_afreadym_stable_q    <=  1'b1;
      sva_atdatam_stable_q     <=  {32{1'b0}};
      sva_atbytesm_stable_q    <=  {2{1'b0}};
      sva_atidm_stable_q       <=  {7{1'b0}};
    end
    else begin
      sva_atvalidm_stable_q    <=  etm_atvalidm_o;
      sva_afreadym_stable_q    <=  etm_afreadym_o;
      sva_atdatam_stable_q     <=  etm_atdatam_o;
      sva_atbytesm_stable_q    <=  etm_atbytesm_o;
      sva_atidm_stable_q       <=  etm_atidm_o;
    end
  end

  //ETM output ATCLK signas keep stable when ATCLKEN is not active
  //Use non-gated clock wherever possible for stronger and easier check
  usva_atvalim_stable_check: assert property (@(posedge clk) disable iff (!po_reset_n)
       (sva_atvalidm_stable_q != etm_atvalidm_o) |-> $past(gov_atclken_i))
    `SVA_FATAL("atvalidm_o can only change after atclken is asserted");

  usva_afreadym_stable_check: assert property (@(posedge clk) disable iff (!po_reset_n)
       (sva_afreadym_stable_q != etm_afreadym_o) |-> $past(gov_atclken_i))
    `SVA_FATAL("afreadym_o can only change after atclken is asserted");

  usva_atdatam_stable_check: assert property (@(posedge clk) disable iff (!po_reset_n)
       (sva_atdatam_stable_q != etm_atdatam_o) |-> $past(gov_atclken_i))
    `SVA_FATAL("atdatam_o can only change after atclken is asserted");

  usva_atbytesm_stable_check: assert property (@(posedge clk) disable iff (!po_reset_n)
       (sva_atbytesm_stable_q != etm_atbytesm_o) |-> $past(gov_atclken_i))
    `SVA_FATAL("atbytesm_o can only change after atclken is asserted");

  usva_atidm_stable_check: assert property (@(posedge clk) disable iff (!po_reset_n)
       (sva_atidm_stable_q != etm_atidm_o) |-> $past(gov_atclken_i))
    `SVA_FATAL("atidm_o can only change after atclken is asserted");

 // Clock enable term for ETM must be high in the following scenarios
  usva_etm_clken: assert property (@(posedge clk) disable iff (!po_reset_n)
       (|num_bytes_t5) |-> u_ca53etm_clk.clken)
    `SVA_FATAL("ETM has data in flight but no active clock");
  usva_etm_clken_trig: assert property (@(posedge clk) disable iff (!po_reset_n)
       (u_traceout.sva_trigger_requested) |-> u_ca53etm_clk.clken) 
    `SVA_FATAL("ETM has trigger in flight but no active clock");
  usva_clken_pready: assert property (@(posedge clk) disable iff (!po_reset_n)
    etm_preadydbg_o |-> u_ca53etm_clk.clken)
    `SVA_FATAL("Clock enable low but etm_preadydbg_o high");
  usva_clken_idle: assert property (@(posedge clk) disable iff (!po_reset_n)
    (u_viewinst.idle_state_t1 != 3'b000) |-> u_ca53etm_clk.clken)
    `SVA_FATAL("Clock enable low but idle state machine active");
  usva_clken_count: assert property (@(posedge clk) disable iff (!po_reset_n)
     ~u_ca53etm_clk.clken |-> u_trace_gen.trace_idle_state_t2 == 2'b00)
    `SVA_FATAL("Clock enable low but idle count active");
    
// Overflow sequence relies on fifo_idle_ack not being stuck high
// Actual limit is not critical
    reg [4:0] sva_idle_count;
  always @ (posedge clk or negedge po_reset_n)
  begin
    if  (!po_reset_n)
      sva_idle_count <= 5'b00000;
    else
      sva_idle_count <= u_fifo.fifo_idle_ack_t6 ?
                        sva_idle_count + {4'b0000,gov_atclken_i & gov_atreadym_i} :
                        5'b00000;
  end

  usva_idle_seq:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                     (sva_idle_count == 5'h9) |-> ~u_fifo.fifo_idle_req_t6)
    `SVA_FATAL("Fifo idle request sequence not as expected");

  usva_ovfl_seq:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                     ( ~ovfl_req_t2 ##1 
                                        ovfl_req_t2 ##1 
                                       ~ovfl_req_t2) |->
                                    u_fifo.ovfl_pos_t5_en)
    `SVA_FATAL("Fifo did not overflow as expected");

  usva_ovfl_run:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                     ~core_at_main_run_t2 |->
                                    &u_fifo.ovfl_pos_t6)
    `SVA_FATAL("Fifo tracking overflow, but trace is disabled");

  usva_ovfl_match:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                     ~u_trace_gen.overflow_state_t4 |->
                                           &u_fifo.ovfl_pos_t6 |
                                     $past(&u_fifo.ovfl_pos_t6)|
                                     $past(&u_fifo.ovfl_pos_t6,2))
    `SVA_FATAL("Fifo tracking overflow, but trace trace_gen has no overflow");

  usva_ovfl_sync:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                     ~&u_fifo.ovfl_pos_t6 |-> 
                                     ~async_req_t4[*2])
    `SVA_FATAL("Fifo tracking overflow, and async requested");

    // Idle counter must not be stuck at non-zero values
  usva_idle_counter_state:  assert property (@(posedge clk) disable iff (!po_reset_n)
                                       trcstatr_idle |-> 
                                       ~|u_trace_gen.trace_idle_state_cnt_t3)
    `SVA_ERROR("Trace idle counter not cleared when in idle state");

    // Idle counter count must run when in stop state
  usva_idle_counter_run:  assert property (@(posedge clk) disable iff (!po_reset_n)
                                       u_viewinst.idle_state_t1 == 3'b010 |=>
                                       trcgen_idle_ack |
                                       $past(etm_atvalidm_o)  |
                                       etm_atvalidm_o  |
                                       u_trace_gen.set_overflow_t3   |
                                       u_trace_gen.overflow_state_t4 |
                                       u_trace_gen.overflow_state_t5 |
                                       (u_trace_gen.trace_idle_state_t2 == 2'b01 & $past(u_viewinst.idle_state_t1 == 3'b001,2)) | // Leaving run state to count
                                       (u_trace_gen.trace_idle_state_t2 == 2'b01 & $past(u_viewinst.idle_state_t1 == 3'b001,3)) | // Leaving run state to count
                                       u_trace_gen.trace_idle_state_cnt_t3 == ($past(u_trace_gen.trace_idle_state_cnt_t3)+4'b0001))
    `SVA_ERROR("Trace idle counter not running when idle stop requested");

 // Sub-set of data written to fifo whilst fifo needing async request
  usva_fifo_seq:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                            u_fifo.sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY[*3] |->
                                    u_trace_gen.async_req_t3 | 
                                    async_req_t4 | 
                                 ~|{u_trace_gen.excep_pkt_gen_t3,u_trace_gen.valid_branch_packet_t3})
    `SVA_ERROR("Exception packet generated before fifo revovered from overflow");
    // Use this instead of above if proven
  usva_fifo_seq1:  assert property  (@(posedge clk) disable iff(!po_reset_n)
                                            u_fifo.sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY |->
                                    u_trace_gen.async_req_t3 | 
                                    async_req_t4 | 
                                 ~|{u_trace_gen.excep_pkt_gen_t3,u_trace_gen.valid_branch_packet_t3})
    `SVA_ERROR("Exception packet generated before fifo revovered from overflow");
    
  usva_wfx_extout:  assert property (@(posedge clk) disable iff (!po_reset_n)
                                       (gov_wfx_drain_req_t2 & ~lp_override_reg)[*10] |-> 
                                       (~|etm_extout & 
                                       ~u_derived_res.extout_enabled_t2))
    `SVA_ERROR("External outputs not disabled in low power mode");

    // Pipelining of sparse fifo input signals after initialisation for non-reset flops
  usva_fifo_in1:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    |num_first8_t5 ##1 |num_first8_t5 |->
    ($past(u_trace_gen.first_8_t3[63:16],3    ) === u_fifo.u_fifo_rotate.full_rot_in[63 :16]))
    `SVA_ERROR("Fifo input pipeline does not match");
  usva_fifo_in2:  assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    |num_bytes_t5 ##1 |num_bytes_t5 |->
    ($past(u_trace_gen.pack_data_out_t5[156:0]) === u_fifo.u_fifo_rotate.full_rot_in[220:64]))
    `SVA_ERROR("Fifo input pipeline does not match");

    // Overflow abstraction - overflow can't happen on first cycle
  usva_overflow_abstract6:  assert property (@(posedge clk) disable iff (!po_reset_n)
    u_trace_gen.set_overflow_t3
      |-> po_reset_n & 
          $past(po_reset_n))
    `SVA_ERROR("Fifo nust not overflow in first cycle after reset");

  // Flush tracking check, should never forget about flush
  usva_flush_lost:  assert property (@(posedge clk) disable iff (!po_reset_n)
    ~u_traceout.wfx_flush_active               &
    $past(gov_atclken_i)                       &
    |u_traceout.sva_flush_bytes_delay_q        &
    $past(|u_traceout.sva_flush_bytes_delay_q) |->
    ~u_traceout.core_flush_nack_q         |
    etm_afreadym_o                        |
    u_traceout.at_flush_req               |
    u_traceout.at_flush_ready             |
    fifo_flush_req                        |
    fifo_idle_ack                         |
    $past(fifo_flush_req)                 |
    fifo_flush_ack                        |
    |u_fifo.flush_delay_t6                |
    (u_fifo.flush_state_t7 & ~fifo_ready) |
    ~&u_fifo.flush_pos_t6)
    `SVA_ERROR("Waiting for flush response, but no flush being tracked in fifo");

  usva_flush_lost2:  assert property (@(posedge clk) disable iff (!po_reset_n)
    u_traceout.at_flush_req_q             |=>
    u_traceout.core_flush_req_q           |
    |u_fifo.flush_delay_t6                |
    ~&u_fifo.flush_pos_t6                 |
    ~fifo_ready                           |
    fifo_idle_ack                         |
    $past(fifo_idle_ack)                  |
    fifo_flush_ack |
    ~u_traceout.core_flush_nack_q)
    `SVA_ERROR("Waiting for flush response, but no flush being tracked in fifo");

  // Flush logic must be reset when ETM is idle
  usva_flush_clear:  assert property (@(posedge clk) disable iff (!po_reset_n)
                                      (u_viewinst.idle_state_t1 == 3'b000 &
                                      ~gov_wfx_drain_req_i)[*3] |=> 
                                      ~u_traceout.wfx_flush_active_q)
    `SVA_ERROR("Flush request is masked");
    
  // If flush fifo is in flush state, must reach the output or see new flush request (around breif idle)
  reg sva_flush_needed;
  always @ (posedge clk or negedge po_reset_n)
  begin
    if  (!po_reset_n)
      sva_flush_needed <= 1'b0;
    else
      sva_flush_needed <= ~etm_afreadym_o & ~fifo_flush_req &
                          ((u_fifo.flush_state_t7 & u_traceout.at_flush_req & u_traceout.at_flush_req_q) |
                           (sva_flush_needed & ~u_fifo.flush_state_t7));
     end 
  flush_not_ack: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
   sva_flush_needed & ~u_fifo.flush_state_t7 |-> etm_atvalidm_o | etm_afreadym_o | u_traceout.at_flush_ready |
 ~gov_atclken_i | ~u_traceout.at_active_state_d | ~u_traceout.at_flush_req_q | fifo_flush_req | fifo_idle_req_t2)
    `SVA_ERROR("Flush not acknowledged");

  // Overflow in o-idle corner
  usva_overflow_seq:  assert property (@(posedge clk) disable iff (!po_reset_n)
               ~wpt_valid_t2 ##1 
               u_trace_gen.trace_state_t4 == 3'b11 & ~fifo_ready & fifo_valid & ~viewinst_idle_req_t2 & ~viewinst_en_t2 ##1
               ~fifo_ready & ~viewinst_idle_req_t2 & ~viewinst_en_t2 & async_req_t4   ##1
               ~fifo_ready |=>
               fifo_overflow | u_fifo.fifo_space_final_t6 < $past(u_fifo.fifo_space_final_t6))
    `SVA_ERROR("Synchronisation not generated whilst recovering from overflow");
                     
  // Traced event must go somewhere  
  usva_event_all_strict:  assert property (@(posedge clk) disable iff (!po_reset_n)
     |u_trace_gen.event_trace_pipe_t3 ##3
    ~|u_fifo.fifo_byte_active_t6 |->  ##1
    $past(|traced_event_t3) |
     $past(fifo_valid && fifo_bytes == 2'b10 && fifo_data[23:4] == 20'h05007,2) | // End of overflow sequence
     $past(fifo_valid && fifo_bytes == 2'b10 && fifo_data[23:4] == 20'h05007,3) | // End of overflow sequence
     $past(fifo_valid && fifo_bytes == 2'b10 && fifo_data[23:4] == 20'h05007,4))  // End of overflow sequence
    `SVA_ERROR("Event was not loaded into fifo, must be traced later");
`endif

`ifdef ARM_FORMAL_ON
  `include "ca53etm_top_formal.sv"
`endif




endmodule // ca53etm
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/ // ca53etm

