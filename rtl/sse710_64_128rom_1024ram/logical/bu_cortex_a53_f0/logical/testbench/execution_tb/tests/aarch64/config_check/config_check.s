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

                .section testcode, "ax", %progbits

                .global test_start

//-------------------------------------------------------------------------------
// Main test code
//-------------------------------------------------------------------------------

test_start:     mov     x8, #0x13000000 // Tube address
                adr     x1, banner_msg
                bl      print
                bl      newline

                //----------------------
                // Check number of CPUs
                //----------------------

                mrs     x0, S3_1_c11_c0_2       // Read L2CTLR
                ubfx    x0, x0, #24, #2         // Num. CPUs field
                add     x0, x0, #0x31           // Add num CPUs to ASCII code for '1'
                adr     x1, numcpus_msg
                bl      print
                strb    w0, [x8]
                bl      newline


                //----------------------
                // Check L1 I cache size
                //----------------------

                adr     x1, l1isize_msg
                bl      print

                // Set CSSELR to L1 instruction
                mov     x2, #0x1                // L1 I
                msr     csselr_el1, x2          // CSSELR
                mrs     x2, ccsidr_el1          // CCSIDR
                bic     x2, x2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     x2, x2, #13             // x2 == NumSets - 1
                add     x2, x2, #1

                lsr     x2, x2, #6              // x2 == 0x1 if 8k, 0x2 if 16k, etc
                adr     x1, l1size_8
                mov     x0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l1i_loop:       cmp     x2, #0x1
                b.eq    l1i_end
                lsr     x2, x2, #1
                add     x0, x0, #4              // Offset to next size string
                b       l1i_loop

                // x1 + x2 now points to the correct size string
l1i_end:        add     x1, x1, x0
                bl      print
                bl      newline

                //----------------------
                // Check L1 D cache size
                //----------------------

                adr     x1, l1dsize_msg
                bl      print

                // Set CSSELR to L1 data
                mov     x2, #0x0                // L1 D
                msr     csselr_el1, x2          // CSSELR
                mrs     x2, ccsidr_el1          // CCSIDR
                bic     x2, x2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     x2, x2, #13             // x2 == NumSets - 1
                add     x2, x2, #1

                lsr     x2, x2, #5              // x2 == 0x1 if 8k, 0x2 if 16k, etc
                adr     x1, l1size_8
                mov     x0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l1d_loop:       cmp     x2, #0x1
                b.eq    l1d_end
                lsr     x2, x2, #1
                add     x0, x0, #4              // Offset to next size string
                b       l1d_loop

                // x1 + x2 now points to the correct size string
l1d_end:        add     x1, x1, x0
                bl      print
                bl      newline

                //----------------------
                // Check L2 cache size
                //----------------------

                adr     x1, l2size_msg
                bl      print

                // Read the CLIDR first to check whether an L2 cache is present
                mrs     x2, clidr_el1           // CLIDR
                ubfx    x10, x2, #3, #3         // Get L2 field, preserve in x10
                cbnz    x10, l2_present
                adr     x1, none_msg
                bl      print
                bl      newline
                b       ecc_test

                // Set the CSSELR to L2 and then read the CCSIDR to determine
                // the size
l2_present:     mov     x2, #0x2
                msr     csselr_el1, x2          // CSSELR
                mrs     x2, ccsidr_el1          // CCSIDR
                bic     x2, x2, #(0xF << 28)    // Clear WA, RA, WB, WT fields
                lsr     x2, x2, #13             // x2 == NumSets - 1
                add     x2, x2, #1

                lsr     x2, x2, #7              // x2 == 0x1 if 128k, 0x2 if 256k, etc
                adr     x1, l2size_128
                mov     x0, #0

                // Shift r2 while incrementing the message pointer until we
                // find the current cache size
l2_loop:        cmp     x2, #0x1
                b.eq    l2_end
                lsr     x2, x2, #1
                add     x0, x0, #6              // Offset to next size string
                b       l2_loop

                // w1 + w2 now points to the correct size string
l2_end:         add     x1, x1, x0
                bl      print
                bl      newline

                //----------------------
                // Check L2 latencies
                //----------------------

                // Assumes L2 has already been tested as present

                // Read L2CTLR to get both the input and output latencies of
                // L2 data RAMs
                mrs     x0, S3_1_c11_c0_2       // Read L2CTLR
                and     x2, x0, #0x1            // w2 == output latency field
                and     x3, x0, #(0x1 << 5)
                lsr     x3, x3, #5              // w3 == input latency field

                // Add two to output latency field to get cycle count
                // Add one to input latency field to get cycle count
                // This is done by adding to the ASCII code for '2' and
                // '1' to make it suitable for printing.
                add     x2, x2, #'2'
                add     x3, x3, #'1'

                // Print
                adr     x1, l2latency_o_msg
                bl      print
                strb    w2, [x8]
                bl      newline
                adr     x1, l2latency_i_msg
                bl      print
                strb    w3, [x8]
                bl      newline

                //----------------------------------
                // Check L1 and L2 ECC configuration
                //----------------------------------

ecc_test:       adr     x1, l1ecc_msg
                bl      print

                // Read L2CTLR.  Bit[22] indicates L1ECC, bit[21] indicated L2ECC
                mrs     x0, S3_1_c11_c0_2       // Read L2CTLR
ecc_l1_test:    ubfx    x2, x0, #22, #1
                cmp     x2, #0
                adr     x3, no_msg
                adr     x4, yes_msg
                csel    x1, x3, x4, eq
                bl      print
                bl      newline

                // x10 was set with the CLIDR L2 field.  If this is zero
                // indicating no L2 cache we skip the L2 ECC check.
ecc_l2_test:    cbz     x10, ace_sky_test
                adr     x1, l2ecc_msg    // Continue with L2 ECC check
                bl      print
                ubfx    x2, x0, #21, #1
                cmp     x2, #0
                adr     x3, no_msg
                adr     x4, yes_msg
                csel    x1, x3, x4, eq
                bl      print
                bl      newline

                //----------------------
                // Check ACE/Skyros
                //----------------------

ace_sky_test:   adr     x1, intf_msg
                bl      print

                // Read L2ACTLR.  Bit[3] resets to 0 for ACE, 1 for Skyros
                mrs     x0, S3_1_c15_c0_0
                ands    x0, x0, #0x8
                adr     x2, sky_msg
                adr     x3, ace_msg
                csel    x1, x2, x3, ne
                bl      print
                bl      newline


                //----------------------
                // Check NEON/FPU
                //----------------------

neon_fpu_test:  adr     x1, neon_fpu_msg
                bl      print

                // Read ID_AA64PFR0 to determine whether floating-point and
                // Advanced SIMD is implemented.  ID_AA64PFR0[23:20] shows
                // whether floating-point is implemented and  ID_AA64PFR0[19:16]
                // shows whether Advanced SIMD is implemented.  In Cortex-A53
                // these fields will always read the same value, so we only
                // check one of them here.
                mrs     x0, id_aa64pfr0_el1
                ubfx    x0, x0, #16, #4         // Bits[19:16]
                cmp     x0, #0
                adr     x2, yes_msg
                adr     x3, no_msg
                csel    x1, x2, x3, eq
                bl      print
                bl      newline


                //----------------------
                // Check crypto
                //----------------------

                adr     x1, crypto_msg
                bl      print

                // Read ID_ISAR5.  Bits[15:4] will be zero if cryptographic
                // extensions are not available.
                mrs     x0, id_isar5_el1
                ubfx    x0, x0, #4, #12
                cmp     x0, #0
                adr     x2, no_msg
                adr     x3, yes_msg
                csel    x1, x2, x3, eq

                bl      print
                bl      newline


                //----------------------
                // End of test
                //----------------------

                // Print end of test message
                adr     x1, pass_msg
                bl      print
                bl      newline

                // Print 0x4 (EOT character) to end the test
                mov     w0, #0x4
                strb    w0, [x8]
                dsb     sy
                b       .


//-------------------------------------------------------------------------------
// Subroutines
//-------------------------------------------------------------------------------

                // Routine to print a string at the address in x1.
                //  - Expects x8 -> tube
                //  - Modifies w7
.type print, %function
print:          ldrb    w7, [x1], #0x1
                cbz     w7, print_end
                strb    w7, [x8]
                b       print
print_end:      ret

                // Routine to print a newline character to the tube.
                //  - Expects x8 -> tube
                //  - Modifies w7
.type newline, %function
newline:        mov     w7, #'\n'
                strb    w7, [x8]
                ret


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
