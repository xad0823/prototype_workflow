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


module css600_ntsasyncbridgeslv_core #(parameter
  FF_SYNC_DEPTH = 2,
  THRESHOLD     = 8,
  FIFO_DEPTH    = 6
)
(
  input wire        clks,
  input wire        resetsn,

  input wire  [6:0] tsbits,
  input wire  [1:0] tssyncs,
  output wire       tssyncreadys,


  input wire  [3:0] syn_rd_ptr_gry_s,
  output wire [3:0] syn_wr_ptr_gry_s,

  output wire [FIFO_DEPTH*2-1:0] syn_encd_data_s,


  input wire  [3:0] nts_rd_ptr_gry_s,
  output wire [3:0] nts_wr_ptr_gry_s,

  output wire [FIFO_DEPTH*7-1:0] nts_encd_data_s,

  input wire        clk_lp_req,
  output reg        clk_lp_done,

  input wire        pwr_lp_req,
  input wire        master_stopped

  );


  localparam RESYNC_PCKT    = {7{1'b1}};
  localparam LPI_IDLE       = 2'b00;
  localparam LPI_STOPPED    = 2'b01;
  localparam LPI_UNUSED     = 2'b10;
  localparam INSERT_RESYNC  = 2'b11;


  wire [1:0] syn_enc_data;
  wire nts_enc_data_rg_en;
  wire nts_enc_data_vld;
  wire syn_enc_data_rg_en;
  wire syn_enc_data_vld;
  wire syn_async_fifo_full;
  wire nts_async_fifo_full;
  wire nts_wr_req;
  wire syn_wr_req;

  wire [FIFO_DEPTH-1:0] nts_wr_en;
  wire [FIFO_DEPTH-1:0] syn_wr_en;

  wire [3:0] nts_rd_ptr_gry_s_sync;
  wire [3:0] syn_rd_ptr_gry_s_sync;

  wire nts_roll_over;
  wire syn_roll_over;

  wire clock_stop;
  reg  thrsh_on;
  wire clock_stop_en;

  wire gen_resync_pck;

  wire tsbitvalids;
  wire tsbits_rg_en;
  wire tssyncs_rg_en;
  wire [6:0] stky_strg;
  wire state_en;

  wire syn_ready_to_start;
  wire nts_ready_to_start;

  wire nts_async_fifo_empty;
  wire syn_async_fifo_empty;

  reg [3:0] nts_incr_ptr_gry;
  reg [3:0] nts_gry_to_bin;

  reg [3:0] syn_incr_ptr_gry;
  reg [3:0] syn_gry_to_bin;

  reg [3:0] nts_rd_ptr_gry_s_to_bin;
  reg [3:0] syn_rd_ptr_gry_s_to_bin;

  reg [6:0] nts_enc_data_rg_next;
  reg [6:0] nts_enc_data_rg;

  reg [1:0] syn_enc_data_rg_next;
  reg [1:0] syn_enc_data_rg;


  reg [6:0] tsbits_rg_next;
  reg [6:0] tsbits_rg;
  reg [1:0] tssyncs_rg_next;
  reg [1:0] tssyncs_rg;

  reg       clock_stop_rg;

  reg [3:0] nts_wr_ptr_gry_s_next;
  reg [3:0] nts_wr_ptr_gry_s_q;

  reg [3:0] syn_wr_ptr_gry_s_next;
  reg [3:0] syn_wr_ptr_gry_s_q;

  reg [1:0] lpi_state;
  reg [1:0] nxt_lpi_state;

  reg [3:0] nts_rd_ptr_gry_s_sync_d;
  reg [3:0] syn_rd_ptr_gry_s_sync_d;

  reg nxt_clk_lp_done;

  reg [FIFO_DEPTH*7-1:0] nts_enc_data_fifo;
  reg [FIFO_DEPTH*2-1:0] syn_enc_data_fifo;


`include "css600_ntsasyncbridge_functions.v"


  assign clock_stop_en  = (stky_strg > THRESHOLD[6:0]) & (stky_strg !=  7'h7f) & thrsh_on;
  assign clock_stop     = (tsbits_rg > THRESHOLD[6:0]) & (tsbits_rg !=  7'h7f) & clock_stop_rg;

  always @(posedge clks or negedge resetsn)
    begin
      if (!resetsn)
        clock_stop_rg <= 1'b0;
      else if (clock_stop_en)
        clock_stop_rg <= 1'b1;
      else if (!nts_async_fifo_full || clock_stop)
        clock_stop_rg <= 1'b0;
    end

  always @(*)
    begin
      if (pwr_lp_req || (lpi_state == LPI_STOPPED))
        tsbits_rg_next = {7{1'b0}};
       else
        tsbits_rg_next = tsbits;
    end

  assign tsbits_rg_en = (tsbits_rg != tsbits_rg_next);

  always @(posedge clks or negedge resetsn)
    begin
      if (!resetsn)
        tsbits_rg <= {7{1'b0}};
      else if (tsbits_rg_en)
        tsbits_rg <= tsbits_rg_next;
    end

  always @(*)
    begin
      if (pwr_lp_req  || (lpi_state == LPI_STOPPED))
        tssyncs_rg_next = 2'b0;
      else if (syn_async_fifo_full)
        tssyncs_rg_next = tssyncs_rg;
      else
        tssyncs_rg_next = tssyncs;
    end

  assign tssyncs_rg_en = ((tssyncs_rg != tssyncs_rg_next));

  always @(posedge clks or negedge resetsn)
    begin
      if (!resetsn)
        tssyncs_rg <= {2{1'b0}};
      else if (tssyncs_rg_en)
        tssyncs_rg <= tssyncs_rg_next;
    end


  assign tsbitvalids = (tsbits_rg != {7{1'b0}}) | (nts_enc_data_rg != {7{1'b0}});

  assign syn_enc_data = ((|tssyncs_rg)) ? tssyncs_rg : {2{1'b0}};

  assign gen_resync_pck = (lpi_state == INSERT_RESYNC);

  assign stky_strg = (tsbits_rg > nts_enc_data_rg) ? tsbits_rg : nts_enc_data_rg;

  always @(*)
  begin
    nts_enc_data_rg_next = nts_enc_data_rg;
    syn_enc_data_rg_next = syn_enc_data_rg;
    thrsh_on = 1'b0;

    case (pwr_lp_req || (lpi_state == LPI_STOPPED))
      1'b1 : begin
            nts_enc_data_rg_next = {7{1'b0}};
            syn_enc_data_rg_next = {2{1'b0}};
          end

      1'b0 : begin
            case (nts_async_fifo_full)
              1'b0 : nts_enc_data_rg_next = gen_resync_pck ? RESYNC_PCKT : tsbits_rg;
              1'b1 : begin
                      nts_enc_data_rg_next = gen_resync_pck || clock_stop ? RESYNC_PCKT : stky_strg;
                      thrsh_on = 1'b1;
                     end
              default : nts_enc_data_rg_next = {7{1'bx}};
            endcase

            case (syn_async_fifo_full)
              1'b0 : syn_enc_data_rg_next = syn_enc_data;
              1'b1 : syn_enc_data_rg_next = syn_enc_data_rg;
              default : syn_enc_data_rg_next = {2{1'bx}};
            endcase
          end

      default : begin
                  nts_enc_data_rg_next = {7{1'bx}};
                  syn_enc_data_rg_next = {2{1'bx}};
                end
    endcase
  end

  assign nts_enc_data_rg_en = (gen_resync_pck | tsbitvalids | (nts_enc_data_rg != {7{1'b0}}));

  assign syn_enc_data_rg_en = ((|tssyncs_rg) | (|syn_enc_data_rg));


  always @(posedge clks or negedge resetsn)
    begin
      if (!resetsn) begin
        nts_enc_data_rg <= {7{1'b0}};
        syn_enc_data_rg <= {2{1'b0}};
      end
      else begin
        if (nts_enc_data_rg_en)
          nts_enc_data_rg <= nts_enc_data_rg_next;
        if (syn_enc_data_rg_en)
          syn_enc_data_rg <= syn_enc_data_rg_next;
      end
    end

  assign nts_enc_data_vld = (nts_enc_data_rg != {7{1'b0}});

  assign syn_enc_data_vld = (|syn_enc_data_rg);


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_nts_rd_ptr_gry_s0 (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (nts_rd_ptr_gry_s[0]),
      .q_sync_o  (nts_rd_ptr_gry_s_sync[0])
  );
  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_nts_rd_ptr_gry_s1
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (nts_rd_ptr_gry_s[1]),
      .q_sync_o  (nts_rd_ptr_gry_s_sync[1])
  );
  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_nts_rd_ptr_gry_s2
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (nts_rd_ptr_gry_s[2]),
      .q_sync_o  (nts_rd_ptr_gry_s_sync[2])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_nts_rd_ptr_gry_s3
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (nts_rd_ptr_gry_s[3]),
      .q_sync_o  (nts_rd_ptr_gry_s_sync[3])
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_syn_rd_ptr_gry_s0
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (syn_rd_ptr_gry_s[0]),
      .q_sync_o  (syn_rd_ptr_gry_s_sync[0])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_syn_rd_ptr_gry_s1
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (syn_rd_ptr_gry_s[1]),
      .q_sync_o  (syn_rd_ptr_gry_s_sync[1])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_syn_rd_ptr_gry_s2
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (syn_rd_ptr_gry_s[2]),
      .q_sync_o  (syn_rd_ptr_gry_s_sync[2])
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH  (FF_SYNC_DEPTH)
  )
  u_cdc_syn_rd_ptr_gry_s3
  (
      .clk       (clks),
      .reset_n   (resetsn),
      .d_async_i (syn_rd_ptr_gry_s[3]),
      .q_sync_o  (syn_rd_ptr_gry_s_sync[3])
  );

  generate
  if (FF_SYNC_DEPTH == 2) begin: rd_ptr_fifo_depth_6
    always @(nts_rd_ptr_gry_s_sync or syn_rd_ptr_gry_s_sync)
    begin
      nts_rd_ptr_gry_s_to_bin = gray_to_bin_6(nts_rd_ptr_gry_s_sync);
      syn_rd_ptr_gry_s_to_bin = gray_to_bin_6(syn_rd_ptr_gry_s_sync);
    end
  end
  if (FF_SYNC_DEPTH == 3) begin: rd_ptr_fifo_depth_8
    always @(nts_rd_ptr_gry_s_sync or syn_rd_ptr_gry_s_sync)
    begin
      nts_rd_ptr_gry_s_to_bin = gray_to_bin_8(nts_rd_ptr_gry_s_sync);
      syn_rd_ptr_gry_s_to_bin = gray_to_bin_8(syn_rd_ptr_gry_s_sync);
    end
  end
  endgenerate


  assign nts_roll_over = nts_wr_ptr_gry_s_q[3] ^ nts_rd_ptr_gry_s_sync[3];
  assign syn_roll_over = syn_wr_ptr_gry_s_q[3] ^ syn_rd_ptr_gry_s_sync[3];

  assign nts_async_fifo_full = ((nts_gry_to_bin == nts_rd_ptr_gry_s_to_bin) & nts_roll_over);
  assign syn_async_fifo_full = ((syn_gry_to_bin == syn_rd_ptr_gry_s_to_bin) & syn_roll_over);

  assign nts_async_fifo_empty = (nts_gry_to_bin == nts_rd_ptr_gry_s_to_bin) & ~nts_roll_over;
  assign syn_async_fifo_empty = (syn_gry_to_bin == syn_rd_ptr_gry_s_to_bin) & ~syn_roll_over;

  assign tssyncreadys = (master_stopped || pwr_lp_req || clk_lp_req) ? 1'b1 : ~(syn_async_fifo_full);


 generate
  if (FF_SYNC_DEPTH == 2) begin: wr_ptr_inc_fifo_depth_6
    always @(*)
    begin
      nts_incr_ptr_gry = gray_inc_6(nts_wr_ptr_gry_s_q);
      syn_incr_ptr_gry = gray_inc_6(syn_wr_ptr_gry_s_q);
    end
  end
  if (FF_SYNC_DEPTH == 3) begin: wr_ptr_inc_fifo_depth_8
    always @(*)
    begin
      nts_incr_ptr_gry = gray_inc_8(nts_wr_ptr_gry_s_q);
      syn_incr_ptr_gry = gray_inc_8(syn_wr_ptr_gry_s_q);
    end
  end
  endgenerate

  assign nts_wr_req = ~nts_async_fifo_full & nts_enc_data_vld & ~pwr_lp_req & ~(lpi_state == LPI_STOPPED);
  assign syn_wr_req = ~syn_async_fifo_full & syn_enc_data_vld & ~pwr_lp_req & ~(lpi_state == LPI_STOPPED);

  always @(*)
  begin
    nts_wr_ptr_gry_s_next = nts_wr_ptr_gry_s_q;
    syn_wr_ptr_gry_s_next = syn_wr_ptr_gry_s_q;

    if (~syn_async_fifo_full && syn_wr_req) begin
      syn_wr_ptr_gry_s_next = syn_incr_ptr_gry;
    end

    if (~nts_async_fifo_full && nts_wr_req) begin
      nts_wr_ptr_gry_s_next = nts_incr_ptr_gry;
    end
  end

  always @(posedge clks or negedge resetsn)
    begin
      if (!resetsn) begin
        nts_wr_ptr_gry_s_q <= {4{1'b0}};
        syn_wr_ptr_gry_s_q <= {4{1'b0}};
      end
      else if (pwr_lp_req) begin
        nts_wr_ptr_gry_s_q <= {4{1'b0}};
        syn_wr_ptr_gry_s_q <= {4{1'b0}};
      end
      else begin
        nts_wr_ptr_gry_s_q <= nts_wr_ptr_gry_s_next;
        syn_wr_ptr_gry_s_q <= syn_wr_ptr_gry_s_next;
      end
    end

  assign nts_wr_ptr_gry_s = nts_wr_ptr_gry_s_q;
  assign syn_wr_ptr_gry_s = syn_wr_ptr_gry_s_q;


 generate
  if (FF_SYNC_DEPTH == 2) begin: wr_ptr_fifo_depth_6
    always @(*)
    begin
      nts_gry_to_bin = gray_to_bin_6(nts_wr_ptr_gry_s_q);
      syn_gry_to_bin = gray_to_bin_6(syn_wr_ptr_gry_s_q);
    end
  end
  if (FF_SYNC_DEPTH == 3) begin: wr_ptr_fifo_depth_8
    always @(*)
    begin
      nts_gry_to_bin = gray_to_bin_8(nts_wr_ptr_gry_s_q);
      syn_gry_to_bin = gray_to_bin_8(syn_wr_ptr_gry_s_q);
    end
  end
  endgenerate

  genvar i;
  generate
  for (i=0; i<FIFO_DEPTH; i=i+1) begin: gen_fifo_wr

    assign nts_wr_en[i] = nts_wr_req & (nts_gry_to_bin == i[3:0]);

    always @(posedge clks or negedge resetsn) begin : p_enc_data_rg_nts
      if (!resetsn)
        nts_enc_data_fifo[i*7 +: 7] <= {7{1'b0}};
      else if (pwr_lp_req)
        nts_enc_data_fifo[i*7 +: 7] <= {7{1'b0}};
      else if (nts_wr_en[i])
        nts_enc_data_fifo[i*7 +: 7] <= nts_enc_data_rg;
    end

    assign syn_wr_en[i] = syn_wr_req & (syn_gry_to_bin == i[3:0]);

    always @(posedge clks or negedge resetsn) begin : p_enc_data_rg_syn
      if (!resetsn)
        syn_enc_data_fifo[i*2 +: 2] <= {2{1'b0}};
      else if (pwr_lp_req)
        syn_enc_data_fifo[i*2 +: 2] <= {2{1'b0}};
      else if (syn_wr_en[i])
        syn_enc_data_fifo[i*2 +: 2] <= syn_enc_data_rg;
    end

  end
  endgenerate

  assign nts_encd_data_s = nts_enc_data_fifo;
  assign syn_encd_data_s = syn_enc_data_fifo;


  assign syn_ready_to_start  = (syn_rd_ptr_gry_s_sync  == syn_rd_ptr_gry_s_sync_d) & syn_async_fifo_empty;
  assign nts_ready_to_start  = (nts_rd_ptr_gry_s_sync  == nts_rd_ptr_gry_s_sync_d) & nts_async_fifo_empty;

  always @(posedge clks or negedge resetsn) begin
    if (!resetsn)
      nts_rd_ptr_gry_s_sync_d <= 4'b0;
    else if (pwr_lp_req)
      nts_rd_ptr_gry_s_sync_d <= 4'b0;
    else
      nts_rd_ptr_gry_s_sync_d <= nts_rd_ptr_gry_s_sync;
  end

  always @(posedge clks or negedge resetsn) begin
    if (!resetsn)
      syn_rd_ptr_gry_s_sync_d <= 4'b0;
    else if (pwr_lp_req)
      syn_rd_ptr_gry_s_sync_d <= 4'b0;
    else
      syn_rd_ptr_gry_s_sync_d <= syn_rd_ptr_gry_s_sync;
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
          if (syn_ready_to_start && nts_ready_to_start)
            nxt_lpi_state = INSERT_RESYNC;
          else if (master_stopped)
            nxt_lpi_state = INSERT_RESYNC;
        end
        else begin
          nxt_lpi_state = LPI_STOPPED;
          nxt_clk_lp_done = 1'b1;
        end
      end

      INSERT_RESYNC: begin
        nxt_lpi_state = LPI_IDLE;
        nxt_clk_lp_done = 1'b0;
      end

      LPI_UNUSED : begin
                    nxt_lpi_state = LPI_STOPPED;
                    nxt_clk_lp_done = 1'b1;
                   end

      default: begin
        nxt_lpi_state = 2'bxx;
        nxt_clk_lp_done   = 1'bx;
      end
    endcase
  end

  assign state_en = (nxt_lpi_state != lpi_state);

  always @(posedge clks or negedge resetsn) begin
    if (!resetsn)
      lpi_state <= LPI_STOPPED;
    else if (pwr_lp_req)
      lpi_state <= LPI_STOPPED;
    else if (state_en)
      lpi_state <= nxt_lpi_state;
  end

  always @(posedge clks or negedge resetsn) begin
    if (!resetsn)
      clk_lp_done <= 1'b0;
    else
      clk_lp_done <= nxt_clk_lp_done;
  end


endmodule


