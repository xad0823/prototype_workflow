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
//  Abstract            : BusMatrixLite is a wrapper module that wraps around
//                        the BusMatrix module to give AHB Lite compliant
//                        slave and master interfaces.
//
//-----------------------------------------------------------------------------


`timescale 1ns/1ps


module cm0p_mtx_lite (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System Address Remap control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HADDRINITCM0,
    HTRANSINITCM0,
    HWRITEINITCM0,
    HSIZEINITCM0,
    HBURSTINITCM0,
    HPROTINITCM0,
    HWDATAINITCM0,
    HMASTLOCKINITCM0,
    HAUSERINITCM0,
    HWUSERINITCM0,

    // Input port SI1 (inputs from master 1)
    HADDRINITCA,
    HTRANSINITCA,
    HWRITEINITCA,
    HSIZEINITCA,
    HBURSTINITCA,
    HPROTINITCA,
    HWDATAINITCA,
    HMASTLOCKINITCA,
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
    HWDATATARGDEBUG,
    HMASTLOCKTARGDEBUG,
    HREADYMUXTARGDEBUG,
    HAUSERTARGDEBUG,
    HWUSERTARGDEBUG,

    // Input port SI0 (outputs to master 0)
    HRDATAINITCM0,
    HREADYINITCM0,
    HRESPINITCM0,
    HRUSERINITCM0,

    // Input port SI1 (outputs to master 1)
    HRDATAINITCA,
    HREADYINITCA,
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

    // System Address Remap control
    input   [3:0] REMAP;           // System Address REMAP control

    // Input port SI0 (inputs from master 0)
    input  [31:0] HADDRINITCM0;         // Address bus
    input   [1:0] HTRANSINITCM0;        // Transfer type
    input         HWRITEINITCM0;        // Transfer direction
    input   [2:0] HSIZEINITCM0;         // Transfer size
    input   [2:0] HBURSTINITCM0;        // Burst type
    input   [3:0] HPROTINITCM0;         // Protection control
    input  [31:0] HWDATAINITCM0;        // Write data
    input         HMASTLOCKINITCM0;     // Locked Sequence
    input  [1:0] HAUSERINITCM0;        // Address USER signals
    input  [1:0] HWUSERINITCM0;        // Write-data USER signals

    // Input port SI1 (inputs from master 1)
    input  [31:0] HADDRINITCA;         // Address bus
    input   [1:0] HTRANSINITCA;        // Transfer type
    input         HWRITEINITCA;        // Transfer direction
    input   [2:0] HSIZEINITCA;         // Transfer size
    input   [2:0] HBURSTINITCA;        // Burst type
    input   [3:0] HPROTINITCA;         // Protection control
    input  [31:0] HWDATAINITCA;        // Write data
    input         HMASTLOCKINITCA;     // Locked Sequence
    input  [1:0] HAUSERINITCA;        // Address USER signals
    input  [1:0] HWUSERINITCA;        // Write-data USER signals

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATATARGROM;        // Read data bus
    input         HREADYOUTTARGROM;     // HREADY feedback
    input         HRESPTARGROM;         // Transfer response
    input  [1:0] HRUSERTARGROM;        // Read-data USER signals

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATATARGRAM;        // Read data bus
    input         HREADYOUTTARGRAM;     // HREADY feedback
    input         HRESPTARGRAM;         // Transfer response
    input  [1:0] HRUSERTARGRAM;        // Read-data USER signals

    // Output port MI2 (inputs from slave 2)
    input  [31:0] HRDATATARGCRYPTO;        // Read data bus
    input         HREADYOUTTARGCRYPTO;     // HREADY feedback
    input         HRESPTARGCRYPTO;         // Transfer response
    input  [1:0] HRUSERTARGCRYPTO;        // Read-data USER signals

    // Output port MI3 (inputs from slave 3)
    input  [31:0] HRDATATARGPERIPH;        // Read data bus
    input         HREADYOUTTARGPERIPH;     // HREADY feedback
    input         HRESPTARGPERIPH;         // Transfer response
    input  [1:0] HRUSERTARGPERIPH;        // Read-data USER signals

    // Output port MI4 (inputs from slave 4)
    input  [31:0] HRDATATARGDEBUG;        // Read data bus
    input         HREADYOUTTARGDEBUG;     // HREADY feedback
    input         HRESPTARGDEBUG;         // Transfer response
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
    output [31:0] HWDATATARGDEBUG;        // Write data
    output        HMASTLOCKTARGDEBUG;     // Locked Sequence
    output        HREADYMUXTARGDEBUG;     // Transfer done
    output [1:0] HAUSERTARGDEBUG;        // Address USER signals
    output [1:0] HWUSERTARGDEBUG;        // Write-data USER signals

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATAINITCM0;        // Read data bus
    output        HREADYINITCM0;     // HREADY feedback
    output        HRESPINITCM0;         // Transfer response
    output [1:0] HRUSERINITCM0;        // Read-data USER signals

    // Input port SI1 (outputs to master 1)
    output [31:0] HRDATAINITCA;        // Read data bus
    output        HREADYINITCA;     // HREADY feedback
    output        HRESPINITCA;         // Transfer response
    output [1:0] HRUSERINITCA;        // Read-data USER signals

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output

// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System Address Remap control
    wire   [3:0] REMAP;           // System REMAP signal

    // Input Port SI0
    wire  [31:0] HADDRINITCM0;         // Address bus
    wire   [1:0] HTRANSINITCM0;        // Transfer type
    wire         HWRITEINITCM0;        // Transfer direction
    wire   [2:0] HSIZEINITCM0;         // Transfer size
    wire   [2:0] HBURSTINITCM0;        // Burst type
    wire   [3:0] HPROTINITCM0;         // Protection control
    wire  [31:0] HWDATAINITCM0;        // Write data
    wire         HMASTLOCKINITCM0;     // Locked Sequence

    wire  [31:0] HRDATAINITCM0;        // Read data bus
    wire         HREADYINITCM0;     // HREADY feedback
    wire         HRESPINITCM0;         // Transfer response
    wire  [1:0] HAUSERINITCM0;        // Address USER signals
    wire  [1:0] HWUSERINITCM0;        // Write-data USER signals
    wire  [1:0] HRUSERINITCM0;        // Read-data USER signals

    // Input Port SI1
    wire  [31:0] HADDRINITCA;         // Address bus
    wire   [1:0] HTRANSINITCA;        // Transfer type
    wire         HWRITEINITCA;        // Transfer direction
    wire   [2:0] HSIZEINITCA;         // Transfer size
    wire   [2:0] HBURSTINITCA;        // Burst type
    wire   [3:0] HPROTINITCA;         // Protection control
    wire  [31:0] HWDATAINITCA;        // Write data
    wire         HMASTLOCKINITCA;     // Locked Sequence

    wire  [31:0] HRDATAINITCA;        // Read data bus
    wire         HREADYINITCA;     // HREADY feedback
    wire         HRESPINITCA;         // Transfer response
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
    wire  [31:0] HWDATATARGROM;        // Write data
    wire         HMASTLOCKTARGROM;     // Locked Sequence
    wire         HREADYMUXTARGROM;     // Transfer done

    wire  [31:0] HRDATATARGROM;        // Read data bus
    wire         HREADYOUTTARGROM;     // HREADY feedback
    wire         HRESPTARGROM;         // Transfer response
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
    wire  [31:0] HWDATATARGRAM;        // Write data
    wire         HMASTLOCKTARGRAM;     // Locked Sequence
    wire         HREADYMUXTARGRAM;     // Transfer done

    wire  [31:0] HRDATATARGRAM;        // Read data bus
    wire         HREADYOUTTARGRAM;     // HREADY feedback
    wire         HRESPTARGRAM;         // Transfer response
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
    wire  [31:0] HWDATATARGCRYPTO;        // Write data
    wire         HMASTLOCKTARGCRYPTO;     // Locked Sequence
    wire         HREADYMUXTARGCRYPTO;     // Transfer done

    wire  [31:0] HRDATATARGCRYPTO;        // Read data bus
    wire         HREADYOUTTARGCRYPTO;     // HREADY feedback
    wire         HRESPTARGCRYPTO;         // Transfer response
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
    wire  [31:0] HWDATATARGPERIPH;        // Write data
    wire         HMASTLOCKTARGPERIPH;     // Locked Sequence
    wire         HREADYMUXTARGPERIPH;     // Transfer done

    wire  [31:0] HRDATATARGPERIPH;        // Read data bus
    wire         HREADYOUTTARGPERIPH;     // HREADY feedback
    wire         HRESPTARGPERIPH;         // Transfer response
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
    wire  [31:0] HWDATATARGDEBUG;        // Write data
    wire         HMASTLOCKTARGDEBUG;     // Locked Sequence
    wire         HREADYMUXTARGDEBUG;     // Transfer done

    wire  [31:0] HRDATATARGDEBUG;        // Read data bus
    wire         HREADYOUTTARGDEBUG;     // HREADY feedback
    wire         HRESPTARGDEBUG;         // Transfer response
    wire  [1:0] HAUSERTARGDEBUG;        // Address USER signals
    wire  [1:0] HWUSERTARGDEBUG;        // Write-data USER signals
    wire  [1:0] HRUSERTARGDEBUG;        // Read-data USER signals


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------
    wire   [3:0] tie_hi_4;
    wire         tie_hi;
    wire         tie_low;
    wire   [1:0] i_hrespINITCM0;
    wire   [1:0] i_hrespINITCA;

    wire   [3:0]        i_hmasterTARGROM;
    wire   [1:0] i_hrespTARGROM;
    wire   [3:0]        i_hmasterTARGRAM;
    wire   [1:0] i_hrespTARGRAM;
    wire   [3:0]        i_hmasterTARGCRYPTO;
    wire   [1:0] i_hrespTARGCRYPTO;
    wire   [3:0]        i_hmasterTARGPERIPH;
    wire   [1:0] i_hrespTARGPERIPH;
    wire   [3:0]        i_hmasterTARGDEBUG;
    wire   [1:0] i_hrespTARGDEBUG;

// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

    assign tie_hi   = 1'b1;
    assign tie_hi_4 = 4'b1111;
    assign tie_low  = 1'b0;


    assign HRESPINITCM0  = i_hrespINITCM0[0];

    assign HRESPINITCA  = i_hrespINITCA[0];

    assign i_hrespTARGROM = {{1{tie_low}}, HRESPTARGROM};
    assign i_hrespTARGRAM = {{1{tie_low}}, HRESPTARGRAM};
    assign i_hrespTARGCRYPTO = {{1{tie_low}}, HRESPTARGCRYPTO};
    assign i_hrespTARGPERIPH = {{1{tie_low}}, HRESPTARGPERIPH};
    assign i_hrespTARGDEBUG = {{1{tie_low}}, HRESPTARGDEBUG};

// BusMatrix instance
  cm0p_mtx ucm0p_mtx (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .REMAP      (REMAP),

    // Input port SI0 signals
    .HSELINITCM0       (tie_hi),
    .HADDRINITCM0      (HADDRINITCM0),
    .HTRANSINITCM0     (HTRANSINITCM0),
    .HWRITEINITCM0     (HWRITEINITCM0),
    .HSIZEINITCM0      (HSIZEINITCM0),
    .HBURSTINITCM0     (HBURSTINITCM0),
    .HPROTINITCM0      (HPROTINITCM0),
    .HWDATAINITCM0     (HWDATAINITCM0),
    .HMASTLOCKINITCM0  (HMASTLOCKINITCM0),
    .HMASTERINITCM0    (tie_hi_4),
    .HREADYINITCM0     (HREADYINITCM0),
    .HAUSERINITCM0     (HAUSERINITCM0),
    .HWUSERINITCM0     (HWUSERINITCM0),
    .HRDATAINITCM0     (HRDATAINITCM0),
    .HREADYOUTINITCM0  (HREADYINITCM0),
    .HRESPINITCM0      (i_hrespINITCM0),
    .HRUSERINITCM0     (HRUSERINITCM0),

    // Input port SI1 signals
    .HSELINITCA       (tie_hi),
    .HADDRINITCA      (HADDRINITCA),
    .HTRANSINITCA     (HTRANSINITCA),
    .HWRITEINITCA     (HWRITEINITCA),
    .HSIZEINITCA      (HSIZEINITCA),
    .HBURSTINITCA     (HBURSTINITCA),
    .HPROTINITCA      (HPROTINITCA),
    .HWDATAINITCA     (HWDATAINITCA),
    .HMASTLOCKINITCA  (HMASTLOCKINITCA),
    .HMASTERINITCA    (tie_hi_4),
    .HREADYINITCA     (HREADYINITCA),
    .HAUSERINITCA     (HAUSERINITCA),
    .HWUSERINITCA     (HWUSERINITCA),
    .HRDATAINITCA     (HRDATAINITCA),
    .HREADYOUTINITCA  (HREADYINITCA),
    .HRESPINITCA      (i_hrespINITCA),
    .HRUSERINITCA     (HRUSERINITCA),


    // Output port MI0 signals
    .HSELTARGROM       (HSELTARGROM),
    .HADDRTARGROM      (HADDRTARGROM),
    .HTRANSTARGROM     (HTRANSTARGROM),
    .HWRITETARGROM     (HWRITETARGROM),
    .HSIZETARGROM      (HSIZETARGROM),
    .HBURSTTARGROM     (HBURSTTARGROM),
    .HPROTTARGROM      (HPROTTARGROM),
    .HWDATATARGROM     (HWDATATARGROM),
    .HMASTERTARGROM    (i_hmasterTARGROM),
    .HMASTLOCKTARGROM  (HMASTLOCKTARGROM),
    .HREADYMUXTARGROM  (HREADYMUXTARGROM),
    .HAUSERTARGROM     (HAUSERTARGROM),
    .HWUSERTARGROM     (HWUSERTARGROM),
    .HRDATATARGROM     (HRDATATARGROM),
    .HREADYOUTTARGROM  (HREADYOUTTARGROM),
    .HRESPTARGROM      (i_hrespTARGROM),
    .HRUSERTARGROM     (HRUSERTARGROM),

    // Output port MI1 signals
    .HSELTARGRAM       (HSELTARGRAM),
    .HADDRTARGRAM      (HADDRTARGRAM),
    .HTRANSTARGRAM     (HTRANSTARGRAM),
    .HWRITETARGRAM     (HWRITETARGRAM),
    .HSIZETARGRAM      (HSIZETARGRAM),
    .HBURSTTARGRAM     (HBURSTTARGRAM),
    .HPROTTARGRAM      (HPROTTARGRAM),
    .HWDATATARGRAM     (HWDATATARGRAM),
    .HMASTERTARGRAM    (i_hmasterTARGRAM),
    .HMASTLOCKTARGRAM  (HMASTLOCKTARGRAM),
    .HREADYMUXTARGRAM  (HREADYMUXTARGRAM),
    .HAUSERTARGRAM     (HAUSERTARGRAM),
    .HWUSERTARGRAM     (HWUSERTARGRAM),
    .HRDATATARGRAM     (HRDATATARGRAM),
    .HREADYOUTTARGRAM  (HREADYOUTTARGRAM),
    .HRESPTARGRAM      (i_hrespTARGRAM),
    .HRUSERTARGRAM     (HRUSERTARGRAM),

    // Output port MI2 signals
    .HSELTARGCRYPTO       (HSELTARGCRYPTO),
    .HADDRTARGCRYPTO      (HADDRTARGCRYPTO),
    .HTRANSTARGCRYPTO     (HTRANSTARGCRYPTO),
    .HWRITETARGCRYPTO     (HWRITETARGCRYPTO),
    .HSIZETARGCRYPTO      (HSIZETARGCRYPTO),
    .HBURSTTARGCRYPTO     (HBURSTTARGCRYPTO),
    .HPROTTARGCRYPTO      (HPROTTARGCRYPTO),
    .HWDATATARGCRYPTO     (HWDATATARGCRYPTO),
    .HMASTERTARGCRYPTO    (i_hmasterTARGCRYPTO),
    .HMASTLOCKTARGCRYPTO  (HMASTLOCKTARGCRYPTO),
    .HREADYMUXTARGCRYPTO  (HREADYMUXTARGCRYPTO),
    .HAUSERTARGCRYPTO     (HAUSERTARGCRYPTO),
    .HWUSERTARGCRYPTO     (HWUSERTARGCRYPTO),
    .HRDATATARGCRYPTO     (HRDATATARGCRYPTO),
    .HREADYOUTTARGCRYPTO  (HREADYOUTTARGCRYPTO),
    .HRESPTARGCRYPTO      (i_hrespTARGCRYPTO),
    .HRUSERTARGCRYPTO     (HRUSERTARGCRYPTO),

    // Output port MI3 signals
    .HSELTARGPERIPH       (HSELTARGPERIPH),
    .HADDRTARGPERIPH      (HADDRTARGPERIPH),
    .HTRANSTARGPERIPH     (HTRANSTARGPERIPH),
    .HWRITETARGPERIPH     (HWRITETARGPERIPH),
    .HSIZETARGPERIPH      (HSIZETARGPERIPH),
    .HBURSTTARGPERIPH     (HBURSTTARGPERIPH),
    .HPROTTARGPERIPH      (HPROTTARGPERIPH),
    .HWDATATARGPERIPH     (HWDATATARGPERIPH),
    .HMASTERTARGPERIPH    (i_hmasterTARGPERIPH),
    .HMASTLOCKTARGPERIPH  (HMASTLOCKTARGPERIPH),
    .HREADYMUXTARGPERIPH  (HREADYMUXTARGPERIPH),
    .HAUSERTARGPERIPH     (HAUSERTARGPERIPH),
    .HWUSERTARGPERIPH     (HWUSERTARGPERIPH),
    .HRDATATARGPERIPH     (HRDATATARGPERIPH),
    .HREADYOUTTARGPERIPH  (HREADYOUTTARGPERIPH),
    .HRESPTARGPERIPH      (i_hrespTARGPERIPH),
    .HRUSERTARGPERIPH     (HRUSERTARGPERIPH),

    // Output port MI4 signals
    .HSELTARGDEBUG       (HSELTARGDEBUG),
    .HADDRTARGDEBUG      (HADDRTARGDEBUG),
    .HTRANSTARGDEBUG     (HTRANSTARGDEBUG),
    .HWRITETARGDEBUG     (HWRITETARGDEBUG),
    .HSIZETARGDEBUG      (HSIZETARGDEBUG),
    .HBURSTTARGDEBUG     (HBURSTTARGDEBUG),
    .HPROTTARGDEBUG      (HPROTTARGDEBUG),
    .HWDATATARGDEBUG     (HWDATATARGDEBUG),
    .HMASTERTARGDEBUG    (i_hmasterTARGDEBUG),
    .HMASTLOCKTARGDEBUG  (HMASTLOCKTARGDEBUG),
    .HREADYMUXTARGDEBUG  (HREADYMUXTARGDEBUG),
    .HAUSERTARGDEBUG     (HAUSERTARGDEBUG),
    .HWUSERTARGDEBUG     (HWUSERTARGDEBUG),
    .HRDATATARGDEBUG     (HRDATATARGDEBUG),
    .HREADYOUTTARGDEBUG  (HREADYOUTTARGDEBUG),
    .HRESPTARGDEBUG      (i_hrespTARGDEBUG),
    .HRUSERTARGDEBUG     (HRUSERTARGDEBUG),


    // Scan test dummy signals; not connected until scan insertion
    .SCANENABLE            (SCANENABLE),
    .SCANINHCLK            (SCANINHCLK),
    .SCANOUTHCLK           (SCANOUTHCLK)
  );


endmodule
