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



module nic400_ib_dbg_axim_ib_upsize_rd_addr_fmt_sse710_dbg3s1m
  (
    aresetn,
    aclk,


    ardata_valid,
    ardata_ready,
    ardata_data,
    

    arid_s,
    araddr_s,
    arlen_s,
    arsize_s,
    arburst_s,
    arvalid_s,
    arready_s,
    arprot_s,
    arcache_s,
    aruser_s,
    arlock_s,

    arid_m,
    araddr_m,
    arlen_m,
    arsize_m,
    arburst_m,
    arvalid_m,
    arready_m,
    arprot_m,
    arcache_m,
    aruser_m,
    arlock_m          

  );

`include "nic400_ib_dbg_axim_ib_defs_sse710_dbg3s1m.v"
`include "Axi.v"

  input                    aclk;
  input                    aresetn;
  input                    ardata_ready;
  output                   ardata_valid;
  output [18:0]            ardata_data;
  

  input [3:0]              arid_s;            
  input [31:0]             araddr_s;          
  input [7:0]              arlen_s;           
  input [2:0]              arsize_s;          
  input [1:0]              arburst_s;         
  input [3:0]              arcache_s;         
  input [2:0]              arprot_s;          
  input                    arvalid_s;         
  input                    arlock_s;          
  input [2:0]              aruser_s;          
  output                   arready_s;         


  output [3:0]              arid_m;            
  output [31:0]             araddr_m;          
  output [7:0]              arlen_m;           
  output [2:0]              arsize_m;          
  output [1:0]              arburst_m;         
  output [3:0]              arcache_m;         
  output [2:0]              arprot_m;          
  output                    arlock_m;          
  output [2:0]              aruser_m;          
  output                    arvalid_m;         
  input                     arready_m;         

  


 
  reg [31:0]                araddro;              
  reg [7:0]                 arleno;               
  reg [2:0]                 arsizeo;              
  reg [1:0]                 arbursto;             
  reg [3:0]                 arido;                
  reg [3:0]                 arcacheo;             
  reg [2:0]                 arproto;              
  reg [2:0]                 arusero;              
  reg                       arlocko;              

  reg                       excl_override_reg;     
  reg                       busy_reg;              
  
  reg [9:0]                 wrap_bytes_remaining_reg; 
  reg [2:0]                 align_mask;           
  reg [2:0]                 read_mask;            
  wire                         n_response;           

  reg [9:0]                 total_bytes;          
  reg [9:0]                 total_bytes_masked;    
  
  reg [2:0]                 wrapsize;             
  reg [2:0]                 wrapfitsize;          
  reg [3:0]                 wraplen;              
  reg [3:0]                 wrapalignmask;         
  
  reg                       wrap_split_reg;
  
  reg [2:0]                 incrsize;

  
  

  wire                      slave_hndshk;
  wire                      master_hndshk;        

  wire                      bypass;               
  
                                            
                                                  
  wire [31:0]               araddr_aligned;                                                  

  wire [10:0]                total_bytes_ext;      

  wire [9:0]                wrap_boundary_mask;   

  wire                      wrap_aligned;         
  wire                      wrap_is_incr;         
  wire                      wrap_split;           
  wire                      wrap_fits;            
  wire [9:0]                wrap_fits_mask;       
  wire [3:0]                working_addr;         

  wire                      wrap_split_reg_nxt;
  wire                      wrap_split_reg_wr_en;
  wire                      wrap_info_write_en;
  wire [9:0]                next_wrap_bytes_remaining_reg;
  wire [9:0]                addr_less_one;
  
  wire [7:0]                wraplen_i;
  
  wire [7:0]                arlen_1;

  wire [7:0]                incrlen;

  wire [9:0]                bytes_to_transfer;
  wire [17:0]                bytes_to_transfer_large;
  wire [9:0]                bytes_to_transfer_wrap1;

  wire [2:0]                offset_address;       
  wire [7:0]                incrlenmaxsize;       

  

  wire [3:0]                final_address;        
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
  

  wire                      buffers_ok;        
  wire                      new_transaction;   
  wire                      trans_in_progress; 
  wire                      new_trans_avail;   
  wire                      trans_complete;    
  wire                      next_busy_reg;     
  wire                      busy_reg_wr_en;    
  wire                      excl_override;     



  wire [9:0]                bytes_in_transfer;
  wire [9:0]                bytes_in_transfer_aligned;


 assign slave_hndshk = arvalid_s & arready_s;
 assign master_hndshk = arvalid_m & arready_m;

 
 assign ardata_data[`ARDATA_SIZE] = arsize_s;
 assign ardata_data[`ARDATA_TWO] = n_response;
 assign ardata_data[`ARDATA_BYPASS] = bypass;
 assign ardata_data[`ARDATA_ADDR] = araddr_s[2:0] & align_mask;
 assign ardata_data[`ARDATA_MASK] = read_mask;
 assign ardata_data[`ARDATA_END] = ((arburst_s == `AXI_ABURST_WRAP) & ~wrap_is_incr) ? addr_less_one[2:0] & align_mask : final_address[2:0] & align_mask;
 assign ardata_data[`ARDATA_ID] = arid_s;
 assign ardata_data[`ARDATA_WRAP_FITS] = wrap_fits;

 

 assign ardata_valid = new_transaction;
 

 always @(*)
  begin : p_new_addr_incr_en_r
  
    read_mask = {3{1'b0}};
  
    case (arburst_s)
      `AXI_ABURST_FIXED : read_mask = {3{1'b0}};
      `AXI_ABURST_WRAP  : read_mask = total_bytes[2:0];
      `AXI_ABURST_INCR  : read_mask = {3{1'b1}};
      default           : read_mask = {3{1'bx}};
    endcase
  end 


 
 assign n_response = wrap_split;

 



 
 assign buffers_ok = ardata_ready;

 
 assign  trans_complete = ~((wrap_split & ~wrap_split_reg) );
 

 assign trans_in_progress = new_transaction | busy_reg;

 assign new_transaction = new_trans_avail & buffers_ok;

 assign new_trans_avail = arvalid_s & ~busy_reg;

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



 assign excl_override = (new_transaction) ? n_response | (|arleno[7:4]) : excl_override_reg;

 always @(posedge aclk or negedge aresetn)
   begin : excl_override_reg_p
      if (!aresetn) begin
          excl_override_reg <= 1'b0;
      end else if (new_transaction) begin
          excl_override_reg <= excl_override;
      end
    end




 assign arid_m =     arido;
 assign arcache_m =  arcacheo;
 assign arprot_m =   arproto;
 assign aruser_m =   arusero;
 assign arlen_m =    arleno;
 assign arsize_m =   arsizeo;
 assign araddr_m =   araddro;
 assign arburst_m =  arbursto;
 assign arlock_m =   arlocko;

 assign arvalid_m = arvalid_s && trans_in_progress;

 assign arready_s = master_hndshk && trans_complete;

 always @(*) begin

      arleno = incrlen;
      arsizeo = incrsize;
      arbursto = `AXI_ABURST_INCR;
      arido = arid_s;
      arcacheo = arcache_s;
      arproto = arprot_s;
      arusero = aruser_s;
      araddro = araddr_aligned;
      
      arlocko = (arlock_s && (~excl_override));
      


      if (!wrap_split_reg) begin

         araddro = araddr_s;
         if (wrap_aligned) begin
            arleno = wraplen_i;
            arsizeo = wrapsize;
            arbursto = `AXI_ABURST_WRAP;
         end else if (bypass) begin
            arleno = arlen_s;
            arsizeo = arsize_s;
            arbursto = arburst_s;
         end else if (wrap_fits) begin
            araddro = araddr_aligned;
            arleno = arlen_1;
            arsizeo = wrapfitsize;
            arbursto = `AXI_ABURST_INCR;
         end
      end
  end

  
 assign wraplen_i = {4'b0000,wraplen};
 assign arlen_1 = {4'b0000,`AXI_ALEN_1};

 assign addr_less_one = araddr_s[9:0] - {{9{1'b0}},1'b1};
 
 assign next_wrap_bytes_remaining_reg = (addr_less_one & total_bytes);

 assign wrap_info_write_en = wrap_split & master_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wrap_bytes_remaining_reg_p
      if (!aresetn) begin
          wrap_bytes_remaining_reg <= 10'b0;
      end else if (wrap_info_write_en) begin
          wrap_bytes_remaining_reg <= next_wrap_bytes_remaining_reg;
      end
    end

 assign araddr_aligned = {araddr_s[31:10],((araddr_s[9:0]) & (~total_bytes))};


 assign wrap_split_reg_nxt = wrap_split & ~(wrap_split_reg);

 assign wrap_split_reg_wr_en = master_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wrap_split_p
      if (!aresetn)
          wrap_split_reg <= 1'b0;
      else if (wrap_split_reg_wr_en)
          wrap_split_reg <= wrap_split_reg_nxt;
    end



  
 
 
 assign bypass = (arburst_s == `AXI_ABURST_FIXED ) || ~arcache_s[1] || (arlen_s == `AXI_ALEN_1);
 

 always @(*)
  begin : total_bytes_p
    case (arsize_s)
       `AXI_ASIZE_8    : total_bytes = {2'b0, arlen_s};
       `AXI_ASIZE_16   : total_bytes = {1'b0, arlen_s, 1'b1};
       `AXI_ASIZE_32   : total_bytes = {arlen_s, 2'b11};
       `AXI_ASIZE_64,
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes = {2'b0, arlen_s};    
       default         : total_bytes = {10'bx};
    endcase
  end


 assign total_bytes_ext = {1'b0,total_bytes};

 always @(*)
  begin : wrap_size_len
   if (total_bytes_ext[3]) begin
            wrapfitsize = `AXI_ASIZE_128;
            wrapsize = `AXI_ASIZE_64;
            wraplen = total_bytes_ext[6:3];
            wrapalignmask = {1'b0, 3'b111};
  end else if (total_bytes_ext[2]) begin
            wrapfitsize = `AXI_ASIZE_64;
            wrapsize = `AXI_ASIZE_32;
            wraplen = total_bytes_ext[5:2];
            wrapalignmask = {2'b0, 2'b11};
  end else if (total_bytes_ext[1]) begin
            wrapfitsize = `AXI_ASIZE_32;
            wrapsize = `AXI_ASIZE_16;
            wraplen = total_bytes_ext[4:1];
            wrapalignmask = {3'b0, 1'b1};
  end else if (total_bytes_ext[0])begin
            wrapfitsize = `AXI_ASIZE_16;
            wrapsize = `AXI_ASIZE_8;
            wraplen = total_bytes_ext[3:0];
            wrapalignmask = 4'b0;
  end else begin
            wrapfitsize = 3'bx;
            wrapsize = 3'bx;
            wraplen = 4'bx;
            wrapalignmask = 4'bx;
        end
  end

 assign working_addr = araddr_s[3:0] & wrapalignmask;

 assign wrap_fits_mask = {{7{1'b1}}, 3'b000};
 

 assign  wrap_fits = ~|(total_bytes & wrap_fits_mask) & (arburst_s == `AXI_ABURST_WRAP);
 assign  wrap_is_incr = ~|(araddr_s[9:0] & total_bytes);
 assign  wrap_aligned = ~|working_addr & (arburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_is_incr & ~wrap_fits ;
 assign  wrap_split = ((|working_addr)) & (arburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_fits;

 


 assign wrap_boundary_mask = total_bytes;



 assign bytes_to_transfer_wrap1 = ~(araddr_s[9:0]) & wrap_boundary_mask;

 assign bytes_to_transfer = (wrap_split_reg) ? wrap_bytes_remaining_reg
                            : ((arburst_s == `AXI_ABURST_WRAP) ? bytes_to_transfer_wrap1
                            : total_bytes_masked);

 

 always @(*)
  begin : total_bytes_masked_p
    case (arsize_s)
       `AXI_ASIZE_8    : total_bytes_masked = {2'b0, arlen_s};
       `AXI_ASIZE_16   : total_bytes_masked = {1'b0, arlen_s, ~araddr_s[0]};
       `AXI_ASIZE_32   : total_bytes_masked = {arlen_s, ~araddr_s[1:0]};
       `AXI_ASIZE_64,
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes_masked = {2'b0, arlen_s};    
       default         : total_bytes_masked = {10{1'bx}};
    endcase
 end

 

 always @(*)
  begin : align_mask_p
    case (arsize_s)
       `AXI_ASIZE_8    : align_mask = {3{1'b1}};
       `AXI_ASIZE_16   : align_mask = {{2{1'b1}}, 1'b0};
       `AXI_ASIZE_32   : align_mask = {{1{1'b1}}, 2'b0};
       `AXI_ASIZE_64,
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : align_mask = {3{1'b1}};    
       default         : align_mask = {3{1'bx}};
    endcase
  end
  

 assign offset_address = (wrap_split_reg) ? araddr_aligned[2:0] : 
                            araddr_s[2:0];

 assign  half_carry =  bytes_to_transfer[0] & offset_address[0];
 assign  half_carry_double = half_carry & bytes_to_transfer[1];
 assign  word_carry =  {1'b0, bytes_to_transfer[1:0]} + {1'b0, offset_address[1:0]};
 assign  word_carry_double = word_carry[2] & bytes_to_transfer[2];
 

 assign  bytes_lt_one_byte   = ~|bytes_to_transfer;
 assign  bytes_lt_two_byte   = ~|bytes_to_transfer[9:1];
 assign  bytes_lt_two_half   = ~|bytes_to_transfer[9:1] & ~half_carry;
 assign  bytes_lt_four_half  = ~|bytes_to_transfer[9:2] & ~half_carry_double;
 assign  bytes_lt_four_word  = ~|bytes_to_transfer[9:2] & ~word_carry[2];
 assign  bytes_lt_eight_word = ~|bytes_to_transfer[9:3] & ~word_carry_double;
 

 always @(*)
  begin : size_lookup

        incrsize = `AXI_ASIZE_64;

        if (bytes_lt_one_byte || (bytes_lt_two_byte && (offset_address[2:0] == {3{1'b1}}))) begin
            incrsize = `AXI_ASIZE_8;
        end else if (bytes_lt_two_half || (bytes_lt_four_half && (offset_address[2:1] == {2{1'b1}}))) begin
            incrsize = `AXI_ASIZE_16;
        end else if (bytes_lt_four_word || (bytes_lt_eight_word && (offset_address[2:2] == {1{1'b1}}))) begin
            incrsize = `AXI_ASIZE_32;
        end 

  end

  assign final_address = {1'b0, offset_address} + {1'b0, bytes_to_transfer_large[2:0]};
  assign overflow =  final_address[3];

  assign bytes_to_transfer_large = {8'b00000000, bytes_to_transfer};

  

  assign incrlenmaxsize =  bytes_to_transfer_large[10:3] + 4'b1;
  assign incrlen = (overflow) ? incrlenmaxsize : bytes_to_transfer_large[10:3];

  

`ifdef ARM_ASSERT_ON


  assert_never #(0,0,"ERROR, Transaction incoming that has arsize too large for incoming bus")
      ovl_max_input_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_s && (arsize_s > 2))
       );

  assert_never #(0,0,"ERROR, Transaction issued that is too large for outgoing bus")
      ovl_max_output_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_m && (arsize_m > 3))
       );

  assert_never #(0,0,"ERROR, Inefficient transaction issued when not in bypass")
      ovl_inefficient_size_len_com
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_m && (!bypass) && (arlen_m > 4'b1)
                    && (arsize_m != 3)
                    && (arburst_m != 2'b0))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been touched")
      ovl_illegal_trans_mod
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_m && (!arcache_s[1]) && (arsize_s <= 3)
                    && (arsize_s != arsize_m) && (arlen_s != arlen_m))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been created")
      ovl_illegal_trans_create
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_m && (!arvalid_s))
       );

 assert_never #(0,0,"ERROR, Unaligned incoming wrap")
      ovl_illegal_incoming_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_s && (arburst_s == `AXI_ABURST_WRAP) &&
                    !((arsize_s == `AXI_ASIZE_8) ||
                      (arsize_s == `AXI_ASIZE_16  && araddr_s[0]   == 1'b0) ||
                      (arsize_s == `AXI_ASIZE_32  && araddr_s[1:0] == 2'b0) ||
                      (arsize_s == `AXI_ASIZE_64  && araddr_s[2:0] == 3'b0) ||
                      (arsize_s == `AXI_ASIZE_128 && araddr_s[3:0] == 4'b0) ||
                      (arsize_s == `AXI_ASIZE_256 && araddr_s[4:0] == 5'b0)))
       );

 assert_never #(0,0,"ERROR, Unaligned outgoing wrap")
      ovl_illegal_outgoing_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (arvalid_m && (arburst_m == `AXI_ABURST_WRAP) &&
                   !((arsize_m == `AXI_ASIZE_8) ||
                     (arsize_m == `AXI_ASIZE_16  && araddr_m[0]   == 1'b0) ||
                     (arsize_m == `AXI_ASIZE_32  && araddr_m[1:0] == 2'b0) ||
                     (arsize_m == `AXI_ASIZE_64  && araddr_m[2:0] == 3'b0) ||
                     (arsize_m == `AXI_ASIZE_128 && araddr_m[3:0] == 4'b0) ||
                     (arsize_m == `AXI_ASIZE_256 && araddr_m[4:0] == 5'b0)))
       );

 reg arvalid_m_prev;
 reg arvalid_s_prev;
 reg arready_m_prev;
 reg arready_s_prev;
 reg in_trans;
 reg [0:0]  n_response_count;

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           arvalid_m_prev <= 1'b0;
           arvalid_s_prev <= 1'b0;
           arready_m_prev <= 1'b0;
           arready_s_prev <= 1'b0;
        end else begin
           arvalid_m_prev <= arvalid_m;
           arvalid_s_prev <= arvalid_s;
           arready_m_prev <= arready_m;
           arready_s_prev <= arready_s;
        end
    end

 always @(posedge aclk or negedge aresetn)
    begin
       if (!aresetn) begin
           in_trans <= 1'b0;
       end else if (arvalid_m && arready_m) begin
           in_trans <= arvalid_s && (!arready_s);
       end
    end

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           n_response_count <= 1'b0;
        end else if (arvalid_m && arready_m && (!in_trans) && |n_response) begin
           n_response_count <= {1'b0, n_response};
        end else if (arvalid_m && arready_m && |n_response_count) begin
           n_response_count <= n_response_count - 1'b1;
        end
    end

 assert_never #(0,0,"ERROR, Exclusive transaction has been split")
   ovl_split_exclusive
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (arvalid_m && (!arvalid_s)
                  && arlock_m == `AXI_ALOCK_EXCL)
     );

 assert_implication #(0,0,"ERROR, Transaction has lost lock")
   ovl_lost_lock
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (arvalid_s && arvalid_m &&
                        arlock_s == `AXI_ALOCK_LOCKED),
      .consequent_expr (arlock_m == `AXI_ALOCK_LOCKED)
     );

 assert_never #(0,0,"ERROR, Sticky output valid")
   ovl_sticky_valid_m
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (arvalid_m_prev && (!arvalid_m)
                  && (!arready_m_prev))
     );

 assert_never #(0,0,"ERROR, Sticky input valid")
   ovl_sticky_valid_s
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (arvalid_s_prev && (!arvalid_s)
                  && (!arready_s_prev))
     );

 
 assert_never #(0,0,"ERROR, Illegal Rchannel Hndshake value")
   ovl_illegal_r_hndshk
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (ardata_valid && (!ardata_ready))
     );

 assert_never #(0,0,"ERROR, Illegal Push to Bchannel")
   ovl_illegal_r_push
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (in_trans && ardata_valid)
     );

 assert_implication #(0,0,"ERROR, Illegal transaction count")
   ovl_illegal_trans_count
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (arvalid_s && arready_s),
      .consequent_expr (arvalid_m && arready_m &&
                       (((!in_trans) && (~|n_response)) || (in_trans && n_response_count == 1'b1)))
     );

`endif


endmodule

`include "nic400_ib_dbg_axim_ib_undefs_sse710_dbg3s1m.v"
`include "Axi_undefs.v"



