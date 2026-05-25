// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
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


module pck600_ppu_ccu_async_sse710_sys
#(
  parameter NUM_PWR_DEVACTIVE = 11,
  parameter DEVACTIVE_LSB = 1
)
(

  //Async DEVxACTIVEs
  input wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_async_i,
  //Sync DEVxACTIVEs and PWAKEUP
  input wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_st_i,
  input wire                  pwakeup_i,
  //Internal QACTIVE
  input wire                  ppuclk_qactive_int_i,
  //QACTIVE
  output wire                 ppuclk_qactive_o

);


  localparam NUM_OR_TREE_INPUTS = NUM_PWR_DEVACTIVE-DEVACTIVE_LSB;


  genvar                      I;

  wire [NUM_OR_TREE_INPUTS-1:0] devactive_async_sync_xor;

  wire                        or_tree_result;

  wire                        devactive_pwakeup;



generate
for(I=DEVACTIVE_LSB; I<NUM_PWR_DEVACTIVE; I=I+1)
begin:pwr_devxactive_xor_gate

  pck600_std_xor2
  u_pck600_xor2_devxactive
  (
    .A  (pwr_devactive_async_i[I]),
    .B  (pwr_devactive_st_i[I]),
    .Y  (devactive_async_sync_xor[I-DEVACTIVE_LSB])
  );

end
endgenerate

  pck600_or_tree
  #(
    .NUM_OR_TREE_INPUTS (NUM_OR_TREE_INPUTS)
  )
  u_pck600_or_tree
  (
    .or_tree_i  (devactive_async_sync_xor),
    .or_tree_o  (or_tree_result)
  );

  pck600_std_or2
  u_pck600_or2_devxactive_pwakeup
  (
    .A  (or_tree_result),
    .B  (pwakeup_i),
    .Y  (devactive_pwakeup)
  );

  pck600_std_or2
  u_pck600_or2_qactive
  (
    .A  (devactive_pwakeup),
    .B  (ppuclk_qactive_int_i),
    .Y  (ppuclk_qactive_o)
  );

endmodule
