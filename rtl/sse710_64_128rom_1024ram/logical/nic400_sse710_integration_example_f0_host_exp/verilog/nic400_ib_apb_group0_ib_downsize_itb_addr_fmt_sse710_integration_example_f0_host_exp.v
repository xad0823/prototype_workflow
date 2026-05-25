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


module nic400_ib_apb_group0_ib_downsize_itb_addr_fmt_sse710_integration_example_f0_host_exp
  (
    aresetn,
    aclk,


    bdata_data,
    bdata_valid,
    bdata_ready,

    awfmt_valid,
    awfmt_ready,
    awfmt_data,
    

    awrite_s,
    aid_s,
    aaddr_s,
    alen_s,
    asize_s,
    aburst_s,
    avalid_s,
    aready_s,
    aprot_s,
    acache_s,
    alock_s,

    aid_m,
    aaddr_m,
    alen_m,
    asize_m,
    aburst_m,
    avalid_m,
    aready_m,
    aprot_m,
    acache_m,
    alock_m,
    arfmt_data,
    downsize_m          

  );

`include "nic400_ib_apb_group0_ib_defs_sse710_integration_example_f0_host_exp.v"
`include "Axi.v"

  input                    aclk;
  input                    aresetn;

  output [21:0]            bdata_data;
  output                   bdata_valid;
  input                    bdata_ready;

  input                    awfmt_ready;
  output                   awfmt_valid;
  output [10:0]            awfmt_data;
  

  input                    awrite_s;         
  input [17:0]             aid_s;            
  input [31:0]             aaddr_s;          
  input [7:0]              alen_s;           
  input [2:0]              asize_s;          
  input [1:0]              aburst_s;         
  input [3:0]              acache_s;         
  input [2:0]              aprot_s;          
  input                    avalid_s;         
  input                    alock_s;          
  output                   aready_s;         


  output [17:0]             aid_m;            
  output [31:0]             aaddr_m;          
  output [7:0]              alen_m;           
  output [2:0]              asize_m;          
  output [1:0]              aburst_m;         
  output [3:0]              acache_m;         
  output [2:0]              aprot_m;          
  output                    alock_m;          
  output                    avalid_m;         
  input                     aready_m;         

  
  output [11:0]             arfmt_data;
  output                    downsize_m;


 
  reg [31:0]                aaddro;              
  reg [7:0]                 aleno;               
  reg [2:0]                 asizeo;              
  reg [1:0]                 abursto;             
  reg [17:0]                aido;                
  reg [3:0]                 acacheo;             
  reg [2:0]                 aproto;              
  reg                       alocko;              

  reg                       excl_override_reg;     
  reg                       busy_reg;              
  
  reg [10:0]                 wrap_bytes_remaining_reg; 
  reg [7:0]                 aaddr_reg;
  wire[7:0]                 addr_reg_inc;
  reg                       align_mask;           
  reg [2:0]                 read_mask;            
  reg [1:0]                 read_mask_end;            
  
  reg [2:0]                 write_mask;            
  
  reg [3:0]                    n_response;           

  reg [10:0]                 total_bytes;          
  reg [10:0]                 total_bytes_masked;    
  
  reg [2:0]                 wrapsize;             
  reg [2:0]                 wrapfitsize;          
  reg [3:0]                 wraplen;              
  reg [2:0]                 wrapalignmask;         
  
  reg                       wrap_split_reg;
  
  reg [2:0]                 incrsize;

  
  wire [11:0]               base_address;                     
  wire                      trans_overflow;
  wire                      burst_overflow;
  reg                       trans_overflow_reg;
  wire [11:0]               addr_result;
  wire [7:0]                inc_addr;
  wire [31:0]               aaddr_incr;
  wire [10:0]                next_incr_bytes_remaining_reg;
  wire                      incr_info_write_en;
  reg [3:0]                  a_count_reg;
  reg [10:0]                 incr_bytes_remaining_reg;  
  reg [11:0]                addr_mask;
  
  reg                       fixed_overflow_reg;
  reg [10:0]                 total_bytes_fixed;  
  
  reg [2:0]                 downsize;
  
  

  wire                      slave_hndshk;
  wire                      master_hndshk;        

  wire                      bypass;               
  
                                            
                                                  
  wire [31:0]               aaddr_aligned;
  wire [31:0]               aaddr_boundary;                                                  

  wire [5:0]                total_bytes_ext;      

  wire [10:0]                wrap_boundary_mask;   

  wire                      wrap_aligned;         
  wire                      wrap_is_incr;         
  wire                      wrap_split;           
  wire                      wrap_fits;            
  wire [10:0]                wrap_fits_mask;       
  wire [2:0]                working_addr;         

  wire                      wrap_split_reg_nxt;
  wire                      wrap_split_reg_wr_en;
  wire                      wrap_info_write_en;
  wire [10:0]                next_wrap_bytes_remaining_reg;
  wire [10:0]                addr_less_one;
  
  wire [7:0]                wraplen_i;
  
  wire [7:0]                alen_1;

  wire [7:0]                incrlen;

  wire [10:0]                bytes_to_transfer;
  wire [18:0]                bytes_to_transfer_large;
  wire [10:0]                bytes_to_transfer_wrap1;

  wire [1:0]                offset_address;       
  wire [7:0]                incrlenmaxsize;       

  
  wire [3:0]                   n_response_out;
  

  wire [2:0]                final_address;        
  wire                      overflow;             
  
  wire                      bytes_lt_one_byte;
  wire                      bytes_lt_two_byte;
  wire                      bytes_lt_two_half;
  wire                      bytes_lt_four_half;
  wire                      half_carry;
  wire                      half_carry_double;
  
  wire                      fixed_overflow;
  wire                      fixed_overflow_hold;
  wire                      wrap_overflow;
  wire                      count_sel_overflow;

  wire [3:0]                   a_count_in;
  wire [3:0]                   a_count_reg_next;
  wire                      a_count_reg_wr_en;

  
  wire                      fixed_overflow_reg_nxt;
  wire                      fixed_overflow_reg_wr_en;
  wire [5:0]                boundary_incr;
  wire                      downsize_m;
  wire                      overflow_reg;
  wire [1:0]                wrap_split_resp;
  wire                      wrap_split_overflow;
  wire [3:0]                trans_split_resp;
  wire [3:0]                trans_split_resp_incr;
  

  wire                      buffers_ok;        
  wire                      new_transaction;   
  wire                      trans_in_progress; 
  wire                      new_trans_avail;   
  wire                      trans_complete;    
  wire                      next_busy_reg;     
  wire                      busy_reg_wr_en;    
  wire                      excl_override;     


  wire                      no_long_bursts;    


  wire [10:0]                bytes_in_transfer;
  wire [10:0]                bytes_in_transfer_aligned;


 assign slave_hndshk = avalid_s & aready_s;
 assign master_hndshk = avalid_m & aready_m;

  
 assign arfmt_data = {n_response_out,
                      read_mask_end,
                      read_mask,
                      asize_s};

 assign n_response_out = (overflow_reg | wrap_split_reg) ? a_count_reg : n_response;

 always @(*)
  begin : p_end_addr_mask
  
    read_mask_end = {2{1'b1}};
    
    case (aburst_s)
      `AXI_ABURST_FIXED : read_mask_end = {2{1'b1}};
      `AXI_ABURST_WRAP  : read_mask_end =  wrap_fits ? total_bytes[1:0] : addr_less_one[1:0];
      `AXI_ABURST_INCR  : read_mask_end = (alen_m == `AXI_ALEN_1) ? total_bytes[1:0] : final_address[1:0];
      default           : read_mask_end = {2{1'bx}};
    endcase
  end 
  

 always @(*)
  begin : p_new_addr_incr_en_r
  
    read_mask = {3{1'b0}};
  
    case (aburst_s)
      `AXI_ABURST_FIXED : read_mask = {3{1'b0}};
      `AXI_ABURST_WRAP  : read_mask = total_bytes[2:0];
      `AXI_ABURST_INCR  : read_mask = {3{1'b1}};
      default           : read_mask = {3{1'bx}};
    endcase
  end 



 
 
 assign awfmt_data[`AWFIFO_BYPASS]    = bypass || (aburst_s == `AXI_ABURST_FIXED);
 assign awfmt_data[`AWFIFO_ADDR]      = aaddr_s[2:0];
 assign awfmt_data[`AWFIFO_SIZE]      = asize_s;
 assign awfmt_data[`AWFIFO_MASK]      = write_mask;
 assign awfmt_data[`AWFIFO_WRAP_FITS] = wrap_fits;

 assign awfmt_valid = new_transaction && awrite_s;

 always @(*)
  begin : p_new_addr_incr_en_w
  
    write_mask = {3{1'b0}};
  
    case (aburst_s)
      `AXI_ABURST_FIXED : write_mask = {3{1'b0}};
      `AXI_ABURST_WRAP  : write_mask = total_bytes[2:0];
      `AXI_ABURST_INCR  : write_mask = {3{1'b1}};
      default           : write_mask = {3{1'bx}};
    endcase
  end 

 



 assign bdata_data = {aid_s, n_response};

 assign bdata_valid = new_transaction && awrite_s;

 


  always @(*)
  begin : p_n_response_select

    n_response = {4{1'b0}};
    
    case (aburst_s)
      `AXI_ABURST_FIXED : n_response = fixed_overflow_hold ? alen_s[3:0] : {4{1'b0}};
      `AXI_ABURST_WRAP  : n_response = (wrap_split & (trans_overflow | wrap_split_overflow)) ? {{2{1'b0}},wrap_split_resp}
                                       : ((trans_overflow) ? trans_split_resp
                                         : {{3{1'b0}}, wrap_split});
      `AXI_ABURST_INCR  : n_response = trans_overflow ? trans_split_resp : {4{1'b0}};
      default           : n_response = {4{1'bx}};
    endcase
  end 

  assign trans_split_resp_incr = bytes_to_transfer_large[9:6] + 4'b1;
  assign trans_split_resp = (burst_overflow) ? trans_split_resp_incr :
                            (no_long_bursts) ? bytes_to_transfer_large[9:6]    : 
                                               bytes_to_transfer_large[13:10];

  assign wrap_split_overflow = |next_wrap_bytes_remaining_reg[10:6];
  assign wrap_split_resp = (no_long_bursts) ? 2'b10 : {{1{1'b0}},{1'b1}};
  



 
 assign buffers_ok = (awrite_s) ? bdata_ready & awfmt_ready : 1'b1;

 
 assign  trans_complete = ~(trans_overflow | 
                           (wrap_split & ~wrap_split_reg)  | 
                           (fixed_overflow_hold & ~fixed_overflow_reg)            | 
                           (fixed_overflow_reg & |a_count_reg));    

 assign trans_in_progress = new_transaction | busy_reg;

 assign new_transaction = new_trans_avail & buffers_ok;

 assign new_trans_avail = avalid_s & ~busy_reg;

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



 assign excl_override = (new_transaction) ? |n_response | (|aleno[7:4]) : excl_override_reg;

 always @(posedge aclk or negedge aresetn)
   begin : excl_override_reg_p
      if (!aresetn) begin
          excl_override_reg <= 1'b0;
      end else if (new_transaction) begin
          excl_override_reg <= excl_override;
      end
    end




 assign aid_m =     aido;
 assign acache_m =  acacheo;
 assign aprot_m =   aproto;
 assign alen_m =    aleno;
 assign asize_m =   asizeo;
 assign aaddr_m =   aaddro;
 assign aburst_m =  abursto;
 assign alock_m =   alocko;

 assign avalid_m = avalid_s && trans_in_progress;

 assign aready_s = master_hndshk && trans_complete;

 always @(*) begin

      aleno = incrlen;
      asizeo = incrsize;
      abursto = `AXI_ABURST_INCR;
      aido = aid_s;
      acacheo = acache_s;
      aproto = aprot_s;
      aaddro = (trans_overflow_reg) ? aaddr_boundary : aaddr_aligned;
      
      alocko = (alock_s && (~excl_override));
      


      if (!wrap_split_reg) begin

         aaddro = (trans_overflow_reg) ? aaddr_incr : aaddr_s;
         if (wrap_aligned) begin
            aleno = wraplen_i;
            asizeo = wrapsize;
            abursto = wrap_overflow ? `AXI_ABURST_INCR : `AXI_ABURST_WRAP;
         end else if (bypass) begin
            aleno = alen_s;
            asizeo = asize_s;
            abursto = aburst_s;
         end else if (wrap_fits) begin
            aaddro = aaddr_aligned;
            aleno = alen_1;
            asizeo = wrapfitsize;
            abursto = `AXI_ABURST_INCR;
         end else if ((!fixed_overflow) && aburst_s == `AXI_ABURST_FIXED) begin
            aleno = alen_s;
            asizeo = incrsize;
            abursto = `AXI_ABURST_FIXED;
         end
      end
  end

  
 assign wraplen_i = {4'b0000,wraplen};
 assign alen_1 = {4'b0000,`AXI_ALEN_1};

 assign addr_less_one = aaddr_s[10:0] - {{10{1'b0}},1'b1};
 
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

 assign aaddr_aligned = {aaddr_s[31:11],((aaddr_s[10:0]) & (~total_bytes))};


 assign wrap_split_reg_nxt = wrap_split & ~(wrap_split_reg ^ trans_overflow);

 assign wrap_split_reg_wr_en = master_hndshk;

 always @(posedge aclk or negedge aresetn)
   begin : wrap_split_p
      if (!aresetn)
          wrap_split_reg <= 1'b0;
      else if (wrap_split_reg_wr_en)
          wrap_split_reg <= wrap_split_reg_nxt;
    end



  
 
 
 assign bypass = (aburst_s == `AXI_ABURST_FIXED && (align_mask)) || ( (align_mask) ? ((~acache_s[1]) || (alen_s == `AXI_ALEN_1) ) : 1'b0 );
 
 assign no_long_bursts = ~(|alen_s[7:4]);
 

 always @(*)
  begin : total_bytes_p
    case (asize_s)
       `AXI_ASIZE_8    : total_bytes = {3'b0, alen_s};
       `AXI_ASIZE_16   : total_bytes = {2'b0, alen_s, 1'b1};
       `AXI_ASIZE_32   : total_bytes = {1'b0, alen_s, 2'b11};
       `AXI_ASIZE_64   : total_bytes = {alen_s, 3'b111};
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes = {3'b0, alen_s};    
       default         : total_bytes = {11'bx};
    endcase
  end


 assign total_bytes_ext = total_bytes[5:0];

 always @(*)
  begin : wrap_size_len
   if (total_bytes_ext[2]) begin
            wrapfitsize = `AXI_ASIZE_64;
            wrapsize = `AXI_ASIZE_32;
            wraplen = total_bytes_ext[5:2];
            wrapalignmask = {1'b0, 2'b11};
  end else if (total_bytes_ext[1]) begin
            wrapfitsize = `AXI_ASIZE_32;
            wrapsize = `AXI_ASIZE_16;
            wraplen = total_bytes_ext[4:1];
            wrapalignmask = {2'b0, 1'b1};
  end else if (total_bytes_ext[0])begin
            wrapfitsize = `AXI_ASIZE_16;
            wrapsize = `AXI_ASIZE_8;
            wraplen = total_bytes_ext[3:0];
            wrapalignmask = 3'b0;
  end else begin
            wrapfitsize = 3'bx;
            wrapsize = 3'bx;
            wraplen = 4'bx;
            wrapalignmask = 3'bx;
        end
  end

 assign working_addr = aaddr_s[2:0] & wrapalignmask;

 assign wrap_fits_mask = {{9{1'b1}}, 2'b00};
 

 assign  wrap_fits = ~|(total_bytes & wrap_fits_mask) & (aburst_s == `AXI_ABURST_WRAP);
 assign  wrap_is_incr = ~|(aaddr_s[10:0] & total_bytes);
 assign  wrap_aligned = ~|working_addr & (aburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_is_incr & ~wrap_fits & ~wrap_overflow;
 assign  wrap_split = ((|working_addr) || (wrap_overflow)) & (aburst_s == `AXI_ABURST_WRAP) & ~bypass & ~wrap_fits & ~wrap_is_incr;

 


 assign wrap_boundary_mask = total_bytes;



 assign bytes_to_transfer_wrap1 = ~(aaddr_s[10:0]) & wrap_boundary_mask;

 assign bytes_to_transfer = (trans_overflow_reg) ? incr_bytes_remaining_reg
                            : ((wrap_split_reg) ? wrap_bytes_remaining_reg
                            : ((aburst_s == `AXI_ABURST_FIXED) ? total_bytes_fixed
                            : ((aburst_s == `AXI_ABURST_WRAP) ? bytes_to_transfer_wrap1
                            : total_bytes_masked)));

 

 always @(*)
  begin : total_bytes_masked_p
    case (asize_s)
       `AXI_ASIZE_8    : total_bytes_masked = {3'b0, alen_s};
       `AXI_ASIZE_16   : total_bytes_masked = {2'b0, alen_s, ~aaddr_s[0]};
       `AXI_ASIZE_32   : total_bytes_masked = {1'b0, alen_s, ~aaddr_s[1:0]};
       `AXI_ASIZE_64   : total_bytes_masked = {alen_s, ~aaddr_s[2:0]};
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes_masked = {3'b0, alen_s};    
       default         : total_bytes_masked = {11{1'bx}};
    endcase
 end

 
  always @(*)
  begin : align_mask_p
    case (asize_s)
       `AXI_ASIZE_8    : align_mask = 1'b1;
       `AXI_ASIZE_16   : align_mask = 1'b1;
       `AXI_ASIZE_32   : align_mask = 1'b1;
       `AXI_ASIZE_64   : align_mask = 1'b0;
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : align_mask = 1'b0;    
       default         : align_mask = 1'bx;
    endcase
  end
  
  always @(*)
   begin : total_bytes_fixed_p
      case (asize_s)
        `AXI_ASIZE_8    : total_bytes_fixed = {11{1'b0}};
        `AXI_ASIZE_16   : total_bytes_fixed = {{10{1'b0}}, ~aaddr_s[0]};
        `AXI_ASIZE_32   : total_bytes_fixed = {{9{1'b0}}, ~aaddr_s[1:0]};
        `AXI_ASIZE_64   : total_bytes_fixed = {{8{1'b0}}, ~aaddr_s[2:0]};
        `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : total_bytes_fixed = {11{1'b0}};    
        default         : total_bytes_fixed = {11{1'bx}};
    endcase
  end
  

 assign offset_address = (wrap_split_reg) ? aaddr_aligned[1:0] : 
                            ((trans_overflow_reg) ? aaddr_incr[1:0] : 
                            aaddr_s[1:0]);

 assign  half_carry =  bytes_to_transfer[0] & offset_address[0];
 assign  half_carry_double = half_carry & bytes_to_transfer[1];
 

 assign  bytes_lt_one_byte   = ~|bytes_to_transfer;
 assign  bytes_lt_two_byte   = ~|bytes_to_transfer[10:1];
 assign  bytes_lt_two_half   = ~|bytes_to_transfer[10:1] & ~half_carry;
 assign  bytes_lt_four_half  = ~|bytes_to_transfer[10:2] & ~half_carry_double;
 

 always @(*)
  begin : size_lookup

        incrsize = `AXI_ASIZE_32;

        if (bytes_lt_one_byte || (bytes_lt_two_byte && (offset_address[1:0] == {2{1'b1}}))) begin
            incrsize = `AXI_ASIZE_8;
        end else if (bytes_lt_two_half || (bytes_lt_four_half && (offset_address[1:1] == {1{1'b1}}))) begin
            incrsize = `AXI_ASIZE_16;
        end 

  end

  assign final_address = {1'b0, offset_address} + {1'b0, bytes_to_transfer_large[1:0]};
  assign overflow = (trans_overflow & ~trans_overflow_reg) ? 1'b0 : final_address[2];

  assign bytes_to_transfer_large = {8'b00000000, bytes_to_transfer};

  

  assign incrlenmaxsize =  bytes_to_transfer_large[9:2] + 4'b1;
  assign incrlen = (overflow) ? incrlenmaxsize :  
                   (trans_overflow ?  {{4{~no_long_bursts}}, 4'b1111} : bytes_to_transfer_large[9:2]);

  
 assign downsize_m = downsize[2:2];

  always @(*)
    begin : downsize_mask_p
      case (asize_s)
       `AXI_ASIZE_8    : downsize = {3{1'b0}};
       `AXI_ASIZE_16   : downsize = {{2{1'b0}},{1'b1}};
       `AXI_ASIZE_32   : downsize = {{1{1'b0}},{2'b11}};
       `AXI_ASIZE_64   : downsize = {{3'b111}};
       `AXI_ASIZE_128,
       `AXI_ASIZE_256,
       `AXI_ASIZE_512,
       `AXI_ASIZE_1024 : downsize = {3{1'b0}};    
        default : downsize = 3'bx;
      endcase
    end
  
 assign overflow_reg = (fixed_overflow_reg || trans_overflow_reg);


 
 assign burst_overflow = ~bypass & final_address[2] & ~trans_overflow_reg &
                                 (&({(bytes_to_transfer[9:6] | {4{no_long_bursts}}), bytes_to_transfer[5:2]}));
 

 assign trans_overflow = burst_overflow | ((no_long_bursts) ? (|bytes_to_transfer[10:6]) : bytes_to_transfer[10]);


 always @(posedge aclk or negedge aresetn)
   begin : trans_overflow_p
      if (!aresetn)
          trans_overflow_reg <= 1'b0;
      else if (master_hndshk)
          trans_overflow_reg <= trans_overflow;
    end

  assign incr_info_write_en = trans_overflow & master_hndshk;

  always @(posedge aclk or negedge aresetn)
   begin : addr_overflow_p
      if (!aresetn)
          aaddr_reg <= 8'h00;
      else if (incr_info_write_en)
          aaddr_reg <= aaddro[11:4];
    end 

  always @(posedge aclk or negedge aresetn)
   begin : incr_bytes_remaining_reg_p
      if (!aresetn) begin
          incr_bytes_remaining_reg <= 11'b0;
      end else if (incr_info_write_en) begin
          incr_bytes_remaining_reg <= next_incr_bytes_remaining_reg;
      end
    end

  assign base_address = (wrap_split_reg) ? aaddr_s[11:0] & {{1{1'b1}},  ~wrap_boundary_mask} : aaddr_s[11:0];

  
  
  
  

  assign addr_reg_inc = ((no_long_bursts) ? 8'b00000100 : 8'b01000000); 
                       

  assign inc_addr = aaddr_reg + addr_reg_inc; 

  

  assign addr_result = {inc_addr,base_address[3:0]} & 12'b111111111100;
  

  
  assign aaddr_incr = {aaddr_s[31:12],addr_result};


  assign bytes_in_transfer = {{1{1'b0}}, {4{~no_long_bursts}}, 4'b1111, {2{1'b1}}};     
                                          
  assign bytes_in_transfer_aligned = (trans_overflow & ~trans_overflow_reg) ? 
                  bytes_in_transfer & {{9{1'b1}}, ~aaddr_s[1:0]} : 
                  bytes_in_transfer;

                                          

  assign next_incr_bytes_remaining_reg = bytes_to_transfer - bytes_in_transfer_aligned - {{10{1'b0}},1'b1};

  


  assign fixed_overflow = (aburst_s == `AXI_ABURST_FIXED) ? avalid_s & ((~align_mask)  & (|incrlen)) : 1'b0;

  assign fixed_overflow_hold = fixed_overflow & (|alen_s);

 assign fixed_overflow_reg_nxt = (fixed_overflow_hold) & ~(slave_hndshk);

 assign fixed_overflow_reg_wr_en = (master_hndshk) & (fixed_overflow_hold);

 always @(posedge aclk or negedge aresetn)
   begin : fixed_overflow_p
      if (!aresetn)
          fixed_overflow_reg <= 1'b0;
      else if (fixed_overflow_reg_wr_en)
          fixed_overflow_reg <= fixed_overflow_reg_nxt;
    end





  assign wrap_overflow = (aburst_s == `AXI_ABURST_WRAP) ?
                          avalid_s & (|total_bytes[10:6]) : 1'b0;


  
  assign boundary_incr = aaddr_aligned[11:6] + 6'b000001;

  assign aaddr_boundary = ({aaddr_aligned[31:12],boundary_incr,aaddr_aligned[5:0]});

 


  
  assign a_count_in = (|aburst_s) ? (n_response - {{3{1'b0}}, 1'b1}) : (alen_s[3:0] - 4'b0001);
  
  assign count_sel_overflow = (fixed_overflow_hold || trans_overflow || wrap_overflow);


  assign a_count_reg_next = (count_sel_overflow & (~|a_count_reg)) ? a_count_in :
                              ((master_hndshk & ~slave_hndshk & (count_sel_overflow) ? a_count_reg - 4'b1 : 
                                a_count_reg));


  assign a_count_reg_wr_en = ((fixed_overflow || trans_overflow || wrap_overflow) & ~slave_hndshk & master_hndshk);

 always @(posedge aclk or negedge aresetn)
     begin : a_count_cnt_p
       if (!aresetn)
          a_count_reg <= 4'b0;
       else if (a_count_reg_wr_en)
          a_count_reg <= a_count_reg_next;
     end 

 

`ifdef ARM_ASSERT_ON


  assert_never #(0,0,"ERROR, Transaction incoming that has asize too large for incoming bus")
      ovl_max_input_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_s && (asize_s > 3))
       );

  assert_never #(0,0,"ERROR, Transaction issued that is too large for outgoing bus")
      ovl_max_output_size
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_m && (asize_m > 2))
       );

  assert_never #(0,0,"ERROR, Inefficient transaction issued when not in bypass")
      ovl_inefficient_size_len_com
       (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_m && (!bypass) && (alen_m > 4'b1)
                    && (asize_m != 2)
                    && (aburst_m != 2'b0))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been touched")
      ovl_illegal_trans_mod
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_m && (!acache_s[1]) && (asize_s <= 2)
                    && (asize_s != asize_m) && (alen_s != alen_m))
       );

  assert_never #(0,0,"ERROR, Transaction should not have been created")
      ovl_illegal_trans_create
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_m && (!avalid_s))
       );

 assert_never #(0,0,"ERROR, Unaligned incoming wrap")
      ovl_illegal_incoming_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_s && (aburst_s == `AXI_ABURST_WRAP) &&
                    !((asize_s == `AXI_ASIZE_8) ||
                      (asize_s == `AXI_ASIZE_16  && aaddr_s[0]   == 1'b0) ||
                      (asize_s == `AXI_ASIZE_32  && aaddr_s[1:0] == 2'b0) ||
                      (asize_s == `AXI_ASIZE_64  && aaddr_s[2:0] == 3'b0) ||
                      (asize_s == `AXI_ASIZE_128 && aaddr_s[3:0] == 4'b0) ||
                      (asize_s == `AXI_ASIZE_256 && aaddr_s[4:0] == 5'b0)))
       );

 assert_never #(0,0,"ERROR, Unaligned outgoing wrap")
      ovl_illegal_outgoing_wrap
        (
        .clk       (aclk),
        .reset_n   (aresetn),
        .test_expr (avalid_m && (aburst_m == `AXI_ABURST_WRAP) &&
                   !((asize_m == `AXI_ASIZE_8) ||
                     (asize_m == `AXI_ASIZE_16  && aaddr_m[0]   == 1'b0) ||
                     (asize_m == `AXI_ASIZE_32  && aaddr_m[1:0] == 2'b0) ||
                     (asize_m == `AXI_ASIZE_64  && aaddr_m[2:0] == 3'b0) ||
                     (asize_m == `AXI_ASIZE_128 && aaddr_m[3:0] == 4'b0) ||
                     (asize_m == `AXI_ASIZE_256 && aaddr_m[4:0] == 5'b0)))
       );

 reg avalid_m_prev;
 reg avalid_s_prev;
 reg aready_m_prev;
 reg aready_s_prev;
 reg in_trans;
 reg [3:0]  n_response_count;

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           avalid_m_prev <= 1'b0;
           avalid_s_prev <= 1'b0;
           aready_m_prev <= 1'b0;
           aready_s_prev <= 1'b0;
        end else begin
           avalid_m_prev <= avalid_m;
           avalid_s_prev <= avalid_s;
           aready_m_prev <= aready_m;
           aready_s_prev <= aready_s;
        end
    end

 always @(posedge aclk or negedge aresetn)
    begin
       if (!aresetn) begin
           in_trans <= 1'b0;
       end else if (avalid_m && aready_m) begin
           in_trans <= avalid_s && (!aready_s);
       end
    end

 always @(posedge aclk or negedge aresetn)
    begin
        if (!aresetn) begin
           n_response_count <= 4'b0;
        end else if (avalid_m && aready_m && (!in_trans) && |n_response) begin
           n_response_count <= {1'b0, n_response};
        end else if (avalid_m && aready_m && |n_response_count) begin
           n_response_count <= n_response_count - 4'b1;
        end
    end

 assert_never #(0,0,"ERROR, Exclusive transaction has been split")
   ovl_split_exclusive
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (avalid_m && (!avalid_s)
                  && alock_m == `AXI_ALOCK_EXCL)
     );

 assert_implication #(0,0,"ERROR, Transaction has lost lock")
   ovl_lost_lock
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (avalid_s && avalid_m &&
                        alock_s == `AXI_ALOCK_LOCKED),
      .consequent_expr (alock_m == `AXI_ALOCK_LOCKED)
     );

 assert_never #(0,0,"ERROR, Sticky output valid")
   ovl_sticky_valid_m
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (avalid_m_prev && (!avalid_m)
                  && (!aready_m_prev))
     );

 assert_never #(0,0,"ERROR, Sticky input valid")
   ovl_sticky_valid_s
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (avalid_s_prev && (!avalid_s)
                  && (!aready_s_prev))
     );

 

 assert_implication #(0,0,"ERROR, Illegal transaction count")
   ovl_illegal_trans_count
     (
      .clk       (aclk),
      .reset_n   (aresetn),
      .antecedent_expr (avalid_s && aready_s),
      .consequent_expr (avalid_m && aready_m &&
                       (((!in_trans) && (~|n_response)) || (in_trans && n_response_count == 4'b1)))
     );

`endif


endmodule

`include "nic400_ib_apb_group0_ib_undefs_sse710_integration_example_f0_host_exp.v"


