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

module mhuv2_f1_adb_posedge_master #(
  parameter WIDTH = 1
  
)(
  input   wire                          CLK,
  input   wire                          RESETn,

  input   wire  [WIDTH-1:0]             EDGEREQASYNC,
  output  wire  [WIDTH-1:0]             EDGEACKASYNC,
  output  wire  [WIDTH-1:0]             EDGESYNC,

  input   wire                          CLKEN,
  
  output  wire                          CLKREQUEST
 
);

  
  wire [WIDTH-1:0] edgereq_sync;
  
  wire [WIDTH-1:0] comb_edge_detect_flop;
  reg  [WIDTH-1:0] edge_detect_flop;
  
  wire             clkrequest_int;

    
  generate
  genvar i;
    for( i = 0; i < {25'h0, WIDTH}; i = i + 1) begin: SYNC
      mhuv2_f1_adb_sync u_adb_sync_edgereqasync(
        .CLK                              (CLK),
        .RESETn                           (RESETn),
        .ASYNC                            (EDGEREQASYNC[i]),
        .SYNC                             (edgereq_sync[i])
  
      );
    end
  endgenerate
  
  
  assign comb_edge_detect_flop = edgereq_sync & {WIDTH{CLKEN}};
  
  always @(posedge CLK or negedge RESETn)
          if(!RESETn)
                  edge_detect_flop <= {WIDTH{1'b0}};
          else if (clkrequest_int)
                  edge_detect_flop <= comb_edge_detect_flop;
  
  assign EDGEACKASYNC = edge_detect_flop;
  
  assign EDGESYNC = ~edge_detect_flop & edgereq_sync;
  
  
  assign clkrequest_int = |(edgereq_sync | edge_detect_flop);
  assign CLKREQUEST     = clkrequest_int;
  

endmodule
