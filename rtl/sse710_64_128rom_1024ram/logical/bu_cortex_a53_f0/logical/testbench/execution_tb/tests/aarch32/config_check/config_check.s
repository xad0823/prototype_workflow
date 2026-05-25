//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-------------------------------------------------------------------------------
// Description:
//
//   Prints the processor configuration
//-------------------------------------------------------------------------------


// Enable UAL syntax
.syntax unified

                .section testcode, "ax", %progbits

                .global test_start

//-------------------------------------------------------------------------------
// Main test code
//-------------------------------------------------------------------------------

test_start:     ldr     r8, =0x13000000 // Tube address
                ldr     r1, =banner_msg
                bl      print
                bl      newline

                //----------------------
                // Check number of CPUs
                //----------------------

                mrc     p15, 1, r0, c9, c0, 2   // Read L2CTLR
                ubfx    r0, r0, #24, #2         // Num. CPUs field
                add     r0, r0, #0x31           // Add num CPUs to ASCII code for '1'
                ldr     r1, =numcpus_msg
                bl      print
                strb    r0, [r8]
                bl      newline


                //----------------------
                // Check L1 I cache size
                //----------------------

                ldr     r1, =l1isize_msg
                bl      print

                // Set CSSELR to L1 instruction
                mov     r2, #0x1                // L1 I
                mcr     p15, 2, r2, c0, c0, 0   // CSSELR
                mrc     p15, 1, r2, c0, c0, 0   // CCSIDR
                bic     r2, r2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     r2, r2, #13             // r2 == NumSets - 1
                add     r2, r2, #1

                lsr     r2, r2, #6              // r2 == 0x1 if 8k, 0x2 if 16k, etc
                ldr     r1, =l1size_8
                mov     r0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l1i_loop:       cmp     r2, #0x1
                lsrne   r2, r2, #1
                addne   r0, r0, #4              // Offset to next size string
                bne     l1i_loop

                // r1 + r2 now points to the correct size string
                add     r1, r1, r0
                bl      print
                bl      newline

                //----------------------
                // Check L1 D cache size
                //----------------------

                ldr     r1, =l1dsize_msg
                bl      print

                // Set CSSELR to L1 data
                mov     r2, #0x0                // L1 D
                mcr     p15, 2, r2, c0, c0, 0   // CSSELR
                mrc     p15, 1, r2, c0, c0, 0   // CCSIDR
                bic     r2, r2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     r2, r2, #13             // r2 == NumSets - 1
                add     r2, r2, #1

                lsr     r2, r2, #5              // r2 == 0x1 if 8k, 0x2 if 16k, etc
                ldr     r1, =l1size_8
                mov     r0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l1d_loop:       cmp     r2, #0x1
                lsrne   r2, r2, #1
                addne   r0, r0, #4              // Offset to next size string
                bne     l1d_loop

                // r1 + r2 now points to the correct size string
                add     r1, r1, r0
                bl      print
                bl      newline

                //----------------------
                // Check L2 cache size
                //----------------------

                ldr     r1, =l2size_msg
                bl      print

                // Read the CLIDR first to check whether an L2 cache is present
                mrc     p15, 1, r2, c0, c0, 1   // CLIDR
                lsr     r2, r2, #3              // Get L2 field in bits [2:0]
                ands    r10, r2, #0x7           // Clear other bits and preserve in r10
                bne     l2_present
                ldr     r1, =none_msg
                bl      print
                bl      newline
                b       ecc_test

                // Set the CSSELR to L2 and then read the CCSIDR to determine
                // the size
l2_present:     mov     r2, #0x2
                mcr     p15, 2, r2, c0, c0, 0   // CSSELR
                mrc     p15, 1, r2, c0, c0, 0   // CCSIDR
                bic     r2, r2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     r2, r2, #13             // r2 == NumSets - 1
                add     r2, r2, #1

                lsr     r2, r2, #7              // r2 == 0x1 if 128k, 0x2 if 256k, etc
                ldr     r1, =l2size_128
                mov     r0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l2_loop:        cmp     r2, #0x1
                lsrne   r2, r2, #1
                addne   r0, r0, #6              // Offset to next size string
                bne     l2_loop

                // r1 + r2 now points to the correct size string
                add     r1, r1, r0
                bl      print
                bl      newline

                //----------------------
                // Check L2 latencies
                //----------------------

                // Assumes L2 has already been tested as present

                // Read L2CTLR to get both the input and output latencies of
                // L2 data RAMs
                mrc     p15, 1, r0, c9, c0, 2
                and     r2, r0, #0x1            // r2 == output latency field
                and     r3, r0, #(0x1 << 5)
                lsr     r3, r3, #5              // r3 == input latency field

                // Add two to output latency field to get cycle count
                // Add one to input latency field to get cycle count
                // This is done by adding to the ASCII code for '2' and
                // '1' to make it suitable for printing.
                add     r2, r2, #'2'
                add     r3, r3, #'1'

                // Print
                ldr     r1, =l2latency_o_msg
                bl      print
                strb    r2, [r8]
                bl      newline
                ldr     r1, =l2latency_i_msg
                bl      print
                strb    r3, [r8]
                bl      newline

                //----------------------------------
                // Check L1 and L2 ECC configuration
                //----------------------------------

ecc_test:       ldr     r1, =l1ecc_msg
                bl      print

                // Read L2CTLR.  Bit[22] indicates L1ECC, bit[21] indicated L2ECC
                mrc     p15, 1, r0, c9, c0, 2
ecc_l1_test:    ubfx    r2, r0, #22, #1
                cmp     r2, #0
                ldreq   r1, =no_msg
                ldrne   r1, =yes_msg
                bl      print
                bl      newline

                // r10 was set with the CLIDR L2 field.  If this is zero
                // indicating no L2 cache we skip the L2 ECC check.
ecc_l2_test:    cmp     r10, #0
                beq     ace_sky_test
                ldr     r1, =l2ecc_msg   // Continue with L2 ECC check
                bl      print
                ubfx    r2, r0, #21, #1
                cmp     r2, #0
                ldreq   r1, =no_msg
                ldrne   r1, =yes_msg
                bl      print
                bl      newline

                //----------------------
                // Check ACE/Skyros
                //----------------------

ace_sky_test:   ldr     r1, =intf_msg
                bl      print

                // Read L2ACTLR.  Bit[3] resets to 0 for ACE, 1 for Skyros
                mrc     p15, 1, r0, c15, c0, 0
                ands    r0, r0, #0x8
                ldrne   r1, =sky_msg
                ldreq   r1, =ace_msg
                bl      print
                bl      newline


                //----------------------
                // Check NEON/FPU
                //----------------------

neon_fpu_test:  ldr     r1, =neon_fpu_msg
                bl      print

                // Attempt to enable CP10 and CP11 in the CPACR.
                // Then read back the CPACR to check that bit[20] is set
                // indicating that access is permitted.
                mov     r0, #(0xFF << 20)
                mcr     p15, 0, r0, c1, c0, 2   // Write CPACR
                mrc     p15, 0, r0, c1, c0, 2   // Read CPACR
                ubfx    r0, r0, #20, #1         // Get bit[20]
                cmp     r0, #1
                ldreq   r1, =yes_msg
                ldrne   r1, =no_msg

                bl      print
                bl      newline


                //----------------------
                // Check crypto
                //----------------------

                ldr     r1, =crypto_msg
                bl      print

                // Read ID_ISAR5.  Bits[15:4] will be zero if cryptographic
                // extensions are not available.
                mrc     p15, 0, r0, c0, c2, 5
                ubfx    r0, r0, #4, #12
                cmp     r0, #0
                ldreq   r1, =no_msg
                ldrne   r1, =yes_msg

                bl      print
                bl      newline


                //----------------------
                // End of test
                //----------------------

                // Print end of test message
                ldr     r1, =pass_msg
                bl      print
                bl      newline

                // Print 0x4 (EOT character) to end the test
                mov     r0, #0x4
                strb    r0, [r8]
                dsb
                b       .


//-------------------------------------------------------------------------------
// Subroutines
//-------------------------------------------------------------------------------

                // Routine to print a string at the address in r1.
                //  - Expects r8 -> tube
                //  - Modifies r7
.type print, %function
print:          ldrb    r7, [r1], #0x1
                cmp     r7, #0x0
                strbne  r7, [r8]
                bne     print
                mov     pc, lr          // Return on NULL character

                // Routine to print a newline character to the tube.
                //  - Expects r8 -> tube
                //  - Modifies r7
.type newline, %function
newline:        mov     r7, #'\n'
                strb    r7, [r8]
                mov     pc, lr


//-------------------------------------------------------------------------------
// Strings
//-------------------------------------------------------------------------------
                 .balign 4
banner_msg:      .asciz "Cortex-A53 configuration check"
numcpus_msg:     .asciz "Number of CPUs                    : "
crypto_msg:      .asciz "Cryptography extension            : "
l1isize_msg:     .asciz "L1 I cache size                   : "
l1dsize_msg:     .asciz "L1 D cache size                   : "
l2size_msg:      .asciz "L2 cache size                     : "
l2latency_i_msg: .asciz "L2 data RAM input latency cycles  : "
l2latency_o_msg: .asciz "L2 data RAM output latency cycles : "
l1ecc_msg:       .asciz "CPU cache protection              : "
l2ecc_msg:       .asciz "SCU L2 cache protection           : "
intf_msg:        .asciz "Bus master interface              : "
neon_fpu_msg:    .asciz "NEON and floating point support   : "

ace_msg:         .asciz "ACE"
sky_msg:         .asciz "Skyros"

yes_msg:         .asciz "Yes"
no_msg:          .asciz "No"
none_msg:        .asciz "None"

l2size_128:      .asciz "128K\0"  // Pad with extra NULLs to make all labels
l2size_256:      .asciz "256K\0"  //  in this set an equal size
l2size_512:      .asciz "512K\0"
l2size_1024:     .asciz "1024K"
l2size_2048:     .asciz "2048K"

l1size_8:        .asciz "8K\0"
l1size_16:       .asciz "16K"
l1size_32:       .asciz "32K"
l2size_64:       .asciz "64K"
pass_msg:        .asciz "** TEST PASSED OK **\n"

                 .end
