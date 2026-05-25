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
// Abstract: CortexA53 GIC CPU Interface Top Level
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gic_gov_defs.v"


module ca53gic_cpu (
  // Inputs
  input   wire                            clk,
  input   wire                            reset_n,
  input   wire                            DFTSE,
  input   wire  [31:0]                    arb_data_i,               // Arbiter Request bus data
  input   wire                            arb_req_i,                // Arbiter Request bus handshake request
  input   wire                            arb_tready_i,             // AXI-4 Stream TREADY between Arbiter Master and CPU Interface
  input   wire  [(`CA53_CPADDR_W-1):0]    cp_gov_addr_i,            // DCU Interface address
  input   wire                            cp_gov_ns_i,              // DCU Interface none-secure memory mapped access
  input   wire                            cp_gov_req_i,             // DCU Interface handshake request
  input   wire  [(`CA53_CPSEL_W-1):0]     cp_gov_sel_i,             // DCU Interface Governor device select
  input   wire  [(`CA53_CPDATA_W-1):0]    cp_gov_wdata_i,           // DCU Interface write data
  input   wire                            cp_gov_wenable_i,         // DCU Interface write enable
  input   wire                            gov_aarch64_at_el3_i,
  input   wire  [(`CA53_EXCP_LEV_W-1):0]  gov_exception_level_i,    // Current Exception level
  input   wire                            gov_giccdisable_i,        // Registered version of GICCDISABLE
  input   wire                            gov_hcr_el2_amo_i,        // HCR_EL2.AMO (treated)
  input   wire                            gov_hcr_el2_fmo_i,        // HCR_EL2.FMO (treated)
  input   wire                            gov_hcr_el2_imo_i,        // HCR_EL2.IMO (treated)
  input   wire                            gov_monitor_mode_i,
  input   wire                            gov_scr_el3_fiq_i,        // SCR_EL3.FIQ
  input   wire                            gov_scr_el3_irq_i,        // SCR_EL3.IRQ
  input   wire                            gov_scr_el3_ns_i,         // SCR_EL3.NS
  input   wire                            nfiq_rs_i,                // Physical FIQ legacy PPI and bypass signal (active LOW)
  input   wire                            nirq_rs_i,                // Physical IRQ legacy PPI and bypass signal (active LOW)
  input   wire                            nvfiq_rs_i,               // Virtual FIQ bypass signal (active LOW)
  input   wire                            nvirq_rs_i,               // Virtual IRQ bypass signal (active LOW)
  // Outputs
  output  wire                            gic_arb_ack_o,            // Arbiter Request bus handshake acknowledge
  output  wire                            gic_cp_ack_o,             // DCU Interface handshake acknowledge
  output  wire  [(`CA53_CPDATA_W-1):0]    gic_cp_rdata_o,           // DCU Interface read data
  output  wire                            gic_fiq_o,                // Physcial FIQ (active HIGH)
  output  wire                            gic_icc_sre_el1_ns_sre_o, // El1 Non-secure system register enable
  output  wire                            gic_icc_sre_el1_s_sre_o,  // EL1 Secure system register enable
  output  wire                            gic_icc_sre_el2_enable_o, // EL2 System register enable for lower exception levels
  output  wire                            gic_icc_sre_el2_sre_o,    // EL2 System register enable
  output  wire                            gic_icc_sre_el3_enable_o, // EL3 System register enable enable for lower exception levels
  output  wire                            gic_icc_sre_el3_sre_o,    // EL3 System register enable
  output  wire                            gic_ich_hcr_el2_tall0_o,  // Trap ALL EL1 Group 0 system register accesses
  output  wire                            gic_ich_hcr_el2_tall1_o,  // Trap ALL EL1 Group 1 system register accesses
  output  wire                            gic_ich_hcr_el2_tc_o,     // Trap ALL Non-Secure EL1 Group 0 and Group 1 system register accesses
  output  wire                            gic_irq_o,                // Physical IRQ (active HIGH)
  output  reg                             gic_nxt_int_active_o,     // An interupt is being asserted by the GIC
  output  wire                            gic_stall_dsb_o,          // Distributor state does not match CPU Interface state
  output  wire  [(`CA53_TDATA_W-1):0]     gic_tdata_o,              // CPU Interface Request bus TDATA
  output  wire                            gic_tlast_o,              // CPU Interface Request bus TLAST
  output  wire                            gic_tvalid_o,             // CPU Interface Request bus TVALID
  output  wire                            gic_vfiq_o,               // Virtual FIQ (active HIGH)
  output  wire                            gic_virq_o,               // Virtual IRQ (active HIGH)
  output  wire                            nvcpumntirq_o             // Virtual CPU maintenance interrupt (active LOW)
);


  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg                               active;
  reg                               gic_fiq;
  reg                               gic_irq;
  reg                               gic_vfiq;
  reg                               gic_virq;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire                              activate_ack_outstanding;
  wire                              activate_ack_recv;
  wire                              activate_ack_v_outstanding;
  wire                              activate_ack_v_recv;
  wire                              activate_not_release;
  wire                              activate_not_release_v;
  wire                              activate_release_pending;
  wire                              activate_release_sent;
  wire                              activate_release_v_pending;
  wire                              activate_release_v_sent;
  wire  [(`CA53_GIC_ID_W-1):0]      arb_data_rs_interrupt;
  wire                              arb_data_rs_grp;
  wire                              arb_data_rs_grp_mod;
  wire  [(`CA53_GIC_PRI_W-1):0]     arb_data_rs_priority;
  wire                              clear_ack_pending;
  wire                              clear_ack_v_pending;
  wire                              clear_recv;
  wire                              clk_g;
  wire  [(`CA53_GICCP_W-2):0]       cp_addr;
  wire                              cp_gov_ns_rs;
  wire                              cp_gov_req_gic;
  wire  [(`CA53_GIC_ID_W-1):0]      cp_gov_wdata_rs;
  wire                              cp_gov_wenable_rs;
  wire                              cp_last_valid;
  wire                              cp_sys;
  wire                              cp_valid;
  wire                              cp_virtual;
  wire                              cp_wdata_lpi_id;
  wire                              cp_wdata_spurious_id;
  wire  [(`CA53_CPDATA_W-1):0]      cpo_wdata;
  wire                              cpuif_drives_fiq;
  wire                              cpuif_drives_irq;
  wire                              cpuif_fiq;
  wire                              cpuif_irq;
  wire                              cpuif_vfiq;
  wire                              cpuif_virq;
  wire                              deactivate_ack_recv;
  wire                              deactivate_grp0;
  wire                              deactivate_grp1_ns;
  wire                              deactivate_grp1_s;
  wire                              deactivate_lr_grp0;
  wire                              deactivate_lr_grp1_ns;
  wire  [(`CA53_GIC_LR_PID_W-1):0]  deactivate_lr_pid;
  wire                              deactivate_pending;
  wire                              downstream_wr_ack_pending;
  wire                              downstream_wr_recv;
  wire                              dpkt_active;
  wire                              fiq_grp_enabled;
  wire                              generate_sgi_ack_recv;
  wire                              generate_sgi_pending;
  wire                              gic_tvalid;
  wire                              gicd_ctlr_ds;
  wire                              grp0_enable;
  wire                              grp1_ns_enable;
  wire                              grp1_s_enable;
  wire                              ipr_empty;
  wire                              ipr_empty_v;
  wire  [(`CA53_GIC_ID_W-1):0]      ipr_id;
  wire  [(`CA53_GIC_ID_W-1):0]      ipr_id_v;
  wire                              irq_grp_enabled;
  wire                              ns_el;
  wire                              nxt_active;
  wire                              nxt_gic_fiq;
  wire                              nxt_gic_nxt_int_active;
  wire                              nxt_gic_irq;
  wire                              nxt_gic_vfiq;
  wire                              nxt_gic_virq;
  wire                              nxt_set_recv_visible;
  wire                              nxt_vset_recv_visible;
  wire  [(`CA53_CPDATA_W-1):0]      pcpu_rdata;
  wire  [(`CA53_GIC_PRI_W-1):0]     priority_mask;
  wire                              quiesce_ack_pending;
  wire                              quiesce_recv;
  wire                              send_deactivate;
  wire                              send_deactivate_lr;
  wire                              send_generate_sgi;
  wire                              send_upstream_wr_enables;
  wire                              send_upstream_wr_enables_v;
  wire                              send_upstream_wr_priority;
  wire                              set_recv;
  wire  [(`CA53_GIC_SGT_W-1):0]     sgt;
  wire                              sre_el1_ns;
  wire                              sre_el1_s;
  wire                              sre_el2;
  wire                              upstream_wr_ack_recv;
  wire                              upstream_wr_pending;
  wire                              v_grp0_enable;
  wire                              v_grp1_enable;
  wire                              vclear_recv;
  wire  [(`CA53_CPDATA_W-1):0]      vcpu_rdata;
  wire                              vset_recv;


  // ------------------------------------------------------
  // Bypass CPU Interface using ungated clock
  // ------------------------------------------------------

  assign nxt_gic_fiq  = fiq_grp_enabled   ?  cpuif_fiq: // Driven by CPU Interface
                        cpuif_drives_fiq  ?  1'b0:      // No interrupt
                                            ~nfiq_rs_i; // Driven by external source (software bypass)

  assign nxt_gic_irq  = irq_grp_enabled   ?  cpuif_irq: // Driven by CPU Interface
                        cpuif_drives_irq  ?  1'b0:      // No interrupt
                                            ~nirq_rs_i; // Driven by external source (software bypass)

  assign nxt_gic_vfiq = cpuif_vfiq | ~nvfiq_rs_i;

  assign nxt_gic_virq = cpuif_virq | ~nvirq_rs_i;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n) begin
      gic_fiq  <= 1'b0;
      gic_irq  <= 1'b0;
      gic_vfiq <= 1'b0;
      gic_virq <= 1'b0;
    end else begin
      gic_fiq  <= nxt_gic_fiq;
      gic_irq  <= nxt_gic_irq;
      gic_vfiq <= nxt_gic_vfiq;
      gic_virq <= nxt_gic_virq;
    end


  // ------------------------------------------------------
  // Qaulify next interrupt signals using ungated clock
  // ------------------------------------------------------

  // The gic_nxt_int_active must be asserted when the GIC CPU Interface signals
  // an interrupt.  Additionally, it might be asserted to approximate if an
  // interrupt will be signalled in the following cycle.

  assign nxt_gic_nxt_int_active = nxt_gic_fiq |
                                  nxt_gic_irq |
                                  nxt_gic_vfiq |
                                  nxt_gic_virq |
                                  nxt_set_recv_visible |
                                  nxt_vset_recv_visible;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n) begin
      gic_nxt_int_active_o <= 1'b0;
    end else begin
      gic_nxt_int_active_o <= nxt_gic_nxt_int_active;
    end


  // ------------------------------------------------------
  // Clock gate
  // ------------------------------------------------------

  assign nxt_active = activate_release_pending |    // Activate or Release waiting to be sent
                      activate_release_v_pending |  // Activate or Release waiting to be sent
                      arb_req_i |                   // New or processing incoming packet
                      clear_ack_pending |           // Clear Ack (physical) waiting to be sent
                      clear_ack_v_pending |         // Clear Ack (virtual) waiting to be sent
                      cp_gov_req_gic |              // New CPU request
                      deactivate_pending |          // Deactivate packet waiting to be sent
                      downstream_wr_ack_pending |   // Downstream Write Ack waiting to be sent
                      dpkt_active |                 // There is a packet being processed
                      gic_tvalid |                  // Sending transfer
                      quiesce_ack_pending |         // Quiesce Ack waiting to be sent
                      upstream_wr_pending;          // Upstream Write waiting to be sent

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      active <= 1'b0;
    end else if ( ~gov_giccdisable_i ) begin
      active <= nxt_active;
    end

  ca53_cell_clkgate u_ca53_cell_clkgate (
    // Inputs
    .clk_i          (clk),
    .clk_enable_i   (active),
    .clk_senable_i  (DFTSE),
    // Outputs
    .clk_gated_o    (clk_g)
  ); // u_ca53_cell_clkgate


  // ------------------------------------------------------
  // CP Operation logic
  // ------------------------------------------------------

  ca53gic_cpu_cpo u_ca53gic_cpu_cpo (
    // Inputs
    .clk                            (clk_g),
    .reset_n                        (reset_n),
    .cp_gov_addr_i                  (cp_gov_addr_i),
    .cp_gov_ns_i                    (cp_gov_ns_i),
    .cp_gov_req_i                   (cp_gov_req_i),
    .cp_gov_sel_i                   (cp_gov_sel_i),
    .cp_gov_wdata_i                 (cp_gov_wdata_i),
    .cp_gov_wenable_i               (cp_gov_wenable_i),
    .deactivate_pending_i           (deactivate_pending),
    .generate_sgi_pending_i         (generate_sgi_pending),
    .pcpu_rdata_i                   (pcpu_rdata),
    .send_generate_sgi_i            (send_generate_sgi),
    .sre_el1_ns_i                   (sre_el1_ns),
    .sre_el1_s_i                    (sre_el1_s),
    .sre_el2_i                      (sre_el2),
    .upstream_wr_pending_i          (upstream_wr_pending),
    .vcpu_rdata_i                   (vcpu_rdata),
    // Outputs
    .cp_addr_o                      (cp_addr),
    .cp_gov_ns_rs_o                 (cp_gov_ns_rs),
    .cp_gov_req_gic_o               (cp_gov_req_gic),
    .cp_gov_wdata_rs_o              (cp_gov_wdata_rs),
    .cp_gov_wenable_rs_o            (cp_gov_wenable_rs),
    .cp_last_valid_o                (cp_last_valid),
    .cp_sys_o                       (cp_sys),
    .cp_valid_o                     (cp_valid),
    .cp_virtual_o                   (cp_virtual),
    .cp_wdata_lpi_id_o              (cp_wdata_lpi_id),
    .cp_wdata_spurious_id_o         (cp_wdata_spurious_id),
    .cpo_wdata_o                    (cpo_wdata),
    .gic_cp_ack_o                   (gic_cp_ack_o),
    .gic_cp_rdata_o                 (gic_cp_rdata_o)
  ); // u_ca53gic_cpu_cpo


  // ------------------------------------------------------
  // Distributor to CPU Interface packet buffer
  // ------------------------------------------------------

  ca53gic_cpu_dpacket u_ca53gic_cpu_dpacket (
    // Inputs
    .clk                            (clk_g),
    .reset_n                        (reset_n),
    .arb_data_i                     (arb_data_i),
    .arb_req_i                      (arb_req_i),
    .ipr_empty_i                    (ipr_empty),
    .ipr_empty_v_i                  (ipr_empty_v),
    // Ouputs
    .activate_ack_recv_o            (activate_ack_recv),
    .activate_ack_v_recv_o          (activate_ack_v_recv),
    .arb_data_rs_interrupt_o        (arb_data_rs_interrupt),
    .arb_data_rs_grp_o              (arb_data_rs_grp),
    .arb_data_rs_grp_mod_o          (arb_data_rs_grp_mod),
    .arb_data_rs_priority_o         (arb_data_rs_priority),
    .clear_recv_o                   (clear_recv),
    .deactivate_ack_recv_o          (deactivate_ack_recv),
    .downstream_wr_recv_o           (downstream_wr_recv),
    .dpkt_active_o                  (dpkt_active),
    .generate_sgi_ack_recv_o        (generate_sgi_ack_recv),
    .gic_arb_ack_o                  (gic_arb_ack_o),
    .gicd_ctlr_ds_o                 (gicd_ctlr_ds),
    .quiesce_recv_o                 (quiesce_recv),
    .set_recv_o                     (set_recv),
    .upstream_wr_ack_recv_o         (upstream_wr_ack_recv),
    .vclear_recv_o                  (vclear_recv),
    .vset_recv_o                    (vset_recv)
  ); // u_ca53gic_cpu_dpacket


  // ------------------------------------------------------
  // Physical CPU Interface
  // ------------------------------------------------------

  ca53gic_cpu_pcpu u_ca53gic_cpu_pcpu (
    // Inputs
    .clk                            (clk_g),
    .reset_n                        (reset_n),
    .activate_ack_outstanding_i     (activate_ack_outstanding),
    .activate_release_sent_i        (activate_release_sent),
    .arb_data_rs_grp_i              (arb_data_rs_grp),
    .arb_data_rs_grp_mod_i          (arb_data_rs_grp_mod),
    .arb_data_rs_interrupt_i        (arb_data_rs_interrupt),
    .arb_data_rs_priority_i         (arb_data_rs_priority),
    .clear_recv_i                   (clear_recv),
    .cp_addr_i                      (cp_addr[(`CA53_GICREG_PCPU_W-1):0]),
    .cp_gov_ns_rs_i                 (cp_gov_ns_rs),
    .cp_gov_wenable_rs_i            (cp_gov_wenable_rs),
    .cp_last_valid_i                (cp_last_valid),
    .cp_sys_i                       (cp_sys),
    .cp_valid_i                     (cp_valid),
    .cp_virtual_i                   (cp_virtual),
    .cp_wdata_lpi_id_i              (cp_wdata_lpi_id),
    .cp_wdata_spurious_id_i         (cp_wdata_spurious_id),
    .cpo_wdata_i                    (cpo_wdata[31:0]),
    .gicd_ctlr_ds_i                 (gicd_ctlr_ds),
    .gov_aarch64_at_el3_i           (gov_aarch64_at_el3_i),
    .gov_exception_level_i          (gov_exception_level_i),
    .gov_hcr_el2_amo_i              (gov_hcr_el2_amo_i),
    .gov_hcr_el2_fmo_i              (gov_hcr_el2_fmo_i),
    .gov_hcr_el2_imo_i              (gov_hcr_el2_imo_i),
    .gov_monitor_mode_i             (gov_monitor_mode_i),
    .gov_scr_el3_fiq_i              (gov_scr_el3_fiq_i),
    .gov_scr_el3_irq_i              (gov_scr_el3_irq_i),
    .gov_scr_el3_ns_i               (gov_scr_el3_ns_i),
    .quiesce_recv_i                 (quiesce_recv),
    .set_recv_i                     (set_recv),
    // Outputs
    .activate_not_release_o         (activate_not_release),
    .activate_release_pending_o     (activate_release_pending),
    .cpuif_drives_fiq_o             (cpuif_drives_fiq),
    .cpuif_drives_irq_o             (cpuif_drives_irq),
    .cpuif_fiq_o                    (cpuif_fiq),
    .cpuif_irq_o                    (cpuif_irq),
    .deactivate_grp0_o              (deactivate_grp0),
    .deactivate_grp1_ns_o           (deactivate_grp1_ns),
    .deactivate_grp1_s_o            (deactivate_grp1_s),
    .fiq_grp_enabled_o              (fiq_grp_enabled),
    .gic_icc_sre_el1_ns_sre_o       (gic_icc_sre_el1_ns_sre_o),
    .gic_icc_sre_el1_s_sre_o        (gic_icc_sre_el1_s_sre_o),
    .gic_icc_sre_el2_enable_o       (gic_icc_sre_el2_enable_o),
    .gic_icc_sre_el2_sre_o          (gic_icc_sre_el2_sre_o),
    .gic_icc_sre_el3_enable_o       (gic_icc_sre_el3_enable_o),
    .gic_icc_sre_el3_sre_o          (gic_icc_sre_el3_sre_o),
    .grp0_enable_o                  (grp0_enable),
    .grp1_ns_enable_o               (grp1_ns_enable),
    .grp1_s_enable_o                (grp1_s_enable),
    .ipr_empty_o                    (ipr_empty),
    .ipr_id_o                       (ipr_id),
    .irq_grp_enabled_o              (irq_grp_enabled),
    .ns_el_o                        (ns_el),
    .nxt_set_recv_visible_o         (nxt_set_recv_visible),
    .pcpu_rdata_o                   (pcpu_rdata),
    .priority_mask_o                (priority_mask),
    .send_deactivate_o              (send_deactivate),
    .send_generate_sgi_o            (send_generate_sgi),
    .send_upstream_wr_enables_o     (send_upstream_wr_enables),
    .send_upstream_wr_priority_o    (send_upstream_wr_priority),
    .sgt_o                          (sgt),
    .sre_el1_ns_o                   (sre_el1_ns),
    .sre_el1_s_o                    (sre_el1_s),
    .sre_el2_o                      (sre_el2)
  ); // u_ca53gic_cpu_pcpu


  // ------------------------------------------------------
  // Virtual CPU Interface and Virtual Control Interface
  // ------------------------------------------------------

  ca53gic_cpu_vcpu u_ca53gic_cpu_vcpu (
    // Inputs
    .clk                            (clk_g),
    .reset_n                        (reset_n),
    .activate_ack_v_outstanding_i   (activate_ack_v_outstanding),
    .activate_release_v_sent_i      (activate_release_v_sent),
    .arb_data_rs_grp_i              (arb_data_rs_grp),
    .arb_data_rs_interrupt_i        (arb_data_rs_interrupt),
    .arb_data_rs_priority_i         (arb_data_rs_priority),
    .cp_addr_i                      (cp_addr[(`CA53_GICREG_VCPU_W-1):0]),
    .cp_gov_wdata_rs_i              (cp_gov_wdata_rs),
    .cp_gov_wenable_rs_i            (cp_gov_wenable_rs),
    .cp_last_valid_i                (cp_last_valid),
    .cp_sys_i                       (cp_sys),
    .cp_valid_i                     (cp_valid),
    .cp_virtual_i                   (cp_virtual),
    .cp_wdata_lpi_id_i              (cp_wdata_lpi_id),
    .cp_wdata_spurious_id_i         (cp_wdata_spurious_id),
    .cpo_wdata_i                    (cpo_wdata),
    .gicd_ctlr_ds_i                 (gicd_ctlr_ds),
    .gov_scr_el3_fiq_i              (gov_scr_el3_fiq_i),
    .gov_scr_el3_irq_i              (gov_scr_el3_irq_i),
    .quiesce_recv_i                 (quiesce_recv),
    .sre_el1_ns_i                   (sre_el1_ns),
    .sre_el2_i                      (sre_el2),
    .vclear_recv_i                  (vclear_recv),
    .vset_recv_i                    (vset_recv),
    // Outputs
    .activate_not_release_v_o       (activate_not_release_v),
    .activate_release_v_pending_o   (activate_release_v_pending),
    .cpuif_vfiq_o                   (cpuif_vfiq),
    .cpuif_virq_o                   (cpuif_virq),
    .deactivate_lr_grp0_o           (deactivate_lr_grp0),
    .deactivate_lr_grp1_ns_o        (deactivate_lr_grp1_ns),
    .deactivate_lr_pid_o            (deactivate_lr_pid),
    .gic_ich_hcr_el2_tall0_o        (gic_ich_hcr_el2_tall0_o),
    .gic_ich_hcr_el2_tall1_o        (gic_ich_hcr_el2_tall1_o),
    .gic_ich_hcr_el2_tc_o           (gic_ich_hcr_el2_tc_o),
    .ipr_empty_v_o                  (ipr_empty_v),
    .ipr_id_v_o                     (ipr_id_v),
    .nvcpumntirq_o                  (nvcpumntirq_o),
    .nxt_vset_recv_visible_o        (nxt_vset_recv_visible),
    .send_deactivate_lr_o           (send_deactivate_lr),
    .send_upstream_wr_enables_v_o   (send_upstream_wr_enables_v),
    .v_grp0_enable_o                (v_grp0_enable),
    .v_grp1_enable_o                (v_grp1_enable),
    .vcpu_rdata_o                   (vcpu_rdata)
  ); // u_ca53gic_cpu_vcpu


  // ------------------------------------------------------
  // CPU Interface to Distributor packet generation
  // ------------------------------------------------------

  ca53gic_cpu_cpacket u_ca53gic_cpu_cpacket (
    // Inputs
    .clk                            (clk_g),
    .reset_n                        (reset_n),
    .activate_ack_recv_i            (activate_ack_recv),
    .activate_ack_v_recv_i          (activate_ack_v_recv),
    .activate_not_release_i         (activate_not_release),
    .activate_not_release_v_i       (activate_not_release_v),
    .activate_release_pending_i     (activate_release_pending),
    .activate_release_v_pending_i   (activate_release_v_pending),
    .arb_tready_i                   (arb_tready_i),
    .clear_recv_i                   (clear_recv),
    .cp_gov_wdata_i                 (cp_gov_wdata_i[40:0]),
    .cp_gov_wdata_rs_i              (cp_gov_wdata_rs[12:0]),
    .cp_virtual_i                   (cp_virtual),
    .deactivate_ack_recv_i          (deactivate_ack_recv),
    .deactivate_grp0_i              (deactivate_grp0),
    .deactivate_grp1_ns_i           (deactivate_grp1_ns),
    .deactivate_grp1_s_i            (deactivate_grp1_s),
    .deactivate_lr_grp0_i           (deactivate_lr_grp0),
    .deactivate_lr_grp1_ns_i        (deactivate_lr_grp1_ns),
    .deactivate_lr_pid_i            (deactivate_lr_pid),
    .downstream_wr_recv_i           (downstream_wr_recv),
    .generate_sgi_ack_recv_i        (generate_sgi_ack_recv),
    .grp0_enable_i                  (grp0_enable),
    .grp1_ns_enable_i               (grp1_ns_enable),
    .grp1_s_enable_i                (grp1_s_enable),
    .ipr_id_i                       (ipr_id),
    .ipr_id_v_i                     (ipr_id_v),
    .ns_el_i                        (ns_el),
    .priority_mask_i                (priority_mask),
    .quiesce_recv_i                 (quiesce_recv),
    .send_deactivate_i              (send_deactivate),
    .send_deactivate_lr_i           (send_deactivate_lr),
    .send_generate_sgi_i            (send_generate_sgi),
    .send_upstream_wr_enables_i     (send_upstream_wr_enables),
    .send_upstream_wr_enables_v_i   (send_upstream_wr_enables_v),
    .send_upstream_wr_priority_i    (send_upstream_wr_priority),
    .sgt_i                          (sgt),
    .upstream_wr_ack_recv_i         (upstream_wr_ack_recv),
    .v_grp0_enable_i                (v_grp0_enable),
    .v_grp1_enable_i                (v_grp1_enable),
    .vclear_recv_i                  (vclear_recv),
    // Outputs
    .activate_ack_outstanding_o     (activate_ack_outstanding),
    .activate_ack_v_outstanding_o   (activate_ack_v_outstanding),
    .activate_release_sent_o        (activate_release_sent),
    .activate_release_v_sent_o      (activate_release_v_sent),
    .clear_ack_pending_o            (clear_ack_pending),
    .clear_ack_v_pending_o          (clear_ack_v_pending),
    .deactivate_pending_o           (deactivate_pending),
    .downstream_wr_ack_pending_o    (downstream_wr_ack_pending),
    .generate_sgi_pending_o         (generate_sgi_pending),
    .gic_stall_dsb_o                (gic_stall_dsb_o),
    .gic_tdata_o                    (gic_tdata_o),
    .gic_tlast_o                    (gic_tlast_o),
    .gic_tvalid_o                   (gic_tvalid),
    .quiesce_ack_pending_o          (quiesce_ack_pending),
    .upstream_wr_pending_o          (upstream_wr_pending)
  ); // u_ca53gic_cpu_cpacket


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign gic_fiq_o      = gic_fiq;
  assign gic_irq_o      = gic_irq;
  assign gic_tvalid_o   = gic_tvalid;
  assign gic_vfiq_o     = gic_vfiq;
  assign gic_virq_o     = gic_virq;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // GICCDISABLE
  reg ovl_init_done;
  reg ovl_last_nfiq_rs;
  reg ovl_last_nirq_rs;
  reg ovl_last_nvfiq_rs;
  reg ovl_last_nvirq_rs;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_init_done <= 1'b0;
    end else begin
      ovl_init_done <= 1'b1;
    end

  always @ ( posedge clk )
    begin
      ovl_last_nfiq_rs  <= nfiq_rs_i;
      ovl_last_nirq_rs  <= nirq_rs_i;
      ovl_last_nvfiq_rs <= nvfiq_rs_i;
      ovl_last_nvirq_rs <= nvirq_rs_i;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC CPU Interface: GICCDISABLE nFIQ")
  u_ovl_implication_gov_giccdisable_fiq (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (gov_giccdisable_i & ovl_init_done),
                                         .consequent_expr (gic_fiq ^ ovl_last_nfiq_rs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC CPU Interface: GICCDISABLE nIRQ")
  u_ovl_implication_gov_giccdisable_irq (.clk             (clk),
                                         .reset_n         (reset_n),
                                         .antecedent_expr (gov_giccdisable_i & ovl_init_done),
                                         .consequent_expr (gic_irq ^ ovl_last_nirq_rs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC CPU Interface: GICCDISABLE nVFIQ")
  u_ovl_implication_gov_giccdisable_vfiq (.clk             (clk),
                                          .reset_n         (reset_n),
                                          .antecedent_expr (gov_giccdisable_i & ovl_init_done),
                                          .consequent_expr (gic_vfiq ^ ovl_last_nvfiq_rs));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC CPU Interface: GICCDISABLE nVIRQ")
  u_ovl_implication_gov_giccdisable_virq (.clk             (clk),
                                          .reset_n         (reset_n),
                                          .antecedent_expr (gov_giccdisable_i & ovl_init_done),
                                          .consequent_expr (gic_virq ^ ovl_last_nvirq_rs));

  // ARMAUTO_X

  // OVL_ASSERT_END

`endif


endmodule // ca53gic_cpu


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gic_gov_defs.v"
`undef CA53_UNDEFINE

