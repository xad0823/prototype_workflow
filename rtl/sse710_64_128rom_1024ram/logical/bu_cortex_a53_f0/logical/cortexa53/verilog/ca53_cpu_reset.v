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
//      Checked In          : $Date: 2012-03-29 11:45:10 +0100 (Thu, 29 Mar 2012) $
//
//      Revision            : $Revision: 205962 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: CPU reset repeater block
//-----------------------------------------------------------------------------

module ca53_cpu_reset (
  // Inputs
  input  wire                                clk,
  input  wire                                DFTRSTDISABLE,
  input  wire                                reset_n_cpu,
  input  wire                                po_reset_n_cpu,
  // Outputs
  output wire                                reset_n,
  output wire                                po_reset_n
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire         reset_n_repeater;
  wire         po_reset_n_repeater;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Reset control
  // ------------------------------------------------------

  // Core reset synchronisation
  ca53_cell_sync u_ca53_cell_sync1 (.out_o    (reset_n_repeater),
                                    .clk_i    (clk),
                                    .inp_i    (reset_n_cpu),
                                    .resetn_i (reset_n_cpu));

  // CPU power-on reset synchronisation
  ca53_cell_sync u_ca53_cell_sync0 (.out_o    (po_reset_n_repeater),
                                    .clk_i    (clk),
                                    .inp_i    (po_reset_n_cpu),
                                    .resetn_i (po_reset_n_cpu));

  // ------------------------------------------------------
  // Reset assignment
  // ------------------------------------------------------

  assign reset_n    = DFTRSTDISABLE | reset_n_repeater;
  assign po_reset_n = DFTRSTDISABLE | po_reset_n_repeater;

endmodule // ca53_cpu_reset
