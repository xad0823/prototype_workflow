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


module css600_dpslv_watcher
  #(parameter JTAG_DP = 1,
    parameter SW_DP = 1,
    parameter SYNC_DEPTH = 2,
    parameter JTAGDP_IRLEN = 4)

  (
  input  wire        swclktck,
  input  wire        porst_n,
  input  wire        ntrst,

  input  wire        swditms_i,

  input  wire  [3:0] jtagstate_i,
  input  wire        linereset_i,

  output wire        jtagactive_o,
  output wire        swactive_o,
  output wire        swactive_rise_o,
  output wire        dormantstate_o,

  output wire        safetms_q_o,
  output wire        tlr_reset_req_o,
  output wire        protocol_err_req_o

  );


   `include "css600_dpslv_watcher_localparams.v"
   `include "css600_dpslv_jtag_localparams.v"


  wire jt_present;
  wire sw_present;

  wire safe_swdi;
  reg  safe_swdi_q;
  wire swdi_sync;

  wire protocol_err_req;
  wire tlr_reset_req;

  wire [9:0] swj_st_nxt_lfsr;
  wire [5:0] count_inc;
  wire [9:0] swj_st_nxt_step;
  wire       swj_st_step_jtag;
  wire [9:0] swj_st_nxt_jtag;
  reg        swj_st_step_sw;
  reg  [9:0] swj_st_nxt_sw;
  reg        swj_st_step_dorm;
  reg  [9:0] swj_st_nxt_dorm;
  reg        swj_st_step_mux;
  reg  [9:0] swj_st_nxt_mux;
  wire [9:0] swj_st_nxt_main;
  wire [9:0] swj_st_nxt;
  wire [9:0] swj_st;

  wire       zbs_detect;
  reg        opt_zbs_detect;
  reg  [3:0] zbs_st_nxt;
  reg  [3:0] zbs_st;

  wire       jtagsel;
  wire       swsel;
  wire       swactive_rise;
  wire       lfsrsel;
  wire       dormantsel;

  assign jtagactive_o          = jtagsel;
  assign swactive_o            = swsel;
  assign swactive_rise_o       = swactive_rise;
  assign dormantstate_o        = dormantsel;
  assign safetms_q_o           = safe_swdi_q;
  assign tlr_reset_req_o       = tlr_reset_req;
  assign protocol_err_req_o    = protocol_err_req;


  assign jt_present = (JTAG_DP == 1);
  assign sw_present = (SW_DP   == 1);

  localparam [9:0] SWJ_ST_RST = (JTAG_DP == 1) ? SWJ_ST_JTAG_SEL : SWJ_ST_DLFSR_WAIT;


  css600_or
    u_safe_swditms
      (.in_a  (swditms_i),
       .in_b  (lfsrsel),
       .out_y (safe_swdi)
      );


  css600_cdc_capt_sync_high
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
    u_css600_cdc_capt_sync_swditms(
    .clk       (swclktck),
    .reset_n   (porst_n),
    .d_async_i (swditms_i),
    .q_sync_o  (swdi_sync)
  );

  always @(posedge swclktck or negedge porst_n)
      if (!porst_n)
        safe_swdi_q <= 1'b1;
      else
        safe_swdi_q <= safe_swdi;


  assign swj_st_nxt_lfsr = ((swdi_sync == swj_st[0])
                            ? (
                               ((swj_st == SWJ_ST_DLFSR_WAIT)
                                ? SWJ_ST_DLFSR_START
                                : ((swj_st == SWJ_ST_DLFSR_END)
                                   ? ((SYNC_DEPTH == 3)
                                       ? SWJ_ST_ALRT1 :
                                         SWJ_ST_ALRT0
                                      )
                                   : {3'b001,
                                      swj_st[6] ^ swj_st[3] ^ swj_st[1] ^ swj_st[0],
                                      swj_st[6:1]}
                                   )
                                )
                               )
                            : (
                               SWJ_ST_DLFSR_WAIT
                               )
                            );


  assign tlr_reset_req = jt_present & ((swj_st == SWJ_ST_DZEBX1));

  assign protocol_err_req = sw_present &
                           ((swj_st == SWJ_ST_STOD13) & safe_swdi_q);


  assign count_inc =  swj_st[5:0] + 6'b000001;
  assign swj_st_nxt_step = {swj_st[9:6], count_inc[5:0]};


   assign swj_st_step_jtag = 1'b0;
   assign swj_st_nxt_jtag  = SWJ_ST_JTAG_SEL;


  generate
    if(SW_DP == 1) begin : gen_sw_switch

      always@* begin
        case(swj_st[4:0])


          SWJ_ST_SW_SYNC[4:0] : begin
                                  swj_st_step_sw = 1'b1;
                                  swj_st_nxt_sw  = {10{1'b0}};
                                end
          SWJ_ST_SW_SEL[4:0] : begin
                                  swj_st_step_sw = linereset_i & ~safe_swdi_q;
                                  swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD0[4:0] : begin
                                 swj_st_step_sw = ~safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD1[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD2[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD3[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD4[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD5[4:0] : begin
                                 swj_st_step_sw = ~safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD6[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD7[4:0]  : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD8[4:0]  : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD9[4:0]  : begin
                                 swj_st_step_sw = ~safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD10[4:0] : begin
                                 swj_st_step_sw = ~safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD11[4:0] : begin
                                 swj_st_step_sw = ~safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD12[4:0] : begin
                                 swj_st_step_sw = safe_swdi_q;
                                 swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                               end
          SWJ_ST_STOD13[4:0] : begin
                                 swj_st_step_sw = 1'b0;
                                 swj_st_nxt_sw  = safe_swdi_q && safe_swdi ? SWJ_ST_DORM_SYNC0 :
                                                                             SWJ_ST_SW_SYNC;
                               end

          SWJ_ST_UNUSED31[4:0],
          SWJ_ST_UNUSED32[4:0],
          SWJ_ST_UNUSED33[4:0],
          SWJ_ST_UNUSED34[4:0],
          SWJ_ST_UNUSED35[4:0],
          SWJ_ST_UNUSED36[4:0],
          SWJ_ST_UNUSED37[4:0],
          SWJ_ST_UNUSED38[4:0],
          SWJ_ST_UNUSED39[4:0],
          SWJ_ST_UNUSED40[4:0],
          SWJ_ST_UNUSED41[4:0],
          SWJ_ST_UNUSED42[4:0],
          SWJ_ST_UNUSED43[4:0],
          SWJ_ST_UNUSED44[4:0],
          SWJ_ST_UNUSED45[4:0],
          SWJ_ST_UNUSED46[4:0] : begin
                                   swj_st_step_sw = 1'b0;
                                   swj_st_nxt_sw  = SWJ_ST_SW_SEL;
                                 end

          default : begin
                      swj_st_step_sw = 1'bx;
                      swj_st_nxt_sw  = {10{1'bx}};
                    end

        endcase
      end

    end else begin : remove_sw_switch
      always@* begin
        swj_st_step_sw =     1'b0;
        swj_st_nxt_sw  = {10{1'b0}};
      end
    end
  endgenerate


  always@* begin
    case(swj_st[5:0])


      SWJ_ST_DORM_SYNC0[5:0] : begin
                                 swj_st_step_dorm = jt_present;
                                 swj_st_nxt_dorm = SWJ_ST_DLFSR_WAIT;
                               end
      SWJ_ST_DORM_SYNC1[5:0] : begin
                                 swj_st_step_dorm = (SYNC_DEPTH == 3);
                                 swj_st_nxt_dorm  = SWJ_ST_DLFSR_WAIT;
                               end

      SWJ_ST_DORM_SYNC2[5:0] : begin
                                 swj_st_step_dorm = 1'b0;
                                 swj_st_nxt_dorm  = SWJ_ST_DLFSR_WAIT;
                               end


      SWJ_ST_ALRT0[5:0],
      SWJ_ST_ALRT1[5:0],
      SWJ_ST_ALRT2[5:0] : begin
                            swj_st_step_dorm = 1'b1;
                            swj_st_nxt_dorm  = {10{1'b0}};
                          end


      SWJ_ST_ACT0[5:0] : begin
                           swj_st_step_dorm = ~safe_swdi_q;
                           swj_st_nxt_dorm  = SWJ_ST_DORM_SYNC1;
                         end
      SWJ_ST_ACT1[5:0] : begin
                           swj_st_step_dorm = safe_swdi_q;
                           swj_st_nxt_dorm  = jt_present ? SWJ_ST_ACT2_Z :
                                                           SWJ_ST_DLFSR_WAIT;
                         end

      SWJ_ST_ACT2_JS[5:0] : begin
                              swj_st_step_dorm = ~safe_swdi_q;
                              swj_st_nxt_dorm  = SWJ_ST_DORM_SYNC1;
                            end
      SWJ_ST_ACT3_JS[5:0] : begin
                              swj_st_step_dorm = safe_swdi_q;
                              swj_st_nxt_dorm  = SWJ_ST_DORM_SYNC1;
                            end
      SWJ_ST_ACT4_JS[5:0] : begin
                              swj_st_step_dorm = 1'b0;
                              swj_st_nxt_dorm  = jt_present && ~safe_swdi_q ? SWJ_ST_ACT5_J :
                                                 sw_present &&  safe_swdi_q ? SWJ_ST_ACT5_S :
                                                                              SWJ_ST_DLFSR_WAIT;
                            end

      SWJ_ST_ACT5_J[5:0] : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DORM_SYNC1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT6_J[5:0] : begin
                             swj_st_step_dorm = 1'b0;
                             swj_st_nxt_dorm = !jt_present               ? SWJ_ST_DLFSR_WAIT   :
                                               !safe_swdi_q && !safe_swdi ? SWJ_ST_JTAG_SEL :
                                                                           SWJ_ST_DORM_SYNC0;
                           end


      SWJ_ST_ACT5_S[5:0] : begin
                             swj_st_step_dorm = sw_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = sw_present ? SWJ_ST_DORM_SYNC1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT6_S[5:0] : begin
                             swj_st_step_dorm = 1'b0;
                             swj_st_nxt_dorm  = !sw_present                ? SWJ_ST_DLFSR_WAIT :
                                                !safe_swdi_q && !safe_swdi ? SWJ_ST_SW_SYNC :
                                                                             SWJ_ST_DORM_SYNC0;
                           end

      SWJ_ST_ACT2_Z[5:0] : begin
                             swj_st_step_dorm = jt_present;
                             swj_st_nxt_dorm  = SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT3_Z[5:0] : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DORM_SYNC1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT4_Z[5:0] : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DORM_SYNC1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT5_Z[5:0] : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DORM_SYNC1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT6_Z[5:0] : begin
                             swj_st_step_dorm = jt_present;
                             swj_st_nxt_dorm  = SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT7_Z[5:0] : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DSKIP0 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_ACT8_Z[5:0] : begin
                             swj_st_step_dorm = 1'b0;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DZEB :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_DSKIP0[5:0],
      SWJ_ST_DSKIP1[5:0],
      SWJ_ST_DSKIP2[5:0],
      SWJ_ST_DSKIP3[5:0],
      SWJ_ST_DSKIP4[5:0],
      SWJ_ST_DSKIP5[5:0],
      SWJ_ST_DSKIP6[5:0],
      SWJ_ST_DSKIP7[5:0],
      SWJ_ST_DSKIP8[5:0],
      SWJ_ST_DSKIP9[5:0],
      SWJ_ST_DSKIP10[5:0],
      SWJ_ST_DSKIP11[5:0],
      SWJ_ST_DSKIP12[5:0],
      SWJ_ST_DSKIP13[5:0],
      SWJ_ST_DSKIP14[5:0],
      SWJ_ST_DSKIP15[5:0],
      SWJ_ST_DSKIP16[5:0],
      SWJ_ST_DSKIP17[5:0],
      SWJ_ST_DSKIP18[5:0],
      SWJ_ST_DSKIP19[5:0],
      SWJ_ST_DSKIP20[5:0],
      SWJ_ST_DSKIP21[5:0],
      SWJ_ST_DSKIP22[5:0],
      SWJ_ST_DSKIP23[5:0],
      SWJ_ST_DSKIP24[5:0] : begin
                              swj_st_step_dorm = jt_present;
                              swj_st_nxt_dorm  = SWJ_ST_DLFSR_WAIT;
                            end
      SWJ_ST_DZEB[5:0]   : begin
                             swj_st_step_dorm = jt_present & ~safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DZEB1 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_DZEB0[5:0]  : begin
                             swj_st_step_dorm = jt_present & safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_JTAG_SEL :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_DZEB1[5:0]  : begin
                             swj_st_step_dorm = jt_present & safe_swdi_q;
                             swj_st_nxt_dorm  = jt_present ? SWJ_ST_DZEB0 :
                                                             SWJ_ST_DLFSR_WAIT;
                           end
      SWJ_ST_DZEBX1[5:0] : begin
                             swj_st_step_dorm = 1'b0;
                             swj_st_nxt_dorm = jt_present ? SWJ_ST_DORM_SYNC1 :
                                                            SWJ_ST_DLFSR_WAIT;
                           end

      SWJ_ST_UNUSED47[5:0],
      SWJ_ST_UNUSED48[5:0],
      SWJ_ST_UNUSED49[5:0],
      SWJ_ST_UNUSED50[5:0],
      SWJ_ST_UNUSED51[5:0],
      SWJ_ST_UNUSED52[5:0],
      SWJ_ST_UNUSED53[5:0],
      SWJ_ST_UNUSED54[5:0],
      SWJ_ST_UNUSED55[5:0],
      SWJ_ST_UNUSED56[5:0],
      SWJ_ST_UNUSED57[5:0],
      SWJ_ST_UNUSED58[5:0],
      SWJ_ST_UNUSED59[5:0] : begin
                               swj_st_step_dorm = 1'b0;
                               swj_st_nxt_dorm  = jt_present ? SWJ_ST_JTAG_SEL :
                                                               SWJ_ST_DLFSR_WAIT;
                             end

      default : begin
                  swj_st_step_dorm = 1'bx;
                  swj_st_nxt_dorm  = {10{1'bx}};
                end

    endcase
  end


  always@*
    case(swj_st[9:7])
      3'b000: begin
                swj_st_step_mux = swj_st_step_dorm;
                swj_st_nxt_mux  = swj_st_nxt_dorm;
              end
      3'b100: begin
                swj_st_step_mux = swj_st_step_jtag;
                swj_st_nxt_mux  = swj_st_nxt_jtag;
              end
      3'b010: begin
                swj_st_step_mux = swj_st_step_sw;
                swj_st_nxt_mux  = swj_st_nxt_sw;
              end
      3'b001: begin
                swj_st_step_mux = 1'b0;
                swj_st_nxt_mux  = swj_st_nxt_lfsr;
              end

      3'b011,
      3'b101,
      3'b110,
      3'b111: begin
                swj_st_step_mux = 1'b0;
                swj_st_nxt_mux  = SWJ_ST_RST;
              end

      default: begin
                 swj_st_step_mux = 1'bx;
                 swj_st_nxt_mux  = {10{1'bx}};
               end
    endcase

  assign swj_st_nxt_main = swj_st_step_mux ? swj_st_nxt_step : swj_st_nxt_mux;

  assign swj_st_nxt = !zbs_detect ? swj_st_nxt_main : SWJ_ST_DORM_SYNC0;

  generate
    if ((JTAG_DP == 1) && (SW_DP == 1)) begin : gen_swj_st_a

      reg [9:0] swj_st_reg;

      always @(posedge swclktck or negedge porst_n)
        if (!porst_n)
          swj_st_reg[9:0] <= SWJ_ST_RST;
        else
          swj_st_reg[9:0] <= swj_st_nxt[9:0];

      wire swj_st_9 = jt_present & swj_st_reg[9];
      wire swj_st_8 = sw_present & swj_st_reg[8];

      assign swj_st = {swj_st_9,swj_st_8,swj_st_reg[7:0]};
      assign swactive_rise = sw_present & swj_st_nxt[8] & ~swj_st_reg[8];

    end else if ((JTAG_DP == 1) && (SW_DP == 0)) begin : gen_swj_st_b

      reg [8:0] swj_st_reg;

      always @(posedge swclktck or negedge porst_n)
        if (!porst_n) begin
          swj_st_reg[8] <= SWJ_ST_RST[9];
          swj_st_reg[7:0] <= SWJ_ST_RST[7:0];
        end
        else
          swj_st_reg[8:0] <= {swj_st_nxt[9],swj_st_nxt[7:0]};

      assign swj_st = {swj_st_reg[8],1'b0,swj_st_reg[7:0]};
      assign swactive_rise = 1'b0;

    end else if ((JTAG_DP == 0) && (SW_DP == 1)) begin : gen_swj_st_c

      reg [8:0] swj_st_reg;

      always @(posedge swclktck or negedge porst_n)
        if (!porst_n)
          swj_st_reg[8:0] <= SWJ_ST_RST[8:0];
        else
          swj_st_reg[8:0] <= swj_st_nxt[8:0];

      assign swj_st = {1'b0,swj_st_reg[8:0]};
      assign swactive_rise = sw_present & swj_st_nxt[8] & ~swj_st_reg[8];

    end
  endgenerate


  generate
    if(JTAG_DP == 1) begin : gen_zbs_switch

      always@*
        case(zbs_st)
          ZBS_WAIT  : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_CDR) ? ZBS0 :
                                                                 ZBS_WAIT;
                      end
          ZBS0      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_WAIT :
                                     (jtagstate_i == JTAG_CDR) ? ZBS1     :
                                                                 ZBS0;
                      end
          ZBS1      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCKN :
                                     (jtagstate_i == JTAG_CDR) ? ZBS2      :
                                                                 ZBS1;
                      end
          ZBS2      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCKN :
                                     (jtagstate_i == JTAG_CDR) ? ZBS3      :
                                                                 ZBS2;
                      end
          ZBS3      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCKN :
                                     (jtagstate_i == JTAG_CDR) ? ZBS4      :
                                                                 ZBS3;
                      end
          ZBS4      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCKN :
                                     (jtagstate_i == JTAG_CDR) ? ZBS5      :
                                                                 ZBS4;
                      end
          ZBS5      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCKN :
                                     (jtagstate_i == JTAG_CDR) ? ZBS6      :
                                                                 ZBS5;
                      end
          ZBS6      : begin
                        opt_zbs_detect = 1'b0;
                        zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                     (jtagstate_i == JTAG_SDR) ? ZBS_LOCK6 :
                                     (jtagstate_i == JTAG_CDR) ? ZBS_LOCKN :
                                                                 ZBS6;
                      end
          ZBS_LOCKN : begin
                       opt_zbs_detect = 1'b0;
                       zbs_st_nxt = (jtagstate_i == JTAG_TLR) ? ZBS_WAIT :
                                    (jtagstate_i == JTAG_SIS) ? ZBS_WAIT :
                                                                ZBS_LOCKN;
                      end
          ZBS_LOCK6 : begin
                       opt_zbs_detect = ~safe_swdi & ((jtagstate_i == JTAG_UDR) |
                                                  (jtagstate_i == JTAG_UIR));

                       zbs_st_nxt = opt_zbs_detect           ? ZBS_WAIT :
                                   (jtagstate_i == JTAG_SIS) ? ZBS_WAIT  :
                                   (jtagstate_i == JTAG_RTI) ? ZBS_WAIT  :
                                                               ZBS_LOCK6;
                      end


          ZBS_UNUSED0,
          ZBS_UNUSED1,
          ZBS_UNUSED2,
          ZBS_UNUSED3,
          ZBS_UNUSED4 : begin
                          opt_zbs_detect = 1'b0;
                          zbs_st_nxt     = ZBS_WAIT;
                        end

          default   : begin
                        opt_zbs_detect = 1'bx;
                        zbs_st_nxt     = {4{1'bx}};
                      end

        endcase

      assign zbs_detect = jt_present & opt_zbs_detect;


      always @(posedge swclktck or negedge ntrst)
        if (!ntrst)
          zbs_st <= ZBS_WAIT;
        else if (jtagsel)
          zbs_st <= zbs_st_nxt;


    end else begin : remove_zbs_switch

      assign zbs_detect = 1'b0;


    end
  endgenerate


  assign jtagsel = swj_st[9];
  assign swsel   = swj_st[8];
  assign lfsrsel = swj_st[7];
  assign dormantsel = (!jtagsel) && (!swsel);


endmodule

