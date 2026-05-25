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


module pck600_lpd_p_pstatemap_sse710_extsys 
#(
  parameter DEV_ID          = 0,
  parameter P_CH_PSTATE_LEN = 8
)(
  output reg  [P_CH_PSTATE_LEN-1:0] pstate_map,
  input  wire [P_CH_PSTATE_LEN-1:0] pstate_in
);

localparam DEV_P_CH_0_PWR_PSTATE_MAP_0000 = 4'b0000;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0001 = 4'b0001;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0010 = 4'b0010;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0011 = 4'b0011;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0100 = 4'b0100;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0101 = 4'b0101;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0110 = 4'b0110;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_0111 = 4'b0111;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1000 = 4'b1000;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1001 = 4'b1001;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1010 = 4'b1010;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1011 = 4'b1011;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1100 = 4'b1100;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1101 = 4'b1101;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1110 = 4'b1110;
localparam DEV_P_CH_0_PWR_PSTATE_MAP_1111 = 4'b1111;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0000 = 4'b0000;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0001 = 4'b0001;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0010 = 4'b0010;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0011 = 4'b0011;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0100 = 4'b0100;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0101 = 4'b0101;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0110 = 4'b0110;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_0111 = 4'b0111;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1000 = 4'b1000;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1001 = 4'b1001;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1010 = 4'b1010;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1011 = 4'b1011;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1100 = 4'b1100;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1101 = 4'b1101;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1110 = 4'b1110;
localparam DEV_P_CH_1_PWR_PSTATE_MAP_1111 = 4'b1111;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0000 = 4'b0000;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0001 = 4'b0001;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0010 = 4'b0010;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0011 = 4'b0011;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0100 = 4'b0100;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0101 = 4'b0101;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0110 = 4'b0110;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_0111 = 4'b0111;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1000 = 4'b1000;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1001 = 4'b1001;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1010 = 4'b1010;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1011 = 4'b1011;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1100 = 4'b1100;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1101 = 4'b1101;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1110 = 4'b1110;
localparam DEV_P_CH_2_PWR_PSTATE_MAP_1111 = 4'b1111;

always@*
begin
  if (DEV_ID == 0) 
    begin         
      case (pstate_in[3:0])

        4'b0000 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0000;
        4'b0001 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0001;
        4'b0010 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0010;
        4'b0011 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0011;
        4'b0100 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0100;
        4'b0101 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0101;
        4'b0110 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0110;
        4'b0111 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_0111;
        4'b1000 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1000;
        4'b1001 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1001;
        4'b1010 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1010;
        4'b1011 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1011;
        4'b1100 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1100;
        4'b1101 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1101;
        4'b1110 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1110;
        4'b1111 : pstate_map[3:0] = DEV_P_CH_0_PWR_PSTATE_MAP_1111;
        default : pstate_map[3:0] = 4'hx;
      endcase

   
    end 
  else if (DEV_ID == 1) 
    begin         
      case (pstate_in[3:0])

        4'b0000 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0000;
        4'b0001 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0001;
        4'b0010 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0010;
        4'b0011 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0011;
        4'b0100 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0100;
        4'b0101 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0101;
        4'b0110 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0110;
        4'b0111 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_0111;
        4'b1000 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1000;
        4'b1001 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1001;
        4'b1010 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1010;
        4'b1011 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1011;
        4'b1100 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1100;
        4'b1101 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1101;
        4'b1110 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1110;
        4'b1111 : pstate_map[3:0] = DEV_P_CH_1_PWR_PSTATE_MAP_1111;
        default : pstate_map[3:0] = 4'hx;
      endcase

   
    end 
  else if (DEV_ID == 2) 
    begin         
      case (pstate_in[3:0])

        4'b0000 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0000;
        4'b0001 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0001;
        4'b0010 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0010;
        4'b0011 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0011;
        4'b0100 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0100;
        4'b0101 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0101;
        4'b0110 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0110;
        4'b0111 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_0111;
        4'b1000 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1000;
        4'b1001 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1001;
        4'b1010 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1010;
        4'b1011 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1011;
        4'b1100 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1100;
        4'b1101 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1101;
        4'b1110 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1110;
        4'b1111 : pstate_map[3:0] = DEV_P_CH_2_PWR_PSTATE_MAP_1111;
        default : pstate_map[3:0] = 4'hx;
      endcase

   
    end 
end

endmodule
