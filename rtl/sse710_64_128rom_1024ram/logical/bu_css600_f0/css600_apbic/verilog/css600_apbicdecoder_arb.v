//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_apbic
//
//----------------------------------------------------------------------------


module css600_apbicdecoder_arb # (parameter
  NUM_APB_SLAVES     = 1
)
(
  input  wire                      clk,
  input  wire                      reset_n,
  input  wire [NUM_APB_SLAVES-1:0] psel_s,
  input  wire                      psel_default_q,
  output wire                      penable_int,
  input  wire                      pready_int,
/* verilator lint_off UNOPTFLAT */
  output wire [NUM_APB_SLAVES-1:0] slave_select,
/* verilator lint_on UNOPTFLAT */
  output reg                       cycle_active,
  output reg                       cycle_start,
  input                            dev_run,
  output reg                       dev_active
);


  localparam IDLE   = 2'b00;
  localparam SETUP  = 2'b01;
  localparam ACTIVE = 2'b11;
  localparam UNUSED = 2'b10;

  reg        state_en;
  reg  [1:0] arb_state;
  reg  [1:0] next_arb_state;


  genvar slave;
  generate
    assign slave_select[0] = psel_s[0];
    for (slave = 1; slave < NUM_APB_SLAVES; slave = slave + 1) begin: encode
      assign slave_select[slave]
        = psel_s[slave] & ~|(slave_select[slave-1:0]);
    end
  endgenerate


  always @(*) begin
    next_arb_state = arb_state;
    cycle_start = 1'b0;
    cycle_active = 1'b0;
    dev_active = 1'b0;
    state_en = 1'b0;
    case (arb_state)
      IDLE: begin
        dev_active = 1'b0;
        if (|(psel_s) && dev_run) begin
          cycle_start    = 1'b1;
          next_arb_state = SETUP;
          state_en = 1'b1;
        end
      end
      SETUP: begin
        dev_active     = 1'b1;
        next_arb_state = ACTIVE;
        state_en = 1'b1;
      end
      ACTIVE: begin
        dev_active     = 1'b1;
        cycle_active   = 1'b1;
        if (pready_int)
          next_arb_state = IDLE;
          state_en = 1'b1;
      end
      UNUSED: begin
        next_arb_state = IDLE;
        state_en = 1'b1;
      end
      default: begin
        next_arb_state = 2'bxx;
        cycle_start    = 1'bx;
        cycle_active   = 1'bx;
        dev_active     = 1'bx;
        state_en       = 1'bx;
      end
    endcase
  end


  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      arb_state <= IDLE;
    else if (state_en)
     arb_state <= next_arb_state;
  end

  assign penable_int = arb_state[1] & ~psel_default_q;

endmodule
