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
//      Checked In          : Thu Jun 7 13:38:44 2018 +0200
//
//      Revision            : 1c926b6
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//-----------------------------------------------------------------------------

module sdc600_comasyncbridge_indirect_async2com #(
    parameter FF_SYNC_DEPTH = 2
   )
   (
   input  wire           reset_n,
   input  wire           clk,
   output wire   [7:0]   tx_data,
   output wire           tx_valid,
   input  wire           tx_ready,
   input  wire           tx_linkup,
   output wire           tx_linkest,
   input  wire   [7:0]   async_rx_data,
   input  wire           async_rx_req,
   output wire           async_rx_ack,
   output wire           async_rx_linkup,
   input  wire           async_rx_linkest,
   input  wire           clk_on,
   input  wire           pwr_on,
   output wire           sync_rx_req
);


localparam AC_IDLE     = 2'b00;
localparam AC_VALID    = 2'b10;
localparam AC_DONE     = 2'b01;
localparam AC_UNUSED   = 2'b11;


reg   [1:0]  ac_state_nxt;
wire  [1:0]  ac_state;
wire         data_wr_en;
wire         clr_data;
wire         reg_tx_valid;
wire  [7:0]  tx_data_nxt;
wire  [7:0]  reg_tx_data;
wire         reg_async_rx_ack;
wire         async_rx_linkup_nxt;
wire         reg_async_rx_linkup;


always @*
begin
  ac_state_nxt = ac_state;
  case (ac_state)
    AC_IDLE:
      begin
        if (sync_rx_req && tx_linkup && clk_on && pwr_on) begin
          ac_state_nxt = AC_VALID;
        end
      end

    AC_VALID:
      begin
        if (!sync_rx_req || !tx_linkup) begin
          ac_state_nxt = AC_IDLE;
        end
        else if (tx_ready) begin
          ac_state_nxt = AC_DONE;
        end
      end

    AC_DONE:
      begin
        if (!sync_rx_req) begin
          ac_state_nxt = AC_IDLE;
        end
      end

    AC_UNUSED:
      begin
        ac_state_nxt = AC_IDLE;
      end

    default:
      begin
        ac_state_nxt = 2'bxx;
      end
  endcase
end


assign clr_data =  ~pwr_on & clk_on & (ac_state == AC_IDLE);
assign data_wr_en = (ac_state_nxt == AC_VALID) | clr_data;

sdc600_flop #(.DATA_WIDTH(1)) u_reg_tx_valid (.clk(clk), .reset_n(reset_n), .d(ac_state_nxt[1]), .q(reg_tx_valid));
  assign tx_data_nxt = {8{~clr_data}} & async_rx_data;
  sdc600_flop_en #(.DATA_WIDTH(8)) u_reg_tx_data (.clk(clk), .reset_n(reset_n), .d(tx_data_nxt), .en(data_wr_en), .q(reg_tx_data));


assign async_rx_linkup_nxt = tx_linkup & pwr_on;
sdc600_flop    #(.DATA_WIDTH(1)) u_reg_async_rx_ack    (.clk(clk), .reset_n(reset_n), .d(ac_state_nxt[0]    ), .q(reg_async_rx_ack   ));
sdc600_flop_en #(.DATA_WIDTH(1)) u_reg_async_rx_linkup (.clk(clk), .reset_n(reset_n), .d(async_rx_linkup_nxt), .en(clk_on), .q(reg_async_rx_linkup));

assign ac_state[0] = reg_async_rx_ack;
assign ac_state[1] = reg_tx_valid;

assign tx_valid = reg_tx_valid;
assign tx_data = reg_tx_data;


  assign async_rx_ack = reg_async_rx_ack;
  assign async_rx_linkup = reg_async_rx_linkup;


sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_rx_req     (.clk(clk), .reset_n(reset_n), .d(async_rx_req    ), .q(sync_rx_req));
sdc600_sync #(.FF_SYNC_DEPTH(FF_SYNC_DEPTH)) u_sync_async_rx_linkest (.clk(clk), .reset_n(reset_n), .d(async_rx_linkest), .q(tx_linkest ));

endmodule
