//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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
//   Sub-module of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti_ti #( parameter
  NUM_EVENT_SLAVES  = 1,
  NUM_EVENT_MASTERS = 1,
  SW_HANDSHAKE      = 32'h0000_0000,
  EVENT_IN_LEVEL    = 32'h0000_0000
)
(
  input  wire                          clk,
  input  wire                          reset_n,
  input  wire                          cti_en,
  input  wire [NUM_EVENT_MASTERS-1:0]  cti_int_ack,
  input  wire [NUM_EVENT_MASTERS-1:0]  todbgensel,
  input  wire [NUM_EVENT_SLAVES-1:0]   tinidensel,
  input  wire [NUM_EVENT_SLAVES-1:0]   ctitrigin,
  output wire [NUM_EVENT_SLAVES-1:0]   map_trig_in,
  output wire [NUM_EVENT_SLAVES-1:0]   trig_in_status,
  output wire [NUM_EVENT_MASTERS-1:0]  ctitrigout,
  input  wire [NUM_EVENT_MASTERS-1:0]  map_trig_out,
  output wire [NUM_EVENT_MASTERS-1:0]  trig_out_status,
  input  wire                          dbgen,
  input  wire                          niden,
  input  wire                          iten,
  input  wire [NUM_EVENT_MASTERS-1:0]  it_trig_out
);

  reg  [NUM_EVENT_MASTERS-1:0]   trigout_int_q;
  wire                           trigout_int_q_en;
  reg  [NUM_EVENT_MASTERS-1:0]   trigout_holder_q;
  wire [NUM_EVENT_MASTERS-1:0]   trigout_holder_q_en;

  wire                           dbgen_niden;
  wire [NUM_EVENT_SLAVES-1:0]    trigin_mask;
  wire [NUM_EVENT_SLAVES-1:0]    trigin_pulse;

  wire [NUM_EVENT_MASTERS-1:0]   trigout_mask;
  wire [NUM_EVENT_MASTERS-1:0]   trigout;
  wire [NUM_EVENT_MASTERS-1:0]   trigout_holder;
  wire [NUM_EVENT_MASTERS-1:0]   trigout_ctien;
  wire [NUM_EVENT_MASTERS-1:0]   trigout_ctien_int;


  genvar i;

  localparam [NUM_EVENT_SLAVES-1:0] L_EVENT_IN_LEVEL = EVENT_IN_LEVEL[NUM_EVENT_SLAVES-1:0];

  generate

  for (i=0; i<NUM_EVENT_SLAVES; i=i+1) begin: gen_input_logic
    if (L_EVENT_IN_LEVEL[i] == 1'b1) begin: gen_edgedet
      reg ctitrigin_q;

      always @(posedge clk or negedge reset_n)
        if (!reset_n)
          ctitrigin_q <= 1'b0;
        else
          ctitrigin_q <= ctitrigin[i];

      assign trigin_pulse[i] = ctitrigin[i] & ~ctitrigin_q;

    end
    else begin: gen_no_edgedet

      assign trigin_pulse[i] = ctitrigin[i];

    end
  end

  endgenerate

  assign dbgen_niden = niden | dbgen;


  assign trigin_mask = ( tinidensel | (~tinidensel & {NUM_EVENT_SLAVES{dbgen_niden}}) );

  assign map_trig_in = trigin_pulse & trigin_mask;

  assign trig_in_status = map_trig_in;


  assign trigout_mask = ( todbgensel | (~todbgensel & {NUM_EVENT_MASTERS{dbgen}}) );

  generate

  for (i = 0; i < NUM_EVENT_MASTERS; i=i+1)
  begin : gen_sw_handshake

    if ( SW_HANDSHAKE[i] == 1'b1 )
    begin : sw_handshake_enabled

      assign trigout[i] = (trigout_mask[i] & map_trig_out[i]) | trigout_holder_q[i];

      assign trigout_holder[i] = trigout[i] & (~cti_int_ack[i]);
      assign trigout_holder_q_en[i] = trigout_holder_q[i] ^ trigout_holder[i];
      always @(posedge clk or negedge reset_n)
      begin : reg_trigout_holder
        if (!reset_n)
          trigout_holder_q[i] <= 1'b0;
        else if (trigout_holder_q_en[i])
          trigout_holder_q[i] <= trigout_holder[i];
      end

    end

    else
    begin : sw_handshake_disabled
      assign trigout[i] = trigout_mask[i] & map_trig_out[i];
    end

  end

  endgenerate

  assign trigout_ctien = {NUM_EVENT_MASTERS{cti_en}} & trigout;

  assign trigout_ctien_int = (iten == 1'b1) ? (it_trig_out & trigout_mask) : trigout_ctien;

  assign trigout_int_q_en = |(trigout_int_q ^ trigout_ctien_int);
  always @(posedge clk or negedge reset_n)
  begin : reg_trigout
    if (!reset_n)
      trigout_int_q <= {NUM_EVENT_MASTERS{1'b0}};
    else if (trigout_int_q_en)
      trigout_int_q <= trigout_ctien_int;
  end

  assign ctitrigout = trigout_int_q;

  assign trig_out_status = trigout_int_q;


endmodule

