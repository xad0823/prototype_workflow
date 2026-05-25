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
//   MSR CPSR_flag,#<imm> and then conditionally executes branch instructions.
//   It also performs comparisons of large and small positive and negative
//   numbers
//-------------------------------------------------------------------------------

// Test constants
.equ NUM_PARTS,  4
.equ NUM_ITERS,  5

                .code 32

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
                B\cc    .+8
                b       exit
                .else
                B\cc    exit
                .endif
                .endm

                // Test conditional branch
                .macro BCC_TEST cc, list
                LOCAL lbl
lbl:            msr     CPSR_f,#(\cc)
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
                add     r0, r0, #1      // test id counter
                .endm

                // Test flags
                .macro FLAG_TEST cc, list, instr
                LOCAL lbl
lbl:            msr     CPSR_f,#(\cc)
                \instr
                .ifne (\list) & EQ
                beq     exit
                .endif
                .ifne (\list) & NE
                bne     exit
                .endif
                .ifne (\list) & CS
                bcs     exit
                .endif
                .ifne (\list) & CC
                bcc     exit
                .endif
                .ifne (\list) & MI
                bmi     exit
                .endif
                .ifne (\list) & PL
                bpl     exit
                .endif
                .ifne (\list) & VS
                bvs     exit
                .endif
                .ifne (\list) & VC
                bvc     exit
                .endif
                add     r0, r0, #1
                .endm

                // Test relations (e.g. LT, GT, etc.)
                .macro REL_TEST list, instr
                LOCAL lbl
lbl:            \instr
                .ifne (\list) & EQ
                beq     exit
                .endif
                .ifne (\list) & NE
                bne     exit
                .endif
                .ifne (\list) & CS
                bcs     exit
                .endif
                .ifne (\list) & CC
                bcc     exit
                .endif
                .ifne (\list) & HI
                bhi     exit
                .endif
                .ifne (\list) & LS
                bls     exit
                .endif
                .ifne (\list) & GE
                bge     exit
                .endif
                .ifne (\list) & LT
                blt     exit
                .endif
                .ifne (\list) & GT
                bgt     exit
                .endif
                .ifne (\list) & LE
                ble     exit
                .endif
                add     r0, r0, #1
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
                mov     r0,  #0
                mov     r10, #NUM_ITERS // Run several iterations

loop:
                // Test conditional branches, coverage is exhaustive.
bcc_00:         BCC_TEST 0,                      NE+CC+PL+VC+LS+GE+GT
bcc_01:         BCC_TEST VFLAG,                  NE+CC+PL+VS+LS+LT+LE
bcc_02:         BCC_TEST CFLAG,                  NE+CS+PL+VC+HI+GE+GT
bcc_03:         BCC_TEST CFLAG+VFLAG,            NE+CS+PL+VS+HI+LT+LE
bcc_04:         BCC_TEST ZFLAG,                  EQ+CC+PL+VC+LS+GE+LE
bcc_05:         BCC_TEST ZFLAG+VFLAG,            EQ+CC+PL+VS+LS+LT+LE
bcc_06:         BCC_TEST ZFLAG+CFLAG,            EQ+CS+PL+VC+LS+GE+LE
bcc_07:         BCC_TEST ZFLAG+CFLAG+VFLAG,      EQ+CS+PL+VS+LS+LT+LE
bcc_08:         BCC_TEST NFLAG,                  NE+CC+MI+VC+LS+LT+LE
bcc_09:         BCC_TEST NFLAG+VFLAG,            NE+CC+MI+VS+LS+GE+GT
bcc_0A:         BCC_TEST NFLAG+CFLAG,            NE+CS+MI+VC+HI+LT+LE
bcc_0B:         BCC_TEST NFLAG+CFLAG+VFLAG,      NE+CS+MI+VS+HI+GE+GT
bcc_0C:         BCC_TEST NFLAG+ZFLAG,            EQ+CC+MI+VC+LS+LT+LE
bcc_0D:         BCC_TEST NFLAG+ZFLAG+VFLAG,      EQ+CC+MI+VS+LS+GE+LE
bcc_0E:         BCC_TEST NFLAG+ZFLAG+CFLAG,      EQ+CS+MI+VC+LS+LT+LE
bcc_0F:         BCC_TEST NFLAG+ZFLAG+CFLAG+VFLAG,EQ+CS+MI+VS+LS+GE+LE
                cmp     r0, #0x10
                bne     exit
                add     r11, r11, #1

                mov     r0, #0

                // Test setting N flag to 1 and Z flag to 0
                mov     r1, #(NFLAG+ZFLAG+CFLAG+VFLAG)
flg_00:         FLAG_TEST 0,                      PL+EQ+CS+VS, <tst r1,r1>
flg_01:         FLAG_TEST ZFLAG+CFLAG+VFLAG,      PL+EQ+CC+VC, <tst r1,r1>
flg_02:         FLAG_TEST NFLAG+CFLAG+VFLAG,      PL+EQ+CC+VC, <tst r1,r1>
flg_03:         FLAG_TEST NFLAG,                  PL+EQ+CS+VS, <tst r1,r1>
flg_04:         FLAG_TEST ZFLAG,                  PL+EQ+CS+VS, <tst r1,r1>
flg_05:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,PL+EQ+CC+VC, <tst r1,r1>

                // Test setting N flag to 0 and Z flag to 1
                mov     r1, #(NFLAG+ZFLAG+CFLAG+VFLAG)
flg_06:         FLAG_TEST 0,                      MI+NE+CS+VS, <teq r1,r1>
flg_07:         FLAG_TEST ZFLAG+CFLAG+VFLAG,      MI+NE+CC+VC, <teq r1,r1>
flg_08:         FLAG_TEST NFLAG+CFLAG+VFLAG,      MI+NE+CC+VC, <teq r1,r1>
flg_09:         FLAG_TEST NFLAG,                  MI+NE+CS+VS, <teq r1,r1>
flg_0A:         FLAG_TEST ZFLAG,                  MI+NE+CS+VS, <teq r1,r1>
flg_0B:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,MI+NE+CC+VC, <teq r1,r1>

                // Test setting N flag to 0 and Z flag to 0
                mov    r1, #0x340000
flg_0C:         FLAG_TEST 0,                      MI+EQ+CS+VS, <tst r1,r1>
flg_0D:         FLAG_TEST ZFLAG+CFLAG+VFLAG,      MI+EQ+CC+VC, <tst r1,r1>
flg_0E:         FLAG_TEST NFLAG+CFLAG+VFLAG,      MI+EQ+CC+VC, <tst r1,r1>
flg_0F:         FLAG_TEST NFLAG,                  MI+EQ+CS+VS, <tst r1,r1>
flg_10:         FLAG_TEST ZFLAG,                  MI+EQ+CS+VS, <tst r1,r1>
flg_11:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,MI+EQ+CC+VC, <tst r1,r1>

                // Test setting C flag to 0
                mov     r1, #0x340000
flg_12:         FLAG_TEST 0,                      CS+VS, <tst r1,r1,LSL #1>
flg_13:         FLAG_TEST NFLAG+ZFLAG+VFLAG,      CS+VC, <tst r1,r1,LSL #1>
flg_14:         FLAG_TEST CFLAG,                  CS+VS, <tst r1,r1,LSL #1>
flg_15:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CS+VC, <tst r1,r1,LSL #1>

                // Test setting C flag to 1
                mov     r1, #NFLAG+ZFLAG+CFLAG+VFLAG
flg_16:         FLAG_TEST 0,                      CC+VS, <tst r1,r1,LSL #1>
flg_17:         FLAG_TEST NFLAG+ZFLAG+VFLAG,      CC+VC, <tst r1,r1,LSL #1>
flg_18:         FLAG_TEST CFLAG,                  CC+VS, <tst r1,r1,LSL #1>
flg_19:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CC+VC, <tst r1,r1,LSL #1>

                // Test setting C flag to 0 and V flag to 0
                mov     r1, #0x340000
flg_1A:         FLAG_TEST 0,                      CS+VS, <cmn r1,r1>
flg_1B:         FLAG_TEST NFLAG+ZFLAG+CFLAG,      CS+VS, <cmn r1,r1>
flg_1C:         FLAG_TEST VFLAG,                  CS+VS, <cmn r1,r1>
flg_1D:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CS+VS, <cmn r1,r1>

                // Test setting C flag to 1 and Vflag to 0
                mov     r1, #NFLAG+ZFLAG+CFLAG+VFLAG
flg_1E:         FLAG_TEST 0,                      CC+VS, <cmn r1,r1>
flg_1F:         FLAG_TEST NFLAG+ZFLAG+CFLAG,      CC+VS, <cmn r1,r1>
flg_20:         FLAG_TEST VFLAG,                  CC+VS, <cmn r1,r1>
flg_21:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CC+VS, <cmn r1,r1>

                // Test setting C flag to 0 and V flag to 1
                mov     r1, #0x71000000
flg_22:         FLAG_TEST 0,                      CS+VC, <cmn r1,r1>
flg_23:         FLAG_TEST NFLAG+ZFLAG+CFLAG,      CS+VC, <cmn r1,r1>
flg_24:         FLAG_TEST VFLAG,                  CS+VC, <cmn r1,r1>
flg_25:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CS+VC, <cmn r1,r1>

                // Test setting C flag to 1 and V flag to 1
                mov    r1, #0x81000000
flg_26:         FLAG_TEST 0,                      CC+VC, <cmn r1,r1>
flg_27:         FLAG_TEST NFLAG+ZFLAG+CFLAG,      CC+VC, <cmn r1,r1>
flg_28:         FLAG_TEST VFLAG,                  CC+VC, <cmn r1,r1>
flg_29:         FLAG_TEST NFLAG+ZFLAG+CFLAG+VFLAG,CC+VC, <cmn r1,r1>

                cmp     r0, #0x2A
                bne     exit
                add     r11, r11, #1

                // Test relations. Need 5 numbers bigneg, neg, 0,  pos, bigpos
                //                                R5      R4   R3  R2   R1
                mov     r0, #0

                mov     r2, #0xFF00
                mov     r3, #0
                mov     r4, #0xFF000000
                mov     r5, #0x80000000
                subs    r1, r5, #1
                bvc     exit
                bcc     exit

                REL_TEST NE+CC+HI+LT+GT, <cmp r1,r1>
                REL_TEST EQ+CC+LS+LT+LE, <cmp r1,r2>
                REL_TEST EQ+CC+LS+LT+LE, <cmp r1,r3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r1,r4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r1,r5>

                REL_TEST EQ+CS+HI+GE+GT, <cmp r2,r1>
                REL_TEST NE+CC+HI+LT+GT, <cmp r2,r2>
                REL_TEST EQ+CC+LS+LT+LE, <cmp r2,r3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r2,r4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r2,r5>

                REL_TEST EQ+CS+HI+GE+GT, <cmp r3,r1>
                REL_TEST EQ+CS+HI+GE+GT, <cmp r3,r2>
                REL_TEST NE+CC+HI+LT+GT, <cmp r3,r3>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r3,r4>
                REL_TEST EQ+CS+HI+LT+LE, <cmp r3,r5>

                REL_TEST EQ+CC+LS+GE+GT, <cmp r4,r1>
                REL_TEST EQ+CC+LS+GE+GT, <cmp r4,r2>
                REL_TEST EQ+CC+LS+GE+GT, <cmp r4,r3>
                REL_TEST NE+CC+HI+LT+GT, <cmp r4,r4>
                REL_TEST EQ+CC+LS+LT+LE, <cmp r4,r5>

                REL_TEST EQ+CC+LS+GE+GT, <cmp r5,r1>
                REL_TEST EQ+CC+LS+GE+GT, <cmp r5,r2>
                REL_TEST EQ+CC+LS+GE+GT, <cmp r5,r3>
                REL_TEST EQ+CS+HI+GE+GT, <cmp r5,r4>
                REL_TEST NE+CC+HI+LT+GT, <cmp r5,r5>

                // Check cmn
                sub     r3, r3, #1      //  -1
                cmn     r3, #1
                bcc     exit
                bne     exit

                add     r11, r11, #1

                // Check ALU results
                mov     r0, #0          // 0
                ldr     r1, fives       // 0x55..
                ldr     r2, fives+4     // 0xAA..
                ldr     r3, fives+8     // 0xFF..
                ldr     r4, fives+12    // 0x55..+0xFF..
                ldr     r5, fives+16    // 0xAA..+0xFF..

                // Move negated
                mvns    r8, r3
                bne     exit
                mvn     r8, r2
                cmp     r8, r1
                bne     exit
                mvn     r8, r1
                cmp     r8, r2
                bne     exit
                mvn     r8, r0
                cmp     r8, r3
                bne     exit

                // Add
                adds    r8, r0, r0
                bne     exit
                add     r8, r0, r1
                cmp     r8, r1
                bne     exit
                add     r8, r0, r2
                cmp     r8, r2
                bne     exit
                add     r8, r0, r3
                cmp     r8, r3
                bne     exit
                add     r8, r1, r0
                cmp     r8, r1
                bne     exit
                add     r8, r1, r1
                cmp     r8, r2
                bne     exit
                add     r8, r1, r2
                cmp     r8, r3
                bne     exit
                add     r8, r1, r3
                cmp     r8, r4
                bne     exit
                add     r8, r2, r0
                cmp     r8, r2
                bne     exit
                add     r8, r2, r1
                cmp     r8, r3
                bne     exit
                add     r8, r2, r2
                cmp     r8, r2, lsl #1
                bne     exit
                add     r8, r2, r3
                cmp     r8, r5
                bne     exit
                add     r8, r3, r0
                cmp     r8, r3
                bne     exit
                add     r8, r3, r1
                cmp     r8, r4
                bne     exit
                add     r8, r3, r2
                cmp     r8, r5
                bne     exit
                add     r8, r3, r3
                cmp     r8, r3, lsl #1
                bne     exit

                // Check adc
                adds    r8, r3, r3      // Set carry
                adc     r8, r0, r0
                cmp     r8, #1
                bne     exit
                adds    r8, r0, r0
                adcs    r8, r0, r0
                bne     exit

                // Check sub
                sub     r8, r3, r2
                cmp     r8, r1
                bne     exit

                // Check sbc
                sbc     r8, r3, r2
                cmp     r8, r1
                bne     exit

                // Check rsb
                rsb     r8,r2,r3
                cmp     r8,r1
                bne     exit

                // Check rsc
                rsc     r8, r2, r3
                cmp     r8, r1
                bne     exit

                // and
                ands    r8, r0, r0
                bne     exit
                ands    r8, r0, r1
                bne     exit
                ands    r8, r0, r2
                bne     exit
                ands    r8, r0, r3
                bne     exit
                ands    r8, r1, r0
                bne     exit
                and     r8, r1, r1
                cmp     r8, r1
                bne     exit
                ands    r8, r1, r2
                bne     exit
                and     r8, r1, r3
                cmp     r8, r1
                bne     exit
                ands    r8, r2, r0
                bne     exit
                ands    r8, r2, r1
                bne     exit
                and     r8, r2, r2
                cmp     r8, r2
                bne     exit
                and     r8, r2, r3
                cmp     r8, r2
                bne     exit
                ands    r8, r3, r0
                bne     exit
                and     r8, r3, r1
                cmp     r8, r1
                bne     exit
                and     r8, r3, r2
                cmp     r8, r2
                bne     exit
                and     r8, r3, r3
                cmp     r8, r3
                bne     exit

                // or
                orrs    r8,r0,r0
                bne     exit
                orr     r8,r0,r1
                cmp     r8,r1
                bne     exit
                orr     r8,r0,r2
                cmp     r8,r2
                bne     exit
                orr     r8,r0,r3
                cmp     r8,r3
                bne     exit
                orr     r8,r1,r0
                cmp     r8,r1
                bne     exit
                orr     r8,r1,r1
                cmp     r8,r1
                bne     exit
                orr     r8,r1,r2
                cmp     r8,r3
                bne     exit
                orr     r8,r1,r3
                cmp     r8,r3
                bne     exit
                orr     r8,r2,r0
                cmp     r8,r2
                bne     exit
                orr     r8,r2,r1
                cmp     r8,r3
                bne     exit
                orr     r8,r2,r2
                cmp     r8,r2
                bne     exit
                orr     r8,r2,r3
                cmp     r8,r3
                bne     exit
                orr     r8,r3,r0
                cmp     r8,r3
                bne     exit
                orr     r8,r3,r1
                cmp     r8,r3
                bne     exit
                orr     r8,r3,r2
                cmp     r8,r3
                bne     exit
                orr     r8,r3,r3
                cmp     r8,r3
                bne     exit

                // eor
                eors    r8, r0, r0
                bne     exit
                eor     r8, r0, r1
                cmp     r8, r1
                bne     exit
                eor     r8, r0, r2
                cmp     r8, r2
                bne     exit
                eor     r8, r0, r3
                cmp     r8, r3
                bne     exit
                eor     r8, r1, r0
                cmp     r8, r1
                bne     exit
                eors    r8, r1, r1
                bne     exit
                eor     r8, r1, r2
                cmp     r8, r3
                bne     exit
                eor     r8, r1, r3
                cmp     r8, r2
                bne     exit
                eor     r8, r2, r0
                cmp     r8, r2
                bne     exit
                eor     r8, r2, r1
                cmp     r8, r3
                bne     exit
                eors    r8, r2, r2
                bne     exit
                eor     r8, r2, r3
                cmp     r8, r1
                bne     exit
                eor     r8, r3, r0
                cmp     r8, r3
                bne     exit
                eor     r8, r3, r1
                cmp     r8, r2
                bne     exit
                eor     r8, r3, r2
                cmp     r8, r1
                bne     exit
                eors    r8, r3, r3
                bne     exit
                add     r11, r11, #1

                // Decrement loop counter and run again until it reaches zero
                subs    r10, r10, #1
                bne     loop


//-------------------------------------------------------------------------------
// End of test
//-------------------------------------------------------------------------------

exit:
                // Register r11 contains the number of completed parts multiplied
                // by the number of test iterations.  Any failing parts would
                // have branched here before r11 increments to the expected value.
                // Print pass or fail message depending on whether r11 is the
                // expected value.
                mov     r1, #(NUM_PARTS * NUM_ITERS)
                cmp     r1, r11

                ldr     r0, =0x13000000         // Tube address
                ldreq   r1, =test_pass_msg
                ldrne   r1, =test_fail_msg

                // Print loop
print_loop:     ldrb    r2, [r1], #1
                cmp     r2, #0
                beq     print_end
                strb    r2, [r0]
                b       print_loop

print_end:      mov     r2, #0x04
                strb    r2, [r0]
                dsb
end_wfi:        wfi
                b       end_wfi


//-------------------------------------------------------------------------------
// Test data pool
//-------------------------------------------------------------------------------

// Note: the bitwise AND (&) expression in some of the constants below is to
// remove the carry-out that intentionally results from the addition.  This would
// otherwise generate an assembler warning.  Although the addition intentionally
// creates a carry-out only the 32-bit result is needed to check against the
// ALU result from the same addition.
fives:          .word 0x55555555
                .word 0xAAAAAAAA
                .word -1
                .word (0x55555555+0xFFFFFFFF) & 0xFFFFFFFF
                .word (0xAAAAAAAA+0xFFFFFFFF) & 0xFFFFFFFF
                
                .balign 4
test_pass_msg:  .asciz "** TEST PASSED OK **\n"
test_fail_msg:  .asciz "** TEST FAILED **\n"

                .end
