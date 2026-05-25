//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53cti_mapper
#(
  parameter ECT_TR_WIDTH = 8,
  parameter ECT_CH_WIDTH = 4,
  parameter ECT_GATE_CHIN = 0
)
 (
  input                     clk_cti,
  input                     reset_n,

  input              [11:2] paddrdbg_i,
  input  [ECT_CH_WIDTH-1:0] pwdatadbg_i,
  input                     bus_read_i,
  input                     bus_write_unlocked_i,

  input                     glben_i,
  input  [ECT_CH_WIDTH-1:0] apptrigpulse_i,

  input  [ECT_TR_WIDTH-1:0] ctitrigin_rs_i,
  input  [ECT_CH_WIDTH-1:0] ctichin_gated_i,

  output                    map_rdata_valid_o,
  output             [31:0] map_rdata_o,
  output [ECT_TR_WIDTH-1:0] map_out_trig_o,
  output [ECT_CH_WIDTH-1:0] map_out_ch_o
);

  reg    [ECT_CH_WIDTH-1:0] ctiinen_r[ECT_TR_WIDTH-1:0];
  reg    [ECT_CH_WIDTH-1:0] ctiouten_r[ECT_TR_WIDTH-1:0];

  wire   [ECT_CH_WIDTH-1:0] ctiinen_nxt[ECT_TR_WIDTH-1:0];
  wire   [ECT_CH_WIDTH-1:0] ctiouten_nxt[ECT_TR_WIDTH-1:0];

  wire   [ECT_CH_WIDTH*ECT_TR_WIDTH-1:0] inouten_rd_data;

  wire   [ECT_TR_WIDTH-1:0] ctiinen_en;
  wire   [ECT_TR_WIDTH-1:0] ctiouten_en;

  wire   [ECT_TR_WIDTH-1:0] ctiinen_wren;
  wire   [ECT_TR_WIDTH-1:0] ctiouten_wren;

  wire   [ECT_TR_WIDTH-1:0] int_ch_map_out[ECT_CH_WIDTH-1:0];

  wire   [ECT_CH_WIDTH-1:0] in_map_ch_act;

  wire   [ECT_CH_WIDTH-1:0] map_in_ch;

  genvar                    i, j;


//------------------------------------------------------------------
// ctiinen and ctiouten registers
//       NOTE: inouten_rd_data is a large vector instead of array of
//             vectors so that the sensitivity for the reduction OR
//             function works as expected.
//------------------------------------------------------------------
  generate for (i = 0; i < ECT_TR_WIDTH; i = i+1) begin : CTIEN_REGS_GEN
    assign ctiinen_wren[i]  = bus_write_unlocked_i & ctiinen_en[i];
    assign ctiouten_wren[i] = bus_write_unlocked_i & ctiouten_en[i];

    assign ctiinen_nxt[i]   = pwdatadbg_i[ECT_CH_WIDTH-1:0];
    assign ctiouten_nxt[i]  = pwdatadbg_i[ECT_CH_WIDTH-1:0];

    always @(posedge clk_cti, negedge reset_n)
      if (~reset_n)
        ctiinen_r[i] <= {ECT_CH_WIDTH{1'b0}};
      else if (ctiinen_wren[i])
        ctiinen_r[i] <= ctiinen_nxt[i];

    always @(posedge clk_cti, negedge reset_n)
      if (~reset_n)
        ctiouten_r[i] <= {ECT_CH_WIDTH{1'b0}};
      else if (ctiouten_wren[i])
        ctiouten_r[i] <= ctiouten_nxt[i];
  end
  endgenerate


  generate for (i = 0; i < ECT_TR_WIDTH; i = i+1) begin : CTIEN_EN_GEN
    assign ctiinen_en[i]   = (paddrdbg_i[11:2] == 10'h008 + i[4:0]);
    assign ctiouten_en[i]  = (paddrdbg_i[11:2] == 10'h028 + i[4:0]);

    assign inouten_rd_data[(i+1)*ECT_CH_WIDTH-1 -: ECT_CH_WIDTH]  =
                                 ctiinen_r[i]  & {ECT_CH_WIDTH{ctiinen_en[i] }} |
                                 ctiouten_r[i] & {ECT_CH_WIDTH{ctiouten_en[i]}};
  end
  endgenerate


  function automatic [ECT_CH_WIDTH-1:0] map_reduction_or (
    input [ECT_CH_WIDTH*ECT_TR_WIDTH-1:0] rd_data
  );
    integer k;
    begin
      map_reduction_or  = {ECT_CH_WIDTH{1'b0}};
      for (k = 0; k < ECT_TR_WIDTH; k = k + 1)
        map_reduction_or  = map_reduction_or | rd_data[(k+1)*ECT_CH_WIDTH-1 -: ECT_CH_WIDTH];
    end
  endfunction // map_reduction_or

  assign map_rdata_o  = { {(32-ECT_CH_WIDTH){1'b0}} , map_reduction_or(inouten_rd_data) };

  assign map_rdata_valid_o  = (bus_read_i & |ctiinen_en ) |
                              (bus_read_i & |ctiouten_en);



//------------------------------------------------------------------
// Input mapping (trigger -> internal channel)
//       this function does the input trigger to (output) channel mapping,
//       including the gating with CTICONTROL.glben
//------------------------------------------------------------------
  generate for (i = 0; i < ECT_CH_WIDTH; i = i+1) begin : IN_MAP_CH_GEN
    for (j = 0; j < ECT_TR_WIDTH; j = j+1) begin : MAP_TR
      assign int_ch_map_out[i][j]  = ctitrigin_rs_i[j] & ctiinen_r[j][i];
    end
  end
  endgenerate

  generate for (i = 0; i < ECT_CH_WIDTH; i = i+1) begin : IN_MAP_CH_ACT_GEN
    assign in_map_ch_act[i]  = glben_i & |(int_ch_map_out[i]);
  end
  endgenerate



//------------------------------------------------------------------
// Output mapping (internal channel -> trigger)
//       this function does the (internal) channel to output trigger mapping,
//       including the gating with CTICONTROL.glben
//------------------------------------------------------------------
  generate for (i = 0; i < ECT_TR_WIDTH; i = i+1) begin : OUT_MAP_TRIG_ACT_GEN
    assign map_out_trig_o[i]  = glben_i & |(map_in_ch & ctiouten_r[i]);
  end
  endgenerate



//------------------------------------------------------------------
// Internal channels
//     - map_ch_out is the internal channel connecting input triggers and
//       software triggers (CTIAPPTRIG/CTIAPPPULSE).
//
//     - map_in_ch is the internal channel connecting the input channel(s)
//       and the other internal channel, int_ch_out, to the trigger outputs.
//------------------------------------------------------------------
  generate for (i = 0; i < ECT_CH_WIDTH; i = i+1) begin : CTI_INT_CH_GEN
    assign map_out_ch_o[i]  = apptrigpulse_i[i] | // int_ch_out is the CTIAPPTRIG (and CTIAPPPULSE) ...
                              in_map_ch_act[i]; // or'ed with the output of the tripper input to channel output mapping

    assign map_in_ch[i]     = map_out_ch_o[i] |   // int_ch_in is the int_ch_out ...
                              ctichin_gated_i[i]; // or'ed with the channel input
  end // block: CTI_INT_CH
  endgenerate



`ifdef ARM_ASSERT_ON

  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------
  `include "std_ovl_defines.h"

  assert_zero_one_hot
     #(.severity_level(`OVL_FATAL), .property_type(`OVL_ASSERT), .width(2*ECT_TR_WIDTH),
       .msg("more than one bit of ctiinen_en and ctiouten_en set"))
   u_ovl_inouten_en_one_hot
     (.clk(clk_cti), .reset_n(reset_n),
      .test_expr({ctiinen_en, ctiouten_en} & {(2*ECT_TR_WIDTH){bus_read_i | bus_write_unlocked_i }} ));


  assert_zero_one_hot
     #(.severity_level(`OVL_FATAL), .property_type(`OVL_ASSERT), .width(2*ECT_TR_WIDTH),
       .msg("more than one bit of ctiinen_wren and ctiouten_wren set"))
   u_ovl_inouten_wren_one_hot
     (.clk(clk_cti), .reset_n(reset_n),
      .test_expr({ctiinen_wren, ctiouten_wren}));

`endif //  `ifdef ARM_ASSERT_ON


endmodule // ca53cti_mapper

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
