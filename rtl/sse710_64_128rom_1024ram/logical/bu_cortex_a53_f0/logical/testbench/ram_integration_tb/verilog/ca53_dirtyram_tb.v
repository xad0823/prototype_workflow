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

module ca53_dirtyram_tb #(parameter CPU_CACHE_PROTECTION  = 1'b0)
(
  output wire                                dc_dirtyram_en_o,
  output wire                                dc_dirtyram_wr_o,
  output wire [(`CA53_DDIRTY_RAM_W-1):0]     dc_dirtyram_strb_o,
  output wire [(`CA53_DDIRTY_RAM_W-1):0]     dc_dirtyram_wdata_o,
  output wire [8:0]                          dc_dirtyram_addr_o,
  input  wire [(`CA53_DDIRTY_RAM_W-1):0]     dc_dirtyram_rdata_i,

  output wire                                dc_dirtyram_passed_num1_o,
  output wire                                dc_dirtyram_passed_num2_o,
  output wire                                dc_dirtyram_passed_num3_o,
  output reg                                 dc_dirtyram_done_num1_o,
  output reg                                 dc_dirtyram_done_num2_o,
  output reg                                 dc_dirtyram_done_num3_o,
  input  wire                                clk,
  input  wire                                reset_n,
  input  wire [8:0]                          max_dirtyram_range,
  input  wire                                test_start_i
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
      f_scramble_data = f_scramble_byte(data[7:0]  , bank);
    end
  endfunction

   function [19:0] f_wdata_check;
    input [0:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check = {{19{1'b0}} , data};
           5'b00001 : f_wdata_check = {{18{1'b0}} , data, {1{1'b0}}};
           5'b00010 : f_wdata_check = {{17{1'b0}} , data, {2{1'b0}}};
           5'b00011 : f_wdata_check = {{16{1'b0}} , data, {3{1'b0}}};
           5'b00100 : f_wdata_check = {{15{1'b0}} , data, {4{1'b0}}};
           5'b00101 : f_wdata_check = {{14{1'b0}} , data, {5{1'b0}}};
           5'b00110 : f_wdata_check = {{13{1'b0}} , data, {6{1'b0}}};
           5'b00111 : f_wdata_check = {{12{1'b0}} , data, {7{1'b0}}};
           5'b01000 : f_wdata_check = {{11{1'b0}} , data, {8{1'b0}}};
           5'b01001 : f_wdata_check = {{10{1'b0}} , data, {9{1'b0}}};
           5'b01010 : f_wdata_check = {{ 9{1'b0}} , data, {10{1'b0}}};
           5'b01011 : f_wdata_check = {{ 8{1'b0}} , data, {11{1'b0}}};
           5'b01100 : f_wdata_check = {{ 7{1'b0}} , data, {12{1'b0}}};
           5'b01101 : f_wdata_check = {{ 6{1'b0}} , data, {13{1'b0}}};
           5'b01110 : f_wdata_check = {{ 5{1'b0}} , data, {14{1'b0}}};
           5'b01111 : f_wdata_check = {{ 4{1'b0}} , data, {15{1'b0}}};
           5'b10000 : f_wdata_check = {{ 3{1'b0}} , data, {16{1'b0}}};
           5'b10001 : f_wdata_check = {{ 2{1'b0}} , data, {17{1'b0}}};
           5'b10010 : f_wdata_check = {{ 1{1'b0}} , data, {18{1'b0}}};
           5'b10011 : f_wdata_check = {             data, {19{1'b0}}};
           default : f_wdata_check = {20{1'bx}};
         endcase
    end
  endfunction

  //DirtyRam TB
  //------------

  wire [((`CA53_DDIRTY_RAM_W * `DDIRTYRAM_NUM_BANKS) -1):0] dc_dirtyram_rdata;
  wire                                                      reset_data_word_num2;
  wire [8:0]                                                dc_dirtyram_addr_tst_out;
 
  //Test Number-1 Declarations
  wire                                                      dc_dirtyram_done_num1;
  wire [3:0]                                                dc_dirtyram_bank_cnt_num1;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_num1;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_num1;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_check_num1;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_num1;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_bw_en_num1;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_tst1;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_tst1;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_strb_tst1;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_tst1;
  wire                                                      dc_dirtyram_wr_num1;
  wire [((`CA53_DDIRTY_RAM_W * `DDIRTYRAM_NUM_BANKS) -1):0] expected_dirtyram_wdata_num1;
  wire                                                      in_progress_num1;

  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check0_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check1_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check2_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check3_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check4_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check5_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check6_num1;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check7_num1;

  //Test Number-2 Declarations
  wire                                                      dc_dirtyram_done_num2;
  wire [3:0]                                                dc_dirtyram_bank_cnt_num2;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_num2;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_num2;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_check_num2;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_num2;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_bw_en_num2;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_tst2;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_tst2;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_strb_tst2;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_tst2;
  wire                                                      dc_dirtyram_wr_num2;
  wire [((`CA53_DDIRTY_RAM_W * `DDIRTYRAM_NUM_BANKS) -1):0] expected_dirtyram_wdata_num2;
  wire                                                      in_progress_num2;

  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check0_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check1_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check2_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check3_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check4_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check5_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check6_num2;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check7_num2;

  //Test Number-3 Declarations
  wire                                                      dc_dirtyram_done_num3;
  wire [3:0]                                                dc_dirtyram_bank_cnt_num3;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_num3;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_num3;
  wire [(`DDIRTYRAM_BYTE_WIDTH -1)  :0]                     dc_dirtyram_wdata_check_num3;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_num3;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_bw_en_num3;
  wire [(`DDIRTYRAM_ADDR_WIDTH -1)  :0]                     dc_dirtyram_addr_tst3;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_wdata_tst3;
  wire [(`CA53_DDIRTY_RAM_W -1)     :0]                     dc_dirtyram_strb_tst3;
  wire [(`DDIRTYRAM_NUM_BANKS -1)   :0]                     dc_dirtyram_en_tst3;
  wire                                                      dc_dirtyram_wr_num3;
  wire                                                      in_progress_num3;

  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check0_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check1_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check2_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check3_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check4_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check5_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check6_num3;
  reg [(`CA53_DDIRTY_RAM_W -1)      :0]                     dirtyram_wdata_check7_num3;

  //########### Generic Code for all test#######
  //--------------------------------------------

  assign dc_dirtyram_rdata = dc_dirtyram_rdata_i;

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `DDIRTYRAM_RAM_ID),        // Unique ID
                             .ADDR_WIDTH ( `DDIRTYRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DDIRTYRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DDIRTYRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DDIRTYRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DDIRTY_RAM_W),        // width of RAM to test
                             .NUM_STRBS  ( `CA53_DDIRTY_RAM_W),
                             .CHK_LATENCY( `DDIRTYRAM_CHECK_LATENCY)
  ) dirty_ramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),       // dc_startstate[0]
   .rdata_i       (dc_dirtyram_rdata),
   .max_range_i   (max_dirtyram_range),
   .expected_data (expected_dirtyram_wdata_num1),
   //Outputs
   .addr_o        (dc_dirtyram_addr_num1),
   .wdata_o       (dc_dirtyram_wdata_num1),
   .enable_o      (dc_dirtyram_en_num1),
   .wr_en_o       (dc_dirtyram_wr_num1),
   .wrbyte_en_o   (dc_dirtyram_bw_en_num1),
   .bank_cnt_o    (dc_dirtyram_bank_cnt_num1),
   .wdata_check_o (dc_dirtyram_wdata_check_num1),
   .passed_o      (dc_dirtyram_passed_num1_o),
   .done_o        (dc_dirtyram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

   // Assign a different address to each bank.
  assign dc_dirtyram_addr_tst1 =  dc_dirtyram_addr_num1;

  // Assign different write data to each bank.
  assign dc_dirtyram_wdata_tst1 = f_scramble_data(dc_dirtyram_wdata_num1, 0);

 // STRBS are only set if the banks are enabled
  assign dc_dirtyram_strb_tst1 = dc_dirtyram_bw_en_num1 & {`CA53_DDIRTY_RAM_W{dc_dirtyram_en_num1[0]}};

  assign dc_dirtyram_en_tst1 = dc_dirtyram_en_num1;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     dc_dirtyram_done_num1_o <= 1'b0;
   else if (dc_dirtyram_done_num1)
     dc_dirtyram_done_num1_o <= dc_dirtyram_done_num1;

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `DDIRTYRAM_RAM_ID),        // Unique ID
                             .ADDR_WIDTH ( `DDIRTYRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DDIRTYRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DDIRTYRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DDIRTYRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DDIRTY_RAM_W),        // width of RAM to test
                             .NUM_STRBS  ( `CA53_DDIRTY_RAM_W),
                             .CHK_LATENCY( `DDIRTYRAM_CHECK_LATENCY)
  ) dirty_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (dc_dirtyram_done_num1),
   .rdata_i           (dc_dirtyram_rdata),
   .max_range_i       (max_dirtyram_range),
   .expected_data     (expected_dirtyram_wdata_num2),
   //Outputs
   .addr_o            (dc_dirtyram_addr_num2),
   .wdata_o           (dc_dirtyram_wdata_num2),
   .enable_o          (dc_dirtyram_en_num2),
   .wr_en_o           (dc_dirtyram_wr_num2),
   .wrbyte_en_o       (dc_dirtyram_bw_en_num2),
   .bank_cnt_o        (dc_dirtyram_bank_cnt_num2),
   .wdata_check_o     (dc_dirtyram_wdata_check_num2),
   .passed_o          (dc_dirtyram_passed_num2_o),
   .done_o            (dc_dirtyram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

  // Assign same address as we are only testing address-0
  assign dc_dirtyram_addr_tst2 =  dc_dirtyram_addr_num2;

  // Assign different write data to each bank.
  assign dc_dirtyram_wdata_tst2 = dc_dirtyram_wdata_num2;

  // STRBS are only set if the banks are enabled
  assign dc_dirtyram_strb_tst2 = dc_dirtyram_bw_en_num2;

  assign dc_dirtyram_en_tst2 = dc_dirtyram_en_num2;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     dc_dirtyram_done_num2_o <= 1'b0;
   else if (dc_dirtyram_done_num2)
     dc_dirtyram_done_num2_o <= dc_dirtyram_done_num2;

  //##########Test Number-3 Code###########
  //---------------------------------------

  ca53_rambittest_number3   #(.RAM_ID     ( `DDIRTYRAM_RAM_ID),       // Unique ID
                              .ADDR_WIDTH ( `DDIRTYRAM_ADDR_WIDTH),   // Addr bits
                              .RAM_TYPE   ( `DDIRTYRAM_RAM_TYPE  ),   // RAM type
                              .NUM_BANKS  ( `DDIRTYRAM_NUM_BANKS),    // Number of Banks
                              .BYTE_WIDTH ( `DDIRTYRAM_BYTE_WIDTH),   // Byte or bit granularity
                              .WORD_WIDTH ( `CA53_DDIRTY_RAM_W),        // width of RAM to test
                              .NUM_STRBS  ( `CA53_DDIRTY_RAM_W),
                              .CHK_LATENCY( `DDIRTYRAM_CHECK_LATENCY)
  ) dirty_ramtest_number3
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (dc_dirtyram_done_num2),
   .rdata_i       (dc_dirtyram_rdata),
   .max_range_i   (max_dirtyram_range),
   //Outputs
   .addr_o        (dc_dirtyram_addr_num3),
   .wdata_o       (dc_dirtyram_wdata_num3),
   .enable_o      (dc_dirtyram_en_num3),
   .wr_en_o       (dc_dirtyram_wr_num3),
   .wrbyte_en_o   (dc_dirtyram_bw_en_num3),
   .bank_cnt_o    (dc_dirtyram_bank_cnt_num3),
   .passed_o      (dc_dirtyram_passed_num3_o),
   .done_o        (dc_dirtyram_done_num3),
   .in_progress_o (in_progress_num3)
   );

  // Assign same address as we are only testing address-0
  assign dc_dirtyram_addr_tst3 =  dc_dirtyram_addr_num3;

  // Assign different write data to each bank.
  assign dc_dirtyram_wdata_tst3 = dc_dirtyram_wdata_num3;

  // STRBS are only set if the banks are enabled
  assign dc_dirtyram_strb_tst3 = dc_dirtyram_bw_en_num3 & {`CA53_DDIRTY_RAM_W{dc_dirtyram_en_num3[0]}};

  assign dc_dirtyram_en_tst3 = dc_dirtyram_en_num3;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     dc_dirtyram_done_num3_o <= 1'b0;
   else if (dc_dirtyram_done_num3)
     dc_dirtyram_done_num3_o <= dc_dirtyram_done_num3;

  //##########Final Muxing###########
  //---------------------------------

  assign dc_dirtyram_addr_tst_out  = in_progress_num1 ? dc_dirtyram_addr_tst1  : in_progress_num2 ? dc_dirtyram_addr_tst2  : in_progress_num3 ? dc_dirtyram_addr_tst3  : {8{1'b0}};

  assign dc_dirtyram_addr_o        = dc_dirtyram_wr_o ? (~max_dirtyram_range | dc_dirtyram_addr_tst_out) : dc_dirtyram_addr_tst_out;
  
  assign dc_dirtyram_wdata_o       = in_progress_num1 ? dc_dirtyram_wdata_tst1 : in_progress_num2 ? dc_dirtyram_wdata_tst2 : in_progress_num3 ? dc_dirtyram_wdata_tst3 : {`CA53_DDIRTY_RAM_W{1'b0}};

  assign dc_dirtyram_strb_o        = in_progress_num1 ? dc_dirtyram_strb_tst1  : in_progress_num2 ? dc_dirtyram_strb_tst2  : in_progress_num3 ? dc_dirtyram_strb_tst3  : {`CA53_DDIRTY_RAM_W{1'b0}};

  assign dc_dirtyram_en_o          = in_progress_num1 ? dc_dirtyram_en_tst1    : in_progress_num2 ? dc_dirtyram_en_tst2    : in_progress_num3 ? dc_dirtyram_en_tst3    :  1'b0;

  assign dc_dirtyram_wr_o          = in_progress_num1 ? dc_dirtyram_wr_num1    : in_progress_num2 ? dc_dirtyram_wr_num2    : in_progress_num3 ? dc_dirtyram_wr_num3    :  1'b0;


  //Checker Case Statement for Test-1
 always@(*)
   begin
     dirtyram_wdata_check0_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check1_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check2_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check3_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check4_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check5_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check6_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check7_num1 = {`CA53_DDIRTY_RAM_W{1'b0}};
     case (dc_dirtyram_bank_cnt_num1)
       4'b0000 : dirtyram_wdata_check0_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 0);
       4'b0001 : dirtyram_wdata_check1_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 1);
       4'b0010 : dirtyram_wdata_check2_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 2);
       4'b0011 : dirtyram_wdata_check3_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 3);
       4'b0100 : dirtyram_wdata_check4_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 4);
       4'b0101 : dirtyram_wdata_check5_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 5);
       4'b0110 : dirtyram_wdata_check6_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 6);
       4'b0111 : dirtyram_wdata_check7_num1 = f_scramble_data(dc_dirtyram_wdata_check_num1, 7);
     endcase
   end

 assign expected_dirtyram_wdata_num1 = dirtyram_wdata_check0_num1;

  //Checker Case Statement for Test-2
 always@(*)
   begin
     dirtyram_wdata_check0_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check1_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check2_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check3_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check4_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check5_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check6_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     dirtyram_wdata_check7_num2 = {`CA53_DDIRTY_RAM_W{1'b0}};
     case (dc_dirtyram_bank_cnt_num2)
       4'b0000 : dirtyram_wdata_check0_num2 = dc_dirtyram_wdata_check_num2;
       4'b0001 : dirtyram_wdata_check1_num2 = dc_dirtyram_wdata_check_num2;
       4'b0010 : dirtyram_wdata_check2_num2 = dc_dirtyram_wdata_check_num2;
       4'b0011 : dirtyram_wdata_check3_num2 = dc_dirtyram_wdata_check_num2;
       4'b0100 : dirtyram_wdata_check4_num2 = dc_dirtyram_wdata_check_num2;
       4'b0101 : dirtyram_wdata_check5_num2 = dc_dirtyram_wdata_check_num2;
       4'b0110 : dirtyram_wdata_check6_num2 = dc_dirtyram_wdata_check_num2;
       4'b0111 : dirtyram_wdata_check7_num2 = dc_dirtyram_wdata_check_num2;
     endcase
   end

  assign expected_dirtyram_wdata_num2 = dirtyram_wdata_check0_num2;


endmodule
