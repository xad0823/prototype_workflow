// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2008-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------
// Purpose : CDC Capture
//
// Single register for capturing stable signals crossing a clock domain
// boundary. This will END THE SIMULATION if an unsafe value is captured.
//
//------------------------------------------------------------------------------

module pck600_cdc_capt_nosync #(parameter IH = 0, // high index
                                parameter IL = 0) // low index
  (
  // ------------------------------------------------------
  // Port Declaration
  // ------------------------------------------------------
  input   wire          clk,
  input   wire          reset_n,
  input   wire          en,
  input   wire  [IH:IL] async,     // May be connected to an asynchronous input

  output  reg   [IH:IL] sync
);

  // ------------------------------------------------------
  // reg/wire declarations
  // ------------------------------------------------------

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        sync[IH:IL] <= {(1+IH-IL){1'b0}};
      end
    else if (en)
      begin
        sync[IH:IL] <= async[IH:IL];
      end


endmodule
