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
//   Top level of css600_ctm
//
//----------------------------------------------------------------------------


module css600_ctm #(parameter
  NUM_INTERFACES = 2
  )
  (
  clk,
  reset_n,
  channel_in,
  channel_out
  );

  localparam L_NUM_INTF = (NUM_INTERFACES >=2) && (NUM_INTERFACES <=33)
                          ? NUM_INTERFACES
                          : 2;

  input wire                     clk;
  input wire                     reset_n;
  input wire [L_NUM_INTF*4-1:0]  channel_in;
  output reg  [L_NUM_INTF*4-1:0] channel_out;


  wire [L_NUM_INTF-1:0] channel_in_0;
  wire [L_NUM_INTF-1:0] channel_in_1;
  wire [L_NUM_INTF-1:0] channel_in_2;
  wire [L_NUM_INTF-1:0] channel_in_3;
  wire [L_NUM_INTF-1:0] channel_out_next_0;
  wire [L_NUM_INTF-1:0] channel_out_next_1;
  wire [L_NUM_INTF-1:0] channel_out_next_2;
  wire [L_NUM_INTF-1:0] channel_out_next_3;

  genvar                  in_intf;
  genvar                  out_intf;


  function channel_or;
  input [L_NUM_INTF-1:0] channel_in;
  input integer          skip_intf;
  integer                intf;
  begin
    channel_or = 1'b0;
    for (intf=0;intf<L_NUM_INTF;intf=intf+1) begin
      if (intf != skip_intf)
        channel_or = channel_or | channel_in[intf];
    end
  end
  endfunction

  generate
    for (in_intf=0;in_intf<L_NUM_INTF;in_intf=in_intf+1) begin: gen_channels
      assign channel_in_0[in_intf] = channel_in[4*in_intf];
      assign channel_in_1[in_intf] = channel_in[4*in_intf+1];
      assign channel_in_2[in_intf] = channel_in[4*in_intf+2];
      assign channel_in_3[in_intf] = channel_in[4*in_intf+3];
    end
  endgenerate

  generate
    for (out_intf=0;out_intf<L_NUM_INTF;out_intf=out_intf+1) begin: gen_or
      assign channel_out_next_0[out_intf] = channel_or(channel_in_0, out_intf);
      assign channel_out_next_1[out_intf] = channel_or(channel_in_1, out_intf);
      assign channel_out_next_2[out_intf] = channel_or(channel_in_2, out_intf);
      assign channel_out_next_3[out_intf] = channel_or(channel_in_3, out_intf);
    end
  endgenerate

  generate
    for (out_intf=0;out_intf<L_NUM_INTF;out_intf=out_intf+1) begin: gen_flops
      always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
          channel_out[out_intf*4+0] <= 1'b0;
          channel_out[out_intf*4+1] <= 1'b0;
          channel_out[out_intf*4+2] <= 1'b0;
          channel_out[out_intf*4+3] <= 1'b0;
        end
        else begin
          channel_out[out_intf*4+0] <= channel_out_next_0[out_intf];
          channel_out[out_intf*4+1] <= channel_out_next_1[out_intf];
          channel_out[out_intf*4+2] <= channel_out_next_2[out_intf];
          channel_out[out_intf*4+3] <= channel_out_next_3[out_intf];
        end
      end
    end
  endgenerate


endmodule
