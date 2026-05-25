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

module ca53_d_dataram_tb #(parameter CPU_CACHE_PROTECTION  = 1'b0)
(
  output wire [7:0]                            dc_dataram_en_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb0_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb1_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb2_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb3_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb4_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb5_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb6_o,
  output wire [(`CA53_DDATA_WEN_W-1):0]        dc_dataram_strb7_o,
  output wire                                  dc_dataram_wr_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata0_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata1_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata2_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata3_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata4_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata5_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata6_o,
  output wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_wdata7_o,
  output wire [10:0]                           dc_dataram_addr0_o,
  output wire [10:0]                           dc_dataram_addr1_o,
  output wire [10:0]                           dc_dataram_addr2_o,
  output wire [10:0]                           dc_dataram_addr3_o,
  output wire [10:0]                           dc_dataram_addr4_o,
  output wire [10:0]                           dc_dataram_addr5_o,
  output wire [10:0]                           dc_dataram_addr6_o,
  output wire [10:0]                           dc_dataram_addr7_o,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata0_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata1_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata2_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata3_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata4_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata5_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata6_i,
  input  wire [(`CA53_DDATA_RAM_W-1):0]        dc_dataram_rdata7_i,

  output wire                                  dc_dataram_passed_num1_o,
  output wire                                  dc_dataram_passed_num2_o,
  output wire                                  dc_dataram_passed_num3_o,
  output reg                                   dc_dataram_done_num1_o,
  output reg                                   dc_dataram_done_num2_o,
  output reg                                   dc_dataram_done_num3_o,
  input  wire                                  clk,
  input  wire                                  reset_n,
  input  wire [10:0]                           max_d_dataram_range,
  input  wire                                  test_start_i
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

  function [31:0] f_wdata_check_noecc;
    input [7:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check_noecc = {{8{1'b0}}, {8{1'b0}}, {8{1'b0}}, data};
           5'b00001 : f_wdata_check_noecc = {{8{1'b0}}, {8{1'b0}}, data, {8{1'b0}}};
           5'b00010 : f_wdata_check_noecc = {{8{1'b0}}, data, {8{1'b0}}, {8{1'b0}}};
           5'b00011 : f_wdata_check_noecc = {data, {8{1'b0}}, {8{1'b0}}, {8{1'b0}}};
           default : f_wdata_check_noecc  = {32{1'bx}};
         endcase
    end
  endfunction

  function [38:0] f_wdata_check_ecc;
    input [7:0] data;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : f_wdata_check_ecc = {data[2:0], data[6:3], {8{1'b0}}, {8{1'b0}}, {8{1'b0}}, data};
           5'b00001 : f_wdata_check_ecc = {data[2:0], data[6:3], {8{1'b0}}, {8{1'b0}}, data, {8{1'b0}}};
           5'b00010 : f_wdata_check_ecc = {data[2:0], data[6:3], {8{1'b0}}, data, {8{1'b0}}, {8{1'b0}}};
           5'b00011 : f_wdata_check_ecc = {data[2:0], data[6:3], data, {8{1'b0}}, {8{1'b0}}, {8{1'b0}}};
           5'b00100 : f_wdata_check_ecc = {39{1'b0}};
           default : f_wdata_check_ecc  = {39{1'bx}};
         endcase
    end
  endfunction

  //D-DataRam TB
  //------------

  wire [((`CA53_DDATA_RAM_W * `DDATARAM_NUM_BANKS) -1):0] dc_dataram_rdata;
  wire [10:0]	   	                                  dc_dataram_addr0_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr1_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr2_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr3_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr4_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr5_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr6_tst_out;
  wire [10:0]	   	                                  dc_dataram_addr7_tst_out;
 
  //Test Number-1 Declarations
  wire                                                    dc_dataram_done_num1;
  wire [3:0]                                              dc_dataram_bank_cnt_num1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr_num1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata_num1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata_check_num1;
  wire [(`DDATARAM_NUM_BANKS -1) :0]                      dc_dataram_en_num1;
  wire [(`CA53_DDATA_WEN_W -1)   :0]                      dc_dataram_bw_en_num1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr0_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr1_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr2_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr3_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr4_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr5_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr6_tst1;
  wire [(`DDATARAM_ADDR_WIDTH -1):0]                      dc_dataram_addr7_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata0_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata1_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata2_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata3_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata4_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata5_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata6_tst1;
  wire [(`CA53_DDATA_RAM_W -1)   :0]                      dc_dataram_wdata7_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb0_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb1_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb2_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb3_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb4_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb5_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb6_tst1;
  wire [(`CA53_DDATA_WEN_W-1)    :0]                      dc_dataram_strb7_tst1;
  wire [(`DDATARAM_NUM_BANKS -1) :0]                      dc_dataram_en_tst1;
  wire [((`CA53_DDATA_RAM_W * `DDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num1;
  wire                                                    dc_dataram_wr_num1;
  wire                                                    in_progress_num1;

  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check0_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check1_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check2_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check3_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check4_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check5_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check6_num1;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check7_num1;

    //Test Number-2 Declarations
  wire                                                    dc_dataram_done_num2;
  wire [3:0]                                              dc_dataram_bank_cnt_num2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr_num2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata_num2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata_check_num2;
  wire [(`DDATARAM_NUM_BANKS -1)  :0]                     dc_dataram_en_num2;
  wire [(`CA53_DDATA_WEN_W -1)    :0]                     dc_dataram_bw_en_num2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr0_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr1_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr2_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr3_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr4_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr5_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr6_tst2;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr7_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata0_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata1_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata2_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata3_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata4_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata5_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata6_tst2;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata7_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb0_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb1_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb2_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb3_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb4_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb5_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb6_tst2;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb7_tst2;
  wire [(`DDATARAM_NUM_BANKS -1)  :0]                     dc_dataram_en_tst2;
  wire                                                    dc_dataram_wr_num2;
  wire                                                    in_progress_num2;
  wire [((`CA53_DDATA_RAM_W * `DDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num2;
  wire                                                    reset_data_word_num2;

  reg [(`DDATARAM_NUM_BANKS -1)   :0]                     dc_dataram_wr_en_tst2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check0_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check1_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check2_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check3_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check4_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check5_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check6_num2;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check7_num2;


  //Test Number-3 Declarations
  wire                                                    dc_dataram_done_num3;
  wire [3:0]                                              dc_dataram_bank_cnt_num3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr_num3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata_num3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata_num3_ecc;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata_sel3;
  wire [(`DDATARAM_BYTE_WIDTH -1) :0]                     dc_dataram_wdata_check_num3;
  wire [(`DDATARAM_NUM_BANKS -1)  :0]                     dc_dataram_en_num3;
  wire [(`CA53_DDATA_WEN_W -1)    :0]                     dc_dataram_bw_en_num3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr0_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr1_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr2_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr3_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr4_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr5_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr6_tst3;
  wire [(`DDATARAM_ADDR_WIDTH -1) :0]                     dc_dataram_addr7_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata0_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata1_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata2_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata3_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata4_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata5_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata6_tst3;
  wire [(`CA53_DDATA_RAM_W -1)    :0]                     dc_dataram_wdata7_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb0_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb1_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb2_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb3_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb4_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb5_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb6_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_strb7_tst3;
  wire [(`CA53_DDATA_WEN_W-1)     :0]                     dc_dataram_bw_en_sel3;
  wire [(`DDATARAM_NUM_BANKS -1)  :0]                     dc_dataram_en_tst3;
  wire                                                    dc_dataram_wr_num3;
  wire                                                    in_progress_num3;
  wire [((`CA53_DDATA_RAM_W * `DDATARAM_NUM_BANKS) -1):0] expected_dataram_wdata_num3;
  wire [4:0]                                              dc_dataram_strb_cnt_num3;
  wire                                                    reset_data_word_num3;

  reg [(`DDATARAM_NUM_BANKS -1)   :0]                     dc_dataram_wr_en_tst3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check0_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check1_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check2_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check3_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check4_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check5_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check6_num3;
  reg [(`CA53_DDATA_RAM_W -1)     :0]                     dataram_wdata_check7_num3;


  //########### Generic Code for all test#######
  //--------------------------------------------

  assign dc_dataram_rdata = {dc_dataram_rdata7_i, dc_dataram_rdata6_i, dc_dataram_rdata5_i, dc_dataram_rdata4_i,
                             dc_dataram_rdata3_i, dc_dataram_rdata2_i, dc_dataram_rdata1_i, dc_dataram_rdata0_i};



  //##########Test Number-1 Code###########
  //---------------------------------------

  ca53_ramtest_number1     #(.RAM_ID     ( `DDATARAM_RAM_ID),       // Unique ID
                             .ADDR_WIDTH ( `DDATARAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DDATARAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DDATARAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DDATARAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DDATA_RAM_W),      // width of RAM to test
                             .NUM_STRBS  ( `CA53_DDATA_WEN_W),
                             .CHK_LATENCY( `DDATARAM_CHECK_LATENCY)
  )  ddata_ram_number1
  (
   //Inputs
   .clk           (clk),
   .reset_n       (reset_n),
   .start_i       (test_start_i),
   .rdata_i       (dc_dataram_rdata),
   .max_range_i   (max_d_dataram_range),
   .expected_data (expected_dataram_wdata_num1),
   //Outputs
   .addr_o        (dc_dataram_addr_num1),
   .wdata_o       (dc_dataram_wdata_num1),
   .enable_o      (dc_dataram_en_num1),
   .wr_en_o       (dc_dataram_wr_num1),
   .wrbyte_en_o   (dc_dataram_bw_en_num1),
   .bank_cnt_o    (dc_dataram_bank_cnt_num1),
   .wdata_check_o (dc_dataram_wdata_check_num1),
   .passed_o      (dc_dataram_passed_num1_o),
   .done_o        (dc_dataram_done_num1),
   .in_progress_o (in_progress_num1),
   .dis_clken_o   ( )
   );

   // Assign a different address to each bank and zero if the bank is not enabled.
   assign dc_dataram_addr0_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0000}} &  dc_dataram_addr_num1[10:0];
   assign dc_dataram_addr1_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0001}} & {dc_dataram_addr_num1[10:2], dc_dataram_addr_num1[0], dc_dataram_addr_num1[1]};
   assign dc_dataram_addr2_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0010}} & {dc_dataram_addr_num1[10:3], dc_dataram_addr_num1[0], dc_dataram_addr_num1[2:1]};
   assign dc_dataram_addr3_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0011}} & {dc_dataram_addr_num1[10:4], dc_dataram_addr_num1[0], dc_dataram_addr_num1[3:1]};
   assign dc_dataram_addr4_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0100}} & {dc_dataram_addr_num1[10:5], dc_dataram_addr_num1[0], dc_dataram_addr_num1[4:1]};
   assign dc_dataram_addr5_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0101}} & {dc_dataram_addr_num1[10:6], dc_dataram_addr_num1[0], dc_dataram_addr_num1[5:1]};
   assign dc_dataram_addr6_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0110}} & {dc_dataram_addr_num1[10:7], dc_dataram_addr_num1[0], dc_dataram_addr_num1[6:1]};
   assign dc_dataram_addr7_tst1 = {11{dc_dataram_bank_cnt_num1 == 4'b0111}} & {dc_dataram_addr_num1[10:8], dc_dataram_addr_num1[0], dc_dataram_addr_num1[7:1]};

   // Assign different write data to each bank.
   assign dc_dataram_wdata0_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0000}} & f_scramble_data(dc_dataram_wdata_num1, 0);
   assign dc_dataram_wdata1_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0001}} & f_scramble_data(dc_dataram_wdata_num1, 1);
   assign dc_dataram_wdata2_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0010}} & f_scramble_data(dc_dataram_wdata_num1, 2);
   assign dc_dataram_wdata3_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0011}} & f_scramble_data(dc_dataram_wdata_num1, 3);
   assign dc_dataram_wdata4_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0100}} & f_scramble_data(dc_dataram_wdata_num1, 4);
   assign dc_dataram_wdata5_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0101}} & f_scramble_data(dc_dataram_wdata_num1, 5);
   assign dc_dataram_wdata6_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0110}} & f_scramble_data(dc_dataram_wdata_num1, 6);
   assign dc_dataram_wdata7_tst1 = {`CA53_DDATA_RAM_W{dc_dataram_bank_cnt_num1 == 4'b0111}} & f_scramble_data(dc_dataram_wdata_num1, 7);

   // STRBS are only set if the banks are enabled
   assign dc_dataram_strb0_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[0]}};
   assign dc_dataram_strb1_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[1]}};
   assign dc_dataram_strb2_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[2]}};
   assign dc_dataram_strb3_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[3]}};
   assign dc_dataram_strb4_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[4]}};
   assign dc_dataram_strb5_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[5]}};
   assign dc_dataram_strb6_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[6]}};
   assign dc_dataram_strb7_tst1 = dc_dataram_bw_en_num1 & {`CA53_DDATA_WEN_W{dc_dataram_en_num1[7]}};

   assign dc_dataram_en_tst1 = dc_dataram_en_num1;

  //Registering the Done signal
   always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dc_dataram_done_num1_o <= 1'b0;
    else if (dc_dataram_done_num1)
      dc_dataram_done_num1_o <= dc_dataram_done_num1;

  //##########Test Number-2 Code###########
  //---------------------------------------

  ca53_ramtest_number2     #(.RAM_ID     ( `DDATARAM_RAM_ID),         // Unique ID
                             .ADDR_WIDTH ( `DDATARAM_ADDR_WIDTH),   // Addr bits
                             .RAM_TYPE   ( `DDATARAM_RAM_TYPE  ),   // RAM type
                             .NUM_BANKS  ( `DDATARAM_NUM_BANKS),    // Number of Banks
                             .BYTE_WIDTH ( `DDATARAM_BYTE_WIDTH),   // Byte or bit granularity
                             .WORD_WIDTH ( `CA53_DDATA_RAM_W),      // width of RAM to test
                             .NUM_STRBS  ( `CA53_DDATA_WEN_W),
                             .CHK_LATENCY( `DDATARAM_CHECK_LATENCY)
  )  ddata_ram_number2
  (
   //Inputs
   .clk               (clk),
   .reset_n           (reset_n),
   .start_i           (dc_dataram_done_num1),
   .rdata_i           (dc_dataram_rdata),
   .max_range_i       (max_d_dataram_range),
   .expected_data     (expected_dataram_wdata_num2),
   //Outputs
   .addr_o            (dc_dataram_addr_num2),
   .wdata_o           (dc_dataram_wdata_num2),
   .enable_o          (dc_dataram_en_num2),
   .wr_en_o           (dc_dataram_wr_num2),
   .wrbyte_en_o       (dc_dataram_bw_en_num2),
   .bank_cnt_o        (dc_dataram_bank_cnt_num2),
   .wdata_check_o     (dc_dataram_wdata_check_num2),
   .passed_o          (dc_dataram_passed_num2_o),
   .done_o            (dc_dataram_done_num2),
   .in_progress_o     (in_progress_num2),
   .reset_data_word_o (reset_data_word_num2),
   .word_cnt_o        ( )
   );

    // Assign same address as we are only testing address-0
   assign dc_dataram_addr0_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr1_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr2_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr3_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr4_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr5_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr6_tst2 = dc_dataram_addr_num2[10:0];
   assign dc_dataram_addr7_tst2 = dc_dataram_addr_num2[10:0];

   // Only write to the RAM when bank enabled.
   assign dc_dataram_wdata0_tst2 = dc_dataram_bank_cnt_num2 == 4'b0000 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata1_tst2 = dc_dataram_bank_cnt_num2 == 4'b0001 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata2_tst2 = dc_dataram_bank_cnt_num2 == 4'b0010 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata3_tst2 = dc_dataram_bank_cnt_num2 == 4'b0011 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata4_tst2 = dc_dataram_bank_cnt_num2 == 4'b0100 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata5_tst2 = dc_dataram_bank_cnt_num2 == 4'b0101 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata6_tst2 = dc_dataram_bank_cnt_num2 == 4'b0110 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};
   assign dc_dataram_wdata7_tst2 = dc_dataram_bank_cnt_num2 == 4'b0111 | reset_data_word_num2 ? dc_dataram_wdata_num2 : {`CA53_DDATA_RAM_W{1'b1}};

   // STRBS are only set if the banks are enabled
   assign dc_dataram_strb0_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb1_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb2_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb3_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb4_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb5_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb6_tst2 = dc_dataram_bw_en_num2;
   assign dc_dataram_strb7_tst2 = dc_dataram_bw_en_num2;

   assign dc_dataram_en_tst2 = (dc_dataram_wdata_num2 == {`CA53_DDATA_RAM_W{1'b0}} | dc_dataram_en_num2 == {`DDATARAM_NUM_BANKS{1'b0}}) ? dc_dataram_en_num2 : (dc_dataram_wr_num2 ? dc_dataram_wr_en_tst2 : dc_dataram_en_num2);

    //Registering the Done signal
   always @(posedge clk or negedge reset_n)
    if (~reset_n)
      dc_dataram_done_num2_o <= 1'b0;
    else if (dc_dataram_done_num2)
      dc_dataram_done_num2_o <= dc_dataram_done_num2;

   always@(*)
   begin
     case(dc_dataram_bank_cnt_num2)
       4'b0000 : dc_dataram_wr_en_tst2 = 8'b00000001;
       4'b0001 : dc_dataram_wr_en_tst2 = 8'b00000010;
       4'b0010 : dc_dataram_wr_en_tst2 = 8'b00000100;
       4'b0011 : dc_dataram_wr_en_tst2 = 8'b00001000;
       4'b0100 : dc_dataram_wr_en_tst2 = 8'b00010000;
       4'b0101 : dc_dataram_wr_en_tst2 = 8'b00100000;
       4'b0110 : dc_dataram_wr_en_tst2 = 8'b01000000;
       4'b0111 : dc_dataram_wr_en_tst2 = 8'b10000000;
       default : dc_dataram_wr_en_tst2 = {8{1'bx}};
     endcase
   end


  generate if (CPU_CACHE_PROTECTION == 0) begin : dataram_strbschecking_num3

    //##########Test Number-3 Code###########
    //---------------------------------------

    ca53_rambytetest_number3     #(.RAM_ID     ( `DDATARAM_RAM_ID),       // Unique ID
                                   .ADDR_WIDTH ( `DDATARAM_ADDR_WIDTH), // Addr bits
                                   .RAM_TYPE   ( `DDATARAM_RAM_TYPE  ), // RAM type
                                   .NUM_BANKS  ( `DDATARAM_NUM_BANKS),  // Number of Banks
                                   .BYTE_WIDTH ( `DDATARAM_BYTE_WIDTH), // Byte or bit granularity
                                   .WORD_WIDTH ( `CA53_DDATA_RAM_W),    // width of RAM to test
                                   .NUM_STRBS  ( `CA53_DDATA_WEN_W),
                                   .CHK_LATENCY( `DDATARAM_CHECK_LATENCY)
    )  ddata_ram_number3
    (
     //Inputs
     .clk               (clk),
     .reset_n           (reset_n),
     .start_i           (dc_dataram_done_num2),
     .rdata_i           (dc_dataram_rdata),
     .max_range_i       (max_d_dataram_range),
     .expected_data     (expected_dataram_wdata_num3),
     //Outputs
     .addr_o            (dc_dataram_addr_num3),
     .wdata_o           (dc_dataram_wdata_num3),
     .enable_o          (dc_dataram_en_num3),
     .wr_en_o           (dc_dataram_wr_num3),
     .wrbyte_en_o       (dc_dataram_bw_en_num3),
     .bank_cnt_o        (dc_dataram_bank_cnt_num3),
     .strb_cnt_o        (dc_dataram_strb_cnt_num3),
     .wdata_check_o     (dc_dataram_wdata_check_num3),
     .passed_o          (dc_dataram_passed_num3_o),
     .done_o            (dc_dataram_done_num3),
     .in_progress_o     (in_progress_num3),
     .reset_data_word_o (reset_data_word_num3)
     );

      // Assign same address as we are only testing address-0
     assign dc_dataram_addr0_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr1_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr2_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr3_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr4_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr5_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr6_tst3 = dc_dataram_addr_num3[10:0];
     assign dc_dataram_addr7_tst3 = dc_dataram_addr_num3[10:0];

     // Only write to the RAM when bank enabled.
     // - When ECC is enabled then we send 0'b0
     //   data when strb has reached 4 for strb[4]
     // - Otherwise we take the data as normal

     // Swapping the data around for ECC to make it different.
     assign dc_dataram_wdata_sel3  = CPU_CACHE_PROTECTION ? dc_dataram_wdata_num3_ecc : dc_dataram_wdata_num3;

     assign dc_dataram_wdata0_tst3 = dc_dataram_bank_cnt_num3 == 4'b0000 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata1_tst3 = dc_dataram_bank_cnt_num3 == 4'b0001 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata2_tst3 = dc_dataram_bank_cnt_num3 == 4'b0010 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata3_tst3 = dc_dataram_bank_cnt_num3 == 4'b0011 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata4_tst3 = dc_dataram_bank_cnt_num3 == 4'b0100 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata5_tst3 = dc_dataram_bank_cnt_num3 == 4'b0101 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata6_tst3 = dc_dataram_bank_cnt_num3 == 4'b0110 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};
     assign dc_dataram_wdata7_tst3 = dc_dataram_bank_cnt_num3 == 4'b0111 | reset_data_word_num3 ? (CPU_CACHE_PROTECTION & (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1)) ? {`CA53_DDATA_RAM_W{1'b0}} : dc_dataram_wdata_sel3 : {`CA53_DDATA_RAM_W{1'b1}};

     //   STRBS are only set if the banks are enabled
     // - In ECC only first 4 bits are taken as Strb[4]
     //   needs to be high all the time. Strb have 5 bits
     // - In ECC only when strb cnt reaches 4 then all
     //   strbs are high.
     // - In NoECC all 4 strbs are taken.Strb have 4 bits
     assign dc_dataram_bw_en_sel3 = CPU_CACHE_PROTECTION ? ( (dc_dataram_strb_cnt_num3 == `CA53_DDATA_WEN_W -1) ? {`CA53_DDATA_WEN_W{1'b1}} : {1'b1, dc_dataram_bw_en_num3[(`CA53_DDATA_WEN_W - 1 -1) : 0]} ): dc_dataram_bw_en_num3;

     assign dc_dataram_strb0_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[0]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb1_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[1]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb2_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[2]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb3_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[3]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb4_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[4]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb5_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[5]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb6_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[6]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};
     assign dc_dataram_strb7_tst3 = dc_dataram_bw_en_sel3 & {`CA53_DDATA_WEN_W{dc_dataram_en_tst3[7]}} & {`CA53_DDATA_WEN_W{dc_dataram_wr_num3}};

     assign dc_dataram_en_tst3 = dc_dataram_wdata_num3 == {`CA53_DDATA_RAM_W{1'b0}} ? dc_dataram_en_num3 : (dc_dataram_wr_num3 ? dc_dataram_wr_en_tst3 : dc_dataram_en_num3);

     //Registering the Done signal
     always @(posedge clk or negedge reset_n)
      if (~reset_n)
        dc_dataram_done_num3_o <= 1'b0;
      else if (dc_dataram_done_num3)
        dc_dataram_done_num3_o <= dc_dataram_done_num3;

     always@(*)
     begin
       case(dc_dataram_bank_cnt_num3)
         4'b0000 : dc_dataram_wr_en_tst3 = 8'b00000001;
         4'b0001 : dc_dataram_wr_en_tst3 = 8'b00000010;
         4'b0010 : dc_dataram_wr_en_tst3 = 8'b00000100;
         4'b0011 : dc_dataram_wr_en_tst3 = 8'b00001000;
         4'b0100 : dc_dataram_wr_en_tst3 = 8'b00010000;
         4'b0101 : dc_dataram_wr_en_tst3 = 8'b00100000;
         4'b0110 : dc_dataram_wr_en_tst3 = 8'b01000000;
         4'b0111 : dc_dataram_wr_en_tst3 = 8'b10000000;
         default : dc_dataram_wr_en_tst3  = {8{1'bx}};
       endcase
     end

  end else begin : dataram_strbschecking_num3_tieoffs

     //Registering the Done signal
     always @(posedge clk or negedge reset_n)
      if (~reset_n)
        dc_dataram_done_num3_o <= 1'b0;
      else if (dc_dataram_done_num2)
        dc_dataram_done_num3_o <= dc_dataram_done_num2;

      assign dc_dataram_passed_num3_o = dc_dataram_passed_num2_o;

      assign in_progress_num3 = 1'b0;
  end
  endgenerate

  //##########Final Muxing###########
  //---------------------------------------

  assign dc_dataram_addr0_tst_out = in_progress_num1 ? dc_dataram_addr0_tst1 : in_progress_num2 ?  dc_dataram_addr0_tst2 : in_progress_num3 ? dc_dataram_addr0_tst3 : {11{1'b0}};
  assign dc_dataram_addr1_tst_out = in_progress_num1 ? dc_dataram_addr1_tst1 : in_progress_num2 ?  dc_dataram_addr1_tst2 : in_progress_num3 ? dc_dataram_addr1_tst3 : {11{1'b0}};
  assign dc_dataram_addr2_tst_out = in_progress_num1 ? dc_dataram_addr2_tst1 : in_progress_num2 ?  dc_dataram_addr2_tst2 : in_progress_num3 ? dc_dataram_addr2_tst3 : {11{1'b0}};
  assign dc_dataram_addr3_tst_out = in_progress_num1 ? dc_dataram_addr3_tst1 : in_progress_num2 ?  dc_dataram_addr3_tst2 : in_progress_num3 ? dc_dataram_addr3_tst3 : {11{1'b0}};
  assign dc_dataram_addr4_tst_out = in_progress_num1 ? dc_dataram_addr4_tst1 : in_progress_num2 ?  dc_dataram_addr4_tst2 : in_progress_num3 ? dc_dataram_addr4_tst3 : {11{1'b0}};
  assign dc_dataram_addr5_tst_out = in_progress_num1 ? dc_dataram_addr5_tst1 : in_progress_num2 ?  dc_dataram_addr5_tst2 : in_progress_num3 ? dc_dataram_addr5_tst3 : {11{1'b0}};
  assign dc_dataram_addr6_tst_out = in_progress_num1 ? dc_dataram_addr6_tst1 : in_progress_num2 ?  dc_dataram_addr6_tst2 : in_progress_num3 ? dc_dataram_addr6_tst3 : {11{1'b0}};
  assign dc_dataram_addr7_tst_out = in_progress_num1 ? dc_dataram_addr7_tst1 : in_progress_num2 ?  dc_dataram_addr7_tst2 : in_progress_num3 ? dc_dataram_addr7_tst3 : {11{1'b0}};

  assign dc_dataram_addr0_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr0_tst_out) : dc_dataram_addr0_tst_out;
  assign dc_dataram_addr1_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr1_tst_out) : dc_dataram_addr1_tst_out;
  assign dc_dataram_addr2_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr2_tst_out) : dc_dataram_addr2_tst_out;
  assign dc_dataram_addr3_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr3_tst_out) : dc_dataram_addr3_tst_out;
  assign dc_dataram_addr4_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr4_tst_out) : dc_dataram_addr4_tst_out;
  assign dc_dataram_addr5_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr5_tst_out) : dc_dataram_addr5_tst_out;
  assign dc_dataram_addr6_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr6_tst_out) : dc_dataram_addr6_tst_out;
  assign dc_dataram_addr7_o = dc_dataram_wr_o ? (~max_d_dataram_range | dc_dataram_addr7_tst_out) : dc_dataram_addr7_tst_out;

  assign dc_dataram_wdata0_o = in_progress_num1 ? dc_dataram_wdata0_tst1 : in_progress_num2 ?  dc_dataram_wdata0_tst2 : in_progress_num3 ? dc_dataram_wdata0_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata1_o = in_progress_num1 ? dc_dataram_wdata1_tst1 : in_progress_num2 ?  dc_dataram_wdata1_tst2 : in_progress_num3 ? dc_dataram_wdata1_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata2_o = in_progress_num1 ? dc_dataram_wdata2_tst1 : in_progress_num2 ?  dc_dataram_wdata2_tst2 : in_progress_num3 ? dc_dataram_wdata2_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata3_o = in_progress_num1 ? dc_dataram_wdata3_tst1 : in_progress_num2 ?  dc_dataram_wdata3_tst2 : in_progress_num3 ? dc_dataram_wdata3_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata4_o = in_progress_num1 ? dc_dataram_wdata4_tst1 : in_progress_num2 ?  dc_dataram_wdata4_tst2 : in_progress_num3 ? dc_dataram_wdata4_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata5_o = in_progress_num1 ? dc_dataram_wdata5_tst1 : in_progress_num2 ?  dc_dataram_wdata5_tst2 : in_progress_num3 ? dc_dataram_wdata5_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata6_o = in_progress_num1 ? dc_dataram_wdata6_tst1 : in_progress_num2 ?  dc_dataram_wdata6_tst2 : in_progress_num3 ? dc_dataram_wdata6_tst3 : {`CA53_DDATA_RAM_W{1'b0}};
  assign dc_dataram_wdata7_o = in_progress_num1 ? dc_dataram_wdata7_tst1 : in_progress_num2 ?  dc_dataram_wdata7_tst2 : in_progress_num3 ? dc_dataram_wdata7_tst3 : {`CA53_DDATA_RAM_W{1'b0}};

  assign dc_dataram_strb0_o =  in_progress_num1 ? dc_dataram_strb0_tst1 : in_progress_num2 ? dc_dataram_strb0_tst2 : in_progress_num3 ? dc_dataram_strb0_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb1_o =  in_progress_num1 ? dc_dataram_strb1_tst1 : in_progress_num2 ? dc_dataram_strb1_tst2 : in_progress_num3 ? dc_dataram_strb1_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb2_o =  in_progress_num1 ? dc_dataram_strb2_tst1 : in_progress_num2 ? dc_dataram_strb2_tst2 : in_progress_num3 ? dc_dataram_strb2_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb3_o =  in_progress_num1 ? dc_dataram_strb3_tst1 : in_progress_num2 ? dc_dataram_strb3_tst2 : in_progress_num3 ? dc_dataram_strb3_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb4_o =  in_progress_num1 ? dc_dataram_strb4_tst1 : in_progress_num2 ? dc_dataram_strb4_tst2 : in_progress_num3 ? dc_dataram_strb4_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb5_o =  in_progress_num1 ? dc_dataram_strb5_tst1 : in_progress_num2 ? dc_dataram_strb5_tst2 : in_progress_num3 ? dc_dataram_strb5_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb6_o =  in_progress_num1 ? dc_dataram_strb6_tst1 : in_progress_num2 ? dc_dataram_strb6_tst2 : in_progress_num3 ? dc_dataram_strb6_tst3 : {`CA53_DDATA_WEN_W{1'b0}};
  assign dc_dataram_strb7_o =  in_progress_num1 ? dc_dataram_strb7_tst1 : in_progress_num2 ? dc_dataram_strb7_tst2 : in_progress_num3 ? dc_dataram_strb7_tst3 : {`CA53_DDATA_WEN_W{1'b0}};

  assign dc_dataram_en_o =  in_progress_num1 ? dc_dataram_en_tst1 : in_progress_num2 ? dc_dataram_en_tst2 : in_progress_num3 ? dc_dataram_en_tst3 : {8{1'b0}};

  assign dc_dataram_wr_o =  in_progress_num1 ? dc_dataram_wr_num1 : in_progress_num2 ? dc_dataram_wr_num2 : in_progress_num3 ? dc_dataram_wr_num3 : 1'b0;

 //Checker Case Statement for Test-1
 always@(*)
   begin
     dataram_wdata_check0_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check1_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check2_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check3_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check4_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check5_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check6_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check7_num1 = {`CA53_DDATA_RAM_W{1'b0}};
     case (dc_dataram_bank_cnt_num1)
       4'b0000 : dataram_wdata_check0_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 0);
       4'b0001 : dataram_wdata_check1_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 1);
       4'b0010 : dataram_wdata_check2_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 2);
       4'b0011 : dataram_wdata_check3_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 3);
       4'b0100 : dataram_wdata_check4_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 4);
       4'b0101 : dataram_wdata_check5_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 5);
       4'b0110 : dataram_wdata_check6_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 6);
       4'b0111 : dataram_wdata_check7_num1 = f_scramble_data(dc_dataram_wdata_check_num1, 7);
     endcase
   end

 assign expected_dataram_wdata_num1 = {dataram_wdata_check7_num1, dataram_wdata_check6_num1, dataram_wdata_check5_num1, dataram_wdata_check4_num1,
                                       dataram_wdata_check3_num1, dataram_wdata_check2_num1, dataram_wdata_check1_num1, dataram_wdata_check0_num1};

 //Checker Case Statement for Test-2
 always@(*)
   begin
     dataram_wdata_check0_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check1_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check2_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check3_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check4_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check5_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check6_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     dataram_wdata_check7_num2 = {`CA53_DDATA_RAM_W{1'b0}};
     case (dc_dataram_bank_cnt_num2)
       4'b0000 : dataram_wdata_check0_num2 = dc_dataram_wdata_check_num2;
       4'b0001 : dataram_wdata_check1_num2 = dc_dataram_wdata_check_num2;
       4'b0010 : dataram_wdata_check2_num2 = dc_dataram_wdata_check_num2;
       4'b0011 : dataram_wdata_check3_num2 = dc_dataram_wdata_check_num2;
       4'b0100 : dataram_wdata_check4_num2 = dc_dataram_wdata_check_num2;
       4'b0101 : dataram_wdata_check5_num2 = dc_dataram_wdata_check_num2;
       4'b0110 : dataram_wdata_check6_num2 = dc_dataram_wdata_check_num2;
       4'b0111 : dataram_wdata_check7_num2 = dc_dataram_wdata_check_num2;
     endcase
   end

 assign expected_dataram_wdata_num2 = {dataram_wdata_check7_num2, dataram_wdata_check6_num2, dataram_wdata_check5_num2, dataram_wdata_check4_num2,
                                       dataram_wdata_check3_num2, dataram_wdata_check2_num2, dataram_wdata_check1_num2, dataram_wdata_check0_num2};

 generate if (CPU_CACHE_PROTECTION == 0) begin : dataram_strbstbchecking_num3
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
       case (dc_dataram_bank_cnt_num3)
         4'b0000 : dataram_wdata_check0_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0001 : dataram_wdata_check1_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0010 : dataram_wdata_check2_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0011 : dataram_wdata_check3_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0100 : dataram_wdata_check4_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0101 : dataram_wdata_check5_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0110 : dataram_wdata_check6_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
         4'b0111 : dataram_wdata_check7_num3 = CPU_CACHE_PROTECTION ? f_wdata_check_ecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3) : f_wdata_check_noecc(dc_dataram_wdata_check_num3, dc_dataram_strb_cnt_num3);
       endcase
     end

   assign expected_dataram_wdata_num3 = {dataram_wdata_check7_num3, dataram_wdata_check6_num3, dataram_wdata_check5_num3, dataram_wdata_check4_num3,
                                         dataram_wdata_check3_num3, dataram_wdata_check2_num3, dataram_wdata_check1_num3, dataram_wdata_check0_num3};

  end
  endgenerate

endmodule
