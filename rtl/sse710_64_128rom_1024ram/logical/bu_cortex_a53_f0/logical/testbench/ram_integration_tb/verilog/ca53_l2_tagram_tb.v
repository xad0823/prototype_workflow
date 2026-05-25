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
`include "ca53scu_defs.v"

module ca53_l2_tagram_tb `CA53_L2_PARAM_DECL (
  output wire                                   l2_tagram_clken_o,
  output wire [`CA53_SCU_L2_ASSOC-1        :0]  l2_tagram_en_o,
  output wire                                   l2_tagram_wr_o,
  output wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]  l2_tagram_addr_o,
  output wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_wdata_o,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way0_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way1_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way2_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way3_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way4_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way5_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way6_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way7_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way8_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way9_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way10_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way11_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way12_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way13_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way14_rdata_i,
  input  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1:0]  l2_tagram_way15_rdata_i,

  output wire                                   l2tagram_passed_num1_o,
  output wire                                   l2tagram_passed_num2_o,
  output reg                                    l2tagram_done_num1_o,
  output reg                                    l2tagram_done_num2_o,
  input  wire                                   clk,
  input  wire                                   reset_n,
  input  wire [`CA53_L2_SIZE_W-1           :0]  l2_size_i,
  input  wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]  max_l2tagram_range,
  input  wire                                   test_start_i

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
        4'b1000 : f_scramble_byte = {data[3:0], data[7:4]                  };
        4'b1001 : f_scramble_byte = {data[7:2], data[0],          data[1]  };
        4'b1010 : f_scramble_byte = {data[7:3], data[0], data[2] ,data[1]  };
        4'b1011 : f_scramble_byte = {data[7:4], data[0], data[3] ,data[2:1]};
        4'b1100 : f_scramble_byte = {data[7:5], data[0], data[4] ,data[3:1]};
        4'b1101 : f_scramble_byte = {data[7:6], data[0], data[5] ,data[4:1]};
        4'b1110 : f_scramble_byte = {data[7]  , data[0], data[6] ,data[5:1]};
        4'b1111 : f_scramble_byte = {           data[0], data[7] ,data[6:1]};
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

  //L2-TagRam TB
  //------------
  wire [((`CA53_SCU_L2_TAGRAM_DATA_W * `L2TAGRAM_NUM_BANKS) -1):0]  l2tagram_rdata;
  wire [`CA53_SCU_L2_TAGRAM_ADDR_W-1:0]                             l2_tagram_addr_tst_out;
  wire                                                              dis_clken_num1;
   
  //Test Number-1 Declarations
  wire                                                              l2tagram_done_num1;
  wire [3:0]                                                        l2tagram_bank_cnt_num1;
  wire [(`CA53_SCU_L2_TAGRAM_ADDR_W -1)   :0]                       l2tagram_addr_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_disclken_num1;  
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check_num1;
  wire [(`CA53_SCU_L2_ASSOC -1)           :0]                       l2tagram_en_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check0_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check1_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check2_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check3_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check4_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check5_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check6_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check7_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check8_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check9_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check10_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check11_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check12_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check13_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check14_num1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check15_num1;
  wire [((`CA53_SCU_L2_TAGRAM_DATA_W * `L2TAGRAM_NUM_BANKS) -1):0]  expected_l2tagram_wdata_num1;
  wire                                                              in_progress_num1;
  wire                                                              l2_tagram_wr_num1;
  wire [(`CA53_SCU_L2_TAGRAM_ADDR_W -1)   :0]                       l2_tagram_addr_tst1;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2_tagram_wdata_tst1;
  wire [(`CA53_SCU_L2_ASSOC -1)           :0]                       l2_tagram_en_tst1;

  reg [(`L2TAGRAM_NUM_BANKS -1)           :0]                       l2tagram_wr_en_num1;

 //Test Number-2 Declarations
  wire                                                              l2tagram_done_num2;
  wire [3:0]                                                        l2tagram_bank_cnt_num2;
  wire [(`CA53_SCU_L2_TAGRAM_ADDR_W -1)   :0]                       l2tagram_addr_num2;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_num2;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2tagram_wdata_check_num2;
  wire [(`CA53_SCU_L2_ASSOC -1) :0]                                 l2tagram_en_num2;
  wire [((`CA53_SCU_L2_TAGRAM_DATA_W * `L2TAGRAM_NUM_BANKS) -1):0]  expected_l2tagram_wdata_num2;
  wire                                                              in_progress_num2;
  wire                                                              l2_tagram_wr_num2;
  wire [(`CA53_SCU_L2_TAGRAM_ADDR_W -1)   :0]                       l2_tagram_addr_tst2;
  wire [(`CA53_SCU_L2_TAGRAM_DATA_W -1)   :0]                       l2_tagram_wdata_tst2;
  wire [(`CA53_SCU_L2_ASSOC -1) :0]                                 l2_tagram_en_tst2;

  reg [(`L2TAGRAM_NUM_BANKS -1) :0]                                 l2tagram_wr_en_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check0_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check1_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check2_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check3_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check4_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check5_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check6_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check7_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check8_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check9_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check10_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check11_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check12_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check13_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check14_num2;
  reg [(`CA53_SCU_L2_TAGRAM_DATA_W -1)    :0]                       l2tagram_wdata_check15_num2;


  //########### Generic Code for all test#######
  //--------------------------------------------
  // mask bottom bits of the tag based on the cache size
  wire [`CA53_SCU_L2_TAGRAM_DATA_W-1      :0]                       tag_mask;

  assign tag_mask[`CA53_SCU_L2_TAGRAM_DATA_W-1:`CA53_L2_SIZE_W] = {`CA53_SCU_L2_TAGRAM_DATA_W-`CA53_L2_SIZE_W{1'b1}};
  assign tag_mask[`CA53_L2_SIZE_W-1:0]              = ~l2_size_i;

  assign l2tagram_rdata = {l2_tagram_way15_rdata_i, l2_tagram_way14_rdata_i, l2_tagram_way13_rdata_i, l2_tagram_way12_rdata_i,
                           l2_tagram_way11_rdata_i, l2_tagram_way10_rdata_i, l2_tagram_way9_rdata_i , l2_tagram_way8_rdata_i ,
                           l2_tagram_way7_rdata_i , l2_tagram_way6_rdata_i , l2_tagram_way5_rdata_i , l2_tagram_way4_rdata_i ,
                           l2_tagram_way3_rdata_i , l2_tagram_way2_rdata_i , l2_tagram_way1_rdata_i , l2_tagram_way0_rdata_i }; 


  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `L2TAGRAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `L2TAGRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `L2TAGRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `L2TAGRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `L2TAGRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_SCU_L2_TAGRAM_DATA_W),        // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `L2TAGRAM_CHECK_LATENCY)
  )  l2_tagramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (l2tagram_rdata),
   .max_range_i   (max_l2tagram_range),
   .expected_data (expected_l2tagram_wdata_num1),
   //Outputs
   .addr_o        (l2tagram_addr_num1),
   .wdata_o       (l2tagram_wdata_num1),
   .enable_o      (l2tagram_en_num1),
   .wr_en_o       (l2_tagram_wr_num1),
   .wrbyte_en_o   ( ),
   .bank_cnt_o    (l2tagram_bank_cnt_num1),
   .wdata_check_o (l2tagram_wdata_check_num1),
   .passed_o      (l2tagram_passed_num1_o),
   .done_o        (l2tagram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   (dis_clken_num1)
   );

   // Assign a different address to each bank.
  assign l2_tagram_addr_tst1   = l2tagram_addr_num1;

  // Assign different write data to each bank.
  assign l2tagram_wdata_disclken_num1 = l2tagram_wdata_num1 | {`CA53_SCU_L2_TAGRAM_DATA_W{dis_clken_num1}}; 
  
  assign l2_tagram_wdata_tst1 = f_scramble_data(l2tagram_wdata_disclken_num1, l2tagram_bank_cnt_num1);

  assign l2_tagram_en_tst1 =  (l2_tagram_wr_num1 & !dis_clken_num1) ? l2tagram_wr_en_num1 : l2tagram_en_num1;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2tagram_done_num1_o <= 1'b0;
   else if (l2tagram_done_num1)
     l2tagram_done_num1_o <= l2tagram_done_num1;

  always@(*)
   begin
     case(l2tagram_bank_cnt_num1)
       4'b0000 : l2tagram_wr_en_num1 = 16'b0000000000000001;
       4'b0001 : l2tagram_wr_en_num1 = 16'b0000000000000010;
       4'b0010 : l2tagram_wr_en_num1 = 16'b0000000000000100;
       4'b0011 : l2tagram_wr_en_num1 = 16'b0000000000001000;
       4'b0100 : l2tagram_wr_en_num1 = 16'b0000000000010000;
       4'b0101 : l2tagram_wr_en_num1 = 16'b0000000000100000;
       4'b0110 : l2tagram_wr_en_num1 = 16'b0000000001000000;
       4'b0111 : l2tagram_wr_en_num1 = 16'b0000000010000000;
       4'b1000 : l2tagram_wr_en_num1 = 16'b0000000100000000;
       4'b1001 : l2tagram_wr_en_num1 = 16'b0000001000000000;
       4'b1010 : l2tagram_wr_en_num1 = 16'b0000010000000000;
       4'b1011 : l2tagram_wr_en_num1 = 16'b0000100000000000;
       4'b1100 : l2tagram_wr_en_num1 = 16'b0001000000000000;
       4'b1101 : l2tagram_wr_en_num1 = 16'b0010000000000000;
       4'b1110 : l2tagram_wr_en_num1 = 16'b0100000000000000;
       4'b1111 : l2tagram_wr_en_num1 = 16'b1000000000000000;
       default : l2tagram_wr_en_num1 = {16{1'bx}};
     endcase
   end

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `L2TAGRAM_RAM_ID),       // Unique ID
                             .ADDR_WIDTH ( `L2TAGRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `L2TAGRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `L2TAGRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `L2TAGRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_SCU_L2_TAGRAM_DATA_W), // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `L2TAGRAM_CHECK_LATENCY)
  )  l2_tagramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (l2tagram_done_num1),
   .rdata_i           (l2tagram_rdata),
   .max_range_i       (max_l2tagram_range),
   .expected_data     (expected_l2tagram_wdata_num2),
   //Outputs
   .addr_o            (l2tagram_addr_num2),
   .wdata_o           (l2tagram_wdata_num2),
   .enable_o          (l2tagram_en_num2),
   .wr_en_o           (l2_tagram_wr_num2),
   .wrbyte_en_o       ( ),
   .bank_cnt_o        (l2tagram_bank_cnt_num2),
   .wdata_check_o     (l2tagram_wdata_check_num2),
   .passed_o          (l2tagram_passed_num2_o),
   .done_o            (l2tagram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

   // Assign a different address to each bank.
  assign l2_tagram_addr_tst2   = l2tagram_addr_num2;

  // Assign different write data to each bank.
  assign l2_tagram_wdata_tst2 = l2tagram_wdata_num2;

  assign l2_tagram_en_tst2 = (l2tagram_wdata_num2 == {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}} | l2tagram_en_num2 == {`CA53_SCU_L2_ASSOC{1'b0}})? l2tagram_en_num2 : (l2_tagram_wr_num2 ? l2tagram_wr_en_num2 : l2tagram_en_num2);

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2tagram_done_num2_o <= 1'b0;
   else if (l2tagram_done_num2)
     l2tagram_done_num2_o <= l2tagram_done_num2;

  always@(*)
   begin
     case(l2tagram_bank_cnt_num2)
       4'b0000 : l2tagram_wr_en_num2 = 16'b0000000000000001;
       4'b0001 : l2tagram_wr_en_num2 = 16'b0000000000000010;
       4'b0010 : l2tagram_wr_en_num2 = 16'b0000000000000100;
       4'b0011 : l2tagram_wr_en_num2 = 16'b0000000000001000;
       4'b0100 : l2tagram_wr_en_num2 = 16'b0000000000010000;
       4'b0101 : l2tagram_wr_en_num2 = 16'b0000000000100000;
       4'b0110 : l2tagram_wr_en_num2 = 16'b0000000001000000;
       4'b0111 : l2tagram_wr_en_num2 = 16'b0000000010000000;
       4'b1000 : l2tagram_wr_en_num2 = 16'b0000000100000000;
       4'b1001 : l2tagram_wr_en_num2 = 16'b0000001000000000;
       4'b1010 : l2tagram_wr_en_num2 = 16'b0000010000000000;
       4'b1011 : l2tagram_wr_en_num2 = 16'b0000100000000000;
       4'b1100 : l2tagram_wr_en_num2 = 16'b0001000000000000;
       4'b1101 : l2tagram_wr_en_num2 = 16'b0010000000000000;
       4'b1110 : l2tagram_wr_en_num2 = 16'b0100000000000000;
       4'b1111 : l2tagram_wr_en_num2 = 16'b1000000000000000;
       default : l2tagram_wr_en_num2 = {16{1'bx}};
     endcase
   end

 //##########Final Muxing###########
 //---------------------------------

 assign l2_tagram_addr_tst_out = in_progress_num1 ? l2_tagram_addr_tst1  : in_progress_num2 ? l2_tagram_addr_tst2  : {`CA53_SCU_L2_TAGRAM_ADDR_W{1'b0}};
 
 assign l2_tagram_addr_o       = l2_tagram_wr_o   ? (~max_l2tagram_range | l2_tagram_addr_tst_out) : l2_tagram_addr_tst_out; 
 
 assign l2_tagram_wdata_o      = tag_mask & (in_progress_num1 ? l2_tagram_wdata_tst1 : in_progress_num2 ? l2_tagram_wdata_tst2 : {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}});

 assign l2_tagram_en_o         = in_progress_num1 ? l2_tagram_en_tst1	 : in_progress_num2 ? l2_tagram_en_tst2    : {`CA53_SCU_L2_ASSOC{1'b0}};

 assign l2_tagram_wr_o         = in_progress_num1 ? l2_tagram_wr_num1	 : in_progress_num2 ? l2_tagram_wr_num2    :  1'b0;

 assign l2_tagram_clken_o      = (in_progress_num1 & !dis_clken_num1) | in_progress_num2;
 
 //Checker Case Statement for Test-1
 assign l2tagram_wdata_check0_num1  = f_scramble_data(l2tagram_wdata_check_num1, 0);
 assign l2tagram_wdata_check1_num1  = f_scramble_data(l2tagram_wdata_check_num1, 1);
 assign l2tagram_wdata_check2_num1  = f_scramble_data(l2tagram_wdata_check_num1, 2);
 assign l2tagram_wdata_check3_num1  = f_scramble_data(l2tagram_wdata_check_num1, 3);
 assign l2tagram_wdata_check4_num1  = f_scramble_data(l2tagram_wdata_check_num1, 4);
 assign l2tagram_wdata_check5_num1  = f_scramble_data(l2tagram_wdata_check_num1, 5);
 assign l2tagram_wdata_check6_num1  = f_scramble_data(l2tagram_wdata_check_num1, 6);
 assign l2tagram_wdata_check7_num1  = f_scramble_data(l2tagram_wdata_check_num1, 7);
 assign l2tagram_wdata_check8_num1  = f_scramble_data(l2tagram_wdata_check_num1, 8);
 assign l2tagram_wdata_check9_num1  = f_scramble_data(l2tagram_wdata_check_num1, 9);
 assign l2tagram_wdata_check10_num1 = f_scramble_data(l2tagram_wdata_check_num1, 10);
 assign l2tagram_wdata_check11_num1 = f_scramble_data(l2tagram_wdata_check_num1, 11);
 assign l2tagram_wdata_check12_num1 = f_scramble_data(l2tagram_wdata_check_num1, 12);
 assign l2tagram_wdata_check13_num1 = f_scramble_data(l2tagram_wdata_check_num1, 13);
 assign l2tagram_wdata_check14_num1 = f_scramble_data(l2tagram_wdata_check_num1, 14);
 assign l2tagram_wdata_check15_num1 = f_scramble_data(l2tagram_wdata_check_num1, 15);

 assign expected_l2tagram_wdata_num1 = {l2tagram_wdata_check15_num1, l2tagram_wdata_check14_num1, l2tagram_wdata_check13_num1, l2tagram_wdata_check12_num1,
                                        l2tagram_wdata_check11_num1, l2tagram_wdata_check10_num1, l2tagram_wdata_check9_num1 , l2tagram_wdata_check8_num1,
                                        l2tagram_wdata_check7_num1 , l2tagram_wdata_check6_num1 , l2tagram_wdata_check5_num1 , l2tagram_wdata_check4_num1,
                                        l2tagram_wdata_check3_num1 , l2tagram_wdata_check2_num1 , l2tagram_wdata_check1_num1 , l2tagram_wdata_check0_num1} &
                                       {tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               };

  //Checker Case Statement for Test-2
 always@(*)
   begin
     l2tagram_wdata_check0_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check1_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check2_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check3_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check4_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check5_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check6_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check7_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check8_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check9_num2  = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check10_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check11_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check12_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check13_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check14_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};
     l2tagram_wdata_check15_num2 = {`CA53_SCU_L2_TAGRAM_DATA_W{1'b0}};

     case (l2tagram_bank_cnt_num2)
       4'b0000 : l2tagram_wdata_check0_num2  = l2tagram_wdata_check_num2;
       4'b0001 : l2tagram_wdata_check1_num2  = l2tagram_wdata_check_num2;
       4'b0010 : l2tagram_wdata_check2_num2  = l2tagram_wdata_check_num2;
       4'b0011 : l2tagram_wdata_check3_num2  = l2tagram_wdata_check_num2;
       4'b0100 : l2tagram_wdata_check4_num2  = l2tagram_wdata_check_num2;
       4'b0101 : l2tagram_wdata_check5_num2  = l2tagram_wdata_check_num2;
       4'b0110 : l2tagram_wdata_check6_num2  = l2tagram_wdata_check_num2;
       4'b0111 : l2tagram_wdata_check7_num2  = l2tagram_wdata_check_num2;
       4'b1000 : l2tagram_wdata_check8_num2  = l2tagram_wdata_check_num2;
       4'b1001 : l2tagram_wdata_check9_num2  = l2tagram_wdata_check_num2;
       4'b1010 : l2tagram_wdata_check10_num2 = l2tagram_wdata_check_num2;
       4'b1011 : l2tagram_wdata_check11_num2 = l2tagram_wdata_check_num2;
       4'b1100 : l2tagram_wdata_check12_num2 = l2tagram_wdata_check_num2;
       4'b1101 : l2tagram_wdata_check13_num2 = l2tagram_wdata_check_num2;
       4'b1110 : l2tagram_wdata_check14_num2 = l2tagram_wdata_check_num2;
       4'b1111 : l2tagram_wdata_check15_num2 = l2tagram_wdata_check_num2;
     endcase
   end

 assign expected_l2tagram_wdata_num2 = {l2tagram_wdata_check15_num2, l2tagram_wdata_check14_num2, l2tagram_wdata_check13_num2, l2tagram_wdata_check12_num2,
                                        l2tagram_wdata_check11_num2, l2tagram_wdata_check10_num2, l2tagram_wdata_check9_num2 , l2tagram_wdata_check8_num2 ,
                                        l2tagram_wdata_check7_num2 , l2tagram_wdata_check6_num2 , l2tagram_wdata_check5_num2 , l2tagram_wdata_check4_num2 ,
                                        l2tagram_wdata_check3_num2 , l2tagram_wdata_check2_num2 , l2tagram_wdata_check1_num2 , l2tagram_wdata_check0_num2}  &
                                       {tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               ,
                                        tag_mask                   , tag_mask                   , tag_mask                   , tag_mask               };

endmodule
