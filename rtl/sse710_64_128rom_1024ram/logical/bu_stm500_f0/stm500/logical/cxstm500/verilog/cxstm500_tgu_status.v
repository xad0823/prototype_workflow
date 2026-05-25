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
//      RTL design for STM TGU status logic
//-----------------------------------------------------------------------------

module cxstm500_tgu_status #(
  parameter FIFO_DEPTH = 4
  )
  (
  // Inputs
  input wire         clk_gated,          // gated clock
  input wire         STMRESETn,          // asynchronous reset
  input wire         fifoin_valid_i,     // fifo input valid
  input wire         fifoin_ready_i,     // fifo input ready
  input wire         fifoout_valid_i,    // fifo output valid
  input wire         fifoout_ready_i,    // fifo output ready
  input wire         tgu_valid_i,        // TGU i/f is busy
  input wire         tracegen_busy_i,    // Tracegen is busy
  input wire         atb_busy_i,         // ATB or Packer busy

  // Outputs
  output wire        tgu_busy_o,         // TGU busy
  output wire [1:0]  tgu_fifo_level_o,   // fifo level: 00 < 25%, 01 < 50%, 10 < 75%, 11 >75%
  output wire        tgu_fifo_empty_o,   // fifo empty
  output wire        tgu_fifo_full_o     // fifo full
  );

  //-----------------------------------------------------------------------------
  // Constant Functions
  //-----------------------------------------------------------------------------
  function integer cxstm500_log2 (input integer depth);
    integer i;
    begin
      cxstm500_log2 = 32'h00000000; // Initialisation
      for(i = depth; i > 1; i = i >> 1)
        cxstm500_log2 = cxstm500_log2 + 1;
    end
  endfunction

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam FIFO_LEVEL_WIDTH = cxstm500_log2(FIFO_DEPTH) + 1;

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                         fifo_level_we;
  wire                         fifo_write;
  wire                         fifo_read;
  wire                         tgu_busy;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg  [FIFO_LEVEL_WIDTH-1:0]  fifo_level_reg;
  reg  [FIFO_LEVEL_WIDTH-1:0]  nxt_fifo_level;

  // -----------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  // -----------------------------------------------------------------------------

  // FIFO level is updated on each
  // 1. fifo write
  // 2. fifo read
  assign fifo_write    = fifoin_valid_i  & fifoin_ready_i;
  assign fifo_read     = fifoout_valid_i & fifoout_ready_i;
  assign fifo_level_we = fifo_write | fifo_read;

  always @*
  begin
    case ({fifo_write, fifo_read})
      2'b00:   nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0] =  fifo_level_reg[FIFO_LEVEL_WIDTH-1:0];
      2'b01:   nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0] = (fifo_level_reg[FIFO_LEVEL_WIDTH-1:0] - {{(FIFO_LEVEL_WIDTH-1){1'b0}}, 1'b1});
      2'b10:   nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0] = (fifo_level_reg[FIFO_LEVEL_WIDTH-1:0] + {{(FIFO_LEVEL_WIDTH-1){1'b0}}, 1'b1});
      2'b11:   nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0] =  fifo_level_reg[FIFO_LEVEL_WIDTH-1:0];
      // unreachable, X propagation only
      // VCS coverage off
      default: nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0] = {FIFO_LEVEL_WIDTH{1'bx}};
      // VCS coverage on
    endcase
  end

  always @(posedge clk_gated or negedge STMRESETn)
  begin
    if (!STMRESETn)
      fifo_level_reg[FIFO_LEVEL_WIDTH-1:0] <= {FIFO_LEVEL_WIDTH{1'b0}};
    else if(fifo_level_we)
      fifo_level_reg[FIFO_LEVEL_WIDTH-1:0] <= nxt_fifo_level[FIFO_LEVEL_WIDTH-1:0];
  end

  // TGU is busy when:
  // - TGU i/f is busy
  // - tracegen is busy
  // - ATB is busy
  // - there's data in FIFO
  assign tgu_busy = tgu_valid_i | tracegen_busy_i | atb_busy_i | (|(fifo_level_reg[FIFO_LEVEL_WIDTH-1:0]));

  // -----------------------------------------------------------------------------
  // Output assignment
  // -----------------------------------------------------------------------------
  // TGU fifo level status output is top two bits of fifo_level_reg
  // Status encoding is:
  // 2'b00 fifo < 25% full
  // 2'b01 fifo < 50% full
  // 2'b10 fifo < 75% full
  // 2'b11 fifo > 75% full
  assign tgu_fifo_level_o[1:0] = fifo_level_reg[FIFO_LEVEL_WIDTH-2:FIFO_LEVEL_WIDTH-3] | {2{fifo_level_reg[FIFO_LEVEL_WIDTH-1]}};

  assign tgu_busy_o = tgu_busy;

  assign tgu_fifo_empty_o = ~(|fifo_level_reg[FIFO_LEVEL_WIDTH-1:0]);
  assign tgu_fifo_full_o  = fifo_level_reg[FIFO_LEVEL_WIDTH-1];

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "fifo_level_we is X")
    ovl_never_unknown_tgu_status_fifo_level_we (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (fifo_level_we)
    );

  assert_never_unknown #(`OVL_FATAL, FIFO_LEVEL_WIDTH, `OVL_ASSERT, "fifo_level is X")
    ovl_never_unknown_tgu_status_fifo_level (
      .clk       (clk_gated),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (fifo_level_reg)
    );


`endif

endmodule // cxstm500_tgu_status
