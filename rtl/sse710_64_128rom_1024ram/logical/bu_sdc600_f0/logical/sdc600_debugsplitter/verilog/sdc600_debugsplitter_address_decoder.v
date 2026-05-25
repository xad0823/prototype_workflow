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
//      Checked In          : Thu May 10 21:13:13 2018 +0100
//
//      Revision            : 1b4a001
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_debugsplitter_address_decoder #(
  parameter            ADDR_WIDTH = 32,
  parameter [31:0]  COM_BASE_ADDR = 32'hFFFF_E000
)(
  input   wire [ADDR_WIDTH-1:0] slvaddr,
  input   wire                  dbgen,
  input   wire                  niden,
  input   wire                  spiden,
  input   wire                  spniden,
  input   wire           [ 2:0] slvsize,
  output  reg            [ 2:0] slvsel_m
);


wire auth;

wire [11: 0] unused = slvaddr[11: 0];

assign auth = dbgen | niden | spiden | spniden;

always @(*) begin
   if ((slvaddr[ADDR_WIDTH-1:12] == COM_BASE_ADDR[ADDR_WIDTH-1:12])) begin : COM_SEL
    if (slvsize == 3'b010) begin : SLVSIZE_OK
      slvsel_m = 3'b010;
    end
    else begin
      slvsel_m = 3'b100;
    end
  end
  else begin
    if (auth) begin : AUTH_OK
      slvsel_m = 3'b001;
    end
    else begin
      slvsel_m = 3'b100;
    end
  end
end

endmodule
