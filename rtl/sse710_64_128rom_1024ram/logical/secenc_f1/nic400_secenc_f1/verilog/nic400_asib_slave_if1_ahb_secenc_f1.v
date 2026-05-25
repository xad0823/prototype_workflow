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



`include "nic400_asib_slave_if1_ahb_defs_secenc_f1.v"
`include "Axi.v"
`include "AhbDefns.v"

module nic400_asib_slave_if1_ahb_secenc_f1
(
  aclk,
  aresetn,

  r_override,
  w_override,

  haddr,
  hburst,
  hprot,
  hsize,
  htrans,
  hwdata,
  hwrite,
  hreadyout,
  hresp,
  hselx,
  hready,
  hauser,

  awrite,
  aaddr,
  alen,
  asize,
  aburst,
  alock,
  acache,
  aprot,
  avalid,
  aready,
  auser,

  dbnr,
  dresp,
  dlast,
  dvalid,
  dready,

  wdata,
  wstrb,
  wlast,
  wvalid,
  wready
);




  input                 aclk;           
  input                 aresetn;        

  input                 r_override;     
  input                 w_override;     

  input   [31:0]        haddr;          
  input   [2:0]         hburst;         
  input   [3:0]         hprot;          
  input   [2:0]         hsize;          
  input   [1:0]         htrans;         
  input   [31:0]        hwdata;         
  input                 hwrite;         
  output                hreadyout;      
  output                hresp;          
  input                 hselx;          
  input                 hready;         
  input   [1:0]         hauser;         


  output                awrite;         
  output  [31:0]        aaddr;          
  output  [3:0]         alen;           
  output  [2:0]         asize;          
  output  [1:0]         aburst;         
  output  [1:0]         alock;          
  output  [3:0]         acache;         
  output  [2:0]         aprot;          
  output  [1:0]         auser;          
  output                avalid;         
  input                 aready;         

  input                 dbnr;           
  input   [1:0]         dresp;          
  input                 dlast;          
  input                 dvalid;         
  output                dready;         

  output  [31:0]        wdata;          
  output  [3:0]         wstrb;          
  output                wlast;          
  output                wvalid;         
  input                 wready;         



  wire  [31:0]          haddr_int;              
  reg   [1:0]           htrans_int;             
  wire                  hwrite_int;             
  wire  [2:0]           hsize_int;              
  wire  [2:0]           hburst_int;             
  wire  [3:0]           hprot_int;              
  reg                   hselx_int;              
  reg                   hready_int;             
  wire  [1:0]           hauser_int;             
  reg                   w_override_int;         
  reg                   r_override_int;         
  wire                  override_en;            
  wire  [44:0]          ti_reg_payload_in;      
  reg   [44:0]          ti_reg_payload_out;     

  wire  [1:0]           htrans_new;             
  wire                  begin_axi_burst;        
  reg   [3:0]           potential_burst_len;    
  wire  [3:0]           axi_burst_len;          
  wire                  incr_nwrap;             
  wire                  force_axi_single_incr;  
  wire                  break_axi_burst;        
  reg   [2:0]           wdata_size;             
  reg   [1:0]           wstrb_shift;            

  wire  [1:0]           axi_burst_type;         
  reg   [3:0]           axi_cache_type;         
  wire  [2:0]           axi_protection_type;    
  reg   [51:0]          prev_addr_payload;      
  wire                  axi_lock;               

  wire                  ahb_dvalid;             
  reg   [2:0]           ahb_rh_state;           
  reg   [2:0]           ahb_rh_next_state;      
  reg                   ahb_dready;             
  wire                  hreadyout_int;          
  reg                   hresp_out;              
  wire  [1:0]           htrans_current;         

  reg                   hold_addr_payload;      
  wire  [51:0]          addr_payload;           
  wire                  addr_done;              
  reg   [51:0]          addr_payload_out;       
  reg                   avalid_out;             
  wire                  alock1_out;             
  wire                  awrite_out;             
  wire  [3:0]           acache_out;             
  reg   [2:0]           asm_state;              
  reg   [2:0]           asm_next_state;         

  wire                  new_awvalid;            
  wire                  old_avalid_nxt;         
  reg                   old_avalid;             
  reg                   ahb_wc_state;           
  reg                   ahb_wc_next_state;      
  reg                   submit_new_wdata;       

  reg                   axi_wc_state;           
  reg                   axi_wc_next_state;      
  reg                   wvalid_out;             
  reg                   axi_wbeat_done;         
  reg                   write_mask;             
  reg   [3:0]           wstrb;                  

  wire                  r_done;                 
  wire                  w_done;                 
  wire                  b_done;                 
  wire                  d_err;                  
  wire                  axi_rbeat_done;         
  wire                  axi_err;                
  wire                  dready_out;             
  wire                  whandshake_nxt;         
  wire                  whandshake_reg_en;      
  reg                   whandshake_done_reg;    
  wire                  whandshake_done;        
  reg                   bhandshake_done_reg;    
  wire                  bhandshake_done;        
  wire                  bhandshake_nxt;         
  wire                  bhandshake_reg_en;      
  wire                  awhandshake_done;       
  wire                  awhandshake_nxt;        
  wire                  awhandshake_reg_en;     
  reg                   awhandshake_done_reg;   
  reg                   axi_burst_wnr;          
  wire                  wnr_next;               

  wire                  axi_last;               
  wire                  axi_in_burst;           
  reg                   axi_in_burst_reg;       
  wire                  cnt_en;                 
  reg   [2:0]           axi_bc_state;           
  reg   [2:0]           axi_bc_next_state;      
  reg   [3:0]           cnt;                    
  reg   [3:0]           cnt_next;               
  reg                   cnt_load;               
  reg                   broken_burst;           
  reg                   ignore_rresp;           
  reg                   ignore_bresp;           
  reg                   dummy_write;            
  reg                   bc_pause_awaddr;        
  reg                   bc_pause_araddr;        
  wire                  bb_awhandshake_done;    
  wire                  bb_awhandshake_nxt;     
  wire                  bb_awhandshake_reg_en;  
  reg                   bb_awhandshake_done_reg;
  reg                   pause_wdata_submit;     
  wire                  pause_addr_submit;      



  assign ti_reg_payload_in = {haddr,
                              hwrite,
                              hsize,
                              hburst,
                              hprot,
                              hauser
                             };
  assign {haddr_int,
          hwrite_int,
          hsize_int,
          hburst_int,
          hprot_int,
          hauser_int} = ti_reg_payload_out;


  always @ (posedge aclk)
  begin : p_ti_payload_out_seq
      if (hready)
          ti_reg_payload_out <= ti_reg_payload_in;
  end

  always @ (posedge aclk or negedge aresetn)
  begin : p_ti_htrans_hselx_seq
      if (~aresetn) begin
          htrans_int <= 2'b00;
          hselx_int  <= 1'b0;
      end
      else if (hready) begin
          htrans_int <= htrans;
          hselx_int  <= hselx;
      end
  end


  assign override_en = ((htrans == `AHB_TRANS_NONSEQ ||
                         htrans == `AHB_TRANS_IDLE) &&
                        hready) ? 1'b1 : 1'b0;

  always @ (posedge aclk or negedge aresetn)
  begin : p_override_seq
      if (~aresetn) begin
          w_override_int    <= 1'b0;
          r_override_int    <= 1'b0;
      end
      else if (override_en) begin
          w_override_int    <= w_override;
          r_override_int    <= r_override;
      end
  end

  always @ (posedge aclk or negedge aresetn)
  begin : p_ti_ready_reg_seq
      if (~aresetn)
          hready_int <= 1'b0;
      else
          hready_int <= hready;
  end

  assign htrans_new            = htrans_int & {2{hselx_int}};
  assign force_axi_single_incr = htrans_new[1] &&
                                 ((hburst_int == `AHB_BURST_INCR) ||
                                  (w_override_int && hwrite_int) ||
                                  (r_override_int && ~hwrite_int)
                                 );

  assign begin_axi_burst       = hready_int &&
                                 ( (htrans_new == `AHB_TRANS_NONSEQ) ||
                                   (force_axi_single_incr));

  assign incr_nwrap            = ((hburst_int == `AHB_BURST_SINGLE) ||
                                  (hburst_int == `AHB_BURST_INCR)   ||
                                  (hburst_int == `AHB_BURST_INCR4)  ||
                                  (hburst_int == `AHB_BURST_INCR8)  ||
                                  (hburst_int == `AHB_BURST_INCR16))
                                 ? 1'b1 : 1'b0;

  assign break_axi_burst       = hready && axi_in_burst &&
                                 (htrans_new != `AHB_TRANS_IDLE) &&
                                 ((htrans_current == `AHB_TRANS_IDLE) ||
                                  (htrans_current == `AHB_TRANS_NONSEQ));

  assign axi_burst_len         = potential_burst_len &
                                 {4{~force_axi_single_incr}};


  always @ (posedge aclk)
  begin : p_wstrb_shift_gen_seq
      if (hreadyout_int)
      begin
          wdata_size <= hsize;
          wstrb_shift <= haddr[1:0];
      end
  end

  always @ (hburst_int)
  begin : p_potential_burst_len_comb
      case(hburst_int)
          `AHB_BURST_SINGLE:  potential_burst_len = 4'b0000;
          `AHB_BURST_INCR:    potential_burst_len = 4'b0000;
          `AHB_BURST_WRAP4:   potential_burst_len = 4'b0011;
          `AHB_BURST_INCR4:   potential_burst_len = 4'b0011;
          `AHB_BURST_WRAP8:   potential_burst_len = 4'b0111;
          `AHB_BURST_INCR8:   potential_burst_len = 4'b0111;
          `AHB_BURST_WRAP16:  potential_burst_len = 4'b1111;
          `AHB_BURST_INCR16:  potential_burst_len = 4'b1111;
          default:            potential_burst_len = 4'bxxxx;
      endcase
  end


  assign axi_burst_type = (incr_nwrap | force_axi_single_incr)
                          ? `AXI_ABURST_INCR : `AXI_ABURST_WRAP;

  always @ (hprot_int)
  begin : p_cache_type_comb
      case (hprot_int[3:2])
          2'b00:   axi_cache_type = 4'b0000;
          2'b01:   axi_cache_type = 4'b0001;
          2'b10:   axi_cache_type = 4'b0010;
          2'b11:   axi_cache_type = 4'b1111;
          default: axi_cache_type = 4'bxxxx;
      endcase
  end

  assign axi_protection_type[0] = hprot_int[1];   
  assign axi_protection_type[1] = 1'b0;           
  assign axi_protection_type[2] = ~hprot_int[0];  


  assign axi_lock = 1'b0;

  assign addr_payload = {hwrite_int,          
                         haddr_int,           
                         axi_burst_len,       
                         hsize_int,           
                         axi_burst_type,      
                         axi_lock,            
                         axi_cache_type,      
                         axi_protection_type, 
                         hauser_int
                        };


  assign new_awvalid    = avalid_out & ~old_avalid & awrite_out;
  assign old_avalid_nxt = avalid_out & ~aready;

  always @ (posedge aclk or negedge aresetn)
  begin
      if (~aresetn)
         old_avalid <= 1'b0;
      else
         old_avalid <= old_avalid_nxt;
  end


  always @ (posedge aclk or negedge aresetn)
  begin : p_ahb_wc_state_reg_seq
      if (!aresetn)
         ahb_wc_state <= `AHB_WC_IDLE;
      else
         ahb_wc_state <= ahb_wc_next_state;
  end
  always @ (new_awvalid or pause_wdata_submit or htrans_int or
            axi_last or w_done or ahb_wc_state)
  begin : p_ahb_wc_state_comb
      case (ahb_wc_state)
          `AHB_WC_IDLE: begin
              submit_new_wdata = 1'b0;
              if (new_awvalid)
                  ahb_wc_next_state = `AHB_WC_SUBMIT;
              else
                  ahb_wc_next_state = ahb_wc_state;
          end
          `AHB_WC_SUBMIT: begin
              submit_new_wdata = (!pause_wdata_submit &&
                                     (htrans_int != `AHB_TRANS_BUSY)) ?
                                         1'b1: 1'b0;
              if ((pause_wdata_submit || (axi_last && w_done)) && !new_awvalid)
                  ahb_wc_next_state = `AHB_WC_IDLE;
              else
                  ahb_wc_next_state = ahb_wc_state;
          end
          default: begin
              submit_new_wdata  = 1'bx;
              ahb_wc_next_state = 1'bx;
          end
      endcase
  end



  assign htrans_current = htrans & {2{hselx}};

  always @ (posedge aclk or negedge aresetn)
  begin : p_ahb_rh_state_reg_seq
      if (~aresetn)
          ahb_rh_state <= `AHB_RH_IDLE_BUSY;
      else
          ahb_rh_state <= ahb_rh_next_state;
  end

  always @ (ahb_rh_state or axi_err or ahb_dvalid or htrans_current or
            awhandshake_done or hwrite_int or hready)
  begin : p_ahb_rh_state_comb
      case (ahb_rh_state)
          `AHB_RH_IDLE_BUSY: begin
              ahb_dready    = 1'b0;
              hresp_out     = 1'b0;
              if (htrans_current[1] && hready)
                  ahb_rh_next_state = `AHB_RH_SEQ_NSEQ;
              else
                  ahb_rh_next_state = `AHB_RH_IDLE_BUSY;
          end
          `AHB_RH_SEQ_NSEQ: begin
              ahb_dready    = ~axi_err;
              hresp_out     = axi_err & (awhandshake_done | ~hwrite_int);
              if (axi_err && (awhandshake_done || !hwrite_int))
                  ahb_rh_next_state = `AHB_RH_ERROR;
              else if (!axi_err && ahb_dvalid && !htrans_current[1])
                  ahb_rh_next_state = `AHB_RH_IDLE_BUSY;
              else
                  ahb_rh_next_state = `AHB_RH_SEQ_NSEQ;
          end
          `AHB_RH_ERROR: begin
              ahb_dready    = 1'b1;
              hresp_out     = 1'b1;
              if (htrans_current[1])
                  ahb_rh_next_state = `AHB_RH_SEQ_NSEQ;
              else
                  ahb_rh_next_state = `AHB_RH_IDLE_BUSY;
          end
          default: begin 
              ahb_dready    = 1'b0;
              hresp_out     = 1'b0;
              ahb_rh_next_state = `AHB_RH_IDLE_BUSY;
          end
      endcase
  end

  assign hreadyout_int = (ahb_rh_state == `AHB_RH_SEQ_NSEQ) ?
                            (~axi_err & ahb_dvalid) : 1'b1;

  assign ahb_dvalid = axi_rbeat_done |
                      (whandshake_done & ~axi_last) |
                      (bhandshake_done & awhandshake_done);
  assign hreadyout = hreadyout_int;
  assign hresp     = hresp_out;




  always @ (hold_addr_payload or addr_payload or prev_addr_payload)
  begin : p_hold_addr_payload_mux_comb
      case (hold_addr_payload)
          1'b0:    addr_payload_out = addr_payload;
          1'b1:    addr_payload_out = prev_addr_payload;
          default: addr_payload_out = {52{1'bx}};
      endcase
  end

  always @ (posedge aclk or negedge aresetn)
  begin : p_addr_payload_holding_reg_seq
      if (~aresetn)
          prev_addr_payload <= {52{1'b0}};
      else
          prev_addr_payload <= addr_payload_out;
  end

  assign {awrite_out,
          aaddr,
          alen,
          asize,
          aburst,
          alock1_out,
          acache_out,
          aprot,
          auser
  } = addr_payload_out;

  assign acache = acache_out;
  assign awrite = awrite_out;
  assign alock[1] = alock1_out;
  assign alock[0] = 1'b0;
  assign addr_done = aready & avalid_out;
  assign avalid = avalid_out;


  always @ (posedge aclk or negedge aresetn)
  begin : p_asm_state_reg_seq
      if (~aresetn)
          asm_state <= `AXI_ASM_IDLE;
      else
          asm_state <= asm_next_state;
  end

  always @ (begin_axi_burst or asm_state or aready or pause_addr_submit)
  begin : p_asm_state_comb
      case (asm_state)
          `AXI_ASM_IDLE: begin
              avalid_out = begin_axi_burst & ~pause_addr_submit;
              hold_addr_payload = 1'b0;
              if ( begin_axi_burst && !aready && ~pause_addr_submit)
                  asm_next_state = `AXI_ASM_KEEP_AVALID;
              else if (begin_axi_burst & pause_addr_submit) 
                  asm_next_state = `AXI_ASM_PAUSE_ADDR;
              else
                  asm_next_state = asm_state;
          end
          `AXI_ASM_PAUSE_ADDR: begin
              avalid_out = ~pause_addr_submit;
              hold_addr_payload = 1'b1;
              if (~pause_addr_submit && aready) 
                  asm_next_state = `AXI_ASM_IDLE;
              else if (~pause_addr_submit & !aready) 
                  asm_next_state = `AXI_ASM_KEEP_AVALID;
              else
                  asm_next_state = asm_state;
          end
          `AXI_ASM_KEEP_AVALID: begin
              avalid_out = 1'b1;
              hold_addr_payload = 1'b1;
              if (aready && !begin_axi_burst)
                  asm_next_state = `AXI_ASM_IDLE;
              else if (aready && begin_axi_burst)
                  asm_next_state = `AXI_ASM_BEGIN_NEW;
              else if (!aready && begin_axi_burst)
                  asm_next_state = `AXI_ASM_NEW_PENDING;
              else
                  asm_next_state = asm_state;
          end
          `AXI_ASM_NEW_PENDING: begin
              avalid_out = 1'b1;
              hold_addr_payload = 1'b1;
              if (aready)
                  asm_next_state = `AXI_ASM_BEGIN_NEW;
              else
                  asm_next_state = asm_state;
          end
          `AXI_ASM_BEGIN_NEW: begin
              avalid_out = ~pause_addr_submit;
              hold_addr_payload = 1'b0;
              if (aready && !pause_addr_submit)
                  asm_next_state = `AXI_ASM_IDLE;
              else if (!aready && !pause_addr_submit)
                  asm_next_state = `AXI_ASM_KEEP_AVALID;
              else
                  asm_next_state = `AXI_ASM_PAUSE_ADDR;
          end
          `AXI_ASM_ILLEGAL_111, `AXI_ASM_ILLEGAL_110, `AXI_ASM_ILLEGAL_101:
          begin
              avalid_out = begin_axi_burst & ~pause_addr_submit;
              hold_addr_payload = 1'b1;
              asm_next_state = `AXI_ASM_IDLE;
          end
          default: begin
              avalid_out = 1'bx;
              hold_addr_payload = 1'bx;
              asm_next_state = 3'bxxx;
          end
      endcase
  end




  always @ (posedge aclk or negedge aresetn)
  begin : p_axi_wc_state_reg_seq
      if (~aresetn)
          axi_wc_state <= `AXI_WC_IDLE;
      else
          axi_wc_state <= axi_wc_next_state;
  end

  always @ (submit_new_wdata or axi_wc_state or wready or dummy_write)
  begin : p_axi_wc_state_comb
      case (axi_wc_state)
          `AXI_WC_IDLE: begin
              wvalid_out     = submit_new_wdata | dummy_write;
              axi_wbeat_done = submit_new_wdata & ~dummy_write & wready;
              write_mask     = submit_new_wdata & ~dummy_write;
              if (submit_new_wdata && !wready)
                  axi_wc_next_state = `AXI_WC_WAIT_FOR_WREADY;
              else
                  axi_wc_next_state = axi_wc_state;
          end
          `AXI_WC_WAIT_FOR_WREADY: begin
              wvalid_out     = 1'b1;
              axi_wbeat_done = wready & ~dummy_write;
              write_mask     = 1'b1;
              if (wready)
                  axi_wc_next_state = `AXI_WC_IDLE;
              else
                  axi_wc_next_state = axi_wc_state;
          end
          default: begin
              wvalid_out     = 1'bx;
              axi_wbeat_done = 1'bx;
              write_mask     = 1'bx;
              axi_wc_next_state = 1'bx;
          end
      endcase
  end

  always @ (wdata_size or write_mask or wstrb_shift)
  begin : p_write_strb_decode_comb

      if (~write_mask)
          wstrb = 4'b0000;
      else
          case (wdata_size)
              3'b000 : 
                  wstrb = 4'b0001 << wstrb_shift[1:0];
              3'b001 : 
                  wstrb = 4'b0011 << { wstrb_shift[1] , 1'b0 };
              3'b010 : 
                  wstrb = 4'b1111;
              3'b011 : 
                  wstrb = 4'b1111;
              3'b100 : 
                  wstrb = 4'b1111;
              3'b101 : 
                  wstrb = 4'b1111;
              3'b110 : 
                  wstrb = 4'b1111;
              3'b111 : 
                  wstrb = 4'b1111;
              default :
                  wstrb = 4'bxxxx;
          endcase

  end
  assign wvalid = wvalid_out;
  assign wdata  = hwdata & {32{write_mask}};
  assign wlast  = axi_last & (write_mask | dummy_write);


  assign b_done         = dvalid & dready_out & dbnr;
  assign r_done         = dvalid & dready_out & ~dbnr;
  assign w_done         = wvalid_out & wready;
  assign d_err          = dvalid & |dresp;
  assign axi_rbeat_done = r_done & ~ignore_rresp;
  assign axi_err        = ((dbnr & ~ignore_bresp) | (~dbnr & ~ignore_rresp)) &
                          ((d_err));
  assign dready_out     = ((ahb_dready | ignore_bresp) & dbnr) |
                          ((ahb_dready | ignore_rresp) & ~dbnr);
  assign dready         = dready_out;


  assign awhandshake_done = awhandshake_done_reg;
  assign awhandshake_nxt  = (awhandshake_done_reg) ?
                            ~(hreadyout_int & (~axi_in_burst | break_axi_burst))
                            : (addr_done & (asm_state != `AXI_ASM_NEW_PENDING));

  assign awhandshake_reg_en = (hreadyout_int & awhandshake_done_reg &
                              ~axi_in_burst) | addr_done | break_axi_burst;

  always @ (posedge aclk or negedge aresetn)
  begin : p_awhandshake_reg_seq
      if (~aresetn)
          awhandshake_done_reg <= 1'b0;
      else if (awhandshake_reg_en)
          awhandshake_done_reg <= awhandshake_nxt;
  end

  assign whandshake_done   = axi_wbeat_done | whandshake_done_reg;
  assign whandshake_nxt    = (axi_wbeat_done & ~hreadyout_int) |
                             (whandshake_done_reg & ~hreadyout_int);

  assign whandshake_reg_en = (hreadyout_int & whandshake_done_reg) |
                             axi_wbeat_done;

  always @ (posedge aclk or negedge aresetn)
  begin : p_whandshake_reg_seq
      if (~aresetn)
          whandshake_done_reg <= 1'b0;
      else if (whandshake_reg_en)
          whandshake_done_reg <= whandshake_nxt;
  end

  assign bhandshake_done     = (dbnr & dvalid & dready_out & ~ignore_bresp) |
                               bhandshake_done_reg;
  assign bhandshake_nxt      = (dbnr & dvalid & dready_out & ~ignore_bresp &
                                 ~hreadyout_int) |
                               (bhandshake_done_reg & ~hreadyout_int);

  assign bhandshake_reg_en = (hreadyout_int & bhandshake_done_reg) |
                             (dvalid & dready_out & dbnr & ~ignore_bresp);

  always @ (posedge aclk or negedge aresetn)
  begin : p_bhandshake_reg_seq
      if (~aresetn)
      begin
          bhandshake_done_reg <= 1'b0;
      end
      else if (bhandshake_reg_en)
      begin
          bhandshake_done_reg <= bhandshake_nxt;
      end
  end



  assign cnt_en   = cnt_load |
                    ((((r_done & (~d_err | ignore_rresp)) | w_done) |
                     (hresp_out & hreadyout_int & ~axi_burst_wnr))
                     & axi_in_burst);
  assign axi_last = ~|cnt; 

  assign axi_in_burst = (begin_axi_burst | (|cnt) | axi_in_burst_reg) &
                         ~(~|cnt & wvalid_out & wready) &
                         ~(~|cnt & ~dbnr & dready_out & dvalid);
  always @ (posedge aclk or negedge aresetn)
  begin : p_axi_in_burst_seq
      if (~aresetn)
          axi_in_burst_reg <= 1'b0;
      else
          axi_in_burst_reg <= axi_in_burst;
  end

  always @ (posedge aclk or negedge aresetn)
  begin : p_axi_burst_wnr_reg_seq
      if (~aresetn)
          axi_burst_wnr <= 1'b0;
      else if (cnt_en)
          axi_burst_wnr <= wnr_next;
  end

  assign wnr_next = (cnt_load) ? hwrite_int : axi_burst_wnr;

  always @ (posedge aclk or negedge aresetn)
  begin : p_burst_down_counter_seq
      if (~aresetn)
          cnt <= 4'b0000;
      else if (cnt_en)
          cnt <= cnt_next;
  end

  always @ (cnt or cnt_load or axi_burst_len)
  begin : p_burst_down_counter_comb
      if (cnt_load)
          cnt_next = axi_burst_len;
      else
          cnt_next = cnt - 1;
  end


  always @ (posedge aclk or negedge aresetn)
  begin : p_axi_bc_state_reg_seq
      if (~aresetn)
          axi_bc_state <= `AXI_BC_NORMAL;
      else
          axi_bc_state <= axi_bc_next_state;
  end

  always @ (axi_bc_state or begin_axi_burst or break_axi_burst or axi_burst_wnr
            or axi_last or htrans_new or w_done or r_done or b_done or
            bb_awhandshake_done)
  begin : p_axi_bc_state_comb
      case (axi_bc_state)
          `AXI_BC_NORMAL: begin
              cnt_load           = begin_axi_burst;
              broken_burst       = 1'b0;
              ignore_rresp       = 1'b0;
              ignore_bresp       = 1'b0;
              dummy_write        = 1'b0;
              bc_pause_awaddr    = 1'b0;
              bc_pause_araddr    = 1'b0;
              pause_wdata_submit = 1'b0;
              if (break_axi_burst & ~axi_burst_wnr)
                  axi_bc_next_state = `AXI_BC_BROKEN_READ;
              else if (break_axi_burst & axi_burst_wnr)
                  axi_bc_next_state = `AXI_BC_BROKEN_WRITE;
              else
                  axi_bc_next_state = axi_bc_state;
          end
          `AXI_BC_BROKEN_READ: begin
              cnt_load           = (axi_last && r_done &&
                                    (htrans_new != `AHB_TRANS_IDLE))
                                     ? 1'b1 : 1'b0;
              broken_burst       = 1'b1;
              ignore_rresp       = 1'b1;
              ignore_bresp       = 1'b0;
              dummy_write        = 1'b0;
              bc_pause_awaddr    = 1'b1;
              bc_pause_araddr    = 1'b0;
              pause_wdata_submit = 1'b1;
              if (axi_last & r_done)
                  axi_bc_next_state = `AXI_BC_NORMAL;
              else
                  axi_bc_next_state = axi_bc_state;
          end
          `AXI_BC_BROKEN_WRITE: begin
              cnt_load           = (bb_awhandshake_done &&
                                    axi_last && w_done &&
                                    (htrans_new != `AHB_TRANS_IDLE))
                                     ? 1'b1 : 1'b0;
              broken_burst       = 1'b1;
              ignore_rresp       = 1'b0;
              ignore_bresp       = 1'b1;
              dummy_write        = 1'b1;
              bc_pause_awaddr    = 1'b1;
              bc_pause_araddr    = 1'b1;
              pause_wdata_submit = 1'b1;
              if (axi_last & w_done)
                  axi_bc_next_state = `AXI_BC_WAIT_BHANDSHAKE;
              else
                  axi_bc_next_state = axi_bc_state;
          end
          `AXI_BC_WAIT_BHANDSHAKE: begin
              cnt_load           = (bb_awhandshake_done && axi_last &&
                                    (htrans_new != `AHB_TRANS_IDLE))
                                     ? 1'b1 : 1'b0;
              broken_burst       = 1'b1;
              ignore_rresp       = 1'b0;
              ignore_bresp       = 1'b1;
              dummy_write        = 1'b0;
              bc_pause_awaddr    = 1'b1;
              bc_pause_araddr    = 1'b1;
              pause_wdata_submit = 1'b1;
              if (b_done & ~bb_awhandshake_done)
                  axi_bc_next_state = `AXI_BC_WAIT_AHANDSHAKE;
              else if (b_done & bb_awhandshake_done)
                  axi_bc_next_state = `AXI_BC_NORMAL;
              else
                  axi_bc_next_state = axi_bc_state;
          end
          `AXI_BC_WAIT_AHANDSHAKE: begin
              cnt_load           = (bb_awhandshake_done &&
                                    axi_last &&
                                    (htrans_new != `AHB_TRANS_IDLE))
                                     ? 1'b1 : 1'b0;
              broken_burst       = 1'b1;
              ignore_rresp       = 1'b0;
              ignore_bresp       = 1'b0;
              dummy_write        = 1'b0;
              bc_pause_awaddr    = 1'b0;
              bc_pause_araddr    = 1'b0;
              pause_wdata_submit = 1'b0;
              if (bb_awhandshake_done)
                  axi_bc_next_state = `AXI_BC_NORMAL;
              else
                  axi_bc_next_state = axi_bc_state;
          end
          `AXI_BC_ILLEGAL_110,
          `AXI_BC_ILLEGAL_010,
          `AXI_BC_ILLEGAL_101: begin
              cnt_load           = 1'b0;
              broken_burst       = 1'b1;
              ignore_rresp       = 1'b0;
              ignore_bresp       = 1'b0;
              dummy_write        = 1'b0;
              bc_pause_awaddr    = axi_bc_state[0];
              bc_pause_araddr    = axi_bc_state[1];
              pause_wdata_submit = 1'b0;
              axi_bc_next_state  = `AXI_BC_NORMAL;
          end
          default: begin
              cnt_load           = 1'bx;
              broken_burst       = 1'bx;
              ignore_rresp       = 1'bx;
              ignore_bresp       = 1'bx;
              dummy_write        = 1'bx;
              bc_pause_awaddr    = 1'bx;
              bc_pause_araddr    = 1'bx;
              pause_wdata_submit = 1'bx;
              axi_bc_next_state  = 3'bxxx;
          end
      endcase
  end

  assign bb_awhandshake_done   = addr_done | bb_awhandshake_done_reg;
  assign bb_awhandshake_nxt    = addr_done | awhandshake_done;
  assign bb_awhandshake_reg_en = (break_axi_burst & ~broken_burst) | addr_done;

  always @ (posedge aclk or negedge aresetn)
  begin : p_bb_awhandshake_reg_seq
      if (~aresetn)
          bb_awhandshake_done_reg <= 1'b0;
      else if (bb_awhandshake_reg_en)
          bb_awhandshake_done_reg <= bb_awhandshake_nxt;
  end


  assign pause_addr_submit = (awrite_out & bc_pause_awaddr) |
                             (~awrite_out & bc_pause_araddr);


`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  assert_next
    #(`OVL_ERROR,1,1,0,`OVL_ASSERT,
      "Error: Broken AHB Burst Encountered")
      ovl_no_ahb_broken_bursts
      (
        .clk (aclk),
        .reset_n (aresetn),
        .start_event ( hresp != 1'b1),
        .test_expr ( break_axi_burst == 1'b0 )
      );


  assert_one_hot
    #(`OVL_FATAL, 3,`OVL_ASSERT,
      "Error: AHB Response Handling State Machine entered illegal state")
      ovl_ahb_rh_illegal_state
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( ahb_rh_state )
      );


`endif

endmodule

`include "nic400_asib_slave_if1_ahb_undefs_secenc_f1.v"
`include "Axi_undefs.v"
`include "AhbDefns_undefs.v"

