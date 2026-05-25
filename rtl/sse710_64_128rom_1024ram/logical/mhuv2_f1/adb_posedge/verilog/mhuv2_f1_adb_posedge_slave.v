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

module mhuv2_f1_adb_posedge_slave #(
  parameter WIDTH = 1

)(
  input   wire                          CLK,
  input   wire                          RESETn,

  output  wire  [WIDTH-1:0]             EDGEREQASYNC,
  input   wire  [WIDTH-1:0]             EDGEACKASYNC,
  
  input   wire  [WIDTH-1:0]             EDGESYNC,

  input   wire                          CLKEN,
  
  output  wire                          CLKREQUEST,
  
  input   wire                          PWREN,
  
  output  wire                          PWRREQUEST

);

  
  wire             en_comb;
  
  wire [WIDTH-1:0] edgesync_gated;

  wire [WIDTH-1:0] edgereqasync_comb;

  reg  [WIDTH-1:0] edgereqasync_state;
  
  wire [WIDTH-1:0] edgeack_sync;
  
  wire             clkrequest_int;
  wire             clkenable_int;
  
  reg              pwrrequest_int;
  wire             pwrrequest_int_comb;
  

  generate
    genvar i;
    for( i = 0; i < {25'h0, WIDTH}; i = i + 1) begin: SYNC
      mhuv2_f1_adb_sync u_adb_sync_edgeack(
        .CLK                                  (CLK),
        .RESETn                               (RESETn),
        .ASYNC                                (EDGEACKASYNC[i]),
        .SYNC                                 (edgeack_sync[i])
  
      );
    end
  endgenerate

  
  assign en_comb = CLKEN & PWREN;
  
  assign edgesync_gated = EDGESYNC & {WIDTH{en_comb}};
  
  assign  edgereqasync_comb = (edgesync_gated & ~edgeack_sync) | (edgereqasync_state & ~edgeack_sync);
  
  always @(posedge CLK or negedge RESETn)
          if(!RESETn)
                  edgereqasync_state <= {WIDTH{1'b0}};
          else if (en_comb)
                  edgereqasync_state <= edgereqasync_comb;
  
  assign EDGEREQASYNC = edgereqasync_state;

  
  assign clkrequest_int = | (edgereqasync_state | edgeack_sync);
  
  assign CLKREQUEST     = clkrequest_int;
  
  always @(posedge CLK or negedge RESETn)
    if(!RESETn)
      pwrrequest_int <= 1'b0;
    else
      pwrrequest_int <= pwrrequest_int_comb;
  
  assign pwrrequest_int_comb = clkrequest_int | (|edgesync_gated);
  
  assign PWRREQUEST = pwrrequest_int;
   

endmodule
