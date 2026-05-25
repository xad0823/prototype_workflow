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


module css600_dpslv_jtag_protocol
  #(parameter JTAGDP_IRLEN = 4)
   (

    input  wire        tck,
    input  wire        porst_n,

    input  wire        jtagactive_i,

    input  wire        ntrst,
    input  wire        tdi_i,
    input  wire        tms_i,
    output wire        tdo_o,
    output wire        tdo_en_n_o,

    output wire [31:0] bus_wdata_o,
    output wire  [1:0] bus_addr_o,
    output wire        bus_write_o,
    output wire        bus_load_int_o,
    output wire        bus_req_int_o,
    output wire        bus_req_int_reject_o,

    input  wire [31:0] bus_rdata_i,
    input  wire        bus_ack_int_i,
    input  wire        bus_pwr_int_i,

    output wire [31:0] reg_wdata_o,
    output wire  [1:0] reg_addr_o,
    output wire        reg_write_o,
    output wire        reg_orun_o,
    output wire        reg_sel_o,
    output wire        stickyerr_clr_o,

    input wire [31:0] reg_rdata_i,
    input wire        reg_stky_err_i,

    input  wire       tlr_reset_req_i,

    output wire  [3:0] jtagstate_o,

    output wire [JTAGDP_IRLEN-1:0] jtagir_o

    );


  `include "css600_dpslv_jtag_localparams.v"


  localparam [31:0] JTAGDP_DEVICEID = JTAGDP_IRLEN==8 ? JTAGDP_DEVICEID_IR8 :
                                      JTAGDP_DEVICEID_IR4;


  reg         tdo;
  wire        tdo_en_n;


  wire        tck_n;
  reg         tdo_next_data;
  wire        tdo_next;
  wire        tdo_load;
  reg         tdo_en;

  reg  [3:0]  jtag_state_q;
  reg  [3:0]  jtag_state_case;
  wire [3:0]  jtag_state_next;
  wire        jtag_state_en;


  reg  [2:0]              jtag_inst;
  reg  [2:0]              jtag_inst_enc;
  wire [2:0]              jtag_inst_next;
  wire                    jtag_inst_next_id_ab;
  wire                    jtag_inst_load;
  wire                    jtag_inst_load_next_id_ab;
  reg  [JTAGDP_IRLEN-1:0] jtagir;
  wire [JTAGDP_IRLEN-1:0] jtagir_next;

  wire        ir_apacc;
  wire        ir_dpacc;
  wire        ir_dpapacc;
  wire        ir_abort;
  wire        ir_idcode;

  wire        tdi_masked;

  reg  [31:0] jtag_sc_top;
  reg  [2:0]  jtag_sc_btm;

  wire [31:0] jtag_sc_top_next;
  wire [31:0] jtag_sc_shifted;
  wire        jtag_sc_top_load;
  wire [2:0]  jtag_sc_btm_next;
  wire        jtag_sc_btm_load;
  wire        jtag_sc_btm_ldack;
  wire        jtag_sc_btm_shift;

  wire        state_cir;
  wire        state_cdr;
  wire        state_udr;
  wire        state_uir;
  wire        state_sdr;
  wire        state_sir;
  wire        state_tlr;
  wire        shift_sel;
  wire        id_sel;
  wire        cir_sel;

  wire        ack_ok;
  wire        ack_fault;
  wire        ack_wait;
  wire        ap_wait;
  wire        dp_wait;
  wire [2:0]  ack;
  reg         prev_ap_id_ab_ndp;
  wire        prev_ap_id_ab_ndp_next;
  wire        prev_ap_id_ab_ndp_load;

  reg         ack_wait_q;
  reg         ack_fault_q;
  wire        stickyerr_clr;

  wire [1:0]  tx_addr;
  wire        tx_write;

  wire        perform_tx_ap;
  wire        bus_req_ap_next;
  reg         bus_req_ap;
  reg         bus_req_ap_q;
  wire        bus_req_int_reject;
  wire        bus_req_int_accept;
  reg         bus_req_int;
  wire        bus_load_int;
  reg         bus_ack_ap;
  wire [1:0]  bus_addr;
  wire        bus_write;
  wire [31:0] bus_wdata;
  reg [0:0]   bus_state_next;
  reg [0:0]   bus_state;

  wire        reg_orun_next;
  reg         reg_orun;

  wire        perform_tx_wr_dp;
  wire        perform_tx_rd_dp;
  wire        perform_dp_abort;
  wire        ap_id_ab_sel;
  wire        reg_sel;
  wire [1:0]  reg_addr;
  wire        reg_write;
  wire [31:0] reg_wdata;


  wire [31:0] jtag_tap_id;

  assign tdo_o                  = tdo;
  assign tdo_en_n_o             = tdo_en_n;
  assign bus_wdata_o            = bus_wdata;
  assign bus_addr_o             = bus_addr;
  assign bus_write_o            = bus_write;
  assign bus_load_int_o         = bus_load_int;
  assign bus_req_int_o          = bus_req_int;
  assign bus_req_int_reject_o   = bus_req_int_reject;
  assign reg_wdata_o            = reg_wdata;
  assign reg_addr_o             = reg_addr;
  assign reg_write_o            = reg_write;
  assign reg_orun_o             = reg_orun;
  assign reg_sel_o              = reg_sel;
  assign jtagir_o               = jtagir;
  assign jtagstate_o            = jtag_state_q;

  assign stickyerr_clr_o        = stickyerr_clr;


  localparam [0:0] BUS_ALIVE = 1'd0;
  localparam [0:0] BUS_BUSY  = 1'd1;

  assign tck_n = ~tck;

  assign jtag_tap_id = JTAGDP_DEVICEID;

  always @*
    case (jtag_state_q)
      JTAG_TLR : jtag_state_case = (tms_i ? JTAG_TLR : JTAG_RTI);
      JTAG_RTI : jtag_state_case = (tms_i ? JTAG_SDS : JTAG_RTI);
      JTAG_SDS : jtag_state_case = (tms_i ? JTAG_SIS : JTAG_CDR);
      JTAG_CDR : jtag_state_case = (tms_i ? JTAG_E1D : JTAG_SDR);
      JTAG_SDR : jtag_state_case = (tms_i ? JTAG_E1D : JTAG_SDR);
      JTAG_E1D : jtag_state_case = (tms_i ? JTAG_UDR : JTAG_PDR);
      JTAG_PDR : jtag_state_case = (tms_i ? JTAG_E2D : JTAG_PDR);
      JTAG_E2D : jtag_state_case = (tms_i ? JTAG_UDR : JTAG_SDR);
      JTAG_UDR : jtag_state_case = (tms_i ? JTAG_SDS : JTAG_RTI);
      JTAG_SIS : jtag_state_case = (tms_i ? JTAG_TLR : JTAG_CIR);
      JTAG_CIR : jtag_state_case = (tms_i ? JTAG_E1I : JTAG_SIR);
      JTAG_SIR : jtag_state_case = (tms_i ? JTAG_E1I : JTAG_SIR);
      JTAG_E1I : jtag_state_case = (tms_i ? JTAG_UIR : JTAG_PIR);
      JTAG_PIR : jtag_state_case = (tms_i ? JTAG_E2I : JTAG_PIR);
      JTAG_E2I : jtag_state_case = (tms_i ? JTAG_UIR : JTAG_SIR);
      JTAG_UIR : jtag_state_case = (tms_i ? JTAG_SDS : JTAG_RTI);
      default : jtag_state_case = 4'bxxxx;
    endcase

  assign jtag_state_next = !tlr_reset_req_i ? jtag_state_case : JTAG_TLR;
  assign jtag_state_en = (jtagactive_i | tlr_reset_req_i);

  always @(posedge tck or negedge ntrst)
    if (!ntrst)
      jtag_state_q <= JTAG_TLR;
    else if (jtag_state_en)
      jtag_state_q <= jtag_state_next;


  generate
    if(JTAGDP_IRLEN == 4) begin : IR_4_ENC
      always @*
        case (jtag_sc_top[31:28])
          JTAG_ABORT   : jtag_inst_enc = JTAG_3_ABORT;
          JTAG_DPACC   : jtag_inst_enc = JTAG_3_DPACC;
          JTAG_APACC   : jtag_inst_enc = JTAG_3_APACC;
          JTAG_IDCODE  : jtag_inst_enc = JTAG_3_IDCODE;
          JTAG_BYPASS  : jtag_inst_enc = JTAG_3_BYPASS;
          JTAG_UNSUP0,
          JTAG_UNSUP1,
          JTAG_UNSUP2,
          JTAG_UNSUP3,
          JTAG_UNSUP4,
          JTAG_UNSUP5,
          JTAG_UNSUP6,
          JTAG_UNSUP7,
          JTAG_UNSUP9,
          JTAG_UNSUPC,
          JTAG_UNSUPD  : jtag_inst_enc = JTAG_3_BYPASS;
          default      : jtag_inst_enc = 3'bxxx;
        endcase
    end
    else if (JTAGDP_IRLEN == 8) begin : IR_8_ENC
      always @*
        case (jtag_sc_top[31:24])
          JTAG_ABORT     : jtag_inst_enc = JTAG_3_ABORT;
          JTAG_DPACC     : jtag_inst_enc = JTAG_3_DPACC;
          JTAG_APACC     : jtag_inst_enc = JTAG_3_APACC;
          JTAG_IDCODE    : jtag_inst_enc = JTAG_3_IDCODE;
          JTAG_BYPASS    : jtag_inst_enc = JTAG_3_BYPASS;
          JTAG_UNSUP0_0,
          JTAG_UNSUP1_0,
          JTAG_UNSUP2_0,
          JTAG_UNSUP3_0,
          JTAG_UNSUP4_0,
          JTAG_UNSUP5_0,
          JTAG_UNSUP6_0,
          JTAG_UNSUP7_0,
          JTAG_UNSUP8_0,
          JTAG_UNSUP9_0,
          JTAG_UNSUPA_0,
          JTAG_UNSUPB_0,
          JTAG_UNSUPC_0,
          JTAG_UNSUPD_0,
          JTAG_UNSUPE_0,
          JTAG_UNSUPF_0,
          JTAG_UNSUP0_1,
          JTAG_UNSUP1_1,
          JTAG_UNSUP2_1,
          JTAG_UNSUP3_1,
          JTAG_UNSUP4_1,
          JTAG_UNSUP5_1,
          JTAG_UNSUP6_1,
          JTAG_UNSUP7_1,
          JTAG_UNSUP8_1,
          JTAG_UNSUP9_1,
          JTAG_UNSUPA_1,
          JTAG_UNSUPB_1,
          JTAG_UNSUPC_1,
          JTAG_UNSUPD_1,
          JTAG_UNSUPE_1,
          JTAG_UNSUPF_1,
          JTAG_UNSUP0_2,
          JTAG_UNSUP1_2,
          JTAG_UNSUP2_2,
          JTAG_UNSUP3_2,
          JTAG_UNSUP4_2,
          JTAG_UNSUP5_2,
          JTAG_UNSUP6_2,
          JTAG_UNSUP7_2,
          JTAG_UNSUP8_2,
          JTAG_UNSUP9_2,
          JTAG_UNSUPA_2,
          JTAG_UNSUPB_2,
          JTAG_UNSUPC_2,
          JTAG_UNSUPD_2,
          JTAG_UNSUPE_2,
          JTAG_UNSUPF_2,
          JTAG_UNSUP0_3,
          JTAG_UNSUP1_3,
          JTAG_UNSUP2_3,
          JTAG_UNSUP3_3,
          JTAG_UNSUP4_3,
          JTAG_UNSUP5_3,
          JTAG_UNSUP6_3,
          JTAG_UNSUP7_3,
          JTAG_UNSUP8_3,
          JTAG_UNSUP9_3,
          JTAG_UNSUPA_3,
          JTAG_UNSUPB_3,
          JTAG_UNSUPC_3,
          JTAG_UNSUPD_3,
          JTAG_UNSUPE_3,
          JTAG_UNSUPF_3,
          JTAG_UNSUP0_4,
          JTAG_UNSUP1_4,
          JTAG_UNSUP2_4,
          JTAG_UNSUP3_4,
          JTAG_UNSUP4_4,
          JTAG_UNSUP5_4,
          JTAG_UNSUP6_4,
          JTAG_UNSUP7_4,
          JTAG_UNSUP8_4,
          JTAG_UNSUP9_4,
          JTAG_UNSUPA_4,
          JTAG_UNSUPB_4,
          JTAG_UNSUPC_4,
          JTAG_UNSUPD_4,
          JTAG_UNSUPE_4,
          JTAG_UNSUPF_4,
          JTAG_UNSUP0_5,
          JTAG_UNSUP1_5,
          JTAG_UNSUP2_5,
          JTAG_UNSUP3_5,
          JTAG_UNSUP4_5,
          JTAG_UNSUP5_5,
          JTAG_UNSUP6_5,
          JTAG_UNSUP7_5,
          JTAG_UNSUP8_5,
          JTAG_UNSUP9_5,
          JTAG_UNSUPA_5,
          JTAG_UNSUPB_5,
          JTAG_UNSUPC_5,
          JTAG_UNSUPD_5,
          JTAG_UNSUPE_5,
          JTAG_UNSUPF_5,
          JTAG_UNSUP0_6,
          JTAG_UNSUP1_6,
          JTAG_UNSUP2_6,
          JTAG_UNSUP3_6,
          JTAG_UNSUP4_6,
          JTAG_UNSUP5_6,
          JTAG_UNSUP6_6,
          JTAG_UNSUP7_6,
          JTAG_UNSUP8_6,
          JTAG_UNSUP9_6,
          JTAG_UNSUPA_6,
          JTAG_UNSUPB_6,
          JTAG_UNSUPC_6,
          JTAG_UNSUPD_6,
          JTAG_UNSUPE_6,
          JTAG_UNSUPF_6,
          JTAG_UNSUP0_7,
          JTAG_UNSUP1_7,
          JTAG_UNSUP2_7,
          JTAG_UNSUP3_7,
          JTAG_UNSUP4_7,
          JTAG_UNSUP5_7,
          JTAG_UNSUP6_7,
          JTAG_UNSUP7_7,
          JTAG_UNSUP8_7,
          JTAG_UNSUP9_7,
          JTAG_UNSUPA_7,
          JTAG_UNSUPB_7,
          JTAG_UNSUPC_7,
          JTAG_UNSUPD_7,
          JTAG_UNSUPE_7,
          JTAG_UNSUPF_7,
          JTAG_UNSUP0_8,
          JTAG_UNSUP1_8,
          JTAG_UNSUP2_8,
          JTAG_UNSUP3_8,
          JTAG_UNSUP4_8,
          JTAG_UNSUP5_8,
          JTAG_UNSUP6_8,
          JTAG_UNSUP7_8,
          JTAG_UNSUP8_8,
          JTAG_UNSUP9_8,
          JTAG_UNSUPA_8,
          JTAG_UNSUPB_8,
          JTAG_UNSUPC_8,
          JTAG_UNSUPD_8,
          JTAG_UNSUPE_8,
          JTAG_UNSUPF_8,
          JTAG_UNSUP0_9,
          JTAG_UNSUP1_9,
          JTAG_UNSUP2_9,
          JTAG_UNSUP3_9,
          JTAG_UNSUP4_9,
          JTAG_UNSUP5_9,
          JTAG_UNSUP6_9,
          JTAG_UNSUP7_9,
          JTAG_UNSUP8_9,
          JTAG_UNSUP9_9,
          JTAG_UNSUPA_9,
          JTAG_UNSUPB_9,
          JTAG_UNSUPC_9,
          JTAG_UNSUPD_9,
          JTAG_UNSUPE_9,
          JTAG_UNSUPF_9,
          JTAG_UNSUP0_A,
          JTAG_UNSUP1_A,
          JTAG_UNSUP2_A,
          JTAG_UNSUP3_A,
          JTAG_UNSUP4_A,
          JTAG_UNSUP5_A,
          JTAG_UNSUP6_A,
          JTAG_UNSUP7_A,
          JTAG_UNSUP8_A,
          JTAG_UNSUP9_A,
          JTAG_UNSUPA_A,
          JTAG_UNSUPB_A,
          JTAG_UNSUPC_A,
          JTAG_UNSUPD_A,
          JTAG_UNSUPE_A,
          JTAG_UNSUPF_A,
          JTAG_UNSUP0_B,
          JTAG_UNSUP1_B,
          JTAG_UNSUP2_B,
          JTAG_UNSUP3_B,
          JTAG_UNSUP4_B,
          JTAG_UNSUP5_B,
          JTAG_UNSUP6_B,
          JTAG_UNSUP7_B,
          JTAG_UNSUP8_B,
          JTAG_UNSUP9_B,
          JTAG_UNSUPA_B,
          JTAG_UNSUPB_B,
          JTAG_UNSUPC_B,
          JTAG_UNSUPD_B,
          JTAG_UNSUPE_B,
          JTAG_UNSUPF_B,
          JTAG_UNSUP0_C,
          JTAG_UNSUP1_C,
          JTAG_UNSUP2_C,
          JTAG_UNSUP3_C,
          JTAG_UNSUP4_C,
          JTAG_UNSUP5_C,
          JTAG_UNSUP6_C,
          JTAG_UNSUP7_C,
          JTAG_UNSUP8_C,
          JTAG_UNSUP9_C,
          JTAG_UNSUPA_C,
          JTAG_UNSUPB_C,
          JTAG_UNSUPC_C,
          JTAG_UNSUPD_C,
          JTAG_UNSUPE_C,
          JTAG_UNSUPF_C,
          JTAG_UNSUP0_D,
          JTAG_UNSUP1_D,
          JTAG_UNSUP2_D,
          JTAG_UNSUP3_D,
          JTAG_UNSUP4_D,
          JTAG_UNSUP5_D,
          JTAG_UNSUP6_D,
          JTAG_UNSUP7_D,
          JTAG_UNSUP8_D,
          JTAG_UNSUP9_D,
          JTAG_UNSUPA_D,
          JTAG_UNSUPB_D,
          JTAG_UNSUPC_D,
          JTAG_UNSUPD_D,
          JTAG_UNSUPE_D,
          JTAG_UNSUPF_D,
          JTAG_UNSUP0_E,
          JTAG_UNSUP1_E,
          JTAG_UNSUP2_E,
          JTAG_UNSUP3_E,
          JTAG_UNSUP4_E,
          JTAG_UNSUP5_E,
          JTAG_UNSUP6_E,
          JTAG_UNSUP7_E,
          JTAG_UNSUP8_E,
          JTAG_UNSUP9_E,
          JTAG_UNSUPA_E,
          JTAG_UNSUPB_E,
          JTAG_UNSUPC_E,
          JTAG_UNSUPD_E,
          JTAG_UNSUPE_E,
          JTAG_UNSUPF_E,
          JTAG_UNSUP0_F,
          JTAG_UNSUP1_F,
          JTAG_UNSUP2_F,
          JTAG_UNSUP3_F,
          JTAG_UNSUP4_F,
          JTAG_UNSUP5_F,
          JTAG_UNSUP6_F,
          JTAG_UNSUP7_F,
          JTAG_UNSUP9_F,
          JTAG_UNSUPC_F,
          JTAG_UNSUPD_F  : jtag_inst_enc = JTAG_3_BYPASS;
          default        : jtag_inst_enc = 3'bxxx;
        endcase
    end
  endgenerate

  assign jtag_inst_next = (state_tlr
                           ? JTAG_3_IDCODE
                           : jtag_inst_enc);

  assign jtag_inst_next_id_ab = (jtag_inst_next == JTAG_3_IDCODE) | (jtag_inst_next == JTAG_3_ABORT);

  assign jtag_inst_load = state_tlr | state_uir;

  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      jtag_inst <= JTAG_3_IDCODE;
    else if (jtag_inst_load)
      jtag_inst <= jtag_inst_next;

  assign jtagir_next = (state_tlr
                        ? JTAG_IDCODE
                        : jtag_sc_top[31:31-JTAGDP_IRLEN+1]);

  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      jtagir <= JTAG_IDCODE;
    else if (jtag_inst_load)
      jtagir <= jtagir_next;

  assign ir_apacc   = (jtag_inst == JTAG_3_APACC);
  assign ir_dpacc   = (jtag_inst == JTAG_3_DPACC);
  assign ir_abort   = (jtag_inst == JTAG_3_ABORT);
  assign ir_idcode  = (jtag_inst == JTAG_3_IDCODE);
  assign ir_dpapacc = (jtag_inst == JTAG_3_DPACC) | (jtag_inst == JTAG_3_APACC);

  always @*
    case (jtag_inst)
      JTAG_3_BYPASS  : tdo_next_data = jtag_sc_top[31];
      JTAG_3_IDCODE  : tdo_next_data = jtag_sc_top[0];
      JTAG_3_ABORT,
      JTAG_3_DPACC,
      JTAG_3_APACC   : tdo_next_data = jtag_sc_btm[0];
      default        : tdo_next_data = 1'bx;
    endcase

  generate
    if(JTAGDP_IRLEN == 4) begin : IR_4_TDO_NEXT
      assign tdo_next = (state_sdr
                         ? tdo_next_data
                         : jtag_sc_top[28]);
    end
    else if (JTAGDP_IRLEN == 8) begin : IR_8_TDO_NEXT
      assign tdo_next = (state_sdr
                         ? tdo_next_data
                         : jtag_sc_top[24]);
    end
  endgenerate

  assign tdo_load = state_sdr | state_sir;

  always @(posedge tck_n or negedge porst_n)
    if (!porst_n)
      tdo <= 1'b0;
    else if (tdo_load)
      tdo <= tdo_next;

  always @(posedge tck_n or negedge porst_n)
    if (!porst_n)
      tdo_en <= 1'b0;
    else
      tdo_en <= tdo_load;

  assign tdo_en_n = ~tdo_en;

  assign state_cir            = (jtag_state_q == JTAG_CIR);
  assign state_cdr            = (jtag_state_q == JTAG_CDR);
  assign state_uir            = (jtag_state_q == JTAG_UIR);
  assign state_udr            = (jtag_state_q == JTAG_UDR);
  assign state_sir            = (jtag_state_q == JTAG_SIR);
  assign state_sdr            = (jtag_state_q == JTAG_SDR);
  assign state_tlr            = (jtag_state_q == JTAG_TLR);

  assign shift_sel            = state_sdr | state_sir;
  assign id_sel               = state_cdr & ir_idcode;
  assign ap_id_ab_sel         = state_cdr & ir_dpapacc & prev_ap_id_ab_ndp;
  assign cir_sel              = state_cir;

  generate
    if(JTAGDP_IRLEN == 4) begin : IR_4_CIR
      assign jtag_sc_top_next = ({32{   shift_sel   }} & {tdi_i,jtag_sc_top[31:1]} )
                              | ({32{   id_sel      }} & jtag_tap_id               )
                              | ({32{   ap_id_ab_sel}} & bus_rdata_i               )
                              | ({32{   reg_sel     }} & reg_rdata_i               )
                              | ({31'b0,cir_sel      } << 28                       )
                              ;
    end
    else if (JTAGDP_IRLEN == 8) begin : IR_8_CIR
      assign jtag_sc_top_next = ({32{   shift_sel   }} & {tdi_i,jtag_sc_top[31:1]} )
                              | ({32{   id_sel      }} & jtag_tap_id               )
                              | ({32{   ap_id_ab_sel}} & bus_rdata_i               )
                              | ({32{   reg_sel     }} & reg_rdata_i               )
                              | ({31'b0,cir_sel      } << 24                       )
                              ;
    end
  endgenerate

  assign jtag_sc_top_load     = state_cdr
                              | state_cir
                              | state_sdr
                              | state_sir
                              ;

  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      jtag_sc_top             <= {32{1'b1}};
    else if (jtag_sc_top_load)
      jtag_sc_top             <= jtag_sc_top_next;

  assign ap_wait              = state_cdr & ir_apacc & ( bus_req_ap
                                                       )
                                                       ;
  assign dp_wait              = state_cdr & ir_dpacc & ( bus_req_ap
                                                       | bus_ack_int_i
                                                       )
                                                       ;
  assign ack_wait             = ap_wait | dp_wait;

  assign ack_fault            = state_cdr
                              & ir_dpapacc
                              & prev_ap_id_ab_ndp
                              & ~ack_wait
                              & reg_stky_err_i
                              ;

  assign ack_ok               = state_cdr & ~(ack_fault | ack_wait);

  assign ack                  = {ack_ok,ack_fault,ack_wait};

  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      ack_wait_q              <= 1'b1;
    else if (jtag_sc_btm_ldack)
      ack_wait_q              <= ack_wait;

  assign jtag_sc_btm_ldack    = state_cdr & (ir_dpapacc|ir_abort);
  assign jtag_sc_btm_shift    = state_sdr & (ir_dpapacc|ir_abort);

  assign jtag_sc_btm_next     = jtag_sc_btm_ldack ? ack
                              : jtag_sc_btm_shift ? ({jtag_sc_top[0], jtag_sc_btm[2:1]})
                              :                     jtag_sc_btm
                              ;

  assign jtag_sc_btm_load     = jtag_sc_btm_ldack
                              | jtag_sc_btm_shift
                              ;

  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      jtag_sc_btm             <= 3'b000;
    else if (jtag_sc_btm_load)
      jtag_sc_btm             <= jtag_sc_btm_next;

  assign tx_addr              = jtag_sc_btm[2:1];
  assign tx_write             = ~jtag_sc_btm[0];


  always @(posedge tck or negedge porst_n)
    if (!porst_n)
      ack_fault_q             <= 1'b0;
    else if (state_cdr)
      ack_fault_q             <= ack[1];

  assign stickyerr_clr        = state_udr & ack_fault_q;

  assign jtag_inst_load_next_id_ab = jtag_inst_load & jtag_inst_next_id_ab;

  assign prev_ap_id_ab_ndp_load = (state_udr & ir_dpapacc & ~ack_wait_q)
                                | (jtag_inst_load_next_id_ab)
                                ;

  assign prev_ap_id_ab_ndp_next = ir_apacc | (jtag_inst_load_next_id_ab);

  always @(posedge tck or negedge porst_n) begin
    if (!porst_n) begin
      prev_ap_id_ab_ndp <= 1'b0;
    end
    else if (prev_ap_id_ab_ndp_load) begin
      prev_ap_id_ab_ndp <= prev_ap_id_ab_ndp_next;
    end
  end


  assign perform_tx_ap = state_udr
                       & ir_apacc
                       & ~ack_wait_q
                       & ~reg_stky_err_i;


  always @*
    begin
      bus_state_next = bus_state;

      case (bus_state)
        BUS_ALIVE : begin
          bus_ack_ap       = bus_ack_int_i;
          bus_req_int      = bus_req_ap;
          if (!bus_req_ap && bus_ack_int_i & state_cdr) begin
            bus_state_next = BUS_BUSY;
            bus_req_int    = 1'b0;
          end
        end

        BUS_BUSY : begin
          bus_ack_ap  = 1'b0;
          bus_req_int = 1'b0;
          if (!bus_ack_int_i) begin
            bus_state_next = BUS_ALIVE;
            bus_req_int    = bus_req_ap;
            bus_ack_ap     = 1'b0;
          end
        end

        default : begin
          bus_state_next = 1'bx;
        end

      endcase
    end

  always @(posedge tck or negedge porst_n)
    if(!porst_n)
      bus_state       <= BUS_ALIVE;
    else
      bus_state       <= bus_state_next;

  assign bus_req_int_reject = bus_req_int & ~bus_pwr_int_i;
  assign bus_req_int_accept = bus_req_int &  bus_ack_int_i;

  assign bus_req_ap_next    = bus_req_int_reject           ? 1'b0
                            : bus_req_int_accept           ? 1'b0
                            : perform_tx_ap && !bus_req_ap ? 1'b1
                            : perform_tx_ap &&  bus_req_ap ? 1'b0
                            :                   bus_req_ap
                            ;

  always @(posedge tck or negedge porst_n)
    if(!porst_n)
      bus_req_ap       <= 1'b0;
    else
      bus_req_ap       <= bus_req_ap_next;

  always @(posedge tck or negedge porst_n)
    if(!porst_n)
      bus_req_ap_q     <= 1'b0;
    else
      bus_req_ap_q     <= bus_req_ap;

  assign bus_load_int  = bus_req_ap & ~bus_req_ap_q;

  assign bus_addr      = tx_addr;
  assign bus_write     = tx_write;
  assign bus_wdata     = jtag_sc_top[31:0];

  assign reg_orun_next = state_cdr & ir_dpapacc & (ack[1] | ack[0]);

  always @(posedge tck or negedge porst_n)
    if(!porst_n)
      reg_orun <= 1'b0;
    else
      reg_orun <= reg_orun_next;


  assign perform_tx_wr_dp = state_udr
                          & ir_dpacc
                          & tx_write
                          & ~ack_wait_q
                          & (reg_addr != 2'b00)
                          ;

  assign perform_tx_rd_dp = state_cdr &
                            ir_dpapacc &
                            ~prev_ap_id_ab_ndp &
                            (~tx_write);

  assign perform_dp_abort = state_udr  &
                            ir_abort;


  assign reg_sel = perform_tx_wr_dp | perform_tx_rd_dp | perform_dp_abort;

  assign reg_addr  = perform_dp_abort ? 2'b00 : tx_addr;
  assign reg_write = perform_dp_abort ? 1'b1  : tx_write;
  assign reg_wdata = jtag_sc_top[31:0];


endmodule
