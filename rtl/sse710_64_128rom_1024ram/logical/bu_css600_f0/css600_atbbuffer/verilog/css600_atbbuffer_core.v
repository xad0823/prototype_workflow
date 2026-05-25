//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbbuffer
//
//----------------------------------------------------------------------------


module css600_atbbuffer_core #
(
  parameter ATB_DATA_WIDTH = 32,
  parameter BUFFER_DEPTH = 2,
  parameter MIN_HOLD_TIME = 1)
(
  clk,
  reset_n,

  atvalid_s,
  atready_s,
  atid_s,
  atdata_s,
  atbytes_s,

  afready_s,
  afvalid_s,

  afready_m,
  afvalid_m,

  syncreq_s,
  atwakeup_s,
  atwakeup_m,

  atvalid_m,
  atready_m,
  atid_m,
  atdata_m,
  atbytes_m,

  syncreq_m
);

function integer atb_clog2 (input integer num);
  integer i;
  begin
    atb_clog2 = 0;
    for(i=num; i>1; i=i>>1)
      atb_clog2 = atb_clog2 + 1;
  end
endfunction


  localparam ATBYTES_WIDTH = (ATB_DATA_WIDTH > 8) ? (atb_clog2(ATB_DATA_WIDTH)-3) : 1;
  localparam POINTER_WIDTH = atb_clog2(BUFFER_DEPTH);
  localparam POINTER_MSB   = POINTER_WIDTH > 1 ? (POINTER_WIDTH-1) : 1;
  localparam MIN_HOLD_TIME_LOC = MIN_HOLD_TIME <= BUFFER_DEPTH ? MIN_HOLD_TIME : BUFFER_DEPTH;

  localparam FIFO_UNLOADING         = 1'b0;
  localparam FIFO_EMPTYING          = 1'b1;

  localparam FLUSH_IDLE     = 2'b00;
  localparam FLUSHING_UPSTR = 2'b01;
  localparam FLUSHING_BUFF  = 2'b10;
  localparam FLUSHING_WAIT  = 2'b11;

  localparam PYLD_WIDTH = ATB_DATA_WIDTH+ATBYTES_WIDTH+7;
  localparam PTR_INC    = {{(POINTER_WIDTH){1'b0}}, 1'b1};


  input wire                        clk;
  input wire                        reset_n;

  input wire                        atvalid_s;
  input wire                        atready_m;
  input wire [6:0]                  atid_s;
  input wire [ATB_DATA_WIDTH-1:0]   atdata_s;
  input wire [ATBYTES_WIDTH-1:0]    atbytes_s;

  input wire                        afready_s;
  input wire                        afvalid_m;
  input wire                        syncreq_m;
  output wire                       atvalid_m;
  output wire                       atready_s;
  output wire [6:0]                 atid_m;
  output wire [ATB_DATA_WIDTH-1:0]  atdata_m;
  output wire [ATBYTES_WIDTH-1:0]   atbytes_m;

  output reg                        afready_m;
  output reg                        afvalid_s;

  output wire                       syncreq_s;
  input  wire                       atwakeup_s;
  output reg                        atwakeup_m;


  reg [PYLD_WIDTH-1:0]      atb_fifo [BUFFER_DEPTH-1 : 0];
  reg [PYLD_WIDTH-1:0]      fifo_rdata;
  reg [POINTER_WIDTH:0]     wr_ptr;
  reg [POINTER_WIDTH:0]     rd_ptr;
  reg                       buffer_empty;
  wire [POINTER_WIDTH:0]    nxt_wr_ptr;
  wire [POINTER_WIDTH:0]    nxt_rd_ptr;
  wire [POINTER_WIDTH-1:0]  fifo_wr_idx;
  wire [POINTER_WIDTH-1:0]  fifo_rd_idx;

  wire                      fifo_full;
  wire                      fifo_empty;
  wire                      ptr_eq;
  wire                      empty_ptr_eq;
  wire                      flush_fifo_empty;
  wire                      fifo_write;
  wire                      fifo_read;
  reg                       nxt_buffer_empty;
  reg [POINTER_WIDTH:0]     fifo_inc;
  reg [POINTER_WIDTH:0]     fifo_dec;

  reg                       flush_req;
  reg                       nxt_flush_req;
  reg [1:0]                 nxt_flush_state;
  reg [1:0]                 flush_state;

  wire [POINTER_WIDTH:0]    nxt_fifo_content;
  wire [POINTER_WIDTH:0]    nxt_fifo_flush_content;
  reg  [POINTER_WIDTH:0]    fifo_content;
  reg  [POINTER_WIDTH:0]    fifo_flush_content;
  reg                       fifo_state;
  reg                       nxt_fifo_state;

  wire                      flush_start;
  wire                      flush_ongoing;
  reg  [POINTER_WIDTH:0]    fifo_flush_inc;
  wire                      fifo_flush_write;

  reg                       nxt_afvalid_s;
  reg                       nxt_afready_m;
  reg                       rst_state;

  wire buffer_empty_en;
  wire afready_m_en;
  wire flush_req_en;
  wire flush_state_en;
  wire afvalid_s_en;
  wire fifo_state_en;


  assign syncreq_s = syncreq_m;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      atwakeup_m <= 1'b0;
    end
    else begin
      atwakeup_m <= atwakeup_s;
    end
  end


  assign ptr_eq     = (wr_ptr[POINTER_WIDTH-1:0] == nxt_rd_ptr[POINTER_WIDTH-1:0]);
  assign fifo_full  = (wr_ptr[POINTER_WIDTH] != nxt_rd_ptr[POINTER_WIDTH]) ? ptr_eq : 1'b0;

  assign empty_ptr_eq  = (wr_ptr[POINTER_WIDTH-1:0] == nxt_rd_ptr[POINTER_WIDTH-1:0]);
  assign fifo_empty = (wr_ptr[POINTER_WIDTH] == nxt_rd_ptr[POINTER_WIDTH]) ? empty_ptr_eq : 1'b0;

  assign flush_fifo_empty = (nxt_fifo_flush_content == {(POINTER_WIDTH+1){1'b0}}) && (flush_state != FLUSH_IDLE);

  assign atready_s = ~fifo_full & ~rst_state;


  assign fifo_write = atvalid_s & atready_s;
  assign nxt_wr_ptr = wr_ptr + PTR_INC;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      wr_ptr <= {(POINTER_WIDTH+1){1'b0}};
    end
    else if (fifo_write)
      wr_ptr <= nxt_wr_ptr;
  end

  assign fifo_wr_idx = wr_ptr[POINTER_WIDTH-1:0];

  always @(posedge clk)
  begin
    if (fifo_write) begin
      atb_fifo[fifo_wr_idx] <= {atdata_s, atbytes_s, atid_s};
    end
  end

  assign fifo_read      = atvalid_m & atready_m;
  assign nxt_rd_ptr     = fifo_read ? rd_ptr + PTR_INC : rd_ptr;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      rd_ptr <= {(POINTER_WIDTH+1){1'b0}};
    end
    else if (fifo_read)
      rd_ptr <= nxt_rd_ptr;
  end

  assign fifo_rd_idx = nxt_rd_ptr[POINTER_WIDTH-1:0];

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      fifo_rdata <= {(PYLD_WIDTH){1'b0}};
    end
    else if (nxt_buffer_empty) begin
      fifo_rdata <= atb_fifo[fifo_rd_idx];
    end
  end

  assign atvalid_m = buffer_empty;

  assign buffer_empty_en = (buffer_empty != nxt_buffer_empty);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      buffer_empty <= 1'b0;
    else if (buffer_empty_en)
      buffer_empty <= nxt_buffer_empty ;
  end

  assign atdata_m   = fifo_rdata[(ATB_DATA_WIDTH+ATBYTES_WIDTH+7-1):(ATBYTES_WIDTH+7)];
  assign atbytes_m  = fifo_rdata[(ATBYTES_WIDTH+7-1):7];
  assign atid_m     = fifo_rdata[6:0];


  always @*
    begin

      nxt_afvalid_s   = afvalid_s;
      nxt_afready_m   = afready_m;
      nxt_flush_req   = flush_req;
      nxt_flush_state = flush_state;

      case(flush_state)
        FLUSH_IDLE      : begin
                            if (afvalid_m) begin
                              nxt_flush_state = FLUSHING_UPSTR;
                              nxt_afvalid_s   = 1'b1;
                              nxt_flush_req   = 1'b1;
                            end
                          end
        FLUSHING_UPSTR  : begin
                            if (afready_s) begin
                              nxt_flush_state = FLUSHING_BUFF;
                              nxt_afvalid_s = 1'b0;

                              if (flush_fifo_empty && !fifo_write) begin
                                nxt_flush_state = FLUSHING_WAIT;
                                nxt_afready_m = 1'b1;
                                nxt_flush_req = 1'b0;
                              end
                            end
                          end
        FLUSHING_BUFF   : begin
                            if (flush_fifo_empty) begin
                              nxt_flush_state = FLUSHING_WAIT;
                              nxt_afready_m = 1'b1;
                              nxt_flush_req = 1'b0;
                            end
                          end
        FLUSHING_WAIT  :  begin
                            nxt_flush_state = FLUSH_IDLE;
                          end
        default: begin
                  nxt_afready_m = 1'bx;
                  nxt_afvalid_s = 1'bx;
                  nxt_flush_req = 1'bx;
                  nxt_flush_state = 2'bxx;
                 end
      endcase
    end

  assign afready_m_en = (nxt_afready_m | afready_m);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      afready_m <= 1'b1;
    end
    else if (afready_m_en) begin
      afready_m    <= nxt_afready_m & ~afready_m;
    end
  end

  assign afvalid_s_en = (afvalid_s != nxt_afvalid_s);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      afvalid_s <= 1'b0;
    end
    else if (afvalid_s_en) begin
      afvalid_s <= nxt_afvalid_s;
    end
  end

  assign flush_req_en = (flush_req != nxt_flush_req);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      flush_req <= 1'b0;
    end
    else if (flush_req_en) begin
      flush_req <= nxt_flush_req;
    end
  end

  assign flush_state_en = (flush_state != nxt_flush_state);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      flush_state <= 2'b0;
    end
    else if (flush_state_en) begin
      flush_state <= nxt_flush_state;
    end
  end


  always @*
    begin
        fifo_inc    = {(POINTER_WIDTH+1){1'b0}};
        fifo_inc[0] = fifo_write;
        fifo_dec    = {(POINTER_WIDTH+1){1'b0}};
        fifo_dec[0] = fifo_read;
    end

  assign nxt_fifo_content = fifo_content + fifo_inc - fifo_dec;

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      fifo_content <= {(POINTER_MSB+1){1'b0}};
    else if (fifo_read || fifo_write)
      fifo_content <= nxt_fifo_content;
  end

  assign fifo_flush_write = fifo_write & ~flush_state[1];

  always @*
    begin
        fifo_flush_inc = {{(POINTER_MSB){1'b0}}, fifo_flush_write};
    end

  assign nxt_fifo_flush_content = ( |(fifo_flush_content + fifo_flush_inc) ) ? (fifo_flush_content + fifo_flush_inc - fifo_dec) : {(POINTER_WIDTH+1){1'b0}};

  assign flush_start = (nxt_flush_state == FLUSHING_UPSTR) && (flush_state == FLUSH_IDLE);
  assign flush_ongoing = (nxt_flush_state != FLUSH_IDLE);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n)
      fifo_flush_content <= {(POINTER_WIDTH+1){1'b0}};
    else if (flush_start)
      fifo_flush_content <= nxt_fifo_content;
    else if (flush_ongoing)
      fifo_flush_content <= nxt_fifo_flush_content;
  end

  always @*
    begin

      nxt_buffer_empty = buffer_empty;
      nxt_fifo_state = fifo_state;

      case (fifo_state)
        FIFO_UNLOADING: begin
                          if ( (fifo_content >= MIN_HOLD_TIME_LOC[POINTER_WIDTH:0]) || (flush_req && (|fifo_content)) ) begin
                            nxt_fifo_state = FIFO_EMPTYING;
                            nxt_buffer_empty = 1'b1;
                          end
                          else begin
                            nxt_fifo_state = FIFO_UNLOADING;
                            nxt_buffer_empty = buffer_empty;
                          end
                        end
        FIFO_EMPTYING : begin
                          if (fifo_empty) begin
                            nxt_fifo_state = FIFO_UNLOADING;
                            nxt_buffer_empty = 1'b0;
                          end
                          else begin
                            nxt_fifo_state = FIFO_EMPTYING;
                            nxt_buffer_empty = 1'b1;
                          end
                        end
        default: begin
                    nxt_fifo_state = 1'bx;
                    nxt_buffer_empty = 1'bx;
                 end
      endcase
    end


  assign fifo_state_en = (fifo_state != nxt_fifo_state);

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      fifo_state <= 1'b0;
    end
    else if (fifo_state_en) begin
      fifo_state <= nxt_fifo_state;
    end
  end

  always @(posedge clk or negedge reset_n)
  begin
    if (!reset_n) begin
      rst_state <= 1'b1;
    end
    else if (rst_state) begin
      rst_state <= 1'b0;
    end
  end


endmodule
