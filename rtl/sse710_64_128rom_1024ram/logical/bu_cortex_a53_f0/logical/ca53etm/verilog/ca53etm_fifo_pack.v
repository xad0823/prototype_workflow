//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//
// Overview
// ========
//

//
// Pack16 + Pack4
// Re-order 16 input bytes to give 16 output bytes using required address for
// each input byte. Pipeline stage exists between stage A and B
// Xor desired location with current to give shift for each stage.
// Packing function allows bytes to be moved to top or bottom, but not re-ordered
// Any don't care bytes must be assigned a control input of 0, this is indicated
// by an input request of 0xF
// Append Pack4 at the end of Pack16
//

//
// Module Declaration
// ==================
//

`include "ca53etm_params.v"
`include "cortexa53params.v"

module  ca53etm_fifo_pack (



//
// Interface Signals
// =================
//

// Global inputs
  input wire            clk_gated,            // CPU clock
`ifdef CA53_SVA_ON
  input wire            po_reset_n,           // Power on reset
`endif
// Inputs

// Signals from trace_gen
  input wire  [127:0] pack16_data_in_t4_i,    // Data input to be packed 16 bytes
  input wire  [4:0]   pack16_bytes_in_t4_i,   // Valid bytes in pack 16

  input wire  [1:0]   final_16_0_t4_i,        // Final position for byte 0
  input wire  [3:0]   final_16_1_t4_i,        // Final position for byte 1
  input wire  [3:0]   final_16_2_t4_i,        // Final position for byte 2
  input wire  [3:0]   final_16_3_t4_i,        // Final position for byte 3
  input wire  [3:0]   final_16_4_t4_i,        // Final position for byte 4
  input wire  [3:0]   final_16_5_t4_i,        // Final position for byte 5
  input wire  [3:0]   final_16_6_t4_i,        // Final position for byte 6
  input wire  [3:0]   final_16_7_t4_i,        // Final position for byte 7
  input wire  [3:0]   final_16_8_t4_i,        // Final position for byte 8
  input wire  [3:0]   final_16_9_t4_i,        // Final position for byte 9
  input wire  [3:0]   final_16_a_t4_i,        // Final position for byte 1
  input wire  [3:0]   final_16_b_t4_i,        // Final position for byte 11
  input wire  [3:0]   final_16_c_t4_i,        // Final position for byte 12
  input wire  [3:0]   final_16_d_t4_i,        // Final position for byte 13
  input wire  [3:0]   final_16_e_t4_i,        // Final position for byte 14
  input wire  [3:0]   final_16_f_t4_i,        // Final position for byte 15

  input wire  [31:0]  pack_pack4_data_in_t4_i,// Data input to be packed lower 4 bytes
  input wire  [2:0]   pack4_num_bytes_t4_i,   // Valid bytes in pack 4

// Outputs
  output wire  [156:0] pack_data_out_t5_o     // Packed Data 16+4 bytes.

 );
  // -----------------------------
  // Wire and reg declarations
  // -----------------------------
  reg  [  4:  0] pack16_bytes_in_t5;
  wire [127:  0] pack16_data_out_t5;
  reg  [ 31:  0] pack4_data_in_t5;
  wire           pack_data_en_t4;
  wire [  1:  0] pack_data_sel_0_t5;
  wire [  4:  0] pack_data_sel_10_t5;
  wire [  4:  0] pack_data_sel_11_t5;
  wire [  4:  0] pack_data_sel_12_t5;
  wire [  4:  0] pack_data_sel_13_t5;
  wire [  4:  0] pack_data_sel_14_t5;
  wire [  4:  0] pack_data_sel_15_t5;
  wire [  3:  0] pack_data_sel_16_t5;
  wire [  2:  0] pack_data_sel_17_t5;
  wire [  1:  0] pack_data_sel_18_t5;
  wire [  2:  0] pack_data_sel_1_t5;
  wire [  3:  0] pack_data_sel_2_t5;
  wire [  4:  0] pack_data_sel_3_t5;
  wire [  4:  0] pack_data_sel_4_t5;
  wire [  4:  0] pack_data_sel_5_t5;
  wire [  4:  0] pack_data_sel_6_t5;
  wire [  4:  0] pack_data_sel_7_t5;
  wire [  4:  0] pack_data_sel_8_t5;
  wire [  4:  0] pack_data_sel_9_t5;


  genvar       i;
  wire         control_level_a0_1_t4;
  wire         control_level_a1_1_t4;
  wire         control_level_a_lo0_t4  [7: 0];
  wire [ 3: 0] control_level_a_hi_t4  [15: 8];
  wire [ 7: 0] byte_level_b_t4     [15: 0];
  wire         control_level_b_1_0_t4;
  wire         control_level_b_5_0_t4;
  wire [ 2: 0] control_level_b_t4  [15: 8];
  reg  [ 7: 0] byte_level_b_t5     [15: 0];
  // First few control inputs are sparse
  reg          control_level_b_1_0_t5;
  reg          control_level_b_5_0_t5;
  reg  [ 2: 0] control_level_b_t5  [15: 8];
  wire [ 7: 0] byte_level_c_t5     [15: 0];
  wire         control_level_c_3_0_t5;
  wire [ 1: 0] control_level_c_t5  [15: 8];

  wire [ 7: 0] byte_level_d_t5     [15: 0];
  wire         control_level_d_t5  [15: 7];


//
// Main Code
// =========
//

// Don't care lanes must be given control value of 0
  assign control_level_a0_1_t4          = final_16_0_t4_i[1];
  assign control_level_a1_1_t4          = {~&final_16_1_t4_i[3:0]}  & (          final_16_1_t4_i[1]);

  assign control_level_a_lo0_t4[ 0]     =                                          final_16_0_t4_i[0];
  assign control_level_a_lo0_t4[ 1]     = { {~&final_16_1_t4_i[3:0]}} & (   1'b1 ^ final_16_1_t4_i[0]);
  assign control_level_a_lo0_t4[ 2]     = { {~&final_16_2_t4_i[3:0]}} & (   1'b0 ^ final_16_2_t4_i[0]);
  assign control_level_a_lo0_t4[ 3]     = { {~&final_16_3_t4_i[3:0]}} & (   1'b1 ^ final_16_3_t4_i[0]);
  assign control_level_a_lo0_t4[ 4]     = { {~&final_16_4_t4_i[3:0]}} & (   1'b0 ^ final_16_4_t4_i[0]);
  assign control_level_a_lo0_t4[ 5]     = { {~&final_16_5_t4_i[3:0]}} & (   1'b1 ^ final_16_5_t4_i[0]);
  assign control_level_a_lo0_t4[ 6]     = { {~&final_16_6_t4_i[3:0]}} & (   1'b0 ^ final_16_6_t4_i[0]);
  assign control_level_a_lo0_t4[ 7]     = { {~&final_16_7_t4_i[3:0]}} & (   1'b1 ^ final_16_7_t4_i[0]);
  assign control_level_a_hi_t4[ 8][3:0] = {4{~&final_16_8_t4_i[3:0]}} & (4'b1000 ^ final_16_8_t4_i[3:0]);
  assign control_level_a_hi_t4[ 9][3:0] = {4{~&final_16_9_t4_i[3:0]}} & (4'b1001 ^ final_16_9_t4_i[3:0]);
  assign control_level_a_hi_t4[10][3:0] = {4{~&final_16_a_t4_i[3:0]}} & (4'b1010 ^ final_16_a_t4_i[3:0]);
  assign control_level_a_hi_t4[11][3:0] = {4{~&final_16_b_t4_i[3:0]}} & (4'b1011 ^ final_16_b_t4_i[3:0]);
  assign control_level_a_hi_t4[12][3:0] = {4{~&final_16_c_t4_i[3:0]}} & (4'b1100 ^ final_16_c_t4_i[3:0]);
  assign control_level_a_hi_t4[13][3:0] = {4{~&final_16_d_t4_i[3:0]}} & (4'b1101 ^ final_16_d_t4_i[3:0]);
  assign control_level_a_hi_t4[14][3:0] = {4{~&final_16_e_t4_i[3:0]}} & (4'b1110 ^ final_16_e_t4_i[3:0]);
  assign control_level_a_hi_t4[15][3:0] = 4'b1111 ^ final_16_f_t4_i[3:0];

  // Stage A - cross with neighbour
  // Bytes 0,2,4,6 generate 0 result for stage B, and only need +1 input control
    assign control_level_b_1_0_t4    = (control_level_a_lo0_t4[0]                              )?
                                                                    control_level_a0_1_t4 :
                                                                    control_level_a1_1_t4 ;
    assign control_level_b_5_0_t4    = (control_level_a_lo0_t4[4]                              )?
                                                                    1'b1 :
                                                                    1'b0 ;

  // Bytes 0-7
  generate
    for (i = 0; i < 8; i = i + 2) begin: upack_stagea_first

      assign byte_level_b_t4[  i][7:0]    = (                           control_level_a_lo0_t4[i+1])?
                                                                 pack16_data_in_t4_i[(i+1)*8 +: 8] :
                                                                 pack16_data_in_t4_i[    i*8 +: 8] ;
      assign byte_level_b_t4[i+1][7:0]    = (control_level_a_lo0_t4[i]                             )?
                                                                 pack16_data_in_t4_i[i*8 +: 8]     :
                                                                 pack16_data_in_t4_i[(i+1)*8 +: 8] ;
    end
  endgenerate
  // Bytes 8-15
  generate
    for (i = 8; i < 16; i = i + 2) begin: upack_stagea_second

      assign byte_level_b_t4[  i][7:0]    = (control_level_a_hi_t4[i][0] | control_level_a_hi_t4[i+1][0])?
                                                                 pack16_data_in_t4_i[(i+1)*8 +: 8] :
                                                                 pack16_data_in_t4_i[    i*8 +: 8] ;
      assign byte_level_b_t4[i+1][7:0]    = (control_level_a_hi_t4[i][0] | control_level_a_hi_t4[i+1][0])?
                                                                 pack16_data_in_t4_i[i*8 +: 8]     :
                                                                 pack16_data_in_t4_i[(i+1)*8 +: 8] ;
      assign control_level_b_t4[  i][2:0] = (control_level_a_hi_t4[i][0] | control_level_a_hi_t4[i+1][0])?
                                                                      control_level_a_hi_t4[i+1][3:1] :
                                                                      control_level_a_hi_t4[  i][3:1] ;
      assign control_level_b_t4[i+1][2:0] = (control_level_a_hi_t4[i][0] | control_level_a_hi_t4[i+1][0])?
                                                                      control_level_a_hi_t4[  i][3:1] :
                                                                      control_level_a_hi_t4[i+1][3:1] ;
    end
  endgenerate

  // Pipeline control and data between stage A and B
  assign pack_data_en_t4 = (|{pack16_bytes_in_t4_i[4:0],pack4_num_bytes_t4_i[2:0]});

  generate
    for (i = 0; i < 16; i = i +1) begin: ubyte_level_b_t5
      always @(posedge clk_gated)
        if (pack_data_en_t4) begin
          byte_level_b_t5   [i][7:0] <= byte_level_b_t4   [i][7:0];
        end
    end
  endgenerate

  always @(posedge clk_gated)
    if (pack_data_en_t4) begin
      control_level_b_1_0_t5 <= control_level_b_1_0_t4;
      control_level_b_5_0_t5 <= control_level_b_5_0_t4;
    end

  generate
    for (i = 8; i < 16; i = i +1) begin: uctl_level_b_t5
      always @(posedge clk_gated)
        if (pack_data_en_t4) begin
          control_level_b_t5[i][2:0] <= control_level_b_t4[i][2:0];
        end
    end
  endgenerate

  // Stage B - cross with 2nd neighbour
  // Control inputs 0,2,4,6 are low
   assign byte_level_c_t5[  0][7:0]    =                                byte_level_b_t5[  0][7:0] ;
   assign byte_level_c_t5[0+2][7:0]    =                                byte_level_b_t5[0+2][7:0] ;
   assign byte_level_c_t5[0+1][7:0]    = (control_level_b_1_0_t5                                )?
                                                                        byte_level_b_t5[0+3][7:0] :
                                                                        byte_level_b_t5[0+1][7:0] ;
   assign byte_level_c_t5[0+3][7:0]    = (control_level_b_1_0_t5                                )?
                                                                        byte_level_b_t5[0+1][7:0] :
                                                                        byte_level_b_t5[0+3][7:0] ;
  // Only bit[0] of this term is needed
   assign control_level_c_3_0_t5       = (control_level_b_1_0_t5                                )?
                                                                        1'b1 :
                                                                        1'b0 ;

   assign byte_level_c_t5[  4][7:0]    =                                 byte_level_b_t5[  4][7:0] ;
   assign byte_level_c_t5[4+2][7:0]    =                                 byte_level_b_t5[4+2][7:0] ;
  //for bytes: 8,10,12,14,
  generate
    for (i = 8; i < 16; i = i + 4) begin: upack_stageb_first
      assign byte_level_c_t5[  i][7:0]    = (control_level_b_t5[  i][0] | control_level_b_t5[i+2][0]) ?
                                                                            byte_level_b_t5[i+2][7:0] :
                                                                            byte_level_b_t5[  i][7:0] ;
      assign byte_level_c_t5[i+2][7:0]    = (control_level_b_t5[  i][0] | control_level_b_t5[i+2][0]) ?
                                                                            byte_level_b_t5[  i][7:0] :
                                                                            byte_level_b_t5[i+2][7:0] ;
      assign control_level_c_t5[  i][1:0] = (control_level_b_t5[  i][0] | control_level_b_t5[i+2][0]) ?
                                                                         control_level_b_t5[i+2][2:1] :
                                                                         control_level_b_t5[  i][2:1] ;
      assign control_level_c_t5[i+2][1:0] = (control_level_b_t5[  i][0] | control_level_b_t5[i+2][0]) ?
                                                                         control_level_b_t5[  i][2:1] :
                                                                         control_level_b_t5[i+2][2:1] ;
    end
  endgenerate
  
  
  assign byte_level_c_t5[4+1][7:0]    = (control_level_b_5_0_t5                         )?
                                                                  byte_level_b_t5[4+3][7:0] :
                                                                  byte_level_b_t5[4+1][7:0] ;
  assign byte_level_c_t5[4+3][7:0]    = (control_level_b_5_0_t5                         )?
                                                                  byte_level_b_t5[4+1][7:0] :
                                                                  byte_level_b_t5[4+3][7:0] ;
  generate
    for (i = 8; i < 16; i = i + 4) begin: upack_stageb
      //for bytes: 9,11,13,15
      assign byte_level_c_t5[i+1][7:0]    = (control_level_b_t5[i+1][0] | control_level_b_t5[i+3][0])?
                                                                           byte_level_b_t5[i+3][7:0] :
                                                                           byte_level_b_t5[i+1][7:0] ;
      assign byte_level_c_t5[i+3][7:0]    = (control_level_b_t5[i+1][0] | control_level_b_t5[i+3][0])?
                                                                           byte_level_b_t5[i+1][7:0] :
                                                                           byte_level_b_t5[i+3][7:0] ;
      assign control_level_c_t5[i+1][1:0] = (control_level_b_t5[i+1][0] | control_level_b_t5[i+3][0])?
                                                                        control_level_b_t5[i+3][2:1] :
                                                                        control_level_b_t5[i+1][2:1] ;
      assign control_level_c_t5[i+3][1:0] = (control_level_b_t5[i+1][0] | control_level_b_t5[i+3][0])?
                                                                        control_level_b_t5[i+1][2:1] :
                                                                        control_level_b_t5[i+3][2:1] ;
    end
  endgenerate


  // Stage C - Cross with 4th neighbour
  // Control 0,1,2,4,5,6 are always low, result 0-6 are low
 //for bytes: 0,1,4,5
  generate
    for (i = 0; i < 2; i = i + 1) begin: upack_stagec_basic
      assign byte_level_d_t5[i][7:0]    =                              byte_level_c_t5[  i][7:0] ;
      assign byte_level_d_t5[i+4][7:0]  =                              byte_level_c_t5[i+4][7:0] ;
    end
  endgenerate
 //for bytes: 2,6
  generate
    for (i = 2; i < 3; i = i + 1) begin: upack_stagec_2_6
      assign byte_level_d_t5[i][7:0]    =                              byte_level_c_t5[  i][7:0] ;
      assign byte_level_d_t5[i+4][7:0]  =                              byte_level_c_t5[i+4][7:0] ;
    end
  endgenerate
 //for bytes: 3,7
   assign byte_level_d_t5[3][7:0]    = (control_level_c_3_0_t5                               )?
                                                                    byte_level_c_t5[3+4][7:0] :
                                                                    byte_level_c_t5[  3][7:0] ;
   assign byte_level_d_t5[3+4][7:0]  = (control_level_c_3_0_t5                               )?
                                                                    byte_level_c_t5[  3][7:0] :
                                                                    byte_level_c_t5[3+4][7:0] ;
   assign control_level_d_t5[3+4]    = (control_level_c_3_0_t5                               )?
                                                                   1'b1                       :
                                                                   1'b0 ;

 //for bytes: second half 8 bytes
  generate
    for (i = 8; i < 12; i = i + 1) begin: upack_stagec_second
      assign byte_level_d_t5[i][7:0]    = (control_level_c_t5[i][0] | control_level_c_t5[i+4][0])?
                                                                       byte_level_c_t5[i+4][7:0] :
                                                                       byte_level_c_t5[  i][7:0] ;
      assign byte_level_d_t5[i+4][7:0]  = (control_level_c_t5[i][0] | control_level_c_t5[i+4][0])?
                                                                       byte_level_c_t5[  i][7:0] :
                                                                       byte_level_c_t5[i+4][7:0] ;
      assign control_level_d_t5[  i]    = (control_level_c_t5[i][0] | control_level_c_t5[i+4][0])?
                                                                      control_level_c_t5[i+4][1] :
                                                                      control_level_c_t5[  i][1] ;
      assign control_level_d_t5[i+4]    = (control_level_c_t5[i][0] | control_level_c_t5[i+4][0])?
                                                                      control_level_c_t5[  i][1] :
                                                                      control_level_c_t5[i+4][1] ;
    end
  endgenerate


  // Stage D - Cross with 8th neighbour
  // Control 6:0 are always low
  generate
    for (i = 0; i < 7; i = i + 1) begin: upack_staged_1
      assign pack16_data_out_t5[    i*8 +:8]  = (                      control_level_d_t5[i+8]) ?
                                                                        byte_level_d_t5[i+8][7:0] :
                                                                        byte_level_d_t5[  i][7:0] ;
    end
  endgenerate
  // byte 7
  assign   pack16_data_out_t5[    7*8 +:8]  = (control_level_d_t5[7] | control_level_d_t5[7+8]) ?
                                                                        byte_level_d_t5[7+8][7:0] :
                                                                        byte_level_d_t5[  7][7:0] ;
  // Bytes 8-14
  generate
    for (i = 0; i < 7; i = i + 1) begin: upack_staged_2
      assign pack16_data_out_t5[(i+8)*8 +:8]  = (                      control_level_d_t5[i+8]) ?
                                                                        byte_level_d_t5[  i][7:0] :
                                                                        byte_level_d_t5[i+8][7:0] ;
    end
  endgenerate
  // Byte 15
      assign pack16_data_out_t5[(7+8)*8 +:8]  = (control_level_d_t5[7] | control_level_d_t5[7+8]) ?
                                                                        byte_level_d_t5[  7][7:0] :
                                                                        byte_level_d_t5[7+8][7:0] ;

// Append pack4 after most valid byte of pack16
  always @(posedge clk_gated)
  begin: upack_data_t5
    if (pack_data_en_t4) begin
      pack16_bytes_in_t5[4:0] <= pack16_bytes_in_t4_i[4:0];
      pack4_data_in_t5[31:0]  <= pack_pack4_data_in_t4_i[31:0];
    end
  end

  
  assign pack_data_sel_0_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00001);
  assign pack_data_sel_0_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00000);

  assign pack_data_sel_1_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00010);
  assign pack_data_sel_1_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00001);
  assign pack_data_sel_1_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00000);

  assign pack_data_sel_2_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00011);
  assign pack_data_sel_2_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00010);
  assign pack_data_sel_2_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00001);
  assign pack_data_sel_2_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00000);

  assign pack_data_sel_3_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00100);
  assign pack_data_sel_3_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00011);
  assign pack_data_sel_3_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00010);
  assign pack_data_sel_3_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00001);
  assign pack_data_sel_3_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00000);

  assign pack_data_sel_4_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00101);
  assign pack_data_sel_4_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00100);
  assign pack_data_sel_4_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00011);
  assign pack_data_sel_4_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00010);
  assign pack_data_sel_4_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00001);

  assign pack_data_sel_5_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00110);
  assign pack_data_sel_5_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00101);
  assign pack_data_sel_5_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00100);
  assign pack_data_sel_5_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00011);
  assign pack_data_sel_5_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00010);

  assign pack_data_sel_6_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b00111);
  assign pack_data_sel_6_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00110);
  assign pack_data_sel_6_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00101);
  assign pack_data_sel_6_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00100);
  assign pack_data_sel_6_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00011);

  assign pack_data_sel_7_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01000);
  assign pack_data_sel_7_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b00111);
  assign pack_data_sel_7_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00110);
  assign pack_data_sel_7_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00101);
  assign pack_data_sel_7_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00100);

  assign pack_data_sel_8_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01001);
  assign pack_data_sel_8_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01000);
  assign pack_data_sel_8_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b00111);
  assign pack_data_sel_8_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00110);
  assign pack_data_sel_8_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00101);

  assign pack_data_sel_9_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01010);
  assign pack_data_sel_9_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01001);
  assign pack_data_sel_9_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01000);
  assign pack_data_sel_9_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b00111);
  assign pack_data_sel_9_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00110);

  assign pack_data_sel_10_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01011);
  assign pack_data_sel_10_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01010);
  assign pack_data_sel_10_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01001);
  assign pack_data_sel_10_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01000);
  assign pack_data_sel_10_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b00111);

  assign pack_data_sel_11_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01100);
  assign pack_data_sel_11_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01011);
  assign pack_data_sel_11_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01010);
  assign pack_data_sel_11_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01001);
  assign pack_data_sel_11_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b01000);

  assign pack_data_sel_12_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01101);
  assign pack_data_sel_12_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01100);
  assign pack_data_sel_12_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01011);
  assign pack_data_sel_12_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01010);
  assign pack_data_sel_12_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b01001);

  assign pack_data_sel_13_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01110);
  assign pack_data_sel_13_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01101);
  assign pack_data_sel_13_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01100);
  assign pack_data_sel_13_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01011);
  assign pack_data_sel_13_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b01010);

  assign pack_data_sel_14_t5[0] = (pack16_bytes_in_t5[4:0] >= 5'b01111);
  assign pack_data_sel_14_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01110);
  assign pack_data_sel_14_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01101);
  assign pack_data_sel_14_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01100);
  assign pack_data_sel_14_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b01011);

  assign pack_data_sel_15_t5[0] = (pack16_bytes_in_t5[4:0] == 5'b10000);
  assign pack_data_sel_15_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01111);
  assign pack_data_sel_15_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01110);
  assign pack_data_sel_15_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01101);
  assign pack_data_sel_15_t5[4] = (pack16_bytes_in_t5[4:0] == 5'b01100);

  assign pack_data_sel_16_t5[0] = (pack16_bytes_in_t5[4:0] == 5'b10000);
  assign pack_data_sel_16_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01111);
  assign pack_data_sel_16_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01110);
  assign pack_data_sel_16_t5[3] = (pack16_bytes_in_t5[4:0] == 5'b01101);

  assign pack_data_sel_17_t5[0] = (pack16_bytes_in_t5[4:0] == 5'b10000);
  assign pack_data_sel_17_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01111);
  assign pack_data_sel_17_t5[2] = (pack16_bytes_in_t5[4:0] == 5'b01110);

  assign pack_data_sel_18_t5[0] = (pack16_bytes_in_t5[4:0] == 5'b10000);
  assign pack_data_sel_18_t5[1] = (pack16_bytes_in_t5[4:0] == 5'b01111);

  assign pack_data_out_t5_o[7:0]   =
    ({8{pack_data_sel_0_t5[0]}} & pack16_data_out_t5[7:0]) |
    ({8{pack_data_sel_0_t5[1]}} & pack4_data_in_t5[7:0]) ;

  assign pack_data_out_t5_o[15:8]  =
    ({8{pack_data_sel_1_t5[0]}} & pack16_data_out_t5[15:8]) |
    ({8{pack_data_sel_1_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_1_t5[2]}} & pack4_data_in_t5[15:8]) ;

  assign pack_data_out_t5_o[23:16] =
    ({8{pack_data_sel_2_t5[0]}} & pack16_data_out_t5[23:16]) |
    ({8{pack_data_sel_2_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_2_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_2_t5[3]}} & pack4_data_in_t5[23:16]) ;

  assign pack_data_out_t5_o[31:24] =
    ({8{pack_data_sel_3_t5[0]}} & pack16_data_out_t5[31:24]) |
    ({8{pack_data_sel_3_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_3_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_3_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_3_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[39:32] =
    ({8{pack_data_sel_4_t5[0]}} & pack16_data_out_t5[39:32]) |
    ({8{pack_data_sel_4_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_4_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_4_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_4_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[47:40] =
    ({8{pack_data_sel_5_t5[0]}} & pack16_data_out_t5[47:40]) |
    ({8{pack_data_sel_5_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_5_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_5_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_5_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[55:48] =
    ({8{pack_data_sel_6_t5[0]}} & pack16_data_out_t5[55:48]) |
    ({8{pack_data_sel_6_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_6_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_6_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_6_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[63:56] =
    ({8{pack_data_sel_7_t5[0]}} & pack16_data_out_t5[63:56]) |
    ({8{pack_data_sel_7_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_7_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_7_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_7_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[71:64] =
    ({8{pack_data_sel_8_t5[0]}} & pack16_data_out_t5[71:64]) |
    ({8{pack_data_sel_8_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_8_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_8_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_8_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[79:72] =
    ({8{pack_data_sel_9_t5[0]}} & pack16_data_out_t5[79:72]) |
    ({8{pack_data_sel_9_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_9_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_9_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_9_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[87:80] =
    ({8{pack_data_sel_10_t5[0]}} & pack16_data_out_t5[87:80]) |
    ({8{pack_data_sel_10_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_10_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_10_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_10_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[95:88] =
    ({8{pack_data_sel_11_t5[0]}} & pack16_data_out_t5[95:88]) |
    ({8{pack_data_sel_11_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_11_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_11_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_11_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[103:96] =
    ({8{pack_data_sel_12_t5[0]}} & pack16_data_out_t5[103:96]) |
    ({8{pack_data_sel_12_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_12_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_12_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_12_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[111:104] =
    ({8{pack_data_sel_13_t5[0]}} & pack16_data_out_t5[111:104]) |
    ({8{pack_data_sel_13_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_13_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_13_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_13_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[119:112] =
    ({8{pack_data_sel_14_t5[0]}} & pack16_data_out_t5[119:112]) |
    ({8{pack_data_sel_14_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_14_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_14_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_14_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[127:120] =
    ({8{pack_data_sel_15_t5[0]}} & pack16_data_out_t5[127:120]) |
    ({8{pack_data_sel_15_t5[1]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_15_t5[2]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_15_t5[3]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_15_t5[4]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[135:128] =
    ({8{pack_data_sel_16_t5[0]}} & pack4_data_in_t5[7:0]) |
    ({8{pack_data_sel_16_t5[1]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_16_t5[2]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_16_t5[3]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[143:136] =
    ({8{pack_data_sel_17_t5[0]}} & pack4_data_in_t5[15:8]) |
    ({8{pack_data_sel_17_t5[1]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_17_t5[2]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[151:144] =
    ({8{pack_data_sel_18_t5[0]}} & pack4_data_in_t5[23:16]) |
    ({8{pack_data_sel_18_t5[1]}} & pack4_data_in_t5[31:24]) ;

  assign pack_data_out_t5_o[156:152] = pack4_data_in_t5[28:24];

//--------------------------------------------------------------------------
// ASSERTIONS
//--------------------------------------------------------------------------
`ifdef CA53_SVA_ON

`include "ca53etm_val_defs.v"
// FIFO Pack


  reg [7:0]   sva_pack16_out_bytes[0:15];
  reg [127:0] sva_pack16_data_in_t5;
  reg [3:0]   sva_final_16_0_t5;
  reg [3:0]   sva_final_16_1_t5;
  reg [3:0]   sva_final_16_2_t5;
  reg [3:0]   sva_final_16_3_t5;
  reg [3:0]   sva_final_16_4_t5;
  reg [3:0]   sva_final_16_5_t5;
  reg [3:0]   sva_final_16_6_t5;
  reg [3:0]   sva_final_16_7_t5;
  reg [3:0]   sva_final_16_8_t5;
  reg [3:0]   sva_final_16_9_t5;
  reg [3:0]   sva_final_16_a_t5;
  reg [3:0]   sva_final_16_b_t5;
  reg [3:0]   sva_final_16_c_t5;
  reg [3:0]   sva_final_16_d_t5;
  reg [3:0]   sva_final_16_e_t5;
  reg [3:0]   sva_final_16_f_t5;
  reg         sva_reset_delay_q;

  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      sva_reset_delay_q <=  1'b0;
  else
      sva_reset_delay_q <=  1'b1;

  wire sva_pack16_data_en_t4;
  assign sva_pack16_data_en_t4 = sva_reset_delay_q & (|{pack16_bytes_in_t4_i[4:0],pack4_num_bytes_t4_i[2:0]});

// Pack has a 1 cycle delay
  always @(posedge clk_gated or negedge po_reset_n)
    if (!po_reset_n)
      begin
        sva_pack16_data_in_t5 <=  {128{1'b0}};
        sva_final_16_0_t5 <=  4'hF;
        sva_final_16_1_t5 <=  4'hF;
        sva_final_16_2_t5 <=  4'hF;
        sva_final_16_3_t5 <=  4'hF;
        sva_final_16_4_t5 <=  4'hF;
        sva_final_16_5_t5 <=  4'hF;
        sva_final_16_6_t5 <=  4'hF;
        sva_final_16_7_t5 <=  4'hF;
        sva_final_16_8_t5 <=  4'hF;
        sva_final_16_9_t5 <=  4'hF;
        sva_final_16_a_t5 <=  4'hF;
        sva_final_16_b_t5 <=  4'hF;
        sva_final_16_c_t5 <=  4'hF;
        sva_final_16_d_t5 <=  4'hF;
        sva_final_16_e_t5 <=  4'hF;
        sva_final_16_f_t5 <=  4'hF;
      end
    else if(sva_pack16_data_en_t4)
      begin
        sva_pack16_data_in_t5 <=  pack16_data_in_t4_i[127:0];
        sva_final_16_0_t5 <=  {{2{final_16_0_t4_i[1]}},final_16_0_t4_i[1:0]};
        sva_final_16_1_t5 <=  final_16_1_t4_i[3:0];
        sva_final_16_2_t5 <=  final_16_2_t4_i[3:0];
        sva_final_16_3_t5 <=  final_16_3_t4_i[3:0];
        sva_final_16_4_t5 <=  final_16_4_t4_i[3:0];
        sva_final_16_5_t5 <=  final_16_5_t4_i[3:0];
        sva_final_16_6_t5 <=  final_16_6_t4_i[3:0];
        sva_final_16_7_t5 <=  final_16_7_t4_i[3:0];
        sva_final_16_8_t5 <=  final_16_8_t4_i[3:0];
        sva_final_16_9_t5 <=  final_16_9_t4_i[3:0];
        sva_final_16_a_t5 <=  final_16_a_t4_i[3:0];
        sva_final_16_b_t5 <=  final_16_b_t4_i[3:0];
        sva_final_16_c_t5 <=  final_16_c_t4_i[3:0];
        sva_final_16_d_t5 <=  final_16_d_t4_i[3:0];
        sva_final_16_e_t5 <=  final_16_e_t4_i[3:0];
        sva_final_16_f_t5 <=  final_16_f_t4_i[3:0];
      end

// Fill an array of bytes from pack_out[127:0] so that we can access
// individual bytes in the assertions below.
  integer     sva_inner;
  integer     sva_outer;
  always @* begin: sva_pack_expand
    reg [7:0]   sva_pack16_out_byte_tmp;
    for (sva_outer = 0; sva_outer < 16; sva_outer = sva_outer + 1)
      begin
        for (sva_inner = 0; sva_inner < 8; sva_inner = sva_inner + 1)
          sva_pack16_out_byte_tmp[sva_inner] = pack16_data_out_t5[sva_inner + sva_outer*8];
        sva_pack16_out_bytes[sva_outer] = sva_pack16_out_byte_tmp;
      end
    end

// check that input bytes end up in the correct place on the output. A
// value of 4'b1111 for final_16_x_t4 indicates "don't care".
  usva_pack_byte_0: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_0_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_0_t5] === sva_pack16_data_in_t5[7:0])
    `SVA_FATAL("Byte 0 should be packed correctly");

  usva_pack_byte_1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_1_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_1_t5] === sva_pack16_data_in_t5[15:8])
    `SVA_FATAL("Byte 1 should be packed correctly");

  usva_pack_byte_2: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_2_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_2_t5] === sva_pack16_data_in_t5[23:16])
    `SVA_FATAL("Byte 2 should be packed correctly");

  usva_pack_byte_3: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_3_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_3_t5] === sva_pack16_data_in_t5[31:24])
    `SVA_FATAL("Byte 3 should be packed correctly");

  usva_pack_byte_4: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_4_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_4_t5] === sva_pack16_data_in_t5[39:32])
    `SVA_FATAL("Byte 4 should be packed correctly");

  usva_pack_byte_5: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_5_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_5_t5] === sva_pack16_data_in_t5[47:40])
    `SVA_FATAL("Byte 5 should be packed correctly");

  usva_pack_byte_6: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_6_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_6_t5] === sva_pack16_data_in_t5[55:48])
    `SVA_FATAL("Byte 6 should be packed correctly");

  usva_pack_byte_7: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_7_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_7_t5] === sva_pack16_data_in_t5[63:56])
    `SVA_FATAL("Byte 7 should be packed correctly");

  usva_pack_byte_8: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_8_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_8_t5] === sva_pack16_data_in_t5[71:64])
    `SVA_FATAL("Byte 8 should be packed correctly");

  usva_pack_byte_9: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_9_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_9_t5] === sva_pack16_data_in_t5[79:72])
    `SVA_FATAL("Byte 9 should be packed correctly");

  usva_pack_byte_10: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_a_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_a_t5] === sva_pack16_data_in_t5[87:80])
    `SVA_FATAL("Byte 10 should be packed correctly");

  usva_pack_byte_11: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_b_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_b_t5] === sva_pack16_data_in_t5[95:88])
    `SVA_FATAL("Byte 11 should be packed correctly");

  usva_pack_byte_12: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_c_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_c_t5] === sva_pack16_data_in_t5[103:96])
    `SVA_FATAL("Byte 12 should be packed correctly");

  usva_pack_byte_13: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_d_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_d_t5] === sva_pack16_data_in_t5[111:104])
    `SVA_FATAL("Byte 13 should be packed correctly");

  usva_pack_byte_14: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_e_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_e_t5] === sva_pack16_data_in_t5[119:112])
    `SVA_FATAL("Byte 14 should be packed correctly");

  usva_pack_byte_15: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (sva_final_16_f_t5 != 4'b1111) |-> sva_pack16_out_bytes[sva_final_16_f_t5] === sva_pack16_data_in_t5[127:120])
    `SVA_FATAL("Byte 15 should be packed correctly");

// pack16_bytes_in_t4_i needs to be <= 16.
  usva_valid_bytes_pack16: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (pack16_bytes_in_t4_i[4:0] >= ( 0)) & (pack16_bytes_in_t4_i[4:0] <= ( 16)))
    `SVA_FATAL("Valid number of bytes in pack16 out of range");

// Check the position of pack4 in final output.
  reg [7:0]   sva_pack4_out_byte0;
  reg [7:0]   sva_pack4_out_byte1;
  reg [7:0]   sva_pack4_out_byte2;
  reg [7:0]   sva_pack4_out_byte3;
  integer     sva_pack4_bit_count;
  always @*
   begin
    for(sva_pack4_bit_count = 0; sva_pack4_bit_count < 8; sva_pack4_bit_count = sva_pack4_bit_count + 1)
    begin
    sva_pack4_out_byte0[sva_pack4_bit_count] = pack_data_out_t5_o[(pack16_bytes_in_t5*8) + sva_pack4_bit_count];
    sva_pack4_out_byte1[sva_pack4_bit_count] = pack_data_out_t5_o[((pack16_bytes_in_t5+1)*8) + sva_pack4_bit_count];
    sva_pack4_out_byte2[sva_pack4_bit_count] = pack_data_out_t5_o[((pack16_bytes_in_t5+2)*8) + sva_pack4_bit_count];
    sva_pack4_out_byte3[sva_pack4_bit_count] = pack_data_out_t5_o[((pack16_bytes_in_t5+3)*8) + sva_pack4_bit_count];
    end

   end

  usva_pack4_byte_16: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 |=> (sva_pack4_out_byte0[7:0] === pack4_data_in_t5[7:0]))
    `SVA_FATAL("Byte 16 should be packed correctly");

  usva_pack4_byte_17: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    pack_data_en_t4 |=> (sva_pack4_out_byte1[7:0] === pack4_data_in_t5[15:8]))
    `SVA_FATAL("Byte 17 should be packed correctly");

  usva_pack4_byte_18: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    pack_data_en_t4 |=> (sva_pack4_out_byte2[7:0] === pack4_data_in_t5[23:16]))
    `SVA_FATAL("Byte 18 should be packed correctly");

  // Allow for X-prop on unused input, which can be tied off at input
  usva_pack4_byte_19: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    pack_data_en_t4 |=> (sva_pack4_out_byte3[4:0] === {pack4_data_in_t5[28:24]}))
    `SVA_FATAL("Byte 19 should be packed correctly");

// No of valid bytes to pack16 and number of valid final values should match
  wire [4:0] sva_no_valid_final_16;
  assign sva_no_valid_final_16[4:0] = $countones({({{2{final_16_0_t4_i[1]}},final_16_0_t4_i[1:0]} != 4'hF),
                                                  (final_16_1_t4_i[3:0] != 4'hF),
                                                  (final_16_2_t4_i[3:0] != 4'hF),
                                                  (final_16_3_t4_i[3:0] != 4'hF),
                                                  (final_16_4_t4_i[3:0] != 4'hF),
                                                  (final_16_5_t4_i[3:0] != 4'hF),
                                                  (final_16_6_t4_i[3:0] != 4'hF),
                                                  (final_16_7_t4_i[3:0] != 4'hF),
                                                  (final_16_8_t4_i[3:0] != 4'hF),
                                                  (final_16_9_t4_i[3:0] != 4'hF),
                                                  (final_16_a_t4_i[3:0] != 4'hF),
                                                  (final_16_b_t4_i[3:0] != 4'hF),
                                                  (final_16_c_t4_i[3:0] != 4'hF),
                                                  (final_16_d_t4_i[3:0] != 4'hF),
                                                  (final_16_e_t4_i[3:0] != 4'hF),
                                                  (final_16_f_t4_i[3:0] != 4'hF)});
  usva_final_enables: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
    (pack16_bytes_in_t4_i[4:0] > 5'b00000) & (pack16_bytes_in_t4_i[4:0] <= 5'b01111) |-> sva_no_valid_final_16[4:0] == pack16_bytes_in_t4_i[4:0])
    `SVA_FATAL("Number of enabled input pack final lanes does not match pack16_bytes_in_t4_i");

    usva_fec_reach_e4: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
                                        pack_data_en_t4 |=> control_level_c_3_0_t5 == control_level_b_1_0_t5);
        
  // Some Control combinations are redundant, either as on of {0,1} {1,0} missing
  // or both missing.
  usva_fec_reach1: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_lo0_t4[5] |-> control_level_a_lo0_t4[4])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach2b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4  & control_level_a_lo0_t4[7] |-> control_level_a_lo0_t4[6])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach9: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_hi_t4[14][0] |-> control_level_a_hi_t4[15][0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach9a: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_hi_t4[15][0] |-> control_level_a_hi_t4[14][0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach14b: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_b_t5[14][0] |-> control_level_b_t5[12][0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach15: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_b_t5[15][0] |-> control_level_b_t5[13][0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach16: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 && control_level_a_lo0_t4[6] |=> control_level_b_5_0_t5)
    `SVA_WARN("Coverage point hit");
  usva_fec_reach17: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_lo0_t4[1] |-> control_level_a_lo0_t4[0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach18: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_hi_t4[13][0] |-> control_level_a_hi_t4[12][0])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach19: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   control_level_a_lo0_t4[3] |-> control_level_a_lo0_t4[2])
    `SVA_WARN("Coverage point hit");

    
// For L301
  usva_fec_reach31: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_c_t5[9][0] |-> ~control_level_c_t5[13][1])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach32: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_c_t5[13][0] |-> ~control_level_c_t5[13][1])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach33: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_c_t5[8][0] |-> ~control_level_c_t5[12][1])
    `SVA_WARN("Coverage point hit");
  usva_fec_reach34: assert property (@(posedge clk_gated) disable iff (!po_reset_n)
   pack_data_en_t4 ##1 control_level_c_t5[12][0] |-> ~control_level_c_t5[12][1])
    `SVA_WARN("Coverage point hit");
`endif

endmodule
 /*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53etm_val_defs.v"
`include "cortexa53params.v"
`include "ca53etm_params.v"
`undef CA53_UNDEFINE
 /*END*/
