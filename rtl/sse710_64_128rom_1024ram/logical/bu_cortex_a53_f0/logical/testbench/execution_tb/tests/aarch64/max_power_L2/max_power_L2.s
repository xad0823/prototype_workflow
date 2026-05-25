//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-25 10:06:39 +0100 (Fri, 25 Jul 2014) $
//
//      Revision            : $Revision: 285790 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-------------------------------------------------------------------------------
// Description:
//
//   L2 maximum power test
//-------------------------------------------------------------------------------

                .section testcode, "ax", %progbits

                .global test_start

//------------------------------------------------------------------------------
// Constants
//------------------------------------------------------------------------------

.equ L1_MEMORY,        0x00500000  // L1 memory address

//-------------------------------------------------------------------------------
// FIQ handler
//
//   This test uses a FIQ to release CPUs from WFI.  The FIQ handler simply
//   clears the FIQ using the trickbox and returns.
//-------------------------------------------------------------------------------

// Make fiq_handler visible to linker so that it can override the default handler
.global curr_el_spx_fiq_vector
curr_el_spx_fiq_vector:
                mrs     x20, mpidr_el1          // Read MPIDR
                tst     w20, #0xFF
                b.ne    fiq_loop

                ldr     x20, =0x13000000         // Trickbox base
                str     w20, [x20, #0x10]        // Clear FIQ (nb. write value ignored)

                // Poll the ISR register until the FIQ has cleared
fiq_loop:       mrs     x21, isr_el1             // r21 == ISR
                tbnz    x21, #6, fiq_loop

                // Return using ERET.  This test uses WFI spin code (a WFI
                // instruction followed by a branch back to the WFI) to force
                // the CPUs to remain idle until the test breaks them out of the
                // WFI spin.  For asynchronous exceptions such as FIQ, the ELR
                // points to the first instruction that has not been fully
                // executed, which in the WFI spin loop is the branch back to
                // the WFI instruction.  Therefore we add 4 to the ELR before
                // returning, so that we break out of the loop and execute the
                // first instruction following the loop.
                mrs     x21, elr_el3
                add     x21, x21, #4
                msr     elr_el3, x21
                eret

//-------------------------------------------------------------------------------
// Main test code
//-------------------------------------------------------------------------------

test_start:
                mrs     x12, mpidr_el1          // Read MPIDR
                ands    x12, x12, #0xFF         // x12 == CPU number
                b.ne    setup_power

                adr     x0, banner_msg
                bl      print

                // Bring 128K of data starting at L1_MEMORY into the L1
                mov     w9, #128*1024
                ldr     x10, =L1_MEMORY

preload_loop:
                prfm    pstl1keep, [x10]
                prfm    pstl1keep, [x10, #0x40]
                prfm    pstl1keep, [x10, #0x80]
                prfm    pstl1keep, [x10, #0xc0]
                prfm    pstl1keep, [x10, #0x100]
                prfm    pstl1keep, [x10, #0x140]
                prfm    pstl1keep, [x10, #0x180]
                prfm    pstl1keep, [x10, #0x1c0]

                add     x10, x10, #0x200
                subs    w9, w9, #0x200
                b.ne    preload_loop

                // Invalidate the L1 data cache back to L2
                mov     w0, #0                 // Select L1 D-cache
                msr     csselr_el1, x0
                isb
                mrs     x0, ccsidr_el1
                ubfx    w0, w0, #13, #15
                mov     w1, #0
inv_loop:
                orr     w2, w1, #0x40000000
                orr     w3, w1, #0x80000000
                orr     w4, w1, #0xC0000000
                dc      cisw, x1
                dc      cisw, x2
                dc      cisw, x3
                dc      cisw, x4
                add     w1, w1, #0x40
                subs    w0, w0, #1
                b.cs    inv_loop

                adr     x0, memcpy_start_msg
                bl      print

                // Set up a FIQ to wake all CPUs from WFI.  When the other CPUs
                // wake they will branch to setup_power, so the following code
                // is only executed by CPU0.
                ldr     x0, =0x13000000         // Trickbox base
                mov     w1, #0x400              // Counter value
                .ifdef BIGEND
                rev     w1, w1
                .endif
                str     w1, [x0, #0x8]          // Store to FIQ counter

                // CPU0 waits here for the interrupt.  Other CPUs are already
                // waiting in WFI in the boot code.  After the interrupt all CPUs
                // will execute the setup code below (CPUs 1-3 will first branch
                // to test_start and then the setup code).
cpu0_wait:      wfi
                b       cpu0_wait

setup_power:
                // Mask FIQ interrupts, so that the interrupt will wake the core
                // from WFI, but not cause an exception
                msr     daifset, #1

                mov     w8, #2                  // Set the number of loops

                ldr     x10, =L1_MEMORY
                add     x10, x10, x12, LSL 15   // Dedicated L1_MEMORY address space for each CPU
                add     x11, x10, #8192

//-------------------------------------------------------------------------------
// Main power loop
//-------------------------------------------------------------------------------

next_iter_loop:
                mov     w9, #8192
                ldr     x0, =0x13000000         // Trickbox base

                // Now CPU0 programs the trickbox to schedule another FIQ and
                // all CPUs enter WFI.  The CPUs will then all wake and execute
                // the L2 power loop at the same time.
                cbnz    x12, all_wait

                mov     w1, #0x400              // Counter value
                .ifdef BIGEND
                rev     w1, w1
                .endif
                str     w1, [x0, #0x8]          // Store to FIQ counter

all_wait:       wfi
                str     w0, [x0, #0x10]         // Clear FIQ (nb. write value ignored)

                // Begin the L2 maximum power sequence
mem_copy_loop:
                ldp x0, x1, [x10], #0x10
                stp x0, x1, [x11], #0x10

                ldp x0, x1, [x10], #0x10
                stp x0, x1, [x11], #0x10

                ldp x0, x1, [x10], #0x10
                stp x0, x1, [x11], #0x10

                ldp x0, x1, [x10], #0x10
                stp x0, x1, [x11], #0x10

                subs    w9, w9, #0x40
                b.ne    mem_copy_loop


                add     x10, x10, #8192
                add     x11, x11, #8192

                subs    w8, w8, #1
                b.ne    next_iter_loop

//-------------------------------------------------------------------------------
// End of test
//-------------------------------------------------------------------------------

                // All CPUs except CPU0 enter WFI, while CPU0 ends the test
                cbnz    x12, end_wfi

                adr     x0, memcpy_end_msg
                bl      print

                adr     x0, pass_msg
                bl      print

end:            ldr     x0, =0x13000000         // Tube address
                mov     w2, #0x04               // EOT
                strb    w2, [x0]

end_wfi:        wfi
                b       end_wfi

//-------------------------------------------------------------------------------
// Subroutines
//-------------------------------------------------------------------------------

                // Routine to print a string at the address in r0.
.type print, %function
print:          mov     x1, #0x13000000         // Tube address
                ldrb    w2, [x0], #0x1
                cbz     w2, 1f
                strb    w2, [x1]
                b       print
1:
                mov     w2, #'\n'
                strb    w2, [x1]
                ret                             // Return on NULL character


//-------------------------------------------------------------------------------
// Data pool
//-------------------------------------------------------------------------------

                      .section datapools, "aw", %progbits

                      .balign 4

banner_msg:           .asciz "Start L2 maximum power test"
memcpy_start_msg:     .asciz "Start memcopy"
memcpy_end_msg:       .asciz "End memcopy"
pass_msg:             .asciz "** TEST PASSED OK **"

                      .end
