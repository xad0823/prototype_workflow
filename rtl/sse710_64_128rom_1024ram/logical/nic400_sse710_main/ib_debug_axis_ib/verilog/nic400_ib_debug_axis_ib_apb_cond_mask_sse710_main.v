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

module nic400_ib_debug_axis_ib_apb_cond_mask_sse710_main
  (
   prdata, pready, addr, wdata_reg, write_reg, wr_strb,
   aclk, aresetn, pclken, paddr, psel, penable, pwrite, pwdata,
   data_out
   );

   input         aclk;          
   input         aresetn;       
   input         pclken;        
   input [12:2]  paddr;         
   input         psel;          
   input         penable;       
   input         pwrite;        
   input [31:0]  pwdata;        
   input [31:0]  data_out;      

   output [31:0] prdata;        
   output        pready;        
   output [12:2] addr;          
   output [31:0] wdata_reg;     
   output        write_reg;     
   output        wr_strb;       



   reg [31:0]    wdata_reg;        
   reg           wr_strb;          
   reg [31:0]    prdata;           

   wire          next_first_penable;
   reg           pready;           
   wire          next_pready;      
   wire          apb_enable;       


   assign apb_enable = pclken & psel;

   always @(posedge aclk or negedge aresetn)
     if (!aresetn) begin
        wdata_reg     <= {32{1'b0}};
        prdata        <= {32{1'b0}};
        wr_strb       <= 1'b0;
        pready        <= 1'b0;
     end else if (apb_enable) begin
        wdata_reg     <= pwdata;
        wr_strb       <= next_first_penable;
        prdata        <= data_out;
        pready        <= next_pready;
     end

   assign next_first_penable = psel & ~penable;
   assign next_pready        = ~next_first_penable;
     
   assign addr = paddr;
   
   assign write_reg = pwrite;


`ifdef ARM_ASSERT_ON



`endif

endmodule

