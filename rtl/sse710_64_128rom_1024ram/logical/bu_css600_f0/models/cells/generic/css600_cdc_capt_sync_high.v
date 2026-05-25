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
//   Top level of css600_cdc_capt_sync_high
//
//----------------------------------------------------------------------------

module css600_cdc_capt_sync_high
  #(parameter FF_SYNC_DEPTH = 2)
  (
  clk,
  reset_n,
  d_async_i,
  q_sync_o
  );

localparam SYNC_DEPTH = (FF_SYNC_DEPTH == 3) ? 3 : 2;


input        clk;
input        reset_n;
input        d_async_i;

output wire  q_sync_o;


  reg       d_sync1;
  reg       d_sync2;

generate
  if (SYNC_DEPTH == 3) begin: sync_depth_3
    reg       d_sync3;
    always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
        begin
          d_sync1 <= 1'b1;
          d_sync2 <= 1'b1;
          d_sync3 <= 1'b1;
        end
      else
        begin
          d_sync1 <= d_async_i;
          d_sync2 <= d_sync1;
          d_sync3 <= d_sync2;
        end
    end

    assign q_sync_o = d_sync3;
  end
  else begin: sync_depth_2
    always @(posedge clk or negedge reset_n) begin
      if (!reset_n)
      begin
        d_sync1 <= 1'b1;
        d_sync2 <= 1'b1;
      end
      else
        begin
          d_sync1 <= d_async_i;
          d_sync2 <= d_sync1;
        end
    end

    assign q_sync_o = d_sync2;
  end

endgenerate


endmodule // css600_cdc_capt_sync_high
