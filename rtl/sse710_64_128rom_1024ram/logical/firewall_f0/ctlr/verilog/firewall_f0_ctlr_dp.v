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

module firewall_f0_ctlr_dp #(
  parameter REG_ADDR_WIDTH      = 10,
  parameter REG_ENUM_WIDTH      = 126,
  parameter LOG2_FC_NUM_RGN     = 2,
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
  parameter FW_ID_WIDTH         = 5,
  `include "firewall_f0_ctlr_params.vh"
  ,
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
    input  wire                                   arvalid_s_i ,
    output wire                                   arready_s_o ,
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
    output wire                                   awready_s_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_s_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_s_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_s_i   ,
    input  wire                                   wlast_s_i   ,
    input  wire                                   wvalid_s_i  ,
    output wire                                   wready_s_o  ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_s_o     ,
    output wire [1:0]                             bresp_s_o   ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]          buser_s_o   ,
    output wire                                   bvalid_s_o  ,
    input  wire                                   bready_s_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              rid_s_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]            rdata_s_o   ,
    output wire [1:0]                             rresp_s_o   ,
    output wire                                   rlast_s_o   ,
    output wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_s_o   ,
    output wire                                   rvalid_s_o  ,
    input  wire                                   rready_s_i  ,

    input  wire                                   awakeup_s_i ,

    output wire [FC_AXIID_WIDTH-1:0]              arid_m_o    ,
    output wire [REG_ADDR_WIDTH-1:0]              araddr_m_o  ,
    output wire                                   arvalid_m_o ,
    output wire[FC_MST_ID_WIDTH-1:0]              armmusid_m_o,
    input  wire                                   arready_m_i ,

    output wire [FC_AXIID_WIDTH-1:0]              awid_m_o    ,
    output wire [REG_ADDR_WIDTH-1:0]              awaddr_m_o  ,
    output wire                                   awvalid_m_o ,
    output wire[FC_MST_ID_WIDTH-1:0]              awmmusid_m_o,
    input  wire                                   awready_m_i ,

    output wire [FC_AXIDATA_WIDTH-1:0]            wdata_m_o   ,
    output wire                                   wvalid_m_o  ,
    output wire                                   wlast_m_o  ,
    input  wire                                   wready_m_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]              bid_m_i     ,
    input  wire [1:0]                             bresp_m_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]          buser_m_i   ,
    input  wire                                   bvalid_m_i  ,
    output wire                                   bready_m_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]              rid_m_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]            rdata_m_i   ,
    input  wire [1:0]                             rresp_m_i   ,
    input  wire                                   rlast_m_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_m_i   ,
    input  wire                                   rvalid_m_i  ,
    output wire                                   rready_m_o  ,
    input  wire [FC_MST_ID_WIDTH-1:0]             mst_id_m_i ,

    output wire                                   awakeup_m_o ,

    output  wire [FW_ID_WIDTH-1:0]                cfg_w_fw_id_o,
    output  wire [FW_ID_WIDTH-1:0]                cfg_r_fw_id_o,

    input  wire                                    rb_me_st_rdum_i ,
    input  wire                                    rb_pe_st_err_i , 
    input  wire [1:0]                              rb_pe_st_err_raz_i , 
    input  wire [1:0]                              rb_pe_st_flt_cfg_i,  
    input  wire                                    rb_pe_st_en_i,

    output wire [FE_TAL_WIDTH-1:0]                 rb_fe_rd_tal_o,
    output wire [FE_TAU_WIDTH-1:0]                 rb_fe_rd_tau_o,
    output wire [FE_TP_WIDTH-1:0]                  rb_fe_rd_tp_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rb_fe_rd_mid_o,
    output wire                                    rb_fe_rd_valid_o,
    output wire                                    rb_fe_rd_type_o,  
    output wire                                    rb_tmp_reg_err_rd,

    output wire [FE_TAL_WIDTH-1:0]                 rb_fe_wr_tal_o,
    output wire [FE_TAU_WIDTH-1:0]                 rb_fe_wr_tau_o,
    output wire [FE_TP_WIDTH-1:0]                  rb_fe_wr_tp_o,
    output wire [FC_MST_ID_WIDTH-1:0]              rb_fe_wr_mid_o,
    output wire                                    rb_fe_wr_valid_o,
    output wire                                    rb_fe_wr_type_o,  
    output wire                                    rb_tmp_reg_err_wr,

    input  wire [(FW_NUM_FC+1)*8-1:0]              rb_prot_size_i,
    input  wire                                    rb_bypass_i,
    input  wire [1:0]                              rb_fw_st_i,
    input  wire [FW_NUM_FC-1:0]                    rb_comp_pwr_st_i,

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

    input  wire [PID0_WIDTH-1:0]                   rb_pid0_i,
    input  wire [PID1_WIDTH-1:0]                   rb_pid1_i,
    input  wire [PID2_WIDTH-1:0]                   rb_pid2_i,
    input  wire [PID3_WIDTH-1:0]                   rb_pid3_i,
    input  wire [PID4_WIDTH-1:0]                   rb_pid4_i,

    input  wire [CID0_WIDTH-1:0]                   rb_cid0_i,
    input  wire [CID1_WIDTH-1:0]                   rb_cid1_i,
    input  wire [CID2_WIDTH-1:0]                   rb_cid2_i,
    input  wire [CID3_WIDTH-1:0]                   rb_cid3_i,

    input  wire [AIDR_WIDTH-1:0]                   rb_aidr_i  ,
    input  wire [IIDR_WIDTH-1:0]                   rb_iidr_i  ,
    input  wire [1:0]                              rb_fw_sr_ctrl_i,
    input  wire                                    rb_sr_rdy_i,

    output wire                                    rb_write_tamp_o,
    output wire                                    rb_read_tamp_o,

    output wire [REG_ENUM_WIDTH-1:0]              reg_addr_dec_rd_o,
    output wire [REG_ENUM_WIDTH-1:0]              reg_addr_dec_wr_o

);

 localparam TRACKER_PAYLOAD_WIDTH_AR = 1;
 localparam TRACKER_PAYLOAD_WIDTH_AW = 1;

 wire [FC_AXIID_WIDTH-1:0]              dp_pchk_arid_wire;
 wire [FC_ADDR_WIDTH-1:0]               dp_pchk_araddr_wire;
 wire [7:0]                             dp_pchk_arlen_wire;
 wire [2:0]                             dp_pchk_arsize_wire;
 wire [1:0]                             dp_pchk_arburst_wire;
 wire                                   dp_pchk_arlock_wire;
 wire [3:0]                             dp_pchk_arcache_wire;
 wire [2:0]                             dp_pchk_arprot_wire;
 wire [3:0]                             dp_pchk_arqos_wire;
 wire [3:0]                             dp_pchk_arregion_wire;
 wire                                   dp_pchk_arvalid_wire;
 wire                                   dp_pchk_arready_wire;
 wire [FC_MST_ID_WIDTH-1:0]             dp_pchk_armmusid_wire;

 wire [FC_AXIID_WIDTH-1:0]              dp_pchk_awid_wire;
 wire [FC_ADDR_WIDTH-1:0]               dp_pchk_awaddr_wire;
 wire [7:0]                             dp_pchk_awlen_wire;
 wire [2:0]                             dp_pchk_awsize_wire;
 wire [1:0]                             dp_pchk_awburst_wire;
 wire                                   dp_pchk_awlock_wire;
 wire [3:0]                             dp_pchk_awcache_wire;
 wire [2:0]                             dp_pchk_awprot_wire;
 wire [3:0]                             dp_pchk_awqos_wire;
 wire [3:0]                             dp_pchk_awregion_wire;
 wire                                   dp_pchk_awvalid_wire;
 wire                                   dp_pchk_awready_wire;
 wire [FC_MST_ID_WIDTH-1:0]             dp_pchk_awmmusid_wire;

 wire [FC_AXIDATA_WIDTH-1:0]            dp_pchk_wdata_wire;
 wire [FC_AXIDATA_WIDTH/8-1:0]          dp_pchk_wstrb_wire;
 wire                                   dp_pchk_wlast_wire;
 wire                                   dp_pchk_wvalid_wire;
 wire                                   dp_pchk_wready_wire;

 wire [FC_AXIID_WIDTH-1:0]              dp_pchk_bid_wire;
 wire [1:0]                             dp_pchk_bresp_wire;
 wire [FC_AXIUSER_B_WIDTH-1:0]          dp_pchk_buser_wire;
 wire                                   dp_pchk_bvalid_wire;
 wire                                   dp_pchk_bready_wire;

 wire [FC_AXIID_WIDTH-1:0]              dp_pchk_rid_wire;
 wire [FC_AXIDATA_WIDTH-1:0]            dp_pchk_rdata_wire;
 wire [1:0]                             dp_pchk_rresp_wire;
 wire                                   dp_pchk_rlast_wire;
 wire [FC_AXIUSER_R_WIDTH-1:0]          dp_pchk_ruser_wire;
 wire                                   dp_pchk_rvalid_wire;
 wire                                   dp_pchk_rready_wire;

 wire                                   dp_pchk_awakeup_wire;

 wire [FC_AXIID_WIDTH-1:0]               rid_pchk_wire     ;
 wire [FC_AXIDATA_WIDTH-1:0]             rdata_pchk_wire   ;
 wire [1:0]                              rresp_pchk_wire   ;
 wire                                    rlast_pchk_wire   ;
 wire [FC_AXIUSER_R_WIDTH-1:0]           ruser_pchk_wire   ;
 wire                                    rvalid_pchk_wire  ;
 wire [FC_MST_ID_WIDTH-1:0]              mst_id_pchk_wire  ;
 wire                                    rready_pchk_wire  ;


assign awakeup_m_o = awakeup_s_i;

firewall_f0_comp_dp #(
  .FC_ME_LVL                (FC_ME_LVL               ),
  .FC_PE_LVL                (FC_PE_LVL               ),
  .FC_TE_LVL                (FC_TE_LVL               ),
  .FC_ADDR_WIDTH            (FC_ADDR_WIDTH           ),
  .FC_AXIDATA_WIDTH         (FC_AXIDATA_WIDTH        ),
  .FC_AXIID_WIDTH           (FC_AXIID_WIDTH          ),
  .FC_MST_ID_WIDTH          (FC_MST_ID_WIDTH         ),
  .FC_AXIUSER_AR_WIDTH      (1'b1                    ),
  .FC_AXIUSER_AW_WIDTH      (1'b1                    ),
  .FC_AXIUSER_W_WIDTH       (1'b1                    ),
  .FC_AXIUSER_R_WIDTH       (FC_AXIUSER_R_WIDTH      ),
  .FC_AXIUSER_B_WIDTH       (FC_AXIUSER_B_WIDTH      ),
  .TRACKER_PAYLOAD_WIDTH_AR (TRACKER_PAYLOAD_WIDTH_AR),
  .TRACKER_PAYLOAD_WIDTH_AW (TRACKER_PAYLOAD_WIDTH_AW),
  .FC_NUM_RGN               (FC_NUM_RGN            ),
  .LOG2_FC_NUM_RGN          (LOG2_FC_NUM_RGN       ),
  .FC_NUM_MPE               (FC_NUM_MPE            ),
  .FC_MNRS                  (FC_MNRS               ),
  .FC_MXRS                  (FC_MXRS               ),
  .FC_SINGLE_MST            (FC_SINGLE_MST         ),
  .FC_NUM_MST_ID            (FC_NUM_MST_ID         ),
  .FC_ID                    (FC_ID                 ),
  .FC_MST_ID_VAL            (FC_MST_ID_VAL         ),
  .FC_ERR_RESP_PER_MST_ID   (FC_ERR_RESP_PER_MST_ID),
  .FC_ERR_RESP_DEF          (FC_ERR_RESP_DEF       )

)
u_fctlr_dp(
    .clk          (clk         ),
    .reset_n      (reset_n     ),

    .arid_s_i     (arid_s_i    ),
    .araddr_s_i   (araddr_s_i  ),
    .arlen_s_i    (arlen_s_i   ),
    .arsize_s_i   (arsize_s_i  ),
    .arburst_s_i  (arburst_s_i ),
    .arlock_s_i   (arlock_s_i  ),
    .arcache_s_i  (arcache_s_i ),
    .arprot_s_i   (arprot_s_i  ),
    .arqos_s_i    (arqos_s_i   ),
    .arregion_s_i (arregion_s_i),
    .aruser_s_i   (1'b0  ),
    .arvalid_s_i  (arvalid_s_i ),
    .arready_s_o  (arready_s_o ),
    .armmusid_s_i (armmusid_s_i),

    .awid_s_i     (awid_s_i    ),
    .awaddr_s_i   (awaddr_s_i  ),
    .awlen_s_i    (awlen_s_i   ),
    .awsize_s_i   (awsize_s_i  ),
    .awburst_s_i  (awburst_s_i ),
    .awlock_s_i   (awlock_s_i  ),
    .awcache_s_i  (awcache_s_i ),
    .awprot_s_i   (awprot_s_i  ),
    .awqos_s_i    (awqos_s_i   ),
    .awregion_s_i (awregion_s_i),
    .awuser_s_i   (1'b0  ),
    .awvalid_s_i  (awvalid_s_i ),
    .awready_s_o  (awready_s_o ),
    .awmmusid_s_i (awmmusid_s_i),

    .wdata_s_i    (wdata_s_i   ),
    .wstrb_s_i    (wstrb_s_i   ),
    .wlast_s_i    (wlast_s_i   ),
    .wuser_s_i    (1'b0  ),
    .wvalid_s_i   (wvalid_s_i  ),
    .wready_s_o   (wready_s_o  ),

    .bid_s_o      (bid_s_o     ),
    .bresp_s_o    (bresp_s_o   ),
    .buser_s_o    (buser_s_o   ),
    .bvalid_s_o   (bvalid_s_o  ),
    .bready_s_i   (bready_s_i  ),

    .rid_s_o      (rid_s_o     ),
    .rdata_s_o    (rdata_s_o   ),
    .rresp_s_o    (rresp_s_o   ),
    .rlast_s_o    (rlast_s_o   ),
    .ruser_s_o    (ruser_s_o   ),
    .rvalid_s_o   (rvalid_s_o  ),
    .rready_s_i   (rready_s_i  ),

    .awakeup_s_i  (awakeup_s_i ),

    .arid_m_o     (dp_pchk_arid_wire    ),
    .araddr_m_o   (dp_pchk_araddr_wire  ),
    .arlen_m_o    (dp_pchk_arlen_wire   ),
    .arsize_m_o   (dp_pchk_arsize_wire  ),
    .arburst_m_o  (dp_pchk_arburst_wire ),
    .arlock_m_o   (dp_pchk_arlock_wire  ),
    .arcache_m_o  (dp_pchk_arcache_wire ),
    .arprot_m_o   (dp_pchk_arprot_wire  ),
    .arqos_m_o    (dp_pchk_arqos_wire   ),
    .arregion_m_o (dp_pchk_arregion_wire),
    .aruser_m_o   (  ), 
    .arvalid_m_o  (dp_pchk_arvalid_wire ),
    .arready_m_i  (dp_pchk_arready_wire ),
    .armmusid_m_o (dp_pchk_armmusid_wire),

    .awid_m_o     (dp_pchk_awid_wire    ),
    .awaddr_m_o   (dp_pchk_awaddr_wire  ),
    .awlen_m_o    (dp_pchk_awlen_wire   ),
    .awsize_m_o   (dp_pchk_awsize_wire  ),
    .awburst_m_o  (dp_pchk_awburst_wire ),
    .awlock_m_o   (dp_pchk_awlock_wire  ),
    .awcache_m_o  (dp_pchk_awcache_wire ),
    .awprot_m_o   (dp_pchk_awprot_wire  ),
    .awqos_m_o    (dp_pchk_awqos_wire   ),
    .awregion_m_o (dp_pchk_awregion_wire),
    .awuser_m_o   (  ), 
    .awvalid_m_o  (dp_pchk_awvalid_wire ),
    .awready_m_i  (dp_pchk_awready_wire ),
    .awmmusid_m_o (dp_pchk_awmmusid_wire),

    .wdata_m_o   (dp_pchk_wdata_wire   ),
    .wstrb_m_o    (dp_pchk_wstrb_wire   ),
    .wlast_m_o    (dp_pchk_wlast_wire   ),
    .wuser_m_o    (   ), 
    .wvalid_m_o   (dp_pchk_wvalid_wire  ),
    .wready_m_i   (dp_pchk_wready_wire  ),


    .bid_m_i            ({FC_AXIID_WIDTH{1'b0}}),
    .bresp_m_i          (2'b00),
    .buser_m_i          ({FC_AXIUSER_B_WIDTH{1'b0}}),
    .bvalid_m_i         (1'b0),
    .bready_m_o         (),   

    .rid_m_i            ({FC_AXIID_WIDTH{1'b0}}),
    .rdata_m_i          ({FC_AXIDATA_WIDTH{1'b0}}),
    .rresp_m_i          (2'b00),
    .rlast_m_i          (1'b0),
    .ruser_m_i          ({FC_AXIUSER_R_WIDTH{1'b0}}),
    .rvalid_m_i         (1'b0),
    .rready_m_o         (),   


    .awakeup_m_o  (dp_pchk_awakeup_wire ),

    .tracker_al_empty_rd_i (1'b1), 
    .tracker_al_empty_wr_i (1'b1), 
    .tracker_empty_rd_i (1'b1), 
    .tracker_empty_wr_i (1'b1), 

    .tracker_id_rd_ch_o    (),     
    .tracker_id_wr_ch_o    (),     
    .tracker_read_rd_ch_o  (),     
    .tracker_read_wr_ch_o  (),     
    .tracker_dout_rd_ch_i  (1'b0), 
    .tracker_dout_wr_ch_i  (1'b0),  
    .tracker_dout_rd_ch_vld_i (1'b0),
    .tracker_dout_wr_ch_vld_i (1'b0),

    .rb_me_st_rdum_i       ( rb_me_st_rdum_i    ),
    .rb_pe_st_err_i        ( rb_pe_st_err_i     ),
    .rb_pe_st_err_raz_i    ( rb_pe_st_err_raz_i ),
    .rb_pe_st_flt_cfg_i    ( rb_pe_st_flt_cfg_i ),
    .rb_pe_st_en_i         ( rb_pe_st_en_i      ),

    .rb_fe_rd_tal_o        ( rb_fe_rd_tal_o     ),
    .rb_fe_rd_tau_o        ( rb_fe_rd_tau_o     ),
    .rb_fe_rd_tp_o         ( rb_fe_rd_tp_o      ),
    .rb_fe_rd_mid_o        ( rb_fe_rd_mid_o     ),
    .rb_fe_rd_valid_o      ( rb_fe_rd_valid_o   ),
    .rb_fe_rd_type_o       ( rb_fe_rd_type_o    ),
    .rb_tmp_reg_err_rd     ( rb_tmp_reg_err_rd  ),

    .rb_fe_wr_tal_o        ( rb_fe_wr_tal_o     ),
    .rb_fe_wr_tau_o        ( rb_fe_wr_tau_o     ),
    .rb_fe_wr_tp_o         ( rb_fe_wr_tp_o      ),
    .rb_fe_wr_mid_o        ( rb_fe_wr_mid_o     ),
    .rb_fe_wr_valid_o      ( rb_fe_wr_valid_o   ),
    .rb_fe_wr_type_o       ( rb_fe_wr_type_o    ),
    .rb_tmp_reg_err_wr     ( rb_tmp_reg_err_wr  ),

    .rb_prot_size_i        ( rb_prot_size_i[PROT_SIZE_WIDTH-1:0]     ),
    .rb_bypass_i           ( rb_bypass_i        ),
    .rb_sram_rdy_i         ( rb_sr_rdy_i        ),
    .rb_fw_st_i            ( rb_fw_st_i         ),
    .rb_st_me_en_i         ( 1'b0 ),
    .rd_edr_wen_o          (), 
    .rd_edr_addr_lwr_o     (), 
    .rd_edr_addr_uppr_o    (), 
    .rd_edr_prop_o         (), 
    .wr_edr_wen_o          (), 
    .wr_edr_addr_lwr_o     (), 
    .wr_edr_addr_uppr_o    (), 
    .wr_edr_prop_o         (), 

    .rb_cfg_rgn_tcfg0_i    ( {FC_NUM_RGN*RGN_TCFG0_WIDTH {1'b0}} ),
    .rb_cfg_rgn_tcfg1_i    ( {FC_NUM_RGN*RGN_TCFG1_WIDTH {1'b0}} ),
    .rb_cfg_rgn_tcfg2_i    ( {FC_NUM_RGN*RGN_TCFG2_WIDTH {1'b0}} ),

    .rb_rgn_st_i           ( rb_rgn_st_i        ),
    .rb_rgn_size_i         ( rb_rgn_size_i      ),
    .rb_rgn_base_addr_i    ( rb_rgn_base_addr_i ),
    .rb_rgn_upper_addr_i   ( rb_rgn_upper_addr_i),

    .rb_rgn_mid0_i         ( rb_rgn_mid0_i      ),
    .rb_rgn_mid1_i         ( rb_rgn_mid1_i      ),
    .rb_rgn_mid2_i         ( rb_rgn_mid2_i      ),
    .rb_rgn_mid3_i         ( rb_rgn_mid3_i      ),

    .rb_rgn_mpl0_i         ( rb_rgn_mpl0_i      ),
    .rb_rgn_mpl1_i         ( rb_rgn_mpl1_i      ),
    .rb_rgn_mpl2_i         ( rb_rgn_mpl2_i      ),
    .rb_rgn_mpl3_i         ( rb_rgn_mpl3_i      ),

    .bid_pchk_i      (dp_pchk_bid_wire     ),
    .bresp_pchk_i    (dp_pchk_bresp_wire   ),
    .buser_pchk_i    (dp_pchk_buser_wire   ),
    .bvalid_pchk_i   (dp_pchk_bvalid_wire  ),
    .bready_pchk_o   (dp_pchk_bready_wire  ),

    .rid_pchk_i      (dp_pchk_rid_wire     ),
    .rdata_pchk_i    (dp_pchk_rdata_wire   ),
    .rresp_pchk_i    (dp_pchk_rresp_wire   ),
    .rlast_pchk_i    (dp_pchk_rlast_wire   ),
    .ruser_pchk_i    (dp_pchk_ruser_wire   ),
    .rvalid_pchk_i   (dp_pchk_rvalid_wire  ),
    .mst_id_pchk_i   (mst_id_pchk_wire),
    .rready_pchk_o   (dp_pchk_rready_wire  ),

    .bid_cfg_i             ( bid_m_i   ),  
    .bresp_cfg_i           ( bresp_m_i ),
    .buser_cfg_i           ( buser_m_i ),
    .bvalid_cfg_i          ( bvalid_m_i),
    .bready_cfg_o          ( bready_m_o),

    .rid_cfg_i             ( rid_m_i   ),
    .rdata_cfg_i           ( rdata_m_i ),
    .rresp_cfg_i           ( rresp_m_i ),
    .rlast_cfg_i           ( rlast_m_i ),
    .ruser_cfg_i           ( ruser_m_i ),
    .rvalid_cfg_i          ( rvalid_m_i),
    .mst_id_cfg_i          ( mst_id_m_i),
    .rready_cfg_o          ( rready_m_o)

);

firewall_f0_ctlr_pchk #(
  .REG_ADDR_WIDTH           (REG_ADDR_WIDTH),
  .REG_ENUM_WIDTH           (REG_ENUM_WIDTH),
  .PID0_WIDTH               (PID0_WIDTH)    ,
  .PID1_WIDTH               (PID1_WIDTH)    ,
  .PID2_WIDTH               (PID2_WIDTH)    ,
  .PID3_WIDTH               (PID3_WIDTH)    ,
  .PID4_WIDTH               (PID4_WIDTH)    ,
  .CID0_WIDTH               (CID0_WIDTH)    ,
  .CID1_WIDTH               (CID1_WIDTH)    ,
  .CID2_WIDTH               (CID2_WIDTH)    ,
  .CID3_WIDTH               (CID3_WIDTH)    ,
  .AIDR_WIDTH               (AIDR_WIDTH)    ,
  .IIDR_WIDTH               (IIDR_WIDTH)    ,
  .FW_ID_WIDTH              (FW_ID_WIDTH)   ,
  `include "firewall_f0_ctlr_params_inst.vh"
)
u_fctlr_pchk (
    .clk          (clk         ),
    .reset_n      (reset_n     ),

    .arid_s_i     (dp_pchk_arid_wire    ),
    .araddr_s_i   (dp_pchk_araddr_wire  ),
    .arlen_s_i    (dp_pchk_arlen_wire   ),
    .arsize_s_i   (dp_pchk_arsize_wire  ),
    .arburst_s_i  (dp_pchk_arburst_wire ),
    .arlock_s_i   (dp_pchk_arlock_wire  ),
    .arcache_s_i  (dp_pchk_arcache_wire ),
    .arprot_s_i   (dp_pchk_arprot_wire  ),
    .arqos_s_i    (dp_pchk_arqos_wire   ),
    .arregion_s_i (dp_pchk_arregion_wire),
    .arvalid_s_i  (dp_pchk_arvalid_wire ),
    .arready_s_o  (dp_pchk_arready_wire ),
    .armmusid_s_i (dp_pchk_armmusid_wire),

    .awid_s_i     (dp_pchk_awid_wire    ),
    .awaddr_s_i   (dp_pchk_awaddr_wire  ),
    .awlen_s_i    (dp_pchk_awlen_wire   ),
    .awsize_s_i   (dp_pchk_awsize_wire  ),
    .awburst_s_i  (dp_pchk_awburst_wire ),
    .awlock_s_i   (dp_pchk_awlock_wire  ),
    .awcache_s_i  (dp_pchk_awcache_wire ),
    .awprot_s_i   (dp_pchk_awprot_wire  ),
    .awqos_s_i    (dp_pchk_awqos_wire   ),
    .awregion_s_i (dp_pchk_awregion_wire),
    .awvalid_s_i  (dp_pchk_awvalid_wire ),
    .awready_s_o  (dp_pchk_awready_wire ),
    .awmmusid_s_i (dp_pchk_awmmusid_wire),

    .wdata_s_i    (dp_pchk_wdata_wire   ),
    .wstrb_s_i    (dp_pchk_wstrb_wire   ),
    .wlast_s_i    (dp_pchk_wlast_wire   ),
    .wvalid_s_i   (dp_pchk_wvalid_wire  ),
    .wready_s_o   (dp_pchk_wready_wire  ),

    .bid_pchk_o      (dp_pchk_bid_wire     ),
    .bresp_pchk_o    (dp_pchk_bresp_wire   ),
    .buser_pchk_o    (dp_pchk_buser_wire   ),
    .bvalid_pchk_o   (dp_pchk_bvalid_wire  ),
    .bready_pchk_i   (dp_pchk_bready_wire  ),

    .rid_pchk_o      (dp_pchk_rid_wire     ),
    .rdata_pchk_o    (dp_pchk_rdata_wire   ),
    .rresp_pchk_o    (dp_pchk_rresp_wire   ),
    .rlast_pchk_o    (dp_pchk_rlast_wire   ),
    .ruser_pchk_o    (dp_pchk_ruser_wire   ),
    .rvalid_pchk_o   (dp_pchk_rvalid_wire  ),
    .mst_id_pchk_o   (mst_id_pchk_wire),
    .rready_pchk_i   (dp_pchk_rready_wire  ),

    .awakeup_s_i  (dp_pchk_awakeup_wire ),

    .arid_m_o     (arid_m_o    ),
    .araddr_m_o   (araddr_m_o  ),
    .arvalid_m_o  (arvalid_m_o ),
    .arready_m_i  (arready_m_i ),
    .armmusid_m_o (armmusid_m_o),

    .awid_m_o     (awid_m_o    ),
    .awaddr_m_o   (awaddr_m_o  ),
    .awvalid_m_o  (awvalid_m_o ),
    .awready_m_i  (awready_m_i ),
    .awmmusid_m_o (awmmusid_m_o),

    .wdata_m_o    (wdata_m_o   ),
    .wvalid_m_o   (wvalid_m_o  ),
    .wready_m_i   (wready_m_i  ),
    .wlast_m_o    (wlast_m_o   ),

    .cfg_w_fw_id_o (cfg_w_fw_id_o ),
    .cfg_r_fw_id_o (cfg_r_fw_id_o ),

    .reg_addr_dec_rd_o  (reg_addr_dec_rd_o),
    .reg_addr_dec_wr_o  (reg_addr_dec_wr_o ),

    .prot_size_i        (rb_prot_size_i),

    .reg_pid0_i(rb_pid0_i),
    .reg_pid1_i(rb_pid1_i),
    .reg_pid2_i(rb_pid2_i),
    .reg_pid3_i(rb_pid3_i),
    .reg_pid4_i(rb_pid4_i),

    .reg_cid0_i(rb_cid0_i),
    .reg_cid1_i(rb_cid1_i),
    .reg_cid2_i(rb_cid2_i),
    .reg_cid3_i(rb_cid3_i),

    .reg_aidr_i(rb_aidr_i),
    .reg_iidr_i(rb_iidr_i),
    .reg_fw_sr_ctrl_i(rb_fw_sr_ctrl_i),
    .sram_rdy_i(rb_sr_rdy_i ),

    .rb_comp_pwr_st_i  (rb_comp_pwr_st_i),
    .pchk_write_tamp_o (rb_write_tamp_o),
    .pchk_read_tamp_o  (rb_read_tamp_o)
);

endmodule
