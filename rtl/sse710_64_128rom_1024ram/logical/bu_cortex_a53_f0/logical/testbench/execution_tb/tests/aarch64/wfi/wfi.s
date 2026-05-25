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


                .section testcode, "ax", %progbits

                .global test_start

test_start:
                // Schedule a FIQ from the trickbox
                mov     x0, #0x13000000 // Val base
                mov     w1, #0x1800     // Counter value
                .ifdef BIGEND
                rev     w1, w1
                .endif
                str     w1, [x0, #0x8]  // Store to FIQ counter

                // Enter WFI. Issue a DSB first to ensure the trickbox
                // has been written.
                dsb     sy
wfi_spin:       wfi
                b       wfi_spin


                // FIQ handler
                .global curr_el_spx_fiq_vector
curr_el_spx_fiq_vector:
                // Make sure CPU0 came out of WFI.  CPU0 ends the simulation
                // and other CPUs do nothing.
                mrs     x0, mpidr_el1
                ands    x0, x0, #0xFF   // x0 == CPU number
                bne     fiq_end_wfi

                // Clear the FIQ
                mov     x0, #0x13000000
                str     w0, [x0, #0x10] // Any value clears

                // Print test passed message
                adr     x1, message
fiq_print_loop: ldrb    w2, [x1], #1
                cbz     w2, fiq_end
                strb    w2, [x0]
                b       fiq_print_loop

fiq_end:        mov     w2, #0x04       // EOT character
                strb    w2, [x0]
                dsb     sy
fiq_end_wfi:    wfi
                b       fiq_end_wfi

// The message to print.  It is NULL-terminated so that the print loop
// can detect the end of the string.
                .balign 4
message:        .asciz "** TEST PASSED OK **\n"

                .end
