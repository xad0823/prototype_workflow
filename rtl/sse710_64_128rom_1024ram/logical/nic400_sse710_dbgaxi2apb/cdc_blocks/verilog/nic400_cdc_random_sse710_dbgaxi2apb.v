//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module nic400_cdc_random_sse710_dbgaxi2apb
  ( din, dout);


  parameter WIDTH = 4;
  parameter HIER_LEN = 100;

  input [WIDTH-1:0]     din;
  output [WIDTH-1:0]    dout;

`ifdef ARM_CDC_CHECK

  reg [WIDTH-1:0]       dout;

  integer               seed;
  integer               i;
  integer               j;
  integer               seed_char;
  reg [0:(8*HIER_LEN)]  seed_string;
  integer               top_level_seed;
  
  reg [31:0]            lfsr;
  wire                  lfsr_feedback;
                           
  initial 
    begin
      $swrite(seed_string,"%m");
    
      
      seed = 0;
      for (i = 0; i < (8*HIER_LEN); i = i + 8) 
        begin
          seed_char = (seed_string[i+:8]);
          seed = seed + seed_char;     
        end
      
      
      if ($value$plusargs("seed=%d",top_level_seed)) seed = seed+top_level_seed;
      
      $display ("%s using seed %h",seed_string, seed);
      
      lfsr <= seed;
      
    end 
  
  assign lfsr_feedback = lfsr[2] ^ lfsr[30];

  always @(din)
    for (j = 0; j < WIDTH; j = j + 1) begin

        if ((din[j] ^ din[j]) !== 1'b0)
          begin
            dout[j] = lfsr[0];
            lfsr = {lfsr[30:0],lfsr_feedback};
          end
        else
          dout[j] = din[j];
    end      
  
`else
    assign dout = din;
`endif

endmodule

