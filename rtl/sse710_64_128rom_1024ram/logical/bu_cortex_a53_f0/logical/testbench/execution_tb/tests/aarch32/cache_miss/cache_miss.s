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
//   Data is loaded from the data pool after cleaning and invalidating the
//   caches to force a cache miss.
//
//   This file contains the function that implements the test code plus the
//   literal data pools that the test code uses.
//-------------------------------------------------------------------------------

// Enable UAL syntax
.syntax unified

                .section testcode, "ax", %progbits
                .code 32
                .eabi_attribute Tag_ABI_align_preserved, 1

//------------------------------------------------------------------------------
// PMU events
//------------------------------------------------------------------------------

.equ PMU_DCACHE_MISS_CNTR,       0x0  // Event counter to use
.equ PMU_EVENT_L1D_CACHE_REFILL, 0x3  // Event type for this event


//------------------------------------------------------------------------------
// Test code
//
//   run_test is a function to be called from C.
//
//     Arguments: number of iterations passed in r0
//     Returns:   number of D cache misses in r0
//------------------------------------------------------------------------------

.global run_test
.type   run_test, %function

run_test:
                //-----------------------------------------
                // Preamble
                //-----------------------------------------

                // First, stack registers used for local variables.
                // Note r0-r3 don't need to be stacked according to the ARM
                // procedure call standard.  We also don't need to stack the
                // link register because this is a leaf function.  Therefore
                // only r4 needs to be stacked.
                push    {r4}
                mov     r4, r0  // Back up argument register for later

                //-----------------------------------------
                // Set up performance monitors
                //-----------------------------------------

                // Clear all counters
                mrc     p15, 0, r0, c9, c12, 0  // Read PMCR
                bic     r0, r0, #0xF            // Clear PMCR.{D,C,P,E}
                mcr     p15, 0, r0, c9, c12, 0  // Write PMCR
                isb

                // Set up counter for D cache miss
                mov     r1, #PMU_DCACHE_MISS_CNTR
                mcr     p15, 0, r1, c9, c12, 5  // Write PMSELR
                mov     r1, #PMU_EVENT_L1D_CACHE_REFILL
                mcr     p15, 0, r1, c9, c13, 1  // Write PM0EVTYPER

                // Clear overflow status and enable
                ldr     r1, =0x80000001
                mcr     p15, 0, r1, c9, c12, 3  // Write PMOVSR
                mcr     p15, 0, r1, c9, c12, 1  // Write PMCNTENSET

                // Reset and enable counters
                orr     r0, r0, #0x7            // Set PMCR.{C,P,E}
                mcr     p15, 0, r0, c9, c12, 0  // Write PMCR
                isb


                //-----------------------------------------
                // Main test code
                //-----------------------------------------

loop:           ldr     r0, =data_pool1
                ldr     r1, =data_pool2
                ldr     r2, =data_pool3

                str     r2, [r1]
                str     r1, [r0]

                mcr     p15, 0, r0, c7, c14, 1  // DCCIMVAC
                mcr     p15, 0, r1, c7, c14, 1
                mcr     p15, 0, r2, c7, c14, 1
                dsb

                ldr     r1, [r0]
                ldr     r2, [r1]
                ldr     r3, [r2]

                add     r3, r3, #0x0
                add     r1, r1, r3
                subs    r4, r4, #0x1
                bne     loop


                //-----------------------------------------
                // Loops complete - read event counters
                //-----------------------------------------

done:
                // Disable counters
                mrc     p15, 0, r0, c9, c12, 0  // Read PMCR
                bic     r0, r0, #0x1
                mcr     p15, 0, r0, c9, c12, 0  // Write PMCR

                // Read event counter into r0 to form the return value
                mov     r0, #PMU_DCACHE_MISS_CNTR
                mcr     p15, 0, r0, c9, c12, 5  // Write PMSELR
                mrc     p15, 0, r0, c9, c13, 2  // Read PMXEVCNTR into r0


                //-----------------------------------------
                // Function return
                //-----------------------------------------

                pop     {r4}    // Restore used registers
                bx      lr      // Return


//-------------------------------------------------------------------------------
// Data pool
//-------------------------------------------------------------------------------

                .section datapools, "aw", %progbits
                .balign 64

data_pool1:     .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555
                .word 0xAAAAAAAA
                .word 0x55555555

                .balign 64

data_pool2:     .word 0x00010000
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000
                .word 0xFFFFFFFF
                .word 0x00000000

                .balign 64

data_pool3:     .word 0x00000000
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA
                .word 0xDEADCAFE
                .word 0xEAEAEAEA

                .end

