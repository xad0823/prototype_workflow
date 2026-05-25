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


module pck600_lpd_q_sequencer_core
#(
  parameter NUM_QCHL = 2
)
(
  input  wire                 clk,
  input  wire                 reset_n,

  input  wire                 ctrl_qreqn_i,
  output wire                 ctrl_qacceptn_o,
  output wire                 ctrl_qdeny_o,

  output wire [NUM_QCHL-1:0]  dev_qreqn_o,
  input  wire [NUM_QCHL-1:0]  dev_qacceptn_i,
  input  wire [NUM_QCHL-1:0]  dev_qdeny_i,

  input  wire                 active_deny_i,

  output wire                 int_clken_o

);

localparam Q_STOPPED      = 3'b000;
localparam Q_EXIT         = 3'b001;
localparam Q_RUN          = 3'b010;
localparam Q_REQUEST      = 3'b011;
localparam Q_CONTINUE     = 3'b100;
localparam Q_DENIED       = 3'b101;
localparam Q_REQ_WAIT     = 3'b110;
localparam Q_REQ_CONTINUE = 3'b111;
localparam SHIFT_WIDTH    = NUM_QCHL;


  reg  [2:0]                  state;
  reg  [2:0]                  nxt_state;
  reg                         state_en;
  reg                         dev_qreqn_en;

  reg  [SHIFT_WIDTH-1:0]      sr_r;
  reg  [SHIFT_WIDTH-1:0]      nxt_sr;
  wire                        sr_en;
  wire [SHIFT_WIDTH-1:0]      nxt_sr_mask;

  reg                         shift_left;
  reg                         shift_right;

  wire                        dev_qacceptn_sel;
  wire                        dev_qdeny_sel;

  reg  [NUM_QCHL-1:0]         active_deny_channel_r;
  reg                         active_deny_channel_en;
  wire                        dev_qacceptn_sel_active_deny;
  wire                        dev_qdeny_sel_active_deny;

  reg  [NUM_QCHL-1:0]         dev_qreqn_r;
  reg                         ctrl_qacceptn_r;
  reg                         ctrl_qdeny_r;
  reg  [NUM_QCHL-1:0]         nxt_dev_qreqn;
  reg                         nxt_ctrl_qacceptn;
  reg                         nxt_ctrl_qdeny;

  wire                        int_clken;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state           <= Q_STOPPED;
      ctrl_qacceptn_r <= 1'b0;
      ctrl_qdeny_r    <= 1'b0;
    end
    else if(state_en)
    begin
      state           <= nxt_state;
      ctrl_qacceptn_r <= nxt_ctrl_qacceptn;
      ctrl_qdeny_r    <= nxt_ctrl_qdeny;
    end
  end

  always@*
  begin
    case(state)
    Q_STOPPED:
    begin
      nxt_state              = Q_EXIT;
      state_en               = ctrl_qreqn_i;
      nxt_ctrl_qacceptn      = 1'b0;
      nxt_ctrl_qdeny         = 1'b0;
      nxt_dev_qreqn          = {{NUM_QCHL-1{1'b0}},1'b1};
      dev_qreqn_en           = ctrl_qreqn_i;
      shift_left             = 1'b0;
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_EXIT:
    begin
      nxt_state              = Q_RUN;
      state_en               = sr_r[NUM_QCHL-1] & dev_qacceptn_sel;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = 1'b0;
      nxt_dev_qreqn          = dev_qreqn_r[NUM_QCHL-1:0] | nxt_sr[NUM_QCHL-1:0];
      dev_qreqn_en           = dev_qacceptn_sel;
      shift_left             = dev_qacceptn_sel & ~sr_r[NUM_QCHL-1];
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_RUN:
    begin
      nxt_state              = (active_deny_i)? Q_DENIED:Q_REQUEST;
      state_en               = ~ctrl_qreqn_i;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = active_deny_i;
      nxt_dev_qreqn          = (active_deny_i)? {NUM_QCHL{1'b1}}:{1'b0,{NUM_QCHL-1{1'b1}}};
      dev_qreqn_en           = ~ctrl_qreqn_i & ~active_deny_i;
      shift_left             = 1'b0;
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_REQUEST:
    begin
      nxt_state              = (dev_qdeny_sel | (~dev_qacceptn_sel & active_deny_i))? Q_CONTINUE:
                               ((active_deny_i)? Q_REQ_WAIT:Q_STOPPED);
      state_en               = (sr_r[0] & ~dev_qacceptn_sel) | dev_qdeny_sel | active_deny_i;
      nxt_ctrl_qacceptn      = dev_qdeny_sel | active_deny_i;
      nxt_ctrl_qdeny         = dev_qdeny_sel | active_deny_i;
      nxt_dev_qreqn          = (dev_qdeny_sel | (~dev_qacceptn_sel & active_deny_i))?
                               (dev_qreqn_r[NUM_QCHL-1:0] | sr_r[NUM_QCHL-1:0]):
                               (dev_qreqn_r[NUM_QCHL-1:0] & ~nxt_sr[NUM_QCHL-1:0]);
      dev_qreqn_en           = ~dev_qacceptn_sel | dev_qdeny_sel;
      shift_left             = active_deny_i & dev_qacceptn_sel & ~sr_r[NUM_QCHL-1] & ~dev_qdeny_sel;
      shift_right            = ~active_deny_i & ~dev_qdeny_sel & ~dev_qacceptn_sel & ~sr_r[0];
      active_deny_channel_en = active_deny_i;
    end
    Q_CONTINUE:
    begin
      nxt_state              = Q_RUN;
      state_en               = sr_r[NUM_QCHL-1] & dev_qacceptn_sel & ~dev_qdeny_sel & ctrl_qreqn_i;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = 1'b0;
      nxt_dev_qreqn          = dev_qreqn_r[NUM_QCHL-1:0] | nxt_sr[NUM_QCHL-1:0];
      dev_qreqn_en           = 1'b1;
      shift_left             = dev_qacceptn_sel & ~dev_qdeny_sel & ~sr_r[NUM_QCHL-1];
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_DENIED:
    begin
      nxt_state              = Q_RUN;
      state_en               = ctrl_qreqn_i;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = 1'b0;
      nxt_dev_qreqn          = {NUM_QCHL{1'b1}};
      dev_qreqn_en           = 1'b0;
      shift_left             = 1'b0;
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_REQ_WAIT:
    begin
      nxt_state              = Q_REQ_CONTINUE;
      state_en               = ~dev_qacceptn_sel_active_deny | dev_qdeny_sel_active_deny;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = 1'b1;
      nxt_dev_qreqn          = (~dev_qacceptn_sel_active_deny | dev_qdeny_sel_active_deny) ?
                               (dev_qreqn_r | nxt_sr_mask | active_deny_channel_r):
                               (dev_qreqn_r | nxt_sr_mask);
      dev_qreqn_en           = 1'b1;
      shift_left             = dev_qacceptn_sel & ~sr_r[NUM_QCHL-1];
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    Q_REQ_CONTINUE:
    begin
      nxt_state              = (ctrl_qreqn_i & sr_r[NUM_QCHL-1] & dev_qacceptn_sel & ~dev_qdeny_sel)? Q_RUN:Q_CONTINUE;
      state_en               = dev_qacceptn_sel_active_deny & ~dev_qdeny_sel_active_deny;
      nxt_ctrl_qacceptn      = 1'b1;
      nxt_ctrl_qdeny         = ~(ctrl_qreqn_i & sr_r[NUM_QCHL-1] & dev_qacceptn_sel & ~dev_qdeny_sel);
      nxt_dev_qreqn          = (~dev_qacceptn_sel_active_deny | dev_qdeny_sel_active_deny) ?
                               (dev_qreqn_r | nxt_sr_mask | active_deny_channel_r):
                               (dev_qreqn_r | nxt_sr_mask);
      dev_qreqn_en           = 1'b1;
      shift_left             = dev_qacceptn_sel & ~sr_r[NUM_QCHL-1];
      shift_right            = 1'b0;
      active_deny_channel_en = 1'b0;
    end
    default:
    begin
      nxt_state              = 3'bxxx;
      state_en               = 1'bx;
      nxt_ctrl_qacceptn      = 1'bx;
      nxt_ctrl_qdeny         = 1'bx;
      nxt_dev_qreqn          = {NUM_QCHL{1'bx}};
      dev_qreqn_en           = 1'bx;
      shift_left             = 1'bx;
      shift_right            = 1'bx;
      active_deny_channel_en = 1'bx;
    end
    endcase
  end


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      sr_r <= {{NUM_QCHL-1{1'b0}},1'b1};
    end
    else if(sr_en)
    begin
      sr_r <= nxt_sr;
    end
  end

  always@*
  begin
    case({shift_left,shift_right})
    2'b00:   nxt_sr[SHIFT_WIDTH-1:0] = sr_r[SHIFT_WIDTH-1:0];
    2'b01:   nxt_sr[SHIFT_WIDTH-1:0] = sr_r[SHIFT_WIDTH-1:0] >> 1;
    2'b10:   nxt_sr[SHIFT_WIDTH-1:0] = sr_r[SHIFT_WIDTH-1:0] << 1;
    default: nxt_sr[SHIFT_WIDTH-1:0] = {SHIFT_WIDTH{1'bx}};
    endcase
  end

  assign sr_en = shift_left | shift_right;

  assign nxt_sr_mask = nxt_sr[NUM_QCHL-1:0] & ~active_deny_channel_r[NUM_QCHL-1:0];


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      active_deny_channel_r[NUM_QCHL-1:0] <= {NUM_QCHL{1'b0}};
    end
    else if(active_deny_channel_en)
    begin
      active_deny_channel_r[NUM_QCHL-1:0] <= sr_r[NUM_QCHL-1:0];
    end
  end

  assign dev_qacceptn_sel_active_deny = |(dev_qacceptn_i & active_deny_channel_r);
  assign dev_qdeny_sel_active_deny    = |(dev_qdeny_i    & active_deny_channel_r);


  assign dev_qacceptn_sel = |(dev_qacceptn_i & sr_r);
  assign dev_qdeny_sel    = |(dev_qdeny_i    & sr_r);


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dev_qreqn_r <= {NUM_QCHL{1'b0}};
    end
    else if(dev_qreqn_en)
    begin
      dev_qreqn_r <= nxt_dev_qreqn;
    end
  end


  assign int_clken = ((state[2:0] == Q_STOPPED) &  ctrl_qreqn_i) |
                     ((state[2:0] == Q_RUN)     & ~ctrl_qreqn_i) |
                     ((state[2:0] != Q_STOPPED) & (state[2:0] != Q_RUN));


  assign ctrl_qacceptn_o = ctrl_qacceptn_r;
  assign ctrl_qdeny_o = ctrl_qdeny_r;

  assign dev_qreqn_o[NUM_QCHL-1:0] = dev_qreqn_r[NUM_QCHL-1:0];

  assign int_clken_o = int_clken;

endmodule

