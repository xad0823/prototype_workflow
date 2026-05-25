//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------


`timescale 1ns/1ps


module sse710_integration_example_f0_ahb_mtx (

    HCLK,
    HRESETn,

    REMAP,

    HSELINITCM3DI,
    HADDRINITCM3DI,
    HTRANSINITCM3DI,
    HWRITEINITCM3DI,
    HSIZEINITCM3DI,
    HBURSTINITCM3DI,
    HPROTINITCM3DI,
    HMASTERINITCM3DI,
    HWDATAINITCM3DI,
    HMASTLOCKINITCM3DI,
    HREADYINITCM3DI,
    HAUSERINITCM3DI,
    HWUSERINITCM3DI,

    HSELINITCM3S,
    HADDRINITCM3S,
    HTRANSINITCM3S,
    HWRITEINITCM3S,
    HSIZEINITCM3S,
    HBURSTINITCM3S,
    HPROTINITCM3S,
    HMASTERINITCM3S,
    HWDATAINITCM3S,
    HMASTLOCKINITCM3S,
    HREADYINITCM3S,
    HAUSERINITCM3S,
    HWUSERINITCM3S,

    HSELINITEXP0,
    HADDRINITEXP0,
    HTRANSINITEXP0,
    HWRITEINITEXP0,
    HSIZEINITEXP0,
    HBURSTINITEXP0,
    HPROTINITEXP0,
    HMASTERINITEXP0,
    HWDATAINITEXP0,
    HMASTLOCKINITEXP0,
    HREADYINITEXP0,
    HAUSERINITEXP0,
    HWUSERINITEXP0,

    HSELINITEXP1,
    HADDRINITEXP1,
    HTRANSINITEXP1,
    HWRITEINITEXP1,
    HSIZEINITEXP1,
    HBURSTINITEXP1,
    HPROTINITEXP1,
    HMASTERINITEXP1,
    HWDATAINITEXP1,
    HMASTLOCKINITEXP1,
    HREADYINITEXP1,
    HAUSERINITEXP1,
    HWUSERINITEXP1,

    HRDATATARGFLASH0,
    HREADYOUTTARGFLASH0,
    HRESPTARGFLASH0,
    HRUSERTARGFLASH0,

    HRDATATARGSRAM0,
    HREADYOUTTARGSRAM0,
    HRESPTARGSRAM0,
    HRUSERTARGSRAM0,

    HRDATATARGSRAM1,
    HREADYOUTTARGSRAM1,
    HRESPTARGSRAM1,
    HRUSERTARGSRAM1,

    HRDATATARGSRAM2,
    HREADYOUTTARGSRAM2,
    HRESPTARGSRAM2,
    HRUSERTARGSRAM2,

    HRDATATARGSRAM3,
    HREADYOUTTARGSRAM3,
    HRESPTARGSRAM3,
    HRUSERTARGSRAM3,

    HRDATATARGAPB0,
    HREADYOUTTARGAPB0,
    HRESPTARGAPB0,
    HRUSERTARGAPB0,

    HRDATATARGEXP0,
    HREADYOUTTARGEXP0,
    HRESPTARGEXP0,
    HRUSERTARGEXP0,

    HRDATATARGEXP1,
    HREADYOUTTARGEXP1,
    HRESPTARGEXP1,
    HRUSERTARGEXP1,

    SCANENABLE,   
    SCANINHCLK,   


    HSELTARGFLASH0,
    HADDRTARGFLASH0,
    HTRANSTARGFLASH0,
    HWRITETARGFLASH0,
    HSIZETARGFLASH0,
    HBURSTTARGFLASH0,
    HPROTTARGFLASH0,
    HMASTERTARGFLASH0,
    HWDATATARGFLASH0,
    HMASTLOCKTARGFLASH0,
    HREADYMUXTARGFLASH0,
    HAUSERTARGFLASH0,
    HWUSERTARGFLASH0,

    HSELTARGSRAM0,
    HADDRTARGSRAM0,
    HTRANSTARGSRAM0,
    HWRITETARGSRAM0,
    HSIZETARGSRAM0,
    HBURSTTARGSRAM0,
    HPROTTARGSRAM0,
    HMASTERTARGSRAM0,
    HWDATATARGSRAM0,
    HMASTLOCKTARGSRAM0,
    HREADYMUXTARGSRAM0,
    HAUSERTARGSRAM0,
    HWUSERTARGSRAM0,

    HSELTARGSRAM1,
    HADDRTARGSRAM1,
    HTRANSTARGSRAM1,
    HWRITETARGSRAM1,
    HSIZETARGSRAM1,
    HBURSTTARGSRAM1,
    HPROTTARGSRAM1,
    HMASTERTARGSRAM1,
    HWDATATARGSRAM1,
    HMASTLOCKTARGSRAM1,
    HREADYMUXTARGSRAM1,
    HAUSERTARGSRAM1,
    HWUSERTARGSRAM1,

    HSELTARGSRAM2,
    HADDRTARGSRAM2,
    HTRANSTARGSRAM2,
    HWRITETARGSRAM2,
    HSIZETARGSRAM2,
    HBURSTTARGSRAM2,
    HPROTTARGSRAM2,
    HMASTERTARGSRAM2,
    HWDATATARGSRAM2,
    HMASTLOCKTARGSRAM2,
    HREADYMUXTARGSRAM2,
    HAUSERTARGSRAM2,
    HWUSERTARGSRAM2,

    HSELTARGSRAM3,
    HADDRTARGSRAM3,
    HTRANSTARGSRAM3,
    HWRITETARGSRAM3,
    HSIZETARGSRAM3,
    HBURSTTARGSRAM3,
    HPROTTARGSRAM3,
    HMASTERTARGSRAM3,
    HWDATATARGSRAM3,
    HMASTLOCKTARGSRAM3,
    HREADYMUXTARGSRAM3,
    HAUSERTARGSRAM3,
    HWUSERTARGSRAM3,

    HSELTARGAPB0,
    HADDRTARGAPB0,
    HTRANSTARGAPB0,
    HWRITETARGAPB0,
    HSIZETARGAPB0,
    HBURSTTARGAPB0,
    HPROTTARGAPB0,
    HMASTERTARGAPB0,
    HWDATATARGAPB0,
    HMASTLOCKTARGAPB0,
    HREADYMUXTARGAPB0,
    HAUSERTARGAPB0,
    HWUSERTARGAPB0,

    HSELTARGEXP0,
    HADDRTARGEXP0,
    HTRANSTARGEXP0,
    HWRITETARGEXP0,
    HSIZETARGEXP0,
    HBURSTTARGEXP0,
    HPROTTARGEXP0,
    HMASTERTARGEXP0,
    HWDATATARGEXP0,
    HMASTLOCKTARGEXP0,
    HREADYMUXTARGEXP0,
    HAUSERTARGEXP0,
    HWUSERTARGEXP0,

    HSELTARGEXP1,
    HADDRTARGEXP1,
    HTRANSTARGEXP1,
    HWRITETARGEXP1,
    HSIZETARGEXP1,
    HBURSTTARGEXP1,
    HPROTTARGEXP1,
    HMASTERTARGEXP1,
    HWDATATARGEXP1,
    HMASTLOCKTARGEXP1,
    HREADYMUXTARGEXP1,
    HAUSERTARGEXP1,
    HWUSERTARGEXP1,

    HRDATAINITCM3DI,
    HREADYOUTINITCM3DI,
    HRESPINITCM3DI,
    HRUSERINITCM3DI,

    HRDATAINITCM3S,
    HREADYOUTINITCM3S,
    HRESPINITCM3S,
    HRUSERINITCM3S,

    HRDATAINITEXP0,
    HREADYOUTINITEXP0,
    HRESPINITEXP0,
    HRUSERINITEXP0,

    HRDATAINITEXP1,
    HREADYOUTINITEXP1,
    HRESPINITEXP1,
    HRUSERINITEXP1,

    SCANOUTHCLK   

    );



    input         HCLK;            
    input         HRESETn;         

    input   [3:0] REMAP;           

    input         HSELINITCM3DI;          
    input  [31:0] HADDRINITCM3DI;         
    input   [1:0] HTRANSINITCM3DI;        
    input         HWRITEINITCM3DI;        
    input   [2:0] HSIZEINITCM3DI;         
    input   [2:0] HBURSTINITCM3DI;        
    input   [3:0] HPROTINITCM3DI;         
    input   [3:0] HMASTERINITCM3DI;       
    input  [31:0] HWDATAINITCM3DI;        
    input         HMASTLOCKINITCM3DI;     
    input         HREADYINITCM3DI;        
    input  [3:0] HAUSERINITCM3DI;        
    input  [3:0] HWUSERINITCM3DI;        

    input         HSELINITCM3S;          
    input  [31:0] HADDRINITCM3S;         
    input   [1:0] HTRANSINITCM3S;        
    input         HWRITEINITCM3S;        
    input   [2:0] HSIZEINITCM3S;         
    input   [2:0] HBURSTINITCM3S;        
    input   [3:0] HPROTINITCM3S;         
    input   [3:0] HMASTERINITCM3S;       
    input  [31:0] HWDATAINITCM3S;        
    input         HMASTLOCKINITCM3S;     
    input         HREADYINITCM3S;        
    input  [3:0] HAUSERINITCM3S;        
    input  [3:0] HWUSERINITCM3S;        

    input         HSELINITEXP0;          
    input  [31:0] HADDRINITEXP0;         
    input   [1:0] HTRANSINITEXP0;        
    input         HWRITEINITEXP0;        
    input   [2:0] HSIZEINITEXP0;         
    input   [2:0] HBURSTINITEXP0;        
    input   [3:0] HPROTINITEXP0;         
    input   [3:0] HMASTERINITEXP0;       
    input  [31:0] HWDATAINITEXP0;        
    input         HMASTLOCKINITEXP0;     
    input         HREADYINITEXP0;        
    input  [3:0] HAUSERINITEXP0;        
    input  [3:0] HWUSERINITEXP0;        

    input         HSELINITEXP1;          
    input  [31:0] HADDRINITEXP1;         
    input   [1:0] HTRANSINITEXP1;        
    input         HWRITEINITEXP1;        
    input   [2:0] HSIZEINITEXP1;         
    input   [2:0] HBURSTINITEXP1;        
    input   [3:0] HPROTINITEXP1;         
    input   [3:0] HMASTERINITEXP1;       
    input  [31:0] HWDATAINITEXP1;        
    input         HMASTLOCKINITEXP1;     
    input         HREADYINITEXP1;        
    input  [3:0] HAUSERINITEXP1;        
    input  [3:0] HWUSERINITEXP1;        

    input  [31:0] HRDATATARGFLASH0;        
    input         HREADYOUTTARGFLASH0;     
    input   [1:0] HRESPTARGFLASH0;         
    input  [3:0] HRUSERTARGFLASH0;        

    input  [31:0] HRDATATARGSRAM0;        
    input         HREADYOUTTARGSRAM0;     
    input   [1:0] HRESPTARGSRAM0;         
    input  [3:0] HRUSERTARGSRAM0;        

    input  [31:0] HRDATATARGSRAM1;        
    input         HREADYOUTTARGSRAM1;     
    input   [1:0] HRESPTARGSRAM1;         
    input  [3:0] HRUSERTARGSRAM1;        

    input  [31:0] HRDATATARGSRAM2;        
    input         HREADYOUTTARGSRAM2;     
    input   [1:0] HRESPTARGSRAM2;         
    input  [3:0] HRUSERTARGSRAM2;        

    input  [31:0] HRDATATARGSRAM3;        
    input         HREADYOUTTARGSRAM3;     
    input   [1:0] HRESPTARGSRAM3;         
    input  [3:0] HRUSERTARGSRAM3;        

    input  [31:0] HRDATATARGAPB0;        
    input         HREADYOUTTARGAPB0;     
    input   [1:0] HRESPTARGAPB0;         
    input  [3:0] HRUSERTARGAPB0;        

    input  [31:0] HRDATATARGEXP0;        
    input         HREADYOUTTARGEXP0;     
    input   [1:0] HRESPTARGEXP0;         
    input  [3:0] HRUSERTARGEXP0;        

    input  [31:0] HRDATATARGEXP1;        
    input         HREADYOUTTARGEXP1;     
    input   [1:0] HRESPTARGEXP1;         
    input  [3:0] HRUSERTARGEXP1;        

    input         SCANENABLE;      
    input         SCANINHCLK;      


    output        HSELTARGFLASH0;          
    output [31:0] HADDRTARGFLASH0;         
    output  [1:0] HTRANSTARGFLASH0;        
    output        HWRITETARGFLASH0;        
    output  [2:0] HSIZETARGFLASH0;         
    output  [2:0] HBURSTTARGFLASH0;        
    output  [3:0] HPROTTARGFLASH0;         
    output  [3:0] HMASTERTARGFLASH0;       
    output [31:0] HWDATATARGFLASH0;        
    output        HMASTLOCKTARGFLASH0;     
    output        HREADYMUXTARGFLASH0;     
    output [3:0] HAUSERTARGFLASH0;        
    output [3:0] HWUSERTARGFLASH0;        

    output        HSELTARGSRAM0;          
    output [31:0] HADDRTARGSRAM0;         
    output  [1:0] HTRANSTARGSRAM0;        
    output        HWRITETARGSRAM0;        
    output  [2:0] HSIZETARGSRAM0;         
    output  [2:0] HBURSTTARGSRAM0;        
    output  [3:0] HPROTTARGSRAM0;         
    output  [3:0] HMASTERTARGSRAM0;       
    output [31:0] HWDATATARGSRAM0;        
    output        HMASTLOCKTARGSRAM0;     
    output        HREADYMUXTARGSRAM0;     
    output [3:0] HAUSERTARGSRAM0;        
    output [3:0] HWUSERTARGSRAM0;        

    output        HSELTARGSRAM1;          
    output [31:0] HADDRTARGSRAM1;         
    output  [1:0] HTRANSTARGSRAM1;        
    output        HWRITETARGSRAM1;        
    output  [2:0] HSIZETARGSRAM1;         
    output  [2:0] HBURSTTARGSRAM1;        
    output  [3:0] HPROTTARGSRAM1;         
    output  [3:0] HMASTERTARGSRAM1;       
    output [31:0] HWDATATARGSRAM1;        
    output        HMASTLOCKTARGSRAM1;     
    output        HREADYMUXTARGSRAM1;     
    output [3:0] HAUSERTARGSRAM1;        
    output [3:0] HWUSERTARGSRAM1;        

    output        HSELTARGSRAM2;          
    output [31:0] HADDRTARGSRAM2;         
    output  [1:0] HTRANSTARGSRAM2;        
    output        HWRITETARGSRAM2;        
    output  [2:0] HSIZETARGSRAM2;         
    output  [2:0] HBURSTTARGSRAM2;        
    output  [3:0] HPROTTARGSRAM2;         
    output  [3:0] HMASTERTARGSRAM2;       
    output [31:0] HWDATATARGSRAM2;        
    output        HMASTLOCKTARGSRAM2;     
    output        HREADYMUXTARGSRAM2;     
    output [3:0] HAUSERTARGSRAM2;        
    output [3:0] HWUSERTARGSRAM2;        

    output        HSELTARGSRAM3;          
    output [31:0] HADDRTARGSRAM3;         
    output  [1:0] HTRANSTARGSRAM3;        
    output        HWRITETARGSRAM3;        
    output  [2:0] HSIZETARGSRAM3;         
    output  [2:0] HBURSTTARGSRAM3;        
    output  [3:0] HPROTTARGSRAM3;         
    output  [3:0] HMASTERTARGSRAM3;       
    output [31:0] HWDATATARGSRAM3;        
    output        HMASTLOCKTARGSRAM3;     
    output        HREADYMUXTARGSRAM3;     
    output [3:0] HAUSERTARGSRAM3;        
    output [3:0] HWUSERTARGSRAM3;        

    output        HSELTARGAPB0;          
    output [31:0] HADDRTARGAPB0;         
    output  [1:0] HTRANSTARGAPB0;        
    output        HWRITETARGAPB0;        
    output  [2:0] HSIZETARGAPB0;         
    output  [2:0] HBURSTTARGAPB0;        
    output  [3:0] HPROTTARGAPB0;         
    output  [3:0] HMASTERTARGAPB0;       
    output [31:0] HWDATATARGAPB0;        
    output        HMASTLOCKTARGAPB0;     
    output        HREADYMUXTARGAPB0;     
    output [3:0] HAUSERTARGAPB0;        
    output [3:0] HWUSERTARGAPB0;        

    output        HSELTARGEXP0;          
    output [31:0] HADDRTARGEXP0;         
    output  [1:0] HTRANSTARGEXP0;        
    output        HWRITETARGEXP0;        
    output  [2:0] HSIZETARGEXP0;         
    output  [2:0] HBURSTTARGEXP0;        
    output  [3:0] HPROTTARGEXP0;         
    output  [3:0] HMASTERTARGEXP0;       
    output [31:0] HWDATATARGEXP0;        
    output        HMASTLOCKTARGEXP0;     
    output        HREADYMUXTARGEXP0;     
    output [3:0] HAUSERTARGEXP0;        
    output [3:0] HWUSERTARGEXP0;        

    output        HSELTARGEXP1;          
    output [31:0] HADDRTARGEXP1;         
    output  [1:0] HTRANSTARGEXP1;        
    output        HWRITETARGEXP1;        
    output  [2:0] HSIZETARGEXP1;         
    output  [2:0] HBURSTTARGEXP1;        
    output  [3:0] HPROTTARGEXP1;         
    output  [3:0] HMASTERTARGEXP1;       
    output [31:0] HWDATATARGEXP1;        
    output        HMASTLOCKTARGEXP1;     
    output        HREADYMUXTARGEXP1;     
    output [3:0] HAUSERTARGEXP1;        
    output [3:0] HWUSERTARGEXP1;        

    output [31:0] HRDATAINITCM3DI;        
    output        HREADYOUTINITCM3DI;     
    output  [1:0] HRESPINITCM3DI;         
    output [3:0] HRUSERINITCM3DI;        

    output [31:0] HRDATAINITCM3S;        
    output        HREADYOUTINITCM3S;     
    output  [1:0] HRESPINITCM3S;         
    output [3:0] HRUSERINITCM3S;        

    output [31:0] HRDATAINITEXP0;        
    output        HREADYOUTINITEXP0;     
    output  [1:0] HRESPINITEXP0;         
    output [3:0] HRUSERINITEXP0;        

    output [31:0] HRDATAINITEXP1;        
    output        HREADYOUTINITEXP1;     
    output  [1:0] HRESPINITEXP1;         
    output [3:0] HRUSERINITEXP1;        

    output        SCANOUTHCLK;     



    wire         HCLK;            
    wire         HRESETn;         

    wire   [3:0] REMAP;           

    wire         HSELINITCM3DI;          
    wire  [31:0] HADDRINITCM3DI;         
    wire   [1:0] HTRANSINITCM3DI;        
    wire         HWRITEINITCM3DI;        
    wire   [2:0] HSIZEINITCM3DI;         
    wire   [2:0] HBURSTINITCM3DI;        
    wire   [3:0] HPROTINITCM3DI;         
    wire   [3:0] HMASTERINITCM3DI;       
    wire  [31:0] HWDATAINITCM3DI;        
    wire         HMASTLOCKINITCM3DI;     
    wire         HREADYINITCM3DI;        

    wire  [31:0] HRDATAINITCM3DI;        
    wire         HREADYOUTINITCM3DI;     
    wire   [1:0] HRESPINITCM3DI;         
    wire  [3:0] HAUSERINITCM3DI;        
    wire  [3:0] HWUSERINITCM3DI;        
    wire  [3:0] HRUSERINITCM3DI;        

    wire         HSELINITCM3S;          
    wire  [31:0] HADDRINITCM3S;         
    wire   [1:0] HTRANSINITCM3S;        
    wire         HWRITEINITCM3S;        
    wire   [2:0] HSIZEINITCM3S;         
    wire   [2:0] HBURSTINITCM3S;        
    wire   [3:0] HPROTINITCM3S;         
    wire   [3:0] HMASTERINITCM3S;       
    wire  [31:0] HWDATAINITCM3S;        
    wire         HMASTLOCKINITCM3S;     
    wire         HREADYINITCM3S;        

    wire  [31:0] HRDATAINITCM3S;        
    wire         HREADYOUTINITCM3S;     
    wire   [1:0] HRESPINITCM3S;         
    wire  [3:0] HAUSERINITCM3S;        
    wire  [3:0] HWUSERINITCM3S;        
    wire  [3:0] HRUSERINITCM3S;        

    wire         HSELINITEXP0;          
    wire  [31:0] HADDRINITEXP0;         
    wire   [1:0] HTRANSINITEXP0;        
    wire         HWRITEINITEXP0;        
    wire   [2:0] HSIZEINITEXP0;         
    wire   [2:0] HBURSTINITEXP0;        
    wire   [3:0] HPROTINITEXP0;         
    wire   [3:0] HMASTERINITEXP0;       
    wire  [31:0] HWDATAINITEXP0;        
    wire         HMASTLOCKINITEXP0;     
    wire         HREADYINITEXP0;        

    wire  [31:0] HRDATAINITEXP0;        
    wire         HREADYOUTINITEXP0;     
    wire   [1:0] HRESPINITEXP0;         
    wire  [3:0] HAUSERINITEXP0;        
    wire  [3:0] HWUSERINITEXP0;        
    wire  [3:0] HRUSERINITEXP0;        

    wire         HSELINITEXP1;          
    wire  [31:0] HADDRINITEXP1;         
    wire   [1:0] HTRANSINITEXP1;        
    wire         HWRITEINITEXP1;        
    wire   [2:0] HSIZEINITEXP1;         
    wire   [2:0] HBURSTINITEXP1;        
    wire   [3:0] HPROTINITEXP1;         
    wire   [3:0] HMASTERINITEXP1;       
    wire  [31:0] HWDATAINITEXP1;        
    wire         HMASTLOCKINITEXP1;     
    wire         HREADYINITEXP1;        

    wire  [31:0] HRDATAINITEXP1;        
    wire         HREADYOUTINITEXP1;     
    wire   [1:0] HRESPINITEXP1;         
    wire  [3:0] HAUSERINITEXP1;        
    wire  [3:0] HWUSERINITEXP1;        
    wire  [3:0] HRUSERINITEXP1;        

    wire         HSELTARGFLASH0;          
    wire  [31:0] HADDRTARGFLASH0;         
    wire   [1:0] HTRANSTARGFLASH0;        
    wire         HWRITETARGFLASH0;        
    wire   [2:0] HSIZETARGFLASH0;         
    wire   [2:0] HBURSTTARGFLASH0;        
    wire   [3:0] HPROTTARGFLASH0;         
    wire   [3:0] HMASTERTARGFLASH0;       
    wire  [31:0] HWDATATARGFLASH0;        
    wire         HMASTLOCKTARGFLASH0;     
    wire         HREADYMUXTARGFLASH0;     

    wire  [31:0] HRDATATARGFLASH0;        
    wire         HREADYOUTTARGFLASH0;     
    wire   [1:0] HRESPTARGFLASH0;         
    wire  [3:0] HAUSERTARGFLASH0;        
    wire  [3:0] HWUSERTARGFLASH0;        
    wire  [3:0] HRUSERTARGFLASH0;        

    wire         HSELTARGSRAM0;          
    wire  [31:0] HADDRTARGSRAM0;         
    wire   [1:0] HTRANSTARGSRAM0;        
    wire         HWRITETARGSRAM0;        
    wire   [2:0] HSIZETARGSRAM0;         
    wire   [2:0] HBURSTTARGSRAM0;        
    wire   [3:0] HPROTTARGSRAM0;         
    wire   [3:0] HMASTERTARGSRAM0;       
    wire  [31:0] HWDATATARGSRAM0;        
    wire         HMASTLOCKTARGSRAM0;     
    wire         HREADYMUXTARGSRAM0;     

    wire  [31:0] HRDATATARGSRAM0;        
    wire         HREADYOUTTARGSRAM0;     
    wire   [1:0] HRESPTARGSRAM0;         
    wire  [3:0] HAUSERTARGSRAM0;        
    wire  [3:0] HWUSERTARGSRAM0;        
    wire  [3:0] HRUSERTARGSRAM0;        

    wire         HSELTARGSRAM1;          
    wire  [31:0] HADDRTARGSRAM1;         
    wire   [1:0] HTRANSTARGSRAM1;        
    wire         HWRITETARGSRAM1;        
    wire   [2:0] HSIZETARGSRAM1;         
    wire   [2:0] HBURSTTARGSRAM1;        
    wire   [3:0] HPROTTARGSRAM1;         
    wire   [3:0] HMASTERTARGSRAM1;       
    wire  [31:0] HWDATATARGSRAM1;        
    wire         HMASTLOCKTARGSRAM1;     
    wire         HREADYMUXTARGSRAM1;     

    wire  [31:0] HRDATATARGSRAM1;        
    wire         HREADYOUTTARGSRAM1;     
    wire   [1:0] HRESPTARGSRAM1;         
    wire  [3:0] HAUSERTARGSRAM1;        
    wire  [3:0] HWUSERTARGSRAM1;        
    wire  [3:0] HRUSERTARGSRAM1;        

    wire         HSELTARGSRAM2;          
    wire  [31:0] HADDRTARGSRAM2;         
    wire   [1:0] HTRANSTARGSRAM2;        
    wire         HWRITETARGSRAM2;        
    wire   [2:0] HSIZETARGSRAM2;         
    wire   [2:0] HBURSTTARGSRAM2;        
    wire   [3:0] HPROTTARGSRAM2;         
    wire   [3:0] HMASTERTARGSRAM2;       
    wire  [31:0] HWDATATARGSRAM2;        
    wire         HMASTLOCKTARGSRAM2;     
    wire         HREADYMUXTARGSRAM2;     

    wire  [31:0] HRDATATARGSRAM2;        
    wire         HREADYOUTTARGSRAM2;     
    wire   [1:0] HRESPTARGSRAM2;         
    wire  [3:0] HAUSERTARGSRAM2;        
    wire  [3:0] HWUSERTARGSRAM2;        
    wire  [3:0] HRUSERTARGSRAM2;        

    wire         HSELTARGSRAM3;          
    wire  [31:0] HADDRTARGSRAM3;         
    wire   [1:0] HTRANSTARGSRAM3;        
    wire         HWRITETARGSRAM3;        
    wire   [2:0] HSIZETARGSRAM3;         
    wire   [2:0] HBURSTTARGSRAM3;        
    wire   [3:0] HPROTTARGSRAM3;         
    wire   [3:0] HMASTERTARGSRAM3;       
    wire  [31:0] HWDATATARGSRAM3;        
    wire         HMASTLOCKTARGSRAM3;     
    wire         HREADYMUXTARGSRAM3;     

    wire  [31:0] HRDATATARGSRAM3;        
    wire         HREADYOUTTARGSRAM3;     
    wire   [1:0] HRESPTARGSRAM3;         
    wire  [3:0] HAUSERTARGSRAM3;        
    wire  [3:0] HWUSERTARGSRAM3;        
    wire  [3:0] HRUSERTARGSRAM3;        

    wire         HSELTARGAPB0;          
    wire  [31:0] HADDRTARGAPB0;         
    wire   [1:0] HTRANSTARGAPB0;        
    wire         HWRITETARGAPB0;        
    wire   [2:0] HSIZETARGAPB0;         
    wire   [2:0] HBURSTTARGAPB0;        
    wire   [3:0] HPROTTARGAPB0;         
    wire   [3:0] HMASTERTARGAPB0;       
    wire  [31:0] HWDATATARGAPB0;        
    wire         HMASTLOCKTARGAPB0;     
    wire         HREADYMUXTARGAPB0;     

    wire  [31:0] HRDATATARGAPB0;        
    wire         HREADYOUTTARGAPB0;     
    wire   [1:0] HRESPTARGAPB0;         
    wire  [3:0] HAUSERTARGAPB0;        
    wire  [3:0] HWUSERTARGAPB0;        
    wire  [3:0] HRUSERTARGAPB0;        

    wire         HSELTARGEXP0;          
    wire  [31:0] HADDRTARGEXP0;         
    wire   [1:0] HTRANSTARGEXP0;        
    wire         HWRITETARGEXP0;        
    wire   [2:0] HSIZETARGEXP0;         
    wire   [2:0] HBURSTTARGEXP0;        
    wire   [3:0] HPROTTARGEXP0;         
    wire   [3:0] HMASTERTARGEXP0;       
    wire  [31:0] HWDATATARGEXP0;        
    wire         HMASTLOCKTARGEXP0;     
    wire         HREADYMUXTARGEXP0;     

    wire  [31:0] HRDATATARGEXP0;        
    wire         HREADYOUTTARGEXP0;     
    wire   [1:0] HRESPTARGEXP0;         
    wire  [3:0] HAUSERTARGEXP0;        
    wire  [3:0] HWUSERTARGEXP0;        
    wire  [3:0] HRUSERTARGEXP0;        

    wire         HSELTARGEXP1;          
    wire  [31:0] HADDRTARGEXP1;         
    wire   [1:0] HTRANSTARGEXP1;        
    wire         HWRITETARGEXP1;        
    wire   [2:0] HSIZETARGEXP1;         
    wire   [2:0] HBURSTTARGEXP1;        
    wire   [3:0] HPROTTARGEXP1;         
    wire   [3:0] HMASTERTARGEXP1;       
    wire  [31:0] HWDATATARGEXP1;        
    wire         HMASTLOCKTARGEXP1;     
    wire         HREADYMUXTARGEXP1;     

    wire  [31:0] HRDATATARGEXP1;        
    wire         HREADYOUTTARGEXP1;     
    wire   [1:0] HRESPTARGEXP1;         
    wire  [3:0] HAUSERTARGEXP1;        
    wire  [3:0] HWUSERTARGEXP1;        
    wire  [3:0] HRUSERTARGEXP1;        



    wire         i_sel0;            
    wire  [31:0] i_addr0;           
    wire   [1:0] i_trans0;          
    wire         i_write0;          
    wire   [2:0] i_size0;           
    wire   [2:0] i_burst0;          
    wire   [3:0] i_prot0;           
    wire   [3:0] i_master0;         
    wire         i_mastlock0;       
    wire         i_active0;         
    wire         i_held_tran0;       
    wire         i_readyout0;       
    wire   [1:0] i_resp0;           
    wire  [3:0] i_auser0;          

    wire         i_sel1;            
    wire  [31:0] i_addr1;           
    wire   [1:0] i_trans1;          
    wire         i_write1;          
    wire   [2:0] i_size1;           
    wire   [2:0] i_burst1;          
    wire   [3:0] i_prot1;           
    wire   [3:0] i_master1;         
    wire         i_mastlock1;       
    wire         i_active1;         
    wire         i_held_tran1;       
    wire         i_readyout1;       
    wire   [1:0] i_resp1;           
    wire  [3:0] i_auser1;          

    wire         i_sel2;            
    wire  [31:0] i_addr2;           
    wire   [1:0] i_trans2;          
    wire         i_write2;          
    wire   [2:0] i_size2;           
    wire   [2:0] i_burst2;          
    wire   [3:0] i_prot2;           
    wire   [3:0] i_master2;         
    wire         i_mastlock2;       
    wire         i_active2;         
    wire         i_held_tran2;       
    wire         i_readyout2;       
    wire   [1:0] i_resp2;           
    wire  [3:0] i_auser2;          

    wire         i_sel3;            
    wire  [31:0] i_addr3;           
    wire   [1:0] i_trans3;          
    wire         i_write3;          
    wire   [2:0] i_size3;           
    wire   [2:0] i_burst3;          
    wire   [3:0] i_prot3;           
    wire   [3:0] i_master3;         
    wire         i_mastlock3;       
    wire         i_active3;         
    wire         i_held_tran3;       
    wire         i_readyout3;       
    wire   [1:0] i_resp3;           
    wire  [3:0] i_auser3;          

    wire         i_sel0to0;         
    wire         i_active0to0;      

    wire         i_sel0to7;         
    wire         i_active0to7;      

    wire         i_sel1to1;         
    wire         i_active1to1;      

    wire         i_sel1to2;         
    wire         i_active1to2;      

    wire         i_sel1to3;         
    wire         i_active1to3;      

    wire         i_sel1to4;         
    wire         i_active1to4;      

    wire         i_sel1to5;         
    wire         i_active1to5;      

    wire         i_sel1to6;         
    wire         i_active1to6;      

    wire         i_sel1to7;         
    wire         i_active1to7;      

    wire         i_sel2to0;         
    wire         i_active2to0;      

    wire         i_sel2to1;         
    wire         i_active2to1;      

    wire         i_sel2to2;         
    wire         i_active2to2;      

    wire         i_sel2to3;         
    wire         i_active2to3;      

    wire         i_sel2to4;         
    wire         i_active2to4;      

    wire         i_sel2to5;         
    wire         i_active2to5;      

    wire         i_sel2to6;         
    wire         i_active2to6;      

    wire         i_sel2to7;         
    wire         i_active2to7;      

    wire         i_sel3to0;         
    wire         i_active3to0;      

    wire         i_sel3to1;         
    wire         i_active3to1;      

    wire         i_sel3to2;         
    wire         i_active3to2;      

    wire         i_sel3to3;         
    wire         i_active3to3;      

    wire         i_sel3to4;         
    wire         i_active3to4;      

    wire         i_sel3to5;         
    wire         i_active3to5;      

    wire         i_sel3to6;         
    wire         i_active3to6;      

    wire         i_sel3to7;         
    wire         i_active3to7;      

    wire         i_hready_mux_targflash0;    
    wire         i_hready_mux_targsram0;    
    wire         i_hready_mux_targsram1;    
    wire         i_hready_mux_targsram2;    
    wire         i_hready_mux_targsram3;    
    wire         i_hready_mux_targapb0;    
    wire         i_hready_mux_targexp0;    
    wire         i_hready_mux_targexp1;    



  sse710_integration_example_f0_ahb_mtx_input_stage u_sse710_integration_example_f0_ahb_mtx_input_stage_0 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .HSELS      (HSELINITCM3DI),
    .HADDRS     (HADDRINITCM3DI),
    .HTRANSS    (HTRANSINITCM3DI),
    .HWRITES    (HWRITEINITCM3DI),
    .HSIZES     (HSIZEINITCM3DI),
    .HBURSTS    (HBURSTINITCM3DI),
    .HPROTS     (HPROTINITCM3DI),
    .HMASTERS   (HMASTERINITCM3DI),
    .HMASTLOCKS (HMASTLOCKINITCM3DI),
    .HREADYS    (HREADYINITCM3DI),
    .HAUSERS    (HAUSERINITCM3DI),

    .active_ip     (i_active0),
    .readyout_ip   (i_readyout0),
    .resp_ip       (i_resp0),

    .HREADYOUTS (HREADYOUTINITCM3DI),
    .HRESPS     (HRESPINITCM3DI),

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


  sse710_integration_example_f0_ahb_mtx_input_stage u_sse710_integration_example_f0_ahb_mtx_input_stage_1 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .HSELS      (HSELINITCM3S),
    .HADDRS     (HADDRINITCM3S),
    .HTRANSS    (HTRANSINITCM3S),
    .HWRITES    (HWRITEINITCM3S),
    .HSIZES     (HSIZEINITCM3S),
    .HBURSTS    (HBURSTINITCM3S),
    .HPROTS     (HPROTINITCM3S),
    .HMASTERS   (HMASTERINITCM3S),
    .HMASTLOCKS (HMASTLOCKINITCM3S),
    .HREADYS    (HREADYINITCM3S),
    .HAUSERS    (HAUSERINITCM3S),

    .active_ip     (i_active1),
    .readyout_ip   (i_readyout1),
    .resp_ip       (i_resp1),

    .HREADYOUTS (HREADYOUTINITCM3S),
    .HRESPS     (HRESPINITCM3S),

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


  sse710_integration_example_f0_ahb_mtx_input_stage u_sse710_integration_example_f0_ahb_mtx_input_stage_2 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .HSELS      (HSELINITEXP0),
    .HADDRS     (HADDRINITEXP0),
    .HTRANSS    (HTRANSINITEXP0),
    .HWRITES    (HWRITEINITEXP0),
    .HSIZES     (HSIZEINITEXP0),
    .HBURSTS    (HBURSTINITEXP0),
    .HPROTS     (HPROTINITEXP0),
    .HMASTERS   (HMASTERINITEXP0),
    .HMASTLOCKS (HMASTLOCKINITEXP0),
    .HREADYS    (HREADYINITEXP0),
    .HAUSERS    (HAUSERINITEXP0),

    .active_ip     (i_active2),
    .readyout_ip   (i_readyout2),
    .resp_ip       (i_resp2),

    .HREADYOUTS (HREADYOUTINITEXP0),
    .HRESPS     (HRESPINITEXP0),

    .sel_ip        (i_sel2),
    .addr_ip       (i_addr2),
    .auser_ip      (i_auser2),
    .trans_ip      (i_trans2),
    .write_ip      (i_write2),
    .size_ip       (i_size2),
    .burst_ip      (i_burst2),
    .prot_ip       (i_prot2),
    .master_ip     (i_master2),
    .mastlock_ip   (i_mastlock2),
    .held_tran_ip   (i_held_tran2)

    );


  sse710_integration_example_f0_ahb_mtx_input_stage u_sse710_integration_example_f0_ahb_mtx_input_stage_3 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .HSELS      (HSELINITEXP1),
    .HADDRS     (HADDRINITEXP1),
    .HTRANSS    (HTRANSINITEXP1),
    .HWRITES    (HWRITEINITEXP1),
    .HSIZES     (HSIZEINITEXP1),
    .HBURSTS    (HBURSTINITEXP1),
    .HPROTS     (HPROTINITEXP1),
    .HMASTERS   (HMASTERINITEXP1),
    .HMASTLOCKS (HMASTLOCKINITEXP1),
    .HREADYS    (HREADYINITEXP1),
    .HAUSERS    (HAUSERINITEXP1),

    .active_ip     (i_active3),
    .readyout_ip   (i_readyout3),
    .resp_ip       (i_resp3),

    .HREADYOUTS (HREADYOUTINITEXP1),
    .HRESPS     (HRESPINITEXP1),

    .sel_ip        (i_sel3),
    .addr_ip       (i_addr3),
    .auser_ip      (i_auser3),
    .trans_ip      (i_trans3),
    .write_ip      (i_write3),
    .size_ip       (i_size3),
    .burst_ip      (i_burst3),
    .prot_ip       (i_prot3),
    .master_ip     (i_master3),
    .mastlock_ip   (i_mastlock3),
    .held_tran_ip   (i_held_tran3)

    );


  sse710_integration_example_f0_ahb_mtx_decoderINITCM3DI u_sse710_integration_example_f0_ahb_mtx_decoderinitcm3di (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .remapping_dec  ( REMAP[0] ),

    .HREADYS    (HREADYINITCM3DI),
    .sel_dec        (i_sel0),
    .decode_addr_dec (i_addr0[31:10]),   
    .trans_dec      (i_trans0),

    .active_dec0    (i_active0to0),
    .readyout_dec0  (i_hready_mux_targflash0),
    .resp_dec0      (HRESPTARGFLASH0),
    .rdata_dec0     (HRDATATARGFLASH0),
    .ruser_dec0     (HRUSERTARGFLASH0),

    .active_dec7    (i_active0to7),
    .readyout_dec7  (i_hready_mux_targexp1),
    .resp_dec7      (HRESPTARGEXP1),
    .rdata_dec7     (HRDATATARGEXP1),
    .ruser_dec7     (HRUSERTARGEXP1),

    .sel_dec0       (i_sel0to0),
    .sel_dec7       (i_sel0to7),

    .active_dec     (i_active0),
    .HREADYOUTS (i_readyout0),
    .HRESPS     (i_resp0),
    .HRUSERS    (HRUSERINITCM3DI),
    .HRDATAS    (HRDATAINITCM3DI)

    );


  sse710_integration_example_f0_ahb_mtx_decoderINITCM3S u_sse710_integration_example_f0_ahb_mtx_decoderinitcm3s (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .remapping_dec  ( { REMAP[3], REMAP[2], REMAP[1] } ),

    .HREADYS    (HREADYINITCM3S),
    .sel_dec        (i_sel1),
    .decode_addr_dec (i_addr1[31:10]),   
    .trans_dec      (i_trans1),

    .active_dec1    (i_active1to1),
    .readyout_dec1  (i_hready_mux_targsram0),
    .resp_dec1      (HRESPTARGSRAM0),
    .rdata_dec1     (HRDATATARGSRAM0),
    .ruser_dec1     (HRUSERTARGSRAM0),

    .active_dec2    (i_active1to2),
    .readyout_dec2  (i_hready_mux_targsram1),
    .resp_dec2      (HRESPTARGSRAM1),
    .rdata_dec2     (HRDATATARGSRAM1),
    .ruser_dec2     (HRUSERTARGSRAM1),

    .active_dec3    (i_active1to3),
    .readyout_dec3  (i_hready_mux_targsram2),
    .resp_dec3      (HRESPTARGSRAM2),
    .rdata_dec3     (HRDATATARGSRAM2),
    .ruser_dec3     (HRUSERTARGSRAM2),

    .active_dec4    (i_active1to4),
    .readyout_dec4  (i_hready_mux_targsram3),
    .resp_dec4      (HRESPTARGSRAM3),
    .rdata_dec4     (HRDATATARGSRAM3),
    .ruser_dec4     (HRUSERTARGSRAM3),

    .active_dec5    (i_active1to5),
    .readyout_dec5  (i_hready_mux_targapb0),
    .resp_dec5      (HRESPTARGAPB0),
    .rdata_dec5     (HRDATATARGAPB0),
    .ruser_dec5     (HRUSERTARGAPB0),

    .active_dec6    (i_active1to6),
    .readyout_dec6  (i_hready_mux_targexp0),
    .resp_dec6      (HRESPTARGEXP0),
    .rdata_dec6     (HRDATATARGEXP0),
    .ruser_dec6     (HRUSERTARGEXP0),

    .active_dec7    (i_active1to7),
    .readyout_dec7  (i_hready_mux_targexp1),
    .resp_dec7      (HRESPTARGEXP1),
    .rdata_dec7     (HRDATATARGEXP1),
    .ruser_dec7     (HRUSERTARGEXP1),

    .sel_dec1       (i_sel1to1),
    .sel_dec2       (i_sel1to2),
    .sel_dec3       (i_sel1to3),
    .sel_dec4       (i_sel1to4),
    .sel_dec5       (i_sel1to5),
    .sel_dec6       (i_sel1to6),
    .sel_dec7       (i_sel1to7),

    .active_dec     (i_active1),
    .HREADYOUTS (i_readyout1),
    .HRESPS     (i_resp1),
    .HRUSERS    (HRUSERINITCM3S),
    .HRDATAS    (HRDATAINITCM3S)

    );


  sse710_integration_example_f0_ahb_mtx_decoderINITEXP0 u_sse710_integration_example_f0_ahb_mtx_decoderinitexp0 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .remapping_dec  ( { REMAP[3], REMAP[2], REMAP[1], REMAP[0] } ),

    .HREADYS    (HREADYINITEXP0),
    .sel_dec        (i_sel2),
    .decode_addr_dec (i_addr2[31:10]),   
    .trans_dec      (i_trans2),

    .active_dec0    (i_active2to0),
    .readyout_dec0  (i_hready_mux_targflash0),
    .resp_dec0      (HRESPTARGFLASH0),
    .rdata_dec0     (HRDATATARGFLASH0),
    .ruser_dec0     (HRUSERTARGFLASH0),

    .active_dec1    (i_active2to1),
    .readyout_dec1  (i_hready_mux_targsram0),
    .resp_dec1      (HRESPTARGSRAM0),
    .rdata_dec1     (HRDATATARGSRAM0),
    .ruser_dec1     (HRUSERTARGSRAM0),

    .active_dec2    (i_active2to2),
    .readyout_dec2  (i_hready_mux_targsram1),
    .resp_dec2      (HRESPTARGSRAM1),
    .rdata_dec2     (HRDATATARGSRAM1),
    .ruser_dec2     (HRUSERTARGSRAM1),

    .active_dec3    (i_active2to3),
    .readyout_dec3  (i_hready_mux_targsram2),
    .resp_dec3      (HRESPTARGSRAM2),
    .rdata_dec3     (HRDATATARGSRAM2),
    .ruser_dec3     (HRUSERTARGSRAM2),

    .active_dec4    (i_active2to4),
    .readyout_dec4  (i_hready_mux_targsram3),
    .resp_dec4      (HRESPTARGSRAM3),
    .rdata_dec4     (HRDATATARGSRAM3),
    .ruser_dec4     (HRUSERTARGSRAM3),

    .active_dec5    (i_active2to5),
    .readyout_dec5  (i_hready_mux_targapb0),
    .resp_dec5      (HRESPTARGAPB0),
    .rdata_dec5     (HRDATATARGAPB0),
    .ruser_dec5     (HRUSERTARGAPB0),

    .active_dec6    (i_active2to6),
    .readyout_dec6  (i_hready_mux_targexp0),
    .resp_dec6      (HRESPTARGEXP0),
    .rdata_dec6     (HRDATATARGEXP0),
    .ruser_dec6     (HRUSERTARGEXP0),

    .active_dec7    (i_active2to7),
    .readyout_dec7  (i_hready_mux_targexp1),
    .resp_dec7      (HRESPTARGEXP1),
    .rdata_dec7     (HRDATATARGEXP1),
    .ruser_dec7     (HRUSERTARGEXP1),

    .sel_dec0       (i_sel2to0),
    .sel_dec1       (i_sel2to1),
    .sel_dec2       (i_sel2to2),
    .sel_dec3       (i_sel2to3),
    .sel_dec4       (i_sel2to4),
    .sel_dec5       (i_sel2to5),
    .sel_dec6       (i_sel2to6),
    .sel_dec7       (i_sel2to7),

    .active_dec     (i_active2),
    .HREADYOUTS (i_readyout2),
    .HRESPS     (i_resp2),
    .HRUSERS    (HRUSERINITEXP0),
    .HRDATAS    (HRDATAINITEXP0)

    );


  sse710_integration_example_f0_ahb_mtx_decoderINITEXP1 u_sse710_integration_example_f0_ahb_mtx_decoderinitexp1 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .remapping_dec  ( { REMAP[3], REMAP[2], REMAP[1], REMAP[0] } ),

    .HREADYS    (HREADYINITEXP1),
    .sel_dec        (i_sel3),
    .decode_addr_dec (i_addr3[31:10]),   
    .trans_dec      (i_trans3),

    .active_dec0    (i_active3to0),
    .readyout_dec0  (i_hready_mux_targflash0),
    .resp_dec0      (HRESPTARGFLASH0),
    .rdata_dec0     (HRDATATARGFLASH0),
    .ruser_dec0     (HRUSERTARGFLASH0),

    .active_dec1    (i_active3to1),
    .readyout_dec1  (i_hready_mux_targsram0),
    .resp_dec1      (HRESPTARGSRAM0),
    .rdata_dec1     (HRDATATARGSRAM0),
    .ruser_dec1     (HRUSERTARGSRAM0),

    .active_dec2    (i_active3to2),
    .readyout_dec2  (i_hready_mux_targsram1),
    .resp_dec2      (HRESPTARGSRAM1),
    .rdata_dec2     (HRDATATARGSRAM1),
    .ruser_dec2     (HRUSERTARGSRAM1),

    .active_dec3    (i_active3to3),
    .readyout_dec3  (i_hready_mux_targsram2),
    .resp_dec3      (HRESPTARGSRAM2),
    .rdata_dec3     (HRDATATARGSRAM2),
    .ruser_dec3     (HRUSERTARGSRAM2),

    .active_dec4    (i_active3to4),
    .readyout_dec4  (i_hready_mux_targsram3),
    .resp_dec4      (HRESPTARGSRAM3),
    .rdata_dec4     (HRDATATARGSRAM3),
    .ruser_dec4     (HRUSERTARGSRAM3),

    .active_dec5    (i_active3to5),
    .readyout_dec5  (i_hready_mux_targapb0),
    .resp_dec5      (HRESPTARGAPB0),
    .rdata_dec5     (HRDATATARGAPB0),
    .ruser_dec5     (HRUSERTARGAPB0),

    .active_dec6    (i_active3to6),
    .readyout_dec6  (i_hready_mux_targexp0),
    .resp_dec6      (HRESPTARGEXP0),
    .rdata_dec6     (HRDATATARGEXP0),
    .ruser_dec6     (HRUSERTARGEXP0),

    .active_dec7    (i_active3to7),
    .readyout_dec7  (i_hready_mux_targexp1),
    .resp_dec7      (HRESPTARGEXP1),
    .rdata_dec7     (HRDATATARGEXP1),
    .ruser_dec7     (HRUSERTARGEXP1),

    .sel_dec0       (i_sel3to0),
    .sel_dec1       (i_sel3to1),
    .sel_dec2       (i_sel3to2),
    .sel_dec3       (i_sel3to3),
    .sel_dec4       (i_sel3to4),
    .sel_dec5       (i_sel3to5),
    .sel_dec6       (i_sel3to6),
    .sel_dec7       (i_sel3to7),

    .active_dec     (i_active3),
    .HREADYOUTS (i_readyout3),
    .HRESPS     (i_resp3),
    .HRUSERS    (HRUSERINITEXP1),
    .HRDATAS    (HRDATAINITEXP1)

    );


  sse710_integration_example_f0_ahb_mtx_output_stageTARGFLASH0 u_sse710_integration_example_f0_ahb_mtx_output_stagetargflash0_0 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

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
    .wdata_op0     (HWDATAINITCM3DI),
    .wuser_op0     (HWUSERINITCM3DI),
    .held_tran_op0  (i_held_tran0),

    .sel_op2       (i_sel2to0),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to0),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGFLASH0),

    .active_op0    (i_active0to0),
    .active_op2    (i_active2to0),
    .active_op3    (i_active3to0),

    .HSELM      (HSELTARGFLASH0),
    .HADDRM     (HADDRTARGFLASH0),
    .HAUSERM    (HAUSERTARGFLASH0),
    .HTRANSM    (HTRANSTARGFLASH0),
    .HWRITEM    (HWRITETARGFLASH0),
    .HSIZEM     (HSIZETARGFLASH0),
    .HBURSTM    (HBURSTTARGFLASH0),
    .HPROTM     (HPROTTARGFLASH0),
    .HMASTERM   (HMASTERTARGFLASH0),
    .HMASTLOCKM (HMASTLOCKTARGFLASH0),
    .HREADYMUXM (i_hready_mux_targflash0),
    .HWUSERM    (HWUSERTARGFLASH0),
    .HWDATAM    (HWDATATARGFLASH0)

    );

  assign HREADYMUXTARGFLASH0 = i_hready_mux_targflash0;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGSRAM0 u_sse710_integration_example_f0_ahb_mtx_output_stagetargsram0_1 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

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
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to1),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to1),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGSRAM0),

    .active_op1    (i_active1to1),
    .active_op2    (i_active2to1),
    .active_op3    (i_active3to1),

    .HSELM      (HSELTARGSRAM0),
    .HADDRM     (HADDRTARGSRAM0),
    .HAUSERM    (HAUSERTARGSRAM0),
    .HTRANSM    (HTRANSTARGSRAM0),
    .HWRITEM    (HWRITETARGSRAM0),
    .HSIZEM     (HSIZETARGSRAM0),
    .HBURSTM    (HBURSTTARGSRAM0),
    .HPROTM     (HPROTTARGSRAM0),
    .HMASTERM   (HMASTERTARGSRAM0),
    .HMASTLOCKM (HMASTLOCKTARGSRAM0),
    .HREADYMUXM (i_hready_mux_targsram0),
    .HWUSERM    (HWUSERTARGSRAM0),
    .HWDATAM    (HWDATATARGSRAM0)

    );

  assign HREADYMUXTARGSRAM0 = i_hready_mux_targsram0;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGSRAM1 u_sse710_integration_example_f0_ahb_mtx_output_stagetargsram1_2 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op1       (i_sel1to2),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to2),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to2),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGSRAM1),

    .active_op1    (i_active1to2),
    .active_op2    (i_active2to2),
    .active_op3    (i_active3to2),

    .HSELM      (HSELTARGSRAM1),
    .HADDRM     (HADDRTARGSRAM1),
    .HAUSERM    (HAUSERTARGSRAM1),
    .HTRANSM    (HTRANSTARGSRAM1),
    .HWRITEM    (HWRITETARGSRAM1),
    .HSIZEM     (HSIZETARGSRAM1),
    .HBURSTM    (HBURSTTARGSRAM1),
    .HPROTM     (HPROTTARGSRAM1),
    .HMASTERM   (HMASTERTARGSRAM1),
    .HMASTLOCKM (HMASTLOCKTARGSRAM1),
    .HREADYMUXM (i_hready_mux_targsram1),
    .HWUSERM    (HWUSERTARGSRAM1),
    .HWDATAM    (HWDATATARGSRAM1)

    );

  assign HREADYMUXTARGSRAM1 = i_hready_mux_targsram1;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGSRAM2 u_sse710_integration_example_f0_ahb_mtx_output_stagetargsram2_3 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op1       (i_sel1to3),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to3),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to3),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGSRAM2),

    .active_op1    (i_active1to3),
    .active_op2    (i_active2to3),
    .active_op3    (i_active3to3),

    .HSELM      (HSELTARGSRAM2),
    .HADDRM     (HADDRTARGSRAM2),
    .HAUSERM    (HAUSERTARGSRAM2),
    .HTRANSM    (HTRANSTARGSRAM2),
    .HWRITEM    (HWRITETARGSRAM2),
    .HSIZEM     (HSIZETARGSRAM2),
    .HBURSTM    (HBURSTTARGSRAM2),
    .HPROTM     (HPROTTARGSRAM2),
    .HMASTERM   (HMASTERTARGSRAM2),
    .HMASTLOCKM (HMASTLOCKTARGSRAM2),
    .HREADYMUXM (i_hready_mux_targsram2),
    .HWUSERM    (HWUSERTARGSRAM2),
    .HWDATAM    (HWDATATARGSRAM2)

    );

  assign HREADYMUXTARGSRAM2 = i_hready_mux_targsram2;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGSRAM3 u_sse710_integration_example_f0_ahb_mtx_output_stagetargsram3_4 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op1       (i_sel1to4),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to4),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to4),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGSRAM3),

    .active_op1    (i_active1to4),
    .active_op2    (i_active2to4),
    .active_op3    (i_active3to4),

    .HSELM      (HSELTARGSRAM3),
    .HADDRM     (HADDRTARGSRAM3),
    .HAUSERM    (HAUSERTARGSRAM3),
    .HTRANSM    (HTRANSTARGSRAM3),
    .HWRITEM    (HWRITETARGSRAM3),
    .HSIZEM     (HSIZETARGSRAM3),
    .HBURSTM    (HBURSTTARGSRAM3),
    .HPROTM     (HPROTTARGSRAM3),
    .HMASTERM   (HMASTERTARGSRAM3),
    .HMASTLOCKM (HMASTLOCKTARGSRAM3),
    .HREADYMUXM (i_hready_mux_targsram3),
    .HWUSERM    (HWUSERTARGSRAM3),
    .HWDATAM    (HWDATATARGSRAM3)

    );

  assign HREADYMUXTARGSRAM3 = i_hready_mux_targsram3;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGAPB0 u_sse710_integration_example_f0_ahb_mtx_output_stagetargapb0_5 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op1       (i_sel1to5),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to5),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to5),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGAPB0),

    .active_op1    (i_active1to5),
    .active_op2    (i_active2to5),
    .active_op3    (i_active3to5),

    .HSELM      (HSELTARGAPB0),
    .HADDRM     (HADDRTARGAPB0),
    .HAUSERM    (HAUSERTARGAPB0),
    .HTRANSM    (HTRANSTARGAPB0),
    .HWRITEM    (HWRITETARGAPB0),
    .HSIZEM     (HSIZETARGAPB0),
    .HBURSTM    (HBURSTTARGAPB0),
    .HPROTM     (HPROTTARGAPB0),
    .HMASTERM   (HMASTERTARGAPB0),
    .HMASTLOCKM (HMASTLOCKTARGAPB0),
    .HREADYMUXM (i_hready_mux_targapb0),
    .HWUSERM    (HWUSERTARGAPB0),
    .HWDATAM    (HWDATATARGAPB0)

    );

  assign HREADYMUXTARGAPB0 = i_hready_mux_targapb0;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGEXP0 u_sse710_integration_example_f0_ahb_mtx_output_stagetargexp0_6 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op1       (i_sel1to6),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to6),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to6),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGEXP0),

    .active_op1    (i_active1to6),
    .active_op2    (i_active2to6),
    .active_op3    (i_active3to6),

    .HSELM      (HSELTARGEXP0),
    .HADDRM     (HADDRTARGEXP0),
    .HAUSERM    (HAUSERTARGEXP0),
    .HTRANSM    (HTRANSTARGEXP0),
    .HWRITEM    (HWRITETARGEXP0),
    .HSIZEM     (HSIZETARGEXP0),
    .HBURSTM    (HBURSTTARGEXP0),
    .HPROTM     (HPROTTARGEXP0),
    .HMASTERM   (HMASTERTARGEXP0),
    .HMASTLOCKM (HMASTLOCKTARGEXP0),
    .HREADYMUXM (i_hready_mux_targexp0),
    .HWUSERM    (HWUSERTARGEXP0),
    .HWDATAM    (HWDATATARGEXP0)

    );

  assign HREADYMUXTARGEXP0 = i_hready_mux_targexp0;


  sse710_integration_example_f0_ahb_mtx_output_stageTARGEXP1 u_sse710_integration_example_f0_ahb_mtx_output_stagetargexp1_7 (

    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    .sel_op0       (i_sel0to7),
    .addr_op0      (i_addr0),
    .auser_op0     (i_auser0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATAINITCM3DI),
    .wuser_op0     (HWUSERINITCM3DI),
    .held_tran_op0  (i_held_tran0),

    .sel_op1       (i_sel1to7),
    .addr_op1      (i_addr1),
    .auser_op1     (i_auser1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATAINITCM3S),
    .wuser_op1     (HWUSERINITCM3S),
    .held_tran_op1  (i_held_tran1),

    .sel_op2       (i_sel2to7),
    .addr_op2      (i_addr2),
    .auser_op2     (i_auser2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATAINITEXP0),
    .wuser_op2     (HWUSERINITEXP0),
    .held_tran_op2  (i_held_tran2),

    .sel_op3       (i_sel3to7),
    .addr_op3      (i_addr3),
    .auser_op3     (i_auser3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATAINITEXP1),
    .wuser_op3     (HWUSERINITEXP1),
    .held_tran_op3  (i_held_tran3),

    .HREADYOUTM (HREADYOUTTARGEXP1),

    .active_op0    (i_active0to7),
    .active_op1    (i_active1to7),
    .active_op2    (i_active2to7),
    .active_op3    (i_active3to7),

    .HSELM      (HSELTARGEXP1),
    .HADDRM     (HADDRTARGEXP1),
    .HAUSERM    (HAUSERTARGEXP1),
    .HTRANSM    (HTRANSTARGEXP1),
    .HWRITEM    (HWRITETARGEXP1),
    .HSIZEM     (HSIZETARGEXP1),
    .HBURSTM    (HBURSTTARGEXP1),
    .HPROTM     (HPROTTARGEXP1),
    .HMASTERM   (HMASTERTARGEXP1),
    .HMASTLOCKM (HMASTLOCKTARGEXP1),
    .HREADYMUXM (i_hready_mux_targexp1),
    .HWUSERM    (HWUSERTARGEXP1),
    .HWDATAM    (HWDATATARGEXP1)

    );

  assign HREADYMUXTARGEXP1 = i_hready_mux_targexp1;


endmodule

