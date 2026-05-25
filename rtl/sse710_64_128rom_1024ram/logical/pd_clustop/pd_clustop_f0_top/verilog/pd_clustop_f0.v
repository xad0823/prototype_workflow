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
module pd_clustop_f0
  #(parameter
      HOST_CPU_NUM_CORES   = 4,
      NUM_EXP_SHD_INT      = 64,
      HOST_CPU_TYPE        = 1,
      CLUSTOP_CORE_RST_DLY = 0,
      ATB_DATA_WIDTH       = 32,
      CPU_ADDR_WIDTH       = 40,
      CPU_DATA_WIDTH       = 128,
      CPU_AWID_WIDTH       = 8,
      CPU_ARID_WIDTH       = 8,
      CPU_AWUSER_WIDTH     = 2,
      CPU_WUSER_WIDTH      = 0,
      CPU_BUSER_WIDTH      = 0,
      CPU_ARUSER_WIDTH     = 2,
      CPU_RUSER_WIDTH      = 0,
      CPU_AW_FIFO_DEPTH    = 4,
      CPU_W_FIFO_DEPTH     = 6,
      CPU_B_FIFO_DEPTH     = 2,
      CPU_AR_FIFO_DEPTH    = 4,
      CPU_R_FIFO_DEPTH     = 6,
      CPU_AW_PAYLOAD_WIDTH = 316,
      CPU_W_PAYLOAD_WIDTH  = 870,
      CPU_B_PAYLOAD_WIDTH  = 20,
      CPU_AR_PAYLOAD_WIDTH = 316,
      CPU_R_PAYLOAD_WIDTH  = 834,
      GIC_ADDR_WIDTH       = 15,
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
)
(

input  wire refclk,
input  wire cpu_pll,
input  wire sys_pll,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_core_poresetn,
input  wire [HOST_CPU_NUM_CORES-1:0] hostcpu_core_warmresetn,

input  wire        hostcpu_clustop_poresetn,
input  wire        hostcpu_clustop_warmresetn,

input  wire [63:0] hostcpu_tsvalueb,

input  wire [4:0] hostcpuclk_div1_clkdiv,
output wire [4:0] hostcpuclk_div1_clkdiv_cur,

input  wire [4:0] hostcpuclk_div0_clkdiv,
output wire [4:0] hostcpuclk_div0_clkdiv_cur,

input  wire [2:0] hostcpuclk_ctrl_clkselect,
output wire [2:0] hostcpuclk_ctrl_clkselect_cur,

input  wire [4:0] gicclk_div0_clkdiv,
output wire [4:0] gicclk_div0_clkdiv_cur,

input  wire [1:0] gicclk_ctrl_clkselect,
output wire [1:0] gicclk_ctrl_clkselect_cur,

input  wire [4:0]                      hostcpu_gicintdbgtop,                         
input  wire [9:0]                      hostcpu_gicintmhus,                           
input  wire [9:0]                      hostcpu_gicintmhuns,                          
input  wire [1:0]                      hostcpu_gicintuart,                           
input  wire [NUM_EXP_SHD_INT+32-1:0]   hostcpu_gicshdint,                            
input  wire [1:0]                      hostcpu_gicintwdogs,                          
input  wire                            hostcpu_gicintwdogns,                         

output wire [2:0]                      hostcpu_gicintdbgtop_pulse_ack,



input  wire                      cpu_pwrq_permit_deny_sar_i,

input  wire                      hostcpu_axim_egress_qreqn,
output wire                      hostcpu_axim_egress_qacceptn,
output wire                      hostcpu_axim_egress_qdeny,
output wire                      hostcpu_axim_egress_qactive,

input  wire [1:0]                hostcpu_dbgtrace_cti_egress_qreqn,
output wire [1:0]                hostcpu_dbgtrace_cti_egress_qacceptn,
output wire [1:0]                hostcpu_dbgtrace_cti_egress_qdeny,
output wire [1:0]                hostcpu_dbgtrace_cti_egress_qactive,

input  wire                      clustop_ingress_cti_double_bridge_qreqn,
output wire                      clustop_ingress_cti_double_bridge_qacceptn,
output wire                      clustop_ingress_cti_double_bridge_qdeny,
output wire                      clustop_ingress_cti_double_bridge_qactive,

output wire hostcpu_slvmustacceptreqn_async,
output wire hostcpu_slvcandenyreqn_async,
input  wire hostcpu_slvacceptn_async,
input  wire hostcpu_slvdeny_async,

output wire hostcpu_si_to_mi_wakeup_async,
input  wire hostcpu_mi_to_si_wakeup_async,

output wire [CPU_AW_FIFO_DEPTH-1:0] hostcpu_aw_wr_ptr_async,
input  wire [CPU_AW_FIFO_DEPTH-1:0] hostcpu_aw_rd_ptr_async,
output wire [CPU_AW_PAYLOAD_WIDTH-1:0] hostcpu_aw_payld_async,

output wire [ CPU_W_FIFO_DEPTH-1:0]  hostcpu_w_wr_ptr_async,
input  wire [ CPU_W_FIFO_DEPTH-1:0]  hostcpu_w_rd_ptr_async,
output wire [CPU_W_PAYLOAD_WIDTH-1:0] hostcpu_w_payld_async,

input  wire [ CPU_B_FIFO_DEPTH-1:0]  hostcpu_b_wr_ptr_async,
output wire [ CPU_B_FIFO_DEPTH-1:0]  hostcpu_b_rd_ptr_async,
input  wire [CPU_B_PAYLOAD_WIDTH-1:0] hostcpu_b_payld_async,

output wire [CPU_AR_FIFO_DEPTH-1:0] hostcpu_ar_wr_ptr_async,
input  wire [CPU_AR_FIFO_DEPTH-1:0] hostcpu_ar_rd_ptr_async,
output wire [CPU_AR_PAYLOAD_WIDTH-1:0] hostcpu_ar_payld_async,

input  wire [ CPU_R_FIFO_DEPTH-1:0]  hostcpu_r_wr_ptr_async,
output wire [ CPU_R_FIFO_DEPTH-1:0]  hostcpu_r_rd_ptr_async,
input  wire [CPU_R_PAYLOAD_WIDTH-1:0] hostcpu_r_payld_async,


input  wire gic_slvmustacceptreqn_async,
input  wire gic_slvcandenyreqn_async,
output wire gic_slvacceptn_async,
output wire gic_slvdeny_async,

input  wire gic_si_to_mi_wakeup_async,
output wire gic_mi_to_si_wakeup_async,


input  wire [GIC_AW_FIFO_DEPTH-1:0] gic_aw_wr_ptr_async,
output wire [GIC_AW_FIFO_DEPTH-1:0] gic_aw_rd_ptr_async,
input  wire [GIC_AW_PAYLOAD_WIDTH-1:0] gic_aw_payld_async,

input  wire [ GIC_W_FIFO_DEPTH-1:0]  gic_w_wr_ptr_async,
output wire [ GIC_W_FIFO_DEPTH-1:0]  gic_w_rd_ptr_async,
input  wire [GIC_W_PAYLOAD_WIDTH-1:0] gic_w_payld_async,

output wire [ GIC_B_FIFO_DEPTH-1:0]  gic_b_wr_ptr_async,
input  wire [ GIC_B_FIFO_DEPTH-1:0]  gic_b_rd_ptr_async,
output wire [GIC_B_PAYLOAD_WIDTH-1:0] gic_b_payld_async,

input  wire [GIC_AR_FIFO_DEPTH-1:0] gic_ar_wr_ptr_async,
output wire [GIC_AR_FIFO_DEPTH-1:0] gic_ar_rd_ptr_async,
input  wire [GIC_AR_PAYLOAD_WIDTH-1:0] gic_ar_payld_async,

output wire [ GIC_R_FIFO_DEPTH-1:0]  gic_r_wr_ptr_async,
input  wire [ GIC_R_FIFO_DEPTH-1:0]  gic_r_rd_ptr_async,
output wire [GIC_R_PAYLOAD_WIDTH-1:0] gic_r_payld_async,

input  wire               hostcpu_l2rstdisable,

input  wire [3:0]         hostcpu_dbgen,
input  wire [3:0]         hostcpu_spiden,
input  wire [3:0]         hostcpu_niden,
input  wire [3:0]         hostcpu_spniden,
input  wire [3:0]         hostcpu_dbgpwrdup,
output wire [3:0]         hostcpu_dbgnopwrdwn,
output wire [3:0]         hostcpu_dbgpwrupreq,

input  wire [63:0]        host_cntvalueg,
input  wire               host_cntclkout,

input  wire [3:0]         hostcpu_cp15sdisable,
input  wire [3:0]         hostcpu_cfgend,
input  wire [3:0]         hostcpu_vinithi,
input  wire [3:0]         hostcpu_cfgte,
input  wire               hostcpu_cfgsdisable,
input  wire [3:0]         hostcpu_aa64naa32,
input  wire [39:2]        hostcpu_rvbaraddr0,
input  wire [39:2]        hostcpu_rvbaraddr1,
input  wire [39:2]        hostcpu_rvbaraddr2,
input  wire [39:2]        hostcpu_rvbaraddr3,
input  wire               hostcpu_cryptodisable,
output wire [3:0]         hostcpu_stanbywfi,
output wire               hostcpu_stanbywfil2,
input  wire               hostcpu_mbistreq,
input  wire               nmbistreset,
input  wire [1:0]         hostcpu_dftrstdisable,
input  wire               hostcpu_dftramhold,
  
input  wire [3:0]         hostcpu_ctichin,
input  wire [3:0]         hostcpu_ctichoutack,
output wire [3:0]         hostcpu_ctichout,
output wire [3:0]         hostcpu_ctichinack,
 
output wire [6*41 - 1 : 0] hostcpu_atb_fwd_data,
output wire                hostcpu_flush_done,
input  wire                hostcpu_flush_req,
output wire                hostcpu_sync_clear,
input  wire                hostcpu_sync_done,
input  wire                hostcpu_syncreq_async_req,
output wire                hostcpu_syncreq_async_ack,
output wire [3:0]          hostcpu_wr_pointer_gray,
input  wire [3:0]          hostcpu_rd_pointer_gray,

input  wire                hostcpu_debug_async_req,
input  wire [67:0]         hostcpu_debug_async_req_payload,
output wire [32:0]         hostcpu_debug_async_resp_payload,
output wire                hostcpu_debug_async_ack,

output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_warmrstreq,
input  wire                  hostcpu_l2flushreq,
output wire                  hostcpu_l2flushdone,
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_smpen,

input  wire                  hostcpu_cpuwait,
  
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_cpuqactive,

input  wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_preq_power_handshake,
input  wire [4*HOST_CPU_NUM_CORES-1:0] hostcpu_pstate_power_handshake,
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_paccept_power_handshake,
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_pdeny_power_handshake,

input  wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_preq_warmrst_check,
input  wire [4*HOST_CPU_NUM_CORES-1:0] hostcpu_pstate_warmrst_check,
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_paccept_warmrst_check,
output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_pdeny_warmrst_check,
  
output wire               hostcpu_l2qactive,
input  wire               hostcpu_l2qreqn,
output wire               hostcpu_l2qdeny,
output wire               hostcpu_l2qacceptn,

output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_dbgrstreq,
input  wire                  hostcpu_dftcgen,
input  wire                  hostcpu_dftmcphold,

output wire [HOST_CPU_NUM_CORES-1:0]   hostcpu_wakeupreq,
input wire                dftdivsel,
input wire [1:0]          dftgicclksel,
input wire                dftgicclkselen,
input wire                dftgicclkdivbypass,

input wire [2:0]          dfthostcpuclksel,
input wire                dfthostcpuclkselen,
input wire                dfthostcpuclkdivbypass

);

wire  gic_clk;
wire  cpu_clk;

wire [HOST_CPU_NUM_CORES-1:0] core_poresetn;
wire [HOST_CPU_NUM_CORES-1:0] core_warmresetn;

wire  clustop_warmresetn;
wire  clustop_poresetn;
wire  clustop_poresetn_refclk;
wire  gic_resetn;

wire [7:0]   awid_hostcpu_axis;
wire [39:0]  awaddr_hostcpu_axis;
wire [7:0]   awlen_hostcpu_axis;
wire [2:0]   awsize_hostcpu_axis;
wire [1:0]   awburst_hostcpu_axis;
wire         awlock_hostcpu_axis;
wire [3:0]   awcache_hostcpu_axis;
wire [2:0]   awprot_hostcpu_axis;
wire         awvalid_hostcpu_axis;
wire         awready_hostcpu_axis;
wire [127:0] wdata_hostcpu_axis;
wire [15:0]  wstrb_hostcpu_axis;
wire         wlast_hostcpu_axis;
wire         wvalid_hostcpu_axis;
wire         wready_hostcpu_axis;
wire [7:0]   bid_hostcpu_axis;
wire [1:0]   bresp_hostcpu_axis;
wire         bvalid_hostcpu_axis;
wire         bready_hostcpu_axis;
wire [7:0]   arid_hostcpu_axis;
wire [39:0]  araddr_hostcpu_axis;
wire [7:0]   arlen_hostcpu_axis;
wire [2:0]   arsize_hostcpu_axis;
wire [1:0]   arburst_hostcpu_axis;
wire         arlock_hostcpu_axis;
wire [3:0]   arcache_hostcpu_axis;
wire [2:0]   arprot_hostcpu_axis;
wire         arvalid_hostcpu_axis;
wire         arready_hostcpu_axis;
wire [7:0]   rid_hostcpu_axis;
wire [127:0] rdata_hostcpu_axis;
wire [1:0]   rresp_hostcpu_axis;
wire         rlast_hostcpu_axis;
wire         rvalid_hostcpu_axis;
wire         rready_hostcpu_axis;
wire [1:0]   awuser_hostcpu_axis = awid_hostcpu_axis[1:0]; 
wire [1:0]   aruser_hostcpu_axis = arid_hostcpu_axis[1:0];

assign arid_hostcpu_axis[7:6] = 2'b00;
assign awid_hostcpu_axis[7:5] = 3'b000;

wire [GIC_ARID_WIDTH-1:0]  arid_gic_axim;
wire [GIC_ADDR_WIDTH-1:0]  araddr_gic_axim;
wire [7:0]   arlen_gic_axim;
wire [2:0]   arsize_gic_axim;
wire [1:0]   arburst_gic_axim;
wire [2:0]   arprot_gic_axim;
wire [2:0]   aruser_gic_axim;
wire         arvalid_gic_axim;
wire         arready_gic_axim;
                   
wire [GIC_ARID_WIDTH-1:0]  rid_gic_axim;
wire [31:0]  rdata_gic_axim;
wire         rlast_gic_axim;
wire [1:0]   rresp_gic_axim;
wire         rvalid_gic_axim;
wire         rready_gic_axim;
                   
wire [GIC_AWID_WIDTH-1:0]  awid_gic_axim;
wire [GIC_ADDR_WIDTH-1:0]  awaddr_gic_axim;
wire [7:0]   awlen_gic_axim;
wire [2:0]   awsize_gic_axim;
wire [1:0]   awburst_gic_axim;
wire [2:0]   awprot_gic_axim;
wire [2:0]   awuser_gic_axim;
wire         awvalid_gic_axim;
wire         awready_gic_axim;
                   
wire [31:0]  wdata_gic_axim;
wire [3:0]   wstrb_gic_axim;
wire         wvalid_gic_axim;
wire         wready_gic_axim;
                   
wire [GIC_AWID_WIDTH-1:0]  bid_gic_axim;
wire [1:0]   bresp_gic_axim;
wire         bvalid_gic_axim;
wire         bready_gic_axim;

wire         hostcpu_syncreqs;
wire         hostcpu_atreadys;
wire         hostcpu_afvalids;
wire         hostcpu_atvalids;
wire [6:0]   hostcpu_atids;
wire         hostcpu_afreadys;
wire         hostcpu_atwakeups;
wire [1:0] hostcpu_atbytess;
wire [ATB_DATA_WIDTH-1:0]           hostcpu_atdatas;


wire         hostcpu_debug_psel;
wire [31:0]  hostcpu_debug_paddr;
wire         hostcpu_debug_pwrite;
wire [31:0]  hostcpu_debug_prdata;
wire [31:0]  hostcpu_debug_pwdata;
wire         hostcpu_debug_penable;
wire         hostcpu_debug_pready;
wire         hostcpu_debug_pslverr;
wire         hostcpu_debug_pwakeup;
    
wire         resetn_clk_gen;

reg hostcpu_axi_slv_wakeups;
wire hostcpu_axi_slv_wakeups_int;

always @(posedge cpu_clk or negedge clustop_warmresetn)
begin
  if (~clustop_warmresetn)
  begin
    hostcpu_axi_slv_wakeups <= 1'b0;
  end
  else
  begin
    hostcpu_axi_slv_wakeups <= hostcpu_axi_slv_wakeups_int; 
  end
end

arm_element_std_or3 u_hostcpu_axislv_wakeup_or3 (
  .A (awvalid_hostcpu_axis),
  .B (arvalid_hostcpu_axis),
  .C (wvalid_hostcpu_axis),

  .Y (hostcpu_axi_slv_wakeups_int)
);

sse710_adb400_r3_axi4_slv_wrapper
    #(
    .ADDR_WIDTH         (CPU_ADDR_WIDTH),
    .DATA_WIDTH         (CPU_DATA_WIDTH),
    .AWID_WIDTH         (CPU_AWID_WIDTH),
    .ARID_WIDTH         (CPU_ARID_WIDTH),
    .AWUSER_WIDTH       (CPU_AWUSER_WIDTH),
    .WUSER_WIDTH        (CPU_WUSER_WIDTH),
    .BUSER_WIDTH        (CPU_BUSER_WIDTH),
    .ARUSER_WIDTH       (CPU_ARUSER_WIDTH),
    .RUSER_WIDTH        (CPU_RUSER_WIDTH),
    .AW_FIFO_DEPTH      (CPU_AW_FIFO_DEPTH),
    .W_FIFO_DEPTH       (CPU_W_FIFO_DEPTH),
    .B_FIFO_DEPTH       (CPU_B_FIFO_DEPTH),
    .AR_FIFO_DEPTH      (CPU_AR_FIFO_DEPTH),
    .R_FIFO_DEPTH       (CPU_R_FIFO_DEPTH),
    .B_OPREG            (1),
    .R_OPREG            (1),
    .SI_SYNC_LEVELS     (2),
    .AW_PAYLOAD_WIDTH   (CPU_AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH    (CPU_W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH    (CPU_B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH   (CPU_AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH    (CPU_R_PAYLOAD_WIDTH)
      
    )
  u_sse710_adb400_r3_axi4_slv_wrapper
    (
    .pwrq_permit_deny_sar_i (cpu_pwrq_permit_deny_sar_i),

    .aclks                  (cpu_clk),         
    .aresetns               (clustop_warmresetn),

    .clkqreqns_i            (1'b1), 
    .clkqacceptns_o         (),
    .clkqdenys_o            (),
    .clkqactives_o          (),
    .pwrqreqns_i            (hostcpu_axim_egress_qreqn),
    .pwrqacceptns_o         (hostcpu_axim_egress_qacceptn),
    .pwrqdenys_o            (hostcpu_axim_egress_qdeny),
    .pwrqactives_o          (hostcpu_axim_egress_qactive),

    .wakeups_i              (hostcpu_axi_slv_wakeups),

    .awvalids               (awvalid_hostcpu_axis ),
    .awreadys               (awready_hostcpu_axis ),
    .awusers                (awuser_hostcpu_axis  ),
    .awids                  (awid_hostcpu_axis    ),
    .awaddrs                (awaddr_hostcpu_axis  ),
    .awregions              (4'h0),  
    .awlens                 (awlen_hostcpu_axis   ),
    .awsizes                (awsize_hostcpu_axis  ),
    .awlocks                (awlock_hostcpu_axis  ),
    .awcaches               (awcache_hostcpu_axis ),
    .awprots                (awprot_hostcpu_axis  ),
    .awqoss                 (4'hf), 
    .awbursts               (awburst_hostcpu_axis ),
    .wvalids                (wvalid_hostcpu_axis  ),
    .wreadys                (wready_hostcpu_axis  ),
    .wusers                 (1'b0), 
    .wdatas                 (wdata_hostcpu_axis   ),
    .wstrbs                 (wstrb_hostcpu_axis   ),
    .wlasts                 (wlast_hostcpu_axis   ),
    .bvalids                (bvalid_hostcpu_axis  ),
    .breadys                (bready_hostcpu_axis  ),
    .busers                 (), 
    .bids                   (bid_hostcpu_axis     ),
    .bresps                 (bresp_hostcpu_axis   ),
    .arvalids               (arvalid_hostcpu_axis ),
    .arreadys               (arready_hostcpu_axis ),
    .arusers                (aruser_hostcpu_axis  ),
    .arids                  (arid_hostcpu_axis    ),
    .araddrs                (araddr_hostcpu_axis  ),
    .arregions              (4'h0),  
    .arlens                 (arlen_hostcpu_axis   ),
    .arsizes                (arsize_hostcpu_axis  ),
    .arlocks                (arlock_hostcpu_axis  ),
    .arcaches               (arcache_hostcpu_axis ),
    .arprots                (arprot_hostcpu_axis  ),
    .arqoss                 (4'hf), 
    .arbursts               (arburst_hostcpu_axis ),
    .rvalids                (rvalid_hostcpu_axis  ),
    .rreadys                (rready_hostcpu_axis  ),
    .rusers                 (), 
    .rids                   (rid_hostcpu_axis     ),
    .rdatas                 (rdata_hostcpu_axis   ),
    .rresps                 (rresp_hostcpu_axis   ),
    .rlasts                 (rlast_hostcpu_axis   ),



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

    .dftrstdisables          (hostcpu_dftrstdisable[1])
    );


  sse710_adb400_r3_axi4_mst_wrapper  #(
    .ADDR_WIDTH          (GIC_ADDR_WIDTH    ),
    .DATA_WIDTH          (GIC_DATA_WIDTH    ),
    .AWID_WIDTH          (GIC_AWID_WIDTH    ),
    .ARID_WIDTH          (GIC_ARID_WIDTH    ),
    .AWUSER_WIDTH        (GIC_AWUSER_WIDTH  ),
    .WUSER_WIDTH         (GIC_WUSER_WIDTH   ),
    .BUSER_WIDTH         (GIC_BUSER_WIDTH   ),
    .ARUSER_WIDTH        (GIC_ARUSER_WIDTH  ),
    .RUSER_WIDTH         (GIC_RUSER_WIDTH   ),
    .AW_FIFO_DEPTH       (GIC_AW_FIFO_DEPTH ),
    .W_FIFO_DEPTH        (GIC_W_FIFO_DEPTH  ),
    .B_FIFO_DEPTH        (GIC_B_FIFO_DEPTH  ),
    .AR_FIFO_DEPTH       (GIC_AR_FIFO_DEPTH ),
    .R_FIFO_DEPTH        (GIC_R_FIFO_DEPTH  ),
    .AW_OPREG            (1), 
    .W_OPREG             (1),
    .AR_OPREG            (1),
    .MI_SYNC_LEVELS      (2),
    .AW_PAYLOAD_WIDTH   (GIC_AW_PAYLOAD_WIDTH),
    .W_PAYLOAD_WIDTH    (GIC_W_PAYLOAD_WIDTH),
    .B_PAYLOAD_WIDTH    (GIC_B_PAYLOAD_WIDTH),
    .AR_PAYLOAD_WIDTH   (GIC_AR_PAYLOAD_WIDTH),
    .R_PAYLOAD_WIDTH    (GIC_R_PAYLOAD_WIDTH)
  ) u_sse710_adb400_r3_axi4_mst_wrapper (
    .aclkm                  (gic_clk  ),
    .aresetnm               (gic_resetn     ),

    .clkqreqnm_i            (1'b1 ),
    .clkqacceptnm_o         ( ),
    .clkqdenym_o            ( ),
    .clkqactivem_o          ( ),
                                            
    .wakeupm_o              ( ),
                                            
    .awvalidm               (awvalid_gic_axim       ),
    .awreadym               (awready_gic_axim       ),
    .awuserm                (awuser_gic_axim        ),
    .awidm                  (awid_gic_axim          ),
    .awaddrm                (awaddr_gic_axim        ),
    .awregionm              (  ),
    .awlenm                 (awlen_gic_axim         ),
    .awsizem                (awsize_gic_axim        ),
    .awlockm                (  ),
    .awcachem               (  ),
    .awprotm                (awprot_gic_axim        ),
    .awqosm                 (  ),
    .awburstm               (awburst_gic_axim       ),
                                            
    .wvalidm                (wvalid_gic_axim        ),
    .wreadym                (wready_gic_axim        ),
    .wuserm                 (  ),
    .wdatam                 (wdata_gic_axim         ),
    .wstrbm                 (wstrb_gic_axim         ),
    .wlastm                 (  ),
                                            
    .bvalidm                (bvalid_gic_axim        ),
    .breadym                (bready_gic_axim        ),
    .buserm                 (1'b0),
    .bidm                   (bid_gic_axim           ),
    .brespm                 (bresp_gic_axim         ),
                                            
    .arvalidm               (arvalid_gic_axim       ),
    .arreadym               (arready_gic_axim       ),
    .aruserm                (aruser_gic_axim        ),
    .aridm                  (arid_gic_axim          ),
    .araddrm                (araddr_gic_axim        ),
    .arregionm              (  ),
    .arlenm                 (arlen_gic_axim         ),
    .arsizem                (arsize_gic_axim        ),
    .arlockm                (  ),
    .arcachem               (  ),
    .arprotm                (arprot_gic_axim        ),
    .arqosm                 (  ),
    .arburstm               (arburst_gic_axim       ),
                                            
    .rvalidm                (rvalid_gic_axim        ),
    .rreadym                (rready_gic_axim        ),
    .ruserm                 (1'b0),
    .ridm                   (rid_gic_axim           ),
    .rdatam                 (rdata_gic_axim         ),
    .rrespm                 (rresp_gic_axim         ),
    .rlastm                 (rlast_gic_axim         ),


    .slvmustacceptreqn_async(gic_slvmustacceptreqn_async),
    .slvcandenyreqn_async   (gic_slvcandenyreqn_async),
    .slvacceptn_async       (gic_slvacceptn_async),
    .slvdeny_async          (gic_slvdeny_async),

    .si_to_mi_wakeup_async  (gic_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async  (gic_mi_to_si_wakeup_async),

    .aw_wr_ptr_async        (gic_aw_wr_ptr_async),
    .aw_rd_ptr_async        (gic_aw_rd_ptr_async),
    .aw_payld_async         (gic_aw_payld_async ),
    .w_wr_ptr_async         (gic_w_wr_ptr_async ),
    .w_rd_ptr_async         (gic_w_rd_ptr_async ),
    .w_payld_async          (gic_w_payld_async  ),
    .b_wr_ptr_async         (gic_b_wr_ptr_async ),
    .b_rd_ptr_async         (gic_b_rd_ptr_async ),
    .b_payld_async          (gic_b_payld_async  ),
    .ar_wr_ptr_async        (gic_ar_wr_ptr_async),
    .ar_rd_ptr_async        (gic_ar_rd_ptr_async),
    .ar_payld_async         (gic_ar_payld_async ),
    .r_wr_ptr_async         (gic_r_wr_ptr_async ),
    .r_rd_ptr_async         (gic_r_rd_ptr_async ),
    .r_payld_async          (gic_r_payld_async  ),

    .dftrstdisablem         (hostcpu_dftrstdisable[1])

  );

wire [3:0] hostcpu_ctichout_int;
wire [3:0] hostcpu_ctichoutack_int;
wire [3:0] hostcpu_ctichout_pulse_internal;
wire [3:0] hostcpu_ctichin_pulse_internal;
wire [3:0] hostcpuctichin_pulse_req_internal;
wire [3:0] hostcpuctichin_pulse_ack_internal;
wire clustop_ingress_cti_double_bridge_qacceptn_int;
wire clustop_ingress_cti_double_bridge_qreqn_sync;

css600_pulseasyncbridgeslv #(
  .WIDTH         (4),
  .WAKE_ON_PULSE (0)
) u_ctichin_pulseasyncbridge_slv (
  .clk_s         (cpu_clk),
  .reset_s_n     (clustop_poresetn),

  .pulse_in      (hostcpu_ctichin_pulse_internal),
  .pulse_req     (hostcpuctichin_pulse_req_internal),
  .pulse_ack     (hostcpuctichin_pulse_ack_internal),
  .clk_s_qactive (),

  .pwr_qreq_n    (1'b1),
  .pwr_qaccept_n ( ),
  .pwr_qactive   ( )
);

 arm_element_cdc_capt_sync u_ingress_cti_qreqn_sync (
    .clk     (cpu_clk),
    .nreset  (clustop_poresetn),
    .d_async (clustop_ingress_cti_double_bridge_qreqn),
    .q       (clustop_ingress_cti_double_bridge_qreqn_sync)
  );

assign clustop_ingress_cti_double_bridge_qacceptn_int = clustop_ingress_cti_double_bridge_qreqn_sync;
assign clustop_ingress_cti_double_bridge_qactive      = 1'b0;
assign clustop_ingress_cti_double_bridge_qdeny        = 1'b0;


reg clustop_ingress_cti_double_bridge_qacceptn_ddd;
reg clustop_ingress_cti_double_bridge_qacceptn_dd;
reg clustop_ingress_cti_double_bridge_qacceptn_d;


always @(posedge cpu_clk or negedge clustop_poresetn)
begin
  if (~clustop_poresetn)
  begin
    clustop_ingress_cti_double_bridge_qacceptn_d    <= 1'b0;
    clustop_ingress_cti_double_bridge_qacceptn_dd   <= 1'b0;
    clustop_ingress_cti_double_bridge_qacceptn_ddd  <= 1'b0;
  end
  else
  begin
    clustop_ingress_cti_double_bridge_qacceptn_ddd  <= clustop_ingress_cti_double_bridge_qacceptn_dd;
    clustop_ingress_cti_double_bridge_qacceptn_dd   <= clustop_ingress_cti_double_bridge_qacceptn_d;
    clustop_ingress_cti_double_bridge_qacceptn_d    <= clustop_ingress_cti_double_bridge_qacceptn_int;
  end
end

assign clustop_ingress_cti_double_bridge_qacceptn = clustop_ingress_cti_double_bridge_qacceptn_ddd;

css600_pulseasyncbridgemstr #(
  .WIDTH  (4)
) u_ctichin_pulseasyncbridge_mstr (
  .clk_m            (cpu_clk),
  .reset_m_n        (clustop_poresetn),

  .pulse_out        (hostcpu_ctichin_pulse_internal),
  .pulse_req        (hostcpu_ctichin),
  .pulse_ack        (hostcpu_ctichinack),

  .clk_m_qreq_n     (1'b1),
  .clk_m_qaccept_n  ( ),
  .clk_m_qactive    ( )
);


css600_pulseasyncbridgeslv #(
  .WIDTH         (4),
  .WAKE_ON_PULSE (0)
) u_ctichout_pulseasyncbridge_slv (
  .clk_s         (cpu_clk),
  .reset_s_n     (clustop_poresetn),

  .pulse_in      (hostcpu_ctichout_pulse_internal),
  .pulse_req     (hostcpu_ctichout),
  .pulse_ack     (hostcpu_ctichoutack),
  .clk_s_qactive (),

  .pwr_qreq_n    (hostcpu_dbgtrace_cti_egress_qreqn[0]),
  .pwr_qaccept_n (hostcpu_dbgtrace_cti_egress_qacceptn[0]),
  .pwr_qactive   (hostcpu_dbgtrace_cti_egress_qactive[0])
);

assign hostcpu_dbgtrace_cti_egress_qdeny[0]   = 1'b0;

css600_pulseasyncbridgemstr #(
  .WIDTH  (4)
) u_ctichout_pulseasyncbridge_mstr (
  .clk_m            (cpu_clk),
  .reset_m_n        (clustop_poresetn),

  .pulse_out        (hostcpu_ctichout_pulse_internal),
  .pulse_req        (hostcpu_ctichout_int),
  .pulse_ack        (hostcpu_ctichoutack_int),

  .clk_m_qreq_n     (1'b1),
  .clk_m_qaccept_n  ( ),
  .clk_m_qactive    ( )
);



wire [2:0] host_cpu_pulse_interrupts;

css600_pulseasyncbridgemstr #(
  .WIDTH (3)
) u_shared_interrupts_pulse_mstr (
  .clk_m (gic_clk),
  .reset_m_n (gic_resetn),

  .pulse_out (host_cpu_pulse_interrupts),
  .pulse_req ({hostcpu_gicintdbgtop[4:3], hostcpu_gicintdbgtop[0]}),
  .pulse_ack (hostcpu_gicintdbgtop_pulse_ack),

  .clk_m_qreq_n (1'b1),
  .clk_m_qaccept_n ( ),
  .clk_m_qactive ( )
);

wire [4:0] hostcpu_gicintdbgtop_pulsesync;

assign hostcpu_gicintdbgtop_pulsesync = {host_cpu_pulse_interrupts[2:1], hostcpu_gicintdbgtop[2:1], host_cpu_pulse_interrupts[0]}; 


wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_cpuqreqn;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_cpuqdeny;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_cpuqacceptn;
wire [HOST_CPU_NUM_CORES-1:0]  hostcpu_cpuqactive_int;

wire [HOST_CPU_NUM_CORES-1:0]  core_cpuwait;


genvar J;
generate
for (J=0; J<HOST_CPU_NUM_CORES; J=J+1)
begin:core_power_handshake_logic

sse710_core_power_handshake u_core_power_handshake (
  .clk                         (cpu_clk),
  .resetn                      (core_poresetn[J]),

  .preq_power_handshake        (hostcpu_preq_power_handshake[J]),
  .pstate_power_handshake      (hostcpu_pstate_power_handshake[4*J+:4]),
  .pdeny_power_handshake       (hostcpu_pdeny_power_handshake[J]),
  .paccept_power_handshake     (hostcpu_paccept_power_handshake[J]),

  .preq_warmrst_check          (hostcpu_preq_warmrst_check[J]),
  .pstate_warmrst_check        (hostcpu_pstate_warmrst_check[4*J+:4]),
  .pdeny_warmrst_check         (hostcpu_pdeny_warmrst_check[J]),
  .paccept_warmrst_check       (hostcpu_paccept_warmrst_check[J]),

  .cpuqactive_o                (hostcpu_cpuqactive[J]),

  .cpuqreqn_o                  (hostcpu_cpuqreqn[J]),
  .cpuqdeny_i                  (hostcpu_cpuqdeny[J]),
  .cpuqacceptn_i               (hostcpu_cpuqacceptn[J]),
  .cpuqactive_i                (hostcpu_cpuqactive_int[J]),

  .standbywfi                  (hostcpu_stanbywfi[J]),
  .dbgrstreq                   (hostcpu_dbgrstreq[J]),
  .warmrstreq                  (hostcpu_warmrstreq[J]),
  .cpuwait_i                   (hostcpu_cpuwait),

  .cpuwait_o                   (core_cpuwait[J]),

  .dftcgen                     (hostcpu_dftcgen)

);

end
endgenerate



sse710_cpu_gic_socket
#(
  .HOST_CPU_NUM_CORES (HOST_CPU_NUM_CORES),
  .HOST_CPU_TYPE (HOST_CPU_TYPE),
  .NUM_GICRID_BITS(GIC_ARID_WIDTH),
  .NUM_GICWID_BITS(GIC_AWID_WIDTH),
  .NUM_EXP_SHD_INT (NUM_EXP_SHD_INT)
  )
 u_cpu_gic_socket (
      .REFCLK                 (refclk),
      .HOSTCNTCLKOUT          (host_cntclkout),
      .HOSTCPUCLKOUT          (cpu_clk),
      .GICCLKOUT              (gic_clk),
      .GICRESETn              (gic_resetn),
      .HOSTCPUPORESETn        (core_poresetn),
      .HOSTCPUWARMRESETn      (core_warmresetn),
      .HOSTCLUSTOPWARMRESETn  (clustop_warmresetn),
      .HOSTCLUSTOPPORESETn    (clustop_poresetn),

      .L2RSTDISABLE           (hostcpu_l2rstdisable),
      .GICINTDBGTOP           (hostcpu_gicintdbgtop_pulsesync),
      .GICINTMHUS             (hostcpu_gicintmhus),
      .GICINTMHUNS            (hostcpu_gicintmhuns),
      .GICINTWDOGS            (hostcpu_gicintwdogs),
      .GICINTWDOGNS           (hostcpu_gicintwdogns),
      .GICINTUART             (hostcpu_gicintuart),
      .GICSHDINT              (hostcpu_gicshdint),
      .WAKEUPREQ              (hostcpu_wakeupreq),
      .ARIDGICM      (arid_gic_axim),
      .ARADDRGICM    (araddr_gic_axim),
      .ARLENGICM     (arlen_gic_axim),
      .ARSIZEGICM    (arsize_gic_axim),
      .ARBURSTGICM   (arburst_gic_axim),
      .ARPROTGICM    (arprot_gic_axim),
      .ARUSERGICM    (aruser_gic_axim),
      .ARVALIDGICM   (arvalid_gic_axim),
      .ARREADYGICM   (arready_gic_axim),

      .RIDGICM       (rid_gic_axim),
      .RDATAGICM     (rdata_gic_axim),
      .RLASTGICM     (rlast_gic_axim),
      .RRESPGICM     (rresp_gic_axim),
      .RVALIDGICM    (rvalid_gic_axim),
      .RREADYGICM    (rready_gic_axim),

      .AWIDGICM      (awid_gic_axim),
      .AWADDRGICM    (awaddr_gic_axim),
      .AWLENGICM     (awlen_gic_axim),
      .AWSIZEGICM    (awsize_gic_axim),
      .AWBURSTGICM   (awburst_gic_axim),
      .AWPROTGICM    (awprot_gic_axim),
      .AWUSERGICM    (awuser_gic_axim),
      .AWVALIDGICM   (awvalid_gic_axim),
      .AWREADYGICM   (awready_gic_axim),

      .WDATAGICM     (wdata_gic_axim),
      .WSTRBGICM     (wstrb_gic_axim),
      .WVALIDGICM    (wvalid_gic_axim),
      .WREADYGICM    (wready_gic_axim),

      .BIDGICM       (bid_gic_axim),
      .BRESPGICM     (bresp_gic_axim),
      .BVALIDGICM    (bvalid_gic_axim),
      .BREADYGICM    (bready_gic_axim),

      .ARREADYHOSTCPUMEM     (arready_hostcpu_axis),
      .ARVALIDHOSTCPUMEM     (arvalid_hostcpu_axis),
      .ARADDRHOSTCPUMEM      (araddr_hostcpu_axis),
      .ARLENHOSTCPUMEM       (arlen_hostcpu_axis),
      .ARSIZEHOSTCPUMEM      (arsize_hostcpu_axis),
      .ARBURSTHOSTCPUMEM     (arburst_hostcpu_axis),
      .ARLOCKHOSTCPUMEM      (arlock_hostcpu_axis),
      .ARCACHEHOSTCPUMEM     (arcache_hostcpu_axis),
      .ARPROTHOSTCPUMEM      (arprot_hostcpu_axis),
      .ARIDHOSTCPUMEM        (arid_hostcpu_axis[5:0]),
      .RVALIDHOSTCPUMEM      (rvalid_hostcpu_axis),
      .RLASTHOSTCPUMEM       (rlast_hostcpu_axis),
      .RDATAHOSTCPUMEM       (rdata_hostcpu_axis),
      .RRESPHOSTCPUMEM       (rresp_hostcpu_axis), 
      .RIDHOSTCPUMEM         (rid_hostcpu_axis[5:0]),
      .RREADYHOSTCPUMEM      (rready_hostcpu_axis),
      .AWREADYHOSTCPUMEM     (awready_hostcpu_axis),
      .AWVALIDHOSTCPUMEM     (awvalid_hostcpu_axis),
      .AWADDRHOSTCPUMEM      (awaddr_hostcpu_axis),
      .AWLENHOSTCPUMEM       (awlen_hostcpu_axis),
      .AWSIZEHOSTCPUMEM      (awsize_hostcpu_axis),
      .AWBURSTHOSTCPUMEM     (awburst_hostcpu_axis),
      .AWLOCKHOSTCPUMEM      (awlock_hostcpu_axis),
      .AWCACHEHOSTCPUMEM     (awcache_hostcpu_axis),
      .AWPROTHOSTCPUMEM      (awprot_hostcpu_axis),
      .AWIDHOSTCPUMEM        (awid_hostcpu_axis[4:0]),
      .WREADYHOSTCPUMEM     (wready_hostcpu_axis),
      .WVALIDHOSTCPUMEM     (wvalid_hostcpu_axis),
      .WLASTHOSTCPUMEM      (wlast_hostcpu_axis),
      .WDATAHOSTCPUMEM      (wdata_hostcpu_axis),
      .WSTRBHOSTCPUMEM      (wstrb_hostcpu_axis),
      .WIDHOSTCPUMEM        (), 
      .BVALIDHOSTCPUMEM      (bvalid_hostcpu_axis),
      .BRESPHOSTCPUMEM       (bresp_hostcpu_axis),
      .BIDHOSTCPUMEM         (bid_hostcpu_axis[4:0]),
      .BREADYHOSTCPUMEM      (bready_hostcpu_axis),
      .PSELHOSTCPUDBG         (hostcpu_debug_psel),
      .PADDRHOSTCPUDBG        (hostcpu_debug_paddr),      
      .PWRITEHOSTCPUDBG       (hostcpu_debug_pwrite),
      .PRDATAHOSTCPUDBG       (hostcpu_debug_prdata),
      .PWDATAHOSTCPUDBG       (hostcpu_debug_pwdata),
      .PENABLEHOSTCPUDBG      (hostcpu_debug_penable),
      .PREADYHOSTCPUDBG       (hostcpu_debug_pready),
      .PSLVERRHOSTCPUDBG      (hostcpu_debug_pslverr),
      .PWAKEUPHOSTCPUDBG      (hostcpu_debug_pwakeup),
      .HOSTCPUDBGAUTHDBGEN    (hostcpu_dbgen),
      .HOSTCPUDBGAUTHSPIDEN   (hostcpu_spiden),
      .HOSTCPUDBGAUTHNIDEN    (hostcpu_niden),
      .HOSTCPUDBGAUTHSPNIDEN  (hostcpu_spniden),
      .DBGPWRDUP        (hostcpu_dbgpwrdup),
      .DBGNOPWRDWN      (hostcpu_dbgnopwrdwn),
      .DBGPWRUPREQ      (hostcpu_dbgpwrupreq),
      .TSVALUEB       (hostcpu_tsvalueb),
      .HOSTCNTVALUEG  (host_cntvalueg),
      .CP15SDISABLE     (hostcpu_cp15sdisable[HOST_CPU_NUM_CORES-1:0]),
      .CFGEND           (hostcpu_cfgend[HOST_CPU_NUM_CORES-1:0]),
      .VINITHI          (hostcpu_vinithi[HOST_CPU_NUM_CORES-1:0]),
      .CFGTE            (hostcpu_cfgte[HOST_CPU_NUM_CORES-1:0]),
      .CFGSDISABLE      (hostcpu_cfgsdisable),
      .STANDBYWFI       (hostcpu_stanbywfi),
      .STANDBYWFIL2     (hostcpu_stanbywfil2),
      .AA64nAA32        (hostcpu_aa64naa32[HOST_CPU_NUM_CORES-1:0]),
      .RVBARADDR0       (hostcpu_rvbaraddr0),
      .RVBARADDR1       (hostcpu_rvbaraddr1),
      .RVBARADDR2       (hostcpu_rvbaraddr2),
      .RVBARADDR3       (hostcpu_rvbaraddr3),
      .CRYPTODISABLE    (hostcpu_cryptodisable),
      .DFTRSTDISABLE    (hostcpu_dftrstdisable[1]),
      .DFTRAMHOLD       (hostcpu_dftramhold),
      .MBISTREQ         (hostcpu_mbistreq),
      .nMBISTRESET      (nmbistreset),
      .CTICHIN          (hostcpuctichin_pulse_req_internal),
      .CTICHOUTACK      (hostcpu_ctichoutack_int),
      .CTICHOUT         (hostcpu_ctichout_int),
      .CTICHINACK       (hostcpuctichin_pulse_ack_internal),


      .ATREADYHOSTCPUTRACE         (hostcpu_atreadys),
      .AFVALIDHOSTCPUTRACE         (hostcpu_afvalids),
      .AFREADYHOSTCPUTRACE         (hostcpu_afreadys),
      .ATVALIDHOSTCPUTRACE         (hostcpu_atvalids),
      .ATWAKEUPHOSTCPUTRACE        (hostcpu_atwakeups),
      .SYNCREQHOSTCPUTRACE         (hostcpu_syncreqs),
      .ATDATAHOSTCPUTRACE          (hostcpu_atdatas),
      .ATBYTESHOSTCPUTRACE         (hostcpu_atbytess),
      .ATIDHOSTCPUTRACE            (hostcpu_atids),

      .WARMRSTREQ       (hostcpu_warmrstreq),
      .L2FLUSHREQ       (hostcpu_l2flushreq),
      .L2FLUSHDONE      (hostcpu_l2flushdone),
      .SMPEN            (hostcpu_smpen),

      .CPUQACTIVE       (hostcpu_cpuqactive_int),
      .CPUQREQn         (hostcpu_cpuqreqn),
      .CPUQDENY         (hostcpu_cpuqdeny),
      .CPUQACCEPTn      (hostcpu_cpuqacceptn),

      .L2QACTIVE        (hostcpu_l2qactive),
      .L2QREQn          (hostcpu_l2qreqn),
      .L2QDENY          (hostcpu_l2qdeny),
      .L2QACCEPTn       (hostcpu_l2qacceptn),

      
      .DBGRSTREQ        (hostcpu_dbgrstreq),

      .DFTCGEN           (hostcpu_dftcgen),
      .DFTMCPHOLD        (hostcpu_dftmcphold)
);



sse710_rstsync_delay #(
  .RESET_DELAY_CYCLES (CLUSTOP_CORE_RST_DLY)
) u_clustop_warmresetn_sync (
  .clk              (cpu_clk),            
  .resetn_async     (hostcpu_clustop_warmresetn),
  .resetn_syncdelay (clustop_warmresetn),          

  .dftrstdisable    (hostcpu_dftrstdisable[1:0])  
);

sse710_rstsync_delay #(
  .RESET_DELAY_CYCLES (CLUSTOP_CORE_RST_DLY)
) u_clustop_poresetn_sync (
  .clk              (cpu_clk),            
  .resetn_async     (hostcpu_clustop_poresetn),
  .resetn_syncdelay (clustop_poresetn),          

  .dftrstdisable    (hostcpu_dftrstdisable[1:0])  
);

arm_element_reset_sync u_clustop_poresetn_refclk_sync (
  .clk              (refclk),            
  .resetn_async     (hostcpu_clustop_poresetn),
  .resetn_sync      (clustop_poresetn_refclk),          

  .dftrstdisable    (hostcpu_dftrstdisable[1])  
);

sse710_rstsync_delay #(
  .RESET_DELAY_CYCLES (CLUSTOP_CORE_RST_DLY)  
) u_gic_resetn_sync (
  .clk              (gic_clk),            
  .resetn_async     (hostcpu_clustop_warmresetn),
  .resetn_syncdelay (gic_resetn),          

  .dftrstdisable    (hostcpu_dftrstdisable[1:0])  
);

wire [HOST_CPU_NUM_CORES-1:0] core_cpuwait_n;
wire [HOST_CPU_NUM_CORES-1:0] core_warmresetn_cpuwait;
wire [HOST_CPU_NUM_CORES-1:0] core_warmresetn_int;

genvar I;
generate
for (I=0; I<HOST_CPU_NUM_CORES; I=I+1)
begin:core_reset_sync

  arm_element_clock_inverter u_core_cpuwait_inverter (
    .clk_in  (core_cpuwait[I]),
    .clk_out (core_cpuwait_n[I])
  );

  arm_element_cdc_comb_mux2 u_core_cpuwait_and2_cpu (
    .din1_async (1'b0),
    .din2_async (hostcpu_core_warmresetn[I]),
    .sel (core_cpuwait_n[I]), .dout_async (core_warmresetn_cpuwait[I])
  );

  arm_element_std_or2 u_core_warmreset_dftrstdisable_cpu (
    .A  (core_warmresetn_cpuwait[I]),
    .B  (hostcpu_dftrstdisable[1]),
    .Y  (core_warmresetn_int[I])
  );
  
  sse710_rstsync_delay #(
    .RESET_DELAY_CYCLES (CLUSTOP_CORE_RST_DLY)
  ) u_core_poresetn_sync (
    .clk              (cpu_clk),
    .resetn_async     (hostcpu_core_poresetn[I]),
    .resetn_syncdelay (core_poresetn[I]),

    .dftrstdisable    (hostcpu_dftrstdisable[1:0])
  );

  sse710_rstsync_delay #(
    .RESET_DELAY_CYCLES (CLUSTOP_CORE_RST_DLY)
  ) u_core_warmresetn_sync (
    .clk              (cpu_clk),
    .resetn_async     (core_warmresetn_int[I]),
    .resetn_syncdelay (core_warmresetn[I]),

    .dftrstdisable    ({hostcpu_dftrstdisable[0],hostcpu_dftrstdisable[1]})
  );
end
endgenerate

arm_element_cdc_comb_mux2 u_clkgen_reset_nmbistreset_mux (
 .din1_async(clustop_poresetn_refclk),
 .din2_async(nmbistreset),
 .sel       (dftdivsel),
 .dout_async(resetn_clk_gen)
);

e_clk_f1_top_clustop u_clk_gen_clustop (

   .CLUSTOP_RESETN                             (resetn_clk_gen),        

   .REFCLK                                     (refclk),                
   .CPUPLL                                     (cpu_pll),               
   .SYSPLL                                     (sys_pll),               

   .HOSTCPUCLK                                 (cpu_clk),               

   .HOSTCPUCLK_ON_CPUPLL_DIVRATIO              (hostcpuclk_div1_clkdiv),
   .HOSTCPUCLK_ON_CPUPLL_DIVRATIO_CUR          (hostcpuclk_div1_clkdiv_cur),
   .HOSTCPUCLK_ON_SYSPLL_DIVRATIO              (hostcpuclk_div0_clkdiv),
   .HOSTCPUCLK_ON_SYSPLL_DIVRATIO_CUR          (hostcpuclk_div0_clkdiv_cur),

   .HOSTCPUCLK_CLKSEL                          (hostcpuclk_ctrl_clkselect),
   .HOSTCPUCLK_CLKSEL_CUR                      (hostcpuclk_ctrl_clkselect_cur),

   .DFTHOSTCPUCLKSEL                           (dfthostcpuclksel                ),
   .DFTHOSTCPUCLKSELEN                         (dfthostcpuclkselen              ),
   .DFTHOSTCPUCLKDIVBYPASS_ON_CPUPLL           (dfthostcpuclkdivbypass),
   .DFTHOSTCPUCLKDIVBYPASS_ON_SYSPLL           (dfthostcpuclkdivbypass),

   .GICCLK                                     (gic_clk),   

   .GICCLK_ON_SYSPLL_DIVRATIO                  (gicclk_div0_clkdiv),
   .GICCLK_ON_SYSPLL_DIVRATIO_CUR              (gicclk_div0_clkdiv_cur),

   .GICCLK_CLKSEL                              (gicclk_ctrl_clkselect),
   .GICCLK_CLKSEL_CUR                          (gicclk_ctrl_clkselect_cur),

   .DFTGICCLKSEL                               (dftgicclksel                ),
   .DFTGICCLKSELEN                             (dftgicclkselen              ),
   .DFTGICCLKDIVBYPASS_ON_SYSPLL               (dftgicclkdivbypass),

   .DFTCGEN                                    (hostcpu_dftcgen),
   .DFTRSTDISABLE                              (hostcpu_dftrstdisable[0])

);

css600_atbasyncbridgeslv #(
  .ATB_DATA_WIDTH (ATB_DATA_WIDTH)
) u_clustop_atb_slv (
  .clk_s               (cpu_clk),
  .reset_s_n           (clustop_warmresetn),
  
  .syncreq_s           (hostcpu_syncreqs ),
  .atready_s           (hostcpu_atreadys ),
  .afvalid_s           (hostcpu_afvalids ),
  .atvalid_s           (hostcpu_atvalids ),
  .atid_s              (hostcpu_atids ),
  .atbytes_s           (hostcpu_atbytess),
  .atdata_s            (hostcpu_atdatas ),
  .afready_s           (hostcpu_afreadys ),
  .atwakeup_s          (hostcpu_atwakeups ),
                      
  .atb_fwd_data        (hostcpu_atb_fwd_data ),
  .flush_done          (hostcpu_flush_done ),
  .flush_req           (hostcpu_flush_req ),
  .sync_clear          (hostcpu_sync_clear ),
  .sync_done           (hostcpu_sync_done ),
  .syncreq_async_req   (hostcpu_syncreq_async_req ),
  .syncreq_async_ack   (hostcpu_syncreq_async_ack ),
  .wr_pointer_gray     (hostcpu_wr_pointer_gray ),
  .rd_pointer_gray     (hostcpu_rd_pointer_gray ),

  .clk_s_qreq_n(1'b1),
  .clk_s_qaccept_n(), 
  .clk_s_qactive(), 
  .clk_s_qdeny(),
 
  .pwr_qreq_n    (hostcpu_dbgtrace_cti_egress_qreqn[1]),
  .pwr_qaccept_n (hostcpu_dbgtrace_cti_egress_qacceptn[1]),
  .pwr_qdeny     (hostcpu_dbgtrace_cti_egress_qdeny[1]),
  .pwr_qactive   ( )
 );

assign hostcpu_dbgtrace_cti_egress_qactive[1] = 1'b0;

css600_apbasyncbridgemstr #(
   .APB_ADDR_WIDTH(32)
)
u_host_cpu_debug_mstr
(
  .clk_m                  (cpu_clk),
  .reset_m_n              (clustop_poresetn),
  .dftcgen                (hostcpu_dftcgen),
  .psel_m                 (hostcpu_debug_psel),
  .penable_m              (hostcpu_debug_penable),
  .paddr_m                (hostcpu_debug_paddr),
  .pwrite_m               (hostcpu_debug_pwrite),
  .pwdata_m               (hostcpu_debug_pwdata),
  .pprot_m                ( ),
  .prdata_m               (hostcpu_debug_prdata),
  .pready_m               (hostcpu_debug_pready),
  .pslverr_m              (hostcpu_debug_pslverr),
  .pwakeup_m              (hostcpu_debug_pwakeup),
  .clk_m_qreq_n           (1'b1),
  .clk_m_qaccept_n        (),
  .clk_m_qdeny            (),
  .clk_m_qactive          (),
  .apb_async_req          (hostcpu_debug_async_req),
  .apb_async_req_payload  (hostcpu_debug_async_req_payload),
  .apb_async_resp_payload (hostcpu_debug_async_resp_payload),
  .apb_async_ack          (hostcpu_debug_async_ack)

);

 wire unused_a53;
  
    assign unused_a53 = (|bid_hostcpu_axis[7:5]) |
                        (|rid_hostcpu_axis[7:6]) |
                        (|hostcpu_debug_paddr[31:29]) |
                        (|hostcpu_debug_paddr[27:22]) |
                        (|hostcpu_debug_paddr[1:0]);
 

wire unused;

assign unused = 1'b0;
 

endmodule
