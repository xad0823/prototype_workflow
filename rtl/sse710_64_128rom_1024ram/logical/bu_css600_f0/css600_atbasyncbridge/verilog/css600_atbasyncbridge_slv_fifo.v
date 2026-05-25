//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2015, 2016-2019 Arm Limited or its affiliates.
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


module css600_atbasyncbridge_slv_fifo #(parameter
  FIFO_DATA_WIDTH = 41,
  BUFFER_DEPTH    = 6
)
(
  clk_s,
  reset_s_n,
  atvalids,
  rdptr_gray_sync,
  write_data,
  afreadys,
  flush_req_sync,
  sync_clear,
  sync_done_sync,
  atreadys,
  afvalids,
  wrptr_gray,
  fifo_data,
  flush_done,

  pwr_lp_request,
  pwr_lp_done,

  clk_lp_request,
  clk_lp_done,
  clk_lp_dny,
  pulse_qaccept_n,
  clk_qreq_n_sync,
  clk_qaccept_n
);


localparam  LPI_IDLE                 = 3'b000;
localparam  LPI_FLUSH_REQ            = 3'b001;
localparam  LPI_FIFO_EMPTYING        = 3'b010;
localparam  LPI_WAIT_FOR_MASTER_DOWN = 3'b011;
localparam  PWR_DWN                  = 3'b100;
localparam  LPI_MST_RDY              = 3'b101;

localparam  LPI_WAIT_FOR_MASTER_UP   = 3'b110;
localparam  LPI_UNUSED_3             = 3'b111;

localparam  F_IDLE                   = 2'b00;
localparam  F_FLUSHING               = 2'b01;
localparam  F_FLUSH_COMPLETE         = 2'b10;
localparam  F_NO_FLUSH               = 2'b11;
localparam  F_UNDEFINED              = 2'bxx;

localparam  CLK_LP_IDLE              = 2'b00;
localparam  CLK_LP_DENY              = 2'b01;
localparam  CLK_LP_DWN               = 2'b10;
localparam  CLK_LP_WAIT_DEV_ACTIVE   = 2'b11;
localparam  CLK_LP_UNDEFINED         = 2'bxx;


  input wire                        clk_s;
  input wire                        reset_s_n;
  input wire                        atvalids;
  input wire [FIFO_DATA_WIDTH-1:0]  write_data;
  input wire                        afreadys;
  input wire [3:0]                  rdptr_gray_sync;
  input wire                        flush_req_sync;

  input wire                        pulse_qaccept_n;
  input wire                        pwr_lp_request;
  input wire                        clk_lp_request;
  input wire                        sync_done_sync;
  input wire                        clk_qreq_n_sync;
  input wire                        clk_qaccept_n;

  output wire                       atreadys;
  output reg                        afvalids;
  output reg  [3:0]                 wrptr_gray;
  output wire [BUFFER_DEPTH*FIFO_DATA_WIDTH-1:0]  fifo_data;
  output reg                        flush_done;
  input  wire                       clk_lp_dny;

  output reg                        pwr_lp_done;
  output reg                        clk_lp_done;
  output reg                        sync_clear;


  wire                       wrptr_en;
  wire                       data_rdy;

  wire                       write_en;
  wire                       fifo_empty;
  wire                       fifo_data_en [BUFFER_DEPTH-1:0];
  wire                       iflush_req;
  wire                       lpi_state_en;
  reg [2:0]                  rdptr_gray_bin;
  reg [2:0]                  wrptr_bin;
  reg [3:0]                  nxt_wrptr_gray;
  reg                        nxt_afvalids;
  reg                        nxt_flush_done;

  reg  [FIFO_DATA_WIDTH-1:0] fifo_data_word [BUFFER_DEPTH-1:0];


  reg  [2:0] nxt_pwr_lpi_state;
  reg  [2:0] pwr_lpi_state;

  reg         nxt_sync_clear;
  reg         nxt_pwr_lp_done;

  reg  [1:0]  flush_state;
  reg  [1:0]  nxt_flush_state;

  reg         lpi_flush;
  reg         nxt_lpi_flush;

  reg [1:0]   nxt_clk_lpi_state;
  reg [1:0]   clk_lpi_state;
  reg         nxt_clk_lp_done;


  genvar cc;
  generate

    for (cc=0; cc< BUFFER_DEPTH; cc=cc+1) begin: fifo_data_assign_gen
      assign fifo_data[cc*FIFO_DATA_WIDTH+:FIFO_DATA_WIDTH] = fifo_data_word[cc];
    end
  endgenerate

  genvar bb;
  generate

    for (bb=0; bb< BUFFER_DEPTH; bb=bb+1) begin: fifo_data_cdc_gen
      always @(posedge clk_s or negedge reset_s_n)
        begin
          if (!reset_s_n)
            fifo_data_word[bb]   <= {FIFO_DATA_WIDTH{1'b0}};
          else
            if (fifo_data_en[bb])
              fifo_data_word[bb] <= write_data;
        end
    end
  endgenerate


  assign write_en  = (pwr_lpi_state == LPI_IDLE | pwr_lpi_state == LPI_FLUSH_REQ);
  assign wrptr_en  = atvalids & atreadys & write_en & lpi_state_en;

  genvar aa;
  generate

    for (aa=0; aa< BUFFER_DEPTH; aa=aa+1) begin: fifo_data_en_gen
      assign fifo_data_en[aa] = (wrptr_en & (wrptr_bin[2:0] == aa[2:0]));
    end
  endgenerate


  assign iflush_req = ((pwr_lpi_state == PWR_DWN) || (clk_lpi_state == CLK_LP_DWN)) ? 1'b0 : flush_req_sync;

  always @*
  begin

    nxt_flush_state = flush_state;
    nxt_afvalids   = afvalids;
    nxt_flush_done  = flush_done;

    case (flush_state)

    F_IDLE            : begin
                          if (iflush_req || lpi_flush) begin
                            nxt_flush_state = F_FLUSHING;
                            nxt_afvalids   = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_IDLE;
                            nxt_afvalids   = 1'b0;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_FLUSHING        : begin
                          if (afreadys) begin
                            nxt_flush_state = F_FLUSH_COMPLETE;
                            nxt_afvalids   = 1'b0;
                            nxt_flush_done  = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_FLUSHING;
                            nxt_afvalids   = afvalids;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_FLUSH_COMPLETE  : begin
                          if (lpi_flush) begin
                            nxt_flush_state = F_NO_FLUSH;
                            nxt_flush_done  = 1'b1;
                          end
                          else if (iflush_req) begin
                            nxt_flush_state = F_FLUSH_COMPLETE;
                            nxt_flush_done  = 1'b1;
                          end
                          else begin
                            nxt_flush_state = F_IDLE;
                            nxt_flush_done  = 1'b0;
                          end
                        end
    F_NO_FLUSH        : begin
                          if (pwr_lpi_state == LPI_IDLE) begin
                            nxt_flush_state = F_IDLE;
                            nxt_flush_done  = 1'b0;
                          end
                        end

    default           : begin
                          nxt_flush_state = F_UNDEFINED;
                          nxt_afvalids   = 1'bx;
                          nxt_flush_done  = 1'bx;
                        end
   endcase
  end


  always @(posedge clk_s or negedge reset_s_n)
  begin
    if (!reset_s_n)
      flush_state <= F_NO_FLUSH;
    else
      flush_state <= nxt_flush_state;
  end

  always @(posedge clk_s or negedge reset_s_n)
  begin
    if (!reset_s_n)
      afvalids  <= 1'b0;
    else
      afvalids <= nxt_afvalids;
  end

  always @(posedge clk_s or negedge reset_s_n)
  begin
    if (!reset_s_n)
      flush_done <= 1'b1;
    else if (pwr_lpi_state == PWR_DWN)
      flush_done <= 1'b1;
    else
      flush_done <= nxt_flush_done;
  end


  always @* begin

    nxt_clk_lpi_state = clk_lpi_state;
    nxt_clk_lp_done = clk_lp_done;

    case (clk_lpi_state)
      CLK_LP_IDLE: begin
        if (clk_lp_request) begin
          if (clk_lp_dny) begin
            nxt_clk_lpi_state = CLK_LP_DENY;
            nxt_clk_lp_done = 1'b1;
          end
          else if (!pulse_qaccept_n) begin
            nxt_clk_lpi_state = CLK_LP_WAIT_DEV_ACTIVE;
            nxt_clk_lp_done = 1'b1;
          end
          else begin
            nxt_clk_lpi_state = CLK_LP_IDLE;
            nxt_clk_lp_done = 1'b0;
          end
        end
      end

      CLK_LP_WAIT_DEV_ACTIVE: begin
        nxt_clk_lp_done = 1'b1;
        if (clk_lp_dny)
          nxt_clk_lpi_state = CLK_LP_DENY;
        else
          nxt_clk_lpi_state = CLK_LP_DWN;
      end

      CLK_LP_DWN: begin
        if (!clk_lp_request) begin
          nxt_clk_lp_done = 1'b0;
          nxt_clk_lpi_state = CLK_LP_IDLE;
        end
        else begin
          nxt_clk_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DWN;
        end
      end

      CLK_LP_DENY : begin
        if (!clk_lp_request) begin
          nxt_clk_lp_done = 1'b0;
          nxt_clk_lpi_state = CLK_LP_IDLE;
        end
        else begin
          nxt_clk_lp_done = 1'b1;
          nxt_clk_lpi_state = CLK_LP_DENY;
        end
      end

      default: begin
        nxt_clk_lpi_state = CLK_LP_UNDEFINED;
        nxt_clk_lp_done       = 1'bx;
      end
    endcase
  end

  always @(posedge clk_s or negedge reset_s_n)
  begin
    if (!reset_s_n)
    begin
      clk_lpi_state <= CLK_LP_DWN;
      clk_lp_done   <= 1'b0;
    end
    else
    begin
      clk_lpi_state <= nxt_clk_lpi_state;
      clk_lp_done   <= nxt_clk_lp_done;
    end
  end

  generate
  if (BUFFER_DEPTH == 6) begin: wrptr_gray_inc_6_gen

  always @(wrptr_gray)
    begin
        case (wrptr_gray[3:0])
          4'b0000: nxt_wrptr_gray = 4'b0001;
          4'b0001: nxt_wrptr_gray = 4'b0011;
          4'b0011: nxt_wrptr_gray = 4'b0010;
          4'b0010: nxt_wrptr_gray = 4'b0110;
          4'b0110: nxt_wrptr_gray = 4'b0111;
          4'b0111: nxt_wrptr_gray = 4'b1111;
          4'b1111: nxt_wrptr_gray = 4'b1110;
          4'b1110: nxt_wrptr_gray = 4'b1010;
          4'b1010: nxt_wrptr_gray = 4'b1011;
          4'b1011: nxt_wrptr_gray = 4'b1001;
          4'b1001: nxt_wrptr_gray = 4'b1000;
          4'b1000: nxt_wrptr_gray = 4'b0000;
          4'b0100,
          4'b1100,
          4'b0101,
          4'b1101: nxt_wrptr_gray = 4'b0000;
          default: nxt_wrptr_gray = {4{1'bx}};
        endcase
    end
  end

  if (BUFFER_DEPTH == 8) begin: wrptr_gray_inc_8_gen
  always @(wrptr_gray)
    begin
        case (wrptr_gray[3:0])
          4'b0000: nxt_wrptr_gray = 4'b0001;
          4'b0001: nxt_wrptr_gray = 4'b0011;
          4'b0011: nxt_wrptr_gray = 4'b0010;
          4'b0010: nxt_wrptr_gray = 4'b0110;
          4'b0110: nxt_wrptr_gray = 4'b0111;
          4'b0111: nxt_wrptr_gray = 4'b0101;
          4'b0101: nxt_wrptr_gray = 4'b0100;
          4'b0100: nxt_wrptr_gray = 4'b1100;
          4'b1100: nxt_wrptr_gray = 4'b1101;
          4'b1101: nxt_wrptr_gray = 4'b1111;
          4'b1111: nxt_wrptr_gray = 4'b1110;
          4'b1110: nxt_wrptr_gray = 4'b1010;
          4'b1010: nxt_wrptr_gray = 4'b1011;
          4'b1011: nxt_wrptr_gray = 4'b1001;
          4'b1001: nxt_wrptr_gray = 4'b1000;
          4'b1000: nxt_wrptr_gray = 4'b0000;
          default: nxt_wrptr_gray = {4{1'bx}};
        endcase
    end
  end
  endgenerate

  always @(posedge clk_s or negedge reset_s_n)
    begin : s_wrptrctl
      if (!reset_s_n)
          wrptr_gray    <= {4{1'b0}};
      else if (sync_done_sync)
          wrptr_gray    <= {4{1'b0}};
      else if(wrptr_en)
          wrptr_gray    <= nxt_wrptr_gray;
    end

  generate

  if (BUFFER_DEPTH==6) begin: wrptr_gray_to_bin_6_gen

  always @(wrptr_gray)
    begin
      case (wrptr_gray[3:0])
        4'b0000: wrptr_bin = 3'd0;
        4'b0001: wrptr_bin = 3'd1;
        4'b0011: wrptr_bin = 3'd2;
        4'b0010: wrptr_bin = 3'd3;
        4'b0110: wrptr_bin = 3'd4;
        4'b0111: wrptr_bin = 3'd5;
        4'b1111: wrptr_bin = 3'd0;
        4'b1110: wrptr_bin = 3'd1;
        4'b1010: wrptr_bin = 3'd2;
        4'b1011: wrptr_bin = 3'd3;
        4'b1001: wrptr_bin = 3'd4;
        4'b1000: wrptr_bin = 3'd5;
        4'b0100,
        4'b1100,
        4'b0101,
        4'b1101: wrptr_bin = 3'd0;
        default: wrptr_bin = {3{1'bx}};
      endcase
    end
  end

  if (BUFFER_DEPTH==8) begin: wrptr_gray_to_bin_8_gen
  always @(wrptr_gray)
    begin
      case (wrptr_gray[3:0])
        4'b0000: wrptr_bin = 3'd0;
        4'b0001: wrptr_bin = 3'd1;
        4'b0011: wrptr_bin = 3'd2;
        4'b0010: wrptr_bin = 3'd3;
        4'b0110: wrptr_bin = 3'd4;
        4'b0111: wrptr_bin = 3'd5;
        4'b0101: wrptr_bin = 3'd6;
        4'b0100: wrptr_bin = 3'd7;
        4'b1100: wrptr_bin = 3'd0;
        4'b1101: wrptr_bin = 3'd1;
        4'b1111: wrptr_bin = 3'd2;
        4'b1110: wrptr_bin = 3'd3;
        4'b1010: wrptr_bin = 3'd4;
        4'b1011: wrptr_bin = 3'd5;
        4'b1001: wrptr_bin = 3'd6;
        4'b1000: wrptr_bin = 3'd7;
        default: wrptr_bin = {3{1'bx}};
      endcase
    end
  end

  endgenerate

  generate
  if (BUFFER_DEPTH==6) begin: rd_ptr_gray_6_gen

  always @(rdptr_gray_sync)
    begin
      case (rdptr_gray_sync[3:0])
        4'b0000: rdptr_gray_bin = 3'd0;
        4'b0001: rdptr_gray_bin = 3'd1;
        4'b0011: rdptr_gray_bin = 3'd2;
        4'b0010: rdptr_gray_bin = 3'd3;
        4'b0110: rdptr_gray_bin = 3'd4;
        4'b0111: rdptr_gray_bin = 3'd5;
        4'b1111: rdptr_gray_bin = 3'd0;
        4'b1110: rdptr_gray_bin = 3'd1;
        4'b1010: rdptr_gray_bin = 3'd2;
        4'b1011: rdptr_gray_bin = 3'd3;
        4'b1001: rdptr_gray_bin = 3'd4;
        4'b1000: rdptr_gray_bin = 3'd5;
        4'b0100,
        4'b1100,
        4'b0101,
        4'b1101: rdptr_gray_bin = 3'd0;
        default: rdptr_gray_bin = {3{1'bx}};
      endcase
    end
  end

  if (BUFFER_DEPTH==8) begin: rd_ptr_gray_8_gen

  always @(rdptr_gray_sync)
    begin
      case (rdptr_gray_sync[3:0])
        4'b0000: rdptr_gray_bin = 3'd0;
        4'b0001: rdptr_gray_bin = 3'd1;
        4'b0011: rdptr_gray_bin = 3'd2;
        4'b0010: rdptr_gray_bin = 3'd3;
        4'b0110: rdptr_gray_bin = 3'd4;
        4'b0111: rdptr_gray_bin = 3'd5;
        4'b0101: rdptr_gray_bin = 3'd6;
        4'b0100: rdptr_gray_bin = 3'd7;
        4'b1100: rdptr_gray_bin = 3'd0;
        4'b1101: rdptr_gray_bin = 3'd1;
        4'b1111: rdptr_gray_bin = 3'd2;
        4'b1110: rdptr_gray_bin = 3'd3;
        4'b1010: rdptr_gray_bin = 3'd4;
        4'b1011: rdptr_gray_bin = 3'd5;
        4'b1001: rdptr_gray_bin = 3'd6;
        4'b1000: rdptr_gray_bin = 3'd7;
        default: rdptr_gray_bin = {3{1'bx}};
      endcase
    end
  end

  endgenerate
  assign data_rdy = (~((wrptr_bin == rdptr_gray_bin) & (wrptr_gray[3] != rdptr_gray_sync[3])));
  assign fifo_empty = (wrptr_gray == rdptr_gray_sync);
  assign atreadys = ((data_rdy & write_en & lpi_state_en)) | (pwr_lpi_state == PWR_DWN);


  assign lpi_state_en = (clk_qreq_n_sync | clk_qaccept_n) &
                        (
                          ~(
                            (flush_state == F_FLUSH_COMPLETE) |
                            (flush_state == F_NO_FLUSH)
                           )
                          |
                           pwr_lpi_state == LPI_IDLE
                        );


  always @(posedge clk_s or negedge reset_s_n)
  begin
    if (!reset_s_n) begin
      pwr_lpi_state   <= PWR_DWN;
      sync_clear  <= 1'b1;
      pwr_lp_done <= 1'b1;
      lpi_flush   <= 1'b0;

    end
    else begin
      pwr_lpi_state   <= nxt_pwr_lpi_state;
      sync_clear  <= nxt_sync_clear;
      pwr_lp_done <= nxt_pwr_lp_done;
      lpi_flush <= nxt_lpi_flush;
    end
  end

  always @* begin
    nxt_pwr_lpi_state = pwr_lpi_state;
    nxt_sync_clear    = sync_clear;
    nxt_pwr_lp_done   = pwr_lp_done;
    nxt_lpi_flush     = lpi_flush;

    if (clk_lpi_state != CLK_LP_DWN)
    begin

      case (pwr_lpi_state)
        LPI_IDLE: begin
          if (pwr_lp_request) begin
            nxt_sync_clear = 1'b0;
            if (flush_state == F_IDLE) begin
              nxt_pwr_lpi_state = LPI_FLUSH_REQ;
              nxt_lpi_flush = 1'b1;
            end
            else begin
              nxt_pwr_lpi_state = LPI_IDLE;
              nxt_lpi_flush = 1'b0;
            end
          end
        end
        LPI_FLUSH_REQ: begin
          if (flush_state == F_NO_FLUSH) begin
            nxt_pwr_lpi_state = LPI_FIFO_EMPTYING;
            nxt_lpi_flush = 1'b0;
          end
        end
        LPI_FIFO_EMPTYING: begin
          if (fifo_empty) begin
            nxt_pwr_lpi_state = LPI_WAIT_FOR_MASTER_DOWN;
            nxt_sync_clear = 1'b1;
          end
        end
        LPI_WAIT_FOR_MASTER_DOWN: begin
          if (sync_done_sync) begin
            nxt_pwr_lpi_state = PWR_DWN;
            nxt_pwr_lp_done = 1'b1;
          end
        end
        PWR_DWN: begin
          if (!pwr_lp_request) begin
            nxt_pwr_lpi_state = LPI_WAIT_FOR_MASTER_UP;
          end
          else begin
            nxt_sync_clear = 1'b1;
            nxt_pwr_lpi_state = PWR_DWN;
          end
        end
        LPI_WAIT_FOR_MASTER_UP: begin
          if (sync_done_sync) begin
            nxt_pwr_lpi_state = LPI_MST_RDY;
            nxt_sync_clear = 1'b0;
          end
          else begin
            nxt_sync_clear = 1'b1;
            nxt_pwr_lpi_state = LPI_WAIT_FOR_MASTER_UP;
          end
        end
        LPI_MST_RDY : begin
          if (!sync_done_sync) begin
            nxt_pwr_lp_done = 1'b0;
            nxt_pwr_lpi_state = LPI_IDLE;
          end
        end
        LPI_UNUSED_3: nxt_pwr_lpi_state = LPI_IDLE;
        default: begin
          nxt_pwr_lpi_state = 3'bxxx;
          nxt_sync_clear = 1'bx;
        end
      endcase
    end
  end


endmodule

