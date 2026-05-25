// -----------------------------------------------------------------------------
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited.
//
//             (C) COPYRIGHT 2013-2014 ARM Limited.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited.
//
//       SVN Information
//
//       Checked In          : $Date: 2014-07-25 11:01:14 +0100 (Fri, 25 Jul 2014) $
//
//       Revision            : $Revision: 285802 $
//
//       Release Information : CORTEXA53-r0p4-00rel0
// -----------------------------------------------------------------------------
//
#include "cx_generic.h"

void SelectCPU(void)
{
  // This function is SoC specific and must be modified to suit your system.
  // This function must compile for all CPU architectures in your system.
  // This function must return only if the CPU executing is the CPU
  // specified by "#define CPU <n>" during compilation.
  //
  // It may be necessary to use System-specific knowledge to identify the executing CPU.
  // It may also be necessary to identify the CPU based on the specific image being executed
  // as specified by "#define TESTIMAGE<n>" or "#define TESTIMAGECXDT"

  //
  // CXDT is a testbench component so never shares a memory image with any other CPU
  //
#ifdef TESTIMAGECXDT
  // This is the CXDT's test image
  #if (CXDT == 1)
    return;
  #else
    while (1);
  #endif
#else
  //
  // System Specific code follows
  //

  //Code for Cortex-A53 MPcore
  #if((TESTIMAGE == 0) && (CPUEXE == 1))
    #if (defined(__TARGET_ARCH_AARCH64) || defined(__aarch64__)) //AARCH64 state
      uint64_t cpunum = 0;
      asm volatile("mrs %0, mpidr_el1":"=r"(cpunum));
    #else //AARCH32 state
      uint32_t cpunum = 0;
      asm volatile("mrc p15,0,%0,c0,c0,5":"=r"(cpunum));
    #endif

    cpunum = cpunum & 0x00ff; //MPIDR

    // This is IMAGE0 for CPU 0-3
    if (cpunum == CPU)
      return;     //Return if current CPU is used for running the test code
    else
      while(1);   //Stay in IDLE if current CPU is not used for running the test code
  #else
    while(1);
  #endif
#endif
}
