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

module ca53cti_ti
#(
  parameter ECT_TR_WIDTH = 8,
  parameter ECT_CH_WIDTH = 4,
  parameter ECT_GATE_CHIN = 0,
  parameter TIHSBYPASS = {ECT_TR_WIDTH{1'b0}},
  parameter INTRIG_USED  = {ECT_TR_WIDTH{1'b1}},
  parameter OUTTRIG_USED = {ECT_TR_WIDTH{1'b1}}
)
 (
  input                         clk_cti,
  input                         reset_n,

  input      [ECT_TR_WIDTH-1:0] ctitrigin_i,
  input      [ECT_TR_WIDTH-1:0] ctitrigoutack_i,

  input      [ECT_TR_WIDTH-1:0] intack_i,

  input      [ECT_TR_WIDTH-1:0] map_out_trig_i,

  output     [ECT_TR_WIDTH-1:0] ctitrigin_rs_o,
  output                        ctitrigout_act_o,

  output     [ECT_TR_WIDTH-1:0] ctitriginstatus_o,
  output     [ECT_TR_WIDTH-1:0] ctitrigoutstatus_o,

  output     [ECT_TR_WIDTH-1:0] ctitrigout_o
);

  wire       [ECT_TR_WIDTH-1:0] ctitrigin_rs;
  wire       [ECT_TR_WIDTH-1:0] ctitrigout_rs;
  wire       [ECT_TR_WIDTH-1:0] ctitrigout_ret_rs;

  reg        [ECT_TR_WIDTH-1:0] ctitrigin_r;
  reg        [ECT_TR_WIDTH-1:0] ctitrigout_r;

  wire       [ECT_TR_WIDTH-1:0] ctitrigout_nxt;

  reg        [ECT_TR_WIDTH-1:0] ctitrigout_ret_r;
  reg        [ECT_TR_WIDTH-1:0] ctitrigout_clr_r;

  wire       [ECT_TR_WIDTH-1:0] ctitrigout_ret_nxt;
  wire       [ECT_TR_WIDTH-1:0] ctitrigout_clr_nxt;


  genvar                    i;


//------------------------------------------------------------------
// Trigger output activity signal
//       Used by the clock gating logic to keep clock enabled until
//       all trigger outputs are cleared.
//------------------------------------------------------------------
  assign ctitrigout_act_o  = |ctitrigout_ret_rs;



//------------------------------------------------------------------
// Trigger status signals
//       pass-through.
//------------------------------------------------------------------
  assign ctitriginstatus_o   = ctitrigin_rs;
  assign ctitrigoutstatus_o  = ctitrigout_rs;



//------------------------------------------------------------------
// Input trigger interface
//
//------------------------------------------------------------------
  assign ctitrigin_rs_o  = ctitrigin_rs;

  generate for (i = 0; i < ECT_TR_WIDTH; i = i+1) begin : CTI_TR_IN
    if (INTRIG_USED[i]) begin : IN_TRIG_USED

      assign ctitrigin_rs[i]  = ctitrigin_r[i];

      always @(posedge clk_cti, negedge reset_n)
        if (~reset_n)
          ctitrigin_r[i] <= 1'b0;
        else
          ctitrigin_r[i] <= ctitrigin_i[i];

    end else begin : IN_TRIG_UNUSED

      assign ctitrigin_rs[i]  = 1'b0;

    end
  end
  endgenerate



//------------------------------------------------------------------
// Output trigger interface
//       The output trigger interface connects up the internal channel to
//       the output trigger, and also includes retention and ACK'ing logic,
//       and additional retention for software ACK to be held until the
//       internal channel is deasserted.
//------------------------------------------------------------------
  assign ctitrigout_o      = ctitrigout_rs;

  generate for (i = 0; i < ECT_TR_WIDTH; i = i+1) begin : CTI_TR_OUT
    if (TIHSBYPASS[i] || !OUTTRIG_USED[i]) begin : HS_BYPASS

      assign ctitrigout_nxt[i]  = map_out_trig_i[i];
      assign ctitrigout_ret_rs[i]  = 1'b0;

    end else begin : NO_HS_BYPASS

      assign ctitrigout_ret_nxt[i]   =  ctitrigout_nxt[i]     & // Retain next output value ...
                                       ~ctitrigoutack_i[i]    & // unless the ACK has been asserted
                                       ~intack_i[i]           & // or it has been ACK'ed by software
                                       ~ctitrigout_clr_r[i];    // or it has been ACK'ed by software earlier

      // Retention register (for ACK'ing logic)
      always @(posedge clk_cti, negedge reset_n)
        if (~reset_n)
          ctitrigout_ret_r[i] <= 1'b0;
        else
          ctitrigout_ret_r[i] <= ctitrigout_ret_nxt[i];


      assign ctitrigout_clr_nxt[i] =   map_out_trig_i[i] &    // save the software clear if map output still enabled
                                      ( ctitrigout_clr_r[i] | // and currently holding a clear from a previous cycle ...
                                        intack_i[i]);         // or a new software ACK (clear) is being asserted

      // Retention register (for software clear/INTACK)
      // - effectively holds intack while there is activity on the internal channel
      always @(posedge clk_cti, negedge reset_n)
        if (~reset_n)
          ctitrigout_clr_r[i] <= 1'b0;
        else
          ctitrigout_clr_r[i] <= ctitrigout_clr_nxt[i];


      assign ctitrigout_nxt[i]  = ctitrigout_ret_r[i] | // In normal mode, or retention register ...
                                  map_out_trig_i[i];      // with mapped output trigger

      assign ctitrigout_ret_rs[i]  = ctitrigout_ret_r[i];

    end // block: NO_HS_BYPASS


    if (OUTTRIG_USED[i]) begin : OUT_TRIG_USED

      assign ctitrigout_rs[i]  = ctitrigout_r[i];

      always @(posedge clk_cti, negedge reset_n)
        if (~reset_n)
          ctitrigout_r[i] <= 1'b0;
        else
          ctitrigout_r[i] <= ctitrigout_nxt[i];

    end else begin : OUT_TRIG_UNUSED

      assign ctitrigout_rs[i]  = 1'b0;

    end

  end // block: CTI_TR_OUT
  endgenerate

endmodule // ca53cti_ti

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
