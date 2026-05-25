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
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h_read_data_buffer.v#10 $ 
//
// -------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Filename    : DW_axi_x2h_read_data_buffer.v
// 
// Created     : Tues Dec 21 20:00:00 GMT 2004
// Description : Connects to the DWbb fifo control and the registers
//               Allows for a single or two clocks, selects fifo based on 
//               clocking
//               The AHB side pushes with the data ID and resp
//               and monitors the condition of the stack by looking at
//               the adddress to the RAM (hrdata_uush_cnt)
//-----------------------------------------------------------------------------

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h_read_data_buffer(/*AUTOARG*/
  // Outputs
  arstatus_int, 
                                   arid_int, 
                                   arlast_int, 
                                   ardata_int, 
                                   arvalid_int_n, 
                                   hrdata_push_cnt, 
                                   // Inputs
                                   clk_axi, 
                                   pop_data_int_n, 
                                   clk_ahb,
                                   push_data_int_n, 
                                   hrstatus_int, 
                                   hrid_int, 
                                   hrlast_int, 
                                   hrdata_int,
                                   pop_rst_n,
                                   push_rst_n
                                   ); 
     // requires the following to be defined
//  X2H_AXI_DATA_WIDTH       width of the read data word;
//  X2H_AXI_ID_WIDTH         width of the read id
//  X2H_READ_BUFFER_DEPTH    depth of the FIFO

//  X2H_CLK_MODE           0 = Async Clocks implies FIFO with 2 or 3 push and pop sync 
//                         1 = Sync Clocks  imnplies FIFO with 1 push and pop sync
//                         2 = single clock implies a single clock fifo
    // if X2H_CLK_MODE=0 the following will be used
//  X2H_SYNC_MODE  number of clocks used in both the push and pop sections when asynchronous clocking 

      parameter FIFO_WIDTH       = `X2H_AXI_DATA_WIDTH+`X2H_AXI_ID_WIDTH+3;

parameter DEPTH            = `X2H_READ_BUFFER_DEPTH;


// push and pop syns for dual clock systems.
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
   // if FIFO is  dual-clocked adjusting the RAM depth for odd and non-power of 2 compatibility with the control
parameter DW_EFFECTIVE_DEPTH_S1 = DEPTH ;
parameter DW_EFFECTIVE_DEPTH_S2 = ((DEPTH == (1 << DW_ADDR_WIDTH))? DEPTH : DEPTH + ((DEPTH & 1) ? 1: 2));
parameter DW_EFFECTIVE_DEPTH    = ((`X2H_CLK_MODE==2) ? DW_EFFECTIVE_DEPTH_S1 : DW_EFFECTIVE_DEPTH_S2);
parameter [7:0] HRDATA_DEPTH_DFLT = DEPTH;
  
  input                                   clk_axi;
  output [1:0]                            arstatus_int; 
  output [`X2H_AXI_ID_WIDTH-1:0]          arid_int;
  output                                  arlast_int;
  output [`X2H_AXI_DATA_WIDTH-1:0]        ardata_int;
  input                                   pop_data_int_n;
  output                                  arvalid_int_n;
  
  input                                   clk_ahb;
  input                                   push_data_int_n;
  input [1:0]                             hrstatus_int; 
  input [`X2H_AXI_ID_WIDTH-1:0]           hrid_int;
  input                                   hrlast_int;
  input [`X2H_AXI_DATA_WIDTH-1:0]         hrdata_int;
  output [7:0]                            hrdata_push_cnt;
  reg [7:0]                               hrdata_push_cnt;
  
  input                                   push_rst_n;
  input                                   pop_rst_n;
  
  wire [1:0]                              arstatus_int;

  reg                                     hrdata_rdy_int_n, arvalid_int_n; 
  //The MSB of this signal is not used.
  reg  [COUNT_WIDTH-1:0]                  local_push_cnt;
  reg  [COUNT_WIDTH-1:0]                  sclk_wcount;
  wire [COUNT_WIDTH-1:0]                  dclk_wcount;
    
  parameter PUSH_AE_LVL = ((`X2H_READ_BUFFER_DEPTH > 2) || (`X2H_CLK_MODE != 2)) ? 2 : 0;

  parameter TST_MODE    = 0;      // scan test input not connected


  wire                       pop_empty;
  wire                       push_full;
  wire                       push_empty_unconn; 
  wire                       nxt_push_empty_unconn; 
  wire                       push_ae_unconn;
  wire                       push_hf_unconn;
  wire                       push_af_unconn;
  wire                       push_error_unconn;
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



  wire [1:0]                             h2aaf_hrstatus_int; 
  wire [`X2H_AXI_ID_WIDTH-1:0]           h2aaf_hrid_int;
  wire                                   h2aaf_hrlast_int;
  wire [`X2H_AXI_DATA_WIDTH-1:0]         h2aaf_hrdata_int;
  
  wire [1:0]                             sh2aaf_arstatus_int; 
  wire [`X2H_AXI_ID_WIDTH-1:0]           sh2aaf_arid_int;
  wire                                   sh2aaf_arlast_int;
  wire [`X2H_AXI_DATA_WIDTH-1:0]         sh2aaf_ardata_int;

  //spyglass disable_block W415a
  //SMD: Signal may be multiply assigned (beside initialization) in the same scope.
  //SJ : Depending on the hrdata_rdy_int_n qualifier the hrdata_push_cnt takes a contant value. The unused MSBs are tied to zeros. Thus it won't cause any functional issues. This warning can be ignored.
 always @(*)
   begin:HRDATA_PUSH_CNT_PROC
     hrdata_push_cnt = 8'h00;
     // the single clk fifo controller gives 0 when full
     // this fixes it to give the full depth
     hrdata_push_cnt[COUNT_WIDTH-1:0] = {1'b0, local_push_cnt[COUNT_WIDTH-2:0]};  
     if (hrdata_rdy_int_n == 1'b1) hrdata_push_cnt = HRDATA_DEPTH_DFLT;
   end
  //spyglass enable_block W415a
             
 // feeding the outputs from the appropriate control
  always @(*)
    begin:CLK_MODE_2_PROC
//          s1_rst_n = 1'b0;  // hold the unusd control in reset
          hrdata_rdy_int_n = push_full;
          arvalid_int_n = pop_empty;
          local_push_cnt = dclk_wcount;          
    end // always @ (...


  // The RAM
  assign h2aaf_hrstatus_int = hrstatus_int;
  assign h2aaf_hrid_int     = hrid_int;
  assign h2aaf_hrlast_int   = hrlast_int;
  assign h2aaf_hrdata_int   = hrdata_int;
  
  assign arstatus_int = sh2aaf_arstatus_int; 
  assign arid_int     = sh2aaf_arid_int;    
  assign arlast_int   = sh2aaf_arlast_int;  
  assign ardata_int   = sh2aaf_ardata_int;  

// used in all the fifos for undefine defines


//--------------------------------------------------------------------
  // Single Clock Push & Pop Word Count
  //--------------------------------------------------------------------
  wire [COUNT_WIDTH-1:0] sclk_wcount_plus1;
  wire [COUNT_WIDTH-1:0] sclk_wcount_minus1;
  wire CO_add_unconn;
  wire CO_sub_unconn;
//spyglass disable_block W528
//SMD: A signal or variable is set but never read
//SJ : This port is not used. Therefore waiving this warning.
  generate
    if (`X2H_CLK_MODE==2) begin: DW01
      DW01_add #(COUNT_WIDTH) U_add (
        .A(sclk_wcount),
        .B({{(COUNT_WIDTH - 1){1'b0}}, 1'b1}),
        .CI(1'b0),
        .SUM(sclk_wcount_plus1),
        .CO(CO_add_unconn)
      );
  
      DW01_sub #(COUNT_WIDTH) U_sub (
        .A(sclk_wcount),
        .B({{(COUNT_WIDTH - 1){1'b0}}, 1'b1}),
        .CI(1'b0),
        .DIFF(sclk_wcount_minus1),
        .CO(CO_sub_unconn)
      );
    end
  endgenerate
//spyglass enable_block W528
  generate
    if (`X2H_CLK_MODE==2) begin: SCLK_FIFO_CNT
      always @(posedge clk_axi or negedge push_rst_n ) begin: wcount_PROC
        if (push_rst_n == 1'b0) begin
          sclk_wcount <= {COUNT_WIDTH{1'b0}};
        end else begin
          if (push_data_int_n ^ pop_data_int_n) begin
            if (!push_data_int_n)
              sclk_wcount <= sclk_wcount_plus1;
              //sclk_wcount <= sclk_wcount +1;
            else if (!pop_data_int_n) 
              sclk_wcount <= sclk_wcount_minus1;
              //sclk_wcount <= sclk_wcount -1;
          end
        end
      end 
    end  
  endgenerate

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
    1,              // Mem mode
    1               //EARLY_DATA_EN  
  )
  U_dclk_fifo (
    // Push side - Inputs
    .clk_push        (clk_ahb),
    .rst_push_n      (push_rst_n),

    .push_req_n      (push_data_int_n),
    .data_in         ({h2aaf_hrstatus_int,h2aaf_hrid_int,h2aaf_hrlast_int,h2aaf_hrdata_int}),
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
    .push_word_count (dclk_wcount),
    .we_n            (we_n_unconn),
    .wr_addr         (wr_addr_unconn),

    // Pop side - Inputs
    .clk_pop         (clk_axi),
    .rst_pop_n       (pop_rst_n),
    .pop_req_n       (pop_data_int_n),

    // Pop side - Outputs
    .pop_empty       (pop_empty),
    .nxt_pop_empty   (nxt_pop_empty_unconn),
    .data_out        ({sh2aaf_arstatus_int,sh2aaf_arid_int,sh2aaf_arlast_int,sh2aaf_ardata_int}),

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

endmodule // AXI_READ_DATA_BUFFER

  
  

  











         
                      

