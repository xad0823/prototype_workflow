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

module firewall_f0_ctlr_wr_hndlr #(
    parameter FW_LDE_LVL      = 1,
    parameter FC_MST_ID_WIDTH = 8,
    parameter FC_AXIID_WIDTH  = 2,
    parameter FW_SRE_LVL      = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       wr_hndlr_ctlr_valid_i,

    input  wire                       wr_hndlr_msg_rsp_i,
    input  wire                       wr_hndlr_msg_tamp_i,
    input  wire                       wr_hndlr_msg_valid_i,

    input  wire                       wr_hndlr_acc_rsp_i,
    input  wire                       wr_hndlr_acc_tamp_i,
    input  wire                       wr_hndlr_acc_valid_i,

    input  wire                       wr_hndlr_shdw_rsp_i,
    input  wire                       wr_hndlr_shdw_tamp_i,
    input  wire                       wr_hndlr_shdw_valid_i,

    output wire [1:0]                 wr_hndlr_rsp_o,
    output wire                       wr_hndlr_tamp_o,
    output wire                       wr_hndlr_valid_o,
    input  wire [FC_AXIID_WIDTH-1:0]  wr_hndlr_bid_i,
    output wire [FC_AXIID_WIDTH-1:0]  wr_hndlr_bid_o,

    output wire                       wr_hndlr_clk_busy_o
);


localparam WRITE_REG_SLICE = 1;


wire                       wr_hndlr_rsp_nxt;
wire                       wr_hndlr_tamp_nxt;
wire                       wr_hndlr_tamp_int;
wire                       wr_hndlr_valid_nxt;
reg                        wr_hndlr_valid_r;
wire [FC_AXIID_WIDTH-1:0]  wr_hndlr_bid_nxt;
reg  [FC_AXIID_WIDTH-1:0]  wr_hndlr_bid_r;

wire [1:0] wr_hndlr_rsp_enc_nxt;
reg  [1:0] wr_hndlr_rsp_r;


assign wr_hndlr_valid_nxt = wr_hndlr_ctlr_valid_i || wr_hndlr_msg_valid_i ||
                            wr_hndlr_shdw_valid_i || wr_hndlr_acc_valid_i;

assign wr_hndlr_rsp_nxt = wr_hndlr_ctlr_valid_i ? 1'b0 :
                            wr_hndlr_msg_valid_i ? wr_hndlr_msg_rsp_i :
                              wr_hndlr_shdw_valid_i ? wr_hndlr_shdw_rsp_i :
                                wr_hndlr_acc_valid_i ? wr_hndlr_acc_rsp_i :
                                1'b0;

assign wr_hndlr_bid_nxt = wr_hndlr_bid_i;

assign wr_hndlr_rsp_enc_nxt = wr_hndlr_rsp_nxt ? 2'b10 : 2'b00;

generate
  if (FW_LDE_LVL > 0) begin : LDE_1_2_NXT
    assign wr_hndlr_tamp_nxt = wr_hndlr_ctlr_valid_i ? 1'b0 :
                                 wr_hndlr_msg_valid_i ? wr_hndlr_msg_tamp_i :
                                   wr_hndlr_shdw_valid_i ? wr_hndlr_shdw_tamp_i :
                                      wr_hndlr_acc_valid_i ? wr_hndlr_acc_tamp_i : 1'b0;
  end
  else begin: LDE_0_NXT
    assign wr_hndlr_tamp_nxt = 1'b0;
  end
endgenerate


always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    wr_hndlr_rsp_r <= 2'b0;
    wr_hndlr_bid_r <= {FC_AXIID_WIDTH{1'b0}};
  end
  else begin
    if (wr_hndlr_valid_nxt) begin
      wr_hndlr_rsp_r <= wr_hndlr_rsp_enc_nxt;
      wr_hndlr_bid_r <= wr_hndlr_bid_nxt;
    end
  end
end

assign wr_hndlr_tamp_int = wr_hndlr_tamp_nxt;


generate
  if (WRITE_REG_SLICE == 1) begin : SLICE_ENABLED
    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        wr_hndlr_valid_r <= 1'b0;
      end
      else begin
        wr_hndlr_valid_r <= wr_hndlr_valid_nxt;
      end
    end
    assign wr_hndlr_valid_o  = wr_hndlr_valid_r;
    assign wr_hndlr_rsp_o    = wr_hndlr_rsp_r;
    assign wr_hndlr_tamp_o   = wr_hndlr_tamp_int;
    assign wr_hndlr_bid_o    = wr_hndlr_bid_r;
  end
  else begin: SLICE_BYPASSED
    assign wr_hndlr_valid_o  = wr_hndlr_valid_nxt;
    assign wr_hndlr_rsp_o    = wr_hndlr_valid_nxt ? wr_hndlr_rsp_enc_nxt : wr_hndlr_rsp_r;
    assign wr_hndlr_tamp_o   = wr_hndlr_valid_nxt ? wr_hndlr_tamp_nxt : wr_hndlr_tamp_int;
    assign wr_hndlr_bid_o    = wr_hndlr_valid_nxt ? wr_hndlr_bid_nxt : wr_hndlr_bid_r;
  end
endgenerate

assign wr_hndlr_clk_busy_o = wr_hndlr_ctlr_valid_i || wr_hndlr_msg_valid_i ||
                             wr_hndlr_shdw_valid_i || wr_hndlr_acc_valid_i ||
                             wr_hndlr_valid_r;

endmodule
