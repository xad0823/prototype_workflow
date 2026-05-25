//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2004-2006, 2012-2014, 2016-2020 Arm Limited or its affiliates.
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


module css600_tpiu_trace_out
(
  input  wire         traceclk_in,
  input  wire         treset_n,

  output  reg  [31:0] tracedata,
  output  reg         tracectl,

  input  wire         trace_d_valid,
  input  wire  [31:0] trace_d,
  output wire         trace_d_ready,
  input  wire         trace_d_stopped,
  input  wire         trace_flush_req,
  output wire         trace_flush_ack,
  output wire         trace_idle,
  output wire         trace_idle_hsp,
  output reg    [1:0] trace_stop_state,

  input  wire         continuous_mode,
  input  wire         trig_port_sync,
  input  wire         curr_psize_update,
  input  wire  [31:0] port_bit_mask,
  input  wire         trace_pattern
);

  `include "css600_tpiu_localparams.v"
  localparam ST_FTSTOP_IDLE   = 2'b00;
  localparam ST_FTSTOP_RPEND  = 2'b01;
  localparam ST_FTSTOP_RHOLD  = 2'b10;
  localparam ST_FTSTOP_UNUSED = 2'b11;


  wire            trace_stall;
  wire            nxt_trace_ctl;
  reg             trig_port_sync_q;
  wire            trace_trigger;
  wire            t_pattern_q_en;
  reg             t_pattern_q;

  reg             ft_reset;
  reg             trace_stop_state_en;
  reg  [1:0]      nxt_trace_stop_state;

  wire            sync_insert_half;
  wire            trace_ds_valid;

  wire            output_hold;

  wire [5:0]      rotate;
  reg  [5:0]      previous_rotate;
  wire            rotate_en;
  wire [5:0]      nxt_curr_rotate;
  wire [5:0]      new_rotate;
  reg  [5:0]      curr_rotate;
  wire [31:0]     previous_port_bit_mask;

  wire            nxt_bank_update;
  wire            bank_update_en;
  reg             bank_update;
  reg  [31:0]     holding_bank_a;
  reg  [31:0]     holding_bank_b;
  wire [31:0]     nxt_holding_bank;
  wire            update_bank_a;
  wire            update_bank_b;
  wire            nxt_bank_a_empty;
  wire            nxt_bank_b_empty;
  reg             bank_a_empty;
  reg             bank_b_empty;

  reg  [31:0]     bank_sel;
  wire [63:0]     bank_sel_part_a;
  wire [63:0]     bank_sel_part_b;
  wire [63:0]     bank_sel_part_c;
  wire [63:0]     bank_sel_part_d;
  wire [63:0]     bank_sel_part_e;
  wire [63:0]     bank_sel_part_f;
  reg             bank_a_required;
  reg             bank_b_required;
  wire            nxt_bank_a_req;
  wire            nxt_bank_b_req;
  wire [31:0]     nxt_bank_sel;
  wire            bank_mask_en;

  wire [31:0]     nxt_trace_data;
  wire [31:0]     merged_bank;
  wire [31:0]     rot_data_part_a;
  wire [31:0]     rot_data_part_b;
  wire [31:0]     rot_data_part_c;
  wire [31:0]     rot_data_part_d;
  wire [31:0]     rot_data_part_e;


  assign trace_trigger = trig_port_sync & ~trig_port_sync_q;

  assign trace_stall   = (trace_trigger & ~t_pattern_q) |
                         (bank_a_empty & bank_a_required) |
                         (bank_b_empty & bank_b_required);

  assign nxt_trace_ctl = ((trace_stop_state == ST_FTSTOP_RPEND)
                         ) ? 1'b0
                       : (trace_stall | output_hold)
                       ;

  assign trace_idle    = nxt_trace_ctl & tracectl & ~sync_insert_half;

  assign trace_idle_hsp  =  sync_insert_half & trace_d_stopped & (tracedata != 32'h0);

  assign trace_flush_ack = trace_flush_req & (trace_idle | sync_insert_half);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_trigport
    if (!treset_n)
      begin
        tracectl         <= 1'b1;
        trig_port_sync_q <= 1'b0;
      end
    else
      begin
        tracectl         <= nxt_trace_ctl;
        trig_port_sync_q <= trig_port_sync;
      end
  end

  assign t_pattern_q_en = (trace_pattern & ~t_pattern_q) |
                          (~trace_pattern &  t_pattern_q) ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_tpattern_q
    if (!treset_n)
      t_pattern_q <= 1'b0;
    else if (t_pattern_q_en)
      t_pattern_q <= trace_pattern;
  end


  assign output_hold = (curr_rotate==6'd0) & (new_rotate == 6'd0);

  always @ *
  begin : c_nxt_ftstop_state
    ft_reset = 1'b0;

    case (trace_stop_state)
      ST_FTSTOP_IDLE:
        begin
          trace_stop_state_en  = trace_d_stopped;
          nxt_trace_stop_state = (t_pattern_q && ~trace_pattern) ? ST_FTSTOP_RHOLD
                               :                                   ST_FTSTOP_RPEND
                               ;
        end
      ST_FTSTOP_RPEND:
        begin
          trace_stop_state_en  = (~trace_d_stopped|trace_stall);
          nxt_trace_stop_state = ST_FTSTOP_RHOLD;
          ft_reset = trace_stop_state_en;
        end
      ST_FTSTOP_RHOLD:
        begin
          trace_stop_state_en  = ~trace_d_stopped;
          nxt_trace_stop_state = ST_FTSTOP_IDLE;
        end
      ST_FTSTOP_UNUSED:
        begin
          trace_stop_state_en  = ~trace_d_stopped;
          nxt_trace_stop_state = ST_FTSTOP_IDLE;
        end
      default:
        begin
          trace_stop_state_en  = 1'b1;
          nxt_trace_stop_state = 2'bxx;
        end
    endcase
  end

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_ftstop_state
    if (!treset_n)
      trace_stop_state <= ST_FTSTOP_UNUSED;
    else if (trace_stop_state_en)
      trace_stop_state <= nxt_trace_stop_state;
  end


  assign rotate = port_bit_mask[31] ? 6'b100000
                : port_bit_mask[30] ? 6'b011111
                : port_bit_mask[29] ? 6'b011110
                : port_bit_mask[28] ? 6'b011101
                : port_bit_mask[27] ? 6'b011100
                : port_bit_mask[26] ? 6'b011011
                : port_bit_mask[25] ? 6'b011010
                : port_bit_mask[24] ? 6'b011001
                : port_bit_mask[23] ? 6'b011000
                : port_bit_mask[22] ? 6'b010111
                : port_bit_mask[21] ? 6'b010110
                : port_bit_mask[20] ? 6'b010101
                : port_bit_mask[19] ? 6'b010100
                : port_bit_mask[18] ? 6'b010011
                : port_bit_mask[17] ? 6'b010010
                : port_bit_mask[16] ? 6'b010001
                : port_bit_mask[15] ? 6'b010000
                : port_bit_mask[14] ? 6'b001111
                : port_bit_mask[13] ? 6'b001110
                : port_bit_mask[12] ? 6'b001101
                : port_bit_mask[11] ? 6'b001100
                : port_bit_mask[10] ? 6'b001011
                : port_bit_mask[9]  ? 6'b001010
                : port_bit_mask[8]  ? 6'b001001
                : port_bit_mask[7]  ? 6'b001000
                : port_bit_mask[6]  ? 6'b000111
                : port_bit_mask[5]  ? 6'b000110
                : port_bit_mask[4]  ? 6'b000101
                : port_bit_mask[3]  ? 6'b000100
                : port_bit_mask[2]  ? 6'b000011
                : port_bit_mask[1]  ? 6'b000010
                : port_bit_mask[0]  ? 6'b000001
                :                     6'bxxxxxx
                ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_previous_rotate
    if (!treset_n)
      previous_rotate <= 6'b000001;
    else if (curr_psize_update)
      previous_rotate <= rotate;
  end

  assign rotate_en = ~trace_stall | ft_reset;
  assign nxt_curr_rotate = ft_reset ? 6'b0 : new_rotate;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_curr_rotate
    if (!treset_n)
      curr_rotate <= 6'b000000;
    else if (rotate_en)
      curr_rotate <= nxt_curr_rotate;
  end

  assign new_rotate = (t_pattern_q                                         ) ? (curr_rotate + 6'b100000)
                    : (trace_stall                     && curr_psize_update) ? ({1'b1, {5{~trace_pattern}}} & (curr_rotate                  ))
                    : (                                   curr_psize_update) ? ({1'b1, {5{~trace_pattern}}} & (curr_rotate + previous_rotate))
                    :                                                          ({1'b1, {5{~trace_pattern}}} & (curr_rotate +          rotate))
                    ;

  assign previous_port_bit_mask[31] = (previous_rotate > 6'd31);
  assign previous_port_bit_mask[30] = (previous_rotate > 6'd30);
  assign previous_port_bit_mask[29] = (previous_rotate > 6'd29);
  assign previous_port_bit_mask[28] = (previous_rotate > 6'd28);
  assign previous_port_bit_mask[27] = (previous_rotate > 6'd27);
  assign previous_port_bit_mask[26] = (previous_rotate > 6'd26);
  assign previous_port_bit_mask[25] = (previous_rotate > 6'd25);
  assign previous_port_bit_mask[24] = (previous_rotate > 6'd24);
  assign previous_port_bit_mask[23] = (previous_rotate > 6'd23);
  assign previous_port_bit_mask[22] = (previous_rotate > 6'd22);
  assign previous_port_bit_mask[21] = (previous_rotate > 6'd21);
  assign previous_port_bit_mask[20] = (previous_rotate > 6'd20);
  assign previous_port_bit_mask[19] = (previous_rotate > 6'd19);
  assign previous_port_bit_mask[18] = (previous_rotate > 6'd18);
  assign previous_port_bit_mask[17] = (previous_rotate > 6'd17);
  assign previous_port_bit_mask[16] = (previous_rotate > 6'd16);
  assign previous_port_bit_mask[15] = (previous_rotate > 6'd15);
  assign previous_port_bit_mask[14] = (previous_rotate > 6'd14);
  assign previous_port_bit_mask[13] = (previous_rotate > 6'd13);
  assign previous_port_bit_mask[12] = (previous_rotate > 6'd12);
  assign previous_port_bit_mask[11] = (previous_rotate > 6'd11);
  assign previous_port_bit_mask[10] = (previous_rotate > 6'd10);
  assign previous_port_bit_mask[ 9] = (previous_rotate > 6'd 9);
  assign previous_port_bit_mask[ 8] = (previous_rotate > 6'd 8);
  assign previous_port_bit_mask[ 7] = (previous_rotate > 6'd 7);
  assign previous_port_bit_mask[ 6] = (previous_rotate > 6'd 6);
  assign previous_port_bit_mask[ 5] = (previous_rotate > 6'd 5);
  assign previous_port_bit_mask[ 4] = (previous_rotate > 6'd 4);
  assign previous_port_bit_mask[ 3] = (previous_rotate > 6'd 3);
  assign previous_port_bit_mask[ 2] = (previous_rotate > 6'd 2);
  assign previous_port_bit_mask[ 1] = (previous_rotate > 6'd 1);
  assign previous_port_bit_mask[ 0] = (previous_rotate > 6'd 0);


  assign nxt_bank_update  = ~bank_update & ~ft_reset;
  assign sync_insert_half = (continuous_mode == 1'b0 ) ? 1'b0
                          : (nxt_bank_update == 1'b0 ) ? (nxt_bank_b_req & update_bank_b)
                          : (nxt_bank_update == 1'b1 ) ? (nxt_bank_a_req & update_bank_a)
                          :                              1'b1
                          ;
  assign trace_ds_valid   = trace_d_valid | sync_insert_half;
  assign bank_update_en   = (ft_reset |
                             ((update_bank_a | update_bank_b) & trace_ds_valid));

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_bank_update
    if (!treset_n)
      bank_update <= 1'b0;
    else if (bank_update_en)
      bank_update <= nxt_bank_update;
  end

  assign update_bank_a = ((ft_reset     |
                           bank_a_empty |
                           (~trace_stall & ~curr_rotate[5] &  new_rotate[5]) |
                           (~bank_update & trace_pattern) ));

  assign update_bank_b = ((ft_reset     |
                           bank_b_empty |
                           (~trace_stall &  curr_rotate[5] & ~new_rotate[5]) |
                           (bank_update & trace_pattern) ));

  assign nxt_holding_bank = ((ft_reset || ~trace_d_valid) &&  sync_insert_half) ? 32'h7FFF_7FFF
                          : ((ft_reset || ~trace_d_valid) && ~sync_insert_half) ? 32'h0000_0000
                          :                                                       trace_d
                          ;

  always @ (posedge traceclk_in)
  begin : s_banka
    if (update_bank_a)
      holding_bank_a <= nxt_holding_bank;
  end

  always @ (posedge traceclk_in)
  begin : s_bankb
    if (update_bank_b)
      holding_bank_b <= nxt_holding_bank;
  end

  assign nxt_bank_a_empty = update_bank_a & ( bank_update | ~trace_ds_valid);
  assign nxt_bank_b_empty = update_bank_b & (~bank_update | ~trace_ds_valid);


  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_bankemptyflags
    if (!treset_n)
      begin
        bank_a_empty <= 1'b1;
        bank_b_empty <= 1'b1;
      end
    else
      begin
        bank_a_empty <= nxt_bank_a_empty;
        bank_b_empty <= nxt_bank_b_empty;
      end
  end

  assign trace_d_ready = (update_bank_a | update_bank_b) & ~trace_d_stopped;


  assign bank_sel_part_a = (new_rotate[5] ?
                             {port_bit_mask, 32'b0}
                             : {32'b0, port_bit_mask});
  assign bank_sel_part_b = (new_rotate[4] ?
                             {bank_sel_part_a[47:0], bank_sel_part_a[63:48]}
                             : bank_sel_part_a[63:0]);
  assign bank_sel_part_c = (new_rotate[3] ?
                             {bank_sel_part_b[55:0], bank_sel_part_b[63:56]}
                             : bank_sel_part_b[63:0]);
  assign bank_sel_part_d = (new_rotate[2] ?
                             {bank_sel_part_c[59:0], bank_sel_part_c[63:60]}
                             : bank_sel_part_c[63:0]);
  assign bank_sel_part_e = (new_rotate[1] ?
                             {bank_sel_part_d[61:0], bank_sel_part_d[63:62]}
                             : bank_sel_part_d[63:0]);
  assign bank_sel_part_f = (new_rotate[0] ?
                             {bank_sel_part_e[62:0], bank_sel_part_e[63]}
                             : bank_sel_part_e[63:0]);

  assign nxt_bank_a_req = ft_reset ? 1'b1 : |(bank_sel_part_f[31:0] );
  assign nxt_bank_b_req = ft_reset ? 1'b0 : |(bank_sel_part_f[63:32]);
  assign bank_mask_en = ~trace_stall | ft_reset | curr_psize_update;
  assign nxt_bank_sel = ft_reset ? {32{1'b1}}
                      :            bank_sel_part_f[31:0]
                      ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_bank_select
    if (!treset_n)
      begin
        bank_sel        <= {32{1'b1}};
        bank_a_required <= 1'b1;
        bank_b_required <= 1'b0;
      end
    else if (bank_mask_en)
      begin
        bank_sel        <= nxt_bank_sel;
        bank_a_required <= nxt_bank_a_req;
        bank_b_required <= nxt_bank_b_req;
      end
  end


  assign merged_bank[31] = bank_sel[31] ? holding_bank_a[31]: holding_bank_b[31];
  assign merged_bank[30] = bank_sel[30] ? holding_bank_a[30]: holding_bank_b[30];
  assign merged_bank[29] = bank_sel[29] ? holding_bank_a[29]: holding_bank_b[29];
  assign merged_bank[28] = bank_sel[28] ? holding_bank_a[28]: holding_bank_b[28];
  assign merged_bank[27] = bank_sel[27] ? holding_bank_a[27]: holding_bank_b[27];
  assign merged_bank[26] = bank_sel[26] ? holding_bank_a[26]: holding_bank_b[26];
  assign merged_bank[25] = bank_sel[25] ? holding_bank_a[25]: holding_bank_b[25];
  assign merged_bank[24] = bank_sel[24] ? holding_bank_a[24]: holding_bank_b[24];
  assign merged_bank[23] = bank_sel[23] ? holding_bank_a[23]: holding_bank_b[23];
  assign merged_bank[22] = bank_sel[22] ? holding_bank_a[22]: holding_bank_b[22];
  assign merged_bank[21] = bank_sel[21] ? holding_bank_a[21]: holding_bank_b[21];
  assign merged_bank[20] = bank_sel[20] ? holding_bank_a[20]: holding_bank_b[20];
  assign merged_bank[19] = bank_sel[19] ? holding_bank_a[19]: holding_bank_b[19];
  assign merged_bank[18] = bank_sel[18] ? holding_bank_a[18]: holding_bank_b[18];
  assign merged_bank[17] = bank_sel[17] ? holding_bank_a[17]: holding_bank_b[17];
  assign merged_bank[16] = bank_sel[16] ? holding_bank_a[16]: holding_bank_b[16];
  assign merged_bank[15] = bank_sel[15] ? holding_bank_a[15]: holding_bank_b[15];
  assign merged_bank[14] = bank_sel[14] ? holding_bank_a[14]: holding_bank_b[14];
  assign merged_bank[13] = bank_sel[13] ? holding_bank_a[13]: holding_bank_b[13];
  assign merged_bank[12] = bank_sel[12] ? holding_bank_a[12]: holding_bank_b[12];
  assign merged_bank[11] = bank_sel[11] ? holding_bank_a[11]: holding_bank_b[11];
  assign merged_bank[10] = bank_sel[10] ? holding_bank_a[10]: holding_bank_b[10];
  assign merged_bank[9]  = bank_sel[9]  ? holding_bank_a[9] : holding_bank_b[9];
  assign merged_bank[8]  = bank_sel[8]  ? holding_bank_a[8] : holding_bank_b[8];
  assign merged_bank[7]  = bank_sel[7]  ? holding_bank_a[7] : holding_bank_b[7];
  assign merged_bank[6]  = bank_sel[6]  ? holding_bank_a[6] : holding_bank_b[6];
  assign merged_bank[5]  = bank_sel[5]  ? holding_bank_a[5] : holding_bank_b[5];
  assign merged_bank[4]  = bank_sel[4]  ? holding_bank_a[4] : holding_bank_b[4];
  assign merged_bank[3]  = bank_sel[3]  ? holding_bank_a[3] : holding_bank_b[3];
  assign merged_bank[2]  = bank_sel[2]  ? holding_bank_a[2] : holding_bank_b[2];
  assign merged_bank[1]  = bank_sel[1]  ? holding_bank_a[1] : holding_bank_b[1];
  assign merged_bank[0]  = bank_sel[0]  ? holding_bank_a[0] : holding_bank_b[0];

  assign rot_data_part_a = ((curr_rotate[4] && ~t_pattern_q) ?
                              {merged_bank[15:0], merged_bank[31:16]}
                              : merged_bank[31:0]);
  assign rot_data_part_b = ((curr_rotate[3] && ~t_pattern_q) ?
                              {rot_data_part_a[7:0], rot_data_part_a[31:8]}
                              : rot_data_part_a[31:0]);
  assign rot_data_part_c = ((curr_rotate[2] && ~t_pattern_q) ?
                              {rot_data_part_b[3:0], rot_data_part_b[31:4]}
                              : rot_data_part_b[31:0]);
  assign rot_data_part_d = ((curr_rotate[1] && ~t_pattern_q) ?
                              {rot_data_part_c[1:0], rot_data_part_c[31:2]}
                              : rot_data_part_c[31:0]);
  assign rot_data_part_e = ((curr_rotate[0] && ~t_pattern_q) ?
                              {rot_data_part_d[0], rot_data_part_d[31:1]}
                              : rot_data_part_d[31:0]);

  assign nxt_trace_data  = (!nxt_trace_ctl                                       ) ? rot_data_part_e[31:0]  & previous_port_bit_mask
                         : (trace_trigger                                        ) ? {30'b0,~t_pattern_q, 1'b0}
                         :                                                           {30'b0,        1'b0, 1'b1}
                         ;

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_tracedata
    if (!treset_n)
      tracedata <= {31'b0, 1'b1};
    else
      tracedata <= nxt_trace_data;
  end


endmodule

