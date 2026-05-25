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

module ca53_btacram_stg1_tb (
  input  wire [(`CA53_BTAC_RAM_S1D_W-1) :0]  btac_stg1_ram_rdata_i,
  output wire                                btac_stg1_ram_en_o,
  output wire                                btac_stg1_ram_wr_o,
  output wire [(`CA53_BTAC_RAM_S1D_W-1) :0]  btac_stg1_ram_wdata_o,
  output wire [(`CA53_BTAC_RAM_ADDR_W-1):0]  btac_stg1_ram_addr_o,

  output wire                                btacram_passed_num1_o,
  output wire                                btacram_passed_num2_o,
  output reg                                 btacram_done_num1_o,
  output reg                                 btacram_done_num2_o,
  input  wire                                clk,
  input  wire                                reset_n,
  input  wire [6:0]                          max_btacram_range,
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

  //BTACRam TB
  //------------
  wire [((`CA53_BTAC_RAM_S1D_W * `BTACRAM_NUM_BANKS) -1):0] btacram_rdata;
  wire [(`CA53_BTAC_RAM_ADDR_W-1):0]                        btac_stg1_ram_addr_tst_out;
  //Test Number-1 Declarations
  wire                                                      btacram_done_num1;
  wire [3:0]                                                btacram_bank_cnt_num1;
  wire [(`BTACRAM_ADDR_WIDTH -1)      :0]                   btacram_addr_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check_num1;
  wire [(`BTACRAM_NUM_BANKS -1)       :0]                   btacram_en_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check0_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check1_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check2_num1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check3_num1;
  wire [((`CA53_BTAC_RAM_S1D_W * `BTACRAM_NUM_BANKS) -1):0] expected_btacram_wdata_num1;
  wire                                                      in_progress_num1;
  wire [(`CA53_BTAC_RAM_ADDR_W-1)     :0]                   btac_ram_addr_tst1;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btac_ram_wdata_tst1;
  wire [(`BTACRAM_NUM_BANKS - 1)      :0]                   btac_ram_en_tst1;
  wire                                                      btac_ram_wr_num1;

  reg  [3:0]                                                btacram_wr_en_num1;

  //Test Number-2 Declarations

  wire                                                      btacram_done_num2;
  wire [3:0]                                                btacram_bank_cnt_num2;
  wire [(`BTACRAM_ADDR_WIDTH -1)      :0]                   btacram_addr_num2;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_num2;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check_num2;
  wire [(`BTACRAM_NUM_BANKS -1)       :0]                   btacram_en_num2;
  wire [((`CA53_BTAC_RAM_S1D_W * `BTACRAM_NUM_BANKS) -1):0] expected_btacram_wdata_num2;
  wire                                                      in_progress_num2;
  wire [(`CA53_BTAC_RAM_ADDR_W-1)     :0]                   btac_ram_addr_tst2;
  wire [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btac_ram_wdata_tst2;
  wire [(`BTACRAM_NUM_BANKS - 1)      :0]                   btac_ram_en_tst2;
  wire                                                      btac_ram_wr_num2;
  wire                                                      reset_data_word_num2;

  reg  [3:0]                                                btacram_wr_en_num2;
  reg  [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check0_num2;
  reg  [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check1_num2;
  reg  [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check2_num2;
  reg  [(`CA53_BTAC_RAM_S1D_W -1)     :0]                   btacram_wdata_check3_num2;

  //########### Generic Code for all test#######
  //--------------------------------------------

  assign btacram_rdata = btac_stg1_ram_rdata_i;

  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `BTACRAM_RAM_STG1_ID),   // Unique ID
                             .ADDR_WIDTH ( `BTACRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `BTACRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `BTACRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `BTACRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_BTAC_RAM_S1D_W),        // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `BTACRAM_CHECK_LATENCY)
  ) btac_ramtest_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (btacram_rdata),
   .max_range_i   (max_btacram_range),
   .expected_data (expected_btacram_wdata_num1),
   //Outputs
   .addr_o        (btacram_addr_num1),
   .wdata_o       (btacram_wdata_num1),
   .enable_o      (btacram_en_num1),
   .wr_en_o       (btac_ram_wr_num1),
   .wrbyte_en_o   ( ),
   .bank_cnt_o    (btacram_bank_cnt_num1),
   .wdata_check_o (btacram_wdata_check_num1),
   .passed_o      (btacram_passed_num1_o),
   .done_o        (btacram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

   // Assign a different address to each bank.
  assign btac_ram_addr_tst1   = btacram_addr_num1;

  // Assign different write data to each bank.
  assign btac_ram_wdata_tst1 = f_scramble_data(btacram_wdata_num1, btacram_bank_cnt_num1);

  assign btac_ram_en_tst1 =  btac_ram_wr_num1 ? btacram_wr_en_num1[(`BTACRAM_NUM_BANKS - 1):0] : btacram_en_num1[(`BTACRAM_NUM_BANKS - 1):0];

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      btacram_done_num1_o <= 1'b0;
    else if (btacram_done_num1)
      btacram_done_num1_o <= btacram_done_num1;

  always@(*)
   begin
     case(btacram_bank_cnt_num1)
       4'b0000 : btacram_wr_en_num1 = 4'b0001;
       4'b0001 : btacram_wr_en_num1 = 4'b0010;
       4'b0010 : btacram_wr_en_num1 = 4'b0100;
       4'b0011 : btacram_wr_en_num1 = 4'b1000;
       default : btacram_wr_en_num1 = {4{1'bx}};
     endcase
   end

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `BTACRAM_RAM_STG1_ID),   // Unique ID
                             .ADDR_WIDTH ( `BTACRAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `BTACRAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `BTACRAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `BTACRAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_BTAC_RAM_S1D_W),        // width of RAM to test
                             .NUM_STRBS  ( ),
                             .CHK_LATENCY( `BTACRAM_CHECK_LATENCY)
  ) btac_ramtest_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (btacram_done_num1),
   .rdata_i           (btacram_rdata),
   .max_range_i       (max_btacram_range),
   .expected_data     (expected_btacram_wdata_num2),
   //Outputs
   .addr_o            (btacram_addr_num2),
   .wdata_o           (btacram_wdata_num2),
   .enable_o          (btacram_en_num2),
   .wr_en_o           (btac_ram_wr_num2),
   .wrbyte_en_o       ( ),
   .bank_cnt_o        (btacram_bank_cnt_num2),
   .wdata_check_o     (btacram_wdata_check_num2),
   .passed_o          (btacram_passed_num2_o),
   .done_o            (btacram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

   // Assign a different address to each bank.
  assign btac_ram_addr_tst2   = btacram_addr_num2;

  // Assign different write data to each bank.
  assign btac_ram_wdata_tst2 = btacram_wdata_num2;

  assign btac_ram_en_tst2 = (btacram_wdata_num2 == {`CA53_BTAC_RAM_S1D_W{1'b0}} | btacram_en_num2 == {`BTACRAM_NUM_BANKS{1'b0}})? btacram_en_num2[(`BTACRAM_NUM_BANKS - 1):0] : (btac_ram_wr_num2 ? btacram_wr_en_num2[(`BTACRAM_NUM_BANKS - 1):0] : btacram_en_num2[(`BTACRAM_NUM_BANKS - 1):0]);

  //Registering the Done signal
  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      btacram_done_num2_o <= 1'b0;
    else if (btacram_done_num2)
      btacram_done_num2_o <= btacram_done_num2;

  always@(*)
   begin
     case(btacram_bank_cnt_num2)
       4'b0000 : btacram_wr_en_num2 = 4'b0001;
       4'b0001 : btacram_wr_en_num2 = 4'b0010;
       4'b0010 : btacram_wr_en_num2 = 4'b0100;
       4'b0011 : btacram_wr_en_num2 = 4'b1000;
       default : btacram_wr_en_num2 = {4{1'bx}};
     endcase
   end

 //##########Final Muxing###########
 //---------------------------------

 assign btac_stg1_ram_addr_tst_out  = in_progress_num1 ? btac_ram_addr_tst1  : in_progress_num2 ? btac_ram_addr_tst2  : {`CA53_BTAC_RAM_ADDR_W{1'b0}};
 
 assign btac_stg1_ram_addr_o        = btac_stg1_ram_wr_o ? (~max_btacram_range | btac_stg1_ram_addr_tst_out) : btac_stg1_ram_addr_tst_out;
 assign btac_stg1_ram_wdata_o       = in_progress_num1 ? btac_ram_wdata_tst1 : in_progress_num2 ? btac_ram_wdata_tst2 : {`CA53_BTAC_RAM_S1D_W{1'b0}};
 assign btac_stg1_ram_en_o          = in_progress_num1 ? btac_ram_en_tst1    : in_progress_num2 ? btac_ram_en_tst2    : 1'b0;
 assign btac_stg1_ram_wr_o          = in_progress_num1 ? btac_ram_wr_num1    : in_progress_num2 ? btac_ram_wr_num2    : 1'b0;


 //Checker Case Statement for Test-1
 assign btacram_wdata_check0_num1 = f_scramble_data(btacram_wdata_check_num1, 0);

 assign expected_btacram_wdata_num1 = btacram_wdata_check0_num1;

 //Checker Case Statement for Test-2
 always@(*)
   begin
     btacram_wdata_check0_num2 = {`CA53_BTAC_RAM_S1D_W{1'b0}};
     btacram_wdata_check1_num2 = {`CA53_BTAC_RAM_S1D_W{1'b0}};
     btacram_wdata_check2_num2 = {`CA53_BTAC_RAM_S1D_W{1'b0}};
     btacram_wdata_check3_num2 = {`CA53_BTAC_RAM_S1D_W{1'b0}};
     case (btacram_bank_cnt_num2)
       4'b0000 : btacram_wdata_check0_num2 = btacram_wdata_check_num2;
       4'b0001 : btacram_wdata_check1_num2 = btacram_wdata_check_num2;
       4'b0010 : btacram_wdata_check2_num2 = btacram_wdata_check_num2;
       4'b0011 : btacram_wdata_check3_num2 = btacram_wdata_check_num2;
     endcase
   end

 assign expected_btacram_wdata_num2 = btacram_wdata_check0_num2;


endmodule
