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

module firewall_f0_ctlr_a4s_ds_fsm #(
    parameter FC_CFG_DATA_W  = 32,
    parameter LOG2_FW_NUM_FC = 5,
    parameter FC_BAS_REG_SLC = 0
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       tvalid_ds_i,
    output wire                       tready_ds_o,
    input  wire [FC_CFG_DATA_W-1:0]   tdata_ds_i,
    input  wire [FC_CFG_DATA_W/8-1:0] tkeep_ds_i,
    input  wire                       tlast_ds_i,
    input  wire [LOG2_FW_NUM_FC-1:0]  tid_ds_i,
    input  wire                       twakeup_ds_i,

    output wire [FC_CFG_DATA_W-1:0]   a4s_data_o,
    output wire                       a4s_last_o,
    output wire                       a4s_valid_o,
    output wire [LOG2_FW_NUM_FC-1:0]  a4s_tid_o,

    input  wire                       a4s_lpi_hold_i,
    output wire                       a4s_lpi_busy_o,

    output wire                       a4s_gate_bas_o
);


localparam SIZE = 2;
localparam IDL  = 2'b00; 
localparam RCV  = 2'b01; 
localparam BLK  = 2'b10; 


reg [SIZE-1:0] state;
reg [SIZE-1:0] nxt_state;

reg                      tready_ds_o_int;
reg [FC_CFG_DATA_W-1:0]  a4s_data_o_int;
reg                      a4s_last_o_int;
reg                      a4s_valid_o_int;
reg [LOG2_FW_NUM_FC-1:0] a4s_tid_o_int;
reg                      a4s_lpi_busy_o_int;
wire                     a4s_gate_bas_o_int;


always @(posedge clk or negedge reset_n)
begin: NEXT_STATE
  if (!reset_n) begin
    state <= BLK;
  end
  else begin
    state <= nxt_state;
  end
end

always @(*)
begin: FSM_NEXT_STATE
  case (state)
    IDL    : nxt_state = (a4s_lpi_hold_i ? BLK : (tvalid_ds_i ? RCV : IDL));
    RCV    : nxt_state = !tvalid_ds_i ? IDL : RCV;
    BLK    : nxt_state = !a4s_lpi_hold_i ? IDL : BLK;
    default: nxt_state = {SIZE{1'bx}};
  endcase
end

always @(*)
begin: DRIVE_OUTPUTS
  case (state)
    IDL    : begin
      tready_ds_o_int    = 1'b0;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'b0}} ;
      a4s_last_o_int     = 1'b0;
      a4s_valid_o_int    = 1'b0;
      a4s_tid_o_int      = {LOG2_FW_NUM_FC{1'b0}};
      a4s_lpi_busy_o_int = tvalid_ds_i;
    end
    RCV    : begin
      tready_ds_o_int    = 1'b1;
      a4s_data_o_int     = tdata_ds_i;
      a4s_last_o_int     = tlast_ds_i;
      a4s_valid_o_int    = tvalid_ds_i;
      a4s_tid_o_int      = tid_ds_i;
      a4s_lpi_busy_o_int = 1'b1;
    end
    BLK    : begin
      tready_ds_o_int    = 1'b0;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'b0}};
      a4s_last_o_int     = 1'b0;
      a4s_valid_o_int    = 1'b0;
      a4s_tid_o_int      = {LOG2_FW_NUM_FC{1'b0}};
      a4s_lpi_busy_o_int = tvalid_ds_i;
    end
    default: begin
      tready_ds_o_int    = 1'bx;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'bx}};
      a4s_last_o_int     = 1'bx;
      a4s_valid_o_int    = 1'bx;
      a4s_tid_o_int      = {LOG2_FW_NUM_FC{1'bx}};
      a4s_lpi_busy_o_int = 1'bx;
    end
  endcase
end


generate
  if (FC_BAS_REG_SLC != 3) begin : REG_SLC_NO_BYPASS

    reg gate_bas_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        gate_bas_r <= 1'b1;
      end
      else begin
        gate_bas_r <= nxt_state == BLK;
      end
    end

    assign a4s_gate_bas_o_int = gate_bas_r;
  end
  else begin: REG_SLC_BYPASS
    assign a4s_gate_bas_o_int = 1'b0;
  end
endgenerate


assign tready_ds_o    = tready_ds_o_int;
assign a4s_data_o     = a4s_data_o_int;
assign a4s_last_o     = a4s_last_o_int;
assign a4s_valid_o    = a4s_valid_o_int;
assign a4s_tid_o      = a4s_tid_o_int;
assign a4s_lpi_busy_o = a4s_lpi_busy_o_int;
assign a4s_gate_bas_o = a4s_gate_bas_o_int;

endmodule
