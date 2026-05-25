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

module ca53_d_tagram_tb #(parameter CPU_CACHE_PROTECTION  = 1'b0)
(
  output wire [3:0]                          dc_tagram_en_o,
  output wire                                dc_tagram_wr_o,
  output wire [(`CA53_DTAG_RAM_W-1):0]       dc_tagram_wdata_o,
  output wire [7:0]                          dc_tagram_addr_o,
  input  wire [(`CA53_DTAG_RAM_W-1):0]       dc_tagram_rdata0_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]       dc_tagram_rdata1_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]       dc_tagram_rdata2_i,
  input  wire [(`CA53_DTAG_RAM_W-1):0]       dc_tagram_rdata3_i,

  output wire                                dc_tagram_passed_num1_o,
  output wire                                dc_tagram_passed_num2_o,
  output reg                                 dc_tagram_done_num1_o,
  output reg                                 dc_tagram_done_num2_o,
  input  wire                                clk,
  input  wire                                reset_n,
  input  wire [`CA53_L1DC_SIZE_W-1:0]        dc_size_i,
  input  wire [7:0]                          max_d_tagram_range,
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
      f_scramble_data = {f_scramble_byte(data[31:24], bank),
                         f_scramble_byte(data[23:16], bank),
                         f_scramble_byte(data[15:8] , bank),
                         f_scramble_byte(data[7:0]  , bank)};
    end
  endfunction

  //D-TagRam TB
  //------------

  wire [((`CA53_DTAG_RAM_W * `DTAGRAM_NUM_BANKS) -1):0] dc_tagram_rdata;
  wire [7:0]                                            dc_tagram_addr_tst_out;
  
   //Test Number-1 Declarations
  wire                                                  dc_tagram_done_num1;
  wire [3:0]                                            dc_tagram_bank_cnt_num1;
  wire [(`DTAGRAM_ADDR_WIDTH -1)                    :0] dc_tagram_addr_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_check_num1;
  wire [(`DTAGRAM_NUM_BANKS -1)                     :0] dc_tagram_en_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] tagram_wdata_check0_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] tagram_wdata_check1_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] tagram_wdata_check2_num1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] tagram_wdata_check3_num1;
  wire [((`CA53_DTAG_RAM_W * `DTAGRAM_NUM_BANKS) -1):0] expected_tagram_wdata_num1;
  wire                                                  dc_tagram_wr_num1;
  wire [(`DTAGRAM_ADDR_WIDTH -1)                    :0] dc_tagram_addr_tst1;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_tst1;
  wire [(`DTAGRAM_NUM_BANKS -1)                     :0] dc_tagram_en_tst1;
  wire                                                  in_progress_num1;

  reg [(`DTAGRAM_NUM_BANKS -1) :0]                      dc_tagram_wr_en_num1;

   //Test Number-2 Declarations
  wire                                                  dc_tagram_done_num2;
  wire [3:0]                                            dc_tagram_bank_cnt_num2;
  wire [(`DTAGRAM_ADDR_WIDTH -1)                    :0] dc_tagram_addr_num2;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_num2;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_check_num2;
  wire [(`DTAGRAM_NUM_BANKS -1)                     :0] dc_tagram_en_num2;
  wire [((`CA53_DTAG_RAM_W * `DTAGRAM_NUM_BANKS) -1):0] expected_tagram_wdata_num2;
  wire                                                  dc_tagram_wr_num2;
  wire [(`DTAGRAM_ADDR_WIDTH -1)                    :0] dc_tagram_addr_tst2;
  wire [(`CA53_DTAG_RAM_W -1)                       :0] dc_tagram_wdata_tst2;
  wire [(`DTAGRAM_NUM_BANKS -1)                     :0] dc_tagram_en_tst2;
  wire                                                  in_progress_num2;
  wire                                                  reset_data_word_num2;

  reg [(`CA53_DTAG_RAM_W -1)                        :0] tagram_wdata_check0_num2;
  reg [(`CA53_DTAG_RAM_W -1)                        :0] tagram_wdata_check1_num2;
  reg [(`CA53_DTAG_RAM_W -1)                        :0] tagram_wdata_check2_num2;
  reg [(`CA53_DTAG_RAM_W -1)                        :0] tagram_wdata_check3_num2;
  reg [(`DTAGRAM_NUM_BANKS -1)                      :0] dc_tagram_wr_en_num2;


  //########### Generic Code for all test#######
  //--------------------------------------------
  // mask bottom bits of the tag based on the cache size
  wire [`CA53_DTAG_RAM_W-1:0]                           tag_mask;

  assign tag_mask[`CA53_DTAG_RAM_W-1:`CA53_L1DC_SIZE_W] = {`CA53_DTAG_RAM_W-`CA53_L1DC_SIZE_W{1'b1}};
  assign tag_mask[`CA53_L1DC_SIZE_W-1:0]                = ~dc_size_i;

  assign dc_tagram_rdata = {dc_tagram_rdata3_i, dc_tagram_rdata2_i, dc_tagram_rdata1_i, dc_tagram_rdata0_i};

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `DTAGRAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `DTAGRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DTAGRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DTAGRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DTAGRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DTAG_RAM_W),        // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `DTAGRAM_CHECK_LATENCY)
  )  dtag_ramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (dc_tagram_rdata),
   .max_range_i   (max_d_tagram_range),
   .expected_data (expected_tagram_wdata_num1),
   //Outputs
   .addr_o        (dc_tagram_addr_num1),
   .wdata_o       (dc_tagram_wdata_num1),
   .enable_o      (dc_tagram_en_num1),
   .wr_en_o       (dc_tagram_wr_num1),
   .wrbyte_en_o   ( ),
   .bank_cnt_o    (dc_tagram_bank_cnt_num1),
   .wdata_check_o (dc_tagram_wdata_check_num1),
   .passed_o      (dc_tagram_passed_num1_o),
   .done_o        (dc_tagram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

   // Assign a different address to each bank.
  assign dc_tagram_addr_tst1   = dc_tagram_addr_num1;

  // Assign different write data to each bank.
  assign dc_tagram_wdata_tst1 = f_scramble_data(dc_tagram_wdata_num1, dc_tagram_bank_cnt_num1);

  assign dc_tagram_en_tst1 =  dc_tagram_wr_num1 ? dc_tagram_wr_en_num1 : dc_tagram_en_num1;

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     dc_tagram_done_num1_o <= 1'b0;
   else if (dc_tagram_done_num1)
     dc_tagram_done_num1_o <= dc_tagram_done_num1;

  always@(*)
   begin
     case(dc_tagram_bank_cnt_num1)
       4'b0000 : dc_tagram_wr_en_num1 = 4'b0001;
       4'b0001 : dc_tagram_wr_en_num1 = 4'b0010;
       4'b0010 : dc_tagram_wr_en_num1 = 4'b0100;
       4'b0011 : dc_tagram_wr_en_num1 = 4'b1000;
       default : dc_tagram_wr_en_num1 = {4{1'bx}};
     endcase
   end

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `DTAGRAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `DTAGRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DTAGRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DTAGRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DTAGRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DTAG_RAM_W),        // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `DTAGRAM_CHECK_LATENCY)
  )  dtag_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (dc_tagram_done_num1),
   .rdata_i           (dc_tagram_rdata),
   .max_range_i       (max_d_tagram_range),
   .expected_data     (expected_tagram_wdata_num2),
   //Outputs
   .addr_o            (dc_tagram_addr_num2),
   .wdata_o           (dc_tagram_wdata_num2),
   .enable_o          (dc_tagram_en_num2),
   .wr_en_o           (dc_tagram_wr_num2),
   .wrbyte_en_o       ( ),
   .bank_cnt_o        (dc_tagram_bank_cnt_num2),
   .wdata_check_o     (dc_tagram_wdata_check_num2),
   .passed_o          (dc_tagram_passed_num2_o),
   .done_o            (dc_tagram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

   // Assign a different address to each bank.
  assign dc_tagram_addr_tst2  = dc_tagram_addr_num2;

  // Assign different write data to each bank.
  assign dc_tagram_wdata_tst2 = dc_tagram_wdata_num2;

  assign dc_tagram_en_tst2    = (dc_tagram_wdata_num2 == {`CA53_DTAG_RAM_W{1'b0}} | dc_tagram_en_num2 == {`DTAGRAM_NUM_BANKS{1'b0}})? dc_tagram_en_num2 : (dc_tagram_wr_num2 ? dc_tagram_wr_en_num2 : dc_tagram_en_num2);

   //Registering the Done signal
  always @(posedge clk or negedge reset_n)
   if (~reset_n)
     dc_tagram_done_num2_o <= 1'b0;
   else if (dc_tagram_done_num2)
     dc_tagram_done_num2_o <= dc_tagram_done_num2;

  always@(*)
   begin
     case(dc_tagram_bank_cnt_num2)
       4'b0000 : dc_tagram_wr_en_num2 = 4'b0001;
       4'b0001 : dc_tagram_wr_en_num2 = 4'b0010;
       4'b0010 : dc_tagram_wr_en_num2 = 4'b0100;
       4'b0011 : dc_tagram_wr_en_num2 = 4'b1000;
       default : dc_tagram_wr_en_num2 = {4{1'bx}};
     endcase
   end

  //##########Final Muxing###########
  //---------------------------------

 assign dc_tagram_addr_tst_out   = in_progress_num1 ? dc_tagram_addr_tst1  : in_progress_num2 ? dc_tagram_addr_tst2  : {8{1'b0}};
 
 assign dc_tagram_addr_o         = dc_tagram_wr_o ? (~max_d_tagram_range | dc_tagram_addr_tst_out) : dc_tagram_addr_tst_out;
 
 assign dc_tagram_wdata_o        = tag_mask & (in_progress_num1 ? dc_tagram_wdata_tst1 : in_progress_num2 ? dc_tagram_wdata_tst2 : {`CA53_DTAG_RAM_W{1'b0}});

 assign dc_tagram_en_o           = in_progress_num1 ? dc_tagram_en_tst1    : in_progress_num2 ? dc_tagram_en_tst2    : {4{1'b0}};

 assign dc_tagram_wr_o           = in_progress_num1 ? dc_tagram_wr_num1    : in_progress_num2 ? dc_tagram_wr_num2    :  1'b0;

 //Checker Case Statement for Test-1
 assign tagram_wdata_check0_num1 = f_scramble_data(dc_tagram_wdata_check_num1, 0);
 assign tagram_wdata_check1_num1 = f_scramble_data(dc_tagram_wdata_check_num1, 1);
 assign tagram_wdata_check2_num1 = f_scramble_data(dc_tagram_wdata_check_num1, 2);
 assign tagram_wdata_check3_num1 = f_scramble_data(dc_tagram_wdata_check_num1, 3);

 assign expected_tagram_wdata_num1 = {tagram_wdata_check3_num1, tagram_wdata_check2_num1, tagram_wdata_check1_num1, tagram_wdata_check0_num1} &
                                     {tag_mask                , tag_mask                , tag_mask                , tag_mask};

 //Checker Case Statement for Test-2
 always@(*)
   begin
     tagram_wdata_check0_num2 = {`CA53_DTAG_RAM_W{1'b0}};
     tagram_wdata_check1_num2 = {`CA53_DTAG_RAM_W{1'b0}};
     tagram_wdata_check2_num2 = {`CA53_DTAG_RAM_W{1'b0}};
     tagram_wdata_check3_num2 = {`CA53_DTAG_RAM_W{1'b0}};
     case (dc_tagram_bank_cnt_num2)
       4'b0000 : tagram_wdata_check0_num2 = dc_tagram_wdata_check_num2;
       4'b0001 : tagram_wdata_check1_num2 = dc_tagram_wdata_check_num2;
       4'b0010 : tagram_wdata_check2_num2 = dc_tagram_wdata_check_num2;
       4'b0011 : tagram_wdata_check3_num2 = dc_tagram_wdata_check_num2;
     endcase
   end

 assign expected_tagram_wdata_num2 = {tagram_wdata_check3_num2, tagram_wdata_check2_num2, tagram_wdata_check1_num2, tagram_wdata_check0_num2} &
                                     {tag_mask                , tag_mask                , tag_mask                , tag_mask};



endmodule
