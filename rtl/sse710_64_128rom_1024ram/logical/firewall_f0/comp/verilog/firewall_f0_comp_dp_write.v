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

module firewall_f0_comp_dp_write #(
  parameter FC_MST_ID_SINGLE_MST = 0,
  parameter FC_TE_LVL = 0,
  parameter FC_RSE_LVL = 0,
  parameter FC_PE_LVL = 2,
  parameter FC_ME_LVL = 0,
  parameter FW_SE_LVL           = 2'h1, 
  parameter FC_INST_SPT         = 0,
  parameter FC_PRIV_SPT         = 0,
  parameter FC_ADDR_WIDTH    = 64,
  parameter FC_AXIDATA_WIDTH = 64,
  parameter FC_AXIID_WIDTH   = 9 ,
  parameter FC_MST_ID_WIDTH  = 8,
  parameter FC_NUM_RGN          = 4,
  parameter LOG2_FC_NUM_RGN     = 2,
  parameter FC_NUM_MPE          = 4,
  parameter FC_MNRS             = 7'h0, 
  parameter FC_MXRS             = 7'h8,  
  parameter FC_SINGLE_MST       = 1,
  parameter FC_ID               = 1,
  parameter FC_AXIUSER_AW_WIDTH = 2,
  parameter FC_AXIUSER_W_WIDTH  = 2,
  parameter FC_AXIUSER_B_WIDTH  = 2,
  parameter TRACKER_PAYLOAD_WIDTH_AW = 2,
  parameter FC_SEC_SPT          = 1,
  `include "firewall_f0_reg_width_params.vh"
) (
    input  wire                       clk,
    input  wire                       reset_n,

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
    input  wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_s_i  ,
    input  wire                                   awvalid_s_i ,
    output wire                                   awready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output wire                                   wready_s_o  ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_s_o     ,
    output wire [1:0]                             bresp_s_o   ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]          buser_s_o   ,
    output wire                                   bvalid_s_o  ,
    input  wire                                   bready_s_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              awid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               awaddr_m_o  ,
    output wire [7:0]                             awlen_m_o   ,
    output wire [2:0]                             awsize_m_o  ,
    output wire [1:0]                             awburst_m_o ,
    output wire                                   awlock_m_o  ,
    output wire [3:0]                             awcache_m_o ,
    output wire [2:0]                             awprot_m_o  ,
    output wire [3:0]                             awqos_m_o   ,
    output wire [3:0]                             awregion_m_o,
    output wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_m_o  ,
    output wire                                   awvalid_m_o ,
    input  wire                                   awready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             awmmusid_m_o,

    output wire [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_m_o   ,
    output wire                                   wlast_m_o   ,
    output wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_m_o   ,
    output wire                                   wvalid_m_o  ,
    input  wire                                   wready_m_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]              bid_m_i     ,
    input  wire [1:0]                             bresp_m_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]          buser_m_i   ,
    input  wire                                   bvalid_m_i  ,
    output wire                                   bready_m_o  ,

    input  wire                                   tracker_al_empty_wr_i,
    input  wire                                   tracker_empty_wr_i,

    output wire [FC_AXIID_WIDTH-1:0]              tracker_id_wr_ch_o,
    output wire                                   tracker_read_wr_ch_o,
    input  wire [TRACKER_PAYLOAD_WIDTH_AW-1:0]    tracker_dout_wr_ch_i,
    input  wire                                   tracker_dout_wr_ch_vld_i,
    input  wire                                    rb_pe_st_err_i , 
    input  wire [1:0]                              rb_pe_st_flt_cfg_i, 
    input  wire                                    rb_pe_st_en_i,
    output wire [FE_TAL_WIDTH-1:0]                 rb_fe_tal_o,
    output wire [FE_TAU_WIDTH-1:0]                 rb_fe_tau_o,
    output wire [FE_TP_WIDTH-1:0]                  rb_fe_tp_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rb_fe_mid_o,
    output wire                                    rb_fe_valid_o,
    output wire                                    rb_fe_type_o,  
    output wire                                    rb_tmp_reg_err,
    input  wire [PROT_SIZE_WIDTH-1:0]              rb_prot_size_i,
    input  wire                                    rb_bypass_i,
    input  wire                                    rb_sram_rdy_i,
    input  wire                                    rb_fw_st_i,
    input  wire                                    rb_st_me_en_i,
    input  wire [(FC_NUM_RGN*RGN_TCFG0_WIDTH)-1:0] rb_cfg_rgn_tcfg0_i,
    input  wire [(FC_NUM_RGN*RGN_TCFG1_WIDTH)-1:0] rb_cfg_rgn_tcfg1_i,
    input  wire [(FC_NUM_RGN*RGN_TCFG2_WIDTH)-1:0] rb_cfg_rgn_tcfg2_i,

    input  wire [(FC_NUM_RGN*RGN_ST_WIDTH)-1:0]    rb_rgn_st_i,
    input  wire [(FC_NUM_RGN*RGN_SIZE_WIDTH)-1:0]  rb_rgn_size_i,
    input  wire [(FC_NUM_RGN*FC_MXRS)-1:0]         rb_rgn_base_addr_i,
    input  wire [(FC_NUM_RGN*FC_MXRS)-1:0]         rb_rgn_upper_addr_i,

    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rb_rgn_mid0_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rb_rgn_mid1_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rb_rgn_mid2_i,
    input  wire [(FC_NUM_RGN*FC_MST_ID_WIDTH)-1:0]  rb_rgn_mid3_i,

    input  wire [(FC_NUM_RGN*RGN_MPL0_WIDTH)-1:0]  rb_rgn_mpl0_i,
    input  wire [(FC_NUM_RGN*RGN_MPL1_WIDTH)-1:0]  rb_rgn_mpl1_i,
    input  wire [(FC_NUM_RGN*RGN_MPL2_WIDTH)-1:0]  rb_rgn_mpl2_i,
    input  wire [(FC_NUM_RGN*RGN_MPL3_WIDTH)-1:0]  rb_rgn_mpl3_i,

    output wire                                    wr_edr_wen_o,       
    output wire [31:0]                             wr_edr_addr_lwr_o,  
    output wire [31:0]                             wr_edr_addr_uppr_o, 
    output wire [FC_MST_ID_WIDTH+4-1:0]            wr_edr_prop_o,      

    input  wire [FC_AXIID_WIDTH-1:0]               bid_pchk_i     ,
    input  wire [1:0]                              bresp_pchk_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]           buser_pchk_i   ,
    input  wire                                    bvalid_pchk_i  ,
    output wire                                    bready_pchk_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]               bid_cfg_i     ,
    input  wire [1:0]                              bresp_cfg_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]           buser_cfg_i   ,
    input  wire                                    bvalid_cfg_i  ,
    output wire                                    bready_cfg_o

);

wire [FC_AXIID_WIDTH-1:0]           axid_flt_te_wire;
wire [FC_ADDR_WIDTH-1:0]            axaddr_flt_te_wire;
wire [7:0]                          axlen_flt_te_wire;
wire [2:0]                          axsize_flt_te_wire;
wire [1:0]                          axburst_flt_te_wire;
wire                                axlock_flt_te_wire;
wire [3:0]                          axcache_flt_te_wire;
wire [2:0]                          axprot_flt_te_wire;
wire [3:0]                          axqos_flt_te_wire;
wire [3:0]                          axregion_flt_te_wire;
wire [FC_AXIUSER_AW_WIDTH-1:0]      axuser_flt_te_wire;
wire                                axvalid_flt_te_wire;
wire                                axready_flt_te_wire;
wire [FC_MST_ID_WIDTH-1:0]          axmmusid_flt_te_wire;
wire [LOG2_FC_NUM_RGN-1:0]          rgn_number_wire;

wire [FC_AXIID_WIDTH-1:0]           axid_flt_fh_wire    ;
wire [FC_ADDR_WIDTH-1:0]            axaddr_flt_fh_wire  ;
wire [7:0]                          axlen_flt_fh_wire   ;
wire [2:0]                          axsize_flt_fh_wire  ;
wire [1:0]                          axburst_flt_fh_wire ;
wire                                axlock_flt_fh_wire  ;
wire [3:0]                          axcache_flt_fh_wire ;
wire [2:0]                          axprot_flt_fh_wire  ;
wire [3:0]                          axqos_flt_fh_wire   ;
wire [3:0]                          axregion_flt_fh_wire;
wire [FC_AXIUSER_AW_WIDTH-1:0]      axuser_flt_fh_wire  ;
wire                                axvalid_flt_fh_wire ;
wire                                axready_flt_fh_wire ;
wire [FC_MST_ID_WIDTH-1:0]          axmmusid_flt_fh_wire;

wire [FC_AXIID_WIDTH-1:0]           bid_fh_rh_wire   ;
wire [1:0]                          bresp_fh_rh_wire ;
wire [FC_AXIUSER_B_WIDTH-1:0]       buser_fh_rh_wire ;
wire                                bvalid_fh_rh_wire;
wire                                bready_fh_rh_wire;

wire [FC_AXIID_WIDTH-1:0]          bid_rm_rh_wire    ;
wire [1:0]                         bresp_rm_rh_wire  ;
wire [FC_AXIUSER_B_WIDTH-1:0]      buser_rm_rh_wire  ;
wire                               bvalid_rm_rh_wire ;
wire                               bready_rm_rh_wire ;

wire  filter_result_vld_flt_fh_wire;
wire  filter_result_vld_flt_te_wire;
wire [1:0] filter_result_val_flt_fh_wire;
wire [FC_MST_ID_WIDTH-1:0] mst_id_fh_rh_wire;

wire [FC_AXIID_WIDTH-1:0] tracker_id_wr_ch_rm_wire;
wire  tracker_read_wr_ch_rm_wire;
wire tracker_rd_fh_wire;
wire [FC_AXIID_WIDTH-1:0] tracker_rd_bid_fh_wire;

assign tracker_read_wr_ch_o = tracker_read_wr_ch_rm_wire | tracker_rd_fh_wire;
assign tracker_id_wr_ch_o = tracker_rd_fh_wire ? tracker_rd_bid_fh_wire : tracker_id_wr_ch_rm_wire;

firewall_f0_ax_filter #(
  .FC_PE_LVL          (FC_PE_LVL          ),
  .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
  .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AX_WIDTH(FC_AXIUSER_AW_WIDTH),
  .FC_NUM_RGN          (FC_NUM_RGN),
  .LOG2_FC_NUM_RGN     (LOG2_FC_NUM_RGN),
  .FC_NUM_MPE          (FC_NUM_MPE),
  .FC_MNRS             (FC_MNRS),
  .FC_MXRS             (FC_MXRS),
  .FC_SINGLE_MST       (FC_SINGLE_MST),
  .RD_NWR              (0) 

)
u_ax_filter (
    .axid_s_i               (awid_s_i            ),
    .axaddr_s_i             (awaddr_s_i          ),
    .axlen_s_i              (awlen_s_i           ),
    .axsize_s_i             (awsize_s_i          ),
    .axburst_s_i            (awburst_s_i         ),
    .axlock_s_i             (awlock_s_i          ),
    .axcache_s_i            (awcache_s_i         ),
    .axprot_s_i             (awprot_s_i          ),
    .axqos_s_i              (awqos_s_i           ),
    .axregion_s_i           (awregion_s_i        ),
    .axuser_s_i             (awuser_s_i          ),
    .axvalid_s_i            (awvalid_s_i         ),
    .axready_s_o            (awready_s_o         ),
    .axmmusid_s_i           (awmmusid_s_i        ),

    .axid_te_o              (axid_flt_te_wire    ),
    .axaddr_te_o            (axaddr_flt_te_wire  ),
    .axlen_te_o             (axlen_flt_te_wire   ),
    .axsize_te_o            (axsize_flt_te_wire  ),
    .axburst_te_o           (axburst_flt_te_wire ),
    .axlock_te_o            (axlock_flt_te_wire  ),
    .axcache_te_o           (axcache_flt_te_wire ),
    .axprot_te_o            (axprot_flt_te_wire  ),
    .axqos_te_o             (axqos_flt_te_wire   ),
    .axregion_te_o          (axregion_flt_te_wire),
    .axuser_te_o            (axuser_flt_te_wire  ),
    .axvalid_te_o           (axvalid_flt_te_wire ),
    .axready_te_i           (axready_flt_te_wire ),
    .axmmusid_te_o          (axmmusid_flt_te_wire),
    .rgn_number_o           (rgn_number_wire     ),

    .axid_fh_o              (axid_flt_fh_wire    ),
    .axaddr_fh_o            (axaddr_flt_fh_wire  ),
    .axlen_fh_o             (axlen_flt_fh_wire   ),
    .axprot_fh_o            (axprot_flt_fh_wire  ),
    .axvalid_fh_o           (axvalid_flt_fh_wire ),
    .axready_fh_i           (axready_flt_fh_wire ),
    .axmmusid_fh_o          (axmmusid_flt_fh_wire),
    .filter_result_vld_fh_o (filter_result_vld_flt_fh_wire),
    .filter_result_vld_te_o (filter_result_vld_flt_te_wire),
    .filter_result_val_o    (filter_result_val_flt_fh_wire),

    .pe_st_en_i             (rb_pe_st_en_i      ),
    .prot_size_i            (rb_prot_size_i     ),
    .bypass_i               (rb_bypass_i        ),
    .sram_rdy_i             (rb_sram_rdy_i      ),

    .rgn_st_i               (rb_rgn_st_i        ),
    .rgn_size_i             (rb_rgn_size_i      ),
    .rgn_base_addr_i        (rb_rgn_base_addr_i ),
    .rgn_upper_addr_i       (rb_rgn_upper_addr_i),

    .rgn_mid0_i             (rb_rgn_mid0_i      ),
    .rgn_mid1_i             (rb_rgn_mid1_i      ),
    .rgn_mid2_i             (rb_rgn_mid2_i      ),
    .rgn_mid3_i             (rb_rgn_mid3_i      ),

    .rgn_mpl0_i             (rb_rgn_mpl0_i      ),
    .rgn_mpl1_i             (rb_rgn_mpl1_i      ),
    .rgn_mpl2_i             (rb_rgn_mpl2_i      ),
    .rgn_mpl3_i             (rb_rgn_mpl3_i      )

);

firewall_f0_ax_translator #(
  .FC_PE_LVL          (FC_PE_LVL          ),
  .FC_TE_LVL          (FC_TE_LVL          ),
  .FC_RD_FLT          (0                  ), 
  .LOG2_FC_NUM_RGN    (LOG2_FC_NUM_RGN    ),
  .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
  .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AX_WIDTH(FC_AXIUSER_AW_WIDTH),
  .FC_NUM_RGN         (FC_NUM_RGN         ),
  .PROT_SIZE_WIDTH    (PROT_SIZE_WIDTH    ),
  .RGN_SIZE_WIDTH     (RGN_SIZE_WIDTH     ),
  .RGN_TCFG0_WIDTH    (RGN_TCFG0_WIDTH    ),
  .RGN_TCFG1_WIDTH    (RGN_TCFG1_WIDTH    ),
  .RGN_TCFG2_WIDTH    (RGN_TCFG2_WIDTH    )
)
u_ax_translator (
    .axid_flt_i             (axid_flt_te_wire     ),
    .axaddr_flt_i           (axaddr_flt_te_wire   ),
    .axlen_flt_i            (axlen_flt_te_wire    ),
    .axsize_flt_i           (axsize_flt_te_wire   ),
    .axburst_flt_i          (axburst_flt_te_wire  ),
    .axlock_flt_i           (axlock_flt_te_wire   ),
    .axcache_flt_i          (axcache_flt_te_wire  ),
    .axprot_flt_i           (axprot_flt_te_wire   ),
    .axqos_flt_i            (axqos_flt_te_wire    ),
    .axregion_flt_i         (axregion_flt_te_wire ),
    .axuser_flt_i           (axuser_flt_te_wire   ),
    .axvalid_flt_i          (axvalid_flt_te_wire  ),
    .axready_flt_o          (axready_flt_te_wire  ),
    .axmmusid_flt_i         (axmmusid_flt_te_wire ),

    .axid_m_o               (awid_m_o        ),
    .axaddr_m_o             (awaddr_m_o      ),
    .axlen_m_o              (awlen_m_o       ),
    .axsize_m_o             (awsize_m_o      ),
    .axburst_m_o            (awburst_m_o     ),
    .axlock_m_o             (awlock_m_o      ),
    .axcache_m_o            (awcache_m_o     ),
    .axprot_m_o             (awprot_m_o      ),
    .axqos_m_o              (awqos_m_o       ),
    .axregion_m_o           (awregion_m_o    ),
    .axuser_m_o             (awuser_m_o      ),
    .axvalid_m_o            (awvalid_m_o     ),
    .axready_m_i            (awready_m_i     ),
    .axmmusid_m_o           (awmmusid_m_o    ),

    .rgn_number_i           (rgn_number_wire),

    .rb_bypass_status       (rb_bypass_i),
    .rb_rgn_size_i          (rb_rgn_size_i  ),
    .rb_prot_size_i         (rb_prot_size_i    ),
    .rb_cfg_rgn_tcfg0_i     (rb_cfg_rgn_tcfg0_i),
    .rb_cfg_rgn_tcfg1_i     (rb_cfg_rgn_tcfg1_i),
    .rb_cfg_rgn_tcfg2_i     (rb_cfg_rgn_tcfg2_i)
);

firewall_f0_fault_handler_write #(
  .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
  .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AW_WIDTH(FC_AXIUSER_AW_WIDTH),
  .FC_AXIUSER_B_WIDTH (FC_AXIUSER_B_WIDTH)
)
u_ax_fault_handler_write (
    .clk            (clk                ),
    .reset_n        (reset_n            ),

    .axid_flt_i     (axid_flt_fh_wire    ),
    .axaddr_flt_i   (axaddr_flt_fh_wire  ),
    .axprot_flt_i   (axprot_flt_fh_wire  ),
    .axready_flt_o  (axready_flt_fh_wire ),
    .axmmusid_flt_i (axmmusid_flt_fh_wire),
    .filter_result_vld_i (filter_result_vld_flt_fh_wire),
    .filter_result_val_i (filter_result_val_flt_fh_wire),

    .bid_o          (bid_fh_rh_wire   ),
    .bresp_o        (bresp_fh_rh_wire ),
    .buser_o        (buser_fh_rh_wire ),
    .bvalid_o       (bvalid_fh_rh_wire),
    .bready_i       (bready_fh_rh_wire),

    .wlast_i        (wlast_s_i ) ,
    .wvalid_i       (wvalid_s_i) ,
    .wready_i       (wready_s_o) ,

    .tracker_al_empty_wr_i  (tracker_al_empty_wr_i),
    .tracker_empty_wr_i     (tracker_empty_wr_i),
    .tracker_rd_o           (tracker_rd_fh_wire),
    .tracker_rd_bid_o       (tracker_rd_bid_fh_wire),

    .pe_st_flt_cfg_i (rb_pe_st_flt_cfg_i), 
    .fe_tal_o        (rb_fe_tal_o       ),
    .fe_tau_o        (rb_fe_tau_o       ),
    .fe_tp_o         (rb_fe_tp_o        ),
    .fe_mid_o        (rb_fe_mid_o       ),
    .fe_valid_o      (rb_fe_valid_o     ),
    .fe_type_o       (rb_fe_type_o      ),
    .tmp_reg_err     (rb_tmp_reg_err    )

);


firewall_f0_resp_monitor_write #(
  .FC_MST_ID_SINGLE_MST     (FC_MST_ID_SINGLE_MST),
  .FC_SINGLE_MST            (FC_SINGLE_MST),
  .FC_ME_LVL                (FC_ME_LVL),
  .FW_SE_LVL                (FW_SE_LVL  ),
  .FC_INST_SPT              (FC_INST_SPT),
  .FC_PRIV_SPT              (FC_PRIV_SPT),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH),
  .TRACKER_PAYLOAD_WIDTH_AW (TRACKER_PAYLOAD_WIDTH_AW)
)
u_resp_monitor_write (
    .clk            (clk       ),
    .reset_n        (reset_n   ),

    .bid_m_i        (bid_m_i   ),
    .bresp_m_i      (bresp_m_i ),
    .buser_m_i      (buser_m_i ),
    .bvalid_m_i     (bvalid_m_i),
    .bready_m_o     (bready_m_o),

    .bid_rh_o       (bid_rm_rh_wire   ),
    .bresp_rh_o     (bresp_rm_rh_wire ),
    .buser_rh_o     (buser_rm_rh_wire ),
    .bvalid_rh_o    (bvalid_rm_rh_wire),
    .bready_rh_i    (bready_rm_rh_wire),

    .tracker_id_wr_ch_o   (tracker_id_wr_ch_rm_wire),
    .tracker_read_wr_ch_o (tracker_read_wr_ch_rm_wire),
    .tracker_dout_wr_ch_i (tracker_dout_wr_ch_i),
    .tracker_dout_wr_ch_vld_i (tracker_dout_wr_ch_vld_i),

    .rb_st_me_en_i          (rb_st_me_en_i),

    .wr_edr_wen_o           (wr_edr_wen_o),
    .wr_edr_addr_lwr_o      (wr_edr_addr_lwr_o),
    .wr_edr_addr_uppr_o     (wr_edr_addr_uppr_o),
    .wr_edr_prop_o          (wr_edr_prop_o)

);

firewall_f0_resp_handler_write #(
  .FC_ME_LVL                (FC_ME_LVL),
  .FC_PE_LVL                (FC_PE_LVL),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH),
  .FC_ID                    (FC_ID)
)
u_resp_handler_write (

    .bid_s_o        (bid_s_o   ),
    .bresp_s_o      (bresp_s_o ),
    .buser_s_o      (buser_s_o ),
    .bvalid_s_o     (bvalid_s_o),
    .bready_s_i     (bready_s_i),

    .bid_rm_i       (bid_rm_rh_wire   ),
    .bresp_rm_i     (bresp_rm_rh_wire ),
    .buser_rm_i     (buser_rm_rh_wire ),
    .bvalid_rm_i    (bvalid_rm_rh_wire),
    .bready_rm_o    (bready_rm_rh_wire),

    .bid_fh_i       (bid_fh_rh_wire   ),
    .bresp_fh_i     (bresp_fh_rh_wire ),
    .buser_fh_i     (buser_fh_rh_wire ),
    .bvalid_fh_i    (bvalid_fh_rh_wire),
    .bready_fh_o    (bready_fh_rh_wire),

    .bid_pchk_i      ( bid_pchk_i   ),
    .bresp_pchk_i    ( bresp_pchk_i ),
    .buser_pchk_i    ( buser_pchk_i ),
    .bvalid_pchk_i   ( bvalid_pchk_i),
    .bready_pchk_o   ( bready_pchk_o),

    .bid_cfg_i       ( bid_cfg_i    ),
    .bresp_cfg_i     ( bresp_cfg_i  ),
    .buser_cfg_i     ( buser_cfg_i  ),
    .bvalid_cfg_i    ( bvalid_cfg_i ),
    .bready_cfg_o    ( bready_cfg_o ),

    .fw_st_i         (rb_fw_st_i), 
    .pe_st_i         (rb_pe_st_err_i),
    .pe_st_en_i      (rb_pe_st_en_i)
);

firewall_f0_wr_data_handler #(
  .FC_PE_LVL (FC_PE_LVL),
  .FC_AXIDATA_WIDTH  (FC_AXIDATA_WIDTH),
  .FC_AXIUSER_W_WIDTH (FC_AXIUSER_W_WIDTH)
)
u_wr_data_handler(
    .clk           (clk          ),
    .reset_n       (reset_n      ),

    .wdata_s_i     (wdata_s_i    ),
    .wstrb_s_i     (wstrb_s_i    ),
    .wlast_s_i     (wlast_s_i    ),
    .wuser_s_i     (wuser_s_i    ),
    .wvalid_s_i    (wvalid_s_i   ),
    .wready_s_o    (wready_s_o   ),
    .awvalid_i     (awvalid_s_i  ),
    .awready_i     (awready_s_o  ),

    .wdata_m_o     (wdata_m_o    ),
    .wstrb_m_o     (wstrb_m_o    ),
    .wlast_m_o     (wlast_m_o    ),
    .wuser_m_o     (wuser_m_o    ),
    .wvalid_m_o    (wvalid_m_o   ),
    .wready_m_i    (wready_m_i   ),

    .pe_rse_st_vld (filter_result_vld_flt_fh_wire | filter_result_vld_flt_te_wire),
    .pe_rse_st_val (filter_result_val_flt_fh_wire)

);

endmodule
