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

`include "nic400_ib_hostcpu_axis_ib_defs_sse710_main.v"

module nic400_ib_hostcpu_axis_ib_apb_ib_slv_sse710_main
  (
   pready,
   prdata, 
   pslverr,   
   bypass_merge,
   fn_mod_lb,
   
   decode_match, 
   
   aclk, 
   aresetn, 
   
   
   pclken, 
   paddr, 
   psel, 
   penable, 
   pwrite, 
   pwdata
   );

   input         aclk;                    
   input         aresetn;                 
   input         pclken;                  
   input [31:0]  paddr;                   
   input         psel;                    
   input         penable;                 
   input         pwrite;                  
   input [31:0]  pwdata;                  
   output        pready;                  
   output [31:0] prdata;                  
   output        pslverr;                 

   
   
   output        bypass_merge;   
   output        fn_mod_lb;   
   output        decode_match;





   wire [12:2]             addr;                
   wire [31:0]             data_out;            
   wire [31:0]             wdata_reg;           
   wire                    write_reg;           
   wire                    wr_strb;             
      
   wire                    psel_int;
   wire                    decode_match;



   assign pslverr  = 1'b0;
   
   
   assign psel_int = psel & decode_match;
   assign pready = decode_match & penable;
   
   nic400_ib_hostcpu_axis_ib_apb_cond_ib_slv_sse710_main 
   u_ib_hostcpu_axis_ib_apb_cond
     (
      .aclk               (aclk),
      .aresetn            (aresetn),
      .pclken             (pclken),
      .paddr              (paddr[12:2]),
      .psel               (psel_int),
      .penable            (penable),
      .pwrite             (pwrite),
      .pwdata             (pwdata),
      .data_out           (data_out),

      .prdata             (prdata),
      .pready             (),
      .addr               (addr),
      .wr_strb            (wr_strb),
      .wdata_reg          (wdata_reg),
      .write_reg          (write_reg)
      );
      

   nic400_ib_hostcpu_axis_ib_apb_reg_block_ib_slv_sse710_main 
   u_ib_hostcpu_axis_ib_apb_reg_block
     (
      .write                (write_reg),
      .data_in              (wdata_reg),
      .wr_strb              (wr_strb),
      .aclk                 (aclk),
      .aresetn              (aresetn),
      .pclken               (pclken),
      .addr                 (addr),
      .enable               (psel),

      

      .bypass_merge_reg      (bypass_merge),
      .fn_mod_lb_reg      (fn_mod_lb),
      .data_out             (data_out),
      .decode_match         (decode_match)
      );

    



`ifdef ARM_ASSERT_ON
 
`endif 

endmodule

`include "nic400_ib_hostcpu_axis_ib_undefs_sse710_main.v"

