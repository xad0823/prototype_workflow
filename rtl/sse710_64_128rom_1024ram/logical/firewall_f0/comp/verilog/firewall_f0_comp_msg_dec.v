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

module firewall_f0_comp_msg_dec #(
    parameter FC_CFG_DATA_W  = 32,
    parameter REG_ADDR_WIDTH = 10,
    parameter REG_DATA_WIDTH = 32,
    parameter FW_SRE_LVL     = 1,
    parameter FC_PE_LVL      = 1
) (
    input  wire                      clk,
    input  wire                      reset_n,

    input  wire [FC_CFG_DATA_W-1:0]  msg_dec_a4s_data_i,
    input  wire                      msg_dec_a4s_last_i,
    input  wire                      msg_dec_a4s_valid_i,
    output wire                      msg_dec_a4s_ready_o,
    output wire                      msg_dec_a4s_discon_o,

    output wire                      msg_dec_pwr_accept_o,
    output wire                      msg_dec_lpi_busy_o,

    output wire                      msg_dec_reg_restore_o,
    output wire [FC_CFG_DATA_W-1:0]  msg_dec_reg_restore_data_o,
    output wire                      msg_dec_reg_con_accept_o,
    output wire                      msg_dec_reg_rw_o,
    output wire [REG_ADDR_WIDTH-1:0] msg_dec_reg_addr_o,
    output wire [REG_DATA_WIDTH-1:0] msg_dec_wr_data_o,
    output wire                      msg_dec_reg_valid_o,

    input  wire                      msg_dec_rw_nxt_i,

    input  wire                      msg_dec_last_sent_i
);


`include "firewall_f0_msg_prot_types.vh"
`include "firewall_f0_ceil_divide.vh"
`include "firewall_f0_log2.vh"


localparam MAX_RW_MSG_SIZE = 43;

localparam BUF_SM_SIZE     = 2;
localparam BUF_IDLE        = 2'b00;
localparam BUF_RECONSTRUCT = 2'b01;
localparam BUF_HOLD        = 2'b10;

localparam RTR_SM_SIZE = 1;
localparam RTR_IDLE    = 1'b0;
localparam RTR_RESTORE = 1'b1;

localparam MAX_RW_MSG_BEATS = firewall_f0_ceil_divide(MAX_RW_MSG_SIZE, FC_CFG_DATA_W);
localparam LOG2_MAX_RW_MSG_BEATS = firewall_f0_log2(MAX_RW_MSG_BEATS);


reg [MAX_RW_MSG_SIZE-1:0]  msg_buffer_r;
reg [MAX_RW_MSG_SIZE-1:0]  msg_buffer_nxt;
wire                       msg_buffer_en;
wire [MAX_RW_MSG_SIZE-1:0] msg_buffer_src;

reg [BUF_SM_SIZE-1:0] buff_sm_r;
reg [BUF_SM_SIZE-1:0] buff_sm_nxt;

wire reconstructable;

wire holdable;
wire holdable_idle;
wire holdable_idle_n;

wire reg_bank_acc;

wire rw_msg_sent;

wire a4s_valid_no_restore;
wire a4s_last_no_restore;

wire restore_active;

reg buffer_active;

reg msg_dec_reg_valid_nxt;
wire msg_dec_a4s_ready_nxt;

reg  [LOG2_MAX_RW_MSG_BEATS-1:0] reconstruct_counter_r;
wire [LOG2_MAX_RW_MSG_BEATS-1:0] reconstruct_counter_nxt;
wire                             reconstruct_counter_en;
wire                             reconstruct_counter_incr;

wire write_read_req;

integer i;

reg [RTR_SM_SIZE-1:0] rstr_sm_r;
reg [RTR_SM_SIZE-1:0] rstr_sm_nxt;

wire restore_msg;

wire msg_dec_reg_restore_nxt;

wire msg_dec_pwr_accept_nxt;

wire last_con_msg;

wire a4s_last_val;


generate
  if (FC_CFG_DATA_W < 16) begin : READ_BUFF
    assign reconstructable = (msg_dec_a4s_valid_i && !restore_active) ?
                             ((msg_dec_a4s_data_i[2:0] == WRITE_REQ_MSG_HDR) ||
                             (msg_dec_a4s_data_i[2:0] == READ_REQ_MSG_HDR)) :
                             1'b0;
  end
  else if (FC_CFG_DATA_W < 48) begin: NO_READ_BUFF
    assign reconstructable = (msg_dec_a4s_valid_i && !restore_active) ?
                             (msg_dec_a4s_data_i[2:0] == WRITE_REQ_MSG_HDR) :
                             1'b0;
  end
  else begin: NO_BUFF
    assign reconstructable = 1'b0;
  end
endgenerate


assign holdable_idle = (msg_dec_a4s_valid_i && !restore_active) ?
                       ((msg_dec_a4s_data_i[2:0] == WRITE_REQ_MSG_HDR) ||
                       (msg_dec_a4s_data_i[2:0] == READ_REQ_MSG_HDR)) :
                       1'b0;
assign holdable_idle_n = (msg_buffer_r[0] == (WRITE_REQ_MSG_HDR >> 2)) ||
                         (msg_buffer_r[0] == (READ_REQ_MSG_HDR >> 2));

assign holdable = (buff_sm_r == BUF_IDLE) ? holdable_idle : holdable_idle_n;

assign rw_msg_sent = msg_dec_rw_nxt_i && msg_dec_last_sent_i;

assign a4s_valid_no_restore = msg_dec_a4s_valid_i && !restore_active;
assign a4s_last_no_restore = msg_dec_a4s_valid_i ? msg_dec_a4s_last_i &&
                             !restore_active : 1'b0;

assign reg_bank_acc = (msg_dec_a4s_valid_i && !restore_active) ?
                      ((msg_dec_a4s_data_i[2:0] == WRITE_REQ_MSG_HDR) ||
                      (msg_dec_a4s_data_i[2:0] == READ_REQ_MSG_HDR)) :
                      1'b0;

assign a4s_last_val = msg_dec_a4s_valid_i ? msg_dec_a4s_last_i : 1'b0;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    buff_sm_r <= BUF_IDLE;
  end
  else begin
    buff_sm_r <= buff_sm_nxt;
  end
end

always @* begin
  case (buff_sm_r)
    BUF_IDLE: begin
      case ({a4s_valid_no_restore, a4s_last_no_restore, reconstructable, holdable, reg_bank_acc})
        5'b00000, 5'b00001, 5'b00011, 5'b00101, 5'b00111,
        5'b10000, 5'b11000: begin
          buff_sm_nxt   = BUF_IDLE;
          buffer_active = 1'b0;
        end
        5'b10101, 5'b10111: begin
          buff_sm_nxt   = BUF_RECONSTRUCT;
          buffer_active = 1'b0;
        end
        5'b11011, 5'b11111: begin
          buff_sm_nxt   = BUF_HOLD;
          buffer_active = 1'b0;
        end
        default: begin
          buff_sm_nxt   = {BUF_SM_SIZE{1'bx}};
          buffer_active = 1'bx;
        end
      endcase
    end
    BUF_RECONSTRUCT: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val, holdable})
        3'b000, 3'b001, 3'b100, 3'b101: begin
          buff_sm_nxt   = BUF_RECONSTRUCT;
          buffer_active = 1'b1;
        end
        3'b111: begin
          buff_sm_nxt   = BUF_HOLD;
          buffer_active = 1'b1;
        end
        default: begin
          buff_sm_nxt   = {BUF_SM_SIZE{1'bx}};
          buffer_active = 1'bx;
        end
      endcase
    end
    BUF_HOLD: begin
      case (rw_msg_sent)
        1'b0: begin
          buff_sm_nxt   = BUF_HOLD;
          buffer_active = 1'b1;
        end
        1'b1: begin
          buff_sm_nxt   = BUF_IDLE;
          buffer_active = 1'b1;
        end
        default: begin
          buff_sm_nxt   = {BUF_SM_SIZE{1'bx}};
          buffer_active = 1'bx;
        end
      endcase
    end
    default: begin
      buff_sm_nxt       = {BUF_SM_SIZE{1'bx}};
      buffer_active     = 1'bx;
    end
  endcase
end

assign msg_dec_a4s_ready_nxt = (buff_sm_r == BUF_IDLE) ||
                               (buff_sm_r == BUF_RECONSTRUCT);

always @* begin
  case (buff_sm_r)
    BUF_IDLE: begin
      case ({a4s_valid_no_restore, a4s_last_no_restore, reconstructable, holdable, reg_bank_acc})
        5'b00000, 5'b00001, 5'b00011, 5'b00101, 5'b00111,
        5'b10000, 5'b11000, 5'b10101, 5'b10111: begin
          msg_dec_reg_valid_nxt = 1'b0;
        end
        5'b11001, 5'b11101, 5'b11011, 5'b11111: begin
          msg_dec_reg_valid_nxt = 1'b1;
        end
        default: begin
          msg_dec_reg_valid_nxt = 1'bx;
        end
      endcase
    end
    BUF_RECONSTRUCT: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val, holdable})
        3'b000, 3'b001, 3'b100, 3'b101: begin
          msg_dec_reg_valid_nxt = 1'b0;
        end
        3'b111, 3'b110: begin
          msg_dec_reg_valid_nxt = 1'b1;
        end
        default: begin
          msg_dec_reg_valid_nxt = 1'bx;
        end
      endcase
    end
    BUF_HOLD: begin
      msg_dec_reg_valid_nxt = 1'b0;
    end
    default: begin
      msg_dec_reg_valid_nxt = 1'bx;
    end
  endcase
end

assign msg_dec_reg_valid_o = msg_dec_reg_valid_nxt;
assign msg_dec_a4s_ready_o = msg_dec_a4s_ready_nxt;


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    msg_buffer_r <= {MAX_RW_MSG_SIZE{1'b0}};
  end
  else begin
    if (msg_buffer_en) begin
      msg_buffer_r <= msg_buffer_nxt;
    end
  end
end

assign msg_buffer_en = (buff_sm_r == BUF_IDLE && buff_sm_nxt == BUF_RECONSTRUCT) ||
                       (buff_sm_r == BUF_IDLE && buff_sm_nxt == BUF_HOLD) ||
                       (buff_sm_r == BUF_RECONSTRUCT && msg_dec_a4s_valid_i &&
                         buff_sm_nxt != BUF_IDLE);

generate
  if (MAX_RW_MSG_BEATS > 1) begin : MULTIPLE_MSG_BEATS
    always @* begin
      msg_buffer_nxt = msg_buffer_r;
      if (reconstruct_counter_r == 0) begin
        msg_buffer_nxt[(FC_CFG_DATA_W-1)-2:0] = msg_dec_a4s_data_i[FC_CFG_DATA_W-1:2];
      end
      else if (reconstruct_counter_r == MAX_RW_MSG_BEATS-1) begin
        msg_buffer_nxt[MAX_RW_MSG_SIZE-1:(FC_CFG_DATA_W*(MAX_RW_MSG_BEATS-1))-2] =
          msg_dec_a4s_data_i[(MAX_RW_MSG_SIZE-(FC_CFG_DATA_W*(MAX_RW_MSG_BEATS-1))-1)+2:0];
      end
      else begin
        for (i=1; i<MAX_RW_MSG_BEATS-1; i=i+1) begin
          if (reconstruct_counter_r == i) begin
            msg_buffer_nxt[((FC_CFG_DATA_W*(i+1))-1)-2 -: FC_CFG_DATA_W] = msg_dec_a4s_data_i;
          end
        end
      end
    end
  end
  else begin: ONE_MSG_BEAT
    always @* begin
      msg_buffer_nxt = msg_buffer_r;
      msg_buffer_nxt[MAX_RW_MSG_SIZE-1:0] = msg_dec_a4s_data_i[FC_CFG_DATA_W-1:2];
    end
  end
endgenerate

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    reconstruct_counter_r <= {LOG2_MAX_RW_MSG_BEATS{1'b0}};
  end
  else begin
    if (reconstruct_counter_en) begin
      reconstruct_counter_r <= reconstruct_counter_nxt;
    end
  end
end

assign reconstruct_counter_incr = (buff_sm_r == BUF_IDLE &&
                                    buff_sm_nxt == BUF_RECONSTRUCT) ||
                                  (buff_sm_r == BUF_RECONSTRUCT &&
                                    buff_sm_nxt == BUF_RECONSTRUCT &&
                                    msg_dec_a4s_valid_i) ||
                                  (buff_sm_r == BUF_RECONSTRUCT &&
                                    buff_sm_nxt == BUF_HOLD);
assign reconstruct_counter_en = reconstruct_counter_incr || (buff_sm_nxt == BUF_IDLE);

assign reconstruct_counter_nxt = ((buff_sm_nxt == BUF_IDLE) ||
                                 (reconstruct_counter_r == (MAX_RW_MSG_BEATS-1))) ?
                                   {LOG2_MAX_RW_MSG_BEATS{1'b0}} :
                                   reconstruct_counter_r + 1'b1;


assign msg_buffer_src = msg_dec_reg_valid_nxt ? msg_buffer_nxt : msg_buffer_r;

assign write_read_req = msg_buffer_src[0] ? 1'b0 : 1'b1;

assign msg_dec_reg_rw_o   = write_read_req;
assign msg_dec_wr_data_o  = msg_buffer_src[1+REG_ADDR_WIDTH+REG_DATA_WIDTH-1:1+REG_ADDR_WIDTH];
assign msg_dec_reg_addr_o = msg_buffer_src[1+REG_ADDR_WIDTH-1:1];


assign restore_msg = (msg_dec_a4s_valid_i && (buff_sm_r == BUF_IDLE)) ?
                     (msg_dec_a4s_data_i[1:0] == RESTORE_FRAME_MSG_HDR) ||
                     (msg_dec_a4s_data_i[3:0] == CNCT_ACCEPT_RSP_MSG_HDR) :
                     1'b0;

always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    rstr_sm_r <= RTR_IDLE;
  end
  else begin
    rstr_sm_r <= rstr_sm_nxt;
  end
end

always @* begin
  case (rstr_sm_r)
    RTR_IDLE: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val, restore_msg, buffer_active})
        4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b1000, 4'b1001, 4'b1011, 4'b1100,
        4'b1101, 4'b1110, 4'b1111: begin
          rstr_sm_nxt    = RTR_IDLE;
        end
        4'b1010: begin
          rstr_sm_nxt    = RTR_RESTORE;
        end
        default: begin
          rstr_sm_nxt    = {RTR_SM_SIZE{1'bx}};
        end
      endcase
    end
    RTR_RESTORE: begin
      case ({msg_dec_a4s_valid_i, a4s_last_val})
        2'b00, 2'b10: begin
          rstr_sm_nxt    = RTR_RESTORE;
        end
        2'b11: begin
          rstr_sm_nxt    = RTR_IDLE;
        end
        default: begin
          rstr_sm_nxt    = {RTR_SM_SIZE{1'bx}};
        end
      endcase
    end
    default: begin
      rstr_sm_nxt        = {RTR_SM_SIZE{1'bx}};
    end
  endcase
end

assign restore_active = rstr_sm_r == RTR_RESTORE;

assign last_con_msg = a4s_last_val ? restore_msg && !buffer_active : 1'b0;

assign msg_dec_reg_restore_nxt = msg_dec_a4s_valid_i ?
                                 ((rstr_sm_r == RTR_RESTORE) ?
                                 1'b1 :
                                 (last_con_msg || rstr_sm_nxt == RTR_RESTORE) &&
                                 (msg_dec_a4s_data_i[3:0] == CNCT_ACCEPT_RSP_MSG_HDR)) :
                                 1'b0;

assign msg_dec_reg_restore_o = msg_dec_reg_restore_nxt;


assign msg_dec_reg_restore_data_o =  msg_dec_a4s_data_i;


assign msg_dec_pwr_accept_nxt = msg_dec_a4s_valid_i ?
                                (msg_dec_a4s_last_i &&
                                msg_dec_a4s_data_i[2:0] == DISCNCT_ACCEPT_RSP_MSG_HDR &&
                                !restore_active && !buffer_active) :
                                1'b0;

assign msg_dec_pwr_accept_o = msg_dec_a4s_valid_i ? msg_dec_pwr_accept_nxt : 1'b0;

assign msg_dec_a4s_discon_o = msg_dec_a4s_valid_i ?
                              (msg_dec_pwr_accept_nxt &&
                              (msg_dec_a4s_data_i[2:0] == DISCNCT_ACCEPT_RSP_MSG_HDR)) :
                              1'b0;

assign msg_dec_reg_con_accept_o = msg_dec_a4s_valid_i ?
                                  ((msg_dec_a4s_data_i[3:0] == CNCT_ACCEPT_RSP_MSG_HDR) &&
                                  !restore_active && !buffer_active) :
                                  1'b0;


assign msg_dec_lpi_busy_o = (buff_sm_r != BUF_IDLE) || (rstr_sm_r != RTR_IDLE) ||
                            msg_dec_a4s_valid_i;

endmodule
