//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-12-16 14:57:00 +0000 (Fri, 16 Dec 2011) $
//
//      Revision            : $Revision: 195717 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Thumb predecoder. It recognizes if the tranformation is for a T16
// instruction or for a T32A-T32B instruction. It sets the sideband signals.
// It takes two cycles to get the results.
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53ifu_pd_thumb

  (// Inputs
   input         clk,
   input         reset_n, // Global reset

   input         pd_t32_data_en_0_i,
   input         pd_t32_data_en_1_i,
   input [1:0]   pd_pcoffset_i,
   input         ifu_rready_i,
   input [63:0]  rdata_thumb_i, // external data
   input         ctl_pd_ack_i,

   // Outputs
   output [79:0] pd_data_thumb_o,
   output        pd_t32_data_req_pd1_o
   );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [19:0]     encoding_eocl_pd1;
  wire [79:0]     pd_data_thumb;

  wire [63:0]     raw_encoding_pd0;
  wire [3:0]      is_t16_pd0;
  wire [1:0]      pc_offset_pd0;
  wire            shift_second_t32_pd0;

  wire [18:0]     encoding_t16_pd0_3;
  wire [18:0]     encoding_t16_pd0_2;
  wire [18:0]     encoding_t16_pd0_1;
  wire [18:0]     encoding_t16_pd0_0;

  wire [18:0]     raw_encoding_t32_0_pd0a;
  wire [18:0]     raw_encoding_t32_0_pd0b;
  wire [18:0]     raw_encoding_t32_1_pd0a;
  wire [18:0]     raw_encoding_t32_1_pd0b;

  wire [39:0]     raw_encoding_t32_0_pd1;
  wire [39:0]     raw_encoding_t32_1_pd1;

  wire [2:0]      t16_sideband_pd0_0;
  wire [2:0]      t16_sideband_pd0_1;
  wire [2:0]      t16_sideband_pd0_2;
  wire [2:0]      t16_sideband_pd0_3;
  wire [5:0]      t32_sideband_pd1_0;
  wire [5:0]      t32_sideband_pd1_1;

  wire [39:0]     encoding_t32_pd1_1;
  wire [39:0]     encoding_t32_pd1_0;
  wire [19:0]     encoding_t16_pd1_0;
  wire [19:0]     encoding_t16_pd1_1;
  wire [19:0]     encoding_t16_pd1_2;
  wire [19:0]     encoding_t16_pd1_3;
  wire            pd_t32_req;
  wire            pd_t32_en;

  // -----------------------------
  // Reg declarations
  // -----------------------------

  reg [18:0]      raw_encoding_t32_0_pd1a;
  reg [18:0]      raw_encoding_t32_0_pd1b;
  reg [18:0]      raw_encoding_t32_1_pd1a;
  reg [18:0]      raw_encoding_t32_1_pd1b;

  reg [1:0]       pc_offset_pd1;
  reg [3:0]       is_t16_pd1;
  reg             shift_second_t32_pd1;

  reg             pd_t32_data_req_pd1;

  // -----------------------------
  // Main code
  // -----------------------------

  //
  // select the data
  //
  assign raw_encoding_pd0 = rdata_thumb_i;

  assign pc_offset_pd0 = pd_pcoffset_i;

  //
  // speculative check if any of the packets is a potential a T16 instruction
  //
  // a T32A instruction must have the top three bits set to 1 and the fourth and fifth not set to zero
  // speculative we can assume that if that is not met we have a T16
  // Also we need to remember that the instructions are in memory view therefore T32A is at the bottom
  assign is_t16_pd0[0] = ~((raw_encoding_pd0[15:13] == 3'b111) & (raw_encoding_pd0[12:11] != 2'b00));
  assign is_t16_pd0[1] = ~((raw_encoding_pd0[31:29] == 3'b111) & (raw_encoding_pd0[28:27] != 2'b00));
  assign is_t16_pd0[2] = ~((raw_encoding_pd0[47:45] == 3'b111) & (raw_encoding_pd0[44:43] != 2'b00));
  assign is_t16_pd0[3] = ~((raw_encoding_pd0[63:61] == 3'b111) & (raw_encoding_pd0[60:59] != 2'b00));

  // There are few steps that needs to be done before we can set the decoders
  // o decide if the second T32 will read the third and fourth or the
  //   second and third half word
  assign shift_second_t32_pd0 = (pc_offset_pd0[1:0] == 2'b00 & ~is_t16_pd0[1] & is_t16_pd0[0]) |
                                (pc_offset_pd0[1:0] == 2'b01 & ~is_t16_pd0[1]);

  //
  // Instantiate the 4 T16 predecoders
  //
  ca53ifu_pd_t16 u_ca53ifu_pd_t16_0(.raw_encoding_i     (raw_encoding_pd0[15:0]),
                                    .sideband_o         (t16_sideband_pd0_0)
                                    );
  ca53ifu_pd_t16 u_ca53ifu_pd_t16_1(.raw_encoding_i     (raw_encoding_pd0[31:16]),
                                    .sideband_o         (t16_sideband_pd0_1)
                                    );
  ca53ifu_pd_t16 u_ca53ifu_pd_t16_2(.raw_encoding_i     (raw_encoding_pd0[47:32]),
                                    .sideband_o         (t16_sideband_pd0_2)
                                    );
  ca53ifu_pd_t16 u_ca53ifu_pd_t16_3(.raw_encoding_i     (raw_encoding_pd0[63:48]),
                                    .sideband_o         (t16_sideband_pd0_3)
                                    );

  // 1|1||1|1|1|1|1|1|1|1|
  // 9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
  // -+-----+-------------------------------+
  // 0| Sid |        Opcode[15:0]           |
  // -+-----+-------------------------------+
  //Should be 20 bits wide but saving a register as it is a constant and is added in pd1 stage.

  assign encoding_t16_pd0_3[18:16] = t16_sideband_pd0_3;
  assign encoding_t16_pd0_3[15:0]  = raw_encoding_pd0[63:48];

  assign encoding_t16_pd0_2[18:16] = t16_sideband_pd0_2;
  assign encoding_t16_pd0_2[15:0]  = raw_encoding_pd0[47:32];

  assign encoding_t16_pd0_1[18:16] = t16_sideband_pd0_1;
  assign encoding_t16_pd0_1[15:0]  = raw_encoding_pd0[31:16];

  assign encoding_t16_pd0_0[18:16] = t16_sideband_pd0_0;
  assign encoding_t16_pd0_0[15:0]  = raw_encoding_pd0[15:0];

  //
  // Move to pd1
  //
  // at the end of pd0 we mux the data ready to be used by the T32 pre decoders
  // early in pd1 we have to swizzle the data back to reconstruct the T16 and the
  // incomplete format. This is because the T32 predecoders are timing critical
  // while the T16s and the incomplete data are not.
  //
  // |S|   T32_1   |   T32_0   | (S => shift second T32)
  // +-+-----+-----+-----+-----+
  // |0|T16_3|T16_2|T16_1|T16_0|
  // |1|T16_2|T16_1|T16_3|T16_0|
  assign raw_encoding_t32_0_pd0a[18:0]  =                                             encoding_t16_pd0_0;
  assign raw_encoding_t32_0_pd0b[18:0]  = shift_second_t32_pd0 ? encoding_t16_pd0_3 : encoding_t16_pd0_1;
  assign raw_encoding_t32_1_pd0a[18:0]  = shift_second_t32_pd0 ? encoding_t16_pd0_1 : encoding_t16_pd0_2;
  assign raw_encoding_t32_1_pd0b[18:0]  = shift_second_t32_pd0 ? encoding_t16_pd0_2 : encoding_t16_pd0_3;

  //PDO for T32 Predecoder 0 Data
  always @(posedge clk)
    if (pd_t32_data_en_0_i) begin
      raw_encoding_t32_0_pd1a <= raw_encoding_t32_0_pd0a;
      raw_encoding_t32_0_pd1b <= raw_encoding_t32_0_pd0b;
    end

  //PD1 for T32 Predecoder 1 Data
  always @(posedge clk)
    if (pd_t32_data_en_1_i) begin
      raw_encoding_t32_1_pd1a <= raw_encoding_t32_1_pd0a;
      raw_encoding_t32_1_pd1b <= raw_encoding_t32_1_pd0b;
    end

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      pc_offset_pd1          <= 2'b00;
      is_t16_pd1             <= 4'h0;
      shift_second_t32_pd1   <= 1'b0;
    end else if (pd_t32_data_en_0_i) begin
      pc_offset_pd1          <= pc_offset_pd0;
      is_t16_pd1             <= is_t16_pd0;
      shift_second_t32_pd1   <= shift_second_t32_pd0;
    end

   //Concatenating with 1'b0 to make it 40 bits wide again as the register was saved in PD0 stage.
   // The reason why we have bit 39 and bit 19 is to complete the 40 bit word but it is only used
   // in T16 and bit 19 and 39 are set to zero in T16 but for T32 which is shown below will have
   // bit 19 as 1 while bit 39 remains zero.
   assign raw_encoding_t32_0_pd1 = {1'b0,raw_encoding_t32_0_pd1b,1'b0,raw_encoding_t32_0_pd1a};
   assign raw_encoding_t32_1_pd1 = {1'b0,raw_encoding_t32_1_pd1b,1'b0,raw_encoding_t32_1_pd1a};

   //State Signal used to select T32 while not in PDC.

  assign pd_t32_req = (pd_t32_data_en_1_i & ifu_rready_i) | (pd_t32_data_req_pd1 & !ctl_pd_ack_i);
  assign pd_t32_en  = (pd_t32_data_en_1_i & ifu_rready_i) | (pd_t32_data_req_pd1 &  ctl_pd_ack_i);

   always @(posedge clk or negedge reset_n)
     if (!reset_n)
       pd_t32_data_req_pd1  <= 1'b0;
     else if (pd_t32_en)
       pd_t32_data_req_pd1 <= pd_t32_req;

  //
  // Instantiate the 2 T32 predecoders
  //
  // Because we did not pass the ID from the T16 there are two gaps (it is always 1'b0 we can save 4 registers)
  // align data coorectly taking ID into account:
  // Input data to be swizzle for register view                        old[12:0]                    old[35:20]
  ca53ifu_pd_t32 u_ca53ifu_pd_t32_0 (.raw_encoding_i ({raw_encoding_t32_0_pd1[12:0],raw_encoding_t32_0_pd1[35:20]}),
                                     .sideband_o     (t32_sideband_pd1_0)
                                     );
  // Input data to be swizzle for register view                        old[12:0]                    old[35:20]
  ca53ifu_pd_t32 u_ca53ifu_pd_t32_1 (.raw_encoding_i ({raw_encoding_t32_1_pd1[12:0],raw_encoding_t32_1_pd1[35:20]}),
                                     .sideband_o     (t32_sideband_pd1_1)
                                     );

  // 3|3|3|3|3|3|3|3|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1|
  // 9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
  // -+-----+-------------------------------+-+-----------+-------------------------+
  // 0| Sid |        Opcode[15:0]           |1|  Sid[5:0] |        Opcode[28:16]    |
  // -+-----+-------------------------------+-+-----------+-------------------------+
  assign encoding_t32_pd1_1[39]    = 1'b0;
  assign encoding_t32_pd1_1[38:36] = raw_encoding_t32_1_pd1[38:36];
  assign encoding_t32_pd1_1[35:20] = raw_encoding_t32_1_pd1[35:20];
  assign encoding_t32_pd1_1[19]    = 1'b1;
  assign encoding_t32_pd1_1[18:13] = t32_sideband_pd1_1;
  assign encoding_t32_pd1_1[12:0]  = raw_encoding_t32_1_pd1[12:0];

  assign encoding_t32_pd1_0[39]    = 1'b0;
  assign encoding_t32_pd1_0[38:36] = raw_encoding_t32_0_pd1[38:36];
  assign encoding_t32_pd1_0[35:20] = raw_encoding_t32_0_pd1[35:20];
  assign encoding_t32_pd1_0[19]    = 1'b1;
  assign encoding_t32_pd1_0[18:13] = t32_sideband_pd1_0;
  assign encoding_t32_pd1_0[12:0]  = raw_encoding_t32_0_pd1[12:0];

  // We need to realign the data which was set in pd0 ready for T32
  // Because we did not pass the ID from the T16 there are two gaps (it is always 1'b0 we can save 4 registers)
  // align data correctly taking ID into account:
  //
  // |S|   T32_1   |   T32_0   | (S => shift second T32)
  // +-+-----+-----+-----+-----+
  // |0|T16_3|T16_2|T16_1|T16_0|
  // |1|T16_2|T16_1|T16_3|T16_0|
  //

  assign encoding_t16_pd1_0 =                        raw_encoding_t32_0_pd1[19: 0];
  assign encoding_t16_pd1_1 = shift_second_t32_pd1 ? raw_encoding_t32_1_pd1[19: 0]: raw_encoding_t32_0_pd1[39:20];
  assign encoding_t16_pd1_2 = shift_second_t32_pd1 ? raw_encoding_t32_1_pd1[39:20]: raw_encoding_t32_1_pd1[19:0] ;
  assign encoding_t16_pd1_3 = shift_second_t32_pd1 ? raw_encoding_t32_0_pd1[39:20]: raw_encoding_t32_1_pd1[39:20];


  // EOCL
  assign encoding_eocl_pd1[19]    = 1'b1;  //ID T32A
  assign encoding_eocl_pd1[18:13] = 6'b111111;  // Incomplete sideband
  assign encoding_eocl_pd1[12:0]  = shift_second_t32_pd1 ? raw_encoding_t32_0_pd1[32:20] : raw_encoding_t32_1_pd1[32:20];

  //
  // Output mux selector for the predecoders
  //
  assign pd_data_thumb[19:0]  =                           ~is_t16_pd1[0] ? encoding_t32_pd1_0[19:0]  :                                                    encoding_t16_pd1_0 ;
  assign pd_data_thumb[39:20] = pc_offset_pd1 != 2'b01 && ~is_t16_pd1[0] ? encoding_t32_pd1_0[39:20] : (shift_second_t32_pd1 ? encoding_t32_pd1_1[19:0] : encoding_t16_pd1_1);
  assign pd_data_thumb[59:40] =                     shift_second_t32_pd1 ? encoding_t32_pd1_1[39:20] : (~is_t16_pd1[2]       ? encoding_t32_pd1_1[19:0] : encoding_t16_pd1_2);
  assign pd_data_thumb[79:60] = pc_offset_pd1 != 2'b11 && ~shift_second_t32_pd1 && ~is_t16_pd1[2] ? encoding_t32_pd1_1[39:20] : (~is_t16_pd1[3]       ? encoding_eocl_pd1 [19:0] : encoding_t16_pd1_3);

  //
  // Set Thumb Output & Enables
  //
  assign pd_data_thumb_o      = pd_data_thumb;
  assign pd_t32_data_req_pd1_o = pd_t32_data_req_pd1;



  // ------------------------------------------------------
  // OVL
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_t32_en")
  u_ovl_x_pd_t32_en (.clk       (clk),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (pd_t32_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_t32_data_en_0_i")
  u_ovl_x_pd_t32_data_en_0_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (pd_t32_data_en_0_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pd_t32_data_en_1_i")
  u_ovl_x_pd_t32_data_en_1_i (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (pd_t32_data_en_1_i));
`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

