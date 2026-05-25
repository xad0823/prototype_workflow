//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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
// Abstract : Call/Return Stack
//-----------------------------------------------------------------------------
//
// Overview
// --------
// Keeps two copies of the pointers to the stack context (speculative and committed),
// the speculative is updated from the PFU, the committed is updated from DPU.
// Mispredicted branches copy the committed pointer on to the speculative copy.
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_crs (
  // Inputs
  input wire         clk,
  input wire         reset_n,
  input wire         dpu_pf_force_i,
  input wire         crs_disable_i,
  input wire         crs_sp_push_i,
  input wire         crs_sp_pop_i,
  input wire         crs_cm_push_i,
  input wire         crs_cm_pop_i,
  input wire [48:0]  crs_addr_i,
  // Outputs
  output wire [48:0] crs_hit_addr_if3_o
);


  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam integer CRS_ENTRIES = 8;
  localparam integer PTR_SIZE    = `CA53_LOG2(CRS_ENTRIES);


  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg  [48:0]            crs_entry_addr  [0:(CRS_ENTRIES-1)];
  reg  [(PTR_SIZE-1):0]  sp_pnt;
  wire [(PTR_SIZE-1):0]  sp_pnt_p1;
  wire [(PTR_SIZE-1):0]  sp_pnt_m1;
  reg  [(PTR_SIZE-1):0]  cm_pnt;
  wire [(PTR_SIZE-1):0]  cm_pnt_p1;
  wire [(PTR_SIZE-1):0]  cm_pnt_m1;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                  crs_entry_en [0:(CRS_ENTRIES-1)];
  wire [(PTR_SIZE-1):0] cm_pnt_nxt;
  wire                  cm_pnt_we;
  wire [(PTR_SIZE-1):0] sp_pnt_nxt;
  wire                  sp_pnt_we;

  genvar i;


  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------


  // ------------------------------------------------------
  // Pointer calculation
  // ------------------------------------------------------

  // Commited pointer
  assign cm_pnt_p1 = cm_pnt + {{(PTR_SIZE-1){1'b0}}, 1'b1};
  assign cm_pnt_m1 = cm_pnt - {{(PTR_SIZE-1){1'b0}}, 1'b1};

  assign cm_pnt_nxt = crs_cm_push_i ? cm_pnt_p1  : crs_cm_pop_i  ? cm_pnt_m1 : cm_pnt;
  assign cm_pnt_we  = crs_cm_push_i | crs_cm_pop_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cm_pnt <= {PTR_SIZE{1'b0}};
    else if (cm_pnt_we)
      cm_pnt <= cm_pnt_nxt;

  // Speculative pointer
  assign sp_pnt_p1 = sp_pnt + {{(PTR_SIZE-1){1'b0}}, 1'b1};
  assign sp_pnt_m1 = sp_pnt - {{(PTR_SIZE-1){1'b0}}, 1'b1};

  // The dpu_pf_force signal is asserted after a misprediction and forces the commit
  // CRS pointer to be copied to the speculative version.
  // The commit push and pop signals are used to update the commit pointer.
  assign sp_pnt_nxt = dpu_pf_force_i ? cm_pnt_nxt : crs_sp_push_i ? sp_pnt_p1 : sp_pnt_m1;
  assign sp_pnt_we  = dpu_pf_force_i | crs_sp_push_i | crs_sp_pop_i;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      sp_pnt <= {PTR_SIZE{1'b0}};
    else if (sp_pnt_we)
      sp_pnt <= sp_pnt_nxt;

  // ------------------------------------------------------
  // CRS entries
  // ------------------------------------------------------

  generate for (i = 0; i < CRS_ENTRIES; i = i+1) begin : gen_crs_entry

    assign crs_entry_en[i] = (sp_pnt == i[0+:PTR_SIZE]) & crs_sp_push_i & ~crs_disable_i;

    always @(posedge clk or negedge reset_n)
      if (!reset_n)
        crs_entry_addr[i]  <= {49{1'b0}};
      else if (crs_entry_en[i])
        crs_entry_addr[i]  <= crs_addr_i;

  end endgenerate

  assign crs_hit_addr_if3_o  = crs_entry_addr[sp_pnt_m1];


  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cm_pnt_we")
  u_ovl_x_cm_pnt_we (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (cm_pnt_we));

  generate for (i=0; i<CRS_ENTRIES; i=i+1) begin : gen_ovl_crs_entry
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: crs_entry_en[i]")
    u_ovl_x_crs_entry0_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (crs_entry_en[1]));
  end endgenerate

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sp_pnt_we")
  u_ovl_x_sp_pnt_we (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (sp_pnt_we));


`endif
endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
