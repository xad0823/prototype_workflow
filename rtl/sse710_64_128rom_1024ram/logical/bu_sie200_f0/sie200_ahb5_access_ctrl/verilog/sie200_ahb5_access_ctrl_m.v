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
//      Checked In          : Wed Nov 23 16:32:41 2016 +0000
//
//      Revision            : 29a5aa6
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl_m #(
  parameter                       ADDR_WIDTH    = 32,
  parameter                       DATA_WIDTH    = 32,
  parameter                       MASTER_WIDTH  =  4,
  parameter                       USER_WIDTH    =  1,
  parameter                       QS_POWER_EN   =  1,
  parameter                       QM_CLOCK_EN   =  1,
  parameter                       QM_SYNC       =  0
)
(
  input  wire                     hclk_m,
  input  wire                     hresetn_m,

  input  wire                     hsel_i,
  input  wire                     hnonsec_i,
  input  wire [ADDR_WIDTH-1:0]    haddr_i,
  input  wire [1:0]               htrans_i,
  input  wire [2:0]               hsize_i,
  input  wire                     hwrite_i,
  input  wire                     hready_i,
  input  wire [6:0]               hprot_i,
  input  wire [2:0]               hburst_i,
  input  wire                     hmastlock_i,
  input  wire [DATA_WIDTH-1:0]    hwdata_i,
  input  wire                     hexcl_i,
  input  wire [MASTER_WIDTH-1:0]  hmaster_i,
  output wire                     hreadyout_i,
  output wire                     hresp_i,
  output wire [DATA_WIDTH-1:0]    hrdata_i,
  output wire                     hexokay_i,
  input  wire [USER_WIDTH-1:0]    hauser_i,
  input  wire [USER_WIDTH-1:0]    hwuser_i,
  output wire [USER_WIDTH-1:0]    hruser_i,


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


  output wire                     hclk_qactive_m,
  input  wire                     hclk_qreqn_m,
  output wire                     hclk_qacceptn_m,
  output wire                     hclk_qdeny_m,

  input  wire                     s_active_reg,
  input  wire                     pwr_ext_wake,
  output wire                     m_ext_wake,

  output wire                     m_lp_req_n,
  input  wire                     m_lp_done_n,

  input  wire                     pwr_lp_req_n,
  output wire                     pwr_lp_done_n
);

wire  brg_pwr_req_m;
wire  brg_pwr_ack_m;

sie200_ahb5_access_ctrl_core_m # (
    .QCLK_SYNC          (1'b1),
    .QS_POWER_EN        (QS_POWER_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QM_SYNC            (QM_SYNC))
  u_acg_core_m (
    .hclk_m             (hclk_m),
    .hresetn_m          (hresetn_m),
    .hclk_qactive_m     (hclk_qactive_m),
    .hclk_qreqn_m       (hclk_qreqn_m),
    .hclk_qacceptn_m    (hclk_qacceptn_m),
    .hclk_qdeny_m       (hclk_qdeny_m),
    .brg_pwr_req_m      (brg_pwr_req_m),
    .brg_pwr_ack_m      (brg_pwr_ack_m),
    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);

sie200_ahb5_access_ctrl_iso_m # (
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .MASTER_WIDTH       (MASTER_WIDTH),
    .USER_WIDTH         (USER_WIDTH))
  u_acg_iso_m (
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

    .brg_pwr_req_m      (brg_pwr_req_m),
    .brg_pwr_ack_m      (brg_pwr_ack_m)
);











endmodule

