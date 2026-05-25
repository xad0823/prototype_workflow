//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2007-2015 ARM Limited.
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

//-----------------------------------------------------------------------------
// Abstract : Thumb-16 to Thumb-32 and class decoder
//-----------------------------------------------------------------------------

`include "ca53ifu_defs.v"
`include "cortexa53params.v"

module ca53ifu_pf_dec_t16t32 (
  // Inputs
  input wire  [18:0] instr_i,       //[18:16] T16 SB, [15:0] T16 Instr
  input wire         in_it_block_i,
  // Outputs
  output wire [39:0] instr_t16t32_o

  );

  // -----------------------------
  // Wire & Reg declarations
  // -----------------------------

  wire [5:0]  defined_sideband;
  wire        dual_issue_slot1;

  reg  [28:0] instr_t16t32;
  reg  [3:0]  cond;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // Use defined sideband for output, as will be overriden when used if undef
  assign instr_t16t32_o   = {dual_issue_slot1,defined_sideband,cond,instr_t16t32};
  assign dual_issue_slot1 = (instr_i[18:16] == 3'b001) | (instr_i[15:12] == 4'b1101 & instr_i[17] == 1'b1) // B<cond> add bit[17] to ensure SWI are not picked
                                                       | (instr_i[15:12] == 4'b1110)                       // B <reg_target>
                                                       | (instr_i[15:8]  == 8'b01000111)                   // BX <Rm> / BLX <Rm>
                                                       | (instr_i[18:16] == 3'b100);                       // IT

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------
  always @*
    casez (instr_i[15:0])
      16'b11001011????1??? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0111  */
      16'b1011101010?????? : begin instr_t16t32 = {23'b00000000000001011101010,instr_i[5:0]}; cond = 4'b1110; end /* HLT <imm6>_75  */
      16'b11001001??????1? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0011  */
      16'b01000101???????? : begin instr_t16t32 = {9'b010111011,instr_i[7],instr_i[2:0],12'b000011110000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* CMP <Rn>  <Rm>_46  */
      16'b0001101????????? : begin instr_t16t32 = {8'b01011101,~in_it_block_i,1'b0,instr_i[5:3],5'b00000,instr_i[2:0],5'b00000,instr_i[8:6]}; cond = 4'b1110; end /* SUB <Rd>  <Rn>  <Rm>_11  */
      16'b010001110??????? : begin instr_t16t32 = {9'b101111000,instr_i[6],instr_i[5:3],16'b1000111100000000}; cond = 4'b1110; end /* BX <Rm>_7  */
      16'b0001100????????? : begin instr_t16t32 = {8'b01011000,~in_it_block_i,1'b0,instr_i[5:3],5'b00000,instr_i[2:0],5'b00000,instr_i[8:6]}; cond = 4'b1110; end /* ADD <Rd>  <Rn>  <Rm>_10  */
      16'b00100??????????? : begin instr_t16t32 = {8'b10000010,~in_it_block_i,9'b111100000,instr_i[10:8],instr_i[7:0]}; cond = 4'b1110; end /* MOV <Rd>  #<imm8>_14  */
      16'b1011111101??0000 : begin instr_t16t32 = {25'b1001110101111100000000000,instr_i[7:4]}; cond = 4'b1110; end /* (NOP | YIELD | WFE | WFI | SEV_81)_mod3  */
      16'b10110110010????? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* SETEND <endian_specifier>_70  */
      16'b1011000000?????? : begin instr_t16t32 = {21'b100010000110100001101,instr_i[5:0],2'b00}; cond = 4'b1110; end /* ADD SP  SP  #<imm7> * 4_41  */
      16'b1011001011?????? : begin instr_t16t32 = {18'b110100101111111110,instr_i[2:0],5'b10000,instr_i[5:3]}; cond = 4'b1110; end /* UXTB <Rd>  <Rm>_80  */
      16'b11001000???????0 : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* LDMIA <Rn>!  <register_list>_66  */
      16'b10101???01?????? : begin instr_t16t32 = {18'b101010000110101110,instr_i[10:8],1'b1,instr_i[5:0],1'b0}; cond = 4'b1110; end /* ADD <Rd>  SP  #<imm8> * 4_39  */
      16'b10101???1??????? : begin instr_t16t32 = {18'b101010000110101110,instr_i[10:8],1'b0,instr_i[6:0]}; cond = 4'b1110; end /* ADD <Rd>  SP  #<imm8> * 4_40  */
      16'b10001??????????? : begin instr_t16t32 = {10'b1100010110,instr_i[5:3],1'b0,instr_i[2:0],6'b000000,instr_i[10:6],1'b0}; cond = 4'b1110; end /* LDRH <Rd>  [<Rn>  #<imm5> * 2]_53  */
      16'b11010???1??????? : begin instr_t16t32 = {3'b101,instr_i[11:8],15'b111111101011111,instr_i[6:0]}; cond = instr_i[11:8]; end /* B<cond> <target_address>_4  */
      16'b110110??1??????? : begin instr_t16t32 = {3'b101,instr_i[11:8],15'b111111101011111,instr_i[6:0]}; cond = instr_i[11:8]; end /* (B<cond> <target_address>_4)_mod1  */
      16'b0100001100?????? : begin instr_t16t32 = {8'b01010010,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* ORR <Rd>  <Rm>_33  */
      16'b0100000000?????? : begin instr_t16t32 = {8'b01010000,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* AND <Rd>  <Rm>_21  */
      16'b0001110????????? : begin instr_t16t32 = {8'b10001000,~in_it_block_i,1'b0,instr_i[5:3],5'b00000,instr_i[2:0],5'b00000,instr_i[8:6]}; cond = 4'b1110; end /* ADD <Rd>  <Rn>  #<imm3>_12  */
      16'b1011101000?????? : begin instr_t16t32 = {10'b1101010010,instr_i[5:3],5'b11110,instr_i[2:0],5'b10000,instr_i[5:3]}; cond = 4'b1110; end /* REV <Rd>  <Rn>_71  */
      16'b0001111????????? : begin instr_t16t32 = {8'b10001101,~in_it_block_i,1'b0,instr_i[5:3],5'b00000,instr_i[2:0],5'b00000,instr_i[8:6]}; cond = 4'b1110; end /* SUB <Rd>  <Rn>  #<imm3>_13  */
      16'b10111100???????? : begin instr_t16t32 = {13'b0100010111101,instr_i[8],7'b0000000,instr_i[7:0]}; cond = 4'b1110; end /* (POP <register_list>_68)_mod1  */
      16'b010001101????110 : begin instr_t16t32 = {17'b01010010011110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (CPY <Rd>  <Rm>_47)_mod4  */
      16'b11001001??????0? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0010  */
      16'b111000?????????? : begin instr_t16t32 = {19'b1000000000000101110,instr_i[9:0]}; cond = 4'b1110; end /* B <target_address>_5  */
      16'b110011110??????? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1110  */
      16'b11001100???1???? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1001  */
      16'b1011111100000000 : begin instr_t16t32 = {25'b1001110101111100000000000,instr_i[7:4]}; cond = 4'b1110; end /* NOP | YIELD | WFE | WFI | SEV_81  */
      16'b110110??0??????? : begin instr_t16t32 = {3'b100,instr_i[11:8],15'b000000100000000,instr_i[6:0]}; cond = instr_i[11:8]; end /* (B<cond> <target_address>_3)_mod1  */
      16'b1011001010?????? : begin instr_t16t32 = {18'b110100001111111110,instr_i[2:0],5'b10000,instr_i[5:3]}; cond = 4'b1110; end /* UXTH <Rd>  <Rm>_79  */
      16'b10111111????1??? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* (IT{<x>{<y>{<z>}}} <cond>_82)_mod3  */
      16'b1011111100010000 : begin instr_t16t32 = {25'b1001110101111100000000000,instr_i[7:4]}; cond = 4'b1110; end /* (NOP | YIELD | WFE | WFI | SEV_81)_mod1  */
      16'b111001?????????? : begin instr_t16t32 = {19'b1011111111111101111,instr_i[9:0]}; cond = 4'b1110; end /* B <target_address>_6  */
      16'b0100001010?????? : begin instr_t16t32 = {10'b0101110110,instr_i[2:0],13'b0000111100000,instr_i[5:3]}; cond = 4'b1110; end /* CMP <Rn>  <Rm>_31  */
      16'b1101110?0??????? : begin instr_t16t32 = {3'b100,instr_i[11:8],15'b000000100000000,instr_i[6:0]}; cond = instr_i[11:8]; end /* (B<cond> <target_address>_3)_mod2  */
      16'b10111111????001? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* (IT{<x>{<y>{<z>}}} <cond>_82)_mod1  */
      16'b010001101????111 : begin instr_t16t32 = {17'b01010010011110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* CPY <Rd>  <Rm>_47  */
      16'b1011001001?????? : begin instr_t16t32 = {18'b110100100111111110,instr_i[2:0],5'b10000,instr_i[5:3]}; cond = 4'b1110; end /* SXTB <Rd>  <Rm>_78  */
      16'b0101111????????? : begin instr_t16t32 = {10'b1100100110,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* LDRSH <Rd>  [<Rn>  <Rm>]_61  */
      16'b0100001001?????? : begin instr_t16t32 = {8'b10001110,~in_it_block_i,1'b0,instr_i[5:3],5'b00000,instr_i[2:0],8'b00000000}; cond = 4'b1110; end /* NEG <Rd>  <Rm>_30  */
      16'b0100001111?????? : begin instr_t16t32 = {8'b01010011,~in_it_block_i,9'b111100000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* MVN <Rd>  <Rm>_36  */
      16'b10101???00?????? : begin instr_t16t32 = {18'b100010000110100000,instr_i[10:8],instr_i[5:0],2'b00}; cond = 4'b1110; end /* ADD <Rd>  SP  #<imm8> * 4_38  */
      16'b01110??????????? : begin instr_t16t32 = {10'b1100010000,instr_i[5:3],1'b0,instr_i[2:0],7'b0000000,instr_i[10:6]}; cond = 4'b1110; end /* STRB <Rd>  [<Rn>  #<imm5>]_50  */
      16'b0100000100?????? : begin instr_t16t32 = {8'b11010010,~in_it_block_i,1'b0,instr_i[2:0],5'b11110,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* ASR <Rd>  <Rs>_25  */
      16'b11001101??0????? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1010  */
      16'b10111111????0001 : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* IT{<x>{<y>{<z>}}} <cond>_82  */
      16'b1011?0?1???????? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* CBZ<cond> <Rn>  <target_address>_9  */
      16'b10111111001?0000 : begin instr_t16t32 = {25'b1001110101111100000000000,instr_i[7:4]}; cond = 4'b1110; end /* (NOP | YIELD | WFE | WFI | SEV_81)_mod2  */
      16'b11001110?1?????? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1101  */
      16'b010001001????111 : begin instr_t16t32 = {9'b010110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* ADD <Rd>  <Rm>_45  */
      16'b11001101??1????? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1011  */
      16'b01111??????????? : begin instr_t16t32 = {10'b1100010010,instr_i[5:3],1'b0,instr_i[2:0],7'b0000000,instr_i[10:6]}; cond = 4'b1110; end /* LDRB <Rd>  [<Rn>  #<imm5>]_51  */
      16'b10111111????01?? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* (IT{<x>{<y>{<z>}}} <cond>_82)_mod2  */
      16'b1011010????????? : begin instr_t16t32 = {14'b01001001011010,instr_i[8],6'b000000,instr_i[7:0]}; cond = 4'b1110; end /* PUSH <register_list>_67  */
      16'b1011000011?????? : begin instr_t16t32 = {22'b1010110101101011111011,instr_i[5:0],1'b0}; cond = 4'b1110; end /* SUB SP  SP  #<imm7> * 4_44  */
      16'b11001110?0?????? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1100  */
      16'b01100??????????? : begin instr_t16t32 = {10'b1100011000,instr_i[5:3],1'b0,instr_i[2:0],5'b00000,instr_i[10:6],2'b00}; cond = 4'b1110; end /* STR <Rd>  [<Rn>  #<imm5> * 4]_48  */
      16'b0100000010?????? : begin instr_t16t32 = {8'b11010000,~in_it_block_i,1'b0,instr_i[2:0],5'b11110,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* LSL <Rd>  <Rs>_23  */
      16'b00001??????????? : begin instr_t16t32 = {8'b01010010,~in_it_block_i,5'b11110,instr_i[10:8],1'b0,instr_i[2:0],instr_i[7:6],3'b010,instr_i[5:3]}; cond = 4'b1110; end /* LSR <Rd>  <Rm>  #<shift_imm>_19  */
      16'b0101000????????? : begin instr_t16t32 = {10'b1100001000,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* STR <Rd>  [<Rn>  <Rm>]_54  */
      16'b11001011????0??? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0110  */
      16'b11011111???????? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* SWI <imm8>_76  */
      16'b01001??????????? : begin instr_t16t32 = {14'b11000110111110,instr_i[10:8],2'b00,instr_i[7:0],2'b00}; cond = 4'b1110; end /* LDR <Rd>  [PC  #<imm8> * 4]_62  */
      16'b0100000111?????? : begin instr_t16t32 = {8'b11010011,~in_it_block_i,1'b0,instr_i[2:0],5'b11110,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* ROR <Rd>  <Rs>_28  */
      16'b010001101????0?? : begin instr_t16t32 = {17'b01010010011110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (CPY <Rd>  <Rm>_47)_mod2  */
      16'b0100001011?????? : begin instr_t16t32 = {10'b0101100010,instr_i[2:0],13'b0000111100000,instr_i[5:3]}; cond = 4'b1110; end /* CMN <Rn>  <Rm>_32  */
      16'b110011111??????? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1111  */
      16'b1011000001?????? : begin instr_t16t32 = {22'b1010100001101011111011,instr_i[5:0],1'b0}; cond = 4'b1110; end /* ADD SP  SP  #<imm7> * 4_42  */
      16'b0100000101?????? : begin instr_t16t32 = {8'b01011010,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* ADC <Rd>  <Rm>_26  */
      16'b1011001000?????? : begin instr_t16t32 = {18'b110100000111111110,instr_i[2:0],5'b10000,instr_i[5:3]}; cond = 4'b1110; end /* SXTH <Rd>  <Rm>_77  */
      16'b010001000??????? : begin instr_t16t32 = {9'b010110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (ADD <Rd>  <Rm>_45)_mod1  */
      16'b010001001????10? : begin instr_t16t32 = {9'b010110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (ADD <Rd>  <Rm>_45)_mod3  */
      16'b11001100???0???? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod1000  */
      16'b0101101????????? : begin instr_t16t32 = {10'b1100000110,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* LDRH <Rd>  [<Rn>  <Rm>]_59  */
      16'b010001100??????? : begin instr_t16t32 = {17'b01010010011110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (CPY <Rd>  <Rm>_47)_mod1  */
      16'b11010???0??????? : begin instr_t16t32 = {3'b100,instr_i[11:8],15'b000000100000000,instr_i[6:0]}; cond = instr_i[11:8]; end /* B<cond> <target_address>_3  */
      16'b010001111??????? : begin instr_t16t32 = {9'b101111000,instr_i[6],instr_i[5:3],16'b1000111100000010}; cond = 4'b1110; end /* BLX <Rm>_8  */
      16'b0100001101?????? : begin instr_t16t32 = {10'b1101100000,instr_i[5:3],5'b11110,instr_i[2:0],2'b00,~in_it_block_i,2'b00,instr_i[2:0]}; cond = 4'b1110; end /* MUL <Rd>  <Rm>_34  */
      16'b10010??????????? : begin instr_t16t32 = {14'b11000110011010,instr_i[10:8],2'b00,instr_i[7:0],2'b00}; cond = 4'b1110; end /* STR <Rd>  [SP  #<imm8> * 4]_63  */
      16'b11000??????????? : begin instr_t16t32 = {10'b0100010100,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* STMIA <Rn>!  <register_list>_65  */
      16'b010001101????10? : begin instr_t16t32 = {17'b01010010011110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (CPY <Rd>  <Rm>_47)_mod3  */
      16'b10111101???????? : begin instr_t16t32 = {13'b0100010111101,instr_i[8],7'b0000000,instr_i[7:0]}; cond = 4'b1110; end /* POP <register_list>_68  */
      16'b00101??????????? : begin instr_t16t32 = {10'b1000110110,instr_i[10:8],8'b00001111,instr_i[7:0]}; cond = 4'b1110; end /* CMP <Rn>  #<imm8>_15  */
      16'b11001010?????0?? : begin instr_t16t32 = {7'b0100010,1'b1,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0100  */
      16'b0101001????????? : begin instr_t16t32 = {10'b1100000100,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* STRH <Rd>  [<Rn>  <Rm>]_55  */
      16'b1101110?1??????? : begin instr_t16t32 = {3'b101,instr_i[11:8],15'b111111101011111,instr_i[6:0]}; cond = instr_i[11:8]; end /* (B<cond> <target_address>_4)_mod2  */
      16'b10110110011????? : begin instr_t16t32 = {19'b1001110101111100001,instr_i[4],1'b0,instr_i[2],instr_i[1],instr_i[0],5'b00000}; cond = 4'b1110; end /* CPS<effect> <iflags>_69  */
      16'b0101100????????? : begin instr_t16t32 = {10'b1100001010,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* LDR <Rd>  [<Rn>  <Rm>]_58  */
      16'b0101110????????? : begin instr_t16t32 = {10'b1100000010,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* LDRB <Rd>  [<Rn>  <Rm>]_60  */
      16'b10100??????????? : begin instr_t16t32 = {15'b100100000111100,instr_i[7:6],1'b0,instr_i[10:8],instr_i[5:0],2'b00}; cond = 4'b1110; end /* ADD <Rd>  PC  #<imm8> * 4_37  */
      16'b1011000010?????? : begin instr_t16t32 = {21'b100011010110100001101,instr_i[5:0],2'b00}; cond = 4'b1110; end /* SUB SP  SP  #<imm7> * 4_43  */
      16'b11001010?????1?? : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0101  */
      16'b0100001000?????? : begin instr_t16t32 = {10'b0101000010,instr_i[2:0],13'b0000111100000,instr_i[5:3]}; cond = 4'b1110; end /* TST <Rn>  <Rm>_29  */
      16'b0100000110?????? : begin instr_t16t32 = {8'b01011011,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* SBC <Rd>  <Rm>_27  */
      16'b0100000001?????? : begin instr_t16t32 = {8'b01010100,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* EOR <Rd>  <Rm>_22  */
      16'b01101??????????? : begin instr_t16t32 = {10'b1100011010,instr_i[5:3],1'b0,instr_i[2:0],5'b00000,instr_i[10:6],2'b00}; cond = 4'b1110; end /* LDR <Rd>  [<Rn>  #<imm5> * 4]_49  */
      16'b10111110???????? : begin instr_t16t32 = {13'b0000000000000, instr_i[15:0]}; cond = 4'b1110; end /* BKPT <imm8>_74  */
      16'b10000??????????? : begin instr_t16t32 = {10'b1100010100,instr_i[5:3],1'b0,instr_i[2:0],6'b000000,instr_i[10:6],1'b0}; cond = 4'b1110; end /* STRH <Rd>  [<Rn>  #<imm5> * 2]_52  */
      16'b0101010????????? : begin instr_t16t32 = {10'b1100000000,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* STRB <Rd>  [<Rn>  <Rm>]_56  */
      16'b00110??????????? : begin instr_t16t32 = {8'b10001000,~in_it_block_i,1'b0,instr_i[10:8],5'b00000,instr_i[10:8],instr_i[7:0]}; cond = 4'b1110; end /* ADD <Rd>  #<imm8>_16  */
      16'b11001000???????1 : begin instr_t16t32 = {7'b0100010,1'b0,2'b10,instr_i[10:8],8'b00000000,instr_i[7:0]}; cond = 4'b1110; end /* (LDMIA <Rn>!  <register_list>_66)_mod0001  */
      16'b00000??????????? : begin instr_t16t32 = {8'b01010010,~in_it_block_i,5'b11110,instr_i[10:8],1'b0,instr_i[2:0],instr_i[7:6],3'b000,instr_i[5:3]}; cond = 4'b1110; end /* LSL <Rd>  <Rm>  #<shift_imm>_18  */
      16'b00010??????????? : begin instr_t16t32 = {8'b01010010,~in_it_block_i,5'b11110,instr_i[10:8],1'b0,instr_i[2:0],instr_i[7:6],3'b100,instr_i[5:3]}; cond = 4'b1110; end /* ASR <Rd>  <Rm>  #<shift_imm>_20  */
      16'b00111??????????? : begin instr_t16t32 = {8'b10001101,~in_it_block_i,1'b0,instr_i[10:8],5'b00000,instr_i[10:8],instr_i[7:0]}; cond = 4'b1110; end /* SUB <Rd>  #<imm8>_17  */
      16'b0101011????????? : begin instr_t16t32 = {10'b1100100010,instr_i[5:3],1'b0,instr_i[2:0],9'b000000000,instr_i[8:6]}; cond = 4'b1110; end /* LDRSB <Rd>  [<Rn>  <Rm>]_57  */
      16'b1011101011?????? : begin instr_t16t32 = {10'b1101010010,instr_i[5:3],5'b11110,instr_i[2:0],5'b10110,instr_i[5:3]}; cond = 4'b1110; end /* REVSH <Rd>  <Rn>_73  */
      16'b010001001????0?? : begin instr_t16t32 = {9'b010110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (ADD <Rd>  <Rm>_45)_mod2  */
      16'b0100000011?????? : begin instr_t16t32 = {8'b11010001,~in_it_block_i,1'b0,instr_i[2:0],5'b11110,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* LSR <Rd>  <Rs>_24  */
      16'b101111111???0000 : begin instr_t16t32 = {25'b1001110101111100000000000,instr_i[7:4]}; cond = 4'b1110; end /* (NOP | YIELD | WFE | WFI | SEV_81)_mod4  */
      16'b010001001????110 : begin instr_t16t32 = {9'b010110000,instr_i[7],instr_i[2:0],4'b0000,instr_i[7],instr_i[2:0],4'b0000,instr_i[6],instr_i[5:3]}; cond = 4'b1110; end /* (ADD <Rd>  <Rm>_45)_mod4  */
      16'b10011??????????? : begin instr_t16t32 = {14'b11000110111010,instr_i[10:8],2'b00,instr_i[7:0],2'b00}; cond = 4'b1110; end /* LDR <Rd>  [SP  #<imm8> * 4]_64  */
      16'b0100001110?????? : begin instr_t16t32 = {8'b01010001,~in_it_block_i,1'b0,instr_i[2:0],5'b00000,instr_i[2:0],5'b00000,instr_i[5:3]}; cond = 4'b1110; end /* BIC <Rd>  <Rm>_35  */
      16'b1011101001?????? : begin instr_t16t32 = {10'b1101010010,instr_i[5:3],5'b11110,instr_i[2:0],5'b10010,instr_i[5:3]}; cond = 4'b1110; end /* REV16 <Rd>  <Rn>_72  */
      default : begin instr_t16t32 = {29{1'bx}}; cond = {4{1'bx}}; end
    endcase

  wire   net_0_1, net_0_2, net_0_3, net_0_4, net_0_5, net_0_6, net_0_7, net_0_8, net_0_9, net_0_10,
         net_0_11, net_0_12, net_0_13, net_0_14, net_0_15, net_0_16, net_0_17, net_0_18,
         net_0_19, net_0_20, net_0_21, net_0_22, net_0_23, net_0_24, net_0_25, net_0_26,
         net_0_27, net_0_28, net_0_29, net_0_30, net_0_31, net_0_32, net_0_33, net_0_34,
         net_0_35, net_0_36, net_0_37, net_0_38, net_0_39, net_0_40, net_0_41, net_0_42,
         net_0_43, net_0_44, net_0_45, net_0_46, net_0_47, net_0_48, net_0_49, net_0_50,
         net_0_51, net_0_52, net_0_53, net_0_54, net_0_55, net_0_56, net_0_57, net_0_58,
         net_0_59, net_0_60, net_0_61, net_0_62, net_0_63, net_0_64, net_0_65, net_0_66,
         net_0_67, net_0_68, net_0_69, net_0_70, net_0_71, net_0_72, net_0_73, net_0_74,
         net_0_75, net_0_76, net_0_77, net_0_78, net_0_79, net_0_80, net_0_81, net_0_82,
         net_0_83, net_0_84, net_0_85, net_0_86, net_0_87, net_0_88, net_0_89, net_0_90,
         net_0_91, net_0_92, net_0_93, net_0_94, net_0_95, net_0_96, net_0_97, net_0_98,
         net_0_99, net_0_100, net_0_101, net_0_102, net_0_103, net_0_104, net_0_105, net_0_106,
         net_0_107, net_0_108, net_0_109, net_0_110, net_0_111, net_0_112, net_0_113,
         net_0_114, net_0_115, net_0_116, net_0_117, net_0_118, net_0_119, net_0_120,
         net_0_121, net_0_122, net_0_123, net_0_124, net_0_125, net_0_126, net_0_127,
         net_0_128, net_0_129, net_0_130, net_0_131, net_0_132, net_0_133, net_0_134,
         net_0_135, net_0_136, net_0_137, net_0_138, net_0_139, net_0_140, net_0_141,
         net_0_142, net_0_143, net_0_144, net_0_145, net_0_146, net_0_147, net_0_148,
         net_0_149, net_0_150, net_0_151, net_0_152, net_0_153, net_0_154, net_0_155,
         net_0_156, net_0_157, net_0_158, net_0_159, net_0_160, net_0_161, net_0_162,
         net_0_163, net_0_164, net_0_165, net_0_166, net_0_167, net_0_168, net_0_169,
         net_0_170, net_0_171, net_0_172, net_0_173, net_0_174, net_0_175, net_0_176,
         net_0_177;

  assign net_0_1 = ~instr_i[15];
  assign net_0_2 = ~instr_i[14];
  assign net_0_3 = ~instr_i[13];
  assign net_0_4 = ~instr_i[12];
  assign net_0_5 = ~instr_i[10];
  assign net_0_6 = ~instr_i[9];
  assign net_0_7 = ~instr_i[8];
  assign net_0_8 = ~instr_i[7];
  assign net_0_9 = ~instr_i[6];
  assign defined_sideband[5] = (net_0_10 | net_0_11);
  assign net_0_11 = (instr_i[14] & net_0_12);
  assign net_0_12 = ~(net_0_13 & net_0_14);
  assign net_0_14 = ~(instr_i[15] & net_0_15);
  assign net_0_15 = (net_0_16 & net_0_17);
  assign net_0_17 = ~(net_0_18 & net_0_19);
  assign net_0_13 = ~(net_0_20 & net_0_21);
  assign net_0_21 = (net_0_22 & net_0_23);
  assign net_0_23 = (instr_i[13] | net_0_24);
  assign net_0_20 = (instr_i[13] ^ net_0_1);
  assign net_0_10 = (net_0_25 & net_0_26);
  assign net_0_26 = ~(net_0_27 & net_0_28);
  assign net_0_27 = ~(net_0_29 | net_0_30);
  assign net_0_30 = (net_0_19 & net_0_31);
  assign net_0_31 = (instr_i[11] | net_0_32);
  assign defined_sideband[4] = ~(net_0_33 & net_0_34);
  assign net_0_34 = (net_0_35 | net_0_4);
  assign net_0_35 = (net_0_36 & net_0_37);
  assign net_0_37 = ~(net_0_38 & net_0_39);
  assign net_0_33 = (net_0_40 & net_0_41);
  assign net_0_41 = ~(net_0_38 & net_0_3);
  assign net_0_40 = (net_0_42 & net_0_43);
  assign defined_sideband[3] = ~(net_0_44 & net_0_45);
  assign net_0_45 = (net_0_46 & net_0_47);
  assign net_0_47 = ~(instr_i[13] & net_0_48);
  assign net_0_48 = (net_0_38 & net_0_4);
  assign net_0_46 = (net_0_49 | instr_i[15]);
  assign net_0_44 = (net_0_50 & net_0_51);
  assign net_0_51 = ~(net_0_52 & net_0_53);
  assign net_0_53 = ~(net_0_54 & net_0_55);
  assign net_0_55 = ~(net_0_6 ^ net_0_5);
  assign net_0_54 = ~(net_0_56 | net_0_57);
  assign net_0_57 = (net_0_6 & net_0_58);
  assign net_0_58 = ~(net_0_59 & net_0_60);
  assign net_0_60 = ~(instr_i[6] & net_0_8);
  assign net_0_59 = ~(instr_i[8] & net_0_61);
  assign net_0_56 = (net_0_62 | instr_i[11]);
  assign net_0_62 = (net_0_7 & net_0_63);
  assign net_0_63 = (net_0_8 | instr_i[10]);
  assign net_0_50 = (net_0_64 & net_0_65);
  assign net_0_65 = (instr_i[14] | net_0_66);
  assign net_0_66 = (net_0_67 & net_0_68);
  assign net_0_68 = ~(instr_i[13] & net_0_69);
  assign net_0_69 = (net_0_39 & net_0_18);
  assign net_0_67 = (net_0_70 & net_0_71);
  assign net_0_71 = ~(instr_i[11] & net_0_1);
  assign net_0_70 = (net_0_72 & net_0_73);
  assign net_0_73 = (net_0_74 & net_0_75);
  assign net_0_75 = ~(net_0_76 & net_0_29);
  assign net_0_29 = (instr_i[8] & net_0_5);
  assign net_0_74 = (net_0_49 | instr_i[9]);
  assign net_0_49 = (instr_i[11] | net_0_4);
  assign net_0_72 = (instr_i[13] | instr_i[11]);
  assign net_0_64 = (net_0_77 & net_0_78);
  assign net_0_78 = (net_0_2 | net_0_43);
  assign net_0_77 = (net_0_42 | instr_i[11]);
  assign net_0_42 = (net_0_3 | net_0_36);
  assign defined_sideband[2] = ~(net_0_79 & net_0_80);
  assign net_0_80 = ~(net_0_52 & net_0_81);
  assign net_0_81 = ~(net_0_82 & net_0_83);
  assign net_0_83 = (net_0_84 & net_0_85);
  assign net_0_85 = (instr_i[14] | instr_i[11]);
  assign net_0_82 = (net_0_86 & net_0_87);
  assign net_0_87 = ~(instr_i[10] & instr_i[14]);
  assign net_0_86 = (net_0_88 | instr_i[10]);
  assign net_0_88 = (net_0_4 & net_0_89);
  assign net_0_89 = (net_0_90 & net_0_91);
  assign net_0_91 = (instr_i[6] | net_0_92);
  assign net_0_90 = (net_0_93 & net_0_94);
  assign net_0_94 = (net_0_9 | net_0_95);
  assign net_0_93 = (net_0_6 | net_0_96);
  assign net_0_52 = ~(instr_i[15] | instr_i[13]);
  assign net_0_79 = ~(net_0_25 & net_0_97);
  assign net_0_97 = ~(net_0_98 & net_0_99);
  assign net_0_99 = ~(net_0_100 & instr_i[11]);
  assign net_0_100 = (instr_i[8] & net_0_39);
  assign net_0_39 = ~(instr_i[9] | net_0_5);
  assign net_0_98 = ~(net_0_101 & instr_i[9]);
  assign net_0_101 = ~(net_0_102 | net_0_103);
  assign net_0_25 = (net_0_38 & net_0_76);
  assign net_0_38 = ~(instr_i[14] | net_0_1);
  assign defined_sideband[1] = ~(net_0_104 & net_0_105);
  assign net_0_105 = (net_0_106 | instr_i[14]);
  assign net_0_106 = (net_0_107 & net_0_108);
  assign net_0_108 = ~(instr_i[15] & net_0_109);
  assign net_0_109 = ~(net_0_76 & net_0_110);
  assign net_0_110 = (net_0_111 & net_0_112);
  assign net_0_112 = (net_0_113 | net_0_61);
  assign net_0_113 = ~(instr_i[9] & net_0_5);
  assign net_0_111 = (net_0_19 | net_0_18);
  assign net_0_18 = (instr_i[11] & net_0_7);
  assign net_0_76 = (instr_i[13] & instr_i[12]);
  assign net_0_107 = ~(instr_i[11] & net_0_114);
  assign net_0_114 = ~(net_0_115 & net_0_116);
  assign net_0_116 = ~(net_0_117 & instr_i[13]);
  assign net_0_115 = ~(net_0_16 & instr_i[10]);
  assign net_0_16 = ~(instr_i[13] | net_0_4);
  assign net_0_104 = (net_0_118 & net_0_119);
  assign net_0_119 = (net_0_120 | net_0_36);
  assign net_0_36 = ~(instr_i[14] & net_0_1);
  assign net_0_120 = ~(instr_i[13] | net_0_121);
  assign net_0_121 = ~(net_0_84 & net_0_122);
  assign net_0_122 = (net_0_123 | instr_i[11]);
  assign net_0_123 = (net_0_124 & net_0_125);
  assign net_0_125 = (net_0_4 | net_0_19);
  assign net_0_124 = (net_0_126 | instr_i[10]);
  assign net_0_126 = (net_0_127 & net_0_128);
  assign net_0_128 = ~(instr_i[9] & net_0_32);
  assign net_0_127 = (instr_i[9] | net_0_129);
  assign net_0_129 = (net_0_130 ^ net_0_8);
  assign net_0_84 = ~(instr_i[11] & net_0_4);
  assign net_0_118 = (net_0_131 & net_0_132);
  assign net_0_132 = ~(instr_i[13] & net_0_133);
  assign net_0_133 = ~(instr_i[15] | net_0_22);
  assign net_0_22 = ~(instr_i[12] | instr_i[11]);
  assign net_0_131 = (instr_i[11] | net_0_43);
  assign net_0_43 = (instr_i[13] | net_0_134);
  assign net_0_134 = ~(instr_i[15] & net_0_4);
  assign defined_sideband[0] = (net_0_135 | net_0_136);
  assign net_0_136 = ~(net_0_137 & net_0_138);
  assign net_0_138 = (instr_i[14] | net_0_139);
  assign net_0_139 = (instr_i[15] & net_0_140);
  assign net_0_140 = (net_0_141 & net_0_142);
  assign net_0_142 = ~(instr_i[13] & net_0_143);
  assign net_0_143 = (net_0_144 | net_0_145);
  assign net_0_145 = ~(instr_i[12] & net_0_146);
  assign net_0_146 = (net_0_28 | instr_i[8]);
  assign net_0_28 = ~(instr_i[9] & net_0_102);
  assign net_0_102 = (instr_i[11] & net_0_61);
  assign net_0_61 = ~(instr_i[6] | net_0_8);
  assign net_0_144 = (net_0_147 & net_0_148);
  assign net_0_148 = ~(net_0_117 & instr_i[9]);
  assign net_0_117 = (net_0_130 & net_0_149);
  assign net_0_149 = (net_0_150 & net_0_151);
  assign net_0_151 = ~(instr_i[1] | instr_i[0]);
  assign net_0_150 = ~(instr_i[5] | net_0_152);
  assign net_0_152 = (instr_i[7] | net_0_153);
  assign net_0_153 = (instr_i[4] | net_0_154);
  assign net_0_154 = (instr_i[3] | instr_i[2]);
  assign net_0_130 = ~(instr_i[6] | net_0_7);
  assign net_0_147 = (instr_i[11] & instr_i[10]);
  assign net_0_141 = (instr_i[11] | net_0_155);
  assign net_0_155 = (net_0_156 & instr_i[13]);
  assign net_0_156 = (net_0_157 & net_0_158);
  assign net_0_158 = (instr_i[9] | net_0_103);
  assign net_0_103 = (instr_i[10] | instr_i[8]);
  assign net_0_157 = ~(net_0_19 & net_0_32);
  assign net_0_32 = (instr_i[6] & net_0_96);
  assign net_0_96 = ~(instr_i[8] | instr_i[7]);
  assign net_0_137 = (instr_i[15] | net_0_159);
  assign net_0_159 = (instr_i[11] | net_0_160);
  assign net_0_160 = ~(instr_i[13] | net_0_161);
  assign net_0_161 = ~(net_0_162 & net_0_163);
  assign net_0_163 = (instr_i[12] | net_0_164);
  assign net_0_164 = (net_0_165 & net_0_166);
  assign net_0_166 = (instr_i[10] & net_0_92);
  assign net_0_92 = (instr_i[8] ^ instr_i[7]);
  assign net_0_165 = (net_0_167 & net_0_95);
  assign net_0_95 = (instr_i[9] | instr_i[7]);
  assign net_0_167 = (net_0_168 & net_0_169);
  assign net_0_169 = ~(instr_i[7] & net_0_170);
  assign net_0_170 = ~(instr_i[1] & instr_i[2]);
  assign net_0_168 = (instr_i[8] | instr_i[0]);
  assign net_0_162 = ~(instr_i[12] & net_0_19);
  assign net_0_135 = (instr_i[11] & net_0_171);
  assign net_0_171 = ~(instr_i[13] | net_0_172);
  assign net_0_172 = ~(net_0_173 & net_0_174);
  assign net_0_174 = ~(net_0_175 & net_0_176);
  assign net_0_176 = ~(instr_i[12] & net_0_24);
  assign net_0_24 = (instr_i[8] & net_0_19);
  assign net_0_19 = (instr_i[10] & instr_i[9]);
  assign net_0_175 = (net_0_4 ^ instr_i[15]);
  assign net_0_173 = (net_0_177 | instr_i[14]);
  assign net_0_177 = ~(net_0_4 | instr_i[15]);

  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53ifu_defs.v"
`undef CA53_UNDEFINE
/*END*/
