//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module firewall_f0_fifo #(
    parameter FIFO_WIDTH      = 64,
    parameter FIFO_DEPTH      = 16,
    parameter LOG2_FIFO_DEPTH = 4
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       fifo_pop,
    output wire [FIFO_WIDTH-1:0]      fifo_dataout,
    output wire                       fifo_empty,
    input  wire                       fifo_push,
    input  wire [FIFO_WIDTH-1:0]      fifo_datain,
    output wire                       fifo_full,
    output wire [LOG2_FIFO_DEPTH-1:0] fifo_writeptr,
    output wire [LOG2_FIFO_DEPTH-1:0] fifo_readptr
);


reg  [FIFO_WIDTH-1:0]        ffarray [FIFO_DEPTH-1:0];

reg  [LOG2_FIFO_DEPTH-1:0]   readptr_r;
reg  [LOG2_FIFO_DEPTH-1:0]   writeptr_r;
reg                          readptr_wrap_r;
reg                          writeptr_wrap_r;

wire [LOG2_FIFO_DEPTH-1:0]   readptr_nxt;
wire [LOG2_FIFO_DEPTH-1:0]   writeptr_nxt;
wire                         readptr_wrap_nxt;
wire                         writeptr_wrap_nxt;

wire                         wr_sel_en;


always @(posedge clk)
begin
  if (wr_sel_en) begin
    ffarray[writeptr_r] <= fifo_datain;
  end
end

assign fifo_dataout = ffarray[readptr_r];

wire readptr_en;
wire writeptr_en;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    readptr_r         <= {LOG2_FIFO_DEPTH{1'b0}};
    writeptr_r        <= {LOG2_FIFO_DEPTH{1'b0}};
    readptr_wrap_r    <= 1'b0;
    writeptr_wrap_r   <= 1'b0;
  end
  else begin
    if (readptr_en) begin
      readptr_r       <= readptr_nxt;
      readptr_wrap_r  <= readptr_wrap_nxt;
    end
    if (writeptr_en) begin
      writeptr_r      <= writeptr_nxt;
      writeptr_wrap_r <= writeptr_wrap_nxt;
    end
  end
end

assign readptr_en   = fifo_pop;
assign writeptr_en  = fifo_push;

generate
  if (LOG2_FIFO_DEPTH == 1) begin : LOG2_DEPTH_1
    assign readptr_nxt  = (readptr_r == (FIFO_DEPTH-1)) ?
                          {LOG2_FIFO_DEPTH{1'b0}} : readptr_r + 1'b1;
    assign writeptr_nxt = (writeptr_r == (FIFO_DEPTH-1)) ?
                          {LOG2_FIFO_DEPTH{1'b0}} : writeptr_r + 1'b1;
  end
  else begin: LOG2_DEPTH_NOT_1
    assign readptr_nxt = (readptr_r == (FIFO_DEPTH-1)) ?
                         {LOG2_FIFO_DEPTH{1'b0}} : readptr_r + {{(LOG2_FIFO_DEPTH-1){1'b0}} ,1'b1};
    assign writeptr_nxt = (writeptr_r == (FIFO_DEPTH-1)) ?
                          {LOG2_FIFO_DEPTH{1'b0}} : writeptr_r + {{(LOG2_FIFO_DEPTH-1){1'b0}} ,1'b1};
  end
endgenerate

assign readptr_wrap_nxt  = (readptr_r == (FIFO_DEPTH-1)) ? ~readptr_wrap_r : readptr_wrap_r;
assign writeptr_wrap_nxt = (writeptr_r == (FIFO_DEPTH-1)) ? ~writeptr_wrap_r : writeptr_wrap_r;

assign fifo_empty = (readptr_r == writeptr_r) & (readptr_wrap_r == writeptr_wrap_r);

assign fifo_full  = (readptr_r == writeptr_r) & (readptr_wrap_r != writeptr_wrap_r);

assign wr_sel_en = writeptr_en;

assign fifo_readptr  = readptr_r;
assign fifo_writeptr = writeptr_r;

endmodule
