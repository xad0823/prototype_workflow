
// ------------------------------------------------------------------------------
// 
// Copyright 2005 - 2022 Synopsys, INC.
// 
// This Synopsys IP and all associated documentation are proprietary to
// Synopsys, Inc. and may only be used pursuant to the terms and conditions of a
// written license agreement with Synopsys, Inc. All other use, reproduction,
// modification, or distribution of the Synopsys IP or the associated
// documentation is strictly prohibited.
// Inclusivity & Diversity - Visit SolvNetPlus to read the "Synopsys Statement on
//            Inclusivity and Diversity" (Refer to article 000036315 at
//                        https://solvnetplus.synopsys.com)
// 
// Component Name   : DW_axi_x2h
// Component Version: 2.05a
// Release Type     : GA
// Build ID         : 13.18.16.11
// ------------------------------------------------------------------------------

//
// Description : DW_axi_x2h_bcm66.v Verilog module for DW_axi_x2h
//
// DesignWare IP ID: 4f8c23e1
//
////////////////////////////////////////////////////////////////////////////////



module DW_axi_x2h_bcm66(
                clk_push,
                rst_push_n,
                init_push_n,
                push_req_n,
                data_in,
                push_empty,
                nxt_push_empty,
                push_ae,
                push_hf,
                push_af,
                push_full,
                nxt_push_full,
                push_error,
                push_word_count,
                we_n,
                wr_addr,

                clk_pop,
                rst_pop_n,
                init_pop_n,
                pop_req_n,
                pop_empty,
                nxt_pop_empty,
                pop_ae,
                pop_hf,
                pop_af,
                pop_full,
                nxt_pop_full,
                pop_error,
                pop_word_count,
                data_out
                );

parameter integer WIDTH = 8;            // RANGE 1 to 2048
parameter integer DEPTH = 8;            // RANGE 2 to 1024
parameter integer ADDR_WIDTH = 3;       // RANGE 1 to 10
parameter integer COUNT_WIDTH = 4;      // RANGE 2 to 11
parameter integer PUSH_AE_LVL = 2;      // RANGE 1 to DEPTH-1
parameter integer PUSH_AF_LVL = 2;      // RANGE 1 to DEPTH-1
parameter integer POP_AE_LVL = 2;       // RANGE 1 to DEPTH-1
parameter integer POP_AF_LVL = 2;       // RANGE 1 to DEPTH-1
parameter integer ERR_MODE = 0;         // RANGE 0 to 1
parameter integer PUSH_SYNC = 2;        // RANGE 1 to 4
parameter integer POP_SYNC = 2;         // RANGE 1 to 4
parameter integer RST_MODE = 0;         // RANGE 0 to 1
parameter integer VERIF_EN = 1;         // RANGE 0 to 5
parameter integer MEM_MODE = 0;         // RANGE 0 to 7
parameter integer EARLY_DATA_EN = 0;    // RANGE 0 to 1

localparam CTRLR_MEM_MODE = MEM_MODE >> 1;

localparam MEM_DEPTH  =  (DEPTH == (1<<ADDR_WIDTH))? DEPTH : DEPTH + (((DEPTH % 2) == 1)? 1 : 2);
localparam UNS_MEM_DEPTH = $unsigned(MEM_DEPTH);

   input                       clk_push;         // push domain clock input
   input                       rst_push_n;       // push domain async. reset
   input                       init_push_n;      // push domain sync. reset
   input                       push_req_n;       // push domain push request
   input [WIDTH-1:0]           data_in;          // FIFO input data bus (push domain)
   output                      push_empty;       // push domain empty status flag
   output                      nxt_push_empty;   // push domain early empty status flag
   output                      push_ae;          // push domain almost empty status flag
   output                      push_hf;          // push domain half full status flag
   output                      push_af;          // push domain almost full status flag
   output                      push_full;        // push domain full status flag
   output                      nxt_push_full;    // push domain early full status flag
   output                      push_error;       // push domain error status flag
   output [COUNT_WIDTH-1:0]    push_word_count;  // push domain FIFO word count
   output                      we_n;             // Push domain active low RAM write enable
   output [ADDR_WIDTH-1 : 0]   wr_addr;          // Push domain RAM write address

   input                       clk_pop;          // pop domain clock input
   input                       rst_pop_n;        // pop domain async. reset
   input                       init_pop_n;       // pop domain sync. reset
   input                       pop_req_n;        // pop domain pop request
   output                      pop_empty;        // pop domain empty status flag
   output                      nxt_pop_empty;    // pop domain early empty status flag
   output                      pop_ae;           // pop domain almost empty status flag
   output                      pop_hf;           // pop domain half full status flag
   output                      pop_af;           // pop domain almost full status flag
   output                      pop_full;         // pop domain full status flag
   output                      nxt_pop_full;     // pop domain early full status flag
   output                      pop_error;        // pop domain error status flag
   output [COUNT_WIDTH-1:0]    pop_word_count;   // pop domain FIFO word count
   output [WIDTH-1:0]          data_out;         // FIFO input data bus (pop domain)
wire [ADDR_WIDTH-1 : 0] wr_addr_int;
wire [ADDR_WIDTH-1 : 0] rd_addr_int;
wire [ADDR_WIDTH-1 : 0] rd_addr_inc;
wire [WIDTH-1 : 0]      pre_data_out;

wire we_n_int;
wire rd_n_int;
wire pop_empty_int;
wire pop_full_int;
wire [COUNT_WIDTH-1:0] pop_word_count_int;


generate
  if(EARLY_DATA_EN==0) begin : GEN_FIFOCTL_EDE_EQ_0
    // Instance of DW_axi_x2h_bcm07_efes
    DW_axi_x2h_bcm07_efes
     #(
                       DEPTH,
                       ADDR_WIDTH,
                       COUNT_WIDTH,
                       PUSH_AE_LVL,
                       PUSH_AF_LVL,
                       POP_AE_LVL,
                       POP_AF_LVL,
                       ERR_MODE,
                       PUSH_SYNC,
                       POP_SYNC,
                       CTRLR_MEM_MODE,
                       VERIF_EN
                       )
      U_FIFO_CTL (
          .clk_push(clk_push),
          .rst_push_n(rst_push_n),
          .init_push_n(init_push_n),
          .push_req_n(push_req_n),
          .pop_req_n(pop_req_n),
          .push_empty(push_empty),
          .nxt_push_empty(nxt_push_empty),
          .push_ae(push_ae),
          .push_hf(push_hf),
          .push_af(push_af),
          .push_full(push_full),
          .nxt_push_full(nxt_push_full),
          .push_error(push_error),
          .push_word_count(push_word_count),
          .we_n(we_n_int),
          .wr_addr(wr_addr_int),

          .clk_pop(clk_pop),
          .rst_pop_n(rst_pop_n),
          .init_pop_n(init_pop_n),
          .pop_empty(pop_empty_int),
          .nxt_pop_empty(nxt_pop_empty),
          .pop_ae(pop_ae),
          .pop_hf(pop_hf),
          .pop_af(pop_af),
          .pop_full(pop_full_int),
          .nxt_pop_full(nxt_pop_full),
          .pop_error(pop_error),
          .pop_word_count(pop_word_count_int),
          .rd_addr(rd_addr_int) );

    assign rd_n_int    = pop_req_n | pop_empty_int;
    assign rd_addr_inc = rd_addr_int;

    assign pop_empty = pop_empty_int;
    assign pop_full  = pop_full_int;
    assign pop_word_count = pop_word_count_int;
  end else begin : GEN_FIFOCTL_EDE_EQ_1
    wire                    pop_empty_early;
    wire                    pop_full_early;
    wire [COUNT_WIDTH-1:0]  pop_word_count_early;

    // Instance of DW_axi_x2h_bcm07_ef
    DW_axi_x2h_bcm07_ef
     #(
                       DEPTH,
                       ADDR_WIDTH,
                       COUNT_WIDTH,
                       PUSH_AE_LVL,
                       PUSH_AF_LVL,
                       POP_AE_LVL,
                       POP_AF_LVL,
                       ERR_MODE,
                       PUSH_SYNC,
                       POP_SYNC,
                       0,
                       0,
                       CTRLR_MEM_MODE,
                       VERIF_EN,
                       (|MEM_MODE[1:0])
                       )
      U_FIFO_CTL (
          .clk_push(clk_push),
          .rst_push_n(rst_push_n),
          .init_push_n(init_push_n),
          .push_req_n(push_req_n),
          .pop_req_n(pop_req_n),
          .push_empty(push_empty),
          .push_ae(push_ae),
          .push_hf(push_hf),
          .push_af(push_af),
          .push_full(push_full),
          .push_error(push_error),
          .push_word_count(push_word_count),
// spyglass disable_block W287b
// SMD: An output port of module or gate instance is not connected
// SJ: The following port(s) of this instance are intentionally unconnected.
          .push_empty_early(),
          .push_full_early(),
          .push_word_count_early(),
// spyglass enable_block W287b
          .we_n(we_n_int),
          .wr_addr(wr_addr_int),

          .clk_pop(clk_pop),
          .rst_pop_n(rst_pop_n),
          .init_pop_n(init_pop_n),
          .pop_empty(pop_empty_int),
          .pop_ae(pop_ae),
          .pop_hf(pop_hf),
          .pop_af(pop_af),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
          .pop_full(pop_full_int),
// spyglass enable_block W528
          .pop_error(pop_error),
          .pop_empty_early(pop_empty_early),
// spyglass disable_block W528
// SMD: A signal or variable is set but never read
// SJ: Based on component configuration, this(these) signal(s) or parts of it will not be used to compute the final result.
          .pop_word_count(pop_word_count_int),
          .pop_full_early(pop_full_early),
          .pop_word_count_early(pop_word_count_early),
// spyglass enable_block W528
          .rd_addr(rd_addr_int) );

    if ((MEM_MODE&3) == 0) begin : GEN_MM_EQ_0
      assign rd_n_int    = pop_req_n | pop_empty_int;
      assign rd_addr_inc = rd_addr_int;

      assign pop_empty = pop_empty_early;
      assign pop_full  = pop_full_early;
      assign pop_word_count = pop_word_count_early;
      assign data_out = (pop_empty_early == 1'b0) ? pre_data_out : {WIDTH{1'b0}};
    end else begin : GEN_MM_NE_0
      if ((MEM_MODE&3) == 1) begin : GEN_MM_EQ_1
        assign rd_n_int    = (pop_req_n | pop_empty_early) & (~((~pop_empty_early) & pop_empty_int));
        assign rd_addr_inc = (~pop_req_n) ? ((rd_addr_int==(UNS_MEM_DEPTH-1)) ? 0: (rd_addr_int+1)): rd_addr_int;
      end else begin : GEN_MM_EQ_2_OR_3
        assign rd_n_int    = (pop_req_n | pop_empty_early) & (~((~pop_empty_early) & pop_empty_int));
        assign rd_addr_inc = ((~pop_req_n)&(~pop_empty_int)) ? ((rd_addr_int==(UNS_MEM_DEPTH-1)) ? 0: (rd_addr_int+1)): rd_addr_int;
      end

      assign pop_empty = pop_empty_int;
      assign pop_full  = pop_full_int;
      assign pop_word_count = pop_word_count_int;

      if ((MEM_MODE&3) == 2) begin : GEN_MM_EQ_2
        assign data_out = (pop_empty_int == 1'b0) ? pre_data_out : {WIDTH{1'b0}};
      end else begin : GEN_MM_EQ_1_OR_3
        assign data_out = pre_data_out;
      end
    end

    assign nxt_push_empty = 1'b0;
    assign nxt_push_full = 1'b0;
    assign nxt_pop_empty = 1'b0;
    assign nxt_pop_full = 1'b0;
  end
endgenerate

   DW_axi_x2h_bcm58
    #(
                        WIDTH,
                        MEM_DEPTH,
                        ADDR_WIDTH,
                        MEM_MODE,
                        RST_MODE )
           U_FIFO_MEM (
                .clk_w(clk_push),
                .rst_w_n(rst_push_n),
                .en_w_n(we_n_int),
                .data_w(data_in),
                .addr_w(wr_addr_int),

                .clk_r(clk_pop),
                .rst_r_n(rst_pop_n),
                .en_r_n(rd_n_int),
                .addr_r(rd_addr_inc),
// spyglass disable_block W287b
// SMD: An output port of module or gate instance is not connected
// SJ: The following port(s) of this instance are intentionally unconnected.
                .data_r_a(),
// spyglass enable_block W287b
                .data_r(pre_data_out) );

  assign we_n    = we_n_int;
  assign wr_addr = wr_addr_int;

  generate if (EARLY_DATA_EN == 0) begin : GEN_EDE_NE_1
    wire pop_empty_int_x;
    if((MEM_MODE&3) == 0) begin : GEN_MM_EQ_0
      assign pop_empty_int_x = pop_empty_int;
    end else if ((MEM_MODE&3) != 3) begin : GEN_MM_EQ_1_OR_2
      reg pop_empty_int_q;
      always @ (posedge clk_pop or negedge rst_pop_n) begin : pop_empty_PROC
        if (rst_pop_n == 1'b0) begin
          pop_empty_int_q <= 1'b0;
        end else begin
          if (init_pop_n == 1'b0) begin
            pop_empty_int_q <= 1'b0;
          end else begin
            pop_empty_int_q <= pop_empty_int;
          end
        end
      end
      assign pop_empty_int_x = pop_empty_int_q;
    end else begin : GEN_MM_EQ_3
      reg pop_empty_int_q, pop_empty_int_qq;
      always @ (posedge clk_pop or negedge rst_pop_n) begin : pop_empty_PROC
        if (rst_pop_n == 1'b0) begin
          pop_empty_int_q  <= 1'b0;
          pop_empty_int_qq <= 1'b0;
        end else begin
          if (init_pop_n == 1'b0) begin
            pop_empty_int_q  <= 1'b0;
            pop_empty_int_qq <= 1'b0;
          end else begin
            pop_empty_int_q  <= pop_empty_int;
            pop_empty_int_qq <= pop_empty_int_q;
          end
        end
      end
      assign pop_empty_int_x = pop_empty_int_qq;
    end
    assign data_out = (pop_empty_int_x == 1'b0) ? pre_data_out : {WIDTH{1'b0}};
  end endgenerate

endmodule
