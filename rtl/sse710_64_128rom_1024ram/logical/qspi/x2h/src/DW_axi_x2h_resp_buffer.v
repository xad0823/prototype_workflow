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
// File Version     :        $Revision: #9 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h_resp_buffer.v#9 $ 
//
// -------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Filename    : DW_axi_x2h_resp_buffer
// 
// Created     : Tues Dec 21 20:00:00 GMT 2004
// Description : Connects to the DWbb fifo control and the registers
//               Allows for a single or two clocks, selects fifo based on 
//               clocking
//               The AXI side pushes with the response
//   
//-----------------------------------------------------------------------------

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h_resp_buffer(/*AUTOARG*/
  // Outputs
  hresp_rdy_int_n, 
                              aresp_rdy_int_n, 
                              awstatus_int, 
                              awid_int, 
                              // Inputs
                              clk_axi, 
                              clk_ahb, 
                              hwstatus_int, 
                              hwid_int, 
                              push_resp_int_n, 
                              pop_resp_int_n,
                              pop_rst_n,
                              push_rst_n
                              );
  
     // requires the following to be defined
//  X2H_AXI_DATA_WIDTH      width of the read data word;
//  X2H_AXI_ID_WIDTH        width of the read id
//  X2H_WRITE_RESP_BUFFER_DEPTH   depth of the FIFO
   
//  X2H_CLK_MODE           0 = Async Clocks implies FIFO with 2 or 3 push and pop sync 
//                         1 = Sync Clocks  imnplies FIFO with 1 push and pop sync
//                         2 = single clock implies a single clock fifo
    // if X2H_CLK_MODE=0 the following will be used
//  X2H_SYNC_MODE          number of clocks used in both the push and pop sections when asynchronous clocking   
  input                   clk_axi;
  input                   clk_ahb; 
  input [1:0] hwstatus_int;
  input [`X2H_AXI_ID_WIDTH-1:0] hwid_int;
  input       push_resp_int_n;
  output      hresp_rdy_int_n;
  output      aresp_rdy_int_n;
  output [1:0] awstatus_int;
  output [`X2H_AXI_ID_WIDTH-1:0] awid_int;
  input        pop_resp_int_n;
  input        push_rst_n;
  input        pop_rst_n;  
  
parameter FIFO_WIDTH = `X2H_AXI_ID_WIDTH+2;                // fixed for ID plus status
parameter DEPTH      = `X2H_WRITE_RESP_BUFFER_DEPTH;
// push and pop syncs for dual clock systems.
// if the clock are sync use 1 reg between domains
// if async use the constraint
parameter PUSH_SYNC   = `X2H_PUSH_POP_SYNC_VAL; 
parameter POP_SYNC    = `X2H_PUSH_POP_SYNC_VAL; 
parameter PUSH_AE_LVL = 2;
parameter PUSH_AF_LVL = 2;
parameter POP_AE_LVL  = 2;
parameter POP_AF_LVL  = 2;
parameter ERR_MODE    = 0;
// set up all the widths and depths assume here that the depth cannot exceed 256
parameter COUNT_WIDTH           = ((DEPTH <= 2) ? 2 :(DEPTH <= 4) ? 3 :(DEPTH <= 8) ? 4 :(DEPTH <= 16) ? 5:(DEPTH <= 32) ? 6:(DEPTH <= 64) ? 7:(DEPTH <= 128) ? 8:9);
parameter DW_ADDR_WIDTH         = (COUNT_WIDTH-1);
   // adjusting the RAM depth for odd and non-power of 2 compatibility with the control
   // if FIFO is  dual-clocked adjusting the RAM depth for odd and non-power of 2 compatibility with the control
parameter DW_EFFECTIVE_DEPTH_S1 = DEPTH; 
parameter DW_EFFECTIVE_DEPTH_S2 = ((DEPTH == (1 << DW_ADDR_WIDTH))? DEPTH : DEPTH + ((DEPTH & 1) ? 1: 2));
parameter DW_EFFECTIVE_DEPTH    = ((`X2H_CLK_MODE==2) ? DW_EFFECTIVE_DEPTH_S1 : DW_EFFECTIVE_DEPTH_S2);

  reg                       aresp_rdy_int_n,hresp_rdy_int_n;
  
  parameter TST_MODE    = 0;      // scan test input not connected

  reg clk_push;


  wire                         push_full;
  wire                         pop_empty;
  wire                         push_empty_unconn;
  wire                         push_ae_unconn;
  wire                         push_hf_unconn;
  wire                         dclk_push_af;
  wire                         push_af_unconn;
  wire                         push_error_unconn;
  wire    [COUNT_WIDTH-1:0]    push_word_count_unconn;
  wire                         nxt_push_full_unconn;
  wire                         nxt_push_empty_unconn; 
  wire                         we_n_unconn;
  wire [DW_ADDR_WIDTH-1:0]     wr_addr_unconn;
  wire                         pop_ae_unconn;
  wire                         pop_hf_unconn;
  wire                         pop_af_unconn;
  wire                         pop_full_unconn;
  wire                         pop_error_unconn;
  wire    [COUNT_WIDTH-1:0]    pop_word_count_unconn;
  wire                         nxt_pop_empty_unconn;
  wire                         nxt_pop_full_unconn;

  wire [1:0]                   h2aaf_hwstatus_int;
  wire [`X2H_AXI_ID_WIDTH-1:0] h2aaf_hwid_int;
  
  wire [1:0]                   sh2aaf_awstatus_int;
  wire [`X2H_AXI_ID_WIDTH-1:0] sh2aaf_awid_int;

  // feeding the outputs from the appropriate control
  always @(*)
    begin:CLK_MODE_RB_2_PROC
//     s1_rst_n = 1'b0;  // hold the unusd control in reset
     aresp_rdy_int_n = pop_empty;
     hresp_rdy_int_n = push_full;        
    end // always @ (... 

  // The RAM
  assign h2aaf_hwstatus_int = hwstatus_int;
  assign h2aaf_hwid_int     = hwid_int;
  
  assign awstatus_int = sh2aaf_awstatus_int;
  assign awid_int     = sh2aaf_awid_int;

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
    .clk_push        (clk_ahb),
    .rst_push_n      (push_rst_n),

    .push_req_n      (push_resp_int_n),
    .data_in         ({h2aaf_hwstatus_int,h2aaf_hwid_int}),

    // Push side - Outputs
    .push_full       (push_full),
    .nxt_push_full   (nxt_push_full_unconn),
    
    // Push side - Unconnected / Tied off.
    .init_push_n     (1'b1), // Tied to 1'b1.
    .push_empty      (push_empty_unconn),
    .nxt_push_empty  (nxt_push_empty_unconn),
    .push_ae         (push_ae_unconn),
    .push_hf         (push_hf_unconn),
    .push_af         (dclk_push_af),
    .push_error      (push_error_unconn), 
    .push_word_count (push_word_count_unconn),
    .we_n            (we_n_unconn),
    .wr_addr         (wr_addr_unconn),


    // Pop side - Inputs
    .clk_pop         (clk_axi),
    .rst_pop_n       (pop_rst_n),
    .pop_req_n       (pop_resp_int_n),

    // Pop side - Outputs
    .pop_empty       (pop_empty),
    .nxt_pop_empty   (nxt_pop_empty_unconn),
    .data_out        ({sh2aaf_awstatus_int,sh2aaf_awid_int}),

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

    endmodule // AXI_RESP_BUFFER


