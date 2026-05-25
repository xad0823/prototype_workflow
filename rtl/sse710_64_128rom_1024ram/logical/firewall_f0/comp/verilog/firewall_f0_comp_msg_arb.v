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

module firewall_f0_comp_msg_arb #(
    parameter REG_DATA_WIDTH      = 32,
    parameter READ_DATA_SIZE      = 7,
    parameter IRQ_TYPE_WIDTH      = 5,
    parameter MSG_TYPE_WIDTH      = 3,
    parameter MSG_NOFRMT_SIZE     = 32,
    parameter MSG_TYPE_READ       = 3'b000,
    parameter MSG_TYPE_WRITE      = 3'b001,
    parameter MSG_TYPE_CONNECT    = 3'b010,
    parameter MSG_TYPE_DISCONNECT = 3'b011,
    parameter MSG_TYPE_IRQ        = 3'b100,
    parameter FC_ME_LVL           = 1,
    parameter FC_PE_LVL           = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       msg_arb_wr_rsp_i,
    input  wire                       msg_arb_wr_tamp_i,
    input  wire [REG_DATA_WIDTH-1:0]  msg_arb_rd_data_i,
    input  wire                       msg_arb_rw_i,
    input  wire [READ_DATA_SIZE-1:0]  msg_arb_rd_size_i,
    input  wire                       msg_arb_msg_valid_i,

    input  wire [IRQ_TYPE_WIDTH-1:0]  msg_arb_irq_req_i,
    input  wire                       msg_arb_irq_valid_i,

    input  wire [1:0]                 msg_arb_pwr_con_req_i,
    input  wire                       msg_arb_pwr_dis_con_req_i,
    output wire                       msg_arb_lpi_busy_o,

    output wire [MSG_TYPE_WIDTH-1:0]  msg_arb_msg_type_o,
    output wire [MSG_NOFRMT_SIZE-1:0] msg_arb_msg_data_o,
    output wire [READ_DATA_SIZE-1:0]  msg_arb_rd_size_o,
    output wire                       msg_arb_msg_valid_o,

    output wire                       msg_arb_rw_valid_o,

    input wire                        msg_arb_ready_i

);


`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"


localparam ARB_SM_SIZE = 2;
localparam ARB_IDLE    = 2'b00;
localparam ARB_GNT_IRQ = 2'b01;
localparam ARB_GNT_REG = 2'b10;
localparam ARB_GNT_POW = 2'b11;

localparam INT_MSG_TYPE_WIDTH = 2;
localparam INT_MSG_IRQ        = 2'b00;
localparam INT_MSG_REG        = 2'b01;
localparam INT_MSG_POW        = 2'b10;

localparam IRQ_REQ_SM_SIZE = 1;
localparam IRQ_IDLE        = 1'b0;
localparam IRQ_REQD        = 1'b1;
localparam REG_REQ_SM_SIZE = 1;
localparam REG_IDLE        = 1'b0;
localparam REG_REQD        = 1'b1;
localparam POW_REQ_SM_SIZE = 1;
localparam POW_IDLE        = 1'b0;
localparam POW_REQD        = 1'b1;


reg [ARB_SM_SIZE-1:0] arb_sm_r;
reg [ARB_SM_SIZE-1:0] arb_sm_nxt;

reg [IRQ_REQ_SM_SIZE-1:0] irq_sm_r;
reg [IRQ_REQ_SM_SIZE-1:0] irq_sm_nxt;
reg [REG_REQ_SM_SIZE-1:0] reg_sm_r;
reg [REG_REQ_SM_SIZE-1:0] reg_sm_nxt;
reg [POW_REQ_SM_SIZE-1:0] pow_sm_r;
reg [POW_REQ_SM_SIZE-1:0] pow_sm_nxt;

wire reg_req;
wire irq_req;
wire pow_req;

reg reg_grntd;
reg irq_grntd;
reg pow_grntd;

reg [INT_MSG_TYPE_WIDTH-1:0] msg_int_type_nxt;

reg                       msg_arb_msg_valid_nxt;
reg                       msg_arb_rw_valid_nxt;
reg [MSG_TYPE_WIDTH-1:0]  msg_arb_msg_type_nxt;
reg [MSG_NOFRMT_SIZE-1:0] msg_arb_msg_data_nxt;

wire [IRQ_TYPE_WIDTH-1:0] irq_type;

wire pow_type;
reg  pow_type_r;
wire pow_type_nxt;
wire pow_valid;

wire connect_reset;
reg  connect_reset_r;
reg  connect_reset_nxt;
wire connect_reset_en;

wire irq_q_not_empty;
wire irq_q_empty;
wire irq_sent;

wire [2:0]                fe_irq;
wire [1:0]                edr_irq;
wire [IRQ_TYPE_WIDTH-1:0] full_irq;


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    arb_sm_r <= ARB_IDLE;
  end
  else begin
    arb_sm_r <= arb_sm_nxt;
  end
end

always @* begin
  case (arb_sm_r)
    ARB_IDLE: begin
      case ({reg_req, irq_req, pow_req, msg_arb_ready_i})
        4'b0000, 4'b0001, 4'b0010, 4'b0100, 4'b1000, 4'b1100, 4'b1010: begin
          arb_sm_nxt                        = ARB_IDLE;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b0101, 4'b1101: begin
          arb_sm_nxt                        = ARB_GNT_IRQ;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b1001, 4'b1011: begin
          arb_sm_nxt                        = ARB_GNT_REG;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_REG;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b0011: begin
          arb_sm_nxt                        = ARB_GNT_POW;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_POW;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        default: begin
          arb_sm_nxt                        = {ARB_SM_SIZE{1'bx}};
          msg_arb_msg_valid_nxt             = 1'bx;
          msg_arb_rw_valid_nxt              = 1'bx;
          msg_int_type_nxt                  = {INT_MSG_TYPE_WIDTH{1'bx}};
          {pow_grntd, reg_grntd, irq_grntd} = 3'bxxx;
        end
      endcase
    end
    ARB_GNT_IRQ: begin
      case ({reg_req, irq_req, pow_req, msg_arb_ready_i})
        4'b0100, 4'b1100: begin
          arb_sm_nxt                        = ARB_GNT_IRQ;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b0101: begin
          arb_sm_nxt                        = ARB_IDLE;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b001;
        end
        4'b1101: begin
          arb_sm_nxt                        = ARB_GNT_REG;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_REG;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b001;
        end
        default: begin
          arb_sm_nxt                        = {ARB_SM_SIZE{1'bx}};
          msg_arb_msg_valid_nxt             = 1'bx;
          msg_arb_rw_valid_nxt              = 1'bx;
          msg_int_type_nxt                  = {INT_MSG_TYPE_WIDTH{1'bx}};
          {pow_grntd, reg_grntd, irq_grntd} = 3'bxxx;
        end
      endcase
    end
    ARB_GNT_REG: begin
      case ({reg_req, irq_req, pow_req, msg_arb_ready_i})
        4'b1000, 4'b1100, 4'b1010: begin
          arb_sm_nxt                        = ARB_GNT_REG;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b1;
          msg_int_type_nxt                  = INT_MSG_REG;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b1001: begin
          arb_sm_nxt                        = ARB_IDLE;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b1;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b010;
        end
        4'b1101: begin
          arb_sm_nxt                        = ARB_GNT_IRQ;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b1;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b010;
        end
        4'b1011: begin
          arb_sm_nxt                        = ARB_GNT_POW;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b1;
          msg_int_type_nxt                  = INT_MSG_POW;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b010;
        end
        default: begin
          arb_sm_nxt                        = {ARB_SM_SIZE{1'bx}};
          msg_arb_msg_valid_nxt             = 1'bx;
          msg_arb_rw_valid_nxt              = 1'bx;
          msg_int_type_nxt                  = {INT_MSG_TYPE_WIDTH{1'bx}};
          {pow_grntd, reg_grntd, irq_grntd} = 3'bxxx;
        end
      endcase
    end
    ARB_GNT_POW: begin
      case ({reg_req, irq_req, pow_req, msg_arb_ready_i})
        4'b0010, 4'b1010: begin
          arb_sm_nxt                        = ARB_GNT_POW;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_POW;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b000;
        end
        4'b0011: begin
          arb_sm_nxt                        = ARB_IDLE;
          msg_arb_msg_valid_nxt             = 1'b0;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_IRQ;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b100;
        end
        4'b1011: begin
          arb_sm_nxt                        = ARB_GNT_REG;
          msg_arb_msg_valid_nxt             = 1'b1;
          msg_arb_rw_valid_nxt              = 1'b0;
          msg_int_type_nxt                  = INT_MSG_REG;
          {pow_grntd, reg_grntd, irq_grntd} = 3'b100;
        end
        default: begin
          arb_sm_nxt                        = {ARB_SM_SIZE{1'bx}};
          msg_arb_msg_valid_nxt             = 1'bx;
          msg_arb_rw_valid_nxt              = 1'bx;
          msg_int_type_nxt                  = {INT_MSG_TYPE_WIDTH{1'bx}};
          {pow_grntd, reg_grntd, irq_grntd} = 3'bxxx;
        end
      endcase
    end
    default: begin
      arb_sm_nxt                        = {ARB_SM_SIZE{1'bx}};
      msg_arb_msg_valid_nxt             = 1'bx;
      msg_arb_rw_valid_nxt              = 1'bx;
      msg_int_type_nxt                  = {INT_MSG_TYPE_WIDTH{1'bx}};
      {pow_grntd, reg_grntd, irq_grntd} = 3'bxxx;
    end
  endcase
end

assign msg_arb_msg_valid_o = msg_arb_msg_valid_nxt;
assign msg_arb_rw_valid_o  = msg_arb_rw_valid_nxt;

always @* begin
  case (msg_int_type_nxt)
    INT_MSG_IRQ: begin
      msg_arb_msg_type_nxt = MSG_TYPE_IRQ;
      msg_arb_msg_data_nxt = {{(MSG_NOFRMT_SIZE-IRQ_TYPE_WIDTH){1'b0}}, irq_type};
    end
    INT_MSG_REG: begin
      case (msg_arb_rw_i)
        1'b0: begin
          msg_arb_msg_type_nxt = MSG_TYPE_READ;
          msg_arb_msg_data_nxt = msg_arb_rd_data_i;
        end
        1'b1: begin
          msg_arb_msg_type_nxt = MSG_TYPE_WRITE;
          msg_arb_msg_data_nxt = {{(MSG_NOFRMT_SIZE-2){1'b0}}, msg_arb_wr_tamp_i, msg_arb_wr_rsp_i};
        end
        default: begin
          msg_arb_msg_type_nxt = {MSG_TYPE_WIDTH{1'bx}};
          msg_arb_msg_data_nxt = {MSG_NOFRMT_SIZE{1'bx}};
        end
      endcase
    end
    INT_MSG_POW: begin
      case (pow_type)
        1'b0: begin
          msg_arb_msg_type_nxt = MSG_TYPE_DISCONNECT;
          msg_arb_msg_data_nxt = {MSG_NOFRMT_SIZE{1'b0}};
        end
        1'b1: begin
          msg_arb_msg_type_nxt = MSG_TYPE_CONNECT;
          msg_arb_msg_data_nxt = {{(MSG_NOFRMT_SIZE-1){1'b0}}, connect_reset};
        end
        default: begin
          msg_arb_msg_type_nxt = {MSG_TYPE_WIDTH{1'bx}};
          msg_arb_msg_data_nxt = {MSG_NOFRMT_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      msg_arb_msg_type_nxt = {MSG_TYPE_WIDTH{1'bx}};
      msg_arb_msg_data_nxt = {MSG_NOFRMT_SIZE{1'bx}};
    end
  endcase
end

assign msg_arb_rd_size_o  = msg_arb_rd_size_i;
assign msg_arb_msg_data_o = msg_arb_msg_data_nxt;
assign msg_arb_msg_type_o = msg_arb_msg_type_nxt;


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    irq_sm_r <= IRQ_IDLE;
  end
  else begin
    irq_sm_r <= irq_sm_nxt;
  end
end

always @* begin
  case (irq_sm_r)
    IRQ_IDLE: begin
      case ({msg_arb_irq_valid_i, irq_q_not_empty})
        2'b00: begin
          irq_sm_nxt = IRQ_IDLE;
        end
        2'b01, 2'b10, 2'b11: begin
          irq_sm_nxt = IRQ_REQD;
        end
        default: begin
          irq_sm_nxt = {IRQ_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    IRQ_REQD: begin
      case (irq_grntd)
        1'b0: begin
          irq_sm_nxt = IRQ_REQD;
        end
        1'b1: begin
          irq_sm_nxt = IRQ_IDLE;
        end
        default: begin
          irq_sm_nxt = {IRQ_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      irq_sm_nxt = {IRQ_REQ_SM_SIZE{1'bx}};
    end
  endcase
end

assign irq_req = (irq_sm_r == IRQ_REQD) || ((irq_sm_r == IRQ_IDLE) &&
                 (msg_arb_irq_valid_i && !irq_q_not_empty));

assign irq_sent = msg_arb_msg_valid_nxt && msg_arb_msg_type_nxt == MSG_TYPE_IRQ;

generate
  if (FC_PE_LVL > 0) begin : FE_SPT
    reg [2:0] fe_irq_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        fe_irq_r <= 3'b000;
      end
      else begin
        if (!msg_arb_irq_valid_i && irq_sent) begin
          fe_irq_r <= 3'b000;
        end
        else if (msg_arb_irq_valid_i && !irq_sent) begin
          fe_irq_r <= fe_irq_r | msg_arb_irq_req_i[2:0];
        end
        else if (msg_arb_irq_valid_i && irq_sent && !((irq_sm_r == IRQ_IDLE) && irq_q_empty)) begin
          fe_irq_r <= msg_arb_irq_req_i[2:0];
        end


      end
    end

    assign fe_irq = fe_irq_r;

  end
  else begin: FE_NO_SPT
    assign fe_irq = 3'b000;
  end

  if (FC_ME_LVL > 0) begin : EDR_SPT
    reg [1:0] edr_irq_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        edr_irq_r <= 2'b00;
      end
      else begin
        if (!msg_arb_irq_valid_i && irq_sent) begin
          edr_irq_r <= 2'b00;
        end
        else if (msg_arb_irq_valid_i && !irq_sent) begin
          edr_irq_r <= edr_irq_r | msg_arb_irq_req_i[4:3];
        end
        else if (msg_arb_irq_valid_i && irq_sent && !((irq_sm_r == IRQ_IDLE) && irq_q_empty)) begin
          edr_irq_r <= msg_arb_irq_req_i[4:3];
        end

      end
    end

    assign edr_irq = edr_irq_r;

  end
  else begin: EDR_NO_SPT
    assign edr_irq = 2'b00;
  end
endgenerate

assign full_irq = {edr_irq, fe_irq};

assign irq_q_empty = full_irq == {IRQ_TYPE_WIDTH{1'b0}};
assign irq_q_not_empty = !irq_q_empty;

assign irq_type = (msg_arb_irq_valid_i && (irq_sm_r == IRQ_IDLE) && irq_q_empty) ?
                  msg_arb_irq_req_i : full_irq;


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    reg_sm_r <= REG_IDLE;
  end
  else begin
    reg_sm_r <= reg_sm_nxt;
  end
end

always @* begin
  case (reg_sm_r)
    REG_IDLE: begin
      case (msg_arb_msg_valid_i)
        1'b0: begin
          reg_sm_nxt = REG_IDLE;
        end
        1'b1: begin
          reg_sm_nxt = REG_REQD;
        end
        default: begin
          reg_sm_nxt = {REG_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    REG_REQD: begin
      case ({reg_grntd, msg_arb_msg_valid_i})
        2'b00, 2'b11: begin
          reg_sm_nxt = REG_REQD;
        end
        2'b10: begin
          reg_sm_nxt = REG_IDLE;
        end
        default: begin
          reg_sm_nxt = {REG_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      reg_sm_nxt = {REG_REQ_SM_SIZE{1'bx}};
    end
  endcase
end

assign reg_req = (reg_sm_r == REG_REQD) ||
                 ((reg_sm_r == REG_IDLE) && msg_arb_msg_valid_i);


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    pow_sm_r <= POW_IDLE;
  end
  else begin
    pow_sm_r <= pow_sm_nxt;
  end
end

always @* begin
  case (pow_sm_r)
    POW_IDLE: begin
      case (pow_valid)
        1'b0: begin
          pow_sm_nxt = POW_IDLE;
        end
        1'b1: begin
          pow_sm_nxt = POW_REQD;
        end
        default: begin
          pow_sm_nxt = {POW_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    POW_REQD: begin
      case (pow_grntd)
        1'b0: begin
          pow_sm_nxt = POW_REQD;
        end
        1'b1: begin
          pow_sm_nxt = POW_IDLE;
        end
        default: begin
          pow_sm_nxt = {POW_REQ_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      pow_sm_nxt = {POW_REQ_SM_SIZE{1'bx}};
    end
  endcase
end

assign pow_req = (pow_sm_r == POW_REQD) || ((pow_sm_r == POW_IDLE) && pow_valid);

assign pow_valid = msg_arb_pwr_dis_con_req_i ||
                  (msg_arb_pwr_con_req_i == 2'b01 || msg_arb_pwr_con_req_i == 2'b11);

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    pow_type_r      <= 1'b0;
    connect_reset_r <= 1'b0;
  end
  else begin
    if (pow_valid) begin
      pow_type_r      <= pow_type_nxt;
      connect_reset_r <= msg_arb_pwr_con_req_i[1];
    end
  end
end

assign pow_type_nxt = msg_arb_pwr_dis_con_req_i ? 1'b0 : 1'b1;
assign pow_type = pow_valid ? pow_type_nxt : pow_type_r;
assign connect_reset = pow_valid ? msg_arb_pwr_con_req_i[1] : connect_reset_r;


assign msg_arb_lpi_busy_o = (arb_sm_r != ARB_IDLE) || (reg_sm_r != REG_IDLE) ||
                            (irq_sm_r != IRQ_IDLE) || (pow_sm_r != POW_IDLE) ||
                            msg_arb_msg_valid_i || msg_arb_irq_valid_i ||
                            irq_q_not_empty;

endmodule
