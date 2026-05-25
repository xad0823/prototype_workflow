// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Nov 23 16:54:21 2016 +0000
//
//      Revision            : eed409c
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_apb_async_m #(
    parameter ADDR_WIDTH      = 32,
    parameter MASTER_WIDTH    = 4,
    parameter QM_CLOCK_EN     = 1,
    parameter QS_POWER_EN     = 1,
    parameter QM_SYNC         = 0
  )
  (
    input  wire                     pclk,
    input  wire                     presetn,

    input  wire              [31:0] prdata,
    input  wire                     pready,
    input  wire                     pslverr,
    output wire  [MASTER_WIDTH-1:0] pmaster,
    output wire   [ADDR_WIDTH -1:0] paddr,
    output wire                     penable,
    output wire               [3:0] pstrb,
    output wire               [2:0] pprot,
    output wire                     pwrite,
    output wire              [31:0] pwdata,
    output wire                     psel,

    output wire                     apb_active,

    input  wire                     s_req_h,
    output wire                     s_ack_p,

    input  wire [ADDR_WIDTH-3:0]    s_addr,
    input  wire                     s_trans_valid,
    input  wire            [2:0]    s_prot,
    input  wire            [3:0]    s_strb,
    input  wire                     s_write,
    input  wire           [31:0]    s_wdata,
    input  wire [MASTER_WIDTH-1:0]  s_master,

    output wire           [31:0]    s_rdata,
    output wire                     s_resp,


    output wire                     pclk_qactive_m,
    input  wire                     pclk_qreqn_m,
    output wire                     pclk_qacceptn_m,
    output wire                     pclk_qdeny_m,

    input  wire                     s_active_reg,
    input  wire                     pwr_ext_wake,
    output wire                     m_ext_wake,

    output wire                     m_lp_req_n,
    input  wire                     m_lp_done_n,

    input  wire                     pwr_lp_req_n,
    output wire                     pwr_lp_done_n

 );


  wire                    s_req_p;
  wire                    brg_pwr_req_m;
  wire                    brg_pwr_ack_m;

  sie200_ahb5_access_ctrl_core_m # (
      .QCLK_SYNC          (1'b0),
      .QS_POWER_EN        (QS_POWER_EN),
      .QM_CLOCK_EN        (QM_CLOCK_EN),
      .QM_SYNC            (QM_SYNC))
    u_acg_m (
      .hclk_m             (pclk),
      .hresetn_m          (presetn),
      .hclk_qactive_m     (pclk_qactive_m),
      .hclk_qreqn_m       (pclk_qreqn_m),
      .hclk_qacceptn_m    (pclk_qacceptn_m),
      .hclk_qdeny_m       (pclk_qdeny_m),
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



  sie200_sync u_ahb_to_apb_async_syn_1
  (
    .clk                 (pclk),
    .reset_n             (presetn),
    .d                   (s_req_h),
    .q                   (s_req_p)
   );


  sie200_ahb5_to_apb_async_core_m #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .MASTER_WIDTH(MASTER_WIDTH))
   u_ahb5_to_apb_async_core_m (
    .pclk                (pclk),
    .presetn             (presetn),

    .s_addr              (s_addr),
    .s_trans_valid       (s_trans_valid),
    .s_write             (s_write),
    .s_prot              (s_prot),
    .s_strb              (s_strb),
    .s_wdata             (s_wdata),
    .s_master            (s_master),

    .s_rdata             (s_rdata),
    .s_resp              (s_resp),

    .paddr               (paddr),
    .psel                (psel),
    .pmaster             (pmaster),
    .penable             (penable),
    .pwrite              (pwrite),
    .pprot               (pprot),
    .pstrb               (pstrb),
    .pwdata              (pwdata),

    .prdata              (prdata),
    .pready              (pready),
    .pslverr             (pslverr),

    .apb_active          (apb_active),

    .brg_pwr_req_m       (brg_pwr_req_m),
    .brg_pwr_ack_m       (brg_pwr_ack_m),

    .s_req_p             (s_req_p),
    .s_ack_p             (s_ack_p)
    );







endmodule
