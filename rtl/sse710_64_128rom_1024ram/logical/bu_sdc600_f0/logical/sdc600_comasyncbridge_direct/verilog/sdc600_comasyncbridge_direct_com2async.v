//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//      Version Information
//
//      Checked In          : Mon Feb 19 16:31:26 2018 +0100
//
//      Revision            : 19b2149
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------


module sdc600_comasyncbridge_direct_com2async #(
    parameter FF_SYNC_DEPTH = 2
   )
   (
   input  wire           reset_n,
   input  wire           clk,
   input  wire   [7:0]   rx_data,
   input  wire           rx_valid,
   output wire           rx_ready,
   output wire           rx_linkup,
   input  wire           rx_linkest,
   output wire   [7:0]   async_tx_data,
   output wire           async_tx_req,
   input  wire           async_tx_ack,
   input  wire           async_tx_linkup,
   output wire           async_tx_linkest,
   input  wire           clk_on
);


localparam CA_IDLE     = 2'b00;
localparam CA_RESP     = 2'b11;
localparam CA_WAIT     = 2'b01;
localparam CA_UNUSED   = 2'b10;


reg   [1:0]  ca_state_nxt;
wire  [1:0]  ca_state;
wire         reg_rx_ready;
wire         reg_async_tx_req;
wire         sync_tx_ack;

always @*
begin
  ca_state_nxt = ca_state;
  case (ca_state)
    CA_IDLE:
      begin
        if (rx_valid && !sync_tx_ack && clk_on) begin
          ca_state_nxt = CA_WAIT;
        end
      end

    CA_WAIT:
      begin
        if (!rx_valid) begin
          ca_state_nxt = CA_IDLE;
        end
        else if (sync_tx_ack) begin
          ca_state_nxt = CA_RESP;
        end
      end

    CA_RESP:
      begin
        ca_state_nxt = CA_IDLE;
      end

    CA_UNUSED:
      begin
        ca_state_nxt = CA_IDLE;
      end

    default:
      begin
        ca_state_nxt = 2'bxx;
      end
  endcase
end


sdc600_flop #(.DATA_WIDTH(1)) u_reg_rx_ready (.clk(clk), .reset_n(reset_n), .d(ca_state_nxt[1]), .q(reg_rx_ready));

sdc600_flop #(.DATA_WIDTH(1)) u_reg_async_tx_req (.clk(clk), .reset_n(reset_n), .d(ca_state_nxt[0]), .q(reg_async_tx_req));

assign ca_state[0] = reg_async_tx_req;
assign ca_state[1] = reg_rx_ready;
assign rx_ready = reg_rx_ready;

  assign async_tx_req = reg_async_tx_req;
  assign async_tx_linkest = rx_linkest;
  assign async_tx_data = rx_data;


sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_tx_ack    (.clk(clk), .reset_n(reset_n), .d(async_tx_ack   ), .q(sync_tx_ack));
sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_tx_linkup (.clk(clk), .reset_n(reset_n), .d(async_tx_linkup), .q(rx_linkup  ));

endmodule
