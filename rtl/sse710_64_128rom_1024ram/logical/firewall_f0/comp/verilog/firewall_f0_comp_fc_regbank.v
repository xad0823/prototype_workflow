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

module firewall_f0_comp_fc_regbank #(
    parameter FC_ID                = 0,
    parameter FC_PE_LVL            = 2,
    parameter PE_CTRL_WIDTH        = 7,
    parameter PE_ST_WIDTH          = 7,
    parameter RWE_CTRL_WIDTH       = 8,
    parameter FC_NUM_RGN           = 4,
    parameter LOG2_FC_NUM_RGN      = 2,
    parameter RGN_CTRL0_WIDTH      = 1,
    parameter RGN_CTRL1_WIDTH      = 4,
    parameter FC_NUM_MPE           = 4,
    parameter RGN_LCTRL_WIDTH      = 1,
    parameter FW_LDE_LVL           = 0,
    parameter RGN_ST_WIDTH         = 5,
    parameter FC_MXRS              = 8,
    parameter FC_MNRS              = 2,
    parameter RGN_CFG0_WIDTH       = 27,
    parameter PE_BPS_WIDTH         = 3,
    parameter FC_RGN_BASE_ADDR     = {FC_NUM_RGN*FC_MXRS{1'b0}},
    parameter RGN_CFG1_WIDTH       = 32,
    parameter FC_RGN_UPR_ADDR      = {FC_NUM_RGN*FC_MXRS{1'b1}},
    parameter FC_RSE_LVL           = 1,
    parameter RGN_SIZE_WIDTH       = 16,
    parameter FC_RGN_MULNPO2       = {FC_NUM_RGN{1'b0}},
    parameter FC_RGN_SIZE          = {FC_NUM_RGN*8{1'b0}},
    parameter PROT_SIZE_WIDTH      = 8,
    parameter RGN_TCFG0_WIDTH      = 27,
    parameter FC_TE_LVL            = 0,
    parameter RGN_TCFG1_WIDTH      = 32,
    parameter RGN_TCFG2_WIDTH      = 18,
    parameter FC_MA_SPT            = 1,
    parameter FC_SH_SPT            = 0,
    parameter FC_INST_SPT          = 1,
    parameter FC_PRIV_SPT          = 1,
    parameter FC_SEC_SPT           = 1,
    parameter FC_SINGLE_MST        = 1,
    parameter FC_MST_ID_WIDTH      = 8,
    parameter RGN_MPL0_WIDTH       = 13,
    parameter RGN_MPL1_WIDTH       = 13,
    parameter RGN_MPL2_WIDTH       = 13,
    parameter RGN_MPL3_WIDTH       = 13,
    parameter FE_TAL_WIDTH         = 32,
    parameter FE_TAU_WIDTH         = 32,
    parameter FE_TP_WIDTH          = 4,
    parameter FE_CTRL_WIDTH        = 6,
    parameter IRQ_TYPE_WIDTH       = 5,
    parameter ME_CTRL_WIDTH        = 3,
    parameter ME_ST_WIDTH          = 3,
    parameter EDR_TAL_WIDTH        = 32,
    parameter EDR_TAU_WIDTH        = 32,
    parameter EDR_TP_WIDTH         = 4,
    parameter EDR_CTRL_WIDTH       = 3,
    parameter FC_ME_LVL            = 0,
    parameter LD_CTRL_WIDTH        = 3,
    parameter FC_MST_ID_SINGLE_MST = 0,
    parameter FW_SRE_LVL           = 1
) (
    input  wire                                    clk,
    input  wire                                    reset_n,

    input  wire                                    arvalid_i,
    input  wire                                    awvalid_i,
    input  wire                                    wvalid_i,
    input  wire                                    rvalid_i,
    input  wire                                    bvalid_i,

    input  wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_i,
    input  wire                                    pe_ctrl_en,
    output wire [PE_CTRL_WIDTH-1:0]                pe_ctrl_o,

    output wire [PE_ST_WIDTH-1:0]                  pe_st_o,

    input  wire                                    pe_bps_i,
    output wire [PE_BPS_WIDTH-1:0]                 pe_bps_o,

    input  wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_i,
    input  wire                                    rwe_ctrl_en,
    output wire [RWE_CTRL_WIDTH-1:0]               rwe_ctrl_o,

    input  wire [FC_NUM_RGN*RGN_CTRL0_WIDTH-1:0]   rgn_ctrl0_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_ctrl0_en,
    output wire [FC_NUM_RGN*RGN_CTRL0_WIDTH-1:0]   rgn_ctrl0_o,
    output wire [RGN_CTRL0_WIDTH-1:0]              rgn_ctrl0_rgn_o,

    input  wire [FC_NUM_RGN*RGN_CTRL1_WIDTH-1:0]   rgn_ctrl1_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_ctrl1_en,
    output wire [FC_NUM_RGN*RGN_CTRL1_WIDTH-1:0]   rgn_ctrl1_o,
    output wire [RGN_CTRL1_WIDTH-1:0]              rgn_ctrl1_rgn_o,

    input  wire [FC_NUM_RGN*RGN_LCTRL_WIDTH-1:0]   rgn_lctrl_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_lctrl_en,
    output wire [FC_NUM_RGN*RGN_LCTRL_WIDTH-1:0]   rgn_lctrl_o,
    output wire [RGN_LCTRL_WIDTH-1:0]              rgn_lctrl_rgn_o,

    output wire [FC_NUM_RGN*RGN_ST_WIDTH-1:0]      rgn_st_o,
    output wire [RGN_ST_WIDTH-1:0]                 rgn_st_rgn_o,

    input  wire [FC_NUM_RGN*RGN_CFG0_WIDTH-1:0]    rgn_cfg0_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_cfg0_en,
    output wire [FC_NUM_RGN*RGN_CFG0_WIDTH-1:0]    rgn_cfg0_o,
    output wire [RGN_CFG0_WIDTH-1:0]               rgn_cfg0_rgn_o,

    input  wire [FC_NUM_RGN*RGN_CFG1_WIDTH-1:0]    rgn_cfg1_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_cfg1_en,
    output wire [FC_NUM_RGN*RGN_CFG1_WIDTH-1:0]    rgn_cfg1_o,
    output wire [RGN_CFG1_WIDTH-1:0]               rgn_cfg1_rgn_o,

    input  wire [FC_NUM_RGN*RGN_SIZE_WIDTH-1:0]    rgn_size_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_size_en,
    output wire [FC_NUM_RGN*RGN_SIZE_WIDTH-1:0]    rgn_size_o,
    output wire [RGN_SIZE_WIDTH-1:0]               rgn_size_rgn_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_tcfg0_en,
    output wire [RGN_TCFG0_WIDTH-1:0]              rgn_tcfg0_rgn_o,
    output wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rgn_tcfg0_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_tcfg1_en,
    output wire [RGN_TCFG1_WIDTH-1:0]              rgn_tcfg1_rgn_o,
    output wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rgn_tcfg1_o,

    input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_tcfg2_en,
    output wire [RGN_TCFG2_WIDTH-1:0]              rgn_tcfg2_rgn_o,
    output wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rgn_tcfg2_o,

    input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid0_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mid0_en,
    output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid0_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rgn_mid0_rgn_o,

    input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid1_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mid1_en,
    output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid1_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rgn_mid1_rgn_o,

    input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid2_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mid2_en,
    output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid2_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rgn_mid2_rgn_o,

    input  wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid3_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mid3_en,
    output wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0]   rgn_mid3_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rgn_mid3_rgn_o,

    input  wire [FC_NUM_RGN*RGN_MPL0_WIDTH-1:0]    rgn_mpl0_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mpl0_en,
    output wire [FC_NUM_RGN*RGN_MPL0_WIDTH-1:0]    rgn_mpl0_o,
    output wire [RGN_MPL0_WIDTH-1:0]               rgn_mpl0_rgn_o,

    input  wire [FC_NUM_RGN*RGN_MPL1_WIDTH-1:0]    rgn_mpl1_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mpl1_en,
    output wire [FC_NUM_RGN*RGN_MPL1_WIDTH-1:0]    rgn_mpl1_o,
    output wire [RGN_MPL1_WIDTH-1:0]               rgn_mpl1_rgn_o,

    input  wire [FC_NUM_RGN*RGN_MPL2_WIDTH-1:0]    rgn_mpl2_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mpl2_en,
    output wire [FC_NUM_RGN*RGN_MPL2_WIDTH-1:0]    rgn_mpl2_o,
    output wire [RGN_MPL2_WIDTH-1:0]               rgn_mpl2_rgn_o,

    input  wire [FC_NUM_RGN*RGN_MPL3_WIDTH-1:0]    rgn_mpl3_i,
    input  wire [FC_NUM_RGN-1:0]                   rgn_mpl3_en,
    output wire [FC_NUM_RGN*RGN_MPL3_WIDTH-1:0]    rgn_mpl3_o,
    output wire [RGN_MPL3_WIDTH-1:0]               rgn_mpl3_rgn_o,

    input  wire [FE_TAL_WIDTH-1:0]                 fe_tal_rdch_i,
    input  wire [FE_TAU_WIDTH-1:0]                 fe_tau_rdch_i,
    input  wire [FE_TP_WIDTH-1:0]                  fe_tp_rdch_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              fe_mid_rdch_i,
    input  wire                                    fe_rdch_en,
    input  wire                                    fe_type_rdch_i,

    input  wire [FE_TAL_WIDTH-1:0]                 fe_tal_wrch_i,
    input  wire [FE_TAU_WIDTH-1:0]                 fe_tau_wrch_i,
    input  wire [FE_TP_WIDTH-1:0]                  fe_tp_wrch_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              fe_mid_wrch_i,
    input  wire                                    fe_wrch_en,
    input  wire                                    fe_type_wrch_i,

    output wire [FE_TAL_WIDTH-1:0]                 fe_tal_o,
    output wire [FE_TAU_WIDTH-1:0]                 fe_tau_o,
    output wire [FE_TP_WIDTH-1:0]                  fe_tp_o,
    output wire [FC_MST_ID_WIDTH-1:0]              fe_mid_o,

    input  wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_i,
    input  wire                                    fe_ctrl_en,
    output wire [FE_CTRL_WIDTH-1:0]                fe_ctrl_o,

    output wire [IRQ_TYPE_WIDTH-1:0]               cfg_irq_o,
    output wire                                    cfg_irq_valid_o,

    input  wire [ME_CTRL_WIDTH-1:0]                me_ctrl_i,
    input  wire                                    me_ctrl_en,
    output wire [ME_CTRL_WIDTH-1:0]                me_ctrl_o,

    output wire [ME_ST_WIDTH-1:0]                  me_st_o,

    input  wire [EDR_TAL_WIDTH-1:0]                edr_tal_i,
    input  wire                                    edr_tal_en,
    output wire [EDR_TAL_WIDTH-1:0]                edr_tal_o,

    input  wire [EDR_TAU_WIDTH-1:0]                edr_tau_i,
    input  wire                                    edr_tau_en,
    output wire [EDR_TAU_WIDTH-1:0]                edr_tau_o,

    input  wire [EDR_TP_WIDTH-1:0]                 edr_tp_i,
    input  wire                                    edr_tp_en,
    output wire [EDR_TP_WIDTH-1:0]                 edr_tp_o,

    input  wire [FC_MST_ID_WIDTH-1:0]              edr_mid_i,
    input  wire                                    edr_mid_en,
    output wire [FC_MST_ID_WIDTH-1:0]              edr_mid_o,

    input  wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_i,
    input  wire                                    edr_ctrl_en,
    output wire [EDR_CTRL_WIDTH-1:0]               edr_ctrl_o,

    input  wire                                    rd_edr_wen_i,
    input  wire [31:0]                             rd_edr_addr_lwr_i,
    input  wire [31:0]                             rd_edr_addr_uppr_i,
    input  wire [FC_MST_ID_WIDTH+4-1:0]            rd_edr_prop_i,
    input  wire                                    wr_edr_wen_i,
    input  wire [31:0]                             wr_edr_addr_lwr_i,
    input  wire [31:0]                             wr_edr_addr_uppr_i,
    input  wire [FC_MST_ID_WIDTH+4-1:0]            wr_edr_prop_i,

    input  wire [LD_CTRL_WIDTH-1:0]                ld_ctrl_i,
    input  wire                                    ld_ctrl_en,
    output wire [LD_CTRL_WIDTH-1:0]                ld_ctrl_o,

    input  wire [PROT_SIZE_WIDTH-1:0]              prot_size_i,
    input  wire                                    prot_size_en,
    output wire [PROT_SIZE_WIDTH-1:0]              prot_size_o,

    output wire [FC_NUM_RGN*FC_MXRS-1:0]           fc_base_addr_o,
    output wire [FC_NUM_RGN*FC_MXRS-1:0]           fc_upr_addr_o,

    output wire                                    fc_rb_lpi_discon_deny_o,

    input  wire                                    ax_tracker_empty,

    input  wire                                    default_state_i
  );

`include "firewall_f0_reset_values.vh"
`include "firewall_f0_log2.vh"


wire status_enable;
genvar i, j; 



generate
  if (FC_PE_LVL > 0) begin: PE_CTRL_PE_LVL_NOT_ZERO 
    reg [PE_CTRL_WIDTH-1:0] pe_ctrl_r;

    always @ (posedge clk or negedge reset_n) begin: PE_CTRL_REG
      if (!reset_n) begin
        pe_ctrl_r <= PE_CTRL_RST_VAL;
      end else begin
        if (default_state_i) begin
          pe_ctrl_r <= PE_CTRL_RST_VAL;
        end
        else if (pe_ctrl_en) begin
          pe_ctrl_r <= pe_ctrl_i;
        end
      end
    end

    assign pe_ctrl_o = pe_ctrl_r;

  end else begin: PE_CTRL_PE_LVL_ZERO 
    assign pe_ctrl_o = {PE_CTRL_WIDTH{1'b0}};
  end
endgenerate



generate
  if (FC_PE_LVL > 0) begin: PE_BPS_PE_LVL_NOT_ZERO
    wire pe_bps_bypass_if_st; 
    wire pe_bps_bypass_vld;   

    wire pe_st_bypass_msk;   
    wire pe_bps_bypass_st;    
    reg  pe_bps_bypass_st_reg;

    assign pe_st_bypass_msk = pe_st_o[5];

    assign pe_bps_bypass_if_st = pe_bps_i;

    assign pe_bps_bypass_st =
      (pe_bps_i) ? (pe_bps_i & (~pe_st_bypass_msk)) : 1'b0;

    assign pe_bps_bypass_vld = 1'b1;

    assign pe_bps_o = {pe_bps_bypass_vld,
                       pe_bps_bypass_st_reg,  
                       pe_bps_bypass_if_st};  

    always @(posedge clk or negedge reset_n) begin: UPDATE_STATUS_REGS
      if (!reset_n) begin
        pe_bps_bypass_st_reg <= 1'b0;
      end else begin
        if (default_state_i) begin
          pe_bps_bypass_st_reg <= 1'b0;
        end
        else if (!status_enable ) begin
          pe_bps_bypass_st_reg <= pe_bps_bypass_st ;
        end
      end
    end

  end else begin:PE_BPS_PE_LVL_ZERO

    assign pe_bps_o = {PE_BPS_WIDTH{1'b0}};
  end
endgenerate


localparam ACT_RWE_CTRL_WIDTH = LOG2_FC_NUM_RGN;

generate
  if (FC_PE_LVL > 0) begin: RWE_CTRL_PE_LVL_NOT_ZERO 
    reg [ACT_RWE_CTRL_WIDTH-1:0] rwe_ctrl_r;

    always @(posedge clk or negedge reset_n) begin: RWE_CTRL_REG
      if (!reset_n) begin
        rwe_ctrl_r <= {ACT_RWE_CTRL_WIDTH{1'b0}};
      end else begin
        if (default_state_i) begin
          rwe_ctrl_r <= {ACT_RWE_CTRL_WIDTH{1'b0}};
        end
        else if (rwe_ctrl_en) begin
          rwe_ctrl_r <= rwe_ctrl_i[ACT_RWE_CTRL_WIDTH-1:0];
        end
      end
    end

    if (RWE_CTRL_WIDTH > ACT_RWE_CTRL_WIDTH) begin: RWE_CTRL_APPEND_ZEROS
      assign rwe_ctrl_o =
        {{(RWE_CTRL_WIDTH-ACT_RWE_CTRL_WIDTH){1'b0}}, rwe_ctrl_r};
    end else begin: NOT_APPEND_ZEROS
      assign rwe_ctrl_o = rwe_ctrl_r;
    end

  end else begin: RWE_CTRL_PE_LVL_ZERO
    assign rwe_ctrl_o = {RWE_CTRL_WIDTH{1'b0}};
  end
endgenerate


generate
  if (FC_PE_LVL > 0) begin: RGN_CTRL0_PE_LVL_NOT_ZERO 
    reg [FC_NUM_RGN*RGN_CTRL0_WIDTH-1:0] rgn_ctrl0_r   ;
    reg [RGN_CTRL0_WIDTH-1:0]            rgn_ctrl0_curr_rgn;

    always @(posedge clk or negedge reset_n) begin: RGN_CTRL0_REG
      integer i; 
      if (!reset_n) begin
        rgn_ctrl0_r <= {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};
      end else begin
        for (i=0; i<FC_NUM_RGN; i=i+1) begin 
          if (default_state_i) begin
            rgn_ctrl0_r[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH] <= {RGN_CTRL0_WIDTH{1'b0}};
          end
          else if (rgn_ctrl0_en[i]) begin
            rgn_ctrl0_r[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH] <=
              rgn_ctrl0_i[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH];
          end
        end
      end
    end

    assign rgn_ctrl0_o     = rgn_ctrl0_r;

    always @(*) begin: RGN_CTRL0_CURRENT_RGN
      integer i;
      rgn_ctrl0_curr_rgn = {RGN_CTRL0_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_ctrl0_curr_rgn =
            rgn_ctrl0_o[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH];
        end
      end
    end

    assign rgn_ctrl0_rgn_o = rgn_ctrl0_curr_rgn;

  end else begin: RGN_CTRL0_PE_LVL_ZERO 
    assign rgn_ctrl0_o     = {FC_NUM_RGN*RGN_CTRL0_WIDTH{1'b0}};
    assign rgn_ctrl0_rgn_o = {RGN_CTRL0_WIDTH{1'b0}}           ;
  end
endgenerate


localparam ACT_RGN_CTRL1_WIDTH = FC_NUM_MPE;
localparam RGN_CTRL1_DIFF      = RGN_CTRL1_WIDTH - ACT_RGN_CTRL1_WIDTH;

generate
  if (FC_PE_LVL > 0) begin: RGN_CTRL1_PE_LVL_NOT_ZERO 
    reg [FC_NUM_RGN*ACT_RGN_CTRL1_WIDTH-1:0] rgn_ctrl1_r   ;
    reg [RGN_CTRL1_WIDTH-1:0]                rgn_ctrl1_curr_rgn;

    always @(posedge clk or negedge reset_n) begin: RGN_CTRL1_REG
      integer i;
      if (!reset_n) begin
        rgn_ctrl1_r <= {FC_NUM_RGN*ACT_RGN_CTRL1_WIDTH{1'b0}};
      end else begin
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (default_state_i) begin
            rgn_ctrl1_r[((i+1)*ACT_RGN_CTRL1_WIDTH)-1-:ACT_RGN_CTRL1_WIDTH] <= {ACT_RGN_CTRL1_WIDTH{1'b0}};
          end
          else if (rgn_ctrl1_en[i]) begin
            rgn_ctrl1_r[((i+1)*ACT_RGN_CTRL1_WIDTH)-1-:ACT_RGN_CTRL1_WIDTH] <=
              rgn_ctrl1_i[((i+1)*RGN_CTRL1_WIDTH)-RGN_CTRL1_DIFF-1-:ACT_RGN_CTRL1_WIDTH];
          end
        end
      end
    end

    if (RGN_CTRL1_DIFF==0) begin: RGN_CTRL1_ZERO_PAD_NO_NEED
      assign rgn_ctrl1_o = rgn_ctrl1_r;
    end else begin: RGN_CTRL1_ZERO_PAD_NEED
      reg [FC_NUM_RGN*RGN_CTRL1_WIDTH-1:0] rgn_ctrl1_int;
      always @(*) begin: RGN_CTRL1_ZERO_PADDING
        integer i; 
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          rgn_ctrl1_int[(i+1)*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH] =
            {{RGN_CTRL1_DIFF{1'b0}},
             rgn_ctrl1_r[(i+1)*ACT_RGN_CTRL1_WIDTH-1-:ACT_RGN_CTRL1_WIDTH]};
        end
      end
      assign rgn_ctrl1_o = rgn_ctrl1_int;
    end

    always @(*) begin: RGN_CTRL1_CURRENT_RGN
      integer i; 
      rgn_ctrl1_curr_rgn = {RGN_CTRL1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_ctrl1_curr_rgn =
            rgn_ctrl1_o[(i+1)*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH];
        end
      end
    end

    assign rgn_ctrl1_rgn_o = rgn_ctrl1_curr_rgn;

  end else begin: RGN_CTRL1_PE_LVL_ZERO 
    assign rgn_ctrl1_o     = {FC_NUM_RGN*RGN_CTRL1_WIDTH{1'b0}};
    assign rgn_ctrl1_rgn_o = {RGN_CTRL1_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if (FC_PE_LVL > 0 && FW_LDE_LVL == 2) begin: RGN_LCTRL_PE_LVL_NOT_ZERO_LDE_LVL_TWO 
    reg [FC_NUM_RGN*RGN_LCTRL_WIDTH-1:0] rgn_lctrl_r   ;
    reg [RGN_LCTRL_WIDTH-1:0]            rgn_lctrl_curr_rgn;

    always @(posedge clk or negedge reset_n) begin:RGN_LCTRL_REG
      integer i; 
      if (!reset_n) begin
        rgn_lctrl_r <= {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};
      end else begin
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (default_state_i) begin
            rgn_lctrl_r[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH] <= {RGN_LCTRL_WIDTH{1'b0}};
          end
          else if (rgn_lctrl_en[i]) begin
            rgn_lctrl_r[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH] <=
              rgn_lctrl_i[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH];
          end
        end
      end
    end

    assign rgn_lctrl_o = rgn_lctrl_r;

    always @(*) begin: RGN_LCTRL_CURR_RGN_BLK
      integer i; 
      rgn_lctrl_curr_rgn = {RGN_LCTRL_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_LCTRL_CURR_RGN_LOOP
        if (i==rwe_ctrl_o) begin
          rgn_lctrl_curr_rgn =
            rgn_lctrl_o[(i+1)*RGN_LCTRL_WIDTH-1-:RGN_LCTRL_WIDTH];
        end
      end
    end

    assign rgn_lctrl_rgn_o = rgn_lctrl_curr_rgn;

  end else begin: RGN_LCTRL_PE_LVL_ZERO_LDE_LVL_NOT_TWO 
    assign rgn_lctrl_o     = {FC_NUM_RGN*RGN_LCTRL_WIDTH{1'b0}};
    assign rgn_lctrl_rgn_o = {RGN_LCTRL_WIDTH{1'b0}};
  end
endgenerate


wire [FC_NUM_RGN*RGN_ST_WIDTH-1:0] rgn_st_int;

generate
  for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_ST_ASSEMBLE
    assign rgn_st_int [(i+1)*RGN_ST_WIDTH-1-:RGN_ST_WIDTH] =
      {rgn_ctrl1_o[(i+1)*RGN_CTRL1_WIDTH-1-:RGN_CTRL1_WIDTH],
       rgn_ctrl0_o[(i+1)*RGN_CTRL0_WIDTH-1-:RGN_CTRL0_WIDTH]};
  end
endgenerate

reg [RGN_ST_WIDTH-1:0]            rgn_st_curr_rgn;
reg [FC_NUM_RGN*RGN_ST_WIDTH-1:0] rgn_st_reg;

always @(*) begin: RGN_ST_CURRENT_REGION
  integer i;
  rgn_st_curr_rgn = {RGN_ST_WIDTH{1'b0}};
  for (i=0; i<FC_NUM_RGN; i=i+1) begin
    if (i == rwe_ctrl_o) begin
      rgn_st_curr_rgn = rgn_st_reg[(i+1)*RGN_ST_WIDTH-1-:RGN_ST_WIDTH];
    end
  end
end


localparam ACT_RGN_CFG0_WIDTH = (FC_MXRS <= 32) ?
  (FC_MXRS - (FC_MNRS+5)) :
  (32 - (FC_MNRS+5));

localparam RGN_CFG0_DIFF = RGN_CFG0_WIDTH - ACT_RGN_CFG0_WIDTH;

localparam RGN_CFG0_TOP = (FC_MXRS <= 32) ?
  32 - FC_MXRS :
  0;
localparam ACT_CFG0_PART_WIDTH = FC_NUM_RGN > 1 ? (FC_NUM_RGN-1)*ACT_RGN_CFG0_WIDTH-1 : 1;
localparam CFG0_PART_WIDTH = FC_NUM_RGN > 1 ? (FC_NUM_RGN-1)*RGN_CFG0_WIDTH-1 : 1;
reg  [ACT_CFG0_PART_WIDTH:0] rgn_cfg0_i_part;
wire [FC_NUM_RGN*RGN_CFG0_WIDTH-1:0] rgn_cfg0_i_frmtd;
reg  [CFG0_PART_WIDTH:0] rgn_cfg0_i_frmtd_int;

localparam RGN_CFG0_DIFF_FLAG = (FC_MXRS<=32) ? 0 : 1;

generate
  if (FC_PE_LVL > 0) begin: RGN_CFG0_PE_LVL_NOT_ZERO
    reg [RGN_CFG0_WIDTH-1:0] rgn_cfg0_curr_rgn;

    if (FC_PE_LVL == 2) begin: RGN_CFG0_PE_LVL_2

      assign rgn_cfg0_o[RGN_CFG0_WIDTH-1:0] = {RGN_CFG0_WIDTH{1'b0}}; 
      assign rgn_cfg0_i_frmtd[RGN_CFG0_WIDTH-1:0] = {RGN_CFG0_WIDTH{1'b0}}; 

      if (FC_NUM_RGN > 1) begin: RGN_CFG0_PE_LVL_2_FC_NUM_RGN_NOT_1

        reg [(FC_NUM_RGN-1)*ACT_RGN_CFG0_WIDTH-1:0] rgn_cfg0_r;

        always @(posedge clk) begin: RGN_CFG0_REG
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_REG
            if (rgn_cfg0_en[i]) begin
              rgn_cfg0_r[(i)*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH] <=
                rgn_cfg0_i[(i+1)*RGN_CFG0_WIDTH-RGN_CFG0_TOP-1-:ACT_RGN_CFG0_WIDTH];
            end
          end
        end

        always @* begin: RGN_CFG0_INPUT_PART_SEL
          integer i;
          rgn_cfg0_i_part = {((FC_NUM_RGN-1)*ACT_RGN_CFG0_WIDTH){1'b0}};
          for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_REG
            if (rgn_cfg0_en[i]) begin
              rgn_cfg0_i_part[(i)*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH] =
                rgn_cfg0_i[(i+1)*RGN_CFG0_WIDTH-RGN_CFG0_TOP-1-:ACT_RGN_CFG0_WIDTH];
            end
          end
        end

        if (RGN_CFG0_DIFF==0) begin: RGN_CFG0_DO_NOT_PAD
          assign rgn_cfg0_o[FC_NUM_RGN*RGN_CFG0_WIDTH-1:RGN_CFG0_WIDTH] = rgn_cfg0_r;
          assign rgn_cfg0_i_frmtd[FC_NUM_RGN*RGN_CFG0_WIDTH-1:RGN_CFG0_WIDTH] = rgn_cfg0_i_part;

        end else begin: RGN_CFG0_DO_PAD

          reg [(FC_NUM_RGN-1)*RGN_CFG0_WIDTH-1:0] rgn_cfg0_int;

          if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY

            always @(*) begin: RGN_CFG0_ZERO_PAD
              integer i; 
              for (i=1; i<FC_NUM_RGN; i=i+1) begin
                rgn_cfg0_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {{RGN_CFG0_DIFF{1'b0}},
                   rgn_cfg0_r[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH]};
                rgn_cfg0_i_frmtd_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {{RGN_CFG0_DIFF{1'b0}},
                   rgn_cfg0_i_part[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH]};
              end
            end
          end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY

            always @(*) begin: RGN_CFG0_ZERO_PAD
              integer i; 
              for (i=1; i<FC_NUM_RGN; i=i+1) begin
                rgn_cfg0_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {rgn_cfg0_r[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH],
                   {RGN_CFG0_DIFF{1'b0}}};
                rgn_cfg0_i_frmtd_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {rgn_cfg0_i_part[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH],
                   {RGN_CFG0_DIFF{1'b0}}};
              end
            end
          end else begin: RGN_CFG0_ZERO_PAD_BOTH

            always @(*) begin: RGN_CFG0_ZERO_PAD
              integer i; 
              for (i=1; i<FC_NUM_RGN; i=i+1) begin
                rgn_cfg0_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
                   rgn_cfg0_r[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH],
                   {FC_MNRS{1'b0}}};
                rgn_cfg0_i_frmtd_int[i*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                  {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
                   rgn_cfg0_i_part[i*ACT_RGN_CFG0_WIDTH-1-:ACT_RGN_CFG0_WIDTH],
                   {FC_MNRS{1'b0}}};
              end
            end
          end

          assign rgn_cfg0_o[FC_NUM_RGN*RGN_CFG0_WIDTH-1:RGN_CFG0_WIDTH] = rgn_cfg0_int;
          assign rgn_cfg0_i_frmtd[FC_NUM_RGN*RGN_CFG0_WIDTH-1:RGN_CFG0_WIDTH] = rgn_cfg0_i_frmtd_int;
        end
      end

      always @(*) begin: RGN_CFG0_CURR_RGN
        integer i; 
        rgn_cfg0_curr_rgn = {RGN_CFG0_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_cfg0_curr_rgn =
              rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH];
          end
        end
      end

      assign rgn_cfg0_rgn_o = rgn_cfg0_curr_rgn;

    end else if (FC_PE_LVL == 1) begin: RGN_CFG0_PE_LVL_1

      if (RGN_CFG0_DIFF_FLAG == 0) begin: RGN_CFG0_MXRS_LESS_THAN_32

        if (RGN_CFG0_DIFF == 0) begin: RGN_CFG0_DO_NOT_ZERO_PAD
          for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
            assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
              FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH];
          end
        end else begin: RGN_CFG0_DO_ZERO_PAD

          if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {{RGN_CFG0_DIFF{1'b0}},
                 FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH]};
            end
          end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH],
                {RGN_CFG0_DIFF{1'b0}}
                };
            end
          end else begin: RGN_CFG0_ZERO_PAD_BOTH
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
                 FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH],
                 {FC_MNRS{1'b0}}};
            end
          end

        end
      end else begin: RGN_CFG0_MXRS_GREATER_THAN_32

        if (RGN_CFG0_DIFF == 0) begin: RGN_CFG0_DO_NOT_ZERO_PAD
          for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
            assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
              FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH];
          end
        end else begin: RGN_CFG0_DO_ZERO_PAD

          if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {{RGN_CFG0_DIFF{1'b0}},
                 FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH]};
            end
          end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH],
                {RGN_CFG0_DIFF{1'b0}}
                };
            end
          end else begin: RGN_CFG0_ZERO_PAD_BOTH
            for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG0_OUTPUT_PARAM
              assign rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH] =
                {{(RGN_CFG0_DIFF-FC_MNRS){1'b0}},
                 FC_RGN_BASE_ADDR[(i+1)*31-:ACT_RGN_CFG0_WIDTH],
                 {FC_MNRS{1'b0}}};
            end
          end
        end
      end

      always @(*) begin: RGN_CFG0_CURRENT_RGN
        integer i; 
        rgn_cfg0_curr_rgn = {RGN_CFG0_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_cfg0_curr_rgn =
              rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH];
          end
        end
      end

      assign rgn_cfg0_rgn_o = rgn_cfg0_curr_rgn;

    end
  end else begin: RGN_CFG0_PE_LVL_ZERO 
    assign rgn_cfg0_o     = {FC_NUM_RGN*RGN_CFG0_WIDTH{1'b0}};
    assign rgn_cfg0_rgn_o = {RGN_CFG0_WIDTH{1'b0}}           ;
  end
endgenerate


localparam ACT_RGN_CFG1_WIDTH = FC_MXRS - 32;

localparam RGN_CFG1_DIFF = RGN_CFG1_WIDTH - ACT_RGN_CFG1_WIDTH;

localparam RGN_CFG1_TOP = 64 - FC_MXRS;


generate
  if ((FC_PE_LVL > 0) && (FC_MXRS > 32)) begin: RGN_CFG1_PE_LVL_NOT_ZERO_REG_EXISTS

    reg [RGN_CFG1_WIDTH-1:0] rgn_cfg1_curr_rgn;

    assign rgn_cfg1_o[RGN_CFG1_WIDTH-1:0] = {RGN_CFG1_WIDTH{1'b0}};

    if (FC_PE_LVL == 2) begin: RGN_CFG1_PE_LVL_2

      reg [(FC_NUM_RGN-1)*ACT_RGN_CFG1_WIDTH-1:0] rgn_cfg1_r;

      if (FC_NUM_RGN > 1) begin: RGN_CFG1_PE_LVL_2_FC_NUM_RGN_NOT_1

        always @(posedge clk) begin: RGN_CFG1_REG 
          integer i; 
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_cfg1_en[i]) begin
              rgn_cfg1_r[i*ACT_RGN_CFG1_WIDTH-1-:ACT_RGN_CFG1_WIDTH] <=
                rgn_cfg1_i[(i+1)*RGN_CFG1_WIDTH-RGN_CFG1_TOP-1-:ACT_RGN_CFG1_WIDTH];
            end
          end
        end
        if (RGN_CFG1_DIFF == 0) begin: RGN_CFG1_DO_NOT_ZERO_PAD

          assign rgn_cfg1_o[FC_NUM_RGN*RGN_CFG1_WIDTH-1:RGN_CFG1_WIDTH] = rgn_cfg1_r;

        end else begin: RGN_CFG1_DO_ZERO_PAD

          reg [(FC_NUM_RGN-1)*RGN_CFG1_WIDTH-1:0] rgn_cfg1_int;

          always @(*) begin: RGN_CFG1_ZERO_PAD
            integer i; 
            rgn_cfg1_int = {(FC_NUM_RGN-1)*RGN_CFG1_WIDTH{1'b0}};

            for (i=1; i<FC_NUM_RGN; i=i+1) begin
              rgn_cfg1_int[i*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
                {{RGN_CFG1_DIFF{1'b0}},
                  rgn_cfg1_r[i*ACT_RGN_CFG1_WIDTH-1-:ACT_RGN_CFG1_WIDTH]};
            end
          end
          assign rgn_cfg1_o[FC_NUM_RGN*RGN_CFG1_WIDTH-1:RGN_CFG1_WIDTH] = rgn_cfg1_int;

        end
      end

      always @(*) begin: RGN_CFG1_CURRENT_RGN
        integer i; 
        rgn_cfg1_curr_rgn = {RGN_CFG1_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_cfg1_curr_rgn =
              rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH];
          end
        end
      end

      assign rgn_cfg1_rgn_o = rgn_cfg1_curr_rgn;

    end else if (FC_PE_LVL == 1) begin: RGN_CFG1_PE_LVL_1

      if (RGN_CFG1_DIFF == 0) begin: RGN_CFG1_ZERO_PAD_NOT_NEEDED
        for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG1_OUTPUT_PARAM_NO_ZERO_PAD
          assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
            FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG1_WIDTH];
        end
      end else begin: RGN_CFG1_ZERO_PAD_NEEDED
        for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_CFG1_OUTPUT_PARAM_ZERO_PAD
          assign rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH] =
            {{RGN_CFG1_DIFF{1'b0}},
             FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_CFG1_WIDTH]};
        end
      end

      always @(*) begin: RGN_CFG1_CURRENT_RGN
        integer i; 
        rgn_cfg1_curr_rgn = {RGN_CFG1_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_cfg1_curr_rgn =
              rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-1-:RGN_CFG1_WIDTH];
          end
        end
      end

      assign rgn_cfg1_rgn_o = rgn_cfg1_curr_rgn;

    end

  end else begin: RGN_CFG1_PE_LVL_ZERO_REG_NOT_EXISTS 
    assign rgn_cfg1_o     = {FC_NUM_RGN*RGN_CFG1_WIDTH{1'b0}};
    assign rgn_cfg1_rgn_o = {RGN_CFG1_WIDTH{1'b0}}           ;
  end
endgenerate


localparam RGN_SIZE_SIZE_WIDTH = 8;

wire [FC_NUM_RGN-1:0] rgn_size_i_mulnpo2_int;
wire [FC_NUM_RGN*RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_i_size_int;
wire [FC_NUM_RGN*RGN_SIZE_WIDTH-1:0] rgn_size_input_frmtd;

localparam ACT_RGN_SIZE_WIDTH = 9;

localparam RGN_SIZE_DIFF = RGN_SIZE_WIDTH - ACT_RGN_SIZE_WIDTH;

generate
  if (FC_PE_LVL > 0) begin: RGN_SIZE_PE_LVL_NOT_ZERO 


    wire [FC_NUM_RGN-1:0] rgn_size_mulnpo2_int;

    if (FC_RSE_LVL == 0) begin: RGN_SIZE_MULNPO2_PE_LVL_NOT_ZERO_RSE_LVL_ZERO

      assign rgn_size_mulnpo2_int = {FC_NUM_RGN{1'b0}};
      assign rgn_size_i_mulnpo2_int = {FC_NUM_RGN{1'b0}};

    end else begin: RGN_SIZE_MULNPO2_PE_LVL_NOT_ZERO_RSE_LVL_NOT_ZERO
      if (FC_PE_LVL == 2) begin: RGN_SIZE_MULNPO2_PE_LVL_TWO_RSE_LVL_NOT_ZERO

        wire rgn_size_mulnpo2_def_r;
        wire rgn_size_i_mulnpo2_def_r;

        assign rgn_size_mulnpo2_def_r   = 1'b0;
        assign rgn_size_i_mulnpo2_def_r = 1'b0;


        if (FC_NUM_RGN > 1) begin: RGN_SIZE_MULNPO2_FC_NUM_RGN_NOT_1

          reg [FC_NUM_RGN-2:0] rgn_size_mulnpo2_non_def_r;
          reg [FC_NUM_RGN-2:0] rgn_size_i_mulnpo2_non_def_r;

          always @(posedge clk) begin: RGN_SIZE_MULNPO2_NON_DEF_REG
            integer i;
            for (i=1; i<FC_NUM_RGN; i=i+1) begin
              if (rgn_size_en[i]) begin
                rgn_size_mulnpo2_non_def_r[i-1] <=
                  rgn_size_i[(i*RGN_SIZE_WIDTH)+ACT_RGN_SIZE_WIDTH-1];
              end
            end
          end

          always @* begin: RGN_SIZE_INPUT_MULNPO2_NON_DEF_REG
            integer i;
            rgn_size_i_mulnpo2_non_def_r = {(FC_NUM_RGN-1){1'b0}};
            for (i=1; i<FC_NUM_RGN; i=i+1) begin
              if (rgn_size_en[i]) begin
                rgn_size_i_mulnpo2_non_def_r[i-1] =
                  rgn_size_i[(i*RGN_SIZE_WIDTH)+ACT_RGN_SIZE_WIDTH-1];
              end
            end
          end

          assign rgn_size_mulnpo2_int =
            {rgn_size_mulnpo2_non_def_r, rgn_size_mulnpo2_def_r};

          assign rgn_size_i_mulnpo2_int =
            {rgn_size_i_mulnpo2_non_def_r, rgn_size_i_mulnpo2_def_r};

        end else begin: RGN_SIZE_MULNPO2_FC_NUM_RGN_1
          assign rgn_size_mulnpo2_int = rgn_size_mulnpo2_def_r;
          assign rgn_size_i_mulnpo2_int = rgn_size_i_mulnpo2_def_r;
        end

      end else if (FC_PE_LVL == 1) begin: RGN_SIZE_MULNPO2_PE_LVL_ONE_RSE_LVL_NOT_ZERO

        for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_MULNPO2_OUTPUT_PARAM_VAL

          assign rgn_size_mulnpo2_int[i] = FC_RGN_MULNPO2[i];
          assign rgn_size_i_mulnpo2_int[i] = 1'b0;

        end
      end
    end


    wire [FC_NUM_RGN*RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_size_int;

    if (FC_PE_LVL == 2) begin: RGN_SIZE_SIZE_PE_LVL_TWO

      wire [RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_size_def_r;
      wire [RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_i_size_def_r;

      assign rgn_size_size_def_r   = prot_size_o;
      assign rgn_size_i_size_def_r = prot_size_o;

      if (FC_NUM_RGN > 1) begin: RGN_SIZE_SIZE_FC_NUM_RGN_NOT_1

        reg [(FC_NUM_RGN-1)*RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_size_non_def_r;
        reg [(FC_NUM_RGN-1)*RGN_SIZE_SIZE_WIDTH-1:0] rgn_size_i_size_non_def_r;

        always @(posedge clk) begin: RGN_SIZE_SIZE_NON_DEF_REG
          integer i;
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_size_en[i]) begin
              rgn_size_size_non_def_r[i*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH] <=
                rgn_size_i[(i+1)*RGN_SIZE_WIDTH-RGN_SIZE_DIFF-2-:RGN_SIZE_SIZE_WIDTH];
            end
          end
        end

        always @* begin: RGN_SIZE_INPUT_SIZE_NON_DEF_REG
          integer i;
          rgn_size_i_size_non_def_r = {((FC_NUM_RGN-1)*RGN_SIZE_SIZE_WIDTH){1'b0}};
          for (i=1; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_size_en[i]) begin
              rgn_size_i_size_non_def_r[i*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH] =
                rgn_size_i[(i+1)*RGN_SIZE_WIDTH-RGN_SIZE_DIFF-2-:RGN_SIZE_SIZE_WIDTH];
            end
          end

        end

        assign rgn_size_size_int = {rgn_size_size_non_def_r, rgn_size_size_def_r};
        assign rgn_size_i_size_int = {rgn_size_i_size_non_def_r, rgn_size_i_size_def_r};

      end else begin: RGN_SIZE_SIZE_FC_NUM_RGN_1

        assign rgn_size_size_int = rgn_size_size_def_r;
        assign rgn_size_i_size_int = rgn_size_i_size_def_r;

      end

    end else if (FC_PE_LVL == 1) begin: RGN_SIZE_SIZE_PE_LVL_ONE

      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_SIZE_OUTPUT_PARAM_VAL
        assign rgn_size_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH] =
          FC_RGN_SIZE[(i+1)*8-1-:8];
        assign rgn_size_i_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH] =
          8'h00;
      end

    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_SIZE_ASSEMBLE_OUTPUT
      assign rgn_size_o[(i+1)*RGN_SIZE_WIDTH-1-:RGN_SIZE_WIDTH] =
        {{RGN_SIZE_DIFF{1'b0}},
         rgn_size_mulnpo2_int[i],
         rgn_size_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH]};

      assign rgn_size_input_frmtd[(i+1)*RGN_SIZE_WIDTH-1-:RGN_SIZE_WIDTH] =
        {{RGN_SIZE_DIFF{1'b0}},
         rgn_size_i_mulnpo2_int[i],
         rgn_size_i_size_int[(i+1)*RGN_SIZE_SIZE_WIDTH-1-:RGN_SIZE_SIZE_WIDTH]};
    end


    reg [RGN_SIZE_WIDTH-1:0] rgn_size_curr_rgn;

    always @(*) begin: RGN_SIZE_CURRENT_RGN
      integer i;
      rgn_size_curr_rgn = {RGN_SIZE_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_size_curr_rgn =
            rgn_size_o[(i+1)*RGN_SIZE_WIDTH-1-:RGN_SIZE_WIDTH];
        end
      end
    end

    assign rgn_size_rgn_o = rgn_size_curr_rgn;

  end else begin: RGN_SIZE_PE_LVL_ZERO 
    assign rgn_size_o     = {FC_NUM_RGN*RGN_SIZE_WIDTH{1'b0}};
    assign rgn_size_rgn_o = {RGN_SIZE_WIDTH{1'b0}}           ;
  end
endgenerate


localparam ACT_RGN_TCFG0_WIDTH = (FC_MXRS <= 32) ?
  (FC_MXRS - (FC_MNRS+5)) :
  (32 - (FC_MNRS+5));

localparam RGN_TCFG0_DIFF = RGN_TCFG0_WIDTH - ACT_RGN_TCFG0_WIDTH;

localparam RGN_TCFG0_TOP = (FC_MXRS <= 32) ?
  32 - FC_MXRS :
  0;

localparam RGN_TCFG0_PE1_RW_REG_EXISTS = (FC_TE_LVL == 2) && (|(~FC_RGN_MULNPO2));

generate
  if (FC_PE_LVL > 0) begin: RGN_TCFG0_PE_LVL_NOT_ZERO

    reg [RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_curr_rgn;

    if (FC_PE_LVL == 2) begin: RGN_TCFG0_PE_LVL_2
      if ((FC_RSE_LVL == 1) || (FC_TE_LVL == 2)) begin: RGN_TCFG0_PE_LVL_2_REG_EXISTS

        assign rgn_tcfg0_o[RGN_TCFG0_WIDTH-1:0] = {RGN_TCFG0_WIDTH{1'b0}};

        if (FC_NUM_RGN > 1) begin: RGN_TCFG0_PE_LVL_2_FC_NUM_RGN_NOT_1

          reg [(FC_NUM_RGN-1)*ACT_RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_r;

          always @(posedge clk) begin: RGN_TCFG0_REG
            integer i;
            for (i=1; i<FC_NUM_RGN; i=i+1) begin
              if (rgn_tcfg0_en[i]) begin
                rgn_tcfg0_r[(i)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH] <=
                  rgn_tcfg0_i[i*RGN_TCFG0_WIDTH+FC_MNRS+:ACT_RGN_TCFG0_WIDTH];
              end
            end
          end

          if (RGN_TCFG0_DIFF == 0) begin: RGN_TCFG0_ZERO_PAD_NOT_NEEDED

            assign rgn_tcfg0_o[FC_NUM_RGN*RGN_TCFG0_WIDTH-1:RGN_TCFG0_WIDTH] = rgn_tcfg0_r;

          end else begin: RGN_TCFG0_ZERO_PAD_NEEDED

            if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
              for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG0_DO_ZERO_PAD
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {{RGN_TCFG0_DIFF{1'b0}},
                   rgn_tcfg0_r[(i)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH]};
              end

            end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
              for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG0_DO_ZERO_PAD
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {rgn_tcfg0_r[(i)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                  {RGN_TCFG0_DIFF{1'b0}}};
              end

            end else begin: RGN_CFG0_ZERO_PAD_BOTH
              for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG0_DO_ZERO_PAD
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {{(RGN_TCFG0_DIFF-FC_MNRS){1'b0}},
                   rgn_tcfg0_r[(i)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                   {FC_MNRS{1'b0}}};
              end
            end
          end
        end

        always @(*) begin: RGN_TCFG0_CURRENT_RGN
          integer i;
          rgn_tcfg0_curr_rgn = {RGN_TCFG0_WIDTH{1'b0}};
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (i==rwe_ctrl_o) begin
              rgn_tcfg0_curr_rgn =
                rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH];
            end
          end
        end

        assign rgn_tcfg0_rgn_o = rgn_tcfg0_curr_rgn;

      end else begin: RGN_TCFG0_PE_LVL_2_REG_DOES_NOT_EXIST
        assign rgn_tcfg0_o     = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};
        assign rgn_tcfg0_rgn_o = {RGN_TCFG0_WIDTH{1'b0}};
      end
    end else if (FC_PE_LVL == 1) begin: RGN_TCFG0_PE_LVL_1

      wire [FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_int;

      if (RGN_TCFG0_PE1_RW_REG_EXISTS == 1) begin: RGN_TCFG0_BUILD_REG
        reg [FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH-1:0] rgn_tcfg0_r;
        always @(posedge clk) begin: RGN_TCFG0_REG
          integer i;
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_tcfg0_en[i] && !FC_RGN_MULNPO2[i]) begin
              rgn_tcfg0_r[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH] <=
                rgn_tcfg0_i[(i+1)*RGN_TCFG0_WIDTH-RGN_TCFG0_TOP-1-:ACT_RGN_TCFG0_WIDTH];
            end else if (rgn_tcfg0_en[i] && FC_RGN_MULNPO2[i]) begin
              rgn_tcfg0_r[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH] <=
                {ACT_RGN_TCFG0_WIDTH{1'b0}};
            end
          end
        end
        assign rgn_tcfg0_int = rgn_tcfg0_r;
      end else begin: RGN_TCFG0_DO_NOT_BUILD_REG
        assign rgn_tcfg0_int = {FC_NUM_RGN*ACT_RGN_TCFG0_WIDTH{1'b0}};
      end

      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG0_ASSEMBLE_OUTPUT

        if (FC_RGN_MULNPO2[i]) begin: RGN_TCFG0_PE_1_MULNPO2_1

          if (RGN_TCFG0_DIFF == 0) begin: RGN_TCFG0_DO_NOT_ZERO_PAD

            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH];

          end else begin:RGN_TCFG0_DO_ZERO_PAD

            if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {{RGN_TCFG0_DIFF{1'b0}},
                 FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH]};

            end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH],
                {RGN_TCFG0_DIFF{1'b0}}};

            end else begin: RGN_CFG0_ZERO_PAD_BOTH
              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                {{(RGN_TCFG0_DIFF-FC_MNRS){1'b0}},
                 FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH],
                 {FC_MNRS{1'b0}}};
            end

          end

        end else begin: RGN_TCFG0_PE_1_MULNPO2_0

          if (FC_TE_LVL < 2) begin: RGN_TCFG0_OUTPUTS_ZEROS

            assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
              {RGN_TCFG0_WIDTH{1'b0}};

          end else begin:RGN_TCFG0_OUTPUTS_FLOP_CONTENT


            if (RGN_TCFG0_DIFF == 0) begin: RGN_TCFG0_DO_NOT_ZERO_PAD

              assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH];

            end else begin:RGN_TCFG0_DO_ZERO_PAD

              if (FC_MNRS == 0) begin: RGN_CFG0_ZERO_PAD_TOP_ONLY
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {{RGN_TCFG0_DIFF{1'b0}},
                   rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH]};

              end else if (FC_MXRS == 32) begin: RGN_CFG0_ZERO_PAD_BOTTOM_ONLY
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                  {RGN_TCFG0_DIFF{1'b0}}};

              end else begin: RGN_CFG0_ZERO_PAD_BOTH
                assign rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH] =
                  {{(RGN_TCFG0_DIFF-FC_MNRS){1'b0}},
                   rgn_tcfg0_int[(i+1)*ACT_RGN_TCFG0_WIDTH-1-:ACT_RGN_TCFG0_WIDTH],
                   {FC_MNRS{1'b0}}};
              end

            end
          end
        end
      end

      always @(*) begin: RGN_TCFG0_CURRENT_RGN
        integer i;
        rgn_tcfg0_curr_rgn = {RGN_TCFG0_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_tcfg0_curr_rgn =
              rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH];
          end
        end
      end

      assign rgn_tcfg0_rgn_o = rgn_tcfg0_curr_rgn;

    end 

  end else begin: RGN_TCFG0_PE_LVL_ZERO
    assign rgn_tcfg0_o     = {FC_NUM_RGN*RGN_TCFG0_WIDTH{1'b0}};
    assign rgn_tcfg0_rgn_o = {RGN_TCFG0_WIDTH{1'b0}};
  end
endgenerate


localparam ACT_RGN_TCFG1_WIDTH = FC_MXRS - 32;

localparam RGN_TCFG1_DIFF = RGN_TCFG1_WIDTH - ACT_RGN_TCFG1_WIDTH;

localparam RGN_TCFG1_TOP = 64 - FC_MXRS;

localparam RGN_TCFG1_PE1_RW_REG_EXISTS = (FC_TE_LVL == 2) && (|(~FC_RGN_MULNPO2));

generate
  if ((FC_PE_LVL > 0) && (FC_MXRS > 32)) begin: RGN_TCFG1_PE_LVL_NOT_ZERO

    reg [RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_curr_rgn;

    if (FC_PE_LVL == 2) begin: RGN_TCFG1_PE_LVL_2
      if ((FC_RSE_LVL == 1) || (FC_TE_LVL == 2)) begin: RGN_TCFG1_PE_LVL_2_REG_EXISTS

        assign rgn_tcfg1_o[RGN_TCFG1_WIDTH-1:0] = {RGN_TCFG1_WIDTH{1'b0}};

        if (FC_NUM_RGN > 1) begin: RGN_TCFG1_PE_LVL_2_FC_NUM_RGN_NOT_1

          reg [FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_r;

          always @(posedge clk) begin: RGN_TCFG1_REG
            integer i;
            for (i=1; i<FC_NUM_RGN; i=i+1) begin
              if (rgn_tcfg1_en[i]) begin
                rgn_tcfg1_r[(i)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH] <=
                  rgn_tcfg1_i[(i+1)*RGN_TCFG1_WIDTH-RGN_TCFG1_TOP-1-:ACT_RGN_TCFG1_WIDTH];
              end
            end
          end

          if (RGN_TCFG1_DIFF == 0) begin: RGN_TCFG1_ZERO_PAD_NOT_NEEDED

            assign rgn_tcfg1_o[FC_NUM_RGN*RGN_TCFG1_WIDTH-1:RGN_TCFG1_WIDTH] = rgn_tcfg1_r;

          end else begin: RGN_TCFG1_ZERO_PAD_NEEDED

            for (i=1; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG1_DO_ZERO_PAD
              assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
                {{RGN_TCFG1_DIFF{1'b0}}, rgn_tcfg1_r[(i)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH]};
            end

          end
        end

        always @(*) begin: RGN_TCFG1_CURRENT_RGN
          integer i;
          rgn_tcfg1_curr_rgn = {RGN_TCFG1_WIDTH{1'b0}};
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (i==rwe_ctrl_o) begin
              rgn_tcfg1_curr_rgn =
                rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH];
            end
          end
        end

        assign rgn_tcfg1_rgn_o = rgn_tcfg1_curr_rgn;

      end else begin: RGN_TCFG1_PE_LVL_2_REG_DOES_NOT_EXIST
        assign rgn_tcfg1_o     = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};
        assign rgn_tcfg1_rgn_o = {RGN_TCFG1_WIDTH{1'b0}};
      end

    end else if (FC_PE_LVL == 1) begin: RGN_TCFG1_PE_LVL_1

      wire [FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_int;

      if (RGN_TCFG1_PE1_RW_REG_EXISTS == 1) begin: RGN_TCFG1_BUILD_REG
        reg [FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH-1:0] rgn_tcfg1_r;
        always @(posedge clk) begin: RGN_TCFG1_REG
          integer i;
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_tcfg1_en[i] && !FC_RGN_MULNPO2[i]) begin
              rgn_tcfg1_r[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH] <=
                rgn_tcfg1_i[(i+1)*RGN_TCFG1_WIDTH-RGN_TCFG1_TOP-1-:ACT_RGN_TCFG1_WIDTH];
            end else if (rgn_tcfg1_en[i] && FC_RGN_MULNPO2[i]) begin
              rgn_tcfg1_r[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH] <=
                {ACT_RGN_TCFG1_WIDTH{1'b0}};
            end
          end
        end
        assign rgn_tcfg1_int = rgn_tcfg1_r;
      end else begin: RGN_TCFG1_DO_NOT_BUILD_REG
        assign rgn_tcfg1_int = {FC_NUM_RGN*ACT_RGN_TCFG1_WIDTH{1'b0}};
      end

      for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG1_ASSEMBLE_OUTPUT

        if (FC_RGN_MULNPO2[i]) begin: RGN_TCFG1_PE_1_MULNPO2_1

          if (RGN_TCFG1_DIFF == 0) begin: RGN_TCFG1_DO_NOT_ZERO_PAD

            assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
              FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG1_WIDTH];

          end else begin:RGN_TCFG1_DO_ZERO_PAD

            assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
              {{RGN_TCFG1_DIFF{1'b0}},
               FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG1_WIDTH]};

          end

        end else begin: RGN_TCFG1_PE_1_MULNPO2_0

          if (FC_TE_LVL < 2) begin: RGN_TCFG1_OUTPUTS_ZEROS

            assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
              {RGN_TCFG1_WIDTH{1'b0}};

          end else begin:RGN_TCFG1_OUTPUTS_FLOP_CONTENT


            if (RGN_TCFG1_DIFF == 0) begin: RGN_TCFG1_DO_NOT_ZERO_PAD

              assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
                rgn_tcfg1_int[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH];

            end else begin:RGN_TCFG1_DO_ZERO_PAD

              assign rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH] =
                {{RGN_TCFG1_DIFF{1'b0}},
                 rgn_tcfg1_int[(i+1)*ACT_RGN_TCFG1_WIDTH-1-:ACT_RGN_TCFG1_WIDTH]};

            end
          end
        end
      end

      always @(*) begin: RGN_TCFG1_CURRENT_RGN
        integer i;
        rgn_tcfg1_curr_rgn = {RGN_TCFG1_WIDTH{1'b0}};
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (i==rwe_ctrl_o) begin
            rgn_tcfg1_curr_rgn =
              rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-1-:RGN_TCFG1_WIDTH];
          end
        end
      end

      assign rgn_tcfg1_rgn_o = rgn_tcfg1_curr_rgn;

    end 

  end else begin: RGN_TCFG1_PE_LVL_ZERO
    assign rgn_tcfg1_o     = {FC_NUM_RGN*RGN_TCFG1_WIDTH{1'b0}};
    assign rgn_tcfg1_rgn_o = {RGN_TCFG1_WIDTH{1'b0}};
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_TE_LVL > 0)) begin: RGN_TCFG2_PE_LVL_NOT_0_TE_LVL_NOT_0
    wire [FC_NUM_RGN-1:0] rgn_tcfg2_addr_trans_en_int;


    if (FC_TE_LVL == 2) begin: RGN_TCFG2_ADDR_TRANS_EN_PE_LVL_NOT_0_TE_LVL_NOT_2_PE_LVL_2


      if (FC_PE_LVL == 2) begin: RGN_TCFG2_ADDR_TRANS_PE_LVL_NOT_0_TE_LVL_2_PE_LVL_2
        assign rgn_tcfg2_addr_trans_en_int[0] = 1'b0;

      end else begin: RGN_TCFG2_ADDR_TRANS_PE_LVL_NOT_0_TE_LVL_2_PE_LVL_NOT_2

        reg rgn_tcfg2_addr_trans_en_def_r;

        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_ADDR_TRANS_EN_DEF_RGN_REG
          if (!reset_n) begin
            rgn_tcfg2_addr_trans_en_def_r <= 1'b0;
          end else begin
            if (default_state_i) begin
              rgn_tcfg2_addr_trans_en_def_r <= 1'b0;
            end
            else if (rgn_tcfg2_en[0]) begin
              rgn_tcfg2_addr_trans_en_def_r <= rgn_tcfg2_i[RGN_TCFG2_WIDTH-1];
            end
          end
        end
        assign rgn_tcfg2_addr_trans_en_int[0] = rgn_tcfg2_addr_trans_en_def_r;
      end


      if (FC_NUM_RGN > 1) begin: RGN_TCFG2_ADDR_TRANS_EN_FC_NUM_RGN_NOT_1

        reg [FC_NUM_RGN-2:0] rgn_tcfg2_addr_trans_en_non_def_r;
        always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_ADDR_TRANS_EN_NON_DEF_RGN_REG
          integer i; 
          if (!reset_n) begin
            rgn_tcfg2_addr_trans_en_non_def_r <= {(FC_NUM_RGN-1){1'b0}};
          end else begin
            for (i=1; i<FC_NUM_RGN; i=i+1) begin 
              if (default_state_i) begin
                rgn_tcfg2_addr_trans_en_non_def_r[i-1] <= 1'b0;
              end
              else if (rgn_tcfg2_en[i]) begin
                rgn_tcfg2_addr_trans_en_non_def_r[i-1] <=
                  rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-1];
              end
            end
          end
        end

      assign rgn_tcfg2_addr_trans_en_int[FC_NUM_RGN-1:1] =
        rgn_tcfg2_addr_trans_en_non_def_r;

      end 

    end else begin: RGN_TCFG2_ADDR_TRANS_EN_PE_LVL_NOT_0_TE_LVL_NOT_2
      assign rgn_tcfg2_addr_trans_en_int = {FC_NUM_RGN{1'b0}};
    end


    wire [FC_NUM_RGN-1:0] rgn_tcfg2_ma_trans_en_int;

    if (FC_MA_SPT == 0) begin: RGN_TCFG2_MA_TRANS_SPT_FC_MA_EN_0

      assign rgn_tcfg2_ma_trans_en_int = {FC_NUM_RGN{1'b0}};

    end else begin: RGN_TCFG2_MA_TRANS_EN_FC_MA_SPT_1

      reg [FC_NUM_RGN-1:0] rgn_tcfg2_ma_trans_en_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_MA_TRANS_EN_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_ma_trans_en_r <= {FC_NUM_RGN{1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_ma_trans_en_r[i] <= 1'b0;
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_ma_trans_en_r[i] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-2];
            end
          end
        end
      end

      assign rgn_tcfg2_ma_trans_en_int = rgn_tcfg2_ma_trans_en_r;

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_inst_int;

    if (FC_INST_SPT == 0) begin: RGN_TCFG2_INST_FC_INST_SPT_0

      assign rgn_tcfg2_inst_int = {FC_NUM_RGN*2{1'b0}};

    end else begin: RGN_TCFG2_INST_FC_INST_SPT_1
      reg [FC_NUM_RGN*2-1:0] rgn_tcfg2_inst_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_INST_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_inst_r <= {(FC_NUM_RGN*2){1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_inst_r[(i+1)*2-1-:2] <= 2'b00;
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_inst_r[(i+1)*2-1-:2] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-3-:2];
            end
          end
        end
      end

      assign rgn_tcfg2_inst_int = rgn_tcfg2_inst_r;

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_priv_int;

    if (FC_PRIV_SPT == 0) begin: RGN_TCFG2_PRIV_FC_PRIV_SPT_0

      assign rgn_tcfg2_priv_int = {FC_NUM_RGN*2{1'b0}};

    end else begin: RGN_TCFG2_PRIV_FC_PRIV_SPT_1
      reg [FC_NUM_RGN*2-1:0] rgn_tcfg2_priv_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_PRIV_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_priv_r <= {(FC_NUM_RGN*2){1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_priv_r[(i+1)*2-1-:2] <= 2'b00;
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_priv_r[(i+1)*2-1-:2] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-5-:2];
            end
          end
        end
      end

      assign rgn_tcfg2_priv_int = rgn_tcfg2_priv_r;

    end


    wire [FC_NUM_RGN*8-1:0] rgn_tcfg2_ma_int;

    if (FC_MA_SPT == 0) begin: RGN_TCFG2_MA_FC_MA_SPT_0

      assign rgn_tcfg2_ma_int = {FC_NUM_RGN*8{1'b0}};

    end else begin: RGN_TCFG2_MA_FC_MA_SPT_1
      reg [FC_NUM_RGN*8-1:0] rgn_tcfg2_ma_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_MA_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_ma_r <= {(FC_NUM_RGN*8){1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_ma_r[(i+1)*8-1-:8] <= {8{1'b0}};
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_ma_r[(i+1)*8-1-:8] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-7-:8];
            end
          end
        end
      end

      assign rgn_tcfg2_ma_int = rgn_tcfg2_ma_r;

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_sh_int;

    if (FC_SH_SPT == 0) begin: RGN_TCFG2_SH_FC_SH_SPT_0

      assign rgn_tcfg2_sh_int = {FC_NUM_RGN{2'b01}};

    end else begin: RGN_TCFG2_SH_FC_SH_SPT_1
      reg [FC_NUM_RGN*2-1:0] rgn_tcfg2_sh_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_SH_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_sh_r <= {(FC_NUM_RGN*2){1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_sh_r[(i+1)*2-1-:2] <= {2{1'b0}};
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_sh_r[(i+1)*2-1-:2] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-15-:2];
            end
          end
        end
      end

      assign rgn_tcfg2_sh_int = rgn_tcfg2_sh_r;

    end


    wire [FC_NUM_RGN*2-1:0] rgn_tcfg2_ns_int;

    if (FC_SEC_SPT == 0) begin: RGN_TCFG2_NS_FC_SEC_SPT_0

      assign rgn_tcfg2_ns_int = {FC_NUM_RGN*2{1'b0}};

    end else begin: RGN_TCFG2_NS_FC_SEC_SPT_1
      reg [FC_NUM_RGN*2-1:0] rgn_tcfg2_ns_r;

      always @(posedge clk or negedge reset_n) begin: RGN_TCFG2_NS_REG
        integer i;
        if (!reset_n) begin
          rgn_tcfg2_ns_r <= {(FC_NUM_RGN*2){1'b0}};
        end else begin
          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (default_state_i) begin
              rgn_tcfg2_ns_r[(i+1)*2-1-:2] <= {2{1'b0}};
            end
            else if (rgn_tcfg2_en[i]) begin
              rgn_tcfg2_ns_r[(i+1)*2-1-:2] <=
                rgn_tcfg2_i[(i+1)*RGN_TCFG2_WIDTH-17-:2];
            end
          end
        end
      end

      assign rgn_tcfg2_ns_int = rgn_tcfg2_ns_r;

    end


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_TCFG2_ASSEMBLE_OUTPUT

      assign rgn_tcfg2_o[(i+1)*RGN_TCFG2_WIDTH-1-:RGN_TCFG2_WIDTH] =
        {rgn_tcfg2_addr_trans_en_int[i]  ,
         rgn_tcfg2_ma_trans_en_int[i]    ,
         rgn_tcfg2_inst_int[(i+1)*2-1-:2],
         rgn_tcfg2_priv_int[(i+1)*2-1-:2],
         rgn_tcfg2_ma_int[(i+1)*8-1-:8]  ,
         rgn_tcfg2_sh_int[(i+1)*2-1-:2]  ,
         rgn_tcfg2_ns_int[(i+1)*2-1-:2]  };

    end


    reg [RGN_TCFG2_WIDTH-1:0] rgn_tcfg2_curr_rgn;

    always @(*) begin:RGN_TCFG2_CURRENT_RGN
      integer i;
      rgn_tcfg2_curr_rgn = {RGN_TCFG2_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_tcfg2_curr_rgn =
            rgn_tcfg2_o[(i+1)*RGN_TCFG2_WIDTH-1-:RGN_TCFG2_WIDTH];
        end
      end
    end

    assign rgn_tcfg2_rgn_o = rgn_tcfg2_curr_rgn;

  end else begin: RGN_TCFG2_PE_LVL_0_OR_TE_LVL_0 
    assign rgn_tcfg2_o     = {FC_NUM_RGN*RGN_TCFG2_WIDTH{1'b0}};
    assign rgn_tcfg2_rgn_o = {RGN_TCFG2_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if (FC_PE_LVL > 0) begin: RGN_MID0_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid0_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid0_aux;
    assign rgn_mid0_aux = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0];

    if (FC_SINGLE_MST == 1) begin: RGN_MID0_FC_SINGLE_MST_1

      assign rgn_mid0_int = {FC_NUM_RGN{rgn_mid0_aux}};

    end else begin: RGN_MID0_FC_SINGLE_MST_0

      reg [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid0_r;

      always @(posedge clk) begin: RGN_MID0_REG
        integer i; 
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mid0_en[i]) begin
            rgn_mid0_r[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
              rgn_mid0_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
          end
        end
      end

      assign rgn_mid0_int = rgn_mid0_r;

    end

    assign rgn_mid0_o = rgn_mid0_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid0_curr_rgn;
    always @(*) begin: RGN_MID0_CURRENT_RGN
      integer i;
      rgn_mid0_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid0_curr_rgn =
            rgn_mid0_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid0_rgn_o = rgn_mid0_curr_rgn;

  end else begin: RGN_MID0_PE_LVL_0
    assign rgn_mid0_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid0_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 2)) begin: RGN_MID1_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid1_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid1_aux;
    assign rgn_mid1_aux = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0];

    if (FC_SINGLE_MST == 1) begin: RGN_MID1_FC_SINGLE_MST_1

      assign rgn_mid1_int = {FC_NUM_RGN{rgn_mid1_aux}};

    end else begin: RGN_MID1_FC_SINGLE_MST_0

      reg [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid1_r;

      always @(posedge clk) begin: RGN_MID1_REG
        integer i; 
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mid1_en[i]) begin
            rgn_mid1_r[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
              rgn_mid1_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
          end
        end
      end

      assign rgn_mid1_int = rgn_mid1_r;

    end

    assign rgn_mid1_o = rgn_mid1_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid1_curr_rgn;
    always @(*) begin: RGN_MID1_CURRENT_RGN
      integer i;
      rgn_mid1_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid1_curr_rgn =
            rgn_mid1_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid1_rgn_o = rgn_mid1_curr_rgn;

  end else begin: RGN_MID1_PE_LVL_0
    assign rgn_mid1_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid1_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 3)) begin: RGN_MID2_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid2_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid2_aux;
    assign rgn_mid2_aux = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0];

    if (FC_SINGLE_MST == 1) begin: RGN_MID2_FC_SINGLE_MST_1

      assign rgn_mid2_int = {FC_NUM_RGN{rgn_mid2_aux}};

    end else begin: RGN_MID2_FC_SINGLE_MST_0

      reg [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid2_r;

      always @(posedge clk) begin: RGN_MID2_REG
        integer i; 
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mid2_en[i]) begin
            rgn_mid2_r[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
              rgn_mid2_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
          end
        end
      end

      assign rgn_mid2_int = rgn_mid2_r;

    end

    assign rgn_mid2_o = rgn_mid2_int;


    reg [FC_MST_ID_WIDTH-1:0] rgn_mid2_curr_rgn;
    always @(*) begin: RGN_MID2_CURRENT_RGN
      integer i;
      rgn_mid2_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid2_curr_rgn =
            rgn_mid2_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid2_rgn_o = rgn_mid2_curr_rgn;

  end else begin: RGN_MID2_PE_LVL_0
    assign rgn_mid2_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid2_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 4)) begin: RGN_MID3_PE_LVL_NOT_0

    wire [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid3_int;

    wire [FC_MST_ID_WIDTH-1:0] rgn_mid3_aux;
    assign rgn_mid3_aux = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0];

    if (FC_SINGLE_MST == 1) begin: RGN_MID3_FC_SINGLE_MST_1

      assign rgn_mid3_int = {FC_NUM_RGN{rgn_mid3_aux}};

    end else begin: RGN_MID3_FC_SINGLE_MST_0

      reg [FC_NUM_RGN*FC_MST_ID_WIDTH-1:0] rgn_mid3_r;

      always @(posedge clk) begin: RGN_MID3_REG
        integer i; 
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mid3_en[i]) begin
            rgn_mid3_r[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH] <=
              rgn_mid3_i[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
          end
        end
      end

      assign rgn_mid3_int = rgn_mid3_r;

    end

    assign rgn_mid3_o = rgn_mid3_int;

    reg [FC_MST_ID_WIDTH-1:0] rgn_mid3_curr_rgn;
    always @(*) begin: RGN_MID3_CURRENT_RGN
      integer i;
      rgn_mid3_curr_rgn = {FC_MST_ID_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i==rwe_ctrl_o) begin
          rgn_mid3_curr_rgn =
            rgn_mid3_o[(i+1)*FC_MST_ID_WIDTH-1-:FC_MST_ID_WIDTH];
        end
      end
    end

    assign rgn_mid3_rgn_o = rgn_mid3_curr_rgn;

  end else begin: RGN_MID3_PE_LVL_0
    assign rgn_mid3_o     = {FC_NUM_RGN*FC_MST_ID_WIDTH{1'b0}};
    assign rgn_mid3_rgn_o = {FC_MST_ID_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL0_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL0_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL0_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL0_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL0_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL0_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL0_NSUX_RO = (FC_INST_SPT == 0);

generate
  if (FC_PE_LVL > 0) begin: RGN_MPL0_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl0_any_mst_int;

    if (FC_SINGLE_MST == 1) begin: RGN_MPL0_ANY_MST_RO

      assign rgn_mpl0_any_mst_int = {FC_NUM_RGN{1'b0}};

    end else begin: RGN_MPL0_ANY_MST_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_any_mst_r;

      always @(posedge clk) begin: RGN_MPL0_ANY_MST_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_any_mst_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-1];
          end
        end
      end
      assign rgn_mpl0_any_mst_int = rgn_mpl0_any_mst_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_spx_int;

    if (P_RGN_MPL0_SPX_RO == 1) begin: RGN_MPL0_SPX_RO
      assign rgn_mpl0_spx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_spx_r;

      always @(posedge clk) begin: RGN_MPL0_SPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_spx_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-2];
          end
        end
      end
      assign rgn_mpl0_spx_int = rgn_mpl0_spx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_spw_int;

    if (P_RGN_MPL0_SPW_RO == 1) begin: RGN_MPL0_SPW_RO
      assign rgn_mpl0_spw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_spw_r;

      always @(posedge clk) begin: RGN_MPL0_SPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_spw_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-3];
          end
        end
      end
      assign rgn_mpl0_spw_int = rgn_mpl0_spw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_spr_int;

    if (P_RGN_MPL0_SPR_RO == 1) begin: RGN_MPL0_SPR_RO
      assign rgn_mpl0_spr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_spr_r;

      always @(posedge clk) begin: RGN_MPL0_SPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_spr_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-4];
          end
        end
      end
      assign rgn_mpl0_spr_int = rgn_mpl0_spr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_sux_int;

    if (P_RGN_MPL0_SUX_RO == 1) begin: RGN_MPL0_SUX_RO
      assign rgn_mpl0_sux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_sux_r;

      always @(posedge clk) begin: RGN_MPL0_SUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_sux_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-5];
          end
        end
      end
      assign rgn_mpl0_sux_int = rgn_mpl0_sux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_suw_int;

    if (P_RGN_MPL0_SUW_RO == 1) begin: RGN_MPL0_SUW_RO
      assign rgn_mpl0_suw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SUW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_suw_r;

      always @(posedge clk) begin: RGN_MPL0_SUW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_suw_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-6];
          end
        end
      end
      assign rgn_mpl0_suw_int = rgn_mpl0_suw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_sur_int;

    if (P_RGN_MPL0_SUR_RO == 1) begin: RGN_MPL0_SUR_RO
      assign rgn_mpl0_sur_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_SUR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_sur_r;

      always @(posedge clk) begin: RGN_MPL0_SUR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_sur_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-7];
          end
        end
      end
      assign rgn_mpl0_sur_int = rgn_mpl0_sur_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspx_int;

    if (P_RGN_MPL0_NSPX_RO == 1) begin: RGN_MPL0_NSPX_RO
      assign rgn_mpl0_nspx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_NSPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_nspx_r;

      always @(posedge clk) begin: RGN_MPL0_NSPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nspx_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-8];
          end
        end
      end
      assign rgn_mpl0_nspx_int = rgn_mpl0_nspx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspw_int;

    if (P_RGN_MPL0_NSPW_RO == 1) begin: RGN_MPL0_NSPW_RO
      assign rgn_mpl0_nspw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_NSPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_nspw_r;

      always @(posedge clk) begin: RGN_MPL0_NSPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nspw_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-9];
          end
        end
      end
      assign rgn_mpl0_nspw_int = rgn_mpl0_nspw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nspr_int;

    if (P_RGN_MPL0_NSPR_RO == 1) begin: RGN_MPL0_NSPR_RO
      assign rgn_mpl0_nspr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_NSPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_nspr_r;

      always @(posedge clk) begin: RGN_MPL0_NSPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nspr_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-10];
          end
        end
      end
      assign rgn_mpl0_nspr_int = rgn_mpl0_nspr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsux_int;

    if (P_RGN_MPL0_NSUX_RO == 1) begin: RGN_MPL0_NSUX_RO
      assign rgn_mpl0_nsux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL0_NSUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl0_nsux_r;

      always @(posedge clk) begin: RGN_MPL0_NSUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl0_en[i]) begin
            rgn_mpl0_nsux_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-11];
          end
        end
      end
      assign rgn_mpl0_nsux_int = rgn_mpl0_nsux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsuw_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl0_nsuw_r;

    always @(posedge clk) begin: RGN_MPL0_NSUW_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl0_en[i]) begin
          rgn_mpl0_nsuw_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-12];
        end
      end
    end
    assign rgn_mpl0_nsuw_int = rgn_mpl0_nsuw_r;


    wire [FC_NUM_RGN-1:0] rgn_mpl0_nsur_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl0_nsur_r;

    always @(posedge clk) begin: RGN_MPL0_NSUR_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl0_en[i]) begin
          rgn_mpl0_nsur_r[i] <= rgn_mpl0_i[(i+1)*RGN_MPL0_WIDTH-13];
        end
      end
    end
    assign rgn_mpl0_nsur_int = rgn_mpl0_nsur_r;


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL0_ASSEMBLE_OUTPUT
      assign rgn_mpl0_o[(i+1)*RGN_MPL0_WIDTH-1-:RGN_MPL0_WIDTH] =
        {rgn_mpl0_any_mst_int[i],
         rgn_mpl0_spx_int[i],
         rgn_mpl0_spw_int[i],
         rgn_mpl0_spr_int[i],
         rgn_mpl0_sux_int[i],
         rgn_mpl0_suw_int[i],
         rgn_mpl0_sur_int[i],
         rgn_mpl0_nspx_int[i],
         rgn_mpl0_nspw_int[i],
         rgn_mpl0_nspr_int[i],
         rgn_mpl0_nsux_int[i],
         rgn_mpl0_nsuw_int[i],
         rgn_mpl0_nsur_int[i]};
    end


    reg [RGN_MPL0_WIDTH-1:0] rgn_mpl0_curr_rgn;

    always @(*) begin: RGN_MPL0_CURRENT_RGN
      integer i;
      rgn_mpl0_curr_rgn = {RGN_MPL0_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl0_curr_rgn =
            rgn_mpl0_o[(i+1)*RGN_MPL0_WIDTH-1-:RGN_MPL0_WIDTH];
        end
      end
    end

    assign rgn_mpl0_rgn_o = rgn_mpl0_curr_rgn;

  end else begin: RGN_MPL0_PE_LVL_0
    assign rgn_mpl0_o     = {FC_NUM_RGN*RGN_MPL0_WIDTH{1'b0}};
    assign rgn_mpl0_rgn_o = {RGN_MPL0_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL1_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL1_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL1_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL1_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL1_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL1_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL1_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 2)) begin: RGN_MPL1_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl1_any_mst_int;

    assign rgn_mpl1_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spx_int;

    if (P_RGN_MPL1_SPX_RO == 1) begin: RGN_MPL1_SPX_RO
      assign rgn_mpl1_spx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_spx_r;

      always @(posedge clk) begin: RGN_MPL1_SPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_spx_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-2];
          end
        end
      end
      assign rgn_mpl1_spx_int = rgn_mpl1_spx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spw_int;

    if (P_RGN_MPL1_SPW_RO == 1) begin: RGN_MPL1_SPW_RO
      assign rgn_mpl1_spw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_spw_r;

      always @(posedge clk) begin: RGN_MPL1_SPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_spw_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-3];
          end
        end
      end
      assign rgn_mpl1_spw_int = rgn_mpl1_spw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_spr_int;

    if (P_RGN_MPL1_SPR_RO == 1) begin: RGN_MPL1_SPR_RO
      assign rgn_mpl1_spr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_spr_r;

      always @(posedge clk) begin: RGN_MPL1_SPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_spr_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-4];
          end
        end
      end
      assign rgn_mpl1_spr_int = rgn_mpl1_spr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_sux_int;

    if (P_RGN_MPL1_SUX_RO == 1) begin: RGN_MPL1_SUX_RO
      assign rgn_mpl1_sux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_sux_r;

      always @(posedge clk) begin: RGN_MPL1_SUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_sux_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-5];
          end
        end
      end
      assign rgn_mpl1_sux_int = rgn_mpl1_sux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_suw_int;

    if (P_RGN_MPL1_SUW_RO == 1) begin: RGN_MPL1_SUW_RO
      assign rgn_mpl1_suw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SUW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_suw_r;

      always @(posedge clk) begin: RGN_MPL1_SUW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_suw_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-6];
          end
        end
      end
      assign rgn_mpl1_suw_int = rgn_mpl1_suw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_sur_int;

    if (P_RGN_MPL1_SUR_RO == 1) begin: RGN_MPL1_SUR_RO
      assign rgn_mpl1_sur_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_SUR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_sur_r;

      always @(posedge clk) begin: RGN_MPL1_SUR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_sur_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-7];
          end
        end
      end
      assign rgn_mpl1_sur_int = rgn_mpl1_sur_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspx_int;

    if (P_RGN_MPL1_NSPX_RO == 1) begin: RGN_MPL1_NSPX_RO
      assign rgn_mpl1_nspx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_NSPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_nspx_r;

      always @(posedge clk) begin: RGN_MPL1_NSPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nspx_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-8];
          end
        end
      end
      assign rgn_mpl1_nspx_int = rgn_mpl1_nspx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspw_int;

    if (P_RGN_MPL1_NSPW_RO == 1) begin: RGN_MPL1_NSPW_RO
      assign rgn_mpl1_nspw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_NSPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_nspw_r;

      always @(posedge clk) begin: RGN_MPL1_NSPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nspw_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-9];
          end
        end
      end
      assign rgn_mpl1_nspw_int = rgn_mpl1_nspw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nspr_int;

    if (P_RGN_MPL1_NSPR_RO == 1) begin: RGN_MPL1_NSPR_RO
      assign rgn_mpl1_nspr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_NSPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_nspr_r;

      always @(posedge clk) begin: RGN_MPL1_NSPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nspr_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-10];
          end
        end
      end
      assign rgn_mpl1_nspr_int = rgn_mpl1_nspr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsux_int;

    if (P_RGN_MPL1_NSUX_RO == 1) begin: RGN_MPL1_NSUX_RO
      assign rgn_mpl1_nsux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL1_NSUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl1_nsux_r;

      always @(posedge clk) begin: RGN_MPL1_NSUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl1_en[i]) begin
            rgn_mpl1_nsux_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-11];
          end
        end
      end
      assign rgn_mpl1_nsux_int = rgn_mpl1_nsux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsuw_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl1_nsuw_r;

    always @(posedge clk) begin: RGN_MPL1_NSUW_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl1_en[i]) begin
          rgn_mpl1_nsuw_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-12];
        end
      end
    end
    assign rgn_mpl1_nsuw_int = rgn_mpl1_nsuw_r;


    wire [FC_NUM_RGN-1:0] rgn_mpl1_nsur_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl1_nsur_r;

    always @(posedge clk) begin: RGN_MPL1_NSUR_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl1_en[i]) begin
          rgn_mpl1_nsur_r[i] <= rgn_mpl1_i[(i+1)*RGN_MPL1_WIDTH-13];
        end
      end
    end
    assign rgn_mpl1_nsur_int = rgn_mpl1_nsur_r;


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL1_ASSEMBLE_OUTPUT
      assign rgn_mpl1_o[(i+1)*RGN_MPL1_WIDTH-1-:RGN_MPL1_WIDTH] =
        {rgn_mpl1_any_mst_int[i],
         rgn_mpl1_spx_int[i],
         rgn_mpl1_spw_int[i],
         rgn_mpl1_spr_int[i],
         rgn_mpl1_sux_int[i],
         rgn_mpl1_suw_int[i],
         rgn_mpl1_sur_int[i],
         rgn_mpl1_nspx_int[i],
         rgn_mpl1_nspw_int[i],
         rgn_mpl1_nspr_int[i],
         rgn_mpl1_nsux_int[i],
         rgn_mpl1_nsuw_int[i],
         rgn_mpl1_nsur_int[i]};
    end


    reg [RGN_MPL1_WIDTH-1:0] rgn_mpl1_curr_rgn;

    always @(*) begin: RGN_MPL1_CURRENT_RGN
      integer i;
      rgn_mpl1_curr_rgn = {RGN_MPL1_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl1_curr_rgn =
            rgn_mpl1_o[(i+1)*RGN_MPL1_WIDTH-1-:RGN_MPL1_WIDTH];
        end
      end
    end

    assign rgn_mpl1_rgn_o = rgn_mpl1_curr_rgn;

  end else begin: RGN_MPL1_PE_LVL_0
    assign rgn_mpl1_o     = {FC_NUM_RGN*RGN_MPL1_WIDTH{1'b0}};
    assign rgn_mpl1_rgn_o = {RGN_MPL1_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL2_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL2_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL2_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL2_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL2_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL2_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL2_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 3)) begin: RGN_MPL2_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl2_any_mst_int;

    assign rgn_mpl2_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spx_int;

    if (P_RGN_MPL2_SPX_RO == 1) begin: RGN_MPL2_SPX_RO
      assign rgn_mpl2_spx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_spx_r;

      always @(posedge clk) begin: RGN_MPL2_SPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_spx_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-2];
          end
        end
      end
      assign rgn_mpl2_spx_int = rgn_mpl2_spx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spw_int;

    if (P_RGN_MPL2_SPW_RO == 1) begin: RGN_MPL2_SPW_RO
      assign rgn_mpl2_spw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_spw_r;

      always @(posedge clk) begin: RGN_MPL2_SPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_spw_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-3];
          end
        end
      end
      assign rgn_mpl2_spw_int = rgn_mpl2_spw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_spr_int;

    if (P_RGN_MPL2_SPR_RO == 1) begin: RGN_MPL2_SPR_RO
      assign rgn_mpl2_spr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_spr_r;

      always @(posedge clk) begin: RGN_MPL2_SPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_spr_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-4];
          end
        end
      end
      assign rgn_mpl2_spr_int = rgn_mpl2_spr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_sux_int;

    if (P_RGN_MPL2_SUX_RO == 1) begin: RGN_MPL2_SUX_RO
      assign rgn_mpl2_sux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_sux_r;

      always @(posedge clk) begin: RGN_MPL2_SUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_sux_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-5];
          end
        end
      end
      assign rgn_mpl2_sux_int = rgn_mpl2_sux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_suw_int;

    if (P_RGN_MPL2_SUW_RO == 1) begin: RGN_MPL2_SUW_RO
      assign rgn_mpl2_suw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SUW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_suw_r;

      always @(posedge clk) begin: RGN_MPL2_SUW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_suw_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-6];
          end
        end
      end
      assign rgn_mpl2_suw_int = rgn_mpl2_suw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_sur_int;

    if (P_RGN_MPL2_SUR_RO == 1) begin: RGN_MPL2_SUR_RO
      assign rgn_mpl2_sur_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_SUR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_sur_r;

      always @(posedge clk) begin: RGN_MPL2_SUR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_sur_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-7];
          end
        end
      end
      assign rgn_mpl2_sur_int = rgn_mpl2_sur_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspx_int;

    if (P_RGN_MPL2_NSPX_RO == 1) begin: RGN_MPL2_NSPX_RO
      assign rgn_mpl2_nspx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_NSPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_nspx_r;

      always @(posedge clk) begin: RGN_MPL2_NSPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nspx_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-8];
          end
        end
      end
      assign rgn_mpl2_nspx_int = rgn_mpl2_nspx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspw_int;

    if (P_RGN_MPL2_NSPW_RO == 1) begin: RGN_MPL2_NSPW_RO
      assign rgn_mpl2_nspw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_NSPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_nspw_r;

      always @(posedge clk) begin: RGN_MPL2_NSPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nspw_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-9];
          end
        end
      end
      assign rgn_mpl2_nspw_int = rgn_mpl2_nspw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nspr_int;

    if (P_RGN_MPL2_NSPR_RO == 1) begin: RGN_MPL2_NSPR_RO
      assign rgn_mpl2_nspr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_NSPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_nspr_r;

      always @(posedge clk) begin: RGN_MPL2_NSPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nspr_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-10];
          end
        end
      end
      assign rgn_mpl2_nspr_int = rgn_mpl2_nspr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsux_int;

    if (P_RGN_MPL2_NSUX_RO == 1) begin: RGN_MPL2_NSUX_RO
      assign rgn_mpl2_nsux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL2_NSUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl2_nsux_r;

      always @(posedge clk) begin: RGN_MPL2_NSUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl2_en[i]) begin
            rgn_mpl2_nsux_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-11];
          end
        end
      end
      assign rgn_mpl2_nsux_int = rgn_mpl2_nsux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsuw_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl2_nsuw_r;

    always @(posedge clk) begin: RGN_MPL2_NSUW_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl2_en[i]) begin
          rgn_mpl2_nsuw_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-12];
        end
      end
    end
    assign rgn_mpl2_nsuw_int = rgn_mpl2_nsuw_r;


    wire [FC_NUM_RGN-1:0] rgn_mpl2_nsur_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl2_nsur_r;

    always @(posedge clk) begin: RGN_MPL2_NSUR_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl2_en[i]) begin
          rgn_mpl2_nsur_r[i] <= rgn_mpl2_i[(i+1)*RGN_MPL2_WIDTH-13];
        end
      end
    end
    assign rgn_mpl2_nsur_int = rgn_mpl2_nsur_r;


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL2_ASSEMBLE_OUTPUT
      assign rgn_mpl2_o[(i+1)*RGN_MPL2_WIDTH-1-:RGN_MPL2_WIDTH] =
        {rgn_mpl2_any_mst_int[i],
         rgn_mpl2_spx_int[i],
         rgn_mpl2_spw_int[i],
         rgn_mpl2_spr_int[i],
         rgn_mpl2_sux_int[i],
         rgn_mpl2_suw_int[i],
         rgn_mpl2_sur_int[i],
         rgn_mpl2_nspx_int[i],
         rgn_mpl2_nspw_int[i],
         rgn_mpl2_nspr_int[i],
         rgn_mpl2_nsux_int[i],
         rgn_mpl2_nsuw_int[i],
         rgn_mpl2_nsur_int[i]};
    end


    reg [RGN_MPL2_WIDTH-1:0] rgn_mpl2_curr_rgn;

    always @(*) begin: RGN_MPL2_CURRENT_RGN
      integer i;
      rgn_mpl2_curr_rgn = {RGN_MPL2_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl2_curr_rgn =
            rgn_mpl2_o[(i+1)*RGN_MPL2_WIDTH-1-:RGN_MPL2_WIDTH];
        end
      end
    end

    assign rgn_mpl2_rgn_o = rgn_mpl2_curr_rgn;

  end else begin: RGN_MPL2_PE_LVL_0
    assign rgn_mpl2_o     = {FC_NUM_RGN*RGN_MPL2_WIDTH{1'b0}};
    assign rgn_mpl2_rgn_o = {RGN_MPL2_WIDTH{1'b0}}           ;
  end
endgenerate


localparam P_RGN_MPL3_SPX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0) ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL3_SPW_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_SPR_RO = (FC_SEC_SPT == 0)  ||
                             (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_SUX_RO = (FC_SEC_SPT == 0)  ||
                             (FC_INST_SPT == 0);

localparam P_RGN_MPL3_SUW_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL3_SUR_RO = (FC_SEC_SPT == 0);

localparam P_RGN_MPL3_NSPX_RO = (FC_PRIV_SPT == 0) || (FC_INST_SPT == 0);

localparam P_RGN_MPL3_NSPW_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_NSPR_RO = (FC_PRIV_SPT == 0);

localparam P_RGN_MPL3_NSUX_RO = (FC_INST_SPT == 0);

generate
  if ((FC_PE_LVL > 0) && (FC_NUM_MPE >= 4)) begin: RGN_MPL3_PE_LVL_NOT_0



    wire [FC_NUM_RGN-1:0] rgn_mpl3_any_mst_int;

    assign rgn_mpl3_any_mst_int = {FC_NUM_RGN{1'b0}};


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spx_int;

    if (P_RGN_MPL3_SPX_RO == 1) begin: RGN_MPL3_SPX_RO
      assign rgn_mpl3_spx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_spx_r;

      always @(posedge clk) begin: RGN_MPL3_SPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_spx_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-2];
          end
        end
      end
      assign rgn_mpl3_spx_int = rgn_mpl3_spx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spw_int;

    if (P_RGN_MPL3_SPW_RO == 1) begin: RGN_MPL3_SPW_RO
      assign rgn_mpl3_spw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_spw_r;

      always @(posedge clk) begin: RGN_MPL3_SPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_spw_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-3];
          end
        end
      end
      assign rgn_mpl3_spw_int = rgn_mpl3_spw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_spr_int;

    if (P_RGN_MPL3_SPR_RO == 1) begin: RGN_MPL3_SPR_RO
      assign rgn_mpl3_spr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_spr_r;

      always @(posedge clk) begin: RGN_MPL3_SPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_spr_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-4];
          end
        end
      end
      assign rgn_mpl3_spr_int = rgn_mpl3_spr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_sux_int;

    if (P_RGN_MPL3_SUX_RO == 1) begin: RGN_MPL3_SUX_RO
      assign rgn_mpl3_sux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_sux_r;

      always @(posedge clk) begin: RGN_MPL3_SUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_sux_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-5];
          end
        end
      end
      assign rgn_mpl3_sux_int = rgn_mpl3_sux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_suw_int;

    if (P_RGN_MPL3_SUW_RO == 1) begin: RGN_MPL3_SUW_RO
      assign rgn_mpl3_suw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SUW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_suw_r;

      always @(posedge clk) begin: RGN_MPL3_SUW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_suw_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-6];
          end
        end
      end
      assign rgn_mpl3_suw_int = rgn_mpl3_suw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_sur_int;

    if (P_RGN_MPL3_SUR_RO == 1) begin: RGN_MPL3_SUR_RO
      assign rgn_mpl3_sur_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_SUR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_sur_r;

      always @(posedge clk) begin: RGN_MPL3_SUR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_sur_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-7];
          end
        end
      end
      assign rgn_mpl3_sur_int = rgn_mpl3_sur_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspx_int;

    if (P_RGN_MPL3_NSPX_RO == 1) begin: RGN_MPL3_NSPX_RO
      assign rgn_mpl3_nspx_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_NSPX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_nspx_r;

      always @(posedge clk) begin: RGN_MPL3_NSPX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nspx_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-8];
          end
        end
      end
      assign rgn_mpl3_nspx_int = rgn_mpl3_nspx_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspw_int;

    if (P_RGN_MPL3_NSPW_RO == 1) begin: RGN_MPL3_NSPW_RO
      assign rgn_mpl3_nspw_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_NSPW_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_nspw_r;

      always @(posedge clk) begin: RGN_MPL3_NSPW_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nspw_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-9];
          end
        end
      end
      assign rgn_mpl3_nspw_int = rgn_mpl3_nspw_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nspr_int;

    if (P_RGN_MPL3_NSPR_RO == 1) begin: RGN_MPL3_NSPR_RO
      assign rgn_mpl3_nspr_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_NSPR_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_nspr_r;

      always @(posedge clk) begin: RGN_MPL3_NSPR_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nspr_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-10];
          end
        end
      end
      assign rgn_mpl3_nspr_int = rgn_mpl3_nspr_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsux_int;

    if (P_RGN_MPL3_NSUX_RO == 1) begin: RGN_MPL3_NSUX_RO
      assign rgn_mpl3_nsux_int = {FC_NUM_RGN{1'b0}};
    end else begin: RGN_MPL3_NSUX_RW
      reg [FC_NUM_RGN-1:0] rgn_mpl3_nsux_r;

      always @(posedge clk) begin: RGN_MPL3_NSUX_REG
        integer i;
        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          if (rgn_mpl3_en[i]) begin
            rgn_mpl3_nsux_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-11];
          end
        end
      end
      assign rgn_mpl3_nsux_int = rgn_mpl3_nsux_r;
    end


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsuw_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl3_nsuw_r;

    always @(posedge clk) begin: RGN_MPL3_NSUW_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl3_en[i]) begin
          rgn_mpl3_nsuw_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-12];
        end
      end
    end
    assign rgn_mpl3_nsuw_int = rgn_mpl3_nsuw_r;


    wire [FC_NUM_RGN-1:0] rgn_mpl3_nsur_int;

    reg [FC_NUM_RGN-1:0] rgn_mpl3_nsur_r;

    always @(posedge clk) begin: RGN_MPL3_NSUR_REG
      integer i;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (rgn_mpl3_en[i]) begin
          rgn_mpl3_nsur_r[i] <= rgn_mpl3_i[(i+1)*RGN_MPL3_WIDTH-13];
        end
      end
    end
    assign rgn_mpl3_nsur_int = rgn_mpl3_nsur_r;


    for (i=0; i<FC_NUM_RGN; i=i+1) begin: RGN_MPL3_ASSEMBLE_OUTPUT
      assign rgn_mpl3_o[(i+1)*RGN_MPL3_WIDTH-1-:RGN_MPL3_WIDTH] =
        {rgn_mpl3_any_mst_int[i],
         rgn_mpl3_spx_int[i],
         rgn_mpl3_spw_int[i],
         rgn_mpl3_spr_int[i],
         rgn_mpl3_sux_int[i],
         rgn_mpl3_suw_int[i],
         rgn_mpl3_sur_int[i],
         rgn_mpl3_nspx_int[i],
         rgn_mpl3_nspw_int[i],
         rgn_mpl3_nspr_int[i],
         rgn_mpl3_nsux_int[i],
         rgn_mpl3_nsuw_int[i],
         rgn_mpl3_nsur_int[i]};
    end


    reg [RGN_MPL3_WIDTH-1:0] rgn_mpl3_curr_rgn;

    always @(*) begin: RGN_MPL3_CURRENT_RGN
      integer i;
      rgn_mpl3_curr_rgn = {RGN_MPL3_WIDTH{1'b0}};
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        if (i == rwe_ctrl_o) begin
          rgn_mpl3_curr_rgn =
            rgn_mpl3_o[(i+1)*RGN_MPL3_WIDTH-1-:RGN_MPL3_WIDTH];
        end
      end
    end

    assign rgn_mpl3_rgn_o = rgn_mpl3_curr_rgn;

  end else begin: RGN_MPL3_PE_LVL_0
    assign rgn_mpl3_o     = {FC_NUM_RGN*RGN_MPL3_WIDTH{1'b0}};
    assign rgn_mpl3_rgn_o = {RGN_MPL3_WIDTH{1'b0}}           ;
  end
endgenerate


wire [2:0] fe_irq;
wire       fe_irq_valid;

generate
  if (FC_PE_LVL > 0) begin: FAULT_ENTRY_PE_LVL_NOT_0

    reg  [FE_TAL_WIDTH-1:0]    fe_tal_int;
    reg  [FE_TAU_WIDTH-1:0]    fe_tau_int;
    reg  [FE_TP_WIDTH-1:0]     fe_tp_int ;
    reg  [FC_MST_ID_WIDTH-1:0] fe_mid_aux;
    wire [FC_MST_ID_WIDTH-1:0] fe_mid_int;

    reg [2:0]                fe_ctrl_int;

    reg [2:0]                fe_irq_int;
    reg                      fe_irq_valid_int;

    reg                      last_fe_rd;
    wire                     fe_rd_wr;
    wire                     fe_rd_priority;

    assign fe_rd_wr = fe_rdch_en && fe_wrch_en;

    always @ (posedge clk or negedge reset_n) begin: rd_wr_fe_trkr
      if (!reset_n) begin
        last_fe_rd <= 1'b0;
      end
      else begin
        if (default_state_i) begin
          last_fe_rd <= 1'b0;
        end
        else if (fe_rd_wr) begin
          last_fe_rd <= ~last_fe_rd;
        end
      end
    end 

    assign fe_rd_priority = !fe_rd_wr || (fe_rd_wr && !last_fe_rd);

    always @(posedge clk or negedge reset_n)
    begin: fe_mux
      if (!reset_n) begin
        fe_tal_int       <= {FE_TAL_WIDTH{1'b0}};
        fe_tau_int       <= {FE_TAU_WIDTH{1'b0}};
        fe_tp_int        <= {FE_TP_WIDTH{1'b0}};
        fe_ctrl_int[2:0] <= 3'b000;
      end
      else if (default_state_i) begin
        fe_tal_int       <= {FE_TAL_WIDTH{1'b0}};
        fe_tau_int       <= {FE_TAU_WIDTH{1'b0}};
        fe_tp_int        <= {FE_TP_WIDTH{1'b0}};
        fe_ctrl_int[2:0] <= 3'b000;
      end
      else if (fe_rdch_en && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_tal_int       <= fe_tal_rdch_i;
        fe_tau_int       <= fe_tau_rdch_i;
        fe_tp_int        <= fe_tp_rdch_i;
        fe_ctrl_int[2:1] <= 2'b11;
        fe_ctrl_int[0]   <= fe_type_rdch_i;
      end
      else if (fe_wrch_en && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_tal_int       <= fe_tal_wrch_i;
        fe_tau_int       <= fe_tau_wrch_i;
        fe_tp_int        <= fe_tp_wrch_i;
        fe_ctrl_int[2:1] <= 2'b11;
        fe_ctrl_int[0]   <= fe_type_wrch_i;
      end
      else if (fe_ctrl_i[0] && fe_ctrl_en) begin
        fe_tal_int     <= {FE_TAL_WIDTH{1'b0}};
        fe_tau_int     <= {FE_TAU_WIDTH{1'b0}};
        fe_tp_int      <= {FE_TP_WIDTH{1'b0}};
        fe_ctrl_int[2] <= 1'b0;
        fe_ctrl_int[1] <= 1'b0;
      end
      else if (!fe_ctrl_o[4]) begin
        fe_tal_int     <= {FE_TAL_WIDTH{1'b0}};
        fe_tau_int     <= {FE_TAU_WIDTH{1'b0}};
        fe_tp_int      <= {FE_TP_WIDTH{1'b0}};
        fe_ctrl_int[2] <= 1'b0;
        fe_ctrl_int[0] <= 1'b0;
      end
    end 

    if (FC_SINGLE_MST == 0) begin : FE_REG_MST_MID
      always @(posedge clk or negedge reset_n)
      begin: fe_mux_mid
        if (!reset_n) begin
          fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
        end
        else if (default_state_i) begin
          fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
        end
        else if (fe_rdch_en && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
          fe_mid_aux <= fe_mid_rdch_i;
        end
        else if (fe_wrch_en && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
          fe_mid_aux <= fe_mid_wrch_i;
        end
        else if (fe_ctrl_i[0] && fe_ctrl_en) begin
          fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
        end
        else if (!fe_ctrl_o[4]) begin
          fe_mid_aux <= {FC_MST_ID_WIDTH{1'b0}};
        end
      end 

      assign fe_mid_int = fe_mid_aux;
    end
    else begin: FE_SINGLE_MST_MID
      assign fe_mid_int = fe_ctrl_o[4] ? FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0] : {FC_MST_ID_WIDTH{1'b0}};
    end

    always @* begin: fe_irq_comb
      fe_irq_int       = {3{1'b0}};
      fe_irq_valid_int = 1'b0;

      if (fe_rdch_en && !fe_type_rdch_i && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_irq_int[0]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end
      else if (fe_wrch_en && !fe_type_wrch_i && !(fe_rdch_en && fe_type_rdch_i && fe_rd_priority) && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_irq_int[0]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end

      if (fe_rdch_en && fe_type_rdch_i && fe_rd_priority && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_irq_int[1]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end
      else if (fe_wrch_en && fe_type_wrch_i && !(fe_rdch_en && !fe_type_rdch_i && fe_rd_priority) && (!fe_ctrl_o[4] || (fe_ctrl_o[4] && fe_ctrl_i[0] && fe_ctrl_en))) begin
        fe_irq_int[1]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end

      if (fe_wrch_en && fe_rdch_en) begin
        fe_irq_int[2]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end
      else if ((fe_wrch_en || fe_rdch_en) && fe_ctrl_o[4] && !(fe_ctrl_i[0] && fe_ctrl_en)) begin
        fe_irq_int[2]    = 1'b1;
        fe_irq_valid_int = 1'b1;
      end

    end 

    assign fe_tal_o        = fe_tal_int;
    assign fe_tau_o        = fe_tau_int;
    assign fe_tp_o         = fe_tp_int;
    assign fe_mid_o        = fe_mid_int;
    assign fe_ctrl_o       = {fe_ctrl_int, {3{1'b0}}};
    assign fe_irq          = fe_irq_int;
    assign fe_irq_valid    = fe_irq_valid_int;

  end else begin: FAULT_ENTRY_PE_LVL_0

    assign fe_tal_o        = {FE_TAL_WIDTH{1'b0}};
    assign fe_tau_o        = {FE_TAU_WIDTH{1'b0}};
    assign fe_tp_o         = {FE_TP_WIDTH{1'b0}};
    assign fe_mid_o        = {FC_MST_ID_WIDTH{1'b0}};
    assign fe_ctrl_o       = {FE_CTRL_WIDTH{1'b0}};
    assign fe_irq          = {3{1'b0}};
    assign fe_irq_valid    = 1'b0;

  end
endgenerate


generate
  if (FC_ME_LVL > 0) begin: ME_CTRL_ME_LVL_NOT_0

    reg [ME_CTRL_WIDTH-1:0]                me_ctrl_r  ;

    always @(posedge clk or negedge reset_n) begin: ME_CTRL_REG
      if (!reset_n) begin
        me_ctrl_r <= ME_CTRL_RST_VAL;
      end else begin
        if (default_state_i) begin
          me_ctrl_r <= ME_CTRL_RST_VAL;
        end
        else if (me_ctrl_en) begin
          me_ctrl_r <= me_ctrl_i;
        end
      end
    end

    assign me_ctrl_o = me_ctrl_r;

  end else begin: ME_CTRL_ME_LVL_0

    assign me_ctrl_o = {ME_CTRL_WIDTH{1'b0}};

  end
endgenerate



localparam EDR_FIFO_DEPTH   = 1; 
localparam REPORT_WIDTH     = FC_MST_ID_WIDTH + 32 + 32 + 4;
localparam EDR_COUNT_WIDTH  = firewall_f0_log2(EDR_FIFO_DEPTH);

wire [REPORT_WIDTH-1:0]    edr_fifo [EDR_FIFO_DEPTH-1:0];
wire [EDR_COUNT_WIDTH-1:0] edr_count;

wire edr_shift;

wire [1:0] edr_irq;
wire       edr_irq_valid;

wire last_edr_rd;
wire edr_rd_wr;
wire edr_rd_priority;

wire edr_load;

generate
  if (FC_ME_LVL > 0) begin: ME_LVL_NOT_0

    reg last_edr_rd_int;
    wire [EDR_CTRL_WIDTH-2:0] edr_ctrl_int;
    reg [EDR_COUNT_WIDTH-1:0] edr_count_int;
    reg [REPORT_WIDTH-1:0] edr_fifo_r [EDR_FIFO_DEPTH-1:0];
    reg [1:0] edr_irq_int;
    reg       edr_irq_valid_int;
    genvar i;

    assign edr_rd_wr = rd_edr_wen_i && wr_edr_wen_i;

    always @ (posedge clk or negedge reset_n) begin: rd_wr_edr_trkr
      if (!reset_n) begin
        last_edr_rd_int <= 1'b0;
      end
      else begin
        if (default_state_i) begin
          last_edr_rd_int <= 1'b0;
        end
        else if (edr_rd_wr) begin
          last_edr_rd_int <= ~last_edr_rd_int;
        end
      end
    end 

    assign last_edr_rd = last_edr_rd_int;

    assign edr_rd_priority = !edr_rd_wr || (edr_rd_wr && !last_edr_rd);

    assign edr_ctrl_int[0] = (edr_count > 0); 
    assign edr_ctrl_int[1] = (edr_count == 1); 

    assign edr_ctrl_o = {edr_ctrl_int, 1'b0};

    assign edr_shift  = edr_ctrl_i[0] && 
                        edr_ctrl_en   && 
                        edr_ctrl_o[1];   

    assign edr_load = ((edr_count < EDR_FIFO_DEPTH) && (rd_edr_wen_i || wr_edr_wen_i)) | (edr_shift & (rd_edr_wen_i || wr_edr_wen_i));

    always @(posedge clk or negedge reset_n)
    begin:EDR_REGS1
      if (!reset_n) begin
        edr_count_int <= {EDR_COUNT_WIDTH {1'b0}};
      end
      else begin
        if (default_state_i) begin
          edr_count_int <= {EDR_COUNT_WIDTH {1'b0}};
        end
        else if (edr_load && !edr_shift) begin 
          edr_count_int <= edr_count_int + 1'b1;
        end
        else if (!edr_load && edr_shift) begin 
          edr_count_int <= edr_count_int - 1'b1;
        end
      end
    end 

    assign edr_count = edr_count_int;

    always @(posedge clk)
    begin:EDR_REGS2
      integer i;
      for(i=0;i<EDR_FIFO_DEPTH;i=i+1) begin
        if (i<EDR_FIFO_DEPTH-1) begin 
          if (i<edr_count) begin 
            if (edr_shift) begin
              edr_fifo_r[i] <= edr_fifo_r[i+1];
            end
          end
          else if (i==edr_count && edr_count < EDR_FIFO_DEPTH) begin 
            if (wr_edr_wen_i) begin
              edr_fifo_r[i] <= {wr_edr_addr_uppr_i, wr_edr_addr_lwr_i, wr_edr_prop_i};
            end
            else if (rd_edr_wen_i) begin
              edr_fifo_r[i] <= {rd_edr_addr_uppr_i, rd_edr_addr_lwr_i, rd_edr_prop_i};
            end
          end
        end
        else begin 
          if (rd_edr_wen_i && (!edr_ctrl_o[2] || (edr_ctrl_o[2] && edr_ctrl_i[0] && edr_ctrl_en)) && edr_rd_priority ) begin
            edr_fifo_r[i] <= {rd_edr_addr_uppr_i, rd_edr_addr_lwr_i, rd_edr_prop_i};
          end
          else if (wr_edr_wen_i && (!edr_ctrl_o[2] || (edr_ctrl_o[2] && edr_ctrl_i[0] && edr_ctrl_en)) ) begin
            edr_fifo_r[i] <= {wr_edr_addr_uppr_i, wr_edr_addr_lwr_i, wr_edr_prop_i};
          end
        end
      end
    end

    for (i=0; i<EDR_FIFO_DEPTH; i=i+1) begin : ASSIGN_EDR_FIFO
      assign edr_fifo[i] = edr_fifo_r[i];
    end

    always @* begin: edr_irq_comb
      edr_irq_int       = {2{1'b0}};
      edr_irq_valid_int = 1'b0;

      if (rd_edr_wen_i && edr_rd_priority && (!edr_ctrl_o[1] || (edr_ctrl_o[1] && edr_ctrl_i[0] && edr_ctrl_en))) begin
        edr_irq_int[0]    = 1'b1;
        edr_irq_valid_int = 1'b1;
      end
      else if (wr_edr_wen_i && (!edr_ctrl_o[1] || (edr_ctrl_o[1] && edr_ctrl_i[0] && edr_ctrl_en))) begin
        edr_irq_int[0]    = 1'b1;
        edr_irq_valid_int = 1'b1;
      end

      if (rd_edr_wen_i && wr_edr_wen_i) begin
        edr_irq_int[1]    = 1'b1;
        edr_irq_valid_int = 1'b1;
      end
      else if ((rd_edr_wen_i || wr_edr_wen_i) && edr_ctrl_o[1] && !(edr_ctrl_i[0] && edr_ctrl_en)) begin
        edr_irq_int[1]    = 1'b1;
        edr_irq_valid_int = 1'b1;
      end

    end 

    assign edr_irq       = edr_irq_int;
    assign edr_irq_valid = edr_irq_valid_int;

  end
  else begin: ME_LVL_0
    assign edr_rd_wr       = 1'b0;
    assign last_edr_rd     = 1'b0;
    assign edr_rd_priority = 1'b0;
    assign edr_ctrl_o      = {EDR_CTRL_WIDTH{1'b0}};
    assign edr_shift       = 1'b0;
    assign edr_load        = 1'b0;
    assign edr_count       = {EDR_COUNT_WIDTH{1'b0}};
    assign edr_irq         = 2'b00;
    assign edr_irq_valid   = 1'b0;

    genvar i;
    for (i=0; i<EDR_FIFO_DEPTH; i=i+1) begin : ASSIGN_EDR_FIFO
      assign edr_fifo[i] = {REPORT_WIDTH{1'b0}};
    end

  end
endgenerate


localparam I4U = EDR_TAU_WIDTH+EDR_TAL_WIDTH+FC_MST_ID_WIDTH+EDR_TP_WIDTH-1;
localparam I3U =               EDR_TAL_WIDTH+FC_MST_ID_WIDTH+EDR_TP_WIDTH-1;
localparam I2U =                             FC_MST_ID_WIDTH+EDR_TP_WIDTH-1;
localparam I1U =                                             EDR_TP_WIDTH-1;
localparam I4L = EDR_TAL_WIDTH+FC_MST_ID_WIDTH+EDR_TP_WIDTH;
localparam I3L =               FC_MST_ID_WIDTH+EDR_TP_WIDTH;
localparam I2L =                               EDR_TP_WIDTH;
localparam I1L =                                          0;

wire [FC_MST_ID_WIDTH-1:0] edr_mid_sel;

generate
  if ((FC_SINGLE_MST == 0) && (FC_ME_LVL > 0)) begin : EDR_MST_MID
    assign edr_mid_sel = edr_fifo[0][I2U:I2L];
  end
  else begin: EDR_SINGLE_MST_MID
    assign edr_mid_sel = FC_MST_ID_SINGLE_MST[FC_MST_ID_WIDTH-1:0];
  end
endgenerate

assign edr_mid_o = (edr_count > 0 && edr_ctrl_o[1] && FC_ME_LVL > 0)  ? edr_mid_sel          : {FC_MST_ID_WIDTH {1'b0}};
assign edr_tau_o = (edr_count > 0 && edr_ctrl_o[1] && FC_ME_LVL == 2) ? edr_fifo[0][I4U:I4L] : {EDR_TAU_WIDTH {1'b0}};
assign edr_tal_o = (edr_count > 0 && edr_ctrl_o[1] && FC_ME_LVL == 2) ? edr_fifo[0][I3U:I3L] : {EDR_TAL_WIDTH {1'b0}};
assign edr_tp_o  = (edr_count > 0 && edr_ctrl_o[1] && FC_ME_LVL > 0)  ? edr_fifo[0][I1U:I1L] : {EDR_TP_WIDTH  {1'b0}};


assign cfg_irq_o       = {edr_irq, fe_irq};
assign cfg_irq_valid_o = edr_irq_valid || fe_irq_valid;


generate
  if (FW_LDE_LVL > 0 && FW_SRE_LVL == 0) begin: LD_CTRL_LDE_LVL_NOT_0 

    reg [1:0] ld_ctrl_r;

    always @(posedge clk or negedge reset_n) begin: LD_CTRL_REG
      if (!reset_n) begin
        ld_ctrl_r <= {2{1'b0}};
      end else begin
        if (default_state_i) begin
          ld_ctrl_r <= {2{1'b0}};
        end
        else if (ld_ctrl_en) begin
          ld_ctrl_r <= ld_ctrl_i[1:0];
        end
      end
    end

    assign ld_ctrl_o = {1'b0, ld_ctrl_r}; 

    end else begin: LD_CTRL_LDE_LVL_0 
      assign ld_ctrl_o = {LD_CTRL_WIDTH{1'b0}};
    end
endgenerate


generate
  if (FC_PE_LVL > 1) begin: PROT_SIZE_PE_LVL_NOT_0

    reg [PROT_SIZE_WIDTH-1:0] prot_size_r;

    always @ (posedge clk or negedge reset_n) begin: PROT_SIZE_REG
      if (!reset_n) begin
        prot_size_r <= {PROT_SIZE_WIDTH{1'b0}};
      end
      else begin
        if (prot_size_en) begin
          prot_size_r <= prot_size_i;
        end
      end
    end

    assign prot_size_o = prot_size_r;

  end else begin: PROT_SIZE_PE_LVL_0

    assign prot_size_o = {PROT_SIZE_WIDTH{1'b0}};

  end
endgenerate


generate
  if ((FC_PE_LVL == 0) || (FC_MXRS <= (FC_MNRS + 5))) begin: BASE_UPR_ADDR_FC_PE_LVL_0 

    assign fc_base_addr_o = {FC_NUM_RGN*FC_MXRS{1'b0}};
    assign fc_upr_addr_o  = {FC_NUM_RGN*FC_MXRS{1'b0}};

  end else if (FC_PE_LVL == 1) begin: BASE_UPR_ADDR_FC_PE_LVL_1 


    wire [FC_NUM_RGN*FC_MXRS-1:0] curr_rgn_size;

    for (i=0; i<FC_NUM_RGN; i=i+1) begin: UPPR_ADDR_PE_LVL_1_UPR_ADDR
      for (j=0; j<FC_MXRS; j=j+1) begin: UPPR_ADDR_PE_LVL_1_CURRENT_RGN
        if (j < FC_RGN_SIZE[(i+1)*8-1-:8]) begin: UPPR_ADDR_PE_LVL_1_ADD
          assign curr_rgn_size[i*FC_MXRS + j] = 1'b1;
        end else begin: UPPR_ADDR_PE_LVL_1_DO_NOT_ADD
          assign curr_rgn_size[i*FC_MXRS + j] = 1'b0;
        end
      end
    end

    for (i=0; i<FC_NUM_RGN; i=i+1) begin: BASE_UPR_ADDR_OUTPUT_VALUE
      if ((FC_RSE_LVL == 1) && (FC_RGN_MULNPO2[i])) begin: UPR_ADDR_FROM_PARAM

        assign fc_base_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] = FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS];

        assign fc_upr_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          FC_RGN_UPR_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS];

      end else begin: BASE_UPR_ADDR_SUM

        assign fc_base_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] = FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS] & ~curr_rgn_size[(i+1)*FC_MXRS-1-:FC_MXRS];

        assign fc_upr_addr_o[(i+1)*FC_MXRS-1-:FC_MXRS] =
          (FC_RGN_BASE_ADDR[(i+1)*FC_MXRS-1-:FC_MXRS] & ~curr_rgn_size[(i+1)*FC_MXRS-1-:FC_MXRS]) + curr_rgn_size[(i+1)*FC_MXRS-1-:FC_MXRS];

      end
    end

  end else begin: BASE_UPR_ADDR_FC_PE_LVL_2 


    reg [FC_NUM_RGN*FC_MXRS-1:0] fc_base_address_int;
    reg [FC_NUM_RGN*FC_MXRS-1:0] fc_upr_address_int;
    reg [FC_NUM_RGN*FC_MXRS-1:0] region_size;
    reg [FC_NUM_RGN*FC_MXRS-1:0] region_size_input;

    wire [FC_NUM_RGN*FC_MXRS-1:0] fc_upr_addr_tmp;

    always @(*) begin: REGION_SIZE_PE_LVL_2_CALCULATE
      integer i, j, k;
      for (i=0; i<FC_NUM_RGN; i=i+1) begin
        region_size[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};
        region_size_input[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};
        for (j=0; j<FC_MXRS; j=j+1) begin
          if ((j < rgn_size_o[(i+1)*RGN_SIZE_WIDTH-9-:8])) begin
            region_size[i*FC_MXRS+j] = 1'b1;
          end else begin
            region_size[i*FC_MXRS+j] = 1'b0;
          end
        end
        for (k=0; k<FC_MXRS; k=k+1) begin
          if ((k < rgn_size_input_frmtd[(i+1)*RGN_SIZE_WIDTH-9-:8])) begin
            region_size_input[i*FC_MXRS+k] = 1'b1;
          end else begin
            region_size_input[i*FC_MXRS+k] = 1'b0;
          end
        end
      end
    end


    if (FC_MXRS <= 32) begin: BASE_ADDR_PE_LVL_2_CFG0_ONLY

      if (FC_RSE_LVL == 1) begin: BASE_ADDR_PE_LVL_2_CFG0_ONLY_RSE_LVL_1

        always @(*) begin: BASE_ADDR_FROM_CFG0_RSE_LVL_1
          integer i;
          fc_base_address_int = {FC_NUM_RGN*FC_MXRS{1'b0}};

          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_size_o[(i+1)*RGN_SIZE_WIDTH-8]) begin
              fc_base_address_int[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH] =
                rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-RGN_CFG0_TOP-1-:ACT_RGN_CFG0_WIDTH];
            end
            else begin
              fc_base_address_int[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH] =
                rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-RGN_CFG0_TOP-1-:ACT_RGN_CFG0_WIDTH];
              fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
                fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] &
                ~region_size[(i+1)*FC_MXRS-1-:FC_MXRS];
            end
          end
        end
      end
      else begin: BASE_ADDR_PE_LVL_2_CFG0_ONLY_RSE_LVL_0

        always @(*) begin: BASE_ADDR_FROM_CFG0_RSE_LVL_0
          integer i;
          fc_base_address_int = {FC_NUM_RGN*FC_MXRS{1'b0}};

          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            fc_base_address_int[(i+1)*FC_MXRS-1-:ACT_RGN_CFG0_WIDTH] =
              rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-RGN_CFG0_TOP-1-:ACT_RGN_CFG0_WIDTH];
            fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
              fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] &
              ~region_size[(i+1)*FC_MXRS-1-:FC_MXRS];
          end
        end
      end

    end else begin: BASE_ADDR_CFG0_CFG1

      if (FC_RSE_LVL == 1) begin: BASE_ADDR_PE_LVL_2_CFG0_ONLY_RSE_LVL_1

        always @(*) begin: BASE_ADDR_FROM_CFG0_RSE_LVL_1
          integer i;
          fc_base_address_int = {FC_NUM_RGN*FC_MXRS{1'b0}};

          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            if (rgn_size_o[(i+1)*RGN_SIZE_WIDTH-8]) begin
              fc_base_address_int[(i+1)*FC_MXRS-1-:(ACT_RGN_CFG1_WIDTH+ACT_RGN_CFG0_WIDTH)] =
                {rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-RGN_CFG1_TOP-1-:ACT_RGN_CFG1_WIDTH],
                 rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH]};
            end
            else begin
              fc_base_address_int[(i+1)*FC_MXRS-1-:(ACT_RGN_CFG1_WIDTH+ACT_RGN_CFG0_WIDTH)] =
                {rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-RGN_CFG1_TOP-1-:ACT_RGN_CFG1_WIDTH],
                  rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH]};
              fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
                fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] &
                ~region_size[(i+1)*FC_MXRS-1-:FC_MXRS];
            end
          end
        end
      end
      else begin: BASE_ADDR_PE_LVL_2_CFG0_ONLY_RSE_LVL_0

        always @(*) begin: BASE_ADDR_FROM_CFG0_RSE_LVL_0
          integer i;
          fc_base_address_int = {FC_NUM_RGN*FC_MXRS{1'b0}};

          for (i=0; i<FC_NUM_RGN; i=i+1) begin
            fc_base_address_int[(i+1)*FC_MXRS-1-:(ACT_RGN_CFG1_WIDTH+ACT_RGN_CFG0_WIDTH)] =
              {rgn_cfg1_o[(i+1)*RGN_CFG1_WIDTH-RGN_CFG1_TOP-1-:ACT_RGN_CFG1_WIDTH],
                rgn_cfg0_o[(i+1)*RGN_CFG0_WIDTH-1-:RGN_CFG0_WIDTH]};
            fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
              fc_base_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] &
              ~region_size[(i+1)*FC_MXRS-1-:FC_MXRS];
          end
        end
      end

    end 

    assign fc_base_addr_o = fc_base_address_int;


    reg [FC_MXRS-1:0] tmp;

    always @(*) begin: UPR_ADDR_FC_PE_2_RGN_0
      integer i;
      for (i=0; i<FC_MXRS; i=i+1) begin
        if (i<prot_size_o) begin
          tmp[i] = 1'b1;
        end else begin
          tmp[i] = 1'b0;
        end
      end
    end

    reg [FC_MXRS-1:0] rgn_0_upr_addr_tmp_r;
    reg               prot_size_en_r;

    always @ (posedge clk or negedge reset_n) begin: RGN0_UPR_ADDR_REG
      if (!reset_n) begin
        rgn_0_upr_addr_tmp_r <= {FC_MXRS{1'b0}};
        prot_size_en_r       <= 1'b0;
      end
      else begin
        prot_size_en_r <= prot_size_en;
        if (prot_size_en_r) begin
          rgn_0_upr_addr_tmp_r <= tmp;
        end
      end
    end

    if (FC_NUM_RGN == 1) begin: ASSEMBLE_OUTPUT_NUM_RGN_1
      assign fc_upr_addr_o = rgn_0_upr_addr_tmp_r;
    end else begin: ASSEMBLE_OUTPUT_NUM_RGN_NOT_1
      assign fc_upr_addr_o = {fc_upr_addr_tmp[FC_NUM_RGN*FC_MXRS-1:FC_MXRS], rgn_0_upr_addr_tmp_r};
    end

    if (FC_RSE_LVL == 1) begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_1

      if (FC_MXRS <= 8'h20) begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_1_TCFG0_ONLY

        reg [FC_NUM_RGN*FC_MXRS-1:0] fc_upr_address_r;
        integer upr_addr;

        always @ (posedge clk) begin
          for (upr_addr=1; upr_addr<FC_NUM_RGN; upr_addr=upr_addr+1) begin
            if (rgn_size_en[upr_addr] && rgn_size_input_frmtd[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                {rgn_cfg0_o[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} +
                region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_size_en[upr_addr] && ~rgn_size_input_frmtd[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                ({rgn_cfg0_o[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
                region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_cfg0_en[upr_addr] && rgn_size_o[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                {rgn_cfg0_i_frmtd[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} +
                region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_cfg0_en[upr_addr] && ~rgn_size_o[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                ({rgn_cfg0_i_frmtd[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
                region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
          end
        end

        always @ (posedge clk) begin
          fc_upr_address_r[FC_MXRS-1-:FC_MXRS] <=
            {rgn_cfg0_o[0 +: FC_MXRS-5], 5'b0} +
            region_size[FC_MXRS-1-:FC_MXRS];
        end

        always @(*) begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_1_CALCULATE
          integer i, j, k;

          for (i=0; i<FC_NUM_RGN; i=i+1) begin

            fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};

            if (rgn_size_o[(i+1)*RGN_SIZE_WIDTH-8]) begin 

              fc_upr_address_int[(i+1)*FC_MXRS-1-:ACT_RGN_TCFG0_WIDTH] =
                rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-RGN_TCFG0_TOP-1-:ACT_RGN_TCFG0_WIDTH];

            end else begin

              fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
                fc_upr_address_r[(i+1)*FC_MXRS-1-:FC_MXRS];

            end
          end
        end

      end else begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_1_TCFG0_TCFG1

        reg [FC_NUM_RGN*FC_MXRS-1:0] fc_upr_address_r;
        integer upr_addr;

        always @ (posedge clk) begin
          for (upr_addr=1; upr_addr<FC_NUM_RGN; upr_addr=upr_addr+1) begin
            if (rgn_size_en[upr_addr] && rgn_size_input_frmtd[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                {rgn_cfg0_o[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} +
                region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_size_en[upr_addr] && ~rgn_size_input_frmtd[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                ({rgn_cfg0_o[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
                region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_cfg0_en[upr_addr] && rgn_size_o[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                {rgn_cfg0_i_frmtd[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} +
                region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
            else if (rgn_cfg0_en[upr_addr] && ~rgn_size_o[(upr_addr+1)*RGN_SIZE_WIDTH-8]) begin
              fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
                ({rgn_cfg0_i_frmtd[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
                region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
            end
          end
        end

        always @ (posedge clk) begin
          fc_upr_address_r[FC_MXRS-1-:FC_MXRS] <=
            {rgn_cfg0_o[0 +: FC_MXRS-5], 5'b0} +
            region_size[FC_MXRS-1-:FC_MXRS];
        end

        always @(*) begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_1_CALCULATE
          integer i, j, k;

          for (i=0; i<FC_NUM_RGN; i=i+1) begin

            fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};
            region_size_input[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};



            if (rgn_size_o[(i+1)*RGN_SIZE_WIDTH-8]) begin 

              fc_upr_address_int[(i+1)*FC_MXRS-1-:(ACT_RGN_TCFG1_WIDTH + ACT_RGN_TCFG0_WIDTH)] =
                {rgn_tcfg1_o[(i+1)*RGN_TCFG1_WIDTH-RGN_TCFG1_TOP-1-:ACT_RGN_TCFG1_WIDTH],
                 rgn_tcfg0_o[(i+1)*RGN_TCFG0_WIDTH-1-:RGN_TCFG0_WIDTH]};

            end else begin

              fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
                fc_upr_address_r[(i+1)*FC_MXRS-1-:FC_MXRS];

            end
          end
        end

      end

      assign fc_upr_addr_tmp = fc_upr_address_int;

    end else begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_0

      reg [FC_NUM_RGN*FC_MXRS-1:0] fc_upr_address_r;
      integer upr_addr;

      always @ (posedge clk) begin
        for (upr_addr=1; upr_addr<FC_NUM_RGN; upr_addr=upr_addr+1) begin
          if (rgn_size_en[upr_addr]) begin
            fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
              ({rgn_cfg0_o[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
              region_size_input[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
          end
          else if (rgn_cfg0_en[upr_addr]) begin
            fc_upr_address_r[(upr_addr+1)*FC_MXRS-1-:FC_MXRS] <=
              ({rgn_cfg0_i_frmtd[upr_addr*RGN_CFG0_WIDTH +: FC_MXRS-5], 5'b0} & ~region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS]) +
              region_size[(upr_addr+1)*FC_MXRS-1-:FC_MXRS];
          end
        end
      end

      always @ (posedge clk) begin
        fc_upr_address_r[FC_MXRS-1-:FC_MXRS] <=
          {rgn_cfg0_o[0 +: FC_MXRS-5], 5'b0} +
          region_size[FC_MXRS-1-:FC_MXRS];
      end

      always @(*) begin: UPPER_ADDR_PE_LVL_2_RSE_LVL_0_CALCULATE
        integer i, j, k;

        for (i=0; i<FC_NUM_RGN; i=i+1) begin
          fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] = {FC_MXRS{1'b0}};

          fc_upr_address_int[(i+1)*FC_MXRS-1-:FC_MXRS] =
            fc_upr_address_r[(i+1)*FC_MXRS-1-:FC_MXRS];

        end
      end

      assign fc_upr_addr_tmp = fc_upr_address_int;

    end

  end
endgenerate


assign fc_rb_lpi_discon_deny_o =
  (pe_st_o[4] && fe_ctrl_o[4]) ||
  (me_st_o[1] && edr_ctrl_o[1]);


reg [PE_ST_WIDTH-1:0] pe_st_reg;
reg [ME_ST_WIDTH-2:0] me_st_reg;


assign status_enable = arvalid_i ||
                     awvalid_i   ||
                     rvalid_i    ||
                     wvalid_i    ||
                     bvalid_i;

always @(posedge clk or negedge reset_n) begin: UPDATE_STATUS_REGS
  if (!reset_n) begin
    pe_st_reg  <= PE_CTRL_RST_VAL;
    rgn_st_reg <= {FC_NUM_RGN*RGN_ST_WIDTH{1'b0}};
    me_st_reg  <= {(ME_ST_WIDTH-1){1'b0}};
  end else begin
    if (default_state_i) begin
      pe_st_reg  <= PE_CTRL_RST_VAL;
      rgn_st_reg <= {FC_NUM_RGN*RGN_ST_WIDTH{1'b0}};
      me_st_reg  <= {(ME_ST_WIDTH-1){1'b0}};
    end
    else if (!status_enable) begin
      pe_st_reg  <= pe_ctrl_o;
      rgn_st_reg <= rgn_st_int;
      me_st_reg  <= {me_ctrl_o[2], me_ctrl_o[0]};  
    end
  end
end

assign pe_st_o      = pe_st_reg;
assign rgn_st_o     = rgn_st_reg;
assign rgn_st_rgn_o = rgn_st_curr_rgn;
assign me_st_o      = {me_st_reg[1], me_ctrl_o[1], me_st_reg[0]};

endmodule
