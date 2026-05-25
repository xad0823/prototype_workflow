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
//      Checked In          : Fri Apr 27 15:42:10 2018 +0200
//
//      Revision            : 8eaf807
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------

module sdc600_comasyncbridge_indirect_com2async #(
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
   input  wire           clk_on,
   input  wire           pwr_on,
   output wire           sync_tx_ack
);


localparam CA_IDLE     = 2'b00;
localparam CA_RESP     = 2'b11;
localparam CA_WAIT     = 2'b01;
localparam CA_UNUSED   = 2'b10;


reg   [1:0]  ca_state_nxt;
wire  [1:0]  ca_state;
wire         data_wr_en;
wire         clr_data;
reg          async_tx_linkest_nxt;
wire         reg_rx_ready;
wire         reg_async_tx_req;
wire         reg_async_tx_linkest;
wire  [7:0]  async_tx_data_nxt;
wire  [7:0]  reg_async_tx_data;


always @*
begin
  ca_state_nxt = ca_state;
  case (ca_state)
    CA_IDLE:
      begin
        if (rx_valid && !sync_tx_ack && clk_on && pwr_on) begin
          ca_state_nxt = CA_RESP;
        end
      end

    CA_RESP:
      begin
        if (!rx_valid)  begin
          ca_state_nxt = CA_IDLE;
        end
        else begin
          ca_state_nxt = CA_WAIT;
        end
      end

    CA_WAIT:
      begin
        if (sync_tx_ack) begin
          ca_state_nxt = CA_IDLE;
        end
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

always @*
begin
  if (!clk_on) begin
     async_tx_linkest_nxt = reg_async_tx_linkest;
  end
  else if (!pwr_on) begin
    async_tx_linkest_nxt = 1'b0;
  end
  else if (rx_linkest) begin
    async_tx_linkest_nxt = 1'b1;
  end
  else if (sync_tx_ack || ca_state == CA_IDLE) begin
    async_tx_linkest_nxt = 1'b0;
  end
  else begin
    async_tx_linkest_nxt = reg_async_tx_linkest;
  end
end


assign clr_data = ~pwr_on & clk_on & (ca_state == CA_IDLE);
assign async_tx_data_nxt = {8{~clr_data}} & rx_data;
assign data_wr_en = (ca_state_nxt == CA_RESP) | clr_data;

sdc600_flop #(.DATA_WIDTH(1)) u_reg_rx_ready (.clk(clk), .reset_n(reset_n), .d(ca_state_nxt[1]), .q(reg_rx_ready));

sdc600_flop #(.DATA_WIDTH(1)) u_reg_async_tx_req     (.clk(clk), .reset_n(reset_n), .d(ca_state_nxt[0]     ), .q(reg_async_tx_req    ));
sdc600_flop #(.DATA_WIDTH(1)) u_reg_async_tx_linkest (.clk(clk), .reset_n(reset_n), .d(async_tx_linkest_nxt), .q(reg_async_tx_linkest));
sdc600_flop_en #(.DATA_WIDTH(8)) u_reg_async_tx_data (.clk(clk), .reset_n(reset_n), .d(async_tx_data_nxt), .en(data_wr_en), .q(reg_async_tx_data));

assign ca_state[0] = reg_async_tx_req;
assign ca_state[1] = reg_rx_ready;
assign rx_ready = reg_rx_ready;

  assign async_tx_req = reg_async_tx_req;
  assign async_tx_linkest = reg_async_tx_linkest;
  assign async_tx_data = reg_async_tx_data;


sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_tx_ack    (.clk(clk), .reset_n(reset_n), .d(async_tx_ack   ), .q(sync_tx_ack));
sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_tx_linkup (.clk(clk), .reset_n(reset_n), .d(async_tx_linkup), .q(rx_linkup  ));

endmodule
