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

//-----------------------------------------------------------------------------
// Description:
// Reset synchroniser and global clock gate block
//-----------------------------------------------------------------------------


module gic400_clk (
  input wire                      CLK,
  input wire                      DFTRSTDISABLE,
  input wire                      DFTSE,
  input wire                      nRESET,
  input wire                      clk_p_en_i,
  input wire                      clk_pri_en_i,
  output wire                     reset_n_o,
  output wire                     clk_p_o,
  output wire                     clk_pri_o,
  output wire                     load_initial_o
);

  //-----------------------------------------------------------------------------
  // Declarations
  //-----------------------------------------------------------------------------

  wire          gic400_main_rst_ug;
  wire          gic400_main_rst;
  wire          clk_p;
  wire          clk_pri;
  reg           load_initial_q;

  //-----------------------------------------------------------------------------
  // Reset Synchroniser
  //-----------------------------------------------------------------------------

  // Main GIC reset synchroniser
  gic400_sync u_sync (.out_o    (gic400_main_rst_ug),
                      .clk_i    (CLK),
                      .inp_i    (nRESET),
                      .resetn_i (nRESET)
                     );

  // gate reset terms with DFTRSTDISABLE
  assign gic400_main_rst          = gic400_main_rst_ug | DFTRSTDISABLE;


  //-----------------------------------------------------------------------------
  // Clock Gates
  //-----------------------------------------------------------------------------

  gic400_inter_clkgate u_inter_clkgate_p (
    .clk_i         (CLK),
    .clk_enable_i  (clk_p_en_i),
    .clk_senable_i (DFTSE),

    .clk_gated_o   (clk_p)
  );

  gic400_inter_clkgate u_inter_clkgate_pri (
    .clk_i         (CLK),
    .clk_enable_i  (clk_pri_en_i),
    .clk_senable_i (DFTSE),

    .clk_gated_o   (clk_pri)
  );

  //-----------------------------------------------------------------------------
  // Indicate first cycle after reset
  //-----------------------------------------------------------------------------

  // Indicate to the distributor, CPU interface and VCPU interface when it is
  // the first cycle after reset. This is used to gate the clock on constant
  // flops used for ID fields.

  always @(posedge CLK or negedge gic400_main_rst)
    if (!gic400_main_rst)
      load_initial_q <= 1'b1;
    else if (load_initial_q)
      load_initial_q <= 1'b0;


  //-----------------------------------------------------------------------------
  // Assign outputs
  //-----------------------------------------------------------------------------

  assign reset_n_o      = gic400_main_rst;
  assign clk_p_o        = clk_p;
  assign clk_pri_o      = clk_pri;
  assign load_initial_o = load_initial_q;

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_q")
  u_ovl_x_load_initial_q (.clk       (CLK),
                          .reset_n   (gic400_main_rst),
                          .qualifier (1'b1),
                          .test_expr (load_initial_q));


`endif


endmodule
