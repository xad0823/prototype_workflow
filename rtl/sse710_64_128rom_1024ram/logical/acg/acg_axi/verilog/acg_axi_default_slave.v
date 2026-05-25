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


`define AXIBM_AW_READY_HIGH           1'b0
`define AXIBM_AW_READY_LOW            1'b1

`define AXIBM_W_READY_LOW             1'b0
`define AXIBM_W_READY_HIGH            1'b1

`define AXIBM_B_VALID_LOW             1'b0
`define AXIBM_B_VALID_HIGH            1'b1

`define AXIBM_AR_READY_HIGH           1'b0
`define AXIBM_AR_READY_LOW            1'b1

`define AXIBM_R_VALID_LOW             1'b0
`define AXIBM_R_VALID_HIGH            1'b1

`define AXIBM_RLAST_LOW               2'b00
`define AXIBM_RLAST_HIGH_HANDSHAKE    2'b01
`define AXIBM_RLAST_HIGH_NOT_READY    2'b10


module acg_axi_default_slave  #(parameter
      AWID_WIDTH          = 32'd8,
      ARID_WIDTH          = 32'd8
  )
  (

    
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
    aresetn,

    ds_read_busy,
    ds_write_busy
);





  input   [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]      awid;         
  input               awvalid;      
  output              awready;      

  input               wlast;        
  input               wvalid;       
  output              wready;       

  output  [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]      bid;          
  output  [1:0]       bresp;        
  output              bvalid;       
  input               bready;       

  input   [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]      arid;         
  input   [7:0]       arlen;        
  input               arvalid;      
  output              arready;      

  output  [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]      rid;          
  output  [1:0]       rresp;        
  output              rlast;        
  output              rvalid;       
  input               rready;       

  input               aclk;         
  input               aresetn;      

  output              ds_read_busy;
  output              ds_write_busy;




`define AXI_ALEN_1            4'b0000
`define AXI_ALEN_2            4'b0001
`define AXI_ALEN_3            4'b0010
`define AXI_ALEN_4            4'b0011
`define AXI_ALEN_5            4'b0100
`define AXI_ALEN_6            4'b0101
`define AXI_ALEN_7            4'b0110
`define AXI_ALEN_8            4'b0111
`define AXI_ALEN_9            4'b1000
`define AXI_ALEN_10           4'b1001
`define AXI_ALEN_11           4'b1010
`define AXI_ALEN_12           4'b1011
`define AXI_ALEN_13           4'b1100
`define AXI_ALEN_14           4'b1101
`define AXI_ALEN_15           4'b1110
`define AXI_ALEN_16           4'b1111

`define AXI_ASIZE_8           3'b000
`define AXI_ASIZE_16          3'b001
`define AXI_ASIZE_32          3'b010
`define AXI_ASIZE_64          3'b011
`define AXI_ASIZE_128         3'b100
`define AXI_ASIZE_256         3'b101
`define AXI_ASIZE_512         3'b110
`define AXI_ASIZE_1024        3'b111

`define AXI_ABURST_FIXED      2'b00
`define AXI_ABURST_INCR       2'b01
`define AXI_ABURST_WRAP       2'b10

`define AXI_ALOCK_NOLOCK      2'b00
`define AXI_ALOCK_EXCL        2'b01
`define AXI_ALOCK_LOCKED      2'b10

`define AXI_RESP_OKAY         2'b00
`define AXI_RESP_EXOKAY       2'b01
`define AXI_RESP_SLVERR       2'b10
`define AXI_RESP_DECERR       2'b11



wire         aclk;                              
wire         aresetn;                           

reg          ds_read_busy;
wire         next_ds_read_busy;
reg          ds_write_busy;
wire         next_ds_write_busy;

wire   [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awid;
wire         awvalid;                           
wire         awready;                           

wire         wlast;                             
wire         wvalid;                            
wire         wready;                            

wire         bvalid;                            
wire         bready;                            
wire   [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bid;  
wire   [1:0] bresp;                             

wire   [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] arid; 
wire   [7:0] arlen;                             
wire         arvalid;                           
wire         arready;                           

wire  [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] rid;   
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
reg   [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] i_bid;  

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
reg   [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] i_rid;  

assign      awtrans = awvalid & i_awready;   
assign      awready = i_awready;                 
assign      wready  = i_wready;                  
assign      bvalid  = i_bvalid;                  
assign      bresp   = `AXI_RESP_SLVERR;         
assign      bid     = i_bid;                     

assign      arready = i_arready;                 
assign      artrans = arvalid & i_arready;   
assign      rvalid  = i_rvalid;                  
assign      rresp   = `AXI_RESP_SLVERR;         
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

assign next_ds_write_busy = aw_state_nxt == `AXIBM_AW_READY_LOW;

  
always @(negedge aresetn or posedge aclk)
  begin : p_aw_state_seq
    if (~aresetn)
      aw_state <= `AXIBM_AW_READY_HIGH;    
    else
      aw_state <= aw_state_nxt;              
  end


always @(negedge aresetn or posedge aclk)
  begin : ds_write_busy_seq
    if (~aresetn)
      ds_write_busy <= 1'b0;    
    else
      ds_write_busy <= next_ds_write_busy;              
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
    begin : p_b_state_seq
      if (~aresetn)
        b_state  <= `AXIBM_B_VALID_LOW;      
      else
       b_state  <= b_state_nxt;                
    end


always @(negedge aresetn or posedge aclk)
  begin : p_bid_set_seq
    if (~aresetn)
      i_bid <= {((AWID_WIDTH>0)?AWID_WIDTH:1){1'b0}};  
    else if(awtrans)
      i_bid <= awid;       
  end



always @(arvalid or rready or i_rlast or ar_state)
  begin : p_ar_state_comb
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

assign next_ds_read_busy = ar_state_nxt == `AXIBM_AR_READY_LOW;


  
always @(negedge aresetn or posedge aclk)
  begin : p_ar_state_seq
    if (~aresetn)
      ar_state <= `AXIBM_AR_READY_HIGH;      
    else
      ar_state <= ar_state_nxt;                
  end

always @(negedge aresetn or posedge aclk)
  begin : ds_read_busy_seq
    if (~aresetn)
      ds_read_busy <= 1'b0;    
    else
      ds_read_busy <= next_ds_read_busy;              
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
  begin : p_r_state_seq
    if (~aresetn)
      r_state  <= `AXIBM_R_VALID_LOW;     
    else
      r_state  <= r_state_nxt;              
  end


always @(negedge aresetn or posedge aclk)
  begin : p_rid_set_seq
    if (~aresetn)
      i_rid <= {((ARID_WIDTH>0)?ARID_WIDTH:1){1'b0}};  
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



`undef AXI_ALEN_1
`undef AXI_ALEN_2
`undef AXI_ALEN_3
`undef AXI_ALEN_4
`undef AXI_ALEN_5
`undef AXI_ALEN_6
`undef AXI_ALEN_7
`undef AXI_ALEN_8
`undef AXI_ALEN_9
`undef AXI_ALEN_10
`undef AXI_ALEN_11
`undef AXI_ALEN_12
`undef AXI_ALEN_13
`undef AXI_ALEN_14
`undef AXI_ALEN_15
`undef AXI_ALEN_16

`undef AXI_ASIZE_8
`undef AXI_ASIZE_16
`undef AXI_ASIZE_32
`undef AXI_ASIZE_64
`undef AXI_ASIZE_128
`undef AXI_ASIZE_256
`undef AXI_ASIZE_512
`undef AXI_ASIZE_1024

`undef AXI_ABURST_FIXED
`undef AXI_ABURST_INCR
`undef AXI_ABURST_WRAP

`undef AXI_ALOCK_NOLOCK
`undef AXI_ALOCK_EXCL
`undef AXI_ALOCK_LOCKED

`undef AXI_RESP_OKAY
`undef AXI_RESP_EXOKAY
`undef AXI_RESP_SLVERR
`undef AXI_RESP_DECERR

endmodule

`undef AXIBM_AW_READY_HIGH
`undef AXIBM_AW_READY_LOW

`undef AXIBM_W_READY_LOW
`undef AXIBM_W_READY_HIGH

`undef AXIBM_B_VALID_LOW
`undef AXIBM_B_VALID_HIGH

`undef AXIBM_AR_READY_HIGH
`undef AXIBM_AR_READY_LOW

`undef AXIBM_R_VALID_LOW
`undef AXIBM_R_VALID_HIGH

`undef AXIBM_RLAST_LOW
`undef AXIBM_RLAST_HIGH_HANDSHAKE
`undef AXIBM_RLAST_HIGH_NOT_READY

