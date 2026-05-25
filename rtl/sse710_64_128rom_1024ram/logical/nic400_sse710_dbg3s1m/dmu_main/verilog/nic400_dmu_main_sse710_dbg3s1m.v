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




`include "nic400_dmu_main_defs_sse710_dbg3s1m.v"

module nic400_dmu_main_sse710_dbg3s1m
  (
    p0_axis_cactive,

    p0_axis_cactive_wakeup,

    p0_axis_port_enable,

    p1_axis_cactive,

    p1_axis_cactive_wakeup,

    p1_axis_port_enable,

    p2_axis_cactive,

    p2_axis_cactive_wakeup,

    p2_axis_port_enable,

    cd_main_clk,
    cd_main_resetn,
    cd_main_cactive,
    cd_main_csysreq,
    cd_main_csysack

  );


  

  input               p0_axis_cactive;             


  input               p0_axis_cactive_wakeup;      


  output              p0_axis_port_enable;         


  input               p1_axis_cactive;             


  input               p1_axis_cactive_wakeup;      


  output              p1_axis_port_enable;         


  input               p2_axis_cactive;             


  input               p2_axis_cactive_wakeup;      


  output              p2_axis_port_enable;         


  input               cd_main_clk;                 
  input               cd_main_resetn;              
  output              cd_main_cactive;             
  input               cd_main_csysreq;             
  output              cd_main_csysack;             



  wire          p0_axis_cactive;
  wire          p0_axis_cactive_wakeup;
  wire          p1_axis_cactive;
  wire          p1_axis_cactive_wakeup;
  wire          p2_axis_cactive;
  wire          p2_axis_cactive_wakeup;
  wire          domain_active;
  wire          cactive_wakeup;
  wire          cactive_ot;
  wire          cactive_wakeup_fsm;
  wire          csysreq_sync;


  wire          aclk;
  wire          aresetn;


  
  reg           port_enable_reg;
  reg           domain_ack;
  reg           next_domain_ack;
  reg           next_port_enable;
  reg [1:0]     gating_state;
  reg [1:0]     gating_next_state;
  reg           next_idle_delay;
  reg           idle_delay;
  



  assign aclk    = cd_main_clk;
  assign aresetn = cd_main_resetn;


  assign cactive_ot = (p0_axis_cactive
                        | p1_axis_cactive
                        | p2_axis_cactive); 

  

  nic400_cd_main_cdc_comb_or_sse710_dbg3s1m u_nic400_cd_main_cdc_comb_or_sse710_dbg3s1m (
       .in_p0_axis      (p0_axis_cactive_wakeup),
       .in_p1_axis      (p1_axis_cactive_wakeup),
       .in_p2_axis      (p2_axis_cactive_wakeup),
       .result           (cactive_wakeup)
  );
  
  nic400_cdc_comb_or2_sse710_dbg3s1m u_nic400_cdc_comb_or2_sse710_dbg3s1m (
       .din1_async       (cactive_ot),
       .din2_async       (cactive_wakeup),
       .dout_async       (domain_active)
   );
    
  assign cd_main_cactive     = domain_active;  

  assign cd_main_csysack   = domain_ack;



  nic400_cdc_capt_sync_sse710_dbg3s1m #(1) u_csysreq_sync (
    .clk            (aclk),
    .resetn         (aresetn),
    .d_async        (cd_main_csysreq),
    .sync_en        (1'b1),
    .q              (csysreq_sync)
  );

  nic400_cdc_capt_sync_sse710_dbg3s1m #(1) u_cactive_wakeup_sync (
    .clk            (aclk),
    .resetn         (aresetn),
    .d_async        (cactive_wakeup),
    .sync_en        (1'b1),
    .q              (cactive_wakeup_fsm)
  );


  always @(posedge aclk or negedge aresetn)
  begin : p_idle_delay
    if(~aresetn) begin
      idle_delay <= 1'h1;
    end else begin
      idle_delay <= next_idle_delay;
    end
  end 

  always @ (posedge aclk or negedge aresetn)
  begin : p_gating_state_reg_seq
      if (~aresetn) begin
          gating_state <= `IDLE;
          domain_ack <= 1'b0;
      end else begin
          gating_state <= gating_next_state;
          domain_ack <= next_domain_ack;
      end
  end

  always @ (posedge aclk or negedge aresetn)
  begin : p_port_enable_reg_seq
      if (~aresetn) begin
          port_enable_reg <= 1'b0;
      end else begin
          port_enable_reg <= next_port_enable;
      end
  end

  always @ (gating_state or csysreq_sync or cactive_ot or cactive_wakeup_fsm or idle_delay)
  begin : p_trans_completion_state_comb
  
    case(gating_state)
      `RUN: begin
        next_port_enable = 1'b1;
        next_domain_ack  = 1'b1;
        next_idle_delay  = 1'h1;
        if (~csysreq_sync)
          gating_next_state = `WAIT_FOR_IDLE;
        else
          gating_next_state = `RUN;
      end
      `WAIT_FOR_IDLE: begin
        next_idle_delay   = 1'h1;
        if (~cactive_ot & ~cactive_wakeup_fsm) begin
          gating_next_state = `IDLE_DELAY;
          next_port_enable  = 1'b0;
          next_domain_ack   = 1'b1;
        end else begin
          gating_next_state = `WAIT_FOR_IDLE;
          next_port_enable  = 1'b1;
          next_domain_ack   = 1'b1;
        end
      end
      `IDLE_DELAY: begin
        next_port_enable = 1'b0;
        next_domain_ack = 1'b1;
        if (idle_delay) begin
          next_idle_delay   = idle_delay - 1'h1;
          gating_next_state = `IDLE_DELAY;
        end else begin
          next_idle_delay   = 1'h1;
          if (cactive_ot | cactive_wakeup_fsm) begin
            gating_next_state = `WAIT_FOR_IDLE;
          end else begin
            gating_next_state = `IDLE;
          end
        end
      end
      `IDLE: begin
        next_idle_delay   = 1'h1;
        if (csysreq_sync == 1) begin
          gating_next_state = `RUN;
          next_port_enable = 1'b1;
          next_domain_ack = 1'b1;
        end else begin
          gating_next_state = `IDLE;
          next_port_enable = 1'b0;
          next_domain_ack = 1'b0;
        end
      end
      default: begin 
          next_idle_delay   = 1'hx;
          next_port_enable  = 1'bx;
          next_domain_ack   = 1'bx;
          gating_next_state = 2'bxx;
      end
    endcase
  end

  assign p0_axis_port_enable = port_enable_reg;
  assign p1_axis_port_enable = port_enable_reg;
  assign p2_axis_port_enable = port_enable_reg;

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  assert_never_unknown #(1, 1, 0,"CSysReq should never be X in DMU")
    ovl_csysreq_unknown
    ( .clk       (aclk),
      .reset_n   (aresetn),
      .qualifier (1'b1),
      .test_expr (csysreq_sync)
    );

`endif


endmodule

`include "nic400_dmu_main_undefs_sse710_dbg3s1m.v"



