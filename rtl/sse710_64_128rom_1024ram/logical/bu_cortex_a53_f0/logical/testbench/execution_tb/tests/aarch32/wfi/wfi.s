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
//      Checked In          : $Date: 2014-07-25 09:52:11 +0100 (Fri, 25 Jul 2014) $
//
//      Revision            : $Revision: 285788 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-------------------------------------------------------------------------------
// Description:
//
//   The CPU programs the trickbox to schedule a FIQ, and then enters WFI state.
//   If the FIQ succeeds in waking the CPU then the test passes.
//-------------------------------------------------------------------------------


// Enable UAL syntax
.syntax unified

                .section testcode, "ax", %progbits

                .global test_start

test_start:
                // Schedule a FIQ from the trickbox
                ldr     r0, =0x13000000 // Val base
                mov     r1, #0x1800     // Counter value
                .ifdef BIGEND
                rev     r1, r1
                .endif
                str     r1, [r0, #0x8]  // Store to FIQ counter

                // Enter WFI. Issue a DSB first to ensure the trickbox
                // has been written.
                dsb
wfi:            wfi
                b       end_wfi


                // FIQ handler
                .global fiq_handler
fiq_handler:
                // Make sure CPU0 came out of WFI.  CPU0 ends the simulation
                // and other CPUs do nothing.
                mrc     p15, 0, r0, c0, c0, 5   // Read MPIDR
                ands    r0, r0, #0xFF           // r0 == CPU number
                bne     end_wfi

                // Clear the FIQ
                ldr     r0, =0x13000000
                str     r0, [r0, #0x10]

                // Print test passed message
                ldr     r1, =message
loop:           ldrb    r2, [r1], #1
                cmp     r2, #0
                beq     end
                strb    r2, [r0]
                b       loop

end:            mov     r2, #0x04       // EOT character
                strb    r2, [r0]
                dsb
end_wfi:        wfi
                b       end_wfi

// The message to print.  It is NULL-terminated so that the print loop
// can detect the end of the string.
                .balign 4
message:        .asciz "** TEST PASSED OK **\n"
                .end
