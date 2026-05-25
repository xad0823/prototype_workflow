//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
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
// Auto generated function do not modify
//
function automatic [31:0] t32_to_a32(input [39:0] enc);

  // use inside variables which must have been populated
  // using do_a32_icb_encoding

  reg p_a32, w_a32;
  reg cond_code_nv;
  reg done;
  
begin
  done = 0;
  cond_code_nv = enc[39:36] == 4'hf;

  // We need to calculate the PW encoding
  // Because in the raw encoding the bits are at different locations
  // we cannot do that in advance
  //
  //           T32 | A32
  // ----------+----+----+
  // un-index  | 00 | 01 |
  // post-index| 01 | 00 |
  // offset    | 10 | 10 |
  // pre-index | 11 | 11 |

  // Special case 1 : ADD immediate vs CMN immediate
  if ((enc[19] == 1'b0) && (enc[12:11] == 2'b10) &&
      (enc[9:5] == 5'b01000) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMN immediate
      t32_to_a32 = {enc[39:36],7'b0011011,enc[4],enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]};
    end else begin
      // ADD immediate
      t32_to_a32 = {enc[39:36],7'b0010100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end
    done = 1;
  end
  // Special case 2 : AND immediate vs TST immediate
  else if ((enc[19] == 1'b0) && (enc[12:11] == 2'b10) &&
      (enc[9:5] == 5'b00000) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TST immediate
      t32_to_a32 = {enc[39:36],7'b0011000,enc[4],enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]};
    end else begin
      // AND immediate
      t32_to_a32 = {enc[39:36],7'b0010000,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end
    done = 1;
  end
  // Special case 3 : SUB immediate vs CMP immediate
  else if ((enc[19] == 1'b0) && (enc[12:11] == 2'b10) &&
      (enc[9:5] == 5'b01101) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMP immediate
      t32_to_a32 = {enc[39:36],7'b0011010,enc[4],enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]};
    end else begin
      // SUB immediate
      t32_to_a32 = {enc[39:36],7'b0010010,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end
    done = 1;
  end
  // Special case 4 : EOR immediate vs TEQ immediate
  else if ((enc[19] == 1'b0) && (enc[12:11] == 2'b10) &&
      (enc[9:5] == 5'b00100) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TEQ immediate
      t32_to_a32 = {enc[39:36],7'b0011001,enc[4],enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]};
    end else begin
      // EOR immediate
      t32_to_a32 = {enc[39:36],7'b0010001,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end
    done = 1;
  end
  // Special case 5 : ADD register vs CMN register
  else if ((enc[19] == 1'b0) && (enc[12:5] == 8'b01011000) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMN register
      t32_to_a32 = {enc[39:36],7'b0001011,enc[4],enc[3:0],4'b0000,enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end else begin
      // ADD register
      t32_to_a32 = {enc[39:36],7'b0000100,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end
    done = 1;
  end
  // Special case 6 : AND register vs TST register
  else if ((enc[19] == 1'b0) && (enc[12:5] == 8'b01010000) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TST register
      t32_to_a32 = {enc[39:36],7'b0001000,enc[4],enc[3:0],4'b0000,enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end else begin
      // AND register
      t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end
    done = 1;
  end
  // Special case 7 : SUB register vs CMP register
  else if ((enc[19] == 1'b0) && (enc[12:5] == 8'b01011101) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMP register
      t32_to_a32 = {enc[39:36],7'b0001010,enc[4],enc[3:0],4'b0000,enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end else begin
      // SUB register
      t32_to_a32 = {enc[39:36],7'b0000010,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end
    done = 1;
  end
  // Special case 8 : EOR register vs TEQ register
  else if ((enc[19] == 1'b0) && (enc[12:5] == 8'b01010100) && (enc[35] == 1'b0)) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TEQ register
      t32_to_a32 = {enc[39:36],7'b0001001,enc[4],enc[3:0],4'b0000,enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end else begin
      // EOR register
      t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:24],1'b0,enc[23:20]};
    end
    done = 1;
  end
  // Special case 9 : ADD register-shifted register vs CMN register-shifted register
  else if ((enc[19] == 1'b1) && (enc[12:5] == 8'b01011000) && (enc[27:26] == 2'b00) && (enc[39:36] != 4'b1111) ) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMN register-shifted register
      t32_to_a32 = {enc[39:36],7'b0001011,enc[4],enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end else begin
      // ADD register-shifted register
      t32_to_a32 = {enc[39:36],7'b0000100,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end
    done = 1;
  end
  // Special case 10 : AND register-shifted register vs TST register-shifted register
  else if ((enc[19] == 1'b1) && (enc[12:5] == 8'b01010000) && (enc[27:26] == 2'b00) && (enc[39:36] != 4'b1111) ) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TST register-shifted register
      t32_to_a32 = {enc[39:36],7'b0001000,enc[4],enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end else begin
      // AND register-shifted register
      t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end
    done = 1;
  end
  // Special case 11 : SUB register-shifted register vs CMP register-shifted register
  else if ((enc[19] == 1'b1) && (enc[12:5] == 8'b01011101) && (enc[27:26] == 2'b00) && (enc[39:36] != 4'b1111) ) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // CMP register-shifted register
      t32_to_a32 = {enc[39:36],7'b0001010,enc[4],enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end else begin
      // SUB register-shifted register
      t32_to_a32 = {enc[39:36],7'b0000010,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end
    done = 1;
  end
  // Special case 12 : EOR register-shifted register vs TEQ register-shifted register
  else if ((enc[19] == 1'b1) && (enc[12:5] == 8'b01010100) && (enc[27:26] == 2'b00) && (enc[39:36] != 4'b1111) ) begin
    if ((enc[4] == 1'b1) && (enc[31:28] == 4'b1111)) begin
      // TEQ register-shifted register
      t32_to_a32 = {enc[39:36],7'b0001001,enc[4],enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end else begin
      // EOR register-shifted register
      t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]};
    end
    done = 1;
  end
  // Special case 13 : ORR immediate vs MOV immediate
  else if ((enc[19] == 1'b0) && (enc[12:11] == 2'b10) &&
      (enc[9:5] == 5'b00010) && (enc[35] == 1'b0)) begin
    if (enc[3:0] == 4'b1111) begin
      // MOV immediate
      t32_to_a32 = {enc[39:36],7'b0011101,enc[4],4'b0000,enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end else begin
      // ORR immediate
      t32_to_a32 = {enc[39:36],7'b0011100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    end
    done = 1;
  end
  // Special case 14 : ORR register vs MOV register, ASR immediate, LSR immediate, ROR immediate
  else if ((enc[19] == 1'b0) && (enc[12:5] == 8'b01010010) && (enc[35] == 1'b0)) begin
    if (enc[3:0] == 4'b1111) begin
      case (enc[25:24])
        2'b00 : t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b000,enc[23:20]}; // MOV register
        2'b01 : t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b010,enc[23:20]}; // LSR immediate
        2'b10 : t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b100,enc[23:20]}; // ASR immediate
        2'b11 : t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b110,enc[23:20]}; // ROR immediate
      endcase
    end else begin
      // ORR register
      t32_to_a32 = {enc[39:36],7'b0001100,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]};
    end
    done = 1;
  end
  // Special case 15 : SSAT vs SSAT16
  else if ((enc[19] == 1'b0) && (enc[12:6] == 7'b1001100) && (enc[4] == 1'b0) && (enc[35] == 1'b0) && (enc[25] == 1'b0)) begin
    if ((enc[5] == 1'b1) && (enc[34:32] == 3'b000) && (enc[27:26] == 2'b00) && (enc[24] == 1'b0)) begin
      // SSAT16
      t32_to_a32 = {enc[39:36],8'b01101010,enc[23:20],enc[31:28],4'b1111,4'b0011,enc[3:0]};
    end else begin
      // SSAT
      t32_to_a32 = {enc[39:36],7'b0110101,enc[24:20],enc[31:28],enc[34:32],enc[27:26],enc[5],2'b01,enc[3:0]};
    end
    done = 1;
  end
  // Special case 16 : USAT vs USAT16
  else if ((enc[19] == 1'b0) && (enc[12:6] == 7'b1001110) && (enc[4] == 1'b0) && (enc[35] == 1'b0) && (enc[25] == 1'b0)) begin
    if ((enc[5] == 1'b1) && (enc[34:32] == 3'b000) && (enc[27:26] == 2'b00) && (enc[24] == 1'b0)) begin
      // USAT16
      t32_to_a32 = {enc[39:36],8'b01101110,enc[23:20],enc[31:28],4'b1111,4'b0011,enc[3:0]};
    end else begin
      // USAT
      t32_to_a32 = {enc[39:36],7'b0110111,enc[24:20],enc[31:28],enc[34:32],enc[27:26],enc[5],2'b01,enc[3:0]};
    end
    done = 1;
  end
  // Special case 17a : MUL vs MLA not a32 only
  else if ((enc[12:4] == 9'b110110000) && (enc[27:24] == 4'b0000) && (enc[39:36] != 4'b1111)) begin
    if (enc[35:32] == 4'b1111) begin
      // MUL
      t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[31:28],4'b0000,enc[23:20],4'b1001,enc[3:0]};
    end else begin
      // MLA
      t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]};
    end
    done = 1;
  end
  // Special case 17b : MUL vs MLA a32 only
  else if ((enc[19] == 1'b1) && (enc[12:4] == 9'b110110001) && (enc[27:24] == 4'b0000) && (enc[39:36] != 4'b1111)) begin
    if (enc[35:32] == 4'b1111) begin
      // MUL
      t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[31:28],4'b0000,enc[23:20],4'b1001,enc[3:0]};
    end else begin
      // MLA
      t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]};
    end
    done = 1;
  end
  // Special case 18 : SMUL_X_Y vs SMLA_X_Y
  else if ((enc[19] == 1'b0) && (enc[12:4] == 9'b110110001) && (enc[27:26] == 2'b00)) begin
    if (enc[35:32] == 4'b1111) begin
      // SMUL_X_Y
      t32_to_a32 = {enc[39:36],8'b00010110,enc[31:28],4'b0000,enc[23:20],1'b1,enc[24],enc[25],1'b0,enc[3:0]};
    end else begin
      // SMLA_X_Y
      t32_to_a32 = {enc[39:36],8'b00010000,enc[31:28],enc[35:32],enc[23:20],1'b1,enc[24],enc[25],1'b0,enc[3:0]};
    end
    done = 1;
  end
  // Special case 19 : SMULW vs SMLAW
  else if ((enc[19] == 1'b0) && (enc[12:4] == 9'b110110011) && (enc[27:25] == 3'b000)) begin
    if (enc[35:32] == 4'b1111) begin
      // SMULW
      t32_to_a32 = {enc[39:36],8'b00010010,enc[31:28],4'b0000,enc[23:20],1'b1,enc[24],2'b10,enc[3:0]};
    end else begin
      // SMLAW
      t32_to_a32 = {enc[39:36],8'b00010010,enc[31:28],enc[35:32],enc[23:20],1'b1,enc[24],2'b00,enc[3:0]};
    end
    done = 1;
  end
  // Special case 20 : SMMUL vs SMMLA
  else if ((enc[19] == 1'b0) && (enc[12:4] == 9'b110110101) && (enc[27:25] == 3'b000)) begin
    if (enc[35:32] == 4'b1111) begin
      // SMMUL
      t32_to_a32 = {enc[39:36],8'b01110101,enc[31:28],4'b1111,enc[23:20],2'b00,enc[24],1'b1,enc[3:0]};
    end else begin
      // SMMLA
      t32_to_a32 = {enc[39:36],8'b01110101,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]};
    end
    done = 1;
  end
  // Special case 21 : LDRD immediate vs LDRD literal vs Related Encodings (LDREX - LDREXB - LDREXH - LDREXD )
  else if ((enc[19] == 1'b0) && (enc[12:9] == 4'b0100) && (enc[6] == 1'b1) && (enc[4] == 1'b1)) begin
    if ((enc[8] == 1'b0) && (enc[5] == 1'b0)) begin
      // LDREX - LDREXB - LDREXH - LDREXD
      case ({enc[7],enc[27:24]})
        5'b00000 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b001,enc[3:0],enc[35:32],4'b1111,4'b1001,4'b1111}; done = 1; end// LDREX
        5'b10100 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b101,enc[3:0],enc[35:32],4'b1111,4'b1001,4'b1111}; done = 1; end// LDREXB
        5'b10101 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b111,enc[3:0],enc[35:32],4'b1111,4'b1001,4'b1111}; done = 1; end// LDREXH
        5'b10111 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b011,enc[3:0],enc[35:32],4'b1111,4'b1001,4'b1111}; done = 1; end// LDREXD
      endcase
    end else if (enc[3:0] == 4'b1111) begin
      // LDRD literal
      t32_to_a32 = {enc[39:36],3'b000,1'b1,enc[7],1'b1,1'b0,1'b0,4'b1111,enc[35:32],enc[27:24],4'b1101,enc[23:20]};
      done = 1;
    end else begin
      // LDRD
      // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b1,w_a32,1'b0,enc[3:0],enc[35:32],enc[27:24],4'b1101,enc[23:20]};
      done = 1;
    end
  end
  // Special case 22 : STRD immediate vs Related Encodings (STREX - STREXB - STREXH - STREXD )
  else if ((enc[19] == 1'b0) && (enc[12:9] == 4'b0100) && (enc[6] == 1'b1) && (enc[4] == 1'b0)) begin
    if ((enc[8] == 1'b0) && (enc[5] == 1'b0)) begin
      // STREX - STREXB - STREXH - STREXD
      case ({enc[7],enc[27:24]})
        5'b00000 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b000,enc[3:0],enc[31:28],4'b1111,4'b1001,enc[35:32]}; done = 1; end // STREX
        5'b10100 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b100,enc[3:0],enc[23:20],4'b1111,4'b1001,enc[35:32]}; done = 1; end // STREXB
        5'b10101 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b110,enc[3:0],enc[23:20],4'b1111,4'b1001,enc[35:32]}; done = 1; end // STREXH
        5'b10111 : begin t32_to_a32 = {enc[39:36],5'b00011,3'b010,enc[3:0],enc[23:20],4'b1111,4'b1001,enc[35:32]}; done = 1; end // STREXD
      endcase
    end else begin
      // STRD
      // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b1,w_a32,1'b0,enc[3:0],enc[35:32],enc[27:24],4'b1111,enc[23:20]};
      done = 1;
    end
  end
  // Special case 23 : ORR immediate A32 only vs STRB A32 only
  else if ((enc[19] == 1'b1) && (enc[11] == 1'b0) && (enc[9] == 1'b0) && (enc[6] == 1'b1) &&
      (enc[12] == 1'b1) && (enc[8:7] == 2'b00) && (enc[5] == 1'b0) && (enc[35] == 1'b0)) begin
      // ORR immediate
    t32_to_a32 = {enc[39:36],7'b0011100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]};
    done = 1;
  end
  // Special case 24 : SSAT a32 only vs MSR
  else if ((enc[19] == 1'b1) && (enc[12] == 1'b1) && (enc[11:4] == 8'b00110010) &&
      (enc[35:32] == 4'b0000) && (enc[27:25] == 3'b000)) begin
    t32_to_a32 = {enc[39:36],7'b0110101,enc[24:20],enc[31:28],8'b00000101,enc[3:0]};
    done = 1;
  end
  // Special case 25 : NOP vs CPS
  else if ((enc[19] == 1'b0) && (enc[12:4] == 9'b100111010) && (enc[35:34] == 2'b10) && (enc[32] == 1'b0)) begin
    if (enc[30:28] == 3'b000) begin
      // DBG SEV WFI WFE YIELD NOP
      t32_to_a32 = {enc[39:36],20'b00110010000011110000,enc[27:20]};
    end else begin
      // CPS
      t32_to_a32 = {enc[39:36],8'b00010000,enc[30:28],1'b0,7'b0000000,enc[27:25],1'b0,enc[24:20]};
    end
    done = 1;
  end

  // Truly a32 only instruction (no T32 translation available)

  if (!done) begin
    casez ({enc[19],cond_code_nv,enc[11:0],enc[35:20]})
    30'b1_0_00101001????1111???????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 8: ADDS (immediate);
    30'b1_0_00001001????1111???????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 11: ADDS (register);
    30'b1_0_00100001????1111???????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 15: ANDS (immediate);
    30'b1_0_00000001????1111???????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 18: ANDS (register);
    30'b1_1_101????????????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 44: BLX (immediate);
    30'b1_0_00100011????1111???????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 65: EORS (immediate);
    30'b1_0_00000011????1111???????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 68: EORS (register);
    30'b0_0_110????1???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 83: LDC;
    30'b1_0_010??0?1???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 96: LDR (immediate-ARM);
    30'b1_0_011??0?1???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 98: LDR (register);
    30'b1_0_010??1?1???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 99: LDRB (immediate-ARM);
    30'b1_0_011??1?1???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 101: LDRB (register);
    30'b1_0_0100?111???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 102: LDRBT (A1);
    30'b1_0_0110?111???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 103: LDRBT (A2);
    30'b1_0_000??0?1????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 114: LDRH (register);
    30'b1_0_0000?111????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 115: LDRHT;
    30'b1_0_0000?011????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 116: LDRHT;
    30'b1_0_000??0?1????????????1101???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 119: LDRSB (register);
    30'b1_0_0000?111????????????1101???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 120: LDRSBT (A1);
    30'b1_0_0000?011????????????1101???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 121: LDRSBT (A2);
    30'b1_0_000??0?1????????????1111???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 124: LDRSH (register-ARM);
    30'b1_0_0000?111????????????1111???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 125: LDRSHT (A1);
    30'b1_0_0000?011????????????1111???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 126: LDRSHT (A2);
    30'b1_0_0100?011???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 127: LDRT;
    30'b1_0_0110?011???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 128: LDRT;
    30'b0_0_1110???0???????????????1???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 132: MCR;
    30'b0_0_1110???1???????????????1???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 140: MRC;
    30'b1_0_0011001010?????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 142: MSR (immediate);
    30'b1_0_00110010?1?????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 143: MSR (immediate);
    30'b1_0_00110010001????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 144: MSR (immediate);
    30'b1_0_001100100001???????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 145: MSR (immediate);
    30'b1_0_00110110???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 146: MSR (immediate);
    30'b1_1_0101??01???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 161: PLD (immediate-literal);
    30'b1_1_0111??01???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 162: PLD (register);
    30'b1_1_0100?101???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 163: PLI (immediate-literal);
    30'b1_1_0110?101???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 164: PLI (register);
    30'b1_1_100000?1???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 179: RFEDA;
    30'b1_1_100110?1???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 182: RFEIB;
    30'b1_1_100001?0???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 226: SRSDA;
    30'b1_1_100111?0???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 229: SRSIB;
    30'b0_0_110????0???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 236: STC;
    30'b1_0_010??0?0???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 252: STR (immediate-ARM);
    30'b1_0_011??0?0???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 253: STR (register);
    30'b1_0_010??1?0???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 254: STRB (immediate-ARM);
    30'b1_0_011??1?0???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 255: STRB (register);
    30'b1_0_0100?110???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 256: STRBT;
    30'b1_0_0110?110???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 257: STRBT;
    30'b1_0_000??1?0????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 266: STRH (immediate-ARM);
    30'b1_0_000??0?0????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 267: STRH (register);
    30'b1_0_0000?110????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 268: STRHT;
    30'b1_0_0000?010????????????1011???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 269: STRHT;
    30'b1_0_0100?010???????????????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 270: STRT;
    30'b1_0_0110?010???????????????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 271: STRT;
    30'b1_0_00100101????1111???????????? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 274: SUBS (immediate);
    30'b1_0_00000101????1111???????0???? :begin t32_to_a32 = {enc[39:36],enc[11:0],enc[35:20]}; done = 1; end // 277: SUBS (register);
  endcase

  // All the other  cases
  if (!done) begin
    casez ({enc[19],enc[12:0],enc[35:20]})
      30'b0_10?01010?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010101,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 3: ADC (immediate);
      30'b0_01011010?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000101,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 4: ADC (register);
      30'b1_01011010?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000101,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 5: ADC (register-shifted register);
      30'b0_10?01000?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 6: ADD (immediate);
      30'b0_10?010000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00101000,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 7: ADD (immediate);
      30'b0_01011000?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000100,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 9: ADD (register);
      30'b0_010110000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00001000,enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 10: ADD (register);
      30'b1_01011000?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000100,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 12: ADD (register-shifted register);
      30'b0_10?00000?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010000,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 13: AND (immediate);
      30'b0_10?000000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00100000,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 14: AND (immediate);
      30'b0_01010000?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 16: AND (register);
      30'b0_010100000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00000000,enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 17: AND (register);
      30'b1_01010000?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000000,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 19: AND (register-shifted register);
      30'b0_01010010?11110?????????10???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b100,enc[23:20]}; done = 1; end // 20: ASR (immediate);
      30'b0_11010010?????1111????0000???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[23:20],4'b0101,enc[3:0]}; done = 1; end // 21: ASR (register);
      30'b0_100??????????10111??????????? : begin t32_to_a32 = {enc[39:36],7'b1010000,enc[9:0],enc[30:20]}; done = 1; end // 22: B;
      30'b0_100??????????10110??????????? : begin t32_to_a32 = {enc[39:36],7'b1010001,enc[9:0],enc[30:20]}; done = 1; end // 23: B;
      30'b0_100??????????10011??????????? : begin t32_to_a32 = {enc[39:36],7'b1010010,enc[9:0],enc[30:20]}; done = 1; end // 24: B;
      30'b0_100??????????10010??????????? : begin t32_to_a32 = {enc[39:36],7'b1010011,enc[9:0],enc[30:20]}; done = 1; end // 25: B;
      30'b0_101??????????10010??????????? : begin t32_to_a32 = {enc[39:36],7'b1010100,enc[9:0],enc[30:20]}; done = 1; end // 26: B;
      30'b0_101??????????10011??????????? : begin t32_to_a32 = {enc[39:36],7'b1010101,enc[9:0],enc[30:20]}; done = 1; end // 27: B;
      30'b0_101??????????10110??????????? : begin t32_to_a32 = {enc[39:36],7'b1010110,enc[9:0],enc[30:20]}; done = 1; end // 28: B;
      30'b0_101??????????10111??????????? : begin t32_to_a32 = {enc[39:36],7'b1010111,enc[9:0],enc[30:20]}; done = 1; end // 29: B;
      30'b0_100110110????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0111110,enc[24:20],enc[31:28],enc[34:32],enc[27:26],3'b001,enc[3:0]}; done = 1; end // 30: BFC;
      30'b0_100110110????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0111110,enc[24:20],enc[31:28],enc[34:32],enc[27:26],3'b001,enc[3:0]}; done = 1; end // 31: BFI;
      30'b0_10?00001?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0011110,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 32: BIC (immediate);
      30'b0_01010001?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0001110,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 33: BIC (register);
      30'b1_01010001?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0001110,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 34: BIC (register-shifted register);
      30'b0_00000????????10111110???????? : begin t32_to_a32 = {enc[39:36],8'b00010010,enc[7:0],enc[27:24],4'b0111,enc[23:20]}; done = 1; end // 35: BKPT;
      30'b0_100??????????11111??????????? : begin t32_to_a32 = {enc[39:36],7'b1011000,enc[9:0],enc[30:20]}; done = 1; end // 36: BL;
      30'b0_100??????????11110??????????? : begin t32_to_a32 = {enc[39:36],7'b1011001,enc[9:0],enc[30:20]}; done = 1; end // 37: BL;
      30'b0_100??????????11011??????????? : begin t32_to_a32 = {enc[39:36],7'b1011010,enc[9:0],enc[30:20]}; done = 1; end // 38: BL;
      30'b0_100??????????11010??????????? : begin t32_to_a32 = {enc[39:36],7'b1011011,enc[9:0],enc[30:20]}; done = 1; end // 39: BL;
      30'b0_101??????????11010??????????? : begin t32_to_a32 = {enc[39:36],7'b1011100,enc[9:0],enc[30:20]}; done = 1; end // 40: BL;
      30'b0_101??????????11011??????????? : begin t32_to_a32 = {enc[39:36],7'b1011101,enc[9:0],enc[30:20]}; done = 1; end // 41: BL;
      30'b0_101??????????11110??????????? : begin t32_to_a32 = {enc[39:36],7'b1011110,enc[9:0],enc[30:20]}; done = 1; end // 42: BL;
      30'b0_101??????????11111??????????? : begin t32_to_a32 = {enc[39:36],7'b1011111,enc[9:0],enc[30:20]}; done = 1; end // 43: BL;
      30'b0_101111000????1000111100000010 : begin t32_to_a32 = {enc[39:36],24'b000100101111111111110011,enc[3:0]}; done = 1; end // 45: BLX (register);
      30'b0_101111000????1000111100000000 : begin t32_to_a32 = {enc[39:36],24'b000100101111111111110001,enc[3:0]}; done = 1; end // 46: BX;
      30'b0_100111100????1000111100000000 : begin t32_to_a32 = {enc[39:36],24'b000100101111111111110010,enc[3:0]}; done = 1; end // 47: BXJ;
      30'b0_01110???????????????????0???? : begin t32_to_a32 = {enc[39:36],4'b1110,enc[7:4],enc[3:0],enc[35:32],enc[31:28],enc[27:25],1'b0,enc[23:20]}; done = 1; end // 48: CDP;
      30'b0_11110???????????????????0???? : begin t32_to_a32 = {enc[39:36],4'b1110,enc[7:4],enc[3:0],enc[35:32],enc[31:28],enc[27:25],1'b0,enc[23:20]}; done = 1; end // 49: CDP2;
      30'b0_10011101111111000111100101111 : begin t32_to_a32 = {enc[39:36],28'b0101011111111111000000011111}; done = 1; end // 50: CLREX;
      30'b0_110101011????1111????1000???? : begin t32_to_a32 = {enc[39:36],12'b000101101111,enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 51: CLZ;
      30'b0_10?010001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00110111,enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]}; done = 1; end // 52: CMN (immediate);
      30'b0_010110001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00010111,enc[3:0],4'b0000,enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 53: CMN (register);
      30'b1_010110001????????111100?????? : begin t32_to_a32 = {enc[39:36],8'b00010111,enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 54: CMN (register-shifted register);
      30'b0_10?011011????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00110101,enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]}; done = 1; end // 55: CMP (immediate);
      30'b0_010111011????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00010101,enc[3:0],4'b0000,enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 56: CMP (register);
      30'b1_010111011????????111100?????? : begin t32_to_a32 = {enc[39:36],8'b00010101,enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 57: CMP (register-shifted register);
      30'b0_100111010111110000??????????? : begin t32_to_a32 = {enc[39:36],8'b00010000,enc[30:29],enc[28],8'b00000000,enc[27],enc[26],enc[25],1'b0,enc[24:20]}; done = 1; end // 58: CPS;
      30'b0_110101100????1111????10?????? : begin t32_to_a32 = {enc[39:36],5'b00010,enc[25:24],1'b0,enc[3:0],enc[31:28],8'b00000100,enc[23:20]}; done = 1; end // 59: CRC32;
      30'b0_110101101????1111????10?????? : begin t32_to_a32 = {enc[39:36],5'b00010,enc[25:24],1'b0,enc[3:0],enc[31:28],8'b00100100,enc[23:20]}; done = 1; end // 60: CRC32C;
      30'b0_1001110111111100011110101???? : begin t32_to_a32 = {enc[39:36],24'b010101111111111100000101,enc[23:20]}; done = 1; end // 61: DMB;
      30'b0_1001110111111100011110100???? : begin t32_to_a32 = {enc[39:36],24'b010101111111111100000100,enc[23:20]}; done = 1; end // 62: DSB;
      30'b0_10?00100?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010001,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 63: EOR (immediate);
      30'b0_10?001000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00100010,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 64: EOR (immediate);
      30'b0_01010100?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 66: EOR (register);
      30'b0_010101000????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00000010,enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 67: EOR (register);
      30'b1_01010100?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000001,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 69: EOR (register-shifted register);
      30'b0_10011110111101000111100000000 : begin t32_to_a32 = {enc[39:36],28'b0001011000000000000001101110}; done = 1; end // 70: ERET;
      30'b0_110010011????1111000000000000 : begin t32_to_a32 = {enc[39:36],8'b01000001,enc[3:0],16'b0000000000000000}; done = 1; end // 71: HINT;
      30'b0_110011011????1111000000000000 : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],16'b0000000000000000}; done = 1; end // 72: HINT;
      30'b0_000??????????1011101010?????? : begin t32_to_a32 = {enc[39:36],8'b00010000,enc[9:0],enc[25:24],4'b0111,enc[23:20]}; done = 1; end // 73: HLT;
      30'b0_101111110????1000???????????? : begin t32_to_a32 = {enc[39:36],8'b00010100,enc[3:0],enc[31:24],4'b0111,enc[23:20]}; done = 1; end // 74: HVC;
      30'b0_1001110111111100011110110???? : begin t32_to_a32 = {enc[39:36],24'b010101111111111100000110,enc[23:20]}; done = 1; end // 75: ISB;
      30'b0_010001101????????111110101111 : begin t32_to_a32 = {enc[39:36],8'b00011001,enc[3:0],enc[35:32],12'b110010011111}; done = 1; end // 76: LDA;
      30'b0_010001101????????111110001111 : begin t32_to_a32 = {enc[39:36],8'b00011101,enc[3:0],enc[35:32],12'b110010011111}; done = 1; end // 77: LDAB;
      30'b0_010001101????????111110011111 : begin t32_to_a32 = {enc[39:36],8'b00011111,enc[3:0],enc[35:32],12'b110010011111}; done = 1; end // 78: LDAH;
      30'b0_010001101????????111111101111 : begin t32_to_a32 = {enc[39:36],8'b00011001,enc[3:0],enc[35:32],12'b111010011111}; done = 1; end // 79: LDAEX;
      30'b0_010001101????????111111001111 : begin t32_to_a32 = {enc[39:36],8'b00011101,enc[3:0],enc[35:32],12'b111010011111}; done = 1; end // 80: LDAEXB;
      30'b0_010001101????????????11111111 : begin t32_to_a32 = {enc[39:36],8'b00011011,enc[3:0],enc[35:33],13'b0111010011111}; done = 1; end // 81: LDAEXD;
      30'b0_010001101????????111111011111 : begin t32_to_a32 = {enc[39:36],8'b00011111,enc[3:0],enc[35:32],12'b111010011111}; done = 1; end // 82: LDAEXH;
      30'b0_0100010?1???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100010,enc[5],1'b1,enc[3:0],enc[35:20]}; done = 1; end // 84: LDMIA;
      30'b1_0100000?1???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100000,enc[5],1'b1,enc[3:0],enc[35:20]}; done = 1; end // 85: LDMDA;
      30'b0_0100100?1???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100100,enc[5],1'b1,enc[3:0],enc[35:20]}; done = 1; end // 86: LDMDB;
      30'b1_0100110?1???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100110,enc[5],1'b1,enc[3:0],enc[35:20]}; done = 1; end // 87: LDMIB;
      30'b1_010001101????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b10001101,enc[3:0],1'b0,enc[34:20]}; done = 1; end // 88: LDMIA (user-registers);
      30'b1_010000101????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b10000101,enc[3:0],1'b0,enc[34:20]}; done = 1; end // 89: LDMDA (user-registers);
      30'b1_010010101????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b10010101,enc[3:0],1'b0,enc[34:20]}; done = 1; end // 90: LDMDB (user-registers);
      30'b1_010011101????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b10011101,enc[3:0],1'b0,enc[34:20]}; done = 1; end // 91: LDMIB (user-registers);
      30'b1_0100011?1????1??????????????? : begin t32_to_a32 = {enc[39:36],6'b100011,enc[5],1'b1,enc[3:0],1'b1,enc[34:20]}; done = 1; end // 92: LDMIA (exception-return);
      30'b1_0100001?1????1??????????????? : begin t32_to_a32 = {enc[39:36],6'b100001,enc[5],1'b1,enc[3:0],1'b1,enc[34:20]}; done = 1; end // 93: LDMDA (exception-return);
      30'b1_0100101?1????1??????????????? : begin t32_to_a32 = {enc[39:36],6'b100101,enc[5],1'b1,enc[3:0],1'b1,enc[34:20]}; done = 1; end // 94: LDMDB (exception-return);
      30'b1_0100111?1????1??????????????? : begin t32_to_a32 = {enc[39:36],6'b100111,enc[5],1'b1,enc[3:0],1'b1,enc[34:20]}; done = 1; end // 95: LDMIB (exception-return);
      30'b0_11000?101???????????????????? : begin t32_to_a32 = {enc[39:36],4'b0101,enc[7],3'b001,enc[3:0],enc[35:32],enc[31:20]}; done = 1; end // 97: LDR (literal);
      30'b0_11000?001???????????????????? : begin t32_to_a32 = {enc[39:36],4'b0101,enc[7],3'b101,enc[3:0],enc[35:32],enc[31:20]}; done = 1; end // 100: LDRB (literal);
      30'b0_0100??1?1???????????????????? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b1,w_a32,1'b0,enc[3:0],enc[35:33],1'b0,enc[27:24],4'b1101,enc[23:20]}; // 104: LDRD (immediate)
    end
      30'b0_01001?101???????????????????? : begin t32_to_a32 = {enc[39:36],4'b0001,enc[7],3'b100,enc[3:0],enc[35:33],1'b0,enc[27:24],4'b1101,enc[23:20]}; done = 1; end // 105: LDRD (literal);
      30'b1_0000??0?0????????????1101???? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b0,w_a32,1'b0,enc[3:0],enc[35:33],9'b000001101,enc[23:20]}; // 106: LDRD (register-ARM)
    end
      30'b1_0000??0?0????????????1101???? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b0,w_a32,1'b0,enc[3:0],enc[35:33],9'b000001101,enc[23:20]}; // 107: LDRD (register-ARM-PC)
    end
      30'b0_010000101????????111100000000 : begin t32_to_a32 = {enc[39:36],8'b00011001,enc[3:0],enc[35:32],12'b111110011111}; done = 1; end // 108: LDREX;
      30'b0_010001101????????111101001111 : begin t32_to_a32 = {enc[39:36],8'b00011101,enc[3:0],enc[35:32],12'b111110011111}; done = 1; end // 109: LDREXB;
      30'b0_010001101????????????01111111 : begin t32_to_a32 = {enc[39:36],8'b00011011,enc[3:0],enc[35:33],13'b0111110011111}; done = 1; end // 110: LDREXD;
      30'b0_010001101????????111101011111 : begin t32_to_a32 = {enc[39:36],8'b00011111,enc[3:0],enc[35:32],12'b111110011111}; done = 1; end // 111: LDREXH;
      30'b0_110000011????????1??????????? : begin // special case where we need to decode the PW bits
      case ({enc[30],enc[28]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[29],1'b1,w_a32,1'b1,enc[3:0],enc[35:32],enc[27:24],4'b1011,enc[23:20]}; // 112: LDRH (immediate)
    end
      30'b0_11000?011????????0000???????? : begin t32_to_a32 = {enc[39:36],4'b0001,enc[7],3'b101,enc[3:0],enc[35:32],enc[27:24],4'b1011,enc[23:20]}; done = 1; end // 113: LDRH (literal);
      30'b0_110010001????????1??????????? : begin // special case where we need to decode the PW bits
      case ({enc[30],enc[28]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[29],1'b1,w_a32,1'b1,enc[3:0],enc[35:32],enc[27:24],4'b1101,enc[23:20]}; // 117: LDRSB (immediate)
    end
      30'b0_11001?001????????0000???????? : begin t32_to_a32 = {enc[39:36],4'b0001,enc[7],3'b101,enc[3:0],enc[35:32],enc[27:24],4'b1101,enc[23:20]}; done = 1; end // 118: LDRSB (literal);
      30'b0_110010011????????1??????????? : begin // special case where we need to decode the PW bits
      case ({enc[30],enc[28]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[29],1'b1,w_a32,1'b1,enc[3:0],enc[35:32],enc[27:24],4'b1111,enc[23:20]}; // 122: LDRSH (immediate)
    end
      30'b0_11001?011????????0000???????? : begin t32_to_a32 = {enc[39:36],4'b0001,enc[7],3'b101,enc[3:0],enc[35:32],enc[27:24],4'b1111,enc[23:20]}; done = 1; end // 123: LDRSH (literal);
      30'b0_11010000?????1111????0000???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[23:20],4'b0001,enc[3:0]}; done = 1; end // 129: LSL (register);
      30'b0_01010010?11110?????????01???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b010,enc[23:20]}; done = 1; end // 130: LSR (immediate);
      30'b0_11010001?????1111????0000???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[23:20],4'b0011,enc[3:0]}; done = 1; end // 131: LSR (register);
      30'b0_110110000????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00000010,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 133: MLA;
      30'b1_110110001????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00000011,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 134: MLA;
      30'b0_110110000????????????0001???? : begin t32_to_a32 = {enc[39:36],8'b00000110,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 135: MLS;
      30'b0_10?00010?11110??????????????? : begin t32_to_a32 = {enc[39:36],7'b0011101,enc[4],4'b0000,enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 136: MOV (immediate);
      30'b0_10?100100????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00110000,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 137: MOVW (immediate);
      30'b0_01010010?11110?????????00???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b000,enc[23:20]}; done = 1; end // 138: MOV (register);
      30'b0_10?101100????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00110100,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 139: MOVT;
      30'b0_10011111?????1000????00??0000 : begin t32_to_a32 = {enc[39:36],5'b00010,enc[4],2'b00,enc[3:0],enc[31:28],2'b00,enc[25:24],8'b00000000}; done = 1; end // 141: MRS;
      30'b0_10011100?????1000????00??0000 : begin t32_to_a32 = {enc[39:36],5'b00010,enc[4],2'b10,enc[31:28],6'b111100,enc[25:24],4'b0000,enc[3:0]}; done = 1; end // 147: MSR (register);
      30'b0_110110000????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b00000000,enc[31:28],4'b0000,enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 148: MUL;
      30'b1_110110001????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b00000001,enc[31:28],4'b0000,enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 149: MUL;
      30'b0_10?00011?11110??????????????? : begin t32_to_a32 = {enc[39:36],7'b0011111,enc[4],4'b0000,enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 150: MVN (immediate);
      30'b0_01010011?11110??????????????? : begin t32_to_a32 = {enc[39:36],7'b0001111,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 151: MVN (register);
      30'b1_01010011?1111????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0001111,enc[4],4'b0000,enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 152: MVN (register-shifted register);
      30'b0_100111010111110000000???????? : begin t32_to_a32 = {enc[39:36],20'b00110010000011110000,enc[27:20]}; done = 1; end // 153: NOP;
      30'b0_10?00010?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0011100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 154: ORR (immediate);
      30'b0_10?00111?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0011100,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 155: ORR (immediate1);
      30'b0_01010010?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0001100,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 156: ORR (register);
      30'b0_01010111?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0001100,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 157: ORR (register);
      30'b1_01010010?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0001100,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 158: ORR (register-shifted register);
      30'b0_010101100????0?????????10???? : begin t32_to_a32 = {enc[39:36],8'b01101000,enc[3:0],enc[31:28],enc[34:32],enc[27:26],3'b101,enc[23:20]}; done = 1; end // 159: PKHTB;
      30'b0_010101100????0?????????00???? : begin t32_to_a32 = {enc[39:36],8'b01101000,enc[3:0],enc[31:28],enc[34:32],enc[27:26],3'b001,enc[23:20]}; done = 1; end // 160: PKHBT;
      30'b0_110101000????1111????1000???? : begin t32_to_a32 = {enc[39:36],8'b00010000,enc[3:0],enc[31:28],8'b00000101,enc[23:20]}; done = 1; end // 165: QADD;
      30'b0_110101001????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 166: QADD16;
      30'b0_110101000????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 167: QADD8;
      30'b0_110101010????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 168: QASX;
      30'b0_110101000????1111????1001???? : begin t32_to_a32 = {enc[39:36],8'b00010100,enc[3:0],enc[31:28],8'b00000101,enc[23:20]}; done = 1; end // 169: QDADD;
      30'b0_110101000????1111????1011???? : begin t32_to_a32 = {enc[39:36],8'b00010110,enc[3:0],enc[31:28],8'b00000101,enc[23:20]}; done = 1; end // 170: QDSUB;
      30'b0_110101110????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 171: QSAX;
      30'b0_110101000????1111????1010???? : begin t32_to_a32 = {enc[39:36],8'b00010010,enc[3:0],enc[31:28],8'b00000101,enc[23:20]}; done = 1; end // 172: QSUB;
      30'b0_110101101????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 173: QSUB16;
      30'b0_110101100????1111????0001???? : begin t32_to_a32 = {enc[39:36],8'b01100010,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 174: QSUB8;
      30'b0_110101001????1111????1010???? : begin t32_to_a32 = {enc[39:36],12'b011011111111,enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 175: RBIT;
      30'b0_110101001????1111????1000???? : begin t32_to_a32 = {enc[39:36],12'b011010111111,enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 176: REV;
      30'b0_110101001????1111????1001???? : begin t32_to_a32 = {enc[39:36],12'b011010111111,enc[31:28],8'b11111011,enc[23:20]}; done = 1; end // 177: REV16;
      30'b0_110101001????1111????1011???? : begin t32_to_a32 = {enc[39:36],12'b011011111111,enc[31:28],8'b11111011,enc[23:20]}; done = 1; end // 178: REVSH;
      30'b0_0100000?1????1100000000000000 : begin t32_to_a32 = {enc[39:36],6'b100100,enc[5],1'b1,enc[3:0],16'b0000101000000000}; done = 1; end // 180: RFEDB;
      30'b0_0100110?1????1100000000000000 : begin t32_to_a32 = {enc[39:36],6'b100010,enc[5],1'b1,enc[3:0],16'b0000101000000000}; done = 1; end // 181: RFEIA;
      30'b0_01010010?11110?????????11???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[34:32],enc[27:26],3'b110,enc[23:20]}; done = 1; end // 183: ROR (immediate);
      30'b0_11010011?????1111????0000???? : begin t32_to_a32 = {enc[39:36],7'b0001101,enc[4],4'b0000,enc[31:28],enc[23:20],4'b0111,enc[3:0]}; done = 1; end // 184: ROR (register);
      30'b0_10?01110?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010011,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 185: RSB (immediate);
      30'b0_01011110?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000011,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 186: RSB (register);
      30'b1_01011110?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000011,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 187: RSB (register-shifted register);
      30'b0_10?01111?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010111,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 188: RSC (immediate);
      30'b0_01011111?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000111,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 189: RSC (register);
      30'b1_01011111?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000111,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 190: RSC (register-shifted register);
      30'b0_110101001????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 191: SADD16;
      30'b0_110101000????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 192: SADD8;
      30'b0_110101010????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 193: SASX;
      30'b0_10?01011?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010110,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 194: SBC (immediate);
      30'b0_01011011?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000110,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 195: SBC (register);
      30'b1_01011011?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000110,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 196: SBC (register-shifted register);
      30'b0_100110100????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0111101,enc[24:20],enc[31:28],enc[34:32],enc[27:26],3'b101,enc[3:0]}; done = 1; end // 197: SBFX;
      30'b0_110101010????1111????1000???? : begin t32_to_a32 = {enc[39:36],8'b01101000,enc[3:0],enc[31:28],8'b11111011,enc[23:20]}; done = 1; end // 198: SEL;
      30'b0_110111001????1111????1111???? : begin t32_to_a32 = {enc[39:36],8'b01110001,enc[31:28],4'b1111,enc[23:20],4'b0001,enc[3:0]}; done = 1; end // 199: SDIV;
      30'b0_0000000000000101101100101?000 : begin t32_to_a32 = {enc[39:36],18'b000100000001000000,enc[23],9'b000000000}; done = 1; end // 200: SETEND;
      30'b0_110101001????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 201: SHADD16;
      30'b0_110101000????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 202: SHADD8;
      30'b0_110101010????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 203: SHASX;
      30'b0_110101110????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 204: SHSAX;
      30'b0_110101101????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 205: SHSUB16;
      30'b0_110101100????1111????0010???? : begin t32_to_a32 = {enc[39:36],8'b01100011,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 206: SHSUB8;
      30'b0_101111111????1000000000000000 : begin t32_to_a32 = {enc[39:36],24'b000101100000000000000111,enc[3:0]}; done = 1; end // 207: SMC;
      30'b0_110110001????????????00?????? : begin t32_to_a32 = {enc[39:36],8'b00010000,enc[31:28],enc[35:32],enc[23:20],1'b1,enc[24],enc[25],1'b0,enc[3:0]}; done = 1; end // 208: SMLA_X_Y;
      30'b0_110110010????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110000,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]}; done = 1; end // 209: SMLAD;
      30'b0_110111100????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001110,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 210: SMLAL;
      30'b1_110111101????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001111,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 211: SMLAL;
      30'b0_110111100????????????10?????? : begin t32_to_a32 = {enc[39:36],8'b00010100,enc[31:28],enc[35:32],enc[23:20],1'b1,enc[24],enc[25],1'b0,enc[3:0]}; done = 1; end // 212: SMLAL_X_Y;
      30'b0_110111100????????????110????? : begin t32_to_a32 = {enc[39:36],8'b01110100,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]}; done = 1; end // 213: SMLALD;
      30'b0_110110011????????????000????? : begin t32_to_a32 = {enc[39:36],8'b00010010,enc[31:28],enc[35:32],enc[23:20],1'b1,enc[24],2'b00,enc[3:0]}; done = 1; end // 214: SMLAW;
      30'b0_110110100????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110000,enc[31:28],enc[35:32],enc[23:20],2'b01,enc[24],1'b1,enc[3:0]}; done = 1; end // 215: SMLSD;
      30'b0_110111101????????????110????? : begin t32_to_a32 = {enc[39:36],8'b01110100,enc[31:28],enc[35:32],enc[23:20],2'b01,enc[24],1'b1,enc[3:0]}; done = 1; end // 216: SMLSLD;
      30'b0_110110101????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110101,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]}; done = 1; end // 217: SMMLA;
      30'b0_110110110????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110101,enc[31:28],enc[35:32],enc[23:20],2'b11,enc[24],1'b1,enc[3:0]}; done = 1; end // 218: SMMLS;
      30'b0_110110101????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110101,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]}; done = 1; end // 219: SMMUL;
      30'b0_110110010????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110000,enc[31:28],enc[35:32],enc[23:20],2'b00,enc[24],1'b1,enc[3:0]}; done = 1; end // 220: SMUAD;
      30'b0_110110001????1111????00?????? : begin t32_to_a32 = {enc[39:36],8'b00010110,enc[31:28],4'b0000,enc[23:20],1'b1,enc[24],enc[25],1'b0,enc[3:0]}; done = 1; end // 221: SMUL_X_Y;
      30'b0_110111000????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001100,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 222: SMULL;
      30'b1_110111001????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001101,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 223: SMULL;
      30'b0_110110011????1111????000????? : begin t32_to_a32 = {enc[39:36],8'b00010010,enc[31:28],4'b0000,enc[23:20],1'b1,enc[24],2'b10,enc[3:0]}; done = 1; end // 224: SMULW;
      30'b0_110110100????????????000????? : begin t32_to_a32 = {enc[39:36],8'b01110000,enc[31:28],enc[35:32],enc[23:20],2'b01,enc[24],1'b1,enc[3:0]}; done = 1; end // 225: SMUSD;
      30'b0_0100000?0110111000000000????? : begin t32_to_a32 = {enc[39:36],6'b100101,enc[5],16'b0110100000101000,enc[24:20]}; done = 1; end // 227: SRSDB;
      30'b0_0100110?0110111000000000????? : begin t32_to_a32 = {enc[39:36],6'b100011,enc[5],16'b0110100000101000,enc[24:20]}; done = 1; end // 228: SRSIA;
      30'b1_100110010????0000????000????? : begin t32_to_a32 = {enc[39:36],7'b0110101,enc[24:20],enc[31:28],8'b00000101,enc[3:0]}; done = 1; end // 230: SSAT;
      30'b0_1001100?0????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0110101,enc[24:20],enc[31:28],enc[34:32],enc[27:26],enc[5],2'b01,enc[3:0]}; done = 1; end // 231: SSAT;
      30'b0_100110010????0000????0000???? : begin t32_to_a32 = {enc[39:36],8'b01101010,enc[23:20],enc[31:28],8'b11110011,enc[3:0]}; done = 1; end // 232: SSAT16;
      30'b0_110101110????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 233: SSAX;
      30'b0_110101101????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 234: SSUB16;
      30'b0_110101100????1111????0000???? : begin t32_to_a32 = {enc[39:36],8'b01100001,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 235: SSUB8;
      30'b0_010001100????????111110101111 : begin t32_to_a32 = {enc[39:36],8'b00011000,enc[3:0],12'b111111001001,enc[35:32]}; done = 1; end // 237: STL;
      30'b0_010001100????????111110001111 : begin t32_to_a32 = {enc[39:36],8'b00011100,enc[3:0],12'b111111001001,enc[35:32]}; done = 1; end // 238: STLB;
      30'b0_010001100????????111110011111 : begin t32_to_a32 = {enc[39:36],8'b00011110,enc[3:0],12'b111111001001,enc[35:32]}; done = 1; end // 239: STLH;
      30'b0_010001100????????11111110???? : begin t32_to_a32 = {enc[39:36],8'b00011000,enc[3:0],enc[23:20],8'b11101001,enc[35:32]}; done = 1; end // 240: STLEX;
      30'b0_010001100????????11111100???? : begin t32_to_a32 = {enc[39:36],8'b00011100,enc[3:0],enc[23:20],8'b11101001,enc[35:32]}; done = 1; end // 241: STLEXB;
      30'b0_010001100????????????1111???? : begin t32_to_a32 = {enc[39:36],8'b00011010,enc[3:0],enc[23:20],8'b11101001,enc[35:33],1'b0}; done = 1; end // 242: STLEXD;
      30'b0_010001100????????11111101???? : begin t32_to_a32 = {enc[39:36],8'b00011110,enc[3:0],enc[23:20],8'b11101001,enc[35:32]}; done = 1; end // 243: STLEXH;
      30'b0_0100010?0???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100010,enc[5],1'b0,enc[3:0],enc[35:20]}; done = 1; end // 244: STMIA;
      30'b1_0100000?0???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100000,enc[5],1'b0,enc[3:0],enc[35:20]}; done = 1; end // 245: STMDA;
      30'b0_0100100?0???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100100,enc[5],1'b0,enc[3:0],enc[35:20]}; done = 1; end // 246: STMDB;
      30'b1_0100110?0???????????????????? : begin t32_to_a32 = {enc[39:36],6'b100110,enc[5],1'b0,enc[3:0],enc[35:20]}; done = 1; end // 247: STMIB;
      30'b1_010001100???????????????????? : begin t32_to_a32 = {enc[39:36],8'b10001100,enc[3:0],enc[35:20]}; done = 1; end // 248: STMIA (user-registers);
      30'b1_010000100???????????????????? : begin t32_to_a32 = {enc[39:36],8'b10000100,enc[3:0],enc[35:20]}; done = 1; end // 249: STMDA (user-registers);
      30'b1_010010100???????????????????? : begin t32_to_a32 = {enc[39:36],8'b10010100,enc[3:0],enc[35:20]}; done = 1; end // 250: STMDB (user-registers);
      30'b1_010011100???????????????????? : begin t32_to_a32 = {enc[39:36],8'b10011100,enc[3:0],enc[35:20]}; done = 1; end // 251: STMIB (user-registers);
      30'b0_0100??1?0???????????????????? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b1,w_a32,1'b0,enc[3:0],enc[35:33],1'b0,enc[27:24],4'b1111,enc[23:20]}; // 258: STRD (immediate)
    end
      30'b0_01001?100???????????????????? : begin t32_to_a32 = {enc[39:36],4'b0001,enc[7],3'b100,enc[3:0],enc[35:33],1'b0,enc[27:24],4'b1111,enc[23:20]}; done = 1; end // 259: STRD (immediate);
      30'b1_0000??0?0????????????1111???? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b0,w_a32,1'b0,enc[3:0],enc[35:33],9'b000001111,enc[23:20]}; // 260: STRD (register-ARM)
    end
      30'b1_0000??0?0????????????1111???? : begin // special case where we need to decode the PW bits
      case ({enc[8],enc[5]})
        2'b00 : begin p_a32 = 1'b0; w_a32 = 1'b1; end
        2'b01 : begin p_a32 = 1'b0; w_a32 = 1'b0; end
        2'b10 : begin p_a32 = 1'b1; w_a32 = 1'b0; end
        2'b11 : begin p_a32 = 1'b1; w_a32 = 1'b1; end
      endcase
      t32_to_a32 = {enc[39:36],3'b000,p_a32,enc[7],1'b0,w_a32,1'b0,enc[3:0],enc[35:33],9'b000001111,enc[23:20]}; // 261: STRD (register-ARM-PC)
    end
      30'b0_010000100????????????00000000 : begin t32_to_a32 = {enc[39:36],8'b00011000,enc[3:0],enc[31:28],8'b11111001,enc[35:32]}; done = 1; end // 262: STREX;
      30'b0_010001100????????11110100???? : begin t32_to_a32 = {enc[39:36],8'b00011100,enc[3:0],enc[23:20],8'b11111001,enc[35:32]}; done = 1; end // 263: STREXB;
      30'b0_010001100????????????0111???? : begin t32_to_a32 = {enc[39:36],8'b00011010,enc[3:0],enc[23:20],8'b11111001,enc[35:33],1'b0}; done = 1; end // 264: STREXD;
      30'b0_010001100????????11110101???? : begin t32_to_a32 = {enc[39:36],8'b00011110,enc[3:0],enc[23:20],8'b11111001,enc[35:32]}; done = 1; end // 265: STREXH;
      30'b0_10?01101?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0010010,enc[4],enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 272: SUB (immediate);
      30'b0_10?011010????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00100100,enc[3:0],enc[31:28],enc[10],enc[34:32],enc[27:20]}; done = 1; end // 273: SUB (immediate);
      30'b0_01011101?????0??????????????? : begin t32_to_a32 = {enc[39:36],7'b0000010,enc[4],enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 275: SUB (register);
      30'b0_010111010????0??????????????? : begin t32_to_a32 = {enc[39:36],8'b00000100,enc[3:0],enc[31:28],enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 276: SUB (register);
      30'b1_01011101?????????????00?????? : begin t32_to_a32 = {enc[39:36],7'b0000010,enc[4],enc[3:0],enc[31:28],enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 278: SUB (register-shifted register);
      30'b0_00000????????11011111???????? : begin t32_to_a32 = {enc[39:36],12'b111100000000,enc[7:0],enc[27:20]}; done = 1; end // 279: SVC;
      30'b0_110100100????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101010,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 280: SXTAB;
      30'b0_110100010????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101000,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 281: SXTAB16;
      30'b0_110100000????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101011,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 282: SXTAH;
      30'b0_110100100????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101010,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 283: SXTB;
      30'b0_110100010????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101000,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 284: SXTB16;
      30'b0_110100000????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101011,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 285: SXTH;
      30'b0_10?001001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00110011,enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]}; done = 1; end // 286: TEQ (immediate);
      30'b0_010101001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00010011,enc[3:0],4'b0000,enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 287: TEQ (register);
      30'b1_010101001????????111100?????? : begin t32_to_a32 = {enc[39:36],8'b00010011,enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 288: TEQ (register-shifted register);
      30'b0_10?000001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00110001,enc[3:0],4'b0000,enc[10],enc[34:32],enc[27:20]}; done = 1; end // 289: TST (immediate);
      30'b0_010100001????0???1111???????? : begin t32_to_a32 = {enc[39:36],8'b00010001,enc[3:0],4'b0000,enc[34:32],enc[27:26],enc[25:24],1'b0,enc[23:20]}; done = 1; end // 290: TST (register);
      30'b1_010100001????????111100?????? : begin t32_to_a32 = {enc[39:36],8'b00010001,enc[3:0],4'b0000,enc[35:32],1'b0,enc[25:24],1'b1,enc[23:20]}; done = 1; end // 291: TST (register-shifted register);
      30'b0_110101001????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 292: UADD16;
      30'b0_110101000????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 293: UADD8;
      30'b0_110101010????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 294: UASX;
      30'b0_100111100????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0111111,enc[24:20],enc[31:28],enc[34:32],enc[27:26],3'b101,enc[3:0]}; done = 1; end // 295: UBFX;
      30'b0_110111011????1111????1111???? : begin t32_to_a32 = {enc[39:36],8'b01110011,enc[31:28],4'b1111,enc[23:20],4'b0001,enc[3:0]}; done = 1; end // 296: UDIV;
      30'b0_110101001????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 297: UHADD16;
      30'b0_110101000????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 298: UHADD8;
      30'b0_110101010????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 299: UHASX;
      30'b0_110101110????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 300: UHSAX;
      30'b0_110101101????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 301: UHSUB16;
      30'b0_110101100????1111????0110???? : begin t32_to_a32 = {enc[39:36],8'b01100111,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 302: UHSUB8;
      30'b0_110111110????????????0110???? : begin t32_to_a32 = {enc[39:36],8'b00000100,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 303: UMAAL;
      30'b0_110111110????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001010,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 304: UMLAL;
      30'b1_110111111????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001011,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 305: UMLAL;
      30'b0_110111010????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001000,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 306: UMULL;
      30'b1_110111011????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b00001001,enc[31:28],enc[35:32],enc[23:20],4'b1001,enc[3:0]}; done = 1; end // 307: UMULL;
      30'b0_110101001????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11110001,enc[23:20]}; done = 1; end // 308: UQADD16;
      30'b0_110101000????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11111001,enc[23:20]}; done = 1; end // 309: UQADD8;
      30'b0_110101010????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11110011,enc[23:20]}; done = 1; end // 310: UQASX;
      30'b0_110101110????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 311: UQSAX;
      30'b0_110101101????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 312: UQSUB16;
      30'b0_110101100????1111????0101???? : begin t32_to_a32 = {enc[39:36],8'b01100110,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 313: UQSUB8;
      30'b0_110110111????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b01111000,enc[31:28],enc[35:32],enc[23:20],4'b0001,enc[3:0]}; done = 1; end // 314: USAD8;
      30'b0_110110111????????????0000???? : begin t32_to_a32 = {enc[39:36],8'b01111000,enc[31:28],enc[35:32],enc[23:20],4'b0001,enc[3:0]}; done = 1; end // 315: USADA8;
      30'b1_100111010????0000????000????? : begin t32_to_a32 = {enc[39:36],7'b0110111,enc[24:20],enc[31:28],8'b00000101,enc[3:0]}; done = 1; end // 316: USAT;
      30'b0_1001110?0????0?????????0????? : begin t32_to_a32 = {enc[39:36],7'b0110111,enc[24:20],enc[31:28],enc[34:32],enc[27:26],enc[5],2'b01,enc[3:0]}; done = 1; end // 317: USAT;
      30'b0_100111010????0000????0000???? : begin t32_to_a32 = {enc[39:36],8'b01101110,enc[23:20],enc[31:28],8'b11110011,enc[3:0]}; done = 1; end // 318: USAT16;
      30'b0_110101110????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11110101,enc[23:20]}; done = 1; end // 319: USAX;
      30'b0_110101101????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11110111,enc[23:20]}; done = 1; end // 320: USUB16;
      30'b0_110101100????1111????0100???? : begin t32_to_a32 = {enc[39:36],8'b01100101,enc[3:0],enc[31:28],8'b11111111,enc[23:20]}; done = 1; end // 321: USUB8;
      30'b0_110100101????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101110,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 322: UXTAB;
      30'b0_110100011????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101100,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 323: UXTAB16;
      30'b0_110100001????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101111,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 324: UXTAH;
      30'b0_110100101????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101110,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 325: UXTB;
      30'b0_110100011????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101100,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 326: UXTB16;
      30'b0_110100001????1111????10?????? : begin t32_to_a32 = {enc[39:36],8'b01101111,enc[3:0],enc[31:28],enc[25:24],6'b000111,enc[23:20]}; done = 1; end // 327: UXTH;
      30'b0_11001???0???????????????????? : begin t32_to_a32 = {enc[39:36],4'b0100,enc[7],enc[6],enc[5],1'b0,enc[3:0],enc[35:20]}; done = 1; end // 328: SIMD load/store instructions;
      30'b0_?1111???????????????????????? : begin t32_to_a32 = {enc[39:36],3'b001,enc[12],enc[7:0],enc[35:20]}; done = 1; end // 329: SIMD data processing instructions;

      endcase
    end
  end
end
endfunction

//
// Auto generated function do not modify
//
function automatic [39:0] undo_t16_to_t32(input [47:0] encoding);
  // Used to help distinguish between ADDS Rd, Rn, Rm in an IT block (it becomes
  // ADD RD, Rn, Rm in an IT block) and ADD Rd, Rd, Rm.
  reg Rd_eq_Rn;
begin
  Rd_eq_Rn = encoding[19:16] == encoding[11: 8];
  casez ({ Rd_eq_Rn, encoding[28: 0] })
    30'b?_100????000000100000000??????? : undo_t16_to_t32 = { 4'b1101,encoding[25:22],1'b0,encoding[6:0] } ; // 3: branch #immediate
    30'b?_101????111111101011111??????? : undo_t16_to_t32 = { 4'b1101,encoding[25:22],1'b1,encoding[6:0] } ; // 4: branch #immediate
    30'b?_1000000000000101110?????????? : undo_t16_to_t32 = { 6'b111000,encoding[9:0] } ; // 5: branch #immediate
    30'b?_1011111111111101111?????????? : undo_t16_to_t32 = { 6'b111001,encoding[9:0] } ; // 6: branch #immediate
    30'b?_101111000????1000111100000000 : undo_t16_to_t32 = { 9'b010001110,encoding[19:19],encoding[18:16],3'b000 } ; // 7: branch <register>
    30'b?_101111000????1000111100000010 : undo_t16_to_t32 = { 9'b010001111,encoding[19:19],encoding[18:16],3'b000 } ; // 8: branch <register>
    30'b?_00000000000001011?0?1???????? : undo_t16_to_t32 = { encoding[15:0] } ; // 9: cbz
    30'b?_0101100010???00000???00000??? : undo_t16_to_t32 = { 7'b0001100,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 10: ADDS <Rd>  <Rn>  <Rm>
    30'b?_0101110110???00000???00000??? : undo_t16_to_t32 = { 7'b0001101,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 11: SUBS <Rd>  <Rn>  <Rm>
    30'b?_1000100010???00000???00000??? : undo_t16_to_t32 = { 7'b0001110,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 12: ADDS <Rd>  <Rn>  #<imm3>
    30'b?_1000110110???00000???00000??? : undo_t16_to_t32 = { 7'b0001111,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 13: SUBS <Rd>  <Rn>  #<imm3>
    30'b?_100000101111100000??????????? : undo_t16_to_t32 = { 5'b00100,encoding[10:8],encoding[7:0] } ; // 14: MOVS <Rd>  #<imm8>
    30'b?_1000110110???00001111???????? : undo_t16_to_t32 = { 5'b00101,encoding[18:16],encoding[7:0] } ; // 15: CMP <Rd>  #<imm8>
    30'b1_1000100010???00000??????????? : undo_t16_to_t32 = { 5'b00110,encoding[10:8],encoding[7:0] } ; // 16: ADDS <Rd>  <Rd>  #<imm8>
    30'b?_1000110110???00000??????????? : undo_t16_to_t32 = { 5'b00111,encoding[10:8],encoding[7:0] } ; // 17: SUBS <Rd>  <Rd>  #<imm8>
    30'b?_01010010111110???0?????000??? : undo_t16_to_t32 = { 5'b00000,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 18: MOVS <Rd>  <Rm>  LSL #<shift_imm>
    30'b?_01010010111110???0?????010??? : undo_t16_to_t32 = { 5'b00001,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 19: MOVS <Rd>  <Rm>  LSR #<shift_imm>
    30'b?_01010010111110???0?????100??? : undo_t16_to_t32 = { 5'b00010,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 20: MOVS <Rd>  <Rm>  ASR #<shift_imm>
    30'b?_0101000010???00000???00000??? : undo_t16_to_t32 = { 10'b0100000000,encoding[2:0],encoding[10:8] } ; // 21: ANDS <Rd>  <Rd>  <Rm>
    30'b?_0101010010???00000???00000??? : undo_t16_to_t32 = { 10'b0100000001,encoding[2:0],encoding[10:8] } ; // 22: EORS <Rd>  <Rd>  <Rm>
    30'b?_1101000010???11110???00000??? : undo_t16_to_t32 = { 10'b0100000010,encoding[2:0],encoding[10:8] } ; // 23: LSLS <Rd>  <Rd>  <Rs>
    30'b?_1101000110???11110???00000??? : undo_t16_to_t32 = { 10'b0100000011,encoding[2:0],encoding[10:8] } ; // 24: LSRS <Rd>  <Rd>  <Rs>
    30'b?_1101001010???11110???00000??? : undo_t16_to_t32 = { 10'b0100000100,encoding[2:0],encoding[10:8] } ; // 25: ASRS <Rd>  <Rd>  <Rs>
    30'b?_0101101010???00000???00000??? : undo_t16_to_t32 = { 10'b0100000101,encoding[2:0],encoding[10:8] } ; // 26: ADCS <Rd>  <Rd>  <Rm>
    30'b?_0101101110???00000???00000??? : undo_t16_to_t32 = { 10'b0100000110,encoding[2:0],encoding[10:8] } ; // 27: SBCS <Rd>  <Rd>  <Rm>
    30'b?_1101001110???11110???00000??? : undo_t16_to_t32 = { 10'b0100000111,encoding[2:0],encoding[10:8] } ; // 28: RORS <Rd>  <Rd>  <Rs>
    30'b?_0101000010???0000111100000??? : undo_t16_to_t32 = { 10'b0100001000,encoding[2:0],encoding[18:16] } ; // 29: TST <Rn>  <Rm>
    30'b?_1000111010???00000???00000000 : undo_t16_to_t32 = { 10'b0100001001,encoding[18:16],encoding[10:8] } ; // 30: RSBS <Rd>  <Rm>  #0
    30'b?_0101110110???0000111100000??? : undo_t16_to_t32 = { 10'b0100001010,encoding[2:0],encoding[18:16] } ; // 31: CMP <Rn>  <Rm>
    30'b?_0101100010???0000111100000??? : undo_t16_to_t32 = { 10'b0100001011,encoding[2:0],encoding[18:16] } ; // 32: CMN <Rn>  <Rm>
    30'b?_0101001010???00000???00000??? : undo_t16_to_t32 = { 10'b0100001100,encoding[2:0],encoding[10:8] } ; // 33: ORRS <Rd>  <Rd>  <Rm>
    30'b?_1101100000???11110???00100??? : undo_t16_to_t32 = { 10'b0100001101,encoding[18:16],encoding[2:0] } ; // 34: MULS <Rd>  <Rd>  <Rm>
    30'b?_0101000110???00000???00000??? : undo_t16_to_t32 = { 10'b0100001110,encoding[2:0],encoding[10:8] } ; // 35: BICS <Rd>  <Rd>  <Rm>
    30'b?_010100111111100000???00000??? : undo_t16_to_t32 = { 10'b0100001111,encoding[2:0],encoding[10:8] } ; // 36: MVNS <Rd>  <Rm>
    30'b?_100100000111100??0?????????00 : undo_t16_to_t32 = { 5'b10100,encoding[10:8],encoding[13:12],encoding[7:2] } ; // 37: ADDW <Rd>  PC  #<imm8> * 4
    30'b?_100010000110100000?????????00 : undo_t16_to_t32 = { 5'b10101,encoding[10:8],2'b00,encoding[7:2] } ; // 38: ADD <Rd>  SP  #<imm8> * 4
    30'b?_101010000110101110???1??????0 : undo_t16_to_t32 = { 5'b10101,encoding[10:8],2'b01,encoding[6:1] } ; // 39: ADD <Rd>  SP  #<imm8> * 4
    30'b?_101010000110101110???0??????? : undo_t16_to_t32 = { 5'b10101,encoding[10:8],1'b1,encoding[6:0] } ; // 40: ADD <Rd>  SP #<imm8> * 4
    30'b?_100010000110100001101??????00 : undo_t16_to_t32 = { 10'b1011000000,encoding[7:2] } ; // 41: ADD SP  SP  #<imm7> * 4
    30'b?_1010100001101011111011??????0 : undo_t16_to_t32 = { 10'b1011000001,encoding[6:1] } ; // 42: ADD SP  SP  #<imm7> * 4
    30'b?_100011010110100001101??????00 : undo_t16_to_t32 = { 10'b1011000010,encoding[7:2] } ; // 43: SUB SP  SP  #<imm7> * 4
    30'b?_1010110101101011111011??????0 : undo_t16_to_t32 = { 10'b1011000011,encoding[6:1] } ; // 44: SUB SP  SP  #<imm7> * 4
    30'b1_010110000????0000????0000???? : undo_t16_to_t32 = { 8'b01000100,encoding[11:11],encoding[3:3],encoding[2:0],encoding[10:8] } ; // 45: ADD <Rd>  <Rd>  <Rm>
    30'b?_010111011????000011110000???? : undo_t16_to_t32 = { 8'b01000101,encoding[19:19],encoding[3:3],encoding[2:0],encoding[18:16] } ; // 46: CMP <Rn>  <Rm>
    30'b?_01010010011110000????0000???? : undo_t16_to_t32 = { 8'b01000110,encoding[11:11],encoding[3:3],encoding[2:0],encoding[10:8] } ; // 47: MOV <Rd>  <Rm>
    30'b?_1100011000???0???00000?????00 : undo_t16_to_t32 = { 5'b01100,encoding[6:2],encoding[18:16],encoding[14:12] } ; // 48: STR <Rd>  [<Rn>  #<imm5> * 4]
    30'b?_1100011010???0???00000?????00 : undo_t16_to_t32 = { 5'b01101,encoding[6:2],encoding[18:16],encoding[14:12] } ; // 49: LDR <Rd>  [<Rn>  #<imm5> * 4]
    30'b?_1100010000???0???0000000????? : undo_t16_to_t32 = { 5'b01110,encoding[4:0],encoding[18:16],encoding[14:12] } ; // 50: STRB <Rd>  [<Rn>  #<imm5>]
    30'b?_1100010010???0???0000000????? : undo_t16_to_t32 = { 5'b01111,encoding[4:0],encoding[18:16],encoding[14:12] } ; // 51: LDRB <Rd>  [<Rn>  #<imm5>]
    30'b?_1100010100???0???000000?????0 : undo_t16_to_t32 = { 5'b10000,encoding[5:1],encoding[18:16],encoding[14:12] } ; // 52: STRH <Rd>  [<Rn>  #<imm5> * 2]
    30'b?_1100010110???0???000000?????0 : undo_t16_to_t32 = { 5'b10001,encoding[5:1],encoding[18:16],encoding[14:12] } ; // 53: LDRH <Rd>  [<Rn>  #<imm5> * 2]
    30'b?_1100001000???0???000000000??? : undo_t16_to_t32 = { 7'b0101000,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 54: STR <Rd>  [<Rn>  <Rm>]
    30'b?_1100000100???0???000000000??? : undo_t16_to_t32 = { 7'b0101001,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 55: STRH <Rd>  [<Rn>  <Rm>]
    30'b?_1100000000???0???000000000??? : undo_t16_to_t32 = { 7'b0101010,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 56: STRB <Rd>  [<Rn>  <Rm>]
    30'b?_1100100010???0???000000000??? : undo_t16_to_t32 = { 7'b0101011,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 57: LDRSB <Rd>  [<Rn>  <Rm>]
    30'b?_1100001010???0???000000000??? : undo_t16_to_t32 = { 7'b0101100,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 58: LDR <Rd>  [<Rn>  <Rm>]
    30'b?_1100000110???0???000000000??? : undo_t16_to_t32 = { 7'b0101101,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 59: LDRH <Rd>  [<Rn>  <Rm>]
    30'b?_1100000010???0???000000000??? : undo_t16_to_t32 = { 7'b0101110,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 60: LDRB <Rd>  [<Rn>  <Rm>]
    30'b?_1100100110???0???000000000??? : undo_t16_to_t32 = { 7'b0101111,encoding[2:0],encoding[18:16],encoding[14:12] } ; // 61: LDRSH <Rd>  [<Rn>  <Rm>]
    30'b?_11000110111110???00????????00 : undo_t16_to_t32 = { 5'b01001,encoding[14:12],encoding[9:2] } ; // 62: LDR <Rd>  [PC  #<imm8> * 4]
    30'b?_11000110011010???00????????00 : undo_t16_to_t32 = { 5'b10010,encoding[14:12],encoding[9:2] } ; // 63: STR <Rd>  [SP  #<imm5> * 4]
    30'b?_11000110111010???00????????00 : undo_t16_to_t32 = { 5'b10011,encoding[14:12],encoding[9:2] } ; // 64: LDR <Rd>  [SP  #<imm5> * 4]
    30'b?_0100010100???00000000???????? : undo_t16_to_t32 = { 5'b11000,encoding[18:16],encoding[7:0] } ; // 65: STMIA <Rn>{!} <register_list>
    30'b?_0100010?10???00000000???????? : undo_t16_to_t32 = { 5'b11001,encoding[18:16],encoding[7:0] } ; // 66: LDMIA <Rn>{!} <register_list>
    30'b?_01001001011010?000000???????? : undo_t16_to_t32 = { 7'b1011010,encoding[14:14],encoding[7:0] } ; // 67: PUSH <register_list>
    30'b?_0100010111101?0000000???????? : undo_t16_to_t32 = { 7'b1011110,encoding[15:15],encoding[7:0] } ; // 68: POP <register_list>
    30'b?_1001110101111100001?0???00000 : undo_t16_to_t32 = { 11'b10110110011,encoding[9:9],1'b0,encoding[7:7],encoding[6:6],encoding[5:5] } ; // 69: CPS<effect> <iflags>
    30'b?_000000000000010110110010????? : undo_t16_to_t32 = { encoding[15:0] } ; // 70: t16 other
    30'b?_1101010010???11110???10000??? : undo_t16_to_t32 = { 10'b1011101000,encoding[2:0],encoding[10:8] } ; // 71: REV <Rd>  <Rn>
    30'b?_1101010010???11110???10010??? : undo_t16_to_t32 = { 10'b1011101001,encoding[2:0],encoding[10:8] } ; // 72: REV16 <Rd>  <Rn>
    30'b?_1101010010???11110???10110??? : undo_t16_to_t32 = { 10'b1011101011,encoding[2:0],encoding[10:8] } ; // 73: REVSH <Rd>  <Rn>
    30'b?_00000000000001011101010?????? : undo_t16_to_t32 = { 10'b1011101010,encoding[5:0] } ; // 75: HLT
    30'b?_000000000000011011111???????? : undo_t16_to_t32 = { encoding[15:0] } ; // 76: t16 other
    30'b?_110100000111111110???10000??? : undo_t16_to_t32 = { 10'b1011001000,encoding[2:0],encoding[10:8] } ; // 77: SUNPK16TO32 <Rd>  <Rm>
    30'b?_110100100111111110???10000??? : undo_t16_to_t32 = { 10'b1011001001,encoding[2:0],encoding[10:8] } ; // 78: SUNPK8TO32 <Rd>  <Rm>
    30'b?_110100001111111110???10000??? : undo_t16_to_t32 = { 10'b1011001010,encoding[2:0],encoding[10:8] } ; // 79: UUNPK16TO32 <Rd>  <Rm>
    30'b?_110100101111111110???10000??? : undo_t16_to_t32 = { 10'b1011001011,encoding[2:0],encoding[10:8] } ; // 80: UUNPK8TO32 <Rd>  <Rm>
    30'b?_1001110101111100000000000???? : undo_t16_to_t32 = { 8'b10111111,encoding[3:0],4'b0000 } ; // 81: NOP | YIELD | WFE | WFI | SEV
    30'b?_000000000000010111111???????? : undo_t16_to_t32 = { encoding[15:0] } ; // 82: t16 other
    // Special case for those instructions which has the S bit cleared but we still want them to match the expected instruction
    // This can only happen when the intruction is generated without the spreadsheet since no T16 to T32 can generate this case
    30'b?_0101100000???00000???00000??? : undo_t16_to_t32 = { 7'b0001100,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 10: ADDS <Rd>  <Rn>  <Rm>
    30'b?_0101110100???00000???00000??? : undo_t16_to_t32 = { 7'b0001101,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 11: SUBS <Rd>  <Rn>  <Rm>
    30'b?_1000100000???00000???00000??? : undo_t16_to_t32 = { 7'b0001110,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 12: ADDS <Rd>  <Rn>  #<imm3>
    30'b?_1000110100???00000???00000??? : undo_t16_to_t32 = { 7'b0001111,encoding[2:0],encoding[18:16],encoding[10:8] } ; // 13: SUBS <Rd>  <Rn>  #<imm3>
    30'b?_100000100111100000??????????? : undo_t16_to_t32 = { 5'b00100,encoding[10:8],encoding[7:0] } ; // 14: MOVS <Rd>  #<imm8>
    30'b1_1000100000???00000??????????? : undo_t16_to_t32 = { 5'b00110,encoding[10:8],encoding[7:0] } ; // 16: ADDS <Rd>  <Rd>  #<imm8>
    30'b?_1000110100???00000??????????? : undo_t16_to_t32 = { 5'b00111,encoding[10:8],encoding[7:0] } ; // 17: SUBS <Rd>  <Rd>  #<imm8>
    30'b?_01010010011110???0?????000??? : undo_t16_to_t32 = { 5'b00000,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 18: MOVS <Rd>  <Rm>  LSL #<shift_imm>
    30'b?_01010010011110???0?????010??? : undo_t16_to_t32 = { 5'b00001,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 19: MOVS <Rd>  <Rm>  LSR #<shift_imm>
    30'b?_01010010011110???0?????100??? : undo_t16_to_t32 = { 5'b00010,encoding[14:12],encoding[7:6],encoding[2:0],encoding[10:8] } ; // 20: MOVS <Rd>  <Rm>  ASR #<shift_imm>
    30'b?_0101000000???00000???00000??? : undo_t16_to_t32 = { 10'b0100000000,encoding[2:0],encoding[10:8] } ; // 21: ANDS <Rd>  <Rd>  <Rm>
    30'b?_0101010000???00000???00000??? : undo_t16_to_t32 = { 10'b0100000001,encoding[2:0],encoding[10:8] } ; // 22: EORS <Rd>  <Rd>  <Rm>
    30'b?_1101000000???11110???00000??? : undo_t16_to_t32 = { 10'b0100000010,encoding[2:0],encoding[10:8] } ; // 23: LSLS <Rd>  <Rd>  <Rs>
    30'b?_1101000100???11110???00000??? : undo_t16_to_t32 = { 10'b0100000011,encoding[2:0],encoding[10:8] } ; // 24: LSRS <Rd>  <Rd>  <Rs>
    30'b?_1101001000???11110???00000??? : undo_t16_to_t32 = { 10'b0100000100,encoding[2:0],encoding[10:8] } ; // 25: ASRS <Rd>  <Rd>  <Rs>
    30'b?_0101101000???00000???00000??? : undo_t16_to_t32 = { 10'b0100000101,encoding[2:0],encoding[10:8] } ; // 26: ADCS <Rd>  <Rd>  <Rm>
    30'b?_0101101100???00000???00000??? : undo_t16_to_t32 = { 10'b0100000110,encoding[2:0],encoding[10:8] } ; // 27: SBCS <Rd>  <Rd>  <Rm>
    30'b?_1101001100???11110???00000??? : undo_t16_to_t32 = { 10'b0100000111,encoding[2:0],encoding[10:8] } ; // 28: RORS <Rd>  <Rd>  <Rs>
    30'b?_1000111000???00000???00000000 : undo_t16_to_t32 = { 10'b0100001001,encoding[18:16],encoding[10:8] } ; // 30: RSBS <Rd>  <Rm>  #0
    30'b?_0101001000???00000???00000??? : undo_t16_to_t32 = { 10'b0100001100,encoding[2:0],encoding[10:8] } ; // 33: ORRS <Rd>  <Rd>  <Rm>
    30'b?_1101100000???11110???00000??? : undo_t16_to_t32 = { 10'b0100001101,encoding[18:16],encoding[2:0] } ; // 34: MULS <Rd>  <Rd>  <Rm>
    30'b?_0101000100???00000???00000??? : undo_t16_to_t32 = { 10'b0100001110,encoding[2:0],encoding[10:8] } ; // 35: BICS <Rd>  <Rd>  <Rm>
    30'b?_010100110111100000???00000??? : undo_t16_to_t32 = { 10'b0100001111,encoding[2:0],encoding[10:8] } ; // 36: MVNS <Rd>  <Rm>
    default: undo_t16_to_t32 = 0;
  endcase
end
endfunction


//
// Auto generated function do not modify
//
function automatic [31:0] t32_to_a64(input [39:0] encoding);

  // split out bits of encoding of interest
  reg a64_only, sf, m, n, d;
  reg  [5:0] sideband;  // used to reconstitute Ra[4]/Rt2[4]
  reg [28:0] t32;
  reg [34:0] t32_encoding;

begin
  {sf, m, n, d, t32[15:0], a64_only, sideband, t32[28:16]} = encoding;
  t32_encoding = {sideband[0], a64_only, sf, m, n, d, t32[28:0]};

  casez (t32_encoding[33:0])
    34'b0????01011100?????0???????0??????? : t32_to_a64 = {t32_encoding[32], 1'b0, t32_encoding[20], 8'b01011001, t32_encoding[31], t32_encoding[3:0], t32_encoding[14:12], t32_encoding[6:4], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 4:ADD (register)
    34'b0????01011001?????0???????0??????? : t32_to_a64 = {t32_encoding[32], 1'b1, t32_encoding[20], 8'b01011001, t32_encoding[31], t32_encoding[3:0], t32_encoding[14:12], t32_encoding[6:4], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 5:SUB (register)
    34'b0?0??10?100000????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b001000100, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 9:ADD (immediate)
    34'b0?1??10?100000????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b001000101, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 10:ADD (immediate)
    34'b0?0??10?101010????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b101000100, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 11:SUB (immediate)
    34'b0?1??10?101010????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b101000101, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 12:SUB (immediate)
    34'b0?0??10?100001????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b011000100, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 13:ADD (immediate)
    34'b0?1??10?100001????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b011000101, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 14:ADD (immediate)
    34'b0?0??10?101011????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b111000100, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 15:SUB (immediate)
    34'b0?1??10?101011????0??????????????? : t32_to_a64 = {t32_encoding[32], 9'b111000101, t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 16:SUB (immediate)
    34'b0????01011000????????????????????? : t32_to_a64 = {t32_encoding[32], 1'b0, t32_encoding[20], 5'b01011, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 20:ADD (register)
    34'b0????01011101????????????????????? : t32_to_a64 = {t32_encoding[32], 1'b1, t32_encoding[20], 5'b01011, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 21:SUB (register)
    34'b0????01011010?????0000????0000???? : t32_to_a64 = {t32_encoding[32], 1'b0, t32_encoding[20], 8'b11010000, t32_encoding[31], t32_encoding[3:0], 6'b000000, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 25:ADC (register)
    34'b0????01011011?????0000????0000???? : t32_to_a64 = {t32_encoding[32], 1'b1, t32_encoding[20], 8'b11010000, t32_encoding[31], t32_encoding[3:0], 6'b000000, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 26:SBC (register)
    34'b0?0??10?110100????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b00100110, t32_encoding[32], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:6], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 30:SBFM
    34'b0?0??10?110110????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b01100110, t32_encoding[32], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:6], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 31:BFM
    34'b0?0??10?111100????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b10100110, t32_encoding[32], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:6], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 32:UBFM
    34'b1?00?10111???????????????????????? : t32_to_a64 = {t32_encoding[32], 6'b011010, t32_encoding[23], t32_encoding[22:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 35:CB{N}Z
    34'b10000101100??????????????????????? : t32_to_a64 = {8'b01010100, t32_encoding[22:16], t32_encoding[11:0], 1'b0, t32_encoding[15:12]}; // 38:B (cond)
    34'b0????110100010????0000???????????? : t32_to_a64 = {t32_encoding[32], 10'b0011010100, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b00, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 42:CSEL
    34'b0????110100010????0001???????????? : t32_to_a64 = {t32_encoding[32], 10'b0011010100, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b01, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 43:CSINC
    34'b0????110100010????0010???????????? : t32_to_a64 = {t32_encoding[32], 10'b1011010100, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b00, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 44:CSINV
    34'b0????110100010????0011???????????? : t32_to_a64 = {t32_encoding[32], 10'b1011010100, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b01, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 45:CSNEG
    34'b0???0110100010????0100???????????? : t32_to_a64 = {t32_encoding[32], 10'b0111010010, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b00, t32_encoding[30], t32_encoding[19:16], 1'b0, t32_encoding[11:8]}; // 49:CCMN
    34'b0???0110100010????0101???????????? : t32_to_a64 = {t32_encoding[32], 10'b1111010010, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b00, t32_encoding[30], t32_encoding[19:16], 1'b0, t32_encoding[11:8]}; // 50:CCMP
    34'b0???0110100010????0110???????????? : t32_to_a64 = {t32_encoding[32], 10'b0111010010, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b10, t32_encoding[30], t32_encoding[19:16], 1'b0, t32_encoding[11:8]}; // 54:CCMN
    34'b0???0110100010????0111???????????? : t32_to_a64 = {t32_encoding[32], 10'b1111010010, t32_encoding[31], t32_encoding[3:0], t32_encoding[7:4], 2'b10, t32_encoding[30], t32_encoding[19:16], 1'b0, t32_encoding[11:8]}; // 55:CCMP
    34'b0??0?110101001????1111????1010???? : t32_to_a64 = {t32_encoding[32], 21'b101101011000000000000, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 59:RBIT
    34'b0??0?110101001????1111????1001???? : t32_to_a64 = {t32_encoding[32], 21'b101101011000000000001, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 60:REV16
    34'b00?0?110101001????1111????1000???? : t32_to_a64 = {22'b0101101011000000000010, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 61:REV (32-bit regs)
    34'b01?0?110101001????1111????1000???? : t32_to_a64 = {22'b1101101011000000000010, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 62:REV32
    34'b01?0?110101001????1111????1011???? : t32_to_a64 = {22'b1101101011000000000011, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 63:REV (64-bit regs)
    34'b0??0?110101011????1111????1000???? : t32_to_a64 = {t32_encoding[32], 21'b101101011000000000100, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 64:CLZ
    34'b0??0?110101011????1111????1001???? : t32_to_a64 = {t32_encoding[32], 21'b101101011000000000101, t32_encoding[31], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 65:CLS
    34'b0????110111011????1111????1111???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b000010, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 69:UDIV
    34'b0????110111001????1111????1111???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b000011, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 70:SDIV
    34'b0????110100000????1111????0000???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b001000, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 71:LSLV
    34'b0????110100010????1111????0000???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b001001, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 72:LSRV
    34'b0????110100100????1111????0000???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b001010, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 73:ASRV
    34'b0????110100110????1111????0000???? : t32_to_a64 = {t32_encoding[32], 10'b0011010110, t32_encoding[31], t32_encoding[3:0], 6'b001011, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 74:ASRV
    34'b00???110101100????1111????1000???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010000, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 75:CRC32B
    34'b00???110101100????1111????1001???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010001, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 76:CRC32H
    34'b00???110101100????1111????1010???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010010, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 77:CRC32W
    34'b01???110101100????1111????1011???? : t32_to_a64 = {11'b10011010110, t32_encoding[31], t32_encoding[3:0], 6'b010011, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 78:CRC32X
    34'b00???110101101????1111????1000???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010100, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 79:CRC32CB
    34'b00???110101101????1111????1001???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010101, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 80:CRC32CH
    34'b00???110101101????1111????1010???? : t32_to_a64 = {11'b00011010110, t32_encoding[31], t32_encoding[3:0], 6'b010110, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 81:CRC32CW
    34'b01???110101101????1111????1011???? : t32_to_a64 = {11'b10011010110, t32_encoding[31], t32_encoding[3:0], 6'b010111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 82:CRC32CX
    34'b0????110110000????????????0000???? : t32_to_a64 = {t32_encoding[32], 10'b0011011000, t32_encoding[31], t32_encoding[3:0], 1'b0, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 86:MADD
    34'b0????110110000????????????0001???? : t32_to_a64 = {t32_encoding[32], 10'b0011011000, t32_encoding[31], t32_encoding[3:0], 1'b1, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 87:MSUB
    34'b01???110111100????????????0001???? : t32_to_a64 = {11'b10011011001, t32_encoding[31], t32_encoding[3:0], 1'b0, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 88:SMADDL
    34'b01???110111101????????????0001???? : t32_to_a64 = {11'b10011011001, t32_encoding[31], t32_encoding[3:0], 1'b1, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 89:SMSUBL
    34'b01???110111100????1111????0010???? : t32_to_a64 = {11'b10011011010, t32_encoding[31], t32_encoding[3:0], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 90:SMULH
    34'b01???110111110????????????0001???? : t32_to_a64 = {11'b10011011101, t32_encoding[31], t32_encoding[3:0], 1'b0, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 91:UMADDL
    34'b01???110111111????????????0001???? : t32_to_a64 = {11'b10011011101, t32_encoding[31], t32_encoding[3:0], 1'b1, t32_encoding[34], t32_encoding[15:12], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 92:UMSUBL
    34'b01???110111110????1111????0010???? : t32_to_a64 = {11'b10011011110, t32_encoding[31], t32_encoding[3:0], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 93:UMULH
    34'b0000000000????????11011111???????? : t32_to_a64 = {11'b11010100000, t32_encoding[23:16], t32_encoding[7:0], 5'b00001}; // 97:SVC
    34'b00000101111110????1000???????????? : t32_to_a64 = {11'b11010100000, t32_encoding[19:16], t32_encoding[11:0], 5'b00010}; // 98:HVC
    34'b00000101111111????1000???????????? : t32_to_a64 = {11'b11010100000, t32_encoding[19:16], t32_encoding[11:0], 5'b00011}; // 99:SMC
    34'b0000000000????????10111110???????? : t32_to_a64 = {11'b11010100001, t32_encoding[23:16], t32_encoding[7:0], 5'b00000}; // 100:BRK
    34'b00000000??????????1011101010?????? : t32_to_a64 = {11'b11010100010, t32_encoding[25:16], t32_encoding[5:0], 5'b00000}; // 101:HLT
    34'b0000010111100011111000000000000001 : t32_to_a64 = {11'b11010100101, 16'b0000000000000000, 5'b00001}; // 102:DCPS1
    34'b0000010111100011111000000000000010 : t32_to_a64 = {11'b11010100101, 16'b0000000000000000, 5'b00010}; // 103:DCPS2
    34'b0000010111100011111000000000000011 : t32_to_a64 = {11'b11010100101, 16'b0000000000000000, 5'b00011}; // 104:DCPS3
    34'b00???110100111????00?????????????? : t32_to_a64 = {11'b00010011100, t32_encoding[31], t32_encoding[3:0], t32_encoding[13:12], t32_encoding[7:4], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 108:EXTR (32-bit)
    34'b01???110100111????00?????????????? : t32_to_a64 = {11'b10010011110, t32_encoding[31], t32_encoding[3:0], t32_encoding[13:12], t32_encoding[7:4], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 109:EXTR (64-bit)
    34'b1000?000000??????????????????????? : t32_to_a64 = {8'b00011000, t32_encoding[22:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 113:LDR 32-bit reg
    34'b1000?000010??????????????????????? : t32_to_a64 = {8'b01011000, t32_encoding[22:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 114:LDR 64-bit reg
    34'b1000?000100??????????????????????? : t32_to_a64 = {8'b10011000, t32_encoding[22:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 115:LDRSW
    34'b1000?000110??????????????????????? : t32_to_a64 = {8'b11011000, t32_encoding[22:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 116:PRFM
    34'b1000?000001??????????????????????? : t32_to_a64 = {8'b00011100, t32_encoding[29], t32_encoding[21:16], t32_encoding[11:0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 117:LDR to FP S reg
    34'b1000?000011??????????????????????? : t32_to_a64 = {8'b01011100, t32_encoding[29], t32_encoding[21:16], t32_encoding[11:0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 118:LDR to FP D reg
    34'b1000?000101??????????????????????? : t32_to_a64 = {8'b10011100, t32_encoding[29], t32_encoding[21:16], t32_encoding[11:0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 119:LDR to FP Q reg
    34'b00???010001100????????11110100???? : t32_to_a64 = {11'b00001000000, t32_encoding[31], t32_encoding[3:0], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 123:STXRB
    34'b00???010001100????????11110101???? : t32_to_a64 = {11'b01001000000, t32_encoding[31], t32_encoding[3:0], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 124:STXRH
    34'b00???010000100????????????00000000 : t32_to_a64 = {11'b10001000000, t32_encoding[31], t32_encoding[11:8], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 125:STXR
    34'b01???010000100????????????00000000 : t32_to_a64 = {11'b11001000000, t32_encoding[31], t32_encoding[11:8], 6'b011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 126:STXR (64-bit)
    34'b000??010001101????????111101001111 : t32_to_a64 = {22'b0000100001011111011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 127:LDXRB
    34'b000??010001101????????111101011111 : t32_to_a64 = {22'b0100100001011111011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 128:LDXRH
    34'b000??010000101????????111100000000 : t32_to_a64 = {22'b1000100001011111011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 129:LDXR
    34'b010??010000101????????111100000000 : t32_to_a64 = {22'b1100100001011111011111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 130:LDXR (64-bit)
    34'b00???010001100????????????0111???? : t32_to_a64 = {11'b10001000001, t32_encoding[31], t32_encoding[3:0], 1'b0, t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 131:STXP
    34'b01???010001100????????????0111???? : t32_to_a64 = {11'b11001000001, t32_encoding[31], t32_encoding[3:0], 1'b0, t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 132:STXP (64-bit)
    34'b00???010001101????????????01111111 : t32_to_a64 = {17'b10001000011111110, t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 133:LDXP
    34'b01???010001101????????????01111111 : t32_to_a64 = {17'b11001000011111110, t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 134:LDXP (64-bit)
    34'b00???010001100????????11111100???? : t32_to_a64 = {11'b00001000000, t32_encoding[31], t32_encoding[3:0], 6'b111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 135:STLXRB
    34'b00???010001100????????11111101???? : t32_to_a64 = {11'b01001000000, t32_encoding[31], t32_encoding[3:0], 6'b111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 136:STLXRH
    34'b00???010001100????????11111110???? : t32_to_a64 = {11'b10001000000, t32_encoding[31], t32_encoding[3:0], 6'b111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 137:STLXR
    34'b01???010001100????????11111110???? : t32_to_a64 = {11'b11001000000, t32_encoding[31], t32_encoding[3:0], 6'b111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 138:STLXR (64-bit)
    34'b000??010001101????????111111001111 : t32_to_a64 = {22'b0000100001011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 139:LDAXRB
    34'b000??010001101????????111111011111 : t32_to_a64 = {22'b0100100001011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 140:LDAXRH
    34'b000??010001101????????111111101111 : t32_to_a64 = {22'b1000100001011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 141:LDAXR
    34'b010??010001101????????111111101111 : t32_to_a64 = {22'b1100100001011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 142:LDAXR (64-bit)
    34'b00???010001100????????????1111???? : t32_to_a64 = {11'b10001000001, t32_encoding[31], t32_encoding[3:0], 1'b1, t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 143:STLXP
    34'b01???010001100????????????1111???? : t32_to_a64 = {11'b11001000001, t32_encoding[31], t32_encoding[3:0], 1'b1, t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 144:STLXP (64-bit)
    34'b00???010001101????????????11111111 : t32_to_a64 = {17'b10001000011111111, t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 145:LDAXP
    34'b01???010001101????????????11111111 : t32_to_a64 = {17'b11001000011111111, t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 146:LDAXP (64-bit)
    34'b000??010001100????????111110001111 : t32_to_a64 = {22'b0000100010011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 147:STLRB
    34'b000??010001100????????111110011111 : t32_to_a64 = {22'b0100100010011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 148:STLRH
    34'b000??010001100????????111110101111 : t32_to_a64 = {22'b1000100010011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 149:STLR
    34'b010??010001100????????111110101111 : t32_to_a64 = {22'b1100100010011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 150:STLR (64-bit)
    34'b000??010001101????????111110001111 : t32_to_a64 = {22'b0000100011011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 151:LDARB
    34'b000??010001101????????111110011111 : t32_to_a64 = {22'b0100100011011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 152:LDARH
    34'b000??010001101????????111110101111 : t32_to_a64 = {22'b1000100011011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 153:LDAR
    34'b010??010001101????????111110101111 : t32_to_a64 = {22'b1100100011011111111111, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 154:LDAR (64-bit)
    34'b00???110000000????????1?1????????? : t32_to_a64 = {11'b00111000000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 158:ST{U}RB
    34'b00???110000010????????1?1????????? : t32_to_a64 = {11'b01111000000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 159:ST{U}RH
    34'b00???110000100????????1?1????????? : t32_to_a64 = {11'b10111000000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 160:ST{U}R
    34'b01???110000110????????1?1????????? : t32_to_a64 = {11'b11111000000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 161:ST{U}R (64-bit)
    34'b00???110000001????????1?1????????? : t32_to_a64 = {11'b00111000010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 162:LD{U}RB
    34'b00???110000011????????1?1????????? : t32_to_a64 = {11'b01111000010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 163:LD{U}RH
    34'b00???110000101????????1?1????????? : t32_to_a64 = {11'b10111000010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 164:LD{U}R
    34'b01???110000111????????1?1????????? : t32_to_a64 = {11'b11111000010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 165:LD{U}R (64-bit)
    34'b01???110010001????????1?1????????? : t32_to_a64 = {11'b00111000100, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 166:LD{U}RSB
    34'b01???110010011????????1?1????????? : t32_to_a64 = {11'b01111000100, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 167:LD{U}RSH
    34'b01???110010101????????1?1????????? : t32_to_a64 = {11'b10111000100, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 168:LD{U}RSW
    34'b00???110010111????????1010???????? : t32_to_a64 = {11'b11111000100, t32_encoding[31], t32_encoding[7:0], 2'b00, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 169:PRFUM
    34'b00???110010001????????1?1????????? : t32_to_a64 = {11'b00111000110, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 170:LD{U}RSB (32-bit)
    34'b00???110010011????????1?1????????? : t32_to_a64 = {11'b01111000110, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 171:LD{U}RSH (32-bit)
    34'b10??0110000?00????????1?0????????? : t32_to_a64 = {11'b00111100000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 172:ST{U}R (8-bit FP reg)
    34'b10??0110000?10????????1?0????????? : t32_to_a64 = {11'b01111100000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 173:ST{U}R (16-bit FP reg)
    34'b10??0110001?00????????1?0????????? : t32_to_a64 = {11'b10111100000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 174:ST{U}R (32-bit FP reg)
    34'b10??0110001?10????????1?0????????? : t32_to_a64 = {11'b11111100000, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 175:ST{U}R (64-bit FP reg)
    34'b10??0110000?01????????1?0????????? : t32_to_a64 = {11'b00111100010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 176:LD{U}R (8-bit FP reg)
    34'b10??0110000?11????????1?0????????? : t32_to_a64 = {11'b01111100010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 177:LD{U}R (16-bit FP reg)
    34'b10??0110001?01????????1?0????????? : t32_to_a64 = {11'b10111100010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 178:LD{U}R (32-bit FP reg)
    34'b10??0110001?11????????1?0????????? : t32_to_a64 = {11'b11111100010, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 179:LD{U}R (64-bit FP reg)
    34'b10??0110010?00????????1?0????????? : t32_to_a64 = {11'b00111100100, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 180:ST{U}R (128-bit FP reg)
    34'b10??0110010?01????????1?0????????? : t32_to_a64 = {11'b00111100110, t32_encoding[31], t32_encoding[7:0], t32_encoding[10], t32_encoding[8], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 181:LD{U}R (128-bit FP reg)
    34'b000??110001000???????????????????? : t32_to_a64 = {10'b0011100100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 185:STRB
    34'b000??110001010???????????????????? : t32_to_a64 = {10'b0111100100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 186:STRH
    34'b000??110001100???????????????????? : t32_to_a64 = {10'b1011100100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 187:STR (32-bit)
    34'b010??110001110???????????????????? : t32_to_a64 = {10'b1111100100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 188:STR (64-bit)
    34'b000??110001001???????????????????? : t32_to_a64 = {10'b0011100101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 189:LDRB
    34'b000??110001011???????????????????? : t32_to_a64 = {10'b0111100101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 190:LDRH
    34'b000??110001101???????????????????? : t32_to_a64 = {10'b1011100101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 191:LDR (32-bit)
    34'b010??110001111???????????????????? : t32_to_a64 = {10'b1111100101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 192:LDR (64-bit)
    34'b010??110011001???????????????????? : t32_to_a64 = {10'b0011100110, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 193:LDRSB
    34'b010??110011011???????????????????? : t32_to_a64 = {10'b0111100110, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 194:LDRSH
    34'b010??110011101???????????????????? : t32_to_a64 = {10'b1011100110, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 195:LDRSW
    34'b000??110011111???????????????????? : t32_to_a64 = {10'b1111100110, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 196:PRFM
    34'b000??110011001???????????????????? : t32_to_a64 = {10'b0011100111, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 197:LDRSB (into 32-bit)
    34'b000??110011011???????????????????? : t32_to_a64 = {10'b0111100111, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 198:LDRSH (into 32-bit)
    34'b100?0110100?00???????????????????? : t32_to_a64 = {10'b0011110100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 199:STR (8-bit FP reg)
    34'b100?0110100?10???????????????????? : t32_to_a64 = {10'b0111110100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 200:STR (16-bit FP reg)
    34'b100?0110101?00???????????????????? : t32_to_a64 = {10'b1011110100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 201:STR (32-bit FP reg)
    34'b100?0110101?10???????????????????? : t32_to_a64 = {10'b1111110100, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 202:STR (64-bit FP reg)
    34'b100?0110100?01???????????????????? : t32_to_a64 = {10'b0011110101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 203:LDR (8-bit FP reg)
    34'b100?0110100?11???????????????????? : t32_to_a64 = {10'b0111110101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 204:LDR (16-bit FP reg)
    34'b100?0110101?01???????????????????? : t32_to_a64 = {10'b1011110101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 205:LDR (32-bit FP reg)
    34'b100?0110101?11???????????????????? : t32_to_a64 = {10'b1111110101, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 206:LDR (64-bit FP reg)
    34'b100?0110110?00???????????????????? : t32_to_a64 = {10'b0011110110, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 207:STR (128-bit FP reg)
    34'b100?0110110?01???????????????????? : t32_to_a64 = {10'b0011110111, t32_encoding[11:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 208:LDR (128-bit FP reg)
    34'b00???110000000????????0????000???? : t32_to_a64 = {11'b00111000001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 212:STRB
    34'b00???110000010????????00???00????? : t32_to_a64 = {11'b01111000001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 213:STRH
    34'b00???110000100????????00???0?0???? : t32_to_a64 = {11'b10111000001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 214:STR (32-bit)
    34'b01???110000110????????00???0?????? : t32_to_a64 = {11'b11111000001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 215:STR (64-bit)
    34'b00???110000001????????0????000???? : t32_to_a64 = {11'b00111000011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 216:LDRB
    34'b00???110000011????????00???00????? : t32_to_a64 = {11'b01111000011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 217:LDRH
    34'b00???110000101????????00???0?0???? : t32_to_a64 = {11'b10111000011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 218:LDR (32-bit)
    34'b01???110000111????????00???0?????? : t32_to_a64 = {11'b11111000011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 219:LDR (64-bit)
    34'b01???110010001????????0????000???? : t32_to_a64 = {11'b00111000101, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 220:LDRSB
    34'b01???110010011????????00???00????? : t32_to_a64 = {11'b01111000101, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 221:LDRSH
    34'b01???110010101????????00???0?0???? : t32_to_a64 = {11'b10111000101, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 222:LDRSW
    34'b00???110010111????????00???0?????? : t32_to_a64 = {11'b11111000101, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 223:PRFM
    34'b00???110010001????????0????000???? : t32_to_a64 = {11'b00111000111, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 224:LDRSB (into 32-bit)
    34'b00???110010011????????00???00????? : t32_to_a64 = {11'b01111000111, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 225:LDRSH (into 32-bit)
    34'b10??0111000?00????????0????000???? : t32_to_a64 = {11'b00111100001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 226:STR (8-bit FP reg)
    34'b10??0111000?10????????00???00????? : t32_to_a64 = {11'b01111100001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 227:STR (16-bit FP reg)
    34'b10??0111001?00????????00???0?0???? : t32_to_a64 = {11'b10111100001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 228:STR (32-bit FP reg)
    34'b10??0111001?10????????00???0?????? : t32_to_a64 = {11'b11111100001, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 229:STR (64-bit FP reg)
    34'b10??0111000?01????????0????000???? : t32_to_a64 = {11'b00111100011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[10], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 230:LDR (8-bit FP reg)
    34'b10??0111000?11????????00???00????? : t32_to_a64 = {11'b01111100011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[4], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 231:LDR (16-bit FP reg)
    34'b10??0111001?01????????00???0?0???? : t32_to_a64 = {11'b10111100011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 232:LDR (32-bit FP reg)
    34'b10??0111001?11????????00???0?????? : t32_to_a64 = {11'b11111100011, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[5], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 233:LDR (64-bit FP reg)
    34'b10??0111010?00????????00????00???? : t32_to_a64 = {11'b00111100101, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[6], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 234:STR (128-bit FP reg)
    34'b10??0111010?01????????00????00???? : t32_to_a64 = {11'b00111100111, t32_encoding[31], t32_encoding[3:0], t32_encoding[9:7], t32_encoding[6], 2'b10, t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 235:LDR (128-bit FP reg)
    34'b100??0010?01?0????????????0??????? : t32_to_a64 = {7'b0010100, t32_encoding[24], t32_encoding[21], 1'b0, t32_encoding[6:0], t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 239:STP (32-bit regs)
    34'b10???0010?01?1????????????0??????? : t32_to_a64 = {7'b0010100, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[6:0], t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 240:LDP (32-bit regs)
    34'b11???0010?01?1????????????1??????? : t32_to_a64 = {7'b0110100, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[6:0], t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 241:LDPSW
    34'b110??0010?11?0????????????0??????? : t32_to_a64 = {7'b1010100, t32_encoding[24], t32_encoding[21], 1'b0, t32_encoding[6:0], t32_encoding[34], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 242:STP (64-bit regs)
    34'b11???0010?11?1????????????0??????? : t32_to_a64 = {7'b1010100, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[6:0], t32_encoding[31], t32_encoding[11:8], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[15:12]}; // 243:LDP (64-bit regs)
    34'b100??0011?0??0???????????????0???? : t32_to_a64 = {7'b0010110, t32_encoding[24], t32_encoding[21], 1'b0, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 244:STP (32-bit FP regs)
    34'b100??0011?0??1???????????????0???? : t32_to_a64 = {7'b0010110, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 245:LDP (32-bit FP regs)
    34'b100??0011?1??0???????????????0???? : t32_to_a64 = {7'b0110110, t32_encoding[24], t32_encoding[21], 1'b0, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 246:STP (64-bit FP regs)
    34'b100??0011?1??1???????????????0???? : t32_to_a64 = {7'b0110110, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 247:LDP (64-bit FP regs)
    34'b100??0011?0??0???????????????1???? : t32_to_a64 = {7'b1010110, t32_encoding[24], t32_encoding[21], 1'b0, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 248:STP (128-bit FP regs)
    34'b100??0011?0??1???????????????1???? : t32_to_a64 = {7'b1010110, t32_encoding[24], t32_encoding[21], 1'b1, t32_encoding[29], t32_encoding[11:6], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 249:LDP (128-bit FP regs)
    34'b0????10?000000????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b00100100, t32_encoding[31], t32_encoding[26], t32_encoding[7:6], t32_encoding[14:12], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 253:AND
    34'b0????10?000100????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b01100100, t32_encoding[31], t32_encoding[26], t32_encoding[7:6], t32_encoding[14:12], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 254:ORR
    34'b0????10?001000????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b10100100, t32_encoding[31], t32_encoding[26], t32_encoding[7:6], t32_encoding[14:12], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 255:EOR
    34'b0????10?000001????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b11100100, t32_encoding[31], t32_encoding[26], t32_encoding[7:6], t32_encoding[14:12], t32_encoding[5:0], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 256:ANDS
    34'b0????010100000???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0001010, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 260:AND
    34'b0????010100010???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0001010, t32_encoding[5:4], 1'b1, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 261:BIC
    34'b0????010100100???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0101010, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 262:ORR
    34'b0????010100110???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0101010, t32_encoding[5:4], 1'b1, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 263:ORN
    34'b0????010101000???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b1001010, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 264:EOR
    34'b0????010101010???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b1001010, t32_encoding[5:4], 1'b1, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 265:EON
    34'b0????010100001???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b1101010, t32_encoding[5:4], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 266:ANDS
    34'b0????010100011???????????????????? : t32_to_a64 = {t32_encoding[32], 7'b1101010, t32_encoding[5:4], 1'b1, t32_encoding[31], t32_encoding[3:0], t32_encoding[15:12], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[29], t32_encoding[11:8]}; // 267:BICS
    34'b0????10?100101????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b00100101, t32_encoding[31:30], t32_encoding[19:16], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[29], t32_encoding[11:8]}; // 271:MOVN
    34'b0????10?100100????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b10100101, t32_encoding[31:30], t32_encoding[19:16], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[29], t32_encoding[11:8]}; // 272:MOVZ
    34'b0????10?101100????0??????????????? : t32_to_a64 = {t32_encoding[32], 8'b11100101, t32_encoding[31:30], t32_encoding[19:16], t32_encoding[26], t32_encoding[14:12], t32_encoding[7:0], t32_encoding[29], t32_encoding[11:8]}; // 273:MOVK
    34'b1000?1000????????????????????????? : t32_to_a64 = {1'b0, t32_encoding[24:23], 5'b10000, t32_encoding[22:12], t32_encoding[7:0], t32_encoding[29], t32_encoding[11:8]}; // 277:ADR
    34'b1000?1001????????????????????????? : t32_to_a64 = {1'b1, t32_encoding[24:23], 5'b10000, t32_encoding[22:12], t32_encoding[7:0], t32_encoding[29], t32_encoding[11:8]}; // 278:ADRP
    34'b010001001110101111100000010000???? : t32_to_a64 = {20'b11010101000000000100, t32_encoding[3:0], 8'b10111111}; // 282:MSR SPSel
    34'b0100010011101011111000011????00000 : t32_to_a64 = {20'b11010101000000110100, t32_encoding[8:5], 8'b11011111}; // 283:MSR DAIFSet
    34'b0100010011101011111000010????00000 : t32_to_a64 = {20'b11010101000000110100, t32_encoding[8:5], 8'b11111111}; // 284:MSR DAIFClr
    34'b010001001110101111100000000??????? : t32_to_a64 = {20'b11010101000000110010, t32_encoding[6:3], t32_encoding[2:0], 5'b11111}; // 285:HINT
    34'b010001001110111111100011110010???? : t32_to_a64 = {20'b11010101000000110011, t32_encoding[3:0], 8'b01011111}; // 286:CLREX
    34'b010001001110111111100011110100???? : t32_to_a64 = {20'b11010101000000110011, t32_encoding[3:0], 8'b10011111}; // 287:DSB
    34'b010001001110111111100011110101???? : t32_to_a64 = {20'b11010101000000110011, t32_encoding[3:0], 8'b10111111}; // 288:DMB
    34'b010001001110111111100011110110???? : t32_to_a64 = {20'b11010101000000110011, t32_encoding[3:0], 8'b11011111}; // 289:ISB
    34'b0100?01110???0????????1101???1???? : t32_to_a64 = {13'b1101010100001, t32_encoding[23:21], t32_encoding[19:16], t32_encoding[3:0], t32_encoding[7:5], t32_encoding[29], t32_encoding[15:12]}; // 290:SYS
    34'b0100?01110???0????????111????1???? : t32_to_a64 = {12'b110101010001, t32_encoding[8], t32_encoding[23:21], t32_encoding[19:16], t32_encoding[3:0], t32_encoding[7:5], t32_encoding[29], t32_encoding[15:12]}; // 291:MSR (system register)
    34'b0100?01110???1????????1101???1???? : t32_to_a64 = {13'b1101010100101, t32_encoding[23:21], t32_encoding[19:16], t32_encoding[3:0], t32_encoding[7:5], t32_encoding[29], t32_encoding[15:12]}; // 292:SYSL
    34'b0100?01110???1????????111????1???? : t32_to_a64 = {12'b110101010011, t32_encoding[8], t32_encoding[23:21], t32_encoding[19:16], t32_encoding[3:0], t32_encoding[7:5], t32_encoding[29], t32_encoding[15:12]}; // 293:MRS
    34'b1?00?10100???????????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0110110, t32_encoding[22:18], t32_encoding[17:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 296:TBZ
    34'b1?00?10101???????????????????????? : t32_to_a64 = {t32_encoding[32], 7'b0110111, t32_encoding[22:18], t32_encoding[17:16], t32_encoding[11:0], t32_encoding[29], t32_encoding[15:12]}; // 297:TBNZ
    34'b00??010???????????10?1???????????? : t32_to_a64 = {6'b000101, t32_encoding[31], t32_encoding[30], t32_encoding[26], t32_encoding[13], t32_encoding[11], t32_encoding[25:16], t32_encoding[10:0]}; // 301:B
    34'b00??010???????????11?1???????????? : t32_to_a64 = {6'b100101, t32_encoding[31], t32_encoding[30], t32_encoding[26], t32_encoding[13], t32_encoding[11], t32_encoding[25:16], t32_encoding[10:0]}; // 302:BL
    34'b000?0101111000????1000111100000001 : t32_to_a64 = {22'b1101011000011111000000, t32_encoding[30], t32_encoding[19:16], 5'b00000}; // 306:BR
    34'b000?0101111000????1000111100000010 : t32_to_a64 = {22'b1101011000111111000000, t32_encoding[30], t32_encoding[19:16], 5'b00000}; // 307:BLR
    34'b000?0101111000????1000111100000000 : t32_to_a64 = {22'b1101011001011111000000, t32_encoding[30], t32_encoding[19:16], 5'b00000}; // 308:RET
    34'b0000010011110111101000111100000000 : t32_to_a64 = {32'b11010110100111110000001111100000}; // 309:ERET
    34'b0000010011110111111000111100000000 : t32_to_a64 = {32'b11010110101111110000001111100000}; // 310:DRPS
    34'b00000011101?110000????101001?0???? : t32_to_a64 = {22'b0001111000100000010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 315:FMOV
    34'b00000011101?110000????101011?0???? : t32_to_a64 = {22'b0001111000100000110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 316:FABS
    34'b00000011101?110001????101001?0???? : t32_to_a64 = {22'b0001111000100001010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 317:FNEG
    34'b00000011101?110001????101011?0???? : t32_to_a64 = {22'b0001111000100001110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 318:FSQRT
    34'b00000011101?110111????101011?0???? : t32_to_a64 = {22'b0001111000100010110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 319:FCVT (SP > DP)
    34'b00000011101?110011????101001?0???? : t32_to_a64 = {22'b0001111000100011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 320:FCVT (SP > HP)
    34'b00000111101?111001????101001?0???? : t32_to_a64 = {22'b0001111000100100010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 321:FRINTN
    34'b00000111101?111010????101001?0???? : t32_to_a64 = {22'b0001111000100100110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 322:FRINTP
    34'b00000111101?111011????101001?0???? : t32_to_a64 = {22'b0001111000100101010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 323:FRINTM
    34'b00000011101?110110????101011?0???? : t32_to_a64 = {22'b0001111000100101110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 324:FRINTZ
    34'b00000111101?111000????101001?0???? : t32_to_a64 = {22'b0001111000100110010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 325:FRINTA
    34'b00000011101?110111????101001?0???? : t32_to_a64 = {22'b0001111000100111010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 326:FRINTX
    34'b00000011101?110110????101001?0???? : t32_to_a64 = {22'b0001111000100111110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 327:FRINTI
    34'b00000011101?110000????101101?0???? : t32_to_a64 = {22'b0001111001100000010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 328:FMOV
    34'b00000011101?110000????101111?0???? : t32_to_a64 = {22'b0001111001100000110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 329:FABS
    34'b00000011101?110001????101101?0???? : t32_to_a64 = {22'b0001111001100001010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 330:FNEG
    34'b00000011101?110001????101111?0???? : t32_to_a64 = {22'b0001111001100001110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 331:FSQRT
    34'b00000011101?110111????101111?0???? : t32_to_a64 = {22'b0001111001100010010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 332:FCVT (DP > SP)
    34'b00000011101?110011????101101?0???? : t32_to_a64 = {22'b0001111001100011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 333:FCVT (DP > HP)
    34'b00000111101?111001????101101?0???? : t32_to_a64 = {22'b0001111001100100010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 334:FRINTN
    34'b00000111101?111010????101101?0???? : t32_to_a64 = {22'b0001111001100100110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 335:FRINTP
    34'b00000111101?111011????101101?0???? : t32_to_a64 = {22'b0001111001100101010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 336:FRINTM
    34'b00000011101?110110????101111?0???? : t32_to_a64 = {22'b0001111001100101110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 337:FRINTZ
    34'b00000111101?111000????101101?0???? : t32_to_a64 = {22'b0001111001100110010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 338:FRINTA
    34'b00000011101?110111????101101?0???? : t32_to_a64 = {22'b0001111001100111010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 339:FRINTX
    34'b00000011101?110110????101101?0???? : t32_to_a64 = {22'b0001111001100111110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 340:FRINTI
    34'b00000011101?110010????101001?0???? : t32_to_a64 = {22'b0001111011100010010000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 341:FCVT (HP>SP)
    34'b00000011101?110010????101101?0???? : t32_to_a64 = {22'b0001111011100010110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 342:FCVT (DP > HP)
    34'b00000011101?110100????101001?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b00000}; // 346:FCMP
    34'b00000011101?110101????101001000000 : t32_to_a64 = {22'b0001111000100000001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b01000}; // 347:FCMP (with zero)
    34'b00000011101?110100????101011?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b10000}; // 348:FCMPE
    34'b00000011101?110101????101011000000 : t32_to_a64 = {22'b0001111000100000001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b11000}; // 349:FCMPE (with zero)
    34'b00000011101?110100????101101?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b00000}; // 350:FCMP
    34'b00000011101?110101????101101000000 : t32_to_a64 = {22'b0001111001100000001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b01000}; // 351:FCMP (with zero)
    34'b00000011101?110100????101111?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b10000}; // 352:FCMPE
    34'b00000011101?110101????101111000000 : t32_to_a64 = {22'b0001111001100000001000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13], 5'b11000}; // 353:FCMPE (with zero)
    34'b00000011101?11????????10100000???? : t32_to_a64 = {11'b00011110001, t32_encoding[19:16], t32_encoding[3:0], 8'b10000000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 357:FMOV
    34'b00000011101?11????????10110000???? : t32_to_a64 = {11'b00011110011, t32_encoding[19:16], t32_encoding[3:0], 8'b10000000, t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 358:FMOV
    34'b00000011100?10????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 362:FMUL
    34'b00000011101?00????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 363:FDIV
    34'b00000011100?11????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 364:FADD
    34'b00000011100?11????????1010?1?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 365:FSUB
    34'b00000111101?01????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 366:FMAX
    34'b00000111101?01????????1010?1?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 367:FMIN
    34'b00000111101?00????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 368:FMAXNM
    34'b00000111101?00????????1010?1?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 369:FMINNM
    34'b00000011100?10????????1010?1?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 370:FNMUL
    34'b00000011100?10????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 371:FMUL
    34'b00000011101?00????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 372:FDIV
    34'b00000011100?11????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 373:FADD
    34'b00000011100?11????????1011?1?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 374:FSUB
    34'b00000111101?01????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 375:FMAX
    34'b00000111101?01????????1011?1?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 376:FMIN
    34'b00000111101?00????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 377:FMAXNM
    34'b00000111101?00????????1011?1?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011110, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 378:FMINNM
    34'b00000011100?10????????1011?1?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100010, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 379:FNMUL
    34'b10??01111000??????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b01, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 1'b0, t32_encoding[15:12]}; // 383:FCCMP
    34'b10??01111000??????????1010?1?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b01, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 1'b1, t32_encoding[15:12]}; // 384:FCCMPE
    34'b10??01111000??????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b01, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 1'b0, t32_encoding[15:12]}; // 385:FCCMP
    34'b10??01111000??????????1011?1?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b01, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 1'b1, t32_encoding[15:12]}; // 386:FCCMPE
    34'b00??0111100???????????1010?0?0???? : t32_to_a64 = {11'b00011110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b11, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 390:FCSEL
    34'b00??0111100???????????1011?0?0???? : t32_to_a64 = {11'b00011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[21:20], t32_encoding[31:30], 2'b11, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 391:FCSEL
    34'b1000?111101?00?????????????0?0???? : t32_to_a64 = {11'b00011111000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 395:FMADD
    34'b1000?111101?00?????????????1?0???? : t32_to_a64 = {11'b00011111000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b1, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 396:FMSUB
    34'b1000?111101?01?????????????0?0???? : t32_to_a64 = {11'b00011111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 397:FNMADD
    34'b1000?111101?01?????????????1?0???? : t32_to_a64 = {11'b00011111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b1, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 398:FNMSUB
    34'b1000?111101?10?????????????0?0???? : t32_to_a64 = {11'b00011111010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 399:FMADD
    34'b1000?111101?10?????????????1?0???? : t32_to_a64 = {11'b00011111010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b1, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 400:FMSUB
    34'b1000?111101?11?????????????0?0???? : t32_to_a64 = {11'b00011111011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 401:FNMADD
    34'b1000?111101?11?????????????1?0???? : t32_to_a64 = {11'b00011111011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b1, t32_encoding[8], t32_encoding[29], t32_encoding[11:9], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 402:FNMSUB
    34'b0?00?011101101????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111000011000, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 406:FCVTZS
    34'b0?00?011100011????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111000011001, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 407:FCVTZU
    34'b0?00?011101100????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111000000010, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 408:SCVTF
    34'b0?00?011100010????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111000000011, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 409:UCVTF
    34'b0?10?011101101????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111001011000, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 410:FCVTZS
    34'b0?10?011100011????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111001011001, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 411:FCVTZU
    34'b0?10?011101100????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111001000010, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 412:SCVTF
    34'b0?10?011100010????????1010???1???? : t32_to_a64 = {t32_encoding[32], 15'b001111001000011, t32_encoding[6], t32_encoding[3:0], t32_encoding[5], t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 413:UCVTF
    34'b0?00?011100101????????1010???10000 : t32_to_a64 = {t32_encoding[32], 10'b0011110001, t32_encoding[6:5], 9'b000000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 417:FCVT{N|P|M|Z}S
    34'b0?00?011100111????????1010???10000 : t32_to_a64 = {t32_encoding[32], 10'b0011110001, t32_encoding[6:5], 9'b001000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 418:FCVT{N|P|M|Z}U
    34'b0?00?011100100????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111000100010000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 419:SCVTF
    34'b0?00?011100110????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111000100011000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 420:UCVTF
    34'b0?00?011101001????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111000100100000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 421:FCVTAS
    34'b0?00?011101011????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111000100101000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 422:FCVTAU
    34'b0000?011100001????????1010?0010000 : t32_to_a64 = {22'b0001111000100110000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 423:FMOV
    34'b0000?011100000????????1010?0010000 : t32_to_a64 = {22'b0001111000100111000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 424:FMOV
    34'b0?10?011100101????????1010???10000 : t32_to_a64 = {t32_encoding[32], 10'b0011110011, t32_encoding[6:5], 9'b000000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 425:FCVT{N|P|M|Z}S
    34'b0?10?011100111????????1010???10000 : t32_to_a64 = {t32_encoding[32], 10'b0011110011, t32_encoding[6:5], 9'b001000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 426:FCVT{N|P|M|Z}U
    34'b0?10?011100100????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111001100010000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 427:SCVTF
    34'b0?10?011100110????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111001100011000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 428:UCVTF
    34'b0?10?011101001????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111001100100000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 429:FCVTAS
    34'b0?10?011101011????????1010?0010000 : t32_to_a64 = {t32_encoding[32], 21'b001111001100101000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 430:FCVTAU
    34'b0100?011100001????????1010?0010000 : t32_to_a64 = {22'b1001111001100110000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 431:FMOV
    34'b0100?011100000????????1010?0010000 : t32_to_a64 = {22'b1001111001100111000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 432:FMOV
    34'b0100?011100001????????1010?0110000 : t32_to_a64 = {22'b1001111010101110000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 433:FMOV
    34'b0100?011100000????????1010?0110000 : t32_to_a64 = {22'b1001111010101111000000, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 434:FMOV
    34'b00?00111111?11????????10?????0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[9:8], t32_encoding[6], 2'b00, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 439:Table (TBL/TBX)
    34'b10000011110???????????0??????0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[21:20], 1'b0, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[10:8], 2'b10, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 442:Permute
    34'b00000011111?11???????????????0???? : t32_to_a64 = {1'b0, t32_encoding[6], 9'b101110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 1'b0, t32_encoding[11:8], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 445:Extract
    34'b000?0111111?11????????11000??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 9'b001110000, t32_encoding[30], t32_encoding[19:16], 6'b000001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 449:DUP
    34'b0000?0111011?0????????1011?0010000 : t32_to_a64 = {1'b0, t32_encoding[21], 20'b00111000000001000011, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 450:DUP (byte from ARM)
    34'b0000?0111010?0????????1011?0110000 : t32_to_a64 = {1'b0, t32_encoding[21], 20'b00111000000010000011, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 451:DUP (hword from ARM)
    34'b0000?0111010?0????????1011?0010000 : t32_to_a64 = {1'b0, t32_encoding[21], 20'b00111000000100000011, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 452:DUP (word from ARM)
    34'b0100?0111011?0????????1011?0110000 : t32_to_a64 = {1'b0, t32_encoding[21], 20'b00111000001000000011, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 453:DUP (dword from ARM)
    34'b00?0?0111001?0????????1011???10000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], t32_encoding[5], 7'b1000111, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 454:INS (byte from ARM)
    34'b00?0?0111000?0????????1011??110000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], 8'b10000111, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 455:INS (hword from ARM)
    34'b00?0?0111000?0????????1011?0010000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], t32_encoding[21], 9'b100000111, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 456:INS (word from ARM)
    34'b00?0?011100010????????1011?1010000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], 10'b1000000111, t32_encoding[29], t32_encoding[15:12], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 457:INS (dword from ARM)
    34'b0??0?0111001?1????????1011???10000 : t32_to_a64 = {1'b0, t32_encoding[32], 9'b001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], t32_encoding[5], 7'b1001011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 458:SMOV (byte)
    34'b0??0?0111000?1????????1011??110000 : t32_to_a64 = {1'b0, t32_encoding[32], 9'b001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], 8'b10001011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 459:SMOV (hword)
    34'b01?0?0111000?1????????1011?0010000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], t32_encoding[21], 9'b100001011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 460:SMOV (word)
    34'b00?0?0111011?1????????1011???10000 : t32_to_a64 = {11'b00001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], t32_encoding[5], 7'b1001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 461:UMOV (byte)
    34'b00?0?0111010?1????????1011??110000 : t32_to_a64 = {11'b00001110000, t32_encoding[31], t32_encoding[21], t32_encoding[6], 8'b10001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 462:UMOV (hword)
    34'b00?0?0111010?1????????1011?0010000 : t32_to_a64 = {11'b00001110000, t32_encoding[31], t32_encoding[21], 9'b100001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 463:UMOV (word)
    34'b01?0?011101011????????1011?1010000 : t32_to_a64 = {11'b01001110000, t32_encoding[31], 10'b1000001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[29], t32_encoding[15:12]}; // 464:UMOV (dword)
    34'b00??0111111?11????????111????0???? : t32_to_a64 = {11'b01101110000, t32_encoding[31], t32_encoding[15:12], 1'b0, t32_encoding[30], t32_encoding[22], t32_encoding[8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[16], t32_encoding[7], t32_encoding[19:17]}; // 465:INS (from vector)
    34'b00000?11110???????????0000???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 469:{S|U}HADD
    34'b00000?11110???????????0000???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 470:{S|U}QADD
    34'b00000?11110???????????0001???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 471:{S|U}RHADD
    34'b00000?11110???????????0001???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 472:AND/BIC/ORR/ORN/EOR/BSL/BIT/BIF
    34'b00000?11110???????????0010???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 473:{S|U}HSUB
    34'b00000?11110???????????0010???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 474:{S|U}QSUB
    34'b00000?11110???????????0011???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 475:CM{GT|HI}
    34'b00000?11110???????????0011???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 476:CM{GE|HS}
    34'b00000?11110???????????0100???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 477:{S|U}SHL
    34'b00000?11110???????????0100???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 478:{S|U}QSHL
    34'b00000?11110???????????0101???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 479:{S|U}RSHL
    34'b00000?11110???????????0101???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 480:{S|U}QRSHL
    34'b00000?11110???????????0110???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 481:{S|U}MAX
    34'b00000?11110???????????0110???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 482:{S|U}MIN
    34'b00000?11110???????????0111???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 483:{S|U}ABD
    34'b00000?11110???????????0111???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 484:{S|U}ABA
    34'b00000?11110???????????1000???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 485:ADD/SUB
    34'b00000?11110???????????1000???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 486:CM{TST|EQ}
    34'b00000?11110???????????1001???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 487:ML{A|S}
    34'b00000?11110???????????1001???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 488:{P}MUL
    34'b00000?11110???????????1010???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 489:{S|U}MAXP
    34'b00000?11110???????????1010???1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 490:{S|U}MINP
    34'b00000?11110???????????1011???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 491:SQ{R}DMULH
    34'b00000011110???????????1011???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 492:ADDP
    34'b00000111110???????????1111???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 493:F{MAX|MIN}NM
    34'b10000111110???????????1100???0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 494:F{MAX|MIN}NMP
    34'b00000011110???????????1100???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 495:FML{A|S}
    34'b00000?11110???????????1101???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 496:FADD/FADDP/FSUB/FABD
    34'b00000111110?1?????????1101???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011100, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 497:FMULX
    34'b00000111110?0?????????1101???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011100, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 498:FMUL
    34'b00000?11110???????????1110???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 499:FCM{EQ|GE|GT}
    34'b00000111110???????????1110???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 500:FAC{GE|GT}
    34'b00000?11110???????????1111???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 501:F{MIN|MAX}{P}
    34'b00000011110???????????1111???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 502:FRECPS/FRSQRTS
    34'b10000111110?0?????????1111???1???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011100, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 503:FDIV
    34'b01000?11110???????????0000?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 506:{S|U}QADD
    34'b01000?11110???????????0010?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 507:{S|U}QSUB
    34'b01000?11110???????????0011?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 508:CM{GT|HI}
    34'b01000?11110???????????0011?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 509:CM{GE|HS}
    34'b01000?11110???????????0100?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 510:{S|U}SHL
    34'b01000?11110???????????0100?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 511:{S|U}QSHL
    34'b01000?11110???????????0101?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 512:{S|U}RSHL
    34'b01000?11110???????????0101?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], 6'b010111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 513:{S|U}QRSHL
    34'b01000?11110???????????1000?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 514:ADD/SUB
    34'b01000?11110???????????1000?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 515:CM{TST|EQ}
    34'b01000?11110???????????1011?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 516:SQ{R}DMULH
    34'b01000111110?1?????????1101?0?0???? : t32_to_a64 = {9'b011111101, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110101, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 517:FABD
    34'b01000111110?1?????????1101?0?1???? : t32_to_a64 = {9'b010111100, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 518:FMULX
    34'b01000111110?0?????????1101?0?1???? : t32_to_a64 = {9'b011111100, t32_encoding[20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 519:FMUL
    34'b01000?11110???????????1110?0?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111001, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 520:FCM{EQ|GE|GT}
    34'b01000111110???????????1110?0?1???? : t32_to_a64 = {8'b01111110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111011, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 521:FAC{GE|GT}
    34'b01000?11110???????????1111?0?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[21:20], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111111, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 522:FRECPS/FRSQRTS
    34'b00?00?11111?00????????0000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 527:{S|U}ADDL
    34'b00?00?11111?01????????0000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 528:{S|U}ADDL
    34'b00?00?11111?10????????0000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 529:{S|U}ADDL
    34'b00?00?11111?00????????0001?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 530:{S|U}ADDW
    34'b00?00?11111?01????????0001?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 531:{S|U}ADDW
    34'b00?00?11111?10????????0001?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 532:{S|U}ADDW
    34'b00?00?11111?00????????0010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 533:{S|U}SUBL
    34'b00?00?11111?01????????0010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 534:{S|U}SUBL
    34'b00?00?11111?10????????0010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 535:{S|U}SUBL
    34'b00?00?11111?00????????0011?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 536:{S|U}SUBW
    34'b00?00?11111?01????????0011?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 537:{S|U}SUBW
    34'b00?00?11111?10????????0011?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 538:{S|U}SUBW
    34'b00?00?11111?00????????0100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 539:{R}ADDHN
    34'b00?00?11111?01????????0100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 540:{R}ADDHN
    34'b00?00?11111?10????????0100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 541:{R}ADDHN
    34'b00?00?11111?00????????0101?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 542:{S|U}ABAL
    34'b00?00?11111?01????????0101?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 543:{S|U}ABAL
    34'b00?00?11111?10????????0101?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 544:{S|U}ABAL
    34'b00?00?11111?00????????0110?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 545:{R}SUBHN
    34'b00?00?11111?01????????0110?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 546:{R}SUBHN
    34'b00?00?11111?10????????0110?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 547:{R}SUBHN
    34'b00?00?11111?00????????0111?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 548:{S|U}ABDL
    34'b00?00?11111?01????????0111?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 549:{S|U}ABDL
    34'b00?00?11111?10????????0111?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 550:{S|U}ABDL
    34'b00?00?11111?00????????1000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 551:{S|U}MLAL
    34'b00?00?11111?01????????1000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 552:{S|U}MLAL
    34'b00?00?11111?10????????1000?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 553:{S|U}MLAL
    34'b00?00?11111?00????????1010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 554:{S|U}MLSL
    34'b00?00?11111?01????????1010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 555:{S|U}MLSL
    34'b00?00?11111?10????????1010?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 556:{S|U}MLSL
    34'b00?00011111?01????????1001?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 557:SQDMLAL
    34'b00?00011111?10????????1001?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 558:SQDMLAL
    34'b00?00011111?01????????1011?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 559:SQDMLSL
    34'b00?00011111?10????????1011?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 560:SQDMLSL
    34'b00?00?11111?00????????1100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 561:{S|U}MULL
    34'b00?00?11111?01????????1100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 562:{S|U}MULL
    34'b00?00?11111?10????????1100?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 563:{S|U}MULL
    34'b00?00011111?01????????1101?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 564:SQDMULL
    34'b00?00011111?10????????1101?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 565:SQDMULL
    34'b00?00011111?00????????1110?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 566:PMULL
    34'b00?00011111?10????????1110?0?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 9'b001110111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b111000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 567:PMULL
    34'b01000011111?01????????1001?0?0???? : t32_to_a64 = {11'b01011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 571:SQDMLAL
    34'b01000011111?10????????1001?0?0???? : t32_to_a64 = {11'b01011110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b100100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 572:SQDMLAL
    34'b01000011111?01????????1011?0?0???? : t32_to_a64 = {11'b01011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 573:SQDMLSL
    34'b01000011111?10????????1011?0?0???? : t32_to_a64 = {11'b01011110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b101100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 574:SQDMLSL
    34'b01000011111?01????????1101?0?0???? : t32_to_a64 = {11'b01011110011, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 575:SQDMULL
    34'b01000011111?10????????1101?0?0???? : t32_to_a64 = {11'b01011110101, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b110100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 576:SQDMULL
    34'b00000111111?11??00????00000??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000000010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 580:REV64
    34'b00000111111?11??00????00001??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[19:18], 12'b100000000010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 581:REV32
    34'b00000111111?11??00????00010??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000000110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 582:REV16
    34'b00000111111?11??00????0010???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 5'b01110, t32_encoding[19:18], 12'b100000001010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 583:{S|U}ADDLP
    34'b10000111111?11??00????0011???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 5'b01110, t32_encoding[19:18], 12'b100000001110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 584:{SU|US}QADD
    34'b00000111111?11??00????01000??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000010010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 585:CLS
    34'b00000111111?11??00????01001??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[19:18], 12'b100000010010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 586:CLZ
    34'b00000111111?11??00????01010??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000010110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 587:CNT
    34'b00000111111?110000????01011??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 20'b10111000100000010110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 588:NOT
    34'b00000111111?110100????01011??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 20'b10111001100000010110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 589:RBIT
    34'b00000111111?11??00????0110???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 5'b01110, t32_encoding[19:18], 12'b100000011010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 590:{S|U}ADALP
    34'b00000111111?11??00????01110??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 591:SQABS
    34'b00000111111?11??00????01111??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[19:18], 12'b100000011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 592:SQNEG
    34'b00000111111?11??01????0000???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 5'b01110, t32_encoding[19:18], 12'b100000100010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 593:CM{GT|GE}
    34'b00000111111?11??01????0001???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 5'b01110, t32_encoding[19:18], 12'b100000100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 594:CM{EQ|LE}
    34'b00000111111?11??01????00100??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 595:CMLT
    34'b00000111111?11??01????00110??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b001110, t32_encoding[19:18], 12'b100000101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 596:ABS
    34'b00000111111?11??01????00111??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 6'b101110, t32_encoding[19:18], 12'b100000101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 597:NEG
    34'b00000111111?111?01????0100???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011101, t32_encoding[18], 12'b100000110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 598:FCM{GT|GE}
    34'b00000111111?111?01????0101???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011101, t32_encoding[18], 12'b100000110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 599:FCM{EQ|LE}
    34'b00000111111?111?01????01100??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100000111010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 600:FCMLT
    34'b00000111111?111?01????01110??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100000111110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 601:FABS
    34'b00000111111?111?01????01111??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011101, t32_encoding[18], 12'b100000111110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 602:FNEG
    34'b00?00111111?11??10????001000?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 6'b001110, t32_encoding[19:18], 12'b100001001010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 603:XTN
    34'b00?00111111?11??10????001001?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 6'b101110, t32_encoding[19:18], 12'b100001001010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 604:SQXTUN
    34'b00?00111111?11??10????001100?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 6'b101110, t32_encoding[19:18], 12'b100001001110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 605:SHLL
    34'b00?00111111?11??10????00101??0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[6], 5'b01110, t32_encoding[19:18], 12'b100001010010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 606:[SU]QXTN
    34'b00?00111111?110110????011000?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 20'b00111000100001011010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 607:FCVTN (S->H)
    34'b00?00111111?111010????01100??0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[6], 19'b0111001100001011010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 608:FCVT{X}N (D->S)
    34'b00?00111111?110110????011100?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 20'b00111000100001011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 609:FCVTL (H->S)
    34'b00?00111111?111010????011100?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 20'b00111001100001011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 610:FCVTL (S->D)
    34'b00000111111?111?10????01000??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011100, t32_encoding[18], 12'b100001100010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 611:FRINTN
    34'b00000111111?111?10????01101??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011100, t32_encoding[18], 12'b100001100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 612:FRINTM
    34'b00000111111?111?10????01111??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100001100010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 613:FRINTP
    34'b00000111111?111?10????01011??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100001100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 614:FRINTZ
    34'b00000111111?111?10????01010??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011100, t32_encoding[18], 12'b100001100010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 615:FRINTA
    34'b00000111111?111?10????01001??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011100, t32_encoding[18], 12'b100001100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 616:FRINTX
    34'b10000111111?111?10????01001??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011101, t32_encoding[18], 12'b100001100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 617:FRINTI
    34'b00000111111?111?11????0001???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011100, t32_encoding[18], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 618:FCVTN[SU]
    34'b00000111111?111?11????0010???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011101, t32_encoding[18], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 619:FCVTP[SU]
    34'b00000111111?111?11????0011???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011100, t32_encoding[18], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 620:FCVTM[SU]
    34'b00000111111?111?11????0111???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011101, t32_encoding[18], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 621:FCVTZ[SU]
    34'b00000111111?111?11????0000???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011100, t32_encoding[18], 12'b100001110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 622:FCVTA[SU]
    34'b00000111111?111?11????01000??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100001110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 623:URECPE
    34'b00000111111?111?11????01001??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011101, t32_encoding[18], 12'b100001110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 624:URSQRTE
    34'b00000111111?111?11????0110???0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[7], 6'b011100, t32_encoding[18], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 625:{S|U}CVTF
    34'b00000111111?111?11????01010??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b0011101, t32_encoding[18], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 626:FRECPE
    34'b00000111111?111?11????01011??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011101, t32_encoding[18], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 627:FRSQRTE
    34'b10000111111?111?11????01111??0???? : t32_to_a64 = {1'b0, t32_encoding[6], 7'b1011101, t32_encoding[18], 12'b100001111110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 628:FSQRT
    34'b11000111111?11??00????0011?0?0???? : t32_to_a64 = {2'b01, t32_encoding[7], 5'b11110, t32_encoding[19:18], 12'b100000001110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 631:{SU|US}QADD
    34'b01000111111?11??00????011100?0???? : t32_to_a64 = {8'b01011110, t32_encoding[19:18], 12'b100000011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 632:SQABS
    34'b01000111111?11??00????011110?0???? : t32_to_a64 = {8'b01111110, t32_encoding[19:18], 12'b100000011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 633:SQNEG
    34'b01000111111?11??01????0000?0?0???? : t32_to_a64 = {2'b01, t32_encoding[7], 5'b11110, t32_encoding[19:18], 12'b100000100010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 634:CM{GT|GE}
    34'b01000111111?11??01????0001?0?0???? : t32_to_a64 = {2'b01, t32_encoding[7], 5'b11110, t32_encoding[19:18], 12'b100000100110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 635:CM{EQ|LE}
    34'b01000111111?11??01????001000?0???? : t32_to_a64 = {8'b01011110, t32_encoding[19:18], 12'b100000101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 636:CMLT
    34'b01000111111?11??01????001100?0???? : t32_to_a64 = {8'b01011110, t32_encoding[19:18], 12'b100000101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 637:ABS
    34'b01000111111?11??01????001110?0???? : t32_to_a64 = {8'b01111110, t32_encoding[19:18], 12'b100000101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 638:NEG
    34'b01000111111?111?01????0100?0?0???? : t32_to_a64 = {2'b01, t32_encoding[7], 6'b111101, t32_encoding[18], 12'b100000110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 639:FCM{GT|GE}
    34'b01000111111?111?01????0101?0?0???? : t32_to_a64 = {2'b01, t32_encoding[7], 6'b111101, t32_encoding[18], 12'b100000110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 640:FCM{EQ|LE}
    34'b01000111111?111?01????011000?0???? : t32_to_a64 = {9'b010111101, t32_encoding[18], 12'b100000111010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 641:FCMLT
    34'b01000111111?11??10????001001?0???? : t32_to_a64 = {8'b01111110, t32_encoding[19:18], 12'b100001001010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 642:SQXTUN
    34'b01000111111?11??10????00101??0???? : t32_to_a64 = {2'b01, t32_encoding[6], 5'b11110, t32_encoding[19:18], 12'b100001010010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 643:{S|U}QXTN
    34'b01000111111?111010????011001?0???? : t32_to_a64 = {22'b0111111001100001011010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 644:FCVTXN
    34'b01000111101?111101????101?11?0???? : t32_to_a64 = {9'b010111100, t32_encoding[8], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 645:FCVTNS
    34'b01000111101?111101????101?01?0???? : t32_to_a64 = {9'b011111100, t32_encoding[8], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 646:FCVTNU
    34'b01000111101?111110????101?11?0???? : t32_to_a64 = {9'b010111101, t32_encoding[8], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 647:FCVTPS
    34'b01000111101?111110????101?01?0???? : t32_to_a64 = {9'b011111101, t32_encoding[8], 12'b100001101010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 648:FCVTPU
    34'b01000111101?111111????101?11?0???? : t32_to_a64 = {9'b010111100, t32_encoding[8], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 649:FCVTMS
    34'b01000111101?111111????101?01?0???? : t32_to_a64 = {9'b011111100, t32_encoding[8], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 650:FCVTMU
    34'b01000011101?111101????101?11?0???? : t32_to_a64 = {9'b010111101, t32_encoding[8], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 651:FCVTZS
    34'b01000011101?111100????101?11?0???? : t32_to_a64 = {9'b011111101, t32_encoding[8], 12'b100001101110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 652:FCVTZU
    34'b01000111101?111100????101?11?0???? : t32_to_a64 = {9'b010111100, t32_encoding[8], 12'b100001110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 653:FCVTAS
    34'b01000111101?111100????101?01?0???? : t32_to_a64 = {9'b011111100, t32_encoding[8], 12'b100001110010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 654:FCVTAU
    34'b01000011101?111000????101?11?0???? : t32_to_a64 = {9'b010111100, t32_encoding[8], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 655:SCVTF
    34'b01000011101?111000????101?01?0???? : t32_to_a64 = {9'b011111100, t32_encoding[8], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 656:UCVTF
    34'b01000111111?111?11????010100?0???? : t32_to_a64 = {9'b010111101, t32_encoding[18], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 657:FRECPE
    34'b01000111111?111?11????010110?0???? : t32_to_a64 = {9'b011111101, t32_encoding[18], 12'b100001110110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 658:FRSQRTE
    34'b11000111111?111?11????011100?0???? : t32_to_a64 = {9'b010111101, t32_encoding[18], 12'b100001111110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 659:FRECPX
    34'b00000?11111?001???????0???0??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 10'b0111100001, t32_encoding[18:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 664:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b00000?11111?01????????0???0??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 9'b011110001, t32_encoding[19:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 665:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b00000?11111?1?????????0???0??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 8'b01111001, t32_encoding[20:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 666:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b00000?11111???????????0???1??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 7'b0111101, t32_encoding[21:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 667:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b00?00?11111?001???????10??0??1???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 10'b0111100001, t32_encoding[18:16], 2'b10, t32_encoding[9:8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 668:SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL
    34'b00?00?11111?01????????10??0??1???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 9'b011110001, t32_encoding[19:16], 2'b10, t32_encoding[9:8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 669:SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL
    34'b00?00?11111?1?????????10??0??1???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 8'b01111001, t32_encoding[20:16], 2'b10, t32_encoding[9:8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 670:SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN; {S|U}SHLL
    34'b00000?11111?1?????????11100??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 8'b01111001, t32_encoding[20:16], 6'b111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 671:{S|U}CVTF
    34'b00000?11111???????????11101??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 7'b0111101, t32_encoding[21:16], 6'b111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 672:{S|U}CVTF
    34'b00000?11111?1?????????11110??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 8'b01111001, t32_encoding[20:16], 6'b111111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 673:FCVTZ{S|U}
    34'b00000?11111???????????11111??1???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 7'b0111101, t32_encoding[21:16], 6'b111111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 674:FCVTZ{S|U}
    34'b01000?11111?001???????0???00?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 10'b1111100001, t32_encoding[18:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 678:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b01000?11111?01????????0???00?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 9'b111110001, t32_encoding[19:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 679:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b01000?11111?1?????????0???00?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 8'b11111001, t32_encoding[20:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 680:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b01000?11111???????????0???10?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 7'b1111101, t32_encoding[21:16], 1'b0, t32_encoding[10:8], 2'b01, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 681:{|S|U}SHR; {S|U}SRA; {S|U}RSHR; {S|U}RSRA; SRI; SHL; SLI; SQSHLU; {S|U}QSHL
    34'b01000?11111?001???????100?0??1???? : t32_to_a64 = {2'b01, t32_encoding[28], 10'b1111100001, t32_encoding[18:16], 3'b100, t32_encoding[8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 682:SQSHRUN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN
    34'b01000?11111?01????????100?0??1???? : t32_to_a64 = {2'b01, t32_encoding[28], 9'b111110001, t32_encoding[19:16], 3'b100, t32_encoding[8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 683:SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN
    34'b01000?11111?1?????????100?0??1???? : t32_to_a64 = {2'b01, t32_encoding[28], 8'b11111001, t32_encoding[20:16], 3'b100, t32_encoding[8], t32_encoding[6], 1'b1, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 684:SHRN; SQSHRUN; RSHRN; SQRSHRUN; {S|U}QSHRN; {S|U}QRSHRN
    34'b01000?11111?1?????????111000?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 8'b11111001, t32_encoding[20:16], 6'b111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 685:{S|U}CVTF
    34'b01000?11111???????????111010?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 7'b1111101, t32_encoding[21:16], 6'b111001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 686:{S|U}CVTF
    34'b01000?11111?1?????????111100?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 8'b11111001, t32_encoding[20:16], 6'b111111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 687:FCVTZ{S|U}
    34'b01000?11111???????????111110?1???? : t32_to_a64 = {2'b01, t32_encoding[28], 7'b1111101, t32_encoding[21:16], 6'b111111, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 688:FCVTZ{S|U}
    34'b00000?11111?000???????0??00?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 1'b0, t32_encoding[10:9], 3'b001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 692:MOVI (sl)
    34'b00000?11111?000???????0??10?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 1'b0, t32_encoding[10:9], 3'b101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 693:ORR (sl)
    34'b00000?11111?000???????10?00?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 2'b10, t32_encoding[9], 3'b001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 694:MOVI (hl)
    34'b00000?11111?000???????10?10?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 2'b10, t32_encoding[9], 3'b101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 695:ORR (hl)
    34'b00000?11111?000???????110?0?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 3'b110, t32_encoding[8], 2'b01, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 696:MOVI (sm)
    34'b00000?11111?000???????11100?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 6'b111001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 697:MOVI (b)
    34'b00000?11111?000???????0??00?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 1'b0, t32_encoding[10:9], 3'b001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 698:MVNI (sl)
    34'b00000?11111?000???????0??10?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 1'b0, t32_encoding[10:9], 3'b101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 699:BIC (sl)
    34'b00000?11111?000???????10?00?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 2'b10, t32_encoding[9], 3'b001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 700:MVNI (hl)
    34'b00000?11111?000???????10?10?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 2'b10, t32_encoding[9], 3'b101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 701:BIC (hl)
    34'b00000?11111?000???????110?0?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 3'b110, t32_encoding[8], 2'b01, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 702:MVNI (sm)
    34'b00000?11111?000???????11100?11???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b10111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 6'b111001, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 703:MOVI (d)
    34'b00000?11111?000???????11110?01???? : t32_to_a64 = {1'b0, t32_encoding[6], 11'b00111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 6'b111101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 704:FMOV (s)
    34'b00000?11111?000???????11110111???? : t32_to_a64 = {13'b0110111100000, t32_encoding[28], t32_encoding[18], t32_encoding[17], 6'b111101, t32_encoding[16], t32_encoding[3], t32_encoding[2], t32_encoding[1], t32_encoding[0], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 705:FMOV (d)
    34'b000???11111?01????????0000?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0000, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 709:MLA
    34'b000???11111?10????????0000?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0000, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 710:MLA
    34'b000???11111?10????????0001?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 711:FMLA
    34'b000???11111?00????????0001?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 712:FMLA
    34'b00????11111?01????????0010?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0010, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 713:{S|U}MLAL
    34'b00????11111?10????????0010?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0010, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 714:{S|U}MLAL
    34'b00???011111?01????????0011?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 715:SQDMLAL
    34'b00???011111?10????????0011?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 716:SQDMLAL
    34'b000???11111?01????????0100?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 717:MLS
    34'b000???11111?10????????0100?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 718:MLS
    34'b000???11111?10????????0101?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 719:FMLS
    34'b000???11111?00????????0101?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 720:FMLS
    34'b00????11111?01????????0110?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0110, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 721:{S|U}MLSL
    34'b00????11111?10????????0110?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0110, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 722:{S|U}MLSL
    34'b00???011111?01????????0111?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0111, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 723:SQDMLSL
    34'b00???011111?10????????0111?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0111, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 724:SQDMLSL
    34'b000???11111?01????????1000?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1000, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 725:MUL
    34'b000???11111?10????????1000?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1000, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 726:MUL
    34'b000???11111?10????????1001?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 727:FMUL
    34'b000???11111?00????????1001?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 728:FMUL
    34'b000???11111?10????????1110?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 729:FMULX
    34'b000???11111?00????????1110?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b10111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 730:FMULX
    34'b00????11111?01????????1010?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1010, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 731:{S|U}MULL
    34'b00????11111?10????????1010?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], t32_encoding[28], 7'b0111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1010, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 732:{S|U}MULL
    34'b00???011111?01????????1011?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 733:SQDMULL
    34'b00???011111?10????????1011?1?0???? : t32_to_a64 = {1'b0, t32_encoding[31], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 734:SQDMULL
    34'b000???11111?01????????1100?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 735:SQDMULH
    34'b000???11111?10????????1100?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 736:SQDMULH
    34'b000???11111?01????????1101?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 737:SQRDMULH
    34'b000???11111?10????????1101?1?0???? : t32_to_a64 = {1'b0, t32_encoding[28], 8'b00111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 738:SQRDMULH
    34'b010??011111?10????????0001?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 742:FMLA
    34'b010??011111?00????????0001?1?0???? : t32_to_a64 = {10'b0101111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 743:FMLA
    34'b010??011111?01????????0011?1?0???? : t32_to_a64 = {10'b0101111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 744:SQDMLAL
    34'b010??011111?10????????0011?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 745:SQDMLAL
    34'b010??011111?10????????0101?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 746:FMLS
    34'b010??011111?00????????0101?1?0???? : t32_to_a64 = {10'b0101111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 747:FMLS
    34'b010??011111?01????????0111?1?0???? : t32_to_a64 = {10'b0101111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0111, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 748:SQDMLSL
    34'b010??011111?10????????0111?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b0111, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 749:SQDMLSL
    34'b010??011111?10????????1001?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 750:FMUL
    34'b010??011111?00????????1001?1?0???? : t32_to_a64 = {10'b0101111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 751:FMUL
    34'b010??011111?10????????1110?1?0???? : t32_to_a64 = {10'b0111111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 752:FMULX
    34'b010??011111?00????????1110?1?0???? : t32_to_a64 = {10'b0111111111, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1001, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 753:FMULX
    34'b010??011111?01????????1011?1?0???? : t32_to_a64 = {10'b0101111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 754:SQDMULL
    34'b010??011111?10????????1011?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1011, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 755:SQDMULL
    34'b010??011111?01????????1100?1?0???? : t32_to_a64 = {10'b0101111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 756:SQDMULH
    34'b010??011111?10????????1100?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1100, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 757:SQDMULH
    34'b010??011111?01????????1101?1?0???? : t32_to_a64 = {10'b0101111101, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 758:SQRDMULH
    34'b010??011111?10????????1101?1?0???? : t32_to_a64 = {10'b0101111110, t32_encoding[29], t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 4'b1101, t32_encoding[30], 1'b0, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 759:SQRDMULH
    34'b10000?11111?11??1?????????0??0???? : t32_to_a64 = {1'b0, t32_encoding[6], t32_encoding[28], 5'b01110, t32_encoding[19:18], 5'b11000, t32_encoding[16], t32_encoding[11:8], 2'b10, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 762:Accross all elements
    34'b010?0111111?11????????110000?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[30], t32_encoding[19:16], 6'b000001, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 765:Copy (Scalar)
    34'b11000?11111?11??1?????????00?0???? : t32_to_a64 = {2'b01, t32_encoding[28], 5'b11110, t32_encoding[19:18], 5'b11000, t32_encoding[16], t32_encoding[11:8], 2'b10, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 768:Pairwise
    34'b00000111111?110000????001100?0???? : t32_to_a64 = {22'b0100111000101000010010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 772:AESE
    34'b00000111111?110000????001101?0???? : t32_to_a64 = {22'b0100111000101000010110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 773:AESD
    34'b00000111111?110000????001110?0???? : t32_to_a64 = {22'b0100111000101000011010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 774:AESMC
    34'b00000111111?110000????001111?0???? : t32_to_a64 = {22'b0100111000101000011110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 775:AESIMC
    34'b00000011110?00????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 779:SHA1C
    34'b00000011110?01????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b000100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 780:SHA1P
    34'b00000011110?10????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 781:SHA1M
    34'b00000011110?11????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b001100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 782:SHA1SU0
    34'b00000111110?00????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 783:SHA256H
    34'b00000111110?01????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b010100, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 784:SHA256H2
    34'b00000111110?10????????1100?1?0???? : t32_to_a64 = {11'b01011110000, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], 6'b011000, t32_encoding[16], t32_encoding[7], t32_encoding[19:17], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 785:SHA256SU1
    34'b00000111111?111001????001011?0???? : t32_to_a64 = {22'b0101111000101000000010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 789:SHA1H
    34'b00000111111?111010????001110?0???? : t32_to_a64 = {22'b0101111000101000000110, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 790:SHA1SU1
    34'b00000111111?111010????001111?0???? : t32_to_a64 = {22'b0101111000101000001010, t32_encoding[0], t32_encoding[5], t32_encoding[3:1], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 791:SHA256SU0
    34'b0?0?0110010??0??????????????001111 : t32_to_a64 = {1'b0, t32_encoding[32], 7'b0011000, t32_encoding[21], 6'b000000, t32_encoding[11:8], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 795:Load/store multiple (elem)
    34'b0???1110010??0??????????????00???? : t32_to_a64 = {1'b0, t32_encoding[32], 7'b0011001, t32_encoding[21], 1'b0, t32_encoding[31], t32_encoding[3:0], t32_encoding[11:8], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 796:load/store (elem-post)
    34'b0?0?0110011??0???????????????01111 : t32_to_a64 = {1'b0, t32_encoding[32], 7'b0011010, t32_encoding[21], t32_encoding[8], 5'b00000, t32_encoding[11:9], t32_encoding[5], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 797:load/store (one)
    34'b0???1110011??0???????????????0???? : t32_to_a64 = {1'b0, t32_encoding[32], 7'b0011011, t32_encoding[21], t32_encoding[8], t32_encoding[31], t32_encoding[3:0], t32_encoding[11:9], t32_encoding[5], t32_encoding[7:6], t32_encoding[30], t32_encoding[19:16], t32_encoding[12], t32_encoding[22], t32_encoding[15:13]}; // 798:load/store (one-post)

    default : begin
      // while the DPU could fall in here via the tracer it should never happen while the IFU is used
      `ifdef IFU_TB
        string error; $swrite(error,"%6dns : illegal t32_to_a64() encoding found : 0x%09h",$time, t32_encoding);
        `tb_fatal(ifu_tb_message_logger, error);
      `endif
       t32_to_a64 = 0;
    end
  endcase
end
endfunction
