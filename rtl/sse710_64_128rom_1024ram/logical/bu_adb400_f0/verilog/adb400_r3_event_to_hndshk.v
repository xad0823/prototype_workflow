//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-09 14:22:09 +0000 (Tue, 09 Feb 2016)
// Revision : 206584
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_event_to_hndshk.v
//-----------------------------------------------------------------------------
// Purpose : Count non-backpressurable events and handshake them downstream when possible
//-----------------------------------------------------------------------------

module adb400_r3_event_to_hndshk
  #(parameter
      EVENT_COUNT_MAX = 511
  )
  (
    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,

    // The upstream event
    input  wire                   src_event_i,

    // The downstream handshake
    output wire                   dst_valid_o,
    input  wire                   dst_ready_i
  );

`include "adb400_r3_functions.v"

  localparam                         EVENT_COUNT_WIDTH = clogb2(EVENT_COUNT_MAX);
  localparam [EVENT_COUNT_WIDTH-1:0] EVENT_COUNT_1     = {{(EVENT_COUNT_WIDTH-1){1'b0}},1'b1};

  genvar i, j;

  //--------------------------------------------------------------------
  // Count the number of events that have occurred upstream but not downstream
  //--------------------------------------------------------------------

  reg                           dst_valid_q;
  reg  [EVENT_COUNT_WIDTH-1:0]  event_count_q;
  wire                          event_count_upd_en = (src_event_i | dst_ready_i);
  wire                          event_count_ovrflw;
  wire [EVENT_COUNT_WIDTH-1:0]  event_count_p1;
// ACS_off start UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING constant is written as 1'b1 to guide synthesis to an incrementer/decrementer
  assign {event_count_ovrflw,event_count_p1}   = (event_count_q + 1'b1);
  wire [EVENT_COUNT_WIDTH-1:0]  event_count_m1 = (event_count_q - 1'b1);
// ACS_off end UNEQUAL_WIDTH_OP_ARGS CONSTANT_MSB_PADDING
  wire                          event_count_eo = (event_count_q == EVENT_COUNT_1);
  reg  [EVENT_COUNT_WIDTH-1:0]  event_count_nxt;
  reg                           dst_valid_nxt;
  always @*
    begin : p_event_count_nxt
      case ({src_event_i,dst_valid_q,dst_ready_i})
        3'b000,
        3'b001,
        3'b010,
        3'b101,
        3'b111:
          begin
            event_count_nxt = event_count_q;
            dst_valid_nxt   = dst_valid_q;
          end
        3'b011:
          begin
            event_count_nxt = event_count_m1;
            // NOTE: this would not work for event_count==0, but there will not
            //       be a valid in those circumstances, so this is safe.
            dst_valid_nxt   = ~event_count_eo;
          end
        3'b100,
        3'b110:
          begin
            event_count_nxt = event_count_p1;
            dst_valid_nxt = 1'b1;
          end
// ACS_off UNREACHABLE_DEFAULT_BRANCH Unreachable, present for X-prop detection
        default:
// ACS_off UNREACHABLE_DEFAULT_STATEMENT Unreachable, present for X-prop detection
          begin
            event_count_nxt = {EVENT_COUNT_WIDTH{1'bx}};
            dst_valid_nxt = 1'bx;
          end
      endcase
    end


  always @(posedge aclk or negedge aresetn)
    begin : p_event_count_q
      if (! aresetn)
        begin
          event_count_q <= {EVENT_COUNT_WIDTH{1'b0}};
          dst_valid_q   <= 1'b0;
        end
      else if (event_count_upd_en)
        begin
          event_count_q <= event_count_nxt;
          dst_valid_q   <= dst_valid_nxt;
        end
    end
  
  assign dst_valid_o = (dst_valid_q | src_event_i);

endmodule
