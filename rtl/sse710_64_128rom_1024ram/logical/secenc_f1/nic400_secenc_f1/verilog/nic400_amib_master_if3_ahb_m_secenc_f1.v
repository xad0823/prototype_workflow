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
`include "Ahb.v"


module nic400_amib_master_if3_ahb_m_secenc_f1
(
  aclk,
  aresetn,

  awrite,
  aid,
  aaddr,
  alen,
  asize,
  aburst,
  acache,
  aprot,
  avalid,
  aready,

  dbnr,
  did,
  ddata,
  dresp,
  dlast,
  dvalid,
  dready,

  wdata,
  wstrb,
  wlast,
  wvalid,
  wready,

  haddr,
  htrans,
  hwrite,
  hsize,
  hburst,
  hprot,
  hwdata,
  hresp,
  hrdata,
  hready
);



  input                 aclk;                 
  input                 aresetn;              

  input                 awrite;               
  input                 aid;                  
  input       [31:0]    aaddr;                
  input       [7:0]     alen;                 
  input          [2:0]  asize;                
  input          [1:0]  aburst;               
  input          [3:0]  acache;               
  input          [2:0]  aprot;                
  input                 avalid;               
  output                aready;               

  output                dbnr;                 
  output                did;                  
  output        [31:0]  ddata;                
  output         [1:0]  dresp;                
  output                dlast;                
  output                dvalid;               
  input                 dready;               

  input         [31:0]  wdata;                
  input          [3:0]  wstrb;                
  input                 wlast;                
  input                 wvalid;               
  output                wready;               
  input                 hready;               
  input                 hresp;                
  input         [31:0]  hrdata;               
  output      [31:0]    haddr;                
  output         [1:0]  htrans;               
  output                hwrite;               
  output         [2:0]  hsize;                
  output         [2:0]  hburst;               
  output         [3:0]  hprot;                
  output        [31:0]  hwdata;               



  wire                  aclk;                 
  wire                  aresetn;              

  wire                  awrite;               
  wire                  aid;                  
  wire        [31:0]    aaddr;                
  wire        [7:0]     alen;                 
  wire           [2:0]  asize;                
  wire           [1:0]  aburst;               
  wire           [3:0]  acache;               
  wire           [2:0]  aprot;                
  wire                  avalid;               
  wire                  aready;               

  wire                  awrite_reg;           
  wire                  aid_reg;              
  wire        [31:0]    aaddr_reg;            
  wire        [7:0]     alen_reg;             
  wire           [2:0]  asize_reg;            
  wire           [1:0]  aburst_reg;           
  wire           [3:0]  acache_reg;           
  wire           [2:0]  aprot_reg;            

  wire                  dbnr;                 
  wire                  did;                  
  wire          [31:0]  ddata;                
  wire           [1:0]  dresp;                
  wire                  dlast;                
  wire                  dvalid;               
  wire                  dready;               

  wire          [31:0]  wdata;                
  wire           [3:0]  wstrb;                
  wire                  wlast;                
  wire                  wvalid;               
  wire                  wready;               

  wire                  decerr_en;            

  wire                  force_incr;           
  wire                  hready;               
  wire                  hresp;                
  wire          [31:0]  hrdata;               
  wire        [31:0]    haddr;                
  wire           [1:0]  htrans;               
  wire                  hwrite;               
  wire           [2:0]  hsize;                
  wire           [2:0]  hburst;               
  wire           [3:0]  hprot;                
  wire           [3:0]  hwstrb;               
  wire          [31:0]  hwdata;               




  wire                  aready_i;             
  wire                  avalid_i;             
  wire          [53:0]  a_src_data;           
  wire          [53:0]  a_dst_data;           
  wire                  awrite_mux;           
  wire                  aid_mux;              
  wire        [7:0]     alen_mux;             
  wire           [2:0]  asize_mux;            
  wire           [1:0]  aburst_mux;           
  wire           [3:0]  acache_mux;           
  wire                  ach_hndshk;           
  wire           [1:0]  acb_data_in;          
  wire                  acb_push;             
  wire                  acb_push_in;          
  wire                  acb_pop;              
  wire                  acb_pop_in;           
  wire           [1:0]  acb_data_out;         
  wire                  acb_ready;            
  wire                  acb_not_empty;        
  wire          [35:0]  wcb_data_in;          
  wire                  wcb_push;             
  wire                  wcb_push_in;          
  wire                  wcb_pop;              
  wire                  wcb_pop_in;           
  wire          [35:0]  wcb_data_out;         
  wire                  wcb_ready;            
  wire                  wcb_not_empty;        
  wire           [3:0]  hwstrb_nxt;           
  wire          [31:0]  hwdata_nxt;           
  wire                  dbnr_i;               

  wire                  safe_to_start_ahb;    

  wire                  safe_to_start_itb;    

  wire                  nseq_on_ach_hndshk;   

  wire                  nseq_after_hrdy_reg;  

  wire                  start_nseq;           
  wire                  first_aph;            

  wire                  first_aph_rx;         

  wire                  stop_aph;             
  wire                  aph;                  
  wire                  force_undef_incr;     

  wire                  force_incr_mux;       

  wire                  force_incr_aph;       

  wire                  force_incr_burst;     

  wire                  decerr_en_mux;        

  wire                  decerr_en_aph;        

  wire                  unaligned_mux;        

  wire                  unaligned_aph;        

  wire                  unaligned_decerr_en;  
  wire                  increment_haddr;      
  wire        [31:0]    incr_haddr;           
  wire           [5:0]  wrap_mask_n;          
  wire           [5:0]  masked_prev_addr;     

  wire                  addr_wrapped;         

  wire                  wrap_force_nseq;      
  wire                  crosses_1k_mux;       
  wire                  early_ach_hndshk;     
  wire                  stall_bc_load;        

  wire                  load_on_ach_hndshk;   

  wire                  load_on_last_beat_rx; 

  wire                  load_on_rb_recovery;  

  wire                  load_bc_recover;      
  wire                  load_ahb_beat_cnt;    

  wire                  ahb_beat_rx;          

  wire                  ahb_beats_left;       
  wire                  safe_to_start_ahb_wr; 

  wire                  ahb_wr_beats_left;    

  wire                  zero_ahb_wr_beats;    
  wire                  last_ahb_wr_beat;     

  wire                  last_ahb_wr_beat_rx;  

  wire                  ahb_wr_beat_rx;       

  wire                  load_ahb_wbc;         

  wire                  dec_ahb_wbc;          
  wire                  safe_to_start_ahb_rd; 

  wire                  ahb_rd_beats_left;    

  wire                  zero_ahb_rd_beats;    

  wire                  last_ahb_rd_beat;     

  wire                  last_ahb_rd_beat_rx;  

  wire                  ahb_rd_beat_rx;       

  wire                  load_ahb_rbc;         

  wire                  dec_ahb_rbc;          
  wire           [1:0]  beat_resp_mux;        
  wire                  wr_resp_valid;        
  wire           [1:0]  wr_beat_resp;         
  wire           [1:0]  wr_resp_hold;         
  wire           [1:0]  last_wr_resp;         
  wire                  wr_beat_err_resp;     

  wire                  wr_beat_sparse;       

  wire                  wr_beat_strbless;     
  wire                  rd_resp_valid;        
  wire                  last_rd_resp_valid;   
  wire           [1:0]  itb_resp;             
  wire          [36:0]  dcb_data_in;          
  wire                  dcb_push;             
  wire                  dcb_push_in;          
  wire                  dcb_pop;              
  wire                  dcb_pop_in;           
  wire          [36:0]  dcb_data_out;         
  wire                  dcb_ready;            
  wire                  dcb_not_empty;        
  wire                  dcb_may_stall;        
  wire                  itb_rd_beat_rx;       

  wire                  last_itb_wr_beat_rx;  

  wire                  last_itb_beat_rx;     

  wire           [3:0]  strb_chk;             
  wire                  strb_chk_pass;        
  wire                  hwstrbless_nxt;       

  wire                  strbless_on_aph;      

  wire                  strbless_on_dph;      

  wire                  strbless_force_nseq;  

  wire                  idle_recover_nseq;    

  wire                  hwstrbless;           
  wire                  aburst_fixed;         
  wire                  aburst_wrap2;         

  wire                  haddr_at_1kb_bndry;   

  wire                  haddr_at_wrp_bndry;   

  wire                  force_nseq;           
  wire                  nonseq_not_idle;      
  wire                  busy_not_idle;        
  wire                  wr_seq_not_busy;      
  wire                  rd_seq_not_busy;      
  wire                  htrans_bit0_int;      
  wire                  htrans_bit1_int;      
  wire           [1:0]  htrans_aph;           
  wire                  htrans_bit0_masked;   
  wire                  htrans_bit1_masked;   
  wire           [1:0]  htrans_masked;        



  wire                  hwrite_i;             
  wire           [2:0]  hsize_i;              
  wire           [3:0]  hprot_i;              
  wire                  hreadymux_i;          
  wire                  hreadymux_r;          
  wire                  hreadymux_w;          


  reg                   awrite_h;             
  reg                   aid_h;                
  reg         [7:0]     alen_h;               
  reg            [2:0]  asize_h;              
  reg            [1:0]  aburst_h;             
  reg            [3:0]  acache_h;             
  reg            [2:0]  aprot_h;              

  reg                   start_nseq_reg;       
  reg                   first_aph_reg;        
  reg                   aph_reg;              
  reg                   force_incr_mux_h;     
  reg                   decerr_en_mux_h;      
  reg                   force_incr_mux_reg;   
  reg                   decerr_en_mux_reg;    

  reg                   force_incr_dph;       

  reg                   decerr_en_dph;        

  reg         [31:0]    aligned_addr;         
  reg                   unaligned_addr;       
  reg                   unaligned_addr_h;     
  reg                   unaligned_mux_reg;    
  reg                   unaligned_dph;        
  reg            [5:0]  wrap_mask;            
  reg            [5:0]  wrap_mask_reg;        
  reg                   crosses_1k;           
  reg                   crosses_1k_h;         
  reg                   early_ach_hndshk_reg; 
  reg                   stall_bc_load_reg;    
  reg                   load_bc_recover_reg;  
  reg                   load_last_beat_reg;   
  reg            [8:0]     ahb_wbc;              
  reg            [8:0]     ahb_wbc_nxt;          
  reg            [8:0]     ahb_rbc;              
  reg            [8:0]     ahb_rbc_nxt;          
  reg                   reset_wr_resp_hold;   
  reg            [1:0]  wr_resp_hold_reg;     
  reg                   htrans_bit0_aph;      

  reg                   htrans_bit0_aph_reg;  

  reg                   htrans_bit1_aph;      

  reg                   htrans_bit1_aph_reg;  
  reg            [1:0]  htrans_reg;           
  reg            [1:0]  htrans_o;             
  reg                   htrans_bit1_reg_hrdy; 

  reg         [31:0]    haddr_i;              
  reg           [10:0]  haddr_o_reg_htrans;   
  reg            [1:0]  haddr_o_reg_hrdy;       
  reg                   hwrite_o_reg;         
  reg                   hwrite_o_reg_hrdy;    
  reg            [2:0]  hburst_i;             
  reg            [2:0]  hsize_o_reg_hrdy;     
  reg           [31:0]  hwdata_i;             
  reg            [3:0]  hwstrb_i;             
  reg                   hready_reg;           

  reg         [31:0]    haddr_o;              
  reg                   hwrite_o;             
  reg            [2:0]  hsize_o;              
  reg            [2:0]  hburst_o;             
  reg            [3:0]  hprot_o;              


  assign decerr_en  = 1'b0;  
  assign force_incr = 1'b0;  



  assign a_src_data = {awrite,
                       aid,
                       aaddr,
                       alen,
                       asize,
                       aburst,
                       acache,
                       aprot};

  assign {awrite_reg,
          aid_reg,
          aaddr_reg,
          alen_reg,
          asize_reg,
          aburst_reg,
          acache_reg,
          aprot_reg} = a_dst_data;

  nic400_rev_regd_slice_secenc_f1 #(
    .PAYLD_WIDTH     (54)
  ) u_ach_reg_slice
  (
    .aresetn         (aresetn),
    .aclk            (aclk),

    .valid_src       (avalid),
    .ready_dst       (aready_i),
    .payload_src     (a_src_data),

    .valid_dst       (avalid_i),
    .ready_src       (aready),
    .payload_dst     (a_dst_data)
  ); 


  assign safe_to_start_ahb = safe_to_start_ahb_rd & safe_to_start_ahb_wr;

  assign safe_to_start_itb = ~stall_bc_load_reg &
                             dcb_ready &
                             acb_ready &
                             avalid_i  &
                            (( awrite_reg & (wvalid | wcb_not_empty)) |
                              ~awrite_reg);

  assign aready_i = safe_to_start_ahb & safe_to_start_itb;

  assign ach_hndshk = avalid_i & aready_i;


  assign early_ach_hndshk    = ach_hndshk & ((~hreadymux_i & ahb_beats_left) | dcb_may_stall);

  always @ (posedge aclk or negedge aresetn)
  begin : p_early_ach_hndshk_reg_seq
    if (!aresetn) begin
      early_ach_hndshk_reg <= 1'b0;
    end else begin
      early_ach_hndshk_reg <= early_ach_hndshk;
    end
  end 

  assign stall_bc_load = early_ach_hndshk_reg ? 1'b1 :
                         (load_bc_recover_reg ? 1'b0 : stall_bc_load_reg);

  always @ (posedge aclk or negedge aresetn)
  begin : p_stall_bc_load_reg_seq
    if (!aresetn) begin
      stall_bc_load_reg <= 1'b0;
    end else begin
      stall_bc_load_reg <= stall_bc_load;
    end
  end 

  assign load_on_ach_hndshk = ach_hndshk & ~stall_bc_load &
                              ~((~hreadymux_i & ahb_beats_left) | dcb_may_stall);

  assign load_on_last_beat_rx = stall_bc_load &
                                (last_ahb_wr_beat_rx |
                                 last_ahb_rd_beat_rx) &
                                ~dcb_may_stall;

  assign load_on_rb_recovery = stall_bc_load &
                               ~dcb_may_stall & ~ahb_beats_left;

  assign load_bc_recover = load_on_last_beat_rx | load_on_rb_recovery;

  always @ (posedge aclk or negedge aresetn)
  begin : p_load_bc_recover_reg
    if (!aresetn) begin
      load_bc_recover_reg <= 1'b0;
    end else begin
      load_bc_recover_reg <= load_bc_recover;
    end
  end 


  assign safe_to_start_ahb_wr = (zero_ahb_wr_beats & ~first_aph_reg) |
                                (last_ahb_wr_beat & htrans_bit1_aph_reg);

  assign ahb_wr_beats_left = (|ahb_wbc);

  assign zero_ahb_wr_beats = (~|ahb_wbc);

  assign last_ahb_wr_beat = (ahb_wbc == {8'b0,1'b1});

  assign last_ahb_wr_beat_rx = last_ahb_wr_beat & ahb_wr_beat_rx;

  assign ahb_wr_beat_rx = hwrite_o_reg_hrdy & ahb_beat_rx;

  always @* 
  begin : p_ahb_wbc_comb
    ahb_wbc_nxt = ahb_wbc;
    if (load_ahb_wbc) begin
      ahb_wbc_nxt = {1'b0, alen_mux} + {8'b0,1'b1};
    end else if (dec_ahb_wbc) begin
      ahb_wbc_nxt = ahb_wbc - {8'b0,1'b1};
    end
  end 

  assign load_ahb_beat_cnt = load_on_ach_hndshk   |
                             load_on_last_beat_rx | load_on_rb_recovery;

  assign load_ahb_wbc = awrite_mux & load_ahb_beat_cnt;

  assign dec_ahb_wbc = ahb_wr_beat_rx;

  always @(posedge aclk or negedge aresetn)
  begin : p_ahb_wbc_seq
    if (!aresetn) begin
      ahb_wbc <= {8'b0,1'b0};
    end else if (load_ahb_wbc || dec_ahb_wbc) begin
      ahb_wbc <= ahb_wbc_nxt;
    end
  end 


  assign safe_to_start_ahb_rd = (zero_ahb_rd_beats & ~first_aph_reg) |
                                (last_ahb_rd_beat & htrans_bit1_aph_reg);

  assign ahb_rd_beats_left = |ahb_rbc;

  assign zero_ahb_rd_beats = ~|ahb_rbc;

  assign last_ahb_rd_beat = (ahb_rbc == {8'b0,1'b1});

  assign last_ahb_rd_beat_rx = last_ahb_rd_beat & ahb_rd_beat_rx;

  assign ahb_rd_beat_rx = ~hwrite_o_reg_hrdy & ahb_beat_rx;

  always @*
  begin : p_ahb_rbc_comb
    ahb_rbc_nxt = ahb_rbc;
    if (load_ahb_rbc) begin
      ahb_rbc_nxt = {1'b0, alen_mux} + {8'b0,1'b1};
    end else if (dec_ahb_rbc) begin
      ahb_rbc_nxt = ahb_rbc - {8'b0,1'b1};
    end
  end 

  assign load_ahb_rbc = ~awrite_mux & load_ahb_beat_cnt;

  assign dec_ahb_rbc = ahb_rd_beat_rx;

  always @ (posedge aclk or negedge aresetn)
  begin : p_ahb_rbc_seq
    if (!aresetn) begin
      ahb_rbc <= {9{1'b0}};
    end else if (load_ahb_rbc || dec_ahb_rbc) begin
      ahb_rbc <= ahb_rbc_nxt;
    end
  end 

  assign ahb_beat_rx = htrans_bit1_reg_hrdy & hreadymux_r;

  assign ahb_beats_left = ahb_wr_beats_left | ahb_rd_beats_left;


  assign last_itb_wr_beat_rx = wr_resp_valid & dready;

  assign last_itb_beat_rx = (wr_resp_valid | last_rd_resp_valid) &
                             dready;

  assign itb_rd_beat_rx = rd_resp_valid & dready;


  assign acb_data_in = {aid_reg, awrite_reg};
  assign acb_push_in = ach_hndshk;
  assign acb_pop_in  = last_itb_beat_rx;


  nic400_ful_regd_slice_secenc_f1 #(
    .PAYLD_WIDTH    (2)
  ) u_ahb_amib_acb
  (
    .aresetn        (aresetn),
    .aclk           (aclk),
    .valid_src      (acb_push),
    .ready_dst      (acb_pop),
    .payload_src    (acb_data_in),
    .ready_src      (acb_ready),
    .valid_dst      (acb_not_empty),
    .payload_dst    (acb_data_out)
  ); 

  assign acb_push = acb_ready & acb_push_in;

  assign acb_pop = acb_not_empty & acb_pop_in;




  always @ (posedge aclk or negedge aresetn)
  begin : p_reg_itb_ctrl_seq
    if (!aresetn) begin
      awrite_h <= 1'b0;
      aid_h    <= {1{1'b0}};
      alen_h   <= {8{1'b0}};
      asize_h  <= {3{1'b0}};
      aburst_h <= {2{1'b0}};
      acache_h <= {4{1'b0}};
      aprot_h  <= {3{1'b0}};
    end else if (ach_hndshk) begin
      awrite_h <= awrite_reg;
      aid_h    <= aid_reg;
      alen_h   <= alen_reg;
      asize_h  <= asize_reg;
      aburst_h <= aburst_reg;
      acache_h <= acache_reg;
      aprot_h  <= aprot_reg;
    end
  end 

  assign awrite_mux = ach_hndshk ? awrite_reg : awrite_h;
  assign aid_mux    = ach_hndshk ? aid_reg    : aid_h;
  assign alen_mux   = ach_hndshk ? alen_reg   : alen_h;
  assign asize_mux  = ach_hndshk ? asize_reg  : asize_h;
  assign aburst_mux = ach_hndshk ? aburst_reg : aburst_h;
  assign acache_mux = ach_hndshk ? acache_reg : acache_h;


  assign wcb_data_in = {wstrb, wdata};
  assign wcb_push_in = wvalid &
                       (~(aph & hwrite_o & htrans_aph[1] & hreadymux_w) | wcb_not_empty);
  assign wcb_pop_in  = aph & hwrite_o & htrans_aph[1] & hreadymux_w;


  nic400_ful_regd_slice_secenc_f1 #(
    .PAYLD_WIDTH    (36)
  ) u_ahb_amib_wcb
  (
    .aresetn        (aresetn),
    .aclk           (aclk),
    .valid_src      (wcb_push),
    .ready_dst      (wcb_pop),
    .payload_src    (wcb_data_in),
    .ready_src      (wcb_ready),
    .valid_dst      (wcb_not_empty),
    .payload_dst    (wcb_data_out)
  ); 

  assign wcb_push = wcb_ready & wcb_push_in;

  assign wcb_pop = wcb_not_empty & wcb_pop_in;


  assign wready = wcb_ready;

  assign hwstrb_nxt = wcb_not_empty ? wcb_data_out[35:32] :
                            (wvalid ? wstrb : {4{1'b1}});
  assign hwdata_nxt = wcb_not_empty ? wcb_data_out[31:0] : wdata;

  always @ (posedge aclk or negedge aresetn)
  begin : p_reg_ahb_wch_payload
    if (!aresetn) begin
      hwstrb_i <= {4{1'b0}};
      hwdata_i <= {32{1'b0}};
    end else if (hreadymux_i) begin
      hwstrb_i <= hwstrb_nxt;
      hwdata_i <= hwdata_nxt;
    end
  end 

  assign hwstrbless_nxt = ~(|hwstrb_nxt);

  assign strbless_on_aph = force_incr_aph &
                           hwrite_o & hwstrbless_nxt;

  assign strbless_on_dph = force_incr_dph &
                           hwrite_o_reg & hwstrbless;

  assign strbless_force_nseq = ~first_aph & aph &
                               ~strbless_on_aph & strbless_on_dph &
                                ahb_wr_beats_left;

  assign idle_recover_nseq = ~first_aph & aph & hwrite_o &
                             ~(|htrans_reg) & ~htrans_bit1_aph_reg;



  assign dvalid = wr_resp_valid | rd_resp_valid;


  assign dlast = last_rd_resp_valid;


  assign itb_resp[1] = last_wr_resp[1] | unaligned_decerr_en | hresp;
  assign itb_resp[0] = last_wr_resp[0] | unaligned_decerr_en;

  assign dcb_data_in = {hrdata,
                        last_ahb_rd_beat_rx,
                        ahb_rd_beat_rx,
                        last_ahb_wr_beat_rx,
                        itb_resp};
  assign dcb_push_in = ahb_rd_beat_rx | last_ahb_wr_beat_rx;
  assign dcb_pop_in  = itb_rd_beat_rx | last_itb_wr_beat_rx;

  assign beat_resp_mux = dcb_not_empty ? dcb_data_out[1:0] : 2'b00;

  assign wr_resp_valid = dcb_not_empty ? dcb_data_out[2] : 1'b0;

  assign rd_resp_valid = dcb_not_empty ? dcb_data_out[3] : 1'b0;

  assign last_rd_resp_valid = dcb_not_empty ? dcb_data_out[4] : 1'b0;

  assign ddata = dcb_data_out[36:5];


  nic400_ful_regd_slice_secenc_f1 #(
    .PAYLD_WIDTH    (37)
  ) u_ahb_amib_dcb
  (
    .aresetn        (aresetn),
    .aclk           (aclk),
    .valid_src      (dcb_push),
    .ready_dst      (dcb_pop),
    .payload_src    (dcb_data_in),
    .ready_src      (dcb_ready),
    .valid_dst      (dcb_not_empty),
    .payload_dst    (dcb_data_out)
  ); 

  assign dcb_push = dcb_ready & dcb_push_in;

  assign dcb_pop = dcb_not_empty & dcb_pop_in;


  assign dcb_may_stall = ~dready & dcb_not_empty;


  always @ (posedge aclk or negedge aresetn)
  begin : p_haddr_o_reg_hrdy
    if (!aresetn) begin
      haddr_o_reg_hrdy <= {2{1'b0}};
    end else if (hreadymux_i) begin
      haddr_o_reg_hrdy <= haddr_o[1:0];
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_hsize_o_reg_hrdy
    if (!aresetn) begin
      hsize_o_reg_hrdy <= {3{1'b0}};
    end else if (hreadymux_i) begin
      hsize_o_reg_hrdy <= hsize_o;
    end
  end 

  nic400_amib_master_if3_s_gen_secenc_f1 #(
    .DATA_WIDTH     (32)
  ) u_ahb_amib_s_gen
  (
    .addr           (haddr_o_reg_hrdy[1:0]),
    .burst_size     (hsize_o_reg_hrdy),

    .strb           (strb_chk)
  ); 

  assign hwstrbless = ~(|hwstrb_i);

  assign strb_chk_pass = (strb_chk == hwstrb_i) | hwstrbless;

  assign wr_beat_err_resp = ahb_wr_beat_rx & hresp;

  assign wr_beat_sparse = ahb_wr_beat_rx & ~strb_chk_pass &
                          decerr_en_dph;

  assign wr_beat_strbless = ahb_wr_beat_rx & hwstrbless &
                            decerr_en_dph & ~force_incr_dph;

  assign wr_beat_resp[1] = wr_beat_err_resp | wr_beat_sparse | wr_beat_strbless;
  assign wr_beat_resp[0] = wr_beat_sparse | wr_beat_strbless;

  always @ (posedge aclk or negedge aresetn)
  begin : p_reset_wr_resp_hold_seq
    if (!aresetn) begin
      reset_wr_resp_hold <= 1'b0;
    end else begin
      reset_wr_resp_hold <= last_ahb_wr_beat_rx;
    end
  end 

  assign wr_resp_hold =     (wr_beat_resp != 2'b00) ? (wr_beat_resp | wr_resp_hold_reg) :
                        (reset_wr_resp_hold ? 2'b00 : wr_resp_hold_reg);

  assign last_wr_resp = (wr_beat_resp | wr_resp_hold) &
                         {2{last_ahb_wr_beat_rx}};

  always @ (posedge aclk or negedge aresetn)
  begin : p_wr_beat_resp_reg_seq
    if (!aresetn) begin
      wr_resp_hold_reg <= 2'b00;
    end else begin
      wr_resp_hold_reg <= wr_resp_hold;
    end
  end 

  assign dresp = beat_resp_mux;


  assign dbnr_i = acb_not_empty ? acb_data_out[0] : 1'b0;
  assign dbnr = dbnr_i;

  assign did = acb_data_out[1:1];


  always @*
  begin : p_cross_1kb_comb
  
    if (|alen_reg[7:4]) begin
      crosses_1k = 1'b0;
    end else begin
      case (alen_reg)
        `AXI_ALEN_1 : crosses_1k = 1'b0;
        `AXI_ALEN_4 :
          case (asize_reg)
            `AXI_ASIZE_8   : crosses_1k = ( aaddr_reg[9:0]            > 10'h3FC);
            `AXI_ASIZE_16  : crosses_1k = ({aaddr_reg[9:1], 1'b0}     > 10'h3F8);
            `AXI_ASIZE_32  : crosses_1k = ({aaddr_reg[9:2], 2'b00}    > 10'h3F0);
            `AXI_ASIZE_64  : crosses_1k = ({aaddr_reg[9:3], 3'b000}   > 10'h3E0);
            `AXI_ASIZE_128 : crosses_1k = ({aaddr_reg[9:4], 4'b0000}  > 10'h3C0);
            `AXI_ASIZE_256 : crosses_1k = ({aaddr_reg[9:5], 5'b00000} > 10'h380);
            default : crosses_1k = 1'bx;
          endcase
        `AXI_ALEN_8 :
          case (asize_reg)
            `AXI_ASIZE_8   : crosses_1k = ( aaddr_reg[9:0]            > 10'h3F8);
            `AXI_ASIZE_16  : crosses_1k = ({aaddr_reg[9:1], 1'b0}     > 10'h3F0);
            `AXI_ASIZE_32  : crosses_1k = ({aaddr_reg[9:2], 2'b00}    > 10'h3E0);
            `AXI_ASIZE_64  : crosses_1k = ({aaddr_reg[9:3], 3'b000}   > 10'h3C0);
            `AXI_ASIZE_128 : crosses_1k = ({aaddr_reg[9:4], 4'b0000}  > 10'h380);
            `AXI_ASIZE_256 : crosses_1k = ({aaddr_reg[9:5], 5'b00000} > 10'h300);
            default : crosses_1k = 1'bx;
          endcase
        `AXI_ALEN_16 :
          case (asize_reg)
            `AXI_ASIZE_8   : crosses_1k = ( aaddr_reg[9:0]            > 10'h3F0);
            `AXI_ASIZE_16  : crosses_1k = ({aaddr_reg[9:1], 1'b0}     > 10'h3E0);
            `AXI_ASIZE_32  : crosses_1k = ({aaddr_reg[9:2], 2'b00}    > 10'h3C0);
            `AXI_ASIZE_64  : crosses_1k = ({aaddr_reg[9:3], 3'b000}   > 10'h380);
            `AXI_ASIZE_128 : crosses_1k = ({aaddr_reg[9:4], 4'b0000}  > 10'h300);
            `AXI_ASIZE_256 : crosses_1k = ({aaddr_reg[9:5], 5'b00000} > 10'h200);
            default : crosses_1k = 1'bx;
          endcase
        `AXI_ALEN_2,
        `AXI_ALEN_3,
        `AXI_ALEN_5,
        `AXI_ALEN_6,
        `AXI_ALEN_7,
        `AXI_ALEN_9,
        `AXI_ALEN_10,
        `AXI_ALEN_11,
        `AXI_ALEN_12,
        `AXI_ALEN_13,
        `AXI_ALEN_14,
        `AXI_ALEN_15 : crosses_1k = 1'b0;
        default : crosses_1k = 1'bx;
      endcase

    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_crosses_1k_h_seq
    if (!aresetn) begin
      crosses_1k_h <= 1'b0;
    end else if (ach_hndshk) begin
      crosses_1k_h <= crosses_1k;
    end
  end 

  assign crosses_1k_mux = ach_hndshk ? crosses_1k : crosses_1k_h;


  always @* 
  begin : p_detect_unaligned_comb
    case (asize_reg)
      `AXI_ASIZE_8   : unaligned_addr =  1'b0;
      `AXI_ASIZE_16  : unaligned_addr =  aaddr_reg[0];
      `AXI_ASIZE_32  : unaligned_addr = (aaddr_reg[0] | aaddr_reg[1]);
      `AXI_ASIZE_64  : unaligned_addr = (aaddr_reg[0] | aaddr_reg[1] |
                                         aaddr_reg[2]);
      `AXI_ASIZE_128 : unaligned_addr = (aaddr_reg[0] | aaddr_reg[1] |
                                         aaddr_reg[2] | aaddr_reg[3]);
      `AXI_ASIZE_256 : unaligned_addr = (aaddr_reg[0] | aaddr_reg[1] |
                                         aaddr_reg[2] | aaddr_reg[3] |
                                         aaddr_reg[4]);
       default       : unaligned_addr = 1'bx;
    endcase
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_unaligned_addr_h_seq
    if (!aresetn) begin
      unaligned_addr_h <= 1'b0;
    end else if (ach_hndshk) begin
      unaligned_addr_h <= unaligned_addr;
    end
  end 

  assign unaligned_mux = ach_hndshk ? unaligned_addr : unaligned_addr_h;

  always @ (posedge aclk or negedge aresetn)
  begin : p_break_unaligned_mux_timing_seq
    if (!aresetn) begin
      unaligned_mux_reg <= 1'b0;
    end else begin
      unaligned_mux_reg <= unaligned_mux;
    end
  end 

  assign unaligned_aph = unaligned_mux_reg & aph;

  always @ (posedge aclk or negedge aresetn)
  begin : p_unaligned_dph_seq
    if (!aresetn) begin
      unaligned_dph <= 1'b0;
    end else if (hreadymux_i) begin
      unaligned_dph <= unaligned_aph;
    end
  end 

  assign unaligned_decerr_en = unaligned_dph & decerr_en_dph;


  assign force_undef_incr = awrite_mux & (force_incr | acache_mux[3]);

  assign force_incr_mux = ach_hndshk ? force_undef_incr : force_incr_mux_h;

  assign decerr_en_mux = ach_hndshk ? decerr_en : decerr_en_mux_h;

  always @ (posedge aclk or negedge aresetn)
  begin : p_force_incr_mux_h_seq
    if (!aresetn) begin
      force_incr_mux_h <= 1'b0;
    end else if (ach_hndshk) begin
      force_incr_mux_h <= force_undef_incr;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_decerr_en_mux_h_seq
    if (!aresetn) begin
      decerr_en_mux_h <= 1'b0;
    end else if (ach_hndshk) begin
      decerr_en_mux_h <= decerr_en;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_break_tie_offs_timing_seq
    if (!aresetn) begin
      decerr_en_mux_reg  <= 1'b0;
      force_incr_mux_reg <= 1'b0;
    end else begin
      decerr_en_mux_reg  <= decerr_en_mux;
      force_incr_mux_reg <= force_incr_mux;
    end
  end 

  assign force_incr_burst = force_incr_mux & (start_nseq | aph);

  assign force_incr_aph = force_incr_mux_reg & aph;

  assign decerr_en_aph  = decerr_en_mux_reg & aph;

  always @ (posedge aclk or negedge aresetn)
  begin : p_force_incr_dph_seq
    if (!aresetn) begin
      force_incr_dph <= 1'b0;
    end else if (hreadymux_i) begin
      force_incr_dph <= force_incr_aph;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_decerr_en_dph_seq
    if (!aresetn) begin
      decerr_en_dph <= 1'b0;
    end else if (hreadymux_i) begin
      decerr_en_dph <= decerr_en_aph;
    end
  end 



  assign nseq_on_ach_hndshk = ach_hndshk & ~dcb_may_stall;

  assign nseq_after_hrdy_reg = ~first_aph_reg & load_last_beat_reg;

  assign start_nseq = nseq_on_ach_hndshk  |
                      load_on_rb_recovery |
                      nseq_after_hrdy_reg;

  always @ (posedge aclk or negedge aresetn)
  begin : p_start_nseq_reg
    if (!aresetn) begin
      start_nseq_reg <= 1'b0;
    end else begin
      start_nseq_reg <= start_nseq;
    end
  end 

  assign first_aph_rx = first_aph_reg &
                        htrans_bit1_aph_reg & hready_reg;

  assign first_aph = start_nseq_reg ? 1'b1 :
                    (first_aph_rx ? 1'b0 : first_aph_reg);

  always @ (posedge aclk or negedge aresetn)
  begin : p_load_last_beat_reg_seq
    if (!aresetn) begin
      load_last_beat_reg <= 1'b0;
    end else begin
      load_last_beat_reg <= load_on_last_beat_rx;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_hready_reg_seq
    if (!aresetn) begin
      hready_reg <= 1'b0;
    end else begin
      hready_reg <= hreadymux_i;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_first_aph_reg_seq
    if (!aresetn) begin
      first_aph_reg <= 1'b0;
    end else begin
      first_aph_reg <= first_aph;
    end
  end 


  assign stop_aph  = (last_ahb_wr_beat | last_ahb_rd_beat ) &
                      htrans_bit1_reg_hrdy & hready_reg &
                     ~first_aph;

  assign aph = first_aph ? 1'b1 :
               (stop_aph ? 1'b0 : aph_reg);

  always @ (posedge aclk or negedge aresetn)
  begin : p_aph_reg_seq
    if (!aresetn) begin
      aph_reg <= 1'b0;
    end else begin
      aph_reg <= aph;
    end
  end 


  always @* 
  begin : p_gen_hburst_comb
    hburst_i = `AHB_HBURST_SINGLE;
    case (aburst_mux)
      `AXI_ABURST_FIXED : hburst_i = `AHB_HBURST_SINGLE;
      `AXI_ABURST_INCR  :
        begin
          if (crosses_1k_mux || force_incr_burst) begin
            hburst_i = `AHB_HBURST_INCR;
          end else if(|alen_mux[7:4]) begin
            hburst_i = `AHB_HBURST_INCR;
          end else begin
            case (alen_mux)
              `AXI_ALEN_1  : hburst_i = `AHB_HBURST_SINGLE;
              `AXI_ALEN_4  : hburst_i = `AHB_HBURST_INCR4;
              `AXI_ALEN_8  : hburst_i = `AHB_HBURST_INCR8;
              `AXI_ALEN_16 : hburst_i = `AHB_HBURST_INCR16;
              `AXI_ALEN_2,
              `AXI_ALEN_3,
              `AXI_ALEN_5,
              `AXI_ALEN_6,
              `AXI_ALEN_7,
              `AXI_ALEN_9,
              `AXI_ALEN_10,
              `AXI_ALEN_11,
              `AXI_ALEN_12,
              `AXI_ALEN_13,
              `AXI_ALEN_14,
              `AXI_ALEN_15 : hburst_i = `AHB_HBURST_INCR;
              default :
                hburst_i = 3'bxxx;
            endcase
          end
        end
      `AXI_ABURST_WRAP  :
        begin
          if (force_incr_burst) begin
            hburst_i = `AHB_HBURST_INCR;
          end else begin
            case (alen_mux)
              `AXI_ALEN_2  : hburst_i = `AHB_HBURST_SINGLE;
              `AXI_ALEN_4  : hburst_i = `AHB_HBURST_WRAP4;
              `AXI_ALEN_8  : hburst_i = `AHB_HBURST_WRAP8;
              `AXI_ALEN_16 : hburst_i = `AHB_HBURST_WRAP16;
              `AXI_ALEN_3,
              `AXI_ALEN_5,
              `AXI_ALEN_6,
              `AXI_ALEN_7,
              `AXI_ALEN_9,
              `AXI_ALEN_10,
              `AXI_ALEN_11,
              `AXI_ALEN_12,
              `AXI_ALEN_13,
              `AXI_ALEN_14,
              `AXI_ALEN_15 : hburst_i = `AHB_HBURST_INCR;
              default :
                hburst_i = 3'bxxx;
            endcase
          end
        end
      default :
        hburst_i = 3'bxxx;
    endcase
  end 


  assign aburst_fixed = (aburst_h == `AXI_ABURST_FIXED);

  assign aburst_wrap2 = (aburst_h == `AXI_ABURST_WRAP) &&
                        (alen_h   == {4'b0,`AXI_ALEN_2});

  assign haddr_at_1kb_bndry = (haddr_o[10] != haddr_o_reg_htrans[10]);

  assign haddr_at_wrp_bndry = (aburst_h == `AXI_ABURST_WRAP) & addr_wrapped;

  assign wrap_force_nseq = haddr_at_wrp_bndry &
                           force_incr_aph   &
                           ahb_wr_beats_left;

  assign force_nseq = (~first_aph & aph) &
                      (aburst_fixed       |
                       aburst_wrap2       |
                       haddr_at_1kb_bndry |
                       wrap_force_nseq);

  assign busy_not_idle = (~first_aph & aph) & ~force_nseq;

  assign nonseq_not_idle = first_aph;

  assign wr_seq_not_busy = aph & hwrite_o &
                           (wvalid | wcb_not_empty);

  assign rd_seq_not_busy = aph & ~hwrite_o &
                           ~dcb_may_stall;


  assign htrans_bit1_int = nonseq_not_idle |
                           wr_seq_not_busy |
                           rd_seq_not_busy;

  always @* 
  begin : p_htrans_bit1_aph_comb
    if (first_aph || hready_reg) begin
      htrans_bit1_aph = htrans_bit1_int;
    end else begin
      htrans_bit1_aph = htrans_bit1_aph_reg;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_htrans_bit1_aph_reg_seq
    if (!aresetn) begin
      htrans_bit1_aph_reg <= 1'b0;
    end else begin
      htrans_bit1_aph_reg <= htrans_bit1_aph;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_htrans_bit1_reg_hrdy
    if (!aresetn) begin
      htrans_bit1_reg_hrdy <= 1'b0;
    end else if (hreadymux_i) begin
      htrans_bit1_reg_hrdy <= htrans_bit1_aph;
    end
  end 


  assign htrans_bit0_int = busy_not_idle;

  always @* 
  begin : p_htrans_bit0_aph_comb
    if (first_aph || hready_reg) begin
      htrans_bit0_aph = htrans_bit0_int;
    end else begin
      htrans_bit0_aph = htrans_bit0_aph_reg;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_htrans_bit0_aph_reg_seq
    if (!aresetn) begin
      htrans_bit0_aph_reg <= 1'b0;
    end else begin
      htrans_bit0_aph_reg <= htrans_bit0_aph;
    end
  end 


  assign htrans_aph = {htrans_bit1_aph, htrans_bit0_aph};

  assign htrans_bit0_masked =  htrans_aph[0]       &
                              ~strbless_on_aph     &
                              ~strbless_force_nseq &
                              ~idle_recover_nseq;

  assign htrans_bit1_masked =  htrans_bit1_aph & ~strbless_on_aph;

  assign htrans_masked = {htrans_bit1_masked, htrans_bit0_masked};

  always @* 
  begin : p_htrans_comb
    if (first_aph || hready_reg) begin
      htrans_o = htrans_masked;
    end else begin
      htrans_o = htrans_reg;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_htrans_reg_seq
    if (!aresetn) begin
      htrans_reg <= 2'b00;
    end else begin
      htrans_reg <= htrans_o;
    end
  end 


  always @* 
  begin : p_align_addr_comb
    case (asize_reg)
      `AXI_ASIZE_8    : aligned_addr =  aaddr_reg;
      `AXI_ASIZE_16   : aligned_addr = {aaddr_reg[31:1], 1'b0};
      `AXI_ASIZE_32   : aligned_addr = {aaddr_reg[31:2], 2'b00};
      `AXI_ASIZE_64   : aligned_addr = {aaddr_reg[31:3], 3'b000};
      `AXI_ASIZE_128  : aligned_addr = {aaddr_reg[31:4], 4'b0000};
      `AXI_ASIZE_256  : aligned_addr = {aaddr_reg[31:5], 5'b00000};
      `AXI_ASIZE_512  : aligned_addr = aaddr_reg;  
      `AXI_ASIZE_1024 : aligned_addr = aaddr_reg;  
      default : aligned_addr = {32{1'bx}};
    endcase
  end 


  nic400_amib_master_if3_a_gen_secenc_f1 #(
    .ADDR_WIDTH     (12)
  ) u_a_gen
  (
    .addr_in        (haddr_o[11:0]),
    .alen           (alen_mux[3:0]),
    .asize          (asize_mux),
    .aburst         (aburst_mux),

    .addr_out       (incr_haddr[11:0])
  );

  assign incr_haddr[31:12] = haddr_o[31:12];


  always @* 
  begin : p_wrap_mask_comb
    case (asize_mux)
      `AXI_ASIZE_8   : wrap_mask = {2'b0, alen_mux[3:0]};
      `AXI_ASIZE_16  : wrap_mask = {1'b0, alen_mux[3:0], 1'b0};
      `AXI_ASIZE_32  : wrap_mask = {alen_mux[3:0], 2'b00};
      default        : wrap_mask = {6'bx};
    endcase
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_break_wrap_mask_timing_seq
    if (!aresetn) begin
      wrap_mask_reg <= {6'b0};
    end else begin
      wrap_mask_reg <= wrap_mask;
    end
  end 

  assign wrap_mask_n = ~wrap_mask_reg;

  assign masked_prev_addr = haddr_o_reg_htrans[5:0] & wrap_mask_reg;

  assign addr_wrapped = &(masked_prev_addr ^ wrap_mask_n);


  assign increment_haddr = hreadymux_i & htrans_bit1_aph;

  always @* 
  begin : p_haddr_i_comb
    haddr_i = haddr_o;
    if (ach_hndshk) begin
      haddr_i = aligned_addr;
    end else if (increment_haddr) begin
      haddr_i = incr_haddr;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_haddr_o_reg_htrans_seq
    if (!aresetn) begin
      haddr_o_reg_htrans <= {11{1'b0}};
    end else if (htrans_aph[1] && hreadymux_i) begin
      haddr_o_reg_htrans <= haddr_o[10:0];
    end
  end 

  assign hreadymux_r = hready;
  assign hreadymux_w = hready;
  assign hreadymux_i = hready;


  assign hsize_i = asize_mux;

  assign hwrite_i = awrite_mux;

  always @ (posedge aclk or negedge aresetn)
  begin : p_hwrite_o_reg_seq
    if (!aresetn) begin
      hwrite_o_reg <= 1'b0;
    end else begin
      hwrite_o_reg <= hwrite_o;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_hwrite_o_reg_hrdy_seq
    if (!aresetn) begin
      hwrite_o_reg_hrdy <= 1'b0;
    end else if (hreadymux_i) begin
      hwrite_o_reg_hrdy <= hwrite_o;
    end
  end 

  assign hprot_i[3] = acache_mux[2];
  assign hprot_i[2] = acache_mux[0];
  assign hprot_i[1] = ach_hndshk ?  aprot_reg[0] :  aprot_h[0];
  assign hprot_i[0] = ach_hndshk ? ~aprot_reg[2] : ~aprot_h[2];



  always @ (posedge aclk or negedge aresetn)
  begin : p_reg_ahb_fwd_path_seq
    if (!aresetn) begin
      haddr_o     <= {32{1'b0}};
      hwrite_o    <= 1'b0;
      hsize_o     <= {3{1'b0}};
      hburst_o    <= {3{1'b0}};
      hprot_o     <= {4{1'b0}};
    end else begin
      haddr_o     <= haddr_i;
      hwrite_o    <= hwrite_i;
      hsize_o     <= hsize_i;
      hburst_o    <= hburst_i;
      hprot_o     <= hprot_i;
    end
  end 

  assign haddr     = haddr_o;
  assign htrans    = htrans_o;
  assign hwrite    = hwrite_o;
  assign hsize     = hsize_o;
  assign hburst    = hburst_o;
  assign hprot     = hprot_o;
  assign hwstrb    = hwstrb_i;
  assign hwdata    = hwdata_i;

`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  wire ahb_wbc_zero;
  wire ahb_wbc_dec_on_zero;

  assign ahb_wbc_zero = (ahb_wbc == 5'b00000);

  assign ahb_wbc_dec_on_zero = ahb_wbc_zero & dec_ahb_wbc;

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "AHB-Lite AMIB: AHB-Lite Write Beat Counter decremented on zero.")
  ahb_amib_ahb_wbc_dec_on_zero
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (ahb_wbc_dec_on_zero)
  );


  wire ahb_rbc_zero;
  wire ahb_rbc_dec_on_zero;

  assign ahb_rbc_zero = (ahb_rbc == 5'b00000);

  assign ahb_rbc_dec_on_zero = ahb_rbc_zero & dec_ahb_rbc;

  assert_never #(`OVL_FATAL,
                 `OVL_ASSERT,
                 "AHB-Lite AMIB: AHB-Lite Read Beat Counter decremented on zero.")
  ahb_amib_ahb_rbc_dec_on_zero
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (ahb_rbc_dec_on_zero)
  );

`ifdef ARM_OVL_IGNORE_UNALIGN
  initial
    begin : p_ahb_amib_ignore_unalign
      $display("ARM_OVL_IGNORE_UNALIGN: Unalignment OVLs are disabled in %m");
    end 

`else

  wire                  unaligned_itb;        

  assign unaligned_itb = unaligned_addr & ach_hndshk;

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "AHB-Lite AMIB: Unaligned transaction received.")
  ahb_amib_itb_unaligned
  (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  (unaligned_itb)
  );

`endif 
`endif 


endmodule 


`include "Axi_undefs.v"
`include "Ahb_undefs.v"


