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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------
// Abstract: Virtual CPU Interface logic
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"


module ca53gic_cpu_vcpu (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire                              activate_ack_v_outstanding_i,
  input   wire                              activate_release_v_sent_i,
  input   wire  [(`CA53_GIC_ID_W-1):0]      arb_data_rs_interrupt_i,
  input   wire                              arb_data_rs_grp_i,
  input   wire  [(`CA53_GIC_PRI_W-1):0]     arb_data_rs_priority_i,
  input   wire  [(`CA53_GICREG_VCPU_W-1):0] cp_addr_i,
  input   wire  [(`CA53_GIC_ID_W-1):0]      cp_gov_wdata_rs_i,
  input   wire                              cp_gov_wenable_rs_i,
  input   wire                              cp_last_valid_i,
  input   wire                              cp_sys_i,
  input   wire                              cp_valid_i,
  input   wire                              cp_virtual_i,
  input   wire                              cp_wdata_lpi_id_i,
  input   wire                              cp_wdata_spurious_id_i,
  input   wire  [(`CA53_CPDATA_W-1):0]      cpo_wdata_i,
  input   wire                              gicd_ctlr_ds_i,
  input   wire                              gov_scr_el3_fiq_i,
  input   wire                              gov_scr_el3_irq_i,
  input   wire                              quiesce_recv_i,
  input   wire                              sre_el1_ns_i,
  input   wire                              sre_el2_i,
  input   wire                              vclear_recv_i,
  input   wire                              vset_recv_i,
  // Outputs
  output  wire                              activate_not_release_v_o,
  output  wire                              activate_release_v_pending_o,
  output  reg                               deactivate_lr_grp0_o,
  output  reg                               deactivate_lr_grp1_ns_o,
  output  wire                              cpuif_vfiq_o,
  output  wire                              cpuif_virq_o,
  output  wire                              gic_ich_hcr_el2_tall0_o,
  output  wire                              gic_ich_hcr_el2_tall1_o,
  output  wire                              gic_ich_hcr_el2_tc_o,
  output  wire                              nvcpumntirq_o,
  output  wire                              nxt_vset_recv_visible_o,
  output  wire                              send_deactivate_lr_o,
  output  wire                              send_upstream_wr_enables_v_o,
  output  wire                              v_grp0_enable_o,
  output  wire                              v_grp1_enable_o,
  output  wire                              ipr_empty_v_o,
  output  wire  [(`CA53_GIC_ID_W-1):0]      ipr_id_v_o,
  output  wire  [(`CA53_GIC_LR_PID_W-1):0]  deactivate_lr_pid_o,
  output  wire  [(`CA53_CPDATA_W-1):0]      vcpu_rdata_o
);


  // ------------------------------------------------------
  // Constant declarations
  // ------------------------------------------------------

  localparam                      IPR_STATE_W         = 2;
  localparam [(IPR_STATE_W-1):0]  IPR_S_EMPTY         = 2'b00;
  localparam [(IPR_STATE_W-1):0]  IPR_S_PENDING       = 2'b01;
  localparam [(IPR_STATE_W-1):0]  IPR_S_ACKNOWLEDGED  = 2'b11;
  localparam [(IPR_STATE_W-1):0]  IPR_S_RELEASED      = 2'b10;


  // ------------------------------------------------------
  // Variable declarations
  // ------------------------------------------------------

  genvar  i;
  genvar  j;


  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg                                 active_priorities_valid_rs;
  reg   [4:0]                         eoicount;
  reg   [((1<<`CA53_GIC_PRI_W)-1):0]  gich_apr;
  reg   [((1<<`CA53_GIC_PRI_W)-1):0]  ich_ap0r0_el2;
  reg                                 ich_hcr_el2_tall0;
  reg                                 ich_hcr_el2_tall1;
  reg                                 ich_hcr_el2_tc;
  reg                                 ipr_grp;
  reg   [(`CA53_GIC_ID_W-1):0]        ipr_id;
  reg   [(`CA53_GIC_PRI_W-1):0]       ipr_priority;
  reg   [(IPR_STATE_W-1):0]           ipr_state;
  reg   [(`CA53_GIC_LR_CNT-1):0]      lr_grp;
  reg   [(`CA53_GIC_LR_CNT-1):0]      lr_hw;
  reg   [(`CA53_GIC_LR_PID_W-1):0]    lr_physicalid [(`CA53_GIC_LR_CNT-1):0];
  reg   [(`CA53_GIC_PRI_W-1):0]       lr_priority [(`CA53_GIC_LR_CNT-1):0];
  reg   [(`CA53_GIC_LR_S_W-1):0]      lr_state [(`CA53_GIC_LR_CNT-1):0];
  reg   [(`CA53_GIC_ID_W-1):0]        lr_virtualid [(`CA53_GIC_LR_CNT-1):0];
  reg                                 lst_ipr_en;
  reg                                 mntirq_lrenp_enable;
  reg                                 mntirq_np_enable;
  reg                                 mntirq_u_enable;
  reg                                 mntirq_vgrp0d_enable;
  reg                                 mntirq_vgrp0e_enable;
  reg                                 mntirq_vgrp1d_enable;
  reg                                 mntirq_vgrp1e_enable;
  reg                                 nvcpumntirq;
  reg   [(IPR_STATE_W-1):0]           nxt_ipr_state;
  reg                                 raw_v_ackctl;
  reg                                 raw_v_fiq_enable;
  reg   [(`CA53_GIC_PRI_W-1):0]       running_priority_rs;
  reg   [(`CA53_GIC_LR_CNT-1):0]      sel_deactivate_lr_pid;
  reg                                 sel_hp_ipr;
  reg   [(`CA53_GIC_LR_CNT-1):0]      sel_hp_lr;
  reg   [2:0]                         v_binary_point_grp0;
  reg   [(`CA53_GIC_PRI_W-1):0]       v_binary_point_grp0_decoded;
  reg   [2:0]                         v_binary_point_grp1;
  reg   [(`CA53_GIC_PRI_W-1):0]       v_binary_point_grp1_decoded;
  reg                                 v_common_binary_point;
  reg                                 v_grp0_enable;
  reg                                 v_grp1_enable;
  reg                                 v_eoimode;
  reg   [(`CA53_GIC_PRI_W-1):0]       v_priority_mask;
  reg                                 vm_enable;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  acknowlegde_priorities;
  wire                                activate_interrupt;
  wire                                activate_interrupt_gich_apr;
  wire                                activate_interrupt_ipr;
  wire                                activate_interrupt_ich_ap0r0_el2;
  wire  [(`CA53_GIC_LR_CNT-1):0]      activate_lr;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  active_priorities;
  wire                                active_priorities_valid;
  wire  [(`CA53_GIC_PRI_W-1):0]       binary_point_decoded;
  wire                                cp_last_valid_virtual;
  wire                                cp_valid_virtual;
  wire                                cpuif_vfiq;
  wire                                cpuif_virq;
  wire  [(`CA53_GIC_LR_CNT-1):0]      deactivate_lr;
  wire  [(`CA53_GIC_LR_PID_W-1):0]    deactivate_lr_pid;
  wire  [(`CA53_GIC_LR_CNT-1):0]      deactivate_lr_pid_mux [(`CA53_GIC_LR_PID_W-1):0];
  wire                                deactivate_on_dir_wr;
  wire                                deactivate_on_eoir_wr;
  wire                                eoicount_we;
  wire                                gich_apr_we;
  wire  [(`CA53_GIC_LR_CNT-1):0]      gich_eisr0_lrsb;
  wire  [31:0]                        gich_eisr0;
  wire  [(`CA53_GIC_LR_CNT-1):0]      gich_elsr0_lrsb;
  wire  [31:0]                        gich_elsr0;
  wire  [31:0]                        gich_hcr;
  wire  [31:0]                        gich_lr [(`CA53_GIC_LR_CNT-1):0];
  wire  [31:0]                        gich_misr;
  wire  [31:0]                        gich_vmcr;
  wire  [31:0]                        gich_vtr;
  wire  [31:0]                        gicv_abpr;
  wire  [31:0]                        gicv_ahppir;
  wire  [(`CA53_GIC_ID_W-1):0]        gicv_ahppir_id;
  wire  [31:0]                        gicv_aiar;
  wire  [(`CA53_GIC_ID_W-1):0]        gicv_aiar_id;
  wire  [31:0]                        gicv_bpr;
  wire  [31:0]                        gicv_ctlr;
  wire  [31:0]                        gicv_hppir;
  wire  [(`CA53_GIC_ID_W-1):0]        gicv_hppir_id;
  wire  [31:0]                        gicv_iar;
  wire  [(`CA53_GIC_ID_W-1):0]        gicv_iar_id;
  wire  [31:0]                        gicv_pmr;
  wire  [31:0]                        gicv_rpr;
  wire  [7:0]                         gicv_rpr_priority;
  wire                                hcr_we;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  highest_active_priorities;
  wire  [31:0]                        icc_bpr1_el1_v;
  wire  [2:0]                         icc_bpr1_el1_v_bpr;
  wire  [31:0]                        icc_ctlr_el1_v;
  wire  [31:0]                        icc_grpen0_el1_v;
  wire  [31:0]                        icc_grpen1_el1_v;
  wire  [31:0]                        icc_hppir0_el1_v;
  wire  [(`CA53_GIC_ID_W-1):0]        icc_hppir0_el1_v_id;
  wire  [31:0]                        icc_iar0_el1_v;
  wire  [(`CA53_GIC_ID_W-1):0]        icc_iar0_el1_v_id;
  wire                                ich_ap0r0_el2_we;
  wire  [31:0]                        ich_hcr_el2;
  wire  [63:0]                        ich_lr_el2 [(`CA53_GIC_LR_CNT-1):0];
  wire  [(`CA53_GIC_LR_CNT-1):0]      ich_lr_we;
  wire  [(`CA53_GIC_LR_CNT-1):0]      ich_lrc_we;
  wire  [31:0]                        ich_vmcr_el2;
  wire  [31:0]                        ich_vtr_el2;
  wire                                increment_eoicount;
  wire                                ipr_empty;
  wire                                ipr_en;
  wire                                ipr_enabled;
  wire                                ipr_pending_valid;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_eoi_group_cmp;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_found;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_found_cmp;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_pending_valid;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_physicalid_eoi;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_priority_cmp;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_state_active;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_state_invalid;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_state_pactive;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_state_pending;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_state_wr;
  wire  [(`CA53_GIC_LR_CNT-1):0]      lr_underflow;
  wire                                mem_or_sys_grp1_pd;
  wire                                mntirq_eoi;
  wire                                mntirq_lrenp;
  wire                                mntirq_np;
  wire                                mntirq_u;
  wire                                mntirq_vgrp0d;
  wire                                mntirq_vgrp0e;
  wire                                mntirq_vgrp1d;
  wire                                mntirq_vgrp1e;
  wire                                nxt_deactivate_lr_grp0;
  wire                                nxt_deactivate_lr_grp1_ns;
  wire  [4:0]                         nxt_eoicount;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  nxt_gich_apr;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  nxt_ich_ap0r0_el2;
  wire                                nxt_ich_hcr_el2_tall0;
  wire                                nxt_ich_hcr_el2_tall1;
  wire                                nxt_ich_hcr_el2_tc;
  wire                                nxt_lr_grp;
  wire                                nxt_lr_hw;
  wire  [(`CA53_GIC_LR_PID_W-1):0]    nxt_lr_physicalid;
  wire  [(`CA53_GIC_PRI_W-1):0]       nxt_lr_priority;
  wire  [(`CA53_GIC_ID_W-1):0]        nxt_lr_virtualid;
  wire  [(`CA53_GIC_LR_S_W-1):0]      nxt_lr_state [(`CA53_GIC_LR_CNT-1):0];
  wire                                nxt_nvcpumntirq;
  wire                                nxt_raw_v_ackctl;
  wire                                nxt_raw_v_fiq_enable;
  wire                                nxt_sel_hp_ipr;
  wire  [(`CA53_GIC_LR_CNT-1):0]      nxt_sel_hp_lr;
  wire  [2:0]                         nxt_v_binary_point_grp0;
  wire  [2:0]                         nxt_v_binary_point_grp1;
  wire                                nxt_v_common_binary_point;
  wire                                nxt_v_eoimode;
  wire                                nxt_v_grp0_enable;
  wire                                nxt_v_grp1_enable;
  wire  [(`CA53_GIC_PRI_W-1):0]       nxt_v_priority_mask;
  wire                                preemption_valid;
  wire                                priority_unmasked;
  wire                                raw_v_ackctl_wr;
  wire                                raw_v_fiq_enable_wr;
  wire                                rd_valid;
  wire  [31:0]                        rdata_word_high;
  wire  [31:0]                        rdata_word_low;
  wire  [(`CA53_GIC_PRI_W-1):0]       running_priority;
  wire  [(`CA53_GIC_PRI_W-1):0]       running_priority_values [((1<<`CA53_GIC_PRI_W)-1):0];
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]  running_priority_values_rotated [(`CA53_GIC_PRI_W-1):0];
  wire                                sel_gich_apr;
  wire                                sel_gich_eisr0;
  wire                                sel_gich_elsr0;
  wire                                sel_gich_hcr;
  wire  [(`CA53_GIC_LR_CNT-1):0]      sel_gich_lr;
  wire                                sel_gich_lrn;
  wire                                sel_gich_misr;
  wire                                sel_gich_vmcr;
  wire                                sel_gich_vtr;
  wire                                sel_gicv_abpr;
  wire                                sel_gicv_aeoir;
  wire                                sel_gicv_ahppir;
  wire                                sel_gicv_aiar;
  wire                                sel_gicv_apr;
  wire                                sel_gicv_bpr;
  wire                                sel_gicv_ctlr;
  wire                                sel_gicv_dir;
  wire                                sel_gicv_eoir;
  wire                                sel_gicv_hppir;
  wire                                sel_gicv_iar;
  wire                                sel_gicv_pmr;
  wire                                sel_gicv_rpr;
  wire  [(`CA53_GIC_LR_CNT):0]        sel_hp_int;
  wire                                sel_hp_int_grp;
  wire  [(`CA53_GIC_ID_W-1):0]        sel_hp_int_id;
  wire  [(`CA53_GIC_PRI_W-1):0]       sel_hp_int_priority;
  wire                                sel_hp_int_valid;
  wire                                sel_hp_ipr_valid;
  wire                                sel_hp_iprnlr1lr0;
  wire                                sel_hp_iprnlr3lr2;
  wire  [(`CA53_GIC_PRI_W-1):0]       sel_hp_lr1lr0_priority;
  wire                                sel_hp_lr1lr0_valid;
  wire                                sel_hp_lr1nlr0;
  wire                                sel_hp_lr3lr2nlr1lr0;
  wire  [(`CA53_GIC_PRI_W-1):0]       sel_hp_lr3lr2_priority;
  wire                                sel_hp_lr3lr2_valid;
  wire                                sel_hp_lr3nlr2;
  wire                                sel_icc_bpr0_el1_v;
  wire                                sel_icc_bpr1_el1_v;
  wire                                sel_icc_ctlr_el1_v;
  wire                                sel_icc_dir_el1_v;
  wire                                sel_icc_eoir0_el1_v;
  wire                                sel_icc_eoir1_el1_v;
  wire                                sel_icc_grpen0_el1_v;
  wire                                sel_icc_grpen1_el1_v;
  wire                                sel_icc_hppir0_el1_v;
  wire                                sel_icc_hppir1_el1_v;
  wire                                sel_icc_iar0_el1_v;
  wire                                sel_icc_iar1_el1_v;
  wire                                sel_icc_pmr_el1_v;
  wire                                sel_icc_rpr_el1_v;
  wire                                sel_ich_ap0r0_el2;
  wire                                sel_ich_ap1r0_el2;
  wire                                sel_ich_eisr_el2;
  wire                                sel_ich_elsr_el2;
  wire                                sel_ich_hcr_el2;
  wire  [(`CA53_GIC_LR_CNT-1):0]      sel_ich_lr;
  wire  [(`CA53_GIC_LR_CNT-1):0]      sel_ich_lr_el2;
  wire  [(`CA53_GIC_LR_CNT-1):0]      sel_ich_lrc;
  wire                                sel_ich_lrcn;
  wire                                sel_ich_lrn_el2;
  wire                                sel_ich_misr_el2;
  wire                                sel_ich_vmcr_el2;
  wire                                sel_ich_vtr_el2;
  wire                                sel_mem_or_sys_grp1_pd;
  wire                                sel_sys_grp0_pd;
  wire                                signal_interrupt;
  wire  [(`CA53_GIC_LR_CNT-1):0]      spurious_lr_pid;
  wire                                spurious_virtual_id;
  wire                                sys_grp0_pd;
  wire                                v_ackctl;
  wire  [2:0]                         v_binary_point_grp0_ns;
  wire  [2:0]                         v_binary_point_grp0_wdata;
  wire                                v_binary_point_grp0_wr;
  wire  [2:0]                         v_binary_point_grp1_wdata;
  wire                                v_binary_point_grp1_wr;
  wire                                v_common_binary_point_wr;
  wire                                v_fiq_enable;
  wire                                v_grp0_enable_wr;
  wire                                v_grp1_enable_wr;
  wire                                v_eoimode_wr;
  wire                                v_priority_mask_we;
  wire                                vclear_recv_valid;
  wire                                wr_valid;


  // ------------------------------------------------------
  // Interrupt Packet Register
  // ------------------------------------------------------

  // VClear packets only affect the IPR if the IDs match
  assign vclear_recv_valid = vclear_recv_i & ( ipr_id == arb_data_rs_interrupt_i );

  always @*
    case ( ipr_state )
      IPR_S_EMPTY         : nxt_ipr_state = vset_recv_i ? IPR_S_PENDING : IPR_S_EMPTY;
      IPR_S_PENDING       : nxt_ipr_state = activate_interrupt_ipr ? IPR_S_ACKNOWLEDGED:
                                            ( ~ipr_enabled | quiesce_recv_i | vclear_recv_valid | vset_recv_i ) ? IPR_S_RELEASED : IPR_S_PENDING;
      IPR_S_ACKNOWLEDGED  : nxt_ipr_state = activate_release_v_sent_i ? IPR_S_EMPTY : IPR_S_ACKNOWLEDGED;
      IPR_S_RELEASED      : nxt_ipr_state = activate_release_v_sent_i ? IPR_S_EMPTY : IPR_S_RELEASED;
      default             : nxt_ipr_state = {IPR_STATE_W{1'bx}};
    endcase

  assign ipr_empty = ipr_state == IPR_S_EMPTY;

  assign ipr_en    = ipr_empty & vset_recv_i;

  always @ ( posedge clk )
    if ( ipr_en ) begin
      ipr_grp       <= arb_data_rs_grp_i;
      ipr_id        <= arb_data_rs_interrupt_i;
      ipr_priority  <= arb_data_rs_priority_i;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ipr_state   <= IPR_S_EMPTY;
      lst_ipr_en  <= 1'b0;
    end else begin
      ipr_state   <= nxt_ipr_state;
      lst_ipr_en  <= ipr_en;
    end

  // The packet in the IPR is a candidate for prioritization
  assign ipr_enabled  = vm_enable &
                        ( ipr_grp ? v_grp1_enable : v_grp0_enable ) &
                        sre_el2_i;

  // There is a pending interrupt that is enabled and can be serviced
  assign ipr_pending_valid  = ( ipr_state == IPR_S_PENDING ) &
                              ipr_enabled &
                              ~activate_ack_v_outstanding_i;

  // Activate the interrupt held in the IPR
  assign activate_interrupt_ipr = activate_interrupt & sel_hp_int[`CA53_GIC_LR_CNT];


  // ------------------------------------------------------
  // Access decoding
  // ------------------------------------------------------

  // Memory mapped legacy GICv2
  assign sel_gich_apr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_APR );
  assign sel_gich_eisr0   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_EISR0 );
  assign sel_gich_elsr0   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_ELSR0 );
  assign sel_gich_hcr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_HCR );
  assign sel_gich_lr[0]   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_LR0 );
  assign sel_gich_lr[1]   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_LR1 );
  assign sel_gich_lr[2]   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_LR2 );
  assign sel_gich_lr[3]   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_LR3 );
  assign sel_gich_misr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_MISR );
  assign sel_gich_vmcr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_VMCR );
  assign sel_gich_vtr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICH_OP_VTR );
  assign sel_gicv_abpr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_ABPR );
  assign sel_gicv_aeoir   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_AEOIR );
  assign sel_gicv_ahppir  = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_AHPPIR );
  assign sel_gicv_aiar    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_AIAR );
  assign sel_gicv_apr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_APR );
  assign sel_gicv_bpr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_BPR );
  assign sel_gicv_ctlr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_CTLR );
  assign sel_gicv_dir     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_DIR );
  assign sel_gicv_eoir    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_EOIR );
  assign sel_gicv_hppir   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_HPPIR );
  assign sel_gicv_iar     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_IAR );
  assign sel_gicv_pmr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_PMR );
  assign sel_gicv_rpr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICHV_OP_W-1):0] == `CA53_GICV_OP_RPR );

  // System register GICv3
  assign sel_icc_bpr0_el1_v   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR_BPR0 );
  assign sel_icc_bpr1_el1_v   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR_BPR1 );
  assign sel_icc_ctlr_el1_v   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_CTLR );
  assign sel_icc_dir_el1_v    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_DIR );
  assign sel_icc_eoir0_el1_v  = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_EOIR );
  assign sel_icc_eoir1_el1_v  = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_AEOIR );
  assign sel_icc_grpen0_el1_v = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR_VENG0 );
  assign sel_icc_grpen1_el1_v = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR_VENG1 );
  assign sel_icc_hppir0_el1_v = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_HPPIR );
  assign sel_icc_hppir1_el1_v = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_AHPPIR );
  assign sel_icc_iar0_el1_v   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_IAR );
  assign sel_icc_iar1_el1_v   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_AIAR );
  assign sel_icc_pmr_el1_v    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR_PMR );
  assign sel_icc_rpr_el1_v    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICV_RPR );
  assign sel_ich_ap0r0_el2    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_APR0 );
  assign sel_ich_ap1r0_el2    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_APR1 );
  assign sel_ich_eisr_el2     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_EISR );
  assign sel_ich_elsr_el2     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_ELSR );
  assign sel_ich_hcr_el2      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_HCR );
  assign sel_ich_lr[0]        = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR0_L );
  assign sel_ich_lr[1]        = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR1_L );
  assign sel_ich_lr[2]        = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR2_L );
  assign sel_ich_lr[3]        = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR3_L );
  assign sel_ich_lr_el2[0]    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR0 );
  assign sel_ich_lr_el2[1]    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR1 );
  assign sel_ich_lr_el2[2]    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR2 );
  assign sel_ich_lr_el2[3]    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR3 );
  assign sel_ich_lrc[0]       = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR0_H );
  assign sel_ich_lrc[1]       = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR1_H );
  assign sel_ich_lrc[2]       = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR2_H );
  assign sel_ich_lrc[3]       = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_LR3_H );
  assign sel_ich_misr_el2     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_MISR );
  assign sel_ich_vmcr_el2     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VMCR );
  assign sel_ich_vtr_el2      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICH_VTR );

  // Generic list register select
  assign sel_gich_lrn     = |sel_gich_lr;
  assign sel_ich_lrcn     = |sel_ich_lrc;
  assign sel_ich_lrn_el2  = |sel_ich_lr_el2;

  // The operation is valid for this interface
  assign cp_valid_virtual      = cp_valid_i      & cp_virtual_i;
  assign cp_last_valid_virtual = cp_last_valid_i & cp_virtual_i;

  // Valid read
  assign rd_valid = cp_valid_virtual & ~cp_gov_wenable_rs_i;

  // Valid write
  assign wr_valid = cp_valid_virtual &  cp_gov_wenable_rs_i;


  // ------------------------------------------------------
  // Active Priorities Registers
  // ------------------------------------------------------

  // Active Priorities Registers encoding:
  //  ich_ap0r0_el2[i] | gich_apr[i] | Decoding
  //  --------------------------------------------------------------------------------
  //                 0 |           0 | No active interrupt
  //                 0 |           1 | Group one or when memory mapped also group zero
  //                 1 |           0 | Group zero system register
  //                 1 |           1 | Not supported

  assign sel_mem_or_sys_grp1_pd = sel_gicv_aeoir |
                                  sel_gicv_eoir |
                                  sel_icc_eoir0_el1_v |
                                  sel_icc_eoir1_el1_v;

  assign mem_or_sys_grp1_pd     = ~cp_wdata_spurious_id_i &
                                   sel_mem_or_sys_grp1_pd;

  assign sel_sys_grp0_pd        = sel_icc_eoir0_el1_v |
                                  sel_icc_eoir1_el1_v;

  assign sys_grp0_pd            = ~cp_wdata_spurious_id_i &
                                   sel_sys_grp0_pd;

  assign gich_apr_we            = ( activate_interrupt_gich_apr ) |
                                  ( wr_valid & ( mem_or_sys_grp1_pd |
                                                 sel_gich_apr |
                                                 sel_gicv_apr |
                                                 sel_ich_ap0r0_el2 |
                                                 sel_ich_ap1r0_el2 ) );

  assign nxt_gich_apr           = ( {32{sel_gicv_aiar         | sel_gicv_iar | sel_icc_iar1_el1_v}} & ( gich_apr      |  acknowlegde_priorities ) ) |
                                  ( {32{sel_mem_or_sys_grp1_pd}}                                    & ( gich_apr      & ~highest_active_priorities ) ) |
                                  ( {32{sel_gich_apr          | sel_gicv_apr | sel_ich_ap1r0_el2}}  & (~ich_ap0r0_el2 &  cpo_wdata_i[31:0] ) ) |
                                  ( {32{sel_ich_ap0r0_el2}}                                         & ( gich_apr      & ~cpo_wdata_i[31:0] ) );

  assign ich_ap0r0_el2_we       = ( activate_interrupt_ich_ap0r0_el2 ) |
                                  ( wr_valid & ( sys_grp0_pd |
                                                 sel_ich_ap0r0_el2 ) );

  assign nxt_ich_ap0r0_el2      = ( {32{sel_icc_iar0_el1_v}}  & ( ich_ap0r0_el2     |  acknowlegde_priorities ) ) |
                                  ( {32{sel_sys_grp0_pd}}     & ( ich_ap0r0_el2     & ~highest_active_priorities ) ) |
                                  ( {32{sel_ich_ap0r0_el2}}   &   cpo_wdata_i[31:0] );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gich_apr <= {(1<<`CA53_GIC_PRI_W){1'b0}};
    end else if ( gich_apr_we ) begin
      gich_apr <= nxt_gich_apr;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ich_ap0r0_el2 <= {(1<<`CA53_GIC_PRI_W){1'b0}};
    end else if ( ich_ap0r0_el2_we ) begin
      ich_ap0r0_el2 <= nxt_ich_ap0r0_el2;
    end


  // ------------------------------------------------------
  // Binary Point Registers
  // ------------------------------------------------------

  assign v_binary_point_grp0_wr     = sel_gich_vmcr |
                                      sel_gicv_bpr |
                                      sel_icc_bpr0_el1_v |
                                      sel_ich_vmcr_el2;

  assign v_binary_point_grp0_wdata  = ( {3{sel_gich_vmcr}}      & cpo_wdata_i[23:21] ) |
                                      ( {3{sel_gicv_bpr}}       & cpo_wdata_i[2:0] ) |
                                      ( {3{sel_icc_bpr0_el1_v}} & cpo_wdata_i[2:0] ) |
                                      ( {3{sel_ich_vmcr_el2}}   & cpo_wdata_i[23:21] );

  assign nxt_v_binary_point_grp0    = ~v_binary_point_grp0_wr               ? v_binary_point_grp0 :
                                      ( v_binary_point_grp0_wdata >= 3'd2 ) ? v_binary_point_grp0_wdata :
                                                                              3'd2;

  assign v_binary_point_grp1_wr     = sel_gich_vmcr |
                                      sel_gicv_abpr |
                                      ( sel_icc_bpr1_el1_v & ~v_common_binary_point ) |
                                      sel_ich_vmcr_el2;

  assign v_binary_point_grp1_wdata  = ( {3{sel_gich_vmcr}}      & cpo_wdata_i[20:18] ) |
                                      ( {3{sel_gicv_abpr}}      & cpo_wdata_i[2:0] ) |
                                      ( {3{sel_icc_bpr1_el1_v}} & cpo_wdata_i[2:0] ) |
                                      ( {3{sel_ich_vmcr_el2}}   & cpo_wdata_i[20:18] );

  assign nxt_v_binary_point_grp1    = ~v_binary_point_grp1_wr               ? v_binary_point_grp1 :
                                      ( v_binary_point_grp1_wdata >= 3'd3 ) ? v_binary_point_grp1_wdata :
                                                                              3'd3;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      v_binary_point_grp0 <= 3'd2;
      v_binary_point_grp1 <= 3'd3;
    end else if ( wr_valid ) begin
      v_binary_point_grp0 <= nxt_v_binary_point_grp0;
      v_binary_point_grp1 <= nxt_v_binary_point_grp1;
    end

  // Non-secure view of group zero binary point
  assign v_binary_point_grp0_ns = ( &v_binary_point_grp0 ) ? v_binary_point_grp0 : v_binary_point_grp0 + 1'b1;

  assign icc_bpr1_el1_v_bpr     = v_common_binary_point ? v_binary_point_grp0_ns : v_binary_point_grp1;

  // Architectural register(s)
  // NOTE: GICV_ABPR is not effected by the CBPR
  assign gicv_abpr      = { {29{1'b0}},             // RES0
                            v_binary_point_grp1 };  // Binary point

  // NOTE: GICV_BPR (GICv2) == ICC_BPR0_EL1_V (GICv3)
  assign gicv_bpr       = { {29{1'b0}},             // RES0
                            v_binary_point_grp0 };  // Binary point

  // NOTE: ICC_BPR1_EL1_V is effected by the CBPR
  assign icc_bpr1_el1_v = { {29{1'b0}},             // RES0
                            icc_bpr1_el1_v_bpr };   // Binary point


  // ------------------------------------------------------
  // Control Registers
  // ------------------------------------------------------

  // Common Binary Point Register (cbpr):
  // - GICH_VMCR[4]
  // - GICV_CTLR[4]
  // - ICC_CTLR_EL1_V[0]
  // - ICH_VMCR_EL2[4]
  assign v_common_binary_point_wr   = sel_gich_vmcr |
                                      sel_gicv_ctlr |
                                      sel_icc_ctlr_el1_v |
                                      sel_ich_vmcr_el2;

  assign nxt_v_common_binary_point  = ~v_common_binary_point_wr ? v_common_binary_point:
                                       sel_icc_ctlr_el1_v       ? cpo_wdata_i[0]:
                                                                  cpo_wdata_i[4];

  // End Of Interrupt Mode (eoimode):
  // - SEL_GICH_VMCR[9]
  // - GICV_CTLR[9]
  // - ICC_CTLR_EL1_V[1]
  // - ICH_VMCR_EL2[9]
  assign v_eoimode_wr   = sel_gich_vmcr |
                          sel_gicv_ctlr |
                          sel_icc_ctlr_el1_v |
                          sel_ich_vmcr_el2;

  assign nxt_v_eoimode  = ~v_eoimode_wr       ? v_eoimode:
                           sel_icc_ctlr_el1_v ? cpo_wdata_i[1]:
                                                cpo_wdata_i[9];

  // Acknowledge Control (v_ackctl)
  // - GICH_VMCR[2]
  // - GICV_CTLR[2]
  // - ICH_VMCR_EL2[2]
  assign raw_v_ackctl_wr  = sel_gich_vmcr |
                            sel_gicv_ctlr |
                            sel_ich_vmcr_el2;

  assign nxt_raw_v_ackctl = raw_v_ackctl_wr ? cpo_wdata_i[2] : raw_v_ackctl;

  // FIQ Enable (v_fiq_enable):
  // - GICH_VMCR[3]
  // - GICV_CTLR[3]
  // - ICH_VMCR_EL2[3]
  assign raw_v_fiq_enable_wr  = sel_gich_vmcr |
                                sel_gicv_ctlr |
                                sel_ich_vmcr_el2;

  assign nxt_raw_v_fiq_enable = raw_v_fiq_enable_wr ? cpo_wdata_i[3] : raw_v_fiq_enable;

  // Enable Group 0 (enablegrp0):
  // - GICH_VMCR[0]
  // - GICV_CTLR[0]
  // - ICH_VMCR_EL2[0]
  // - ICC_GRPEN0_EL1_V[0]
  assign v_grp0_enable_wr   = sel_gich_vmcr |
                              sel_gicv_ctlr |
                              sel_icc_grpen0_el1_v |
                              sel_ich_vmcr_el2;

  assign nxt_v_grp0_enable  = v_grp0_enable_wr ? cpo_wdata_i[0] : v_grp0_enable;

  // Enable Group 1 (enablegrp1):
  // - GICH_VMCR[1]
  // - GICV_CTLR[1]
  // - ICH_VMCR_EL2[1]
  // - ICC_GRPEN1_EL1_V[0]
  assign v_grp1_enable_wr   = sel_gich_vmcr |
                              sel_gicv_ctlr |
                              sel_icc_grpen1_el1_v |
                              sel_ich_vmcr_el2;

  assign nxt_v_grp1_enable  = ~v_grp1_enable_wr     ? v_grp1_enable:
                               sel_icc_grpen1_el1_v ? cpo_wdata_i[0]:
                                                      cpo_wdata_i[1];

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      raw_v_ackctl          <= 1'b0;
      raw_v_fiq_enable      <= 1'b0;
      v_common_binary_point <= 1'b0;
      v_eoimode             <= 1'b0;
      v_grp0_enable         <= 1'b0;
      v_grp1_enable         <= 1'b0;
    end else if ( wr_valid ) begin
      raw_v_ackctl          <= nxt_raw_v_ackctl;
      raw_v_fiq_enable      <= nxt_raw_v_fiq_enable;
      v_common_binary_point <= nxt_v_common_binary_point;
      v_eoimode             <= nxt_v_eoimode;
      v_grp0_enable         <= nxt_v_grp0_enable;
      v_grp1_enable         <= nxt_v_grp1_enable;
    end

  // GICV_CTLR.ACKCTL is treated as zero when the guest is using system
  // registers (i.e. ICC_SRE_EL1.SRE non-secure is being treated as one).
  assign v_ackctl = raw_v_ackctl & ~sre_el1_ns_i;

  // GICV_CTLR.FIQEN is treated as one when the guest is using system
  // registers (i.e. ICC_SRE_EL1.SRE non-secure is being treated as one).
  assign v_fiq_enable = raw_v_fiq_enable | sre_el1_ns_i;

  // Architectural register(s)
  assign gicv_ctlr        = { {22{1'b0}},                 // RES0
                              v_eoimode,                  // EOImodeNS
                              {4{1'b0}},                  // RES0
                              v_common_binary_point,      // CBPR
                              raw_v_fiq_enable,           // FIQEn
                              raw_v_ackctl,               // AckCtl
                              v_grp1_enable,              // EnableGrp1
                              v_grp0_enable };            // EnableGrp0

  assign icc_ctlr_el1_v   = { {18{1'b0}},                 // RES0
                              {3{1'b0}},                  // IDbits
                              (3'd`CA53_GIC_PRI_W-1'b1),  // PRIbits
                              {5{1'b0}},                  // RES0
                              1'b0,                       // RES0 (PMHE is not for virtual accesses)
                              v_eoimode,                  // EOImodeNS
                              v_common_binary_point };    // CBPR

  assign icc_grpen0_el1_v = { {31{1'b0}},                 // RES0
                              v_grp0_enable };            // Enable

  assign icc_grpen1_el1_v = { {31{1'b0}},                 // RES0
                              v_grp1_enable };            // Enable


  // ------------------------------------------------------
  // Deactivate Interrupt and End of Interrupt Registers
  // ------------------------------------------------------

  // Virtual interrupts are deactivated in list registers if the EOIMODE bit is
  // asserted and the virtual interrupt ID being writen is not in the LPI range.
  assign deactivate_on_dir_wr = ~cp_wdata_lpi_id_i & v_eoimode;

  // Virtual interrupts are deactivated in list registers if the EOIMODE bit is
  // NOT asserted or the virtual interrupt ID being writen is in the LPI range.
  // This is required as LPI do not require deactivation and for list registers
  // the process of deactivation and priority drop are combined for LPIs.
  assign deactivate_on_eoir_wr = cp_wdata_lpi_id_i | ~v_eoimode;

  // Per list register check if the virtual group corresponds to the EOIR
  // access being performed.
  assign lr_eoi_group_cmp = ( {`CA53_GIC_LR_CNT{sel_gicv_aeoir  | sel_icc_eoir1_el1_v}} &    lr_grp ) |
                            ( {`CA53_GIC_LR_CNT{sel_gicv_eoir   | sel_icc_eoir0_el1_v}} & ( ~lr_grp | {`CA53_GIC_LR_CNT{v_ackctl}} ) );

  // Deactivate the appropriate list register.
  assign deactivate_lr  = {`CA53_GIC_LR_CNT{~cp_wdata_spurious_id_i & cp_gov_wenable_rs_i}} &
                          lr_found &
                          ( ( {`CA53_GIC_LR_CNT{deactivate_on_dir_wr    & ( sel_gicv_dir | sel_icc_dir_el1_v ) } } ) |
                            ( {`CA53_GIC_LR_CNT{deactivate_on_eoir_wr}} & lr_eoi_group_cmp & lr_priority_cmp ) );

  // The physical groups that the deactivation of a virtual can modify
  assign nxt_deactivate_lr_grp0    = cp_sys_i ? ~gov_scr_el3_fiq_i & gicd_ctlr_ds_i : gicd_ctlr_ds_i;
  assign nxt_deactivate_lr_grp1_ns = cp_sys_i ? ~gov_scr_el3_irq_i                  : 1'b1;

  // Send a Deactivate interrupt packet for a physical interrupt to the
  // Distributor.  LPIs are also implicitly not sent as the list register
  // physical ID size is too small to support interrupts in the LPI range.
  assign send_deactivate_lr_o = wr_valid &
                                |(  deactivate_lr & lr_hw & ~spurious_lr_pid ) &
                                ( nxt_deactivate_lr_grp0 | nxt_deactivate_lr_grp1_ns );

  always @ ( posedge clk )
    if ( wr_valid ) begin
      deactivate_lr_grp0_o    <= nxt_deactivate_lr_grp0;
      deactivate_lr_grp1_ns_o <= nxt_deactivate_lr_grp1_ns;
    end


  // ------------------------------------------------------
  // End of Interrupt Status Registers
  // ------------------------------------------------------

  assign gich_eisr0_lrsb = ~lr_hw &              // Not hardware
                            lr_physicalid_eoi &  // Requires EOI
                            lr_state_invalid;    // Interrupt in invalid state (i.e. post Active)

  // Architectural register(s)
  // NOTE: GICH_EISR0 (GICv2) == ICH_EISR_EL2 (GICv3)
  assign gich_eisr0 = { {(32-`CA53_GIC_LR_CNT){1'b0}},  // RES0
                        gich_eisr0_lrsb };              // List register status bits


  // ------------------------------------------------------
  // Empty List Register Status Register
  // ------------------------------------------------------

  assign gich_elsr0_lrsb = lr_state_invalid & ( lr_hw | ~lr_physicalid_eoi );

  // Architectural register(s)
  // NOTE: GICH_ELSR0 (GICv2) == ICH_ELSR_EL2 (GICv3)
  assign gich_elsr0 = { {(32-`CA53_GIC_LR_CNT){1'b0}},  // RES0 (unimplemented)
                        gich_elsr0_lrsb };              // List register status bits


  // ------------------------------------------------------
  // Highest Priority Pending Interrupt Register
  // ------------------------------------------------------

  // if interrupt pending:
  //   if group enabled for pending interrupt (was implementation defined in GICv2):
  //     if pending interrupt is group one:
  //       return pending interrupt ID
  // return 1023
  assign gicv_ahppir_id = ( sel_hp_int_valid & sel_hp_int_grp ) ? sel_hp_int_id : `CA53_GIC_ID_SPURIOUS_NONE;

  // if interrupt pending:
  //   if group enabled for pending interrupt (was implementation defined in GICv2):
  //     if pending interrupt is group zero:
  //       return pending interrupt ID
  //     else:
  //       if GICV_CTLR.AckCtl==1:
  //         return pending interrupt ID
  //       else:
  //         return 1022
  // return 1023
  assign gicv_hppir_id  = ~sel_hp_int_valid               ? `CA53_GIC_ID_SPURIOUS_NONE:
                          ( ~sel_hp_int_grp | v_ackctl )  ? sel_hp_int_id :
                                                            `CA53_GIC_ID_SPURIOUS_SECURITY;

  // if interrupt pending:
  //   if group enabled for pending interrupt (was implementation defined in GICv2):
  //     if pending interrupt is group zero:
  //       return pending interrupt ID
  // return 1023
  // NOTE: GICv3 does not provide any indication of a group one inteerrupt.
  assign icc_hppir0_el1_v_id = ( sel_hp_int_valid & ~sel_hp_int_grp ) ? sel_hp_int_id : `CA53_GIC_ID_SPURIOUS_NONE;

  // Architectural register(s)
  // NOTE: GICV_AHPPIR = virtual accesses to ICC_AHPPIR1_EL1
  assign gicv_ahppir      = { {16{1'b0}},             // ID (unimplemented ID space)
                              gicv_ahppir_id };       // ID

  assign gicv_hppir       = { {16{1'b0}},             // ID (unimplemented ID space)
                              gicv_hppir_id};         // ID

  assign icc_hppir0_el1_v = { {16{1'b0}},             // ID (unimplemented ID space)
                              icc_hppir0_el1_v_id };  // ID


  // ------------------------------------------------------
  // Interrupt Acknowledge Register
  // ------------------------------------------------------

  // if virtual machine enabled:
  //   if interrupt pending:
  //     if group enabled for pending interrupt (was implementation defined in GICv2):
  //       if interrut not masked:
  //         if pending interrupt is group one:
  //           return pending interrupt ID
  // return 1023
  assign gicv_aiar_id = ( signal_interrupt & sel_hp_int_grp ) ? sel_hp_int_id : `CA53_GIC_ID_SPURIOUS_NONE;

  // if virtual machine enabled:
  //   if interrupt pending:
  //     if group enabled for pending interrupt (was implementation defined in GICv2):
  //       if interrut not masked:
  //         if pending interrupt is group zero:
  //           return pending interrupt ID
  //         else:
  //           if GICV_CTLR.AckCtl==1:
  //             return pending interrupt ID
  //           else:
  //             return 1022
  // return 1023
  assign gicv_iar_id  = ~signal_interrupt               ? `CA53_GIC_ID_SPURIOUS_NONE:
                        ( ~sel_hp_int_grp | v_ackctl )  ? sel_hp_int_id :
                                                          `CA53_GIC_ID_SPURIOUS_SECURITY;

  // if virtual machine enabled:
  //   if interrupt pending:
  //     if group enabled for pending interrupt (was implementation defined in GICv2):
  //       if interrut not masked:
  //         if pending interrupt is group zero:
  //           return pending interrupt ID
  // return 1023
  assign icc_iar0_el1_v_id = ( signal_interrupt & ~sel_hp_int_grp ) ? sel_hp_int_id : `CA53_GIC_ID_SPURIOUS_NONE;


  // A register access results in the change of state of the list register or
  // VLPIR.  The active prioritiy registers may not change as a result.
  assign activate_interrupt               = signal_interrupt &
                                            rd_valid &
                                            ( ( ( sel_gicv_aiar | sel_icc_iar1_el1_v ) &    sel_hp_int_grp ) |
                                              ( ( sel_gicv_iar  | sel_icc_iar0_el1_v ) & ( ~sel_hp_int_grp | v_ackctl ) ) );

  // A register access results in the change of state of the list register or
  // VLPIR, and the activated priority will be added to the ICH_AP0R0_EL2.
  assign activate_interrupt_ich_ap0r0_el2 = signal_interrupt &
                                            ~spurious_virtual_id &
                                            cp_valid_virtual &
                                            ( sel_icc_iar0_el1_v & ~sel_hp_int_grp );

  // A register access results in the change of state of the list register or
  // VLPIR, and the activated priority will be added to the GICH_APR (ICH_AP1R0_EL2).
  assign activate_interrupt_gich_apr      = signal_interrupt &
                                            ~spurious_virtual_id &
                                            rd_valid &
                                            ( ( ( sel_gicv_aiar | sel_icc_iar1_el1_v ) &    sel_hp_int_grp ) |
                                              (   sel_gicv_iar                         & ( ~sel_hp_int_grp | v_ackctl ) ) );

  // Activate a list register if an interrupt is being activated and the
  // highest priority interrupt is a list register.
  // NOTE: Highest priority interrupt is a zero one hot encoding including
  // the VLIPR as the MSB.
  assign activate_lr = {`CA53_GIC_LR_CNT{activate_interrupt}} & sel_hp_int[(`CA53_GIC_LR_CNT-1):0];

  // Architectural register(s)
  // NOTE: GICV_AIAR = virtual accesses to ICC_IAR1_EL1
  assign gicv_aiar      = { {16{1'b0}},           // ID (unimplemented ID space)
                            gicv_aiar_id };       // ID

  assign gicv_iar       = { {16{1'b0}},           // ID (unimplemented ID space)
                            gicv_iar_id };        // ID

  assign icc_iar0_el1_v = { {16{1'b0}},           // ID (unimplemented ID space)
                            icc_iar0_el1_v_id };  // ID


  // ------------------------------------------------------
  // Hypervisor Control Register
  // ------------------------------------------------------

  assign hcr_we                 = wr_valid & ( sel_gich_hcr | sel_ich_hcr_el2 );

  assign eoicount_we            = wr_valid & ( sel_gich_hcr |
                                               sel_gicv_aeoir |
                                               sel_gicv_dir |
                                               sel_gicv_eoir |
                                               sel_icc_dir_el1_v |
                                               sel_icc_eoir0_el1_v |
                                               sel_icc_eoir1_el1_v |
                                               sel_ich_hcr_el2 );

  assign increment_eoicount     = ~cp_wdata_lpi_id_i &
                                  ~cp_wdata_spurious_id_i &
                                  (~|lr_found ) &
                                  ( v_eoimode ? ( sel_gicv_dir |
                                                  sel_icc_dir_el1_v ):
                                                ( active_priorities_valid_rs & ( sel_gicv_aeoir |
                                                                                 sel_gicv_eoir |
                                                                                 sel_icc_eoir0_el1_v |
                                                                                 sel_icc_eoir1_el1_v ) ) );

  assign nxt_eoicount           = ( sel_gich_hcr | sel_ich_hcr_el2 ) ? cpo_wdata_i[31:27]:
                                  increment_eoicount                 ? ( eoicount + 1'b1 ):
                                                                       eoicount;

  assign nxt_ich_hcr_el2_tall0  = sel_ich_hcr_el2 ? cpo_wdata_i[11] : ich_hcr_el2_tall0;

  assign nxt_ich_hcr_el2_tall1  = sel_ich_hcr_el2 ? cpo_wdata_i[12] : ich_hcr_el2_tall1;

  assign nxt_ich_hcr_el2_tc     = sel_ich_hcr_el2 ? cpo_wdata_i[10] : ich_hcr_el2_tc;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ich_hcr_el2_tall0     <= 1'b0;
      ich_hcr_el2_tall1     <= 1'b0;
      ich_hcr_el2_tc        <= 1'b0;
      mntirq_vgrp0d_enable  <= 1'b0;
      mntirq_vgrp0e_enable  <= 1'b0;
      mntirq_vgrp1d_enable  <= 1'b0;
      mntirq_vgrp1e_enable  <= 1'b0;
      mntirq_lrenp_enable   <= 1'b0;
      mntirq_np_enable      <= 1'b0;
      mntirq_u_enable       <= 1'b0;
      vm_enable             <= 1'b0;
    end else if ( hcr_we ) begin
      ich_hcr_el2_tall0     <= nxt_ich_hcr_el2_tall0;
      ich_hcr_el2_tall1     <= nxt_ich_hcr_el2_tall1;
      ich_hcr_el2_tc        <= nxt_ich_hcr_el2_tc;
      mntirq_vgrp0d_enable  <= cpo_wdata_i[5];
      mntirq_vgrp0e_enable  <= cpo_wdata_i[4];
      mntirq_vgrp1d_enable  <= cpo_wdata_i[7];
      mntirq_vgrp1e_enable  <= cpo_wdata_i[6];
      mntirq_lrenp_enable   <= cpo_wdata_i[2];
      mntirq_np_enable      <= cpo_wdata_i[3];
      mntirq_u_enable       <= cpo_wdata_i[1];
      vm_enable             <= cpo_wdata_i[0];
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      eoicount <= {5{1'b0}};
    end else if ( eoicount_we ) begin
      eoicount <= nxt_eoicount;
    end

  // Architectural register(s)
  assign gich_hcr     = { eoicount,             // EOICount
                          {19{1'b0}},           // RES0
                          mntirq_vgrp1d_enable, // VGrp1DIE
                          mntirq_vgrp1e_enable, // VGrp1EIE
                          mntirq_vgrp0d_enable, // VGrp0DIE
                          mntirq_vgrp0e_enable, // VGrp0EIE
                          mntirq_np_enable,     // NPIE
                          mntirq_lrenp_enable,  // LRENPIE
                          mntirq_u_enable,      // UIE
                          vm_enable };          // En

  assign ich_hcr_el2  = { eoicount,             // EOICount
                          {13{1'b0}},           // RES0
                          1'b0,                 // TSEI - RES0 - Locally generated SEIs not supoorted
                          ich_hcr_el2_tall1,    // TALL1
                          ich_hcr_el2_tall0,    // TALL0
                          ich_hcr_el2_tc,       // TC
                          1'b0,                 // VARE - RES0 - not implemented
                          1'b0,                 // RES0
                          mntirq_vgrp1d_enable, // VGrp1DIE
                          mntirq_vgrp1e_enable, // VGrp1EIE
                          mntirq_vgrp0d_enable, // VGrp0DIE
                          mntirq_vgrp0e_enable, // VGrp0EIE
                          mntirq_np_enable,     // NPIE
                          mntirq_lrenp_enable,  // LRENPIE
                          mntirq_u_enable,      // UIE
                          vm_enable };          // En


  // ------------------------------------------------------
  // List Registers
  // ------------------------------------------------------

  // A CPU Interface implements a set of list registers.  The majority of fields
  // in each list register can only be changed by a direct access by the CPU. For
  // all common fields define the next data based on the type of register access
  // rather than the specific register.
  assign nxt_lr_grp         = ( sel_gich_lrn                        & cpo_wdata_i[30] ) |
                              ( sel_ich_lrcn                        & cpo_wdata_i[28] ) |
                              ( sel_ich_lrn_el2                     & cpo_wdata_i[60] );

  assign nxt_lr_hw          = ( sel_gich_lrn                        & cpo_wdata_i[31] ) |
                              ( sel_ich_lrcn                        & cpo_wdata_i[29] ) |
                              ( sel_ich_lrn_el2                     & cpo_wdata_i[61] );

  assign nxt_lr_physicalid  = ( {10{sel_gich_lrn}}                  & cpo_wdata_i[19:10] ) |
                              ( {10{sel_ich_lrcn}}                  & cpo_wdata_i[9:0] ) |
                              ( {10{sel_ich_lrn_el2}}               & cpo_wdata_i[41:32] );

  assign nxt_lr_priority    = ( {`CA53_GIC_PRI_W{sel_gich_lrn}}     & cpo_wdata_i[27:23] ) |
                              ( {`CA53_GIC_PRI_W{sel_ich_lrcn}}     & cpo_wdata_i[23:19] ) |
                              ( {`CA53_GIC_PRI_W{sel_ich_lrn_el2}}  & cpo_wdata_i[55:51] );

  // When a write is considered valid for a list register the next value can
  // be differentiated by the access mode alone, i.e. if it is a system
  // register operation.  Writes to ICH_LRCn will not enable the register.
  assign nxt_lr_virtualid  = cp_sys_i ? cpo_wdata_i[(`CA53_GIC_ID_W-1):0]:
                                        { {3{1'b0}} , ( nxt_lr_hw ? {3{1'b0}} : nxt_lr_physicalid[2:0] ), cpo_wdata_i[9:0] };

  generate

    for ( i = 0; i < `CA53_GIC_LR_CNT; i = i + 1 ) begin : list_register_n

      // Write the lower half of ICH_LRn_EL2
      assign ich_lr_we[i]     = wr_valid & ( sel_gich_lr[i] |
                                             sel_ich_lr[i] |
                                             sel_ich_lr_el2[i] );

      // Write the upper half of ICH_LRn_EL2
      assign ich_lrc_we[i]    = wr_valid & ( sel_gich_lr[i] |
                                             sel_ich_lr_el2[i] |
                                             sel_ich_lrc[i] );

      assign lr_state_wr[i]   = activate_lr[i] |
                                deactivate_lr[i] |
                                ( cp_gov_wenable_rs_i & ( sel_gich_lr[i] |
                                                          sel_ich_lr_el2[i] |
                                                          sel_ich_lrc[i] ) );

      assign nxt_lr_state[i]  = ( {2{activate_lr[i]}}       & ( spurious_virtual_id ? `CA53_GIC_LR_S_INVALID : `CA53_GIC_LR_S_ACTIVE ) ) |
                                ( {2{deactivate_lr[i]}}     & ( lr_state_pactive[i] ? `CA53_GIC_LR_S_PENDING : `CA53_GIC_LR_S_INVALID ) ) |
                                ( {2{cp_gov_wenable_rs_i}}  & ( ( {2{sel_gich_lr[i]}}    & cpo_wdata_i[29:28] ) |
                                                                ( {2{sel_ich_lr_el2[i]}} & cpo_wdata_i[63:62] ) |
                                                                ( {2{sel_ich_lrc[i]}}    & cpo_wdata_i[31:30] ) ) ) |
                                ( {2{~lr_state_wr[i]}}      & lr_state[i] );

      always @ ( posedge clk or negedge reset_n )
        if ( !reset_n ) begin
          lr_grp[i]         <= 1'b0;
          lr_hw[i]          <= 1'b0;
          lr_physicalid[i]  <= {`CA53_GIC_LR_PID_W{1'b0}};
          lr_priority[i]    <= {`CA53_GIC_PRI_W{1'b0}};
        end else if ( ich_lrc_we[i] ) begin
          lr_grp[i]         <= nxt_lr_grp;
          lr_hw[i]          <= nxt_lr_hw;
          lr_physicalid[i]  <= nxt_lr_physicalid;
          lr_priority[i]    <= nxt_lr_priority;
        end

      always @ ( posedge clk or negedge reset_n )
        if ( !reset_n ) begin
          lr_virtualid[i] <= {`CA53_GIC_ID_W{1'b0}};
        end else if ( ich_lr_we[i] ) begin
          lr_virtualid[i] <= nxt_lr_virtualid;
        end

      always @ ( posedge clk or negedge reset_n )
        if ( !reset_n ) begin
          lr_state[i] <= `CA53_GIC_LR_S_INVALID;
        end else if ( cp_valid_virtual ) begin
          lr_state[i] <= nxt_lr_state[i];
        end

      // List register state decoding
      assign lr_state_invalid[i] = lr_state[i] == `CA53_GIC_LR_S_INVALID;
      assign lr_state_active[i]  = lr_state[i] == `CA53_GIC_LR_S_ACTIVE;
      assign lr_state_pactive[i] = lr_state[i] == `CA53_GIC_LR_S_PACTIVE;
      assign lr_state_pending[i] = lr_state[i] == `CA53_GIC_LR_S_PENDING;

      // Used to calculate GICH_MISR.U.  For each list register determine if
      // all other list registers are marked as invalid.
      assign lr_underflow[i] = &( lr_state_invalid | ( {{(`CA53_GIC_LR_CNT-1){1'b0}},1'b1} << i[(`CA53_GIC_LR_CNT-1):0] ) );

      // NOTE: In GICv2 interrupt prioritization was based on priority alone.
      // In GICv3 prioritization takes the highest priority interrupt that
      // could be signaled to a CPU, i.e., the interrupt group enables are now
      // factored.
      assign lr_pending_valid[i] = lr_state_pending[i] & ( lr_grp[i] ? v_grp1_enable : v_grp0_enable );

      // Compare the list registers priority with a buffered version of RPR (RPR needs to be qualified)
      assign lr_priority_cmp[i] = ( lr_priority[i] == running_priority_rs ) & active_priorities_valid_rs;

      // Select the first list register in the Active or Active Pending states
      // with a matching virtual ID for DIR an EOIR writes.
      assign lr_found_cmp[i] = ( cp_gov_wdata_rs_i == lr_virtualid[i] ) & ( lr_state_active[i] | lr_state_pactive[i] );

      if ( i <= 0 ) begin : lr_found_0
        assign lr_found[i] = lr_found_cmp[i];
      end else begin : lr_found_n
        assign lr_found[i] = lr_found_cmp[i] & ( ~|lr_found_cmp[0+:i] );
      end

      always @ ( posedge clk )
        if ( wr_valid ) begin
          sel_deactivate_lr_pid[i] <= lr_found[i];
        end

      for ( j = 0; j < `CA53_GIC_LR_PID_W; j = j + 1 ) begin : sel_pid_mux_in
        assign deactivate_lr_pid_mux[j][i] = lr_physicalid[i][j] & sel_deactivate_lr_pid[i];
      end

      // The EOI bit in GICv2 and GICv3 at the same offset in the physical ID
      // field but is located in different position in the register:
      // - ICH_LRn_EL2[41]
      // - GICH_LRn[19]
      assign lr_physicalid_eoi[i] = lr_physicalid[i][9];

      // The Physical ID is spurious
      assign spurious_lr_pid[i] = &lr_physicalid[i][9:2];

      // Architectural register(s)
      assign gich_lr[i]     = { lr_hw[i],               // HW
                                lr_grp[i],              // Grp1
                                lr_state[i],            // State
                                lr_priority[i],         // Priority
                                {3{1'b0}},              // RES0
                                lr_physicalid[i],       // PhysicalID
                                lr_virtualid[i][9:0] }; // VirtualID

      // NOTE:  ICH_LRn   == ICH_LRn_EL2[31:0]
      //        ICH_LRCn  == ICH_LRn_EL2[63:32]
      assign ich_lr_el2[i]  = { lr_state[i],            // State
                                lr_hw[i],               // HW
                                lr_grp[i],              // Grp1
                                {4{1'b0}},              // RES0
                                lr_priority[i],         // Priority
                                {3{1'b0}},              // Priority (unimplemented)
                                {6{1'b0}},              // RES0
                                lr_physicalid[i],       // PhysicalID
                                {16{1'b0}},             // VirtualID (unimplemented)
                                lr_virtualid[i] };      // VirtualID

    end // list_register_n

  endgenerate

  generate
    for ( j = 0; j < `CA53_GIC_LR_PID_W; j = j + 1 ) begin : sel_pid_mux_out
      assign deactivate_lr_pid[j] = |deactivate_lr_pid_mux[j];
    end
  endgenerate


  // ------------------------------------------------------
  // Maintenance Interrupt Status Register
  // ------------------------------------------------------

  assign mntirq_eoi    =                         |gich_eisr0_lrsb;  // At least one list register is in the EOI state
  assign mntirq_lrenp  = mntirq_lrenp_enable  &  |eoicount;         // List register Entry Not Present
  assign mntirq_np     = mntirq_np_enable     & ~|lr_state_pending; // No list registers are in the pending state
  assign mntirq_u      = mntirq_u_enable      &  |lr_underflow;     // Underflow - none or one of the list registers are valid
  assign mntirq_vgrp0d = mntirq_vgrp0d_enable &  ~v_grp0_enable;    // Group zero interrupts are disabled
  assign mntirq_vgrp0e = mntirq_vgrp0e_enable &   v_grp0_enable;    // Group zero interrupts are enabled
  assign mntirq_vgrp1d = mntirq_vgrp1d_enable &  ~v_grp1_enable;    // Group one interrupts are disabled
  assign mntirq_vgrp1e = mntirq_vgrp1e_enable &   v_grp1_enable;    // Group one interrupts are enabled

  // Architectural register(s)
  // NOTE: GICH_MISR (GICv2) == ICH_MISR_EL2 (GICv3)
  assign gich_misr  = { {24{1'b0}},    // RES0
                        mntirq_vgrp1d, // VGrp1D
                        mntirq_vgrp1e, // VGrp1E
                        mntirq_vgrp0d, // VGrp0D
                        mntirq_vgrp0e, // VGrp0E
                        mntirq_np,     // NP
                        mntirq_lrenp,  // LRENP
                        mntirq_u,      // U
                        mntirq_eoi };  // EOI


  // ------------------------------------------------------
  // Priority Mask Register
  // ------------------------------------------------------

  assign nxt_v_priority_mask  = ( {`CA53_GIC_PRI_W{sel_gich_vmcr}}      & cpo_wdata_i[31:27] ) |
                                ( {`CA53_GIC_PRI_W{sel_gicv_pmr}}       & cpo_wdata_i[7:3] ) |
                                ( {`CA53_GIC_PRI_W{sel_icc_pmr_el1_v}}  & cpo_wdata_i[7:3] ) |
                                ( {`CA53_GIC_PRI_W{sel_ich_vmcr_el2}}   & cpo_wdata_i[31:27] );

  assign v_priority_mask_we   = wr_valid & ( sel_gich_vmcr |
                                             sel_gicv_pmr |
                                             sel_icc_pmr_el1_v |
                                             sel_ich_vmcr_el2 );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      v_priority_mask <= {`CA53_GIC_PRI_W{1'b0}};
    end else if ( v_priority_mask_we ) begin
      v_priority_mask <= nxt_v_priority_mask;
    end

  // Architectural register(s)
  // NOTE: GICV_PMR (GICv2) == ICC_PMR_EL1 (GICv3)
  assign gicv_pmr = { {24{1'b0}},       // Reserved (RES0)
                      v_priority_mask,  // Priority
                      {3{1'b0}} };      // Pruority (Unused)


  // ------------------------------------------------------
  // Running Priority Register
  // ------------------------------------------------------

  assign gicv_rpr_priority = { running_priority , {3{1'b0}} } | {8{ ~active_priorities_valid }};

  // Architectural register(s)
  // NOTE: GICV_RPR (GICv2) == ICC_RPR_EL1 (GICv3)
  assign gicv_rpr = { {24{1'b0}},           // Reserved (RES0)
                      gicv_rpr_priority };  // Priority


  // ------------------------------------------------------
  // Virtual Machine Control Register
  // ------------------------------------------------------

  // Architectural register(s)
  assign gich_vmcr    = { v_priority_mask,        // VMPriMask
                          {3{1'b0}},              // RES0
                          v_binary_point_grp0,    // VMBP
                          v_binary_point_grp1,    // VMABP
                          {8{1'b0}},              // RES0
                          v_eoimode,              // VEM
                          {4{1'b0}},              // RES0
                          v_common_binary_point,  // VMCBPR
                          raw_v_fiq_enable,       // VMFIQEn
                          raw_v_ackctl,           // VMAckCtl
                          v_grp1_enable,          // VMGrp1En
                          v_grp0_enable };        // VMGrp0En

  assign ich_vmcr_el2 = { v_priority_mask,        // VPMR
                          {3{1'b0}},              // RES0
                          v_binary_point_grp0,    // VMBP
                          v_binary_point_grp1,    // VMABP
                          {8{1'b0}},              // RES0
                          v_eoimode,              // VEM
                          {4{1'b0}},              // RES0
                          v_common_binary_point,  // VCBPR
                          v_fiq_enable,           // VFIQEn
                          v_ackctl,               // VAckCtl
                          v_grp1_enable,          // VENG1
                          v_grp0_enable };        // VENG0


  // ------------------------------------------------------
  // VGIC Type Register
  // ------------------------------------------------------

  // Architectural register(s)
  assign gich_vtr     = { ( 3'd`CA53_GIC_PRI_W-1'b1 ),    // PRIbits
                          ( 3'd`CA53_GIC_PRI_W-1'b1 ),    // PREbits
                          {20{1'b0}},                     // RES0
                          ( 6'd`CA53_GIC_LR_CNT-1'b1 ) }; // ListRegs

  assign ich_vtr_el2  = { ( 3'd`CA53_GIC_PRI_W-1'b1 ),    // PRIbits
                          ( 3'd`CA53_GIC_PRI_W-1'b1 ),    // PREbits
                          { 3{1'b0}},                     // IDbits
                          { 1{1'b0}},                     // SEIS - RES0 - Local SEIs not supported
                          { 1{1'b0}},                     // A3V - RES0 - Affinity level 3 not supported
                          {16{1'b0}},                     // RES0
                          ( 5'd`CA53_GIC_LR_CNT-1'b1 ) }; // ListRegs


  // ------------------------------------------------------
  // Read Data
  // ------------------------------------------------------

  assign rdata_word_low   = ( {32{sel_gich_apr}}          & gich_apr ) |
                            ( {32{sel_gich_eisr0}}        & gich_eisr0 ) |
                            ( {32{sel_gich_elsr0}}        & gich_elsr0 ) |
                            ( {32{sel_gich_hcr}}          & gich_hcr ) |
                            ( {32{sel_gich_lr[0]}}        & gich_lr[0] ) |
                            ( {32{sel_gich_lr[2]}}        & gich_lr[2] ) |
                            ( {32{sel_gich_misr}}         & gich_misr ) |
                            ( {32{sel_gich_vmcr}}         & gich_vmcr ) |
                            ( {32{sel_gicv_ahppir}}       & gicv_ahppir ) |
                            ( {32{sel_gicv_aiar}}         & gicv_aiar ) |
                            ( {32{sel_gicv_apr}}          & gich_apr ) |
                            ( {32{sel_gicv_bpr}}          & gicv_bpr ) |
                            ( {32{sel_gicv_ctlr}}         & gicv_ctlr ) |
                            ( {32{sel_gicv_hppir}}        & gicv_hppir ) |
                            ( {32{sel_icc_bpr0_el1_v}}    & gicv_bpr ) |
                            ( {32{sel_icc_bpr1_el1_v}}    & icc_bpr1_el1_v ) |
                            ( {32{sel_icc_ctlr_el1_v}}    & icc_ctlr_el1_v ) |
                            ( {32{sel_icc_grpen0_el1_v}}  & icc_grpen0_el1_v ) |
                            ( {32{sel_icc_grpen1_el1_v}}  & icc_grpen1_el1_v ) |
                            ( {32{sel_icc_hppir0_el1_v}}  & icc_hppir0_el1_v ) |
                            ( {32{sel_icc_hppir1_el1_v}}  & gicv_ahppir ) |
                            ( {32{sel_icc_iar0_el1_v}}    & icc_iar0_el1_v ) |
                            ( {32{sel_icc_iar1_el1_v}}    & gicv_aiar ) |
                            ( {32{sel_icc_pmr_el1_v}}     & gicv_pmr ) |
                            ( {32{sel_icc_rpr_el1_v}}     & gicv_rpr ) |
                            ( {32{sel_ich_ap0r0_el2}}     & ich_ap0r0_el2 ) |
                            ( {32{sel_ich_ap1r0_el2}}     & gich_apr ) |
                            ( {32{sel_ich_eisr_el2}}      & gich_eisr0 ) |
                            ( {32{sel_ich_elsr_el2}}      & gich_elsr0 ) |
                            ( {32{sel_ich_hcr_el2}}       & ich_hcr_el2 ) |
                            ( {32{sel_ich_lr[0]}}         & ich_lr_el2[0][31:0] ) |
                            ( {32{sel_ich_lr[1]}}         & ich_lr_el2[1][31:0] ) |
                            ( {32{sel_ich_lr[2]}}         & ich_lr_el2[2][31:0] ) |
                            ( {32{sel_ich_lr[3]}}         & ich_lr_el2[3][31:0] ) |
                            ( {32{sel_ich_lr_el2[0]}}     & ich_lr_el2[0][31:0] ) |
                            ( {32{sel_ich_lr_el2[1]}}     & ich_lr_el2[1][31:0] ) |
                            ( {32{sel_ich_lr_el2[2]}}     & ich_lr_el2[2][31:0] ) |
                            ( {32{sel_ich_lr_el2[3]}}     & ich_lr_el2[3][31:0] ) |
                            ( {32{sel_ich_lrc[0]}}        & ich_lr_el2[0][63:32] ) |
                            ( {32{sel_ich_lrc[1]}}        & ich_lr_el2[1][63:32] ) |
                            ( {32{sel_ich_lrc[2]}}        & ich_lr_el2[2][63:32] ) |
                            ( {32{sel_ich_lrc[3]}}        & ich_lr_el2[3][63:32] ) |
                            ( {32{sel_ich_misr_el2}}      & gich_misr ) |
                            ( {32{sel_ich_vmcr_el2}}      & ich_vmcr_el2 ) |
                            ( {32{sel_ich_vtr_el2}}       & ich_vtr_el2 );

  assign rdata_word_high  = ( {32{sel_gich_lr[1]}}    & gich_lr[1] ) |
                            ( {32{sel_gich_lr[3]}}    & gich_lr[3] ) |
                            ( {32{sel_gich_vtr}}      & gich_vtr ) |
                            ( {32{sel_gicv_abpr}}     & gicv_abpr ) |
                            ( {32{sel_gicv_iar}}      & gicv_iar ) |
                            ( {32{sel_gicv_pmr}}      & gicv_pmr ) |
                            ( {32{sel_gicv_rpr}}      & gicv_rpr ) |
                            ( {32{sel_ich_lr_el2[0]}} & ich_lr_el2[0][63:32] ) |
                            ( {32{sel_ich_lr_el2[1]}} & ich_lr_el2[1][63:32] ) |
                            ( {32{sel_ich_lr_el2[2]}} & ich_lr_el2[2][63:32] ) |
                            ( {32{sel_ich_lr_el2[3]}} & ich_lr_el2[3][63:32] );

  assign vcpu_rdata_o = { rdata_word_high , rdata_word_low };


  // ------------------------------------------------------
  // Active Priorities Data Path
  // ------------------------------------------------------

  // Retrieve all of the acknowledged interrupt priorities
  assign active_priorities = gich_apr | ich_ap0r0_el2;

  // Determine if any interrupts are in the acknowledged state
  assign active_priorities_valid = |active_priorities;

  // Highest active priority
  generate
    for ( i = 0; i < (1<<`CA53_GIC_PRI_W) ; i = i + 1 ) begin : hap
      if ( i == 0 ) begin : bit_lsb
        assign highest_active_priorities[0] = active_priorities[0];
      end // bit_lsb
      else begin : bit_n
        assign highest_active_priorities[i] = active_priorities[i] & ( ~|active_priorities[0+:i] );
      end // bit_n
    end // hap
  endgenerate

  // Running Priority
  // Convert the zero-one-hot encoding of the highest active priorities
  // to a decimal encoding for the Running Priority.
  generate
    // Generate a set of 5-bit decimal numbers - one for each priority level - and
    // only keep the one that is for the highest active priority.
    for ( i = 0; i < (1<<`CA53_GIC_PRI_W); i = i + 1 ) begin : rp_valid_values
      assign running_priority_values[i] = {`CA53_GIC_PRI_W{highest_active_priorities[i]}} & i[(`CA53_GIC_PRI_W-1):0];
    end // rp_valid_values
    // Calculate the Running Priority one bit at a time by performing 5x32-bit OR operations.
    for ( j = 0; j < `CA53_GIC_PRI_W; j = j + 1 ) begin : rp_values_rotate_outer
      for ( i = 0; i < (1<<`CA53_GIC_PRI_W); i = i + 1 ) begin : rp_values_rotate_inner
        assign running_priority_values_rotated[j][i] = running_priority_values[i][j];
      end // rp_values_rotate_inner
      assign running_priority[j] = |running_priority_values_rotated[j];
    end // rp_values_rotate_outer
  endgenerate

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      active_priorities_valid_rs  <= 1'b0;
      running_priority_rs         <= {`CA53_GIC_PRI_W{1'b0}};
    end else if ( cp_last_valid_virtual ) begin
      active_priorities_valid_rs  <= active_priorities_valid;
      running_priority_rs         <= running_priority;
    end


  // ------------------------------------------------------
  // Interrupt Prioritisation and Signaling
  // ------------------------------------------------------

  // Interrupt prioritisation occurs over two stages.  A one-hot encoding of
  // the highest priority list register is generated, which may select an invalid
  // list register if none are valid.  Unlike GICv2, GICv3 prioritises the
  // highest priority interrupt for an enabled group.

  assign sel_hp_lr1nlr0         = lr_pending_valid[1] &
                                    ( ( lr_priority[1] < lr_priority[0] ) |
                                      ~lr_pending_valid[0] );

  assign sel_hp_lr1lr0_priority = sel_hp_lr1nlr0 ? lr_priority[1] : lr_priority[0];
  assign sel_hp_lr1lr0_valid    = sel_hp_lr1nlr0 ? lr_pending_valid[1] : lr_pending_valid[0];

  assign sel_hp_lr3nlr2         = lr_pending_valid[3] &
                                    ( ( lr_priority[3] < lr_priority[2] ) |
                                      ~lr_pending_valid[2] );

  assign sel_hp_lr3lr2_priority = sel_hp_lr3nlr2 ? lr_priority[3] : lr_priority[2];
  assign sel_hp_lr3lr2_valid    = sel_hp_lr3nlr2 ? lr_pending_valid[3] : lr_pending_valid[2];

  assign sel_hp_lr3lr2nlr1lr0   = sel_hp_lr3lr2_valid &
                                    ( ( sel_hp_lr3lr2_priority < sel_hp_lr1lr0_priority ) |
                                      ~sel_hp_lr1lr0_valid );

  // sel_hp_lr should be zero-one-hot
  assign nxt_sel_hp_lr  = { (  sel_hp_lr3lr2nlr1lr0 &  sel_hp_lr3nlr2 ),
                            (  sel_hp_lr3lr2nlr1lr0 & ~sel_hp_lr3nlr2 ),
                            ( ~sel_hp_lr3lr2nlr1lr0 &  sel_hp_lr1nlr0 ),
                            ( ~sel_hp_lr3lr2nlr1lr0 & ~sel_hp_lr1nlr0 & lr_pending_valid[0] ) };

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      sel_hp_lr <= {`CA53_GIC_LR_CNT{1'b0}};
    end else if ( cp_last_valid_virtual ) begin
      sel_hp_lr <= nxt_sel_hp_lr;
    end


  // At the completion of the first stage of list register comparisons the IPR
  // is compared with both results.  This is to allow the IPR comparison to be
  // brought forward a cycle.  However, the result of the IPR comparison may
  // become invalid on the next cycle as the IPR may move to a non-Pending state
  // after the comparison has been performed.

  assign sel_hp_iprnlr1lr0  = ipr_pending_valid &
                              ( ( ipr_priority < sel_hp_lr1lr0_priority ) |
                                ~sel_hp_lr1lr0_valid );

  assign sel_hp_iprnlr3lr2  = ipr_pending_valid &
                              ( ( ipr_priority < sel_hp_lr3lr2_priority ) |
                                ~sel_hp_lr3lr2_valid );

  assign nxt_sel_hp_ipr     = sel_hp_iprnlr1lr0 & sel_hp_iprnlr3lr2;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      sel_hp_ipr <= 1'b0;
    end else begin
      sel_hp_ipr <= nxt_sel_hp_ipr;
    end

  // Select the properties of the highest priority pending interrupt

  assign sel_hp_ipr_valid     = sel_hp_ipr & ipr_pending_valid;

  assign sel_hp_int           = { sel_hp_ipr_valid , ( sel_hp_ipr_valid ? {`CA53_GIC_LR_CNT{1'b0}} : sel_hp_lr ) };

  assign sel_hp_int_grp       = sel_hp_ipr_valid ? ipr_grp : |( sel_hp_lr & lr_grp );

  assign sel_hp_int_id        = sel_hp_ipr_valid ? ipr_id : ( ( {`CA53_GIC_ID_W{sel_hp_lr[0]}} & lr_virtualid[0] ) |
                                                              ( {`CA53_GIC_ID_W{sel_hp_lr[1]}} & lr_virtualid[1] ) |
                                                              ( {`CA53_GIC_ID_W{sel_hp_lr[2]}} & lr_virtualid[2] ) |
                                                              ( {`CA53_GIC_ID_W{sel_hp_lr[3]}} & lr_virtualid[3] ) );

  assign sel_hp_int_priority  = sel_hp_ipr_valid ? ipr_priority : ( ( {`CA53_GIC_PRI_W{sel_hp_lr[0]}} & lr_priority[0] ) |
                                                                    ( {`CA53_GIC_PRI_W{sel_hp_lr[1]}} & lr_priority[1] ) |
                                                                    ( {`CA53_GIC_PRI_W{sel_hp_lr[2]}} & lr_priority[2] ) |
                                                                    ( {`CA53_GIC_PRI_W{sel_hp_lr[3]}} & lr_priority[3] ) );

  assign sel_hp_int_valid     = sel_hp_ipr_valid | ( |( sel_hp_lr & lr_pending_valid ) );

  // Determine the one-hot encoding of the active priority
  assign acknowlegde_priorities = { {((1<<`CA53_GIC_PRI_W)-1){1'b0}} , 1'b1 } << sel_hp_int_priority;

  // The interrupt that is being acknowledged has a spurious virtual interrupt
  // ID.  This does not stop the interrupt from being signaled but suppresses
  // modifications to the Active Priorities Registers and will return the ID
  // unmodified via reads of the Interrupt Acknoweldge Register.
  assign spurious_virtual_id = ( ~|sel_hp_int_id[15:13] ) & ( &sel_hp_int_id[9:2] );

  // Decode ABPR to a priority mask (3<=ABPR<=7)
  always @*
    case ( v_binary_point_grp1 )
      3'b011 :  v_binary_point_grp1_decoded = 5'b11111;
      3'b100 :  v_binary_point_grp1_decoded = 5'b11110;
      3'b101 :  v_binary_point_grp1_decoded = 5'b11100;
      3'b110 :  v_binary_point_grp1_decoded = 5'b11000;
      3'b111 :  v_binary_point_grp1_decoded = 5'b10000;
      default : v_binary_point_grp1_decoded = {5{1'bx}};
    endcase

  // Decode BPR to a priority mask (2<=BPR<=7)
  always @*
    case ( v_binary_point_grp0 )
      3'b010 :  v_binary_point_grp0_decoded = 5'b11111;
      3'b011 :  v_binary_point_grp0_decoded = 5'b11110;
      3'b100 :  v_binary_point_grp0_decoded = 5'b11100;
      3'b101 :  v_binary_point_grp0_decoded = 5'b11000;
      3'b110 :  v_binary_point_grp0_decoded = 5'b10000;
      3'b111 :  v_binary_point_grp0_decoded = 5'b00000;
      default : v_binary_point_grp0_decoded = {5{1'bx}};
    endcase

  // Select the appropriate decode BPR based on interrupt group and CBPR
  assign binary_point_decoded = ( sel_hp_int_grp & ~v_common_binary_point ) ? v_binary_point_grp1_decoded:
                                                                              v_binary_point_grp0_decoded;

  // Check if the interrupt's priority qualifies it to preempt currently active
  // interrupts
  assign preemption_valid = sel_hp_int_priority < ( running_priority & binary_point_decoded );

  // Check if the interrupt's priority is not being masked.
  assign priority_unmasked = sel_hp_int_priority < v_priority_mask;

  // The interrupt can be signaled and activated
  assign signal_interrupt = vm_enable &
                            ( ~active_priorities_valid | preemption_valid ) &
                            priority_unmasked &
                            sel_hp_int_valid;

  // Allocation to FIQ and IRQ for the Virtual CPU Interface does not factor
  // the CPU's exception level or security state
  assign cpuif_vfiq =    v_fiq_enable & ~sel_hp_int_grp   & signal_interrupt;
  assign cpuif_virq = ( ~v_fiq_enable |  sel_hp_int_grp ) & signal_interrupt;


  // ------------------------------------------------------
  // Maintenance interrupt generation
  // ------------------------------------------------------

  // Maintenance interrupt generation (maintenance interrupts are active low)
  assign nxt_nvcpumntirq  = ~( vm_enable & ( mntirq_eoi |
                                             mntirq_vgrp0d |
                                             mntirq_vgrp0e |
                                             mntirq_vgrp1d |
                                             mntirq_vgrp1e |
                                             mntirq_lrenp |
                                             mntirq_np |
                                             mntirq_u ) );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      nvcpumntirq <= 1'b1;
    end else if ( cp_last_valid_virtual ) begin
      nvcpumntirq <= nxt_nvcpumntirq;
    end


  // ------------------------------------------------------
  // Upstream Write Packet
  // ------------------------------------------------------

  // Upstream Writes occur any time a Virtual CPU Interface is writen that can
  // modify the interrupt group enables.
  assign send_upstream_wr_enables_v_o = wr_valid & ( sel_gich_vmcr |
                                                     sel_gicv_ctlr |
                                                     sel_icc_grpen0_el1_v |
                                                     sel_icc_grpen1_el1_v |
                                                     sel_ich_vmcr_el2 );


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign activate_not_release_v_o     = ipr_state[0];
  assign activate_release_v_pending_o = ipr_state[1];
  assign cpuif_vfiq_o                 = cpuif_vfiq;
  assign cpuif_virq_o                 = cpuif_virq;
  assign deactivate_lr_pid_o          = deactivate_lr_pid;
  assign gic_ich_hcr_el2_tall0_o      = ich_hcr_el2_tall0;
  assign gic_ich_hcr_el2_tall1_o      = ich_hcr_el2_tall1;
  assign gic_ich_hcr_el2_tc_o         = ich_hcr_el2_tc;
  assign ipr_empty_v_o                = ipr_empty;
  assign nvcpumntirq_o                = nvcpumntirq;
  assign nxt_vset_recv_visible_o      = lst_ipr_en;
  assign v_grp0_enable_o              = v_grp0_enable;
  assign v_grp1_enable_o              = v_grp1_enable;
  assign ipr_id_v_o                   = ipr_id;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ------------------------------------------------------
  // IPR checks
  // ------------------------------------------------------

  reg [(IPR_STATE_W-1):0] ovl_last_ipr_state;
  reg                     ovl_last_vset_recv;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_ipr_state  <= IPR_S_EMPTY;
      ovl_last_vset_recv  <= 1'b0;
    end else begin
      ovl_last_ipr_state  <= ipr_state;
      ovl_last_vset_recv  <= vset_recv_i;
    end

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Packet state must always be known")
  u_ovl_state_known (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr ((ipr_state==IPR_S_EMPTY)|
                                 (ipr_state==IPR_S_PENDING)|
                                 (ipr_state==IPR_S_ACKNOWLEDGED)|
                                 (ipr_state==IPR_S_RELEASED)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only a pending interrupt can be acknowledged")
  u_ovl_state_activate_interrupt_ipr (.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr (activate_interrupt_ipr),
                                      .consequent_expr ((ipr_state==IPR_S_PENDING)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only an interrupt being sent can be sent")
  u_ovl_state_activate_release_v_sent (.clk             (clk),
                                       .reset_n         (reset_n),
                                       .antecedent_expr (activate_release_v_sent_i),
                                       .consequent_expr ((ipr_state==IPR_S_ACKNOWLEDGED)|
                                                         (ipr_state==IPR_S_RELEASED)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only a enabled and supported interrupt can be acknowledged")
  u_ovl_valid_activate_interrupt_ipr (.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr (activate_interrupt_ipr),
                                      .consequent_expr (ipr_enabled));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Zero-One-Hot: quiesce, vclear, vset")
  u_ovl_zoh_quiesce_vclear_vset (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .test_expr ({quiesce_recv_i,vclear_recv_i,vset_recv_i}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The same write should not Set and Release the interrupt")
  u_ovl_changed_vset_recv_i (.clk             (clk),
                             .reset_n         (reset_n),
                             .antecedent_expr ((ovl_last_ipr_state==IPR_S_EMPTY) & ovl_last_vset_recv),
                             .consequent_expr (~vset_recv_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Writes to the interrupt packet register are only observed when the register is EMPTY")
  u_ovl_unchanged_vset_recv_i (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr ((ovl_last_ipr_state!=IPR_S_EMPTY) & ovl_last_vset_recv),
                               .consequent_expr (vset_recv_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: activate_interrupt")
  u_ovl_fsm_x_activate_interrupt_ipr (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .qualifier (1'b1),
                                      .test_expr (activate_interrupt_ipr));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: activate_release_sent_i")
  u_ovl_fsm_x_activate_release_v_sent_i (.clk       (clk),
                                         .reset_n   (reset_n),
                                         .qualifier (1'b1),
                                         .test_expr (activate_release_v_sent_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: ipr_enabled")
  u_ovl_fsm_x_ipr_enabled (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (ipr_state==IPR_S_PENDING),
                           .test_expr (ipr_enabled));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: vclear_recv_valid")
  u_ovl_fsm_x_vclear_recv_valid (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (ipr_state==IPR_S_PENDING),
                                 .test_expr (vclear_recv_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: vset_recv_i")
  u_ovl_fsm_x_vset_recv_i (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (vset_recv_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: quiesce_recv_i")
  u_ovl_fsm_x_quiesce_recv_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (quiesce_recv_i));


  // ------------------------------------------------------
  // GIC Register State
  // ------------------------------------------------------

  // Only one register at a time can be accessed
  assert_zero_one_hot #(`OVL_FATAL, 59, `OVL_ASSERT, "GIC Virtual CPU Interface: register selects are zero-one-hot")
  u_ovl_zoh_register_enable_event (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ({59{cp_valid_virtual}} & { sel_gich_apr,
                                                                          sel_gich_eisr0,
                                                                          sel_gich_elsr0,
                                                                          sel_gich_hcr,
                                                                          sel_gich_lr[0],
                                                                          sel_gich_lr[1],
                                                                          sel_gich_lr[2],
                                                                          sel_gich_lr[3],
                                                                          sel_gich_misr,
                                                                          sel_gich_vmcr,
                                                                          sel_gich_vtr,
                                                                          sel_gicv_abpr,
                                                                          sel_gicv_aeoir,
                                                                          sel_gicv_ahppir,
                                                                          sel_gicv_aiar,
                                                                          sel_gicv_apr,
                                                                          sel_gicv_bpr,
                                                                          sel_gicv_ctlr,
                                                                          sel_gicv_dir,
                                                                          sel_gicv_eoir,
                                                                          sel_gicv_hppir,
                                                                          sel_gicv_iar,
                                                                          sel_gicv_pmr,
                                                                          sel_gicv_rpr,
                                                                          sel_icc_bpr0_el1_v,
                                                                          sel_icc_bpr1_el1_v,
                                                                          sel_icc_ctlr_el1_v,
                                                                          sel_icc_dir_el1_v,
                                                                          sel_icc_eoir0_el1_v,
                                                                          sel_icc_eoir1_el1_v,
                                                                          sel_icc_grpen0_el1_v,
                                                                          sel_icc_grpen1_el1_v,
                                                                          sel_icc_hppir0_el1_v,
                                                                          sel_icc_hppir1_el1_v,
                                                                          sel_icc_iar0_el1_v,
                                                                          sel_icc_iar1_el1_v,
                                                                          sel_icc_pmr_el1_v,
                                                                          sel_icc_rpr_el1_v,
                                                                          sel_ich_ap0r0_el2,
                                                                          sel_ich_ap1r0_el2,
                                                                          sel_ich_eisr_el2,
                                                                          sel_ich_elsr_el2,
                                                                          sel_ich_hcr_el2,
                                                                          sel_ich_lr[0],
                                                                          sel_ich_lr[1],
                                                                          sel_ich_lr[2],
                                                                          sel_ich_lr[3],
                                                                          sel_ich_lr_el2[0],
                                                                          sel_ich_lr_el2[1],
                                                                          sel_ich_lr_el2[2],
                                                                          sel_ich_lr_el2[3],
                                                                          sel_ich_lrc[0],
                                                                          sel_ich_lrc[1],
                                                                          sel_ich_lrc[2],
                                                                          sel_ich_lrc[3],
                                                                          sel_ich_misr_el2,
                                                                          sel_ich_vmcr_el2,
                                                                          sel_ich_vtr_el2}));

  // Active priorities should never be asserted for multiple groups at the same priority level
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "GIC Virtual CPU Interface: active priorities asserted for multiple groups")
  u_ovl_active_priorities (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr (|(gich_apr & ich_ap0r0_el2)));

  // Active priorities registers should only ever have one asserted write enable
  assert_zero_one_hot #(`OVL_FATAL, 4, `OVL_ASSERT, "GIC Virtual CPU Interface: active_priorities write enables must be zero-one-hot")
  u_ovl_zoh_active_priorities_we (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .test_expr ({ sel_gich_apr      & wr_valid,
                                                sel_gicv_apr      & wr_valid,
                                                sel_ich_ap0r0_el2 & wr_valid,
                                                sel_ich_ap1r0_el2 & wr_valid}));

  // Binary point registers are in range
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Virtual CPU Interface: v_binary_point_grp1 not in range")
  u_ovl_v_binary_point_grp1_range (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (v_binary_point_grp1 >= 3'd3));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Virtual CPU Interface: v_binary_point_grp0 not in range")
  u_ovl_v_binary_point_grp0_range (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (v_binary_point_grp0 >= 3'd2));

  // The Highest Priorities must be zero-one-hot encoded for Running Priority generation
  assert_zero_one_hot #(`OVL_FATAL, (1<<`CA53_GIC_PRI_W), `OVL_ASSERT, "GIC Virtual CPU Interface: highest_active_priorities must zero-one-hot")
  u_ovl_zoh_highest_active_priorities (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .test_expr (highest_active_priorities));

  // The highest priority list register select is one hot. However it may be
  // zero on the first cycle after reset.
  assert_zero_one_hot #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "GIC Virtual CPU Interface: Highest priority list register select is zero-one-hot")
  u_ovl_zoh_sel_hp_lr (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr (sel_hp_lr));

  // Virtual IRQs are zero one hot
  assert_zero_one_hot #(`OVL_FATAL, 2, `OVL_ASSERT, "GIC Virtual CPU Interface: FIQ and IRQ are zero-one-hot")
  u_ovl_zoh_fiq_irq (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr ({cpuif_vfiq,cpuif_virq}));


  // ------------------------------------------------------
  // Virtual machine should not generate interrupts when it is disabled
  // ------------------------------------------------------

  reg ovl_last_vm_enable;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_vm_enable <= 1'b0;
    end else begin
      ovl_last_vm_enable <= vm_enable;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"GIC Virtual CPU Interface: VM disabled and FIQ must be deasserted")
  ovl_implication_disabled_fiq (.clk              (clk),
                                .reset_n          (reset_n),
                                .antecedent_expr  (~vm_enable),
                                .consequent_expr  (~cpuif_vfiq));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"GIC Virtual CPU Interface: VM disabled and IRQ must be deasserted")
  ovl_implication_disabled_irq (.clk              (clk),
                                .reset_n          (reset_n),
                                .antecedent_expr  (~vm_enable),
                                .consequent_expr  (~cpuif_virq));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"GIC Virtual CPU Interface: VM disabled and MNTIRQ must be deasserted")
  ovl_implication_disabled_mntirq (.clk              (clk),
                                   .reset_n          (reset_n),
                                   .antecedent_expr  (~ovl_last_vm_enable),
                                   .consequent_expr  (nvcpumntirq));


  // ------------------------------------------------------
  // List registers
  // ------------------------------------------------------

  // An Activation event can only occur to a single list register at a time
  assert_zero_one_hot #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "GIC Virtual CPU Interface: activate_lr is zero-one-hot")
  u_ovl_zoh_activate_lr (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr ({`CA53_GIC_LR_CNT{cp_valid_virtual}} & activate_lr));

  // A Deactivate event can only occur to a single list register at a time
  assert_zero_one_hot #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "GIC Virtual CPU Interface: deactivate_lr is zero-one-hot")
  u_ovl_zoh_deactivate_lr (.clk       (clk),
                           .reset_n   (reset_n),
                           .test_expr ({`CA53_GIC_LR_CNT{cp_valid_virtual}} & deactivate_lr));

  // Only a single list register can be selected at a time and is only
  // ever valid during a write.
  assert_zero_one_hot #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "GIC Virtual CPU Interface: lr_found is zero-one-hot")
  u_ovl_zoh_lr_found (.clk       (clk),
                      .reset_n   (reset_n),
                      .test_expr ({`CA53_GIC_LR_CNT{wr_valid}} & lr_found));

  // Only a single list register can be writen at a time
  assert_zero_one_hot #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "GIC Virtual CPU Interface: lr_state_wr is zero-one-hot")
  u_ovl_zoh_lr_state_wr (.clk       (clk),
                         .reset_n   (reset_n),
                         .test_expr ({`CA53_GIC_LR_CNT{cp_valid_virtual}} & lr_state_wr));

  // List register state transitions
  generate

    for ( i = 0; i < `CA53_GIC_LR_CNT; i = i + 1 ) begin : ovl_list_register_n

      assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Virtual CPU Interface: lr_state is not valid")
      u_ovl_valid_lr_state (.clk       (clk),
                            .reset_n   (reset_n),
                            .test_expr ( ( lr_state[i] == `CA53_GIC_LR_S_INVALID ) |
                                         ( lr_state[i] == `CA53_GIC_LR_S_PENDING ) |
                                         ( lr_state[i] == `CA53_GIC_LR_S_ACTIVE )  |
                                         ( lr_state[i] == `CA53_GIC_LR_S_PACTIVE ) ) );

      assert_implication #(`OVL_FATAL,`OVL_ASSERT,"GIC Virtual CPU Interface: activate_lr can only be asserted for an active interrupt")
      ovl_implication_activate_lr (.clk              (clk),
                                   .reset_n          (reset_n),
                                   .antecedent_expr  (cp_valid_virtual & activate_lr[i]),
                                   .consequent_expr  (lr_state[i] == `CA53_GIC_LR_S_PENDING));

      assert_implication #(`OVL_FATAL,`OVL_ASSERT,"GIC Virtual CPU Interface: deactivate_lr can only be asserted for an active interrupt")
      ovl_implication_deactivate_lr (.clk              (clk),
                                     .reset_n          (reset_n),
                                     .antecedent_expr  (cp_valid_virtual & deactivate_lr[i]),
                                     .consequent_expr  ( ( lr_state[i] == `CA53_GIC_LR_S_ACTIVE ) |
                                                         ( lr_state[i] == `CA53_GIC_LR_S_PACTIVE ) ));
    end

  endgenerate


  // ------------------------------------------------------
  // Register enable X-check
  // ------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_last_valid_virtual")
  u_ovl_x_cp_last_valid_virtual (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (cp_last_valid_virtual));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_valid_virtual")
  u_ovl_x_cp_valid_virtual (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp_valid_virtual));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: gich_apr_we")
  u_ovl_x_gich_apr_we (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (gich_apr_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: eoicount_we")
  u_ovl_x_eoicount_we (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (eoicount_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hcr_we")
  u_ovl_x_hcr_we (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (hcr_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ich_ap0r0_el2_we")
  u_ovl_x_ich_ap0r0_el2_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (ich_ap0r0_el2_we));

  assert_never_unknown #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "Register enable x-check: ich_lr_we")
  u_ovl_x_ich_lr_we (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (ich_lr_we));

  assert_never_unknown #(`OVL_FATAL, `CA53_GIC_LR_CNT, `OVL_ASSERT, "Register enable x-check: ich_lrc_we")
  u_ovl_x_ich_lrc_we (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (ich_lrc_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipr_en")
  u_ovl_x_ipr_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ipr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: v_priority_mask_we")
  u_ovl_x_v_priority_mask_we (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (v_priority_mask_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_valid")
  u_ovl_x_wr_valid (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (wr_valid));


  // OVL_ASSERT_END

`endif

endmodule // ca53gic_cpu_vcpu


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`undef CA53_UNDEFINE

