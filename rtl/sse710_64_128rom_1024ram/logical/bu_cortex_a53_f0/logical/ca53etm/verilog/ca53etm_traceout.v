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

// This block does the following operations:
// Packs data from main FIFO for ATB Interface
// Implements ATB idle control state machine
// Implements ATB integration registers
// Handles ATB sync request and flush request
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module   ca53etm_traceout (



//
// Interface Signals
// =================
//

// Global inputs
  input wire          clk_gated,                  // Core Clock
  input wire          gov_atclken_i,              // ATB Clock enable
  input wire          po_reset_n,                 // Power on reset

// From main fifo
  input wire          fifo_valid_i,               // FIFO output valid
  input wire  [1:0]   fifo_bytes_i,               // Valid byte of the input data
  input wire  [31:0]  fifo_data_i,                // Fifo data
  input wire          fifo_flush_ack_i,           // Flush acknowledge from main fifo.
  input wire          fifo_idle_ack_i,            // Idle request propagated from fifo
  input wire          event_trigger_req_t3_i,     // Event Trigger valid

// ATB interface
  input wire          gov_atreadym_i,             // Ready for data out
  input wire          gov_afvalidm_i,             // Flush request
  input wire          gov_syncreqm_i,             // Synchronization request

// From reg
  input wire          auxctlr_frc_afready_reg_i,  // respond to AFREADY immediately
  input wire          write_ir_atb_out_o,         // IATBCTR0 ATBYTESM, AFREADYM, ATVALIDM
  input wire          write_ir_atb_data_i,        // ATDATA [31] [23] [15] [7] [0]
  input wire          write_at_id_i,              // AT ID Register
  input wire          int_test_enable_i,          // Integration Mode Enable
  input wire  [6:0]   apb_pwdatadbg_6to0_i,       // to generate ATID
  input wire  [9:8]   apb_pwdatadbg_9to8_i,       // Write data bits [9:8]

  // From viewinst
  input wire          core_at_main_run_t2_i,      // Core is in run state now. So ATB interface can resume tracing.

  // From TraceGen
  input wire          low_power_override_flush_i, // low power mode override fifo flush request

  // --------------------------------------------------------------------------
  // Outputs
  // --------------------------------------------------------------------------

// To main fifo
  output wire         fifo_ready_o,              // Ready to accept more data.
  output wire         fifo_flush_req_o,          // Single pulse flush request to main fifo

// To trc_en
  output wire         at_active_state_o,         // ATB interface run status to main idle state machine
  output wire         at_idle_ack_o,             // Handshake with main idle state machine

// ATB interface
  output wire         etm_atvalidm_o,            // ATDATA Valid
  output wire  [1:0]  etm_atbytesm_o,            // Size of ATDATA
  output wire  [31:0] etm_atdatam_o,             // ATB Data
  output wire         etm_afreadym_o,            // Flush acknowledge
  output wire  [6:0]  etm_atidm_o,               // AT ID
  output wire  [6:0]  etm_atidm_reg_o,           // AT ID register value

// To trace_gen
  output wire         sync_req_t2_o,             // External Synchronization request

// To reg
  output wire         atb_reg_ack_o,             // Handshake acknowledge for register access
  output wire         atb_afvalid_o,             // AFVALID read value in integration register
  output wire         atb_atready_o              // ATREADY read value in integration register

 );
  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  reg            af_ready_q;
  reg            af_valid_q;
  wire           at_active_state_d;
  reg            at_active_state_q;
  wire [  1:  0] at_bytes;
  reg  [  1:  0] at_bytes_q;
  wire [ 31:  0] at_data;
  wire           at_data_en;
  reg  [ 31:  0] at_data_q;
  wire [ 31:  0] at_data_value;
  wire           at_flush_ready;
  wire           at_flush_ready_en;
  reg            at_flush_ready_q;
  reg            at_flush_ready_qq;
  wire           at_flush_req;
  reg            at_flush_req_q;
  wire           at_id_en;
  reg  [  6:  0] at_id_reg_q;
  reg  [  6:  0] at_id_reg_prg;
  wire [  6:  0] at_id_reg_value;
  wire           at_idle_ack_d;
  reg            at_idle_ack_q;
  reg            at_idle_ack_qq;
  wire           at_idle_req;
  reg            at_idle_req_q;
  reg            at_main_run_q;
  wire           at_output_en;
  reg            at_ready_q;
  wire           at_valid;
  reg            at_valid_local_q;
  reg            at_valid_q;
  wire           at_vld_and_bytes_en;
  reg            atb_reg_ack_q;
  reg            atb_reg_ack_qq;
  wire           atb_reg_active;
  reg            atb_sync_req_q;
  wire           core_flush_nack;
  reg            core_flush_nack_q;
  wire           core_flush_req_d;
  reg            core_flush_req_q;
  wire           wfx_flush_active;
  reg            wfx_flush_active_q;
  wire           fifo_trigger_done;
  wire           fifo_trigger_inject;
  reg            fifo_trigger_inject_q;
  wire           fifo_trigger_inject_update;
  wire           fifo_trigger_valid;
  reg            fifo_trigger_valid_q;
  wire           fifo_trigger_valid_update;
  wire           reg_req_atb;
  wire [1:0]     mux_bytes;
  wire [31:0]    mux_data;
  wire           fifo_buf_full;
  wire           atb_advance;
  wire           fifo_buf_en;

  reg [1:0]      fifo_bytes_buf;
  reg [31:0]     fifo_data_buf;
  reg            fifo_buf_full_q;



//
// Main Code
// =========
//
//  Fifo data always accepted unless buffer is full.
//  Take output data alternately from buffer and fifo
  assign atb_advance   = (gov_atreadym_i | ~at_valid_local_q) & gov_atclken_i;
  assign fifo_buf_en   = ~fifo_buf_full_q & fifo_buf_full;
  assign fifo_buf_full = (fifo_buf_full_q | fifo_valid_i) & ~(atb_advance & ~fifo_trigger_valid_q);
  assign mux_bytes     = fifo_buf_full_q ? fifo_bytes_buf : fifo_bytes_i;
  assign mux_data      = fifo_buf_full_q ? fifo_data_buf  : fifo_data_i;


  // Capture incoming data from fifo
  always @(posedge clk_gated)
    begin: ufifo_data_buf
      if (fifo_buf_en) begin
        fifo_bytes_buf <= fifo_bytes_i;
        fifo_data_buf  <= fifo_data_i;
      end
    end // block: ufifo_data_buf

  always @(posedge clk_gated or negedge po_reset_n)
    begin: ufifo_buf_full_q
      if (!po_reset_n)
        fifo_buf_full_q  <= 1'b0;
      else
        fifo_buf_full_q  <= fifo_buf_full;
    end // block: ufifo_data_buf_q


//---------------------------------------------------------------------------
// ATVALIDM & ATBYTESM[1:0] & ATDATAM[31:0]
//---------------------------------------------------------------------------

// Enable signal for the ATB output stage
  assign at_output_en        = gov_atclken_i & ((at_valid_local_q & gov_atreadym_i & ~int_test_enable_i) |
                                                (~at_valid_local_q) | fifo_trigger_inject);

  assign at_vld_and_bytes_en = int_test_enable_i ? (gov_atclken_i & write_ir_atb_out_o & atb_reg_active) :
                                                   at_output_en | fifo_trigger_inject;

  assign at_data_en          = int_test_enable_i ? (gov_atclken_i & write_ir_atb_data_i & atb_reg_active) :
                                                   at_output_en | fifo_trigger_inject;

  assign at_valid            = int_test_enable_i ? apb_pwdatadbg_6to0_i[0] :
                                                   (fifo_valid_i | fifo_buf_full_q | fifo_trigger_inject);

// Duplicate register to avoid external output being internally sampled.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_valid_local_q
    if (!po_reset_n)
      at_valid_local_q <= 1'b0;
    else if (at_vld_and_bytes_en)
      at_valid_local_q <= at_valid;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_valid_q
    if (!po_reset_n)
      at_valid_q <= 1'b0;
    else if (at_vld_and_bytes_en)
      at_valid_q <= at_valid;
  end


  assign  etm_atvalidm_o = at_valid_q;

// ATBYTESM[1:0]
  assign at_bytes[1:0] = int_test_enable_i ? apb_pwdatadbg_9to8_i[9:8]: mux_bytes[1:0] & {2{~fifo_trigger_inject}};

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_bytes_q_1_0
    if (!po_reset_n)
      at_bytes_q[1:0] <= {2{1'b0}};
    else if (at_vld_and_bytes_en)
      at_bytes_q[1:0] <= at_bytes[1:0];
  end


  assign  etm_atbytesm_o[1:0] = at_bytes_q[1:0];

// ATDATAM[31:0]
  assign at_data[31]    = int_test_enable_i ? apb_pwdatadbg_6to0_i[4] : mux_data[31];
  assign at_data[30:24] = mux_data[30:24];
  assign at_data[23]    = int_test_enable_i ? apb_pwdatadbg_6to0_i[3] : mux_data[23];
  assign at_data[22:16] = mux_data[22:16];
  assign at_data[15]    = int_test_enable_i ? apb_pwdatadbg_6to0_i[2] : mux_data[15];
  assign at_data[14:8]  = mux_data[14:8];
  assign at_data[7]     = int_test_enable_i ? apb_pwdatadbg_6to0_i[1] : mux_data[ 7];
  assign at_data[6:1]   = mux_data[6:1];
  assign at_data[0]     = int_test_enable_i ? apb_pwdatadbg_6to0_i[0] : mux_data[ 0];

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_data_q_31_0
    if (!po_reset_n)
      at_data_q[31:0] <= {32{1'b0}};
    else if (at_data_en)
      at_data_q[31:0] <= at_data_value[31:0];
  end


  assign at_data_value[31:8] =                                                  at_data[31:8];
  assign at_data_value[ 7:0] = (fifo_trigger_inject)? {1'b0,at_id_reg_q[6:0]} : at_data[7:0];

  assign etm_atdatam_o[31:0] = at_data_q[31:0];

//---------------------------------------------------------------------------
// FIFO READY - Empty buffer first if it is in use already
//---------------------------------------------------------------------------
  assign fifo_ready_o = ~int_test_enable_i & ~fifo_buf_full_q;


//---------------------------------------------------------------------------
// AT Active state
//---------------------------------------------------------------------------
// ATB is already active or can be active as core state machine is entering run mode
// and
// Case 1) No idle request or
// Case 2) Valid data seen
  assign at_active_state_d = (at_active_state_q | at_main_run_q) &
                             (~at_idle_req_q | fifo_valid_i | at_valid_local_q);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_activestate_q
    if (!po_reset_n) begin
      at_active_state_q <= 1'b0;
      at_main_run_q     <= 1'b0;
    end
    else begin
      at_active_state_q <= at_active_state_d;
      at_main_run_q     <= core_at_main_run_t2_i;
    end
  end

  assign at_active_state_o = at_active_state_q;

//---------------------------------------------------------------------------
//IDLE Acknowledge
//---------------------------------------------------------------------------

  assign at_idle_req = fifo_idle_ack_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_idle_req_q
    if (!po_reset_n)
      at_idle_req_q <= 1'b0;
    else
      at_idle_req_q <= at_idle_req;
  end


// Acknowledge idle if no more data is pending to be output.
  assign at_idle_ack_d = (at_idle_req_q          &
                          ~at_valid_local_q      & ~fifo_buf_full_q &
                          ~fifo_trigger_valid_q  & ~fifo_trigger_inject_q & at_flush_ready_q
                          );

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_idle_ack_q
    if (!po_reset_n)
      at_idle_ack_q <= 1'b0;
    else
      at_idle_ack_q <= at_idle_ack_d;
  end

// Wait for one more ATCLK edge
// to make sure AFREADYM is also asserted
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_idle_ack_qq
    if (!po_reset_n)
      at_idle_ack_qq <= 1'b0;
    else if (gov_atclken_i)
      at_idle_ack_qq <= at_idle_ack_q;
  end


  assign at_idle_ack_o = at_idle_ack_qq & at_idle_ack_q;

//---------------------------------------------------------------------------
// Flush handling
//---------------------------------------------------------------------------

// Flush complete
  assign at_flush_ready = auxctlr_frc_afready_reg_i |
                          (int_test_enable_i ?
                          apb_pwdatadbg_6to0_i[1] :
                          ((~at_flush_req & at_flush_req_q & ~core_flush_nack_q) | ~at_active_state_q));

  assign at_flush_ready_en = gov_atclken_i & ((~int_test_enable_i & (~at_valid_local_q | gov_atreadym_i | at_flush_ready_q)) |
                                              (write_ir_atb_out_o & atb_reg_active) |
                                              auxctlr_frc_afready_reg_i);

// Duplicate register to avoid external output being internally sampled.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_flush_ready_q
    if (!po_reset_n)
      at_flush_ready_q <= {1{1'b1}};
    else if (at_flush_ready_en)
      at_flush_ready_q <= at_flush_ready;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uaf_ready_q
    if (!po_reset_n)
      af_ready_q <= {1{1'b1}};
    else if (at_flush_ready_en)
      af_ready_q <= at_flush_ready;
  end

  assign etm_afreadym_o = af_ready_q;

// Need previous cycle flush ready value to correctly detect a new flush request

  always @(posedge clk_gated)
  begin: uat_flush_ready_qq
    if (gov_atclken_i)
      at_flush_ready_qq <= at_flush_ready_q;
  end


// Flush acknowledge from Main FIFO.
  assign core_flush_nack = ~(fifo_flush_ack_i |
                             (~core_flush_nack_q  & at_flush_req_q));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucore_flush_nack_q
    if (!po_reset_n)
      core_flush_nack_q <= {1{1'b1}};
    else
      core_flush_nack_q <= core_flush_nack;
  end


// Flush request to Main FIFO.

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uaf_valid_q
    if (!po_reset_n)
      af_valid_q <= 1'b0;
    else if (gov_atclken_i)
      af_valid_q <= gov_afvalidm_i;
  end

  assign atb_afvalid_o = af_valid_q;

  assign at_flush_req = at_active_state_q & (~at_idle_req | at_flush_req_q) &
                        (  (~wfx_flush_active_q & af_valid_q & core_flush_nack_q & ~(at_flush_ready_q | at_flush_ready_qq)) |
                           (at_flush_req_q & (at_valid_local_q & ~gov_atreadym_i)));

  assign wfx_flush_active = (low_power_override_flush_i & ~fifo_idle_ack_i & ~at_flush_req_q) |
                            (wfx_flush_active_q & ~fifo_flush_ack_i & (at_main_run_q | at_active_state_q));

  assign core_flush_req_d = at_flush_req_q & ~fifo_idle_ack_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_flush_req_q
    if (!po_reset_n)
      at_flush_req_q   <= 1'b0;
    else if (gov_atclken_i)
      at_flush_req_q   <= at_flush_req;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ucore_flush_req_q
    if (!po_reset_n) begin
      core_flush_req_q   <= 1'b0;
      wfx_flush_active_q <= 1'b0;
    end 
    else begin
      core_flush_req_q   <= core_flush_req_d;
      wfx_flush_active_q <= wfx_flush_active;
    end
  end

// Pulse the flush request to main fifo. Will delay back to back request for handshake to fifo
  assign fifo_flush_req_o = ((at_flush_req_q & ~core_flush_req_q) |  //ATB flush request
                              low_power_override_flush_i) &          //wfx override flush request
                              ~fifo_idle_ack_i;

//---------------------------------------------------------------------------
// Generate SYNCREQM for core.
//---------------------------------------------------------------------------
// Trace synchronisation request handshake into clk_gated domain

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uatb_sync_req_q
    if (!po_reset_n)
      atb_sync_req_q <= 1'b0;
    else if (gov_atclken_i)
      atb_sync_req_q <= gov_syncreqm_i;
  end


  assign sync_req_t2_o = atb_sync_req_q;

//---------------------------------------------------------------------------
//   APB Access response
//---------------------------------------------------------------------------
  assign reg_req_atb = write_at_id_i | write_ir_atb_out_o | write_ir_atb_data_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uatb_reg_ack_q
    if (!po_reset_n) begin
      atb_reg_ack_q  <= 1'b0;
      atb_reg_ack_qq <= 1'b0;
    end
    else if (gov_atclken_i) begin
      atb_reg_ack_q  <= reg_req_atb;
      atb_reg_ack_qq <= atb_reg_ack_q;
    end
  end

  assign atb_reg_ack_o  = atb_reg_ack_qq;
  assign atb_reg_active = atb_reg_ack_q & ~atb_reg_ack_qq;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_ready_q
    if (!po_reset_n)
      at_ready_q <= 1'b0;
    else if (gov_atclken_i)
      at_ready_q <= gov_atreadym_i;
  end

  assign atb_atready_o = at_ready_q;

//---------------------------------------------------------------------------
//   AT ID register
//---------------------------------------------------------------------------
  assign at_id_en = fifo_trigger_inject | fifo_trigger_done | (atb_reg_active & gov_atclken_i);
  assign at_id_reg_value[6:0] = (fifo_trigger_inject)?  7'h7D : at_id_reg_prg[6:0];

  assign fifo_trigger_valid_update  =  event_trigger_req_t3_i | fifo_trigger_inject;
  assign fifo_trigger_valid         =  event_trigger_req_t3_i & ~fifo_trigger_inject_q & ~fifo_trigger_inject;

  assign fifo_trigger_inject_update =  fifo_trigger_inject | fifo_trigger_done;
  assign fifo_trigger_inject        =  fifo_trigger_valid_q & atb_advance;
  assign fifo_trigger_done          =  fifo_trigger_inject_q & gov_atreadym_i & gov_atclken_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_trigger_valid_q
    if (!po_reset_n)
      fifo_trigger_valid_q <= 1'b0;
    else if (fifo_trigger_valid_update)
      fifo_trigger_valid_q <= fifo_trigger_valid;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_trigger_inject_q
    if (!po_reset_n)
      fifo_trigger_inject_q <= 1'b0;
    else if (fifo_trigger_inject_update)
      fifo_trigger_inject_q <= fifo_trigger_inject;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_id_reg_prg_6_0
    if (!po_reset_n)
      at_id_reg_prg[6:0] <= {7{1'b0}};
    else if (write_at_id_i)
      at_id_reg_prg[6:0] <= apb_pwdatadbg_6to0_i[6:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uat_id_reg_q_6_0
    if (!po_reset_n)
      at_id_reg_q[6:0] <= {7{1'b0}};
    else if (at_id_en)
      at_id_reg_q[6:0] <= at_id_reg_value[6:0];
  end


  assign etm_atidm_o[6:0]    = at_id_reg_q[6:0];
  assign etm_atidm_reg_o[6:0] = at_id_reg_prg;
  
//--------------------------------------------------------------------------
// ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON
`include "ca53etm_val_defs.v"
// ETM ATB Interface

// Register ATVALIDM and ATREADYM to get the correct behaviour with
// clock gating (when gov_atclken_i low). Note that ATREADYM is not valid when
// ATVALIDM is not set.
  reg [1:0] sva_at_valid_ready_q;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_at_valid_ready_q[1:0] <=  2'b00;
    else if (int_test_enable_i ==1'b1)
      sva_at_valid_ready_q[1:0] <=  2'b00;
    else if (gov_atclken_i)
      sva_at_valid_ready_q[1:0] <=  {etm_atvalidm_o, etm_atvalidm_o ? gov_atreadym_i : 1'b0};

  usva_valid_ready: assert property (@(posedge clk_gated) disable iff (!po_reset_n | int_test_enable_i)
    sva_at_valid_ready_q[1:0] == 2'b10 |=> sva_at_valid_ready_q[1:0] != $past(2'b00))
    `SVA_FATAL("Valid data lost before sampled");

// Ensure that not more than the data capacity of the fifo to ATB logic
// is output before servicing a flush.
// Capacity:   64 (delay)
//          +  84 (fifo size)
//          +   8 (fifo->traceout)
//          +   4 (ATB output)
//          +  20 (margin for special packets)
//          = 180
  reg  [7:0] sva_flush_bytes_delay_q;
  wire [7:0] sva_nxt_flush_bytes_delay;

  assign sva_nxt_flush_bytes_delay = ((~gov_afvalidm_i | etm_afreadym_o | int_test_enable_i) ? 8'h00 :
                                       ~(etm_atvalidm_o & gov_atreadym_i) ? sva_flush_bytes_delay_q :
                                       sva_flush_bytes_delay_q + {6'b000000, etm_atbytesm_o & (etm_atidm_o != 7'h7d)} + 8'h01);

  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_flush_bytes_delay_q <=  {8{1'b0}};
    else if (gov_atclken_i)
      sva_flush_bytes_delay_q <=  sva_nxt_flush_bytes_delay;

  usva_afreadym_latency: assert property (@(posedge clk_gated) disable iff (!po_reset_n | int_test_enable_i)
    !(sva_flush_bytes_delay_q > 8'd180))
    `SVA_FATAL("AFREADYM took too long");

// AFREADYM must be a pulse when not in idle state.
// gov_atclken_i needs to be the clock edge.
  wire sva_at_afreadym;
  reg  sva_at_afreadym_q;
  assign sva_at_afreadym = (etm_afreadym_o & at_active_state_q);
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_at_afreadym_q <=  1'b0;
    else if (gov_atclken_i)
      sva_at_afreadym_q <=  sva_at_afreadym;

  usva_single_afreadym: assert property (@(posedge clk_gated) disable iff (!po_reset_n | int_test_enable_i | auxctlr_frc_afready_reg_i)
    gov_atclken_i & sva_at_afreadym_q |-> ~sva_at_afreadym)
    `SVA_FATAL("Single AT clock cycle pulse AFREADYM when not in idle state");

// at flush request should remain high atleast until fifo flush ack or fifo idle ack is seen.
// sva_at_flush_req_edge only set for one cycle on the positive edge of at_flush_req;
  wire sva_at_flush_req_edge;
  reg  sva_at_flush_req_q;
  always @(posedge clk_gated or negedge po_reset_n)
   if (!po_reset_n)
     sva_at_flush_req_q <=  1'b0;
   else
     sva_at_flush_req_q <=  at_flush_req;

  assign sva_at_flush_req_edge = at_flush_req & ~sva_at_flush_req_q & ~fifo_idle_ack_i;

  usva_fifo_valid_hs: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                  fifo_valid_i & ~fifo_ready_o |=> fifo_valid_i)
    `SVA_FATAL("TraceOut did not sample data from fifo");

  wire [31:0] sva_data_mask    = {{8{&fifo_bytes_i}},{8{&fifo_bytes_i[1]}},{8{|fifo_bytes_i}},{8{1'b1}}};
  wire [31:0] sva_data_mask_buf= {{8{&fifo_bytes_buf}},{8{&fifo_bytes_buf[1]}},{8{|fifo_bytes_buf}},{8{1'b1}}};


  // Check that fifo data is never lost or corrupted
  // 1. Data must be captured somewhere
  usva_fifo_data_buf_set: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                 ~int_test_enable_i & fifo_valid_i & fifo_ready_o |=>
                                 (((fifo_data_buf & $past(sva_data_mask)) == $past(fifo_data_i & sva_data_mask) & fifo_buf_full_q) |
                                  ((etm_atdatam_o & $past(sva_data_mask)) == $past(fifo_data_i & sva_data_mask) & etm_atvalidm_o)))
       `SVA_FATAL("FIFO data lost somewhere");

  // 2. Buffer data is never changed without buffer being used (becoming free)
  usva_fifo_data_overwrite: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                  ~int_test_enable_i & fifo_buf_full_q & $past(fifo_buf_full_q) |->
                                  (fifo_data_buf & sva_data_mask_buf) == $past(fifo_data_buf & sva_data_mask_buf))
       `SVA_FATAL("FIFO buffer data changed without buffer being used");

  // Check that fifo data is never invented
  usva_fifo_data_rep_1: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                 ~int_test_enable_i & gov_atreadym_i & gov_atclken_i & ~fifo_valid_i &
                                 ~fifo_buf_full_q & etm_atvalidm_o & ~fifo_trigger_valid_q |=>
                                 ~etm_atvalidm_o)
       `SVA_FATAL("Unexpected data output");

  usva_fifo_data_rep_2: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                 ~int_test_enable_i & gov_atreadym_i & gov_atclken_i &
                                 ~fifo_valid_i & fifo_buf_full_q & ~fifo_trigger_valid_q |=>
                                 ~fifo_buf_full_q)
       `SVA_FATAL("Unexpected data generated inside traceout module");

  reg [3:0] sva_bytes_present;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_bytes_present <= 4'b0000;
    else
      sva_bytes_present <= {4{~int_test_enable_i}} &
                          (sva_bytes_present +
                          {3'b000,fifo_valid_i & fifo_ready_o} -
                          {3'b000,gov_atclken_i & etm_atvalidm_o & gov_atreadym_i & ~fifo_trigger_inject_q});

  // Byte count should never be more than 2
  usva_at_valid_lost: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                  sva_bytes_present[3:0] < 4'd3)
       `SVA_ERROR("Byte count should never be more than 2");

  usva_at_trig_lost: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                  (fifo_trigger_valid_q & fifo_buf_full_q) |=>
                                  (fifo_buf_full_q))
       `SVA_FATAL("Trigger and buffer must never be consumed together");

  // Check ATB constraints are not over-constraining formal
  usva_at_trig_stuck: cover property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                  (fifo_trigger_valid_q & fifo_buf_full_q) ##1
                                 ~(fifo_trigger_valid_q & fifo_buf_full_q));

  // Byte count can never go negative
  usva_at_valid_created_warn: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                  ~int_test_enable_i &
                                  ~|sva_bytes_present & ~fifo_trigger_inject_q |->
                                  ~(gov_atclken_i & etm_atvalidm_o & gov_atreadym_i))
       `SVA_ERROR("Byte count must be non-zero if ETM has valid data output");

  //fifo_flush_req_o can never be x
  usva_fifo_flush_req_x_check: assert property  (@(posedge clk_gated) disable iff (!po_reset_n)
        !$isunknown(fifo_flush_req_o))
    `SVA_FATAL("fifo_flush_req_o must not be unknown");

    // Check trigger requested is always output
    wire sva_trigger_taken = gov_atclken_i & etm_atvalidm_o & 
                             gov_atreadym_i & (etm_atbytesm_o == 2'b00) & 
                             (etm_atidm_o == 7'h7D);
    reg  sva_trigger_requested;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_trigger_requested <= 1'b0;
    else
      sva_trigger_requested <= ~sva_trigger_taken & (sva_trigger_requested | event_trigger_req_t3_i);

  usva_trigger_valid: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
                          sva_trigger_taken |-> sva_trigger_requested)
       `SVA_ERROR("Trigger packet output but no trigger request");

  // Trigger request might be set before active state, but must be cleared before going inactive again
  usva_trigger_used: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                        sva_trigger_requested |-> 
                                        (at_active_state_o | core_at_main_run_t2_i | ~at_idle_ack_o))
       `SVA_ERROR("Trigger request pending, but session ended");

  // Check back-to-back flush requests do pass to fifo unless fifo is idle (at least for one scenario)
  usva_flush_req: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                     (gov_afvalidm_i & core_at_main_run_t2_i)[*2] ##1
                                     gov_afvalidm_i & etm_afreadym_o & gov_atclken_i & ~auxctlr_frc_afready_reg_i & ~fifo_idle_ack_i##1
                                     gov_afvalidm_i & gov_atclken_i & ~low_power_override_flush_i & ~fifo_idle_ack_i ##1
                                     gov_afvalidm_i & at_flush_req & ~core_flush_req_q  & gov_atclken_i & ~fifo_idle_ack_i##1
                                     gov_afvalidm_i & gov_atclken_i & ~low_power_override_flush_i & ~fifo_idle_ack_i|->
                                      fifo_flush_req_o ##1
                                     (~fifo_flush_req_o | low_power_override_flush_i))
       `SVA_ERROR("Back to back flush request must result in flush request to fifo");

  // Check flush response is not lost
  // May see aborted flush ACK if idle request arrives at same time as older
  // flush was about to be acknowledged
  usva_flush_captured: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
          at_active_state_q ##1 
          at_active_state_q & at_flush_ready & af_valid_q |=>
         (fifo_idle_ack_i & ~at_idle_req_q)       |
         (~core_flush_nack_q & at_flush_req_q)    |
          af_ready_q | 
          at_flush_ready)
       `SVA_ERROR("Flush response lost");

  usva_atb_strobe: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
    write_at_id_i |-> reg_req_atb)
   `SVA_ERROR("ATB ID write, but no active register strobe");

 // Check for over-constrained ATB interface    
  usva_atid_cover1: cover  property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                     gov_atclken_i & etm_atvalidm_o & gov_atreadym_i &
                                     (etm_atidm_o == 7'h01));
  usva_atid_cover2: cover  property  (@(posedge clk_gated) disable iff (!po_reset_n)
                                     gov_atclken_i & etm_atvalidm_o & gov_atreadym_i &
                                     (etm_atidm_o == 7'h10));
    
  // Unreachable states
  usva_idle_empty: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
    at_idle_req_q |-> ~fifo_valid_i)
       `SVA_ERROR("Fifo should be empty before idle request starts");

  usva_idle_trigger: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
    at_idle_req_q & fifo_trigger_inject_q |-> at_valid_local_q | fifo_buf_full_q | fifo_trigger_valid_q)
       `SVA_ERROR("Trigger before idle lost");

  // Reachable corner case
  usva_idle_ack_cover: assert  property  (@(posedge clk_gated) disable iff (!po_reset_n)
    at_idle_req_q & !at_valid_local_q & !fifo_buf_full_q & at_flush_ready_q & (fifo_trigger_valid_q | fifo_trigger_inject_q) |-> ##2
                                          ~fifo_idle_ack_i)
       `SVA_ERROR("Trigger request when going idle must only occur when idle request is removed.");
`endif

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

