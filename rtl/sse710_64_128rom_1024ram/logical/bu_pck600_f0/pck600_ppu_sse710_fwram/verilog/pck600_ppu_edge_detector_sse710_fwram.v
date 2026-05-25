// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_ppu_edge_detector_sse710_fwram
#(
  parameter WIDTH = 1
)
(
  input wire                  clk,
  input wire                  reset_n,

  input wire [WIDTH-1:0]      devactive_i,
  input wire [WIDTH*2-1:0]    devactive_edge_i,

  output wire [WIDTH-1:0]     devactive_pulse_mask_o,
  output wire [WIDTH-1:0]     devactive_st_o,

  output wire                 clk_req_o,
  input wire                  clk_enable_i

);

localparam BANKS = WIDTH/4;
localparam REMAIN = WIDTH%4;
localparam NUM_ENABLES = (BANKS == 0)? 1:BANKS;
localparam FINAL_BANK_LOW_BIT = (BANKS-1)*4;


  genvar                      I;

  reg [WIDTH-1:0]             devactive_r;
  wire [NUM_ENABLES-1:0]      devactive_en;
  wire [WIDTH-1:0]            devactive_xor;


  assign devactive_xor[WIDTH-1:0] = devactive_i[WIDTH-1:0] ^ devactive_r[WIDTH-1:0];

generate
if(REMAIN == 0)
begin:width_multiple_4


  for(I=0; I<BANKS; I=I+1)
  begin:edge_detector_bank

    always@(posedge clk or negedge reset_n)
    begin
      if(!reset_n)
      begin
        devactive_r[I*4 +: 4] <= 4'h0;
      end
      else if(devactive_en[I])
      begin
        devactive_r[I*4 +: 4] <= devactive_i[I*4 +: 4];
      end
    end

    assign devactive_en[I] = (|devactive_xor[I*4 +: 4]) & clk_enable_i;

  end

end
else if(WIDTH < 8)
begin:not_width_multiple_4_and_width_less_8


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devactive_r[WIDTH-1:0] <= {WIDTH{1'b0}};
    end
    else if(devactive_en[0])
    begin
      devactive_r[WIDTH-1:0] <= devactive_i[WIDTH-1:0];
    end
  end

  assign devactive_en[0] = (|devactive_xor[WIDTH-1:0]) & clk_enable_i;

end
else
begin:not_width_multiple_4_and_width_great_equal_8


  for(I=0; I<BANKS-1; I=I+1)
  begin:edge_detector_bank

    always@(posedge clk or negedge reset_n)
    begin
      if(!reset_n)
      begin
        devactive_r[I*4 +: 4] <= 4'h0;
      end
      else if(devactive_en[I])
      begin
        devactive_r[I*4 +: 4] <= devactive_i[I*4 +: 4];
      end
    end

    assign devactive_en[I] = (|devactive_xor[I*4 +: 4]) & clk_enable_i;

  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devactive_r[WIDTH-1:FINAL_BANK_LOW_BIT] <= {(WIDTH-FINAL_BANK_LOW_BIT){1'b0}};
    end
    else if(devactive_en[NUM_ENABLES-1])
    begin
      devactive_r[WIDTH-1:FINAL_BANK_LOW_BIT] <= devactive_i[WIDTH-1:FINAL_BANK_LOW_BIT];
    end
  end

  assign devactive_en[NUM_ENABLES-1] = (|devactive_xor[WIDTH-1:FINAL_BANK_LOW_BIT]) & clk_enable_i;

end
endgenerate


generate
for(I=0; I<WIDTH; I=I+1)
begin:devactive_pulse_mask_output_loop

    assign devactive_pulse_mask_o[I] = (devactive_edge_i[I*2+1] & (devactive_r[I] & ~devactive_i[I])) |
                                       (devactive_edge_i[I*2] & (~devactive_r[I] & devactive_i[I]));

end
endgenerate

  assign devactive_st_o[WIDTH-1:0] = devactive_r[WIDTH-1:0];

  assign clk_req_o = |(devactive_xor[WIDTH-1:0]);

endmodule
