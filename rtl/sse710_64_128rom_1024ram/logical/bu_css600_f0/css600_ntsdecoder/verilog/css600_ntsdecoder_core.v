//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2013, 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_ntsdecoder
//
//----------------------------------------------------------------------------


module css600_ntsdecoder_core (

  input wire        clk,
  input wire        reset_n,

  input wire [6:0]  tsbit,
  input wire [1:0]  tssync,
  output wire       tssyncready,

  output wire [63:0] tsvalue,

  input  lp_req,
  output lp_ack

  );

function automatic [63:0] indx_2_cnt;
  input [63:0] ts_cnt;
  input [6:0] ts_indx;
  reg [6:0] ts_act_indx;
  integer bit_indx;

  begin
    if (ts_indx == {7{1'b0}})
      ts_act_indx = {7{1'b0}};
    else if (ts_indx == {7{1'b1}})
      ts_act_indx = {7{1'b0}};
    else
      ts_act_indx = ts_indx - {{6{1'b0}}, 1'b1};

    for(bit_indx = 0; bit_indx <= 63; bit_indx = bit_indx + 1)
      if (bit_indx[6:0] < ts_act_indx)
        indx_2_cnt[bit_indx] = 1'b0;
      else if (bit_indx[6:0] == ts_act_indx)
        indx_2_cnt[bit_indx] = 1'b1;
      else
        indx_2_cnt[bit_indx] = ts_cnt[bit_indx];
  end
endfunction

function automatic [63:0] indx_2_bit;
  input [63:0]  ts_cnt;
  input [5:0]   ts_bit;
  input         bit_val;
  reg [63:0]    indx_dec_en;
  integer       bit_indx;
  integer       indx_cnt;

  begin
    for(bit_indx = 0; bit_indx <= 63; bit_indx = bit_indx + 1)
      if (ts_bit == bit_indx[5:0])
        indx_dec_en[bit_indx] = 1'b1;
      else
        indx_dec_en[bit_indx] = 1'b0;

    for(indx_cnt = 63; indx_cnt >= 0; indx_cnt = indx_cnt - 1)
      if (indx_dec_en[indx_cnt])
        indx_2_bit[indx_cnt] = bit_val;
      else
        indx_2_bit[indx_cnt] = ts_cnt[indx_cnt];
  end
endfunction

  localparam ST_MARK    = 3'b010;
  localparam ST_SYNC    = 3'b001;
  localparam ST_CNT     = 3'b000;
  localparam ST_CNT_DLY = 3'b100;
  localparam ST_DISCARD = 3'b011;

  localparam ST_UNUSED1 = 3'b101;
  localparam ST_UNUSED2 = 3'b110;
  localparam ST_UNUSED3 = 3'b111;

  localparam DISCARD_SYNC = 7'd72;

  localparam RESYNC    = {7{1'b1}};

  localparam CNTZERO   = {64{1'b0}};

  wire          ts_bit_en;
  wire  [63:0]  ts_cnt_indx_2_cnt;
  wire          quiescence;
  wire  [63:0]  temp_tsvalue_int_nxt;
  wire          lp_req_en;

  wire          ts_enc_sync_en;
  wire  [6:0]   ts_max_bit_nxt;

  wire  [63:0]  sync_value;
  wire [63:0]   ts_enc_sync_one_nxt;
  wire [63:0]   ts_enc_sync_zero_nxt;


  reg [5:0]  ts_int_indx_nxt;
  reg [5:0]  ts_int_indx;
  reg        ts_int_indx_en;
  reg [2:0]  sync_fsm_nxt;
  reg [2:0]  sync_fsm;
  reg [63:0] tsvalue_int;

  reg [63:0] tsvalue_int_nxt;
  reg        tsvalue_int_en;
  reg [6:0]  ts_bit_rg;
  reg        ts_bit_valid_rg;
  reg [1:0]  ts_sync_rg;

  reg        lp_ack_rg;

  reg [6:0]  ts_max_bit;
  reg [63:0] ts_enc_sync_one;
  reg [63:0] ts_enc_sync_zero;

  reg [6:0]  disc_cnt;
  reg [6:0]  disc_cnt_nxt;

  reg [3:0]  cnt_dly;
  reg [3:0]  cnt_dly_nxt;


  assign lp_req_en = (lp_ack_rg != lp_req);

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        lp_ack_rg <= 1'b1;
      else if (lp_req_en)
      begin
        lp_ack_rg <= lp_req;
      end
    end

  assign lp_ack = lp_ack_rg;
  assign quiescence = lp_ack_rg & lp_req;

  assign ts_bit_en = (tsbit != {7{1'b0}});

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_bit_rg <= {7{1'b0}};
      else if (quiescence)
        ts_bit_rg <= {7{1'b0}};
      else if (ts_bit_en)
        ts_bit_rg <= tsbit;
    end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_bit_valid_rg <= 1'b0;
      else
        ts_bit_valid_rg <= ts_bit_en;
    end


  always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
      disc_cnt <= 7'b0;
    else if ((sync_fsm != ST_DISCARD) || quiescence)
      disc_cnt <= 7'b0;
    else
      disc_cnt <= disc_cnt_nxt;
  end

  always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
      cnt_dly <= 4'b0;
    else if ((sync_fsm == ST_CNT) || quiescence)
      cnt_dly <= 4'b0;
    else
      cnt_dly <= cnt_dly_nxt;
  end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_sync_rg <= {2{1'b0}};
      else if (quiescence)
        ts_sync_rg <= {2{1'b0}};
      else
        ts_sync_rg <= tssync;
    end

  assign ts_enc_sync_en = (sync_fsm != ST_CNT);
  assign ts_max_bit_nxt = (ts_bit_rg == {7{1'b1}}) ? ts_max_bit : (ts_bit_rg > ts_max_bit ? ts_bit_rg : ts_max_bit);

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          ts_enc_sync_one  <= {{64{1'b1}}};
          ts_enc_sync_zero <= {{64{1'b0}}};
          ts_max_bit       <= {7{1'b0}};
        end
      else if ((ts_bit_rg == RESYNC) || quiescence)
        begin
          ts_enc_sync_one  <= {{64{1'b1}}};
          ts_enc_sync_zero <= {{64{1'b0}}};
          ts_max_bit       <= {7{1'b0}};
        end
      else if (ts_enc_sync_en)
        begin
          ts_enc_sync_one  <= ts_enc_sync_one_nxt;
          ts_enc_sync_zero <= ts_enc_sync_zero_nxt;
          ts_max_bit       <= ts_max_bit_nxt;
        end
    end


  assign ts_enc_sync_one_nxt  = indx_2_cnt(ts_enc_sync_one,ts_bit_rg);
  assign ts_enc_sync_zero_nxt = indx_2_cnt(ts_enc_sync_zero,ts_bit_rg);

  assign sync_value       = (temp_tsvalue_int_nxt & ts_enc_sync_one_nxt) | ts_enc_sync_zero_nxt;

  assign ts_cnt_indx_2_cnt = indx_2_cnt(tsvalue_int,ts_bit_rg);
  assign temp_tsvalue_int_nxt = ts_sync_rg[1] ? indx_2_bit(tsvalue_int,ts_int_indx,ts_sync_rg[0]) : tsvalue_int;

  always @(*)
    begin
      disc_cnt_nxt = disc_cnt;
      cnt_dly_nxt = cnt_dly;
      case (sync_fsm)
        ST_DISCARD : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en  = 1'b0;

          tsvalue_int_nxt = CNTZERO;
          tsvalue_int_en  = 1'b0;
          if (ts_bit_valid_rg && (ts_bit_rg == {7{1'b1}})) begin
            disc_cnt_nxt = 7'b0;
            sync_fsm_nxt = ST_DISCARD;
          end
          else if (disc_cnt < DISCARD_SYNC) begin
            disc_cnt_nxt = ts_sync_rg == 2'b0 ? disc_cnt : (disc_cnt + 7'b1);
            sync_fsm_nxt = ST_DISCARD;
          end
          else begin
            disc_cnt_nxt = 7'b0;
            sync_fsm_nxt = ST_MARK;
          end
        end
        ST_MARK : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en  = 1'b0;

          tsvalue_int_nxt = CNTZERO;
          tsvalue_int_en  = (ts_max_bit_nxt == 7'h40);
          if (ts_bit_valid_rg && (ts_bit_rg == {7{1'b1}}))
            begin
              sync_fsm_nxt = ST_DISCARD;
            end
          else if (ts_sync_rg == 2'b01)
            begin
              sync_fsm_nxt = tsvalue_int_en ? ST_CNT : ST_SYNC;
              tsvalue_int_nxt = (tsvalue_int_en) ? sync_value : tsvalue_int;
            end
          else
            begin
              sync_fsm_nxt = ST_MARK;
            end
        end
        ST_SYNC : begin
          if (ts_bit_valid_rg && (ts_bit_rg == {7{1'b1}}))
            begin
              ts_int_indx_nxt = 6'd63;
              ts_int_indx_en = 1'b1;
              tsvalue_int_nxt = CNTZERO;
              tsvalue_int_en = 1'b1;
              sync_fsm_nxt = ST_DISCARD;
            end
          else if (ts_max_bit_nxt > {1'b0,ts_int_indx})
            begin
              ts_int_indx_nxt = 6'd63;
              ts_int_indx_en = 1'b1;
              tsvalue_int_nxt = sync_value;
              tsvalue_int_en = 1'b1;
              sync_fsm_nxt = ST_CNT_DLY;
            end
          else if ((ts_int_indx > 6'd0) && (ts_max_bit_nxt == {1'b0,ts_int_indx}) && ts_sync_rg[1] )
            begin
              ts_int_indx_nxt = 6'd63;
              ts_int_indx_en = 1'b1;
              tsvalue_int_nxt = sync_value;
              tsvalue_int_en = 1'b1;
              sync_fsm_nxt = ST_CNT_DLY;
            end
          else
            begin
              case (ts_sync_rg)
                2'b00 : begin
                  ts_int_indx_nxt = ts_int_indx;
                  ts_int_indx_en = 1'b0;
                  tsvalue_int_nxt = tsvalue_int;
                  tsvalue_int_en = 1'b0;
                  sync_fsm_nxt = ST_SYNC;
                end
                2'b01 : begin
                  ts_int_indx_nxt = 6'd63;
                  ts_int_indx_en = 1'b1;
                  tsvalue_int_nxt = CNTZERO;
                  tsvalue_int_en = 1'b1;
                  sync_fsm_nxt = ST_SYNC;
                end
                2'b10, 2'b11 : begin
                  ts_int_indx_nxt = ts_int_indx - 6'd1;
                  ts_int_indx_en = 1'b1;
                  tsvalue_int_nxt = temp_tsvalue_int_nxt;
                  tsvalue_int_en = 1'b1;
                  sync_fsm_nxt = (ts_int_indx == 6'h00) ? ST_CNT_DLY : ST_SYNC;
                end
                default : begin
                  ts_int_indx_nxt = {6{1'bx}};
                  ts_int_indx_en = 1'b1;
                  tsvalue_int_nxt = {64{1'bx}};
                  tsvalue_int_en = 1'bx;
                  sync_fsm_nxt = 3'bxxx;
                end
              endcase
            end
        end

        ST_CNT_DLY : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en = 1'b0;
          if (ts_bit_valid_rg && (ts_bit_rg == {7{1'b1}}))
            begin
              tsvalue_int_nxt = CNTZERO;
              tsvalue_int_en = 1'b1;
              sync_fsm_nxt = ST_DISCARD;
              cnt_dly_nxt = 4'b0000;
            end
          else if (cnt_dly < 4'b1111) begin
              tsvalue_int_en = 1'b1;
              tsvalue_int_nxt = ts_cnt_indx_2_cnt;
              sync_fsm_nxt = ST_CNT_DLY;
              cnt_dly_nxt = ts_bit_valid_rg ? (cnt_dly + 4'b1) : cnt_dly;
            end
          else
            begin
              tsvalue_int_en = ts_bit_valid_rg;
              tsvalue_int_nxt = ts_cnt_indx_2_cnt;
              cnt_dly_nxt = 4'b0000;
              sync_fsm_nxt = ST_CNT;
            end
        end

        ST_CNT : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en = 1'b0;
          if (ts_bit_valid_rg && (ts_bit_rg == {7{1'b1}}))
            begin
              tsvalue_int_nxt = CNTZERO;
              tsvalue_int_en = 1'b1;
              sync_fsm_nxt = ST_DISCARD;
            end
          else
            begin
              tsvalue_int_nxt = ts_cnt_indx_2_cnt;
              tsvalue_int_en = ts_bit_valid_rg;
              sync_fsm_nxt = ST_CNT;
            end
        end

        ST_UNUSED1 : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en  = 1'b0;
          tsvalue_int_nxt = CNTZERO;
          tsvalue_int_en  = 1'b0;
          sync_fsm_nxt    = ST_DISCARD;
          disc_cnt_nxt    = 7'b0;
        end

        ST_UNUSED2 : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en  = 1'b0;
          tsvalue_int_nxt = CNTZERO;
          tsvalue_int_en  = 1'b0;
          sync_fsm_nxt    = ST_DISCARD;
          disc_cnt_nxt    = 7'b0;
        end

        ST_UNUSED3 : begin
          ts_int_indx_nxt = 6'd63;
          ts_int_indx_en  = 1'b0;
          tsvalue_int_nxt = CNTZERO;
          tsvalue_int_en  = 1'b0;
          sync_fsm_nxt    = ST_DISCARD;
          disc_cnt_nxt    = 7'b0;
        end

        default : begin
          ts_int_indx_nxt = {6{1'bx}};
          ts_int_indx_en = 1'bx;
          tsvalue_int_nxt = {64{1'bx}};
          tsvalue_int_en = 1'bx;
          sync_fsm_nxt = 3'bxxx;
          disc_cnt_nxt = 7'bxxxxxxx;
          cnt_dly_nxt = 4'bxxxx;
        end
      endcase
    end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_int_indx <= 6'd63;
      else if (quiescence)
        ts_int_indx <= 6'd63;
      else if (ts_int_indx_en)
        ts_int_indx <= ts_int_indx_nxt;
    end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        sync_fsm <= ST_DISCARD;
      else if (quiescence)
        sync_fsm <= ST_DISCARD;
      else
        sync_fsm <= sync_fsm_nxt;
    end

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        tsvalue_int <= CNTZERO;
      else if (quiescence)
        tsvalue_int <= CNTZERO;
      else if (tsvalue_int_en)
        tsvalue_int <= tsvalue_int_nxt;
    end


  assign tsvalue = (sync_fsm == ST_CNT) ? tsvalue_int : 64'b0;

  assign tssyncready = 1'b1;


endmodule
