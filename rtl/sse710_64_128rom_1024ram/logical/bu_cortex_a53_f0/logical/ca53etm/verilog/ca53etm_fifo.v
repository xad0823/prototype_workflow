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

// Description: Main Synchronous FIFO. Input is packed around 8th input byte,
//              and must be rotated depending on write pointer and the number
//              of used bytes in the first 8 bytes of the input.
//              Async and overflow packets are tracked using counters, and are
//              only inserted at the output of this fifo.
//              The read pointer increments 4 bytes at a time, there is no
//              output rotation. When an async or overflow is inserted, the
//              write pointer is re-aligned to a 4 byte boundary.
//              When a flush sequence completes, the write pointer can be
//              re-aligned as well.
//              Overflow packet must always be followed by Async packet if
//              trace remains active

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_fifo (



//
// Interface Signals
// =================
//

// Global inputs
  input wire          clk_gated,                 // CPU clock
  input wire          po_reset_n,                // Power on reset

// Inputs
// Signals from trace_gen
  input wire  [203:0] pack_fifo_in_t5_i,         // 28-byte FIFO data in with static 0 removed
  input wire  [4:0]   num_bytes_t5_i,            // Number of bytes that are valid.
  input wire  [2:0]   num_first8_t5_i,           // FIFO packet offset. 0 through 8.
  input wire          ts_output_en_pend_t3_i,    // Trace gen has pending timestamp, can't be idle
  input wire          ovfl_req_t2_i,             // Overflow request
  input wire          async_req_t4_i,            // Async request
  input wire          fifo_idle_req_t2_i,        // Flush the FIFO even if it is not 4x bytes full
  input wire  [3:0]   traced_event_t3_i,         // The events occur during fifo overflow

// Signals from traceout
  input wire          fifo_ready_i,              // traceout is ready to receive data
  input wire          fifo_flush_req_i,          // flush the FIFO and record the point where it is flushed

// Signals from APB register
  input wire          istall_reg_i,              // Stall CPU control bit
  input wire [1:0]    stall_level_reg_i,         // FIFO threshold level for stalling CPU

// Outputs
// signal to Core
  output wire         etm_stall_cpu_o,           // CPU stall request drvien from FIFO depth
// Signals to trace_gen
  output wire         fifo_overflow_o,           // FIFO is overflow
  output wire         fifo_empty_o,              // FIFO is empty
  output wire         fifo_8bytes_t6_o,          // 8 bytes of trace output
  output wire         fifo_level28_t7_o,         // FIFO has more than 16 bytes

// Signals to trace out
  output wire  [31:0] fifo_data_o,               // FIFO data output
  output wire  [1:0]  fifo_bytes_o,              // indicate which bytes are valid
  output wire         fifo_valid_o,              // indicate whether the 4 byte output is valid or not
  output wire         fifo_flush_ack_o,          // indicate the point where the FIFO was flushed
  output wire         fifo_idle_ack_o            // propagate idle req

 );

localparam CA53_ETM_MAIN_FIFO_DEPTH      =7'd84;

localparam CA53_ETM_FIFO_ST2_NORMAL      =2'b00;
localparam CA53_ETM_FIFO_ST2_ASYNC_1     =2'b01;
localparam CA53_ETM_FIFO_ST2_ASYNC_2     =2'b10;
localparam CA53_ETM_FIFO_ST2_ASYNC_3     =2'b11;

  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  wire [  1:  0] async_bytes_t6;
  wire [ 31:  0] async_data_t6;
  wire           async_data_valid_t6;
  wire           async_done_t6;
  wire [  7:  0] async_pos_t5;
  wire           async_pos_t5_en;
  reg  [  7:  0] async_pos_t6;
  reg  [  1:  0] async_state_t6;
  wire           async_state_t6_en;
  reg  [  1:  0] async_state_t7;
  wire           async_valid_t6;
  wire           async_when_empty_t5;
  reg            async_when_empty_t6;
  wire [  6:  0] diff_wr_rd_t7;
  wire [ 27:  0] fifo_byte_active_t6;
  wire [ 27:  0] fifo_byte_active_tmp_t6;
  wire [  1:  0] fifo_bytes_normal_t6;
  reg  [  1:  0] fifo_bytes_t7;

  wire [223:  0] fifo_data_in_t6;
  reg  [ 31:  0] fifo_data_normal_t6;
  reg  [ 31:  0] fifo_data_t7;
  wire           fifo_has_no_bytes_t6;
  wire           fifo_idle_ack_t5;
  wire           fifo_idle_ack_t5_en;
  reg            fifo_idle_ack_t6;
  wire           fifo_idle_req_t5;
  reg            fifo_idle_req_t6;
  wire           fifo_in_en;
  reg  [203:  0] pack_fifo_in_t6;
  wire           fifo_level28_t6;
  reg            fifo_level28_t7;
  wire           fifo_not_empty_t7;
  wire           fifo_overflow_aligned_t5;
  reg            fifo_overflow_aligned_t6;
  wire           fifo_overflow_t5;
  wire           fifo_all_overflow_t6;
  reg            fifo_overflow_t6;
  reg            fifo_all_overflow_t7;
  wire           fifo_read_valid_t6;
  wire [  4:  0] fifo_space_recover_t5;
  reg  [  4:  0] fifo_space_recover_t6;
  wire [  6:  0] fifo_space_t5;
  wire [  6:  0] fifo_space_final_t6;
  reg  [  6:  0] fifo_space_t6;
  wire           fifo_valid_t6;
  reg            fifo_valid_t7;
  wire           fifo_waiting_t6;
  wire           fifo_empty_t6;
  reg            fifo_empty_t7;
  wire [  4:  0] final_rot_value_t6;
  wire           flush_align_done_t5;
  reg            flush_align_done_t6;
  wire           flush_condition1_t6;
  wire           flush_condition2_t6;
  wire           flush_data_valid_t6;
  wire [  3:  0] flush_delay_t5;
  reg  [  3:  0] flush_delay_t6;
  wire           flush_done_t6;
  wire           flush_idle_write_align_valid_t5;
  wire           flush_passed_t6;
  reg            flush_passed_t7;
  wire [  7:  0] flush_pos_t5;
  wire           flush_pos_t5_en;
  reg  [  7:  0] flush_pos_t6;
  reg            flush_state_t6;
  wire           flush_state_t6_en;
  reg            flush_state_t7;
  wire           flush_valid_t6;
  reg            idle_comitted_t6;
  wire [  1:  0] merged_bytes_t6;
  wire [ 31:  0] merged_data_t6;
  wire           new_bytes_t5;
  wire           new_bytes_t5_t6;
  reg            new_bytes_t6;
  wire           normal_data_t6;
  reg  [  2:  0] num_first8_t6;
  wire [  1:  0] ovfl_bytes_t6;
  wire [ 31:  0] ovfl_data_t6;
  wire           ovfl_data_valid_t6;
  wire           ovfl_done_t6;
  wire [  7:  0] ovfl_pos_t5;
  wire           ovfl_pos_t5_en;
  reg  [  7:  0] ovfl_pos_t6;
  reg            ovfl_req_retime_t3;
  reg            ovfl_state_t6;
  wire           ovfl_state_t6_en;
  reg            ovfl_state_t7;
  wire           ovfl_valid_t6;
  wire           ovfl_when_empty_t5;
  reg            ovfl_when_empty_t6;
  wire [  5:  0] prerot_t6;
  wire [  2:  0] rd_col_ptr_t5;
  reg  [  2:  0] rd_col_ptr_t6;
  wire           rd_data_t6_en;
  wire           rd_inc_row_t5_en;
  wire           rd_inc_t6_en;
  wire [  1:  0] rd_row_ptr_t5;
  reg  [  1:  0] rd_row_ptr_t6;
  wire [  5:  0] rd_word_ptr_t5;
  reg  [  5:  0] rd_word_ptr_t6;
  reg            ts_output_en_pend_t4;
  reg            async_req_t5;
  wire           valid_async_req_t5;
  wire           valid_flush_req_t5;
  wire           valid_ovfl_req_t5;
  wire           wptr_byte_aligned_t6;
  wire [  7:  0] wr_byte_plus_input_t5;
  wire [  7:  0] wr_byte_ptr_inc_t5;
  wire [  7:  0] wr_byte_ptr_t5;
  wire           wr_byte_ptr_t6_80;
  reg  [  7:  0] wr_byte_ptr_t6;
  reg  [  7:  0] wr_byte_ptr_t7;
  wire           wr_byte_ptr_wrap_msb_t5;
  wire [  6:  0] wr_byte_ptr_wrap_t5;
  wire [  4:  2] wr_col_next_word_t6;
  wire [  5:  0] wr_col_plus_t5;
  reg  [  5:  0] wr_col_plus_t6;
  wire [  4:  0] wr_col_ptr_inc_t5;
  reg  [  4:  0] wr_col_ptr_inc_t6;
  wire [  4:  0] wr_col_ptr_inc_wrap_t6;
  reg  [  4:  0] wr_col_ptr_t6;
  wire [  4:  0] wr_col_wrap_t5;
  wire           wr_ptr_updates;
  wire [  1:  0] wr_row_ptr_inc_t5;
  reg  [  1:  0] wr_row_ptr_t6;
  reg  [  1:  0] wr_row_ptr_t7;
  wire [  1:  0] wr_row_ptr_wrap_56_t6;
  wire [  1:  0] wr_row_ptr_wrap_t7;
  wire           wrap_rd_t6;
  wire           wrap_wr_t6;
  wire           wrap_wr_t7;
  wire           write_align_ovfl_async_t5;
  wire           write_align_valid_t5;
  reg            write_align_valid_t6;
  wire           wrptr_en_t5;


  wire           stall_cpu_level1_t6;
  wire           stall_cpu_level2_t6;
  wire           stall_cpu_level3_t6;
  wire           etm_stall_cpu_t6;
  reg            etm_stall_cpu_t7;

  genvar i;
  reg   [28*8-1: 0]    fifo_data          [   2:0];
  wire      [1 : 0]    fifo_row_wr_ptr_t6 [28-1:0];
  wire    [28-1: 0]    write_start_mask;
  wire  [28*2-1: 0]    write_end_mask;
//
// Main Code
// =========
//

//---------------------------------------------------------------------------
// Write Pointer Calculation - both as row/col and byte
// Byte pointer includes extra MSB to handle wrap-around
//---------------------------------------------------------------------------

// Write pointer must be made word-aligned when special packets are inserted,
// and the number of valid preceding bytes stored. Write pointer is also aligned
// if the FIFO is drained with less than 4 bytes.

// Align write point to word aligned in normal case (without overflow with async/ovfl)
  assign wptr_byte_aligned_t6 = wr_col_ptr_t6[1:0] == 2'b00;
  assign new_bytes_t5_t6      = (|num_bytes_t5_i[4:0]) | new_bytes_t6;

// For idle flush, ensure input is idle, and output is empty. Write pointer must be changed, so t5 must equal t6.
// Also require output holding register to be empty for idle, otherwise can loose position if stalled
  assign write_align_valid_t5 = (
                                  flush_idle_write_align_valid_t5 |                       // on a flush or idle request in t5 or
                                  (     (   (
                                             (fifo_idle_req_t6 &                          // idle request seen last cycle
                                             ~new_bytes_t5_t6 &                           // no new bytes this and last cycle
                                             (ovfl_pos_t6[7:0] == 8'hFF) &                // completed ovfl output
                                             (async_pos_t6[7:0] == 8'hFF) &               // completed async output
                                             ~async_req_t5 &                              // no new async request this cycle
                                             ~ovfl_req_t2_i )                             // no new ovfl request this cycle
                                            |
                                             (flush_state_t6 &                            // flushing this cycle
                                             ~flush_passed_t7 &                           // waiting for flush to complete
                                             |flush_pos_t6[1:0])                          // flush on a non word boundary
                                            )
                                         &
                                            (fifo_waiting_t6) &                           // Less than 4 byte in FIFO
                                            (rd_data_t6_en)                               // with read enable
                                        )              |
                                    valid_ovfl_req_t5  |                                  // on an ovfl request
                                    valid_async_req_t5                                    // on an async request
                                 )
                                 &
                                 (~wptr_byte_aligned_t6));

// Disable write ptr if overflow happens without async and ovfl insert
  assign write_align_ovfl_async_t5 = (valid_ovfl_req_t5 | valid_async_req_t5 )&
                                     (~wptr_byte_aligned_t6);

  assign wrptr_en_t5 = (~fifo_overflow_t5 & ~fifo_all_overflow_t6 &
                        (~fifo_overflow_aligned_t5 | ~write_align_ovfl_async_t5));


//---------------------------------------------------------------------------
// Write Byte Pointer Calculation
//---------------------------------------------------------------------------
  assign wr_byte_plus_input_t5[7:0] = write_align_valid_t5 ?
                                       (({(wr_byte_ptr_t6[7:2] + 6'b000001), 2'b00}) + ({3'b000, num_bytes_t5_i[4:0]})) :
                                       (wr_byte_ptr_t6[7:0] + {3'b000, num_bytes_t5_i[4:0]});

// Failed write may still cause wprtr to become aligned.
// Last byte written, not folded
  assign wr_byte_ptr_inc_t5[7:0] = wr_byte_plus_input_t5[7:0];


// if wr_byte_ptr_inc_t5[6:0] greater than or equal to FIFO depth 84,
// then flip MSB bit[7] and subtract 8'd84 from wr_byte_ptr_inc_t5[6:0],
// else equal to wr_byte_ptr_inc_t5[6:0]

// Current write passes end of FIFO.
// wr_byte_ptr_wrap_t5

// Flip MSB for wrap. i.e wr_byte_ptr_inc_t5[6:0] >= 84
  assign wr_byte_ptr_wrap_msb_t5 = (wr_byte_ptr_inc_t5[7]) ^
                                   ((wr_byte_ptr_inc_t5[6] & wr_byte_ptr_inc_t5[4] & wr_byte_ptr_inc_t5[2]) |
                                    (wr_byte_ptr_inc_t5[6] & wr_byte_ptr_inc_t5[4] & wr_byte_ptr_inc_t5[3]) |
                                    (wr_byte_ptr_inc_t5[6] & wr_byte_ptr_inc_t5[5]));

  // here's the pla table sent to espresso:
  //
  // wr_byte_ptr_inc_t5[6:0]
  // |       wr_byte_ptr_wrap_t5[6:0]
  // |       |
  // 0000000 0000000
  // 0000001 0000001
  // 0000010 0000010
  // 0000011 0000011
  // 0000100 0000100
  // 0000101 0000101
  // 0000110 0000110
  // 0000111 0000111
  // 0001000 0001000
  // 0001001 0001001
  // 0001010 0001010
  // 0001011 0001011
  // 0001100 0001100
  // 0001101 0001101
  // 0001110 0001110
  // 0001111 0001111
  // 0010000 0010000
  // 0010001 0010001
  // 0010010 0010010
  // 0010011 0010011
  // 0010100 0010100
  // 0010101 0010101
  // 0010110 0010110
  // 0010111 0010111
  // 0011000 0011000
  // 0011001 0011001
  // 0011010 0011010
  // 0011011 0011011
  // 0011100 0011100
  // 0011101 0011101
  // 0011110 0011110
  // 0011111 0011111
  // 0100000 0100000
  // 0100001 0100001
  // 0100010 0100010
  // 0100011 0100011
  // 0100100 0100100
  // 0100101 0100101
  // 0100110 0100110
  // 0100111 0100111
  // 0101000 0101000
  // 0101001 0101001
  // 0101010 0101010
  // 0101011 0101011
  // 0101100 0101100
  // 0101101 0101101
  // 0101110 0101110
  // 0101111 0101111
  // 0110000 0110000
  // 0110001 0110001
  // 0110010 0110010
  // 0110011 0110011
  // 0110100 0110100
  // 0110101 0110101
  // 0110110 0110110
  // 0110111 0110111
  // 0111000 0111000
  // 0111001 0111001
  // 0111010 0111010
  // 0111011 0111011
  // 0111100 0111100
  // 0111101 0111101
  // 0111110 0111110
  // 0111111 0111111
  // 1000000 1000000
  // 1000001 1000001
  // 1000010 1000010
  // 1000011 1000011
  // 1000100 1000100
  // 1000101 1000101
  // 1000110 1000110
  // 1000111 1000111
  // 1001000 1001000
  // 1001001 1001001
  // 1001010 1001010
  // 1001011 1001011
  // 1001100 1001100
  // 1001101 1001101
  // 1001110 1001110
  // 1001111 1001111
  // 1010000 1010000
  // 1010001 1010001
  // 1010010 1010010
  // 1010011 1010011
  // 1010100 0000000
  // 1010101 0000001
  // 1010110 0000010
  // 1010111 0000011
  // 1011000 0000100
  // 1011001 0000101
  // 1011010 0000110
  // 1011011 0000111
  // 1011100 0001000
  // 1011101 0001001
  // 1011110 0001010
  // 1011111 0001011
  // 1100000 0001100
  // 1100001 0001101
  // 1100010 0001110
  // 1100011 0001111
  // 1100100 0010000
  // 1100101 0010001
  // 1100110 0010010
  // 1100111 0010011
  // 1101000 0010100
  // 1101001 0010101
  // 1101010 0010110
  // 1101011 0010111
  // 1101100 0011000
  // 1101101 0011001
  // 1101110 0011010
  // 1101111 0011011
  // default:
  // 111---- -------
  //
  // the following equations are the espresso output

  assign wr_byte_ptr_wrap_t5[6] = (wr_byte_ptr_inc_t5[6]&!wr_byte_ptr_inc_t5[5]
    &!wr_byte_ptr_inc_t5[4]&wr_byte_ptr_inc_t5[3]) | (
    wr_byte_ptr_inc_t5[6]&!wr_byte_ptr_inc_t5[5]&!wr_byte_ptr_inc_t5[3]
    &!wr_byte_ptr_inc_t5[2]) | (wr_byte_ptr_inc_t5[6]
    &!wr_byte_ptr_inc_t5[5]&!wr_byte_ptr_inc_t5[4]&wr_byte_ptr_inc_t5[2]);

  assign wr_byte_ptr_wrap_t5[5] = (!wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[5]);

  assign wr_byte_ptr_wrap_t5[4] = (wr_byte_ptr_inc_t5[4]&!wr_byte_ptr_inc_t5[3]
    &!wr_byte_ptr_inc_t5[2]) | (wr_byte_ptr_inc_t5[6]
    &wr_byte_ptr_inc_t5[5]&wr_byte_ptr_inc_t5[3]&!wr_byte_ptr_inc_t5[2]) | (
    !wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[4]) | (
    wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[5]&wr_byte_ptr_inc_t5[2]);

  assign wr_byte_ptr_wrap_t5[3] = (wr_byte_ptr_inc_t5[6]&!wr_byte_ptr_inc_t5[5]
    &!wr_byte_ptr_inc_t5[4]&wr_byte_ptr_inc_t5[3]) | (
    !wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[3]) | (
    wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[5]&!wr_byte_ptr_inc_t5[3]
    &!wr_byte_ptr_inc_t5[2]) | (wr_byte_ptr_inc_t5[3]
    &wr_byte_ptr_inc_t5[2]);

  assign wr_byte_ptr_wrap_t5[2] = (wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[5]
    &wr_byte_ptr_inc_t5[3]&!wr_byte_ptr_inc_t5[2]) | (
    wr_byte_ptr_inc_t5[6]&!wr_byte_ptr_inc_t5[5]&!wr_byte_ptr_inc_t5[4]
    &wr_byte_ptr_inc_t5[2]) | (!wr_byte_ptr_inc_t5[6]
    &wr_byte_ptr_inc_t5[2]) | (wr_byte_ptr_inc_t5[6]
    &wr_byte_ptr_inc_t5[5]&!wr_byte_ptr_inc_t5[3]&!wr_byte_ptr_inc_t5[2]) | (
    wr_byte_ptr_inc_t5[6]&wr_byte_ptr_inc_t5[4]&wr_byte_ptr_inc_t5[3]
    &!wr_byte_ptr_inc_t5[2]);

  assign wr_byte_ptr_wrap_t5[1] = (wr_byte_ptr_inc_t5[1]);

  assign wr_byte_ptr_wrap_t5[0] = (wr_byte_ptr_inc_t5[0]);


  assign wr_byte_ptr_t5[7:0] = {wr_byte_ptr_wrap_msb_t5,wr_byte_ptr_wrap_t5[6:0]};

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwr_byte_ptr_t6_7_0
    if (!po_reset_n)
      wr_byte_ptr_t6[7:0] <= {8{1'b0}};
    else if (wrptr_en_t5)
      wr_byte_ptr_t6[7:0] <= wr_byte_ptr_t5[7:0];
  end


//---------------------------------------------------------------------------
// Async packet Handling
// Write pointer pre-async is stored, async is output when read pointer reaches
// the stored value.
// Multiple Async requests from different sources can be seen while servicing
// an Async request. If an Async request is pending then we ignore the new
// Async request.
//---------------------------------------------------------------------------
  assign valid_async_req_t5 = async_req_t5 & (async_pos_t6[7:0] == 8'hFF) & ~fifo_overflow_t6 & ~fifo_overflow_aligned_t5 & ~ovfl_when_empty_t6;
  assign async_pos_t5_en    = valid_async_req_t5 | async_done_t6;

// Set to 0xFF when there is no async being output
// if wr_byte_ptr is >= 80 then wrap around.
  assign wr_byte_ptr_t6_80 = wr_byte_ptr_t6[6] & wr_byte_ptr_t6[4];

  assign async_pos_t5[7]   = {async_done_t6} |
                             ((wr_byte_ptr_t6_80 & flush_idle_write_align_valid_t5) ^ wr_byte_ptr_t6[7]);

  assign async_pos_t5[6:2] = {5{async_done_t6}} |
                             ( {5{~(wr_byte_ptr_t6_80 & flush_idle_write_align_valid_t5)}} &
                               (wr_byte_ptr_t6[6:2] + ({4'b0000,flush_idle_write_align_valid_t5}))
                             );

  assign async_pos_t5[1:0] = {2{async_done_t6}} |
                             (wr_byte_ptr_t6[1:0] & {2{~flush_idle_write_align_valid_t5}});

// Data written after the async should be output after.
  assign  async_when_empty_t5 = fifo_has_no_bytes_t6 & valid_async_req_t5;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_req_t5
    if (!po_reset_n)
      async_req_t5 <= 1'b0;
    else
      async_req_t5 <= async_req_t4_i;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_pos_t6_7_0
    if (!po_reset_n)
      async_pos_t6[7:0] <= {8{1'b1}};
    else if (async_pos_t5_en)
      async_pos_t6[7:0] <= async_pos_t5[7:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_when_empty_t6
    if (!po_reset_n)
      async_when_empty_t6 <= 1'b0;
    else if (async_pos_t5_en)
      async_when_empty_t6 <= async_when_empty_t5;
  end

  assign async_valid_t6 = (async_pos_t6[7:2] == {rd_word_ptr_t6[5:0]}) &
                          ~fifo_idle_ack_t6;

  always @*
  begin
    case(async_state_t7[1:0])
      CA53_ETM_FIFO_ST2_NORMAL: async_state_t6[1:0] = (async_valid_t6 & ~ovfl_valid_t6 &
                                                       ~(ovfl_req_retime_t3 & fifo_waiting_t6) &
                                                  (rd_data_t6_en | ~fifo_valid_t7))? 
                                                   CA53_ETM_FIFO_ST2_ASYNC_1:CA53_ETM_FIFO_ST2_NORMAL;

      CA53_ETM_FIFO_ST2_ASYNC_1: async_state_t6[1:0] = (rd_data_t6_en) ?
                                                   CA53_ETM_FIFO_ST2_ASYNC_2:CA53_ETM_FIFO_ST2_ASYNC_1;

      CA53_ETM_FIFO_ST2_ASYNC_2: async_state_t6[1:0] = (rd_data_t6_en) ?
                                                   CA53_ETM_FIFO_ST2_ASYNC_3:CA53_ETM_FIFO_ST2_ASYNC_2;

      CA53_ETM_FIFO_ST2_ASYNC_3: async_state_t6[1:0] = (rd_data_t6_en) ?
                                                   CA53_ETM_FIFO_ST2_NORMAL:CA53_ETM_FIFO_ST2_ASYNC_3;
      default     : async_state_t6[1:0] = {2{1'bx}};
    endcase
  end

  assign async_state_t6_en = ~fifo_idle_ack_t6 & (async_valid_t6 | rd_data_t6_en);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uasync_state_t7_1_0
    if (!po_reset_n)
      async_state_t7[1:0] <= CA53_ETM_FIFO_ST2_NORMAL;
    else if (async_state_t6_en)
      async_state_t7[1:0] <= async_state_t6[1:0];
  end


  assign async_bytes_t6[1:0] = // Normal bytes
                               ({2{~async_valid_t6 & ~(ovfl_valid_t6 | ovfl_when_empty_t6)}} & fifo_bytes_normal_t6[1:0]) |
                               // Normal bytes around ASYNC
                               ({2{
                                   async_valid_t6 &
                                   ~ovfl_data_valid_t6 &
                                   ~async_when_empty_t6 &
                                   (async_state_t7[1:0] == CA53_ETM_FIFO_ST2_NORMAL)
                                }} & (async_pos_t6[1:0] - 2'b01)
                               ) |
                               // Async bytes
                               ({2{async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_1}} |
                                {2{async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_2}} |
                                {2{async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_3}}
                               );

  assign async_data_t6[31:0] = // Normal Data or
                                ({32{~async_valid_t6 & ~ovfl_data_valid_t6}}
                                  & fifo_data_normal_t6[31:0]) |
                               // Normal bytes around ASYNC
                               ({32{
                                    async_valid_t6 & ~ovfl_data_valid_t6 &
                                    ~async_when_empty_t6 &
                                    (async_state_t7[1:0] == CA53_ETM_FIFO_ST2_NORMAL)
                                }} & fifo_data_normal_t6[31:0]) |
                                // Async Data
                                ({async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_3,{31{1'b0}}});


  assign async_data_valid_t6 = async_valid_t6 &
                              ((|async_pos_t6[1:0]) |
                                (async_state_t7[1:0] != CA53_ETM_FIFO_ST2_NORMAL));

  // Discard async request if it is at the exact same position as overflow
  assign async_done_t6 = ((async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_3) |
                          (async_valid_t6 & ovfl_state_t7)) & rd_data_t6_en;

//---------------------------------------------------------------------------
// OVFL packet Handling
// Write pointer pre-ovfl is stored, ovfl is output when read pointer reaches
// the stored value. OVFL goes after data input on the same cycle, so is delayed
// one cycle to give identical behaviour to Async.
// Only one ovfl can be pending at a time.
//---------------------------------------------------------------------------
  always @(posedge clk_gated or negedge po_reset_n)
  begin: uovfl_req_retime_t3
    if (!po_reset_n)
      ovfl_req_retime_t3 <= 1'b0;
    else
      ovfl_req_retime_t3 <= ovfl_req_t2_i;
  end


  assign valid_ovfl_req_t5 = ovfl_req_retime_t3;

  assign ovfl_pos_t5_en = valid_ovfl_req_t5 | ovfl_done_t6;

// Set to 0xFF when there is no ovfl being output
// if wr_byte_ptr is at 80 then wrap around.
  assign ovfl_pos_t5[7] = {ovfl_done_t6} |
                             ((wr_byte_ptr_t6_80 & flush_idle_write_align_valid_t5) ^ wr_byte_ptr_t6[7]);

  assign ovfl_pos_t5[6:2] = {5{ovfl_done_t6}} |
                               ({5{~(wr_byte_ptr_t6_80 & flush_idle_write_align_valid_t5)}} &
                                (wr_byte_ptr_t6[6:2] + {4'b0000,flush_idle_write_align_valid_t5})
                               );

  assign ovfl_pos_t5[1:0] = {2{ovfl_done_t6}} |
                               (wr_byte_ptr_t6[1:0] & {2{~flush_idle_write_align_valid_t5}});

// Data written after the ovfl should be output after.
  assign  ovfl_when_empty_t5 = fifo_has_no_bytes_t6 & valid_ovfl_req_t5;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uovfl_pos_t6_7_0
    if (!po_reset_n)
      ovfl_pos_t6[7:0] <= {8{1'b1}};
    else if (ovfl_pos_t5_en)
      ovfl_pos_t6[7:0] <= ovfl_pos_t5[7:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uovfl_when_empty_t6
    if (!po_reset_n)
      ovfl_when_empty_t6 <= 1'b0;
    else if (ovfl_pos_t5_en)
      ovfl_when_empty_t6 <= ovfl_when_empty_t5;
  end

//Overflow might happen whilst async being output
  assign ovfl_valid_t6 = (ovfl_pos_t6[7:2] == {rd_word_ptr_t6[5:0]});

// Stall ovfl state if async is being output.
  always @*
  begin
    case(ovfl_state_t7)
      1'b0:
        ovfl_state_t6 = (ovfl_valid_t6 &
                       ~(async_valid_t6 & (async_state_t7 != CA53_ETM_FIFO_ST2_NORMAL)) &
                        (rd_data_t6_en | ~fifo_valid_t7))?
                           1'b1:1'b0;
      1'b1:
        ovfl_state_t6 = (rd_data_t6_en | ~fifo_valid_t7) ?
                           1'b0:1'b1;
      default     : ovfl_state_t6 = {1{1'bx}};
    endcase
  end

  assign  ovfl_state_t6_en = ~fifo_idle_ack_t6 & (ovfl_valid_t6 | rd_data_t6_en);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uovfl_state_t7
    if (!po_reset_n)
      ovfl_state_t7 <= 1'b0;
    else if (ovfl_state_t6_en)
      ovfl_state_t7 <= ovfl_state_t6;
  end


// OVFL is output as 2 bytes (encodes as 1), or 3 (encodes as 2) depending on events to trace
// If ovfl and async hit together, one of the position pointers will have [1:0]==00.
  assign  ovfl_bytes_t6[1:0] =  (ovfl_valid_t6 & ~ovfl_state_t7 & ~async_when_empty_t6)? ovfl_pos_t6[1:0] - 2'b01 :
                                {|traced_event_t3_i & ovfl_state_t7,~(|traced_event_t3_i) & ovfl_state_t7};

  assign  ovfl_data_t6[31:0] =  (({32{ovfl_valid_t6 & ~async_when_empty_t6 &
                                        ~ovfl_state_t7}} &
                                        fifo_data_normal_t6[31:0]))
                             | (({32{|traced_event_t3_i & ovfl_state_t7}}) & ({{8{1'b0}},{8'b0000_0101}, {8{1'b0}}, {4'h7,traced_event_t3_i[3:0]}}))
                               // ovfl state here is active, has pending event
                             | (({32{~|traced_event_t3_i & ovfl_state_t7}}) & ({{16{1'b0}},{8'b0000_0101}, {8{1'b0}}}));
                               // ovfl state here is active, no pending event

  assign  ovfl_data_valid_t6 = ovfl_valid_t6 &
                               ((ovfl_state_t7) | (|ovfl_pos_t6[1:0]));

  assign  ovfl_done_t6 = (ovfl_state_t7) & rd_data_t6_en;

//---------------------------------------------------------------------------
// Flush Handling
// If FIFO has <4 bytes, and no data in t6, partial data must be flushed.
// This causes t5 write pointer to be re-aligned.
//---------------------------------------------------------------------------

// For idle, pointers are being updated, must wait
  assign wr_ptr_updates = async_req_t5 | new_bytes_t5_t6 | ovfl_req_t2_i | valid_ovfl_req_t5;

// Pointers aligned next cycle , read must stop
  assign flush_idle_write_align_valid_t5 = ((
                                              ( fifo_idle_req_t6 & ~idle_comitted_t6 & ~fifo_idle_ack_t6 & ~wr_ptr_updates & ~fifo_valid_t7 &
                                                (ovfl_pos_t6[7:0]== 8'hFF) & (async_pos_t6[7:0]== 8'hFF)
                                              ) |
                                              (flush_state_t6 & ~flush_passed_t7 &
                                               ~(~fifo_ready_i & fifo_valid_t7) &
                                               |flush_pos_t6[1:0]
                                              )
                                            ) &
                                            (fifo_waiting_t6)
                                           ) &
                                           (~wptr_byte_aligned_t6);


// Delay to allow timestamp to enter FIFO.
// Hold back if already in flush so never see new flush before idle
  assign flush_delay_t5[3:0] = {4{~fifo_idle_ack_t6}} &
                               ( {4{fifo_flush_req_i}} |
                                 {2'b00, (flush_valid_t6 | flush_state_t7) & flush_delay_t6[1],1'b0} |
                                 (flush_delay_t6[3:0] - {3'b000,|flush_delay_t6[3:0]}));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uflush_delay_t6_3_0
    if (!po_reset_n)
      flush_delay_t6[3:0] <= {4{1'b0}};
    else
      flush_delay_t6[3:0] <= flush_delay_t5[3:0];
  end


  assign valid_flush_req_t5 = ~(fifo_idle_ack_t6) & (flush_delay_t6[3:0] == 4'b0001) & (flush_pos_t6[7:0]== 8'hFF);
  assign flush_pos_t5_en    = valid_flush_req_t5 | (flush_done_t6 & (fifo_ready_i | ~fifo_valid_t7));

// Set to 0xFF when there is no flush being output
  assign flush_pos_t5[7:0] = {8{flush_done_t6}} |
                               wr_byte_ptr_t6[7:0];

// Data written after the flush means no need to drain on flush.
  assign flush_align_done_t5 = ((write_align_valid_t5 & fifo_waiting_t6) |flush_align_done_t6) &
                               ((flush_pos_t6[7:0]!= 8'hFF) | valid_flush_req_t5) &
                               ~flush_done_t6;

  assign flush_passed_t6 = (flush_pos_t6[7:2] != wr_byte_ptr_t6[7:2]) & (flush_pos_t6[7:0]!= 8'hFF) & ~flush_align_done_t5;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uflush_align_done_t6
    if (!po_reset_n)
      flush_align_done_t6 <= 1'b0;
    else
      flush_align_done_t6 <= flush_align_done_t5;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uflush_pos_t6_7_0
    if (!po_reset_n)
      flush_pos_t6[7:0] <= {8{1'b1}};
    else if (flush_pos_t5_en)
      flush_pos_t6[7:0] <= flush_pos_t5[7:0];
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uflush_passed_t7
    if (!po_reset_n)
      flush_passed_t7 <= 1'b0;
    else
      flush_passed_t7 <= flush_passed_t6;
  end


// Don't flush if data is entering fifo and would need to change write pointer - allow if flush point has been passed by write pointer.
  assign  flush_valid_t6 = (flush_pos_t6[7:2] == {rd_word_ptr_t6[5:0]}) &
                           ( ~(new_bytes_t5_t6 | async_req_t5 | ovfl_req_t2_i | ovfl_valid_t6 | async_valid_t6) |
                              ~(|flush_pos_t6[1:0]) |
                              flush_passed_t7 | flush_align_done_t6
                           );

  assign  flush_condition1_t6 = ~async_valid_t6 | fifo_idle_ack_t6 |
                                (async_done_t6 & (|async_pos_t6[1:0] | flush_passed_t7)) |
                                ((|async_pos_t6[1:0]) & ~(|flush_pos_t6[1:0]));

  assign  flush_condition2_t6 = ~ovfl_valid_t6 | fifo_idle_ack_t6 |
                                (ovfl_done_t6 & (|ovfl_pos_t6[1:0] | flush_passed_t7)) |
                                (|ovfl_pos_t6[1:0] & ~(|flush_pos_t6[1:0]));

  always @*
  begin
    case(flush_state_t7)
      1'b0: flush_state_t6 = (flush_valid_t6 &
                                              flush_condition1_t6 &
                                              flush_condition2_t6 &
                                              (rd_data_t6_en | ~fifo_valid_t7)) ?
                                             1'b1:1'b0;
      1'b1: flush_state_t6 = (rd_data_t6_en | ~fifo_valid_t7)?
                                            1'b0:1'b1;
      default     : flush_state_t6 = {1{1'bx}};
    endcase
  end

  assign  flush_state_t6_en = (flush_state_t7 & (fifo_ready_i | fifo_idle_ack_t6)) |
                              (~flush_state_t7 &(flush_valid_t6 | rd_data_t6_en));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uflush_state_t7
    if (!po_reset_n)
      flush_state_t7 <= 1'b0;
    else if (flush_state_t6_en)
      flush_state_t7 <= flush_state_t6;
  end


// Single pulse fifo_flush_ack_o
  assign  fifo_flush_ack_o = (flush_state_t7 & (fifo_ready_i | fifo_idle_ack_t6)) | (|flush_delay_t6 & fifo_idle_ack_t6);

// Flush needs to stall if new data arrives just before partial output flushed.
  assign  flush_data_valid_t6 = flush_valid_t6 & ~async_valid_t6 &
                                ~ovfl_valid_t6 &
                                (|flush_pos_t6[1:0]) &
                                (~flush_state_t7);

  assign  flush_done_t6 = (flush_state_t6) &
                          (rd_data_t6_en | ~fifo_valid_t7);

//---------------------------------------------------------------------------
// Idle req Handling
//---------------------------------------------------------------------------

  assign fifo_idle_req_t5 = fifo_idle_req_t2_i & (fifo_idle_req_t6 |~ts_output_en_pend_t4) & ~ovfl_req_t2_i;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_idle_req_t6
    if (!po_reset_n)
      fifo_idle_req_t6 <= 1'b0;
    else
      fifo_idle_req_t6 <= fifo_idle_req_t5;
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uts_output_en_pend_t4
    if (!po_reset_n)
      ts_output_en_pend_t4 <= 1'b0;
    else
      ts_output_en_pend_t4 <= ts_output_en_pend_t3_i;
  end


  assign fifo_idle_ack_t5 = (fifo_idle_req_t6 & (flush_pos_t6[7:0]== 8'hFF) & ~flush_state_t7 &
                            (~ovfl_valid_t6 & ~async_data_valid_t6 &
                            ((fifo_has_no_bytes_t6 & (async_pos_t6[7:0] == 8'hFF) & (ovfl_pos_t6[7:0] == 8'hFF)) | idle_comitted_t6))) |
                            (fifo_idle_req_t6 & fifo_idle_ack_t6);


  assign fifo_idle_ack_t5_en = ~((~fifo_ready_i & fifo_valid_t7) | fifo_valid_t6) | ~fifo_idle_req_t6;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_idle_ack_t6
    if (!po_reset_n)
      fifo_idle_ack_t6 <= 1'b0;
    else if (fifo_idle_ack_t5_en)
      fifo_idle_ack_t6 <= fifo_idle_ack_t5;
  end


  assign fifo_idle_ack_o = fifo_idle_ack_t6;

//---------------------------------------------------------------------------
// FIFO Empty indicated when less than 4 bytes
//---------------------------------------------------------------------------

// the MSB for the rd and wr byte ptr
  assign wrap_rd_t6 = rd_word_ptr_t6[5];

  assign wrap_wr_t6 = wr_byte_ptr_t6[7];
  assign wrap_wr_t7 = wr_byte_ptr_t7[7];

// the distance between the wr and rd ptrs (with wr ptr ahead). t6 for input, t7 output.
  assign diff_wr_rd_t7[6:0] = (wrap_rd_t6 == wrap_wr_t7) ?
                               (wr_byte_ptr_t7[6:0] - {rd_word_ptr_t6[4:0],2'b00}) :
                               (wr_byte_ptr_t7[6:0] + CA53_ETM_MAIN_FIFO_DEPTH - {rd_word_ptr_t6[4:0],2'b00});


// if wr byte ptr = rd byte ptr, FIFO is empty. Must check both due to alignment jump
// when flushing. t7 value would be invalid due to wrap
  assign fifo_not_empty_t7 = (|diff_wr_rd_t7[6:2]) & (~fifo_waiting_t6);

// Empty indicates no more will drain (see assertion)
// fifo_waiting_t6 nearly empty
  assign fifo_waiting_t6 = fifo_space_final_t6[6] & fifo_space_final_t6[4] & (fifo_space_final_t6[2] | (|fifo_space_final_t6[1:0]));


// True empty
  assign fifo_has_no_bytes_t6 = fifo_space_final_t6[6] & fifo_space_final_t6[4] & fifo_space_final_t6[2];

  assign fifo_empty_t6 = ovfl_state_t7 & rd_data_t6_en;
  
  
  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_empty_t7
    if (!po_reset_n)
      fifo_empty_t7 <= 1'b0;
    else
      fifo_empty_t7 <= fifo_empty_t6;
  end

// Any pending async and overflow will be done when empty is asserted
  assign  fifo_empty_o = fifo_empty_t7;

//---------------------------------------------------------------------------
//   Track free space in FIFO
//---------------------------------------------------------------------------
  assign fifo_space_final_t6[6:0] = fifo_all_overflow_t6 ? {2'b00,fifo_space_recover_t6[4:0]} : fifo_space_t6[6:0];

  assign fifo_space_t5[6:0] = ({fifo_space_final_t6[6:2],{2{~write_align_valid_t5}} & fifo_space_final_t6[1:0]}) +   // current space this cycle +
                               {4'b0000,rd_inc_t6_en,2'b00} -                                              // any read this cyle +
                               {2'b00,{5{~(fifo_overflow_t5 | fifo_all_overflow_t6)}} & num_bytes_t5_i[4:0]};       // new bytes written when no oveflow.

  assign fifo_space_recover_t5[4:0] = ({fifo_space_final_t6[4:2],{2{~write_align_valid_t5}} & fifo_space_final_t6[1:0]}) +   // current space this cycle +
                                       {2'b00,rd_inc_t6_en,2'b00};                                          // any read this cycle.

// On reset fifo_space_t6[6:0] is set to CA53_ETM_MAIN_FIFO_DEPTH
// On reset fifo_space_recover_t6[6:0] is set to CA53_ETM_MAIN_FIFO_DEPTH

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_spacer_q
    if (!po_reset_n) begin
      fifo_space_t6[1:0]         <= {2{1'b0}};
      fifo_space_t6[3]           <= 1'b0;
      fifo_space_t6[5]           <= 1'b0;
      fifo_space_recover_t6[1:0] <= {2{1'b0}};
      fifo_space_recover_t6[3]   <= 1'b0;
    end
    else begin
      fifo_space_t6[1:0]         <= fifo_space_t5[1:0];
      fifo_space_t6[3]           <= fifo_space_t5[3];
      fifo_space_t6[5]           <= fifo_space_t5[5];
      fifo_space_recover_t6[1:0] <= fifo_space_recover_t5[1:0];
      fifo_space_recover_t6[3]   <= fifo_space_recover_t5[3];
    end
  end

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_spaces_q
    if (!po_reset_n) begin
      fifo_space_t6[2]         <= {1{1'b1}};
      fifo_space_t6[4]         <= {1{1'b1}};
      fifo_space_t6[6]         <= {1{1'b1}};
      fifo_space_recover_t6[2] <= {1{1'b1}};
      fifo_space_recover_t6[4] <= {1{1'b1}};
    end
    else begin
      fifo_space_t6[2]         <= fifo_space_t5[2];
      fifo_space_t6[4]         <= fifo_space_t5[4];
      fifo_space_t6[6]         <= fifo_space_t5[6];
      fifo_space_recover_t6[2] <= fifo_space_recover_t5[2];
      fifo_space_recover_t6[4] <= fifo_space_recover_t5[4];
    end
  end


  assign fifo_overflow_t5         = {2'b00,num_bytes_t5_i[4:0]} > fifo_space_t6[6:0];
  assign fifo_overflow_aligned_t5 = {2'b00,num_bytes_t5_i[4:0]} > {fifo_space_t6[6:2],2'b00};

//---------------------------------------------------------------------------
// FIFO Overflow
//---------------------------------------------------------------------------

  assign fifo_all_overflow_t6 = fifo_overflow_t6 | (fifo_overflow_aligned_t6 & write_align_valid_t6);

  assign fifo_overflow_o = fifo_all_overflow_t6;


//---------------------------------------------------------------------------
// FIFO status
//---------------------------------------------------------------------------

// Fifo status outputs for the periodic sync counter.
  assign fifo_8bytes_t6_o = rd_word_ptr_t6[0] & rd_inc_t6_en;

// FIFO already has more than 24 to 33 bytes.
// used to delay insertion of synchronization packets.
  assign fifo_level28_t6 = (fifo_space_t6 < 7'h3C) | 
                           ((fifo_space_t6 < 7'h44) & (num_bytes_t5_i > 5'h08)) | 
                           ((fifo_space_t6 < 7'h4C) & (num_bytes_t5_i[4]));

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_level28_t7
    if (!po_reset_n)
      fifo_level28_t7 <= 1'b0;
    else
      fifo_level28_t7 <= fifo_level28_t6;
  end




  assign fifo_level28_t7_o = fifo_level28_t7;


// CPU stall request generated based on the FIFO depth and related control registers
// stall_level_reg_i:   00: no stall
//                      01: level 1: stall CPU if FIFO has less than 8 bytes space
//                      10: level 2: stall CPU if FIFO has less than 24 bytes space
//                      11: level 3: stall CPU if FIFO has less than 43 bytes space

  assign stall_cpu_level1_t6 = (~fifo_space_t6[6] & ~fifo_space_t6[5] & ~fifo_space_t6[4] & ~fifo_space_t6[3]);

  assign stall_cpu_level2_t6 = ((~fifo_space_t6[6] & ~fifo_space_t6[5]) &
                                (~fifo_space_t6[4] | (fifo_space_t6[4] & ~fifo_space_t6[3])));

  assign stall_cpu_level3_t6 = ((~fifo_space_t6[6] & ~fifo_space_t6[5]) |
                                ((~fifo_space_t6[6] & fifo_space_t6[5]) &
                                 ((~fifo_space_t6[4] & ~fifo_space_t6[3]) |
                                  (~fifo_space_t6[4] & fifo_space_t6[3] & ~fifo_space_t6[2]))
                                )
                               );


  assign etm_stall_cpu_t6 = istall_reg_i                     &
                            (((stall_level_reg_i == 2'b01) & stall_cpu_level1_t6) |
                             ((stall_level_reg_i == 2'b10) & stall_cpu_level2_t6) |
                             ((stall_level_reg_i == 2'b11) & stall_cpu_level3_t6)
                            );

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uetm_stall_cpu
    if (!po_reset_n)
      etm_stall_cpu_t7 <= 1'b0;
    else
      etm_stall_cpu_t7 <= etm_stall_cpu_t6;
  end

  assign etm_stall_cpu_o = etm_stall_cpu_t7;


//---------------------------------------------------------------------------
// Reading operations of the FIFO
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Read Pointer Calculation
// Use row/col as FIFO size is not power of 2 wide.
//---------------------------------------------------------------------------

// increment read pointer only when async is outputting data from FIFO
  assign  normal_data_t6 = (~(async_valid_t6 | ovfl_valid_t6) |
                             (async_done_t6 &  ~ovfl_valid_t6 & (|async_pos_t6[1:0]) & ~async_when_empty_t6) |
                             (ovfl_done_t6 & (|ovfl_pos_t6[1:0]) & ~ovfl_when_empty_t6)
                           );

// Read Pointer Enable
// increment the rd ptr when holding reg is free, or will be emptied
// After a flush_align, delay one cycle.
  assign rd_inc_t6_en = (idle_comitted_t6 & ~fifo_idle_ack_t6 & ~ovfl_valid_t6 & ~async_valid_t6) |
                        ( (fifo_read_valid_t6 & ~flush_idle_write_align_valid_t5) &
                          (~fifo_valid_t7 | fifo_ready_i) &
                          normal_data_t6);

// Read Column Pointer counts up from 0 to 6 (7 = (28 bytes / 4 bytes))
  assign rd_col_ptr_t5[2:0] = {3{~(rd_col_ptr_t6[2:0] == 3'b110)}} &
                              (rd_col_ptr_t6[2:0] + 3'b001);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: urd_col_ptr_t6_2_0
    if (!po_reset_n)
      rd_col_ptr_t6[2:0] <= {3{1'b0}};
    else if (rd_inc_t6_en)
      rd_col_ptr_t6[2:0] <= rd_col_ptr_t5[2:0];
  end


// Read Row Pointer counts from 0 to 2 (3*28 = 84 bytes)
  assign rd_row_ptr_t5[1:0] = {2{~(rd_row_ptr_t6[1:0] == 2'b10)}} & (rd_row_ptr_t6[1:0] + 2'b01);

  assign rd_inc_row_t5_en = (rd_col_ptr_t6[2:0] == 3'b110) & rd_inc_t6_en;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: urd_row_ptr_t6_1_0
    if (!po_reset_n)
      rd_row_ptr_t6[1:0] <= {2{1'b0}};
    else if (rd_inc_row_t5_en)
      rd_row_ptr_t6[1:0] <= rd_row_ptr_t5[1:0];
  end


// Read word Pointer counts directly from 0 to 20 (counting words)
// This pointer has an extra bit to handle wrap-round
  assign rd_word_ptr_t5[5:0] = (rd_word_ptr_t6[4:0] == 5'b10100) ? ({~wrap_rd_t6 , 5'b00000}) :
                                                                     rd_word_ptr_t6[5:0] + 6'b000001;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: urd_word_ptr_t6_5_0
    if (!po_reset_n)
      rd_word_ptr_t6[5:0] <= {6{1'b0}};
    else if (rd_inc_t6_en)
      rd_word_ptr_t6[5:0] <= rd_word_ptr_t5[5:0];
  end


//---------------------------------------------------------------------------
// Read Mux
//---------------------------------------------------------------------------

// the read enable flag - for incrementing the rd_ptr and also the valid signal
// Once idle is acknowledged, output is stalled.
// if wr and rd are on the different slot, wr must be ahead of rd, so read enable
// if wr and rd are on same slot: if wr is ahead of rd by more than 3 - on
//                                if wr is ahead of rd by less than 4 but there is a flush or idle_req - on
//                                otherwise - off
  assign  fifo_read_valid_t6 = ~idle_comitted_t6 &
                               ~fifo_idle_ack_t6 & (~((wrap_wr_t7 == wrap_rd_t6)| (wrap_wr_t6 == wrap_rd_t6)) |
                                                      fifo_not_empty_t7 |
                                                      ((~fifo_has_no_bytes_t6) & (diff_wr_rd_t7[6:0] != {7{1'b0}}) & // t7 is sometimes invalid
                                                       ((flush_valid_t6 & |flush_pos_t6[1:0]) |
                                                        (~wr_ptr_updates & ~valid_flush_req_t5 & fifo_idle_req_t6))));


// FIFO data read function: fifo_data_normal_t6[31:0] = fifo_data[rd_row_ptr_t6][rd_col_ptr_t6*32 +: 32];

  always @ * begin: ufifo_data_normal_t6
    case(rd_col_ptr_t6)
      3'b000:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][0*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][0*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][0*32 +: 32] ;
      3'b001:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][1*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][1*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][1*32 +: 32] ;
      3'b010:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][2*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][2*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][2*32 +: 32] ;
      3'b011:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][3*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][3*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][3*32 +: 32] ;
      3'b100:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][4*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][4*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][4*32 +: 32] ;
      3'b101:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][5*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][5*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][5*32 +: 32] ;
      3'b110:  fifo_data_normal_t6[31:0] = ({32{(rd_row_ptr_t6 == 2'b00)}}) & fifo_data[0][6*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b01)}}) & fifo_data[1][6*32 +: 32] |
                                           ({32{(rd_row_ptr_t6 == 2'b10)}}) & fifo_data[2][6*32 +: 32] ;
      default: fifo_data_normal_t6[31:0] = {32{1'bx}};
    endcase
  end


// Valid bytes in output word minus 1, (3 if all valid)
// Flush alignment gap is factored in here.
  assign  fifo_bytes_normal_t6[1] = flush_align_done_t6 ? ~^flush_pos_t6[1:0]: ((|diff_wr_rd_t7[6:2]) | (&wr_byte_ptr_t7[1:0]));
  assign  fifo_bytes_normal_t6[0] = flush_align_done_t6 ? ~flush_pos_t6[0]: ((|diff_wr_rd_t7[6:2]) | (~wr_byte_ptr_t7[0] & wr_byte_ptr_t7[1]));

// Idle should stall any special packets
  assign  rd_data_t6_en = (fifo_ready_i & fifo_valid_t7) |
                           ((fifo_read_valid_t6 | async_data_valid_t6 |
                             ovfl_data_valid_t6 | flush_data_valid_t6) &
                            ~fifo_valid_t7 & ~fifo_idle_ack_t6);

  assign  merged_data_t6[31:0] = async_data_t6[31:0] | ovfl_data_t6[31:0];
  assign  merged_bytes_t6[1:0] = async_bytes_t6[1:0] | ovfl_bytes_t6[1:0];

  always @(posedge clk_gated)
  begin: ufifo_t7
    if (rd_data_t6_en) begin
      fifo_data_t7[31:0] <= merged_data_t6[31:0];
      fifo_bytes_t7[1:0] <= merged_bytes_t6[1:0];
    end
  end


  assign  fifo_data_o[31:0] = fifo_data_t7[31:0];
  assign  fifo_bytes_o[1:0] = fifo_bytes_t7[1:0];

  assign  fifo_valid_t6 = (fifo_read_valid_t6 & normal_data_t6) |
                          async_data_valid_t6 |
                          ovfl_data_valid_t6  |
                          flush_data_valid_t6;

  always @(posedge clk_gated or negedge po_reset_n)
  begin: ufifo_valid_t7
    if (!po_reset_n)
      fifo_valid_t7 <= 1'b0;
    else if (rd_data_t6_en)
      fifo_valid_t7 <= fifo_valid_t6;
  end


  assign  fifo_valid_o = fifo_valid_t7;

//---------------------------------------------------------------------------
// Write operation of FIFO
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Write Pointer Calculation
// Use row/col as FIFO size is not power of 2 wide.
//---------------------------------------------------------------------------

// This is the last (extended) column to write to if data is accepted.
  assign wr_col_plus_t5[5:0] = write_align_valid_t5 ?
                              ({1'b0, wr_col_next_word_t6[4:2],2'b00} + {1'b0, num_bytes_t5_i[4:0]}):
                              ({1'b0, wr_col_ptr_t6[4:0]} + {1'b0, num_bytes_t5_i[4:0]});


// Align write point to word aligned in special case (with overflow happening with async/ovfl)
  assign wr_col_next_word_t6[4:2] = wr_col_ptr_t6[4:2] + 3'b001;

// Column Byte Pointer Calculation
// Without overflow, the normal column pointer calculation :
// equivalent to if wr_col_plus_t5[5:0]is greater or equal to 6'd28,
// subtract 6'd28 from it, otherwise, wr_col_wrap_t5[4:0] equals to wr_col_plus_t5

  // here's the pla table sent to espresso:
  //
  // wr_col_plus_t5[5:0]
  // |      wr_col_wrap_t5[4:0]
  // |      |
  // 000000 00000
  // 000001 00001
  // 000010 00010
  // 000011 00011
  // 000100 00100
  // 000101 00101
  // 000110 00110
  // 000111 00111
  // 001000 01000
  // 001001 01001
  // 001010 01010
  // 001011 01011
  // 001100 01100
  // 001101 01101
  // 001110 01110
  // 001111 01111
  // 010000 10000
  // 010001 10001
  // 010010 10010
  // 010011 10011
  // 010100 10100
  // 010101 10101
  // 010110 10110
  // 010111 10111
  // 011000 11000
  // 011001 11001
  // 011010 11010
  // 011011 11011
  // 011100 00000
  // 011101 00001
  // 011110 00010
  // 011111 00011
  // 100000 00100
  // 100001 00101
  // 100010 00110
  // 100011 00111
  // 100100 01000
  // 100101 01001
  // 100110 01010
  // 100111 01011
  // 101000 01100
  // 101001 01101
  // 101010 01110
  // 101011 01111
  // 101100 10000
  // 101101 10001
  // 101110 10010
  // 101111 10011
  // 110000 10100
  // 110001 10101
  // 110010 10110
  // 110011 10111
  // 110100 11000
  // 110101 11001
  // 110110 11010
  // 110111 11011
  // default:
  // 111--- -----
  //
  // the following equations are the espresso output

  assign wr_col_wrap_t5[4] = (wr_col_plus_t5[4]&!wr_col_plus_t5[3]) | (
    wr_col_plus_t5[4]&!wr_col_plus_t5[2]) | (wr_col_plus_t5[5]
    &wr_col_plus_t5[3]&wr_col_plus_t5[2]);

  assign wr_col_wrap_t5[3] = (!wr_col_plus_t5[5]&!wr_col_plus_t5[4]
    &wr_col_plus_t5[3]&wr_col_plus_t5[2]) | (wr_col_plus_t5[3]
    &!wr_col_plus_t5[2]) | (wr_col_plus_t5[5]&!wr_col_plus_t5[3]
    &wr_col_plus_t5[2]);

  assign wr_col_wrap_t5[2] = (!wr_col_plus_t5[5]&!wr_col_plus_t5[4]
    &wr_col_plus_t5[3]&wr_col_plus_t5[2]) | (!wr_col_plus_t5[5]
    &!wr_col_plus_t5[3]&wr_col_plus_t5[2]) | (wr_col_plus_t5[5]
    &!wr_col_plus_t5[2]);

  assign wr_col_wrap_t5[1] = (wr_col_plus_t5[1]);

  assign wr_col_wrap_t5[0] = (wr_col_plus_t5[0]);

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwr_col_ptr_t6_4_0
    if (!po_reset_n)
      wr_col_ptr_t6[4:0] <= {5{1'b0}};
    else if (wrptr_en_t5)
      wr_col_ptr_t6[4:0] <= wr_col_wrap_t5[4:0];
  end


// Un-wrapped version used to select active lanes, wrap means next row.
// Wrapped version used for rotation
  assign wr_col_ptr_inc_t5[4:2] = wr_col_ptr_t6[4:2] + {2'b00, write_align_valid_t5};
  assign wr_col_ptr_inc_t5[1:0] = {2{~write_align_valid_t5}} & wr_col_ptr_t6[1:0];

  assign wr_col_ptr_inc_wrap_t6[4:2] = {3{~(wr_col_ptr_inc_t6[4] & wr_col_ptr_inc_t6[3] & wr_col_ptr_inc_t6[2])}} &
                                        wr_col_ptr_inc_t6[4:2];
  assign wr_col_ptr_inc_wrap_t6[1:0] = wr_col_ptr_inc_t6[1:0];

// Row Pointer Calculation for data wrapping past end of row

  // here's the pla table sent to espresso:
  //
  //  wr_row_ptr_t6[1:0]
  //  |  wr_row_ptr_wrap_56_t6[1:0]
  //  |  |
  //  00 01
  //  01 10
  //  10 00
  // default:
  // - 11 --
  //
  // the following equations are the espresso output

  assign wr_row_ptr_wrap_56_t6[1] = (wr_row_ptr_t6[0]);

  assign wr_row_ptr_wrap_56_t6[0] = (!wr_row_ptr_t6[1]&!wr_row_ptr_t6[0]);

  assign wr_row_ptr_inc_t5[1:0] = (wr_col_plus_t5[5:0] >= 6'b011100) ?
                                   wr_row_ptr_wrap_56_t6[1:0] : wr_row_ptr_t6[1:0];

  always @(posedge clk_gated or negedge po_reset_n)
  begin: uwr_row_ptr_t6_1_0
    if (!po_reset_n)
      wr_row_ptr_t6[1:0] <= {2{1'b0}};
    else if (wrptr_en_t5)
      wr_row_ptr_t6[1:0] <= wr_row_ptr_inc_t5[1:0];
  end


  assign wr_row_ptr_wrap_t7[1:0] = {2{~(wr_row_ptr_t7[1:0] == 2'b10)}} & (wr_row_ptr_t7[1:0] + 2'b01);


// rotate packed data to place first valid byte on correct fifo entry.
// Add (8-num_first8_t5_i). Rotation wraps at byte 28, so

  assign prerot_t6[5:0] = (wr_col_ptr_inc_wrap_t6[4:0] + {2'b00, num_first8_t6[2:0]});

  // here's the pla table sent to espresso:
  //
  // prerot_t6[5:0]
  // |      final_rot_value_t6[4:0]
  // |      |
  // 000000 10100
  // 000001 10101
  // 000010 10110
  // 000011 10111
  // 000100 11000
  // 000101 11001
  // 000110 11010
  // 000111 11011
  // 001000 00000
  // 001001 00001
  // 001010 00010
  // 001011 00011
  // 001100 00100
  // 001101 00101
  // 001110 00110
  // 001111 00111
  // 010000 01000
  // 010001 01001
  // 010010 01010
  // 010011 01011
  // 010100 01100
  // 010101 01101
  // 010110 01110
  // 010111 01111
  // 011000 10000
  // 011001 10001
  // 011010 10010
  // 011011 10011
  // 011100 10100
  // 011101 10101
  // 011110 10110
  // 011111 10111
  // 100000 11000
  // 100001 11001
  // 100010 11010
  // 100011 11011
  // default:
  // 1--1-- -----
  // 1-1--- -----
  // 11---- -----
  //
  // the following equations are the espresso output

  assign final_rot_value_t6[4] = (!prerot_t6[4]&!prerot_t6[3]&prerot_t6[2]) | (
    prerot_t6[5]) | (prerot_t6[4]&prerot_t6[3]) | (!prerot_t6[5]
    &!prerot_t6[4]&!prerot_t6[3]&!prerot_t6[2]);

  assign final_rot_value_t6[3] = (!prerot_t6[4]&!prerot_t6[3]&prerot_t6[2]) | (
    prerot_t6[5]) | (prerot_t6[4]&!prerot_t6[3]);

  assign final_rot_value_t6[2] = (prerot_t6[4]&prerot_t6[2]) | (prerot_t6[3]
    &prerot_t6[2]) | (!prerot_t6[5]&!prerot_t6[4]&!prerot_t6[3]
    &!prerot_t6[2]);

  assign final_rot_value_t6[1] = (prerot_t6[1]);

  assign final_rot_value_t6[0] = (prerot_t6[0]);

// Rotate the input data
  ca53etm_fifo_rotate u_fifo_rotate (
    .pack_fifo_in_t6_i (pack_fifo_in_t6[203:0]),
    .rotation_i        (final_rot_value_t6[4:0]),

    .fifo_data_in_t6_o (fifo_data_in_t6[223:0])
  );

// Set Active Bytes in Columns
// byte lane is valid
// if current pointer <= byte n  &&  next pointer > byte n
// or if current pointer >= byte n  &&  next pointer > fifowidth + n
//
  // Compute the fifo_byte_active_t6 array, indicating which bytes (columns) will
  // be written to

  // write_start_mask contains a 1 in the bits corresponding to the current
  // column write pointer and beyond, e.g. if wr_col_ptr_inc_t6 is 3, then
  // write_start_mask would equal to ....1111111000
  // write_end_mask contains a 1 in the bits corresponding to the next
  // column write pointer (before wrapping) and beyond
  // Thus the bits that are different between the two masks indicate bytes
  // that should be written this cycle


  assign write_start_mask = {28  {1'b1}} << wr_col_ptr_inc_t6;
  assign write_end_mask   = {28*2{1'b1}} << wr_col_plus_t6;


  assign fifo_byte_active_tmp_t6 = write_start_mask ^ write_end_mask[27:0]   |
                                  ~write_end_mask[28*2-1:28];

  assign  fifo_byte_active_t6 = {28{~(fifo_all_overflow_t6 | fifo_all_overflow_t7)}} & fifo_byte_active_tmp_t6[27:0];

// Set Active Row
  generate
    for (i = 0; i < 27; i = i + 1) begin : ufifo_row_wr_ptr
      assign fifo_row_wr_ptr_t6[i] = (i[4:0] >= wr_col_ptr_inc_t6[4:0]) ? wr_row_ptr_t7[1:0] : wr_row_ptr_wrap_t7[1:0] ;
    end
  endgenerate

  assign  fifo_row_wr_ptr_t6[27] = (5'b11100 != wr_col_ptr_inc_t6[4:0]) ? wr_row_ptr_t7[1:0] : wr_row_ptr_wrap_t7[1:0] ;

//---------------------------------------------------------------------------
//   FIFO elements
//---------------------------------------------------------------------------
//
//
// fifo_byte_active_t6 to indicate which column bytes should be written,
// fifo_row_ptr_t6 to indicate which row of the selected column should be written to

  generate
    for (i = 0; i < 28; i = i + 1) begin : ufifo_column_wr
      always @(posedge clk_gated)
        if (fifo_byte_active_t6[i])
          case (fifo_row_wr_ptr_t6[i])
            2'b00:   fifo_data[0][(i*8) +: 8] <= fifo_data_in_t6[(i*8) +: 8];
            2'b01:   fifo_data[1][(i*8) +: 8] <= fifo_data_in_t6[(i*8) +: 8];
            2'b10:   fifo_data[2][(i*8) +: 8] <= fifo_data_in_t6[(i*8) +: 8];
            2'b11:   fifo_data[0][(i*8) +: 8] <= {8{1'b0}}; //unreachable
            default: fifo_data[0][(i*8) +: 8] <= {8{1'bx}};
          endcase
    end
  endgenerate


//---------------------------------------------------------------------------
// Pipeline data and pointers before rotate and write
//---------------------------------------------------------------------------
  assign new_bytes_t5 = |num_bytes_t5_i[4:0];

  always @(posedge clk_gated or negedge po_reset_n)
  begin: upipe_data_ptr_q
    if (!po_reset_n) begin
      wr_col_ptr_inc_t6[4:0]    <= {5{1'b0}};
      wr_col_plus_t6[5:0]       <= {6{1'b0}};
      wr_row_ptr_t7[1:0]        <= {2{1'b0}};
      wr_byte_ptr_t7[7:0]       <= {8{1'b0}};
      num_first8_t6[2:0]        <= {3{1'b0}};
      new_bytes_t6              <= 1'b0;
      fifo_overflow_t6          <= 1'b0;
      fifo_overflow_aligned_t6  <= 1'b0;
      fifo_all_overflow_t7      <= 1'b0;
      idle_comitted_t6          <= 1'b0;
      write_align_valid_t6      <= 1'b0;
    end
    else begin
      wr_col_ptr_inc_t6[4:0]    <= wr_col_ptr_inc_t5[4:0];
      wr_col_plus_t6[5:0]       <= wr_col_plus_t5[5:0];
      wr_row_ptr_t7[1:0]        <= wr_row_ptr_t6[1:0];
      wr_byte_ptr_t7[7:0]       <= wr_byte_ptr_t6[7:0];
      num_first8_t6[2:0]        <= num_first8_t5_i[2:0];
      new_bytes_t6              <= new_bytes_t5;
      fifo_overflow_t6          <= fifo_overflow_t5;
      fifo_overflow_aligned_t6  <= fifo_overflow_aligned_t5;
      fifo_all_overflow_t7      <= fifo_all_overflow_t6;
      idle_comitted_t6          <= flush_idle_write_align_valid_t5;
      write_align_valid_t6      <= write_align_valid_t5;
    end
  end

  assign fifo_in_en = |num_bytes_t5_i[4:0];

  always @(posedge clk_gated)
  begin: ufifo_in_t6_191_0
    if (fifo_in_en)
      pack_fifo_in_t6[203:0] <= pack_fifo_in_t5_i[203:0];
  end


//--------------------------------------------------------------------------
// ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON
`include "ca53etm_val_defs.v"


 reg [4:0] sva_num_bytes_t6;
 reg [4:0] sva_num_bytes_t7;
 reg [4:0] sva_num_bytes_t8;

 always @(posedge clk_gated or negedge po_reset_n)
  if(!po_reset_n)
   begin
    sva_num_bytes_t6 <=  5'b00000;
    sva_num_bytes_t7 <=  5'b00000;
    sva_num_bytes_t8 <=  5'b00000;
   end
  else
   begin
    sva_num_bytes_t6 <=  num_bytes_t5_i[4:0];
    sva_num_bytes_t7 <=  sva_num_bytes_t6;
    sva_num_bytes_t8 <=  sva_num_bytes_t7;
   end

// Check the rotation value (wptr -8 + num_first) wrapped at 28.
  wire [5:0] sva_rot_value_1;
  wire [5:0] sva_rot_value_fold;

  assign sva_rot_value_1 = {1'b0,wr_col_ptr_inc_wrap_t6[4:0]} + 6'b010100 + {2'b00, num_first8_t6[2:0]};
  assign sva_rot_value_fold = (sva_rot_value_1 > 6'd27) ? (sva_rot_value_1-6'd28) : sva_rot_value_1;

  usva_rot_value: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    {1'b0,final_rot_value_t6[4:0]} == sva_rot_value_fold)
    `SVA_FATAL("Rotation value mismatch");


// Check the fifo write enable strobes.
  wire [4:0] sva_valid_lanes;
  assign sva_valid_lanes = $countones(fifo_byte_active_tmp_t6);

  usva_count_enables: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    sva_num_bytes_t6 == sva_valid_lanes)
    `SVA_FATAL("Number of enabled FIFO bytes does not match num_bytes_t5_i");

// Assertion for fifo_overflow and fifo_empty
  usva_over_empty: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    !((fifo_overflow_o == 1'b1) & (fifo_empty_o == 1'b1)))
    `SVA_FATAL("Overflow and Empty at the same time");

// Async byte pointer should be >=0 and <=83 or 7'b111_1111
  usva_async_pos: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ((async_pos_t5[6:0] >= 7'b0) & (async_pos_t5[6:0] <= 7'b1010011)) | (async_pos_t5[6:0] == 7'b1111111))
    `SVA_FATAL("async pointer out of range");

// Overflow byte pointer should be >=0 and <=83 or 7'b111_1111
  usva_ovfl_pos: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ((ovfl_pos_t5[6:0] >= 7'b0) & (ovfl_pos_t5[6:0] <= 7'b1010011)) | (ovfl_pos_t5[6:0] == 7'b1111111))
    `SVA_FATAL("ovfl pointer out of range");

// Write column pointer should be >=0 and <=27
  usva_wr_col_ptr_a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_t6[4:0] >= ( 0)))
    `SVA_FATAL("Write Column Pointer out of range");

  usva_wr_col_ptr_b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_t6[4:0] <= ( 27)))
    `SVA_FATAL("Write Column Pointer out of range");

// Final write column pointer should be >=0 and <=28
  usva_wr_col_ptr_inc_a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_inc_t5[4:0] >= ( 0)))
    `SVA_FATAL("Final Write Column Pointer out of range");

  usva_wr_col_ptr_inc_b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_inc_t5[4:0] <= ( 28)))
    `SVA_FATAL("Final Write Column Pointer out of range");

// Final wrapped write column pointer should be >=0 and <=27
  usva_wr_col_ptr_inc_wap_a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_inc_wrap_t6[4:0] >= ( 0)))
    `SVA_FATAL("Final Wraped Write Column Pointer out of range");

  usva_wr_col_ptr_inc_wap_b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_col_ptr_inc_wrap_t6[4:0] <= ( 27)))
    `SVA_FATAL("Final Wraped Write Column Pointer out of range");

// Read column pointer should be >=0 and <=6
  usva_rd_col_ptr: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (rd_col_ptr_t6[2:0] >= ( 0)) & (rd_col_ptr_t6[2:0] <= ( 6)))
    `SVA_FATAL("Read Column Pointer out of range");

// Write byte pointer should be >=0 and <=111(84+27)
  usva_wr_byte_ptr: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_byte_ptr_inc_t5[6:0] >= ( 0)) & (wr_byte_ptr_inc_t5[6:0] <= ( 111)))
    `SVA_FATAL("Write Byte Pointer out of range");

// Write wrapped byte pointer should be >=0 and <=83
  usva_wr_ptr_valid: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (wr_byte_ptr_t6[6:0] >= ( 0)) & (wr_byte_ptr_t6[6:0] <= ( 83)))
    `SVA_FATAL("Write Wrapped Byte Pointer out of range");

  usva_fifo_valid_ready1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    {fifo_valid_o,fifo_ready_i} == 2'b10 |=> {fifo_valid_o,fifo_ready_i} != $past(2'b00))
    `SVA_FATAL("Valid data lost before sampled");

  usva_fifo_valid_ready2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    {fifo_valid_o,fifo_ready_i} == 2'b10 |=> {fifo_valid_o,fifo_ready_i} != $past(2'b01))
    `SVA_FATAL("Valid data lost before sampled");

  usva_fifo_empty_up_to_3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_waiting_t6 |-> fifo_space_final_t6[6:0] > 7'd80)
    `SVA_FATAL("fifo_empty_o must not be set if fifo_space_final_t6[6:0] is less than 80");

  usva_fifo_space: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_final_t6[6:0] < 7'h55))
    `SVA_ERROR("Fifo space must be less than 85 apart from 1 cycle when being flushed");

  usva_fifo_space_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_final_t6[6:0] == 7'h54) |-> (~fifo_all_overflow_t6))
    `SVA_FATAL("Fifo must not overflow when empty");

  usva_fifo_space_7: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_final_t6[6:0] == 7'h54)|-> ((wrap_wr_t6 == wrap_rd_t6)))
    `SVA_FATAL("Fifo space must be less than 85");

// Overflow sequence
  usva_fifo_overflow_1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i > fifo_space_final_t6) |-> ##1 (fifo_space_final_t6 < 7'h20))
    `SVA_FATAL("After overflow + 1 cycle, less than 28+4 bytes free");

  usva_fifo_overflow_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i > fifo_space_final_t6) |-> ##2 (fifo_space_final_t6 < 7'h24))
    `SVA_FATAL("After overflow + 2 cycles, less than 28+4+4 bytes free");
  //Calculation of recovery had redundant bits
  usva_fifo_overflow_3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_t5 > 7'h54) |-> fifo_space_recover_t5 < 7'h20)
    `SVA_FATAL("fifo_space_recover_t5 must less than 32 ");

  usva_fifo_overflow_3a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_t5 > 7'h54) |-> fifo_space_final_t6 < 7'h20)
    `SVA_ERROR("fifo_space_final_t6 must less than 32 ");

  //Check valid to truncate overflow calc
  usva_fifo_overflow_3b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_all_overflow_t6) |-> fifo_space_final_t6 < 7'h1F)
    `SVA_FATAL("fifo_space_final_t6 must less than 31 ");

  usva_fifo_overflow_4: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (fifo_space_recover_t5 < 7'h55))
    `SVA_FATAL("fifo_space_recover_t5 must less than 85 ");

  usva_single_async: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    async_req_t4_i == 1'b1 |=> async_req_t4_i != $past(1'b1))
    `SVA_FATAL("Single cycle pulse async_req_t4");

  usva_single_8bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_8bytes_t6_o == 1'b1 |=> fifo_8bytes_t6_o != $past(1'b1))
    `SVA_FATAL("Single cycle pulse fifo_8bytes_t6_o");

  // Stall low priority inputs at 56 bytes space, less not 4 taken
  usva_level28h: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_level28_t6 |-> fifo_space_t5 <= 7'h40)
    `SVA_FATAL("Stall indicated with more than 64 bytes space"); 
 usva_level28l: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t5 < 7'h2f |-> fifo_level28_t6)
    `SVA_FATAL("Stall not indicated with less than 48 bytes space");
    
  usva_async_repeat_3b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      async_req_t5 & valid_async_req_t5 ##1
      async_valid_t6                        |->
      ~ovfl_valid_t6)
    `SVA_FATAL("Repeated async not expected when in overflow");
    
  usva_async_repeat_4: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      ~async_valid_t6 ##1
      async_valid_t6 & ~ovfl_valid_t6 |->
      ##2 ~&async_pos_t6)
    `SVA_FATAL("Async sequence property violated");
    
  usva_async_repeat_5: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      ~async_valid_t6 ##1
      async_valid_t6 & ~async_done_t6  & ~ovfl_valid_t6 |->
      ~async_done_t6[*2])
    `SVA_FATAL("Async sequence property violated");

  // Proven
  usva_async_repeat_6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
      ~async_valid_t6 ##1
       async_valid_t6 |->
      ~async_done_t6)
    `SVA_FATAL("Async sequence property violated");
    
    wire [6:0] sva_rd_byte_ptr_t6 = {rd_word_ptr_t6[4:0],2'b00};
    
  // Helper for usva_async_repeat conditions
  // Overflow can't complete before I-pipe is stopped
  usva_async_overflow_stop: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o |=>
                                        ~ovfl_valid_t6)
    `SVA_FATAL("Overflow can't finish as overflow is indicated to I-pipe");
  usva_async_overflow_stop2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o |=>
                                        ~ovfl_valid_t6[*3])
    `SVA_FATAL("Overflow can't finish as overflow is indicated to I-pipe");    
  usva_async_overflow_stop_ind: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o & ~ovfl_valid_t6 |=>
                                        ~ovfl_valid_t6)
    `SVA_FATAL("Overflow can't finish as overflow is indicated to I-pipe");    
  usva_async_overflow_stop_ind2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o ##1 ~ovfl_valid_t6 |=>
                                        ~ovfl_valid_t6)
    `SVA_FATAL("Overflow can't finish as overflow is indicated to I-pipe");    
// Helper for overflow requires several cycles to reach end of fifo
  usva_overflow_pointer: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o & (wrap_wr_t6 == wrap_rd_t6) |->
                                        (wr_byte_ptr_t6[6:0] - sva_rd_byte_ptr_t6) > 7'h20)
    `SVA_FATAL("Overflow requires more than 32 bytes in fifo");    
  usva_overflow_pointer2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o & (wrap_wr_t6 != wrap_rd_t6) |->
                                        (wr_byte_ptr_t6[6:0] - sva_rd_byte_ptr_t6 + CA53_ETM_MAIN_FIFO_DEPTH) > 7'h20)
    `SVA_FATAL("Overflow requires more than 32 bytes in fifo");
  // Normal overflow only occurs when fifo has data
  usva_overflow_pointer_a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o & (wrap_wr_t6 == wrap_rd_t6) & ~ovfl_req_t2_i |->
                                        (wr_byte_ptr_t6[6:0] - sva_rd_byte_ptr_t6) > 7'h20)
    `SVA_FATAL("Overflow (unforced) requires more than 32 bytes in fifo");
  // Basic overflow case
  usva_overflow_pointer_simple: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        num_bytes_t5_i == 5'h01 & ~ovfl_req_t2_i ##1
                                        fifo_overflow_o & (wrap_wr_t6 == wrap_rd_t6) & ~ovfl_req_t2_i |->
                                        (wr_byte_ptr_t6[6:0] - sva_rd_byte_ptr_t6) > 7'h20)
    `SVA_FATAL("Overflow (unforced) requires more than 32 bytes in fifo");

    
  usva_overflow_pointer2_a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        fifo_overflow_o & (wrap_wr_t6 != wrap_rd_t6) & ~ovfl_req_t2_i |->
                                        (wr_byte_ptr_t6[6:0] - sva_rd_byte_ptr_t6 + CA53_ETM_MAIN_FIFO_DEPTH) > 7'h20)
    `SVA_FATAL("Overflow (unforced) requires more than 32 bytes in fifo");    


    
// Check for reachable code:
usva_async_reach: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (ovfl_valid_t6 & ~ovfl_state_t7 & ~async_valid_t6) |-> ~async_when_empty_t6)
    `SVA_FATAL("Async from request when empty not expected at the same time as overflow");
  // Helpers for above
usva_async_reach3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (ovfl_valid_t6 & ~async_valid_t6) |-> ~async_when_empty_t6)
    `SVA_FATAL("Async from request when empty not expected at the same time as overflow");
usva_async_reach4: cover property (@(posedge clk_gated) disable iff (!po_reset_n)
    (async_when_empty_t6 & ~async_valid_t6));
usva_async_reach6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (~(&ovfl_pos_t6) & ~ovfl_valid_t6 & async_when_empty_t6) |=> ~ovfl_valid_t6)
    `SVA_FATAL("Async from request when empty not expected at the same time as overflow");
// pointers must be valid together
usva_async_empty: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    (async_when_empty_t6) |-> ~&async_pos_t6);
usva_ovfl_empty: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    (ovfl_when_empty_t6) |-> ~&ovfl_pos_t6);

// Helper assertions for usva_ovfl_empty
usva_ovfl_empty_ex1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    fifo_space_t6==7'h54 ##1 ovfl_done_t6 |=> &ovfl_pos_t6);
usva_ovfl_empty_ex2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    (~rd_inc_t6_en & fifo_space_t6==7'h54) ##1 
                                    (~rd_inc_t6_en & ovfl_done_t6)         |=> 
                                     &ovfl_pos_t6);
  
// Possible to see async @xxx00, bytes, overflow (all in same 4 byte block)
usva_async_overflow: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                    ~&ovfl_pos_t6 &
                                      (ovfl_pos_t6[7:2] == async_pos_t6[7:2]) &
                                      async_pos_t6[1:0] != 2'b00 |->
                                      (ovfl_pos_t6[1:0] == async_pos_t6[1:0])
                                      )
    `SVA_FATAL("Async and overflow can only coincide with async word aligned, or exactly together");

usva_async_overflow_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                      (ovfl_pos_t6 == async_pos_t6) &
                                      ovfl_state_t7 & rd_data_t6_en |=>
                                      (&{ovfl_pos_t6,async_pos_t6}))
    `SVA_ERROR("Async and overflow togtether clears async");

// FIFO INTERFACE
// --------------------

  wire sva_ovfl_output;
  wire sva_async_output;

// FIFO output looks like a ovfl packet. Could be set due to some other
// packet payload but this will not affect formal proofs which will be
// pessimistic when looking for a failure.
  wire sva_overflow_only  = (fifo_bytes_o == 2'b01) & (fifo_data_o[15:0] == 16'h0500);
  wire sva_overflow_event = (fifo_bytes_o == 2'b10) & (fifo_data_o[23:4] == 20'h05007);
  assign sva_ovfl_output = fifo_valid_o & (sva_overflow_event | sva_overflow_only);

// FIFO output looks like part of an async packet.
// Could be set due to some other packet payload but this will not
// affect assertions which will be pessimistic when looking for a failure.
  assign sva_async_output =
         fifo_valid_o & (((fifo_bytes_o[1:0] == 2'b11) & (fifo_data_o[31:0] == 32'h00000000)) |
                        ((fifo_bytes_o[1:0] == 2'b11) & (fifo_data_o[31:0] == 32'h80000000)));

  wire sva_fifo_idle_ack_o_1st;
  reg  sva_fifo_idle_ack_o_q;
  always @(posedge clk_gated or negedge po_reset_n)
   if (!po_reset_n)
     sva_fifo_idle_ack_o_q <=  1'b0;
   else
     sva_fifo_idle_ack_o_q <=  fifo_idle_ack_o;

// sva_fifo_idle_ack_o_1st only set for one cycle on the positive edge of fifo_idle_ack_o;
  assign sva_fifo_idle_ack_o_1st = fifo_idle_ack_o & ~sva_fifo_idle_ack_o_q;

  reg  sva_fifo_idle_req_q;
  always @(posedge clk_gated or negedge po_reset_n)
   if (!po_reset_n)
     sva_fifo_idle_req_q <=  1'b0;
   else
     sva_fifo_idle_req_q <=  (fifo_idle_req_t2_i | (sva_fifo_idle_req_q & ~sva_fifo_idle_ack_o_1st));

// FIFO INPUT INTERFACE
// --------------------

// Waypoint update packet                             = 7
// Branch packet for exception return with hyp change = 7
// Cycle count packet                                 = 5
// Exception Return Packet                            = 1
// Context Id Packet                                  = 5
// Virtual Machine ID Packet                          = 2
// Total                                              = 27
// num_bytes_t5_i <= 27
  usva_num_bytes_le_27: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i[4:0] <= ( 27)))
    `SVA_FATAL("num_bytes_t5_i <= 27");

// num_first <= num_bytes_t5_i
// num_bytes_t5_i-num_first <= 20 (
// Both of these are only valid if num_bytes_t5_i is not = 1 (turning off on a wpt update)
// Also not valid when num_bytes_t5_i is zero (no point in masking the wpt update if no atom)
  usva_num_diff_le_20a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i[4:1] != 4'b0000) |-> (({1'b0, num_bytes_t5_i[4:0]} - {2'b00, num_first8_t5_i}) >= ( 0)))
    `SVA_FATAL("0 <= num_bytes_t5_i - num_first8");

  usva_num_diff_le_20b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i[4:1] != 4'b0000) |->  (({1'b0, num_bytes_t5_i[4:0]} - {2'b00, num_first8_t5_i}) <= ( 20)))
    `SVA_FATAL("num_bytes_t5_i - num_first8 <= 20");

// num_first <= 8
  usva_num_first8_le_8: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_first8_t5_i >= ( 0)) & (num_first8_t5_i <= ( 8)))
    `SVA_FATAL("num_first8 <= 8");

  reg  sva_window_ovfl_req_t2;
  always @(posedge clk_gated or negedge po_reset_n)
   if (!po_reset_n)
     sva_window_ovfl_req_t2 <= 1'b0;
   else
     sva_window_ovfl_req_t2 <= (ovfl_req_t2_i | sva_window_ovfl_req_t2) & ~sva_ovfl_output;

// ovfl_req_t2 must not be re-asserted until ovfl has left
// fifo (progbit forces this in the system)
  usva_ovfl_req_window: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ovfl_req_t2_i |-> ~sva_window_ovfl_req_t2)
    `SVA_FATAL("ovfl_req_t2_i must not be set while a ovfl is in the fifo");

// fifo_overflow only set 1 cycle after num_bytes_t5_i > 0
  usva_fifo_overflow_num_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (num_bytes_t5_i == 5'd0) |=> ~fifo_overflow_o)
    `SVA_FATAL("fifo_overflow_o only set 1 cycle after num_bytes_t5_i!=0");

// fifo_8bytes_t6 not set if fifo_empty is set.
  reg sva_fifo_8bytes_t7;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_fifo_8bytes_t7 <=  1'b0;
    else
      sva_fifo_8bytes_t7 <=  fifo_8bytes_t6_o;

  usva_fifo_empty_level8: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_empty_o |-> ~fifo_8bytes_t6_o | ~sva_fifo_8bytes_t7)
    `SVA_FATAL("fifo_8bytes_t6_o must not be set if fifo_empty_o is set");

  usva_fifo_overflow_space: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_overflow_t6 |-> fifo_space_t6 < 7'h20)
    `SVA_FATAL("fifo overflow only occurs with less than 20 bytes free");

  usva_fifo_space_count: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 == 7'h00 |=>
    fifo_space_t6 == 7'h00 |
    fifo_space_t6 == 7'h04)
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 == 7'h01 |=>
    fifo_space_t6 == 7'h00 |
    fifo_space_t6 == 7'h01 |
    fifo_space_t6 == 7'h04 |
    fifo_space_t6 == 7'h05)
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 == 7'h02 |=>
    fifo_space_t6 == 7'h00 |
    fifo_space_t6 == 7'h01 |
    fifo_space_t6 == 7'h02 |
    fifo_space_t6 == 7'h03 |
    fifo_space_t6 == 7'h04 |
    fifo_space_t6 == 7'h05 |
    fifo_space_t6 == 7'h06)
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 <  7'h10 |=>
    fifo_space_t6 <= $past(fifo_space_t6 + 7'h04))
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count4: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 <  7'h20 |=>
    fifo_space_t6 <= $past(fifo_space_t6 + 7'h04))
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count5: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 <  7'h50 |=>
    fifo_space_t6 <= $past(fifo_space_t6 + 7'h04))
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_space_t6 <  7'h53 |=>
    fifo_space_t6 <= $past(fifo_space_t6 + 7'h04))
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count7: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54) & ~|num_bytes_t5_i |=>
    fifo_space_t6 == 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count7a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54)[*3] ##1
   (fifo_space_t6 == 7'h54) & ~|num_bytes_t5_i  & (wrap_wr_t6 == wrap_rd_t6) &
   (wr_byte_ptr_t6[6:0] == sva_rd_byte_ptr_t6) |=>
    fifo_space_t6 == 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");
  usva_fifo_space_count7c: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54)[*3] ##1
   (fifo_space_t6 == 7'h54) & (wrap_wr_t6 == wrap_rd_t6) &
   (wr_byte_ptr_t6[6:0] == sva_rd_byte_ptr_t6) |=>
    fifo_space_t6 <= 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count7d: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54)[*3] ##1
   (fifo_space_t6 == 7'h54) & (wrap_wr_t6 == wrap_rd_t6) &
   (wr_byte_ptr_t6[6:0] == sva_rd_byte_ptr_t6) ##1
   (fifo_space_t6 <= 7'h54) |=>
    fifo_space_t6 <= 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count7e: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54)[*3] ##1
   (wrap_wr_t6 == wrap_rd_t6) &
   (wr_byte_ptr_t6[6:0] == sva_rd_byte_ptr_t6) |=>
    fifo_space_t6 <= 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");

  usva_fifo_space_count7f: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   (fifo_space_t6 == 7'h54)[*3] ##1
   (wr_byte_ptr_t6[6:0] == sva_rd_byte_ptr_t6) |=>
    fifo_space_t6 <= 7'h54)
    `SVA_FATAL("Fifo space stays in legal range");

// FIFO OUTPUT INTERFACE
// ---------------------

// 1 byte fifo_data_o not X if qualifier is high.
  usva_fifo_data_o_not_unknown_one_byte: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_valid_o & (fifo_bytes_o[1:0] == 2'b00) |-> !$isunknown(fifo_data_o[7:0]))
    `SVA_FATAL("fifo_data_o must not be unknown when fifo_valid_o is set");

// 2 bytes fifo_data_o not X if qualifier is high.
  usva_fifo_data_o_not_unknown_two_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_valid_o & (fifo_bytes_o[1:0] == 2'b01) |-> !$isunknown(fifo_data_o[15:0]))
    `SVA_FATAL("fifo_data_o must not be unknown when fifo_valid_o is set");

// 3 bytes fifo_data_o not X if qualifier is high.
  usva_fifo_data_o_not_unknown_three_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_valid_o & (fifo_bytes_o[1:0] == 2'b10) |-> !$isunknown(fifo_data_o[23:0]))
    `SVA_FATAL("fifo_data_o must not be unknown when fifo_valid_o is set");

// 4 bytes fifo_data_o not X if qualifier is high.
  usva_fifo_data_o_not_unknown_four_bytes: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_valid_o & (fifo_bytes_o[1:0] == 2'b11) |-> !$isunknown(fifo_data_o[31:0]))
    `SVA_FATAL("fifo_data_o must not be unknown when fifo_valid_o is set");

// fifo_valid must not go low when fifo_ready is low.
  usva_fifo_valid_at_ready: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                              (fifo_valid_o & ~fifo_ready_i) |=> fifo_valid_o)
    `SVA_FATAL("fifo_valid_o must not go low when fifo_ready is low");

// fifo_bytes_o[1:0] Always = 3 unless
// fifo_flush_ack_o or
// next data is ovfl
// fifo_idle_req are high
// or async is output this or next cycle
// (multi cycle assertions)
  reg sva_fifo_bytes_o_3_unless_q;
  reg sva_fifo_bytes_o_eq_3_q;
  always @(posedge clk_gated or negedge po_reset_n)
   if (!po_reset_n)
     begin
       sva_fifo_bytes_o_3_unless_q <=  1'b1;
       sva_fifo_bytes_o_eq_3_q <=  1'b0;
     end
   else
     begin
       sva_fifo_bytes_o_3_unless_q <=  (~fifo_ready_i | ~fifo_valid_o |
                                                 fifo_flush_ack_o | sva_fifo_idle_req_q |
                                                 sva_ovfl_output | sva_async_output);
       sva_fifo_bytes_o_eq_3_q <=  (fifo_bytes_o[1:0] == 2'b11);
     end

  usva_fifo_bytes_o_3_cf: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    ~(sva_fifo_bytes_o_3_unless_q | sva_ovfl_output | sva_async_output | ~fifo_ready_i) |-> sva_fifo_bytes_o_eq_3_q)
    `SVA_FATAL("expecting fifo_bytes_o[1:0] == 3");

// fifo_idle_ack_o only goes high if fifo_idle_req was high the
// previous cycle or before.
  usva_core_at_idle_req_set: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    sva_fifo_idle_ack_o_1st |-> sva_fifo_idle_req_q)
    `SVA_FATAL("fifo_idle_ack_o high only goes high if fifo_idle_req");

  usva_intf_idle_req_repeat: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    fifo_idle_req_t2_i ##1 ~fifo_idle_req_t2_i |=> ~fifo_idle_req_t2_i)
    `SVA_FATAL("FIFO idle request is too close");

// fifo_idle_ack_o only goes high if fifo_valid is low, and
// fifo is really empty.
  wire [6:0] sva_fifo_depth_t6;
  assign sva_fifo_depth_t6 = (wrap_wr_t6 == wrap_rd_t6) ?
                                  (wr_byte_ptr_t6[6:0] - {rd_word_ptr_t6[4:0],2'b00}) :
                                  (wr_byte_ptr_t6[6:0] - {rd_word_ptr_t6[4:0],2'b00}) + CA53_ETM_MAIN_FIFO_DEPTH;

  usva_core_at_idle_valid_unset: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    sva_fifo_idle_ack_o_1st |-> ~fifo_valid_o & ((sva_fifo_depth_t6 == 7'd0) | (sva_fifo_depth_t6 == {2'b00, sva_num_bytes_t6})))
    `SVA_FATAL("fifo_idle_ack_o only goes high if fifo_valid_o low and fifo is empty or has only just been written to");

  usva_core_at_idle_valid_unset2a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    $rose(fifo_idle_ack_o) |-> ~fifo_valid_o)
    `SVA_FATAL("fifo_idle_ack_o only goes high if fifo_valid_o");

  usva_core_at_idle_valid_unset2b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    $rose(fifo_idle_ack_o) |-> ((sva_fifo_depth_t6 == 7'd0) | (sva_fifo_depth_t6 == {2'b00, sva_num_bytes_t6})))
    `SVA_FATAL("fifo_idle_ack_o only goes high if fifo is empty or has only just been written to");

  wire [7:0] sva_fifo_space_t6;
  assign sva_fifo_space_t6 = (wrap_wr_t6 == wrap_rd_t6) ?
                                  ({1'b0,CA53_ETM_MAIN_FIFO_DEPTH} + {1'b0,sva_rd_byte_ptr_t6} - {1'b0,wr_byte_ptr_t6[6:0]}):
                                  (                                  {1'b0,sva_rd_byte_ptr_t6} - {1'b0,wr_byte_ptr_t6[6:0]});

  // Prevent new flush before old one is finished
  usva_flush_gap: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    flush_state_t7 & ~flush_valid_t6 |=> ~flush_valid_t6)
    `SVA_FATAL("2nd flush started before first finished cleanly");
    
  // Fifo pointers must always match fifo_space calculations (also helps proofs)
  usva_fifo_space_track: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_fifo_space_t6             == fifo_space_t6) |
  (({sva_fifo_space_t6[6:2],2'b00} == fifo_space_t6) & write_align_valid_t6))
    `SVA_FATAL("Fifo Space out of sync with pointers");

  // Helper for usva_fifo_space_track
  usva_fifo_space_track_ind: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_fifo_space_t6             == fifo_space_t6) |=>
    (sva_fifo_space_t6             == fifo_space_t6) |
  (({sva_fifo_space_t6[6:2],2'b00} == fifo_space_t6) & write_align_valid_t6))
    `SVA_FATAL("Fifo Space out of sync with pointers");

  usva_space_align_pulse3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                     write_align_valid_t6[*2] |=> ~write_align_valid_t6)
    `SVA_FATAL("Must not see 3 back to back fifo align request");

  usva_space_ovfl_async: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                     valid_ovfl_req_t5 |=> ~valid_async_req_t5)
    `SVA_FATAL("Not expecting async request just after overflow request");
    
//--------------------------------------------------------------------------
// Module interface assumptions
//--------------------------------------------------------------------------
  reg       sva_ovfl_permitted;

  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_ovfl_permitted <= 1'b1;
    else
      sva_ovfl_permitted <= fifo_empty_o | (~ovfl_req_t2_i & sva_ovfl_permitted);

// Overflow must not repeat before next empty (for counting properties to ba valid)
  usva_intf_ovflw_repeat: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ~sva_ovfl_permitted |=> ~ovfl_req_t2_i)
    `SVA_FATAL("Unexpected overflow request received");

  usva_intf_ovflw_pulse: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_req_t2_i |-> ##1 ~ovfl_req_t2_i[*3])
    `SVA_FATAL("overflow request must be single cycle valid");

  usva_intf_bytes_in: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (num_bytes_t5_i < 5'd29))
    `SVA_FATAL("num_bytes_t5_i should less than 29");
// Write pointer blocked untill write_align_overflow_t6 done
  usva_intf_ovflw_data2: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    fifo_overflow_o |-> ##1 (num_bytes_t5_i == 0)[*3])
    `SVA_FATAL("Unexpected data recevied during FIFO in overflow");

// From case which might cause problems with overflow state
  usva_intf_ovflw_en: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_done_t6 |=> ~ovfl_done_t6)
    `SVA_FATAL("ovfl_done_t6 should be a pulse signal");

  usva_intf_ovflw_en_2: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (ovfl_state_t7 & ~ovfl_state_t6 & rd_data_t6_en) |-> ovfl_state_t6_en)
    `SVA_FATAL("ovfl_state_t6_en expecte to be asserted");

  usva_intf_ovfl_idle: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    fifo_idle_ack_t6 |-> ~(ovfl_pos_t6[7:2] == {rd_word_ptr_t6[5:0]}))
    `SVA_FATAL("ovfl_valid_t6 should be deasserted when fifo_idle_ack_t6 is asserted ");


  usva_overflow_missed: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (ovfl_valid_t6 & ~ovfl_state_t7) |-> ~rd_inc_t6_en)
    `SVA_FATAL("Expect rd_inc_t6_en to be low ");


  usva_overflow_missed_idle: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (ovfl_valid_t6 & ~ovfl_state_t7) |-> ~(idle_comitted_t6 & ~fifo_idle_ack_t6))
    `SVA_FATAL("Expect idle_comitted_t6 not asserted or fifo_idle_ack_t6 asserted ");


//--------------------------------------------------------------------------
// Internal logic requirements
//--------------------------------------------------------------------------
  usva_merge_bytes_cf: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    (|async_bytes_t6) |-> ((ovfl_bytes_t6 == 2'b00) | (async_bytes_t6 == ovfl_bytes_t6)))
    `SVA_FATAL("Merge bytes requirement not met ");

  usva_merge_data: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    (|async_data_t6 & (|ovfl_data_t6)) |-> (ovfl_data_t6 === async_data_t6))
    `SVA_FATAL("Merge data requirement not met ");

  usva_merge_data_seq1: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                                        (~async_valid_t6 & ~ ovfl_valid_t6) ##1
                                        ( async_valid_t6 & ~ ovfl_valid_t6) |=>
                                         ~ovfl_valid_t6 |
                                         async_state_t7 != CA53_ETM_FIFO_ST2_ASYNC_1)
    `SVA_FATAL("Async sequence started instead of overflow");

  // Corner case with new overflow request just as async about to start.
  usva_merge_data_seq2: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                                        (~async_valid_t6 & ~ovfl_valid_t6) ##1
                                        ( async_valid_t6 & ~ovfl_valid_t6) |=>
                                         ~ovfl_valid_t6 |
                                         (merged_data_t6 == ovfl_data_t6)[*2])
    `SVA_FATAL("Merge data requirement not met ");

// Pointer wrap must be followed by resolution in next cycle
  usva_fifo_depth: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (diff_wr_rd_t7 > 7'h60) |=> (diff_wr_rd_t7 < 7'h20))
    `SVA_ERROR("diff_wr_rd_t7 requirement not met ");

  usva_diff_masked: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
     (diff_wr_rd_t7 > 7'h7c) |=> (fifo_waiting_t6 | (diff_wr_rd_t7 < 7'h20)))
    `SVA_FATAL("Pointers mis-aligned, but not masked");

// Async must stay valid whilst being output
// If Async is not yet started, Overflow can be output and async discarded.
  usva_async_state: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (async_state_t7 != CA53_ETM_FIFO_ST2_NORMAL) |-> async_valid_t6)
    `SVA_FATAL("Async output state, but not at async point");

  usva_async_no_rd: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                               ((async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL) &
                                (async_valid_t6 &
                                 ~((ovfl_valid_t6 |ovfl_state_t7)) &
                                 (~|async_pos_t6[1:0] | (|async_pos_t6[1:0] )) &
                                 (rd_data_t6_en | ~fifo_valid_t7))) & rd_data_t6_en |=>
                               async_valid_t6)
    `SVA_FATAL("Expect async_valid_t6 be asserted");

  usva_async_no_inc: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL) &
                                        async_valid_t6 & ~ovfl_valid_t6 |->
                                       ~rd_inc_t6_en)
    `SVA_FATAL("Data read when Async ready to output");

  usva_flush_pipe: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                              (fifo_flush_req_i & ~fifo_idle_ack_t6)
                              |=>  &flush_delay_t6)
    `SVA_FATAL("flush_delay_t6 not equal to 4'b1111");

  usva_flush_no_flap: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                        valid_flush_req_t5 |=> ~valid_flush_req_t5[*5])
    `SVA_FATAL("Flush should not repeat within 5 cycles");
    
//--------------------------------------------------------------------------
// Simple Model of FIFO behaviour
//--------------------------------------------------------------------------

  reg [7:0] sva_bytes_present;

  reg [1:0] sva_overflow_detect_d;
  reg [1:0] sva_overflow_detect;
  reg       sva_overflow_event_q;
  reg [2:0] sva_async_detect;
  reg [2:0] sva_async_count;
  reg [3:0] sva_overflow_count;
  wire      sva_overflow_live = |sva_overflow_count  & (|sva_overflow_detect[1]);
  wire      sva_async_live    = |sva_async_count  & (|sva_async_detect[2:1]);
  wire      sva_async_start   = async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_1;
  wire [7:0] sva_bytes_output = {5'b00000,{3{fifo_valid_o & fifo_ready_i}} & ({1'b0,fifo_bytes_o} + 3'b001)};
  wire [7:0] sva_bytes_ready  = {5'b00000,{3{fifo_valid_o}} & ({1'b0,fifo_bytes_o} + 3'b001)};

  // Maximum delay counters for Async and Overflow packets (counting output cycles)
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n) begin
        sva_async_count    <= 3'b000;
        sva_overflow_count <= 4'b0000;
    end
    else begin
        sva_async_count    <= sva_async_live    ? (sva_async_count    + {2'b00,(fifo_valid_o & fifo_ready_i)})  : {1'b0,sva_async_start,sva_async_start};
        sva_overflow_count <= sva_overflow_live ? (sva_overflow_count + {3'b000,(fifo_valid_o & fifo_ready_i)}) : {ovfl_valid_t6,1'b0,1'b0,1'b0};
    end

  // Possible confusion about overflow being detected early based on specific data pattern.
  wire [7:0] sva_bytes_calc = sva_bytes_present +
                      {6'b000000,(sva_overflow_detect == 2'b01),(sva_overflow_detect == 2'b01) & sva_overflow_event_q & ~(sva_overflow_only & fifo_valid_o)} +
                      {4'b0000,{2{(sva_async_detect == 3'b001)}},2'b00} +
                      {3'b000,{5{~(fifo_all_overflow_t6 | fifo_overflow_t5 | (fifo_overflow_aligned_t5 & write_align_valid_t5))}} & num_bytes_t5_i} -
                           sva_bytes_output;
  // Force this calculation to no overflow, should keep proofs tractable
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_bytes_present <= 8'h10;
    else
      sva_bytes_present <= (sva_bytes_calc < 8'h69) ? sva_bytes_calc : 8'h10;


  //Start of async sequence might be mis-detected, so allow for any length of zero bytes. Final transition
  //depends on bit[31] being seen.
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_async_detect <= 3'b000;
    else
      case (sva_async_detect)
        3'b000: sva_async_detect <= sva_async_start ? 3'b100 : 3'b000;
        3'b001: sva_async_detect <= sva_async_start ? 3'b100 : 3'b000;
        3'b010: sva_async_detect <= (fifo_valid_o & fifo_ready_i) ?
                                    ((fifo_bytes_o == 2'b11) & (fifo_data_o[30:0] == 31'h00000000) ? {1'b0,~fifo_data_o[31],fifo_data_o[31]} : 3'b100)
                                    : 3'b010;
        3'b011: sva_async_detect <= (fifo_valid_o & fifo_ready_i) ? ((fifo_bytes_o == 2'b11) & (fifo_data_o == 32'h00000000) ? 3'b010 : 3'b100) : 3'b011;
        3'b100: sva_async_detect <= (fifo_valid_o & fifo_ready_i) ? ((fifo_bytes_o == 2'b11) & (fifo_data_o == 32'h00000000) ? 3'b011 : 3'b100) : 3'b100;
      endcase // case (sva_async_detect)


  always @(*)
    case (sva_overflow_detect)
      2'b00: sva_overflow_detect_d = ovfl_valid_t6 ? 2'b10 : 2'b00;
      2'b01: sva_overflow_detect_d = ovfl_valid_t6 ? 2'b10 : 2'b00;
      2'b10: sva_overflow_detect_d = (fifo_valid_o & fifo_ready_i & ~ovfl_state_t7) ? ((sva_overflow_event | sva_overflow_only) ? 2'b01 : 2'b10) : 2'b10;
    endcase // case (sva_overflow_detect)
    
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_overflow_detect <= 2'b00;
    else
      sva_overflow_detect <= sva_overflow_detect_d;

  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_overflow_event_q <= 1'b0;
    else
      sva_overflow_event_q <= sva_overflow_event;

// Overflow must be output once sequence starts
  usva_overflow_detect: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    $rose(&sva_overflow_count) |-> (sva_overflow_detect[1] == 1'b0))
    `SVA_FATAL("overflow sequence wrong");

  usva_overflow_state:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_state_t7 |-> ovfl_valid_t6)
    `SVA_FATAL("Expect ovfl_valid_t6 asserted once in overflow state");

  usva_overflow_no_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_state_t7 |-> ~valid_async_req_t5)
    `SVA_FATAL("Expect ovfl_valid_t6 asserted once in overflow state");
  
// Async must be output once sequence starts. Split into stages
  usva_async_detect: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    $rose(&sva_async_count) |-> (sva_async_detect[2:1] == 2'b00))
    `SVA_FATAL("Async sequence wrong");

  usva_async_start: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    sva_async_start |=> sva_async_live)
    `SVA_FATAL("Async sequence wrong, sva_async_live expect to be asserted");

  usva_data_wrap: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    sva_bytes_present > 8'h03)
    `SVA_FATAL("Expect sva_bytes_present > 8'h03");

  usva_data_wrap_2: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    sva_bytes_present < 8'h69)    `SVA_FATAL("Expect sva_bytes_present < 8'h69");
  // Conditions where pointers are not aligned
  usva_data_wrap_add: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (sva_bytes_present + fifo_space_t6 - sva_bytes_ready) != 8'h64 |->
                                        flush_state_t6        |
                                        flush_state_t7        |
                                        $past(flush_state_t7) |
                                        (fifo_idle_ack_t5 & ~fifo_idle_ack_t6) |
                                        sva_overflow_event_q  | 
                                        ~&async_pos_t6        |
                                        ~&ovfl_pos_t6         |
                                        (|sva_async_detect)   |
                                        (|sva_overflow_detect))
    `SVA_ERROR("Data in fifo does not match fifo space tracking");

  reg       sva_state_normal_t8;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_state_normal_t8 <= 1'b0;
    else
      sva_state_normal_t8 <= (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL) & ~ovfl_state_t7;

  reg [1:0] sva_async_state_ready;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_async_state_ready <= 1'b0;
    else if(~fifo_valid_o | fifo_ready_i)
      sva_async_state_ready <= async_state_t7;

// Normal data not yet clocked out
  wire [2:0] sva_out_bytes   = {3{fifo_valid_o}} & ({1'b0,fifo_bytes_o} + 3'b001);
// Only count both if aligned to different words

  usva_intf_ovfl_no_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                     ovfl_req_t2_i |-> ~async_req_t4_i);

  usva_pc4_intf_ovfl_seq1b:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                      ovfl_valid_t6 & fifo_ready_i ##1 fifo_ready_i[*2] |=>
                                         ~ovfl_valid_t6[*5])
    `SVA_ERROR("Fifo state error");
  usva_pc5_intf_ovfl_seq1b:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                      ovfl_valid_t6 ##1 ~ovfl_valid_t6 |=>
                                         ~ovfl_valid_t6)
    `SVA_ERROR("Fifo state error");
  // Proven
  usva_pc7_intf_ovfl_seq1b1:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                               (~fifo_valid_t6 & ~async_valid_t6)[*3] ##1 
                                                (ovfl_valid_t6 & ~fifo_valid_t7 & ~ovfl_state_t7) |=> 
                                                ovfl_data_valid_t6)
    `SVA_ERROR("Fifo state error");
  // Proven
  usva_pc7_intf_ovfl_seq1b2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                               ~fifo_valid_t6[*3] ##1 
                                                (ovfl_valid_t6 & ~fifo_valid_t7 & ~ovfl_state_t7 &
                                                 (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL)
                                                 ) |=> 
                                                ovfl_state_t7)
    `SVA_ERROR("Fifo state error");
  // Proven
  usva_pc7_intf_ovfl_seq1b3:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                               ~fifo_valid_t6[*3] ##1 (ovfl_valid_t6 & ~fifo_valid_t7 & ovfl_state_t7) |=> 
                                                ~ovfl_state_t7)
    `SVA_ERROR("Fifo state error");
    
  usva_pointer_wrap: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       (sva_bytes_present - sva_fifo_depth_t6) != 8'h15)
    `SVA_ERROR("Fifo pointer error");

  usva_pointer_wrap2: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                     (sva_bytes_present == 8'h2E) |->
                                     (sva_fifo_depth_t6 != 8'h19))
    `SVA_ERROR("Fifo pointer error");

  usva_ovfl_seq_deadlock: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            $past(fifo_waiting_t6) & ~fifo_idle_ack_t6 &
                                            ~&{async_pos_t6,ovfl_pos_t6} ##1
                                            (fifo_ready_i & ~valid_async_req_t5 & ~valid_ovfl_req_t5)[*5] |->
                                            (fifo_valid_o |
                                             (fifo_valid_t6 & rd_data_t6_en) |
                                             ~$past(fifo_waiting_t6) |
                                             &{async_pos_t6,ovfl_pos_t6}))
    `SVA_FATAL("Deadlock - fifo not draining");

  usva_ovfl_seq1a:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (~ovfl_state_t7) &
                                      ovfl_valid_t6 & async_valid_t6 & fifo_ready_i |=>
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (ovfl_state_t7))
    `SVA_FATAL("Overflow takes priority over async if async has not started");

  usva_ovfl_seq1b1:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       fifo_valid_t7 &
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (~ovfl_state_t7) & 
                                      ovfl_valid_t6 & async_valid_t6 & ~fifo_ready_i |=>
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (~ovfl_state_t7))
    `SVA_FATAL("Overflow takes priority over async if async has not started");

  usva_ovfl_seq1c:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (ovfl_state_t7) &
                                      ovfl_valid_t6 & async_valid_t6 & fifo_ready_i |=>
                                     (async_state_t7 ==CA53_ETM_FIFO_ST2_NORMAL) &
                                     (~ovfl_state_t7))
    `SVA_FATAL("Overflow takes priority over async if async has not started");

  usva_ovfl_seq2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                     (async_state_t7 != CA53_ETM_FIFO_ST2_ASYNC_3) &
                                     (async_state_t7 != CA53_ETM_FIFO_ST2_NORMAL)  & ovfl_valid_t6 |-> ~async_valid_t6)
    `SVA_FATAL("Async takes priority over overflow if async has already started");

//--------------------------------------------------------------------------
// Overflow/Async sequence at interface level
//--------------------------------------------------------------------------
localparam SVA_CA53_ETM_ST_EMPTY      =2'b00;
localparam SVA_CA53_ETM_ST_ASYNC      =2'b01;
localparam SVA_CA53_ETM_ST_DATA       =2'b10;
localparam SVA_CA53_ETM_ST_OVFL       =2'b11;
    
reg [1:0] sva_fifo_state_q;
reg [1:0] sva_fifo_state;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_fifo_state_q <= 2'b00;
    else
      sva_fifo_state_q <= sva_fifo_state;
    
    always @*
      case (sva_fifo_state_q)
        SVA_CA53_ETM_ST_EMPTY: sva_fifo_state =  async_req_t4_i ? SVA_CA53_ETM_ST_ASYNC : SVA_CA53_ETM_ST_EMPTY;
        SVA_CA53_ETM_ST_ASYNC: sva_fifo_state =  (fifo_valid_o & (fifo_data_o[31:0] == 32'h80000000)) ? SVA_CA53_ETM_ST_DATA : SVA_CA53_ETM_ST_ASYNC;
        SVA_CA53_ETM_ST_DATA: sva_fifo_state =  ovfl_req_retime_t3 ? SVA_CA53_ETM_ST_OVFL : SVA_CA53_ETM_ST_DATA;
        SVA_CA53_ETM_ST_OVFL: sva_fifo_state =  (&ovfl_pos_t6 & fifo_empty_o)  ? SVA_CA53_ETM_ST_EMPTY : SVA_CA53_ETM_ST_OVFL;
        default : sva_fifo_state = 2'bxx;
      endcase // case SVA_CA53_ETM_ST_OFVL
            

 // Between indicating empty and getting async request, only overflow packet can be output
 // Empty does not block for ready, so valid could remain high
  usva_fifo_state_empty:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY |->
                                            ~fifo_valid_o | sva_overflow_event | sva_overflow_only)
    `SVA_ERROR("Fifo generating data, but should be empty");
 // Once async is requested, expect only async packet or overflow (from before)
  usva_fifo_state_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_ASYNC & fifo_valid_o|->
                                            sva_async_output | sva_overflow_event | sva_overflow_only)
    `SVA_ERROR("First data after empty must be ASYNC");
    // Between entering overflow and empty, nothing should come from trace gen.
  usva_fifo_state_ovfl:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_OVFL |->
                                            ~async_req_t4_i)
    `SVA_ERROR("Async request before fifo recovered from overflow");

   // Helper condition for usva_fifo_state_async
  usva_fifo_state_async_ex1:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_ASYNC & fifo_valid_o &
                                            ~rd_inc_t6_en |->
                                                ($past(async_valid_t6) &
                                                sva_async_output) | 
                                                ((sva_overflow_event | sva_overflow_only) & ~$past(fifo_ready_i)))
    `SVA_ERROR("Fifo advance before ASYNC traced");
    
  usva_fifo_state_async_ex2 :  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY |-> ~(|num_bytes_t5_i))
    `SVA_ERROR("Fifo data input before first ASYNC");
// Inductive version of usva_fifo_state_async_ex2
  usva_fifo_state_async_ex2_seq:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY & ~(|num_bytes_t5_i) & ~async_req_t4_i |=>
                                            async_req_t4_i | ~(|num_bytes_t5_i))
    `SVA_ERROR("Fifo data input before first ASYNC");

  usva_fifo_state_async_ex3:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY |-> ~ovfl_req_t2_i)
    `SVA_ERROR("Overflow request between overflow and async");

  usva_fifo_state_async_ex4:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                            sva_fifo_state_q == SVA_CA53_ETM_ST_EMPTY |-> merged_bytes_t6 != 2'b11)
    `SVA_ERROR("Potential trace between overflow and async");
    
  usva_rd_ptr_valid: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (rd_word_ptr_t6[4:0] < 5'b10101))
    `SVA_FATAL("Expect rd_word_ptr_t6[4:0] < 5'b10101");

  usva_space_valid: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (fifo_space_t6 < 7'h55))
    `SVA_FATAL("Expect fifo_space_t6 < h55");

  usva_space_valid_ind: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (fifo_space_t6 < 7'h55) |=> (fifo_space_t6 < 7'h55))
    `SVA_FATAL("Expect fifo_space_t6 < h55");

  usva_space_ovfl_valid: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_valid_t6 |-> 
      (fifo_space_t6 == 7'h50) |
      (fifo_space_t6 == 7'h54))
    `SVA_FATAL("Expect fifo to be 4 bytes from empty when overflow starts");
    
  usva_space_ovfl_wrap: assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    ovfl_valid_t6 |-> wrap_rd_t6 == wrap_wr_t7 | wr_byte_ptr_t6[6:0] == 7'h00)
    `SVA_FATAL("Expect pointers aligned when overflow is output");

//Illegal overflow/async sequences
  usva_states_from_normal:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (~ovfl_state_t7) & (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL) |=>
    (~ovfl_state_t7) | (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL))
    `SVA_FATAL(" ovfl_state_t7 and async_state_t7 relationship not met");

  usva_states_from_ovfl:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (ovfl_state_t7) & (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL) |=>
   ~(async_state_t7 != CA53_ETM_FIFO_ST2_NORMAL))
    `SVA_FATAL(" ovfl_state_t7 and async_state_t7 relationship not met");

  usva_states_from_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (~ovfl_state_t7) & (async_state_t7 != CA53_ETM_FIFO_ST2_NORMAL) |=>
    (~ovfl_state_t7))
    `SVA_FATAL(" ovfl_state_t7 and async_state_t7 relationship not met");

    // Overflow pointer should be reset once passed.
  usva_ovfl_missed:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       ovfl_valid_t6 & rd_inc_t6_en |=>
                                       &ovfl_pos_t6)
    `SVA_FATAL("Read past overflow position, but overflow no reset");
  usva_ovfl_missed2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       ovfl_valid_t6 & rd_inc_t6_en & flush_passed_t7 |=>
                                       &ovfl_pos_t6)
    `SVA_FATAL("Read past overflow position, but overflow no reset");
    // Async pointer should be reset once passed.
  usva_async_missed:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                       async_valid_t6 & rd_inc_t6_en |=>
                                       &async_pos_t6)
    `SVA_FATAL("Read past overflow position, but overflow no reset");
    
    // Check term in rd_inc_t6_en is necessary
  usva_idle_rd_inc_1:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (idle_comitted_t6 & ~fifo_idle_ack_t6 & ~ovfl_valid_t6 & async_valid_t6) |->
                                       (diff_wr_rd_t7 < 7'h04))
    `SVA_ERROR("Read at idle request condition seen");
    // Check term in rd_inc_t6_en is necessary
  usva_idle_rd_inc_2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (idle_comitted_t6 & ~fifo_idle_ack_t6 & ovfl_valid_t6 & ~async_valid_t6) |->
                                       (diff_wr_rd_t7 < 7'h04))
    `SVA_ERROR("Read at idle request condition seen");

    // Check term in rd_inc_t6_en is necessary (both)
  usva_idle_rd_inc_3:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (idle_comitted_t6 & ~fifo_idle_ack_t6 |->  ~ovfl_valid_t6 & ~async_valid_t6))
    `SVA_ERROR("Read at idle request condition seen");
      
    // State space termination check
  usva_idle_advance:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                        (idle_comitted_t6 & ~fifo_idle_ack_t6) |->
                                        ~(ovfl_valid_t6 | async_valid_t6))
    `SVA_ERROR("Committed idle, async may be lost");

  // Flush and async will align async to rounded up write pointer
  usva_async_pos_flush_wr:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                           wr_byte_ptr_t6[6:0] > 7'h50 &
                                           flush_idle_write_align_valid_t5 &
                                           valid_async_req_t5
                                           |=> async_pos_t6[6:0] == 7'h00)
    `SVA_ERROR("Async calculation diverged");
    
  // Write-align only needed when write pointer is not aligned.
  usva_write_align_valid_offset:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    write_align_valid_t5 |-> wr_byte_ptr_t6[1:0] != 2'b00)
    `SVA_ERROR("Write pointer out of sync");
    
  // Async only rounds up if not already word-aligned
  usva_async_pos_flush_0:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                           wr_byte_ptr_t6[1:0] == 2'b00 &
                                           valid_async_req_t5
                                           |=> async_pos_t6[6:0] == $past(wr_byte_ptr_t6[6:0]))
    `SVA_ERROR("Async calculation diverged");

  // Simplify end of overflow sequence
  usva_ovfl_end_space:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                                     ovfl_state_t7 |-> fifo_space_final_t6 >= 8'h50);
  usva_ovfl_end_done:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                                     ovfl_state_t7 & rd_data_t6_en |=> async_pos_t6 == 8'hFF & ovfl_pos_t6[7:0]  == 8'hFF);
    
                                        
//--------------------------------------------------------------------------
// Cover Properties to check for possible deadcode
//--------------------------------------------------------------------------
  cover_overflow: cover property (@(posedge clk_gated) disable iff(!po_reset_n)
                                (ovfl_pos_t6[7:2] == rd_word_ptr_t6[5:0])
                                & (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL));

  usva_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                 async_req_t5 & (async_pos_t6[7:0] == 8'hFF) |-> ~ovfl_valid_t6)
    `SVA_ERROR("Async request can occur with overflow");

  usva_ovfl_valid:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                 ovfl_pos_t6[7:0] == 8'hFF |-> ~ovfl_valid_t6)
    `SVA_ERROR("Overflow detected when not being tracked");

  usva_ovfl_valid2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                                 ovfl_pos_t6[7:0] != 8'hFF |-> ~async_req_t4_i)
    `SVA_ERROR("Overflow detected when not being tracked");

  usva_async_state2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
    (async_pos_t6[7:0] == 8'hFF) |-> (async_state_t7 == CA53_ETM_FIFO_ST2_NORMAL))
    `SVA_ERROR("Async state but not tracking async");

  cover_async1: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
      async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_1 & ~rd_data_t6_en  |-> fifo_valid_t7)
    `SVA_ERROR("In async state, but no output data");
  cover_async2: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
      async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_2 & ~rd_data_t6_en  |-> fifo_valid_t7)
    `SVA_ERROR("In async state, but no output data");
  cover_async3: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
      async_state_t7[1:0] == CA53_ETM_FIFO_ST2_ASYNC_3 & ~rd_data_t6_en  |-> fifo_valid_t7)
    `SVA_ERROR("In async state, but no output data");

  overflow_align_overflow: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                                   (valid_ovfl_req_t5 | valid_async_req_t5) |-> ~fifo_overflow_t6)
    `SVA_ERROR("Overflow request during overflow-align sequence");
    // Cover wr_row_ptr_inc_t5
  align_wr_row: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    (write_align_valid_t5 |-> (wr_col_plus_t5[5:0] != 6'b000000)))
    `SVA_ERROR("write_align_valid_t5 should not happen when new column is zero");

  // Async is suppressed in overflow state, must get new one
  reg   sva_async_suppressed;
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_async_suppressed <= 1'b0;
    else
      sva_async_suppressed <= (fifo_overflow_t6 & async_req_t5) | (sva_async_suppressed & ~async_req_t5 & ~fifo_idle_req_t2_i);
    
  async_not_lost: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    sva_async_suppressed & ~async_req_t5 |-> ~|num_bytes_t5_i)
    `SVA_FATAL("Missing ASYNC before new data");
    
  flush_not_lost: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    flush_pos_t6[7:2] == {rd_word_ptr_t6[5:0]} |=>
   (flush_pos_t6[7:2] == {rd_word_ptr_t6[5:0]}) | flush_pos_t6 == 8'hFF)
    `SVA_ERROR("Flush tracking not reset");
    
  flush_not_ack: assert property (@(posedge clk_gated) disable iff(!po_reset_n)
   flush_state_t7 & ~fifo_flush_ack_o |=> flush_state_t7)
    `SVA_ERROR("Flush not acknowledged");
    
//--------------------------------------------------------------------------
// Required at module block level, to confirm at unit level
//--------------------------------------------------------------------------
  usva_intf_ovfl_stop:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           ovfl_req_t2_i |=> ~|num_bytes_t5_i ##1 ~|num_bytes_t5_i)
    `SVA_FATAL(" unexpected data received while ovfl_req_t2_i is asserted");

  usva_intf_ovfl_check:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           fifo_overflow_aligned_t5 |-> &ovfl_pos_t6)
    `SVA_FATAL(" interface overflow check failed");

  usva_intf_ovfl_check2:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           |num_bytes_t5_i |-> &ovfl_pos_t6)
    `SVA_FATAL(" interface overflow check2 failed");

  usva_intf_ovfl_check3:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           ~&ovfl_pos_t6 |=> ~|num_bytes_t5_i)
    `SVA_FATAL(" interface overflow check3 failed");
// Overflow state must be resolved before new data
  usva_intf_ovfl_check4:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           ovfl_state_t7 & ~fifo_empty_o |=> ~|num_bytes_t5_i[*2])
    `SVA_FATAL(" interface overflow check4 failed");
// Too much data output if async request during overflow output
  usva_intf_ovfl_async:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           ovfl_req_t2_i |=> ~async_req_t4_i[*2])
    `SVA_FATAL(" Unexpect Async request received while ovfl_req_t2_i is asserted");

  usva_intf_ovfl_req_pos:  assert property  (@(posedge clk_gated) disable iff(!po_reset_n)
                           ovfl_req_retime_t3 |-> ovfl_pos_t6[7:0] == 8'hFF)
    `SVA_FATAL(" Unexpect ovfl_pos_t6 value when ovfl_req_retime_t3 is asserted");
//--------------------------------------------------------------------------
// X state or reachable state check
//--------------------------------------------------------------------------
  usva_rd_col_ptr_t6_reachable_check:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                    !(rd_col_ptr_t6[2:0] == 3'b111))
    `SVA_FATAL("Unreachable state for rd_col_ptr_t6 reached");

  usva_rd_col_ptr_t6_unknown_check: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                    !$isunknown(rd_col_ptr_t6))
    `SVA_FATAL("rd_col_ptr_t6 is X");

  usva_rd_row_ptr_t6_reachable_check:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                    !(rd_row_ptr_t6[1:0] == 2'b11))
    `SVA_FATAL("Unreachable state for rd_row_ptr_t6 reached");

  usva_wr_row_ptr_wrap_t7_reachable_check:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
                    !(wr_row_ptr_wrap_t7[1:0] == 2'b11))
    `SVA_FATAL("Unreachable state for rd_row_ptr_t6 reached");

  generate
    for (i = 0; i < 28; i = i + 1) begin : usva_fifo_row_wr_ptr
      assert property (@(posedge clk_gated) disable iff(!po_reset_n)
              !(fifo_row_wr_ptr_t6[i] == 2'b11))
      `SVA_FATAL("Unreachable state for fifo_row_wr_ptr_t6 reached");
     end
  endgenerate

 //Pre-rot unreachable values
  usva_rotate_reachable_check:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
   |prerot_t6[4:3] |-> ~prerot_t6[5])
      `SVA_FATAL("Unreachable state for prerot_t6 reached");
    
  usva_wr_col_reachable_check:  assert property (@(posedge clk_gated) disable iff(!po_reset_n)
    (wr_col_plus_t5[5:0] != 6'b111000))
      `SVA_FATAL("Unreachable state for wr_col_plus_t5 reached");
                                                 
`endif

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/

