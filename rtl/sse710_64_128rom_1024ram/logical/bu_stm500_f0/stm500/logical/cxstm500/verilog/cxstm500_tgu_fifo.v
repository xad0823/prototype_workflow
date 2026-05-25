//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      RTL design for STM TGU FIFO buffers
//-----------------------------------------------------------------------------

module cxstm500_tgu_fifo #(
  parameter DATA_WIDTH = 32,
  parameter FIFO_DEPTH = 4
  )
  (
  // Inputs
  input wire                   clk_gated,        // gated clock
  input wire                   STMRESETn,        // asynchronous reset
  input wire                   fifoin_valid_i,   // fifo input valid
  input wire [DATA_WIDTH-1:0]  fifoin_data_i,    // fifo inpud data
  input wire                   fifoout_ready_i,  // fifo output ready

  // Outputs
  output wire                  fifoin_ready_o,   // fifo input ready
  output wire                  fifoout_valid_o,  // fifo output valid
  output wire [DATA_WIDTH-1:0] fifoout_data_o    // fifo output data
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam ARRAY_DEPTH = FIFO_DEPTH - 1;

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire [ARRAY_DEPTH:0]       nxt_array_valid;
  wire [ARRAY_DEPTH:0]       array_read;
  wire [ARRAY_DEPTH:0]       array_write;
  wire                       fifoin_ready;
  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg  [ARRAY_DEPTH:0]       array_valid_reg;
  reg  [DATA_WIDTH-1:0]      array_data_reg[ARRAY_DEPTH:0];

  genvar i;

  // -----------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  // -----------------------------------------------------------------------------

  // -----------------------------------------------------------------------------
  // Data array
  // -----------------------------------------------------------------------------

  // Array element ARRAY_DEPTH-1 is the input  to the FIFO
  // Array element 0             is the output of the FIFO
  // Data values are shifted from higher numbered elements to lower numbered
  //  elements


  // Mark the array elements that will be read from by the next element
  // Asserted when the next element is empty or will be read from
  // Element 0 is a special case which is read from by the output interface

  // Mark the array elements that will be written to by the previous element
  // Asserted when the previous element contains valid data, and the current
  //  element is empty or will be read from
  // Element ARRAY_DEPTH is a special case which is written to by the input
  //  interface

  // Array element valid next value
  // - set when there is a write
  // - cleared when there is a read without a write
  // - holds the previous value at all other times
  // Data valid registers

  // Data array registers, only enabled when they are written to
  // Element ARRAY_DEPTH is a special case which takes its value from the input
  // interface

  generate
    for (i=0; i <= ARRAY_DEPTH; i=i+1)
    begin : gen_fifo_entry
      case (i)
        0 :
        begin
          assign array_read[0]      = fifoout_ready_i;
          assign array_write[0]     = array_valid_reg[1] & (~array_valid_reg[0] | array_read[0]);
          assign nxt_array_valid[0] = array_write[0] ? 1'b1 :
                                     (array_read[0]  ? 1'b0 : array_valid_reg[0]);

          always @(posedge clk_gated or negedge STMRESETn)
          begin
            if (!STMRESETn)
              array_valid_reg[0] <= 1'b0;
            else
              array_valid_reg[0] <= nxt_array_valid[0];
          end
          always @(posedge clk_gated)
            if (array_write[0])
            array_data_reg[0] <= array_data_reg[1];
        end
        ARRAY_DEPTH :
        begin
          assign array_read[ARRAY_DEPTH]      = (~array_valid_reg[ARRAY_DEPTH-1] | array_read[ARRAY_DEPTH-1]);
          assign array_write[ARRAY_DEPTH]     = fifoin_valid_i;
          assign nxt_array_valid[ARRAY_DEPTH] = array_write[ARRAY_DEPTH] ? 1'b1 :
                                               (array_read[ARRAY_DEPTH]  ? 1'b0 : array_valid_reg[ARRAY_DEPTH]);

          always @(posedge clk_gated or negedge STMRESETn)
          begin
            if (!STMRESETn)
              array_valid_reg[ARRAY_DEPTH] <= 1'b0;
            else
              array_valid_reg[ARRAY_DEPTH] <= nxt_array_valid[ARRAY_DEPTH];
          end
          always @(posedge clk_gated)
            if (array_write[ARRAY_DEPTH])
              array_data_reg[ARRAY_DEPTH] <= fifoin_data_i;
        end
        default :
        begin
          assign array_read[i]      = (~array_valid_reg[i-1] | array_read[i-1]);
          assign array_write[i]     = array_valid_reg[i+1] & (~array_valid_reg[i] | array_read[i]);
          assign nxt_array_valid[i] = array_write[i] ? 1'b1 :
                                     (array_read[i]  ? 1'b0 : array_valid_reg[i]);

          always @(posedge clk_gated or negedge STMRESETn)
          begin
            if (!STMRESETn)
              array_valid_reg[i] <= 1'b0;
            else
              array_valid_reg[i] <= nxt_array_valid[i];
          end
          always @(posedge clk_gated)
            if (array_write[i])
            array_data_reg[i] <= array_data_reg[i+1];
        end
      endcase
    end
  endgenerate

  assign fifoin_ready = ~(array_valid_reg == {FIFO_DEPTH{1'b1}}) | fifoout_ready_i;

  // -----------------------------------------------------------------------------
  // Output assignment
  // -----------------------------------------------------------------------------

  // FIFO is not ready to accept new write when full and there is no read from output
  assign fifoin_ready_o  = fifoin_ready;

  // The output interface is driven directly by the last array element
  assign fifoout_valid_o                = array_valid_reg[0];
  assign fifoout_data_o[DATA_WIDTH-1:0] = array_data_reg[0];

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"No reading from empty fifo")
    ovl_never_fifo_read_when_empty (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .test_expr (~fifoout_valid_o & fifoout_ready_i)
    );

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"FIFO should be ready to accept new data after FIFO read and no new data")
    ovl_next_fifo_ready_after_read (
      .clk         (clk_gated),
      .reset_n     (STMRESETn),
      .start_event (fifoout_valid_o & fifoout_ready_i & ~fifoin_valid_i),
      .test_expr   (fifoin_ready_o)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, FIFO_DEPTH, `OVL_ASSERT, "array_write is X")
    ovl_never_unknown_fifo_array_write (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (array_write[ARRAY_DEPTH:0])
    );

`endif
endmodule

