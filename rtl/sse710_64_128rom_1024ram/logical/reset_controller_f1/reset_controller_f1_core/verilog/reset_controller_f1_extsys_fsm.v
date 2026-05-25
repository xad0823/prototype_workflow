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




module reset_controller_f1_extsys_fsm #(
 parameter SOC_RST_DLY   = 3'b111
)  (
  input  wire          clk,
  input  wire          resetn,
  input  wire          fsm_en,
  input  wire          rst_req,
  output wire          resetn_out,
  output wire          cpuwait,
  output wire [1:0]    rst_ack,
  output wire          qreqn,
  input  wire          qacceptn,
  input  wire          qdeny,
  output wire          rst_syndrome

);
  localparam IDLE = 3'b000;
  localparam WAIT_QACCEPT = 3'b001;
  localparam RESET_ASSERT = 3'b010;
  localparam WAIT_DEASSERT = 3'b011;
  localparam RESET_DEASSERT = 3'b100;
  localparam Q_DENIED = 3'b101;
  localparam DISABLED = 3'b110;


  reg [2:0]  state_r;
  reg [2:0]  downcount_r;
  reg        denied_flag_r;

  reg        resetn_out_r;
  reg        cpuwait_r;
  reg [1:0]  rst_ack_r;
  reg        qreqn_r;
  reg        rst_syndrome_r;

  reg        resetn_out_nxt;
  reg        cpuwait_nxt;
  reg [1:0]  rst_ack_nxt;
  reg        qreqn_nxt;
  reg        rst_syndrome_nxt;

  reg        denied_flag_nxt;
  reg [2:0]  state_nxt;
  reg [2:0]  downcount_nxt;


  wire  qch_okay;

  assign qch_okay = (qreqn_r & qacceptn & ~qdeny);


  always @(posedge clk or negedge resetn)
  begin
  if (~resetn)
  begin
    resetn_out_r <= 1'b0;
    cpuwait_r <= 1'b0;
    rst_ack_r <= 2'b00;
    qreqn_r <= 1'b0;
    rst_syndrome_r <= 1'b0;

    denied_flag_r <= 1'b0;
    state_r <= DISABLED;
    downcount_r <= SOC_RST_DLY[2:0];
  end
  else 
  begin
    resetn_out_r <= resetn_out_nxt;
    cpuwait_r <= cpuwait_nxt;
    rst_ack_r <= rst_ack_nxt;
    qreqn_r <= qreqn_nxt;
    rst_syndrome_r <= rst_syndrome_nxt;

    denied_flag_r <= denied_flag_nxt;
    state_r <= state_nxt;
    downcount_r <= downcount_nxt;
  end
  end

  always @*
  begin
    case (state_r)
    IDLE:
    begin
      state_nxt = fsm_en ? ((rst_req & ~denied_flag_r) & qch_okay ? WAIT_QACCEPT : state_r) : DISABLED;
      
      resetn_out_nxt = fsm_en ? resetn_out_r : 1'b1;
      cpuwait_nxt = fsm_en ? cpuwait_r : 1'b0;
      rst_ack_nxt = fsm_en ?  (rst_req ? rst_ack_r : 2'b00) : 2'b00;
      qreqn_nxt = fsm_en ? ((state_nxt == WAIT_QACCEPT) ? 1'b0 : 1'b1) : qreqn_r;
      rst_syndrome_nxt = fsm_en ? rst_syndrome_r : 1'b0;
      denied_flag_nxt = denied_flag_r ? rst_req : denied_flag_r;
      downcount_nxt = downcount_r;
    end

    WAIT_QACCEPT:
    begin
      state_nxt = fsm_en ? ((qacceptn == 1'b0) ? RESET_ASSERT : (qdeny ? Q_DENIED : state_r)) : DISABLED;
      
      resetn_out_nxt = (fsm_en & (qacceptn == 1'b0)) ? 1'b0 : 1'b1;
      cpuwait_nxt = (fsm_en & (qacceptn == 1'b0)) ? 1'b1 : 1'b0;
      rst_ack_nxt = (fsm_en & (qacceptn == 1'b0)) ? 2'b00 : (fsm_en & (qdeny == 1'b1)) ? 2'b01 : 2'b00;
      qreqn_nxt = (qacceptn == 1'b0) ? (fsm_en ? 1'b0 : 1'b1) : ((qdeny == 1'b1) ? 1'b1 : qreqn_r);   
      rst_syndrome_nxt = fsm_en ? ((qacceptn == 1'b0) ? 1'b1 : rst_syndrome_r) : 1'b0; 
      denied_flag_nxt = (qdeny == 1'b1) ? 1'b1 : 1'b0;
      downcount_nxt = downcount_r;
    end

    Q_DENIED:
    begin
      state_nxt = fsm_en ? ((qdeny == 1'b0) ? IDLE : state_r) : DISABLED;
      
      resetn_out_nxt = fsm_en ? resetn_out_r : 1'b1;
      cpuwait_nxt = fsm_en ? cpuwait_r : 1'b0;
      rst_ack_nxt = fsm_en ? (rst_req ? rst_ack_r : 2'b00) : 2'b00;
      qreqn_nxt = 1'b1;
      rst_syndrome_nxt = fsm_en ? rst_syndrome_r : 1'b0;
      denied_flag_nxt = rst_req ? denied_flag_r : 1'b0;
      downcount_nxt = downcount_r;
    end

    RESET_ASSERT: 
    begin
      state_nxt = fsm_en ? WAIT_DEASSERT : DISABLED;
      
      resetn_out_nxt = fsm_en ? resetn_out_r : 1'b1;
      cpuwait_nxt = fsm_en ? cpuwait_r : 1'b0;
      rst_ack_nxt = fsm_en ? rst_ack_r : 2'b00;
      qreqn_nxt = fsm_en ? qreqn_r : 1'b1;
      rst_syndrome_nxt = fsm_en ? rst_syndrome_r : 1'b0;
      denied_flag_nxt = denied_flag_r;
      downcount_nxt = downcount_r;
    end

    WAIT_DEASSERT:
    begin
      state_nxt = fsm_en ? (((downcount_r == 3'b001) & ~rst_req) ? RESET_DEASSERT : WAIT_DEASSERT) : DISABLED;

      resetn_out_nxt = fsm_en ? (((downcount_r == 3'b001) & ~rst_req) ? 1'b1 : resetn_out_r) : 1'b1;
      cpuwait_nxt = fsm_en ? (((downcount_r == 3'b001) & ~rst_req) ? 1'b0 : cpuwait_r) : 1'b0;
      rst_ack_nxt = fsm_en ? ((downcount_r == 3'b001) ? (rst_req ? 2'b10 : 2'b00) : 2'b00) : 2'b00; 
      qreqn_nxt = fsm_en ? (((downcount_r == 3'b001) & ~rst_req) ? 1'b1 : 1'b0) : 1'b1;
      rst_syndrome_nxt = fsm_en ? rst_syndrome_r : 1'b0;
      denied_flag_nxt = denied_flag_r;
      downcount_nxt = fsm_en ? ((downcount_r > 3'b001) ? (downcount_r - 3'b001) : 3'b001) : SOC_RST_DLY[2:0];
    end

    RESET_DEASSERT:
    begin
      state_nxt = fsm_en ? ((rst_req & qreqn_r & qacceptn & ~qdeny) ? WAIT_QACCEPT : IDLE) : DISABLED;
      
      resetn_out_nxt = fsm_en ? resetn_out_r : 1'b1;
      cpuwait_nxt = fsm_en ? cpuwait_r : 1'b0;
      rst_ack_nxt = fsm_en ? rst_ack_r : 2'b00;
      qreqn_nxt = (fsm_en & rst_req & qacceptn & ~qdeny) ? 1'b0 : qreqn_r;
      rst_syndrome_nxt = fsm_en ? rst_syndrome_r : 1'b0;
      denied_flag_nxt = denied_flag_r;
      downcount_nxt = SOC_RST_DLY[2:0];
    end

    DISABLED:
    begin
      state_nxt = fsm_en ? IDLE : DISABLED;

      resetn_out_nxt = 1'b1;
      cpuwait_nxt = 1'b0;
      rst_ack_nxt = 2'b00;
      qreqn_nxt = 1'b1;
      rst_syndrome_nxt = 1'b0;
      denied_flag_nxt = rst_req ? denied_flag_r : 1'b0;
      downcount_nxt = SOC_RST_DLY[2:0];
    end

    default:
    begin
      state_nxt = 3'bxxx;

      resetn_out_nxt = 1'bx;
      cpuwait_nxt = 1'bx;
      rst_ack_nxt = 2'bxx;
      qreqn_nxt = 1'bx;
      rst_syndrome_nxt = 1'bx;
      denied_flag_nxt = 1'bx;
      downcount_nxt = 3'bxxx;
    end

    endcase
  end


  assign qreqn = qreqn_r;
  assign rst_syndrome = rst_syndrome_r;
  assign cpuwait = cpuwait_r;
  assign rst_ack = rst_ack_r;
  assign resetn_out = resetn_out_r;

endmodule






