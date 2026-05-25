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

module firewall_f0_ctlr_pchk #(
  parameter REG_ADDR_WIDTH      = 10,   
  parameter REG_ENUM_WIDTH      = 126,
  parameter PID0_WIDTH          = 8,
  parameter PID1_WIDTH          = 8,
  parameter PID2_WIDTH          = 8,
  parameter PID3_WIDTH          = 8,
  parameter PID4_WIDTH          = 8,
  parameter CID0_WIDTH          = 8,
  parameter CID1_WIDTH          = 8,
  parameter CID2_WIDTH          = 8,
  parameter CID3_WIDTH          = 8,
  parameter IIDR_WIDTH          = 32,
  parameter AIDR_WIDTH          = 8 ,
  parameter FW_ID_WIDTH         = 5 ,
  `include "firewall_f0_ctlr_params.vh"
  ,
  `include "firewall_f0_reg_addr_params.vh"
  `include "firewall_f0_ctlr_reg_addr_params.vh"
)
(   
    input  wire                                   clk   ,
    input  wire                                   reset_n,

    input  wire [FC_AXIID_WIDTH-1:0]              arid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               araddr_s_i  ,
    input  wire [7:0]                             arlen_s_i   ,
    input  wire [2:0]                             arsize_s_i  ,
    input  wire [1:0]                             arburst_s_i ,
    input  wire                                   arlock_s_i  ,
    input  wire [3:0]                             arcache_s_i ,
    input  wire [2:0]                             arprot_s_i  ,
    input  wire [3:0]                             arqos_s_i   ,
    input  wire [3:0]                             arregion_s_i,
    input  wire                                   arvalid_s_i ,
    output  reg                                   arready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_s_i,

    input  wire [FC_AXIID_WIDTH-1:0]              awid_s_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               awaddr_s_i  ,
    input  wire [7:0]                             awlen_s_i   ,
    input  wire [2:0]                             awsize_s_i  ,
    input  wire [1:0]                             awburst_s_i ,
    input  wire                                   awlock_s_i  ,
    input  wire [3:0]                             awcache_s_i ,
    input  wire [2:0]                             awprot_s_i  ,
    input  wire [3:0]                             awqos_s_i   ,
    input  wire [3:0]                             awregion_s_i,
    input  wire                                   awvalid_s_i ,
    output  reg                                   awready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output  reg                                   wready_s_o  ,

    output  reg [FC_AXIID_WIDTH-1:0]              bid_pchk_o     ,
    output  reg [1:0]                             bresp_pchk_o   ,
    output  reg [FC_AXIUSER_B_WIDTH-1:0]          buser_pchk_o   ,
    output  reg                                   bvalid_pchk_o  ,
    input  wire                                   bready_pchk_i  ,

    output  reg [FC_AXIID_WIDTH-1:0]              rid_pchk_o     ,
    output  reg [FC_AXIDATA_WIDTH-1:0]            rdata_pchk_o   ,
    output  reg [1:0]                             rresp_pchk_o   ,
    output  reg                                   rlast_pchk_o   ,
    output  reg [FC_AXIUSER_R_WIDTH-1:0]          ruser_pchk_o   ,
    output  reg                                   rvalid_pchk_o  ,
    output  reg  [FC_MST_ID_WIDTH-1:0]            mst_id_pchk_o ,
    input  wire                                   rready_pchk_i  ,

    input  wire                                   awakeup_s_i  ,

    output  reg [FC_AXIID_WIDTH-1:0]              arid_m_o    ,
    output  reg [REG_ADDR_WIDTH-1:0]              araddr_m_o  ,
    output  reg                                   arvalid_m_o ,
    output  reg [FC_MST_ID_WIDTH-1:0]             armmusid_m_o,
    input  wire                                   arready_m_i ,

    output  reg [FC_AXIID_WIDTH-1:0]              awid_m_o    ,
    output  reg [REG_ADDR_WIDTH-1:0]              awaddr_m_o  ,
    output  reg                                   awvalid_m_o ,
    output  reg [FC_MST_ID_WIDTH-1:0]             awmmusid_m_o,
    input  wire                                   awready_m_i ,

    output  reg [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output  reg                                   wvalid_m_o  ,
    output  reg                                   wlast_m_o  ,
    input  wire                                   wready_m_i  ,

    output wire [FW_ID_WIDTH-1:0]                 cfg_w_fw_id_o,
    output wire [FW_ID_WIDTH-1:0]                 cfg_r_fw_id_o,

    output wire [REG_ENUM_WIDTH-1:0]              reg_addr_dec_rd_o,
    output wire [REG_ENUM_WIDTH-1:0]              reg_addr_dec_wr_o,

    input wire [(FW_NUM_FC+1)*8-1:0]              prot_size_i,

    input wire [PID0_WIDTH-1:0]                   reg_pid0_i,
    input wire [PID1_WIDTH-1:0]                   reg_pid1_i,
    input wire [PID2_WIDTH-1:0]                   reg_pid2_i,
    input wire [PID3_WIDTH-1:0]                   reg_pid3_i,
    input wire [PID4_WIDTH-1:0]                   reg_pid4_i,

    input wire [CID0_WIDTH-1:0]                   reg_cid0_i,
    input wire [CID1_WIDTH-1:0]                   reg_cid1_i,
    input wire [CID2_WIDTH-1:0]                   reg_cid2_i,
    input wire [CID3_WIDTH-1:0]                   reg_cid3_i,

    input wire [AIDR_WIDTH-1:0]                   reg_aidr_i,
    input wire [IIDR_WIDTH-1:0]                   reg_iidr_i,

    input wire [1:0]                              reg_fw_sr_ctrl_i,

    input  wire                                   sram_rdy_i,
    input  wire [FW_NUM_FC-1:0]                   rb_comp_pwr_st_i,

    output wire                                   pchk_write_tamp_o,
    output wire                                   pchk_read_tamp_o

);

`include "firewall_f0_ctlr_reg_enum.vh"
`include "firewall_f0_log2.vh"

function [3*(FW_NUM_FC+1)-1:0] log2_rgn;
  input [7*(FW_NUM_FC+1)-1:0] rgn;
  integer i;
  integer rgn_res;
  reg [31:0] rgn_32;
  begin
    for (i=0; i<(FW_NUM_FC+1); i=i+1) begin
      rgn_32 = {{(32-7){1'b0}}, rgn[(7*(i+1))-1 -: 7]};
      rgn_res = firewall_f0_log2(rgn_32);
      log2_rgn[(3*(i+1))-1 -: 3] = rgn_res[2:0];
    end
  end
endfunction

function [8*(FW_NUM_FC+1)-1:0] rwe_ctrl_wr_mask;
  input [3*(FW_NUM_FC+1)-1:0] log2_rgn_fc;
  reg [7:0] temp_mask;
  reg [7:0] rgn_bits;
  integer i;
  integer j;
  begin
    for (i=0; i<(FW_NUM_FC+1); i=i+1) begin
      temp_mask = {8{1'b0}};
      rgn_bits = {5'b0, log2_rgn_fc[(3*(i+1))-1 -: 3]};
      for (j=0; j<rgn_bits; j=j+1) begin
        temp_mask[j] = 1'b1;
      end
      rwe_ctrl_wr_mask[8*(i+1)-1 -: 8] = temp_mask;
    end
  end
endfunction

localparam [(2*(FW_NUM_FC+1))-1:0] FC_PE_LVL_ALL  = {FC_PE_LVL_EXT ,FC_PE_LVL[1:0]};
localparam [(2*(FW_NUM_FC+1))-1:0] FC_TE_LVL_ALL  = {FC_TE_LVL_EXT ,FC_TE_LVL[1:0]};
localparam [(FW_NUM_FC+1)-1:0] FC_RSE_LVL_ALL     = {FC_RSE_LVL_EXT ,FC_RSE_LVL[0]};
localparam [(2*(FW_NUM_FC+1))-1:0] FC_ME_LVL_ALL  = {FC_ME_LVL_EXT ,FC_ME_LVL[1:0]};
localparam [(3*(FW_NUM_FC+1))-1:0] FC_NUM_MPE_ALL = {FC_NUM_MPE_EXT ,FC_NUM_MPE[2:0]};
localparam [(7*(FW_NUM_FC+1))-1:0] FC_NUM_RGN_ALL = {FC_NUM_RGN_EXT ,FC_NUM_RGN[6:0]};
localparam [(7*(FW_NUM_FC+1))-1:0] FC_MXRS_ALL    = {FC_MXRS_EXT ,FC_MXRS[6:0]};
localparam [(7*(FW_NUM_FC+1))-1:0] FC_MNRS_ALL    = {FC_MNRS_EXT ,FC_MNRS[6:0]};

localparam [3*(FW_NUM_FC+1)-1:0] LOG2_NUM_RGN_FC = log2_rgn(FC_NUM_RGN_ALL);

localparam [8*(FW_NUM_FC+1)-1:0] RWE_CTRL_MASK = rwe_ctrl_wr_mask(LOG2_NUM_RGN_FC);

localparam LOG2_ALL_NUM_FC = firewall_f0_log2(FW_NUM_FC + 1);

reg early_resp_rd;
reg early_resp_wr;
reg [1:0] resp_type_rd;
reg [1:0] resp_type_rd_reg;
reg [1:0] resp_type_wr;
reg arready_int;
reg awready_int;
reg wready_int;
reg [FC_AXIID_WIDTH-1:0] arid_reg;
reg [7:0] arlen_reg;
reg rdata_begin;
reg [8:0] rdata_ctr;
reg [FC_AXIDATA_WIDTH-1:0] rdata_early;
reg [REG_ENUM_WIDTH-1:0]               reg_addr_dec_rd_int;
reg [REG_ENUM_WIDTH-1:0]               reg_addr_dec_wr_int;
reg [FC_MST_ID_WIDTH-1:0] armmusid_reg;
reg [FC_AXIDATA_WIDTH-1:0] rdata_early_reg;
reg cae_pe0_rd;
reg cae_pe0_lde2_rd;
reg cae_pe0_rse1_te2_rd;
reg cae_te0_rd;
reg cae_pe0_mpe1_rd;
reg cae_pe0_mpe2_rd;
reg cae_pe0_mpe3_rd;
reg cae_pe0_mpe4_rd;
reg cae_rwe_rd;
reg cae_me0_rd;
reg cae_me0_me1_rd;
reg cae_lde0_rd;
reg cae_fc_int_rd;
reg cae_sre_rd;
reg cae_mxrs_rd;
reg cae_mxrs_mnrs_rd;
reg cae_fctlr_rd;
reg cae_rd;
reg cae_pe0_wr;
reg cae_pe0_lde2_wr;
reg cae_pe0_rse1_te2_wr;
reg cae_te0_wr;
reg cae_pe0_mpe1_wr;
reg cae_pe0_mpe2_wr;
reg cae_pe0_mpe3_wr;
reg cae_pe0_mpe4_wr;
reg cae_rwe_wr;
reg cae_me0_wr;
reg cae_me0_me1_wr;
reg cae_lde0_wr;
reg cae_fc_int_wr;
reg cae_sre_wr;
reg cae_mxrs_wr;
reg cae_mxrs_mnrs_wr;
reg cae_fctlr_wr;
reg cae_wr;
wire [FW_NUM_FC:0] all_comp_pwr_st;
wire [LOG2_ALL_NUM_FC-1:0] all_w_fw_id;
wire [LOG2_ALL_NUM_FC-1:0] all_r_fw_id;
reg [2:0] fc_num_mpe_int;
reg [31:0] fc_mst_id_width_int;

assign cfg_w_fw_id_o = awaddr_s_i[16+FW_ID_WIDTH-1 : 16];
assign cfg_r_fw_id_o = araddr_s_i[16+FW_ID_WIDTH-1 : 16];

assign all_w_fw_id = awaddr_s_i[16+LOG2_ALL_NUM_FC-1 : 16];
assign all_r_fw_id = araddr_s_i[16+LOG2_ALL_NUM_FC-1 : 16];

assign all_comp_pwr_st = {rb_comp_pwr_st_i, 1'b1};


assign reg_addr_dec_rd_o = (arvalid_s_i == 1'b1) ? reg_addr_dec_rd_int : {REG_ENUM_WIDTH{1'b0}};
assign reg_addr_dec_wr_o = (awvalid_s_i == 1'b1) ? reg_addr_dec_wr_int : {REG_ENUM_WIDTH{1'b0}};

always @*
begin: reg_dec_rd

  reg_addr_dec_rd_int = {REG_ENUM_WIDTH{1'b0}};

  case (araddr_s_i[11:0])
    FW_CTRL_ADDR     : reg_addr_dec_rd_int[FW_CTRL_ONE_HOT      ] = 1'b1;
    FW_ST_ADDR       : reg_addr_dec_rd_int[FW_ST_ONE_HOT        ] = 1'b1;
    FW_SR_CTRL_ADDR  : reg_addr_dec_rd_int[FW_SR_CTRL_ONE_HOT   ] = 1'b1;
    LD_CTRL_ADDR     : reg_addr_dec_rd_int[LD_CTRL_ONE_HOT      ] = 1'b1;
    PE_CTRL_ADDR     : reg_addr_dec_rd_int[PE_CTRL_ONE_HOT      ] = 1'b1;
    PE_ST_ADDR       : reg_addr_dec_rd_int[PE_ST_ONE_HOT        ] = 1'b1;
    PE_BPS_ADDR      : reg_addr_dec_rd_int[PE_BPS_ONE_HOT       ] = 1'b1;
    RWE_CTRL_ADDR    : reg_addr_dec_rd_int[RWE_CTRL_ONE_HOT     ] = 1'b1;
    RGN_CTRL0_ADDR   : reg_addr_dec_rd_int[RGN_CTRL0_ONE_HOT    ] = 1'b1;
    RGN_CTRL1_ADDR   : reg_addr_dec_rd_int[RGN_CTRL1_ONE_HOT    ] = 1'b1;
    RGN_LCTRL_ADDR   : reg_addr_dec_rd_int[RGN_LCTRL_ONE_HOT    ] = 1'b1;
    RGN_ST_ADDR      : reg_addr_dec_rd_int[RGN_ST_ONE_HOT       ] = 1'b1;
    RGN_CFG0_ADDR    : reg_addr_dec_rd_int[RGN_CFG0_ONE_HOT     ] = 1'b1;
    RGN_CFG1_ADDR    : reg_addr_dec_rd_int[RGN_CFG1_ONE_HOT     ] = 1'b1;
    RGN_SIZE_ADDR    : reg_addr_dec_rd_int[RGN_SIZE_ONE_HOT     ] = 1'b1;
    RGN_TCFG0_ADDR   : reg_addr_dec_rd_int[RGN_TCFG0_ONE_HOT    ] = 1'b1;
    RGN_TCFG1_ADDR   : reg_addr_dec_rd_int[RGN_TCFG1_ONE_HOT    ] = 1'b1;
    RGN_TCFG2_ADDR   : reg_addr_dec_rd_int[RGN_TCFG2_ONE_HOT    ] = 1'b1;
    RGN_MID0_ADDR    : reg_addr_dec_rd_int[RGN_MID0_ONE_HOT     ] = 1'b1;
    RGN_MPL0_ADDR    : reg_addr_dec_rd_int[RGN_MPL0_ONE_HOT     ] = 1'b1;
    RGN_MID1_ADDR    : reg_addr_dec_rd_int[RGN_MID1_ONE_HOT     ] = 1'b1;
    RGN_MPL1_ADDR    : reg_addr_dec_rd_int[RGN_MPL1_ONE_HOT     ] = 1'b1;
    RGN_MID2_ADDR    : reg_addr_dec_rd_int[RGN_MID2_ONE_HOT     ] = 1'b1;
    RGN_MPL2_ADDR    : reg_addr_dec_rd_int[RGN_MPL2_ONE_HOT     ] = 1'b1;
    RGN_MID3_ADDR    : reg_addr_dec_rd_int[RGN_MID3_ONE_HOT     ] = 1'b1;
    RGN_MPL3_ADDR    : reg_addr_dec_rd_int[RGN_MPL3_ONE_HOT     ] = 1'b1;
    FE_TAL_ADDR      : reg_addr_dec_rd_int[FE_TAL_ONE_HOT       ] = 1'b1;
    FE_TAU_ADDR      : reg_addr_dec_rd_int[FE_TAU_ONE_HOT       ] = 1'b1;
    FE_TP_ADDR       : reg_addr_dec_rd_int[FE_TP_ONE_HOT        ] = 1'b1;
    FE_MID_ADDR      : reg_addr_dec_rd_int[FE_MID_ONE_HOT       ] = 1'b1;
    FE_CTRL_ADDR     : reg_addr_dec_rd_int[FE_CTRL_ONE_HOT      ] = 1'b1;
    ME_CTRL_ADDR     : reg_addr_dec_rd_int[ME_CTRL_ONE_HOT      ] = 1'b1;
    ME_ST_ADDR       : reg_addr_dec_rd_int[ME_ST_ONE_HOT        ] = 1'b1;
    EDR_TAL_ADDR     : reg_addr_dec_rd_int[EDR_TAL_ONE_HOT      ] = 1'b1;
    EDR_TAU_ADDR     : reg_addr_dec_rd_int[EDR_TAU_ONE_HOT      ] = 1'b1;
    EDR_TP_ADDR      : reg_addr_dec_rd_int[EDR_TP_ONE_HOT       ] = 1'b1;
    EDR_MID_ADDR     : reg_addr_dec_rd_int[EDR_MID_ONE_HOT      ] = 1'b1;
    EDR_CTRL_ADDR    : reg_addr_dec_rd_int[EDR_CTRL_ONE_HOT     ] = 1'b1;
    FC0_INT_ST_ADDR  : reg_addr_dec_rd_int[FC0_INT_ST_ONE_HOT   ] = 1'b1;
    FC1_INT_ST_ADDR  : reg_addr_dec_rd_int[FC1_INT_ST_ONE_HOT   ] = 1'b1;
    FC2_INT_ST_ADDR  : reg_addr_dec_rd_int[FC2_INT_ST_ONE_HOT   ] = 1'b1;
    FC3_INT_ST_ADDR  : reg_addr_dec_rd_int[FC3_INT_ST_ONE_HOT   ] = 1'b1;
    FC4_INT_ST_ADDR  : reg_addr_dec_rd_int[FC4_INT_ST_ONE_HOT   ] = 1'b1;
    FC5_INT_ST_ADDR  : reg_addr_dec_rd_int[FC5_INT_ST_ONE_HOT   ] = 1'b1;
    FC6_INT_ST_ADDR  : reg_addr_dec_rd_int[FC6_INT_ST_ONE_HOT   ] = 1'b1;
    FC7_INT_ST_ADDR  : reg_addr_dec_rd_int[FC7_INT_ST_ONE_HOT   ] = 1'b1;
    FC8_INT_ST_ADDR  : reg_addr_dec_rd_int[FC8_INT_ST_ONE_HOT   ] = 1'b1;
    FC9_INT_ST_ADDR  : reg_addr_dec_rd_int[FC9_INT_ST_ONE_HOT   ] = 1'b1;
    FC10_INT_ST_ADDR : reg_addr_dec_rd_int[FC10_INT_ST_ONE_HOT  ] = 1'b1;
    FC11_INT_ST_ADDR : reg_addr_dec_rd_int[FC11_INT_ST_ONE_HOT  ] = 1'b1;
    FC12_INT_ST_ADDR : reg_addr_dec_rd_int[FC12_INT_ST_ONE_HOT  ] = 1'b1;
    FC13_INT_ST_ADDR : reg_addr_dec_rd_int[FC13_INT_ST_ONE_HOT  ] = 1'b1;
    FC14_INT_ST_ADDR : reg_addr_dec_rd_int[FC14_INT_ST_ONE_HOT  ] = 1'b1;
    FC15_INT_ST_ADDR : reg_addr_dec_rd_int[FC15_INT_ST_ONE_HOT  ] = 1'b1;
    FC16_INT_ST_ADDR : reg_addr_dec_rd_int[FC16_INT_ST_ONE_HOT  ] = 1'b1;
    FC17_INT_ST_ADDR : reg_addr_dec_rd_int[FC17_INT_ST_ONE_HOT  ] = 1'b1;
    FC18_INT_ST_ADDR : reg_addr_dec_rd_int[FC18_INT_ST_ONE_HOT  ] = 1'b1;
    FC19_INT_ST_ADDR : reg_addr_dec_rd_int[FC19_INT_ST_ONE_HOT  ] = 1'b1;
    FC20_INT_ST_ADDR : reg_addr_dec_rd_int[FC20_INT_ST_ONE_HOT  ] = 1'b1;
    FC21_INT_ST_ADDR : reg_addr_dec_rd_int[FC21_INT_ST_ONE_HOT  ] = 1'b1;
    FC22_INT_ST_ADDR : reg_addr_dec_rd_int[FC22_INT_ST_ONE_HOT  ] = 1'b1;
    FC23_INT_ST_ADDR : reg_addr_dec_rd_int[FC23_INT_ST_ONE_HOT  ] = 1'b1;
    FC24_INT_ST_ADDR : reg_addr_dec_rd_int[FC24_INT_ST_ONE_HOT  ] = 1'b1;
    FC25_INT_ST_ADDR : reg_addr_dec_rd_int[FC25_INT_ST_ONE_HOT  ] = 1'b1;
    FC26_INT_ST_ADDR : reg_addr_dec_rd_int[FC26_INT_ST_ONE_HOT  ] = 1'b1;
    FC27_INT_ST_ADDR : reg_addr_dec_rd_int[FC27_INT_ST_ONE_HOT  ] = 1'b1;
    FC28_INT_ST_ADDR : reg_addr_dec_rd_int[FC28_INT_ST_ONE_HOT  ] = 1'b1;
    FC29_INT_ST_ADDR : reg_addr_dec_rd_int[FC29_INT_ST_ONE_HOT  ] = 1'b1;
    FC30_INT_ST_ADDR : reg_addr_dec_rd_int[FC30_INT_ST_ONE_HOT  ] = 1'b1;
    FC31_INT_ST_ADDR : reg_addr_dec_rd_int[FC31_INT_ST_ONE_HOT  ] = 1'b1;
    FW_INT_ST_ADDR   : reg_addr_dec_rd_int[FW_INT_ST_ONE_HOT    ] = 1'b1;
    FC0_INT_MSK_ADDR : reg_addr_dec_rd_int[FC0_INT_MSK_ONE_HOT  ] = 1'b1;
    FC1_INT_MSK_ADDR : reg_addr_dec_rd_int[FC1_INT_MSK_ONE_HOT  ] = 1'b1;
    FC2_INT_MSK_ADDR : reg_addr_dec_rd_int[FC2_INT_MSK_ONE_HOT  ] = 1'b1;
    FC3_INT_MSK_ADDR : reg_addr_dec_rd_int[FC3_INT_MSK_ONE_HOT  ] = 1'b1;
    FC4_INT_MSK_ADDR : reg_addr_dec_rd_int[FC4_INT_MSK_ONE_HOT  ] = 1'b1;
    FC5_INT_MSK_ADDR : reg_addr_dec_rd_int[FC5_INT_MSK_ONE_HOT  ] = 1'b1;
    FC6_INT_MSK_ADDR : reg_addr_dec_rd_int[FC6_INT_MSK_ONE_HOT  ] = 1'b1;
    FC7_INT_MSK_ADDR : reg_addr_dec_rd_int[FC7_INT_MSK_ONE_HOT  ] = 1'b1;
    FC8_INT_MSK_ADDR : reg_addr_dec_rd_int[FC8_INT_MSK_ONE_HOT  ] = 1'b1;
    FC9_INT_MSK_ADDR : reg_addr_dec_rd_int[FC9_INT_MSK_ONE_HOT  ] = 1'b1;
    FC10_INT_MSK_ADDR: reg_addr_dec_rd_int[FC10_INT_MSK_ONE_HOT ] = 1'b1;
    FC11_INT_MSK_ADDR: reg_addr_dec_rd_int[FC11_INT_MSK_ONE_HOT ] = 1'b1;
    FC12_INT_MSK_ADDR: reg_addr_dec_rd_int[FC12_INT_MSK_ONE_HOT ] = 1'b1;
    FC13_INT_MSK_ADDR: reg_addr_dec_rd_int[FC13_INT_MSK_ONE_HOT ] = 1'b1;
    FC14_INT_MSK_ADDR: reg_addr_dec_rd_int[FC14_INT_MSK_ONE_HOT ] = 1'b1;
    FC15_INT_MSK_ADDR: reg_addr_dec_rd_int[FC15_INT_MSK_ONE_HOT ] = 1'b1;
    FC16_INT_MSK_ADDR: reg_addr_dec_rd_int[FC16_INT_MSK_ONE_HOT ] = 1'b1;
    FC17_INT_MSK_ADDR: reg_addr_dec_rd_int[FC17_INT_MSK_ONE_HOT ] = 1'b1;
    FC18_INT_MSK_ADDR: reg_addr_dec_rd_int[FC18_INT_MSK_ONE_HOT ] = 1'b1;
    FC19_INT_MSK_ADDR: reg_addr_dec_rd_int[FC19_INT_MSK_ONE_HOT ] = 1'b1;
    FC20_INT_MSK_ADDR: reg_addr_dec_rd_int[FC20_INT_MSK_ONE_HOT ] = 1'b1;
    FC21_INT_MSK_ADDR: reg_addr_dec_rd_int[FC21_INT_MSK_ONE_HOT ] = 1'b1;
    FC22_INT_MSK_ADDR: reg_addr_dec_rd_int[FC22_INT_MSK_ONE_HOT ] = 1'b1;
    FC23_INT_MSK_ADDR: reg_addr_dec_rd_int[FC23_INT_MSK_ONE_HOT ] = 1'b1;
    FC24_INT_MSK_ADDR: reg_addr_dec_rd_int[FC24_INT_MSK_ONE_HOT ] = 1'b1;
    FC25_INT_MSK_ADDR: reg_addr_dec_rd_int[FC25_INT_MSK_ONE_HOT ] = 1'b1;
    FC26_INT_MSK_ADDR: reg_addr_dec_rd_int[FC26_INT_MSK_ONE_HOT ] = 1'b1;
    FC27_INT_MSK_ADDR: reg_addr_dec_rd_int[FC27_INT_MSK_ONE_HOT ] = 1'b1;
    FC28_INT_MSK_ADDR: reg_addr_dec_rd_int[FC28_INT_MSK_ONE_HOT ] = 1'b1;
    FC29_INT_MSK_ADDR: reg_addr_dec_rd_int[FC29_INT_MSK_ONE_HOT ] = 1'b1;
    FC30_INT_MSK_ADDR: reg_addr_dec_rd_int[FC30_INT_MSK_ONE_HOT ] = 1'b1;
    FC31_INT_MSK_ADDR: reg_addr_dec_rd_int[FC31_INT_MSK_ONE_HOT ] = 1'b1;
    FW_TMP_TA_ADDR   : reg_addr_dec_rd_int[FW_TMP_TA_ONE_HOT    ] = 1'b1;
    FW_TMP_TP_ADDR   : reg_addr_dec_rd_int[FW_TMP_TP_ONE_HOT    ] = 1'b1;
    FW_TMP_MID_ADDR  : reg_addr_dec_rd_int[FW_TMP_MID_ONE_HOT   ] = 1'b1;
    FW_TMP_CTRL_ADDR : reg_addr_dec_rd_int[FW_TMP_CTRL_ONE_HOT  ] = 1'b1;
    FC_CAP0_ADDR     : reg_addr_dec_rd_int[FC_CAP0_ONE_HOT      ] = 1'b1;
    FC_CAP1_ADDR     : reg_addr_dec_rd_int[FC_CAP1_ONE_HOT      ] = 1'b1;
    FC_CAP2_ADDR     : reg_addr_dec_rd_int[FC_CAP2_ONE_HOT      ] = 1'b1;
    FC_CAP3_ADDR     : reg_addr_dec_rd_int[FC_CAP3_ONE_HOT      ] = 1'b1;
    FC_CFG0_ADDR     : reg_addr_dec_rd_int[FC_CFG0_ONE_HOT      ] = 1'b1;
    FC_CFG1_ADDR     : reg_addr_dec_rd_int[FC_CFG1_ONE_HOT      ] = 1'b1;
    FC_CFG2_ADDR     : reg_addr_dec_rd_int[FC_CFG2_ONE_HOT      ] = 1'b1;
    FC_CFG3_ADDR     : reg_addr_dec_rd_int[FC_CFG3_ONE_HOT      ] = 1'b1;
    IIDR_ADDR        : reg_addr_dec_rd_int[IIDR_ONE_HOT         ] = 1'b1;
    AIDR_ADDR        : reg_addr_dec_rd_int[AIDR_ONE_HOT         ] = 1'b1;
    PID4_ADDR        : reg_addr_dec_rd_int[PID4_ONE_HOT         ] = 1'b1;
    PID0_ADDR        : reg_addr_dec_rd_int[PID0_ONE_HOT         ] = 1'b1;
    PID1_ADDR        : reg_addr_dec_rd_int[PID1_ONE_HOT         ] = 1'b1;
    PID2_ADDR        : reg_addr_dec_rd_int[PID2_ONE_HOT         ] = 1'b1;
    PID3_ADDR        : reg_addr_dec_rd_int[PID3_ONE_HOT         ] = 1'b1;
    CID0_ADDR        : reg_addr_dec_rd_int[CID0_ONE_HOT         ] = 1'b1;
    CID1_ADDR        : reg_addr_dec_rd_int[CID1_ONE_HOT         ] = 1'b1;
    CID2_ADDR        : reg_addr_dec_rd_int[CID2_ONE_HOT         ] = 1'b1;
    CID3_ADDR        : reg_addr_dec_rd_int[CID3_ONE_HOT         ] = 1'b1;
    default          : reg_addr_dec_rd_int = {REG_ENUM_WIDTH{1'b0}};
  endcase
end 

always @*
begin: reg_cae_rd
  integer i;
  cae_pe0_rd = 1'b0;
  cae_pe0_lde2_rd = 1'b0;
  cae_pe0_rse1_te2_rd = 1'b0;
  cae_te0_rd = 1'b0;
  cae_pe0_mpe1_rd = 1'b0;
  cae_pe0_mpe2_rd = 1'b0;
  cae_pe0_mpe3_rd = 1'b0;
  cae_pe0_mpe4_rd = 1'b0;
  cae_rwe_rd = 1'b0;
  cae_me0_rd = 1'b0;
  cae_me0_me1_rd = 1'b0;
  cae_lde0_rd = 1'b0;
  cae_fc_int_rd = 1'b0;
  cae_sre_rd = 1'b0;
  cae_mxrs_rd = 1'b0;
  cae_mxrs_mnrs_rd = 1'b0;
  cae_fctlr_rd = 1'b0;

  cae_lde0_rd = (FW_LDE_LVL == 0) &&
    (reg_addr_dec_rd_int[LD_CTRL_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_TA_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_TP_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_MID_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_CTRL_ONE_HOT]);

  cae_rwe_rd = 1'b0;

  if ((cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}}) &&
    (reg_addr_dec_rd_int[FC0_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC0_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 1) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC1_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC1_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 2) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC2_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC2_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 3) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC3_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC3_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 4) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC4_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC4_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 5) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC5_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC5_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 6) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC6_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC6_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 7) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC7_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC7_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 8) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC8_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC8_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 9) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC9_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC9_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 10) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC10_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC10_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 11) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC11_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC11_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 12) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC12_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC12_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 13) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC13_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC13_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 14) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC14_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC14_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 15) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC15_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC15_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 16) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC16_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC16_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 17) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC17_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC17_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 18) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC18_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC18_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 19) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC19_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC19_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 20) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC20_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC20_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 21) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC21_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC21_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 22) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC22_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC22_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 23) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC23_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC23_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 24) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC24_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC24_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 25) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC25_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC25_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 26) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC26_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC26_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 27) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC27_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC27_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 28) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC28_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC28_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 29) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC29_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC29_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 30) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC30_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC30_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end
  else if (((FW_NUM_FC < 31) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_rd_int[FC31_INT_ST_ONE_HOT] || reg_addr_dec_rd_int[FC31_INT_MSK_ONE_HOT])) begin
    cae_fc_int_rd = 1'b1;
  end

  cae_sre_rd =
    ((FW_SRE_LVL == 0) || (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    reg_addr_dec_rd_int[FW_SR_CTRL_ONE_HOT];

  cae_fctlr_rd = (cfg_r_fw_id_o != {FW_ID_WIDTH{1'b0}}) &&
    (reg_addr_dec_rd_int[FW_CTRL_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_SR_CTRL_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_ST_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_INT_ST_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_TA_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_TP_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_MID_ONE_HOT] ||
     reg_addr_dec_rd_int[FW_TMP_CTRL_ONE_HOT] ||
     reg_addr_dec_rd_int[IIDR_ONE_HOT] ||
     reg_addr_dec_rd_int[AIDR_ONE_HOT] ||
     reg_addr_dec_rd_int[PID4_ONE_HOT] ||
     reg_addr_dec_rd_int[PID0_ONE_HOT] ||
     reg_addr_dec_rd_int[PID1_ONE_HOT] ||
     reg_addr_dec_rd_int[PID2_ONE_HOT] ||
     reg_addr_dec_rd_int[PID3_ONE_HOT] ||
     reg_addr_dec_rd_int[CID0_ONE_HOT] ||
     reg_addr_dec_rd_int[CID1_ONE_HOT] ||
     reg_addr_dec_rd_int[CID2_ONE_HOT] ||
     reg_addr_dec_rd_int[CID3_ONE_HOT]);

  for (i=0; i<FW_NUM_FC+1; i=i+1) begin 

    if (i==cfg_r_fw_id_o) begin
      cae_pe0_rd = (FC_PE_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_rd_int[PE_CTRL_ONE_HOT] ||
         reg_addr_dec_rd_int[PE_ST_ONE_HOT] ||
         reg_addr_dec_rd_int[PE_BPS_ONE_HOT] ||
         reg_addr_dec_rd_int[RWE_CTRL_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_CTRL0_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_CTRL1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_ST_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_CFG0_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_CFG1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_SIZE_ONE_HOT] ||
         reg_addr_dec_rd_int[FE_TAL_ONE_HOT] ||
         reg_addr_dec_rd_int[FE_TAU_ONE_HOT] ||
         reg_addr_dec_rd_int[FE_TP_ONE_HOT] ||
         reg_addr_dec_rd_int[FE_MID_ONE_HOT] ||
         reg_addr_dec_rd_int[FE_CTRL_ONE_HOT]);
      cae_pe0_lde2_rd = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FW_LDE_LVL != 2)) &&
        reg_addr_dec_rd_int[RGN_LCTRL_ONE_HOT];
      cae_pe0_rse1_te2_rd = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        ((FC_RSE_LVL_ALL[i +: 1] != 1) &&
        (FC_TE_LVL_ALL[i*2 +: 2] != 2))) &&
        (reg_addr_dec_rd_int[RGN_TCFG0_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_TCFG1_ONE_HOT]);
      cae_te0_rd = (FC_TE_LVL_ALL[i*2 +: 2] == 0) &&
        reg_addr_dec_rd_int[RGN_TCFG2_ONE_HOT];
      cae_pe0_mpe1_rd = (FC_PE_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_rd_int[RGN_MID0_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL0_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe2_rd = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 2)) &&
        (reg_addr_dec_rd_int[RGN_MID1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL1_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe3_rd =  ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 3)) &&
        (reg_addr_dec_rd_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe4_rd = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 4)) &&
        (reg_addr_dec_rd_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_rd_int[RGN_MPL3_ONE_HOT] );
      cae_me0_rd = (FC_ME_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_rd_int[ME_CTRL_ONE_HOT] ||
         reg_addr_dec_rd_int[ME_ST_ONE_HOT] ||
         reg_addr_dec_rd_int[EDR_MID_ONE_HOT] ||
         reg_addr_dec_rd_int[EDR_CTRL_ONE_HOT] ||
         reg_addr_dec_rd_int[EDR_TP_ONE_HOT]);
      cae_me0_me1_rd = (FC_ME_LVL_ALL[i*2 +: 2] != 2) &&
        (reg_addr_dec_rd_int[EDR_TAL_ONE_HOT] ||
         reg_addr_dec_rd_int[EDR_TAU_ONE_HOT]);
      cae_mxrs_rd = (FC_MXRS_ALL[i*7 +: 7] <= 32) &&
        (reg_addr_dec_rd_int[RGN_CFG1_ONE_HOT] ||
          reg_addr_dec_rd_int[RGN_TCFG1_ONE_HOT]);
      cae_mxrs_mnrs_rd = ((FC_MNRS_ALL[i*7 +: 7] + 5) == FC_MXRS_ALL[i*7 +: 7]) &&
        (reg_addr_dec_rd_int[RGN_CFG0_ONE_HOT] ||
          reg_addr_dec_rd_int[RGN_CFG1_ONE_HOT] ||
          reg_addr_dec_rd_int[RGN_TCFG0_ONE_HOT] ||
          reg_addr_dec_rd_int[RGN_TCFG1_ONE_HOT]);
    end
  end

  cae_rd = cae_pe0_rd || cae_pe0_lde2_rd || cae_pe0_rse1_te2_rd ||
           cae_te0_rd || cae_pe0_mpe1_rd || cae_pe0_mpe2_rd || cae_pe0_mpe3_rd ||
           cae_pe0_mpe4_rd || cae_rwe_rd || cae_me0_rd || cae_me0_me1_rd ||
           cae_lde0_rd || cae_fc_int_rd || cae_sre_rd || cae_mxrs_rd ||
           cae_mxrs_mnrs_rd || cae_fctlr_rd;
end


always @*
begin: reg_dec_wr

  reg_addr_dec_wr_int = {REG_ENUM_WIDTH{1'b0}};

  case (awaddr_s_i[11:0])
    FW_CTRL_ADDR     : reg_addr_dec_wr_int[FW_CTRL_ONE_HOT      ] = 1'b1;
    FW_ST_ADDR       : reg_addr_dec_wr_int[FW_ST_ONE_HOT        ] = 1'b1;
    FW_SR_CTRL_ADDR  : reg_addr_dec_wr_int[FW_SR_CTRL_ONE_HOT   ] = 1'b1;
    LD_CTRL_ADDR     : reg_addr_dec_wr_int[LD_CTRL_ONE_HOT      ] = 1'b1;
    PE_CTRL_ADDR     : reg_addr_dec_wr_int[PE_CTRL_ONE_HOT      ] = 1'b1;
    PE_ST_ADDR       : reg_addr_dec_wr_int[PE_ST_ONE_HOT        ] = 1'b1;
    PE_BPS_ADDR      : reg_addr_dec_wr_int[PE_BPS_ONE_HOT       ] = 1'b1;
    RWE_CTRL_ADDR    : reg_addr_dec_wr_int[RWE_CTRL_ONE_HOT     ] = 1'b1;
    RGN_CTRL0_ADDR   : reg_addr_dec_wr_int[RGN_CTRL0_ONE_HOT    ] = 1'b1;
    RGN_CTRL1_ADDR   : reg_addr_dec_wr_int[RGN_CTRL1_ONE_HOT    ] = 1'b1;
    RGN_LCTRL_ADDR   : reg_addr_dec_wr_int[RGN_LCTRL_ONE_HOT    ] = 1'b1;
    RGN_ST_ADDR      : reg_addr_dec_wr_int[RGN_ST_ONE_HOT       ] = 1'b1;
    RGN_CFG0_ADDR    : reg_addr_dec_wr_int[RGN_CFG0_ONE_HOT     ] = 1'b1;
    RGN_CFG1_ADDR    : reg_addr_dec_wr_int[RGN_CFG1_ONE_HOT     ] = 1'b1;
    RGN_SIZE_ADDR    : reg_addr_dec_wr_int[RGN_SIZE_ONE_HOT     ] = 1'b1;
    RGN_TCFG0_ADDR   : reg_addr_dec_wr_int[RGN_TCFG0_ONE_HOT    ] = 1'b1;
    RGN_TCFG1_ADDR   : reg_addr_dec_wr_int[RGN_TCFG1_ONE_HOT    ] = 1'b1;
    RGN_TCFG2_ADDR   : reg_addr_dec_wr_int[RGN_TCFG2_ONE_HOT    ] = 1'b1;
    RGN_MID0_ADDR    : reg_addr_dec_wr_int[RGN_MID0_ONE_HOT     ] = 1'b1;
    RGN_MPL0_ADDR    : reg_addr_dec_wr_int[RGN_MPL0_ONE_HOT     ] = 1'b1;
    RGN_MID1_ADDR    : reg_addr_dec_wr_int[RGN_MID1_ONE_HOT     ] = 1'b1;
    RGN_MPL1_ADDR    : reg_addr_dec_wr_int[RGN_MPL1_ONE_HOT     ] = 1'b1;
    RGN_MID2_ADDR    : reg_addr_dec_wr_int[RGN_MID2_ONE_HOT     ] = 1'b1;
    RGN_MPL2_ADDR    : reg_addr_dec_wr_int[RGN_MPL2_ONE_HOT     ] = 1'b1;
    RGN_MID3_ADDR    : reg_addr_dec_wr_int[RGN_MID3_ONE_HOT     ] = 1'b1;
    RGN_MPL3_ADDR    : reg_addr_dec_wr_int[RGN_MPL3_ONE_HOT     ] = 1'b1;
    FE_TAL_ADDR      : reg_addr_dec_wr_int[FE_TAL_ONE_HOT       ] = 1'b1;
    FE_TAU_ADDR      : reg_addr_dec_wr_int[FE_TAU_ONE_HOT       ] = 1'b1;
    FE_TP_ADDR       : reg_addr_dec_wr_int[FE_TP_ONE_HOT        ] = 1'b1;
    FE_MID_ADDR      : reg_addr_dec_wr_int[FE_MID_ONE_HOT       ] = 1'b1;
    FE_CTRL_ADDR     : reg_addr_dec_wr_int[FE_CTRL_ONE_HOT      ] = 1'b1;
    ME_CTRL_ADDR     : reg_addr_dec_wr_int[ME_CTRL_ONE_HOT      ] = 1'b1;
    ME_ST_ADDR       : reg_addr_dec_wr_int[ME_ST_ONE_HOT        ] = 1'b1;
    EDR_TAL_ADDR     : reg_addr_dec_wr_int[EDR_TAL_ONE_HOT      ] = 1'b1;
    EDR_TAU_ADDR     : reg_addr_dec_wr_int[EDR_TAU_ONE_HOT      ] = 1'b1;
    EDR_TP_ADDR      : reg_addr_dec_wr_int[EDR_TP_ONE_HOT       ] = 1'b1;
    EDR_MID_ADDR     : reg_addr_dec_wr_int[EDR_MID_ONE_HOT      ] = 1'b1;
    EDR_CTRL_ADDR    : reg_addr_dec_wr_int[EDR_CTRL_ONE_HOT     ] = 1'b1;
    FC0_INT_ST_ADDR  : reg_addr_dec_wr_int[FC0_INT_ST_ONE_HOT   ] = 1'b1;
    FC1_INT_ST_ADDR  : reg_addr_dec_wr_int[FC1_INT_ST_ONE_HOT   ] = 1'b1;
    FC2_INT_ST_ADDR  : reg_addr_dec_wr_int[FC2_INT_ST_ONE_HOT   ] = 1'b1;
    FC3_INT_ST_ADDR  : reg_addr_dec_wr_int[FC3_INT_ST_ONE_HOT   ] = 1'b1;
    FC4_INT_ST_ADDR  : reg_addr_dec_wr_int[FC4_INT_ST_ONE_HOT   ] = 1'b1;
    FC5_INT_ST_ADDR  : reg_addr_dec_wr_int[FC5_INT_ST_ONE_HOT   ] = 1'b1;
    FC6_INT_ST_ADDR  : reg_addr_dec_wr_int[FC6_INT_ST_ONE_HOT   ] = 1'b1;
    FC7_INT_ST_ADDR  : reg_addr_dec_wr_int[FC7_INT_ST_ONE_HOT   ] = 1'b1;
    FC8_INT_ST_ADDR  : reg_addr_dec_wr_int[FC8_INT_ST_ONE_HOT   ] = 1'b1;
    FC9_INT_ST_ADDR  : reg_addr_dec_wr_int[FC9_INT_ST_ONE_HOT   ] = 1'b1;
    FC10_INT_ST_ADDR : reg_addr_dec_wr_int[FC10_INT_ST_ONE_HOT  ] = 1'b1;
    FC11_INT_ST_ADDR : reg_addr_dec_wr_int[FC11_INT_ST_ONE_HOT  ] = 1'b1;
    FC12_INT_ST_ADDR : reg_addr_dec_wr_int[FC12_INT_ST_ONE_HOT  ] = 1'b1;
    FC13_INT_ST_ADDR : reg_addr_dec_wr_int[FC13_INT_ST_ONE_HOT  ] = 1'b1;
    FC14_INT_ST_ADDR : reg_addr_dec_wr_int[FC14_INT_ST_ONE_HOT  ] = 1'b1;
    FC15_INT_ST_ADDR : reg_addr_dec_wr_int[FC15_INT_ST_ONE_HOT  ] = 1'b1;
    FC16_INT_ST_ADDR : reg_addr_dec_wr_int[FC16_INT_ST_ONE_HOT  ] = 1'b1;
    FC17_INT_ST_ADDR : reg_addr_dec_wr_int[FC17_INT_ST_ONE_HOT  ] = 1'b1;
    FC18_INT_ST_ADDR : reg_addr_dec_wr_int[FC18_INT_ST_ONE_HOT  ] = 1'b1;
    FC19_INT_ST_ADDR : reg_addr_dec_wr_int[FC19_INT_ST_ONE_HOT  ] = 1'b1;
    FC20_INT_ST_ADDR : reg_addr_dec_wr_int[FC20_INT_ST_ONE_HOT  ] = 1'b1;
    FC21_INT_ST_ADDR : reg_addr_dec_wr_int[FC21_INT_ST_ONE_HOT  ] = 1'b1;
    FC22_INT_ST_ADDR : reg_addr_dec_wr_int[FC22_INT_ST_ONE_HOT  ] = 1'b1;
    FC23_INT_ST_ADDR : reg_addr_dec_wr_int[FC23_INT_ST_ONE_HOT  ] = 1'b1;
    FC24_INT_ST_ADDR : reg_addr_dec_wr_int[FC24_INT_ST_ONE_HOT  ] = 1'b1;
    FC25_INT_ST_ADDR : reg_addr_dec_wr_int[FC25_INT_ST_ONE_HOT  ] = 1'b1;
    FC26_INT_ST_ADDR : reg_addr_dec_wr_int[FC26_INT_ST_ONE_HOT  ] = 1'b1;
    FC27_INT_ST_ADDR : reg_addr_dec_wr_int[FC27_INT_ST_ONE_HOT  ] = 1'b1;
    FC28_INT_ST_ADDR : reg_addr_dec_wr_int[FC28_INT_ST_ONE_HOT  ] = 1'b1;
    FC29_INT_ST_ADDR : reg_addr_dec_wr_int[FC29_INT_ST_ONE_HOT  ] = 1'b1;
    FC30_INT_ST_ADDR : reg_addr_dec_wr_int[FC30_INT_ST_ONE_HOT  ] = 1'b1;
    FC31_INT_ST_ADDR : reg_addr_dec_wr_int[FC31_INT_ST_ONE_HOT  ] = 1'b1;
    FW_INT_ST_ADDR   : reg_addr_dec_wr_int[FW_INT_ST_ONE_HOT    ] = 1'b1;
    FC0_INT_MSK_ADDR : reg_addr_dec_wr_int[FC0_INT_MSK_ONE_HOT  ] = 1'b1;
    FC1_INT_MSK_ADDR : reg_addr_dec_wr_int[FC1_INT_MSK_ONE_HOT  ] = 1'b1;
    FC2_INT_MSK_ADDR : reg_addr_dec_wr_int[FC2_INT_MSK_ONE_HOT  ] = 1'b1;
    FC3_INT_MSK_ADDR : reg_addr_dec_wr_int[FC3_INT_MSK_ONE_HOT  ] = 1'b1;
    FC4_INT_MSK_ADDR : reg_addr_dec_wr_int[FC4_INT_MSK_ONE_HOT  ] = 1'b1;
    FC5_INT_MSK_ADDR : reg_addr_dec_wr_int[FC5_INT_MSK_ONE_HOT  ] = 1'b1;
    FC6_INT_MSK_ADDR : reg_addr_dec_wr_int[FC6_INT_MSK_ONE_HOT  ] = 1'b1;
    FC7_INT_MSK_ADDR : reg_addr_dec_wr_int[FC7_INT_MSK_ONE_HOT  ] = 1'b1;
    FC8_INT_MSK_ADDR : reg_addr_dec_wr_int[FC8_INT_MSK_ONE_HOT  ] = 1'b1;
    FC9_INT_MSK_ADDR : reg_addr_dec_wr_int[FC9_INT_MSK_ONE_HOT  ] = 1'b1;
    FC10_INT_MSK_ADDR: reg_addr_dec_wr_int[FC10_INT_MSK_ONE_HOT ] = 1'b1;
    FC11_INT_MSK_ADDR: reg_addr_dec_wr_int[FC11_INT_MSK_ONE_HOT ] = 1'b1;
    FC12_INT_MSK_ADDR: reg_addr_dec_wr_int[FC12_INT_MSK_ONE_HOT ] = 1'b1;
    FC13_INT_MSK_ADDR: reg_addr_dec_wr_int[FC13_INT_MSK_ONE_HOT ] = 1'b1;
    FC14_INT_MSK_ADDR: reg_addr_dec_wr_int[FC14_INT_MSK_ONE_HOT ] = 1'b1;
    FC15_INT_MSK_ADDR: reg_addr_dec_wr_int[FC15_INT_MSK_ONE_HOT ] = 1'b1;
    FC16_INT_MSK_ADDR: reg_addr_dec_wr_int[FC16_INT_MSK_ONE_HOT ] = 1'b1;
    FC17_INT_MSK_ADDR: reg_addr_dec_wr_int[FC17_INT_MSK_ONE_HOT ] = 1'b1;
    FC18_INT_MSK_ADDR: reg_addr_dec_wr_int[FC18_INT_MSK_ONE_HOT ] = 1'b1;
    FC19_INT_MSK_ADDR: reg_addr_dec_wr_int[FC19_INT_MSK_ONE_HOT ] = 1'b1;
    FC20_INT_MSK_ADDR: reg_addr_dec_wr_int[FC20_INT_MSK_ONE_HOT ] = 1'b1;
    FC21_INT_MSK_ADDR: reg_addr_dec_wr_int[FC21_INT_MSK_ONE_HOT ] = 1'b1;
    FC22_INT_MSK_ADDR: reg_addr_dec_wr_int[FC22_INT_MSK_ONE_HOT ] = 1'b1;
    FC23_INT_MSK_ADDR: reg_addr_dec_wr_int[FC23_INT_MSK_ONE_HOT ] = 1'b1;
    FC24_INT_MSK_ADDR: reg_addr_dec_wr_int[FC24_INT_MSK_ONE_HOT ] = 1'b1;
    FC25_INT_MSK_ADDR: reg_addr_dec_wr_int[FC25_INT_MSK_ONE_HOT ] = 1'b1;
    FC26_INT_MSK_ADDR: reg_addr_dec_wr_int[FC26_INT_MSK_ONE_HOT ] = 1'b1;
    FC27_INT_MSK_ADDR: reg_addr_dec_wr_int[FC27_INT_MSK_ONE_HOT ] = 1'b1;
    FC28_INT_MSK_ADDR: reg_addr_dec_wr_int[FC28_INT_MSK_ONE_HOT ] = 1'b1;
    FC29_INT_MSK_ADDR: reg_addr_dec_wr_int[FC29_INT_MSK_ONE_HOT ] = 1'b1;
    FC30_INT_MSK_ADDR: reg_addr_dec_wr_int[FC30_INT_MSK_ONE_HOT ] = 1'b1;
    FC31_INT_MSK_ADDR: reg_addr_dec_wr_int[FC31_INT_MSK_ONE_HOT ] = 1'b1;
    FW_TMP_TA_ADDR   : reg_addr_dec_wr_int[FW_TMP_TA_ONE_HOT    ] = 1'b1;
    FW_TMP_TP_ADDR   : reg_addr_dec_wr_int[FW_TMP_TP_ONE_HOT    ] = 1'b1;
    FW_TMP_MID_ADDR  : reg_addr_dec_wr_int[FW_TMP_MID_ONE_HOT   ] = 1'b1;
    FW_TMP_CTRL_ADDR : reg_addr_dec_wr_int[FW_TMP_CTRL_ONE_HOT  ] = 1'b1;
    FC_CAP0_ADDR     : reg_addr_dec_wr_int[FC_CAP0_ONE_HOT      ] = 1'b1;
    FC_CAP1_ADDR     : reg_addr_dec_wr_int[FC_CAP1_ONE_HOT      ] = 1'b1;
    FC_CAP2_ADDR     : reg_addr_dec_wr_int[FC_CAP2_ONE_HOT      ] = 1'b1;
    FC_CAP3_ADDR     : reg_addr_dec_wr_int[FC_CAP3_ONE_HOT      ] = 1'b1;
    FC_CFG0_ADDR     : reg_addr_dec_wr_int[FC_CFG0_ONE_HOT      ] = 1'b1;
    FC_CFG1_ADDR     : reg_addr_dec_wr_int[FC_CFG1_ONE_HOT      ] = 1'b1;
    FC_CFG2_ADDR     : reg_addr_dec_wr_int[FC_CFG2_ONE_HOT      ] = 1'b1;
    FC_CFG3_ADDR     : reg_addr_dec_wr_int[FC_CFG3_ONE_HOT      ] = 1'b1;
    IIDR_ADDR        : reg_addr_dec_wr_int[IIDR_ONE_HOT         ] = 1'b1;
    AIDR_ADDR        : reg_addr_dec_wr_int[AIDR_ONE_HOT         ] = 1'b1;
    PID4_ADDR        : reg_addr_dec_wr_int[PID4_ONE_HOT         ] = 1'b1;
    PID0_ADDR        : reg_addr_dec_wr_int[PID0_ONE_HOT         ] = 1'b1;
    PID1_ADDR        : reg_addr_dec_wr_int[PID1_ONE_HOT         ] = 1'b1;
    PID2_ADDR        : reg_addr_dec_wr_int[PID2_ONE_HOT         ] = 1'b1;
    PID3_ADDR        : reg_addr_dec_wr_int[PID3_ONE_HOT         ] = 1'b1;
    CID0_ADDR        : reg_addr_dec_wr_int[CID0_ONE_HOT         ] = 1'b1;
    CID1_ADDR        : reg_addr_dec_wr_int[CID1_ONE_HOT         ] = 1'b1;
    CID2_ADDR        : reg_addr_dec_wr_int[CID2_ONE_HOT         ] = 1'b1;
    CID3_ADDR        : reg_addr_dec_wr_int[CID3_ONE_HOT         ] = 1'b1;
    default          : reg_addr_dec_wr_int = {REG_ENUM_WIDTH{1'b0}};
  endcase
end

always @*
begin: reg_cae_wr
  integer i;

  cae_pe0_wr = 1'b0;
  cae_pe0_lde2_wr = 1'b0;
  cae_pe0_rse1_te2_wr = 1'b0;
  cae_te0_wr = 1'b0;
  cae_pe0_mpe1_wr = 1'b0;
  cae_pe0_mpe2_wr = 1'b0;
  cae_pe0_mpe3_wr = 1'b0;
  cae_pe0_mpe4_wr = 1'b0;
  cae_rwe_wr = 1'b0;
  cae_me0_wr = 1'b0;
  cae_me0_me1_wr = 1'b0;
  cae_lde0_wr = 1'b0;
  cae_fc_int_wr = 1'b0;
  cae_sre_wr = 1'b0;
  cae_mxrs_wr = 1'b0;
  cae_mxrs_mnrs_wr = 1'b0;
  cae_fctlr_wr = 1'b0;

  cae_lde0_wr = (FW_LDE_LVL == 0) &&
    (reg_addr_dec_wr_int[LD_CTRL_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_TA_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_TP_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_MID_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_CTRL_ONE_HOT]);

  if ((cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}}) &&
    (reg_addr_dec_wr_int[FC0_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC0_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 1) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC1_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC1_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 2) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC2_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC2_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 3) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC3_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC3_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 4) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC4_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC4_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 5) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC5_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC5_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 6) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC6_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC6_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 7) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC7_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC7_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 8) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC8_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC8_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 9) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC9_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC9_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 10) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC10_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC10_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 11) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC11_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC11_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 12) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC12_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC12_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 13) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC13_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC13_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 14) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC14_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC14_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 15) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC15_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC15_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 16) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC16_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC16_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 17) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC17_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC17_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 18) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC18_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC18_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 19) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC19_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC19_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 20) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC20_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC20_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 21) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC21_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC21_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 22) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC22_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC22_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 23) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC23_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC23_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 24) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC24_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC24_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 25) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC25_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC25_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 26) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC26_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC26_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 27) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC27_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC27_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 28) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC28_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC28_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 29) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC29_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC29_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 30) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC30_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC30_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end
  else if (((FW_NUM_FC < 31) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    (reg_addr_dec_wr_int[FC31_INT_ST_ONE_HOT] || reg_addr_dec_wr_int[FC31_INT_MSK_ONE_HOT])) begin
    cae_fc_int_wr = 1'b1;
  end

  cae_sre_wr =
    ((FW_SRE_LVL == 0) || (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}})) &&
    reg_addr_dec_wr_int[FW_SR_CTRL_ONE_HOT];

  cae_fctlr_wr = (cfg_w_fw_id_o != {FW_ID_WIDTH{1'b0}}) &&
    (reg_addr_dec_wr_int[FW_CTRL_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_SR_CTRL_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_ST_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_INT_ST_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_TA_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_TP_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_MID_ONE_HOT] ||
     reg_addr_dec_wr_int[FW_TMP_CTRL_ONE_HOT] ||
     reg_addr_dec_wr_int[IIDR_ONE_HOT] ||
     reg_addr_dec_wr_int[AIDR_ONE_HOT] ||
     reg_addr_dec_wr_int[PID4_ONE_HOT] ||
     reg_addr_dec_wr_int[PID0_ONE_HOT] ||
     reg_addr_dec_wr_int[PID1_ONE_HOT] ||
     reg_addr_dec_wr_int[PID2_ONE_HOT] ||
     reg_addr_dec_wr_int[PID3_ONE_HOT] ||
     reg_addr_dec_wr_int[CID0_ONE_HOT] ||
     reg_addr_dec_wr_int[CID1_ONE_HOT] ||
     reg_addr_dec_wr_int[CID2_ONE_HOT] ||
     reg_addr_dec_wr_int[CID3_ONE_HOT]);

  for (i=0; i<FW_NUM_FC+1; i=i+1) begin 

    if (i==cfg_w_fw_id_o) begin

      cae_pe0_wr = (FC_PE_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_wr_int[PE_CTRL_ONE_HOT] ||
         reg_addr_dec_wr_int[PE_ST_ONE_HOT] ||
         reg_addr_dec_wr_int[PE_BPS_ONE_HOT] ||
         reg_addr_dec_wr_int[RWE_CTRL_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_CTRL0_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_CTRL1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_ST_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_CFG0_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_CFG1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_SIZE_ONE_HOT] ||
         reg_addr_dec_wr_int[FE_TAL_ONE_HOT] ||
         reg_addr_dec_wr_int[FE_TAU_ONE_HOT] ||
         reg_addr_dec_wr_int[FE_TP_ONE_HOT] ||
         reg_addr_dec_wr_int[FE_MID_ONE_HOT] ||
         reg_addr_dec_wr_int[FE_CTRL_ONE_HOT]);
      cae_pe0_lde2_wr = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FW_LDE_LVL != 2)) &&
        reg_addr_dec_wr_int[RGN_LCTRL_ONE_HOT];
      cae_pe0_rse1_te2_wr = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        ((FC_RSE_LVL_ALL[i +: 1] != 1) &&
        (FC_TE_LVL_ALL[i*2 +: 2] != 2))) &&
        (reg_addr_dec_wr_int[RGN_TCFG0_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_TCFG1_ONE_HOT]);
      cae_te0_wr = (FC_TE_LVL_ALL[i*2 +: 2] == 0) &&
        reg_addr_dec_wr_int[RGN_TCFG2_ONE_HOT];
      cae_pe0_mpe1_wr = (FC_PE_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_wr_int[RGN_MID0_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL0_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe2_wr = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 2)) &&
        (reg_addr_dec_wr_int[RGN_MID1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL1_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe3_wr =  ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 3)) &&
        (reg_addr_dec_wr_int[RGN_MID2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL2_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL3_ONE_HOT] );
      cae_pe0_mpe4_wr = ((FC_PE_LVL_ALL[i*2 +: 2] == 0) ||
        (FC_NUM_MPE_ALL[i*3 +: 3] < 4)) &&
        (reg_addr_dec_wr_int[RGN_MID3_ONE_HOT] ||
         reg_addr_dec_wr_int[RGN_MPL3_ONE_HOT] );
      cae_rwe_wr = ((wdata_s_i[7:0] & RWE_CTRL_MASK[i*8 +: 8]) >=
        FC_NUM_RGN_ALL[i*7 +: 7]) && reg_addr_dec_wr_int[RWE_CTRL_ONE_HOT];
      cae_me0_wr = (FC_ME_LVL_ALL[i*2 +: 2] == 0) &&
        (reg_addr_dec_wr_int[ME_CTRL_ONE_HOT] ||
         reg_addr_dec_wr_int[ME_ST_ONE_HOT] ||
         reg_addr_dec_wr_int[EDR_MID_ONE_HOT] ||
         reg_addr_dec_wr_int[EDR_CTRL_ONE_HOT] ||
         reg_addr_dec_wr_int[EDR_TP_ONE_HOT]);
      cae_me0_me1_wr = (FC_ME_LVL_ALL[i*2 +: 2] != 2) &&
        (reg_addr_dec_wr_int[EDR_TAL_ONE_HOT] ||
         reg_addr_dec_wr_int[EDR_TAU_ONE_HOT]);
      cae_mxrs_wr = (FC_MXRS_ALL[i*7 +: 7] <= 32) &&
        (reg_addr_dec_wr_int[RGN_CFG1_ONE_HOT] ||
          reg_addr_dec_wr_int[RGN_TCFG1_ONE_HOT]);
      cae_mxrs_mnrs_wr = ((FC_MNRS_ALL[i*7 +: 7] + 5) == FC_MXRS_ALL[i*7 +: 7]) &&
        (reg_addr_dec_wr_int[RGN_CFG0_ONE_HOT] ||
          reg_addr_dec_wr_int[RGN_CFG1_ONE_HOT] ||
          reg_addr_dec_wr_int[RGN_TCFG0_ONE_HOT] ||
          reg_addr_dec_wr_int[RGN_TCFG1_ONE_HOT]);
    end
  end

  cae_wr = cae_pe0_wr || cae_pe0_lde2_wr || cae_pe0_rse1_te2_wr ||
    cae_te0_wr || cae_pe0_mpe1_wr || cae_pe0_mpe2_wr || cae_pe0_mpe3_wr ||
    cae_pe0_mpe4_wr || cae_rwe_wr || cae_me0_wr || cae_me0_me1_wr ||
    cae_lde0_wr || cae_fc_int_wr || cae_sre_wr || cae_mxrs_wr ||
    cae_mxrs_mnrs_wr || cae_fctlr_wr;

end

always @*
begin: early_read_ch
  early_resp_rd = 1'b0;
  resp_type_rd = 2'b00;  

  if (arvalid_s_i && (arlen_s_i != 8'h00 || arsize_s_i != 3'b010 || arcache_s_i[3:1] != 3'b000) ) begin
    early_resp_rd = 1'b1;
    resp_type_rd = 2'b10;

  end else if (arvalid_s_i && (araddr_s_i[15:12] != 4'b000 ||        
               reg_addr_dec_rd_int == {REG_ENUM_WIDTH{1'b0}} ||  
               araddr_s_i[20:16] > FW_NUM_FC)     
               ) begin 

    early_resp_rd = 1'b1;
    resp_type_rd = 2'b11;

  end else if (arvalid_s_i && (~sram_rdy_i && FW_SRE_LVL == 2'h1)) begin  
    if ((reg_addr_dec_rd_int[FC_CAP0_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP1_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP2_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP3_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG0_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG1_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG2_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG3_ONE_HOT] ||
                 ((cfg_r_fw_id_o == {FW_ID_WIDTH{1'b0}}) &&
                 (reg_addr_dec_rd_int[FW_SR_CTRL_ONE_HOT] ||
                 reg_addr_dec_rd_int[ AIDR_ONE_HOT] ||
                 reg_addr_dec_rd_int[ IIDR_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID0_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID1_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID2_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID3_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID4_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID0_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID1_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID2_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID3_ONE_HOT]))
                )) begin 
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b00;

    end else begin
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b10;
    end

  end else if (arvalid_s_i && ((sram_rdy_i && FW_SRE_LVL == 2'h1) || (FW_SRE_LVL == 2'h0))) begin

    if (cae_rd) begin 
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b10;

    end else if (FW_SRE_LVL == 2'h0 && !all_comp_pwr_st[all_r_fw_id]) begin
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b10;

    end else if (reg_addr_dec_rd_int[FC_CAP0_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP1_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP2_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CAP3_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG0_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG1_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG2_ONE_HOT] ||
                 reg_addr_dec_rd_int[FC_CFG3_ONE_HOT]
                ) begin 
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b00;
    end else if (reg_addr_dec_rd_int[ AIDR_ONE_HOT] ||
                 reg_addr_dec_rd_int[ IIDR_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID0_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID1_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID2_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID3_ONE_HOT] ||
                 reg_addr_dec_rd_int[ PID4_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID0_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID1_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID2_ONE_HOT] ||
                 reg_addr_dec_rd_int[ CID3_ONE_HOT] ) begin
      early_resp_rd = 1'b1;
      resp_type_rd = 2'b00;
    end
  end

end 

always @*
begin: early_write_ch
  early_resp_wr = 1'b0;
  resp_type_wr = 2'b11;  

  if (awvalid_s_i && (awlen_s_i != 8'h00 || awsize_s_i != 3'b010 || awcache_s_i[3:1] != 3'b000 || wstrb_s_i != {FC_AXIDATA_WIDTH/8{1'b1}} )) begin
      early_resp_wr = 1'b1;
      resp_type_wr = 2'b10;

  end else if (awvalid_s_i && (awaddr_s_i[15:12] != 4'b000 ||        
                               reg_addr_dec_wr_int == {REG_ENUM_WIDTH{1'b0}} ||  
                               awaddr_s_i[20:16] > FW_NUM_FC)
              ) begin 
      early_resp_wr = 1'b1;
      resp_type_wr = 2'b11; 

  end else if (awvalid_s_i && (!sram_rdy_i && FW_SRE_LVL == 2'h1) && (!(reg_addr_dec_wr_int[FW_SR_CTRL_ONE_HOT] && cfg_w_fw_id_o == {FW_ID_WIDTH{1'b0}})) ) begin
    early_resp_wr = 1'b1;
    if ((reg_addr_dec_wr_int[FC_CAP0_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP1_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP2_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP3_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG0_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG1_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG2_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG3_ONE_HOT] ||
                 ((cfg_w_fw_id_o == {FW_ID_WIDTH{1'b0}}) &&
                 (reg_addr_dec_wr_int[AIDR_ONE_HOT] ||
                 reg_addr_dec_wr_int[IIDR_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID0_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID1_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID2_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID3_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID4_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID0_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID1_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID2_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID3_ONE_HOT])))
              ) begin
      resp_type_wr = 2'b00;
    end else begin
      resp_type_wr = 2'b10;
    end
  end else if (awvalid_s_i && ((sram_rdy_i && FW_SRE_LVL == 2'h1) || (FW_SRE_LVL == 2'h0))) begin

    if (cae_wr) begin 
      early_resp_wr = 1'b1;
      resp_type_wr = 2'b10;

    end else if (awvalid_s_i && FW_SRE_LVL == 2'h0 && !all_comp_pwr_st[all_w_fw_id]) begin
    early_resp_wr = 1'b1;
    resp_type_wr = 2'b10;

    end else if (reg_addr_dec_wr_int[FC_CAP0_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP1_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP2_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CAP3_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG0_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG1_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG2_ONE_HOT] ||
                 reg_addr_dec_wr_int[FC_CFG3_ONE_HOT] ||
                 reg_addr_dec_wr_int[AIDR_ONE_HOT] ||
                 reg_addr_dec_wr_int[IIDR_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID0_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID1_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID2_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID3_ONE_HOT] ||
                 reg_addr_dec_wr_int[PID4_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID0_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID1_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID2_ONE_HOT] ||
                 reg_addr_dec_wr_int[CID3_ONE_HOT]
                ) begin
        early_resp_wr = 1'b1;
        resp_type_wr = 2'b00;
    end
  end
end 

always @*
begin: get_rdata_early
integer i;

  rdata_early = {FC_AXIDATA_WIDTH{1'b0}};
  fc_num_mpe_int = 3'b000;
  fc_mst_id_width_int = {32{1'b0}};

  if (cfg_r_fw_id_o == {FW_ID_WIDTH{1'b0}}) begin 
    if (reg_addr_dec_rd_o[FC_CAP0_ONE_HOT]) begin
      rdata_early[3:0] = {2'b0, FC_PE_LVL[1:0]};
      rdata_early[7:4] = {2'b0, FC_ME_LVL[1:0]};
      rdata_early[11:8] = {3'b0, FC_RSE_LVL[0]};
      rdata_early[15:12] = {2'b0, FC_TE_LVL[1:0]};
      rdata_early[19:16] = {2'b0, FW_LDE_LVL[1:0]};
      rdata_early[23:20] = {3'b0, FW_SRE_LVL[0]};
      rdata_early[27:24] = {2'b0, FW_SE_LVL[1:0]};
      rdata_early[31:28] = 4'b0000;
    end else if (reg_addr_dec_rd_o[FC_CAP1_ONE_HOT]) begin
      rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 
    end else if (reg_addr_dec_rd_o[FC_CAP2_ONE_HOT]) begin
      rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 
    end else if (reg_addr_dec_rd_o[FC_CAP3_ONE_HOT]) begin
      rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 
    end else if (reg_addr_dec_rd_o[FC_CFG0_ONE_HOT]) begin
      rdata_early[31:5] = 27'h000_0000;
      rdata_early[4:0] = 5'h00; 
    end else if (reg_addr_dec_rd_o[FC_CFG1_ONE_HOT]) begin
      rdata_early[31:21] = 11'h000;
      rdata_early[20] = FC_SEC_SPT[0];
      if (FC_TE_LVL[1:0] != 2'b00) begin
        rdata_early[19] = FC_MA_SPT[0];
        rdata_early[18] = FC_SH_SPT[0];
      end
      rdata_early[17] = FC_INST_SPT[0];
      rdata_early[16] = FC_PRIV_SPT[0];
      rdata_early[15:14] = 2'b00;
      rdata_early[13:12] = FC_NUM_MPE[1:0] - 2'b1;
      rdata_early[11] = 1'b0;
      rdata_early[10:8] = FC_MNRS[2:0];
      rdata_early[7:0] = {1'b0, FC_NUM_RGN[6:0] - 7'b1};
    end else if (reg_addr_dec_rd_o[FC_CFG2_ONE_HOT]) begin
      rdata_early[31] =  FC_SINGLE_MST[0] ;
      rdata_early[30:21] = 10'h000  ;
      rdata_early[20:13] = {1'b0, FC_MXRS[6:0]}  ;  
      rdata_early[12:8] =  FC_MST_ID_WIDTH[4:0] - 5'b1;
      rdata_early[7] = 1'b0  ;
      rdata_early[6:0] = FC_MXRS[6:0]  ;
    end else if (reg_addr_dec_rd_o[FC_CFG3_ONE_HOT]) begin
      rdata_early[31:6] =  26'h000_0000 ;
      rdata_early[5:0] =  FW_NUM_FC[5:0] ;
    end else if (reg_addr_dec_rd_o[PID0_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_pid0_i};
    end else if (reg_addr_dec_rd_o[PID1_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_pid1_i};
    end else if (reg_addr_dec_rd_o[PID2_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_pid2_i};
    end else if (reg_addr_dec_rd_o[PID3_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_pid3_i};
    end else if (reg_addr_dec_rd_o[PID4_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_pid4_i};
    end else if (reg_addr_dec_rd_o[CID0_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_cid0_i};
    end else if (reg_addr_dec_rd_o[CID1_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_cid1_i};
    end else if (reg_addr_dec_rd_o[CID2_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_cid2_i};
    end else if (reg_addr_dec_rd_o[CID3_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_cid3_i};
    end else if (reg_addr_dec_rd_o[AIDR_ONE_HOT]) begin
      rdata_early[31:0] = {24'h000000,reg_aidr_i};
    end else if (reg_addr_dec_rd_o[IIDR_ONE_HOT]) begin
      rdata_early[31:0] = {reg_iidr_i};
    end else if (reg_addr_dec_rd_o[FW_SR_CTRL_ONE_HOT]) begin
      rdata_early[31:0] = {reg_fw_sr_ctrl_i[1] ,{30{1'b0}}, reg_fw_sr_ctrl_i[0]};
    end

  end else begin 
    for (i=1; i<FW_NUM_FC+1; i=i+1) begin 

      if (i==cfg_r_fw_id_o) begin

        if (reg_addr_dec_rd_o[FC_CAP0_ONE_HOT]) begin
          rdata_early[3:0] = {2'b0, FC_PE_LVL_EXT[(i*2)-1 -: 2]};
          rdata_early[7:4] = {2'b0, FC_ME_LVL_EXT[(i*2)-1 -: 2]};
          rdata_early[11:8] = {3'b0, FC_RSE_LVL_EXT[(i-1)]};
          rdata_early[15:12] = {2'b0, FC_TE_LVL_EXT[(i*2)-1 -: 2]};
          rdata_early[19:16] = 4'h0; 
          rdata_early[23:20] = 4'h0; 
          rdata_early[27:24] = 4'h0; 
          rdata_early[31:28] = 4'b0000;
        end else if (reg_addr_dec_rd_o[FC_CAP1_ONE_HOT]) begin
          rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 
        end else if (reg_addr_dec_rd_o[FC_CAP2_ONE_HOT]) begin
          rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 
        end else if (reg_addr_dec_rd_o[FC_CAP3_ONE_HOT]) begin
          rdata_early = {FC_AXIDATA_WIDTH{1'b0}}; 

        end else if (reg_addr_dec_rd_o[FC_CFG0_ONE_HOT]) begin
          rdata_early[31:0] = {{31-FW_ID_WIDTH{1'b0}}, i[FW_ID_WIDTH:0]}; 
        end else if (reg_addr_dec_rd_o[FC_CFG1_ONE_HOT]) begin
          rdata_early[31:21] = 11'h000;
          rdata_early[20] = FC_SEC_SPT_EXT[i-1];
          if (FC_TE_LVL_EXT[(i*2)-1 -: 2] != 0) begin
            rdata_early[19] = FC_MA_SPT_EXT[i-1];
            rdata_early[18] = FC_SH_SPT_EXT[i-1];
          end
          rdata_early[17] = FC_INST_SPT_EXT[i-1];
          rdata_early[16] = FC_PRIV_SPT_EXT[i-1];
          rdata_early[15:14] = 2'b00;
          if (FC_PE_LVL_EXT[(i*2)-1 -: 2] != 0) begin
            fc_num_mpe_int = FC_NUM_MPE_EXT[(i*3)-1 -: 3] - 3'b001;
            rdata_early[13:12] = fc_num_mpe_int[1:0];
            rdata_early[10:8] = FC_MNRS_EXT[(i-1)*7 +: 3];
            rdata_early[7:0] = {1'b0, FC_NUM_RGN_EXT[(i*7)-1 -: 7] - 7'b1};
          end
          rdata_early[11] = 1'b0;

        end else if (reg_addr_dec_rd_o[FC_CFG2_ONE_HOT]) begin
          rdata_early[31] =  FC_SINGLE_MST_EXT[i-1] ;
          rdata_early[30:21] = 10'h000  ;
          rdata_early[20:13] = prot_size_i[i*8+7 -: 8]  ; 
          fc_mst_id_width_int = FC_MST_ID_WIDTH_EXT[(i*32)-1 -: 32]-1;
          rdata_early[12:8] = fc_mst_id_width_int[4:0];
          rdata_early[7] = 1'b0  ;
          if (FC_PE_LVL_EXT[(i*2)-1 -: 2] != 0) begin
            rdata_early[6:0] = FC_MXRS_EXT[(i*7)-1 -: 7]  ;
          end

        end else if (reg_addr_dec_rd_o[FC_CFG3_ONE_HOT]) begin
          rdata_early[31:6] =  26'h000_0000 ;
          rdata_early[5:0] =  6'h00 ;
        end
      end
    end
  end
end 

always @(posedge clk or negedge reset_n)
begin: early_read_resp
  if (!reset_n) begin
    rid_pchk_o  <= {FC_AXIID_WIDTH{1'b0}};
    rdata_pchk_o <= {FC_AXIDATA_WIDTH{1'b0}};
    rresp_pchk_o <= 2'b00;
    ruser_pchk_o <= 1'b0;
    rvalid_pchk_o <= 1'b0;
    arready_int <= 1'b0;
    arlen_reg <= 8'h00;
    arid_reg <= {FC_AXIID_WIDTH{1'b0}};
    resp_type_rd_reg <= 2'b00;
    rdata_begin <= 1'b0;
    rdata_ctr <= 9'h000;
    armmusid_reg <= {FC_MST_ID_WIDTH{1'b0}};
    mst_id_pchk_o <= {FC_MST_ID_WIDTH{1'b0}};
    rdata_early_reg <= {FC_AXIDATA_WIDTH{1'b0}};

  end else begin
    ruser_pchk_o <= 1'b0;
    if (arready_int) begin
      rdata_early_reg <= rdata_early;
    end else if (!rdata_begin) begin
      rdata_early_reg <= {FC_AXIDATA_WIDTH{1'b0}};
    end

    if (early_resp_rd && arvalid_s_i && !arready_int && resp_type_rd != 2'b01) begin 
      arid_reg <= arid_s_i;
      armmusid_reg <= armmusid_s_i;
      arlen_reg <= arlen_s_i;
      arready_int <= 1'b1;
      resp_type_rd_reg <= resp_type_rd;
    end else begin
      arready_int <= 1'b0;
    end

    if (arready_int) begin
      rdata_begin <= 1'b1;
    end else if (rvalid_pchk_o && rlast_pchk_o && rready_pchk_i) begin
      rdata_begin <= 1'b0;
    end

     if ((arready_int || rdata_begin) && !(rlast_pchk_o && rready_pchk_i)) begin
      mst_id_pchk_o <= armmusid_reg;
      rid_pchk_o <= arid_reg;
      rresp_pchk_o <= resp_type_rd_reg;
      rvalid_pchk_o <= 1'b1;
    end else begin
      rid_pchk_o    <= {FC_AXIID_WIDTH{1'b0}};
      rvalid_pchk_o <= 1'b0;
    end

    if (rvalid_pchk_o && rready_pchk_i && !rlast_pchk_o) begin
      rdata_ctr <= rdata_ctr + 9'h1;
    end else if (rvalid_pchk_o && rlast_pchk_o && rready_pchk_i) begin
      rdata_ctr <= 9'h000;
    end

    if ((arready_int || rdata_begin) && (resp_type_rd_reg == 2'b10 || resp_type_rd_reg == 2'b11) ) begin
      rdata_pchk_o <= {FC_AXIDATA_WIDTH{1'b0}};
    end else if (arready_int) begin
      rdata_pchk_o <= rdata_early;
    end else if (rdata_begin) begin
      rdata_pchk_o <= rdata_early_reg;
    end
  end
end 

always @*
begin
  rlast_pchk_o = 1'b0;
    if ((arready_int || rdata_begin) && (rdata_ctr == arlen_reg) ) begin  
      rlast_pchk_o  = 1'b1;
    end else if (rready_pchk_i) begin
      rlast_pchk_o  = 1'b0;
    end

end
always @(posedge clk or negedge reset_n)
begin: early_write_resp

  if (!reset_n) begin
    bid_pchk_o <= {FC_AXIID_WIDTH{1'b0}};
    bresp_pchk_o <= 2'b00;
    bvalid_pchk_o <= 1'b0;
    buser_pchk_o  <= 1'b0;
    awready_int <= 1'b0;
    wready_int <= 1'b0;
  end else begin
    buser_pchk_o  <= 1'b0;

    if (early_resp_wr && awvalid_s_i) begin
      bid_pchk_o <= awid_s_i;
      bresp_pchk_o <= resp_type_wr;
    end

    if (wlast_s_i && wvalid_s_i && wready_s_o && (early_resp_wr | wready_int)) begin
      bvalid_pchk_o <= 1'b1;
    end else if (bready_pchk_i) begin
      bvalid_pchk_o <= 1'b0;
    end

    if (!early_resp_wr) begin
      awready_int <= 1'b0;
    end else begin
      awready_int <= 1'b1;
    end

    if (early_resp_wr && !wready_int) begin
      wready_int <= 1'b1;
    end else if (wready_s_o && wvalid_s_i && wlast_s_i) begin
      wready_int <= 1'b0;
    end
  end
end 


always @*
begin: no_early_resp_rd
  arid_m_o      =   arid_s_i     ;
  araddr_m_o    =   araddr_s_i[REG_ADDR_WIDTH+1:2]   ;
  armmusid_m_o  =   armmusid_s_i ;

  if (!(early_resp_rd )) begin
    arvalid_m_o   =   arvalid_s_i  ;
    arready_s_o   =   arready_m_i  ;
  end else begin
    arvalid_m_o   =   1'b0  ;
    arready_s_o   =   arready_int  ;
  end


end 

always @*
begin: no_early_resp_wr
  awid_m_o      =   awid_s_i     ;
  awaddr_m_o    =   awaddr_s_i[REG_ADDR_WIDTH+1:2]   ;
  awmmusid_m_o  =   awmmusid_s_i ;
  wdata_m_o     =   wdata_s_i    ;

  if (!early_resp_wr ) begin
    awvalid_m_o   =   awvalid_s_i  ;
    awready_s_o   =   awready_m_i  ;
  end else begin
    awvalid_m_o   =   1'b0  ;
    awready_s_o   =   awready_int  ;
  end

  if (early_resp_wr || wready_int) begin
    wvalid_m_o    =   1'b0   ;
    wlast_m_o     =   1'b0    ;
    wready_s_o    =   wready_int   ;
  end else begin
    wvalid_m_o    =   wvalid_s_i   ;
    wlast_m_o     =   wlast_s_i    ;
    wready_s_o    =   wready_m_i   ;
  end
end 

assign pchk_read_tamp_o = early_resp_rd & (resp_type_rd != 2'b00) &
  (reg_addr_dec_rd_int[FW_TMP_TA_ONE_HOT] ||
  reg_addr_dec_rd_int[FW_TMP_TP_ONE_HOT] ||
  reg_addr_dec_rd_int[FW_TMP_MID_ONE_HOT] ||
  reg_addr_dec_rd_int[FW_TMP_CTRL_ONE_HOT]) &
  (araddr_s_i[FC_ADDR_WIDTH-1:12] == {(FC_ADDR_WIDTH-12){1'b0}}) &
  ((armmusid_s_i != FW_CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0]) ||
  (!arprot_s_i[0] && (FC_PRIV_SPT == 1)) ||
  (arprot_s_i[1] && (FC_SEC_SPT > 0))) & arvalid_s_i & arready_s_o;

assign pchk_write_tamp_o = early_resp_wr & (resp_type_wr != 2'b00) &
  (reg_addr_dec_wr_int[FW_TMP_TA_ONE_HOT] ||
  reg_addr_dec_wr_int[FW_TMP_TP_ONE_HOT] ||
  reg_addr_dec_wr_int[FW_TMP_MID_ONE_HOT] ||
  reg_addr_dec_wr_int[FW_TMP_CTRL_ONE_HOT]) &
  (awaddr_s_i[FC_ADDR_WIDTH-1:12] == {(FC_ADDR_WIDTH-12){1'b0}}) &
  ((awmmusid_s_i != FW_CFG_AGENT_MST_ID[FC_MST_ID_WIDTH-1:0]) ||
  (!awprot_s_i[0] && (FC_PRIV_SPT == 1)) ||
  (awprot_s_i[1] && (FC_SEC_SPT > 0))) & awvalid_s_i & awready_s_o;


endmodule
