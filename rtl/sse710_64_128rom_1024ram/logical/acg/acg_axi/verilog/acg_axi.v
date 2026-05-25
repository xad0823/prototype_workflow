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

module acg_axi
  #(parameter
      ERR_RESP_EN = 1'b0, 
      INACT_CD_CONFIG     = 3'b000, 
      ADDR_WIDTH          = 40,
      DATA_WIDTH          = 128,
      AWID_WIDTH          = 32'd8,
      ARID_WIDTH          = 32'd8,
      AWUSER_WIDTH        = 32'd4,
      WUSER_WIDTH         = 32'd4,
      BUSER_WIDTH         = 32'd4,
      ARUSER_WIDTH        = 32'd4,
      RUSER_WIDTH         = 32'd4,
      AW_CNTR_SIZE        = 8,
      W_CNTR_SIZE         = 8,
      AR_CNTR_SIZE        = 8
  )
  (

    input  wire         ACLK,
    input  wire         ARESETn,

    input  wire         PWRQREQn,
    output wire         PWRQACCEPTn,
    output wire         PWRQDENY,
    output wire         PWRQACTIVE,


    input  wire         CLKQREQn,
    output wire         CLKQACCEPTn,
    output wire         CLKQDENY,
    output wire         CLKQACTIVE,

    output wire         INACT, 

    input  wire                      AWVALIDS,
    output wire                      AWREADYS,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] AWIDS,
    input  wire [ADDR_WIDTH-1:0]     AWADDRS,
    input  wire [3:0]                AWREGIONS,
    input  wire [7:0]                AWLENS,
    input  wire [2:0]                AWSIZES,
    input  wire [1:0]                AWBURSTS,
    input  wire                      AWLOCKS,
    input  wire [3:0]                AWCACHES,
    input  wire [2:0]                AWPROTS,
    input  wire [3:0]                AWQOSS,
    input  wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] AWUSERS,

    input  wire                      WVALIDS,
    output wire                      WREADYS,
    input  wire [DATA_WIDTH-1:0]     WDATAS,
    input  wire [(DATA_WIDTH/8)-1:0] WSTRBS,
    input  wire                      WLASTS,
    input  wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] WUSERS,

    output wire                      BVALIDS,
    input  wire                      BREADYS,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] BIDS,
    output wire [1:0]                BRESPS,
    output wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] BUSERS,

    input  wire                      ARVALIDS,
    output wire                      ARREADYS,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] ARIDS,
    input  wire [ADDR_WIDTH-1:0]     ARADDRS,
    input  wire [3:0]                ARREGIONS,
    input  wire [7:0]                ARLENS,
    input  wire [2:0]                ARSIZES,
    input  wire [1:0]                ARBURSTS,
    input  wire                      ARLOCKS,
    input  wire [3:0]                ARCACHES,
    input  wire [2:0]                ARPROTS,
    input  wire [3:0]                ARQOSS,
    input  wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] ARUSERS,

    output wire                      RVALIDS,
    input  wire                      RREADYS,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] RIDS,
    output wire [DATA_WIDTH-1:0]     RDATAS,
    output wire [1:0]                RRESPS,
    output wire                      RLASTS,
    output wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] RUSERS,

    input  wire                      AWAKEUPS, 

    output wire                      AWVALIDM,
    input  wire                      AWREADYM,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] AWIDM,
    output wire [ADDR_WIDTH-1:0]     AWADDRM,
    output wire [3:0]                AWREGIONM,
    output wire [7:0]                AWLENM,
    output wire [2:0]                AWSIZEM,
    output wire [1:0]                AWBURSTM,
    output wire                      AWLOCKM,
    output wire [3:0]                AWCACHEM,
    output wire [2:0]                AWPROTM,
    output wire [3:0]                AWQOSM,
    output wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] AWUSERM,

    output wire                      WVALIDM,
    input  wire                      WREADYM,
    output wire [DATA_WIDTH-1:0]     WDATAM,
    output wire [(DATA_WIDTH/8)-1:0] WSTRBM,
    output wire                      WLASTM,
    output wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] WUSERM,

    input  wire                      BVALIDM,
    output wire                      BREADYM,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] BIDM,
    input  wire [1:0]                BRESPM,
    input  wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] BUSERM,

    output wire                      ARVALIDM,
    input  wire                      ARREADYM,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] ARIDM,
    output wire [ADDR_WIDTH-1:0]     ARADDRM,
    output wire [3:0]                ARREGIONM,
    output wire [7:0]                ARLENM,
    output wire [2:0]                ARSIZEM,
    output wire [1:0]                ARBURSTM,
    output wire                      ARLOCKM,
    output wire [3:0]                ARCACHEM,
    output wire [2:0]                ARPROTM,
    output wire [3:0]                ARQOSM,
    output wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] ARUSERM,

    input  wire                      RVALIDM,
    output wire                      RREADYM,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] RIDM,
    input  wire [DATA_WIDTH-1:0]     RDATAM,
    input  wire [1:0]                RRESPM,
    input  wire                      RLASTM,
    input  wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] RUSERM,

    output wire                      AWAKEUPM 
   );

    

 
     wire       arvalids_acg;
     wire       awvalids_acg;
     wire       wvalids_acg;
     wire       wlasts_acg;
     
     wire       arreadym_acg;
     wire       awreadym_acg;
     wire       wreadym_acg;
     
     wire       awakeups_acg;
   
     wire       rvalids_acg;
     wire       rlasts_acg;
     wire       rreadys_acg;
   
     wire       bvalids_acg;
     wire       breadys_acg;
     
     wire       arvalidm_acg;
     wire       awvalidm_acg;
     wire       wvalidm_acg;
     
     wire       arreadys_acg;
     wire       awreadys_acg;
     wire       wreadys_acg;

    wire        ds_read_busy;
    wire        ds_write_busy;


    
   

   acg_axi_core #(
     .INACT_CD_CONFIG      (INACT_CD_CONFIG),
     .AW_CNTR_SIZE         (AW_CNTR_SIZE),
     .W_CNTR_SIZE          (W_CNTR_SIZE),
     .AR_CNTR_SIZE         (AR_CNTR_SIZE)
   ) u_acg_axi_core(
     .aclk           (ACLK),
     .aresetn        (ARESETn),
   
     .arvalids       (arvalids_acg),
     .awvalids       (awvalids_acg),
     .wvalids        (wvalids_acg),
     .wlasts         (wlasts_acg),
     
     .arreadym       (arreadym_acg),
     .awreadym       (awreadym_acg),
     .wreadym        (wreadym_acg),
     
     .awakeups       (awakeups_acg),
   
     .rvalids        (rvalids_acg),
     .rlasts         (rlasts_acg),
     .rreadys        (rreadys_acg),
   
     .bvalids        (bvalids_acg),
     .breadys        (breadys_acg),
     
     .arvalidm       (arvalidm_acg),
     .awvalidm       (awvalidm_acg),
     .wvalidm        (wvalidm_acg),
     
     .arreadys       (arreadys_acg),
     .awreadys       (awreadys_acg),
     .wreadys        (wreadys_acg),
     
     .inact          (INACT),
   
     .pwr_qreqn      (PWRQREQn),
     .pwr_qacceptn   (PWRQACCEPTn),
     .pwr_qdeny      (PWRQDENY),
     .pwr_qactive    (PWRQACTIVE),
   
     .clk_qreqn      (CLKQREQn),
     .clk_qacceptn   (CLKQACCEPTn),
     .clk_qdeny      (CLKQDENY),
     .clk_qactive    (CLKQACTIVE),

     .ds_read_busy   (ds_read_busy),
     .ds_write_busy  (ds_write_busy)   
    );


   generate
   if (ERR_RESP_EN == 1'b1)
   begin:error_responding_enabled

   acg_axi_mask #(
     .DATA_WIDTH(DATA_WIDTH),
     .AWID_WIDTH(AWID_WIDTH),
     .ARID_WIDTH(ARID_WIDTH)
   ) u_acg_axi_mask(
     .aclk              (ACLK),
     .aresetn           (ARESETn),
     .inact             (INACT),
     .clk_qacceptn      (CLKQACCEPTn),


     .awvalids          (AWVALIDS),
     .awvalidm_acg      (awvalidm_acg),
     .awreadys_acg      (awreadys_acg),
     .awreadym          (AWREADYM),
     .awids             (AWIDS),

     .awvalids_acg      (awvalids_acg),
     .awvalidm          (AWVALIDM),
     .awreadys          (AWREADYS),
     .awreadym_acg      (awreadym_acg),
     .awidm             (AWIDM),


     .wvalids           (WVALIDS),
     .wvalidm_acg       (wvalidm_acg),
     .wreadys_acg       (wreadys_acg),
     .wreadym           (WREADYM),
     .wlasts            (WLASTS),

     .wvalids_acg       (wvalids_acg),
     .wvalidm           (WVALIDM),
     .wreadys           (WREADYS),
     .wreadym_acg       (wreadym_acg),
     .wlastm            (WLASTM),
     .wlasts_acg        (wlasts_acg),


     .bvalidm           (BVALIDM),
     .breadys           (BREADYS),
     .bidm              (BIDM),
     .brespm            (BRESPM),

     .bvalids           (BVALIDS),
     .bvalids_acg       (bvalids_acg),
     .breadym           (BREADYM),
     .breadys_acg       (breadys_acg),
     .bids              (BIDS),
     .bresps            (BRESPS),


     .arvalids          (ARVALIDS),
     .arvalidm_acg      (arvalidm_acg),
     .arreadys_acg      (arreadys_acg),
     .arreadym          (ARREADYM),
     .arids             (ARIDS),
     .arlens            (ARLENS),

     .arvalids_acg      (arvalids_acg),
     .arvalidm          (ARVALIDM),
     .arreadys          (ARREADYS),
     .arreadym_acg      (arreadym_acg),
     .aridm             (ARIDM),
     .arlenm            (ARLENM),


     .rvalidm           (RVALIDM),
     .rreadys           (RREADYS),
     .ridm              (RIDM),
     .rrespm            (RRESPM),
     .rdatam            (RDATAM),
     .rlastm            (RLASTM),

     .rvalids           (RVALIDS),
     .rvalids_acg       (rvalids_acg),
     .rreadym           (RREADYM),
     .rreadys_acg       (rreadys_acg),
     .rids              (RIDS),
     .rresps            (RRESPS),
     .rdatas            (RDATAS),
     .rlasts            (RLASTS),
     .rlasts_acg        (rlasts_acg),

     .awakeups          (AWAKEUPS),
     .awakeups_acg      (awakeups_acg),


     .ds_read_busy      (ds_read_busy),
     .ds_write_busy     (ds_write_busy)     
   );

    
   end 
   else
   begin:error_responding_disabled
     assign ds_read_busy = 1'b0;
     assign ds_write_busy = 1'b0;
     
     assign arvalids_acg = ARVALIDS;
     assign awvalids_acg = AWVALIDS;
     assign wvalids_acg  = WVALIDS;
     assign wlasts_acg   = WLASTS;
 
     assign arreadym_acg = ARREADYM;
     assign awreadym_acg = AWREADYM;
     assign wreadym_acg  = WREADYM;
 
     assign awakeups_acg = AWAKEUPS;
   
     assign rvalids_acg  = RVALIDS;
     assign rlasts_acg   = RLASTS;
     assign rreadys_acg  = RREADYS;
   
     assign bvalids_acg  = BVALIDS;
     assign breadys_acg  = BREADYS;
 
     assign ARVALIDM = arvalidm_acg;
     assign AWVALIDM = awvalidm_acg;
     assign WVALIDM  = wvalidm_acg;

     assign ARREADYS = arreadys_acg;
     assign AWREADYS = awreadys_acg;
     assign WREADYS  = wreadys_acg;

     assign AWIDM = AWIDS;
     assign WLASTM = WLASTS;
     assign BVALIDS  = BVALIDM;
     assign BREADYM  = BREADYS;
     assign BIDS  = BIDM;
     assign BRESPS  = BRESPM;
     assign ARIDM  = ARIDS;
     assign ARLENM  = ARLENS;
     assign RVALIDS  = RVALIDM;
     assign RREADYM  = RREADYS;
     assign RIDS  = RIDM;
     assign RDATAS  = RDATAM;
     assign RRESPS  = RRESPM;
     assign RLASTS  = RLASTM;


   end 
  endgenerate 


    assign AWADDRM  = AWADDRS;
    assign AWREGIONM  = AWREGIONS;
    assign AWLENM  = AWLENS;
    assign AWSIZEM  = AWSIZES;
    assign AWBURSTM  = AWBURSTS;
    assign AWLOCKM  = AWLOCKS;
    assign AWCACHEM  = AWCACHES;
    assign AWPROTM  = AWPROTS;
    assign AWQOSM  = AWQOSS;
    assign AWUSERM  = AWUSERS;


    assign WDATAM  = WDATAS;
    assign WSTRBM  = WSTRBS;
    assign WUSERM  = WUSERS;

    assign BUSERS  = BUSERM;

    assign ARADDRM  = ARADDRS;
    assign ARREGIONM  = ARREGIONS;
    assign ARSIZEM  = ARSIZES;
    assign ARBURSTM  = ARBURSTS;
    assign ARLOCKM  = ARLOCKS;
    assign ARCACHEM  = ARCACHES;
    assign ARPROTM  = ARPROTS;
    assign ARQOSM  = ARQOSS;
    assign ARUSERM  = ARUSERS;

    assign RUSERS  = RUSERM;

    assign AWAKEUPM = AWAKEUPS;



endmodule

