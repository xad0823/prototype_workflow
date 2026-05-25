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
//   The main work for this test is performed in an architecture-specific
//   function.  This file simply uses printf to print the result of that
//   function.
//-------------------------------------------------------------------------------

#include <stdio.h>
#include <string.h>
#include "benchmark.h"

// Function prototype for run_test()
int run_test (int num_iters);

// Main
int main ()
{
  int dcache_misses;

  // Main test routine
  dcache_misses = run_test(ITERATIONS);

  // Print number of cache misses
  printf("Number of D cache misses: %d\n", dcache_misses);

  // Pass if there were D cache misses, fail otherwise
  if (dcache_misses > 0) printf("** TEST PASSED OK **\n");
  else                   printf("** TEST FAILED **\n");

  return 0;
}

