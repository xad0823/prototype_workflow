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

module firewall_f0_ax_translator#(
  parameter FC_PE_LVL           = 0,
  parameter FC_TE_LVL           = 0,
  parameter FC_RD_FLT           = 0, 
  parameter FC_AXIUSER_AX_WIDTH = 1,
  parameter LOG2_FC_NUM_RGN     = 2,
  parameter FC_NUM_RGN          = 4,
  parameter FC_AXIID_WIDTH      = 9,
  parameter FC_ADDR_WIDTH       = 64,
  parameter FC_MST_ID_WIDTH     = 8,
  parameter PROT_SIZE_WIDTH     = 8,
  parameter RGN_SIZE_WIDTH      = 9,
  parameter RGN_TCFG0_WIDTH     = 27,
  parameter RGN_TCFG1_WIDTH     = 32,
  parameter RGN_TCFG2_WIDTH     = 18
)
(
  input  wire [FC_AXIID_WIDTH-1:0]               axid_flt_i,
  input  wire [FC_ADDR_WIDTH-1:0]                axaddr_flt_i,
  input  wire [7:0]                              axlen_flt_i,
  input  wire [2:0]                              axsize_flt_i,
  input  wire [1:0]                              axburst_flt_i,
  input  wire                                    axlock_flt_i,
  input  wire [3:0]                              axcache_flt_i,
  input  wire [2:0]                              axprot_flt_i,
  input  wire [3:0]                              axqos_flt_i,
  input  wire [3:0]                              axregion_flt_i,
  input  wire [FC_AXIUSER_AX_WIDTH-1:0]          axuser_flt_i,
  input  wire                                    axvalid_flt_i,
  output wire                                    axready_flt_o,
  input  wire [FC_MST_ID_WIDTH-1:0]              axmmusid_flt_i,

  output wire [FC_AXIID_WIDTH-1:0]               axid_m_o,
  output wire [FC_ADDR_WIDTH-1:0]                axaddr_m_o,
  output wire [7:0]                              axlen_m_o,
  output wire [2:0]                              axsize_m_o,
  output wire [1:0]                              axburst_m_o,
  output wire                                    axlock_m_o,
  output wire [3:0]                              axcache_m_o,
  output wire [2:0]                              axprot_m_o,
  output wire [3:0]                              axqos_m_o,
  output wire [3:0]                              axregion_m_o,
  output wire [FC_AXIUSER_AX_WIDTH-1:0]          axuser_m_o,
  output wire                                    axvalid_m_o,
  input  wire                                    axready_m_i,
  output wire [FC_MST_ID_WIDTH-1:0]              axmmusid_m_o,

  input  wire [LOG2_FC_NUM_RGN-1:0]              rgn_number_i,

  input  wire                                    rb_bypass_status,
  input  wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  rb_rgn_size_i,
  input  wire [PROT_SIZE_WIDTH-1:0]              rb_prot_size_i,
  input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rb_cfg_rgn_tcfg0_i,
  input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rb_cfg_rgn_tcfg1_i,
  input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rb_cfg_rgn_tcfg2_i

);


  localparam [2:0] DEVICE_NGNRNE  = 3'd0;
  localparam [2:0] DEVICE_NGNRE   = 3'd1;
  localparam [2:0] DEVICE_NGRE    = 3'd2;
  localparam [2:0] DEVICE_GRE     = 3'd3;
  localparam [2:0] NORMAL         = 3'd4;

  localparam [3:0] DEVICE_NB     = 4'b0000;
  localparam [3:0] DEVICE_B      = 4'b0001;
  localparam [3:0] NORMAL_NCNB   = 4'b0010;
  localparam [3:0] NORMAL_NCB    = 4'b0011;
  localparam [3:0] WTNA          = (FC_RD_FLT == 1) ? 4'b1010 : 4'b0110;
  localparam [3:0] WTRA_1        = (FC_RD_FLT == 1) ? 4'b1110 : 4'b0110;
  localparam [3:0] WTRA_2        = (FC_RD_FLT == 1) ? 4'b0110 : 4'b0110; 
  localparam [3:0] WTWA_1        = (FC_RD_FLT == 1) ? 4'b1010 : 4'b1110;
  localparam [3:0] WTWA_2        = (FC_RD_FLT == 1) ? 4'b1010 : 4'b1010; 
  localparam [3:0] WTRWA         = (FC_RD_FLT == 1) ? 4'b1110 : 4'b1110;
  localparam [3:0] WBNA          = (FC_RD_FLT == 1) ? 4'b1011 : 4'b0111;
  localparam [3:0] WBRA_1        = (FC_RD_FLT == 1) ? 4'b1111 : 4'b0111;
  localparam [3:0] WBRA_2        = (FC_RD_FLT == 1) ? 4'b0111 : 4'b0111; 
  localparam [3:0] WBWA_1        = (FC_RD_FLT == 1) ? 4'b1011 : 4'b1111;
  localparam [3:0] WBWA_2        = (FC_RD_FLT == 1) ? 4'b1011 : 4'b1011; 
  localparam [3:0] WBRWA         = (FC_RD_FLT == 1) ? 4'b1111 : 4'b1111;

  localparam [1:0] NA            = 2'd0; 
  localparam [1:0] WT            = 2'd1; 
  localparam [1:0] NC            = 2'd2; 
  localparam [1:0] WB            = 2'd3; 


  function [2:0] get_fw_attribute;
    input [5:0] ma_value;
    case (ma_value)
      {4'b0000, 2'b00} : get_fw_attribute = DEVICE_NGNRNE;
      {4'b0000, 2'b01} : get_fw_attribute = DEVICE_NGNRE;
      {4'b0000, 2'b10} : get_fw_attribute = DEVICE_NGRE;
      {4'b0000, 2'b11} : get_fw_attribute = DEVICE_GRE;
      default          : get_fw_attribute = NORMAL;
    endcase
  endfunction

  function [1:0] get_outer_cacheability;
    input [3:0] ma_value;
    if (ma_value[3:2] == 2'b00 && ma_value[1:0] != 2'b00) begin
      get_outer_cacheability = WT;
    end
    else if (ma_value[3:2] == 2'b01 && ma_value[1:0] == 2'b00) begin
      get_outer_cacheability = NC;
    end
    else if (ma_value[3:2] == 2'b01 && ma_value[1:0] != 2'b00) begin
      get_outer_cacheability = WB;
    end
    else if (ma_value[3:2] == 2'b10) begin
      get_outer_cacheability = WT;
    end
    else if (ma_value[3:2] == 2'b11) begin
      get_outer_cacheability = WB;
    end
    else begin
      get_outer_cacheability = NA;
    end
  endfunction

  function [1:0] get_inner_cacheability;
    input [3:0] ma_value;
    if (ma_value[3:2] == 2'b00) begin
      get_inner_cacheability = WT;
    end
    else if (ma_value[3:2] == 2'b01 && ma_value[1:0] == 2'b00) begin
      get_inner_cacheability = NC;
    end
    else if (ma_value[3:2] == 2'b01 && ma_value[1:0] != 2'b00) begin
      get_inner_cacheability = WB;
    end
    else if (ma_value[3:2] == 2'b10) begin
      get_inner_cacheability = WT;
    end
    else begin
      get_inner_cacheability = WB;
    end
  endfunction

localparam RAB = 32-RGN_TCFG0_WIDTH; 

generate
  if (FC_TE_LVL == 0 && FC_PE_LVL > 0) begin : NO_TE

    reg  [3:0]                  axcache_m_o_translated;

    always @* begin
      if (axcache_flt_i == NORMAL_NCNB || axcache_flt_i == WTNA ||
          axcache_flt_i == WTRA_1 || axcache_flt_i == WTRA_2 ||
          axcache_flt_i == WTWA_1 || axcache_flt_i == WTWA_2 ||
          axcache_flt_i == WTRWA) begin
        axcache_m_o_translated = NORMAL_NCB;
      end
      else if (FC_RD_FLT == 1 && axcache_flt_i == WBRA_2) begin
        axcache_m_o_translated = WBRA_1;
      end
      else if (FC_RD_FLT == 0 && axcache_flt_i == WBWA_2) begin
        axcache_m_o_translated = WBWA_1;
      end
      else begin
        axcache_m_o_translated = axcache_flt_i;
      end

    end

    assign axid_m_o       = axid_flt_i    ;
    assign axaddr_m_o     = axaddr_flt_i  ;
    assign axlen_m_o      = axlen_flt_i   ;
    assign axsize_m_o     = axsize_flt_i  ;
    assign axburst_m_o    = axburst_flt_i ;
    assign axlock_m_o     = axlock_flt_i  ;
    assign axcache_m_o    = axcache_m_o_translated;
    assign axprot_m_o     = axprot_flt_i  ;
    assign axqos_m_o      = axqos_flt_i   ;
    assign axregion_m_o   = axregion_flt_i;
    assign axuser_m_o     = axuser_flt_i  ;
    assign axvalid_m_o    = axvalid_flt_i ;
    assign axready_flt_o  = axready_m_i   ;
    assign axmmusid_m_o   = axmmusid_flt_i;

  end else if (FC_TE_LVL == 0 && FC_PE_LVL == 0) begin : NO_TE_PE
    assign axid_m_o       = axid_flt_i    ;
    assign axaddr_m_o     = axaddr_flt_i  ;
    assign axlen_m_o      = axlen_flt_i   ;
    assign axsize_m_o     = axsize_flt_i  ;
    assign axburst_m_o    = axburst_flt_i ;
    assign axlock_m_o     = axlock_flt_i  ;
    assign axcache_m_o    = axcache_flt_i ;
    assign axprot_m_o     = axprot_flt_i  ;
    assign axqos_m_o      = axqos_flt_i   ;
    assign axregion_m_o   = axregion_flt_i;
    assign axuser_m_o     = axuser_flt_i  ;
    assign axvalid_m_o    = axvalid_flt_i ;
    assign axready_flt_o  = axready_m_i   ;
    assign axmmusid_m_o   = axmmusid_flt_i;

  end else if (FC_TE_LVL > 0) begin : TE

    reg                         axlock_m_o_translated;
    reg  [3:0]                  axcache_m_o_translated;
    reg  [2:0]                  axprot_m_o_translated;

    wire [FC_ADDR_WIDTH-1:0]    ita; 
    reg  [FC_ADDR_WIDTH-1:0]    ta;  
    reg  [FC_ADDR_WIDTH-1:0]    ota; 


    wire                        rb_mulnpo2_i;
    wire [7:0]                  rb_rgn_size;
    wire [RGN_TCFG0_WIDTH-1:0]  rb_upperbits_lower_i;
    wire [RGN_TCFG1_WIDTH-1:0]  rb_upperbits_upper_i;
    wire                        rb_addr_trans_en_i;
    wire                        rb_ma_trans_en_i;
    wire [7:0]                  rb_ma_reg_value_i;
    wire [1:0]                  rb_sec_reg_value_i;
    wire [1:0]                  rb_inst_reg_value_i;
    wire [1:0]                  rb_prv_reg_value_i;

    reg  [2:0]                  fw;
    reg  [1:0]                  inner;
    reg  [1:0]                  outer;


    assign rb_mulnpo2_i          = rb_rgn_size_i[(RGN_SIZE_WIDTH*rgn_number_i)+8];
    assign rb_rgn_size           = rb_rgn_size_i[(RGN_SIZE_WIDTH*rgn_number_i)+:8];
    assign rb_upperbits_lower_i  = rb_cfg_rgn_tcfg0_i[(RGN_TCFG0_WIDTH*rgn_number_i)+:RGN_TCFG0_WIDTH];
    assign rb_upperbits_upper_i  = rb_cfg_rgn_tcfg1_i[(RGN_TCFG1_WIDTH*rgn_number_i)+:RGN_TCFG1_WIDTH];
    assign rb_addr_trans_en_i    = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+17];
    assign rb_ma_trans_en_i      = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+16];

    assign rb_inst_reg_value_i   = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+14+:2];
    assign rb_prv_reg_value_i    = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+12+:2];
    assign rb_ma_reg_value_i     = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+ 4+:8];
    assign rb_sec_reg_value_i    = rb_cfg_rgn_tcfg2_i[(RGN_TCFG2_WIDTH*rgn_number_i)+ 0+:2];


    assign ita = axaddr_flt_i;
    always@(*)
    begin : TA_ASSIGNMENT
      integer i;
      for(i=0;i<FC_ADDR_WIDTH;i=i+1) begin
        if (i < RAB) begin 
          ta[i] = 1'b0;
        end else if (i < 32) begin 
          ta[i] = rb_upperbits_lower_i[i-RAB];
        end else begin
          ta[i] = rb_upperbits_upper_i[i-32];
        end
      end
    end

    always@(*)
    begin : OTA_ASSIGNMENT
      if (rb_bypass_status) begin : BYPASS
        ota = ita;
      end else if((FC_TE_LVL          == 2) &&
                  (rb_mulnpo2_i       == 1'b0) &&
                  (rb_addr_trans_en_i == 1'b1)) begin : TRANSLATE

        integer i;
        for(i=0;i<FC_ADDR_WIDTH;i=i+1) begin
          if (i < rb_rgn_size) begin             
            ota[i] = ita[i];
          end else if (i < rb_prot_size_i) begin 
            ota[i] = ta[i];
          end else begin                         
            ota[i] = ita[i];
          end
        end
      end else begin : NO_ACTION
        ota = ita;
      end
    end

    always@(*)
    begin : CACHE_TRANSLATION


      fw = get_fw_attribute(rb_ma_reg_value_i[7:2]);

      inner = get_inner_cacheability(rb_ma_reg_value_i[3:0]);

      outer = get_outer_cacheability(rb_ma_reg_value_i[7:4]);


      axlock_m_o_translated = axlock_flt_i;

      if (!(rb_bypass_status) && 
          (rb_ma_trans_en_i && !rb_mulnpo2_i)) begin : TRANSLATE

        case (fw)
          DEVICE_NGNRNE  : axcache_m_o_translated = DEVICE_NB;

          DEVICE_NGNRE,
          DEVICE_NGRE,
          DEVICE_GRE     : axcache_m_o_translated = DEVICE_B;

          default        : if ((inner == NC && (outer == NC || outer == WT || outer == WB)) || 
                               (inner == WT && (outer == NC || outer == WT || outer == WB)) || 
                               (inner == WB && (outer == NC || outer == WT))) begin            
                             axcache_m_o_translated = NORMAL_NCB;
                           end else begin 
                             case (rb_ma_reg_value_i[1:0]) 
                               2'b00 : axcache_m_o_translated = WBNA;
                               2'b01 : axcache_m_o_translated = WBWA_1;
                               2'b10 : axcache_m_o_translated = WBRA_1;
                               2'b11 : axcache_m_o_translated = WBRWA;
                             endcase
                             axlock_m_o_translated = 1'b0;
                           end
        endcase


      end else begin : BYPASS

        if (axcache_flt_i == NORMAL_NCNB || axcache_flt_i == WTNA ||
            axcache_flt_i == WTRA_1 || axcache_flt_i == WTRA_2 ||
            axcache_flt_i == WTWA_1 || axcache_flt_i == WTWA_2 ||
            axcache_flt_i == WTRWA) begin
          axcache_m_o_translated = NORMAL_NCB;
        end
        else if (FC_RD_FLT==1 && axcache_flt_i == WBRA_2) begin
          axcache_m_o_translated = WBRA_1;
        end
        else if (FC_RD_FLT==0 && axcache_flt_i == WBWA_2) begin
          axcache_m_o_translated = WBWA_1;
        end
        else begin
          axcache_m_o_translated = axcache_flt_i;
        end
      end
    end

    always@(*)
    begin : PRIV_TRANSLATION
      if (rb_bypass_status) begin : BYPASS
        axprot_m_o_translated[0] = axprot_flt_i[0];
      end else if (rb_mulnpo2_i == 1'b0) begin : PRIV_TRANSLATE
        case (rb_prv_reg_value_i) 
          2'b10   : axprot_m_o_translated[0] = 1'b0; 
          2'b11   : axprot_m_o_translated[0] = 1'b1; 
          default : axprot_m_o_translated[0] = axprot_flt_i[0]; 
        endcase
      end else begin
        axprot_m_o_translated[0] = axprot_flt_i[0];
      end
    end


    always@(*)
    begin : SECURITY_TRANSLATION
      if (rb_bypass_status) begin : BYPASS
        axprot_m_o_translated[1] = axprot_flt_i[1];
      end else if ((axprot_flt_i[1]    == 1'b0) &&                       
                   (rb_sec_reg_value_i == 2'b11) &&                      
                   (rb_mulnpo2_i       == 1'b0)) begin : SEC_TRANSLATION 
        axprot_m_o_translated[1] = 1'b1; 
      end else begin 
        axprot_m_o_translated[1] = axprot_flt_i[1];
      end
    end

    always@(*)
    begin : INST_TRANSLATION
      if (rb_bypass_status) begin : BYPASS
        axprot_m_o_translated[2] = axprot_flt_i[2];
      end else if (rb_mulnpo2_i == 1'b0) begin : INST_TRANSLATION
        case (rb_inst_reg_value_i)
          2'b10   : axprot_m_o_translated[2] = 1'b0; 
          2'b11   : axprot_m_o_translated[2] = 1'b1; 
          default : axprot_m_o_translated[2] = axprot_flt_i[2];
        endcase
      end else begin
        axprot_m_o_translated[2] = axprot_flt_i[2];
      end
    end





    assign axid_m_o       = axid_flt_i;
    assign axaddr_m_o     = ota;
    assign axlen_m_o      = axlen_flt_i;
    assign axsize_m_o     = axsize_flt_i;
    assign axburst_m_o    = axburst_flt_i;
    assign axlock_m_o     = axlock_m_o_translated;
    assign axcache_m_o    = axcache_m_o_translated;
    assign axprot_m_o     = axprot_m_o_translated;
    assign axqos_m_o      = axqos_flt_i;
    assign axregion_m_o   = axregion_flt_i;
    assign axuser_m_o     = axuser_flt_i;
    assign axvalid_m_o    = axvalid_flt_i;
    assign axmmusid_m_o   = axmmusid_flt_i;

    assign axready_flt_o  = axready_m_i;


  end
endgenerate

endmodule
