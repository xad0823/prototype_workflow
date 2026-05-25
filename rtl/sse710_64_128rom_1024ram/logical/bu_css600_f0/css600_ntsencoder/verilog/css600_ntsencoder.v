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
//   Top level of css600_ntsencoder
//
//----------------------------------------------------------------------------


module css600_ntsencoder (
  clk,
  reset_n,
  tsvalue_b_s,
  tsforcesync_s,
  tsbit_m,
  tssync_m,
  tssyncready_m
);


  input wire        clk;
  input wire        reset_n;

  input wire [63:0] tsvalue_b_s;
  input wire        tsforcesync_s;

  output reg [6:0]  tsbit_m;
  output reg [1:0]  tssync_m;
  input wire        tssyncready_m;

  parameter RESYNC_THRESHOLD = 64;

  localparam CNTZERO   = {64{1'b0}};
  localparam SYNC_MARK = 2'b00;
  localparam SYNC_BIT  = 2'b01;
  localparam SYNC_DLY  = 2'b10;
  localparam SYNC_NONE = 2'b11;
  localparam RESYNC    = {7{1'b1}};
  localparam TSBITINV  = {7{1'b0}};

  localparam BIT0_MASK = 64'hAAAA_AAAA_AAAA_AAAA;
  localparam BIT1_MASK = 64'hCCCC_CCCC_CCCC_CCCC;
  localparam BIT2_MASK = 64'hF0F0_F0F0_F0F0_F0F0;
  localparam BIT3_MASK = 64'hFF00_FF00_FF00_FF00;
  localparam BIT4_MASK = 64'hFFFF_0000_FFFF_0000;
  localparam BIT5_MASK = 64'hFFFF_FFFF_0000_0000;

  localparam RESYNC_EN = ((RESYNC_THRESHOLD) < 64 && (RESYNC_THRESHOLD > 6)) ? 1'b1 : 1'b0;
  localparam RESYNC_THRSH = 64'b1 << RESYNC_THRESHOLD;

  wire        ts_cnt_rg_en;
  wire        ts_cnt_en;
  wire [6:0]  ts_bit_nxt;
  wire        ts_bit_en;
  wire [6:0]  ts_int_sync_indx;
  wire [6:0]  ts_cnt_prev_indx;
  wire        tssync_en;
  wire        ts_aligned_indx_en;
  wire [1:0]  ts_sync_bit_info;
  wire [6:0]  ts_index;
  wire [63:0] indx;
  /*verilator lint_off UNOPTFLAT*/
  wire [62:0] indx_or;
  /*verilator lint_on UNOPTFLAT*/
  wire [63:0] indx_chg;
  wire [6:0]  ts_index_int;
  wire [6:0]  incr_val;
  wire [64:0] ts_cnt_rg_pad;

  wire        ts_resync_en;
  wire        ts_back_in_time;
  wire        ts_syncreq_rg_nxt;
  reg [6:0]  ts_aligned_indx;
  reg [63:0] ts_cnt_rg;

  reg [63:0] ts_cnt_prev;
  reg [1:0]  sync_state_nxt;
  reg [1:0]  sync_state;
  reg        sync_state_en;
  reg [1:0]  ts_sync_nxt;
  reg        ts_syncreq_rg;
  reg        ts_sync_en;
  reg [6:0]  index;


  assign ts_cnt_rg_en = (tsvalue_b_s != ts_cnt_rg);

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_cnt_rg <= CNTZERO;
      else if (ts_cnt_rg_en)
        ts_cnt_rg <= tsvalue_b_s;
    end

  assign ts_syncreq_rg_nxt = tsforcesync_s | ts_resync_en | ts_back_in_time;
  assign ts_back_in_time = (tsvalue_b_s < ts_cnt_rg);

  generate
    if (RESYNC_EN) begin: gen_resync_en
      wire ts_rollover  = (tsvalue_b_s[63] == 1'b0) & (ts_cnt_rg[63] == 1'b1);
      assign ts_resync_en = ((tsvalue_b_s - ts_cnt_rg > RESYNC_THRSH) && ~ts_rollover) ? 1'b1 : 1'b0;
    end
    else begin: gen_no_resync_en
      assign ts_resync_en = 1'b0;
    end
  endgenerate

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_syncreq_rg <= 1'b0;
      else
        ts_syncreq_rg <= ts_syncreq_rg_nxt;
    end

  assign ts_cnt_en = (ts_cnt_rg != ts_cnt_prev);

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        ts_cnt_prev <= CNTZERO;
      else if (ts_cnt_en)
        ts_cnt_prev <= ts_cnt_rg;
    end


  assign indx_chg[63]    = (ts_cnt_rg[63] ^ ts_cnt_prev[63]);
  assign indx_chg[62]    = (ts_cnt_rg[62] ^ ts_cnt_prev[62]);

  assign indx_or[62] = indx_chg[63];
  assign indx_or[61] = indx_or[62] | indx_chg[62];

  genvar i;
  generate
   for (i = 0; i < 62; i = i+1)
     begin : gen_indx_chg
       assign indx_chg[i] = (ts_cnt_rg[i] ^ ts_cnt_prev[i]);
     end
   for (i = 0; i < 61; i = i+1)
     begin : gen_indx_or
       assign indx_or[i]  = indx_or[i+1] | indx_chg[i+1];
     end
  endgenerate

  assign indx = {indx_chg[63], (indx_chg[62:0] & ~indx_or[62:0])};

  assign ts_index_int[0] = |(indx & BIT0_MASK);
  assign ts_index_int[1] = |(indx & BIT1_MASK);
  assign ts_index_int[2] = |(indx & BIT2_MASK);
  assign ts_index_int[3] = |(indx & BIT3_MASK);
  assign ts_index_int[4] = |(indx & BIT4_MASK);
  assign ts_index_int[5] = |(indx & BIT5_MASK);
  assign ts_index_int[6] = 1'b0;

  assign incr_val = (ts_index_int[5:0] == {6{1'b0}}) ?
                      {{6{1'b0}},indx[0]} :
                        {{6{1'b0}},1'b1};

  assign ts_index = ts_index_int + incr_val;

  assign ts_bit_nxt = ts_syncreq_rg ? RESYNC : ts_index;

  assign ts_bit_en = ts_cnt_en |
                     ts_syncreq_rg |
                     ((tsbit_m != TSBITINV) && (ts_bit_nxt == TSBITINV));


  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      tsbit_m <= {7{1'b0}};
    end else if (ts_bit_en) begin
      tsbit_m <= ts_bit_nxt;
    end

  assign ts_int_sync_indx = (
                              (tssync_m == 2'b01) || (tsbit_m == RESYNC) ||
                              (tssyncready_m &
                                  (
                                    (
                                     (ts_bit_nxt >= ts_aligned_indx)
                                     &
                                     (ts_bit_nxt != RESYNC)
                                    )
                                    ||
                                      (
                                        (ts_aligned_indx == 7'b1) & (ts_bit_nxt == 7'b0)
                                      )
                                  )
                              )
                            ) ?
                               7'd64 :
                                 (ts_aligned_indx > 7'b1 ? ts_aligned_indx - 7'd1 : ts_aligned_indx);

  assign ts_aligned_indx_en = tssyncready_m | (tssync_m == 2'b01);

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      ts_aligned_indx <= 7'd64;
    end else if (ts_aligned_indx_en) begin
      ts_aligned_indx <= ts_int_sync_indx;
    end


  assign ts_cnt_prev_indx =  ts_int_sync_indx;
  assign ts_cnt_rg_pad    = {ts_cnt_rg,1'b0};

  always @(ts_cnt_prev_indx)
  begin
    if (ts_cnt_prev_indx >= 7'd64)
      index = 7'd64;


    else
      index = ts_cnt_prev_indx;
  end

  assign ts_sync_bit_info = {1'b1, ts_cnt_rg_pad[index]};

  always @(*)
    begin
      sync_state_en = 1'b1;
      sync_state_nxt = sync_state;
      ts_sync_en = 1'b0;
      ts_sync_nxt = tssync_m;

      case (sync_state)
        SYNC_MARK : begin
          if (ts_bit_nxt == RESYNC) begin
            sync_state_nxt = SYNC_DLY;
            ts_sync_nxt = ts_sync_bit_info;
          end else if (tssyncready_m) begin
            ts_sync_nxt = (tssync_m == 2'b01) ? ts_sync_bit_info : 2'b01;
            sync_state_nxt = SYNC_BIT;
          end else begin
            ts_sync_nxt = tssync_m;
            sync_state_en = 1'b0;
          end
        end
        SYNC_BIT : begin
          if (ts_bit_nxt > ts_aligned_indx) begin
            if (ts_bit_nxt == RESYNC) begin
              sync_state_nxt = SYNC_DLY;
              if (tssyncready_m && (ts_aligned_indx == 7'b1))
                ts_sync_nxt = 2'b01;
              else
                ts_sync_nxt = ts_sync_bit_info;
            end else if (tssyncready_m) begin
              sync_state_nxt = SYNC_BIT;
              ts_sync_nxt = 2'b01;
            end else begin
              sync_state_nxt = SYNC_MARK;
              ts_sync_nxt = 2'b01;
              ts_sync_en = 1'b1;
            end
          end else begin
            if ((((ts_bit_nxt == ts_aligned_indx) & (tssync_m != 2'b01)) | (ts_aligned_indx == 7'b1)) && tssyncready_m) begin
                sync_state_nxt = SYNC_BIT;
                ts_sync_nxt = 2'b01;
              end else begin
                ts_sync_nxt = ts_sync_bit_info;
                sync_state_en = 1'b0;
              end
          end
        end
        SYNC_DLY : begin
          ts_sync_nxt = 2'b01;
          ts_sync_en = 1'b1;
          if (ts_bit_nxt == RESYNC) begin
            sync_state_nxt = SYNC_DLY;
          end else if (tssyncready_m) begin
            sync_state_nxt = SYNC_BIT;
          end else begin
            sync_state_nxt = SYNC_MARK;
          end
        end
        SYNC_NONE: sync_state_nxt = SYNC_MARK;
        default : begin
                    ts_sync_nxt     = {2{1'bx}};
                    ts_sync_en      = 1'bx;
                    sync_state_nxt  = {2{1'bx}};
                    sync_state_en   = 1'bx;
                  end
      endcase
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      sync_state <= SYNC_MARK;
    end else if (sync_state_en) begin
      sync_state <= sync_state_nxt;
    end

  assign tssync_en = tssyncready_m | ts_sync_en;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      tssync_m <= {2{1'b0}};
    end else if (tssync_en) begin
      tssync_m <= ts_sync_nxt;
    end


endmodule

