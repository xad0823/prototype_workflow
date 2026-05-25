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



module nic400_ib_xnvm_axi_m_ib_upsize_wr_addr_fmt_sse710_integration_example_f0_flash
  (
    aresetn,
    aclk,


    bdata_data,
    bdata_valid,
    bdata_ready,

    awfmt_valid,
    awfmt_ready,
    awfmt_data,
    

    awid_s,
    awaddr_s,
    awlen_s,
    awsize_s,
    awburst_s,
    awvalid_s,
    awready_s,
    awprot_s,
    awcache_s,
    awlock_s,

    awid_m,
    awaddr_m,
    awlen_m,
    awsize_m,
    awburst_m,
    awvalid_m,
    awready_m,
    awprot_m,
    awcache_m,
    awlock_m          

  );

`include "nic400_ib_xnvm_axi_m_ib_defs_sse710_integration_example_f0_flash.v"
`include "Axi.v"

  input                    aclk;
  input                    aresetn;

  output [12:0]            bdata_data;
  output                   bdata_valid;
  input                    bdata_ready;

  input                    awfmt_ready;
  output                   awfmt_valid;
  output [17:0]            awfmt_data;
  

  input [11:0]             awid_s;            
  input [31:0]             awaddr_s;          
  input [7:0]              awlen_s;           
  input [2:0]              awsize_s;          
  input [1:0]              awburst_s;         
  input [3:0]              awcache_s;         
  input [2:0]              awprot_s;          
  input                    awvalid_s;         
  input                    awlock_s;          
  output                   awready_s;         


  output [11:0]             awid_m;            
  output [31:0]             awaddr_m;          
  output [7:0]              awlen_m;           
  output [2:0]              awsize_m;          
  output [1:0]              awburst_m;         
  output [3:0]              awcache_m;         
  output [2:0]              awprot_m;          
  output                    awlock_m;          
  output                    awvalid_m;         
  input                     awready_m;         

  


 
  reg [31:0]                awaddro;              
  reg [7:0]                 awleno;               
  reg [2:0]                 awsizeo;              
  reg [1:0]                 awbursto;             
  reg [11:0]                awido;                
  reg [3:0]                 awcacheo;             
  reg [2:0]                 awproto;              
  reg                       awlocko;              

  reg                       excl_override_reg;     
  reg                       busy_reg;              
  
  reg [10:0]                 wrap_bytes_remaining_reg; 
  reg [3:0]                 write_mask;            
  
  wire                         n_response;           

  reg [10:0]                 total_bytes;          
  reg [10:0]                 total_bytes_masked;    
  
  reg [2:0]                 wrapsize;             
  reg [2:0]                 wrapfitsize;          
  reg [3:0]                 wraplen;              
  reg [4:0]                 wrapalignmask;         
  
  reg                       wrap_split_reg;
  
  reg [2:0]                 incrsize;

  
  

  wire                      slave_hndshk;
  wire                      master_hndshk;        

  wire                      bypass;               
  
                                            
                                                  
  wire [31:0]               awaddr_aligned;                                                  

  wire [11:0]                total_bytes_ext;      

  wire [10:0]                wrap_boundary_mask;   

  wire                      wrap_aligned;         
  wire                      wrap_is_incr;         
  wire                      wrap_split;           
  wire                      wrap_fits;            
  wire [10:0]                wrap_fits_mask;       
  wire [4:0]                working_addr;         

  wire                      wrap_split_reg_nxt;
  wire                      wrap_split_reg_wr_en;
  wire                      wrap_info_write_en;
  wire [10:0]                next_wrap_bytes_remaining_reg;
  wire [10:0]                addr_less_one;
  
  wire [7:0]                wraplen_i;
  
  wire [7:0]                awlen_1;

  wire [7:0]                incrlen;

  wire [10:0]                bytes_to_transfer;
  wire [18:0]                bytes_to_transfer_large;
  wire [10:0]                bytes_to_transfer_wrap1;

  wire [3:0]                offset_address;       
  wire [7:0]                incrlenmaxsize;       

  

  wire [4:0]                final_address;        
  wire                      overflow;             
  
  wire                      bytes_lt_one_byte;
  wire                      bytes_lt_two_byte;
  wire                      bytes_lt_two_half;
  wire                      bytes_lt_four_half;
  wire                      half_carry;
  wire                      half_carry_double;
  wire                      bytes_lt_four_word;
  wire                      bytes_lt_eight_word;
  wire [2:0]                word_carry;
  wire                      word_carry_double;
  wire                      bytes_lt_eight_dword;
  wire                      bytes_lt_sixt_dword;
  wire [3:0]                dword_carry;
  wire                      dword_carry_double;
  

  wire                      buffers_ok;        
  wire                      new_transaction;   
  wire                      trans_in_progress; 
  wire                      new_trans_avail;   
  wire                      trans_complete;    
  wire                      next_busy_reg;     
  wire                      busy_reg_wr_en;    
  wire                      excl_override;     



  wire [10:0]                bytes_in_transfer;
  wire [10:0]                bytes_in_transfer_aligned;


 assign slave_hndshk = awvalid_s & awready_s;
 assign master_hndshk = awvalid_m & awready_m;

 

 
 
 assign awfmt_data[`AWFIFO_LEN_TB]    = awleno[3:0];
 assign awfmt_data[`AWFIFO_UWRAP]     = wrap_split ;
 assign awfmt_data[`AWFIFO_BYPASS]    = bypass || (awburst_s == `AXI_ABURST_FIXED);
 assign awfmt_data[`AWFIFO_ADDR]      = awaddr_s[3:0];
 assign awfmt_data[`AWFIFO_SIZE]      = awsize_s;
 assign awfmt_data[`AWFIFO_MASK]      = write_mask;
 assign awfmt_data[`AWFIFO_WRAP_FITS] = wrap_fits;

 assign awfmt_valid = new_transaction;

 always @(*)
  begin : p_new_addr_incr_en_w
  
    write_mask = {4{1'b0}};
  
    case (awburst_s)
      `AXI_ABURST_FIXED : write_mask = {4{1'b0}};
      `AXI_ABURST_WRAP  : write_mask = total_bytes[3:0];
      `AXI_ABURST_INCR  : write_mask = {4{1'b1}};
      default           : write_mask = {4{1'bx}};
    endcase
  end 

 



 assign bdata_data = {awid_s, n_response};

 assign bdata_valid = new_transaction;

 
 
 assign n_response = wrap_split;

 



 
 assign buffers_ok = bdata_ready & awfmt_ready;
 

 
 assign  trans_complete = ~((wrap_split & ~wrap_split_reg) );
 

 assign trans_in_progress = new_transaction | busy_reg;

 assign new_transaction = new_trans_avail & buffers_ok;

 assign new_trans_avail = awvalid_s & ~busy_reg;

 assign next_busy_reg = (trans_complete & slave_hndshk)  ? 1'b0 :
                        ((new_transaction & ~slave_hndshk) ? 1'b1 : busy_reg);

 assign busy_reg_wr_en = busy_reg ^ next_busy_reg;

 always @(posedge aclk or negedge aresetn)
   begin : busy_reg_p
      if (!aresetn) begin
          busy_reg <= 1'b0;
      end else if (busy_reg_wr_en) begin
          busy_reg <= next_busy_reg;
      end
    end



 assign excl_override = (new_transaction) ? n_response | (|awleno[7:4]) : excl_override_reg;

 always @(posedge aclk or negedge aresetn)
   begin : excl_override_reg_p
      if (!aresetn) begin
          excl_override_reg <= 1'b0;
      end else if (new_transaction) begin
          excl_override_reg <= excl_override;
      end
    end




 assign awid_m =     awido;
 assign awcache_m =  awcacheo;
 assign awprot_m =   awproto;
 assign awlen_m =    awleno;
 assign awsize_m =   awsizeo;
 assign awaddr_m =   awaddro;
 assign awburst_m =  awbursto;
 assign awlock_m =   awlocko;

 assign awvalid_m = awvalid_s && trans_in_progress;

 assign awready_s = master_hndshk && trans_complete;

 always @(*) begin

      awleno = incrlen;
      awsizeo = incrsize;
      awbursto = `AXI_ABURST_INCR;
      awido = awid_s;
      awcacheo = awcache_s;
      awproto = awprot_s;
      awaddro = awaddr_aligned;
      
      awlocko = (awlock_s && (~excl_override));
      


      if (!wrap_split_reg) begin

         awaddro = awaddr_s;
         if (wrap_aligned) begin
            awleno = wraplen_i;
            awsizeo = wrapsize;
            awbursto = `AXI_ABURST_WRAP;
         end else if (bypass) begin
            awleno = awlen_s;
            awsizeo = awsize_s;
            awbursto = awburst_s;
         end else if (wrap_fits) begin
            awaddro = awaddr_aligned;
            awleno = awlen_1;
            awsizeo = wrapfitsize;
            awbursto = `AXI_ABURST_INCR;
         end
      end
  end

  
 assign wraplen_i = {4'b0000,wraplen};
 assign awlen_1 = {4'b0000,`AXI_ALEN_1};

 assign addr_less_one = awaddr_s[10:0] - {{10{1'b0}},1'b1};
 
 assign next_wrap_bytes_remaining_reg = (addr_less_one & total_bytes);

 assign wrap_info_write_en = wrap_split & master_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wrap_bytes_remaining_reg_p
      if (!aresetn) begin
          wrap_bytes_remaining_reg <= 11'b0;
      end else if (wrap_info_write_en) begin
          wrap_bytes_remaining_reg <= next_wrap_bytes_remaining_reg;
      end
    end

 assign awaddr_aligned = {awaddr_s[31:11],((awaddr_s[10:0]) & (~total_bytes))};


 assign wrap_split_reg_nxt = wrap_split & ~(wrap_split_reg);

 assign wrap_split_reg_wr_en = master_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wrap_split_p
      if (!aresetn)
          wrap_split_reg <= 1'b0;
      else if (wrap_split_reg_wr_en)
          wrap_split_reg <= wrap_split_reg_nxt;
    end



  
 
 
 assign bypass = (awburst_s == `AXI_ABURST_FIXED ) || ~awcache_s[1] || (awlen_s == `AXI_ALEN_1);
 

 always @(*)
  begin : total_bytes_p
    case (awsize_s)
       `AXI_ASIZE_8    : total_bytes = {3'b0, awlen_s};
       `AXI_ASIZE_16   : total_bytes = {2'b0, awlen_s, 1'b1};
       `AXI_ASIZE_32   : total_bytes = {1'b0, awlen_s, 2'b11};
       `AXI_ASIZE_64   : total_bytes = {awlen_s, 3'b111};
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes = {3'b0, awlen_s};    
       default         : total_bytes = {11'bx};
    endcase
  end


 assign total_bytes_ext = {1'b0,total_bytes};

 always @(*)
  begin : wrap_size_len
   if (total_bytes_ext[4]) begin
            wrapfitsize = `AXI_ASIZE_256;
            wrapsize = `AXI_ASIZE_128;
            wraplen = total_bytes_ext[7:4];
            wrapalignmask = {1'b0, 4'b1111};
  end else if (total_bytes_ext[3]) begin
            wrapfitsize = `AXI_ASIZE_128;
            wrapsize = `AXI_ASIZE_64;
            wraplen = total_bytes_ext[6:3];
            wrapalignmask = {2'b0, 3'b111};
  end else if (total_bytes_ext[2]) begin
            wrapfitsize = `AXI_ASIZE_64;
            wrapsize = `AXI_ASIZE_32;
            wraplen = total_bytes_ext[5:2];
            wrapalignmask = {3'b0, 2'b11};
  end else if (total_bytes_ext[1]) begin
            wrapfitsize = `AXI_ASIZE_32;
            wrapsize = `AXI_ASIZE_16;
            wraplen = total_bytes_ext[4:1];
            wrapalignmask = {4'b0, 1'b1};
  end else if (total_bytes_ext[0])begin
            wrapfitsize = `AXI_ASIZE_16;
            wrapsize = `AXI_ASIZE_8;
            wraplen = total_bytes_ext[3:0];
            wrapalignmask = 5'b0;
  end else begin
            wrapfitsize = 3'bx;
            wrapsize = 3'bx;
            wraplen = 4'bx;
            wrapalignmask = 5'bx;
        end
  end

 assign working_addr = awaddr_s[4:0] & wrapalignmask;

 assign wrap_fits_mask = {{7{1'b1}}, 4'b0000};
 

 assign  wrap_fits = ~|(total_bytes & wrap_fits_mask) & (awburst_s == `AXI_ABURST_WRAP);
 assign  wrap_is_incr = ~|(awaddr_s[10:0] & total_bytes);
 assign  wrap_aligned = ~|working_addr & (awburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_is_incr & ~wrap_fits ;
 assign  wrap_split = ((|working_addr)) & (awburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_fits;

 


 assign wrap_boundary_mask = total_bytes;



 assign bytes_to_transfer_wrap1 = ~(awaddr_s[10:0]) & wrap_boundary_mask;

 assign bytes_to_transfer = (wrap_split_reg) ? wrap_bytes_remaining_reg
                            : ((awburst_s == `AXI_ABURST_WRAP) ? bytes_to_transfer_wrap1
                            : total_bytes_masked);

 

 always @(*)
  begin : total_bytes_masked_p
    case (awsize_s)
       `AXI_ASIZE_8    : total_bytes_masked = {3'b0, awlen_s};
       `AXI_ASIZE_16   : total_bytes_masked = {2'b0, awlen_s, ~awaddr_s[0]};
       `AXI_ASIZE_32   : total_bytes_masked = {1'b0, awlen_s, ~awaddr_s[1:0]};
       `AXI_ASIZE_64   : total_bytes_masked = {awlen_s, ~awaddr_s[2:0]};
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes_masked = {3'b0, awlen_s};    
       default         : total_bytes_masked = {11{1'bx}};
    endcase
 end

 

 assign offset_address = (wrap_split_reg) ? awaddr_aligned[3:0] : 
                            awaddr_s[3:0];

 assign  half_carry =  bytes_to_transfer[0] & offset_address[0];
 assign  half_carry_double = half_carry & bytes_to_transfer[1];
 assign  word_carry =  {1'b0, bytes_to_transfer[1:0]} + {1'b0, offset_address[1:0]};
 assign  word_carry_double = word_carry[2] & bytes_to_transfer[2];
 assign  dword_carry =  {1'b0, bytes_to_transfer[2:0]} + {1'b0, offset_address[2:0]};
 assign  dword_carry_double = dword_carry[3] & bytes_to_transfer[3];
 

 assign  bytes_lt_one_byte   = ~|bytes_to_transfer;
 assign  bytes_lt_two_byte   = ~|bytes_to_transfer[10:1];
 assign  bytes_lt_two_half   = ~|bytes_to_transfer[10:1] & ~half_carry;
 assign  bytes_lt_four_half  = ~|bytes_to_transfer[10:2] & ~half_carry_double;
 assign  bytes_lt_four_word  = ~|bytes_to_transfer[10:2] & ~word_carry[2];
 assign  bytes_lt_eight_word = ~|bytes_to_transfer[10:3] & ~word_carry_double;
 assign  bytes_lt_eight_dword  = ~|bytes_to_transfer[10:3] & ~dword_carry[3];
 assign  bytes_lt_sixt_dword = ~|bytes_to_transfer[10:4] & ~dword_carry_double;
 

 always @(*)
  begin : size_lookup

        incrsize = `AXI_ASIZE_128;

        if (bytes_lt_one_byte || (bytes_lt_two_byte && (offset_address[3:0] == {4{1'b1}}))) begin
            incrsize = `AXI_ASIZE_8;
        end else if (bytes_lt_two_half || (bytes_lt_four_half && (offset_address[3:1] == {3{1'b1}}))) begin
            incrsize = `AXI_ASIZE_16;
        end else if (bytes_lt_four_word || (bytes_lt_eight_word && (offset_address[3:2] == {2{1'b1}}))) begin
            incrsize = `AXI_ASIZE_32;
        end else if (bytes_lt_eight_dword || (bytes_lt_sixt_dword && (offset_address[3:3] == {1{1'b1}}))) begin
            incrsize = `AXI_ASIZE_64;
        end 

  end

  assign final_address = {1'b0, offset_address} + {1'b0, bytes_to_transfer_large[3:0]};
  assign overflow =  final_address[4];

  assign bytes_to_transfer_large = {8'b00000000, bytes_to_transfer};

  

  assign incrlenmaxsize =  bytes_to_transfer_large[11:4] + 4'b1;
  assign incrlen = (overflow) ? incrlenmaxsize : bytes_to_transfer_large[11:4];

  

`ifdef ARM_ASSERT_ON


  assert_never #(0,0,"ERROR, Transaction incoming that has awsize too large for incoming bus")
      ovl_max_input_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_s && (awsize_s > 3))
       );

  assert_never #(0,0,"ERROR, Transaction issued that is too large for outgoing bus")
      ovl_max_output_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_m && (awsize_m > 4))
       );

  assert_never #(0,0,"ERROR, Inefficient transaction issued when not in bypass")
      ovl_inefficient_size_len_com
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_m && (!bypass) && (awlen_m > 4'b1)
                    && (awsize_m != 4)
                    && (awburst_m != 2'b0))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been touched")
      ovl_illegal_trans_mod
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_m && (!awcache_s[1]) && (awsize_s <= 4)
                    && (awsize_s != awsize_m) && (awlen_s != awlen_m))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been created")
      ovl_illegal_trans_create
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_m && (!awvalid_s))
       );

 assert_never #(0,0,"ERROR, Unaligned incoming wrap")
      ovl_illegal_incoming_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_s && (awburst_s == `AXI_ABURST_WRAP) &&
                    !((awsize_s == `AXI_ASIZE_8) ||
                      (awsize_s == `AXI_ASIZE_16  && awaddr_s[0]   == 1'b0) ||
                      (awsize_s == `AXI_ASIZE_32  && awaddr_s[1:0] == 2'b0) ||
                      (awsize_s == `AXI_ASIZE_64  && awaddr_s[2:0] == 3'b0) ||
                      (awsize_s == `AXI_ASIZE_128 && awaddr_s[3:0] == 4'b0) ||
                      (awsize_s == `AXI_ASIZE_256 && awaddr_s[4:0] == 5'b0)))
       );

 assert_never #(0,0,"ERROR, Unaligned outgoing wrap")
      ovl_illegal_outgoing_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (awvalid_m && (awburst_m == `AXI_ABURST_WRAP) &&
                   !((awsize_m == `AXI_ASIZE_8) ||
                     (awsize_m == `AXI_ASIZE_16  && awaddr_m[0]   == 1'b0) ||
                     (awsize_m == `AXI_ASIZE_32  && awaddr_m[1:0] == 2'b0) ||
                     (awsize_m == `AXI_ASIZE_64  && awaddr_m[2:0] == 3'b0) ||
                     (awsize_m == `AXI_ASIZE_128 && awaddr_m[3:0] == 4'b0) ||
                     (awsize_m == `AXI_ASIZE_256 && awaddr_m[4:0] == 5'b0)))
       );

 reg awvalid_m_prev;
 reg awvalid_s_prev;
 reg awready_m_prev;
 reg awready_s_prev;
 reg in_trans;
 reg [0:0]  n_response_count;

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           awvalid_m_prev <= 1'b0;
           awvalid_s_prev <= 1'b0;
           awready_m_prev <= 1'b0;
           awready_s_prev <= 1'b0;
        end else begin
           awvalid_m_prev <= awvalid_m;
           awvalid_s_prev <= awvalid_s;
           awready_m_prev <= awready_m;
           awready_s_prev <= awready_s;
        end
    end

 always @(posedge aclk or negedge aresetn)
    begin
       if (!aresetn) begin
           in_trans <= 1'b0;
       end else if (awvalid_m && awready_m) begin
           in_trans <= awvalid_s && (!awready_s);
       end
    end

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           n_response_count <= 1'b0;
        end else if (awvalid_m && awready_m && (!in_trans) && |n_response) begin
           n_response_count <= {1'b0, n_response};
        end else if (awvalid_m && awready_m && |n_response_count) begin
           n_response_count <= n_response_count - 1'b1;
        end
    end

 assert_never #(0,0,"ERROR, Exclusive transaction has been split")
   ovl_split_exclusive
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (awvalid_m && (!awvalid_s)
                  && awlock_m == `AXI_ALOCK_EXCL)
     );

 assert_implication #(0,0,"ERROR, Transaction has lost lock")
   ovl_lost_lock
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (awvalid_s && awvalid_m &&
                        awlock_s == `AXI_ALOCK_LOCKED),
      .consequent_expr (awlock_m == `AXI_ALOCK_LOCKED)
     );

 assert_never #(0,0,"ERROR, Sticky output valid")
   ovl_sticky_valid_m
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (awvalid_m_prev && (!awvalid_m)
                  && (!awready_m_prev))
     );

 assert_never #(0,0,"ERROR, Sticky input valid")
   ovl_sticky_valid_s
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (awvalid_s_prev && (!awvalid_s)
                  && (!awready_s_prev))
     );

 
 assert_never #(0,0,"ERROR, Illegal Bchannel Hndshake value")
   ovl_illegal_b_hndshk
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (bdata_valid && (!bdata_ready))
     );

 assert_never #(0,0,"ERROR, Illegal Push to Bchannel")
   ovl_illegal_b_push
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (in_trans && bdata_valid)
     );

 assert_implication #(0,0,"ERROR, Illegal transaction count")
   ovl_illegal_trans_count
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (awvalid_s && awready_s),
      .consequent_expr (awvalid_m && awready_m &&
                       (((!in_trans) && (~|n_response)) || (in_trans && n_response_count == 1'b1)))
     );

`endif


endmodule

`include "nic400_ib_xnvm_axi_m_ib_undefs_sse710_integration_example_f0_flash.v"
`include "Axi_undefs.v"


