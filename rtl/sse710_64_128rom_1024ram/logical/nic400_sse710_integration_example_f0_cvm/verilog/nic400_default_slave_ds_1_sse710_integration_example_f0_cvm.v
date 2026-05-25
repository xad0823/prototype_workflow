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





`include "nic400_default_slave_ds_1_defs_sse710_integration_example_f0_cvm.v"

module nic400_default_slave_ds_1_sse710_integration_example_f0_cvm (

    
    awid,
    awvalid,
    awready,

    wlast,
    wvalid,
    wready,

    bid,
    bresp,
    bvalid,
    bready,

    arid,
    arlen,
    arvalid,
    arready,

    rid,
    rresp,
    rlast,
    rvalid,
    rready,

    aclk,
    aresetn


);





  input   [11:0]      awid;         
  input               awvalid;      
  output              awready;      

  input               wlast;        
  input               wvalid;       
  output              wready;       

  output  [11:0]      bid;          
  output  [1:0]       bresp;        
  output              bvalid;       
  input               bready;       

  input   [11:0]      arid;         
  input   [7:0]       arlen;        
  input               arvalid;      
  output              arready;      

  output  [11:0]      rid;          
  output  [1:0]       rresp;        
  output              rlast;        
  output              rvalid;       
  input               rready;       

  input               aclk;         
  input               aresetn;      




`include "Axi.v"


wire         aclk;                              
wire         aresetn;                           

wire   [11:0] awid;
wire         awvalid;                           
wire         awready;                           

wire         wlast;                             
wire         wvalid;                            
wire         wready;                            

wire         bvalid;                            
wire         bready;                            
wire   [11:0] bid;  
wire   [1:0] bresp;                             

wire   [11:0] arid; 
wire   [7:0] arlen;                             
wire         arvalid;                           
wire         arready;                           

wire  [11:0] rid;   
wire  [1:0] rresp;                              
wire        rlast;                              
wire        rvalid;                             
wire        rready;                             

reg         aw_state;                            
reg         aw_state_nxt;                         
reg         i_awready;                           
wire        awtrans;                            

reg         w_state;                             
reg         w_state_nxt;                          
reg         i_wready;                            

reg         b_state;                             
reg         b_state_nxt;                          
reg         i_bvalid;                            
reg   [11:0] i_bid;  

reg         ar_state;                            
reg         ar_state_nxt;                         
reg         i_arready;                           
wire        artrans;                            
reg         r_state;                             
reg         r_state_nxt;                          
reg         i_rvalid;                            
reg   [7:0] reads_left;                          
reg   [7:0] reads_left_nxt;                       
wire        i_rlast;                             
reg   [11:0] i_rid;  

assign      awtrans = awvalid & i_awready;   
assign      awready = i_awready;                 
assign      wready  = i_wready;                  
assign      bvalid  = i_bvalid;                  
assign      bresp   = `AXI_RESP_DECERR;         
assign      bid     = i_bid;                     

assign      arready = i_arready;                 
assign      artrans = arvalid & i_arready;   
assign      rvalid  = i_rvalid;                  
assign      rresp   = `AXI_RESP_DECERR;         
assign      rlast   = i_rlast;                   
assign      rid     = i_rid;                     

assign      i_rlast = (reads_left == {8{1'b0}}) ? 1'b1 : 1'b0;



always @(awvalid or i_bvalid or bready or aw_state)
  begin : p_aw_state_comb
    case (aw_state)
  
      `AXIBM_AW_READY_HIGH : 
         begin 
           i_awready = 1'b1; 
           aw_state_nxt = awvalid ? `AXIBM_AW_READY_LOW : 
          `AXIBM_AW_READY_HIGH; 
         end
      
      `AXIBM_AW_READY_LOW :
         begin
           i_awready = 1'b0;
           aw_state_nxt = (i_bvalid & bready) ? `AXIBM_AW_READY_HIGH : 
          `AXIBM_AW_READY_LOW;
         end
      
      default : aw_state_nxt = `AXIBM_AW_READY_HIGH;

    endcase
  end 


  
always @(negedge aresetn or posedge aclk)
  begin : p_aw_stateSeq
    if (~aresetn)
      aw_state <= `AXIBM_AW_READY_HIGH;    
    else
      aw_state <= aw_state_nxt;              
  end


always @(i_awready or wvalid or wlast or i_bvalid or w_state)
  begin : p_w_state_comb
    case (w_state)
  
      `AXIBM_W_READY_LOW :
         begin
           i_wready = 1'b0;
           w_state_nxt = (i_awready || i_bvalid) ? `AXIBM_W_READY_LOW : 
          `AXIBM_W_READY_HIGH;
         end

      `AXIBM_W_READY_HIGH :
         begin
           i_wready = 1'b1;
           w_state_nxt = (wlast & wvalid) ?  `AXIBM_W_READY_LOW : 
          `AXIBM_W_READY_HIGH;
         end

      default : w_state_nxt = `AXIBM_W_READY_LOW;
      
    endcase
  end 
  
  
  
always @(negedge aresetn or posedge aclk)
  begin : p_w_state_seq
    if (~aresetn)
      w_state  <= `AXIBM_W_READY_LOW;     
    else
      w_state  <= w_state_nxt;              
  end


always @(wlast or i_wready or wvalid or bready or b_state)
  begin : p_b_state_comb
    case (b_state)
  
      `AXIBM_B_VALID_LOW :
         begin
            i_bvalid = 1'b0;
            b_state_nxt = (wlast & i_wready & wvalid) ? `AXIBM_B_VALID_HIGH :
           `AXIBM_B_VALID_LOW;
         end

      `AXIBM_B_VALID_HIGH :
         begin
           i_bvalid = 1'b1;
           b_state_nxt = (bready) ? `AXIBM_B_VALID_LOW : 
          `AXIBM_B_VALID_HIGH;
         end

      default : b_state_nxt = `AXIBM_B_VALID_LOW;
      
    endcase
  end 
  
  
  
  always @(negedge aresetn or posedge aclk)
    begin : p_b_stateSeq
      if (~aresetn)
        b_state  <= `AXIBM_B_VALID_LOW;      
      else
       b_state  <= b_state_nxt;                
    end


always @(negedge aresetn or posedge aclk)
  begin : p_bid_set_seq
    if (~aresetn)
      i_bid <= {12{1'b0}};  
    else if(awtrans)
      i_bid <= awid;       
  end



always @(arvalid or rready or i_rlast or ar_state)
  begin : p_ar_stateComb
    case (ar_state)
  
      `AXIBM_AR_READY_HIGH : 
         begin 
           i_arready = 1'b1; 
           ar_state_nxt = arvalid ? `AXIBM_AR_READY_LOW : 
          `AXIBM_AR_READY_HIGH; 
         end
      
      `AXIBM_AR_READY_LOW :
         begin
           i_arready = 1'b0;
           ar_state_nxt = (rready & i_rlast) ? `AXIBM_AR_READY_HIGH : 
          `AXIBM_AR_READY_LOW;
         end
      
      default : ar_state_nxt = `AXIBM_AR_READY_HIGH;

    endcase
  end 


  
always @(negedge aresetn or posedge aclk)
  begin : p_ar_state_seq
    if (~aresetn)
      ar_state <= `AXIBM_AR_READY_HIGH;      
    else
      ar_state <= ar_state_nxt;                
  end


always @(artrans or i_rlast or rready or r_state)
  begin : p_r_state_comb
    case (r_state)
    
      `AXIBM_R_VALID_LOW :
         begin
           i_rvalid = 1'b0;
           r_state_nxt =  (artrans) ? `AXIBM_R_VALID_HIGH : 
          `AXIBM_R_VALID_LOW;
         end

      `AXIBM_R_VALID_HIGH :
         begin
           i_rvalid = 1'b1;
           r_state_nxt = (i_rlast & rready) ? `AXIBM_R_VALID_LOW : 
          `AXIBM_R_VALID_HIGH;
         end

      default : r_state_nxt = `AXIBM_R_VALID_LOW;
        
    endcase
  end 
  
  
  
always @(negedge aresetn or posedge aclk)
  begin : p_r_stateSeq
    if (~aresetn)
      r_state  <= `AXIBM_R_VALID_LOW;     
    else
      r_state  <= r_state_nxt;              
  end


always @(negedge aresetn or posedge aclk)
  begin : p_rid_set_seq
    if (~aresetn)
      i_rid <= {12{1'b0}};  
    else if(artrans)
      i_rid <= arid;                     
  end


always @( artrans or arlen or rready or i_rvalid or reads_left)
  begin : p_r_counter_dec_comb
    if (artrans)                      
       reads_left_nxt = arlen;
    else if((reads_left != {8{1'b0}}) & rready & i_rvalid)   
       reads_left_nxt = reads_left - {{7{1'b0}},1'b1}; 
    else                              
       reads_left_nxt = reads_left;
  end 
  

always @(negedge aresetn or posedge aclk)
  begin : p_r_counter_dec_seq
    if (~aresetn)
      reads_left  <= {8{1'b0}};       
    else
      reads_left  <= reads_left_nxt;  
  end


`include "Axi_undefs.v" 

endmodule

`include "nic400_default_slave_ds_1_undefs_sse710_integration_example_f0_cvm.v"


