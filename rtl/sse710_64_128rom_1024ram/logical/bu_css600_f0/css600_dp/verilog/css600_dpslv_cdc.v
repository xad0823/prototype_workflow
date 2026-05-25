//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_dp
//
//----------------------------------------------------------------------------


module css600_dpslv_cdc
  #(parameter ADDR_SIZE = 32,
    parameter SYNC_DEPTH = 2
   )
   (
    input  wire                    swclktck,
    input  wire                    porst_n,

    input  wire [31:0]             bus_wdata_i,
    input  wire  [1:0]             bus_addr_i,
    input  wire                    bus_write_i,
    input  wire                    bus_load_int_i,
    output wire                    bus_req_int_rising_o,
    input  wire                    bus_req_int_i,
    input  wire                    bus_req_int_reject_i,
    output wire                    bus_pwr_int_o,

    input  wire                    swactive_rise_i,

    output wire [31:0]             bus_rdata_o,
    output wire                    bus_err_set_o,
    output wire                    bus_ack_int_o,

    output wire                    bus_req_o,
    output wire [ADDR_SIZE+31-1:0] bus_req_payload_o,
    input  wire                    bus_ack_i,
    input  wire [33:0]             bus_ack_payload_i,

    input wire [ADDR_SIZE-1:0]     reg_paddr_i
    );


  reg  [31:0] bus_wdata_q;
  reg   [1:0] bus_addr_q;
  reg         bus_write_q;

  wire        bus_req_next;
  reg         bus_req_q;
  wire        bus_auto_next;
  reg         bus_auto_q;

  wire        bus_pwr_on_sync;
  wire        bus_ack_sync;
  wire        bus_ack_sync_masked;
  reg         bus_ack_sync_q;
  wire        bus_ack_sync_rising;
  wire        bus_ack_int;

  wire        bus_req_int_rising;
  wire        bus_req_int_falling;
  wire        bus_rdata_ce;
  wire        bus_rdata_clr;
  wire [31:0] bus_rdata_sync_next;
  wire [31:0] bus_rdata_sync;
  wire        bus_err_sync;
  wire        bus_rdata_sync_load;
  wire        bus_err_set;

  assign bus_rdata_o          = bus_rdata_sync;
  assign bus_err_set_o        = bus_err_set;
  assign bus_ack_int_o        = bus_ack_int;
  assign bus_pwr_int_o        = bus_pwr_on_sync;
  assign bus_req_int_rising_o = bus_req_int_rising;


  assign bus_req_next = bus_req_int_i & ~bus_req_int_reject_i
                      | bus_auto_next
                      | bus_auto_q
                      ;

  always @(posedge swclktck, negedge porst_n)
    if (!porst_n)
      bus_req_q <= 1'b0;
    else
      bus_req_q <= bus_req_next;

  assign bus_auto_next = bus_req_int_falling & ~bus_ack_sync_masked
                       | bus_auto_q          & ~bus_ack_sync_masked
                       ;
  always @(posedge swclktck, negedge porst_n)
    if (!porst_n)
      bus_auto_q <= 1'b0;
    else
      bus_auto_q <= bus_auto_next;

  always @ (posedge swclktck, negedge porst_n) begin
    if (!porst_n) begin
      bus_wdata_q <= 0;
      bus_addr_q  <= 2'h0;
      bus_write_q <= 1'b0;
    end
    else if (bus_load_int_i) begin
      bus_wdata_q <= bus_wdata_i;
      bus_addr_q  <= bus_addr_i;
      bus_write_q <= bus_write_i;
    end
  end

  always @(posedge swclktck, negedge porst_n)
    if (!porst_n)
      bus_ack_sync_q <= 1'b0;
    else
      bus_ack_sync_q <= bus_ack_sync_masked;

  assign bus_req_int_rising  =  bus_req_int_i & ~bus_req_q;
  assign bus_req_int_falling = ~bus_req_int_i &  bus_req_q & ~bus_auto_q;
  assign bus_err_set         = bus_req_int_falling & bus_err_sync
                             | bus_req_int_reject_i
                             ;

  assign bus_ack_sync_masked = bus_ack_sync & bus_pwr_on_sync;
  assign bus_ack_int         = bus_ack_sync_masked &  bus_ack_sync_q;
  assign bus_ack_sync_rising = bus_ack_sync_masked & ~bus_ack_sync_q;
  assign bus_rdata_sync_load = bus_ack_sync_rising  & ~bus_write_q;
  assign bus_rdata_clr       = swactive_rise_i
                             | bus_req_int_reject_i & ~bus_write_q
                             ;
  assign bus_rdata_ce        = bus_rdata_clr
                             | bus_rdata_sync_load
                             ;


  css600_cdc_capt_nosync #(
    .IH(31),.IL(0)
  ) u_css600_cdc_capt_nosync_bus_rdata(
    .clk       (swclktck),
    .reset_n   (porst_n),
    .en        (bus_rdata_ce),
    .d_async_i (bus_rdata_sync_next),
    .q_sync_o  (bus_rdata_sync)
  );

  css600_and #( .OP_W(32) ) u_rdbuf_clr (
     .datain  (bus_ack_payload_i[31:0]),
     .maskn   (~bus_rdata_clr),
     .dataout (bus_rdata_sync_next)
  );

  css600_cdc_capt_nosync #(
    .IH(0),.IL(0)
  ) u_css600_cdc_capt_nosync_bus_err_sync(
    .clk       (swclktck),
    .reset_n   (porst_n),
    .en        (bus_ack_sync_rising),
    .d_async_i (bus_ack_payload_i[32]),
    .q_sync_o  (bus_err_sync)
  );


  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (SYNC_DEPTH)
  ) u_css600_cdc_capt_bus_ack_sync(
    .clk       (swclktck),
    .reset_n   (porst_n),
    .d_async_i (bus_ack_i),
    .q_sync_o  (bus_ack_sync)
  );

  css600_cdc_capt_sync #(
    .FF_SYNC_DEPTH (SYNC_DEPTH)
  ) u_css600_cdc_capt_bus_pwr_on_sync(
    .clk       (swclktck),
    .reset_n   (porst_n),
    .d_async_i (bus_ack_payload_i[33]),
    .q_sync_o  (bus_pwr_on_sync)
  );


  assign    bus_req_o = bus_req_q;

  assign    bus_req_payload_o[0] = bus_write_q;

  assign    bus_req_payload_o[32:1] = bus_wdata_q[31:0];

  assign    bus_req_payload_o[34:33] = bus_addr_q;
  assign    bus_req_payload_o[ADDR_SIZE-1-4+35:35] = reg_paddr_i[ADDR_SIZE-1:4];


endmodule
