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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : Block for remapping memory type attributes
//-----------------------------------------------------------------------------
//
`include "ca53tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_tlb_rams_defs.v"
`include "cortexa53params.v"

module ca53tlb_remap
 (
  input  wire        pagewalk_lpae_i,
  input  wire        pagewalk_ns_i,
  input  wire        pagewalk_exception_level0_i,
  input  wire        pagewalk_exception_level1_i,
  input  wire        pagewalk_aarch64_at_el3_i,
  input  wire        dpu_tex_remap_enable_el1_i,
  input  wire        dpu_tex_remap_enable_el3_i,
  input  wire [31:0] mair0_i,
  input  wire [31:0] mair1_i,
  input  wire [5:0]  tex_c_b_s_i,
  input  wire [4:0]  attrindx_sh_i,

  input  wire [7:0]  stage1_memattrs_i,
  input  wire [3:0]  stage2_memattrs_i,
  input  wire [1:0]  stage2_sh_i,

  output wire [7:0]  remapped_attrs_o,
  output wire [7:0]  combined_attrs_o);

  //----------------------------------------------------------------------------
  // Wire declarations
  //----------------------------------------------------------------------------

  reg  [7:0]  default_attrs_vmsa_0;
  wire [7:0]  default_attrs_vmsa_1;
  wire [7:0]  default_attrs_vmsa;
  wire [7:0]  tex_remapped_attrs_vmsa;
  wire        tex_remapped_shareable;
  reg  [6:0]  prrr_nmrr_bits;
  reg  [7:0]  mair_bits;
  wire [7:0]  remapped_attrs_lpae;
  wire [2:0]  stage1_inner_type;
  reg  [2:0]  stage2_inner_type;
  wire [5:0]  stage1_outer_type;
  reg  [5:0]  stage2_outer_type;
  reg  [1:0]  stage1_sh_type;
  reg  [1:0]  stage2_sh_type;
  wire        force_outer_sh;
  wire [2:0]  combined_inner_type;
  wire [5:0]  combined_outer_type;
  wire [1:0]  combined_sh_type;
  wire        dev_so_override;

  wire       default_vmsa_1_coherent;
  wire [1:0] default_vmsa_1_inner_alloc_hint;
  wire [1:0] default_vmsa_1_outer_alloc_hint;
  wire       vmsa_coherent;
  wire [1:0] vmsa_inner_alloc_hint;
  wire [1:0] vmsa_outer_alloc_hint;
  wire       mair_coherent;
  wire [1:0] mair_inner_attrs;
  wire       dpu_tex_remap_enable;
  wire [1:0] combined_dev_type;
  wire       combined_coherent;
  wire [1:0] combined_inner_attrs;

  //----------------------------------------------------------------------------
  // Stage1 VMSA
  //----------------------------------------------------------------------------

  // Calculate the attributes assuming TEX remapping is disabled and TEX[2] is low

  always @*
    case (tex_c_b_s_i[4:0])
      5'b00_0_0_0,
      5'b00_0_0_1: default_attrs_vmsa_0 = `CA53_PAGE_DEV_STAGE1_NGNRNE_SHARE_OS;
      5'b00_0_1_0,
      5'b00_0_1_1: default_attrs_vmsa_0 = `CA53_PAGE_DEV_STAGE1_NGNRE_SHARE_OS;
      5'b00_1_0_0: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WT_OUTER_WT_SHARE_NS;
      5'b00_1_0_1: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WT_OUTER_WT_SHARE_OS;
      5'b00_1_1_0: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_NS;
      5'b00_1_1_1: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WBRA_OUTER_WBRA_SHARE_OS;
      5'b01_0_0_0,
      5'b01_0_0_1,
      5'b01_0_1_0,
      5'b01_0_1_1: default_attrs_vmsa_0 = `CA53_PAGE_INNER_NC_OUTER_NC_SHARE_OS;
      5'b01_1_0_0,
      5'b01_1_1_0: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_NS;
      5'b01_1_0_1,
      5'b01_1_1_1: default_attrs_vmsa_0 = `CA53_PAGE_INNER_WBRWA_OUTER_WBRWA_SHARE_OS;
      5'b10_0_0_0,
      5'b10_0_0_1,
      5'b10_0_1_0,
      5'b10_0_1_1,
      5'b10_1_0_0,
      5'b10_1_0_1,
      5'b10_1_1_0,
      5'b10_1_1_1,
      5'b11_0_0_0,
      5'b11_0_0_1,
      5'b11_0_1_0,
      5'b11_0_1_1,
      5'b11_1_0_0,
      5'b11_1_0_1,
      5'b11_1_1_0,
      5'b11_1_1_1: default_attrs_vmsa_0 = `CA53_PAGE_DEV_STAGE1_NGNRE_SHARE_OS;
      default:     default_attrs_vmsa_0 =  8'hxx;
    endcase

  // Calculate the attributes assuming remapping is disabled and TEX[2] is high
  // Map out UNPREDICTABLE encoding. If both the outer and inner type is NC
  // then it is forced to be outer shareable. Anything outer shareable but not
  // inner shareable is forced to be non-shareable.

  //tex_c_b_s_i [4:3]  [2:1]  [0]
  //            outer, inner, sharable

  // Coherent if both inner and outer WB
  assign default_vmsa_1_coherent = tex_c_b_s_i[3] & tex_c_b_s_i[1];

  assign default_attrs_vmsa_1[7:6] = (default_vmsa_1_coherent ? 2'b10 :   // Coherent
                                      (tex_c_b_s_i[3]  ? 2'b00 : 2'b01)); // Non-coherent

  assign default_vmsa_1_inner_alloc_hint = tex_c_b_s_i[2] ? 2'b10 : 2'b11;
  assign default_vmsa_1_outer_alloc_hint = tex_c_b_s_i[4] ? 2'b10 : 2'b11;

  assign default_attrs_vmsa_1[5:4] = (default_vmsa_1_coherent ? default_vmsa_1_inner_alloc_hint :
                                      ~|tex_c_b_s_i[4:3] ? 2'b11 :                     // Outer NC
                                      tex_c_b_s_i[3]     ? {1'b1, tex_c_b_s_i[2]} :    // Outer WB
                                      (&tex_c_b_s_i[2:1] ? 2'b01 : tex_c_b_s_i[2:1])); // Outer WT

  assign default_attrs_vmsa_1[3:2] = (|tex_c_b_s_i[4:3] ? default_vmsa_1_outer_alloc_hint : // Outer WB or WT
                                      (tex_c_b_s_i[1] ? 2'b01 : tex_c_b_s_i[2:1]));         // Outer NC

  assign default_attrs_vmsa_1[1:0] = ((tex_c_b_s_i[4:1] == 4'b0000) | (tex_c_b_s_i[0])) ? 2'b10 : 2'b00;

  // Combine the two to get the default mapping when TEX remap is disabled.
  assign default_attrs_vmsa = tex_c_b_s_i[5] ? default_attrs_vmsa_1 : default_attrs_vmsa_0;

  // Calculate the attributes assuming TEX remapping is enabled.
  //
  always @*
   case (tex_c_b_s_i[3:1]) // i.e. {Tex[0],C,B}
                              // Mem type        Outer share  Inner cache     Outer cache
                              // PRRR[1:0]       PRRR[24]     NMRR[1:0]       NMRR[17:16]
     3'b000:  prrr_nmrr_bits = {mair0_i[1:0],   mair0_i[24], mair1_i[1:0],   mair1_i[17:16]};
     3'b001:  prrr_nmrr_bits = {mair0_i[3:2],   mair0_i[25], mair1_i[3:2],   mair1_i[19:18]};
     3'b010:  prrr_nmrr_bits = {mair0_i[5:4],   mair0_i[26], mair1_i[5:4],   mair1_i[21:20]};
     3'b011:  prrr_nmrr_bits = {mair0_i[7:6],   mair0_i[27], mair1_i[7:6],   mair1_i[23:22]};
     3'b100:  prrr_nmrr_bits = {mair0_i[9:8],   mair0_i[28], mair1_i[9:8],   mair1_i[25:24]};
     3'b101:  prrr_nmrr_bits = {mair0_i[11:10], mair0_i[29], mair1_i[11:10], mair1_i[27:26]};
     3'b110:  prrr_nmrr_bits = {mair0_i[13:12], mair0_i[30], mair1_i[13:12], mair1_i[29:28]};
     3'b111:  prrr_nmrr_bits = {mair0_i[15:14], mair0_i[31], mair1_i[15:14], mair1_i[31:30]};
     default: prrr_nmrr_bits = 7'bxxxxxxx;
   endcase

  assign tex_remapped_shareable = tex_c_b_s_i[0] ? mair0_i[19] : mair0_i[18];


  // prrr_nmrr_bits[6:5],             [4],             [3:2]        [1:0]
  //               Mem type,          outer shareable, inner cache, outer cache
  //               00 SO                               00 NC        00 NC
  //               01 Dev                              01 WBWA      01 WBWA
  //               10 Normal                           10 WTnWA     10 WTnWA
  //               11 unpredictable                    11 WBnWA     11 WBnWA


  // Coherent if inner WB and outer WB
  assign vmsa_coherent = prrr_nmrr_bits[6] & prrr_nmrr_bits[2] & prrr_nmrr_bits[0];

  assign tex_remapped_attrs_vmsa[7:6] = (vmsa_coherent      ? 2'b10 :  // Coherent
                                         ~prrr_nmrr_bits[6] ? 2'b00 :  // Device
                                         (prrr_nmrr_bits[0] ? 2'b00 :  // Non-coherent, outer WB
                                                              2'b01)); // Non-coherent, outer WT or NC

  assign vmsa_inner_alloc_hint = prrr_nmrr_bits[3] ? 2'b10 : 2'b11;
  assign vmsa_outer_alloc_hint = prrr_nmrr_bits[1] ? 2'b10 : 2'b11;

  assign tex_remapped_attrs_vmsa[5:4] = (vmsa_coherent         ? vmsa_inner_alloc_hint :
                                         ~prrr_nmrr_bits[6]    ? 2'b00 :                        // Device
                                         ~|prrr_nmrr_bits[1:0] ? 2'b11 :                        // Outer NC
                                         prrr_nmrr_bits[0]     ? {1'b1, prrr_nmrr_bits[3]} :    // Outer WB
                                         (&prrr_nmrr_bits[3:2] ? 2'b01 : prrr_nmrr_bits[3:2])); // Outer WT

  assign tex_remapped_attrs_vmsa[3:2] = (~prrr_nmrr_bits[6]     ? prrr_nmrr_bits[6:5] :          // Device
                                         (|prrr_nmrr_bits[1:0]) ? vmsa_outer_alloc_hint :        // Outer WB or WT
                                         (&prrr_nmrr_bits[3:2]  ? 2'b01 : prrr_nmrr_bits[3:2])); // Outer NC

  // For Device and for inner non-cacheable with outer non-cacheable case, shareability is 
  // forced to outer shareable. For all other cases, shareability is given
  // by shareability field, except for unpredictable value which is also treated
  // as outer shareable
  assign tex_remapped_attrs_vmsa[1:0] = ((~prrr_nmrr_bits[6] |
                                          (prrr_nmrr_bits[3:0] == 4'b0000)) ? 2'b10 :
                                         {tex_remapped_shareable, (tex_remapped_shareable & prrr_nmrr_bits[4])});

  //----------------------------------------------------------------------------
  // Stage1 LPAE
  //----------------------------------------------------------------------------

  always @*
  case (attrindx_sh_i[4:2])
    3'b000:  mair_bits = mair0_i[7:0];
    3'b001:  mair_bits = mair0_i[15:8];
    3'b010:  mair_bits = mair0_i[23:16];
    3'b011:  mair_bits = mair0_i[31:24];
    3'b100:  mair_bits = mair1_i[7:0];
    3'b101:  mair_bits = mair1_i[15:8];
    3'b110:  mair_bits = mair1_i[23:16];
    3'b111:  mair_bits = mair1_i[31:24];
    default: mair_bits = 8'hxx;
  endcase

  // Inner and outer WB
  assign mair_coherent = (mair_bits[6] & (mair_bits[7] | (|mair_bits[5:4])) &
                          mair_bits[2] & (mair_bits[3] | (|mair_bits[1:0])));

  // Inner attrs if outer is NC or WT
  assign mair_inner_attrs = (mair_bits[3:0] == 4'b0100) ? 2'b00 : // NC
                            (~mair_bits[2])             ? 2'b10 : // WT
                                                          2'b01;  // WB


  assign remapped_attrs_lpae[7:6] = (mair_bits[7:4] == 4'b0000) ? 2'b00 : // Device
                                    mair_coherent               ? {1'b1, ~mair_bits[3]} : // Coherent
                                    (~mair_bits[6] |
                                     (~mair_bits[7] &
                                      ~|mair_bits[5:4]))        ? 2'b01 : // Outer NC or WT
                                                                  2'b00;  // Outer WB, non-coherent


  assign remapped_attrs_lpae[5:4]  = (mair_bits[7:4] == 4'b0000) ? 2'b00 :                      // Device
                                     mair_coherent               ? mair_bits[1:0] :             // Coherent - inner alloc hints
                                     (mair_bits[7:4] == 4'b0100) ? 2'b11 :                      // Outer NC
                                     (~mair_bits[6])             ? mair_inner_attrs :           // Outer WT
                                                                   {1'b1, mair_inner_attrs[1]}; // Outer WB, non-coherent

  assign remapped_attrs_lpae[3:2]  = (mair_bits[7:4] == 4'b0000) ? mair_bits[3:2] :   // Device type
                                     (mair_bits[7:4] == 4'b0100) ? mair_inner_attrs : // Outer NC - inner attrs
                                                                   mair_bits[5:4];    // Outer WB, WT - Outer alloc hint

  // For device memory and inner-NC+outer-NC, it should be outer shareable
  // For all other memory types, shareability comes from descriptor
  // Unpredictable shareability from descriptor is treats as NC
  assign remapped_attrs_lpae[1:0]  = ((mair_bits[7:4] == 4'b0000) |                                // device
                                      ((mair_bits[7:4] == 4'b0100) & (mair_bits[3:0] == 4'b0100))) // inner-NC + outer-NC
                                      ? 2'b10 : {attrindx_sh_i[1], &attrindx_sh_i[1:0]};

 //----------------------------------------------------------------------------
 // Output stage1 attributes
 //----------------------------------------------------------------------------

 // Select the correct LPAE or VMSA mapping.
 assign dpu_tex_remap_enable = ((pagewalk_exception_level0_i & pagewalk_ns_i) |
                                (pagewalk_exception_level0_i & ~pagewalk_ns_i & pagewalk_aarch64_at_el3_i) |
                                (pagewalk_exception_level1_i)) ? dpu_tex_remap_enable_el1_i :
                               dpu_tex_remap_enable_el3_i;

 assign remapped_attrs_o = pagewalk_lpae_i      ? remapped_attrs_lpae :
                           dpu_tex_remap_enable ? tex_remapped_attrs_vmsa :
                                                  default_attrs_vmsa;

 //----------------------------------------------------------------------------
 // Combination of Stage 1 and 2 attributes
 //   S1 inner, outer, shareability attributes have to be combined with S2
 //   attributes. As S2 doesn't have allocation hint, so S1 allocation hint
 //   is not combined with any other allocation hint.
 //----------------------------------------------------------------------------

 // Expand the inner attributes into a zero-onehot type
 //   3'b100 represents DEV
 //   3'b010 represents NC
 //   3'b001 represents WT
 //   3'b000 represents WB
 assign stage1_inner_type = {`CA53_MEM_DEVICE(stage1_memattrs_i),
                             `CA53_MEM_NC(stage1_memattrs_i),
                             `CA53_MEM_WT(stage1_memattrs_i)};

 always @*
  case ({|stage2_memattrs_i[3:2], stage2_memattrs_i[1:0]})
    3'b0_00,
    3'b0_01,
    3'b0_10,
    3'b0_11: stage2_inner_type = 3'b100; // Dev
    3'b1_00,
    3'b1_01: stage2_inner_type = 3'b010; // NC, Unpredictable also treated as NC
    3'b1_10: stage2_inner_type = 3'b001; // WT
    3'b1_11: stage2_inner_type = 3'b000; // WB
    default: stage2_inner_type = 3'bxxx;
  endcase

 // Expand the outer attributes into a zero-onehot type
 // {DEV_NGNRNE,DEV_NGNRE,DEV_NGRE,DEV_GRE,NC,WT}
 assign stage1_outer_type = {`CA53_MEM_nGnRnE(stage1_memattrs_i),
                             `CA53_MEM_nGnRE(stage1_memattrs_i),
                             `CA53_MEM_nGRE(stage1_memattrs_i),
                             `CA53_MEM_GRE(stage1_memattrs_i),
                             `CA53_MEM_OUTER_NC(stage1_memattrs_i),
                             `CA53_MEM_OUTER_WT(stage1_memattrs_i)};
 always @*
  case ({stage2_memattrs_i[3:2], stage2_memattrs_i[1:0]})
    4'b00_00: stage2_outer_type = 6'b1000_00; // DEV_NGNRNE
    4'b00_01: stage2_outer_type = 6'b0100_00; // DEV_NGNRE
    4'b00_10: stage2_outer_type = 6'b0010_00; // DEV_NGRE
    4'b00_11: stage2_outer_type = 6'b0001_00; // DEV_GRE
    4'b01_00,
    4'b01_01,
    4'b01_10,
    4'b01_11: stage2_outer_type = 6'b0000_10; // NC
    4'b10_00,
    4'b10_01,
    4'b10_10,
    4'b10_11: stage2_outer_type = 6'b0000_01; // WT
    4'b11_00,
    4'b11_01,
    4'b11_10,
    4'b11_11: stage2_outer_type = 6'b0000_00; // WB
    default:  stage2_outer_type = 6'bxxxx_xx;
  endcase


  // Expand the shareability into a zero-onehot type
  // {outer, inner}
  always @*
  case (stage1_memattrs_i[1:0])
    2'b00,
    2'b01:   stage1_sh_type = 2'b00; // Non   shareable
    2'b10:   stage1_sh_type = 2'b10; // Outer shareable
    2'b11:   stage1_sh_type = 2'b01; // Inner shareable
    default: stage1_sh_type = 2'bxx;
  endcase

  always @*
  case (stage2_sh_i)
    2'b00,
    2'b01:   stage2_sh_type = 2'b00; // Non   shareable
    2'b10:   stage2_sh_type = 2'b10; // Outer shareable
    2'b11:   stage2_sh_type = 2'b01; // Inner shareable
    default: stage2_sh_type = 2'bxx;
  endcase

  // Combine the type fields by or-ing them together. The highest bit set in
  // the result indicates the combined type.
  assign combined_inner_type = stage1_inner_type | stage2_inner_type;
  assign combined_outer_type = stage1_outer_type | stage2_outer_type;

  // Force the shareability to outer shareable if the combined memory type is
  //  - any device type
  //  - inner and outer non-cacheable.
  assign force_outer_sh = (combined_inner_type[2]) |                         // inner Device/SO
                          (combined_inner_type[1] & combined_outer_type[1]); // inner NC , outer NC

  assign combined_sh_type = stage1_sh_type | stage2_sh_type | {force_outer_sh,1'b0};

  // We need to indicate if the resultant type is device or strongly ordered
  // when the stage1 type was normal memory. This is necessary so that when
  // calculating alignment faults the DCU will know whether the fault
  // should be a stage1 or stage2 fault.
  assign dev_so_override = stage2_inner_type[2] & ~stage1_inner_type[2];


  // Re-encode the combined type into the standard internal attributes format.

  // qualify this signal with memory type device
  assign combined_dev_type = combined_outer_type[5] ? 2'b00 : // nGnRnE
                             combined_outer_type[4] ? 2'b01 : // nGnRE
                             combined_outer_type[3] ? 2'b10 : // nGRE
                                                      2'b11 ; // GRE

  assign combined_inner_attrs =  combined_inner_type[1] ? 2'b00 : // inner NC
                                 combined_inner_type[0] ? 2'b10 : // inner WT
                                                          2'b01 ; // inner WB

  assign combined_coherent = ~|combined_inner_type & ~|combined_outer_type[1:0];

  assign combined_attrs_o[7:6] = combined_coherent ? stage1_memattrs_i[7:6] :
                                 (combined_inner_type[2])                          ? 2'b00 : // dev
                                 (combined_outer_type[1] | combined_outer_type[0]) ? 2'b01 : // non-coh NC/WT
                                 2'b00; // Outer WB

  assign combined_attrs_o[5:4] = combined_coherent ? stage1_memattrs_i[5:4] :
                                 (combined_inner_type[2]) ? {1'b0, dev_so_override} :
                                 (combined_outer_type[1]) ? 2'b11:                  // Outer NC
                                 (combined_outer_type[0]) ? combined_inner_attrs :  // Outer WT
                                                            {1'b1, combined_inner_attrs[1]}; // Outer WB, non-coherent

  assign combined_attrs_o[3:2] = (combined_inner_type[2]) ? combined_dev_type :
                                 (combined_outer_type[1]) ? combined_inner_attrs :
                                                            stage1_memattrs_i[3:2];

  assign combined_attrs_o[1:0] = (combined_sh_type[1]) ? 2'b10 : // outer shareable
                                 (combined_sh_type[0]) ? 2'b11 : // inner shareable
                                                         2'b00 ; // non shareable

endmodule // ca53tlb_remap

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53_tlb_rams_defs.v"
`include "ca53_ifu_tlb_defs.v"
`include "ca53_dpu_tlb_defs.v"
`include "ca53_dcu_tlb_defs.v"
`include "ca53_biu_tlb_defs.v"
`include "ca53tlb_defs.v"
`undef CA53_UNDEFINE
/*END*/
