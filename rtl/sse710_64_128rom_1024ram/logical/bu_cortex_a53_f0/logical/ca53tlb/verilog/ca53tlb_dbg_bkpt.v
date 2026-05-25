//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
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
// Abstract : Match logic and registers for a Breakpoint Register Pair (BRP)
//-----------------------------------------------------------------------------
//
// This module can be configured to match on Context ID
//

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_dbg_bkpt #(parameter CID_MATCH = 1'b0, parameter LINK_BRP_NUM = 3'b000) (
  input  wire         clk,
  input  wire         clk_cpregs,
  input  wire         dbg_resetn_i,
  input  wire         dpu_dbg_tlb_bkpt_wpt_en_i,
  input  wire         dpu_dbg_tlb_hw_bkpt_wpt_en_i,
  input  wire         tlb_dbg_legacy_mode_i,
  input  wire         apb_wr_bcr_i,
  input  wire         apb_wr_bvr_i,
  input  wire         apb_wr_bxvr_i,
  input  wire         cp14_wr_bcr_i,
  input  wire         cp14_wr_bvr_i,
  input  wire         cp14_wr_bxvr_i,
  input  wire [31:0]  dpu_dbg_wdata_i,
  input  wire [48:0]  dcu_cp_reg_data_i,
  input  wire         dcu_cp_reg_size_i,
  input  wire [48:3]  ifu_va_if2_i,
  input  wire [4:0]   dpu_mode_iss_i,
  input  wire [1:0]   dpu_exception_level_i,
  input  wire [3:1]   dpu_aarch64_at_el_i,
  input  wire         dpu_current_a64_i,
  input  wire         dpu_ns_state_i,
  input  wire [7:0]   tlb_vmid_i,
  input  wire [31:0]  context_id_i,
  input  wire [1:0]   cid_vmid_linked_hit_i,

  output wire [31:0]  bcr_o,
  output wire [31:0]  bvr_o,
  output wire [31:0]  bxvr_o,
  output wire         cid_vmid_linked_hit_o,
  output wire [3:0]   brp_hit_o
);

  //----------------------------------------------------------------------------
  // Flop declarations
  //----------------------------------------------------------------------------

  reg               bcr0;                     // Breakpoint enable (bit 0)
  reg  [1:0]        bcr_priv_ctl;             // Privileged mode control
  reg  [1:0]        raw_bcr_byte_sel;         // Byte address select
  reg  [2:0]        bcr_sec_ctl;              // Security state control
  reg  [1:0]        bcr_linked_brp;           // BRP this BRP is linked to
  reg               bcr_type_linked;          // BRP is linked to another
  reg [31:(CID_MATCH ? 0 : 2)] bvr;           // Breakpoint value register
  reg [16:0]        bxvr;                     // Breakpoint extended value register
  reg               cid_matched;              // Context ID matches
  reg               bcr_type_mismatch;

  //----------------------------------------------------------------------------
  // Wire declarations
  //----------------------------------------------------------------------------

  reg               brp_mode_match;           // Mode hit check for a BRP
  reg               cid_vmid_hit;             // Context ID and/or VMID match
  wire [3:0]        brp_iva_hit;              // Halfword of the access had a BRP hit
  wire              brp_sec_match;            // Security state matches
  wire              brp_link_check;           // Linked hit check for a BRP
  wire [3:0]        brp_hword_mask_hit;       // Halfword had a BRP hit (based on mask)
  wire              brp_iva_match;            // IVA hit check for a BRP
  wire              bcr_enabled;              // Breakpoint enabled
  wire              next_cid_matched;         // Context ID matches
  wire              cid_hit;                  // Context ID matches and enabled
  wire              vmid_hit;                 // VMID matches and enabled
  wire              cid_vmid_unlinked_hit;    // Unlinked Context ID and VMID match
  wire [3:0]        bcr_byte_sel;             // Expanded byte address select
  wire [1:0]        next_bcr_linked_brp;      // Compressed linked BRP number
  wire [31:0]       bvr_write_data;           // Source data for BVR write
  wire [16:0]       bxvr_write_data;          // Source data for BXVR write
  wire [31:0]       bcr_write_data;           // Source data for BCR write
  wire              bvr_en;                   // Register enable for BVR
  wire              bxvr_en;                  // Register enable for BXVR
  wire              bcr_en;                   // Register enable for BCR
  wire              brp_iva_match_low;
  wire              brp_iva_match_high;
  wire              dpu_exception_el0;
  wire              dpu_exception_el1;
  wire              dpu_exception_el2;
  wire              dpu_exception_el3;
  wire              bcr_type_cid;             // BVR holds a context ID
  wire              bcr_type_vmid;            // BXVR holds a VMID
  wire              bcr_type_mismatch_qualified;



  assign dpu_exception_el0 = (dpu_exception_level_i == 2'b00);
  assign dpu_exception_el1 = (dpu_exception_level_i == 2'b01);
  assign dpu_exception_el2 = (dpu_exception_level_i == 2'b10);
  assign dpu_exception_el3 = (dpu_exception_level_i == 2'b11);

  //----------------------------------------------------------------------------
  // BRP register logic
  //----------------------------------------------------------------------------

  // BVR register write (register does not need to be reset)
  // In A64, {BXVR,BVR} are accesses as single 64-bit register. TLB can not tell
  // if user is writing address/context ID/VMID (without Context ID)/VMID with
  // Context ID, and hence always writes BVR register with BVR address is accessed
  assign bvr_write_data = apb_wr_bvr_i ? dpu_dbg_wdata_i : dcu_cp_reg_data_i[31:0];

  assign bvr_en = apb_wr_bvr_i | cp14_wr_bvr_i;

  always @(posedge clk_cpregs)
  if (bvr_en) begin
    bvr <= bvr_write_data[31:(CID_MATCH ? 0 : 2)];
  end

  assign bxvr_en = apb_wr_bxvr_i | cp14_wr_bxvr_i;

  // BXVR usage
  //   DPU accesses 64-bit debug regs using two separate writes at two
  //   different addresses i.e. DBGBVR for lower half, DBGBXVR for upper half
  //  
  //   DCU accesses
  //   For AArch64, DCU accesses 64-bit debug regs using BVR address,
  //   dcu_cp_reg_size_i is set and data is written using dcu_cp_reg_data_i[48:32]
  //       - For Address instruction BP: bxvr[16:0] is instruction addr
  //       - For context ID BP:          bxvr[16:0] is written with unused value
  //       - For VMID BP:                bxvr[16:8] is written with unused value, bxvr[7:0] is VMID
  //       - For VMID+ContexId BP:       bxvr[16:8] is written with unused value, bxvr[7:0] is VMID
  //   For AArch32, DCU accesses 32-bit debug reg using BXVR address,
  //   dcu_cp_reg_size_i is clear and data is written using dcu_cp_reg_data_i[16:0]
  //       - For Address instruction BP: unused
  //       - For context ID BP:          unused
  //       - For VMID BP:                bxvr[16:8] is written with unused value, bxvr[7:0] is VMID
  //       - For VMID+ContexId, BP:      bxvr[16:8] is written with unused value, bxvr[7:0] is VMID

  generate if (CID_MATCH) begin : g_cid0

    assign bvr_o = bvr;

    // When writing through APB with DPU-A64, all 17-bits of BXVR are updated even if it was context ID
    // update, reason is that TLB can not tell if user is trying to write VMID or VA[48:32]
    assign bxvr_write_data = apb_wr_bxvr_i ?
                              (dpu_dbg_wdata_i[16:0]) :
                              (dcu_cp_reg_size_i ? dcu_cp_reg_data_i[48:32] : dcu_cp_reg_data_i[16:0]);
  end else begin : g_ncid0

    assign bvr_o = {bvr[31:2], 2'b00};

    assign bxvr_write_data = apb_wr_bxvr_i ?
                              (dpu_dbg_wdata_i[16:0]) :
                              (dcu_cp_reg_size_i ? dcu_cp_reg_data_i[48:32] : bxvr[16:0]);
  end endgenerate

    always @(posedge clk_cpregs)
    if (bxvr_en) begin
      bxvr <= bxvr_write_data;
    end

  assign bxvr_o = {{15{bxvr[16]}}, bxvr};

  // BCR register write (only register enable needs resetting, but must be
  // reset for all BCRs)
  assign bcr_write_data = apb_wr_bcr_i ? dpu_dbg_wdata_i : dcu_cp_reg_data_i[31:0];

  assign bcr_en = apb_wr_bcr_i | cp14_wr_bcr_i;

  always @(posedge clk_cpregs or negedge dbg_resetn_i)
  if (~dbg_resetn_i) begin
    bcr0 <= 1'b0;
  end else if (bcr_en) begin
    bcr0 <= bcr_write_data[0];
  end

  assign next_bcr_linked_brp = (bcr_write_data[19:17] == LINK_BRP_NUM[2:0]) ? {1'b1, bcr_write_data[16]} :
                                                                              {1'b0, |bcr_write_data[19:16]};

  always @(posedge clk_cpregs)
  if (bcr_en) begin
    bcr_priv_ctl      <= bcr_write_data[2:1];
    raw_bcr_byte_sel  <= {bcr_write_data[7],bcr_write_data[5]};
    bcr_sec_ctl       <= bcr_write_data[15:13];
    bcr_linked_brp    <= next_bcr_linked_brp;
    bcr_type_linked   <= bcr_write_data[20];
    bcr_type_mismatch <= bcr_write_data[22];
  end

  // For the purpose of read back, value written is returned as such
  // For internal use, mismatch is qualified by following conditions
  //   Software Hardware
  //   Debug    Debug
  //   Enable   Enable
  //     0        0       
  //     0        1  A Mismatch is treated as match
  //     1        0  In Legacy mode: Mismatch is a mismatch, match is a match 
  //                 In Non Legacy mode: Mismatch treated as match
  //     1        1  A Mismatch is treated as match
  assign bcr_type_mismatch_qualified = ~dpu_dbg_tlb_hw_bkpt_wpt_en_i & tlb_dbg_legacy_mode_i & 
                                        bcr_type_mismatch;


  // BCR[23], BCR[21] are writeable only for context aware BP
  generate if (CID_MATCH) begin : g_cid2
    reg bcr_type_cid_early;
    reg bcr_type_vmid_early;

    always @(posedge clk_cpregs)
    if (bcr_en) begin
      bcr_type_cid_early  <= bcr_write_data[21];
      bcr_type_vmid_early <= bcr_write_data[23];
    end
    assign bcr_type_cid  = bcr_type_cid_early;
    assign bcr_type_vmid = bcr_type_vmid_early;

  end else begin : g_ncid2
    assign bcr_type_cid  = 1'b0;
    assign bcr_type_vmid = 1'b0;
  end endgenerate


  // Disable the breakpoint if incorrectly programmed with 
  //  - undefined security state and mode combinations
  //  - Reserved break point type combinations
  assign bcr_enabled = bcr0 & ~((~bcr_sec_ctl[2] & bcr_sec_ctl[0] & ~bcr_priv_ctl[0]) |
                                (bcr_sec_ctl[2] & bcr_sec_ctl[0] & (bcr_priv_ctl[1:0] == 2'b10)) |
                                ((&bcr_sec_ctl[2:1]) & (~bcr_sec_ctl[0] | (|bcr_priv_ctl))))
                            & ~((~bcr_type_vmid & bcr_type_mismatch & bcr_type_cid) |  // BCR[23:21] == 4'b011x
                                (bcr_type_vmid & bcr_type_mismatch)); // BCR[23:21] == 4'b11xx

  assign bcr_byte_sel = { {2{raw_bcr_byte_sel[1]}},
                          {2{raw_bcr_byte_sel[0]}} };

  assign bcr_o = {3'b000,
                  5'b00000,
                  bcr_type_vmid,
                  bcr_type_mismatch,
                  bcr_type_cid,
                  bcr_type_linked,
                  bcr_linked_brp[1] ? {LINK_BRP_NUM[2:0], bcr_linked_brp[0]} : 4'h0,
                  bcr_sec_ctl[2:0],
                  4'b0000,
                  bcr_byte_sel[3:0],
                  2'b00,
                  bcr_priv_ctl,
                  bcr0};

  //----------------------------------------------------------------------------
  // BRP hit checks
  //----------------------------------------------------------------------------

  generate if (CID_MATCH) begin : g_cid1

    // Context ID check for high numbered BRPs only
    assign next_cid_matched = (bvr == context_id_i);

    // Register the CID match to help timing
    always @(posedge clk)
      cid_matched <= next_cid_matched;

    assign cid_hit = cid_matched & ~bcr_type_mismatch_qualified &
                     ~dpu_exception_el2 & ~(dpu_exception_el3 & dpu_aarch64_at_el_i[3]);

    // Not defined for EL2 and EL3-A64
    assign vmid_hit = (bxvr[7:0] == tlb_vmid_i) & ~bcr_type_mismatch_qualified & dpu_ns_state_i &
                      ~dpu_exception_el2 & ~(dpu_exception_el3 & dpu_aarch64_at_el_i[3]);

    always @*
    case ({bcr_type_cid, bcr_type_vmid})
      2'b00:   cid_vmid_hit = 1'b0;
      2'b01:   cid_vmid_hit = vmid_hit;
      2'b10:   cid_vmid_hit = cid_hit;
      2'b11:   cid_vmid_hit = cid_hit & vmid_hit;
      default: cid_vmid_hit = 1'bx;
    endcase

    assign cid_vmid_unlinked_hit = (dpu_dbg_tlb_bkpt_wpt_en_i &
                                    bcr_enabled &
                                    cid_vmid_hit &
                                    ~bcr_type_linked &
                                    brp_mode_match &
                                    brp_sec_match);

    assign cid_vmid_linked_hit_o = bcr0 & cid_vmid_hit & bcr_type_linked;

  end else begin : g_ncid1

    assign cid_hit = 1'b0;
    assign vmid_hit = 1'b0;

    always @*
      cid_vmid_hit = cid_hit;

    assign cid_vmid_unlinked_hit = 1'b0;
    assign cid_vmid_linked_hit_o = 1'b0;

  end endgenerate


  // Check that the doubleword address matches
  assign brp_iva_match_low  = (bvr[31:3] == ifu_va_if2_i[31:3]);
  assign brp_iva_match_high = (bxvr[16:0] == ifu_va_if2_i[48:32]);

  assign brp_iva_match = dpu_current_a64_i ? (brp_iva_match_low & brp_iva_match_high) :
                                             brp_iva_match_low;

  // Check that the current mode is correct for the BRP to be hit
  always @*
  case (bcr_priv_ctl[1:0])
    2'b00:   brp_mode_match =  (bcr_sec_ctl == 3'b111) ? dpu_exception_el2 :                             // EL2
                               (bcr_sec_ctl == 3'b101) ? (dpu_exception_el3 & dpu_aarch64_at_el_i[3]) :  // EL3-A64
                                                         (dpu_exception_el0 & ~dpu_aarch64_at_el_i[1]) | // EL0-A32 
                                                         ((dpu_exception_el1 | dpu_exception_el3) &      // EL1/E3 in 
                                                          ((dpu_mode_iss_i == `CA53_FULL_MODE_SVC) |     //  A32 SVC mode
                                                           (dpu_mode_iss_i == `CA53_FULL_MODE_SYS)) );   //  A32 SYS mode

    2'b01:   brp_mode_match = dpu_exception_el1 |                                               // EL1
                              (bcr_sec_ctl[0] ? (dpu_exception_el2 | dpu_exception_el3) :       // HMC=1 ? EL2/EL3
                                                (dpu_exception_el3 & ~dpu_aarch64_at_el_i[3])); // HMC=0 ? EL3-A32

    2'b10:   brp_mode_match = dpu_exception_el0;

    2'b11:   brp_mode_match = dpu_exception_el0 | dpu_exception_el1 |                           // EL0/EL1
                              (bcr_sec_ctl[0] ? (dpu_exception_el2 | dpu_exception_el3) :       // HMC=1 ? EL2/EL3
                                                (dpu_exception_el3 & ~dpu_aarch64_at_el_i[3])); // HMC=0 ? EL3-A32
    default: brp_mode_match = 1'bx;
  endcase

  // Check that the security state matches
  assign brp_sec_match = dpu_ns_state_i ? (~bcr_sec_ctl[2] | &bcr_sec_ctl[1:0]) : ~bcr_sec_ctl[1];

  // Link check (this is true if the BRP is not linked or is linked
  // and the context ID matches)
  assign brp_link_check = (bcr_type_linked ? (bcr_linked_brp[1] &                               // linked BP5 or BP4
                                              (bcr_linked_brp[0] ? cid_vmid_linked_hit_i[1] :   // If linked BP5, check BP5 context
                                                                   cid_vmid_linked_hit_i[0])) : // else check BP4 context
                                             1'b1);

  // Create the hit mask for each halfword in the doubleword
  assign brp_hword_mask_hit = { {2{bcr_type_mismatch_qualified}} ^ ({2{brp_iva_match &  bvr[2]}} & {|bcr_byte_sel[3:2], |bcr_byte_sel[1:0]}),
                                {2{bcr_type_mismatch_qualified}} ^ ({2{brp_iva_match & ~bvr[2]}} & {|bcr_byte_sel[3:2], |bcr_byte_sel[1:0]})};

  // Combine the various IVA match signals
  assign brp_iva_hit = {4{dpu_dbg_tlb_bkpt_wpt_en_i &
                          bcr_enabled &
                          brp_link_check &
                          ~bcr_type_cid &
                          ~bcr_type_vmid &
                          brp_mode_match &
                          brp_sec_match}} & brp_hword_mask_hit;

  // Produce final hit output
  assign brp_hit_o = {4{cid_vmid_unlinked_hit}} | brp_iva_hit;


  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: bcr_en")
  u_ovl_x_bcr_en (.clk       (clk),
                  .reset_n   (dbg_resetn_i),
                  .qualifier (1'b1),
                  .test_expr (bcr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: bvr_en")
  u_ovl_x_bvr_en (.clk       (clk),
                  .reset_n   (dbg_resetn_i),
                  .qualifier (1'b1),
                  .test_expr (bvr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: bxvr_en")
  u_ovl_x_bxvr_en (.clk       (clk),
                   .reset_n   (dbg_resetn_i),
                   .qualifier (1'b1),
                   .test_expr (bxvr_en));

`endif

endmodule // ca53tlb_dbg_bkpt

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53tlb_defs.v"
`undef CA53_UNDEFINE
/*END*/
