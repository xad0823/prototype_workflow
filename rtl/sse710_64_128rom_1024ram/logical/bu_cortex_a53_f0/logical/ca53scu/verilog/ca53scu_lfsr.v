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

//-----------------------------------------------------------------------------
// Description:
//  LFSR pseudorandom number generator
//  RADIX must be a power of 2, 3, or 5
//  The output value is one token in the range 0 to RADIX-1
//  LFSR_LEN if the number of tokens in the LFSR.
//-----------------------------------------------------------------------------
//

`include "cortexa53params.v"

module ca53scu_lfsr #(parameter RADIX = 2, parameter LFSR_LEN = 7) (
  input  wire                       clk,
  input  wire                       reset_n,
  input  wire                       shift_enable_i,
  output wire [`CA53_LOG2(RADIX)-1:0] lfsr_out_o
);

  function integer get_base(input integer radix);
    if ((radix % 2) == 0)
      get_base = 2;
    else if ((radix % 3) == 0)
      get_base = 3;
    else if ((radix % 5) == 0)
      get_base = 5;
    else
      get_base = -1;
  endfunction

  function integer get_power(input integer radix, input integer base);
    integer tmp;
    begin
      if (base != -1) begin
        tmp = radix;
        get_power = 0;

        while ((tmp > 1) && get_power != -1) begin
          if ((tmp % base) != 0) begin
            get_power = -1;
          end else begin
            get_power = get_power + 1;
            tmp = tmp / base;
          end
        end
      end else begin
        get_power = -1;
      end
    end
  endfunction

  localparam BASE      = get_base(RADIX);
  localparam POW       = get_power(RADIX, BASE);
  localparam ELEM_W    = `CA53_LOG2(BASE);
  localparam TOKEN_W   = ELEM_W * POW;
  localparam LFSR_W    = TOKEN_W * LFSR_LEN;
  localparam NUM_ELEMS = POW * LFSR_LEN;

  //-----------------------------------------------------------------------------
  //  Declarations
  //-----------------------------------------------------------------------------

  reg  [LFSR_W-1:0] lfsr;
  wire [LFSR_W-1:0] lfsr_stage [POW:0];
  wire [LFSR_W-1:0] next_lfsr;

  genvar stage;

  //-----------------------------------------------------------------------------
  //  Main code
  //-----------------------------------------------------------------------------

  assign lfsr_stage[0] = lfsr;

  // Index is reversed: 1 refers to the MSB element
  `define CA53_ELEM(i) (lfsr_stage[stage-1][(NUM_ELEMS - i)*ELEM_W+:ELEM_W])

  generate for (stage = 1; stage <= POW; stage = stage + 1) begin : g_stage
    assign lfsr_stage[stage][0+:LFSR_W-ELEM_W] = lfsr_stage[stage-1][ELEM_W+:LFSR_W-ELEM_W];

    case (BASE)
      2: begin : g_base2
        case (NUM_ELEMS)
          2:  begin : g_len2
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(2)  ^ `CA53_ELEM(1);
          end
          3:  begin : g_len3
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(3)  ^ `CA53_ELEM(2);
          end
          4:  begin : g_len4
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(4)  ^ `CA53_ELEM(3);
          end
          5:  begin : g_len5
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(5)  ^ `CA53_ELEM(3);
          end
          6:  begin : g_len6
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(6)  ^ `CA53_ELEM(5);
          end
          7:  begin : g_len7
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(7)  ^ `CA53_ELEM(6);
          end
          8:  begin : g_len8
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(8)  ^ `CA53_ELEM(6) ^ `CA53_ELEM(5) ^ `CA53_ELEM(4);
          end
          9:  begin : g_len9
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(9)  ^ `CA53_ELEM(5);
          end
          10: begin : g_len10
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(10) ^ `CA53_ELEM(7);
          end
          11: begin : g_len11
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(11) ^ `CA53_ELEM(9);
          end
          12: begin : g_len12
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(12) ^ `CA53_ELEM(11) ^ `CA53_ELEM(10) ^ `CA53_ELEM(4);
          end
          13: begin : g_len13
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(13) ^ `CA53_ELEM(12) ^ `CA53_ELEM(11) ^ `CA53_ELEM(8);
          end
          14: begin : g_len14
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(14) ^ `CA53_ELEM(13) ^ `CA53_ELEM(12) ^ `CA53_ELEM(2);
          end
          15: begin : g_len15
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(15) ^ `CA53_ELEM(14);
          end
          16: begin : g_len16
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = `CA53_ELEM(16) ^ `CA53_ELEM(15) ^ `CA53_ELEM(13) ^ `CA53_ELEM(4);
          end
        endcase
      end
      3: begin : g_base3
        case (NUM_ELEMS)
          2:  begin : g_len2
            wire [3:0] next_digit;
            assign next_digit = (`CA53_ELEM(2) + (`CA53_ELEM(1) * 2'd2)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          3:  begin : g_len3
            wire [2:0] next_digit;
            assign next_digit = (`CA53_ELEM(3) + (`CA53_ELEM(2) * 2'd2)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          4:  begin : g_len4
            wire [3:0] next_digit;
            assign next_digit = (`CA53_ELEM(4) + (`CA53_ELEM(3) * 2'd2)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          5:  begin : g_len5
            wire [2:0] next_digit;
            assign next_digit = (`CA53_ELEM(5) + `CA53_ELEM(4) + `CA53_ELEM(2)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          6:  begin : g_len6
            wire [3:0] next_digit;
            assign next_digit = (`CA53_ELEM(6) + (`CA53_ELEM(5) * 2'd2)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          7:  begin : g_len7
            wire [2:0] next_digit;
            assign next_digit = (`CA53_ELEM(7) + `CA53_ELEM(6) + `CA53_ELEM(4)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
          8:  begin : g_len8
            wire [3:0] next_digit;
            assign next_digit = (`CA53_ELEM(8) + `CA53_ELEM(5)) % 2'd3;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[1:0];
          end
        endcase
      end
      5: begin : g_base5
        case (NUM_ELEMS)
          2: begin : g_len2
            wire [4:0] next_digit;
            assign next_digit = ((`CA53_ELEM(2) + `CA53_ELEM(1)) * 2'd2) % 3'd5;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[2:0];
          end
          3: begin : g_len3
            wire [4:0] next_digit;
            assign next_digit = ((`CA53_ELEM(3) + `CA53_ELEM(2)) * 2'd2) % 3'd5;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[2:0];
          end
          4: begin : g_len4
            wire [5:0] next_digit;
            assign next_digit = ((`CA53_ELEM(4) + `CA53_ELEM(2) + (`CA53_ELEM(1) * 2'd2)) * 2'd2) % 3'd5;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[2:0];
          end
          5: begin : g_len5
            wire [4:0] next_digit;
            assign next_digit = ((`CA53_ELEM(5) + `CA53_ELEM(2)) * 2'd2) % 3'd5;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[2:0];
          end
          6: begin : g_len6
            wire [4:0] next_digit;
            assign next_digit = ((`CA53_ELEM(6) + `CA53_ELEM(5)) * 2'd2) % 3'd5;
            assign lfsr_stage[stage][LFSR_W-1-:ELEM_W] = next_digit[2:0];
          end
        endcase
      end
    endcase
  end endgenerate

  assign next_lfsr = lfsr_stage[POW];

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    lfsr <= { {LFSR_W-1{1'b0}}, 1'b1};
  end else if (shift_enable_i) begin
    lfsr <= next_lfsr;
  end

  //-----------------------------------------------------------------------------
  //  Assign outputs
  //-----------------------------------------------------------------------------

  assign lfsr_out_o = lfsr[TOKEN_W-1:0];

  //-----------------------------------------------------------------------------
  //  Assertions
  //-----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "LFSR should never be zero")
  u_ovl_nonzero_lfsr (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (|lfsr)
  );

  assert_always #(`OVL_FATAL, `OVL_ASSERT, "LFSR output should never be greater than the radix")
  u_ovl_output_in_radix (
    .clk       (clk),
    .reset_n   (reset_n),
    .test_expr (lfsr[TOKEN_W-1:0] < RADIX)
  );

  localparam PERIOD = (RADIX ** LFSR_LEN) - 1;

  integer num_steps;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    num_steps <= 0;
  end else if (shift_enable_i) begin
    num_steps <= num_steps + 1;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "LFSR should not return to initial state before cycling through whole period")
  u_ovl_no_early_initial (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr ((num_steps > 0) && (num_steps < PERIOD)),
    .consequent_expr (lfsr != { {LFSR_W{1'b0}}, 1'b1})
  );

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "LFSR should return to initial state after cycling through whole period")
  u_ovl_return_to_initial (
    .clk             (clk),
    .reset_n         (reset_n),
    .antecedent_expr (num_steps == PERIOD),
    .consequent_expr (lfsr == { {LFSR_W{1'b0}}, 1'b1})
  );

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: shift_enable_i")
  u_ovl_x_shift_enable_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (shift_enable_i));

`endif

endmodule

/*ARMAUTO_UNDEF*/
`undef CA53_ELEM
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
