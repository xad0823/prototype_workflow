//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
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


module css600_cti_mapper
#(
  parameter NUM_EVENT_SLAVES  = 1,
  parameter NUM_EVENT_MASTERS = 1,
  parameter CHANNEL_WIDTH     = 4
)(
  input  wire [CHANNEL_WIDTH*NUM_EVENT_SLAVES-1:0]  trig_in_en,
  input  wire [CHANNEL_WIDTH*NUM_EVENT_MASTERS-1:0] trig_out_en,
  input  wire [CHANNEL_WIDTH-1:0]                   app_trigger,
  input  wire [NUM_EVENT_SLAVES-1:0]                map_trig_in,
  output wire [NUM_EVENT_MASTERS-1:0]               map_trig_out,
  input  wire [CHANNEL_WIDTH-1:0]                   map_ch_in,
  output wire [CHANNEL_WIDTH-1:0]                   map_ch_out
);

  wire [CHANNEL_WIDTH-1:0]    int_ch_out;
  wire [CHANNEL_WIDTH-1:0]    int_ch_in;


  assign  int_ch_in  = (map_ch_out | map_ch_in);

  assign  map_ch_out = (int_ch_out | app_trigger);

  genvar i,j;
  generate

    for (i = 0; i < CHANNEL_WIDTH; i=i+1)
    begin : gen_chout_map

      wire [NUM_EVENT_SLAVES-1:0] int_trigin_en;

      for (j = 0; j < NUM_EVENT_SLAVES; j=j+1)
      begin : gen_trigin
        assign int_trigin_en[j] = map_trig_in[j] & trig_in_en[CHANNEL_WIDTH*j+i];
      end

      assign int_ch_out[i] = |int_trigin_en;

    end

  endgenerate

  generate

    for (i = 0; i < NUM_EVENT_MASTERS; i=i+1)
    begin : gen_trigout_map

      wire [CHANNEL_WIDTH-1:0]    int_chin_en;

      for (j = 0; j < CHANNEL_WIDTH; j=j+1)
      begin : gen_chin
        assign int_chin_en[j] = int_ch_in[j] & trig_out_en[CHANNEL_WIDTH*i+j];
      end

      assign map_trig_out[i] = |int_chin_en;

    end

  endgenerate


endmodule

