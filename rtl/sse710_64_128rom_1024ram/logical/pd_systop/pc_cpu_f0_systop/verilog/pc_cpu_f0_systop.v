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

module pc_cpu_f0_systop 
  #(parameter
      HOST_CPU_NUM_CORES          = 4,
      
      DEV_PREQ_DLY_CLUS         = 1,
      PCSM_PREQ_DLY_CLUS        = 1,
      ISO_CLKEN_DLY_CFG_CLUS    = 0,
      CLKEN_RST_DLY_CFG_CLUS    = 0,
      RST_HWSTAT_DLY_CFG_CLUS   = 0,
      CLKEN_ISO_DLY_CFG_CLUS    = 0,
      ISO_RST_DLY_CFG_CLUS      = 0,

 
      DEV_PREQ_DLY_CPU3        = 1,
      PCSM_PREQ_DLY_CPU3       = 1,
      ISO_CLKEN_DLY_CFG_CPU3   = 0,
      CLKEN_RST_DLY_CFG_CPU3   = 0,
      RST_HWSTAT_DLY_CFG_CPU3  = 0,
      CLKEN_ISO_DLY_CFG_CPU3   = 0,
      ISO_RST_DLY_CFG_CPU3     = 0,

 
      DEV_PREQ_DLY_CPU2        = 1,
      PCSM_PREQ_DLY_CPU2       = 1,
      ISO_CLKEN_DLY_CFG_CPU2   = 0,
      CLKEN_RST_DLY_CFG_CPU2   = 0,
      RST_HWSTAT_DLY_CFG_CPU2  = 0,
      CLKEN_ISO_DLY_CFG_CPU2   = 0,
      ISO_RST_DLY_CFG_CPU2     = 0,

 
      DEV_PREQ_DLY_CPU1        = 1,
      PCSM_PREQ_DLY_CPU1       = 1,
      ISO_CLKEN_DLY_CFG_CPU1   = 0,
      CLKEN_RST_DLY_CFG_CPU1   = 0,
      RST_HWSTAT_DLY_CFG_CPU1  = 0,
      CLKEN_ISO_DLY_CFG_CPU1   = 0,
      ISO_RST_DLY_CFG_CPU1     = 0,

 
      DEV_PREQ_DLY_CPU0        = 1,
      PCSM_PREQ_DLY_CPU0       = 1,
      ISO_CLKEN_DLY_CFG_CPU0   = 0,
      CLKEN_RST_DLY_CFG_CPU0   = 0,
      RST_HWSTAT_DLY_CFG_CPU0  = 0,
      CLKEN_ISO_DLY_CFG_CPU0   = 0,
      ISO_RST_DLY_CFG_CPU0     = 0,

      
      CPU_ADDR_WIDTH    = 40,
      CPU_DATA_WIDTH    = 128,
      CPU_AWID_WIDTH    = 8,
      CPU_ARID_WIDTH    = 8,
      CPU_AWUSER_WIDTH  = 2,
      CPU_WUSER_WIDTH   = 0,
      CPU_BUSER_WIDTH   = 0,
      CPU_ARUSER_WIDTH  = 2,
      CPU_RUSER_WIDTH   = 0,
      CPU_AW_FIFO_DEPTH = 4,
      CPU_W_FIFO_DEPTH  = 6,
      CPU_B_FIFO_DEPTH  = 2,
      CPU_AR_FIFO_DEPTH = 4,
      CPU_R_FIFO_DEPTH  = 6,
      CPU_AW_PAYLOAD_WIDTH = 316,
      CPU_W_PAYLOAD_WIDTH  = 870,
      CPU_B_PAYLOAD_WIDTH  = 20,
      CPU_AR_PAYLOAD_WIDTH = 316,
      CPU_R_PAYLOAD_WIDTH  = 834,
      GIC_ADDR_WIDTH       = 19,
      GIC_DATA_WIDTH       = 32,
      GIC_AWID_WIDTH       = 12,
      GIC_ARID_WIDTH       = 12,
      GIC_AWUSER_WIDTH     = 3,
      GIC_WUSER_WIDTH      = 0,
      GIC_BUSER_WIDTH      = 0,
      GIC_ARUSER_WIDTH     = 3,
      GIC_RUSER_WIDTH      = 0,
      GIC_AW_FIFO_DEPTH    = 4,
      GIC_W_FIFO_DEPTH     = 6,
      GIC_B_FIFO_DEPTH     = 2,
      GIC_AR_FIFO_DEPTH    = 4,
      GIC_R_FIFO_DEPTH     = 6,
      GIC_AW_PAYLOAD_WIDTH = 236,
      GIC_W_PAYLOAD_WIDTH  = 222,
      GIC_B_PAYLOAD_WIDTH  = 24,
      GIC_AR_PAYLOAD_WIDTH = 236,
      GIC_R_PAYLOAD_WIDTH  = 264
) (
input  wire aclk,
input  wire aresetn,

input  wire  [1:0] aclk_qreqn,            
output wire  [1:0] aclk_qacceptn,         
output wire  [1:0] aclk_qdeny,            
output wire  [1:0] aclk_qactive,          

input  wire ctrlclk,
input  wire ctrlclk_free,
input  wire ctrlresetn,
input  wire ppu_dbgen,

output wire         clustop_pcsm_preq_o,
output wire  [3:0]  clustop_pcsm_pstate_o,
input  wire         clustop_pcsm_paccept_i,
input  wire  [3:0]  clustop_pcsm_mode_stat_i,

output wire [CPU_AWID_WIDTH-1:0]  awid_hostcpu_axis,
output wire [CPU_ADDR_WIDTH-1:0]  awaddr_hostcpu_axis,
output wire [7:0]   awlen_hostcpu_axis,
output wire [2:0]   awsize_hostcpu_axis,
output wire [1:0]   awburst_hostcpu_axis,
output wire         awlock_hostcpu_axis,
output wire [3:0]   awcache_hostcpu_axis,
output wire [2:0]   awprot_hostcpu_axis,
output wire         awvalid_hostcpu_axis,
input  wire         awready_hostcpu_axis,
output wire [127:0] wdata_hostcpu_axis,
output wire [15:0]  wstrb_hostcpu_axis,
output wire         wlast_hostcpu_axis,
output wire         wvalid_hostcpu_axis,
input  wire         wready_hostcpu_axis,
input  wire [7:0]   bid_hostcpu_axis,
input  wire [1:0]   bresp_hostcpu_axis,
input  wire         bvalid_hostcpu_axis,
output wire         bready_hostcpu_axis,
output wire [7:0]   arid_hostcpu_axis,
output wire [39:0]  araddr_hostcpu_axis,
output wire [7:0]   arlen_hostcpu_axis,
output wire [2:0]   arsize_hostcpu_axis,
output wire [1:0]   arburst_hostcpu_axis,
output wire         arlock_hostcpu_axis,
output wire [3:0]   arcache_hostcpu_axis,
output wire [2:0]   arprot_hostcpu_axis,
output wire         arvalid_hostcpu_axis,
input  wire         arready_hostcpu_axis,
input  wire [7:0]   rid_hostcpu_axis,
input  wire [127:0] rdata_hostcpu_axis,
input  wire [1:0]   rresp_hostcpu_axis,
input  wire         rlast_hostcpu_axis,
input  wire         rvalid_hostcpu_axis,
output wire         rready_hostcpu_axis,
output wire [1:0]   awuser_hostcpu_axis,
output wire [1:0]   aruser_hostcpu_axis,
output wire [3:0]   awqos_hostcpu_axis,
output wire [3:0]   arqos_hostcpu_axis,

input  wire hostcpu_slvmustacceptreqn_async,
input  wire hostcpu_slvcandenyreqn_async,
output wire hostcpu_slvacceptn_async,
output wire hostcpu_slvdeny_async,

input  wire hostcpu_si_to_mi_wakeup_async,
output wire hostcpu_mi_to_si_wakeup_async,

input  wire [CPU_AW_FIFO_DEPTH-1:0]    hostcpu_aw_wr_ptr_async,
output wire [CPU_AW_FIFO_DEPTH-1:0]    hostcpu_aw_rd_ptr_async,
input  wire [CPU_AW_PAYLOAD_WIDTH-1:0] hostcpu_aw_payld_async,

input  wire [ CPU_W_FIFO_DEPTH-1:0]    hostcpu_w_wr_ptr_async,
output wire [ CPU_W_FIFO_DEPTH-1:0]    hostcpu_w_rd_ptr_async,
input  wire [CPU_W_PAYLOAD_WIDTH-1:0]  hostcpu_w_payld_async,

output wire [ CPU_B_FIFO_DEPTH-1:0]    hostcpu_b_wr_ptr_async,
input  wire [ CPU_B_FIFO_DEPTH-1:0]    hostcpu_b_rd_ptr_async,
output wire [CPU_B_PAYLOAD_WIDTH-1:0]  hostcpu_b_payld_async,

input  wire [CPU_AR_FIFO_DEPTH-1:0]    hostcpu_ar_wr_ptr_async,
output wire [CPU_AR_FIFO_DEPTH-1:0]    hostcpu_ar_rd_ptr_async,
input  wire [CPU_AR_PAYLOAD_WIDTH-1:0] hostcpu_ar_payld_async,

output wire [ CPU_R_FIFO_DEPTH-1:0]    hostcpu_r_wr_ptr_async,
input  wire [ CPU_R_FIFO_DEPTH-1:0]    hostcpu_r_rd_ptr_async,
output wire [CPU_R_PAYLOAD_WIDTH-1:0]  hostcpu_r_payld_async,

output wire gic_slvmustacceptreqn_async,
output wire gic_slvcandenyreqn_async,
input  wire gic_slvacceptn_async,
input  wire gic_slvdeny_async,

output wire gic_si_to_mi_wakeup_async,
input  wire gic_mi_to_si_wakeup_async,

output wire [GIC_AW_FIFO_DEPTH-1:0]    gic_aw_wr_ptr_async,
input  wire [GIC_AW_FIFO_DEPTH-1:0]    gic_aw_rd_ptr_async,
output wire [GIC_AW_PAYLOAD_WIDTH-1:0] gic_aw_payld_async,

output wire [ GIC_W_FIFO_DEPTH-1:0]   gic_w_wr_ptr_async,
input  wire [ GIC_W_FIFO_DEPTH-1:0]   gic_w_rd_ptr_async,
output wire [GIC_W_PAYLOAD_WIDTH-1:0] gic_w_payld_async,

input  wire [ GIC_B_FIFO_DEPTH-1:0]   gic_b_wr_ptr_async,
output wire [ GIC_B_FIFO_DEPTH-1:0]   gic_b_rd_ptr_async,
input  wire [GIC_B_PAYLOAD_WIDTH-1:0] gic_b_payld_async,

output wire [GIC_AR_FIFO_DEPTH-1:0]    gic_ar_wr_ptr_async,
input  wire [GIC_AR_FIFO_DEPTH-1:0]    gic_ar_rd_ptr_async,
output wire [GIC_AR_PAYLOAD_WIDTH-1:0] gic_ar_payld_async,

input  wire [ GIC_R_FIFO_DEPTH-1:0]   gic_r_wr_ptr_async,
output wire [ GIC_R_FIFO_DEPTH-1:0]   gic_r_rd_ptr_async,
input  wire [GIC_R_PAYLOAD_WIDTH-1:0] gic_r_payld_async,

                                                               
input  wire                      gic_adb_pwrq_permit_deny_sar_i,
                                                               
input  wire                      awvalid_gic_axim,
output wire                      awready_gic_axim,
input  wire [((GIC_AWUSER_WIDTH>0)?(GIC_AWUSER_WIDTH-1):0):0] awuser_gic_axim,
input  wire [((GIC_AWID_WIDTH>0)?(GIC_AWID_WIDTH-1):0):0] awid_gic_axim,
input  wire [GIC_ADDR_WIDTH-1:0]     awaddr_gic_axim,
input  wire [3:0]                awregion_gic_axim,
input  wire [7:0]                awlen_gic_axim,
input  wire [2:0]                awsize_gic_axim,
input  wire [1:0]                awburst_gic_axim,
input  wire                      awlock_gic_axim,
input  wire [3:0]                awcache_gic_axim,
input  wire [2:0]                awprot_gic_axim,
input  wire [3:0]                awqos_gic_axim,
                                                               
input  wire                      wvalid_gic_axim,    
output wire                      wready_gic_axim,    
input  wire [GIC_DATA_WIDTH-1:0] wdata_gic_axim,     
input  wire                      wlast_gic_axim,     
input  wire [(GIC_DATA_WIDTH/8)-1:0] wstrb_gic_axim,
                                                               
output wire                      bvalid_gic_axim,                         
input  wire                      bready_gic_axim,                         
output wire [1:0]                bresp_gic_axim,                          
output wire [((GIC_AWID_WIDTH>0)?(GIC_AWID_WIDTH-1):0):0] bid_gic_axim,
                                                               
input  wire                      arvalid_gic_axim,
output wire                      arready_gic_axim,
input  wire [((GIC_ARUSER_WIDTH>0)?(GIC_ARUSER_WIDTH-1):0):0] aruser_gic_axim,
input  wire [((GIC_ARID_WIDTH>0)?(GIC_ARID_WIDTH-1):0):0]     arid_gic_axim,
input  wire [GIC_ADDR_WIDTH-1:0] araddr_gic_axim,
input  wire [3:0]                arregion_gic_axim,
input  wire [7:0]                arlen_gic_axim,
input  wire [2:0]                arsize_gic_axim,
input  wire [1:0]                arburst_gic_axim,
input  wire                      arlock_gic_axim,
input  wire [3:0]                arcache_gic_axim,
input  wire [2:0]                arprot_gic_axim,
input  wire [3:0]                arqos_gic_axim,
                                                               
output wire                      rvalid_gic_axim,
input  wire                      rready_gic_axim,
output wire [GIC_DATA_WIDTH-1:0] rdata_gic_axim,
output wire [1:0]                rresp_gic_axim,
output wire                      rlast_gic_axim,
output wire [((GIC_ARID_WIDTH>0)?(GIC_ARID_WIDTH-1):0):0] rid_gic_axim,

input  wire        pc_cpu_ppu_psel_i,
input  wire        pc_cpu_ppu_penable_i,
input  wire [31:0] pc_cpu_ppu_paddr_i,
input  wire        pc_cpu_ppu_pwrite_i,
input  wire [31:0] pc_cpu_ppu_pwdata_i,
output wire [31:0] pc_cpu_ppu_prdata_o,
output wire        pc_cpu_ppu_pready_o,
output wire        pc_cpu_ppu_pslverr_o,
input  wire [2:0]  pc_cpu_ppu_pprot_i,


    

input  wire [HOST_CPU_NUM_CORES-1:0] host_cpu_boot_msk_boot_msk,
input  wire                host_cpu_clus_pwr_req_pwr_req,
input  wire                host_cpu_clus_pwr_req_mem_ret_r,
input  wire                bsys_pwr_req_wakeup_en,
input  wire                gic_wakeup,
input  wire                system_interrupt_wakeup_clus,
input  wire                router_interrupt_wakeup_clus,
input  wire [3:0]          hostcpu_corewakeup,
input  wire                axiap_csyspwrupreq_1,
output wire                axiap_csyspwrupack_1,
input  wire                hostrom_cdbgpwrupreq,
output wire                hostrom_cdbgpwrupack,

input  wire [3:0]          hostcpu_dbgnopwrdwn,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_smpen,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_wakeupreq,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_dbgrstreq,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_warmrstreq,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_standbywfi,
input  wire                hostcpu_standbywfil2,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_dbgpwrupreq,
output wire [HOST_CPU_NUM_CORES-1:0] hostcpu_dbgpwrdup,

output wire                hostcpu_l2flushreq,
input  wire                hostcpu_l2flushdone,
output wire                hostcpu_l2rstdisable,

input  wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_cpuqactive,

output wire [HOST_CPU_NUM_CORES-1:0]   dev_preq_core_power_handshake,
output wire [4*HOST_CPU_NUM_CORES-1:0] dev_pstate_core_power_handshake,
input  wire [HOST_CPU_NUM_CORES-1:0]   dev_paccept_core_power_handshake,
input  wire [HOST_CPU_NUM_CORES-1:0]   dev_pdeny_core_power_handshake,

output wire [HOST_CPU_NUM_CORES-1:0]   dev_preq_core_warmrst_check,
output wire [4*HOST_CPU_NUM_CORES-1:0] dev_pstate_core_warmrst_check,
input  wire [HOST_CPU_NUM_CORES-1:0]   dev_paccept_core_warmrst_check,
input  wire [HOST_CPU_NUM_CORES-1:0]   dev_pdeny_core_warmrst_check,


output wire  [HOST_CPU_NUM_CORES-1:0]  core_retresetn,
output wire  [HOST_CPU_NUM_CORES-1:0]  core_poresetn,

output wire                clustop_warmresetn,
output wire                clustop_poresetn,

output wire                clustop_ppu_interrupt_o,
output wire [HOST_CPU_NUM_CORES-1:0] core_ppu_interrupt_o,
output wire                clustop_devclken_o,

input  wire  [5:0]         ctrlclk_qreqn,    
output wire  [5:0]         ctrlclk_qacceptn_o, 
output wire  [5:0]         ctrlclk_qdeny_o,    
output wire  [5:0]         ctrlclk_qactive_o,

output wire  clustop_internal_l2_qreqn,
input  wire  clustop_internal_l2_qacceptn,
input  wire  clustop_internal_l2_qdeny,
input  wire  clustop_internal_l2_qactive,


output wire  hostcpu_axim_egress_qreqn,
input  wire  hostcpu_axim_egress_qacceptn,
input  wire  hostcpu_axim_egress_qdeny,
input  wire  hostcpu_axim_egress_qactive,

output wire  hostcpu_dbgtrace_egress_qreqn,
input  wire  hostcpu_dbgtrace_egress_qacceptn,
input  wire  hostcpu_dbgtrace_egress_qdeny,

output wire  hostcpu_dbgtrace_ingress_qreqn,
input  wire  hostcpu_dbgtrace_ingress_qacceptn,
input  wire  hostcpu_dbgtrace_ingress_qdeny,
input  wire  hostcpu_dbgtrace_ingress_qactive,

output wire  clustop_ingress_cti_double_bridge_qreqn,
input  wire  clustop_ingress_cti_double_bridge_qacceptn,
input  wire  clustop_ingress_cti_double_bridge_qdeny,
input  wire  clustop_ingress_cti_double_bridge_qactive,

input  wire  hostcpu_ctichout_active,

output wire  CLUSTOPEGRESSQREQn,
input  wire  CLUSTOPEGRESSQACCEPTn,
input  wire  CLUSTOPEGRESSQDENY,
input  wire  CLUSTOPEGRESSQACTIVE,

output wire  CLUSTOPINGRESSQREQn,
input  wire  CLUSTOPINGRESSQACCEPTn,
input  wire  CLUSTOPINGRESSQDENY,
input  wire  CLUSTOPINGRESSQACTIVE,

input  wire   systop_ingress_qreqn,
output wire   systop_ingress_qacceptn,
output wire   systop_ingress_qdeny,
output wire   systop_ingress_qactive,

output wire   pc_cpu_ctrlclk_qactive,


output wire  [15:0] clustop_ppuhwstat_o,


  
input wire  [9:0]     modify_lock_req,
output wire  [9:0]     modify_lock_ack,
output reg [4:0]      host_lock,
  
input  wire                dftrstdisable,
input  wire [HOST_CPU_NUM_CORES-1:0] dftpwrupcpu,
input  wire [HOST_CPU_NUM_CORES-1:0] dftretdisable,
input  wire                clustop_dftisodisable,
input  wire [HOST_CPU_NUM_CORES-1:0] coreppu_dftisodisable,
input  wire                dftcgen
);
wire  [16*HOST_CPU_NUM_CORES-1:0]  core_ppuhwstat;

wire clustop_ppu_pactive_on_bit;
wire clustop_ppu_pactive_func_ret_bit;
wire clustop_ppu_pactive_func_ret_bit_ss;
wire clustop_ppu_pactive_func_ret_bit_en;
wire clustop_ppu_pactive_func_ret_bit_gated;
wire host_cpu_clus_pwr_req_mem_ret_ss;

wire [4:0] ctrlclk_qacceptn;
wire [4:0] ctrlclk_qdeny;
wire [4:0] ctrlclk_qactive;

wire gic_axis_ingress_qreqn;
wire gic_axis_ingress_qacceptn;
wire gic_axis_ingress_qdeny;
wire gic_axis_ingress_qactive;

wire hostcpu_dbgapb_ingress_qreqn;
wire hostcpu_dbgapb_ingress_qacceptn;
wire hostcpu_dbgapb_ingress_qdeny;
wire hostcpu_dbgapb_ingress_qactive;

wire systop_ingress_qreqn_ss;

reg [9:0] last_clustop_ppuhwstat;
 
reg [9:0] last_core0_ppuhwstat;
 
reg [9:0] last_core1_ppuhwstat;
 
reg [9:0] last_core2_ppuhwstat;
 
reg [9:0] last_core3_ppuhwstat;

wire          clustop_lpd_p_sequencer_qactive_ctrlclk;
wire          clustop_egress_p2q_clkqactive_ctrlclk;
wire          clustop_internal_l2_combined_p2q_clkqactive_ctrlclk;
wire          clustop_ingress_p2q_clkqactive_ctrlclk;
wire          clustop_ingress_lpd_q_qactive_ctrlclk;
wire          hostrom_cdbgpwrupreq_p2q_clkqactive_ctrlclk;
wire          clustop_egress_lpd_q_qactive_ctrlclk;
wire          qactive_apb_arbiter_ctrlclk;
wire          clustop_l2_lpd_q_qactive_ctrlclk;
wire          axiap_csyspwrup_reqack_clkqactive_ctrlclk;
wire          hostrom_cdbgpwrup_reqack_clkqactive_ctrlclk;
wire          clustop_core_dependency_qactive;
wire          core_pactive_sync_active_ctrclk;
reg           clustop_lock_logic_qactive;
reg  [HOST_CPU_NUM_CORES-1:0] core_lock_logic_qactive;
wire          systop_clustop_dependency_qactive;
wire          core_p_network_ctrlclk_clkqactive;
wire          clustop_pactive_on_glitch_qactive_ctrlclk;
wire [HOST_CPU_NUM_CORES-1:0] core_pactive_on_glitch_qactive_ctrlclk;

 
                  
assign ctrlclk_qactive_o[4:0] =    ((HOST_CPU_NUM_CORES == 4) ?  ctrlclk_qactive :
                                   (HOST_CPU_NUM_CORES == 3) ? {ctrlclk_qactive[4],1'b0  , ctrlclk_qactive[2:0]}:
                                   (HOST_CPU_NUM_CORES == 2) ? {ctrlclk_qactive[4],2'b00 , ctrlclk_qactive[1:0]}:
                                                     {ctrlclk_qactive[4],3'b000, ctrlclk_qactive[0]  });

assign ctrlclk_qacceptn_o[4:0] = (HOST_CPU_NUM_CORES == 4) ?  ctrlclk_qacceptn[4:0] :
                                 (HOST_CPU_NUM_CORES == 3) ? {ctrlclk_qacceptn[4], ctrlclk_qreqn[3]  , ctrlclk_qacceptn[2:0]}:
                                 (HOST_CPU_NUM_CORES == 2) ? {ctrlclk_qacceptn[4], ctrlclk_qreqn[3:2], ctrlclk_qacceptn[1:0]}:
                                                   {ctrlclk_qacceptn[4], ctrlclk_qreqn[3:1], ctrlclk_qacceptn[0]};

assign ctrlclk_qdeny_o[4:0] =  (HOST_CPU_NUM_CORES == 4) ?  ctrlclk_qdeny[4:0] :
                               (HOST_CPU_NUM_CORES == 3) ? {ctrlclk_qdeny[4],1'b0  , ctrlclk_qdeny[2:0]}:
                               (HOST_CPU_NUM_CORES == 2) ? {ctrlclk_qdeny[4],2'b00 , ctrlclk_qdeny[1:0]}:
                                                 {ctrlclk_qdeny[4],3'b000, ctrlclk_qdeny[0]};

                            
  localparam NUM_PPUS = 1 + HOST_CPU_NUM_CORES; 

  wire [HOST_CPU_NUM_CORES-1:0]    ppu_core_psel_i;
  wire [HOST_CPU_NUM_CORES-1:0]    ppu_core_penable_i;
  wire [32*HOST_CPU_NUM_CORES-1:0] ppu_core_paddr_i;
  wire [HOST_CPU_NUM_CORES-1:0]    ppu_core_pwrite_i;
  wire [32*HOST_CPU_NUM_CORES-1:0] ppu_core_pwdata_i;
  wire [32*HOST_CPU_NUM_CORES-1:0] ppu_core_prdata_o;
  wire [HOST_CPU_NUM_CORES-1:0]    ppu_core_pready_o;
  wire [HOST_CPU_NUM_CORES-1:0]    ppu_core_pslverr_o;

  wire          ppu_clustop_psel_i;
  wire          ppu_clustop_penable_i;
  wire  [31:0]  ppu_clustop_paddr_i;
  wire          ppu_clustop_pwrite_i;
  wire  [31:0]  ppu_clustop_pwdata_i;
  wire  [31:0]  ppu_clustop_prdata_o;
  wire          ppu_clustop_pready_o;
  wire          ppu_clustop_pslverr_o;

  wire  [4:0]   apbarb_sel_current_i;
  wire  [31:0]  apbarb_paddr_current_o;
  wire          ppu_dbgen_ss;
  wire          ppu_dbgen_sync_active;

 arm_element_cdc_capt_sync u_dbgen_sync (
    .clk     (ctrlclk),
    .nreset  (ctrlresetn),
    .d_async (ppu_dbgen),
    .q       (ppu_dbgen_ss)
  );

  arm_element_std_xor2 u_ppudbgen_sync_qactive (
  .A (ppu_dbgen),
  .B (ppu_dbgen_ss),

  .Y (ppu_dbgen_sync_active)
  );


  wire ppu_dbg_reg_violation;
  assign ppu_dbg_reg_violation = ppu_dbgen_ss ? 1'b0 : pc_cpu_ppu_pwrite_i && ( (apbarb_paddr_current_o[11:0] == 12'h020) || (apbarb_paddr_current_o[11:0] == 12'h024) ); 
 
  assign apbarb_sel_current_i =   ppu_dbg_reg_violation                                           ? 5'b00000 :
                                ( apbarb_paddr_current_o[18:12] == 7'b000_0000)                   ? 5'b00001 : 
                                ((apbarb_paddr_current_o[18:12] == 7'b001_0000) & (HOST_CPU_NUM_CORES > 0)) ? 5'b00010 :
                                ((apbarb_paddr_current_o[18:12] == 7'b010_0000) & (HOST_CPU_NUM_CORES > 1)) ? 5'b00100 :
                                ((apbarb_paddr_current_o[18:12] == 7'b011_0000) & (HOST_CPU_NUM_CORES > 2)) ? 5'b01000 :
                                ((apbarb_paddr_current_o[18:12] == 7'b100_0000) & (HOST_CPU_NUM_CORES > 3)) ? 5'b10000 :
                                5'b00000;

  assign ppu_core_paddr_i   = {HOST_CPU_NUM_CORES{pc_cpu_ppu_paddr_i}};
  assign ppu_core_penable_i = {HOST_CPU_NUM_CORES{pc_cpu_ppu_penable_i}};
  assign ppu_core_pwrite_i  = {HOST_CPU_NUM_CORES{pc_cpu_ppu_pwrite_i}}; 
  assign ppu_core_pwdata_i  = {HOST_CPU_NUM_CORES{pc_cpu_ppu_pwdata_i}};

  assign ppu_clustop_paddr_i   = pc_cpu_ppu_paddr_i;
  assign ppu_clustop_penable_i = pc_cpu_ppu_penable_i;
  assign ppu_clustop_pwrite_i  = pc_cpu_ppu_pwrite_i;
  assign ppu_clustop_pwdata_i  = pc_cpu_ppu_pwdata_i;

  
 
  wire         clustop_dev_preq_o;
  wire  [3:0]  clustop_dev_pstate_o;
  wire         clustop_dev_paccept_i;
  wire         clustop_dev_pdeny_i;
 
  
  
  wire         clustop_isolaten_o;
  wire         clustop_isolaten_ppu;

  wire  [3:0]  clustop_ecorevnum_i = 4'b0000; 


  sse710_adb400_r3_axi4_mst_wrapper
    #(
      .ADDR_WIDTH       (CPU_ADDR_WIDTH   ),
      .DATA_WIDTH       (CPU_DATA_WIDTH   ),
      .AWID_WIDTH       (CPU_AWID_WIDTH   ),
      .ARID_WIDTH       (CPU_ARID_WIDTH   ),
      .AWUSER_WIDTH     (CPU_AWUSER_WIDTH ),
      .WUSER_WIDTH      (CPU_WUSER_WIDTH  ),
      .BUSER_WIDTH      (CPU_BUSER_WIDTH  ),
      .ARUSER_WIDTH     (CPU_ARUSER_WIDTH ),
      .RUSER_WIDTH      (CPU_RUSER_WIDTH  ),
      .AW_FIFO_DEPTH    (CPU_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (CPU_W_FIFO_DEPTH ),
      .B_FIFO_DEPTH     (CPU_B_FIFO_DEPTH ),
      .AR_FIFO_DEPTH    (CPU_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (CPU_R_FIFO_DEPTH ),
      .AW_OPREG         (1),
      .W_OPREG          (1),
      .AR_OPREG         (1),
      .MI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH (CPU_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (CPU_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (CPU_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (CPU_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (CPU_R_PAYLOAD_WIDTH)
      
    )
  u_sse710_adb400_r3_axi4_mst_wrapper
    (
    .aclkm                   (aclk),                   
    .aresetnm                (aresetn),

    .clkqreqnm_i             (aclk_qreqn[0]   ),
    .clkqacceptnm_o          (aclk_qacceptn[0]),
    .clkqdenym_o             (aclk_qdeny[0]   ),
    .clkqactivem_o           (aclk_qactive[0] ),

    .wakeupm_o               ( ),

    .awvalidm                (awvalid_hostcpu_axis ),
    .awreadym                (awready_hostcpu_axis ),
    .awuserm                 (awuser_hostcpu_axis  ),
    .awidm                   (awid_hostcpu_axis    ),
    .awaddrm                 (awaddr_hostcpu_axis  ),
    .awregionm               (),  
    .awlenm                  (awlen_hostcpu_axis   ),
    .awsizem                 (awsize_hostcpu_axis  ),
    .awlockm                 (awlock_hostcpu_axis  ),
    .awcachem                (awcache_hostcpu_axis ),
    .awprotm                 (awprot_hostcpu_axis  ),
    .awqosm                  (awqos_hostcpu_axis   ),
    .awburstm                (awburst_hostcpu_axis ),
    .wvalidm                 (wvalid_hostcpu_axis  ),
    .wreadym                 (wready_hostcpu_axis  ),
    .wuserm                  (), 
    .wdatam                  (wdata_hostcpu_axis   ),
    .wstrbm                  (wstrb_hostcpu_axis   ),
    .wlastm                  (wlast_hostcpu_axis   ),
    .bvalidm                 (bvalid_hostcpu_axis  ),
    .breadym                 (bready_hostcpu_axis  ),
    .buserm                  (1'b0 ), 
    .bidm                    (bid_hostcpu_axis     ),
    .brespm                  (bresp_hostcpu_axis   ),
    .arvalidm                (arvalid_hostcpu_axis ),
    .arreadym                (arready_hostcpu_axis ),
    .aruserm                 (aruser_hostcpu_axis  ),
    .aridm                   (arid_hostcpu_axis    ),
    .araddrm                 (araddr_hostcpu_axis  ),
    .arregionm               (),  
    .arlenm                  (arlen_hostcpu_axis   ),
    .arsizem                 (arsize_hostcpu_axis  ),
    .arlockm                 (arlock_hostcpu_axis  ),
    .arcachem                (arcache_hostcpu_axis ),
    .arprotm                 (arprot_hostcpu_axis  ),
    .arqosm                  (arqos_hostcpu_axis   ),
    .arburstm                (arburst_hostcpu_axis ),
    .rvalidm                 (rvalid_hostcpu_axis  ),
    .rreadym                 (rready_hostcpu_axis  ),
    .ruserm                  (1'b0 ), 
    .ridm                    (rid_hostcpu_axis     ),
    .rdatam                  (rdata_hostcpu_axis   ),
    .rrespm                  (rresp_hostcpu_axis   ),
    .rlastm                  (rlast_hostcpu_axis   ),
                             
    .slvmustacceptreqn_async (hostcpu_slvmustacceptreqn_async),
    .slvcandenyreqn_async    (hostcpu_slvcandenyreqn_async),
    .slvacceptn_async        (hostcpu_slvacceptn_async),
    .slvdeny_async           (hostcpu_slvdeny_async),
    .si_to_mi_wakeup_async   (hostcpu_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async   (hostcpu_mi_to_si_wakeup_async),

    .aw_wr_ptr_async         (hostcpu_aw_wr_ptr_async),
    .aw_rd_ptr_async         (hostcpu_aw_rd_ptr_async),
    .aw_payld_async          (hostcpu_aw_payld_async),
    .w_wr_ptr_async          (hostcpu_w_wr_ptr_async),
    .w_rd_ptr_async          (hostcpu_w_rd_ptr_async),
    .w_payld_async           (hostcpu_w_payld_async),
    .b_wr_ptr_async          (hostcpu_b_wr_ptr_async),
    .b_rd_ptr_async          (hostcpu_b_rd_ptr_async),
    .b_payld_async           (hostcpu_b_payld_async),
    .ar_wr_ptr_async         (hostcpu_ar_wr_ptr_async),
    .ar_rd_ptr_async         (hostcpu_ar_rd_ptr_async),
    .ar_payld_async          (hostcpu_ar_payld_async),
    .r_wr_ptr_async          (hostcpu_r_wr_ptr_async),
    .r_rd_ptr_async          (hostcpu_r_rd_ptr_async),
    .r_payld_async           (hostcpu_r_payld_async),


    .dftrstdisablem          (dftrstdisable)
    );


reg  gic_adb_wakeups;
wire gic_adb_wakeups_int;

always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    gic_adb_wakeups <= 1'b0;
  end
  else
  begin
    gic_adb_wakeups <= gic_adb_wakeups_int; 
  end
end

arm_element_std_or3 u_gic_adb_wakeups_or3 (
  .A (awvalid_gic_axim),
  .B (arvalid_gic_axim),
  .C (wvalid_gic_axim),

  .Y (gic_adb_wakeups_int)
);

  sse710_adb400_r3_axi4_slv_wrapper
    #(
      .ADDR_WIDTH       (GIC_ADDR_WIDTH),
      .DATA_WIDTH       (GIC_DATA_WIDTH),
      .AWID_WIDTH       (GIC_AWID_WIDTH),
      .ARID_WIDTH       (GIC_ARID_WIDTH),
      .AWUSER_WIDTH     (GIC_AWUSER_WIDTH),
      .WUSER_WIDTH      (GIC_WUSER_WIDTH),
      .BUSER_WIDTH      (GIC_BUSER_WIDTH),
      .ARUSER_WIDTH     (GIC_ARUSER_WIDTH),
      .RUSER_WIDTH      (GIC_RUSER_WIDTH),
      .AW_FIFO_DEPTH    (GIC_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (GIC_W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (GIC_B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (GIC_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (GIC_R_FIFO_DEPTH),
      .B_OPREG          (1),
      .R_OPREG          (1),
      .SI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH (GIC_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (GIC_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (GIC_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (GIC_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (GIC_R_PAYLOAD_WIDTH)
    )
  u_sse710_adb400_r3_axi4_slv_wrapper
    (
    .pwrq_permit_deny_sar_i  (gic_adb_pwrq_permit_deny_sar_i),

    .aclks                   (aclk),                   
    .aresetns                (aresetn),

    .clkqreqns_i             (aclk_qreqn[1]   ),
    .clkqacceptns_o          (aclk_qacceptn[1]),
    .clkqdenys_o             (aclk_qdeny[1]   ),
    .clkqactives_o           (aclk_qactive[1] ),
    
    .pwrqreqns_i             (gic_axis_ingress_qreqn   ),
    .pwrqacceptns_o          (gic_axis_ingress_qacceptn),
    .pwrqdenys_o             (gic_axis_ingress_qdeny   ),
    .pwrqactives_o           (gic_axis_ingress_qactive ),

    .wakeups_i               (gic_adb_wakeups),

    .awvalids                (awvalid_gic_axim ),
    .awreadys                (awready_gic_axim ),
    .awusers                 (awuser_gic_axim  ),
    .awids                   (awid_gic_axim    ),
    .awaddrs                 (awaddr_gic_axim  ),
    .awregions               (4'h0),  
    .awlens                  (awlen_gic_axim   ),
    .awsizes                 (awsize_gic_axim  ),
    .awlocks                 (1'b0),
    .awcaches                (4'h0),
    .awprots                 (awprot_gic_axim  ),
    .awqoss                  (4'hf), 
    .awbursts                (awburst_gic_axim ),

    .wvalids                 (wvalid_gic_axim  ),
    .wreadys                 (wready_gic_axim  ),
    .wusers                  (1'b0), 
    .wdatas                  (wdata_gic_axim   ),
    .wstrbs                  (wstrb_gic_axim   ),
    .wlasts                  (wlast_gic_axim   ),

    .bvalids                 (bvalid_gic_axim  ),
    .breadys                 (bready_gic_axim  ),
    .busers                  (  ), 
    .bids                    (bid_gic_axim     ),
    .bresps                  (bresp_gic_axim   ),

    .arvalids                (arvalid_gic_axim ),
    .arreadys                (arready_gic_axim ),
    .arusers                 (aruser_gic_axim  ),
    .arids                   (arid_gic_axim    ),
    .araddrs                 (araddr_gic_axim  ),
    .arregions               (4'h0),  
    .arlens                  (arlen_gic_axim   ),
    .arsizes                 (arsize_gic_axim  ),
    .arlocks                 (1'b0),
    .arcaches                (4'h0),
    .arprots                 (arprot_gic_axim  ),
    .arqoss                  (4'hf), 
    .arbursts                (arburst_gic_axim ),

    .rvalids                 (rvalid_gic_axim  ),
    .rreadys                 (rready_gic_axim  ),
    .rusers                  (  ), 
    .rids                    (rid_gic_axim     ),
    .rdatas                  (rdata_gic_axim   ),
    .rresps                  (rresp_gic_axim   ),
    .rlasts                  (rlast_gic_axim   ),

    .slvmustacceptreqn_async (gic_slvmustacceptreqn_async),
    .slvcandenyreqn_async    (gic_slvcandenyreqn_async),
    .slvacceptn_async        (gic_slvacceptn_async),
    .slvdeny_async           (gic_slvdeny_async),
    .si_to_mi_wakeup_async   (gic_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async   (gic_mi_to_si_wakeup_async),

    .aw_wr_ptr_async         (gic_aw_wr_ptr_async),
    .aw_rd_ptr_async         (gic_aw_rd_ptr_async),
    .aw_payld_async          (gic_aw_payld_async),
    .w_wr_ptr_async          (gic_w_wr_ptr_async),
    .w_rd_ptr_async          (gic_w_rd_ptr_async),
    .w_payld_async           (gic_w_payld_async),
    .b_wr_ptr_async          (gic_b_wr_ptr_async),
    .b_rd_ptr_async          (gic_b_rd_ptr_async),
    .b_payld_async           (gic_b_payld_async),
    .ar_wr_ptr_async         (gic_ar_wr_ptr_async),
    .ar_rd_ptr_async         (gic_ar_rd_ptr_async),
    .ar_payld_async          (gic_ar_payld_async),
    .r_wr_ptr_async          (gic_r_wr_ptr_async),
    .r_rd_ptr_async          (gic_r_rd_ptr_async),
    .r_payld_async           (gic_r_payld_async),

    .dftrstdisables          (dftrstdisable)
    );

  apb4_arbiter
    #(
      .SLAVE_CNT (NUM_PPUS)
    )
  u_pc_cpu_apb_ic (
    .clk                  (ctrlclk),
    .resetn               (ctrlresetn),

    .paddr_s              (pc_cpu_ppu_paddr_i),
    .psel_s               (pc_cpu_ppu_psel_i),
    .pprot_s              (pc_cpu_ppu_pprot_i),
    .penable_s            (pc_cpu_ppu_penable_i),
    .pready_s             (pc_cpu_ppu_pready_o),
    .prdata_s             (pc_cpu_ppu_prdata_o),
    .pslverr_s            (pc_cpu_ppu_pslverr_o),

    .psel_m               ({ppu_core_psel_i,ppu_clustop_psel_i}),
    .pready_m             ({ppu_core_pready_o,ppu_clustop_pready_o}),
    .prdata_m             ({ppu_core_prdata_o,ppu_clustop_prdata_o}),
    .pslverr_m            ({ppu_core_pslverr_o,ppu_clustop_pslverr_o}),
    
    .addr_arb             (apbarb_paddr_current_o),
    .sel_arb              (apbarb_sel_current_i[NUM_PPUS-1:0]),

    .slv_sec              ({NUM_PPUS{1'b1}}),

    .qactive              (qactive_apb_arbiter_ctrlclk)

  );

  

  wire [HOST_CPU_NUM_CORES-1:0] boot_mask_ss;


  wire          clustop_egress_preq_o;
  wire [3:0]    clustop_egress_pstate_o;
  wire [31:0]   clustop_egress_pactive_i;
  wire          clustop_egress_paccept_i;
  wire          clustop_egress_pdeny_i;

  wire          clustop_internal_l2_preq_o;
  wire [3:0]    clustop_internal_l2_pstate_o;
  wire [31:0]   clustop_internal_l2_pactive_i;
  wire          clustop_internal_l2_paccept_i;
  wire          clustop_internal_l2_pdeny_i;

  wire          clustop_ingress_preq_o;
  wire [3:0]    clustop_ingress_pstate_o;
  wire [31:0]   clustop_ingress_pactive_i;
  wire          clustop_ingress_paccept_i;
  wire          clustop_ingress_pdeny_i;

  wire        hostrom_cdbgpwrupreq_preq_o;
  wire [3:0]  hostrom_cdbgpwrupreq_pstate_o;
  wire [31:0] hostrom_cdbgpwrupreq_pactive_i;
  wire        hostrom_cdbgpwrupreq_paccept_i;
  wire        hostrom_cdbgpwrupreq_pdeny_i;


  wire  clustop_egress_qreqn;
  wire  clustop_egress_qacceptn;
  wire  clustop_egress_qdeny;
  wire  clustop_egress_qactive;

  wire  clustop_ingress_qreqn;
  wire  clustop_ingress_qacceptn;
  wire  clustop_ingress_qdeny; 
  wire  clustop_ingress_qactive;

  assign clustop_isolaten_o    = clustop_isolaten_ppu | clustop_dftisodisable;

  pck600_ppu_sse710_clus   
    #(  .DEV_PREQ_DLY       (DEV_PREQ_DLY_CLUS      ),
        .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_CLUS     ),
        .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_CLUS ),
        .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_CLUS ),
        .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_CLUS),
        .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_CLUS ),
        .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_CLUS   )                    
    ) u_clustop_ppu (

    .clk                 (ctrlclk),
    .reset_n             (ctrlresetn),
                       
                       
    .dftcgen             (dftcgen),
    .dftisodisable       (clustop_dftisodisable),
    .dftrstdisable       (dftrstdisable),
                       
                       
    .psel_i              (ppu_clustop_psel_i),
    .penable_i           (ppu_clustop_penable_i),
    .paddr_i             (ppu_clustop_paddr_i),
    .pwrite_i            (ppu_clustop_pwrite_i),
    .pwdata_i            (ppu_clustop_pwdata_i),
    .prdata_o            (ppu_clustop_prdata_o),
    .pready_o            (ppu_clustop_pready_o),
    .pslverr_o           (ppu_clustop_pslverr_o),
    .pwakeup_i           (ppu_clustop_psel_i),                        
                       
    .irq_o               (clustop_ppu_interrupt_o),
                       
                       
    .dev_preq_o          (clustop_dev_preq_o),
    .dev_pstate_o        (clustop_dev_pstate_o),
    .dev_paccept_i       (clustop_dev_paccept_i),
    .dev_pdeny_i         (clustop_dev_pdeny_i),
    .dev_pactive_i       ({1'b0,1'b0,clustop_ppu_pactive_on_bit,clustop_ppu_pactive_func_ret_bit_gated,1'b0,1'b0,1'b0,1'b0,host_cpu_clus_pwr_req_mem_ret_ss,1'b0,1'b1}),
                       
                       
    .ppuhwstat_o         (clustop_ppuhwstat_o),
    .devclken_o          (clustop_devclken_o),
    .devemuclken_o       (),
    .devisolaten_o       (clustop_isolaten_ppu),
    .devemuisolaten_o    (),
    .devwarmresetn_o     (clustop_warmresetn),
    .devretresetn_o      ( ),
    .devporesetn_o       (clustop_poresetn),
                       
                       
    .pcsm_preq_o         (clustop_pcsm_preq_o),
    .pcsm_pstate_o       (clustop_pcsm_pstate_o),
    .pcsm_paccept_i      (clustop_pcsm_paccept_i),
    .pcsm_mode_stat_i    (clustop_pcsm_mode_stat_i),
                       
                       
    .ppuclk_qreqn_i      (ctrlclk_qreqn[4]),
    .ppuclk_qacceptn_o   (ctrlclk_qacceptn[4]),
    .ppuclk_qdeny_o      (ctrlclk_qdeny[4]),
    .ppuclk_qactive_o    (ctrlclk_qactive[4]),
                       
                       
    .ecorevnum_i         (clustop_ecorevnum_i)

  );


  pck600_lpd_p_sse710_clustop u_clustop_p_ch_sequencer (

    .clk            (ctrlclk),
    .reset_n        (ctrlresetn),
         
    .ctrl_preq_i    (clustop_dev_preq_o),
    .ctrl_pstate_i  (clustop_dev_pstate_o),
    .ctrl_pactive_o ( ),
    .ctrl_paccept_o (clustop_dev_paccept_i),
    .ctrl_pdeny_o   (clustop_dev_pdeny_i),
  
    .dev0_preq_o    (clustop_egress_preq_o),
    .dev0_pstate_o  (clustop_egress_pstate_o),
    .dev0_pactive_i (clustop_egress_pactive_i[10:0]),
    .dev0_paccept_i (clustop_egress_paccept_i),
    .dev0_pdeny_i   (clustop_egress_pdeny_i),
  
    
    .dev1_preq_o    (clustop_internal_l2_preq_o),
    .dev1_pstate_o  (clustop_internal_l2_pstate_o),
    .dev1_pactive_i (clustop_internal_l2_pactive_i[10:0]),
    .dev1_paccept_i (clustop_internal_l2_paccept_i),
    .dev1_pdeny_i   (clustop_internal_l2_pdeny_i),
  
    
    .dev2_preq_o    (clustop_ingress_preq_o),
    .dev2_pstate_o  (clustop_ingress_pstate_o),
    .dev2_pactive_i (clustop_ingress_pactive_i[10:0]),
    .dev2_paccept_i (clustop_ingress_paccept_i),
    .dev2_pdeny_i   (clustop_ingress_pdeny_i),

    .dev3_preq_o    (hostrom_cdbgpwrupreq_preq_o),
    .dev3_pstate_o  (hostrom_cdbgpwrupreq_pstate_o),
    .dev3_pactive_i (hostrom_cdbgpwrupreq_pactive_i[10:0]),
    .dev3_paccept_i (hostrom_cdbgpwrupreq_paccept_i),
    .dev3_pdeny_i   (hostrom_cdbgpwrupreq_pdeny_i),

    .clk_qactive_o  (clustop_lpd_p_sequencer_qactive_ctrlclk),

    .dftcgen        (dftcgen)
  );


  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b1111_1101_1111_0000),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_clustop_egress_p2q (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (clustop_egress_preq_o),
    .ctrl_pstate_i    ({4'b0000,clustop_egress_pstate_o}),
    .ctrl_paccept_o   (clustop_egress_paccept_i),
    .ctrl_pdeny_o     (clustop_egress_pdeny_i),
    .ctrl_pactive_o   (clustop_egress_pactive_i),

    .dev_qreqn_o      (clustop_egress_qreqn   ),
    .dev_qacceptn_i   (clustop_egress_qacceptn),
    .dev_qdeny_i      (clustop_egress_qdeny   ),
    .dev_qactive_i    (clustop_egress_qactive ),

    .clk_qactive_o    (clustop_egress_p2q_clkqactive_ctrlclk),

    .dftcgen          (dftcgen)
  );

  pck600_lpd_q #(
    .SEQUENCER (0),
    .NUM_QCHL  (3),
    .CTRL_Q_CH_SYNC (0),
    .DEV_Q_CH_SYNC  (1),
    .ACTIVE_DENY (0)
  ) u_clustop_egress_lpd_q (
    .clk  (ctrlclk),
    .reset_n (ctrlresetn),

    .ctrl_qreqn_i (clustop_egress_qreqn),
    .ctrl_qacceptn_o (clustop_egress_qacceptn),
    .ctrl_qdeny_o (clustop_egress_qdeny),
    .ctrl_qactive_o (clustop_egress_qactive),

    .dev_qreqn_o    ({hostcpu_axim_egress_qreqn,    hostcpu_dbgtrace_egress_qreqn,      CLUSTOPEGRESSQREQn}),
    .dev_qacceptn_i ({hostcpu_axim_egress_qacceptn, hostcpu_dbgtrace_egress_qacceptn,   CLUSTOPEGRESSQACCEPTn}),
    .dev_qdeny_i    ({hostcpu_axim_egress_qdeny,    hostcpu_dbgtrace_egress_qdeny,      CLUSTOPEGRESSQDENY}),
    .dev_qactive_i  ({hostcpu_axim_egress_qactive,  1'b0 , CLUSTOPEGRESSQACTIVE}),

    .clk_qactive_o (clustop_egress_lpd_q_qactive_ctrlclk),

    .dftcgen (dftcgen)
  );

  wire clustop_internal_l2_combined_qreqn;
  wire clustop_internal_l2_combined_qacceptn;
  wire clustop_internal_l2_combined_qdeny;
  wire clustop_internal_l2_combined_qactive;

  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b1111_1101_0111_0000),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_clustop_internal_p2q (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (clustop_internal_l2_preq_o),
    .ctrl_pstate_i    ({4'b0000,clustop_internal_l2_pstate_o}),
    .ctrl_paccept_o   (clustop_internal_l2_paccept_i),
    .ctrl_pdeny_o     (clustop_internal_l2_pdeny_i),
    .ctrl_pactive_o   (clustop_internal_l2_pactive_i),

    .dev_qreqn_o      (clustop_internal_l2_combined_qreqn   ),
    .dev_qacceptn_i   (clustop_internal_l2_combined_qacceptn),
    .dev_qdeny_i      (clustop_internal_l2_combined_qdeny   ),
    .dev_qactive_i    (clustop_internal_l2_combined_qactive ),

    .clk_qactive_o    (clustop_internal_l2_combined_p2q_clkqactive_ctrlclk),

    .dftcgen          (dftcgen)
  );

  wire clustop_l2_flush_qreqn;
  wire  clustop_l2_flush_qacceptn;
  wire clustop_l2_flush_qdeny;
  wire clustop_l2_flush_qactive;

  wire clustop_internal_l2_qreqn_int;
  wire clustop_internal_l2_qacceptn_int;
  wire clustop_internal_l2_qdeny_int;

  wire clustop_internal_l2_qacceptn_ss;
  wire clustop_internal_l2_qdeny_ss;


  wire [4:0]   clear_lock_host;
  wire [4:0]   set_lock_host;
  
  wire [4:0]   clear_lock;
  
   
  assign clear_lock[4] = (clustop_ppuhwstat_o[0] == 1'b1 && last_clustop_ppuhwstat[0] == 1'b0) |
                         (clustop_ppuhwstat_o[2] == 1'b1 && last_clustop_ppuhwstat[2] == 1'b0) |
                         (clustop_ppuhwstat_o[9] == 1'b1 && last_clustop_ppuhwstat[9] == 1'b0);
      
  css600_pulseasyncbridgemstr #(
    .WIDTH(10)
  )
  u_hostcpu_corewakeup_pulse 
  (
    .clk_m            (ctrlclk),
    .reset_m_n        (ctrlresetn),
    .pulse_out        ({clear_lock_host,set_lock_host}),
    .pulse_req        (modify_lock_req),
    .pulse_ack        (modify_lock_ack),
    .clk_m_qreq_n     (ctrlclk_qreqn[5]      ),
    .clk_m_qaccept_n  (ctrlclk_qacceptn_o[5] ),
    .clk_m_qactive    (ctrlclk_qactive_o[5]  )
  );
  assign ctrlclk_qdeny_o[5] = 1'b0;
  

  always @(posedge ctrlclk or negedge ctrlresetn)
  begin
    if(!ctrlresetn)
    begin
        last_clustop_ppuhwstat<=10'd0;
        host_lock<=5'd0;
    end
    else
    begin
        last_clustop_ppuhwstat<=clustop_ppuhwstat_o[9:0];
        
        if( (clear_lock | clear_lock_host) == 5'd0)
            host_lock<=host_lock | set_lock_host;
        else
            host_lock<=host_lock & ~( clear_lock | clear_lock_host);
    end
  end
  
  always @(posedge ctrlclk_free or negedge ctrlresetn)
  begin
    if(!ctrlresetn)
        clustop_lock_logic_qactive<=1'b0;
    else
        clustop_lock_logic_qactive<=last_clustop_ppuhwstat != clustop_ppuhwstat_o[9:0];
  end
  
arm_element_cdc_capt_sync u_l2_qacceptn_sync (.clk (ctrlclk), .nreset (ctrlresetn), 
                                              .d_async (clustop_internal_l2_qacceptn),
                                              .q (clustop_internal_l2_qacceptn_ss));

arm_element_cdc_capt_sync u_l2_qdeny_sync (.clk (ctrlclk), .nreset (ctrlresetn), 
                                           .d_async (clustop_internal_l2_qdeny),
                                           .q (clustop_internal_l2_qdeny_ss));


  pck600_lpd_q #(
    .SEQUENCER (0),
    .NUM_QCHL  (2),
    .CTRL_Q_CH_SYNC (0),
    .DEV_Q_CH_SYNC  (1),
    .ACTIVE_DENY (0)
  ) u_clustop_l2_lpd_q (
    .clk  (ctrlclk),
    .reset_n (ctrlresetn),

    .ctrl_qreqn_i    (clustop_internal_l2_combined_qreqn   ),
    .ctrl_qacceptn_o (clustop_internal_l2_combined_qacceptn),
    .ctrl_qdeny_o    (clustop_internal_l2_combined_qdeny   ),
    .ctrl_qactive_o  (clustop_internal_l2_combined_qactive ),

    .dev_qreqn_o ({clustop_internal_l2_qreqn_int, clustop_l2_flush_qreqn}),
    .dev_qacceptn_i ({clustop_internal_l2_qacceptn_int, clustop_l2_flush_qacceptn}),
    .dev_qdeny_i ({clustop_internal_l2_qdeny_int, clustop_l2_flush_qdeny}),
    .dev_qactive_i ({1'b0, clustop_l2_flush_qactive}),

    .clk_qactive_o (clustop_l2_lpd_q_qactive_ctrlclk),

    .dftcgen (dftcgen)
  );

sse710_clustop_l2_qch_handshake 
u_clustop_l2_qch_handshake (

  .clk             (ctrlclk),
  .resetn          (ctrlresetn),

  .qreqn_i         (clustop_internal_l2_qreqn_int),
  .qdeny_o         (clustop_internal_l2_qdeny_int),
  .qacceptn_o      (clustop_internal_l2_qacceptn_int),

  .pstate_i        (clustop_dev_pstate_o),

  .l2_qreqn_o      (clustop_internal_l2_qreqn),
  .l2_qacceptn_i   (clustop_internal_l2_qacceptn_ss),
  .l2_qdeny_i      (clustop_internal_l2_qdeny_ss)

);



  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b1111_1101_1111_0000),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_clustop_ingress_p2q (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (clustop_ingress_preq_o),
    .ctrl_pstate_i    ({4'b0000,clustop_ingress_pstate_o}),
    .ctrl_paccept_o   (clustop_ingress_paccept_i),
    .ctrl_pdeny_o     (clustop_ingress_pdeny_i),
    .ctrl_pactive_o   (clustop_ingress_pactive_i),

    .dev_qreqn_o      (clustop_ingress_qreqn   ),
    .dev_qacceptn_i   (clustop_ingress_qacceptn),
    .dev_qdeny_i      (clustop_ingress_qdeny   ),
    .dev_qactive_i    (clustop_ingress_qactive ),

    .clk_qactive_o    (clustop_ingress_p2q_clkqactive_ctrlclk),

    .dftcgen          (dftcgen)
  );

wire axiap_csyspwrupreq_qreqn;
wire axiap_csyspwrupreq_qacceptn;
wire axiap_csyspwrupreq_qdeny;
wire axiap_csyspwrupreq_qactive;

wire clustop_core_dependency_qreqn;
wire clustop_core_dependency_qacceptn;
wire clustop_core_dependency_qdeny;


  pck600_lpd_q #(
    .SEQUENCER (0),
    .NUM_QCHL  (6),
    .CTRL_Q_CH_SYNC (0),
    .DEV_Q_CH_SYNC  (1),
    .ACTIVE_DENY (0)
  ) u_clustop_ingress_lpd_q (
    .clk  (ctrlclk),
    .reset_n (ctrlresetn),

    .ctrl_qreqn_i (clustop_ingress_qreqn),
    .ctrl_qacceptn_o (clustop_ingress_qacceptn),
    .ctrl_qdeny_o (clustop_ingress_qdeny),
    .ctrl_qactive_o (clustop_ingress_qactive),

    .dev_qreqn_o    ({gic_axis_ingress_qreqn,    CLUSTOPINGRESSQREQn,    axiap_csyspwrupreq_qreqn,   hostcpu_dbgtrace_ingress_qreqn,    clustop_core_dependency_qreqn,    clustop_ingress_cti_double_bridge_qreqn}),
    .dev_qacceptn_i ({gic_axis_ingress_qacceptn, CLUSTOPINGRESSQACCEPTn, axiap_csyspwrupreq_qacceptn,hostcpu_dbgtrace_ingress_qacceptn, clustop_core_dependency_qacceptn, clustop_ingress_cti_double_bridge_qacceptn}),
    .dev_qdeny_i    ({gic_axis_ingress_qdeny,    CLUSTOPINGRESSQDENY,    axiap_csyspwrupreq_qdeny,   hostcpu_dbgtrace_ingress_qdeny,    clustop_core_dependency_qdeny,    clustop_ingress_cti_double_bridge_qdeny}),
    .dev_qactive_i  ({gic_axis_ingress_qactive,  CLUSTOPINGRESSQACTIVE,  1'b0,                       hostcpu_dbgtrace_ingress_qactive,  1'b0,                             clustop_ingress_cti_double_bridge_qactive}),

    .clk_qactive_o (clustop_ingress_lpd_q_qactive_ctrlclk),

    .dftcgen (dftcgen)
  );


wire hostrom_cdbgpwrupreq_qreqn;
wire hostrom_cdbgpwrupreq_qacceptn;
wire hostrom_cdbgpwrupreq_qdeny;
wire hostrom_cdbgpwrupreq_qactive;

  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b1111_1101_1111_0000),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_hostrom_cdbgpwrupreq_p2q (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (hostrom_cdbgpwrupreq_preq_o),
    .ctrl_pstate_i    ({4'b0000,hostrom_cdbgpwrupreq_pstate_o}),
    .ctrl_paccept_o   (hostrom_cdbgpwrupreq_paccept_i),
    .ctrl_pdeny_o     (hostrom_cdbgpwrupreq_pdeny_i),
    .ctrl_pactive_o   (hostrom_cdbgpwrupreq_pactive_i),

    .dev_qreqn_o      (hostrom_cdbgpwrupreq_qreqn   ),
    .dev_qacceptn_i   (hostrom_cdbgpwrupreq_qacceptn),
    .dev_qdeny_i      (hostrom_cdbgpwrupreq_qdeny   ),
    .dev_qactive_i    (hostrom_cdbgpwrupreq_qactive ),

    .clk_qactive_o    (hostrom_cdbgpwrupreq_p2q_clkqactive_ctrlclk),

    .dftcgen          (dftcgen)
  );





  genvar I;

  wire [HOST_CPU_NUM_CORES-1:0] core_dbgpwrdup_gen_ctrlclk_clkqactive;
  
  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_paccept_power_handshake;
  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_pdeny_power_handshake;
  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_preq_power_handshake;
  wire [4*HOST_CPU_NUM_CORES-1:0] core_dev_pstate_power_handshake;

  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_preq_int;
  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_paccept_int;
  wire [HOST_CPU_NUM_CORES-1:0]   core_dev_pdeny_int;
  wire [4*HOST_CPU_NUM_CORES-1:0] core_dev_pstate_int;

  wire [HOST_CPU_NUM_CORES-1:0]   dbgpwrdup_gen_preq;
  wire [HOST_CPU_NUM_CORES-1:0]   dbgpwrdup_gen_paccept;
  wire [HOST_CPU_NUM_CORES-1:0]   dbgpwrdup_gen_pdeny;
  wire [4*HOST_CPU_NUM_CORES-1:0] dbgpwrdup_gen_pstate;

  wire [HOST_CPU_NUM_CORES-1:0] core_ppu_gic_irq_wakeupreq;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_on_bit;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_warmrst_bit;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_offemu_bit;
  wire [10*HOST_CPU_NUM_CORES-1:0] coreppu_pactive_on_bit_sticky;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_warmrst_bit_ss;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_offemu_bit_ss;
  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_smpen_ss;

  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_on_bit_enabled;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_warmrst_bit_enabled;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_fullret_bit_enabled;
  wire [HOST_CPU_NUM_CORES-1:0] coreppu_pactive_offemu_bit_enabled;
  
  wire  [HOST_CPU_NUM_CORES-1:0]     core_isolaten_o;
  wire  [HOST_CPU_NUM_CORES-1:0]     core_isolaten_ppu;  


  wire  [HOST_CPU_NUM_CORES-1:0]     core_pcsm_preq_o;
  wire  [4*HOST_CPU_NUM_CORES-1:0]   core_pcsm_pstate_o;
  wire  [HOST_CPU_NUM_CORES-1:0]     core_pcsm_paccept_i;
  wire  [4*HOST_CPU_NUM_CORES-1:0]   core_pcsm_mode_stat_i;

  wire  [4*HOST_CPU_NUM_CORES-1:0]   core_ecorevnum_i;







 


 


 


 


 





 
    assign core_isolaten_o[0]    = core_isolaten_ppu[0] | coreppu_dftisodisable[0];

    assign clear_lock[0] = clear_lock[4] | 
                                         (core_ppuhwstat[0 + 0] == 1'b1 && last_core0_ppuhwstat[0] == 1'b0) |
                                         (core_ppuhwstat[0 + 1] == 1'b1 && last_core0_ppuhwstat[1] == 1'b0) |
                                         (core_ppuhwstat[0 + 9] == 1'b1 && last_core0_ppuhwstat[9] == 1'b0);
            
    always @(posedge ctrlclk or negedge ctrlresetn)
    begin
      if(!ctrlresetn)
      begin
          last_core0_ppuhwstat<=10'd0;          
      end
      else
      begin
          last_core0_ppuhwstat<=core_ppuhwstat[0+:10];        
      end
    end
    
    always @(posedge ctrlclk_free or negedge ctrlresetn)
     begin
       if(!ctrlresetn)
           core_lock_logic_qactive[0]<=1'b0;
       else
           core_lock_logic_qactive[0]<= last_core0_ppuhwstat != core_ppuhwstat[0+:10];
     end
    

  
    pck600_ppu_sse710_core 
    #(
      .DEV_PREQ_DLY       (DEV_PREQ_DLY_CPU0      ),
      .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_CPU0     ),
      .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_CPU0 ),
      .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_CPU0 ),
      .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_CPU0),
      .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_CPU0 ),
      .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_CPU0   ) 
    ) u_core0_ppu (

      .clk                 (ctrlclk),
      .reset_n             (ctrlresetn),
                         
                         
      .dftcgen             (dftcgen),
      .dftisodisable       (coreppu_dftisodisable[0]),
      .dftrstdisable       (dftrstdisable),
                         
                         
      .psel_i              (ppu_core_psel_i[0]),
      .penable_i           (ppu_core_penable_i[0]),
      .paddr_i             (ppu_core_paddr_i[0+:32]),
      .pwrite_i            (ppu_core_pwrite_i[0]),
      .pwdata_i            (ppu_core_pwdata_i[0+:32]),
      .prdata_o            (ppu_core_prdata_o[0+:32]),
      .pready_o            (ppu_core_pready_o[0]),
      .pslverr_o           (ppu_core_pslverr_o[0]),
      .pwakeup_i           (ppu_core_psel_i[0]),                        
                         
      .irq_o               (core_ppu_interrupt_o[0]),
                         
                         
      .dev_preq_o          (core_dev_preq_int[0]),
      .dev_pstate_o        (core_dev_pstate_int[0+:4]),
      .dev_paccept_i       (core_dev_paccept_int[0]),
      .dev_pdeny_i         (core_dev_pdeny_int[0]),
      .dev_pactive_i       ({1'b0,coreppu_pactive_warmrst_bit_enabled[0],coreppu_pactive_on_bit_enabled[0],1'b0,1'b0,coreppu_pactive_fullret_bit_enabled[0],1'b0,1'b0,1'b0,coreppu_pactive_offemu_bit_enabled[0],1'b1}),
                         
                         
      .ppuhwstat_o         (core_ppuhwstat[0+:16]),
      .devclken_o          ( ),
      .devemuclken_o       ( ),
      .devisolaten_o       (core_isolaten_ppu[0]),
      .devemuisolaten_o    (),
      .devwarmresetn_o     ( ),
      .devretresetn_o      (core_retresetn[0]),
      .devporesetn_o       (core_poresetn[0]),
                         
                         
      .pcsm_preq_o         (core_pcsm_preq_o[0]),
      .pcsm_pstate_o       (core_pcsm_pstate_o[0+:4]),
      .pcsm_paccept_i      (core_pcsm_paccept_i[0]),
                         
                         
      .ppuclk_qreqn_i      (ctrlclk_qreqn[0]),
      .ppuclk_qacceptn_o   (ctrlclk_qacceptn[0]),
      .ppuclk_qdeny_o      (ctrlclk_qdeny[0]),
      .ppuclk_qactive_o    (ctrlclk_qactive[0]),
                         
                         
      .ecorevnum_i         (4'b0000) 

    );

    pck600_lpd_p_sse710_cpu u_core0_lpd_p (
      .clk               (ctrlclk),
      .reset_n           (ctrlresetn),
      
      .ctrl_preq_i       (core_dev_preq_int[0]),
      .ctrl_pstate_i     (core_dev_pstate_int[0+:4]),
      .ctrl_pactive_o    ( ),
      .ctrl_paccept_o    (core_dev_paccept_int[0]),
      .ctrl_pdeny_o      (core_dev_pdeny_int[0]),

      .dev0_preq_o       (core_dev_preq_power_handshake[0]),
      .dev0_pstate_o     (core_dev_pstate_power_handshake[0+:4]),
      .dev0_pactive_i    (11'd0),
      .dev0_paccept_i    (core_dev_paccept_power_handshake[0]),
      .dev0_pdeny_i      (core_dev_pdeny_power_handshake[0]),

      .dev1_preq_o       (dbgpwrdup_gen_preq[0]),
      .dev1_pstate_o     (dbgpwrdup_gen_pstate[0+:4]),
      .dev1_pactive_i    (11'd0),
      .dev1_paccept_i    (dbgpwrdup_gen_paccept[0]),
      .dev1_pdeny_i      (dbgpwrdup_gen_pdeny[0]),

      .clk_qactive_o     ( ),

      .dftcgen           (dftcgen)
    );

    pck600_lpd_p_sse710_cpu_expander u_pck600_lpd_p_core0_power_handshake (

      .clk            (ctrlclk),
      .reset_n        (ctrlresetn),
    
      .ctrl_preq_i    (core_dev_preq_power_handshake[0]),
      .ctrl_pstate_i  (core_dev_pstate_power_handshake[0+:4]),
      .ctrl_pactive_o ( ),
      .ctrl_paccept_o (core_dev_paccept_power_handshake[0]),
      .ctrl_pdeny_o   (core_dev_pdeny_power_handshake[0]),
    
      .dev0_preq_o    (dev_preq_core_power_handshake[0]),
      .dev0_pstate_o  (dev_pstate_core_power_handshake[0+:4]),
      .dev0_pactive_i (11'd0),
      .dev0_paccept_i (dev_paccept_core_power_handshake[0]),
      .dev0_pdeny_i   (dev_pdeny_core_power_handshake[0]),
    
      .dev1_preq_o    (dev_preq_core_warmrst_check[0]),
      .dev1_pstate_o  (dev_pstate_core_warmrst_check[0+:4]),
      .dev1_pactive_i (11'd0),
      .dev1_paccept_i (dev_paccept_core_warmrst_check[0]),
      .dev1_pdeny_i   (dev_pdeny_core_warmrst_check[0]),
    
      .clk_qactive_o  ( ),
    
      .dftcgen        (dftcgen)

    );


    pck600_ppu_pcsm_sse710_core u_pck600_ppu_pcsm_sse710_core0    (
      .clk              (ctrlclk),
      .reset_n          (ctrlresetn),
        
      .dftpwrup         (dftpwrupcpu[0]),
      .dftretdisable    (dftretdisable[0]),
        
      .pcsm_preq_i      (core_pcsm_preq_o[0]),
      .pcsm_pstate_i    (core_pcsm_pstate_o[0+:4]),
      .pcsm_paccept_o   (core_pcsm_paccept_i[0]),
    
      .lgcpwrn_o        (),
      .lgcretn_o        (),
      .rampwrn_o        (),
      .ramretn_o        ()
    );
 
    assign core_isolaten_o[1]    = core_isolaten_ppu[1] | coreppu_dftisodisable[1];

    assign clear_lock[1] = clear_lock[4] | 
                                         (core_ppuhwstat[16 + 0] == 1'b1 && last_core1_ppuhwstat[0] == 1'b0) |
                                         (core_ppuhwstat[16 + 1] == 1'b1 && last_core1_ppuhwstat[1] == 1'b0) |
                                         (core_ppuhwstat[16 + 9] == 1'b1 && last_core1_ppuhwstat[9] == 1'b0);
            
    always @(posedge ctrlclk or negedge ctrlresetn)
    begin
      if(!ctrlresetn)
      begin
          last_core1_ppuhwstat<=10'd0;          
      end
      else
      begin
          last_core1_ppuhwstat<=core_ppuhwstat[16+:10];        
      end
    end
    
    always @(posedge ctrlclk_free or negedge ctrlresetn)
     begin
       if(!ctrlresetn)
           core_lock_logic_qactive[1]<=1'b0;
       else
           core_lock_logic_qactive[1]<= last_core1_ppuhwstat != core_ppuhwstat[16+:10];
     end
    

  
    pck600_ppu_sse710_core 
    #(
      .DEV_PREQ_DLY       (DEV_PREQ_DLY_CPU1      ),
      .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_CPU1     ),
      .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_CPU1 ),
      .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_CPU1 ),
      .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_CPU1),
      .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_CPU1 ),
      .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_CPU1   ) 
    ) u_core1_ppu (

      .clk                 (ctrlclk),
      .reset_n             (ctrlresetn),
                         
                         
      .dftcgen             (dftcgen),
      .dftisodisable       (coreppu_dftisodisable[1]),
      .dftrstdisable       (dftrstdisable),
                         
                         
      .psel_i              (ppu_core_psel_i[1]),
      .penable_i           (ppu_core_penable_i[1]),
      .paddr_i             (ppu_core_paddr_i[32+:32]),
      .pwrite_i            (ppu_core_pwrite_i[1]),
      .pwdata_i            (ppu_core_pwdata_i[32+:32]),
      .prdata_o            (ppu_core_prdata_o[32+:32]),
      .pready_o            (ppu_core_pready_o[1]),
      .pslverr_o           (ppu_core_pslverr_o[1]),
      .pwakeup_i           (ppu_core_psel_i[1]),                        
                         
      .irq_o               (core_ppu_interrupt_o[1]),
                         
                         
      .dev_preq_o          (core_dev_preq_int[1]),
      .dev_pstate_o        (core_dev_pstate_int[4+:4]),
      .dev_paccept_i       (core_dev_paccept_int[1]),
      .dev_pdeny_i         (core_dev_pdeny_int[1]),
      .dev_pactive_i       ({1'b0,coreppu_pactive_warmrst_bit_enabled[1],coreppu_pactive_on_bit_enabled[1],1'b0,1'b0,coreppu_pactive_fullret_bit_enabled[1],1'b0,1'b0,1'b0,coreppu_pactive_offemu_bit_enabled[1],1'b1}),
                         
                         
      .ppuhwstat_o         (core_ppuhwstat[16+:16]),
      .devclken_o          ( ),
      .devemuclken_o       ( ),
      .devisolaten_o       (core_isolaten_ppu[1]),
      .devemuisolaten_o    (),
      .devwarmresetn_o     ( ),
      .devretresetn_o      (core_retresetn[1]),
      .devporesetn_o       (core_poresetn[1]),
                         
                         
      .pcsm_preq_o         (core_pcsm_preq_o[1]),
      .pcsm_pstate_o       (core_pcsm_pstate_o[4+:4]),
      .pcsm_paccept_i      (core_pcsm_paccept_i[1]),
                         
                         
      .ppuclk_qreqn_i      (ctrlclk_qreqn[1]),
      .ppuclk_qacceptn_o   (ctrlclk_qacceptn[1]),
      .ppuclk_qdeny_o      (ctrlclk_qdeny[1]),
      .ppuclk_qactive_o    (ctrlclk_qactive[1]),
                         
                         
      .ecorevnum_i         (4'b0000) 

    );

    pck600_lpd_p_sse710_cpu u_core1_lpd_p (
      .clk               (ctrlclk),
      .reset_n           (ctrlresetn),
      
      .ctrl_preq_i       (core_dev_preq_int[1]),
      .ctrl_pstate_i     (core_dev_pstate_int[4+:4]),
      .ctrl_pactive_o    ( ),
      .ctrl_paccept_o    (core_dev_paccept_int[1]),
      .ctrl_pdeny_o      (core_dev_pdeny_int[1]),

      .dev0_preq_o       (core_dev_preq_power_handshake[1]),
      .dev0_pstate_o     (core_dev_pstate_power_handshake[4+:4]),
      .dev0_pactive_i    (11'd0),
      .dev0_paccept_i    (core_dev_paccept_power_handshake[1]),
      .dev0_pdeny_i      (core_dev_pdeny_power_handshake[1]),

      .dev1_preq_o       (dbgpwrdup_gen_preq[1]),
      .dev1_pstate_o     (dbgpwrdup_gen_pstate[4+:4]),
      .dev1_pactive_i    (11'd0),
      .dev1_paccept_i    (dbgpwrdup_gen_paccept[1]),
      .dev1_pdeny_i      (dbgpwrdup_gen_pdeny[1]),

      .clk_qactive_o     ( ),

      .dftcgen           (dftcgen)
    );

    pck600_lpd_p_sse710_cpu_expander u_pck600_lpd_p_core1_power_handshake (

      .clk            (ctrlclk),
      .reset_n        (ctrlresetn),
    
      .ctrl_preq_i    (core_dev_preq_power_handshake[1]),
      .ctrl_pstate_i  (core_dev_pstate_power_handshake[4+:4]),
      .ctrl_pactive_o ( ),
      .ctrl_paccept_o (core_dev_paccept_power_handshake[1]),
      .ctrl_pdeny_o   (core_dev_pdeny_power_handshake[1]),
    
      .dev0_preq_o    (dev_preq_core_power_handshake[1]),
      .dev0_pstate_o  (dev_pstate_core_power_handshake[4+:4]),
      .dev0_pactive_i (11'd0),
      .dev0_paccept_i (dev_paccept_core_power_handshake[1]),
      .dev0_pdeny_i   (dev_pdeny_core_power_handshake[1]),
    
      .dev1_preq_o    (dev_preq_core_warmrst_check[1]),
      .dev1_pstate_o  (dev_pstate_core_warmrst_check[4+:4]),
      .dev1_pactive_i (11'd0),
      .dev1_paccept_i (dev_paccept_core_warmrst_check[1]),
      .dev1_pdeny_i   (dev_pdeny_core_warmrst_check[1]),
    
      .clk_qactive_o  ( ),
    
      .dftcgen        (dftcgen)

    );


    pck600_ppu_pcsm_sse710_core u_pck600_ppu_pcsm_sse710_core1    (
      .clk              (ctrlclk),
      .reset_n          (ctrlresetn),
        
      .dftpwrup         (dftpwrupcpu[1]),
      .dftretdisable    (dftretdisable[1]),
        
      .pcsm_preq_i      (core_pcsm_preq_o[1]),
      .pcsm_pstate_i    (core_pcsm_pstate_o[4+:4]),
      .pcsm_paccept_o   (core_pcsm_paccept_i[1]),
    
      .lgcpwrn_o        (),
      .lgcretn_o        (),
      .rampwrn_o        (),
      .ramretn_o        ()
    );
 
    assign core_isolaten_o[2]    = core_isolaten_ppu[2] | coreppu_dftisodisable[2];

    assign clear_lock[2] = clear_lock[4] | 
                                         (core_ppuhwstat[32 + 0] == 1'b1 && last_core2_ppuhwstat[0] == 1'b0) |
                                         (core_ppuhwstat[32 + 1] == 1'b1 && last_core2_ppuhwstat[1] == 1'b0) |
                                         (core_ppuhwstat[32 + 9] == 1'b1 && last_core2_ppuhwstat[9] == 1'b0);
            
    always @(posedge ctrlclk or negedge ctrlresetn)
    begin
      if(!ctrlresetn)
      begin
          last_core2_ppuhwstat<=10'd0;          
      end
      else
      begin
          last_core2_ppuhwstat<=core_ppuhwstat[32+:10];        
      end
    end
    
    always @(posedge ctrlclk_free or negedge ctrlresetn)
     begin
       if(!ctrlresetn)
           core_lock_logic_qactive[2]<=1'b0;
       else
           core_lock_logic_qactive[2]<= last_core2_ppuhwstat != core_ppuhwstat[32+:10];
     end
    

  
    pck600_ppu_sse710_core 
    #(
      .DEV_PREQ_DLY       (DEV_PREQ_DLY_CPU2      ),
      .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_CPU2     ),
      .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_CPU2 ),
      .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_CPU2 ),
      .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_CPU2),
      .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_CPU2 ),
      .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_CPU2   ) 
    ) u_core2_ppu (

      .clk                 (ctrlclk),
      .reset_n             (ctrlresetn),
                         
                         
      .dftcgen             (dftcgen),
      .dftisodisable       (coreppu_dftisodisable[2]),
      .dftrstdisable       (dftrstdisable),
                         
                         
      .psel_i              (ppu_core_psel_i[2]),
      .penable_i           (ppu_core_penable_i[2]),
      .paddr_i             (ppu_core_paddr_i[64+:32]),
      .pwrite_i            (ppu_core_pwrite_i[2]),
      .pwdata_i            (ppu_core_pwdata_i[64+:32]),
      .prdata_o            (ppu_core_prdata_o[64+:32]),
      .pready_o            (ppu_core_pready_o[2]),
      .pslverr_o           (ppu_core_pslverr_o[2]),
      .pwakeup_i           (ppu_core_psel_i[2]),                        
                         
      .irq_o               (core_ppu_interrupt_o[2]),
                         
                         
      .dev_preq_o          (core_dev_preq_int[2]),
      .dev_pstate_o        (core_dev_pstate_int[8+:4]),
      .dev_paccept_i       (core_dev_paccept_int[2]),
      .dev_pdeny_i         (core_dev_pdeny_int[2]),
      .dev_pactive_i       ({1'b0,coreppu_pactive_warmrst_bit_enabled[2],coreppu_pactive_on_bit_enabled[2],1'b0,1'b0,coreppu_pactive_fullret_bit_enabled[2],1'b0,1'b0,1'b0,coreppu_pactive_offemu_bit_enabled[2],1'b1}),
                         
                         
      .ppuhwstat_o         (core_ppuhwstat[32+:16]),
      .devclken_o          ( ),
      .devemuclken_o       ( ),
      .devisolaten_o       (core_isolaten_ppu[2]),
      .devemuisolaten_o    (),
      .devwarmresetn_o     ( ),
      .devretresetn_o      (core_retresetn[2]),
      .devporesetn_o       (core_poresetn[2]),
                         
                         
      .pcsm_preq_o         (core_pcsm_preq_o[2]),
      .pcsm_pstate_o       (core_pcsm_pstate_o[8+:4]),
      .pcsm_paccept_i      (core_pcsm_paccept_i[2]),
                         
                         
      .ppuclk_qreqn_i      (ctrlclk_qreqn[2]),
      .ppuclk_qacceptn_o   (ctrlclk_qacceptn[2]),
      .ppuclk_qdeny_o      (ctrlclk_qdeny[2]),
      .ppuclk_qactive_o    (ctrlclk_qactive[2]),
                         
                         
      .ecorevnum_i         (4'b0000) 

    );

    pck600_lpd_p_sse710_cpu u_core2_lpd_p (
      .clk               (ctrlclk),
      .reset_n           (ctrlresetn),
      
      .ctrl_preq_i       (core_dev_preq_int[2]),
      .ctrl_pstate_i     (core_dev_pstate_int[8+:4]),
      .ctrl_pactive_o    ( ),
      .ctrl_paccept_o    (core_dev_paccept_int[2]),
      .ctrl_pdeny_o      (core_dev_pdeny_int[2]),

      .dev0_preq_o       (core_dev_preq_power_handshake[2]),
      .dev0_pstate_o     (core_dev_pstate_power_handshake[8+:4]),
      .dev0_pactive_i    (11'd0),
      .dev0_paccept_i    (core_dev_paccept_power_handshake[2]),
      .dev0_pdeny_i      (core_dev_pdeny_power_handshake[2]),

      .dev1_preq_o       (dbgpwrdup_gen_preq[2]),
      .dev1_pstate_o     (dbgpwrdup_gen_pstate[8+:4]),
      .dev1_pactive_i    (11'd0),
      .dev1_paccept_i    (dbgpwrdup_gen_paccept[2]),
      .dev1_pdeny_i      (dbgpwrdup_gen_pdeny[2]),

      .clk_qactive_o     ( ),

      .dftcgen           (dftcgen)
    );

    pck600_lpd_p_sse710_cpu_expander u_pck600_lpd_p_core2_power_handshake (

      .clk            (ctrlclk),
      .reset_n        (ctrlresetn),
    
      .ctrl_preq_i    (core_dev_preq_power_handshake[2]),
      .ctrl_pstate_i  (core_dev_pstate_power_handshake[8+:4]),
      .ctrl_pactive_o ( ),
      .ctrl_paccept_o (core_dev_paccept_power_handshake[2]),
      .ctrl_pdeny_o   (core_dev_pdeny_power_handshake[2]),
    
      .dev0_preq_o    (dev_preq_core_power_handshake[2]),
      .dev0_pstate_o  (dev_pstate_core_power_handshake[8+:4]),
      .dev0_pactive_i (11'd0),
      .dev0_paccept_i (dev_paccept_core_power_handshake[2]),
      .dev0_pdeny_i   (dev_pdeny_core_power_handshake[2]),
    
      .dev1_preq_o    (dev_preq_core_warmrst_check[2]),
      .dev1_pstate_o  (dev_pstate_core_warmrst_check[8+:4]),
      .dev1_pactive_i (11'd0),
      .dev1_paccept_i (dev_paccept_core_warmrst_check[2]),
      .dev1_pdeny_i   (dev_pdeny_core_warmrst_check[2]),
    
      .clk_qactive_o  ( ),
    
      .dftcgen        (dftcgen)

    );


    pck600_ppu_pcsm_sse710_core u_pck600_ppu_pcsm_sse710_core2    (
      .clk              (ctrlclk),
      .reset_n          (ctrlresetn),
        
      .dftpwrup         (dftpwrupcpu[2]),
      .dftretdisable    (dftretdisable[2]),
        
      .pcsm_preq_i      (core_pcsm_preq_o[2]),
      .pcsm_pstate_i    (core_pcsm_pstate_o[8+:4]),
      .pcsm_paccept_o   (core_pcsm_paccept_i[2]),
    
      .lgcpwrn_o        (),
      .lgcretn_o        (),
      .rampwrn_o        (),
      .ramretn_o        ()
    );
 
    assign core_isolaten_o[3]    = core_isolaten_ppu[3] | coreppu_dftisodisable[3];

    assign clear_lock[3] = clear_lock[4] | 
                                         (core_ppuhwstat[48 + 0] == 1'b1 && last_core3_ppuhwstat[0] == 1'b0) |
                                         (core_ppuhwstat[48 + 1] == 1'b1 && last_core3_ppuhwstat[1] == 1'b0) |
                                         (core_ppuhwstat[48 + 9] == 1'b1 && last_core3_ppuhwstat[9] == 1'b0);
            
    always @(posedge ctrlclk or negedge ctrlresetn)
    begin
      if(!ctrlresetn)
      begin
          last_core3_ppuhwstat<=10'd0;          
      end
      else
      begin
          last_core3_ppuhwstat<=core_ppuhwstat[48+:10];        
      end
    end
    
    always @(posedge ctrlclk_free or negedge ctrlresetn)
     begin
       if(!ctrlresetn)
           core_lock_logic_qactive[3]<=1'b0;
       else
           core_lock_logic_qactive[3]<= last_core3_ppuhwstat != core_ppuhwstat[48+:10];
     end
    

  
    pck600_ppu_sse710_core 
    #(
      .DEV_PREQ_DLY       (DEV_PREQ_DLY_CPU3      ),
      .PCSM_PREQ_DLY      (PCSM_PREQ_DLY_CPU3     ),
      .ISO_CLKEN_DLY_CFG  (ISO_CLKEN_DLY_CFG_CPU3 ),
      .CLKEN_RST_DLY_CFG  (CLKEN_RST_DLY_CFG_CPU3 ),
      .RST_HWSTAT_DLY_CFG (RST_HWSTAT_DLY_CFG_CPU3),
      .CLKEN_ISO_DLY_CFG  (CLKEN_ISO_DLY_CFG_CPU3 ),
      .ISO_RST_DLY_CFG    (ISO_RST_DLY_CFG_CPU3   ) 
    ) u_core3_ppu (

      .clk                 (ctrlclk),
      .reset_n             (ctrlresetn),
                         
                         
      .dftcgen             (dftcgen),
      .dftisodisable       (coreppu_dftisodisable[3]),
      .dftrstdisable       (dftrstdisable),
                         
                         
      .psel_i              (ppu_core_psel_i[3]),
      .penable_i           (ppu_core_penable_i[3]),
      .paddr_i             (ppu_core_paddr_i[96+:32]),
      .pwrite_i            (ppu_core_pwrite_i[3]),
      .pwdata_i            (ppu_core_pwdata_i[96+:32]),
      .prdata_o            (ppu_core_prdata_o[96+:32]),
      .pready_o            (ppu_core_pready_o[3]),
      .pslverr_o           (ppu_core_pslverr_o[3]),
      .pwakeup_i           (ppu_core_psel_i[3]),                        
                         
      .irq_o               (core_ppu_interrupt_o[3]),
                         
                         
      .dev_preq_o          (core_dev_preq_int[3]),
      .dev_pstate_o        (core_dev_pstate_int[12+:4]),
      .dev_paccept_i       (core_dev_paccept_int[3]),
      .dev_pdeny_i         (core_dev_pdeny_int[3]),
      .dev_pactive_i       ({1'b0,coreppu_pactive_warmrst_bit_enabled[3],coreppu_pactive_on_bit_enabled[3],1'b0,1'b0,coreppu_pactive_fullret_bit_enabled[3],1'b0,1'b0,1'b0,coreppu_pactive_offemu_bit_enabled[3],1'b1}),
                         
                         
      .ppuhwstat_o         (core_ppuhwstat[48+:16]),
      .devclken_o          ( ),
      .devemuclken_o       ( ),
      .devisolaten_o       (core_isolaten_ppu[3]),
      .devemuisolaten_o    (),
      .devwarmresetn_o     ( ),
      .devretresetn_o      (core_retresetn[3]),
      .devporesetn_o       (core_poresetn[3]),
                         
                         
      .pcsm_preq_o         (core_pcsm_preq_o[3]),
      .pcsm_pstate_o       (core_pcsm_pstate_o[12+:4]),
      .pcsm_paccept_i      (core_pcsm_paccept_i[3]),
                         
                         
      .ppuclk_qreqn_i      (ctrlclk_qreqn[3]),
      .ppuclk_qacceptn_o   (ctrlclk_qacceptn[3]),
      .ppuclk_qdeny_o      (ctrlclk_qdeny[3]),
      .ppuclk_qactive_o    (ctrlclk_qactive[3]),
                         
                         
      .ecorevnum_i         (4'b0000) 

    );

    pck600_lpd_p_sse710_cpu u_core3_lpd_p (
      .clk               (ctrlclk),
      .reset_n           (ctrlresetn),
      
      .ctrl_preq_i       (core_dev_preq_int[3]),
      .ctrl_pstate_i     (core_dev_pstate_int[12+:4]),
      .ctrl_pactive_o    ( ),
      .ctrl_paccept_o    (core_dev_paccept_int[3]),
      .ctrl_pdeny_o      (core_dev_pdeny_int[3]),

      .dev0_preq_o       (core_dev_preq_power_handshake[3]),
      .dev0_pstate_o     (core_dev_pstate_power_handshake[12+:4]),
      .dev0_pactive_i    (11'd0),
      .dev0_paccept_i    (core_dev_paccept_power_handshake[3]),
      .dev0_pdeny_i      (core_dev_pdeny_power_handshake[3]),

      .dev1_preq_o       (dbgpwrdup_gen_preq[3]),
      .dev1_pstate_o     (dbgpwrdup_gen_pstate[12+:4]),
      .dev1_pactive_i    (11'd0),
      .dev1_paccept_i    (dbgpwrdup_gen_paccept[3]),
      .dev1_pdeny_i      (dbgpwrdup_gen_pdeny[3]),

      .clk_qactive_o     ( ),

      .dftcgen           (dftcgen)
    );

    pck600_lpd_p_sse710_cpu_expander u_pck600_lpd_p_core3_power_handshake (

      .clk            (ctrlclk),
      .reset_n        (ctrlresetn),
    
      .ctrl_preq_i    (core_dev_preq_power_handshake[3]),
      .ctrl_pstate_i  (core_dev_pstate_power_handshake[12+:4]),
      .ctrl_pactive_o ( ),
      .ctrl_paccept_o (core_dev_paccept_power_handshake[3]),
      .ctrl_pdeny_o   (core_dev_pdeny_power_handshake[3]),
    
      .dev0_preq_o    (dev_preq_core_power_handshake[3]),
      .dev0_pstate_o  (dev_pstate_core_power_handshake[12+:4]),
      .dev0_pactive_i (11'd0),
      .dev0_paccept_i (dev_paccept_core_power_handshake[3]),
      .dev0_pdeny_i   (dev_pdeny_core_power_handshake[3]),
    
      .dev1_preq_o    (dev_preq_core_warmrst_check[3]),
      .dev1_pstate_o  (dev_pstate_core_warmrst_check[12+:4]),
      .dev1_pactive_i (11'd0),
      .dev1_paccept_i (dev_paccept_core_warmrst_check[3]),
      .dev1_pdeny_i   (dev_pdeny_core_warmrst_check[3]),
    
      .clk_qactive_o  ( ),
    
      .dftcgen        (dftcgen)

    );


    pck600_ppu_pcsm_sse710_core u_pck600_ppu_pcsm_sse710_core3    (
      .clk              (ctrlclk),
      .reset_n          (ctrlresetn),
        
      .dftpwrup         (dftpwrupcpu[3]),
      .dftretdisable    (dftretdisable[3]),
        
      .pcsm_preq_i      (core_pcsm_preq_o[3]),
      .pcsm_pstate_i    (core_pcsm_pstate_o[12+:4]),
      .pcsm_paccept_o   (core_pcsm_paccept_i[3]),
    
      .lgcpwrn_o        (),
      .lgcretn_o        (),
      .rampwrn_o        (),
      .ramretn_o        ()
    );
 

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (HOST_CPU_NUM_CORES))
u_core_p_network_clkqactive (
  .or_tree_i ({core_dbgpwrdup_gen_ctrlclk_clkqactive}),
  .or_tree_o (core_p_network_ctrlclk_clkqactive)
);


p_reqack_to_qchan_f0_top u_axiap_csyspwrup_reqack (
  .CLK    (ctrlclk),
  .RESETn (ctrlresetn),

  .PWRUPREQ (axiap_csyspwrupreq_1),
  .PWRUPACK (axiap_csyspwrupack_1),

  .PWRQREQn    (axiap_csyspwrupreq_qreqn),
  .PWRQACCEPTn (axiap_csyspwrupreq_qacceptn),
  .PWRQDENY    (axiap_csyspwrupreq_qdeny),
  .PWRQACTIVE  (axiap_csyspwrupreq_qactive),

  .CLKQACTIVE  (axiap_csyspwrup_reqack_clkqactive_ctrlclk)
);

p_reqack_to_qchan_f0_top u_hostrom_cdbgpwrup_reqack (
  .CLK    (ctrlclk),
  .RESETn (ctrlresetn),

  .PWRUPREQ (hostrom_cdbgpwrupreq),
  .PWRUPACK (hostrom_cdbgpwrupack),

  .PWRQREQn    (hostrom_cdbgpwrupreq_qreqn),
  .PWRQACCEPTn (hostrom_cdbgpwrupreq_qacceptn),
  .PWRQDENY    (hostrom_cdbgpwrupreq_qdeny),
  .PWRQACTIVE  (hostrom_cdbgpwrupreq_qactive),

  .CLKQACTIVE  (hostrom_cdbgpwrup_reqack_clkqactive_ctrlclk)
);




wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_dbgpwrupreq_ss;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_dbgpwrupreq_sync_active;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_wakeupreq_ss;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_wakeupreq_sync_active;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_warmrstreq_ss;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_warmrstreq_sync_active;
wire  [HOST_CPU_NUM_CORES-1:0]  hostcpu_standbywfi_ss;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_standbywfi_sync_active;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_corewakeup_ss;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_corewakeup_sync_active;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_cpuqactive_ss;
wire [HOST_CPU_NUM_CORES-1:0]  cpuqactive_sync_active;
wire clustop_internal_l2_qactive_ss;
wire clustop_l2qactive_sync_active;
wire clustop_mem_ret_sync_active;

arm_element_cdc_capt_sync 
u_clustop_pactive_mem_ret_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (host_cpu_clus_pwr_req_mem_ret_r),
  .q       (host_cpu_clus_pwr_req_mem_ret_ss)
);

arm_element_std_xor2 u_mem_ret_sync_active_xor ( .A (host_cpu_clus_pwr_req_mem_ret_r), .B (host_cpu_clus_pwr_req_mem_ret_ss), .Y (clustop_mem_ret_sync_active));

arm_element_cdc_capt_sync u_core3_dbgpwrupreq_sync        (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_dbgpwrupreq[3]), .q (hostcpu_dbgpwrupreq_ss[3]));
arm_element_cdc_capt_sync u_core3_wakeupreq_sync          (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_wakeupreq[3]), .q (hostcpu_wakeupreq_ss[3]));
arm_element_cdc_capt_sync u_core3_warmrstreq_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_warmrstreq[3]), .q (hostcpu_warmrstreq_ss[3]));
arm_element_cdc_capt_sync u_core3_wakeup_sync             (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_corewakeup[3]), .q (hostcpu_corewakeup_ss[3]));
arm_element_cdc_capt_sync u_core3_cpuqactive_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_cpuqactive[3]), .q (hostcpu_cpuqactive_ss[3]));
arm_element_cdc_capt_sync_set u_core3_standbywfi_sync     (.clk (ctrlclk), .nset (ctrlresetn), .d_async (hostcpu_standbywfi[3]), .q (hostcpu_standbywfi_ss[3]));

arm_element_std_xor2 u_core3_wakeup_sync_active_xor           (.A (hostcpu_corewakeup[3]), .B (hostcpu_corewakeup_ss[3]), .Y (hostcpu_corewakeup_sync_active[3]));
arm_element_std_xor2 u_core3_cpuqactive_sync_active_xor       (.A (hostcpu_cpuqactive[3]), .B (hostcpu_cpuqactive_ss[3]), .Y (cpuqactive_sync_active[3]));
arm_element_std_xor2 u_core3_dbgpwrupreq_sync_active_xor      (.A (hostcpu_dbgpwrupreq[3]), .B (hostcpu_dbgpwrupreq_ss[3]), .Y (hostcpu_dbgpwrupreq_sync_active[3]));
arm_element_std_xor2 u_core3_wakeupreq_sync_active_xor        (.A (hostcpu_wakeupreq[3]), .B (hostcpu_wakeupreq_ss[3]), .Y (hostcpu_wakeupreq_sync_active[3]));
arm_element_std_xor2 u_core3_warmrstreq_sync_active_xor       (.A (hostcpu_warmrstreq[3]), .B (hostcpu_warmrstreq_ss[3]), .Y (hostcpu_warmrstreq_sync_active[3]));
arm_element_std_xor2 u_core3_standbywfi_sync_active_xor       (.A (hostcpu_standbywfi[3]), .B (hostcpu_standbywfi_ss[3]), .Y (hostcpu_standbywfi_sync_active[3]));
arm_element_cdc_capt_sync u_core2_dbgpwrupreq_sync        (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_dbgpwrupreq[2]), .q (hostcpu_dbgpwrupreq_ss[2]));
arm_element_cdc_capt_sync u_core2_wakeupreq_sync          (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_wakeupreq[2]), .q (hostcpu_wakeupreq_ss[2]));
arm_element_cdc_capt_sync u_core2_warmrstreq_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_warmrstreq[2]), .q (hostcpu_warmrstreq_ss[2]));
arm_element_cdc_capt_sync u_core2_wakeup_sync             (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_corewakeup[2]), .q (hostcpu_corewakeup_ss[2]));
arm_element_cdc_capt_sync u_core2_cpuqactive_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_cpuqactive[2]), .q (hostcpu_cpuqactive_ss[2]));
arm_element_cdc_capt_sync_set u_core2_standbywfi_sync     (.clk (ctrlclk), .nset (ctrlresetn), .d_async (hostcpu_standbywfi[2]), .q (hostcpu_standbywfi_ss[2]));

arm_element_std_xor2 u_core2_wakeup_sync_active_xor           (.A (hostcpu_corewakeup[2]), .B (hostcpu_corewakeup_ss[2]), .Y (hostcpu_corewakeup_sync_active[2]));
arm_element_std_xor2 u_core2_cpuqactive_sync_active_xor       (.A (hostcpu_cpuqactive[2]), .B (hostcpu_cpuqactive_ss[2]), .Y (cpuqactive_sync_active[2]));
arm_element_std_xor2 u_core2_dbgpwrupreq_sync_active_xor      (.A (hostcpu_dbgpwrupreq[2]), .B (hostcpu_dbgpwrupreq_ss[2]), .Y (hostcpu_dbgpwrupreq_sync_active[2]));
arm_element_std_xor2 u_core2_wakeupreq_sync_active_xor        (.A (hostcpu_wakeupreq[2]), .B (hostcpu_wakeupreq_ss[2]), .Y (hostcpu_wakeupreq_sync_active[2]));
arm_element_std_xor2 u_core2_warmrstreq_sync_active_xor       (.A (hostcpu_warmrstreq[2]), .B (hostcpu_warmrstreq_ss[2]), .Y (hostcpu_warmrstreq_sync_active[2]));
arm_element_std_xor2 u_core2_standbywfi_sync_active_xor       (.A (hostcpu_standbywfi[2]), .B (hostcpu_standbywfi_ss[2]), .Y (hostcpu_standbywfi_sync_active[2]));
arm_element_cdc_capt_sync u_core1_dbgpwrupreq_sync        (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_dbgpwrupreq[1]), .q (hostcpu_dbgpwrupreq_ss[1]));
arm_element_cdc_capt_sync u_core1_wakeupreq_sync          (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_wakeupreq[1]), .q (hostcpu_wakeupreq_ss[1]));
arm_element_cdc_capt_sync u_core1_warmrstreq_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_warmrstreq[1]), .q (hostcpu_warmrstreq_ss[1]));
arm_element_cdc_capt_sync u_core1_wakeup_sync             (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_corewakeup[1]), .q (hostcpu_corewakeup_ss[1]));
arm_element_cdc_capt_sync u_core1_cpuqactive_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_cpuqactive[1]), .q (hostcpu_cpuqactive_ss[1]));
arm_element_cdc_capt_sync_set u_core1_standbywfi_sync     (.clk (ctrlclk), .nset (ctrlresetn), .d_async (hostcpu_standbywfi[1]), .q (hostcpu_standbywfi_ss[1]));

arm_element_std_xor2 u_core1_wakeup_sync_active_xor           (.A (hostcpu_corewakeup[1]), .B (hostcpu_corewakeup_ss[1]), .Y (hostcpu_corewakeup_sync_active[1]));
arm_element_std_xor2 u_core1_cpuqactive_sync_active_xor       (.A (hostcpu_cpuqactive[1]), .B (hostcpu_cpuqactive_ss[1]), .Y (cpuqactive_sync_active[1]));
arm_element_std_xor2 u_core1_dbgpwrupreq_sync_active_xor      (.A (hostcpu_dbgpwrupreq[1]), .B (hostcpu_dbgpwrupreq_ss[1]), .Y (hostcpu_dbgpwrupreq_sync_active[1]));
arm_element_std_xor2 u_core1_wakeupreq_sync_active_xor        (.A (hostcpu_wakeupreq[1]), .B (hostcpu_wakeupreq_ss[1]), .Y (hostcpu_wakeupreq_sync_active[1]));
arm_element_std_xor2 u_core1_warmrstreq_sync_active_xor       (.A (hostcpu_warmrstreq[1]), .B (hostcpu_warmrstreq_ss[1]), .Y (hostcpu_warmrstreq_sync_active[1]));
arm_element_std_xor2 u_core1_standbywfi_sync_active_xor       (.A (hostcpu_standbywfi[1]), .B (hostcpu_standbywfi_ss[1]), .Y (hostcpu_standbywfi_sync_active[1]));
arm_element_cdc_capt_sync u_core0_dbgpwrupreq_sync        (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_dbgpwrupreq[0]), .q (hostcpu_dbgpwrupreq_ss[0]));
arm_element_cdc_capt_sync u_core0_wakeupreq_sync          (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_wakeupreq[0]), .q (hostcpu_wakeupreq_ss[0]));
arm_element_cdc_capt_sync u_core0_warmrstreq_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_warmrstreq[0]), .q (hostcpu_warmrstreq_ss[0]));
arm_element_cdc_capt_sync u_core0_wakeup_sync             (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_corewakeup[0]), .q (hostcpu_corewakeup_ss[0]));
arm_element_cdc_capt_sync u_core0_cpuqactive_sync         (.clk (ctrlclk), .nreset (ctrlresetn), .d_async (hostcpu_cpuqactive[0]), .q (hostcpu_cpuqactive_ss[0]));
arm_element_cdc_capt_sync_set u_core0_standbywfi_sync     (.clk (ctrlclk), .nset (ctrlresetn), .d_async (hostcpu_standbywfi[0]), .q (hostcpu_standbywfi_ss[0]));

arm_element_std_xor2 u_core0_wakeup_sync_active_xor           (.A (hostcpu_corewakeup[0]), .B (hostcpu_corewakeup_ss[0]), .Y (hostcpu_corewakeup_sync_active[0]));
arm_element_std_xor2 u_core0_cpuqactive_sync_active_xor       (.A (hostcpu_cpuqactive[0]), .B (hostcpu_cpuqactive_ss[0]), .Y (cpuqactive_sync_active[0]));
arm_element_std_xor2 u_core0_dbgpwrupreq_sync_active_xor      (.A (hostcpu_dbgpwrupreq[0]), .B (hostcpu_dbgpwrupreq_ss[0]), .Y (hostcpu_dbgpwrupreq_sync_active[0]));
arm_element_std_xor2 u_core0_wakeupreq_sync_active_xor        (.A (hostcpu_wakeupreq[0]), .B (hostcpu_wakeupreq_ss[0]), .Y (hostcpu_wakeupreq_sync_active[0]));
arm_element_std_xor2 u_core0_warmrstreq_sync_active_xor       (.A (hostcpu_warmrstreq[0]), .B (hostcpu_warmrstreq_ss[0]), .Y (hostcpu_warmrstreq_sync_active[0]));
arm_element_std_xor2 u_core0_standbywfi_sync_active_xor       (.A (hostcpu_standbywfi[0]), .B (hostcpu_standbywfi_ss[0]), .Y (hostcpu_standbywfi_sync_active[0]));


wire [HOST_CPU_NUM_CORES-1:0]  core_ppuhwstat_bit0_inv;
wire [HOST_CPU_NUM_CORES-1:0]  clustop_pactive_on_and2_out;
arm_element_std_inverter u_core3_ppuhwstat_inv (.inv_in (core_ppuhwstat[48]), .inv_out (core_ppuhwstat_bit0_inv[3]));
arm_element_std_inverter u_core2_ppuhwstat_inv (.inv_in (core_ppuhwstat[32]), .inv_out (core_ppuhwstat_bit0_inv[2]));
arm_element_std_inverter u_core1_ppuhwstat_inv (.inv_in (core_ppuhwstat[16]), .inv_out (core_ppuhwstat_bit0_inv[1]));
arm_element_std_inverter u_core0_ppuhwstat_inv (.inv_in (core_ppuhwstat[0]), .inv_out (core_ppuhwstat_bit0_inv[0]));

arm_element_cdc_capt_sync 
u_clustop_l2_qactive_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (clustop_internal_l2_qactive),
  .q       (clustop_internal_l2_qactive_ss)
);

arm_element_std_xor2 u_clustop_l2_qactive_sync_active_xor ( .A (clustop_internal_l2_qactive), .B (clustop_internal_l2_qactive_ss), .Y (clustop_l2qactive_sync_active));

arm_element_cdc_comb_and2 #(.WIDTH (HOST_CPU_NUM_CORES))
u_clustop_ppu_pactive_on_and2 (
  .din1_async ({HOST_CPU_NUM_CORES{clustop_internal_l2_qactive_ss}}),
  .din2_async (core_ppuhwstat_bit0_inv),
  .dout_async (clustop_pactive_on_and2_out)
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (HOST_CPU_NUM_CORES))
u_clustop_ppu_pactive_on_or_tree (
  .or_tree_i (clustop_pactive_on_and2_out),
  .or_tree_o (clustop_ppu_pactive_on_bit)
);


wire atleast_one_core_on;
wire gic_wakeup_with_enable;
wire system_interrupt_wakeup_enable;
wire router_interrupt_wakeup_enable;
wire hostcpu_standbywfil2_inv;
wire [HOST_CPU_NUM_CORES-1:0] core_is_off_or_offemu;
wire [HOST_CPU_NUM_CORES-1:0] core_wakeup;

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (HOST_CPU_NUM_CORES))
u_atleast_one_core_on_or_tree (
  .or_tree_i (core_ppuhwstat_bit0_inv),
  .or_tree_o (atleast_one_core_on)
);

arm_element_cdc_comb_and2 u_gic_wakeup_and2       (.din1_async (gic_wakeup), .din2_async (bsys_pwr_req_wakeup_en), .dout_async (gic_wakeup_with_enable));
arm_element_cdc_comb_and2 u_system_interrupt_and2 (.din1_async (system_interrupt_wakeup_clus), .din2_async (bsys_pwr_req_wakeup_en), .dout_async (system_interrupt_wakeup_enable));
arm_element_cdc_comb_and2 u_router_interrupt_and2 (.din1_async (router_interrupt_wakeup_clus), .din2_async (bsys_pwr_req_wakeup_en), .dout_async (router_interrupt_wakeup_enable));
arm_element_std_inverter u_standbywfil2_inv (.inv_in (hostcpu_standbywfil2), .inv_out (hostcpu_standbywfil2_inv));

assign core_is_off_or_offemu[3] = core_ppuhwstat[48]  | core_ppuhwstat[49];
assign core_is_off_or_offemu[2] = core_ppuhwstat[32]  | core_ppuhwstat[33];
assign core_is_off_or_offemu[1] = core_ppuhwstat[16]  | core_ppuhwstat[17];
assign core_is_off_or_offemu[0] = core_ppuhwstat[0]  | core_ppuhwstat[1];

arm_element_cdc_comb_and2 #(.WIDTH (HOST_CPU_NUM_CORES))
u_core_wakeup_and2 (
  .din1_async (hostcpu_corewakeup_ss[HOST_CPU_NUM_CORES-1:0]),
  .din2_async (core_is_off_or_offemu),
  .dout_async (core_wakeup)
);


arm_element_or_tree #(.NUM_OR_TREE_INPUTS (11+HOST_CPU_NUM_CORES))
u_clustop_pactive_func_ret_or_tree (
  .or_tree_i ({host_cpu_clus_pwr_req_pwr_req,
               atleast_one_core_on,
               gic_wakeup_with_enable,
               system_interrupt_wakeup_enable,
               router_interrupt_wakeup_enable,
               clustop_egress_qactive,
               clustop_ingress_qactive,
               hostcpu_ctichout_active,
               hostrom_cdbgpwrupreq_qactive,
               axiap_csyspwrupreq_qactive,
               hostcpu_standbywfil2_inv,
               core_wakeup}),
  .or_tree_o (clustop_ppu_pactive_func_ret_bit)
);


wire [9:0] clustop_ppu_pactive_func_ret_bit_sticky;

pactive_pulse_converter #(
    .PACTIVE_SYNC(1'b1)
)
u_clustop_pactive_on_glitch  
(
   .clk (ctrlclk),
   .resetn(ctrlresetn),
   .pactive_in({2'd0,clustop_ppu_pactive_func_ret_bit,7'd0}),
   .pactive_out(clustop_ppu_pactive_func_ret_bit_sticky),
   .ppuhwstat(clustop_ppuhwstat_o[8:0]),
   .qactive(clustop_pactive_on_glitch_qactive_ctrlclk)
);
    
assign clustop_ppu_pactive_func_ret_bit_ss = clustop_ppu_pactive_func_ret_bit_sticky[7];
    
arm_element_cdc_comb_and2 u_clustop_ppu_pactive_func_ret_bit_gated ( .din1_async( clustop_ppu_pactive_func_ret_bit_en ),  
                                                                     .din2_async( clustop_ppu_pactive_func_ret_bit_ss ),
                                                                     .dout_async( clustop_ppu_pactive_func_ret_bit_gated));
       
assign systop_ingress_qactive = clustop_ppu_pactive_func_ret_bit_gated;

arm_element_cdc_capt_sync 
u_systop_ingress_qreqn_pactive_on_sync (
  .clk    (ctrlclk_free),
  .nreset (ctrlresetn),

  .d_async (systop_ingress_qreqn),
  .q       (systop_ingress_qreqn_ss)
);

wire clustop_ppu_not_off;
wire ppu_active;

assign clustop_ppu_not_off = ~(clustop_ppuhwstat_o[0] | clustop_ppuhwstat_o[2]);

assign ppu_active = (ctrlclk_qactive[4] | clustop_ppu_pactive_func_ret_bit_ss);

sse710_hierarchical_pd_dependency #(.PACTIVE_WIDTH (1))
u_systop_clustop_dependency_q_chan (
  .clk        (ctrlclk),
  .resetn     (ctrlresetn),

  .pactive           (ppu_active),
  .ppuhwstat_not_off (clustop_ppu_not_off),

  .pwr_qreqn      (systop_ingress_qreqn_ss),
  .pwr_qacceptn   (systop_ingress_qacceptn),
  .pwr_qdeny      (systop_ingress_qdeny),
  
  .clk_qactive    (systop_clustop_dependency_qactive), 

  .pactive_en (clustop_ppu_pactive_func_ret_bit_en)
);
 


wire [HOST_CPU_NUM_CORES-1:0] core_pactive_not_off;
wire [HOST_CPU_NUM_CORES-1:0] core_pactive_enable;

wire [HOST_CPU_NUM_CORES-1:0] pactive_offemu_sync_active;
wire [HOST_CPU_NUM_CORES-1:0] pactive_warmrst_sync_active;
wire [HOST_CPU_NUM_CORES-1:0] smpen_sync_active;

wire                core_ppuhwstat_not_off;
wire                all_core_ppuhwstat_off;

assign all_core_ppuhwstat_off = ( core_ppuhwstat[48] & core_ppuhwstat[32] & core_ppuhwstat[16] & core_ppuhwstat[0]);

assign core_ppuhwstat_not_off = ~(all_core_ppuhwstat_off);

sse710_hierarchical_pd_dependency #(.PACTIVE_WIDTH (HOST_CPU_NUM_CORES))
u_clustop_core_dependency_q_chan (
  .clk        (ctrlclk),
  .resetn     (ctrlresetn),

  .pactive           (core_pactive_not_off),
  .ppuhwstat_not_off (core_ppuhwstat_not_off),

  .pwr_qreqn      (clustop_core_dependency_qreqn),
  .pwr_qacceptn   (clustop_core_dependency_qacceptn),
  .pwr_qdeny      (clustop_core_dependency_qdeny),

  .clk_qactive    (clustop_core_dependency_qactive),

  .pactive_en (core_pactive_enable)
);


arm_element_cdc_capt_sync
u_core0_pactive_warmrst_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_warmrst_bit[0]),
  .q       (coreppu_pactive_warmrst_bit_ss[0])
);

arm_element_std_xor2 u_core0_pactive_warmrst_sync_active_xor (
  .A (coreppu_pactive_warmrst_bit[0]),
  .B (coreppu_pactive_warmrst_bit_ss[0]),

  .Y (pactive_warmrst_sync_active[0])
);

arm_element_cdc_capt_sync
u_core0_smpen_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (hostcpu_smpen[0]),
  .q       (hostcpu_smpen_ss[0])
);

arm_element_std_xor2 u_core0_mpen_sync_active_xor (
  .A (hostcpu_smpen[0]),
  .B (hostcpu_smpen_ss[0]),

  .Y (smpen_sync_active[0])
);

arm_element_std_or2 u_core0_pactive_offemu_or2 (
  .A (hostcpu_dbgnopwrdwn[0]),
  .B (hostcpu_dbgpwrupreq_ss[0]),
  .Y (coreppu_pactive_offemu_bit[0])
);

arm_element_cdc_capt_sync
u_core0_pactive_offemu_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_offemu_bit[0]),
  .q       (coreppu_pactive_offemu_bit_ss[0])
);

arm_element_std_xor2 u_core0_pactive_offemu_sync_active_xor (
  .A (coreppu_pactive_offemu_bit[0]),
  .B (coreppu_pactive_offemu_bit_ss[0]),

  .Y (pactive_offemu_sync_active[0])
);


arm_element_cdc_comb_and2 #(.WIDTH (4))
u_core0_pactive_enable_and2 (
  .din1_async ({4{core_pactive_enable[0]}}),
  .din2_async ({coreppu_pactive_on_bit_sticky[8],
                coreppu_pactive_warmrst_bit_ss[0],
                hostcpu_smpen_ss[0],
                coreppu_pactive_offemu_bit_ss[0]}),

  .dout_async ({coreppu_pactive_on_bit_enabled[0],
                coreppu_pactive_warmrst_bit_enabled[0],
                coreppu_pactive_fullret_bit_enabled[0],
                coreppu_pactive_offemu_bit_enabled[0]})
);


  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0011_0010_0010),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_core0_dbgpwrdup_gen (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (dbgpwrdup_gen_preq[0]),
    .ctrl_pstate_i    ({4'b0000,dbgpwrdup_gen_pstate[0+:4]}),
    .ctrl_paccept_o   (dbgpwrdup_gen_paccept[0]),
    .ctrl_pdeny_o     (dbgpwrdup_gen_pdeny[0]),
    .ctrl_pactive_o   ( ),
                       
    .dev_qreqn_o      (hostcpu_dbgpwrdup[0]),
    .dev_qacceptn_i   (hostcpu_dbgpwrdup[0]),
    .dev_qdeny_i      (1'b0),
    .dev_qactive_i    (1'b0),
                       
    .clk_qactive_o    (core_dbgpwrdup_gen_ctrlclk_clkqactive[0]),
                       
    .dftcgen          (dftcgen)
  );


arm_element_cdc_capt_sync
u_core1_pactive_warmrst_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_warmrst_bit[1]),
  .q       (coreppu_pactive_warmrst_bit_ss[1])
);

arm_element_std_xor2 u_core1_pactive_warmrst_sync_active_xor (
  .A (coreppu_pactive_warmrst_bit[1]),
  .B (coreppu_pactive_warmrst_bit_ss[1]),

  .Y (pactive_warmrst_sync_active[1])
);

arm_element_cdc_capt_sync
u_core1_smpen_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (hostcpu_smpen[1]),
  .q       (hostcpu_smpen_ss[1])
);

arm_element_std_xor2 u_core1_mpen_sync_active_xor (
  .A (hostcpu_smpen[1]),
  .B (hostcpu_smpen_ss[1]),

  .Y (smpen_sync_active[1])
);

arm_element_std_or2 u_core1_pactive_offemu_or2 (
  .A (hostcpu_dbgnopwrdwn[1]),
  .B (hostcpu_dbgpwrupreq_ss[1]),
  .Y (coreppu_pactive_offemu_bit[1])
);

arm_element_cdc_capt_sync
u_core1_pactive_offemu_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_offemu_bit[1]),
  .q       (coreppu_pactive_offemu_bit_ss[1])
);

arm_element_std_xor2 u_core1_pactive_offemu_sync_active_xor (
  .A (coreppu_pactive_offemu_bit[1]),
  .B (coreppu_pactive_offemu_bit_ss[1]),

  .Y (pactive_offemu_sync_active[1])
);


arm_element_cdc_comb_and2 #(.WIDTH (4))
u_core1_pactive_enable_and2 (
  .din1_async ({4{core_pactive_enable[1]}}),
  .din2_async ({coreppu_pactive_on_bit_sticky[18],
                coreppu_pactive_warmrst_bit_ss[1],
                hostcpu_smpen_ss[1],
                coreppu_pactive_offemu_bit_ss[1]}),

  .dout_async ({coreppu_pactive_on_bit_enabled[1],
                coreppu_pactive_warmrst_bit_enabled[1],
                coreppu_pactive_fullret_bit_enabled[1],
                coreppu_pactive_offemu_bit_enabled[1]})
);


  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0011_0010_0010),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_core1_dbgpwrdup_gen (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (dbgpwrdup_gen_preq[1]),
    .ctrl_pstate_i    ({4'b0000,dbgpwrdup_gen_pstate[4+:4]}),
    .ctrl_paccept_o   (dbgpwrdup_gen_paccept[1]),
    .ctrl_pdeny_o     (dbgpwrdup_gen_pdeny[1]),
    .ctrl_pactive_o   ( ),
                       
    .dev_qreqn_o      (hostcpu_dbgpwrdup[1]),
    .dev_qacceptn_i   (hostcpu_dbgpwrdup[1]),
    .dev_qdeny_i      (1'b0),
    .dev_qactive_i    (1'b0),
                       
    .clk_qactive_o    (core_dbgpwrdup_gen_ctrlclk_clkqactive[1]),
                       
    .dftcgen          (dftcgen)
  );


arm_element_cdc_capt_sync
u_core2_pactive_warmrst_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_warmrst_bit[2]),
  .q       (coreppu_pactive_warmrst_bit_ss[2])
);

arm_element_std_xor2 u_core2_pactive_warmrst_sync_active_xor (
  .A (coreppu_pactive_warmrst_bit[2]),
  .B (coreppu_pactive_warmrst_bit_ss[2]),

  .Y (pactive_warmrst_sync_active[2])
);

arm_element_cdc_capt_sync
u_core2_smpen_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (hostcpu_smpen[2]),
  .q       (hostcpu_smpen_ss[2])
);

arm_element_std_xor2 u_core2_mpen_sync_active_xor (
  .A (hostcpu_smpen[2]),
  .B (hostcpu_smpen_ss[2]),

  .Y (smpen_sync_active[2])
);

arm_element_std_or2 u_core2_pactive_offemu_or2 (
  .A (hostcpu_dbgnopwrdwn[2]),
  .B (hostcpu_dbgpwrupreq_ss[2]),
  .Y (coreppu_pactive_offemu_bit[2])
);

arm_element_cdc_capt_sync
u_core2_pactive_offemu_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_offemu_bit[2]),
  .q       (coreppu_pactive_offemu_bit_ss[2])
);

arm_element_std_xor2 u_core2_pactive_offemu_sync_active_xor (
  .A (coreppu_pactive_offemu_bit[2]),
  .B (coreppu_pactive_offemu_bit_ss[2]),

  .Y (pactive_offemu_sync_active[2])
);


arm_element_cdc_comb_and2 #(.WIDTH (4))
u_core2_pactive_enable_and2 (
  .din1_async ({4{core_pactive_enable[2]}}),
  .din2_async ({coreppu_pactive_on_bit_sticky[28],
                coreppu_pactive_warmrst_bit_ss[2],
                hostcpu_smpen_ss[2],
                coreppu_pactive_offemu_bit_ss[2]}),

  .dout_async ({coreppu_pactive_on_bit_enabled[2],
                coreppu_pactive_warmrst_bit_enabled[2],
                coreppu_pactive_fullret_bit_enabled[2],
                coreppu_pactive_offemu_bit_enabled[2]})
);


  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0011_0010_0010),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_core2_dbgpwrdup_gen (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (dbgpwrdup_gen_preq[2]),
    .ctrl_pstate_i    ({4'b0000,dbgpwrdup_gen_pstate[8+:4]}),
    .ctrl_paccept_o   (dbgpwrdup_gen_paccept[2]),
    .ctrl_pdeny_o     (dbgpwrdup_gen_pdeny[2]),
    .ctrl_pactive_o   ( ),
                       
    .dev_qreqn_o      (hostcpu_dbgpwrdup[2]),
    .dev_qacceptn_i   (hostcpu_dbgpwrdup[2]),
    .dev_qdeny_i      (1'b0),
    .dev_qactive_i    (1'b0),
                       
    .clk_qactive_o    (core_dbgpwrdup_gen_ctrlclk_clkqactive[2]),
                       
    .dftcgen          (dftcgen)
  );


arm_element_cdc_capt_sync
u_core3_pactive_warmrst_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_warmrst_bit[3]),
  .q       (coreppu_pactive_warmrst_bit_ss[3])
);

arm_element_std_xor2 u_core3_pactive_warmrst_sync_active_xor (
  .A (coreppu_pactive_warmrst_bit[3]),
  .B (coreppu_pactive_warmrst_bit_ss[3]),

  .Y (pactive_warmrst_sync_active[3])
);

arm_element_cdc_capt_sync
u_core3_smpen_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (hostcpu_smpen[3]),
  .q       (hostcpu_smpen_ss[3])
);

arm_element_std_xor2 u_core3_mpen_sync_active_xor (
  .A (hostcpu_smpen[3]),
  .B (hostcpu_smpen_ss[3]),

  .Y (smpen_sync_active[3])
);

arm_element_std_or2 u_core3_pactive_offemu_or2 (
  .A (hostcpu_dbgnopwrdwn[3]),
  .B (hostcpu_dbgpwrupreq_ss[3]),
  .Y (coreppu_pactive_offemu_bit[3])
);

arm_element_cdc_capt_sync
u_core3_pactive_offemu_sync (
  .clk    (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (coreppu_pactive_offemu_bit[3]),
  .q       (coreppu_pactive_offemu_bit_ss[3])
);

arm_element_std_xor2 u_core3_pactive_offemu_sync_active_xor (
  .A (coreppu_pactive_offemu_bit[3]),
  .B (coreppu_pactive_offemu_bit_ss[3]),

  .Y (pactive_offemu_sync_active[3])
);


arm_element_cdc_comb_and2 #(.WIDTH (4))
u_core3_pactive_enable_and2 (
  .din1_async ({4{core_pactive_enable[3]}}),
  .din2_async ({coreppu_pactive_on_bit_sticky[38],
                coreppu_pactive_warmrst_bit_ss[3],
                hostcpu_smpen_ss[3],
                coreppu_pactive_offemu_bit_ss[3]}),

  .dout_async ({coreppu_pactive_on_bit_enabled[3],
                coreppu_pactive_warmrst_bit_enabled[3],
                coreppu_pactive_fullret_bit_enabled[3],
                coreppu_pactive_offemu_bit_enabled[3]})
);


  pck600_p2q #(
    .CTRL_P_CH_SYNC (0),
    .DEV_Q_CH_SYNC (0),
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0011_0010_0010),
    .CTRL_P_CH_OP_PSTATE_MAP (16'b1111_1111_1111_1111),
    .CTRL_P_CH_PACTIVE (32'd0)
  ) u_core3_dbgpwrdup_gen (
    .clk              (ctrlclk),
    .reset_n          (ctrlresetn),

    .ctrl_preq_i      (dbgpwrdup_gen_preq[3]),
    .ctrl_pstate_i    ({4'b0000,dbgpwrdup_gen_pstate[12+:4]}),
    .ctrl_paccept_o   (dbgpwrdup_gen_paccept[3]),
    .ctrl_pdeny_o     (dbgpwrdup_gen_pdeny[3]),
    .ctrl_pactive_o   ( ),
                       
    .dev_qreqn_o      (hostcpu_dbgpwrdup[3]),
    .dev_qacceptn_i   (hostcpu_dbgpwrdup[3]),
    .dev_qdeny_i      (1'b0),
    .dev_qactive_i    (1'b0),
                       
    .clk_qactive_o    (core_dbgpwrdup_gen_ctrlclk_clkqactive[3]),
                       
    .dftcgen          (dftcgen)
  );


arm_element_or_tree #(.NUM_OR_TREE_INPUTS (9*HOST_CPU_NUM_CORES))
u_core_pactive_sync_active (
  .or_tree_i ({pactive_offemu_sync_active,
               smpen_sync_active,
               pactive_warmrst_sync_active,
               cpuqactive_sync_active,
               hostcpu_wakeupreq_sync_active,
               hostcpu_dbgpwrupreq_sync_active,
               hostcpu_warmrstreq_sync_active,
               hostcpu_standbywfi_sync_active,
               hostcpu_corewakeup_sync_active
             }),

  .or_tree_o (core_pactive_sync_active_ctrclk)
);



wire [HOST_CPU_NUM_CORES-1:0]  core_boot_up;

wire [HOST_CPU_NUM_CORES-1:0] warmrstreq_and_standbywfi_asserted;

wire [HOST_CPU_NUM_CORES-1:0] core_in_fullret_on_warmrst;
wire [HOST_CPU_NUM_CORES-1:0] cpuqactive_and_smpen;
wire [HOST_CPU_NUM_CORES-1:0] smpen_with_active_when_pwrdup;
wire [HOST_CPU_NUM_CORES-1:0] dbgpwrupreq_when_core_off;
wire [HOST_CPU_NUM_CORES-1:0] hostcpu_standbywfi_inv;
wire [HOST_CPU_NUM_CORES-1:0] irqwakeup_when_off_or_offemu;

assign core_ppu_gic_irq_wakeupreq = hostcpu_wakeupreq_ss;


arm_element_std_or3 u_core0_fullret_on_warmrst_or3 (
  .A (core_ppuhwstat[5]),
  .B (core_ppuhwstat[8]),
  .C (core_ppuhwstat[9]),

  .Y (core_in_fullret_on_warmrst[0])
);

arm_element_cdc_comb_and2 u_core0_qactive_smpen_and2 (
  .din1_async (hostcpu_cpuqactive_ss[0]),
  .din2_async (hostcpu_smpen_ss[0]),

  .dout_async (cpuqactive_and_smpen[0])
);

arm_element_cdc_comb_and2 u_core0_smpen_with_active_when_pwrdup_and2 (
  .din1_async (core_in_fullret_on_warmrst[0]),
  .din2_async (cpuqactive_and_smpen[0]),

  .dout_async (smpen_with_active_when_pwrdup[0])
);

arm_element_cdc_comb_and2 u_core0_dbgpwrupreq_when_off_and2 (
  .din1_async (hostcpu_dbgpwrupreq_ss[0]),
  .din2_async (core_ppuhwstat[0]),

  .dout_async (dbgpwrupreq_when_core_off[0])
);

arm_element_std_inverter u_core0_standbywfi_inv (.inv_in (hostcpu_standbywfi_ss[0]), .inv_out (hostcpu_standbywfi_inv[0]));

arm_element_cdc_comb_and2 u_core0_irqwakeup_and2 (
  .din1_async (core_ppu_gic_irq_wakeupreq[0]),
  .din2_async (core_is_off_or_offemu[0]),

  .dout_async (irqwakeup_when_off_or_offemu[0])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (6))
u_core0_pactive_on_or_tree (
  .or_tree_i ({smpen_with_active_when_pwrdup[0],
               dbgpwrupreq_when_core_off[0],
               hostcpu_standbywfi_inv[0],
               irqwakeup_when_off_or_offemu[0],
               core_wakeup[0],
               core_boot_up[0]}),

  .or_tree_o (coreppu_pactive_on_bit[0])
);

pactive_pulse_converter #(
  .PACTIVE_SYNC (1'b1)
) u_core0_pactive_on_glitch (
  .clk         (ctrlclk),
  .resetn      (ctrlresetn),
  .pactive_in  ({1'd0,coreppu_pactive_on_bit[0],8'd0}),
  .pactive_out (coreppu_pactive_on_bit_sticky[9:0]),
  .ppuhwstat   (core_ppuhwstat[8:0]),
  .qactive     (core_pactive_on_glitch_qactive_ctrlclk[0])
);              


arm_element_cdc_comb_and2 u_core0_warmrstreq_standbywfi_and2 (
  .din1_async (hostcpu_warmrstreq_ss[0]),
  .din2_async (hostcpu_standbywfi_ss[0]),
  .dout_async (warmrstreq_and_standbywfi_asserted[0])
);

arm_element_std_or2 u_core0_pactive_warmrst_or2 (
  .A (hostcpu_dbgrstreq[0]),
  .B (warmrstreq_and_standbywfi_asserted[0]),
  .Y (coreppu_pactive_warmrst_bit[0])
);

arm_element_cdc_capt_sync u_boot_mask_sync0 (
  .clk  (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (host_cpu_boot_msk_boot_msk[0]),
  .q       (boot_mask_ss[0])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS(4))
u_core0_pactive_not_off (
  .or_tree_i ({coreppu_pactive_warmrst_bit_ss[0],
               coreppu_pactive_on_bit_sticky[8],
               hostcpu_smpen_ss[0],
               coreppu_pactive_offemu_bit_ss[0]}),
  .or_tree_o (core_pactive_not_off[0])
);


arm_element_std_or3 u_core1_fullret_on_warmrst_or3 (
  .A (core_ppuhwstat[21]),
  .B (core_ppuhwstat[24]),
  .C (core_ppuhwstat[25]),

  .Y (core_in_fullret_on_warmrst[1])
);

arm_element_cdc_comb_and2 u_core1_qactive_smpen_and2 (
  .din1_async (hostcpu_cpuqactive_ss[1]),
  .din2_async (hostcpu_smpen_ss[1]),

  .dout_async (cpuqactive_and_smpen[1])
);

arm_element_cdc_comb_and2 u_core1_smpen_with_active_when_pwrdup_and2 (
  .din1_async (core_in_fullret_on_warmrst[1]),
  .din2_async (cpuqactive_and_smpen[1]),

  .dout_async (smpen_with_active_when_pwrdup[1])
);

arm_element_cdc_comb_and2 u_core1_dbgpwrupreq_when_off_and2 (
  .din1_async (hostcpu_dbgpwrupreq_ss[1]),
  .din2_async (core_ppuhwstat[16]),

  .dout_async (dbgpwrupreq_when_core_off[1])
);

arm_element_std_inverter u_core1_standbywfi_inv (.inv_in (hostcpu_standbywfi_ss[1]), .inv_out (hostcpu_standbywfi_inv[1]));

arm_element_cdc_comb_and2 u_core1_irqwakeup_and2 (
  .din1_async (core_ppu_gic_irq_wakeupreq[1]),
  .din2_async (core_is_off_or_offemu[1]),

  .dout_async (irqwakeup_when_off_or_offemu[1])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (6))
u_core1_pactive_on_or_tree (
  .or_tree_i ({smpen_with_active_when_pwrdup[1],
               dbgpwrupreq_when_core_off[1],
               hostcpu_standbywfi_inv[1],
               irqwakeup_when_off_or_offemu[1],
               core_wakeup[1],
               core_boot_up[1]}),

  .or_tree_o (coreppu_pactive_on_bit[1])
);

pactive_pulse_converter #(
  .PACTIVE_SYNC (1'b1)
) u_core1_pactive_on_glitch (
  .clk         (ctrlclk),
  .resetn      (ctrlresetn),
  .pactive_in  ({1'd0,coreppu_pactive_on_bit[1],8'd0}),
  .pactive_out (coreppu_pactive_on_bit_sticky[19:10]),
  .ppuhwstat   (core_ppuhwstat[24:16]),
  .qactive     (core_pactive_on_glitch_qactive_ctrlclk[1])
);              


arm_element_cdc_comb_and2 u_core1_warmrstreq_standbywfi_and2 (
  .din1_async (hostcpu_warmrstreq_ss[1]),
  .din2_async (hostcpu_standbywfi_ss[1]),
  .dout_async (warmrstreq_and_standbywfi_asserted[1])
);

arm_element_std_or2 u_core1_pactive_warmrst_or2 (
  .A (hostcpu_dbgrstreq[1]),
  .B (warmrstreq_and_standbywfi_asserted[1]),
  .Y (coreppu_pactive_warmrst_bit[1])
);

arm_element_cdc_capt_sync u_boot_mask_sync1 (
  .clk  (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (host_cpu_boot_msk_boot_msk[1]),
  .q       (boot_mask_ss[1])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS(4))
u_core1_pactive_not_off (
  .or_tree_i ({coreppu_pactive_warmrst_bit_ss[1],
               coreppu_pactive_on_bit_sticky[18],
               hostcpu_smpen_ss[1],
               coreppu_pactive_offemu_bit_ss[1]}),
  .or_tree_o (core_pactive_not_off[1])
);


arm_element_std_or3 u_core2_fullret_on_warmrst_or3 (
  .A (core_ppuhwstat[37]),
  .B (core_ppuhwstat[40]),
  .C (core_ppuhwstat[41]),

  .Y (core_in_fullret_on_warmrst[2])
);

arm_element_cdc_comb_and2 u_core2_qactive_smpen_and2 (
  .din1_async (hostcpu_cpuqactive_ss[2]),
  .din2_async (hostcpu_smpen_ss[2]),

  .dout_async (cpuqactive_and_smpen[2])
);

arm_element_cdc_comb_and2 u_core2_smpen_with_active_when_pwrdup_and2 (
  .din1_async (core_in_fullret_on_warmrst[2]),
  .din2_async (cpuqactive_and_smpen[2]),

  .dout_async (smpen_with_active_when_pwrdup[2])
);

arm_element_cdc_comb_and2 u_core2_dbgpwrupreq_when_off_and2 (
  .din1_async (hostcpu_dbgpwrupreq_ss[2]),
  .din2_async (core_ppuhwstat[32]),

  .dout_async (dbgpwrupreq_when_core_off[2])
);

arm_element_std_inverter u_core2_standbywfi_inv (.inv_in (hostcpu_standbywfi_ss[2]), .inv_out (hostcpu_standbywfi_inv[2]));

arm_element_cdc_comb_and2 u_core2_irqwakeup_and2 (
  .din1_async (core_ppu_gic_irq_wakeupreq[2]),
  .din2_async (core_is_off_or_offemu[2]),

  .dout_async (irqwakeup_when_off_or_offemu[2])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (6))
u_core2_pactive_on_or_tree (
  .or_tree_i ({smpen_with_active_when_pwrdup[2],
               dbgpwrupreq_when_core_off[2],
               hostcpu_standbywfi_inv[2],
               irqwakeup_when_off_or_offemu[2],
               core_wakeup[2],
               core_boot_up[2]}),

  .or_tree_o (coreppu_pactive_on_bit[2])
);

pactive_pulse_converter #(
  .PACTIVE_SYNC (1'b1)
) u_core2_pactive_on_glitch (
  .clk         (ctrlclk),
  .resetn      (ctrlresetn),
  .pactive_in  ({1'd0,coreppu_pactive_on_bit[2],8'd0}),
  .pactive_out (coreppu_pactive_on_bit_sticky[29:20]),
  .ppuhwstat   (core_ppuhwstat[40:32]),
  .qactive     (core_pactive_on_glitch_qactive_ctrlclk[2])
);              


arm_element_cdc_comb_and2 u_core2_warmrstreq_standbywfi_and2 (
  .din1_async (hostcpu_warmrstreq_ss[2]),
  .din2_async (hostcpu_standbywfi_ss[2]),
  .dout_async (warmrstreq_and_standbywfi_asserted[2])
);

arm_element_std_or2 u_core2_pactive_warmrst_or2 (
  .A (hostcpu_dbgrstreq[2]),
  .B (warmrstreq_and_standbywfi_asserted[2]),
  .Y (coreppu_pactive_warmrst_bit[2])
);

arm_element_cdc_capt_sync u_boot_mask_sync2 (
  .clk  (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (host_cpu_boot_msk_boot_msk[2]),
  .q       (boot_mask_ss[2])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS(4))
u_core2_pactive_not_off (
  .or_tree_i ({coreppu_pactive_warmrst_bit_ss[2],
               coreppu_pactive_on_bit_sticky[28],
               hostcpu_smpen_ss[2],
               coreppu_pactive_offemu_bit_ss[2]}),
  .or_tree_o (core_pactive_not_off[2])
);


arm_element_std_or3 u_core3_fullret_on_warmrst_or3 (
  .A (core_ppuhwstat[53]),
  .B (core_ppuhwstat[56]),
  .C (core_ppuhwstat[57]),

  .Y (core_in_fullret_on_warmrst[3])
);

arm_element_cdc_comb_and2 u_core3_qactive_smpen_and2 (
  .din1_async (hostcpu_cpuqactive_ss[3]),
  .din2_async (hostcpu_smpen_ss[3]),

  .dout_async (cpuqactive_and_smpen[3])
);

arm_element_cdc_comb_and2 u_core3_smpen_with_active_when_pwrdup_and2 (
  .din1_async (core_in_fullret_on_warmrst[3]),
  .din2_async (cpuqactive_and_smpen[3]),

  .dout_async (smpen_with_active_when_pwrdup[3])
);

arm_element_cdc_comb_and2 u_core3_dbgpwrupreq_when_off_and2 (
  .din1_async (hostcpu_dbgpwrupreq_ss[3]),
  .din2_async (core_ppuhwstat[48]),

  .dout_async (dbgpwrupreq_when_core_off[3])
);

arm_element_std_inverter u_core3_standbywfi_inv (.inv_in (hostcpu_standbywfi_ss[3]), .inv_out (hostcpu_standbywfi_inv[3]));

arm_element_cdc_comb_and2 u_core3_irqwakeup_and2 (
  .din1_async (core_ppu_gic_irq_wakeupreq[3]),
  .din2_async (core_is_off_or_offemu[3]),

  .dout_async (irqwakeup_when_off_or_offemu[3])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS (6))
u_core3_pactive_on_or_tree (
  .or_tree_i ({smpen_with_active_when_pwrdup[3],
               dbgpwrupreq_when_core_off[3],
               hostcpu_standbywfi_inv[3],
               irqwakeup_when_off_or_offemu[3],
               core_wakeup[3],
               core_boot_up[3]}),

  .or_tree_o (coreppu_pactive_on_bit[3])
);

pactive_pulse_converter #(
  .PACTIVE_SYNC (1'b1)
) u_core3_pactive_on_glitch (
  .clk         (ctrlclk),
  .resetn      (ctrlresetn),
  .pactive_in  ({1'd0,coreppu_pactive_on_bit[3],8'd0}),
  .pactive_out (coreppu_pactive_on_bit_sticky[39:30]),
  .ppuhwstat   (core_ppuhwstat[56:48]),
  .qactive     (core_pactive_on_glitch_qactive_ctrlclk[3])
);              


arm_element_cdc_comb_and2 u_core3_warmrstreq_standbywfi_and2 (
  .din1_async (hostcpu_warmrstreq_ss[3]),
  .din2_async (hostcpu_standbywfi_ss[3]),
  .dout_async (warmrstreq_and_standbywfi_asserted[3])
);

arm_element_std_or2 u_core3_pactive_warmrst_or2 (
  .A (hostcpu_dbgrstreq[3]),
  .B (warmrstreq_and_standbywfi_asserted[3]),
  .Y (coreppu_pactive_warmrst_bit[3])
);

arm_element_cdc_capt_sync u_boot_mask_sync3 (
  .clk  (ctrlclk),
  .nreset (ctrlresetn),

  .d_async (host_cpu_boot_msk_boot_msk[3]),
  .q       (boot_mask_ss[3])
);

arm_element_or_tree #(.NUM_OR_TREE_INPUTS(4))
u_core3_pactive_not_off (
  .or_tree_i ({coreppu_pactive_warmrst_bit_ss[3],
               coreppu_pactive_on_bit_sticky[38],
               hostcpu_smpen_ss[3],
               coreppu_pactive_offemu_bit_ss[3]}),
  .or_tree_o (core_pactive_not_off[3])
);

 




sse710_core_boot_up #(
  .HOST_CPU_NUM_CORES (HOST_CPU_NUM_CORES)
) u_core_boot_up (
  .clk              (ctrlclk),
  .resetn           (ctrlresetn),

  .clustop_ppuhwstat_0 (clustop_ppuhwstat_o[0]), 
  .clustop_ppuhwstat_2 (clustop_ppuhwstat_o[2]),
  .clustop_ppuhwstat_7 (clustop_ppuhwstat_o[7]),
  .clustop_ppuhwstat_8 (clustop_ppuhwstat_o[8]),
  .clustop_ppuhwstat_9 (clustop_ppuhwstat_o[9]),

  .core_ppuhwstat_on   ({core_ppuhwstat[8]  , core_ppuhwstat[24]  , core_ppuhwstat[40]  , core_ppuhwstat[56] }),
  .boot_mask           (boot_mask_ss),

  .core_boot_up        (core_boot_up)

);


reg l2rstdisable_r;
reg l2rstdisable_nxt;

assign clustop_l2_flush_qdeny = 1'b0;
assign clustop_l2_flush_qactive = 1'b0;

wire hostcpu_l2flushdone_dd;
wire hostcpu_standbywfil2_dd;
wire standbywfil2_sync_active;

arm_element_cdc_capt_sync u_hostcpu_l2flushdone_dd_sync ( .clk(ctrlclk), .nreset(ctrlresetn), .d_async (hostcpu_l2flushdone),   .q(hostcpu_l2flushdone_dd));
arm_element_cdc_capt_sync u_hostcpu_standbywfil2_dd_sync ( .clk(ctrlclk), .nreset(ctrlresetn), .d_async (hostcpu_standbywfil2),   .q(hostcpu_standbywfil2_dd));

arm_element_std_xor2 u_standbywfil2_sync_active_xor ( .A (hostcpu_standbywfil2), .B (hostcpu_standbywfil2_dd), .Y (standbywfil2_sync_active));


sse710_l2flush_handshake u_l2flush_handshake (
  .clk                  (ctrlclk),
  .resetn               (ctrlresetn),

  .l2_flush_qreqn       (clustop_l2_flush_qreqn),
  .l2_flush_qacceptn    (clustop_l2_flush_qacceptn),

  .clustop_dev_pstate   (clustop_dev_pstate_o),
  .hostcpu_standbywfil2 (hostcpu_standbywfil2_dd),
  .clustop_ppuhwstat_0  (clustop_ppuhwstat_o[0]),
  .clustop_ppuhwstat_2  (clustop_ppuhwstat_o[2]),

  .l2flushdone          (hostcpu_l2flushdone_dd),
  .l2flushreq           (hostcpu_l2flushreq)
);

wire l2rstdisable_en;

always @(posedge ctrlclk or negedge ctrlresetn)
begin
  if (~ctrlresetn)
  begin
    l2rstdisable_r <= 1'b0;
  end
  else if (l2rstdisable_en)
  begin
    l2rstdisable_r <= l2rstdisable_nxt;
  end
end

assign l2rstdisable_en = clustop_ppuhwstat_o[2] | clustop_ppuhwstat_o[0] | clustop_ppuhwstat_o[9];

always @*
begin
  l2rstdisable_nxt = clustop_ppuhwstat_o[2] ? 1'b1 : 1'b0;
end

assign hostcpu_l2rstdisable = l2rstdisable_r;


arm_element_or_tree #(
  .NUM_OR_TREE_INPUTS (2*HOST_CPU_NUM_CORES+21)
  ) u_ctrlclk_qactive_pc_cpu (
  .or_tree_i ({clustop_lpd_p_sequencer_qactive_ctrlclk,
               clustop_egress_p2q_clkqactive_ctrlclk, 
               clustop_internal_l2_combined_p2q_clkqactive_ctrlclk, 
               clustop_ingress_p2q_clkqactive_ctrlclk, 
               clustop_ingress_lpd_q_qactive_ctrlclk,
               hostrom_cdbgpwrupreq_p2q_clkqactive_ctrlclk,
               clustop_egress_lpd_q_qactive_ctrlclk, 
               qactive_apb_arbiter_ctrlclk, 
               clustop_l2_lpd_q_qactive_ctrlclk, 
               axiap_csyspwrup_reqack_clkqactive_ctrlclk, 
               hostrom_cdbgpwrup_reqack_clkqactive_ctrlclk, 
               clustop_core_dependency_qactive, 
               core_pactive_sync_active_ctrclk, 
               clustop_lock_logic_qactive, 
               core_lock_logic_qactive, 
               systop_clustop_dependency_qactive, 
               core_p_network_ctrlclk_clkqactive, 
               clustop_pactive_on_glitch_qactive_ctrlclk, 
               core_pactive_on_glitch_qactive_ctrlclk, 
               ppu_dbgen_sync_active,
               standbywfil2_sync_active,
               clustop_l2qactive_sync_active,
               clustop_mem_ret_sync_active}
             ),

  .or_tree_o (pc_cpu_ctrlclk_qactive)
);



 wire unused;


 wire unused_0 ;
 assign unused_0 = (|({coreppu_pactive_on_bit_sticky[9],coreppu_pactive_on_bit_sticky[7:0]}));
 wire unused_1 ;
 assign unused_1 = (|({coreppu_pactive_on_bit_sticky[19],coreppu_pactive_on_bit_sticky[17:10]}));
 wire unused_2 ;
 assign unused_2 = (|({coreppu_pactive_on_bit_sticky[29],coreppu_pactive_on_bit_sticky[27:20]}));
 wire unused_3 ;
 assign unused_3 = (|({coreppu_pactive_on_bit_sticky[39],coreppu_pactive_on_bit_sticky[37:30]}));
 
 wire   unused_core_pactive_on;
 assign unused_core_pactive_on =  unused_0  | unused_1  | unused_2  | unused_3  ;
 
 assign unused = (|core_ppuhwstat[15:10])                        |
                 (|core_ppuhwstat[31:26])                        |
                 (|core_ppuhwstat[47:42])                        |
                 (|core_ppuhwstat[63:58])                        |
                 (unused_core_pactive_on)                        |
                 (|clustop_ppu_pactive_func_ret_bit_sticky[9:8]) | 
                 (|clustop_ppu_pactive_func_ret_bit_sticky[6:0]) | 
                 (|awregion_gic_axim) | 
                 (|awlock_gic_axim)   | 
                 (|awcache_gic_axim)  | 
                 (|awqos_gic_axim)    | 
                 (|arregion_gic_axim) | 
                 (|arlock_gic_axim)   | 
                 (|arcache_gic_axim)  | 
                 (|arqos_gic_axim)    | 
                 (|apbarb_paddr_current_o[31:19])        | 
                 (|apbarb_paddr_current_o[11:0])         | 
                 (|clustop_egress_pactive_i[31:11])      | 
                 (|clustop_internal_l2_pactive_i[31:11]) | 
                 (|hostrom_cdbgpwrupreq_pactive_i[31:11]) | 
                 (|clustop_ingress_pactive_i[31:11]);      
                 

                 
endmodule 
