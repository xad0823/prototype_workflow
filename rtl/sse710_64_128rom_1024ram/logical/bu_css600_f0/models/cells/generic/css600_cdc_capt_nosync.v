//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_cdc_capt_nosync
//
//----------------------------------------------------------------------------

module css600_cdc_capt_nosync (clk, reset_n, en, d_async_i, q_sync_o);

  parameter IH = 0; // high index
  parameter IL = 0; // low index

  // ------------------------------------------------------
  // port declaration
  // ------------------------------------------------------
  input          clk;
  input          reset_n;
  input          en;
  input  [IH:IL] d_async_i;     // May be connected to an asynchronous input
  output [IH:IL] q_sync_o;

  // ------------------------------------------------------
  // reg/wire declarations
  // ------------------------------------------------------
  reg [IH:IL] q_sync_o;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        q_sync_o[IH:IL] <= {(1+IH-IL){1'b0}};
      end
    else if (en)
      begin
        q_sync_o[IH:IL] <= d_async_i[IH:IL];
      end

endmodule
