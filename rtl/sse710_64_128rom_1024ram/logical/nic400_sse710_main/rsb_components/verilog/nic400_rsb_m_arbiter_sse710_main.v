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



module nic400_rsb_m_arbiter_sse710_main
  (
   rclk,
   rresetn,

   rsb_data_pass,
   rsb_valid_pass,
   rsb_ready_pass,

   rsb_data_new,
   rsb_valid_new,
   rsb_ready_new,

   rsb_data_m,
   rsb_valid_m,
   rsb_ready_m
   );

`include "nic400_rsb_defs_sse710_main.v"

  input                   rclk;         
  input                   rresetn;      

  input             [7:0] rsb_data_pass;
  input                   rsb_valid_pass;
  output                  rsb_ready_pass;
  
  input             [7:0] rsb_data_new;
  input                   rsb_valid_new;
  output                  rsb_ready_new;
  
  output            [7:0] rsb_data_m;
  output                  rsb_valid_m;
  input                   rsb_ready_m;



  wire                    new_arb_pass_sel;
  wire                    arb_pass_sel;
  wire                    arb_pass_sel_reg_en;
  reg                     arb_pass_sel_reg;

  wire                    rsb_m_state_reg_en;
  reg [3:0]               rsb_m_state;
  reg [3:0]               rsb_m_state_reg;

  wire                    rsb_valid_m_i;

  assign rsb_valid_m    =  rsb_valid_m_i;
  assign rsb_data_m     =  arb_pass_sel ? rsb_data_pass : rsb_data_new;
  assign rsb_valid_m_i  =  arb_pass_sel ? rsb_valid_pass : rsb_valid_new;
  assign rsb_ready_new  = ~arb_pass_sel & rsb_ready_m;
  assign rsb_ready_pass =  arb_pass_sel & rsb_ready_m;


  assign new_arb_pass_sel = ((rsb_valid_new & rsb_valid_pass) ?
                             ~arb_pass_sel_reg
                             : rsb_valid_pass);

  assign arb_pass_sel = ((rsb_m_state == `STATE_ADN) ? new_arb_pass_sel
                         : arb_pass_sel_reg);

  assign arb_pass_sel_reg_en = ((rsb_m_state == `STATE_ADN) & rsb_ready_m);
  
  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_arb_reg
    if (~rresetn)
      arb_pass_sel_reg <= 1'b0;
    else if (arb_pass_sel_reg_en)
      arb_pass_sel_reg <= arb_pass_sel;
  end
  
  always @(rsb_valid_new or rsb_valid_pass or rsb_m_state_reg)
  begin : p_state_machine_comb
    case (rsb_m_state_reg)
      `STATE_IDLE,
        `STATE_DAT3:
        begin
          if (rsb_valid_new | rsb_valid_pass)
          begin
            rsb_m_state = `STATE_ADN;
          end
          else
          begin
            rsb_m_state = `STATE_IDLE;
          end
        end
      `STATE_ADN:
        begin
          rsb_m_state = `STATE_MID;
        end
      `STATE_MID:
        begin
          rsb_m_state = `STATE_CTL;
        end
      `STATE_CTL:
        begin
          rsb_m_state = `STATE_ADR1;
        end
      `STATE_ADR1:
        begin
          rsb_m_state = `STATE_ADR2;
        end
      `STATE_ADR2:
        begin
          rsb_m_state = `STATE_DAT0;
        end
      `STATE_DAT0:
        begin
          rsb_m_state = `STATE_DAT1;
        end
      `STATE_DAT1:
        begin
          rsb_m_state = `STATE_DAT2;
        end
      `STATE_DAT2:
        begin
          rsb_m_state = `STATE_DAT3;
        end

      `STATE_WAIT,
        `STATE_U4_B,
        `STATE_U4_C,
        `STATE_U4_D,
        `STATE_U4_E,
        `STATE_U4_F:
          begin
            rsb_m_state = `STATE_IDLE;
          end

      default:
        begin
          rsb_m_state = `STATE_U4_X;
        end
    endcase 
  end 

  assign rsb_m_state_reg_en = (rsb_valid_m_i & rsb_ready_m);

  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_m_state
    if (~rresetn)
      rsb_m_state_reg <= `STATE_IDLE;
    else if (rsb_m_state_reg_en)
      rsb_m_state_reg <= rsb_m_state;
  end

  
`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  wire                    illegal_state;        

  assign illegal_state = (rsb_m_state_reg == `STATE_WAIT) |
                         (rsb_m_state_reg == `STATE_U4_B) |
                         (rsb_m_state_reg == `STATE_U4_C) |
                         (rsb_m_state_reg == `STATE_U4_D) |
                         (rsb_m_state_reg == `STATE_U4_E) |
                         (rsb_m_state_reg == `STATE_U4_F);

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Arbiter): RSB entered illegal state.")
  rsb_illegal_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (illegal_state)
  );


  assert_never_unknown #(`OVL_WARNING,
                 4, 
                 `OVL_ASSERT,
                 "RSB (Master - Arbiter): RSB entered unreachable state.")
  rsb_unreachable_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .qualifier  (1'b1),
    .test_expr  (rsb_m_state_reg)
  );

`endif 

`include "nic400_rsb_undefs_sse710_main.v"

endmodule 


