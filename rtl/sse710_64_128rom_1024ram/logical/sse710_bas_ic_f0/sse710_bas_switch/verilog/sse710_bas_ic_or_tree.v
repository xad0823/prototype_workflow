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

module sse710_bas_ic_or_tree
  #(parameter
    ACTIVE_WIDTH        = 3
   )

  (
    input  wire [ACTIVE_WIDTH -1 : 0] actives_i,
    output wire                       active_o
  );


  localparam EVEN_ACTIVE  = (ACTIVE_WIDTH%2) ? ACTIVE_WIDTH+1 : ACTIVE_WIDTH;
  localparam OR_NODES     = EVEN_ACTIVE-1;

  wire [OR_NODES-1:0]       glitch_free_or;

  genvar g,h;


  generate
    for(g=0;g<OR_NODES;g=g+1) begin: g_glitch_free_or_tree
      if ((ACTIVE_WIDTH%2)!=0 && g == ((ACTIVE_WIDTH-1)/2)) begin: odd_or_signals
        assign glitch_free_or[g] = actives_i[g*2];
      end
      else if (g < (EVEN_ACTIVE/2)) begin: g_base_or_gates
        sse710_bas_ic_or2 u_sse710_bas_ic_or2(
          .din0 (actives_i[g*2]),
          .din1 (actives_i[(g*2)+1]),
          .dout (glitch_free_or[g]));
      end
      else begin: g_layered_or_gates
        sse710_bas_ic_or2 u_sse710_bas_ic_or2(
          .din0 (glitch_free_or[(g%(EVEN_ACTIVE/2))*2]),
          .din1 (glitch_free_or[((g%(EVEN_ACTIVE/2))*2)+1]),
          .dout (glitch_free_or[g]));
      end
    end
  endgenerate

   assign active_o = glitch_free_or[OR_NODES-1];

endmodule
