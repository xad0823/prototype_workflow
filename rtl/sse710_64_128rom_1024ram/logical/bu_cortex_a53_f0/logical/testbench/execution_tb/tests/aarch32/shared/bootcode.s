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

                .section boot, "ax", %progbits
                .global bootcode

// Load stack definitions
.include "boot_defs.hs"

//-------------------------------------------------------------------------------
// Generic boot code
//-------------------------------------------------------------------------------

bootcode:
                // Initialise the register bank
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

                // Initialize the stack pointer
                ldr     r13, =stack_top
                add     r13, r13, #4
                mrc     p15, 0, r0, c0, c0, 5   // MPIDR
                and     r0, r0, #0xff           // r0 == CPU number
                mov     r2, #CPU_STACK_SIZE
                mul     r1, r0, r2
                sub     r13, r13, r1


                // Enable NEON and initialize the register bank if NEON
                // is present.  Test this by attempting to enable CP10 and
                // CP11 in the CPACR and read back the value to see if
                // bit[20] is set.
                mov     r0, #(0xFF << 20)
                mcr     p15, 0, r0, c1, c0, 2   // Write CPACR
                mrc     p15, 0, r0, c1, c0, 2   // Read CPACR
                ubfx    r0, r0, #20, #1         // Get bit[20]
                cmp     r0, #1
                bne     ttb_setup               // Skip if no NEON

                mrc     p15, 0, r1, c1, c0, 2
                orr     r1, r1, #(0xF << 20)
                mcr     p15, 0, r1, c1, c0, 2
                mov     r1, #(0x1 << 30)
                isb
                vmsr    fpexc, r1

                mov             r1, #0
                mov             r2, #0
                vmov.f64        d0, r1, r2
                vmov.f64        d1, d0
                vmov.f64        d2, d0
                vmov.f64        d3, d0
                vmov.f64        d4, d0
                vmov.f64        d5, d0
                vmov.f64        d6, d0
                vmov.f64        d7, d0
                vmov.f64        d8, d0
                vmov.f64        d9, d0
                vmov.f64        d10, d0
                vmov.f64        d11, d0
                vmov.f64        d12, d0
                vmov.f64        d13, d0
                vmov.f64        d14, d0
                vmov.f64        d15, d0
                vmov.f64        d16, d0
                vmov.f64        d17, d0
                vmov.f64        d18, d0
                vmov.f64        d19, d0
                vmov.f64        d20, d0
                vmov.f64        d21, d0
                vmov.f64        d22, d0
                vmov.f64        d23, d0
                vmov.f64        d24, d0
                vmov.f64        d25, d0
                vmov.f64        d26, d0
                vmov.f64        d27, d0
                vmov.f64        d28, d0
                vmov.f64        d29, d0
                vmov.f64        d30, d0
                vmov.f64        d31, d0

                // Create page tables
ttb_setup:      ldr     r1, =ttb0_base
                mcr     p15, 0, r1, c2, c0, 0   // TTBR0

                // Set all domains as manager
                ldr     r1, =0xFFFFFFFF
                mcr     p15, 0, r1, c3, c0, 0   // DACR

                // Enable caches and MMU
                mrc     p15, 0, r1, c1, c0, 0   // SCTLR
                orr     r1, r1, #(0x1 << 2)     // C bit (data cache)
                orr     r1, r1, #(0x1 << 12)    // I bit (instruction cache)
                orr     r1, r1, #0x1            // M bit (MMU)
                mcr     p15, 0, r1, c1, c0, 0

                // Ensure all writes to system registers have taken place
                dsb
                isb

                // Enable interrupts
                cpsie   if

                .ifdef IK_MODE
                // All CPUs start the test code. The select_cpu function in the integration kit
                // will determine which CPU run 
                b       cpu_start
                .else
                // Only CPU0 starts the test code.  Other CPUs sleep and will be enabled
                // in individual tests where required.
                mrc     p15, 0, r0, c0, c0, 5   // Read MPIDR
                ands    r0, r0, #0xFF           // r0 == CPU number
                beq     cpu_start
                .endif

                // If the CPU is not CPU0 then enter WFI
wfi_loop:       wfi
                b       wfi_loop


//-------------------------------------------------------------------------------
// Start the test
//-------------------------------------------------------------------------------
                // If IK_MODE is set, all CPUs can reach this cpu_start label. 
                // If IK_MODE is not set (which is default for execution TB), only 
                // CPU0 reaches this label (the others are in WFI).  The label
                // for the start of the test depends on whether it's a C or an
                // assember test.  Weakly import the labels for each and to
                // determine the correct one.  Note that the linker translates
                // any branches to non-existant weakly-imported labels to NOPs.
cpu_start:
                .weak _arm_start
                .weak test_start

                b       _arm_start
                b       test_start

                .end
                .balign 4
