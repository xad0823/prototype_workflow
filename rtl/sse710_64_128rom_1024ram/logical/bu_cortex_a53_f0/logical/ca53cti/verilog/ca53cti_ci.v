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

module ca53cti_ci
#(
  parameter ECT_TR_WIDTH = 8,
  parameter ECT_CH_WIDTH = 4,
  parameter ECT_GATE_CHIN = 0
)
 (
  input                         clk_cti,
  input                         reset_n,

  input      [ECT_CH_WIDTH-1:0] ctichin_i,

  input      [ECT_CH_WIDTH-1:0] ctigate_i,
  input                         glben_i,

  input      [ECT_CH_WIDTH-1:0] map_out_ch_i,

  output     [ECT_CH_WIDTH-1:0] ctichinstatus_o,
  output     [ECT_CH_WIDTH-1:0] ctichoutstatus_o,

  output     [ECT_CH_WIDTH-1:0] ctichin_gated_o,
  output     [ECT_CH_WIDTH-1:0] ctichout_o
);


  reg        [ECT_CH_WIDTH-1:0] ctichin_r;
  reg        [ECT_CH_WIDTH-1:0] ctichout_r;

  wire       [ECT_CH_WIDTH-1:0] ctichout_nxt;


  genvar                    i;


//------------------------------------------------------------------
// Channel status signals
//       pass-through.
//------------------------------------------------------------------
  assign ctichinstatus_o   = ctichin_r;
  assign ctichoutstatus_o  = ctichout_r;



//------------------------------------------------------------------
// Input channel interface
//       Optional ctigate gating
//------------------------------------------------------------------
  generate if (ECT_GATE_CHIN) begin : CTICHIN_GATE_GEN
    assign ctichin_gated_o = ctichin_r & ctigate_i;
  end else begin : CTICHIN_GATE_GEN_ELSE
    assign ctichin_gated_o = ctichin_r;
  end
  endgenerate

  always @(posedge clk_cti, negedge reset_n)
    if (~reset_n)
      ctichin_r <= {ECT_CH_WIDTH{1'b0}};
    else
      ctichin_r <= ctichin_i;


//------------------------------------------------------------------
// Output channel interface
//       The output channel interface connects up the internal channel to
//       the output channel, and also includes retention and ACK'ing logic.
//------------------------------------------------------------------
  assign ctichout_o  = ctichout_r;

  generate for (i = 0; i < ECT_CH_WIDTH; i = i+1) begin : CTI_CH_OUT
    assign ctichout_nxt[i]  = glben_i & ctigate_i[i] & map_out_ch_i[i];

    always @(posedge clk_cti, negedge reset_n)
      if (~reset_n)
        ctichout_r[i] <= 1'b0;
      else
        ctichout_r[i] <= ctichout_nxt[i];
  end
  endgenerate

endmodule // ca53cti_ci

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
