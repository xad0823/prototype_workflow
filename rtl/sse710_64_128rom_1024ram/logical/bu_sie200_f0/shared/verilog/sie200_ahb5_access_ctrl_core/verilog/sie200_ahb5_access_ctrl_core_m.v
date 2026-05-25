// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Jun 1 08:30:31 2017 +0100
//
//      Revision            : ff06b35
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl_core_m #(
  parameter                       QCLK_SYNC     =  0,
  parameter                       QS_POWER_EN   =  1,
  parameter                       QM_CLOCK_EN   =  1,
  parameter                       QM_SYNC       =  0
)
(
  input  wire                     hclk_m,
  input  wire                     hresetn_m,

  output wire                     hclk_qactive_m,
  input  wire                     hclk_qreqn_m,
  output wire                     hclk_qacceptn_m,
  output wire                     hclk_qdeny_m,

  output wire                     brg_pwr_req_m,
  input  wire                     brg_pwr_ack_m,

  input  wire                     s_active_reg,
  input  wire                     pwr_ext_wake,
  output wire                     m_ext_wake,

  output wire                     m_lp_req_n,
  input  wire                     m_lp_done_n,

  input  wire                     pwr_lp_req_n,
  output wire                     pwr_lp_done_n
);



wire    wake_up;
wire    dev_active_sync;
wire    lp_done_n_sync;
wire    pwr_lp_req_n_sync;
wire    lp_request;
wire    lp_request_n;
wire    lp_done_n_reg;
wire    lp_done;
wire    hclk_qreqn_m_sync;

wire    us_pwr_req;
wire    us_pwr_ack;
wire    us_pwr_ack_n;
wire    us_pwr_ack_launch_n;

wire    m_ext_wake_xor;
wire    m_ext_wake_i;


generate
  if(QM_CLOCK_EN == 1 || QS_POWER_EN == 1) begin: Q_HCLK_M_PRESENT

    if(QM_SYNC == 0) begin : QREQN_ASYNC
      sie200_sync   u_sync_qreq_n (.clk(hclk_m), .reset_n(hresetn_m), .d(hclk_qreqn_m), .q(hclk_qreqn_m_sync));
    end
    else begin: QREQN_SYNC
      assign hclk_qreqn_m_sync = hclk_qreqn_m;
    end

    sie200_lpislave_ds # (.QS_POWER_EN(QS_POWER_EN)) u_q_hclk_m(
      .clk          (hclk_m),
      .reset_n      (hresetn_m),

      .qreq_sync_n  (hclk_qreqn_m_sync),
      .qaccept_n    (hclk_qacceptn_m),
      .qdeny        (hclk_qdeny_m),
      .qactive      (hclk_qactive_m),

      .us_pwr_req   (us_pwr_req),
      .us_pwr_ack   (us_pwr_ack),
      .ds_pwr_req   (brg_pwr_req_m),
      .ds_pwr_ack   (brg_pwr_ack_m),

      .wake_up      (wake_up),
      .lp_request   (lp_request),
      .dev_active   (dev_active_sync),
      .lp_done      (lp_done),
      .dev_run      ( ),
      .cg_en        ( )
      );


    sie200_xor    u_xor_m_ext_wake (.in_a(hclk_qreqn_m), .in_b(hclk_qacceptn_m), .out_y(m_ext_wake_xor));

    if(QS_POWER_EN) begin: POWER_ISOLATION_NEEDED
      sie200_and    u_and_m_ext_wake (.in_a(~brg_pwr_req_m), .in_b(m_ext_wake_xor), .out_y(m_ext_wake_i));
    end
    else begin: NO_POWER_ISOLATION_NEEDED
      assign m_ext_wake_i = m_ext_wake_xor;
    end

    sie200_or     u_or_wake_up  (.in_a(s_active_reg), .in_b(pwr_ext_wake), .out_y(wake_up));

    sie200_flop   u_lp_done_dly (.clk(hclk_m), .reset_n(hresetn_m), .d(lp_done_n_sync), .q(lp_done_n_reg));

    assign us_pwr_req     = ~pwr_lp_req_n_sync;

    assign pwr_lp_done_n  = us_pwr_ack_launch_n;
    assign us_pwr_ack_n   = ~us_pwr_ack;
    assign lp_done        = ~lp_done_n_reg;
    assign lp_request_n   = ~lp_request;


    if(QCLK_SYNC == 0) begin: QCLK_ASYNCHRONOUS

      sie200_sync   u_sync_dev_active (.clk(hclk_m), .reset_n(hresetn_m), .d(s_active_reg), .q(dev_active_sync));
      sie200_sync   u_sync_lp_done    (.clk(hclk_m), .reset_n(hresetn_m), .d(m_lp_done_n),  .q(lp_done_n_sync));
      sie200_launch u_launch_lp_req   (.clk(hclk_m), .reset_n(hresetn_m), .d(lp_request_n),  .q(m_lp_req_n));

      if (QS_POWER_EN == 1 ) begin : QCLK_ASYNC_AND_POWER_BOUNDARY
        sie200_flop   u_launch_pwr_ack  (.clk(hclk_m), .reset_n(hresetn_m), .d(us_pwr_ack_n), .q(us_pwr_ack_launch_n));
        sie200_sync   u_sync_pwr_lp_req (.clk(hclk_m), .reset_n(hresetn_m), .d(pwr_lp_req_n), .q(pwr_lp_req_n_sync));
      end
      else begin: QCLK_ASYNC_AND_NO_POWER_BOUNDARY
        assign pwr_lp_req_n_sync    = 1'b1,
               us_pwr_ack_launch_n  = us_pwr_ack_n;
        wire   unused               = pwr_lp_req_n;
      end

    end
    else if (QS_POWER_EN == 1 ) begin: QCLK_SYNCHRONOUS_BUT_POWER_BOUNDARY

      sie200_flop   u_catch_dev_active  (.clk(hclk_m), .reset_n(hresetn_m), .d(s_active_reg), .q(dev_active_sync));
      sie200_flop   u_catch_lp_done     (.clk(hclk_m), .reset_n(hresetn_m), .d(m_lp_done_n),  .q(lp_done_n_sync));
      sie200_flop   u_catch_pwr_lp_req  (.clk(hclk_m), .reset_n(hresetn_m), .d(pwr_lp_req_n), .q(pwr_lp_req_n_sync));

      assign  m_lp_req_n          = lp_request_n;
      assign  us_pwr_ack_launch_n = us_pwr_ack_n;

    end
    else begin: QCLK_SYNCHRONOUS_AND_NO_POWER_BOUNDARY

      assign  dev_active_sync     = s_active_reg,
              lp_done_n_sync      = m_lp_done_n,
              pwr_lp_req_n_sync   = pwr_lp_req_n;

      assign  m_lp_req_n          = lp_request_n;
      assign  us_pwr_ack_launch_n = us_pwr_ack_n;
    end
  end
  else begin: Q_HCLK_M_NOT_PRESENT

    assign  hclk_qactive_m    = 1'b1,
            hclk_qacceptn_m   = 1'b1,
            hclk_qdeny_m      = 1'b0;


    assign  m_lp_req_n        = 1'b1,
            pwr_lp_done_n     = 1'b1,
            m_ext_wake_i      = 1'b0,
            brg_pwr_req_m     = 1'b0;

    localparam UNUSED_WIDTH           = 8;
    wire  [UNUSED_WIDTH-1:0] unused   = {hclk_m, hresetn_m, s_active_reg, pwr_ext_wake, m_lp_done_n, pwr_lp_req_n, hclk_qreqn_m, brg_pwr_ack_m};

  end


assign m_ext_wake = m_ext_wake_i;


endgenerate


endmodule
