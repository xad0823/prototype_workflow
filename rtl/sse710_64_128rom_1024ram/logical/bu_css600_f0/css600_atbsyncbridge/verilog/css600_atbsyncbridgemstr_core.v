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
//   Sub-module of css600_atbsyncbridge
//
//----------------------------------------------------------------------------


module css600_atbsyncbridgemstr_core # (
    parameter ATB_DATA_WIDTH = 32
)

(
  clk_m,

  reset_m_n,

  afready_m,
  afvalid_m,

  atvalid_m,
  atready_m,
  atid_m,
  atbytes_m,
  atdata_m,

  atb_fwd_data,
  flush_req,
  flush_done,
  wr_pointer,
  rd_pointer,
  sync_clear,
  sync_done,
  pulse_done

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
  localparam PAYLD_WIDTH     = (ATBYTES_WIDTH+ATB_DATA_WIDTH+7);

  localparam FIFO_PTR_WIDTH = 1;
  localparam FIFO_DEPTH     = 2;

  localparam  F_IDLE          =2'b00;
  localparam  F_SLAVE_FLUSH   =2'b01;
  localparam  F_MSTR_FLUSH    =2'b10;
  localparam  F_FLUSH_COMPLETE=2'b11;
  localparam  F_UNDEFINED     =2'bxx;

  localparam  LP_IDLE           = 2'b00;
  localparam  LP_WAIT_FOR_EMPTY = 2'b01;
  localparam  LP_PWR_DWN        = 2'b10;
  localparam  LP_UNUSED         = 2'b11;
  localparam  LP_UNDEFINED      = 2'bxx;


  input   wire clk_m;
  input   wire reset_m_n;

  output  wire atvalid_m;
  output  wire [6:0] atid_m;
  output  wire [ATBYTES_WIDTH-1:0] atbytes_m;
  output  wire [ATB_DATA_WIDTH - 1:0] atdata_m;
  input   wire atready_m;

  output  wire afready_m;
  input   wire afvalid_m;

  input   wire [2*PAYLD_WIDTH+1:0] atb_fwd_data;
  output  wire flush_req;
  input   wire flush_done;
  input   wire [1:0] wr_pointer;
  output  wire [1:0] rd_pointer;
  input   wire sync_clear;
  output  reg  sync_done;
  input   wire pulse_done;


  wire [PAYLD_WIDTH-1 :0] fifo_payload [FIFO_DEPTH-1 :0];
  wire                    nxt_fifo_empty;

  wire                    inc_rd_ptr;
  wire [FIFO_PTR_WIDTH:0] nxt_rd_ptr;


  wire                    nxt_afreadym;
  wire                    nxt_end_of_flush;
  wire                    nxt_valid_entry;


  wire                    flush_fifo_empty;
  wire [FIFO_PTR_WIDTH:0] flush_end_wr_ptr;

  wire                    output_off;
  wire                    nxt_flush_req;


  reg  [FIFO_PTR_WIDTH:0] rd_ptr;
  reg [PAYLD_WIDTH-1:0]   payload_dst;

  reg                     valid_entry_reg;

  reg [1:0]               nxt_flush_state;
  reg [1:0]               flush_state;
  reg                     iafreadym;

  reg                     iflush_req;

  wire                    payload_load;
  reg  [PAYLD_WIDTH-1:0]  payload_q;

  reg                     end_of_flush;

  reg                     nxt_sync_done;

  reg [1:0]               lpi_state;
  reg [1:0]               nxt_lpi_state;


  assign nxt_rd_ptr  = (inc_rd_ptr ? rd_ptr+2'b1 : rd_ptr);

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      rd_ptr <= {(FIFO_PTR_WIDTH+1){1'b0}};
    else if (lpi_state == LP_PWR_DWN)
      rd_ptr <= {(FIFO_PTR_WIDTH+1){1'b0}};
    else
      rd_ptr <= nxt_rd_ptr;
  end

  assign rd_pointer = nxt_rd_ptr;


  assign inc_rd_ptr = valid_entry_reg & atready_m;


  assign nxt_fifo_empty = (nxt_rd_ptr == wr_pointer);


  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      end_of_flush <= 1'b0;
    else
      if (flush_done)
        end_of_flush <= 1'b1;
      else
        end_of_flush <= 1'b0;
  end


  assign flush_fifo_empty = (nxt_rd_ptr == flush_end_wr_ptr);


  assign nxt_end_of_flush = ~iafreadym & (end_of_flush | flush_done);

  assign nxt_valid_entry = ~nxt_fifo_empty & (nxt_end_of_flush ? ~flush_fifo_empty : 1'b1);

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      valid_entry_reg <= 1'b0;
    else if (nxt_sync_done)
      valid_entry_reg <= 1'b0;
    else
      valid_entry_reg <= nxt_valid_entry;
  end

  assign atvalid_m = valid_entry_reg;


  always @*
  begin
    nxt_sync_done = sync_done;

    case (lpi_state)
      LP_IDLE            : begin
                            if (sync_clear)
                              nxt_lpi_state = LP_WAIT_FOR_EMPTY;
                            else
                              nxt_lpi_state = LP_IDLE;
                            end

      LP_WAIT_FOR_EMPTY  : begin
                            if (!nxt_valid_entry && !pulse_done)
                              nxt_lpi_state = LP_PWR_DWN;
                            else
                              nxt_lpi_state = LP_WAIT_FOR_EMPTY;
                           end

      LP_PWR_DWN :         begin
                            if (!sync_clear) begin
                              nxt_lpi_state = LP_IDLE;
                              nxt_sync_done = 1'b0;
                            end
                            else begin
                              nxt_lpi_state = LP_PWR_DWN;
                              nxt_sync_done = 1'b1;
                            end
                           end

      LP_UNUSED : nxt_lpi_state = LP_PWR_DWN;

      default   : begin
                    nxt_sync_done = 1'bx;
                    nxt_lpi_state = LP_UNDEFINED;
                  end

   endcase
  end

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      lpi_state <= LP_PWR_DWN;
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


  assign fifo_payload[0] = atb_fwd_data[PAYLD_WIDTH-1:0];
  assign fifo_payload[1] = atb_fwd_data[2*PAYLD_WIDTH-1:PAYLD_WIDTH];
  assign flush_end_wr_ptr = atb_fwd_data[2*PAYLD_WIDTH+1:2*PAYLD_WIDTH];

  always @*
  begin  : p_payload_out
    case (nxt_rd_ptr)
      2'b01,
      2'b11: payload_dst = fifo_payload[1];
      2'b00,
      2'b10: payload_dst = fifo_payload[0];
      default : payload_dst = {PAYLD_WIDTH{1'bx}};
    endcase
  end

  assign output_off = sync_clear & nxt_sync_done;
  assign payload_load = nxt_valid_entry && !output_off;

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      payload_q <= {PAYLD_WIDTH{1'b0}};
    else if (payload_load) begin
      payload_q <= payload_dst;
    end
  end

  assign {atbytes_m, atid_m, atdata_m} = payload_q;


  always @*
  begin

    nxt_flush_state = flush_state;
    case (flush_state)

    F_IDLE            : nxt_flush_state = (afvalid_m && ~iafreadym) ? F_SLAVE_FLUSH : F_IDLE;
    F_SLAVE_FLUSH    : nxt_flush_state = flush_done ? (flush_fifo_empty ? F_FLUSH_COMPLETE :F_MSTR_FLUSH) : F_SLAVE_FLUSH;
    F_MSTR_FLUSH      : nxt_flush_state = flush_fifo_empty ? (flush_done ? F_FLUSH_COMPLETE : F_IDLE) : F_MSTR_FLUSH;
    F_FLUSH_COMPLETE  : nxt_flush_state = flush_done ? F_FLUSH_COMPLETE : F_IDLE;
    default            : nxt_flush_state = F_UNDEFINED;
   endcase
  end


  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
     flush_state  <= F_IDLE;
    else if (output_off)
     flush_state  <= F_IDLE;
    else
     flush_state  <= nxt_flush_state;
  end


  assign nxt_flush_req = ((nxt_flush_state== F_SLAVE_FLUSH) && ~iflush_req) ? 1'b1 : ~(nxt_flush_state != F_SLAVE_FLUSH & flush_state == F_SLAVE_FLUSH) & iflush_req ;

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
      iflush_req  <= 1'b0;
    else if (lpi_state == LP_PWR_DWN)
      iflush_req  <= 1'b0;
    else
      iflush_req <= nxt_flush_req;
  end
  assign flush_req = iflush_req;


  assign nxt_afreadym = ((nxt_flush_state == F_IDLE & flush_state[1] == 1'b1) & ~iafreadym);

  always @(posedge clk_m or negedge reset_m_n)
  begin
    if (!reset_m_n)
     iafreadym  <= 1'b1;
    else
      iafreadym <= nxt_afreadym;
  end

  assign afready_m = iafreadym | (sync_clear & sync_done);

endmodule
