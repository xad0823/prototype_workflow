//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2009-2010, 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_tmc
//
//----------------------------------------------------------------------------


module css600_tmc_apbreadfifo
#(
  parameter TMC_CONFIG     = 0,
  parameter ATB_DATA_WIDTH = 128,
  parameter WB_DATA_WIDTH  = 256
)
(
  input wire                              clk,
  input wire                              cg_en,
  input wire                              reset_n,

  input wire                              rrd_rd_req,
  output reg                              rrd_rd_ack,
  output wire                      [31:0] rrd_rd_data,

  output reg                              rb_req_valid,
  input wire                              rb_req_ready,
  input wire                              rb_rdata_valid,
  input wire          [WB_DATA_WIDTH-1:0] rb_data,

  input wire                              mem_err,
  input wire                              apbreadfifo_clr,
  output reg                              apb_read_fifo_rrp_en
);

  `include "css600_tmc_localparams.v"


  localparam FIFO_DEPTH         = (TMC_CONFIG == ETR) ?
                                    ((ATB_DATA_WIDTH == 128) ? 4 :
                                     (ATB_DATA_WIDTH == 64)  ? 2 : 1) :
                                    ((ATB_DATA_WIDTH == 128) ? 8 :
                                     (ATB_DATA_WIDTH == 64)  ? 4 : 2);
  localparam FIFO_DEPTH_MINUS_2 = (TMC_CONFIG == ETR) ?
                                    ((ATB_DATA_WIDTH == 128) ? 2 : 0) :
                                    ((ATB_DATA_WIDTH == 128) ? 6 :
                                     (ATB_DATA_WIDTH == 64)  ? 2 : 0);
  localparam PTR_WIDTH          = (TMC_CONFIG == ETR) ?
                                    ((ATB_DATA_WIDTH == 128) ? 2 : 1) :
                                    ((ATB_DATA_WIDTH == 128) ? 3 :
                                     (ATB_DATA_WIDTH == 64)  ? 2 : 1);

  localparam CONST_ONE          = 1;

  localparam FIFO_EMPTY      = 1'b0;
  localparam FIFO_REQ_RAISED = 1'b1;
  localparam FIFO_EMPTY_MULT      = 2'b00;
  localparam FIFO_REQ_RAISED_MULT = 2'b01;
  localparam FIFO_NOT_EMPTY_MULT  = 2'b10;


  reg  [31:0]                 apb_read_fifo[FIFO_DEPTH-1:0];

  reg  [PTR_WIDTH-1:0]        rptr;
  reg  [PTR_WIDTH-1:0]        nxt_rptr;

  wire                        nxt_rb_req_valid;
  reg                         nxt_apb_read_fifo_rrp_en;
  reg                         rb_req_set;
  reg                         nxt_rrd_rd_ack;
  reg  [WB_DATA_WIDTH-1:0]    rb_data_hold;

  integer                     loopvar_i;


  assign nxt_rb_req_valid = rb_req_set | (rb_req_valid & ~rb_req_ready);

  generate
    if ((TMC_CONFIG == ETR) && (ATB_DATA_WIDTH == 32))
      begin : gen_fsm_onerd
        reg fifo_state;
        reg nxt_fifo_state;

        always @*
        begin : c_apbreadfifo_fsm_onerd
          rb_req_set            = 1'b0;
          nxt_fifo_state        = fifo_state;
          nxt_rrd_rd_ack        = 1'b0;
          apb_read_fifo_rrp_en  = 1'b0;

          case (fifo_state)
            FIFO_EMPTY :
              begin
                rb_req_set        = rrd_rd_req;
                nxt_fifo_state    = rrd_rd_req ? FIFO_REQ_RAISED : FIFO_EMPTY;
              end

            FIFO_REQ_RAISED :
              begin
                nxt_fifo_state    = rb_rdata_valid ? FIFO_EMPTY : FIFO_REQ_RAISED;
                nxt_rrd_rd_ack    = rb_rdata_valid;
              end

            default :
              begin
                nxt_rrd_rd_ack    = 1'bx;
                nxt_fifo_state    = 1'bx;
                rb_req_set        = 1'bx;
              end
          endcase
        end

        assign rrd_rd_data = apb_read_fifo[1'b0];

        always @ (posedge clk or negedge reset_n)
        begin : s_fifo_state
          if (!reset_n)
            fifo_state <= FIFO_EMPTY;
          else if (cg_en)
            fifo_state <= nxt_fifo_state;
        end

        wire [1:0] dummy_net;
        assign dummy_net = {mem_err, apbreadfifo_clr};

      end
    else
      begin : gen_fsm_multrd
        reg [1:0] fifo_state;
        reg [1:0] nxt_fifo_state;

        always @*
        begin : c_apbreadfifo_fsm_multrd
          nxt_fifo_state           = fifo_state;
          nxt_rptr                 = rptr;
          rb_req_set               = 1'b0;
          nxt_rrd_rd_ack           = 1'b0;
          nxt_apb_read_fifo_rrp_en = 1'b0;

          case (fifo_state)
            FIFO_EMPTY_MULT :
              begin
                nxt_rptr          = rptr;
                rb_req_set        = rrd_rd_req;
                nxt_fifo_state    = rrd_rd_req ? FIFO_REQ_RAISED_MULT : FIFO_EMPTY_MULT;
              end

            FIFO_REQ_RAISED_MULT :
              begin
                nxt_fifo_state    = rb_rdata_valid ? (mem_err ? FIFO_EMPTY_MULT : FIFO_NOT_EMPTY_MULT)
                                                   :  FIFO_REQ_RAISED_MULT;
                nxt_rrd_rd_ack    = rb_rdata_valid;
                nxt_rptr          = rb_rdata_valid ? {PTR_WIDTH{1'b0}} : rptr;
              end

            FIFO_NOT_EMPTY_MULT :
              begin
                nxt_rrd_rd_ack    = rrd_rd_req;
                nxt_rptr          = rrd_rd_req ? rptr + CONST_ONE[PTR_WIDTH-1:0] : rptr;
                nxt_apb_read_fifo_rrp_en = rrd_rd_req & (rptr == FIFO_DEPTH_MINUS_2[PTR_WIDTH-1:0]);
                nxt_fifo_state    = apbreadfifo_clr ||
                                   (rrd_rd_req && (rptr == FIFO_DEPTH_MINUS_2[PTR_WIDTH-1:0])) ?
                                      FIFO_EMPTY_MULT : FIFO_NOT_EMPTY_MULT;
            end

            default :
              begin
                nxt_rrd_rd_ack            = 1'bx;
                nxt_rptr                  = {PTR_WIDTH{1'bx}};
                nxt_fifo_state            = 2'bxx;
                rb_req_set                = 1'bx;
                nxt_apb_read_fifo_rrp_en  = 1'bx;
              end
          endcase
        end

        assign rrd_rd_data = apb_read_fifo[rptr];

        always @(posedge clk or negedge reset_n)
        begin : s_fifo_state
          if (!reset_n) begin
            rptr                  <= {PTR_WIDTH{1'b0}};
            apb_read_fifo_rrp_en  <= 1'b0;
            fifo_state            <= FIFO_EMPTY_MULT;
          end else
          if (cg_en)
          begin
            apb_read_fifo_rrp_en  <= nxt_apb_read_fifo_rrp_en;
            rptr                  <= nxt_rptr;
            fifo_state            <= nxt_fifo_state;
          end
        end

      end
  endgenerate

  always @*
  begin : c_apb_read_fifo
    for (loopvar_i=0; loopvar_i < FIFO_DEPTH; loopvar_i=loopvar_i+1) begin
      apb_read_fifo[loopvar_i] = rb_data_hold[loopvar_i*32 +: 32];
    end
  end

  always @(posedge clk)
  begin : s_rb_rdata_hold
    if (cg_en && rb_rdata_valid)
      rb_data_hold <= rb_data;
  end

  always @(posedge clk or negedge reset_n)
  begin : s_fifo_reg_stage
    if (!reset_n) begin
      rrd_rd_ack   <= 1'b0;
      rb_req_valid <= 1'b0;
    end else
      if (cg_en)
      begin
        rrd_rd_ack   <= nxt_rrd_rd_ack;
        rb_req_valid <= nxt_rb_req_valid;
      end
  end


endmodule
