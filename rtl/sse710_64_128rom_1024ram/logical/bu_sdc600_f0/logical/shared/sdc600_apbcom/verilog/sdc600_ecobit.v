//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue Mar 13 13:27:15 2018 +0000
//
//      Revision            : 465a31a
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_ecobit  #(
  parameter ECOBITVAL = 1'b0
)(
  output    wire  ecobit
);

wire tielow   = 1'b0;
wire tiehigh  = 1'b1;

generate
if (ECOBITVAL == 1'b0) begin : ECOBITLOW
  sdc600_mux u_ecobit (.in_a(tielow), .in_b(tiehigh), .sel( tielow), .out_y(ecobit));
end
else begin : ECOBITHIGH
  sdc600_mux u_ecobit (.in_a(tielow), .in_b(tiehigh), .sel(tiehigh), .out_y(ecobit));
end
endgenerate

endmodule
