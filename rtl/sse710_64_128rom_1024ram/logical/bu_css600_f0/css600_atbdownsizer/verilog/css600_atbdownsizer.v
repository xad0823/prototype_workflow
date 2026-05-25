//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2012, 2016-2017 Arm Limited or its affiliates.
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
//   Top level of css600_atbdownsizer
//
//----------------------------------------------------------------------------


module css600_atbdownsizer #(parameter
  ATB_SLAVE_DATA_WIDTH  = 32,
  ATB_MASTER_DATA_WIDTH = 8
)
(
    clk,
    reset_n,
    atwakeup_m,
    atvalid_m,
    atready_m,
    afvalid_m,
    afready_m,
    syncreq_m,
    atid_m,
    atdata_m,
    atbytes_m,
    atwakeup_s,
    atvalid_s,
    atready_s,
    afvalid_s,
    afready_s,
    syncreq_s,
    atid_s,
    atdata_s,
    atbytes_s,
    clk_qactive
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATB_SLAVE_DATA_WIDTH_LOC =  (
                                          (ATB_SLAVE_DATA_WIDTH == 16)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 32)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 64)  ||
                                          (ATB_SLAVE_DATA_WIDTH == 128)
                                         ) ? ATB_SLAVE_DATA_WIDTH : 32;

  localparam ATB_MASTER_DATA_WIDTH_LOC = (
                                          (ATB_MASTER_DATA_WIDTH == 8)  ||
                                          (ATB_MASTER_DATA_WIDTH == 16)  ||
                                          (ATB_MASTER_DATA_WIDTH == 32)  ||
                                          (ATB_MASTER_DATA_WIDTH == 64)
                                         ) ? ATB_MASTER_DATA_WIDTH : 8;

  localparam ATBYTESS_CNT_WIDTH = atb_clog2(ATB_SLAVE_DATA_WIDTH_LOC)-3;
  localparam ATBYTESM_MAX = ATB_MASTER_DATA_WIDTH_LOC/8-1;
  localparam ATBYTESM_MAX_PLUS_ONE = ATBYTESM_MAX + 1;
  localparam ATBYTESM_MAX_PLUS_ONE_ADJUSTED = (ATB_SLAVE_DATA_WIDTH_LOC == 16) ? 1 : ATB_MASTER_DATA_WIDTH_LOC/8;

  localparam ATBYTESM_WIDTH = (ATB_MASTER_DATA_WIDTH_LOC > 8) ? (atb_clog2(ATB_MASTER_DATA_WIDTH_LOC)-4) : 0;


  input  wire                                   clk;
  input  wire                                   reset_n;

  output reg                                    atwakeup_m;

  output wire                                   atvalid_m;
  input  wire                                   atready_m;

  input  wire                                   afvalid_m;
  output wire                                   afready_m;

  input  wire                                   syncreq_m;

  output wire [6:0]                             atid_m;
  output reg [ATB_MASTER_DATA_WIDTH_LOC - 1:0]  atdata_m;
  output wire [ATBYTESM_WIDTH:0]                atbytes_m;

  input  wire                                   atwakeup_s;

  input  wire                                   atvalid_s;
  output wire                                   atready_s;

  output wire                                   afvalid_s;
  input  wire                                   afready_s;

  output wire                                   syncreq_s;

  input  wire [6:0]                             atid_s;
  input  wire [ATB_SLAVE_DATA_WIDTH_LOC - 1:0]  atdata_s;
  input  wire [ATBYTESS_CNT_WIDTH-1:0]          atbytes_s;

  output wire                                   clk_qactive;


  wire        slave_atb_hand_shake;
  wire        master_atb_hand_shake;
  reg         nxt_rem_txr;
  reg         rem_txr;

  reg  [ATBYTESS_CNT_WIDTH-1:0] nxt_atbytes_cnt;
  wire [ATBYTESS_CNT_WIDTH-1:0] nxt_atbytes_up_cnt;
  reg  [ATBYTESS_CNT_WIDTH-1:0] atbytes_up_cnt;
  reg  [ATBYTESS_CNT_WIDTH-1:0] atbytes_cnt;

  reg  [ATBYTESM_WIDTH:0] atbytesm_wide;
  reg         rst_state;


  assign slave_atb_hand_shake = atvalid_s & atready_s;
  assign master_atb_hand_shake = atvalid_m & atready_m;


  assign atvalid_m = atvalid_s;
  assign afvalid_s = afvalid_m;
  assign afready_m = afready_s;
  assign atid_m    = atid_s;
  assign syncreq_s = syncreq_m;


  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        atwakeup_m <= 1'b0;
      else
        atwakeup_m <= atwakeup_s;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        rst_state <= 1'b1;
      else
        rst_state <= 1'b0;
    end

  assign atready_s = (atvalid_s &
                    (((atbytes_cnt <= ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0]) & rem_txr) |
                     (atbytes_s <= ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0])) & atready_m)
                     & ~rst_state;


  always @(*)
  begin
    if (slave_atb_hand_shake) begin
      nxt_atbytes_cnt = {(ATBYTESS_CNT_WIDTH){1'b0}};
    end else if (atvalid_s && !atready_m && !(|atbytes_cnt) && !rem_txr) begin
      nxt_atbytes_cnt = atbytes_s;

    end else if (atvalid_s && atready_m && !(|atbytes_cnt)) begin
      nxt_atbytes_cnt = atbytes_s - ATBYTESM_MAX_PLUS_ONE_ADJUSTED[ATBYTESS_CNT_WIDTH-1:0];
    end else if ((|atbytes_cnt) && master_atb_hand_shake) begin
      nxt_atbytes_cnt = atbytes_cnt - ATBYTESM_MAX_PLUS_ONE_ADJUSTED[ATBYTESS_CNT_WIDTH-1:0];
    end else begin
      nxt_atbytes_cnt = atbytes_cnt;
    end
  end

  assign nxt_atbytes_up_cnt = atbytes_s - nxt_atbytes_cnt;

  always @(posedge clk or negedge reset_n)
    begin :  p_atbytes_cnt_seq
      if (!reset_n)
        begin
          atbytes_cnt <= {ATBYTESS_CNT_WIDTH{1'b0}};
          atbytes_up_cnt <= {ATBYTESS_CNT_WIDTH{1'b0}};
        end
      else
        begin
          atbytes_cnt <= nxt_atbytes_cnt;
          atbytes_up_cnt <= nxt_atbytes_up_cnt;
        end
    end


generate
  if (ATB_MASTER_DATA_WIDTH_LOC == 8) begin : always_atbytesm_wide_8
    assign atbytes_m = 1'b0;
  end

  if (ATB_MASTER_DATA_WIDTH_LOC == 16) begin : always_atbytesm_wide_16
    always @(*)
      begin
        if (!(|atbytes_cnt) && (atbytes_s > ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0]) && !rem_txr) begin
          atbytesm_wide = 1'b1;
        end else if (!(|atbytes_cnt)) begin
          atbytesm_wide = atbytes_s[0];
        end else if (atbytes_cnt >= ATBYTESM_MAX_PLUS_ONE) begin
          atbytesm_wide = 1'b1;
        end else begin
          atbytesm_wide = atbytes_cnt[0];
        end
      end

      assign atbytes_m = atbytesm_wide;
  end


  if (ATB_MASTER_DATA_WIDTH_LOC == 32) begin : always_atbytesm_wide_32
    always @(*)
      begin
        if (!(|atbytes_cnt) && (atbytes_s > ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0]) && !rem_txr) begin
          atbytesm_wide = 2'b11;
        end else if (!(|atbytes_cnt)) begin
          atbytesm_wide = atbytes_s[1:0];
        end else if (atbytes_cnt >= ATBYTESM_MAX_PLUS_ONE[ATBYTESS_CNT_WIDTH-1:0]) begin
          atbytesm_wide = 2'b11;
        end else begin
          atbytesm_wide = atbytes_cnt[1:0];
        end
      end

    assign atbytes_m = atbytesm_wide;
  end

  if (ATB_MASTER_DATA_WIDTH_LOC == 64) begin : always_atbytesm_wide_64
    always @(*)
      begin
        if (!(|atbytes_cnt) && (atbytes_s > ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0]) && !rem_txr) begin
          atbytesm_wide = 3'b111;
        end else if (!(|atbytes_cnt)) begin
          atbytesm_wide = atbytes_s[2:0];
        end else if (atbytes_cnt >= ATBYTESM_MAX_PLUS_ONE[ATBYTESS_CNT_WIDTH-1:0]) begin
          atbytesm_wide = 3'b111;
        end else begin
          atbytesm_wide = atbytes_cnt[2:0];
        end
      end

    assign atbytes_m = atbytesm_wide;
  end
endgenerate

  always @(*)
  begin
    if (master_atb_hand_shake && !rem_txr && !(atbytes_s <= ATBYTESM_MAX[ATBYTESS_CNT_WIDTH-1:0])) begin
      nxt_rem_txr = 1'b1;
    end else if (slave_atb_hand_shake) begin
      nxt_rem_txr = 1'b0;
    end else begin
      nxt_rem_txr = rem_txr;
    end
  end

  always @(posedge clk or negedge reset_n)
    begin : p_rem_txr_seq
      if (!reset_n)
        begin
          rem_txr <= 1'b0;
        end
      else
        begin
          rem_txr <= nxt_rem_txr;
        end
    end


generate
  if ((ATB_SLAVE_DATA_WIDTH_LOC == 16) && (ATB_MASTER_DATA_WIDTH_LOC == 8)) begin : always_slave16_master8_assig
    always @ (*)
      begin : p_atdatam_comb
        atdata_m = atdata_s[7:0];
        if (rem_txr && (atbytes_cnt == 1'b0))
          atdata_m = atdata_s[15:8];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 32) && (ATB_MASTER_DATA_WIDTH_LOC == 8)) begin : always_slave32_master8_assig_16
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          2'd3 : atdata_m = atdata_s[31:24];
          2'd2 : atdata_m = atdata_s[23:16];
          2'd1 : atdata_m = atdata_s[15:8];
          2'd0 : atdata_m = atdata_s[7:0];
          default : atdata_m = {ATB_MASTER_DATA_WIDTH_LOC{1'bx}};
        endcase
        else
          atdata_m = atdata_s[7:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 64) && (ATB_MASTER_DATA_WIDTH_LOC == 8)) begin : always_slave64_master8_assig_16
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          3'd7 : atdata_m = atdata_s[63:56];
          3'd6 : atdata_m = atdata_s[55:48];
          3'd5 : atdata_m = atdata_s[47:40];
          3'd4 : atdata_m = atdata_s[39:32];
          3'd3 : atdata_m = atdata_s[31:24];
          3'd2 : atdata_m = atdata_s[23:16];
          3'd1 : atdata_m = atdata_s[15:8];
          3'd0 : atdata_m = atdata_s[7:0];
          default : atdata_m = 8'bx;
        endcase
        else
          atdata_m = atdata_s[7:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 128) && (ATB_MASTER_DATA_WIDTH_LOC == 8)) begin : always_slave128_master8_assig
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          4'd15 : atdata_m = atdata_s[127:120];
          4'd14 : atdata_m = atdata_s[119:112];
          4'd13 : atdata_m = atdata_s[111:104];
          4'd12 : atdata_m = atdata_s[103:96];
          4'd11 : atdata_m = atdata_s[95:88];
          4'd10 : atdata_m = atdata_s[87:80];
          4'd9 : atdata_m = atdata_s[79:72];
          4'd8 : atdata_m = atdata_s[71:64];
          4'd7 : atdata_m = atdata_s[63:56];
          4'd6 : atdata_m = atdata_s[55:48];
          4'd5 : atdata_m = atdata_s[47:40];
          4'd4 : atdata_m = atdata_s[39:32];
          4'd3 : atdata_m = atdata_s[31:24];
          4'd2 : atdata_m = atdata_s[23:16];
          4'd1 : atdata_m = atdata_s[15:8];
          4'd0 : atdata_m = atdata_s[7:0];
          default : atdata_m = 8'bx;
        endcase
        else
          atdata_m = atdata_s[7:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 32) && (ATB_MASTER_DATA_WIDTH_LOC == 16)) begin : always_slave32_master16_assig
    always @ *
      begin : p_atdatam_comb
      if (rem_txr & atbytes_up_cnt[1])
        atdata_m = atdata_s[31:16];
      else
        atdata_m = atdata_s[15:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 64) && (ATB_MASTER_DATA_WIDTH_LOC == 16)) begin : always_slave64_master16_assig
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          3'd6, 3'd7 : atdata_m = atdata_s[63:48];
          3'd4, 3'd5 : atdata_m = atdata_s[47:32];
          3'd2, 3'd3 : atdata_m = atdata_s[31:16];
          3'd1, 3'd0 : atdata_m = atdata_s[15:0];
          default    : atdata_m = 16'bx;
        endcase
        else
        atdata_m = atdata_s[15:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 128) && (ATB_MASTER_DATA_WIDTH_LOC == 16)) begin : always_slave128_master16_assig
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          4'd14, 4'd15 : atdata_m = atdata_s[127:112];
          4'd12, 4'd13 : atdata_m = atdata_s[111:96];
          4'd10, 4'd11 : atdata_m = atdata_s[95:80];
          4'd8, 4'd9 : atdata_m = atdata_s[79:64];
          4'd6, 4'd7 : atdata_m = atdata_s[63:48];
          4'd4, 5'd5 : atdata_m = atdata_s[47:32];
          4'd2, 4'd3 : atdata_m = atdata_s[31:16];
          4'd1, 4'd0 : atdata_m = atdata_s[15:0];
          default    : atdata_m = 16'bx;
        endcase
        else
        atdata_m = atdata_s[15:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 64) && (ATB_MASTER_DATA_WIDTH_LOC == 32)) begin : always_slave64_master32_assig
    always @ *
      begin : p_atdatam_comb
      if (rem_txr & atbytes_up_cnt[2])
        atdata_m = atdata_s[63:32];
      else
        atdata_m = atdata_s[31:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 128) && (ATB_MASTER_DATA_WIDTH_LOC == 32)) begin : always_slave128_master32_assig
    always @ *
      begin : p_atdatam_comb
        if (rem_txr)
        case (atbytes_up_cnt)
          4'd15, 4'd14, 4'd13, 4'd12 : atdata_m = atdata_s[127:96];
          4'd11, 4'd10, 4'd9, 4'd8   : atdata_m = atdata_s[95:64];
          4'd7, 4'd6, 4'd5, 4'd4     : atdata_m = atdata_s[63:32];
          4'd3, 4'd2, 4'd1, 4'd0     : atdata_m = atdata_s[31:0];
          default                    : atdata_m = 32'bx;
        endcase
        else
        atdata_m = atdata_s[31:0];
      end
  end

  if ((ATB_SLAVE_DATA_WIDTH_LOC == 128) && (ATB_MASTER_DATA_WIDTH_LOC == 64)) begin : always_slave128_master64_assig
    always @ *
      begin : p_atdatam_comb
      if (rem_txr & atbytes_up_cnt[3])
        atdata_m = atdata_s[127:64];
      else
        atdata_m = atdata_s[63:0];
      end
  end

endgenerate

css600_or u_qactive_async (
  .in_a(atwakeup_s),
  .in_b(afvalid_m),
  .out_y(clk_qactive)
);


endmodule
