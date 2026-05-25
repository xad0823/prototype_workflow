//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Wed Nov 9 16:24:05 2016 +0000
//
//      Revision            : 41e98b3
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_m3_m4_ahb5_adapter_ex_conv (


  input  wire                     hclk            ,
  input  wire                     hresetn         ,

  input  wire                     exreq           ,
  output wire                     exresp          ,

  input  wire                     hready          ,
  input  wire                     hresp           ,
  output wire                     hexcl           ,
  input  wire                     hexokay
);

  reg exreq_dphase;


always @(posedge hclk or negedge hresetn) begin
  if (~hresetn)
    exreq_dphase <= 1'b0;
  else if (hready)
    exreq_dphase <= exreq;
end

assign hexcl  = exreq;
assign exresp = (~(hexokay | hresp)) & exreq_dphase & hready;

endmodule

