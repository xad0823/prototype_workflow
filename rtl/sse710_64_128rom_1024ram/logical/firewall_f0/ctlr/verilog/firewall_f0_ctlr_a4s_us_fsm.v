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

module firewall_f0_ctlr_a4s_us_fsm #(
    parameter FC_CFG_DATA_W       = 32,
    parameter LOG2_FW_NUM_FC      = 5,
    parameter MSG_SIZE            = 46,
    parameter MSG_SIZE_WIDTH      = 1,
    parameter FW_SRE_LVL          = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    output wire                       tvalid_us_o,
    input  wire                       tready_us_i,
    output wire [FC_CFG_DATA_W-1:0]   tdata_us_o,
    output wire [FC_CFG_DATA_W/8-1:0] tkeep_us_o,
    output wire                       tlast_us_o,
    output wire [LOG2_FW_NUM_FC-1:0]  tdest_us_o,
    output wire                       twakeup_us_o,

    input wire [MSG_SIZE-1:0]         a4s_up_msg_i,
    input wire [MSG_SIZE_WIDTH-1:0]   a4s_up_msg_size_i,
    input wire                        a4s_up_msg_valid_i,
    input wire [LOG2_FW_NUM_FC-1:0]   a4s_up_msg_fw_id_i,

    output wire                       a4s_up_prot_block_o,

    output wire                       a4s_up_pkt_sent_o,
    input  wire                       a4s_up_last_pkt_i,
    input  wire                       a4s_up_first_restore_data_i,

    output wire                       a4s_up_lpi_busy_o,

    output wire                       a4s_us_last_sent_o
);


localparam SIZE = 3;      
localparam IDLE = 3'b001; 
localparam SEND = 3'b010; 
localparam RSTR = 3'b100; 

localparam KEEP_SIZE    = FC_CFG_DATA_W/8;
localparam COUNTER_SIZE = MSG_SIZE_WIDTH;

localparam ONE_DEC = 1;


reg [SIZE-1:0] state;

reg [SIZE-1:0] nxt_state;

reg [COUNTER_SIZE-1:0] counter;

reg [MSG_SIZE-1:0] msg_sr;

reg msg_sr_valid;
reg msg_sr_en;

reg [LOG2_FW_NUM_FC-1:0]  tdest_reg;

reg                       tvalid_us_o_int;
reg [FC_CFG_DATA_W-1:0]   tdata_us_o_int;
reg [FC_CFG_DATA_W/8-1:0] tkeep_us_o_int;
reg                       tlast_us_o_int;
reg [LOG2_FW_NUM_FC-1:0]  tdest_us_o_int;
reg                       twakeup_us_o_int;
reg                       a4s_up_ready_o_int;
reg                       a4s_up_last_sent_o_int;
reg                       a4s_up_lpi_busy_o_int;
reg                       a4s_up_prot_block_o_int;

reg restore_valid_r;


always @(posedge clk or negedge reset_n)
begin:GO_TO_NEXT_STATE
  if (!reset_n) begin
    state <= IDLE;
  end
  else begin
    state <= nxt_state;
  end
end

always @(posedge clk or negedge reset_n)
begin: COUNTER_BLOCK
  if (!reset_n) begin
    counter <= {COUNTER_SIZE{1'b0}};
  end
  else begin
    if (state==SEND) begin
      if (tready_us_i &&
         (a4s_up_msg_size_i > {(COUNTER_SIZE){1'b0}}) &&
         msg_sr_valid) begin
         if (counter != (a4s_up_msg_size_i)) begin
           counter <= counter + ONE_DEC[COUNTER_SIZE-1:0];
         end
         else begin
           counter <= {COUNTER_SIZE{1'b0}};
         end
      end
    end
    else begin
      counter <= {COUNTER_SIZE{1'b0}};
    end
  end
end

always @ (posedge clk or negedge reset_n) begin: RESTORE_VAL_BLOCK
  if (!reset_n) begin
    restore_valid_r <= 1'b0;
  end
  else begin
    if (tready_us_i) begin
      restore_valid_r <= 1'b0;
    end
    else if (a4s_up_msg_valid_i) begin
      restore_valid_r <= 1'b1;
    end
  end
end

always @(posedge clk or negedge reset_n)
begin: SHIFT_REGISTER
  if (!reset_n) begin
    msg_sr       <= {MSG_SIZE{1'b0}};
    msg_sr_valid <= 1'b0;
  end
  else begin
    if (msg_sr_en) begin
      msg_sr_valid <= 1'b1;

      if (a4s_up_msg_valid_i) begin
        msg_sr       <= a4s_up_msg_i;
      end
      else if (msg_sr_valid && (a4s_up_msg_size_i > {(COUNTER_SIZE){1'b0}} && tready_us_i)) begin
        msg_sr <= {{FC_CFG_DATA_W{1'b0}},msg_sr[MSG_SIZE-1:FC_CFG_DATA_W]};
      end

    end
    else begin
      msg_sr       <= {MSG_SIZE{1'b0}};
      msg_sr_valid <= 1'b0;
    end
  end
end

always @(*)
begin
  if (nxt_state == SEND || state == SEND) begin
    msg_sr_en = 1'b1;
  end
  else begin
    msg_sr_en = 1'b0;
  end
end

always @(posedge clk or negedge reset_n)
begin:STORE_TDEST
  if (!reset_n) begin
    tdest_reg   <= {LOG2_FW_NUM_FC{1'b0}};
  end
  else begin
    if (a4s_up_msg_valid_i) begin
      tdest_reg <= a4s_up_msg_fw_id_i;
    end
  end
end

always @(*)
begin:NEXT_STATE
  case (state)
    IDLE: begin
      if (a4s_up_first_restore_data_i && a4s_up_msg_valid_i) begin
        nxt_state = RSTR;
      end
      else if (!a4s_up_first_restore_data_i && a4s_up_msg_valid_i) begin
        nxt_state = SEND;
      end
      else begin
        nxt_state = IDLE;
      end
    end

    SEND: begin
      if (a4s_up_last_sent_o_int) begin
        nxt_state = IDLE;
      end else begin
        nxt_state = SEND;
      end
    end

    RSTR: begin
      if (a4s_up_last_pkt_i && a4s_up_last_sent_o_int) begin
        nxt_state = IDLE;
      end
      else begin
        nxt_state = RSTR;
      end
    end
    default : nxt_state = {SIZE{1'bx}};
  endcase
end

always @(*)
begin:DRIVE_OUTPUTS
  case (state)
    IDLE   : begin
      tvalid_us_o_int        = 1'b0;
      tdata_us_o_int         = {FC_CFG_DATA_W{1'b0}};
      tkeep_us_o_int         = {KEEP_SIZE{1'b1}};
      tlast_us_o_int         = 1'b0;
      tdest_us_o_int         = {LOG2_FW_NUM_FC{1'b0}};
      twakeup_us_o_int       = 1'b0;
      a4s_up_ready_o_int     = 1'b1;
      a4s_up_last_sent_o_int = 1'b0;
      a4s_up_lpi_busy_o_int  = 1'b0;
    end
    SEND   : begin
      tvalid_us_o_int        = msg_sr_valid;
      tdata_us_o_int         = msg_sr[FC_CFG_DATA_W-1:0];
      tkeep_us_o_int         = {KEEP_SIZE{1'b1}};
      tdest_us_o_int         = tdest_reg;
      a4s_up_lpi_busy_o_int  = 1'b1;

      if (a4s_up_msg_size_i > {(COUNTER_SIZE){1'b0}}) begin
        if (counter == (a4s_up_msg_size_i)) begin
          tlast_us_o_int         = 1'b1;
          a4s_up_last_sent_o_int = 1'b1 && tready_us_i;
        end
        else begin
          tlast_us_o_int         = 1'b0;
          a4s_up_last_sent_o_int = 1'b0;
        end
      end
      else begin
        tlast_us_o_int         = msg_sr_valid;
        a4s_up_last_sent_o_int = msg_sr_valid && tready_us_i;
      end

      if (a4s_up_msg_size_i > {(COUNTER_SIZE){1'b0}}) begin
        if (counter == (a4s_up_msg_size_i) && tready_us_i) begin
          a4s_up_ready_o_int = 1'b1;
        end
        else begin
          a4s_up_ready_o_int = 1'b0;
        end
      end
      else begin
        a4s_up_ready_o_int = tready_us_i;
      end

      twakeup_us_o_int = tvalid_us_o_int;
    end
    RSTR   : begin
      tvalid_us_o_int  = restore_valid_r || a4s_up_msg_valid_i;
      tdata_us_o_int   = a4s_up_msg_i[FC_CFG_DATA_W-1:0];
      tkeep_us_o_int   = {KEEP_SIZE{1'b1}};
      tlast_us_o_int   = a4s_up_last_pkt_i;
      tdest_us_o_int   = a4s_up_msg_fw_id_i;
      twakeup_us_o_int = tvalid_us_o_int;

      a4s_up_last_sent_o_int = (restore_valid_r || a4s_up_msg_valid_i) && tready_us_i;

      a4s_up_ready_o_int = tready_us_i;

      a4s_up_lpi_busy_o_int  = 1'b1;
    end
    default: begin 
      tvalid_us_o_int        = 1'bx;
      tdata_us_o_int         = {FC_CFG_DATA_W{1'bx}};
      tkeep_us_o_int         = {KEEP_SIZE{1'bx}};
      tlast_us_o_int         = 1'bx;
      tdest_us_o_int         = {LOG2_FW_NUM_FC{1'bx}};
      twakeup_us_o_int       = 1'bx;
      a4s_up_ready_o_int     = 1'bx;
      a4s_up_last_sent_o_int = 1'bx;
      a4s_up_lpi_busy_o_int  = 1'bx;
    end
  endcase
end

always @(posedge clk or negedge reset_n)
begin:DRIVE_PROT_BLOCK_FROM_FLOP
  if (!reset_n) begin
    a4s_up_prot_block_o_int <= 1'b0;
  end
  else begin
    a4s_up_prot_block_o_int <= ~a4s_up_ready_o_int;
  end
end


assign tvalid_us_o            = tvalid_us_o_int;
assign tdata_us_o             = tdata_us_o_int;
assign tkeep_us_o             = tkeep_us_o_int;
assign tlast_us_o             = tlast_us_o_int;
assign tdest_us_o             = tdest_us_o_int;
assign twakeup_us_o           = twakeup_us_o_int;
assign a4s_up_prot_block_o    = a4s_up_prot_block_o_int;
assign a4s_up_pkt_sent_o      = a4s_up_last_sent_o_int;
assign a4s_up_lpi_busy_o      = a4s_up_lpi_busy_o_int;
assign a4s_us_last_sent_o     = a4s_up_last_sent_o_int;

endmodule
