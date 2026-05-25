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

module firewall_f0_ctlr_msg_dec #(
    parameter FC_CFG_DATA_W  = 32,
    parameter LOG2_FW_NUM_FC = 6,
    parameter IRQ_TYPE_WIDTH = 5,
    parameter REG_DATA_WIDTH = 32,
    parameter FW_LDE_LVL     = 1
) (
    input  wire                      clk,
    input  wire                      reset_n,

    input  wire [FC_CFG_DATA_W-1:0]  msg_dec_a4s_data_i,
    input  wire                      msg_dec_a4s_last_i,
    input  wire                      msg_dec_a4s_valid_i,
    input  wire [LOG2_FW_NUM_FC-1:0] msg_dec_a4s_tid_i,

    output wire [1:0]                msg_dec_pwr_con_req_o,
    output wire                      msg_dec_pwr_discon_req_o,
    output wire                      msg_dec_pwr_valid_o,
    output wire [LOG2_FW_NUM_FC-1:0] msg_dec_pwr_fw_id_o,

    output wire                      msg_dec_irq_req_o,
    output wire [IRQ_TYPE_WIDTH-1:0] msg_dec_irq_type_o,
    output wire [LOG2_FW_NUM_FC-1:0] msg_dec_irq_fw_id_o,

    output wire [FC_CFG_DATA_W-1:0]  msg_dec_rd_data_o,
    output wire                      msg_dec_rd_last_o,
    output wire                      msg_dec_rd_valid_o,

    output wire                      msg_dec_wr_rsp_o,
    output wire                      msg_dec_wr_tamp_o,
    output wire                      msg_dec_wr_valid_o,

    output wire                      msg_dec_lpi_clk_busy_o
);


`include "firewall_f0_msg_prot_types.vh"


localparam RD_SM_SIZE = 1;
localparam RD_IDLE    = 1'b0;
localparam RD_READ    = 1'b1;


reg  rd_sm_r;
reg  rd_sm_nxt;

wire read_active;
wire read_msg;

wire a4s_last_val;


assign msg_dec_pwr_valid_o = msg_dec_a4s_valid_i ?
                             (!read_active &&
                             (msg_dec_a4s_data_i[1:0] == HNDSHK_RSP_T)) :
                             1'b0;

assign msg_dec_irq_req_o = msg_dec_a4s_valid_i ?
                           (!read_active &&
                           (msg_dec_a4s_data_i[1:0] == IRQ_REQ_T)) :
                           1'b0;

assign msg_dec_wr_valid_o = msg_dec_a4s_valid_i ?
                            (!read_active &&
                            (msg_dec_a4s_data_i[2:0] == {CFG_WRITE_RSP_T, CFG_RSP_T})) :
                            1'b0;

assign msg_dec_rd_valid_o = msg_dec_a4s_valid_i ?
                            ((!read_active &&
                            (msg_dec_a4s_data_i[2:0] == {CFG_READ_RSP_T, CFG_RSP_T})) ||
                            read_active) :
                            1'b0;


assign a4s_last_val = msg_dec_a4s_valid_i ? msg_dec_a4s_last_i : 1'b0;

assign read_msg = msg_dec_a4s_valid_i ?
                  (!read_active &&
                  (msg_dec_a4s_data_i[2:0] == {CFG_READ_RSP_T, CFG_RSP_T})) :
                  1'b0;

always @ (posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    rd_sm_r <= RD_IDLE;
  end
  else begin
    rd_sm_r <= rd_sm_nxt;
  end
end

always @* begin
  case (rd_sm_r)
    RD_IDLE: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val, read_msg})
        3'b000, 3'b001, 3'b100, 3'b110, 3'b111: begin
          rd_sm_nxt = RD_IDLE;
        end
        3'b101: begin
          rd_sm_nxt = RD_READ;
        end
        default: begin
          rd_sm_nxt = 1'bx;
        end
      endcase
    end
    RD_READ: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val})
        2'b00, 2'b10: begin
          rd_sm_nxt = RD_READ;
        end
        2'b11: begin
          rd_sm_nxt = RD_IDLE;
        end
        default: begin
          rd_sm_nxt = 1'bx;
        end
      endcase
    end
    default: begin
      rd_sm_nxt = 1'bx;
    end
  endcase
end

assign read_active = rd_sm_r == RD_READ;

assign msg_dec_rd_data_o = msg_dec_a4s_data_i;
assign msg_dec_rd_last_o = a4s_last_val;


assign msg_dec_pwr_con_req_o = msg_dec_a4s_valid_i ?
                              {msg_dec_a4s_data_i[3], (CNCT_REQ_T == msg_dec_a4s_data_i[2])} :
                              2'b0;
assign msg_dec_pwr_discon_req_o = msg_dec_a4s_valid_i ?
                                  (DISCNCT_REQ_T == msg_dec_a4s_data_i[2]) :
                                  1'b0;
assign msg_dec_pwr_fw_id_o = msg_dec_a4s_tid_i;


assign msg_dec_irq_type_o = msg_dec_a4s_data_i[6:2];
assign msg_dec_irq_fw_id_o = msg_dec_a4s_tid_i;


assign msg_dec_wr_rsp_o = msg_dec_a4s_data_i[3];
assign msg_dec_wr_tamp_o = msg_dec_a4s_data_i[4];


assign msg_dec_lpi_clk_busy_o = (rd_sm_r != RD_IDLE) || msg_dec_a4s_valid_i;

endmodule
