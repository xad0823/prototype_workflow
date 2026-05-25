//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2012 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-30 17:43:20 +0100 (Mon, 30 Jul 2012) $
//
//      Revision            : $Revision: 216978 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose: Instantiates the required number of CPU and Virtual CPU
//          interfaces.
//-----------------------------------------------------------------------------

module gic400_interfaces #(parameter NUM_CPUS = 4,
                           parameter _CORTEXA7_INTERNAL = 0)
(
  input  wire                    clk,
  input  wire                    clk_p,
  input  wire                    reset_n,
  input  wire                    load_initial_i,
  input  wire                    gic_cfgsdisable_i,

  // Programming Interface
  input  wire                    p_vcpuif_read_i,
  input  wire                    p_vcpuif_write_i,
  input  wire                    p_cpuif_read_i,
  input  wire                    p_cpuif_write_i,
  input  wire              [2:0] p_rcpu_i,
  input  wire              [2:0] p_wcpu_i,
  input  wire                    p_rnsecure_i,
  input  wire                    p_wnsecure_i,
  input  wire              [3:0] p_rd_op_i,
  input  wire              [3:0] p_wr_op_i,
  input  wire                    p_vcpuif_rd_front_i,
  input  wire                    p_vcpuif_wr_front_i,
  input  wire             [31:0] p_wdata_i,
  output wire             [31:0] p_rdata_o,

  // Priority Logic Inputs
  input  wire     [NUM_CPUS-1:0] cpu_high_valid_i,
  input  wire     [NUM_CPUS-1:0] cpu_high_nsecure_i,
  input  wire [(NUM_CPUS*5)-1:0] cpu_high_priority_i,
  input  wire [(NUM_CPUS*9)-1:0] cpu_high_id_i,
  input  wire [(NUM_CPUS*3)-1:0] cpu_high_cpu_i,

  // ACK/EOI/Deactivate Outputs to Distributor
  output wire     [NUM_CPUS-1:0] cpu_deactivate_o,
  output wire     [NUM_CPUS-1:0] cpu_vdeactivate_o,
  output wire              [8:0] vdeactivate_id_o,
  output wire     [NUM_CPUS-1:0] cpu_ack_o,

  // IRQs
  input  wire     [NUM_CPUS-1:0] legacy_nirq_i,
  input  wire     [NUM_CPUS-1:0] legacy_nfiq_i,
  output wire     [NUM_CPUS-1:0] ppi_legacy_nirq_o,
  output wire     [NUM_CPUS-1:0] ppi_legacy_nfiq_o,
  output wire     [NUM_CPUS-1:0] cpu_nirq_out_o,
  output wire     [NUM_CPUS-1:0] cpu_nfiq_out_o,
  output wire     [NUM_CPUS-1:0] cpu_nirq_o,
  output wire     [NUM_CPUS-1:0] cpu_nfiq_o,
  output wire     [NUM_CPUS-1:0] cpu_nvirq_o,
  output wire     [NUM_CPUS-1:0] cpu_nvfiq_o,
  output wire     [NUM_CPUS-1:0] cpu_maintenance_irq_o

);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"

  localparam [3:0] IIDR_REVISION  = 4'h1;
  localparam [7:0] PRODUCT_ID = _CORTEXA7_INTERNAL ? 8'h01 : 8'h02;

  localparam one_with_zero_extension = 1;


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  wire [NUM_CPUS-1:0] p_vcpuif_cpu_write;
  wire [NUM_CPUS-1:0] p_vcpuif_cpu_read;
  wire [NUM_CPUS-1:0] p_cpuif_cpu_write;
  wire [NUM_CPUS-1:0] p_cpuif_cpu_read;

  wire                p_rd_id;

  wire                p_cpu_rd_control_req;
  wire                p_cpu_wr_control_req;
  wire                p_cpu_rd_priority_mask_req;
  wire                p_cpu_wr_priority_mask_req;
  wire                p_cpu_rd_binary_point_req;
  wire                p_cpu_wr_binary_point_req;
  wire                p_cpu_rd_ack_req;
  wire                p_cpu_wr_eoi_req;
  wire                p_cpu_rd_running_priority_req;
  wire                p_cpu_rd_highest_pending_req;
  wire                p_cpu_rd_binary_point_ns_alias_req;
  wire                p_cpu_wr_binary_point_ns_alias_req;
  wire                p_cpu_rd_ack_ns_alias_req;
  wire                p_cpu_wr_eoi_ns_alias_req;
  wire                p_cpu_rd_hpi_ns_alias_req;
  wire                p_cpu_rd_active_priorities_req;
  wire                p_cpu_wr_active_priorities_req;
  wire                p_cpu_rd_active_priorities_ns_req;
  wire                p_cpu_wr_active_priorities_ns_req;
  wire                p_cpu_wr_deactivate_req;

  wire                p_vcpu_rd_hyp_control_back;
  wire                p_vcpu_rd_vgic_type_back;
  wire                p_vcpu_rd_vm_control_alias_back;
  wire                p_vcpu_rd_maint_int_status_back;
  wire                p_vcpu_rd_eoi_int_status_back;
  wire                p_vcpu_rd_empty_list_status_back;
  wire                p_vcpu_rd_active_priorities_back;
  wire                p_vcpu_rd_list_back;
  wire          [3:0] p_vcpu_rd_list_sel;
  wire                p_vcpu_wr_hyp_control_back;
  wire                p_vcpu_wr_vm_control_alias_back;
  wire                p_vcpu_wr_active_priorities_back;
  wire                p_vcpu_wr_list_back;
  wire          [3:0] p_vcpu_wr_list_sel;
  wire                p_vcpu_rd_vm_control_front;
  wire                p_vcpu_rd_priority_mask_front;
  wire                p_vcpu_rd_binary_point_front;
  wire                p_vcpu_rd_ack_front;
  wire                p_vcpu_rd_running_priority_front;
  wire                p_vcpu_rd_highest_pending_front;
  wire                p_vcpu_rd_binary_point_ns_alias_front;
  wire                p_vcpu_rd_ack_ns_alias_front;
  wire                p_vcpu_rd_hpi_ns_alias_front;
  wire                p_vcpu_rd_active_priorities_front;
  wire                p_vcpu_wr_vm_control_front;
  wire                p_vcpu_wr_priority_mask_front;
  wire                p_vcpu_wr_binary_point_front;
  wire                p_vcpu_wr_eoi_front;
  wire                p_vcpu_wr_binary_point_ns_alias_front;
  wire                p_vcpu_wr_eoi_ns_alias_front;
  wire                p_vcpu_wr_active_priorities_front;
  wire                p_vcpu_wr_deactivate_front;

  wire         [31:0] p_vcpuif_cpu_rdata [NUM_CPUS-1:0];
  wire         [31:0] p_cpuif_cpu_rdata  [NUM_CPUS-1:0];
  wire          [8:0] cpu_vdeactivate_id [NUM_CPUS-1:0];

  reg          [31:0] p_vcpuif_rdata;
  reg          [31:0] p_cpuif_rdata;
  reg           [8:0] vdeactivate_id;

  reg           [3:0] iidr_revid_q;  // Revision ID for IIDR registers

  genvar vcpu, cpu, binary;


  //----------------------------------------------------------------------------
  // Virtual CPU Interfaces
  //----------------------------------------------------------------------------

  // Convert from binary to one-hot
  generate for (binary=0; binary<NUM_CPUS; binary=binary+1) begin : g_onehot_vcpuif_cpu
    assign p_vcpuif_cpu_write[binary] = p_vcpuif_write_i & (binary == p_wcpu_i);
    assign p_vcpuif_cpu_read[binary]  = p_vcpuif_read_i  & (binary == p_rcpu_i);
  end endgenerate

  // Decode Hypervisor view (back-end)
  assign p_vcpu_rd_hyp_control_back            = (p_rd_op_i[3:0] == H_HCR);
  assign p_vcpu_rd_vgic_type_back              = (p_rd_op_i[3:0] == H_VTR);
  assign p_vcpu_rd_vm_control_alias_back       = (p_rd_op_i[3:0] == H_VMCR);
  assign p_vcpu_rd_maint_int_status_back       = (p_rd_op_i[3:0] == H_MISR);
  assign p_vcpu_rd_eoi_int_status_back         = (p_rd_op_i[3:0] == H_EISR);
  assign p_vcpu_rd_empty_list_status_back      = (p_rd_op_i[3:0] == H_ELSR);
  assign p_vcpu_rd_active_priorities_back      = (p_rd_op_i[3:0] == H_APR);
  assign p_vcpu_rd_list_back                   = (p_rd_op_i[3:2] == H_LR);
  assign p_vcpu_rd_list_sel                    = 4'b0001 << p_rd_op_i[1:0];

  assign p_vcpu_wr_hyp_control_back            = (p_wr_op_i[3:0] == H_HCR);
  assign p_vcpu_wr_vm_control_alias_back       = (p_wr_op_i[3:0] == H_VMCR);
  assign p_vcpu_wr_active_priorities_back      = (p_wr_op_i[3:0] == H_APR);
  assign p_vcpu_wr_list_back                   = (p_wr_op_i[3:2] == H_LR);
  assign p_vcpu_wr_list_sel                    = 4'b0001 << p_wr_op_i[1:0];

  // Decode Virtual Machine view (front-end)
  assign p_vcpu_rd_vm_control_front            = (p_rd_op_i[3:0] == V_CTLR);
  assign p_vcpu_rd_priority_mask_front         = (p_rd_op_i[3:0] == V_PMR);
  assign p_vcpu_rd_binary_point_front          = (p_rd_op_i[3:0] == V_BPR);
  assign p_vcpu_rd_ack_front                   = (p_rd_op_i[3:0] == V_IAR);
  assign p_vcpu_rd_running_priority_front      = (p_rd_op_i[3:0] == V_RPR);
  assign p_vcpu_rd_highest_pending_front       = (p_rd_op_i[3:0] == V_HPPIR);
  assign p_vcpu_rd_binary_point_ns_alias_front = (p_rd_op_i[3:0] == V_ABPR);
  assign p_vcpu_rd_ack_ns_alias_front          = (p_rd_op_i[3:0] == V_AIAR);
  assign p_vcpu_rd_hpi_ns_alias_front          = (p_rd_op_i[3:0] == V_AHPPIR);
  assign p_vcpu_rd_active_priorities_front     = (p_rd_op_i[3:0] == V_APR);

  assign p_vcpu_wr_vm_control_front            = (p_wr_op_i[3:0] == V_CTLR);
  assign p_vcpu_wr_priority_mask_front         = (p_wr_op_i[3:0] == V_PMR);
  assign p_vcpu_wr_binary_point_front          = (p_wr_op_i[3:0] == V_BPR);
  assign p_vcpu_wr_eoi_front                   = (p_wr_op_i[3:0] == V_EOIR);
  assign p_vcpu_wr_binary_point_ns_alias_front = (p_wr_op_i[3:0] == V_ABPR);
  assign p_vcpu_wr_eoi_ns_alias_front          = (p_wr_op_i[3:0] == V_AEOIR);
  assign p_vcpu_wr_active_priorities_front     = (p_wr_op_i[3:0] == V_APR);
  assign p_vcpu_wr_deactivate_front            = (p_wr_op_i[3:0] == V_DIR);

  generate for (vcpu=0; vcpu<NUM_CPUS; vcpu=vcpu+1) begin : g_gic_vcpu_interfaces

    gic400_vcpu_interface
      u_gic_vcpu_interface
        (
          .clk                                (clk),
          .clk_p                              (clk_p),
          .reset_n                            (reset_n),

          .p_read_i                           (p_vcpuif_cpu_read[vcpu]),
          .p_write_i                          (p_vcpuif_cpu_write[vcpu]),
          .p_rd_front_i                       (p_vcpuif_rd_front_i),
          .p_wr_front_i                       (p_vcpuif_wr_front_i),
          .p_wdata_i                          (p_wdata_i[31:0]),
          .p_rdata_o                          (p_vcpuif_cpu_rdata[vcpu][31:0]),

          .p_rd_hyp_control_back_i            (p_vcpu_rd_hyp_control_back),
          .p_rd_vgic_type_back_i              (p_vcpu_rd_vgic_type_back),
          .p_rd_vm_control_alias_back_i       (p_vcpu_rd_vm_control_alias_back),
          .p_rd_maint_int_status_back_i       (p_vcpu_rd_maint_int_status_back),
          .p_rd_eoi_int_status_back_i         (p_vcpu_rd_eoi_int_status_back),
          .p_rd_empty_list_status_back_i      (p_vcpu_rd_empty_list_status_back),
          .p_rd_active_priorities_back_i      (p_vcpu_rd_active_priorities_back),
          .p_rd_list_back_i                   (p_vcpu_rd_list_back),
          .p_rd_list_sel_i                    (p_vcpu_rd_list_sel[3:0]),
          .p_wr_hyp_control_back_i            (p_vcpu_wr_hyp_control_back),
          .p_wr_vm_control_alias_back_i       (p_vcpu_wr_vm_control_alias_back),
          .p_wr_active_priorities_back_i      (p_vcpu_wr_active_priorities_back),
          .p_wr_list_back_i                   (p_vcpu_wr_list_back),
          .p_wr_list_sel_i                    (p_vcpu_wr_list_sel[3:0]),
          .p_rd_vm_control_front_i            (p_vcpu_rd_vm_control_front),
          .p_rd_priority_mask_front_i         (p_vcpu_rd_priority_mask_front),
          .p_rd_binary_point_front_i          (p_vcpu_rd_binary_point_front),
          .p_rd_ack_front_i                   (p_vcpu_rd_ack_front),
          .p_rd_running_priority_front_i      (p_vcpu_rd_running_priority_front),
          .p_rd_highest_pending_front_i       (p_vcpu_rd_highest_pending_front),
          .p_rd_binary_point_ns_alias_front_i (p_vcpu_rd_binary_point_ns_alias_front),
          .p_rd_ack_ns_alias_front_i          (p_vcpu_rd_ack_ns_alias_front),
          .p_rd_hpi_ns_alias_front_i          (p_vcpu_rd_hpi_ns_alias_front),
          .p_rd_active_priorities_front_i     (p_vcpu_rd_active_priorities_front),
          .p_wr_vm_control_front_i            (p_vcpu_wr_vm_control_front),
          .p_wr_priority_mask_front_i         (p_vcpu_wr_priority_mask_front),
          .p_wr_binary_point_front_i          (p_vcpu_wr_binary_point_front),
          .p_wr_eoi_front_i                   (p_vcpu_wr_eoi_front),
          .p_wr_binary_point_ns_alias_front_i (p_vcpu_wr_binary_point_ns_alias_front),
          .p_wr_eoi_ns_alias_front_i          (p_vcpu_wr_eoi_ns_alias_front),
          .p_wr_active_priorities_front_i     (p_vcpu_wr_active_priorities_front),
          .p_wr_deactivate_front_i            (p_vcpu_wr_deactivate_front),

          .deactivate_id_o                    (cpu_vdeactivate_id[vcpu][8:0]),
          .deactivate_o                       (cpu_vdeactivate_o[vcpu]),
          .maintenance_irq_o                  (cpu_maintenance_irq_o[vcpu]),
          .nvfiq_o                            (cpu_nvfiq_o[vcpu]),
          .nvirq_o                            (cpu_nvirq_o[vcpu])
        );

  end endgenerate

  //----------------------------------------------------------------------------
  // CPU Interfaces
  //----------------------------------------------------------------------------

  assign p_cpuif_cpu_write[NUM_CPUS-1:0]  = {NUM_CPUS{p_cpuif_write_i}} & (one_with_zero_extension[NUM_CPUS-1:0] << p_wcpu_i);
  assign p_cpuif_cpu_read[NUM_CPUS-1:0]   = {NUM_CPUS{p_cpuif_read_i}}  & (one_with_zero_extension[NUM_CPUS-1:0] << p_rcpu_i);

  // Decode register addresses. Done here as common between separate
  // interfaces.
  assign p_cpu_rd_control_req               = (p_rd_op_i[3:0] == C_CTLR);
  assign p_cpu_rd_priority_mask_req         = (p_rd_op_i[3:0] == C_PMR);
  assign p_cpu_rd_binary_point_req          = (p_rd_op_i[3:0] == C_BPR);
  assign p_cpu_rd_ack_req                   = (p_rd_op_i[3:0] == C_IAR);     // RO
  assign p_cpu_rd_running_priority_req      = (p_rd_op_i[3:0] == C_RPR);     // RO
  assign p_cpu_rd_highest_pending_req       = (p_rd_op_i[3:0] == C_HPPIR);   // RO
  assign p_cpu_rd_binary_point_ns_alias_req = (p_rd_op_i[3:0] == C_ABPR);
  assign p_cpu_rd_ack_ns_alias_req          = (p_rd_op_i[3:0] == C_AIAR);    // RO
  assign p_cpu_rd_hpi_ns_alias_req          = (p_rd_op_i[3:0] == C_AHPPIR);  // RO
  assign p_cpu_rd_active_priorities_req     = (p_rd_op_i[3:0] == C_APR);
  assign p_cpu_rd_active_priorities_ns_req  = (p_rd_op_i[3:0] == C_NSAPR);

  assign p_cpu_wr_active_priorities_ns_req  = (p_wr_op_i[3:0] == C_NSAPR);
  assign p_cpu_wr_active_priorities_req     = (p_wr_op_i[3:0] == C_APR);
  assign p_cpu_wr_eoi_ns_alias_req          = (p_wr_op_i[3:0] == C_AEOIR);   // WO
  assign p_cpu_wr_binary_point_ns_alias_req = (p_wr_op_i[3:0] == C_ABPR);
  assign p_cpu_wr_eoi_req                   = (p_wr_op_i[3:0] == C_EOIR);    // WO
  assign p_cpu_wr_binary_point_req          = (p_wr_op_i[3:0] == C_BPR);
  assign p_cpu_wr_control_req               = (p_wr_op_i[3:0] == C_CTLR);
  assign p_cpu_wr_priority_mask_req         = (p_wr_op_i[3:0] == C_PMR);
  assign p_cpu_wr_deactivate_req            = (p_wr_op_i[3:0] == C_DIR);     // WO

  generate for (cpu=0; cpu<NUM_CPUS; cpu=cpu+1) begin : g_gic_cpu_interfaces
    gic400_cpu_interface

      u_gic_cpu_interface
        (
          .clk                              (clk),
          .clk_p                            (clk_p),
          .reset_n                          (reset_n),

          .gic_cfgsdisable_i                (gic_cfgsdisable_i),

          .legacy_nfiq_i                    (legacy_nfiq_i[cpu]),
          .legacy_nirq_i                    (legacy_nirq_i[cpu]),

          .ppi_legacy_nfiq_o                (ppi_legacy_nfiq_o[cpu]),
          .ppi_legacy_nirq_o                (ppi_legacy_nirq_o[cpu]),

          .p_read_i                         (p_cpuif_cpu_read[cpu]),
          .p_write_i                        (p_cpuif_cpu_write[cpu]),
          .p_rnsecure_i                     (p_rnsecure_i),
          .p_wnsecure_i                     (p_wnsecure_i),
          .p_wdata_i                        (p_wdata_i[31:0]),
          .p_rdata_o                        (p_cpuif_cpu_rdata[cpu][31:0]),

          .p_rd_control_req_i               (p_cpu_rd_control_req),
          .p_wr_control_req_i               (p_cpu_wr_control_req),
          .p_rd_priority_mask_req_i         (p_cpu_rd_priority_mask_req),
          .p_wr_priority_mask_req_i         (p_cpu_wr_priority_mask_req),
          .p_rd_binary_point_req_i          (p_cpu_rd_binary_point_req),
          .p_wr_binary_point_req_i          (p_cpu_wr_binary_point_req),
          .p_rd_ack_req_i                   (p_cpu_rd_ack_req),
          .p_wr_eoi_req_i                   (p_cpu_wr_eoi_req),
          .p_rd_running_priority_req_i      (p_cpu_rd_running_priority_req),
          .p_rd_highest_pending_req_i       (p_cpu_rd_highest_pending_req),
          .p_rd_binary_point_ns_alias_req_i (p_cpu_rd_binary_point_ns_alias_req),
          .p_wr_binary_point_ns_alias_req_i (p_cpu_wr_binary_point_ns_alias_req),
          .p_rd_ack_ns_alias_req_i          (p_cpu_rd_ack_ns_alias_req),
          .p_wr_eoi_ns_alias_req_i          (p_cpu_wr_eoi_ns_alias_req),
          .p_rd_hpi_ns_alias_req_i          (p_cpu_rd_hpi_ns_alias_req),
          .p_rd_active_priorities_req_i     (p_cpu_rd_active_priorities_req),
          .p_wr_active_priorities_req_i     (p_cpu_wr_active_priorities_req),
          .p_rd_active_priorities_ns_req_i  (p_cpu_rd_active_priorities_ns_req),
          .p_wr_active_priorities_ns_req_i  (p_cpu_wr_active_priorities_ns_req),
          .p_wr_deactivate_req_i            (p_cpu_wr_deactivate_req),

          .high_valid_i                     (cpu_high_valid_i[cpu]),
          .high_nsecure_i                   (cpu_high_nsecure_i[cpu]),
          .high_priority_i                  (cpu_high_priority_i[5*cpu +: 5]),
          .high_id_i                        (cpu_high_id_i[9*cpu +: 9]),
          .high_cpu_i                       (cpu_high_cpu_i[3*cpu +: 3]),

          .deactivate_o                     (cpu_deactivate_o[cpu]),
          .interface_ack_o                  (cpu_ack_o[cpu]),
          .nfiq_out_o                       (cpu_nfiq_out_o[cpu]),
          .nirq_out_o                       (cpu_nirq_out_o[cpu]),
          .nfiq_o                           (cpu_nfiq_o[cpu]),
          .nirq_o                           (cpu_nirq_o[cpu])
        );

  end endgenerate

  wire [31:0] p_id_rdata;

  //----------------------------------------------------------------------------
  // Combine Outputs
  //----------------------------------------------------------------------------

  always @* begin : g_combine_intfs
    integer n;
    reg[31:0] p_vcpuif_rdata_tmp;
    reg[31:0] p_cpuif_rdata_tmp;
    reg[8:0] vdeactivate_id_tmp;

    p_vcpuif_rdata_tmp  = 32'h00000000;
    p_cpuif_rdata_tmp   = 32'h00000000;
    vdeactivate_id_tmp  = 9'b000000000;

    for (n = 0; n < NUM_CPUS; n = n+1) begin
      p_vcpuif_rdata_tmp = p_vcpuif_rdata_tmp  | ({32{p_rcpu_i[2:0] == n[2:0]}} & p_vcpuif_cpu_rdata[n][31:0]);
      p_cpuif_rdata_tmp  = p_cpuif_rdata_tmp   | ({32{p_rcpu_i[2:0] == n[2:0]}} & p_cpuif_cpu_rdata[n][31:0]);
      vdeactivate_id_tmp = vdeactivate_id_tmp  | ( {9{p_wcpu_i[2:0] == n[2:0]}} & cpu_vdeactivate_id[n][8:0]);
    end

    p_vcpuif_rdata  = p_vcpuif_rdata_tmp;
    p_cpuif_rdata   = p_cpuif_rdata_tmp;
    vdeactivate_id  = vdeactivate_id_tmp;
  end

  assign vdeactivate_id_o = vdeactivate_id[8:0];

  // Read Data

  // - The CPU and VCPU IIDR registers read the same value, and are selected by
  // the same opcode on p_rd_op_i, so only one read value is needed.
  assign p_rd_id = (p_rd_op_i[3:0] == C_V_IIDR);

  // - Register revision value for easy modification
  always @(posedge clk)
    if (load_initial_i)
      iidr_revid_q[3:0] <= IIDR_REVISION;

  assign p_id_rdata[31:0] = {PRODUCT_ID[7:0],     // [31:24] = Part Number
                             4'h0,                // [23:20] = Reserved
                             4'h2,                // [19:16] = Architecture version
                             iidr_revid_q[3:0],   // [15:12] = Revision number
                             12'h43b};            // [11:0]  = Implementer ID

  // Form the final read data
  assign p_rdata_o = ({32{p_cpuif_read_i}}  & p_cpuif_rdata[31:0])  |
                     ({32{p_vcpuif_read_i}} & p_vcpuif_rdata[31:0]) |
                     ({32{p_rd_id}}         & p_id_rdata[31:0]);


  //------------------------------------------------------------------------------
  // OVL assertions
  //------------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // The read data from the CPU/VCPU blocks should be zero when there is an
  // IIDR read
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"CPU/VCPU read data was not zero for IIDR read")
  ovl_cpu_vcpu_rdata_id  (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (p_rd_id),
                          .consequent_expr  ((p_cpuif_rdata[31:0] | p_vcpuif_rdata[31:0]) == {32{1'b0}}));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_i")
  u_ovl_x_load_initial_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (load_initial_i));


`endif

endmodule

