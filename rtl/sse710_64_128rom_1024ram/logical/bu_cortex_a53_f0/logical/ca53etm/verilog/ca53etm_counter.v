//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//
// Overview
// ========
//

// Counter Resource Block
// 16 bit down counter with counter_reload_o and read/write access
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_counter (



//
// Interface Signals
// =================
//

// Global inputs
  input wire            clk_gated,                    // CPU Clock
  input wire            po_reset_n,                   // Power on reset

// Inputs
  input wire  [15:0]    counter_reload_reg_i,         // Reload Value Register
  input wire  [4:0]     counter_cntevent_reg_i,       // Enable Event Register
  input wire  [4:0]     counter_rldevent_reg_i,       // Reload Event Register
  input wire            counter_rldself_reg_i,        // Counter Self Reload mode
  input wire            counter_cntchain_reg_i,       // Counter Chain mode
  input wire            counter_write_i,              // Counter Value Register Write Enable
  input wire            counter_control_write_i,      // Counter Value Register Write Enable
  input wire  [16:0]    apb_pwdatadbg_16to0_i,        // Counter Value Register Write Value
  input wire  [22:2]    evt_resources_t2_i,           // Resources Bus
  input wire            counter_enabled_i,            // Counter resource is enabled
  input wire            other_counter_reload_i,       // Other counter reload

// Outputs
  output wire           counter_zero_t3_o,            // Counter Value is zero flag to resource bus
  output wire  [15:0]   counter_value_o,              // Counter Value Register Read Value
  output wire           counter_reload_o              // Counter Reload is true

 );
  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire           counter_cntevent_t2;
  wire           counter_decrement;
  wire           counter_en;
  wire           counter_rldevent_t2;
  wire           counter_reload_t2;
  wire           counter_rldself;
  wire [ 15:  0] counter_sub;
  wire [ 15:  0] counter_value_t2;
  reg  [ 15:  0] counter_value_t3;
  wire           counter_value_zero_t3;
  wire           counter_zero_en;
  wire           counter_zero_t2;
  reg            counter_zero_t3;

  // -----------------------------
  // Main Code
  // -----------------------------


// Update Counter from 3 possible sources:
// Counter programming
//     -> APB write to counter when trace enable is low
// Reload event
//     -> RLDSELF is false (Normal mode)
//        Counter reload event is active
//     -> RLDSELF is true
//        Counter enable event is active and counter is zero or
//        Counter reload event is active
// Decrement event
//     -> CNTCHAIN is false
//        Counter enable event is active and counter is non-zero
//     -> CNTCHAIN is true (Only possible for counter 1)
//        Counter1 enable event is active and counter is non-zero
//        Counter0 (i.e other counter) reload event is active

// Counter at zero resource
//     -> RLDSELF is false (Normal mode)
//        Counter at zero resource is active as long as counter value is zero
//        Counter value can be zero because of register write/decrement/reload
//     -> RLDSELF is true
//        Counter at zero resource is active for at most one cycle when counter
//        value is zero, self reload event is true and reload event is false
//

// Generate count reload event
  ca53etm_event u_counter_event(
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (counter_rldevent_reg_i[4]),
    .event_sel_i        (counter_rldevent_reg_i[3:0]),

    .event_out_o        (counter_rldevent_t2)
);

// Generate count enable event
  ca53etm_event  u_count_en_event (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (counter_cntevent_reg_i[4]),
    .event_sel_i        (counter_cntevent_reg_i[3:0]),

    .event_out_o        (counter_cntevent_t2)
);

// Count event and counter non-zero
  assign counter_decrement = counter_enabled_i &                                       // Counter Enabled
                             ~counter_rldevent_t2 &                                    // Reload Event is not active
                             (counter_value_t3[15:0] != 16'h0000) &                    // Counter is not at zero
                             (counter_cntevent_t2 |                                    // Count enable event is active or
                              (counter_cntchain_reg_i & other_counter_reload_i));      // Count chain event is active

// Reload self event and counter zero
  assign counter_rldself = counter_enabled_i &                                         // Counter Enabled
                           ~counter_rldevent_t2 &                                      // Reload event not active
                            counter_value_zero_t3 &                                    // Counter is currently at zero
                            counter_rldself_reg_i &                                    // Counter in reload self mode
                           (counter_cntevent_t2 |                                      // Count enable event is active or
                            (counter_cntchain_reg_i & other_counter_reload_i));        // Count chain event is active

// Reload event
  assign counter_reload_t2 = counter_enabled_i & (counter_rldevent_t2 |                 // Normal reload event
                                                  counter_rldself);                     // Reload self event
  assign counter_reload_o  = counter_reload_t2;

// Decremented counter value
  assign counter_sub[15:0] = (counter_value_t3[15:0] - {{15{1'b0}},1'b1});

// Counter value for next cycle
  assign counter_value_t2[15:0] = ({16{counter_write_i}} & apb_pwdatadbg_16to0_i[15:0])  |// APB write
                                  ({16{counter_reload_t2}} & counter_reload_reg_i[15:0]) |// Reload Event
                                  ({16{counter_decrement}} & counter_sub[15:0]);          // Decrement

// Instantiate flop to hold counter value
  assign counter_en = counter_write_i |                           // APB Write to counter value
                      counter_reload_t2 |                         // Reload Event
                      counter_decrement;                          // Decrement

  always @(posedge clk_gated)
  begin: ucounter_value_t2_15_0
    if (counter_en)
      counter_value_t3 <= counter_value_t2;
  end


 assign counter_value_o[15:0] = counter_value_t3[15:0];
 assign counter_value_zero_t3 = counter_value_t3 == 16'h0000;

//---------------------------------------------------------------------------
// Counter at Zero Resource
//---------------------------------------------------------------------------

// Trace Enabled:
// Detect counter about to become zero in normal mode, or
// already zero and will be self reloaded
//
// Trace Disabled:
// loaded with zero in normal mode or
// already zero and counter mode selected as normal mode
//

  assign counter_zero_t2 = // APB write to counter value in normal mode
                           (counter_write_i & ~(|apb_pwdatadbg_16to0_i[15:0]) & ~counter_rldself_reg_i) |
                           // APB write to counter control for normal mode
                           (counter_control_write_i & ~apb_pwdatadbg_16to0_i[16] & counter_value_zero_t3) |
                           // Reload Event with reload value 0 in normal mode
                           ((counter_reload_reg_i == 16'h0000) & counter_reload_t2 & ~counter_rldself_reg_i) |
                           // Decrement in normal mode
                           ((counter_value_t3 == 16'h0001) & counter_decrement & ~counter_rldself_reg_i);

// Instantiate flop to hold counter at zero flag
  assign counter_zero_en = counter_write_i  |                        // APB Write to counter value
                           counter_control_write_i |                 // APB Write to counter control reg
                           counter_reload_t2 |                       // Reload Event
                           counter_decrement;                        // Decrement

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucounter_zero_t3
    if (!po_reset_n)
      counter_zero_t3 <= 1'b0;
    else if (counter_zero_en)
      counter_zero_t3 <= counter_zero_t2;
  end

 assign counter_zero_t3_o = counter_zero_t3 | counter_rldself;

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

