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
//      Checked In          : $Date: 2011-08-03 15:09:44 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180427 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//   AXI slave interface for the interrupt controller. Responsible for
//   accepting AXI transactions and issuing corresponding transactions to the
//   GICs internal programming interface.
//------------------------------------------------------------------------------

module gic400_axi_intf #(parameter NUM_CPUS = 4,
                         parameter NUM_WID_BITS = 4,
                         parameter NUM_RID_BITS = 4)
(
  // Clocks and resets
  input  wire                    clk,
  input  wire                    clk_p,
  input  wire                    reset_n,

  output wire                    clk_p_en_o,

  // AXI read address channel
  input  wire [NUM_RID_BITS-1:0] axi_arid_i,
  input  wire             [14:0] axi_araddr_i,
  input  wire              [7:0] axi_arlen_i,
  input  wire              [1:0] axi_arsize_i,
  input  wire              [1:0] axi_arburst_i,
  input  wire              [2:0] axi_arprot_i,
  input  wire              [2:0] axi_arcpu_i,
  input  wire                    axi_arvalid_i,
  output wire                    axi_arready_o,

  // AXI read data channel
  output wire [NUM_RID_BITS-1:0] axi_rid_o,
  output wire             [31:0] axi_rdata_o,
  output wire                    axi_rlast_o,
  output wire              [1:0] axi_rresp_o,
  output wire                    axi_rvalid_o,
  input  wire                    axi_rready_i,

  // AXI write address channel
  input  wire [NUM_WID_BITS-1:0] axi_awid_i,
  input  wire             [14:0] axi_awaddr_i,
  input  wire              [7:0] axi_awlen_i,
  input  wire              [1:0] axi_awsize_i,
  input  wire              [1:0] axi_awburst_i,
  input  wire              [2:0] axi_awprot_i,
  input  wire              [2:0] axi_awcpu_i,
  input  wire                    axi_awvalid_i,
  output wire                    axi_awready_o,

  // AXI write data channel
  input  wire             [31:0] axi_wdata_i,
  input  wire              [3:0] axi_wstrb_i,
  input  wire                    axi_wvalid_i,
  output wire                    axi_wready_o,

  // AXI write response channel
  output wire [NUM_WID_BITS-1:0] axi_bid_o,
  output wire              [1:0] axi_bresp_o,
  output wire                    axi_bvalid_o,
  input  wire                    axi_bready_i,

  // Internal Programming Interface
  output wire                    p_cpuif_read_o,
  output wire                    p_vcpuif_read_o,
  output wire                    p_vcpuif_rd_front_o,

  output wire              [3:0] p_dist_rd_op_o,
  output wire              [3:0] p_intf_rd_op_o,
  output wire              [3:0] p_dist_rd_block_o,
  output wire              [2:0] p_rindex_o,
  output wire                    p_rnsecure_o,
  input  wire             [31:0] p_dist_rdata_i,
  input  wire             [31:0] p_intf_rdata_i,

  output wire              [2:0] p_rcpu_o,
  output wire                    p_dist_write_o,
  output wire                    p_cpuif_write_o,
  output wire                    p_vcpuif_wr_front_o,
  output wire                    p_vcpuif_write_o,


  output wire              [3:0] p_dist_wr_op_o,
  output wire              [3:0] p_intf_wr_op_o,
  output wire              [3:0] p_dist_wr_block_o,
  output wire              [2:0] p_windex_o,
  output wire                    p_wnsecure_o,
  output wire              [3:0] p_strb_o,
  output wire             [31:0] p_wdata_o,
  output wire              [2:0] p_wcpu_o,

  input  wire                    p_priority_recalc_stall_i,
  input  wire                    pri_write_allowed_i,
  input  wire                    ns_sgi_write_allowed_i

);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  reg  [NUM_RID_BITS-1:0] axi_rid_q;
  reg  [NUM_WID_BITS-1:0] axi_bid_q;
  wire                    axi_awready;
  wire                    axi_arready;
  reg                     axi_wready_q;
  wire                    nxt_axi_wready;
  wire                    axi_bresp_en;
  reg                     axi_bunpred_q;
  wire              [1:0] axi_bresp;
  wire                    nxt_axi_bvalid;
  reg                     axi_bvalid_q;
  wire                    axi_read_en;
  wire                    nxt_axi_rvalid;
  reg                     axi_rvalid_q;
  reg                     axi_runpred_q;
  wire              [1:0] axi_rresp;
  reg                     axi_rlast_q;
  wire             [31:0] nxt_axi_rdata;
  reg              [31:0] axi_rdata_q;
  wire                    new_axi_wdata;

  wire [NUM_WID_BITS-1:0] p0w_id;
  wire             [14:2] p0w_addr;
  wire                    p0w_valid;
  wire                    p0w_last;
  wire                    p0w_nsecure;
  wire              [2:0] p0w_cpu;
  wire             [14:2] p0r_addr;
  wire                    p0r_valid;
  wire                    p0r_last;
  wire [NUM_RID_BITS-1:0] p0r_id;
  wire                    p0r_nsecure;
  wire              [2:0] p0r_cpu;
  wire              [1:0] p0r_size;
  reg              [31:0] p0w_data_q;
  reg               [3:0] p0w_strb_q;
  wire                    nxt_p0w_data_valid;
  reg                     p0w_data_valid_q;
  wire                    read_to_wait_for_recalc_p0r;
  wire                    read_to_wait_for_eoi_deac_p0r;
  wire                    stall_p0w;
  wire                    stall_p0r;

  wire                    p1r_enable;
  wire                    p1w_enable;
  wire                    p1r_valid;
  wire                    p1w_valid;
  wire                    p1w_last;
  wire              [2:0] p1r_cpu;
  wire              [3:0] p1r_dist_op;
  wire              [3:0] p1r_intf_op;
  wire              [2:0] p1w_cpu;
  wire              [3:0] p1w_dist_op;
  wire              [3:0] p1w_intf_op;
  wire              [3:0] p1r_dist_block;
  wire              [3:0] p1w_dist_block;
  wire                    p1r_unpred;
  wire                    p1w_unpred;
  wire              [2:0] p1r_index;
  wire              [2:0] p1w_index;
  reg               [3:0] p1w_strb_q;
  reg              [31:0] p1w_wdata_q;
  wire                    p1r_dist_valid;
  wire                    p1w_dist_valid;
  wire                    p1r_cpuif_valid;
  wire                    p1w_cpuif_valid;
  wire                    p1r_vcpuif_valid;
  wire                    p1r_vcpuif_front;
  wire                    p1w_vcpuif_valid;
  wire                    p1w_vcpuif_front;
  wire                    p1r_nsecure;
  wire                    p1r_last;
  wire                    p1w_nsecure;
  wire [NUM_RID_BITS-1:0] p1r_id;
  wire [NUM_WID_BITS-1:0] p1w_id;
  wire                    eoi_deactivate_p1w;
  wire                    read_to_wait_for_vcpu_recalc_p0r;
  wire                    vcpu_recalc_stall;

  wire                    nxt_p2w_unpred;
  wire                    nxt_p2r_valid;
  reg                     p2r_valid_q;
  reg              [31:0] p2r_dist_data_q;
  wire                    p2r_intf_data_en;
  reg              [31:0] p2r_intf_data_q;
  reg                     p2r_unpred_q;
  reg                     p2r_dist_valid_q;
  reg                     p2r_last_q;
  wire                    nxt_p2w_valid;
  wire                    p2w_id_en;
  reg                     p2w_valid_q;
  reg                     p2w_unpred_q;
  reg  [NUM_WID_BITS-1:0] p2w_id_q;
  reg  [NUM_RID_BITS-1:0] p2r_id_q;

  wire                    nxt_clk_p_en;
  reg                     clk_p_en;

  //----------------------------------------------------------------------------
  // Main Code
  //----------------------------------------------------------------------------

  // There are 4 register stages separating the AXI inputs from the
  // subsequent outputs:
  // - The AR, AW, and W inputs are registered to form a P0 address. For
  //   bursts, a single AXI transaction results in a number of P0 transactions.
  // - The addresses are decoded in P0 and registered again to form P1
  //   transactions which are sent to the internal programming interface.
  //   Transactions can stall in P0, but never stall in P1. The internal
  //   interface generates read data combinatorially, and applies the effect of
  //   transactions on the same cycle they are driven.
  // - The read data or response for a P1 transaction is registered in the
  //   interface to form a P2 result.
  // - The P2 registers drive the output registers, which connect to the AXI
  //   R and B outputs.
  //
  // To reduce the amount of buffering required in the AXI interface, the
  // interface can only accept new transactions at a maximum rate of one
  // every other cycle.
  //
  // Reads and writes are treated independently and the internal programming
  // interface can accept a read and write concurrently.


  //----------------------------------------------------------------------------
  // AXI AR
  //----------------------------------------------------------------------------

  // Accept new AR transactions from AXI and convert to the correct number of
  // P0 transactions for the burst.

  gic400_axi_intf_addr_unpack #(.NUM_ID_BITS(NUM_RID_BITS))
    u_gic_axi_intf_addr_unpack_rd
      (
       .clk               (clk),
       .reset_n           (reset_n),
       .axi_addr_i        (axi_araddr_i),
       .axi_size_i        (axi_arsize_i),
       .axi_burst_i       (axi_arburst_i),
       .axi_len_i         (axi_arlen_i),
       .axi_prot_i        (axi_arprot_i),
       .axi_cpu_i         (axi_arcpu_i),
       .axi_id_i          (axi_arid_i),
       .axi_valid_i       (axi_arvalid_i),
       .axi_ready_o       (axi_arready),
       .defer_axi_ready_i (1'b0),

       .p0_ready_i        (p1r_enable),
       .p0_valid_o        (p0r_valid),
       .p0_addr_o         (p0r_addr),
       .p0_last_o         (p0r_last),
       .p0_cpu_o          (p0r_cpu),
       .p0_size_o         (p0r_size),
       .p0_nsecure_o      (p0r_nsecure),
       .p0_id_o           (p0r_id)
      );

  assign axi_arready_o = axi_arready;

  //----------------------------------------------------------------------------
  // AXI AW & W
  //----------------------------------------------------------------------------

  gic400_axi_intf_addr_unpack #(.NUM_ID_BITS(NUM_WID_BITS))
    u_gic_axi_intf_addr_unpack_wr
      (
       .clk               (clk),
       .reset_n           (reset_n),

       .axi_addr_i        (axi_awaddr_i),
       .axi_size_i        (axi_awsize_i),
       .axi_burst_i       (axi_awburst_i),
       .axi_len_i         (axi_awlen_i),
       .axi_prot_i        (axi_awprot_i),
       .axi_cpu_i         (axi_awcpu_i),
       .axi_id_i          (axi_awid_i),
       .axi_valid_i       (axi_awvalid_i),
       .axi_ready_o       (axi_awready),
       .defer_axi_ready_i (p0r_valid),      // Don't accept new transaction if it would block a read

       .p0_ready_i        (p1w_enable),
       .p0_valid_o        (p0w_valid),
       .p0_addr_o         (p0w_addr),
       .p0_last_o         (p0w_last),
       .p0_cpu_o          (p0w_cpu),
       .p0_size_o         (),
       .p0_nsecure_o      (p0w_nsecure),
       .p0_id_o           (p0w_id)
      );


  // Register the W-transfer and set p0w_data_valid_q while it is valid
  assign new_axi_wdata = axi_wvalid_i & axi_wready_q;

  assign nxt_p0w_data_valid = new_axi_wdata |                   // Set when new data accepted from AXI
                              (p0w_data_valid_q & ~p1w_enable); // Maintain until accepted by programming interface

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      p0w_data_valid_q <= 1'b0;
    else
      p0w_data_valid_q <= nxt_p0w_data_valid;

  always @(posedge clk)
    if (new_axi_wdata) begin
      p0w_data_q <= axi_wdata_i;
      p0w_strb_q <= axi_wstrb_i;
    end

  // We can accept data into the W buffer if there is going to be space. New
  // data can be accepted at most once every two cycles.
  assign nxt_axi_wready = ~new_axi_wdata & (~p0w_data_valid_q | p1w_enable);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      axi_wready_q <= 1'b0;
    else
      axi_wready_q <= nxt_axi_wready;

  // Outputs to AXI
  assign axi_awready_o = axi_awready;
  assign axi_wready_o  = axi_wready_q;


  //----------------------------------------------------------------------------
  // Register programming interface (P1)
  //----------------------------------------------------------------------------

  // Transactions are issued from P0 to P1, where they are presented to the
  // internal programming interface, when there is no current transaction in
  // P1 (transactions are issued at most once every two cycles to match the
  // throughput on AXI), and the P0 transaction does not need to stall.


  // When there has been an access to an architectural register which can
  // affect which interrupt is forwarded from the distributor to a CPU
  // interface, a read which could expose the result of the write is stalled
  // until the priority logic in the distributor has recalculated the result,
  // to ensure that software always has a consistent view of the GIC state.
  //
  // The distributor tracks when there has been a necessary access, but since
  // ACK reads and EOI/deactivate writes take an extra cycle to take effect,
  // reads also need to stall in P0 whenever there is one of those accesses
  // in P1, as the signal from the distributor will not become set until the
  // following cycle. For ACKs this is not an issue, as a P0 read cannot be
  // issued when there is a read in P1, but the EOI/deactivate case needs to
  // be accounted for.

  // - The registers which can expose the result of a change to the priority
  // calculation inputs are:
  assign read_to_wait_for_recalc_p0r = (p0r_addr[14:2] == AXI_C_IAR)   | // GICC_IAR
                                       (p0r_addr[14:2] == AXI_C_AIAR)  | // GICC_AIAR
                                       (p0r_addr[14:2] == AXI_C_HPPIR) | // GICC_HPPIR
                                       (p0r_addr[14:2] == AXI_C_AHPPIR); // GICC_AHPPIR

  // - The writes which could cause prioritry_recalc_in_progress to become
  // set on the next cycle are EOIs and Deactivates:
  assign eoi_deactivate_p1w = (p1w_cpuif_valid  & ((p1w_intf_op == C_EOIR)  |   // GICC_EOIR
                                                   (p1w_intf_op == C_AEOIR) |   // GICC_AEOIR
                                                   (p1w_intf_op == C_DIR)))  |  // GICC_DIR
                              (p1w_vcpuif_valid &
                               p1w_vcpuif_front & ((p1w_intf_op == V_EOIR)  |   // GICV_EOIR
                                                   (p1w_intf_op == V_AEOIR) |   // GICV_AEOIR
                                                   (p1w_intf_op == V_DIR)));    // GICV_DIR

  // Writes to the EOI/deactivate registers can also change the architectural
  // active state of a register. As the writes take an extra cycle to take
  // effect, reads of the IxACTIVER registers must stall for a cycle in P0
  // when the EOI/deactivate write is in P1, ensuring that the registers will
  // have been updated by the time the read reaches P1.
  assign read_to_wait_for_eoi_deac_p0r = (p0r_addr[14:8] ==  7'b001_0011); // GICD_IxACTIVER
  // - NB this decode covers all architectural GICD_IxACTIVER registers, even
  // those which are not implemented. This is fine however, as it just means
  // that the RESERVED accesses will stall unnecessarily.

  // In the Virtual CPU interfaces, changes in the list state take one extra
  // cycle to be reflected in the highest pending interrupt registers.
  // Therefore read which can expose the result need to stall for an extra
  // cycle.

  // - The reads which can expose the result are:
  assign read_to_wait_for_vcpu_recalc_p0r = (p0r_addr[14:2] == AXI_V_HPPIR)  |  // GICV_HPPIR
                                            (p0r_addr[14:2] == AXI_V_AHPPIR) |  // GICV_AHPPIR
                                            (p0r_addr[14:2] == AXI_V_IAR)    |  // GICV_IAR
                                            (p0r_addr[14:2] == AXI_V_AIAR);     // GICV_AIAR

  // - The writes which could case the list state to change are:
  assign vcpu_recalc_stall = p1w_vcpuif_valid &
                             (p1w_vcpuif_front ? ((p1w_intf_op == V_EOIR)  |    // GICV_EOIR
                                                  (p1w_intf_op == V_AEOIR) |    // GICV_AEOIR
                                                  (p1w_intf_op == V_DIR))       // GICV_DIR
                                               : (p1w_intf_op[3:2] == H_LR));   // GICH_LR{0-3}

  
  // to verify without impacting the most crucial use-cases.
  // - To ensure multi-copy atomicity of accesses, without requiring address
  // hazarding, reads are never issued to the programming interface when
  // there is a write burst in progress. To ensure reads are not held off
  // indefinitely, new write transactions are blocked on AXI when there is
  // a read pending.
  assign stall_p0r = p0w_valid |                          // Stall on writes
                     (read_to_wait_for_recalc_p0r &       // Or if read should wait for IRQ recalculation:
                      (p_priority_recalc_stall_i |        // - and distributor indicates recalculation in progress
                       eoi_deactivate_p1w)) |             // - or it might do on the next cycle because of a P1 write
                     (read_to_wait_for_eoi_deac_p0r &     // Or if read should wait for EOI/deactivate to take effect:
                      eoi_deactivate_p1w) |               // - and EOI/deactivate in P1
                     (read_to_wait_for_vcpu_recalc_p0r &  // Or if read should wait for VCPU recalculation:
                      vcpu_recalc_stall);                 // - and recalculation in progress

  // Issue a read when there is no stall, and there is guaranteed to be room
  // for the read data to be stored.
  assign p1r_enable  = p0r_valid &                     // Transaction available
                       ~stall_p0r &                    // Not stalled
                       ~p1r_valid &                    // Can't issue back to back
                       ~(p2r_valid_q & axi_rvalid_q);  // Don't issue if read buffer and AXI buffer full

  // The priority logic requires that the values of the interrupt priority,
  // interrupt security and, for SGIs, the source CPU, do not change at
  // certain points during the iteration. This means these values to not have
  // to be registered inside the priority block, which would require
  // significant area. The priority block indicates when writes to these
  // registers must stall, and in those cases, the writes stall in P0.
  assign stall_p0w = (~pri_write_allowed_i    &  (p0w_addr[14:10] == 5'b001_01)) |      // GICD_IPRIORITYR
                     (~ns_sgi_write_allowed_i & ((p0w_addr[14:7]  == 8'b001_0000_1) |   // GICD_IGROUP
                                                 (p0w_addr[14:7]  == 8'b001_1111_0)));  // GICD_SGIR, GICD_xPENDSGIR (either can change source CPU)
  // - NB these decodes include some RESERVED addresses to simplify
  // the decode, so accesses to those addresses may stall unnecessarily.

  // Issue a write when there is no stall, and there is guaranteed to be room
  // for the write response to be stored.
  assign p1w_enable = p0w_valid & p0w_data_valid_q &  // Transaction available
                      ~stall_p0w &                    // Not stalled
                      ~p1w_valid &                    // Can't issue back to back
                      ~(p2w_valid_q & axi_bvalid_q);  // Don't issue if resp buffer and AXI buffer full

  // The addresses presented by AXI are re-encoded to a format which is
  // easier to decode by the different internal blocks.

  gic400_axi_intf_p1_tx_gen #(.RD(1),
                              .NUM_ID_BITS(NUM_RID_BITS))
    u_p1_tx_gen_rd
      (
       .clk               (clk),
       .reset_n           (reset_n),

       .p0_addr_i         (p0r_addr[14:2]),
       .p0_nsecure_i      (p0r_nsecure),
       .p0_cpu_i          (p0r_cpu[2:0]),
       .p0_strb_i         (4'b0000),
       .p0_size_i         (p0r_size[1:0]),
       .p0_last_i         (p0r_last),
       .p0_id_i           (p0r_id),
       .p0_wdata_9to2_i   (8'h00),

       .p1_enable_i       (p1r_enable),

       .p1_dist_req_o     (p1r_dist_valid),
       .p1_cpuif_req_o    (p1r_cpuif_valid),
       .p1_vcpuif_req_o   (p1r_vcpuif_valid),
       .p1_dist_op_o      (p1r_dist_op[3:0]),
       .p1_intf_op_o      (p1r_intf_op[3:0]),
       .p1_nsecure_o      (p1r_nsecure),
       .p1_dist_block_o   (p1r_dist_block[3:0]),
       .p1_cpu_o          (p1r_cpu[2:0]),
       .p1_unpred_o       (p1r_unpred),
       .p1_vcpuif_front_o (p1r_vcpuif_front),
       .p1_index_o        (p1r_index),
       .p1_id_o           (p1r_id),
       .p1_last_o         (p1r_last)
      );

  gic400_axi_intf_p1_tx_gen #(.RD(0),
                              .NUM_ID_BITS(NUM_WID_BITS))
    u_p1_tx_gen_wr
      (
       .clk               (clk),
       .reset_n           (reset_n),

       .p0_addr_i         (p0w_addr[14:2]),
       .p0_nsecure_i      (p0w_nsecure),
       .p0_cpu_i          (p0w_cpu[2:0]),
       .p0_strb_i         (p0w_strb_q),
       .p0_size_i         (2'b00),
       .p0_last_i         (p0w_last),
       .p0_id_i           (p0w_id),
       .p0_wdata_9to2_i   (p0w_data_q[9:2]),

       .p1_enable_i       (p1w_enable),

       .p1_dist_req_o     (p1w_dist_valid),
       .p1_cpuif_req_o    (p1w_cpuif_valid),
       .p1_vcpuif_req_o   (p1w_vcpuif_valid),
       .p1_dist_op_o      (p1w_dist_op[3:0]),
       .p1_intf_op_o      (p1w_intf_op[3:0]),
       .p1_nsecure_o      (p1w_nsecure),
       .p1_dist_block_o   (p1w_dist_block[3:0]),
       .p1_cpu_o          (p1w_cpu[2:0]),
       .p1_unpred_o       (p1w_unpred),
       .p1_vcpuif_front_o (p1w_vcpuif_front),
       .p1_index_o        (p1w_index),
       .p1_id_o           (p1w_id),
       .p1_last_o         (p1w_last)
      );


  // For writes, need to register strobes and write data as well
  always @(posedge clk)
    if (p1w_enable) begin
      p1w_strb_q[3:0]   <= p0w_strb_q[3:0];
      p1w_wdata_q[31:0] <= p0w_data_q[31:0];
    end

  // Indicate when a read or write of any type is valid in P1
  assign p1w_valid  = p1w_dist_valid | p1w_cpuif_valid | p1w_vcpuif_valid;
  assign p1r_valid  = p1r_dist_valid | p1r_cpuif_valid | p1r_vcpuif_valid;

  // The programming interface clock is enabled whenever there is an access
  // in P1 or P2, so that it can be used for transactions with side effects
  // in the programming interface, and the P1, P2 and AXI output registers 
  // in the AXI interface.
  assign nxt_clk_p_en = p1w_enable  | p1r_enable |
                        p1w_valid   | p1r_valid  |
                        p2w_valid_q | p2r_valid_q;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      clk_p_en <= 1'b0;
    else
      clk_p_en <= nxt_clk_p_en;

  assign clk_p_en_o = clk_p_en;

  // Programming interface outputs to internal GIC blocks
  assign p_cpuif_read_o         = p1r_cpuif_valid;
  assign p_vcpuif_read_o        = p1r_vcpuif_valid;

  assign p_dist_rd_op_o         = p1r_dist_op[3:0];
  assign p_dist_rd_block_o      = p1r_dist_block[3:0];
  assign p_intf_rd_op_o         = p1r_intf_op[3:0];
  assign p_vcpuif_rd_front_o    = p1r_vcpuif_front;
  assign p_rcpu_o               = p1r_cpu[2:0];
  assign p_rnsecure_o           = p1r_nsecure;
  assign p_rindex_o             = p1r_index[2:0];

  assign p_dist_write_o         = p1w_dist_valid;
  assign p_cpuif_write_o        = p1w_cpuif_valid;
  assign p_vcpuif_write_o       = p1w_vcpuif_valid;

  assign p_dist_wr_op_o         = p1w_dist_op[3:0];
  assign p_dist_wr_block_o      = p1w_dist_block[3:0];
  assign p_intf_wr_op_o         = p1w_intf_op[3:0];
  assign p_vcpuif_wr_front_o    = p1w_vcpuif_front;
  assign p_wcpu_o               = p1w_cpu[2:0];
  assign p_wnsecure_o           = p1w_nsecure;
  assign p_windex_o             = p1w_index[2:0];
  assign p_strb_o               = p1w_strb_q[3:0];
  assign p_wdata_o              = p1w_wdata_q[31:0];


  //----------------------------------------------------------------------------
  // Read Data
  //----------------------------------------------------------------------------

  // Register read data for reads from every new address
  // - The read data from the distributor and interfaces is late, so
  // a separate read data register is used for each source, which are
  // combined on the next cycle.

  assign nxt_p2r_valid = p1r_valid | (p2r_valid_q & axi_rvalid_q);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      p2r_valid_q <= 1'b0;
    else
      p2r_valid_q <= nxt_p2r_valid;

  always @(posedge clk_p)
    if (p1r_valid) begin
      p2r_dist_valid_q <= p1r_dist_valid;
      p2r_unpred_q     <= p1r_unpred;
      p2r_last_q       <= p1r_last;
      p2r_id_q         <= p1r_id;
    end

  // Register distributor data on distributor reads
  always @(posedge clk_p)
    if (p1r_dist_valid)
      p2r_dist_data_q <= p_dist_rdata_i;

  // Register interface data on VCPU or CPU interface reads
  assign p2r_intf_data_en = p1r_cpuif_valid | p1r_vcpuif_valid;

  always @(posedge clk_p)
    if (p2r_intf_data_en)
      p2r_intf_data_q <= p_intf_rdata_i;

  assign axi_read_en = p2r_valid_q & ~axi_rvalid_q;

  assign nxt_axi_rdata[31:0] = p2r_dist_valid_q ? p2r_dist_data_q[31:0] : p2r_intf_data_q[31:0];

  always @(posedge clk_p)
    if (axi_read_en) begin
      axi_rdata_q   <= nxt_axi_rdata;
      axi_runpred_q <= p2r_unpred_q;
      axi_rlast_q   <= p2r_last_q;
      axi_rid_q     <= p2r_id_q;
    end

  assign axi_rresp = {axi_runpred_q, 1'b0}; // 0x2=SLVERR, 0x0=OKAY

  assign nxt_axi_rvalid = (p2r_valid_q & ~axi_rvalid_q) | // Set when new rdata available and not driving rdata (always one empty cycle between beats)
                          (axi_rvalid_q & ~axi_rready_i); // Maintain until rdata accepted by AXI

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      axi_rvalid_q <= 1'b0;
    else
      axi_rvalid_q <= nxt_axi_rvalid;

  // Outputs to AXI
  assign axi_rid_o     = axi_rid_q;
  assign axi_rdata_o   = axi_rdata_q;
  assign axi_rresp_o   = axi_rresp;
  assign axi_rlast_o   = axi_rlast_q;
  assign axi_rvalid_o  = axi_rvalid_q;


  //----------------------------------------------------------------------------
  // Write Response
  //----------------------------------------------------------------------------

  assign nxt_p2w_valid = (p1w_valid & p1w_last) |       // Set on last beat of write burst
                         (p2w_valid_q & axi_bvalid_q);  // Maintain until can put in AXI register

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      p2w_valid_q <= 1'b0;
    else
      p2w_valid_q <= nxt_p2w_valid;

  // If any beat of a write burst generates an unpredictable response, then
  // the response for the entire burst will be an error. Therefore it is
  // necessary to hold any unpredictable response until the end of a burst
  // when the transaction response is generated.

  assign nxt_p2w_unpred = (p1w_valid & p1w_unpred) |      // Set if any beat of burst generates unpred
                          (p2w_unpred_q & ~axi_bresp_en); // Clear when response pipelined to AXI

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      p2w_unpred_q <= 1'b0;
    else
      p2w_unpred_q <= nxt_p2w_unpred;

  // Pipeline the ID on the last beat of the burst

  assign p2w_id_en = p1w_valid & p1w_last;

  always @(posedge clk_p)
    if (p2w_id_en) begin
      p2w_id_q <= p1w_id;
    end

  assign nxt_axi_bvalid = (p2w_valid_q & ~axi_bvalid_q) | // Set when new resp available and not driving resp (always one empty cycle between txs)
                          (axi_bvalid_q & ~axi_bready_i); // Maintain until resp accepted by AXI

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      axi_bvalid_q <= 1'b0;
    else
      axi_bvalid_q <= nxt_axi_bvalid;

  assign axi_bresp_en = p2w_valid_q & ~axi_bvalid_q;

  always @(posedge clk_p)
    if (axi_bresp_en) begin
      axi_bunpred_q <= p2w_unpred_q;
      axi_bid_q     <= p2w_id_q;
    end

  assign axi_bresp = {axi_bunpred_q, 1'b0}; // 0x2=SLVERR, 0x0=OKAY


  // Outputs to AXI
  assign axi_bid_o     = axi_bid_q;
  assign axi_bresp_o   = axi_bresp;
  assign axi_bvalid_o  = axi_bvalid_q;


  //----------------------------------------------------------------------------
  // OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // Reads and writes should never be issued to the internal programming
  // interface at the same time.
  assert_zero_one_hot #(`OVL_FATAL,2,`OVL_ASSERT,"A read and write were issued to the programming interface simultaneously")
  ovl_p1r_p1w_exclusive      (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr ({p1r_valid, p1w_valid}));

  // New write transactions should not be accepted from AXI when a read
  // transaction is stalled waiting for a write, to ensure the read can
  // eventually happen.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"A new write transaction was accepted from AXI when a read was stalled on a write")
  ovl_write_on_stalled_read  (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (p0r_valid & p0w_valid),
                              .consequent_expr  (~axi_awready));

  // Reads should not be issued to P1 when there is a write in P0.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"A read was issued to P1 when a write was in P0")
  ovl_read_stalled_on_write  (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (p1r_enable),
                              .consequent_expr  (~p0w_valid));

  // An enable for a P1 transaction must generate a matching P1 transaction
  // on the next cycle.
  reg p1w_enable_reg;
  reg p1r_enable_reg;
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      p1w_enable_reg <= 1'b0;
      p1r_enable_reg <= 1'b0;
    end else begin
      p1w_enable_reg <= p1w_enable;
      p1r_enable_reg <= p1r_enable;
    end

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"p1w_enable was asserted on one cycle and p1w_valid was not asserted on the next cycle")
  ovl_p1w_en_to_p1w_valid    (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (p1w_enable_reg),
                              .consequent_expr  (p1w_valid));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"p1r_enable was asserted on one cycle and p1r_valid was not asserted on the next cycle")
  ovl_p1r_en_to_p1r_valid    (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (p1r_enable_reg),
                              .consequent_expr  (p1r_valid));

  // There should always be room for the write response when the final beat
  // of a write transaction is in P1.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Write transaction is P1 with previous response still in P2")
  ovl_p1w_last_p2w_valid     (.clk              (clk),
                              .reset_n          (reset_n),
                              .antecedent_expr  (p1w_valid & p1w_last),
                              .consequent_expr  (~p2w_valid_q));


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: axi_bresp_en")
  u_ovl_x_axi_bresp_en (.clk       (clk_p),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (axi_bresp_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: axi_read_en")
  u_ovl_x_axi_read_en (.clk       (clk_p),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (axi_read_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: new_axi_wdata")
  u_ovl_x_new_axi_wdata (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (new_axi_wdata));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p1r_dist_valid")
  u_ovl_x_p1r_dist_valid (.clk       (clk_p),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (p1r_dist_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p1r_valid")
  u_ovl_x_p1r_valid (.clk       (clk_p),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (p1r_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p1w_enable")
  u_ovl_x_p1w_enable (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (p1w_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p2r_intf_data_en")
  u_ovl_x_p2r_intf_data_en (.clk       (clk_p),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (p2r_intf_data_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p2w_id_en")
  u_ovl_x_p2w_id_en (.clk       (clk_p),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (p2w_id_en));


`endif


endmodule

