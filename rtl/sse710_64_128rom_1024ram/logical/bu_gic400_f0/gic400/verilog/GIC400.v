//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-06-16 17:57:51 +0100 (Thu, 16 Jun 2011) $
//
//      Revision            : $Revision: 175532 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//   Top-level module for the GIC-400 Generic Interrupt Controller
//------------------------------------------------------------------------------

module GIC400 #(
                 `include "GIC400_CONFIG.v"       // User modifiable parameters
                 parameter _CORTEXA7_INTERNAL = 0 // Not user modifiable: is instantiated within a Cortex-A7 core
               ) 
(
  // Clocks and resets
  input  wire                       CLK,
  input  wire                       nRESET,
  input  wire                       DFTRSTDISABLE,
  input  wire                       DFTSE,

  // Configuration inputs
  input  wire                       CFGSDISABLE,    // Secure disable

  // AXI read address channel
  input  wire    [NUM_RID_BITS-1:0] ARID,
  input  wire                [14:0] ARADDR,
  input  wire                 [7:0] ARLEN,
  input  wire                 [2:0] ARSIZE,
  input  wire                 [1:0] ARBURST,
  input  wire                 [2:0] ARPROT,
  input  wire                 [2:0] ARUSER,
  input  wire                       ARVALID,
  output wire                       ARREADY,

  // AXI read data channel
  output wire    [NUM_RID_BITS-1:0] RID,
  output wire                [31:0] RDATA,
  output wire                       RLAST,
  output wire                 [1:0] RRESP,
  output wire                       RVALID,
  input  wire                       RREADY,

  // AXI write address channel
  input  wire    [NUM_WID_BITS-1:0] AWID,
  input  wire                [14:0] AWADDR,
  input  wire                 [7:0] AWLEN,
  input  wire                 [2:0] AWSIZE,
  input  wire                 [1:0] AWBURST,
  input  wire                 [2:0] AWPROT,
  input  wire                 [2:0] AWUSER,
  input  wire                       AWVALID,
  output wire                       AWREADY,

  // AXI write data channel
  input  wire                [31:0] WDATA,
  input  wire                 [3:0] WSTRB,
  input  wire                       WVALID,
  output wire                       WREADY,

  // AXI write response channel
  output wire    [NUM_WID_BITS-1:0] BID,
  output wire                 [1:0] BRESP,
  output wire                       BVALID,
  input  wire                       BREADY,

  // Shared Peripheral Interrupts
  input  wire [spi_msb(NUM_SPIS):0] IRQS,

  // Private Peripheral Interrupts
  input  wire        [NUM_CPUS-1:0] nLEGACYFIQ,  // Legacy FIQ (PPI0)
  input  wire        [NUM_CPUS-1:0] nLEGACYIRQ,  // Legacy IRQ (PPI3)
  input  wire        [NUM_CPUS-1:0] nCNTPSIRQ,   // Physical timer secure (PPI1)
  input  wire        [NUM_CPUS-1:0] nCNTPNSIRQ,  // Physical timer non-secure (PPI2)
  input  wire        [NUM_CPUS-1:0] nCNTVIRQ,    // Virtual timer (PPI4)
  input  wire        [NUM_CPUS-1:0] nCNTHPIRQ,   // Hypervisor timer event (PPI5)

  // Interrupts for individual cores
  output wire        [NUM_CPUS-1:0] nIRQCPU,
  output wire        [NUM_CPUS-1:0] nFIQCPU,
  output wire        [NUM_CPUS-1:0] nVIRQCPU,
  output wire        [NUM_CPUS-1:0] nVFIQCPU,

  output wire        [NUM_CPUS-1:0] nIRQOUT,
  output wire        [NUM_CPUS-1:0] nFIQOUT
);

  `include "gic400_defs.v"

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  wire                  reset_n;
  wire                  load_initial;
  wire                  clk_p;
  wire                  clk_pri;
  wire                  clk_p_en;
  wire                  clk_pri_en;
  wire   [NUM_CPUS-1:0] cpu_nfiq;
  wire   [NUM_CPUS-1:0] cpu_nirq;
  wire   [NUM_CPUS-1:0] cpu_nvfiq;
  wire   [NUM_CPUS-1:0] cpu_nvirq;
  wire   [NUM_CPUS-1:0] nfiq_out;
  wire   [NUM_CPUS-1:0] nirq_out;
  wire                  p_cpuif_read;
  wire                  p_vcpuif_read;
  wire                  p_vcpuif_rd_front;
  wire                  p_dist_write;
  wire                  p_cpuif_write;
  wire                  p_vcpuif_write;
  wire                  p_vcpuif_wr_front;
  wire            [3:0] p_dist_rd_op;
  wire            [3:0] p_intf_rd_op;
  wire            [2:0] p_rcpu;
  wire            [3:0] p_dist_rd_block;
  wire            [2:0] p_rindex;
  wire                  p_rnsecure;
  wire            [2:0] p_wcpu;
  wire            [3:0] p_dist_wr_op;
  wire            [3:0] p_intf_wr_op;
  wire            [3:0] p_dist_wr_block;
  wire            [2:0] p_windex;
  wire                  p_wnsecure;
  wire            [3:0] p_strb;
  wire           [31:0] p_wdata;
  wire           [31:0] p_dist_rdata;
  wire           [31:0] p_intf_rdata;
  wire   [NUM_CPUS-1:0] ppi_legacy_nirq;
  wire   [NUM_CPUS-1:0] ppi_legacy_nfiq;
  wire   [NUM_CPUS-1:0] cpu_interface_ack;
  wire   [NUM_CPUS-1:0] cpu_deactivate;
  wire            [8:0] vdeactivate_id;
  wire   [NUM_CPUS-1:0] cpu_vdeactivate;
  wire   [NUM_CPUS-1:0] cpu_vinterface_maintenance;
  wire   [NUM_CPUS-1:0] cpu_high_valid;
  wire   [NUM_CPUS-1:0] cpu_high_nsecure;
  wire [5*NUM_CPUS-1:0] cpu_high_priority;
  wire [9*NUM_CPUS-1:0] cpu_high_id;
  wire [3*NUM_CPUS-1:0] cpu_high_cpu;
  wire                  p_priority_recalc_stall;
  wire                  pri_write_allowed;
  wire                  ns_sgi_write_allowed;
  wire                  gic_cfgsdisable;


  //----------------------------------------------------------------------------
  // Reset synchroniser & architectural clock gates
  //----------------------------------------------------------------------------

  gic400_clk u_gic_clk (
    // Inputs
    .CLK              (CLK),
    .nRESET           (nRESET),
    .DFTRSTDISABLE    (DFTRSTDISABLE),
    .DFTSE            (DFTSE),
    .clk_p_en_i       (clk_p_en),
    .clk_pri_en_i     (clk_pri_en),
    // Outputs
    .reset_n_o        (reset_n),
    .clk_p_o          (clk_p),
    .clk_pri_o        (clk_pri),
    .load_initial_o   (load_initial)
  );


  //----------------------------------------------------------------------------
  // AXI slave interface
  //----------------------------------------------------------------------------

  gic400_axi_intf #(.NUM_CPUS(NUM_CPUS),
                    .NUM_RID_BITS(NUM_RID_BITS),
                    .NUM_WID_BITS(NUM_WID_BITS))
    u_gic_axi_intf
     (
      .clk                              (CLK),
      .clk_p                            (clk_p),
      .reset_n                          (reset_n),

      .axi_arid_i                       (ARID),
      .axi_araddr_i                     (ARADDR),
      .axi_arlen_i                      (ARLEN),
      .axi_arsize_i                     (ARSIZE[1:0]),
      .axi_arburst_i                    (ARBURST),
      .axi_arprot_i                     (ARPROT),
      .axi_arcpu_i                      (ARUSER),
      .axi_arvalid_i                    (ARVALID),
      .axi_rready_i                     (RREADY),
      .axi_awid_i                       (AWID),
      .axi_awaddr_i                     (AWADDR),
      .axi_awlen_i                      (AWLEN),
      .axi_awsize_i                     (AWSIZE[1:0]),
      .axi_awburst_i                    (AWBURST),
      .axi_awprot_i                     (AWPROT),
      .axi_awcpu_i                      (AWUSER),
      .axi_awvalid_i                    (AWVALID),
      .axi_wdata_i                      (WDATA),
      .axi_wstrb_i                      (WSTRB),
      .axi_wvalid_i                     (WVALID),
      .axi_bready_i                     (BREADY),

      .p_priority_recalc_stall_i        (p_priority_recalc_stall),
      .pri_write_allowed_i              (pri_write_allowed),
      .ns_sgi_write_allowed_i           (ns_sgi_write_allowed),
      .p_dist_rdata_i                   (p_dist_rdata[31:0]),
      .p_intf_rdata_i                   (p_intf_rdata[31:0]),
      .p_cpuif_read_o                   (p_cpuif_read),
      .p_vcpuif_rd_front_o              (p_vcpuif_rd_front),
      .p_vcpuif_read_o                  (p_vcpuif_read),
      .p_dist_write_o                   (p_dist_write),
      .p_cpuif_write_o                  (p_cpuif_write),
      .p_vcpuif_wr_front_o              (p_vcpuif_wr_front),
      .p_vcpuif_write_o                 (p_vcpuif_write),
      .p_dist_rd_op_o                   (p_dist_rd_op),
      .p_intf_rd_op_o                   (p_intf_rd_op),
      .p_rcpu_o                         (p_rcpu),
      .p_dist_rd_block_o                (p_dist_rd_block),
      .p_rindex_o                       (p_rindex),
      .p_rnsecure_o                     (p_rnsecure),
      .p_dist_wr_op_o                   (p_dist_wr_op),
      .p_intf_wr_op_o                   (p_intf_wr_op),
      .p_wcpu_o                         (p_wcpu),
      .p_dist_wr_block_o                (p_dist_wr_block),
      .p_windex_o                       (p_windex),
      .p_wnsecure_o                     (p_wnsecure),
      .p_strb_o                         (p_strb),
      .p_wdata_o                        (p_wdata),
      .clk_p_en_o                       (clk_p_en),

      .axi_arready_o                    (ARREADY),
      .axi_rid_o                        (RID),
      .axi_rdata_o                      (RDATA),
      .axi_rlast_o                      (RLAST),
      .axi_rresp_o                      (RRESP),
      .axi_rvalid_o                     (RVALID),
      .axi_awready_o                    (AWREADY),
      .axi_wready_o                     (WREADY),
      .axi_bid_o                        (BID),
      .axi_bresp_o                      (BRESP),
      .axi_bvalid_o                     (BVALID)
     );

  //----------------------------------------------------------------------------
  // Distributor
  //----------------------------------------------------------------------------

  gic400_distributor #(.NUM_CPUS(NUM_CPUS),
                       .NUM_SPIS(NUM_SPIS),
                       ._CORTEXA7_INTERNAL(_CORTEXA7_INTERNAL))
    u_gic_distributor
      (
        .clk                              (CLK),
        .clk_p                            (clk_p),
        .clk_pri                          (clk_pri),
        .reset_n                          (reset_n),
        .cfgsdisable_i                    (CFGSDISABLE),
        .load_initial_i                   (load_initial),
        .gic_cfgsdisable_o                (gic_cfgsdisable),
        .clk_pri_en_o                     (clk_pri_en),

        .irqs_i                           (IRQS),
        .cpu_tm_cnthp_nirq_i              (nCNTHPIRQ),
        .cpu_tm_cntp_ns_nirq_i            (nCNTPNSIRQ),
        .cpu_tm_cntp_s_nirq_i             (nCNTPSIRQ),
        .cpu_tm_cntv_nirq_i               (nCNTVIRQ),
        .ppi_legacy_nirq_i                (ppi_legacy_nirq),
        .ppi_legacy_nfiq_i                (ppi_legacy_nfiq),
        .cpu_vinterface_maintenance_i     (cpu_vinterface_maintenance),

        .p_rdata_o                        (p_dist_rdata[31:0]),
        .p_write_i                        (p_dist_write),
        .p_vcpuif_write_i                 (p_vcpuif_write),
        .p_rd_op_i                        (p_dist_rd_op[3:0]),
        .p_rcpu_i                         (p_rcpu[2:0]),
        .p_rd_block_i                     (p_dist_rd_block[3:0]),
        .p_rindex_i                       (p_rindex[2:0]),
        .p_rnsecure_i                     (p_rnsecure),
        .p_wr_op_i                        (p_dist_wr_op[3:0]),
        .p_wcpu_i                         (p_wcpu[2:0]),
        .p_wr_block_i                     (p_dist_wr_block[3:0]),
        .p_windex_i                       (p_windex[2:0]),
        .p_wnsecure_i                     (p_wnsecure),
        .p_strb_i                         (p_strb[3:0]),
        .p_wdata_i                        (p_wdata[31:0]),
        .p_priority_recalc_stall_o        (p_priority_recalc_stall),
        .pri_write_allowed_o              (pri_write_allowed),
        .ns_sgi_write_allowed_o           (ns_sgi_write_allowed),

        .cpu_interface_ack_i              (cpu_interface_ack),
        .cpu_deactivate_i                 (cpu_deactivate),
        .cpu_vdeactivate_i                (cpu_vdeactivate),
        .vdeactivate_id_i                 (vdeactivate_id),

        .cpu_high_valid_o                 (cpu_high_valid[NUM_CPUS-1:0]),
        .cpu_high_id_o                    (cpu_high_id[9*NUM_CPUS-1:0]),
        .cpu_high_nsecure_o               (cpu_high_nsecure[NUM_CPUS-1:0]),
        .cpu_high_priority_o              (cpu_high_priority[5*NUM_CPUS-1:0]),
        .cpu_high_cpu_o                   (cpu_high_cpu[3*NUM_CPUS-1:0])
      );

  //----------------------------------------------------------------------------
  // CPU & VCPU Interfaces
  //----------------------------------------------------------------------------

  gic400_interfaces #(.NUM_CPUS(NUM_CPUS),
                      ._CORTEXA7_INTERNAL(_CORTEXA7_INTERNAL))
    u_gic_interfaces
      (
        .clk                              (CLK),
        .clk_p                            (clk_p),
        .reset_n                          (reset_n),
        .load_initial_i                   (load_initial),
        .gic_cfgsdisable_i                (gic_cfgsdisable),

        .p_vcpuif_read_i                  (p_vcpuif_read),
        .p_vcpuif_write_i                 (p_vcpuif_write),
        .p_cpuif_read_i                   (p_cpuif_read),
        .p_cpuif_write_i                  (p_cpuif_write),
        .p_rcpu_i                         (p_rcpu[2:0]),
        .p_wcpu_i                         (p_wcpu[2:0]),
        .p_rnsecure_i                     (p_rnsecure),
        .p_wnsecure_i                     (p_wnsecure),
        .p_rd_op_i                        (p_intf_rd_op[3:0]),
        .p_wr_op_i                        (p_intf_wr_op[3:0]),
        .p_vcpuif_rd_front_i              (p_vcpuif_rd_front),
        .p_vcpuif_wr_front_i              (p_vcpuif_wr_front),
        .p_wdata_i                        (p_wdata[31:0]),
        .p_rdata_o                        (p_intf_rdata[31:0]),

        .cpu_high_valid_i                 (cpu_high_valid[NUM_CPUS-1:0]),
        .cpu_high_nsecure_i               (cpu_high_nsecure[NUM_CPUS-1:0]),
        .cpu_high_priority_i              (cpu_high_priority[5*NUM_CPUS-1:0]),
        .cpu_high_id_i                    (cpu_high_id[9*NUM_CPUS-1:0]),
        .cpu_high_cpu_i                   (cpu_high_cpu[3*NUM_CPUS-1:0]),

        .cpu_deactivate_o                 (cpu_deactivate[NUM_CPUS-1:0]),
        .cpu_vdeactivate_o                (cpu_vdeactivate[NUM_CPUS-1:0]),
        .vdeactivate_id_o                 (vdeactivate_id[8:0]),
        .cpu_ack_o                        (cpu_interface_ack[NUM_CPUS-1:0]),

        .legacy_nirq_i                    (nLEGACYIRQ[NUM_CPUS-1:0]),
        .legacy_nfiq_i                    (nLEGACYFIQ[NUM_CPUS-1:0]),
        .ppi_legacy_nirq_o                (ppi_legacy_nirq[NUM_CPUS-1:0]),
        .ppi_legacy_nfiq_o                (ppi_legacy_nfiq[NUM_CPUS-1:0]),
        .cpu_nirq_out_o                   (nirq_out[NUM_CPUS-1:0]),
        .cpu_nfiq_out_o                   (nfiq_out[NUM_CPUS-1:0]),
        .cpu_nirq_o                       (cpu_nirq[NUM_CPUS-1:0]),
        .cpu_nfiq_o                       (cpu_nfiq[NUM_CPUS-1:0]),
        .cpu_nvirq_o                      (cpu_nvirq[NUM_CPUS-1:0]),
        .cpu_nvfiq_o                      (cpu_nvfiq[NUM_CPUS-1:0]),
        .cpu_maintenance_irq_o            (cpu_vinterface_maintenance[NUM_CPUS-1:0])
      );

  //----------------------------------------------------------------------------
  // Output generation
  //----------------------------------------------------------------------------

  assign nFIQOUT     = nfiq_out[NUM_CPUS-1:0];
  assign nIRQOUT     = nirq_out[NUM_CPUS-1:0];

  assign nIRQCPU     = cpu_nirq[NUM_CPUS-1:0];
  assign nFIQCPU     = cpu_nfiq[NUM_CPUS-1:0];
  assign nVIRQCPU    = cpu_nvirq[NUM_CPUS-1:0];
  assign nVFIQCPU    = cpu_nvfiq[NUM_CPUS-1:0];


endmodule

