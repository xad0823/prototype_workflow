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
module pc_debug_f0_systop 
  #(parameter
      SYS_EGRESS_2_DBG  = 2,
      DBG_ADDR_WIDTH    = 32,
      DBG_DATA_WIDTH    = 64,
      DBG_AWID_WIDTH    = 4,
      DBG_ARID_WIDTH    = 4,
      DBG_AWUSER_WIDTH  = 10,
      DBG_WUSER_WIDTH   = 0,
      DBG_BUSER_WIDTH   = 1,
      DBG_ARUSER_WIDTH  = 10,
      DBG_RUSER_WIDTH   = 1,
      DBG_AW_FIFO_DEPTH = 4,
      DBG_W_FIFO_DEPTH  = 6,
      DBG_B_FIFO_DEPTH  = 2,
      DBG_AR_FIFO_DEPTH = 4,
      DBG_R_FIFO_DEPTH  = 6,
      DBG_AW_PAYLOAD_WIDTH = 316,
      DBG_W_PAYLOAD_WIDTH  = 870,
      DBG_B_PAYLOAD_WIDTH  = 20,
      DBG_AR_PAYLOAD_WIDTH = 316,
      DBG_R_PAYLOAD_WIDTH  = 834,
      STM_AXI_ID_WIDTH     = 11,
      STM_ADDR_WIDTH       = 32,
      STM_DATA_WIDTH       = 64,
      STM_AWID_WIDTH       = STM_AXI_ID_WIDTH,
      STM_ARID_WIDTH       = STM_AXI_ID_WIDTH,
      STM_AWUSER_WIDTH     = 10,
      STM_WUSER_WIDTH      = 0,
      STM_BUSER_WIDTH      = 0,
      STM_ARUSER_WIDTH     = 10,
      STM_RUSER_WIDTH      = 0,
      STM_AW_FIFO_DEPTH    = 4,
      STM_W_FIFO_DEPTH     = 6,
      STM_B_FIFO_DEPTH     = 2,
      STM_AR_FIFO_DEPTH    = 4,
      STM_R_FIFO_DEPTH     = 6,
      STM_AW_PAYLOAD_WIDTH = 236,
      STM_W_PAYLOAD_WIDTH  = 222,
      STM_B_PAYLOAD_WIDTH  = 24,
      STM_AR_PAYLOAD_WIDTH = 236,
      STM_R_PAYLOAD_WIDTH  = 264
) (
input  wire aclk,
input  wire aresetn,
input wire   [4:0]          aclk_qreqn,
output wire  [4:0]          aclk_qacceptn,
output wire  [4:0]          aclk_qdeny,
output wire  [4:0]          aclk_qactive,


output wire debug_axis_wakeupm_o,


input  [31:0] paddr_hostsysdbg_apb,
input         pselx_hostsysdbg_apb,
input         penable_hostsysdbg_apb,
input         pwrite_hostsysdbg_apb,
output [31:0] prdata_hostsysdbg_apb,
input  [31:0] pwdata_hostsysdbg_apb,
input  [2:0]  pprot_hostsysdbg_apb,
input  [3:0]  pstrb_hostsysdbg_apb,
output        pready_hostsysdbg_apb,
output        pslverr_hostsysdbg_apb,

output  wire           hostsysdbg_async_req,
output  wire [67:0]    hostsysdbg_async_req_payload,
input   wire [32:0]    hostsysdbg_async_resp_payload,
input   wire           hostsysdbg_async_ack,    


output wire [DBG_AWID_WIDTH-1:0]   awid_debug_axis,
output wire [DBG_ADDR_WIDTH-1:0]  awaddr_debug_axis,
output wire [7:0]   awlen_debug_axis,
output wire [2:0]   awsize_debug_axis,
output wire [1:0]   awburst_debug_axis,
output wire         awlock_debug_axis,
output wire [3:0]   awcache_debug_axis,
output wire [2:0]   awprot_debug_axis,
output wire         awvalid_debug_axis,
input  wire         awready_debug_axis,
output wire [DBG_DATA_WIDTH-1:0] wdata_debug_axis,
output wire [(DBG_DATA_WIDTH/8)-1:0]  wstrb_debug_axis,
output wire         wlast_debug_axis,
output wire         wvalid_debug_axis,
input  wire         wready_debug_axis,
input  wire [DBG_AWID_WIDTH-1:0]   bid_debug_axis,
input  wire [1:0]   bresp_debug_axis,
input  wire         bvalid_debug_axis,
output wire         bready_debug_axis,
output wire [DBG_ARID_WIDTH-1:0]   arid_debug_axis,
output wire [DBG_ADDR_WIDTH-1:0]  araddr_debug_axis,
output wire [7:0]   arlen_debug_axis,
output wire [2:0]   arsize_debug_axis,
output wire [1:0]   arburst_debug_axis,
output wire         arlock_debug_axis,
output wire [3:0]   arcache_debug_axis,
output wire [2:0]   arprot_debug_axis,
output wire         arvalid_debug_axis,
input  wire         arready_debug_axis,
input  wire [DBG_ARID_WIDTH-1:0]   rid_debug_axis,
input  wire [DBG_DATA_WIDTH-1:0] rdata_debug_axis,
input  wire [1:0]   rresp_debug_axis,
input  wire         rlast_debug_axis,
input  wire         rvalid_debug_axis,
output wire         rready_debug_axis,
output wire [DBG_AWUSER_WIDTH-1:0]   awuser_debug_axis,
output wire [DBG_ARUSER_WIDTH-1:0]   aruser_debug_axis,
input  wire [DBG_BUSER_WIDTH-1:0]   buser_debug_axis,
input  wire [DBG_RUSER_WIDTH-1:0]   ruser_debug_axis,

input  wire debug_axis_slvmustacceptreqn_async,
input  wire debug_axis_slvcandenyreqn_async,
output wire debug_axis_slvacceptn_async,
output wire debug_axis_slvdeny_async,

input  wire debug_axis_si_to_mi_wakeup_async,
output wire debug_axis_mi_to_si_wakeup_async,

input  wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_wr_ptr_async,
output wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_rd_ptr_async,
input  wire [DBG_AW_PAYLOAD_WIDTH-1:0] debug_axis_aw_payld_async,

input  wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_wr_ptr_async,
output wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_rd_ptr_async,
input  wire [DBG_W_PAYLOAD_WIDTH-1:0]  debug_axis_w_payld_async,
                                       
output wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_wr_ptr_async,
input  wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_rd_ptr_async,
output wire [DBG_B_PAYLOAD_WIDTH-1:0]  debug_axis_b_payld_async,

input  wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_wr_ptr_async,
output wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_rd_ptr_async,
input  wire [DBG_AR_PAYLOAD_WIDTH-1:0] debug_axis_ar_payld_async,

output wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_wr_ptr_async,
input  wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_rd_ptr_async,
output wire [DBG_R_PAYLOAD_WIDTH-1:0]  debug_axis_r_payld_async,


output  wire                            stm_slvmustacceptreqn_async,
output  wire                            stm_slvcandenyreqn_async,
input   wire                            stm_slvacceptn_async,
input   wire                            stm_slvdeny_async,
    
output  wire                            stm_si_to_mi_wakeup_async,
input wire                              stm_mi_to_si_wakeup_async,

output  wire [STM_AW_FIFO_DEPTH-1:0]    stm_aw_wr_ptr_async,
input wire [STM_AW_FIFO_DEPTH-1:0]      stm_aw_rd_ptr_async,
output  wire [STM_AW_PAYLOAD_WIDTH-1:0] stm_aw_payld_async,

output  wire [ STM_W_FIFO_DEPTH-1:0]    stm_w_wr_ptr_async,
input wire [ STM_W_FIFO_DEPTH-1:0]      stm_w_rd_ptr_async,
output  wire [STM_W_PAYLOAD_WIDTH-1:0]  stm_w_payld_async,

input wire [ STM_B_FIFO_DEPTH-1:0]      stm_b_wr_ptr_async,
output  wire [ STM_B_FIFO_DEPTH-1:0]    stm_b_rd_ptr_async,
input wire [STM_B_PAYLOAD_WIDTH-1:0]    stm_b_payld_async,

output  wire [STM_AR_FIFO_DEPTH-1:0]    stm_ar_wr_ptr_async,
input wire [STM_AR_FIFO_DEPTH-1:0]      stm_ar_rd_ptr_async,
output  wire [STM_AR_PAYLOAD_WIDTH-1:0] stm_ar_payld_async,

input wire [ STM_R_FIFO_DEPTH-1:0]      stm_r_wr_ptr_async,
output  wire [ STM_R_FIFO_DEPTH-1:0]    stm_r_rd_ptr_async,
input wire [STM_R_PAYLOAD_WIDTH-1:0]    stm_r_payld_async,
                                                               

                                                               
input  wire                      awvalid_stm_axim,
output wire                      awready_stm_axim,
input  wire [((STM_AWUSER_WIDTH>0)?(STM_AWUSER_WIDTH-1):0):0] awuser_stm_axim,
input  wire [((STM_AWID_WIDTH>0)?(STM_AWID_WIDTH-1):0):0] awid_stm_axim,
input  wire [STM_ADDR_WIDTH-1:0]     awaddr_stm_axim,
input  wire [7:0]                awlen_stm_axim,
input  wire [2:0]                awsize_stm_axim,
input  wire [1:0]                awburst_stm_axim,
input  wire                      awlock_stm_axim,
input  wire [3:0]                awcache_stm_axim,
input  wire [2:0]                awprot_stm_axim,
                                                               
input  wire                      wvalid_stm_axim,
output wire                      wready_stm_axim,
input  wire [STM_DATA_WIDTH-1:0]     wdata_stm_axim,
input  wire [(STM_DATA_WIDTH/8)-1:0] wstrb_stm_axim,
input  wire                      wlast_stm_axim,
                                                               
output wire                      bvalid_stm_axim,
input  wire                      bready_stm_axim,
output wire [((STM_AWID_WIDTH>0)?(STM_AWID_WIDTH-1):0):0] bid_stm_axim,
output wire [1:0]                bresp_stm_axim,
                                                               
input  wire                      arvalid_stm_axim,
output wire                      arready_stm_axim,
input  wire [((STM_ARUSER_WIDTH>0)?(STM_ARUSER_WIDTH-1):0):0] aruser_stm_axim,
input  wire [((STM_ARID_WIDTH>0)?(STM_ARID_WIDTH-1):0):0] arid_stm_axim,
input  wire [STM_ADDR_WIDTH-1:0]     araddr_stm_axim,
input  wire [7:0]                arlen_stm_axim,
input  wire [2:0]                arsize_stm_axim,
input  wire [1:0]                arburst_stm_axim,
input  wire                      arlock_stm_axim,
input  wire [3:0]                arcache_stm_axim,
input  wire [2:0]                arprot_stm_axim,
                                                               
output wire                      rvalid_stm_axim,
input  wire                      rready_stm_axim,
output wire [((STM_ARID_WIDTH>0)?(STM_ARID_WIDTH-1):0):0] rid_stm_axim,
output wire [STM_DATA_WIDTH-1:0]     rdata_stm_axim,
output wire [1:0]                rresp_stm_axim,
output wire                      rlast_stm_axim,

 
input wire   [SYS_EGRESS_2_DBG-1:0]  qreqn_systop_egress_dbgtop,
output  wire [SYS_EGRESS_2_DBG-1:0]  qacceptn_systop_egress_dbgtop,
output  wire [SYS_EGRESS_2_DBG-1:0]  qdeny_systop_egress_dbgtop,
output  wire [SYS_EGRESS_2_DBG-1:0]  qactive_systop_egress_dbgtop,
  

input dftcgen,
input dftrstdisable
);
     

wire                      awvalid_gated_stm_axim;
wire                      awready_gated_stm_axim;
wire [((STM_AWUSER_WIDTH>0)?(STM_AWUSER_WIDTH-1):0):0] awuser_gated_stm_axim;
wire [((STM_AWID_WIDTH>0)?(STM_AWID_WIDTH-1):0):0] awid_gated_stm_axim;
wire [STM_ADDR_WIDTH-1:0]     awaddr_gated_stm_axim;
wire [7:0]                awlen_gated_stm_axim;
wire [2:0]                awsize_gated_stm_axim;
wire [1:0]                awburst_gated_stm_axim;
wire                      awlock_gated_stm_axim;
wire [3:0]                awcache_gated_stm_axim;
wire [2:0]                awprot_gated_stm_axim;
                                                        

wire                      wvalid_gated_stm_axim;
wire                      wready_gated_stm_axim;
wire [((STM_AWUSER_WIDTH>0)?(STM_AWUSER_WIDTH-1):0):0] wuser_gated_stm_axim;
wire [STM_DATA_WIDTH-1:0]     wdata_gated_stm_axim;
wire [(STM_DATA_WIDTH/8)-1:0] wstrb_gated_stm_axim;
wire                      wlast_gated_stm_axim;
                                                        

wire                      bvalid_gated_stm_axim;
wire                      bready_gated_stm_axim;
wire [((STM_BUSER_WIDTH>0)?(STM_BUSER_WIDTH-1):0):0] buser_gated_stm_axim;
wire [((STM_AWID_WIDTH>0)?(STM_AWID_WIDTH-1):0):0] bid_gated_stm_axim;

                                                        

wire                      arvalid_gated_stm_axim;
wire                      arready_gated_stm_axim;
wire [((STM_ARUSER_WIDTH>0)?(STM_ARUSER_WIDTH-1):0):0] aruser_gated_stm_axim;
wire [((STM_ARID_WIDTH>0)?(STM_ARID_WIDTH-1):0):0] arid_gated_stm_axim;
wire [STM_ADDR_WIDTH-1:0]     araddr_gated_stm_axim;
wire [7:0]                arlen_gated_stm_axim;
wire [2:0]                arsize_gated_stm_axim;
wire [1:0]                arburst_gated_stm_axim;
wire                      arlock_gated_stm_axim;
wire [3:0]                arcache_gated_stm_axim;
wire [2:0]                arprot_gated_stm_axim;
                                                       

wire                      rvalid_gated_stm_axim;
wire                      rready_gated_stm_axim;
wire [((STM_RUSER_WIDTH>0)?(STM_RUSER_WIDTH-1):0):0] ruser_gated_stm_axim;
wire [((STM_ARID_WIDTH>0)?(STM_ARID_WIDTH-1):0):0] rid_gated_stm_axim;
wire [STM_DATA_WIDTH-1:0]     rdata_gated_stm_axim;
wire                      rlast_gated_stm_axim;

 
     
     
     


  sse710_adb400_r3_axi4_mst_wrapper
    #(
      .ADDR_WIDTH       (DBG_ADDR_WIDTH   ),
      .DATA_WIDTH       (DBG_DATA_WIDTH   ),
      .AWID_WIDTH       (DBG_AWID_WIDTH   ),
      .ARID_WIDTH       (DBG_ARID_WIDTH   ),
      .AWUSER_WIDTH     (DBG_AWUSER_WIDTH ),
      .WUSER_WIDTH      (DBG_WUSER_WIDTH  ),
      .BUSER_WIDTH      (DBG_BUSER_WIDTH  ),
      .ARUSER_WIDTH     (DBG_ARUSER_WIDTH ),
      .RUSER_WIDTH      (DBG_RUSER_WIDTH  ),
      .AW_FIFO_DEPTH    (DBG_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (DBG_W_FIFO_DEPTH ),
      .B_FIFO_DEPTH     (DBG_B_FIFO_DEPTH ),
      .AR_FIFO_DEPTH    (DBG_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (DBG_R_FIFO_DEPTH ),
      .AW_OPREG         (1),
      .W_OPREG          (1),
      .AR_OPREG         (1),
      .MI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH (DBG_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (DBG_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (DBG_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (DBG_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (DBG_R_PAYLOAD_WIDTH)
    )
  u_sse710_adb400_r3_axi4_mst_wrapper
    (

    .aclkm                  (aclk),                   
    .aresetnm               (aresetn),

    .clkqreqnm_i            (aclk_qreqn[0]),    
    .clkqacceptnm_o         (aclk_qacceptn[0]),
    .clkqdenym_o            (aclk_qdeny[0]),
    .clkqactivem_o          (aclk_qactive[0]),

    .wakeupm_o              (debug_axis_wakeupm_o),

    .awvalidm               (awvalid_debug_axis ),
    .awreadym               (awready_debug_axis ),
    .awuserm                (awuser_debug_axis  ),
    .awidm                  (awid_debug_axis),
    .awaddrm                (awaddr_debug_axis  ),
    .awregionm              (),  
    .awlenm                 (awlen_debug_axis   ),
    .awsizem                (awsize_debug_axis  ),
    .awlockm                (awlock_debug_axis  ),
    .awcachem               (awcache_debug_axis ),
    .awprotm                (awprot_debug_axis  ),
    .awqosm                 (),
    .awburstm               (awburst_debug_axis ),
    .wvalidm                (wvalid_debug_axis  ),
    .wreadym                (wready_debug_axis  ),
    .wuserm                 (), 
    .wdatam                 (wdata_debug_axis   ),
    .wstrbm                 (wstrb_debug_axis   ),
    .wlastm                 (wlast_debug_axis   ),
    .bvalidm                (bvalid_debug_axis  ),
    .breadym                (bready_debug_axis  ),
    .buserm                 (buser_debug_axis   ),
    .bidm                   (bid_debug_axis     ),
    .brespm                 (bresp_debug_axis   ),
    .arvalidm               (arvalid_debug_axis ),
    .arreadym               (arready_debug_axis ),
    .aruserm                (aruser_debug_axis  ),
    .aridm                  (arid_debug_axis),
    .araddrm                (araddr_debug_axis  ),
    .arregionm              (),  
    .arlenm                 (arlen_debug_axis   ),
    .arsizem                (arsize_debug_axis  ),
    .arlockm                (arlock_debug_axis  ),
    .arcachem               (arcache_debug_axis ),
    .arprotm                (arprot_debug_axis  ),
    .arqosm                 (),
    .arburstm               (arburst_debug_axis ),
    .rvalidm                (rvalid_debug_axis  ),
    .rreadym                (rready_debug_axis  ),
    .ruserm                 (ruser_debug_axis   ),
    .ridm                   (rid_debug_axis     ),
    .rdatam                 (rdata_debug_axis   ),
    .rrespm                 (rresp_debug_axis   ),
    .rlastm                 (rlast_debug_axis   ),
                             


    .slvmustacceptreqn_async (debug_axis_slvmustacceptreqn_async),
    .slvcandenyreqn_async    (debug_axis_slvcandenyreqn_async),
    .slvacceptn_async        (debug_axis_slvacceptn_async),
    .slvdeny_async           (debug_axis_slvdeny_async),
    .si_to_mi_wakeup_async   (debug_axis_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async   (debug_axis_mi_to_si_wakeup_async),

    .aw_wr_ptr_async         (debug_axis_aw_wr_ptr_async),
    .aw_rd_ptr_async         (debug_axis_aw_rd_ptr_async),
    .aw_payld_async          (debug_axis_aw_payld_async),
    .w_wr_ptr_async          (debug_axis_w_wr_ptr_async),
    .w_rd_ptr_async          (debug_axis_w_rd_ptr_async),
    .w_payld_async           (debug_axis_w_payld_async),
    .b_wr_ptr_async          (debug_axis_b_wr_ptr_async),
    .b_rd_ptr_async          (debug_axis_b_rd_ptr_async),
    .b_payld_async           (debug_axis_b_payld_async),
    .ar_wr_ptr_async         (debug_axis_ar_wr_ptr_async),
    .ar_rd_ptr_async         (debug_axis_ar_rd_ptr_async),
    .ar_payld_async          (debug_axis_ar_payld_async),
    .r_wr_ptr_async          (debug_axis_r_wr_ptr_async),
    .r_rd_ptr_async          (debug_axis_r_rd_ptr_async),
    .r_payld_async           (debug_axis_r_payld_async),


    .dftrstdisablem          (dftrstdisable)
    );
  
 assign rresp_stm_axim = 2'd0;
 assign bresp_stm_axim = 2'd0;
 
 
 wire acg_qreqn   ;
 wire acg_qacceptn;
 wire acg_qdeny   ;
 wire acg_qactive ;
 
 wire stm_qreqn   ;
 wire stm_qacceptn;
 wire stm_qdeny   ;
 wire stm_qactive ;
 
 pck600_lpd_q  #(
    .SEQUENCER      (1), 
    .NUM_QCHL       (2),
    .CTRL_Q_CH_SYNC (1), 
    .DEV_Q_CH_SYNC  (0), 
    .ACTIVE_DENY    (0)  
    ) 
    u_acg_stm_sequencer                 
    (
    .clk              (aclk),
    .reset_n          (aresetn),    
    
    .ctrl_qreqn_i     (qreqn_systop_egress_dbgtop[0]   ),
    .ctrl_qacceptn_o  (qacceptn_systop_egress_dbgtop[0]),
    .ctrl_qdeny_o     (qdeny_systop_egress_dbgtop[0]   ),
    .ctrl_qactive_o   ( ),
    
    .dev_qreqn_o      ({acg_qreqn   ,stm_qreqn   }),
    .dev_qacceptn_i   ({acg_qacceptn,stm_qacceptn}),
    .dev_qdeny_i      ({acg_qdeny   ,stm_qdeny   }),
    .dev_qactive_i    ({acg_qactive ,stm_qactive }),
    
    .clk_qactive_o    (aclk_qactive[3]),
    
    .dftcgen          (dftcgen)
    );
  
  wire awakeup_stm_axim;
  wire awakeup_gated_stm_axim;
    
  assign aclk_qacceptn[3] = aclk_qreqn[3];
  assign aclk_qdeny[3]    = 1'b0;
  
  assign qactive_systop_egress_dbgtop[0] = 1'b0;
  assign awakeup_stm_axim = 1'b0;
       
  acg_axi #(
  .ADDR_WIDTH   (STM_ADDR_WIDTH),
  .DATA_WIDTH   (STM_DATA_WIDTH),
  .AWID_WIDTH   (STM_AWID_WIDTH),
  .ARID_WIDTH   (STM_ARID_WIDTH),
  .AWUSER_WIDTH (STM_AWUSER_WIDTH),
  .WUSER_WIDTH  (STM_WUSER_WIDTH),
  .BUSER_WIDTH  (STM_BUSER_WIDTH),
  .ARUSER_WIDTH (STM_ARUSER_WIDTH),
  .RUSER_WIDTH  (STM_RUSER_WIDTH),
  .AW_CNTR_SIZE (6),
  .W_CNTR_SIZE  (6),
  .AR_CNTR_SIZE (1),
  .ERR_RESP_EN  (1)
)
  u_acg_axi_stm (
  .ACLK          (aclk),
  .ARESETn       (aresetn),
  .PWRQREQn      (acg_qreqn),
  .PWRQACCEPTn   (acg_qacceptn),
  .PWRQDENY      (acg_qdeny),
  .PWRQACTIVE    (acg_qactive),

  .CLKQREQn      (aclk_qreqn[4]),
  .CLKQACCEPTn   (aclk_qacceptn[4]),
  .CLKQDENY      (aclk_qdeny[4]),
  .CLKQACTIVE    (aclk_qactive[4]), 

  
  .INACT         (),
  
  .AWVALIDS      (awvalid_stm_axim),
  .AWREADYS      (awready_stm_axim),
  .AWIDS         (awid_stm_axim),
  .AWADDRS       (awaddr_stm_axim),
  .AWREGIONS     (4'h0),
  .AWLENS        (awlen_stm_axim),
  .AWSIZES       (awsize_stm_axim),
  .AWBURSTS      (awburst_stm_axim),
  .AWLOCKS       (awlock_stm_axim),
  .AWCACHES      (awcache_stm_axim),
  .AWPROTS       (awprot_stm_axim),
  .AWQOSS        (4'hf),
  .AWUSERS       (awuser_stm_axim),
  .WVALIDS       (wvalid_stm_axim),
  .WREADYS       (wready_stm_axim),
  .WDATAS        (wdata_stm_axim),
  .WSTRBS        (wstrb_stm_axim),
  .WLASTS        (wlast_stm_axim),
  .WUSERS        (1'b0),
  .BVALIDS       (bvalid_stm_axim),
  .BREADYS       (bready_stm_axim),
  .BIDS          (bid_stm_axim),
  .BRESPS        (),
  .BUSERS        (),
  .ARVALIDS      (arvalid_stm_axim),
  .ARREADYS      (arready_stm_axim),
  .ARIDS         (arid_stm_axim),
  .ARADDRS       (araddr_stm_axim),
  .ARREGIONS     (4'h0),
  .ARLENS        (arlen_stm_axim),
  .ARSIZES       (arsize_stm_axim),
  .ARBURSTS      (arburst_stm_axim),
  .ARLOCKS       (arlock_stm_axim),
  .ARCACHES      (arcache_stm_axim),
  .ARPROTS       (arprot_stm_axim),
  .ARQOSS        (4'hf),
  .ARUSERS       (aruser_stm_axim),
  .RVALIDS       (rvalid_stm_axim),
  .RREADYS       (rready_stm_axim),
  .RIDS          (rid_stm_axim),
  .RDATAS        (rdata_stm_axim),
  .RRESPS        (),
  .RLASTS        (rlast_stm_axim),
  .RUSERS        (),
  .AWAKEUPS      (awakeup_stm_axim),

  .AWVALIDM      (awvalid_gated_stm_axim),
  .AWREADYM      (awready_gated_stm_axim),
  .AWIDM         (awid_gated_stm_axim),
  .AWADDRM       (awaddr_gated_stm_axim),
  .AWREGIONM     (),
  .AWLENM        (awlen_gated_stm_axim),
  .AWSIZEM       (awsize_gated_stm_axim),
  .AWBURSTM      (awburst_gated_stm_axim),
  .AWLOCKM       (awlock_gated_stm_axim),
  .AWCACHEM      (awcache_gated_stm_axim),
  .AWPROTM       (awprot_gated_stm_axim),
  .AWQOSM        (),
  .AWUSERM       (awuser_gated_stm_axim),
  .WVALIDM       (wvalid_gated_stm_axim),
  .WREADYM       (wready_gated_stm_axim),
  .WDATAM        (wdata_gated_stm_axim),
  .WSTRBM        (wstrb_gated_stm_axim),
  .WLASTM        (wlast_gated_stm_axim),
  .WUSERM        (),
  .BVALIDM       (bvalid_gated_stm_axim),
  .BREADYM       (bready_gated_stm_axim),
  .BIDM          (bid_gated_stm_axim),
  .BRESPM        (2'd0),
  .BUSERM        (1'b0),
  .ARVALIDM      (arvalid_gated_stm_axim),
  .ARREADYM      (arready_gated_stm_axim),
  .ARIDM         (arid_gated_stm_axim),
  .ARADDRM       (araddr_gated_stm_axim),
  .ARREGIONM     (),
  .ARLENM        (arlen_gated_stm_axim),
  .ARSIZEM       (arsize_gated_stm_axim),
  .ARBURSTM      (arburst_gated_stm_axim),
  .ARLOCKM       (arlock_gated_stm_axim),
  .ARCACHEM      (arcache_gated_stm_axim),
  .ARPROTM       (arprot_gated_stm_axim),
  .ARQOSM        (),
  .ARUSERM       (aruser_gated_stm_axim),
  .RVALIDM       (rvalid_gated_stm_axim),
  .RREADYM       (rready_gated_stm_axim),
  .RIDM          (rid_gated_stm_axim),
  .RDATAM        (rdata_gated_stm_axim),
  .RRESPM        (2'd0),
  .RLASTM        (rlast_gated_stm_axim),
  .RUSERM        (1'b0),
  .AWAKEUPM      (awakeup_gated_stm_axim)
);

  sse710_adb400_r3_axi4_slv_wrapper
    #(
      .ADDR_WIDTH       (STM_ADDR_WIDTH),
      .DATA_WIDTH       (STM_DATA_WIDTH),
      .AWID_WIDTH       (STM_AWID_WIDTH),
      .ARID_WIDTH       (STM_ARID_WIDTH),
      .AWUSER_WIDTH     (STM_AWUSER_WIDTH),
      .WUSER_WIDTH      (STM_WUSER_WIDTH),
      .BUSER_WIDTH      (STM_BUSER_WIDTH),
      .ARUSER_WIDTH     (STM_ARUSER_WIDTH),
      .RUSER_WIDTH      (STM_RUSER_WIDTH),
      .AW_FIFO_DEPTH    (STM_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (STM_W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (STM_B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (STM_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (STM_R_FIFO_DEPTH),
      .B_OPREG          (1),
      .R_OPREG          (1),
      .SI_SYNC_LEVELS   (2),                     
      .AW_PAYLOAD_WIDTH (STM_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (STM_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (STM_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (STM_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (STM_R_PAYLOAD_WIDTH)
    )
  u_sse710_adb400_r3_axi4_slv_wrapper
    (
    .pwrq_permit_deny_sar_i (1'b1),

    .aclks                  (aclk),                   
    .aresetns               (aresetn),

    .clkqreqns_i            (aclk_qreqn[1]),
    .clkqacceptns_o         (aclk_qacceptn[1]),
    .clkqdenys_o            (aclk_qdeny[1]),
    .clkqactives_o          (aclk_qactive[1]), 
    
    .pwrqreqns_i            (stm_qreqn   ),  
    .pwrqacceptns_o         (stm_qacceptn),  
    .pwrqdenys_o            (stm_qdeny   ),  
    .pwrqactives_o          (stm_qactive ),  

    .wakeups_i              (awakeup_gated_stm_axim),
                             
    .awvalids               (awvalid_gated_stm_axim ),
    .awreadys               (awready_gated_stm_axim ),
    .awusers                (awuser_gated_stm_axim  ),
    .awids                  (awid_gated_stm_axim    ),
    .awaddrs                (awaddr_gated_stm_axim  ),
    .awregions              (4'h0),  
    .awlens                 (awlen_gated_stm_axim   ),
    .awsizes                (awsize_gated_stm_axim  ),
    .awlocks                (awlock_gated_stm_axim),
    .awcaches               (awcache_gated_stm_axim),
    .awprots                (awprot_gated_stm_axim  ),
    .awqoss                 (4'hf), 
    .awbursts               (awburst_gated_stm_axim ),

    .wvalids                (wvalid_gated_stm_axim  ),
    .wreadys                (wready_gated_stm_axim  ),
    .wusers                 (1'b0), 
    .wdatas                 (wdata_gated_stm_axim   ),
    .wstrbs                 (wstrb_gated_stm_axim   ),
    .wlasts                 (wlast_gated_stm_axim),

    .bvalids                (bvalid_gated_stm_axim  ),
    .breadys                (bready_gated_stm_axim  ),
    .busers                 (  ), 
    .bids                   (bid_gated_stm_axim     ),
    .bresps                 (   ),

    .arvalids               (arvalid_gated_stm_axim ),
    .arreadys               (arready_gated_stm_axim ),
    .arusers                (aruser_gated_stm_axim  ),
    .arids                  (arid_gated_stm_axim    ),
    .araddrs                (araddr_gated_stm_axim  ),
    .arregions              (4'h0),  
    .arlens                 (arlen_gated_stm_axim   ),
    .arsizes                (arsize_gated_stm_axim  ),
    .arlocks                (arlock_gated_stm_axim),
    .arcaches               (arcache_gated_stm_axim),
    .arprots                (arprot_gated_stm_axim  ),
    .arqoss                 (4'hf), 
    .arbursts               (arburst_gated_stm_axim ),

    .rvalids                (rvalid_gated_stm_axim  ),
    .rreadys                (rready_gated_stm_axim  ),
    .rusers                 (  ), 
    .rids                   (rid_gated_stm_axim     ),
    .rdatas                 (rdata_gated_stm_axim   ),
    .rresps                 (   ),
    .rlasts                 (rlast_gated_stm_axim   ),



    .slvmustacceptreqn_async (stm_slvmustacceptreqn_async),
    .slvcandenyreqn_async    (stm_slvcandenyreqn_async),
    .slvacceptn_async        (stm_slvacceptn_async),
    .slvdeny_async           (stm_slvdeny_async),
    .si_to_mi_wakeup_async   (stm_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async   (stm_mi_to_si_wakeup_async),

    .aw_wr_ptr_async         (stm_aw_wr_ptr_async),
    .aw_rd_ptr_async         (stm_aw_rd_ptr_async),
    .aw_payld_async          (stm_aw_payld_async),
    .w_wr_ptr_async          (stm_w_wr_ptr_async),
    .w_rd_ptr_async          (stm_w_rd_ptr_async),
    .w_payld_async           (stm_w_payld_async),
    .b_wr_ptr_async          (stm_b_wr_ptr_async),
    .b_rd_ptr_async          (stm_b_rd_ptr_async),
    .b_payld_async           (stm_b_payld_async),
    .ar_wr_ptr_async         (stm_ar_wr_ptr_async),
    .ar_rd_ptr_async         (stm_ar_rd_ptr_async),
    .ar_payld_async          (stm_ar_payld_async),
    .r_wr_ptr_async          (stm_r_wr_ptr_async),
    .r_rd_ptr_async          (stm_r_rd_ptr_async),
    .r_payld_async           (stm_r_payld_async),

    .dftrstdisables          (dftrstdisable)
    );

  reg pwakeup_hostsysdbg_apb;
  
  always @(posedge aclk or negedge aresetn)
  begin
    if(!aresetn)
        pwakeup_hostsysdbg_apb<=1'b0;
    else
        pwakeup_hostsysdbg_apb<=pselx_hostsysdbg_apb;
  end
  
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_adb_hostsysdbg_slv (
    .clk_s                      (aclk),
    .reset_s_n                  (aresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (pselx_hostsysdbg_apb),  
    .penable_s                  (penable_hostsysdbg_apb),
    .paddr_s                    (paddr_hostsysdbg_apb),  
    .pwrite_s                   (pwrite_hostsysdbg_apb), 
    .pwdata_s                   (pwdata_hostsysdbg_apb), 
    .pprot_s                    (pprot_hostsysdbg_apb),  
    .prdata_s                   (prdata_hostsysdbg_apb), 
    .pready_s                   (pready_hostsysdbg_apb), 
    .pslverr_s                  (pslverr_hostsysdbg_apb),
    .pwakeup_s                  (pwakeup_hostsysdbg_apb),
    
    .clk_s_qreq_n               (aclk_qreqn[2]),
    .clk_s_qaccept_n            (aclk_qacceptn[2]),
    .clk_s_qdeny                (aclk_qdeny[2]),
    .clk_s_qactive              (aclk_qactive[2]),
    
    .pwr_qreq_n                 (qreqn_systop_egress_dbgtop[1]),
    .pwr_qaccept_n              (qacceptn_systop_egress_dbgtop[1]),
    .pwr_qdeny                  (qdeny_systop_egress_dbgtop[1]),
    .pwr_qactive                (qactive_systop_egress_dbgtop[1]),
    
    .apb_async_req              (hostsysdbg_async_req),
    .apb_async_req_payload      (hostsysdbg_async_req_payload),
    .apb_async_resp_payload     (hostsysdbg_async_resp_payload),
    .apb_async_ack              (hostsysdbg_async_ack)
  );

  wire unused;
  
  assign unused = (|pstrb_hostsysdbg_apb);
                  
endmodule 
