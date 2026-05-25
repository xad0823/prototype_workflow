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
//-----------------------------------------------------------------------------

// Enable UAL syntax
.syntax unified

                .section testcode, "ax", %progbits
                .global bootcode

bootcode:
                // Initialise the register file as a safeguard against
                // spurious X propagation.
                mov     r0,  #0
                mov     r1,  #0
                mov     r2,  #0
                mov     r3,  #0
                mov     r4,  #0
                mov     r5,  #0
                mov     r6,  #0
                mov     r7,  #0
                mov     r8,  #0
                mov     r9,  #0
                mov     r10, #0
                mov     r11, #0
                mov     r12, #0
                mov     r14, #0
                mov     r13, r0

                // Only CPU0 prints the message and all other CPUs enter a
                // WFI state.  A CPU can determine its number within a cluster
                // reading bits[7:0] of the MPIDR (Affinity level 0 field).
                mrc     p15, 0, r0, c0, c0, 5   // r0 == MPIDR
                ands    r0, r0, #0xFF           // r0 == Affinity level 0
                bne     wfi_spin                // WFI if not CPU0

                // CPU0:
                // Write the text one byte at a time to the tube address
                ldr     r0, =0x13000000 // Tube address
                ldr     r1, =message

loop:           ldrb    r2, [r1], #1
                cmp     r2, #0
                beq     end
                strb    r2, [r0]
                b       loop

end:            mov     r2, #0x04       // EOT character
                strb    r2, [r0]
                dsb

wfi_spin:       wfi
                b       wfi_spin

// The message to print.  It is NULL-terminated so that the print loop
// can detect the end of the string.
                .balign 4
message:        .asciz "Hello World!\n\n** TEST PASSED OK **\n"

                .end
