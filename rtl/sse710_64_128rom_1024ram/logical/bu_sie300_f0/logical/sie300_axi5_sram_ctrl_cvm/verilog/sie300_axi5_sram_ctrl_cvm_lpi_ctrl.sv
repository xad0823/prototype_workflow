//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Mon Jul 8 16:16:13 2019 +0100
//
//      Revision            : 28b24c60
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_lpi_ctrl
(
  input  wire logic                                           clk,
  input  wire logic                                           resetn,

  output      logic                                           clk_qactive,
  input  wire logic                                           clk_qreqn,
  output      logic                                           clk_qacceptn,
  output      logic                                           clk_qdeny,

  output      logic                                           pwr_qactive,
  input  wire logic                                           pwr_qreqn,
  output      logic                                           pwr_qacceptn,
  output      logic                                           pwr_qdeny,

  input  wire logic                                           ext_gt_qreqn,
  output      logic                                           ext_gt_qacceptn,

  input  wire logic                                           arvalid,
  input  wire logic                                           rvalid,
  input  wire logic                                           awvalid,
  input  wire logic                                           wvalid,
  input  wire logic                                           bvalid,

  input  wire logic                                           awq_empty,
  input  wire logic                                           wq_empty,
  input  wire logic                                           bq_empty,
  input  wire logic                                           arq_empty,
  input  wire logic                                           rq_empty,
  input  wire logic                                           rq_vld,
  input  wire logic                                           awakeup,
  input  wire logic                                           resp_fsm_act,
  output      logic                                           ext_stall,
  output      logic                                           stopped,
  output      logic                                           sel_resp_path,
  output      logic                                           resp_fsm_en
);

  typedef enum logic [1:0] {
    ST_STOP         = 2'b00,
    ST_RUN          = 2'b01,
    ST_DENY         = 2'b11,
    ST_UNUSED       = 2'b10,
    ST_DEFAULT_X    = 'x
  } c_p_state_t;
  typedef enum logic [1:0] {
    ST_GATED        = 2'b00,
    ST_FINISH_GATE  = 2'b10,
    ST_OPEN         = 2'b01,
    ST_START_GATE   = 2'b11,
    ST_DEFAULT_X_EXT= 'x
  } ext_state_t;

  c_p_state_t                                     qclk_state_nxt;
  c_p_state_t                                     qclk_state;
  c_p_state_t                                     qpwr_state_nxt;
  c_p_state_t                                     qpwr_state;
  ext_state_t                                     qext_state_nxt;
  ext_state_t                                     qext_state;
  logic                                           axi_act;
  logic                                           int_act;
  logic                                           clk_deny_cond;
  logic                                           clk_fsm_act;
  logic                                           pwr_fsm_act;
  logic                                           ext_fsm_act;
  logic                                           pwr_q_ch_act;
  logic                                           clk_qreqn_int;
  logic                                           pwr_qreqn_int;
  logic                                           ext_qreqn_int;
  logic                                           ext_qreqn;
  logic                                           ext_qacceptn;


  sie300_sync u_qclk_sync (
    .clk      (clk              ),
    .reset_n  (resetn           ),
    .d        (clk_qreqn        ),
    .q        (clk_qreqn_int    )
  );

  assign pwr_qreqn_int = pwr_qreqn;


  assign ext_qreqn_int = ext_qreqn;


  always_comb begin : comb_qclk_state_nxt
    qclk_state_nxt = qclk_state;
    case (qclk_state)
      ST_STOP:  if (clk_qreqn_int) begin
                  qclk_state_nxt = ST_RUN;
                end

      ST_RUN:   if (!clk_qreqn_int) begin
                  if (clk_fsm_act) begin
                    qclk_state_nxt = ST_DENY;
                  end
                  else begin
                    qclk_state_nxt = ST_STOP;
                  end
                end

      ST_DENY:  if (clk_qreqn_int) begin
                  qclk_state_nxt = ST_RUN;
                end

      default:  qclk_state_nxt = ST_DEFAULT_X;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn) begin : reg_qclk_state
    if (~resetn) begin
      qclk_state <= ST_STOP;
    end
    else if (qclk_state != qclk_state_nxt) begin
      qclk_state <= qclk_state_nxt;
    end
  end

  assign clk_qdeny    = qclk_state[1];
  assign clk_qacceptn = qclk_state[0];

  always_comb begin : comb_qpwr_state_nxt
    qpwr_state_nxt = qpwr_state;
    case (qpwr_state)
      ST_STOP:  if (pwr_qreqn_int) begin
                  qpwr_state_nxt = ST_RUN;
                end

      ST_RUN:   if (!pwr_qreqn_int) begin
                  if (pwr_fsm_act) begin
                    qpwr_state_nxt = ST_DENY;
                  end
                  else begin
                    qpwr_state_nxt = ST_STOP;
                  end
                end

      ST_DENY:  if (pwr_qreqn_int) begin
                  qpwr_state_nxt = ST_RUN;
                end

      default:  qpwr_state_nxt = ST_DEFAULT_X;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn) begin : reg_qpwr_state
    if (~resetn) begin
      qpwr_state <= ST_STOP;
    end
    else if (qpwr_state != qpwr_state_nxt) begin
      qpwr_state <= qpwr_state_nxt;
    end
  end

  assign pwr_qdeny    = qpwr_state[1];
  assign pwr_qacceptn = qpwr_state[0];

  always_comb begin : comb_qext_state_nxt
    qext_state_nxt = qext_state;
    case (qext_state)
      ST_GATED:       if (ext_qreqn_int) begin
                        qext_state_nxt = ST_FINISH_GATE;
                      end

      ST_FINISH_GATE: if (~resp_fsm_act) begin
                        qext_state_nxt = ST_OPEN;
                      end

      ST_OPEN:        if (~ext_qreqn_int) begin
                        qext_state_nxt = ST_START_GATE;
                      end

      ST_START_GATE:  if (~ext_fsm_act) begin
                        qext_state_nxt = ST_GATED;
                      end

      default:        qext_state_nxt = ST_DEFAULT_X_EXT;
    endcase
  end

  always_ff @ (posedge clk or negedge resetn) begin : reg_qext_state
    if (~resetn)
      qext_state <= ST_GATED;
    else if (qext_state != qext_state_nxt)
      qext_state <= qext_state_nxt;
  end

  assign ext_qacceptn   = qext_state[0];


  assign axi_act        = arvalid | awvalid | wvalid | bvalid | rvalid;

  assign clk_fsm_act    = axi_act | clk_deny_cond;
  assign pwr_fsm_act    = axi_act | pwr_qactive;
  assign ext_fsm_act    = int_act;


  sie300_or_tree  #(
    .NUM_OR_INPUTS ( 7 )
  ) u_or_tree_int_act (
    .or_inputs  ( { ~awq_empty      ,
                    ~wq_empty       ,
                    ~bq_empty       ,
                    ~arq_empty      ,
                    ~rq_empty       ,
                    rq_vld          ,
                    resp_fsm_act    } ),
    .or_output  ( int_act           )
  );

  logic pwr_q_xor;
  sie300_arm_xor2 u_xor2_pwr_q_xor (
    .a_i        ( pwr_qreqn       ),
    .b_i        ( pwr_qacceptn    ),
    .y_o        ( pwr_q_xor       )
  );
  sie300_arm_or2 u_or2_pwr_q_ch_act (
    .a_i        ( pwr_q_xor       ),
    .b_i        ( pwr_qdeny       ),
    .y_o        ( pwr_q_ch_act    )
  );

  logic ext_q_ch_act;
  sie300_arm_xor2 u_xor2_ext_q_ch_act (
    .a_i        ( ext_qreqn       ),
    .b_i        ( ext_qacceptn    ),
    .y_o        ( ext_q_ch_act    )
  );

  sie300_or_tree  #(
    .NUM_OR_INPUTS ( 2 )
  ) u_or_tree_pwr_qactive (
    .or_inputs ( {awakeup       ,
                  int_act       } ),
    .or_output ( pwr_qactive      )
  );

  sie300_or_tree  #(
    .NUM_OR_INPUTS ( 3 )
  ) u_or_tree_clk_qactive (
    .or_inputs ( {pwr_qactive   ,
                  pwr_q_ch_act  ,
                  ext_q_ch_act  } ),
    .or_output ( clk_qactive      )
  );

  assign clk_deny_cond    = pwr_qactive
                          | (ext_qreqn_int ^ ext_qacceptn)
                          | (pwr_qreqn_int ^ pwr_qacceptn) | pwr_qdeny;

  assign ext_stall        = qclk_state == ST_STOP
                          | qpwr_state == ST_STOP
                          | qext_state == ST_GATED
                          | qext_state == ST_START_GATE
                          | qext_state == ST_FINISH_GATE;

  assign stopped          = qpwr_state == ST_STOP
                          | qext_state == ST_GATED;

  assign ext_gt_qacceptn  = ext_qacceptn;
  assign ext_qreqn        = ext_gt_qreqn;

  assign resp_fsm_en      = qext_state == ST_GATED
                          & qclk_state != ST_STOP
                          & qpwr_state != ST_STOP;


  assign sel_resp_path    = qext_state == ST_GATED
                          | qext_state == ST_FINISH_GATE;

endmodule
