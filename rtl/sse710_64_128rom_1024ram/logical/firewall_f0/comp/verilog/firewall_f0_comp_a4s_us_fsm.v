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

module firewall_f0_comp_a4s_us_fsm #(
    parameter FC_CFG_DATA_W  = 32,
    parameter LOG2_FW_NUM_FC = 5,
    parameter FC_BAS_REG_SLC = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       tvalid_us_i,
    output wire                       tready_us_o,
    input  wire [FC_CFG_DATA_W-1:0]   tdata_us_i,
    input  wire [FC_CFG_DATA_W/8-1:0] tkeep_us_i,
    input  wire                       tlast_us_i,
    input  wire [LOG2_FW_NUM_FC-1:0]  tdest_us_i,
    input  wire                       twakeup_us_i,

    output wire [FC_CFG_DATA_W-1:0]   a4s_data_o,
    output wire                       a4s_last_o,
    output wire                       a4s_valid_o,
    input  wire                       a4s_ready_i,
    input  wire                       a4s_discon_i,

    input  wire                       a4s_con_i,
    input  wire                       a4s_clk_hold_i,
    output wire                       a4s_lpi_busy_o,

    output wire                       a4s_gate_bas_o
);


localparam SIZE = 3;
localparam IDL  = 3'b000; 
localparam RCV  = 3'b001; 
localparam BLK  = 3'b010; 
localparam DSC  = 3'b011; 
localparam RTR  = 3'b100; 


reg [SIZE-1:0] state;
reg [SIZE-1:0] nxt_state;

reg                     tready_us_o_int;
reg [FC_CFG_DATA_W-1:0] a4s_data_o_int;
reg                     a4s_last_o_int;
reg                     a4s_valid_o_int;
reg                     a4s_lpi_busy_o_int;
wire                    a4s_gate_bas_o_int;
reg                     in_rcv_state_r;


always @(*)
begin:FSM_NEXT_STATE
  case (state)
    IDL: begin
      if (a4s_clk_hold_i) begin
        nxt_state = BLK;
      end
      else if (tvalid_us_i & (tdata_us_i[1:0] == 2'b01) & !in_rcv_state_r) begin
        nxt_state = RTR;
      end
      else if (tvalid_us_i) begin
        nxt_state = RCV;
      end
      else begin
        nxt_state = IDL;
      end
    end
    RCV: begin
      if (a4s_discon_i) begin
        nxt_state = DSC;
      end
      else if (!tvalid_us_i) begin
        nxt_state = IDL;
      end
      else begin
        nxt_state = RCV;
      end
    end
    BLK: begin
      if (!a4s_clk_hold_i) begin
        nxt_state = IDL;
      end else begin
        nxt_state = BLK;
      end
    end
    DSC: begin
      if (a4s_con_i) begin
        nxt_state = IDL;
      end else begin
        nxt_state = DSC;
      end
    end
    RTR: begin
      if (tlast_us_i & tvalid_us_i) begin
        nxt_state = IDL;
      end else begin
        nxt_state = RTR;
      end
    end
    default: nxt_state = {SIZE{1'bx}};
  endcase
end

always @(posedge clk or negedge reset_n)
begin: NEXT_STATE
  if (!reset_n) begin
    state <= DSC;
  end else begin
    state <= nxt_state;
  end
end

always @ (posedge clk or negedge reset_n) begin : NEXT_RCV
  if (!reset_n) begin
    in_rcv_state_r <= 1'b0;
  end
  else begin
    if ((nxt_state == RCV) & !tlast_us_i) begin
      in_rcv_state_r <= 1'b1;
    end
    else if (tvalid_us_i & tlast_us_i) begin
      in_rcv_state_r <= 1'b0;
    end
  end
end

always @(*)
begin: STATES
  case (state)
    IDL : begin
      a4s_valid_o_int    = 1'b0;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'b0}};
      a4s_last_o_int     = 1'b0;
      tready_us_o_int    = 1'b0;
      a4s_lpi_busy_o_int = tvalid_us_i;
    end
    RCV : begin
      a4s_valid_o_int    = tvalid_us_i;
      a4s_data_o_int     = tdata_us_i;
      a4s_last_o_int     = tlast_us_i;
      tready_us_o_int    = a4s_ready_i;
      a4s_lpi_busy_o_int = 1'b1;
    end
    RTR : begin
      a4s_valid_o_int    = tvalid_us_i;
      a4s_data_o_int     = tdata_us_i;
      a4s_last_o_int     = tlast_us_i;
      tready_us_o_int    = 1'b1;
      a4s_lpi_busy_o_int = 1'b1;
    end
    BLK : begin
      a4s_valid_o_int    = 1'b0;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'b0}};
      a4s_last_o_int     = 1'b0;
      tready_us_o_int    = 1'b0;
      a4s_lpi_busy_o_int = tvalid_us_i;
    end
    DSC : begin
      a4s_valid_o_int    = 1'b0;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'b0}};
      a4s_last_o_int     = 1'b0;
      tready_us_o_int    = 1'b0;
      a4s_lpi_busy_o_int = tvalid_us_i;
    end
    default: begin
      a4s_valid_o_int    = 1'bx;
      a4s_data_o_int     = {FC_CFG_DATA_W{1'bx}};
      a4s_last_o_int     = 1'bx;
      tready_us_o_int    = 1'bx;
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
        gate_bas_r <= (nxt_state == BLK) || (nxt_state == DSC);
      end
    end

    assign a4s_gate_bas_o_int = gate_bas_r;
  end
  else begin: REG_SLC_BYPASS
    assign a4s_gate_bas_o_int = 1'b0;
  end
endgenerate


assign tready_us_o    = tready_us_o_int;
assign a4s_data_o     = a4s_data_o_int;
assign a4s_last_o     = a4s_last_o_int;
assign a4s_valid_o    = a4s_valid_o_int;
assign a4s_lpi_busy_o = a4s_lpi_busy_o_int;
assign a4s_gate_bas_o = a4s_gate_bas_o_int;

endmodule
