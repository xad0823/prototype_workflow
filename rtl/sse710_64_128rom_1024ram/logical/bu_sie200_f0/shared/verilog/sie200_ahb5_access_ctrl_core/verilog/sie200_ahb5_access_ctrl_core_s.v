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

module sie200_ahb5_access_ctrl_core_s #(
  parameter                       QCLK_SYNC     =  0,
  parameter                       QS_CLOCK_EN   =  1,
  parameter                       QM_CLOCK_EN   =  1,
  parameter                       QS_POWER_EN   =  1,
  parameter                       QS_SYNC       =  0,
  parameter                       EXT_GATE_SYNC =  0
)
(
  input  wire                     hclk_s,
  input  wire                     hresetn_s,

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

  output wire                     brg_pwr_req_s,
  input  wire                     brg_pwr_ack_s,

  output wire                     hold_en,
  input  wire                     pend_trans,
  input  wire                     s_active,


  output wire                     s_active_reg,
  output wire                     pwr_ext_wake,
  input  wire                     m_ext_wake,
  input  wire                     m_lp_req_n,
  output wire                     m_lp_done_n,

  output wire                     pwr_lp_req_n,
  input  wire                     pwr_lp_done_n


);


wire pwr_qreqn_s_sync;
wire pwr_wake_up;
wire pwr_dev_active;
wire pwr_lp_request;
wire pwr_lp_done;
wire pwr_dev_run;
wire pwr_lp_hold_req;

wire pwr_ext_wake_i;
wire pwr_ext_wake_xor;

wire pwr_lp_request_n;
wire pwr_lp_done_n_sync;

wire q_hold_req;

wire hclk_qreqn_s_sync;
wire hclk_wake_up;
wire hclk_lp_request;
wire hclk_lp_done;
wire hclk_dev_active;

wire m_lp_request;
wire m_lp_req_n_sync;

wire s_lp_request;
wire s_lp_done;
wire ext_gate_req_sync;
wire s_lp_hold_req;

reg [2:0] s_lp_req_dly;
reg       s_active_reg_d;

reg       ext_gate_hold_req_d;
wire      ext_gate_hold_req;
wire      ext_gate_hold_ack;
wire      q_hold_ack_reg;
wire      q_hold_ack;

wire      m_lp_request_d;
wire      m_lp_denied;
wire      m_lp_denied_src;
wire      m_lp_denied_reg;
wire      m_lp_hold_req;

wire      s_active_reg_i;


generate
  if(QS_CLOCK_EN == 1 || QS_POWER_EN == 1 || QM_CLOCK_EN == 1) begin: S_ACTIVE_REG_PRESENT
    sie200_flop u_launch_s_active (.clk(hclk_s), .reset_n(hresetn_s), .d(s_active), .q(s_active_reg_i));
  end
  else begin: S_ACTIVE_REG_NOT_PRESENT
    wire unused = s_active;
    assign s_active_reg_i = 1'b0;
  end
endgenerate
assign s_active_reg  = s_active_reg_i;

generate


  if(QS_POWER_EN == 1) begin: Q_PWR_S_PRESENT

    sie200_sync   u_sync_pwr_qreq_n (.clk(hclk_s), .reset_n(hresetn_s), .d(pwr_qreqn_s), .q(pwr_qreqn_s_sync));

    sie200_lpislave u_q_pwr_s(
      .clk          (hclk_s),
      .reset_n      (hresetn_s),

      .qreq_sync_n  (pwr_qreqn_s_sync),
      .qaccept_n    (pwr_qacceptn_s),
      .qdeny        (pwr_qdeny_s),
      .qactive      (pwr_qactive_s),

      .wake_up      (pwr_wake_up),
      .lp_request   (pwr_lp_request),
      .dev_active   (pwr_dev_active),
      .lp_done      (pwr_lp_done),
      .dev_run      (pwr_dev_run),
      .cg_en        ( )
      );

    assign  pwr_wake_up        = s_active_reg_i,
            pwr_dev_active     = s_active_reg_i;

    sie200_xor u_xor_pwr_ext_wake (.in_a(pwr_qreqn_s), .in_b(pwr_qacceptn_s),   .out_y(pwr_ext_wake_xor));
    sie200_or  u_or_pwr_ext_wake  (.in_a(pwr_qdeny_s), .in_b(pwr_ext_wake_xor), .out_y(pwr_ext_wake_i));


    assign  pwr_lp_request_n   = ~pwr_lp_request,
            pwr_lp_done        = (~pwr_lp_done_n_sync ^ brg_pwr_ack_s) ? ~pwr_lp_request : ~pwr_lp_done_n_sync;

    assign  brg_pwr_req_s      = pwr_lp_request;

    if(QCLK_SYNC == 0) begin: QCLK_ASYNCHRONOUS

      sie200_sync   u_sync_pwr_lp_done   (.clk(hclk_s), .reset_n(hresetn_s), .d(pwr_lp_done_n), .q(pwr_lp_done_n_sync));
      sie200_launch u_launch_pwr_lp_req  (.clk(hclk_s), .reset_n(hresetn_s), .d(pwr_lp_request_n), .q(pwr_lp_req_n));


    end
    else begin: QCLK_SYNCHRONOUS_BUT_POWER_BOUNDARY

      sie200_flop   u_catch_pwr_lp_done (.clk(hclk_s), .reset_n(hresetn_s), .d(pwr_lp_done_n),.q(pwr_lp_done_n_sync));

      assign  pwr_lp_req_n = pwr_lp_request_n;

    end

  end
  else begin : Q_PWR_S_NOT_PRESENT

    assign  pwr_qactive_s     = 1'b1,
            pwr_qacceptn_s    = 1'b1,
            pwr_qdeny_s       = 1'b0;

    assign  pwr_lp_request    = 1'b0,
            pwr_lp_done       = 1'b0,
            pwr_lp_req_n      = 1'b1,
            pwr_ext_wake_i    = 1'b0,
            pwr_dev_run       = 1'b1;

    assign  brg_pwr_req_s     = 1'b0;

  end





  if(QS_CLOCK_EN == 1 || QS_POWER_EN == 1) begin: Q_HCLK_S_PRESENT

    if(QS_SYNC == 0) begin : QREQN_ASYNC
      sie200_sync   u_syn_qreq_n (.clk(hclk_s), .reset_n(hresetn_s), .d(hclk_qreqn_s), .q(hclk_qreqn_s_sync));
    end
    else begin: QREQN_SYNC
      assign hclk_qreqn_s_sync = hclk_qreqn_s;
    end


    sie200_lpislave u_q_hclk_s(
      .clk          (hclk_s),
      .reset_n      (hresetn_s),

      .qreq_sync_n  (hclk_qreqn_s_sync),
      .qaccept_n    (hclk_qacceptn_s),
      .qdeny        (hclk_qdeny_s),
      .qactive      (hclk_qactive_s),

      .wake_up      (hclk_wake_up),
      .lp_request   (hclk_lp_request),
      .dev_active   (hclk_dev_active),
      .lp_done      (hclk_lp_done),
      .dev_run      ( ),
      .cg_en        ( )
      );



    sie200_or u_or_hclk_wake_up (.in_a(m_ext_wake), .in_b(pwr_ext_wake_i), .out_y(hclk_wake_up));



    assign hclk_dev_active  = s_active_reg_i,
           hclk_lp_done     = s_lp_done,
           s_lp_request     = hclk_lp_request;

    if(QS_POWER_EN == 0) begin: UNUSED_Q_PWR_S_NOT_PRESENT

      localparam UNUSED_WIDTH           = 3;
      wire  [UNUSED_WIDTH-1:0] unused   = {pwr_lp_done_n, pwr_qreqn_s, brg_pwr_ack_s};

    end
  end
  else begin: Q_HCLK_S_NOT_PRESENT

    assign  hclk_qactive_s    = 1'b1,
            hclk_qacceptn_s   = 1'b1,
            hclk_qdeny_s      = 1'b0,
            s_lp_request      = 1'b0;

    localparam UNUSED_WIDTH           = 7;
    wire  [UNUSED_WIDTH-1:0] unused   = {pwr_lp_done_n, m_ext_wake, hclk_qreqn_s, pwr_qreqn_s, brg_pwr_ack_s, s_lp_request, s_lp_done};

  end



  if(QM_CLOCK_EN == 0 && QS_POWER_EN == 0) begin: M_LP_REQ_DOES_NOT_EXIST

    assign  m_lp_req_n_sync     = 1'b1;
    wire unused                 = m_lp_req_n;
    assign m_lp_denied_src      = s_active_reg_i;

  end
  else if(QCLK_SYNC == 0) begin: M_LP_REQ_QCLK_ASYNCHRONOUS

    sie200_sync   u_sync_m_lp_req    (.clk(hclk_s), .reset_n(hresetn_s), .d(m_lp_req_n), .q(m_lp_req_n_sync));
    assign m_lp_denied_src      = s_active_reg_i;

  end
  else begin: M_LP_REQ_QCLK_SYNCHRONOUS

    sie200_flop   u_catch_m_lp_req  (.clk(hclk_s), .reset_n(hresetn_s), .d(m_lp_req_n), .q(m_lp_req_n_sync));
    assign m_lp_denied_src      = s_active_reg_i | s_active_reg_d;

    always @ (posedge hclk_s or negedge hresetn_s) begin
      if(~hresetn_s) begin
        s_active_reg_d  <= 1'b0;
      end
      else begin
        s_active_reg_d  <= s_active_reg_i;
      end
    end
  end


  if(EXT_GATE_SYNC == 0) begin : EXTERNAL_GATE_REQ_ASYNCHRONOUS
    sie200_sync   u_sync_ext_gate_req    (.clk(hclk_s), .reset_n(hresetn_s), .d(ext_gate_req), .q(ext_gate_req_sync));
    sie200_launch u_launch_ext_gate_ack  (.clk(hclk_s), .reset_n(hresetn_s), .d(ext_gate_hold_req), .q(ext_gate_ack));
    assign ext_gate_hold_ack = ext_gate_hold_req | ext_gate_hold_req_d;


    if(QS_CLOCK_EN == 0 && QS_POWER_EN == 0) begin: EXT_GATE_REQ_BUT_NO_QS_CLOCK

      assign s_lp_done          = 1'b0,
             s_lp_hold_req      = 1'b0;

    end
    else begin: EXT_GATE_REQ_DELAY_FLOPS

      always @ (posedge hclk_s or negedge hresetn_s) begin
        if(~hresetn_s) begin
          s_lp_req_dly    <= 3'b111;
        end
        else begin
          if(s_lp_request) begin
            s_lp_req_dly    <= 3'b111;
          end
          else begin
            s_lp_req_dly    <= {s_lp_req_dly[1:0],1'b0};
          end
        end
      end
      assign s_lp_done          = s_lp_request | s_lp_req_dly[2],
             s_lp_hold_req      = s_lp_done;

    end

  end
  else begin : EXTERNAL_GATE_REQ_SYNC

    assign  s_lp_done           = s_lp_request,
            s_lp_hold_req       = s_lp_done,
            ext_gate_req_sync   = ext_gate_req,
            ext_gate_ack        = ext_gate_hold_req,
            ext_gate_hold_ack   = ext_gate_ack;
  end

endgenerate


assign m_lp_request = ~m_lp_req_n_sync;
assign m_lp_done_n  = m_lp_req_n_sync;




always @ (posedge hclk_s or negedge hresetn_s) begin
  if(~hresetn_s) begin
    ext_gate_hold_req_d <= 1'b0;
  end
  else begin
    ext_gate_hold_req_d <= ext_gate_hold_req;
  end
end

generate
  if(QS_CLOCK_EN == 1 || QS_POWER_EN == 1 || QM_CLOCK_EN == 1) begin: Q_HOLD_ACK_REG_PRESENT
    reg q_hold_ack_reg_r;
    always @ (posedge hclk_s or negedge hresetn_s) begin
      if(~hresetn_s) begin
        q_hold_ack_reg_r <= 1'b0;
      end
      else begin
        q_hold_ack_reg_r <= q_hold_ack;
      end
    end
    assign q_hold_ack_reg = q_hold_ack_reg_r;
  end
  else begin: Q_HOLD_ACK_REG_NOT_PRESENT
    assign q_hold_ack_reg = 1'b0;
  end

  if(QM_CLOCK_EN == 1 || QS_POWER_EN == 1) begin: M_LP_REQ_QM_CLOCK_PRESENT
    reg m_lp_request_d_r;
    reg m_lp_denied_reg_r;
    always @ (posedge hclk_s or negedge hresetn_s) begin
      if(~hresetn_s) begin
        m_lp_request_d_r <= 1'b0;
        m_lp_denied_reg_r <= 1'b0;
      end
      else begin
        m_lp_request_d_r <= m_lp_request;
        if(m_lp_request) begin
          if(~m_lp_request_d) begin
            m_lp_denied_reg_r <= m_lp_denied_src & ~pwr_lp_hold_req;
          end
        end
        else begin
          m_lp_denied_reg_r <= 1'b0;
        end
      end
    end

    assign m_lp_request_d  = m_lp_request_d_r;
    assign m_lp_denied_reg = m_lp_denied_reg_r;


  end
  else begin: M_LP_REQ_NOT_PRESENT
    assign m_lp_request_d  = 1'b0;
    assign m_lp_denied_reg = 1'b0;
  end
endgenerate

assign m_lp_denied = (m_lp_request & ~m_lp_request_d & m_lp_denied_src & ~pwr_lp_hold_req) | m_lp_denied_reg;
assign m_lp_hold_req = m_lp_request & ~m_lp_denied;
assign pwr_lp_hold_req = pwr_lp_request | pwr_lp_done | !pwr_dev_run;
assign ext_gate_hold_req = ext_gate_req_sync & (q_hold_ack | ~pend_trans | ext_gate_hold_req_d) &
                           (!pwr_lp_done | (EXT_GATE_SYNC ? pwr_dev_run :
                                                           (pwr_dev_run & ~(!pwr_qdeny_s & pwr_lp_request & !s_active_reg_i & pwr_lp_done))));
assign pwr_ext_wake = pwr_ext_wake_i;


assign q_hold_req   = m_lp_hold_req | pwr_lp_hold_req | s_lp_hold_req;
assign q_hold_ack   = q_hold_req & (~pend_trans | q_hold_ack_reg);

assign hold_en      = q_hold_ack | ext_gate_hold_ack;
















endmodule
