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

module firewall_f0_ctlr_rd_hndlr #(
    parameter REG_DATA_WIDTH  = 32,
    parameter FC_CFG_DATA_W   = 32,
    parameter FC_MST_ID_WIDTH = 8,
    parameter FC_AXIID_WIDTH  = 2,
    parameter FW_LDE_LVL      = 0,
    parameter FW_SRE_LVL      = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire [REG_DATA_WIDTH-1:0]  rd_hndlr_acc_rd_data_i,
    input  wire                       rd_hndlr_acc_rd_rsp_i,
    input  wire                       rd_hndlr_acc_rd_tamp_i,
    input  wire                       rd_hndlr_acc_valid_i,

    input  wire [FC_CFG_DATA_W-1:0]   rd_hndlr_msg_rd_data_i,
    input  wire                       rd_hndlr_rd_last_i,
    input  wire                       rd_hndlr_msg_valid_i,

    input  wire [REG_DATA_WIDTH-1:0]  rd_hndlr_shdw_rd_data_i,
    input  wire                       rd_hndlr_shdw_valid_i,

    output wire [1:0]                 rd_hndlr_rsp_o,
    output wire                       rd_hndlr_tamp_o,
    output wire                       rd_hndlr_valid_o,
    output wire [REG_DATA_WIDTH-1:0]  rd_hndlr_data_o,
    output wire [FC_MST_ID_WIDTH-1:0] rd_hndlr_mst_id_o,
    input  wire [FC_MST_ID_WIDTH-1:0] rd_hndlr_mst_id_i,
    output wire [FC_AXIID_WIDTH-1:0]  rd_hndlr_rid_o,
    input  wire [FC_AXIID_WIDTH-1:0]  rd_hndlr_rid_i,

    output wire [REG_DATA_WIDTH-1:0]  rd_hndlr_unfrmt_rd_data_o,
    input  wire [REG_DATA_WIDTH-1:0]  rd_hndlr_frmt_rd_data_i,

    output wire                       rd_hndlr_clk_busy_o
);


`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"


localparam MSG_SM_SIZE     = 1;
localparam MSG_IDLE        = 1'b0;
localparam MSG_RECONSTRUCT = 1'b1;

localparam MAX_READ_SIZE = 35;

localparam MAX_BEATS      = firewall_f0_ceil_divide(MAX_READ_SIZE, FC_CFG_DATA_W);
localparam LOG2_MAX_BEATS = firewall_f0_log2(MAX_BEATS);

localparam READ_REG_SLICE = 1;


reg msg_sm_r;
reg msg_sm_nxt;
reg msg_reconstructed;

reg  [REG_DATA_WIDTH-1:0]  read_buffer_r;
reg  [REG_DATA_WIDTH-1:0]  read_buffer_nxt;
wire                       read_buffer_en;
reg  [1:0]                 read_rsp_r;
wire [1:0]                 read_rsp_nxt;
wire                       read_hndlr_tamp_nxt;
reg  [FC_MST_ID_WIDTH-1:0] read_mst_id_r;
wire [FC_MST_ID_WIDTH-1:0] read_mst_id_nxt;
reg  [FC_AXIID_WIDTH-1:0]  read_rid_r;
wire [FC_AXIID_WIDTH-1:0]  read_rid_nxt;

reg  [LOG2_MAX_BEATS-1:0] recnstrct_cntr_r;
wire [LOG2_MAX_BEATS-1:0] recnstrct_cntr_nxt;
wire                      recnstrct_cntr_en;
wire                      recnstrct_cntr_incr;

reg  [REG_DATA_WIDTH-1:0] recnstrct_nxt;

integer i;

wire rd_acc_shdw_valid;

wire full_rd_data;
reg  full_rd_data_r;

wire msg_rd_last;


assign msg_rd_last = rd_hndlr_msg_valid_i ? rd_hndlr_rd_last_i : 1'b0;

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    msg_sm_r <= MSG_IDLE;
  end
  else begin
    msg_sm_r <= msg_sm_nxt;
  end
end

always @* begin
  case (msg_sm_r)
    MSG_IDLE: begin
      case ({rd_hndlr_msg_valid_i, msg_rd_last})
        2'b00: begin
          msg_sm_nxt        = MSG_IDLE;
          msg_reconstructed = 1'b0;
        end
        2'b11: begin
          msg_sm_nxt        = MSG_IDLE;
          msg_reconstructed = 1'b1;
        end
        2'b10: begin
          msg_sm_nxt        = MSG_RECONSTRUCT;
          msg_reconstructed = 1'b0;
        end
        default: begin
          msg_sm_nxt        = 1'bx;
          msg_reconstructed = 1'bx;
        end
      endcase
    end
    MSG_RECONSTRUCT: begin
      case ({rd_hndlr_msg_valid_i, msg_rd_last})
        2'b00, 2'b10: begin
          msg_sm_nxt        = MSG_RECONSTRUCT;
          msg_reconstructed = 1'b0;
        end
        2'b11: begin
          msg_sm_nxt        = MSG_IDLE;
          msg_reconstructed = 1'b1;
        end
        default: begin
          msg_sm_nxt        = 1'bx;
          msg_reconstructed = 1'bx;
        end
      endcase
    end
    default: begin
      msg_sm_nxt        = 1'bx;
      msg_reconstructed = 1'bx;
    end
  endcase
end

generate
  if (MAX_BEATS > 1) begin: MULTIPLE_READ_BEATS
    always @* begin
      recnstrct_nxt = read_buffer_r;
      if (recnstrct_cntr_r == 0) begin
        recnstrct_nxt = {FC_CFG_DATA_W{1'b0}};
        recnstrct_nxt[(FC_CFG_DATA_W-1)-3:0] = rd_hndlr_msg_rd_data_i[FC_CFG_DATA_W-1:3];
      end
      else if (recnstrct_cntr_r == MAX_BEATS-1) begin
        recnstrct_nxt[REG_DATA_WIDTH-1:(FC_CFG_DATA_W*(MAX_BEATS-1))-3] =
          rd_hndlr_msg_rd_data_i[(REG_DATA_WIDTH-(FC_CFG_DATA_W*(MAX_BEATS-1))-1)+3:0];
      end
      else begin
        for (i=1; i<MAX_BEATS-1; i=i+1) begin
          if (recnstrct_cntr_r == i) begin
            recnstrct_nxt[((FC_CFG_DATA_W*(i+1))-1)-3 -: FC_CFG_DATA_W] = rd_hndlr_msg_rd_data_i;
          end
        end
      end

    end
  end
  else begin: ONE_READ_BEAT
    always @* begin
      recnstrct_nxt = {FC_CFG_DATA_W{1'b0}};
      recnstrct_nxt[(FC_CFG_DATA_W-1)-3:0] = rd_hndlr_msg_rd_data_i[FC_CFG_DATA_W-1:3];
    end
  end
endgenerate

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    recnstrct_cntr_r <= {LOG2_MAX_BEATS{1'b0}};
  end
  else begin
    if (recnstrct_cntr_en) begin
      recnstrct_cntr_r <= recnstrct_cntr_nxt;
    end
  end
end

assign recnstrct_cntr_incr = (msg_sm_r == MSG_IDLE &&
                               msg_sm_nxt == MSG_RECONSTRUCT) ||
                             (msg_sm_r ==  MSG_RECONSTRUCT &&
                               msg_sm_nxt == MSG_RECONSTRUCT &&
                               rd_hndlr_msg_valid_i);
assign recnstrct_cntr_en = recnstrct_cntr_incr || (msg_sm_nxt == MSG_IDLE);
assign recnstrct_cntr_nxt = (msg_sm_nxt == MSG_IDLE) ?
                              {LOG2_MAX_BEATS{1'b0}} :
                              recnstrct_cntr_r + 1'b1;


always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    read_buffer_r <= {REG_DATA_WIDTH{1'b0}};
    read_rsp_r    <= 2'b0;
    read_mst_id_r <= {FC_MST_ID_WIDTH{1'b0}};
    read_rid_r    <= {FC_AXIID_WIDTH{1'b0}};
  end
  else begin
    if (read_buffer_en) begin
      read_buffer_r <= read_buffer_nxt;
      read_rsp_r    <= read_rsp_nxt;
      read_mst_id_r <= read_mst_id_nxt;
      read_rid_r    <= read_rid_nxt;
    end
  end
end

assign read_mst_id_nxt = rd_hndlr_mst_id_i;

assign read_rid_nxt = rd_hndlr_rid_i;

assign read_rsp_nxt = rd_hndlr_acc_rd_rsp_i ? 2'b10 : 2'b00;

generate
  if (FW_LDE_LVL > 0) begin : LDE_1_2_NXT
    assign read_hndlr_tamp_nxt = rd_hndlr_acc_valid_i ?
      rd_hndlr_acc_rd_tamp_i : 1'b0;
  end
  else begin: LDE_0_NXT
    assign read_hndlr_tamp_nxt = 1'b0;
  end
endgenerate

assign read_buffer_en = rd_hndlr_acc_valid_i || rd_hndlr_msg_valid_i ||
                        rd_hndlr_shdw_valid_i;

assign rd_acc_shdw_valid = rd_hndlr_acc_valid_i || rd_hndlr_shdw_valid_i;

assign rd_hndlr_unfrmt_rd_data_o = rd_acc_shdw_valid ?
                                    (rd_hndlr_acc_valid_i ?
                                      rd_hndlr_acc_rd_data_i :
                                      rd_hndlr_shdw_rd_data_i) :
                                    recnstrct_nxt;

always @* begin
  case ({rd_acc_shdw_valid, rd_hndlr_msg_valid_i, msg_rd_last})
    3'b000, 3'b100, 3'b011, 3'b101: begin
      read_buffer_nxt = rd_hndlr_acc_rd_rsp_i ? {REG_DATA_WIDTH{1'b0}} : rd_hndlr_frmt_rd_data_i;
    end
    3'b010: begin
      read_buffer_nxt = recnstrct_nxt;
    end
    default: begin
      read_buffer_nxt = {REG_DATA_WIDTH{1'bx}};
    end
  endcase
end

assign full_rd_data = rd_hndlr_acc_valid_i || rd_hndlr_shdw_valid_i ||
                      (rd_hndlr_msg_valid_i && msg_rd_last);


always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    full_rd_data_r <= 1'b0;
  end
  else begin
    full_rd_data_r <= full_rd_data;
  end
end

generate
  if (READ_REG_SLICE == 1) begin : SLICE_ENABLED
    assign rd_hndlr_data_o   = read_buffer_r;
    assign rd_hndlr_valid_o  = full_rd_data_r;
    assign rd_hndlr_rsp_o    = read_rsp_r;
    assign rd_hndlr_mst_id_o = read_mst_id_r;
    assign rd_hndlr_rid_o    = read_rid_r;
  end
  else begin: SLICE_BYPASSED
    assign rd_hndlr_data_o   = full_rd_data ? read_buffer_nxt : read_buffer_r;
    assign rd_hndlr_valid_o  = full_rd_data;
    assign rd_hndlr_rsp_o    = full_rd_data ? read_rsp_nxt : read_rsp_r;
    assign rd_hndlr_mst_id_o = full_rd_data ? read_mst_id_nxt : read_mst_id_r;
    assign rd_hndlr_rid_o    = full_rd_data ? read_rid_nxt : read_rid_r;
  end
endgenerate

assign rd_hndlr_tamp_o = read_hndlr_tamp_nxt;

assign rd_hndlr_clk_busy_o = read_buffer_en || (msg_sm_r != MSG_IDLE) ||
                             full_rd_data_r;


endmodule
