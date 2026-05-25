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
// Abstract : Match logic and registers for a Watchpoint Register Pair (WRP)
//-----------------------------------------------------------------------------

`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_dbg_wpt #(parameter LINK_BRP_NUM = 3'b000) (
  input  wire         clk,
  input  wire         clk_cpregs,
  input  wire         dbg_resetn_i,
  input  wire         dpu_dbg_tlb_bkpt_wpt_en_i,
  input  wire         apb_wr_wcr_i,
  input  wire         apb_wr_wvr_i,
  input  wire         apb_wr_wvr_high_i,
  input  wire         cp14_wr_wcr_i,
  input  wire         cp14_wr_wvr_i,
  input  wire         cp14_wr_wvr_high_i,
  input  wire [31:0]  dpu_dbg_wdata_i,
  input  wire         dpu_ns_state_i,
  input  wire [1:0]   dpu_exception_level_i,
  input  wire [3:1]   dpu_aarch64_at_el_i,
  input  wire         dpu_current_a64_i,
  input  wire [48:0]  dcu_cp_reg_data_i,
  input  wire         dcu_cp_reg_size_i,
  input  wire [48:3]  dpu_va_dc1_i,
  input  wire         dcu_priv_dc1_i,
  input  wire         dcu_store_dc1_i,
  input  wire         dcu_wpt_check_512_dc1_i,
  input  wire [1:0]   cid_vmid_linked_hit_i,

  output wire [31:0]  wcr_o,
  output wire [31:0]  wvr_o,
  output wire [31:0]  wvr_high_o,
  output wire [15:0]  wrp_hit_o
);

  //----------------------------------------------------------------------------
  // Flop declarations
  //----------------------------------------------------------------------------

  reg         wcr0;                 // Watchpoint enable
  reg  [1:0]  wcr_priv_ctl;         // Privileged mode control
  reg  [1:0]  wcr_ls_acc_ctl;       // Load/store access control
  reg  [7:0]  wcr_byte_sel;         // Byte address select bits
  reg  [2:0]  wcr_sec_ctl;          // Security state control
  reg  [1:0]  wcr_linked_brp;       // BRP this WRP is linked to
  reg         wcr_type_linked;      // WRP is linked to a BRP
  reg  [4:0]  wcr_addr_mask;        // Address range mask
  reg  [31:2] wvr;                  // Watchpoint value register
  reg  [16:0] wvr_high;

  //----------------------------------------------------------------------------
  // Wire declarations
  //----------------------------------------------------------------------------

  reg         wrp_sec_priv_match;   // Processor security state and privilege matches
  wire [1:0]  dcu_acc_type;         // Load/store access type (bit 0 = Load/swap, bit 1 = Store/swap)
  wire        wrp_link_check;       // Linked hit check for a WRP
  wire        wrp_ls_match;         // Direction of access matches
  wire        wrp_dva_match;        // DVA hit check for a WRP
  wire [1:0]  next_wcr_linked_brp;  // Compressed linked BRP number
  wire [31:0] wcr_write_data;       // Source data for WCR write
  wire [31:2] wvr_write_data;       // Source data for WVR write
  wire        wcr_en;               // Enable for WCR register
  wire        wvr_en;               // Enable for WVR register
  wire        wvr_high_en;
  wire [16:0] wvr_high_write_data;

  reg  [31:2] wrp_full_mask;         // Full mask for a WCR
  wire        wrp_dva_match_low_128; // For 128-bit matching
  wire        wrp_dva_match_low_512; // For 512-bit matching
  wire        wrp_dva_match_low;
  wire        masked_wvr_check;
  wire [7:0]  mod_wcr_byte_sel;      // Byte address select bits

  wire        wrp_dva_match_high;
  wire        dpu_exception_el1;
  wire        dpu_exception_el2;
  wire        dpu_exception_el3_a32;
  wire        dpu_exception_el3_a64;


  //----------------------------------------------------------------------------
  // WRP register logic
  //----------------------------------------------------------------------------


  // WVR register write (register does not need to be reset)
  assign wvr_write_data = apb_wr_wvr_i ? dpu_dbg_wdata_i[31:2] : dcu_cp_reg_data_i[31:2];

  assign wvr_en = apb_wr_wvr_i | cp14_wr_wvr_i;

  always @(posedge clk_cpregs)
  if (wvr_en) begin
    wvr <= wvr_write_data[31:2];
  end

  assign wvr_o = {wvr[31:2], 2'b00};


  assign wvr_high_en = apb_wr_wvr_high_i | cp14_wr_wvr_high_i;

  assign wvr_high_write_data = apb_wr_wvr_high_i ?
                              (dpu_dbg_wdata_i[16:0]) :
                              (dcu_cp_reg_size_i ? dcu_cp_reg_data_i[48:32] : wvr_high[16:0]);

  always @(posedge clk_cpregs)
  if (wvr_high_en) begin
    wvr_high <= wvr_high_write_data;
  end

  // Unused bits have sign extended values
  assign wvr_high_o = {{15{wvr_high[16]}}, wvr_high};

  // WCR register write (only register enable needs resetting, but must be
  // reset for all WCRs)
  assign wcr_write_data = apb_wr_wcr_i ? dpu_dbg_wdata_i : dcu_cp_reg_data_i[31:0];

  assign wcr_en = apb_wr_wcr_i | cp14_wr_wcr_i;

  always @(posedge clk_cpregs or negedge dbg_resetn_i)
  if (~dbg_resetn_i) begin
    wcr0 <= 1'b0;
  end else if (wcr_en) begin
    wcr0 <= wcr_write_data[0];
  end

  assign next_wcr_linked_brp = (wcr_write_data[19:17] == LINK_BRP_NUM) ? {1'b1, wcr_write_data[16]} :
                                                                         {1'b0, |wcr_write_data[19:16]};

  always @(posedge clk_cpregs)
  if (wcr_en) begin
    wcr_priv_ctl    <= wcr_write_data[2:1];
    wcr_ls_acc_ctl  <= wcr_write_data[4:3];
    wcr_byte_sel    <= wcr_write_data[12:5];
    wcr_sec_ctl     <= wcr_write_data[15:13];
    wcr_linked_brp  <= next_wcr_linked_brp;
    wcr_type_linked <= wcr_write_data[20];
    wcr_addr_mask   <= wcr_write_data[28:24];
  end

  assign wcr_o = {3'b000,
                  wcr_addr_mask[4:0],
                  3'b000,
                  wcr_type_linked,
                  wcr_linked_brp[1] ? {LINK_BRP_NUM, wcr_linked_brp[0]} : 4'h0,
                  wcr_sec_ctl,
                  wcr_byte_sel[7:0],
                  wcr_ls_acc_ctl[1:0],
                  wcr_priv_ctl[1:0],
                  wcr0};


  //----------------------------------------------------------------------------
  // WRP hit checks
  //----------------------------------------------------------------------------


  // DCU access type for WCR LS access control comparison
  assign dcu_acc_type = {dcu_store_dc1_i, ~dcu_store_dc1_i};

  always @(*)
    case (wcr_addr_mask)
      5'b00000: wrp_full_mask = 30'b000000000000000000000000000000;
      5'b00001: wrp_full_mask = 30'b000000000000000000000000000000;
      5'b00010: wrp_full_mask = 30'b000000000000000000000000000000;
      5'b00011: wrp_full_mask = 30'b000000000000000000000000000001;
      5'b00100: wrp_full_mask = 30'b000000000000000000000000000011;
      5'b00101: wrp_full_mask = 30'b000000000000000000000000000111;
      5'b00110: wrp_full_mask = 30'b000000000000000000000000001111;
      5'b00111: wrp_full_mask = 30'b000000000000000000000000011111;
      5'b01000: wrp_full_mask = 30'b000000000000000000000000111111;
      5'b01001: wrp_full_mask = 30'b000000000000000000000001111111;
      5'b01010: wrp_full_mask = 30'b000000000000000000000011111111;
      5'b01011: wrp_full_mask = 30'b000000000000000000000111111111;
      5'b01100: wrp_full_mask = 30'b000000000000000000001111111111;
      5'b01101: wrp_full_mask = 30'b000000000000000000011111111111;
      5'b01110: wrp_full_mask = 30'b000000000000000000111111111111;
      5'b01111: wrp_full_mask = 30'b000000000000000001111111111111;
      5'b10000: wrp_full_mask = 30'b000000000000000011111111111111;
      5'b10001: wrp_full_mask = 30'b000000000000000111111111111111;
      5'b10010: wrp_full_mask = 30'b000000000000001111111111111111;
      5'b10011: wrp_full_mask = 30'b000000000000011111111111111111;
      5'b10100: wrp_full_mask = 30'b000000000000111111111111111111;
      5'b10101: wrp_full_mask = 30'b000000000001111111111111111111;
      5'b10110: wrp_full_mask = 30'b000000000011111111111111111111;
      5'b10111: wrp_full_mask = 30'b000000000111111111111111111111;
      5'b11000: wrp_full_mask = 30'b000000001111111111111111111111;
      5'b11001: wrp_full_mask = 30'b000000011111111111111111111111;
      5'b11010: wrp_full_mask = 30'b000000111111111111111111111111;
      5'b11011: wrp_full_mask = 30'b000001111111111111111111111111;
      5'b11100: wrp_full_mask = 30'b000011111111111111111111111111;
      5'b11101: wrp_full_mask = 30'b000111111111111111111111111111;
      5'b11110: wrp_full_mask = 30'b001111111111111111111111111111;
      5'b11111: wrp_full_mask = 30'b011111111111111111111111111111;
      default:  wrp_full_mask = 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    endcase

  assign dpu_exception_el1     = (dpu_exception_level_i == 2'b01);
  assign dpu_exception_el2     = (dpu_exception_level_i == 2'b10);
  assign dpu_exception_el3_a32 = (dpu_exception_level_i == 2'b11) & ~dpu_aarch64_at_el_i[3];
  assign dpu_exception_el3_a64 = (dpu_exception_level_i == 2'b11) & dpu_aarch64_at_el_i[3];

  // Check that the security state and mode matches
  //  LDRT/STRT are unpredictable at EL2
  //  dcu_priv_dc1_i set means any exception level except
  //   EL0
  //   EL1 with unprivileged instruction
  //   EL3-A32 with unprivileged instruction
  always @*
  case ({wcr_sec_ctl, wcr_priv_ctl})
    5'b000_00: wrp_sec_priv_match = 1'b0;
    5'b000_01: wrp_sec_priv_match = dcu_priv_dc1_i & (dpu_exception_el3_a32 | dpu_exception_el1);
    5'b000_10: wrp_sec_priv_match = ~dcu_priv_dc1_i;
    5'b000_11: wrp_sec_priv_match = ~dpu_exception_el2 & ~dpu_exception_el3_a64;

    5'b001_00: wrp_sec_priv_match = 1'b0;
    5'b001_01: wrp_sec_priv_match = dcu_priv_dc1_i;
    5'b001_10: wrp_sec_priv_match = 1'b0;
    5'b001_11: wrp_sec_priv_match = 1'b1;

    5'b010_00: wrp_sec_priv_match = 1'b0;
    5'b010_01: wrp_sec_priv_match = dpu_ns_state_i & dpu_exception_el1 & dcu_priv_dc1_i;
    5'b010_10: wrp_sec_priv_match = dpu_ns_state_i & ~dcu_priv_dc1_i;
    5'b010_11: wrp_sec_priv_match = dpu_ns_state_i & ~dpu_exception_el2;

    5'b011_00: wrp_sec_priv_match = 1'b0;
    5'b011_01: wrp_sec_priv_match = dpu_ns_state_i & dcu_priv_dc1_i;
    5'b011_10: wrp_sec_priv_match = 1'b0;
    5'b011_11: wrp_sec_priv_match = dpu_ns_state_i;

    5'b100_00: wrp_sec_priv_match = 1'b0;
    5'b100_01: wrp_sec_priv_match = ~dpu_ns_state_i & dcu_priv_dc1_i & (dpu_exception_el3_a32 | dpu_exception_el1);
    5'b100_10: wrp_sec_priv_match = ~dpu_ns_state_i & ~dcu_priv_dc1_i;
    5'b100_11: wrp_sec_priv_match = ~dpu_ns_state_i & ~dpu_exception_el3_a64;

    5'b101_00: wrp_sec_priv_match = dpu_exception_el3_a64; //dcu_priv_dc1_i is always set for EL3-A64
    5'b101_01: wrp_sec_priv_match = ~dpu_ns_state_i & dcu_priv_dc1_i;
    5'b101_10: wrp_sec_priv_match = 1'b0;
    5'b101_11: wrp_sec_priv_match = ~dpu_ns_state_i;

    5'b110_00: wrp_sec_priv_match = 1'b0;
    5'b110_01: wrp_sec_priv_match = 1'b0;
    5'b110_10: wrp_sec_priv_match = 1'b0;
    5'b110_11: wrp_sec_priv_match = 1'b0;

    5'b111_00: wrp_sec_priv_match = dpu_exception_el2;
    5'b111_01: wrp_sec_priv_match = 1'b0;
    5'b111_10: wrp_sec_priv_match = 1'b0;
    5'b111_11: wrp_sec_priv_match = 1'b0;
    default:   wrp_sec_priv_match = 1'bx;
  endcase

  // Check direction of access
  assign wrp_ls_match = |(wcr_ls_acc_ctl[1:0] & dcu_acc_type[1:0]);

  // Check doubleword address of access.
  assign wrp_dva_match_low_512 = (wvr[31:6] == (dpu_va_dc1_i[31:6] & ~wrp_full_mask[31:6]));
                                  
  assign wrp_dva_match_low_128 = wrp_dva_match_low_512 &
                                 (wvr[5:4] == (dpu_va_dc1_i[5:4] & ~wrp_full_mask[5:4]));

  assign wrp_dva_match_low  = dcu_wpt_check_512_dc1_i ? wrp_dva_match_low_512 : wrp_dva_match_low_128;

  assign wrp_dva_match_high = (wvr_high[16:0] == dpu_va_dc1_i[48:32]);

  assign wrp_dva_match = dpu_current_a64_i ? (wrp_dva_match_low & wrp_dva_match_high) :
                                              wrp_dva_match_low;

  // Link check (this is true if the WRP is not linked or is linked
  // and the context ID matches)
  assign wrp_link_check = (wcr_type_linked ? (wcr_linked_brp[1] &
                                              (wcr_linked_brp[0] ? cid_vmid_linked_hit_i[1] :
                                                                   cid_vmid_linked_hit_i[0])) :
                                             1'b1);

  // WVR bits which are masked should be zero
  assign masked_wvr_check = ((wvr[5:2] & wrp_full_mask[5:2]) == 4'b0000);

  // When MASK = 3, need to force the strobes
  assign mod_wcr_byte_sel = (wvr[2] ? {wcr_byte_sel[3:0], 4'b0000} : wcr_byte_sel[7:0]) |
                            {8{wcr_addr_mask[1:0] == 2'b11}};

  // Combine the various hit signals
  assign wrp_hit_o = {16{dpu_dbg_tlb_bkpt_wpt_en_i & wcr0 &
                         wrp_sec_priv_match & wrp_ls_match & wrp_dva_match & wrp_link_check & 
                         masked_wvr_check}} &
                     (((dcu_wpt_check_512_dc1_i & (|mod_wcr_byte_sel)) |
                       (|wcr_addr_mask[4:2]))                            ? {16{1'b1}}                :
                       wvr[3]                                            ? {mod_wcr_byte_sel, 8'h00} :
                                                                           {8'h00, mod_wcr_byte_sel});

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
`ifdef ARM_ASSERT_ON

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wcr_en")
  u_ovl_x_wcr_en (.clk       (clk),
                  .reset_n   (dbg_resetn_i),
                  .qualifier (1'b1),
                  .test_expr (wcr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wvr_en")
  u_ovl_x_wvr_en (.clk       (clk),
                  .reset_n   (dbg_resetn_i),
                  .qualifier (1'b1),
                  .test_expr (wvr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: wvr_high_en")
  u_ovl_x_wvr_high_en (.clk       (clk),
                       .reset_n   (dbg_resetn_i),
                       .qualifier (1'b1),
                       .test_expr (wvr_high_en));

`endif

endmodule // ca53tlb_dbg_wpt

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
