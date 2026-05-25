//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module sse710_q_ch_bridge
(
  input wire                  clk,
  input wire                  resetn,

  input wire                  ctrl_qreqn_i,
  input wire  [3:0]           ctrl_pstate_i,
  output wire                 ctrl_qacceptn_o,
  output wire                 ctrl_qdeny_o,

  output wire                 dev_qreqn_o,
  input wire                  dev_qacceptn_i,
  input wire                  dev_qdeny_i,

  input wire                  standbywfi_i,
  input wire                  dbgrstreq_i,

  input wire                  dev_reset_status_i,

  output wire                 cpuwait_o

);


  localparam Q_STOPPED = 3'b000;
  localparam Q_EXIT = 3'b001;
  localparam Q_RUN = 3'b010;
  localparam Q_REQUEST = 3'b011;
  localparam Q_DENIED = 3'b100;
  localparam Q_DEV_RESTORE = 3'b101;
  localparam Q_DENIED_CPUWAIT = 3'b110;


  reg [2:0]                   state;
  reg                         ctrl_qacceptn_r;
  reg                         ctrl_qdeny_r;
  reg                         dev_qreqn_r;
  reg                         cpuwait_r;

  reg [2:0]                   nxt_state;
  reg                         state_en;
  reg                         nxt_ctrl_qacceptn_r;
  reg                         nxt_ctrl_qdeny_r;
  reg                         nxt_dev_qreqn_r;
  reg                         nxt_cpuwait_r;


  always@(posedge clk or negedge resetn)
  begin
    if(!resetn)
    begin
      state[2:0] <= Q_STOPPED;
      ctrl_qacceptn_r <= 1'b0;
      ctrl_qdeny_r <= 1'b0;
      dev_qreqn_r <= 1'b0;
      cpuwait_r <= 1'b1;
    end
    else if(state_en)
    begin
      state[2:0] <= nxt_state[2:0];
      ctrl_qacceptn_r <= nxt_ctrl_qacceptn_r;
      ctrl_qdeny_r <= nxt_ctrl_qdeny_r;
      dev_qreqn_r <= nxt_dev_qreqn_r;
      cpuwait_r <= nxt_cpuwait_r;
    end
  end


  always@*
  begin
    case(state[2:0])
    Q_STOPPED:
    begin
      state_en = ctrl_qreqn_i;
      nxt_ctrl_qdeny_r = 1'b0;
      nxt_cpuwait_r = dev_reset_status_i;
      case(dev_reset_status_i)
      1'b0:
      begin
        nxt_state[2:0] = Q_EXIT;
        nxt_ctrl_qacceptn_r = 1'b0;
        nxt_dev_qreqn_r = 1'b1;
      end
      1'b1:
      begin
        nxt_state[2:0] = Q_RUN;
        nxt_ctrl_qacceptn_r = 1'b1;
        nxt_dev_qreqn_r = 1'b0;
      end
      default:
      begin
        nxt_state[2:0] = 3'bxxx;
        nxt_ctrl_qacceptn_r = 1'bx;
        nxt_dev_qreqn_r = 1'bx;
      end
      endcase
    end
    Q_EXIT:
    begin
      nxt_state[2:0] = Q_RUN;
      state_en = dev_qacceptn_i;
      nxt_ctrl_qacceptn_r = 1'b1;
      nxt_ctrl_qdeny_r = 1'b0;
      nxt_dev_qreqn_r = 1'b1;
      nxt_cpuwait_r = dev_reset_status_i;
    end
    Q_RUN:
    begin
      case({dev_reset_status_i,dev_qacceptn_i})
      2'b00:
      begin
        nxt_state[2:0] = Q_DEV_RESTORE;
        state_en = 1'b1;
        nxt_ctrl_qacceptn_r = 1'b1;
        nxt_ctrl_qdeny_r = 1'b0;
        nxt_dev_qreqn_r = 1'b1;
        nxt_cpuwait_r = dev_reset_status_i;
      end
      2'b01:
      begin
        nxt_state[2:0] = (standbywfi_i | ((ctrl_pstate_i == 4'b1001) & dbgrstreq_i)) ? Q_REQUEST : Q_DENIED_CPUWAIT;
        state_en = ~ctrl_qreqn_i;
        nxt_ctrl_qacceptn_r = 1'b1;
        nxt_ctrl_qdeny_r = (standbywfi_i | ((ctrl_pstate_i == 4'b1001) & dbgrstreq_i)) ? 1'b0 : 1'b1;
        nxt_dev_qreqn_r = (standbywfi_i | ((ctrl_pstate_i == 4'b1001) & dbgrstreq_i)) ? 1'b0 : 1'b1;
        nxt_cpuwait_r = dev_reset_status_i;
      end
      2'b10,2'b11:
      begin
        nxt_state[2:0] = Q_STOPPED;
        state_en = ~ctrl_qreqn_i;
        nxt_ctrl_qacceptn_r = 1'b0;
        nxt_ctrl_qdeny_r = 1'b0;
        nxt_dev_qreqn_r = 1'b0;
        nxt_cpuwait_r = 1'b1;
      end
      default:
      begin
        nxt_state[2:0] = 3'bxxx;
        state_en = 1'bx;
        nxt_ctrl_qacceptn_r = 1'bx;
        nxt_ctrl_qdeny_r = 1'bx;
        nxt_dev_qreqn_r = 1'bx;
        nxt_cpuwait_r = 1'bx;
      end
      endcase
    end
    Q_REQUEST:
    begin
      state_en = ~dev_qacceptn_i | dev_qdeny_i;
      nxt_cpuwait_r = dev_reset_status_i;
      case(dev_qdeny_i)
      1'b0:
      begin
        nxt_state[2:0] = Q_STOPPED;
        nxt_ctrl_qacceptn_r = 1'b0;
        nxt_ctrl_qdeny_r = 1'b0;
        nxt_dev_qreqn_r = 1'b0;
      end
      1'b1:
      begin
        nxt_state[2:0] = Q_DENIED;
        nxt_ctrl_qacceptn_r = 1'b1;
        nxt_ctrl_qdeny_r = 1'b1;
        nxt_dev_qreqn_r = 1'b1;
      end
      default:
      begin
        nxt_state[2:0] = 3'bxxx;
        nxt_ctrl_qdeny_r = 1'bx;
        nxt_ctrl_qacceptn_r = 1'bx;
        nxt_dev_qreqn_r = 1'bx;
      end
      endcase
    end
    Q_DENIED:
    begin
      nxt_state[2:0] = Q_RUN;
      state_en = ctrl_qreqn_i & ~dev_qdeny_i;
      nxt_ctrl_qacceptn_r = 1'b1;
      nxt_ctrl_qdeny_r = 1'b0;
      nxt_dev_qreqn_r = 1'b1;
      nxt_cpuwait_r = dev_reset_status_i;
    end
    Q_DEV_RESTORE:
    begin
      nxt_state[2:0] = Q_RUN;
      state_en = dev_qacceptn_i;
      nxt_ctrl_qacceptn_r = 1'b1;
      nxt_ctrl_qdeny_r = 1'b0;
      nxt_dev_qreqn_r = 1'b1;
      nxt_cpuwait_r = dev_reset_status_i;
    end
    Q_DENIED_CPUWAIT:
    begin
      nxt_state[2:0] = Q_RUN;
      state_en = ctrl_qreqn_i;
      nxt_ctrl_qacceptn_r = 1'b1;
      nxt_ctrl_qdeny_r = 1'b0;
      nxt_dev_qreqn_r = 1'b1;
      nxt_cpuwait_r = dev_reset_status_i;
    end
    default:
    begin
      nxt_state[2:0] = 3'bxxx;
      state_en = 1'bx;
      nxt_ctrl_qacceptn_r = 1'bx;
      nxt_ctrl_qdeny_r = 1'bx;
      nxt_dev_qreqn_r = 1'bx;
      nxt_cpuwait_r = 1'bx;
    end
    endcase
  end

assign ctrl_qacceptn_o = ctrl_qacceptn_r;
assign ctrl_qdeny_o    = ctrl_qdeny_r;
assign dev_qreqn_o     = dev_qreqn_r;
assign cpuwait_o       = cpuwait_r;

endmodule

