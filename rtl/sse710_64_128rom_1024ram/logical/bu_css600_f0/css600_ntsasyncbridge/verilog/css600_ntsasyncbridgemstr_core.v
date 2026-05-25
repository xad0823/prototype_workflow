//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_ntsasyncbridge
//
//----------------------------------------------------------------------------


module css600_ntsasyncbridgemstr_core# (parameter
  FF_SYNC_DEPTH = 2,
  FIFO_DEPTH    = 6
)

(
  input wire        clkm,
  input wire        resetmn,

  output wire [6:0] tsbitm,
  output wire [1:0] tssyncm,
  input wire        tssyncreadym,

  output wire [3:0] nts_rd_ptr_gry_m,
  output wire [3:0] syn_rd_ptr_gry_m,

  input wire  [3:0] nts_wr_ptr_gry_m,
  input wire  [3:0] syn_wr_ptr_gry_m,

  input wire  [FIFO_DEPTH*7-1:0] nts_encd_data_m,

  input wire  [FIFO_DEPTH*2-1:0] syn_encd_data_m,

  input wire  pwr_lp_req,

  input  wire clk_lp_req,
  output reg  clk_lp_done,

  output wire master_stopped

  );


  localparam LPI_IDLE            = 2'b00;
  localparam INSERT_RESYNC       = 2'b01;
  localparam LPI_STOPPED         = 2'b11;
  localparam LPI_FLUSH_FIFO      = 2'b10;


  wire syn_ready_to_flush;
  wire nts_ready_to_flush;

  wire [1:0] ts_sync_m_next;
  wire [6:0] nts_d_lvl_0_mux_0;
  wire [6:0] nts_d_lvl_0_mux_1;
  wire [1:0] syn_d_lvl_0_mux_0;
  wire [1:0] syn_d_lvl_0_mux_1;


  wire       nts_async_fifo_empty;
  wire       nts_async_fifo_flushed;
  wire       nts_async_fifo_full;
  wire       nts_rd_req;
  wire [3:0] nts_wr_ptr_gry_m_sync;
  wire       nts_roll_over;
  wire [2:0] nts_rd_ptr_bin;
  wire [6:0] nts_encd_data;

  wire       syn_async_fifo_empty;
  wire       syn_async_fifo_flushed;
  wire       syn_async_fifo_full;
  wire       syn_rd_req;
  wire [3:0] syn_wr_ptr_gry_m_sync;
  wire       syn_roll_over;
  wire [2:0] syn_rd_ptr_bin;
  wire [1:0] syn_encd_data;

  wire       tsbitm_en;
  wire       ts_sync_en;
  wire [6:0] nxt_nts_encd_data;

  wire nts_flush_roll_over;
  wire syn_flush_roll_over;


  reg [6:0] tsbitm_next;


  reg [3:0] nts_incr_ptr_gry;
  reg [3:0] nts_gry_to_bin;
  reg [3:0] nts_wr_ptr_gry_m_sync_d;
  reg [3:0] nts_wr_ptr_gry_m_to_bin;
  reg [3:0] nts_rd_ptr_gry_m_next;
  reg [3:0] nts_rd_ptr_gry_m_q;

  reg [3:0] nts_wr_ptr_snapshot;
  reg [3:0] nts_wr_ptr_snapshot_bin;

  reg [3:0] syn_incr_ptr_gry;
  reg [3:0] syn_gry_to_bin;
  reg [3:0] syn_wr_ptr_gry_m_sync_d;
  reg [3:0] syn_wr_ptr_gry_m_to_bin;
  reg [3:0] syn_rd_ptr_gry_m_next;
  reg [3:0] syn_rd_ptr_gry_m_q;

  reg [3:0] syn_wr_ptr_snapshot;
  reg [3:0] syn_wr_ptr_snapshot_bin;
  reg [1:0] lpi_state;
  reg [1:0] nxt_lpi_state;
  reg       nxt_clk_lp_done;


`include "css600_ntsasyncbridge_functions.v"


  assign nts_roll_over = nts_rd_ptr_gry_m_q[3] ^ nts_wr_ptr_gry_m_sync[3];

  assign syn_roll_over = syn_rd_ptr_gry_m_q[3] ^ syn_wr_ptr_gry_m_sync[3];

  assign nts_flush_roll_over = nts_rd_ptr_gry_m_q[3] ^ nts_wr_ptr_snapshot[3];
  assign syn_flush_roll_over = syn_rd_ptr_gry_m_q[3] ^ syn_wr_ptr_snapshot[3];

  assign nts_async_fifo_empty = (nts_gry_to_bin == nts_wr_ptr_gry_m_to_bin) & ~nts_roll_over;
  assign nts_async_fifo_flushed = (nts_gry_to_bin == nts_wr_ptr_snapshot_bin) & ~nts_flush_roll_over;
  assign nts_async_fifo_full  = ((nts_gry_to_bin == nts_wr_ptr_gry_m_to_bin) & nts_roll_over);

  assign syn_async_fifo_empty = (syn_gry_to_bin == syn_wr_ptr_gry_m_to_bin) & ~syn_roll_over;
  assign syn_async_fifo_flushed = (syn_gry_to_bin == syn_wr_ptr_snapshot_bin) & ~syn_flush_roll_over;
  assign syn_async_fifo_full  = ((syn_gry_to_bin == syn_wr_ptr_gry_m_to_bin) & syn_roll_over);


  generate
  if (FIFO_DEPTH == 6) begin: gray_inc_fifo6

    always @(*)
      begin
        nts_incr_ptr_gry = gray_inc_6(nts_rd_ptr_gry_m_q);
        syn_incr_ptr_gry = gray_inc_6(syn_rd_ptr_gry_m_q);
      end
  end
  if (FIFO_DEPTH == 8) begin: gray_inc_fifo8

    always @(*)
      begin
        nts_incr_ptr_gry = gray_inc_8(nts_rd_ptr_gry_m_q);
        syn_incr_ptr_gry = gray_inc_8(syn_rd_ptr_gry_m_q);
      end
  end
  endgenerate

  assign nts_rd_req = ~nts_async_fifo_empty & ~(pwr_lp_req | lpi_state == LPI_STOPPED);
  assign syn_rd_req = ~syn_async_fifo_empty & ~(pwr_lp_req | lpi_state == LPI_STOPPED) & (tssyncreadym | lpi_state == LPI_FLUSH_FIFO);

  always @(*)
  begin
    nts_rd_ptr_gry_m_next = nts_rd_ptr_gry_m_q;
    syn_rd_ptr_gry_m_next = syn_rd_ptr_gry_m_q;


    if (~nts_async_fifo_empty && nts_rd_req) begin
      nts_rd_ptr_gry_m_next = nts_incr_ptr_gry;
    end

    if (~syn_async_fifo_empty && syn_rd_req) begin
      syn_rd_ptr_gry_m_next = syn_incr_ptr_gry;
    end
  end

  always @(posedge clkm or negedge resetmn)
    begin
      if (!resetmn)
      begin
        nts_rd_ptr_gry_m_q <= {4{1'b0}};
        syn_rd_ptr_gry_m_q <= {4{1'b0}};
      end
      else if (pwr_lp_req)
      begin
        nts_rd_ptr_gry_m_q <= {4{1'b0}};
        syn_rd_ptr_gry_m_q <= {4{1'b0}};
      end
      else
      begin
        nts_rd_ptr_gry_m_q <= nts_rd_ptr_gry_m_next;
        syn_rd_ptr_gry_m_q <= syn_rd_ptr_gry_m_next;
      end
    end

  assign nts_rd_ptr_gry_m = nts_rd_ptr_gry_m_q;
  assign syn_rd_ptr_gry_m = syn_rd_ptr_gry_m_q;


  genvar i;
  generate
  for (i=0; i<4; i=i+1) begin: gen_wr_ptr_sync
    css600_cdc_capt_sync #(
      .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
    )
    u_cdc_sync_nts_wr_ptr_gry_m0
    (
      .clk       (clkm),
      .reset_n   (resetmn),
      .d_async_i (nts_wr_ptr_gry_m[i]),
      .q_sync_o  (nts_wr_ptr_gry_m_sync[i])
    );

    css600_cdc_capt_sync #(
      .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
    )
    u_cdc_sync_syn_wr_ptr_gry_m0
    (
      .clk       (clkm),
      .reset_n   (resetmn),
      .d_async_i (syn_wr_ptr_gry_m[i]),
      .q_sync_o  (syn_wr_ptr_gry_m_sync[i])
    );
  end
  endgenerate

  generate
  if (FIFO_DEPTH == 6) begin: gray_to_bin_read_fifo6

      always @(*)
      begin
        nts_wr_ptr_gry_m_to_bin = gray_to_bin_6(nts_wr_ptr_gry_m_sync);
        syn_wr_ptr_gry_m_to_bin = gray_to_bin_6(syn_wr_ptr_gry_m_sync);
        nts_wr_ptr_snapshot_bin = gray_to_bin_6(nts_wr_ptr_snapshot);
        syn_wr_ptr_snapshot_bin = gray_to_bin_6(syn_wr_ptr_snapshot);
      end
  end
  if (FIFO_DEPTH == 8) begin: gray_to_bin_read_fifo8

      always @(*)
      begin
        nts_wr_ptr_gry_m_to_bin = gray_to_bin_8(nts_wr_ptr_gry_m_sync);
        syn_wr_ptr_gry_m_to_bin = gray_to_bin_8(syn_wr_ptr_gry_m_sync);
        nts_wr_ptr_snapshot_bin = gray_to_bin_8(nts_wr_ptr_snapshot);
        syn_wr_ptr_snapshot_bin = gray_to_bin_8(syn_wr_ptr_snapshot);
    end
  end
  endgenerate


  generate
  for (i=0; i<7; i=i+1) begin: gen_dmux_lvl_0
    css600_mux4 u_lvl_0_mux_0 (
      .din1_async (nts_encd_data_m[i+0]),
      .din2_async (nts_encd_data_m[i+7]),
      .din3_async (nts_encd_data_m[i+14]),
      .din4_async (nts_encd_data_m[i+21]),
      .sel        (nts_rd_ptr_bin[1:0]),
      .dout_async (nts_d_lvl_0_mux_0[i]));
    if (FIFO_DEPTH == 6) begin: gen_mux0_sync_depth_2
      css600_mux4 u_lvl_0_mux_1 (
        .din1_async (nts_encd_data_m[i+28]),
        .din2_async (nts_encd_data_m[i+35]),
        .din3_async (1'b0),
        .din4_async (1'b0),
        .sel        (nts_rd_ptr_bin[1:0]),
        .dout_async (nts_d_lvl_0_mux_1[i]));
    end
    else begin: gen_mux0_sync_depth_3
      css600_mux4 u_lvl_0_mux_1 (
        .din1_async (nts_encd_data_m[i+28]),
        .din2_async (nts_encd_data_m[i+35]),
        .din3_async (nts_encd_data_m[i+42]),
        .din4_async (nts_encd_data_m[i+49]),
        .sel        (nts_rd_ptr_bin[1:0]),
        .dout_async (nts_d_lvl_0_mux_1[i]));
    end
   end
 endgenerate

  generate
  for (i=0; i<7; i=i+1) begin: gen_dmux_lvl_1
    css600_mux2 u_lvl_1_dmux (
      .din1_async (nts_d_lvl_0_mux_0[i]),
      .din2_async (nts_d_lvl_0_mux_1[i]),
      .sel        (nts_rd_ptr_bin[2]),
      .dout_async (nts_encd_data[i]));
  end
  endgenerate

  generate
  for (i=0; i<2; i=i+1) begin: gen_smux_lvl_0
    css600_mux4 u_bit_7_lvl_0_mux_0 (
      .din1_async (syn_encd_data_m[i+0]),
      .din2_async (syn_encd_data_m[i+2]),
      .din3_async (syn_encd_data_m[i+4]),
      .din4_async (syn_encd_data_m[i+6]),
      .sel        (syn_rd_ptr_bin[1:0]),
      .dout_async (syn_d_lvl_0_mux_0[i]));
    if (FIFO_DEPTH == 6) begin: gen_smux_sync_depth_2
      css600_mux4 u_lvl_0_mux_1 (
        .din1_async (syn_encd_data_m[i+8]),
        .din2_async (syn_encd_data_m[i+10]),
        .din3_async (1'b0),
        .din4_async (1'b0),
        .sel        (syn_rd_ptr_bin[1:0]),
        .dout_async (syn_d_lvl_0_mux_1[i]));
    end
    else begin: gen_smux_sync_depth_3
      css600_mux4 u_lvl_0_mux_1 (
        .din1_async (syn_encd_data_m[i+8]),
        .din2_async (syn_encd_data_m[i+10]),
        .din3_async (syn_encd_data_m[i+12]),
        .din4_async (syn_encd_data_m[i+14]),
        .sel        (syn_rd_ptr_bin[1:0]),
        .dout_async (syn_d_lvl_0_mux_1[i]));
    end
  end
  endgenerate

  generate
  for (i=0; i<2; i=i+1) begin: gen_smux_lvl_1
    css600_mux2 u_lvl_1_smux (
      .din1_async (syn_d_lvl_0_mux_0[i]),
      .din2_async (syn_d_lvl_0_mux_1[i]),
      .sel        (syn_rd_ptr_bin[2]),
      .dout_async (syn_encd_data[i]));
  end
  endgenerate

generate
  if (FIFO_DEPTH == 6) begin: gry_to_bin_read_fifo6
    always @(*)
      begin
      nts_gry_to_bin = gray_to_bin_6(nts_rd_ptr_gry_m_q);
      syn_gry_to_bin = gray_to_bin_6(syn_rd_ptr_gry_m_q);
    end
  end
  if (FIFO_DEPTH == 8) begin: gry_to_bin_read_fifo8
    always @(*)
      begin
      nts_gry_to_bin = gray_to_bin_8(nts_rd_ptr_gry_m_q);
      syn_gry_to_bin = gray_to_bin_8(syn_rd_ptr_gry_m_q);
    end
  end
endgenerate

  assign nts_rd_ptr_bin = nts_gry_to_bin[2:0];
  assign syn_rd_ptr_bin = syn_gry_to_bin[2:0];

  assign nxt_nts_encd_data = (lpi_state == INSERT_RESYNC) ? {7{1'b1}} : ({7{~nts_async_fifo_empty}} & nts_encd_data);

  always @(*)
  begin
    tsbitm_next = tsbitm;

    case (pwr_lp_req | clk_lp_req | lpi_state[1])

      1'b0 : tsbitm_next = nxt_nts_encd_data;

      1'b1 : tsbitm_next = {7{1'b0}};

      default : tsbitm_next = 7'bxxxxxxx;
    endcase
  end

  assign tsbitm_en = (tsbitm != tsbitm_next) && !lpi_state[1];


  assign syn_ready_to_flush  = (syn_wr_ptr_gry_m_sync  == syn_wr_ptr_gry_m_sync_d) & syn_async_fifo_full;
  assign nts_ready_to_flush  = (nts_wr_ptr_gry_m_sync  == nts_wr_ptr_gry_m_sync_d) & nts_async_fifo_full;

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      nts_wr_ptr_snapshot <= 4'b0;
    else if (pwr_lp_req)
      nts_wr_ptr_snapshot <= 4'b0;
    else if (nts_ready_to_flush)
      nts_wr_ptr_snapshot <= nts_wr_ptr_gry_m_sync;
  end

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      syn_wr_ptr_snapshot <= 4'b0;
    else if (pwr_lp_req)
      syn_wr_ptr_snapshot <= 4'b0;
    else if (syn_ready_to_flush)
      syn_wr_ptr_snapshot <= syn_wr_ptr_gry_m_sync;
  end

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      nts_wr_ptr_gry_m_sync_d <= 4'b0;
    else if (pwr_lp_req)
      nts_wr_ptr_gry_m_sync_d <= 4'b0;
    else
      nts_wr_ptr_gry_m_sync_d <= nts_wr_ptr_gry_m_sync;
  end

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      syn_wr_ptr_gry_m_sync_d <= 4'b0;
    else if (pwr_lp_req)
      syn_wr_ptr_gry_m_sync_d <= 4'b0;
    else
      syn_wr_ptr_gry_m_sync_d <= syn_wr_ptr_gry_m_sync;
  end


  always @*
  begin
      nxt_lpi_state = lpi_state;
      nxt_clk_lp_done = clk_lp_done;

    case (lpi_state)

      LPI_IDLE: begin
        if (clk_lp_req) begin
          nxt_lpi_state = LPI_STOPPED;
          nxt_clk_lp_done = 1'b1;
        end
        else begin
          nxt_clk_lp_done = 1'b0;
        end
      end

      LPI_STOPPED: begin
        if (!clk_lp_req) begin
          nxt_clk_lp_done = 1'b0;
          if (syn_ready_to_flush && nts_ready_to_flush)
            nxt_lpi_state = LPI_FLUSH_FIFO;
          else
            nxt_lpi_state = LPI_STOPPED;
        end
        else begin
          nxt_lpi_state = LPI_STOPPED;
          nxt_clk_lp_done = 1'b1;
        end
      end

      LPI_FLUSH_FIFO: begin
        nxt_clk_lp_done = 1'b0;
        if (syn_async_fifo_flushed && nts_async_fifo_flushed) begin
          nxt_lpi_state = INSERT_RESYNC;
        end
        else begin
          nxt_lpi_state = LPI_FLUSH_FIFO;
        end
      end

      INSERT_RESYNC: begin
        nxt_lpi_state = LPI_IDLE;
        nxt_clk_lp_done = 1'b0;
      end

      default: begin
        nxt_lpi_state = 2'bxx;
        nxt_clk_lp_done   = 1'bx;
      end
    endcase
  end

  assign master_stopped = lpi_state == LPI_STOPPED;

  wire state_en = (nxt_lpi_state != lpi_state);

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      lpi_state <= LPI_STOPPED;
    else if (pwr_lp_req)
      lpi_state <= LPI_STOPPED;
    else if (state_en)
      lpi_state <= nxt_lpi_state;
  end

  always @(posedge clkm or negedge resetmn) begin
    if (!resetmn)
      clk_lp_done <= 1'b0;
    else
      clk_lp_done <= nxt_clk_lp_done;
  end

  css600_cdc_capt_nosync #( .IH(6), .IL(0)) u_cdc_capt_nosync_tsbit(
   .clk       (clkm),
   .reset_n   (resetmn),
   .en        (tsbitm_en),
   .d_async_i (tsbitm_next),
   .q_sync_o  (tsbitm)
  );

  assign ts_sync_m_next = (pwr_lp_req || clk_lp_req || lpi_state[1])
                        ? {2{1'b0}}
                        : ({2{~syn_async_fifo_empty}} & syn_encd_data);
  assign ts_sync_en     = (pwr_lp_req || clk_lp_req || lpi_state[1])
                        ? 1'b1
                        : tssyncreadym & !lpi_state[1] & (ts_sync_m_next != tssyncm);

  css600_cdc_capt_nosync #( .IH(1), .IL(0) ) u_cdc_capt_nosync_tssync(
   .clk       (clkm),
   .reset_n   (resetmn),
   .en        (ts_sync_en),
   .d_async_i (ts_sync_m_next),
   .q_sync_o  (tssyncm)
  );


endmodule

