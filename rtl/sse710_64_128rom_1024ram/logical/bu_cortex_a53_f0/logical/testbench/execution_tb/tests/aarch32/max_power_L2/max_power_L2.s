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

// Enable UAL syntax
.syntax unified

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
.global fiq_handler

fiq_handler:
                mrc     p15, 0, r8, c0, c0, 5   // Read MPIDR
                tst     r8, #0xFF
                bne     fiq_loop

                ldr     r8, =0x13000000         // Trickbox base
                str     r8, [r8, #0x10]         // Clear FIQ (nb. write value ignored)

                // Poll the ISR register until the FIQ has cleared
fiq_loop:       mrc     p15, 0, r9, c12, c1, 0  // r9 == ISR
                tst     r9, #1<<6
                bne     fiq_loop

                // Return using ERET.  This test uses WFI spin code (a WFI
                // instruction followed by a branch back to the WFI) to force
                // the CPUs to remain idle until the test breaks them out of the
                // WFI spin.  For FIQ exceptions the LR has an offset of +4
                // applied, which means that this return will take us to the
                // instruction following the WFI spin branch and hence break us
                // out of the WFI spin.
                eret

//------------------------------------------------------------------------------
// Main test code
//------------------------------------------------------------------------------

test_start:
                mrc     p15, 0, r12, c0, c0, 5  // Read MPIDR
                ands    r12, r12, #0xFF         // r12 == CPU number
                bne     setup_power

                ldr     r0, =banner_msg
                bl      print

                // Bring 128K of data starting at L1_MEMORY into the L1
                mov     r9, #128*1024
                ldr     r10, =L1_MEMORY

preload_loop:
                pldw    [r10]
                pldw    [r10, #0x40]
                pldw    [r10, #0x80]
                pldw    [r10, #0xc0]
                pldw    [r10, #0x100]
                pldw    [r10, #0x140]
                pldw    [r10, #0x180]
                pldw    [r10, #0x1c0]

                add     r10, r10, #0x200
                subs    r9, r9, #0x200
                bne     preload_loop

                // Invalidate the L1 data cache back to L2
                mov     r0, #0                 // Select L1 D-cache
                mcr     p15, 2, r0, c0, c0, 0
                isb
                mrc     p15, 1, r0, c0, c0, 0
                ubfx    r0, r0, #13, #15
                mov     r1, #0
inv_loop:
                orr     r2, r1, #0x40000000
                orr     r3, r1, #0x80000000
                orr     r4, r1, #0xC0000000
                mcr     p15, 0, r1, c7, c14, 2
                mcr     p15, 0, r2, c7, c14, 2
                mcr     p15, 0, r3, c7, c14, 2
                mcr     p15, 0, r4, c7, c14, 2
                add     r1, r1, #0x40
                subs    r0, r0, #1
                bcs     inv_loop

                ldr     r0, =memcpy_start_msg
                bl      print

                // Set up a FIQ to wake all CPUs from WFI.  When the other CPUs
                // wake they will branch to setup_power, so the following code
                // is only executed by CPU0.
                ldr     r9, =0x13000000         // Trickbox base
                mov     r10, #0x400             // FIQ schedule value
                .ifdef BIGEND
                rev     r10, r10
                .endif
                str     r10, [r9, #0x8]         // Store to FIQ counter

                // CPU0 waits here for the interrupt.  Other CPUs are already
                // waiting in WFI in the boot code.  After the interrupt all CPUs
                // will execute the setup code below (CPUs 1-3 will first branch
                // to test_start and then the setup code).
cpu0_wait:      wfi
                b       cpu0_wait

setup_power:
                // Mask FIQ interrupts, so that the interrupt will wake the core
                // from WFI, but not cause an exception
                cpsid   f

                mov     r8, #2                  // Set the number of loops

                ldr     r10, =L1_MEMORY
                add     r10, r10, r12, LSL 15   // Dedicated L1_MEMORY address space for each CPU
                add     r11, r10, #8192

//-------------------------------------------------------------------------------
// Main power loop
//-------------------------------------------------------------------------------

next_iter_loop:
                mov     r9, #8192
                ldr     r0, =0x13000000         // Trickbox base

                // Now CPU0 programs the trickbox to schedule another FIQ and
                // all CPUs enter WFI.  The CPUs will then all wake and execute
                // the L2 power loop at the same time.
                cmp     r12, #0x0
                bne     all_wait

                mov     r1, #0x400              // FIQ schedule value
                .ifdef BIGEND
                rev     r1, r1
                .endif
                str     r1, [r0, #0x8]          // Store to FIQ counter

all_wait:       wfi
                str     r0, [r0, #0x10]         // Clear FIQ (nb. write value ignored)

                // Begin the L2 maximum power sequence
mem_copy_loop:
                ldmia   r10!, {r0, r1, r2, r3}
                stmia   r11!, {r0, r1, r2, r3}

                ldmia   r10!, {r0, r1, r2, r3}
                stmia   r11!, {r0, r1, r2, r3}

                ldmia   r10!, {r0, r1, r2, r3}
                stmia   r11!, {r0, r1, r2, r3}

                ldmia   r10!, {r0, r1, r2, r3}
                stmia   r11!, {r0, r1, r2, r3}

                subs    r9, r9, #0x40
                bne     mem_copy_loop


                add     r10, r10, #8192
                add     r11, r11, #8192

                subs    r8, r8, #1
                bne     next_iter_loop

//-------------------------------------------------------------------------------
// End of test
//-------------------------------------------------------------------------------

                // All CPUs except CPU0 enter WFI, while CPU0 ends the test
                cmp     r12, #0x0
                bne     end_wfi

                ldr     r0, =memcpy_end_msg
                bl      print

                ldr     r0, =pass_msg
                bl      print

end:            ldr     r0, =0x13000000         // Tube address
                mov     r2, #4                  // EOT
                strb    r2, [r0]

end_wfi:        wfi
                b       end_wfi

//-------------------------------------------------------------------------------
// Subroutines
//-------------------------------------------------------------------------------

                // Routine to print a string at the address in r0.
.type print, %function
print:          mov     r1, #0x13000000        // Tube address
                ldrb    r2, [r0], #0x1
                cmp     r2, #0x0
                strbne  r2, [r1]
                bne     print
                mov     r2, #'\n'
                strb    r2, [r1]
                bx      lr                     // Return on NULL character


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
