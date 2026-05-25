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

module sse710_integration_example_f0_external_system_cpu_pwrctrl (
    
    input  wire           extsys_aonclk,
    
    input  wire           extsys_poresetn_s,    
        
    input  wire           cpupwr_preq,
    input  wire [3:0]     cpupwr_pstate,
    
    output wire           cpupwr_paccept,
    output wire           cpupwr_pdeny,
    output wire [10:0]    cpupwr_pactive,
    
    input  wire           sleeping_ss,
    input  wire           sleep_hold_ackn_ss,
    input  wire           sysreset_req_ss,
    input  wire           pwrdown_en,
    
    output wire           sleep_hold_reqn,
    
    output wire           clk_qactive
    
  );


  localparam STABLE     = 3'b000;
  localparam REQ        = 3'b001;
  localparam OFF_REQ0   = 3'b010;
  localparam OFF_REQ1   = 3'b011;
  localparam DENY       = 3'b100;
  localparam ACCEPT     = 3'b101;
  
  localparam PSTATE_OFF = 4'b0000;
  localparam PSTATE_ON  = 4'b1000;


  reg [2:0]  state;
  reg [2:0]  nxt_state;
  reg        state_en;
  reg        nxt_paccept;
  reg        nxt_pdeny;  
  reg        nxt_sleep_hold_reqn;
  
  reg [3:0]  curr_pwr_state_r;
  reg [3:0]  nxt_curr_pwr_state;
  
  reg        paccept_r;
  reg        pdeny_r;
  reg        sleep_hold_reqn_r;



  always@(posedge extsys_aonclk or negedge extsys_poresetn_s)
  begin
    if(!extsys_poresetn_s)
    begin
      state[2:0]        <= STABLE;
      paccept_r         <= 1'b0;
      pdeny_r           <= 1'b0;
      sleep_hold_reqn_r <= 1'b1;
      curr_pwr_state_r  <= PSTATE_OFF;
    end
    else if (state_en)
    begin
      state             <= nxt_state;
      paccept_r         <= nxt_paccept;
      pdeny_r           <= nxt_pdeny;
      sleep_hold_reqn_r <= nxt_sleep_hold_reqn;
      curr_pwr_state_r  <= nxt_curr_pwr_state;
    end
  end

  always@*
  begin
    case(state)
    STABLE:
    begin
      nxt_state           = REQ;
      state_en            = cpupwr_preq;
      nxt_paccept         = 1'b0;
      nxt_pdeny           = 1'b0;
      nxt_sleep_hold_reqn = sleep_hold_reqn_r;
      nxt_curr_pwr_state  = curr_pwr_state_r;
     end
    REQ:
    begin
      nxt_state           = ((curr_pwr_state_r != PSTATE_OFF) & (cpupwr_pstate == PSTATE_OFF)) ? OFF_REQ0 : ACCEPT;
      state_en            = 1'b1;
      nxt_paccept         = ((curr_pwr_state_r != PSTATE_OFF) & (cpupwr_pstate == PSTATE_OFF)) ? 1'b0 : 1'b1;
      nxt_pdeny           = 1'b0;
      nxt_sleep_hold_reqn = (cpupwr_pstate == PSTATE_ON) ? 1'b1 : sleep_hold_reqn_r;
      nxt_curr_pwr_state  = curr_pwr_state_r;
    end
    OFF_REQ0:
    begin
      nxt_state           = ({pwrdown_en,sleeping_ss} == 2'b11) ? OFF_REQ1 : DENY ;
      state_en            = 1'b1;
      nxt_paccept         = 1'b0;
      nxt_pdeny           = ({pwrdown_en,sleeping_ss} == 2'b11) ? 1'b0 : 1'b1;
      nxt_sleep_hold_reqn = ({pwrdown_en,sleeping_ss} == 2'b11) ? 1'b0 : 1'b1;
      nxt_curr_pwr_state  = curr_pwr_state_r;
    end
    OFF_REQ1:
    begin
      nxt_state           = ({sleep_hold_ackn_ss,sleeping_ss} == 2'b01) ? ACCEPT : DENY;
      state_en            = ({sleep_hold_ackn_ss,sleeping_ss} == 2'b11) ? 1'b0 : 1'b1;
      nxt_paccept         = ({sleep_hold_ackn_ss,sleeping_ss} == 2'b01) ? 1'b1 : 1'b0;
      nxt_pdeny           = ({sleep_hold_ackn_ss,sleeping_ss} == 2'b01) ? 1'b0 : 1'b1;
      nxt_sleep_hold_reqn = ({sleep_hold_ackn_ss,sleeping_ss} == 2'b01) ? 1'b0 : 1'b1;
      nxt_curr_pwr_state  = curr_pwr_state_r;
    end
    DENY:
    begin
      nxt_state           = STABLE;
      state_en            = ~cpupwr_preq;
      nxt_paccept         = 1'b0;
      nxt_pdeny           = 1'b0;
      nxt_sleep_hold_reqn = 1'b1;
      nxt_curr_pwr_state  = curr_pwr_state_r;
    end
    ACCEPT:
    begin
      nxt_state           = STABLE;
      state_en            = ~cpupwr_preq;
      nxt_paccept         = 1'b0;
      nxt_pdeny           = 1'b0;
      nxt_sleep_hold_reqn = sleep_hold_reqn_r;
      nxt_curr_pwr_state  = cpupwr_pstate;
    end
    default:
    begin
      nxt_state           = 3'bxxx;
      state_en            = 1'bx;
      nxt_paccept         = 1'bx;
      nxt_pdeny           = 1'bx;
      nxt_sleep_hold_reqn = 1'bx;
      nxt_curr_pwr_state  = 4'bxxxx;
    end
    endcase
  end


  assign cpupwr_paccept    = paccept_r;
  assign cpupwr_pdeny      = pdeny_r;
  
  assign sleep_hold_reqn   = sleep_hold_reqn_r;
  
  assign cpupwr_pactive[7:0] = 8'h0; 
  assign cpupwr_pactive[8]   = ~(pwrdown_en & (sleeping_ss | (curr_pwr_state_r == 4'b0000))); 
  assign cpupwr_pactive[9]   = sysreset_req_ss;  
  assign cpupwr_pactive[10]  = 1'b0;
  
  assign clk_qactive         = |{state, cpupwr_preq};
  
endmodule
