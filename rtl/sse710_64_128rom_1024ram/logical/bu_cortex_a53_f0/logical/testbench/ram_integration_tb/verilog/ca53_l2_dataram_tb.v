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

module ca53_l2_dataram_tb `CA53_L2_PARAM_DECL (
  output wire                                     l2_dataram_no_acc_next_cycle_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]     l2_dataram_clken_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]     l2_dataram_en_o,
  output wire                                     l2_dataram_wr_o,
  output wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0]   l2_dataram_addr_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata0_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata1_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata2_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata3_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata4_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata5_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata6_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_wdata7_o,

  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata0_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata1_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata2_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata3_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata4_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata5_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata6_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0]   l2_dataram_rdata7_i,

  output wire                                     l2_dataram_passed_num1_o,
  output wire                                     l2_dataram_passed_num2_o,
  output reg                                      l2_dataram_done_num1_o,
  output reg                                      l2_dataram_done_num2_o,
  input  wire                                     clk,
  input  wire                                     reset_n,
  input  wire [`CA53_SCU_L2_DATARAM_ADDR_W-1-3:0] max_l2_dataram_range,
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
        4'b0001 : f_scramble_byte = {data[7:2], data[0], data[1]             };
        4'b0010 : f_scramble_byte = {data[7:3], data[0], data[1],   data[2]  };
        4'b0011 : f_scramble_byte = {data[7:4], data[0], data[2:1], data[3]  };
        4'b0100 : f_scramble_byte = {data[7:5], data[0], data[3:1], data[4]  };
        4'b0101 : f_scramble_byte = {data[7:6], data[0], data[4:1], data[5]  };
        4'b0110 : f_scramble_byte = {data[7]  , data[0], data[5:1], data[6]  };
        4'b0111 : f_scramble_byte = {          ~data[0], data[3:1], data[7:4]};
        default : f_scramble_byte = 8'hxx;
      endcase
    end
  endfunction

  function [71:0] f_scramble_data;
    input [71:0] data;
    input [3:0]  bank;
    begin
      f_scramble_data = {f_scramble_byte(data[71:64], bank),
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

  //L2-DataRam TB
  //------------

  wire [((`CA53_SCU_L2_DATARAM_DATA_W * `L2DATARAM_NUM_BANKS) -1):0] l2_dataram_rdata;
  wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0]                             l2_dataram_addr_tst_out;
  wire                                                               dis_wren_num1;
  
  //Test Number-1 Declarations
  wire                                                               l2_dataram_done_num1;
  wire [3:0]                                                         l2_dataram_bank_cnt_num1;
  wire [(`L2DATARAM_ADDR_WIDTH -1)          :0]                      l2_dataram_addr_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata_check_num1;
  wire [(`L2DATARAM_NUM_BANKS -1)           :0]                      l2_dataram_en_num1;
  wire [(`CA53_SCU_L2_DATARAM_EN_W -1)      :0]                      l2_dataram_bw_en_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check0_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check1_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check2_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check3_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check4_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check5_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check6_num1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      dataram_wdata_check7_num1;
  wire [((`CA53_SCU_L2_DATARAM_DATA_W * `L2DATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num1;
  wire [3:0]                                                         l2dataram_way_num1;
  wire                                                               l2_dataram_wr_num1_num1;
  wire                                                               in_progress_num1;
  wire [`CA53_SCU_L2_DATARAM_ADDR_W-1       :0]                      l2_dataram_addr_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata0_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata1_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata2_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata3_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata4_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata5_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata6_tst1;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata7_tst1;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1         :0]                      l2_dataram_en_tst1;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1         :0]                      l2_dataram_clk_en_num1;

  reg [(`L2DATARAM_NUM_BANKS -1)            :0]                      l2dataram_wr_en_num1;

  //Test Number-2 Declarations
  wire                                                               l2_dataram_done_num2;
  wire [3:0]                                                         l2_dataram_bank_cnt_num2;
  wire [(`L2DATARAM_ADDR_WIDTH -1)          :0]                      l2_dataram_addr_num2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata_num2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata_check_num2;
  wire [(`L2DATARAM_NUM_BANKS -1)           :0]                      l2_dataram_en_num2;
  wire [(`CA53_SCU_L2_DATARAM_EN_W -1)      :0]                      l2_dataram_bw_en_num2;
  wire [((`CA53_SCU_L2_DATARAM_DATA_W * `L2DATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num2;
  wire [3:0]                                                         l2dataram_way_num2;
  wire                                                               l2_dataram_wr_num2_num2;
  wire                                                               in_progress_num2;
  wire [`CA53_SCU_L2_DATARAM_ADDR_W-1       :0]                      l2_dataram_addr_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata0_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata1_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata2_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata3_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata4_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata5_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata6_tst2;
  wire [(`CA53_SCU_L2_DATARAM_DATA_W -1)    :0]                      l2_dataram_wdata7_tst2;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1         :0]                      l2_dataram_en_tst2;
  wire [`CA53_SCU_L2_DATARAM_EN_W-1         :0]                      l2_dataram_clk_en_num2;

  reg [(`L2DATARAM_NUM_BANKS -1)            :0]                      l2dataram_wr_en_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check0_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check1_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check2_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check3_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check4_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check5_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check6_num2;
  reg [(`CA53_SCU_L2_DATARAM_DATA_W -1)     :0]                      dataram_wdata_check7_num2;


  //########### Generic Code for all test#######
  //--------------------------------------------

  assign l2_dataram_rdata = {l2_dataram_rdata7_i, l2_dataram_rdata6_i, l2_dataram_rdata5_i, l2_dataram_rdata4_i,
                             l2_dataram_rdata3_i, l2_dataram_rdata2_i, l2_dataram_rdata1_i, l2_dataram_rdata0_i};

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_l2dataramtest_number1   #(.RAM_ID          (`L2DATARAM_RAM_ID),        // Unique ID
                                 .ADDR_WIDTH      (`L2DATARAM_ADDR_WIDTH),    // Addr bits
                                 .RAM_TYPE        (`L2DATARAM_RAM_TYPE  ),    // RAM type
                                 .NUM_BANKS       (`L2DATARAM_NUM_BANKS),     // Number of Banks
                                 .BYTE_WIDTH      (`L2DATARAM_BYTE_WIDTH),    // Byte or bit granularity
                                 .WORD_WIDTH      (`CA53_SCU_L2_DATARAM_DATA_W), // width of RAM to test
                                 .NUM_STRBS       (`CA53_SCU_L2_DATARAM_EN_W),
                                 .CHK_LATENCY     (`L2DATARAM_CHECK_LATENCY),
                                 .L2_DATARAM_WAYS (`L2_DATARAM_WAYS)
  )  l2_data_ramtest_number1
  (
   //Inputs
   .clk                  (clk),
   .reset_n              (reset_n),
   .start_i              (test_start_i),
   .rdata_i              (l2_dataram_rdata),
   .max_range_i          (max_l2_dataram_range),
   .expected_data        (expected_dataram_wdata_num1),
   .l2_wr_latency_i      (L2_INPUT_LATENCY),
   .l2_rd_latency_i      (L2_OUTPUT_LATENCY),
   //Outputs
   .addr_o               (l2_dataram_addr_num1),
   .wdata_o              (l2_dataram_wdata_num1),
   .enable_o             (l2_dataram_en_num1),
   .wr_en_o              (l2_dataram_wr_num1),
   .wrbyte_en_o          (l2_dataram_bw_en_num1),
   .clk_en_o             (l2_dataram_clk_en_num1),
   .bank_cnt_o           (l2_dataram_bank_cnt_num1),
   .l2dataram_way_o      (l2dataram_way_num1),
   .wdata_check_o        (l2_dataram_wdata_check_num1),
   .passed_o             (l2_dataram_passed_num1_o),
   .done_o               (l2_dataram_done_num1),
   .in_progress_o        (in_progress_num1),
   .dis_wren_o           (dis_wren_num1)
   );

   // Assign a different address to each bank.
  assign l2_dataram_addr_tst1   = {l2_dataram_addr_num1[(`L2DATARAM_ADDR_WIDTH -1):0],l2dataram_way_num1[2:0]};

  // Assign different write data to each bank.
  assign l2_dataram_wdata0_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0000}} & f_scramble_data(l2_dataram_wdata_num1, 0);
  assign l2_dataram_wdata1_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0001}} & f_scramble_data(l2_dataram_wdata_num1, 1);
  assign l2_dataram_wdata2_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0010}} & f_scramble_data(l2_dataram_wdata_num1, 2);
  assign l2_dataram_wdata3_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0011}} & f_scramble_data(l2_dataram_wdata_num1, 3);
  assign l2_dataram_wdata4_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0100}} & f_scramble_data(l2_dataram_wdata_num1, 4);
  assign l2_dataram_wdata5_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0101}} & f_scramble_data(l2_dataram_wdata_num1, 5);
  assign l2_dataram_wdata6_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0110}} & f_scramble_data(l2_dataram_wdata_num1, 6);
  assign l2_dataram_wdata7_tst1 = dis_wren_num1 ? {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}} : {`CA53_SCU_L2_DATARAM_DATA_W{l2_dataram_bank_cnt_num1 == 4'b0111}} & f_scramble_data(l2_dataram_wdata_num1, 7);

  assign l2_dataram_en_tst1 =  (l2_dataram_wr_num1 & !dis_wren_num1) ? l2dataram_wr_en_num1 : l2_dataram_en_num1;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2_dataram_done_num1_o <= 1'b0;
   else if (l2_dataram_done_num1)
     l2_dataram_done_num1_o <= l2_dataram_done_num1;

  always@(*)
   begin
     case(l2_dataram_bank_cnt_num1)
       4'b0000 : l2dataram_wr_en_num1 = 8'b00000001;
       4'b0001 : l2dataram_wr_en_num1 = 8'b00000010;
       4'b0010 : l2dataram_wr_en_num1 = 8'b00000100;
       4'b0011 : l2dataram_wr_en_num1 = 8'b00001000;
       4'b0100 : l2dataram_wr_en_num1 = 8'b00010000;
       4'b0101 : l2dataram_wr_en_num1 = 8'b00100000;
       4'b0110 : l2dataram_wr_en_num1 = 8'b01000000;
       4'b0111 : l2dataram_wr_en_num1 = 8'b10000000;
       default : l2dataram_wr_en_num1 = {8{1'bx}};
     endcase
   end

  //##########Test Number-2 Code###########
  //---------------------------------------

   ca53_l2dataramtest_number2   #(.RAM_ID          (`L2DATARAM_RAM_ID),        // Unique ID
                                  .ADDR_WIDTH      (`L2DATARAM_ADDR_WIDTH),    // Addr bits
                                  .RAM_TYPE        (`L2DATARAM_RAM_TYPE  ),    // RAM type
                                  .NUM_BANKS       (`L2DATARAM_NUM_BANKS),     // Number of Banks
                                  .BYTE_WIDTH      (`L2DATARAM_BYTE_WIDTH),       // Byte or bit granularity
                                  .WORD_WIDTH      (`CA53_SCU_L2_DATARAM_DATA_W), // width of RAM to test
                                  .NUM_STRBS       (`CA53_SCU_L2_DATARAM_EN_W),
                                  .CHK_LATENCY     (`L2DATARAM_CHECK_LATENCY),
                                  .L2_DATARAM_WAYS (`L2_DATARAM_WAYS)
  )  l2_data_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (l2_dataram_done_num1),
   .rdata_i           (l2_dataram_rdata),
   .max_range_i       (max_l2_dataram_range),
   .expected_data     (expected_dataram_wdata_num2),
   .l2_wr_latency_i   (L2_INPUT_LATENCY),
   .l2_rd_latency_i   (L2_OUTPUT_LATENCY),
   //Outputs
   .addr_o            (l2_dataram_addr_num2),
   .wdata_o           (l2_dataram_wdata_num2),
   .enable_o          (l2_dataram_en_num2),
   .wr_en_o           (l2_dataram_wr_num2),
   .wrbyte_en_o       (l2_dataram_bw_en_num2),
   .clk_en_o          (l2_dataram_clk_en_num2),
   .bank_cnt_o        (l2_dataram_bank_cnt_num2),
   .l2dataram_way_o   (l2dataram_way_num2),
   .wdata_check_o     (l2_dataram_wdata_check_num2),
   .passed_o          (l2_dataram_passed_num2_o),
   .done_o            (l2_dataram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2)
   );

   // Assign a different address to each bank.
  assign l2_dataram_addr_tst2   = {l2_dataram_addr_num2[(`L2DATARAM_ADDR_WIDTH -1):0],l2dataram_way_num2[2:0]};

  // Assign different write data to each bank.
  assign l2_dataram_wdata0_tst2 = l2_dataram_bank_cnt_num2 == 4'b0000 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata1_tst2 = l2_dataram_bank_cnt_num2 == 4'b0001 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata2_tst2 = l2_dataram_bank_cnt_num2 == 4'b0010 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata3_tst2 = l2_dataram_bank_cnt_num2 == 4'b0011 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata4_tst2 = l2_dataram_bank_cnt_num2 == 4'b0100 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata5_tst2 = l2_dataram_bank_cnt_num2 == 4'b0101 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata6_tst2 = l2_dataram_bank_cnt_num2 == 4'b0110 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};
  assign l2_dataram_wdata7_tst2 = l2_dataram_bank_cnt_num2 == 4'b0111 | reset_data_word_num2 ? l2_dataram_wdata_num2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b1}};

  assign l2_dataram_en_tst2     = l2_dataram_en_num2;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     l2_dataram_done_num2_o <= 1'b0;
   else if (l2_dataram_done_num2)
     l2_dataram_done_num2_o <= l2_dataram_done_num2;

 //##########Final Muxing###########
 //---------------------------------

 assign l2_dataram_addr_tst_out = in_progress_num1 ? l2_dataram_addr_tst1   : in_progress_num2 ? l2_dataram_addr_tst2   : {`CA53_SCU_L2_DATARAM_ADDR_W{1'b0}};
 
 assign l2_dataram_addr_o       = l2_dataram_wr_o  ? (~{max_l2_dataram_range,3'b111} | l2_dataram_addr_tst_out) : l2_dataram_addr_tst_out;

 assign l2_dataram_wdata0_o     = in_progress_num1 ? l2_dataram_wdata0_tst1 : in_progress_num2 ? l2_dataram_wdata0_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata1_o     = in_progress_num1 ? l2_dataram_wdata1_tst1 : in_progress_num2 ? l2_dataram_wdata1_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata2_o     = in_progress_num1 ? l2_dataram_wdata2_tst1 : in_progress_num2 ? l2_dataram_wdata2_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata3_o     = in_progress_num1 ? l2_dataram_wdata3_tst1 : in_progress_num2 ? l2_dataram_wdata3_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata4_o     = in_progress_num1 ? l2_dataram_wdata4_tst1 : in_progress_num2 ? l2_dataram_wdata4_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata5_o     = in_progress_num1 ? l2_dataram_wdata5_tst1 : in_progress_num2 ? l2_dataram_wdata5_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata6_o     = in_progress_num1 ? l2_dataram_wdata6_tst1 : in_progress_num2 ? l2_dataram_wdata6_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
 assign l2_dataram_wdata7_o     = in_progress_num1 ? l2_dataram_wdata7_tst1 : in_progress_num2 ? l2_dataram_wdata7_tst2 : {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};

 assign l2_dataram_en_o         = in_progress_num1 ? l2_dataram_en_tst1     : in_progress_num2 ? l2_dataram_en_tst2	: {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};

 generate if (L2_INPUT_LATENCY == 1'b0) begin : bit_or_clken
   assign l2_dataram_clken_o      = in_progress_num1 ? l2_dataram_clk_en_num1 : in_progress_num2 ? l2_dataram_clk_en_num2 : {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};
 end else begin : clken
   assign l2_dataram_clken_o      = in_progress_num1 ? {`CA53_SCU_L2_DATARAM_EN_W{(|l2_dataram_clk_en_num1)}} : in_progress_num2 ? {`CA53_SCU_L2_DATARAM_EN_W{(|l2_dataram_clk_en_num2)}} : {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};
 end
 endgenerate
 
 assign l2_dataram_wr_o         = in_progress_num1 ? l2_dataram_wr_num1     : in_progress_num2 ? l2_dataram_wr_num2	:  1'b0;

 assign l2_dataram_no_acc_next_cycle_o = ~(in_progress_num1 | in_progress_num2);
 
 //Checker Case Statement for Test-1
 assign dataram_wdata_check0_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 0);
 assign dataram_wdata_check1_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 1);
 assign dataram_wdata_check2_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 2);
 assign dataram_wdata_check3_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 3);
 assign dataram_wdata_check4_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 4);
 assign dataram_wdata_check5_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 5);
 assign dataram_wdata_check6_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 6);
 assign dataram_wdata_check7_num1 = f_scramble_data(l2_dataram_wdata_check_num1, 7);

 assign expected_dataram_wdata_num1 = {dataram_wdata_check7_num1, dataram_wdata_check6_num1, dataram_wdata_check5_num1, dataram_wdata_check4_num1,
                                       dataram_wdata_check3_num1, dataram_wdata_check2_num1, dataram_wdata_check1_num1, dataram_wdata_check0_num1};


 //Checker Case Statement for Test-2
 always@(*)
   begin
     dataram_wdata_check0_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check1_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check2_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check3_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check4_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check5_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check6_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     dataram_wdata_check7_num2 = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
     case (l2_dataram_bank_cnt_num2)
       4'b0000 : dataram_wdata_check0_num2 = l2_dataram_wdata_check_num2;
       4'b0001 : dataram_wdata_check1_num2 = l2_dataram_wdata_check_num2;
       4'b0010 : dataram_wdata_check2_num2 = l2_dataram_wdata_check_num2;
       4'b0011 : dataram_wdata_check3_num2 = l2_dataram_wdata_check_num2;
       4'b0100 : dataram_wdata_check4_num2 = l2_dataram_wdata_check_num2;
       4'b0101 : dataram_wdata_check5_num2 = l2_dataram_wdata_check_num2;
       4'b0110 : dataram_wdata_check6_num2 = l2_dataram_wdata_check_num2;
       4'b0111 : dataram_wdata_check7_num2 = l2_dataram_wdata_check_num2;
     endcase
   end

 assign expected_dataram_wdata_num2 = {dataram_wdata_check7_num2, dataram_wdata_check6_num2, dataram_wdata_check5_num2, dataram_wdata_check4_num2,
                                       dataram_wdata_check3_num2, dataram_wdata_check2_num2, dataram_wdata_check1_num2, dataram_wdata_check0_num2};

endmodule
