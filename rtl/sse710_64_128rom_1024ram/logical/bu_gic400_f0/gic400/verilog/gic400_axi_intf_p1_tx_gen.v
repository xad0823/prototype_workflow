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
//      Checked In          : $Date: 2011-08-03 15:09:44 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180427 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//   Takes P0 transactions spun out by the addr_unpack block and generates
//   corresponding P1 transactions to issue to the internal programming
//   interface. The AXI format addresses from P0 are re-encoded into the
//   internal programming interface opcode format.
//------------------------------------------------------------------------------

module gic400_axi_intf_p1_tx_gen #(parameter RD = 0,
                                   parameter NUM_ID_BITS = 4)
(
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire            [14:2] p0_addr_i,
  input  wire             [2:0] p0_cpu_i,
  input  wire                   p0_nsecure_i,
  input  wire             [3:0] p0_strb_i,
  input  wire             [1:0] p0_size_i,
  input  wire                   p0_last_i,
  input  wire [NUM_ID_BITS-1:0] p0_id_i,
  input  wire             [9:2] p0_wdata_9to2_i,

  input  wire                   p1_enable_i,

  output wire                   p1_dist_req_o,
  output wire                   p1_cpuif_req_o,
  output wire                   p1_vcpuif_req_o,
  output wire             [3:0] p1_dist_op_o,
  output wire             [3:0] p1_intf_op_o,
  output wire                   p1_nsecure_o,
  output wire             [3:0] p1_dist_block_o,
  output wire             [2:0] p1_cpu_o,
  output wire                   p1_unpred_o,
  output wire                   p1_vcpuif_front_o,
  output wire             [2:0] p1_index_o,
  output wire [NUM_ID_BITS-1:0] p1_id_o,
  output wire                   p1_last_o
);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"


  //-----------------------------------------------------------------------------
  // Signal Declarations
  //-----------------------------------------------------------------------------

  wire            [3:0] p0_dist_op;
  wire            [3:0] p0_dist_block;
  wire            [3:0] p0_c_intf_op;
  wire            [3:0] p0_v_intf_op;
  wire            [3:0] p0_h_intf_op;
  wire                  p0_word_access;
  wire                  p0_cpuif_req;
  wire                  p0_vcpuif_req;
  wire            [3:0] p0_intf_op;
  wire            [2:0] p0_cpu;
  wire                  nxt_p_dist_req;
  wire                  nxt_p_cpuif_req;
  wire                  nxt_p_vcpuif_req;
  reg                   p1_dist_req_q;
  reg                   p1_cpuif_req_q;
  reg                   p1_vcpuif_req_q;
  reg             [3:0] p1_intf_op_q;
  reg             [3:0] p1_dist_op_q;
  reg             [2:0] p1_cpu_q;
  reg             [3:0] p1_dist_block_q;
  reg                   p1_unpred_q;
  reg             [2:0] p1_index_q;
  reg [NUM_ID_BITS-1:0] p1_id_q;
  reg                   p1_nsecure_q;
  reg                   p1_last_q;
  reg                   p1_vcpuif_front_q;
  wire                  p0_unpred;
  wire                  p0_dist_req;
  wire                  p0_spurious_id;


  //-----------------------------------------------------------------------------
  // Distributor Decode
  //-----------------------------------------------------------------------------

  generate if (RD) begin : g_p0_dist_rd_op

    assign p0_dist_op[3:0] = {4{p0_addr_i[12]}} &  // Distributor registers all in upper half of distributor address space
        (({4{(p0_addr_i[11:6] == AXI_D_IGROUPR) & ~p0_nsecure_i}}       & D_IGROUPR)    |  // Only valid on secure accesses
         ({4{ p0_addr_i[11:6] == AXI_D_ISENABLER}}                      & D_ISENABLER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ICENABLER}}                      & D_ICENABLER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ISPENDR}}                        & D_ISPENDR)    |
         ({4{ p0_addr_i[11:6] == AXI_D_ICPENDR}}                        & D_ICPENDR)    |
         ({4{ p0_addr_i[11:6] == AXI_D_ISACTIVER}}                      & D_ISACTIVER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ICACTIVER}}                      & D_ICACTIVER)  |
         ({4{ p0_addr_i[11:9] == AXI_D_IPRIORITYR}}                     & D_IPRIORITYR) |
         ({4{ p0_addr_i[11:9] == AXI_D_ITARGETSR}}                      & D_ITARGETSR)  |
         ({4{ p0_addr_i[11:7] == AXI_D_ICFGR}}                          & D_ICFGR)      |
         ({4{ p0_addr_i[11:6] == AXI_D_ISTATUSR}}                       & D_ISTATUSR)   |
         ({4{ p0_addr_i[11:4] == AXI_D_CPENDSGIR}}                      & D_CPENDSGIR)  |
         ({4{ p0_addr_i[11:4] == AXI_D_SPENDSGIR}}                      & D_SPENDSGIR)  |
         ({4{(p0_addr_i[11:4] == AXI_D_CTLR_ID) |                                         // CTLR, TYPER, IIDR
             ((p0_addr_i[11:6] == AXI_D_PRIMECELL) & |p0_addr_i[5:4])}} & D_COMMON));     // ICPIDR, ICCIDR

  end else begin : g_p0_dist_wr_op

    assign p0_dist_op[3:0] = {4{p0_addr_i[12]}} &  // Distributor registers all in upper half of distributor address space
        (({4{(p0_addr_i[11:6] == AXI_D_IGROUPR) & ~p0_nsecure_i}}       & D_IGROUPR)    |  // Only valid on secure accesses
         ({4{ p0_addr_i[11:6] == AXI_D_ISENABLER}}                      & D_ISENABLER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ICENABLER}}                      & D_ICENABLER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ISPENDR}}                        & D_ISPENDR)    |
         ({4{ p0_addr_i[11:6] == AXI_D_ICPENDR}}                        & D_ICPENDR)    |
         ({4{ p0_addr_i[11:6] == AXI_D_ISACTIVER}}                      & D_ISACTIVER)  |
         ({4{ p0_addr_i[11:6] == AXI_D_ICACTIVER}}                      & D_ICACTIVER)  |
         ({4{ p0_addr_i[11:9] == AXI_D_IPRIORITYR}}                     & D_IPRIORITYR) |
         ({4{ p0_addr_i[11:9] == AXI_D_ITARGETSR}}                      & D_ITARGETSR)  |
         ({4{ p0_addr_i[11:7] == AXI_D_ICFGR}}                          & D_ICFGR)      |
         ({4{ p0_addr_i[11:6] == AXI_D_ISTATUSR}}                       & D_ISTATUSR)   |
         ({4{ p0_addr_i[11:4] == AXI_D_CPENDSGIR}}                      & D_CPENDSGIR)  |
         ({4{ p0_addr_i[11:4] == AXI_D_SPENDSGIR}}                      & D_SPENDSGIR)  |
         ({4{(p0_addr_i[11:2] == AXI_D_SGIR) & (&p0_strb_i[3:0])}}      & D_SGIR)       | // WO and only valid on full word writes
         ({4{(p0_addr_i[11:2] == AXI_D_CTLR) & p0_strb_i[0]}}           & D_COMMON));     // CTLR - write only has effect when strb[0] set

  end endgenerate


  // For the distributor, the block specifies which 32-IRQ block the register
  // maps to.
  // - For the common registers, the type of register can be determined from
  //   the bottom 4-bits of the address:
  //     CTLR      (0x000)       - 4'b0000
  //     TYPER     (0x004)       - 4'b0001
  //     IIDR      (0x008)       - 4'b0010
  //     ICPIDR0-3 (0xFE0-0xFEC) - 4'b10xx
  //     ICPIDR4-7 (0xFD0-0xFDC) - 4'b01xx
  //     ICCIDR0-3 (0xFF0-0xFFC) - 4'b11xx

  // Note that the block is masked to zero on SGI Pend/Clear reqs, to ensure
  // the bottom block (where those registers reside) is selected, to simplify
  // the logic which combines the read data from each IRQ block in the
  // distributor.
  assign p0_dist_block[3:0] = ({4{(p0_addr_i[11:10] == 2'b00) |
                                  (p0_addr_i[11:8]  == 4'b1101) |
                                  (p0_addr_i[11:7]  == 5'b1111_1)}} & p0_addr_i[5:2]) | // IGROUPR, IxENABLER, IxPENDR, IxACTIVER, ISTATUSR, Common
                              ({4{p0_addr_i[11] ^ p0_addr_i[10]}}   & p0_addr_i[8:5]) | // IPRIORITYR, ITARGETSR
                              ({4{p0_addr_i[11:8] == 4'b1100}}      & p0_addr_i[6:3]);  // ICFGR


  assign p0_dist_req = (p0_addr_i[14:13] == 2'b00);

  //-----------------------------------------------------------------------------
  // CPU Interface
  //-----------------------------------------------------------------------------

  // Writes to the EOI/Deactivate registers with a suprious interrupt ID have
  // no effect. This is implemented by not sending such accesses to the
  // programming interface.
  // The ID is specified on wdata[9:0], and IDs > 1019 are spurious
  assign p0_spurious_id = &p0_wdata_9to2_i;

  generate if (RD) begin : g_p0_c_intf_rd_op

    assign p0_c_intf_op[3:0] = ({4{ p0_addr_i[14:2] == AXI_C_CTLR}}                      & C_CTLR)   |
                               ({4{ p0_addr_i[14:2] == AXI_C_PMR}}                       & C_PMR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_BPR}}                       & C_BPR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_IAR}}                       & C_IAR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_RPR}}                       & C_RPR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_HPPIR}}                     & C_HPPIR)  |
                               ({4{ p0_addr_i[14:2] == AXI_C_ABPR}}                      & C_ABPR)   |
                               ({4{ p0_addr_i[14:2] == AXI_C_AIAR}}                      & C_AIAR)   |
                               ({4{ p0_addr_i[14:2] == AXI_C_AHPPIR}}                    & C_AHPPIR) |
                               ({4{ p0_addr_i[14:2] == AXI_C_APR}}                       & C_APR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_NSAPR}}                     & C_NSAPR)  |
                               ({4{ p0_addr_i[14:2] == AXI_C_IIDR}}                      & C_V_IIDR); // IIDR is common to CPU/VCPU interface

  end else begin : g_p0_c_intf_wr_op

    assign p0_c_intf_op[3:0] = ({4{ p0_addr_i[14:2] == AXI_C_CTLR}}                      & C_CTLR)   |
                               ({4{ p0_addr_i[14:2] == AXI_C_PMR}}                       & C_PMR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_BPR}}                       & C_BPR)    |
                               ({4{(p0_addr_i[14:2] == AXI_C_EOIR)  & ~p0_spurious_id}}  & C_EOIR)   |
                               ({4{ p0_addr_i[14:2] == AXI_C_ABPR}}                      & C_ABPR)   |
                               ({4{(p0_addr_i[14:2] == AXI_C_AEOIR) & ~p0_spurious_id}}  & C_AEOIR)  |
                               ({4{ p0_addr_i[14:2] == AXI_C_APR}}                       & C_APR)    |
                               ({4{ p0_addr_i[14:2] == AXI_C_NSAPR}}                     & C_NSAPR)  |
                               ({4{(p0_addr_i[14:2] == AXI_C_DIR)   & ~p0_spurious_id}}  & C_DIR);
  end endgenerate

  assign p0_cpuif_req = (p0_addr_i[14:13] == 2'b01);

  //-----------------------------------------------------------------------------
  // Virtual CPU Interface
  //-----------------------------------------------------------------------------

  generate if (RD) begin : g_p0_hv_intf_rd_op

    assign p0_h_intf_op[3:0] = {4{(p0_addr_i[14:13] == 2'b10) & (p0_addr_i[12] | ~|p0_addr_i[11:9])}} &
                               (({4{ p0_addr_i[8:2]  == AXI_H_HCR}}                       & H_HCR)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_VTR}}                       & H_VTR)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_VMCR}}                      & H_VMCR)   |
                                ({4{ p0_addr_i[8:2]  == AXI_H_MISR}}                      & H_MISR)   |
                                ({4{ p0_addr_i[8:2]  == AXI_H_EISR}}                      & H_EISR)   |
                                ({4{ p0_addr_i[8:2]  == AXI_H_ELSR}}                      & H_ELSR)   |
                                ({4{ p0_addr_i[8:2]  == AXI_H_APR}}                       & H_APR)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR0}}                       & H_LR0)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR1}}                       & H_LR1)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR2}}                       & H_LR2)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR3}}                       & H_LR3));

    assign p0_v_intf_op[3:0] =  ({4{ p0_addr_i[14:2] == AXI_V_CTLR}}                      & V_CTLR)   |
                                ({4{ p0_addr_i[14:2] == AXI_V_PMR}}                       & V_PMR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_BPR}}                       & V_BPR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_IAR}}                       & V_IAR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_RPR}}                       & V_RPR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_HPPIR}}                     & V_HPPIR)  |
                                ({4{ p0_addr_i[14:2] == AXI_V_ABPR}}                      & V_ABPR)   |
                                ({4{ p0_addr_i[14:2] == AXI_V_AIAR}}                      & V_AIAR)   |
                                ({4{ p0_addr_i[14:2] == AXI_V_AHPPIR}}                    & V_AHPPIR) |
                                ({4{ p0_addr_i[14:2] == AXI_V_APR}}                       & V_APR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_IIDR}}                      & C_V_IIDR);  // IIDR is common to CPU/VCPU interface

  end else begin : g_p0_hv_intf_wr_op

    assign p0_h_intf_op[3:0] = {4{(p0_addr_i[14:13] == 2'b10) & (p0_addr_i[12] | ~|p0_addr_i[11:9])}} &
                               (({4{ p0_addr_i[8:2]  == AXI_H_HCR}}                       & H_HCR)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_VMCR}}                      & H_VMCR)   |
                                ({4{ p0_addr_i[8:2]  == AXI_H_APR}}                       & H_APR)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR0}}                       & H_LR0)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR1}}                       & H_LR1)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR2}}                       & H_LR2)    |
                                ({4{ p0_addr_i[8:2]  == AXI_H_LR3}}                       & H_LR3));

    assign p0_v_intf_op[3:0] =  ({4{ p0_addr_i[14:2] == AXI_V_CTLR}}                      & V_CTLR)   |
                                ({4{ p0_addr_i[14:2] == AXI_V_PMR}}                       & V_PMR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_BPR}}                       & V_BPR)    |
                                ({4{ p0_addr_i[14:2] == AXI_V_ABPR}}                      & V_ABPR)   |
                                ({4{ p0_addr_i[14:2] == AXI_V_APR}}                       & V_APR)    |
                                ({4{(p0_addr_i[14:2] == AXI_V_EOIR)  & ~p0_spurious_id}}  & V_EOIR)   |
                                ({4{(p0_addr_i[14:2] == AXI_V_AEOIR) & ~p0_spurious_id}}  & V_AEOIR)  |
                                ({4{(p0_addr_i[14:2] == AXI_V_DIR)   & ~p0_spurious_id}}  & V_DIR);

  end endgenerate

  assign p0_vcpuif_req = p0_addr_i[14];

  //-----------------------------------------------------------------------------
  // Programming Interface
  //-----------------------------------------------------------------------------

  assign nxt_p_dist_req   = p1_enable_i & p0_dist_req;
  assign nxt_p_cpuif_req  = p1_enable_i & p0_cpuif_req;
  assign nxt_p_vcpuif_req = p1_enable_i & p0_vcpuif_req;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      p1_dist_req_q   <= 1'b0;
      p1_cpuif_req_q  <= 1'b0;
      p1_vcpuif_req_q <= 1'b0;
    end else begin
      p1_dist_req_q   <= nxt_p_dist_req;
      p1_cpuif_req_q  <= nxt_p_cpuif_req;
      p1_vcpuif_req_q <= nxt_p_vcpuif_req;
    end

  generate if (RD) begin : g_word_access_rd
    assign p0_word_access = (p0_size_i == AXI_SIZE_32);
  end else begin : g_word_access_wr
    assign p0_word_access = (p0_strb_i == 4'hf);
  end endgenerate

  assign p0_intf_op[3:0] = {4{p0_word_access}} & // Mask to RESERVED when not a word access
                           (p0_c_intf_op[3:0] |
                            p0_v_intf_op[3:0] |
                            p0_h_intf_op[3:0]); 

  assign p0_cpu[2:0]     = (p0_addr_i[14:12] == 3'b101) ? p0_addr_i[11:9] : p0_cpu_i;  // Use alias for VCPU back when [10] set

  generate if (RD) begin : g_runpred
    // Distributor reads are never unpredictable. CPU/VCPU reads are
    // unpredictable if they are not word sized.
    assign p0_unpred = (p0_addr_i[14:13] != 2'b00) & (p0_size_i[1:0] != AXI_SIZE_32);
  end else begin : g_wunpred
    // All CPU/VCPU writes must be a full word, as must distributor SGIR
    // writes.
    assign p0_unpred = (|p0_strb_i[3:0] & ~&p0_strb_i[3:0]) & // Some, but not all strobes set
                       ((p0_addr_i[14:13] != 2'b00) |
                        (p0_addr_i[12] & (p0_addr_i[11:2] == AXI_D_SGIR)));
  end endgenerate

  always @(posedge clk)
    if (p1_enable_i) begin
      p1_dist_op_q       <= p0_dist_op[3:0];
      p1_intf_op_q       <= p0_intf_op[3:0];
      p1_cpu_q           <= p0_cpu[2:0];
      p1_dist_block_q    <= p0_dist_block[3:0];
      p1_unpred_q        <= p0_unpred;
      p1_index_q         <= p0_addr_i[4:2];
      p1_id_q            <= p0_id_i[NUM_ID_BITS-1:0];
      p1_nsecure_q       <= p0_nsecure_i;
      p1_last_q          <= p0_last_i;
      p1_vcpuif_front_q  <= p0_addr_i[13];
    end

  assign p1_dist_req_o   = p1_dist_req_q;
  assign p1_cpuif_req_o  = p1_cpuif_req_q;
  assign p1_vcpuif_req_o = p1_vcpuif_req_q;

  assign p1_dist_op_o       = p1_dist_op_q[3:0];
  assign p1_intf_op_o       = p1_intf_op_q[3:0];
  assign p1_cpu_o           = p1_cpu_q[2:0];
  assign p1_dist_block_o    = p1_dist_block_q[3:0];
  assign p1_unpred_o        = p1_unpred_q;
  assign p1_index_o         = p1_index_q[2:0];
  assign p1_id_o            = p1_id_q[NUM_ID_BITS-1:0];
  assign p1_nsecure_o       = p1_nsecure_q;
  assign p1_last_o          = p1_last_q;
  assign p1_vcpuif_front_o  = p1_vcpuif_front_q;


  //-----------------------------------------------------------------------------
  // OVLs
  //-----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: p1_enable_i")
  u_ovl_x_p1_enable_i (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (p1_enable_i));



`endif

endmodule

