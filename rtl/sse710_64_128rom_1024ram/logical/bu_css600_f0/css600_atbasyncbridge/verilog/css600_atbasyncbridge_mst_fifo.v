//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2019 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbasyncbridge
//
//----------------------------------------------------------------------------


module css600_atbasyncbridge_mst_fifo #(parameter
  ATB_DATA_WIDTH = 32,
  ATBYTES_WIDTH  = 2,
  BUFFER_DEPTH   = 6
)
(
  clk_m,
  reset_m_n,
  atreadym,
  wrptr_gray_sync,
  flush_done_sync,
  fifo_data,
  afvalidm,

  atvalidm,
  atbytesm,
  atidm,
  atdatam,
  afreadym,
  rd_ptr_gray,
  flush_req,
  sync_clear_sync,
  sync_done,
  pulse_done,
  pulse_qactive,
  syncreq_gate,

  lp_request,
  lp_done,
  lp_dny

  );

  localparam CSBA_ST_F_IDLE    = 2'b00;
  localparam CSBA_ST_F_WAIT1   = 2'b01;
  localparam CSBA_ST_F_ASSERT  = 2'b11;
  localparam CSBA_ST_F_WAIT2   = 2'b10;
  localparam CSBA_ST_F_UNDEF   = 2'bXX;

  localparam  PWR_LP_IDLE           = 2'b00;
  localparam  PWR_LP_WAIT_FOR_EMPTY = 2'b01;
  localparam  PWR_LP_PWR_DWN        = 2'b10;
  localparam  PWR_LP_UNUSED         = 2'b11;
  localparam  LP_UNDEFINED      = 2'bxx;

  localparam  CLK_LP_IDLE            = 2'b00;
  localparam  CLK_LP_DNY             = 2'b01;
  localparam  CLK_LP_DWN             = 2'b10;
  localparam  CLK_LP_WAIT_PULSE_BR   = 2'b11;

  localparam FIFO_DATA_WIDTH   = ATB_DATA_WIDTH + 7 + ATBYTES_WIDTH;

  input wire                       clk_m;
  input wire                       reset_m_n;
  input wire                       atreadym;
  input wire [3:0]                 wrptr_gray_sync;
  input wire                       flush_done_sync;
  input wire                       afvalidm;

  input wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1:0] fifo_data;

  output wire                      atvalidm;
  output wire [ATBYTES_WIDTH-1:0]  atbytesm;
  output wire [6:0]                atidm;
  output wire [ATB_DATA_WIDTH-1:0] atdatam;
  output reg                       afreadym;
  output reg [3:0]                 rd_ptr_gray;
  output reg                       flush_req;

  input  wire                      lp_request;
  output reg                       lp_done;
  output wire                      lp_dny;

  input wire                       sync_clear_sync;
  input wire                       pulse_done;
  input wire                       pulse_qactive;
  output wire                      syncreq_gate;
  output reg                       sync_done;


  wire                                       rdptr_en;
  wire                                       sample;
  wire                                       data_en;
  wire                                       fifo_rdata_en;
  wire                                       nxt_atvalidm;
  wire                                       new_flush;
  wire                                       nxt_flush_req;
  wire                                       nxt_afreadym;


  wire [FIFO_DATA_WIDTH-1:0]                 atb_fifo_data_lvl_0_mux_0;
  wire [FIFO_DATA_WIDTH-1:0]                 atb_fifo_data_lvl_0_mux_1;

  wire [BUFFER_DEPTH * FIFO_DATA_WIDTH -1:0] fifo_data_corrupt;
  wire [FIFO_DATA_WIDTH-1:0] fifo_rdata;


  wire [6:0]                 fifo_rid;
  wire [ATB_DATA_WIDTH-1:0]  fifo_rpyld;
  wire [ATBYTES_WIDTH-1:0]   fifo_rbytes;

  wire                       flush_empty;
  wire                       nxt_flush_ptr_save;
  wire [3:0]                 flush_ptr_bin;
  wire                       nxt_flushing;

  wire                       fifo_empty;
  wire                       clk_dev_active;


  reg [3:0]                  nxt_rd_ptr_gray;

  reg [1:0]                  nxt_flush_state;
  reg [1:0]                  flush_state;

  reg                        flush_ptr_save;
  reg [3:0]                  rd_ptr_bin;
  reg [3:0]                  flush_rd_ptr;
  reg                        flushing;
  reg [1:0]                  lpi_state;
  reg [1:0]                  nxt_lpi_state;
  reg                        nxt_sync_done;
  reg                        nxt_lp_done;

  reg [1:0]                  clk_lpi_state;
  reg [1:0]                  nxt_clk_lpi_state;

  function [3:0] gray_to_bin_6;
    input [3:0] gray;

    begin
    case (gray)
        4'd0 : gray_to_bin_6 = 4'd0;
        4'd1 : gray_to_bin_6 = 4'd1;

        4'd3 : gray_to_bin_6 = 4'd2;
        4'd2 : gray_to_bin_6 = 4'd3;
        4'd6 : gray_to_bin_6 = 4'd4;
        4'd7 : gray_to_bin_6 = 4'd5;
        4'd15 : gray_to_bin_6 = 4'd0;
        4'd14 : gray_to_bin_6 = 4'd1;
        4'd10 : gray_to_bin_6 = 4'd2;
        4'd11 : gray_to_bin_6 = 4'd3;
        4'd9 : gray_to_bin_6 = 4'd4;
        4'd8 : gray_to_bin_6 = 4'd5;

        4'd4,
        4'd5,
        4'd12,
        4'd13 : gray_to_bin_6 = {4{1'b0}};

        default : gray_to_bin_6 = {4{1'bx}};
      endcase
    end
  endfunction


  function [3:0] gray_to_bin_8;
    input [3:0] gray;

    begin
    case (gray)
        4'd0 : gray_to_bin_8 = 4'd0;
        4'd1 : gray_to_bin_8 = 4'd1;
        4'd3 : gray_to_bin_8 = 4'd2;
        4'd2 : gray_to_bin_8 = 4'd3;
        4'd6 : gray_to_bin_8 = 4'd4;
        4'd7 : gray_to_bin_8 = 4'd5;
        4'd5 : gray_to_bin_8 = 4'd6;
        4'd4 : gray_to_bin_8 = 4'd7;

        4'd12 : gray_to_bin_8 = 4'd0;
        4'd13 : gray_to_bin_8 = 4'd1;
        4'd15 : gray_to_bin_8 = 4'd2;
        4'd14 : gray_to_bin_8 = 4'd3;
        4'd10 : gray_to_bin_8 = 4'd4;
        4'd11 : gray_to_bin_8 = 4'd5;
        4'd9  : gray_to_bin_8 = 4'd6;
        4'd8  : gray_to_bin_8 = 4'd7;

        default : gray_to_bin_8 = {4{1'bx}};
      endcase
    end
  endfunction


  generate
  if (BUFFER_DEPTH == 6) begin: gray_inc_fifo6

    always @(rd_ptr_gray)
      begin
        rd_ptr_bin = gray_to_bin_6(rd_ptr_gray);
      end
  end
  if (BUFFER_DEPTH == 8) begin: gray_inc_fifo8

    always @(rd_ptr_gray)
      begin
        rd_ptr_bin = gray_to_bin_8(rd_ptr_gray);
      end
  end
  endgenerate

  assign fifo_data_corrupt = fifo_data;

  genvar a;
  generate
  for (a=0; a< FIFO_DATA_WIDTH; a=a+1) begin: fifo_data_mux_0

    css600_mux4 u_bit_0_lvl_0_mux_0 (
    .din1_async (fifo_data_corrupt[a]),
    .din2_async (fifo_data_corrupt[FIFO_DATA_WIDTH+a]),
    .din3_async (fifo_data_corrupt[2*FIFO_DATA_WIDTH+a]),
    .din4_async (fifo_data_corrupt[3*FIFO_DATA_WIDTH+a]),
    .sel        (rd_ptr_bin[1:0]),
    .dout_async (atb_fifo_data_lvl_0_mux_0[a]));

    if (BUFFER_DEPTH == 6) begin: fifo_data_mux_1_depth_6

      css600_mux4 u_bit_0_lvl_0_mux_1 (
      .din1_async (fifo_data_corrupt[4*FIFO_DATA_WIDTH+a]),
      .din2_async (fifo_data_corrupt[5*FIFO_DATA_WIDTH+a]),
      .din3_async (1'b0),
      .din4_async (1'b0),
      .sel        (rd_ptr_bin[1:0]),
      .dout_async (atb_fifo_data_lvl_0_mux_1[a]));

    end
    if (BUFFER_DEPTH == 8) begin : fifo_data_mux_1_depth_8

      css600_mux4 u_bit_0_lvl_0_mux_1 (
      .din1_async (fifo_data_corrupt[4*FIFO_DATA_WIDTH+a]),
      .din2_async (fifo_data_corrupt[5*FIFO_DATA_WIDTH+a]),
      .din3_async (fifo_data_corrupt[6*FIFO_DATA_WIDTH+a]),
      .din4_async (fifo_data_corrupt[7*FIFO_DATA_WIDTH+a]),
      .sel        (rd_ptr_bin[1:0]),
      .dout_async (atb_fifo_data_lvl_0_mux_1[a]));

    end

  css600_mux2 u_bit_0_lvl_1_mux_0 (
  .din1_async (atb_fifo_data_lvl_0_mux_0[a]),
  .din2_async (atb_fifo_data_lvl_0_mux_1[a]),
  .sel        (rd_ptr_bin[2]),
  .dout_async (fifo_rdata[a]));

  end
  endgenerate


  assign fifo_empty = (wrptr_gray_sync == rd_ptr_gray);


    always @(posedge clk_m or negedge reset_m_n)
      begin
        if (!reset_m_n)
          lp_done  <= 1'b1;
        else
          lp_done  <= nxt_lp_done;
      end


  generate
  if (BUFFER_DEPTH == 6) begin: rd_ptr_gray_inc_6

  always @ *
    begin
        case (rd_ptr_gray)
          4'b0000: nxt_rd_ptr_gray = 4'b0001;
          4'b0001: nxt_rd_ptr_gray = 4'b0011;
          4'b0011: nxt_rd_ptr_gray = 4'b0010;
          4'b0010: nxt_rd_ptr_gray = 4'b0110;
          4'b0110: nxt_rd_ptr_gray = 4'b0111;
          4'b0111: nxt_rd_ptr_gray = 4'b1111;
          4'b1111: nxt_rd_ptr_gray = 4'b1110;
          4'b1110: nxt_rd_ptr_gray = 4'b1010;
          4'b1010: nxt_rd_ptr_gray = 4'b1011;
          4'b1011: nxt_rd_ptr_gray = 4'b1001;
          4'b1001: nxt_rd_ptr_gray = 4'b1000;
          4'b1000: nxt_rd_ptr_gray = 4'b0000;
          4'b0100,
          4'b1100,
          4'b0101,
          4'b1101: nxt_rd_ptr_gray = 4'b0000;
          default: nxt_rd_ptr_gray = {4{1'bx}};
        endcase
    end

    end

  if (BUFFER_DEPTH == 8) begin: rd_ptr_gray_inc_8
  always @ *
    begin
        case (rd_ptr_gray)
          4'b0000: nxt_rd_ptr_gray = 4'b0001;
          4'b0001: nxt_rd_ptr_gray = 4'b0011;
          4'b0011: nxt_rd_ptr_gray = 4'b0010;
          4'b0010: nxt_rd_ptr_gray = 4'b0110;
          4'b0110: nxt_rd_ptr_gray = 4'b0111;
          4'b0111: nxt_rd_ptr_gray = 4'b0101;
          4'b0101: nxt_rd_ptr_gray = 4'b0100;
          4'b0100: nxt_rd_ptr_gray = 4'b1100;
          4'b1100: nxt_rd_ptr_gray = 4'b1101;
          4'b1101: nxt_rd_ptr_gray = 4'b1111;
          4'b1111: nxt_rd_ptr_gray = 4'b1110;
          4'b1110: nxt_rd_ptr_gray = 4'b1010;
          4'b1010: nxt_rd_ptr_gray = 4'b1011;
          4'b1011: nxt_rd_ptr_gray = 4'b1001;
          4'b1001: nxt_rd_ptr_gray = 4'b1000;
          4'b1000: nxt_rd_ptr_gray = 4'b0000;
          default: nxt_rd_ptr_gray = {4{1'bx}};
        endcase
    end
  end
  endgenerate


  assign rdptr_en = sample & ~fifo_empty;

  always @(posedge clk_m or negedge reset_m_n)
    begin
      if (!reset_m_n)
        rd_ptr_gray   <= {4{1'b0}};
      else if (lpi_state == PWR_LP_PWR_DWN)
        rd_ptr_gray   <= {4{1'b0}};
      else
        if (rdptr_en)
          rd_ptr_gray <= nxt_rd_ptr_gray;
    end


  assign new_flush     = (!flush_req && !flush_done_sync) ? afvalidm : flush_req;
  assign nxt_flush_req = (flush_state == CSBA_ST_F_ASSERT) ? 1'b0 : new_flush;

  always @(posedge clk_m or negedge reset_m_n)
    begin : s_flush_req
      if (!reset_m_n)
        flush_req <= 1'b0;
      else if (lpi_state == PWR_LP_PWR_DWN || clk_lpi_state[1])
        flush_req <= 1'b0;
      else
        flush_req <= nxt_flush_req;
    end


  assign nxt_flush_ptr_save = ~flush_ptr_save & (nxt_flush_state == CSBA_ST_F_WAIT1 && flush_state == CSBA_ST_F_IDLE);

  always @(posedge clk_m or negedge reset_m_n)
    begin : s_flush_ptr_save
      if (!reset_m_n)
        flush_ptr_save <= 1'b0;
      else
        flush_ptr_save <= nxt_flush_ptr_save;
    end

  always @(posedge clk_m or negedge reset_m_n)
    begin : s_flush_ptr
      if (!reset_m_n)
        flush_rd_ptr <= {4{1'b0}};
      else if (flush_ptr_save)
        flush_rd_ptr <= rd_ptr_gray;
    end

  always @(posedge clk_m or negedge reset_m_n)
    begin : s_flush_ongoing
      if (!reset_m_n)
        flushing <= 1'b0;
      else
        flushing <= nxt_flushing;
    end

  assign nxt_flushing = (flushing | flush_ptr_save) & (nxt_flush_state == CSBA_ST_F_WAIT1);

  generate

  if (BUFFER_DEPTH == 6) begin: flush_ptr_6_deep
    assign flush_ptr_bin = gray_to_bin_6(flush_rd_ptr);
  end
  else begin: flush_ptr_8_deep
    assign flush_ptr_bin = gray_to_bin_8(flush_rd_ptr);
  end
  endgenerate

  assign flush_empty = (flush_ptr_bin == rd_ptr_bin) && (rd_ptr_gray[3] != flush_rd_ptr[3]) & flushing;

  always@(flush_req or flush_done_sync or fifo_empty or flush_state or sample or flush_empty)
    begin
      case (flush_state)
        CSBA_ST_F_IDLE   : nxt_flush_state = (flush_req && flush_done_sync) ? (fifo_empty && sample) ? CSBA_ST_F_ASSERT
                                                                              :                        CSBA_ST_F_WAIT1
                                           : CSBA_ST_F_IDLE
                                           ;
        CSBA_ST_F_WAIT1  : nxt_flush_state = ((fifo_empty | flush_empty) && sample) ? CSBA_ST_F_ASSERT
                                           :                                          CSBA_ST_F_WAIT1
                                           ;
        CSBA_ST_F_ASSERT : nxt_flush_state = CSBA_ST_F_WAIT2
                                           ;
        CSBA_ST_F_WAIT2  : nxt_flush_state = flush_done_sync ? CSBA_ST_F_WAIT2
                                           : CSBA_ST_F_IDLE
                                           ;
        default          : nxt_flush_state = CSBA_ST_F_UNDEF;
      endcase
    end

  always @(posedge clk_m or negedge reset_m_n)
    begin : s_flush_state
      if (!reset_m_n)
        flush_state <= CSBA_ST_F_IDLE;
      else if (sync_clear_sync && nxt_sync_done)
        flush_state <= CSBA_ST_F_IDLE;
      else
        flush_state <= nxt_flush_state;
    end


  always @*
  begin
    nxt_sync_done = sync_done;

    case (lpi_state)
      PWR_LP_IDLE            : begin
                            if (sync_clear_sync)
                              nxt_lpi_state = PWR_LP_WAIT_FOR_EMPTY;
                            else
                              nxt_lpi_state = PWR_LP_IDLE;
                            end

      PWR_LP_WAIT_FOR_EMPTY  : begin
                            if (!atvalidm && !pulse_done)
                              nxt_lpi_state = PWR_LP_PWR_DWN;
                            else
                              nxt_lpi_state = PWR_LP_WAIT_FOR_EMPTY;
                           end

      PWR_LP_PWR_DWN :    begin
                            if (!sync_clear_sync && pulse_done)
                            begin
                              nxt_lpi_state = PWR_LP_IDLE;
                              nxt_sync_done = 1'b0;
                            end
                            else begin
                              nxt_lpi_state = PWR_LP_PWR_DWN;
                              nxt_sync_done = 1'b1;
                            end
                           end

      PWR_LP_UNUSED : nxt_lpi_state = PWR_LP_PWR_DWN;

      default   : begin
                    nxt_sync_done = 1'bx;
                    nxt_lpi_state = LP_UNDEFINED;
                  end

   endcase
  end

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      lpi_state <= PWR_LP_PWR_DWN;
    else
      lpi_state <= nxt_lpi_state;
  end


  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      sync_done <= 1'b1;
    else
      sync_done <= nxt_sync_done;
  end


  assign syncreq_gate = (nxt_clk_lpi_state == CLK_LP_DWN);
  assign clk_dev_active = (~fifo_empty | afvalidm | atvalidm | pulse_qactive);
  assign lp_dny = clk_dev_active & ~clk_lpi_state[1];

  always @* begin

    nxt_clk_lpi_state = clk_lpi_state;
    nxt_lp_done = lp_done;

    case (clk_lpi_state)
      CLK_LP_IDLE: begin
        if (lp_request) begin
          if (lp_dny) begin
            nxt_clk_lpi_state = CLK_LP_DNY;
            nxt_lp_done = 1'b1;
          end
          else begin
            nxt_clk_lpi_state = CLK_LP_DWN;
            nxt_lp_done = 1'b1;
          end

        end
      end

      CLK_LP_DNY : begin
        if (!lp_request) begin
          nxt_lp_done = 1'b0;
          nxt_clk_lpi_state = CLK_LP_IDLE;
        end
        else begin
          nxt_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DNY;
        end
      end

      CLK_LP_DWN: begin
        if (!lp_request) begin
          if (pulse_done || sync_clear_sync) begin
            nxt_lp_done = 1'b0;
            nxt_clk_lpi_state = CLK_LP_IDLE;
          end
        else begin
          nxt_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DWN;
        end
        end
        else begin
          nxt_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DWN;
        end
      end

      CLK_LP_WAIT_PULSE_BR: begin
        if (pulse_qactive) begin
          nxt_lp_done = 1'b0;
          nxt_clk_lpi_state = CLK_LP_WAIT_PULSE_BR;
        end
        else begin
          nxt_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DWN;
        end
      end

      default: begin
        nxt_clk_lpi_state = 2'bxx;
        nxt_lp_done       = 1'bx;
      end
    endcase
  end

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      clk_lpi_state <= CLK_LP_DWN;
    else
      clk_lpi_state <= nxt_clk_lpi_state;
  end


  assign nxt_afreadym = (nxt_flush_state == CSBA_ST_F_ASSERT) | (nxt_sync_done & sync_clear_sync);


  always @(posedge clk_m or negedge reset_m_n)
    begin : s_afreadym
      if (!reset_m_n)
        afreadym <= 1'b1;
      else
        afreadym <= nxt_afreadym;
    end


  assign sample                              = (~atvalidm | atreadym) & ~clk_lpi_state[1];
  assign nxt_atvalidm                        = ~fifo_empty & ~sync_done & ~clk_lpi_state[1];
  assign {fifo_rbytes, fifo_rid, fifo_rpyld} = fifo_rdata;
  assign fifo_rdata_en                       = sample & nxt_atvalidm & ~(sync_clear_sync & nxt_sync_done);
  assign data_en                             = sample;

  css600_cdc_capt_nosync #( .IH(0), .IL(0) ) u_cdc_capt_nosync_atvalid(
    .clk       (clk_m),
    .reset_n   (reset_m_n),
    .en        (data_en),
    .d_async_i (nxt_atvalidm),
    .q_sync_o  (atvalidm)
  );

  css600_cdc_capt_nosync #( .IH(ATBYTES_WIDTH-1), .IL(0) ) u_cdc_capt_nosync_atbytes(
    .clk       (clk_m),
    .reset_n   (1'b1),
    .en        (fifo_rdata_en),
    .d_async_i (fifo_rbytes),
    .q_sync_o  (atbytesm)
  );

  css600_cdc_capt_nosync #( .IH(6), .IL(0) ) u_cdc_capt_nosync_atid(
    .clk       (clk_m),
    .reset_n   (1'b1),
    .en        (fifo_rdata_en),
    .d_async_i (fifo_rid),
    .q_sync_o  (atidm)
  );

  css600_cdc_capt_nosync #( .IH(ATB_DATA_WIDTH-1), .IL(0) ) u_cdc_capt_nosync_atdata(
    .clk       (clk_m),
    .reset_n   (1'b1),
    .en        (fifo_rdata_en),
    .d_async_i (fifo_rpyld),
    .q_sync_o  (atdatam)
  );


endmodule
