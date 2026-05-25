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



`include "Axi.v"


module nic400_amib_master_if2_s_gen_secenc_f1
(
  addr,
  burst_size,
  strb
);


  parameter DATA_WIDTH = 32;                

  localparam STRB_WIDTH = (DATA_WIDTH / 8);  
  localparam STRB_MAX   = (STRB_WIDTH - 1);  



  input          [1:0]  addr;               
  input          [2:0]  burst_size;         

  output  [STRB_MAX:0]  strb;               

  wire           [1:0]  addr;               
  wire           [2:0]  burst_size;         
  reg     [STRB_MAX:0]  strb;               



  always @ (burst_size or addr)
  begin : p_strb_gen_comb
    case (burst_size)
      `AXI_ASIZE_8 :
        case (addr[1:0])
          2'b00   : strb = 4'b0001;
          2'b01   : strb = 4'b0010;
          2'b10   : strb = 4'b0100;
          2'b11   : strb = 4'b1000;
          default : strb = 4'bxxxx;
        endcase 
      
      `AXI_ASIZE_16 :
        case (addr[1:0])
          2'b00   : strb = 4'b0011;
          2'b01   : strb = 4'b0010;
          2'b10   : strb = 4'b1100;
          2'b11   : strb = 4'b1000;
          default : strb = 4'bxxxx;
        endcase 
      
      `AXI_ASIZE_32 :
        case (addr[1:0])
          2'b00   : strb = 4'b1111;
          2'b01   : strb = 4'b1110;
          2'b10   : strb = 4'b1100;
          2'b11   : strb = 4'b1000;
          default : strb = 4'bxxxx;
        endcase 

      default : strb = 4'bxxxx;
    endcase 
  end 


endmodule 


`include "Axi_undefs.v"



