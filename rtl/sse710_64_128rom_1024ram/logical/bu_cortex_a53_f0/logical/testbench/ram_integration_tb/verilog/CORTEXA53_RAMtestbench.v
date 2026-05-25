//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-05-23 16:00:38 +0100 (Wed, 23 May 2012) $
//
//      Revision            : $Revision: 209955 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
// Testbench harness for Cache RAM Integration tester.

`timescale 1ns/10ps

`define period 10


module CORTEXA53_RAMtestbench
();

  // ---------------------------
  // Reg declaration
  // ---------------------------
  reg       CLKIN;
  reg [3:0] nCORERESET;
  reg       nL2RESET;

  // ------------------------------------------------------
  // Write automatically generated localparam
  // ------------------------------------------------------

  localparam L2_CACHE = 1;
  localparam ACE = 1;
  localparam ACP = 1;
  localparam [2:0] L1_ICACHE_SIZE = 3'b011;
  localparam SCU_CACHE_PROTECTION = 0;
  localparam [0:0] L2_OUTPUT_LATENCY = 1'b0;
  localparam [2:0] L1_DCACHE_SIZE = 3'b011;
  localparam CPU_CACHE_PROTECTION = 0;
  localparam [3:0] L2_CACHE_SIZE = 4'b0111;
  localparam LEGACY_V7_DEBUG_MAP = 0;
  localparam [0:0] L2_INPUT_LATENCY = 1'b0;
  localparam NUM_CPUS = 1;
  localparam CRYPTO = 1;
  localparam NEON_FP = 1;
  // ------------------------------------------------------
  // End automatically generated localparam
  // ------------------------------------------------------


  initial
    begin
      CLKIN     = 1'b0;
      // hold on reset
      nCORERESET = 4'h0;
      nL2RESET  = 1'b0;
      $display ("======================================");
      $display ("=========== Starting RAM Test ========");
      $display ("======================================");
      $display ("\n");
      $display ("CONFIGURATION SETTING ...");
      $display ("-------------------------");
      $display (" - NUMBER of CPU's = %0d",NUM_CPUS);
      case (CPU_CACHE_PROTECTION)
        0 : $display (" - CPU CACHE PROTECTION NOT ENABLED.");
        1 : $display (" - CPU CACHE PROTECTION ENABLED.");
      endcase
      case (L2_CACHE)
        0 : $display (" - L2 CACHE NOT PRESENT.");
        1 : begin
              $display (" - L2 CACHE PRESENT.");
              case (L2_INPUT_LATENCY)
                1'b0 : $display ("    L2 Input Latency  = 1 cycle.");
                1'b1 : $display ("    L2 Input Latency  = 2 cycle.");
              endcase
              case (L2_OUTPUT_LATENCY)
                1'b0 : $display ("    L2 Output Latency = 2 cycle.");
                1'b1 : $display ("    L2 Output Latency = 3 cycle.");
              endcase
            end
      endcase
      case (SCU_CACHE_PROTECTION)
        0 : $display (" - L2/SCU CACHE PROTECTION NOT ENABLED.");
        1 : $display (" - L2/SCU CACHE PROTECTION ENABLED.");
      endcase
      #(`period*10)
      // release SCU
      nL2RESET = 1'b1;
      // give time for SCU max size (2MB) to complete
      #(`period*1900000)
      // release Core 0
      nCORERESET[0] = 1'b1;
      #(`period*37000)
      // release Core 1
      nCORERESET[1] = 1'b1;
      #(`period*37000)
      // release Core 2
      nCORERESET[2] = 1'b1;
      #(`period*37000)
      // release Core 3
      nCORERESET[3] = 1'b1;
      #(`period*37000)
      #(`period*10000)
      // We only reach this if there are no errors that causes a $finish
      $display ("\n");
      $display ("=======================================");
      $display ("==== Test completed with no errors ====");
      $display ("=======================================");
      $finish;
    end

  //Generation of Clock Logic
  //-------------------------
  always
    #(`period/2) CLKIN = ~CLKIN;

  // ------------------------------------------------------
  // Start automatically generated logic
  // ------------------------------------------------------

  CORTEXA53 u_CORTEXA53 ( 
    //Inputs 
         .CLKIN	(CLKIN),
         .nCPUPORESET	(nCORERESET[NUM_CPUS - 1 : 0]),
         .nCORERESET	(nCORERESET[NUM_CPUS - 1 : 0]),
         .nL2RESET	(nL2RESET),
         .L2RSTDISABLE	({1 {1'b0}}),
         .CFGEND	({1 {1'b0}}),
         .VINITHI	({1 {1'b0}}),
         .CFGTE	({1 {1'b0}}),
         .CP15SDISABLE	({1 {1'b0}}),
         .CLUSTERIDAFF1	({8 {1'b0}}),
         .CLUSTERIDAFF2	({8 {1'b0}}),
         .AA64nAA32	({1 {1'b0}}),
         .RVBARADDR0	({38 {1'b0}}),
         .CRYPTODISABLE	({1 {1'b0}}),
         .nFIQ	({1 {1'b1}}),
         .nIRQ	({1 {1'b1}}),
         .nSEI	({1 {1'b0}}),
         .nVFIQ	({1 {1'b1}}),
         .nVIRQ	({1 {1'b1}}),
         .nVSEI	({1 {1'b0}}),
         .nREI	({1 {1'b0}}),
         .PERIPHBASE	({22 {1'b0}}),
         .GICCDISABLE	({1 {1'b0}}),
         .ICDTVALID	({1 {1'b0}}),
         .ICDTDATA	({16 {1'b0}}),
         .ICDTLAST	({1 {1'b0}}),
         .ICDTDEST	({2 {1'b0}}),
         .ICCTREADY	({1 {1'b0}}),
         .CNTVALUEB	({64 {1'b0}}),
         .CNTCLKEN	({1 {1'b0}}),
         .CLREXMONREQ	({1 {1'b0}}),
         .EVENTI	({1 {1'b0}}),
         .L2FLUSHREQ	({1 {1'b0}}),
         .CPUQREQn	({1 {1'b0}}),
         .NEONQREQn	({1 {1'b0}}),
         .L2QREQn	({1 {1'b0}}),
         .BROADCASTCACHEMAINT	({1 {1'b0}}),
         .BROADCASTINNER	({1 {1'b0}}),
         .BROADCASTOUTER	({1 {1'b0}}),
         .SYSBARDISABLE	({1 {1'b0}}),
         .ACLKENM	({1 {1'b1}}),
         .ACINACTM	({1 {1'b0}}),
         .AWREADYM	({1 {1'b0}}),
         .WREADYM	({1 {1'b0}}),
         .BVALIDM	({1 {1'b0}}),
         .BIDM	({5 {1'b0}}),
         .BRESPM	({2 {1'b0}}),
         .ARREADYM	({1 {1'b0}}),
         .RVALIDM	({1 {1'b0}}),
         .RIDM	({6 {1'b0}}),
         .RDATAM	({128 {1'b0}}),
         .RRESPM	({4 {1'b0}}),
         .RLASTM	({1 {1'b0}}),
         .ACVALIDM	({1 {1'b0}}),
         .ACADDRM	({44 {1'b0}}),
         .ACPROTM	({3 {1'b0}}),
         .ACSNOOPM	({4 {1'b0}}),
         .CRREADYM	({1 {1'b0}}),
         .CDREADYM	({1 {1'b0}}),
         .ACLKENS	({1 {1'b0}}),
         .AINACTS	({1 {1'b0}}),
         .AWVALIDS	({1 {1'b0}}),
         .AWIDS	({5 {1'b0}}),
         .AWADDRS	({40 {1'b0}}),
         .AWLENS	({8 {1'b0}}),
         .AWCACHES	({4 {1'b0}}),
         .AWUSERS	({2 {1'b0}}),
         .AWPROTS	({3 {1'b0}}),
         .WVALIDS	({1 {1'b0}}),
         .WDATAS	({128 {1'b0}}),
         .WSTRBS	({16 {1'b0}}),
         .WLASTS	({1 {1'b0}}),
         .BREADYS	({1 {1'b0}}),
         .ARVALIDS	({1 {1'b0}}),
         .ARIDS	({5 {1'b0}}),
         .ARADDRS	({40 {1'b0}}),
         .ARLENS	({8 {1'b0}}),
         .ARCACHES	({4 {1'b0}}),
         .ARUSERS	({2 {1'b0}}),
         .ARPROTS	({3 {1'b0}}),
         .RREADYS	({1 {1'b0}}),
         .nPRESETDBG	({1 {1'b0}}),
         .PCLKENDBG	({1 {1'b1}}),
         .PSELDBG	({1 {1'b0}}),
         .PADDRDBG	({20 {1'b0}}),
         .PADDRDBG31	({1 {1'b0}}),
         .PENABLEDBG	({1 {1'b0}}),
         .PWRITEDBG	({1 {1'b0}}),
         .PWDATADBG	({32 {1'b0}}),
         .DBGROMADDR	({28 {1'b0}}),
         .DBGROMADDRV	({1 {1'b0}}),
         .EDBGRQ	({1 {1'b0}}),
         .DBGEN	({1 {1'b0}}),
         .NIDEN	({1 {1'b0}}),
         .SPIDEN	({1 {1'b0}}),
         .SPNIDEN	({1 {1'b0}}),
         .DBGPWRDUP	({1 {1'b0}}),
         .DBGL1RSTDISABLE	({1 {1'b0}}),
         .ATCLKEN	({1 {1'b0}}),
         .ATREADYM0	({1 {1'b0}}),
         .AFVALIDM0	({1 {1'b0}}),
         .SYNCREQM0	({1 {1'b0}}),
         .TSVALUEB	({64 {1'b0}}),
         .CTICHIN	({4 {1'b0}}),
         .CTICHOUTACK	({4 {1'b0}}),
         .CISBYPASS	({1 {1'b0}}),
         .CIHSBYPASS	({4 {1'b0}}),
         .CTIIRQACK	({1 {1'b0}}),
         .DFTSE	({1 {1'b0}}),
         .DFTRSTDISABLE	({1 {1'b0}}),
         .DFTRAMHOLD	({1 {1'b0}}),
         .DFTMCPHOLD	({1 {1'b0}}),
         .MBISTREQ	({1 {1'b0}}),
         .nMBISTRESET	({1 {1'b1}}),
    //Outputs 
         .WARMRSTREQ	(),
         .nVCPUMNTIRQ	(),
         .ICDTREADY	(),
         .ICCTVALID	(),
         .ICCTDATA	(),
         .ICCTLAST	(),
         .ICCTID	(),
         .nCNTPNSIRQ	(),
         .nCNTPSIRQ	(),
         .nCNTVIRQ	(),
         .nCNTHPIRQ	(),
         .CLREXMONACK	(),
         .EVENTO	(),
         .STANDBYWFI	(),
         .STANDBYWFE	(),
         .STANDBYWFIL2	(),
         .L2FLUSHDONE	(),
         .SMPEN	(),
         .CPUQACTIVE	(),
         .CPUQDENY	(),
         .CPUQACCEPTn	(),
         .NEONQACTIVE	(),
         .NEONQDENY	(),
         .NEONQACCEPTn	(),
         .L2QACTIVE	(),
         .L2QDENY	(),
         .L2QACCEPTn	(),
         .nEXTERRIRQ	(),
         .RDMEMATTR	(),
         .WRMEMATTR	(),
         .AWVALIDM	(),
         .AWIDM	(),
         .AWADDRM	(),
         .AWLENM	(),
         .AWSIZEM	(),
         .AWBURSTM	(),
         .AWBARM	(),
         .AWDOMAINM	(),
         .AWLOCKM	(),
         .AWCACHEM	(),
         .AWPROTM	(),
         .AWSNOOPM	(),
         .AWUNIQUEM	(),
         .WVALIDM	(),
         .WIDM	(),
         .WDATAM	(),
         .WSTRBM	(),
         .WLASTM	(),
         .BREADYM	(),
         .ARVALIDM	(),
         .ARIDM	(),
         .ARADDRM	(),
         .ARLENM	(),
         .ARSIZEM	(),
         .ARBURSTM	(),
         .ARBARM	(),
         .ARDOMAINM	(),
         .ARLOCKM	(),
         .ARCACHEM	(),
         .ARPROTM	(),
         .ARSNOOPM	(),
         .RREADYM	(),
         .ACREADYM	(),
         .CRVALIDM	(),
         .CRRESPM	(),
         .CDVALIDM	(),
         .CDDATAM	(),
         .CDLASTM	(),
         .RACKM	(),
         .WACKM	(),
         .AWREADYS	(),
         .WREADYS	(),
         .BVALIDS	(),
         .BIDS	(),
         .BRESPS	(),
         .ARREADYS	(),
         .RVALIDS	(),
         .RIDS	(),
         .RDATAS	(),
         .RRESPS	(),
         .RLASTS	(),
         .PRDATADBG	(),
         .PREADYDBG	(),
         .PSLVERRDBG	(),
         .DBGACK	(),
         .nCOMMIRQ	(),
         .COMMRX	(),
         .COMMTX	(),
         .DBGRSTREQ	(),
         .DBGNOPWRDWN	(),
         .DBGPWRUPREQ	(),
         .ATDATAM0	(),
         .ATVALIDM0	(),
         .ATBYTESM0	(),
         .AFREADYM0	(),
         .ATIDM0	(),
         .CTICHOUT	(),
         .CTICHINACK	(),
         .CTIIRQ	(),
         .nPMUIRQ	(),
         .PMUEVENT0	()
   ); 
  // ------------------------------------------------------
  // End automatically generated logic
  // ------------------------------------------------------

endmodule
