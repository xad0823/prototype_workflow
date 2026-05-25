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


module sse710_cpu_gic_socket #(
parameter HOST_CPU_TYPE = 3,
parameter HOST_CPU_NUM_CORES = 4,
parameter NUM_SPIS = 480,
parameter NUM_GICRID_BITS = 12,
parameter NUM_GICWID_BITS = 12,
parameter NUM_EXP_SHD_INT = 64
)
(
  input   wire                                        REFCLK,                            
  input   wire                                        HOSTCNTCLKOUT,                     
  input   wire                                        HOSTCPUCLKOUT,                     
  input   wire                                        GICCLKOUT,                         
  input   wire                                        GICRESETn,                         
  input   wire  [HOST_CPU_NUM_CORES-1:0]              HOSTCPUPORESETn,                   
  input   wire  [HOST_CPU_NUM_CORES-1:0]              HOSTCPUWARMRESETn,                 
  input   wire                                        HOSTCLUSTOPWARMRESETn,             
  input   wire                                        HOSTCLUSTOPPORESETn,               

  input   wire                                        L2RSTDISABLE,                      
  input   wire  [3:0]                                 DBGPWRDUP,                         
  output  wire  [3:0]                                 DBGNOPWRDWN,                       
  output  wire  [3:0]                                 DBGPWRUPREQ,                       
  output  wire  [3:0]                                 STANDBYWFI,                        
  output  wire                                        STANDBYWFIL2,                      

  output  wire  [HOST_CPU_NUM_CORES-1:0]              WARMRSTREQ,                        
  input   wire                                        L2FLUSHREQ,                        
  output  wire                                        L2FLUSHDONE,                       
  output  wire  [HOST_CPU_NUM_CORES-1:0]              SMPEN,                             
  output  wire  [HOST_CPU_NUM_CORES-1:0]              WAKEUPREQ,                         

  output  wire  [HOST_CPU_NUM_CORES-1:0]              CPUQACTIVE,                        
  input   wire  [HOST_CPU_NUM_CORES-1:0]              CPUQREQn,                          
  output  wire  [HOST_CPU_NUM_CORES-1:0]              CPUQDENY,                          
  output  wire  [HOST_CPU_NUM_CORES-1:0]              CPUQACCEPTn,                       

  output  wire                                        L2QACTIVE,                         
  input   wire                                        L2QREQn,                           
  output  wire                                        L2QDENY,                           
  output  wire                                        L2QACCEPTn,                        

  output  wire  [HOST_CPU_NUM_CORES-1:0]              DBGRSTREQ,                         

  input   wire  [4:0]                                 GICINTDBGTOP,
  input   wire  [9:0]                                 GICINTMHUS,
  input   wire  [9:0]                                 GICINTMHUNS,
  input   wire  [1:0]                                 GICINTWDOGS,
  input   wire                                        GICINTWDOGNS,
  input   wire  [1:0]                                 GICINTUART,

  input   wire  [NUM_EXP_SHD_INT+31:0]                GICSHDINT,



  input  wire [NUM_GICRID_BITS-1:0]                   ARIDGICM,
  input  wire                [18:0]                   ARADDRGICM,
  input  wire                 [7:0]                   ARLENGICM,
  input  wire                 [2:0]                   ARSIZEGICM,
  input  wire                 [1:0]                   ARBURSTGICM,
  input  wire                 [2:0]                   ARPROTGICM,
  input  wire                 [2:0]                   ARUSERGICM,
  input  wire                                         ARVALIDGICM,
  output wire                                         ARREADYGICM,

  output wire [NUM_GICRID_BITS-1:0]                   RIDGICM,
  output wire                [31:0]                   RDATAGICM,
  output wire                                         RLASTGICM,
  output wire                 [1:0]                   RRESPGICM,
  output wire                                         RVALIDGICM,
  input  wire                                         RREADYGICM,

  input  wire [NUM_GICWID_BITS-1:0]                   AWIDGICM,
  input  wire                [18:0]                   AWADDRGICM,
  input  wire                 [7:0]                   AWLENGICM,
  input  wire                 [2:0]                   AWSIZEGICM,
  input  wire                 [1:0]                   AWBURSTGICM,
  input  wire                 [2:0]                   AWPROTGICM,
  input  wire                 [2:0]                   AWUSERGICM,
  input  wire                                         AWVALIDGICM,
  output wire                                         AWREADYGICM,

  input  wire                [31:0]                   WDATAGICM,
  input  wire                 [3:0]                   WSTRBGICM,
  input  wire                                         WVALIDGICM,
  output wire                                         WREADYGICM,

  output wire [NUM_GICWID_BITS-1:0]                   BIDGICM,
  output wire                 [1:0]                   BRESPGICM,
  output wire                                         BVALIDGICM,
  input  wire                                         BREADYGICM,


  input  wire                                         ARREADYHOSTCPUMEM,                          
  output wire                                         ARVALIDHOSTCPUMEM,                          
  output wire [39:0]                                  ARADDRHOSTCPUMEM,                           
  output wire [7:0]                                   ARLENHOSTCPUMEM,                            
  output wire [2:0]                                   ARSIZEHOSTCPUMEM,                           
  output wire [1:0]                                   ARBURSTHOSTCPUMEM,                          
  output wire                                         ARLOCKHOSTCPUMEM,                           
  output wire [3:0]                                   ARCACHEHOSTCPUMEM,                          
  output wire [2:0]                                   ARPROTHOSTCPUMEM,                           
  output wire [5:0]                                   ARIDHOSTCPUMEM,                             
  input  wire                                         RVALIDHOSTCPUMEM,                            
  input  wire                                         RLASTHOSTCPUMEM,                             
  input  wire [127:0]                                 RDATAHOSTCPUMEM,                             
  input  wire [1:0]                                   RRESPHOSTCPUMEM,                             
  input  wire [5:0]                                   RIDHOSTCPUMEM,                               
  output wire                                         RREADYHOSTCPUMEM,                            
  input  wire                                         AWREADYHOSTCPUMEM,                           
  output wire                                         AWVALIDHOSTCPUMEM,                           
  output wire [39:0]                                  AWADDRHOSTCPUMEM,                            
  output wire [7:0]                                   AWLENHOSTCPUMEM,                             
  output wire [2:0]                                   AWSIZEHOSTCPUMEM,                            
  output wire [1:0]                                   AWBURSTHOSTCPUMEM,                           
  output wire                                         AWLOCKHOSTCPUMEM,                            
  output wire [3:0]                                   AWCACHEHOSTCPUMEM,                           
  output wire [2:0]                                   AWPROTHOSTCPUMEM,                            
  output wire [4:0]                                   AWIDHOSTCPUMEM,                              
  input  wire                                         WREADYHOSTCPUMEM,                            
  output wire                                         WVALIDHOSTCPUMEM,                            
  output wire                                         WLASTHOSTCPUMEM,                             
  output wire [127:0]                                 WDATAHOSTCPUMEM,                             
  output wire [15:0]                                  WSTRBHOSTCPUMEM,                             
  output wire [4:0]                                   WIDHOSTCPUMEM,                               
  input  wire                                         BVALIDHOSTCPUMEM,                            
  input  wire [1:0]                                   BRESPHOSTCPUMEM,                             
  input  wire [4:0]                                   BIDHOSTCPUMEM,                               
  output wire                                         BREADYHOSTCPUMEM,                            

  input  wire                                         PSELHOSTCPUDBG,   
  input  wire [31:0]                                  PADDRHOSTCPUDBG,    
  input  wire                                         PWRITEHOSTCPUDBG, 
  output wire [31:0]                                  PRDATAHOSTCPUDBG, 
  input  wire [31:0]                                  PWDATAHOSTCPUDBG, 
  input  wire                                         PENABLEHOSTCPUDBG,
  output wire                                         PREADYHOSTCPUDBG, 
  output wire                                         PSLVERRHOSTCPUDBG,
  input  wire                                         PWAKEUPHOSTCPUDBG,

  input  wire [3:0]                                   HOSTCPUDBGAUTHDBGEN,                         
  input  wire [3:0]                                   HOSTCPUDBGAUTHSPIDEN,                        
  input  wire [3:0]                                   HOSTCPUDBGAUTHNIDEN,                         
  input  wire [3:0]                                   HOSTCPUDBGAUTHSPNIDEN,                       

  input  wire [63:0]                                  TSVALUEB,                                    
  input  wire [63:0]                                  HOSTCNTVALUEG,                               

  input  wire [HOST_CPU_NUM_CORES-1:0]                CP15SDISABLE,                                
  input  wire [HOST_CPU_NUM_CORES-1:0]                CFGEND,                                      
  input  wire [HOST_CPU_NUM_CORES-1:0]                VINITHI,                                     
  input  wire [HOST_CPU_NUM_CORES-1:0]                CFGTE,                                       
  input  wire [HOST_CPU_NUM_CORES-1:0]                AA64nAA32,
  input  wire [39:2]                                  RVBARADDR0,
  input  wire [39:2]                                  RVBARADDR1,
  input  wire [39:2]                                  RVBARADDR2,
  input  wire [39:2]                                  RVBARADDR3,
  input  wire                                         CRYPTODISABLE,

  input  wire                                         CFGSDISABLE,                                 

  input  wire                                         ATREADYHOSTCPUTRACE,                         
  input  wire                                         AFVALIDHOSTCPUTRACE,                         
  output wire                                         AFREADYHOSTCPUTRACE,                         
  output wire                                         ATVALIDHOSTCPUTRACE,                         
  output wire                                         ATWAKEUPHOSTCPUTRACE,                        
  input  wire                                         SYNCREQHOSTCPUTRACE,                         
  output wire [31:0]                                  ATDATAHOSTCPUTRACE,                          
  output wire [1:0]                                   ATBYTESHOSTCPUTRACE,                         
  output wire [6:0]                                   ATIDHOSTCPUTRACE,                            



  input  wire                                         MBISTREQ,
  input  wire                                         nMBISTRESET,
  input  wire                                         DFTCGEN,
  input  wire                                         DFTMCPHOLD,
  input  wire                                         DFTRSTDISABLE,
  input  wire                                         DFTRAMHOLD,  

  input  wire [3:0]                                   CTICHOUTACK,                                 
  output wire [3:0]                                   CTICHOUT,                                    

  input  wire [3:0]                                   CTICHIN,                                     
  output wire [3:0]                                   CTICHINACK                                   

);

wire [HOST_CPU_NUM_CORES-1:0] nirqcpu_int;
wire [HOST_CPU_NUM_CORES-1:0] nfiqcpu_int;
wire [HOST_CPU_NUM_CORES-1:0] nvirqcpu_int;
wire [HOST_CPU_NUM_CORES-1:0] nvfiqcpu_int;
wire [HOST_CPU_NUM_CORES-1:0] nirqcpu_ss;
wire [HOST_CPU_NUM_CORES-1:0] nfiqcpu_ss;
wire [HOST_CPU_NUM_CORES-1:0] nvirqcpu_ss;
wire [HOST_CPU_NUM_CORES-1:0] nvfiqcpu_ss;
wire [HOST_CPU_NUM_CORES-1:0] ncntpsirq_int;   
wire [HOST_CPU_NUM_CORES-1:0] ncntpnsirq_int;  
wire [HOST_CPU_NUM_CORES-1:0] ncntvirq_int;    
wire [HOST_CPU_NUM_CORES-1:0] ncnthpirq_int;
wire [HOST_CPU_NUM_CORES-1:0] ncntpsirq_ss;   
wire [HOST_CPU_NUM_CORES-1:0] ncntpnsirq_ss;  
wire [HOST_CPU_NUM_CORES-1:0] ncntvirq_ss;    
wire [HOST_CPU_NUM_CORES-1:0] ncnthpirq_ss;
wire [NUM_SPIS-1:0] irqs_ss;
 
wire                          l2qreqn_ss;
 
wire [HOST_CPU_NUM_CORES-1:0] dbgpwrdup_ss;
wire [HOST_CPU_NUM_CORES-1:0] cfgte_ss;
wire [HOST_CPU_NUM_CORES-1:0] cfgend_ss;
wire [HOST_CPU_NUM_CORES-1:0] vinithi_ss;
wire                          cfgsdisable_ss;
wire [HOST_CPU_NUM_CORES-1:0] cp15sdisable_ss;
wire [HOST_CPU_NUM_CORES-1:0] aa64naa32_ss;
 
wire [39:2]                   rvbaraddr0_ss;
  wire [39:2]                   rvbaraddr1_ss;
    wire [39:2]                   rvbaraddr2_ss;
    wire [39:2]                  rvbaraddr3_ss;
   
wire        cryptodisable_ss;
 
wire [3:0]                    atreadym;
wire [3:0]                    afvalidm;
wire [3:0]                    afreadym;
wire [3:0]                    atvalidm;
wire [27:0]                   atidm;
wire [3:0]                    syncreq;
wire [127:0]                  atdatam;
wire [7:0]                    atbytesm;

wire [HOST_CPU_NUM_CORES-1:0] nirqout;
wire [HOST_CPU_NUM_CORES-1:0] nfiqout;
wire [HOST_CPU_NUM_CORES-1:0] wakeupreq_int;

wire [HOST_CPU_NUM_CORES-1:0] ctiirq_int;
wire [HOST_CPU_NUM_CORES-1:0] ctiirq_int_ack;
wire [HOST_CPU_NUM_CORES-1:0] ncommirq_int;
wire                          nexterrirq_int;
 
wire                          ninterrirq_int;
 
wire [HOST_CPU_NUM_CORES-1:0] npmuirq_int;

wire [43:0]                   awaddrhostcpumem_int;
wire [43:0]                   araddrhostcpumem_int;
wire [39:0]                   periphbase_int;

assign periphbase_int = 40'h001C000000;


wire [63:0] tsvalueb_binary_tsintp;

wire [3:0]                    commrx_int;
wire [3:0]                    commtx_int;

wire [HOST_CPU_NUM_CORES-1:0] hostcpu_core_warmresetn;
wire [HOST_CPU_NUM_CORES-1:0] hostcpu_core_poresetn;
wire                          hostcpu_clustop_warmresetn;
wire                          hostcpu_clustop_poresetn;

arm_element_std_or2 u_mbistreq_core0poresetn   ( .A (MBISTREQ), .B (HOSTCPUPORESETn[0]), .Y (hostcpu_core_poresetn[0]));
arm_element_std_or2 u_mbistreq_core0warmresetn ( .A (MBISTREQ), .B (HOSTCPUWARMRESETn[0]), .Y (hostcpu_core_warmresetn[0]));
arm_element_std_or2 u_mbistreq_core1poresetn   ( .A (MBISTREQ), .B (HOSTCPUPORESETn[1]), .Y (hostcpu_core_poresetn[1]));
arm_element_std_or2 u_mbistreq_core1warmresetn ( .A (MBISTREQ), .B (HOSTCPUWARMRESETn[1]), .Y (hostcpu_core_warmresetn[1]));
arm_element_std_or2 u_mbistreq_core2poresetn   ( .A (MBISTREQ), .B (HOSTCPUPORESETn[2]), .Y (hostcpu_core_poresetn[2]));
arm_element_std_or2 u_mbistreq_core2warmresetn ( .A (MBISTREQ), .B (HOSTCPUWARMRESETn[2]), .Y (hostcpu_core_warmresetn[2]));
arm_element_std_or2 u_mbistreq_core3poresetn   ( .A (MBISTREQ), .B (HOSTCPUPORESETn[3]), .Y (hostcpu_core_poresetn[3]));
arm_element_std_or2 u_mbistreq_core3warmresetn ( .A (MBISTREQ), .B (HOSTCPUWARMRESETn[3]), .Y (hostcpu_core_warmresetn[3]));
arm_element_std_or2 u_mbistreq_cluswarmresetn  ( .A (MBISTREQ), .B (HOSTCLUSTOPWARMRESETn), .Y (hostcpu_clustop_warmresetn));
arm_element_std_or2 u_mbistreq_clusporesetn    ( .A (MBISTREQ), .B (HOSTCLUSTOPPORESETn), .Y (hostcpu_clustop_poresetn));


wire paddrhostcpudbg31;
assign paddrhostcpudbg31 = ~PADDRHOSTCPUDBG[24];

reg mbist_enable;
wire l2rstdisable_int;

always @(posedge HOSTCPUCLKOUT or negedge hostcpu_clustop_poresetn)
begin
  if (~hostcpu_clustop_poresetn)
  begin
    mbist_enable <= 1'b0;
  end
  else
  begin
    mbist_enable <= MBISTREQ;
  end
end

arm_element_cdc_comb_mux2 #(.WIDTH (1))
u_l2rstdisable_mux (
  .din1_async (L2RSTDISABLE),
  .din2_async (1'b0),
  .sel        (mbist_enable),

  .dout_async (l2rstdisable_int)
);


wire [63:0] cntvalueb;

gray_decode_async u_gray_decode(
  .clk          (HOSTCPUCLKOUT),
  .nreset       (HOSTCLUSTOPWARMRESETn),

  .gray_count   (HOSTCNTVALUEG),
  .binary_count (cntvalueb)
);




generate 
if (1)
begin:cortexa53_inst
CORTEXA53 u_cortex_a53 (

.CLKIN  (HOSTCPUCLKOUT),
.nCPUPORESET  (hostcpu_core_poresetn),
.nCORERESET  (hostcpu_core_warmresetn),
.WARMRSTREQ  (WARMRSTREQ),
.nL2RESET  (hostcpu_clustop_warmresetn),
.L2RSTDISABLE  (l2rstdisable_int),
                 
.CFGEND  (cfgend_ss[HOST_CPU_NUM_CORES-1:0]),
.VINITHI  (vinithi_ss[HOST_CPU_NUM_CORES-1:0]),
.CFGTE  (cfgte_ss[HOST_CPU_NUM_CORES-1:0]),
.CP15SDISABLE  (cp15sdisable_ss[HOST_CPU_NUM_CORES-1:0]),
.CLUSTERIDAFF1  (8'h00),
.CLUSTERIDAFF2  (8'h00),
.AA64nAA32(aa64naa32_ss), 

.RVBARADDR0(rvbaraddr0_ss),
.RVBARADDR1(rvbaraddr1_ss),
.RVBARADDR2(rvbaraddr2_ss),
.RVBARADDR3(rvbaraddr3_ss),

 
  .CRYPTODISABLE ({4{cryptodisable_ss}}),
   
                 
.nFIQ  (nfiqcpu_ss),
.nIRQ  (nirqcpu_ss),
.nSEI  ({(HOST_CPU_NUM_CORES){1'b1}}),
.nVFIQ  (nvfiqcpu_ss),
.nVIRQ  (nvirqcpu_ss),
.nVSEI  ({(HOST_CPU_NUM_CORES){1'b1}}),
.nREI  ({(HOST_CPU_NUM_CORES){1'b1}}),
.nVCPUMNTIRQ(), 
.PERIPHBASE(periphbase_int[39:18]),
.GICCDISABLE(1'b1),
.ICDTVALID(1'b0),
.ICDTREADY(     ),
.ICDTDATA(16'h0000),
.ICDTLAST(1'b0),
.ICDTDEST(2'b00),
.ICCTVALID(     ),
.ICCTREADY(1'b0),
.ICCTDATA(     ),
.ICCTLAST(     ),
.ICCTID(     ),
                 
.CNTVALUEB  (cntvalueb),
.CNTCLKEN  (1'b1), 
                 
.nCNTPNSIRQ  (ncntpnsirq_int[HOST_CPU_NUM_CORES-1:0]),
.nCNTPSIRQ  (ncntpsirq_int[HOST_CPU_NUM_CORES-1:0]),
.nCNTVIRQ  (ncntvirq_int[HOST_CPU_NUM_CORES-1:0]),
.nCNTHPIRQ  (ncnthpirq_int[HOST_CPU_NUM_CORES-1:0]),
                 
.CLREXMONREQ  (1'b0), 
.CLREXMONACK  ( ), 
.EVENTI  (1'b0),
.EVENTO  ( ),
.STANDBYWFI  (STANDBYWFI[HOST_CPU_NUM_CORES-1:0]),
.STANDBYWFE  ( ),
.STANDBYWFIL2  (STANDBYWFIL2),
 
.L2FLUSHREQ  (L2FLUSHREQ), 
.L2FLUSHDONE  (L2FLUSHDONE),
 
.SMPEN  (SMPEN[HOST_CPU_NUM_CORES-1:0]),

.CPUQACTIVE  (CPUQACTIVE[HOST_CPU_NUM_CORES-1:0]),
.CPUQREQn  (CPUQREQn[HOST_CPU_NUM_CORES-1:0]),
.CPUQDENY  (CPUQDENY[HOST_CPU_NUM_CORES-1:0]), 
.CPUQACCEPTn  (CPUQACCEPTn[HOST_CPU_NUM_CORES-1:0]),

 
.NEONQACTIVE    (),
.NEONQREQn      ({HOST_CPU_NUM_CORES{1'b1}}), 
.NEONQDENY      (),
.NEONQACCEPTn   (),
 

 
.L2QACTIVE   (L2QACTIVE),
.L2QREQn     (l2qreqn_ss),
.L2QDENY     (L2QDENY),
.L2QACCEPTn  (L2QACCEPTn),
 

 
.nINTERRIRQ  (ninterrirq_int),
 
.nEXTERRIRQ  (nexterrirq_int),
.BROADCASTCACHEMAINT(1'b0),
.BROADCASTINNER(1'b0),
.BROADCASTOUTER(1'b0),
.SYSBARDISABLE(1'b1),
                 
.ACLKENM  (1'b1),
.ACINACTM (1'b1),
.RDMEMATTR  ( ), 
.WRMEMATTR  ( ),

.AWREADYM (AWREADYHOSTCPUMEM),
.AWVALIDM (AWVALIDHOSTCPUMEM),
.AWIDM    (AWIDHOSTCPUMEM),
.AWADDRM  (awaddrhostcpumem_int),
.AWLENM   (AWLENHOSTCPUMEM),
.AWSIZEM  (AWSIZEHOSTCPUMEM),
.AWBURSTM (AWBURSTHOSTCPUMEM),
.AWBARM    ( ),
.AWDOMAINM ( ),

.AWLOCKM  (AWLOCKHOSTCPUMEM),
.AWCACHEM (AWCACHEHOSTCPUMEM),
.AWPROTM  (AWPROTHOSTCPUMEM),
.AWSNOOPM  ( ),
.AWUNIQUEM ( ),

.WREADYM  (WREADYHOSTCPUMEM),
.WVALIDM  (WVALIDHOSTCPUMEM),
.WIDM     (WIDHOSTCPUMEM),
.WDATAM   (WDATAHOSTCPUMEM),
.WSTRBM   (WSTRBHOSTCPUMEM),
.WLASTM   (WLASTHOSTCPUMEM),
                 
.BREADYM  (BREADYHOSTCPUMEM),
.BVALIDM  (BVALIDHOSTCPUMEM),
.BIDM     (BIDHOSTCPUMEM),
.BRESPM   (BRESPHOSTCPUMEM),
                 
.ARREADYM (ARREADYHOSTCPUMEM),
.ARVALIDM (ARVALIDHOSTCPUMEM),
.ARIDM    (ARIDHOSTCPUMEM),
.ARADDRM  (araddrhostcpumem_int),
.ARLENM   (ARLENHOSTCPUMEM),
.ARSIZEM  (ARSIZEHOSTCPUMEM),
.ARBURSTM (ARBURSTHOSTCPUMEM),
.ARBARM   ( ),
.ARDOMAINM( ),

.ARLOCKM  (ARLOCKHOSTCPUMEM),
.ARCACHEM (ARCACHEHOSTCPUMEM),
.ARPROTM  (ARPROTHOSTCPUMEM),
.ARSNOOPM (),

.RREADYM  (RREADYHOSTCPUMEM),
.RVALIDM  (RVALIDHOSTCPUMEM),
.RIDM     (RIDHOSTCPUMEM),
.RDATAM   (RDATAHOSTCPUMEM),
.RLASTM   (RLASTHOSTCPUMEM),
.RRESPM   ({2'b00 , RRESPHOSTCPUMEM[1:0]}),

.ACREADYM(),
.ACVALIDM(1'b0),
.ACADDRM(44'h0),
.ACPROTM(3'b000),
.ACSNOOPM(4'h0),

.CRREADYM(1'b0),
.CRVALIDM(),
.CRRESPM(),

.CDREADYM(1'b0),
.CDVALIDM(),
.CDDATAM(),
.CDLASTM(),

.RACKM(),
.WACKM(),

.nPRESETDBG  (hostcpu_clustop_poresetn),
.PCLKENDBG  (1'b1),
.PSELDBG  (PSELHOSTCPUDBG),
.PADDRDBG  (PADDRHOSTCPUDBG[21:2]),
.PADDRDBG31  (paddrhostcpudbg31),
.PENABLEDBG  (PENABLEHOSTCPUDBG),
.PWRITEDBG  (PWRITEHOSTCPUDBG),
.PWDATADBG  (PWDATAHOSTCPUDBG),
.PRDATADBG  (PRDATAHOSTCPUDBG),
.PREADYDBG  (PREADYHOSTCPUDBG),
.PSLVERRDBG  (PSLVERRHOSTCPUDBG),

.DBGROMADDR  (28'h000_0000),
.DBGROMADDRV  (1'b1),
.DBGACK  ( ),
.nCOMMIRQ  (ncommirq_int[HOST_CPU_NUM_CORES-1:0]),
.COMMRX  (commrx_int[HOST_CPU_NUM_CORES-1:0]),
.COMMTX  (commtx_int[HOST_CPU_NUM_CORES-1:0]),
.EDBGRQ  ({HOST_CPU_NUM_CORES{1'b0}}),
.DBGEN  (HOSTCPUDBGAUTHDBGEN[HOST_CPU_NUM_CORES-1:0]),
.NIDEN  (HOSTCPUDBGAUTHNIDEN[HOST_CPU_NUM_CORES-1:0]),
.SPIDEN  (HOSTCPUDBGAUTHSPIDEN[HOST_CPU_NUM_CORES-1:0]),
.SPNIDEN  (HOSTCPUDBGAUTHSPNIDEN[HOST_CPU_NUM_CORES-1:0]),
.DBGRSTREQ  (DBGRSTREQ[HOST_CPU_NUM_CORES-1:0]),
.DBGNOPWRDWN  (DBGNOPWRDWN[HOST_CPU_NUM_CORES-1:0]),
.DBGPWRDUP  (dbgpwrdup_ss[HOST_CPU_NUM_CORES-1:0]),
.DBGPWRUPREQ  (DBGPWRUPREQ[HOST_CPU_NUM_CORES-1:0]),
.DBGL1RSTDISABLE  (1'b0),
                 
.ATCLKEN    (1'b1),
.SYNCREQM0  (syncreq[0]),
.ATREADYM0  (atreadym[0]),
.AFVALIDM0  (afvalidm[0]),
.ATDATAM0   (atdatam[31:0]),
.ATVALIDM0  (atvalidm[0]),
.ATBYTESM0  (atbytesm[1:0]),
.AFREADYM0  (afreadym[0]),
.ATIDM0     (atidm[6:0]),

.SYNCREQM1  (syncreq[1]),
.ATREADYM1  (atreadym[1]),
.AFVALIDM1  (afvalidm[1]),
.ATDATAM1   (atdatam[63:32]),
.ATVALIDM1  (atvalidm[1]),
.ATBYTESM1  (atbytesm[3:2]),
.AFREADYM1  (afreadym[1]),
.ATIDM1     (atidm[13:7]),
.SYNCREQM2  (syncreq[2]),
.ATREADYM2  (atreadym[2]),
.AFVALIDM2  (afvalidm[2]),
.ATDATAM2   (atdatam[95:64]),
.ATVALIDM2  (atvalidm[2]),
.ATBYTESM2  (atbytesm[5:4]),
.AFREADYM2  (afreadym[2]),
.ATIDM2     (atidm[20:14]),
.SYNCREQM3  (syncreq[3]),
.ATREADYM3  (atreadym[3]),
.AFVALIDM3  (afvalidm[3]),
.ATDATAM3   (atdatam[127:96]),
.ATVALIDM3  (atvalidm[3]),
.ATBYTESM3  (atbytesm[7:6]),
.AFREADYM3  (afreadym[3]),
.ATIDM3     (atidm[27:21]),

.TSVALUEB  (tsvalueb_binary_tsintp),
                 
.CTICHIN     (CTICHIN),
.CTICHOUTACK (CTICHOUTACK),
.CTICHOUT    (CTICHOUT),
.CTICHINACK  (CTICHINACK),
.CISBYPASS   (1'b0),
.CIHSBYPASS  (4'h0),
                 
.CTIIRQ  (ctiirq_int[HOST_CPU_NUM_CORES-1:0]),
.CTIIRQACK  (ctiirq_int_ack[HOST_CPU_NUM_CORES-1:0]),
.nPMUIRQ  (npmuirq_int[HOST_CPU_NUM_CORES-1:0]),

.PMUEVENT0  ( ),
.PMUEVENT1  ( ),
.PMUEVENT2  ( ),
.PMUEVENT3  ( ),
                 
.DFTSE  (DFTCGEN),
.DFTRSTDISABLE  (DFTRSTDISABLE),
.DFTRAMHOLD  (DFTRAMHOLD),
.DFTMCPHOLD  (DFTMCPHOLD), 
.MBISTREQ  (mbist_enable),
.nMBISTRESET  (nMBISTRESET)
);
end
endgenerate


wire [NUM_SPIS-1:0]  irqs_internal;

 
assign irqs_internal[NUM_SPIS-1:96]  = {{NUM_SPIS-(96+NUM_EXP_SHD_INT-11){1'b0}}, GICSHDINT[42+NUM_EXP_SHD_INT-11:43]};
 

assign irqs_internal[95:74] = 22'h0;
assign irqs_internal[73]    = 1'b0;
 
assign irqs_internal[72]    = ctiirq_int[3];
assign irqs_internal[71]    = ~npmuirq_int[3];
assign irqs_internal[70]    = 1'b0;
assign irqs_internal[69]    = ~ncommirq_int[3];
assign irqs_internal[68]    = 1'b0;
 
assign irqs_internal[67]    = ctiirq_int[2];
assign irqs_internal[66]    = ~npmuirq_int[2];
assign irqs_internal[65]    = 1'b0;
assign irqs_internal[64]    = ~ncommirq_int[2];
assign irqs_internal[63]    = 1'b0;
 
assign irqs_internal[62]    = ctiirq_int[1];
assign irqs_internal[61]    = ~npmuirq_int[1];
assign irqs_internal[60]    = 1'b0;
assign irqs_internal[59]    = ~ncommirq_int[1];
assign irqs_internal[58]    = 1'b0;
 
assign irqs_internal[57]    = ctiirq_int[0];
assign irqs_internal[56]    = ~npmuirq_int[0];
assign irqs_internal[55]    = 1'b0;
assign irqs_internal[54]    = ~ncommirq_int[0];
assign irqs_internal[53:44] = GICINTMHUNS;
assign irqs_internal[43:42] = GICSHDINT[10:9];
assign irqs_internal[41:37] = GICINTDBGTOP;
assign irqs_internal[36]    = GICSHDINT[8];
assign irqs_internal[35:33] = GICSHDINT[6:4];
assign irqs_internal[32]    = GICINTWDOGNS;
assign irqs_internal[31:21] =  GICSHDINT[42:32] ;
assign irqs_internal[20:19] = GICINTUART;
assign irqs_internal[18:9]  = GICINTMHUS;
 
assign irqs_internal[8]     = ~ninterrirq_int;
 
assign irqs_internal[7]     = ~nexterrirq_int;
assign irqs_internal[6]     = GICSHDINT[1];
assign irqs_internal[5]     = GICSHDINT[2];
assign irqs_internal[4]     = GICSHDINT[0];
assign irqs_internal[3]     = GICSHDINT[7];
assign irqs_internal[2]     = GICSHDINT[3];
assign irqs_internal[1:0]   = GICINTWDOGS;

  generate
    genvar j;
    for (j=0; j<NUM_SPIS; j=j+1)
    begin: IRQS_SS_GEN
      if (((j>(96+NUM_EXP_SHD_INT-12)) & (j<NUM_SPIS)) | ((j>72)  & (j<96)) | (j==73) | (j==70) | (j==68) | (j==65) | (j==63) | (j==60) | (j==58) | (j==55) | (j==41) | (j==40) | (j==37))
      begin: GEN_IRQS_NO_SYNC
        assign irqs_ss[j] = irqs_internal[j];
      end
      else
      begin: GEN_IRQS_SYNC
        arm_element_cdc_capt_sync u_cdc_capt_sync_intr0 (
          .clk        (GICCLKOUT),
          .nreset     (GICRESETn),

          .d_async    (irqs_internal[j]),
          .q          (irqs_ss[j])
        );
      end
    end
  endgenerate

  generate
    genvar i;
    for(i=0; i<HOST_CPU_NUM_CORES; i=i+1) 
    begin: GEN_INTR_SYNC
      arm_element_cdc_capt_sync u_cdc_capt_sync_intr0 (
        .clk        (HOSTCPUCLKOUT),
        .nreset     (HOSTCLUSTOPWARMRESETn),

        .d_async    (nirqcpu_int[i]),
        .q          (nirqcpu_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr1 (
        .clk        (HOSTCPUCLKOUT),
        .nreset     (HOSTCLUSTOPWARMRESETn),

        .d_async    (nfiqcpu_int[i]),
        .q          (nfiqcpu_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr2 (
        .clk        (HOSTCPUCLKOUT),
        .nreset     (HOSTCLUSTOPWARMRESETn),

        .d_async    (nvirqcpu_int[i]),
        .q          (nvirqcpu_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr3 (
        .clk        (HOSTCPUCLKOUT),
        .nreset     (HOSTCLUSTOPWARMRESETn),

        .d_async    (nvfiqcpu_int[i]),
        .q          (nvfiqcpu_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr4 (
        .clk        (GICCLKOUT),
        .nreset     (GICRESETn),

        .d_async    (ncntpsirq_int[i]),
        .q          (ncntpsirq_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr5 (
        .clk        (GICCLKOUT),
        .nreset     (GICRESETn),

        .d_async    (ncntpnsirq_int[i]),
        .q          (ncntpnsirq_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr6 (
        .clk        (GICCLKOUT),
        .nreset     (GICRESETn),

        .d_async    (ncntvirq_int[i]),
        .q          (ncntvirq_ss[i])
      );

      arm_element_cdc_capt_sync u_cdc_capt_sync_intr7 (
        .clk        (GICCLKOUT),
        .nreset     (GICRESETn),

        .d_async    (ncnthpirq_int[i]),
        .q          (ncnthpirq_ss[i])
      );

    arm_element_cdc_capt_sync u_cdc_capt_sync_dbgpwrdup (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (DBGPWRDUP[i]),
      .q          (dbgpwrdup_ss[i])
    );

    arm_element_cdc_capt_sync u_cdc_capt_sync_cfgte (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (CFGTE[i]),
      .q          (cfgte_ss[i])
    );

    arm_element_cdc_capt_sync u_cdc_capt_sync_cfgend (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (CFGEND[i]),
      .q          (cfgend_ss[i])
    );

    arm_element_cdc_capt_sync u_cdc_capt_sync_vinithi (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (VINITHI[i]),
      .q          (vinithi_ss[i])
    );

    arm_element_cdc_capt_sync u_cdc_capt_sync_cp15sdisable (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (CP15SDISABLE[i]),
      .q          (cp15sdisable_ss[i])
    );

 
   arm_element_cdc_capt_sync u_cdc_capt_sync_aa64naa32 (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),
      .d_async    (AA64nAA32[i]),
      .q          (aa64naa32_ss[i])
    );
 
    
    end
  endgenerate
  
 
   
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_2 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[2]),
     .q          (rvbaraddr0_ss[2])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_3 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[3]),
     .q          (rvbaraddr0_ss[3])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_4 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[4]),
     .q          (rvbaraddr0_ss[4])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_5 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[5]),
     .q          (rvbaraddr0_ss[5])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_6 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[6]),
     .q          (rvbaraddr0_ss[6])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_7 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[7]),
     .q          (rvbaraddr0_ss[7])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_8 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[8]),
     .q          (rvbaraddr0_ss[8])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_9 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[9]),
     .q          (rvbaraddr0_ss[9])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_10 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[10]),
     .q          (rvbaraddr0_ss[10])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_11 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[11]),
     .q          (rvbaraddr0_ss[11])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_12 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[12]),
     .q          (rvbaraddr0_ss[12])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_13 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[13]),
     .q          (rvbaraddr0_ss[13])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_14 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[14]),
     .q          (rvbaraddr0_ss[14])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_15 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[15]),
     .q          (rvbaraddr0_ss[15])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_16 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[16]),
     .q          (rvbaraddr0_ss[16])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_17 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[17]),
     .q          (rvbaraddr0_ss[17])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_18 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[18]),
     .q          (rvbaraddr0_ss[18])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_19 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[19]),
     .q          (rvbaraddr0_ss[19])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_20 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[20]),
     .q          (rvbaraddr0_ss[20])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_21 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[21]),
     .q          (rvbaraddr0_ss[21])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_22 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[22]),
     .q          (rvbaraddr0_ss[22])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_23 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[23]),
     .q          (rvbaraddr0_ss[23])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_24 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[24]),
     .q          (rvbaraddr0_ss[24])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_25 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[25]),
     .q          (rvbaraddr0_ss[25])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_26 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[26]),
     .q          (rvbaraddr0_ss[26])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_27 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[27]),
     .q          (rvbaraddr0_ss[27])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_28 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[28]),
     .q          (rvbaraddr0_ss[28])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_29 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[29]),
     .q          (rvbaraddr0_ss[29])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_30 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[30]),
     .q          (rvbaraddr0_ss[30])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_31 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[31]),
     .q          (rvbaraddr0_ss[31])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_32 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[32]),
     .q          (rvbaraddr0_ss[32])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_33 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[33]),
     .q          (rvbaraddr0_ss[33])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_34 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[34]),
     .q          (rvbaraddr0_ss[34])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_35 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[35]),
     .q          (rvbaraddr0_ss[35])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_36 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[36]),
     .q          (rvbaraddr0_ss[36])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_37 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[37]),
     .q          (rvbaraddr0_ss[37])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_38 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[38]),
     .q          (rvbaraddr0_ss[38])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr0_39 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR0[39]),
     .q          (rvbaraddr0_ss[39])
   );
       
   
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_2 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[2]),
     .q          (rvbaraddr1_ss[2])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_3 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[3]),
     .q          (rvbaraddr1_ss[3])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_4 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[4]),
     .q          (rvbaraddr1_ss[4])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_5 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[5]),
     .q          (rvbaraddr1_ss[5])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_6 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[6]),
     .q          (rvbaraddr1_ss[6])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_7 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[7]),
     .q          (rvbaraddr1_ss[7])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_8 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[8]),
     .q          (rvbaraddr1_ss[8])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_9 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[9]),
     .q          (rvbaraddr1_ss[9])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_10 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[10]),
     .q          (rvbaraddr1_ss[10])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_11 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[11]),
     .q          (rvbaraddr1_ss[11])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_12 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[12]),
     .q          (rvbaraddr1_ss[12])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_13 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[13]),
     .q          (rvbaraddr1_ss[13])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_14 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[14]),
     .q          (rvbaraddr1_ss[14])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_15 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[15]),
     .q          (rvbaraddr1_ss[15])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_16 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[16]),
     .q          (rvbaraddr1_ss[16])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_17 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[17]),
     .q          (rvbaraddr1_ss[17])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_18 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[18]),
     .q          (rvbaraddr1_ss[18])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_19 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[19]),
     .q          (rvbaraddr1_ss[19])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_20 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[20]),
     .q          (rvbaraddr1_ss[20])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_21 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[21]),
     .q          (rvbaraddr1_ss[21])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_22 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[22]),
     .q          (rvbaraddr1_ss[22])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_23 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[23]),
     .q          (rvbaraddr1_ss[23])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_24 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[24]),
     .q          (rvbaraddr1_ss[24])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_25 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[25]),
     .q          (rvbaraddr1_ss[25])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_26 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[26]),
     .q          (rvbaraddr1_ss[26])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_27 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[27]),
     .q          (rvbaraddr1_ss[27])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_28 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[28]),
     .q          (rvbaraddr1_ss[28])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_29 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[29]),
     .q          (rvbaraddr1_ss[29])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_30 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[30]),
     .q          (rvbaraddr1_ss[30])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_31 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[31]),
     .q          (rvbaraddr1_ss[31])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_32 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[32]),
     .q          (rvbaraddr1_ss[32])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_33 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[33]),
     .q          (rvbaraddr1_ss[33])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_34 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[34]),
     .q          (rvbaraddr1_ss[34])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_35 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[35]),
     .q          (rvbaraddr1_ss[35])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_36 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[36]),
     .q          (rvbaraddr1_ss[36])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_37 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[37]),
     .q          (rvbaraddr1_ss[37])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_38 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[38]),
     .q          (rvbaraddr1_ss[38])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr1_39 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR1[39]),
     .q          (rvbaraddr1_ss[39])
   );
       
   
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_2 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[2]),
     .q          (rvbaraddr2_ss[2])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_3 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[3]),
     .q          (rvbaraddr2_ss[3])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_4 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[4]),
     .q          (rvbaraddr2_ss[4])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_5 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[5]),
     .q          (rvbaraddr2_ss[5])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_6 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[6]),
     .q          (rvbaraddr2_ss[6])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_7 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[7]),
     .q          (rvbaraddr2_ss[7])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_8 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[8]),
     .q          (rvbaraddr2_ss[8])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_9 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[9]),
     .q          (rvbaraddr2_ss[9])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_10 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[10]),
     .q          (rvbaraddr2_ss[10])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_11 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[11]),
     .q          (rvbaraddr2_ss[11])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_12 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[12]),
     .q          (rvbaraddr2_ss[12])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_13 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[13]),
     .q          (rvbaraddr2_ss[13])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_14 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[14]),
     .q          (rvbaraddr2_ss[14])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_15 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[15]),
     .q          (rvbaraddr2_ss[15])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_16 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[16]),
     .q          (rvbaraddr2_ss[16])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_17 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[17]),
     .q          (rvbaraddr2_ss[17])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_18 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[18]),
     .q          (rvbaraddr2_ss[18])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_19 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[19]),
     .q          (rvbaraddr2_ss[19])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_20 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[20]),
     .q          (rvbaraddr2_ss[20])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_21 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[21]),
     .q          (rvbaraddr2_ss[21])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_22 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[22]),
     .q          (rvbaraddr2_ss[22])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_23 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[23]),
     .q          (rvbaraddr2_ss[23])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_24 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[24]),
     .q          (rvbaraddr2_ss[24])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_25 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[25]),
     .q          (rvbaraddr2_ss[25])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_26 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[26]),
     .q          (rvbaraddr2_ss[26])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_27 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[27]),
     .q          (rvbaraddr2_ss[27])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_28 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[28]),
     .q          (rvbaraddr2_ss[28])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_29 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[29]),
     .q          (rvbaraddr2_ss[29])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_30 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[30]),
     .q          (rvbaraddr2_ss[30])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_31 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[31]),
     .q          (rvbaraddr2_ss[31])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_32 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[32]),
     .q          (rvbaraddr2_ss[32])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_33 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[33]),
     .q          (rvbaraddr2_ss[33])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_34 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[34]),
     .q          (rvbaraddr2_ss[34])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_35 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[35]),
     .q          (rvbaraddr2_ss[35])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_36 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[36]),
     .q          (rvbaraddr2_ss[36])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_37 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[37]),
     .q          (rvbaraddr2_ss[37])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_38 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[38]),
     .q          (rvbaraddr2_ss[38])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr2_39 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR2[39]),
     .q          (rvbaraddr2_ss[39])
   );
       
   
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_2 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[2]),
     .q          (rvbaraddr3_ss[2])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_3 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[3]),
     .q          (rvbaraddr3_ss[3])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_4 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[4]),
     .q          (rvbaraddr3_ss[4])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_5 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[5]),
     .q          (rvbaraddr3_ss[5])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_6 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[6]),
     .q          (rvbaraddr3_ss[6])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_7 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[7]),
     .q          (rvbaraddr3_ss[7])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_8 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[8]),
     .q          (rvbaraddr3_ss[8])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_9 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[9]),
     .q          (rvbaraddr3_ss[9])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_10 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[10]),
     .q          (rvbaraddr3_ss[10])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_11 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[11]),
     .q          (rvbaraddr3_ss[11])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_12 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[12]),
     .q          (rvbaraddr3_ss[12])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_13 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[13]),
     .q          (rvbaraddr3_ss[13])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_14 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[14]),
     .q          (rvbaraddr3_ss[14])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_15 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[15]),
     .q          (rvbaraddr3_ss[15])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_16 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[16]),
     .q          (rvbaraddr3_ss[16])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_17 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[17]),
     .q          (rvbaraddr3_ss[17])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_18 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[18]),
     .q          (rvbaraddr3_ss[18])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_19 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[19]),
     .q          (rvbaraddr3_ss[19])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_20 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[20]),
     .q          (rvbaraddr3_ss[20])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_21 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[21]),
     .q          (rvbaraddr3_ss[21])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_22 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[22]),
     .q          (rvbaraddr3_ss[22])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_23 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[23]),
     .q          (rvbaraddr3_ss[23])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_24 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[24]),
     .q          (rvbaraddr3_ss[24])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_25 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[25]),
     .q          (rvbaraddr3_ss[25])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_26 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[26]),
     .q          (rvbaraddr3_ss[26])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_27 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[27]),
     .q          (rvbaraddr3_ss[27])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_28 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[28]),
     .q          (rvbaraddr3_ss[28])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_29 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[29]),
     .q          (rvbaraddr3_ss[29])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_30 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[30]),
     .q          (rvbaraddr3_ss[30])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_31 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[31]),
     .q          (rvbaraddr3_ss[31])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_32 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[32]),
     .q          (rvbaraddr3_ss[32])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_33 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[33]),
     .q          (rvbaraddr3_ss[33])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_34 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[34]),
     .q          (rvbaraddr3_ss[34])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_35 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[35]),
     .q          (rvbaraddr3_ss[35])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_36 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[36]),
     .q          (rvbaraddr3_ss[36])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_37 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[37]),
     .q          (rvbaraddr3_ss[37])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_38 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[38]),
     .q          (rvbaraddr3_ss[38])
   );
      
  arm_element_cdc_capt_sync u_cdc_capt_sync_rvbaraddr3_39 (
     .clk        (HOSTCPUCLKOUT),
     .nreset     (HOSTCLUSTOPPORESETn),
     .d_async    (RVBARADDR3[39]),
     .q          (rvbaraddr3_ss[39])
   );
       
     
   

 
   arm_element_cdc_capt_sync u_cdc_capt_sync_cryptodisable (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),
      .d_async    (CRYPTODISABLE),
      .q          (cryptodisable_ss)
    );
   

 
    arm_element_cdc_capt_sync u_cdc_capt_sync_l2qreqn (
      .clk        (HOSTCPUCLKOUT),
      .nreset     (HOSTCLUSTOPPORESETn),

      .d_async    (L2QREQn),
      .q          (l2qreqn_ss)
    );
 

    arm_element_cdc_capt_sync u_cdc_capt_sync_cfgsdisable (
      .clk        (GICCLKOUT),
      .nreset     (GICRESETn),

      .d_async    (CFGSDISABLE),
      .q          (cfgsdisable_ss)
    );

assign ctiirq_int_ack[0] = irqs_ss[57];
assign ctiirq_int_ack[1] = irqs_ss[62];
assign ctiirq_int_ack[2] = irqs_ss[67];
assign ctiirq_int_ack[3] = irqs_ss[72];



GIC400 #(
.NUM_CPUS(HOST_CPU_NUM_CORES),
.NUM_SPIS(NUM_SPIS),
.NUM_WID_BITS(NUM_GICWID_BITS),
.NUM_RID_BITS(NUM_GICRID_BITS)
) u_gic400 (
.CLK(GICCLKOUT),
.nRESET(GICRESETn),
.DFTRSTDISABLE(DFTRSTDISABLE),
.DFTSE(DFTCGEN),
.CFGSDISABLE(cfgsdisable_ss),    
.ARID       (ARIDGICM),
.ARADDR     ({ARADDRGICM[18:16],ARADDRGICM[11:0]}),
.ARLEN      (ARLENGICM),
.ARSIZE     (ARSIZEGICM),
.ARBURST    (ARBURSTGICM),
.ARPROT     (ARPROTGICM),
.ARUSER     ({1'b0,ARUSERGICM[1:0]}),
.ARVALID    (ARVALIDGICM),
.ARREADY    (ARREADYGICM),
.RID        (RIDGICM),
.RDATA      (RDATAGICM),
.RLAST      (RLASTGICM),
.RRESP      (RRESPGICM),
.RVALID     (RVALIDGICM),
.RREADY     (RREADYGICM),
.AWID       (AWIDGICM),
.AWADDR     ({AWADDRGICM[18:16],AWADDRGICM[11:0]}),
.AWLEN      (AWLENGICM),
.AWSIZE     (AWSIZEGICM),
.AWBURST    (AWBURSTGICM),
.AWPROT     (AWPROTGICM),
.AWUSER     ({1'b0,AWUSERGICM[1:0]}),
.AWVALID    (AWVALIDGICM),
.AWREADY    (AWREADYGICM),
.WDATA      (WDATAGICM),
.WSTRB      (WSTRBGICM),
.WVALID     (WVALIDGICM),
.WREADY     (WREADYGICM),
.BID        (BIDGICM),
.BRESP      (BRESPGICM),
.BVALID     (BVALIDGICM),
.BREADY     (BREADYGICM),
.IRQS(irqs_ss),
.nLEGACYFIQ({HOST_CPU_NUM_CORES{1'b1}}),  
.nLEGACYIRQ({HOST_CPU_NUM_CORES{1'b1}}),  
.nCNTPSIRQ(ncntpsirq_ss),   
.nCNTPNSIRQ(ncntpnsirq_ss),  
.nCNTVIRQ(ncntvirq_ss),    
.nCNTHPIRQ(ncnthpirq_ss),   
.nIRQCPU(nirqcpu_int),
.nFIQCPU(nfiqcpu_int),
.nVIRQCPU(nvirqcpu_int),
.nVFIQCPU(nvfiqcpu_int),
.nIRQOUT(nirqout),
.nFIQOUT(nfiqout)
);


wire [27:0]  atidm_int;
wire [127:0] atdatam_int;
wire [7:0]   atbytesm_int;

generate
genvar I;
if ((HOST_CPU_TYPE == 1) || (HOST_CPU_TYPE == 2) || (HOST_CPU_TYPE == 3))
begin:atb_reset_value_logic
for (I=0; I<HOST_CPU_NUM_CORES; I=I+1)
begin:per_core
arm_element_cdc_comb_mux2 #(.WIDTH (7))
u_atidm_mux (
  .din1_async (7'h00),
  .din2_async (atidm[7*I+:7]),
  .sel        (atvalidm[I]),

  .dout_async (atidm_int[7*I+:7])
);

arm_element_cdc_comb_mux2 #(.WIDTH (32))
u_atdatam_mux (
  .din1_async (32'h0000_0000),
  .din2_async (atdatam[32*I+:32]),
  .sel        (atvalidm[I]),

  .dout_async (atdatam_int[32*I+:32])
);

arm_element_cdc_comb_mux2 #(.WIDTH (2))
u_atbytesm_mux (
  .din1_async (2'b00),
  .din2_async (atbytesm[2*I+:2]),
  .sel        (atvalidm[I]),

  .dout_async (atbytesm_int[2*I+:2])
);
end
end
endgenerate

wire [31:0] atdata_s;
wire [1:0] atbytes_s;

generate
if (HOST_CPU_NUM_CORES == 1)
begin:atb_funnel_gen
assign atreadym[0] = ATREADYHOSTCPUTRACE;
assign afvalidm[0] = AFVALIDHOSTCPUTRACE;
assign syncreq[0] = SYNCREQHOSTCPUTRACE;
assign ATVALIDHOSTCPUTRACE = atvalidm[0];
assign AFREADYHOSTCPUTRACE = afreadym[0];
assign ATIDHOSTCPUTRACE = atidm_int[6:0];
assign ATDATAHOSTCPUTRACE = atdatam_int[31:0];
assign ATBYTESHOSTCPUTRACE = atbytesm_int[1:0];
assign ATWAKEUPHOSTCPUTRACE = atvalidm[0];
end
else if (HOST_CPU_NUM_CORES > 1)
begin:atb_funnel_gen_1
css600_atbfunnel #(
.ATB_DATA_WIDTH(32),
.NUM_ATB_SLAVES(HOST_CPU_NUM_CORES)
) u_atbfunnel_cores (
.clk(HOSTCPUCLKOUT),
.reset_n(HOSTCLUSTOPWARMRESETn),

.atwakeup_s({HOST_CPU_NUM_CORES{1'b0}}),
.atvalid_s(atvalidm[HOST_CPU_NUM_CORES-1:0]),
.afready_s(afreadym[HOST_CPU_NUM_CORES-1:0]),
.atid_s(atidm_int[HOST_CPU_NUM_CORES*7-1:0]),
.atdata_s(atdatam_int[HOST_CPU_NUM_CORES*32-1:0]),
.atbytes_s(atbytesm_int[HOST_CPU_NUM_CORES*2-1:0]),
.atready_m(ATREADYHOSTCPUTRACE),
.afvalid_m(AFVALIDHOSTCPUTRACE),
.syncreq_m(SYNCREQHOSTCPUTRACE),
.atwakeup_m(ATWAKEUPHOSTCPUTRACE),
.atvalid_m(ATVALIDHOSTCPUTRACE),
.afready_m(AFREADYHOSTCPUTRACE),
.atid_m(ATIDHOSTCPUTRACE),
.atdata_m(atdata_s),
.atbytes_m(atbytes_s),

.atready_s(atreadym[HOST_CPU_NUM_CORES-1:0]),
.afvalid_s(afvalidm[HOST_CPU_NUM_CORES-1:0]),
.syncreq_s(syncreq[HOST_CPU_NUM_CORES-1:0]),

.clk_qactive( )
);

assign ATDATAHOSTCPUTRACE  = atdata_s;
assign ATBYTESHOSTCPUTRACE = atbytes_s;

end
endgenerate

wire resetn_refclk;
wire resetn_cpuclk;
wire [63:0] tsvalueb_gray;
wire [63:0] tsvalueb_binary;

arm_element_reset_sync u_tsvalue_refclk_resetn_sync (
  .clk             (REFCLK),            
  .resetn_async    (HOSTCLUSTOPWARMRESETn),
  .resetn_sync     (resetn_refclk),          

  .dftrstdisable   (DFTRSTDISABLE)  
);

arm_element_reset_sync u_tsvalue_cpuclk_resetn_sync (
  .clk             (HOSTCPUCLKOUT),            
  .resetn_async    (HOSTCLUSTOPWARMRESETn),
  .resetn_sync     (resetn_cpuclk),          

  .dftrstdisable   (DFTRSTDISABLE)  
);


gray_encode u_gray_encode_hostcpu(
  .clk         (REFCLK),
  .nreset      (resetn_refclk),

  .binary_count(TSVALUEB),
  .gray_count  (tsvalueb_gray)
);

gray_decode_async u_gray_decode_hostcpu(
  .clk (HOSTCPUCLKOUT),
  .nreset (resetn_cpuclk),

  .gray_count  (tsvalueb_gray),
  .binary_count (tsvalueb_binary)
);

css600_tsintp u_css600_tsintp_hostcpu(
  .clk (HOSTCPUCLKOUT),
  .reset_n (resetn_cpuclk),

  .tsvalue_b_s  (tsvalueb_binary),
  .tsvalue_b_m  (tsvalueb_binary_tsintp),

  .clk_qreq_n   (1'b1),
  .clk_qaccept_n()
);

wire  [HOST_CPU_NUM_CORES-1:0]  nwakeupreq;
arm_element_cdc_comb_and2 #(
  .WIDTH (HOST_CPU_NUM_CORES)
) u_wakeupreq_and2 (
  .din1_async  (nirqout),
  .din2_async  (nfiqout),

  .dout_async  (nwakeupreq)

);

generate
  genvar k;
  for(k=0; k<HOST_CPU_NUM_CORES; k=k+1)
  begin: GEN_WAKEUPREQ_INV
    arm_element_std_inverter u_wakeupreq_bit0_inv ( .inv_in (nwakeupreq[k]), .inv_out (wakeupreq_int[k]));
    arm_element_cdc_capt_sync u_cdc_capt_sync_wakeupreq (.clk (GICCLKOUT), .nreset (GICRESETn), .d_async (wakeupreq_int[k]), .q (WAKEUPREQ[k]));
  end
endgenerate


wire unused;

wire [2:0] unused_num_cpus;
 
 assign unused = (|AWADDRGICM[15:12]) |
                 (|ARADDRGICM[15:12]) |
                 (|PWAKEUPHOSTCPUDBG) |
                 (|unused_num_cpus)   |
                 (|{PADDRHOSTCPUDBG[31:25],PADDRHOSTCPUDBG[23:22],PADDRHOSTCPUDBG[1:0]}) |                  
                 (ARUSERGICM[2] | AWUSERGICM[2]) |
                 (|(GICSHDINT[31:11]));
                 


 wire unused_a53;
  
    assign unused_a53 = (|commrx_int   ) | 
                        (|commtx_int   ) | 
                        (|awaddrhostcpumem_int[43:40]) |
                        (|periphbase_int[17:0]) |
                        (|araddrhostcpumem_int[43:40]);

     assign AWADDRHOSTCPUMEM = awaddrhostcpumem_int[39:0];
     assign ARADDRHOSTCPUMEM = araddrhostcpumem_int[39:0];



 
assign unused_num_cpus = 3'b000;

 

endmodule

