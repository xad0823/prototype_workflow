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
module pc_systop_f0_dbgtop 
#(
      parameter DBG_ADDR_WIDTH       = 32,
      parameter DBG_DATA_WIDTH       = 32,
      parameter DBG_AWID_WIDTH       = 4,
      parameter DBG_ARID_WIDTH       = 4,
      parameter DBG_AWUSER_WIDTH     = 0,
      parameter DBG_WUSER_WIDTH      = 0,
      parameter DBG_BUSER_WIDTH      = 0,
      parameter DBG_ARUSER_WIDTH     = 0,
      parameter DBG_RUSER_WIDTH      = 0,
      parameter DBG_AW_FIFO_DEPTH    = 4,
      parameter DBG_W_FIFO_DEPTH     = 6,
      parameter DBG_B_FIFO_DEPTH     = 2,
      parameter DBG_AR_FIFO_DEPTH    = 4,
      parameter DBG_R_FIFO_DEPTH     = 6,
      parameter DBG_AW_PAYLOAD_WIDTH = 316,
      parameter DBG_W_PAYLOAD_WIDTH  = 870,
      parameter DBG_B_PAYLOAD_WIDTH  = 20,
      parameter DBG_AR_PAYLOAD_WIDTH = 316,
      parameter DBG_R_PAYLOAD_WIDTH  = 834,
      parameter STM_AW_FIFO_DEPTH    = 2,
      parameter STM_W_FIFO_DEPTH     = 2,
      parameter STM_B_FIFO_DEPTH     = 2,
      parameter STM_AR_FIFO_DEPTH    = 2,
      parameter STM_R_FIFO_DEPTH     = 2,
      parameter STM_AW_PAYLOAD_WIDTH = 236,
      parameter STM_W_PAYLOAD_WIDTH  = 222,
      parameter STM_B_PAYLOAD_WIDTH  = 24,
      parameter STM_AR_PAYLOAD_WIDTH = 236,
      parameter STM_R_PAYLOAD_WIDTH  = 264,
      parameter STM_AXI_ID_WIDTH     = 12,
      parameter STM_AWUSER_WIDTH     = 0,
      parameter STM_WUSER_WIDTH      = 0,
      parameter STM_BUSER_WIDTH      = 0,
      parameter STM_ARUSER_WIDTH     = 0,
      parameter STM_RUSER_WIDTH      = 0
 )   (
    input dbgclk,
    input reset_n,
    input dftcgen,


    input wire  [2:0]  dbgclk_qreqn    ,
    output wire [2:0] dbgclk_qacceptn,    
    output wire [2:0] dbgclk_qdeny   ,    
    output wire [2:0] dbgclk_qactive,    


    
    output  wire debug_axis_slvmustacceptreqn_async,
    output  wire debug_axis_slvcandenyreqn_async,
    input wire debug_axis_slvacceptn_async,
    input wire debug_axis_slvdeny_async,
    
    output  wire debug_axis_si_to_mi_wakeup_async,
    input wire debug_axis_mi_to_si_wakeup_async,
    
    output  wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_wr_ptr_async,
    input wire [DBG_AW_FIFO_DEPTH-1:0]    debug_axis_aw_rd_ptr_async,
    output  wire [DBG_AW_PAYLOAD_WIDTH-1:0] debug_axis_aw_payld_async,
    
    output  wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_wr_ptr_async,
    input wire [ DBG_W_FIFO_DEPTH-1:0]    debug_axis_w_rd_ptr_async,
    output  wire [DBG_W_PAYLOAD_WIDTH-1:0]  debug_axis_w_payld_async,
                                        
    input wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_wr_ptr_async,
    output  wire [ DBG_B_FIFO_DEPTH-1:0]    debug_axis_b_rd_ptr_async,
    input wire [DBG_B_PAYLOAD_WIDTH-1:0]  debug_axis_b_payld_async,
    
    output  wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_wr_ptr_async,
    input wire [DBG_AR_FIFO_DEPTH-1:0]    debug_axis_ar_rd_ptr_async,
    output  wire [DBG_AR_PAYLOAD_WIDTH-1:0] debug_axis_ar_payld_async,
    
    input wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_wr_ptr_async,
    output  wire [ DBG_R_FIFO_DEPTH-1:0]    debug_axis_r_rd_ptr_async,
    input wire [DBG_R_PAYLOAD_WIDTH-1:0]  debug_axis_r_payld_async,
    
    
    input  wire                            stm_slvmustacceptreqn_async,
    input  wire                            stm_slvcandenyreqn_async,
    output   wire                            stm_slvacceptn_async,
    output   wire                            stm_slvdeny_async,
        
    input  wire                            stm_si_to_mi_wakeup_async,
    output wire                              stm_mi_to_si_wakeup_async,
    
    input  wire [STM_AW_FIFO_DEPTH-1:0]    stm_aw_wr_ptr_async,
    output wire [STM_AW_FIFO_DEPTH-1:0]      stm_aw_rd_ptr_async,
    input  wire [STM_AW_PAYLOAD_WIDTH-1:0] stm_aw_payld_async,
    
    input  wire [ STM_W_FIFO_DEPTH-1:0]    stm_w_wr_ptr_async,
    output wire [ STM_W_FIFO_DEPTH-1:0]      stm_w_rd_ptr_async,
    input  wire [STM_W_PAYLOAD_WIDTH-1:0]  stm_w_payld_async,
    
    output wire [ STM_B_FIFO_DEPTH-1:0]      stm_b_wr_ptr_async,
    input  wire [ STM_B_FIFO_DEPTH-1:0]    stm_b_rd_ptr_async,
    output wire [STM_B_PAYLOAD_WIDTH-1:0]    stm_b_payld_async,
    
    input  wire [STM_AR_FIFO_DEPTH-1:0]    stm_ar_wr_ptr_async,
    output wire [STM_AR_FIFO_DEPTH-1:0]      stm_ar_rd_ptr_async,
    input  wire [STM_AR_PAYLOAD_WIDTH-1:0] stm_ar_payld_async,
    
    output wire [ STM_R_FIFO_DEPTH-1:0]      stm_r_wr_ptr_async,
    input  wire [ STM_R_FIFO_DEPTH-1:0]    stm_r_rd_ptr_async,
    output wire [STM_R_PAYLOAD_WIDTH-1:0]    stm_r_payld_async,

    
    output  wire [STM_AXI_ID_WIDTH-1:0]          stm_axi_arid,        
    output  wire [31:0]                      stm_axi_araddr,      
    output  wire [7:0]                       stm_axi_arlen,       
    output  wire [2:0]                       stm_axi_arsize,      
    output  wire [1:0]                       stm_axi_arburst,     
    output  wire                             stm_axi_arlock,      
    output  wire [3:0]                       stm_axi_arcache,     
    output  wire [2:0]                       stm_axi_arprot,      
    output  wire                             stm_axi_arvalid,     
    input wire                                stm_axi_arready,     

    output  wire                             stm_axi_rready,      
    input wire [STM_AXI_ID_WIDTH-1:0]          stm_axi_rid,         
    input wire [63:0]                      stm_axi_rdata,       
    input wire [1:0]                       stm_axi_rresp,       
    input wire                             stm_axi_rlast,       
    input wire                             stm_axi_rvalid,      

    output  wire [STM_AXI_ID_WIDTH-1:0]          stm_axi_awid,        
    output  wire [31:0]                      stm_axi_awaddr,      
    output  wire [7:0]                       stm_axi_awlen,       
    output  wire [2:0]                       stm_axi_awsize,      
    output  wire [1:0]                       stm_axi_awburst,     
    output  wire                             stm_axi_awlock,      
    output  wire [3:0]                       stm_axi_awcache,     
    output  wire [STM_AWUSER_WIDTH-1:0]       stm_axi_awuser,     
    output  wire [2:0]                       stm_axi_awprot,      
    output  wire                             stm_axi_awvalid,     
    input wire                              stm_axi_awready,     

    output  wire [63:0]                      stm_axi_wdata,       
    output  wire [7:0]                       stm_axi_wstrb,       
    output  wire                             stm_axi_wlast,       
    output  wire                             stm_axi_wvalid,      
    input wire                               stm_axi_wready,      

    output  wire                             stm_axi_bready,      
    input wire [STM_AXI_ID_WIDTH-1:0]          stm_axi_bid,         
    input wire [1:0]                       stm_axi_bresp,       
    input wire                             stm_axi_bvalid,       

    
    input  wire [((DBG_ARID_WIDTH>0)?(DBG_ARID_WIDTH-1):0):0]          debug_axis_arid,        
    input  wire [DBG_ADDR_WIDTH-1:0]        debug_axis_araddr,      
    input  wire [7:0]                       debug_axis_arlen,       
    input  wire [2:0]                       debug_axis_arsize,      
    input  wire [1:0]                       debug_axis_arburst,     
    input  wire                             debug_axis_arlock,      
    input  wire [3:0]                       debug_axis_arcache,     
    input  wire [2:0]                       debug_axis_arprot,      
    input  wire                             debug_axis_arvalid,     
    output wire                             debug_axis_arready,     
    input  wire [DBG_ARUSER_WIDTH-1:0]      debug_axis_aruser,     

    input  wire                             debug_axis_rready,      
    output wire [((DBG_ARID_WIDTH>0)?(DBG_ARID_WIDTH-1):0):0]        debug_axis_rid,         
    output wire [DBG_DATA_WIDTH-1:0]        debug_axis_rdata,       
    output wire [1:0]                       debug_axis_rresp,       
    output wire                             debug_axis_rlast,       
    output wire                             debug_axis_rvalid,      

    input  wire [((DBG_AWID_WIDTH>0)?(DBG_AWID_WIDTH-1):0):0]        debug_axis_awid,        
    input  wire [31:0]                      debug_axis_awaddr,      
    input  wire [7:0]                       debug_axis_awlen,       
    input  wire [2:0]                       debug_axis_awsize,      
    input  wire [1:0]                       debug_axis_awburst,     
    input  wire                             debug_axis_awlock,      
    input  wire [3:0]                       debug_axis_awcache,     
    input  wire [2:0]                       debug_axis_awprot,      
    input  wire                             debug_axis_awvalid,     
    output wire                             debug_axis_awready,     
    input  wire [DBG_AWUSER_WIDTH-1:0]      debug_axis_awuser,     
    

    input  wire [DBG_DATA_WIDTH-1:0]        debug_axis_wdata,       
    input  wire [(DBG_DATA_WIDTH/8)-1:0]    debug_axis_wstrb,       
    input  wire                             debug_axis_wlast,       
    input  wire                             debug_axis_wvalid,      
    output wire                             debug_axis_wready,      

    input  wire                             debug_axis_bready,      
    output wire [((DBG_AWID_WIDTH>0)?(DBG_AWID_WIDTH-1):0):0]        debug_axis_bid,         
    output wire [1:0]                       debug_axis_bresp,       
    output wire                             debug_axis_bvalid,       

    output wire                             hostdbg_psel,    
    output wire                             hostdbg_penable, 
    output wire [31:0]                      hostdbg_paddr,   
    output wire                             hostdbg_pwrite,  
    output wire [31:0]                      hostdbg_pwdata,  
    output wire [3:0]                       hostdbg_pstrb,  
    output wire [2:0]                       hostdbg_pprot,   
    input  wire [31:0]                      hostdbg_prdata,  
    input  wire                             hostdbg_pready,  
    input  wire                             hostdbg_pslverr, 
    output wire                             hostdbg_pwakeup, 
    
    input  wire                            hostsysdbg_async_req,
    input  wire [67:0]                     hostsysdbg_async_req_payload,
    output wire [32:0]                     hostsysdbg_async_resp_payload,
    output wire                            hostsysdbg_async_ack,

    input  wire                           qreqn_axi_adb,
    output wire                           qacceptn_axi_adb,
    output wire                           qdeny_axi_adb,
    output wire                           qactive_axi_adb,
   
    
    
    
    
    input  wire                             dftrstdisable

);


 reg slv_wakeup;
 wire nx_slv_wakeup;
 
  sse710_adb400_r3_axi4_mst_wrapper
    #(
      .ADDR_WIDTH       (32   ),
      .DATA_WIDTH       (64   ),
      .AWID_WIDTH       (STM_AXI_ID_WIDTH ),
      .ARID_WIDTH       (STM_AXI_ID_WIDTH ),
      .AWUSER_WIDTH     (STM_AWUSER_WIDTH ),
      .WUSER_WIDTH      (STM_WUSER_WIDTH  ),
      .BUSER_WIDTH      (STM_BUSER_WIDTH  ),
      .ARUSER_WIDTH     (STM_ARUSER_WIDTH ),
      .RUSER_WIDTH      (STM_RUSER_WIDTH  ),
      .AW_FIFO_DEPTH    (STM_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (STM_W_FIFO_DEPTH ),
      .B_FIFO_DEPTH     (STM_B_FIFO_DEPTH ),
      .AR_FIFO_DEPTH    (STM_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (STM_R_FIFO_DEPTH ),
      .AW_OPREG         (1),
      .W_OPREG          (1),
      .AR_OPREG         (1),
      .MI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH   (STM_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH    (STM_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH    (STM_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH   (STM_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH    (STM_R_PAYLOAD_WIDTH)          
    )
  u_sse710_adb400_r3_axi4_mst_wrapper
    (

    .aclkm                  (dbgclk),                   
    .aresetnm               (reset_n),

    .clkqreqnm_i            (dbgclk_qreqn   [0]),
    .clkqacceptnm_o         (dbgclk_qacceptn[0]),
    .clkqdenym_o            (dbgclk_qdeny   [0]),
    .clkqactivem_o          (dbgclk_qactive[0]),

    .wakeupm_o              (),

    .awvalidm               (stm_axi_awvalid ),
    .awreadym               (stm_axi_awready ),
    .awuserm                (stm_axi_awuser  ),
    .awidm                  (stm_axi_awid    ),
    .awaddrm                (stm_axi_awaddr  ),
    .awregionm              (),  
    .awlenm                 (stm_axi_awlen   ),
    .awsizem                (stm_axi_awsize  ),
    .awlockm                (stm_axi_awlock  ),
    .awcachem               (stm_axi_awcache ),
    .awprotm                (stm_axi_awprot  ),
    .awqosm                 (   ),
    .awburstm               (stm_axi_awburst ),
    .wvalidm                (stm_axi_wvalid  ),
    .wreadym                (stm_axi_wready  ),
    .wuserm                 (), 
    .wdatam                 (stm_axi_wdata   ),
    .wstrbm                 (stm_axi_wstrb   ),
    .wlastm                 (stm_axi_wlast   ),
    .bvalidm                (stm_axi_bvalid  ),
    .breadym                (stm_axi_bready  ),
    .buserm                 (1'b0 ), 
    .bidm                   (stm_axi_bid     ),
    .brespm                 (stm_axi_bresp   ),
    .arvalidm               (stm_axi_arvalid ),
    .arreadym               (stm_axi_arready ),
    .aruserm                (),
    .aridm                  (stm_axi_arid    ),
    .araddrm                (stm_axi_araddr  ),
    .arregionm              (),  
    .arlenm                 (stm_axi_arlen   ),
    .arsizem                (stm_axi_arsize  ),
    .arlockm                (stm_axi_arlock  ),
    .arcachem               (stm_axi_arcache ),
    .arprotm                (stm_axi_arprot  ),
    .arqosm                 (   ),
    .arburstm               (stm_axi_arburst ),
    .rvalidm                (stm_axi_rvalid  ),
    .rreadym                (stm_axi_rready  ),
    .ruserm                 (1'b0 ), 
    .ridm                   (stm_axi_rid     ),
    .rdatam                 (stm_axi_rdata   ),
    .rrespm                 (stm_axi_rresp   ),
    .rlastm                 (stm_axi_rlast   ),
                             


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


    .dftrstdisablem          (dftrstdisable)
    );

 assign nx_slv_wakeup = debug_axis_awvalid | debug_axis_arvalid | debug_axis_wvalid;
 
 always @(posedge dbgclk or negedge reset_n)
 begin
    if(reset_n == 1'b0)
        slv_wakeup <= 1'b0;
    else
        slv_wakeup<=nx_slv_wakeup;
 end
 
 
 

 sse710_adb400_r3_axi4_slv_wrapper
    #(
      .ADDR_WIDTH       (DBG_ADDR_WIDTH),
      .DATA_WIDTH       (DBG_DATA_WIDTH),
      .AWID_WIDTH       (DBG_AWID_WIDTH),
      .ARID_WIDTH       (DBG_ARID_WIDTH),
      .AWUSER_WIDTH     (DBG_AWUSER_WIDTH),
      .WUSER_WIDTH      (DBG_WUSER_WIDTH),
      .BUSER_WIDTH      (DBG_BUSER_WIDTH),
      .ARUSER_WIDTH     (DBG_ARUSER_WIDTH),
      .RUSER_WIDTH      (DBG_RUSER_WIDTH),
      .AW_FIFO_DEPTH    (DBG_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (DBG_W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (DBG_B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (DBG_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (DBG_R_FIFO_DEPTH),
      .B_OPREG          (1),
      .R_OPREG          (1),
      .SI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH   (DBG_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH    (DBG_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH    (DBG_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH   (DBG_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH    (DBG_R_PAYLOAD_WIDTH)    
    )
  u_sse710_adb400_r3_axi4_slv_wrapper
    (
    .pwrq_permit_deny_sar_i (1'b1),

    .aclks                  (dbgclk),                   
    .aresetns               (reset_n),

    .clkqreqns_i            (dbgclk_qreqn   [1]),
    .clkqacceptns_o         (dbgclk_qacceptn[1]),
    .clkqdenys_o            (dbgclk_qdeny   [1]),
    .clkqactives_o          (dbgclk_qactive[1]),
    .pwrqreqns_i            (qreqn_axi_adb),
    .pwrqacceptns_o         (qacceptn_axi_adb ),
    .pwrqdenys_o            (qdeny_axi_adb    ),
    .pwrqactives_o          (qactive_axi_adb  ),

    .wakeups_i              (slv_wakeup),

    .awvalids               (debug_axis_awvalid ),
    .awreadys               (debug_axis_awready ),
    .awusers                (debug_axis_awuser  ),
    .awids                  (debug_axis_awid),
    .awaddrs                (debug_axis_awaddr  ),
    .awregions              (4'h0),  
    .awlens                 (debug_axis_awlen   ),
    .awsizes                (debug_axis_awsize  ),
    .awlocks                (debug_axis_awlock),
    .awcaches               (debug_axis_awcache),
    .awprots                (debug_axis_awprot  ),
    .awqoss                 (4'hf), 
    .awbursts               (debug_axis_awburst ),
   
    .wvalids                (debug_axis_wvalid  ),
    .wreadys                (debug_axis_wready  ),
    .wusers                 (1'b0), 
    .wdatas                 (debug_axis_wdata   ),
    .wstrbs                 (debug_axis_wstrb   ),
    .wlasts                 (debug_axis_wlast),
                            
    .bvalids                (debug_axis_bvalid  ),
    .breadys                (debug_axis_bready  ),
    .busers                 (  ), 
    .bids                   (debug_axis_bid),
    .bresps                 (debug_axis_bresp   ),
    .arvalids               (debug_axis_arvalid ),
    .arreadys               (debug_axis_arready ),
    .arusers                (debug_axis_aruser),
    .arids                  (debug_axis_arid  ),
    .araddrs                (debug_axis_araddr  ),
    .arregions              (4'h0),  
    .arlens                 (debug_axis_arlen   ),
    .arsizes                (debug_axis_arsize  ),
    .arlocks                (debug_axis_arlock),
    .arcaches               (debug_axis_arcache),
    .arprots                (debug_axis_arprot  ),
    .arqoss                 (4'hf), 
    .arbursts               (debug_axis_arburst ),
    .rvalids                (debug_axis_rvalid  ),
    .rreadys                (debug_axis_rready  ),
    .rusers                 (  ), 
    .rids                   (debug_axis_rid),
    .rdatas                 (debug_axis_rdata   ),
    .rresps                 (debug_axis_rresp   ),
    .rlasts                 (debug_axis_rlast   ),



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

    .dftrstdisables          (dftrstdisable)
    );

    assign hostdbg_pstrb = {4{hostdbg_pwrite}};

    css600_apbasyncbridgemstr #(
    
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
     ) u_apbhostext_mst (
        .clk_m                    (dbgclk),
        .reset_m_n                 (reset_n),
        .dftcgen                 (dftcgen),
        .psel_m                  (hostdbg_psel    ),
        .penable_m               (hostdbg_penable ),
        .paddr_m                 (hostdbg_paddr   ),
        .pwrite_m                (hostdbg_pwrite  ),
        .pwdata_m                (hostdbg_pwdata  ),
        .pprot_m                 (hostdbg_pprot   ),
        .prdata_m                (hostdbg_prdata  ),
        .pready_m                (hostdbg_pready  ),
        .pslverr_m               (hostdbg_pslverr ),
        .pwakeup_m               (hostdbg_pwakeup ),
        .clk_m_qreq_n            (dbgclk_qreqn   [2]),
        .clk_m_qaccept_n         (dbgclk_qacceptn[2]),
        .clk_m_qdeny           (dbgclk_qdeny   [2]),
        .clk_m_qactive         (dbgclk_qactive[2]),
        .apb_async_req           (hostsysdbg_async_req),
        .apb_async_req_payload   (hostsysdbg_async_req_payload),
        .apb_async_resp_payload  (hostsysdbg_async_resp_payload),
        .apb_async_ack           (hostsysdbg_async_ack)
    );


endmodule
