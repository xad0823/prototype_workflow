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

module sse710_bas_arbiter_pri
  #(parameter
      WAYS = 4,
      LSB_N_MSB = 0
  )
(
  input  wire [WAYS-1:0] request_i,
  output wire [WAYS-1:0] grant_o
);


  genvar i;

  generate
    if (LSB_N_MSB == 0)
      begin : g_msb
        for (i=0 ; i<WAYS ; i=i+1)
          begin : g_i
            if (i==(WAYS-1))
              begin : g_i_last
                assign grant_o[i] = (request_i[i]);
              end
            else if (i==(WAYS-2))
              begin : g_i_penultimate
                assign grant_o[i] = (request_i[i] & ~request_i[i+1]);
              end
            else
              begin : g_i_other
                assign grant_o[i] = (request_i[i] & ~(|(request_i[(WAYS-1):(i+1)])));
              end
          end
      end
    else
      begin : g_lsb
        for (i=0 ; i<WAYS ; i=i+1)
          begin : g_i
            if (i==0)
              begin : g_i_last
                assign grant_o[i] = (request_i[i]);
              end
            else if (i==1)
              begin : g_i_penultimate
                assign grant_o[i] = (request_i[i] & ~request_i[i-1]);
              end
            else
              begin : g_i_other
                assign grant_o[i] = (request_i[i] & ~(|(request_i[(i-1):0])));
              end
          end
      end
  endgenerate

endmodule
