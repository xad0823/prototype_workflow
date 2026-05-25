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

module ca53_i_dataram_tb #(parameter CPU_CACHE_PROTECTION  = 1'b0)
(
  output wire [3:0]                          ic_dataram_en_o,
  output wire                                ic_dataram_wr_o,
  output wire [(`CA53_IDATA_WEN_W-1):0]      ic_dataram_strb0_o,
  output wire [(`CA53_IDATA_WEN_W-1):0]      ic_dataram_strb1_o,
  output wire [(`CA53_IDATA_RAM_W-1):0]      ic_dataram_wdata0_o,
  output wire [(`CA53_IDATA_RAM_W-1):0]      ic_dataram_wdata1_o,
  output wire [11:0]                         ic_dataram_addr0_o,
  output wire [11:0]                         ic_dataram_addr1_o,
  input  wire [(`CA53_IDATA_RAM_W-1):0]      ic_dataram_rdata0_i,
  input  wire [(`CA53_IDATA_RAM_W-1):0]      ic_dataram_rdata1_i,

  output wire                                ic_dataram_passed_num1_o,
  output wire                                ic_dataram_passed_num2_o,
  output wire                                ic_dataram_passed_num3_o,
  output reg                                 ic_dataram_done_num1_o,
  output reg                                 ic_dataram_done_num2_o,
  output reg                                 ic_dataram_done_num3_o,
  input  wire                                clk,
  input  wire                                reset_n,
  input  wire [11:0]                         max_i_dataram_range,
  input  wire                                test_start_i
);

`define SEL_BYTE_WIDTH  (CPU_CACHE_PROTECTION ? `IDATARAM_BYTE_WIDTH_ECC : `IDATARAM_BYTE_WIDTH_NOECC)

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

  function [79:0] f_scramble_data;
    input [79:0] data;
    input [3:0]  bank;
    begin
      f_scramble_data = {f_scramble_byte(data[79:72], bank),
                         f_scramble_byte(data[71:64], bank),
                         f_scramble_byte(data[63:56], bank),
                         f_scramble_byte(data[55:48], bank),
                         f_scramble_byte(data[47:40], bank),
                         f_scramble_byte(data[39:32], bank),
                         f_scramble_byte(data[31:24], bank),
                         f_scramble_byte(data[23:16], bank),
                         f_scramble_byte(data[15:8] , bank),
                         f_scramble_byte(data[7:0]  , bank)};
    end
  endfunction

  function [79:0] f_wdata_check_noecc;
    input [19:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check_noecc = {{20{1'b0}}, {20{1'b0}}, {20{1'b0}}, data};
           5'b00001 : f_wdata_check_noecc = {{20{1'b0}}, {20{1'b0}}, data, {20{1'b0}}};
           5'b00010 : f_wdata_check_noecc = {{20{1'b0}}, data, {20{1'b0}}, {20{1'b0}}};
           5'b00011 : f_wdata_check_noecc = {data, {20{1'b0}}, {20{1'b0}}, {20{1'b0}}};
           default  : f_wdata_check_noecc = {80{1'bx}};
         endcase
    end
  endfunction

  function [83:0] f_wdata_check_ecc;
    input [20:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check_ecc = {{21{1'b0}}, {21{1'b0}}, {21{1'b0}}, data};
           5'b00001 : f_wdata_check_ecc = {{21{1'b0}}, {21{1'b0}}, data, {21{1'b0}}};
           5'b00010 : f_wdata_check_ecc = {{21{1'b0}}, data, {21{1'b0}}, {21{1'b0}}};
           5'b00011 : f_wdata_check_ecc = {data, {21{1'b0}}, {21{1'b0}}, {21{1'b0}}};
           default  : f_wdata_check_ecc = {84{1'bx}};
         endcase
    end
  endfunction

  //I-DataRam TB
  //------------

  wire [((`CA53_IDATA_RAM_W * `IDATARAM_NUM_BANKS) -1):0] ic_dataram_rdata;
  wire [11:0]                                             ic_dataram_addr0_tst_out;
  wire [11:0]                                             ic_dataram_addr1_tst_out;
  
  //Test Number-1 Declarations
  wire                                                    ic_dataram_done_num1;
  wire [3:0]                                              ic_dataram_bank_cnt_num1;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr_num1;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata_num1;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata_check_num1;
  wire [(`IDATARAM_NUM_BANKS -1)       :0]                ic_dataram_en_num1;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_bw_en_num1;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr0_tst1;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr1_tst1;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata0_tst1;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata1_tst1;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb0_tst1;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb1_tst1;
  wire [(`IDATARAM_NUM_BANKS * 2 -1)   :0]                ic_dataram_en_tst1;
  wire                                                    ic_dataram_wr_num1;
  wire [((`CA53_IDATA_RAM_W * `IDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num1;

  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check0_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check1_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check2_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check3_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check4_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check5_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check6_num1;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check7_num1;

  //Test Number-2 Declarations
  wire                                                    ic_dataram_done_num2;
  wire [3:0]                                              ic_dataram_bank_cnt_num2;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr_num2;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata_num2;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata_check_num2;
  wire [(`IDATARAM_NUM_BANKS -1)       :0]                ic_dataram_en_num2;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_bw_en_num2;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr0_tst2;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr1_tst2;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata0_tst2;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata1_tst2;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb0_tst2;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb1_tst2;
  wire [(`IDATARAM_NUM_BANKS * 2 -1)   :0]                ic_dataram_en_tst2;
  wire                                                    ic_dataram_wr_num2;
  wire [((`CA53_IDATA_RAM_W * `IDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num2;
  wire                                                    reset_data_word_num2;
  wire [7:0]                                              word_cnt_num2;

  reg [(`IDATARAM_NUM_BANKS  * 2 -1)   :0]                ic_dataram_wr_en_tst2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check0_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check1_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check2_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check3_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check4_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check5_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check6_num2;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check7_num2;

  //Test Number-3 Declarations
  wire                                                    ic_dataram_done_num3;
  wire [3:0]                                              ic_dataram_bank_cnt_num3;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr_num3;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata_num3;
  wire [(`SEL_BYTE_WIDTH -1)           :0]                ic_dataram_wdata_check_num3;
  wire [(`IDATARAM_NUM_BANKS -1)       :0]                ic_dataram_en_num3;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_bw_en_num3;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr0_tst3;
  wire [(`IDATARAM_ADDR_WIDTH -1)      :0]                ic_dataram_addr1_tst3;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata0_tst3;
  wire [(`CA53_IDATA_RAM_W -1)         :0]                ic_dataram_wdata1_tst3;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb0_tst3;
  wire [(`CA53_IDATA_WEN_W -1)         :0]                ic_dataram_strb1_tst3;
  wire [(`IDATARAM_NUM_BANKS * 2 -1)   :0]                ic_dataram_en_tst3;
  wire                                                    ic_dataram_wr_num3;
  wire [((`CA53_IDATA_RAM_W * `IDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num3;
  wire [4:0]                                              ic_dataram_strb_cnt_num3;
  wire                                                    reset_data_word_num3;

  reg [(`IDATARAM_NUM_BANKS  * 2 -1)   :0]                ic_dataram_wr_en_tst3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check0_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check1_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check2_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check3_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check4_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check5_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check6_num3;
  reg [(`CA53_IDATA_RAM_W -1)          :0]                dataram_wdata_check7_num3;


  //########### Generic Code for all test#######
  //--------------------------------------------

  assign ic_dataram_rdata = {ic_dataram_rdata1_i, ic_dataram_rdata0_i};

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `IDATARAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `IDATARAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `IDATARAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `IDATARAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `SEL_BYTE_WIDTH),        // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_IDATA_RAM_W),        // width of RAM to test
                             .NUM_STRBS  ( `CA53_IDATA_WEN_W),
                             .CHK_LATENCY( `IDATARAM_CHECK_LATENCY)
  )  idata_ramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (ic_dataram_rdata),
   .max_range_i   (max_i_dataram_range),
   .expected_data (expected_dataram_wdata_num1),
   //Outputs
   .addr_o        (ic_dataram_addr_num1),
   .wdata_o       (ic_dataram_wdata_num1),
   .enable_o      (ic_dataram_en_num1),
   .wr_en_o       (ic_dataram_wr_num1),
   .wrbyte_en_o   (ic_dataram_bw_en_num1),
   .bank_cnt_o    (ic_dataram_bank_cnt_num1),
   .wdata_check_o (ic_dataram_wdata_check_num1),
   .passed_o      (ic_dataram_passed_num1_o),
   .done_o        (ic_dataram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

  // Assign a different address to each bank and zero if the bank is not enabled
  assign ic_dataram_addr0_tst1 = {12{ic_dataram_bank_cnt_num1 == 4'b0000}} &  ic_dataram_addr_num1[11:0];
  assign ic_dataram_addr1_tst1 = {12{ic_dataram_bank_cnt_num1 == 4'b0001}} & {ic_dataram_addr_num1[11:2], ic_dataram_addr_num1[0], ic_dataram_addr_num1[1]};

  // Assign different write data to each bank.
  assign ic_dataram_wdata0_tst1 = {`CA53_IDATA_RAM_W{ic_dataram_bank_cnt_num1 == 4'b0000}} & f_scramble_data(ic_dataram_wdata_num1, 0);
  assign ic_dataram_wdata1_tst1 = {`CA53_IDATA_RAM_W{ic_dataram_bank_cnt_num1 == 4'b0001}} & f_scramble_data(ic_dataram_wdata_num1, 1);

  // STRBS are only set if the banks are enabled
  assign ic_dataram_strb0_tst1 = ic_dataram_bw_en_num1 & {`CA53_IDATA_WEN_W{ic_dataram_en_num1[0]}};
  assign ic_dataram_strb1_tst1 = ic_dataram_bw_en_num1 & {`CA53_IDATA_WEN_W{ic_dataram_en_num1[1]}};

  assign ic_dataram_en_tst1 = { {2{ic_dataram_en_num1[1]}} , {2{ic_dataram_en_num1[0]}} };

   //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     ic_dataram_done_num1_o <= 1'b0;
   else if (ic_dataram_done_num1)
     ic_dataram_done_num1_o <= ic_dataram_done_num1;

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `IDATARAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `IDATARAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `IDATARAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `IDATARAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `SEL_BYTE_WIDTH),        // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_IDATA_RAM_W),      // width of RAM to test
                             .NUM_STRBS  ( `CA53_IDATA_WEN_W),
                             .CHK_LATENCY( `IDATARAM_CHECK_LATENCY)
  )  idata_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (ic_dataram_done_num1),
   .rdata_i           (ic_dataram_rdata),
   .max_range_i       (max_i_dataram_range),
   .expected_data     (expected_dataram_wdata_num2),
   //Outputs
   .addr_o            (ic_dataram_addr_num2),
   .wdata_o           (ic_dataram_wdata_num2),
   .enable_o          (ic_dataram_en_num2),
   .wr_en_o           (ic_dataram_wr_num2),
   .wrbyte_en_o       (ic_dataram_bw_en_num2),
   .bank_cnt_o        (ic_dataram_bank_cnt_num2),
   .wdata_check_o     (ic_dataram_wdata_check_num2),
   .passed_o          (ic_dataram_passed_num2_o),
   .done_o            (ic_dataram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        (word_cnt_num2)
   );

  // Assign same address as we are only testing address-0
  assign ic_dataram_addr0_tst2 = ic_dataram_addr_num2[11:0];
  assign ic_dataram_addr1_tst2 = ic_dataram_addr_num2[11:0];

 // Only write to the RAM when bank enabled.
  assign ic_dataram_wdata0_tst2 = ic_dataram_bank_cnt_num2 == 4'b0000 | reset_data_word_num2 ? ic_dataram_wdata_num2 : {`CA53_IDATA_RAM_W{1'b0}};
  assign ic_dataram_wdata1_tst2 = ic_dataram_bank_cnt_num2 == 4'b0001 | reset_data_word_num2 ? ic_dataram_wdata_num2 : {`CA53_IDATA_RAM_W{1'b0}};

  // STRBS are only set if the banks are enabled
  assign ic_dataram_strb0_tst2 = ic_dataram_bw_en_num2;
  assign ic_dataram_strb1_tst2 = ic_dataram_bw_en_num2;

  // Enables are extended from 2 bits to 4 bits and have become a special case, so when we are in write mode then do something special otherwise enable all bits
  assign ic_dataram_en_tst2 = (ic_dataram_wdata_num2 == {`CA53_IDATA_RAM_W{1'b0}} | ic_dataram_en_num2 == {`IDATARAM_NUM_BANKS{1'b0}})? { {2{ic_dataram_en_num2[1]}} , {2{ic_dataram_en_num2[0]}} } : (ic_dataram_wr_num2 ? ic_dataram_wr_en_tst2 : { {2{ic_dataram_en_num2[1]}} , {2{ic_dataram_en_num2[0]}} });

   //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     ic_dataram_done_num2_o <= 1'b0;
   else if (ic_dataram_done_num2)
     ic_dataram_done_num2_o <= ic_dataram_done_num2;

  //Depending upon which half of the word we are in, which will enable different part of the word
  always@(*)
   begin
     case(ic_dataram_bank_cnt_num2)
       4'b0000 : ic_dataram_wr_en_tst2 = (word_cnt_num2 <= `CA53_IDATA_RAM_W/2) ? 4'b0001 : 4'b0010;
       4'b0001 : ic_dataram_wr_en_tst2 = (word_cnt_num2 <= `CA53_IDATA_RAM_W/2) ? 4'b0100 : 4'b1000;
       default : ic_dataram_wr_en_tst2 = {4{1'bx}};
     endcase
   end

  //##########Test Number-3 Code###########
  //---------------------------------------

  ca53_rambytetest_number3   #(.RAM_ID     ( `IDATARAM_RAM_ID), // Unique ID
                                 .ADDR_WIDTH ( `IDATARAM_ADDR_WIDTH),   // Addr bits
                                 .RAM_TYPE   ( `IDATARAM_RAM_TYPE  ),   // RAM type
                                 .NUM_BANKS  ( `IDATARAM_NUM_BANKS),    // Number of Banks
                                 .BYTE_WIDTH ( `SEL_BYTE_WIDTH),        // Byte or bit granularity
                                 .WORD_WIDTH ( `CA53_IDATA_RAM_W),      // width of RAM to test
                                 .NUM_STRBS  ( `CA53_IDATA_WEN_W),
                                 .CHK_LATENCY( `IDATARAM_CHECK_LATENCY)
  )  idata_ramtest_number3
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (ic_dataram_done_num2),
   .rdata_i           (ic_dataram_rdata),
   .max_range_i       (max_i_dataram_range),
   .expected_data     (expected_dataram_wdata_num3),
   //Outputs
   .addr_o            (ic_dataram_addr_num3),
   .wdata_o           (ic_dataram_wdata_num3),
   .enable_o          (ic_dataram_en_num3),
   .wr_en_o           (ic_dataram_wr_num3),
   .wrbyte_en_o       (ic_dataram_bw_en_num3),
   .bank_cnt_o        (ic_dataram_bank_cnt_num3),
   .strb_cnt_o        (ic_dataram_strb_cnt_num3),
   .wdata_check_o     (ic_dataram_wdata_check_num3),
   .passed_o          (ic_dataram_passed_num3_o),
   .done_o            (ic_dataram_done_num3),
   .in_progress_o     (in_progress_num3),
   .reset_data_word_o (reset_data_word_num3)
   );

  // Assign same address as we are only testing address-0
  assign ic_dataram_addr0_tst3 = ic_dataram_addr_num3[11:0];
  assign ic_dataram_addr1_tst3 = ic_dataram_addr_num3[11:0];

 // Only write to the RAM when bank enabled.
  assign ic_dataram_wdata0_tst3 = ic_dataram_bank_cnt_num3 == 4'b0000 | reset_data_word_num3 ? ic_dataram_wdata_num3 : {`CA53_IDATA_RAM_W{1'b1}};
  assign ic_dataram_wdata1_tst3 = ic_dataram_bank_cnt_num3 == 4'b0001 | reset_data_word_num3 ? ic_dataram_wdata_num3 : {`CA53_IDATA_RAM_W{1'b1}};

  // STRBS are only set if the banks are enabled
  assign ic_dataram_strb0_tst3 = ic_dataram_bw_en_num3 & ( {`CA53_IDATA_WEN_W{ic_dataram_en_tst3[0]}} | {`CA53_IDATA_WEN_W{ic_dataram_en_tst3[1]}} ) & {`CA53_DDATA_WEN_W{ic_dataram_wr_num3}};
  assign ic_dataram_strb1_tst3 = ic_dataram_bw_en_num3 & ( {`CA53_IDATA_WEN_W{ic_dataram_en_tst3[2]}} | {`CA53_IDATA_WEN_W{ic_dataram_en_tst3[3]}} ) & {`CA53_DDATA_WEN_W{ic_dataram_wr_num3}};

  // Enables are extended from 2 bits to 4 bits and have become a special case, so when we are in write mode then do something special otherwise enable all bits
  assign ic_dataram_en_tst3 = ic_dataram_wdata_num3 == {`CA53_IDATA_RAM_W{1'b0}} ? { {2{ic_dataram_en_num3[1]}} , {2{ic_dataram_en_num3[0]}} } : (ic_dataram_wr_num3 ? ic_dataram_wr_en_tst3 : { {2{ic_dataram_en_num3[1]}} , {2{ic_dataram_en_num3[0]}} });

   //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     ic_dataram_done_num3_o <= 1'b0;
   else if (ic_dataram_done_num3)
     ic_dataram_done_num3_o <= ic_dataram_done_num3;

  //When strb bits [0] or [1] are set then enable only first half of enable otherwise the second half
  always@(*)
   begin
     case(ic_dataram_bank_cnt_num3)
       4'b0000 : ic_dataram_wr_en_tst3 = (ic_dataram_bw_en_num3 == 4'b0001 || ic_dataram_bw_en_num3 == 4'b0010) ? 4'b0001 : 4'b0010;
       4'b0001 : ic_dataram_wr_en_tst3 = (ic_dataram_bw_en_num3 == 4'b0001 || ic_dataram_bw_en_num3 == 4'b0010) ? 4'b0100 : 4'b1000;
       default : ic_dataram_wr_en_tst3 = {4{1'bx}};
     endcase
   end

 //##########Final Muxing###########
 //---------------------------------------
   
   assign ic_dataram_addr0_tst_out  = in_progress_num1 ? ic_dataram_addr0_tst1  : in_progress_num2 ? ic_dataram_addr0_tst2  : in_progress_num3 ? ic_dataram_addr0_tst3  : {`IDATARAM_ADDR_WIDTH{1'b0}};
   assign ic_dataram_addr1_tst_out  = in_progress_num1 ? ic_dataram_addr1_tst1  : in_progress_num2 ? ic_dataram_addr1_tst2  : in_progress_num3 ? ic_dataram_addr1_tst3  : {`IDATARAM_ADDR_WIDTH{1'b0}};
    
   assign ic_dataram_addr0_o = ic_dataram_wr_o ? (~max_i_dataram_range | ic_dataram_addr0_tst_out) : ic_dataram_addr0_tst_out;
   assign ic_dataram_addr1_o = ic_dataram_wr_o ? (~max_i_dataram_range | ic_dataram_addr1_tst_out) : ic_dataram_addr1_tst_out;
   
   assign ic_dataram_wdata0_o = in_progress_num1 ? ic_dataram_wdata0_tst1 : in_progress_num2 ? ic_dataram_wdata0_tst2 : in_progress_num3 ? ic_dataram_wdata0_tst3 : {`CA53_IDATA_RAM_W{1'b0}};
   assign ic_dataram_wdata1_o = in_progress_num1 ? ic_dataram_wdata1_tst1 : in_progress_num2 ? ic_dataram_wdata1_tst2 : in_progress_num3 ? ic_dataram_wdata1_tst3 : {`CA53_IDATA_RAM_W{1'b0}};

   assign ic_dataram_strb0_o  = in_progress_num1 ? ic_dataram_strb0_tst1  : in_progress_num2 ? ic_dataram_strb0_tst2  : in_progress_num3 ? ic_dataram_strb0_tst3  : {`CA53_IDATA_WEN_W{1'b0}};
   assign ic_dataram_strb1_o  = in_progress_num1 ? ic_dataram_strb1_tst1  : in_progress_num2 ? ic_dataram_strb1_tst2  : in_progress_num3 ? ic_dataram_strb1_tst3  : {`CA53_IDATA_WEN_W{1'b0}};

   assign ic_dataram_en_o     = in_progress_num1 ? ic_dataram_en_tst1     : in_progress_num2 ? ic_dataram_en_tst2     : in_progress_num3 ? ic_dataram_en_tst3     : {4{1'b0}};

   assign ic_dataram_wr_o     = in_progress_num1 ? ic_dataram_wr_num1     : in_progress_num2 ? ic_dataram_wr_num2     : in_progress_num3 ? ic_dataram_wr_num3     : 1'b0;

 //Checker Case Statement for Test-1
 always@(*)
   begin
     dataram_wdata_check0_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check1_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check2_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check3_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check4_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check5_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check6_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check7_num1 = {`CA53_IDATA_RAM_W{1'b0}};
     case (ic_dataram_bank_cnt_num1)
       4'b0000 : dataram_wdata_check0_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 0);
       4'b0001 : dataram_wdata_check1_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 1);
       4'b0010 : dataram_wdata_check2_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 2);
       4'b0011 : dataram_wdata_check3_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 3);
       4'b0100 : dataram_wdata_check4_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 4);
       4'b0101 : dataram_wdata_check5_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 5);
       4'b0110 : dataram_wdata_check6_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 6);
       4'b0111 : dataram_wdata_check7_num1 = f_scramble_data(ic_dataram_wdata_check_num1 , 7);
     endcase
   end

 assign expected_dataram_wdata_num1 = {dataram_wdata_check1_num1, dataram_wdata_check0_num1};

  //Checker Case Statement for Test-2
 always@(*)
   begin
     dataram_wdata_check0_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check1_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check2_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check3_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check4_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check5_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check6_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     dataram_wdata_check7_num2 = {`CA53_IDATA_RAM_W{1'b0}};
     case (ic_dataram_bank_cnt_num2)
       4'b0000 : dataram_wdata_check0_num2 = (word_cnt_num2 <= `CA53_IDATA_RAM_W/2) ? ic_dataram_wdata_check_num2 : {ic_dataram_wdata_check_num2[(`CA53_IDATA_RAM_W -1):(`CA53_IDATA_RAM_W)/2], 1'b1, {((`CA53_IDATA_RAM_W)/2 -1 ){1'b0}}};
       4'b0001 : dataram_wdata_check1_num2 = (word_cnt_num2 <= `CA53_IDATA_RAM_W/2) ? ic_dataram_wdata_check_num2 : {ic_dataram_wdata_check_num2[(`CA53_IDATA_RAM_W -1):(`CA53_IDATA_RAM_W)/2], 1'b1, {((`CA53_IDATA_RAM_W)/2 -1 ){1'b0}}};
       4'b0010 : dataram_wdata_check2_num2 = ic_dataram_wdata_check_num2;
       4'b0011 : dataram_wdata_check3_num2 = ic_dataram_wdata_check_num2;
       4'b0100 : dataram_wdata_check4_num2 = ic_dataram_wdata_check_num2;
       4'b0101 : dataram_wdata_check5_num2 = ic_dataram_wdata_check_num2;
       4'b0110 : dataram_wdata_check6_num2 = ic_dataram_wdata_check_num2;
       4'b0111 : dataram_wdata_check7_num2 = ic_dataram_wdata_check_num2;
     endcase
   end

 assign expected_dataram_wdata_num2 = {dataram_wdata_check1_num2, dataram_wdata_check0_num2};

  //Checker Case Statement for Test-3
 always@(*)
   begin
     dataram_wdata_check0_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check1_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check2_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check3_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check4_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check5_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check6_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check7_num3 = {`CA53_DDATA_RAM_W{1'b0}};
     case (ic_dataram_bank_cnt_num3)
       4'b0000 : dataram_wdata_check0_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0001 : dataram_wdata_check1_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0010 : dataram_wdata_check2_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0011 : dataram_wdata_check3_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0100 : dataram_wdata_check4_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0101 : dataram_wdata_check5_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0110 : dataram_wdata_check6_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
       4'b0111 : dataram_wdata_check7_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3) : f_wdata_check_noecc(ic_dataram_wdata_check_num3, ic_dataram_strb_cnt_num3);
     endcase
   end

 assign expected_dataram_wdata_num3 = {dataram_wdata_check1_num3, dataram_wdata_check0_num3};


endmodule
