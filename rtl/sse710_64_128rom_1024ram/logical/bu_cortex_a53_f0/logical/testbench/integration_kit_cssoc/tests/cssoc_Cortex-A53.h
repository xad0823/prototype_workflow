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
//      Checked In          : $Date: 2014-07-25 11:01:14 +0100 (Fri, 25 Jul 2014) $
//
//      Revision            : $Revision: 285802 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//-----------------------------------------------------------------------------
//
// Description
//
// CSSoC Part Library file : ARM Cortex-A53 Processor
//
// This file has functions used to configure and enable trace sources.
//
// arm_cx_etm_a53_configure():
// This function is used to configure the ETM
//
// arm_cx_etm_a53_trc_enable():
// This function is provided to enable and disable trace
//
// cortexa53_etm_tracesequence():
// This function is used to generate trace by executing the trace code
// which has both the start and stop address programmed in the start and
// stop comparators.
//
// NOTE:
// This file is the CSSoC Part Library file and must be copied to the CSSoC
// partlib directory.
//-----------------------------------------------------------------------------

CPUPART ( 0x410FD030, "Cortex-A53 Processor", "r0p0")

CSPART ( 0x00000004000BB4A3, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level Legacy V7 debug memory map", "r0p0", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004000BB4A1, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level", "r0p0", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004000BB95D, 0xB105900D, 0x13, "ARM", "Cortex-A53 ETM",               "r0p0", NULL, NULL, NULL, &arm_cx_etm_a53_configure, &arm_cx_etm_a53_trc_enable)
CSPART ( 0x00000004000BB9A8, 0xB105900D, 0x14, "ARM", "Cortex-A53 CTI",               "r0p0", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004000BB9D3, 0xB105900D, 0x16, "ARM", "Cortex-A53 PMU",               "r0p0", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004000BBD03, 0xB105900D, 0x15, "ARM", "Cortex-A53 DBG",               "r0p0", NULL, NULL, NULL, NULL, NULL)

CPUPART ( 0x410FD031, "Cortex-A53 Processor", "r0p1")

CSPART ( 0x00000004001BB4A3, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level Legacy V7 debug memory map", "r0p1", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004001BB4A1, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level", "r0p1", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004001BB95D, 0xB105900D, 0x13, "ARM", "Cortex-A53 ETM",               "r0p1", NULL, NULL, NULL, &arm_cx_etm_a53_configure, &arm_cx_etm_a53_trc_enable)
CSPART ( 0x00000004001BB9A8, 0xB105900D, 0x14, "ARM", "Cortex-A53 CTI",               "r0p1", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004001BB9D3, 0xB105900D, 0x16, "ARM", "Cortex-A53 PMU",               "r0p1", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004001BBD03, 0xB105900D, 0x15, "ARM", "Cortex-A53 DBG",               "r0p1", NULL, NULL, NULL, NULL, NULL)

CPUPART ( 0x410FD032, "Cortex-A53 Processor", "r0p2")

CSPART ( 0x00000004002BB4A3, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level Legacy V7 debug memory map", "r0p2", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004002BB4A1, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level", "r0p2", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004002BB95D, 0xB105900D, 0x13, "ARM", "Cortex-A53 ETM",               "r0p2", NULL, NULL, NULL, &arm_cx_etm_a53_configure, &arm_cx_etm_a53_trc_enable)
CSPART ( 0x00000004002BB9A8, 0xB105900D, 0x14, "ARM", "Cortex-A53 CTI",               "r0p2", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004002BB9D3, 0xB105900D, 0x16, "ARM", "Cortex-A53 PMU",               "r0p2", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004002BBD03, 0xB105900D, 0x15, "ARM", "Cortex-A53 DBG",               "r0p2", NULL, NULL, NULL, NULL, NULL)

CPUPART ( 0x410FD033, "Cortex-A53 Processor", "r0p3")

CSPART ( 0x00000004003BB4A3, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level Legacy V7 debug memory map", "r0p3", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004003BB4A1, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level", "r0p3", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004003BB95D, 0xB105900D, 0x13, "ARM", "Cortex-A53 ETM",               "r0p3", NULL, NULL, NULL, &arm_cx_etm_a53_configure, &arm_cx_etm_a53_trc_enable)
CSPART ( 0x00000004003BB9A8, 0xB105900D, 0x14, "ARM", "Cortex-A53 CTI",               "r0p3", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004003BB9D3, 0xB105900D, 0x16, "ARM", "Cortex-A53 PMU",               "r0p3", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004003BBD03, 0xB105900D, 0x15, "ARM", "Cortex-A53 DBG",               "r0p3", NULL, NULL, NULL, NULL, NULL)

CPUPART ( 0x410FD034, "Cortex-A53 Processor", "r0p4")

CSPART ( 0x00000004004BB4A3, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level Legacy V7 debug memory map", "r0p4", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004004BB4A1, 0xB105100D, 0x00, "ARM", "Cortex-A53 Integration Level", "r0p4", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004004BB95D, 0xB105900D, 0x13, "ARM", "Cortex-A53 ETM",               "r0p4", NULL, NULL, NULL, &arm_cx_etm_a53_configure, &arm_cx_etm_a53_trc_enable)
CSPART ( 0x00000004004BB9A8, 0xB105900D, 0x14, "ARM", "Cortex-A53 CTI",               "r0p4", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004004BB9D3, 0xB105900D, 0x16, "ARM", "Cortex-A53 PMU",               "r0p4", NULL, NULL, NULL, NULL, NULL)
CSPART ( 0x00000004004BBD03, 0xB105900D, 0x15, "ARM", "Cortex-A53 DBG",               "r0p4", NULL, NULL, NULL, NULL, NULL)


#ifdef CSPART_FUNCTIONS

uint64_t * cortexa53_etm_tracesequence(uint32_t);
//=============================================================================
//FUNCTION: arm_cx_etm_a53_configure
//=============================================================================
// Configurate ETM for trace
//
// if the trace_conf->mode == INTEGRATION, the ETM will be configured
// to trace based on the start/stop configuration
// if the trace_conf->mode == TRACEALL, the ETM will be configured to always
// trace
//=============================================================================
// Arguments   : trace_conf : This has all the parameters
//                            required to setup the trace
//=============================================================================
uint32_t arm_cx_etm_a53_configure (cstraceconf_t *trace_conf)
{
  uint32_t                  write_data;
  uint32_t                   read_data;
  uint64_t * ca53_tracesequence_addr_p;

  //Check the ETM PID0 register to ensure that ETM is accessible
  ReadMem(trace_conf->addr,CS_PIDR0_OFFSET, &read_data);
  if (read_data != 0x0000005d) {
    MSG_ERROR("Check ETM PID0 Register failed, expected 0x5d but get %x. Skip ETM configuration \n", read_data);
    return FAIL;
  }

  MSG("Cortex-A53 ETM configuration\n");
  if(trace_conf->mode == TRACEINTEGRATION) {
    // Get addresses for programming trace_start,trace stop
    ca53_tracesequence_addr_p   = cortexa53_etm_tracesequence(0);
    #if (defined(__TARGET_ARCH_AARCH64) || defined(__aarch64__))
    trace_conf->addr_start      = *ca53_tracesequence_addr_p;     // Start address
    trace_conf->addr_stop       = *(ca53_tracesequence_addr_p+1); // Stop address
    #else
    #if (defined(__BIG_ENDIAN) || (defined(__BYTE_ORDER__) && (__BYTE_ORDER__ == __ORDER_BIG_ENDIAN__)))
    trace_conf->addr_stop       = *ca53_tracesequence_addr_p & 0x00000000ffffffff;     // Stop address
    trace_conf->addr_start      = *(ca53_tracesequence_addr_p)>>32;                    // Start address
    #else
    trace_conf->addr_start      = *ca53_tracesequence_addr_p & 0x00000000ffffffff;     // Start address
    trace_conf->addr_stop       = *(ca53_tracesequence_addr_p)>>32;                    // Stop address
    #endif
    #endif
  } else {
    trace_conf->addr_start = 0x0;     // Start address
    trace_conf->addr_stop  = 0x0;     // Stop address
  }
  //Unlock SW lock
  write_data = 0xc5acce55;
  WriteMem(trace_conf->addr,CS_LAR_OFFSET,write_data);
  //unlock OS lock
  write_data = 0x0;
  WriteMem(trace_conf->addr,CS_OSLAR_OFFSET,write_data);

  //Disable tracing
  write_data=0x0;
  WriteMem(trace_conf->addr,ETMV4_PRGCTLR_OFFSET,write_data);

  do {
    //check the ETM status register PMSTABLE bit is set and trace is idle
    ReadMem(trace_conf->addr,ETMV4_STATR_OFFSET, &read_data);
    MSG("Check ETM status= %x \n", read_data);
    read_data = read_data & 0x3;
  } while (read_data != 0x3);

  //trace configuration register, enable TS, disable VMID, CID tracing, enable return stack,
  write_data = 0x1801;
  WriteMem(trace_conf->addr,ETMV4_CONFIGR_OFFSET,write_data);
  //Disable all event tracing
  write_data = 0x0;
  WriteMem(trace_conf->addr,ETMV4_EVTCTL0R_OFFSET,write_data);
  write_data = 0x0;
  WriteMem(trace_conf->addr,ETMV4_EVTCTL1R_OFFSET, write_data);
  //stall control: disable stall
  write_data = 0x0;
  WriteMem(trace_conf->addr,ETMV4_STLLCTLR_OFFSET, write_data);
  //TS control: timestamp event
  write_data = 0x0;
  WriteMem(trace_conf->addr,ETMV4_TSCTLR_OFFSET, write_data);
  //Synchronization period register: 1024 bytes
  write_data = 0xa;
  WriteMem(trace_conf->addr,ETMV4_SYNCPR_OFFSET, write_data);
  //Trace ID reg
  write_data = trace_conf->atid;
  WriteMem(trace_conf->addr,ETMV4_TRACEIDR_OFFSET, write_data);
  //Address comparator value registers and access type registers:
  write_data = 0;
  WriteMem(trace_conf->addr,ETMV4_ACATR0_UP_OFFSET, write_data);
  WriteMem(trace_conf->addr,ETMV4_ACATR1_UP_OFFSET, write_data);
  //Trace start address: high 32 bits
  write_data = (uint32_t)((trace_conf->addr_start) >> 32);
  WriteMem(trace_conf->addr,ETMV4_ACVR0_UP_OFFSET, write_data);
  //trace stop address: high 32 bits
  write_data = (uint32_t)((trace_conf->addr_stop) >> 32);
  WriteMem(trace_conf->addr,ETMV4_ACVR1_UP_OFFSET, write_data);
  //trace start address: low 32 bits
  write_data = (uint32_t)(trace_conf->addr_start);
  WriteMem(trace_conf->addr,ETMV4_ACVR0_OFFSET, write_data);
  //trace stop address: low 32 bits
  write_data = (uint32_t)(trace_conf->addr_stop);
  WriteMem(trace_conf->addr,ETMV4_ACVR1_OFFSET, write_data);
  //instruction address in all exception level
  write_data = 0;
  WriteMem(trace_conf->addr,ETMV4_ACATR0_OFFSET, write_data);
  //instruction address in all exception level
  write_data = 0;
  WriteMem(trace_conf->addr,ETMV4_ACATR1_OFFSET, write_data);

  //Viewinst include/exclude control: No address range filtering for viewinst
  write_data = 0;
  WriteMem(trace_conf->addr,ETMV4_VIIECTLR_OFFSET, write_data);
  if(trace_conf->mode == 1) {
    //Enalbe viewinst, start/stop in start state
    write_data=0x00000201;
    WriteMem(trace_conf->addr, ETMV4_VICTLR_OFFSET, write_data);
    //Viewinst start/stop control: No start/stop filtering for viewinst
    write_data=0x0;
    WriteMem(trace_conf->addr,ETMV4_VISSCTLR_OFFSET, write_data);
  } else {
    //Enalbe viewinst, start/stop in stop state
    write_data=0x00000001;
    WriteMem(trace_conf->addr, ETMV4_VICTLR_OFFSET, write_data);
    //Viewinst start/stop control:  start/stop address comparators 0/1
    write_data=0x20001;
    WriteMem(trace_conf->addr,ETMV4_VISSCTLR_OFFSET, write_data);
  }

  //Enalbe tracing
  write_data=0x1;
  WriteMem(trace_conf->addr, ETMV4_PRGCTLR_OFFSET, write_data);

  MSG("Cortex-A53 ETM configuration done \n");
  if(trace_conf->mode == TRACEINTEGRATION) {
    MSG("Trace generation\n");
    MSG_DBG("Enter trace generate function\n");
    cortexa53_etm_tracesequence(1);
    MSG_DBG("Exited trace generate function\n");
  }
  return PASS;
}

//=============================================================================
// FUNCTION: arm_cx_etm_a53_trc_enable
//=============================================================================
// Description : This function disables/enables the ETM
//=============================================================================
// Arguments   : trace_conf : This has all the parameters required to
//                            setup the trace
//               enable     : enable/disable
//=============================================================================
uint32_t arm_cx_etm_a53_trc_enable (cstraceconf_t *trace_conf, uint32_t enable)
{
  uint32_t          write_data;
  uint32_t          read_data;


  //Check the ETM PID0 register to ensure that ETM is accessible
  ReadMem(trace_conf->addr,CS_PIDR0_OFFSET, &read_data);
  if (read_data != 0x0000005d) {
    MSG_ERROR("Check ETM PID0 Register failed, expected 0x5d but get %x. Skip enable/disable trace\n", read_data);
    return FAIL;
  }

  //enable/disable ETM trace
  if(enable == 1) {
    MSG("Enable ETM \n");
    write_data=0x1;
    WriteMem(trace_conf->addr,ETMV4_PRGCTLR_OFFSET, write_data);
  } else {
    MSG("Disable ETM \n");
    write_data=0x0;
    WriteMem(trace_conf->addr,ETMV4_PRGCTLR_OFFSET, write_data);
    do {
    //check the ETM status register PMSTABLE bit is set and trace is idle
      ReadMem(trace_conf->addr,ETMV4_STATR_OFFSET, &read_data);
      MSG("Check ETM status= %x \n", read_data);
      read_data = read_data & 0x3;
    } while (read_data != 0x3);

  }
  return PASS;
}


//=============================================================================
//FUNCTION: cortexa53_etm_tracesequence
//=============================================================================
//DESCRIPTION: This is the function which executes the trace generation
//             sequence and also can give the start and stop labels
//=============================================================================
//ARGUMENTS: run   : 0 -> return ptr to start/stop addresses
//                   1 -> execute trace code
//=============================================================================

uint64_t                 ca53_tracesequence_addr_p[2] = {0};

#if (defined TESTIMAGECXDT || !(defined TRACECODE_CORTEXA53))

uint64_t * cortexa53_etm_tracesequence(uint32_t run)
{
  MSG_ERROR("Trace sequence for Cortex-A53 not built in this image.\n");
  return ca53_tracesequence_addr_p;
}

#else
// GCC inline assemlby code
uint64_t * cortexa53_etm_tracesequence(uint32_t run)
{
  // AAPCS: select will be in r0
  //        Return value will be in r0
  //
  // If run == 0, return ptr to addresses
  // If run == 1, execute the trace function

  // NB - Code this using the instructions allowed by your architecture

#if defined(__aarch64__)
asm volatile(
  "CMP x0, #1\n\t"
  "B.EQ cortexa53_etm_tracesequence_pad\n\t"

  // Return pointer to addresses
  "LDR x0, =cortexa53_etm_tracesequence_addresses\n\t"
  "RET \n\t"
  ".ltorg\n"
  // Padding instructions before start of sequence
  "cortexa53_etm_tracesequence_pad:\n\t"
  "NOP \n\t"
  "NOP \n\t"
  "NOP \n\t"
  "NOP \n\t"
  "cortexa53_etm_tracesequence_start:\n\t"
  "STR x2, [sp, #-8]\n\t"
  "MOV x2, #10\n"
  "inner_loop_a53:\n\t"
  "SUBS x2, x2, #0x1\n\t"
  "B.NE inner_loop_a53\n\t"
  //Causes insertion of extra timestamps
  "ISB\n\t"
  "LDR x2, [sp, #8]\n"
  "cortexa53_etm_tracesequence_stop:\n\t"
  "B cortexa53_etm_trace_return\n\t"
  "cortexa53_etm_trace_return:\n\t"
  "RET \n\t"

  //Address values used to configure the trace source
  "cortexa53_etm_tracesequence_addresses:\n\t"
  ".quad cortexa53_etm_tracesequence_start \n\t"
  ".quad cortexa53_etm_tracesequence_stop \n\t"

);
#else
asm volatile(
  "CMP r0, #1\n\t"
  "BEQ cortexa53_etm_tracesequence_pad\n\t"

  // Return pointer to addresses
  "LDR r0, =cortexa53_etm_tracesequence_addresses\n\t"
  "BX LR\n\t"
  ".ltorg\n"
  // Padding instructions before start of sequence
  "cortexa53_etm_tracesequence_pad:\n\t"
  "NOP \n\t"
  "NOP \n\t"
  "NOP \n\t"
  "NOP \n\t"
  "cortexa53_etm_tracesequence_start:\n\t"
  "PUSH {r2}\n\t"
  "MOVS r2, #10\n"
  "inner_loop_a53:\n\t"
  "SUBS r2, r2, #0x1\n\t"
  "BNE  inner_loop_a53\n\t"
  //Causes insertion of extra timestamps
  "ISB\n\t"
  "POP {r2}\n"
  "cortexa53_etm_tracesequence_stop:\n\t"
  "BX   lr\n\t"

  //Address values used to configure the trace source
  "cortexa53_etm_tracesequence_addresses:\n\t"
  ".word cortexa53_etm_tracesequence_start \n\t"
  ".word cortexa53_etm_tracesequence_stop \n\t"

);

#endif
}

#endif // End of (defined TESTIMAGECXDT || !(defined TRACECODE_CORTEXA53))
#endif // End of CSPART_FUNCTIONS
