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
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_tlb_entry
#(
  parameter TAG_WIDTH  = 28,
  parameter DATA_WIDTH = 40
)(
  input  wire                      clk,
  input  wire                      reset_n,
  input  wire [TAG_WIDTH-1:0]      lookup_tag,
  input  wire                      lookup_enable,
  output wire [TAG_WIDTH-1:0]      entry_tag,
  output wire [DATA_WIDTH-1:0]     entry_data,
  output wire                      entry_hit,
  input  wire [TAG_WIDTH-1:0]      update_tag,
  input  wire [DATA_WIDTH-1:0]     update_data,
  input  wire                      update_valid,
  input  wire                      update_enable
);

reg  [TAG_WIDTH-1:0]       entry_tag_q;
reg  [DATA_WIDTH-1:0]      entry_data_q;
reg                        entry_valid_q;

wire                       lookup_match;


  always @(posedge clk)
  begin : reg_entry_tag
    if (update_enable)
      entry_tag_q <= update_tag;
  end

  always @(posedge clk)
  begin : reg_entry_data
    if (update_enable)
      entry_data_q <= update_data;
  end

  always @(posedge clk or negedge reset_n)
  begin : reg_entry_valid
    if (!reset_n)
      entry_valid_q <= 1'b0;
    else if (update_enable)
      entry_valid_q <= update_valid;
  end

  assign lookup_match = entry_valid_q & (lookup_tag == entry_tag_q);

  assign entry_hit  = lookup_enable & lookup_match;
  assign entry_tag  = entry_tag_q;
  assign entry_data = entry_data_q;

endmodule

