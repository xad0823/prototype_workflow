
// ------------------------------------------------------------------------------
// 
// Copyright 2005 - 2022 Synopsys, INC.
// 
// This Synopsys IP and all associated documentation are proprietary to
// Synopsys, Inc. and may only be used pursuant to the terms and conditions of a
// written license agreement with Synopsys, Inc. All other use, reproduction,
// modification, or distribution of the Synopsys IP or the associated
// documentation is strictly prohibited.
// Inclusivity & Diversity - Visit SolvNetPlus to read the "Synopsys Statement on
//            Inclusivity and Diversity" (Refer to article 000036315 at
//                        https://solvnetplus.synopsys.com)
// 
// Component Name   : DW_axi_x2h
// Component Version: 2.05a
// Release Type     : GA
// Build ID         : 13.18.16.11
// ------------------------------------------------------------------------------

//
// Description : DW_axi_x2h_bcm02.v Verilog module for DW_axi_x2h
//
// DesignWare IP ID: 64c479c0
//
////////////////////////////////////////////////////////////////////////////////



module DW_axi_x2h_bcm02(
        a,
        sel,
        mux
        );

   parameter    integer A_WIDTH    = 8;  // width of input array
   parameter    integer SEL_WIDTH  = 2;  // width of selection index
   parameter    integer MUX_WIDTH  = 2;  // width of selected output

   input [A_WIDTH-1:0] a;       // input array to select from
   input [SEL_WIDTH-1:0] sel;   // selection index

   output [MUX_WIDTH-1:0] mux;  // selected output
   reg    [MUX_WIDTH-1:0] mux;

   // Selects one of N equal sized subsections of an
   // input vector to the specified output.

  always @ (a or sel) begin : mux_PROC
    integer     mxny_i, mxny_j, mxny_k;
      mux = {MUX_WIDTH {1'b0}};
      mxny_j = 0;
// spyglass disable_block STARC05-2.9.1.2e
// SMD: Loop variable used outside of the for loop
// SJ: The loop variable here has to be initialized outside of the for loop, otherwise Spyglasss could incorrectly infer a latch. And the initialization won't cause any problem here.
      mxny_k = 0;
// spyglass enable_block STARC05-2.9.1.2e
// synthesis loop_limit 8000
      for (mxny_i=0 ; mxny_i<A_WIDTH/MUX_WIDTH ; mxny_i=mxny_i+1) begin
        if ($unsigned(mxny_i) == {{(32-SEL_WIDTH){1'b0}},sel}) begin
// synthesis loop_limit 8000
          for (mxny_k=0 ; mxny_k<MUX_WIDTH ; mxny_k=mxny_k+1) begin
// spyglass disable_block W415a
// SMD: Signal may be multiply assigned (beside initialization) in the same scope
// SJ: The design checked and verified that not any one of a single bit of the bus is assigned more than once beside initialization or the multiple assignments are intentional.
// spyglass disable_block SelfDeterminedExpr-ML
// SMD: Self determined expression found
// SJ: The expression indexing the vector/array will never exceed the bound of the vector/array.
            mux[mxny_k] = a[mxny_j + mxny_k];
// spyglass enable_block W415a
// spyglass enable_block SelfDeterminedExpr-ML
          end // for (mxny_k
        end // if
        mxny_j = mxny_j + MUX_WIDTH;
      end // for (mxny_i
  end

endmodule
