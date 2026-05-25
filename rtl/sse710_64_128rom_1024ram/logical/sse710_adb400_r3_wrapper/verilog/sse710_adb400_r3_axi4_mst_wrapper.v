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

module sse710_adb400_r3_axi4_mst_wrapper
  #(
   parameter ADDR_WIDTH          = 40,
   parameter DATA_WIDTH          = 128,
   parameter AWID_WIDTH          = 1,
   parameter ARID_WIDTH          = 1,
   parameter AWUSER_WIDTH        = 1,
   parameter WUSER_WIDTH         = 1,
   parameter BUSER_WIDTH         = 1,
   parameter ARUSER_WIDTH        = 1,
   parameter RUSER_WIDTH         = 1,
   parameter AW_FIFO_DEPTH       = 4,
   parameter W_FIFO_DEPTH        = 6,
   parameter B_FIFO_DEPTH        = 2,
   parameter AR_FIFO_DEPTH       = 4,
   parameter R_FIFO_DEPTH        = 6,
   parameter AW_OPREG            = 1,
   parameter W_OPREG             = 1,
   parameter AR_OPREG            = 1,
   parameter MI_SYNC_LEVELS      = 2,
   parameter AW_PAYLOAD_WIDTH    = 236,
   parameter W_PAYLOAD_WIDTH     = 222,
   parameter B_PAYLOAD_WIDTH     = 24,
   parameter AR_PAYLOAD_WIDTH    = 236,
   parameter R_PAYLOAD_WIDTH     = 264
  )
  (

    input  wire                      aclkm,
    input  wire                      aresetnm,

    input  wire                      clkqreqnm_i,
    output wire                      clkqacceptnm_o,
    output wire                      clkqdenym_o,

    output wire                      clkqactivem_o,


    output wire                      wakeupm_o,

    output wire                      awvalidm,
    input  wire                      awreadym,
    output wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awidm,
    output wire [ADDR_WIDTH-1:0]     awaddrm,
    output wire [3:0]                awregionm,
    output wire [7:0]                awlenm,
    output wire [2:0]                awsizem,
    output wire [1:0]                awburstm,
    output wire                      awlockm,
    output wire [3:0]                awcachem,
    output wire [2:0]                awprotm,
    output wire [3:0]                awqosm,
    output wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awuserm,

    output wire                      wvalidm,
    input  wire                      wreadym,
    output wire [DATA_WIDTH-1:0]     wdatam,
    output wire [(DATA_WIDTH/8)-1:0] wstrbm,
    output wire                      wlastm,
    output wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0] wuserm,

    input  wire                      bvalidm,
    output wire                      breadym,
    input  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bidm,
    input  wire [1:0]                brespm,
    input  wire [((BUSER_WIDTH>0)?(BUSER_WIDTH-1):0):0] buserm,

    output wire                      arvalidm,
    input  wire                      arreadym,
    output wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] aridm,
    output wire [ADDR_WIDTH-1:0]     araddrm,
    output wire [3:0]                arregionm,
    output wire [7:0]                arlenm,
    output wire [2:0]                arsizem,
    output wire [1:0]                arburstm,
    output wire                      arlockm,
    output wire [3:0]                arcachem,
    output wire [2:0]                arprotm,
    output wire [3:0]                arqosm,
    output wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] aruserm,

    input  wire                      rvalidm,
    output wire                      rreadym,
    input  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] ridm,
    input  wire [DATA_WIDTH-1:0]     rdatam,
    input  wire [1:0]                rrespm,
    input  wire                      rlastm,
    input  wire [((RUSER_WIDTH>0)?(RUSER_WIDTH-1):0):0] ruserm,




    input  wire                   slvmustacceptreqn_async,
    input  wire                   slvcandenyreqn_async,
    output wire                   slvacceptn_async,
    output wire                   slvdeny_async,

    input  wire                   si_to_mi_wakeup_async,
    output wire                   mi_to_si_wakeup_async,


    input  wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    output wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    input  wire [AW_PAYLOAD_WIDTH-1:0] aw_payld_async,

    input  wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    output wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    input  wire [ W_PAYLOAD_WIDTH-1:0] w_payld_async,

    output wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    input  wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    output wire [ B_PAYLOAD_WIDTH-1:0] b_payld_async,

    input  wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    output wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    input  wire [AR_PAYLOAD_WIDTH-1:0] ar_payld_async,

    output wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    input  wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    output wire [ R_PAYLOAD_WIDTH-1:0] r_payld_async,


    input  wire                      dftrstdisablem
);


    wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]     awidm_int;
    wire [ADDR_WIDTH-1:0]                          awaddrm_int;
    wire [3:0]                                     awregionm_int;
    wire [7:0]                                     awlenm_int;
    wire [2:0]                                     awsizem_int;
    wire [1:0]                                     awburstm_int;
    wire                                           awlockm_int;
    wire [3:0]                                     awcachem_int;
    wire [2:0]                                     awprotm_int;
    wire [3:0]                                     awqosm_int;
    wire [((AWUSER_WIDTH>0)?(AWUSER_WIDTH-1):0):0] awuserm_int;

    wire [DATA_WIDTH-1:0]                          wdatam_int;
    wire [(DATA_WIDTH/8)-1:0]                      wstrbm_int;
    wire                                           wlastm_int;
    wire [((WUSER_WIDTH>0)?(WUSER_WIDTH-1):0):0]   wuserm_int;
    
    wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]     aridm_int;
    wire [ADDR_WIDTH-1:0]                          araddrm_int;
    wire [3:0]                                     arregionm_int;
    wire [7:0]                                     arlenm_int;
    wire [2:0]                                     arsizem_int;
    wire [1:0]                                     arburstm_int;
    wire                                           arlockm_int;
    wire [3:0]                                     arcachem_int;
    wire [2:0]                                     arprotm_int;
    wire [3:0]                                     arqosm_int;
    wire [((ARUSER_WIDTH>0)?(ARUSER_WIDTH-1):0):0] aruserm_int;    
  

  adb400_r3_axi4_mst #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .DATA_WIDTH             (DATA_WIDTH),
    .AWID_WIDTH             (AWID_WIDTH),
    .ARID_WIDTH             (ARID_WIDTH),
    .AWUSER_WIDTH           (AWUSER_WIDTH),
    .WUSER_WIDTH            (WUSER_WIDTH),
    .BUSER_WIDTH            (BUSER_WIDTH),
    .ARUSER_WIDTH           (ARUSER_WIDTH),
    .RUSER_WIDTH            (RUSER_WIDTH),
    .AW_FIFO_DEPTH          (AW_FIFO_DEPTH),
    .W_FIFO_DEPTH           (W_FIFO_DEPTH),
    .B_FIFO_DEPTH           (B_FIFO_DEPTH),
    .AR_FIFO_DEPTH          (AR_FIFO_DEPTH),
    .R_FIFO_DEPTH           (R_FIFO_DEPTH),
    .AW_OPREG               (AW_OPREG),
    .W_OPREG                (W_OPREG),
    .AR_OPREG               (AR_OPREG),
    .MI_SYNC_LEVELS         (MI_SYNC_LEVELS)
  ) u_adb400_r3_axi4_mst (
    .aclkm                          (aclkm),
    .aresetnm                       (aresetnm),
    .clkqreqnm_i                    (clkqreqnm_i),
    .clkqacceptnm_o                 (clkqacceptnm_o),
    .clkqdenym_o                    (clkqdenym_o),
    .clkqactivem_o                  (clkqactivem_o),
    .wakeupm_o                      (wakeupm_o),
    .awvalidm                       (awvalidm),
    .awreadym                       (awreadym),
    .awuserm                        (awuserm_int),
    .awidm                          (awidm_int),
    .awaddrm                        (awaddrm_int),
    .awregionm                      (awregionm_int),
    .awlenm                         (awlenm_int),
    .awsizem                        (awsizem_int),
    .awburstm                       (awburstm_int),
    .awlockm                        (awlockm_int),
    .awcachem                       (awcachem_int),
    .awprotm                        (awprotm_int),
    .awqosm                         (awqosm_int),
    .wvalidm                        (wvalidm),
    .wreadym                        (wreadym),
    .wuserm                         (wuserm_int),
    .wdatam                         (wdatam_int),
    .wstrbm                         (wstrbm_int),
    .wlastm                         (wlastm_int),
    .bvalidm                        (bvalidm),
    .breadym                        (breadym),
    .buserm                         (buserm),
    .bidm                           (bidm),
    .brespm                         (brespm),
    .arvalidm                       (arvalidm),
    .arreadym                       (arreadym),
    .aruserm                        (aruserm_int),
    .aridm                          (aridm_int),
    .araddrm                        (araddrm_int),
    .arregionm                      (arregionm_int),
    .arlenm                         (arlenm_int),
    .arsizem                        (arsizem_int),
    .arburstm                       (arburstm_int),
    .arlockm                        (arlockm_int),
    .arcachem                       (arcachem_int),
    .arprotm                        (arprotm_int),
    .arqosm                         (arqosm_int),
    .rvalidm                        (rvalidm),
    .rreadym                        (rreadym),
    .ruserm                         (ruserm),
    .ridm                           (ridm),
    .rdatam                         (rdatam),
    .rrespm                         (rrespm),
    .rlastm                         (rlastm),
    .slvmustacceptreqn_async        (slvmustacceptreqn_async),
    .slvcandenyreqn_async           (slvcandenyreqn_async),
    .slvacceptn_async               (slvacceptn_async),
    .slvdeny_async                  (slvdeny_async),
    .si_to_mi_wakeup_async          (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async          (mi_to_si_wakeup_async),
    .aw_wr_ptr_async                (aw_wr_ptr_async),
    .aw_rd_ptr_async                (aw_rd_ptr_async),
    .aw_payld_async                 (aw_payld_async),
    .w_wr_ptr_async                 (w_wr_ptr_async),
    .w_rd_ptr_async                 (w_rd_ptr_async),
    .w_payld_async                  (w_payld_async),
    .b_wr_ptr_async                 (b_wr_ptr_async),
    .b_rd_ptr_async                 (b_rd_ptr_async),
    .b_payld_async                  (b_payld_async),
    .ar_wr_ptr_async                (ar_wr_ptr_async),
    .ar_rd_ptr_async                (ar_rd_ptr_async),
    .ar_payld_async                 (ar_payld_async),
    .r_wr_ptr_async                 (r_wr_ptr_async),
    .r_rd_ptr_async                 (r_rd_ptr_async),
    .r_payld_async                  (r_payld_async),
    .dftrstdisablem                 (dftrstdisablem)
  );


  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((AWID_WIDTH>0)?(AWID_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_awidm (
    .din1_async   (awidm_int),
    .din2_async   ({((AWID_WIDTH>0)?(AWID_WIDTH):1){awvalidm}}),
    .dout_async   (awidm)
  );
 
  arm_element_cdc_comb_and2 #(
    .WIDTH (ADDR_WIDTH)
  ) u_arm_element_cdc_comb_and2_awaddrm (
    .din1_async   (awaddrm_int),
    .din2_async   ({ADDR_WIDTH{awvalidm}}),
    .dout_async   (awaddrm)
  ); 

  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_awregionm (
    .din1_async   (awregionm_int),
    .din2_async   ({4{awvalidm}}),
    .dout_async   (awregionm)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (8)
  ) u_arm_element_cdc_comb_and2_awlenm (
    .din1_async   (awlenm_int),
    .din2_async   ({8{awvalidm}}),
    .dout_async   (awlenm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (3)
  ) u_arm_element_cdc_comb_and2_awsizem (
    .din1_async   (awsizem_int),
    .din2_async   ({3{awvalidm}}),
    .dout_async   (awsizem)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (2)
  ) u_arm_element_cdc_comb_and2_awburstm (
    .din1_async   (awburstm_int),
    .din2_async   ({2{awvalidm}}),
    .dout_async   (awburstm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (1)
  ) u_arm_element_cdc_comb_and2_awlockm (
    .din1_async   (awlockm_int),
    .din2_async   (awvalidm),
    .dout_async   (awlockm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_awcachem (
    .din1_async   (awcachem_int),
    .din2_async   ({4{awvalidm}}),
    .dout_async   (awcachem)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (3)
  ) u_arm_element_cdc_comb_and2_awprotm (
    .din1_async   (awprotm_int),
    .din2_async   ({3{awvalidm}}),
    .dout_async   (awprotm)
  );  
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_awqosm (
    .din1_async   (awqosm_int),
    .din2_async   ({4{awvalidm}}),
    .dout_async   (awqosm)
  );  

  arm_element_cdc_comb_and2 #(
    .WIDTH (((AWUSER_WIDTH>0)?(AWUSER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_awuserm (
    .din1_async   (awuserm_int),
    .din2_async   ({((AWUSER_WIDTH>0)?(AWUSER_WIDTH):1){awvalidm}}),
    .dout_async   (awuserm)
  );    


  arm_element_cdc_comb_and2 #(
    .WIDTH (((ARID_WIDTH>0)?(ARID_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_aridm (
    .din1_async   (aridm_int),
    .din2_async   ({((ARID_WIDTH>0)?(ARID_WIDTH):1){arvalidm}}),
    .dout_async   (aridm)
  );
 
  arm_element_cdc_comb_and2 #(
    .WIDTH (ADDR_WIDTH)
  ) u_arm_element_cdc_comb_and2_araddrm (
    .din1_async   (araddrm_int),
    .din2_async   ({ADDR_WIDTH{arvalidm}}),
    .dout_async   (araddrm)
  ); 

  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_arregionm (
    .din1_async   (arregionm_int),
    .din2_async   ({4{arvalidm}}),
    .dout_async   (arregionm)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (8)
  ) u_arm_element_cdc_comb_and2_arlenm (
    .din1_async   (arlenm_int),
    .din2_async   ({8{arvalidm}}),
    .dout_async   (arlenm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (3)
  ) u_arm_element_cdc_comb_and2_arsizem (
    .din1_async   (arsizem_int),
    .din2_async   ({3{arvalidm}}),
    .dout_async   (arsizem)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (2)
  ) u_arm_element_cdc_comb_and2_arburstm (
    .din1_async   (arburstm_int),
    .din2_async   ({2{arvalidm}}),
    .dout_async   (arburstm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (1)
  ) u_arm_element_cdc_comb_and2_arlockm (
    .din1_async   (arlockm_int),
    .din2_async   (arvalidm),
    .dout_async   (arlockm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_arcachem (
    .din1_async   (arcachem_int),
    .din2_async   ({4{arvalidm}}),
    .dout_async   (arcachem)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (3)
  ) u_arm_element_cdc_comb_and2_arprotm (
    .din1_async   (arprotm_int),
    .din2_async   ({3{arvalidm}}),
    .dout_async   (arprotm)
  );  
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (4)
  ) u_arm_element_cdc_comb_and2_arqosm (
    .din1_async   (arqosm_int),
    .din2_async   ({4{arvalidm}}),
    .dout_async   (arqosm)
  );  

  arm_element_cdc_comb_and2 #(
    .WIDTH (((ARUSER_WIDTH>0)?(ARUSER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_aruserm (
    .din1_async   (aruserm_int),
    .din2_async   ({((ARUSER_WIDTH>0)?(ARUSER_WIDTH):1){arvalidm}}),
    .dout_async   (aruserm)
  );    
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (DATA_WIDTH)
  ) u_arm_element_cdc_comb_and2_wdatam (
    .din1_async   (wdatam_int),
    .din2_async   ({DATA_WIDTH{wvalidm}}),
    .dout_async   (wdatam)
  ); 

  arm_element_cdc_comb_and2 #(
    .WIDTH (DATA_WIDTH/8)
  ) u_arm_element_cdc_comb_and2_wstrbm (
    .din1_async   (wstrbm_int),
    .din2_async   ({(DATA_WIDTH/8){wvalidm}}),
    .dout_async   (wstrbm)
  );  
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (1)
  ) u_arm_element_cdc_comb_and2_wlastm (
    .din1_async   (wlastm_int),
    .din2_async   (wvalidm),
    .dout_async   (wlastm)
  ); 

  arm_element_cdc_comb_and2 #(
    .WIDTH (((WUSER_WIDTH>0)?(WUSER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_wuserm (
    .din1_async   (wuserm_int),
    .din2_async   ({((WUSER_WIDTH>0)?(WUSER_WIDTH):1){wvalidm}}),
    .dout_async   (wuserm)
  );   
      
endmodule
