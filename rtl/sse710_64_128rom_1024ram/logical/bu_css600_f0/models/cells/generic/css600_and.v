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
//   Top level of css600_and
//
//----------------------------------------------------------------------------

module css600_and
#(
  parameter OP_W = 32
)
(
  input  wire [OP_W-1:0]      datain,   // Data to be Masked
  input  wire                 maskn,    // Mask Enable
  output wire [OP_W-1:0]      dataout   // Masked Data Output
);


  //----------------------------------------------------------------------------
  // Beginning of main code
  //----------------------------------------------------------------------------

  // AND Gate Mask
  assign dataout = datain & {OP_W{maskn}};

endmodule
