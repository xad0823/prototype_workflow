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
//      Checked In          : $Date: 2014-07-25 09:52:11 +0100 (Fri, 25 Jul 2014) $
//
//      Revision            : $Revision: 285788 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
// Description:
// START NOGENERATE
//   This is the unconfigured RTL and cannot be used until it has been rendered
//   to the correct configuration.  This unconfigured file contains directives,
//   such as the 'START NOGENERATE' line above, that a processing script uses to
//   configure the testbench.
// END NOGENERATE
// START CONFIG (!intkit)
//
//   Top-level for the Cortex-A53 execution testbench. The testbench is generated to
//   match the configuration of the Cortex-A53 processor.
//
//        +------------------------+
//        |                        |
//        |                        |
//        |  Cortex-A53 Processor  |
//        |                        |
//        |                        |
//        +------------------------+
//                    |
//                    |
//                    |
//                    |
//    +---------------------------------+
//    | Validation subsystem            |
//    |                                 |
//    |            +------------------+ |
//    |            | Val tube         | |
//    |            +------------------+ |
//    |                                 |
//    |            +------------------+ |
//    |            | Val trickbox     | |
//    |            +------------------+ |
//    |                                 |
//    |            +------------------+ |
//    |            | Val RAM          | |
//    |            |   ...            | |
//    |            |   ...            | |
//    |            +------------------+ |
//    |                                 |
//    +---------------------------------+
//
//-----------------------------------------------------------------------------
// END CONFIG
// START CONFIG intkit
//
//   Top-level for the Cortex-A53 integration kit testbench.The testbench is generated
//   to match the configuration of the Cortex-A53 processor.
//
//        +------------------------+                       +--------------------+
//        |                        |                       |                    |
//        |                        |                       |                    |
//        |  Cortex-A53 Processor  |-----------------------|CSSYS Example Sys   |
//        |                        |                       |                    |
//        |                        |                       |                    |
//        +------------------------+                       +--------------------+
//                    |                                               |
//                    |                                               |
//                    |                                               |
//                    |                                               |
//    +---------------------------------+                  +--------------------+
//    | Validation subsystem            |                  |                    |
//    |                                 |                  |                    |
//    |            +------------------+ |                  |         CXDT       |
//    |            | Val tube         | |                  |                    |
//    |            +------------------+ |                  |                    |
//    |                                 |                  +--------------------+
//    |            +------------------+ |
//    |            | Val trickbox     | |
//    |            +------------------+ |
//    |                                 |
//    |            +------------------+ |
//    |            | Val RAM          | |
//    |            |   ...            | |
//    |            |   ...            | |
//    |            +------------------+ |
//    |                                 |
//    +---------------------------------+
//
//-----------------------------------------------------------------------------
// END CONFIG

`timescale 1ns/10ps
// START CONFIG intkit
module cortexa53_intkit_tb ();
// END CONFIG
// START CONFIG (!intkit)
module cortexa53_execution_tb ();
// END CONFIG

  //----------------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------------

  localparam CLK_PERIOD       = 10;

  // START GENPARAM
  localparam NUM_CPUS    = <# NUM_CPUS    : 1 #>;
  localparam ACE         = <# ACE         : 1 #>;
  localparam ACP         = <# ACP         : 1 #>;
  localparam USE_DAPLITE = <# USE_DAPLITE : 0 #>;
  localparam USE_TPIULOG = <# USE_TPIULOG : 0 #>;
  // END GENPARAM

  // Skyros node IDs.  These are only used in the Skyros configuration.
  localparam [6:0] SKY_RNFNODEID = 7'b0000000; // RN-F ID : Cortex-A53 processor
  localparam [6:0] SKY_HNINODEID = 7'b0000001; // HN-I ID : Validation subsystem
  localparam [6:0] SKY_MNNODEID  = 7'b0001111; // MN ID   : Validation subsystem

  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  // Clocks and resets
  reg                   clk;
  reg                   reset_n;

  // ACE interface signals
  wire                  ace_awready;
  wire                  ace_awvalid;
  wire [4:0]            ace_awid;
  wire [43:0]           ace_awaddr;
  wire [7:0]            ace_awlen;
  wire [2:0]            ace_awsize;
  wire [1:0]            ace_awburst;
  wire [1:0]            ace_awbar;
  wire [1:0]            ace_awdomain;
  wire                  ace_awlock;
  wire [3:0]            ace_awcache;
  wire [2:0]            ace_awprot;
  wire [2:0]            ace_awsnoop;
  wire                  ace_awunique;
  wire                  ace_wready;
  wire                  ace_wvalid;
  wire [4:0]            ace_wid;
  wire [127:0]          ace_wdata;
  wire [15:0]           ace_wstrb;
  wire                  ace_wlast;
  wire                  ace_bready;
  wire                  ace_bvalid;
  wire [4:0]            ace_bid;
  wire [1:0]            ace_bresp;
  wire                  ace_arready;
  wire                  ace_arvalid;
  wire [5:0]            ace_arid;
  wire [43:0]           ace_araddr;
  wire [7:0]            ace_arlen;
  wire [2:0]            ace_arsize;
  wire [1:0]            ace_arburst;
  wire [1:0]            ace_arbar;
  wire [1:0]            ace_ardomain;
  wire                  ace_arlock;
  wire [3:0]            ace_arcache;
  wire [2:0]            ace_arprot;
  wire [3:0]            ace_arsnoop;
  wire                  ace_rready;
  wire                  ace_rvalid;
  wire [5:0]            ace_rid;
  wire [127:0]          ace_rdata;
  wire [3:0]            ace_rresp;
  wire                  ace_rlast;
  wire                  ace_acready;
  wire                  ace_acvalid;
  wire [43:0]           ace_acaddr;
  wire [2:0]            ace_acprot;
  wire [3:0]            ace_acsnoop;
  wire                  ace_crready;
  wire                  ace_crvalid;
  wire [4:0]            ace_crresp;
  wire                  ace_cdready;
  wire                  ace_cdvalid;
  wire [127:0]          ace_cddata;
  wire                  ace_cdlast;
  wire                  ace_rack;
  wire                  ace_wack;

  // Skyros interface signals
  wire                  sky_rxsactive;
  wire                  sky_txsactive;
  wire                  sky_rxlinkactivereq;
  wire                  sky_rxlinkactiveack;
  wire                  sky_txlinkactivereq;
  wire                  sky_txlinkactiveack;
  wire [7:0]            sky_reqmemattr;
  wire                  sky_txreqflitpend;
  wire                  sky_txreqflitv;
  wire [99:0]           sky_txreqflit;
  wire                  sky_txreqlcrdv;
  wire                  sky_txrspflitpend;
  wire                  sky_txrspflitv;
  wire [44:0]           sky_txrspflit;
  wire                  sky_txrsplcrdv;
  wire                  sky_txdatflitpend;
  wire                  sky_txdatflitv;
  wire [193:0]          sky_txdatflit;
  wire                  sky_txdatlcrdv;
  wire                  sky_rxrspflitpend;
  wire                  sky_rxrspflitv;
  wire [44:0]           sky_rxrspflit;
  wire                  sky_rxrsplcrdv;
  wire                  sky_rxdatflitpend;
  wire                  sky_rxdatflitv;
  wire [193:0]          sky_rxdatflit;
  wire                  sky_rxdatlcrdv;
  wire                  sky_rxsnpflitpend;
  wire                  sky_rxsnpflitv;
  wire [64:0]           sky_rxsnpflit;
  wire                  sky_rxsnplcrdv;

  // Configuration
  wire [(NUM_CPUS-1):0] cfg_cfgend;
  wire [(NUM_CPUS-1):0] cfg_aa64naa32;
  wire [(NUM_CPUS-1):0] cfg_vinithi;
  wire [(NUM_CPUS-1):0] cfg_cfgte;
  wire [39:18]          cfg_periphbase;
  wire [7:0]            cfg_clusterid;

  // Trickbox
  wire [(NUM_CPUS-1):0] tbox_nfiq;
  wire [63:0]           tbox_cntvalueb;

  // VCD dumping
  reg  [1:0]            dump;
  reg  [31:0]           dumpon;
  reg  [31:0]           dumpoff;
  reg                   dumpon_set;
  reg                   dumpoff_set;

  // Watchdog
  wire [(NUM_CPUS-1):0] standbywfi;
`ifndef ARM_TB_WATCHDOG_DISABLE
  reg  [31:0]           watchdog_timeout;
  reg  [31:0]           watchdog_count;
  wire [31:0]           nxt_watchdog_count;
  wire [3:0]            watchdog_clear;
  genvar                i;
`endif

  // START CONFIG intkit
  // PAD level SW/JTAG interface signals
  wire        nTRST;
  wire        TDI;
  wire        TDO;
  wire        SWDIOTMS;
  wire        SWCLKTCK;

  // Internal SW/JTAG interface signals
  wire        tdi_intf;
  wire        swditms_intf;
  wire        tdo_intf;
  wire        swdo_intf;
  wire        swdoen_intf;
  wire        ntdoen_intf;

  //END CONFIG
  // Debug APB interface signals
  wire        pclkendbg;
  wire        pseldbg;
  wire [31:2] paddrdbg;
  wire        paddrdbg31;
  wire        penabledbg;
  wire        pwritedbg;
  wire [31:0] pwdatadbg;
  wire [31:0] prdatadbg;
  wire        preadydbg;
  wire        pslverrdbg;

  // ATB interface signals
  wire        atreadym0;
  wire        afvalidm0;
  wire [31:0] atdatam0;
  wire        atvalidm0;
  wire [1:0]  atbytesm0;
  wire        afreadym0;
  wire [6:0]  atidm0;

  //Timestamp value for trace
  wire [63:0] cx_tsvalueb;

  //CTI interfaces
  wire [3:0]  ctichin;
  wire [3:0]  ctichoutack;
  wire [3:0]  ctichout;
  wire [3:0]  ctichinack;

  wire [(NUM_CPUS-1):0]       ctiirq;
  wire [(NUM_CPUS-1):0]       nctiirq;


  //----------------------------------------------------------------------------
  // Clock generation
  //----------------------------------------------------------------------------

  initial clk = 1'b0;

  always
    #(CLK_PERIOD/2) clk = ~clk;


  //----------------------------------------------------------------------------
  // Reset generation
  //----------------------------------------------------------------------------

  // Reset asserted at start of simulation, de-asserted after 50 cycles.
  // The execution testbench starts with a power-on reset (all resets except
  // MBIST reset asserted) and then enters run mode (all resets except MBIST
  // reset de-asserted.)  Therefore one global reset signal can be used.
  initial begin
    reset_n = 1'b0;
    #(50*CLK_PERIOD) reset_n = 1'b1;
  end


  //----------------------------------------------------------------------------
  // Processor configuration plusargs
  //
  //   +arch64 : Initial processor state is AArch64
  //   +hivecs : Use high vectors
  //   +cfgte  : Initial value for TE bit (Thumb Exception Enable)
  //
  //----------------------------------------------------------------------------

  // Create wires for processor configuration inputs
  assign cfg_cfgend     = {NUM_CPUS{($test$plusargs("bigend")  > 0)}};
  assign cfg_aa64naa32  = {NUM_CPUS{($test$plusargs("arch64")  > 0)}};
  assign cfg_vinithi    = {NUM_CPUS{($test$plusargs("hivecs")  > 0)}};
  assign cfg_cfgte      = {NUM_CPUS{($test$plusargs("cfgte")   > 0)}};
  assign cfg_periphbase = {20'h00130, 2'b10};
  assign cfg_clusterid  = 8'h00;


  //----------------------------------------------------------------------------
  // Cortex-A53 instantiation
  //----------------------------------------------------------------------------

  CORTEXA53
    u_cortexa53
      (// Clocks and resets
       .CLKIN                       (clk),
       .nCPUPORESET                 ({NUM_CPUS{reset_n}}),
       .nCORERESET                  ({NUM_CPUS{reset_n}}),
       .nPRESETDBG                  (reset_n),
       .nL2RESET                    (reset_n),
       .nMBISTRESET                 (1'b1),       // No MBIST
       .L2RSTDISABLE                (1'b0),
       .WARMRSTREQ                  (),

       // Configuration signals
       .CFGEND                      (cfg_cfgend),
       .VINITHI                     (cfg_vinithi),
       .CFGTE                       (cfg_cfgte),
       .CP15SDISABLE                ({NUM_CPUS{1'b0}}),
       .CLUSTERIDAFF1               (cfg_clusterid),
       .CLUSTERIDAFF2               (8'h00),
       .AA64nAA32                   (cfg_aa64naa32),
       .RVBARADDR0                  ({38{1'b0}}),
       // START CONFIG (NUM_CPUS > 1)
       .RVBARADDR1                  ({38{1'b0}}),
       // END CONFIG
       // START CONFIG (NUM_CPUS > 2)
       .RVBARADDR2                  ({38{1'b0}}),
       // END CONFIG
       // START CONFIG (NUM_CPUS > 3)
       .RVBARADDR3                  ({38{1'b0}}),
       // END CONFIG
       // START CONFIG CRYPTO
       .CRYPTODISABLE               ({NUM_CPUS{1'b0}}),
       // END CONFIG

       // Interrupt signals
       .nFIQ                        (tbox_nfiq),
       .nIRQ                        (nctiirq),
       .nSEI                        ({NUM_CPUS{1'b1}}),
       .nVFIQ                       ({NUM_CPUS{1'b1}}),
       .nVIRQ                       ({NUM_CPUS{1'b1}}),
       .nVSEI                       ({NUM_CPUS{1'b1}}),
       .nREI                        ({NUM_CPUS{1'b1}}),
       .nVCPUMNTIRQ                 (),
       .PERIPHBASE                  (cfg_periphbase),
       .GICCDISABLE                 (1'b1),
       .ICDTVALID                   (1'b0),
       .ICDTREADY                   (),
       .ICDTDATA                    ({16{1'b0}}),
       .ICDTLAST                    (1'b0),
       .ICDTDEST                    (2'b00),
       .ICCTVALID                   (),
       .ICCTREADY                   (1'b0),
       .ICCTDATA                    (),
       .ICCTLAST                    (),
       .ICCTID                      (),

       // Generic timer signals
       .CNTVALUEB                   (tbox_cntvalueb),
       .CNTCLKEN                    (1'b1),
       .nCNTPNSIRQ                  (),
       .nCNTPSIRQ                   (),
       .nCNTVIRQ                    (),
       .nCNTHPIRQ                   (),

       // Power management signals
       .CLREXMONREQ                 (1'b0),
       .CLREXMONACK                 (),
       .EVENTI                      (1'b0),
       .EVENTO                      (),
       .STANDBYWFI                  (standbywfi),
       .STANDBYWFE                  (),
       .STANDBYWFIL2                (),
       // START CONFIG L2_CACHE
       .L2FLUSHREQ                  (1'b0),
       .L2FLUSHDONE                 (),
       // END CONFIG
       .SMPEN                       (),
       .CPUQACTIVE                  (),
       .CPUQREQn                    ({NUM_CPUS{1'b1}}),
       .CPUQDENY                    (),
       .CPUQACCEPTn                 (),
       // START CONFIG NEON_FP
       .NEONQACTIVE                 (),
       .NEONQREQn                   ({NUM_CPUS{1'b1}}),
       .NEONQDENY                   (),
       .NEONQACCEPTn                (),
       // END CONFIG
       // START CONFIG L2_CACHE
       .L2QACTIVE                   (),
       .L2QREQn                     (1'b1),
       .L2QDENY                     (),
       .L2QACCEPTn                  (),
       // END CONFIG

       // START CONFIG CPU_OR_SCU_CACHE_PROTECTION
       // L2 error signals
       .nINTERRIRQ                  (),

       // END CONFIG
       // ACE/Skyros interface signals
       //   NB. the execution testbench bus model is a simple single master,
       //   single slave system and therefore cache maintenance operations are
       //   disabled. The bus model is a simple in-order device so barriers are
       //   also disabled in the ACE configuration. However, in a Skyros system
       //   SYSBARDISABLE must be HIGH, so the Skyros subsystem does process
       //   barriers.
       .nEXTERRIRQ                  (),
       .BROADCASTCACHEMAINT         (1'b0),
       .BROADCASTINNER              (1'b0),
       .BROADCASTOUTER              (1'b0),
       .SYSBARDISABLE               ((ACE != 0)),

       // START CONFIG (!ACE)
       // Skyros interface
       //   - Clock and configuration signals
       .SCLKEN                      (1'b1),
       .SINACT                      (1'b1),
       .NODEID                      (SKY_RNFNODEID),
       .RXSACTIVE                   (sky_rxsactive),
       .TXSACTIVE                   (sky_txsactive),
       .RXLINKACTIVEREQ             (sky_rxlinkactivereq),
       .RXLINKACTIVEACK             (sky_rxlinkactiveack),
       .TXLINKACTIVEREQ             (sky_txlinkactivereq),
       .TXLINKACTIVEACK             (sky_txlinkactiveack),
       .REQMEMATTR                  (sky_reqmemattr),
       //  - Transmit request virtual channel signals
       .TXREQFLITPEND               (sky_txreqflitpend),
       .TXREQFLITV                  (sky_txreqflitv),
       .TXREQFLIT                   (sky_txreqflit),
       .TXREQLCRDV                  (sky_txreqlcrdv),
       //  - Transmit response virtual channel signals
       .TXRSPFLITPEND               (sky_txrspflitpend),
       .TXRSPFLITV                  (sky_txrspflitv),
       .TXRSPFLIT                   (sky_txrspflit),
       .TXRSPLCRDV                  (sky_txrsplcrdv),
       //  - Transmit data virtual channel signals
       .TXDATFLITPEND               (sky_txdatflitpend),
       .TXDATFLITV                  (sky_txdatflitv),
       .TXDATFLIT                   (sky_txdatflit),
       .TXDATLCRDV                  (sky_txdatlcrdv),
       //  - Receive snoop virtual channel signals
       .RXSNPFLITPEND               (sky_rxsnpflitpend),
       .RXSNPFLITV                  (sky_rxsnpflitv),
       .RXSNPFLIT                   (sky_rxsnpflit),
       .RXSNPLCRDV                  (sky_rxsnplcrdv),
       //  - Receive response virtual channel signals
       .RXRSPFLITPEND               (sky_rxrspflitpend),
       .RXRSPFLITV                  (sky_rxrspflitv),
       .RXRSPFLIT                   (sky_rxrspflit),
       .RXRSPLCRDV                  (sky_rxrsplcrdv),
       //  - Receive data virtual channel signals
       .RXDATFLITPEND               (sky_rxdatflitpend),
       .RXDATFLITV                  (sky_rxdatflitv),
       .RXDATFLIT                   (sky_rxdatflit),
       .RXDATLCRDV                  (sky_rxdatlcrdv),
       //  - System address map signals
       .SAMADDRMAP0                 (2'b01),  // HN-I 0
       .SAMADDRMAP1                 (2'b01),  // HN-I 0
       .SAMADDRMAP2                 (2'b01),  // HN-I 0
       .SAMADDRMAP3                 (2'b01),  // HN-I 0
       .SAMADDRMAP4                 (2'b01),  // HN-I 0
       .SAMADDRMAP5                 (2'b01),  // HN-I 0
       .SAMADDRMAP6                 (2'b01),  // HN-I 0
       .SAMADDRMAP7                 (2'b01),  // HN-I 0
       .SAMADDRMAP8                 (2'b01),  // HN-I 0
       .SAMADDRMAP9                 (2'b01),  // HN-I 0
       .SAMADDRMAP10                (2'b01),  // HN-I 0
       .SAMADDRMAP11                (2'b01),  // HN-I 0
       .SAMADDRMAP12                (2'b01),  // HN-I 0
       .SAMADDRMAP13                (2'b01),  // HN-I 0
       .SAMADDRMAP14                (2'b01),  // HN-I 0
       .SAMADDRMAP15                (2'b00),  // HN-I 0
       .SAMMNBASE                   ({16{1'b1}}),
       .SAMMNNODEID                 (SKY_MNNODEID),  // MN    : In validation subsys
       .SAMHNI0NODEID               (SKY_HNINODEID), // HN-I 0: In validation subsys
       .SAMHNI1NODEID               (7'b000_0000),   // HN-I 1: Not used
       .SAMHNF0NODEID               (7'b000_0000),   // HN-F 0: Not used
       .SAMHNF1NODEID               (7'b000_0000),   // HN-F 1: Not used
       .SAMHNF2NODEID               (7'b000_0000),   // HN-F 2: Not used
       .SAMHNF3NODEID               (7'b000_0000),   // HN-F 3: Not used
       .SAMHNF4NODEID               (7'b000_0000),   // HN-F 4: Not used
       .SAMHNF5NODEID               (7'b000_0000),   // HN-F 5: Not used
       .SAMHNF6NODEID               (7'b000_0000),   // HN-F 6: Not used
       .SAMHNF7NODEID               (7'b000_0000),   // HN-F 7: Not used
       .SAMHNFMODE                  (3'b000),
       // END CONFIG
       // START CONFIG ACE
       // ACE interface
       //   - Clock and configuration signals
       .ACLKENM                     (1'b1),
       .ACINACTM                    (1'b1),
       .RDMEMATTR                   (),
       .WRMEMATTR                   (),
       //  - Write address channel signals
       .AWREADYM                    (ace_awready),
       .AWVALIDM                    (ace_awvalid),
       .AWIDM                       (ace_awid),
       .AWADDRM                     (ace_awaddr),
       .AWLENM                      (ace_awlen),
       .AWSIZEM                     (ace_awsize),
       .AWBURSTM                    (ace_awburst),
       .AWBARM                      (ace_awbar),
       .AWDOMAINM                   (ace_awdomain),
       .AWLOCKM                     (ace_awlock),
       .AWCACHEM                    (ace_awcache),
       .AWPROTM                     (ace_awprot),
       .AWSNOOPM                    (ace_awsnoop),
       .AWUNIQUEM                   (ace_awunique),
       //  - Write data channel signals
       .WREADYM                     (ace_wready),
       .WVALIDM                     (ace_wvalid),
       .WIDM                        (ace_wid),
       .WDATAM                      (ace_wdata),
       .WSTRBM                      (ace_wstrb),
       .WLASTM                      (ace_wlast),
       //  - Write response channel signals
       .BREADYM                     (ace_bready),
       .BVALIDM                     (ace_bvalid),
       .BIDM                        (ace_bid),
       .BRESPM                      (ace_bresp),
       //  - Read address channel signals
       .ARREADYM                    (ace_arready),
       .ARVALIDM                    (ace_arvalid),
       .ARIDM                       (ace_arid),
       .ARADDRM                     (ace_araddr),
       .ARLENM                      (ace_arlen),
       .ARSIZEM                     (ace_arsize),
       .ARBURSTM                    (ace_arburst),
       .ARBARM                      (ace_arbar),
       .ARDOMAINM                   (ace_ardomain),
       .ARLOCKM                     (ace_arlock),
       .ARCACHEM                    (ace_arcache),
       .ARPROTM                     (ace_arprot),
       .ARSNOOPM                    (ace_arsnoop),
       //  - Read data channel signals
       .RREADYM                     (ace_rready),
       .RVALIDM                     (ace_rvalid),
       .RIDM                        (ace_rid),
       .RDATAM                      (ace_rdata),
       .RRESPM                      (ace_rresp),
       .RLASTM                      (ace_rlast),
       //  - Coherency address channel signals
       .ACREADYM                    (ace_acready),
       .ACVALIDM                    (ace_acvalid),
       .ACADDRM                     (ace_acaddr),
       .ACPROTM                     (ace_acprot),
       .ACSNOOPM                    (ace_acsnoop),
       //  - Coherency response channel signals
       .CRREADYM                    (ace_crready),
       .CRVALIDM                    (ace_crvalid),
       .CRRESPM                     (ace_crresp),
       //  - Coherency data channel signals
       .CDREADYM                    (ace_cdready),
       .CDVALIDM                    (ace_cdvalid),
       .CDDATAM                     (ace_cddata),
       .CDLASTM                     (ace_cdlast),
       //  - Read/write acknowledge signals
       .RACKM                       (ace_rack),
       .WACKM                       (ace_wack),
       // END CONFIG

       // START CONFIG ACP
       // ACP interface
       //  - Clock and configuration signals
       .ACLKENS                     (1'b1),
       .AINACTS                     (1'b1),
       //  - Write address channel signals
       .AWREADYS                    (),
       .AWVALIDS                    (1'b0),
       .AWIDS                       ({5{1'b0}}),
       .AWADDRS                     ({40{1'b0}}),
       .AWLENS                      ({8{1'b0}}),
       .AWCACHES                    ({4{1'b0}}),
       .AWUSERS                     ({2{1'b0}}),
       .AWPROTS                     ({3{1'b0}}),
       //  - Write data channel signals
       .WREADYS                     (),
       .WVALIDS                     (1'b0),
       .WDATAS                      ({128{1'b0}}),
       .WSTRBS                      ({16{1'b0}}),
       .WLASTS                      (1'b0),
       //  - Write response channel signals
       .BREADYS                     (1'b0),
       .BVALIDS                     (),
       .BIDS                        (),
       .BRESPS                      (),
       //  - Read address channel signals
       .ARREADYS                    (),
       .ARVALIDS                    (1'b0),
       .ARIDS                       ({5{1'b0}}),
       .ARADDRS                     ({40{1'b0}}),
       .ARLENS                      ({8{1'b0}}),
       .ARCACHES                    ({4{1'b0}}),
       .ARUSERS                     ({2{1'b0}}),
       .ARPROTS                     ({3{1'b0}}),
       //  - Read data channel signals
       .RREADYS                     (1'b0),
       .RVALIDS                     (),
       .RIDS                        (),
       .RDATAS                      (),
       .RRESPS                      (),
       .RLASTS                      (),

       // END CONFIG
       // Debug APB interface signals
       .PCLKENDBG                   (1'b1),
       .PSELDBG                     (pseldbg),
       .PADDRDBG                    (paddrdbg[21:2]),
       .PADDRDBG31                  (paddrdbg31),
       .PENABLEDBG                  (penabledbg),
       .PWRITEDBG                   (pwritedbg),
       .PWDATADBG                   (pwdatadbg),
       .PRDATADBG                   (prdatadbg),
       .PREADYDBG                   (preadydbg),
       .PSLVERRDBG                  (pslverrdbg),

       // Miscellaneous debug signals
       .DBGROMADDR                  ({28{1'b0}}),
       .DBGROMADDRV                 (1'b0),
       .DBGACK                      (),
       .nCOMMIRQ                    (),
       .COMMRX                      (),
       .COMMTX                      (),
       .EDBGRQ                      ({NUM_CPUS{1'b0}}),
       .DBGEN                       ({NUM_CPUS{1'b1}}),
       .NIDEN                       ({NUM_CPUS{1'b1}}),
       .SPIDEN                      ({NUM_CPUS{1'b1}}),
       .SPNIDEN                     ({NUM_CPUS{1'b1}}),
       .DBGRSTREQ                   (),
       .DBGNOPWRDWN                 (),
       .DBGPWRDUP                   ({NUM_CPUS{1'b1}}),
       .DBGPWRUPREQ                 (),
       .DBGL1RSTDISABLE             (1'b0),

       // ATB interface signals
       .ATCLKEN                     (1'b1),
       .ATREADYM0                   (atreadym0),
       .AFVALIDM0                   (afvalidm0),
       .ATDATAM0                    (atdatam0),
       .ATVALIDM0                   (atvalidm0),
       .ATBYTESM0                   (atbytesm0),
       .AFREADYM0                   (afreadym0),
       .ATIDM0                      (atidm0),

       // START CONFIG (NUM_CPUS > 1)
       .ATREADYM1                   (1'b0),
       .AFVALIDM1                   (1'b0),
       .ATDATAM1                    (),
       .ATVALIDM1                   (),
       .ATBYTESM1                   (),
       .AFREADYM1                   (),
       .ATIDM1                      (),

       // END CONFIG
       // START CONFIG (NUM_CPUS > 2)
       .ATREADYM2                   (1'b0),
       .AFVALIDM2                   (1'b0),
       .ATDATAM2                    (),
       .ATVALIDM2                   (),
       .ATBYTESM2                   (),
       .AFREADYM2                   (),
       .ATIDM2                      (),
       // END CONFIG
       // START CONFIG (NUM_CPUS > 3)
       .ATREADYM3                   (1'b0),
       .AFVALIDM3                   (1'b0),
       .ATDATAM3                    (),
       .ATVALIDM3                   (),
       .ATBYTESM3                   (),
       .AFREADYM3                   (),
       .ATIDM3                      (),
       // END CONFIG

       // Miscellaneous ETM signals
       .SYNCREQM0                   (1'b0),
        // START CONFIG (NUM_CPUS > 1)
       .SYNCREQM1                   (1'b0),
       // END CONFIG
        // START CONFIG (NUM_CPUS > 2)
       .SYNCREQM2                   (1'b0),
       // END CONFIG
        // START CONFIG (NUM_CPUS > 3)
       .SYNCREQM3                   (1'b0),
       // END CONFIG
       .TSVALUEB                    (cx_tsvalueb),

       // CTI interface signals:
       .CTICHIN                     (ctichin),
       .CTICHOUTACK                 (ctichoutack),
       .CTICHOUT                    (ctichout),
       .CTICHINACK                  (ctichinack),
       .CISBYPASS                   (1'b1),
       .CIHSBYPASS                  ({4{1'b1}}),
       .CTIIRQ                      (ctiirq),
       .CTIIRQACK                   ({NUM_CPUS{1'b1}}),

       // PMU signals
       .nPMUIRQ                     (),
       .PMUEVENT0                   (),
       // START CONFIG (NUM_CPUS > 1)
       .PMUEVENT1                   (),
       // END CONFIG
       // START CONFIG (NUM_CPUS > 2)
       .PMUEVENT2                   (),
       // END CONFIG
       // START CONFIG (NUM_CPUS > 3)
       .PMUEVENT3                   (),
       // END CONFIG

       // DFT signals
       .DFTSE                       (1'b0),
       .DFTRSTDISABLE               (1'b0),
       .DFTRAMHOLD                  (1'b0),
       .DFTMCPHOLD                  (1'b0),

       // MBIST interface signals
       .MBISTREQ                    (1'b0)
      );


  // START CONFIG intkit

  // CTIIRQ from the processor should be connected to the nIRQ.
  // Other interrupts can be combined with this as required
  assign nctiirq = ~ctiirq;

  //----------------------------------------------------------------------------
  // CoreSight subsystem
  //----------------------------------------------------------------------------
  generate if (USE_DAPLITE) begin: GEN_CSSYS
    wire        cdbgpwrup;
    wire        csyspwrup;

    //Timestamp value: For DAPLite, this can be simply tied to 0
    assign cx_tsvalueb = {64{1'b0}};
    //CTI interfaces
    assign ctichin     = 4'b0000;
    assign ctichoutack = 4'b0000;
    //ATB interface
    assign atreadym0   = 1'b1;
    assign afvalidm0   = 1'b0;
    //APB paddrdbg31
    assign paddrdbg31  = paddrdbg[31];

    //Instanciate the DAP-Lite module
    DAPLITE u_cssys (
      // Outputs
      .TDO             (tdo_intf),
      .nTDOEN          (ntdoen_intf),
      .SWDO            (swdo_intf),
      .SWDOEN          (swdoen_intf),
      .JTAGNSW         (),
      .JTAGTOP         (),
      .CDBGPWRUPREQ    (cdbgpwrup),
      .CSYSPWRUPREQ    (csyspwrup),
      .CDBGRSTREQ      (),
      .DBGSWENABLE     (),
      .PRDATASYS       (),
      .PREADYSYS       (),
      .PSLVERRSYS      (),
      .PADDRDBG        (paddrdbg[31:2] ),
      .PENABLEDBG      (penabledbg),
      .PSELDBG         (pseldbg),
      .PWDATADBG       (pwdatadbg[31:0]),
      .PWRITEDBG       (pwritedbg),
      // Inputs
      .nPOTRST         (reset_n),
      .nTRST           (nTRST),
      .SWCLKTCK        (SWCLKTCK),
      .SWDITMS         (swditms_intf),
      .TDI             (tdi_intf),
      .CDBGPWRUPACK    (cdbgpwrup),
      .CSYSPWRUPACK    (csyspwrup),
      .CDBGRSTACK      (1'b0), //Tie this signal low if not used
      .nCDBGPWRDN      (1'b1),
      .nCSOCPWRDN      (1'b1),
      .DEVICEEN        (1'b1),
      .PCLKSYS         (clk),
      .PCLKENSYS       (1'b1),
      .PRESETSYSn      (reset_n),
      .PADDRSYS        (),
      .PSELSYS         (1'b0),
      .PWRITESYS       (1'b0),
      .PENABLESYS      (1'b0),
      .PWDATASYS       (),
      .PCLKDBG         (clk),
      .PCLKENDBG       (1'b1),
      .PRESETDBGn      (reset_n),
      .PRDATADBG       (prdatadbg[31:0]),
      .PREADYDBG       (preadydbg),
      .PSLVERRDBG      (pslverrdbg),
      .SE              (1'b0)
    ); //DAPLITE
  end
  else begin: GEN_CSSYS

    //Power control
    wire        cpwrupreq_csyspwrup;
    wire        cpwrupreq_cdbgpwrup;

    //TPIU interface
    wire        trace_clk;
    wire[31:0]  trace_data;
    wire        trace_ctl;

    //Timestamp
    wire[63:0]  tsvalue_wtimestamp;
    //Timestamp value: this is the value come from the CoreSight timestamp generator
    assign      cx_tsvalueb = tsvalue_wtimestamp;

    cssys_upv8 u_cssys (
    // Instance: cxatbreplicator_32b_prog_0, Port: ATBSlave
    .atvalid_atbin0     (atvalidm0),
    .atready_atbin0     (atreadym0),
    .atid_atbin0        (atidm0),
    .atbytes_atbin0     (atbytesm0),
    .atdata_atbin0      (atdatam0[31:0]),
    .afvalid_atbin0     (afvalidm0),
    .afready_atbin0     (afreadym0),

    // Instance: cxcti_0, Port: AuthenticationInterface
    .dbgen_authenticationinterface(1'b1),
    .niden_authenticationinterface(1'b1),

    // Instance: cxcti_0, Port: Staticcfg_SE
    .configuration_staticcfg_se_0 (1'b0),

    // Instance: cxctm_0, Port: ChannelInterface1Master
    .ch_channelinterface1master   (ctichin),
    .chack_channelinterface1master(ctichinack),

    // Instance: cxctm_0, Port: ChannelInterface1Slave
    .ch_channelinterface1slave    (ctichout),
    .chack_channelinterface1slave (ctichoutack),

    // Instance: cxtpiu_0, Port: Staticcfg_SE: TPIU Scan enable
    .configuration_staticcfg_se   (1'b0),

    // Instance: cxtpiu_0, Port: Staticcfg_TPCTL
    .configuration_staticcfg_tpctl(1'b0),

    // Instance: cxtpiu_0, Port: Staticcfg_TPMAXDATASIZE: TPIU maximum TRACEDATA width
    .configuration_staticcfg_tpmaxdatasize ({5{1'b1}}),

    // Instance: cxtpiu_0, Port: TraceOutPortIntf: OUTPUT
    .traceclk_traceoutportintf  (trace_clk),
    .tracedata_traceoutportintf (trace_data),
    .tracectl_traceoutportintf  (trace_ctl),

    // Instance: cxtsgen_0, Port: WTimestamp: OUTPUT
    .tsvalue_wtimestamp         (tsvalue_wtimestamp),
    .tsforcesync_wtimestamp     (),

    // Instance: cxapbic, Port: APB_Master0
    .paddr_apb_master0          (paddrdbg[21:2]),
    .paddr_apb_master0_1        (paddrdbg31),
    .pselx_apb_master0          (pseldbg),
    .penable_apb_master0        (penabledbg),
    .pwrite_apb_master0         (pwritedbg),
    .prdata_apb_master0         (prdatadbg[31:0]),
    .pwdata_apb_master0         (pwdatadbg[31:0]),
    .pready_apb_master0         (preadydbg),
    .pslverr_apb_master0        (pslverrdbg),

    // Instance: cxapbic, Port: APB_Slave1
    .paddr_apb_slave1           (),
    .pselx_apb_slave1           (1'b0),
    .penable_apb_slave1         (1'b0),
    .pwrite_apb_slave1          (1'b0),
    .prdata_apb_slave1          (),
    .pwdata_apb_slave1          (),
    .pready_apb_slave1          (),
    .pslverr_apb_slave1         (),

    // Instance: cxapbic, Port: Staticcfg_targetid
    // connect this siganl to the correct ID of your system
    .configuration_staticcfg_targetid_0 (32'h0000_0001),

    // Instance: u_dap_v8, Port: CDBGPWRUP
    .cpwrupreq_cdbgpwrup        (cpwrupreq_cdbgpwrup),
    .cpwrupack_cdbgpwrup        (cpwrupreq_cdbgpwrup),

    // Instance: u_dap_v8, Port: CDBGRST
    .cdbgrstreq_cdbgrst         (),
    .cdbgrstack_cdbgrst         (1'b0),           //Tie this signal low if not used

    // Instance: u_dap_v8, Port: CSYSPWRUP
    .cpwrupreq_csyspwrup        (cpwrupreq_csyspwrup),
    .cpwrupack_csyspwrup        (cpwrupreq_csyspwrup),

    // Instance: u_dap_v8, Port: SWJ
    .tdi_swj                    (tdi_intf),        //input: JTAG TAP Data In / Alternative input function
    .swditms_swj                (swditms_intf),    //input: SW Debug Data In / JTAG Test Mode Select
    .tdo_swj                    (tdo_intf),        //output: JTAG TAP Data Out
    .swdo_swj                   (swdo_intf),       //output: SW Data Out
    .swdoen_swj                 (swdoen_intf),     //output: SW Data Out Enable
    .ntdoen_swj                 (ntdoen_intf),     //output: TDO enable

    // Instance: u_dap_v8, Port: Staticcfg_deviceen
    .configuration_staticcfg_deviceen  (1'b1),  //apb ap enable

    // Instance: u_dap_v8, Port: Staticcfg_instanceid
    .configuration_staticcfg_instanceid ({4{1'b0}}),

    //  Non-bus signals
    .clk_0_0                    (clk),
    .clken_0_0                  (1'b1),
    .npotrst                    (reset_n),
    .ntrst_swj                  (nTRST),

    .reset_0_0                  (reset_n),
    .se                         (1'b0),
    .swclk                      (SWCLKTCK)
    );

    //----------------------------------------------------------------------------
    // logger modules
    //----------------------------------------------------------------------------
    // TPIU Monitor
    if (USE_TPIULOG) begin: GEN_TPIULOG
      TPIUMonitor #( .trace_file ("log.tpiu"))
         u_tpiu_monitor(
         .TRACECLK   (trace_clk),
         .TRACEDATA  (trace_data),
         .TRACECTL   (trace_ctl)
        );
    end

  end //GEN_CSSYS
  endgenerate
  //----------------------------------------------------------------------------
  // CXDT DebugTester subsystem
  //----------------------------------------------------------------------------

  //
  // Pullups/Pulldowns on DBG interface signals - these would normally be on the board
  //
  pullup   (nTRST);
  pullup   (TDI);
  pullup   (TDO);
  pullup   (SWDIOTMS);
  pullup   (SWCLKTCK);

  CXDT #( .IMAGENAME ("cxdt.bin"))
  u_cxdt(
    .CLK         (clk),
    .PORESETn    (reset_n),
    .TDO         (TDO),       //input
    .TDI         (TDI),       //output
    .nTRST       (nTRST),     //output
    .SWCLKTCK    (SWCLKTCK),  //output
    .SWDIOTMS    (SWDIOTMS)   //inout
    );

  //
  // Tri-State logic to convert the DAP IO into PAD IO
  //
  assign TDO          = tdo_intf;
  assign SWDIOTMS     = swdoen_intf ? swdo_intf : 1'bz;

  assign swditms_intf = SWDIOTMS;
  assign tdi_intf     = TDI;


  // END CONFIG


  //----------------------------------------------------------------------------
  // Validation subsystem
  //----------------------------------------------------------------------------

  generate if (ACE) begin : gen_ace_subsys
    execution_tb_val_sys_ace #(.NUM_CPUS(NUM_CPUS))
      u_execution_tb_val_sys_ace
        (// Clocks and resets
         .clk               (clk),
         .reset_n           (reset_n),

         // ACE interface (direct processor connection)
         .ace_awready_o     (ace_awready),
         .ace_awvalid_i     (ace_awvalid),
         .ace_awid_i        (ace_awid),
         .ace_awaddr_i      (ace_awaddr),
         .ace_awlen_i       (ace_awlen),
         .ace_awsize_i      (ace_awsize),
         .ace_awburst_i     (ace_awburst),
         .ace_awbar_i       (ace_awbar),
         .ace_awdomain_i    (ace_awdomain),
         .ace_awlock_i      (ace_awlock),
         .ace_awcache_i     (ace_awcache),
         .ace_awprot_i      (ace_awprot),
         .ace_awsnoop_i     (ace_awsnoop),
         .ace_awunique_i    (ace_awunique),
         .ace_wready_o      (ace_wready),
         .ace_wvalid_i      (ace_wvalid),
         .ace_wid_i         (ace_wid),
         .ace_wdata_i       (ace_wdata),
         .ace_wstrb_i       (ace_wstrb),
         .ace_wlast_i       (ace_wlast),
         .ace_bready_i      (ace_bready),
         .ace_bvalid_o      (ace_bvalid),
         .ace_bid_o         (ace_bid),
         .ace_bresp_o       (ace_bresp),
         .ace_arready_o     (ace_arready),
         .ace_arvalid_i     (ace_arvalid),
         .ace_arid_i        (ace_arid),
         .ace_araddr_i      (ace_araddr),
         .ace_arlen_i       (ace_arlen),
         .ace_arsize_i      (ace_arsize),
         .ace_arburst_i     (ace_arburst),
         .ace_arbar_i       (ace_arbar),
         .ace_ardomain_i    (ace_ardomain),
         .ace_arlock_i      (ace_arlock),
         .ace_arcache_i     (ace_arcache),
         .ace_arprot_i      (ace_arprot),
         .ace_arsnoop_i     (ace_arsnoop),
         .ace_rready_i      (ace_rready),
         .ace_rvalid_o      (ace_rvalid),
         .ace_rid_o         (ace_rid),
         .ace_rdata_o       (ace_rdata),
         .ace_rresp_o       (ace_rresp),
         .ace_rlast_o       (ace_rlast),
         .ace_acready_i     (ace_acready),
         .ace_acvalid_o     (ace_acvalid),
         .ace_acaddr_o      (ace_acaddr),
         .ace_acprot_o      (ace_acprot),
         .ace_acsnoop_o     (ace_acsnoop),
         .ace_crready_o     (ace_crready),
         .ace_crvalid_i     (ace_crvalid),
         .ace_crresp_i      (ace_crresp),
         .ace_cdready_o     (ace_cdready),
         .ace_cdvalid_i     (ace_cdvalid),
         .ace_cddata_i      (ace_cddata),
         .ace_cdlast_i      (ace_cdlast),
         .ace_rack_i        (ace_rack),
         .ace_wack_i        (ace_wack),

         // Trickbox
         .tbox_nfiq_o       (tbox_nfiq),
         .tbox_cntvalueb_o  (tbox_cntvalueb)
        );
  end else begin : gen_skyros_subsys
    // Note: the Skyros RX/TX nets in this module are named from the processor's
    // perspective and are connected to the opposite port on the validation
    // subsystem module
    execution_tb_val_sys_sky #(.NUM_CPUS (NUM_CPUS),
                               .HNINODEID(SKY_HNINODEID),
                               .MNNODEID (SKY_MNNODEID))
      u_execution_tb_val_sys_sky
        (// Clocks and resets
         .clk               (clk),
         .reset_n           (reset_n),

         // Link active states
         .rxlinkactivereq_i (sky_txlinkactivereq),
         .rxlinkactiveack_o (sky_txlinkactiveack),
         .txlinkactivereq_o (sky_rxlinkactivereq),
         .txlinkactiveack_i (sky_rxlinkactiveack),
         .txsactive_o       (sky_rxsactive),

         // Links
         .rxreqflitpend_i   (sky_txreqflitpend),
         .rxreqflitv_i      (sky_txreqflitv),
         .rxreqflit_i       (sky_txreqflit),
         .rxreqlcrdv_o      (sky_txreqlcrdv),
         .rxrspflitpend_i   (sky_txrspflitpend),
         .rxrspflitv_i      (sky_txrspflitv),
         .rxrspflit_i       (sky_txrspflit),
         .rxrsplcrdv_o      (sky_txrsplcrdv),
         .rxdatflitpend_i   (sky_txdatflitpend),
         .rxdatflitv_i      (sky_txdatflitv),
         .rxdatflit_i       (sky_txdatflit),
         .rxdatlcrdv_o      (sky_txdatlcrdv),
         .txrspflitpend_o   (sky_rxrspflitpend),
         .txrspflitv_o      (sky_rxrspflitv),
         .txrspflit_o       (sky_rxrspflit),
         .txrsplcrdv_i      (sky_rxrsplcrdv),
         .txdatflitpend_o   (sky_rxdatflitpend),
         .txdatflitv_o      (sky_rxdatflitv),
         .txdatflit_o       (sky_rxdatflit),
         .txdatlcrdv_i      (sky_rxdatlcrdv),
         .txsnpflitpend_o   (sky_rxsnpflitpend),
         .txsnpflitv_o      (sky_rxsnpflitv),
         .txsnpflit_o       (sky_rxsnpflit),
         .txsnplcrdv_i      (sky_rxsnplcrdv),

         // Trickbox
         .tbox_nfiq_o       (tbox_nfiq),
         .tbox_cntvalueb_o  (tbox_cntvalueb)
        );
  end endgenerate


  //----------------------------------------------------------------------------
  // Interface tie-offs
  //----------------------------------------------------------------------------

  // The processor is configured with either an ACE interface or a Skyros
  // interface.  The signals for the not-present interface are tied off here.
  generate if (ACE) begin : gen_skyros_stubs
    assign sky_rxsactive        = 1'b0;
    assign sky_txsactive        = 1'b0;
    assign sky_rxlinkactivereq  = 1'b0;
    assign sky_rxlinkactiveack  = 1'b0;
    assign sky_txlinkactivereq  = 1'b0;
    assign sky_txlinkactiveack  = 1'b0;
    assign sky_reqmemattr       = {8{1'b0}};
    assign sky_txreqflitpend    = 1'b0;
    assign sky_txreqflitv       = 1'b0;
    assign sky_txreqflit        = {100{1'b0}};
    assign sky_txreqlcrdv       = 1'b0;
    assign sky_txrspflitpend    = 1'b0;
    assign sky_txrspflitv       = 1'b0;
    assign sky_txrspflit        = {45{1'b0}};
    assign sky_txrsplcrdv       = 1'b0;
    assign sky_txdatflitpend    = 1'b0;
    assign sky_txdatflitv       = 1'b0;
    assign sky_txdatflit        = {194{1'b0}};
    assign sky_txdatlcrdv       = 1'b0;
    assign sky_rxrspflitpend    = 1'b0;
    assign sky_rxrspflitv       = 1'b0;
    assign sky_rxrspflit        = {45{1'b0}};
    assign sky_rxrsplcrdv       = 1'b0;
    assign sky_rxdatflitpend    = 1'b0;
    assign sky_rxdatflitv       = 1'b0;
    assign sky_rxdatflit        = {194{1'b0}};
    assign sky_rxdatlcrdv       = 1'b0;
    assign sky_rxsnpflitpend    = 1'b0;
    assign sky_rxsnpflitv       = 1'b0;
    assign sky_rxsnpflit        = {65{1'b0}};
    assign sky_rxsnplcrdv       = 1'b0;
  end else begin : gen_ace_stubs
    assign ace_awready          = 1'b0;
    assign ace_awvalid          = 1'b0;
    assign ace_awid             = {5{1'b0}};
    assign ace_awaddr           = {44{1'b0}};
    assign ace_awlen            = {8{1'b0}};
    assign ace_awsize           = {3{1'b0}};
    assign ace_awburst          = {2{1'b0}};
    assign ace_awbar            = {2{1'b0}};
    assign ace_awdomain         = {2{1'b0}};
    assign ace_awlock           = 1'b0;
    assign ace_awcache          = {4{1'b0}};
    assign ace_awprot           = {3{1'b0}};
    assign ace_awsnoop          = {3{1'b0}};
    assign ace_awunique         = 1'b0;
    assign ace_wready           = 1'b0;
    assign ace_wvalid           = 1'b0;
    assign ace_wid              = {5{1'b0}};
    assign ace_wdata            = {128{1'b0}};
    assign ace_wstrb            = {16{1'b0}};
    assign ace_wlast            = 1'b0;
    assign ace_bready           = 1'b0;
    assign ace_bvalid           = 1'b0;
    assign ace_bid              = {5{1'b0}};
    assign ace_bresp            = {2{1'b0}};
    assign ace_arready          = 1'b0;
    assign ace_arvalid          = 1'b0;
    assign ace_arid             = {5{1'b0}};
    assign ace_araddr           = {44{1'b0}};
    assign ace_arlen            = {8{1'b0}};
    assign ace_arsize           = {3{1'b0}};
    assign ace_arburst          = {2{1'b0}};
    assign ace_arbar            = {2{1'b0}};
    assign ace_ardomain         = {2{1'b0}};
    assign ace_arlock           = 1'b0;
    assign ace_arcache          = {4{1'b0}};
    assign ace_arprot           = {3{1'b0}};
    assign ace_arsnoop          = {4{1'b0}};
    assign ace_rready           = 1'b0;
    assign ace_rvalid           = 1'b0;
    assign ace_rid              = {6{1'b0}};
    assign ace_rdata            = {128{1'b0}};
    assign ace_rresp            = {4{1'b0}};
    assign ace_rlast            = 1'b0;
    assign ace_acready          = 1'b0;
    assign ace_acvalid          = 1'b0;
    assign ace_acaddr           = {44{1'b0}};
    assign ace_acprot           = {3{1'b0}};
    assign ace_acsnoop          = {4{1'b0}};
    assign ace_crready          = 1'b0;
    assign ace_crvalid          = 1'b0;
    assign ace_crresp           = {5{1'b0}};
    assign ace_cdready          = 1'b0;
    assign ace_cdvalid          = 1'b0;
    assign ace_cddata           = {127{1'b0}};
    assign ace_cdlast           = 1'b0;
    assign ace_rack             = 1'b0;
    assign ace_wack             = 1'b0;
  end endgenerate

  // START CONFIG (!intkit)
  // Tie off the interfaces that are only used in integration kit.
  //  - Debug APB
  assign pclkendbg   = 1'b0;
  assign pseldbg     = 1'b0;
  assign paddrdbg    = {20{1'b0}};
  assign paddrdbg31  = 1'b0;
  assign penabledbg  = 1'b0;
  assign pwritedbg   = 1'b0;
  assign pwdatadbg   = {32{1'b0}};
  //Timestamp value
  assign cx_tsvalueb = {64{1'b0}};
  // CTI interface
  assign ctichin     = 4'b0000;
  assign ctichoutack = 4'b0000;
  assign nctiirq     = {NUM_CPUS{1'b1}};
  //  - ATB
  assign atreadym0   = 1'b1;
  assign afvalidm0   = 1'b0;
  //END CONFIG


  //----------------------------------------------------------------------------
  // VCD dump
  //
  //   +dumpon=<start>  : Dump VCD from <start> ns
  //   +dumpoff=<end>   : Stop VCD dump at <end> ns
  //
  // If either +dumpon=<start> or +dumpoff=<end> is specified then dumps are
  // created between <start> ns and <end> ns.  The default start is 0ns and the
  // default end is unbound.
  //
  // If neither +dumpon nor +dumpoff is specified then no VCD dump is created.
  //
  // VCD dumps capture the complete hierarchy starting at the Cortex-A53
  // processor instantiation.
  //----------------------------------------------------------------------------

  // The vcd_dump signal represents the dump state:
  //   0: Do not dump
  //   1: Start when $time > dumpon
  //   2: Stop when $time > dumpoff
  initial begin
    dumpon  = 32'h00000000;
    dumpoff = 32'h00000000;

    // Set timeformat to a nano-second timescale for printing
    $timeformat(-9, 0, "ns", 9);
    dumpon_set  = $value$plusargs("dumpon=%d", dumpon);
    dumpoff_set = $value$plusargs("dumpoff=%d", dumpoff);

    if (dumpon_set || dumpoff_set)
      dump = 2'b01;
    else
      dump = 2'b00;

    if (dump > 0) begin
      if (dumpoff > 0) $display("Dumping VCD to dump.vcd from time %0t to time %0t", dumpon, dumpoff);
      else             $display("Dumping VCD to dump.vcd from time %0t", dumpon);
    end
  end

  always @ (posedge clk) begin
    // Start dumping
    if ((dump == 2'b01) && ($time > dumpon)) begin
      $display("VCD dump started at time %0t", $time);
      $dumpfile("dump.vcd");
      $dumpvars(0, u_cortexa53);
      $dumpon;
      dump = 2'b10;
    end

    // Continue dumping until dumpoff time
    if ((dump == 2'b10) && (dumpoff > 0) && ($time > dumpoff)) begin
      $display("VCD dump stopped at time %0t", $time);
      $dumpoff;
      dump = 2'b00;
    end
  end


  //----------------------------------------------------------------------------
  // Watchdog
  //
  //   The watchdog logic monitors the DPU for activity.  If no DPU activity is
  //   detected for many cycles then terminate the simulation with an error.
  //
  //   This logic is removed in netlist simulations.
  //----------------------------------------------------------------------------

`ifndef ARM_TB_WATCHDOG_DISABLE
  initial begin
    watchdog_count = 32'h00000000;

    // Set the watchdog timeout from the plusarg or set to the default if
    // the plusarg is not specified.
    if (!$value$plusargs("watchdog_timeout=%d", watchdog_timeout))
      watchdog_timeout = 32'h00400000;
  end

  // Reset the watchdog counter whenever a processor is reset or when the DPU in
  // any CPU pops an instruction.  On any other cycle increment the counter.
  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      watchdog_count <= 32'h00000000;
    else
      watchdog_count <= nxt_watchdog_count;

  assign nxt_watchdog_count = (|watchdog_clear) ? 32'h00000000 : (watchdog_count + 1'b1);

  generate for (i=0; i<4; i=i+1) begin : gen_watchdog
    if (i < NUM_CPUS)
      assign watchdog_clear[i] = u_cortexa53.g_ca53_cpu[i].u_ca53_cpu.u_ca53_noram.u_ca53dpu.u_dpu_de.u_iq.iq_pop[0] & ~standbywfi[i];
    else
      assign watchdog_clear[i] = 1'b0;
  end endgenerate

  // Terminate the simulation when the watchdog counter exceeds the maximum.
  // Disable the check completely when the timeout is set to zero (or less.)
  always @ (posedge clk)
    if ((watchdog_timeout > 0) && (watchdog_count > watchdog_timeout)) begin
      $display("WATCHDOG: No CPU activity for %0d cycles, terminating simulation", watchdog_timeout);
      $display("WATCHDOG: ** TEST FAILED **");
      $finish;
    end
`endif

endmodule

