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
//   Sub-module of css600_apv1adapter
//
//----------------------------------------------------------------------------


module css600_apv1adapter_decoder (
  input  wire [11:0] paddr_s,
  input  wire        psel_s,
  input  wire        penable_s,
  input  wire        pwrite_s,
  input  wire [31:0] pwdata_s,

  output reg         psel_mgmt,
  output reg         psel_res,
  output reg [7:0]   dapcaddr_m,
  output reg         dapsel_m,
  output reg         dapenable_m,
  output reg         dapwrite_m,
  output reg [31:0]  dapwdata_m
  );

  always @(paddr_s or psel_s or penable_s or pwrite_s or pwdata_s) begin
    psel_mgmt   = 1'b0;
    psel_res    = 1'b0;
    dapcaddr_m  = 8'h00;
    dapsel_m    = 1'b0;
    dapenable_m = 1'b0;
    dapwrite_m  = 1'b0;
    dapwdata_m  = 32'h00000000;
    if (((paddr_s[11]    == 1'b0) ||
         (paddr_s[11:10] == 2'b10) ||
         (paddr_s[11:8]  == 4'b1100))
         && psel_s)
      psel_res = psel_s;
    if ((paddr_s[11:8] == 4'b1101) && psel_s) begin
      dapsel_m    = 1'b1;
      dapcaddr_m  = paddr_s[7:0];
      dapenable_m = penable_s;
      dapwrite_m  = pwrite_s;
      dapwdata_m  = pwdata_s;
    end
    if ((paddr_s[11:9] == 3'b111) && psel_s)
      psel_mgmt = psel_s;
  end

endmodule
