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

`include "nic400_ib_ib2_defs_sse710_integration_example_f0_host_exp.v"
`include "Axi.v"

module nic400_ib_ib2_downsize_wr_mux_sse710_integration_example_f0_host_exp
  (
    wdata_m,
    wstrb_m,
    wlast_m,
    
    awvalid_m,
    awready_s,
    
    wready_s,
    wvalid_m,
    
    aclk, aresetn,
   
    awaddr_s,
    awlen_s,
    awsize_s,
    awburst_s,
    
    awvalid_s,
    awready_m,
    
    downsize,
    
    wdata_s,
    wstrb_s,
    wlast_s,
    
    wready_m,
    wvalid_s
  );



  input           aclk;
  input           aresetn;
  
  input [2:0]     awaddr_s;
  input [7:0]     awlen_s;
  input [1:0]     awsize_s;  
  input [1:0]     awburst_s;
  
  input           awvalid_s;
  input           awready_m;
  
  
  input           downsize;
  
  input [63:0]    wdata_s;
  input [7:0]     wstrb_s;
  input           wlast_s;
    
  input           wready_m;
  input           wvalid_s;
  
  
  output [31:0]   wdata_m;
  output [3:0]    wstrb_m;
  output          wlast_m;
    
  output          awvalid_m;
  output          awready_s;
  
  output          wready_s;
  output          wvalid_m;
 
  
  wire            awreg_wr_en;
  
  wire [2:0]      awaddr_in;
  wire [7:0]      awlen_in; 
  wire [1:0]      awsize_in; 
  wire [1:0]      awburst_in;
  
  wire            downsize_in;
  
  wire [2:0]      addr_internal;
  wire [3:0]      addr_incr;
  wire            awfifo_hndshk;
  wire            w_hndshk;
  wire            awready_s_i;
  wire            awvalid_m_i;
  wire            wvalid_m_i;
  wire            wlast_m_i;
  
  wire            reg_wr_en;
  wire            beat_reg_wr_en;
  
  wire            avalid_reg_en;
  wire            aready_reg_en;
  wire            stall_reg_en;
  
  wire [63:0]     wdata_s;
  wire [7:0]      wstrb_s;
  wire            wlast_s;
  
  wire [7:0]      write_count;
  wire [7:0]      beat_reg_next;
  wire            aw_busy_reg_next;
  wire            stall_next;
  
  wire            wready_s;
  wire            wvalid_s;
    
  wire [2:0]      store_addr;
  
  wire            cross_boundary;
  wire            data_select;
  
     
     
  reg             avalid_reg;
  reg             aready_reg;     
  
  reg  [2:0]      addr_reg;
  reg  [7:0]      beat_reg;
  
  reg  [7:0]      awlen_reg; 
  reg  [1:0]      awsize_reg;
  reg  [1:0]      awburst_reg;
  
  reg             downsize_reg;
  
  reg  [2:0]      addr_reg_next;
  
  reg  [5:0]      total_bytes;
  reg  [2:0]      addr_mask;
  reg  [3:0]      size_incr;
  
  reg             aw_busy_reg;
  reg             stall;
  
  reg  [31:0]     wdata_m;
  reg  [3:0]      wstrb_m;


          
  
  assign awready_s_i = awready_m & ~(aw_busy_reg & ~stall);
  assign awvalid_m_i = awvalid_s & ~(aw_busy_reg & ~stall);
  assign awready_s   = awready_s_i;
  assign awvalid_m   = awvalid_m_i;
  
  
  assign stall_next = awvalid_m_i & ~awready_m;
  
  assign avalid_reg_en = awvalid_m_i || avalid_reg;
  assign aready_reg_en = aready_reg  || awready_s_i;
  assign stall_reg_en  = awvalid_m_i || stall;

   always @(posedge aclk or negedge aresetn)
     begin : add_push_seq
       if (!aresetn)
         begin
             avalid_reg  <= 1'b0;
             aready_reg  <= 1'b0;
             stall  <= 1'b0;
         end
       else
         begin
            if (avalid_reg_en)
             begin
                 avalid_reg  <= awvalid_m_i;
             end
            if (aready_reg_en)
             begin
                aready_reg <= awready_s_i;
             end
            if (stall_reg_en)
             begin       
                stall <= stall_next;
             end
         end
   end 

   assign awfifo_hndshk = ((awvalid_m_i & ~avalid_reg) | (awvalid_m_i & avalid_reg & aready_reg));

   assign w_hndshk = wready_m & wvalid_m_i; 
 
   assign addr_internal = (awfifo_hndshk) ? awaddr_in : addr_reg;
  
 
   assign awreg_wr_en = awfifo_hndshk;
 
   always @(posedge aclk or negedge aresetn)
     begin : aw_seq
       if (!aresetn) begin
           awlen_reg <= 8'b0;
           awsize_reg <= 2'b0;
           awburst_reg <= 2'b0;
           downsize_reg <= 1'b0;
       end else if (awreg_wr_en) begin
           awlen_reg <= awlen_s;
           awsize_reg <= awsize_s;
           awburst_reg <= awburst_s;
           downsize_reg <= downsize;
       end
     end 
    
   assign awaddr_in = awfifo_hndshk ? awaddr_s[2:0] : addr_reg;
   assign awlen_in = awfifo_hndshk ? awlen_s : awlen_reg;
   assign awsize_in = awfifo_hndshk ? awsize_s : awsize_reg;
   assign awburst_in = awfifo_hndshk ? awburst_s : awburst_reg;
   assign downsize_in = awfifo_hndshk ? downsize : downsize_reg;
   
     
 
   assign data_select = addr_internal[2:2];

   always @(data_select or wdata_s)
     begin : p_wdata_mux
       case (data_select)
         1'd0 : wdata_m = wdata_s[31:0];
         1'd1 : wdata_m = wdata_s[63:32];
         default : wdata_m = 32'bx;
       endcase
     end 
        
   always @(data_select or wstrb_s)
     begin : p_wstrb_mux
       case (data_select)
         1'd0 : wstrb_m = wstrb_s[3:0];
         1'd1 : wstrb_m = wstrb_s[7:4];
         default : wstrb_m = 4'bx;
       endcase
     end 
   

    
 
   always @(awlen_in or awsize_in)
     begin : p_total_bytes
       case (awsize_in)
         2'd0   : total_bytes = awlen_in[5:0];         
         2'd1   : total_bytes = {awlen_in[4:0], 1'b1};    
         2'd2   : total_bytes = {awlen_in[3:0], 2'b11};          
         2'd3   : total_bytes = awlen_in[5:0];       
         
         default         : total_bytes = {6'bx};
       endcase
     end
  
  
  
  
  
   always @( awburst_in or total_bytes )
     begin : p_new_addr_incr_en
       case (awburst_in)
         `AXI_ABURST_FIXED : addr_mask = {3{1'b0}};
         `AXI_ABURST_WRAP  : addr_mask = total_bytes[2:0];
         `AXI_ABURST_INCR  : addr_mask = {3{1'b1}};
         default           : addr_mask = {3{1'bx}};
       endcase
     end 
     
   always @(awsize_in)
     begin : p_size_incr
       case (awsize_in)
         2'd0   : size_incr = {3'b0, 1'b1};    
         2'd1   : size_incr = {2'b0, 2'b10};    
         2'd2   : size_incr = {1'b0, 3'b100};    
         2'd3   : size_incr = {3'b0, 1'b1};    
         default         : size_incr = {4'bx};
       endcase
     end
  
   assign addr_incr = {1'b0, awaddr_in} + size_incr;

   always @(addr_incr or addr_mask or awaddr_in)
     begin : p_addr_reg_next
       integer index_i;
       for (index_i = 0; index_i < 3 ; index_i = index_i + 1)
         begin
           if (addr_mask[index_i] == 1'b1)
             addr_reg_next[index_i] = addr_incr[index_i];
           else
             addr_reg_next[index_i] = awaddr_in[index_i];
         end
     end 

   assign store_addr = (w_hndshk) ? addr_reg_next : awaddr_in;

   assign reg_wr_en = w_hndshk || awfifo_hndshk;

   always @(posedge aclk or negedge aresetn)
     begin : addr_seq
       if (!aresetn)
           addr_reg <= 3'b0;
       else if (reg_wr_en)
           addr_reg <= store_addr;
     end 
    
    
   assign cross_boundary = |((addr_incr ^ {1'b0, awaddr_in}) & ({1'b1, ~addr_mask} | {1'b0,~downsize_in,2'b0}));   
    
    
 
   assign aw_busy_reg_next = ((awfifo_hndshk & ~(wlast_m_i & w_hndshk))) ? 1'b1
                             : ((w_hndshk & wlast_m_i) ? 1'b0 : aw_busy_reg);
                        
    
  
   assign write_count = (awfifo_hndshk) ? awlen_in : beat_reg;
   
   assign beat_reg_next = (|write_count & w_hndshk) ? write_count - {{7{1'b0}},1'b1} : write_count;
 
   assign beat_reg_wr_en = (w_hndshk || awfifo_hndshk); 
 

   always @(posedge aclk or negedge aresetn)
     begin : p_beat_cnt
       if (!aresetn) begin
          beat_reg <= 8'b0;
          aw_busy_reg <= 1'b0;
       end else if (beat_reg_wr_en) begin
          beat_reg <= beat_reg_next;
          aw_busy_reg <= aw_busy_reg_next;
       end   
     end 

 
   assign wlast_m_i = (~|write_count);
   assign wlast_m   = wlast_m_i;
   assign wready_s   = (wready_m & (cross_boundary | (~downsize_in))) & (aw_busy_reg | (awvalid_s && ~stall));
   assign wvalid_m_i = wvalid_s && (aw_busy_reg | (awvalid_s && ~stall));
   assign wvalid_m   = wvalid_m_i;
   
`ifdef ARM_ASSERT_ON   
   
`include "std_ovl_defines.h"

  wire        awsize_out_range;
  
  assign      awsize_out_range = (awsize_in > 2'd2);





  wire                    illegal_total_bytes;        


  assign illegal_total_bytes =  (total_bytes == {2'b0, awlen_in}) & awsize_out_range;

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "Input awsize_in to total_bytes calculation has gone out of legal range")
  ovl_total_bytes_illegal_asize
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (illegal_total_bytes)
  );




  wire                    illegal_size_incr;        

  assign illegal_size_incr =  (size_incr == {3'b0, 1'b1}) & awsize_out_range;

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "Input awsize_in to size_incr calculation has gone out of legal range")
  ovl_size_incr_illegal_asize
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (illegal_size_incr)
  );
`endif

endmodule

`include "nic400_ib_ib2_undefs_sse710_integration_example_f0_host_exp.v"
`include "Axi_undefs.v"

