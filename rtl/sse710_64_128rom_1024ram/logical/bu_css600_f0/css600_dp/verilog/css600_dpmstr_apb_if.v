//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019 Arm Limited or its affiliates.
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


module css600_dpmstr_apb_if
  #(parameter ADDR_SIZE = 32,
    parameter SYNC_DEPTH = 2
   )
   (
    input  wire        clk,
    input  wire        reset_n,


    output wire                 psel_o,
    output wire                 pwakeup_o,
    output wire                 penable_o,
    output wire                 pwrite_o,
    output wire [ADDR_SIZE-1:0] paddr_o,
    output wire          [31:0] pwdata_o,
    input  wire          [31:0] prdata_i,
    input  wire                 pready_i,
    input  wire                 pslverr_i,

    input  wire                    bus_req_dp_mstr_i,
    output wire                    bus_req_dp_mstr_o,
    input  wire [ADDR_SIZE+31-1:0] bus_req_payload_i,
    output wire                    bus_ack_dp_mstr_o,
    output wire [33:0]             bus_ack_payload_o,

    input wire                     dev_run_i,

    output wire                    apb_active_o
    );


  localparam    APB_ST_IDLE    =    2'b00;
  localparam    APB_ST_SETUP   =    2'b01;
  localparam    APB_ST_ACCESS  =    2'b11;
  localparam    APB_ST_ACK     =    2'b10;
  localparam    APB_ST_UNDEF   =    2'bxx;


  wire         bus_req_dp_mstr;
  wire         capt_en;

  reg   [1:0]  current_state_q;
  reg   [1:0]  next_state;
  reg          psel_q;
  wire         psel_next;

  wire         bus_pwr_on;
  wire         read_load;
  wire         err_load;
  reg  [31:0]  prdata_q;
  reg          pslverr_q;
  reg          ack_state;

  wire         apb_active;


  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      current_state_q <= APB_ST_IDLE;
    else if (apb_active)
      current_state_q <= next_state;


  always @*
  begin
    case (current_state_q)
      APB_ST_IDLE:
        next_state = (dev_run_i && bus_req_dp_mstr) ? APB_ST_SETUP : APB_ST_IDLE;
      APB_ST_SETUP:
        next_state = APB_ST_ACCESS;
      APB_ST_ACCESS:
        next_state = pready_i ? APB_ST_ACK : APB_ST_ACCESS;

      APB_ST_ACK:
        next_state = !bus_req_dp_mstr ? APB_ST_IDLE : APB_ST_ACK;
      default: next_state = APB_ST_UNDEF;
    endcase
  end

  wire next_ack_state = (next_state == APB_ST_ACK);
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      ack_state <= 1'b0;
    else
      ack_state <= next_ack_state;
  end

  assign penable_o = (current_state_q == APB_ST_ACCESS );

  assign psel_next = (next_state != APB_ST_IDLE) & (next_state != APB_ST_ACK);

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      psel_q <= 1'b0;
    else if (apb_active)
      psel_q <= psel_next;

  assign psel_o = psel_q;
  assign pwakeup_o = psel_q;


  assign capt_en = (next_state == APB_ST_SETUP);

  assign read_load = (current_state_q == APB_ST_ACCESS) & pready_i & (!pwrite_o);

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      prdata_q  <= 0;
    end
    else if (read_load) begin
      prdata_q  <= prdata_i;
    end
    else if (current_state_q == APB_ST_IDLE) begin
      prdata_q  <= 0;
    end
  end

  assign err_load = (current_state_q == APB_ST_ACCESS) & pready_i;

  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      pslverr_q <= 1'b0;
    end
    else if (err_load) begin
      pslverr_q <= pslverr_i;
    end
    else if (current_state_q == APB_ST_IDLE) begin
      pslverr_q <= 1'b0;
    end
  end

  assign apb_active   = bus_req_dp_mstr | ack_state;
  assign apb_active_o = apb_active;


  assign bus_pwr_on = 1'b1;

  assign    bus_ack_dp_mstr_o = ack_state;

  assign    bus_ack_payload_o[31:0] = prdata_q;

  assign    bus_ack_payload_o[32] = pslverr_q;

  assign    bus_ack_payload_o[33] = bus_pwr_on;


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
      u_css600_cdc_capt_sync_req(
                                    .clk       (clk),
                                    .reset_n   (reset_n),
                                    .d_async_i (bus_req_dp_mstr_i),
                                    .q_sync_o  (bus_req_dp_mstr)
                                   );

  assign bus_req_dp_mstr_o = bus_req_dp_mstr;


  css600_cdc_capt_nosync #(.IH(0),.IL(0)) u_css600_cdc_capt_nosync_bus_write(
                                                                  .clk       (clk),
                                                                  .reset_n   (reset_n),
                                                                  .en        (capt_en),
                                                                  .d_async_i (bus_req_payload_i[0]),
                                                                  .q_sync_o  (pwrite_o)
                                                                 );

  css600_cdc_capt_nosync #(.IH(31),.IL(0)) u_css600_cdc_capt_nosync_bus_wdata(
                                                                  .clk       (clk),
                                                                  .reset_n   (reset_n),
                                                                  .en        (capt_en),
                                                                  .d_async_i (bus_req_payload_i[32:1]),
                                                                  .q_sync_o  (pwdata_o)
                                                                 );


  assign paddr_o[1:0] = 2'b00;

  css600_cdc_capt_nosync #(.IH(ADDR_SIZE-3),.IL(0)) u_css600_cdc_capt_nosync_bus_addr(
                                                                  .clk       (clk),
                                                                  .reset_n   (reset_n),
                                                                  .en        (capt_en),
                                                                  .d_async_i (bus_req_payload_i[ADDR_SIZE+31-1:33]),
                                                                  .q_sync_o  (paddr_o[ADDR_SIZE-1:2])
                                                                 );


endmodule
