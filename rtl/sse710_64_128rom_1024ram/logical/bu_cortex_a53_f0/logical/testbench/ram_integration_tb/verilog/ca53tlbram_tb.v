//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-05-23 16:00:38 +0100 (Wed, 23 May 2012) $
//
//      Revision            : $Revision: 209955 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
//
// NOTE : The module is customize for CortexA53
//-----------------------------------------------------------------------------

`include "CORTEXA53_RAMtestbench_defs.v"
`include "cortexa53params.v"

module ca53tlbram_tb #(parameter CPU_CACHE_PROTECTION  = 1'b0)
(
  output wire [3:0]                          tlb_ram_en_o,
  output wire                                tlb_ram_wr_o,
  output wire [(`CA53_TLB_RAM_ADDR_W-1):0]   tlb_ram_addr_o,
  output wire [(`CA53_TLB_RAM_W-1)     :0]   tlb_ram_wdata_o,
  input  wire [(`CA53_TLB_RAM_W-1)     :0]   tlb_ram_rdata0_i,
  input  wire [(`CA53_TLB_RAM_W-1)     :0]   tlb_ram_rdata1_i,
  input  wire [(`CA53_TLB_RAM_W-1)     :0]   tlb_ram_rdata2_i,
  input  wire [(`CA53_TLB_RAM_W-1)     :0]   tlb_ram_rdata3_i,

  output wire                                tlbram_passed_num1_o,
  output wire                                tlbram_passed_num2_o,
  output reg                                 tlbram_done_num1_o,
  output reg                                 tlbram_done_num2_o,
  input  wire                                clk,
  input  wire                                reset_n,
  input  wire [7:0]                          max_tlbram_range,
  input  wire                                test_start_i
);


  localparam [(`CA53_TLB_RAM_ADDR_W-1):0] TLB_MAX_ADDR  = 8'b10100000; //159

  // -----------------------------------------------------------------------------
  // Functions for mangling data depending on RAM bank.
  // -----------------------------------------------------------------------------

  function [7:0] f_scramble_byte;
    input [7:0] data;
    input [3:0] bank;
    begin
      case(bank)
        4'b0000 : f_scramble_byte =  data[7:0];
        4'b0001 : f_scramble_byte = {data[7:2], data[0], data[1]           };
        4'b0010 : f_scramble_byte = {data[7:3], data[0], data[1],   data[2]};
        4'b0011 : f_scramble_byte = {data[7:4], data[0], data[2:1], data[3]};
        4'b0100 : f_scramble_byte = {data[7:5], data[0], data[3:1], data[4]};
        4'b0101 : f_scramble_byte = {data[7:6], data[0], data[4:1], data[5]};
        4'b0110 : f_scramble_byte = {data[7]  , data[0], data[5:1], data[6]};
        4'b0111 : f_scramble_byte = {           data[0], data[6:1], data[7]};
        default : f_scramble_byte = 8'hxx;
      endcase
    end
  endfunction

  function [31:0] f_scramble_data;
    input [31:0] data;
    input [3:0]  bank;
    begin
      f_scramble_data = {f_scramble_byte(data[31:24], bank),
                         f_scramble_byte(data[23:16], bank),
                         f_scramble_byte(data[15:8] , bank),
                         f_scramble_byte(data[7:0]  , bank)};
    end
  endfunction

  //TLBRam TB
  //------------
  wire [((`CA53_TLB_RAM_W * `TLBRAM_NUM_BANKS) -1):0]  tlbram_rdata;
  wire [(`CA53_TLB_RAM_ADDR_W-1):0]                    tlb_ram_addr_tst_out;
  //Test Number-1 Declarations
  wire                                                 tlbram_done_num1;
  wire [3:0]                                           tlbram_bank_cnt_num1;
  wire [(`TLBRAM_ADDR_WIDTH -1):0]                     tlbram_addr_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_check_num1;
  wire [(`TLBRAM_NUM_BANKS -1) :0]                     tlbram_en_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_check0_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_check1_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_check2_num1;
  wire [(`CA53_TLB_RAM_W -1)   :0]                     tlbram_wdata_check3_num1;
  wire [((`CA53_TLB_RAM_W * `TLBRAM_NUM_BANKS) -1):0]  expected_tlbram_wdata_num1;
  wire                                                 in_progress_num1;
  wire [(`CA53_TLB_RAM_ADDR_W-1) :0]                   tlb_ram_addr_tst1;
  wire [(`CA53_TLB_RAM_W -1)     :0]                   tlb_ram_wdata_tst1;
  wire [(`TLBRAM_NUM_BANKS - 1)  :0]                   tlb_ram_en_tst1;
  wire                                                 tlb_ram_wr_num1;

  reg  [3:0]                                           tlbram_wr_en_num1;

  //Test Number-2 Declarations

  wire                                                 tlbram_done_num2;
  wire [3:0]                                           tlbram_bank_cnt_num2;
  wire [(`TLBRAM_ADDR_WIDTH -1)  :0]                   tlbram_addr_num2;
  wire [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_num2;
  wire [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_check_num2;
  wire [(`TLBRAM_NUM_BANKS -1)   :0]                   tlbram_en_num2;
  wire [((`CA53_TLB_RAM_W * `TLBRAM_NUM_BANKS) -1):0]  expected_tlbram_wdata_num2;
  wire                                                 in_progress_num2;
  wire [(`CA53_TLB_RAM_ADDR_W-1) :0]                   tlb_ram_addr_tst2;
  wire [(`CA53_TLB_RAM_W -1)     :0]                   tlb_ram_wdata_tst2;
  wire [(`TLBRAM_NUM_BANKS - 1)  :0]                   tlb_ram_en_tst2;
  wire                                                 tlb_ram_wr_num2;
  wire                                                 reset_data_word_num2;

  reg  [3:0]                                           tlbram_wr_en_num2;
  reg  [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_check0_num2;
  reg  [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_check1_num2;
  reg  [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_check2_num2;
  reg  [(`CA53_TLB_RAM_W -1)     :0]                   tlbram_wdata_check3_num2;

  //########### Generic Code for all test#######
  //--------------------------------------------

  assign tlbram_rdata = {tlb_ram_rdata3_i, tlb_ram_rdata2_i, tlb_ram_rdata1_i, tlb_ram_rdata0_i};

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `TLBRAM_RAM_ID),       // Unique ID
                             .ADDR_WIDTH ( `TLBRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `TLBRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `TLBRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `TLBRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_TLB_RAM_W),      // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `TLBRAM_CHECK_LATENCY)
  ) tlb_ramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (tlbram_rdata),
   .max_range_i   (max_tlbram_range),
   .expected_data (expected_tlbram_wdata_num1),
   //Outputs
   .addr_o        (tlbram_addr_num1),
   .wdata_o       (tlbram_wdata_num1),
   .enable_o      (tlbram_en_num1),
   .wr_en_o       (tlb_ram_wr_num1),
   .wrbyte_en_o   ( ),
   .bank_cnt_o    (tlbram_bank_cnt_num1),
   .wdata_check_o (tlbram_wdata_check_num1),
   .passed_o      (tlbram_passed_num1_o),
   .done_o        (tlbram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

   // Assign a different address to each bank.
  assign tlb_ram_addr_tst1   = (tlbram_addr_num1 < TLB_MAX_ADDR) ? tlbram_addr_num1 : {`CA53_TLB_RAM_ADDR_W{1'b0}};

  // Assign different write data to each bank.
  assign tlb_ram_wdata_tst1 = (tlbram_addr_num1 < TLB_MAX_ADDR) ? f_scramble_data(tlbram_wdata_num1, tlbram_bank_cnt_num1) : {`CA53_TLB_RAM_W{1'b0}};

  assign tlb_ram_en_tst1 =  tlb_ram_wr_num1 ? tlbram_wr_en_num1[(`TLBRAM_NUM_BANKS - 1):0] : tlbram_en_num1[(`TLBRAM_NUM_BANKS - 1):0];

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      tlbram_done_num1_o <= 1'b0;
    else if (tlbram_done_num1)
      tlbram_done_num1_o <= tlbram_done_num1;

  always@(*)
   begin
     case(tlbram_bank_cnt_num1)
       4'b0000 : tlbram_wr_en_num1 = 4'b0001;
       4'b0001 : tlbram_wr_en_num1 = 4'b0010;
       4'b0010 : tlbram_wr_en_num1 = 4'b0100;
       4'b0011 : tlbram_wr_en_num1 = 4'b1000;
       default : tlbram_wr_en_num1 = {4{1'bx}};
     endcase
   end

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `TLBRAM_RAM_ID),       // Unique ID
                             .ADDR_WIDTH ( `TLBRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `TLBRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `TLBRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `TLBRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_TLB_RAM_W),      // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `TLBRAM_CHECK_LATENCY)
  ) tlb_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (tlbram_done_num1),
   .rdata_i           (tlbram_rdata),
   .max_range_i       (max_tlbram_range),
   .expected_data     (expected_tlbram_wdata_num2),
   //Outputs
   .addr_o            (tlbram_addr_num2),
   .wdata_o           (tlbram_wdata_num2),
   .enable_o          (tlbram_en_num2),
   .wr_en_o           (tlb_ram_wr_num2),
   .wrbyte_en_o       ( ),
   .bank_cnt_o        (tlbram_bank_cnt_num2),
   .wdata_check_o     (tlbram_wdata_check_num2),
   .passed_o          (tlbram_passed_num2_o),
   .done_o            (tlbram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

   // Assign a different address to each bank.
  assign tlb_ram_addr_tst2   = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_addr_num2 : {`CA53_TLB_RAM_ADDR_W{1'b0}};

  // Assign different write data to each bank.
  assign tlb_ram_wdata_tst2 = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_wdata_num2 : {`CA53_TLB_RAM_W{1'b0}};

  assign tlb_ram_en_tst2 = (tlbram_wdata_num2 == {`CA53_TLB_RAM_W{1'b0}} | tlbram_en_num2 == {`TLBRAM_NUM_BANKS{1'b0}}) ? tlbram_en_num2[(`TLBRAM_NUM_BANKS - 1):0] : (tlb_ram_wr_num2 ? tlbram_wr_en_num2[(`TLBRAM_NUM_BANKS - 1):0] : tlbram_en_num2[(`TLBRAM_NUM_BANKS - 1):0]);

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      tlbram_done_num2_o <= 1'b0;
    else if (tlbram_done_num2)
      tlbram_done_num2_o <= tlbram_done_num2;

  always@(*)
   begin
     case(tlbram_bank_cnt_num2)
       4'b0000 : tlbram_wr_en_num2 = 4'b0001;
       4'b0001 : tlbram_wr_en_num2 = 4'b0010;
       4'b0010 : tlbram_wr_en_num2 = 4'b0100;
       4'b0011 : tlbram_wr_en_num2 = 4'b1000;
       default : tlbram_wr_en_num2 = {4{1'bx}};
     endcase
   end

 //##########Final Muxing###########
 //---------------------------------

 assign tlb_ram_addr_tst_out = in_progress_num1 ? tlb_ram_addr_tst1  : in_progress_num2 ? tlb_ram_addr_tst2  : {`CA53_TLB_RAM_ADDR_W{1'b0}};
 assign tlb_ram_addr_o       = tlb_ram_wr_o     ? (~max_tlbram_range | tlb_ram_addr_tst_out) : tlb_ram_addr_tst_out;
 assign tlb_ram_wdata_o      = in_progress_num1 ? tlb_ram_wdata_tst1 : in_progress_num2 ? tlb_ram_wdata_tst2 : {`CA53_TLB_RAM_W{1'b0}};
 assign tlb_ram_en_o         = in_progress_num1 ? tlb_ram_en_tst1    : in_progress_num2 ? tlb_ram_en_tst2    : {2{1'b0}};
 assign tlb_ram_wr_o         = in_progress_num1 ? tlb_ram_wr_num1    : in_progress_num2 ? tlb_ram_wr_num2    :  1'b0;

 //Checker Case Statement for Test-1
 assign tlbram_wdata_check0_num1 = (tlbram_addr_num1 < TLB_MAX_ADDR) ? f_scramble_data(tlbram_wdata_check_num1, 0) : {`CA53_TLB_RAM_W{1'b0}};
 assign tlbram_wdata_check1_num1 = (tlbram_addr_num1 < TLB_MAX_ADDR) ? f_scramble_data(tlbram_wdata_check_num1, 1) : {`CA53_TLB_RAM_W{1'b0}};
 assign tlbram_wdata_check2_num1 = (tlbram_addr_num1 < TLB_MAX_ADDR) ? f_scramble_data(tlbram_wdata_check_num1, 2) : {`CA53_TLB_RAM_W{1'b0}};
 assign tlbram_wdata_check3_num1 = (tlbram_addr_num1 < TLB_MAX_ADDR) ? f_scramble_data(tlbram_wdata_check_num1, 3) : {`CA53_TLB_RAM_W{1'b0}};

 assign expected_tlbram_wdata_num1 = {tlbram_wdata_check3_num1, tlbram_wdata_check2_num1, tlbram_wdata_check1_num1, tlbram_wdata_check0_num1};

 //Checker Case Statement for Test-2
 always@(*)
   begin
     tlbram_wdata_check0_num2 = {`CA53_TLB_RAM_W{1'b0}};
     tlbram_wdata_check1_num2 = {`CA53_TLB_RAM_W{1'b0}};
     tlbram_wdata_check2_num2 = {`CA53_TLB_RAM_W{1'b0}};
     tlbram_wdata_check3_num2 = {`CA53_TLB_RAM_W{1'b0}};
     case (tlbram_bank_cnt_num2)
       4'b0000 : tlbram_wdata_check0_num2 = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_wdata_check_num2 : {`CA53_TLB_RAM_W{1'b0}};
       4'b0001 : tlbram_wdata_check1_num2 = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_wdata_check_num2 : {`CA53_TLB_RAM_W{1'b0}};
       4'b0010 : tlbram_wdata_check2_num2 = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_wdata_check_num2 : {`CA53_TLB_RAM_W{1'b0}};
       4'b0011 : tlbram_wdata_check3_num2 = (tlbram_addr_num2 < TLB_MAX_ADDR) ? tlbram_wdata_check_num2 : {`CA53_TLB_RAM_W{1'b0}};
     endcase
   end

 assign expected_tlbram_wdata_num2 = {tlbram_wdata_check3_num2, tlbram_wdata_check2_num2, tlbram_wdata_check1_num2, tlbram_wdata_check0_num2};


endmodule
