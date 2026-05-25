//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2004-05, 2012, 2016-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_trace_pattern
(
  input  wire        traceclk_in,
  input  wire        treset_n,

  input  wire        pattern_complete,
  output  reg [31:0] gen_data,

  output wire        trace_pattern,
  output wire        trace_pattern_falling,

  input  wire        reg_update,
  input  wire [31:0] curr_psize_masked,
  input  wire  [3:0] curr_patt_sel,
  input  wire  [1:0] curr_patt_mode,

  output wire        pattern_done
);


  wire           nxt_pat_bit_3;
  wire           nxt_pat_bit_2;
  wire           nxt_pat_bit_1;
  wire           nxt_pat_bit_0;
  reg  [3:0]     nxt_pattern_sel;
  wire           nxt_pattern_en;
  reg  [3:0]     pattern_sel;
  wire           nxt_pattern_restart;
  reg            pattern_restart;

  wire           restart_0;
  wire [31:0]    gen_data_0;
  wire           gen_data_0_r_en;
  reg  [31:0]    gen_data_0_q;

  wire [31:0]    gen_data_1;

  wire           restart_2;
  wire [31:0]    gen_data_2;
  wire           gen_data_2_r_en;
  reg            gen_data_2_q;

  wire [31:0]    gen_data_3;

  wire           nxt_running;
  reg            running;
  wire           running_en;

  reg         patt_state;
  reg         nxt_patt_state;
  wire        patt_st_en;
  wire [3:0]  nxt_pattern;


  localparam ST_PATTERN_OFF = 1'b0;
  localparam ST_PATTERN_ON  = 1'b1;


  assign nxt_pat_bit_3 = ( pattern_sel[0]                           |
                          (pattern_sel[1] &  ~curr_patt_sel[0])     |
                          (pattern_sel[2] & ~(curr_patt_sel[0] |
                                              curr_patt_sel[1]   )) |
                          (pattern_sel[3] & ~(curr_patt_sel[0] |
                                              curr_patt_sel[1] |
                                              curr_patt_sel[2]   )) |
                          (~(|pattern_sel[3:0]))
                         );

  assign nxt_pat_bit_2 = ( pattern_sel[3]                           |
                          (pattern_sel[0] & ~curr_patt_sel[3])      |
                          (pattern_sel[1] & ~(curr_patt_sel[3] |
                                              curr_patt_sel[0]   )) |
                          (pattern_sel[2] & ~(curr_patt_sel[3] |
                                              curr_patt_sel[0] |
                                              curr_patt_sel[1]   )) |
                          (~(|pattern_sel[3:0]) & ~curr_patt_sel[3])
                         );

  assign nxt_pat_bit_1 = ( pattern_sel[2]                           |
                          (pattern_sel[3] & ~curr_patt_sel[2])      |
                          (pattern_sel[0] & ~(curr_patt_sel[2] |
                                              curr_patt_sel[3]   )) |
                          (pattern_sel[1] & ~(curr_patt_sel[2] |
                                              curr_patt_sel[3] |
                                              curr_patt_sel[0]   )) |
                          (~(|pattern_sel[3:0]) & ~(curr_patt_sel[3] |
                                                    curr_patt_sel[2])));

  assign nxt_pat_bit_0 = ( pattern_sel[1]                           |
                          (pattern_sel[2] & ~curr_patt_sel[1])      |
                          (pattern_sel[3] & ~(curr_patt_sel[1] |
                                              curr_patt_sel[2]   )) |
                          (pattern_sel[0] & ~(curr_patt_sel[1] |
                                              curr_patt_sel[2] |
                                              curr_patt_sel[3]   )) |
                          (~(|pattern_sel[3:0]) & ~(curr_patt_sel[3] |
                                                    curr_patt_sel[2] |
                                                    curr_patt_sel[1])));

  assign patt_st_en = patt_state != nxt_patt_state;

  always @ *
  begin : c_pattern_state

    case (patt_state)
      ST_PATTERN_OFF:
        begin
          if (nxt_running)
            begin
              nxt_patt_state = ST_PATTERN_ON;
              nxt_pattern_sel = nxt_pattern;
            end
          else
            begin
              nxt_patt_state = ST_PATTERN_OFF;
              nxt_pattern_sel = 4'b0;
            end
        end
      ST_PATTERN_ON:
        begin
          if (nxt_running)
            begin
              nxt_patt_state = ST_PATTERN_ON;
              nxt_pattern_sel = nxt_pattern;
            end
          else
            begin
              nxt_patt_state = ST_PATTERN_OFF;
              nxt_pattern_sel = 4'b0;
            end
        end
      default:
        begin
          nxt_patt_state = 1'bx;
          nxt_pattern_sel = 4'bxxxx;
        end
    endcase
  end

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_patt_state
    if (!treset_n)
      patt_state <= 1'b0;
    else if (patt_st_en)
      patt_state <= nxt_patt_state;
  end

  assign nxt_pattern = {(curr_patt_sel[3] & nxt_pat_bit_3),
                            (curr_patt_sel[2] & nxt_pat_bit_2),
                            (curr_patt_sel[1] & nxt_pat_bit_1),
                            (curr_patt_sel[0] & nxt_pat_bit_0) };


  assign nxt_pattern_en = (pattern_complete | reg_update) ||
                          (nxt_patt_state == ST_PATTERN_ON && patt_state == ST_PATTERN_OFF);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_pattern_sel
    if (!treset_n)
      pattern_sel <= 4'b0;
    else if (nxt_pattern_en)
      pattern_sel <= nxt_pattern_sel;
  end

  assign pattern_done = ( pattern_complete
                        & ( (pattern_sel[3] & ~(|curr_patt_sel[2:0]))
                          | (pattern_sel[2] & ~(|curr_patt_sel[1:0]))
                          | (pattern_sel[1] & ~( curr_patt_sel[0]  ))
                          | (pattern_sel[0]                         )
                          | (pattern_sel==4'd0                      )
                          )
                        );

  assign nxt_pattern_restart = pattern_complete | reg_update;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_pattern_ctl
    if (!treset_n)
      begin
        pattern_restart    <= 1'b0;
      end
    else if (running || nxt_pattern_restart)
      begin
        pattern_restart    <= nxt_pattern_restart;
      end
  end


  assign restart_0 = ((|(gen_data_0_q[31:0] & curr_psize_masked)) & running)|
                       pattern_restart;

  assign gen_data_0 = restart_0 ? 32'h00000001 :
                               {gen_data_0_q[30:0],gen_data_0_q[31]};

  assign gen_data_0_r_en = (running | restart_0);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_walking_bits
    if (!treset_n)
      gen_data_0_q <= 32'b0;
    else if (gen_data_0_r_en)
      gen_data_0_q <= gen_data_0;
  end


  assign gen_data_1 = ~gen_data_0[31:0];


  assign restart_2 = pattern_restart;

  assign gen_data_2 = {16{ restart_2 ? 2'b01 : {~gen_data_2_q, gen_data_2_q} }};

  assign gen_data_2_r_en = (running | restart_2);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_alt_bits
    if (!treset_n)
      gen_data_2_q <= 1'b0;
    else if (gen_data_2_r_en)
      gen_data_2_q <= gen_data_2[1];
  end


  assign gen_data_3 = {32{ restart_2 ? 1'b1 : gen_data_2_q }};


  assign nxt_running = curr_patt_mode[1] | (curr_patt_mode[0] & ~pattern_done);
  assign running_en  = (nxt_running | running);

  always @ *
  begin : c_gen_data
    case (pattern_sel[3:0])
      4'b1000 : gen_data = gen_data_3;
      4'b0100 : gen_data = gen_data_2;
      4'b0010 : gen_data = gen_data_1;
      4'b0001 : gen_data = gen_data_0;
      4'b0000 : gen_data = {32{1'b0}};
      default : gen_data = {32{1'bx}};
    endcase
  end

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_running
    if (!treset_n)
      running <= 1'b0;
    else if (running_en)
      running <= nxt_running;
  end

  assign trace_pattern         = running;
  assign trace_pattern_falling = running & ~nxt_running;


endmodule

