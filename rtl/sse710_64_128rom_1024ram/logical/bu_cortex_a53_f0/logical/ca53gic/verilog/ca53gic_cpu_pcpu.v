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
// Abstract : Physical CPU Interface software accessible registers
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"


module ca53gic_cpu_pcpu (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire                              activate_ack_outstanding_i,
  input   wire                              activate_release_sent_i,
  input   wire  [(`CA53_GIC_ID_W-1):0]      arb_data_rs_interrupt_i,
  input   wire                              arb_data_rs_grp_i,
  input   wire                              arb_data_rs_grp_mod_i,
  input   wire  [(`CA53_GIC_PRI_W-1):0]     arb_data_rs_priority_i,
  input   wire                              clear_recv_i,
  input   wire  [(`CA53_GICREG_PCPU_W-1):0] cp_addr_i,
  input   wire                              cp_gov_ns_rs_i,
  input   wire                              cp_gov_wenable_rs_i,
  input   wire                              cp_last_valid_i,
  input   wire                              cp_sys_i,
  input   wire                              cp_valid_i,
  input   wire                              cp_virtual_i,
  input   wire                              cp_wdata_lpi_id_i,
  input   wire                              cp_wdata_spurious_id_i,
  input   wire  [31:0]                      cpo_wdata_i,
  input   wire                              gicd_ctlr_ds_i,
  input   wire                              gov_aarch64_at_el3_i,
  input   wire  [(`CA53_EXCP_LEV_W-1):0]    gov_exception_level_i,
  input   wire                              gov_hcr_el2_amo_i,
  input   wire                              gov_hcr_el2_fmo_i,
  input   wire                              gov_hcr_el2_imo_i,
  input   wire                              gov_monitor_mode_i,
  input   wire                              gov_scr_el3_fiq_i,
  input   wire                              gov_scr_el3_irq_i,
  input   wire                              gov_scr_el3_ns_i,
  input   wire                              quiesce_recv_i,
  input   wire                              set_recv_i,
  // Outputs
  output  wire                              activate_not_release_o,
  output  wire                              activate_release_pending_o,
  output  wire                              cpuif_drives_fiq_o,
  output  wire                              cpuif_drives_irq_o,
  output  wire                              cpuif_fiq_o,
  output  wire                              cpuif_irq_o,
  output  reg                               deactivate_grp0_o,
  output  reg                               deactivate_grp1_ns_o,
  output  reg                               deactivate_grp1_s_o,
  output  wire                              fiq_grp_enabled_o,
  output  reg                               gic_icc_sre_el1_ns_sre_o,
  output  reg                               gic_icc_sre_el1_s_sre_o,
  output  wire                              gic_icc_sre_el2_enable_o,
  output  reg                               gic_icc_sre_el2_sre_o,
  output  wire                              gic_icc_sre_el3_enable_o,
  output  reg                               gic_icc_sre_el3_sre_o,
  output  wire                              grp0_enable_o,
  output  wire                              grp1_ns_enable_o,
  output  wire                              grp1_s_enable_o,
  output  wire                              ns_el_o,
  output  wire                              nxt_set_recv_visible_o,
  output  wire                              ipr_empty_o,
  output  wire  [(`CA53_GIC_ID_W-1):0]      ipr_id_o,
  output  wire                              irq_grp_enabled_o,
  output  wire  [(`CA53_CPDATA_W-1):0]      pcpu_rdata_o,
  output  wire  [(`CA53_GIC_PRI_W-1):0]     priority_mask_o,
  output  wire                              send_deactivate_o,
  output  wire                              send_generate_sgi_o,
  output  wire                              send_upstream_wr_enables_o,
  output  wire                              send_upstream_wr_priority_o,
  output  wire  [(`CA53_GIC_SGT_W-1):0]     sgt_o,
  output  wire                              sre_el1_ns_o,
  output  wire                              sre_el1_s_o,
  output  wire                              sre_el2_o
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

  reg   [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities_0;
  reg   [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities_1;
  reg   [2:0]                             binary_point_grp0;
  reg   [(`CA53_GIC_PRI_W-1):0]           binary_point_grp0_decoded;
  reg   [2:0]                             binary_point_grp1_ns;
  reg   [(`CA53_GIC_PRI_W-1):0]           binary_point_grp1_ns_decoded;
  reg   [2:0]                             binary_point_grp1_s;
  reg   [(`CA53_GIC_PRI_W-1):0]           binary_point_grp1_s_decoded;
  reg                                     common_binary_point_grp1_ns;
  reg                                     common_binary_point_grp1_s;
  reg                                     eoi_mode_el1_ns;
  reg                                     eoi_mode_el1_s;
  reg                                     eoi_mode_el3_monitor;
  reg                                     grp0_enable;
  reg                                     grp1_ns_enable;
  reg                                     grp1_s_enable;
  reg   [1:0]                             highest_active_group_rs;
  reg                                     icc_sre_el2_enable;
  reg                                     icc_sre_el3_enable;
  reg                                     ipr_grp;
  reg                                     ipr_grp_mod;
  reg   [(`CA53_GIC_ID_W-1):0]            ipr_id;
  reg   [(`CA53_GIC_PRI_W-1):0]           ipr_priority;
  reg   [(IPR_STATE_W-1):0]               ipr_state;
  reg   [(IPR_STATE_W-1):0]               nxt_ipr_state;
  reg   [(`CA53_GIC_PRI_W-1):0]           priority_mask;
  reg                                     priority_mask_hint_enable;
  reg                                     raw_dis_fiq_byp;
  reg                                     raw_dis_fiq_byp_grp0;
  reg                                     raw_dis_fiq_byp_grp1;
  reg                                     raw_dis_irq_byp;
  reg                                     raw_dis_irq_byp_grp0;
  reg                                     raw_dis_irq_byp_grp1;
  reg                                     raw_fiqen;
  reg                                     raw_routing_modifier;
  reg                                     raw_sre_el2;
  reg                                     raw_sre_el1_s;
  reg                                     raw_sre_el1_ns;
  reg                                     sre_el3;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire                                    activate_interrupt;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      activate_priorities_0;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      activate_priorities_1;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities;
  wire  [31:0]                            active_priorities_0_grp0_wdata;
  wire  [31:0]                            active_priorities_0_grp1_s_wdata;
  wire                                    active_priorities_0_we;
  wire  [31:0]                            active_priorities_1_grp0_wdata;
  wire  [31:0]                            active_priorities_1_grp1_ns_wdata;
  wire  [31:0]                            active_priorities_1_grp1_s_wdata;
  wire                                    active_priorities_1_high_we;
  wire                                    active_priorities_1_low_we;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities_grp0;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities_grp1_ns;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      active_priorities_grp1_s;
  wire                                    active_priorities_valid;
  wire  [(`CA53_GIC_PRI_W-1):0]           binary_point_decoded;
  wire  [2:0]                             binary_point_grp0_ns;
  wire                                    binary_point_grp0_wr;
  wire                                    binary_point_grp1_ns_wr;
  wire                                    binary_point_grp1_s_wr;
  wire  [2:0]                             binary_point_ns_wdata;
  wire  [2:0]                             binary_point_s_wdata;
  wire                                    clear_recv_valid;
  wire                                    cp_valid_physical;
  wire                                    cp_last_valid_physical;
  wire                                    common_binary_point_grp1_ns_wr;
  wire                                    common_binary_point_grp1_s_wr;
  wire                                    cpuif_drives_fiq;
  wire                                    cpuif_drives_irq;
  wire                                    cpuif_fiq;
  wire                                    cpuif_irq;
  wire                                    disable_bypass_wr;
  wire                                    dis_fiq_byp;
  wire                                    dis_fiq_byp_grp0;
  wire                                    dis_fiq_byp_grp1;
  wire                                    dis_irq_byp;
  wire                                    dis_irq_byp_grp0;
  wire                                    dis_irq_byp_grp1;
  wire                                    el1;
  wire                                    el3;
  wire                                    el3_monitor;
  wire                                    el3_not_monitor;
  wire                                    eoi_mode_el1_ns_wr;
  wire                                    eoi_mode_el1_s_wr;
  wire                                    eoi_mode;
  wire                                    eoi_mode_mem;
  wire                                    eoi_mode_sys;
  wire                                    fiq_enable;
  wire                                    fiq_grp_enabled;
  wire  [31:0]                            gicc_abpr;
  wire  [31:0]                            gicc_apr0_ns;
  wire  [31:0]                            gicc_apr0_s;
  wire  [31:0]                            gicc_bpr_ns;
  wire  [2:0]                             gicc_bpr_ns_bpr;
  wire  [31:0]                            gicc_bpr_s;
  wire  [31:0]                            gicc_ctlr_ns;
  wire  [31:0]                            gicc_ctlr_s;
  wire  [31:0]                            gicc_hppir_ns;
  wire  [(`CA53_GIC_ID_W-1):0]            gicc_hppir_ns_id;
  wire  [31:0]                            gicc_hppir_s;
  wire  [(`CA53_GIC_ID_W-1):0]            gicc_hppir_s_id;
  wire  [31:0]                            gicc_iar_ns;
  wire  [(`CA53_GIC_ID_W-1):0]            gicc_iar_ns_id;
  wire  [31:0]                            gicc_iar_s;
  wire  [(`CA53_GIC_ID_W-1):0]            gicc_iar_s_id;
  wire  [31:0]                            gicc_iidr;
  wire  [31:0]                            gicc_nsapr0;
  wire  [31:0]                            gicc_pmr_ns;
  wire  [31:0]                            gicc_pmr_s;
  wire  [31:0]                            gicc_rpr_ns;
  wire  [31:0]                            gicc_rpr_s;
  wire                                    group_modifiable;
  wire                                    grp0_enable_wr;
  wire                                    grp0_modifiable;
  wire                                    grp0_sys_modifiable;
  wire                                    grp0_sys_security_valid;
  wire                                    grp1_ns_enable_wr;
  wire                                    grp1_ns_fiq;
  wire                                    grp1_ns_modifiable;
  wire                                    grp1_ns_sys_modifiable;
  wire                                    grp1_s_enable_wr;
  wire                                    grp1_s_fiq;
  wire                                    grp1_s_modifiable;
  wire                                    grp1_s_sys_modifiable;
  wire                                    grp1_s_supported;
  wire                                    grp1_sys_security_valid;
  wire  [1:0]                             highest_active_group;
  wire                                    highest_active_group_rs_grp0;
  wire                                    highest_active_group_rs_grp1_ns;
  wire                                    highest_active_group_rs_grp1_s;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      highest_active_priorities;
  wire  [(`CA53_GIC_ID_W-1):0]            hppi_grp0_sys_id;
  wire  [(`CA53_GIC_ID_W-1):0]            hppi_grp1_sys_id;
  wire                                    iar_group_valid;
  wire  [31:0]                            icc_ap0r0_el1;
  wire  [31:0]                            icc_ap1r0_el1_ns;
  wire  [31:0]                            icc_ap1r0_el1_s;
  wire  [31:0]                            icc_bpr0_el1;
  wire  [31:0]                            icc_bpr1_el1_ns;
  wire  [2:0]                             icc_bpr1_el1_ns_bpr;
  wire  [31:0]                            icc_bpr1_el1_s;
  wire  [2:0]                             icc_bpr1_el1_s_bpr;
  wire  [2:0]                             icc_ctlr_el1_pribits;
  wire  [31:0]                            icc_ctlr_el1_ns;
  wire  [31:0]                            icc_ctlr_el1_s;
  wire  [31:0]                            icc_ctlr_el3;
  wire  [31:0]                            icc_hppir0_el1;
  wire  [(`CA53_GIC_ID_W-1):0]            icc_hppir0_el1_id;
  wire  [31:0]                            icc_hppir1_el1;
  wire  [(`CA53_GIC_ID_W-1):0]            icc_hppir1_el1_id;
  wire  [31:0]                            icc_iar0_el1;
  wire  [(`CA53_GIC_ID_W-1):0]            icc_iar0_el1_id;
  wire  [31:0]                            icc_iar1_el1;
  wire  [(`CA53_GIC_ID_W-1):0]            icc_iar1_el1_id;
  wire  [31:0]                            icc_igrpen0_el1;
  wire  [31:0]                            icc_igrpen1_el1_ns;
  wire  [31:0]                            icc_igrpen1_el1_s;
  wire  [31:0]                            icc_igrpen1_el3;
  wire  [31:0]                            icc_pmr_el1;
  wire  [(`CA53_GIC_PRI_W-1):0]           icc_pmr_el1_wdata;
  wire  [31:0]                            icc_rpr_el1;
  wire  [31:0]                            icc_sre_el1_ns;
  wire  [31:0]                            icc_sre_el1_s;
  wire  [31:0]                            icc_sre_el2;
  wire  [31:0]                            icc_sre_el3;
  wire                                    ipr_empty;
  wire                                    ipr_en;
  wire                                    ipr_enabled;
  wire                                    ipr_grp0;
  wire                                    ipr_grp1_ns;
  wire                                    ipr_grp1_s;
  wire                                    ipr_pending_valid;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      ipr_priorities;
  wire                                    irq_grp_enabled;
  wire                                    memory_access_ns;
  wire                                    ns_el;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      nxt_active_priorities_0;
  wire  [((1<<(`CA53_GIC_PRI_W-1))-1):0]  nxt_active_priorities_1_high;
  wire  [((1<<(`CA53_GIC_PRI_W-1))-1):0]  nxt_active_priorities_1_low;
  wire  [2:0]                             nxt_binary_point_grp0;
  wire  [2:0]                             nxt_binary_point_grp1_ns;
  wire  [2:0]                             nxt_binary_point_grp1_s;
  wire                                    nxt_common_binary_point_grp1_ns;
  wire                                    nxt_common_binary_point_grp1_s;
  wire                                    nxt_eoi_mode_el1_ns;
  wire                                    nxt_eoi_mode_el1_s;
  wire                                    nxt_eoi_mode_el3_monitor;
  wire                                    nxt_grp0_enable;
  wire                                    nxt_grp1_ns_enable;
  wire                                    nxt_grp1_s_enable;
  wire                                    nxt_icc_sre_el2_enable;
  wire                                    nxt_icc_sre_el3_enable;
  wire                                    nxt_ipr_grp_mod;
  wire  [(`CA53_GIC_PRI_W-1):0]           nxt_priority_mask;
  wire                                    nxt_priority_mask_hint_enable;
  wire                                    nxt_raw_dis_fiq_byp;
  wire                                    nxt_raw_dis_fiq_byp_grp0;
  wire                                    nxt_raw_dis_fiq_byp_grp1;
  wire                                    nxt_raw_dis_irq_byp;
  wire                                    nxt_raw_dis_irq_byp_grp0;
  wire                                    nxt_raw_dis_irq_byp_grp1;
  wire                                    nxt_raw_fiqen;
  wire                                    nxt_raw_routing_modifier;
  wire                                    nxt_raw_sre_el1_ns;
  wire                                    nxt_raw_sre_el1_s;
  wire                                    nxt_raw_sre_el2;
  wire                                    nxt_sre_el3;
  wire                                    ns_sys_reg_view;
  wire                                    preemption_valid;
  wire                                    priority_drop_0;
  wire                                    priority_drop_1;
  wire                                    priority_drop_deactivate;
  wire                                    priority_drop_grp0;
  wire                                    priority_drop_grp1_ns;
  wire                                    priority_drop_grp1_s;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      priority_drop_priorities_0;
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      priority_drop_priorities_1;
  wire                                    priority_mask_hint_enable_wr;
  wire  [(`CA53_GIC_PRI_W-1):0]           priority_mask_ns_rdata;
  wire  [(`CA53_GIC_PRI_W-1):0]           priority_mask_ns_wdata;
  wire                                    priority_mask_we;
  wire                                    priority_unmasked;
  wire                                    raw_dis_fiq_byp_grp0_wr;
  wire                                    raw_dis_fiq_byp_grp1_wr;
  wire                                    raw_dis_irq_byp_grp0_wr;
  wire                                    raw_dis_irq_byp_grp1_wr;
  wire                                    rd_valid;
  wire  [31:0]                            rdata_word_high;
  wire  [31:0]                            rdata_word_low;
  wire                                    routing_modifier;
  wire  [(`CA53_GIC_PRI_W-1):0]           running_priority;
  wire  [7:0]                             running_priority_ns;
  wire  [7:0]                             running_priority_s;
  wire  [(`CA53_GIC_PRI_W-1):0]           running_priority_values [((1<<`CA53_GIC_PRI_W)-1):0];
  wire  [((1<<`CA53_GIC_PRI_W)-1):0]      running_priority_values_rotated [(`CA53_GIC_PRI_W-1):0];
  wire                                    secure_int;
  wire                                    sel_binary_point_grp0_decoded;
  wire                                    sel_binary_point_grp1_ns_decoded;
  wire                                    sel_binary_point_grp1_s_decoded;
  wire                                    sel_gicc_abpr;
  wire                                    sel_gicc_aeoir;
  wire                                    sel_gicc_ahppir;
  wire                                    sel_gicc_aiar;
  wire                                    sel_gicc_apr0;
  wire                                    sel_gicc_apr0_ns;
  wire                                    sel_gicc_apr0_s;
  wire                                    sel_gicc_bpr;
  wire                                    sel_gicc_bpr_ns;
  wire                                    sel_gicc_bpr_s;
  wire                                    sel_gicc_ctlr;
  wire                                    sel_gicc_ctlr_ns;
  wire                                    sel_gicc_ctlr_s;
  wire                                    sel_gicc_dir;
  wire                                    sel_gicc_eoir;
  wire                                    sel_gicc_eoir_ns;
  wire                                    sel_gicc_eoir_s;
  wire                                    sel_gicc_hppir;
  wire                                    sel_gicc_hppir_ns;
  wire                                    sel_gicc_hppir_s;
  wire                                    sel_gicc_iar;
  wire                                    sel_gicc_iar_ns;
  wire                                    sel_gicc_iar_s;
  wire                                    sel_gicc_iidr;
  wire                                    sel_gicc_nsapr0;
  wire                                    sel_gicc_pmr;
  wire                                    sel_gicc_pmr_ns;
  wire                                    sel_gicc_pmr_s;
  wire                                    sel_gicc_rpr;
  wire                                    sel_gicc_rpr_ns;
  wire                                    sel_gicc_rpr_s;
  wire                                    sel_icc_ap0r0_el1;
  wire                                    sel_icc_ap1r0_el1;
  wire                                    sel_icc_ap1r0_el1_ns;
  wire                                    sel_icc_ap1r0_el1_s;
  wire                                    sel_icc_asgi1r_el1;
  wire                                    sel_icc_bpr0_el1;
  wire                                    sel_icc_bpr1_el1;
  wire                                    sel_icc_bpr1_el1_ns;
  wire                                    sel_icc_bpr1_el1_s;
  wire                                    sel_icc_ctlr_el1;
  wire                                    sel_icc_ctlr_el1_ns;
  wire                                    sel_icc_ctlr_el1_s;
  wire                                    sel_icc_ctlr_el3;
  wire                                    sel_icc_dir_el1;
  wire                                    sel_icc_eoir0_el1;
  wire                                    sel_icc_eoir1_el1;
  wire                                    sel_icc_hppir0_el1;
  wire                                    sel_icc_hppir1_el1;
  wire                                    sel_icc_iar0_el1;
  wire                                    sel_icc_iar1_el1;
  wire                                    sel_icc_igrpen0_el1;
  wire                                    sel_icc_igrpen1_el1;
  wire                                    sel_icc_igrpen1_el1_ns;
  wire                                    sel_icc_igrpen1_el1_s;
  wire                                    sel_icc_igrpen1_el3;
  wire                                    sel_icc_pmr_el1;
  wire                                    sel_icc_rpr_el1;
  wire                                    sel_icc_sgi0r_el1;
  wire                                    sel_icc_sgi1r_el1;
  wire                                    sel_icc_sre_el1;
  wire                                    sel_icc_sre_el1_ns;
  wire                                    sel_icc_sre_el1_s;
  wire                                    sel_icc_sre_el2;
  wire                                    sel_icc_sre_el3;
  wire                                    signal_interrupt;
  wire                                    send_deactivate;
  wire                                    send_upstream_wr_priority;
  wire                                    sre_el1_ns;
  wire                                    sre_el1_s;
  wire                                    sre_el2;
  wire                                    wr_valid;
  wire                                    wr_valid_mem;
  wire                                    wr_valid_sys;
  wire                                    wr_valid_sys_el3_monitor;


  // ------------------------------------------------------
  // Interrupt Packet Register
  // ------------------------------------------------------

  // The Group Modifier bit is only supported when secure group one interrupts
  // are supported.  The support of this requires GICD_CTRL.DS to be
  // deasserted and the Secure SRE EL1 to be treated as being asserted.  It is
  // a software requirement for this to only change when there are no pending
  // interrupts.  If the Group Modifier is not supported then the interrupt
  // will be treated as group zero.  As such, the treatment bit is applied on
  // packet arrival.  If the group is no longer supported then the packet is
  // released.  Dynamic treatment of groups is not required.
  assign nxt_ipr_grp_mod = arb_data_rs_grp_mod_i & grp1_s_supported;

  // Clear packets only affect the IPR if the IDs match
  assign clear_recv_valid = clear_recv_i & ( ipr_id == arb_data_rs_interrupt_i );

  always @*
    case ( ipr_state )
      IPR_S_EMPTY         : nxt_ipr_state = set_recv_i ? IPR_S_PENDING : IPR_S_EMPTY;
      IPR_S_PENDING       : nxt_ipr_state = activate_interrupt ? IPR_S_ACKNOWLEDGED:
                                            ( clear_recv_valid | ~ipr_enabled | quiesce_recv_i | set_recv_i ) ? IPR_S_RELEASED : IPR_S_PENDING;
      IPR_S_ACKNOWLEDGED  : nxt_ipr_state = activate_release_sent_i ? IPR_S_EMPTY : IPR_S_ACKNOWLEDGED;
      IPR_S_RELEASED      : nxt_ipr_state = activate_release_sent_i ? IPR_S_EMPTY : IPR_S_RELEASED;
      default             : nxt_ipr_state = {IPR_STATE_W{1'bx}};
    endcase

  assign ipr_empty = ipr_state == IPR_S_EMPTY;

  assign ipr_en    = ipr_empty & set_recv_i;

  always @ ( posedge clk )
    if ( ipr_en ) begin
      ipr_grp       <= arb_data_rs_grp_i;
      ipr_grp_mod   <= nxt_ipr_grp_mod;
      ipr_id        <= arb_data_rs_interrupt_i;
      ipr_priority  <= arb_data_rs_priority_i;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ipr_state <= IPR_S_EMPTY;
    end else begin
      ipr_state <= nxt_ipr_state;
    end

  // Determine the correct interrupt group enable that controls the release of this packet
  assign ipr_grp0     = ( ~ipr_grp ) & ~ipr_grp_mod;
  assign ipr_grp1_ns  =    ipr_grp;
  assign ipr_grp1_s   = ( ~ipr_grp ) &  ipr_grp_mod;

  // Packet's signaled group is support and enabled
  assign ipr_enabled  = ( ipr_grp0    & grp0_enable ) |
                        ( ipr_grp1_ns & grp1_ns_enable ) |
                        ( ipr_grp1_s  & grp1_s_enable & grp1_s_supported );

  // There is a pending interrupt that is enabled and can be serviced
  assign ipr_pending_valid  = ( ipr_state == IPR_S_PENDING ) &
                              ipr_enabled &
                              ~activate_ack_outstanding_i;

  // The interrupt is considered secure
  assign secure_int = ~gicd_ctlr_ds_i & ~ipr_grp;


  // ------------------------------------------------------
  // Exception levels
  // ------------------------------------------------------

  assign el1              = gov_exception_level_i == `CA53_EL1;

  assign el3              = gov_exception_level_i == `CA53_EL3;

  assign el3_monitor      = el3 & ( gov_aarch64_at_el3_i | gov_monitor_mode_i );

  assign el3_not_monitor  = el3 & ~gov_aarch64_at_el3_i & ~gov_monitor_mode_i;

  assign ns_el            = ~el3_monitor & gov_scr_el3_ns_i;


  // ------------------------------------------------------
  // Access decoding
  // ------------------------------------------------------

  // Memory mapped legacy GICv2
  // EOIMode for memory accesses is defined by the security of the memory access
  assign eoi_mode_mem = memory_access_ns ? eoi_mode_el1_ns : eoi_mode_el1_s;

  assign sel_gicc_abpr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_ABPR );
  assign sel_gicc_aeoir   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_AEOIR );
  assign sel_gicc_ahppir  = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_AHPPIR );
  assign sel_gicc_aiar    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_AIAR );
  assign sel_gicc_apr0    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_APR );
  assign sel_gicc_bpr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_BPR );
  assign sel_gicc_ctlr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_CTLR );
  assign sel_gicc_dir     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_DIR ) & eoi_mode_mem;
  assign sel_gicc_eoir    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_EOIR );
  assign sel_gicc_hppir   = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_HPPIR );
  assign sel_gicc_iar     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_IAR );
  assign sel_gicc_iidr    = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_IIDR );
  assign sel_gicc_nsapr0  = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_NSAPR ) & ~memory_access_ns;
  assign sel_gicc_pmr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_PMR );
  assign sel_gicc_rpr     = ~cp_sys_i & ( cp_addr_i[(`CA53_GICC_OP_W-1):0] == `CA53_GICC_OP_RPR );

  // NOTE: All memory mapped accesses are treated as secure if GICD_CTLR.DS=1.
  assign memory_access_ns = cp_gov_ns_rs_i & ~gicd_ctlr_ds_i;

  assign sel_gicc_apr0_ns   = sel_gicc_apr0   &  memory_access_ns;
  assign sel_gicc_apr0_s    = sel_gicc_apr0   & ~memory_access_ns;
  assign sel_gicc_bpr_ns    = sel_gicc_bpr    &  memory_access_ns;
  assign sel_gicc_bpr_s     = sel_gicc_bpr    & ~memory_access_ns;
  assign sel_gicc_ctlr_ns   = sel_gicc_ctlr   &  memory_access_ns;
  assign sel_gicc_ctlr_s    = sel_gicc_ctlr   & ~memory_access_ns;
  assign sel_gicc_eoir_ns   = sel_gicc_eoir   &  memory_access_ns;
  assign sel_gicc_eoir_s    = sel_gicc_eoir   & ~memory_access_ns;
  assign sel_gicc_hppir_ns  = sel_gicc_hppir  &  memory_access_ns;
  assign sel_gicc_hppir_s   = sel_gicc_hppir  & ~memory_access_ns;
  assign sel_gicc_iar_ns    = sel_gicc_iar    &  memory_access_ns;
  assign sel_gicc_iar_s     = sel_gicc_iar    & ~memory_access_ns;
  assign sel_gicc_pmr_ns    = sel_gicc_pmr    &  memory_access_ns;
  assign sel_gicc_pmr_s     = sel_gicc_pmr    & ~memory_access_ns;
  assign sel_gicc_rpr_ns    = sel_gicc_rpr    &  memory_access_ns;
  assign sel_gicc_rpr_s     = sel_gicc_rpr    & ~memory_access_ns;

  // System register GICv3
  // EOIMode for system register accesses is defined by exception level and CPU security state
  assign eoi_mode_sys = el3_monitor       ? eoi_mode_el3_monitor:
                        gov_scr_el3_ns_i  ? eoi_mode_el1_ns:
                                            eoi_mode_el1_s;

  assign sel_icc_ap0r0_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_AP0R0_EL1 );
  assign sel_icc_ap1r0_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_AP1R0_EL1 );
  assign sel_icc_asgi1r_el1   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_ASGI1R_EL1 );
  assign sel_icc_bpr0_el1     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_BPR0_EL1 );
  assign sel_icc_bpr1_el1     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_BPR1_EL1 );
  assign sel_icc_ctlr_el1     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_CTLR_EL1 );
  assign sel_icc_ctlr_el3     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_CTLR_EL3 );
  assign sel_icc_dir_el1      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_DIR_EL1 ) & eoi_mode_sys;
  assign sel_icc_eoir0_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_EOIR0_EL1 );
  assign sel_icc_eoir1_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_EOIR1_EL1 );
  assign sel_icc_hppir0_el1   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_HPPIR0_EL1 );
  assign sel_icc_hppir1_el1   = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_HPPIR1_EL1 );
  assign sel_icc_iar0_el1     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_IAR0_EL1 );
  assign sel_icc_iar1_el1     = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_IAR1_EL1 );
  assign sel_icc_igrpen0_el1  = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_IGRPEN0_EL1 );
  assign sel_icc_igrpen1_el1  = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_IGRPEN1_EL1 );
  assign sel_icc_igrpen1_el3  = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_IGRPEN1_EL3 );
  assign sel_icc_pmr_el1      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_PMR_EL1 );
  assign sel_icc_rpr_el1      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_RPR );
  assign sel_icc_sgi0r_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_SGI0R_EL1 );
  assign sel_icc_sgi1r_el1    = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_SGI1R_EL1 );
  assign sel_icc_sre_el1      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_SRE_EL1 );
  assign sel_icc_sre_el2      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_SRE_EL2 );
  assign sel_icc_sre_el3      = cp_sys_i & ( cp_addr_i == `CA53_GICREG_GICC_SRE_EL3 );

  // NOTE: System register banked registers are not affected by GICD_CTLR.DS
  assign sel_icc_ap1r0_el1_ns   = sel_icc_ap1r0_el1   &  gov_scr_el3_ns_i;
  assign sel_icc_ap1r0_el1_s    = sel_icc_ap1r0_el1   & ~gov_scr_el3_ns_i;
  assign sel_icc_ctlr_el1_ns    = sel_icc_ctlr_el1    &  gov_scr_el3_ns_i;
  assign sel_icc_ctlr_el1_s     = sel_icc_ctlr_el1    & ~gov_scr_el3_ns_i;
  assign sel_icc_bpr1_el1_ns    = sel_icc_bpr1_el1    &  gov_scr_el3_ns_i;
  assign sel_icc_bpr1_el1_s     = sel_icc_bpr1_el1    & ~gov_scr_el3_ns_i;
  assign sel_icc_igrpen1_el1_ns = sel_icc_igrpen1_el1 &  gov_scr_el3_ns_i;
  assign sel_icc_igrpen1_el1_s  = sel_icc_igrpen1_el1 & ~gov_scr_el3_ns_i;
  assign sel_icc_sre_el1_ns     = sel_icc_sre_el1     &  gov_scr_el3_ns_i;
  assign sel_icc_sre_el1_s      = sel_icc_sre_el1     & ~gov_scr_el3_ns_i;

  // The operation is valid for this interface
  assign cp_valid_physical      = cp_valid_i      & ~cp_virtual_i;
  assign cp_last_valid_physical = cp_last_valid_i & ~cp_virtual_i;

  // Valid read
  assign rd_valid = cp_valid_physical & ~cp_gov_wenable_rs_i;

  // Valid write
  assign wr_valid                 = cp_valid_physical &  cp_gov_wenable_rs_i;
  assign wr_valid_mem             = wr_valid          & ~cp_sys_i;
  assign wr_valid_sys             = wr_valid          &  cp_sys_i;
  assign wr_valid_sys_el3_monitor = wr_valid_sys      &  el3_monitor;


  // ------------------------------------------------------
  // Active Priority Registers
  // ------------------------------------------------------

  // Active Priorities Registers encoding:
  //  active_priorities_0[i] | active_priorities_1[i] | Decoding
  //  ----------------------------------------------------------------------
  //                       0 |                      0 | No active interrupt
  //                       0 |                      1 | Group one non-secure
  //                       1 |                      0 | Group zero (grp0)
  //                       1 |                      1 | Group one secure

  // The active priorities for the different interrupt groups
  assign active_priorities_grp0     =  active_priorities_0 & ~active_priorities_1;
  assign active_priorities_grp1_ns  = ~active_priorities_0 &  active_priorities_1;
  assign active_priorities_grp1_s   =  active_priorities_0 &  active_priorities_1;

  // APR data for writing group zero interrupts
  assign active_priorities_0_grp0_wdata =  cpo_wdata_i | active_priorities_grp1_s;
  assign active_priorities_1_grp0_wdata = ~cpo_wdata_i & active_priorities_1;

  // APR data for writing group one non-secure interrupts
  assign active_priorities_1_grp1_ns_wdata  = ( ( ( sel_gicc_apr0_ns | ( sel_icc_ap1r0_el1_ns & ~el3 & ~gicd_ctlr_ds_i ) ) ?
                                                  { cpo_wdata_i[15:0] , active_priorities_1[15:0] } : cpo_wdata_i ) | active_priorities_grp1_s ) &
                                              ~active_priorities_grp0;

  // APR data for writing group one secure interrupts
  assign active_priorities_0_grp1_s_wdata = cpo_wdata_i   |  active_priorities_grp0;
  assign active_priorities_1_grp1_s_wdata = ( cpo_wdata_i & ~active_priorities_grp0 ) | active_priorities_grp1_ns;

  // Calculate the Active Priorities Register values after the interrupt has been acknowledged
  assign activate_priorities_0 = active_priorities_0 | ipr_priorities;
  assign activate_priorities_1 = active_priorities_1 | ipr_priorities;

  // The Active Priorities Registers after a priority drop
  assign priority_drop_priorities_0 = active_priorities_0 & ~highest_active_priorities;
  assign priority_drop_priorities_1 = active_priorities_1 & ~highest_active_priorities;

  assign nxt_active_priorities_0      = ( {32{sel_gicc_iar      | sel_icc_iar0_el1  | sel_icc_iar1_el1}}  & activate_priorities_0 ) |
                                        ( {32{sel_gicc_eoir     | sel_icc_eoir0_el1 | sel_icc_eoir1_el1}} & priority_drop_priorities_0 ) |
                                        ( {32{sel_gicc_apr0     | sel_icc_ap0r0_el1}}                     & active_priorities_0_grp0_wdata ) |
                                        ( {32{sel_icc_ap1r0_el1}}                                         & active_priorities_0_grp1_s_wdata );

  assign active_priorities_0_we       = ( activate_interrupt & ~ipr_grp1_ns ) |
                                        ( wr_valid  & ( priority_drop_0 |
                                                        sel_gicc_apr0_s |
                                                        sel_icc_ap0r0_el1 |
                                                        sel_icc_ap1r0_el1_s ) );

  assign nxt_active_priorities_1_low  = ( {16{sel_gicc_iar        | sel_gicc_aiar       | sel_icc_iar1_el1}}  & activate_priorities_1[15:0] ) |
                                        ( {16{sel_gicc_eoir       | sel_gicc_aeoir      | sel_icc_eoir1_el1}} & priority_drop_priorities_1[15:0] ) |
                                        ( {16{sel_gicc_apr0       | sel_icc_ap0r0_el1}}                       & active_priorities_1_grp0_wdata[15:0] ) |
                                        ( {16{sel_gicc_nsapr0     | sel_icc_ap1r0_el1_ns}}                    & active_priorities_1_grp1_ns_wdata[15:0] ) |
                                        ( {16{sel_icc_ap1r0_el1_s}}                                           & active_priorities_1_grp1_s_wdata[15:0] );

  assign active_priorities_1_low_we   = ( activate_interrupt & ~ipr_grp0 ) |
                                        ( wr_valid  & ( priority_drop_1 |
                                                        sel_gicc_apr0_s | // sel_gicc_apr0_ns can not modify [0:+16]
                                                        sel_gicc_nsapr0 |
                                                        sel_icc_ap0r0_el1 |
                                                        sel_icc_ap1r0_el1 ) );

  assign nxt_active_priorities_1_high = ( {16{sel_gicc_iar        | sel_gicc_aiar     | sel_icc_iar1_el1}}     & activate_priorities_1[31:16] ) |
                                        ( {16{sel_gicc_eoir       | sel_gicc_aeoir    | sel_icc_eoir1_el1}}    & priority_drop_priorities_1[31:16] ) |
                                        ( {16{sel_gicc_apr0_ns    | sel_gicc_nsapr0   | sel_icc_ap1r0_el1_ns}} & active_priorities_1_grp1_ns_wdata[31:16] ) |
                                        ( {16{sel_gicc_apr0_s     | sel_icc_ap0r0_el1}}                        & active_priorities_1_grp0_wdata[31:16] ) |
                                        ( {16{sel_icc_ap1r0_el1_s}}                                            & active_priorities_1_grp1_s_wdata[31:16] );

  assign active_priorities_1_high_we  = ( activate_interrupt & ~ipr_grp0 ) |
                                        ( wr_valid  & ( priority_drop_1 |
                                                        sel_gicc_apr0 | // sel_gicc_apr0_ns and sel_gicc_apr0_s can modify bits [16:+16]
                                                        sel_gicc_nsapr0 |
                                                        sel_icc_ap0r0_el1 |
                                                        sel_icc_ap1r0_el1 ) );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      active_priorities_0 <= {32{1'b0}};
    end else if ( active_priorities_0_we ) begin
      active_priorities_0 <= nxt_active_priorities_0;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      active_priorities_1[15:0] <= {16{1'b0}};
    end else if ( active_priorities_1_low_we ) begin
      active_priorities_1[15:0] <= nxt_active_priorities_1_low;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      active_priorities_1[31:16] <= {16{1'b0}};
    end else if ( active_priorities_1_high_we ) begin
      active_priorities_1[31:16] <= nxt_active_priorities_1_high;
    end

  // Architectural register(s)
  assign gicc_apr0_ns     = { {16{1'b0}} , active_priorities_grp1_ns[31:16] };

  assign gicc_apr0_s      = active_priorities_grp0;

  assign gicc_nsapr0      = active_priorities_grp1_ns;

  assign icc_ap0r0_el1    = active_priorities_grp0;

  assign icc_ap1r0_el1_ns = ( el3 | gicd_ctlr_ds_i )  ? active_priorities_grp1_ns:
                                                        { {16{1'b0}} , active_priorities_grp1_ns[31:16] };

  assign icc_ap1r0_el1_s  = active_priorities_grp1_s;


  // ------------------------------------------------------
  // Binary Point Registers
  // ------------------------------------------------------

  // Constrained BPR write data
  assign binary_point_s_wdata     = ( cpo_wdata_i[2:0] >= 3'd2 ) ? cpo_wdata_i[2:0] : 3'd2;
  assign binary_point_ns_wdata    = ( cpo_wdata_i[2:0] >= 3'd3 ) ? cpo_wdata_i[2:0] : 3'd3;

  assign binary_point_grp0_wr     = sel_gicc_bpr_s |
                                    sel_icc_bpr0_el1 |
                                    ( sel_icc_bpr1_el1_ns & common_binary_point_grp1_ns &  el3_not_monitor ) |
                                    ( sel_icc_bpr1_el1_s  & common_binary_point_grp1_s  & ~el3_monitor  );

  assign nxt_binary_point_grp0    = binary_point_grp0_wr ? binary_point_s_wdata : binary_point_grp0;

  assign binary_point_grp1_ns_wr  = sel_gicc_abpr |
                                    ( sel_gicc_bpr_ns     &   ~common_binary_point_grp1_ns ) |
                                    ( sel_icc_bpr1_el1_ns & ( ~common_binary_point_grp1_ns | el3_monitor ) );

  assign nxt_binary_point_grp1_ns = binary_point_grp1_ns_wr ? binary_point_ns_wdata : binary_point_grp1_ns;

  assign binary_point_grp1_s_wr   = sel_icc_bpr1_el1_s & ( ~common_binary_point_grp1_s | el3_monitor );

  assign nxt_binary_point_grp1_s  = binary_point_grp1_s_wr ? binary_point_s_wdata : binary_point_grp1_s;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      binary_point_grp0     <= 3'd2;
      binary_point_grp1_ns  <= 3'd3;
    end else if ( wr_valid ) begin
      binary_point_grp0     <= nxt_binary_point_grp0;
      binary_point_grp1_ns  <= nxt_binary_point_grp1_ns;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      binary_point_grp1_s <= 3'd2;
    end else if ( wr_valid_sys ) begin
      binary_point_grp1_s <= nxt_binary_point_grp1_s;
    end

  // Non-secure view of group zero binary point
  assign binary_point_grp0_ns = ( &binary_point_grp0 ) ? binary_point_grp0 : binary_point_grp0 + 1'b1;

  assign gicc_bpr_ns_bpr      = common_binary_point_grp1_ns                     ? binary_point_grp0_ns:
                                                                                  binary_point_grp1_ns;

  assign icc_bpr1_el1_ns_bpr  = ( ~common_binary_point_grp1_ns | el3_monitor )  ? binary_point_grp1_ns:
                                el3                                             ? binary_point_grp0:
                                                                                  binary_point_grp0_ns;

  assign icc_bpr1_el1_s_bpr   = ( ~common_binary_point_grp1_s  | el3_monitor )  ? binary_point_grp1_s:
                                                                                  binary_point_grp0;

  // Architectural register(s)
  assign gicc_abpr        = { {29{1'b0}},             // Reserved
                              binary_point_grp1_ns }; // Binary Point

  assign gicc_bpr_ns      = { {29{1'b0}},             // Reserved
                              gicc_bpr_ns_bpr };      // Binary Point

  assign gicc_bpr_s       = { {29{1'b0}},             // Reserved
                              binary_point_grp0 };    // Binary Point

  assign icc_bpr0_el1     = { {29{1'b0}},             // Reserved
                              binary_point_grp0 };    // Binary Point

  assign icc_bpr1_el1_ns  = { {29{1'b0}},             // Reserved
                              icc_bpr1_el1_ns_bpr };  // Binary Point

  assign icc_bpr1_el1_s   = { {29{1'b0}},             // Reserved
                              icc_bpr1_el1_s_bpr };   // Binary Point


  // ------------------------------------------------------
  // Control Registers
  // ------------------------------------------------------

  // Common Binary Point Register Group 1 Non-Secure
  // - GICC_CTLR_S[4]
  // - ICC_CTLR_EL1_NS[0] when GICD_CTLR.DS=1
  // - ICC_CTLR_EL3[1]
  assign common_binary_point_grp1_ns_wr   =   sel_gicc_ctlr_s |
                                            ( sel_icc_ctlr_el1_ns & gicd_ctlr_ds_i ) |
                                              sel_icc_ctlr_el3;

  assign nxt_common_binary_point_grp1_ns  = ~common_binary_point_grp1_ns_wr ? common_binary_point_grp1_ns:
                                                                              ( ( sel_gicc_ctlr     & cpo_wdata_i[4] ) |
                                                                                ( sel_icc_ctlr_el1  & cpo_wdata_i[0] ) |
                                                                                ( sel_icc_ctlr_el3  & cpo_wdata_i[1] ) );

  // Common Binary Point Register Group 1 Secure
  // - ICC_CTLR_EL1_S[0] when GICD_CTLR.DS=1
  // - ICC_CTLR_EL3[0]
  assign common_binary_point_grp1_s_wr  = ( sel_icc_ctlr_el1_s & gicd_ctlr_ds_i ) |
                                            sel_icc_ctlr_el3;

  assign nxt_common_binary_point_grp1_s = common_binary_point_grp1_s_wr ? cpo_wdata_i[0] : common_binary_point_grp1_s;

  // End Of Interrupt Mode Non-Secure
  // - GICC_CTLR_NS[9]
  // - GICC_CTLR_S[10] (RAZ we when security disabled)
  // - ICC_CTLR_EL1_NS[1]
  // - ICC_CTLR_EL3[4]
  assign eoi_mode_el1_ns_wr   = sel_gicc_ctlr_ns |
                                ( sel_gicc_ctlr_s & ~gicd_ctlr_ds_i ) |
                                sel_icc_ctlr_el1_ns |
                                sel_icc_ctlr_el3;

  assign nxt_eoi_mode_el1_ns  = ~eoi_mode_el1_ns_wr ? eoi_mode_el1_ns:
                                                      ( ( sel_gicc_ctlr_ns    & cpo_wdata_i[9] ) |
                                                        ( sel_gicc_ctlr_s     & cpo_wdata_i[10] ) |
                                                        ( sel_icc_ctlr_el1_ns & cpo_wdata_i[1] ) |
                                                        ( sel_icc_ctlr_el3    & cpo_wdata_i[4] ) );

  // End Of Interrupt Mode Secure
  // - GICC_CTLR_S[9]
  // - ICC_CTLR_EL1_S[1]
  // - ICC_CTLR_EL3[3]
  assign eoi_mode_el1_s_wr  = sel_gicc_ctlr_s |
                              sel_icc_ctlr_el1_s |
                              sel_icc_ctlr_el3;

  assign nxt_eoi_mode_el1_s = ( sel_gicc_ctlr_s         & cpo_wdata_i[9] ) |
                              ( sel_icc_ctlr_el1_s      & cpo_wdata_i[1] ) |
                              ( sel_icc_ctlr_el3        & cpo_wdata_i[3] ) |
                              ( ( ~eoi_mode_el1_s_wr )  & eoi_mode_el1_s );

  // End Of Interrupt Mode El3
  // - ICC_CTLR_EL3[2]
  assign nxt_eoi_mode_el3_monitor = sel_icc_ctlr_el3 ? cpo_wdata_i[2] : eoi_mode_el3_monitor;

  // FIQ Bypass Disable Group 0
  // - GICC_CTLR_S[5]
  assign raw_dis_fiq_byp_grp0_wr   = ~dis_fiq_byp & sel_gicc_ctlr_s;

  assign nxt_raw_dis_fiq_byp_grp0  = raw_dis_fiq_byp_grp0_wr ? cpo_wdata_i[5] : raw_dis_fiq_byp_grp0;

  // FIQ Bypass Disable Group 1
  // - GICC_CTLR_NS[5]
  // - GICC_CTLR_S[7]
  assign raw_dis_fiq_byp_grp1_wr   = ~dis_fiq_byp & sel_gicc_ctlr;

  assign nxt_raw_dis_fiq_byp_grp1  = ~raw_dis_fiq_byp_grp1_wr ? raw_dis_fiq_byp_grp1:
                                      memory_access_ns        ? cpo_wdata_i[5]:
                                                                cpo_wdata_i[7];

  // FIQ Enable
  // - GICC_CTLR_S[3]
  assign nxt_raw_fiqen = sel_gicc_ctlr_s ? cpo_wdata_i[3] : raw_fiqen;

  // Interrupt Group 0 Enable
  // - GICC_CTLR_S[0]
  // - ICC_IGRPEN0_EL1[0]
  assign grp0_enable_wr   = sel_gicc_ctlr_s | sel_icc_igrpen0_el1;

  assign nxt_grp0_enable  = grp0_enable_wr ? cpo_wdata_i[0] : grp0_enable;

  // Interrupt Group 1 Non-Secure Enable
  // - GICC_CTLR_S[1]
  // - GICC_CTLR_NS[0]
  // - ICC_IGRPEN1_EL1_NS[0]
  // - ICC_IGRPEN1_EL3[0]
  assign grp1_ns_enable_wr  = sel_gicc_ctlr |
                              sel_icc_igrpen1_el1_ns |
                              sel_icc_igrpen1_el3;

  assign nxt_grp1_ns_enable = ~grp1_ns_enable_wr ? grp1_ns_enable:
                               sel_gicc_ctlr_s   ? cpo_wdata_i[1]:
                                                   cpo_wdata_i[0];

  // Interrupt Group 1 Secure Enable
  // - ICC_IGRPEN1_EL1_S[0]
  // - ICC_IGRPEN1_EL3[1]
  assign grp1_s_enable_wr   = sel_icc_igrpen1_el1_s | sel_icc_igrpen1_el3;

  assign nxt_grp1_s_enable  = ~grp1_s_enable_wr    ? grp1_s_enable:
                               sel_icc_igrpen1_el3 ? cpo_wdata_i[1]:
                                                     cpo_wdata_i[0];

  // IRQ Bypass Disable Group 0
  // - GICC_CTLR_S[6]
  assign raw_dis_irq_byp_grp0_wr   = ~dis_irq_byp & sel_gicc_ctlr_s;

  assign nxt_raw_dis_irq_byp_grp0  = raw_dis_irq_byp_grp0_wr ? cpo_wdata_i[6] : raw_dis_irq_byp_grp0;

  // IRQ Bypass Disable Group 1
  // - GICC_CTLR_NS[6]
  // - GICC_CTLR_S[8]
  assign raw_dis_irq_byp_grp1_wr   = ~dis_irq_byp & sel_gicc_ctlr;

  assign nxt_raw_dis_irq_byp_grp1  = ~raw_dis_irq_byp_grp1_wr ? raw_dis_irq_byp_grp1:
                                      memory_access_ns        ? cpo_wdata_i[6]:
                                                                cpo_wdata_i[8];

  // Priority Mask Hint Enable
  // - ICC_CTLR_EL1[2] when GICD_CTLR.DS=1
  // - ICC_CTLR_EL3[6]
  assign priority_mask_hint_enable_wr   = ( sel_icc_ctlr_el1 & gicd_ctlr_ds_i) |
                                            sel_icc_ctlr_el3;

  assign nxt_priority_mask_hint_enable  = priority_mask_hint_enable_wr ? cpo_wdata_i[6] : priority_mask_hint_enable;

  // Routing Modifier
  // - ICC_CTLR_EL3[5]
  assign nxt_raw_routing_modifier = sel_icc_ctlr_el3 ? cpo_wdata_i[5] : raw_routing_modifier;

  // ONLY accessible by memory mapped operations
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      raw_dis_fiq_byp_grp0  <= 1'b0;
      raw_dis_fiq_byp_grp1  <= 1'b0;
      raw_dis_irq_byp_grp0  <= 1'b0;
      raw_dis_irq_byp_grp1  <= 1'b0;
      raw_fiqen             <= 1'b0;
    end else if ( wr_valid_mem ) begin
      raw_dis_fiq_byp_grp0  <= nxt_raw_dis_fiq_byp_grp0;
      raw_dis_fiq_byp_grp1  <= nxt_raw_dis_fiq_byp_grp1;
      raw_dis_irq_byp_grp0  <= nxt_raw_dis_irq_byp_grp0;
      raw_dis_irq_byp_grp1  <= nxt_raw_dis_irq_byp_grp1;
      raw_fiqen             <= nxt_raw_fiqen;
    end

  // Accessible by memory mapped AND system register operations
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      common_binary_point_grp1_ns <= 1'b0;
      eoi_mode_el1_ns             <= 1'b0;
      eoi_mode_el1_s              <= 1'b0;
      grp0_enable                 <= 1'b0;
      grp1_ns_enable              <= 1'b0;
    end else if ( wr_valid ) begin
      common_binary_point_grp1_ns <= nxt_common_binary_point_grp1_ns;
      eoi_mode_el1_ns             <= nxt_eoi_mode_el1_ns;
      eoi_mode_el1_s              <= nxt_eoi_mode_el1_s;
      grp0_enable                 <= nxt_grp0_enable;
      grp1_ns_enable              <= nxt_grp1_ns_enable;
    end

  // ONLY accessible by system register operations
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      common_binary_point_grp1_s  <= 1'b0;
      grp1_s_enable               <= 1'b0;
      priority_mask_hint_enable   <= 1'b0;
    end else if ( wr_valid_sys ) begin
      common_binary_point_grp1_s  <= nxt_common_binary_point_grp1_s;
      grp1_s_enable               <= nxt_grp1_s_enable;
      priority_mask_hint_enable   <= nxt_priority_mask_hint_enable;
    end

  // ONLY accessible by system register operations at EL3 Monitor
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      eoi_mode_el3_monitor  <= 1'b0;
      raw_routing_modifier  <= 1'b0;
    end else if ( wr_valid_sys_el3_monitor ) begin
      eoi_mode_el3_monitor  <= nxt_eoi_mode_el3_monitor;
      raw_routing_modifier  <= nxt_raw_routing_modifier;
    end

  // GICC_CTLR.dis_fiq_byp_grp0 and dis_fiq_byp_grp1 are treated as being asserted
  // when either the system register's ICC_SRE_EL3.DFB is treated as being
  // asserted or if some exceptions levels are still using memory mapped
  // acccesses when the register state is asserted.
  assign dis_fiq_byp_grp0 = dis_fiq_byp | ( raw_dis_fiq_byp_grp0 & ~sre_el1_s );
  assign dis_fiq_byp_grp1 = dis_fiq_byp | ( raw_dis_fiq_byp_grp1 & ~sre_el1_s );

  // FIQ is always enabled when all modes use system registers.  When
  // ICC_SRE_EL1_S.SRE is enabled then system registers are enabled for all
  // exception levels.
  assign fiq_enable = raw_fiqen | sre_el1_s;

  // GICC_CTLR.dis_irq_byp_grp0 and dis_irq_byp_grp1 are treated as being asserted
  // when either the system register's ICC_SRE_EL3.DIB is treated as being
  // asserted or if some exceptions levels are still using memory mapped
  // acccesses when the register state is asserted.
  assign dis_irq_byp_grp0 = dis_irq_byp | ( raw_dis_irq_byp_grp0 & ~sre_el1_s );
  assign dis_irq_byp_grp1 = dis_irq_byp | ( raw_dis_irq_byp_grp1 & ~sre_el1_s );

  // The Routing Modifier is only valid in EL3 Monitor mode
  assign routing_modifier = el3_monitor & raw_routing_modifier;

  // Read only number of implemented priority bits
  assign icc_ctlr_el1_pribits = 3'd`CA53_GIC_PRI_W - 1'b1;

  // Architectural register(s)
  assign gicc_ctlr_ns       = { {22{1'b0}},                             // Reserved (RES0)
                                eoi_mode_el1_ns,                        // EOImodeNS
                                {2{1'b0}},                              // Reserved (RES0)
                                dis_irq_byp_grp1,                       // IRQBypDisGrp1
                                dis_fiq_byp_grp1,                       // FIQBypDisGrp1
                                {4{1'b0}},                              // Reserved (RES0)
                                grp1_ns_enable };                       // EnableGrp1

  assign gicc_ctlr_s        = { {21{1'b0}},                             // Reserved (RES0)
                                ( eoi_mode_el1_ns & ~gicd_ctlr_ds_i ),  // EOImodeNS
                                eoi_mode_el1_s,                         // EOImodeS
                                dis_irq_byp_grp1,                       // IRQBypDisGrp1
                                dis_fiq_byp_grp1,                       // FIQBypDisGrp1
                                dis_irq_byp_grp0,                       // IRQBypDisGrp0
                                dis_fiq_byp_grp0,                       // FIQBypDisGrp0
                                common_binary_point_grp1_ns,            // CBPR
                                fiq_enable,                             // FIQEn
                                1'b0,                                   // Reserved (RES0) - AckCtl obsolete in GICv3
                                grp1_ns_enable,                         // EnableGrp1
                                grp0_enable };                          // EnableGrp0

  assign icc_ctlr_el1_ns    = { {17{1'b0}},                             // Reserved (RES0)
                                1'b0,                                   // SEIS - local generation of SEIs not supported
                                {3{1'b0}},                              // IDbits - 16-bit
                                icc_ctlr_el1_pribits,                   // PRIbits
                                1'b0,                                   // Reserved (RES0)
                                priority_mask_hint_enable,              // PMHE
                                {4{1'b0}},                              // Reserved (RES0)
                                eoi_mode_el1_ns,                        // EOImode (EOImode_EL1NS)
                                common_binary_point_grp1_ns };          // CBPR (CBPR_EL1NS)

  assign icc_ctlr_el1_s     = { {17{1'b0}},                             // Reserved (RES0)
                                1'b0,                                   // SEIS - local generation of SEIs not supported
                                {3{1'b0}},                              // IDbits - 16-bit
                                icc_ctlr_el1_pribits,                   // PRIbits
                                1'b0,                                   // Reserved (RES0)
                                priority_mask_hint_enable,              // PMHE
                                {4{1'b0}},                              // Reserved (RES0)
                                eoi_mode_el1_s,                         // EOImode (EOImode_EL1S)
                                common_binary_point_grp1_s };           // CBPR (CBPR_EL1S)

  assign icc_ctlr_el3       = { {17{1'b0}},                             // Reserved (RES0)
                                1'b0,                                   // SEIS - local generation of SEIs not supported
                                {3{1'b0}},                              // IDbits - 16-bit
                                icc_ctlr_el1_pribits,                   // PRIbits
                                1'b0,                                   // Reserved (RES0)
                                priority_mask_hint_enable,              // PMHE
                                raw_routing_modifier,                   // RM
                                eoi_mode_el1_ns,                        // EOImode_EL1NS
                                eoi_mode_el1_s,                         // EOImode_EL1S
                                eoi_mode_el3_monitor,                   // EOImode_EL3
                                common_binary_point_grp1_ns,            // CBPR_EL1NS
                                common_binary_point_grp1_s };           // CBPR_EL1S

  assign icc_igrpen0_el1    = { {31{1'b0}},                             // Reserved (RES0)
                                grp0_enable };                          // Enable

  assign icc_igrpen1_el1_ns = { {31{1'b0}},                             // Reserved (RES0)
                                grp1_ns_enable };                       // Enable

  assign icc_igrpen1_el1_s  = { {31{1'b0}},                             // Reserved (RES0)
                                grp1_s_enable };                        // Enable

  assign icc_igrpen1_el3    = { {30{1'b0}},                             // Reserved (RES0)
                                grp1_s_enable,                          // EnableGrp1 (secure)
                                grp1_ns_enable };                       // EnableGrp1 (non-secure)


  // ------------------------------------------------------
  // End Of Interrupt Register
  // ------------------------------------------------------

  // Priority drop per group
  assign priority_drop_grp0       = highest_active_group_rs_grp0    & ( sel_gicc_eoir_s |
                                                                        ( sel_icc_eoir0_el1 & ( gicd_ctlr_ds_i | ~ns_el ) ) );

  assign priority_drop_grp1_ns    = highest_active_group_rs_grp1_ns & ( sel_gicc_aeoir |
                                                                        sel_gicc_eoir_ns |
                                                                        ( sel_icc_eoir1_el1 & ( gov_scr_el3_ns_i | el3_monitor ) ) );

  assign priority_drop_grp1_s     = highest_active_group_rs_grp1_s  & sel_icc_eoir1_el1 & ~ns_el;

  // Active Priorities Register 0 requires a priority drop
  assign priority_drop_0          = ~cp_wdata_spurious_id_i & ( priority_drop_grp0    | priority_drop_grp1_s );

  // Active Priorities Register 1 requires a priority drop
  assign priority_drop_1          = ~cp_wdata_spurious_id_i & ( priority_drop_grp1_ns | priority_drop_grp1_s );

  // A write to an EOIR should deactivate an interrupt
  assign priority_drop_deactivate = ~eoi_mode & ( priority_drop_grp0 | priority_drop_grp1_ns | priority_drop_grp1_s );


  // ------------------------------------------------------
  // Highest Priority Pending Interrupt and Acknowledge Register
  // ------------------------------------------------------

  // Memory Mapped Group 0
  assign gicc_hppir_s_id  = ipr_pending_valid ? ( ~ipr_grp1_ns ? ipr_id : `CA53_GIC_ID_SPURIOUS_SECURITY ) : `CA53_GIC_ID_SPURIOUS_NONE;
  assign gicc_iar_s_id    = signal_interrupt  ? ( ~ipr_grp1_ns ? ipr_id : `CA53_GIC_ID_SPURIOUS_SECURITY ) : `CA53_GIC_ID_SPURIOUS_NONE;

  // Memory Mapped Group 1
  assign gicc_hppir_ns_id = ipr_pending_valid ? (  ipr_grp1_ns ? ipr_id : `CA53_GIC_ID_SPURIOUS_NONE )     : `CA53_GIC_ID_SPURIOUS_NONE;
  assign gicc_iar_ns_id   = signal_interrupt  ? (  ipr_grp1_ns ? ipr_id : `CA53_GIC_ID_SPURIOUS_NONE )     : `CA53_GIC_ID_SPURIOUS_NONE;

  // The current group specific system register access has valid security
  assign grp0_sys_security_valid = el3_monitor |  ~gov_scr_el3_ns_i | ~secure_int;
  assign grp1_sys_security_valid = el3_monitor | ( gov_scr_el3_ns_i ^  secure_int );

  // System register group 0
  assign hppi_grp0_sys_id   =  ipr_grp0 ? ( routing_modifier        ? `CA53_GIC_ID_SPURIOUS_SECURE_EL:
                                            grp0_sys_security_valid ? ipr_id:
                                                                      `CA53_GIC_ID_SPURIOUS_NONE ):
                                          ( ~el3_monitor            ? `CA53_GIC_ID_SPURIOUS_NONE:
                                             secure_int             ? `CA53_GIC_ID_SPURIOUS_SECURE_EL:
                                                                      `CA53_GIC_ID_SPURIOUS_NS_EL);

  assign icc_hppir0_el1_id  = ipr_pending_valid ? hppi_grp0_sys_id : `CA53_GIC_ID_SPURIOUS_NONE;

  assign icc_iar0_el1_id    = signal_interrupt  ? hppi_grp0_sys_id : `CA53_GIC_ID_SPURIOUS_NONE;

  // System register group 1
  assign hppi_grp1_sys_id   = ipr_grp0 ? ( routing_modifier         ? `CA53_GIC_ID_SPURIOUS_SECURE_EL:
                                                                      `CA53_GIC_ID_SPURIOUS_NONE ):
                                         ( routing_modifier         ? `CA53_GIC_ID_SPURIOUS_NS_EL:
                                           grp1_sys_security_valid  ? ipr_id:
                                                                      `CA53_GIC_ID_SPURIOUS_NONE );

  assign icc_hppir1_el1_id  = ipr_pending_valid ? hppi_grp1_sys_id : `CA53_GIC_ID_SPURIOUS_NONE;

  assign icc_iar1_el1_id    = signal_interrupt  ? hppi_grp1_sys_id : `CA53_GIC_ID_SPURIOUS_NONE;

  // Activate interrupt
  assign iar_group_valid    = ipr_grp0  ? ( sel_gicc_iar_s |
                                            ( sel_icc_iar0_el1 & ~routing_modifier & grp0_sys_security_valid ) ):
                                          ( sel_gicc_aiar |
                                            sel_gicc_iar_ns |
                                            ( sel_icc_iar1_el1 & ~routing_modifier & grp1_sys_security_valid ) );

  assign activate_interrupt = rd_valid &          // Active read operation
                              iar_group_valid &   // IAR read matches group of highest pending interrupt group
                              signal_interrupt;   // Interrupt is valid to be signaled

  // Architectural register(s)
  assign gicc_hppir_s   = { {16{1'b0}},           // RES0
                            gicc_hppir_s_id };    // Interrupt ID

  // NOTE: gicc_hppir_ns is a synonym for the following registers:
  // - GICC_AHPPIR
  // - GICC_HPPIR non-secure when GICD_CTLR.DS==0
  assign gicc_hppir_ns  = { {16{1'b0}},           // RES0
                            gicc_hppir_ns_id};    // Interrupt ID

  assign gicc_iar_s     = { {16{1'b0}},           // RES0
                            gicc_iar_s_id};       // Interrupt ID

  // NOTE: gicc_iar_ns is a synonym for the following registers:
  // - GICC_AIAR
  // - GICC_IAR non-secure when GICD_CTLR.DS==0
  assign gicc_iar_ns    = { {16{1'b0}},           // RES0
                            gicc_iar_ns_id};      // Interrupt ID

  assign icc_hppir0_el1 = { {16{1'b0}},           // RES0
                            icc_hppir0_el1_id };  // Interrupt ID

  assign icc_hppir1_el1 = { {16{1'b0}},           // RES0
                            icc_hppir1_el1_id };  // Interrupt ID

  assign icc_iar0_el1   = { {16{1'b0}},           // RES0
                            icc_iar0_el1_id };    // Interrupt ID

  assign icc_iar1_el1   = { {16{1'b0}},           // RES0
                            icc_iar1_el1_id };    // Interrupt ID


  // ------------------------------------------------------
  // Interface Identification Register
  // ------------------------------------------------------

  // Architectural register(s)
  assign gicc_iidr  = { `CA53_GIC_PRODUCT,    // ProductID
                        `CA53_GIC_ARCH,       // Architecture version
                        `CA53_PERPH_REVISION, // Revision
                        `CA53_GIC_IMP };      // Implementer


  // ------------------------------------------------------
  // Priority Mask Register
  // ------------------------------------------------------

  assign priority_mask_ns_wdata = priority_mask[4] ? { 1'b1 , cpo_wdata_i[7:4] } : priority_mask;

  assign ns_sys_reg_view        = ~el3 & gov_scr_el3_ns_i & gov_scr_el3_fiq_i;

  assign icc_pmr_el1_wdata      = ns_sys_reg_view ? priority_mask_ns_wdata : cpo_wdata_i[7:3];

  assign nxt_priority_mask      = ( {`CA53_GIC_PRI_W{sel_gicc_pmr_ns}}  & priority_mask_ns_wdata ) |
                                  ( {`CA53_GIC_PRI_W{sel_gicc_pmr_s}}   & cpo_wdata_i[7:3] ) |
                                  ( {`CA53_GIC_PRI_W{sel_icc_pmr_el1}}  & icc_pmr_el1_wdata );

  assign priority_mask_we       = wr_valid & ( sel_gicc_pmr | sel_icc_pmr_el1 );

  // Priority Change packet
  assign send_upstream_wr_priority  = priority_mask_we &          // Priority Mask has been writen
                                      priority_mask_hint_enable;  // Sending Priority Mask values is enabled

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      priority_mask <= {`CA53_GIC_PRI_W{1'b0}};
    end else if ( priority_mask_we ) begin
      priority_mask <= nxt_priority_mask;
    end

  // Non-secure view of priority mask (normal mask used for signaling)
  assign priority_mask_ns_rdata = priority_mask[`CA53_GIC_PRI_W-1] ? { priority_mask[(`CA53_GIC_PRI_W-2):0] , 1'b0 } : {`CA53_GIC_PRI_W{1'b0}};

  // Architectural register(s)
  assign gicc_pmr_s   = { {24{1'b0}},             // Reserved (RES0)
                          priority_mask,          // Priority
                          { 3{1'b0}} };           // Pruority (Unused)

  assign gicc_pmr_ns  = { {24{1'b0}},             // Reserved (RES0)
                          priority_mask_ns_rdata, // Priority
                          { 3{1'b0}} };           // Priority (Unused)

  assign icc_pmr_el1  = { {24{1'b0}},                                                   // Reserved (RES0)
                          ( ns_sys_reg_view ? priority_mask_ns_rdata : priority_mask ), // Priority
                          { 3{1'b0}} };                                                 // Priority (Unused)


  // ------------------------------------------------------
  // Running priority Register
  // ------------------------------------------------------

  // Disabled security or secure view of running priority (normal running priority used for signaling)
  assign running_priority_s = { running_priority , {3{1'b0}} } | {8{ ~active_priorities_valid }};

  // Non-secure view of running priority (normal running priority used for signaling)
  assign running_priority_ns = { ( {4{running_priority[4]}} & running_priority[3:0] ) , {4{1'b0}} } | {8{ ~active_priorities_valid }};

  // Architectural register(s)
  assign gicc_rpr_s   = { {24{1'b0}},             // Reserved (RES0)
                          running_priority_s };   // Priority

  assign gicc_rpr_ns  = { {24{1'b0}},             // Reserved (RES0)
                          running_priority_ns };  // Priority

  assign icc_rpr_el1  = { {24{1'b0}},                                                       // Reserved (RES0)
                          ( ns_sys_reg_view ? running_priority_ns : running_priority_s ) }; // Priority


  // ------------------------------------------------------
  // Software Generated Interrupt Registers
  // ------------------------------------------------------

  assign sgt_o                = ( {`CA53_GIC_SGT_W{sel_icc_asgi1r_el1}} & `CA53_GIC_SGT_ASGI1R)|
                                ( {`CA53_GIC_SGT_W{sel_icc_sgi0r_el1}}  & `CA53_GIC_SGT_SGI0R)|
                                ( {`CA53_GIC_SGT_W{sel_icc_sgi1r_el1}}  & `CA53_GIC_SGT_SGI1R);

  assign send_generate_sgi_o  = wr_valid &  ( sel_icc_asgi1r_el1 |
                                              sel_icc_sgi0r_el1 |
                                              sel_icc_sgi1r_el1 );


  // ------------------------------------------------------
  // System Register Enable Registers
  // ------------------------------------------------------

  // Modifications to DFB and DIB can occur via accesses to ICC_SRE_EL3 or
  // ICC_SRE_EL2 when security is disabled.
  assign disable_bypass_wr = ( sel_icc_sre_el2 & gicd_ctlr_ds_i ) | sel_icc_sre_el3;

  assign nxt_icc_sre_el2_enable = sel_icc_sre_el2    ? cpo_wdata_i[3] : icc_sre_el2_enable;
  assign nxt_icc_sre_el3_enable = sel_icc_sre_el3    ? cpo_wdata_i[3] : icc_sre_el3_enable;
  assign nxt_sre_el3            = sel_icc_sre_el3    ? cpo_wdata_i[0] : sre_el3;
  assign nxt_raw_dis_fiq_byp    = disable_bypass_wr  ? cpo_wdata_i[1] : raw_dis_fiq_byp;
  assign nxt_raw_dis_irq_byp    = disable_bypass_wr  ? cpo_wdata_i[2] : raw_dis_irq_byp;
  assign nxt_raw_sre_el1_ns     = sel_icc_sre_el1_ns ? cpo_wdata_i[0] : raw_sre_el1_ns;
  assign nxt_raw_sre_el1_s      = sel_icc_sre_el1_s  ? cpo_wdata_i[0] : raw_sre_el1_s;
  assign nxt_raw_sre_el2        = sel_icc_sre_el2    ? cpo_wdata_i[0] : raw_sre_el2;

  // NOTE: The SRE registers were duplicated to meet timing requirements.
  // ONLY accessible by system register operations
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_icc_sre_el1_ns_sre_o  <= 1'b0;
      gic_icc_sre_el1_s_sre_o   <= 1'b0;
      gic_icc_sre_el2_sre_o     <= 1'b0;
      icc_sre_el2_enable        <= 1'b0;
      raw_dis_fiq_byp           <= 1'b0;
      raw_dis_irq_byp           <= 1'b0;
      raw_sre_el1_ns            <= 1'b0;
      raw_sre_el1_s             <= 1'b0;
      raw_sre_el2               <= 1'b0;
    end else if ( wr_valid_sys ) begin
      gic_icc_sre_el1_ns_sre_o  <= nxt_raw_sre_el1_ns;
      gic_icc_sre_el1_s_sre_o   <= nxt_raw_sre_el1_s;
      gic_icc_sre_el2_sre_o     <= nxt_raw_sre_el2;
      icc_sre_el2_enable        <= nxt_icc_sre_el2_enable;
      raw_dis_fiq_byp           <= nxt_raw_dis_fiq_byp;
      raw_dis_irq_byp           <= nxt_raw_dis_irq_byp;
      raw_sre_el1_ns            <= nxt_raw_sre_el1_ns;
      raw_sre_el1_s             <= nxt_raw_sre_el1_s;
      raw_sre_el2               <= nxt_raw_sre_el2;
    end

  // NOTE: The SRE registers were duplicated to meet timing requirements.
  // ONLY accessible by system register operations at EL3 Monitor
  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_icc_sre_el3_sre_o <= 1'b0;
      icc_sre_el3_enable    <= 1'b0;
      sre_el3               <= 1'b0;
    end else if ( wr_valid_sys_el3_monitor ) begin
      gic_icc_sre_el3_sre_o <= nxt_sre_el3;
      icc_sre_el3_enable    <= nxt_icc_sre_el3_enable;
      sre_el3               <= nxt_sre_el3;
    end

  // ICC_SRE_EL1.SRE (secure) is treated as being asserted only if
  // ICC_SRE_EL3.SRE == 1 and ICC_SRE_EL1.SRE (secure) == 1.
  assign sre_el1_s = sre_el3 & raw_sre_el1_s;

  // ICC_SRE_EL2.SRE is treated as being asserted only if ICC_SRE_EL3.SRE == 1
  // and either ICC_SRE_EL1.SRE (secure) == 1 or ICC_SRE_EL2.SRE == 1.
  assign sre_el2 = sre_el3 & ( raw_sre_el1_s | raw_sre_el2 );

  // ICC_SRE_EL1.SRE (non-secure) is treated as being asserted only if either
  // the treated version of ICC_SRE_EL2.SRE and the raw version of
  // ICC_SRE_EL1.SRE (non-secure) are asserted or the treated version of
  // ICC_SRE_EL1.SRE (secure) is asserted and not all interrupts are being
  // virtualized.
  assign sre_el1_ns = ( sre_el2   &    raw_sre_el1_ns ) |
                      ( sre_el1_s & ( ~gov_hcr_el2_amo_i |
                                      ~gov_hcr_el2_fmo_i |
                                      ~gov_hcr_el2_imo_i ) );

  // Disable FIQ Bypass is treated as zero when ICC_SRE_EL3.SRE is not asserted
  assign dis_fiq_byp = raw_dis_fiq_byp & sre_el3;

  // Disable IRQ Bypass is treated as zero when ICC_SRE_EL3.SRE is not asserted
  assign dis_irq_byp = raw_dis_irq_byp & sre_el3;

  // Secure group one interrupts are not supported when system registers are
  // not enabled at all exception levels or when security is disabled
  assign grp1_s_supported = sre_el1_s & ~gicd_ctlr_ds_i;

  // Architectural register(s)
  assign icc_sre_el1_ns = { {29{1'b0}},         // Reserved (RES0)
                            raw_dis_irq_byp,    // DIB
                            raw_dis_fiq_byp,    // DFB
                            sre_el1_ns };       // SRE

  assign icc_sre_el1_s  = { {29{1'b0}},         // Reserved (RES0)
                            raw_dis_irq_byp,    // DIB
                            raw_dis_fiq_byp,    // DFB
                            sre_el1_s };        // SRE

  assign icc_sre_el2    = { {28{1'b0}},         // Reserved (RES0)
                            icc_sre_el2_enable, // Enable
                            raw_dis_irq_byp,    // DIB
                            raw_dis_fiq_byp,    // DFB
                            sre_el2 };          // SRE

  assign icc_sre_el3    = { {28{1'b0}},         // Reserved (RES0)
                            icc_sre_el3_enable, // Enable
                            raw_dis_irq_byp,    // DIB
                            raw_dis_fiq_byp,    // DFB
                            sre_el3 };          // SRE


  // ------------------------------------------------------
  // Read Data
  // ------------------------------------------------------

  assign rdata_word_low   = ( {32{sel_gicc_ahppir}}         & gicc_hppir_ns ) |
                            ( {32{sel_gicc_aiar}}           & gicc_iar_ns ) |
                            ( {32{sel_gicc_apr0_ns}}        & gicc_apr0_ns ) |
                            ( {32{sel_gicc_apr0_s}}         & gicc_apr0_s ) |
                            ( {32{sel_gicc_bpr_ns}}         & gicc_bpr_ns ) |
                            ( {32{sel_gicc_bpr_s}}          & gicc_bpr_s ) |
                            ( {32{sel_gicc_ctlr_ns}}        & gicc_ctlr_ns ) |
                            ( {32{sel_gicc_ctlr_s}}         & gicc_ctlr_s ) |
                            ( {32{sel_gicc_hppir_ns}}       & gicc_hppir_ns ) |
                            ( {32{sel_gicc_hppir_s}}        & gicc_hppir_s ) |
                            ( {32{sel_gicc_nsapr0}}         & gicc_nsapr0 ) |
                            ( {32{sel_icc_ap0r0_el1}}       & icc_ap0r0_el1 ) |
                            ( {32{sel_icc_ap1r0_el1_ns}}    & icc_ap1r0_el1_ns ) |
                            ( {32{sel_icc_ap1r0_el1_s}}     & icc_ap1r0_el1_s ) |
                            ( {32{sel_icc_bpr0_el1}}        & icc_bpr0_el1 ) |
                            ( {32{sel_icc_bpr1_el1_ns}}     & icc_bpr1_el1_ns ) |
                            ( {32{sel_icc_bpr1_el1_s}}      & icc_bpr1_el1_s ) |
                            ( {32{sel_icc_ctlr_el1_ns}}     & icc_ctlr_el1_ns ) |
                            ( {32{sel_icc_ctlr_el1_s}}      & icc_ctlr_el1_s ) |
                            ( {32{sel_icc_ctlr_el3}}        & icc_ctlr_el3 ) |
                            ( {32{sel_icc_hppir0_el1}}      & icc_hppir0_el1 ) |
                            ( {32{sel_icc_hppir1_el1}}      & icc_hppir1_el1 ) |
                            ( {32{sel_icc_iar0_el1}}        & icc_iar0_el1 ) |
                            ( {32{sel_icc_iar1_el1}}        & icc_iar1_el1 ) |
                            ( {32{sel_icc_igrpen0_el1}}     & icc_igrpen0_el1 ) |
                            ( {32{sel_icc_igrpen1_el1_ns}}  & icc_igrpen1_el1_ns ) |
                            ( {32{sel_icc_igrpen1_el1_s}}   & icc_igrpen1_el1_s ) |
                            ( {32{sel_icc_igrpen1_el3}}     & icc_igrpen1_el3 ) |
                            ( {32{sel_icc_pmr_el1}}         & icc_pmr_el1 ) |
                            ( {32{sel_icc_rpr_el1}}         & icc_rpr_el1 ) |
                            ( {32{sel_icc_sre_el1_ns}}      & icc_sre_el1_ns ) |
                            ( {32{sel_icc_sre_el1_s}}       & icc_sre_el1_s ) |
                            ( {32{sel_icc_sre_el2}}         & icc_sre_el2 ) |
                            ( {32{sel_icc_sre_el3}}         & icc_sre_el3 );

  assign rdata_word_high  = ( {32{sel_gicc_abpr}}           & gicc_abpr ) |
                            ( {32{sel_gicc_iar_s}}          & gicc_iar_s ) |
                            ( {32{sel_gicc_iar_ns}}         & gicc_iar_ns ) |
                            ( {32{sel_gicc_iidr}}           & gicc_iidr ) |
                            ( {32{sel_gicc_pmr_ns}}         & gicc_pmr_ns ) |
                            ( {32{sel_gicc_pmr_s}}          & gicc_pmr_s ) |
                            ( {32{sel_gicc_rpr_ns}}         & gicc_rpr_ns ) |
                            ( {32{sel_gicc_rpr_s}}          & gicc_rpr_s );

  assign pcpu_rdata_o     = { rdata_word_high , rdata_word_low };


  // ------------------------------------------------------
  // Highest Active Priority
  // ------------------------------------------------------

  // Retrieve all of the active interrupt priorities
  assign active_priorities = active_priorities_0 | active_priorities_1;

  // Determine if any interrupts are in the Active state
  assign active_priorities_valid = |active_priorities;

  // Highest active priority
  generate
    for ( i = 0; i < 32 ; i = i + 1 ) begin : hap
      if ( i == 0 ) begin : bit_lsb
        assign highest_active_priorities[0] = active_priorities[0];
      end else begin : bit_n
        assign highest_active_priorities[i] = active_priorities[i] & ( ~|active_priorities[0+:i] );
      end
    end // hap
  endgenerate

  // The highest active group encoding
  assign highest_active_group[0] = |( active_priorities_0 & highest_active_priorities );
  assign highest_active_group[1] = |( active_priorities_1 & highest_active_priorities );

  // Running Priority
  // Convert the zero-one-hot encoding of the highest active priorities
  // to a decimal encoding for the Running Priority.
  generate
    // Generate a set of 5-bit decimal numbers - one for each priority level - and
    // only keep the one that is for the highest active priority.
    for ( i = 0; i < (1<<`CA53_GIC_PRI_W); i = i + 1 ) begin : rp_valid_values
      assign running_priority_values[i] = {`CA53_GIC_PRI_W{highest_active_priorities[i]}} & i[(`CA53_GIC_PRI_W-1):0];
    end
    // Calculate the Running Priority one bit at a time by performing 5x32-bit OR operations.
    for ( j = 0; j < `CA53_GIC_PRI_W; j = j + 1 ) begin : rp_values_rotate_outer
      for ( i = 0; i < (1<<`CA53_GIC_PRI_W); i = i + 1 ) begin : rp_values_rotate_inner
        assign running_priority_values_rotated[j][i] = running_priority_values[i][j];
      end
      assign running_priority[j] = |running_priority_values_rotated[j];
    end
  endgenerate

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      highest_active_group_rs <= {2{1'b0}};
    end else if ( cp_last_valid_physical ) begin
      highest_active_group_rs <= highest_active_group;
    end

  // The highest active group
  assign highest_active_group_rs_grp0    =  highest_active_group_rs[0] & ~highest_active_group_rs[1];
  assign highest_active_group_rs_grp1_ns = ~highest_active_group_rs[0] &  highest_active_group_rs[1];
  assign highest_active_group_rs_grp1_s  =  highest_active_group_rs[0] &  highest_active_group_rs[1];


  // ------------------------------------------------------
  // Pre-emption Priority
  // ------------------------------------------------------

  // Determine the one-hot encoding of the active priority
  assign ipr_priorities = { {((1<<`CA53_GIC_PRI_W)-1){1'b0}} , 1'b1 } << ipr_priority;

  // Decode BPR (group 0) to a priority mask ( 2 <= BPR <= 7 )
  always @*
    case ( binary_point_grp0 )
      3'b010 :  binary_point_grp0_decoded = 5'b11111;
      3'b011 :  binary_point_grp0_decoded = 5'b11110;
      3'b100 :  binary_point_grp0_decoded = 5'b11100;
      3'b101 :  binary_point_grp0_decoded = 5'b11000;
      3'b110 :  binary_point_grp0_decoded = 5'b10000;
      3'b111 :  binary_point_grp0_decoded = 5'b00000;
      default : binary_point_grp0_decoded = {5{1'bx}};
    endcase

  // Decode BPR (group 1 non-secure) to a priority mask ( 3 <= BPR <= 7 )
  always @*
    case ( binary_point_grp1_ns )
      3'b011 :  binary_point_grp1_ns_decoded = 5'b11111;
      3'b100 :  binary_point_grp1_ns_decoded = 5'b11110;
      3'b101 :  binary_point_grp1_ns_decoded = 5'b11100;
      3'b110 :  binary_point_grp1_ns_decoded = 5'b11000;
      3'b111 :  binary_point_grp1_ns_decoded = 5'b10000;
      default : binary_point_grp1_ns_decoded = {5{1'bx}};
    endcase

  // Decode BPR (group 1 secure) to a priority mask ( 2 <= BPR <= 7 )
  always @*
    case ( binary_point_grp1_s )
      3'b010 :  binary_point_grp1_s_decoded = 5'b11111;
      3'b011 :  binary_point_grp1_s_decoded = 5'b11110;
      3'b100 :  binary_point_grp1_s_decoded = 5'b11100;
      3'b101 :  binary_point_grp1_s_decoded = 5'b11000;
      3'b110 :  binary_point_grp1_s_decoded = 5'b10000;
      3'b111 :  binary_point_grp1_s_decoded = 5'b00000;
      default : binary_point_grp1_s_decoded = {5{1'bx}};
    endcase

  assign sel_binary_point_grp0_decoded    = ipr_grp0 | ( ipr_grp1_ns & common_binary_point_grp1_ns ) | ( ipr_grp1_s & common_binary_point_grp1_s );
  assign sel_binary_point_grp1_ns_decoded = ipr_grp1_ns & ~common_binary_point_grp1_ns;
  assign sel_binary_point_grp1_s_decoded  = ipr_grp1_s & ~common_binary_point_grp1_s;

  assign binary_point_decoded = ( {5{sel_binary_point_grp0_decoded}}    & binary_point_grp0_decoded ) |
                                ( {5{sel_binary_point_grp1_ns_decoded}} & binary_point_grp1_ns_decoded ) |
                                ( {5{sel_binary_point_grp1_s_decoded}}  & binary_point_grp1_s_decoded );

  // Check if the interrupt's priority qualifies it to preempt currently active
  // interrupts
  assign preemption_valid = ipr_priority < ( running_priority & binary_point_decoded );

  // Check if the interrupt's priority is not being masked.
  assign priority_unmasked = ipr_priority < priority_mask;

  // Interrupt can be signaled or activated
  assign signal_interrupt = ( ~active_priorities_valid | preemption_valid ) &
                            priority_unmasked &
                            ipr_pending_valid;


  // ------------------------------------------------------
  // FIQ and IRQ allocation and routing
  // ------------------------------------------------------

  // Interrupts are allocated to FIQ (group 0 is always allocated to FIQ)
  assign grp1_ns_fiq      = grp1_s_supported & ( el3 | ~gov_scr_el3_ns_i );
  assign grp1_s_fiq       = gov_aarch64_at_el3_i ? ( el3 | gov_scr_el3_ns_i ) : ( ~el3 & gov_scr_el3_ns_i );

  // An interrupt group signaled as FIQ is enabled
  assign fiq_grp_enabled  = ( grp0_enable & fiq_enable ) |
                            ( grp1_ns_enable & fiq_enable & grp1_ns_fiq ) |
                            ( grp1_s_enable & grp1_s_fiq & grp1_s_supported );

  // An interrupt group signaled as IRQ is enabled
  assign irq_grp_enabled  = ( grp0_enable & ~fiq_enable ) |
                            ( grp1_ns_enable & ( ~fiq_enable | ~grp1_ns_fiq ) ) |
                            ( grp1_s_enable & ~grp1_s_fiq & grp1_s_supported );

  // The CPU Interface drives FIQ when no enabled group is signaled as FIQ
  assign cpuif_drives_fiq = fiq_enable ? dis_fiq_byp_grp0 : dis_fiq_byp_grp0 & dis_fiq_byp_grp1;

  // The CPU Interface drives IRQ when no enabled group is signaled as IRQ
  assign cpuif_drives_irq = fiq_enable ? dis_irq_byp_grp1 & dis_irq_byp_grp0 : dis_irq_byp_grp1;

  // The highest priority pending interrupt is signaled as FIQ
  // NOTE: The support of secure group one interrupts is qualified by signal_interrupt
  assign cpuif_fiq        = signal_interrupt & ( ( ipr_grp0 & fiq_enable ) |
                                                 ( ipr_grp1_ns & fiq_enable & grp1_ns_fiq ) |
                                                 ( ipr_grp1_s & grp1_s_fiq ) );

  // The highest priority pending interrupt is signaled as IRQ
  // NOTE: The support of secure group one interrupts is qualified by signal_interrupt
  assign cpuif_irq        = signal_interrupt & ( ( ipr_grp0 & ~fiq_enable ) |
                                                 ( ipr_grp1_ns & ( ~fiq_enable | ~grp1_ns_fiq ) ) |
                                                 ( ipr_grp1_s & ~grp1_s_fiq ) );


  // ------------------------------------------------------
  // Deactivate Packet
  // ------------------------------------------------------

  // Routing of FIQ/IRQ to exception level:
  //  SCR_EL3.FIQ/IRQ | SCR_EL3.NS | HCR_EL2.FMO/IMO | Exception level
  //  -------------------------------------------------------------------------------
  //                0 |          0 |               X | EL1
  //                0 |          1 |               0 | EL1
  //                0 |          1 |               1 | EL2
  //                1 |          0 |               X | EL3 AArch64 or Monitor AArch32
  //                1 |          1 |               0 | EL3 AArch64 or Monitor AArch32
  //                1 |          1 |               1 | EL3 AArch64 or Monitor AArch32
  //
  // Note: Secure interrupts, i.e., group zero or secure group one, can't be
  //       modified from non-secure states unless GICD_CTLR.DS==1.

  // Groups are modifiable by system register mode accesses
  assign grp0_sys_modifiable    = el3_monitor | ( ~gov_scr_el3_fiq_i & ( ~gov_scr_el3_ns_i |
                                                                            ( gicd_ctlr_ds_i & ( ~gov_hcr_el2_fmo_i | ~el1 ) ) ) );

  assign grp1_ns_sys_modifiable = el3_monitor | ( ~gov_scr_el3_irq_i & ( ~gov_scr_el3_ns_i |
                                                                            ( ~gov_hcr_el2_imo_i | ~el1 ) ) );

  assign grp1_s_sys_modifiable  = el3_monitor | ( ~gov_scr_el3_irq_i &  ~gov_scr_el3_ns_i );

  // Groups are modifiable by memory mapped or system register mode accesses
  assign grp0_modifiable        = cp_sys_i        ? grp0_sys_modifiable    : ~memory_access_ns;

  assign grp1_ns_modifiable     = cp_sys_i        ? grp1_ns_sys_modifiable :  1'b1;

  assign grp1_s_modifiable      = gicd_ctlr_ds_i  ? 1'b0:
                                  sre_el1_s       ? grp1_s_sys_modifiable: // sre_el1_s==1 -> cp_sys_i==1
                                                    grp0_modifiable ;

  // A group could be modifide by a write to any DIR or EOIR registers
  assign group_modifiable       = grp0_modifiable | grp1_ns_modifiable | grp1_s_modifiable;

  assign eoi_mode               = cp_sys_i ? eoi_mode_sys : eoi_mode_mem;

  assign send_deactivate        = ( wr_valid & ( priority_drop_deactivate |
                                                 sel_gicc_dir |
                                                 sel_icc_dir_el1 ) ) &
                                  ~cp_wdata_lpi_id_i &
                                  ~cp_wdata_spurious_id_i &
                                  group_modifiable;

  always @ ( posedge clk )
    if ( wr_valid ) begin
      deactivate_grp0_o     <= grp0_modifiable;
      deactivate_grp1_ns_o  <= grp1_ns_modifiable;
      deactivate_grp1_s_o   <= grp1_s_modifiable;
    end


  // ------------------------------------------------------
  // Upstream Write Packet
  // ------------------------------------------------------

  // Upstream Data Write packet
  assign send_upstream_wr_enables_o = wr_valid  & ( grp0_enable_wr    |   // GRP0 enable write
                                                    grp1_ns_enable_wr |   // GRP1 NS enable write
                                                    grp1_s_enable_wr  );  // GRP1 S enable write


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign activate_not_release_o       = ipr_state[0];
  assign activate_release_pending_o   = ipr_state[1];
  assign cpuif_drives_fiq_o           = cpuif_drives_fiq;
  assign cpuif_drives_irq_o           = cpuif_drives_irq;
  assign cpuif_fiq_o                  = cpuif_fiq;
  assign cpuif_irq_o                  = cpuif_irq;
  assign fiq_grp_enabled_o            = fiq_grp_enabled;
  assign gic_icc_sre_el2_enable_o     = icc_sre_el2_enable;
  assign gic_icc_sre_el3_enable_o     = icc_sre_el3_enable;
  assign grp0_enable_o                = grp0_enable;
  assign grp1_ns_enable_o             = grp1_ns_enable;
  assign grp1_s_enable_o              = grp1_s_enable;
  assign ipr_empty_o                  = ipr_empty;
  assign ipr_id_o                     = ipr_id;
  assign irq_grp_enabled_o            = irq_grp_enabled;
  assign ns_el_o                      = ns_el;
  assign nxt_set_recv_visible_o       = ipr_en;
  assign priority_mask_o              = priority_mask;
  assign send_deactivate_o            = send_deactivate;
  assign send_upstream_wr_priority_o  = send_upstream_wr_priority;
  assign sre_el1_ns_o                 = sre_el1_ns;
  assign sre_el1_s_o                  = sre_el1_s;
  assign sre_el2_o                    = sre_el2;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ------------------------------------------------------
  // IPR checks
  // ------------------------------------------------------

  reg                     ovl_last_set_recv;
  reg [(IPR_STATE_W-1):0] ovl_last_ipr_state;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_set_recv   <= 1'b0;
      ovl_last_ipr_state  <= IPR_S_EMPTY;
    end else begin
      ovl_last_set_recv   <= set_recv_i;
      ovl_last_ipr_state  <= ipr_state;
    end

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "Packet state must always be known")
  u_ovl_state_known (.clk       (clk),
                     .reset_n   (reset_n),
                     .test_expr ((ipr_state==IPR_S_EMPTY)|
                                 (ipr_state==IPR_S_PENDING)|
                                 (ipr_state==IPR_S_ACKNOWLEDGED)|
                                 (ipr_state==IPR_S_RELEASED)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only a pending interrupt can be acknowledged")
  u_ovl_state_activate_interrupt (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (activate_interrupt),
                                  .consequent_expr ((ipr_state==IPR_S_PENDING)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only an interrupt being sent can be sent")
  u_ovl_state_activate_release_sent (.clk             (clk),
                                     .reset_n         (reset_n),
                                     .antecedent_expr (activate_release_sent_i),
                                     .consequent_expr ((ipr_state==IPR_S_ACKNOWLEDGED)|
                                                       (ipr_state==IPR_S_RELEASED)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Only a enabled and supported interrupt can be acknowledged")
  u_ovl_valid_activate_interrupt (.clk             (clk),
                                  .reset_n         (reset_n),
                                  .antecedent_expr (activate_interrupt),
                                  .consequent_expr (ipr_enabled));

  assert_zero_one_hot #(`OVL_FATAL, 3, `OVL_ASSERT, "Zero-One-Hot: set, clear, quiesce")
  u_ovl_zoh_clear_quiesce_set (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ({clear_recv_i,quiesce_recv_i,set_recv_i}));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The same write should not Set and Release the interrupt")
  u_ovl_changed_set_recv_i (.clk             (clk),
                            .reset_n         (reset_n),
                            .antecedent_expr ((ovl_last_ipr_state==IPR_S_EMPTY) & ovl_last_set_recv),
                            .consequent_expr (~set_recv_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Writes to the interrupt packet register are only observed when the register is EMPTY")
  u_ovl_unchanged_set_recv_i (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr ((ovl_last_ipr_state!=IPR_S_EMPTY) & ovl_last_set_recv),
                              .consequent_expr (set_recv_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: activate_interrupt")
  u_ovl_fsm_x_activate_interrupt (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (activate_interrupt));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: activate_release_sent_i")
  u_ovl_fsm_x_activate_release_sent_i (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (activate_release_sent_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: clear_recv_valid")
  u_ovl_fsm_x_clear_recv_valid (.clk       (clk),
                                .reset_n   (reset_n),
                                .qualifier (ipr_state==IPR_S_PENDING),
                                .test_expr (clear_recv_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: ipr_enabled")
  u_ovl_fsm_x_ipr_enabled (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (ipr_state==IPR_S_PENDING),
                           .test_expr (ipr_enabled));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: set_recv_i")
  u_ovl_fsm_x_set_recv_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (set_recv_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "FSM input x-check: quiesce_recv_i")
  u_ovl_fsm_x_quiesce_recv_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (quiesce_recv_i));


  // ------------------------------------------------------
  // GIC Register State
  // ------------------------------------------------------

  // Binary point registers are in range
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Physical CPU Interface binary_point_grp0 not in range")
  u_ovl_binary_point_grp0_range (.clk       (clk),
                                 .reset_n   (reset_n),
                                 .test_expr (binary_point_grp0>=3'd2));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Physical CPU Interface binary_point_grp1_ns not in range")
  u_ovl_binary_point_grp1_ns_range (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .test_expr (binary_point_grp1_ns>=3'd3));

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "GIC Physical CPU Interface binary_point_grp1_s not in range")
  u_ovl_binary_point_grp1_s_range (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr (binary_point_grp1_s>=3'd2));

  // The Highest Priorities must be Zero-One-Hot encoded for Running Priority generation
  assert_zero_one_hot #(`OVL_FATAL, 32, `OVL_ASSERT, "Zero-One-Hot: highest_active_priorities")
  u_ovl_zoh_highest_active_priorities (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .test_expr (highest_active_priorities));

  // Highest_active_group_rs must equal highest_active_group during write for valid priority drop
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Highest_active_group_rs must equal highest_active_group during write")
  u_ovl_implication_highest_active_group_rs (.clk             (clk),
                                             .reset_n         (reset_n),
                                             .antecedent_expr (cp_valid_physical),
                                             .consequent_expr (highest_active_group==highest_active_group_rs));

  // Accesses are zero-one-hot
  assert_zero_one_hot #(`OVL_FATAL, 39, `OVL_ASSERT, "Zero-One-Hot: GIC Physical CPU Interface register selects")
  u_ovl_zoh_register_enable_event (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ({39{cp_valid_physical}} & { sel_gicc_abpr,
                                                                           sel_gicc_aeoir,
                                                                           sel_gicc_ahppir,
                                                                           sel_gicc_aiar,
                                                                           sel_gicc_apr0,
                                                                           sel_gicc_bpr,
                                                                           sel_gicc_ctlr,
                                                                           sel_gicc_dir,
                                                                           sel_gicc_eoir,
                                                                           sel_gicc_hppir,
                                                                           sel_gicc_iar,
                                                                           sel_gicc_iidr,
                                                                           sel_gicc_nsapr0,
                                                                           sel_gicc_pmr,
                                                                           sel_gicc_rpr,
                                                                           sel_icc_ap0r0_el1,
                                                                           sel_icc_ap1r0_el1,
                                                                           sel_icc_asgi1r_el1,
                                                                           sel_icc_bpr0_el1,
                                                                           sel_icc_bpr1_el1,
                                                                           sel_icc_ctlr_el1,
                                                                           sel_icc_ctlr_el3,
                                                                           sel_icc_dir_el1,
                                                                           sel_icc_eoir0_el1,
                                                                           sel_icc_eoir1_el1,
                                                                           sel_icc_hppir0_el1,
                                                                           sel_icc_hppir1_el1,
                                                                           sel_icc_iar0_el1,
                                                                           sel_icc_iar1_el1,
                                                                           sel_icc_igrpen0_el1,
                                                                           sel_icc_igrpen1_el1,
                                                                           sel_icc_igrpen1_el3,
                                                                           sel_icc_pmr_el1,
                                                                           sel_icc_rpr_el1,
                                                                           sel_icc_sgi0r_el1,
                                                                           sel_icc_sgi1r_el1,
                                                                           sel_icc_sre_el1,
                                                                           sel_icc_sre_el2,
                                                                           sel_icc_sre_el3 }));

  // ------------------------------------------------------
  // Register Enable X-Check
  // ------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_0_we")
  u_ovl_x_active_priorities_0_we (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (active_priorities_0_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_1_high_we")
  u_ovl_x_active_priorities_1_high_we (.clk       (clk),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (active_priorities_1_high_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_1_low_we")
  u_ovl_x_active_priorities_1_low_we (.clk       (clk),
                                      .reset_n   (reset_n),
                                      .qualifier (1'b1),
                                      .test_expr (active_priorities_1_low_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_last_valid_physical")
  u_ovl_x_cp_last_valid_physical (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (cp_last_valid_physical));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ipr_en")
  u_ovl_x_ipr_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ipr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_mask_we")
  u_ovl_x_priority_mask_we (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (priority_mask_we));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_valid")
  u_ovl_x_wr_valid (.clk       (clk),
                    .reset_n   (reset_n),
                    .qualifier (1'b1),
                    .test_expr (wr_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_valid_mem")
  u_ovl_x_wr_valid_mem (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (wr_valid_mem));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_valid_sys")
  u_ovl_x_wr_valid_sys (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (wr_valid_sys));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wr_valid_sys_el3_monitor")
  u_ovl_x_wr_valid_sys_el3_monitor (.clk       (clk),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (wr_valid_sys_el3_monitor));
  // OVL_ASSERT_END

`endif


endmodule // ca53gic_cpu_pcpu


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gicarb_ext_defs.v"
`undef CA53_UNDEFINE

