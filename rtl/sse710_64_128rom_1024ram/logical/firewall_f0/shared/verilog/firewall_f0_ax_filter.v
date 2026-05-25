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

module firewall_f0_ax_filter #(
  parameter FC_PE_LVL           = 2,
  parameter FC_ADDR_WIDTH       = 64,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter FC_AXIUSER_AX_WIDTH = 1,
  parameter FC_NUM_RGN          = 1,
  parameter LOG2_FC_NUM_RGN     = 1,
  parameter FC_NUM_MPE          = 2,
  parameter FC_MNRS             = 7'h0, 
  parameter FC_MXRS             = 7'h8,  
  parameter FC_SINGLE_MST       = 1,
  parameter RD_NWR              = 1,  
  `include "firewall_f0_reg_width_params.vh"
)
(
    input  wire [FC_AXIID_WIDTH-1:0]       axid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]        axaddr_s_i  ,
    input  wire [7:0]                      axlen_s_i   ,
    input  wire [2:0]                      axsize_s_i  ,
    input  wire [1:0]                      axburst_s_i ,
    input  wire                            axlock_s_i  ,
    input  wire [3:0]                      axcache_s_i ,
    input  wire [2:0]                      axprot_s_i  ,
    input  wire [3:0]                      axqos_s_i   ,
    input  wire [3:0]                      axregion_s_i,
    input  wire [FC_AXIUSER_AX_WIDTH-1:0]  axuser_s_i  ,
    input  wire                            axvalid_s_i ,
    output reg                             axready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]      axmmusid_s_i,

    output reg  [FC_AXIID_WIDTH-1:0]       axid_te_o    ,
    output reg  [FC_ADDR_WIDTH-1:0]        axaddr_te_o  ,
    output reg  [7:0]                      axlen_te_o   ,
    output reg  [2:0]                      axsize_te_o  ,
    output reg  [1:0]                      axburst_te_o ,
    output reg                             axlock_te_o  ,
    output reg  [3:0]                      axcache_te_o ,
    output reg  [2:0]                      axprot_te_o  ,
    output reg  [3:0]                      axqos_te_o   ,
    output reg  [3:0]                      axregion_te_o,
    output reg  [FC_AXIUSER_AX_WIDTH-1:0]  axuser_te_o  ,
    output reg                             axvalid_te_o ,
    input  wire                            axready_te_i ,
    output reg  [FC_MST_ID_WIDTH-1:0]      axmmusid_te_o,
    output reg                             filter_result_vld_te_o,
    output reg  [LOG2_FC_NUM_RGN-1:0]      rgn_number_o,

    output reg  [FC_AXIID_WIDTH-1:0]       axid_fh_o    ,
    output reg  [FC_ADDR_WIDTH-1:0]        axaddr_fh_o  ,
    output reg  [7:0]                      axlen_fh_o   ,
    output reg  [2:0]                      axprot_fh_o  ,
    output reg                             axvalid_fh_o ,
    input  wire                            axready_fh_i ,
    output reg  [FC_MST_ID_WIDTH-1:0]      axmmusid_fh_o,
    output reg                             filter_result_vld_fh_o,

    output reg  [1:0]                      filter_result_val_o, 

    input  wire                                    pe_st_en_i,
    input  wire [PROT_SIZE_WIDTH-1:0]              prot_size_i,
    input  wire                                    bypass_i,
    input  wire                                    sram_rdy_i, 

    input  wire [(FC_NUM_RGN*RGN_ST_WIDTH)-1:0]    rgn_st_i,
    input  wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  rgn_size_i,
    input  wire [(FC_NUM_RGN*FC_MXRS)-1:0]         rgn_base_addr_i,
    input  wire [(FC_NUM_RGN*FC_MXRS)-1:0]         rgn_upper_addr_i,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rgn_mid0_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rgn_mid1_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rgn_mid2_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rgn_mid3_i,

    input  wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rgn_mpl0_i,
    input  wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rgn_mpl1_i,
    input  wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rgn_mpl2_i,
    input  wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rgn_mpl3_i
);

localparam FIXED = 2'b00;
localparam INCR = 2'b01;
localparam WRAP = 2'b10;
localparam IDLE = 2'b00;
localparam ACCESS_ERR = 2'b01;
localparam PROG_ERR = 2'b10;
localparam OKAY = 2'b11;

localparam AXI_4K_BURST = 32'h0000_0FFF;

generate
  if (FC_PE_LVL == 0) begin : NO_PE


    always @* begin
      axid_fh_o     = {FC_AXIID_WIDTH{1'b0}};
      axaddr_fh_o   = {FC_ADDR_WIDTH{1'b0}};
      axlen_fh_o    = {8{1'b0}};
      axprot_fh_o   = {3{1'b0}};
      axvalid_fh_o  = 1'b0;
      axmmusid_fh_o = {FC_MST_ID_WIDTH{1'b0}};
      filter_result_vld_fh_o = 1'b0;
      filter_result_val_o = 2'b00;

     axid_te_o       = axid_s_i    ;
     axaddr_te_o     = axaddr_s_i  ;
     axlen_te_o      = axlen_s_i   ;
     axsize_te_o     = axsize_s_i  ;
     axburst_te_o    = axburst_s_i ;
     axlock_te_o     = axlock_s_i  ;
     axcache_te_o    = axcache_s_i ;
     axprot_te_o     = axprot_s_i  ;
     axqos_te_o      = axqos_s_i   ;
     axregion_te_o   = axregion_s_i;
     axuser_te_o     = axuser_s_i  ;
     axvalid_te_o    = axvalid_s_i ;
     axready_s_o     = axready_te_i;
     axmmusid_te_o   = axmmusid_s_i;
     filter_result_vld_te_o = 1'b0;
     rgn_number_o    = {LOG2_FC_NUM_RGN{1'b0}};
   end

  end else if (FC_PE_LVL > 0) begin : PE


    reg [FC_NUM_RGN-1:0] mpl0_matched;
    reg [FC_NUM_RGN-1:0] mpl1_matched;
    reg [FC_NUM_RGN-1:0] mpl2_matched;
    reg [FC_NUM_RGN-1:0] mpl3_matched;

    reg [FC_NUM_RGN-1:0] mid0_matched;
    reg [FC_NUM_RGN-1:0] mid1_matched;
    reg [FC_NUM_RGN-1:0] mid2_matched;
    reg [FC_NUM_RGN-1:0] mid3_matched;

    reg [3:0]            region_mid_matched; 
    reg [FC_NUM_RGN-1:0] region_mid0_matched;
    reg [FC_NUM_RGN-1:0] region_mid1_matched;
    reg [FC_NUM_RGN-1:0] region_mid2_matched;
    reg [FC_NUM_RGN-1:0] region_mid3_matched;

    reg [7:0] mpl0_read; 
    reg [7:0] mpl1_read;
    reg [7:0] mpl2_read;
    reg [7:0] mpl3_read;

    reg [7:0] mpl0_write;
    reg [7:0] mpl1_write;
    reg [7:0] mpl2_write;
    reg [7:0] mpl3_write;

    reg mult_mid_found;
    reg mult_rgn_mid_found;
    wire [FC_NUM_RGN-1:0] mult_rgn_mid_ovlp;

    reg  [FC_NUM_RGN-1:0] base_addr_matched;
    reg  [FC_NUM_RGN-1:0] upper_addr_matched;
    wire [FC_NUM_RGN-1:0] region_addr_matched;
    reg  [FC_NUM_RGN-1:0] region_size_zero;
    reg  first_rgn_mid_matched;
    reg  second_rgn_mid_matched;
    reg  unique_rgn_mid_matched;
    reg  mult_rgn_mid_matched;
    reg [FC_NUM_RGN-1:0] region_mpe_matched;
    reg [FC_MXRS-1:0] trans_base_addr;     
    reg [FC_MXRS-1:0] trans_upper_addr;    
    wire [FC_MXRS-1:0] trans_base_addr_masked;
    wire [FC_MXRS-1:0] trans_upper_addr_masked;
    reg [(FC_NUM_RGN*FC_MXRS)-1:0] rgn_base_addr_masked;
    reg [(FC_NUM_RGN*FC_MXRS)-1:0] rgn_upper_addr_masked;
    wire [7:0] wrap_num_bytes_per_beat;
    wire [11:0] wrap_num_bytes_per_burst;  
    wire [11:0] incr_num_bytes_per_burst;  
    reg prot_size_result_pe2;
    reg [FC_MXRS-1:0] addr_mask;           
    reg [FC_MXRS-1:0] addr_align_mask;
    reg prot_size_addr_chk;
    reg prot_size_zero;
    reg [FC_NUM_MPE-1:0] same_region_mult_mid;
    wire mpl_match;
    reg mpl_match_0;
    reg mpl_match_1;
    reg mpl_match_2;
    reg mpl_match_3;
    wire [FC_ADDR_WIDTH-1:0] wrap_num_bytes_per_burst_addr_w;
    reg default_rgn_only_match;
    wire max_4k_burst;

    assign wrap_num_bytes_per_beat = (axlen_s_i[3:0]+8'h1);
    assign wrap_num_bytes_per_burst = {4'h0, wrap_num_bytes_per_beat} << axsize_s_i;  
    assign wrap_num_bytes_per_burst_addr_w = {{(FC_ADDR_WIDTH-12){1'b0}}, wrap_num_bytes_per_burst}; 
    assign incr_num_bytes_per_burst =  ((axlen_s_i+12'h1) << axsize_s_i);
    assign max_4k_burst = ((axlen_s_i == 8'hFF) && (axsize_s_i == 3'h4)) ||
                          ((axlen_s_i == 8'h7F) && (axsize_s_i == 3'h5)) ||
                          ((axlen_s_i == 8'h3F) && (axsize_s_i == 3'h6)) ||
                          ((axlen_s_i == 8'h1F) && (axsize_s_i == 3'h7));

    always @*
    begin: align_base_addr
     integer x;
     addr_align_mask = {FC_MXRS{1'b1}};
      for (x=0; x<7; x=x+1) begin
        if (x < axsize_s_i) begin
          addr_align_mask[x] = 1'b0;
        end
      end
    end 

    always @*
    begin : trans_addr
      case (axburst_s_i)
        FIXED: begin    
          trans_base_addr = axaddr_s_i[FC_MXRS-1:0]; 
          trans_upper_addr = (axaddr_s_i[FC_MXRS-1:0] & addr_align_mask) + (1'b1<<axsize_s_i) - {{(FC_MXRS-1){1'b0}}, 1'b1};  
        end
        INCR: begin          
          trans_base_addr = axaddr_s_i[FC_MXRS-1:0];
          trans_upper_addr = max_4k_burst ? (axaddr_s_i[FC_MXRS-1:0] & addr_align_mask) + AXI_4K_BURST[FC_MXRS-1:0] : (axaddr_s_i[FC_MXRS-1:0] & addr_align_mask) + incr_num_bytes_per_burst - {{(FC_MXRS-1){1'b0}}, 1'b1};
        end
        WRAP: begin
          trans_base_addr = axaddr_s_i[FC_MXRS-1:0] & ~(wrap_num_bytes_per_burst_addr_w[FC_MXRS-1:0] - {{(FC_MXRS-1){1'b0}}, 1'b1});
          trans_upper_addr = axaddr_s_i[FC_MXRS-1:0] | (wrap_num_bytes_per_burst_addr_w[FC_MXRS-1:0] - {{(FC_MXRS-1){1'b0}}, 1'b1});
        end
        default: begin  
          trans_base_addr = axaddr_s_i[FC_MXRS-1:0];
          trans_upper_addr = axaddr_s_i[FC_MXRS-1:0];
        end
      endcase
    end 

   assign trans_base_addr_masked = trans_base_addr & addr_mask;
   assign trans_upper_addr_masked = trans_upper_addr & addr_mask;

    always @*
    begin: rgn_addr_mask_gen
    integer x;
      for (x=0; x<FC_NUM_RGN; x=x+1)
      begin
        rgn_base_addr_masked[(x*FC_MXRS)+FC_MXRS-1 -:FC_MXRS] = rgn_base_addr_i[(x*FC_MXRS)+FC_MXRS-1 -: FC_MXRS] & addr_mask;
        rgn_upper_addr_masked[(x*FC_MXRS)+FC_MXRS-1 -:FC_MXRS] = rgn_upper_addr_i[(x*FC_MXRS)+FC_MXRS-1 -: FC_MXRS] & addr_mask;
      end
    end 


    always @*
    begin: addr_mask_prot

      integer x1;
      integer x2;
      integer x3;

      if (FC_PE_LVL == 2) begin : PE_2


        if (prot_size_i == {PROT_SIZE_WIDTH{1'b0}}) begin
          prot_size_zero = 1'b1;
        end else begin
          prot_size_zero = 1'b0;
        end


        prot_size_addr_chk = 1'b1; 

        if (prot_size_i<FC_MXRS) begin 
          for (x1=FC_MNRS+5; x1<FC_MXRS; x1=x1+1) begin
            if (x1>=prot_size_i) begin
              if (trans_base_addr[x1] || trans_upper_addr[x1] ) begin 
                prot_size_addr_chk = 1'b0;  
              end
            end
          end
        end


        addr_mask = {FC_MXRS{1'b1}};

        for (x2=0;x2<FC_MXRS;x2=x2+1) begin
          if (x2<FC_MNRS+5) begin
            addr_mask[x2] = 1'b0;
          end
        end

        prot_size_result_pe2 = prot_size_addr_chk & ~prot_size_zero;
      end else begin 
        prot_size_result_pe2 = 1'b1; 

        addr_mask = {FC_MXRS{1'b0}};
        for (x3=FC_MNRS+5;x3<FC_MXRS;x3=x3+1) begin
          addr_mask[x3] = 1'b1;
        end
      end 
    end 

    always @*
    begin: addr_cmp
    integer x;

      base_addr_matched = {FC_NUM_RGN{1'b0}};
      upper_addr_matched = {FC_NUM_RGN{1'b0}};

      for (x=0; x<FC_NUM_RGN; x=x+1) begin
       if ((trans_base_addr_masked >= rgn_base_addr_masked[x*FC_MXRS+FC_MXRS-1 -: FC_MXRS])
            &&
            (trans_base_addr_masked <= rgn_upper_addr_masked[x*FC_MXRS+FC_MXRS-1 -: FC_MXRS])
            && axvalid_s_i && rgn_st_i[(x)*RGN_ST_WIDTH]) begin
          base_addr_matched[x] = 1'b1;
        end

        if ((trans_upper_addr_masked >= rgn_base_addr_masked[x*FC_MXRS+FC_MXRS-1 -: FC_MXRS])
            &&
            (trans_upper_addr_masked <=rgn_upper_addr_masked[x*FC_MXRS+FC_MXRS-1 -: FC_MXRS])
            && axvalid_s_i && rgn_st_i[(x)*RGN_ST_WIDTH])  begin

          upper_addr_matched[x] = 1'b1;
        end
      end
    end 

    always @*
    begin: rgn_size_zerod
     integer x;
     region_size_zero = {FC_NUM_RGN{1'b1}};
      if (FC_PE_LVL>0) begin
        for (x=0; x<FC_NUM_RGN; x=x+1) begin
          if ((rgn_size_i[(x*RGN_SIZE_WIDTH)+8-1 -: 8] == 8'h00) && (rgn_size_i[(x*RGN_SIZE_WIDTH)+9-1 -: 1]==1'b0)) begin
            region_size_zero[x] = 1'b0;
          end
        end
      end
    end 

    assign region_addr_matched = base_addr_matched & upper_addr_matched & region_size_zero;

    always @*
    begin: mpl_cmp
      integer x;
      integer y;
      mpl0_matched = {FC_NUM_RGN{1'b0}};
      mpl1_matched = {FC_NUM_RGN{1'b0}};
      mpl2_matched = {FC_NUM_RGN{1'b0}};
      mpl3_matched = {FC_NUM_RGN{1'b0}};

      mpl0_read = 8'h00;
      mpl1_read = 8'h00;
      mpl2_read = 8'h00;
      mpl3_read = 8'h00;

      mpl0_write = 8'h00;
      mpl1_write = 8'h00;
      mpl2_write = 8'h00;
      mpl3_write = 8'h00;

      if (RD_NWR == 1) begin
        for (x=0; x<FC_NUM_RGN; x=x+1) begin
          for (y=0; y<FC_NUM_MPE; y=y+1) begin
            if (y==0 && rgn_st_i[(x*RGN_ST_WIDTH) + 1]) begin 
              mpl0_read[0] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +6]; 
              mpl0_read[1] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +9]; 
              mpl0_read[2] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +0]; 
              mpl0_read[3] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +3]; 
              mpl0_read[4] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +8]; 
              mpl0_read[5] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH)+11]; 
              mpl0_read[6] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +2]; 
              mpl0_read[7] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +5]; 
              mpl0_matched[x] = mpl0_read[axprot_s_i];

            end else if (y==1 && rgn_st_i[(x*RGN_ST_WIDTH) + 2]) begin
              mpl1_read[0] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +6]; 
              mpl1_read[1] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +9]; 
              mpl1_read[2] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +0]; 
              mpl1_read[3] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +3]; 
              mpl1_read[4] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +8]; 
              mpl1_read[5] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)+11]; 
              mpl1_read[6] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +2]; 
              mpl1_read[7] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)  +5]; 
              mpl1_matched[x] = mpl1_read[axprot_s_i] ;

            end else if (y==2 && rgn_st_i[(x*RGN_ST_WIDTH) + 3]) begin
              mpl2_read[0] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +6]; 
              mpl2_read[1] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +9]; 
              mpl2_read[2] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +0]; 
              mpl2_read[3] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +3]; 
              mpl2_read[4] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +8]; 
              mpl2_read[5] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)+11]; 
              mpl2_read[6] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +2]; 
              mpl2_read[7] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)  +5]; 
              mpl2_matched[x] = mpl2_read[axprot_s_i];

            end else if (y==3 && rgn_st_i[(x*RGN_ST_WIDTH)+4]) begin
              mpl3_read[0] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +6]; 
              mpl3_read[1] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +9]; 
              mpl3_read[2] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +0]; 
              mpl3_read[3] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +3]; 
              mpl3_read[4] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +8]; 
              mpl3_read[5] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH)+11]; 
              mpl3_read[6] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +2]; 
              mpl3_read[7] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +5]; 
              mpl3_matched[x] = mpl3_read[axprot_s_i];
            end
          end 
        end 
      end else if (RD_NWR == 0) begin 
        for (x=0; x<FC_NUM_RGN; x=x+1) begin
          for (y=0; y<FC_NUM_MPE; y=y+1) begin
            if (y==0 && rgn_st_i[(x*RGN_ST_WIDTH)+1]) begin
              mpl0_write[0] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +7]; 
              mpl0_write[1] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH)+10]; 
              mpl0_write[2] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +1]; 
              mpl0_write[3] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +4]; 
              mpl0_write[4] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +8]; 
              mpl0_write[5] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH)+11]; 
              mpl0_write[6] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +2]; 
              mpl0_write[7] = rgn_mpl0_i[(x*RGN_MPL0_WIDTH) +5]; 
              mpl0_matched[x] = mpl0_write[axprot_s_i];

            end else if (y==1 && rgn_st_i[(x*RGN_ST_WIDTH)+2]) begin
              mpl1_write[0] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +7]; 
              mpl1_write[1] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)+10]; 
              mpl1_write[2] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +1]; 
              mpl1_write[3] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +4]; 
              mpl1_write[4] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +8]; 
              mpl1_write[5] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH)+11]; 
              mpl1_write[6] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +2]; 
              mpl1_write[7] = rgn_mpl1_i[(x*RGN_MPL1_WIDTH) +5]; 

              mpl1_matched[x] = mpl1_write[axprot_s_i]; 

            end else if (y==2 && rgn_st_i[(x*RGN_ST_WIDTH)+3]) begin
              mpl2_write[0] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +7]; 
              mpl2_write[1] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)+10]; 
              mpl2_write[2] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +1]; 
              mpl2_write[3] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +4]; 
              mpl2_write[4] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +8]; 
              mpl2_write[5] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH)+11]; 
              mpl2_write[6] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +2]; 
              mpl2_write[7] = rgn_mpl2_i[(x*RGN_MPL2_WIDTH) +5]; 
              mpl2_matched[x] = mpl2_write[axprot_s_i];

            end else if (y==3 && rgn_st_i[(x*RGN_ST_WIDTH)+4]) begin
              mpl3_write[0] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +7]; 
              mpl3_write[1] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH)+10]; 
              mpl3_write[2] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +1]; 
              mpl3_write[3] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +4]; 
              mpl3_write[4] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +8]; 
              mpl3_write[5] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH)+11]; 
              mpl3_write[6] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +2]; 
              mpl3_write[7] = rgn_mpl3_i[(x*RGN_MPL3_WIDTH) +5]; 
              mpl3_matched[x] = mpl3_write[axprot_s_i];
            end
          end 
        end 
      end 
    end 

    always @*
    begin: mid_cmp
      integer x;
      integer y;
      mid0_matched = {FC_NUM_RGN{1'b0}};
      mid1_matched = {FC_NUM_RGN{1'b0}};
      mid2_matched = {FC_NUM_RGN{1'b0}};
      mid3_matched = {FC_NUM_RGN{1'b0}};

      if (FC_SINGLE_MST==0) begin
        for (x=0; x<FC_NUM_RGN; x=x+1) begin
          for (y=0; y<FC_NUM_MPE; y=y+1) begin
            if (y==0 && rgn_st_i[(x*RGN_ST_WIDTH) + 1]) begin 
              mid0_matched[x] = ((rgn_mpl0_i[(x*RGN_MPL0_WIDTH)+12]) ||  
                                 (axmmusid_s_i == rgn_mid0_i[(x*FC_MST_ID_WIDTH)+FC_MST_ID_WIDTH-1 -: FC_MST_ID_WIDTH]));
            end else if (y==1 && rgn_st_i[(x*RGN_ST_WIDTH)+2]) begin
              mid1_matched[x] = (axmmusid_s_i == rgn_mid1_i[(x*FC_MST_ID_WIDTH)+FC_MST_ID_WIDTH-1 -:FC_MST_ID_WIDTH]);
            end else if (y==2 && rgn_st_i[(x*RGN_ST_WIDTH)+3]) begin
              mid2_matched[x] = (axmmusid_s_i == rgn_mid2_i[(x*FC_MST_ID_WIDTH)+FC_MST_ID_WIDTH-1 -: FC_MST_ID_WIDTH]);
            end else if (y==3 && rgn_st_i[(x*RGN_ST_WIDTH)+4]) begin
              mid3_matched[x] = (axmmusid_s_i == rgn_mid3_i[(x*FC_MST_ID_WIDTH)+FC_MST_ID_WIDTH-1 -: FC_MST_ID_WIDTH]);
            end
          end 
        end 
      end else begin 
        for (x=0; x<FC_NUM_RGN; x=x+1) begin 
            if (rgn_st_i[(x*RGN_ST_WIDTH) + 1]) begin 
              mid0_matched[x] = 1'b1;  
            end
        end 
      end 
    end 

    always @*
    begin: mid_final
      integer x;
      integer y;

      mult_mid_found = 1'b0;

      if (FC_SINGLE_MST == 0) begin
        region_mid0_matched = region_addr_matched & mid0_matched;
        region_mid1_matched = region_addr_matched & mid1_matched;
        region_mid2_matched = region_addr_matched & mid2_matched;
        region_mid3_matched = region_addr_matched & mid3_matched;

        same_region_mult_mid = {FC_NUM_MPE{1'b0}};

        for (x=0; x<FC_NUM_RGN; x=x+1) begin
          region_mid_matched[0] = region_mid0_matched[x];
          region_mid_matched[1] = region_mid1_matched[x];
          region_mid_matched[2] = region_mid2_matched[x];
          region_mid_matched[3] = region_mid3_matched[x];
          for (y=0; y<FC_NUM_MPE; y=y+1) begin
            same_region_mult_mid[y] = region_mid_matched[y];

          end 
          if (same_region_mult_mid == 4'b0011 ||
              same_region_mult_mid == 4'b0101 ||
              same_region_mult_mid == 4'b0110 ||
              same_region_mult_mid == 4'b0111 ||
              same_region_mult_mid == 4'b1001 ||
              same_region_mult_mid == 4'b1010 ||
              same_region_mult_mid == 4'b1011 ||
              same_region_mult_mid == 4'b1100 ||
              same_region_mult_mid == 4'b1101 ||
              same_region_mult_mid == 4'b1110 ||
              same_region_mult_mid == 4'b1111) begin
            mult_mid_found = ((x == 0) && (FC_PE_LVL == 2)) ? default_rgn_only_match : 1'b1;
          end
        end 
      end else begin 
        region_mid0_matched = region_addr_matched & mid0_matched;
        region_mid1_matched = region_addr_matched & mid1_matched; 
        region_mid2_matched = region_addr_matched & mid2_matched; 
        region_mid3_matched = region_addr_matched & mid3_matched; 
      end
    end 

    assign mult_rgn_mid_ovlp =  region_mid0_matched | region_mid1_matched | region_mid2_matched | region_mid3_matched;


  if (FC_NUM_RGN ==1) begin : NUM_RGN1

    always @*
    begin: uniq
      integer x;
      integer y;
      integer match_1;
      integer match_2;
      reg match_1_found;
      reg match_2_found;

      default_rgn_only_match = 1'b0;
      first_rgn_mid_matched = 1'b0;
      second_rgn_mid_matched = 1'b0;
      match_1_found = 1'b0;
      match_2_found = 1'b0;
      match_1=0;
      match_2=0;

      if (FC_PE_LVL==1) begin
        for (x=0; x<FC_NUM_RGN; x=x+1) begin  
          if (mult_rgn_mid_ovlp[x]) begin
            match_1 = x;
            match_1_found = 1'b1;
          end
        end

        for (y=FC_NUM_RGN-1; y>=0; y=y-1) begin  
          if (mult_rgn_mid_ovlp[y]) begin
            match_2 = y;
            match_2_found = 1'b1;
          end
        end
        if (match_1_found && match_2_found && (match_1 == match_2)) begin
          first_rgn_mid_matched = 1'b1;
          second_rgn_mid_matched = 1'b0;
        end else if (match_1_found && match_2_found ) begin
          first_rgn_mid_matched = 1'b1;
          second_rgn_mid_matched = 1'b1;
        end
      end else if (FC_PE_LVL==2) begin
        if (mult_rgn_mid_ovlp[0]) begin
          first_rgn_mid_matched = 1'b1;
          second_rgn_mid_matched = 1'b0;
          default_rgn_only_match = 1'b1;
        end
      end

      if (first_rgn_mid_matched & ~second_rgn_mid_matched) begin
        unique_rgn_mid_matched = 1'b1;
        mult_rgn_mid_matched = 1'b0;
      end else if (second_rgn_mid_matched) begin
        unique_rgn_mid_matched = 1'b0;
        mult_rgn_mid_matched = 1'b1;
      end else begin
        unique_rgn_mid_matched = 1'b0;
        mult_rgn_mid_matched = 1'b0;
      end

    end 


  end else begin : NUM_RGN_NOT_1 


    always @*
    begin: uniq
    integer x;
    integer y;
    integer match_1;
    integer match_2;
    reg match_1_found;
    reg match_2_found;

      default_rgn_only_match = 1'b0;
      first_rgn_mid_matched = 1'b0;
      second_rgn_mid_matched = 1'b0;
      match_1_found = 1'b0;
      match_2_found = 1'b0;
      match_1=0;
      match_2=0;

      if (FC_PE_LVL==1) begin
        for (x=0; x<FC_NUM_RGN; x=x+1) begin  
          if (mult_rgn_mid_ovlp[x]) begin
            match_1 = x;
            match_1_found = 1'b1;
          end
        end

        for (y=FC_NUM_RGN-1; y>=0; y=y-1) begin  
          if (mult_rgn_mid_ovlp[y]) begin
            match_2 = y;
            match_2_found = 1'b1;
          end
        end
        if (match_1_found && match_2_found && (match_1 == match_2)) begin
          first_rgn_mid_matched = 1'b1;
          second_rgn_mid_matched = 1'b0;
        end else if (match_1_found && match_2_found ) begin
          first_rgn_mid_matched = 1'b1;
          second_rgn_mid_matched = 1'b1;
        end
      end else if (FC_PE_LVL==2) begin
          if (mult_rgn_mid_ovlp[0] && rgn_st_i[0] && ~|(mult_rgn_mid_ovlp[FC_NUM_RGN-1:1])) begin  
            first_rgn_mid_matched = 1'b1;
            second_rgn_mid_matched = 1'b0;
            default_rgn_only_match = 1'b1;

          end else begin
            for (x=1; x<FC_NUM_RGN; x=x+1) begin  
              if (mult_rgn_mid_ovlp[x]) begin
                match_1 = x;
                match_1_found = 1'b1;
              end
            end

            for (y=FC_NUM_RGN-1; y>=1; y=y-1) begin  
              if (mult_rgn_mid_ovlp[y]) begin
                match_2 = y;
                match_2_found = 1'b1;
              end
            end
            if (match_1_found && match_2_found && (match_1 == match_2)) begin
              first_rgn_mid_matched = 1'b1;
              second_rgn_mid_matched = 1'b0;
            end else if (match_1_found && match_2_found ) begin
              first_rgn_mid_matched = 1'b1;
              second_rgn_mid_matched = 1'b1;
            end
          end
      end

      if (first_rgn_mid_matched & ~second_rgn_mid_matched) begin
        unique_rgn_mid_matched = 1'b1;
        mult_rgn_mid_matched = 1'b0;
      end else if (second_rgn_mid_matched) begin
        unique_rgn_mid_matched = 1'b0;
        mult_rgn_mid_matched = 1'b1;
      end else begin
        unique_rgn_mid_matched = 1'b0;
        mult_rgn_mid_matched = 1'b0;
      end

    end 
  end

    assign mpl_match = mpl_match_0 | mpl_match_1 | mpl_match_2 | mpl_match_3;
    always @*
    begin: mpl_mch
    integer x;
    integer y;

      mpl_match_0 = 1'b0;
      mpl_match_1 = 1'b0;
      mpl_match_2 = 1'b0;
      mpl_match_3 = 1'b0;

      rgn_number_o    = {LOG2_FC_NUM_RGN{1'b0}};

      if (FC_PE_LVL == 1) begin
        if (unique_rgn_mid_matched)  begin 
          for (x=0; x<FC_NUM_RGN; x=x+1) begin
            for (y=0; y<FC_NUM_MPE; y=y+1) begin

              if (y==0) begin
                if (region_mid0_matched[x]) begin
                  mpl_match_0 = mpl0_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==1) begin
                if (region_mid1_matched[x]) begin
                  mpl_match_1 = mpl1_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==2) begin
                if (region_mid2_matched[x]) begin
                  mpl_match_2 = mpl2_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==3) begin
                if (region_mid3_matched[x]) begin
                  mpl_match_3 = mpl3_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end 
              end 
            end 
          end 
        end 
      end else if (FC_PE_LVL == 2) begin 
        if (unique_rgn_mid_matched && !default_rgn_only_match)  begin 
          for (x=1; x<FC_NUM_RGN; x=x+1) begin 
            for (y=0; y<FC_NUM_MPE; y=y+1) begin

             if (y==0) begin
                if (region_mid0_matched[x]) begin
                  mpl_match_0 = mpl0_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==1) begin
                if (region_mid1_matched[x]) begin
                  mpl_match_1 = mpl1_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==2) begin
                if (region_mid2_matched[x]) begin
                  mpl_match_2 = mpl2_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end
              end else
              if (y==3) begin
                if (region_mid3_matched[x]) begin
                  mpl_match_3 = mpl3_matched[x];
                  rgn_number_o = x[LOG2_FC_NUM_RGN-1:0];
                end 
              end 
            end 
          end 
        end else if (unique_rgn_mid_matched && default_rgn_only_match)  begin
            for (y=0; y<FC_NUM_MPE; y=y+1) begin

             if (y==0) begin
                if (region_mid0_matched[0]) begin
                  mpl_match_0 = mpl0_matched[0];
                  rgn_number_o = {LOG2_FC_NUM_RGN{1'b0}};
                end
              end else
              if (y==1) begin
                if (region_mid1_matched[0]) begin
                  mpl_match_1 = mpl1_matched[0];
                  rgn_number_o = {LOG2_FC_NUM_RGN{1'b0}};
                end
              end else
              if (y==2) begin
                if (region_mid2_matched[0]) begin
                  mpl_match_2 = mpl2_matched[0];
                  rgn_number_o = {LOG2_FC_NUM_RGN{1'b0}};
                end
              end else
              if (y==3) begin
                if (region_mid3_matched[0]) begin
                  mpl_match_3 = mpl3_matched[0];
                  rgn_number_o = {LOG2_FC_NUM_RGN{1'b0}};
                end 
              end 
            end 
        end 
      end 
    end 

    always @*
    begin : filter_result
      if (axvalid_s_i) begin
        if (~pe_st_en_i && ~bypass_i) begin 
          filter_result_val_o = ACCESS_ERR;
        end else if (bypass_i) begin 
          filter_result_val_o = OKAY;
        end else if (~prot_size_result_pe2) begin  
          filter_result_val_o = ACCESS_ERR;
        end else if (mult_mid_found) begin
          filter_result_val_o = PROG_ERR;
        end else if (mult_rgn_mid_matched) begin
          filter_result_val_o = PROG_ERR;
        end else if (~mult_rgn_mid_matched && ~unique_rgn_mid_matched) begin
          filter_result_val_o = ACCESS_ERR;
        end else if (unique_rgn_mid_matched && mpl_match) begin
          filter_result_val_o = OKAY;
        end else begin
          filter_result_val_o = ACCESS_ERR;
        end
      end else begin
        filter_result_val_o = IDLE;
      end 


    end 

    always @*
    begin: op_assign
      if (filter_result_val_o == OKAY) begin
        axid_te_o       = axid_s_i    ;
        axaddr_te_o     = axaddr_s_i  ;
        axlen_te_o      = axlen_s_i   ;
        axsize_te_o     = axsize_s_i  ;
        axburst_te_o    = axburst_s_i ;
        axlock_te_o     = axlock_s_i  ;
        axcache_te_o    = axcache_s_i ;
        axprot_te_o     = axprot_s_i  ;
        axqos_te_o      = axqos_s_i   ;
        axregion_te_o   = axregion_s_i;
        axuser_te_o     = axuser_s_i  ;
        axvalid_te_o    = axvalid_s_i ;
        axmmusid_te_o   = axmmusid_s_i;
        axready_s_o     = axready_te_i;
        filter_result_vld_te_o = axvalid_s_i;

        axid_fh_o     = {FC_AXIID_WIDTH{1'b0}};
        axaddr_fh_o   = {FC_ADDR_WIDTH{1'b0}};
        axlen_fh_o    = {8{1'b0}};
        axprot_fh_o   = {3{1'b0}};
        axvalid_fh_o  = 1'b0;
        axmmusid_fh_o = {FC_MST_ID_WIDTH{1'b0}};
        filter_result_vld_fh_o = 1'b0;

      end else begin
        axid_fh_o     = axid_s_i    ;
        axaddr_fh_o   = axaddr_s_i  ;
        axlen_fh_o    = axlen_s_i   ;
        axprot_fh_o   = axprot_s_i  ;
        axvalid_fh_o  = axvalid_s_i ;
        axmmusid_fh_o = axmmusid_s_i;
        axready_s_o   = axready_fh_i;
        filter_result_vld_fh_o = axvalid_s_i;

        axid_te_o     = {FC_AXIID_WIDTH{1'b0}};
        axaddr_te_o   = {FC_ADDR_WIDTH{1'b0}};
        axlen_te_o    = {8{1'b0}};
        axsize_te_o   = {3{1'b0}};
        axburst_te_o  = {2{1'b0}};
        axlock_te_o   = 1'b0;
        axcache_te_o  = {4{1'b0}};
        axprot_te_o   = {3{1'b0}};
        axqos_te_o    = {4{1'b0}};
        axregion_te_o = {4{1'b0}};
        axuser_te_o   = {FC_AXIUSER_AX_WIDTH{1'b0}};
        axvalid_te_o  = 1'b0;
        axmmusid_te_o = {FC_MST_ID_WIDTH{1'b0}};
        filter_result_vld_te_o = 1'b0;

      end
    end 

  end
endgenerate

endmodule
