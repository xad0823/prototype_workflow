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
//      Checked In          : Fri Dec 9 09:57:44 2016 +0000
//
//      Revision            : b783292
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_sync_m #(
    parameter ADDR_WIDTH     = 32,
    parameter MASTER_WIDTH   =  4,
    parameter QS_POWER_EN    =  1,
    parameter QM_CLOCK_EN    =  1,
    parameter QM_SYNC        =  0
  )
 (
    input  wire                             pclk,
    input  wire                             presetn,

    input  wire                             pready,

    input  wire                             apb_trnf_req,
    output wire                             apb_trnf_ack,
    input  wire     [31:0]                  prdata,
    output wire     [31:0]                  prdata_r,
    output wire                             psel,
    output wire                             penable,
    output wire                             apb_active,

    output wire                             pslverr_i,
    input  wire                             pslverr,
    input  wire         [MASTER_WIDTH-1:0]  pmaster_i,
    output wire         [MASTER_WIDTH-1:0]  pmaster,
    input  wire           [ADDR_WIDTH-1:0]  paddr_i,
    output wire           [ADDR_WIDTH-1:0]  paddr,
    input  wire                             pwrite_i,
    output wire                             pwrite,
    input  wire                      [3:0]  pstrb_i,
    output wire                      [3:0]  pstrb,
    input  wire                      [2:0]  pprot_i,
    output wire                      [2:0]  pprot,
    input  wire                     [31:0]  pwdata_i,
    output wire                     [31:0]  pwdata,
    output wire                             pclk_qactive_m,
    input  wire                             pclk_qreqn_m,
    output wire                             pclk_qacceptn_m,
    output wire                             pclk_qdeny_m,


    input  wire                             s_active_reg,
    input  wire                             pwr_ext_wake,
    output wire                             m_ext_wake,

    output wire                             m_lp_req_n,
    input  wire                             m_lp_done_n,

    input  wire                             pwr_lp_req_n,
    output wire                             pwr_lp_done_n
  );

  wire      brg_pwr_req_m;
  wire      pslverr_reg;

  wire             [31:0]  prdata_g ;

     sie200_ahb5_to_apb_sync_core_m
     u_ahb5_to_apb_sync_apbs (
      .pclk            (pclk),
      .presetn         (presetn),
      .pready          (pready),
      .apb_trnf_req    (apb_trnf_req),
      .apb_trnf_ack    (apb_trnf_ack),
      .psel            (psel),
      .prdata          (prdata),
      .prdata_r        (prdata_g),
      .pslverr         (pslverr),
      .pslverr_r       (pslverr_reg),
      .penable         (penable),
      .apb_active      (apb_active)
     );


    sie200_ahb5_access_ctrl_core_m # (
    .QCLK_SYNC          (1'b1),
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
    .brg_pwr_ack_m      (brg_pwr_req_m),
    .s_active_reg       (s_active_reg),
    .pwr_ext_wake       (pwr_ext_wake),
    .m_ext_wake         (m_ext_wake),
    .m_lp_req_n         (m_lp_req_n),
    .m_lp_done_n        (m_lp_done_n),
    .pwr_lp_req_n       (pwr_lp_req_n),
    .pwr_lp_done_n      (pwr_lp_done_n)
    );


  generate
    if (QS_POWER_EN)
      begin : power_down_m
          localparam ISO_WIDTH = MASTER_WIDTH + ADDR_WIDTH + 73;
          sie200_and #(.DATA_WIDTH(ISO_WIDTH)) u_sie200_and (
          .in_a  ({pmaster_i,paddr_i,pwrite_i,pstrb_i,pprot_i,pwdata_i,pslverr_reg,prdata_g}),
          .in_b  ({(ISO_WIDTH){~brg_pwr_req_m}}),
          .out_y ({pmaster  ,paddr  ,pwrite  ,pstrb  ,pprot  ,pwdata  ,pslverr_i  ,prdata_r})
          );
      end
    else
      begin : functional_m
          assign {pmaster  ,paddr  ,pslverr_i  ,pwrite  ,pstrb  ,pwdata  ,pprot  ,prdata_r}  =
                 {pmaster_i,paddr_i,pslverr_reg,pwrite_i,pstrb_i,pwdata_i,pprot_i,prdata_g};
      end
  endgenerate











endmodule

