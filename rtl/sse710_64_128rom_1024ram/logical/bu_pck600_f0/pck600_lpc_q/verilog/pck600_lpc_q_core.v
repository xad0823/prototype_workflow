// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_lpc_q_core
#(
  parameter NUM_CTRL_Q_CHL = 2,
  parameter NUM_DEV_Q_CHL = 1
)
(

  input  wire                      clk,
  input  wire                      reset_n,

  input  wire [NUM_CTRL_Q_CHL-1:0] ctrl_qreqn_i,
  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qacceptn_o,
  output wire [NUM_CTRL_Q_CHL-1:0] ctrl_qdeny_o,

  output wire [NUM_DEV_Q_CHL-1:0]  dev_qreqn_o,
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qacceptn_i,
  input  wire [NUM_DEV_Q_CHL-1:0]  dev_qdeny_i,

  output wire                      clk_qactive_syn_o,

  output wire                      int_clken_o

);

localparam Q_STOPPED  = 3'b000;
localparam Q_EXIT     = 3'b001;
localparam Q_RUN      = 3'b010;
localparam Q_REQUEST  = 3'b011;
localparam Q_CONTINUE = 3'b100;


  reg [2:0]                   state;
  reg                         state_en;
  reg [NUM_CTRL_Q_CHL-1:0]    ctrl_qacceptn_r;
  reg [NUM_CTRL_Q_CHL-1:0]    ctrl_qdeny_r;
  reg [NUM_DEV_Q_CHL-1:0]     dev_qreqn_r;
  reg [NUM_DEV_Q_CHL-1:0]     dev_ack_log_r;
  reg                         clk_qactive_r;

  reg [2:0]                   nxt_state;
  reg [NUM_CTRL_Q_CHL-1:0]    nxt_ctrl_qacceptn;
  reg [NUM_CTRL_Q_CHL-1:0]    nxt_ctrl_qdeny;
  reg [NUM_DEV_Q_CHL-1:0]     nxt_dev_qreqn;
  reg [NUM_DEV_Q_CHL-1:0]     nxt_dev_ack_log;
  reg                         nxt_clk_qactive;

  wire                        ctrl_ch_req;
  wire                        ctrl_all_qreqn_deassert;
  wire                        ctrl_req_qrun;
  wire                        dev_exit_all_accept;
  wire                        dev_entry_all_accept;
  wire                        dev_entry_deny;
  wire                        dev_all_qrun;

  reg [NUM_CTRL_Q_CHL-1:0]    req_ctrl_ch_r;
  wire                        req_ctrl_ch_en;

  wire                        int_clken;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state           <= Q_STOPPED;
      ctrl_qacceptn_r <= {NUM_CTRL_Q_CHL{1'b0}};
      ctrl_qdeny_r    <= {NUM_CTRL_Q_CHL{1'b0}};
      dev_qreqn_r     <= {NUM_DEV_Q_CHL{1'b0}};
      dev_ack_log_r   <= {NUM_DEV_Q_CHL{1'b0}};
      clk_qactive_r   <= 1'b0;
    end
    else if(state_en)
    begin
      state           <= nxt_state;
      ctrl_qacceptn_r <= nxt_ctrl_qacceptn;
      ctrl_qdeny_r    <= nxt_ctrl_qdeny;
      dev_qreqn_r     <= nxt_dev_qreqn;
      dev_ack_log_r   <= nxt_dev_ack_log;
      clk_qactive_r   <= nxt_clk_qactive;
    end
  end

  always@*
  begin
    case(state)
    Q_STOPPED:
    begin
      nxt_ctrl_qdeny      = {NUM_CTRL_Q_CHL{1'b0}};
      nxt_dev_ack_log     = dev_ack_log_r[NUM_DEV_Q_CHL-1:0];
      case(ctrl_all_qreqn_deassert)
      1'b0:
      begin
        nxt_state         = Q_STOPPED;
        state_en          = ctrl_ch_req;
        nxt_ctrl_qacceptn = ctrl_qreqn_i[NUM_CTRL_Q_CHL-1:0];
        nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'b0}};
        nxt_clk_qactive   = 1'b0;
      end
      1'b1:
      begin
        nxt_state         = Q_EXIT;
        state_en          = 1'b1;
        nxt_ctrl_qacceptn = ctrl_qacceptn_r[NUM_CTRL_Q_CHL-1:0];
        nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'b1}};
        nxt_clk_qactive   = 1'b1;
      end
      default:
      begin
        nxt_state         = 3'bxxx;
        state_en          = 1'bx;
        nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'bx}};
        nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'bx}};
        nxt_clk_qactive   = 1'bx;
      end
      endcase
    end
    Q_EXIT:
    begin
      nxt_state         = Q_RUN;
      state_en          = dev_exit_all_accept;
      nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'b1}};
      nxt_ctrl_qdeny    = {NUM_CTRL_Q_CHL{1'b0}};
      nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'b1}};
      nxt_dev_ack_log   = dev_ack_log_r[NUM_DEV_Q_CHL-1:0];
      nxt_clk_qactive   = 1'b0;
    end
    Q_RUN:
    begin
      nxt_state         = Q_REQUEST;
      state_en          = ctrl_ch_req;
      nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'b1}};
      nxt_ctrl_qdeny    = {NUM_CTRL_Q_CHL{1'b0}};
      nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'b0}};
      nxt_dev_ack_log   = {NUM_DEV_Q_CHL{1'b0}};
      nxt_clk_qactive   = 1'b1;
    end
    Q_REQUEST:
    begin
      state_en            = dev_entry_all_accept |
                            dev_entry_deny;
      case({dev_entry_all_accept,dev_entry_deny})
      2'b01:
      begin
        nxt_state         = Q_CONTINUE;
        nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'b1}};
        nxt_ctrl_qdeny    = ~req_ctrl_ch_r[NUM_CTRL_Q_CHL-1:0];
        nxt_dev_qreqn     = (~dev_qacceptn_i[NUM_DEV_Q_CHL-1:0] |
                              dev_qdeny_i[NUM_DEV_Q_CHL-1:0]);
        nxt_dev_ack_log   = (~dev_qacceptn_i[NUM_DEV_Q_CHL-1:0] |
                              dev_qdeny_i[NUM_DEV_Q_CHL-1:0] |
                              dev_ack_log_r[NUM_DEV_Q_CHL-1:0]);
        nxt_clk_qactive   = 1'b1;
      end
      2'b10:
      begin
        nxt_state         = Q_STOPPED;
        nxt_ctrl_qacceptn = req_ctrl_ch_r[NUM_CTRL_Q_CHL-1:0];
        nxt_ctrl_qdeny    = {NUM_CTRL_Q_CHL{1'b0}};
        nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'b0}};
        nxt_dev_ack_log   = dev_ack_log_r[NUM_DEV_Q_CHL-1:0];
        nxt_clk_qactive   = 1'b0;
      end
      default:
      begin
        nxt_state         = 3'bxxx;
        nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'bx}};
        nxt_ctrl_qdeny    = {NUM_CTRL_Q_CHL{1'bx}};
        nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'bx}};
        nxt_dev_ack_log   = {NUM_DEV_Q_CHL{1'bx}};
        nxt_clk_qactive   = 1'bx;
      end
      endcase
    end
    Q_CONTINUE:
    begin
      nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'b1}};
      nxt_dev_ack_log   = (~dev_qacceptn_i[NUM_DEV_Q_CHL-1:0] |
                            dev_qdeny_i[NUM_DEV_Q_CHL-1:0] |
                            dev_ack_log_r[NUM_DEV_Q_CHL-1:0]);
      case(dev_all_qrun)
      1'b0:
      begin
        nxt_state       = Q_CONTINUE;
        state_en        = 1'b1;
        nxt_ctrl_qdeny  = ~req_ctrl_ch_r[NUM_CTRL_Q_CHL-1:0];
        nxt_dev_qreqn   = (~dev_qacceptn_i[NUM_DEV_Q_CHL-1:0] |
                            dev_qdeny_i[NUM_DEV_Q_CHL-1:0] |
                            dev_ack_log_r[NUM_DEV_Q_CHL-1:0]);
        nxt_clk_qactive = 1'b1;
      end
      1'b1:
      begin
        nxt_state       = Q_RUN;
        state_en        = ctrl_req_qrun;
        nxt_ctrl_qdeny  = {NUM_CTRL_Q_CHL{1'b0}};
        nxt_dev_qreqn   = {NUM_DEV_Q_CHL{1'b1}};
        nxt_clk_qactive = 1'b0;
      end
      default:
      begin
        nxt_state       = 3'bxxx;
        state_en        = 1'bx;
        nxt_ctrl_qdeny  = {NUM_CTRL_Q_CHL{1'bx}};
        nxt_dev_qreqn   = {NUM_DEV_Q_CHL{1'bx}};
        nxt_clk_qactive = 1'bx;
      end
      endcase
    end
    default:
    begin
      nxt_state         = 3'bxxx;
      state_en          = 1'bx;
      nxt_ctrl_qacceptn = {NUM_CTRL_Q_CHL{1'bx}};
      nxt_ctrl_qdeny    = {NUM_CTRL_Q_CHL{1'bx}};
      nxt_dev_qreqn     = {NUM_DEV_Q_CHL{1'bx}};
      nxt_dev_ack_log   = {NUM_DEV_Q_CHL{1'bx}};
      nxt_clk_qactive   = 1'bx;
    end
    endcase
  end

  assign ctrl_ch_req = |(ctrl_qreqn_i ^ ctrl_qacceptn_r);

  assign ctrl_all_qreqn_deassert = (&ctrl_qreqn_i);

  assign ctrl_req_qrun = &(req_ctrl_ch_r | ctrl_qreqn_i);

  assign dev_exit_all_accept = (&dev_qacceptn_i);

  assign dev_entry_all_accept = ~(|dev_qacceptn_i);

  assign dev_entry_deny = (|dev_qdeny_i);

  assign dev_all_qrun   = &(dev_qacceptn_i & (~dev_qdeny_i) & nxt_dev_ack_log);


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      req_ctrl_ch_r <= {NUM_CTRL_Q_CHL{1'b0}};
    end
    else if(req_ctrl_ch_en)
    begin
      req_ctrl_ch_r <= ctrl_qreqn_i;
    end
  end

  assign req_ctrl_ch_en = (state == Q_RUN) & ctrl_ch_req;


  assign int_clken = ((state == Q_STOPPED) & ctrl_ch_req) |
                     ((state == Q_RUN)     & ctrl_ch_req) |
                     ((state != Q_STOPPED) & (state != Q_RUN));


  assign ctrl_qacceptn_o   = ctrl_qacceptn_r;
  assign ctrl_qdeny_o      = ctrl_qdeny_r;

  assign dev_qreqn_o       = dev_qreqn_r;

  assign clk_qactive_syn_o = clk_qactive_r;

  assign int_clken_o       = int_clken;

endmodule

