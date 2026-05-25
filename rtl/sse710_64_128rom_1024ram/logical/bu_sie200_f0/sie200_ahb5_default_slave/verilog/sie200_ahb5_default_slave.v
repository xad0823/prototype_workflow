//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue Aug 9 08:12:07 2016 +0100
//
//      Revision            : 8ac0ed4
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_default_slave
  (
  input  wire                     hclk,
  input  wire                     hresetn,

  input  wire                     hsel,
  input  wire [1:0]               htrans,
  input  wire                     hready,

  output wire                     hexokay,
  output wire                     hreadyout,
  output wire                     hresp
);


localparam UNUSED_WIDTH           = 1;
wire  [UNUSED_WIDTH-1:0] unused   = htrans[0];


wire          trans_req;
reg   [1:0]   resp_state;
wire  [1:0]   next_state;

assign trans_req = hsel & htrans[1] & hready;


assign next_state = { trans_req | ~resp_state[0] ,
                      ~trans_req
                    };

always @(posedge hclk or negedge hresetn) begin
  if (~hresetn) begin
    resp_state <= 2'b01;
  end
  else begin
    resp_state <= next_state;
  end
end


assign hreadyout        = resp_state[0];
assign hresp            = resp_state[1];
assign hexokay          = 1'b0;












endmodule
