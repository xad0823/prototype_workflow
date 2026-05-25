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
//      Checked In          : Thu Dec 1 11:53:45 2016 +0000
//
//      Revision            : 43833a0
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl_s #(
  parameter                       ADDR_WIDTH    = 32,
  parameter                       DATA_WIDTH    = 32,
  parameter                       MASTER_WIDTH  =  4,
  parameter                       USER_WIDTH    =  1,
  parameter                       QS_CLOCK_EN   =  1,
  parameter                       QM_CLOCK_EN   =  1,
  parameter                       QS_POWER_EN   =  1,
  parameter                       QS_SYNC       =  0,
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

  output wire                     hsel_i,
  output wire                     hnonsec_i,
  output wire [ADDR_WIDTH-1:0]    haddr_i,
  output wire [1:0]               htrans_i,
  output wire [2:0]               hsize_i,
  output wire                     hwrite_i,
  output wire                     hready_i,
  output wire [6:0]               hprot_i,
  output wire [2:0]               hburst_i,
  output wire                     hmastlock_i,
  output wire [DATA_WIDTH-1:0]    hwdata_i,
  output wire                     hexcl_i,
  output wire [MASTER_WIDTH-1:0]  hmaster_i,
  input  wire                     hreadyout_i,
  input  wire                     hresp_i,
  input  wire [DATA_WIDTH-1:0]    hrdata_i,
  input  wire                     hexokay_i,
  output wire [USER_WIDTH-1:0]    hauser_i,
  output wire [USER_WIDTH-1:0]    hwuser_i,
  input  wire [USER_WIDTH-1:0]    hruser_i,

  output wire                     hclk_qactive_s,
  input  wire                     hclk_qreqn_s,
  output wire                     hclk_qacceptn_s,
  output wire                     hclk_qdeny_s,

  output wire                     pwr_qactive_s,
  input  wire                     pwr_qreqn_s,
  output wire                     pwr_qacceptn_s,
  output wire                     pwr_qdeny_s,

  input  wire                     ext_gate_req,
  output wire                     ext_gate_ack,
  input  wire                     cfg_gate_resp,

  output wire                     s_active_reg,
  output wire                     pwr_ext_wake,
  input  wire                     m_ext_wake,
  input  wire                     m_lp_req_n,
  output wire                     m_lp_done_n,

  output wire                     pwr_lp_req_n,
  input  wire                     pwr_lp_done_n
);


wire  hold_en;
wire  pend_trans;
wire  s_active;

wire  brg_pwr_req_s;
wire  brg_pwr_ack_s;


sie200_ahb5_access_ctrl_hold #(
  .ADDR_WIDTH           (ADDR_WIDTH),
  .DATA_WIDTH           (DATA_WIDTH),
  .MASTER_WIDTH         (MASTER_WIDTH),
  .USER_WIDTH           (USER_WIDTH))
  u_acg_hold (

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

    .hsel_m             (hsel_i),
    .hnonsec_m          (hnonsec_i),
    .haddr_m            (haddr_i),
    .htrans_m           (htrans_i),
    .hsize_m            (hsize_i),
    .hwrite_m           (hwrite_i),
    .hready_m           (hready_i),
    .hprot_m            (hprot_i),
    .hburst_m           (hburst_i),
    .hmastlock_m        (hmastlock_i),
    .hwdata_m           (hwdata_i),
    .hexcl_m            (hexcl_i),
    .hmaster_m          (hmaster_i),
    .hreadyout_m        (hreadyout_i),
    .hresp_m            (hresp_i),
    .hrdata_m           (hrdata_i),
    .hexokay_m          (hexokay_i),
    .hauser_m           (hauser_i),
    .hwuser_m           (hwuser_i),
    .hruser_m           (hruser_i),

    .cfg_gate_resp      (cfg_gate_resp),
    .brg_pwr_req_s      (brg_pwr_req_s),
    .brg_pwr_ack_s      (brg_pwr_ack_s),
    .hold_en            (hold_en),
    .pend_trans         (pend_trans),
    .s_active           (s_active)
);

sie200_ahb5_access_ctrl_core_s # (
    .QCLK_SYNC          (1),
    .QS_CLOCK_EN        (QS_CLOCK_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QS_POWER_EN        (QS_POWER_EN),
    .QS_SYNC            (QS_SYNC),
    .EXT_GATE_SYNC      (EXT_GATE_SYNC))
  u_acg_core_s (
    .hclk_s             (hclk_s),
    .hresetn_s          (hresetn_s),

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

    .hold_en            (hold_en),
    .pend_trans         (pend_trans),
    .s_active           (s_active),

    .brg_pwr_req_s      (brg_pwr_req_s),
    .brg_pwr_ack_s      (brg_pwr_ack_s),
    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
);























endmodule

