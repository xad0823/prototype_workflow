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
//      STM DMA Peripheral Request Interface
//-----------------------------------------------------------------------------

module cxstm500_dmaif (
  // Clock and Reset
  input wire                     CLK,              // AXI Clock
  input wire                     ARESETn,          // AXI Reset
  // DMA Peripheral Request Interface
  input  wire                    DRREADY,          // DMA Request Ready
  input  wire                    DAVALID,          // DMA Acknowledge Valid
  input  wire [1:0]              DATYPE,           // DMA Acknowledge Type
  output wire                    DRVALID,          // DMA Request Valid
  output wire [1:0]              DRTYPE,           // DMA Request Type
  output wire                    DRLAST,           // DMA Last Request
  output wire                    DAREADY,          // DMA Acknowledge Ready
  // DMA control interface
  input  wire                    dma_enable_i,     // dma request generation enable
  input  wire [1:0]              dma_sens_i,       // dma fifo sensitivity
  input  wire [1:0]              tgu_fifo_level_i, // dma fifo sensitivity
  input  wire                    tgu_fifo_full_i,  // TGU fifo full
  output wire                    dma_busy_o,       // DMA busy for STM Busy
  output wire                    dma_busy_qchan_o, // DMA busy for Q-Channel
  input  wire                    q_stop_i          // Q-Channel stopped
  );

  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam  DMA_IDLE       = 3'b000;    // DMA FSM idle
  localparam  DMA_BREQ       = 3'b101;    // DMA FSM requesting burst from DMAC
  localparam  DMA_WAIT       = 3'b011;    // DMA FSM waiting for burst acknowledge from DMAC
  localparam  DMA_FLUSH      = 3'b110;    // DMA FSM acknowledging flush request from DMAC

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                    state_we;
  wire                    flush_req;
  wire                    burst_ack;
  wire                    fifo_ready;
  wire                    flush_ack;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg  [2:0]              nxt_state;
  reg [2:0]               state_reg;
  reg                     dma_busy_reg;
  reg                     dma_busy_qchan_reg;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------
  assign flush_ack = DRREADY & DRVALID & (DRTYPE == 2'b10);
  assign state_we = (flush_req | flush_ack | dma_enable_i | dma_busy_reg) & ~q_stop_i;

  // FSM that controls DMA request generation
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      state_reg <= DMA_IDLE;
    else if (state_we)
      state_reg <= nxt_state;
  end

  assign flush_req  = DAVALID & (DATYPE[1:0] == 2'b10);
  assign burst_ack  = DAVALID & (DATYPE[1:0] == 2'b01);
  assign fifo_ready = ((dma_sens_i[1:0] == 2'b11) & ~tgu_fifo_full_i)                 |
                      ((dma_sens_i[1:0] == 2'b10) & (tgu_fifo_level_i[1:0] != 2'b11)) |
                      ((dma_sens_i[1:0] == 2'b01) & ~tgu_fifo_level_i[1])             |
                      ((dma_sens_i[1:0] == 2'b00) & (tgu_fifo_level_i[1:0] == 2'b00));

  // FSM for handling PL330 DMA request protocol
  always @*
  begin
    case (state_reg)
      DMA_IDLE: begin
        // assertion present for flush_req being X
        if (flush_req)
          nxt_state = DMA_FLUSH;
        else
          case ({dma_enable_i, fifo_ready})
            2'b00:   nxt_state = DMA_IDLE;
            2'b01:   nxt_state = DMA_IDLE;
            2'b10:   nxt_state = DMA_IDLE;
            2'b11:   nxt_state = DMA_BREQ;
            // unreachable, X propagation only
            // VCS coverage off
            default: nxt_state = 3'bxxx;
            // VCS coverage on
          endcase
      end
      DMA_BREQ: begin
        nxt_state = DRREADY ? DMA_WAIT[2:0] : DMA_BREQ[2:0];
      end
      DMA_WAIT: begin
        case ({flush_req, burst_ack})
          2'b10:   nxt_state = DMA_FLUSH;
          2'b01:   nxt_state = DMA_IDLE;
          2'b00:   nxt_state = DMA_WAIT;
          // flush_req & burst_ack cannot happen, assertion present - uzovl_0
          // VCS coverage off
          default: nxt_state = 3'bxxx;
          // VCS coverage on
        endcase
      end
      DMA_FLUSH: begin
        nxt_state = DRREADY ? DMA_IDLE : DMA_FLUSH;
      end
      // all other cases are illegal cases, assertion present - uzovl_1
      // VCS coverage off
      default: nxt_state = 3'bxxx;
      // VCS coverage on
    endcase
  end

  // dma_busy reports busy if there is request ongoing - flush does not factor
  // into the STM busy flag as the STM is able to respond to flush requests
  // while disabled
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      dma_busy_reg <= 1'b0;
    else if (state_we)
      dma_busy_reg <= nxt_state[0];
  end

  // dma_qchannel_busy reports busy if there is request or flush ongoing
  // The STM will be unable to respond to flush requests while in Q_STOPPED
  // hence they must be factored into the qchannel busy flag
  always @(posedge CLK or negedge ARESETn)
  begin
    if (!ARESETn)
      dma_busy_qchan_reg <= 1'b0;
    else if (state_we)
      dma_busy_qchan_reg <= ~(nxt_state == 3'b000);
  end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  // DMAC i/f
  assign DRVALID     =  state_reg[2] & ~q_stop_i;
  assign DRTYPE[1:0] =  state_reg[1:0];
  assign DRLAST      =  1'b0;

  // Only accept flush requests or responses if not burst request acceptance is not stalled
  assign DAREADY     = ~state_reg[2] & ~q_stop_i;

  // Status i/f
  assign dma_busy_o       = dma_busy_reg;
  assign dma_busy_qchan_o = dma_busy_qchan_reg | (DAVALID & DAREADY);

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"illegal - flush request and burst acknowledge cannot happen together")
    ovl_never_dmaif_illegal_flush_request (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr (flush_req & burst_ack)
    );

  assert_never #(`OVL_FATAL,`OVL_ASSERT,"illegal state")
    ovl_never_dmaif_illegal_state (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .test_expr ((state_reg[2:0]==3'b001)|(state_reg[2:0]==3'b010)|(state_reg[2:0]==3'b100)|(state_reg[2:0]==3'b111))
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 3, `OVL_ASSERT, "illegal nxt_state")
    ovl_never_unknown_dmaif_nxt_state (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (nxt_state[2:0])
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "flush_req is X")
    ovl_never_unknown_dmaif_flush_req (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (flush_req)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "state_we is X")
    ovl_never_unknown_dmaif_state_we (
      .clk       (CLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (state_we)
    );

`endif

endmodule // cxstm500_dmaif
