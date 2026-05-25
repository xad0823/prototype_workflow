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
//   Top level of css600_claimtags
//
//----------------------------------------------------------------------------


module css600_claimtags #(
  parameter NUM_CLAIM_TAGS = 2
  )
  (
  input                       clk,
  input                       reset_n,
  input                       claim_set_wr,
  input  [NUM_CLAIM_TAGS-1:0] claim_set_wr_data,
  input                       claim_set_rd,
  output [NUM_CLAIM_TAGS-1:0] claim_set_rd_data,
  input                       claim_clr_wr,
  input  [NUM_CLAIM_TAGS-1:0] claim_clr_wr_data,
  input                       claim_clr_rd,
  output [NUM_CLAIM_TAGS-1:0] claim_clr_rd_data
  );

  reg    [NUM_CLAIM_TAGS-1:0] claim_tags;
  reg    [NUM_CLAIM_TAGS-1:0] claim_tags_next;

  genvar tag;

  wire claim_tag_en = claim_set_wr | claim_clr_wr;

  generate
    for (tag=0; tag<NUM_CLAIM_TAGS; tag=tag+1) begin: gen_tags

      always @(claim_set_wr or claim_set_wr_data or
               claim_clr_wr or claim_clr_wr_data or
               claim_tags) begin
        claim_tags_next[tag] = claim_tags[tag];
        if (claim_set_wr && claim_set_wr_data[tag])
          claim_tags_next[tag] = 1'b1;
        if (claim_clr_wr && claim_clr_wr_data[tag])
          claim_tags_next[tag] = 1'b0;
      end

      always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
          claim_tags[tag] <= 1'b0;
        else if (claim_tag_en)
          claim_tags[tag] <= claim_tags_next[tag];
      end

    end
  endgenerate

  assign claim_set_rd_data = claim_set_rd ? {NUM_CLAIM_TAGS{1'b1}}
                                          : {NUM_CLAIM_TAGS{1'b0}};

  assign claim_clr_rd_data = claim_clr_rd ? claim_tags
                                          : {NUM_CLAIM_TAGS{1'b0}};


endmodule
