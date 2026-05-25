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
//      Checked In          : Tue Aug 9 08:12:07 2016 +0100
//
//      Revision            : 8ac0ed4
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_apb_async #(
    parameter ADDR_WIDTH      = 32,
    parameter MASTER_WIDTH    = 4,
    parameter QS_CLOCK_EN     = 1,
    parameter QM_CLOCK_EN     = 1,
    parameter QS_POWER_EN     = 1,
    parameter QS_SYNC         = 0,
    parameter QM_SYNC         = 0,
    parameter EXT_GATE_SYNC   = 0
  )
  (
    input  wire                     hclk,
    input  wire                     hresetn,

    input  wire                     hsel,
    input  wire                     hnonsec,
    input  wire    [ADDR_WIDTH-1:0] haddr,
    input  wire               [1:0] htrans,
    input  wire               [2:0] hsize,
    input  wire               [6:0] hprot,
    input  wire                     hwrite,
    input  wire                     hready,
    input  wire              [31:0] hwdata,
    input  wire  [MASTER_WIDTH-1:0] hmaster,
    output wire                     hreadyout,
    output wire              [31:0] hrdata,
    output wire                     hresp,

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
    output wire                     hclk_qactive_s,
    input  wire                     hclk_qreqn_s,
    output wire                     hclk_qacceptn_s,
    output wire                     hclk_qdeny_s,

    output wire                     pclk_qactive_m,
    input  wire                     pclk_qreqn_m,
    output wire                     pclk_qacceptn_m,
    output wire                     pclk_qdeny_m,

    output wire                     pwr_qactive_s,
    input  wire                     pwr_qreqn_s,
    output wire                     pwr_qacceptn_s,
    output wire                     pwr_qdeny_s,

    input  wire                     ext_gate_req,
    output wire                     ext_gate_ack,
    input  wire                     cfg_gate_resp
  );

  wire   [ADDR_WIDTH-3:0] s_addr;
  wire                    s_trans_valid;
  wire                    s_write;
  wire             [31:0] s_wdata;
  wire              [2:0] s_prot;
  wire              [3:0] s_strb;
  wire [MASTER_WIDTH-1:0] s_master;

  wire            [31:0]  s_rdata;
  wire                    s_resp;

  wire                    s_req_h;
  wire                    s_ack_p;


  wire                    s_active_reg;
  wire                    pwr_ext_wake;
  wire                    m_ext_wake;
  wire                    m_lp_req_n;
  wire                    m_lp_done_n;
  wire                    pwr_lp_req_n;
  wire                    pwr_lp_done_n;


  sie200_ahb5_to_apb_async_s #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .MASTER_WIDTH(MASTER_WIDTH),
    .QS_CLOCK_EN        (QS_CLOCK_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QS_POWER_EN        (QS_POWER_EN),
    .QS_SYNC            (QS_SYNC),
    .EXT_GATE_SYNC      (EXT_GATE_SYNC)
  )
   u_ahb5_to_apb_async_s (
    .hclk                (hclk),
    .hresetn             (hresetn),

    .haddr               (haddr),
    .hsel                (hsel),
    .htrans              (htrans),
    .hsize               (hsize),
    .hprot               (hprot),
    .hwrite              (hwrite),
    .hwdata              (hwdata),
    .hready              (hready),
    .hmaster             (hmaster),
    .hnonsec             (hnonsec),

    .hreadyout           (hreadyout),
    .hrdata              (hrdata),
    .hresp               (hresp),

    .s_addr              (s_addr),
    .s_trans_valid       (s_trans_valid),
    .s_write             (s_write),
    .s_prot              (s_prot),
    .s_strb              (s_strb),
    .s_master            (s_master),
    .s_wdata             (s_wdata),

    .s_rdata             (s_rdata),
    .s_resp              (s_resp),

    .s_req_h             (s_req_h),
    .s_ack_p             (s_ack_p),

    .hclk_qactive_s      (hclk_qactive_s),
    .hclk_qreqn_s        (hclk_qreqn_s),
    .hclk_qacceptn_s     (hclk_qacceptn_s),
    .hclk_qdeny_s        (hclk_qdeny_s),

    .pwr_qactive_s       (pwr_qactive_s),
    .pwr_qreqn_s         (pwr_qreqn_s),
    .pwr_qacceptn_s      (pwr_qacceptn_s),
    .pwr_qdeny_s         (pwr_qdeny_s),

    .ext_gate_req        (ext_gate_req),
    .ext_gate_ack        (ext_gate_ack),
    .cfg_gate_resp       (cfg_gate_resp),

    .s_active_reg        (s_active_reg),
    .pwr_ext_wake        (pwr_ext_wake),
    .m_ext_wake          (m_ext_wake),
    .m_lp_req_n          (m_lp_req_n),
    .m_lp_done_n         (m_lp_done_n),
    .pwr_lp_req_n        (pwr_lp_req_n),
    .pwr_lp_done_n       (pwr_lp_done_n)

    );


  sie200_ahb5_to_apb_async_m #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .MASTER_WIDTH       (MASTER_WIDTH),
    .QS_POWER_EN        (QS_POWER_EN),
    .QM_CLOCK_EN        (QM_CLOCK_EN),
    .QM_SYNC            (QM_SYNC)
  )
   u_ahb5_to_apb_async_m (
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

    .s_req_h             (s_req_h),
    .s_ack_p             (s_ack_p),

    .pclk_qactive_m      (pclk_qactive_m),
    .pclk_qreqn_m        (pclk_qreqn_m),
    .pclk_qacceptn_m     (pclk_qacceptn_m),
    .pclk_qdeny_m        (pclk_qdeny_m),

    .s_active_reg        (s_active_reg),
    .pwr_ext_wake        (pwr_ext_wake),
    .m_ext_wake          (m_ext_wake),
    .m_lp_req_n          (m_lp_req_n),
    .m_lp_done_n         (m_lp_done_n),
    .pwr_lp_req_n        (pwr_lp_req_n),
    .pwr_lp_done_n       (pwr_lp_done_n)

    );














endmodule
