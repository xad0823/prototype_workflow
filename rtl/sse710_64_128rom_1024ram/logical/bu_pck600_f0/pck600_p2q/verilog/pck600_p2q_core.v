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

module pck600_p2q_core #(
                    parameter CTRL_P_CH_SYNC     = 1,
                    parameter CTRL_P_CH_PWR_PSTATE_MAP = 16'b0000000111110000,
                    parameter CTRL_P_CH_OP_PSTATE_MAP = 16'b0000000111110000,
                    parameter CTRL_P_CH_PACTIVE  = 32'b11111111111111111111111111111111)
  (
  input  wire                          clk,
  input  wire                          reset_n,

  input  wire [7:0]                    ctrl_pstate_i,
  input  wire                          ctrl_preq_i,
  output wire                          ctrl_paccept_o,
  output wire                          ctrl_pdeny_o,
  output wire [31:0]                   ctrl_pactive_o,

  input  wire                          ctrl_preq_edge_i,

  output wire                          dev_qreqn_o,
  input  wire                          dev_qacceptn_i,
  input  wire                          dev_qdeny_i,
  input  wire                          dev_qactive_i,

  output wire                          clk_qactive_o
);

  localparam PSTATE_OFF         = 4'b0000;
  localparam PSTATE_OFF_EMU     = 4'b0001;
  localparam PSTATE_MEM_RET     = 4'b0010;
  localparam PSTATE_MEM_RET_EMU = 4'b0011;
  localparam PSTATE_LOGIC_RET   = 4'b0100;
  localparam PSTATE_FULL_RET    = 4'b0101;
  localparam PSTATE_MEM_OFF     = 4'b0110;
  localparam PSTATE_FUNC_RET    = 4'b0111;
  localparam PSTATE_ON          = 4'b1000;
  localparam PSTATE_WARM_RST    = 4'b1001;
  localparam PSTATE_DBG_RECOV   = 4'b1010;
  localparam PSTATE_RSVD0       = 4'b1011;
  localparam PSTATE_RSVD1       = 4'b1100;
  localparam PSTATE_RSVD2       = 4'b1101;
  localparam PSTATE_RSVD3       = 4'b1110;
  localparam PSTATE_RSVD4       = 4'b1111;

  localparam P_INIT_CDC0        = 4'b1100;
  localparam P_INIT_CDC1        = 4'b1101;
  localparam P_INIT_CDC2        = 4'b1110;
  localparam P_INIT0            = 4'b0000;
  localparam P_INIT1            = 4'b0001;
  localparam P_STABLE_OFF       = 4'b0010;
  localparam P_STABLE_ON        = 4'b0011;
  localparam P_ACCEPT_OFF       = 4'b0100;
  localparam P_ACCEPT_ON        = 4'b0101;
  localparam P_DENY_ON          = 4'b0110;
  localparam DEV_Q_REQ          = 4'b0111;
  localparam DEV_Q_DENIED       = 4'b1000;
  localparam DEV_Q_EXIT         = 4'b1001;

  genvar                        G, H;

  wire                          clk_qactive;
  wire [31:0]                   ctrl_pactive;
  reg                           ctrl_paccept;
  wire                          ctrl_accept_deny;
  wire                          ctrl_paccept_pdeny;
  reg                           ctrl_pdeny;
  reg                           dev_qreqn;
  reg                           int_clken_q;
  reg                           nxt_ctrl_paccept;
  reg                           nxt_ctrl_pdeny;
  reg                           nxt_dev_qreqn;
  wire                          nxt_int_clken;
  reg  [3:0]                    nxt_p_state_fsm;
  reg                           p_state_en;
  reg  [3:0]                    p_state_fsm_q;


  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        dev_qreqn <= 1'b0;
      end else if (p_state_en)
      begin
        dev_qreqn <= nxt_dev_qreqn;
      end

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        ctrl_paccept <= 1'b0;
      end else if (p_state_en)
      begin
        ctrl_paccept <= nxt_ctrl_paccept;
      end

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        ctrl_pdeny <= 1'b0;
      end else if (p_state_en)
      begin
        ctrl_pdeny <= nxt_ctrl_pdeny;
      end

  generate for (G = 0; G < 32; G = G + 1)
  begin: gen_pactive
   if (CTRL_P_CH_PACTIVE[G] == 1'b1) begin : gen_pactv
    assign ctrl_pactive[G] = dev_qactive_i;
   end else begin : gen_no_pactv
    assign ctrl_pactive[G] = 1'b0;
  end
  end
  endgenerate


  assign nxt_int_clken = ctrl_preq_edge_i |
                         (~(((p_state_fsm_q == P_STABLE_OFF) |
                             (p_state_fsm_q == P_STABLE_ON)) & (~ctrl_preq_i)));

  always@(posedge clk or negedge reset_n)
    if (!reset_n)
      int_clken_q <= 1'b1;
    else
      int_clken_q <= nxt_int_clken;

  pck600_std_or2 u_pck600_or2_clk_qactive0 (
  .A (ctrl_paccept_o),
  .B (ctrl_pdeny_o),
  .Y (ctrl_paccept_pdeny)
  );

  pck600_std_or2 u_pck600_or2_clk_qactive1 (
  .A (int_clken_q),
  .B (ctrl_preq_edge_i),
  .Y (ctrl_accept_deny)
  );

  pck600_std_or2 u_pck600_or2_clk_qactive (
  .A (ctrl_paccept_pdeny),
  .B (ctrl_accept_deny),
  .Y (clk_qactive)
  );


  wire p_state_off_qrun         = (ctrl_pstate_i[3:0] == PSTATE_OFF)         &  CTRL_P_CH_PWR_PSTATE_MAP[0];
  wire p_state_off_emu_qrun     = (ctrl_pstate_i[3:0] == PSTATE_OFF_EMU)     &  CTRL_P_CH_PWR_PSTATE_MAP[1];
  wire p_state_mem_ret_qrun     = (ctrl_pstate_i[3:0] == PSTATE_MEM_RET)     &  CTRL_P_CH_PWR_PSTATE_MAP[2];
  wire p_state_mem_ret_emu_qrun = (ctrl_pstate_i[3:0] == PSTATE_MEM_RET_EMU) &  CTRL_P_CH_PWR_PSTATE_MAP[3];
  wire p_state_logic_ret_qrun   = (ctrl_pstate_i[3:0] == PSTATE_LOGIC_RET)   &  CTRL_P_CH_PWR_PSTATE_MAP[4];
  wire p_state_full_ret_qrun    = (ctrl_pstate_i[3:0] == PSTATE_FULL_RET)    &  CTRL_P_CH_PWR_PSTATE_MAP[5];
  wire p_state_mem_off_qrun     = (ctrl_pstate_i[3:0] == PSTATE_MEM_OFF)     &  CTRL_P_CH_PWR_PSTATE_MAP[6];
  wire p_state_func_ret_qrun    = (ctrl_pstate_i[3:0] == PSTATE_FUNC_RET)    &  CTRL_P_CH_PWR_PSTATE_MAP[7];
  wire p_state_on               = (ctrl_pstate_i[3:0] == PSTATE_ON)          &  CTRL_P_CH_PWR_PSTATE_MAP[8];
  wire p_state_warm_rst         = (ctrl_pstate_i[3:0] == PSTATE_WARM_RST)    &  CTRL_P_CH_PWR_PSTATE_MAP[9];
  wire p_state_dbg_recov        = (ctrl_pstate_i[3:0] == PSTATE_DBG_RECOV)   &  CTRL_P_CH_PWR_PSTATE_MAP[10];
  wire p_state_rsvd0_qrun       = (ctrl_pstate_i[3:0] == PSTATE_RSVD0)       &  CTRL_P_CH_PWR_PSTATE_MAP[11];
  wire p_state_rsvd1_qrun       = (ctrl_pstate_i[3:0] == PSTATE_RSVD1)       &  CTRL_P_CH_PWR_PSTATE_MAP[12];
  wire p_state_rsvd2_qrun       = (ctrl_pstate_i[3:0] == PSTATE_RSVD2)       &  CTRL_P_CH_PWR_PSTATE_MAP[13];
  wire p_state_rsvd3_qrun       = (ctrl_pstate_i[3:0] == PSTATE_RSVD3)       &  CTRL_P_CH_PWR_PSTATE_MAP[14];
  wire p_state_rsvd4_qrun       = (ctrl_pstate_i[3:0] == PSTATE_RSVD4)       &  CTRL_P_CH_PWR_PSTATE_MAP[15];

  wire p_state_qrun = p_state_off_qrun       | p_state_off_emu_qrun     |
                      p_state_mem_ret_qrun   | p_state_mem_ret_emu_qrun |
                      p_state_logic_ret_qrun | p_state_full_ret_qrun    |
                      p_state_mem_off_qrun   | p_state_func_ret_qrun    |
                      p_state_on             | p_state_warm_rst         |
                      p_state_dbg_recov      | p_state_rsvd0_qrun       |
                      p_state_rsvd1_qrun     | p_state_rsvd2_qrun       |
                      p_state_rsvd3_qrun     | p_state_rsvd4_qrun;

  wire [15:0] op_mode_run;

  generate for (H = 0; H < 16; H = H + 1)
  begin: gen_opmode
   if (CTRL_P_CH_OP_PSTATE_MAP[H] == 1'b1) begin : gen_opmode_run
    assign op_mode_run[H] = (ctrl_pstate_i[7:4] == H);
   end else begin : gen_opmode_off
    assign op_mode_run[H] = 1'b0;
  end
  end
  endgenerate

  wire op_mode_qrun = (|op_mode_run);


  generate if(CTRL_P_CH_SYNC == 1)
  begin:ctrl_sync_inc

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        p_state_fsm_q <= P_INIT_CDC0;
      end else if (p_state_en)
      begin
        p_state_fsm_q <= nxt_p_state_fsm;
      end

  end
  else
  begin:ctrl_sync_excl

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      begin
        p_state_fsm_q <= P_INIT_CDC2;
      end else if (p_state_en)
      begin
        p_state_fsm_q <= nxt_p_state_fsm;
      end

  end
  endgenerate

  always @*
    begin : pck600_p2q_fsm_nxt
      case(p_state_fsm_q)

        P_INIT_CDC0:
          begin
           nxt_p_state_fsm  = P_INIT_CDC1;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b0;
           p_state_en       = 1'b1;
          end
        P_INIT_CDC1:
          begin
           nxt_p_state_fsm  = P_INIT_CDC2;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b0;
           p_state_en       = 1'b1;
          end
        P_INIT_CDC2:
          begin
           nxt_p_state_fsm  = P_INIT0;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b0;
           p_state_en       = 1'b1;
          end
        P_INIT0:
          begin
           nxt_p_state_fsm  = ctrl_preq_i ? ((p_state_qrun & op_mode_qrun) ? DEV_Q_EXIT : P_ACCEPT_OFF) :
                                            ((p_state_qrun & op_mode_qrun) ? P_INIT1    : P_STABLE_OFF);
           nxt_ctrl_paccept = ctrl_preq_i ? ((p_state_qrun & op_mode_qrun) ? 1'b0 : 1'b1) :
                                            1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = (p_state_qrun & op_mode_qrun);
           p_state_en       = 1'b1;
          end
        P_INIT1:
          begin
           nxt_p_state_fsm  = P_STABLE_ON;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = dev_qacceptn_i;
           p_state_en       = dev_qacceptn_i;
          end
        P_STABLE_OFF:
          begin
           nxt_p_state_fsm  = (p_state_qrun & op_mode_qrun) ? DEV_Q_EXIT : P_ACCEPT_OFF;
           nxt_ctrl_paccept = (p_state_qrun & op_mode_qrun) ? 1'b0 : 1'b1;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = (p_state_qrun & op_mode_qrun);
           p_state_en       = ctrl_preq_i;
          end
        P_ACCEPT_OFF:
          begin
           nxt_p_state_fsm  = P_STABLE_OFF;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b0;
           p_state_en       = ~ctrl_preq_i;
          end
        DEV_Q_EXIT:
          begin
           nxt_p_state_fsm  = P_ACCEPT_ON;
           nxt_ctrl_paccept = ctrl_preq_i;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = dev_qacceptn_i;
           p_state_en       = dev_qacceptn_i;
          end
        P_ACCEPT_ON:
          begin
           nxt_p_state_fsm  = P_STABLE_ON;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b1;
           p_state_en       = ~ctrl_preq_i;
          end
        P_STABLE_ON:
          begin
           nxt_p_state_fsm  = (p_state_qrun & op_mode_qrun) ? P_ACCEPT_ON : DEV_Q_REQ;
           nxt_ctrl_paccept = (p_state_qrun & op_mode_qrun);
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = (p_state_qrun & op_mode_qrun);
           p_state_en       = ctrl_preq_i;
          end
        DEV_Q_REQ:
          begin
           nxt_p_state_fsm  = (~dev_qacceptn_i) ? P_ACCEPT_OFF : DEV_Q_DENIED;
           nxt_ctrl_paccept = ~dev_qacceptn_i;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = ~dev_qacceptn_i   ? 1'b0 : 1'b1;
           p_state_en       = ~dev_qacceptn_i | dev_qdeny_i;
          end
        DEV_Q_DENIED:
          begin
           nxt_p_state_fsm  = dev_qdeny_i ? DEV_Q_DENIED : P_DENY_ON;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = dev_qdeny_i ? 1'b0 : 1'b1;
           nxt_dev_qreqn    = 1'b1;
           p_state_en       = 1'b1;
          end
        P_DENY_ON:
          begin
           nxt_p_state_fsm  = P_STABLE_ON;
           nxt_ctrl_paccept = 1'b0;
           nxt_ctrl_pdeny   = 1'b0;
           nxt_dev_qreqn    = 1'b1;
           p_state_en       = ~ctrl_preq_i;
          end
        default:
          begin
           nxt_p_state_fsm  = 4'bxxxx;
           nxt_ctrl_paccept = 1'bx;
           nxt_ctrl_pdeny   = 1'bx;
           nxt_dev_qreqn    = 1'bx;
           p_state_en       = 1'bx;
          end
      endcase
    end


  wire [1:1] config_check_0;
  assign config_check_0[~((CTRL_P_CH_PWR_PSTATE_MAP == 16'h0000) | (CTRL_P_CH_OP_PSTATE_MAP == 16'h0000))] = 1'b1;

  wire [1:1] config_check_1;
  assign config_check_1[~((CTRL_P_CH_PWR_PSTATE_MAP == 16'hFFFF) & (CTRL_P_CH_OP_PSTATE_MAP == 16'hFFFF))] = 1'b1;

  wire unused = config_check_1 | config_check_0;

  assign ctrl_paccept_o  = ctrl_paccept;
  assign ctrl_pactive_o  = ctrl_pactive;
  assign ctrl_pdeny_o    = ctrl_pdeny;
  assign clk_qactive_o   = clk_qactive;
  assign dev_qreqn_o     = dev_qreqn;


endmodule
