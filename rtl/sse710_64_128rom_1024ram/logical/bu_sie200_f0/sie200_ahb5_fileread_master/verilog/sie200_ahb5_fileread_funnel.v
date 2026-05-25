//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2011,2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Aug 29 15:38:23 2016 +0100
//
//      Revision            : dc068a6
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_fileread_funnel (
 input  wire        hclk,
 input  wire        hresetn,
 input  wire        haddr2_s,
 input  wire [63:0] hwdata_s,
 input  wire        hready_s,
 output wire [63:0] hrdata_s,
 output reg  [31:0] hwdata_m,
 input  wire [31:0] hrdata_m);


reg        haddr2_s_reg;


always@(posedge hclk or negedge hresetn)
  begin : p_haddr2_s_reg
    if (hresetn == 1'b0)
      haddr2_s_reg <= 1'b0;
    else
      begin
        if (hready_s == 1'b1)
        haddr2_s_reg <= haddr2_s;
      end
  end


always@(haddr2_s_reg or hwdata_s)
  begin : p_write_mux
    if (haddr2_s_reg == 1'b0)
      hwdata_m = hwdata_s[31:0];
    else
      hwdata_m = hwdata_s[63:32];
  end

  assign hrdata_s = {hrdata_m,hrdata_m};


endmodule
