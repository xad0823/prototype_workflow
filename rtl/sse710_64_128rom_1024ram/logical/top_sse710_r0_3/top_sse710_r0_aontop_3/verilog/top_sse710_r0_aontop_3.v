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


module top_sse710_r0_aontop_3 #(

  `include "top_sse710_r0_params_3.vh"
  
 ) (
  input  wire         S32KCLK,
  input  wire         REFCLK,
  input  wire         SECENCREFCLK,
  input  wire         TRACECLKIN,
  input  wire         UARTCLK,
  input  wire         SYSPLL,
  input  wire         SYSPLLLOCK,
  input  wire         CPUPLL,
  input  wire         CPUPLLLOCK,

  output wire         DBGCLKOUT,
  output wire         HOSTAONEXPCLK,
  output wire         TRACECLKOUT,
  output wire         HOSTCNTCLKOUT,
  output wire         HOSTS32KCNTCLKOUT,
  
  
  input  wire         PORESETn,
  input  wire         nSRST,
  output wire         AONTOPPORESETn,
  output wire         AONTOPWARMRESETn,
  output wire         DBGTOPWARMRESETn,

  input wire [11:0]   SOCPRTID,
  input wire [3:0]    SOCVAR,
  input wire [3:0]    SOCREV,
  input wire [10:0]   SOCIMPLID,

  input wire [11:0]   DPROMPRTID,
  input wire [3:0]    DPROMREV,
  input wire [3:0]    DPROMVAR,
  input wire [10:0]   DPROMIMPLID,

  input wire [11:0]   EXTDBGROMPRTID,
  input wire [3:0]    EXTDBGROMREV,
  input wire [3:0]    EXTDBGROMVAR,
  input wire [10:0]   EXTDBGROMIMPLID,

  input wire [11:0]   HOSTROMPRTID,
  input wire [3:0]    HOSTROMREV,
  input wire [3:0]    HOSTROMVAR,
  input wire [10:0]   HOSTROMIMPLID,

  input wire [11:0]   HOSTAXIAPROMPRTID,
  input wire [3:0]    HOSTAXIAPROMREV,
  input wire [3:0]    HOSTAXIAPROMVAR,
  input wire [10:0]   HOSTAXIAPROMIMPLID,

  input wire [7:0]    OCVMSIZE,
  input wire [7:0]    XNVMSIZE,
  input wire [7:0]    CVMSIZE,

  
  input  wire [63:0]  EXPSHDINT,
  input  wire         GICWAKEUP,
  
  input  wire         SWCLKTCK,
  input  wire         nTRST,
  
  output wire [15:0]  HOSTDBGPWRREQ,
  input  wire [15:0]  HOSTDBGPWRACK,
  
  input  wire         SWDITMS,
  output wire         SWDO,
  output wire         SWDOEN,
  input  wire         TDI,
  output wire         TDO,
  output wire         TDOENn,
  output wire         SWACTIVE,
  output wire         JTAGACTIVE,
  output wire [3:0]   JTAGIR,
  output wire [3:0]   JTAGSTATE,
  output wire         DORMANTSTATE,

  input  wire         ATWAKEUPHOSTDBGTRACEEXP,
  input  wire [6:0]   ATIDHOSTDBGTRACEEXP,
  input  wire [1:0]   ATBYTESHOSTDBGTRACEEXP,
  input  wire [31:0]  ATDATAHOSTDBGTRACEEXP,
  input  wire         ATVALIDHOSTDBGTRACEEXP,
  output wire         ATREADYHOSTDBGTRACEEXP,
  output wire         AFVALIDHOSTDBGTRACEEXP,
  input  wire         AFREADYHOSTDBGTRACEEXP,
  output wire         SYNCREQHOSTDBGTRACEEXP,
  
  input  wire [3:0]   HOSTCTICHINEXP,
  output wire [3:0]   HOSTCTICHOUTEXP,
  
  output wire         PWAKEUPHOSTDBGEXP,
  output wire         PSELHOSTDBGEXP,
  output wire         PENABLEHOSTDBGEXP,
  output wire         PWRITEHOSTDBGEXP,
  output wire  [2:0]  PPROTHOSTDBGEXP,
  output wire  [3:0]  PSTRBHOSTDBGEXP,
  output wire [31:0]  PADDRHOSTDBGEXP,
  output wire [31:0]  PWDATAHOSTDBGEXP,
  input  wire         PREADYHOSTDBGEXP,
  input  wire         PSLVERRHOSTDBGEXP,
  input  wire [31:0]  PRDATAHOSTDBGEXP,
  
  input wire          HOSTSTMDPRDRREADY,
  input wire          HOSTSTMDPRDAVALID,
  input wire [1:0]    HOSTSTMDPRDATYPE,
  output wire         HOSTSTMDPRDRVALID,
  output wire [1:0]   HOSTSTMDPRDRTYPE,
  output wire         HOSTSTMDPRDRLAST,
  output wire         HOSTSTMDPRDAREADY,
  
  output wire [63:0]  SCBEXP,
  
  input  wire         SOCLCC,

  output wire [31:0]  TPIUTRACEDATA,
  output wire         TPIUTRACECTL,
  input  wire  [4:0]  TPIUTRACEMAXDATASIZE,
  input  wire         TPIUTPCTLVALID,
      
  input  wire         REFCLKQREQn,
  output wire         REFCLKQACCEPTn,
  output wire         REFCLKQDENY,
  output wire         REFCLKQACTIVE,


    output wire [7:0] DBGCLKQREQn,
  input wire [7:0] DBGCLKQACCEPTn,
  input wire [7:0] DBGCLKQDENY,
  input wire [7:0] DBGCLKQACTIVE,
  
  output wire [2:0]   DBGTOPQREQn,
  input  wire [2:0]   DBGTOPQACCEPTn,
  input  wire [2:0]   DBGTOPQDENY,
  input  wire [2:0]   DBGTOPQACTIVE,

  

  output wire         HOSTDBGAUTHDBGEN,
  output wire         HOSTDBGAUTHNIDEN,
  output wire         HOSTDBGAUTHSPIDEN,
  output wire         HOSTDBGAUTHSPNIDEN,

  input  wire [63:0]  HOSTTSVALUEB,

  output wire [63:0]  HOSTCNTVALUEG,
  input  wire [63:0]  HOSTCNTVALUEB,
  
  output wire [63:0]  HOSTS32KCNTVALUEG,
  input  wire [63:0]  HOSTS32KCNTVALUEB,

  output wire         HOSTUART0OUT2n,
  output wire         HOSTUART0OUT1n,
  output wire         HOSTUART0RTSn,
  output wire         HOSTUART0DTRn,
  output wire         HOSTUART0TX,
  input  wire         HOSTUART0CTSn,
  input  wire         HOSTUART0DCDn,
  input  wire         HOSTUART0DSRn,
  input  wire         HOSTUART0RIn,
  input  wire         HOSTUART0RX,
                      
  output wire         HOSTUART1OUT2n,
  output wire         HOSTUART1OUT1n,
  output wire         HOSTUART1RTSn,
  output wire         HOSTUART1DTRn,
  output wire         HOSTUART1TX,
  input  wire         HOSTUART1CTSn,
  input  wire         HOSTUART1DCDn,
  input  wire         HOSTUART1DSRn,
  input  wire         HOSTUART1RIn,
  input  wire         HOSTUART1RX,

  output wire         SECENCUARTTX,
  input  wire         SECENCUARTRX,
  output wire         SECENCUARTRTSn,
  input  wire         SECENCUARTCTSn,
  input  wire         SECENCUARTRIn,
  input  wire         SECENCUARTDCDn,
  input  wire         SECENCUARTDSRn,
  output wire         SECENCUARTDTRn,
  output wire         SECENCUARTOUT1n,
  output wire         SECENCUARTOUT2n,
  
  output wire         PSELHOSTAONEXPMST,
  output wire         PENABLEHOSTAONEXPMST,
  output wire [31:0]  PADDRHOSTAONEXPMST,
  output wire         PWRITEHOSTAONEXPMST,
  output wire [31:0]  PWDATAHOSTAONEXPMST,
  output wire [3:0]   PSTRBHOSTAONEXPMST,
  output wire [2:0]   PPROTHOSTAONEXPMST,
  output wire         PWAKEUPHOSTAONEXPMST,
  input  wire         PREADYHOSTAONEXPMST,
  input  wire [31:0]  PRDATAHOSTAONEXPMST,
  input  wire         PSLVERRHOSTAONEXPMST,


  output wire         ACLKOUT,
  output wire         SYSTOPWARMRESETn,   

  output wire [14:0] ACLKQREQn,
  input  wire [14:0] ACLKQACCEPTn,
  input  wire [14:0] ACLKQDENY,
  input  wire [14:0] ACLKQACTIVE,

  output wire [2:0]   SYSTOPQREQn,
  input  wire [2:0]   SYSTOPQACCEPTn,
  input  wire [2:0]   SYSTOPQDENY,
  input  wire [2:0]   SYSTOPQACTIVE,
  
  output wire [11:0]  AWIDCVM,
  output wire [31:0]  AWADDRCVM,
  output wire [7:0]   AWLENCVM,
  output wire [2:0]   AWSIZECVM,
  output wire [1:0]   AWBURSTCVM,
  output wire         AWLOCKCVM,
  output wire [3:0]   AWCACHECVM,
  output wire [2:0]   AWPROTCVM,
  output wire         AWVALIDCVM,
  output wire         AWAKEUPCVM,
  input  wire         AWREADYCVM,
  output wire [64-1:0]  WDATACVM,
  output wire [(64/8)-1:0]   WSTRBCVM,
  output wire         WLASTCVM,
  output wire         WVALIDCVM,
  input  wire         WREADYCVM,
  input  wire [11:0]  BIDCVM,
  input  wire [1:0]   BRESPCVM,
  input  wire         BVALIDCVM,
  output wire         BREADYCVM,
  output wire [11:0]  ARIDCVM,
  output wire [31:0]  ARADDRCVM,
  output wire [7:0]   ARLENCVM,
  output wire [2:0]   ARSIZECVM,
  output wire [1:0]   ARBURSTCVM,
  output wire         ARLOCKCVM,
  output wire [3:0]   ARCACHECVM,
  output wire [2:0]   ARPROTCVM,
  output wire         ARVALIDCVM,
  input  wire         ARREADYCVM,
  input  wire [11:0]  RIDCVM,
  input  wire [64-1:0]  RDATACVM,
  input  wire [1:0]   RRESPCVM,
  input  wire         RLASTCVM,
  input  wire         RVALIDCVM,
  output wire         RREADYCVM,
  output wire [7:0]   AWMMUSIDCVM,
  output wire [1:0]   AWUSERCVM,
  output wire [7:0]   ARMMUSIDCVM,
  output wire [1:0]   ARUSERCVM,
  output wire [3:0]   AWQOSCVM,
  output wire [3:0]   ARQOSCVM,

  output wire [11:0]  AWIDXNVM,
  output wire [31:0]  AWADDRXNVM,
  output wire [7:0]   AWLENXNVM,
  output wire [2:0]   AWSIZEXNVM,
  output wire [1:0]   AWBURSTXNVM,
  output wire         AWLOCKXNVM,
  output wire [3:0]   AWCACHEXNVM,
  output wire [2:0]   AWPROTXNVM,
  output wire         AWVALIDXNVM,
  output wire         AWAKEUPXNVM,
  input  wire         AWREADYXNVM,
  output wire [64-1:0]  WDATAXNVM,
  output wire [(64/8)-1:0]   WSTRBXNVM,
  output wire         WLASTXNVM,
  output wire         WVALIDXNVM,
  input  wire         WREADYXNVM,
  input  wire [11:0]  BIDXNVM,
  input  wire [1:0]   BRESPXNVM,
  input  wire         BVALIDXNVM,
  output wire         BREADYXNVM,
  output wire [11:0]  ARIDXNVM,
  output wire [31:0]  ARADDRXNVM,
  output wire [7:0]   ARLENXNVM,
  output wire [2:0]   ARSIZEXNVM,
  output wire [1:0]   ARBURSTXNVM,
  output wire         ARLOCKXNVM,
  output wire [3:0]   ARCACHEXNVM,
  output wire [2:0]   ARPROTXNVM,
  output wire         ARVALIDXNVM,
  input  wire         ARREADYXNVM,
  input  wire [11:0]  RIDXNVM,
  input  wire [64-1:0]  RDATAXNVM,
  input  wire [1:0]   RRESPXNVM,
  input  wire         RLASTXNVM,
  input  wire         RVALIDXNVM,
  output wire         RREADYXNVM,
  output wire [7:0]   AWMMUSIDXNVM,
  output wire [1:0]   AWUSERXNVM,
  output wire [7:0]   ARMMUSIDXNVM,
  output wire [1:0]   ARUSERXNVM,
  output wire [3:0]   AWQOSXNVM,
  output wire [3:0]   ARQOSXNVM,

  output wire [11:0]  AWIDOCVM,
  output wire [31:0]  AWADDROCVM,
  output wire [7:0]   AWLENOCVM,
  output wire [2:0]   AWSIZEOCVM,
  output wire [1:0]   AWBURSTOCVM,
  output wire         AWLOCKOCVM,
  output wire [3:0]   AWCACHEOCVM,
  output wire [2:0]   AWPROTOCVM,
  output wire         AWVALIDOCVM,
  output wire         AWAKEUPOCVM,
  input  wire         AWREADYOCVM,
  output wire [64-1:0]  WDATAOCVM,
  output wire [(64/8)-1:0]   WSTRBOCVM,
  output wire         WLASTOCVM,
  output wire         WVALIDOCVM,
  input  wire         WREADYOCVM,
  input  wire [11:0]  BIDOCVM,
  input  wire [1:0]   BRESPOCVM,
  input  wire         BVALIDOCVM,
  output wire         BREADYOCVM,
  output wire [11:0]  ARIDOCVM,
  output wire [31:0]  ARADDROCVM,
  output wire [7:0]   ARLENOCVM,
  output wire [2:0]   ARSIZEOCVM,
  output wire [1:0]   ARBURSTOCVM,
  output wire         ARLOCKOCVM,
  output wire [3:0]   ARCACHEOCVM,
  output wire [2:0]   ARPROTOCVM,
  output wire         ARVALIDOCVM,
  input  wire         ARREADYOCVM,
  input  wire [11:0]  RIDOCVM,
  input  wire [64-1:0]  RDATAOCVM,
  input  wire [1:0]   RRESPOCVM,
  input  wire         RLASTOCVM,
  input  wire         RVALIDOCVM,
  output wire         RREADYOCVM,
  output wire [7:0]   AWMMUSIDOCVM,
  output wire [1:0]   AWUSEROCVM,
  output wire [7:0]   ARMMUSIDOCVM,
  output wire [1:0]   ARUSEROCVM,
  output wire [3:0]   AWQOSOCVM,
  output wire [3:0]   ARQOSOCVM,

 
  input  wire [8-1:0]   AWIDEXPSLV0,
  input  wire [31:0]  AWADDREXPSLV0,
  input  wire [7:0]   AWLENEXPSLV0,
  input  wire [2:0]   AWSIZEEXPSLV0,
  input  wire [1:0]   AWBURSTEXPSLV0,
  input  wire         AWLOCKEXPSLV0,
  input  wire [3:0]   AWCACHEEXPSLV0,
  input  wire [2:0]   AWPROTEXPSLV0,
  input  wire         AWVALIDEXPSLV0,
  input  wire         AWAKEUPEXPSLV0,
  output wire         AWREADYEXPSLV0,
  input  wire [64-1:0]  WDATAEXPSLV0,
  input  wire [(64/8)-1:0]   WSTRBEXPSLV0,
  input  wire         WLASTEXPSLV0,
  input  wire         WVALIDEXPSLV0,
  output wire         WREADYEXPSLV0,
  output wire [8-1:0]   BIDEXPSLV0,
  output wire [1:0]   BRESPEXPSLV0,
  output wire         BVALIDEXPSLV0,
  input  wire         BREADYEXPSLV0,
  input  wire [8-1:0]   ARIDEXPSLV0,
  input  wire [31:0]  ARADDREXPSLV0,
  input  wire [7:0]   ARLENEXPSLV0,
  input  wire [2:0]   ARSIZEEXPSLV0,
  input  wire [1:0]   ARBURSTEXPSLV0,
  input  wire         ARLOCKEXPSLV0,
  input  wire [3:0]   ARCACHEEXPSLV0,
  input  wire [2:0]   ARPROTEXPSLV0,
  input  wire         ARVALIDEXPSLV0,
  output wire         ARREADYEXPSLV0,
  output wire [8-1:0]   RIDEXPSLV0,
  output wire [64-1:0]  RDATAEXPSLV0,
  output wire [1:0]   RRESPEXPSLV0,
  output wire         RLASTEXPSLV0,
  output wire         RVALIDEXPSLV0,
  input  wire         RREADYEXPSLV0,
  input  wire [7:0]   AWMMUSIDEXPSLV0,
  input  wire [1:0]   AWUSEREXPSLV0,
  input  wire [7:0]   ARMMUSIDEXPSLV0,
  input  wire [1:0]   ARUSEREXPSLV0,
  input  wire [3:0]   AWQOSEXPSLV0,
  input  wire [3:0]   ARQOSEXPSLV0,

 
  input  wire [8-1:0]   AWIDEXPSLV1,
  input  wire [31:0]  AWADDREXPSLV1,
  input  wire [7:0]   AWLENEXPSLV1,
  input  wire [2:0]   AWSIZEEXPSLV1,
  input  wire [1:0]   AWBURSTEXPSLV1,
  input  wire         AWLOCKEXPSLV1,
  input  wire [3:0]   AWCACHEEXPSLV1,
  input  wire [2:0]   AWPROTEXPSLV1,
  input  wire         AWVALIDEXPSLV1,
  input  wire         AWAKEUPEXPSLV1,
  output wire         AWREADYEXPSLV1,
  input  wire [64-1:0]  WDATAEXPSLV1,
  input  wire [(64/8)-1:0]   WSTRBEXPSLV1,
  input  wire         WLASTEXPSLV1,
  input  wire         WVALIDEXPSLV1,
  output wire         WREADYEXPSLV1,
  output wire [8-1:0]   BIDEXPSLV1,
  output wire [1:0]   BRESPEXPSLV1,
  output wire         BVALIDEXPSLV1,
  input  wire         BREADYEXPSLV1,
  input  wire [8-1:0]   ARIDEXPSLV1,
  input  wire [31:0]  ARADDREXPSLV1,
  input  wire [7:0]   ARLENEXPSLV1,
  input  wire [2:0]   ARSIZEEXPSLV1,
  input  wire [1:0]   ARBURSTEXPSLV1,
  input  wire         ARLOCKEXPSLV1,
  input  wire [3:0]   ARCACHEEXPSLV1,
  input  wire [2:0]   ARPROTEXPSLV1,
  input  wire         ARVALIDEXPSLV1,
  output wire         ARREADYEXPSLV1,
  output wire [8-1:0]   RIDEXPSLV1,
  output wire [64-1:0]  RDATAEXPSLV1,
  output wire [1:0]   RRESPEXPSLV1,
  output wire         RLASTEXPSLV1,
  output wire         RVALIDEXPSLV1,
  input  wire         RREADYEXPSLV1,
  input  wire [7:0]   AWMMUSIDEXPSLV1,
  input  wire [1:0]   AWUSEREXPSLV1,
  input  wire [7:0]   ARMMUSIDEXPSLV1,
  input  wire [1:0]   ARUSEREXPSLV1,
  input  wire [3:0]   AWQOSEXPSLV1,
  input  wire [3:0]   ARQOSEXPSLV1,


 

  output wire [11:0]  AWIDEXPMST0,
  output wire [31:0]  AWADDREXPMST0,
  output wire [7:0]   AWLENEXPMST0,
  output wire [2:0]   AWSIZEEXPMST0,
  output wire [1:0]   AWBURSTEXPMST0,
  output wire         AWLOCKEXPMST0,
  output wire [3:0]   AWCACHEEXPMST0,
  output wire [2:0]   AWPROTEXPMST0,
  output wire         AWVALIDEXPMST0,
  output wire         AWAKEUPEXPMST0,
  input  wire         AWREADYEXPMST0,
  output wire [64-1:0]  WDATAEXPMST0,
  output wire [(64/8)-1:0]   WSTRBEXPMST0,
  output wire         WLASTEXPMST0,
  output wire         WVALIDEXPMST0,
  input  wire         WREADYEXPMST0,
  input  wire [11:0]  BIDEXPMST0,
  input  wire [1:0]   BRESPEXPMST0,
  input  wire         BVALIDEXPMST0,
  output wire         BREADYEXPMST0,
  output wire [11:0]  ARIDEXPMST0,
  output wire [31:0]  ARADDREXPMST0,
  output wire [7:0]   ARLENEXPMST0,
  output wire [2:0]   ARSIZEEXPMST0,
  output wire [1:0]   ARBURSTEXPMST0,
  output wire         ARLOCKEXPMST0,
  output wire [3:0]   ARCACHEEXPMST0,
  output wire [2:0]   ARPROTEXPMST0,
  output wire         ARVALIDEXPMST0,
  input  wire         ARREADYEXPMST0,
  input  wire [11:0]  RIDEXPMST0,
  input  wire [64-1:0]  RDATAEXPMST0,
  input  wire [1:0]   RRESPEXPMST0,
  input  wire         RLASTEXPMST0,
  input  wire         RVALIDEXPMST0,
  output wire         RREADYEXPMST0,
  output wire [7:0]   AWMMUSIDEXPMST0,
  output wire [1:0]   AWUSEREXPMST0,
  output wire [7:0]   ARMMUSIDEXPMST0,
  output wire [1:0]   ARUSEREXPMST0,
  output wire [3:0]   AWQOSEXPMST0,
  output wire [3:0]   ARQOSEXPMST0,

 

  output wire [11:0]  AWIDEXPMST1,
  output wire [31:0]  AWADDREXPMST1,
  output wire [7:0]   AWLENEXPMST1,
  output wire [2:0]   AWSIZEEXPMST1,
  output wire [1:0]   AWBURSTEXPMST1,
  output wire         AWLOCKEXPMST1,
  output wire [3:0]   AWCACHEEXPMST1,
  output wire [2:0]   AWPROTEXPMST1,
  output wire         AWVALIDEXPMST1,
  output wire         AWAKEUPEXPMST1,
  input  wire         AWREADYEXPMST1,
  output wire [64-1:0]  WDATAEXPMST1,
  output wire [(64/8)-1:0]   WSTRBEXPMST1,
  output wire         WLASTEXPMST1,
  output wire         WVALIDEXPMST1,
  input  wire         WREADYEXPMST1,
  input  wire [11:0]  BIDEXPMST1,
  input  wire [1:0]   BRESPEXPMST1,
  input  wire         BVALIDEXPMST1,
  output wire         BREADYEXPMST1,
  output wire [11:0]  ARIDEXPMST1,
  output wire [31:0]  ARADDREXPMST1,
  output wire [7:0]   ARLENEXPMST1,
  output wire [2:0]   ARSIZEEXPMST1,
  output wire [1:0]   ARBURSTEXPMST1,
  output wire         ARLOCKEXPMST1,
  output wire [3:0]   ARCACHEEXPMST1,
  output wire [2:0]   ARPROTEXPMST1,
  output wire         ARVALIDEXPMST1,
  input  wire         ARREADYEXPMST1,
  input  wire [11:0]  RIDEXPMST1,
  input  wire [64-1:0]  RDATAEXPMST1,
  input  wire [1:0]   RRESPEXPMST1,
  input  wire         RLASTEXPMST1,
  input  wire         RVALIDEXPMST1,
  output wire         RREADYEXPMST1,
  output wire [7:0]   AWMMUSIDEXPMST1,
  output wire [1:0]   AWUSEREXPMST1,
  output wire [7:0]   ARMMUSIDEXPMST1,
  output wire [1:0]   ARUSEREXPMST1,
  output wire [3:0]   AWQOSEXPMST1,
  output wire [3:0]   ARQOSEXPMST1,




  input  wire         EXTSYS0DBGCLKS,
  input  wire         EXTSYS0DBGCLKM,
  input  wire         EXTSYS0MHUCLK,
  input  wire         EXTSYS0ATCLK,
  input  wire         EXTSYS0CTICLK,
  input  wire         EXTSYS0ACLK,

  input  wire         EXTSYS0DBGPRESETSn,
  input  wire         EXTSYS0DBGPRESETMn,
  input  wire         EXTSYS0MHURESETn,
  input  wire         EXTSYS0ATRESETn,
  input  wire         EXTSYS0CTIRESETn,
  input  wire         EXTSYS0ARESETn,
  output wire         EXTSYS0PORESETn,

  output wire         EXTSYS0CPUWAIT,

  input  wire         AWAKEUPEXTSYS0MEM,
  input  wire [8-1:0]   AWIDEXTSYS0MEM,
  input  wire [31:0]  AWADDREXTSYS0MEM,
  input  wire [7:0]   AWLENEXTSYS0MEM,
  input  wire [2:0]   AWSIZEEXTSYS0MEM,
  input  wire [1:0]   AWBURSTEXTSYS0MEM,
  input  wire         AWLOCKEXTSYS0MEM,
  input  wire [3:0]   AWCACHEEXTSYS0MEM,
  input  wire [2:0]   AWPROTEXTSYS0MEM,
  input  wire [3:0]   AWREGIONEXTSYS0MEM,
  input  wire         AWVALIDEXTSYS0MEM,
  output wire         AWREADYEXTSYS0MEM,
  input  wire [(64/8)-1:0]   WSTRBEXTSYS0MEM,
  input  wire         WLASTEXTSYS0MEM,
  input  wire         WVALIDEXTSYS0MEM,
  input  wire [64-1:0]  WDATAEXTSYS0MEM,
  output wire         WREADYEXTSYS0MEM,
  output wire [8-1:0]   BIDEXTSYS0MEM,
  output wire [1:0]   BRESPEXTSYS0MEM,
  output wire         BVALIDEXTSYS0MEM,
  input  wire         BREADYEXTSYS0MEM,
  input  wire [8-1:0]   ARIDEXTSYS0MEM,
  input  wire [31:0]  ARADDREXTSYS0MEM,
  input  wire [7:0]   ARLENEXTSYS0MEM,
  input  wire [2:0]   ARSIZEEXTSYS0MEM,
  input  wire [1:0]   ARBURSTEXTSYS0MEM,
  input  wire         ARLOCKEXTSYS0MEM,
  input  wire [3:0]   ARCACHEEXTSYS0MEM,
  input  wire [2:0]   ARPROTEXTSYS0MEM,
  input  wire [3:0]   ARREGIONEXTSYS0MEM,
  input  wire         ARVALIDEXTSYS0MEM,
  output wire         ARREADYEXTSYS0MEM,
  output wire [8-1:0]   RIDEXTSYS0MEM,
  output wire [1:0]   RRESPEXTSYS0MEM,
  output wire         RLASTEXTSYS0MEM,
  output wire         RVALIDEXTSYS0MEM,
  output wire [64-1:0]  RDATAEXTSYS0MEM,
  input  wire         RREADYEXTSYS0MEM,

  input  wire         PSELEXTSYS0MHU,
  input  wire         PWAKEUPEXTSYS0MHU,
  input  wire         PENABLEEXTSYS0MHU,
  input  wire [18:0]  PADDREXTSYS0MHU,
  input  wire         PWRITEEXTSYS0MHU,
  input  wire [31:0]  PWDATAEXTSYS0MHU,
  input  wire [3:0]   PSTRBEXTSYS0MHU,
  input  wire [2:0]   PPROTEXTSYS0MHU,
  output wire [31:0]  PRDATAEXTSYS0MHU,
  output wire         PREADYEXTSYS0MHU,
  output wire         PSLVERREXTSYS0MHU,

  output wire         ESH0EXTSYS0MHUINT,
  output wire         HES0EXTSYS0MHUINT,
    
  output wire         ESH1EXTSYS0MHUINT,
  output wire         HES1EXTSYS0MHUINT,
  
  output wire         ESSE0EXTSYS0MHUINT,
  output wire         SEES0EXTSYS0MHUINT,
  
    
  output wire         ESSE1EXTSYS0MHUINT,
  output wire         SEES1EXTSYS0MHUINT,
  
  output wire         ATREADYEXTSYS0TRACEEXP,
  output wire         AFVALIDEXTSYS0TRACEEXP,
  output wire         SYNCREQEXTSYS0TRACEEXP,
  input  wire [6:0]   ATIDEXTSYS0TRACEEXP,
  input  wire         ATVALIDEXTSYS0TRACEEXP,
  input  wire [31:0]  ATDATAEXTSYS0TRACEEXP,
  input  wire [1:0]   ATBYTESEXTSYS0TRACEEXP,
  input  wire         AFREADYEXTSYS0TRACEEXP,
  input  wire         ATWAKEUPEXTSYS0TRACEEXP,

  output wire         PSELEXTSYS0DBG,
  output wire         PWAKEUPEXTSYS0DBG,
  output wire         PENABLEEXTSYS0DBG,
  output wire [31:0]  PADDREXTSYS0DBG,
  output wire         PWRITEEXTSYS0DBG,
  output wire [31:0]  PWDATAEXTSYS0DBG,
  output wire [3:0]   PSTRBEXTSYS0DBG,
  output wire [2:0]   PPROTEXTSYS0DBG,
  input  wire [31:0]  PRDATAEXTSYS0DBG,
  input  wire         PREADYEXTSYS0DBG,
  input  wire         PSLVERREXTSYS0DBG,

  output wire         DPABORTEXTSYS0DBG,

  input  wire         PSELEXTSYS0EXTDBG,
  input  wire         PWAKEUPEXTSYS0EXTDBG,
  input  wire         PENABLEEXTSYS0EXTDBG,
  input  wire [31:0]  PADDREXTSYS0EXTDBG,
  input  wire         PWRITEEXTSYS0EXTDBG,
  input  wire [31:0]  PWDATAEXTSYS0EXTDBG,
  input  wire [3:0]   PSTRBEXTSYS0EXTDBG,
  input  wire [2:0]   PPROTEXTSYS0EXTDBG,
  output wire [31:0]  PRDATAEXTSYS0EXTDBG,
  output wire         PREADYEXTSYS0EXTDBG,
  output wire         PSLVERREXTSYS0EXTDBG,

  input  wire [3:0]   EXTSYS0CTICHIN,

  output wire [3:0]   EXTSYS0CTICHOUT,

  output wire [95:0] EXTSYS0SHDINT,

  input  wire         EXTSYS0ACLKQREQn,
  output wire         EXTSYS0ACLKQACCEPTn,
  output wire         EXTSYS0ACLKQDENY,
  output wire         EXTSYS0ACLKQACTIVE,

  input  wire         EXTSYS0MHUCLKQREQn,
  output wire         EXTSYS0MHUCLKQACCEPTn,
  output wire         EXTSYS0MHUCLKQDENY,
  output wire         EXTSYS0MHUCLKQACTIVE,

  input  wire         EXTSYS0ATCLKQREQn,
  output wire         EXTSYS0ATCLKQACCEPTn,
  output wire         EXTSYS0ATCLKQDENY,
  output wire         EXTSYS0ATCLKQACTIVE,

  input  wire         EXTSYS0DBGCLKMQREQn,
  output wire         EXTSYS0DBGCLKMQACCEPTn,
  output wire         EXTSYS0DBGCLKMQDENY,
  output wire         EXTSYS0DBGCLKMQACTIVE,

  input  wire         EXTSYS0DBGCLKSQREQn,
  output wire         EXTSYS0DBGCLKSQACCEPTn,
  output wire         EXTSYS0DBGCLKSQDENY,
  output wire         EXTSYS0DBGCLKSQACTIVE,

  input  wire         EXTSYS0CTICLKQREQn,
  output wire         EXTSYS0CTICLKQACCEPTn,
  output wire         EXTSYS0CTICLKQDENY,
  output wire         EXTSYS0CTICLKQACTIVE,

  input  wire         EXTSYS0MEMPWRQREQn,
  output wire         EXTSYS0MEMPWRQACCEPTn,
  output wire         EXTSYS0MEMPWRQDENY,
  output wire         EXTSYS0MEMPWRQACTIVE,

  input  wire         EXTSYS0MHUPWRQREQn,
  output wire         EXTSYS0MHUPWRQACCEPTn,
  output wire         EXTSYS0MHUPWRQDENY,

  output wire         EXTSYS0MHUPWRREQACTIVE,

  input  wire         EXTSYS0TRACEEXPPWRQREQn,
  output wire         EXTSYS0TRACEEXPPWRQACCEPTn,
  output wire         EXTSYS0TRACEEXPPWRQDENY,
  output wire         EXTSYS0TRACEEXPPWRQACTIVE,

  input  wire         EXTSYS0DBGPWRQREQn,
  output wire         EXTSYS0DBGPWRQACCEPTn,
  output wire         EXTSYS0DBGPWRQDENY,
  output wire         EXTSYS0DBGPWRQACTIVE,

  input  wire         EXTSYS0EXTDBGPWRQREQn,
  output wire         EXTSYS0EXTDBGPWRQACCEPTn,
  output wire         EXTSYS0EXTDBGPWRQDENY,
  output wire         EXTSYS0EXTDBGPWRQACTIVE,

  input  wire         EXTSYS0CTIINPWRQREQn,
  output wire         EXTSYS0CTIINPWRQACCEPTn,
  output wire         EXTSYS0CTIINPWRQDENY,
  output wire         EXTSYS0CTIINPWRQACTIVE,

  input  wire         EXTSYS0CTIOUTPWRQREQn,
  output wire         EXTSYS0CTIOUTPWRQACCEPTn,
  output wire         EXTSYS0CTIOUTPWRQDENY,
  output wire         EXTSYS0CTIOUTPWRQACTIVE,

  output wire         EXTSYS0DBGTOPQREQn,
  input  wire         EXTSYS0DBGTOPQACCEPTn,
  input  wire         EXTSYS0DBGTOPQDENY,
  input  wire         EXTSYS0DBGTOPQACTIVE,

  output  wire        EXTSYS0SYSTOPQREQn,
  input   wire        EXTSYS0SYSTOPQACCEPTn,
  input   wire        EXTSYS0SYSTOPQDENY,
  input   wire        EXTSYS0SYSTOPQACTIVE,

  output  wire        EXTSYS0AONTOPQREQn,
  input   wire        EXTSYS0AONTOPQACCEPTn,
  input   wire        EXTSYS0AONTOPQDENY,
  input   wire        EXTSYS0AONTOPQACTIVE,

  output wire         EXTSYS0EXTDBGROMCDBGPWRUPREQ,
  input  wire         EXTSYS0EXTDBGROMCDBGPWRUPACK,
  output wire         EXTSYS0AXIAPROMCSYSPWRUPREQ,
  input  wire         EXTSYS0AXIAPROMCSYSPWRUPACK,

  output wire [4:0]   EXTSYS0RSTSYN,

  input  wire         EXTSYS1DBGCLKS,
  input  wire         EXTSYS1DBGCLKM,
  input  wire         EXTSYS1MHUCLK,
  input  wire         EXTSYS1ATCLK,
  input  wire         EXTSYS1CTICLK,
  input  wire         EXTSYS1ACLK,

  input  wire         EXTSYS1DBGPRESETSn,
  input  wire         EXTSYS1DBGPRESETMn,
  input  wire         EXTSYS1MHURESETn,
  input  wire         EXTSYS1ATRESETn,
  input  wire         EXTSYS1CTIRESETn,
  input  wire         EXTSYS1ARESETn,
  output wire         EXTSYS1PORESETn,

  output wire         EXTSYS1CPUWAIT,

  input  wire         AWAKEUPEXTSYS1MEM,
  input  wire [8-1:0]   AWIDEXTSYS1MEM,
  input  wire [31:0]  AWADDREXTSYS1MEM,
  input  wire [7:0]   AWLENEXTSYS1MEM,
  input  wire [2:0]   AWSIZEEXTSYS1MEM,
  input  wire [1:0]   AWBURSTEXTSYS1MEM,
  input  wire         AWLOCKEXTSYS1MEM,
  input  wire [3:0]   AWCACHEEXTSYS1MEM,
  input  wire [2:0]   AWPROTEXTSYS1MEM,
  input  wire [3:0]   AWREGIONEXTSYS1MEM,
  input  wire         AWVALIDEXTSYS1MEM,
  output wire         AWREADYEXTSYS1MEM,
  input  wire [(64/8)-1:0]   WSTRBEXTSYS1MEM,
  input  wire         WLASTEXTSYS1MEM,
  input  wire         WVALIDEXTSYS1MEM,
  input  wire [64-1:0]  WDATAEXTSYS1MEM,
  output wire         WREADYEXTSYS1MEM,
  output wire [8-1:0]   BIDEXTSYS1MEM,
  output wire [1:0]   BRESPEXTSYS1MEM,
  output wire         BVALIDEXTSYS1MEM,
  input  wire         BREADYEXTSYS1MEM,
  input  wire [8-1:0]   ARIDEXTSYS1MEM,
  input  wire [31:0]  ARADDREXTSYS1MEM,
  input  wire [7:0]   ARLENEXTSYS1MEM,
  input  wire [2:0]   ARSIZEEXTSYS1MEM,
  input  wire [1:0]   ARBURSTEXTSYS1MEM,
  input  wire         ARLOCKEXTSYS1MEM,
  input  wire [3:0]   ARCACHEEXTSYS1MEM,
  input  wire [2:0]   ARPROTEXTSYS1MEM,
  input  wire [3:0]   ARREGIONEXTSYS1MEM,
  input  wire         ARVALIDEXTSYS1MEM,
  output wire         ARREADYEXTSYS1MEM,
  output wire [8-1:0]   RIDEXTSYS1MEM,
  output wire [1:0]   RRESPEXTSYS1MEM,
  output wire         RLASTEXTSYS1MEM,
  output wire         RVALIDEXTSYS1MEM,
  output wire [64-1:0]  RDATAEXTSYS1MEM,
  input  wire         RREADYEXTSYS1MEM,

  input  wire         PSELEXTSYS1MHU,
  input  wire         PWAKEUPEXTSYS1MHU,
  input  wire         PENABLEEXTSYS1MHU,
  input  wire [18:0]  PADDREXTSYS1MHU,
  input  wire         PWRITEEXTSYS1MHU,
  input  wire [31:0]  PWDATAEXTSYS1MHU,
  input  wire [3:0]   PSTRBEXTSYS1MHU,
  input  wire [2:0]   PPROTEXTSYS1MHU,
  output wire [31:0]  PRDATAEXTSYS1MHU,
  output wire         PREADYEXTSYS1MHU,
  output wire         PSLVERREXTSYS1MHU,

  output wire         ESH0EXTSYS1MHUINT,
  output wire         HES0EXTSYS1MHUINT,
    
  output wire         ESH1EXTSYS1MHUINT,
  output wire         HES1EXTSYS1MHUINT,
  
  output wire         ESSE0EXTSYS1MHUINT,
  output wire         SEES0EXTSYS1MHUINT,
  
    
  output wire         ESSE1EXTSYS1MHUINT,
  output wire         SEES1EXTSYS1MHUINT,
  
  output wire         ATREADYEXTSYS1TRACEEXP,
  output wire         AFVALIDEXTSYS1TRACEEXP,
  output wire         SYNCREQEXTSYS1TRACEEXP,
  input  wire [6:0]   ATIDEXTSYS1TRACEEXP,
  input  wire         ATVALIDEXTSYS1TRACEEXP,
  input  wire [31:0]  ATDATAEXTSYS1TRACEEXP,
  input  wire [1:0]   ATBYTESEXTSYS1TRACEEXP,
  input  wire         AFREADYEXTSYS1TRACEEXP,
  input  wire         ATWAKEUPEXTSYS1TRACEEXP,

  output wire         PSELEXTSYS1DBG,
  output wire         PWAKEUPEXTSYS1DBG,
  output wire         PENABLEEXTSYS1DBG,
  output wire [31:0]  PADDREXTSYS1DBG,
  output wire         PWRITEEXTSYS1DBG,
  output wire [31:0]  PWDATAEXTSYS1DBG,
  output wire [3:0]   PSTRBEXTSYS1DBG,
  output wire [2:0]   PPROTEXTSYS1DBG,
  input  wire [31:0]  PRDATAEXTSYS1DBG,
  input  wire         PREADYEXTSYS1DBG,
  input  wire         PSLVERREXTSYS1DBG,

  output wire         DPABORTEXTSYS1DBG,

  input  wire         PSELEXTSYS1EXTDBG,
  input  wire         PWAKEUPEXTSYS1EXTDBG,
  input  wire         PENABLEEXTSYS1EXTDBG,
  input  wire [31:0]  PADDREXTSYS1EXTDBG,
  input  wire         PWRITEEXTSYS1EXTDBG,
  input  wire [31:0]  PWDATAEXTSYS1EXTDBG,
  input  wire [3:0]   PSTRBEXTSYS1EXTDBG,
  input  wire [2:0]   PPROTEXTSYS1EXTDBG,
  output wire [31:0]  PRDATAEXTSYS1EXTDBG,
  output wire         PREADYEXTSYS1EXTDBG,
  output wire         PSLVERREXTSYS1EXTDBG,

  input  wire [3:0]   EXTSYS1CTICHIN,

  output wire [3:0]   EXTSYS1CTICHOUT,

  output wire [95:0] EXTSYS1SHDINT,

  input  wire         EXTSYS1ACLKQREQn,
  output wire         EXTSYS1ACLKQACCEPTn,
  output wire         EXTSYS1ACLKQDENY,
  output wire         EXTSYS1ACLKQACTIVE,

  input  wire         EXTSYS1MHUCLKQREQn,
  output wire         EXTSYS1MHUCLKQACCEPTn,
  output wire         EXTSYS1MHUCLKQDENY,
  output wire         EXTSYS1MHUCLKQACTIVE,

  input  wire         EXTSYS1ATCLKQREQn,
  output wire         EXTSYS1ATCLKQACCEPTn,
  output wire         EXTSYS1ATCLKQDENY,
  output wire         EXTSYS1ATCLKQACTIVE,

  input  wire         EXTSYS1DBGCLKMQREQn,
  output wire         EXTSYS1DBGCLKMQACCEPTn,
  output wire         EXTSYS1DBGCLKMQDENY,
  output wire         EXTSYS1DBGCLKMQACTIVE,

  input  wire         EXTSYS1DBGCLKSQREQn,
  output wire         EXTSYS1DBGCLKSQACCEPTn,
  output wire         EXTSYS1DBGCLKSQDENY,
  output wire         EXTSYS1DBGCLKSQACTIVE,

  input  wire         EXTSYS1CTICLKQREQn,
  output wire         EXTSYS1CTICLKQACCEPTn,
  output wire         EXTSYS1CTICLKQDENY,
  output wire         EXTSYS1CTICLKQACTIVE,

  input  wire         EXTSYS1MEMPWRQREQn,
  output wire         EXTSYS1MEMPWRQACCEPTn,
  output wire         EXTSYS1MEMPWRQDENY,
  output wire         EXTSYS1MEMPWRQACTIVE,

  input  wire         EXTSYS1MHUPWRQREQn,
  output wire         EXTSYS1MHUPWRQACCEPTn,
  output wire         EXTSYS1MHUPWRQDENY,

  output wire         EXTSYS1MHUPWRREQACTIVE,

  input  wire         EXTSYS1TRACEEXPPWRQREQn,
  output wire         EXTSYS1TRACEEXPPWRQACCEPTn,
  output wire         EXTSYS1TRACEEXPPWRQDENY,
  output wire         EXTSYS1TRACEEXPPWRQACTIVE,

  input  wire         EXTSYS1DBGPWRQREQn,
  output wire         EXTSYS1DBGPWRQACCEPTn,
  output wire         EXTSYS1DBGPWRQDENY,
  output wire         EXTSYS1DBGPWRQACTIVE,

  input  wire         EXTSYS1EXTDBGPWRQREQn,
  output wire         EXTSYS1EXTDBGPWRQACCEPTn,
  output wire         EXTSYS1EXTDBGPWRQDENY,
  output wire         EXTSYS1EXTDBGPWRQACTIVE,

  input  wire         EXTSYS1CTIINPWRQREQn,
  output wire         EXTSYS1CTIINPWRQACCEPTn,
  output wire         EXTSYS1CTIINPWRQDENY,
  output wire         EXTSYS1CTIINPWRQACTIVE,

  input  wire         EXTSYS1CTIOUTPWRQREQn,
  output wire         EXTSYS1CTIOUTPWRQACCEPTn,
  output wire         EXTSYS1CTIOUTPWRQDENY,
  output wire         EXTSYS1CTIOUTPWRQACTIVE,

  output wire         EXTSYS1DBGTOPQREQn,
  input  wire         EXTSYS1DBGTOPQACCEPTn,
  input  wire         EXTSYS1DBGTOPQDENY,
  input  wire         EXTSYS1DBGTOPQACTIVE,

  output  wire        EXTSYS1SYSTOPQREQn,
  input   wire        EXTSYS1SYSTOPQACCEPTn,
  input   wire        EXTSYS1SYSTOPQDENY,
  input   wire        EXTSYS1SYSTOPQACTIVE,

  output  wire        EXTSYS1AONTOPQREQn,
  input   wire        EXTSYS1AONTOPQACCEPTn,
  input   wire        EXTSYS1AONTOPQDENY,
  input   wire        EXTSYS1AONTOPQACTIVE,

  output wire         EXTSYS1EXTDBGROMCDBGPWRUPREQ,
  input  wire         EXTSYS1EXTDBGROMCDBGPWRUPACK,
  output wire         EXTSYS1AXIAPROMCSYSPWRUPREQ,
  input  wire         EXTSYS1AXIAPROMCSYSPWRUPACK,

  output wire [4:0]   EXTSYS1RSTSYN,



  input  wire         MBISTREQ,
  input  wire         nMBISTRESET,

  input  wire         DFTDIVSEL,
  input  wire         DFTRAMHOLD,
  input  wire         DFTMCPHOLD,
  input  wire         DFTCGEN,
  input  wire [1:0]   DFTRSTDISABLE,
  input  wire         DFTPWRUP,
  input  wire         DFTRETDISABLE,
  input  wire         DFTISODISABLE,
  output wire [1:0]   DFTENABLE,
  input wire [2:0]    DFTHOSTUARTCLKSEL,
  input wire [1:0]    DFTCTRLCLKSEL,
  input wire [1:0]    DFTGICCLKSEL,
  input wire [1:0]    DFTACLKSEL,
  input wire [1:0]    DFTDBGCLKSEL,
  input wire [1:0]    DFTSECCLKSEL,
  input wire          DFTCLKSELEN,
  input wire [2:0]    DFTHOSTCPUCLKSEL,
  input wire          DFTDIVBYPASS,
  input  wire         DFTSE,
  input  wire         DFTTESTMODE  
);

localparam XNVM_DATA_WIDTH          = 64;
localparam CVM_DATA_WIDTH           = 64;
localparam OCVM_DATA_WIDTH          = 64; 

localparam EXT_SYS0_DATA_WIDTH     = 64; 
localparam EXT_SYS0_ID_WIDTH       = 8; 
localparam EXT_SYS1_DATA_WIDTH     = 64; 
localparam EXT_SYS1_ID_WIDTH       = 8; 

localparam EXPSLV0_DATA_WIDTH     = 64; 
localparam EXPSLV0_ID_WIDTH       = 8; 
localparam EXPSLV1_DATA_WIDTH     = 64; 
localparam EXPSLV1_ID_WIDTH       = 8; 

localparam EXPMST0_DATA_WIDTH     = 64; 
localparam EXPMST1_DATA_WIDTH     = 64; 

localparam HOST_CPU_NUM_CORES = 4;

localparam NUM_ACLK_QCH   = 8;
localparam NUM_DBGCLK_QCH = 8;

localparam NUM_EXP_SHD_INT   = 64;
localparam SECENC_SHD_INT    = NUM_EXP_SHD_INT < 33 ? NUM_EXP_SHD_INT + 32 : 64;

localparam A4S_ID_WIDTH      = 4;
localparam A4S_PAYLOAD_WIDTH = payload_width_fn(1,32,0,4,A4S_ID_WIDTH,A4S_ID_WIDTH,0);

localparam NUM_EXT_SYS = 2;
localparam SYS_EGRESS_2_DBG = 2;
localparam SYS_INGRESS_2_DBG = 1;
localparam CLUS_INGRESS_2_DBG = 3;
localparam DBG_INTERNAL_CNT = 2;
localparam DBG_EGRESS_CNT = 1;

localparam EXT_SYS0_TZ_SPT  = 1; 
localparam EXT_SYS1_TZ_SPT  = 1; 

localparam   EXT_SYS0_MEM_ADDR_WIDTH    = 32;
localparam   EXT_SYS0_MEM_DATA_WIDTH    = EXT_SYS0_DATA_WIDTH;
localparam   EXT_SYS0_MEM_AWID_WIDTH    = EXT_SYS0_ID_WIDTH;
localparam   EXT_SYS0_MEM_ARID_WIDTH    = EXT_SYS0_ID_WIDTH;
localparam   EXT_SYS0_MEM_AWUSER_WIDTH  = 0;
localparam   EXT_SYS0_MEM_WUSER_WIDTH   = 0;
localparam   EXT_SYS0_MEM_BUSER_WIDTH   = 0;
localparam   EXT_SYS0_MEM_ARUSER_WIDTH  = 0;
localparam   EXT_SYS0_MEM_RUSER_WIDTH   = 0;

localparam   EXT_SYS0_MEM_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(EXT_SYS0_MEM_AWUSER_WIDTH,EXT_SYS0_MEM_AWID_WIDTH,EXT_SYS0_MEM_ADDR_WIDTH)+0)*EXT_SYS0_MEM_AW_FIFO_DEPTH); 
localparam   EXT_SYS0_MEM_W_PAYLOAD_WIDTH = ((w_payload_width_fn(EXT_SYS0_MEM_WUSER_WIDTH,EXT_SYS0_MEM_AWID_WIDTH,EXT_SYS0_MEM_DATA_WIDTH)+0)* EXT_SYS0_MEM_W_FIFO_DEPTH);
localparam   EXT_SYS0_MEM_B_PAYLOAD_WIDTH = (b_payload_width_fn(EXT_SYS0_MEM_BUSER_WIDTH,EXT_SYS0_MEM_AWID_WIDTH)* EXT_SYS0_MEM_B_FIFO_DEPTH); 
localparam   EXT_SYS0_MEM_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(EXT_SYS0_MEM_ARUSER_WIDTH,EXT_SYS0_MEM_ARID_WIDTH,EXT_SYS0_MEM_ADDR_WIDTH)+0)*EXT_SYS0_MEM_AR_FIFO_DEPTH);
localparam   EXT_SYS0_MEM_R_PAYLOAD_WIDTH = (r_payload_width_fn(EXT_SYS0_MEM_RUSER_WIDTH,EXT_SYS0_MEM_ARID_WIDTH,EXT_SYS0_MEM_DATA_WIDTH)* EXT_SYS0_MEM_R_FIFO_DEPTH);

localparam   EXT_SYS1_MEM_ADDR_WIDTH    = 32;
localparam   EXT_SYS1_MEM_DATA_WIDTH    = EXT_SYS1_DATA_WIDTH;
localparam   EXT_SYS1_MEM_AWID_WIDTH    = EXT_SYS1_ID_WIDTH;
localparam   EXT_SYS1_MEM_ARID_WIDTH    = EXT_SYS1_ID_WIDTH;
localparam   EXT_SYS1_MEM_AWUSER_WIDTH  = 0;
localparam   EXT_SYS1_MEM_WUSER_WIDTH   = 0;
localparam   EXT_SYS1_MEM_BUSER_WIDTH   = 0;
localparam   EXT_SYS1_MEM_ARUSER_WIDTH  = 0;
localparam   EXT_SYS1_MEM_RUSER_WIDTH   = 0;

localparam   EXT_SYS1_MEM_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(EXT_SYS1_MEM_AWUSER_WIDTH,EXT_SYS1_MEM_AWID_WIDTH,EXT_SYS1_MEM_ADDR_WIDTH)+0)*EXT_SYS1_MEM_AW_FIFO_DEPTH); 
localparam   EXT_SYS1_MEM_W_PAYLOAD_WIDTH = ((w_payload_width_fn(EXT_SYS1_MEM_WUSER_WIDTH,EXT_SYS1_MEM_AWID_WIDTH,EXT_SYS1_MEM_DATA_WIDTH)+0)* EXT_SYS1_MEM_W_FIFO_DEPTH);
localparam   EXT_SYS1_MEM_B_PAYLOAD_WIDTH = (b_payload_width_fn(EXT_SYS1_MEM_BUSER_WIDTH,EXT_SYS1_MEM_AWID_WIDTH)* EXT_SYS1_MEM_B_FIFO_DEPTH); 
localparam   EXT_SYS1_MEM_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(EXT_SYS1_MEM_ARUSER_WIDTH,EXT_SYS1_MEM_ARID_WIDTH,EXT_SYS1_MEM_ADDR_WIDTH)+0)*EXT_SYS1_MEM_AR_FIFO_DEPTH);
localparam   EXT_SYS1_MEM_R_PAYLOAD_WIDTH = (r_payload_width_fn(EXT_SYS1_MEM_RUSER_WIDTH,EXT_SYS1_MEM_ARID_WIDTH,EXT_SYS1_MEM_DATA_WIDTH)* EXT_SYS1_MEM_R_FIFO_DEPTH);

localparam   SECENC_ADDR_WIDTH       = 32;
localparam   SECENC_DATA_WIDTH       = 32;
localparam   SECENC_AWID_WIDTH       = 1;
localparam   SECENC_ARID_WIDTH       = 1;
localparam   SECENC_AWUSER_WIDTH     = 0;
localparam   SECENC_WUSER_WIDTH      = 0;
localparam   SECENC_BUSER_WIDTH      = 1;
localparam   SECENC_ARUSER_WIDTH     = 0;
localparam   SECENC_RUSER_WIDTH      = 1;
localparam   SECENC_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(SECENC_AWUSER_WIDTH,SECENC_AWID_WIDTH,SECENC_ADDR_WIDTH)+0)*SECENC_AW_FIFO_DEPTH);
localparam   SECENC_W_PAYLOAD_WIDTH  = ((w_payload_width_fn(SECENC_WUSER_WIDTH,SECENC_AWID_WIDTH,SECENC_DATA_WIDTH)+0)* SECENC_W_FIFO_DEPTH);
localparam   SECENC_B_PAYLOAD_WIDTH  = (b_payload_width_fn(SECENC_BUSER_WIDTH,SECENC_AWID_WIDTH)* SECENC_B_FIFO_DEPTH);
localparam   SECENC_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(SECENC_ARUSER_WIDTH,SECENC_ARID_WIDTH,SECENC_ADDR_WIDTH)+0)*SECENC_AR_FIFO_DEPTH);
localparam   SECENC_R_PAYLOAD_WIDTH  = (r_payload_width_fn(SECENC_RUSER_WIDTH,SECENC_ARID_WIDTH,SECENC_DATA_WIDTH)* SECENC_R_FIFO_DEPTH);


 
localparam   FW_AXI_ADDR_WIDTH       = 32;
localparam   FW_AXI_DATA_WIDTH       = 32;
localparam   FW_AXI_AWID_WIDTH       = 10; 
localparam   FW_AXI_ARID_WIDTH       = 10; 
localparam   FW_AXI_AWUSER_WIDTH     = 10;  
localparam   FW_AXI_WUSER_WIDTH      = 0;  
localparam   FW_AXI_BUSER_WIDTH      = 1;
localparam   FW_AXI_ARUSER_WIDTH     = 10;  
localparam   FW_AXI_RUSER_WIDTH      = 1;  
localparam   FW_AXI_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(FW_AXI_AWUSER_WIDTH,FW_AXI_AWID_WIDTH,FW_AXI_ADDR_WIDTH)+0)*FW_AXI_AW_FIFO_DEPTH);
localparam   FW_AXI_W_PAYLOAD_WIDTH  = ((w_payload_width_fn(FW_AXI_WUSER_WIDTH,FW_AXI_AWID_WIDTH,FW_AXI_DATA_WIDTH)+0)* FW_AXI_W_FIFO_DEPTH);
localparam   FW_AXI_B_PAYLOAD_WIDTH  = (b_payload_width_fn(FW_AXI_BUSER_WIDTH,FW_AXI_AWID_WIDTH)* FW_AXI_B_FIFO_DEPTH);
localparam   FW_AXI_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(FW_AXI_ARUSER_WIDTH,FW_AXI_ARID_WIDTH,FW_AXI_ADDR_WIDTH)+0)*FW_AXI_AR_FIFO_DEPTH);
localparam   FW_AXI_R_PAYLOAD_WIDTH  = (r_payload_width_fn(FW_AXI_RUSER_WIDTH,FW_AXI_ARID_WIDTH,FW_AXI_DATA_WIDTH)* FW_AXI_R_FIFO_DEPTH);

localparam   DBG_ADDR_WIDTH       = 32;
localparam   DBG_DATA_WIDTH       = 64;
localparam   DBG_AWID_WIDTH       = 4; 
localparam   DBG_ARID_WIDTH       = 4;
localparam   DBG_AWUSER_WIDTH     = 10;
localparam   DBG_WUSER_WIDTH      = 0;
localparam   DBG_BUSER_WIDTH      = 1;
localparam   DBG_ARUSER_WIDTH     = 10;
localparam   DBG_RUSER_WIDTH      = 1;
localparam   DBG_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(DBG_AWUSER_WIDTH,DBG_AWID_WIDTH,DBG_ADDR_WIDTH)+0)*DBG_AW_FIFO_DEPTH);
localparam   DBG_W_PAYLOAD_WIDTH  = ((w_payload_width_fn(DBG_WUSER_WIDTH,DBG_AWID_WIDTH,DBG_DATA_WIDTH)+0)* DBG_W_FIFO_DEPTH);
localparam   DBG_B_PAYLOAD_WIDTH  = (b_payload_width_fn(DBG_BUSER_WIDTH,DBG_AWID_WIDTH)* DBG_B_FIFO_DEPTH);
localparam   DBG_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(DBG_ARUSER_WIDTH,DBG_ARID_WIDTH,DBG_ADDR_WIDTH)+0)*DBG_AR_FIFO_DEPTH);
localparam   DBG_R_PAYLOAD_WIDTH  = (r_payload_width_fn(DBG_RUSER_WIDTH,DBG_ARID_WIDTH,DBG_DATA_WIDTH)* DBG_R_FIFO_DEPTH);
  
localparam   STM_ADDR_WIDTH       = 32;
localparam   STM_DATA_WIDTH       = 64;
localparam   STM_AXI_ID_WIDTH     = 12;
localparam   STM_AWID_WIDTH       = STM_AXI_ID_WIDTH; 
localparam   STM_ARID_WIDTH       = STM_AXI_ID_WIDTH;
localparam   STM_AWUSER_WIDTH     = 10;
localparam   STM_WUSER_WIDTH      = 0;
localparam   STM_BUSER_WIDTH      = 0;
localparam   STM_ARUSER_WIDTH     = 10;
localparam   STM_RUSER_WIDTH      = 0;
localparam   STM_AW_PAYLOAD_WIDTH = ((aw_payload_width_fn(STM_AWUSER_WIDTH,STM_AWID_WIDTH,STM_ADDR_WIDTH)+0)*STM_AW_FIFO_DEPTH);
localparam   STM_W_PAYLOAD_WIDTH  = ((w_payload_width_fn(STM_WUSER_WIDTH,STM_AWID_WIDTH,STM_DATA_WIDTH)+0)* STM_W_FIFO_DEPTH);
localparam   STM_B_PAYLOAD_WIDTH  = (b_payload_width_fn(STM_BUSER_WIDTH,STM_AWID_WIDTH)* STM_B_FIFO_DEPTH);
localparam   STM_AR_PAYLOAD_WIDTH = ((ar_payload_width_fn(STM_ARUSER_WIDTH,STM_ARID_WIDTH,STM_ADDR_WIDTH)+0)*STM_AR_FIFO_DEPTH);
localparam   STM_R_PAYLOAD_WIDTH  = (r_payload_width_fn(STM_RUSER_WIDTH,STM_ARID_WIDTH,STM_DATA_WIDTH)* STM_R_FIFO_DEPTH);
  
localparam   QACTIVE_REFCLK_TOP_CNT = NUM_EXT_SYS*2+7;

localparam  [15:0] SEC_ENC_ROM_SIZE = 16'd128;
localparam  [15:0] SEC_ENC_RAM_SIZE = 16'd1024;

  function automatic integer payload_width_fn
    (
      input integer last_width,
      input integer data_width,
      input integer strb_width,
      input integer keep_width,
      input integer id_width,
      input integer dest_width,
      input integer user_width
    );
    begin : fn_payload_width_fn
      payload_width_fn = 
               ((last_width>0)?1:0) +
               data_width +
               strb_width +
               keep_width +
               id_width +
               dest_width +
               user_width +
               0;
    end
  endfunction

  function automatic integer aw_payload_width_fn
    (
      input integer awuser_width,
      input integer awid_width,
      input integer awaddr_width
    ); 
    begin : fn_aw_payload_width_fn
      aw_payload_width_fn =
               awuser_width +
               awid_width +
               awaddr_width +
               4 +            
               8 +            
               3 +            
               2 +            
               1 +            
               4 +            
               3 +            
               4 +            
               0;
    end
  endfunction

  function automatic integer w_payload_width_fn
    (
      input integer wuser_width,
      input integer wid_width,
      input integer wdata_width
    ); 
    begin : fn_w_payload_width_fn
      w_payload_width_fn =
               wuser_width +
               wdata_width +
               (wdata_width/8) + 
               1 +            
               0;
    end
  endfunction

  function automatic integer b_payload_width_fn
    (
      input integer buser_width,
      input integer bid_width
    ); 
    begin : fn_b_payload_width_fn
      b_payload_width_fn =
               buser_width +
               bid_width +
               2 +            
               0;
    end
  endfunction

  function automatic integer ar_payload_width_fn
    (
      input integer aruser_width,
      input integer arid_width,
      input integer araddr_width
    ); 
    begin : fn_ar_payload_width_fn
      ar_payload_width_fn =
               aruser_width +
               arid_width +
               araddr_width +
               4 +            
               8 +            
               3 +            
               2 +            
               1 +            
               4 +            
               3 +            
               4 +            
               0;
    end
  endfunction

  function automatic integer r_payload_width_fn
    (
      input integer ruser_width,
      input integer rid_width,
      input integer rdata_width
    ); 
    begin : fn_r_payload_width_fn
      r_payload_width_fn =
               ruser_width +
               rid_width +
               rdata_width +
               2 +            
               1 +            
               0;
    end
  endfunction



wire                             clkforce_st_refclk_force_st;
wire [7:0]                       refclk_ctrl_entrydelay;
  
wire                             s32k_counter_haltreqreq;
wire                             s32k_counter_haltreqack;
wire                             s32k_counter_restartreq;
wire                             s32k_counter_restartack;

wire                             refclk_counter_haltreqreq;
wire                             refclk_counter_haltreqack;
wire                             refclk_counter_restartreq;
wire                             refclk_counter_restartack;
      
wire                             fw2systop_dn_slvmustacceptreqn_async;
wire                             fw2systop_dn_slvcandenyreqn_async;
wire                             fw2systop_dn_slvacceptn_async;
wire                             fw2systop_dn_slvdeny_async;
wire                             fw2systop_dn_si_to_mi_wakeup_async;
wire                             fw2systop_dn_mi_to_si_wakeup_async;
wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_wr_ptr_async;
wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_rd_ptr_async;
wire [((A4S_PAYLOAD_WIDTH>0)?
             ((A4S_PAYLOAD_WIDTH*FW2SYSTOP_FIFO_DEPTH)-1):
              0):0]              fw2systop_dn_payld_async;
wire                             fw2systop_up_slvmustacceptreqn_async;
wire                             fw2systop_up_slvcandenyreqn_async;
wire                             fw2systop_up_slvacceptn_async;
wire                             fw2systop_up_slvdeny_async;
wire                             fw2systop_up_si_to_mi_wakeup_async;
wire                             fw2systop_up_mi_to_si_wakeup_async;
wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_wr_ptr_async;
wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_rd_ptr_async;
wire [((A4S_PAYLOAD_WIDTH>0)?
             ((A4S_PAYLOAD_WIDTH*FW2SYSTOP_FIFO_DEPTH)-1):
              0):0]               fw2systop_up_payld_async;

wire                             fw2dbgtop_dn_slvmustacceptreqn_async;
wire                             fw2dbgtop_dn_slvcandenyreqn_async;
wire                             fw2dbgtop_dn_slvacceptn_async;
wire                             fw2dbgtop_dn_slvdeny_async;
wire                             fw2dbgtop_dn_si_to_mi_wakeup_async;
wire                             fw2dbgtop_dn_mi_to_si_wakeup_async;
wire [FW2DBGTOP_FIFO_DEPTH-1:0]  fw2dbgtop_dn_wr_ptr_async;
wire [FW2DBGTOP_FIFO_DEPTH-1:0]  fw2dbgtop_dn_rd_ptr_async;
wire [((A4S_PAYLOAD_WIDTH>0)?
             ((A4S_PAYLOAD_WIDTH*FW2DBGTOP_FIFO_DEPTH)-1):
              0):0]              fw2dbgtop_dn_payld_async;
wire                             fw2dbgtop_up_slvmustacceptreqn_async;
wire                             fw2dbgtop_up_slvcandenyreqn_async;
wire                             fw2dbgtop_up_slvacceptn_async;
wire                             fw2dbgtop_up_slvdeny_async;
wire                             fw2dbgtop_up_si_to_mi_wakeup_async;
wire                             fw2dbgtop_up_mi_to_si_wakeup_async;
wire [FW2DBGTOP_FIFO_DEPTH-1:0]  fw2dbgtop_up_wr_ptr_async;
wire [FW2DBGTOP_FIFO_DEPTH-1:0]  fw2dbgtop_up_rd_ptr_async;
wire [((A4S_PAYLOAD_WIDTH>0)?
           ((A4S_PAYLOAD_WIDTH*FW2DBGTOP_FIFO_DEPTH)-1):
            0):0]                fw2dbgtop_up_payld_async;

            
wire [3:0]                       secenc_bsys_pwr_req_systop_pwr_req;
wire [4:0]                       secenc_bsys_pwr_st_systop_pwr_st;

wire                             secenc_bsys_pwr_req_dbgtop_pwr_req;
wire                             secenc_bsys_pwr_st_dbgtop_pwr_st;

wire  [7:0]                      aclk_ctrl_entrydelay;
wire  [7:0]                      ctrlclk_ctrl_entrydelay;
wire  [7:0]                      dbgclk_ctrl_entrydelay;
  
wire                             hostcntclkout_systop;
wire                             refclk_sleep_gated;  
wire                             refclk_int_gated;
wire                             refclk_systop;
wire                             refclk_dbgtop;
wire                             syspll_systop;
wire                             syspll_dbgtop;
wire                             cpupll_systop;
wire                             traceclk_in_dbgtop;
wire                             secenc_clk;

 assign         HOSTS32KCNTCLKOUT  = S32KCLK;
 
wire                             hostsysdbg_async_req;
wire [67:0]                      hostsysdbg_async_req_payload;
wire [32:0]                      hostsysdbg_async_resp_payload;
wire                             hostsysdbg_async_ack;

wire                             apb_async_req_eh0_mhu_esh_0;
wire [48:0]                      apb_async_req_payload_eh0_mhu_esh_0;
wire [32:0]                      apb_async_resp_payload_eh0_mhu_esh_0;
wire                             apb_async_ack_eh0_mhu_esh_0;
wire                             recawake_async_eh0_mhu_esh_0;
wire                             recwakeup_async_eh0_mhu_esh_0;
wire [MHU_ES0H0_NUM_CH-1:0]     edge_async_req_eh0_mhu_esh_0;
wire [MHU_ES0H0_NUM_CH-1:0]     edge_async_ack_eh0_mhu_esh_0;
                                
wire                             apb_async_req_eh0_mhu_hes_0;
wire [48:0]                      apb_async_req_payload_eh0_mhu_hes_0;
wire [32:0]                      apb_async_resp_payload_eh0_mhu_hes_0;
wire                             apb_async_ack_eh0_mhu_hes_0;
wire                             recawake_async_eh0_mhu_hes_0;
wire                             recwakeup_async_eh0_mhu_hes_0;
wire [MHU_HES00_NUM_CH-1:0]     edge_async_req_eh0_mhu_hes_0;
wire [MHU_HES00_NUM_CH-1:0]     edge_async_ack_eh0_mhu_hes_0;

  
wire                             apb_async_req_eh0_mhu_esh_1;
wire [48:0]                      apb_async_req_payload_eh0_mhu_esh_1;
wire [32:0]                      apb_async_resp_payload_eh0_mhu_esh_1;
wire                             apb_async_ack_eh0_mhu_esh_1;
wire                             recawake_async_eh0_mhu_esh_1;
wire                             recwakeup_async_eh0_mhu_esh_1;
wire [MHU_ES0H1_NUM_CH-1:0]     edge_async_req_eh0_mhu_esh_1;
wire [MHU_ES0H1_NUM_CH-1:0]     edge_async_ack_eh0_mhu_esh_1;
                                
wire                             apb_async_req_eh0_mhu_hes_1;
wire [48:0]                      apb_async_req_payload_eh0_mhu_hes_1;
wire [32:0]                      apb_async_resp_payload_eh0_mhu_hes_1;
wire                             apb_async_ack_eh0_mhu_hes_1;
wire                             recawake_async_eh0_mhu_hes_1;
wire                             recwakeup_async_eh0_mhu_hes_1;
wire [MHU_HES01_NUM_CH-1:0]     edge_async_req_eh0_mhu_hes_1;
wire [MHU_HES01_NUM_CH-1:0]     edge_async_ack_eh0_mhu_hes_1;

  
wire                             extsys0mhupwrreqactiveq_systop;
  
wire                                                   slvmustacceptreqn_async_eh0;
wire                                                   slvcandenyreqn_async_eh0;
wire                                                   slvacceptn_async_eh0;
wire                                                   slvdeny_async_eh0;
wire                                                   si_to_mi_wakeup_async_eh0;
wire                                                   mi_to_si_wakeup_async_eh0;
wire [EXT_SYS0_MEM_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_eh0;
wire [EXT_SYS0_MEM_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_eh0;
wire [EXT_SYS0_MEM_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_eh0;
wire [EXT_SYS0_MEM_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_eh0;
wire [EXT_SYS0_MEM_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_eh0;
wire [EXT_SYS0_MEM_W_PAYLOAD_WIDTH-1:0]  w_payld_async_eh0;
wire [EXT_SYS0_MEM_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_eh0;
wire [EXT_SYS0_MEM_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_eh0;
wire [EXT_SYS0_MEM_B_PAYLOAD_WIDTH-1:0]  b_payld_async_eh0;
wire [EXT_SYS0_MEM_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_eh0;
wire [EXT_SYS0_MEM_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_eh0;
wire [EXT_SYS0_MEM_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_eh0;
wire [EXT_SYS0_MEM_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_eh0;
wire [EXT_SYS0_MEM_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_eh0;
wire [EXT_SYS0_MEM_R_PAYLOAD_WIDTH-1:0]  r_payld_async_eh0;
  
wire [3:0]                       pulse_req_eh0_cti_out;
wire [3:0]                       pulse_ack_eh0_cti_out;
  
wire [3:0]                       pulse_ack_eh0_cti_in;
wire [3:0]                       pulse_req_eh0_cti_in;
                                   
wire [3:0]                       rd_pointer_gray_eh0;
wire                             flush_req_eh0;
wire                             sync_done_eh0;
wire                             syncreq_async_req_eh0;
wire                             flush_done_eh0;
wire                             sync_clear_eh0;
wire [3:0]                       wr_pointer_gray_eh0;
wire [245:0]                     atb_fwd_data_eh0;
wire                             syncreq_async_ack_eh0;
                                      
wire                             apb_async_req_eh0_extdbg;
wire [67:0]                      apb_async_req_payload_eh0_extdbg;
wire [32:0]                      apb_async_resp_payload_eh0_extdbg;
wire                             apb_async_ack_eh0_extdbg;

  
wire                             apb_async_req_eh0_dbg;
wire [67:0]                      apb_async_req_payload_eh0_dbg;
wire [32:0]                      apb_async_resp_payload_eh0_dbg;
wire                             apb_async_ack_eh0_dbg;
                                      
wire                             dpabort_pulse_req_eh0;
wire                             dpabort_pulse_ack_eh0;

wire                             qreqn_eh0_refclk;
wire                             qacceptn_eh0_refclk;
wire                             qdeny_eh0_refclk;
wire                             qactive_eh0_refclk;

wire                             apb_async_req_eh1_mhu_esh_0;
wire [48:0]                      apb_async_req_payload_eh1_mhu_esh_0;
wire [32:0]                      apb_async_resp_payload_eh1_mhu_esh_0;
wire                             apb_async_ack_eh1_mhu_esh_0;
wire                             recawake_async_eh1_mhu_esh_0;
wire                             recwakeup_async_eh1_mhu_esh_0;
wire [MHU_ES1H0_NUM_CH-1:0]     edge_async_req_eh1_mhu_esh_0;
wire [MHU_ES1H0_NUM_CH-1:0]     edge_async_ack_eh1_mhu_esh_0;
                                
wire                             apb_async_req_eh1_mhu_hes_0;
wire [48:0]                      apb_async_req_payload_eh1_mhu_hes_0;
wire [32:0]                      apb_async_resp_payload_eh1_mhu_hes_0;
wire                             apb_async_ack_eh1_mhu_hes_0;
wire                             recawake_async_eh1_mhu_hes_0;
wire                             recwakeup_async_eh1_mhu_hes_0;
wire [MHU_HES10_NUM_CH-1:0]     edge_async_req_eh1_mhu_hes_0;
wire [MHU_HES10_NUM_CH-1:0]     edge_async_ack_eh1_mhu_hes_0;

  
wire                             apb_async_req_eh1_mhu_esh_1;
wire [48:0]                      apb_async_req_payload_eh1_mhu_esh_1;
wire [32:0]                      apb_async_resp_payload_eh1_mhu_esh_1;
wire                             apb_async_ack_eh1_mhu_esh_1;
wire                             recawake_async_eh1_mhu_esh_1;
wire                             recwakeup_async_eh1_mhu_esh_1;
wire [MHU_ES1H1_NUM_CH-1:0]     edge_async_req_eh1_mhu_esh_1;
wire [MHU_ES1H1_NUM_CH-1:0]     edge_async_ack_eh1_mhu_esh_1;
                                
wire                             apb_async_req_eh1_mhu_hes_1;
wire [48:0]                      apb_async_req_payload_eh1_mhu_hes_1;
wire [32:0]                      apb_async_resp_payload_eh1_mhu_hes_1;
wire                             apb_async_ack_eh1_mhu_hes_1;
wire                             recawake_async_eh1_mhu_hes_1;
wire                             recwakeup_async_eh1_mhu_hes_1;
wire [MHU_HES11_NUM_CH-1:0]     edge_async_req_eh1_mhu_hes_1;
wire [MHU_HES11_NUM_CH-1:0]     edge_async_ack_eh1_mhu_hes_1;

  
wire                             extsys1mhupwrreqactiveq_systop;
  
wire                                                   slvmustacceptreqn_async_eh1;
wire                                                   slvcandenyreqn_async_eh1;
wire                                                   slvacceptn_async_eh1;
wire                                                   slvdeny_async_eh1;
wire                                                   si_to_mi_wakeup_async_eh1;
wire                                                   mi_to_si_wakeup_async_eh1;
wire [EXT_SYS1_MEM_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_eh1;
wire [EXT_SYS1_MEM_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_eh1;
wire [EXT_SYS1_MEM_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_eh1;
wire [EXT_SYS1_MEM_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_eh1;
wire [EXT_SYS1_MEM_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_eh1;
wire [EXT_SYS1_MEM_W_PAYLOAD_WIDTH-1:0]  w_payld_async_eh1;
wire [EXT_SYS1_MEM_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_eh1;
wire [EXT_SYS1_MEM_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_eh1;
wire [EXT_SYS1_MEM_B_PAYLOAD_WIDTH-1:0]  b_payld_async_eh1;
wire [EXT_SYS1_MEM_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_eh1;
wire [EXT_SYS1_MEM_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_eh1;
wire [EXT_SYS1_MEM_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_eh1;
wire [EXT_SYS1_MEM_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_eh1;
wire [EXT_SYS1_MEM_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_eh1;
wire [EXT_SYS1_MEM_R_PAYLOAD_WIDTH-1:0]  r_payld_async_eh1;
  
wire [3:0]                       pulse_req_eh1_cti_out;
wire [3:0]                       pulse_ack_eh1_cti_out;
  
wire [3:0]                       pulse_ack_eh1_cti_in;
wire [3:0]                       pulse_req_eh1_cti_in;
                                   
wire [3:0]                       rd_pointer_gray_eh1;
wire                             flush_req_eh1;
wire                             sync_done_eh1;
wire                             syncreq_async_req_eh1;
wire                             flush_done_eh1;
wire                             sync_clear_eh1;
wire [3:0]                       wr_pointer_gray_eh1;
wire [245:0]                     atb_fwd_data_eh1;
wire                             syncreq_async_ack_eh1;
                                      
wire                             apb_async_req_eh1_extdbg;
wire [67:0]                      apb_async_req_payload_eh1_extdbg;
wire [32:0]                      apb_async_resp_payload_eh1_extdbg;
wire                             apb_async_ack_eh1_extdbg;

  
wire                             apb_async_req_eh1_dbg;
wire [67:0]                      apb_async_req_payload_eh1_dbg;
wire [32:0]                      apb_async_resp_payload_eh1_dbg;
wire                             apb_async_ack_eh1_dbg;
                                      
wire                             dpabort_pulse_req_eh1;
wire                             dpabort_pulse_ack_eh1;

wire                             qreqn_eh1_refclk;
wire                             qacceptn_eh1_refclk;
wire                             qdeny_eh1_refclk;
wire                             qactive_eh1_refclk;


wire                             extdbg_async_req;
wire [67:0]                      extdbg_async_req_payload;
wire [32:0]                      extdbg_async_resp_payload;
wire                             extdbg_async_ack;

wire                             ext_sys0_rst_ctrl_rst_req;
wire [1:0]                       ext_sys0_rst_st_rst_ack;
wire                             ext_sys1_rst_ctrl_rst_req;
wire [1:0]                       ext_sys1_rst_st_rst_ack;


wire                             aonperiph_async_req;
wire [67:0]                      aonperiph_async_req_payload;
wire [32:0]                      aonperiph_async_resp_payload;
wire                             aonperiph_async_ack;

wire                             bootreg_async_req;
wire [61:0]                      bootreg_async_req_payload;
wire [32:0]                      bootreg_async_resp_payload;
wire                             bootreg_async_ack;


wire                             seporesetn;
  
  
wire                               slvmustacceptreqn_async_secenc;
wire                               slvcandenyreqn_async_secenc;
wire                               slvacceptn_async_secenc;
wire                               slvdeny_async_secenc;
wire                               si_to_mi_wakeup_async_secenc;
wire                               mi_to_si_wakeup_async_secenc;
wire [SECENC_AW_FIFO_DEPTH-1:0]    aw_wr_ptr_async_secenc;
wire [SECENC_AW_FIFO_DEPTH-1:0]    aw_rd_ptr_async_secenc;
wire [SECENC_AW_PAYLOAD_WIDTH-1:0] aw_payld_async_secenc;
wire [SECENC_W_FIFO_DEPTH-1:0]     w_wr_ptr_async_secenc;
wire [SECENC_W_FIFO_DEPTH-1:0]     w_rd_ptr_async_secenc;
wire [SECENC_W_PAYLOAD_WIDTH-1:0]  w_payld_async_secenc;
wire [SECENC_B_FIFO_DEPTH-1:0]     b_wr_ptr_async_secenc;
wire [SECENC_B_FIFO_DEPTH-1:0]     b_rd_ptr_async_secenc;
wire [SECENC_B_PAYLOAD_WIDTH-1:0]  b_payld_async_secenc;
wire [SECENC_AR_FIFO_DEPTH-1:0]    ar_wr_ptr_async_secenc;
wire [SECENC_AR_FIFO_DEPTH-1:0]    ar_rd_ptr_async_secenc;
wire [SECENC_AR_PAYLOAD_WIDTH-1:0] ar_payld_async_secenc;
wire [SECENC_R_FIFO_DEPTH-1:0]     r_wr_ptr_async_secenc;
wire [SECENC_R_FIFO_DEPTH-1:0]     r_rd_ptr_async_secenc;
wire [SECENC_R_PAYLOAD_WIDTH-1:0]  r_payld_async_secenc;

wire                          apb_async_req_seh0_mhu;
wire [48:0]                   apb_async_req_payload_seh0_mhu;
wire [32:0]                   apb_async_resp_payload_seh0_mhu;
wire                          apb_async_ack_seh0_mhu;
wire                          recawake_async_seh0_mhu;
wire                          recwakeup_async_seh0_mhu;
wire [MHU_SEH0_NUM_CH-1:0]    edge_async_req_seh0_mhu;
wire [MHU_SEH0_NUM_CH-1:0]    edge_async_ack_seh0_mhu;
                                                 
wire                          apb_async_req_hse0_mhu;
wire [48:0]                   apb_async_req_payload_hse0_mhu;
wire [32:0]                   apb_async_resp_payload_hse0_mhu;
wire                          apb_async_ack_hse0_mhu;
wire                          recawake_async_hse0_mhu;
wire                          recwakeup_async_hse0_mhu;
wire [MHU_HSE0_NUM_CH-1:0]    edge_async_req_hse0_mhu;
wire [MHU_HSE0_NUM_CH-1:0]    edge_async_ack_hse0_mhu;
                                                 
wire                          apb_async_req_seh1_mhu;
wire [48:0]                   apb_async_req_payload_seh1_mhu;
wire [32:0]                   apb_async_resp_payload_seh1_mhu;
wire                          apb_async_ack_seh1_mhu;
wire                          recawake_async_seh1_mhu;
wire                          recwakeup_async_seh1_mhu;
wire [MHU_SEH1_NUM_CH-1:0]    edge_async_req_seh1_mhu;
wire [MHU_SEH1_NUM_CH-1:0]    edge_async_ack_seh1_mhu;
                                                 
wire                          apb_async_req_hse1_mhu;
wire [48:0]                   apb_async_req_payload_hse1_mhu;
wire [32:0]                   apb_async_resp_payload_hse1_mhu;
wire                          apb_async_ack_hse1_mhu;
wire                          recawake_async_hse1_mhu;
wire                          recwakeup_async_hse1_mhu;
wire [MHU_HSE1_NUM_CH-1:0]    edge_async_req_hse1_mhu;
wire [MHU_HSE1_NUM_CH-1:0]    edge_async_ack_hse1_mhu;

wire                          mhu_es0se0_apb_async_req;
wire                [48:0]    mhu_es0se0_apb_async_req_payload;
wire                [32:0]    mhu_es0se0_apb_async_resp_payload;
wire                          mhu_es0se0_apb_async_ack;
wire [MHU_ES0SE0_NUM_CH-1:0]  mhu_es0se0_edge_async_req;
wire [MHU_ES0SE0_NUM_CH-1:0]  mhu_es0se0_edge_async_ack;
wire                          mhu_es0se0_recawake_async;
wire                          mhu_es0se0_recwakeup_async;

wire                          mhu_sees00_apb_async_req;
wire                [48:0]    mhu_sees00_apb_async_req_payload;
wire                [32:0]    mhu_sees00_apb_async_resp_payload;
wire                          mhu_sees00_apb_async_ack;
wire [MHU_SEES00_NUM_CH-1:0]  mhu_sees00_edge_async_req;
wire [MHU_SEES00_NUM_CH-1:0]  mhu_sees00_edge_async_ack;
wire                          mhu_sees00_recawake_async;
wire                          mhu_sees00_recwakeup_async;

  
wire                          mhu_es0se1_apb_async_req;
wire                [48:0]    mhu_es0se1_apb_async_req_payload;
wire                [32:0]    mhu_es0se1_apb_async_resp_payload;
wire                          mhu_es0se1_apb_async_ack;
wire [MHU_ES0SE1_NUM_CH-1:0]  mhu_es0se1_edge_async_req;
wire [MHU_ES0SE1_NUM_CH-1:0]  mhu_es0se1_edge_async_ack;
wire                          mhu_es0se1_recawake_async;
wire                          mhu_es0se1_recwakeup_async;

wire                          mhu_sees01_apb_async_req;
wire                [48:0]    mhu_sees01_apb_async_req_payload;
wire                [32:0]    mhu_sees01_apb_async_resp_payload;
wire                          mhu_sees01_apb_async_ack;
wire [MHU_SEES01_NUM_CH-1:0]  mhu_sees01_edge_async_req;
wire [MHU_SEES01_NUM_CH-1:0]  mhu_sees01_edge_async_ack;
wire                          mhu_sees01_recawake_async;
wire                          mhu_sees01_recwakeup_async;
  wire                          mhu_es1se0_apb_async_req;
wire                [48:0]    mhu_es1se0_apb_async_req_payload;
wire                [32:0]    mhu_es1se0_apb_async_resp_payload;
wire                          mhu_es1se0_apb_async_ack;
wire [MHU_ES1SE0_NUM_CH-1:0]  mhu_es1se0_edge_async_req;
wire [MHU_ES1SE0_NUM_CH-1:0]  mhu_es1se0_edge_async_ack;
wire                          mhu_es1se0_recawake_async;
wire                          mhu_es1se0_recwakeup_async;

wire                          mhu_sees10_apb_async_req;
wire                [48:0]    mhu_sees10_apb_async_req_payload;
wire                [32:0]    mhu_sees10_apb_async_resp_payload;
wire                          mhu_sees10_apb_async_ack;
wire [MHU_SEES10_NUM_CH-1:0]  mhu_sees10_edge_async_req;
wire [MHU_SEES10_NUM_CH-1:0]  mhu_sees10_edge_async_ack;
wire                          mhu_sees10_recawake_async;
wire                          mhu_sees10_recwakeup_async;

  
wire                          mhu_es1se1_apb_async_req;
wire                [48:0]    mhu_es1se1_apb_async_req_payload;
wire                [32:0]    mhu_es1se1_apb_async_resp_payload;
wire                          mhu_es1se1_apb_async_ack;
wire [MHU_ES1SE1_NUM_CH-1:0]  mhu_es1se1_edge_async_req;
wire [MHU_ES1SE1_NUM_CH-1:0]  mhu_es1se1_edge_async_ack;
wire                          mhu_es1se1_recawake_async;
wire                          mhu_es1se1_recwakeup_async;

wire                          mhu_sees11_apb_async_req;
wire                [48:0]    mhu_sees11_apb_async_req_payload;
wire                [32:0]    mhu_sees11_apb_async_resp_payload;
wire                          mhu_sees11_apb_async_ack;
wire [MHU_SEES11_NUM_CH-1:0]  mhu_sees11_edge_async_req;
wire [MHU_SEES11_NUM_CH-1:0]  mhu_sees11_edge_async_ack;
wire                          mhu_sees11_recawake_async;
wire                          mhu_sees11_recwakeup_async;
    
wire                          apb_async_req_secenc_dbg;
wire [48:0]                   apb_async_req_payload_secenc_dbg;
wire [32:0]                   apb_async_resp_payload_secenc_dbg;
wire                          apb_async_ack_secenc_dbg;

wire [3:0]                    cti_cha_to_secenc_pulse_req;
wire [3:0]                    cti_cha_to_secenc_pulse_ack;
wire [3:0]                    cti_secenc_to_cha_pulse_ack;
wire [3:0]                    cti_secenc_to_cha_pulse_req;
  
wire                          dp_abort_secenc_pulse_req;
wire                          dp_abort_secenc_pulse_ack;
  
wire                          qreqn_secenc_dbg_pwr;
wire                          qacceptn_secenc_dbg_pwr;
wire                          qdeny_secenc_dbg_pwr;
wire                          qactive_secenc_dbg_pwr;
  
wire                          secenc_divclk;
wire                          secenc_hintclk;
wire                          secenc_s32kclk;
wire                          secenc_poresetn;
wire                          secenc_warmresetn;
wire                          secenc_cpuwait;
  
wire                          secenc_soc_wd_irq;
wire                          secenc_uart_irq;
wire                          secenc_ppu_irq;
wire                          secenc_co_irq;  

  
wire                          secenc_mhu2r_cirq;
wire                          secenc_mhu2s_cirq;
wire                          secenc_mhu3r_cirq;
wire                          secenc_mhu3s_cirq;
    
wire                          secenc_mhu4r_cirq;
wire                          secenc_mhu4s_cirq;
wire                          secenc_mhu5r_cirq;
wire                          secenc_mhu5s_cirq;
  wire                          secenc_host_fwt_irq_ss;
wire                          secenc_int_rtt_irq_ss;
wire                          secenc_swd_ws1_irq_ss;
  
wire                          apb_async_req_secenc_aon;
wire [55:0]                   apb_async_req_payload_secenc_aon;
wire [32:0]                   apb_async_resp_payload_secenc_aon;
wire                          apb_async_ack_secenc_aon;

wire                          apb_async_req_secenc_socwd;
wire [47:0]                   apb_async_req_payload_secenc_socwd;
wire [32:0]                   apb_async_resp_payload_secenc_socwd;
wire                          apb_async_ack_secenc_socwd;

wire                          secenc_mhu0_qreqn;
wire                          secenc_mhu0_qacceptn;
wire                          secenc_mhu0_qdeny;
wire                          secenc_mhu1_qreqn;
wire                          secenc_mhu1_qacceptn;
wire                          secenc_mhu1_qdeny;
   
wire                          secenc_mhu2_qreqn;
wire                          secenc_mhu2_qacceptn;
wire                          secenc_mhu2_qdeny;
  wire                          secenc_mhu3_qreqn;
wire                          secenc_mhu3_qacceptn;
wire                          secenc_mhu3_qdeny;
     
wire                          secenc_mhu4_qreqn;
wire                          secenc_mhu4_qacceptn;
wire                          secenc_mhu4_qdeny;
  wire                          secenc_mhu5_qreqn;
wire                          secenc_mhu5_qacceptn;
wire                          secenc_mhu5_qdeny;
  wire                          secenc_cti_qreqn;
wire                          secenc_cti_qacceptn;
wire                          secenc_cti_qdeny;
wire                          secenc_cti_qactive;
wire                          secenc_cm0_qreqn;
wire                          secenc_cm0_qacceptn;
wire                          secenc_cm0_qdeny;
wire                          secenc_cm0_qactive;
wire                          secenc_axib_qreqn;
wire                          secenc_axib_qacceptn;
wire                          secenc_axib_qdeny;
wire                          secenc_axib_qactive;
wire                          secenc_socwd_adb_qreqn;
wire                          secenc_socwd_adb_qacceptn;
wire                          secenc_socwd_adb_qdeny;
wire                          secenc_socwd_adb_qactive;
wire                          secenc_aon_adb_qreqn;
wire                          secenc_aon_adb_qacceptn;
wire                          secenc_aon_adb_qdeny;
wire                          secenc_aon_adb_qactive;

wire                          secenc_m0_halted;
wire [7:0]                    secenc_entry_delay;
wire                          secenc_clkforce;

wire   [CAAON2CA_WIDTH-1:0]   secenc_caaon2ca;
wire   [CA2CAAON_WIDTH-1:0]   secenc_ca2caaon;

wire                          secenc_cae;
wire                          secenc_ca_err_msk;
  
wire                          secenc_wdog_rst_req;
wire                          secenc_soc_wdog_rst_req;
wire                          secenc_sw_rst_req;
wire                          soc_rst_req;
wire                          secenc_cae_rst_req;
wire [4:0]                    soc_rst_syn;
wire [2:0]                    se_rst_syn;
wire [3:0]                    host_rst_syn;
wire                          host_rst_req;
wire [1:0]                    host_rst_ack;
wire                          hostcpu_cpuwait;
wire [5:0]                    secenc_bsys_pwr_req;
wire                          secenc_bsys_pwr_req_refclk;
wire [5:0]                    secenc_bsys_pwr_st;
    
wire [63:0]                   secenc_shared_interrupts;
wire [63:0]                   secenc_extirq;
  
wire                          fwtamp_intr;
wire                          interrupt_router_tamper_interrupt;
wire                          secure_wdog_intr_second;
wire                          unused_interrupts;

wire [127:0]                  scb_secenc;
wire                          unused_scb_secenc;


wire                          dbgen_secencauth;
wire                          niden_secencauth;

wire                          chen_secencauth;
wire                          chen_tpiuauth;
wire                          chen_counterauth;
wire                          chen_hostauth;
  
wire                          ap_en_hostextauth;
wire                          ap_secure_en_hostextauth;
  
wire                          dbgen_dpauth;
wire                          niden_dpauth;
wire                          spiden_dpauth;
wire                          spniden_dpauth;
                                
wire                          dbgen_comauth;
wire                          niden_comauth;
                                
wire                          dbgen_tpiuauth;
wire                          niden_tpiuauth;
wire                          spiden_tpiuauth;
                                
wire                          dbgen_counterauth;
wire                          niden_counterauth;
                                
wire                          dbgen_niden_hostextauth;
wire                          spiden_spniden_hostextauth;
                                
wire                          dbgen_hostaxiauth;
wire                          niden_hostaxiauth;
wire                          spiden_hostaxiauth;
wire                          spniden_hostaxiauth;
                                
wire                          dbgen_hostauth;
wire                          niden_hostauth;
wire                          spiden_hostauth;
wire                          spniden_hostauth;
  
wire [3:0]                    host_cpu_dbgen;
wire [3:0]                    host_cpu_niden;
wire [3:0]                    host_cpu_spiden;
wire [3:0]                    host_cpu_spniden;
  
wire                          ppu_dbgen;
  
wire                          host_fctrl_bypass;
wire                          secenc_fctrl_bypass;

wire                          acg_dp_dbgen;
wire                          acg_hostext_dbgen;

wire                           acg_extsys0_dbgen;
wire                           extsys0_cpuwait_wen;
wire                           acg_extsys1_dbgen;
wire                           extsys1_cpuwait_wen;

wire                           host_cpuwait_wen;

wire                           secenc_calc;
wire                           debug_calc;

wire                           psel_ehx0_extdbg;
wire                           penable_ehx0_extdbg;
wire [31:0]                    paddr_ehx0_extdbg;
wire                           pwrite_ehx0_extdbg;
wire [31:0]                    pwdata_ehx0_extdbg;
wire [2:0]                     pprot_ehx0_extdbg;
wire [31:0]                    prdata_ehx0_extdbg;
wire                           pready_ehx0_extdbg;
wire                           pwakeup_ehx0_extdbg;
wire                           pslverr_ehx0_extdbg;

wire                           psel_ehx1_extdbg;
wire                           penable_ehx1_extdbg;
wire [31:0]                    paddr_ehx1_extdbg;
wire                           pwrite_ehx1_extdbg;
wire [31:0]                    pwdata_ehx1_extdbg;
wire [2:0]                     pprot_ehx1_extdbg;
wire [31:0]                    prdata_ehx1_extdbg;
wire                           pready_ehx1_extdbg;
wire                           pwakeup_ehx1_extdbg;
wire                           pslverr_ehx1_extdbg;


wire                           sdc600_ext_rempua;
wire                           sdc600_ext_rempur;
wire                           sdc600_ext_remrr;


wire                           dprom_cdbgpwrupreq;
wire                           dprom_cdbgpwrupack;



wire                           dprom_csyspwrupreq;
wire                           dprom_cdbgrstreq;
wire                           dprom_cdbgrstack;
wire                           dprom_csysrstreq;
wire                           dprom_csysrstack;
  
wire                           pwrdbg_pwrqreqn_i;
wire                           pwrdbg_pwrqacceptn_o;
wire                           pwrdbg_pwrqdeny_o;
wire                           pwrdbg_pwrqactive_o;
wire                           pwrdbg_pwrdwnresp_i;

wire                           dpslv_cdbgpwrupreq;
wire                           dpslv_cdbgpwrupack;
wire                           dpslv_csyspwrupreq;
wire                           dpslv_csyspwrupack;
wire                           dpslv_cdbgrstreq;
wire                           dpslv_cdbgrstack;
  
  
wire                           dp2hostdbg_pwrdbg_pwrqreqn;
wire                           dp2hostdbg_pwrdbg_pwrqacceptn;
wire                           dp2hostdbg_pwrdbg_pwrqdeny;
wire                           dp2hostdbg_pwrdbg_pwrqactive;
wire                           dp2hostdbg_pwrdbg_pwrdwnresp;
wire                           dp2hostdbg_apb_async_req;
wire [67:0]                    dp2hostdbg_apb_async_req_payload;
wire [32:0]                    dp2hostdbg_apb_async_resp_payload;
wire                           dp2hostdbg_apb_async_ack;
  
  
wire                           hostcpu_async_req;
wire [67:0]                    hostcpu_async_req_payload;
wire [32:0]                    hostcpu_async_resp_payload;
wire                           hostcpu_async_ack;
  
  
wire [6*41-1 : 0]              hostcpu_atb_fwd_data;
wire [3:0]                     hostcpu_wr_pointer_gray;
wire [3:0]                     hostcpu_rd_pointer_gray;
wire                           hostcpu_flush_req;
wire                           hostcpu_flush_done;
wire                           hostcpu_sync_clear;
wire                           hostcpu_sync_done;
wire                           hostcpu_syncreq_async_req;
wire                           hostcpu_syncreq_async_ack;
 
wire                           u_soc_cti_event_out_6_to_u_dp_eventstat;

wire                           aondbgclk;
wire                           aondbgclk_en;
wire [6:0]           aondbgclk_qreqn;
wire [6:0]           aondbgclk_qacceptn;
wire [6:0]           aondbgclk_qdeny;
wire [6:0]           aondbgclk_qactive;

wire [14:0]    aondbgclk_qactive_only;

wire                            qreqn_aondbg_sleep_gated;
wire                            qacceptn_aondbg_sleep_gated;
wire                            qdeny_aondbg_sleep_gated;
wire                            qactive_aondbg_sleep_gated;
    
wire                            debug_axis_slvmustacceptreqn_async;
wire                            debug_axis_slvcandenyreqn_async;
wire                            debug_axis_slvacceptn_async;
wire                            debug_axis_slvdeny_async;

wire                            debug_axis_si_to_mi_wakeup_async;
wire                            debug_axis_mi_to_si_wakeup_async;

wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_wr_ptr_async;
wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_rd_ptr_async;
wire [DBG_AW_PAYLOAD_WIDTH-1:0] debug_axis_aw_payld_async;

wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_wr_ptr_async;
wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_rd_ptr_async;
wire [DBG_W_PAYLOAD_WIDTH-1:0]  debug_axis_w_payld_async;
                                       
wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_wr_ptr_async;
wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_rd_ptr_async;
wire [DBG_B_PAYLOAD_WIDTH-1:0]  debug_axis_b_payld_async;

wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_wr_ptr_async;
wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_rd_ptr_async;
wire [DBG_AR_PAYLOAD_WIDTH-1:0] debug_axis_ar_payld_async;

wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_wr_ptr_async;
wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_rd_ptr_async;
wire [DBG_R_PAYLOAD_WIDTH-1:0]  debug_axis_r_payld_async;


wire                            stm_slvmustacceptreqn_async;
wire                            stm_slvcandenyreqn_async;
wire                            stm_slvacceptn_async;
wire                            stm_slvdeny_async;
    
wire                            stm_si_to_mi_wakeup_async;
wire                            stm_mi_to_si_wakeup_async;

wire [STM_AW_FIFO_DEPTH-1:0]    stm_aw_wr_ptr_async;
wire [STM_AW_FIFO_DEPTH-1:0]    stm_aw_rd_ptr_async;
wire [STM_AW_PAYLOAD_WIDTH-1:0] stm_aw_payld_async;

wire [ STM_W_FIFO_DEPTH-1:0]    stm_w_wr_ptr_async;
wire [ STM_W_FIFO_DEPTH-1:0]    stm_w_rd_ptr_async;
wire [STM_W_PAYLOAD_WIDTH-1:0]  stm_w_payld_async;

wire [ STM_B_FIFO_DEPTH-1:0]    stm_b_wr_ptr_async;
wire [ STM_B_FIFO_DEPTH-1:0]    stm_b_rd_ptr_async;
wire [STM_B_PAYLOAD_WIDTH-1:0]  stm_b_payld_async;

wire [STM_AR_FIFO_DEPTH-1:0]    stm_ar_wr_ptr_async;
wire [STM_AR_FIFO_DEPTH-1:0]    stm_ar_rd_ptr_async;
wire [STM_AR_PAYLOAD_WIDTH-1:0] stm_ar_payld_async;

wire [ STM_R_FIFO_DEPTH-1:0]    stm_r_wr_ptr_async;
wire [ STM_R_FIFO_DEPTH-1:0]    stm_r_rd_ptr_async;
wire [STM_R_PAYLOAD_WIDTH-1:0]  stm_r_payld_async;
  
wire [3:0]                      hostcpuctichin_pulse_req;
wire [3:0]                      hostcpuctichin_pulse_ack;
              
wire [3:0]                      hostcpuctichout_pulse_req;
wire [3:0]                      hostcpuctichout_pulse_ack;
    
    
wire [2+2*NUM_EXT_SYS-1:0]      qactive_clkctrl_refclk;

wire [NUM_EXT_SYS-1:0]          qreqn_extsys_systopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qacceptn_extsys_systopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qdeny_extsys_systopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qactive_extsys_systopq_rstctrl;
 
wire [NUM_EXT_SYS-1:0]          qreqn_extsys_dbgtopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qacceptn_extsys_dbgtopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qdeny_extsys_dbgtopq_rstctrl;
wire [NUM_EXT_SYS-1:0]          qactive_extsys_dbgtopq_rstctrl;
  
wire                            qreqn_secenc_systopq_rstctrl;
wire                            qacceptn_secenc_systopq_rstctrl;
wire                            qdeny_secenc_systopq_rstctrl;
wire                            qactive_secenc_systopq_rstctrl;
 
wire                            qreqn_secenc_dbgtopq_rstctrl;
wire                            qacceptn_secenc_dbgtopq_rstctrl;
wire                            qdeny_secenc_dbgtopq_rstctrl;
wire                            qactive_secenc_dbgtopq_rstctrl;
  
wire [QACTIVE_REFCLK_TOP_CNT-1:0]  qactive_refclk_int_gated;
wire                               qactive_refclk_systop;
wire                               qreqn_secenc_systopq;
wire                               qacceptn_secenc_systopq;
wire                               qdeny_secenc_systopq;
wire                               qactive_secenc_systopq;
 
wire                               qreqn_secenc_dbgtopq;
wire                               qacceptn_secenc_dbgtopq;
wire                               qdeny_secenc_dbgtopq;
wire                               qactive_secenc_dbgtopq;
 
wire [NUM_EXT_SYS-1:0]          qreqn_extsys_systopq_ppu;
wire [NUM_EXT_SYS-1:0]          qacceptn_extsys_systopq_ppu;
wire [NUM_EXT_SYS-1:0]          qdeny_extsys_systopq_ppu;
wire [NUM_EXT_SYS-1:0]          qactive_extsys_systopq_ppu;
 
wire [NUM_EXT_SYS-1:0]          qreqn_extsys_dbgtopq_ppu;
wire [NUM_EXT_SYS-1:0]          qacceptn_extsys_dbgtopq_ppu;
wire [NUM_EXT_SYS-1:0]          qdeny_extsys_dbgtopq_ppu;
wire [NUM_EXT_SYS-1:0]          qactive_extsys_dbgtopq_ppu;
 
  
wire                            qreqn_secenc_systopq_ppu;
wire                            qacceptn_secenc_systopq_ppu;
wire                            qdeny_secenc_systopq_ppu;
wire                            qactive_secenc_systopq_ppu;
 
wire                            qreqn_secenc_dbgtopq_ppu;
wire                            qacceptn_secenc_dbgtopq_ppu;
wire                            qdeny_secenc_dbgtopq_ppu;
wire                            qactive_secenc_dbgtopq_ppu;
  

wire [SYS_EGRESS_2_DBG-1:0]     qreqn_systop_egress_dbgtop;
wire [SYS_EGRESS_2_DBG-1:0]     qacceptn_systop_egress_dbgtop;
wire [SYS_EGRESS_2_DBG-1:0]     qdeny_systop_egress_dbgtop;
wire [SYS_EGRESS_2_DBG-1:0]     qactive_systop_egress_dbgtop;
  
wire [SYS_INGRESS_2_DBG-1:0]    qreqn_systop_ingress_dbgtop;
wire [SYS_INGRESS_2_DBG-1:0]    qacceptn_systop_ingress_dbgtop;
wire [SYS_INGRESS_2_DBG-1:0]    qdeny_systop_ingress_dbgtop;
wire [SYS_INGRESS_2_DBG-1:0]    qactive_systop_ingress_dbgtop;

wire [CLUS_INGRESS_2_DBG-1:0]   qreqn_clustop_ingress_dbgtop;
wire [CLUS_INGRESS_2_DBG-1:0]   qacceptn_clustop_ingress_dbgtop;
wire [CLUS_INGRESS_2_DBG-1:0]   qdeny_clustop_ingress_dbgtop;
wire [CLUS_INGRESS_2_DBG-1:0]   qactive_clustop_ingress_dbgtop;

wire [1:0]                      qreqn_clustop_egress_dbgtop;
wire [1:0]                      qacceptn_clustop_egress_dbgtop;
wire [1:0]                      qdeny_clustop_egress_dbgtop;
wire [1:0]                      qactive_clustop_egress_dbgtop;

wire                            clustop_dependency_qreqn;
wire                            clustop_dependency_qacceptn;
wire                            clustop_dependency_qdeny;
wire                            clustop_dependency_qactive;
  
wire                            qreqn_clustop_ingress_comb0_dbgtop;
wire                            qacceptn_clustop_ingress_comb0_dbgtop;
wire                            qdeny_clustop_ingress_comb0_dbgtop;
wire                            qactive_clustop_ingress_comb0_dbgtop;
     
wire                            qreqn_clustop_ingress_comb1_dbgtop;
wire                            qacceptn_clustop_ingress_comb1_dbgtop;
wire                            qdeny_clustop_ingress_comb1_dbgtop;
wire                            qactive_clustop_ingress_comb1_dbgtop;

wire                            qreqn_clustop_egress_comb0_dbgtop;
wire                            qacceptn_clustop_egress_comb0_dbgtop;
wire                            qdeny_clustop_egress_comb0_dbgtop;
wire                            qactive_clustop_egress_comb0_dbgtop;
     
wire                            qreqn_clustop_egress_comb1_dbgtop;
wire                            qacceptn_clustop_egress_comb1_dbgtop;
wire                            qdeny_clustop_egress_comb1_dbgtop;
wire                            qactive_clustop_egress_comb1_dbgtop;

       
wire [2:0]                      qreqn_systop;
wire [2:0]                      qacceptn_systop;
wire [2:0]                      qdeny_systop;
wire [2:0]                      qactive_systop;
  
wire                            qreqn_systop_acg;
wire                            qacceptn_systop_acg;
wire                            qdeny_systop_acg;
wire                            qactive_systop_acg;

    
wire [DBG_INTERNAL_CNT-1:0]     qreqn_dbgtop_internal;
wire [DBG_INTERNAL_CNT-1:0]     qacceptn_dbgtop_internal;
wire [DBG_INTERNAL_CNT-1:0]     qdeny_dbgtop_internal;
wire [DBG_INTERNAL_CNT-1:0]     qactive_dbgtop_internal;

wire [DBG_EGRESS_CNT-1:0]       qreqn_dbgtop_egress;
wire [DBG_EGRESS_CNT-1:0]       qacceptn_dbgtop_egress;
wire [DBG_EGRESS_CNT-1:0]       qdeny_dbgtop_egress;
wire [DBG_EGRESS_CNT-1:0]       qactive_dbgtop_egress;

wire  [1:0]                     dp2hostdbg_pwrdbg_aontop_pwrqreqn;
wire  [1:0]                     dp2hostdbg_pwrdbg_aontop_pwrqacceptn;
wire  [1:0]                     dp2hostdbg_pwrdbg_aontop_pwrqdeny;
wire  [1:0]                     dp2hostdbg_pwrdbg_aontop_pwrqactive;

wire                            systop_egress_dbgaon_comb1_pwrqreqn;
wire                            systop_egress_dbgaon_comb1_pwrqacceptn;
wire                            systop_egress_dbgaon_comb1_pwrqdeny;
wire                            systop_egress_dbgaon_comb1_pwrqactive;
            
wire   [1:0]                    systop_egress_dbgaon_comb_pwrqreqn;
wire   [1:0]                    systop_egress_dbgaon_comb_pwrqacceptn;
wire   [1:0]                    systop_egress_dbgaon_comb_pwrqdeny;
wire   [1:0]                    systop_egress_dbgaon_comb_pwrqactive;

wire                            clustop_egress_dbgtop_comb1_qreqn;
wire                            clustop_egress_dbgtop_comb1_qacceptn;
wire                            clustop_egress_dbgtop_comb1_qdeny;
wire                            clustop_egress_dbgtop_comb1_qactive;

  
wire                            cluster_config_cryptodisable;
wire                            pe0_config_aa64naa32 ; 
wire                            pe0_config_vinithi;
wire                            pe0_config_cfgte;
wire                            pe0_config_cfgend;
wire [29:0]                     pe0_rvbaraddr_lw_rvbar31_2 ; 
wire [11:0]                     pe0_rvbaraddr_up_rvbar43_32; 
wire                            pe1_config_aa64naa32 ;
wire                            pe1_config_vinithi;
wire                            pe1_config_cfgte;
wire                            pe1_config_cfgend;
wire [29:0]                     pe1_rvbaraddr_lw_rvbar31_2 ;
wire [11:0]                     pe1_rvbaraddr_up_rvbar43_32 ;
wire                            pe2_config_aa64naa32;
wire                            pe2_config_vinithi;
wire                            pe2_config_cfgte;
wire                            pe2_config_cfgend;
wire [29:0]                     pe2_rvbaraddr_lw_rvbar31_2;
wire [11:0]                     pe2_rvbaraddr_up_rvbar43_32;
wire                            pe3_config_aa64naa32;
wire                            pe3_config_vinithi;
wire                            pe3_config_cfgte;
wire                            pe3_config_cfgend;
wire [29:0]                     pe3_rvbaraddr_lw_rvbar31_2;
wire [11:0]                     pe3_rvbaraddr_up_rvbar43_32;
wire [3:0]                      host_cpu_boot_msk_boot_msk;
wire                            host_cpu_clus_pwr_req_pwr_req;
wire                            bsys_pwr_req_wakeup_en;
wire [7:0]                      hostcpuclk_ctrl_clkselect_cur;
wire [7:0]                      hostcpuclk_ctrl_clkselect;
wire [4:0]                      hostcpuclk_div0_clkdiv_cur;
  
wire [4:0]                      hostcpuclk_div0_clkdiv;
wire [4:0]                      hostcpuclk_div1_clkdiv_cur;
  
wire [4:0]                      hostcpuclk_div1_clkdiv;
wire [7:0]                      gicclk_ctrl_clkselect_cur;
wire [7:0]                      gicclk_ctrl_clkselect;
wire [4:0]                      gicclk_div0_clkdiv_cur;
wire [4:0]                      gicclk_div0_clkdiv;
wire [7:0]                      aclk_ctrl_clkselect_cur;
wire [7:0]                      aclk_ctrl_clkselect;
wire [4:0]                      aclk_div0_clkdiv_cur;
  
wire [4:0]                      aclk_div0_clkdiv;
wire [7:0]                      ctrlclk_ctrl_clkselect_cur;
wire [7:0]                      ctrlclk_ctrl_clkselect;
wire [4:0]                      ctrlclk_div0_clkdiv_cur;
wire [4:0]                      ctrlclk_div0_clkdiv;
wire [7:0]                      dbgclk_ctrl_clkselect_cur;
wire [7:0]                      dbgclk_ctrl_clkselect;
wire [4:0]                      dbgclk_div0_clkdiv_cur;
wire [4:0]                      dbgclk_div0_clkdiv;
wire                            clkforce_st_dbgclk_force_st;
wire                            clkforce_st_ctrlclk_force_st;
wire                            clkforce_st_aclk_force_st;
wire                            host_ppu_int_st_core3_int_st;
wire                            host_ppu_int_st_core2_int_st;
wire                            host_ppu_int_st_core1_int_st;
wire                            host_ppu_int_st_core0_int_st;
wire                            host_ppu_int_st_clustop_int_st;
wire                            host_cpu_clus_pwr_req_mem_ret_r;
    
wire                            irq_sdc600;
    
wire   [7:0]                    ie_data_sdc600;
wire                            ie_req_sdc600;
wire                            ie_ack_sdc600;
wire                            ie_linkup_sdc600;
wire                            ie_linkest_sdc600;
wire   [7:0]                    ei_data_sdc600;
wire                            ei_req_sdc600;
wire                            ei_ack_sdc600;
wire                            ei_linkup_sdc600;
wire                            ei_linkest_sdc600;

wire                            dp_abort_pulse_req;
wire                            dp_abort_pulse_ack;
    
    
wire                            irq_soc_etr;
wire                            irq_soc_catu;
wire                            irq_host_stm;
wire                            irq_host_etr;
wire                            irq_host_catu;
wire                            host_cti_trig_out_4;
wire                            host_cti_trig_out_5;


wire                            hes_0_eh0_mhuint;
wire                            esh_0_eh0_mhuint;
wire                            hes_1_eh0_mhuint;
wire                            esh_1_eh0_mhuint;
wire                            hes_0_eh1_mhuint;
wire                            esh_0_eh1_mhuint;
wire                            hes_1_eh1_mhuint;
wire                            esh_1_eh1_mhuint;

wire                            secenc_mhu1_sender_cirq;
wire                            secenc_mhu1_receiver_cirq;
wire                            secenc_mhu0_sender_cirq;
wire                            secenc_mhu0_receiver_cirq;


wire                            clustop_pcsm_preq_o;
wire [3:0]                      clustop_pcsm_pstate_o;
wire                            clustop_pcsm_paccept_i;
wire [3:0]                      clustop_pcsm_mode_stat_i;


wire                            refclk_warmresetn;
wire                            refclk_aontopporesetn;

wire [4:0]                      hostcpu_gicintdbgtop;                         
wire [1:0]                      hostcpu_gicintuart;                           
wire [95:0]            hostcpu_gicshdint;                            
wire [1:0]                      hostcpu_gicintwdogs;                          
wire                            hostcpu_gicintwdogns;                         

wire                            host_cti_trig_out_4_ack;
wire                            host_cti_trig_out_5_ack;
wire                            irq_host_stm_ack;

wire                            dbgtopap_pulse_out;
wire                            dbgtopaxi_pulse_out;

wire [3:0] axiap_csyspwrupreq_int; 
wire [3:0] axiap_csyspwrupack_int; 

wire                            hostrom_cdbgpwrupreq;
wire                            hostrom_cdbgpwrupack;

wire [2:0]  extdbg_cdbgpwrupreq;  
wire [2:0]  extdbg_cdbgpwrupack;  
  
assign hostcpuclk_ctrl_clkselect_cur[7:3] = 5'd0;  
assign gicclk_ctrl_clkselect_cur [7:2] = 6'd0;
assign aclk_ctrl_clkselect_cur   [7:2] = 6'd0;
assign ctrlclk_ctrl_clkselect_cur[7:2] = 6'd0;
assign dbgclk_ctrl_clkselect_cur [7:2] = 6'd0;

wire                               set_extsys0_cpuwait;
wire                               set_extsys1_cpuwait;

wire                               firewall_slvmustacceptreqn_async;
wire                               firewall_slvcandenyreqn_async;
wire                               firewall_slvacceptn_async;
wire                               firewall_slvdeny_async;

wire                               firewall_si_to_mi_wakeup_async;
wire                               firewall_mi_to_si_wakeup_async;

wire [FW_AXI_AW_FIFO_DEPTH-1:0]    firewall_aw_wr_ptr_async;
wire [FW_AXI_AW_FIFO_DEPTH-1:0]    firewall_aw_rd_ptr_async;
wire [FW_AXI_AW_PAYLOAD_WIDTH-1:0] firewall_aw_payld_async;

wire [FW_AXI_W_FIFO_DEPTH-1:0]     firewall_w_wr_ptr_async;
wire [FW_AXI_W_FIFO_DEPTH-1:0]     firewall_w_rd_ptr_async;
wire [FW_AXI_W_PAYLOAD_WIDTH-1:0]  firewall_w_payld_async;

wire [FW_AXI_B_FIFO_DEPTH-1:0]     firewall_b_wr_ptr_async;
wire [FW_AXI_B_FIFO_DEPTH-1:0]     firewall_b_rd_ptr_async;
wire [FW_AXI_B_PAYLOAD_WIDTH-1:0]  firewall_b_payld_async;

wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_wr_ptr_async;
wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_rd_ptr_async;
wire [FW_AXI_AR_PAYLOAD_WIDTH-1:0] firewall_ar_payld_async;

wire [FW_AXI_R_FIFO_DEPTH -1:0]    firewall_r_wr_ptr_async;
wire [FW_AXI_R_FIFO_DEPTH -1:0]    firewall_r_rd_ptr_async;
wire [FW_AXI_R_PAYLOAD_WIDTH-1:0]  firewall_r_payld_async;


wire                               aontoppo_systop_qreqn;
wire                               aontoppo_systop_qacceptn;
wire                               aontoppo_systop_qdeny;
wire                               aontoppo_systop_qactive;

wire                               aontoppo_dbgtop_qreqn;
wire                               aontoppo_dbgtop_qacceptn;
wire                               aontoppo_dbgtop_qdeny;
wire                               aontoppo_dbgtop_qactive;

wire                               aon_ctrlresetn;

wire [NUM_EXT_SYS-1:0]             t_qreqn_extsys_systopq;
wire [NUM_EXT_SYS-1:0]             t_qacceptn_extsys_systopq;
wire [NUM_EXT_SYS-1:0]             t_qdeny_extsys_systopq;
wire [NUM_EXT_SYS-1:0]             t_qactive_extsys_systopq;

wire [NUM_EXT_SYS-1:0]             t_qreqn_extsys_dbgtopq;
wire [NUM_EXT_SYS-1:0]             t_qacceptn_extsys_dbgtopq;
wire [NUM_EXT_SYS-1:0]             t_qdeny_extsys_dbgtopq;
wire [NUM_EXT_SYS-1:0]             t_qactive_extsys_dbgtopq;

wire [3:0]           host_cpu_wake_up;
wire [4:0]  host_lock;

wire [15:0]                        clustop_ppuhwstat;
 
        
wire                               uart_async_req;
wire [52:0]                        uart_async_req_payload;
wire [32:0]                        uart_async_resp_payload;
wire                               uart_async_ack;
            
wire  [9:0]     modify_lock_req;
wire  [9:0]     modify_lock_ack;


pd_systop_f0  #(

  .NUM_EXP_SHD_INT                                  (64),
  .HOST_CPU_NUM_CORES                               (HOST_CPU_NUM_CORES),
  .CLUSTOP_CORE_RST_DLY                             (CLUSTOP_CORE_RST_DLY),

  .EXT_SYS0_TZ_SPT                    (EXT_SYS0_TZ_SPT),
  .MHU_HES00_NUM_CH                   (MHU_HES00_NUM_CH),
  .MHU_ES0H0_NUM_CH                   (MHU_ES0H0_NUM_CH),
    .MHU_HES01_NUM_CH                   (MHU_HES01_NUM_CH),
  .MHU_ES0H1_NUM_CH                   (MHU_ES0H1_NUM_CH),
  
  .EXT_SYS0_MEM_ADDR_WIDTH            (EXT_SYS0_MEM_ADDR_WIDTH),
  .EXT_SYS0_MEM_DATA_WIDTH            (EXT_SYS0_MEM_DATA_WIDTH),
  .EXT_SYS0_MEM_AWID_WIDTH            (EXT_SYS0_MEM_AWID_WIDTH),
  .EXT_SYS0_MEM_ARID_WIDTH            (EXT_SYS0_MEM_ARID_WIDTH),
  .EXT_SYS0_MEM_AWUSER_WIDTH          (EXT_SYS0_MEM_AWUSER_WIDTH),
  .EXT_SYS0_MEM_WUSER_WIDTH           (EXT_SYS0_MEM_WUSER_WIDTH),
  .EXT_SYS0_MEM_BUSER_WIDTH           (EXT_SYS0_MEM_BUSER_WIDTH),
  .EXT_SYS0_MEM_ARUSER_WIDTH          (EXT_SYS0_MEM_ARUSER_WIDTH),
  .EXT_SYS0_MEM_RUSER_WIDTH           (EXT_SYS0_MEM_RUSER_WIDTH),
  .EXT_SYS0_MEM_AW_FIFO_DEPTH         (EXT_SYS0_MEM_AW_FIFO_DEPTH),
  .EXT_SYS0_MEM_W_FIFO_DEPTH          (EXT_SYS0_MEM_W_FIFO_DEPTH),
  .EXT_SYS0_MEM_B_FIFO_DEPTH          (EXT_SYS0_MEM_B_FIFO_DEPTH),
  .EXT_SYS0_MEM_AR_FIFO_DEPTH         (EXT_SYS0_MEM_AR_FIFO_DEPTH),
  .EXT_SYS0_MEM_R_FIFO_DEPTH          (EXT_SYS0_MEM_R_FIFO_DEPTH),
  .EXT_SYS0_MEM_AW_PAYLOAD_WIDTH      (EXT_SYS0_MEM_AW_PAYLOAD_WIDTH),
  .EXT_SYS0_MEM_W_PAYLOAD_WIDTH       (EXT_SYS0_MEM_W_PAYLOAD_WIDTH),
  .EXT_SYS0_MEM_B_PAYLOAD_WIDTH       (EXT_SYS0_MEM_B_PAYLOAD_WIDTH),
  .EXT_SYS0_MEM_AR_PAYLOAD_WIDTH      (EXT_SYS0_MEM_AR_PAYLOAD_WIDTH),
  .EXT_SYS0_MEM_R_PAYLOAD_WIDTH       (EXT_SYS0_MEM_R_PAYLOAD_WIDTH), 

  .EXT_SYS1_TZ_SPT                    (EXT_SYS1_TZ_SPT),
  .MHU_HES10_NUM_CH                   (MHU_HES10_NUM_CH),
  .MHU_ES1H0_NUM_CH                   (MHU_ES1H0_NUM_CH),
    .MHU_HES11_NUM_CH                   (MHU_HES11_NUM_CH),
  .MHU_ES1H1_NUM_CH                   (MHU_ES1H1_NUM_CH),
  
  .EXT_SYS1_MEM_ADDR_WIDTH            (EXT_SYS1_MEM_ADDR_WIDTH),
  .EXT_SYS1_MEM_DATA_WIDTH            (EXT_SYS1_MEM_DATA_WIDTH),
  .EXT_SYS1_MEM_AWID_WIDTH            (EXT_SYS1_MEM_AWID_WIDTH),
  .EXT_SYS1_MEM_ARID_WIDTH            (EXT_SYS1_MEM_ARID_WIDTH),
  .EXT_SYS1_MEM_AWUSER_WIDTH          (EXT_SYS1_MEM_AWUSER_WIDTH),
  .EXT_SYS1_MEM_WUSER_WIDTH           (EXT_SYS1_MEM_WUSER_WIDTH),
  .EXT_SYS1_MEM_BUSER_WIDTH           (EXT_SYS1_MEM_BUSER_WIDTH),
  .EXT_SYS1_MEM_ARUSER_WIDTH          (EXT_SYS1_MEM_ARUSER_WIDTH),
  .EXT_SYS1_MEM_RUSER_WIDTH           (EXT_SYS1_MEM_RUSER_WIDTH),
  .EXT_SYS1_MEM_AW_FIFO_DEPTH         (EXT_SYS1_MEM_AW_FIFO_DEPTH),
  .EXT_SYS1_MEM_W_FIFO_DEPTH          (EXT_SYS1_MEM_W_FIFO_DEPTH),
  .EXT_SYS1_MEM_B_FIFO_DEPTH          (EXT_SYS1_MEM_B_FIFO_DEPTH),
  .EXT_SYS1_MEM_AR_FIFO_DEPTH         (EXT_SYS1_MEM_AR_FIFO_DEPTH),
  .EXT_SYS1_MEM_R_FIFO_DEPTH          (EXT_SYS1_MEM_R_FIFO_DEPTH),
  .EXT_SYS1_MEM_AW_PAYLOAD_WIDTH      (EXT_SYS1_MEM_AW_PAYLOAD_WIDTH),
  .EXT_SYS1_MEM_W_PAYLOAD_WIDTH       (EXT_SYS1_MEM_W_PAYLOAD_WIDTH),
  .EXT_SYS1_MEM_B_PAYLOAD_WIDTH       (EXT_SYS1_MEM_B_PAYLOAD_WIDTH),
  .EXT_SYS1_MEM_AR_PAYLOAD_WIDTH      (EXT_SYS1_MEM_AR_PAYLOAD_WIDTH),
  .EXT_SYS1_MEM_R_PAYLOAD_WIDTH       (EXT_SYS1_MEM_R_PAYLOAD_WIDTH), 

  

  .XNVM_DATA_WIDTH                                  (XNVM_DATA_WIDTH), 
  .CVM_DATA_WIDTH                                   (CVM_DATA_WIDTH), 
  .OCVM_DATA_WIDTH                                  (OCVM_DATA_WIDTH), 

  .EXPSLV0_DATA_WIDTH                 (EXPSLV0_DATA_WIDTH), 
  .EXPSLV0_ID_WIDTH                   (EXPSLV0_ID_WIDTH), 
  .EXPSLV1_DATA_WIDTH                 (EXPSLV1_DATA_WIDTH), 
  .EXPSLV1_ID_WIDTH                   (EXPSLV1_ID_WIDTH), 

  .EXPMST0_DATA_WIDTH                 (EXPMST0_DATA_WIDTH), 
  .EXPMST1_DATA_WIDTH                 (EXPMST1_DATA_WIDTH), 

  .MHU_HSE0_NUM_CH                                  (MHU_HSE0_NUM_CH),
  .MHU_SEH0_NUM_CH                                  (MHU_SEH0_NUM_CH),
  .MHU_HSE1_NUM_CH                                  (MHU_HSE1_NUM_CH),
  .MHU_SEH1_NUM_CH                                  (MHU_SEH1_NUM_CH),

  .CPU_AW_FIFO_DEPTH                                (CPU_AW_FIFO_DEPTH),
  .CPU_W_FIFO_DEPTH                                 (CPU_W_FIFO_DEPTH),
  .CPU_B_FIFO_DEPTH                                 (CPU_B_FIFO_DEPTH),
  .CPU_AR_FIFO_DEPTH                                (CPU_AR_FIFO_DEPTH),
  .CPU_R_FIFO_DEPTH                                 (CPU_R_FIFO_DEPTH),

  .GIC_AW_FIFO_DEPTH                                (GIC_AW_FIFO_DEPTH),
  .GIC_W_FIFO_DEPTH                                 (GIC_W_FIFO_DEPTH),
  .GIC_B_FIFO_DEPTH                                 (GIC_B_FIFO_DEPTH),
  .GIC_AR_FIFO_DEPTH                                (GIC_AR_FIFO_DEPTH),
  .GIC_R_FIFO_DEPTH                                 (GIC_R_FIFO_DEPTH),
                                
  .SECENC_ADDR_WIDTH                                (SECENC_ADDR_WIDTH),
  .SECENC_DATA_WIDTH                                (SECENC_DATA_WIDTH),
  .SECENC_AWID_WIDTH                                (SECENC_AWID_WIDTH),
  .SECENC_ARID_WIDTH                                (SECENC_ARID_WIDTH),
  .SECENC_AWUSER_WIDTH                              (SECENC_AWUSER_WIDTH),
  .SECENC_WUSER_WIDTH                               (SECENC_WUSER_WIDTH),
  .SECENC_BUSER_WIDTH                               (SECENC_BUSER_WIDTH),
  .SECENC_ARUSER_WIDTH                              (SECENC_ARUSER_WIDTH),
  .SECENC_RUSER_WIDTH                               (SECENC_RUSER_WIDTH),
  .SECENC_AW_FIFO_DEPTH                             (SECENC_AW_FIFO_DEPTH),
  .SECENC_W_FIFO_DEPTH                              (SECENC_W_FIFO_DEPTH),
  .SECENC_B_FIFO_DEPTH                              (SECENC_B_FIFO_DEPTH),
  .SECENC_AR_FIFO_DEPTH                             (SECENC_AR_FIFO_DEPTH),
  .SECENC_R_FIFO_DEPTH                              (SECENC_R_FIFO_DEPTH),
  .SECENC_AW_PAYLOAD_WIDTH                          (SECENC_AW_PAYLOAD_WIDTH),
  .SECENC_W_PAYLOAD_WIDTH                           (SECENC_W_PAYLOAD_WIDTH),
  .SECENC_B_PAYLOAD_WIDTH                           (SECENC_B_PAYLOAD_WIDTH),
  .SECENC_AR_PAYLOAD_WIDTH                          (SECENC_AR_PAYLOAD_WIDTH),
  .SECENC_R_PAYLOAD_WIDTH                           (SECENC_R_PAYLOAD_WIDTH),

  .FW2SYSTOP_FIFO_DEPTH                             (FW2SYSTOP_FIFO_DEPTH),
  
  .FW_AXI_ADDR_WIDTH                                (FW_AXI_ADDR_WIDTH),
  .FW_AXI_DATA_WIDTH                                (FW_AXI_DATA_WIDTH),
  .FW_AXI_AWID_WIDTH                                (FW_AXI_AWID_WIDTH),
  .FW_AXI_ARID_WIDTH                                (FW_AXI_ARID_WIDTH),
  .FW_AXI_AWUSER_WIDTH                              (FW_AXI_AWUSER_WIDTH),
  .FW_AXI_WUSER_WIDTH                               (FW_AXI_WUSER_WIDTH),
  .FW_AXI_BUSER_WIDTH                               (FW_AXI_BUSER_WIDTH),
  .FW_AXI_ARUSER_WIDTH                              (FW_AXI_ARUSER_WIDTH),
  .FW_AXI_RUSER_WIDTH                               (FW_AXI_RUSER_WIDTH),
  
  .FW_AXI_AW_FIFO_DEPTH                             (FW_AXI_AW_FIFO_DEPTH),
  .FW_AXI_W_FIFO_DEPTH                              (FW_AXI_W_FIFO_DEPTH),
  .FW_AXI_B_FIFO_DEPTH                              (FW_AXI_B_FIFO_DEPTH),
  .FW_AXI_AR_FIFO_DEPTH                             (FW_AXI_AR_FIFO_DEPTH),
  .FW_AXI_R_FIFO_DEPTH                              (FW_AXI_R_FIFO_DEPTH),
  .FW_AXI_AW_PAYLOAD_WIDTH                          (FW_AXI_AW_PAYLOAD_WIDTH),
  .FW_AXI_W_PAYLOAD_WIDTH                           (FW_AXI_W_PAYLOAD_WIDTH),
  .FW_AXI_B_PAYLOAD_WIDTH                           (FW_AXI_B_PAYLOAD_WIDTH),
  .FW_AXI_AR_PAYLOAD_WIDTH                          (FW_AXI_AR_PAYLOAD_WIDTH),
  .FW_AXI_R_PAYLOAD_WIDTH                           (FW_AXI_R_PAYLOAD_WIDTH),

  .DEV_PREQ_DLY_CLUS                                (DEV_PREQ_DLY_CLUS),
  .PCSM_PREQ_DLY_CLUS                               (PCSM_PREQ_DLY_CLUS),
  .ISO_CLKEN_DLY_CFG_CLUS                           (ISO_CLKEN_DLY_CFG_CLUS),
  .CLKEN_RST_DLY_CFG_CLUS                           (CLKEN_RST_DLY_CFG_CLUS),
  .RST_HWSTAT_DLY_CFG_CLUS                          (RST_HWSTAT_DLY_CFG_CLUS),
  .CLKEN_ISO_DLY_CFG_CLUS                           (CLKEN_ISO_DLY_CFG_CLUS),
  .ISO_RST_DLY_CFG_CLUS                             (ISO_RST_DLY_CFG_CLUS),

 
  .DEV_PREQ_DLY_CPU3                  (DEV_PREQ_DLY_CPU3      ),
  .PCSM_PREQ_DLY_CPU3                 (PCSM_PREQ_DLY_CPU3     ),
  .ISO_CLKEN_DLY_CFG_CPU3             (ISO_CLKEN_DLY_CFG_CPU3 ),
  .CLKEN_RST_DLY_CFG_CPU3             (CLKEN_RST_DLY_CFG_CPU3 ),
  .RST_HWSTAT_DLY_CFG_CPU3            (RST_HWSTAT_DLY_CFG_CPU3),
  .CLKEN_ISO_DLY_CFG_CPU3             (CLKEN_ISO_DLY_CFG_CPU3 ),
  .ISO_RST_DLY_CFG_CPU3               (ISO_RST_DLY_CFG_CPU3   ),
  
 
  .DEV_PREQ_DLY_CPU2                  (DEV_PREQ_DLY_CPU2      ),
  .PCSM_PREQ_DLY_CPU2                 (PCSM_PREQ_DLY_CPU2     ),
  .ISO_CLKEN_DLY_CFG_CPU2             (ISO_CLKEN_DLY_CFG_CPU2 ),
  .CLKEN_RST_DLY_CFG_CPU2             (CLKEN_RST_DLY_CFG_CPU2 ),
  .RST_HWSTAT_DLY_CFG_CPU2            (RST_HWSTAT_DLY_CFG_CPU2),
  .CLKEN_ISO_DLY_CFG_CPU2             (CLKEN_ISO_DLY_CFG_CPU2 ),
  .ISO_RST_DLY_CFG_CPU2               (ISO_RST_DLY_CFG_CPU2   ),
  
 
  .DEV_PREQ_DLY_CPU1                  (DEV_PREQ_DLY_CPU1      ),
  .PCSM_PREQ_DLY_CPU1                 (PCSM_PREQ_DLY_CPU1     ),
  .ISO_CLKEN_DLY_CFG_CPU1             (ISO_CLKEN_DLY_CFG_CPU1 ),
  .CLKEN_RST_DLY_CFG_CPU1             (CLKEN_RST_DLY_CFG_CPU1 ),
  .RST_HWSTAT_DLY_CFG_CPU1            (RST_HWSTAT_DLY_CFG_CPU1),
  .CLKEN_ISO_DLY_CFG_CPU1             (CLKEN_ISO_DLY_CFG_CPU1 ),
  .ISO_RST_DLY_CFG_CPU1               (ISO_RST_DLY_CFG_CPU1   ),
  
 
  .DEV_PREQ_DLY_CPU0                  (DEV_PREQ_DLY_CPU0      ),
  .PCSM_PREQ_DLY_CPU0                 (PCSM_PREQ_DLY_CPU0     ),
  .ISO_CLKEN_DLY_CFG_CPU0             (ISO_CLKEN_DLY_CFG_CPU0 ),
  .CLKEN_RST_DLY_CFG_CPU0             (CLKEN_RST_DLY_CFG_CPU0 ),
  .RST_HWSTAT_DLY_CFG_CPU0            (RST_HWSTAT_DLY_CFG_CPU0),
  .CLKEN_ISO_DLY_CFG_CPU0             (CLKEN_ISO_DLY_CFG_CPU0 ),
  .ISO_RST_DLY_CFG_CPU0               (ISO_RST_DLY_CFG_CPU0   ),
  
  .DBG_ADDR_WIDTH                                   (DBG_ADDR_WIDTH),
  .DBG_DATA_WIDTH                                   (DBG_DATA_WIDTH),
  .DBG_AWID_WIDTH                                   (DBG_AWID_WIDTH),
  .DBG_ARID_WIDTH                                   (DBG_ARID_WIDTH),
  .DBG_AWUSER_WIDTH                                 (DBG_AWUSER_WIDTH),
  .DBG_WUSER_WIDTH                                  (DBG_WUSER_WIDTH),
  .DBG_BUSER_WIDTH                                  (DBG_BUSER_WIDTH),
  .DBG_ARUSER_WIDTH                                 (DBG_ARUSER_WIDTH),
  .DBG_RUSER_WIDTH                                  (DBG_RUSER_WIDTH),
  .DBG_AW_FIFO_DEPTH                                (DBG_AW_FIFO_DEPTH),
  .DBG_W_FIFO_DEPTH                                 (DBG_W_FIFO_DEPTH),
  .DBG_B_FIFO_DEPTH                                 (DBG_B_FIFO_DEPTH),
  .DBG_AR_FIFO_DEPTH                                (DBG_AR_FIFO_DEPTH),
  .DBG_R_FIFO_DEPTH                                 (DBG_R_FIFO_DEPTH),
  .DBG_AW_PAYLOAD_WIDTH                             (DBG_AW_PAYLOAD_WIDTH),
  .DBG_W_PAYLOAD_WIDTH                              (DBG_W_PAYLOAD_WIDTH),
  .DBG_B_PAYLOAD_WIDTH                              (DBG_B_PAYLOAD_WIDTH),
  .DBG_AR_PAYLOAD_WIDTH                             (DBG_AR_PAYLOAD_WIDTH),
  .DBG_R_PAYLOAD_WIDTH                              (DBG_R_PAYLOAD_WIDTH),
  .STM_ADDR_WIDTH                                   (STM_ADDR_WIDTH),
  .STM_DATA_WIDTH                                   (STM_DATA_WIDTH),
  .STM_AWUSER_WIDTH                                 (STM_AWUSER_WIDTH),
  .STM_WUSER_WIDTH                                  (STM_WUSER_WIDTH),
  .STM_BUSER_WIDTH                                  (STM_BUSER_WIDTH),
  .STM_ARUSER_WIDTH                                 (STM_ARUSER_WIDTH),
  .STM_RUSER_WIDTH                                  (STM_RUSER_WIDTH),
  .STM_AW_FIFO_DEPTH                                (STM_AW_FIFO_DEPTH),
  .STM_W_FIFO_DEPTH                                 (STM_W_FIFO_DEPTH),
  .STM_B_FIFO_DEPTH                                 (STM_B_FIFO_DEPTH),
  .STM_AR_FIFO_DEPTH                                (STM_AR_FIFO_DEPTH),
  .STM_R_FIFO_DEPTH                                 (STM_R_FIFO_DEPTH),
  .STM_AW_PAYLOAD_WIDTH                             (STM_AW_PAYLOAD_WIDTH),
  .STM_W_PAYLOAD_WIDTH                              (STM_W_PAYLOAD_WIDTH),
  .STM_B_PAYLOAD_WIDTH                              (STM_B_PAYLOAD_WIDTH),
  .STM_AR_PAYLOAD_WIDTH                             (STM_AR_PAYLOAD_WIDTH),
  .STM_R_PAYLOAD_WIDTH                              (STM_R_PAYLOAD_WIDTH),
  .STM_AXI_ID_WIDTH                                 (STM_AXI_ID_WIDTH),
  .SYS_EGRESS_2_DBG                                 (SYS_EGRESS_2_DBG),
  .NUM_ACLK_QCH                                     (NUM_ACLK_QCH)
  ) u_pd_systop (
  .refclk                                           (refclk_systop),
  .refclk_qactive_o                                 (qactive_refclk_systop),
  .sys_pll                                          (syspll_systop),
  .cpu_pll                                          (cpupll_systop),
  .aclkout                                          (ACLKOUT),
  .aclk_on_syspll_divratio                          (aclk_div0_clkdiv[4:0]),
  .aclk_on_syspll_divratio_cur                      (aclk_div0_clkdiv_cur[4:0]),
  .aclk_clksel                                      (aclk_ctrl_clkselect[1:0]),
  .aclk_clksel_cur                                  (aclk_ctrl_clkselect_cur[1:0]),
  .host_cntclkout                                   (hostcntclkout_systop),
  
  .ctrlclk_on_syspll_divratio                       (ctrlclk_div0_clkdiv),
  .ctrlclk_on_syspll_divratio_cur                   (ctrlclk_div0_clkdiv_cur),
  .ctrlclk_clksel                                   (ctrlclk_ctrl_clkselect[1:0]),
  .ctrlclk_clksel_cur                               (ctrlclk_ctrl_clkselect_cur[1:0]),
  
  .aclk_qreqn                                       (ACLKQREQn),
  .aclk_qacceptn                                    (ACLKQACCEPTn),
  .aclk_qdeny                                       (ACLKQDENY),
  .aclk_qactive                                     (ACLKQACTIVE),
 
  
  .aclk_ctrl_entrydelay                             (aclk_ctrl_entrydelay),
  .ctrlclk_ctrl_entrydelay                          (ctrlclk_ctrl_entrydelay),

  .clustop_ppuhwstat                                (clustop_ppuhwstat),
  .ppu_dbgen                                        (ppu_dbgen),

  .hostcpu_corewakeup                               (host_cpu_wake_up),
  .host_lock                                        (host_lock),
  
  .modify_lock_req                                  (modify_lock_req),
  .modify_lock_ack                                  (modify_lock_ack),
  
  
  .hostcpuclk_div1_clkdiv                           (hostcpuclk_div1_clkdiv),
  .hostcpuclk_div1_clkdiv_cur                       (hostcpuclk_div1_clkdiv_cur),
  .hostcpuclk_div0_clkdiv                           (hostcpuclk_div0_clkdiv),
  .hostcpuclk_div0_clkdiv_cur                       (hostcpuclk_div0_clkdiv_cur),
  .hostcpuclk_ctrl_clkselect                        (hostcpuclk_ctrl_clkselect[2:0]),
  .hostcpuclk_ctrl_clkselect_cur                    (hostcpuclk_ctrl_clkselect_cur[2:0]),
  .gicclk_div0_clkdiv                               (gicclk_div0_clkdiv),
  .gicclk_div0_clkdiv_cur                           (gicclk_div0_clkdiv_cur),
  .gicclk_ctrl_clkselect                            (gicclk_ctrl_clkselect[1:0]),
  .gicclk_ctrl_clkselect_cur                        (gicclk_ctrl_clkselect_cur[1:0]),

  .systop_warmresetn                                (SYSTOPWARMRESETn),
  .mbistreq                                         (MBISTREQ),
  .nmbistreset                                      (nMBISTRESET),
  .dftdivsel                                        (DFTDIVSEL),
  .dftrstdisable                                    ({DFTRSTDISABLE[1], DFTRSTDISABLE[0]}),
  .dftisodisable                                    (DFTISODISABLE),
  .dftcgen                                          (DFTCGEN),
  .dftpwrup                                         (DFTPWRUP),
  .dftretdisable                                    (DFTRETDISABLE),
  .dftaclksel                                       (DFTACLKSEL),
  .dftaclkselen                                     (DFTCLKSELEN),
  .dftaclkdivbypass                                 (DFTDIVBYPASS),
  
  .dftctrlclksel                                    (DFTCTRLCLKSEL),
  .dftctrlclkselen                                  (DFTCLKSELEN),
  .dftctrlclkdivbypass                              (DFTDIVBYPASS),
  
  .dftgicclksel                                     (DFTGICCLKSEL),
  .dftgicclkselen                                   (DFTCLKSELEN),
  .dftgicclkdivbypass                               (DFTDIVBYPASS),
  
  .dfthostcpuclksel                                 (DFTHOSTCPUCLKSEL),
  .dfthostcpuclkselen                               (DFTCLKSELEN),
  .dfthostcpuclkdivbypass                           (DFTDIVBYPASS),
 
  .clustop_pcsm_preq_o                              (clustop_pcsm_preq_o),
  .clustop_pcsm_pstate_o                            (clustop_pcsm_pstate_o),
  .clustop_pcsm_paccept_i                           (clustop_pcsm_paccept_i),
  .clustop_pcsm_mode_stat_i                         (clustop_pcsm_mode_stat_i),


  .hostcpu_gicintdbgtop                             (hostcpu_gicintdbgtop),
  .hostcpu_gicintuart                               (hostcpu_gicintuart),
  .hostcpu_gicintwdogs                              (hostcpu_gicintwdogs),
  .hostcpu_gicintwdogns                             (hostcpu_gicintwdogns),
  .hostcpu_gicshdint                                (hostcpu_gicshdint),

  .hostcpu_gicintdbgtop_pulse_ack                   ({host_cti_trig_out_5_ack, host_cti_trig_out_4_ack, irq_host_stm_ack}),

  .hostsysdbg_async_req                             (hostsysdbg_async_req),
  .hostsysdbg_async_req_payload                     (hostsysdbg_async_req_payload),
  .hostsysdbg_async_resp_payload                    (hostsysdbg_async_resp_payload),
  .hostsysdbg_async_ack                             (hostsysdbg_async_ack),

  .uart_async_req                                   (uart_async_req),
  .uart_async_req_payload                           (uart_async_req_payload),
  .uart_async_resp_payload                          (uart_async_resp_payload),
  .uart_async_ack                                   (uart_async_ack),
  

  .irq_sdc600                                       (irq_sdc600),

  .ie_data_sdc600                                   (ie_data_sdc600),
  .ie_req_sdc600                                    (ie_req_sdc600),
  .ie_ack_sdc600                                    (ie_ack_sdc600),
  .ie_linkup_sdc600                                 (ie_linkup_sdc600),
  .ie_linkest_sdc600                                (ie_linkest_sdc600),
  .ei_data_sdc600                                   (ei_data_sdc600),
  .ei_req_sdc600                                    (ei_req_sdc600),
  .ei_ack_sdc600                                    (ei_ack_sdc600),
  .ei_linkup_sdc600                                 (ei_linkup_sdc600),
  .ei_linkest_sdc600                                (ei_linkest_sdc600),
     
   .fctrl_bypass                                    (host_fctrl_bypass),
  .firewall_slvmustacceptreqn_async                 (firewall_slvmustacceptreqn_async),
  .firewall_slvcandenyreqn_async                    (firewall_slvcandenyreqn_async),
  .firewall_slvacceptn_async                        (firewall_slvacceptn_async),
  .firewall_slvdeny_async                           (firewall_slvdeny_async),

  .firewall_si_to_mi_wakeup_async                   (firewall_si_to_mi_wakeup_async),
  .firewall_mi_to_si_wakeup_async                   (firewall_mi_to_si_wakeup_async),
    
  .firewall_aw_wr_ptr_async                         (firewall_aw_wr_ptr_async),
  .firewall_aw_rd_ptr_async                         (firewall_aw_rd_ptr_async),
  .firewall_aw_payld_async                          (firewall_aw_payld_async),
  .firewall_w_wr_ptr_async                          (firewall_w_wr_ptr_async),
  .firewall_w_rd_ptr_async                          (firewall_w_rd_ptr_async),
  .firewall_w_payld_async                           (firewall_w_payld_async),
  .firewall_b_wr_ptr_async                          (firewall_b_wr_ptr_async),
  .firewall_b_rd_ptr_async                          (firewall_b_rd_ptr_async),
  .firewall_b_payld_async                           (firewall_b_payld_async),
  .firewall_ar_wr_ptr_async                         (firewall_ar_wr_ptr_async),
  .firewall_ar_rd_ptr_async                         (firewall_ar_rd_ptr_async),
  .firewall_ar_payld_async                          (firewall_ar_payld_async),
  .firewall_r_wr_ptr_async                          (firewall_r_wr_ptr_async),
  .firewall_r_rd_ptr_async                          (firewall_r_rd_ptr_async),
  .firewall_r_payld_async                           (firewall_r_payld_async),
  .fw2systop_dn_slvmustacceptreqn_async             (fw2systop_dn_slvmustacceptreqn_async),
  .fw2systop_dn_slvcandenyreqn_async                (fw2systop_dn_slvcandenyreqn_async),
  .fw2systop_dn_slvacceptn_async                    (fw2systop_dn_slvacceptn_async),
  .fw2systop_dn_slvdeny_async                       (fw2systop_dn_slvdeny_async),
  .fw2systop_dn_si_to_mi_wakeup_async               (fw2systop_dn_si_to_mi_wakeup_async),
  .fw2systop_dn_mi_to_si_wakeup_async               (fw2systop_dn_mi_to_si_wakeup_async),
  .fw2systop_dn_wr_ptr_async                        (fw2systop_dn_wr_ptr_async),
  .fw2systop_dn_rd_ptr_async                        (fw2systop_dn_rd_ptr_async),
  .fw2systop_dn_payld_async                         (fw2systop_dn_payld_async),
                                                    
  .fw2systop_up_slvmustacceptreqn_async             (fw2systop_up_slvmustacceptreqn_async),
  .fw2systop_up_slvcandenyreqn_async                (fw2systop_up_slvcandenyreqn_async),
  .fw2systop_up_slvacceptn_async                    (fw2systop_up_slvacceptn_async),
  .fw2systop_up_slvdeny_async                       (fw2systop_up_slvdeny_async),
  .fw2systop_up_si_to_mi_wakeup_async               (fw2systop_up_si_to_mi_wakeup_async),
  .fw2systop_up_mi_to_si_wakeup_async               (fw2systop_up_mi_to_si_wakeup_async),
  .fw2systop_up_wr_ptr_async                        (fw2systop_up_wr_ptr_async),
  .fw2systop_up_rd_ptr_async                        (fw2systop_up_rd_ptr_async),
  .fw2systop_up_payld_async                         (fw2systop_up_payld_async),
  


  .awid_xnvm_axim                                   (AWIDXNVM),
  .awaddr_xnvm_axim                                 (AWADDRXNVM),
  .awlen_xnvm_axim                                  (AWLENXNVM),
  .awsize_xnvm_axim                                 (AWSIZEXNVM),
  .awburst_xnvm_axim                                (AWBURSTXNVM),
  .awlock_xnvm_axim                                 (AWLOCKXNVM),
  .awcache_xnvm_axim                                (AWCACHEXNVM),
  .awprot_xnvm_axim                                 (AWPROTXNVM),
  .awvalid_xnvm_axim                                (AWVALIDXNVM),
  .awakeup_xnvm_axim                                (AWAKEUPXNVM),
  .awready_xnvm_axim                                (AWREADYXNVM),
  .wdata_xnvm_axim                                  (WDATAXNVM),
  .wstrb_xnvm_axim                                  (WSTRBXNVM),
  .wlast_xnvm_axim                                  (WLASTXNVM),
  .wvalid_xnvm_axim                                 (WVALIDXNVM),
  .wready_xnvm_axim                                 (WREADYXNVM),
  .bid_xnvm_axim                                    (BIDXNVM),
  .bresp_xnvm_axim                                  (BRESPXNVM),
  .bvalid_xnvm_axim                                 (BVALIDXNVM),
  .bready_xnvm_axim                                 (BREADYXNVM),
  .arid_xnvm_axim                                   (ARIDXNVM),
  .araddr_xnvm_axim                                 (ARADDRXNVM),
  .arlen_xnvm_axim                                  (ARLENXNVM),
  .arsize_xnvm_axim                                 (ARSIZEXNVM),
  .arburst_xnvm_axim                                (ARBURSTXNVM),
  .arlock_xnvm_axim                                 (ARLOCKXNVM),
  .arcache_xnvm_axim                                (ARCACHEXNVM),
  .arprot_xnvm_axim                                 (ARPROTXNVM),
  .arvalid_xnvm_axim                                (ARVALIDXNVM),
  .arready_xnvm_axim                                (ARREADYXNVM),
  .rid_xnvm_axim                                    (RIDXNVM),
  .rdata_xnvm_axim                                  (RDATAXNVM),
  .rresp_xnvm_axim                                  (RRESPXNVM),
  .rlast_xnvm_axim                                  (RLASTXNVM),
  .rvalid_xnvm_axim                                 (RVALIDXNVM),
  .rready_xnvm_axim                                 (RREADYXNVM),
  .awuser_xnvm_axim                                 ({AWMMUSIDXNVM,AWUSERXNVM}),
  .aruser_xnvm_axim                                 ({ARMMUSIDXNVM,ARUSERXNVM}),
  .awqos_xnvm_axim                                  (AWQOSXNVM),
  .arqos_xnvm_axim                                  (ARQOSXNVM),
  

  .awid_cvm_axim                                    (AWIDCVM),
  .awaddr_cvm_axim                                  (AWADDRCVM),
  .awlen_cvm_axim                                   (AWLENCVM),
  .awsize_cvm_axim                                  (AWSIZECVM),
  .awburst_cvm_axim                                 (AWBURSTCVM),
  .awlock_cvm_axim                                  (AWLOCKCVM),
  .awcache_cvm_axim                                 (AWCACHECVM),
  .awprot_cvm_axim                                  (AWPROTCVM),
  .awvalid_cvm_axim                                 (AWVALIDCVM),
  .awakeup_cvm_axim                                 (AWAKEUPCVM),
  .awready_cvm_axim                                 (AWREADYCVM),
  .wdata_cvm_axim                                   (WDATACVM),
  .wstrb_cvm_axim                                   (WSTRBCVM),
  .wlast_cvm_axim                                   (WLASTCVM),
  .wvalid_cvm_axim                                  (WVALIDCVM),
  .wready_cvm_axim                                  (WREADYCVM),
  .bid_cvm_axim                                     (BIDCVM),
  .bresp_cvm_axim                                   (BRESPCVM),
  .bvalid_cvm_axim                                  (BVALIDCVM),
  .bready_cvm_axim                                  (BREADYCVM),
  .arid_cvm_axim                                    (ARIDCVM),
  .araddr_cvm_axim                                  (ARADDRCVM),
  .arlen_cvm_axim                                   (ARLENCVM),
  .arsize_cvm_axim                                  (ARSIZECVM),
  .arburst_cvm_axim                                 (ARBURSTCVM),
  .arlock_cvm_axim                                  (ARLOCKCVM),
  .arcache_cvm_axim                                 (ARCACHECVM),
  .arprot_cvm_axim                                  (ARPROTCVM),
  .arvalid_cvm_axim                                 (ARVALIDCVM),
  .arready_cvm_axim                                 (ARREADYCVM),
  .rid_cvm_axim                                     (RIDCVM),
  .rdata_cvm_axim                                   (RDATACVM),
  .rresp_cvm_axim                                   (RRESPCVM),
  .rlast_cvm_axim                                   (RLASTCVM),
  .rvalid_cvm_axim                                  (RVALIDCVM),
  .rready_cvm_axim                                  (RREADYCVM),
  .awuser_cvm_axim                                  ({AWMMUSIDCVM,AWUSERCVM}),
  .aruser_cvm_axim                                  ({ARMMUSIDCVM,ARUSERCVM}),
  .awqos_cvm_axim                                   (AWQOSCVM),
  .arqos_cvm_axim                                   (ARQOSCVM),


 

  .awid_expmstr0_axim                 (AWIDEXPMST0),
  .awaddr_expmstr0_axim               (AWADDREXPMST0),
  .awlen_expmstr0_axim                (AWLENEXPMST0),
  .awsize_expmstr0_axim               (AWSIZEEXPMST0),
  .awburst_expmstr0_axim              (AWBURSTEXPMST0),
  .awlock_expmstr0_axim               (AWLOCKEXPMST0),
  .awcache_expmstr0_axim              (AWCACHEEXPMST0),
  .awprot_expmstr0_axim               (AWPROTEXPMST0),
  .awvalid_expmstr0_axim              (AWVALIDEXPMST0),
  .awakeup_expmstr0_axim              (AWAKEUPEXPMST0),
  .awready_expmstr0_axim              (AWREADYEXPMST0),
  .wdata_expmstr0_axim                (WDATAEXPMST0),
  .wstrb_expmstr0_axim                (WSTRBEXPMST0),
  .wlast_expmstr0_axim                (WLASTEXPMST0),
  .wvalid_expmstr0_axim               (WVALIDEXPMST0),
  .wready_expmstr0_axim               (WREADYEXPMST0),
  .bid_expmstr0_axim                  (BIDEXPMST0),
  .bresp_expmstr0_axim                (BRESPEXPMST0),
  .bvalid_expmstr0_axim               (BVALIDEXPMST0),
  .bready_expmstr0_axim               (BREADYEXPMST0),
  .arid_expmstr0_axim                 (ARIDEXPMST0),
  .araddr_expmstr0_axim               (ARADDREXPMST0),
  .arlen_expmstr0_axim                (ARLENEXPMST0),
  .arsize_expmstr0_axim               (ARSIZEEXPMST0),
  .arburst_expmstr0_axim              (ARBURSTEXPMST0),
  .arlock_expmstr0_axim               (ARLOCKEXPMST0),
  .arcache_expmstr0_axim              (ARCACHEEXPMST0),
  .arprot_expmstr0_axim               (ARPROTEXPMST0),
  .arvalid_expmstr0_axim              (ARVALIDEXPMST0),
  .arready_expmstr0_axim              (ARREADYEXPMST0),
  .rid_expmstr0_axim                  (RIDEXPMST0),
  .rdata_expmstr0_axim                (RDATAEXPMST0),
  .rresp_expmstr0_axim                (RRESPEXPMST0),
  .rlast_expmstr0_axim                (RLASTEXPMST0),
  .rvalid_expmstr0_axim               (RVALIDEXPMST0),
  .rready_expmstr0_axim               (RREADYEXPMST0),
  .awuser_expmstr0_axim               ({AWMMUSIDEXPMST0,AWUSEREXPMST0}),
  .aruser_expmstr0_axim               ({ARMMUSIDEXPMST0,ARUSEREXPMST0}),
  .awqos_expmstr0_axim                (AWQOSEXPMST0),
  .arqos_expmstr0_axim                (ARQOSEXPMST0),

 

  .awid_expmstr1_axim                 (AWIDEXPMST1),
  .awaddr_expmstr1_axim               (AWADDREXPMST1),
  .awlen_expmstr1_axim                (AWLENEXPMST1),
  .awsize_expmstr1_axim               (AWSIZEEXPMST1),
  .awburst_expmstr1_axim              (AWBURSTEXPMST1),
  .awlock_expmstr1_axim               (AWLOCKEXPMST1),
  .awcache_expmstr1_axim              (AWCACHEEXPMST1),
  .awprot_expmstr1_axim               (AWPROTEXPMST1),
  .awvalid_expmstr1_axim              (AWVALIDEXPMST1),
  .awakeup_expmstr1_axim              (AWAKEUPEXPMST1),
  .awready_expmstr1_axim              (AWREADYEXPMST1),
  .wdata_expmstr1_axim                (WDATAEXPMST1),
  .wstrb_expmstr1_axim                (WSTRBEXPMST1),
  .wlast_expmstr1_axim                (WLASTEXPMST1),
  .wvalid_expmstr1_axim               (WVALIDEXPMST1),
  .wready_expmstr1_axim               (WREADYEXPMST1),
  .bid_expmstr1_axim                  (BIDEXPMST1),
  .bresp_expmstr1_axim                (BRESPEXPMST1),
  .bvalid_expmstr1_axim               (BVALIDEXPMST1),
  .bready_expmstr1_axim               (BREADYEXPMST1),
  .arid_expmstr1_axim                 (ARIDEXPMST1),
  .araddr_expmstr1_axim               (ARADDREXPMST1),
  .arlen_expmstr1_axim                (ARLENEXPMST1),
  .arsize_expmstr1_axim               (ARSIZEEXPMST1),
  .arburst_expmstr1_axim              (ARBURSTEXPMST1),
  .arlock_expmstr1_axim               (ARLOCKEXPMST1),
  .arcache_expmstr1_axim              (ARCACHEEXPMST1),
  .arprot_expmstr1_axim               (ARPROTEXPMST1),
  .arvalid_expmstr1_axim              (ARVALIDEXPMST1),
  .arready_expmstr1_axim              (ARREADYEXPMST1),
  .rid_expmstr1_axim                  (RIDEXPMST1),
  .rdata_expmstr1_axim                (RDATAEXPMST1),
  .rresp_expmstr1_axim                (RRESPEXPMST1),
  .rlast_expmstr1_axim                (RLASTEXPMST1),
  .rvalid_expmstr1_axim               (RVALIDEXPMST1),
  .rready_expmstr1_axim               (RREADYEXPMST1),
  .awuser_expmstr1_axim               ({AWMMUSIDEXPMST1,AWUSEREXPMST1}),
  .aruser_expmstr1_axim               ({ARMMUSIDEXPMST1,ARUSEREXPMST1}),
  .awqos_expmstr1_axim                (AWQOSEXPMST1),
  .arqos_expmstr1_axim                (ARQOSEXPMST1),

  
  
  .awid_ocvm_axim                                    (AWIDOCVM),
  .awaddr_ocvm_axim                                  (AWADDROCVM),
  .awlen_ocvm_axim                                   (AWLENOCVM),
  .awsize_ocvm_axim                                  (AWSIZEOCVM),
  .awburst_ocvm_axim                                 (AWBURSTOCVM),
  .awlock_ocvm_axim                                  (AWLOCKOCVM),
  .awcache_ocvm_axim                                 (AWCACHEOCVM),
  .awprot_ocvm_axim                                  (AWPROTOCVM),
  .awvalid_ocvm_axim                                 (AWVALIDOCVM),
  .awakeup_ocvm_axim                                 (AWAKEUPOCVM),
  .awready_ocvm_axim                                 (AWREADYOCVM),
  .wdata_ocvm_axim                                   (WDATAOCVM),
  .wstrb_ocvm_axim                                   (WSTRBOCVM),
  .wlast_ocvm_axim                                   (WLASTOCVM),
  .wvalid_ocvm_axim                                  (WVALIDOCVM),
  .wready_ocvm_axim                                  (WREADYOCVM),
  .bid_ocvm_axim                                     (BIDOCVM),
  .bresp_ocvm_axim                                   (BRESPOCVM),
  .bvalid_ocvm_axim                                  (BVALIDOCVM),
  .bready_ocvm_axim                                  (BREADYOCVM),
  .arid_ocvm_axim                                    (ARIDOCVM),
  .araddr_ocvm_axim                                  (ARADDROCVM),
  .arlen_ocvm_axim                                   (ARLENOCVM),
  .arsize_ocvm_axim                                  (ARSIZEOCVM),
  .arburst_ocvm_axim                                 (ARBURSTOCVM),
  .arlock_ocvm_axim                                  (ARLOCKOCVM),
  .arcache_ocvm_axim                                 (ARCACHEOCVM),
  .arprot_ocvm_axim                                  (ARPROTOCVM),
  .arvalid_ocvm_axim                                 (ARVALIDOCVM),
  .arready_ocvm_axim                                 (ARREADYOCVM),
  .rid_ocvm_axim                                     (RIDOCVM),
  .rdata_ocvm_axim                                   (RDATAOCVM),
  .rresp_ocvm_axim                                   (RRESPOCVM),
  .rlast_ocvm_axim                                   (RLASTOCVM),
  .rvalid_ocvm_axim                                  (RVALIDOCVM),
  .rready_ocvm_axim                                  (RREADYOCVM),
  .awuser_ocvm_axim                                  ({AWMMUSIDOCVM,AWUSEROCVM}),
  .aruser_ocvm_axim                                  ({ARMMUSIDOCVM,ARUSEROCVM}),
  .awqos_ocvm_axim                                   (AWQOSOCVM),
  .arqos_ocvm_axim                                   (ARQOSOCVM),

 
                              
  .awid_expslv0_axis                     (AWIDEXPSLV0),
  .awaddr_expslv0_axis                   (AWADDREXPSLV0),
  .awlen_expslv0_axis                    (AWLENEXPSLV0),
  .awsize_expslv0_axis                   (AWSIZEEXPSLV0),
  .awburst_expslv0_axis                  (AWBURSTEXPSLV0),
  .awlock_expslv0_axis                   (AWLOCKEXPSLV0),
  .awcache_expslv0_axis                  (AWCACHEEXPSLV0),
  .awprot_expslv0_axis                   (AWPROTEXPSLV0),
  .awvalid_expslv0_axis                  (AWVALIDEXPSLV0),
  .awakeup_expslv0_axis                  (AWAKEUPEXPSLV0),
  .awready_expslv0_axis                  (AWREADYEXPSLV0),
  .wdata_expslv0_axis                    (WDATAEXPSLV0),
  .wstrb_expslv0_axis                    (WSTRBEXPSLV0),
  .wlast_expslv0_axis                    (WLASTEXPSLV0),
  .wvalid_expslv0_axis                   (WVALIDEXPSLV0),
  .wready_expslv0_axis                   (WREADYEXPSLV0),
  .bid_expslv0_axis                      (BIDEXPSLV0),
  .bresp_expslv0_axis                    (BRESPEXPSLV0),
  .bvalid_expslv0_axis                   (BVALIDEXPSLV0),
  .bready_expslv0_axis                   (BREADYEXPSLV0),
  .arid_expslv0_axis                     (ARIDEXPSLV0),
  .araddr_expslv0_axis                   (ARADDREXPSLV0),
  .arlen_expslv0_axis                    (ARLENEXPSLV0),
  .arsize_expslv0_axis                   (ARSIZEEXPSLV0),
  .arburst_expslv0_axis                  (ARBURSTEXPSLV0),
  .arlock_expslv0_axis                   (ARLOCKEXPSLV0),
  .arcache_expslv0_axis                  (ARCACHEEXPSLV0),
  .arprot_expslv0_axis                   (ARPROTEXPSLV0),
  .arvalid_expslv0_axis                  (ARVALIDEXPSLV0),
  .arready_expslv0_axis                  (ARREADYEXPSLV0),
  .rid_expslv0_axis                      (RIDEXPSLV0),
  .rdata_expslv0_axis                    (RDATAEXPSLV0),
  .rresp_expslv0_axis                    (RRESPEXPSLV0),
  .rlast_expslv0_axis                    (RLASTEXPSLV0),
  .rvalid_expslv0_axis                   (RVALIDEXPSLV0),
  .rready_expslv0_axis                   (RREADYEXPSLV0),
  .awuser_expslv0_axis                   ({AWMMUSIDEXPSLV0,AWUSEREXPSLV0}),
  .aruser_expslv0_axis                   ({ARMMUSIDEXPSLV0,ARUSEREXPSLV0}),
  .awqos_expslv0_axis                    (AWQOSEXPSLV0),
  .arqos_expslv0_axis                    (ARQOSEXPSLV0),
 
                              
  .awid_expslv1_axis                     (AWIDEXPSLV1),
  .awaddr_expslv1_axis                   (AWADDREXPSLV1),
  .awlen_expslv1_axis                    (AWLENEXPSLV1),
  .awsize_expslv1_axis                   (AWSIZEEXPSLV1),
  .awburst_expslv1_axis                  (AWBURSTEXPSLV1),
  .awlock_expslv1_axis                   (AWLOCKEXPSLV1),
  .awcache_expslv1_axis                  (AWCACHEEXPSLV1),
  .awprot_expslv1_axis                   (AWPROTEXPSLV1),
  .awvalid_expslv1_axis                  (AWVALIDEXPSLV1),
  .awakeup_expslv1_axis                  (AWAKEUPEXPSLV1),
  .awready_expslv1_axis                  (AWREADYEXPSLV1),
  .wdata_expslv1_axis                    (WDATAEXPSLV1),
  .wstrb_expslv1_axis                    (WSTRBEXPSLV1),
  .wlast_expslv1_axis                    (WLASTEXPSLV1),
  .wvalid_expslv1_axis                   (WVALIDEXPSLV1),
  .wready_expslv1_axis                   (WREADYEXPSLV1),
  .bid_expslv1_axis                      (BIDEXPSLV1),
  .bresp_expslv1_axis                    (BRESPEXPSLV1),
  .bvalid_expslv1_axis                   (BVALIDEXPSLV1),
  .bready_expslv1_axis                   (BREADYEXPSLV1),
  .arid_expslv1_axis                     (ARIDEXPSLV1),
  .araddr_expslv1_axis                   (ARADDREXPSLV1),
  .arlen_expslv1_axis                    (ARLENEXPSLV1),
  .arsize_expslv1_axis                   (ARSIZEEXPSLV1),
  .arburst_expslv1_axis                  (ARBURSTEXPSLV1),
  .arlock_expslv1_axis                   (ARLOCKEXPSLV1),
  .arcache_expslv1_axis                  (ARCACHEEXPSLV1),
  .arprot_expslv1_axis                   (ARPROTEXPSLV1),
  .arvalid_expslv1_axis                  (ARVALIDEXPSLV1),
  .arready_expslv1_axis                  (ARREADYEXPSLV1),
  .rid_expslv1_axis                      (RIDEXPSLV1),
  .rdata_expslv1_axis                    (RDATAEXPSLV1),
  .rresp_expslv1_axis                    (RRESPEXPSLV1),
  .rlast_expslv1_axis                    (RLASTEXPSLV1),
  .rvalid_expslv1_axis                   (RVALIDEXPSLV1),
  .rready_expslv1_axis                   (RREADYEXPSLV1),
  .awuser_expslv1_axis                   ({AWMMUSIDEXPSLV1,AWUSEREXPSLV1}),
  .aruser_expslv1_axis                   ({ARMMUSIDEXPSLV1,ARUSEREXPSLV1}),
  .awqos_expslv1_axis                    (AWQOSEXPSLV1),
  .arqos_expslv1_axis                    (ARQOSEXPSLV1),

  .extdbg_async_req                                    (extdbg_async_req),
  .extdbg_async_req_payload                            (extdbg_async_req_payload),
  .extdbg_async_resp_payload                           (extdbg_async_resp_payload),
  .extdbg_async_ack                                    (extdbg_async_ack),
 
  .aonperiph_async_req                                 (aonperiph_async_req),
  .aonperiph_async_req_payload                         (aonperiph_async_req_payload),
  .aonperiph_async_resp_payload                        (aonperiph_async_resp_payload),
  .aonperiph_async_ack                                 (aonperiph_async_ack),

  .bootreg_async_req                                   (bootreg_async_req),
  .bootreg_async_req_payload                           (bootreg_async_req_payload),
  .bootreg_async_resp_payload                          (bootreg_async_resp_payload),
  .bootreg_async_ack                                   (bootreg_async_ack),
                                                       

  .qactive_extsys0_mhupwrreq             (extsys0mhupwrreqactiveq_systop),

  .slvmustacceptreqn_async_eh0           (slvmustacceptreqn_async_eh0),
  .slvcandenyreqn_async_eh0              (slvcandenyreqn_async_eh0),
  .slvacceptn_async_eh0                  (slvacceptn_async_eh0),
  .slvdeny_async_eh0                     (slvdeny_async_eh0),
  .si_to_mi_wakeup_async_eh0             (si_to_mi_wakeup_async_eh0),
  .mi_to_si_wakeup_async_eh0             (mi_to_si_wakeup_async_eh0),
  .aw_wr_ptr_async_eh0                   (aw_wr_ptr_async_eh0),
  .aw_rd_ptr_async_eh0                   (aw_rd_ptr_async_eh0),
  .aw_payld_async_eh0                    (aw_payld_async_eh0),
  .w_wr_ptr_async_eh0                    (w_wr_ptr_async_eh0),
  .w_rd_ptr_async_eh0                    (w_rd_ptr_async_eh0),
  .w_payld_async_eh0                     (w_payld_async_eh0),
  .b_wr_ptr_async_eh0                    (b_wr_ptr_async_eh0),
  .b_rd_ptr_async_eh0                    (b_rd_ptr_async_eh0),
  .b_payld_async_eh0                     (b_payld_async_eh0),
  .ar_wr_ptr_async_eh0                   (ar_wr_ptr_async_eh0),
  .ar_rd_ptr_async_eh0                   (ar_rd_ptr_async_eh0),
  .ar_payld_async_eh0                    (ar_payld_async_eh0),
  .r_wr_ptr_async_eh0                    (r_wr_ptr_async_eh0),
  .r_rd_ptr_async_eh0                    (r_rd_ptr_async_eh0),
  .r_payld_async_eh0                     (r_payld_async_eh0),
                                          
  .apb_async_req_eh0_mhu_esh_0           (apb_async_req_eh0_mhu_esh_0),
  .apb_async_req_payload_eh0_mhu_esh_0   (apb_async_req_payload_eh0_mhu_esh_0),
  .apb_async_resp_payload_eh0_mhu_esh_0  (apb_async_resp_payload_eh0_mhu_esh_0),
  .apb_async_ack_eh0_mhu_esh_0           (apb_async_ack_eh0_mhu_esh_0),
  .recawake_async_eh0_mhu_esh_0          (recawake_async_eh0_mhu_esh_0),
  .recwakeup_async_eh0_mhu_esh_0         (recwakeup_async_eh0_mhu_esh_0),
  .edge_async_req_eh0_mhu_esh_0          (edge_async_req_eh0_mhu_esh_0),
  .edge_async_ack_eh0_mhu_esh_0          (edge_async_ack_eh0_mhu_esh_0),
                                          
  .apb_async_req_eh0_mhu_hes_0           (apb_async_req_eh0_mhu_hes_0),
  .apb_async_req_payload_eh0_mhu_hes_0   (apb_async_req_payload_eh0_mhu_hes_0),
  .apb_async_resp_payload_eh0_mhu_hes_0  (apb_async_resp_payload_eh0_mhu_hes_0),
  .apb_async_ack_eh0_mhu_hes_0           (apb_async_ack_eh0_mhu_hes_0),
  .recawake_async_eh0_mhu_hes_0          (recawake_async_eh0_mhu_hes_0),
  .recwakeup_async_eh0_mhu_hes_0         (recwakeup_async_eh0_mhu_hes_0),
  .edge_async_req_eh0_mhu_hes_0          (edge_async_req_eh0_mhu_hes_0),
  .edge_async_ack_eh0_mhu_hes_0          (edge_async_ack_eh0_mhu_hes_0),
  
    
  .apb_async_req_eh0_mhu_esh_1           (apb_async_req_eh0_mhu_esh_1),
  .apb_async_req_payload_eh0_mhu_esh_1   (apb_async_req_payload_eh0_mhu_esh_1),
  .apb_async_resp_payload_eh0_mhu_esh_1  (apb_async_resp_payload_eh0_mhu_esh_1),
  .apb_async_ack_eh0_mhu_esh_1           (apb_async_ack_eh0_mhu_esh_1),
  .recawake_async_eh0_mhu_esh_1          (recawake_async_eh0_mhu_esh_1),
  .recwakeup_async_eh0_mhu_esh_1         (recwakeup_async_eh0_mhu_esh_1),
  .edge_async_req_eh0_mhu_esh_1          (edge_async_req_eh0_mhu_esh_1),
  .edge_async_ack_eh0_mhu_esh_1          (edge_async_ack_eh0_mhu_esh_1),
                                          
  .apb_async_req_eh0_mhu_hes_1           (apb_async_req_eh0_mhu_hes_1),
  .apb_async_req_payload_eh0_mhu_hes_1   (apb_async_req_payload_eh0_mhu_hes_1),
  .apb_async_resp_payload_eh0_mhu_hes_1  (apb_async_resp_payload_eh0_mhu_hes_1),
  .apb_async_ack_eh0_mhu_hes_1           (apb_async_ack_eh0_mhu_hes_1),
  .recawake_async_eh0_mhu_hes_1          (recawake_async_eh0_mhu_hes_1),
  .recwakeup_async_eh0_mhu_hes_1         (recwakeup_async_eh0_mhu_hes_1),
  .edge_async_req_eh0_mhu_hes_1          (edge_async_req_eh0_mhu_hes_1),
  .edge_async_ack_eh0_mhu_hes_1          (edge_async_ack_eh0_mhu_hes_1),
  
  .hes_0_eh0_mhuint                      (hes_0_eh0_mhuint),
  .esh_0_eh0_mhuint                      (esh_0_eh0_mhuint),
    .hes_1_eh0_mhuint                      (hes_1_eh0_mhuint),
  .esh_1_eh0_mhuint                      (esh_1_eh0_mhuint),
  

  .qactive_extsys1_mhupwrreq             (extsys1mhupwrreqactiveq_systop),

  .slvmustacceptreqn_async_eh1           (slvmustacceptreqn_async_eh1),
  .slvcandenyreqn_async_eh1              (slvcandenyreqn_async_eh1),
  .slvacceptn_async_eh1                  (slvacceptn_async_eh1),
  .slvdeny_async_eh1                     (slvdeny_async_eh1),
  .si_to_mi_wakeup_async_eh1             (si_to_mi_wakeup_async_eh1),
  .mi_to_si_wakeup_async_eh1             (mi_to_si_wakeup_async_eh1),
  .aw_wr_ptr_async_eh1                   (aw_wr_ptr_async_eh1),
  .aw_rd_ptr_async_eh1                   (aw_rd_ptr_async_eh1),
  .aw_payld_async_eh1                    (aw_payld_async_eh1),
  .w_wr_ptr_async_eh1                    (w_wr_ptr_async_eh1),
  .w_rd_ptr_async_eh1                    (w_rd_ptr_async_eh1),
  .w_payld_async_eh1                     (w_payld_async_eh1),
  .b_wr_ptr_async_eh1                    (b_wr_ptr_async_eh1),
  .b_rd_ptr_async_eh1                    (b_rd_ptr_async_eh1),
  .b_payld_async_eh1                     (b_payld_async_eh1),
  .ar_wr_ptr_async_eh1                   (ar_wr_ptr_async_eh1),
  .ar_rd_ptr_async_eh1                   (ar_rd_ptr_async_eh1),
  .ar_payld_async_eh1                    (ar_payld_async_eh1),
  .r_wr_ptr_async_eh1                    (r_wr_ptr_async_eh1),
  .r_rd_ptr_async_eh1                    (r_rd_ptr_async_eh1),
  .r_payld_async_eh1                     (r_payld_async_eh1),
                                          
  .apb_async_req_eh1_mhu_esh_0           (apb_async_req_eh1_mhu_esh_0),
  .apb_async_req_payload_eh1_mhu_esh_0   (apb_async_req_payload_eh1_mhu_esh_0),
  .apb_async_resp_payload_eh1_mhu_esh_0  (apb_async_resp_payload_eh1_mhu_esh_0),
  .apb_async_ack_eh1_mhu_esh_0           (apb_async_ack_eh1_mhu_esh_0),
  .recawake_async_eh1_mhu_esh_0          (recawake_async_eh1_mhu_esh_0),
  .recwakeup_async_eh1_mhu_esh_0         (recwakeup_async_eh1_mhu_esh_0),
  .edge_async_req_eh1_mhu_esh_0          (edge_async_req_eh1_mhu_esh_0),
  .edge_async_ack_eh1_mhu_esh_0          (edge_async_ack_eh1_mhu_esh_0),
                                          
  .apb_async_req_eh1_mhu_hes_0           (apb_async_req_eh1_mhu_hes_0),
  .apb_async_req_payload_eh1_mhu_hes_0   (apb_async_req_payload_eh1_mhu_hes_0),
  .apb_async_resp_payload_eh1_mhu_hes_0  (apb_async_resp_payload_eh1_mhu_hes_0),
  .apb_async_ack_eh1_mhu_hes_0           (apb_async_ack_eh1_mhu_hes_0),
  .recawake_async_eh1_mhu_hes_0          (recawake_async_eh1_mhu_hes_0),
  .recwakeup_async_eh1_mhu_hes_0         (recwakeup_async_eh1_mhu_hes_0),
  .edge_async_req_eh1_mhu_hes_0          (edge_async_req_eh1_mhu_hes_0),
  .edge_async_ack_eh1_mhu_hes_0          (edge_async_ack_eh1_mhu_hes_0),
  
    
  .apb_async_req_eh1_mhu_esh_1           (apb_async_req_eh1_mhu_esh_1),
  .apb_async_req_payload_eh1_mhu_esh_1   (apb_async_req_payload_eh1_mhu_esh_1),
  .apb_async_resp_payload_eh1_mhu_esh_1  (apb_async_resp_payload_eh1_mhu_esh_1),
  .apb_async_ack_eh1_mhu_esh_1           (apb_async_ack_eh1_mhu_esh_1),
  .recawake_async_eh1_mhu_esh_1          (recawake_async_eh1_mhu_esh_1),
  .recwakeup_async_eh1_mhu_esh_1         (recwakeup_async_eh1_mhu_esh_1),
  .edge_async_req_eh1_mhu_esh_1          (edge_async_req_eh1_mhu_esh_1),
  .edge_async_ack_eh1_mhu_esh_1          (edge_async_ack_eh1_mhu_esh_1),
                                          
  .apb_async_req_eh1_mhu_hes_1           (apb_async_req_eh1_mhu_hes_1),
  .apb_async_req_payload_eh1_mhu_hes_1   (apb_async_req_payload_eh1_mhu_hes_1),
  .apb_async_resp_payload_eh1_mhu_hes_1  (apb_async_resp_payload_eh1_mhu_hes_1),
  .apb_async_ack_eh1_mhu_hes_1           (apb_async_ack_eh1_mhu_hes_1),
  .recawake_async_eh1_mhu_hes_1          (recawake_async_eh1_mhu_hes_1),
  .recwakeup_async_eh1_mhu_hes_1         (recwakeup_async_eh1_mhu_hes_1),
  .edge_async_req_eh1_mhu_hes_1          (edge_async_req_eh1_mhu_hes_1),
  .edge_async_ack_eh1_mhu_hes_1          (edge_async_ack_eh1_mhu_hes_1),
  
  .hes_0_eh1_mhuint                      (hes_0_eh1_mhuint),
  .esh_0_eh1_mhuint                      (esh_0_eh1_mhuint),
    .hes_1_eh1_mhuint                      (hes_1_eh1_mhuint),
  .esh_1_eh1_mhuint                      (esh_1_eh1_mhuint),
  
  .slvmustacceptreqn_async_secenc                      (slvmustacceptreqn_async_secenc),
  .slvcandenyreqn_async_secenc                         (slvcandenyreqn_async_secenc),
  .slvacceptn_async_secenc                             (slvacceptn_async_secenc),
  .slvdeny_async_secenc                                (slvdeny_async_secenc),
  .si_to_mi_wakeup_async_secenc                        (si_to_mi_wakeup_async_secenc),
  .mi_to_si_wakeup_async_secenc                        (mi_to_si_wakeup_async_secenc),
  .aw_wr_ptr_async_secenc                              (aw_wr_ptr_async_secenc),
  .aw_rd_ptr_async_secenc                              (aw_rd_ptr_async_secenc),
  .aw_payld_async_secenc                               (aw_payld_async_secenc),
  .w_wr_ptr_async_secenc                               (w_wr_ptr_async_secenc),
  .w_rd_ptr_async_secenc                               (w_rd_ptr_async_secenc),
  .w_payld_async_secenc                                (w_payld_async_secenc),
  .b_wr_ptr_async_secenc                               (b_wr_ptr_async_secenc),
  .b_rd_ptr_async_secenc                               (b_rd_ptr_async_secenc),
  .b_payld_async_secenc                                (b_payld_async_secenc),
  .ar_wr_ptr_async_secenc                              (ar_wr_ptr_async_secenc),
  .ar_rd_ptr_async_secenc                              (ar_rd_ptr_async_secenc),
  .ar_payld_async_secenc                               (ar_payld_async_secenc),
  .r_wr_ptr_async_secenc                               (r_wr_ptr_async_secenc),
  .r_rd_ptr_async_secenc                               (r_rd_ptr_async_secenc),
  .r_payld_async_secenc                                (r_payld_async_secenc),
  
  .apb_async_req_seh0_mhu                              (apb_async_req_seh0_mhu),
  .apb_async_req_payload_seh0_mhu                      (apb_async_req_payload_seh0_mhu),
  .apb_async_resp_payload_seh0_mhu                     (apb_async_resp_payload_seh0_mhu),
  .apb_async_ack_seh0_mhu                              (apb_async_ack_seh0_mhu),
  .recawake_async_seh0_mhu                             (recawake_async_seh0_mhu),
  .recwakeup_async_seh0_mhu                            (recwakeup_async_seh0_mhu),
  .edge_async_req_seh0_mhu                             (edge_async_req_seh0_mhu),
  .edge_async_ack_seh0_mhu                             (edge_async_ack_seh0_mhu),
                                          
  .apb_async_req_hse0_mhu                              (apb_async_req_hse0_mhu),
  .apb_async_req_payload_hse0_mhu                      (apb_async_req_payload_hse0_mhu),
  .apb_async_resp_payload_hse0_mhu                     (apb_async_resp_payload_hse0_mhu),
  .apb_async_ack_hse0_mhu                              (apb_async_ack_hse0_mhu),
  .recawake_async_hse0_mhu                             (recawake_async_hse0_mhu),
  .recwakeup_async_hse0_mhu                            (recwakeup_async_hse0_mhu),
  .edge_async_req_hse0_mhu                             (edge_async_req_hse0_mhu),
  .edge_async_ack_hse0_mhu                             (edge_async_ack_hse0_mhu),
                                          
  .apb_async_req_seh1_mhu                              (apb_async_req_seh1_mhu),
  .apb_async_req_payload_seh1_mhu                      (apb_async_req_payload_seh1_mhu),
  .apb_async_resp_payload_seh1_mhu                     (apb_async_resp_payload_seh1_mhu),
  .apb_async_ack_seh1_mhu                              (apb_async_ack_seh1_mhu),
  .recawake_async_seh1_mhu                             (recawake_async_seh1_mhu),
  .recwakeup_async_seh1_mhu                            (recwakeup_async_seh1_mhu),
  .edge_async_req_seh1_mhu                             (edge_async_req_seh1_mhu),
  .edge_async_ack_seh1_mhu                             (edge_async_ack_seh1_mhu),
                                          
  .apb_async_req_hse1_mhu                              (apb_async_req_hse1_mhu),
  .apb_async_req_payload_hse1_mhu                      (apb_async_req_payload_hse1_mhu),
  .apb_async_resp_payload_hse1_mhu                     (apb_async_resp_payload_hse1_mhu),
  .apb_async_ack_hse1_mhu                              (apb_async_ack_hse1_mhu),
  .recawake_async_hse1_mhu                             (recawake_async_hse1_mhu),
  .recwakeup_async_hse1_mhu                            (recwakeup_async_hse1_mhu),
  .edge_async_req_hse1_mhu                             (edge_async_req_hse1_mhu),
  .edge_async_ack_hse1_mhu                             (edge_async_ack_hse1_mhu),

  .hse0_mhuint                                         (secenc_mhu0_sender_cirq),
  .seh0_mhuint                                         (secenc_mhu0_receiver_cirq),
  .hse1_mhuint                                         (secenc_mhu1_sender_cirq),
  .seh1_mhuint                                         (secenc_mhu1_receiver_cirq),

  .tsvalueb                                            (HOSTTSVALUEB),
  .host_cntvalueg                                      (HOSTCNTVALUEG),

  .hostcpu_dbgen                                       (host_cpu_dbgen[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_spiden                                      (host_cpu_spiden[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_niden                                       (host_cpu_niden[HOST_CPU_NUM_CORES-1:0]),
  .hostcpu_spniden                                     (host_cpu_spniden[HOST_CPU_NUM_CORES-1:0]),

  .hostcpu_dftramhold                                  (DFTRAMHOLD), 

  .hostcpu_ctichin                                     (hostcpuctichin_pulse_req ),
  .hostcpu_ctichinack                                  (hostcpuctichin_pulse_ack ),
  .hostcpu_ctichout                                    (hostcpuctichout_pulse_req),
  .hostcpu_ctichoutack                                 (hostcpuctichout_pulse_ack),
    
  .debug_hostcpu_async_req                             (hostcpu_async_req),
  .debug_hostcpu_async_req_payload                     (hostcpu_async_req_payload),
  .debug_hostcpu_async_resp_payload                    (hostcpu_async_resp_payload),
  .debug_hostcpu_async_ack                             (hostcpu_async_ack),
  
  .debug_hostcpu_atb_fwd_data                          (hostcpu_atb_fwd_data),
  .debug_hostcpu_wr_pointer_gray                       (hostcpu_wr_pointer_gray),
  .debug_hostcpu_rd_pointer_gray                       (hostcpu_rd_pointer_gray),
  .debug_hostcpu_flush_req                             (hostcpu_flush_req),
  .debug_hostcpu_flush_done                            (hostcpu_flush_done),
  .debug_hostcpu_sync_clear                            (hostcpu_sync_clear),
  .debug_hostcpu_sync_done                             (hostcpu_sync_done),
  .debug_hostcpu_syncreq_async_req                     (hostcpu_syncreq_async_req),
  .debug_hostcpu_syncreq_async_ack                     (hostcpu_syncreq_async_ack),

  .hostcpu_dftmcphold                                  (DFTMCPHOLD), 

  .debug_axis_slvmustacceptreqn_async                  (debug_axis_slvmustacceptreqn_async),
  .debug_axis_slvcandenyreqn_async                     (debug_axis_slvcandenyreqn_async),
  .debug_axis_slvacceptn_async                         (debug_axis_slvacceptn_async),
  .debug_axis_slvdeny_async                            (debug_axis_slvdeny_async),
                                         
  .debug_axis_si_to_mi_wakeup_async                    (debug_axis_si_to_mi_wakeup_async),
  .debug_axis_mi_to_si_wakeup_async                    (debug_axis_mi_to_si_wakeup_async),
  .debug_axis_aw_wr_ptr_async                          (debug_axis_aw_wr_ptr_async),
  .debug_axis_aw_rd_ptr_async                          (debug_axis_aw_rd_ptr_async),
  .debug_axis_aw_payld_async                           (debug_axis_aw_payld_async),
  .debug_axis_w_wr_ptr_async                           (debug_axis_w_wr_ptr_async),
  .debug_axis_w_rd_ptr_async                           (debug_axis_w_rd_ptr_async),
  .debug_axis_w_payld_async                            (debug_axis_w_payld_async),
  .debug_axis_b_wr_ptr_async                           (debug_axis_b_wr_ptr_async),
  .debug_axis_b_rd_ptr_async                           (debug_axis_b_rd_ptr_async),
  .debug_axis_b_payld_async                            (debug_axis_b_payld_async),
  .debug_axis_ar_wr_ptr_async                          (debug_axis_ar_wr_ptr_async),
  .debug_axis_ar_rd_ptr_async                          (debug_axis_ar_rd_ptr_async),
  .debug_axis_ar_payld_async                           (debug_axis_ar_payld_async),
  .debug_axis_r_wr_ptr_async                           (debug_axis_r_wr_ptr_async),
  .debug_axis_r_rd_ptr_async                           (debug_axis_r_rd_ptr_async),
  .debug_axis_r_payld_async                            (debug_axis_r_payld_async),
                                         
  .stm_slvmustacceptreqn_async                         (stm_slvmustacceptreqn_async),
  .stm_slvcandenyreqn_async                            (stm_slvcandenyreqn_async),
  .stm_slvacceptn_async                                (stm_slvacceptn_async),
  .stm_slvdeny_async                                   (stm_slvdeny_async),
  .stm_si_to_mi_wakeup_async                           (stm_si_to_mi_wakeup_async),
  .stm_mi_to_si_wakeup_async                           (stm_mi_to_si_wakeup_async),
  .stm_aw_wr_ptr_async                                 (stm_aw_wr_ptr_async),
  .stm_aw_rd_ptr_async                                 (stm_aw_rd_ptr_async),
  .stm_aw_payld_async                                  (stm_aw_payld_async),
  .stm_w_wr_ptr_async                                  (stm_w_wr_ptr_async),
  .stm_w_rd_ptr_async                                  (stm_w_rd_ptr_async),
  .stm_w_payld_async                                   (stm_w_payld_async),
  .stm_b_wr_ptr_async                                  (stm_b_wr_ptr_async),
  .stm_b_rd_ptr_async                                  (stm_b_rd_ptr_async),
  .stm_b_payld_async                                   (stm_b_payld_async),
  .stm_ar_wr_ptr_async                                 (stm_ar_wr_ptr_async),
  .stm_ar_rd_ptr_async                                 (stm_ar_rd_ptr_async),
  .stm_ar_payld_async                                  (stm_ar_payld_async),
  .stm_r_wr_ptr_async                                  (stm_r_wr_ptr_async),
  .stm_r_rd_ptr_async                                  (stm_r_rd_ptr_async),
  .stm_r_payld_async                                   (stm_r_payld_async),
  
  .qreqn_systop_egress_dbgtop                          (qreqn_systop_egress_dbgtop),
  .qacceptn_systop_egress_dbgtop                       (qacceptn_systop_egress_dbgtop),
  .qdeny_systop_egress_dbgtop                          (qdeny_systop_egress_dbgtop),
  .qactive_systop_egress_dbgtop                        (qactive_systop_egress_dbgtop),

  
  .clustop_dependency_qreqn                            (clustop_dependency_qreqn),
  .clustop_dependency_qacceptn                         (clustop_dependency_qacceptn),
  .clustop_dependency_qdeny                            (clustop_dependency_qdeny),
  .clustop_dependency_qactive                          (clustop_dependency_qactive),
    
                                          
  .hostcpu_dbgtrace_egress_comb_qreqn                  (qreqn_clustop_egress_dbgtop),
  .hostcpu_dbgtrace_egress_comb_qacceptn               (qacceptn_clustop_egress_dbgtop),
  .hostcpu_dbgtrace_egress_comb_qdeny                  (qdeny_clustop_egress_dbgtop),
  .hostcpu_dbgtrace_egress_comb_qactive                (qactive_clustop_egress_dbgtop),
  .hostcpu_dbgtrace_egress_comb1_qreqn                 (qreqn_clustop_egress_comb1_dbgtop),
  .hostcpu_dbgtrace_egress_comb1_qacceptn              (qacceptn_clustop_egress_comb1_dbgtop),
  .hostcpu_dbgtrace_egress_comb1_qdeny                 (qdeny_clustop_egress_comb1_dbgtop),
  
  .hostcpu_dbgtrace_ingress_qreqn                      (qreqn_clustop_ingress_comb1_dbgtop),
  .hostcpu_dbgtrace_ingress_qacceptn                   (qacceptn_clustop_ingress_comb1_dbgtop),
  .hostcpu_dbgtrace_ingress_qdeny                      (qdeny_clustop_ingress_comb1_dbgtop),
  .hostcpu_dbgtrace_ingress_qactive                    (qactive_clustop_ingress_comb1_dbgtop),

  .systop_egress_dbgaon_comb1_pwrqreqn                 (systop_egress_dbgaon_comb1_pwrqreqn),
  .systop_egress_dbgaon_comb1_pwrqacceptn              (systop_egress_dbgaon_comb1_pwrqacceptn),
  .systop_egress_dbgaon_comb1_pwrqdeny                 (systop_egress_dbgaon_comb1_pwrqdeny),
  .systop_egress_dbgaon_comb1_pwrqactive               (systop_egress_dbgaon_comb1_pwrqactive),
  
  .systop_egress_dbgaon_comb_pwrqreqn                  (systop_egress_dbgaon_comb_pwrqreqn[1:0]),
  .systop_egress_dbgaon_comb_pwrqacceptn               (systop_egress_dbgaon_comb_pwrqacceptn[1:0]),
  .systop_egress_dbgaon_comb_pwrqdeny                  (systop_egress_dbgaon_comb_pwrqdeny[1:0]),
  .systop_egress_dbgaon_comb_pwrqactive                (systop_egress_dbgaon_comb_pwrqactive[1:0]),

  .qreqn_systop                                        (qreqn_systop),
  .qacceptn_systop                                     (qacceptn_systop),
  .qdeny_systop                                        (qdeny_systop),
  .qactive_systop                                      (qactive_systop),
               
  .qreqn_systop_acg                                    (qreqn_systop_acg),
  .qacceptn_systop_acg                                 (qacceptn_systop_acg),
  .qdeny_systop_acg                                    (qdeny_systop_acg),
  .qactive_systop_acg                                  (qactive_systop_acg),
     
  .cluster_config_cryptodisable                        (cluster_config_cryptodisable),
 
  .pe0_config_aa64naa32                                (pe0_config_aa64naa32),
  .pe0_rvbaraddr_lw_rvbar31_2                          (pe0_rvbaraddr_lw_rvbar31_2),
  .pe0_rvbaraddr_up_rvbar43_32                         (pe0_rvbaraddr_up_rvbar43_32[7:0]),
  .pe1_config_aa64naa32                                (pe1_config_aa64naa32),
  .pe1_rvbaraddr_lw_rvbar31_2                          (pe1_rvbaraddr_lw_rvbar31_2),
  .pe1_rvbaraddr_up_rvbar43_32                         (pe1_rvbaraddr_up_rvbar43_32[7:0]),
  .pe2_config_aa64naa32                                (pe2_config_aa64naa32),
  .pe2_rvbaraddr_lw_rvbar31_2                          (pe2_rvbaraddr_lw_rvbar31_2),
  .pe2_rvbaraddr_up_rvbar43_32                         (pe2_rvbaraddr_up_rvbar43_32[7:0]),
  .pe3_config_aa64naa32                                (pe3_config_aa64naa32),
  .pe3_rvbaraddr_lw_rvbar31_2                          (pe3_rvbaraddr_lw_rvbar31_2),
  .pe3_rvbaraddr_up_rvbar43_32                         (pe3_rvbaraddr_up_rvbar43_32[7:0]),
 
  .pe3_config_vinithi                                  (pe3_config_vinithi),
  .pe3_config_cfgte                                    (pe3_config_cfgte),
  .pe3_config_cfgend                                   (pe3_config_cfgend),
  .pe2_config_vinithi                                  (pe2_config_vinithi),
  .pe2_config_cfgte                                    (pe2_config_cfgte),
  .pe2_config_cfgend                                   (pe2_config_cfgend),
  .pe1_config_vinithi                                  (pe1_config_vinithi),
  .pe1_config_cfgte                                    (pe1_config_cfgte),
  .pe1_config_cfgend                                   (pe1_config_cfgend),
  .pe0_config_vinithi                                  (pe0_config_vinithi),
  .pe0_config_cfgte                                    (pe0_config_cfgte),
  .pe0_config_cfgend                                   (pe0_config_cfgend),
 
  .host_cpu_boot_msk_boot_msk                          (host_cpu_boot_msk_boot_msk),
  .host_cpu_clus_pwr_req_pwr_req                       (host_cpu_clus_pwr_req_pwr_req),
  .bsys_pwr_req_wakeup_en                              (bsys_pwr_req_wakeup_en),
  .gic_wakeup                                          (GICWAKEUP),
  .axiap_csyspwrupreq_1                                (axiap_csyspwrupreq_int[1]),
  .axiap_csyspwrupack_1                                (axiap_csyspwrupack_int[1]),
  .hostrom_cdbgpwrupreq                                (hostrom_cdbgpwrupreq),
  .hostrom_cdbgpwrupack                                (hostrom_cdbgpwrupack),
  .hostcpu_cpuwait                                     (hostcpu_cpuwait),
  .clkforce_st_ctrlclk_force_st                        (clkforce_st_ctrlclk_force_st),
  .clkforce_st_aclk_force_st                           (clkforce_st_aclk_force_st),
  .host_ppu_int_st_core3_int_st                        (host_ppu_int_st_core3_int_st),
  .host_ppu_int_st_core2_int_st                        (host_ppu_int_st_core2_int_st),
  .host_ppu_int_st_core1_int_st                        (host_ppu_int_st_core1_int_st),
  .host_ppu_int_st_core0_int_st                        (host_ppu_int_st_core0_int_st),
  .host_ppu_int_st_clustop_int_st                      (host_ppu_int_st_clustop_int_st),
  .host_cpu_clus_pwr_req_mem_ret_r                     (host_cpu_clus_pwr_req_mem_ret_r)
);
  
  system_control_f0_aontop  #(
     .DEV_PREQ_DLY_DBG                                 (DEV_PREQ_DLY_DBG),
    .PCSM_PREQ_DLY_DBG                                 (PCSM_PREQ_DLY_DBG),
    .ISO_CLKEN_DLY_CFG_DBG                             (ISO_CLKEN_DLY_CFG_DBG),
    .CLKEN_RST_DLY_CFG_DBG                             (CLKEN_RST_DLY_CFG_DBG),
    .RST_HWSTAT_DLY_CFG_DBG                            (RST_HWSTAT_DLY_CFG_DBG),
    .CLKEN_ISO_DLY_CFG_DBG                             (CLKEN_ISO_DLY_CFG_DBG),
    .ISO_RST_DLY_CFG_DBG                               (ISO_RST_DLY_CFG_DBG),
    .DEV_PREQ_DLY_SYS                                  (DEV_PREQ_DLY_SYS),
    .PCSM_PREQ_DLY_SYS                                 (PCSM_PREQ_DLY_SYS),
    .ISO_CLKEN_DLY_CFG_SYS                             (ISO_CLKEN_DLY_CFG_SYS),
    .CLKEN_RST_DLY_CFG_SYS                             (CLKEN_RST_DLY_CFG_SYS),
    .RST_HWSTAT_DLY_CFG_SYS                            (RST_HWSTAT_DLY_CFG_SYS),
    .CLKEN_ISO_DLY_CFG_SYS                             (CLKEN_ISO_DLY_CFG_SYS),
    .ISO_RST_DLY_CFG_SYS                               (ISO_RST_DLY_CFG_SYS),
    .DEV_PREQ_DLY_FWRAM                                (DEV_PREQ_DLY_FWRAM),
    .PCSM_PREQ_DLY_FWRAM                               (PCSM_PREQ_DLY_FWRAM),
    .ISO_CLKEN_DLY_CFG_FWRAM                           (ISO_CLKEN_DLY_CFG_FWRAM),
    .CLKEN_RST_DLY_CFG_FWRAM                           (CLKEN_RST_DLY_CFG_FWRAM),
    .RST_HWSTAT_DLY_CFG_FWRAM                          (RST_HWSTAT_DLY_CFG_FWRAM),
    .CLKEN_ISO_DLY_CFG_FWRAM                           (CLKEN_ISO_DLY_CFG_FWRAM),
    .ISO_RST_DLY_CFG_FWRAM                             (ISO_RST_DLY_CFG_FWRAM),
 
    .FCTRLCFG_UP_FIFO_DEPTH_SYSTOP                     (FW2SYSTOP_FIFO_DEPTH),
    .FCTRLCFG_DN_FIFO_DEPTH_SYSTOP                     (FW2SYSTOP_FIFO_DEPTH),
    .FCTRLCFG_UP_FIFO_DEPTH_DBGTOP                     (FW2DBGTOP_FIFO_DEPTH),
    .FCTRLCFG_DN_FIFO_DEPTH_DBGTOP                     (FW2DBGTOP_FIFO_DEPTH),
    .ES_CNT                                            (NUM_EXT_SYS),
    .SYS_EGRESS_2_DBG                                  (SYS_EGRESS_2_DBG),
    .SYS_INGRESS_2_DBG                                 (SYS_INGRESS_2_DBG),
    .DBG_INTERNAL_CNT                                  (DBG_INTERNAL_CNT),
    .DBG_EGRESS_CNT                                    (DBG_EGRESS_CNT),
    .FCTRLCFG_DN_PAYLD_LEN_DBGTOP                      (A4S_PAYLOAD_WIDTH*FW2DBGTOP_FIFO_DEPTH),
    .FCTRLCFG_UP_PAYLD_LEN_DBGTOP                      (A4S_PAYLOAD_WIDTH*FW2DBGTOP_FIFO_DEPTH),
    .FCTRLCFG_DN_PAYLD_LEN_SYSTOP                      (A4S_PAYLOAD_WIDTH*FW2SYSTOP_FIFO_DEPTH),
    .FCTRLCFG_UP_PAYLD_LEN_SYSTOP                      (A4S_PAYLOAD_WIDTH*FW2SYSTOP_FIFO_DEPTH),
    
    .FCTRLPROG_AW_FIFO_DEPTH                           (FW_AXI_AW_FIFO_DEPTH), 
    .FCTRLPROG_AR_FIFO_DEPTH                           (FW_AXI_AR_FIFO_DEPTH), 
    .FCTRLPROG_W_FIFO_DEPTH                            (FW_AXI_W_FIFO_DEPTH),
    .FCTRLPROG_B_FIFO_DEPTH                            (FW_AXI_B_FIFO_DEPTH),
    .FCTRLPROG_R_FIFO_DEPTH                            (FW_AXI_R_FIFO_DEPTH),
    .FCTRLPROG_AWUSER_WIDTH                            (FW_AXI_AWUSER_WIDTH),
    .FCTRLPROG_ARUSER_WIDTH                            (FW_AXI_ARUSER_WIDTH),
    .FCTRLPROG_WUSER_WIDTH                             (FW_AXI_WUSER_WIDTH),
    .FCTRLPROG_BUSER_WIDTH                             (FW_AXI_BUSER_WIDTH),
    .FCTRLPROG_RUSER_WIDTH                             (FW_AXI_RUSER_WIDTH),
    .FCTRLPROG_AWID_WIDTH                              (FW_AXI_AWID_WIDTH),
    .FCTRLPROG_ARID_WIDTH                              (FW_AXI_ARID_WIDTH),
    .FCTRLPROG_ADDR_WIDTH                              (FW_AXI_ADDR_WIDTH),
    .FCTRLPROG_DATA_WIDTH                              (FW_AXI_DATA_WIDTH),    
    .QACTIVE_REFCLK_TOP_CNT                            (QACTIVE_REFCLK_TOP_CNT),
    .NUM_SHD_INT                                       (96),
    .HOST_CPU_NUM_CORES                                (HOST_CPU_NUM_CORES),
    .IIDR_PRODUCT_ID                                   (IIDR_PRODUCT_ID ),
    .IIDR_VARIANT_ID                                   (IIDR_VARIANT_ID ),
    .IIDR_REVISION                                     (IIDR_REVISION   ),
    .IIDR_IMPLEMENTER                                  (IIDR_IMPLEMENTER),
    .FCTRL_NUM_FC_CLOG2                                (A4S_ID_WIDTH)
  )
  u_system_control_f0_aontop
  (
    .refclk_free                                       (REFCLK),    
    .s32kclk                                           (S32KCLK),    
    .syspll                                            (SYSPLL),  
    .cpupll                                            (CPUPLL),    
    .traceclk_in                                       (TRACECLKIN),
    
    .uartclk(UARTCLK),
    .extsys0_cpuwait_wen                 (extsys0_cpuwait_wen),
    .extsys1_cpuwait_wen                 (extsys1_cpuwait_wen),
    .hostcntclkout                                     (HOSTCNTCLKOUT),
    .hostcntclkout_systop                              (hostcntclkout_systop),
    .refclk_int_gated_out                              (refclk_int_gated),
    .refclk_sleep_gated_out                            (refclk_sleep_gated),
    .aontop_warmresetn                                 (AONTOPWARMRESETn),
    .aontop_poresetn                                   (AONTOPPORESETn),
    .poresetn                                          (PORESETn),
    .refclk_warmresetn                                 (refclk_warmresetn),
    .refclk_aontopporesetn                             (refclk_aontopporesetn),
          
    .qactive_refclk_int_gated_top                      (qactive_refclk_int_gated),
    .qactive_refclk_systop                             (qactive_refclk_systop),
    .soc_id_product_id                                 (SOCPRTID),
    .soc_id_variant_id                                 (SOCVAR),
    .soc_id_revision                                   (SOCREV),
    .soc_id_implementer                                (SOCIMPLID),
     
    .ppu_dbgen                                         (ppu_dbgen),
    .ocvmsize                                          (OCVMSIZE),
    .cnvmsize                                          (XNVMSIZE),
    .cvmsize                                           (CVMSIZE),

    .ext_sys0_rst_st_rst_ack             (ext_sys0_rst_st_rst_ack),
    .ext_sys1_rst_st_rst_ack             (ext_sys1_rst_st_rst_ack),
     
    
    .refclk_systop                                     (refclk_systop),
    .refclk_dbgtop                                     (refclk_dbgtop),
    
    .syspll_systop                                     (syspll_systop),
    .syspll_dbgtop                                     (syspll_dbgtop),
    .cpupll_systop                                     (cpupll_systop),
    .traceclk_in_dbgtop                                (traceclk_in_dbgtop),
    
    .systop_warmresetn                                 (SYSTOPWARMRESETn),
    .dbgtop_warmresetn                                 (DBGTOPWARMRESETn),
    
    .refclk_poresetn_qreqn                             (REFCLKQREQn),
    .refclk_poresetn_qacceptn                          (REFCLKQACCEPTn),
    .refclk_poresetn_qdeny                             (REFCLKQDENY),
    .refclk_poresetn_qactive                           (REFCLKQACTIVE),
  
    .periph_async_req                                  (aonperiph_async_req),
    .periph_async_req_payload                          (aonperiph_async_req_payload),
    .periph_async_resp_payload                         (aonperiph_async_resp_payload),
    .periph_async_ack                                  (aonperiph_async_ack),
    
    .bootreg_async_req                                 (bootreg_async_req),
    .bootreg_async_req_payload                         (bootreg_async_req_payload),
    .bootreg_async_resp_payload                        (bootreg_async_resp_payload),
    .bootreg_async_ack                                 (bootreg_async_ack),
         
    .uart_async_req                                    (uart_async_req),
    .uart_async_req_payload                            (uart_async_req_payload),
    .uart_async_resp_payload                           (uart_async_resp_payload),
    .uart_async_ack                                    (uart_async_ack),
    
    
    .refclk_counter_haltreqreq                         (refclk_counter_haltreqreq),
    .refclk_counter_haltreqack                         (refclk_counter_haltreqack),
    .refclk_counter_restartreq                         (refclk_counter_restartreq),
    .refclk_counter_restartack                         (refclk_counter_restartack),
                                                       
    .s32k_counter_haltreqreq                           (s32k_counter_haltreqreq),
    .s32k_counter_haltreqack                           (s32k_counter_haltreqack),
    .s32k_counter_restartreq                           (s32k_counter_restartreq),
    .s32k_counter_restartack                           (s32k_counter_restartack),
 
    .psel_aon_expansion                                (PSELHOSTAONEXPMST),
    .penable_aon_expansion                             (PENABLEHOSTAONEXPMST),
    .paddr_aon_expansion                               (PADDRHOSTAONEXPMST),
    .pwrite_aon_expansion                              (PWRITEHOSTAONEXPMST),
    .pwdata_aon_expansion                              (PWDATAHOSTAONEXPMST),
    .pstrb_aon_expansion                               (PSTRBHOSTAONEXPMST),
    .pprot_aon_expansion                               (PPROTHOSTAONEXPMST),
    .pready_aon_expansion                              (PREADYHOSTAONEXPMST),
    .prdata_aon_expansion                              (PRDATAHOSTAONEXPMST),
    .pslverr_aon_expansion                             (PSLVERRHOSTAONEXPMST),
    .pwakeup_aon_expansion                             (PWAKEUPHOSTAONEXPMST),
    .pclk_aon_expansion                                (HOSTAONEXPCLK),

    .fctrlprog_slvmustacceptreqn_async                 (firewall_slvmustacceptreqn_async),
    .fctrlprog_slvcandenyreqn_async                    (firewall_slvcandenyreqn_async),
    .fctrlprog_slvacceptn_async                        (firewall_slvacceptn_async),
    .fctrlprog_slvdeny_async                           (firewall_slvdeny_async),
    .fctrlprog_si_to_mi_wakeup_async                   (firewall_si_to_mi_wakeup_async),
    .fctrlprog_mi_to_si_wakeup_async                   (firewall_mi_to_si_wakeup_async),
    .fctrlprog_aw_wr_ptr_async                         (firewall_aw_wr_ptr_async),
    .fctrlprog_aw_rd_ptr_async                         (firewall_aw_rd_ptr_async),
    .fctrlprog_aw_payld_async                          (firewall_aw_payld_async),
    .fctrlprog_w_wr_ptr_async                          (firewall_w_wr_ptr_async),
    .fctrlprog_w_rd_ptr_async                          (firewall_w_rd_ptr_async),
    .fctrlprog_w_payld_async                           (firewall_w_payld_async),
    .fctrlprog_b_wr_ptr_async                          (firewall_b_wr_ptr_async),
    .fctrlprog_b_rd_ptr_async                          (firewall_b_rd_ptr_async),
    .fctrlprog_b_payld_async                           (firewall_b_payld_async),
    .fctrlprog_ar_wr_ptr_async                         (firewall_ar_wr_ptr_async),
    .fctrlprog_ar_rd_ptr_async                         (firewall_ar_rd_ptr_async),
    .fctrlprog_ar_payld_async                          (firewall_ar_payld_async),
    .fctrlprog_r_wr_ptr_async                          (firewall_r_wr_ptr_async),
    .fctrlprog_r_rd_ptr_async                          (firewall_r_rd_ptr_async),
    .fctrlprog_r_payld_async                           (firewall_r_payld_async),

    .fctrlcfg_systop_up_slvmustacceptreqn_async        (fw2systop_up_slvmustacceptreqn_async),
    .fctrlcfg_systop_up_slvcandenyreqn_async           (fw2systop_up_slvcandenyreqn_async),
    .fctrlcfg_systop_up_slvacceptn_async               (fw2systop_up_slvacceptn_async),
    .fctrlcfg_systop_up_slvdeny_async                  (fw2systop_up_slvdeny_async),
                                                       
    .fctrlcfg_systop_up_si_to_mi_wakeup_async          (fw2systop_up_si_to_mi_wakeup_async),
    .fctrlcfg_systop_up_mi_to_si_wakeup_async          (fw2systop_up_mi_to_si_wakeup_async),
                                                       
    .fctrlcfg_systop_up_wr_ptr_async                   (fw2systop_up_wr_ptr_async),
    .fctrlcfg_systop_up_rd_ptr_async                   (fw2systop_up_rd_ptr_async),
    .fctrlcfg_systop_up_payld_async                    (fw2systop_up_payld_async),
                                                       
                                                       
    .fctrlcfg_systop_dn_slvmustacceptreqn_async        (fw2systop_dn_slvmustacceptreqn_async),
    .fctrlcfg_systop_dn_slvcandenyreqn_async           (fw2systop_dn_slvcandenyreqn_async),
    .fctrlcfg_systop_dn_slvacceptn_async               (fw2systop_dn_slvacceptn_async),
    .fctrlcfg_systop_dn_slvdeny_async                  (fw2systop_dn_slvdeny_async),
                                                       
    .fctrlcfg_systop_dn_si_to_mi_wakeup_async          (fw2systop_dn_si_to_mi_wakeup_async),
    .fctrlcfg_systop_dn_mi_to_si_wakeup_async          (fw2systop_dn_mi_to_si_wakeup_async),
                                                       
    .fctrlcfg_systop_dn_wr_ptr_async                   (fw2systop_dn_wr_ptr_async),
    .fctrlcfg_systop_dn_rd_ptr_async                   (fw2systop_dn_rd_ptr_async),
    .fctrlcfg_systop_dn_payld_async                    (fw2systop_dn_payld_async),
    
    
    .fctrlcfg_dbgtop_up_slvmustacceptreqn_async        (fw2dbgtop_up_slvmustacceptreqn_async),
    .fctrlcfg_dbgtop_up_slvcandenyreqn_async           (fw2dbgtop_up_slvcandenyreqn_async),
    .fctrlcfg_dbgtop_up_slvacceptn_async               (fw2dbgtop_up_slvacceptn_async),
    .fctrlcfg_dbgtop_up_slvdeny_async                  (fw2dbgtop_up_slvdeny_async),
                                                       
    .fctrlcfg_dbgtop_up_si_to_mi_wakeup_async          (fw2dbgtop_up_si_to_mi_wakeup_async),
    .fctrlcfg_dbgtop_up_mi_to_si_wakeup_async          (fw2dbgtop_up_mi_to_si_wakeup_async),
                                                       
    .fctrlcfg_dbgtop_up_wr_ptr_async                   (fw2dbgtop_up_wr_ptr_async),
    .fctrlcfg_dbgtop_up_rd_ptr_async                   (fw2dbgtop_up_rd_ptr_async),
    .fctrlcfg_dbgtop_up_payld_async                    (fw2dbgtop_up_payld_async),
                                                       
                                                       
    .fctrlcfg_dbgtop_dn_slvmustacceptreqn_async        (fw2dbgtop_dn_slvmustacceptreqn_async),
    .fctrlcfg_dbgtop_dn_slvcandenyreqn_async           (fw2dbgtop_dn_slvcandenyreqn_async),
    .fctrlcfg_dbgtop_dn_slvacceptn_async               (fw2dbgtop_dn_slvacceptn_async),
    .fctrlcfg_dbgtop_dn_slvdeny_async                  (fw2dbgtop_dn_slvdeny_async),
                                                       
    .fctrlcfg_dbgtop_dn_si_to_mi_wakeup_async          (fw2dbgtop_dn_si_to_mi_wakeup_async),
    .fctrlcfg_dbgtop_dn_mi_to_si_wakeup_async          (fw2dbgtop_dn_mi_to_si_wakeup_async),
                                                       
    .fctrlcfg_dbgtop_dn_wr_ptr_async                   (fw2dbgtop_dn_wr_ptr_async),
    .fctrlcfg_dbgtop_dn_rd_ptr_async                   (fw2dbgtop_dn_rd_ptr_async),
    .fctrlcfg_dbgtop_dn_payld_async                    (fw2dbgtop_dn_payld_async),
                                                       
    .uart0_out2n                                       (HOSTUART0OUT2n),
    .uart0_out1n                                       (HOSTUART0OUT1n),
    .uart0_rtsn                                        (HOSTUART0RTSn),
    .uart0_dtrn                                        (HOSTUART0DTRn),
    .uart0_txd                                         (HOSTUART0TX),
    .uart0_ctsn                                        (HOSTUART0CTSn),
    .uart0_dcdn                                        (HOSTUART0DCDn),
    .uart0_dsrn                                        (HOSTUART0DSRn),
    .uart0_ri                                          (HOSTUART0RIn),
    .uart0_rxd                                         (HOSTUART0RX),
                                                       
    .uart1_out2n                                       (HOSTUART1OUT2n),
    .uart1_out1n                                       (HOSTUART1OUT1n),
    .uart1_rtsn                                        (HOSTUART1RTSn),
    .uart1_dtrn                                        (HOSTUART1DTRn),
    .uart1_txd                                         (HOSTUART1TX),
    .uart1_ctsn                                        (HOSTUART1CTSn),
    .uart1_dcdn                                        (HOSTUART1DCDn),
    .uart1_dsrn                                        (HOSTUART1DSRn),
    .uart1_ri                                          (HOSTUART1RIn),
    .uart1_rxd                                         (HOSTUART1RX),
      
    .tsvalueg_out                                      (HOSTCNTVALUEG),
    .tsvalueb_in                                       (HOSTCNTVALUEB),
                        
    .tsvalueg_s32k_out                                 (HOSTS32KCNTVALUEG),
    .tsvalueb_s32k_in                                  (HOSTS32KCNTVALUEB),
  
    .host_cpu_wake_up                                  (host_cpu_wake_up),
    .clustop_ppuhwstat                                 (clustop_ppuhwstat),
    
    .qreqn_dbgtop_ingress_aon                          (dp2hostdbg_pwrdbg_pwrqreqn),
    .qacceptn_dbgtop_ingress_aon                       (dp2hostdbg_pwrdbg_pwrqacceptn),
    .qdeny_dbgtop_ingress_aon                          (dp2hostdbg_pwrdbg_pwrqdeny),
    .qactive_dbgtop_ingress_aon                        (dp2hostdbg_pwrdbg_pwrqactive),
                                        
                                        
    .qreqn_systop_egress_dbgtop                        (qreqn_systop_egress_dbgtop),
    .qacceptn_systop_egress_dbgtop                     (qacceptn_systop_egress_dbgtop),
    .qdeny_systop_egress_dbgtop                        (qdeny_systop_egress_dbgtop),
    .qactive_systop_egress_dbgtop                      (qactive_systop_egress_dbgtop),
                                        
    .qreqn_systop_ingress_dbgtop                       (qreqn_systop_ingress_dbgtop),
    .qacceptn_systop_ingress_dbgtop                    (qacceptn_systop_ingress_dbgtop),
    .qdeny_systop_ingress_dbgtop                       (qdeny_systop_ingress_dbgtop),
    .qactive_systop_ingress_dbgtop                     (qactive_systop_ingress_dbgtop),
    
    .qreqn_secenc_systopq                              (qreqn_secenc_systopq_ppu),
    .qacceptn_secenc_systopq                           (qacceptn_secenc_systopq_ppu),
    .qdeny_secenc_systopq                              (qdeny_secenc_systopq_ppu),
    .qactive_secenc_systopq                            (qactive_secenc_systopq_ppu),
                                
                                
    .qreqn_secenc_dbgtopq                              (qreqn_secenc_dbgtopq_ppu),
    .qacceptn_secenc_dbgtopq                           (qacceptn_secenc_dbgtopq_ppu),
    .qdeny_secenc_dbgtopq                              (qdeny_secenc_dbgtopq_ppu),
    .qactive_secenc_dbgtopq                            (qactive_secenc_dbgtopq_ppu),
                                
                                
                 
    .qreqn_extsys_systopq                              (qreqn_extsys_systopq_ppu),
    .qacceptn_extsys_systopq                           (qacceptn_extsys_systopq_ppu),
    .qdeny_extsys_systopq                              (qdeny_extsys_systopq_ppu),
    .qactive_extsys_systopq                            (qactive_extsys_systopq_ppu),
                                
   
    .qreqn_extsys_dbgtopq                              (qreqn_extsys_dbgtopq_ppu),
    .qacceptn_extsys_dbgtopq                           (qacceptn_extsys_dbgtopq_ppu),
    .qdeny_extsys_dbgtopq                              (qdeny_extsys_dbgtopq_ppu),
    .qactive_extsys_dbgtopq                            (qactive_extsys_dbgtopq_ppu),
                                
    
    .clustop_dependency_qreqn                          (clustop_dependency_qreqn),
    .clustop_dependency_qacceptn                       (clustop_dependency_qacceptn),
    .clustop_dependency_qdeny                          (clustop_dependency_qdeny),
    .clustop_dependency_qactive                        (clustop_dependency_qactive),
                                        
    .qreqn_systop                                      (qreqn_systop),
    .qacceptn_systop                                   (qacceptn_systop),
    .qdeny_systop                                      (qdeny_systop),
    .qactive_systop                                    (qactive_systop),
                                        
    .qreqn_systop_acg                                  (qreqn_systop_acg),
    .qacceptn_systop_acg                               (qacceptn_systop_acg),
    .qdeny_systop_acg                                  (qdeny_systop_acg),
    .qactive_systop_acg                                (qactive_systop_acg),
                                        
    .qreqn_clustop_egress_dbgtop                       (qreqn_clustop_egress_comb0_dbgtop),
    .qacceptn_clustop_egress_dbgtop                    (qacceptn_clustop_egress_comb0_dbgtop),
    .qdeny_clustop_egress_dbgtop                       (qdeny_clustop_egress_comb0_dbgtop),
    .qactive_clustop_egress_dbgtop                     (qactive_clustop_egress_comb0_dbgtop),
    
    .qreqn_clustop_ingress_dbgtop                      (qreqn_clustop_ingress_comb0_dbgtop),
    .qacceptn_clustop_ingress_dbgtop                   (qacceptn_clustop_ingress_comb0_dbgtop),
    .qdeny_clustop_ingress_dbgtop                      (qdeny_clustop_ingress_comb0_dbgtop),
    .qactive_clustop_ingress_dbgtop                    (qactive_clustop_ingress_comb0_dbgtop),
                                            
    .qreqn_dbgtop_exp                                  (DBGTOPQREQn),
    .qacceptn_dbgtop_exp                               (DBGTOPQACCEPTn),
    .qdeny_dbgtop_exp                                  (DBGTOPQDENY),
    .qactive_dbgtop_exp                                (DBGTOPQACTIVE),
                                        


    .qreqn_systop_exp                                  (SYSTOPQREQn),
    .qacceptn_systop_exp                               (SYSTOPQACCEPTn),
    .qdeny_systop_exp                                  (SYSTOPQDENY),
    .qactive_systop_exp                                (SYSTOPQACTIVE),
                                        
    .qreqn_dbgtop_internal                             (qreqn_dbgtop_internal),
    .qacceptn_dbgtop_internal                          (qacceptn_dbgtop_internal),
    .qdeny_dbgtop_internal                             (qdeny_dbgtop_internal),
    .qactive_dbgtop_internal                           (qactive_dbgtop_internal),
    
    .qreqn_dbgtop_egress                               (qreqn_dbgtop_egress),
    .qacceptn_dbgtop_egress                            (qacceptn_dbgtop_egress),
    .qdeny_dbgtop_egress                               (qdeny_dbgtop_egress),
    .qactive_dbgtop_egress                             (qactive_dbgtop_egress),
   
 
    .qreqn_aondbg_sleep_gated                          (qreqn_aondbg_sleep_gated),
    .qacceptn_aondbg_sleep_gated                       (qacceptn_aondbg_sleep_gated),
    .qdeny_aondbg_sleep_gated                          (qdeny_aondbg_sleep_gated),
    .qactive_aondbg_sleep_gated                        (qactive_aondbg_sleep_gated),
 
    .cluster_config_cryptodisable                      (cluster_config_cryptodisable),
    .pe0_config_vinithi                                (pe0_config_vinithi),
    .pe0_config_cfgte                                  (pe0_config_cfgte),
    .pe0_config_cfgend                                 (pe0_config_cfgend),
    .pe1_config_vinithi                                (pe1_config_vinithi),
    .pe1_config_cfgte                                  (pe1_config_cfgte),
    .pe1_config_cfgend                                 (pe1_config_cfgend),
    .pe2_config_vinithi                                (pe2_config_vinithi),
    .pe2_config_cfgte                                  (pe2_config_cfgte),
    .pe2_config_cfgend                                 (pe2_config_cfgend),
    .pe3_config_vinithi                                (pe3_config_vinithi),
    .pe3_config_cfgte                                  (pe3_config_cfgte),
    .pe3_config_cfgend                                 (pe3_config_cfgend),

    .pe0_config_aa64naa32                              (pe0_config_aa64naa32),
    .pe0_rvbaraddr_lw_rvbar31_2                        (pe0_rvbaraddr_lw_rvbar31_2),
    .pe0_rvbaraddr_up_rvbar43_32                       (pe0_rvbaraddr_up_rvbar43_32),
    .pe1_config_aa64naa32                              (pe1_config_aa64naa32),
    .pe1_rvbaraddr_lw_rvbar31_2                        (pe1_rvbaraddr_lw_rvbar31_2),
    .pe1_rvbaraddr_up_rvbar43_32                       (pe1_rvbaraddr_up_rvbar43_32),
    .pe2_config_aa64naa32                              (pe2_config_aa64naa32),
    .pe2_rvbaraddr_lw_rvbar31_2                        (pe2_rvbaraddr_lw_rvbar31_2),
    .pe2_rvbaraddr_up_rvbar43_32                       (pe2_rvbaraddr_up_rvbar43_32),
    .pe3_config_aa64naa32                              (pe3_config_aa64naa32),
    .pe3_rvbaraddr_lw_rvbar31_2                        (pe3_rvbaraddr_lw_rvbar31_2),
    .pe3_rvbaraddr_up_rvbar43_32                       (pe3_rvbaraddr_up_rvbar43_32),
     
    .host_cpu_boot_msk_boot_msk                        (host_cpu_boot_msk_boot_msk),
    .host_cpu_clus_pwr_req_pwr_req                     (host_cpu_clus_pwr_req_pwr_req),
    .bsys_pwr_req_wakeup_en_o                          (bsys_pwr_req_wakeup_en),
    .hostcpuclk_ctrl_clkselect_cur                     (hostcpuclk_ctrl_clkselect_cur),
    .hostcpuclk_ctrl_clkselect                         (hostcpuclk_ctrl_clkselect),
    .hostcpuclk_div0_clkdiv_cur                        (hostcpuclk_div0_clkdiv_cur),
    .hostcpuclk_div0_clkdiv                            (hostcpuclk_div0_clkdiv),
    .hostcpuclk_div1_clkdiv_cur                        (hostcpuclk_div1_clkdiv_cur),
    .hostcpuclk_div1_clkdiv                            (hostcpuclk_div1_clkdiv),
    .gicclk_ctrl_clkselect_cur                         (gicclk_ctrl_clkselect_cur),
    .gicclk_ctrl_clkselect                             (gicclk_ctrl_clkselect),
    .gicclk_div0_clkdiv_cur                            (gicclk_div0_clkdiv_cur),
    .gicclk_div0_clkdiv                                (gicclk_div0_clkdiv),
    .aclk_ctrl_clkselect_cur                           (aclk_ctrl_clkselect_cur),
    .aclk_ctrl_clkselect                               (aclk_ctrl_clkselect),
    .aclk_div0_clkdiv_cur                              (aclk_div0_clkdiv_cur),
    .aclk_div0_clkdiv                                  (aclk_div0_clkdiv),
    .ctrlclk_ctrl_clkselect_cur                        (ctrlclk_ctrl_clkselect_cur),
    .ctrlclk_ctrl_clkselect                            (ctrlclk_ctrl_clkselect),
    .ctrlclk_div0_clkdiv_cur                           (ctrlclk_div0_clkdiv_cur),
    .ctrlclk_div0_clkdiv                               (ctrlclk_div0_clkdiv),
    .dbgclk_ctrl_clkselect_cur                         (dbgclk_ctrl_clkselect_cur),
    .dbgclk_ctrl_clkselect                             (dbgclk_ctrl_clkselect),
    .dbgclk_div0_clkdiv_cur                            (dbgclk_div0_clkdiv_cur),
    .dbgclk_div0_clkdiv                                (dbgclk_div0_clkdiv),
    .clkforce_st_dbgclk_force_st                       (clkforce_st_dbgclk_force_st),
    .clkforce_st_ctrlclk_force_st                      (clkforce_st_ctrlclk_force_st),
    .clkforce_st_aclk_force_st                         (clkforce_st_aclk_force_st),
    .clkforce_st_gicclk_force_st                       (),
    .pll_st_cpuplllock_st                              (CPUPLLLOCK),
    .pll_st_sysplllock_st                              (SYSPLLLOCK),
    .host_ppu_int_st_core3_int_st                      (host_ppu_int_st_core3_int_st),
    .host_ppu_int_st_core2_int_st                      (host_ppu_int_st_core2_int_st),
    .host_ppu_int_st_core1_int_st                      (host_ppu_int_st_core1_int_st),
    .host_ppu_int_st_core0_int_st                      (host_ppu_int_st_core0_int_st),
    .host_ppu_int_st_clustop_int_st                    (host_ppu_int_st_clustop_int_st),
    .host_cpu_clus_pwr_req_mem_ret_r                   (host_cpu_clus_pwr_req_mem_ret_r),
    
    .interrupt_router_tamper_interrupt                 (interrupt_router_tamper_interrupt),
   
    .exp_shd_int                                       (EXPSHDINT),
    .hostcpu_gicintdbgtop                              (hostcpu_gicintdbgtop),
    .hostcpu_gicintuart                                (hostcpu_gicintuart),
    .hostcpu_gicintwdogs                               (hostcpu_gicintwdogs),
    .hostcpu_gicintwdogns                              (hostcpu_gicintwdogns),
    .hostcpu_gicshdint                                 (hostcpu_gicshdint),

    .extsys0_shared_interrupts           (EXTSYS0SHDINT),
    .extsys1_shared_interrupts           (EXTSYS1SHDINT),

    .secenc_shared_interrupts                          (secenc_shared_interrupts),
   
    .dp_cdbgpwrupreq                                   (dpslv_cdbgpwrupreq),
    .dp_cdbgpwrupack                                   (dpslv_cdbgpwrupack),
    
    .dprom_cdbgpwrupreq0                               (dprom_cdbgpwrupreq),
    .dprom_cdbgpwrupack0                               (dprom_cdbgpwrupack),
    
    .dprom_cdbgrstreq0                                 (dprom_cdbgrstreq),
    .dprom_cdbgrstack0                                 (dprom_cdbgrstack),
        
    .host_cdbgpwrupreq                                 (hostrom_cdbgpwrupreq),
    .axiap_csyspwrupreq0                               (axiap_csyspwrupreq_int[0]),
    .axiap_csyspwrupreq1                               (axiap_csyspwrupreq_int[1]),
    .axiap_csyspwrupack0                               (axiap_csyspwrupack_int[0]),

    .ext_sys0_rst_ctrl_rst_req           (ext_sys0_rst_ctrl_rst_req),
    .ext_sys0_rst_ctrl_cpuwait           (EXTSYS0CPUWAIT),
    .ext_sys1_rst_ctrl_rst_req           (ext_sys1_rst_ctrl_rst_req),
    .ext_sys1_rst_ctrl_cpuwait           (EXTSYS1CPUWAIT),

    .sdc600_rempur                                     (sdc600_ext_rempur),
    .sdc600_rempua                                     (sdc600_ext_rempua),
    .irq_sdc600                                        (irq_sdc600),
    .irq_soc_etr                                       (irq_soc_etr),
    .irq_soc_catu                                      (irq_soc_catu),
    .irq_host_stm                                      (irq_host_stm),
    .irq_host_etr                                      (irq_host_etr),
    .irq_host_catu                                     (irq_host_catu),
 
    .host_cti_trig_out_4                               (host_cti_trig_out_4),
    .host_cti_trig_out_5                               (host_cti_trig_out_5),
    .secenc_mhu1_sender_cirq                           (secenc_mhu1_sender_cirq),
    .secenc_mhu1_receiver_cirq                         (secenc_mhu1_receiver_cirq),
    .secenc_mhu0_sender_cirq                           (secenc_mhu0_sender_cirq   ),
    .secenc_mhu0_receiver_cirq                         (secenc_mhu0_receiver_cirq ),
    .extsys0_mhu0_sender_cirq            (hes_0_eh0_mhuint),
    .extsys0_mhu0_receiver_cirq          (esh_0_eh0_mhuint),
      .extsys0_mhu1_sender_cirq            (hes_1_eh0_mhuint),
    .extsys0_mhu1_receiver_cirq          (esh_1_eh0_mhuint),
      .extsys1_mhu0_sender_cirq            (hes_0_eh1_mhuint),
    .extsys1_mhu0_receiver_cirq          (esh_0_eh1_mhuint),
      .extsys1_mhu1_sender_cirq            (hes_1_eh1_mhuint),
    .extsys1_mhu1_receiver_cirq          (esh_1_eh1_mhuint),
      .gic_wakeup                                        (GICWAKEUP),
    .host_rst_syn                                      (host_rst_syn),
    
    .secenc_bsys_pwr_req_systop_pwr_req                (secenc_bsys_pwr_req_systop_pwr_req),
    .secenc_bsys_pwr_st_systop_pwr_st                  (secenc_bsys_pwr_st_systop_pwr_st),
                                                       
    .secenc_bsys_pwr_req_dbgtop_pwr_req                (secenc_bsys_pwr_req_dbgtop_pwr_req),
    .secenc_bsys_pwr_st_dbgtop_pwr_st                  (secenc_bsys_pwr_st_dbgtop_pwr_st),
    .secenc_bsys_pwr_req_refclk_req                    (secenc_bsys_pwr_req_refclk),
    
    .secure_wdog_intr_second                           (secure_wdog_intr_second),
    .fwtamp_intr                                       (fwtamp_intr),
    .fctrl_bypass                                      (host_fctrl_bypass),
    
    .clkforce_st_refclk_force_st                       (clkforce_st_refclk_force_st),
    .refclk_ctrl_entrydelay                            (refclk_ctrl_entrydelay),
       
    .gicclk_ctrl_entrydelay                            (), 
    .aclk_ctrl_entrydelay                              (aclk_ctrl_entrydelay),
    .ctrlclk_ctrl_entrydelay                           (ctrlclk_ctrl_entrydelay),
    .dbgclk_ctrl_entrydelay                            (dbgclk_ctrl_entrydelay),

    .set_extsys0_cpuwait                 (set_extsys0_cpuwait),
    .set_extsys1_cpuwait                 (set_extsys1_cpuwait),

    .recwakeup_async_eh0_mhu_esh_0       (recwakeup_async_eh0_mhu_esh_0),
      .recwakeup_async_eh0_mhu_esh_1       (recwakeup_async_eh0_mhu_esh_1),
      .recwakeup_async_eh1_mhu_esh_0       (recwakeup_async_eh1_mhu_esh_0),
      .recwakeup_async_eh1_mhu_esh_1       (recwakeup_async_eh1_mhu_esh_1),
      .recwakeup_async_seh0_mhu                          (recwakeup_async_seh0_mhu),
    .recwakeup_async_seh1_mhu                          (recwakeup_async_seh1_mhu),
  
    .modify_lock_req                                   (modify_lock_req),
    .modify_lock_ack                                   (modify_lock_ack),
  
    .host_lock                                         (host_lock),
  
    .dfthostuartclksel                                 (DFTHOSTUARTCLKSEL),
    .dfthostuartclkselen                               (DFTCLKSELEN),
    .dfthostuartclkdivbypass                           (DFTDIVBYPASS),   
    .dftramhold                                        (DFTRAMHOLD),
    .dftdivsel                                         (DFTDIVSEL),
    .nmbistreset                                       (nMBISTRESET),
    .mbistreq                                          (MBISTREQ),
    .dftpwrup                                          (DFTPWRUP),
    .dftretdisable                                     (DFTRETDISABLE),
    .dftisodisable                                     (DFTISODISABLE),   
    .dftrstdisable                                     ({DFTRSTDISABLE[1], DFTRSTDISABLE[0]}),
    .dftcgen                                           (DFTCGEN)
   );


  pd_extsys0top_f0 #(
    
    .MHU_HESX0_NUM_CH                            (MHU_HES00_NUM_CH), 
    .MHU_ESXH0_NUM_CH                            (MHU_ES0H0_NUM_CH), 
    .MHU_SEESX0_NUM_CH                           (MHU_SEES00_NUM_CH), 
    .MHU_ESXSE0_NUM_CH                           (MHU_ES0SE0_NUM_CH),
    
    
    .MHU_HESX1_NUM_CH                            (MHU_HES01_NUM_CH), 
    .MHU_ESXH1_NUM_CH                            (MHU_ES0H1_NUM_CH), 
    .MHU_SEESX1_NUM_CH                           (MHU_SEES01_NUM_CH), 
    .MHU_ESXSE1_NUM_CH                           (MHU_ES0SE1_NUM_CH),   
      .EXT_SYSX_MEM_ADDR_WIDTH                     (EXT_SYS0_MEM_ADDR_WIDTH),
    .EXT_SYSX_MEM_DATA_WIDTH                     (EXT_SYS0_MEM_DATA_WIDTH),
    .EXT_SYSX_MEM_AWID_WIDTH                     (EXT_SYS0_MEM_AWID_WIDTH),
    .EXT_SYSX_MEM_ARID_WIDTH                     (EXT_SYS0_MEM_ARID_WIDTH),
    .EXT_SYSX_MEM_AWUSER_WIDTH                   (EXT_SYS0_MEM_AWUSER_WIDTH),
    .EXT_SYSX_MEM_WUSER_WIDTH                    (EXT_SYS0_MEM_WUSER_WIDTH),
    .EXT_SYSX_MEM_BUSER_WIDTH                    (EXT_SYS0_MEM_BUSER_WIDTH),
    .EXT_SYSX_MEM_ARUSER_WIDTH                   (EXT_SYS0_MEM_ARUSER_WIDTH),
    .EXT_SYSX_MEM_RUSER_WIDTH                    (EXT_SYS0_MEM_RUSER_WIDTH),
    .EXT_SYSX_MEM_AW_FIFO_DEPTH                  (EXT_SYS0_MEM_AW_FIFO_DEPTH),
    .EXT_SYSX_MEM_W_FIFO_DEPTH                   (EXT_SYS0_MEM_W_FIFO_DEPTH),
    .EXT_SYSX_MEM_B_FIFO_DEPTH                   (EXT_SYS0_MEM_B_FIFO_DEPTH),
    .EXT_SYSX_MEM_AR_FIFO_DEPTH                  (EXT_SYS0_MEM_AR_FIFO_DEPTH),
    .EXT_SYSX_MEM_R_FIFO_DEPTH                   (EXT_SYS0_MEM_R_FIFO_DEPTH),
    .EXT_SYSX_MEM_AW_PAYLOAD_WIDTH               (EXT_SYS0_MEM_AW_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_W_PAYLOAD_WIDTH                (EXT_SYS0_MEM_W_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_B_PAYLOAD_WIDTH                (EXT_SYS0_MEM_B_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_AR_PAYLOAD_WIDTH               (EXT_SYS0_MEM_AR_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_R_PAYLOAD_WIDTH                (EXT_SYS0_MEM_R_PAYLOAD_WIDTH)
    
  ) u_pd_extsys0top (
    .extsysx_dbgclks                             (EXTSYS0DBGCLKS),
    .extsysx_dbgclkm                             (EXTSYS0DBGCLKM),
    .extsysx_atclk                               (EXTSYS0ATCLK),
    .extsysx_cticlk                              (EXTSYS0CTICLK),
    .extsysx_aclk                                (EXTSYS0ACLK),
    .extsysx_mhuclk                              (EXTSYS0MHUCLK),
    
    .extsysx_dbgpresetsn                         (EXTSYS0DBGPRESETSn),
    .extsysx_dbgpresetmn                         (EXTSYS0DBGPRESETMn),
    .extsysx_atresetn                            (EXTSYS0ATRESETn),
    .extsysx_ctiresetn                           (EXTSYS0CTIRESETn),
    .extsysx_aresetn                             (EXTSYS0ARESETn),
    .extsysx_mhuresetn                           (EXTSYS0MHURESETn),
    
    .awakeup_extsysx_mem                         (AWAKEUPEXTSYS0MEM),
    .awid_extsysx_mem                            (AWIDEXTSYS0MEM),
    .awaddr_extsysx_mem                          (AWADDREXTSYS0MEM),
    .awlen_extsysx_mem                           (AWLENEXTSYS0MEM),
    .awsize_extsysx_mem                          (AWSIZEEXTSYS0MEM),
    .awburst_extsysx_mem                         (AWBURSTEXTSYS0MEM),
    .awlock_extsysx_mem                          (AWLOCKEXTSYS0MEM),
    .awcache_extsysx_mem                         (AWCACHEEXTSYS0MEM),
    .awprot_extsysx_mem                          (AWPROTEXTSYS0MEM),
    .awregion_extsysx_mem                        (AWREGIONEXTSYS0MEM),
    .awvalid_extsysx_mem                         (AWVALIDEXTSYS0MEM),
    .awready_extsysx_mem                         (AWREADYEXTSYS0MEM),
    .wstrb_extsysx_mem                           (WSTRBEXTSYS0MEM),
    .wlast_extsysx_mem                           (WLASTEXTSYS0MEM),
    .wvalid_extsysx_mem                          (WVALIDEXTSYS0MEM),
    .wdata_extsysx_mem                           (WDATAEXTSYS0MEM),
    .wready_extsysx_mem                          (WREADYEXTSYS0MEM),
    .bid_extsysx_mem                             (BIDEXTSYS0MEM),
    .bresp_extsysx_mem                           (BRESPEXTSYS0MEM),
    .bvalid_extsysx_mem                          (BVALIDEXTSYS0MEM),
    .bready_extsysx_mem                          (BREADYEXTSYS0MEM),
    .arid_extsysx_mem                            (ARIDEXTSYS0MEM),
    .araddr_extsysx_mem                          (ARADDREXTSYS0MEM),
    .arlen_extsysx_mem                           (ARLENEXTSYS0MEM),
    .arsize_extsysx_mem                          (ARSIZEEXTSYS0MEM),
    .arburst_extsysx_mem                         (ARBURSTEXTSYS0MEM),
    .arlock_extsysx_mem                          (ARLOCKEXTSYS0MEM),
    .arcache_extsysx_mem                         (ARCACHEEXTSYS0MEM),
    .arprot_extsysx_mem                          (ARPROTEXTSYS0MEM),
    .arregion_extsysx_mem                        (ARREGIONEXTSYS0MEM),
    .arvalid_extsysx_mem                         (ARVALIDEXTSYS0MEM),
    .arready_extsysx_mem                         (ARREADYEXTSYS0MEM),
    .rid_extsysx_mem                             (RIDEXTSYS0MEM),
    .rresp_extsysx_mem                           (RRESPEXTSYS0MEM),
    .rlast_extsysx_mem                           (RLASTEXTSYS0MEM),
    .rvalid_extsysx_mem                          (RVALIDEXTSYS0MEM),
    .rdata_extsysx_mem                           (RDATAEXTSYS0MEM),
    .rready_extsysx_mem                          (RREADYEXTSYS0MEM),
    .psel_extsysx_mhu                            (PSELEXTSYS0MHU),
    .pwakeup_extsysx_mhu                         (PWAKEUPEXTSYS0MHU),
    .penable_extsysx_mhu                         (PENABLEEXTSYS0MHU),
    .paddr_extsysx_mhu                           (PADDREXTSYS0MHU),
    .pwrite_extsysx_mhu                          (PWRITEEXTSYS0MHU),
    .pwdata_extsysx_mhu                          (PWDATAEXTSYS0MHU),
    .pstrb_extsysx_mhu                           (PSTRBEXTSYS0MHU),
    .pprot_extsysx_mhu                           (PPROTEXTSYS0MHU),
    .prdata_extsysx_mhu                          (PRDATAEXTSYS0MHU),
    .pready_extsysx_mhu                          (PREADYEXTSYS0MHU),
    .pslverr_extsysx_mhu                         (PSLVERREXTSYS0MHU),
    
    .esh0_extsysx_mhuint                         (ESH0EXTSYS0MHUINT),
    .hes0_extsysx_mhuint                         (HES0EXTSYS0MHUINT),
    .esse0_extsysx_mhuint                        (ESSE0EXTSYS0MHUINT),
    .sees0_extsysx_mhuint                        (SEES0EXTSYS0MHUINT),
      .esh1_extsysx_mhuint                         (ESH1EXTSYS0MHUINT),
    .hes1_extsysx_mhuint                         (HES1EXTSYS0MHUINT),
    .esse1_extsysx_mhuint                        (ESSE1EXTSYS0MHUINT),
    .sees1_extsysx_mhuint                        (SEES1EXTSYS0MHUINT),
      
    .atready_extsysx_traceexp                    (ATREADYEXTSYS0TRACEEXP),
    .afvalid_extsysx_traceexp                    (AFVALIDEXTSYS0TRACEEXP),
    .syncreq_extsysx_traceexp                    (SYNCREQEXTSYS0TRACEEXP),
    .atid_extsysx_traceexp                       (ATIDEXTSYS0TRACEEXP),
    .atvalid_extsysx_traceexp                    (ATVALIDEXTSYS0TRACEEXP),
    .atdata_extsysx_traceexp                     (ATDATAEXTSYS0TRACEEXP),
    .atbytes_extsysx_traceexp                    (ATBYTESEXTSYS0TRACEEXP),
    .afready_extsysx_traceexp                    (AFREADYEXTSYS0TRACEEXP),
    .atwakeup_extsysx_traceexp                   (ATWAKEUPEXTSYS0TRACEEXP),
    
    .psel_extsysx_dbg                            (PSELEXTSYS0DBG),
    .pwakeup_extsysx_dbg                         (PWAKEUPEXTSYS0DBG),
    .penable_extsysx_dbg                         (PENABLEEXTSYS0DBG),
    .paddr_extsysx_dbg                           (PADDREXTSYS0DBG),
    .pwrite_extsysx_dbg                          (PWRITEEXTSYS0DBG),
    .pwdata_extsysx_dbg                          (PWDATAEXTSYS0DBG),
    .pstrb_extsysx_dbg                           (PSTRBEXTSYS0DBG),
    .pprot_extsysx_dbg                           (PPROTEXTSYS0DBG),
    .prdata_extsysx_dbg                          (PRDATAEXTSYS0DBG),
    .pready_extsysx_dbg                          (PREADYEXTSYS0DBG),
    .pslverr_extsysx_dbg                         (PSLVERREXTSYS0DBG),
    .dpabort_extsysx_dbg                         (DPABORTEXTSYS0DBG),
    
    .psel_extsysx_extdbg                         (PSELEXTSYS0EXTDBG),
    .pwakeup_extsysx_extdbg                      (PWAKEUPEXTSYS0EXTDBG),
    .penable_extsysx_extdbg                      (PENABLEEXTSYS0EXTDBG),
    .paddr_extsysx_extdbg                        (PADDREXTSYS0EXTDBG),
    .pwrite_extsysx_extdbg                       (PWRITEEXTSYS0EXTDBG),
    .pwdata_extsysx_extdbg                       (PWDATAEXTSYS0EXTDBG),
    .pstrb_extsysx_extdbg                        (PSTRBEXTSYS0EXTDBG),
    .pprot_extsysx_extdbg                        (PPROTEXTSYS0EXTDBG),
    .prdata_extsysx_extdbg                       (PRDATAEXTSYS0EXTDBG),
    .pready_extsysx_extdbg                       (PREADYEXTSYS0EXTDBG),
    .pslverr_extsysx_extdbg                      (PSLVERREXTSYS0EXTDBG),
    
    .extsysx_ctichin                             (EXTSYS0CTICHIN),
    .extsysx_ctichout                            (EXTSYS0CTICHOUT),
    
    .qreqn_extsysx_aclk                          (EXTSYS0ACLKQREQn),
    .qacceptn_extsysx_aclk                       (EXTSYS0ACLKQACCEPTn),
    .qdeny_extsysx_aclk                          (EXTSYS0ACLKQDENY),
    .qactive_extsysx_aclk                        (EXTSYS0ACLKQACTIVE),
    
    .qreqn_extsysx_mhuclk                        (EXTSYS0MHUCLKQREQn),
    .qacceptn_extsysx_mhuclk                     (EXTSYS0MHUCLKQACCEPTn),
    .qdeny_extsysx_mhuclk                        (EXTSYS0MHUCLKQDENY),
    .qactive_extsysx_mhuclk                      (EXTSYS0MHUCLKQACTIVE),
    
    .qreqn_extsysx_atclk                         (EXTSYS0ATCLKQREQn),
    .qacceptn_extsysx_atclk                      (EXTSYS0ATCLKQACCEPTn),
    .qdeny_extsysx_atclk                         (EXTSYS0ATCLKQDENY),
    .qactive_extsysx_atclk                       (EXTSYS0ATCLKQACTIVE),
    
    .qreqn_extsysx_dbgclkm                       (EXTSYS0DBGCLKMQREQn),
    .qacceptn_extsysx_dbgclkm                    (EXTSYS0DBGCLKMQACCEPTn),
    .qdeny_extsysx_dbgclkm                       (EXTSYS0DBGCLKMQDENY),
    .qactive_extsysx_dbgclkm                     (EXTSYS0DBGCLKMQACTIVE),
    
    .qreqn_extsysx_dbgclks                       (EXTSYS0DBGCLKSQREQn),
    .qacceptn_extsysx_dbgclks                    (EXTSYS0DBGCLKSQACCEPTn),
    .qdeny_extsysx_dbgclks                       (EXTSYS0DBGCLKSQDENY),
    .qactive_extsysx_dbgclks                     (EXTSYS0DBGCLKSQACTIVE),
    
    .qreqn_extsysx_cticlk                        (EXTSYS0CTICLKQREQn),
    .qacceptn_extsysx_cticlk                     (EXTSYS0CTICLKQACCEPTn),
    .qdeny_extsysx_cticlk                        (EXTSYS0CTICLKQDENY),
    .qactive_extsysx_cticlk                      (EXTSYS0CTICLKQACTIVE),
    
    .qreqn_extsysx_mempwr                        (EXTSYS0MEMPWRQREQn),
    .qacceptn_extsysx_mempwr                     (EXTSYS0MEMPWRQACCEPTn),
    .qdeny_extsysx_mempwr                        (EXTSYS0MEMPWRQDENY),
    .qactive_extsysx_mempwr                      (EXTSYS0MEMPWRQACTIVE),
    
    .qreqn_extsysx_mhupwr                        (EXTSYS0MHUPWRQREQn),
    .qacceptn_extsysx_mhupwr                     (EXTSYS0MHUPWRQACCEPTn),
    .qdeny_extsysx_mhupwr                        (EXTSYS0MHUPWRQDENY),
    
    .qreqn_extsysx_traceexppwr                   (EXTSYS0TRACEEXPPWRQREQn),
    .qacceptn_extsysx_traceexppwr                (EXTSYS0TRACEEXPPWRQACCEPTn),
    .qdeny_extsysx_traceexppwr                   (EXTSYS0TRACEEXPPWRQDENY),
    .qactive_extsysx_traceexppwr                 (EXTSYS0TRACEEXPPWRQACTIVE),
    
    .qreqn_extsysx_extdbgpwr                     (EXTSYS0EXTDBGPWRQREQn),
    .qacceptn_extsysx_extdbgpwr                  (EXTSYS0EXTDBGPWRQACCEPTn),
    .qdeny_extsysx_extdbgpwr                     (EXTSYS0EXTDBGPWRQDENY),
    .qactive_extsysx_extdbgpwr                   (EXTSYS0EXTDBGPWRQACTIVE),
    
    .qreqn_extsysx_ctiinpwr                      (EXTSYS0CTIINPWRQREQn),
    .qacceptn_extsysx_ctiinpwr                   (EXTSYS0CTIINPWRQACCEPTn),
    .qdeny_extsysx_ctiinpwr                      (EXTSYS0CTIINPWRQDENY),
    .qactive_extsysx_ctiinpwr                    (EXTSYS0CTIINPWRQACTIVE),
    
    .apb_async_req_ehx_mhu_esh_0                 (apb_async_req_eh0_mhu_esh_0),
    .apb_async_req_payload_ehx_mhu_esh_0         (apb_async_req_payload_eh0_mhu_esh_0),
    .apb_async_resp_payload_ehx_mhu_esh_0        (apb_async_resp_payload_eh0_mhu_esh_0),
    .apb_async_ack_ehx_mhu_esh_0                 (apb_async_ack_eh0_mhu_esh_0),
    .recawake_async_ehx_mhu_esh_0                (recawake_async_eh0_mhu_esh_0),
    .recwakeup_async_ehx_mhu_esh_0               (recwakeup_async_eh0_mhu_esh_0),
    .edge_async_req_ehx_mhu_esh_0                (edge_async_req_eh0_mhu_esh_0),
    .edge_async_ack_ehx_mhu_esh_0                (edge_async_ack_eh0_mhu_esh_0),
    .apb_async_req_ehx_mhu_hes_0                 (apb_async_req_eh0_mhu_hes_0),
    
    .apb_async_req_payload_ehx_mhu_hes_0         (apb_async_req_payload_eh0_mhu_hes_0),
    .apb_async_resp_payload_ehx_mhu_hes_0        (apb_async_resp_payload_eh0_mhu_hes_0),
    .apb_async_ack_ehx_mhu_hes_0                 (apb_async_ack_eh0_mhu_hes_0),
    .recawake_async_ehx_mhu_hes_0                (recawake_async_eh0_mhu_hes_0),
    .recwakeup_async_ehx_mhu_hes_0               (recwakeup_async_eh0_mhu_hes_0),
    .edge_async_req_ehx_mhu_hes_0                (edge_async_req_eh0_mhu_hes_0),
    .edge_async_ack_ehx_mhu_hes_0                (edge_async_ack_eh0_mhu_hes_0),
    
      .apb_async_req_ehx_mhu_esh_1                 (apb_async_req_eh0_mhu_esh_1),
    .apb_async_req_payload_ehx_mhu_esh_1         (apb_async_req_payload_eh0_mhu_esh_1),
    .apb_async_resp_payload_ehx_mhu_esh_1        (apb_async_resp_payload_eh0_mhu_esh_1),
    .apb_async_ack_ehx_mhu_esh_1                 (apb_async_ack_eh0_mhu_esh_1),
    .recawake_async_ehx_mhu_esh_1                (recawake_async_eh0_mhu_esh_1),
    .recwakeup_async_ehx_mhu_esh_1               (recwakeup_async_eh0_mhu_esh_1),
    .edge_async_req_ehx_mhu_esh_1                (edge_async_req_eh0_mhu_esh_1),
    .edge_async_ack_ehx_mhu_esh_1                (edge_async_ack_eh0_mhu_esh_1),
    
    .apb_async_req_ehx_mhu_hes_1                 (apb_async_req_eh0_mhu_hes_1),
    .apb_async_req_payload_ehx_mhu_hes_1         (apb_async_req_payload_eh0_mhu_hes_1),
    .apb_async_resp_payload_ehx_mhu_hes_1        (apb_async_resp_payload_eh0_mhu_hes_1),
    .apb_async_ack_ehx_mhu_hes_1                 (apb_async_ack_eh0_mhu_hes_1),
    .recawake_async_ehx_mhu_hes_1                (recawake_async_eh0_mhu_hes_1),
    .recwakeup_async_ehx_mhu_hes_1               (recwakeup_async_eh0_mhu_hes_1),
    .edge_async_req_ehx_mhu_hes_1                (edge_async_req_eh0_mhu_hes_1),
    .edge_async_ack_ehx_mhu_hes_1                (edge_async_ack_eh0_mhu_hes_1), 
      
    .apb_async_req_ehx_mhu_esse_0                (mhu_es0se0_apb_async_req),
    .apb_async_req_payload_ehx_mhu_esse_0        (mhu_es0se0_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_esse_0       (mhu_es0se0_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_esse_0                (mhu_es0se0_apb_async_ack),
    .recawake_async_ehx_mhu_esse_0               (mhu_es0se0_recawake_async),
    .recwakeup_async_ehx_mhu_esse_0              (mhu_es0se0_recwakeup_async),
    .edge_async_req_ehx_mhu_esse_0               (mhu_es0se0_edge_async_req),
    .edge_async_ack_ehx_mhu_esse_0               (mhu_es0se0_edge_async_ack),
    
    .apb_async_req_ehx_mhu_sees_0                (mhu_sees00_apb_async_req),
    .apb_async_req_payload_ehx_mhu_sees_0        (mhu_sees00_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_sees_0       (mhu_sees00_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_sees_0                (mhu_sees00_apb_async_ack),
    .recawake_async_ehx_mhu_sees_0               (mhu_sees00_recawake_async),
    .recwakeup_async_ehx_mhu_sees_0              (mhu_sees00_recwakeup_async),
    .edge_async_req_ehx_mhu_sees_0               (mhu_sees00_edge_async_req),
    .edge_async_ack_ehx_mhu_sees_0               (mhu_sees00_edge_async_ack),
  
     
    .apb_async_req_ehx_mhu_esse_1                (mhu_es0se1_apb_async_req),
    .apb_async_req_payload_ehx_mhu_esse_1        (mhu_es0se1_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_esse_1       (mhu_es0se1_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_esse_1                (mhu_es0se1_apb_async_ack),
    .recawake_async_ehx_mhu_esse_1               (mhu_es0se1_recawake_async),
    .recwakeup_async_ehx_mhu_esse_1              (mhu_es0se1_recwakeup_async),
    .edge_async_req_ehx_mhu_esse_1               (mhu_es0se1_edge_async_req),
    .edge_async_ack_ehx_mhu_esse_1               (mhu_es0se1_edge_async_ack),
                                                 
    .apb_async_req_ehx_mhu_sees_1                (mhu_sees01_apb_async_req),
    .apb_async_req_payload_ehx_mhu_sees_1        (mhu_sees01_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_sees_1       (mhu_sees01_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_sees_1                (mhu_sees01_apb_async_ack),
    .recawake_async_ehx_mhu_sees_1               (mhu_sees01_recawake_async),
    .recwakeup_async_ehx_mhu_sees_1              (mhu_sees01_recwakeup_async),
    .edge_async_req_ehx_mhu_sees_1               (mhu_sees01_edge_async_req),
    .edge_async_ack_ehx_mhu_sees_1               (mhu_sees01_edge_async_ack),
      .slvmustacceptreqn_async_ehx                 (slvmustacceptreqn_async_eh0),
    .slvcandenyreqn_async_ehx                    (slvcandenyreqn_async_eh0),
    .slvacceptn_async_ehx                        (slvacceptn_async_eh0),
    .slvdeny_async_ehx                           (slvdeny_async_eh0),
    .si_to_mi_wakeup_async_ehx                   (si_to_mi_wakeup_async_eh0),
    .mi_to_si_wakeup_async_ehx                   (mi_to_si_wakeup_async_eh0),
    .aw_wr_ptr_async_ehx                         (aw_wr_ptr_async_eh0),
    .aw_rd_ptr_async_ehx                         (aw_rd_ptr_async_eh0),
    .aw_payld_async_ehx                          (aw_payld_async_eh0),
    .w_wr_ptr_async_ehx                          (w_wr_ptr_async_eh0),
    .w_rd_ptr_async_ehx                          (w_rd_ptr_async_eh0),
    .w_payld_async_ehx                           (w_payld_async_eh0),
    .b_wr_ptr_async_ehx                          (b_wr_ptr_async_eh0),
    .b_rd_ptr_async_ehx                          (b_rd_ptr_async_eh0),
    .b_payld_async_ehx                           (b_payld_async_eh0),
    .ar_wr_ptr_async_ehx                         (ar_wr_ptr_async_eh0),
    .ar_rd_ptr_async_ehx                         (ar_rd_ptr_async_eh0),
    .ar_payld_async_ehx                          (ar_payld_async_eh0),
    .r_wr_ptr_async_ehx                          (r_wr_ptr_async_eh0),
    .r_rd_ptr_async_ehx                          (r_rd_ptr_async_eh0),
    .r_payld_async_ehx                           (r_payld_async_eh0),
    
    .pulse_req_ehx_cti_out                       (pulse_req_eh0_cti_out),
    .pulse_ack_ehx_cti_out                       (pulse_ack_eh0_cti_out),
    .pulse_ack_ehx_cti_in                        (pulse_ack_eh0_cti_in),
    .pulse_req_ehx_cti_in                        (pulse_req_eh0_cti_in),
    
    .rd_pointer_gray_ehx                         (rd_pointer_gray_eh0),
    .flush_req_ehx                               (flush_req_eh0),
    .sync_done_ehx                               (sync_done_eh0),
    .syncreq_async_req_ehx                       (syncreq_async_req_eh0),
    .flush_done_ehx                              (flush_done_eh0),
    .sync_clear_ehx                              (sync_clear_eh0),
    .wr_pointer_gray_ehx                         (wr_pointer_gray_eh0),
    .atb_fwd_data_ehx                            (atb_fwd_data_eh0),
    .syncreq_async_ack_ehx                       (syncreq_async_ack_eh0),
    
    .apb_async_req_ehx_extdbg                    (apb_async_req_eh0_extdbg),
    .apb_async_req_payload_ehx_extdbg            (apb_async_req_payload_eh0_extdbg),
    .apb_async_resp_payload_ehx_extdbg           (apb_async_resp_payload_eh0_extdbg),
    .apb_async_ack_ehx_extdbg                    (apb_async_ack_eh0_extdbg),
    
    .apb_async_req_ehx_dbg                       (apb_async_req_eh0_dbg),
    .apb_async_req_payload_ehx_dbg               (apb_async_req_payload_eh0_dbg),
    .apb_async_resp_payload_ehx_dbg              (apb_async_resp_payload_eh0_dbg),
    .apb_async_ack_ehx_dbg                       (apb_async_ack_eh0_dbg),
    
    .dpabort_pulse_req_ehx                       (dpabort_pulse_req_eh0),
    .dpabort_pulse_ack_ehx                       (dpabort_pulse_ack_eh0),
    
    .dftcgen                                     (DFTCGEN),
    .dftrstdisable                               (DFTRSTDISABLE[0])
  );
  
  assign EXTSYS0EXTDBGROMCDBGPWRUPREQ = extdbg_cdbgpwrupreq[1];   
  assign EXTSYS0AXIAPROMCSYSPWRUPREQ  = axiap_csyspwrupreq_int[2];  
  
  assign extdbg_cdbgpwrupack[1]       = EXTSYS0EXTDBGROMCDBGPWRUPACK; 
  assign axiap_csyspwrupack_int[2]    = EXTSYS0AXIAPROMCSYSPWRUPACK;  
  
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (3)
  ) u_arm_element_or_tree_es0 (
    .or_tree_i  ({mhu_sees00_recwakeup_async, mhu_sees01_recwakeup_async, extsys0mhupwrreqactiveq_systop}),
    .or_tree_o  (EXTSYS0MHUPWRREQACTIVE)
  );  
  
  eh_f0_aontop u_eh0_f0_aontop (          
    .refclk                               (aondbgclk),
    .refclk_resetn                        (refclk_aontopporesetn),
    .psel_ehx_extdbg                      (psel_ehx0_extdbg),
    .penable_ehx_extdbg                   (penable_ehx0_extdbg),
    .paddr_ehx_extdbg                     (paddr_ehx0_extdbg),
    .pwrite_ehx_extdbg                    (pwrite_ehx0_extdbg),
    .pwdata_ehx_extdbg                    (pwdata_ehx0_extdbg),
    .pprot_ehx_extdbg                     (pprot_ehx0_extdbg),
    .prdata_ehx_extdbg                    (prdata_ehx0_extdbg),
    .pready_ehx_extdbg                    (pready_ehx0_extdbg),
    .pslverr_ehx_extdbg                   (pslverr_ehx0_extdbg),
    .pwakeup_ehx_extdbg                   (pwakeup_ehx0_extdbg),
    .apb_async_req_ehx_extdbg             (apb_async_req_eh0_extdbg),
    .apb_async_req_payload_ehx_extdbg     (apb_async_req_payload_eh0_extdbg),
    .apb_async_resp_payload_ehx_extdbg    (apb_async_resp_payload_eh0_extdbg),
    .apb_async_ack_ehx_extdbg             (apb_async_ack_eh0_extdbg),
    .qreqn_ehx_refclk                     (qreqn_eh0_refclk),
    .qacceptn_ehx_refclk                  (qacceptn_eh0_refclk),
    .qdeny_ehx_refclk                     (qdeny_eh0_refclk),
    .qactive_ehx_refclk                   (qactive_eh0_refclk),
    .dftcgen                              (DFTCGEN)
    );    


  pd_extsys1top_f0 #(
    
    .MHU_HESX0_NUM_CH                            (MHU_HES10_NUM_CH), 
    .MHU_ESXH0_NUM_CH                            (MHU_ES1H0_NUM_CH), 
    .MHU_SEESX0_NUM_CH                           (MHU_SEES10_NUM_CH), 
    .MHU_ESXSE0_NUM_CH                           (MHU_ES1SE0_NUM_CH),
    
    
    .MHU_HESX1_NUM_CH                            (MHU_HES11_NUM_CH), 
    .MHU_ESXH1_NUM_CH                            (MHU_ES1H1_NUM_CH), 
    .MHU_SEESX1_NUM_CH                           (MHU_SEES11_NUM_CH), 
    .MHU_ESXSE1_NUM_CH                           (MHU_ES1SE1_NUM_CH),   
      .EXT_SYSX_MEM_ADDR_WIDTH                     (EXT_SYS1_MEM_ADDR_WIDTH),
    .EXT_SYSX_MEM_DATA_WIDTH                     (EXT_SYS1_MEM_DATA_WIDTH),
    .EXT_SYSX_MEM_AWID_WIDTH                     (EXT_SYS1_MEM_AWID_WIDTH),
    .EXT_SYSX_MEM_ARID_WIDTH                     (EXT_SYS1_MEM_ARID_WIDTH),
    .EXT_SYSX_MEM_AWUSER_WIDTH                   (EXT_SYS1_MEM_AWUSER_WIDTH),
    .EXT_SYSX_MEM_WUSER_WIDTH                    (EXT_SYS1_MEM_WUSER_WIDTH),
    .EXT_SYSX_MEM_BUSER_WIDTH                    (EXT_SYS1_MEM_BUSER_WIDTH),
    .EXT_SYSX_MEM_ARUSER_WIDTH                   (EXT_SYS1_MEM_ARUSER_WIDTH),
    .EXT_SYSX_MEM_RUSER_WIDTH                    (EXT_SYS1_MEM_RUSER_WIDTH),
    .EXT_SYSX_MEM_AW_FIFO_DEPTH                  (EXT_SYS1_MEM_AW_FIFO_DEPTH),
    .EXT_SYSX_MEM_W_FIFO_DEPTH                   (EXT_SYS1_MEM_W_FIFO_DEPTH),
    .EXT_SYSX_MEM_B_FIFO_DEPTH                   (EXT_SYS1_MEM_B_FIFO_DEPTH),
    .EXT_SYSX_MEM_AR_FIFO_DEPTH                  (EXT_SYS1_MEM_AR_FIFO_DEPTH),
    .EXT_SYSX_MEM_R_FIFO_DEPTH                   (EXT_SYS1_MEM_R_FIFO_DEPTH),
    .EXT_SYSX_MEM_AW_PAYLOAD_WIDTH               (EXT_SYS1_MEM_AW_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_W_PAYLOAD_WIDTH                (EXT_SYS1_MEM_W_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_B_PAYLOAD_WIDTH                (EXT_SYS1_MEM_B_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_AR_PAYLOAD_WIDTH               (EXT_SYS1_MEM_AR_PAYLOAD_WIDTH),
    .EXT_SYSX_MEM_R_PAYLOAD_WIDTH                (EXT_SYS1_MEM_R_PAYLOAD_WIDTH)
    
  ) u_pd_extsys1top (
    .extsysx_dbgclks                             (EXTSYS1DBGCLKS),
    .extsysx_dbgclkm                             (EXTSYS1DBGCLKM),
    .extsysx_atclk                               (EXTSYS1ATCLK),
    .extsysx_cticlk                              (EXTSYS1CTICLK),
    .extsysx_aclk                                (EXTSYS1ACLK),
    .extsysx_mhuclk                              (EXTSYS1MHUCLK),
    
    .extsysx_dbgpresetsn                         (EXTSYS1DBGPRESETSn),
    .extsysx_dbgpresetmn                         (EXTSYS1DBGPRESETMn),
    .extsysx_atresetn                            (EXTSYS1ATRESETn),
    .extsysx_ctiresetn                           (EXTSYS1CTIRESETn),
    .extsysx_aresetn                             (EXTSYS1ARESETn),
    .extsysx_mhuresetn                           (EXTSYS1MHURESETn),
    
    .awakeup_extsysx_mem                         (AWAKEUPEXTSYS1MEM),
    .awid_extsysx_mem                            (AWIDEXTSYS1MEM),
    .awaddr_extsysx_mem                          (AWADDREXTSYS1MEM),
    .awlen_extsysx_mem                           (AWLENEXTSYS1MEM),
    .awsize_extsysx_mem                          (AWSIZEEXTSYS1MEM),
    .awburst_extsysx_mem                         (AWBURSTEXTSYS1MEM),
    .awlock_extsysx_mem                          (AWLOCKEXTSYS1MEM),
    .awcache_extsysx_mem                         (AWCACHEEXTSYS1MEM),
    .awprot_extsysx_mem                          (AWPROTEXTSYS1MEM),
    .awregion_extsysx_mem                        (AWREGIONEXTSYS1MEM),
    .awvalid_extsysx_mem                         (AWVALIDEXTSYS1MEM),
    .awready_extsysx_mem                         (AWREADYEXTSYS1MEM),
    .wstrb_extsysx_mem                           (WSTRBEXTSYS1MEM),
    .wlast_extsysx_mem                           (WLASTEXTSYS1MEM),
    .wvalid_extsysx_mem                          (WVALIDEXTSYS1MEM),
    .wdata_extsysx_mem                           (WDATAEXTSYS1MEM),
    .wready_extsysx_mem                          (WREADYEXTSYS1MEM),
    .bid_extsysx_mem                             (BIDEXTSYS1MEM),
    .bresp_extsysx_mem                           (BRESPEXTSYS1MEM),
    .bvalid_extsysx_mem                          (BVALIDEXTSYS1MEM),
    .bready_extsysx_mem                          (BREADYEXTSYS1MEM),
    .arid_extsysx_mem                            (ARIDEXTSYS1MEM),
    .araddr_extsysx_mem                          (ARADDREXTSYS1MEM),
    .arlen_extsysx_mem                           (ARLENEXTSYS1MEM),
    .arsize_extsysx_mem                          (ARSIZEEXTSYS1MEM),
    .arburst_extsysx_mem                         (ARBURSTEXTSYS1MEM),
    .arlock_extsysx_mem                          (ARLOCKEXTSYS1MEM),
    .arcache_extsysx_mem                         (ARCACHEEXTSYS1MEM),
    .arprot_extsysx_mem                          (ARPROTEXTSYS1MEM),
    .arregion_extsysx_mem                        (ARREGIONEXTSYS1MEM),
    .arvalid_extsysx_mem                         (ARVALIDEXTSYS1MEM),
    .arready_extsysx_mem                         (ARREADYEXTSYS1MEM),
    .rid_extsysx_mem                             (RIDEXTSYS1MEM),
    .rresp_extsysx_mem                           (RRESPEXTSYS1MEM),
    .rlast_extsysx_mem                           (RLASTEXTSYS1MEM),
    .rvalid_extsysx_mem                          (RVALIDEXTSYS1MEM),
    .rdata_extsysx_mem                           (RDATAEXTSYS1MEM),
    .rready_extsysx_mem                          (RREADYEXTSYS1MEM),
    .psel_extsysx_mhu                            (PSELEXTSYS1MHU),
    .pwakeup_extsysx_mhu                         (PWAKEUPEXTSYS1MHU),
    .penable_extsysx_mhu                         (PENABLEEXTSYS1MHU),
    .paddr_extsysx_mhu                           (PADDREXTSYS1MHU),
    .pwrite_extsysx_mhu                          (PWRITEEXTSYS1MHU),
    .pwdata_extsysx_mhu                          (PWDATAEXTSYS1MHU),
    .pstrb_extsysx_mhu                           (PSTRBEXTSYS1MHU),
    .pprot_extsysx_mhu                           (PPROTEXTSYS1MHU),
    .prdata_extsysx_mhu                          (PRDATAEXTSYS1MHU),
    .pready_extsysx_mhu                          (PREADYEXTSYS1MHU),
    .pslverr_extsysx_mhu                         (PSLVERREXTSYS1MHU),
    
    .esh0_extsysx_mhuint                         (ESH0EXTSYS1MHUINT),
    .hes0_extsysx_mhuint                         (HES0EXTSYS1MHUINT),
    .esse0_extsysx_mhuint                        (ESSE0EXTSYS1MHUINT),
    .sees0_extsysx_mhuint                        (SEES0EXTSYS1MHUINT),
      .esh1_extsysx_mhuint                         (ESH1EXTSYS1MHUINT),
    .hes1_extsysx_mhuint                         (HES1EXTSYS1MHUINT),
    .esse1_extsysx_mhuint                        (ESSE1EXTSYS1MHUINT),
    .sees1_extsysx_mhuint                        (SEES1EXTSYS1MHUINT),
      
    .atready_extsysx_traceexp                    (ATREADYEXTSYS1TRACEEXP),
    .afvalid_extsysx_traceexp                    (AFVALIDEXTSYS1TRACEEXP),
    .syncreq_extsysx_traceexp                    (SYNCREQEXTSYS1TRACEEXP),
    .atid_extsysx_traceexp                       (ATIDEXTSYS1TRACEEXP),
    .atvalid_extsysx_traceexp                    (ATVALIDEXTSYS1TRACEEXP),
    .atdata_extsysx_traceexp                     (ATDATAEXTSYS1TRACEEXP),
    .atbytes_extsysx_traceexp                    (ATBYTESEXTSYS1TRACEEXP),
    .afready_extsysx_traceexp                    (AFREADYEXTSYS1TRACEEXP),
    .atwakeup_extsysx_traceexp                   (ATWAKEUPEXTSYS1TRACEEXP),
    
    .psel_extsysx_dbg                            (PSELEXTSYS1DBG),
    .pwakeup_extsysx_dbg                         (PWAKEUPEXTSYS1DBG),
    .penable_extsysx_dbg                         (PENABLEEXTSYS1DBG),
    .paddr_extsysx_dbg                           (PADDREXTSYS1DBG),
    .pwrite_extsysx_dbg                          (PWRITEEXTSYS1DBG),
    .pwdata_extsysx_dbg                          (PWDATAEXTSYS1DBG),
    .pstrb_extsysx_dbg                           (PSTRBEXTSYS1DBG),
    .pprot_extsysx_dbg                           (PPROTEXTSYS1DBG),
    .prdata_extsysx_dbg                          (PRDATAEXTSYS1DBG),
    .pready_extsysx_dbg                          (PREADYEXTSYS1DBG),
    .pslverr_extsysx_dbg                         (PSLVERREXTSYS1DBG),
    .dpabort_extsysx_dbg                         (DPABORTEXTSYS1DBG),
    
    .psel_extsysx_extdbg                         (PSELEXTSYS1EXTDBG),
    .pwakeup_extsysx_extdbg                      (PWAKEUPEXTSYS1EXTDBG),
    .penable_extsysx_extdbg                      (PENABLEEXTSYS1EXTDBG),
    .paddr_extsysx_extdbg                        (PADDREXTSYS1EXTDBG),
    .pwrite_extsysx_extdbg                       (PWRITEEXTSYS1EXTDBG),
    .pwdata_extsysx_extdbg                       (PWDATAEXTSYS1EXTDBG),
    .pstrb_extsysx_extdbg                        (PSTRBEXTSYS1EXTDBG),
    .pprot_extsysx_extdbg                        (PPROTEXTSYS1EXTDBG),
    .prdata_extsysx_extdbg                       (PRDATAEXTSYS1EXTDBG),
    .pready_extsysx_extdbg                       (PREADYEXTSYS1EXTDBG),
    .pslverr_extsysx_extdbg                      (PSLVERREXTSYS1EXTDBG),
    
    .extsysx_ctichin                             (EXTSYS1CTICHIN),
    .extsysx_ctichout                            (EXTSYS1CTICHOUT),
    
    .qreqn_extsysx_aclk                          (EXTSYS1ACLKQREQn),
    .qacceptn_extsysx_aclk                       (EXTSYS1ACLKQACCEPTn),
    .qdeny_extsysx_aclk                          (EXTSYS1ACLKQDENY),
    .qactive_extsysx_aclk                        (EXTSYS1ACLKQACTIVE),
    
    .qreqn_extsysx_mhuclk                        (EXTSYS1MHUCLKQREQn),
    .qacceptn_extsysx_mhuclk                     (EXTSYS1MHUCLKQACCEPTn),
    .qdeny_extsysx_mhuclk                        (EXTSYS1MHUCLKQDENY),
    .qactive_extsysx_mhuclk                      (EXTSYS1MHUCLKQACTIVE),
    
    .qreqn_extsysx_atclk                         (EXTSYS1ATCLKQREQn),
    .qacceptn_extsysx_atclk                      (EXTSYS1ATCLKQACCEPTn),
    .qdeny_extsysx_atclk                         (EXTSYS1ATCLKQDENY),
    .qactive_extsysx_atclk                       (EXTSYS1ATCLKQACTIVE),
    
    .qreqn_extsysx_dbgclkm                       (EXTSYS1DBGCLKMQREQn),
    .qacceptn_extsysx_dbgclkm                    (EXTSYS1DBGCLKMQACCEPTn),
    .qdeny_extsysx_dbgclkm                       (EXTSYS1DBGCLKMQDENY),
    .qactive_extsysx_dbgclkm                     (EXTSYS1DBGCLKMQACTIVE),
    
    .qreqn_extsysx_dbgclks                       (EXTSYS1DBGCLKSQREQn),
    .qacceptn_extsysx_dbgclks                    (EXTSYS1DBGCLKSQACCEPTn),
    .qdeny_extsysx_dbgclks                       (EXTSYS1DBGCLKSQDENY),
    .qactive_extsysx_dbgclks                     (EXTSYS1DBGCLKSQACTIVE),
    
    .qreqn_extsysx_cticlk                        (EXTSYS1CTICLKQREQn),
    .qacceptn_extsysx_cticlk                     (EXTSYS1CTICLKQACCEPTn),
    .qdeny_extsysx_cticlk                        (EXTSYS1CTICLKQDENY),
    .qactive_extsysx_cticlk                      (EXTSYS1CTICLKQACTIVE),
    
    .qreqn_extsysx_mempwr                        (EXTSYS1MEMPWRQREQn),
    .qacceptn_extsysx_mempwr                     (EXTSYS1MEMPWRQACCEPTn),
    .qdeny_extsysx_mempwr                        (EXTSYS1MEMPWRQDENY),
    .qactive_extsysx_mempwr                      (EXTSYS1MEMPWRQACTIVE),
    
    .qreqn_extsysx_mhupwr                        (EXTSYS1MHUPWRQREQn),
    .qacceptn_extsysx_mhupwr                     (EXTSYS1MHUPWRQACCEPTn),
    .qdeny_extsysx_mhupwr                        (EXTSYS1MHUPWRQDENY),
    
    .qreqn_extsysx_traceexppwr                   (EXTSYS1TRACEEXPPWRQREQn),
    .qacceptn_extsysx_traceexppwr                (EXTSYS1TRACEEXPPWRQACCEPTn),
    .qdeny_extsysx_traceexppwr                   (EXTSYS1TRACEEXPPWRQDENY),
    .qactive_extsysx_traceexppwr                 (EXTSYS1TRACEEXPPWRQACTIVE),
    
    .qreqn_extsysx_extdbgpwr                     (EXTSYS1EXTDBGPWRQREQn),
    .qacceptn_extsysx_extdbgpwr                  (EXTSYS1EXTDBGPWRQACCEPTn),
    .qdeny_extsysx_extdbgpwr                     (EXTSYS1EXTDBGPWRQDENY),
    .qactive_extsysx_extdbgpwr                   (EXTSYS1EXTDBGPWRQACTIVE),
    
    .qreqn_extsysx_ctiinpwr                      (EXTSYS1CTIINPWRQREQn),
    .qacceptn_extsysx_ctiinpwr                   (EXTSYS1CTIINPWRQACCEPTn),
    .qdeny_extsysx_ctiinpwr                      (EXTSYS1CTIINPWRQDENY),
    .qactive_extsysx_ctiinpwr                    (EXTSYS1CTIINPWRQACTIVE),
    
    .apb_async_req_ehx_mhu_esh_0                 (apb_async_req_eh1_mhu_esh_0),
    .apb_async_req_payload_ehx_mhu_esh_0         (apb_async_req_payload_eh1_mhu_esh_0),
    .apb_async_resp_payload_ehx_mhu_esh_0        (apb_async_resp_payload_eh1_mhu_esh_0),
    .apb_async_ack_ehx_mhu_esh_0                 (apb_async_ack_eh1_mhu_esh_0),
    .recawake_async_ehx_mhu_esh_0                (recawake_async_eh1_mhu_esh_0),
    .recwakeup_async_ehx_mhu_esh_0               (recwakeup_async_eh1_mhu_esh_0),
    .edge_async_req_ehx_mhu_esh_0                (edge_async_req_eh1_mhu_esh_0),
    .edge_async_ack_ehx_mhu_esh_0                (edge_async_ack_eh1_mhu_esh_0),
    .apb_async_req_ehx_mhu_hes_0                 (apb_async_req_eh1_mhu_hes_0),
    
    .apb_async_req_payload_ehx_mhu_hes_0         (apb_async_req_payload_eh1_mhu_hes_0),
    .apb_async_resp_payload_ehx_mhu_hes_0        (apb_async_resp_payload_eh1_mhu_hes_0),
    .apb_async_ack_ehx_mhu_hes_0                 (apb_async_ack_eh1_mhu_hes_0),
    .recawake_async_ehx_mhu_hes_0                (recawake_async_eh1_mhu_hes_0),
    .recwakeup_async_ehx_mhu_hes_0               (recwakeup_async_eh1_mhu_hes_0),
    .edge_async_req_ehx_mhu_hes_0                (edge_async_req_eh1_mhu_hes_0),
    .edge_async_ack_ehx_mhu_hes_0                (edge_async_ack_eh1_mhu_hes_0),
    
      .apb_async_req_ehx_mhu_esh_1                 (apb_async_req_eh1_mhu_esh_1),
    .apb_async_req_payload_ehx_mhu_esh_1         (apb_async_req_payload_eh1_mhu_esh_1),
    .apb_async_resp_payload_ehx_mhu_esh_1        (apb_async_resp_payload_eh1_mhu_esh_1),
    .apb_async_ack_ehx_mhu_esh_1                 (apb_async_ack_eh1_mhu_esh_1),
    .recawake_async_ehx_mhu_esh_1                (recawake_async_eh1_mhu_esh_1),
    .recwakeup_async_ehx_mhu_esh_1               (recwakeup_async_eh1_mhu_esh_1),
    .edge_async_req_ehx_mhu_esh_1                (edge_async_req_eh1_mhu_esh_1),
    .edge_async_ack_ehx_mhu_esh_1                (edge_async_ack_eh1_mhu_esh_1),
    
    .apb_async_req_ehx_mhu_hes_1                 (apb_async_req_eh1_mhu_hes_1),
    .apb_async_req_payload_ehx_mhu_hes_1         (apb_async_req_payload_eh1_mhu_hes_1),
    .apb_async_resp_payload_ehx_mhu_hes_1        (apb_async_resp_payload_eh1_mhu_hes_1),
    .apb_async_ack_ehx_mhu_hes_1                 (apb_async_ack_eh1_mhu_hes_1),
    .recawake_async_ehx_mhu_hes_1                (recawake_async_eh1_mhu_hes_1),
    .recwakeup_async_ehx_mhu_hes_1               (recwakeup_async_eh1_mhu_hes_1),
    .edge_async_req_ehx_mhu_hes_1                (edge_async_req_eh1_mhu_hes_1),
    .edge_async_ack_ehx_mhu_hes_1                (edge_async_ack_eh1_mhu_hes_1), 
      
    .apb_async_req_ehx_mhu_esse_0                (mhu_es1se0_apb_async_req),
    .apb_async_req_payload_ehx_mhu_esse_0        (mhu_es1se0_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_esse_0       (mhu_es1se0_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_esse_0                (mhu_es1se0_apb_async_ack),
    .recawake_async_ehx_mhu_esse_0               (mhu_es1se0_recawake_async),
    .recwakeup_async_ehx_mhu_esse_0              (mhu_es1se0_recwakeup_async),
    .edge_async_req_ehx_mhu_esse_0               (mhu_es1se0_edge_async_req),
    .edge_async_ack_ehx_mhu_esse_0               (mhu_es1se0_edge_async_ack),
    
    .apb_async_req_ehx_mhu_sees_0                (mhu_sees10_apb_async_req),
    .apb_async_req_payload_ehx_mhu_sees_0        (mhu_sees10_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_sees_0       (mhu_sees10_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_sees_0                (mhu_sees10_apb_async_ack),
    .recawake_async_ehx_mhu_sees_0               (mhu_sees10_recawake_async),
    .recwakeup_async_ehx_mhu_sees_0              (mhu_sees10_recwakeup_async),
    .edge_async_req_ehx_mhu_sees_0               (mhu_sees10_edge_async_req),
    .edge_async_ack_ehx_mhu_sees_0               (mhu_sees10_edge_async_ack),
  
     
    .apb_async_req_ehx_mhu_esse_1                (mhu_es1se1_apb_async_req),
    .apb_async_req_payload_ehx_mhu_esse_1        (mhu_es1se1_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_esse_1       (mhu_es1se1_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_esse_1                (mhu_es1se1_apb_async_ack),
    .recawake_async_ehx_mhu_esse_1               (mhu_es1se1_recawake_async),
    .recwakeup_async_ehx_mhu_esse_1              (mhu_es1se1_recwakeup_async),
    .edge_async_req_ehx_mhu_esse_1               (mhu_es1se1_edge_async_req),
    .edge_async_ack_ehx_mhu_esse_1               (mhu_es1se1_edge_async_ack),
                                                 
    .apb_async_req_ehx_mhu_sees_1                (mhu_sees11_apb_async_req),
    .apb_async_req_payload_ehx_mhu_sees_1        (mhu_sees11_apb_async_req_payload),
    .apb_async_resp_payload_ehx_mhu_sees_1       (mhu_sees11_apb_async_resp_payload),
    .apb_async_ack_ehx_mhu_sees_1                (mhu_sees11_apb_async_ack),
    .recawake_async_ehx_mhu_sees_1               (mhu_sees11_recawake_async),
    .recwakeup_async_ehx_mhu_sees_1              (mhu_sees11_recwakeup_async),
    .edge_async_req_ehx_mhu_sees_1               (mhu_sees11_edge_async_req),
    .edge_async_ack_ehx_mhu_sees_1               (mhu_sees11_edge_async_ack),
      .slvmustacceptreqn_async_ehx                 (slvmustacceptreqn_async_eh1),
    .slvcandenyreqn_async_ehx                    (slvcandenyreqn_async_eh1),
    .slvacceptn_async_ehx                        (slvacceptn_async_eh1),
    .slvdeny_async_ehx                           (slvdeny_async_eh1),
    .si_to_mi_wakeup_async_ehx                   (si_to_mi_wakeup_async_eh1),
    .mi_to_si_wakeup_async_ehx                   (mi_to_si_wakeup_async_eh1),
    .aw_wr_ptr_async_ehx                         (aw_wr_ptr_async_eh1),
    .aw_rd_ptr_async_ehx                         (aw_rd_ptr_async_eh1),
    .aw_payld_async_ehx                          (aw_payld_async_eh1),
    .w_wr_ptr_async_ehx                          (w_wr_ptr_async_eh1),
    .w_rd_ptr_async_ehx                          (w_rd_ptr_async_eh1),
    .w_payld_async_ehx                           (w_payld_async_eh1),
    .b_wr_ptr_async_ehx                          (b_wr_ptr_async_eh1),
    .b_rd_ptr_async_ehx                          (b_rd_ptr_async_eh1),
    .b_payld_async_ehx                           (b_payld_async_eh1),
    .ar_wr_ptr_async_ehx                         (ar_wr_ptr_async_eh1),
    .ar_rd_ptr_async_ehx                         (ar_rd_ptr_async_eh1),
    .ar_payld_async_ehx                          (ar_payld_async_eh1),
    .r_wr_ptr_async_ehx                          (r_wr_ptr_async_eh1),
    .r_rd_ptr_async_ehx                          (r_rd_ptr_async_eh1),
    .r_payld_async_ehx                           (r_payld_async_eh1),
    
    .pulse_req_ehx_cti_out                       (pulse_req_eh1_cti_out),
    .pulse_ack_ehx_cti_out                       (pulse_ack_eh1_cti_out),
    .pulse_ack_ehx_cti_in                        (pulse_ack_eh1_cti_in),
    .pulse_req_ehx_cti_in                        (pulse_req_eh1_cti_in),
    
    .rd_pointer_gray_ehx                         (rd_pointer_gray_eh1),
    .flush_req_ehx                               (flush_req_eh1),
    .sync_done_ehx                               (sync_done_eh1),
    .syncreq_async_req_ehx                       (syncreq_async_req_eh1),
    .flush_done_ehx                              (flush_done_eh1),
    .sync_clear_ehx                              (sync_clear_eh1),
    .wr_pointer_gray_ehx                         (wr_pointer_gray_eh1),
    .atb_fwd_data_ehx                            (atb_fwd_data_eh1),
    .syncreq_async_ack_ehx                       (syncreq_async_ack_eh1),
    
    .apb_async_req_ehx_extdbg                    (apb_async_req_eh1_extdbg),
    .apb_async_req_payload_ehx_extdbg            (apb_async_req_payload_eh1_extdbg),
    .apb_async_resp_payload_ehx_extdbg           (apb_async_resp_payload_eh1_extdbg),
    .apb_async_ack_ehx_extdbg                    (apb_async_ack_eh1_extdbg),
    
    .apb_async_req_ehx_dbg                       (apb_async_req_eh1_dbg),
    .apb_async_req_payload_ehx_dbg               (apb_async_req_payload_eh1_dbg),
    .apb_async_resp_payload_ehx_dbg              (apb_async_resp_payload_eh1_dbg),
    .apb_async_ack_ehx_dbg                       (apb_async_ack_eh1_dbg),
    
    .dpabort_pulse_req_ehx                       (dpabort_pulse_req_eh1),
    .dpabort_pulse_ack_ehx                       (dpabort_pulse_ack_eh1),
    
    .dftcgen                                     (DFTCGEN),
    .dftrstdisable                               (DFTRSTDISABLE[0])
  );
  
  assign EXTSYS1EXTDBGROMCDBGPWRUPREQ = extdbg_cdbgpwrupreq[2];   
  assign EXTSYS1AXIAPROMCSYSPWRUPREQ  = axiap_csyspwrupreq_int[3];  
  
  assign extdbg_cdbgpwrupack[2]       = EXTSYS1EXTDBGROMCDBGPWRUPACK; 
  assign axiap_csyspwrupack_int[3]    = EXTSYS1AXIAPROMCSYSPWRUPACK;  
  
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (3)
  ) u_arm_element_or_tree_es1 (
    .or_tree_i  ({mhu_sees10_recwakeup_async, mhu_sees11_recwakeup_async, extsys1mhupwrreqactiveq_systop}),
    .or_tree_o  (EXTSYS1MHUPWRREQACTIVE)
  );  
  
  eh_f0_aontop u_eh1_f0_aontop (          
    .refclk                               (aondbgclk),
    .refclk_resetn                        (refclk_aontopporesetn),
    .psel_ehx_extdbg                      (psel_ehx1_extdbg),
    .penable_ehx_extdbg                   (penable_ehx1_extdbg),
    .paddr_ehx_extdbg                     (paddr_ehx1_extdbg),
    .pwrite_ehx_extdbg                    (pwrite_ehx1_extdbg),
    .pwdata_ehx_extdbg                    (pwdata_ehx1_extdbg),
    .pprot_ehx_extdbg                     (pprot_ehx1_extdbg),
    .prdata_ehx_extdbg                    (prdata_ehx1_extdbg),
    .pready_ehx_extdbg                    (pready_ehx1_extdbg),
    .pslverr_ehx_extdbg                   (pslverr_ehx1_extdbg),
    .pwakeup_ehx_extdbg                   (pwakeup_ehx1_extdbg),
    .apb_async_req_ehx_extdbg             (apb_async_req_eh1_extdbg),
    .apb_async_req_payload_ehx_extdbg     (apb_async_req_payload_eh1_extdbg),
    .apb_async_resp_payload_ehx_extdbg    (apb_async_resp_payload_eh1_extdbg),
    .apb_async_ack_ehx_extdbg             (apb_async_ack_eh1_extdbg),
    .qreqn_ehx_refclk                     (qreqn_eh1_refclk),
    .qacceptn_ehx_refclk                  (qacceptn_eh1_refclk),
    .qdeny_ehx_refclk                     (qdeny_eh1_refclk),
    .qactive_ehx_refclk                   (qactive_eh1_refclk),
    .dftcgen                              (DFTCGEN)
    );    


  pd_dbgtop_f0  #(
    .SYS_INGRESS_2_DBG    (SYS_INGRESS_2_DBG),
    .CLUS_INGRESS_2_DBG   (CLUS_INGRESS_2_DBG),
    .DBG_INTERNAL_CNT     (DBG_INTERNAL_CNT),
    .DBG_ADDR_WIDTH       (DBG_ADDR_WIDTH),
    .DBG_DATA_WIDTH       (DBG_DATA_WIDTH),
    .DBG_AWID_WIDTH       (DBG_AWID_WIDTH),
    .DBG_ARID_WIDTH       (DBG_ARID_WIDTH),
    .DBG_AWUSER_WIDTH     (DBG_AWUSER_WIDTH),
    .DBG_WUSER_WIDTH      (DBG_WUSER_WIDTH),
    .DBG_BUSER_WIDTH      (DBG_BUSER_WIDTH),
    .DBG_ARUSER_WIDTH     (DBG_ARUSER_WIDTH),
    .DBG_RUSER_WIDTH      (DBG_RUSER_WIDTH),
    .DBG_AW_FIFO_DEPTH    (DBG_AW_FIFO_DEPTH),
    .DBG_W_FIFO_DEPTH     (DBG_W_FIFO_DEPTH),
    .DBG_B_FIFO_DEPTH     (DBG_B_FIFO_DEPTH),
    .DBG_AR_FIFO_DEPTH    (DBG_AR_FIFO_DEPTH),
    .DBG_R_FIFO_DEPTH     (DBG_R_FIFO_DEPTH),
    .DBG_AW_PAYLOAD_WIDTH (DBG_AW_PAYLOAD_WIDTH),
    .DBG_W_PAYLOAD_WIDTH  (DBG_W_PAYLOAD_WIDTH),
    .DBG_B_PAYLOAD_WIDTH  (DBG_B_PAYLOAD_WIDTH),
    .DBG_AR_PAYLOAD_WIDTH (DBG_AR_PAYLOAD_WIDTH),
    .DBG_R_PAYLOAD_WIDTH  (DBG_R_PAYLOAD_WIDTH),
    .STM_ADDR_WIDTH       (STM_ADDR_WIDTH),
    .STM_AWUSER_WIDTH     (STM_AWUSER_WIDTH),
    .STM_WUSER_WIDTH      (STM_WUSER_WIDTH),
    .STM_BUSER_WIDTH      (STM_BUSER_WIDTH),
    .STM_ARUSER_WIDTH     (STM_ARUSER_WIDTH),
    .STM_RUSER_WIDTH      (STM_RUSER_WIDTH),
    .STM_AW_FIFO_DEPTH    (STM_AW_FIFO_DEPTH),
    .STM_W_FIFO_DEPTH     (STM_W_FIFO_DEPTH),
    .STM_B_FIFO_DEPTH     (STM_B_FIFO_DEPTH),
    .STM_AR_FIFO_DEPTH    (STM_AR_FIFO_DEPTH),
    .STM_R_FIFO_DEPTH     (STM_R_FIFO_DEPTH),
    .STM_AW_PAYLOAD_WIDTH (STM_AW_PAYLOAD_WIDTH),
    .STM_W_PAYLOAD_WIDTH  (STM_W_PAYLOAD_WIDTH),
    .STM_B_PAYLOAD_WIDTH  (STM_B_PAYLOAD_WIDTH),
    .STM_AR_PAYLOAD_WIDTH (STM_AR_PAYLOAD_WIDTH),
    .STM_R_PAYLOAD_WIDTH  (STM_R_PAYLOAD_WIDTH),
    .STM_AXI_ID_WIDTH     (STM_AXI_ID_WIDTH),
    .A4S_ID_WIDTH         (A4S_ID_WIDTH),
    .A4S_FIFO_WIDTH       (FW2DBGTOP_FIFO_DEPTH),
    .A4S_PAYLOAD_WIDTH    (A4S_PAYLOAD_WIDTH*FW2DBGTOP_FIFO_DEPTH),
    .EXT_SYS0_ROM_ENTRY   (EXT_SYS0_ROM_ENTRY),
    .EXT_SYS1_ROM_ENTRY   (EXT_SYS1_ROM_ENTRY),
    .DBG_FC_ID            (4'hd),
    .NUM_DBGCLK_QCH       (NUM_DBGCLK_QCH),
    .HOST_EXP_ROM_ENTRY   (HOST_EXP_ROM_ENTRY)
  ) u_pd_dbgtop_f0
  (
    .refclk                                          (refclk_dbgtop),
    .sys_pll                                         (syspll_dbgtop),
    .dbgtopwarmresetn                                (DBGTOPWARMRESETn),
    .dbgclkout                                       (DBGCLKOUT),
    .dp_abort_pulse_req                              (dp_abort_pulse_req),
    .dp_abort_pulse_ack                              (dp_abort_pulse_ack),
  
    .dbgclk_on_syspll_divratio                       (dbgclk_div0_clkdiv),
    .dbgclk_clksel                                   (dbgclk_ctrl_clkselect[1:0]),
    .dbgclk_on_syspll_divratio_cur                   (dbgclk_div0_clkdiv_cur),
    .dbgclk_clksel_cur                               (dbgclk_ctrl_clkselect_cur[1:0]),
    .clkforce_st_dbgclk_force_st                     (clkforce_st_dbgclk_force_st),
    .dbgclk_entrydelay                               (dbgclk_ctrl_entrydelay),
    
    .fctrl_bypass                                    (host_fctrl_bypass),

    .flush_done_eh0                    (flush_done_eh0),
    .sync_clear_eh0                    (sync_clear_eh0),
    .wr_pointer_gray_eh0               (wr_pointer_gray_eh0),
    .atb_fwd_data_eh0                  (atb_fwd_data_eh0),
    .syncreq_async_ack_eh0             (syncreq_async_ack_eh0),
    .rd_pointer_gray_eh0               (rd_pointer_gray_eh0),
    .flush_req_eh0                     (flush_req_eh0),
    .sync_done_eh0                     (sync_done_eh0),
    .syncreq_async_req_eh0             (syncreq_async_req_eh0),
    .apb_async_req_eh0_dbg             (apb_async_req_eh0_dbg),
    .apb_async_req_payload_eh0_dbg     (apb_async_req_payload_eh0_dbg),
    .apb_async_resp_payload_eh0_dbg    (apb_async_resp_payload_eh0_dbg),
    .apb_async_ack_eh0_dbg             (apb_async_ack_eh0_dbg),
    .pulse_req_eh0_cti_out             (pulse_req_eh0_cti_out),
    .pulse_ack_eh0_cti_out             (pulse_ack_eh0_cti_out),
    .pulse_ack_eh0_cti_in              (pulse_ack_eh0_cti_in),
    .pulse_req_eh0_cti_in              (pulse_req_eh0_cti_in),
    .dpabort_pulse_req_eh0             (dpabort_pulse_req_eh0),
    .dpabort_pulse_ack_eh0             (dpabort_pulse_ack_eh0),
    .qreqn_extsys0_ctioutpwr           (EXTSYS0CTIOUTPWRQREQn),
    .qacceptn_extsys0_ctioutpwr        (EXTSYS0CTIOUTPWRQACCEPTn),
    .qdeny_extsys0_ctioutpwr           (EXTSYS0CTIOUTPWRQDENY),
    .qactive_extsys0_ctioutpwr         (EXTSYS0CTIOUTPWRQACTIVE),
    .qreqn_extsys0_dbgpwr              (EXTSYS0DBGPWRQREQn),
    .qacceptn_extsys0_dbgpwr           (EXTSYS0DBGPWRQACCEPTn),
    .qdeny_extsys0_dbgpwr              (EXTSYS0DBGPWRQDENY),
    .qactive_extsys0_dbgpwr            (EXTSYS0DBGPWRQACTIVE),

    .flush_done_eh1                    (flush_done_eh1),
    .sync_clear_eh1                    (sync_clear_eh1),
    .wr_pointer_gray_eh1               (wr_pointer_gray_eh1),
    .atb_fwd_data_eh1                  (atb_fwd_data_eh1),
    .syncreq_async_ack_eh1             (syncreq_async_ack_eh1),
    .rd_pointer_gray_eh1               (rd_pointer_gray_eh1),
    .flush_req_eh1                     (flush_req_eh1),
    .sync_done_eh1                     (sync_done_eh1),
    .syncreq_async_req_eh1             (syncreq_async_req_eh1),
    .apb_async_req_eh1_dbg             (apb_async_req_eh1_dbg),
    .apb_async_req_payload_eh1_dbg     (apb_async_req_payload_eh1_dbg),
    .apb_async_resp_payload_eh1_dbg    (apb_async_resp_payload_eh1_dbg),
    .apb_async_ack_eh1_dbg             (apb_async_ack_eh1_dbg),
    .pulse_req_eh1_cti_out             (pulse_req_eh1_cti_out),
    .pulse_ack_eh1_cti_out             (pulse_ack_eh1_cti_out),
    .pulse_ack_eh1_cti_in              (pulse_ack_eh1_cti_in),
    .pulse_req_eh1_cti_in              (pulse_req_eh1_cti_in),
    .dpabort_pulse_req_eh1             (dpabort_pulse_req_eh1),
    .dpabort_pulse_ack_eh1             (dpabort_pulse_ack_eh1),
    .qreqn_extsys1_ctioutpwr           (EXTSYS1CTIOUTPWRQREQn),
    .qacceptn_extsys1_ctioutpwr        (EXTSYS1CTIOUTPWRQACCEPTn),
    .qdeny_extsys1_ctioutpwr           (EXTSYS1CTIOUTPWRQDENY),
    .qactive_extsys1_ctioutpwr         (EXTSYS1CTIOUTPWRQACTIVE),
    .qreqn_extsys1_dbgpwr              (EXTSYS1DBGPWRQREQn),
    .qacceptn_extsys1_dbgpwr           (EXTSYS1DBGPWRQACCEPTn),
    .qdeny_extsys1_dbgpwr              (EXTSYS1DBGPWRQDENY),
    .qactive_extsys1_dbgpwr            (EXTSYS1DBGPWRQACTIVE),

    .apb_async_req_secenc_dbg                        (apb_async_req_secenc_dbg),
    .apb_async_req_payload_secenc_dbg                (apb_async_req_payload_secenc_dbg),
    .apb_async_resp_payload_secenc_dbg               (apb_async_resp_payload_secenc_dbg),
    .apb_async_ack_secenc_dbg                        (apb_async_ack_secenc_dbg),
    
    .dp_abort_secenc_pulse_req                       (dp_abort_secenc_pulse_req),
    .dp_abort_secenc_pulse_ack                       (dp_abort_secenc_pulse_ack),
    
    .cti_cha_to_secenc_pulse_req                     (cti_cha_to_secenc_pulse_req),
    .cti_cha_to_secenc_pulse_ack                     (cti_cha_to_secenc_pulse_ack),
    .cti_secenc_to_cha_pulse_ack                     (cti_secenc_to_cha_pulse_ack),
    .cti_secenc_to_cha_pulse_req                     (cti_secenc_to_cha_pulse_req),
    
    .qreqn_secenc_dbg_pwr                            (qreqn_secenc_dbg_pwr),
    .qacceptn_secenc_dbg_pwr                         (qacceptn_secenc_dbg_pwr),
    .qdeny_secenc_dbg_pwr                            (qdeny_secenc_dbg_pwr),
    .qactive_secenc_dbg_pwr                          (qactive_secenc_dbg_pwr),
                                       
    .apb_async_req_aontop_dbg                        (dp2hostdbg_apb_async_req),
    .apb_async_req_payload_aontop_dbg                (dp2hostdbg_apb_async_req_payload),
    .apb_async_resp_payload_aontop_dbg               (dp2hostdbg_apb_async_resp_payload),
    .apb_async_ack_aontop_dbg                        (dp2hostdbg_apb_async_ack),
    
    .apb_async_req_hostcpu                           (hostcpu_async_req),
    .apb_async_req_payload_hostcpu                   (hostcpu_async_req_payload),
    .apb_async_resp_payload_hostcpu                  (hostcpu_async_resp_payload),
    .apb_async_ack_hostcpu                           (hostcpu_async_ack),
    
    .atb_fwd_data_hostcpu                            (hostcpu_atb_fwd_data),
    .wr_pointer_gray_hostcpu                         (hostcpu_wr_pointer_gray),
    .rd_pointer_gray_hostcpu                         (hostcpu_rd_pointer_gray),
    .flush_req_hostcpu                               (hostcpu_flush_req),
    .flush_done_hostcpu                              (hostcpu_flush_done),
    .sync_clear_hostcpu                              (hostcpu_sync_clear),
    .sync_done_hostcpu                               (hostcpu_sync_done),
    .syncreq_async_req_hostcpu                       (hostcpu_syncreq_async_req),
    .syncreq_async_ack_hostcpu                       (hostcpu_syncreq_async_ack),
    
    .debug_axis_slvmustacceptreqn_async              (debug_axis_slvmustacceptreqn_async),
    .debug_axis_slvcandenyreqn_async                 (debug_axis_slvcandenyreqn_async),
    .debug_axis_slvacceptn_async                     (debug_axis_slvacceptn_async),
    .debug_axis_slvdeny_async                        (debug_axis_slvdeny_async),
                                           
    .debug_axis_si_to_mi_wakeup_async                (debug_axis_si_to_mi_wakeup_async),
    .debug_axis_mi_to_si_wakeup_async                (debug_axis_mi_to_si_wakeup_async),
    .debug_axis_aw_wr_ptr_async                      (debug_axis_aw_wr_ptr_async),
    .debug_axis_aw_rd_ptr_async                      (debug_axis_aw_rd_ptr_async),
    .debug_axis_aw_payld_async                       (debug_axis_aw_payld_async),
    .debug_axis_w_wr_ptr_async                       (debug_axis_w_wr_ptr_async),
    .debug_axis_w_rd_ptr_async                       (debug_axis_w_rd_ptr_async),
    .debug_axis_w_payld_async                        (debug_axis_w_payld_async),
    .debug_axis_b_wr_ptr_async                       (debug_axis_b_wr_ptr_async),
    .debug_axis_b_rd_ptr_async                       (debug_axis_b_rd_ptr_async),
    .debug_axis_b_payld_async                        (debug_axis_b_payld_async),
    .debug_axis_ar_wr_ptr_async                      (debug_axis_ar_wr_ptr_async),
    .debug_axis_ar_rd_ptr_async                      (debug_axis_ar_rd_ptr_async),
    .debug_axis_ar_payld_async                       (debug_axis_ar_payld_async),
    .debug_axis_r_wr_ptr_async                       (debug_axis_r_wr_ptr_async),
    .debug_axis_r_rd_ptr_async                       (debug_axis_r_rd_ptr_async),
    .debug_axis_r_payld_async                        (debug_axis_r_payld_async),
                                           
    .stm_slvmustacceptreqn_async                     (stm_slvmustacceptreqn_async),
    .stm_slvcandenyreqn_async                        (stm_slvcandenyreqn_async),
    .stm_slvacceptn_async                            (stm_slvacceptn_async),
    .stm_slvdeny_async                               (stm_slvdeny_async),
    .stm_si_to_mi_wakeup_async                       (stm_si_to_mi_wakeup_async),
    .stm_mi_to_si_wakeup_async                       (stm_mi_to_si_wakeup_async),
    .stm_aw_wr_ptr_async                             (stm_aw_wr_ptr_async),
    .stm_aw_rd_ptr_async                             (stm_aw_rd_ptr_async),
    .stm_aw_payld_async                              (stm_aw_payld_async),
    .stm_w_wr_ptr_async                              (stm_w_wr_ptr_async),
    .stm_w_rd_ptr_async                              (stm_w_rd_ptr_async),
    .stm_w_payld_async                               (stm_w_payld_async),
    .stm_b_wr_ptr_async                              (stm_b_wr_ptr_async),
    .stm_b_rd_ptr_async                              (stm_b_rd_ptr_async),
    .stm_b_payld_async                               (stm_b_payld_async),
    .stm_ar_wr_ptr_async                             (stm_ar_wr_ptr_async),
    .stm_ar_rd_ptr_async                             (stm_ar_rd_ptr_async),
    .stm_ar_payld_async                              (stm_ar_payld_async),
    .stm_r_wr_ptr_async                              (stm_r_wr_ptr_async),
    .stm_r_rd_ptr_async                              (stm_r_rd_ptr_async),
    .stm_r_payld_async                               (stm_r_payld_async),
    
    
    .tsvalueb_refclk                                 (HOSTTSVALUEB),

    .axiap_csyspwrupreq_hostdbgpwr                   (HOSTDBGPWRREQ),
    .axiap_csyspwrupack_hostdbgpwr                   (HOSTDBGPWRACK),
    .axiap_csyspwrupreq_internal                     (axiap_csyspwrupreq_int),
    .axiap_csyspwrupack_internal                     (axiap_csyspwrupack_int),
    .extdbg_cdbgpwrupreq                             (extdbg_cdbgpwrupreq),
    .extdbg_cdbgpwrupack                             (extdbg_cdbgpwrupack),
    .host_cdbgpwrupreq                               (hostrom_cdbgpwrupreq),
    .host_cdbgpwrupack                               (hostrom_cdbgpwrupack),

                                                      
    .hostcpuctichin_pulse_req                        (hostcpuctichin_pulse_req),
    .hostcpuctichin_pulse_ack                        (hostcpuctichin_pulse_ack),
                                                      
    .hostcpuctichout_pulse_req                       (hostcpuctichout_pulse_req),
    .hostcpuctichout_pulse_ack                       (hostcpuctichout_pulse_ack),
                                        
    
    .dbgen_tpiuauth                                  (dbgen_tpiuauth),
    .niden_tpiuauth                                  (niden_tpiuauth),
    .spiden_tpiuauth                                 (spiden_tpiuauth),
    .chen_tpiuauth                                   (chen_tpiuauth),

    .irq_soc_etr                                     (irq_soc_etr),
    .irq_soc_catu                                    (irq_soc_catu),
    
    .irq_host_etr                                    (irq_host_etr),
    .irq_host_catu                                   (irq_host_catu),
  
    .irq_gic72_req                                   (host_cti_trig_out_4),
    .irq_gic73_req                                   (host_cti_trig_out_5),
    .irq_host_stm_req                                (irq_host_stm),
 
    .irq_gic72_ack                                   (host_cti_trig_out_4_ack),
    .irq_gic73_ack                                   (host_cti_trig_out_5_ack),
    .irq_host_stm_ack                                (irq_host_stm_ack),
 
    .ap_en_hostextauth                               (ap_en_hostextauth),
    .ap_secure_en_hostextauth                        (ap_secure_en_hostextauth),
    .dbgen_hostaxiauth                               (dbgen_hostaxiauth),
    .niden_hostaxiauth                               (niden_hostaxiauth),
    .spiden_hostaxiauth                              (spiden_hostaxiauth),
    .spniden_hostaxiauth                             (spniden_hostaxiauth),
    .dbgen_dpauth                                    (dbgen_dpauth),
    .niden_dpauth                                    (niden_dpauth),
    .spiden_dpauth                                   (spiden_dpauth),
    .spniden_dpauth                                  (spniden_dpauth),
    .dbgen_hostauth                                  (dbgen_hostauth),
    .niden_hostauth                                  (niden_hostauth),
    .spiden_hostauth                                 (spiden_hostauth),
    .spniden_hostauth                                (spniden_hostauth),
    .chen_hostauth                                   (chen_hostauth),
    .dbgen_counterauth                               (dbgen_counterauth),
    .niden_counterauth                               (niden_counterauth),
    .chen_counterauth                                (chen_counterauth),

    .traceclk_in                                     (traceclk_in_dbgtop),
    .traceclk                                        (TRACECLKOUT),
    .tracedata                                       (TPIUTRACEDATA),
    .tracectl                                        (TPIUTRACECTL),
    .trace_max_datasize                              (TPIUTRACEMAXDATASIZE),
    .tpctl_valid                                     (TPIUTPCTLVALID),
    
    .u_soc_cti_event_out_6_to_u_dp_eventstat(u_soc_cti_event_out_6_to_u_dp_eventstat),
    
    
   .qreqn_systop_ingress_dbgtop                      (qreqn_systop_ingress_dbgtop),
   .qacceptn_systop_ingress_dbgtop                   (qacceptn_systop_ingress_dbgtop),
   .qdeny_systop_ingress_dbgtop                      (qdeny_systop_ingress_dbgtop),
   .qactive_systop_ingress_dbgtop                    (qactive_systop_ingress_dbgtop),
                                        
   .qreqn_clustop_ingress_dbgtop                     (qreqn_clustop_ingress_dbgtop),
   .qacceptn_clustop_ingress_dbgtop                  (qacceptn_clustop_ingress_dbgtop),
   .qdeny_clustop_ingress_dbgtop                     (qdeny_clustop_ingress_dbgtop),
   .qactive_clustop_ingress_dbgtop                   (qactive_clustop_ingress_dbgtop),

    .qreqn_egress_dbgtop                             (qreqn_dbgtop_egress),
    .qacceptn_egress_dbgtop                          (qacceptn_dbgtop_egress),
    .qdeny_egress_dbgtop                             (qdeny_dbgtop_egress),
    .qactive_egress_dbgtop                           (qactive_dbgtop_egress),
                                        
    .qreqn_internal_dbgtop                           (qreqn_dbgtop_internal),
    .qacceptn_internal_dbgtop                        (qacceptn_dbgtop_internal),
    .qdeny_internal_dbgtop                           (qdeny_dbgtop_internal),
    .qactive_internal_dbgtop                         (qactive_dbgtop_internal),

    .pc_aontop_slvmustacceptreqn_async_slv           (fw2dbgtop_dn_slvmustacceptreqn_async),
    .pc_aontop_slvcandenyreqn_async_slv              (fw2dbgtop_dn_slvcandenyreqn_async),
    .pc_aontop_slvacceptn_async_slv                  (fw2dbgtop_dn_slvacceptn_async),
    .pc_aontop_slvdeny_async_slv                     (fw2dbgtop_dn_slvdeny_async),
                                           
    .pc_aontop_si_to_mi_wakeup_async_slv             (fw2dbgtop_dn_si_to_mi_wakeup_async),
    .pc_aontop_mi_to_si_wakeup_async_slv             (fw2dbgtop_dn_mi_to_si_wakeup_async),
                                           
    .pc_aontop_wr_ptr_async_slv                      (fw2dbgtop_dn_wr_ptr_async),
    .pc_aontop_rd_ptr_async_slv                      (fw2dbgtop_dn_rd_ptr_async),
    .pc_aontop_payld_async_slv                       (fw2dbgtop_dn_payld_async),

    .pc_aontop_slvmustacceptreqn_async_mst           (fw2dbgtop_up_slvmustacceptreqn_async),
    .pc_aontop_slvcandenyreqn_async_mst              (fw2dbgtop_up_slvcandenyreqn_async),
    .pc_aontop_slvacceptn_async_mst                  (fw2dbgtop_up_slvacceptn_async),
    .pc_aontop_slvdeny_async_mst                     (fw2dbgtop_up_slvdeny_async),
                                           
    .pc_aontop_si_to_mi_wakeup_async_mst             (fw2dbgtop_up_si_to_mi_wakeup_async),
    .pc_aontop_mi_to_si_wakeup_async_mst             (fw2dbgtop_up_mi_to_si_wakeup_async),
                                           
    .pc_aontop_wr_ptr_async_mst                      (fw2dbgtop_up_wr_ptr_async),
    .pc_aontop_rd_ptr_async_mst                      (fw2dbgtop_up_rd_ptr_async),
    .pc_aontop_payld_async_mst                       (fw2dbgtop_up_payld_async),
    
    .s32k_counter_haltreqreq                         (s32k_counter_haltreqreq),
    .s32k_counter_haltreqack                         (s32k_counter_haltreqack),
    
    .s32k_counter_restartreq                         (s32k_counter_restartreq),
    .s32k_counter_restartack                         (s32k_counter_restartack),
 
    .refclk_counter_restartreq                       (refclk_counter_restartreq),
    .refclk_counter_restartack                       (refclk_counter_restartack),
                                                                   
    .refclk_counter_haltreqreq                       (refclk_counter_haltreqreq),
    .refclk_counter_haltreqack                       (refclk_counter_haltreqack),
 
    .hostsysdbg_async_req                            (hostsysdbg_async_req),
    .hostsysdbg_async_req_payload                    (hostsysdbg_async_req_payload),
    .hostsysdbg_async_resp_payload                   (hostsysdbg_async_resp_payload),
    .hostsysdbg_async_ack                            (hostsysdbg_async_ack),
 
    .host_axiap_rom_part_number                      (HOSTAXIAPROMPRTID),
    .host_axiap_rom_eco_rev_and                      (HOSTAXIAPROMREV),
    .host_axiap_rom_revision                         (HOSTAXIAPROMVAR),
    .host_axiap_rom_jep106_id                        (HOSTAXIAPROMIMPLID),
    
    .extdbg_rom_part_number                          (EXTDBGROMPRTID),
    .extdbg_rom_eco_rev_and                          (EXTDBGROMREV),
    .extdbg_rom_revision                             (EXTDBGROMVAR),
    .extdbg_rom_jep106_id                            (EXTDBGROMIMPLID),
    
    .host_rom_part_number                            (HOSTROMPRTID),
    .host_rom_eco_rev_and                            (HOSTROMREV),
    .host_rom_revision                               (HOSTROMVAR),
    .host_rom_jep106_id                              (HOSTROMIMPLID),
    
    .traceexp_atwakeup_mst                           (ATWAKEUPHOSTDBGTRACEEXP),
    .traceexp_atid_mst                               (ATIDHOSTDBGTRACEEXP),
    .traceexp_atbytes_mst                            (ATBYTESHOSTDBGTRACEEXP),
    .traceexp_atdata_mst                             (ATDATAHOSTDBGTRACEEXP),
    .traceexp_atvalid_mst                            (ATVALIDHOSTDBGTRACEEXP),
    .traceexp_atready_mst                            (ATREADYHOSTDBGTRACEEXP),
    .traceexp_afvalid_mst                            (AFVALIDHOSTDBGTRACEEXP),
    .traceexp_afready_mst                            (AFREADYHOSTDBGTRACEEXP),
    .traceexp_syncreq_mst                            (SYNCREQHOSTDBGTRACEEXP),
    
    .dbgexp_apb4_mst_pwakeup                         (PWAKEUPHOSTDBGEXP),
    .dbgexp_apb4_mst_psel                            (PSELHOSTDBGEXP),
    .dbgexp_apb4_mst_penable                         (PENABLEHOSTDBGEXP),
    .dbgexp_apb4_mst_pwrite                          (PWRITEHOSTDBGEXP),
    .dbgexp_apb4_mst_pprot                           (PPROTHOSTDBGEXP),
    .dbgexp_apb4_mst_paddr                           (PADDRHOSTDBGEXP),
    .dbgexp_apb4_mst_pwdata                          (PWDATAHOSTDBGEXP),
    .dbgexp_apb4_mst_pready                          (PREADYHOSTDBGEXP),
    .dbgexp_apb4_mst_pslverr                         (PSLVERRHOSTDBGEXP),
    .dbgexp_apb4_mst_prdata                          (PRDATAHOSTDBGEXP),
    .dbgexp_apb4_mst_pstrb                           (PSTRBHOSTDBGEXP),
    
    .ctiexp_ctichin                                  (HOSTCTICHINEXP),
    .ctiexp_ctichout                                 (HOSTCTICHOUTEXP),
    
    .dbgclk_qreqn                                    (DBGCLKQREQn),
    .dbgclk_qacceptn                                 (DBGCLKQACCEPTn),
    .dbgclk_qdeny                                    (DBGCLKQDENY),
    .dbgclk_qactive                                  (DBGCLKQACTIVE),
                                 
    .stm_drready                                     (HOSTSTMDPRDRREADY),
    .stm_davalid                                     (HOSTSTMDPRDAVALID),
    .stm_datype                                      (HOSTSTMDPRDATYPE),
    .stm_drvalid                                     (HOSTSTMDPRDRVALID),
    .stm_drtype                                      (HOSTSTMDPRDRTYPE),
    .stm_drlast                                      (HOSTSTMDPRDRLAST),
    .stm_daready                                     (HOSTSTMDPRDAREADY),
                                 
    .dftdbgclksel                                    (DFTDBGCLKSEL),
    .dftdbgclkselen                                  (DFTCLKSELEN),
    .dftdbgclkdivbypass                              (DFTDIVBYPASS),
    
    .dftcgen                                         (DFTCGEN),
    .dftrstdisable                                   ({DFTRSTDISABLE[0], DFTRSTDISABLE[1]}),
    .dftdivsel                                       (DFTDIVSEL),
    .nmbistreset                                     (nMBISTRESET)
    );

  debug_f0_aontop 
   u_debug_f0_aontop (
    .swclktck                                        (SWCLKTCK),
    .ntrst                                           (nTRST),
    .swditms                                         (SWDITMS),
    .swdo                                            (SWDO),
    .swdo_en                                         (SWDOEN),
    .tdi                                             (TDI),
    .tdo                                             (TDO),
    .tdo_en_n                                        (TDOENn),
    .dbgclk                                          (aondbgclk),
    .dbgclk_reset_n                                  (refclk_aontopporesetn),
          
    .porst_n                                         (PORESETn),
    .swactive                                        (SWACTIVE),
    .jtagactive                                      (JTAGACTIVE),
    .jtagir                                          (JTAGIR),
    .jtagstate                                       (JTAGSTATE),
    .dormantstate                                    (DORMANTSTATE),
    
    .dpslv_cdbgpwrupreq                              (dpslv_cdbgpwrupreq),
    .dpslv_cdbgpwrupack                              (dpslv_cdbgpwrupack),
    .dpslv_csyspwrupreq                              (dpslv_csyspwrupreq),
    .dpslv_csyspwrupack                              (dpslv_csyspwrupreq),
    .dpslv_cdbgrstreq                                (dpslv_cdbgrstreq),
    .dpslv_cdbgrstack                                (dpslv_cdbgrstack),
   
    .targetid                                        ({SOCVAR,SOCPRTID,4'd0,SOCIMPLID,1'b1}),
    .instanceid                                      (4'd0),
    .baseaddr                                        (32'd0),
    .baseaddr_valid                                  (1'b1),
     
    .hostext_async_req_i                             (extdbg_async_req),
    .hostext_async_req_payload_i                     (extdbg_async_req_payload),
    .hostext_async_resp_payload_o                    (extdbg_async_resp_payload),
    .hostext_async_ack_o                             (extdbg_async_ack),
     
    .extsys0_psel_s                    (psel_ehx0_extdbg),
    .extsys0_pprot_s                   (pprot_ehx0_extdbg),
    .extsys0_paddr_s                   (paddr_ehx0_extdbg),
    .extsys0_penable_s                 (penable_ehx0_extdbg),
    .extsys0_pwrite_s                  (pwrite_ehx0_extdbg),
    .extsys0_pwdata_s                  (pwdata_ehx0_extdbg),
    .extsys0_pstrb_s                   ({4{pwrite_ehx0_extdbg}}),
    .extsys0_pwakeup_s                 (pwakeup_ehx0_extdbg),
    .extsys0_pready_s                  (pready_ehx0_extdbg),
    .extsys0_prdata_s                  (prdata_ehx0_extdbg),
    .extsys0_pslverr_s                 (pslverr_ehx0_extdbg),
    .extsys1_psel_s                    (psel_ehx1_extdbg),
    .extsys1_pprot_s                   (pprot_ehx1_extdbg),
    .extsys1_paddr_s                   (paddr_ehx1_extdbg),
    .extsys1_penable_s                 (penable_ehx1_extdbg),
    .extsys1_pwrite_s                  (pwrite_ehx1_extdbg),
    .extsys1_pwdata_s                  (pwdata_ehx1_extdbg),
    .extsys1_pstrb_s                   ({4{pwrite_ehx1_extdbg}}),
    .extsys1_pwakeup_s                 (pwakeup_ehx1_extdbg),
    .extsys1_pready_s                  (pready_ehx1_extdbg),
    .extsys1_prdata_s                  (prdata_ehx1_extdbg),
    .extsys1_pslverr_s                 (pslverr_ehx1_extdbg),
        
    .dprom_cdbgpwrupreq                              (dprom_cdbgpwrupreq),
    .dprom_cdbgpwrupack                              (dprom_cdbgpwrupack),
    .dprom_csyspwrupreq                              (dprom_csyspwrupreq),
    .dprom_csyspwrupack                              (dprom_csyspwrupreq),
    .dprom_cdbgrstreq                                (dprom_cdbgrstreq),
    .dprom_cdbgrstack                                (dprom_cdbgrstack), 
    .dprom_csysrstreq                                (dprom_csysrstreq),
    .dprom_csysrstack                                (dprom_csysrstack),
         
    .pwrdbg_apb_pwrqreqn_i                           (dp2hostdbg_pwrdbg_aontop_pwrqreqn[0]),
    .pwrdbg_apb_pwrqacceptn_o                        (dp2hostdbg_pwrdbg_aontop_pwrqacceptn[0]),
    .pwrdbg_apb_pwrqdeny_o                           (dp2hostdbg_pwrdbg_aontop_pwrqdeny[0]),
    .pwrdbg_apb_pwrqactive_o                         (dp2hostdbg_pwrdbg_aontop_pwrqactive[0]),
    
    
    .apb_async_req_o                                 (dp2hostdbg_apb_async_req),
    .apb_async_req_payload_o                         (dp2hostdbg_apb_async_req_payload),
    .apb_async_resp_payload_i                        (dp2hostdbg_apb_async_resp_payload),
    .apb_async_ack_i                                 (dp2hostdbg_apb_async_ack),
 
    .acg_extsys0_dbgen                 (acg_extsys0_dbgen),
    .acg_extsys1_dbgen                 (acg_extsys1_dbgen),
    .acg_hostext_dbgen                               (acg_hostext_dbgen),
    .acg_dp_dbgen                                    (acg_dp_dbgen),
    
    .dbgen_dpauth                                    (dbgen_dpauth),
    .niden_dpauth                                    (niden_dpauth),
    .spiden_dpauth                                   (spiden_dpauth),
    .spniden_dpauth                                  (spniden_dpauth),
    
    .u_soc_cti_event_out_6_to_u_dp_eventstat         (u_soc_cti_event_out_6_to_u_dp_eventstat),
     
    .dp_abort_pulse_req                              (dp_abort_pulse_req),
    .dp_abort_pulse_ack                              (dp_abort_pulse_ack),

    .dp_abort_pwr_qreq_n                             (dp2hostdbg_pwrdbg_aontop_pwrqreqn[1]),
    .dp_abort_pwr_qaccept_n                          (dp2hostdbg_pwrdbg_aontop_pwrqacceptn[1]),
    .dp_abort_pwr_qactive                            (dp2hostdbg_pwrdbg_aontop_pwrqactive[1]),
                                  

    .dbgen_comauth                                   (dbgen_comauth),
    .niden_comauth                                   (niden_comauth),
    
      
    .sdc600_ext_rempua                               (sdc600_ext_rempua),
    .sdc600_ext_remra                                (sdc600_ext_remrr),
    .sdc600_ext_rempur                               (sdc600_ext_rempur),
    .sdc600_ext_remrr                                (sdc600_ext_remrr),
    
        
    .ie_data_sdc600                                  (ie_data_sdc600),
    .ie_req_sdc600                                   (ie_req_sdc600),
    .ie_ack_sdc600                                   (ie_ack_sdc600),
    .ie_linkup_sdc600                                (ie_linkup_sdc600),
    .ie_linkest_sdc600                               (ie_linkest_sdc600),
    .ei_data_sdc600                                  (ei_data_sdc600),
    .ei_req_sdc600                                   (ei_req_sdc600),
    .ei_ack_sdc600                                   (ei_ack_sdc600),
    .ei_linkup_sdc600                                (ei_linkup_sdc600),
    .ei_linkest_sdc600                               (ei_linkest_sdc600),
    
    .dbgclk_qreqn                                    (aondbgclk_qreqn),
    .dbgclk_qacceptn                                 (aondbgclk_qacceptn),
    .dbgclk_qdeny                                    (aondbgclk_qdeny),
    .dbgclk_qactive                                  (aondbgclk_qactive),
    .dbgclk_qactive_only                             (aondbgclk_qactive_only),
    
    .dprom_revision                                  (DPROMVAR),
    .dprom_part_number                               (DPROMPRTID),
    .dprom_jep106_id                                 (DPROMIMPLID),
    .dprom_eco_rev_and                               (DPROMREV),
                                                           
    .calc                                            (debug_calc),
    .dftcgen                                         (DFTCGEN)
    );
 
    
  reset_controller_f1_top #(
    .SOC_RST_DLY (SOC_RST_DLY),
    .NUM_EXT_SYS (NUM_EXT_SYS)
  ) u_reset_controller_f1_top (
    .s32kclk                       (S32KCLK),
    .poresetn                      (PORESETn),
    .refclk                        (refclk_int_gated),

    .soc_wdog_rst_req              (secenc_soc_wdog_rst_req), 
    .secenc_wdog_rst_req           (secenc_wdog_rst_req),     
    .secenc_cae_rst_req            (secenc_cae_rst_req),      
    .cdbgrstreq_dp                 (dpslv_cdbgrstreq),        
    .soc_rst_req                   (soc_rst_req),             
    .secenc_sw_rst_req             (secenc_sw_rst_req),
    .nsrst                         (nSRST),
    .csysrstreq_dprom              (dprom_csysrstreq),
    .host_sys_rst_req              (host_rst_req),
    .extsys_rst_req                ({ ext_sys1_rst_ctrl_rst_req, ext_sys0_rst_ctrl_rst_req}),
    
    .aontopporesetn                (AONTOPPORESETn),
    .aontopwarmresetn              (AONTOPWARMRESETn),
    .secporesetn                   (seporesetn),
    .extsysporesetn                ({ EXTSYS1PORESETn, EXTSYS0PORESETn}),

    .cdbgrstack_dp                 (dpslv_cdbgrstack),
    .secenccpuwait                 (secenc_cpuwait),
    .extsyscpuwait                 ({ set_extsys1_cpuwait, set_extsys0_cpuwait}),
    .csysrstack_dprom              (dprom_csysrstack),
    .host_sys_rst_ack              (host_rst_ack),
    .extsys_rst_ack                ({ ext_sys1_rst_st_rst_ack, ext_sys0_rst_st_rst_ack}),

    .soc_rst_syn                   (soc_rst_syn),
    .host_rst_syn                  (host_rst_syn),
    .extsys_rst_syn                ({ EXTSYS1RSTSYN, EXTSYS0RSTSYN}),
    .se_rst_syn                    (se_rst_syn),

    .aontoppo_systop_qreqn         (aontoppo_systop_qreqn), 
    .aontoppo_systop_qacceptn      (aontoppo_systop_qacceptn),
    .aontoppo_systop_qdeny         (aontoppo_systop_qdeny),
    .aontoppo_systop_qactive       (aontoppo_systop_qactive),

    .aontoppo_dbgtop_qreqn         (aontoppo_dbgtop_qreqn),
    .aontoppo_dbgtop_qacceptn      (aontoppo_dbgtop_qacceptn),
    .aontoppo_dbgtop_qdeny         (aontoppo_dbgtop_qdeny),
    .aontoppo_dbgtop_qactive       (aontoppo_dbgtop_qactive),

    .secenc_systop_qreqn           (qreqn_secenc_systopq_rstctrl),
    .secenc_systop_qacceptn        (qacceptn_secenc_systopq_rstctrl),
    .secenc_systop_qdeny           (qdeny_secenc_systopq_rstctrl),
    .secenc_systop_qactive         (qactive_secenc_systopq_rstctrl),

    .secenc_dbgtop_qreqn           (qreqn_secenc_dbgtopq_rstctrl),
    .secenc_dbgtop_qacceptn        (qacceptn_secenc_dbgtopq_rstctrl),
    .secenc_dbgtop_qdeny           (qdeny_secenc_dbgtopq_rstctrl),
    .secenc_dbgtop_qactive         (qactive_secenc_dbgtopq_rstctrl),  

    .extsys_systop_qreqn           (qreqn_extsys_systopq_rstctrl),
    .extsys_systop_qacceptn        (qacceptn_extsys_systopq_rstctrl),
    .extsys_systop_qdeny           (qdeny_extsys_systopq_rstctrl),
    .extsys_systop_qactive         (qactive_extsys_systopq_rstctrl), 

    .extsys_dbgtop_qreqn           (qreqn_extsys_dbgtopq_rstctrl),
    .extsys_dbgtop_qacceptn        (qacceptn_extsys_dbgtopq_rstctrl),
    .extsys_dbgtop_qdeny           (qdeny_extsys_dbgtopq_rstctrl),
    .extsys_dbgtop_qactive         (qactive_extsys_dbgtopq_rstctrl),

    .extsys_aontop_qreqn           ({ EXTSYS1AONTOPQREQn, EXTSYS0AONTOPQREQn}),
    .extsys_aontop_qacceptn        ({ EXTSYS1AONTOPQACCEPTn, EXTSYS0AONTOPQACCEPTn}),
    .extsys_aontop_qdeny           ({ EXTSYS1AONTOPQDENY, EXTSYS0AONTOPQDENY}),
    .extsys_aontop_qactive         ({ EXTSYS1AONTOPQACTIVE, EXTSYS0AONTOPQACTIVE}),

    .refclk_clk_qactive            (qactive_refclk_int_gated[NUM_EXT_SYS*2+6]),

    .dftcgen                       (DFTCGEN),
    .dftrstdisable                 (DFTRSTDISABLE[1:0])
);


  pck600_ppu_pcsm_sse710_clus u_pck600_ppu_pcsm_sse710_clus
  (
    .clk                           (refclk_sleep_gated),
    .reset_n                       (refclk_warmresetn),
    
    .dftpwrup                      (DFTPWRUP),
    .dftretdisable                 (DFTRETDISABLE),
    
    .pcsm_preq_i                   (clustop_pcsm_preq_o),
    .pcsm_pstate_i                 (clustop_pcsm_pstate_o),
    .pcsm_paccept_o                (clustop_pcsm_paccept_i),
    .pcsm_mode_stat_o              (clustop_pcsm_mode_stat_i),

    .lgcpwrn_o                     (),
    .lgcretn_o                     (),
    .rampwrn_o                     (),
    .ramretn_o                     ()
    );
  

  pd_secenc_f1_top #(
    .SEC_ENC_ROM_SIZE                    (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE                    (SEC_ENC_RAM_SIZE),
    .MHU_HSE0_NUM_CH                     (MHU_HSE0_NUM_CH),  
    .MHU_SEH0_NUM_CH                     (MHU_SEH0_NUM_CH),  
    .MHU_HSE1_NUM_CH                     (MHU_HSE1_NUM_CH),  
    .MHU_SEH1_NUM_CH                     (MHU_SEH1_NUM_CH),
    
    .MHU_SEES00_NUM_CH  (MHU_SEES00_NUM_CH),
    .MHU_ES0SE0_NUM_CH  (MHU_ES0SE0_NUM_CH),
      .MHU_SEES01_NUM_CH  (MHU_SEES01_NUM_CH),
    .MHU_ES0SE1_NUM_CH  (MHU_ES0SE1_NUM_CH),
      .MHU_SEES10_NUM_CH  (MHU_SEES10_NUM_CH),
    .MHU_ES1SE0_NUM_CH  (MHU_ES1SE0_NUM_CH),
      .MHU_SEES11_NUM_CH  (MHU_SEES11_NUM_CH),
    .MHU_ES1SE1_NUM_CH  (MHU_ES1SE1_NUM_CH),
  
    .AW_FIFO_DEPTH                       (SECENC_AW_FIFO_DEPTH),
    .W_FIFO_DEPTH                        (SECENC_W_FIFO_DEPTH),
    .B_FIFO_DEPTH                        (SECENC_B_FIFO_DEPTH),
    .AR_FIFO_DEPTH                       (SECENC_AR_FIFO_DEPTH),
    .R_FIFO_DEPTH                        (SECENC_R_FIFO_DEPTH),
    .AW_PAYLOAD_WIDTH                    (SECENC_AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH                     (SECENC_W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH                     (SECENC_B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH                    (SECENC_AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH                     (SECENC_R_PAYLOAD_WIDTH),
    
    .CAAON2CA_WIDTH                      (CAAON2CA_WIDTH),
    .CA2CAAON_WIDTH                      (CA2CAAON_WIDTH),
    .AHB_SYNC_BRIDGE                     (1) 
  ) u_pd_secenc_f1_top (                 
    .SECENCCLK                           (secenc_clk), 
    .SECENCDIVCLK                        (secenc_divclk), 
    .SECENCHINTCLK                       (secenc_hintclk),
    .S32KCLK_SECENC                      (secenc_s32kclk),
    .SECENCPORESETn                      (secenc_poresetn),
    .SECENCWARMRESETn                    (secenc_warmresetn),
    .SECENCCPUWAIT                       (secenc_cpuwait),
    .M0_HALTED                           (secenc_m0_halted),
    .CDBGPWRUPREQ0                       (extdbg_cdbgpwrupreq[0]),            
    .CLKFORCE                            (secenc_clkforce   ),
    .ENTRY_DELAY                         (secenc_entry_delay),
                                         
    .DEBUG_APB_ASYNC_REQ                 (apb_async_req_secenc_dbg),
    .DEBUG_APB_ASYNC_REQ_PAYLOAD         (apb_async_req_payload_secenc_dbg),
    .DEBUG_APB_ASYNC_RESP_PAYLOAD        (apb_async_resp_payload_secenc_dbg),
    .DEBUG_APB_ASYNC_ACK                 (apb_async_ack_secenc_dbg),
                                         
    .DP_ABORT_PULSE_REQ                  (dp_abort_secenc_pulse_req),
    .DP_ABORT_PULSE_ACK                  (dp_abort_secenc_pulse_ack),
                                         
    .CTI_CHA_TO_SECENC_PULSE_REQ         (cti_cha_to_secenc_pulse_req),
    .CTI_CHA_TO_SECENC_PULSE_ACK         (cti_cha_to_secenc_pulse_ack),
    .CTI_SECENC_TO_CHA_PULSE_ACK         (cti_secenc_to_cha_pulse_ack),
    .CTI_SECENC_TO_CHA_PULSE_REQ         (cti_secenc_to_cha_pulse_req),
                                         
    .SLVMUSTACCEPTREQN_ASYNC             (slvmustacceptreqn_async_secenc),
    .SLVCANDENYREQN_ASYNC                (slvcandenyreqn_async_secenc),
    .SLVACCEPTN_ASYNC                    (slvacceptn_async_secenc),
    .SLVDENY_ASYNC                       (slvdeny_async_secenc),
    .SI_TO_MI_WAKEUP_ASYNC               (si_to_mi_wakeup_async_secenc),
    .MI_TO_SI_WAKEUP_ASYNC               (mi_to_si_wakeup_async_secenc),
    .AW_WR_PTR_ASYNC                     (aw_wr_ptr_async_secenc),
    .AW_RD_PTR_ASYNC                     (aw_rd_ptr_async_secenc),
    .AW_PAYLD_ASYNC                      (aw_payld_async_secenc),
    .W_WR_PTR_ASYNC                      (w_wr_ptr_async_secenc),
    .W_RD_PTR_ASYNC                      (w_rd_ptr_async_secenc),
    .W_PAYLD_ASYNC                       (w_payld_async_secenc),
    .B_WR_PTR_ASYNC                      (b_wr_ptr_async_secenc),
    .B_RD_PTR_ASYNC                      (b_rd_ptr_async_secenc),
    .B_PAYLD_ASYNC                       (b_payld_async_secenc),
    .AR_WR_PTR_ASYNC                     (ar_wr_ptr_async_secenc),
    .AR_RD_PTR_ASYNC                     (ar_rd_ptr_async_secenc),
    .AR_PAYLD_ASYNC                      (ar_payld_async_secenc),
    .R_WR_PTR_ASYNC                      (r_wr_ptr_async_secenc),
    .R_RD_PTR_ASYNC                      (r_rd_ptr_async_secenc),
    .R_PAYLD_ASYNC                       (r_payld_async_secenc),
                                         
    .MHU_HSE0_APB_ASYNC_REQ              (apb_async_req_hse0_mhu),
    .MHU_HSE0_APB_ASYNC_REQ_PAYLOAD      (apb_async_req_payload_hse0_mhu),
    .MHU_HSE0_APB_ASYNC_RESP_PAYLOAD     (apb_async_resp_payload_hse0_mhu),
    .MHU_HSE0_APB_ASYNC_ACK              (apb_async_ack_hse0_mhu),
    .MHU_HSE0_RECAWAKE_ASYNC             (recawake_async_hse0_mhu),
    .MHU_HSE0_RECWAKEUP_ASYNC            (recwakeup_async_hse0_mhu),
    .MHU_HSE0_EDGE_ASYNC_REQ             (edge_async_req_hse0_mhu),
    .MHU_HSE0_EDGE_ASYNC_ACK             (edge_async_ack_hse0_mhu),
                                         
    .MHU_SEH0_APB_ASYNC_REQ              (apb_async_req_seh0_mhu),
    .MHU_SEH0_APB_ASYNC_REQ_PAYLOAD      (apb_async_req_payload_seh0_mhu),
    .MHU_SEH0_APB_ASYNC_RESP_PAYLOAD     (apb_async_resp_payload_seh0_mhu),
    .MHU_SEH0_APB_ASYNC_ACK              (apb_async_ack_seh0_mhu),
    .MHU_SEH0_RECAWAKE_ASYNC             (recawake_async_seh0_mhu),
    .MHU_SEH0_RECWAKEUP_ASYNC            (recwakeup_async_seh0_mhu),
    .MHU_SEH0_EDGE_ASYNC_REQ             (edge_async_req_seh0_mhu),
    .MHU_SEH0_EDGE_ASYNC_ACK             (edge_async_ack_seh0_mhu),
                                         
    .MHU_HSE1_APB_ASYNC_REQ              (apb_async_req_hse1_mhu),
    .MHU_HSE1_APB_ASYNC_REQ_PAYLOAD      (apb_async_req_payload_hse1_mhu),
    .MHU_HSE1_APB_ASYNC_RESP_PAYLOAD     (apb_async_resp_payload_hse1_mhu),
    .MHU_HSE1_APB_ASYNC_ACK              (apb_async_ack_hse1_mhu),
    .MHU_HSE1_RECAWAKE_ASYNC             (recawake_async_hse1_mhu),
    .MHU_HSE1_RECWAKEUP_ASYNC            (recwakeup_async_hse1_mhu),
    .MHU_HSE1_EDGE_ASYNC_REQ             (edge_async_req_hse1_mhu),
    .MHU_HSE1_EDGE_ASYNC_ACK             (edge_async_ack_hse1_mhu),
                                                              
    .MHU_SEH1_APB_ASYNC_REQ              (apb_async_req_seh1_mhu),
    .MHU_SEH1_APB_ASYNC_REQ_PAYLOAD      (apb_async_req_payload_seh1_mhu),
    .MHU_SEH1_APB_ASYNC_RESP_PAYLOAD     (apb_async_resp_payload_seh1_mhu),
    .MHU_SEH1_APB_ASYNC_ACK              (apb_async_ack_seh1_mhu),
    .MHU_SEH1_RECAWAKE_ASYNC             (recawake_async_seh1_mhu),
    .MHU_SEH1_RECWAKEUP_ASYNC            (recwakeup_async_seh1_mhu),
    .MHU_SEH1_EDGE_ASYNC_REQ             (edge_async_req_seh1_mhu),
    .MHU_SEH1_EDGE_ASYNC_ACK             (edge_async_ack_seh1_mhu),

  
    .MHU_ES0SE0_APB_ASYNC_REQ            (mhu_es0se0_apb_async_req),
    .MHU_ES0SE0_APB_ASYNC_REQ_PAYLOAD    (mhu_es0se0_apb_async_req_payload),
    .MHU_ES0SE0_APB_ASYNC_RESP_PAYLOAD   (mhu_es0se0_apb_async_resp_payload),
    .MHU_ES0SE0_APB_ASYNC_ACK            (mhu_es0se0_apb_async_ack),
    .MHU_ES0SE0_RECAWAKE_ASYNC           (mhu_es0se0_recawake_async),
    .MHU_ES0SE0_RECWAKEUP_ASYNC          (mhu_es0se0_recwakeup_async),
    .MHU_ES0SE0_EDGE_ASYNC_REQ           (mhu_es0se0_edge_async_req),
    .MHU_ES0SE0_EDGE_ASYNC_ACK           (mhu_es0se0_edge_async_ack),
    
    .MHU_SEES00_APB_ASYNC_REQ            (mhu_sees00_apb_async_req),
    .MHU_SEES00_APB_ASYNC_REQ_PAYLOAD    (mhu_sees00_apb_async_req_payload),
    .MHU_SEES00_APB_ASYNC_RESP_PAYLOAD   (mhu_sees00_apb_async_resp_payload),
    .MHU_SEES00_APB_ASYNC_ACK            (mhu_sees00_apb_async_ack),
    .MHU_SEES00_RECAWAKE_ASYNC           (mhu_sees00_recawake_async),
    .MHU_SEES00_RECWAKEUP_ASYNC          (mhu_sees00_recwakeup_async),
    .MHU_SEES00_EDGE_ASYNC_REQ           (mhu_sees00_edge_async_req),
    .MHU_SEES00_EDGE_ASYNC_ACK           (mhu_sees00_edge_async_ack),
  
    
    .MHU_ES0SE1_APB_ASYNC_REQ            (mhu_es0se1_apb_async_req),
    .MHU_ES0SE1_APB_ASYNC_REQ_PAYLOAD    (mhu_es0se1_apb_async_req_payload),
    .MHU_ES0SE1_APB_ASYNC_RESP_PAYLOAD   (mhu_es0se1_apb_async_resp_payload),
    .MHU_ES0SE1_APB_ASYNC_ACK            (mhu_es0se1_apb_async_ack),
    .MHU_ES0SE1_RECAWAKE_ASYNC           (mhu_es0se1_recawake_async),
    .MHU_ES0SE1_RECWAKEUP_ASYNC          (mhu_es0se1_recwakeup_async),
    .MHU_ES0SE1_EDGE_ASYNC_REQ           (mhu_es0se1_edge_async_req),
    .MHU_ES0SE1_EDGE_ASYNC_ACK           (mhu_es0se1_edge_async_ack),
    
    .MHU_SEES01_APB_ASYNC_REQ            (mhu_sees01_apb_async_req),
    .MHU_SEES01_APB_ASYNC_REQ_PAYLOAD    (mhu_sees01_apb_async_req_payload),
    .MHU_SEES01_APB_ASYNC_RESP_PAYLOAD   (mhu_sees01_apb_async_resp_payload),
    .MHU_SEES01_APB_ASYNC_ACK            (mhu_sees01_apb_async_ack),
    .MHU_SEES01_RECAWAKE_ASYNC           (mhu_sees01_recawake_async),
    .MHU_SEES01_RECWAKEUP_ASYNC          (mhu_sees01_recwakeup_async), 
    .MHU_SEES01_EDGE_ASYNC_REQ           (mhu_sees01_edge_async_req),
    .MHU_SEES01_EDGE_ASYNC_ACK           (mhu_sees01_edge_async_ack),
    
    .MHU_ES1SE0_APB_ASYNC_REQ            (mhu_es1se0_apb_async_req),
    .MHU_ES1SE0_APB_ASYNC_REQ_PAYLOAD    (mhu_es1se0_apb_async_req_payload),
    .MHU_ES1SE0_APB_ASYNC_RESP_PAYLOAD   (mhu_es1se0_apb_async_resp_payload),
    .MHU_ES1SE0_APB_ASYNC_ACK            (mhu_es1se0_apb_async_ack),
    .MHU_ES1SE0_RECAWAKE_ASYNC           (mhu_es1se0_recawake_async),
    .MHU_ES1SE0_RECWAKEUP_ASYNC          (mhu_es1se0_recwakeup_async),
    .MHU_ES1SE0_EDGE_ASYNC_REQ           (mhu_es1se0_edge_async_req),
    .MHU_ES1SE0_EDGE_ASYNC_ACK           (mhu_es1se0_edge_async_ack),
    
    .MHU_SEES10_APB_ASYNC_REQ            (mhu_sees10_apb_async_req),
    .MHU_SEES10_APB_ASYNC_REQ_PAYLOAD    (mhu_sees10_apb_async_req_payload),
    .MHU_SEES10_APB_ASYNC_RESP_PAYLOAD   (mhu_sees10_apb_async_resp_payload),
    .MHU_SEES10_APB_ASYNC_ACK            (mhu_sees10_apb_async_ack),
    .MHU_SEES10_RECAWAKE_ASYNC           (mhu_sees10_recawake_async),
    .MHU_SEES10_RECWAKEUP_ASYNC          (mhu_sees10_recwakeup_async),
    .MHU_SEES10_EDGE_ASYNC_REQ           (mhu_sees10_edge_async_req),
    .MHU_SEES10_EDGE_ASYNC_ACK           (mhu_sees10_edge_async_ack),
  
    
    .MHU_ES1SE1_APB_ASYNC_REQ            (mhu_es1se1_apb_async_req),
    .MHU_ES1SE1_APB_ASYNC_REQ_PAYLOAD    (mhu_es1se1_apb_async_req_payload),
    .MHU_ES1SE1_APB_ASYNC_RESP_PAYLOAD   (mhu_es1se1_apb_async_resp_payload),
    .MHU_ES1SE1_APB_ASYNC_ACK            (mhu_es1se1_apb_async_ack),
    .MHU_ES1SE1_RECAWAKE_ASYNC           (mhu_es1se1_recawake_async),
    .MHU_ES1SE1_RECWAKEUP_ASYNC          (mhu_es1se1_recwakeup_async),
    .MHU_ES1SE1_EDGE_ASYNC_REQ           (mhu_es1se1_edge_async_req),
    .MHU_ES1SE1_EDGE_ASYNC_ACK           (mhu_es1se1_edge_async_ack),
    
    .MHU_SEES11_APB_ASYNC_REQ            (mhu_sees11_apb_async_req),
    .MHU_SEES11_APB_ASYNC_REQ_PAYLOAD    (mhu_sees11_apb_async_req_payload),
    .MHU_SEES11_APB_ASYNC_RESP_PAYLOAD   (mhu_sees11_apb_async_resp_payload),
    .MHU_SEES11_APB_ASYNC_ACK            (mhu_sees11_apb_async_ack),
    .MHU_SEES11_RECAWAKE_ASYNC           (mhu_sees11_recawake_async),
    .MHU_SEES11_RECWAKEUP_ASYNC          (mhu_sees11_recwakeup_async), 
    .MHU_SEES11_EDGE_ASYNC_REQ           (mhu_sees11_edge_async_req),
    .MHU_SEES11_EDGE_ASYNC_ACK           (mhu_sees11_edge_async_ack),
   
 
    .SOC_WD_IRQ                          (secenc_soc_wd_irq),
    .UART_IRQ                            (secenc_uart_irq),
    .PPU_IRQ                             (secenc_ppu_irq), 
    .CO_IRQ                              (secenc_co_irq),
  
    .MHU2R_CIRQ      (secenc_mhu2r_cirq),
    .MHU2S_CIRQ      (secenc_mhu2s_cirq),
      .MHU3R_CIRQ      (secenc_mhu3r_cirq),
    .MHU3S_CIRQ      (secenc_mhu3s_cirq),
    
    .MHU4R_CIRQ      (secenc_mhu4r_cirq),
    .MHU4S_CIRQ      (secenc_mhu4s_cirq),
      .MHU5R_CIRQ      (secenc_mhu5r_cirq),
    .MHU5S_CIRQ      (secenc_mhu5s_cirq),
      .HOST_FWT_IRQ                        (secenc_host_fwt_irq_ss), 
    .INT_RTT_IRQ                         (secenc_int_rtt_irq_ss), 
    .SWD_WS1_IRQ                         (secenc_swd_ws1_irq_ss), 

    .AON_APB_ASYNC_REQ                   (apb_async_req_secenc_aon),
    .AON_APB_ASYNC_REQ_PAYLOAD           (apb_async_req_payload_secenc_aon),
    .AON_APB_ASYNC_RESP_PAYLOAD          (apb_async_resp_payload_secenc_aon),
    .AON_APB_ASYNC_ACK                   (apb_async_ack_secenc_aon),
    
    .SOCWD_APB_ASYNC_REQ                 (apb_async_req_secenc_socwd),
    .SOCWD_APB_ASYNC_REQ_PAYLOAD         (apb_async_req_payload_secenc_socwd),
    .SOCWD_APB_ASYNC_RESP_PAYLOAD        (apb_async_resp_payload_secenc_socwd),
    .SOCWD_APB_ASYNC_ACK                 (apb_async_ack_secenc_socwd),
                                         
    .MHU0_QREQn                          (secenc_mhu0_qreqn),
    .MHU0_QACCEPTn                       (secenc_mhu0_qacceptn),
    .MHU0_QDENY                          (secenc_mhu0_qdeny),
    .MHU1_QREQn                          (secenc_mhu1_qreqn),
    .MHU1_QACCEPTn                       (secenc_mhu1_qacceptn),
    .MHU1_QDENY                          (secenc_mhu1_qdeny),
   
    .MHU2_QREQn    (secenc_mhu2_qreqn),
    .MHU2_QACCEPTn (secenc_mhu2_qacceptn),
    .MHU2_QDENY    (secenc_mhu2_qdeny),
      .MHU3_QREQn    (secenc_mhu3_qreqn),
    .MHU3_QACCEPTn (secenc_mhu3_qacceptn),
    .MHU3_QDENY    (secenc_mhu3_qdeny),
     
    .MHU4_QREQn    (secenc_mhu4_qreqn),
    .MHU4_QACCEPTn (secenc_mhu4_qacceptn),
    .MHU4_QDENY    (secenc_mhu4_qdeny),
      .MHU5_QREQn    (secenc_mhu5_qreqn),
    .MHU5_QACCEPTn (secenc_mhu5_qacceptn),
    .MHU5_QDENY    (secenc_mhu5_qdeny),
      .CTI_QREQn                           (secenc_cti_qreqn),
    .CTI_QACCEPTn                        (secenc_cti_qacceptn),
    .CTI_QDENY                           (secenc_cti_qdeny),
    .CTI_QACTIVE                         (secenc_cti_qactive),
    .CM0_QREQn                           (secenc_cm0_qreqn),
    .CM0_QACCEPTn                        (secenc_cm0_qacceptn),
    .CM0_QDENY                           (secenc_cm0_qdeny),
    .CM0_QACTIVE                         (secenc_cm0_qactive),
    .AXIB_QREQn                          (secenc_axib_qreqn),
    .AXIB_QACCEPTn                       (secenc_axib_qacceptn),
    .AXIB_QDENY                          (secenc_axib_qdeny),
    .AXIB_QACTIVE                        (secenc_axib_qactive),
    .SOCWD_ADB_QREQn                     (secenc_socwd_adb_qreqn),
    .SOCWD_ADB_QACCEPTn                  (secenc_socwd_adb_qacceptn),
    .SOCWD_ADB_QDENY                     (secenc_socwd_adb_qdeny),
    .SOCWD_ADB_QACTIVE                   (secenc_socwd_adb_qactive),
    .AON_ADB_QREQn                       (secenc_aon_adb_qreqn),
    .AON_ADB_QACCEPTn                    (secenc_aon_adb_qacceptn),
    .AON_ADB_QDENY                       (secenc_aon_adb_qdeny),
    .AON_ADB_QACTIVE                     (secenc_aon_adb_qactive),
              
    .WDOG_RST_REQ                        (secenc_wdog_rst_req),
    .SW_RST_REQ                          (secenc_sw_rst_req),
    
    .DBGEN                               (dbgen_secencauth),
    .NIDEN                               (niden_secencauth),
    .CHEN                                (chen_secencauth),
    .FIREWALL_BYPASS                     (secenc_fctrl_bypass),

    .CAAON2CA                            (secenc_caaon2ca),
    .CA2CAAON                            (secenc_ca2caaon),
    
    .CAE                                 (secenc_cae),
    .CA_ERR_MSK                          (secenc_ca_err_msk),

    
    .DFTRSTDISABLE                       (DFTRSTDISABLE),
    .DFTRAMHOLD                          (DFTRAMHOLD),
    .DFTCGEN                             (DFTCGEN),
    .DFTMCPHOLD                          (DFTMCPHOLD),
    .MBISTREQ                            (MBISTREQ),
    .DFTSE                               (DFTSE),
    .DFTTESTMODE                         (DFTTESTMODE)
    );
  
  
  
  assign dbgen_secencauth      = scb_secenc[2]; 
  assign niden_secencauth      = scb_secenc[3]; 
  assign chen_secencauth       = scb_secenc[4];
  
  assign dbgen_dpauth          = scb_secenc[5];
  assign niden_dpauth          = scb_secenc[6];
  assign spiden_dpauth         = scb_secenc[7];
  assign spniden_dpauth        = scb_secenc[8];
  
  assign dbgen_comauth         = scb_secenc[9];
  assign niden_comauth         = scb_secenc[10];
 
  assign dbgen_tpiuauth        = scb_secenc[13];
  assign niden_tpiuauth        = scb_secenc[14];
  assign spiden_tpiuauth       = scb_secenc[15];
  assign chen_tpiuauth         = scb_secenc[17];

  assign dbgen_counterauth     = scb_secenc[18];
  assign niden_counterauth     = scb_secenc[19];
  assign chen_counterauth      = scb_secenc[22];

  assign ap_en_hostextauth        = scb_secenc[23];
  assign ap_secure_en_hostextauth = scb_secenc[24];
  
  assign dbgen_hostaxiauth     = scb_secenc[25];
  assign niden_hostaxiauth     = scb_secenc[26];
  assign spiden_hostaxiauth    = scb_secenc[27];
  assign spniden_hostaxiauth   = scb_secenc[28];
  
  assign dbgen_hostauth        = scb_secenc[29];
  assign niden_hostauth        = scb_secenc[30];
  assign spiden_hostauth       = scb_secenc[31];
  assign spniden_hostauth      = scb_secenc[32];
  assign chen_hostauth         = scb_secenc[33];
                               
  assign host_cpu_dbgen        = {4{dbgen_hostauth}};
  assign host_cpu_niden        = {4{niden_hostauth}};
  assign host_cpu_spiden       = {4{spiden_hostauth}};
  assign host_cpu_spniden      = {4{spniden_hostauth}};
  
  assign HOSTDBGAUTHDBGEN      = dbgen_hostauth;
  assign HOSTDBGAUTHNIDEN      = niden_hostauth;
  assign HOSTDBGAUTHSPIDEN     = spiden_hostauth;
  assign HOSTDBGAUTHSPNIDEN    = spniden_hostauth;
  
  assign DFTENABLE[0]          = scb_secenc[34];
  assign DFTENABLE[1]          = scb_secenc[63];

  assign ppu_dbgen             = scb_secenc[35];
  
  assign secenc_fctrl_bypass   = scb_secenc[36];
  assign host_fctrl_bypass     = scb_secenc[37];
  
  assign acg_dp_dbgen          = scb_secenc[38];
  assign acg_hostext_dbgen     = scb_secenc[39];
  assign acg_extsys0_dbgen     = scb_secenc[40];
  assign acg_extsys1_dbgen     = scb_secenc[41];

  assign host_cpuwait_wen      = scb_secenc[48];
  assign extsys0_cpuwait_wen   = scb_secenc[49];
  assign extsys1_cpuwait_wen   = scb_secenc[50];
  
  assign SCBEXP                = scb_secenc[127:64];
  
  assign unused_scb_secenc = |{scb_secenc[0],
                               scb_secenc[1],
                               scb_secenc[11],
                               scb_secenc[12],
                               scb_secenc[16],
                               scb_secenc[21],
                               scb_secenc[20],
 
                               scb_secenc[42],
 
                               scb_secenc[43],
 
                               scb_secenc[47:44],
                               host_cpuwait_wen, 
 
                               scb_secenc[51],
 
                               scb_secenc[52],
 
                               scb_secenc[62:53]};
  
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_arm_element_or_tree_2 (
    .or_tree_i          ({SOCLCC, debug_calc}),
    .or_tree_o          (secenc_calc)
  );  
  
  secenc_f1_aontop #(
    .SEC_ENC_ROM_SIZE             (SEC_ENC_ROM_SIZE),
    .SEC_ENC_RAM_SIZE             (SEC_ENC_RAM_SIZE),
    .CAAON2CA_WIDTH               (CAAON2CA_WIDTH),
    .CA2CAAON_WIDTH               (CA2CAAON_WIDTH),
    .DEV_PREQ_DLY_SECENC          (DEV_PREQ_DLY_SECENC),
    .PCSM_PREQ_DLY_SECENC         (PCSM_PREQ_DLY_SECENC),
    .ISO_CLKEN_DLY_CFG_SECENC     (ISO_CLKEN_DLY_CFG_SECENC),
    .CLKEN_RST_DLY_CFG_SECENC     (CLKEN_RST_DLY_CFG_SECENC),
    .RST_HWSTAT_DLY_CFG_SECENC    (RST_HWSTAT_DLY_CFG_SECENC),
    .CLKEN_ISO_DLY_CFG_SECENC     (CLKEN_ISO_DLY_CFG_SECENC),
    .ISO_RST_DLY_CFG_SECENC       (ISO_RST_DLY_CFG_SECENC)
  ) u_secenc_f1_aontop (         
    .SECENCREFCLK                 (SECENCREFCLK),
    .SYSPLL                       (SYSPLL),      
    .SYSPLLLOCK                   (SYSPLLLOCK), 
    .S32KCLK                      (S32KCLK),
                                  
    .SEPORESETn                   (seporesetn),
                                  
    .SECENCCLK                    (secenc_clk),
    .SECENCDIVCLK                 (secenc_divclk),
    .SECENCHINTCLK                (secenc_hintclk),
    .S32KCLK_SECENC               (secenc_s32kclk),
                                    
    .SECENCPORESETn               (secenc_poresetn),
    .SECENCWARMRESETn             (secenc_warmresetn),
                                  
    .nUARTCTS                     (SECENCUARTCTSn),
    .nUARTDCD                     (SECENCUARTDCDn),
    .nUARTDSR                     (SECENCUARTDSRn),
    .nUARTRI                      (SECENCUARTRIn),
    .UARTRXD                      (SECENCUARTRX),
    .UARTTXD                      (SECENCUARTTX),
    .nUARTDTR                     (SECENCUARTDTRn),
    .nUARTRTS                     (SECENCUARTRTSn),
    .nUARTOut1                    (SECENCUARTOUT1n),
    .nUARTOut2                    (SECENCUARTOUT2n),
                                  
    .EXTIRQ                       (secenc_extirq),           
    .SOC_WD_IRQ                   (secenc_soc_wd_irq),
    .UART_IRQ                     (secenc_uart_irq),
    .PPU_IRQ                      (secenc_ppu_irq),
    .CO_IRQ                       (secenc_co_irq),
  
    .MHU2R_CIRQ      (secenc_mhu2r_cirq),
    .MHU2S_CIRQ      (secenc_mhu2s_cirq),
      .MHU3R_CIRQ      (secenc_mhu3r_cirq),
    .MHU3S_CIRQ      (secenc_mhu3s_cirq),
    
    .MHU4R_CIRQ      (secenc_mhu4r_cirq),
    .MHU4S_CIRQ      (secenc_mhu4s_cirq),
      .MHU5R_CIRQ      (secenc_mhu5r_cirq),
    .MHU5S_CIRQ      (secenc_mhu5s_cirq),
      .HOST_FWT_IRQ                 (fwtamp_intr),
    .INT_RTT_IRQ                  (interrupt_router_tamper_interrupt),
    .SWD_WS1_IRQ                  (secure_wdog_intr_second),
    .HOST_FWT_IRQ_SS              (secenc_host_fwt_irq_ss),
    .INT_RTT_IRQ_SS               (secenc_int_rtt_irq_ss),
    .SWD_WS1_IRQ_SS               (secenc_swd_ws1_irq_ss),
                                  
    .SCB                          (scb_secenc),
    .CALC                         (secenc_calc),
                                  
    .HOST_RST_ACK                 (host_rst_ack),
    .HOST_RST_REQ                 (host_rst_req),
    .HOST_CPUWAIT                 (hostcpu_cpuwait),
    .CHS_PWR_ST                   (secenc_bsys_pwr_st),      
    .SOC_RST_SYN                  (soc_rst_syn),        
    .SE_RST_SYN                   (se_rst_syn),
    .S32_WDOG_RST_REQ             (secenc_soc_wdog_rst_req), 
    .SOC_RST_REQ                  (soc_rst_req),             
    .CHS_PWR_REQ                  (secenc_bsys_pwr_req),     
    .CAE_RST_REQ                  (secenc_cae_rst_req),      
    
    .AON_APB_ASYNC_REQ            (apb_async_req_secenc_aon),
    .AON_APB_ASYNC_REQ_PAYLOAD    (apb_async_req_payload_secenc_aon),
    .AON_APB_ASYNC_RESP_PAYLOAD   (apb_async_resp_payload_secenc_aon),
    .AON_APB_ASYNC_ACK            (apb_async_ack_secenc_aon),
    
    .SOCWD_APB_ASYNC_REQ          (apb_async_req_secenc_socwd),
    .SOCWD_APB_ASYNC_REQ_PAYLOAD  (apb_async_req_payload_secenc_socwd),
    .SOCWD_APB_ASYNC_RESP_PAYLOAD (apb_async_resp_payload_secenc_socwd),
    .SOCWD_APB_ASYNC_ACK          (apb_async_ack_secenc_socwd),
 
    .DBGD_QREQn                   (qreqn_secenc_dbg_pwr),
    .DBGD_QACCEPTn                (qacceptn_secenc_dbg_pwr),
    .DBGD_QDENY                   (qdeny_secenc_dbg_pwr),
    .DBGD_QACTIVE                 (qactive_secenc_dbg_pwr),
                                  
    .MHU0_QREQn                   (secenc_mhu0_qreqn),
    .MHU0_QACCEPTn                (secenc_mhu0_qacceptn),
    .MHU0_QDENY                   (secenc_mhu0_qdeny),
    .MHU1_QREQn                   (secenc_mhu1_qreqn),
    .MHU1_QACCEPTn                (secenc_mhu1_qacceptn),
    .MHU1_QDENY                   (secenc_mhu1_qdeny),
   
    .MHU2_QREQn    (secenc_mhu2_qreqn),
    .MHU2_QACCEPTn (secenc_mhu2_qacceptn),
    .MHU2_QDENY    (secenc_mhu2_qdeny),
      .MHU3_QREQn    (secenc_mhu3_qreqn),
    .MHU3_QACCEPTn (secenc_mhu3_qacceptn),
    .MHU3_QDENY    (secenc_mhu3_qdeny),
     
    .MHU4_QREQn    (secenc_mhu4_qreqn),
    .MHU4_QACCEPTn (secenc_mhu4_qacceptn),
    .MHU4_QDENY    (secenc_mhu4_qdeny),
      .MHU5_QREQn    (secenc_mhu5_qreqn),
    .MHU5_QACCEPTn (secenc_mhu5_qacceptn),
    .MHU5_QDENY    (secenc_mhu5_qdeny),
   
    .CTI_QREQn                    (secenc_cti_qreqn),
    .CTI_QACCEPTn                 (secenc_cti_qacceptn),
    .CTI_QDENY                    (secenc_cti_qdeny),
    .CTI_QACTIVE                  (secenc_cti_qactive),
    .CM0_QREQn                    (secenc_cm0_qreqn),
    .CM0_QACCEPTn                 (secenc_cm0_qacceptn),
    .CM0_QDENY                    (secenc_cm0_qdeny),
    .CM0_QACTIVE                  (secenc_cm0_qactive),
    .AXIB_QREQn                   (secenc_axib_qreqn),
    .AXIB_QACCEPTn                (secenc_axib_qacceptn),
    .AXIB_QDENY                   (secenc_axib_qdeny),
    .AXIB_QACTIVE                 (secenc_axib_qactive),
    .SOCWD_ADB_QREQn              (secenc_socwd_adb_qreqn),
    .SOCWD_ADB_QACCEPTn           (secenc_socwd_adb_qacceptn),
    .SOCWD_ADB_QDENY              (secenc_socwd_adb_qdeny),
    .SOCWD_ADB_QACTIVE            (secenc_socwd_adb_qactive),
    .AON_ADB_QREQn                (secenc_aon_adb_qreqn),
    .AON_ADB_QACCEPTn             (secenc_aon_adb_qacceptn),
    .AON_ADB_QDENY                (secenc_aon_adb_qdeny),
    .AON_ADB_QACTIVE              (secenc_aon_adb_qactive),
                                  
    .SYSC_QREQn                   (qreqn_secenc_systopq),
    .SYSC_QACCEPTn                (qacceptn_secenc_systopq),
    .SYSC_QDENY                   (qdeny_secenc_systopq),
    .SYSC_QACTIVE                 (qactive_secenc_systopq),
                                  
    .DBGC_QREQn                   (qreqn_secenc_dbgtopq),
    .DBGC_QACCEPTn                (qacceptn_secenc_dbgtopq),
    .DBGC_QDENY                   (qdeny_secenc_dbgtopq),
    .DBGC_QACTIVE                 (qactive_secenc_dbgtopq),
                                  
    .MHU_HSE0_RECWAKEUP_ASYNC     (recwakeup_async_hse0_mhu),
    .MHU_HSE1_RECWAKEUP_ASYNC     (recwakeup_async_hse1_mhu),
 
    .MHU_ES0SE0_RECWAKEUP_ASYNC   (mhu_es0se0_recwakeup_async),
      .MHU_ES0SE1_RECWAKEUP_ASYNC   (mhu_es0se1_recwakeup_async),
   
    .MHU_ES1SE0_RECWAKEUP_ASYNC   (mhu_es1se0_recwakeup_async),
      .MHU_ES1SE1_RECWAKEUP_ASYNC   (mhu_es1se1_recwakeup_async),
                                    
    .CDBGPWRUPREQ0                (extdbg_cdbgpwrupreq[0]), 
    .CDBGPWRUPACK0                (extdbg_cdbgpwrupack[0]), 
                                  
    .CLKFORCE                     (secenc_clkforce   ),
    .ENTRY_DELAY                  (secenc_entry_delay),

    .M0_HALTED                    (secenc_m0_halted),
                                  
    .CAAON2CA                     (secenc_caaon2ca),
    .CA2CAAON                     (secenc_ca2caaon),
    
    .CAE                          (secenc_cae),
    .CA_ERR_MSK                   (secenc_ca_err_msk),
    
    
    .DFTDIVSEL                    (DFTDIVSEL),
    .DFTCLKSELEN                  (DFTCLKSELEN),
    .DFTCLKSEL                    (DFTSECCLKSEL),
    .DFTDIVBYPASS                 (DFTDIVBYPASS),
    .DFTRSTDISABLE                ({DFTRSTDISABLE[1],DFTRSTDISABLE[0]}),
    .DFTISODISABLE                (DFTISODISABLE),
    .DFTPWRUP                     (DFTPWRUP),
    .DFTRETDISABLE                (DFTRETDISABLE),
    .DFTCGEN                      (DFTCGEN),
    .MBISTREQ                     (MBISTREQ),
    .nMBISTRESET                  (nMBISTRESET),
    .DFTSE                        (DFTSE),
    .DFTTESTMODE                  (DFTTESTMODE)
  );
  
  generate
    if (SECENC_SHD_INT < 64) begin: gen_secenc_extirq
                                                 
      assign secenc_extirq[63:SECENC_SHD_INT] = {(64-SECENC_SHD_INT){1'b0}};
      assign unused_interrupts                = |secenc_shared_interrupts[63:SECENC_SHD_INT];
    end
  endgenerate
  generate
    if (SECENC_SHD_INT >= 64) begin: gen_secenc_extirq_2
      assign unused_interrupts                = 1'b0;
    end
  endgenerate
  
  assign secenc_extirq[SECENC_SHD_INT-1:0] = secenc_shared_interrupts[SECENC_SHD_INT-1:0];
  
  assign secenc_bsys_pwr_req_systop_pwr_req = secenc_bsys_pwr_req[5:2];
  assign secenc_bsys_pwr_req_dbgtop_pwr_req = secenc_bsys_pwr_req[1];
  assign secenc_bsys_pwr_req_refclk         = secenc_bsys_pwr_req[0];
  
  assign secenc_bsys_pwr_st[5:1]            = secenc_bsys_pwr_st_systop_pwr_st;
  assign secenc_bsys_pwr_st[0]              = secenc_bsys_pwr_st_dbgtop_pwr_st;
  

  assign { EXTSYS1SYSTOPQREQn, EXTSYS0SYSTOPQREQn}   = t_qreqn_extsys_systopq;
  assign t_qacceptn_extsys_systopq = { EXTSYS1SYSTOPQACCEPTn, EXTSYS0SYSTOPQACCEPTn};
  assign t_qdeny_extsys_systopq    = { EXTSYS1SYSTOPQDENY, EXTSYS0SYSTOPQDENY};
  assign t_qactive_extsys_systopq  = { EXTSYS1SYSTOPQACTIVE, EXTSYS0SYSTOPQACTIVE};
  
  assign { EXTSYS1DBGTOPQREQn, EXTSYS0DBGTOPQREQn}   = t_qreqn_extsys_dbgtopq;
  assign t_qacceptn_extsys_dbgtopq = { EXTSYS1DBGTOPQACCEPTn, EXTSYS0DBGTOPQACCEPTn};
  assign t_qdeny_extsys_dbgtopq    = { EXTSYS1DBGTOPQDENY, EXTSYS0DBGTOPQDENY};
  assign t_qactive_extsys_dbgtopq  = { EXTSYS1DBGTOPQACTIVE, EXTSYS0DBGTOPQACTIVE};

 pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (2),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_clustop_dbgtop_egress_comb
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_clustop_egress_comb0_dbgtop    , qreqn_clustop_egress_comb1_dbgtop   }),
    .ctrl_qacceptn_o  ({qacceptn_clustop_egress_comb0_dbgtop , qacceptn_clustop_egress_comb1_dbgtop}),
    .ctrl_qdeny_o     ({qdeny_clustop_egress_comb0_dbgtop    , qdeny_clustop_egress_comb1_dbgtop   }),
    .ctrl_qactive_o   ({qactive_clustop_egress_comb0_dbgtop  , qactive_clustop_egress_comb1_dbgtop }),
    
    .dev_qreqn_o      (qreqn_clustop_egress_dbgtop   ),   
    .dev_qacceptn_i   (qacceptn_clustop_egress_dbgtop),
    .dev_qdeny_i      (qdeny_clustop_egress_dbgtop   ),    
    .dev_qactive_i    (qactive_clustop_egress_dbgtop ),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2+4]),
    
    .dftcgen          (DFTCGEN)
  );
  
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (CLUS_INGRESS_2_DBG),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_clustop_dbgtop_ingress_comb
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_clustop_ingress_comb0_dbgtop   ,  qreqn_clustop_ingress_comb1_dbgtop   }),
    .ctrl_qacceptn_o  ({qacceptn_clustop_ingress_comb0_dbgtop,  qacceptn_clustop_ingress_comb1_dbgtop}),
    .ctrl_qdeny_o     ({qdeny_clustop_ingress_comb0_dbgtop   ,  qdeny_clustop_ingress_comb1_dbgtop   }),
    .ctrl_qactive_o   ({qactive_clustop_ingress_comb0_dbgtop ,  qactive_clustop_ingress_comb1_dbgtop }),
    
    .dev_qreqn_o      (qreqn_clustop_ingress_dbgtop   ),   
    .dev_qacceptn_i   (qacceptn_clustop_ingress_dbgtop),
    .dev_qdeny_i      (qdeny_clustop_ingress_dbgtop   ),    
    .dev_qactive_i    (qactive_clustop_ingress_dbgtop ), 
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2+5]),
    
    .dftcgen          (DFTCGEN)
  );
 
                                        
  genvar i;
  generate 
  for(i=0;i<NUM_EXT_SYS;i=i+1)
  begin : extsys_systopq_comb
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (1),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_extsys_systopq_comb              
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_extsys_systopq_ppu[i],     qreqn_extsys_systopq_rstctrl[i]    }), 
    .ctrl_qacceptn_o  ({qacceptn_extsys_systopq_ppu[i],  qacceptn_extsys_systopq_rstctrl[i] }),
    .ctrl_qdeny_o     ({qdeny_extsys_systopq_ppu[i],     qdeny_extsys_systopq_rstctrl[i]    }),
    .ctrl_qactive_o   ({qactive_extsys_systopq_ppu[i],   qactive_extsys_systopq_rstctrl[i]  }),
    
    .dev_qreqn_o      (t_qreqn_extsys_systopq[i]   ),
    .dev_qacceptn_i   (t_qacceptn_extsys_systopq[i]),
    .dev_qdeny_i      (t_qdeny_extsys_systopq[i]   ),
    .dev_qactive_i    (t_qactive_extsys_systopq[i] ),
  
    .clk_qactive_o    (qactive_refclk_int_gated[i]),
    
    .dftcgen          (DFTCGEN)
  );
  end
  endgenerate
  
  generate 
  for(i=0;i<NUM_EXT_SYS;i=i+1)
  begin : extsys_dbgtopq_comb
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (1),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_extsys_dbgtopq_comb              
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_extsys_dbgtopq_ppu[i],     qreqn_extsys_dbgtopq_rstctrl[i]    }), 
    .ctrl_qacceptn_o  ({qacceptn_extsys_dbgtopq_ppu[i],  qacceptn_extsys_dbgtopq_rstctrl[i] }),
    .ctrl_qdeny_o     ({qdeny_extsys_dbgtopq_ppu[i],     qdeny_extsys_dbgtopq_rstctrl[i]    }),
    .ctrl_qactive_o   ({qactive_extsys_dbgtopq_ppu[i],   qactive_extsys_dbgtopq_rstctrl[i]  }),
    
    .dev_qreqn_o      (t_qreqn_extsys_dbgtopq[i]   ),
    .dev_qacceptn_i   (t_qacceptn_extsys_dbgtopq[i]),
    .dev_qdeny_i      (t_qdeny_extsys_dbgtopq[i]   ),
    .dev_qactive_i    (t_qactive_extsys_dbgtopq[i] ),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS+i]),
    
    .dftcgen          (DFTCGEN)
  );
  end
  endgenerate
  
  
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (1),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_secenc_systopq_comb              
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_secenc_systopq_ppu,     qreqn_secenc_systopq_rstctrl    }), 
    .ctrl_qacceptn_o  ({qacceptn_secenc_systopq_ppu,  qacceptn_secenc_systopq_rstctrl }),
    .ctrl_qdeny_o     ({qdeny_secenc_systopq_ppu,     qdeny_secenc_systopq_rstctrl    }),
    .ctrl_qactive_o   ({qactive_secenc_systopq_ppu,   qactive_secenc_systopq_rstctrl  }),
    
    .dev_qreqn_o      (qreqn_secenc_systopq   ),
    .dev_qacceptn_i   (qacceptn_secenc_systopq),
    .dev_qdeny_i      (qdeny_secenc_systopq   ),
    .dev_qactive_i    (qactive_secenc_systopq ),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2]),
    
    .dftcgen          (DFTCGEN)
  );
  
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (1),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_secenc_dbgtopq_comb              
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({qreqn_secenc_dbgtopq_ppu,     qreqn_secenc_dbgtopq_rstctrl    }), 
    .ctrl_qacceptn_o  ({qacceptn_secenc_dbgtopq_ppu,  qacceptn_secenc_dbgtopq_rstctrl }),
    .ctrl_qdeny_o     ({qdeny_secenc_dbgtopq_ppu,     qdeny_secenc_dbgtopq_rstctrl    }),
    .ctrl_qactive_o   ({qactive_secenc_dbgtopq_ppu,   qactive_secenc_dbgtopq_rstctrl  }),
    
    .dev_qreqn_o      (qreqn_secenc_dbgtopq   ),
    .dev_qacceptn_i   (qacceptn_secenc_dbgtopq),
    .dev_qdeny_i      (qdeny_secenc_dbgtopq   ),
    .dev_qactive_i    (qactive_secenc_dbgtopq ),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2+1]),
    
    .dftcgen          (DFTCGEN)
  );

  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (2),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_dp2hostdbg_aontopq_comb
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({aontoppo_dbgtop_qreqn    , dp2hostdbg_pwrdbg_pwrqreqn}), 
    .ctrl_qacceptn_o  ({aontoppo_dbgtop_qacceptn , dp2hostdbg_pwrdbg_pwrqacceptn}),
    .ctrl_qdeny_o     ({aontoppo_dbgtop_qdeny    , dp2hostdbg_pwrdbg_pwrqdeny}),
    .ctrl_qactive_o   ({aontoppo_dbgtop_qactive  , dp2hostdbg_pwrdbg_pwrqactive}),
    
    .dev_qreqn_o      (dp2hostdbg_pwrdbg_aontop_pwrqreqn),
    .dev_qacceptn_i   (dp2hostdbg_pwrdbg_aontop_pwrqacceptn),
    .dev_qdeny_i      (dp2hostdbg_pwrdbg_aontop_pwrqdeny),
    .dev_qactive_i    (dp2hostdbg_pwrdbg_aontop_pwrqactive),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2+2]),
    
    .dftcgen          (DFTCGEN)
  );
  assign dp2hostdbg_pwrdbg_aontop_pwrqdeny[1] = 1'b0;
  
  
  
  pck600_lpc_q #(
                      .NUM_CTRL_Q_CHL (2),
                      .NUM_DEV_Q_CHL  (2),
                      .CTRL_Q_CH_SYNC(1),
                      .DEV_Q_CH_SYNC(1))
  u_dp2systop_aontopq_comb
  (
    .clk              (refclk_int_gated),
    .reset_n          (refclk_warmresetn),
    
    .ctrl_qreqn_i     ({aontoppo_systop_qreqn    , systop_egress_dbgaon_comb1_pwrqreqn}),
    .ctrl_qacceptn_o  ({aontoppo_systop_qacceptn , systop_egress_dbgaon_comb1_pwrqacceptn}),
    .ctrl_qdeny_o     ({aontoppo_systop_qdeny    , systop_egress_dbgaon_comb1_pwrqdeny}),
    .ctrl_qactive_o   ({aontoppo_systop_qactive  , systop_egress_dbgaon_comb1_pwrqactive}),
    
    .dev_qreqn_o      (systop_egress_dbgaon_comb_pwrqreqn),
    .dev_qacceptn_i   (systop_egress_dbgaon_comb_pwrqacceptn),
    .dev_qdeny_i      (systop_egress_dbgaon_comb_pwrqdeny),
    .dev_qactive_i    (systop_egress_dbgaon_comb_pwrqactive),
  
    .clk_qactive_o    (qactive_refclk_int_gated[NUM_EXT_SYS*2+3]),
    
    .dftcgen          (DFTCGEN)
  );


  
    pck600_clk_ctrl
    #(
     .NUM_Q_CHL        (9),
     .NUM_QACTIVE_ONLY (15),
     .HC_Q_CH_SYNC     (1),
     .PWR_Q_CH_SYNC    (0),
     .CLK_Q_CH_SYNC    (1),
     .ACTIVE_DENY_EN   (1)
    )
    u_clk_ctrl_aondbgctrl
   (
     .clk          (refclk_sleep_gated),
     .reset_n      (refclk_aontopporesetn),
                   
     .dftcgen      (DFTCGEN),
     
     .hc_qreqn_i       (qreqn_aondbg_sleep_gated),
     .hc_qacceptn_o    (qacceptn_aondbg_sleep_gated),
     .hc_qdeny_o       (qdeny_aondbg_sleep_gated),
     .hc_qactive_o     (qactive_aondbg_sleep_gated),
   
     .pwr_qreqn_i      (1'b1),
     .pwr_qacceptn_o   (),
     .pwr_qdeny_o      (),
     .pwr_qactive_o    (),
   
     .clk_qreqn_o      ( {                        aondbgclk_qreqn     ,  qreqn_eh1_refclk    ,  qreqn_eh0_refclk    } ),
     .clk_qacceptn_i   ( {                        aondbgclk_qacceptn  ,  qacceptn_eh1_refclk ,  qacceptn_eh0_refclk } ),
     .clk_qdeny_i      ( {                        aondbgclk_qdeny     ,  qdeny_eh1_refclk    ,  qdeny_eh0_refclk    } ),
     .clk_qactive_i    ( {aondbgclk_qactive_only, aondbgclk_qactive   ,  qactive_eh1_refclk  ,  qactive_eh0_refclk  } ),
   
     .clk_force_i      (clkforce_st_refclk_force_st),
   
     .entry_delay_i    (refclk_ctrl_entrydelay),
   
     .clken_o          ( aondbgclk_en)
   );
   
   arm_element_clock_gate u_aondbgclk_en (
    .clk_in  (refclk_sleep_gated),
    .enable  (aondbgclk_en),
    .clk_out (aondbgclk),
    .dftcgen (DFTCGEN)
  );
   
   
   // Buffer is recommended for new tool-added connections for complete equivalence checking 
   // where DFTSE connections already exist in RTL
   arm_element_std_buffer u_dftse_buffer (
    .buf_in (DFTSE),
    .buf_out()
   );

  wire unused;
  
  assign unused     = (|hostcpuclk_ctrl_clkselect[7:3]) | 
                      (|gicclk_ctrl_clkselect[7:2])     | 
                      (|aclk_ctrl_clkselect[7:2])       | 
                      (|ctrlclk_ctrl_clkselect[7:2])    | 
                      (|dbgclk_ctrl_clkselect[7:2])     | 
                      (qactive_clustop_egress_comb1_dbgtop)  |
                      (unused_interrupts)               |                     
                      (|pe0_rvbaraddr_up_rvbar43_32[11:8]) | 
                      (|pe1_rvbaraddr_up_rvbar43_32[11:8]) |
                      (|pe2_rvbaraddr_up_rvbar43_32[11:8]) |                      
                      (|pe3_rvbaraddr_up_rvbar43_32[11:8]);  
  
  endmodule
  
  
  

