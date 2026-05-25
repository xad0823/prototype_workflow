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


module pck600_ppu_input_block_sse710_secenc
#(
  parameter SYNC_EN=1
)
(
  input wire                  clk,
  input wire                  reset_n,

  input wire                  sig_i,

  output wire                 sig_o

);



  wire                        int_sig;


generate
if(SYNC_EN == 1)
begin:input_sync

  pck600_cdc_capt_sync
  u_pck600_sync
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (sig_i),
    .sync    (int_sig)
  );

end
else
begin:input_reg

  reg                         sig_r;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      sig_r <= 1'b0;
    end
    else
    begin
      sig_r <= sig_i;
    end
  end

  assign int_sig = sig_r;

end
endgenerate


  assign sig_o = int_sig;

endmodule

