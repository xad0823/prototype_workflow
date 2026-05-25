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

module ca53_l2_victimram_tb (
  output wire                                     l2_victimram_no_acc_next_cycle_o,
  output wire                                     l2_victimram_clken_o,
  output wire                                     l2_victimram_en_o,
  output wire                                     l2_victimram_wr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_STRB_W-1:0] l2_victimram_strb_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] l2_victimram_addr_o,
  output wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_wdata_o,
  input  wire [`CA53_SCU_L2_VICTIMRAM_DATA_W-1:0] l2_victimram_rdata_i,

  output wire                                     l2_victimram_passed_num1_o,
  output wire                                     l2_victimram_passed_num2_o,
  output wire                                     l2_victimram_passed_num3_o,
  output reg                                      l2_victimram_done_num1_o,
  output reg                                      l2_victimram_done_num2_o,
  output reg                                      l2_victimram_done_num3_o,
  input  wire                                     clk,
  input  wire                                     reset_n,
  input  wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0] max_l2_victimram_range,
  input  wire                                     test_start_i
);

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

   function [31:0] f_wdata_check;
    input [1:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check = {{30{1'b0}} , data};
           5'b00001 : f_wdata_check = {{28{1'b0}} , data, {2{1'b0}}};
           5'b00010 : f_wdata_check = {{26{1'b0}} , data, {4{1'b0}}};
           5'b00011 : f_wdata_check = {{24{1'b0}} , data, {6{1'b0}}};
           5'b00100 : f_wdata_check = {{22{1'b0}} , data, {8{1'b0}}};
           5'b00101 : f_wdata_check = {{20{1'b0}} , data, {10{1'b0}}};
           5'b00110 : f_wdata_check = {{18{1'b0}} , data, {12{1'b0}}};
           5'b00111 : f_wdata_check = {{16{1'b0}} , data, {14{1'b0}}};
           5'b01000 : f_wdata_check = {{14{1'b0}} , data, {16{1'b0}}};
           5'b01001 : f_wdata_check = {{12{1'b0}} , data, {18{1'b0}}};
           5'b01010 : f_wdata_check = {{10{1'b0}} , data, {20{1'b0}}};
           5'b01011 : f_wdata_check = {{ 8{1'b0}} , data, {22{1'b0}}};
           5'b01100 : f_wdata_check = {{ 6{1'b0}} , data, {24{1'b0}}};
           5'b01101 : f_wdata_check = {{ 4{1'b0}} , data, {26{1'b0}}};
           5'b01110 : f_wdata_check = {{ 2{1'b0}} , data, {28{1'b0}}};
           5'b01111 : f_wdata_check = {             data, {30{1'b0}}};
           default : f_wdata_check = {32{1'bx}};
         endcase
    end
  endfunction

  //DirtyRam TB
  //------------

  wire [((`CA53_SCU_L2_VICTIMRAM_DATA_W * `L2VICTIMRAM_NUM_BANKS) -1):0] l2_victimram_rdata;
  wire                                                                   reset_data_word_num2;
  wire [`CA53_SCU_L2_VICTIMRAM_ADDR_W-1:0]                               l2_victimram_addr_tst_out;
  wire                                                                   dis_clken_num1;
  
  //Test Number-1 Declarations
  wire                                                                   l2_victimram_done_num1;
  wire [3:0]                                                             l2_victimram_bank_cnt_num1;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_num1;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_num1;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_disclken_num1;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_check_num1;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_num1;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_bw_en_num1;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_tst1;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_tst1;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_strb_tst1;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_tst1;
  wire                                                                   l2_victimram_wr_num1;
  wire [((`CA53_SCU_L2_VICTIMRAM_DATA_W * `L2VICTIMRAM_NUM_BANKS) -1):0] expected_l2_victimram_wdata_num1;
  wire                                                                   in_progress_num1;

  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check0_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check1_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check2_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check3_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check4_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check5_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check6_num1;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check7_num1;

  //Test Number-2 Declarations
  wire                                                                   l2_victimram_done_num2;
  wire [3:0]                                                             l2_victimram_bank_cnt_num2;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_num2;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_num2;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_check_num2;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_num2;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_bw_en_num2;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_tst2;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_tst2;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_strb_tst2;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_tst2;
  wire                                                                   l2_victimram_wr_num2;
  wire [((`CA53_SCU_L2_VICTIMRAM_DATA_W * `L2VICTIMRAM_NUM_BANKS) -1):0] expected_l2_victimram_wdata_num2;
  wire                                                                   in_progress_num2;

  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check0_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check1_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check2_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check3_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check4_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check5_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check6_num2;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check7_num2;

  //Test Number-3 Declarations
  wire                                                                   l2_victimram_done_num3;
  wire [3:0]                                                             l2_victimram_bank_cnt_num3;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_num3;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_num3;
  wire [(`L2VICTIMRAM_BYTE_WIDTH -1)          :0]                        l2_victimram_wdata_check_num3;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_num3;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_bw_en_num3;
  wire [(`L2VICTIMRAM_ADDR_WIDTH -1)          :0]                        l2_victimram_addr_tst3;
  wire [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)    :0]                        l2_victimram_wdata_tst3;
  wire [(`CA53_SCU_L2_VICTIMRAM_STRB_W -1)    :0]                        l2_victimram_strb_tst3;
  wire [(`L2VICTIMRAM_NUM_BANKS -1)           :0]                        l2_victimram_en_tst3;
  wire                                                                   l2_victimram_wr_num3;
  wire                                                                   in_progress_num3;
  wire [4:0]                                                             l2_victimram_strb_cnt_num3;
  wire                                                                   reset_data_word_num3;
  wire [((`CA53_SCU_L2_VICTIMRAM_DATA_W * `L2VICTIMRAM_NUM_BANKS) -1):0] expected_victimram_wdata_num3;

  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check0_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check1_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check2_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check3_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check4_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check5_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check6_num3;
  reg [(`CA53_SCU_L2_VICTIMRAM_DATA_W -1)     :0]                        l2_victimram_wdata_check7_num3;

  //########### Generic Code for all test#######
  //--------------------------------------------

  assign l2_victimram_rdata = l2_victimram_rdata_i;

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `L2VICTIMRAM_RAM_ID),    // Unique ID
                             .ADDR_WIDTH ( `L2VICTIMRAM_ADDR_WIDTH),      // Addr bits
                             .RAM_TYPE   ( `L2VICTIMRAM_RAM_TYPE  ),      // RAM type
                             .NUM_BANKS  ( `L2VICTIMRAM_NUM_BANKS),       // Number of Banks
                             .BYTE_WIDTH ( `L2VICTIMRAM_BYTE_WIDTH),      // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_SCU_L2_VICTIMRAM_DATA_W),  // width of RAM to test
                             .NUM_STRBS  ( `CA53_SCU_L2_VICTIMRAM_STRB_W),
                             .CHK_LATENCY( `L2VICTIMRAM_CHECK_LATENCY)
  ) l2_victimram_test_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (l2_victimram_rdata),
   .max_range_i   (max_l2_victimram_range),
   .expected_data (expected_l2_victimram_wdata_num1),
   //Outputs
   .addr_o        (l2_victimram_addr_num1),
   .wdata_o       (l2_victimram_wdata_num1),
   .enable_o      (l2_victimram_en_num1),
   .wr_en_o       (l2_victimram_wr_num1),
   .wrbyte_en_o   (l2_victimram_bw_en_num1),
   .bank_cnt_o    (l2_victimram_bank_cnt_num1),
   .wdata_check_o (l2_victimram_wdata_check_num1),
   .passed_o      (l2_victimram_passed_num1_o),
   .done_o        (l2_victimram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   (dis_clken_num1)
   );

   // Assign a different address to each bank.
  assign l2_victimram_addr_tst1 =  l2_victimram_addr_num1;

  // Assign different write data to each bank.
  assign l2_victimram_wdata_disclken_num1 = l2_victimram_wdata_num1 | {`CA53_SCU_L2_VICTIMRAM_DATA_W{dis_clken_num1}};
  
  assign l2_victimram_wdata_tst1 = f_scramble_data(l2_victimram_wdata_disclken_num1, 0);

 // STRBS are only set if the banks are enabled
  assign l2_victimram_strb_tst1 = l2_victimram_bw_en_num1 & {`CA53_SCU_L2_VICTIMRAM_STRB_W{l2_victimram_en_num1[0]}};

  assign l2_victimram_en_tst1 = l2_victimram_en_num1;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2_victimram_done_num1_o <= 1'b0;
   else if (l2_victimram_done_num1)
     l2_victimram_done_num1_o <= l2_victimram_done_num1;

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `L2VICTIMRAM_RAM_ID),      // Unique ID
                             .ADDR_WIDTH ( `L2VICTIMRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `L2VICTIMRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `L2VICTIMRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `L2VICTIMRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_SCU_L2_VICTIMRAM_DATA_W), // width of RAM to test
                             .NUM_STRBS  ( `CA53_SCU_L2_VICTIMRAM_STRB_W),
                             .CHK_LATENCY( `L2VICTIMRAM_CHECK_LATENCY)
  ) l2_victimram_test_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (l2_victimram_done_num1),
   .rdata_i           (l2_victimram_rdata),
   .max_range_i       (max_l2_victimram_range),
   .expected_data     (expected_l2_victimram_wdata_num2),
   //Outputs
   .addr_o            (l2_victimram_addr_num2),
   .wdata_o           (l2_victimram_wdata_num2),
   .enable_o          (l2_victimram_en_num2),
   .wr_en_o           (l2_victimram_wr_num2),
   .wrbyte_en_o       (l2_victimram_bw_en_num2),
   .bank_cnt_o        (l2_victimram_bank_cnt_num2),
   .wdata_check_o     (l2_victimram_wdata_check_num2),
   .passed_o          (l2_victimram_passed_num2_o),
   .done_o            (l2_victimram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

  // Assign same address as we are only testing address-0
  assign l2_victimram_addr_tst2 =  l2_victimram_addr_num2;

  // Assign different write data to each bank.
  assign l2_victimram_wdata_tst2 = l2_victimram_wdata_num2;

  // STRBS are only set if the banks are enabled
  assign l2_victimram_strb_tst2 = l2_victimram_bw_en_num2; 

  assign l2_victimram_en_tst2 = l2_victimram_en_num2;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2_victimram_done_num2_o <= 1'b0;
   else if (l2_victimram_done_num2)
     l2_victimram_done_num2_o <= l2_victimram_done_num2;

  //##########Test Number-3 Code###########
  //---------------------------------------

  ca53_rambytetest_number3  #(.RAM_ID     ( `L2VICTIMRAM_RAM_ID),            // Unique ID
                              .ADDR_WIDTH ( `L2VICTIMRAM_ADDR_WIDTH),   // Addr bits
                              .RAM_TYPE   ( `L2VICTIMRAM_RAM_TYPE  ),   // RAM type
                              .NUM_BANKS  ( `L2VICTIMRAM_NUM_BANKS),    // Number of Banks
                              .BYTE_WIDTH ( `L2VICTIMRAM_BYTE_WIDTH),   // Byte or bit granularity
                              .WORD_WIDTH ( `CA53_SCU_L2_VICTIMRAM_DATA_W),        // width of RAM to test
                              .NUM_STRBS  ( `CA53_SCU_L2_VICTIMRAM_STRB_W),
                              .CHK_LATENCY( `L2VICTIMRAM_CHECK_LATENCY)
  ) l2_victimram_test_number3
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (l2_victimram_done_num2),
   .rdata_i       (l2_victimram_rdata),
   .max_range_i   (max_l2_victimram_range),
   .expected_data (expected_victimram_wdata_num3),
   //Outputs
   .addr_o        (l2_victimram_addr_num3),
   .wdata_o       (l2_victimram_wdata_num3),
   .enable_o      (l2_victimram_en_num3),
   .wr_en_o       (l2_victimram_wr_num3),
   .wrbyte_en_o   (l2_victimram_bw_en_num3),
   .bank_cnt_o    (l2_victimram_bank_cnt_num3),
   .strb_cnt_o    (l2_victimram_strb_cnt_num3),
   .wdata_check_o (l2_victimram_wdata_check_num3 ),
   .passed_o      (l2_victimram_passed_num3_o),
   .done_o        (l2_victimram_done_num3),
   .in_progress_o (in_progress_num3),
   .reset_data_word_o (reset_data_word_num3)
   );

  // Assign same address as we are only testing address-0
  assign l2_victimram_addr_tst3 =  l2_victimram_addr_num3;

  // Assign different write data to each bank.
  assign l2_victimram_wdata_tst3 = l2_victimram_wdata_num3;

  // STRBS are only set if the banks are enabled
  assign l2_victimram_strb_tst3 = l2_victimram_bw_en_num3 & {`CA53_SCU_L2_VICTIMRAM_STRB_W{l2_victimram_en_num3[0]}};

  assign l2_victimram_en_tst3 = l2_victimram_en_num3;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2_victimram_done_num3_o <= 1'b0;
   else if (l2_victimram_done_num3)
     l2_victimram_done_num3_o <= l2_victimram_done_num3;

  //##########Final Muxing###########
  //---------------------------------

  assign l2_victimram_addr_tst_out = in_progress_num1 ? l2_victimram_addr_tst1  : in_progress_num2 ? l2_victimram_addr_tst2  : in_progress_num3 ? l2_victimram_addr_tst3  : {8{1'b0}};

  assign l2_victimram_addr_o       = l2_victimram_wr_o ? (~max_l2_victimram_range | l2_victimram_addr_tst_out) : l2_victimram_addr_tst_out;
  
  assign l2_victimram_wdata_o      = in_progress_num1 ? l2_victimram_wdata_tst1 : in_progress_num2 ? l2_victimram_wdata_tst2 : in_progress_num3 ? l2_victimram_wdata_tst3 : {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};

  assign l2_victimram_strb_o       = in_progress_num1 ? l2_victimram_strb_tst1  : in_progress_num2 ? l2_victimram_strb_tst2  : in_progress_num3 ? l2_victimram_strb_tst3  : {`CA53_SCU_L2_VICTIMRAM_STRB_W{1'b0}};

  assign l2_victimram_en_o         = in_progress_num1 ? l2_victimram_en_tst1	: in_progress_num2 ? l2_victimram_en_tst2    : in_progress_num3 ? l2_victimram_en_tst3    :  1'b0;

  assign l2_victimram_wr_o         = in_progress_num1 ? l2_victimram_wr_num1	: in_progress_num2 ? l2_victimram_wr_num2    : in_progress_num3 ? l2_victimram_wr_num3    :  1'b0;

  assign l2_victimram_clken_o      = (in_progress_num1  & !dis_clken_num1) | in_progress_num2 | in_progress_num3;

  assign l2_victimram_no_acc_next_cycle_o = ~(in_progress_num1 | in_progress_num2 | in_progress_num3);
  
  //Checker Case Statement for Test-1
 always@(*)
   begin
     l2_victimram_wdata_check0_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check1_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check2_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check3_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check4_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check5_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check6_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check7_num1 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     case (l2_victimram_bank_cnt_num1)
       4'b0000 : l2_victimram_wdata_check0_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 0);
       4'b0001 : l2_victimram_wdata_check1_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 1);
       4'b0010 : l2_victimram_wdata_check2_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 2);
       4'b0011 : l2_victimram_wdata_check3_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 3);
       4'b0100 : l2_victimram_wdata_check4_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 4);
       4'b0101 : l2_victimram_wdata_check5_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 5);
       4'b0110 : l2_victimram_wdata_check6_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 6);
       4'b0111 : l2_victimram_wdata_check7_num1 = f_scramble_data(l2_victimram_wdata_check_num1, 7);
     endcase
   end

 assign expected_l2_victimram_wdata_num1 = l2_victimram_wdata_check0_num1;

  //Checker Case Statement for Test-2
 always@(*)
   begin
     l2_victimram_wdata_check0_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check1_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check2_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check3_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check4_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check5_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check6_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check7_num2 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     case (l2_victimram_bank_cnt_num2)
       4'b0000 : l2_victimram_wdata_check0_num2 = l2_victimram_wdata_check_num2;
       4'b0001 : l2_victimram_wdata_check1_num2 = l2_victimram_wdata_check_num2;
       4'b0010 : l2_victimram_wdata_check2_num2 = l2_victimram_wdata_check_num2;
       4'b0011 : l2_victimram_wdata_check3_num2 = l2_victimram_wdata_check_num2;
       4'b0100 : l2_victimram_wdata_check4_num2 = l2_victimram_wdata_check_num2;
       4'b0101 : l2_victimram_wdata_check5_num2 = l2_victimram_wdata_check_num2;
       4'b0110 : l2_victimram_wdata_check6_num2 = l2_victimram_wdata_check_num2;
       4'b0111 : l2_victimram_wdata_check7_num2 = l2_victimram_wdata_check_num2;
     endcase
   end

  assign expected_l2_victimram_wdata_num2 = l2_victimram_wdata_check0_num2;

   //Checker Case Statement for Test-3
 always@(*)
   begin
     l2_victimram_wdata_check0_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check1_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check2_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check3_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check4_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check5_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check6_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     l2_victimram_wdata_check7_num3 = {`CA53_SCU_L2_VICTIMRAM_DATA_W{1'b0}};
     case (l2_victimram_bank_cnt_num3)
       4'b0000 : l2_victimram_wdata_check0_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0001 : l2_victimram_wdata_check1_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0010 : l2_victimram_wdata_check2_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0011 : l2_victimram_wdata_check3_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0100 : l2_victimram_wdata_check4_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0101 : l2_victimram_wdata_check5_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0110 : l2_victimram_wdata_check6_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
       4'b0111 : l2_victimram_wdata_check7_num3 = f_wdata_check(l2_victimram_wdata_check_num3, l2_victimram_strb_cnt_num3);
     endcase
   end

 assign expected_victimram_wdata_num3 = l2_victimram_wdata_check0_num3;

endmodule
