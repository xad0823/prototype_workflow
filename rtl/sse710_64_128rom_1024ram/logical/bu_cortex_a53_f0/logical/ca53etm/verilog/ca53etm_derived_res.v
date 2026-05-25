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

// -----------------------------
// Overview
// -----------------------------
//
// ETM Derived Resources
// This block does the following operations:
// 1) Sequencer
// 2) Counter 0 & 1
// 3) External Outputs
// 4) Timestamp
// 5) Extended external Inputs
//

// -----------------------------
// Module Declaration
// -----------------------------
//
`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_derived_res (



// -----------------------------
// Interface Signals
// -----------------------------

// Global inputs
  input wire                  clk_gated,                            // CPU clock
  input wire                  po_reset_n,                           // Power On reset

// Inputs
  input wire                  resource_active_t2_i,                 // Resource active
  input wire                  resource_active_t3_i,                 // Resource active
  input wire                  resource_active_t4_i,                 // Resource active
  input wire                  resource_active_t5_i,                 // Resource active
  input wire                  trace_req_t0_i,                         // Combined enable
  input wire  [16:0]          apb_pwdatadbg_16to0_i,                // Register Write Data
  input wire  [22:2]          evt_resources_t2_i,                   // Resource Bus

  input wire  [15:0]          counter0_reload_reg_i,                // Counter 0 Reload Register Value
  input wire  [15:0]          counter1_reload_reg_i,                // Counter 1 Reload Register Value
  input wire  [4:0]           counter0_cntevent_reg_i,              // Counter 0 Enable Event Register
  input wire  [4:0]           counter1_cntevent_reg_i,              // Counter 1 Enable Event Register
  input wire                  counter0_rldself_reg_i,               // Counter 0 Self Reload Mode
  input wire                  counter1_rldself_reg_i,               // Counter 1 Self Reload Mode
  input wire                  counter1_cntchain_reg_i,              // Counter 1 Chain Mode
  input wire  [4:0]           counter0_rldevent_reg_i,              // Counter 0 Reload Event Register
  input wire  [4:0]           counter1_rldevent_reg_i,              // Counter 1 Reload Event Register
  input wire                  counter0_write_i,                     // Write to Counter 0
  input wire                  counter1_write_i,                     // Write to Counter 1
  input wire                  counter0_control_write_i,             // Write to Counter 0
  input wire                  counter1_control_write_i,             // Write to Counter 1

  input wire  [4:0]           seq_transition_b0_reg_i,              // Sequencer B0 Transition Event Register
  input wire  [4:0]           seq_transition_f0_reg_i,              // Sequencer F0 Transition Event Register
  input wire  [4:0]           seq_transition_b1_reg_i,              // Sequencer B1 Transition Event Register
  input wire  [4:0]           seq_transition_f1_reg_i,              // Sequencer F1 Transition Event Register
  input wire  [4:0]           seq_transition_b2_reg_i,              // Sequencer B2 Transition Event Register
  input wire  [4:0]           seq_transition_f2_reg_i,              // Sequencer F2 Transition Event Register
  input wire  [4:0]           seq_rst_reg_i,                        // Sequencer Reset Event Register
  input wire                  seq_write_i,                          // Write to Sequencer State

  input wire  [4:0]           event0_sel_reg_i,                     // Event/External Output 0 Event Register
  input wire  [4:0]           event1_sel_reg_i,                     // Event/External Output 1 Event Register
  input wire  [4:0]           event2_sel_reg_i,                     // Event/External Output 2 Event Register
  input wire  [4:0]           event3_sel_reg_i,                     // Event/External Output 3 Event Register

  input wire  [3:0]           gov_extin_i,                          // External input to ETM
  input wire  [25:0]          dpu_pmuevent_i,                       // Event bus from PMU
  input wire  [4:0]           extin_sel0_reg_i,                     // Extended External Input 0 Selection
  input wire  [4:0]           extin_sel1_reg_i,                     // Extended External Input 1 Selection
  input wire  [4:0]           extin_sel2_reg_i,                     // Extended External Input 2 Selection
  input wire  [4:0]           extin_sel3_reg_i,                     // Extended External Input 3 Selection

  input wire  [4:0]           ts_event_reg_i,                       // Time Stamp Event


// Outputs
  output wire                 trcstatr_pmstable_o,                  // PMSTABLE bit read value in status register

  output wire  [15:0]         counter0_value_o,                     // Counter 0 Value to Read Mux
  output wire  [15:0]         counter1_value_o,                     // Counter 1 Value to Read Mux
  output wire                 counter0_zero_t3_o,                   // Counter 0 at Zero to Resource Bus
  output wire                 counter1_zero_t3_o,                   // Counter 1 at Zero to Resource Bus

  output wire  [1:0]          seq_state_t2_o,                       // Sequencer State Value to Read Mux
  output wire  [3:0]          seq_resource_t2_o,                    // Sequencer State Value to Resource Bus

  output wire  [3:0]          etm_extout_o,                         // EXT OUT of ETM to tracegen/PMU/CTI

  output wire  [3:0]          extin_rsrc_t2_o,                      // External Input to Resource Bus

  output wire                 ts_event_t2_o                         // TimeStamp Event Enable to Trace Generation

 );

  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire                         counter0_reload;
  wire                         counter_seq_enable;
  reg  [  3:  0]               cti_event_etm_t1;
  reg  [ 25:  0]               pm_event_bus_t1;
  wire                         extout_enabled_t2;
  wire [  1:  0]               seq_end_state_t1;
  wire                         seq_event_active;
  wire                         seq_event_b0;
  wire                         seq_event_b1;
  wire                         seq_event_b2;
  wire                         seq_event_f0;
  wire                         seq_event_f1;
  wire                         seq_event_f2;
  wire                         seq_event_rst;
  wire                         seq_resource_en               ;
  wire                         seq_low_power_en;
  wire [  3:  0]               seq_rsrc_vld_t1;
  wire [  3:  0]               seq_resource_t1;
  reg  [  3:  0]               seq_resource_t2;
  reg                          trace_req_t1;
  reg                          trace_req_t2;
  

  wire [  3:  0]               seq_rsrc_t1;
  wire                         seq_state_en;
  wire [  1:  0]               seq_state_t1;
  reg  [  1:  0]               seq_state_t2;
  genvar                       i;

  wire [4:0]                   event_sel_reg[3:0];
  wire [4:0]                   extin_sel_reg[3:0];
// -----------------------------
// Main Code
// -----------------------------
// Generate PMSTABLE
  assign trcstatr_pmstable_o = ~ (resource_active_t2_i |
                                  resource_active_t3_i |
                                  resource_active_t4_i |
                                  resource_active_t5_i);

// Counter and Sequencer need to go through one more iteration when trace is disabled
  assign counter_seq_enable = (resource_active_t2_i | resource_active_t3_i | resource_active_t4_i);

//---------------------------------------------------------------------------
// Counters
//---------------------------------------------------------------------------

// Counter 0 Resource
  ca53etm_counter u_counter0 (
    .clk_gated                 (clk_gated),
    .po_reset_n                (po_reset_n),
    .counter_reload_reg_i      (counter0_reload_reg_i[15:0]),
    .counter_cntevent_reg_i    (counter0_cntevent_reg_i[4:0]),
    .counter_rldevent_reg_i    (counter0_rldevent_reg_i[4:0]),
    .counter_rldself_reg_i     (counter0_rldself_reg_i),
    .counter_cntchain_reg_i    (1'b0),
    .counter_write_i           (counter0_write_i),
    .counter_control_write_i   (counter0_control_write_i),
    .apb_pwdatadbg_16to0_i     (apb_pwdatadbg_16to0_i),
    .evt_resources_t2_i        (evt_resources_t2_i[22:2]),
    .counter_enabled_i         (counter_seq_enable),
    .other_counter_reload_i    (1'b0),

    .counter_zero_t3_o         (counter0_zero_t3_o),
    .counter_value_o           (counter0_value_o[15:0]),
    .counter_reload_o          (counter0_reload)
  );

// Counter 1 Resource
  ca53etm_counter u_counter1 (
    .clk_gated                 (clk_gated),
    .po_reset_n                (po_reset_n),
    .counter_reload_reg_i      (counter1_reload_reg_i[15:0]),
    .counter_cntevent_reg_i    (counter1_cntevent_reg_i[4:0]),
    .counter_rldevent_reg_i    (counter1_rldevent_reg_i[4:0]),
    .counter_rldself_reg_i     (counter1_rldself_reg_i),
    .counter_cntchain_reg_i    (counter1_cntchain_reg_i),
    .counter_write_i           (counter1_write_i),
    .counter_control_write_i   (counter1_control_write_i),
    .apb_pwdatadbg_16to0_i     (apb_pwdatadbg_16to0_i),
    .evt_resources_t2_i        (evt_resources_t2_i[22:2]),
    .counter_enabled_i         (counter_seq_enable),
    .other_counter_reload_i    (counter0_reload),

    .counter_zero_t3_o         (counter1_zero_t3_o),
    .counter_value_o           (counter1_value_o[15:0]),
    .counter_reload_o          (/*Not used*/)
  );


//---------------------------------------------------------------------------
//   4 State Sequencer
//---------------------------------------------------------------------------

// The ETM Sequencer is a 4-state state machine with 6 possible
// state transition arcs and 1 reset transition arc.
// The state transitions are controlled by 7 Event Generators.
//
// The 4 possible states are denoted S0, S1, S2, S3.
//
// The state diagram is shown below:
//
//                         ------------
//            ------------>|    S0    |
//            |            ------------
//            |              ^      |
//            |              |      |
//            |              B0     F0
//            |              |      |
//            |              |      v
//            |            ------------
//            ----RST------|    S1    |
//            |            ------------
//            |              ^      |
//            |              |      |
//            |              B1     F1
//            |              |      |
//            |              |      v
//            |            ------------
//            ----RST------|    S2    |
//            |            ------------
//            |              ^      |
//            |              |      |
//            |              B2     F2
//            |              |      |
//            |              |      v
//            |            ------------
//            ----RST------|    S3    |
//                         ------------
//

  ca53etm_event u_seq_event_rst (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_rst_reg_i[4]),
    .event_sel_i        (seq_rst_reg_i[3:0]),

    .event_out_o        (seq_event_rst)
  );

  ca53etm_event u_seq_event_b0 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_b0_reg_i[4]),
    .event_sel_i        (seq_transition_b0_reg_i[3:0]),
                        
    .event_out_o        (seq_event_b0)
  );

  ca53etm_event u_seq_event_f0 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_f0_reg_i[4]),
    .event_sel_i        (seq_transition_f0_reg_i[3:0]),
                        
    .event_out_o        (seq_event_f0)
  );

  ca53etm_event u_seq_event_b1 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_b1_reg_i[4]),
    .event_sel_i        (seq_transition_b1_reg_i[3:0]),
                        
    .event_out_o        (seq_event_b1)
  );

  ca53etm_event u_seq_event_f1 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_f1_reg_i[4]),
    .event_sel_i        (seq_transition_f1_reg_i[3:0]),
                        
    .event_out_o        (seq_event_f1)
  );

  ca53etm_event u_seq_event_b2 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_b2_reg_i[4]),
    .event_sel_i        (seq_transition_b2_reg_i[3:0]),
                        
    .event_out_o        (seq_event_b2)
  );

  ca53etm_event u_seq_event_f2 (
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (seq_transition_f2_reg_i[4]),
    .event_sel_i        (seq_transition_f2_reg_i[3:0]),
                        
    .event_out_o        (seq_event_f2)
  );

// Update the sequencer state from 3 possible sources:
// 1) APB write to sequencer state when trace enable is low
// 2) Sequencer Reset Event is true.
// 3) Transition Event is true.
//    If both forward and backward are true in the same cycle then
//    forward transition takes priority
//    If a chain of consecutive transitions are true in the same cycle
//    then end states determined by last transition in the chain
//    is reached in the same cycle.
//
// Sequencer resource needs to be active depending upon current state
// If a chain of consecutive transitions are true in the same cycle
// then sequencer resources needs to be true for all intermediate
// sequencer states.

  // here's the pla table sent to espresso:
  //
  // seq_state_t2[1:0]
  // |  seq_event_rst
  // |  | seq_event_f0
  // |  | | seq_event_b0
  // |  | | | seq_event_f1
  // |  | | | | seq_event_b1
  // |  | | | | | seq_event_f2
  // |  | | | | | | seq_event_b2
  // |  | | | | | | | seq_rsrc_t1[3:0]
  // |  | | | | | | | |    seq_end_state_t1[1:0]
  // |  | | | | | | | |    |
  // 00 1 - - - - - - 0001 00
  // 00 0 0 - - - - - 0001 00
  // 00 0 1 - 0 - - - 0010 01
  // 00 0 1 - 1 - 0 - 0110 10
  // 00 0 1 - 1 - 1 - 1110 11
  // 01 1 - - - - - - 0001 00
  // 01 0 0 1 0 - - - 0001 00
  // 01 0 1 - 0 - - - 0010 01
  // 01 0 0 0 0 - - - 0010 01
  // 01 0 - - 1 - 0 - 0100 10
  // 01 0 - - 1 - 1 - 1100 11
  // 10 1 - - - - - - 0001 00
  // 10 0 0 1 0 1 0 - 0011 00
  // 10 0 1 - 0 1 0 - 0010 01
  // 10 0 0 0 0 1 0 - 0010 01
  // 10 0 - - 1 - 0 - 0100 10
  // 10 0 - - 0 0 0 - 0100 10
  // 10 0 - - - - 1 - 1000 11
  // 11 1 - - - - - - 0001 00
  // 11 0 0 1 0 1 0 1 0111 00
  // 11 0 1 - 0 1 0 1 0110 01
  // 11 0 0 0 0 1 0 1 0110 01
  // 11 0 - - 1 - 0 1 0100 10
  // 11 0 - - 0 0 0 1 0100 10
  // 11 0 - - - - 1 - 1000 11
  // 11 0 - - - - 0 0 1000 11
  // default:
  //
  // the following equations are the espresso output

  assign seq_rsrc_t1[3] = (!seq_event_rst&seq_event_f0&seq_event_f1&seq_event_f2) | (
    seq_state_t2[0]&!seq_event_rst&seq_event_f1&seq_event_f2) | (
    seq_state_t2[1]&seq_state_t2[0]&!seq_event_rst&!seq_event_b2) | (
    seq_state_t2[1]&!seq_event_rst&seq_event_f2);

  assign seq_rsrc_t1[2] = (seq_state_t2[1]&seq_state_t2[0]&!seq_event_rst
    &!seq_event_f1&seq_event_b1&!seq_event_f2&seq_event_b2) | (
    seq_state_t2[1]&!seq_event_rst&!seq_event_b1&!seq_event_f2
    &seq_event_b2) | (seq_state_t2[0]&!seq_event_rst&seq_event_f1
    &!seq_event_f2&seq_event_b2) | (seq_state_t2[1]&!seq_state_t2[0]
    &!seq_event_rst&!seq_event_b1&!seq_event_f2) | (!seq_state_t2[1]
    &!seq_state_t2[0]&!seq_event_rst&seq_event_f0&seq_event_f1) | (
    seq_state_t2[1]&!seq_state_t2[0]&!seq_event_rst&seq_event_f1
    &!seq_event_f2) | (!seq_state_t2[1]&seq_state_t2[0]&!seq_event_rst
    &seq_event_f1);

  assign seq_rsrc_t1[1] = (seq_state_t2[1]&seq_state_t2[0]&!seq_event_rst
    &!seq_event_f1&seq_event_b1&!seq_event_f2&seq_event_b2) | (
    seq_state_t2[1]&!seq_state_t2[0]&!seq_event_rst&!seq_event_f1
    &seq_event_b1&!seq_event_f2) | (!seq_state_t2[1]&seq_state_t2[0]
    &!seq_event_rst&!seq_event_b0&!seq_event_f1) | (!seq_state_t2[1]
    &!seq_state_t2[0]&!seq_event_rst&seq_event_f0&seq_event_f1) | (
    !seq_state_t2[1]&!seq_event_rst&seq_event_f0&!seq_event_f1);

  assign seq_rsrc_t1[0] = (!seq_event_f0&seq_event_b0&!seq_event_f1&seq_event_b1
    &!seq_event_f2&seq_event_b2) | (!seq_state_t2[0]&!seq_event_f0
    &seq_event_b0&!seq_event_f1&seq_event_b1&!seq_event_f2) | (
    !seq_state_t2[1]&!seq_event_f0&seq_event_b0&!seq_event_f1) | (
    !seq_state_t2[1]&!seq_state_t2[0]&!seq_event_f0) | (
    seq_event_rst);

  assign seq_end_state_t1[1] = (seq_state_t2[1]&!seq_event_rst&!seq_event_b1
    &!seq_event_f2&seq_event_b2) | (seq_state_t2[0]&!seq_event_rst
    &seq_event_f1&!seq_event_f2&seq_event_b2) | (seq_state_t2[1]
    &!seq_state_t2[0]&!seq_event_rst&!seq_event_b1&!seq_event_f2) | (
    !seq_state_t2[1]&!seq_state_t2[0]&!seq_event_rst&seq_event_f0
    &seq_event_f1) | (seq_state_t2[1]&!seq_state_t2[0]&!seq_event_rst
    &seq_event_f1&!seq_event_f2) | (!seq_state_t2[1]&seq_state_t2[0]
    &!seq_event_rst&seq_event_f1) | (seq_state_t2[1]&seq_state_t2[0]
    &!seq_event_rst&!seq_event_b2) | (seq_state_t2[1]&!seq_event_rst
    &seq_event_f2);

  assign seq_end_state_t1[0] = (!seq_event_rst&seq_event_f0&seq_event_f1
    &seq_event_f2) | (seq_state_t2[1]&!seq_event_rst&!seq_event_b0
    &!seq_event_f1&seq_event_b1) | (seq_state_t2[0]&!seq_event_rst
    &seq_event_f1&seq_event_f2) | (!seq_state_t2[1]&seq_state_t2[0]
    &!seq_event_rst&!seq_event_b0&!seq_event_f1) | (!seq_event_rst
    &seq_event_f0&!seq_event_f1&seq_event_b1) | (!seq_state_t2[1]
    &!seq_event_rst&seq_event_f0&!seq_event_f1) | (seq_state_t2[1]
    &seq_state_t2[0]&!seq_event_rst&!seq_event_b2) | (
    seq_state_t2[1]&!seq_event_rst&seq_event_f2);


  assign seq_state_t1[1:0] = ({2{seq_write_i}} & apb_pwdatadbg_16to0_i[1:0]) |
                             ({2{seq_event_active}} & seq_end_state_t1[1:0]);

  assign seq_event_active = counter_seq_enable &
                            (seq_event_rst |
                             seq_event_b0 |
                             seq_event_f0 |
                             seq_event_b1 |
                             seq_event_f1 |
                             seq_event_b2 |
                             seq_event_f2);

  assign seq_state_en = seq_write_i |                  // APB Write
                        seq_event_active;              // Transition event is active

  always @(posedge clk_gated or negedge po_reset_n)
  begin: useq_state_t2_1_0
    if (!po_reset_n)
      seq_state_t2[1:0] <= {2{1'b0}};
    else if (seq_state_en)
      seq_state_t2[1:0] <= seq_state_t1[1:0];
  end
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ustrace_req
    if (!po_reset_n) begin
      trace_req_t1 <= 1'b0;
      trace_req_t2 <= 1'b0;
      end else begin
      trace_req_t1 <= trace_req_t0_i;
      trace_req_t2 <= trace_req_t1;
      end
  end
  
    
// Read value in sequencer state register
  assign seq_state_t2_o[1:0] = seq_state_t2[1:0];

  // here's the pla table sent to espresso:
  //
  // seq_state_en
  // | seq_resource_t2[3:0]
  // | |    seq_resource_en
  // | |    |
  // 1 ---- 1
  // 0 0000 0
  // 0 0001 0
  // 0 0010 0
  // 0 0011 1
  // 0 0100 0
  // 0 0101 1
  // 0 0110 1
  // 0 0111 1
  // 0 1000 0
  // 0 1001 1
  // 0 1010 1
  // 0 1011 1
  // 0 1100 1
  // 0 1101 1
  // 0 1110 1
  // 0 1111 1
  // default:
  //
  // the following equations are the espresso output

  assign seq_resource_en = (seq_resource_t2[3]&seq_resource_t2[2]) | (
    seq_resource_t2[3]&seq_resource_t2[1]) | (seq_resource_t2[2]
    &seq_resource_t2[1]) | (seq_resource_t2[3]&seq_resource_t2[0]) | (
    seq_resource_t2[2]&seq_resource_t2[0]) | (seq_resource_t2[1]
    &seq_resource_t2[0]) | (seq_state_en);

  // In low power state, keep old value static
  assign seq_low_power_en = seq_resource_en & (~trace_req_t2 | counter_seq_enable);
                            
// Resource decoding
// When sequencer is disabled, and more than one transition occurred in the same cycle then
// use seq_state_t2[1:0] instead of seq_rsrc_t1[3:0] for updating seq_resource_t2[3:0]
  assign seq_rsrc_vld_t1[3] = (counter_seq_enable) ? (seq_rsrc_t1[3]) : ( seq_state_t2[1] &  seq_state_t2[0]);
  assign seq_rsrc_vld_t1[2] = (counter_seq_enable) ? (seq_rsrc_t1[2]) : ( seq_state_t2[1] & ~seq_state_t2[0]);
  assign seq_rsrc_vld_t1[1] = (counter_seq_enable) ? (seq_rsrc_t1[1]) : (~seq_state_t2[1] &  seq_state_t2[0]);
  assign seq_rsrc_vld_t1[0] = (counter_seq_enable) ? (seq_rsrc_t1[0]) : (~seq_state_t2[1] & ~seq_state_t2[0]);

  assign seq_resource_t1[3] = (seq_write_i) ? ( apb_pwdatadbg_16to0_i[1] &  apb_pwdatadbg_16to0_i[0]) : (seq_rsrc_vld_t1[3]);
  assign seq_resource_t1[2] = (seq_write_i) ? ( apb_pwdatadbg_16to0_i[1] & ~apb_pwdatadbg_16to0_i[0]) : (seq_rsrc_vld_t1[2]);
  assign seq_resource_t1[1] = (seq_write_i) ? (~apb_pwdatadbg_16to0_i[1] &  apb_pwdatadbg_16to0_i[0]) : (seq_rsrc_vld_t1[1]);
  assign seq_resource_t1[0] = (seq_write_i) ? (~apb_pwdatadbg_16to0_i[1] & ~apb_pwdatadbg_16to0_i[0]) : (seq_rsrc_vld_t1[0]);

// Reset to 4'b0001 - State 1
  always @(posedge clk_gated or negedge po_reset_n)
  begin: useq_resource_t2
    if (!po_reset_n) begin
      seq_resource_t2[3:1] <= {3{1'b0}};
      seq_resource_t2[0]   <= {1{1'b1}};
    end
    else if (seq_low_power_en) begin
      seq_resource_t2[3:1] <= seq_resource_t1[3:1];
      seq_resource_t2[0]   <= seq_resource_t1[0];
    end
  end

// Sequencer state resource
  assign seq_resource_t2_o[3:0] = seq_resource_t2[3:0];


//---------------------------------------------------------------------------------
// External Outputs 0-3
//---------------------------------------------------------------------------------
  assign extout_enabled_t2   = (resource_active_t2_i | resource_active_t3_i |
                                resource_active_t4_i |
                                resource_active_t5_i);


  assign event_sel_reg[0] = event0_sel_reg_i;
  assign event_sel_reg[1] = event1_sel_reg_i;
  assign event_sel_reg[2] = event2_sel_reg_i;
  assign event_sel_reg[3] = event3_sel_reg_i;

  generate for (i = 0; i < 4; i = i + 1) begin : g_extout

    ca53etm_extout u_extout (
      .clk_gated                 (clk_gated),
      .po_reset_n                (po_reset_n),
      .evt_resources_t2_i        (evt_resources_t2_i[22:2]),
      .extout_event_reg_i        (event_sel_reg[i]),
      .extout_enabled_t2_i       (extout_enabled_t2),

      .extout_o                  (etm_extout_o[i])
    );
  end endgenerate

//---------------------------------------------------------------------------
//   External inputs
//---------------------------------------------------------------------------

  always @(posedge clk_gated)
  begin: ucti_event_etm_t1_3_0
    cti_event_etm_t1[3:0] <= gov_extin_i[3:0];
  end

// Pipeline PMU Events
  always @(posedge clk_gated)
  begin: upm_event_bus_t1
    pm_event_bus_t1 <= dpu_pmuevent_i;
  end

//---------------------------------------------------------------------------
// External Input Selector 0-3
//---------------------------------------------------------------------------
  assign extin_sel_reg[0] = extin_sel0_reg_i;
  assign extin_sel_reg[1] = extin_sel1_reg_i;
  assign extin_sel_reg[2] = extin_sel2_reg_i;
  assign extin_sel_reg[3] = extin_sel3_reg_i;

  generate for (i = 0; i < 4; i = i + 1) begin : g_extin

    ca53etm_extin u_extin (
      .clk_gated                 (clk_gated),
      .extin_sel_reg_i           (extin_sel_reg[i]),
      .cti_event_etm_t1_i        (cti_event_etm_t1[3:0]),
      .pm_event_bus_t1_i         (pm_event_bus_t1),

      .extin_rsrc_t2_o           (extin_rsrc_t2_o[i])
    );
  end  endgenerate

//---------------------------------------------------------------------------
// Time Stamp Event
//---------------------------------------------------------------------------

// TimeStamp event decode
  ca53etm_event u_ts_event(
    .evt_resources_t2_i (evt_resources_t2_i[22:2]),
    .event_type_i       (ts_event_reg_i[4]),
    .event_sel_i        (ts_event_reg_i[3:0]),

    .event_out_o        (ts_event_t2_o)
  );

//--------------------------------------------------------------------------
// ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON

 `include "ca53etm_val_defs.v"
  // Sequencer can be in maximum of 3 states, not all 4.
  usva_seq_unreach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                     (seq_resource_t2 != 4'b0000) &
                                     (seq_resource_t2 != 4'b0101) &
                                     (seq_resource_t2 != 4'b1101) &
                                     (seq_resource_t2 != 4'b1011) &
                                     (seq_resource_t2 != 4'b1010) &
                                     (seq_resource_t2 != 4'b1001) &
                                     (seq_resource_t2 != 4'b1111)
                                     )
    `SVA_FATAL("Maximum of 3 sequencer states can be set, must be continous");
                                     
  usva_seq_match: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (seq_resource_t2[seq_state_t2] == 1'b1))
    `SVA_FATAL("Sequencer resource must match sequencer state");


`endif
  

endmodule // ca53etm_derived_res
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

