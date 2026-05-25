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
// Abstract : BIU DVM encoder
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// The DVM encoder takes coherency requests from the STB and outputs the
// corresponding DVM message if applicable.

`include "cortexa53params.v"
`include "ca53_ace_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53biu_defs.v"

module ca53biu_dvm_enc
    (
     //------------------------------------------------------------------------------
     // STB Interface
     //------------------------------------------------------------------------------

     input  wire [7:0]        stb_ar_type_i,
     input  wire [15:0]       stb_ar_asid_i,
     input  wire [7:0]        stb_ar_vmid_i,
     input  wire [48:0]       stb_ar_va_i,
     input  wire [39:0]       stb_ar_addr_i,
     input  wire [7:0]        stb_ar_attrs_i,
     input  wire              stb_ar_ns_dsc_i,
     input  wire              stb_ar_ns_scr_i,
     output wire [40:0]       dvm_msg_1_o,
     output wire [40:0]       dvm_msg_2_o
     );

  //------------------------------------------------------------------------------
  // Wires
  //------------------------------------------------------------------------------

  wire      dvm_aarch64_tlb_cpop;
  wire      dvm_ns_tlb_cpop;

  //------------------------------------------------------------------------------
  // Registers
  //------------------------------------------------------------------------------

  reg       dvm_address_follows;
  reg       dvm_apply_to_guest_os;
  reg       dvm_apply_to_hypervisor;
  reg       dvm_apply_to_non_secure;
  reg       dvm_apply_to_secure;
  reg       dvm_apply_to_leaf;
  reg [1:0] dvm_apply_to_stage;
  reg       dvm_apply_to_el3;
  reg       dvm_asid_specified;
  reg [2:0] dvm_msg_type;
  reg       dvm_vindex_specified;
  reg       dvm_vmid_specified;

  //------------------------------------------------------------------------------
  // Compute the secure status of the TLB CP_OPs:
  // - scr_el3.ns in AArch64
  // - ns_state in AArch32
  //------------------------------------------------------------------------------

  assign dvm_aarch64_tlb_cpop = stb_ar_type_i[5];

  assign dvm_ns_tlb_cpop      = dvm_aarch64_tlb_cpop ? stb_ar_ns_scr_i : stb_ar_ns_dsc_i;

  //------------------------------------------------------------------------------
  // DVM message generation
  //------------------------------------------------------------------------------

  always @*
    case (stb_ar_type_i)
      `CA53_CPOP_8_TLBIVAE1,
      `CA53_CPOP_8_TLBIVAE1IS,
      `CA53_CPOP_8_TLBIMVA,
      `CA53_CPOP_8_TLBIMVAIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b1;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVALE1,
      `CA53_CPOP_8_TLBIVALE1IS,
      `CA53_CPOP_8_TLBIMVAL,
      `CA53_CPOP_8_TLBIMVALIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b1;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b1;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVAAE1,
      `CA53_CPOP_8_TLBIVAAE1IS,
      `CA53_CPOP_8_TLBIMVAA,
      `CA53_CPOP_8_TLBIMVAAIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVAALE1,
      `CA53_CPOP_8_TLBIVAALE1IS,
      `CA53_CPOP_8_TLBIMVAAL,
      `CA53_CPOP_8_TLBIMVAALIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b1;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIASIDE1,
      `CA53_CPOP_8_TLBIASIDE1IS,
      `CA53_CPOP_8_TLBIASID,
      `CA53_CPOP_8_TLBIASIDIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b1;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVMALLE1,
      `CA53_CPOP_8_TLBIVMALLE1IS,
      `CA53_CPOP_8_TLBIALL,
      `CA53_CPOP_8_TLBIALLIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = {1'b0, dvm_aarch64_tlb_cpop & dvm_ns_tlb_cpop};
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVMALLS12E1,
      `CA53_CPOP_8_TLBIVMALLS12E1IS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~dvm_ns_tlb_cpop;
        dvm_apply_to_non_secure = dvm_ns_tlb_cpop;
        dvm_vmid_specified      = dvm_ns_tlb_cpop;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIALLE1,
      `CA53_CPOP_8_TLBIALLE1IS,
      `CA53_CPOP_8_TLBIALLNSNH,
      `CA53_CPOP_8_TLBIALLNSNHIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     =  dvm_aarch64_tlb_cpop & ~stb_ar_ns_scr_i;
        dvm_apply_to_non_secure = ~dvm_aarch64_tlb_cpop |  stb_ar_ns_scr_i;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIIPAS2E1,
      `CA53_CPOP_8_TLBIIPAS2E1IS,
      `CA53_CPOP_8_TLBIIPAS2,
      `CA53_CPOP_8_TLBIIPAS2IS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = 1'b0;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b1;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b10;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIIPAS2LE1,
      `CA53_CPOP_8_TLBIIPAS2LE1IS,
      `CA53_CPOP_8_TLBIIPAS2L,
      `CA53_CPOP_8_TLBIIPAS2LIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b0;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = 1'b0;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b1;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b1;
        dvm_apply_to_stage      = 2'b10;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVAE2,
      `CA53_CPOP_8_TLBIVAE2IS,
      `CA53_CPOP_8_TLBIMVAH,
      `CA53_CPOP_8_TLBIMVAHIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b0;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVALE2,
      `CA53_CPOP_8_TLBIVALE2IS,
      `CA53_CPOP_8_TLBIMVALH,
      `CA53_CPOP_8_TLBIMVALHIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b0;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b1;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIALLE2,
      `CA53_CPOP_8_TLBIALLE2IS,
      `CA53_CPOP_8_TLBIALLH,
      `CA53_CPOP_8_TLBIALLHIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b0;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_TLBIVAE3,
      `CA53_CPOP_8_TLBIVAE3IS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b0;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b1;
      end
      `CA53_CPOP_8_TLBIVALE3,
      `CA53_CPOP_8_TLBIVALE3IS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b0;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b1;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b1;
      end
      `CA53_CPOP_8_TLBIALLE3,
      `CA53_CPOP_8_TLBIALLE3IS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_TLBINVIS :
                                                                               `CA53_DVM_TLBINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b0;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b0;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b1;
      end
      `CA53_CPOP_8_ICIALLU,
      `CA53_CPOP_8_ICIALLUIS : begin
        dvm_msg_type            = `CA53_BIU_STB_IS_DVM_FOR_IS(stb_ar_type_i) ? `CA53_DVM_ICVINVIS :
                                                                               `CA53_DVM_ICINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~stb_ar_ns_dsc_i;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_ICIVAU : begin
        dvm_msg_type            = `CA53_MEM_SHAREABLE(stb_ar_attrs_i) ? `CA53_DVM_ICPINVIS :
                                                                        `CA53_DVM_ICINV;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = ~stb_ar_ns_dsc_i;
        dvm_apply_to_non_secure = stb_ar_ns_dsc_i;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b1;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_BPIALLIS : begin
        dvm_msg_type            = `CA53_DVM_BPINVIS;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_BPIMVA : begin
        dvm_msg_type            = `CA53_DVM_BPINVIS;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b1;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      `CA53_CPOP_8_SYNC : begin
        dvm_msg_type            = `CA53_DVM_SYNC;
        dvm_apply_to_hypervisor = 1'b1;
        dvm_apply_to_guest_os   = 1'b1;
        dvm_apply_to_secure     = 1'b1;
        dvm_apply_to_non_secure = 1'b1;
        dvm_vmid_specified      = 1'b0;
        dvm_asid_specified      = 1'b0;
        dvm_vindex_specified    = 1'b0;
        dvm_address_follows     = 1'b0;
        dvm_apply_to_leaf       = 1'b0;
        dvm_apply_to_stage      = 2'b00;
        dvm_apply_to_el3        = 1'b0;
      end
      default : begin
        dvm_msg_type            = 3'bxxx;
        dvm_apply_to_hypervisor = 1'bx;
        dvm_apply_to_guest_os   = 1'bx;
        dvm_apply_to_secure     = 1'bx;
        dvm_apply_to_non_secure = 1'bx;
        dvm_vmid_specified      = 1'bx;
        dvm_asid_specified      = 1'bx;
        dvm_vindex_specified    = 1'bx;
        dvm_address_follows     = 1'bx;
        dvm_apply_to_leaf       = 1'bx;
        dvm_apply_to_stage      = 2'bxx;
        dvm_apply_to_el3        = 1'bx;
      end
    endcase

  //------------------------------------------------------------------------------
  // Assign outputs
  //------------------------------------------------------------------------------

  assign dvm_msg_1_o[40]    = stb_ar_va_i[45];

  assign dvm_msg_1_o[39:32] = {8{dvm_asid_specified}} & stb_ar_asid_i[15:8];

  assign dvm_msg_1_o[31:24] = ({8{dvm_vmid_specified}}   & stb_ar_vmid_i)    |
                              ({8{dvm_vindex_specified}} & stb_ar_va_i[27:20]);

  assign dvm_msg_1_o[23:16] = ({8{dvm_asid_specified}}   & stb_ar_asid_i[7:0]) |
                              ({8{dvm_vindex_specified}} & stb_ar_va_i[19:12]  );

  assign dvm_msg_1_o[15]    = stb_ar_va_i[48];
  assign dvm_msg_1_o[14:12] = dvm_msg_type;

  assign dvm_msg_1_o[11:10] = (dvm_apply_to_el3)                                ? `CA53_BIU_DVM_EL3      :
                              (dvm_apply_to_hypervisor & dvm_apply_to_guest_os) ? `CA53_BIU_DVM_OS_BOTH  :
                              (dvm_apply_to_hypervisor)                         ? `CA53_BIU_DVM_OS_HYP   :
                                                                                  `CA53_BIU_DVM_OS_GUEST;


  assign dvm_msg_1_o[9:8]   = (dvm_apply_to_secure & dvm_apply_to_non_secure)   ? `CA53_BIU_DVM_SEC_BOTH :
                              (dvm_apply_to_secure)                             ? `CA53_BIU_DVM_SEC_SEC  :
                                                                                  `CA53_BIU_DVM_SEC_NSEC;

  assign dvm_msg_1_o[7]     = stb_ar_va_i[47];
  assign dvm_msg_1_o[6]     = dvm_vmid_specified | dvm_vindex_specified;
  assign dvm_msg_1_o[5]     = dvm_asid_specified | dvm_vindex_specified;
  assign dvm_msg_1_o[4]     = dvm_apply_to_leaf;
  assign dvm_msg_1_o[3:2]   = dvm_apply_to_stage;
  assign dvm_msg_1_o[1]     = stb_ar_va_i[46];
  assign dvm_msg_1_o[0]     = dvm_address_follows;

  assign dvm_msg_2_o[40]    = ~`CA53_BIU_STB_IS_ICINV(stb_ar_type_i) & stb_ar_va_i[41];
  assign dvm_msg_2_o[39:4]  = ~`CA53_BIU_STB_IS_ICINV(stb_ar_type_i) ? stb_ar_va_i[39:4] : stb_ar_addr_i[39:4];
  assign dvm_msg_2_o[3]     = ~`CA53_BIU_STB_IS_ICINV(stb_ar_type_i) & stb_ar_va_i[40];
  assign dvm_msg_2_o[2:0]   = {3{~`CA53_BIU_STB_IS_ICINV(stb_ar_type_i)}} & stb_ar_va_i[44:42];

endmodule // ca53biu_dvm_enc

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53biu_defs.v"
`include "ca53_stb_biu_defs.v"
`include "ca53_biu_scu_defs.v"
`include "ca53_dcu_stb_defs.v"
`include "ca53_dcu_biu_defs.v"
`include "ca53_ace_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
