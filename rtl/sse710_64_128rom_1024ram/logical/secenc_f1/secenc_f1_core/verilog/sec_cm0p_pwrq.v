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


module sec_cm0p_pwrq (
  input  wire         clk,
  input  wire         rst_n,

  input  wire         cm0_qreqn,
  output wire         cm0_qacceptn,
  output wire         cm0_qdeny,
  output wire         cm0_qactive,

  input  wire         sleep_deep,       
  output wire         sleep_hold_reqn,  
  input  wire         sleep_hold_ackn   
);


  localparam [2:0] ST_Q_STOP  = 3'b000; 
  localparam [2:0] ST_Q_RUN   = 3'b010; 
  localparam [2:0] ST_SH_DEAS = 3'b100; 
  localparam [2:0] ST_SH_ASS  = 3'b110; 
  localparam [2:0] ST_Q_DENY  = 3'b111; 


  reg   [2:0] state_pm2q;
  reg   [2:0] state_pm2q_nxt;

  reg         cm0_hold_reqn;
  reg         cm0_hold_reqn_nxt;
  
  reg         cm0_qactive_r;
  wire        cm0_qactive_nxt;


  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      state_pm2q <= ST_Q_STOP;
    else
      state_pm2q <= state_pm2q_nxt;

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cm0_hold_reqn <= 1'b1;
    else
      cm0_hold_reqn <= cm0_hold_reqn_nxt;

  always @(*)
    begin
      state_pm2q_nxt = state_pm2q;
      cm0_hold_reqn_nxt = cm0_hold_reqn;
      case (state_pm2q)
        ST_Q_STOP :
          if (cm0_qreqn) begin
            cm0_hold_reqn_nxt = 1'b1;
            state_pm2q_nxt = ST_SH_DEAS;
          end
        ST_SH_DEAS :
          if (sleep_hold_ackn)
            state_pm2q_nxt = ST_Q_RUN;
        ST_Q_RUN :
          if (!sleep_deep & !cm0_qreqn)
            state_pm2q_nxt = ST_Q_DENY;
          else if (sleep_deep & !cm0_qreqn) begin
            cm0_hold_reqn_nxt = 1'b0;
            state_pm2q_nxt = ST_SH_ASS;
          end
        ST_Q_DENY :
          if (cm0_qreqn)
            state_pm2q_nxt = ST_Q_RUN;
        ST_SH_ASS :
          if (!sleep_hold_ackn)
            state_pm2q_nxt = ST_Q_STOP;
          else if (!sleep_deep) begin
            cm0_hold_reqn_nxt = 1'b1;
            state_pm2q_nxt = ST_Q_DENY;
          end

        3'b001, 3'b011, 3'b101 : 
          state_pm2q_nxt = ST_Q_STOP;

        default : begin 
            cm0_hold_reqn_nxt = 1'bx;
            state_pm2q_nxt = 3'bxxx;
          end

      endcase
    end


  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      cm0_qactive_r <= 1'b0;
    else
      cm0_qactive_r <= cm0_qactive_nxt;
      
  assign cm0_qactive_nxt = ~sleep_deep; 


  assign cm0_qacceptn    = state_pm2q[1];     
  assign cm0_qdeny       = state_pm2q[0];     
  assign cm0_qactive     = cm0_qactive_r;
  assign sleep_hold_reqn = cm0_hold_reqn;

endmodule
