//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2014 ARM Limited.
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
//   This test checks the operation of the ALU and the condition code system
//   using ARM instructions.  It first manually sets the condition codes using
//   a special-purpose MSR instruction and then conditionally executes branch
//   instructions.  It also performs comparisons of large and small positive and
//   negative numbers
//-------------------------------------------------------------------------------

// Test constants
.equ NUM_PARTS,  4
.equ NUM_ITERS,  5

                .section testcode, "ax", %progbits
                .align 8

                .global test_start


//-------------------------------------------------------------------------------
// Macros
//-------------------------------------------------------------------------------

// Alternative macro syntax used to simplify quoting of some macro arguments
.altmacro

                // Conditional branch
                .macro BCC_COND cc, list
                .ifne (\list) & \cc
                B.\cc   .+8
                b       exit
                .else
                B.\cc   exit
                .endif
                .endm

                // Test conditional branch
                .macro BCC_TEST cc, reg, list
                LOCAL lbl
lbl:            mov     \reg, #\cc
                msr     NZCV, \reg
                BCC_COND EQ, \list
                BCC_COND NE, \list
                BCC_COND CS, \list
                BCC_COND CC, \list
                BCC_COND MI, \list
                BCC_COND PL, \list
                BCC_COND VS, \list
                BCC_COND VC, \list
                BCC_COND HI, \list
                BCC_COND LS, \list
                BCC_COND GE, \list
                BCC_COND LT, \list
                BCC_COND GT, \list
                BCC_COND LE, \list
                add     x0, x0, #1      // test id counter
                .endm

                // Test flags
                .macro FLAG_TEST cc, reg, list, instr
                LOCAL lbl
lbl:            mov     \reg, #\cc
                msr     NZCV, \reg
                \instr
                .ifne (\list) & EQ
                b.eq    exit
                .endif
                .ifne (\list) & NE
                b.ne    exit
                .endif
                .ifne (\list) & CS
                b.cs    exit
                .endif
                .ifne (\list) & CC
                b.cc    exit
                .endif
                .ifne (\list) & MI
                b.mi    exit
                .endif
                .ifne (\list) & PL
                b.pl    exit
                .endif
                .ifne (\list) & VS
                b.vs    exit
                .endif
                .ifne (\list) & VC
                b.vc    exit
                .endif
                add     x0, x0, #1
                .endm

                // Test relations (e.g. LT, GT, etc.)
                .macro REL_TEST list, instr
                LOCAL lbl
lbl:            \instr
                .ifne (\list) & EQ
                b.eq    exit
                .endif
                .ifne (\list) & NE
                b.ne    exit
                .endif
                .ifne (\list) & CS
                b.cs    exit
                .endif
                .ifne (\list) & CC
                b.cc    exit
                .endif
                .ifne (\list) & HI
                b.hi    exit
                .endif
                .ifne (\list) & LS
                b.ls    exit
                .endif
                .ifne (\list) & GE
                b.ge    exit
                .endif
                .ifne (\list) & LT
                b.lt    exit
                .endif
                .ifne (\list) & GT
                b.gt    exit
                .endif
                .ifne (\list) & LE
                b.le    exit
                .endif
                add     x0, x0, #1
                .endm


// Relational definitions
.equ EQ, 1<<0
.equ NE, 1<<1
.equ CS, 1<<2
.equ CC, 1<<3
.equ MI, 1<<4
.equ PL, 1<<5
.equ VS, 1<<6
.equ VC, 1<<7
.equ HI, 1<<8
.equ LS, 1<<9
.equ GE, 1<<10
.equ LT, 1<<11
.equ GT, 1<<12
.equ LE, 1<<13
.equ AL, 1<<14
.equ NV, 1<<15

// Flag positions
.equ NFLAG, 0x80000000
.equ ZFLAG, 0x40000000
.equ CFLAG, 0x20000000
.equ VFLAG, 0x10000000


//-------------------------------------------------------------------------------
// Main test code
//-------------------------------------------------------------------------------

test_start:
                mov     x0,  #0
                mov     x10, #NUM_ITERS // Run several iterations

loop:
                // Test conditional branches, coverage is exhaustive.
bcc_00:         BCC_TEST 0,                      x13,NE+CC+PL+VC+LS+GE+GT
bcc_01:         BCC_TEST VFLAG,                  x13,NE+CC+PL+VS+LS+LT+LE
bcc_02:         BCC_TEST CFLAG,                  x13,NE+CS+PL+VC+HI+GE+GT
bcc_03:         BCC_TEST CFLAG+VFLAG,            x13,NE+CS+PL+VS+HI+LT+LE
bcc_04:         BCC_TEST ZFLAG,                  x13,EQ+CC+PL+VC+LS+GE+LE
bcc_05:         BCC_TEST ZFLAG+VFLAG,            x13,EQ+CC+PL+VS+LS+LT+LE
bcc_06:         BCC_TEST ZFLAG+CFLAG,            x13,EQ+CS+PL+VC+LS+GE+LE
bcc_07:         BCC_TEST ZFLAG+CFLAG+VFLAG,      x13,EQ+CS+PL+VS+LS+LT+LE
bcc_08:         BCC_TEST NFLAG,                  x13,NE+CC+MI+VC+LS+LT+LE
bcc_09:         BCC_TEST NFLAG+VFLAG,            x13,NE+CC+MI+VS+LS+GE+GT
bcc_0A:         BCC_TEST NFLAG+CFLAG,            x13,NE+CS+MI+VC+HI+LT+LE
bcc_0B:         BCC_TEST NFLAG+CFLAG+VFLAG,      x13,NE+CS+MI+VS+HI+GE+GT
bcc_0C:         BCC_TEST NFLAG+ZFLAG,            x13,EQ+CC+MI+VC+LS+LT+LE
bcc_0D:         BCC_TEST NFLAG+ZFLAG+VFLAG,      x13,EQ+CC+MI+VS+LS+GE+LE
bcc_0E:         BCC_TEST NFLAG+ZFLAG+CFLAG,      x13,EQ+CS+MI+VC+LS+LT+LE
bcc_0F:         BCC_TEST NFLAG+ZFLAG+CFLAG+VFLAG,x13,EQ+CS+MI+VS+LS+GE+LE
                cmp     x0, #0x10
                b.ne    exit
                add     x11, x11, #1

                mov     x0, #0

                // Test setting N flag to 1 and Z flag to 0
                mov     x1, #((NFLAG+ZFLAG+CFLAG+VFLAG)<<32) // Move to top of doubleword
flg_00:         FLAG_TEST 0,                       x13, PL+EQ+CS+VS, <tst x1,x1>
flg_01:         FLAG_TEST ZFLAG+CFLAG+VFLAG,       x13, PL+EQ+CS+VS, <tst x1,x1>
flg_02:         FLAG_TEST NFLAG+CFLAG+VFLAG,       x13, PL+EQ+CS+VS, <tst x1,x1>
flg_03:         FLAG_TEST NFLAG,                   x13, PL+EQ+CS+VS, <tst x1,x1>
flg_04:         FLAG_TEST ZFLAG,                   x13, PL+EQ+CS+VS, <tst x1,x1>
flg_05:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, PL+EQ+CS+VS, <tst x1,x1>

                // Test setting N flag to 0 and Z flag to 1
                mov     x1, #((NFLAG+ZFLAG+CFLAG+VFLAG)<<32)
flg_06:         FLAG_TEST 0,                       x13, MI+NE+CS+VS, <bics xzr, x1,x1>
flg_07:         FLAG_TEST ZFLAG+CFLAG+VFLAG,       x13, MI+NE+CS+VS, <bics xzr, x1,x1>
flg_08:         FLAG_TEST NFLAG+CFLAG+VFLAG,       x13, MI+NE+CS+VS, <bics xzr, x1,x1>
flg_09:         FLAG_TEST NFLAG,                   x13, MI+NE+CS+VS, <bics xzr, x1,x1>
flg_0A:         FLAG_TEST ZFLAG,                   x13, MI+NE+CS+VS, <bics xzr, x1,x1>
flg_0B:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, MI+NE+CS+VS, <bics xzr, x1,x1>

                // Test setting N flag to 0 and Z flag to 0
                mov    x1, #0x340000
flg_0C:         FLAG_TEST 0,                       x13, MI+EQ+CS+VS, <tst x1,x1>
flg_0D:         FLAG_TEST ZFLAG+CFLAG+VFLAG,       x13, MI+EQ+CS+VS, <tst x1,x1>
flg_0E:         FLAG_TEST NFLAG+CFLAG+VFLAG,       x13, MI+EQ+CS+VS, <tst x1,x1>
flg_0F:         FLAG_TEST NFLAG,                   x13, MI+EQ+CS+VS, <tst x1,x1>
flg_10:         FLAG_TEST ZFLAG,                   x13, MI+EQ+CS+VS, <tst x1,x1>
flg_11:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, MI+EQ+CS+VS, <tst x1,x1>

                // Test setting C flag to 0 and V flag to 0
                mov     x1, #0x340000
flg_12:         FLAG_TEST 0,                       x13, CS+VS, <cmn x1,x1>
flg_13:         FLAG_TEST NFLAG+ZFLAG+CFLAG,       x13, CS+VS, <cmn x1,x1>
flg_14:         FLAG_TEST VFLAG,                   x13, CS+VS, <cmn x1,x1>
flg_15:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, CS+VS, <cmn x1,x1>

                // Test setting C flag to 1 and Vflag to 0
                mov     x1, #((NFLAG+ZFLAG+CFLAG+VFLAG)<<32)
flg_16:         FLAG_TEST 0,                       x13, CC+VS, <cmn x1,x1>
flg_17:         FLAG_TEST NFLAG+ZFLAG+CFLAG,       x13, CC+VS, <cmn x1,x1>
flg_18:         FLAG_TEST VFLAG,                   x13, CC+VS, <cmn x1,x1>
flg_19:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, CC+VS, <cmn x1,x1>

                // Test setting C flag to 0 and V flag to 1
                mov     x1, #0x7100000000000000
flg_1A:         FLAG_TEST 0,                       x13, CS+VC, <cmn x1,x1>
flg_1B:         FLAG_TEST NFLAG+ZFLAG+CFLAG,       x13, CS+VC, <cmn x1,x1>
flg_1C:         FLAG_TEST VFLAG,                   x13, CS+VC, <cmn x1,x1>
flg_1D:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, CS+VC, <cmn x1,x1>

                // Test setting C flag to 1 and V flag to 1
                mov    x1, #0x8100000000000000
flg_1E:         FLAG_TEST 0,                       x13, CC+VC, <cmn x1,x1>
flg_1F:         FLAG_TEST NFLAG+ZFLAG+CFLAG,       x13, CC+VC, <cmn x1,x1>
flg_20:         FLAG_TEST VFLAG,                   x13, CC+VC, <cmn x1,x1>
flg_21:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG, x13, CC+VC, <cmn x1,x1>

                cmp     x0, #0x22
                b.ne    exit
                add     x11, x11, #1

                // Test relations. Need 5 numbers bigneg, neg, 0,  pos, bigpos
                //                                R5      R4   R3  R2   R1
                mov     x0, #0

                mov     x2, #0xFF00
                mov     x3, #0
                mov     x4, #0xFF00000000000000
                mov     x5, #0x8000000000000000
                subs    x1, x5, #1
                b.vc    exit
                b.cc    exit

                REL_TEST NE+CC+HI+LT+GT, <cmp x1,x1>
                REL_TEST EQ+CC+LS+LT+LE, <cmp x1,x2>
                REL_TEST EQ+CC+LS+LT+LE, <cmp x1,x3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x1,x4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x1,x5>

                REL_TEST EQ+CS+HI+GE+GT, <cmp x2,x1>
                REL_TEST NE+CC+HI+LT+GT, <cmp x2,x2>
                REL_TEST EQ+CC+LS+LT+LE, <cmp x2,x3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x2,x4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x2,x5>

                REL_TEST EQ+CS+HI+GE+GT, <cmp x3,x1>
                REL_TEST EQ+CS+HI+GE+GT, <cmp x3,x2>
                REL_TEST NE+CC+HI+LT+GT, <cmp x3,x3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x3,x4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp x3,x5>

                REL_TEST EQ+CC+LS+GE+GT, <cmp x4,x1>
                REL_TEST EQ+CC+LS+GE+GT, <cmp x4,x2>
                REL_TEST EQ+CC+LS+GE+GT, <cmp x4,x3>
                REL_TEST NE+CC+HI+LT+GT, <cmp x4,x4>
                REL_TEST EQ+CC+LS+LT+LE, <cmp x4,x5>

                REL_TEST EQ+CC+LS+GE+GT, <cmp x5,x1>
                REL_TEST EQ+CC+LS+GE+GT, <cmp x5,x2>
                REL_TEST EQ+CC+LS+GE+GT, <cmp x5,x3>
                REL_TEST EQ+CS+HI+GE+GT, <cmp x5,x4>
                REL_TEST NE+CC+HI+LT+GT, <cmp x5,x5>

                // Check cmn
                sub     x3, x3, #1      //  -1
                cmn     x3, #1
                b.cc    exit
                b.ne    exit

                add     x11, x11, #1

                // Check ALU results
                mov     x0, #0          // 0
                ldr     x1, fives       // 0x55..
                ldr     x2, fives+8     // 0xAA..
                ldr     x3, fives+16    // 0xFF..
                ldr     x4, fives+24    // 0x55..+0xFF..
                ldr     x5, fives+32    // 0xAA..+0xFF..

                // Move negated
                mvn     x8, x3
                cbnz    x8, exit
                mvn     x8, x2
                cmp     x8, x1
                b.ne    exit
                mvn     x8, x1
                cmp     x8, x2
                b.ne    exit
                mvn     x8, x0
                cmp     x8, x3
                b.ne    exit

                // Add
                adds    x8, x0, x0
                b.ne    exit
                add     x8, x0, x1
                cmp     x8, x1
                b.ne    exit
                add     x8, x0, x2
                cmp     x8, x2
                b.ne    exit
                add     x8, x0, x3
                cmp     x8, x3
                b.ne    exit
                add     x8, x1, x0
                cmp     x8, x1
                b.ne    exit
                add     x8, x1, x1
                cmp     x8, x2
                b.ne    exit
                add     x8, x1, x2
                cmp     x8, x3
                b.ne    exit
                add     x8, x1, x3
                cmp     x8, x4
                b.ne    exit
                add     x8, x2, x0
                cmp     x8, x2
                b.ne    exit
                add     x8, x2, x1
                cmp     x8, x3
                b.ne    exit
                add     x8, x2, x2
                cmp     x8, x2, lsl #1
                b.ne    exit
                add     x8, x2, x3
                cmp     x8, x5
                b.ne    exit
                add     x8, x3, x0
                cmp     x8, x3
                b.ne    exit
                add     x8, x3, x1
                cmp     x8, x4
                b.ne    exit
                add     x8, x3, x2
                cmp     x8, x5
                b.ne    exit
                add     x8, x3, x3
                cmp     x8, x3, lsl #1
                b.ne    exit

                // Check adc
                adds    x8, x3, x3      // Set carry
                adc     x8, x0, x0
                cmp     x8, #1
                b.ne    exit
                adds    x8, x0, x0
                adcs    x8, x0, x0
                b.ne    exit

                // Check sub
                sub     x8, x3, x2
                cmp     x8, x1
                b.ne    exit

                // Check sbc
                sbc     x8, x3, x2
                cmp     x8, x1
                b.ne    exit

                // and
                ands    x8, x0, x0
                b.ne    exit
                ands    x8, x0, x1
                b.ne    exit
                ands    x8, x0, x2
                b.ne    exit
                ands    x8, x0, x3
                b.ne    exit
                ands    x8, x1, x0
                b.ne    exit
                and     x8, x1, x1
                cmp     x8, x1
                b.ne    exit
                ands    x8, x1, x2
                b.ne    exit
                and     x8, x1, x3
                cmp     x8, x1
                b.ne    exit
                ands    x8, x2, x0
                b.ne    exit
                ands    x8, x2, x1
                b.ne    exit
                and     x8, x2, x2
                cmp     x8, x2
                b.ne    exit
                and     x8, x2, x3
                cmp     x8, x2
                b.ne    exit
                ands    x8, x3, x0
                b.ne    exit
                and     x8, x3, x1
                cmp     x8, x1
                b.ne    exit
                and     x8, x3, x2
                cmp     x8, x2
                b.ne    exit
                and     x8, x3, x3
                cmp     x8, x3
                b.ne    exit

                // or
                orr     x8,x0,x0
                cbnz    x8, exit
                orr     x8,x0,x1
                cmp     x8,x1
                b.ne    exit
                orr     x8,x0,x2
                cmp     x8,x2
                b.ne    exit
                orr     x8,x0,x3
                cmp     x8,x3
                b.ne    exit
                orr     x8,x1,x0
                cmp     x8,x1
                b.ne    exit
                orr     x8,x1,x1
                cmp     x8,x1
                b.ne    exit
                orr     x8,x1,x2
                cmp     x8,x3
                b.ne    exit
                orr     x8,x1,x3
                cmp     x8,x3
                b.ne    exit
                orr     x8,x2,x0
                cmp     x8,x2
                b.ne    exit
                orr     x8,x2,x1
                cmp     x8,x3
                b.ne    exit
                orr     x8,x2,x2
                cmp     x8,x2
                b.ne    exit
                orr     x8,x2,x3
                cmp     x8,x3
                b.ne    exit
                orr     x8,x3,x0
                cmp     x8,x3
                b.ne    exit
                orr     x8,x3,x1
                cmp     x8,x3
                b.ne    exit
                orr     x8,x3,x2
                cmp     x8,x3
                b.ne    exit
                orr     x8,x3,x3
                cmp     x8,x3
                b.ne    exit

                // eor
                eor     x8, x0, x0
                cbnz    x8, exit
                eor     x8, x0, x1
                cmp     x8, x1
                b.ne    exit
                eor     x8, x0, x2
                cmp     x8, x2
                b.ne    exit
                eor     x8, x0, x3
                cmp     x8, x3
                b.ne    exit
                eor     x8, x1, x0
                cmp     x8, x1
                b.ne    exit
                eor     x8, x1, x1
                cbnz    x8, exit
                eor     x8, x1, x2
                cmp     x8, x3
                b.ne    exit
                eor     x8, x1, x3
                cmp     x8, x2
                b.ne    exit
                eor     x8, x2, x0
                cmp     x8, x2
                b.ne    exit
                eor     x8, x2, x1
                cmp     x8, x3
                b.ne    exit
                eor     x8, x2, x2
                cbnz    x8, exit
                eor     x8, x2, x3
                cmp     x8, x1
                b.ne    exit
                eor     x8, x3, x0
                cmp     x8, x3
                b.ne    exit
                eor     x8, x3, x1
                cmp     x8, x2
                b.ne    exit
                eor     x8, x3, x2
                cmp     x8, x1
                b.ne    exit
                eor     x8, x3, x3
                cbnz    x8, exit
                add     x11, x11, #1

                // Decrement loop counter and run again until it reaches zero
                subs    x10, x10, #1
                b.ne    loop


//-------------------------------------------------------------------------------
// End of test
//-------------------------------------------------------------------------------

exit:
                // Register r11 contains the number of completed parts multiplied
                // by the number of test iterations.  Any failing parts would
                // have branched here before r11 increments to the expected value.
                // Print pass or fail message depending on whether r11 is the
                // expected value.
                mov     x1, #(NUM_PARTS * NUM_ITERS)
                cmp     x1, x11

                ldr     x0, =0x13000000         // Tube address
                adr     x1, test_pass_msg
                adr     x2, test_fail_msg
                csel    x1, x1, x2, eq

                // Print loop
print_loop:     ldrb    w2, [x1], #1
                cbz     w2, print_end
                strb    w2, [x0]
                b       print_loop

print_end:      mov     w2, #0x04
                strb    w2, [x0]
                dsb     sy
end_wfi:        wfi
                b       end_wfi


//-------------------------------------------------------------------------------
// Test data pool
//-------------------------------------------------------------------------------

// Note: the bitwise AND (&) expression in some of the constants below is to
// remove the carry-out that intentionally results from the addition.  This would
// otherwise generate an assembler warning.  Although the addition intentionally
// creates a carry-out only the 64-bit result is needed to check against the
// ALU result from the same addition.
fives:          .quad 0x5555555555555555
                .quad 0xAAAAAAAAAAAAAAAA
                .quad -1
                .quad (0x5555555555555555+0xFFFFFFFFFFFFFFFF) & 0xFFFFFFFFFFFFFFFF
                .quad (0xAAAAAAAAAAAAAAAA+0xFFFFFFFFFFFFFFFF) & 0xFFFFFFFFFFFFFFFF

                .balign 4
test_pass_msg:  .asciz "** TEST PASSED OK **\n"
test_fail_msg:  .asciz "** TEST FAILED **\n"

                .end
