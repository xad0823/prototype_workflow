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

                .section testcode, "ax", %progbits

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

                // This function only uses registers that can be used as
                // temporary registers in the AArch64 procedure call standard.
                // Therefore no registers need to be stored on the stack.
                // The link register does not need to be saved because this
                // is a leaf function.

                mov     x9, x0  // Backup number of iterations

                //-----------------------------------------
                // Set up performance monitors
                //-----------------------------------------

                // Clear all counters
                mrs     x0, pmcr_el0            // Read PMCR
                bic     x0, x0, #0xF            // Clear PMCR.{D,C,P,E}
                msr     pmcr_el0, x0            // Write PMCR
                isb

                // Set up counter for D cache miss
                mov     x1, #PMU_DCACHE_MISS_CNTR
                msr     pmselr_el0, x1          // Write PMSELR
                mov     x1, #PMU_EVENT_L1D_CACHE_REFILL
                msr     pmxevtyper_el0, x1      // Write PM0EVTYPER

                // Clear overflow status and enable
                ldr     x1, =0x80000001
                msr     pmovsclr_el0, x1        // Write PMOVSCLR
                msr     pmcntenset_el0, x1      // Write PMCNTENSET

                // Reset and enable counters
                orr     x0, x0, #0x7            // Set PMCR.{C,P,E}
                msr     pmcr_el0, x0            // Write PMCR
                isb


                //-----------------------------------------
                // Main test code
                //-----------------------------------------

loop:           adr     x0, data_pool1
                adr     x1, data_pool2
                adr     x2, data_pool3

                str     w2, [x1]
                str     w1, [x0]

                // Clean and invalidate
                dc      CIVAC, x0
                dc      CIVAC, x1
                dc      CIVAC, x2
                dsb     sy

                ldr     w1, [x0]
                ldr     w2, [x1]
                ldr     w3, [x2]

                add     w3, w3, #0x0
                add     w1, w1, w3
                subs    x9, x9, #0x1
                bne     loop


                //-----------------------------------------
                // Loops complete - read event counters
                //-----------------------------------------

done:
                // Disable counters
                mrs     x0, pmcr_el0            // Read PMCR
                bic     x0, x0, #0x1
                msr     pmcr_el0, x0            // Write PMCR

                // Read event counter into r0 to form the return value
                mov     x0, #PMU_DCACHE_MISS_CNTR
                msr     pmselr_el0, x0          // Write PMSELR
                mrs     x0, pmxevcntr_el0       // Read PM0EVCNTR into x0


                //-----------------------------------------
                // Function return
                //-----------------------------------------

                ret


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

