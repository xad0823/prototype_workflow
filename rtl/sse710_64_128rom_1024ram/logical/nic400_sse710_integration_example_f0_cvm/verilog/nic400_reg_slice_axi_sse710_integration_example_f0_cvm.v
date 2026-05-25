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



`include "reg_slice_axi_defs.v"

module nic400_reg_slice_axi_sse710_integration_example_f0_cvm
  (
   aresetn,
   aclk,

   awids,
   awaddrs,
   awlens,
   awsizes,
   awbursts,
   awlocks,
   awcaches,
   awprots,
   awusers,
   awvalids,
   awreadys,

   wids,
   wdatas,
   wstrbs,
   wusers,
   wlasts,
   wvalids,
   wreadys,

   bids,
   bresps,
   busers,
   bvalids,
   breadys,

   arids,
   araddrs,
   arlens,
   arsizes,
   arbursts,
   arlocks,
   arcaches,
   arprots,
   arusers,
   arvalids,
   arreadys,

   rids,
   rdatas,
   rresps,
   rusers,
   rlasts,
   rvalids,
   rreadys,

   awidm,
   awaddrm,
   awlenm,
   awsizem,
   awburstm,
   awlockm,
   awcachem,
   awprotm,
   awuserm,
   awvalidm,
   awreadym,

   widm,
   wdatam,
   wstrbm,
   wuserm,
   wlastm,
   wvalidm,
   wreadym,

   bidm,
   brespm,
   buserm,
   bvalidm,
   breadym,

   aridm,
   araddrm,
   arlenm,
   arsizem,
   arburstm,
   arlockm,
   arcachem,
   arprotm,
   aruserm,
   arvalidm,
   arreadym,

   ridm,
   rdatam,
   rrespm,
   ruserm,
   rlastm,
   rvalidm,
   rreadym,

   scanenable,
   scaninaclk,
   scanoutaclk
   );

  parameter ID_WIDTH        = 4;       
  parameter DATA_WIDTH      = 64;      
  parameter AWUSER_WIDTH    = 32;      
  parameter WUSER_WIDTH     = 32;      
  parameter BUSER_WIDTH     = 32;      
  parameter ARUSER_WIDTH    = 32;      
  parameter RUSER_WIDTH     = 32;      
  parameter AW_HNDSHK_MODE  = `RS_REGD;
  parameter W_HNDSHK_MODE   = `RS_REGD;
  parameter B_HNDSHK_MODE   = `RS_REGD;
  parameter AR_HNDSHK_MODE  = `RS_REGD;
  parameter R_HNDSHK_MODE   = `RS_REGD;
  parameter ADDR_WIDTH      = 32;      

  parameter ID_MAX          = (ID_WIDTH - 1);
  parameter DATA_MAX        = (DATA_WIDTH - 1);
  parameter STRB_WIDTH      = (DATA_WIDTH / 8);
  parameter STRB_MAX        = (STRB_WIDTH - 1);
  parameter AWUSER_MAX      = (AWUSER_WIDTH - 1);
  parameter WUSER_MAX       = (WUSER_WIDTH - 1);
  parameter BUSER_MAX       = (BUSER_WIDTH - 1);
  parameter ARUSER_MAX      = (ARUSER_WIDTH - 1);
  parameter RUSER_MAX       = (RUSER_WIDTH - 1);
  parameter ADDR_MAX        = (ADDR_WIDTH - 1);
   
  input                 aresetn;          
  input                 aclk;             

  input [ID_MAX:0]      awids;            
  input [ADDR_MAX:0]    awaddrs;          
  input [3:0]           awlens;           
  input [2:0]           awsizes;          
  input [1:0]           awbursts;         
  input [1:0]           awlocks;          
  input [3:0]           awcaches;         
  input [2:0]           awprots;          
  input [AWUSER_MAX:0]  awusers;          
  input                 awvalids;         
  output                awreadys;         

  input [ID_MAX:0]      wids;             
  input [DATA_MAX:0]    wdatas;           
  input [STRB_MAX:0]    wstrbs;           
  input [WUSER_MAX:0]   wusers;           
  input                 wlasts;           
  input                 wvalids;          
  output                wreadys;          

  output [ID_MAX:0]     bids;             
  output [1:0]          bresps;           
  output [BUSER_MAX:0]  busers;           
  output                bvalids;          
  input                 breadys;          

  input [ID_MAX:0]      arids;            
  input [ADDR_MAX:0]    araddrs;          
  input [3:0]           arlens;           
  input [2:0]           arsizes;          
  input [1:0]           arbursts;         
  input [1:0]           arlocks;          
  input [3:0]           arcaches;         
  input [2:0]           arprots;          
  input [ARUSER_MAX:0]  arusers;          
  input                 arvalids;         
  output                arreadys;         

  output [ID_MAX:0]     rids;             
  output [DATA_MAX:0]   rdatas;           
  output [1:0]          rresps;           
  output [RUSER_MAX:0]  rusers;           
  output                rlasts;           
  output                rvalids;          
  input                 rreadys;          

  output [ID_MAX:0]     awidm;            
  output [ADDR_MAX:0]   awaddrm;          
  output [3:0]          awlenm;           
  output [2:0]          awsizem;          
  output [1:0]          awburstm;         
  output [1:0]          awlockm;          
  output [3:0]          awcachem;         
  output [2:0]          awprotm;          
  output [AWUSER_MAX:0] awuserm;          
  output                awvalidm;         
  input                 awreadym;         

  output [ID_MAX:0]     widm;             
  output [DATA_MAX:0]   wdatam;           
  output [STRB_MAX:0]   wstrbm;           
  output [WUSER_MAX:0]  wuserm;           
  output                wlastm;           
  output                wvalidm;          
  input                 wreadym;          

  input [ID_MAX:0]      bidm;             
  input [1:0]           brespm;           
  input [BUSER_MAX:0]   buserm;           
  input                 bvalidm;          
  output                breadym;          

  output [ID_MAX:0]     aridm;            
  output [ADDR_MAX:0]   araddrm;          
  output [3:0]          arlenm;           
  output [2:0]          arsizem;          
  output [1:0]          arburstm;         
  output [1:0]          arlockm;          
  output [3:0]          arcachem;         
  output [2:0]          arprotm;          
  output [ARUSER_MAX:0] aruserm;          
  output                arvalidm;         
  input                 arreadym;         

  input [ID_MAX:0]      ridm;             
  input [DATA_MAX:0]    rdatam;           
  input [1:0]           rrespm;           
  input [RUSER_MAX:0]   ruserm;           
  input                 rlastm;           
  input                 rvalidm;          
  output                rreadym;          

  input                 scanenable;       
  input                 scaninaclk;       
  output                scanoutaclk;      

  wire                  aresetn;          
  wire                  aclk;             

  wire [ID_MAX:0]       awids;            
  wire [ADDR_MAX:0]     awaddrs;          
  wire [3:0]            awlens;           
  wire [2:0]            awsizes;          
  wire [1:0]            awbursts;         
  wire [1:0]            awlocks;          
  wire [3:0]            awcaches;         
  wire [2:0]            awprots;          
  wire [AWUSER_MAX:0]   awusers;          
  wire                  awvalids;         
  wire                  awreadys;         

  wire [ID_MAX:0]       wids;             
  wire [DATA_MAX:0]     wdatas;           
  wire [STRB_MAX:0]     wstrbs;           
  wire [WUSER_MAX:0]    wusers;           
  wire                  wlasts;           
  wire                  wvalids;          
  wire                  wreadys;          

  wire [ID_MAX:0]       bids;             
  wire [1:0]            bresps;           
  wire [BUSER_MAX:0]    busers;           
  wire                  bvalids;          
  wire                  breadys;          

  wire [ID_MAX:0]       arids;            
  wire [ADDR_MAX:0]     araddrs;          
  wire [3:0]            arlens;           
  wire [2:0]            arsizes;          
  wire [1:0]            arbursts;         
  wire [1:0]            arlocks;          
  wire [3:0]            arcaches;         
  wire [2:0]            arprots;          
  wire [ARUSER_MAX:0]   arusers;          
  wire                  arvalids;         
  wire                  arreadys;         

  wire [ID_MAX:0]       rids;             
  wire [DATA_MAX:0]     rdatas;           
  wire [1:0]            rresps;           
  wire [RUSER_MAX:0]    rusers;           
  wire                  rlasts;           
  wire                  rvalids;          
  wire                  rreadys;          

  wire [ID_MAX:0]       awidm;            
  wire [ADDR_MAX:0]     awaddrm;          
  wire [3:0]            awlenm;           
  wire [2:0]            awsizem;          
  wire [1:0]            awburstm;         
  wire [1:0]            awlockm;          
  wire [3:0]            awcachem;         
  wire [2:0]            awprotm;          
  wire [AWUSER_MAX:0]   awuserm;          
  wire                  awvalidm;         
  wire                  awreadym;         

  wire [ID_MAX:0]       widm;             
  wire [DATA_MAX:0]     wdatam;           
  wire [STRB_MAX:0]     wstrbm;           
  wire [WUSER_MAX:0]    wuserm;           
  wire                  wlastm;           
  wire                  wvalidm;          
  wire                  wreadym;          

  wire [ID_MAX:0]       bidm;             
  wire [1:0]            brespm;           
  wire [BUSER_MAX:0]    buserm;           
  wire                  bvalidm;          
  wire                  breadym;          

  wire [ID_MAX:0]       aridm;            
  wire [ADDR_MAX:0]     araddrm;          
  wire [3:0]            arlenm;           
  wire [2:0]            arsizem;          
  wire [1:0]            arburstm;         
  wire [1:0]            arlockm;          
  wire [3:0]            arcachem;         
  wire [2:0]            arprotm;          
  wire [ARUSER_MAX:0]   aruserm;          
  wire                  arvalidm;         
  wire                  arreadym;         

  wire [ID_MAX:0]       ridm;             
  wire [DATA_MAX:0]     rdatam;           
  wire [1:0]            rrespm;           
  wire [RUSER_MAX:0]    ruserm;           
  wire                  rlastm;           
  wire                  rvalidm;          
  wire                  rreadym;          

  wire                  scanenable;       
  wire                  scaninaclk;       
  wire                  scanoutaclk;      


  nic400_ax_reg_slice_sse710_integration_example_f0_cvm #(ID_WIDTH, AWUSER_WIDTH, AW_HNDSHK_MODE, ADDR_WIDTH) u_aw_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .axids          (awids),
     .axaddrs        (awaddrs),
     .axlens         (awlens),
     .axsizes        (awsizes),
     .axbursts       (awbursts),
     .axlocks        (awlocks),
     .axcaches       (awcaches),
     .axprots        (awprots),
     .axusers        (awusers),
     .axvalids       (awvalids),
     .axreadys       (awreadys),

     .axidm          (awidm),
     .axaddrm        (awaddrm),
     .axlenm         (awlenm),
     .axsizem        (awsizem),
     .axburstm       (awburstm),
     .axlockm        (awlockm),
     .axcachem       (awcachem),
     .axprotm        (awprotm),
     .axuserm        (awuserm),
     .axvalidm       (awvalidm),
     .axreadym       (awreadym)
     );

  nic400_wr_reg_slice_sse710_integration_example_f0_cvm #(ID_WIDTH, DATA_WIDTH, WUSER_WIDTH, W_HNDSHK_MODE) u_wr_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .wids           (wids),
     .wdatas         (wdatas),
     .wstrbs         (wstrbs),
     .wusers         (wusers),
     .wlasts         (wlasts),
     .wvalids        (wvalids),
     .wreadys        (wreadys),

     .widm           (widm),
     .wdatam         (wdatam),
     .wstrbm         (wstrbm),
     .wuserm         (wuserm),
     .wlastm         (wlastm),
     .wvalidm        (wvalidm),
     .wreadym        (wreadym)
     );

  nic400_buf_reg_slice_sse710_integration_example_f0_cvm #(ID_WIDTH, BUSER_WIDTH, B_HNDSHK_MODE) u_buf_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .bids           (bids),
     .bresps         (bresps),
     .busers         (busers),
     .bvalids        (bvalids),
     .breadys        (breadys),

     .bidm           (bidm),
     .brespm         (brespm),
     .buserm         (buserm),
     .bvalidm        (bvalidm),
     .breadym        (breadym)
     );

  nic400_ax_reg_slice_sse710_integration_example_f0_cvm #(ID_WIDTH, ARUSER_WIDTH, AR_HNDSHK_MODE, ADDR_WIDTH) u_ar_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .axids          (arids),
     .axaddrs        (araddrs),
     .axlens         (arlens),
     .axsizes        (arsizes),
     .axbursts       (arbursts),
     .axlocks        (arlocks),
     .axcaches       (arcaches),
     .axprots        (arprots),
     .axusers        (arusers),
     .axvalids       (arvalids),
     .axreadys       (arreadys),

     .axidm          (aridm),
     .axaddrm        (araddrm),
     .axlenm         (arlenm),
     .axsizem        (arsizem),
     .axburstm       (arburstm),
     .axlockm        (arlockm),
     .axcachem       (arcachem),
     .axprotm        (arprotm),
     .axuserm        (aruserm),
     .axvalidm       (arvalidm),
     .axreadym       (arreadym)
     );

  nic400_rd_reg_slice_sse710_integration_example_f0_cvm #(ID_WIDTH, DATA_WIDTH, RUSER_WIDTH, R_HNDSHK_MODE) u_rd_reg_slice
    (
     .aresetn        (aresetn),
     .aclk           (aclk),

     .rids           (rids),
     .rdatas         (rdatas),
     .rresps         (rresps),
     .rusers         (rusers),
     .rlasts         (rlasts),
     .rvalids        (rvalids),
     .rreadys        (rreadys),

     .ridm           (ridm),
     .rdatam         (rdatam),
     .rrespm         (rrespm),
     .ruserm         (ruserm),
     .rlastm         (rlastm),
     .rvalidm        (rvalidm),
     .rreadym        (rreadym)
     );

`ifdef ARM_ASSERT_ON

  assert_proposition
    #(0, 1, "Error: value of AW_HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_aw_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((AW_HNDSHK_MODE == `RS_REGD         ) |
                    (AW_HNDSHK_MODE == `RS_FWD_REG      ) |
                    (AW_HNDSHK_MODE == `RS_REV_REG      ) |
                    (AW_HNDSHK_MODE == `RS_STATIC_BYPASS)));

  
  assert_proposition
    #(0, 1, "Error: value of W_HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_w_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((W_HNDSHK_MODE == `RS_REGD         ) |
                    (W_HNDSHK_MODE == `RS_FWD_REG      ) |
                    (W_HNDSHK_MODE == `RS_REV_REG      ) |
                    (W_HNDSHK_MODE == `RS_STATIC_BYPASS)));

  
  assert_proposition
    #(0, 1, "Error: value of B_HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_b_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((B_HNDSHK_MODE == `RS_REGD         ) |
                    (B_HNDSHK_MODE == `RS_FWD_REG      ) |
                    (B_HNDSHK_MODE == `RS_REV_REG      ) |
                    (B_HNDSHK_MODE == `RS_STATIC_BYPASS)));

  
  assert_proposition
    #(0, 1, "Error: value of AR_HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_ar_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((AR_HNDSHK_MODE == `RS_REGD         ) |
                    (AR_HNDSHK_MODE == `RS_FWD_REG      ) |
                    (AR_HNDSHK_MODE == `RS_REV_REG      ) |
                    (AR_HNDSHK_MODE == `RS_STATIC_BYPASS)));

  
  assert_proposition
    #(0, 1, "Error: value of R_HNDSHK_MODE must be 0, 1, 2 or 3")
      illegal_r_hndshk_mode_val
        (.reset_n (aresetn),
         .test_expr((R_HNDSHK_MODE == `RS_REGD         ) |
                    (R_HNDSHK_MODE == `RS_FWD_REG      ) |
                    (R_HNDSHK_MODE == `RS_REV_REG      ) |
                    (R_HNDSHK_MODE == `RS_STATIC_BYPASS)));

`endif

endmodule

`include "reg_slice_axi_undefs.v"

