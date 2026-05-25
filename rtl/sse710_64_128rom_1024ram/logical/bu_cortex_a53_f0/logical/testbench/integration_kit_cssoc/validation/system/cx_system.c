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
//-----------------------------------------------------------------------------
#include <stdlib.h>
#include "cx_types.h"

////////////////////////////////////////////////////////////////////////////////
//
// CXDT CoreSight System
//
// These declarations describe the SoC under test
//
// Refer to generic/cx_types.h for the definition of each data type
//
////////////////////////////////////////////////////////////////////////////////

//#define CA53_V7_DBG_MAP  //uncomment this line if the Cortex-A53 is configured to use
                           //the legacy V7 debug memory map.
                           //defualt is for V8 debug memory map

////////////////////////////////////////////////////////////////////////////////
//
// DPs and APs - Describe the Protocol, ID, and APs for the DAP
//
////////////////////////////////////////////////////////////////////////////////

csdpinst_t SOC_DPS[] = {

  // "CoreSight JTAG-DP"
  [0] = { .type= JTAG, .targetid= 0x00000000, .targetinstance= 0x0, .finalap= 0, .maxpwrupretries= 0,
        .aps= {
        [0] = { .type= MEMAP, }, // "ARM AMBA APB2/3 Mem-AP r0p4"
              },
        },
};

uint32_t NUM_SOC_DPS = sizeof SOC_DPS / sizeof SOC_DPS[0];


////////////////////////////////////////////////////////////////////////////////
//
// System - CoreSight Components
//
////////////////////////////////////////////////////////////////////////////////

csinst_t SOC_COMPONENTS[] = {
  { .addr= {0, 0, 0x0000000080000000}, .id.peripheralid= 0x0000000000080000, .id.componentid= 0xb105100d, .id.devtype= 0x00, .instname= "dp0_ap000_0x0000000080000000", }, //"(unknown JEP), (unknown PID) (unknown revision), (ROM Table) ***ERROR*** Unrecognised Revision ***ERROR*** Unrecognised Peripheral ID ***ERROR*** Unrecognised Jedec JEP ID"
  #ifdef CA53_V7_DBG_MAP //Legacy V7 debug memory map
  { .addr= {0, 0, 0x0000000080800000}, .id.peripheralid= 0x00000004004bb4a3, .id.componentid= 0xb105100d, .id.devtype= 0x00, .instname= "dp0_ap000_0x0000000080800000", }, //"ARM, Cortex-A53 Integration Level r0p4, (ROM Table)"
  { .addr= {0, 0, 0x0000000080810000}, .id.peripheralid= 0x00000004004bbd03, .id.componentid= 0xb105900d, .id.devtype= 0x15, .instname= "dp0_ap000_0x0000000080810000", }, //"ARM, Cortex-A53 DBG r0p4, (CoreSight Debug Component: Debug Logic, Processor core)"
  { .addr= {0, 0, 0x0000000080811000}, .id.peripheralid= 0x00000004004bb9d3, .id.componentid= 0xb105900d, .id.devtype= 0x16, .instname= "dp0_ap000_0x0000000080811000", }, //"ARM, Cortex-A53 PMU r0p4, (CoreSight Debug Component: Performance Monitor, Associated with a processor)"
  { .addr= {0, 0, 0x0000000080818000}, .id.peripheralid= 0x00000004004bb9a8, .id.componentid= 0xb105900d, .id.devtype= 0x14, .instname= "dp0_ap000_0x0000000080818000", }, //"ARM, Cortex-A53 CTI r0p4, (CoreSight Debug Component: Debug Control, Trigger Matrix)"
  { .addr= {0, 0, 0x000000008081C000}, .id.peripheralid= 0x00000004004bb95d, .id.componentid= 0xb105900d, .id.devtype= 0x13, .instname= "dp0_ap000_0x000000008081C000", }, //"ARM, Cortex-A53 ETM r0p4, (CoreSight Debug Component: Trace Source, Associated with a processor core)"
  #else
  { .addr= {0, 0, 0x0000000080800000}, .id.peripheralid= 0x00000004004bb4a1, .id.componentid= 0xb105100d, .id.devtype= 0x00, .instname= "dp0_ap000_0x0000000080800000", }, //"ARM, Cortex-A53 Integration Level r0p4, (ROM Table)"
  { .addr= {0, 0, 0x0000000080810000}, .id.peripheralid= 0x00000004004bbd03, .id.componentid= 0xb105900d, .id.devtype= 0x15, .instname= "dp0_ap000_0x0000000080810000", }, //"ARM, Cortex-A53 DBG r0p4, (CoreSight Debug Component: Debug Logic, Processor core)"
  { .addr= {0, 0, 0x0000000080820000}, .id.peripheralid= 0x00000004004bb9a8, .id.componentid= 0xb105900d, .id.devtype= 0x14, .instname= "dp0_ap000_0x0000000080820000", }, //"ARM, Cortex-A53 CTI r0p4, (CoreSight Debug Component: Debug Control, Trigger Matrix)"
  { .addr= {0, 0, 0x0000000080830000}, .id.peripheralid= 0x00000004004bb9d3, .id.componentid= 0xb105900d, .id.devtype= 0x16, .instname= "dp0_ap000_0x0000000080830000", }, //"ARM, Cortex-A53 PMU r0p4, (CoreSight Debug Component: Performance Monitor, Associated with a processor)"
  { .addr= {0, 0, 0x0000000080840000}, .id.peripheralid= 0x00000004004bb95d, .id.componentid= 0xb105900d, .id.devtype= 0x13, .instname= "dp0_ap000_0x0000000080840000", }, //"ARM, Cortex-A53 ETM r0p4, (CoreSight Debug Component: Trace Source, Associated with a processor core)"
  #endif
  { .addr= {0, 0, 0x0000000081000000}, .id.peripheralid= 0x00000004004bb912, .id.componentid= 0xb105900d, .id.devtype= 0x11, .instname= "dp0_ap000_0x0000000081000000", }, //"ARM, CoreSight Trace Port Interface Unit (TPIU) r4, (CoreSight Debug Component: Trace Sink, Trace port)"
  { .addr= {0, 0, 0x0000000081001000}, .id.peripheralid= 0x00000004003bb907, .id.componentid= 0xb105900d, .id.devtype= 0x21, .instname= "dp0_ap000_0x0000000081001000", }, //"ARM, CoreSight Embedded Trace Buffer (ETB) r3, (CoreSight Debug Component: Trace Sink, Buffer)"
  { .addr= {0, 0, 0x0000000081002000}, .id.peripheralid= 0x00000004001bb909, .id.componentid= 0xb105900d, .id.devtype= 0x22, .instname= "dp0_ap000_0x0000000081002000", }, //"ARM, CoreSight ATB Replicator r1, (CoreSight Debug Component: Trace Link, Filter)"
  { .addr= {0, 0, 0x0000000081003000}, .id.peripheralid= 0x00000004004bb906, .id.componentid= 0xb105900d, .id.devtype= 0x14, .instname= "dp0_ap000_0x0000000081003000", }, //"ARM, CoreSight Cross Trigger Interface (CTI) r4, (CoreSight Debug Component: Debug Control, Trigger Matrix)"
  { .addr= {0, 0, 0x0000000081004000}, .id.peripheralid= 0x00000004001bb101, .id.componentid= 0xb105f00d, .id.devtype= 0x00, .instname= "dp0_ap000_0x0000000081004000", }, //"ARM, TimeStamp Generator r1, (CoreLink / PrimeCell / System Component)"
};

uint32_t NUM_SOC_COMPONENTS = sizeof SOC_COMPONENTS / sizeof SOC_COMPONENTS[0];


////////////////////////////////////////////////////////////////////////////////
//
// CPU Information
//
////////////////////////////////////////////////////////////////////////////////

cpuinst_t SOC_CPUS[] = {
  #ifdef CA53_V7_DBG_MAP //Legacy V7 debug memory map
  { .cpuromaddr= {0, 0, 0x0000000080000000}, .cpuaddr= {0, 0, 0x0000000080810000}, .cpuarch= V8A, .sysdbgaddrmask= 0x000000007fffffff, .sysdbgaddr= 0x0000000040000000, .ctiaddr= {0, 0, 0x0000000080818000}, .traceaddr[0]= {0, 0, 0x000000008081C000}, },
  #else
    { .cpuromaddr= {0, 0, 0x0000000080000000}, .cpuaddr= {0, 0, 0x0000000080810000}, .cpuarch= V8A, .sysdbgaddrmask= 0x000000007fffffff, .sysdbgaddr= 0x0000000040000000, .ctiaddr= {0, 0, 0x0000000080820000}, .traceaddr[0]= {0, 0, 0x0000000080840000}, },
  #endif
};


uint32_t NUM_SOC_CPUS = sizeof SOC_CPUS / sizeof SOC_CPUS[0];


////////////////////////////////////////////////////////////////////////////////
//
// System - Trigger Connectivity
//
////////////////////////////////////////////////////////////////////////////////

cstrigcon_t SOC_TRIGGERS[] = {
  { .master.index= 9, .master.signal= EVENTINTFOUT0, .master.port= 0, .slave.index= 6, .slave.signal= TRIGIN, .slave.port= 0, }, // "dp0_ap000_0x0000000081003000" -> "dp0_ap000_0x0000000081000000"
  { .master.index= 9, .master.signal= EVENTINTFOUT1, .master.port= 0, .slave.index= 6, .slave.signal= FLUSHIN, .slave.port= 0, }, // "dp0_ap000_0x0000000081003000" -> "dp0_ap000_0x0000000081000000"
  { .master.index= 9, .master.signal= EVENTINTFOUT2, .master.port= 0, .slave.index= 7, .slave.signal= FLUSHIN, .slave.port= 0, }, // "dp0_ap000_0x0000000081003000" -> "dp0_ap000_0x0000000081001000"
  { .master.index= 9, .master.signal= EVENTINTFOUT3, .master.port= 0, .slave.index= 7, .slave.signal= TRIGIN, .slave.port= 0, }, // "dp0_ap000_0x0000000081003000" -> "dp0_ap000_0x0000000081001000"
  { .master.index= 7, .master.signal= ACQCOMP, .master.port= 0, .slave.index= 9, .slave.signal= EVENTINTFIN0, .slave.port= 0, }, // "dp0_ap000_0x0000000081001000" -> "dp0_ap000_0x0000000081003000"
  { .master.index= 7, .master.signal= FULL, .master.port= 0, .slave.index= 9, .slave.signal= EVENTINTFIN1, .slave.port= 0, }, // "dp0_ap000_0x0000000081001000" -> "dp0_ap000_0x0000000081003000"
  #ifdef CA53_V7_DBG_MAP //Legacy V7 debug memory map
  { .master.index= 4, .master.signal= EVENTINTFOUT0, .master.port= 0, .slave.index= 2, .slave.signal= DBGHALT, .slave.port= 0, }, // "dp0_ap000_0x0000000080818000" -> "dp0_ap000_0x0000000080810000"
  { .master.index= 4, .master.signal= EVENTINTFOUT1, .master.port= 0, .slave.index= 2, .slave.signal= DBGRESTART, .slave.port= 0, }, // "dp0_ap000_0x0000000080818000" -> "dp0_ap000_0x0000000080810000"
  { .master.index= 4, .master.signal= EVENTINTFOUT2, .master.port= 0, .slave.index= 2, .slave.signal= INTERRUPT, .slave.port= 0, }, // "dp0_ap000_0x0000000080818000" -> "dp0_ap000_0x0000000080810000"
  #else
  { .master.index= 3, .master.signal= EVENTINTFOUT0, .master.port= 0, .slave.index= 2, .slave.signal= DBGHALT, .slave.port= 0, }, // "dp0_ap000_0x0000000080820000" -> "dp0_ap000_0x0000000080810000"
  { .master.index= 3, .master.signal= EVENTINTFOUT1, .master.port= 0, .slave.index= 2, .slave.signal= DBGRESTART, .slave.port= 0, }, // "dp0_ap000_0x0000000080820000" -> "dp0_ap000_0x0000000080810000"
  { .master.index= 3, .master.signal= EVENTINTFOUT2, .master.port= 0, .slave.index= 2, .slave.signal= INTERRUPT, .slave.port= 0, }, // "dp0_ap000_0x0000000080820000" -> "dp0_ap000_0x0000000080810000"
  #endif
};

uint32_t NUM_SOC_TRIGGERS = sizeof SOC_TRIGGERS / sizeof SOC_TRIGGERS[0];


////////////////////////////////////////////////////////////////////////////////
//
// System - ATB Trace Connectivity
//
////////////////////////////////////////////////////////////////////////////////

cstracenode_t SOC_TRACE[] = {
  { .signode.index= 5, .signode.signal= ATB, .signode.width= 32, .signode.port= 0, .type= SOURCE, }, // "dp0_ap000_0x0000000080840000"
  { .signode.index= 8, .signode.signal= ATB, .signode.width= 32, .signode.port= 0, .type= LINK, }, // "dp0_ap000_0x0000000081002000"
  { .signode.index= 6, .signode.signal= ATB, .signode.width= 32, .signode.port= 0, .type= SINK, }, // "dp0_ap000_0x0000000081000000"
  { .signode.index= 5, .signode.signal= ATB, .signode.width= 32, .signode.port= 0, .type= SOURCE, }, // "dp0_ap000_0x0000000080840000"
  { .signode.index= 8, .signode.signal= ATB, .signode.width= 32, .signode.port= 1, .type= LINK, }, // "dp0_ap000_0x0000000081002000"
  { .signode.index= 7, .signode.signal= ATB, .signode.width= 32, .signode.port= 0, .type= SINK, }, // "dp0_ap000_0x0000000081001000"
};

uint32_t NUM_SOC_TRACE = sizeof SOC_TRACE / sizeof SOC_TRACE[0];


////////////////////////////////////////////////////////////////////////////////
//
// Everything below is test-specific
//
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
//
// System - CTI Slave CPU Connectivity
//
////////////////////////////////////////////////////////////////////////////////

cscrossmasslv_t SOC_TEST_CTIMASSLV[] = {
  #ifdef CA53_V7_DBG_MAP //Legacy V7 debug memory map
  { .master_cti= 4, .slave_cpu= 2, }, // "dp0_ap000_0x0000000080818000" -> "dp0_ap000_0x0000000080810000"
  #else
  { .master_cti= 3, .slave_cpu= 2, }, // "dp0_ap000_0x0000000080820000" -> "dp0_ap000_0x0000000080810000"
  #endif
  { .master_cti= 9, .slave_cpu= 0xffff, }, // "dp0_ap000_0x0000000081003000" -> ALL
};

uint32_t NUM_SOC_TEST_CTIMASSLV = sizeof SOC_TEST_CTIMASSLV / sizeof SOC_TEST_CTIMASSLV[0];



////////////////////////////////////////////////////////////////////////////////
//
// Memory ranges to test with memap_check
//
////////////////////////////////////////////////////////////////////////////////

mem_ap_test SOC_TEST_MEMAP_CHECK[]={};

uint32_t NUM_SOC_TEST_MEMAP_CHECK = 0;

