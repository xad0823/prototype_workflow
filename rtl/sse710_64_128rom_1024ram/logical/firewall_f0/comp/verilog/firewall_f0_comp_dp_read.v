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

module firewall_f0_comp_dp_read #(
  parameter FC_MST_ID_SINGLE_MST = 0,
  parameter FC_TE_LVL = 0,
  parameter FC_RSE_LVL = 0,
  parameter FC_PE_LVL = 0,
  parameter FC_ME_LVL = 0,
  parameter FW_SE_LVL = 1,
  parameter FC_INST_SPT = 0,
  parameter FC_ADDR_WIDTH    = 64,
  parameter FC_AXIDATA_WIDTH = 64,
  parameter FC_AXIID_WIDTH   = 9 ,
  parameter FC_MST_ID_WIDTH  = 8,
  parameter FC_AXIUSER_AR_WIDTH = 2,
  parameter FC_AXIUSER_R_WIDTH  = 2,
  parameter TRACKER_PAYLOAD_WIDTH_AR = 1,
  parameter FC_NUM_RGN          = 4,
  parameter LOG2_FC_NUM_RGN     = 2,
  parameter FC_NUM_MPE          = 4,
  parameter FC_MNRS             = 7'h0, 
  parameter FC_MXRS             = 7'h8,  
  parameter FC_SINGLE_MST       = 1,
  parameter FC_NUM_MST_ID       = 4,
  parameter FC_ID               = 1,
  parameter [FC_MST_ID_WIDTH*FC_NUM_MST_ID-1:0]  FC_MST_ID_VAL          = {FC_NUM_MST_ID*FC_MST_ID_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH*FC_NUM_MST_ID-1:0] FC_ERR_RESP_PER_MST_ID = {FC_NUM_MST_ID*FC_AXIDATA_WIDTH{1'b0}},
  parameter [FC_AXIDATA_WIDTH-1:0]               FC_ERR_RESP_DEF        = {FC_AXIDATA_WIDTH{1'b0}},
  parameter FC_PRIV_SPT         = 1,
  parameter FC_SEC_SPT          = 1,
  parameter FC_NUM_READ_OS      = 4,
  parameter FC_AXI_READ_RESP_INTRLV  = 1,
  `include "firewall_f0_reg_width_params.vh"
) (
    input  wire                       clk,
    input  wire                       reset_n,

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
    input  wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_s_i  ,
    input  wire                                   arvalid_s_i ,
    output wire                                   arready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_s_i,

    output wire [FC_AXIID_WIDTH-1:0]              rid_s_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]            rdata_s_o   ,
    output wire [1:0]                             rresp_s_o   ,
    output wire                                   rlast_s_o   ,
    output wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_s_o   ,
    output wire                                   rvalid_s_o  ,
    input  wire                                   rready_s_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              arid_m_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               araddr_m_o  ,
    output wire [7:0]                             arlen_m_o   ,
    output wire [2:0]                             arsize_m_o  ,
    output wire [1:0]                             arburst_m_o ,
    output wire                                   arlock_m_o  ,
    output wire [3:0]                             arcache_m_o ,
    output wire [2:0]                             arprot_m_o  ,
    output wire [3:0]                             arqos_m_o   ,
    output wire [3:0]                             arregion_m_o,
    output wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_m_o  ,
    output wire                                   arvalid_m_o ,
    input  wire                                   arready_m_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             armmusid_m_o,

    input  wire [FC_AXIID_WIDTH-1:0]              rid_m_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]            rdata_m_i   ,
    input  wire [1:0]                             rresp_m_i   ,
    input  wire                                   rlast_m_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_m_i   ,
    input  wire                                   rvalid_m_i  ,
    output wire                                   rready_m_o  ,

    input  wire                                   tracker_al_empty_rd_i,
    input  wire                                   tracker_empty_rd_i,

    output wire [FC_AXIID_WIDTH-1:0]              tracker_id_rd_ch_o,
    output wire                                   tracker_read_rd_ch_o,
    input  wire [TRACKER_PAYLOAD_WIDTH_AR-1:0]    tracker_dout_rd_ch_i,
    input wire                                    tracker_dout_rd_ch_vld_i,

    input  wire                                    rb_me_st_rdum_i ,
    input  wire [1:0]                              rb_pe_st_err_raz_i , 
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
    input  wire [1:0]                              rb_fw_st_i,
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

    output wire                                    rd_edr_wen_o,       
    output wire [31:0]                             rd_edr_addr_lwr_o,  
    output wire [31:0]                             rd_edr_addr_uppr_o, 
    output wire [FC_MST_ID_WIDTH+4-1:0]            rd_edr_prop_o,      

    input  wire [FC_AXIID_WIDTH-1:0]               rid_pchk_i,
    input  wire [FC_AXIDATA_WIDTH-1:0]             rdata_pchk_i,
    input  wire [1:0]                              rresp_pchk_i,
    input  wire                                    rlast_pchk_i,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]           ruser_pchk_i,
    input  wire                                    rvalid_pchk_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              mst_id_pchk_i,
    output wire                                    rready_pchk_o,

    input  wire [FC_AXIID_WIDTH-1:0]               rid_cfg_i,
    input  wire [FC_AXIDATA_WIDTH-1:0]             rdata_cfg_i,
    input  wire [1:0]                              rresp_cfg_i,
    input  wire                                    rlast_cfg_i,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]           ruser_cfg_i,
    input  wire                                    rvalid_cfg_i,
    input  wire [FC_MST_ID_WIDTH-1:0]              mst_id_cfg_i,
    output wire                                    rready_cfg_o
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
wire [FC_AXIUSER_AR_WIDTH-1:0]      axuser_flt_te_wire;
wire                                axvalid_flt_te_wire;
wire                                axready_flt_te_wire;
wire [FC_MST_ID_WIDTH-1:0]          axmmusid_flt_te_wire;

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
wire [FC_AXIUSER_AR_WIDTH-1:0]      axuser_flt_fh_wire  ;
wire                                axvalid_flt_fh_wire ;
wire                                axready_flt_fh_wire ;
wire [FC_MST_ID_WIDTH-1:0]          axmmusid_flt_fh_wire;

wire [FC_AXIID_WIDTH-1:0]           rid_fh_rh_wire   ;
wire [FC_AXIDATA_WIDTH-1:0]         rdata_fh_rh_wire ;
wire [1:0]                          rresp_fh_rh_wire ;
wire                                rlast_fh_rh_wire ;
wire [FC_AXIUSER_R_WIDTH-1:0]       ruser_fh_rh_wire ;
wire                                rvalid_fh_rh_wire;
wire                                rready_fh_rh_wire;

wire [FC_AXIID_WIDTH-1:0]          rid_rm_rh_wire    ;
wire [FC_AXIDATA_WIDTH-1:0]        rdata_rm_rh_wire  ;
wire [1:0]                         rresp_rm_rh_wire  ;
wire                               rlast_rm_rh_wire  ;
wire [FC_AXIUSER_R_WIDTH-1:0]      ruser_rm_rh_wire  ;
wire                               rvalid_rm_rh_wire ;
wire                               rready_rm_rh_wire ;
wire [FC_MST_ID_WIDTH-1:0]         mst_id_rm_wire    ;

wire                               filter_result_vld_flt_fh_wire;
wire [1:0]                         filter_result_val_flt_fh_wire;
wire [FC_MST_ID_WIDTH-1:0]         mst_id_fh_rh_wire;
wire [LOG2_FC_NUM_RGN-1:0]         rgn_number_wire;

wire                               tracker_rd_fh_wire;
wire [FC_AXIID_WIDTH-1:0]          tracker_rd_rid_fh_wire;
wire [FC_AXIID_WIDTH-1:0]          tracker_id_rd_ch_rm_wire;
wire                               tracker_read_rd_ch_rm_wire;

assign tracker_read_rd_ch_o = tracker_rd_fh_wire | tracker_read_rd_ch_rm_wire;
assign tracker_id_rd_ch_o = tracker_rd_fh_wire ? tracker_rd_rid_fh_wire : tracker_id_rd_ch_rm_wire;

firewall_f0_ax_filter #(
  .FC_PE_LVL           (FC_PE_LVL          ),
  .FC_ADDR_WIDTH       (FC_ADDR_WIDTH      ),
  .FC_AXIID_WIDTH      (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH     (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AX_WIDTH (FC_AXIUSER_AR_WIDTH),
  .FC_NUM_RGN          (FC_NUM_RGN),
  .LOG2_FC_NUM_RGN     (LOG2_FC_NUM_RGN),
  .FC_NUM_MPE          (FC_NUM_MPE),
  .FC_MNRS             (FC_MNRS),
  .FC_MXRS             (FC_MXRS),
  .FC_SINGLE_MST       (FC_SINGLE_MST),
  .RD_NWR              (1)
)
u_ax_filter (
    .axid_s_i               (arid_s_i            ),
    .axaddr_s_i             (araddr_s_i          ),
    .axlen_s_i              (arlen_s_i           ),
    .axsize_s_i             (arsize_s_i          ),
    .axburst_s_i            (arburst_s_i         ),
    .axlock_s_i             (arlock_s_i          ),
    .axcache_s_i            (arcache_s_i         ),
    .axprot_s_i             (arprot_s_i          ),
    .axqos_s_i              (arqos_s_i           ),
    .axregion_s_i           (arregion_s_i        ),
    .axuser_s_i             (aruser_s_i          ),
    .axvalid_s_i            (arvalid_s_i         ),
    .axready_s_o            (arready_s_o         ),
    .axmmusid_s_i           (armmusid_s_i        ),

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
    .rgn_number_o           (rgn_number_wire),

    .axid_fh_o              (axid_flt_fh_wire    ),
    .axaddr_fh_o            (axaddr_flt_fh_wire  ),
    .axlen_fh_o             (axlen_flt_fh_wire   ),
    .axprot_fh_o            (axprot_flt_fh_wire  ),
    .axvalid_fh_o           (axvalid_flt_fh_wire ),
    .axready_fh_i           (axready_flt_fh_wire ),
    .axmmusid_fh_o          (axmmusid_flt_fh_wire),
    .filter_result_vld_fh_o    (filter_result_vld_flt_fh_wire),
    .filter_result_vld_te_o    ( ), 
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
  .FC_RD_FLT          (1                  ), 
  .LOG2_FC_NUM_RGN    (LOG2_FC_NUM_RGN    ),
  .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
  .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AX_WIDTH(FC_AXIUSER_AR_WIDTH),
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

    .axid_m_o               (arid_m_o        ),
    .axaddr_m_o             (araddr_m_o      ),
    .axlen_m_o              (arlen_m_o       ),
    .axsize_m_o             (arsize_m_o      ),
    .axburst_m_o            (arburst_m_o     ),
    .axlock_m_o             (arlock_m_o      ),
    .axcache_m_o            (arcache_m_o     ),
    .axprot_m_o             (arprot_m_o      ),
    .axqos_m_o              (arqos_m_o       ),
    .axregion_m_o           (arregion_m_o    ),
    .axuser_m_o             (aruser_m_o      ),
    .axvalid_m_o            (arvalid_m_o     ),
    .axready_m_i            (arready_m_i     ),
    .axmmusid_m_o           (armmusid_m_o    ),

    .rgn_number_i           (rgn_number_wire),

    .rb_bypass_status       (rb_bypass_i),
    .rb_rgn_size_i          (rb_rgn_size_i  ),
    .rb_prot_size_i         (rb_prot_size_i    ),
    .rb_cfg_rgn_tcfg0_i     (rb_cfg_rgn_tcfg0_i),
    .rb_cfg_rgn_tcfg1_i     (rb_cfg_rgn_tcfg1_i),
    .rb_cfg_rgn_tcfg2_i     (rb_cfg_rgn_tcfg2_i)
);


firewall_f0_fault_handler_read #(
  .FC_ADDR_WIDTH      (FC_ADDR_WIDTH      ),
  .FC_AXIDATA_WIDTH   (FC_AXIDATA_WIDTH),
  .FC_AXIID_WIDTH     (FC_AXIID_WIDTH     ),
  .FC_MST_ID_WIDTH    (FC_MST_ID_WIDTH    ),
  .FC_AXIUSER_AR_WIDTH(FC_AXIUSER_AR_WIDTH),
  .FC_AXIUSER_R_WIDTH (FC_AXIUSER_R_WIDTH)

)
u_ax_fault_handler_read (
    .clk                    (clk                ),
    .reset_n                (reset_n            ),

    .axid_flt_i             (axid_flt_fh_wire    ),
    .axaddr_flt_i           (axaddr_flt_fh_wire  ),
    .axlen_flt_i            (axlen_flt_fh_wire   ),
    .axprot_flt_i           (axprot_flt_fh_wire  ),
    .axready_flt_o          (axready_flt_fh_wire ),
    .axmmusid_flt_i         (axmmusid_flt_fh_wire),
    .filter_result_vld_i    (filter_result_vld_flt_fh_wire),
    .filter_result_val_i    (filter_result_val_flt_fh_wire),

    .rid_o                  (rid_fh_rh_wire   ),
    .rdata_o                (rdata_fh_rh_wire ),
    .rresp_o                (rresp_fh_rh_wire ),
    .rlast_o                (rlast_fh_rh_wire ),
    .ruser_o                (ruser_fh_rh_wire ),
    .rvalid_o               (rvalid_fh_rh_wire),
    .rready_i               (rready_fh_rh_wire),
    .rmst_id_o              (mst_id_fh_rh_wire),

    .tracker_al_empty_rd_i  (tracker_al_empty_rd_i),
    .tracker_empty_rd_i     (tracker_empty_rd_i),
    .tracker_rd_o           (tracker_rd_fh_wire),
    .tracker_rd_rid_o       (tracker_rd_rid_fh_wire),

    .pe_st_flt_cfg_i        (rb_pe_st_flt_cfg_i), 
    .fe_tal_o               (rb_fe_tal_o       ),
    .fe_tau_o               (rb_fe_tau_o       ),
    .fe_tp_o                (rb_fe_tp_o        ),
    .fe_mid_o               (rb_fe_mid_o       ),
    .fe_valid_o             (rb_fe_valid_o     ),
    .fe_type_o              (rb_fe_type_o      ),
    .tmp_reg_err            (rb_tmp_reg_err    )

);


firewall_f0_resp_monitor_read #(
  .FC_MST_ID_SINGLE_MST     (FC_MST_ID_SINGLE_MST),
  .FC_SINGLE_MST            (FC_SINGLE_MST),
  .FC_ME_LVL                (FC_ME_LVL),
  .FW_SE_LVL                (FW_SE_LVL),
  .FC_PRIV_SPT              (FC_PRIV_SPT),
  .FC_INST_SPT              (FC_INST_SPT),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH),
  .TRACKER_PAYLOAD_WIDTH_AR (TRACKER_PAYLOAD_WIDTH_AR),
  .NUM_OUTSTAND             (FC_NUM_READ_OS),
  .FC_AXI_READ_RESP_INTRLV  (FC_AXI_READ_RESP_INTRLV),
  .FC_NUM_MST_ID            (FC_NUM_MST_ID),
  .FC_MST_ID_VAL            (FC_MST_ID_VAL),
  .FC_ERR_RESP_PER_MST_ID   (FC_ERR_RESP_PER_MST_ID),
  .FC_ERR_RESP_DEF          (FC_ERR_RESP_DEF)

)
u_resp_monitor_read (
    .clk            (clk       ),
    .reset_n        (reset_n   ),
    .rid_m_i        (rid_m_i   ),
    .rdata_m_i      (rdata_m_i ),
    .rresp_m_i      (rresp_m_i ),
    .rlast_m_i      (rlast_m_i ),
    .ruser_m_i      (ruser_m_i ),
    .rvalid_m_i     (rvalid_m_i),
    .rready_m_o     (rready_m_o),

    .rvalid_fh_i    (rvalid_fh_rh_wire),

    .rid_rh_o       (rid_rm_rh_wire   ),
    .rdata_rh_o     (rdata_rm_rh_wire ),
    .rresp_rh_o     (rresp_rm_rh_wire ),
    .rlast_rh_o     (rlast_rm_rh_wire ),
    .ruser_rh_o     (ruser_rm_rh_wire ),
    .rvalid_rh_o    (rvalid_rm_rh_wire),
    .rready_rh_i    (rready_rm_rh_wire),
    .mst_id_rm_o    (mst_id_rm_wire   ),

    .tracker_id_rd_ch_o   (tracker_id_rd_ch_rm_wire),
    .tracker_read_rd_ch_o (tracker_read_rd_ch_rm_wire),
    .tracker_dout_rd_ch_i (tracker_dout_rd_ch_i),
    .tracker_dout_rd_ch_vld_i (tracker_dout_rd_ch_vld_i),

    .rb_st_me_en_i          (rb_st_me_en_i),
    .me_st_rdum_i           (rb_me_st_rdum_i),

    .rd_edr_wen_o           (rd_edr_wen_o),
    .rd_edr_addr_lwr_o      (rd_edr_addr_lwr_o),
    .rd_edr_addr_uppr_o     (rd_edr_addr_uppr_o),
    .rd_edr_prop_o          (rd_edr_prop_o)
);

firewall_f0_resp_handler_read #(
  .FC_ME_LVL                (FC_ME_LVL             ),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH      ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH        ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH    ),
  .FC_PE_LVL                (FC_PE_LVL             ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH       ),
  .FC_NUM_MST_ID            (FC_NUM_MST_ID         ),
  .FC_ID                    (FC_ID                 ),
  .FC_MST_ID_VAL            (FC_MST_ID_VAL         ),
  .FC_ERR_RESP_PER_MST_ID   (FC_ERR_RESP_PER_MST_ID),
  .FC_ERR_RESP_DEF          (FC_ERR_RESP_DEF       ),
  .FC_SINGLE_MST            (FC_SINGLE_MST         )
)
u_resp_handler_read (
    .rid_s_o      (rid_s_o   ),
    .rdata_s_o    (rdata_s_o ),
    .rresp_s_o    (rresp_s_o ),
    .rlast_s_o    (rlast_s_o ),
    .ruser_s_o    (ruser_s_o ),
    .rvalid_s_o   (rvalid_s_o),
    .rready_s_i   (rready_s_i),

    .rid_rm_i       (rid_rm_rh_wire   ),
    .rdata_rm_i     (rdata_rm_rh_wire ),
    .rresp_rm_i     (rresp_rm_rh_wire ),
    .rlast_rm_i     (rlast_rm_rh_wire ),
    .ruser_rm_i     (ruser_rm_rh_wire ),
    .rvalid_rm_i    (rvalid_rm_rh_wire),
    .rready_rm_o    (rready_rm_rh_wire),
    .mst_id_rm_i    (mst_id_rm_wire   ),

    .rid_fh_i       (rid_fh_rh_wire   ),
    .rdata_fh_i     (rdata_fh_rh_wire ),
    .rresp_fh_i     (rresp_fh_rh_wire ),
    .rlast_fh_i     (rlast_fh_rh_wire ),
    .ruser_fh_i     (ruser_fh_rh_wire ),
    .rvalid_fh_i    (rvalid_fh_rh_wire),
    .rready_fh_o    (rready_fh_rh_wire),
    .mst_id_fh_i    (mst_id_fh_rh_wire),

    .rid_pchk_i       (rid_pchk_i   ),
    .rdata_pchk_i     (rdata_pchk_i ),
    .rresp_pchk_i     (rresp_pchk_i ),
    .rlast_pchk_i     (rlast_pchk_i ),
    .ruser_pchk_i     (ruser_pchk_i ),
    .rvalid_pchk_i    (rvalid_pchk_i),
    .rready_pchk_o    (rready_pchk_o),
    .mst_id_pchk_i    (mst_id_pchk_i),

    .rid_cfg_i        (rid_cfg_i    ),
    .rdata_cfg_i      (rdata_cfg_i  ),
    .rresp_cfg_i      (rresp_cfg_i  ),
    .rlast_cfg_i      (rlast_cfg_i  ),
    .ruser_cfg_i      (ruser_cfg_i  ),
    .rvalid_cfg_i     (rvalid_cfg_i ),
    .rready_cfg_o     (rready_cfg_o ),
    .mst_id_cfg_i     (mst_id_cfg_i ),

    .me_st_rdum_i    (rb_me_st_rdum_i),
    .me_st_en_i      (rb_st_me_en_i),
    .pe_st_en_i      (rb_pe_st_en_i),
    .fw_st_i         (rb_fw_st_i),  
    .pe_st_i         (rb_pe_st_err_raz_i)
);

endmodule
