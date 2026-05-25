//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2008-2017, 2019 Arm Limited or its affiliates.
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


module css600_dpslv_sw_protocol
  #(parameter SWDP_WRITEBUFFER = 1)
  (
    input  wire        swclk,
    input  wire        porst_n,

    input  wire        swdi_q_i,
    output wire        swdo_o,
    output wire        swdoen_o,

    output wire [31:0] bus_wdata_o,
    output wire  [1:0] bus_addr_o,
    output wire        bus_write_o,
    output wire        bus_req_int_o,
    output wire        bus_req_int_reject_o,

    input  wire [31:0] bus_rdata_i,
    input  wire        bus_ack_int_i,
    input  wire        bus_pwr_int_i,

    output wire [31:0] reg_wdata_o,
    output wire  [1:0] reg_addr_o,
    output wire        reg_write_o,
    output wire        reg_orun_o,
    output wire        reg_wdata_err_o,
    output wire        reg_readok_o,
    output wire        reg_sel_o,
    output wire        stickyerr_clr_o,

    input wire  [31:0] reg_rdata_i,
    input wire         reg_stky_err_i,
    input wire   [3:0] reg_select_dpbanksel_i,
    input wire [31:28] reg_dlpidr_i,
    input wire  [27:0] reg_targetid_i,
    input wire         reg_orundetect_i,
    input wire         reg_wdataerr_i,

    input  wire       protocol_err_req_i,

    output wire       linereset_o,

    input wire        swactive_i,

    input wire [1:0]  sw_trn_i
   );


  `include "css600_dpslv_sw_localparams.v"

  wire    [7:0] sw_state;
  reg     [7:0] sw_state_q;
  reg           sw_step_ndat;
  wire          sw_step_norm;
  reg     [7:0] sw_next_norm;
  wire          sw_step_reset;
  wire    [7:0] sw_next_reset;
  reg           sw_step_mux;
  wire    [7:0] sw_next_main;
  wire    [7:0] sw_next_step;
  reg     [7:0] sw_next_mux;
  wire    [7:0] sw_next;
  wire    [7:0] sw_next_parity_rst;
  wire    [7:0] sw_next_stop_rst;

  wire          count_50;
  wire    [6:0] count_inc;

  reg     [3:0] packet;
  wire          packet_shift;
  wire    [3:0] packet_next;
  wire          packet_ap_ndp;
  wire          packet_r_nw;
  wire    [1:0] packet_reg_addr;

  reg           parity;
  wire          parity_next;
  wire          parity_load;
  wire          parity_generate;
  wire          parity_ack_ok_en;
  wire          parity_ack_wait_en;
  wire          parity_ack_fault_en;
  wire          parity_reset;
  wire          parity_source;
  wire          sw_parity_err;

  wire          sw_linereset;
  wire          sw_start_bit;
  wire          sw_data_end_ok;
  wire          perform_tx_write_dp;
  wire          perform_tx_write_ap;
  wire          perform_tx_write;
  wire          sw_ack0_bit;
  wire          perform_tx_read_dp;
  wire          perform_tx_read_ap;
  wire          perform_tx_read;
  wire          perform_tx;
  wire          dp_write;
  wire          non_waitable_tx;
  wire          dpidr_dec;
  wire          tsel_dec;
  wire          targetsel;
  wire          reg_sel;
  wire    [1:0] reg_addr;
  wire          reg_write;
  wire   [31:0] reg_wdata;

  reg    [31:0] sw_data;
  wire          sw_header_valid;
  wire          sw_state_prev_ack;
  wire          sw_state_prev_ackok;
  wire          ap_acc;
  reg           ap_wait;
  wire          dp_wait;
  wire          sw_reg_load;
  wire          sw_ap_load;
  wire          sw_data_shift;
  wire   [31:0] sw_data_shifted;
  wire   [31:0] sw_data_next;
  wire          sw_data_load;

  wire          start_ap_tx;
  reg           bus_req_ap;
  wire          bus_req_ap_next;
  wire          bus_req_ap_load;
  wire    [1:0] bus_addr;
  wire          bus_write;
  wire   [31:0] bus_wdata;
  reg           bus_req_int;
  reg           bus_req_int_reject;
  reg           bus_ack_ap;
  wire          stickyerr_clr;

  wire          ack_ok_inst;
  wire          ack_wait_inst;
  wire          ack_fault;
  reg     [1:0] ack_q;


  wire          wdataerr_detected;
  wire          stickyorun_detected;

  reg           dp_cs_readok;
  wire          dp_cs_readok_load;
  wire          dp_cs_readok_next;


  wire          swdi_int;
  wire          swdi_int_en;
  wire          swdoen_ack;
  wire          swdoen_next;
  wire          swdo;
  reg           swdoen;

  assign   swdo_o                = swdo;
  assign   swdoen_o              = swdoen;
  assign   bus_wdata_o           = bus_wdata;
  assign   bus_addr_o            = bus_addr;
  assign   bus_write_o           = bus_write;
  assign   bus_req_int_o         = bus_req_int;
  assign   bus_req_int_reject_o  = bus_req_int_reject;
  assign   reg_wdata_o           = reg_wdata;
  assign   reg_addr_o            = reg_addr;
  assign   reg_write_o           = reg_write;
  assign   reg_orun_o            = stickyorun_detected;
  assign   reg_sel_o             = reg_sel;
  assign   reg_wdata_err_o       = wdataerr_detected;
  assign   reg_readok_o          = dp_cs_readok;
  assign   stickyerr_clr_o       = stickyerr_clr;
  assign   linereset_o           = sw_linereset;


  assign     sw_next_parity_rst = (swdi_int ?
                                   (packet[3] ?
                                    (packet[2] ?
                                     (packet[1] ?
                                      (packet[0] ?
                                       SW_ST_RST_6 :
                                       SW_ST_RST_4) :
                                      SW_ST_RST_3) :
                                     SW_ST_RST_2) :
                                    SW_ST_RST_1) :
                                   SW_ST_RST_0);

  assign     sw_next_stop_rst   = (parity ?
                                   (packet[3] ?
                                    (packet[2] ?
                                     (packet[1] ?
                                      (packet[0] ?
                                       SW_ST_RST_7 :
                                       SW_ST_RST_5) :
                                      SW_ST_RST_4) :
                                     SW_ST_RST_3) :
                                    SW_ST_RST_2) :
                                   SW_ST_RST_1);

  always @*
    begin
      sw_step_ndat = 1'bx;
      sw_next_norm = {8{1'bx}};
      case (sw_state[5:0])
        SW_ST_DATAPARITY[5:0]: begin
                                 sw_step_ndat = packet_r_nw;
                                 sw_next_norm = (tsel_dec
                                                 ? (targetsel
                                                    ? SW_ST_RST_START
                                                    : SW_ST_RST_0)
                                                 :  SW_ST_START
                                                 );
                               end
        SW_ST_ENDTRN0[5:0]   : sw_step_ndat = 1'b1;
        SW_ST_ENDTRN1[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b00);
                                 sw_next_norm = SW_ST_START;
                               end
        SW_ST_ENDTRN2[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b01);
                                 sw_next_norm = SW_ST_START;
                               end
        SW_ST_ENDTRN3[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b10);
                                 sw_next_norm = SW_ST_START;
                               end
        SW_ST_ENDTRN4[5:0]   : sw_step_ndat = 1'b1;
        SW_ST_START[5:0]     : begin
                                 sw_step_ndat = swdi_int;
                                 sw_next_norm = SW_ST_START;
                               end
        SW_ST_AP_N_DP[5:0]   : sw_step_ndat = 1'b1;
        SW_ST_R_N_W[5:0]     : sw_step_ndat = 1'b1;
        SW_ST_A0[5:0]        : sw_step_ndat = 1'b1;
        SW_ST_A1[5:0]        : sw_step_ndat = 1'b1;
        SW_ST_PARITY[5:0]    : begin
                                 sw_step_ndat = ~(sw_parity_err | tsel_dec);
                                 sw_next_norm = sw_next_parity_rst;
                               end
        SW_ST_STOP[5:0]      : begin
                                 sw_step_ndat = ~swdi_int;
                                 sw_next_norm = sw_next_stop_rst;
                               end
        SW_ST_PARK[5:0]      : begin
                                 sw_step_ndat = swdi_int & (ack_ok_inst | reg_orundetect_i) & (sw_trn_i > 2'b00);
                                 sw_next_norm = swdi_int ?
                                                  ((ack_ok_inst || reg_orundetect_i) ? SW_ST_ACK0
                                                    : ((sw_trn_i > 2'b00) ? SW_ST_PACKET_TRN0
                                                        : SW_ST_ACK0_NODAT
                                                      )
                                                  )
                                                  : SW_ST_RST_0;
                               end
        SW_ST_PACKET_TRN0[5:0]: begin
                                 sw_step_ndat = (sw_trn_i > 2'b01);
                                 sw_next_norm = (ack_ok_inst || reg_orundetect_i) ? SW_ST_ACK0
                                                                                  : SW_ST_ACK0_NODAT;
                               end

        SW_ST_PACKET_TRN1[5:0]: begin
                                 sw_step_ndat = (sw_trn_i > 2'b10);
                                 sw_next_norm = (ack_ok_inst || reg_orundetect_i) ? SW_ST_ACK0
                                                                                  : SW_ST_ACK0_NODAT;
                               end

        SW_ST_PACKET_TRN2[5:0]: begin
                                 sw_step_ndat = (ack_ok_inst | reg_orundetect_i);
                                 sw_next_norm = SW_ST_ACK0_NODAT;
                               end

        SW_ST_ACK0[5:0]      : sw_step_ndat = 1'b1;
        SW_ST_ACK1[5:0]      : sw_step_ndat = 1'b1;
        SW_ST_ACK2[5:0]      : begin
                                 sw_step_ndat = ~packet_r_nw;
                                 sw_next_norm = SW_ST_DATA0;
                               end
        SW_ST_ACKTRN0[5:0]   : sw_step_ndat = 1'b1;
        SW_ST_ACKTRN1[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b00);
                                 sw_next_norm = SW_ST_DATA0;
                               end
        SW_ST_ACKTRN2[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b01);
                                 sw_next_norm = SW_ST_DATA0;
                               end
        SW_ST_ACKTRN3[5:0]   : begin
                                 sw_step_ndat = (sw_trn_i > 2'b10);
                                 sw_next_norm = SW_ST_DATA0;
                               end

        SW_ST_ACKTRN4[5:0]   : begin
                                 sw_step_ndat = 1'b0;
                                 sw_next_norm = SW_ST_DATA0;
                               end
        SW_ST_ACK0_NODAT[5:0]: sw_step_ndat = 1'b1;
        SW_ST_ACK1_NODAT[5:0]: sw_step_ndat = 1'b1;
        SW_ST_ACK2_NODAT[5:0]: begin
                                 sw_step_ndat = 1'b0;
                                 sw_next_norm = SW_ST_ENDTRN0;
                               end
        SW_ST_RST_START[5:0] : begin
                                 sw_step_ndat = swdi_int;
                                 sw_next_norm = SW_ST_RST_START;
                               end
        SW_ST_RST_AP_N_DP[5:0]: sw_step_ndat = 1'b1;
        SW_ST_RST_R_N_W[5:0]  : sw_step_ndat = 1'b1;
        SW_ST_RST_A0[5:0]     : sw_step_ndat = 1'b1;
        SW_ST_RST_A1[5:0]     : sw_step_ndat = 1'b1;
        SW_ST_RST_PARITY[5:0]: begin
                                 sw_step_ndat = 1'b0;
                                 sw_next_norm = (((dpidr_dec || tsel_dec) && !sw_parity_err)
                                                 ? SW_ST_STOP
                                                 : sw_next_parity_rst);
                               end
        SW_ST_PACKET_TRN0_NODAT[5:0],
        SW_ST_PACKET_TRN1_NODAT[5:0],
        SW_ST_PACKET_TRN2_NODAT[5:0],
        SW_ST_UNUSED0 [5:0],
        SW_ST_UNUSED1 [5:0],
        SW_ST_UNUSED2 [5:0],
        SW_ST_UNUSED3 [5:0],
        SW_ST_UNUSED4 [5:0],
        SW_ST_UNUSED5 [5:0],
        SW_ST_UNUSED6 [5:0],
        SW_ST_UNUSED7 [5:0],
        SW_ST_UNUSED8 [5:0],
        SW_ST_UNUSED9 [5:0],
        SW_ST_UNUSED10[5:0],
        SW_ST_UNUSED11[5:0],
        SW_ST_UNUSED12[5:0],
        SW_ST_UNUSED13[5:0],
        SW_ST_UNUSED14[5:0],
        SW_ST_UNUSED15[5:0],
        SW_ST_UNUSED16[5:0],
        SW_ST_UNUSED17[5:0],
        SW_ST_UNUSED18[5:0],
        SW_ST_UNUSED19[5:0],
        SW_ST_UNUSED20[5:0],
        SW_ST_UNUSED21[5:0],
        SW_ST_UNUSED22[5:0],
        SW_ST_UNUSED23[5:0],
        SW_ST_UNUSED24[5:0],
        SW_ST_UNUSED25[5:0],
        SW_ST_UNUSED26[5:0]  : begin
                                 sw_step_ndat = 1'b0;
                                 sw_next_norm = SW_ST_RST_0;
                               end
        default              : begin
                                 sw_step_ndat = 1'bx;
                                 sw_next_norm = {8{1'bx}};
                               end
      endcase
    end

  assign sw_step_norm = sw_step_ndat | (sw_state[6] == SW_ST_DATA0[6]);

  assign count_50 = sw_state[5] & sw_state[4] & sw_state[1];

  assign count_inc = sw_state[6:0] + 7'b0000001;

  assign sw_next_step = {sw_state[7], count_inc[6:0]};

  assign sw_step_reset = swdi_int & ~count_50;
  assign sw_next_reset = (count_50
                          ? (swdi_int
                             ? SW_ST_RST_50
                                : SW_ST_RST_START
                                )
                          : SW_ST_RST_0
                          );

  always @*
    case (sw_state[7])
      1'b0:  sw_step_mux = sw_step_norm;
      1'b1:  sw_step_mux = sw_step_reset;
      default: sw_step_mux = 1'bx;
    endcase

  always @*
    case (sw_state[7])
      1'b0:  sw_next_mux = sw_next_norm;
      1'b1:  sw_next_mux = sw_next_reset;
      default: sw_next_mux = {8{1'bx}};
    endcase

  assign sw_next_main = sw_step_mux ? sw_next_step : sw_next_mux;

  assign sw_next = !protocol_err_req_i ? sw_next_main : SW_ST_RST_0;

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      sw_state_q <= SW_ST_RST_0;
    else
      sw_state_q <= sw_next;

  assign sw_state = sw_state_q;


  assign packet_shift = ( ((sw_state & SW_ST_HDR_MASK) == SW_ST_AP_N_DP) |
                          ((sw_state & SW_ST_HDR_MASK) == SW_ST_R_N_W) |
                          ((sw_state & SW_ST_HDR_MASK) == SW_ST_A0) |
                          ((sw_state & SW_ST_HDR_MASK) == SW_ST_A1)
                        );

  assign packet_next = {swdi_int, packet[3:1]};

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      packet <= 4'b1111;
    else if (packet_shift)
      packet <= packet_next;

  assign packet_ap_ndp    = packet[0];
  assign packet_r_nw      = packet[1];
  assign packet_reg_addr  = packet[3:2];


  assign parity_source = (sw_data_shift && packet_r_nw) ? swdo
                                                        : swdi_int;

  assign parity_reset = ( sw_start_bit
                        | ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK2)
                        | ((sw_state == SW_ST_ACKTRN1) & (sw_trn_i == 2'b00))
                        | ((sw_state == SW_ST_ACKTRN2) & (sw_trn_i == 2'b01))
                        | ((sw_state == SW_ST_ACKTRN3) & (sw_trn_i == 2'b10))
                        | ((sw_state == SW_ST_ACKTRN4) & (sw_trn_i == 2'b11)) );

  assign parity_generate = (packet_shift | sw_data_shift);

  assign parity_ack_ok_en     = ( ((sw_state == SW_ST_PARK) & (sw_trn_i == 2'b00))
                                | (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN0) & (sw_trn_i == 2'b01))
                                | (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN1) & (sw_trn_i == 2'b10))
                                | (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN2) & (sw_trn_i == 2'b11))
                                );
  assign parity_ack_wait_en   = ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0);
  assign parity_ack_fault_en  = ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK1);

  assign parity_next =  (parity_generate      & (parity ^ parity_source))   |
                        (parity_ack_ok_en     & ack_ok_inst)                |
                        (parity_ack_wait_en   & (ack_q==SWACK_WAIT)) |
                        (parity_ack_fault_en  & (ack_q==SWACK_FAULT));

  assign parity_load =  parity_reset        |
                        parity_generate     |
                        parity_ack_ok_en    |
                        parity_ack_wait_en  |
                        parity_ack_fault_en;

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      parity <= 1'b1;
    else if (parity_load)
      parity <= parity_next;

  assign sw_parity_err = (swdi_int ^ parity);


  assign sw_linereset   = (sw_state == SW_ST_RST_50);

  assign sw_start_bit       = ((sw_state & SW_ST_HDR_MASK) == SW_ST_START);

  assign sw_data_end_ok = (sw_state == SW_ST_DATAPARITY) &
                          (ack_q == SWACK_OK);

  assign sw_ack0_bit = (sw_state == SW_ST_ACK0);


  assign perform_tx_read_dp  = ~packet_ap_ndp & sw_data_end_ok                          &  packet_r_nw;
  assign perform_tx_read_ap  =  packet_ap_ndp & sw_ack0_bit       & (ack_q == SWACK_OK) &  packet_r_nw;
  assign perform_tx_read = perform_tx_read_dp | perform_tx_read_ap;

  assign perform_tx_write_dp = ~packet_ap_ndp & sw_data_end_ok & ~sw_parity_err         & ~packet_r_nw;
  assign perform_tx_write_ap =  packet_ap_ndp & sw_data_end_ok & ~sw_parity_err         & ~packet_r_nw;
  assign perform_tx_write = perform_tx_write_dp | perform_tx_write_ap;

  assign perform_tx = perform_tx_read | perform_tx_write;

  assign dp_write = perform_tx_write & ~packet_ap_ndp;

  assign non_waitable_tx = ~packet_ap_ndp
                         & ( (  packet_r_nw & (packet_reg_addr == SW_REGADDR_DPIDR   ) & (reg_select_dpbanksel_i == SW_DPBANK_DPIDR   ))
                           | (  packet_r_nw & (packet_reg_addr == SW_REGADDR_DPIDR1  ) & (reg_select_dpbanksel_i == SW_DPBANK_DPIDR1  ))
                           | (  packet_r_nw & (packet_reg_addr == SW_REGADDR_CTRLSTAT) & (reg_select_dpbanksel_i == SW_DPBANK_CTRLSTAT))
                           | ( ~packet_r_nw & (packet_reg_addr == SW_REGADDR_ABORT   )                                                 )
                           | tsel_dec
                           );

  assign dpidr_dec =  (~packet_ap_ndp) & packet_r_nw &
                      (packet_reg_addr == SW_REGADDR_DPIDR) &
                      (reg_select_dpbanksel_i == SW_DPBANK_DPIDR);

  assign tsel_dec   = (~packet_ap_ndp) & (~packet_r_nw) &
                      (packet_reg_addr == SW_REGADDR_TARGETSEL);
  assign targetsel  = (sw_data == {reg_dlpidr_i[31:28], reg_targetid_i[27:0]}) &
                      (~sw_parity_err);


  assign reg_sel = dp_write | sw_reg_load;

  assign reg_addr = packet_reg_addr;
  assign reg_write = dp_write;
  assign reg_wdata = sw_data;

  assign sw_header_valid = ((sw_state == SW_ST_PARK) & (swdi_int));

  assign sw_state_prev_ack = (sw_header_valid                 & (sw_trn_i == 2'b00)) |
                             (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN0) & (sw_trn_i == 2'b01)) |
                             (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN1) & (sw_trn_i == 2'b10)) |
                             (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN2) & (sw_trn_i == 2'b11));

  assign sw_state_prev_ackok = sw_state_prev_ack & ack_ok_inst;

  assign ap_acc = packet_ap_ndp |
                  ((packet_reg_addr == SW_REGADDR_RDBUFF) &
                  packet_r_nw);

  assign sw_reg_load = sw_state_prev_ackok & (~packet_ap_ndp);

  assign sw_ap_load = sw_state_prev_ackok & (packet_ap_ndp);

  assign sw_data_shift = (sw_state[7:5] == SW_ST_DATA0[7:5])
                       & (ack_q == SWACK_OK)
                       ;

  assign sw_data_shifted = {swdi_int, sw_data[31:1]};
  assign sw_data_next = ({32{sw_reg_load}}     & reg_rdata_i)    |
                        ({32{sw_data_shift}}   & sw_data_shifted)|
                        ({32{sw_ap_load}}      & bus_rdata_i);

  assign sw_data_load = sw_data_shift | sw_state_prev_ackok;

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      sw_data <= {32{1'b1}};
    else if (sw_data_load)
      sw_data <= sw_data_next;


  assign start_ap_tx = perform_tx & packet_ap_ndp;

  assign stickyerr_clr = ack_fault & sw_state_prev_ack;

  assign bus_req_ap_next = (start_ap_tx             ) ? 1'b1
                         : (bus_req_ap && bus_ack_ap) ? 1'b0
                         :                              bus_req_ap
                         ;

  assign bus_req_ap_load = start_ap_tx | (bus_req_ap & bus_ack_ap);

  always @(posedge swclk or negedge porst_n)
    if(!porst_n)
      bus_req_ap <= 1'b0;
    else if (bus_req_ap_load)
      bus_req_ap <= bus_req_ap_next;


  generate
    if (SWDP_WRITEBUFFER != 1) begin : cfg_no_write_buffer
        wire bus_interface_busy;
        wire bus_busy_inst;
        wire bus_busy_load;
        reg  bus_busy_q;

        assign bus_addr  = packet_reg_addr;
        assign bus_write = (~packet_r_nw);
        assign bus_wdata = sw_data;
        always @* begin
          bus_req_int             = bus_req_ap;
          bus_ack_ap              = bus_ack_int_i | bus_req_int_reject;
          ap_wait                 = bus_busy_inst;
        end

        always @* begin
          bus_req_int_reject      = bus_req_ap & ~bus_pwr_int_i;
        end

        assign dp_wait            = bus_busy_inst;

        assign bus_interface_busy = bus_req_ap    ? 1'b1
                                  : bus_ack_int_i ? 1'b1
                                  :                 1'b0
                                  ;

        assign bus_busy_inst      = bus_interface_busy & bus_busy_q;
        always @(posedge swclk or negedge porst_n)
          if (!porst_n)
            bus_busy_q <= 1'b0;
          else if (bus_busy_load)
            bus_busy_q <= start_ap_tx;

        assign bus_busy_load = start_ap_tx |
                              (sw_state_prev_ack & (~bus_busy_inst) &
                               (ap_acc |
                                (~(packet_r_nw | tsel_dec))));

      end

    else begin : cfg_write_buffer
        reg  [1:0] bus_addr_q;
        reg        bus_write_q;
        reg [31:0] bus_wdata_q;
        reg  [2:0] bus_state_next;
        reg  [2:0] bus_state_q;
        reg        write_buffer_busy;
        reg        read_posting_busy;

        always @(posedge swclk)
          if (start_ap_tx) begin
            bus_addr_q  <= packet_reg_addr;
            bus_write_q <= (~packet_r_nw);
            bus_wdata_q <= sw_data;
          end
        assign bus_addr  = bus_addr_q;
        assign bus_write = bus_write_q;
        assign bus_wdata = bus_wdata_q;

        assign dp_wait = sw_state_prev_ack & ~ap_acc & ~non_waitable_tx & write_buffer_busy
                       | sw_state_prev_ack & ~ap_acc & ~non_waitable_tx & read_posting_busy
                       | sw_state_prev_ack & ~ap_acc & ~non_waitable_tx & bus_ack_ap
                       ;

        always @* begin
          bus_req_int_reject      = 1'b0;
          bus_req_int             = 1'b0;
          bus_ack_ap              = 1'b0;
          bus_state_next          = bus_state_q;
          write_buffer_busy       = 1'b0;
          read_posting_busy       = 1'b0;
          ap_wait                 = sw_state_prev_ack & ap_acc;

          case (bus_state_q)

            BUS_IDLE: begin
              ap_wait             = 1'b0;
              if          ( bus_ack_int_i) begin bus_state_next = BUS_IDLE;
              end else if (!bus_req_ap   ) begin bus_state_next = BUS_IDLE;
              end else if (!bus_write_q  ) begin bus_state_next = BUS_RREQ; bus_req_int=1'b1;
              end else if ( bus_write_q  ) begin bus_state_next = BUS_WREQ; bus_req_int=1'b1; bus_ack_ap = 1'b1;
              end
            end

            BUS_RREQ: begin
              read_posting_busy   = 1'b1;
              bus_req_int         = 1'b1;
              if          (!bus_pwr_int_i)
                                           begin bus_state_next = BUS_IDLE;                   bus_ack_ap = 1'b1; bus_req_int_reject=1'b1;
              end else if (bus_ack_int_i ) begin bus_state_next = BUS_RACK;
              end
            end

            BUS_RACK: begin
              read_posting_busy   = 1'b1;
              bus_ack_ap          = 1'b1;
              if          (bus_ack_int_i ) begin bus_state_next = BUS_RACK;
              end else                     begin bus_state_next = BUS_IDLE;                   bus_ack_ap = 1'b0; ap_wait = 1'b0; read_posting_busy = 1'b0;
              end
            end

            BUS_WREQ: begin
              ap_wait             = sw_state_prev_ack & ap_acc & (packet_r_nw | bus_req_ap);
              write_buffer_busy   = 1'b1;
              bus_req_int         = 1'b1;
              if          (!swactive_i   )
                                           begin bus_state_next = BUS_IDLE;                   bus_ack_ap = 1'b1;
              end else if (!bus_pwr_int_i)
                                           begin bus_state_next = BUS_IDLE;                   bus_ack_ap = 1'b1; bus_req_int_reject=1'b1;
              end else if (bus_ack_int_i ) begin bus_state_next = BUS_WACK;
              end
            end

            BUS_WACK: begin
              ap_wait             = sw_state_prev_ack & ap_acc & (packet_r_nw | bus_req_ap);
              write_buffer_busy   = 1'b1;
              if          (bus_ack_int_i ) begin bus_state_next = BUS_WACK;
              end else if (bus_req_ap    ) begin bus_state_next = BUS_WREQ;
                                                                                                   bus_ack_ap = 1'b1;
              end else                     begin bus_state_next = BUS_IDLE;
              end
            end

            BUS_UNUSED1,
            BUS_UNUSED4,
            BUS_UNUSED5 : begin
              bus_state_next = BUS_IDLE;
            end

            default : begin
              bus_req_int_reject  = 1'bx;
              bus_req_int         = 1'bx;
              bus_ack_ap          = 1'bx;
              write_buffer_busy   = 1'bx;
              read_posting_busy   = 1'bx;
              ap_wait             = 1'bx;
            end
          endcase
        end

        always @(posedge swclk or negedge porst_n)
           if (!porst_n)
             bus_state_q <= BUS_IDLE;
           else
             bus_state_q <= bus_state_next;

      end

  endgenerate


  assign ack_fault      = (~non_waitable_tx) &
                          (~ack_wait_inst) &
                          (reg_wdataerr_i | reg_stky_err_i);

  assign ack_wait_inst  = (ap_wait | dp_wait) &
                         (~non_waitable_tx);

  assign ack_ok_inst    = ~ack_fault & ~ack_wait_inst;


  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      ack_q <= SWACK_WAIT;
    else if (sw_state_prev_ack)
      ack_q <= ack_fault     ? SWACK_FAULT
             : ack_wait_inst ? SWACK_WAIT
             :                 SWACK_OK
             ;

  assign wdataerr_detected =  (sw_data_end_ok) &
                              (~packet_r_nw) &
                              (sw_parity_err & ~tsel_dec);

  assign stickyorun_detected  = reg_orundetect_i &
                                ( (((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0) &
                                   (ack_q!=SWACK_OK)) |
                                  (sw_state[7] == SW_ST_RST_0[7]) |
                                  wdataerr_detected);


  assign dp_cs_readok_load =  sw_state_prev_ack &
                                    ap_acc &
                                    packet_r_nw;
  assign dp_cs_readok_next = ack_ok_inst;

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      dp_cs_readok <= 1'b0;
    else if (dp_cs_readok_load)
      dp_cs_readok <= dp_cs_readok_next;


  assign swdoen_ack = (sw_trn_i == 2'b00) ? (sw_header_valid |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK1)) :
                      (sw_trn_i == 2'b01) ? (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN0) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK1)) :
                      (sw_trn_i == 2'b10) ? (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN1) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK1)) :
                                            (((sw_state & SW_ST_ACK_MASK) == SW_ST_PACKET_TRN2) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK0) |
                                            ((sw_state & SW_ST_ACK_MASK) == SW_ST_ACK1));


  assign swdoen_next = ((swdoen_ack &
                         ~tsel_dec) |
                        ((sw_state == SW_ST_ACK2) &
                         packet_r_nw & (ack_q == SWACK_OK)) |
                        (swdoen & sw_data_shift & (ack_q == SWACK_OK))) & (!protocol_err_req_i);

  always @(posedge swclk or negedge porst_n)
    if (!porst_n)
      swdoen <= 1'b0;
    else
      swdoen <= swdoen_next;

  assign swdo = sw_state[6] ? sw_data[0] : parity;

  assign swdi_int_en =  (
                          sw_start_bit |
                          packet_shift |
                          ((sw_state & SW_ST_HDR_MASK) == SW_ST_PARITY) |
                          (sw_state == SW_ST_STOP) |
                          (sw_state == SW_ST_PARK) |
                          ((~packet_r_nw) & (
                            sw_data_shift |
                            (sw_state == SW_ST_DATAPARITY) )) |
                          (sw_state[7] == SW_ST_RST_0[7])
                        );

  css600_and #( .OP_W(1) )
    u_mask_swdi_sw
      (.datain   (swdi_q_i),
       .maskn    (swdi_int_en),
       .dataout  (swdi_int));


endmodule
