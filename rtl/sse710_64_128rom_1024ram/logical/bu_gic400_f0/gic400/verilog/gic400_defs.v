//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2011-03-25 10:35:58 +0000 (Fri, 25 Mar 2011) $
//
//      Revision            : $Revision: 165874 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Functions
//-----------------------------------------------------------------------------

// Calculate the MSB for SPI inputs. When there are no SPIs, this is 0.
function integer spi_msb(input integer num_spis_local);
  spi_msb = ((num_spis_local != 0) ? (num_spis_local - 1) : 0);
endfunction

// log2 function for integers from 2 to 131072 (inclusive).  Results are rounded up.
// Returns 1 for inputs less than 2 and -1 for inputs greater than 131072.
function integer log2(input integer a);
  log2 = (((a)<=2)     ? 1  :
          ((a)<=4)     ? 2  :
          ((a)<=8)     ? 3  :
          ((a)<=16)    ? 4  :
          ((a)<=32)    ? 5  :
          ((a)<=64)    ? 6  :
          ((a)<=128)   ? 7  :
          ((a)<=256)   ? 8  :
          ((a)<=512)   ? 9  :
          ((a)<=1024)  ? 10 :
          ((a)<=2048)  ? 11 :
          ((a)<=4096)  ? 12 :
          ((a)<=8192)  ? 13 :
          ((a)<=16384) ? 14 :
          ((a)<=32768) ? 15 :
          ((a)<=65536) ? 16 :
          ((a)<=131072)? 17 :
                         -1);
endfunction

// Filter the priority to return a one-hot value corresponding to the lowest
// bit set.
function [31:0] priority_filter(input [31:0] pri);
  integer i;
  begin

    priority_filter[31:0] = 32'h00000000;

    for (i=31; i>=0; i=i-1) begin
      if (pri[i]) 
        priority_filter[31:0] = (32'h00000001 << i);
    end

  end
endfunction

// Binary encode a 32-bit signal based on the lowest bit set
// - i.e. return the binary encoding of the one hot signal which would be
// returned by priority_filter().
function [4:0] priority_encode(input [31:0] pri);
  integer i;
  begin

    priority_encode[4:0] = 5'b00000;

    for (i=31; i>=0; i=i-1) begin
      if (pri[i])
        priority_encode[4:0] = i[4:0];
    end

  end
endfunction


//-----------------------------------------------------------------------------
// AXI Transaction Defines
//-----------------------------------------------------------------------------

// Transaction size
localparam [1:0] AXI_SIZE_8      = 2'b00;   // 1-byte burst
localparam [1:0] AXI_SIZE_16     = 2'b01;   // 2-byte burst
localparam [1:0] AXI_SIZE_32     = 2'b10;   // 4-byte burst
localparam [1:0] AXI_SIZE_64     = 2'b11;   // 8-byte burst

// Burst type
localparam [1:0] AXI_BURST_FIXED = 2'b00;
localparam [1:0] AXI_BURST_INCR  = 2'b01;
localparam [1:0] AXI_BURST_WRAP  = 2'b10;

//-----------------------------------------------------------------------------
// AXI Interface Addresses
//-----------------------------------------------------------------------------

// Distributor registers                                // Offset within distributor address map:
localparam [11:2] AXI_D_CTLR        = 10'b0000_0000_00; // 0x000
localparam [11:4] AXI_D_CTLR_ID     =  8'b0000_0000;    // 0x000 - 0x00F
localparam [11:6] AXI_D_IGROUPR     =  6'b0000_10;      // 0x080 - 0x0BF
localparam [11:6] AXI_D_ISENABLER   =  6'b0001_00;      // 0x100 - 0x13F
localparam [11:6] AXI_D_ICENABLER   =  6'b0001_10;      // 0x180 - 0x1CF
localparam [11:6] AXI_D_ISPENDR     =  6'b0010_00;      // 0x200 - 0x23F
localparam [11:6] AXI_D_ICPENDR     =  6'b0010_10;      // 0x280 - 0x2CF
localparam [11:6] AXI_D_ISACTIVER   =  6'b0011_00;      // 0x300 - 0x33F
localparam [11:6] AXI_D_ICACTIVER   =  6'b0011_10;      // 0x380 - 0x3CF
localparam [11:9] AXI_D_IPRIORITYR  =  3'b010;          // 0x400 - 0x5FF
localparam [11:9] AXI_D_ITARGETSR   =  3'b100;          // 0x800 - 0x9FF
localparam [11:7] AXI_D_ICFGR       =  5'b1100_0;       // 0xC00 - 0xC7F
localparam [11:6] AXI_D_ISTATUSR    =  6'b1101_00;      // 0xD00 - 0xD3F
localparam [11:2] AXI_D_SGIR        = 10'b1111_0000_00; // 0xF00
localparam [11:4] AXI_D_CPENDSGIR   =  8'b1111_0001;    // 0xF10 - 0xF1F
localparam [11:4] AXI_D_SPENDSGIR   =  8'b1111_0010;    // 0xF20 - 0xF2F
localparam [11:6] AXI_D_PRIMECELL   =  6'b1111_11;      // 0xFC0 - 0xFFF

// CPU interface registers
localparam [14:2] AXI_C_CTLR      = 13'b010_0000_0000_00;
localparam [14:2] AXI_C_PMR       = 13'b010_0000_0000_01;
localparam [14:2] AXI_C_BPR       = 13'b010_0000_0000_10;
localparam [14:2] AXI_C_IAR       = 13'b010_0000_0000_11;
localparam [14:2] AXI_C_EOIR      = 13'b010_0000_0001_00;
localparam [14:2] AXI_C_RPR       = 13'b010_0000_0001_01;
localparam [14:2] AXI_C_HPPIR     = 13'b010_0000_0001_10;
localparam [14:2] AXI_C_ABPR      = 13'b010_0000_0001_11;
localparam [14:2] AXI_C_AIAR      = 13'b010_0000_0010_00;
localparam [14:2] AXI_C_AEOIR     = 13'b010_0000_0010_01;
localparam [14:2] AXI_C_AHPPIR    = 13'b010_0000_0010_10;
localparam [14:2] AXI_C_APR       = 13'b010_0000_1101_00;
localparam [14:2] AXI_C_NSAPR     = 13'b010_0000_1110_00;
localparam [14:2] AXI_C_IIDR      = 13'b010_0000_1111_11;
localparam [14:2] AXI_C_DIR       = 13'b011_0000_0000_00;

// VCPU interface registers

// - Hypervisor view registers
localparam [8:2] AXI_H_HCR   = 7'b0_0000_00;
localparam [8:2] AXI_H_VTR   = 7'b0_0000_01;
localparam [8:2] AXI_H_VMCR  = 7'b0_0000_10;
localparam [8:2] AXI_H_MISR  = 7'b0_0001_00;
localparam [8:2] AXI_H_EISR  = 7'b0_0010_00;
localparam [8:2] AXI_H_ELSR  = 7'b0_0011_00;
localparam [8:2] AXI_H_APR   = 7'b0_1111_00;
localparam [8:2] AXI_H_LR0   = 7'b1_0000_00;
localparam [8:2] AXI_H_LR1   = 7'b1_0000_01;
localparam [8:2] AXI_H_LR2   = 7'b1_0000_10;
localparam [8:2] AXI_H_LR3   = 7'b1_0000_11;

// - VM view registers
localparam [14:2] AXI_V_CTLR    = 13'b110_0000_0000_00;
localparam [14:2] AXI_V_PMR     = 13'b110_0000_0000_01;
localparam [14:2] AXI_V_BPR     = 13'b110_0000_0000_10;
localparam [14:2] AXI_V_IAR     = 13'b110_0000_0000_11;
localparam [14:2] AXI_V_RPR     = 13'b110_0000_0001_01;
localparam [14:2] AXI_V_HPPIR   = 13'b110_0000_0001_10;
localparam [14:2] AXI_V_ABPR    = 13'b110_0000_0001_11;
localparam [14:2] AXI_V_AIAR    = 13'b110_0000_0010_00;
localparam [14:2] AXI_V_AHPPIR  = 13'b110_0000_0010_10;
localparam [14:2] AXI_V_APR     = 13'b110_0000_1101_00;
localparam [14:2] AXI_V_IIDR    = 13'b110_0000_1111_11;
localparam [14:2] AXI_V_EOIR    = 13'b110_0000_0001_00;
localparam [14:2] AXI_V_AEOIR   = 13'b110_0000_0010_01;
localparam [14:2] AXI_V_DIR     = 13'b111_0000_0000_00;

//-----------------------------------------------------------------------------
// Programming Interface Opcodes
//-----------------------------------------------------------------------------

// Distributor registers
localparam [3:0] D_RESERVED     = 4'b0000;
localparam [3:0] D_IGROUPR      = 4'b0001;
localparam [3:0] D_ISENABLER    = 4'b0010;
localparam [3:0] D_ICENABLER    = 4'b0011;
localparam [3:0] D_ISPENDR      = 4'b0100;
localparam [3:0] D_ICPENDR      = 4'b0101;
localparam [3:0] D_ISACTIVER    = 4'b0110;
localparam [3:0] D_ICACTIVER    = 4'b0111;
localparam [3:0] D_IPRIORITYR   = 4'b1000;
localparam [3:0] D_ITARGETSR    = 4'b1001;
localparam [3:0] D_ICFGR        = 4'b1010;
localparam [3:0] D_ISTATUSR     = 4'b1011;
localparam [3:0] D_CPENDSGIR    = 4'b1100;
localparam [3:0] D_SPENDSGIR    = 4'b1101;
localparam [3:0] D_SGIR         = 4'b1110;
localparam [3:0] D_COMMON       = 4'b1111;

// CPU interface registers
localparam [3:0] C_RESERVED = 4'b0000;
localparam [3:0] C_CTLR     = 4'b0001;
localparam [3:0] C_PMR      = 4'b0010;
localparam [3:0] C_BPR      = 4'b0011;
localparam [3:0] C_IAR      = 4'b0100;
localparam [3:0] C_EOIR     = 4'b0101;
localparam [3:0] C_RPR      = 4'b0110;
localparam [3:0] C_HPPIR    = 4'b0111;
localparam [3:0] C_ABPR     = 4'b1000;
localparam [3:0] C_AIAR     = 4'b1001;
localparam [3:0] C_AEOIR    = 4'b1010;
localparam [3:0] C_AHPPIR   = 4'b1011;
localparam [3:0] C_APR      = 4'b1100;
localparam [3:0] C_NSAPR    = 4'b1101;
localparam [3:0] C_DIR      = 4'b1110;

// VCPU interface registers

// - Hypervisor view registers
localparam [3:0] H_RESERVED = 4'b0000;
localparam [3:0] H_HCR      = 4'b0001;
localparam [3:0] H_VTR      = 4'b0010;
localparam [3:0] H_VMCR     = 4'b0011;
localparam [3:0] H_MISR     = 4'b0100;
localparam [3:0] H_EISR     = 4'b0101;
localparam [3:0] H_ELSR     = 4'b0110;
localparam [3:0] H_APR      = 4'b0111;
localparam [3:2] H_LR       = 2'b10;    // Encoding space for list registers - can take list ID from [1:0]
localparam [3:0] H_LR0      = 4'b1000;
localparam [3:0] H_LR1      = 4'b1001;
localparam [3:0] H_LR2      = 4'b1010;
localparam [3:0] H_LR3      = 4'b1011;

// - VM view registers
localparam [3:0] V_RESERVED = 4'b0000;
localparam [3:0] V_CTLR     = 4'b0001;
localparam [3:0] V_PMR      = 4'b0010;
localparam [3:0] V_BPR      = 4'b0011;
localparam [3:0] V_IAR      = 4'b0100;
localparam [3:0] V_EOIR     = 4'b0101;
localparam [3:0] V_RPR      = 4'b0110;
localparam [3:0] V_HPPIR    = 4'b0111;
localparam [3:0] V_ABPR     = 4'b1000;
localparam [3:0] V_AIAR     = 4'b1001;
localparam [3:0] V_AEOIR    = 4'b1010;
localparam [3:0] V_AHPPIR   = 4'b1011;
localparam [3:0] V_APR      = 4'b1100;
localparam [3:0] V_DIR      = 4'b1110;

// Common CPU and VCPU Registers
localparam [3:0] C_V_IIDR   = 4'b1111;

