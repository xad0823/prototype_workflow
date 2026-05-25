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

                .section testcode, "ax", %progbits

                .global bootcode
bootcode:
                // Initialise the register file as a safeguard against
                // spurious X propagation.
                mov     x0,  xzr
                mov     x1,  xzr
                mov     x2,  xzr
                mov     x3,  xzr
                mov     x4,  xzr
                mov     x5,  xzr
                mov     x6,  xzr
                mov     x7,  xzr
                mov     x8,  xzr
                mov     x9,  xzr
                mov     x10, xzr
                mov     x11, xzr
                mov     x12, xzr
                mov     x13, xzr
                mov     x14, xzr
                mov     x15, xzr
                mov     x16, xzr
                mov     x17, xzr
                mov     x18, xzr
                mov     x19, xzr
                mov     x20, xzr
                mov     x21, xzr
                mov     x22, xzr
                mov     x23, xzr
                mov     x24, xzr
                mov     x25, xzr
                mov     x26, xzr
                mov     x27, xzr
                mov     x28, xzr
                mov     x29, xzr
                mov     x30, xzr
                mov     sp,  x0

                // Only CPU0 prints the message and all other CPUs enter a
                // WFI state.  A CPU can determine its number within a cluster
                // reading bits[7:0] of the MPIDR (Affinity level 0 field).
                mrs     x0, mpidr_el1           // x0 == MPIDR
                and     x0, x0, #0xFF           // x0 == Affinity level 0
                cbnz    x0, wfi_spin            // WFI if not CPU0

                // CPU0:
                // Write the text one byte at a time to the tube address
                mov     x0, #0x13000000 // Tube address
                adr     x1, message

loop:           ldrb    w2, [x1], #1
                cbz     w2, end         // Branch to end on NULL byte
                strb    w2, [x0]
                b       loop

end:            mov     w2, #0x04       // EOT character
                strb    w2, [x0]
                dsb     sy

wfi_spin:       wfi
                b       wfi_spin

// The message to print.  It is NULL-terminated so that the print loop
// can detect the end of the string.
                .balign 4 
message:        .asciz "Hello 64-bit World!\n\n** TEST PASSED OK **\n"
                .end
