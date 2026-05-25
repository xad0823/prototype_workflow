// ---------------------------------------------------------------------
//
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
// Release version :  2.05a
// File Version     :        $Revision: #10 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h_write_data_buffer.v#10 $ 
//
// -------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Filename    : DW_axi_x2h_write_data_buffer.v
// 
// Created     : Tues Dec 21 20:00:00 GMT 2004
// Description : Connects to the DWbb fifo control and the registers
//               Allows for a single or two clocks, selects fifo based on 
//               clocking
//               The AXI side pushes with the aword
//   
//-----------------------------------------------------------------------------

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h_write_data_buffer(/*AUTOARG*/
  // Outputs
  awdata_rdy_int_n, 
                                    hwword_int, 
                                    hwdata_rdy_int_n, 
                                    // Inputs
                                    clk_axi, 
                                    awword_int, 
                                    push_awdata_int_n, 
                                    clk_ahb,
                                    pop_wdata_int_n, 
                                    pop_rst_n,
                                    push_rst_n
                                    );         
    // requires the following to be defined
//  X2H_AXI_DATA_WIDTH      width of the write data wordword;
//  X2H_AXI_WSTRB_WIDTH     width of the write strobe
//  X2H_WRITE_BUFFER_DEPTH  depth of the FIFO
    
//  X2H_CLK_MODE           0 = Async Clocks implies FIFO with 2 or 3 push and pop sync 
//                         1 = Sync Clocks  imnplies FIFO with 1 push and pop cync
//                         2 = single clock implies a single clock fifo
    // if X2H_CLK_MODE=0 the following will be used

parameter DEPTH            = `X2H_WRITE_BUFFER_DEPTH;

parameter FIFO_WIDTH       = `X2H_AXI_DATA_WIDTH+`X2H_AXI_WSTRB_WIDTH+1;   // including the last

parameter AWWORD_WIDTH = `X2H_AXI_DATA_WIDTH+`X2H_AXI_WSTRB_WIDTH+1;

// push and pop syns for dual clock systes.
// if the clock ar sync use 1 reg between domains
// if async use the constraint
parameter PUSH_SYNC   = `X2H_PUSH_POP_SYNC_VAL; 
parameter POP_SYNC    = `X2H_PUSH_POP_SYNC_VAL; 
parameter PUSH_AF_LVL = 2;
parameter POP_AE_LVL  = 2;
parameter POP_AF_LVL  = 2;
parameter ERR_MODE    = 0;
// set up all the widths and depths assume here that the depth cannot exceed 256
parameter COUNT_WIDTH = ((DEPTH <= 2) ? 2 :(DEPTH <= 4) ? 3 :(DEPTH <= 8) ? 4 :(DEPTH <= 16) ? 5:(DEPTH <= 32) ? 6:(DEPTH <= 64) ? 7:(DEPTH <= 128) ? 8:9);
parameter DW_ADDR_WIDTH = (COUNT_WIDTH-1); 
  // adjusting the RAM depth for odd and non-power of 2 compatibility with the control
   // if FIFO is  dual-clocked adjusting the RAM depth for odd and non-power of 2 compatibility with the control
parameter DW_EFFECTIVE_DEPTH_S1 = DEPTH;
parameter DW_EFFECTIVE_DEPTH_S2 = ((DEPTH == (1 << DW_ADDR_WIDTH))? DEPTH : DEPTH + ((DEPTH & 1) ? 1: 2));
parameter DW_EFFECTIVE_DEPTH    = ((`X2H_CLK_MODE==2) ? DW_EFFECTIVE_DEPTH_S1 : DW_EFFECTIVE_DEPTH_S2);
   
  input                    clk_axi;
  input [AWWORD_WIDTH-1:0]   awword_int;    // consisting of all the inputs
  input                    push_awdata_int_n;
  output                   awdata_rdy_int_n;
  
  
  input                     clk_ahb;
  input                     pop_wdata_int_n;
  output [AWWORD_WIDTH-1:0]   hwword_int;
  output                    hwdata_rdy_int_n;
  input                     push_rst_n;
  input                     pop_rst_n;
  
 
  reg                       awdata_rdy_int_n,hwdata_rdy_int_n;



  parameter TST_MODE     = 0;      // scan test input not connected

  parameter PUSH_AE_LVL = ((`X2H_WRITE_BUFFER_DEPTH > 2) || (`X2H_CLK_MODE != 2)) ? 2 : 0;


  wire                       pop_empty;
  wire                       push_full;
  wire                       push_empty_unconn;             
  wire                       nxt_push_empty_unconn; 
  wire                       push_ae_unconn;
  wire                       push_hf_unconn;
  wire                       push_af_unconn;
  wire                       push_error_unconn;
  wire    [COUNT_WIDTH-1:0]  push_word_count_unconn;
  wire                       nxt_push_full_unconn;
  wire                       we_n_unconn;
  wire   [DW_ADDR_WIDTH-1:0] wr_addr_unconn;
  wire                       nxt_pop_empty_unconn;
  wire                       pop_ae_unconn;
  wire                       pop_hf_unconn;
  wire                       pop_af_unconn;
  wire                       pop_full_unconn;
  wire                       nxt_pop_full_unconn;
  wire                       pop_error_unconn;
  wire    [COUNT_WIDTH-1:0]  pop_word_count_unconn;

  wire [AWWORD_WIDTH-1:0]  a2haf_awword_int;    
  
  wire [AWWORD_WIDTH-1:0]  sa2haf_hwword_int;    

 // feeding the outputs from the appropriate control
  always @(*)
    begin:CLK_MODE_WDB_PROC
      awdata_rdy_int_n = push_full;
      hwdata_rdy_int_n = pop_empty;
    end // always @ (...
      
  // The RAM
  assign a2haf_awword_int = awword_int;
  
  assign hwword_int       = sa2haf_hwword_int;



//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ : BCM components are configurable to use in various scenarios in this particular design we are not using certain ports. Hence although those signals are read we are not driving them. Therefore waiving this warning.



DW_axi_x2h_bcm66

  #(FIFO_WIDTH,     // Word width.
    DEPTH,          // Word depth.
    DW_ADDR_WIDTH,  // Fifo address width.
    COUNT_WIDTH,    // Count width.
    PUSH_AE_LVL,    // push ae_level, don't care.
    PUSH_AF_LVL,    // push af_level, don't care.
    POP_AE_LVL,     // pop ae_level, don't care.
    POP_AF_LVL,     // pop af_level, don't care.
    ERR_MODE,       // err_mode, don't care.
    PUSH_SYNC,      // Push sync mode.
    POP_SYNC,       // Pop sync mode.
    0,              // Reset mode, asynch. reset including memory.
    `X2H_VERIF_EN,  // Verification enable control
    1 ,             // Mem mode
    1               // EARLY_DATA_EN  
  )
  U_dclk_fifo (
    // Push side - Inputs
    .clk_push        (clk_axi),
    .rst_push_n      (push_rst_n),

    .push_req_n      (push_awdata_int_n),
    .data_in         (a2haf_awword_int),

    // Push side - Outputs
    .push_full       (push_full),
    .nxt_push_full   (nxt_push_full_unconn),
    
    // Push side - Unconnected / Tied off.
    .init_push_n     (1'b1), // Tied to 1'b1.
    .push_empty      (push_empty_unconn),
    .nxt_push_empty  (nxt_push_empty_unconn),
    .push_ae         (push_ae_unconn),
    .push_hf         (push_hf_unconn),
    .push_af         (push_af_unconn),
    .push_error      (push_error_unconn), 
    .push_word_count (push_word_count_unconn),
    .we_n            (we_n_unconn),
    .wr_addr         (wr_addr_unconn),


    // Pop side - Inputs
    .clk_pop         (clk_ahb),
    .rst_pop_n       (pop_rst_n),
    .pop_req_n       (pop_wdata_int_n),

    // Pop side - Outputs
    .pop_empty       (pop_empty),
    .nxt_pop_empty   (nxt_pop_empty_unconn),
    .data_out        (sa2haf_hwword_int),

    // Pop side - Unconnected / tied off
    .init_pop_n      (1'b1), // Never using diagnostic mode.
    .pop_ae          (pop_ae_unconn),
    .pop_hf          (pop_hf_unconn),
    .pop_af          (pop_af_unconn),
    .pop_full        (pop_full_unconn),
    .nxt_pop_full    (nxt_pop_full_unconn),
    .pop_error       (pop_error_unconn), 
    .pop_word_count  (pop_word_count_unconn)
  );

//spyglass enable_block W528


endmodule // AXI_WRITE_DATA_BUFFER


