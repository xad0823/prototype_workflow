//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2013,2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Aug 10 15:02:19 2016 +0100
//
//      Revision            : 9b8fcac
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_sync #(

  parameter       ADDR_WIDTH    = 32,
  parameter       DATA_WIDTH    = 32,
  parameter       MASTER_WIDTH  = 4,
  parameter       USER_WIDTH    = 1,
  parameter       BURST         = 0,
  parameter       EXT_GATE_SYNC = 0)
 (
  input  wire                    hclk,
  input  wire                    hresetn,

  input  wire                    hsel_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire                    hmastlock_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hnonsec_s,
  input  wire                    hexcl_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire   [2:0]            hburst_m,
  output wire                    hnonsec_m,
  output wire                    hexcl_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  input  wire                    ext_gate_req,
  output wire                    ext_gate_ack,
  input  wire                    cfg_gate_resp

  );

  wire             pend_trans;
  wire             hold_en;

  sie200_ahb5_to_ahb5_sync_core #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .DATA_WIDTH    (DATA_WIDTH),
    .MASTER_WIDTH  (MASTER_WIDTH),
    .USER_WIDTH    (USER_WIDTH),
    .BURST         (BURST))
  u_sie200_ahb5_to_ahb5_sync_core (
    .hclk         (hclk),
    .hresetn      (hresetn),

    .hsel_s       (hsel_s),
    .haddr_s      (haddr_s),
    .htrans_s     (htrans_s),
    .hsize_s      (hsize_s),
    .hwrite_s     (hwrite_s),
    .hready_s     (hready_s),
    .hprot_s      (hprot_s),
    .hmaster_s    (hmaster_s),
    .hmastlock_s  (hmastlock_s),
    .hwdata_s     (hwdata_s),
    .hburst_s     (hburst_s),
    .hnonsec_s    (hnonsec_s),
    .hexcl_s      (hexcl_s),
    .hauser_s     (hauser_s),
    .hwuser_s     (hwuser_s),

    .hreadyout_s  (hreadyout_s),
    .hresp_s      (hresp_s),
    .hrdata_s     (hrdata_s),
    .hexokay_s    (hexokay_s),
    .hruser_s     (hruser_s),

    .haddr_m      (haddr_m),
    .htrans_m     (htrans_m),
    .hsize_m      (hsize_m),
    .hwrite_m     (hwrite_m),
    .hprot_m      (hprot_m),
    .hmaster_m    (hmaster_m),
    .hmastlock_m  (hmastlock_m),
    .hwdata_m     (hwdata_m),
    .hburst_m     (hburst_m),
    .hready_m     (hready_m),
    .hnonsec_m    (hnonsec_m),
    .hexcl_m      (hexcl_m),
    .hauser_m     (hauser_m),
    .hwuser_m     (hwuser_m),

    .hresp_m      (hresp_m),
    .hrdata_m     (hrdata_m),
    .hexokay_m    (hexokay_m),
    .hruser_m     (hruser_m),

    .cfg_gate_resp(cfg_gate_resp),
    .hold_en      (hold_en),
    .pend_trans   (pend_trans)
  );



  sie200_ahb5_access_ctrl_core_s # (
      .QS_CLOCK_EN      (1'b0),
      .QM_CLOCK_EN      (1'b0),
      .QS_POWER_EN      (1'b0),
      .QCLK_SYNC        (1'b1),
      .EXT_GATE_SYNC    (EXT_GATE_SYNC))
    u_acg_s (
      .hclk_s           (hclk),
      .hresetn_s        (hresetn),

      .hclk_qactive_s   (),
      .hclk_qreqn_s     (1'b1),
      .hclk_qacceptn_s  (),
      .hclk_qdeny_s     (),

      .pwr_qactive_s    (),
      .pwr_qreqn_s      (1'b1),
      .pwr_qacceptn_s   (),
      .pwr_qdeny_s      (),

      .ext_gate_req     (ext_gate_req),
      .ext_gate_ack     (ext_gate_ack),

      .hold_en          (hold_en),
      .pend_trans       (pend_trans),
      .s_active         (1'b1),

      .brg_pwr_req_s    (),
      .brg_pwr_ack_s    (1'b0),

      .s_active_reg     (),
      .pwr_ext_wake     (),
      .m_ext_wake       (1'b0),
      .m_lp_req_n       (1'b1),
      .m_lp_done_n      (),
      .pwr_lp_req_n     (),
      .pwr_lp_done_n    (1'b1)
  );


endmodule
