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

module nic400_ib_ib4_downsize_wr_cntrl_sse710_main
  (
    aresetn,
    aclk,

    awfifo_valid,
    awfifo_ready,
    awfifo_data,

    wvalid_s,
    wready_s,
    wlast,

    merge,
    merge_clear,
    data_select,
    strb_skid_valid,

    wdata_merged,
    wstrb_merged,

    wvalid_m,
    wready_m,
    wdata_m,
    wstrb_m,
    wlast_m
  );
 
`include "nic400_ib_ib4_defs_sse710_main.v"
`include "Axi.v"

  input                     aclk;
  input                     aresetn;

  output                    awfifo_ready;
  input                     awfifo_valid;
  input [10:0]              awfifo_data;

  input                     wvalid_s;         
  output                    wready_s;         
  input                     wlast;           

  output                    merge;           
  output                    merge_clear;     
  output  [1:0]                data_select;       
  input                     strb_skid_valid;

  input [63:0]              wdata_merged;    
  input [7:0]               wstrb_merged;    
  
  output                    wvalid_m;     
  input                     wready_m;     
  
  output [63:0]             wdata_m;
  output [7:0]              wstrb_m;
  output                    wlast_m;
  

  wire                      slavew_hndshk;      
  wire                      wfifo_hndshk;       
  wire                      awfifo_hndshk;      

  wire                      bypass_in;           
  wire [2:0]                write_size;         
  wire [2:0]                write_addr;        
  wire [2:0]                write_addr_mask;   
  
 
  wire                      bypass;            
  wire [2:0]                a_size;              
  wire [2:0]                addr_mask;
  wire [2:0]                addr_internal;
  

  wire [3:0]                addr_incr;          
  wire [2:0]                store_addr;        

  wire                      wrap_fits_in;
  wire                      wrap_fits;
  

  wire                      cross_boundary;         
  wire                      cross_boundary_sel;
  wire                      idle;
  wire                      wlast_sel;
  wire                      wfifo_valid_next;       
  wire                      wfifo_should_push;       
  wire                      busy_reg_next;          
  wire                      reg_wr_en;              
  wire                      reg_update;
  wire [3:0]                downsize_boundary_mask;


  reg [2:0]                 addr_reg;
  reg [2:0]                 addr_mask_reg;
  reg                       cross_boundary_reg;
  reg [2:0]                 size_reg;
  reg                       bypass_reg;
  reg                       wrap_fits_reg; 
  
  reg [3:0]                 size_incr;
  reg [2:0]                 addr_reg_nxt;              
  reg [1:0]                    data_select;               

  
  reg                       wfifo_valid_reg;           

  reg                       busy_reg;                  
  reg                       merge_clear;               
  reg                       wlast_reg;                 
  
  
  

 assign slavew_hndshk = wvalid_s && wready_s;
 assign wfifo_hndshk  = wvalid_m  &&  wready_m;
 assign awfifo_hndshk = awfifo_valid  &&  awfifo_ready;

 assign merge = slavew_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : last_clear_p
     if (!aresetn)
        merge_clear <= 1'b0;
     else if (merge || wfifo_hndshk)
        merge_clear <= wfifo_hndshk;
   end

 assign idle = (~awfifo_valid && ~busy_reg);
 
 always @(*)
   begin : data_select_p

      
       data_select = {1'b0,1'b1};
   
      if (idle)
         data_select = {2{1'b1}};
   end

 
 assign wready_s = ~strb_skid_valid & ~wfifo_valid_reg;

 assign awfifo_ready = ~busy_reg;

 assign wfifo_valid_next = ((wvalid_m & ~wready_m) || wfifo_valid_reg) & ~wfifo_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wfifo_valid_seq
     if (!aresetn)
        wfifo_valid_reg <= 1'b0;
     else 
        wfifo_valid_reg <= wfifo_valid_next;
   end 

 assign wfifo_should_push = (bypass || wlast_sel || cross_boundary_sel) & (busy_reg || awfifo_hndshk);
 
 assign wvalid_m = wfifo_should_push & (wfifo_valid_reg || merge || strb_skid_valid);

 assign reg_update = slavew_hndshk || (busy_reg_next && strb_skid_valid);

 always @(posedge aclk or negedge aresetn)
  begin : wfifo_data_int_seq
    if (!aresetn) begin
       wlast_reg <= 1'b0;
    end else if (slavew_hndshk) begin
       wlast_reg <= wlast;
    end
  end 

  always @(posedge aclk or negedge aresetn)
  begin : cross_boundary_reg_seq
    if (!aresetn) begin
       cross_boundary_reg <= 1'b0;
    end else if (reg_update) begin
       cross_boundary_reg <= cross_boundary;
    end
  end 
 
 assign wlast_sel        = (wready_s) ? (wlast & wvalid_s) : wlast_reg;

 assign cross_boundary_sel = (wfifo_valid_reg) ? cross_boundary_reg : cross_boundary;

 assign busy_reg_next = ((awfifo_hndshk & ~(strb_skid_valid & wfifo_valid_reg) & ~(wlast_sel & wfifo_hndshk))) ? 1'b1 :
                        ((wfifo_hndshk & wlast_sel) ? 1'b0 : busy_reg);

 always @(posedge aclk or negedge aresetn)
   begin : busy_seq
     if (!aresetn)
        busy_reg <= 1'b0;
     else 
        busy_reg <= busy_reg_next;
   end 

 

 assign bypass_in           = awfifo_data[`AWFIFO_BYPASS];
  
 
 assign write_size          = awfifo_data[`AWFIFO_SIZE];
 assign write_addr          = awfifo_data[`AWFIFO_ADDR];
 assign write_addr_mask     = awfifo_data[`AWFIFO_MASK];
 assign wrap_fits_in        = awfifo_data[`AWFIFO_WRAP_FITS];
 

  

 assign wlast_m   = wlast_sel ;

 assign wdata_m   = wdata_merged;
 assign wstrb_m   = wstrb_merged;
 
 
    




 assign addr_internal = (awfifo_hndshk) ? write_addr : addr_reg;
 assign addr_mask     = (awfifo_hndshk) ? write_addr_mask : addr_mask_reg;
 assign bypass        = (awfifo_hndshk) ? bypass_in : bypass_reg;
 assign a_size        = (awfifo_hndshk) ? write_size :  size_reg;
 assign wrap_fits     = (awfifo_hndshk) ? wrap_fits_in : wrap_fits_reg;
 
 

 always @(*)
 begin : size_incr_p
    case (a_size)
       `AXI_ASIZE_8    : size_incr = {3'b0, 1'b1};
       `AXI_ASIZE_16   : size_incr = {2'b0, 2'b10};          
       `AXI_ASIZE_32   : size_incr = {1'b0, 3'b100};
       `AXI_ASIZE_64   : size_incr = {4'b1000};     
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : size_incr = {3'b0, 1'b1};    
       default         : size_incr = {4'bx};
    endcase
  end

 assign addr_incr = {1'b0, addr_internal} + size_incr;

 always @(*)
  begin : addr_reg_nxt_p
    integer index_i;
    for (index_i = 0; index_i < 3 ; index_i = index_i + 1)
    begin
      if (addr_mask[index_i] == 1'b1)
        addr_reg_nxt[index_i] = addr_incr[index_i];
      else
        addr_reg_nxt[index_i] = addr_internal[index_i];
    end
  end 

 assign store_addr = (reg_update) ? addr_reg_nxt : addr_internal;

 assign reg_wr_en = merge || awfifo_hndshk;

 always @(posedge aclk or negedge aresetn)
    begin : addr_seq
      if (!aresetn)
          addr_reg <= 3'b0;
      else if (reg_wr_en)
          addr_reg <= store_addr;
    end 

 always @(posedge aclk or negedge aresetn)
    begin : store_seq
      if (!aresetn) begin
          addr_mask_reg <= 3'b0;
          bypass_reg <= 1'b0;
          size_reg <= 3'b0;
          wrap_fits_reg <= 1'b0;
      end else if (awfifo_hndshk) begin
          addr_mask_reg <= write_addr_mask;
          bypass_reg <= bypass_in;
          size_reg <= write_size;
          wrap_fits_reg <= wrap_fits_in;
      end
    end 
 
    
 
 assign downsize_boundary_mask = {{1{1'b0}},1'b1,{2{1'b0}}};

 assign cross_boundary = (|((addr_incr ^ {1'b0, addr_internal}) & ({1'b1, ~addr_mask} | downsize_boundary_mask))) & ~(wrap_fits);

 
`ifdef ARM_ASSERT_ON
`include "std_ovl_defines.h"

 

     
     wire        asize_out_range;
 
     assign      asize_out_range = (a_size > `AXI_ASIZE_64);
                                                                                             
     wire        illegal_size_incr;        

     assign illegal_size_incr =  (size_incr == {3'b0, 1'b1}) & asize_out_range;

     assert_never #(`OVL_FATAL,
                    `OVL_ASSERT,
                    "Input a_size to size_incr calculation has gone out of legal range")
     ovl_size_incr_illegal_asize
     (
       .clk        (aclk),
       .reset_n    (aresetn),
       .test_expr  (illegal_size_incr)
     );


`endif
endmodule

`include "nic400_ib_ib4_undefs_sse710_main.v"
`include "Axi_undefs.v"


