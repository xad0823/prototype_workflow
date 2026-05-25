//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2012, 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Sep 1 13:10:58 2016 +0100
//
//      Revision            : e4d2652
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_sync #(
    parameter ADDR_WIDTH     = 32,
    parameter MASTER_WIDTH   =  4,
    parameter REGISTER_WDATA =  0,
    parameter QS_POWER_EN    =  1,
    parameter QS_CLOCK_EN    =  1,
    parameter QM_CLOCK_EN    =  1,
    parameter QS_SYNC        =  0,
    parameter QM_SYNC        =  0,
    parameter EXT_GATE_SYNC  =  0

  )
 (
  input  wire                             hclk,
  input  wire                             hresetn,
  input  wire                             pclk,
  input  wire                             presetn,

  input  wire                             hsel,
  input  wire            [ADDR_WIDTH-1:0] haddr,
  input  wire                       [1:0] htrans,
  input  wire                       [2:0] hsize,
  input  wire                       [6:0] hprot,
  input  wire                             hwrite,
  input  wire                             hready,
  input  wire                      [31:0] hwdata,
  input  wire          [MASTER_WIDTH-1:0] hmaster,

  output wire                             hreadyout,
  output wire                      [31:0] hrdata,
  output wire                             hresp,

  input  wire                             hnonsec,

  output wire          [MASTER_WIDTH-1:0] pmaster,
  output wire            [ADDR_WIDTH-1:0] paddr,
  output wire                             penable,
  output wire                             pwrite,
  output wire          [3:0]              pstrb,
  output wire                       [2:0] pprot,
  output wire                      [31:0] pwdata,
  output wire                             psel,

  output wire                             apb_active,

  input  wire                      [31:0] prdata,
  input  wire                             pready,
  input  wire                             pslverr,

  output wire                             hclk_qactive_s,
  input  wire                             hclk_qreqn_s,
  output wire                             hclk_qacceptn_s,
  output wire                             hclk_qdeny_s,

  output wire                             pclk_qactive_m,
  input  wire                             pclk_qreqn_m,
  output wire                             pclk_qacceptn_m,
  output wire                             pclk_qdeny_m,

  output wire                             pwr_qactive_s,
  input  wire                             pwr_qreqn_s,
  output wire                             pwr_qacceptn_s,
  output wire                             pwr_qdeny_s,

  input  wire                             ext_gate_req,
  output wire                             ext_gate_ack,
  input  wire                             cfg_gate_resp
  );


  wire        apb_trnf_req;
  wire        apb_trnf_ack;

  wire        s_active_reg;
  wire        pwr_ext_wake;
  wire        m_ext_wake;
  wire        m_lp_req_n;
  wire        m_lp_done_n;
  wire        pwr_lp_req_n;
  wire        pwr_lp_done_n;

  wire [31:0] prdata_r;

  wire                      pslverr_i;
  wire  [MASTER_WIDTH-1:0]  pmaster_i;
  wire    [ADDR_WIDTH-1:0]  paddr_i;
  wire                      pwrite_i;
  wire               [3:0]  pstrb_i;
  wire               [2:0]  pprot_i;
  wire              [31:0]  pwdata_i;




     sie200_ahb5_to_apb_sync_s #(
      .ADDR_WIDTH     (ADDR_WIDTH),
      .MASTER_WIDTH   (MASTER_WIDTH),
      .REGISTER_WDATA (REGISTER_WDATA),
      .QS_CLOCK_EN    (QS_CLOCK_EN),
      .QM_CLOCK_EN    (QM_CLOCK_EN),
      .QS_POWER_EN    (QS_POWER_EN),
      .QS_SYNC        (QS_SYNC),
      .EXT_GATE_SYNC  (EXT_GATE_SYNC)
      )
     u_ahb5_to_apb_sync_s (
      .hclk            (hclk),
      .hresetn         (hresetn),
      .hsel            (hsel),
      .haddr           (haddr),
      .htrans          (htrans),
      .hsize           (hsize),
      .hprot           (hprot),
      .hwrite          (hwrite),
      .hready          (hready),
      .hwdata          (hwdata),
      .hnonsec         (hnonsec),
      .hmaster         (hmaster),
      .hreadyout       (hreadyout),
      .hrdata          (hrdata),
      .hresp           (hresp),
      .apb_trnf_req    (apb_trnf_req),
      .apb_trnf_ack    (apb_trnf_ack),
      .pslverr_i       (pslverr_i),
      .prdata_r        (prdata_r),
      .pmaster_i       (pmaster_i),
      .paddr_i         (paddr_i),
      .pwrite_i        (pwrite_i),
      .pstrb_i         (pstrb_i),
      .pprot_i         (pprot_i),
      .pwdata_i        (pwdata_i),

      .hclk_qactive_s  (hclk_qactive_s),
      .hclk_qreqn_s    (hclk_qreqn_s),
      .hclk_qacceptn_s (hclk_qacceptn_s),
      .hclk_qdeny_s    (hclk_qdeny_s),

      .pwr_qactive_s   (pwr_qactive_s),
      .pwr_qreqn_s     (pwr_qreqn_s),
      .pwr_qacceptn_s  (pwr_qacceptn_s),
      .pwr_qdeny_s     (pwr_qdeny_s),

      .ext_gate_req    (ext_gate_req),
      .ext_gate_ack    (ext_gate_ack),
      .cfg_gate_resp   (cfg_gate_resp),

      .s_active_reg    (s_active_reg),
      .pwr_ext_wake    (pwr_ext_wake),
      .m_ext_wake      (m_ext_wake),
      .m_lp_req_n      (m_lp_req_n),
      .m_lp_done_n     (m_lp_done_n),
      .pwr_lp_req_n    (pwr_lp_req_n),
      .pwr_lp_done_n   (pwr_lp_done_n)
     );


     sie200_ahb5_to_apb_sync_m # (
      .ADDR_WIDTH      (ADDR_WIDTH),
      .MASTER_WIDTH    (MASTER_WIDTH),
      .QS_POWER_EN     (QS_POWER_EN),
      .QM_CLOCK_EN     (QM_CLOCK_EN),
      .QM_SYNC         (QM_SYNC))
     u_ahb5_to_apb_sync_m (
      .pclk            (pclk),
      .presetn         (presetn),
      .pready          (pready),
      .apb_trnf_req    (apb_trnf_req),
      .apb_trnf_ack    (apb_trnf_ack),
      .psel            (psel),
      .prdata          (prdata),
      .prdata_r        (prdata_r),
      .penable         (penable),
      .apb_active      (apb_active),
      .pslverr_i       (pslverr_i),
      .pslverr         (pslverr),
      .pmaster_i       (pmaster_i),
      .pmaster         (pmaster),
      .paddr_i         (paddr_i),
      .paddr           (paddr),
      .pwrite_i        (pwrite_i),
      .pwrite          (pwrite),
      .pstrb_i         (pstrb_i),
      .pstrb           (pstrb),
      .pprot_i         (pprot_i),
      .pprot           (pprot),
      .pwdata_i        (pwdata_i),
      .pwdata          (pwdata),
      .pclk_qactive_m  (pclk_qactive_m),
      .pclk_qreqn_m    (pclk_qreqn_m),
      .pclk_qacceptn_m (pclk_qacceptn_m),
      .pclk_qdeny_m    (pclk_qdeny_m),
      .s_active_reg    (s_active_reg),
      .pwr_ext_wake    (pwr_ext_wake),
      .m_ext_wake      (m_ext_wake),
      .m_lp_req_n      (m_lp_req_n),
      .m_lp_done_n     (m_lp_done_n),
      .pwr_lp_req_n    (pwr_lp_req_n),
      .pwr_lp_done_n   (pwr_lp_done_n)
     );








endmodule

