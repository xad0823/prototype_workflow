//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module firewall_f0_ctlr_adder #(
    parameter ADDER_WIDTH = 11
) (
    input  wire [ADDER_WIDTH-1:0] add_oprnd_shdw_1_i, 
    input  wire [ADDER_WIDTH-1:0] add_oprnd_shdw_2_i, 

    input  wire [ADDER_WIDTH-1:0] add_oprnd_addr_1_i, 
    input  wire [ADDER_WIDTH-1:0] add_oprnd_addr_2_i, 

    input  wire                   add_shdw_en_i,
    input  wire                   add_addr_en_i,

    output wire [ADDER_WIDTH-1:0] add_rslt_o 

);


wire [ADDER_WIDTH-1:0] add_oprnd_1;
wire [ADDER_WIDTH-1:0] add_oprnd_2;

assign add_oprnd_1 = (add_addr_en_i && !add_shdw_en_i) ?
  add_oprnd_addr_1_i : add_oprnd_shdw_1_i;
assign add_oprnd_2 = (add_addr_en_i && !add_shdw_en_i) ?
  add_oprnd_addr_2_i : add_oprnd_shdw_2_i;

assign add_rslt_o = add_oprnd_1 + add_oprnd_2;

endmodule
