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

module firewall_f0_comp_a4s_ds_fsm #(
    parameter FC_CFG_DATA_W   = 32,
    parameter MSG_SIZE        = 35,
    parameter FC_ID           = 1,
    parameter LOG2_FW_NUM_FC  = 5,
    parameter READ_DATA_SIZE  = 7,
    parameter MAX_NUM_OF_PKTS = 2,
    parameter MSG_SIZE_WIDTH  = 1

) (
    input  wire                        clk,
    input  wire                        reset_n,

    output wire                        tvalid_ds_o,
    input  wire                        tready_ds_i,
    output wire  [FC_CFG_DATA_W-1:0]   tdata_ds_o,
    output wire  [FC_CFG_DATA_W/8-1:0] tkeep_ds_o,
    output wire                        tlast_ds_o,
    output wire  [LOG2_FW_NUM_FC-1:0]  tid_ds_o,
    output wire                        twakeup_ds_o,

    input  wire [MSG_SIZE-1:0]         a4s_dn_msg_i,
    input  wire [MSG_SIZE_WIDTH-1:0]   a4s_dn_msg_size_i,
    input  wire                        a4s_dn_msg_valid_i,

    output wire                        a4s_dn_ready_o,

    output wire                        a4s_dn_last_sent_o,

    output wire                        a4s_dn_lpi_busy_o
);


`include "firewall_f0_log2.vh"
`include "firewall_f0_ceil_divide.vh"


localparam SIZE = 2;     
localparam IDLE = 2'b01; 
localparam SEND = 2'b10; 

localparam TID_SIZE     = LOG2_FW_NUM_FC;
localparam KEEP_SIZE    = FC_CFG_DATA_W/8;
localparam COUNTER_SIZE = MSG_SIZE_WIDTH;
localparam FC_TID       = FC_ID - 1;


reg [SIZE-1:0]            state;
reg [SIZE-1:0]            nxt_state;
reg [COUNTER_SIZE-1:0]    counter;
reg [MSG_SIZE-1:0]        msg_sr;
reg                       msg_sr_valid;

reg                       tvalid_ds_o_int;
reg [FC_CFG_DATA_W-1:0]   tdata_ds_o_int;
reg [FC_CFG_DATA_W/8-1:0] tkeep_ds_o_int;
reg                       tlast_ds_o_int;
reg [TID_SIZE-1:0]        tid_ds_o_int;
reg                       twakeup_ds_o_int;
reg                       a4s_dn_ready_o_int;
reg                       a4s_dn_last_sent_o_int;
reg                       a4s_dn_lpi_busy_o_int;

wire [MSG_SIZE_WIDTH-1:0] current_message_size;


assign current_message_size = a4s_dn_msg_size_i;

always @(posedge clk or negedge reset_n)
begin:GO_TO_NEXT_STATE
  if (!reset_n) begin
    state <= IDLE;
  end else begin
    state <= nxt_state;
  end
end

always @(posedge clk or negedge reset_n)
begin: COUNTER_BLOCK
  if (!reset_n) begin
    counter <= {COUNTER_SIZE{1'b0}};
  end else begin
    if (state==SEND) begin
      if (tready_ds_i && (current_message_size > 0) && msg_sr_valid && (counter != (current_message_size))) begin
        counter <= counter + 1'b1;

      end else if ((counter == (current_message_size)) && tready_ds_i) begin
        counter <= {COUNTER_SIZE{1'b0}};
      end

    end else begin
      counter <= {COUNTER_SIZE{1'b0}};
    end
  end
end

always @(posedge clk or negedge reset_n)
begin:SHIFT_REG_BLOCK
  if (!reset_n) begin
    msg_sr       <= {MSG_SIZE{1'b0}};
    msg_sr_valid <= 1'b0;
  end else begin
    if ((counter==(current_message_size) && a4s_dn_last_sent_o_int) ||
        (counter=={COUNTER_SIZE{1'b0}} && a4s_dn_last_sent_o_int) ||
        !msg_sr_valid) begin
      if (a4s_dn_msg_valid_i) begin
        msg_sr       <= a4s_dn_msg_i;
        msg_sr_valid <= 1'b1;
      end else begin
        msg_sr       <= {MSG_SIZE{1'b0}};
        msg_sr_valid <= 1'b0;
      end
    end else begin
      if (state==SEND && tready_ds_i &&
          (current_message_size > 0) && msg_sr_valid) begin
        msg_sr <= {{FC_CFG_DATA_W{1'b0}},msg_sr[MSG_SIZE-1:FC_CFG_DATA_W]};
      end
    end
  end
end

always @(*)
begin:NEXT_STATE
  case (state)
    IDLE: begin
      if (a4s_dn_msg_valid_i) begin
        nxt_state = SEND;
      end else begin
        nxt_state = IDLE;
      end
    end
    SEND: begin
      if (!msg_sr_valid && counter=={COUNTER_SIZE{1'b0}} &&
          !a4s_dn_msg_valid_i) begin
        nxt_state = IDLE;
      end else begin
        nxt_state = SEND;
      end
    end
    default : nxt_state = {SIZE{1'bx}};
  endcase
end

always @(*)
begin:DRIVE_OUTPUTS
  case (state)
    IDLE   : begin
      tvalid_ds_o_int        = 1'b0;
      tdata_ds_o_int         = {FC_CFG_DATA_W{1'b0}};
      tkeep_ds_o_int         = {KEEP_SIZE{1'b1}};
      tlast_ds_o_int         = 1'b0;
      tid_ds_o_int           = FC_TID[TID_SIZE-1:0];
      twakeup_ds_o_int       = 1'b0;

      a4s_dn_ready_o_int     = 1'b1;
      a4s_dn_last_sent_o_int = 1'b0;
      a4s_dn_lpi_busy_o_int  = 1'b0;
    end
    SEND   : begin
      tvalid_ds_o_int        = msg_sr_valid;
      tdata_ds_o_int         = msg_sr[FC_CFG_DATA_W-1:0];
      tkeep_ds_o_int         = {KEEP_SIZE{1'b1}};
      tid_ds_o_int           = FC_TID[TID_SIZE-1:0];
      a4s_dn_lpi_busy_o_int  = 1'b1;

      if (current_message_size > 0) begin
        if (counter==(current_message_size)) begin
          tlast_ds_o_int         = 1'b1;
          a4s_dn_last_sent_o_int = 1'b1 && tready_ds_i;
        end else begin
          tlast_ds_o_int         = 1'b0;
          a4s_dn_last_sent_o_int = 1'b0;
        end
      end else begin
        tlast_ds_o_int         = msg_sr_valid;
        a4s_dn_last_sent_o_int = msg_sr_valid && tready_ds_i;
      end

      a4s_dn_ready_o_int = !msg_sr_valid;

      twakeup_ds_o_int       = tvalid_ds_o_int;
    end

    default: begin 
      tvalid_ds_o_int        = 1'bx;
      tdata_ds_o_int         = {FC_CFG_DATA_W{1'bx}};
      tkeep_ds_o_int         = {KEEP_SIZE{1'bx}};
      tlast_ds_o_int         = 1'bx;
      tid_ds_o_int           = {TID_SIZE{1'bx}};
      twakeup_ds_o_int       = 1'bx;
      a4s_dn_ready_o_int     = 1'bx;
      a4s_dn_last_sent_o_int = 1'bx;
      a4s_dn_lpi_busy_o_int  = 1'bx;
    end
  endcase
end


assign tvalid_ds_o        = tvalid_ds_o_int;
assign tdata_ds_o         = tdata_ds_o_int;
assign tkeep_ds_o         = tkeep_ds_o_int;
assign tlast_ds_o         = tlast_ds_o_int;
assign tid_ds_o           = tid_ds_o_int;
assign twakeup_ds_o       = twakeup_ds_o_int;
assign a4s_dn_ready_o     = a4s_dn_ready_o_int;
assign a4s_dn_last_sent_o = a4s_dn_last_sent_o_int;
assign a4s_dn_lpi_busy_o  = a4s_dn_lpi_busy_o_int ;

endmodule
