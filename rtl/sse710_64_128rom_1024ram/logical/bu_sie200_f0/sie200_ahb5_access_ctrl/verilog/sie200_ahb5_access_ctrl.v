//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Oct 14 17:21:05 2016 +0100
//
//      Revision            : ae8f9f2
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl #(
  parameter                       ADDR_WIDTH    = 32,
  parameter                       DATA_WIDTH    = 32,
  parameter                       MASTER_WIDTH  =  4,
  parameter                       USER_WIDTH    =  1,
  parameter                       QS_CLOCK_EN   =  1,
  parameter                       QM_CLOCK_EN   =  1,
  parameter                       QS_POWER_EN   =  1,
  parameter                       QS_SYNC       =  0,
  parameter                       QM_SYNC       =  0,
  parameter                       EXT_GATE_SYNC =  0
)
(
  input  wire                     hclk_s,
  input  wire                     hresetn_s,
  input  wire                     hsel_s,
  input  wire                     hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]    haddr_s,
  input  wire [1:0]               htrans_s,
  input  wire [2:0]               hsize_s,
  input  wire                     hwrite_s,
  input  wire                     hready_s,
  input  wire [6:0]               hprot_s,
  input  wire [2:0]               hburst_s,
  input  wire                     hmastlock_s,
  input  wire [DATA_WIDTH-1:0]    hwdata_s,
  input  wire                     hexcl_s,
  input  wire [MASTER_WIDTH-1:0]  hmaster_s,
  output wire                     hreadyout_s,
  output wire                     hresp_s,
  output wire [DATA_WIDTH-1:0]    hrdata_s,
  output wire                     hexokay_s,
  input  wire [USER_WIDTH-1:0]    hauser_s,
  input  wire [USER_WIDTH-1:0]    hwuser_s,
  output wire [USER_WIDTH-1:0]    hruser_s,

  input  wire                     hclk_m,
  input  wire                     hresetn_m,
  output wire                     hsel_m,
  output wire                     hnonsec_m,
  output wire [ADDR_WIDTH-1:0]    haddr_m,
  output wire [1:0]               htrans_m,
  output wire [2:0]               hsize_m,
  output wire                     hwrite_m,
  output wire                     hready_m,
  output wire [6:0]               hprot_m,
  output wire [2:0]               hburst_m,
  output wire                     hmastlock_m,
  output wire [DATA_WIDTH-1:0]    hwdata_m,
  output wire                     hexcl_m,
  output wire [MASTER_WIDTH-1:0]  hmaster_m,
  input  wire                     hreadyout_m,
  input  wire                     hresp_m,
  input  wire [DATA_WIDTH-1:0]    hrdata_m,
  input  wire                     hexokay_m,
  output wire [USER_WIDTH-1:0]    hauser_m,
  output wire [USER_WIDTH-1:0]    hwuser_m,
  input  wire [USER_WIDTH-1:0]    hruser_m,

  output wire                     hclk_qactive_s,
  input  wire                     hclk_qreqn_s,
  output wire                     hclk_qacceptn_s,
  output wire                     hclk_qdeny_s,

  output wire                     hclk_qactive_m,
  input  wire                     hclk_qreqn_m,
  output wire                     hclk_qacceptn_m,
  output wire                     hclk_qdeny_m,

  output wire                     pwr_qactive_s,
  input  wire                     pwr_qreqn_s,
  output wire                     pwr_qacceptn_s,
  output wire                     pwr_qdeny_s,

  input  wire                     ext_gate_req,
  output wire                     ext_gate_ack,
  input  wire                     cfg_gate_resp
);







wire                     s_active_reg;
wire                     pwr_ext_wake;
wire                     m_ext_wake;
wire                     m_lp_req_n;
wire                     m_lp_done_n;
wire                     pwr_lp_req_n;
wire                     pwr_lp_done_n;

wire                     hsel_i;
wire                     hnonsec_i;
wire [ADDR_WIDTH-1:0]    haddr_i;
wire [1:0]               htrans_i;
wire [2:0]               hsize_i;
wire                     hwrite_i;
wire                     hready_i;
wire [6:0]               hprot_i;
wire [2:0]               hburst_i;
wire                     hmastlock_i;
wire [DATA_WIDTH-1:0]    hwdata_i;
wire                     hexcl_i;
wire [MASTER_WIDTH-1:0]  hmaster_i;
wire                     hreadyout_i;
wire                     hresp_i;
wire [DATA_WIDTH-1:0]    hrdata_i;
wire                     hexokay_i;
wire [USER_WIDTH-1:0]    hauser_i;
wire [USER_WIDTH-1:0]    hwuser_i;
wire [USER_WIDTH-1:0]    hruser_i;


sie200_ahb5_access_ctrl_s #(
  .ADDR_WIDTH           (ADDR_WIDTH),
  .DATA_WIDTH           (DATA_WIDTH),
  .MASTER_WIDTH         (MASTER_WIDTH),
  .USER_WIDTH           (USER_WIDTH),
  .QS_CLOCK_EN          (QS_CLOCK_EN),
  .QM_CLOCK_EN          (QM_CLOCK_EN),
  .QS_POWER_EN          (QS_POWER_EN),
  .QS_SYNC              (QS_SYNC),
  .EXT_GATE_SYNC        (EXT_GATE_SYNC))
  u_acg_s (

    .hclk_s             (hclk_s),
    .hresetn_s          (hresetn_s),

    .hsel_s             (hsel_s),
    .hnonsec_s          (hnonsec_s),
    .haddr_s            (haddr_s),
    .htrans_s           (htrans_s),
    .hsize_s            (hsize_s),
    .hwrite_s           (hwrite_s),
    .hready_s           (hready_s),
    .hprot_s            (hprot_s),
    .hburst_s           (hburst_s),
    .hmastlock_s        (hmastlock_s),
    .hwdata_s           (hwdata_s),
    .hexcl_s            (hexcl_s),
    .hmaster_s          (hmaster_s),
    .hreadyout_s        (hreadyout_s),
    .hresp_s            (hresp_s),
    .hrdata_s           (hrdata_s),
    .hexokay_s          (hexokay_s),
    .hauser_s           (hauser_s),
    .hwuser_s           (hwuser_s),
    .hruser_s           (hruser_s),

    .hsel_i             (hsel_i),
    .hnonsec_i          (hnonsec_i),
    .haddr_i            (haddr_i),
    .htrans_i           (htrans_i),
    .hsize_i            (hsize_i),
    .hwrite_i           (hwrite_i),
    .hready_i           (hready_i),
    .hprot_i            (hprot_i),
    .hburst_i           (hburst_i),
    .hmastlock_i        (hmastlock_i),
    .hwdata_i           (hwdata_i),
    .hexcl_i            (hexcl_i),
    .hmaster_i          (hmaster_i),
    .hreadyout_i        (hreadyout_i),
    .hresp_i            (hresp_i),
    .hrdata_i           (hrdata_i),
    .hexokay_i          (hexokay_i),
    .hauser_i           (hauser_i),
    .hwuser_i           (hwuser_i),
    .hruser_i           (hruser_i),

    .hclk_qactive_s     (hclk_qactive_s),
    .hclk_qreqn_s       (hclk_qreqn_s),
    .hclk_qacceptn_s    (hclk_qacceptn_s),
    .hclk_qdeny_s       (hclk_qdeny_s),

    .pwr_qactive_s      (pwr_qactive_s),
    .pwr_qreqn_s        (pwr_qreqn_s),
    .pwr_qacceptn_s     (pwr_qacceptn_s),
    .pwr_qdeny_s        (pwr_qdeny_s),

    .ext_gate_req       (ext_gate_req),
    .ext_gate_ack       (ext_gate_ack),
    .cfg_gate_resp      (cfg_gate_resp),

    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);



sie200_ahb5_access_ctrl_m # (
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .MASTER_WIDTH       (MASTER_WIDTH),
    .USER_WIDTH         (USER_WIDTH),
    .QS_POWER_EN        (QS_POWER_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QM_SYNC            (QM_SYNC))
  u_acg_m (
    .hclk_m             (hclk_m),
    .hresetn_m          (hresetn_m),

    .hsel_i             (hsel_i),
    .hnonsec_i          (hnonsec_i),
    .haddr_i            (haddr_i),
    .htrans_i           (htrans_i),
    .hsize_i            (hsize_i),
    .hwrite_i           (hwrite_i),
    .hready_i           (hready_i),
    .hprot_i            (hprot_i),
    .hburst_i           (hburst_i),
    .hmastlock_i        (hmastlock_i),
    .hwdata_i           (hwdata_i),
    .hexcl_i            (hexcl_i),
    .hmaster_i          (hmaster_i),
    .hreadyout_i        (hreadyout_i),
    .hresp_i            (hresp_i),
    .hrdata_i           (hrdata_i),
    .hexokay_i          (hexokay_i),
    .hauser_i           (hauser_i),
    .hwuser_i           (hwuser_i),
    .hruser_i           (hruser_i),

    .hsel_m             (hsel_m),
    .hnonsec_m          (hnonsec_m),
    .haddr_m            (haddr_m),
    .htrans_m           (htrans_m),
    .hsize_m            (hsize_m),
    .hwrite_m           (hwrite_m),
    .hready_m           (hready_m),
    .hprot_m            (hprot_m),
    .hburst_m           (hburst_m),
    .hmastlock_m        (hmastlock_m),
    .hwdata_m           (hwdata_m),
    .hexcl_m            (hexcl_m),
    .hmaster_m          (hmaster_m),
    .hreadyout_m        (hreadyout_m),
    .hresp_m            (hresp_m),
    .hrdata_m           (hrdata_m),
    .hexokay_m          (hexokay_m),
    .hauser_m           (hauser_m),
    .hwuser_m           (hwuser_m),
    .hruser_m           (hruser_m),


    .hclk_qactive_m     (hclk_qactive_m),
    .hclk_qreqn_m       (hclk_qreqn_m),
    .hclk_qacceptn_m    (hclk_qacceptn_m),
    .hclk_qdeny_m       (hclk_qdeny_m),

    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);



endmodule

