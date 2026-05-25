//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2001-2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
//  Abstract            : BusMatrix is the top-level which connects together
//                        the required Input Stages, MatrixDecodes, Output
//                        Stages and Output Arbitration blocks.
//
//                        Supports the following configured options:
//
//                         - Architecture type 'ahb2',
//                         - 2 slave ports (connecting to masters),
//                         - 5 master ports (connecting to slaves),
//                         - Routing address width of 32 bits,
//                         - Routing data width of 32 bits,
//                         - xUSER signal width of 2 bits,
//                         - Arbiter type 'round',
//                         - Connectivity mapping:
//                             INITCM0 -> TARGROM, TARGRAM, TARGCRYPTO, TARGPERIPH, TARGDEBUG, 
//                             INITCA -> TARGROM, TARGRAM,
//                         - Connectivity type 'sparse'.
//
//------------------------------------------------------------------------------


`timescale 1ns/1ps


module cm0p_mtx (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System address remapping control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HSELINITCM0,
    HADDRINITCM0,
    HTRANSINITCM0,
    HWRITEINITCM0,
    HSIZEINITCM0,
    HBURSTINITCM0,
    HPROTINITCM0,
    HMASTERINITCM0,
    HWDATAINITCM0,
    HMASTLOCKINITCM0,
    HREADYINITCM0,
    HAUSERINITCM0,
    HWUSERINITCM0,

    // Input port SI1 (inputs from master 1)
    HSELINITCA,
    HADDRINITCA,
    HTRANSINITCA,
    HWRITEINITCA,
    HSIZEINITCA,
    HBURSTINITCA,
    HPROTINITCA,
    HMASTERINITCA,
    HWDATAINITCA,
    HMASTLOCKINITCA,
    HREADYINITCA,
    HAUSERINITCA,
    HWUSERINITCA,

    // Output port MI0 (inputs from slave 0)
    HRDATATARGROM,
    HREADYOUTTARGROM,
    HRESPTARGROM,
    HRUSERTARGROM,

    // Output port MI1 (inputs from slave 1)
    HRDATATARGRAM,
    HREADYOUTTARGRAM,
    HRESPTARGRAM,
    HRUSERTARGRAM,

    // Output port MI2 (inputs from slave 2)
    HRDATATARGCRYPTO,
    HREADYOUTTARGCRYPTO,
    HRESPTARGCRYPTO,
    HRUSERTARGCRYPTO,

    // Output port MI3 (inputs from slave 3)
    HRDATATARGPERIPH,
    HREADYOUTTARGPERIPH,
    HRESPTARGPERIPH,
    HRUSERTARGPERIPH,

    // Output port MI4 (inputs from slave 4)
    HRDATATARGDEBUG,
    HREADYOUTTARGDEBUG,
    HRESPTARGDEBUG,
    HRUSERTARGDEBUG,

    // Scan test dummy signals; not connected until scan insertion
    SCANENABLE,   // Scan Test Mode Enable
    SCANINHCLK,   // Scan Chain Input


    // Output port MI0 (outputs to slave 0)
    HSELTARGROM,
    HADDRTARGROM,
    HTRANSTARGROM,
    HWRITETARGROM,
    HSIZETARGROM,
    HBURSTTARGROM,
    HPROTTARGROM,
    HMASTERTARGROM,
    HWDATATARGROM,
    HMASTLOCKTARGROM,
    HREADYMUXTARGROM,
    HAUSERTARGROM,
    HWUSERTARGROM,

    // Output port MI1 (outputs to slave 1)
    HSELTARGRAM,
    HADDRTARGRAM,
    HTRANSTARGRAM,
    HWRITETARGRAM,
    HSIZETARGRAM,
    HBURSTTARGRAM,
    HPROTTARGRAM,
    HMASTERTARGRAM,
    HWDATATARGRAM,
    HMASTLOCKTARGRAM,
    HREADYMUXTARGRAM,
    HAUSERTARGRAM,
    HWUSERTARGRAM,

    // Output port MI2 (outputs to slave 2)
    HSELTARGCRYPTO,
    HADDRTARGCRYPTO,
    HTRANSTARGCRYPTO,
    HWRITETARGCRYPTO,
    HSIZETARGCRYPTO,
    HBURSTTARGCRYPTO,
    HPROTTARGCRYPTO,
    HMASTERTARGCRYPTO,
    HWDATATARGCRYPTO,
    HMASTLOCKTARGCRYPTO,
    HREADYMUXTARGCRYPTO,
    HAUSERTARGCRYPTO,
    HWUSERTARGCRYPTO,

    // Output port MI3 (outputs to slave 3)
    HSELTARGPERIPH,
    HADDRTARGPERIPH,
    HTRANSTARGPERIPH,
    HWRITETARGPERIPH,
    HSIZETARGPERIPH,
    HBURSTTARGPERIPH,
    HPROTTARGPERIPH,
    HMASTERTARGPERIPH,
    HWDATATARGPERIPH,
    HMASTLOCKTARGPERIPH,
    HREADYMUXTARGPERIPH,
    HAUSERTARGPERIPH,
    HWUSERTARGPERIPH,

    // Output port MI4 (outputs to slave 4)
    HSELTARGDEBUG,
    HADDRTARGDEBUG,
    HTRANSTARGDEBUG,
    HWRITETARGDEBUG,
    HSIZETARGDEBUG,
    HBURSTTARGDEBUG,
    HPROTTARGDEBUG,
    HMASTERTARGDEBUG,
    HWDATATARGDEBUG,
    HMASTLOCKTARGDEBUG,
    HREADYMUXTARGDEBUG,
    HAUSERTARGDEBUG,
    HWUSERTARGDEBUG,

    // Input port SI0 (outputs to master 0)
    HRDATAINITCM0,
    HREADYOUTINITCM0,
    HRESPINITCM0,
    HRUSERINITCM0,

    // Input port SI1 (outputs to master 1)
    HRDATAINITCA,
    HREADYOUTINITCA,
    HRESPINITCA,
    HRUSERINITCA,

    // Scan test dummy signals; not connected until scan insertion
    SCANOUTHCLK   // Scan Chain Output

    );


// -----------------------------------------------------------------------------
// Input and Output declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    input         HCLK;            // AHB System Clock
    input         HRESETn;         // AHB System Reset

    // System address remapping control
    input   [3:0] REMAP;           // REMAP input

    // Input port SI0 (inputs from master 0)
    input         HSELINITCM0;          // Slave Select
    input  [31:0] HADDRINITCM0;         // Address bus
    input   [1:0] HTRANSINITCM0;        // Transfer type
    input         HWRITEINITCM0;        // Transfer direction
    input   [2:0] HSIZEINITCM0;         // Transfer size
    input   [2:0] HBURSTINITCM0;        // Burst type
    input   [3:0] HPROTINITCM0;         // Protection control
    input   [3:0] HMASTERINITCM0;       // Master select
    input  [31:0] HWDATAINITCM0;        // Write data
    input         HMASTLOCKINITCM0;     // Locked Sequence
    input         HREADYINITCM0;        // Transfer done
    input  [1:0] HAUSERINITCM0;        // Address USER signals
    input  [1:0] HWUSERINITCM0;        // Write-data USER signals

    // Input port SI1 (inputs from master 1)
    input         HSELINITCA;          // Slave Select
    input  [31:0] HADDRINITCA;         // Address bus
    input   [1:0] HTRANSINITCA;        // Transfer type
    input         HWRITEINITCA;        // Transfer direction
    input   [2:0] HSIZEINITCA;         // Transfer size
    input   [2:0] HBURSTINITCA;        // Burst type
    input   [3:0] HPROTINITCA;         // Protection control
    input   [3:0] HMASTERINITCA;       // Master select
    input  [31:0] HWDATAINITCA;        // Write data
    input         HMASTLOCKINITCA;     // Locked Sequence
    input         HREADYINITCA;        // Transfer done
    input  [1:0] HAUSERINITCA;        // Address USER signals
    input  [1:0] HWUSERINITCA;        // Write-data USER signals

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATATARGROM;        // Read data bus
    input         HREADYOUTTARGROM;     // HREADY feedback
    input   [1:0] HRESPTARGROM;         // Transfer response
    input  [1:0] HRUSERTARGROM;        // Read-data USER signals

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATATARGRAM;        // Read data bus
    input         HREADYOUTTARGRAM;     // HREADY feedback
    input   [1:0] HRESPTARGRAM;         // Transfer response
    input  [1:0] HRUSERTARGRAM;        // Read-data USER signals

    // Output port MI2 (inputs from slave 2)
    input  [31:0] HRDATATARGCRYPTO;        // Read data bus
    input         HREADYOUTTARGCRYPTO;     // HREADY feedback
    input   [1:0] HRESPTARGCRYPTO;         // Transfer response
    input  [1:0] HRUSERTARGCRYPTO;        // Read-data USER signals

    // Output port MI3 (inputs from slave 3)
    input  [31:0] HRDATATARGPERIPH;        // Read data bus
    input         HREADYOUTTARGPERIPH;     // HREADY feedback
    input   [1:0] HRESPTARGPERIPH;         // Transfer response
    input  [1:0] HRUSERTARGPERIPH;        // Read-data USER signals

    // Output port MI4 (inputs from slave 4)
    input  [31:0] HRDATATARGDEBUG;        // Read data bus
    input         HREADYOUTTARGDEBUG;     // HREADY feedback
    input   [1:0] HRESPTARGDEBUG;         // Transfer response
    input  [1:0] HRUSERTARGDEBUG;        // Read-data USER signals

    // Scan test dummy signals; not connected until scan insertion
    input         SCANENABLE;      // Scan enable signal
    input         SCANINHCLK;      // HCLK scan input


    // Output port MI0 (outputs to slave 0)
    output        HSELTARGROM;          // Slave Select
    output [31:0] HADDRTARGROM;         // Address bus
    output  [1:0] HTRANSTARGROM;        // Transfer type
    output        HWRITETARGROM;        // Transfer direction
    output  [2:0] HSIZETARGROM;         // Transfer size
    output  [2:0] HBURSTTARGROM;        // Burst type
    output  [3:0] HPROTTARGROM;         // Protection control
    output  [3:0] HMASTERTARGROM;       // Master select
    output [31:0] HWDATATARGROM;        // Write data
    output        HMASTLOCKTARGROM;     // Locked Sequence
    output        HREADYMUXTARGROM;     // Transfer done
    output [1:0] HAUSERTARGROM;        // Address USER signals
    output [1:0] HWUSERTARGROM;        // Write-data USER signals

    // Output port MI1 (outputs to slave 1)
    output        HSELTARGRAM;          // Slave Select
    output [31:0] HADDRTARGRAM;         // Address bus
    output  [1:0] HTRANSTARGRAM;        // Transfer type
    output        HWRITETARGRAM;        // Transfer direction
    output  [2:0] HSIZETARGRAM;         // Transfer size
    output  [2:0] HBURSTTARGRAM;        // Burst type
    output  [3:0] HPROTTARGRAM;         // Protection control
    output  [3:0] HMASTERTARGRAM;       // Master select
    output [31:0] HWDATATARGRAM;        // Write data
    output        HMASTLOCKTARGRAM;     // Locked Sequence
    output        HREADYMUXTARGRAM;     // Transfer done
    output [1:0] HAUSERTARGRAM;        // Address USER signals
    output [1:0] HWUSERTARGRAM;        // Write-data USER signals

    // Output port MI2 (outputs to slave 2)
    output        HSELTARGCRYPTO;          // Slave Select
    output [31:0] HADDRTARGCRYPTO;         // Address bus
    output  [1:0] HTRANSTARGCRYPTO;        // Transfer type
    output        HWRITETARGCRYPTO;        // Transfer direction
    output  [2:0] HSIZETARGCRYPTO;         // Transfer size
    output  [2:0] HBURSTTARGCRYPTO;        // Burst type
    output  [3:0] HPROTTARGCRYPTO;         // Protection control
    output  [3:0] HMASTERTARGCRYPTO;       // Master select
    output [31:0] HWDATATARGCRYPTO;        // Write data
    output        HMASTLOCKTARGCRYPTO;     // Locked Sequence
    output        HREADYMUXTARGCRYPTO;     // Transfer done
    output [1:0] HAUSERTARGCRYPTO;        // Address USER signals
    output [1:0] HWUSERTARGCRYPTO;        // Write-data USER signals

    // Output port MI3 (outputs to slave 3)
    output        HSELTARGPERIPH;          // Slave Select
    output [31:0] HADDRTARGPERIPH;         // Address bus
    output  [1:0] HTRANSTARGPERIPH;        // Transfer type
    output        HWRITETARGPERIPH;        // Transfer direction
    output  [2:0] HSIZETARGPERIPH;         // Transfer size
    output  [2:0] HBURSTTARGPERIPH;        // Burst type
    output  [3:0] HPROTTARGPERIPH;         // Protection control
    output  [3:0] HMASTERTARGPERIPH;       // Master select
    output [31:0] HWDATATARGPERIPH;        // Write data
    output        HMASTLOCKTARGPERIPH;     // Locked Sequence
    output        HREADYMUXTARGPERIPH;     // Transfer done
    output [1:0] HAUSERTARGPERIPH;        // Address USER signals
    output [1:0] HWUSERTARGPERIPH;        // Write-data USER signals

    // Output port MI4 (outputs to slave 4)
    output        HSELTARGDEBUG;          // Slave Select
    output [31:0] HADDRTARGDEBUG;         // Address bus
    output  [1:0] HTRANSTARGDEBUG;        // Transfer type
    output        HWRITETARGDEBUG;        // Transfer direction
    output  [2:0] HSIZETARGDEBUG;         // Transfer size
    output  [2:0] HBURSTTARGDEBUG;        // Burst type
    output  [3:0] HPROTTARGDEBUG;         // Protection control
    output  [3:0] HMASTERTARGDEBUG;       // Master select
    output [31:0] HWDATATARGDEBUG;        // Write data
    output        HMASTLOCKTARGDEBUG;     // Locked Sequence
    output        HREADYMUXTARGDEBUG;     // Transfer done
    output [1:0] HAUSERTARGDEBUG;        // Address USER signals
    output [1:0] HWUSERTARGDEBUG;        // Write-data USER signals

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATAINITCM0;        // Read data bus
    output        HREADYOUTINITCM0;     // HREADY feedback
    output  [1:0] HRESPINITCM0;         // Transfer response
    output [1:0] HRUSERINITCM0;        // Read-data USER signals

    // Input port SI1 (outputs to master 1)
    output [31:0] HRDATAINITCA;        // Read data bus
    output        HREADYOUTINITCA;     // HREADY feedback
    output  [1:0] HRESPINITCA;         // Transfer response
    output [1:0] HRUSERINITCA;        // Read-data USER signals

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output


// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System address remapping control
    wire   [3:0] REMAP;           // REMAP signal

    // Input Port SI0
    wire         HSELINITCM0;          // Slave Select
    wire  [31:0] HADDRINITCM0;         // Address bus
    wire   [1:0] HTRANSINITCM0;        // Transfer type
    wire         HWRITEINITCM0;        // Transfer direction
    wire   [2:0] HSIZEINITCM0;         // Transfer size
    wire   [2:0] HBURSTINITCM0;        // Burst type
    wire   [3:0] HPROTINITCM0;         // Protection control
    wire   [3:0] HMASTERINITCM0;       // Master select
    wire  [31:0] HWDATAINITCM0;        // Write data
    wire         HMASTLOCKINITCM0;     // Locked Sequence
    wire         HREADYINITCM0;        // Transfer done

    wire  [31:0] HRDATAINITCM0;        // Read data bus
    wire         HREADYOUTINITCM0;     // HREADY feedback
    wire   [1:0] HRESPINITCM0;         // Transfer response
    wire  [1:0] HAUSERINITCM0;        // Address USER signals
    wire  [1:0] HWUSERINITCM0;        // Write-data USER signals
    wire  [1:0] HRUSERINITCM0;        // Read-data USER signals

    // Input Port SI1
    wire         HSELINITCA;          // Slave Select
    wire  [31:0] HADDRINITCA;         // Address bus
    wire   [1:0] HTRANSINITCA;        // Transfer type
    wire         HWRITEINITCA;        // Transfer direction
    wire   [2:0] HSIZEINITCA;         // Transfer size
    wire   [2:0] HBURSTINITCA;        // Burst type
    wire   [3:0] HPROTINITCA;         // Protection control
    wire   [3:0] HMASTERINITCA;       // Master select
    wire  [31:0] HWDATAINITCA;        // Write data
    wire         HMASTLOCKINITCA;     // Locked Sequence
    wire         HREADYINITCA;        // Transfer done

    wire  [31:0] HRDATAINITCA;        // Read data bus
    wire         HREADYOUTINITCA;     // HREADY feedback
    wire   [1:0] HRESPINITCA;         // Transfer response
    wire  [1:0] HAUSERINITCA;        // Address USER signals
    wire  [1:0] HWUSERINITCA;        // Write-data USER signals
    wire  [1:0] HRUSERINITCA;        // Read-data USER signals

    // Output Port MI0
    wire         HSELTARGROM;          // Slave Select
    wire  [31:0] HADDRTARGROM;         // Address bus
    wire   [1:0] HTRANSTARGROM;        // Transfer type
    wire         HWRITETARGROM;        // Transfer direction
    wire   [2:0] HSIZETARGROM;         // Transfer size
    wire   [2:0] HBURSTTARGROM;        // Burst type
    wire   [3:0] HPROTTARGROM;         // Protection control
    wire   [3:0] HMASTERTARGROM;       // Master select
    wire  [31:0] HWDATATARGROM;        // Write data
    wire         HMASTLOCKTARGROM;     // Locked Sequence
    wire         HREADYMUXTARGROM;     // Transfer done

    wire  [31:0] HRDATATARGROM;        // Read data bus
    wire         HREADYOUTTARGROM;     // HREADY feedback
    wire   [1:0] HRESPTARGROM;         // Transfer response
    wire  [1:0] HAUSERTARGROM;        // Address USER signals
    wire  [1:0] HWUSERTARGROM;        // Write-data USER signals
    wire  [1:0] HRUSERTARGROM;        // Read-data USER signals

    // Output Port MI1
    wire         HSELTARGRAM;          // Slave Select
    wire  [31:0] HADDRTARGRAM;         // Address bus
    wire   [1:0] HTRANSTARGRAM;        // Transfer type
    wire         HWRITETARGRAM;        // Transfer direction
    wire   [2:0] HSIZETARGRAM;         // Transfer size
    wire   [2:0] HBURSTTARGRAM;        // Burst type
    wire   [3:0] HPROTTARGRAM;         // Protection control
    wire   [3:0] HMASTERTARGRAM;       // Master select
    wire  [31:0] HWDATATARGRAM;        // Write data
    wire         HMASTLOCKTARGRAM;     // Locked Sequence
    wire         HREADYMUXTARGRAM;     // Transfer done

    wire  [31:0] HRDATATARGRAM;        // Read data bus
    wire         HREADYOUTTARGRAM;     // HREADY feedback
    wire   [1:0] HRESPTARGRAM;         // Transfer response
    wire  [1:0] HAUSERTARGRAM;        // Address USER signals
    wire  [1:0] HWUSERTARGRAM;        // Write-data USER signals
    wire  [1:0] HRUSERTARGRAM;        // Read-data USER signals

    // Output Port MI2
    wire         HSELTARGCRYPTO;          // Slave Select
    wire  [31:0] HADDRTARGCRYPTO;         // Address bus
    wire   [1:0] HTRANSTARGCRYPTO;        // Transfer type
    wire         HWRITETARGCRYPTO;        // Transfer direction
    wire   [2:0] HSIZETARGCRYPTO;         // Transfer size
    wire   [2:0] HBURSTTARGCRYPTO;        // Burst type
    wire   [3:0] HPROTTARGCRYPTO;         // Protection control
    wire   [3:0] HMASTERTARGCRYPTO;       // Master select
    wire  [31:0] HWDATATARGCRYPTO;        // Write data
    wire         HMASTLOCKTARGCRYPTO;     // Locked Sequence
    wire         HREADYMUXTARGCRYPTO;     // Transfer done

    wire  [31:0] HRDATATARGCRYPTO;        // Read data bus
    wire         HREADYOUTTARGCRYPTO;     // HREADY feedback
    wire   [1:0] HRESPTARGCRYPTO;         // Transfer response
    wire  [1:0] HAUSERTARGCRYPTO;        // Address USER signals
    wire  [1:0] HWUSERTARGCRYPTO;        // Write-data USER signals
    wire  [1:0] HRUSERTARGCRYPTO;        // Read-data USER signals

    // Output Port MI3
    wire         HSELTARGPERIPH;          // Slave Select
    wire  [31:0] HADDRTARGPERIPH;         // Address bus
    wire   [1:0] HTRANSTARGPERIPH;        // Transfer type
    wire         HWRITETARGPERIPH;        // Transfer direction
    wire   [2:0] HSIZETARGPERIPH;         // Transfer size
    wire   [2:0] HBURSTTARGPERIPH;        // Burst type
    wire   [3:0] HPROTTARGPERIPH;         // Protection control
    wire   [3:0] HMASTERTARGPERIPH;       // Master select
    wire  [31:0] HWDATATARGPERIPH;        // Write data
    wire         HMASTLOCKTARGPERIPH;     // Locked Sequence
    wire         HREADYMUXTARGPERIPH;     // Transfer done

    wire  [31:0] HRDATATARGPERIPH;        // Read data bus
    wire         HREADYOUTTARGPERIPH;     // HREADY feedback
    wire   [1:0] HRESPTARGPERIPH;         // Transfer response
    wire  [1:0] HAUSERTARGPERIPH;        // Address USER signals
    wire  [1:0] HWUSERTARGPERIPH;        // Write-data USER signals
    wire  [1:0] HRUSERTARGPERIPH;        // Read-data USER signals

    // Output Port MI4
    wire         HSELTARGDEBUG;          // Slave Select
    wire  [31:0] HADDRTARGDEBUG;         // Address bus
    wire   [1:0] HTRANSTARGDEBUG;        // Transfer type
    wire         HWRITETARGDEBUG;        // Transfer direction
    wire   [2:0] HSIZETARGDEBUG;         // Transfer size
    wire   [2:0] HBURSTTARGDEBUG;        // Burst type
    wire   [3:0] HPROTTARGDEBUG;         // Protection control
    wire   [3:0] HMASTERTARGDEBUG;       // Master select
    wire  [31:0] HWDATATARGDEBUG;        // Write data
    wire         HMASTLOCKTARGDEBUG;     // Locked Sequence
    wire         HREADYMUXTARGDEBUG;     // Transfer done

    wire  [31:0] HRDATATARGDEBUG;        // Read data bus
    wire         HREADYOUTTARGDEBUG;     // HREADY feedback
    wire   [1:0] HRESPTARGDEBUG;         // Transfer response
    wire  [1:0] HAUSERTARGDEBUG;        // Address USER signals
    wire  [1:0] HWUSERTARGDEBUG;        // Write-data USER signals
    wire  [1:0] HRUSERTARGDEBUG;        // Read-data USER signals


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------

    // Bus-switch input SI0
    wire         i_sel0;            // HSEL signal
    wire  [31:0] i_addr0;           // HADDR signal
    wire   [1:0] i_trans0;          // HTRANS signal
    wire         i_write0;          // HWRITE signal
    wire   [2:0] i_size0;           // HSIZE signal
    wire   [2:0] i_burst0;          // HBURST signal
    wire   [3:0] i_prot0;           // HPROTS signal
    wire   [3:0] i_master0;         // HMASTER signal
    wire         i_mastlock0;       // HMASTLOCK signal
    wire         i_active0;         // Active signal
    wire         i_held_tran0;       // HeldTran signal
    wire         i_readyout0;       // Readyout signal
    wire   [1:0] i_resp0;           // Response signal
    wire  [1:0] i_auser0;          // HAUSER signal

    // Bus-switch input SI1
    wire         i_sel1;            // HSEL signal
    wire  [31:0] i_addr1;           // HADDR signal
    wire   [1:0] i_trans1;          // HTRANS signal
    wire         i_write1;          // HWRITE signal
    wire   [2:0] i_size1;           // HSIZE signal
    wire   [2:0] i_burst1;          // HBURST signal
    wire   [3:0] i_prot1;           // HPROTS signal
    wire   [3:0] i_master1;         // HMASTER signal
    wire         i_mastlock1;       // HMASTLOCK signal
    wire         i_active1;         // Active signal
    wire         i_held_tran1;       // HeldTran signal
    wire         i_readyout1;       // Readyout signal
    wire   [1:0] i_resp1;           // Response signal
    wire  [1:0] i_auser1;          // HAUSER signal

    // Bus-switch SI0 to MI0 signals
    wire         i_sel0to0;         // Routing selection signal
    wire         i_active0to0;      // Active signal

    // Bus-switch SI0 to MI1 signals
    wire         i_sel0to1;         // Routing selection signal
    wire         i_active0to1;      // Active signal

    // Bus-switch SI0 to MI2 signals
    wire         i_sel0to2;         // Routing selection signal
    wire         i_active0to2;      // Active signal

    // Bus-switch SI0 to MI3 signals
    wire         i_sel0to3;         // Routing selection signal
    wire         i_active0to3;      // Active signal

    // Bus-switch SI0 to MI4 signals
    wire         i_sel0to4;         // Routing selection signal
    wire         i_active0to4;      // Active signal

    // Bus-switch SI1 to MI0 signals
    wire         i_sel1to0;         // Routing selection signal
    wire         i_active1to0;      // Active signal

    // Bus-switch SI1 to MI1 signals
    wire         i_sel1to1;         // Routing selection signal
    wire         i_active1to1;      // Active signal

    wire         i_hready_mux_targrom;    // Internal HREADYMUXM for MI0
    wire         i_hready_mux_targram;    // Internal HREADYMUXM for MI1
    wire         i_hready_mux_targcrypto;    // Internal HREADYMUXM for MI2
    wire         i_hready_mux_targperiph;    // Internal HREADYMUXM for MI3
    wire         i_hready_mux_targdebug;    // Internal HREADYMUXM for MI4


// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

  // Input stage for SI0
  cm0p_mtx_in_stage u_cm0p_mtx_in_stage_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSELINITCM0),
    .HADDRS     (HADDRINITCM0),
    .HTRANSS    (HTRANSINITCM0),
    .HWRITES    (HWRITEINITCM0),
    .HSIZES     (HSIZEINITCM0),
    .HBURSTS    (HBURSTINITCM0),
    .HPROTS     (HPROTINITCM0),
    .HMASTERS   (HMASTERINITCM0),
    .HMASTLOCKS (HMASTLOCKINITCM0),
    .HREADYS    (HREADYINITCM0),
    .HAUSERS    (HAUSERINITCM0),

    // Internal Response
    .active_ip     (i_active0),
    .readyout_ip   (i_readyout0),
    .resp_ip       (i_resp0),

    // Input Port Response
    .HREADYOUTS (HREADYOUTINITCM0),
    .HRESPS     (HRESPINITCM0),

    // Internal Address/Control Signals
    .sel_ip        (i_sel0),
    .addr_ip       (i_addr0),
    .auser_ip      (i_auser0),
    .trans_ip      (i_trans0),
    .write_ip      (i_write0),
    .size_ip       (i_size0),
    .burst_ip      (i_burst0),
    .prot_ip       (i_prot0),
    .master_ip     (i_master0),
    .mastlock_ip   (i_mastlock0),
    .held_tran_ip   (i_held_tran0)

    );


  // Input stage for SI1
  cm0p_mtx_in_stage u_cm0p_mtx_in_stage_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSELINITCA),
    .HADDRS     (HADDRINITCA),
    .HTRANSS    (HTRANSINITCA),
    .HWRITES    (HWRITEINITCA),
    .HSIZES     (HSIZEINITCA),
    .HBURSTS    (HBURSTINITCA),
    .HPROTS     (HPROTINITCA),
    .HMASTERS   (HMASTERINITCA),
    .HMASTLOCKS (HMASTLOCKINITCA),
    .HREADYS    (HREADYINITCA),
    .HAUSERS    (HAUSERINITCA),

    // Internal Response
    .active_ip     (i_active1),
    .readyout_ip   (i_readyout1),
    .resp_ip       (i_resp1),

    // Input Port Response
    .HREADYOUTS (HREADYOUTINITCA),
    .HRESPS     (HRESPINITCA),

    // Internal Address/Control Signals
    .sel_ip        (i_sel1),
    .addr_ip       (i_addr1),
    .auser_ip      (i_auser1),
    .trans_ip      (i_trans1),
    .write_ip      (i_write1),
    .size_ip       (i_size1),
    .burst_ip      (i_burst1),
    .prot_ip       (i_prot1),
    .master_ip     (i_master1),
    .mastlock_ip   (i_mastlock1),
    .held_tran_ip   (i_held_tran1)

    );


  // Matrix decoder for SI0
  cm0p_mtx_decoderINITCM0 u_cm0p_mtx_decoderinitcm0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Signals from Input stage SI0
    .HREADYS    (HREADYINITCM0),
    .sel_dec        (i_sel0),
    .decode_addr_dec (i_addr0[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans0),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active0to0),
    .readyout_dec0  (i_hready_mux_targrom),
    .resp_dec0      (HRESPTARGROM),
    .rdata_dec0     (HRDATATARGROM),
    .ruser_dec0     (HRUSERTARGROM),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active0to1),
    .readyout_dec1  (i_hready_mux_targram),
    .resp_dec1      (HRESPTARGRAM),
    .rdata_dec1     (HRDATATARGRAM),
    .ruser_dec1     (HRUSERTARGRAM),

    // Control/Response for Output Stage MI2
    .active_dec2    (i_active0to2),
    .readyout_dec2  (i_hready_mux_targcrypto),
    .resp_dec2      (HRESPTARGCRYPTO),
    .rdata_dec2     (HRDATATARGCRYPTO),
    .ruser_dec2     (HRUSERTARGCRYPTO),

    // Control/Response for Output Stage MI3
    .active_dec3    (i_active0to3),
    .readyout_dec3  (i_hready_mux_targperiph),
    .resp_dec3      (HRESPTARGPERIPH),
    .rdata_dec3     (HRDATATARGPERIPH),
    .ruser_dec3     (HRUSERTARGPERIPH),

    // Control/Response for Output Stage MI4
    .active_dec4    (i_active0to4),
    .readyout_dec4  (i_hready_mux_targdebug),
    .resp_dec4      (HRESPTARGDEBUG),
    .rdata_dec4     (HRDATATARGDEBUG),
    .ruser_dec4     (HRUSERTARGDEBUG),

    .sel_dec0       (i_sel0to0),
    .sel_dec1       (i_sel0to1),
    .sel_dec2       (i_sel0to2),
    .sel_dec3       (i_sel0to3),
    .sel_dec4       (i_sel0to4),

    .active_dec     (i_active0),
    .HREADYOUTS (i_readyout0),
    .HRESPS     (i_resp0),
    .HRUSERS    (HRUSERINITCM0),
    .HRDATAS    (HRDATAINITCM0)

    );


  // Matrix decoder for SI1
  cm0p_mtx_decoderINITCA u_cm0p_mtx_decoderinitca (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Signals from Input stage SI1
    .HREADYS    (HREADYINITCA),
    .sel_dec        (i_sel1),
    .decode_addr_dec (i_addr1[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans1),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active1to0),
    .readyout_dec0  (i_hready_mux_targrom),
    .resp_dec0      (HRESPTARGROM),
    .rdata_dec0     (HRDATATARGROM),
    .ruser_dec0     (HRUSERTARGROM),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active1to1),
    .readyout_dec1  (i_hready_mux_targram),
    .resp_dec1      (HRESPTARGRAM),
    .rdata_dec1     (HRDATATARGRAM),
    .ruser_dec1     (HRUSERTARGRAM),

    .sel_dec0       (i_sel1to0),
    .sel_dec1       (i_sel1to1),

    .active_dec     (i_active1),
    .HREADYOUTS (i_readyout1),
    .HRESPS     (i_resp1),
    .HRUSERS    (HRUSERINITCA),
    .HRDATAS    (HRDATAINITCA)

    );


  // Output stage for MI0
  cm0p_mtx_outTARGROM u_cm0p_mtx_outtargrom_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to0),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM0),
    .wuser_op0     (HWUSERINITCM0),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to0),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCA),
    .wuser_op1     (HWUSERINITCA),
    .held_tran_op1  (i_held_tran1),

    // Slave read data and response
    .HREADYOUTM (HREADYOUTTARGROM),

    .active_op0    (i_active0to0),
    .active_op1    (i_active1to0),

    // Slave Address/Control Signals
    .HSELM      (HSELTARGROM),
    .HADDRM     (HADDRTARGROM),
    .HAUSERM    (HAUSERTARGROM),
    .HTRANSM    (HTRANSTARGROM),
    .HWRITEM    (HWRITETARGROM),
    .HSIZEM     (HSIZETARGROM),
    .HBURSTM    (HBURSTTARGROM),
    .HPROTM     (HPROTTARGROM),
    .HMASTERM   (HMASTERTARGROM),
    .HMASTLOCKM (HMASTLOCKTARGROM),
    .HREADYMUXM (i_hready_mux_targrom),
    .HWUSERM    (HWUSERTARGROM),
    .HWDATAM    (HWDATATARGROM)

    );

  // Drive output with internal version
  assign HREADYMUXTARGROM = i_hready_mux_targrom;


  // Output stage for MI1
  cm0p_mtx_outTARGRAM u_cm0p_mtx_outtargram_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to1),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM0),
    .wuser_op0     (HWUSERINITCM0),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to1),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCA),
    .wuser_op1     (HWUSERINITCA),
    .held_tran_op1  (i_held_tran1),

    // Slave read data and response
    .HREADYOUTM (HREADYOUTTARGRAM),

    .active_op0    (i_active0to1),
    .active_op1    (i_active1to1),

    // Slave Address/Control Signals
    .HSELM      (HSELTARGRAM),
    .HADDRM     (HADDRTARGRAM),
    .HAUSERM    (HAUSERTARGRAM),
    .HTRANSM    (HTRANSTARGRAM),
    .HWRITEM    (HWRITETARGRAM),
    .HSIZEM     (HSIZETARGRAM),
    .HBURSTM    (HBURSTTARGRAM),
    .HPROTM     (HPROTTARGRAM),
    .HMASTERM   (HMASTERTARGRAM),
    .HMASTLOCKM (HMASTLOCKTARGRAM),
    .HREADYMUXM (i_hready_mux_targram),
    .HWUSERM    (HWUSERTARGRAM),
    .HWDATAM    (HWDATATARGRAM)

    );

  // Drive output with internal version
  assign HREADYMUXTARGRAM = i_hready_mux_targram;


  // Output stage for MI2
  cm0p_mtx_outTARGCRYPTO u_cm0p_mtx_outtargcrypto_2 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to2),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM0),
    .wuser_op0     (HWUSERINITCM0),
    .held_tran_op0  (i_held_tran0),

    // Slave read data and response
    .HREADYOUTM (HREADYOUTTARGCRYPTO),

    .active_op0    (i_active0to2),

    // Slave Address/Control Signals
    .HSELM      (HSELTARGCRYPTO),
    .HADDRM     (HADDRTARGCRYPTO),
    .HAUSERM    (HAUSERTARGCRYPTO),
    .HTRANSM    (HTRANSTARGCRYPTO),
    .HWRITEM    (HWRITETARGCRYPTO),
    .HSIZEM     (HSIZETARGCRYPTO),
    .HBURSTM    (HBURSTTARGCRYPTO),
    .HPROTM     (HPROTTARGCRYPTO),
    .HMASTERM   (HMASTERTARGCRYPTO),
    .HMASTLOCKM (HMASTLOCKTARGCRYPTO),
    .HREADYMUXM (i_hready_mux_targcrypto),
    .HWUSERM    (HWUSERTARGCRYPTO),
    .HWDATAM    (HWDATATARGCRYPTO)

    );

  // Drive output with internal version
  assign HREADYMUXTARGCRYPTO = i_hready_mux_targcrypto;


  // Output stage for MI3
  cm0p_mtx_outTARGPERIPH u_cm0p_mtx_outtargperiph_3 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to3),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM0),
    .wuser_op0     (HWUSERINITCM0),
    .held_tran_op0  (i_held_tran0),

    // Slave read data and response
    .HREADYOUTM (HREADYOUTTARGPERIPH),

    .active_op0    (i_active0to3),

    // Slave Address/Control Signals
    .HSELM      (HSELTARGPERIPH),
    .HADDRM     (HADDRTARGPERIPH),
    .HAUSERM    (HAUSERTARGPERIPH),
    .HTRANSM    (HTRANSTARGPERIPH),
    .HWRITEM    (HWRITETARGPERIPH),
    .HSIZEM     (HSIZETARGPERIPH),
    .HBURSTM    (HBURSTTARGPERIPH),
    .HPROTM     (HPROTTARGPERIPH),
    .HMASTERM   (HMASTERTARGPERIPH),
    .HMASTLOCKM (HMASTLOCKTARGPERIPH),
    .HREADYMUXM (i_hready_mux_targperiph),
    .HWUSERM    (HWUSERTARGPERIPH),
    .HWDATAM    (HWDATATARGPERIPH)

    );

  // Drive output with internal version
  assign HREADYMUXTARGPERIPH = i_hready_mux_targperiph;


  // Output stage for MI4
  cm0p_mtx_outTARGDEBUG u_cm0p_mtx_outtargdebug_4 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to4),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM0),
    .wuser_op0     (HWUSERINITCM0),
    .held_tran_op0  (i_held_tran0),

    // Slave read data and response
    .HREADYOUTM (HREADYOUTTARGDEBUG),

    .active_op0    (i_active0to4),

    // Slave Address/Control Signals
    .HSELM      (HSELTARGDEBUG),
    .HADDRM     (HADDRTARGDEBUG),
    .HAUSERM    (HAUSERTARGDEBUG),
    .HTRANSM    (HTRANSTARGDEBUG),
    .HWRITEM    (HWRITETARGDEBUG),
    .HSIZEM     (HSIZETARGDEBUG),
    .HBURSTM    (HBURSTTARGDEBUG),
    .HPROTM     (HPROTTARGDEBUG),
    .HMASTERM   (HMASTERTARGDEBUG),
    .HMASTLOCKM (HMASTLOCKTARGDEBUG),
    .HREADYMUXM (i_hready_mux_targdebug),
    .HWUSERM    (HWUSERTARGDEBUG),
    .HWDATAM    (HWDATATARGDEBUG)

    );

  // Drive output with internal version
  assign HREADYMUXTARGDEBUG = i_hready_mux_targdebug;


endmodule

// --================================= End ===================================--
