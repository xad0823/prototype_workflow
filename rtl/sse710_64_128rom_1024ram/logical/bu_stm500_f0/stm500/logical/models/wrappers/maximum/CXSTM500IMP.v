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
//      Checked In          : $Date: 2013-12-16 17:35:16 +0000 (Mon, 16 Dec 2013) $
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Top Level Module for STM
//-----------------------------------------------------------------------------

module CXSTM500IMP
  (
  // --------------------------------------------------------------------------
  // Clocks and Resets
  // --------------------------------------------------------------------------
  input wire                     CLK,         // STM Clock
  input wire                     ARESETn,     // AXI Reset
  input wire                     STMRESETn,   // STM Reset
  // --------------------------------------------------------------------------
  // AXI Slave Interface
  // --------------------------------------------------------------------------
  // AR Channel
  input wire [23:0]              ARIDS,        // Read Address ID
  input wire [31:0]              ARADDRS,      // Read Address
  input wire [7:0]               ARLENS,       // Read Burst Length
  input wire [2:0]               ARSIZES,      // Read Burst Size
  input wire [1:0]               ARBURSTS,     // Read Burst Type
  input wire                     ARLOCKS,      // Read Lock Type
  input wire [3:0]               ARCACHES,     // Read Cache Type
  input wire [2:0]               ARPROTS,      // Read Protection Type
  input wire                     ARVALIDS,     // Read Address Valid
  output wire                    ARREADYS,     // Read Address Ready
  // R Channel
  input  wire                    RREADYS,      // Read Data Ready
  output wire [23:0]             RIDS,         // Read Data ID
  output wire [63:0]             RDATAS,       // Read Data
  output wire [1:0]              RRESPS,       // Read Response
  output wire                    RLASTS,       // Read Data Last
  output wire                    RVALIDS,      // Read Data Valid
  // AW Channel
  input wire [23:0]              AWIDS,        // Write Address ID
  input wire [31:0]              AWADDRS,      // Write Address
  input wire [7:0]               AWLENS,       // Write Burst Length
  input wire [2:0]               AWSIZES,      // Write Burst Size
  input wire [1:0]               AWBURSTS,     // Write Burst Type
  input wire                     AWLOCKS,      // Write Lock Type
  input wire [3:0]               AWCACHES,     // Write Cache Type
  input wire [2:0]               AWPROTS,      // Write Protection Type
  input wire                     AWVALIDS,     // Write Address Valid
  output wire                    AWREADYS,     // Write Address Ready
  // W Channel
  input wire [63:0]              WDATAS,       // Write Data
  input wire [7:0]               WSTRBS,       // Write Strobes
  input wire                     WLASTS,       // Write Data Last
  input wire                     WVALIDS,      // Write Data Valid
  output wire                    WREADYS,      // Write Data Ready
  // B Channel
  input wire                     BREADYS,      // Write Response Ready
  output wire [23:0]             BIDS,         // Write Response ID
  output wire [1:0]              BRESPS,       // Write Response
  output wire                    BVALIDS,      // Write Response Valid
  // --------------------------------------------------------------------------
  // Debug APB Slave Interface
  // --------------------------------------------------------------------------
  input wire                     PSELDBG,      // APB slave select
  input wire                     PENABLEDBG,   // APB enable
  input wire                     PWRITEDBG,    // APB write
  input wire                     PADDRDBG31,   // APB internal vs external access select
  input wire [11:2]              PADDRDBG,     // APB address
  input wire [31:0]              PWDATADBG,    // APB write data
  output wire                    PREADYDBG,    // APB ready
  output wire                    PSLVERRDBG,   // APB slave error
  output wire [31:0]             PRDATADBG,    // APB read data
  // --------------------------------------------------------------------------
  // ATB Master Interface
  // --------------------------------------------------------------------------
  input wire                     ATREADYM,     // ATB ready
  input wire                     AFVALIDM,     // ATB flush valid
  input wire                     SYNCREQM,      // ATB synchronization request
  output wire                    ATVALIDM,     // ATB valid
  output wire [2:0]              ATBYTESM,     // ATB bytes
  output wire [63:0]             ATDATAM,      // ATB data
  output wire [6:0]              ATIDM,        // ATB ID
  output wire                    AFREADYM,     // ATB flush ready
  // --------------------------------------------------------------------------
  // Hardware Event Observation Port
  // --------------------------------------------------------------------------
  input wire  [63:0]             HWEVENTS,     // Hardware Events
  output wire [7:0]              HEEXTMUX,     // Hardware Event External Multiplexor Control
  // --------------------------------------------------------------------------
  // DMA Peripheral Request Interface
  // --------------------------------------------------------------------------
  input wire                     DRREADY,      // DMA Request Ready
  input wire                     DAVALID,      // DMA Acknowledge Valid
  input wire [1:0]               DATYPE,       // DMA Acknowledge Type
  output wire                    DRVALID,      // DMA Request Valid
  output wire [1:0]              DRTYPE,       // DMA Request Type
  output wire                    DRLAST,       // DMA Last Request
  output wire                    DAREADY,      // DMA Acknowledge Ready
  // --------------------------------------------------------------------------
  // Timestamp Port
  // --------------------------------------------------------------------------
  input wire [63:0]              TSVALUE,      // Timestamp value
  // --------------------------------------------------------------------------
  // Authentication Interface
  // --------------------------------------------------------------------------
  input wire                     DBGEN,        // Invasive debug enable
  input wire                     NIDEN,        // Non-invasive debug enable
  input wire                     SPIDEN,       // Secure invasive debug enable
  input wire                     SPNIDEN,      // Secure non-invasive debug enable
  // --------------------------------------------------------------------------
  // Non-secure AXI access control
  // --------------------------------------------------------------------------
  input wire                     NSGUAREN,     // Enable non-secure guaranteed stimulus port accesses
  // --------------------------------------------------------------------------
  // Cross-Triggering Interface
  // --------------------------------------------------------------------------
  output wire                    TRIGOUTSPTE,  // Trigger output event, matches using STMSPTER
  output wire                    TRIGOUTSW,    // Trigger output event, writes to TRIG location
  output wire                    TRIGOUTHETE,  // Trigger output event, matches using STMHETER
  output wire                    ASYNCOUT,     // Async sequence has been output event
  // --------------------------------------------------------------------------
  // Test Interface
  // --------------------------------------------------------------------------
  input wire                     DFTCLKCGEN,   // Force STM clock gates on in test mode
  //---------------------------------------------------------------------------
  // AXI Q-Channel Interface
  //---------------------------------------------------------------------------
  input  wire                    AXIQREQn,     //Quiscence Request

  output wire                    AXIQACCEPTn,  //Quiscence Request Acknowledge
  output wire                    AXIQDENY,     //Quiscence Request Deny
  output wire                    AXIQACTIVE,   //STM Active

  input  wire                    AWAKEUP,      //AXI Active Signal
  //---------------------------------------------------------------------------
  // STM Q-Channel Interface
  //---------------------------------------------------------------------------
  input  wire                    STMQREQn,     //Quiscence Request

  output wire                    STMQACCEPTn,  //Quiscence Request Acknowledge
  output wire                    STMQDENY,     //Quiscence Request Deny
  output wire                    STMQACTIVE,   //STM Active

  input  wire                    PWAKEUP       //APB Active Signal
  );

  // --------------------------------------------------------------------------
  // Local Parameters
  // --------------------------------------------------------------------------

  localparam        HWEVOBIF_PRESENT      = 1;              // Valid Values: 0 or 1
  localparam        AXI_ID_WIDTH          = 24;             // Valid Values: 2 - 24
  localparam        DATA_FIFO_DEPTH       = 32;             // Valid Values: 4/8/16/32
  localparam        CHN_FIFO_DEPTH        = 32;             // Valid Values: 4/8/16/32
  localparam [31:0] HWEVOBIF_CONFIG_63_32 = 32'h0000_0000;  // Any Value
  localparam [31:0] HWEVOBIF_CONFIG_31_0  = 32'hFFFF_FFFF;  // Any Value

  //----------------------------------------------------------------------------
  // Instantiate STM
  //----------------------------------------------------------------------------

  CXSTM500 #(
    .HWEVOBIF_PRESENT      (HWEVOBIF_PRESENT),
    .AXI_ID_WIDTH          (AXI_ID_WIDTH),
    .DATA_FIFO_DEPTH       (DATA_FIFO_DEPTH),
    .CHN_FIFO_DEPTH        (CHN_FIFO_DEPTH),
    .HWEVOBIF_CONFIG_63_32 (HWEVOBIF_CONFIG_63_32),
    .HWEVOBIF_CONFIG_31_0  (HWEVOBIF_CONFIG_31_0)

  ) u_cxstm500 (

  // --------------------------------------------------------------------------
  // Clocks and Resets
  // --------------------------------------------------------------------------
  .CLK                      (CLK),         // STM Clock
  .ARESETn                  (ARESETn),     // AXI Reset
  .STMRESETn                (STMRESETn),   // STM Reset
  // --------------------------------------------------------------------------
  // AXI Slave Interface
  // --------------------------------------------------------------------------
  // AR Channel
  .ARIDS                    (ARIDS),        // Read Address ID
  .ARADDRS                  (ARADDRS),      // Read Address
  .ARLENS                   (ARLENS),       // Read Burst Length
  .ARSIZES                  (ARSIZES),      // Read Burst Size
  .ARBURSTS                 (ARBURSTS),     // Read Burst Type
  .ARLOCKS                  (ARLOCKS),      // Read Lock Type
  .ARCACHES                 (ARCACHES),     // Read Cache Type
  .ARPROTS                  (ARPROTS),      // Read Protection Type
  .ARVALIDS                 (ARVALIDS),     // Read Address Valid
  .ARREADYS                 (ARREADYS),     // Read Address Ready
  // R Channel
  .RREADYS                  (RREADYS),      // Read Data Ready
  .RIDS                     (RIDS),         // Read Data ID
  .RDATAS                   (RDATAS),       // Read Data
  .RRESPS                   (RRESPS),       // Read Response
  .RLASTS                   (RLASTS),       // Read Data Last
  .RVALIDS                  (RVALIDS),      // Read Data Valid
  // AW Channel
  .AWIDS                    (AWIDS),        // Write Address ID
  .AWADDRS                  (AWADDRS),      // Write Address
  .AWLENS                   (AWLENS),       // Write Burst Length
  .AWSIZES                  (AWSIZES),      // Write Burst Size
  .AWBURSTS                 (AWBURSTS),     // Write Burst Type
  .AWLOCKS                  (AWLOCKS),      // Write Lock Type
  .AWCACHES                 (AWCACHES),     // Write Cache Type
  .AWPROTS                  (AWPROTS),      // Write Protection Type
  .AWVALIDS                 (AWVALIDS),     // Write Address Valid
  .AWREADYS                 (AWREADYS),     // Write Address Ready
  // W Channel
  .WDATAS                   (WDATAS),       // Write Data
  .WSTRBS                   (WSTRBS),       // Write Strobes
  .WLASTS                   (WLASTS),       // Write Data Last
  .WVALIDS                  (WVALIDS),      // Write Data Valid
  .WREADYS                  (WREADYS),      // Write Data Ready
  // B Channel
  .BREADYS                  (BREADYS),      // Write Response Ready
  .BIDS                     (BIDS),         // Write Response ID
  .BRESPS                   (BRESPS),       // Write Response
  .BVALIDS                  (BVALIDS),      // Write Response Valid
  // --------------------------------------------------------------------------
  // Debug APB Slave Interface
  // --------------------------------------------------------------------------
  .PSELDBG                  (PSELDBG),      // APB slave select
  .PENABLEDBG               (PENABLEDBG),   // APB enable
  .PWRITEDBG                (PWRITEDBG),    // APB write
  .PADDRDBG31               (PADDRDBG31),   // APB internal vs external access select
  .PADDRDBG                 (PADDRDBG),     // APB address
  .PWDATADBG                (PWDATADBG),    // APB write data
  .PREADYDBG                (PREADYDBG),    // APB ready
  .PSLVERRDBG               (PSLVERRDBG),   // APB slave error
  .PRDATADBG                (PRDATADBG),    // APB read data
  // --------------------------------------------------------------------------
  // ATB Master Interface
  // --------------------------------------------------------------------------
  .ATREADYM                 (ATREADYM),     // ATB ready
  .AFVALIDM                 (AFVALIDM),     // ATB flush valid
  .SYNCREQM                 (SYNCREQM),      // ATB synchronization request
  .ATVALIDM                 (ATVALIDM),     // ATB valid
  .ATBYTESM                 (ATBYTESM),     // ATB bytes
  .ATDATAM                  (ATDATAM),      // ATB data
  .ATIDM                    (ATIDM),        // ATB ID
  .AFREADYM                 (AFREADYM),     // ATB flush ready
  // --------------------------------------------------------------------------
  // Hardware Event Observation Port
  // --------------------------------------------------------------------------
  .HWEVENTS                 (HWEVENTS),     // Hardware Events
  .HEEXTMUX                 (HEEXTMUX),     // Hardware Event External Multiplexor Control
  // --------------------------------------------------------------------------
  // DMA Peripheral Request Interface
  // --------------------------------------------------------------------------
  .DRREADY                  (DRREADY),      // DMA Request Ready
  .DAVALID                  (DAVALID),      // DMA Acknowledge Valid
  .DATYPE                   (DATYPE),       // DMA Acknowledge Type
  .DRVALID                  (DRVALID),      // DMA Request Valid
  .DRTYPE                   (DRTYPE),       // DMA Request Type
  .DRLAST                   (DRLAST),       // DMA Last Request
  .DAREADY                  (DAREADY),      // DMA Acknowledge Ready
  // --------------------------------------------------------------------------
  // Timestamp Port
  // --------------------------------------------------------------------------
  .TSVALUE                  (TSVALUE),      // Timestamp value
  // --------------------------------------------------------------------------
  // Authentication Interface
  // --------------------------------------------------------------------------
  .DBGEN                    (DBGEN),        // Invasive debug enable
  .NIDEN                    (NIDEN),        // Non-invasive debug enable
  .SPIDEN                   (SPIDEN),       // Secure invasive debug enable
  .SPNIDEN                  (SPNIDEN),      // Secure non-invasive debug enable
  // --------------------------------------------------------------------------
  // Non-secure AXI access control
  // --------------------------------------------------------------------------
  .NSGUAREN                 (NSGUAREN),     // Enable non-secure guaranteed stimulus port accesses
  // --------------------------------------------------------------------------
  // Cross-Triggering Interface
  // --------------------------------------------------------------------------
  .TRIGOUTSPTE              (TRIGOUTSPTE),  // Trigger output event, matches using STMSPTER
  .TRIGOUTSW                (TRIGOUTSW),    // Trigger output event, writes to TRIG location
  .TRIGOUTHETE              (TRIGOUTHETE),  // Trigger output event, matches using STMHETER
  .ASYNCOUT                 (ASYNCOUT),     // Async sequence has been output event
  // --------------------------------------------------------------------------
  // Test Interface
  // --------------------------------------------------------------------------
  .DFTCLKCGEN               (DFTCLKCGEN),   // Clock disable DFT control
  // --------------------------------------------------------------------------
  // Q-Channel Interface
  // --------------------------------------------------------------------------
  .AXIQREQn                 (AXIQREQn),     // Q-Channel Request
  .AXIQACCEPTn              (AXIQACCEPTn),  // Q-Channel Accept
  .AXIQDENY                 (AXIQDENY),     // Q-Channel Deny
  .AXIQACTIVE               (AXIQACTIVE),   // Q-Channel Active

  .AWAKEUP                  (AWAKEUP),      // AXI Active

  .STMQREQn                 (STMQREQn),     // Q-Channel Request
  .STMQACCEPTn              (STMQACCEPTn),  // Q-Channel Accept
  .STMQDENY                 (STMQDENY),     // Q-Channel Deny
  .STMQACTIVE               (STMQACTIVE),   // Q-Channel Active

  .PWAKEUP                  (PWAKEUP)       // APB Active
  );


endmodule // CXSTM500

