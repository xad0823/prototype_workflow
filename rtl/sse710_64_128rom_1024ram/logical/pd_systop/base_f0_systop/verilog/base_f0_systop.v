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


module base_f0_systop #(
  parameter         XNVM_DATA_WIDTH          = 64, 
  parameter         CVM_DATA_WIDTH           = 64,

  parameter         OCVM_DATA_WIDTH          = 64, 

  parameter         EXPSLV0_DATA_WIDTH       = 64, 
  parameter         EXPSLV0_ID_WIDTH         = 8, 
  parameter         EXPSLV1_DATA_WIDTH       = 64, 
  parameter         EXPSLV1_ID_WIDTH         = 8, 

  parameter         EXPMST0_DATA_WIDTH       = 64, 
  parameter         EXPMST1_DATA_WIDTH       = 64, 

  parameter         EXT_SYS0_MEM_DATA_WIDTH   = 64, 
  parameter         EXT_SYS0_MEM_AWID_WIDTH   = 8, 
  parameter         EXT_SYS0_MEM_ARID_WIDTH   = 8, 
  parameter         EXT_SYS1_MEM_DATA_WIDTH   = 64, 
  parameter         EXT_SYS1_MEM_AWID_WIDTH   = 8, 
  parameter         EXT_SYS1_MEM_ARID_WIDTH   = 8, 

  parameter GLOBAL_ID_WIDTH           = 12,
  parameter SYSTOP_BASE_INTERNAL_PWRQ = 13 

) (
input  wire aclk,
input  wire aresetn,

input  wire ctrlclk,
input  wire ctrlresetn,

input  wire dftcgen,
input  wire fctrl_bypass,

input  wire  aclk_qreqn,            
output wire  aclk_qacceptn,         
output wire  aclk_qdeny,            
output wire  aclk_qactive,          
output wire  cactive_cd_maingpv,

input  wire [SYSTOP_BASE_INTERNAL_PWRQ-1:0] qreqn_systop_base_internal,
output wire [SYSTOP_BASE_INTERNAL_PWRQ-1:0] qacceptn_systop_base_internal,
output wire [SYSTOP_BASE_INTERNAL_PWRQ-1:0] qdeny_systop_base_internal,
output wire [SYSTOP_BASE_INTERNAL_PWRQ-1:0] qactive_systop_base_internal,


output wire [16:0] paddr_uart_apb,
output wire [31:0] pwdata_uart_apb,
output wire        pwrite_uart_apb,
output wire [2:0]  pprot_uart_apb,
output wire [3:0]  pstrb_uart_apb,
output wire        penable_uart_apb,
output wire        pselx_uart_apb,
input  wire [31:0] prdata_uart_apb,
input  wire        pslverr_uart_apb,
input  wire        pready_uart_apb,


output wire [27:0] paddr_sysctrl_apb,
output wire [31:0] pwdata_sysctrl_apb,
output wire        pwrite_sysctrl_apb,
output wire [2:0]  pprot_sysctrl_apb,
output wire [3:0]  pstrb_sysctrl_apb,
output wire        penable_sysctrl_apb,
output wire        pselx_sysctrl_apb,
input  wire [31:0] prdata_sysctrl_apb,
input  wire        pslverr_sysctrl_apb,
input  wire        pready_sysctrl_apb,

output wire        awakeup_xnvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] awid_xnvm_axim,
output wire [31:0] awaddr_xnvm_axim,
output wire [7:0]  awlen_xnvm_axim,
output wire [2:0]  awsize_xnvm_axim,
output wire [1:0]  awburst_xnvm_axim,
output wire        awlock_xnvm_axim,
output wire [3:0]  awcache_xnvm_axim,
output wire [2:0]  awprot_xnvm_axim,
output wire [3:0]  awqos_xnvm_axim,
output wire        awvalid_xnvm_axim,
input  wire        awready_xnvm_axim,
output wire [XNVM_DATA_WIDTH-1:0] wdata_xnvm_axim,
output wire [(XNVM_DATA_WIDTH/8)-1:0]  wstrb_xnvm_axim,
output wire        wlast_xnvm_axim,
output wire        wvalid_xnvm_axim,
input  wire        wready_xnvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_xnvm_axim,
input  wire [1:0]  bresp_xnvm_axim,
input  wire        bvalid_xnvm_axim,
output wire        bready_xnvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_xnvm_axim,
output wire [31:0] araddr_xnvm_axim,
output wire [7:0]  arlen_xnvm_axim,
output wire [2:0]  arsize_xnvm_axim,
output wire [1:0]  arburst_xnvm_axim,
output wire        arlock_xnvm_axim,
output wire [3:0]  arcache_xnvm_axim,
output wire [2:0]  arprot_xnvm_axim,
output wire [3:0]  arqos_xnvm_axim,
output wire        arvalid_xnvm_axim,
input  wire        arready_xnvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_xnvm_axim,
input  wire [XNVM_DATA_WIDTH-1:0] rdata_xnvm_axim,
input  wire [1:0]  rresp_xnvm_axim,
input  wire        rlast_xnvm_axim,
input  wire        rvalid_xnvm_axim,
output wire        rready_xnvm_axim,
output wire [9:0]  awuser_xnvm_axim,
output wire [9:0]  aruser_xnvm_axim,


output wire [GLOBAL_ID_WIDTH-1:0] awid_cvm_axim,
output wire [31:0] awaddr_cvm_axim,
output wire [7:0]  awlen_cvm_axim,
output wire [2:0]  awsize_cvm_axim,
output wire [1:0]  awburst_cvm_axim,
output wire        awlock_cvm_axim,
output wire [3:0]  awcache_cvm_axim,
output wire [2:0]  awprot_cvm_axim,
output wire        awvalid_cvm_axim,
output wire        awakeup_cvm_axim,
input  wire        awready_cvm_axim,
output wire [CVM_DATA_WIDTH-1:0] wdata_cvm_axim,
output wire [(CVM_DATA_WIDTH/8)-1:0]  wstrb_cvm_axim,
output wire        wlast_cvm_axim,
output wire        wvalid_cvm_axim,
input  wire        wready_cvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_cvm_axim,
input  wire [1:0]  bresp_cvm_axim,
input  wire        bvalid_cvm_axim,
output wire        bready_cvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_cvm_axim,
output wire [31:0] araddr_cvm_axim,
output wire [7:0]  arlen_cvm_axim,
output wire [2:0]  arsize_cvm_axim,
output wire [1:0]  arburst_cvm_axim,
output wire        arlock_cvm_axim,
output wire [3:0]  arcache_cvm_axim,
output wire [2:0]  arprot_cvm_axim,
output wire        arvalid_cvm_axim,
input  wire        arready_cvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_cvm_axim,
input  wire [CVM_DATA_WIDTH-1:0] rdata_cvm_axim,
input  wire [1:0]  rresp_cvm_axim,
input  wire        rlast_cvm_axim,
input  wire        rvalid_cvm_axim,
output wire        rready_cvm_axim,
output wire [9:0]  awuser_cvm_axim,
output wire [9:0]  aruser_cvm_axim,
output wire [3:0]  awqos_cvm_axim,
output wire [3:0]  arqos_cvm_axim,

 

output wire [GLOBAL_ID_WIDTH-1:0] awid_expmstr0_axim,
output wire [31:0] awaddr_expmstr0_axim,
output wire [7:0]  awlen_expmstr0_axim,
output wire [2:0]  awsize_expmstr0_axim,
output wire [1:0]  awburst_expmstr0_axim,
output wire        awlock_expmstr0_axim,
output wire [3:0]  awcache_expmstr0_axim,
output wire [2:0]  awprot_expmstr0_axim,
output wire        awvalid_expmstr0_axim,
output wire        awakeup_expmstr0_axim,
input  wire        awready_expmstr0_axim,
output wire [EXPMST0_DATA_WIDTH-1:0] wdata_expmstr0_axim,
output wire [(EXPMST0_DATA_WIDTH/8)-1:0]  wstrb_expmstr0_axim,
output wire        wlast_expmstr0_axim,
output wire        wvalid_expmstr0_axim,
input  wire        wready_expmstr0_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_expmstr0_axim,
input  wire [1:0]  bresp_expmstr0_axim,
input  wire        bvalid_expmstr0_axim,
output wire        bready_expmstr0_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_expmstr0_axim,
output wire [31:0] araddr_expmstr0_axim,
output wire [7:0]  arlen_expmstr0_axim,
output wire [2:0]  arsize_expmstr0_axim,
output wire [1:0]  arburst_expmstr0_axim,
output wire        arlock_expmstr0_axim,
output wire [3:0]  arcache_expmstr0_axim,
output wire [2:0]  arprot_expmstr0_axim,
output wire        arvalid_expmstr0_axim,
input  wire        arready_expmstr0_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_expmstr0_axim,
input  wire [EXPMST0_DATA_WIDTH-1:0] rdata_expmstr0_axim,
input  wire [1:0]  rresp_expmstr0_axim,
input  wire        rlast_expmstr0_axim,
input  wire        rvalid_expmstr0_axim,
output wire        rready_expmstr0_axim,
output wire [9:0]  awuser_expmstr0_axim,
output wire [9:0]  aruser_expmstr0_axim,
output wire [3:0]  awqos_expmstr0_axim,
output wire [3:0]  arqos_expmstr0_axim,
 

output wire [GLOBAL_ID_WIDTH-1:0] awid_expmstr1_axim,
output wire [31:0] awaddr_expmstr1_axim,
output wire [7:0]  awlen_expmstr1_axim,
output wire [2:0]  awsize_expmstr1_axim,
output wire [1:0]  awburst_expmstr1_axim,
output wire        awlock_expmstr1_axim,
output wire [3:0]  awcache_expmstr1_axim,
output wire [2:0]  awprot_expmstr1_axim,
output wire        awvalid_expmstr1_axim,
output wire        awakeup_expmstr1_axim,
input  wire        awready_expmstr1_axim,
output wire [EXPMST1_DATA_WIDTH-1:0] wdata_expmstr1_axim,
output wire [(EXPMST1_DATA_WIDTH/8)-1:0]  wstrb_expmstr1_axim,
output wire        wlast_expmstr1_axim,
output wire        wvalid_expmstr1_axim,
input  wire        wready_expmstr1_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_expmstr1_axim,
input  wire [1:0]  bresp_expmstr1_axim,
input  wire        bvalid_expmstr1_axim,
output wire        bready_expmstr1_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_expmstr1_axim,
output wire [31:0] araddr_expmstr1_axim,
output wire [7:0]  arlen_expmstr1_axim,
output wire [2:0]  arsize_expmstr1_axim,
output wire [1:0]  arburst_expmstr1_axim,
output wire        arlock_expmstr1_axim,
output wire [3:0]  arcache_expmstr1_axim,
output wire [2:0]  arprot_expmstr1_axim,
output wire        arvalid_expmstr1_axim,
input  wire        arready_expmstr1_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_expmstr1_axim,
input  wire [EXPMST1_DATA_WIDTH-1:0] rdata_expmstr1_axim,
input  wire [1:0]  rresp_expmstr1_axim,
input  wire        rlast_expmstr1_axim,
input  wire        rvalid_expmstr1_axim,
output wire        rready_expmstr1_axim,
output wire [9:0]  awuser_expmstr1_axim,
output wire [9:0]  aruser_expmstr1_axim,
output wire [3:0]  awqos_expmstr1_axim,
output wire [3:0]  arqos_expmstr1_axim,


output wire [9:0]  awid_firewall_axim,
output wire [31:0] awaddr_firewall_axim,
output wire [7:0]  awlen_firewall_axim,
output wire [2:0]  awsize_firewall_axim,
output wire [1:0]  awburst_firewall_axim,
output wire        awlock_firewall_axim,
output wire [3:0]  awcache_firewall_axim,
output wire [2:0]  awprot_firewall_axim,
output wire        awvalid_firewall_axim,
input  wire        awready_firewall_axim,
output wire [31:0] wdata_firewall_axim,
output wire [3:0]  wstrb_firewall_axim,
output wire        wlast_firewall_axim,
output wire        wvalid_firewall_axim,
input  wire        wready_firewall_axim,
input  wire [9:0]  bid_firewall_axim,
input  wire [1:0]  bresp_firewall_axim,
input  wire        bvalid_firewall_axim,
output wire        bready_firewall_axim,
output wire [9:0]  arid_firewall_axim,
output wire [31:0] araddr_firewall_axim,
output wire [7:0]  arlen_firewall_axim,
output wire [2:0]  arsize_firewall_axim,
output wire [1:0]  arburst_firewall_axim,
output wire        arlock_firewall_axim,
output wire [3:0]  arcache_firewall_axim,
output wire [2:0]  arprot_firewall_axim,
output wire        arvalid_firewall_axim,
input  wire        arready_firewall_axim,
input  wire [9:0]  rid_firewall_axim,
input  wire [31:0] rdata_firewall_axim,
input  wire [1:0]  rresp_firewall_axim,
input  wire        rlast_firewall_axim,
input  wire        rvalid_firewall_axim,
output wire        rready_firewall_axim,
output wire [9:0]  awuser_firewall_axim,
output wire [9:0]  aruser_firewall_axim,
input  wire        ruser_firewall_axim,
input  wire        buser_firewall_axim,


output wire [GLOBAL_ID_WIDTH-1:0] awid_ocvm_axim,
output wire [31:0] awaddr_ocvm_axim,
output wire [7:0]  awlen_ocvm_axim,
output wire [2:0]  awsize_ocvm_axim,
output wire [1:0]  awburst_ocvm_axim,
output wire        awlock_ocvm_axim,
output wire [3:0]  awcache_ocvm_axim,
output wire [2:0]  awprot_ocvm_axim,
output wire        awvalid_ocvm_axim,
output wire        awakeup_ocvm_axim,
input  wire        awready_ocvm_axim,
output wire [OCVM_DATA_WIDTH-1:0] wdata_ocvm_axim,
output wire [(OCVM_DATA_WIDTH/8)-1:0]  wstrb_ocvm_axim,
output wire        wlast_ocvm_axim,
output wire        wvalid_ocvm_axim,
input  wire        wready_ocvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_ocvm_axim,
input  wire [1:0]  bresp_ocvm_axim,
input  wire        bvalid_ocvm_axim,
output wire        bready_ocvm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_ocvm_axim,
output wire [31:0] araddr_ocvm_axim,
output wire [7:0]  arlen_ocvm_axim,
output wire [2:0]  arsize_ocvm_axim,
output wire [1:0]  arburst_ocvm_axim,
output wire        arlock_ocvm_axim,
output wire [3:0]  arcache_ocvm_axim,
output wire [2:0]  arprot_ocvm_axim,
output wire        arvalid_ocvm_axim,
input  wire        arready_ocvm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_ocvm_axim,
input  wire [OCVM_DATA_WIDTH-1:0] rdata_ocvm_axim,
input  wire [1:0]  rresp_ocvm_axim,
input  wire        rlast_ocvm_axim,
input  wire        rvalid_ocvm_axim,
output wire        rready_ocvm_axim,
output wire [9:0]  awuser_ocvm_axim,
output wire [9:0]  aruser_ocvm_axim,
output wire [3:0]  awqos_ocvm_axim,
output wire [3:0]  arqos_ocvm_axim,


output wire [9:0]  awid_bootreg_axim,
output wire [39:0] awaddr_bootreg_axim,
output wire [7:0]  awlen_bootreg_axim,
output wire [2:0]  awsize_bootreg_axim,
output wire [1:0]  awburst_bootreg_axim,
output wire        awlock_bootreg_axim,
output wire [3:0]  awcache_bootreg_axim,
output wire [2:0]  awprot_bootreg_axim,
output wire        awvalid_bootreg_axim,
input  wire        awready_bootreg_axim,
output wire [31:0] wdata_bootreg_axim,
output wire [3:0]  wstrb_bootreg_axim,
output wire        wlast_bootreg_axim,
output wire        wvalid_bootreg_axim,
input  wire        wready_bootreg_axim,
input  wire [9:0]  bid_bootreg_axim,
input  wire [1:0]  bresp_bootreg_axim,
input  wire        bvalid_bootreg_axim,
output wire        bready_bootreg_axim,
output wire [9:0]  arid_bootreg_axim,
output wire [39:0] araddr_bootreg_axim,
output wire [7:0]  arlen_bootreg_axim,
output wire [2:0]  arsize_bootreg_axim,
output wire [1:0]  arburst_bootreg_axim,
output wire        arlock_bootreg_axim,
output wire [3:0]  arcache_bootreg_axim,
output wire [2:0]  arprot_bootreg_axim,
output wire        arvalid_bootreg_axim,
input  wire        arready_bootreg_axim,
input  wire [9:0]  rid_bootreg_axim,
input  wire [31:0] rdata_bootreg_axim,
input  wire [1:0]  rresp_bootreg_axim,
input  wire        rlast_bootreg_axim,
input  wire        rvalid_bootreg_axim,
output wire        rready_bootreg_axim,
output wire [9:0]  awuser_bootreg_axim,
output wire [9:0]  aruser_bootreg_axim,



input  wire [3:0]  awid_debug_axis,
input  wire [31:0] awaddr_debug_axis,
input  wire [7:0]  awlen_debug_axis,
input  wire [2:0]  awsize_debug_axis,
input  wire [1:0]  awburst_debug_axis,
input  wire        awlock_debug_axis,
input  wire [3:0]  awcache_debug_axis,
input  wire [2:0]  awprot_debug_axis,
input  wire        awvalid_debug_axis,
output wire        awready_debug_axis,
input  wire [63:0] wdata_debug_axis,
input  wire [7:0]  wstrb_debug_axis,
input  wire        wlast_debug_axis,
input  wire        wvalid_debug_axis,
output wire        wready_debug_axis,
output wire [3:0]  bid_debug_axis,
output wire [1:0]  bresp_debug_axis,
output wire        bvalid_debug_axis,
input  wire        bready_debug_axis,
input  wire [3:0]  arid_debug_axis,
input  wire [31:0] araddr_debug_axis,
input  wire [7:0]  arlen_debug_axis,
input  wire [2:0]  arsize_debug_axis,
input  wire [1:0]  arburst_debug_axis,
input  wire        arlock_debug_axis,
input  wire [3:0]  arcache_debug_axis,
input  wire [2:0]  arprot_debug_axis,
input  wire        arvalid_debug_axis,
output wire        arready_debug_axis,
output wire [3:0]  rid_debug_axis,
output wire [63:0] rdata_debug_axis,
output wire [1:0]  rresp_debug_axis,
output wire        rlast_debug_axis,
output wire        rvalid_debug_axis,
input  wire        rready_debug_axis,
input  wire [9:0]  awuser_debug_axis,
input  wire [9:0]  aruser_debug_axis,
output wire        buser_debug_axis,
output wire        ruser_debug_axis,


input  wire [EXPSLV0_ID_WIDTH-1:0]  awid_expslv0_axis,
input  wire [31:0] awaddr_expslv0_axis,
input  wire [7:0]  awlen_expslv0_axis,
input  wire [2:0]  awsize_expslv0_axis,
input  wire [1:0]  awburst_expslv0_axis,
input  wire        awlock_expslv0_axis,
input  wire [3:0]  awcache_expslv0_axis,
input  wire [2:0]  awprot_expslv0_axis,
input  wire        awvalid_expslv0_axis,
input  wire        awakeup_expslv0_axis,
output wire        awready_expslv0_axis,
input  wire [EXPSLV0_DATA_WIDTH-1:0] wdata_expslv0_axis,
input  wire [(EXPSLV0_DATA_WIDTH/8)-1:0]  wstrb_expslv0_axis,
input  wire        wlast_expslv0_axis,
input  wire        wvalid_expslv0_axis,
output wire        wready_expslv0_axis,
output wire [EXPSLV0_ID_WIDTH-1:0]  bid_expslv0_axis,
output wire [1:0]  bresp_expslv0_axis,
output wire        bvalid_expslv0_axis,
input  wire        bready_expslv0_axis,
input  wire [EXPSLV0_ID_WIDTH-1:0]  arid_expslv0_axis,
input  wire [31:0] araddr_expslv0_axis,
input  wire [7:0]  arlen_expslv0_axis,
input  wire [2:0]  arsize_expslv0_axis,
input  wire [1:0]  arburst_expslv0_axis,
input  wire        arlock_expslv0_axis,
input  wire [3:0]  arcache_expslv0_axis,
input  wire [2:0]  arprot_expslv0_axis,
input  wire        arvalid_expslv0_axis,
output wire        arready_expslv0_axis,
output wire [EXPSLV0_ID_WIDTH-1:0]  rid_expslv0_axis,
output wire [EXPSLV0_DATA_WIDTH-1:0] rdata_expslv0_axis,
output wire [1:0]  rresp_expslv0_axis,
output wire        rlast_expslv0_axis,
output wire        rvalid_expslv0_axis,
input  wire        rready_expslv0_axis,
input  wire [9:0]  awuser_expslv0_axis,
input  wire [9:0]  aruser_expslv0_axis,
input  wire [3:0]  awqos_expslv0_axis,
input  wire [3:0]  arqos_expslv0_axis,


input  wire [EXPSLV1_ID_WIDTH-1:0]  awid_expslv1_axis,
input  wire [31:0] awaddr_expslv1_axis,
input  wire [7:0]  awlen_expslv1_axis,
input  wire [2:0]  awsize_expslv1_axis,
input  wire [1:0]  awburst_expslv1_axis,
input  wire        awlock_expslv1_axis,
input  wire [3:0]  awcache_expslv1_axis,
input  wire [2:0]  awprot_expslv1_axis,
input  wire        awvalid_expslv1_axis,
input  wire        awakeup_expslv1_axis,
output wire        awready_expslv1_axis,
input  wire [EXPSLV1_DATA_WIDTH-1:0] wdata_expslv1_axis,
input  wire [(EXPSLV1_DATA_WIDTH/8)-1:0]  wstrb_expslv1_axis,
input  wire        wlast_expslv1_axis,
input  wire        wvalid_expslv1_axis,
output wire        wready_expslv1_axis,
output wire [EXPSLV1_ID_WIDTH-1:0]  bid_expslv1_axis,
output wire [1:0]  bresp_expslv1_axis,
output wire        bvalid_expslv1_axis,
input  wire        bready_expslv1_axis,
input  wire [EXPSLV1_ID_WIDTH-1:0]  arid_expslv1_axis,
input  wire [31:0] araddr_expslv1_axis,
input  wire [7:0]  arlen_expslv1_axis,
input  wire [2:0]  arsize_expslv1_axis,
input  wire [1:0]  arburst_expslv1_axis,
input  wire        arlock_expslv1_axis,
input  wire [3:0]  arcache_expslv1_axis,
input  wire [2:0]  arprot_expslv1_axis,
input  wire        arvalid_expslv1_axis,
output wire        arready_expslv1_axis,
output wire [EXPSLV1_ID_WIDTH-1:0]  rid_expslv1_axis,
output wire [EXPSLV1_DATA_WIDTH-1:0] rdata_expslv1_axis,
output wire [1:0]  rresp_expslv1_axis,
output wire        rlast_expslv1_axis,
output wire        rvalid_expslv1_axis,
input  wire        rready_expslv1_axis,
input  wire [9:0]  awuser_expslv1_axis,
input  wire [9:0]  aruser_expslv1_axis,
input  wire [3:0]  awqos_expslv1_axis,
input  wire [3:0]  arqos_expslv1_axis,


input  wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  awid_extsys0_axis,
input  wire [31:0] awaddr_extsys0_axis,
input  wire [7:0]  awlen_extsys0_axis,
input  wire [2:0]  awsize_extsys0_axis,
input  wire [1:0]  awburst_extsys0_axis,
input  wire        awlock_extsys0_axis,
input  wire [3:0]  awcache_extsys0_axis,
input  wire [2:0]  awprot_extsys0_axis,
input  wire        awvalid_extsys0_axis,
input  wire        awakeup_extsys0_axis,
output wire        awready_extsys0_axis,
input  wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] wdata_extsys0_axis,
input  wire [(EXT_SYS0_MEM_DATA_WIDTH/8)-1:0]  wstrb_extsys0_axis,
input  wire        wlast_extsys0_axis,
input  wire        wvalid_extsys0_axis,
output wire        wready_extsys0_axis,
output wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  bid_extsys0_axis,
output wire [1:0]  bresp_extsys0_axis,
output wire        bvalid_extsys0_axis,
input  wire        bready_extsys0_axis,
input  wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  arid_extsys0_axis,
input  wire [31:0] araddr_extsys0_axis,
input  wire [7:0]  arlen_extsys0_axis,
input  wire [2:0]  arsize_extsys0_axis,
input  wire [1:0]  arburst_extsys0_axis,
input  wire        arlock_extsys0_axis,
input  wire [3:0]  arcache_extsys0_axis,
input  wire [2:0]  arprot_extsys0_axis,
input  wire        arvalid_extsys0_axis,
output wire        arready_extsys0_axis,
output wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  rid_extsys0_axis,
output wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] rdata_extsys0_axis,
output wire [1:0]  rresp_extsys0_axis,
output wire        rlast_extsys0_axis,
output wire        rvalid_extsys0_axis,
input  wire        rready_extsys0_axis,
input  wire [9:0]  awuser_extsys0_axis,
input  wire [9:0]  aruser_extsys0_axis,


input  wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  awid_extsys1_axis,
input  wire [31:0] awaddr_extsys1_axis,
input  wire [7:0]  awlen_extsys1_axis,
input  wire [2:0]  awsize_extsys1_axis,
input  wire [1:0]  awburst_extsys1_axis,
input  wire        awlock_extsys1_axis,
input  wire [3:0]  awcache_extsys1_axis,
input  wire [2:0]  awprot_extsys1_axis,
input  wire        awvalid_extsys1_axis,
input  wire        awakeup_extsys1_axis,
output wire        awready_extsys1_axis,
input  wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] wdata_extsys1_axis,
input  wire [(EXT_SYS1_MEM_DATA_WIDTH/8)-1:0]  wstrb_extsys1_axis,
input  wire        wlast_extsys1_axis,
input  wire        wvalid_extsys1_axis,
output wire        wready_extsys1_axis,
output wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  bid_extsys1_axis,
output wire [1:0]  bresp_extsys1_axis,
output wire        bvalid_extsys1_axis,
input  wire        bready_extsys1_axis,
input  wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  arid_extsys1_axis,
input  wire [31:0] araddr_extsys1_axis,
input  wire [7:0]  arlen_extsys1_axis,
input  wire [2:0]  arsize_extsys1_axis,
input  wire [1:0]  arburst_extsys1_axis,
input  wire        arlock_extsys1_axis,
input  wire [3:0]  arcache_extsys1_axis,
input  wire [2:0]  arprot_extsys1_axis,
input  wire        arvalid_extsys1_axis,
output wire        arready_extsys1_axis,
output wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  rid_extsys1_axis,
output wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] rdata_extsys1_axis,
output wire [1:0]  rresp_extsys1_axis,
output wire        rlast_extsys1_axis,
output wire        rvalid_extsys1_axis,
input  wire        rready_extsys1_axis,
input  wire [9:0]  awuser_extsys1_axis,
input  wire [9:0]  aruser_extsys1_axis,


input  wire [7:0]  awid_hostcpu_axis,
input  wire [39:0] awaddr_hostcpu_axis,
input  wire [7:0]  awlen_hostcpu_axis,
input  wire [2:0]  awsize_hostcpu_axis,
input  wire [1:0]  awburst_hostcpu_axis,
input  wire        awlock_hostcpu_axis,
input  wire [3:0]  awcache_hostcpu_axis,
input  wire [2:0]  awprot_hostcpu_axis,
input  wire        awvalid_hostcpu_axis,
output wire        awready_hostcpu_axis,
input  wire [127:0] wdata_hostcpu_axis,
input  wire [15:0] wstrb_hostcpu_axis,
input  wire        wlast_hostcpu_axis,
input  wire        wvalid_hostcpu_axis,
output wire        wready_hostcpu_axis,
output wire [7:0]  bid_hostcpu_axis,
output wire [1:0]  bresp_hostcpu_axis,
output wire        bvalid_hostcpu_axis,
input  wire        bready_hostcpu_axis,
input  wire [7:0]  arid_hostcpu_axis,
input  wire [39:0] araddr_hostcpu_axis,
input  wire [7:0]  arlen_hostcpu_axis,
input  wire [2:0]  arsize_hostcpu_axis,
input  wire [1:0]  arburst_hostcpu_axis,
input  wire        arlock_hostcpu_axis,
input  wire [3:0]  arcache_hostcpu_axis,
input  wire [2:0]  arprot_hostcpu_axis,
input  wire        arvalid_hostcpu_axis,
output wire        arready_hostcpu_axis,
output wire [7:0]  rid_hostcpu_axis,
output wire [127:0] rdata_hostcpu_axis,
output wire [1:0]  rresp_hostcpu_axis,
output wire        rlast_hostcpu_axis,
output wire        rvalid_hostcpu_axis,
input  wire        rready_hostcpu_axis,
input  wire [9:0]  awuser_hostcpu_axis,
input  wire [9:0]  aruser_hostcpu_axis,


input  wire [7:0]  awid_secenc_axis,
input  wire [39:0] awaddr_secenc_axis,
input  wire [7:0]  awlen_secenc_axis,
input  wire [2:0]  awsize_secenc_axis,
input  wire [1:0]  awburst_secenc_axis,
input  wire        awlock_secenc_axis,
input  wire [3:0]  awcache_secenc_axis,
input  wire [2:0]  awprot_secenc_axis,
input  wire        awvalid_secenc_axis,
output wire        awready_secenc_axis,
input  wire [31:0] wdata_secenc_axis,
input  wire [3:0]  wstrb_secenc_axis,
input  wire        wlast_secenc_axis,
input  wire        wvalid_secenc_axis,
output wire        wready_secenc_axis,
output wire [7:0]  bid_secenc_axis,
output wire [1:0]  bresp_secenc_axis,
output wire        bvalid_secenc_axis,
input  wire        bready_secenc_axis,
input  wire [7:0]  arid_secenc_axis,
input  wire [39:0] araddr_secenc_axis,
input  wire [7:0]  arlen_secenc_axis,
input  wire [2:0]  arsize_secenc_axis,
input  wire [1:0]  arburst_secenc_axis,
input  wire        arlock_secenc_axis,
input  wire [3:0]  arcache_secenc_axis,
input  wire [2:0]  arprot_secenc_axis,
input  wire        arvalid_secenc_axis,
output wire        arready_secenc_axis,
output wire [7:0]  rid_secenc_axis,
output wire [31:0] rdata_secenc_axis,
output wire [1:0]  rresp_secenc_axis,
output wire        rlast_secenc_axis,
output wire        rvalid_secenc_axis,
input  wire        rready_secenc_axis,
input  wire [9:0]  awuser_secenc_axis,
input  wire [9:0]  aruser_secenc_axis,
output wire        buser_secenc_axis,
output wire        ruser_secenc_axis,


output wire [31:0] paddr_extdbg_apb,
output wire        pselx_extdbg_apb,
output wire        penable_extdbg_apb,
output wire        pwrite_extdbg_apb,
input  wire [31:0] prdata_extdbg_apb,
output wire [31:0] pwdata_extdbg_apb,
output wire [2:0]  pprot_extdbg_apb,
output wire [3:0]  pstrb_extdbg_apb,
input  wire        pready_extdbg_apb,
input  wire        pslverr_extdbg_apb,


output wire [GLOBAL_ID_WIDTH-1:0] awid_gic_axim,
output wire [31:0] awaddr_gic_axim,
output wire [7:0]  awlen_gic_axim,
output wire [2:0]  awsize_gic_axim,
output wire [1:0]  awburst_gic_axim,
output wire        awlock_gic_axim,
output wire [3:0]  awcache_gic_axim,
output wire [2:0]  awprot_gic_axim,
output wire [3:0]  awqos_gic_axim,
output wire        awvalid_gic_axim,
input  wire        awready_gic_axim,
output wire [31:0] wdata_gic_axim,
output wire [3:0]  wstrb_gic_axim,
output wire        wlast_gic_axim,
output wire        wvalid_gic_axim,
input  wire        wready_gic_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_gic_axim,
input  wire [1:0]  bresp_gic_axim,
input  wire        bvalid_gic_axim,
output wire        bready_gic_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_gic_axim,
output wire [31:0] araddr_gic_axim,
output wire [7:0]  arlen_gic_axim,
output wire [2:0]  arsize_gic_axim,
output wire [1:0]  arburst_gic_axim,
output wire        arlock_gic_axim,
output wire [3:0]  arcache_gic_axim,
output wire [2:0]  arprot_gic_axim,
output wire [3:0]  arqos_gic_axim,
output wire        arvalid_gic_axim,
input  wire        arready_gic_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_gic_axim,
input  wire [31:0] rdata_gic_axim,
input  wire [1:0]  rresp_gic_axim,
input  wire        rlast_gic_axim,
input  wire        rvalid_gic_axim,
output wire        rready_gic_axim,
output wire [9:0]  awuser_gic_axim,
output wire [9:0]  aruser_gic_axim,


output wire [31:0] paddr_hostsysdbg_apb,
output wire        pselx_hostsysdbg_apb,
output wire        penable_hostsysdbg_apb,
output wire        pwrite_hostsysdbg_apb,
input  wire [31:0] prdata_hostsysdbg_apb,
output wire [31:0] pwdata_hostsysdbg_apb,
output wire [2:0]  pprot_hostsysdbg_apb,
output wire [3:0]  pstrb_hostsysdbg_apb,
input  wire        pready_hostsysdbg_apb,
input  wire        pslverr_hostsysdbg_apb,


output wire [31:0] paddr_hse_mhu0,
output wire        pselx_hse_mhu0,
output wire        penable_hse_mhu0,
output wire        pwrite_hse_mhu0,
input  wire [31:0] prdata_hse_mhu0,
output wire [31:0] pwdata_hse_mhu0,
output wire [2:0]  pprot_hse_mhu0,
output wire [3:0]  pstrb_hse_mhu0,
input  wire        pready_hse_mhu0,
input  wire        pslverr_hse_mhu0,


output wire [31:0] paddr_hse_mhu1,
output wire        pselx_hse_mhu1,
output wire        penable_hse_mhu1,
output wire        pwrite_hse_mhu1,
input  wire [31:0] prdata_hse_mhu1,
output wire [31:0] pwdata_hse_mhu1,
output wire [2:0]  pprot_hse_mhu1,
output wire [3:0]  pstrb_hse_mhu1,
input  wire        pready_hse_mhu1,
input  wire        pslverr_hse_mhu1,


output wire [31:0] paddr_sdc600_apb,
output wire        pselx_sdc600_apb,
output wire        penable_sdc600_apb,
output wire        pwrite_sdc600_apb,
input  wire [31:0] prdata_sdc600_apb,
output wire [31:0] pwdata_sdc600_apb,
output wire [2:0]  pprot_sdc600_apb,
output wire [3:0]  pstrb_sdc600_apb,
input  wire        pready_sdc600_apb,
input  wire        pslverr_sdc600_apb,


output wire [31:0] paddr_seh_mhu0,
output wire        pselx_seh_mhu0,
output wire        penable_seh_mhu0,
output wire        pwrite_seh_mhu0,
input  wire [31:0] prdata_seh_mhu0,
output wire [31:0] pwdata_seh_mhu0,
output wire [2:0]  pprot_seh_mhu0,
output wire [3:0]  pstrb_seh_mhu0,
input  wire        pready_seh_mhu0,
input  wire        pslverr_seh_mhu0,


output wire [31:0] paddr_seh_mhu1,
output wire        pselx_seh_mhu1,
output wire        penable_seh_mhu1,
output wire        pwrite_seh_mhu1,
input  wire [31:0] prdata_seh_mhu1,
output wire [31:0] pwdata_seh_mhu1,
output wire [2:0]  pprot_seh_mhu1,
output wire [3:0]  pstrb_seh_mhu1,
input  wire        pready_seh_mhu1,
input  wire        pslverr_seh_mhu1,


output wire [GLOBAL_ID_WIDTH-1:0] awid_stm_axim,
output wire [31:0] awaddr_stm_axim,
output wire [7:0]  awlen_stm_axim,
output wire [2:0]  awsize_stm_axim,
output wire [1:0]  awburst_stm_axim,
output wire        awlock_stm_axim,
output wire [3:0]  awcache_stm_axim,
output wire [2:0]  awprot_stm_axim,
output wire        awvalid_stm_axim,
input  wire        awready_stm_axim,
output wire [63:0] wdata_stm_axim,
output wire [7:0]  wstrb_stm_axim,
output wire        wlast_stm_axim,
output wire        wvalid_stm_axim,
input  wire        wready_stm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] bid_stm_axim,
input  wire [1:0]  bresp_stm_axim,
input  wire        bvalid_stm_axim,
output wire        bready_stm_axim,
output wire [GLOBAL_ID_WIDTH-1:0] arid_stm_axim,
output wire [31:0] araddr_stm_axim,
output wire [7:0]  arlen_stm_axim,
output wire [2:0]  arsize_stm_axim,
output wire [1:0]  arburst_stm_axim,
output wire        arlock_stm_axim,
output wire [3:0]  arcache_stm_axim,
output wire [2:0]  arprot_stm_axim,
output wire        arvalid_stm_axim,
input  wire        arready_stm_axim,
input  wire [GLOBAL_ID_WIDTH-1:0] rid_stm_axim,
input  wire [63:0] rdata_stm_axim,
input  wire [1:0]  rresp_stm_axim,
input  wire        rlast_stm_axim,
input  wire        rvalid_stm_axim,
output wire        rready_stm_axim,
output wire [9:0]  awuser_stm_axim,
output wire [9:0]  aruser_stm_axim,




output wire [31:0] paddr_es0h_mhu0,
output wire        pselx_es0h_mhu0,
output wire        penable_es0h_mhu0,
output wire        pwrite_es0h_mhu0,
input  wire [31:0] prdata_es0h_mhu0,
output wire [31:0] pwdata_es0h_mhu0,
output wire [2:0]  pprot_es0h_mhu0,
output wire [3:0]  pstrb_es0h_mhu0,
input  wire        pready_es0h_mhu0,
input  wire        pslverr_es0h_mhu0,


output wire [31:0] paddr_hes0_mhu0,
output wire        pselx_hes0_mhu0,
output wire        penable_hes0_mhu0,
output wire        pwrite_hes0_mhu0,
input  wire [31:0] prdata_hes0_mhu0,
output wire [31:0] pwdata_hes0_mhu0,
output wire [2:0]  pprot_hes0_mhu0,
output wire [3:0]  pstrb_hes0_mhu0,
input  wire        pready_hes0_mhu0,
input  wire        pslverr_hes0_mhu0,

    

output wire [31:0] paddr_es0h_mhu1,
output wire        pselx_es0h_mhu1,
output wire        penable_es0h_mhu1,
output wire        pwrite_es0h_mhu1,
input  wire [31:0] prdata_es0h_mhu1,
output wire [31:0] pwdata_es0h_mhu1,
output wire [2:0]  pprot_es0h_mhu1,
output wire [3:0]  pstrb_es0h_mhu1,
input  wire        pready_es0h_mhu1,
input  wire        pslverr_es0h_mhu1,


output wire [31:0] paddr_hes0_mhu1,
output wire        pselx_hes0_mhu1,
output wire        penable_hes0_mhu1,
output wire        pwrite_hes0_mhu1,
input  wire [31:0] prdata_hes0_mhu1,
output wire [31:0] pwdata_hes0_mhu1,
output wire [2:0]  pprot_hes0_mhu1,
output wire [3:0]  pstrb_hes0_mhu1,
input  wire        pready_hes0_mhu1,
input  wire        pslverr_hes0_mhu1,

  

output wire [31:0] paddr_es1h_mhu0,
output wire        pselx_es1h_mhu0,
output wire        penable_es1h_mhu0,
output wire        pwrite_es1h_mhu0,
input  wire [31:0] prdata_es1h_mhu0,
output wire [31:0] pwdata_es1h_mhu0,
output wire [2:0]  pprot_es1h_mhu0,
output wire [3:0]  pstrb_es1h_mhu0,
input  wire        pready_es1h_mhu0,
input  wire        pslverr_es1h_mhu0,


output wire [31:0] paddr_hes1_mhu0,
output wire        pselx_hes1_mhu0,
output wire        penable_hes1_mhu0,
output wire        pwrite_hes1_mhu0,
input  wire [31:0] prdata_hes1_mhu0,
output wire [31:0] pwdata_hes1_mhu0,
output wire [2:0]  pprot_hes1_mhu0,
output wire [3:0]  pstrb_hes1_mhu0,
input  wire        pready_hes1_mhu0,
input  wire        pslverr_hes1_mhu0,

    

output wire [31:0] paddr_es1h_mhu1,
output wire        pselx_es1h_mhu1,
output wire        penable_es1h_mhu1,
output wire        pwrite_es1h_mhu1,
input  wire [31:0] prdata_es1h_mhu1,
output wire [31:0] pwdata_es1h_mhu1,
output wire [2:0]  pprot_es1h_mhu1,
output wire [3:0]  pstrb_es1h_mhu1,
input  wire        pready_es1h_mhu1,
input  wire        pslverr_es1h_mhu1,


output wire [31:0] paddr_hes1_mhu1,
output wire        pselx_hes1_mhu1,
output wire        penable_hes1_mhu1,
output wire        pwrite_hes1_mhu1,
input  wire [31:0] prdata_hes1_mhu1,
output wire [31:0] pwdata_hes1_mhu1,
output wire [2:0]  pprot_hes1_mhu1,
output wire [3:0]  pstrb_hes1_mhu1,
input  wire        pready_hes1_mhu1,
input  wire        pslverr_hes1_mhu1,

  

input  wire         csysreq_cd_ctrl,    
output wire         csysack_cd_ctrl,    
output wire         cactive_cd_ctrl,    


output wire [31:0] paddr_ppu_cpu_apb,
output wire        pselx_ppu_cpu_apb,
output wire        penable_ppu_cpu_apb,
output wire        pwrite_ppu_cpu_apb,
input  wire [31:0] prdata_ppu_cpu_apb,
output wire [31:0] pwdata_ppu_cpu_apb,
output wire [2:0]  pprot_ppu_cpu_apb,
output wire [3:0]  pstrb_ppu_cpu_apb,
input  wire        pready_ppu_cpu_apb,
input  wire        pslverr_ppu_cpu_apb,

output wire        tvalid_dti_dn_m,
input  wire        tready_dti_dn_m,
output wire [31:0] tdata_dti_dn_m,
output wire [3:0]  tkeep_dti_dn_m,
output wire [3:0]  tid_dti_dn_m,
output wire        tlast_dti_dn_m,
output wire        twakeup_dti_dn_m,
input  wire         tvalid_dti_up_m,
output wire         tready_dti_up_m,
input  wire [31:0]  tdata_dti_up_m,
input  wire [3:0]   tkeep_dti_up_m,
input  wire [3:0]   tdest_dti_up_m,
input  wire         tlast_dti_up_m,
input  wire         twakeup_dti_up_m

);

 

wire [GLOBAL_ID_WIDTH-1:0] awid_sysctrl_axim;
wire [31:0] awaddr_sysctrl_axim;
wire [7:0]  awlen_sysctrl_axim;
wire [2:0]  awsize_sysctrl_axim;
wire [1:0]  awburst_sysctrl_axim;
wire        awlock_sysctrl_axim;
wire [3:0]  awcache_sysctrl_axim;
wire [1:0]  awprot_sysctrl_axim;
wire        awvalid_sysctrl_axim;
wire        awready_sysctrl_axim;
wire [31:0] wdata_sysctrl_axim;
wire [3:0]  wstrb_sysctrl_axim;
wire        wlast_sysctrl_axim;
wire        wvalid_sysctrl_axim;
wire        wready_sysctrl_axim;
wire [GLOBAL_ID_WIDTH-1:0] bid_sysctrl_axim;
wire [1:0]  bresp_sysctrl_axim;
wire        bvalid_sysctrl_axim;
wire        bready_sysctrl_axim;
wire [GLOBAL_ID_WIDTH-1:0] arid_sysctrl_axim;
wire [31:0] araddr_sysctrl_axim;
wire [7:0]  arlen_sysctrl_axim;
wire [2:0]  arsize_sysctrl_axim;
wire [1:0]  arburst_sysctrl_axim;
wire        arlock_sysctrl_axim;
wire [3:0]  arcache_sysctrl_axim;
wire [1:0]  arprot_sysctrl_axim;
wire        arvalid_sysctrl_axim;
wire        arready_sysctrl_axim;
wire [GLOBAL_ID_WIDTH-1:0] rid_sysctrl_axim;
wire [31:0] rdata_sysctrl_axim;
wire [1:0]  rresp_sysctrl_axim;
wire        rlast_sysctrl_axim;
wire        rvalid_sysctrl_axim;
wire        rready_sysctrl_axim;
wire [7:0]  awmmusid_sysctrl_axim;
wire [7:0]  armmusid_sysctrl_axim;


wire [GLOBAL_ID_WIDTH-1:0]  awid_sysperi_axim;
wire [31:0] awaddr_sysperi_axim;
wire [7:0]  awlen_sysperi_axim;
wire [2:0]  awsize_sysperi_axim;
wire [1:0]  awburst_sysperi_axim;
wire        awlock_sysperi_axim;
wire [3:0]  awcache_sysperi_axim;
wire [2:0]  awprot_sysperi_axim;
wire        awvalid_sysperi_axim;
wire        awready_sysperi_axim;
wire [31:0] wdata_sysperi_axim;
wire [3:0]  wstrb_sysperi_axim;
wire        wlast_sysperi_axim;
wire        wvalid_sysperi_axim;
wire        wready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  bid_sysperi_axim;
wire [1:0]  bresp_sysperi_axim;
wire        bvalid_sysperi_axim;
wire        bready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  arid_sysperi_axim;
wire [31:0] araddr_sysperi_axim;
wire [7:0]  arlen_sysperi_axim;
wire [2:0]  arsize_sysperi_axim;
wire [1:0]  arburst_sysperi_axim;
wire        arlock_sysperi_axim;
wire [3:0]  arcache_sysperi_axim;
wire [2:0]  arprot_sysperi_axim;
wire        arvalid_sysperi_axim;
wire        arready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  rid_sysperi_axim;
wire [31:0] rdata_sysperi_axim;
wire [1:0]  rresp_sysperi_axim;
wire        rlast_sysperi_axim;
wire        rvalid_sysperi_axim;
wire        rready_sysperi_axim;
wire [9:0]  awuser_sysperi_axim;
wire [9:0]  aruser_sysperi_axim;


wire  [7:0]  fc_awid_hostcpu_axis   ;
wire  [39:0] fc_awaddr_hostcpu_axis ;
wire  [7:0]  fc_awlen_hostcpu_axis  ;
wire  [2:0]  fc_awsize_hostcpu_axis ;
wire  [1:0]  fc_awburst_hostcpu_axis;
wire         fc_awlock_hostcpu_axis ;
wire  [3:0]  fc_awcache_hostcpu_axis;
wire  [2:0]  fc_awprot_hostcpu_axis ;
wire         fc_awvalid_hostcpu_axis;
wire         fc_awready_hostcpu_axis;
wire [127:0] fc_wdata_hostcpu_axis  ;
wire [15:0]  fc_wstrb_hostcpu_axis  ;
wire         fc_wlast_hostcpu_axis  ;
wire         fc_wvalid_hostcpu_axis ;
wire         fc_wready_hostcpu_axis ;
wire [7:0]   fc_bid_hostcpu_axis    ;
wire [1:0]   fc_bresp_hostcpu_axis  ;
wire         fc_bvalid_hostcpu_axis ;
wire         fc_bready_hostcpu_axis ;
wire [7:0]   fc_arid_hostcpu_axis   ;
wire [39:0]  fc_araddr_hostcpu_axis ;
wire [7:0]   fc_arlen_hostcpu_axis  ;
wire [2:0]   fc_arsize_hostcpu_axis ;
wire [1:0]   fc_arburst_hostcpu_axis;
wire         fc_arlock_hostcpu_axis ;
wire [3:0]   fc_arcache_hostcpu_axis;
wire [2:0]   fc_arprot_hostcpu_axis ;
wire         fc_arvalid_hostcpu_axis;
wire         fc_arready_hostcpu_axis;
wire [7:0]   fc_rid_hostcpu_axis    ;
wire [127:0] fc_rdata_hostcpu_axis  ;
wire [1:0]   fc_rresp_hostcpu_axis  ;
wire         fc_rlast_hostcpu_axis  ;
wire         fc_rvalid_hostcpu_axis ;
wire         fc_rready_hostcpu_axis ;
wire [9:0]   fc_awuser_hostcpu_axis ;
wire [9:0]   fc_aruser_hostcpu_axis ;
wire         fc_ruser_hostcpu_axis  ;
wire         fc_buser_hostcpu_axis  ;


wire [EXPSLV0_ID_WIDTH-1:0]  fc_awid_expslv0_axis;
wire [31:0] fc_awaddr_expslv0_axis;
wire [7:0]  fc_awlen_expslv0_axis;
wire [2:0]  fc_awsize_expslv0_axis;
wire [1:0]  fc_awburst_expslv0_axis;
wire        fc_awlock_expslv0_axis;
wire [3:0]  fc_awcache_expslv0_axis;
wire [2:0]  fc_awprot_expslv0_axis;
wire        fc_awvalid_expslv0_axis;
wire        fc_awready_expslv0_axis;
wire [EXPSLV0_DATA_WIDTH-1:0] fc_wdata_expslv0_axis;
wire [(EXPSLV0_DATA_WIDTH/8)-1:0]  fc_wstrb_expslv0_axis;
wire        fc_wlast_expslv0_axis;
wire        fc_wvalid_expslv0_axis;
wire        fc_wready_expslv0_axis;
wire [EXPSLV0_ID_WIDTH-1:0]  fc_bid_expslv0_axis;
wire [1:0]  fc_bresp_expslv0_axis;
wire        fc_bvalid_expslv0_axis;
wire        fc_bready_expslv0_axis;
wire [EXPSLV0_ID_WIDTH-1:0]  fc_arid_expslv0_axis;
wire [31:0] fc_araddr_expslv0_axis;
wire [7:0]  fc_arlen_expslv0_axis;
wire [2:0]  fc_arsize_expslv0_axis;
wire [1:0]  fc_arburst_expslv0_axis;
wire        fc_arlock_expslv0_axis;
wire [3:0]  fc_arcache_expslv0_axis;
wire [2:0]  fc_arprot_expslv0_axis;
wire        fc_arvalid_expslv0_axis;
wire        fc_arready_expslv0_axis;
wire [EXPSLV0_ID_WIDTH-1:0]  fc_rid_expslv0_axis;
wire [EXPSLV0_DATA_WIDTH-1:0] fc_rdata_expslv0_axis;
wire [1:0]  fc_rresp_expslv0_axis;
wire        fc_rlast_expslv0_axis;
wire        fc_rvalid_expslv0_axis;
wire        fc_rready_expslv0_axis;
wire [9:0]  fc_awuser_expslv0_axis;
wire [9:0]  fc_aruser_expslv0_axis;
wire [3:0]  fc_awqos_expslv0_axis;
wire [3:0]  fc_arqos_expslv0_axis;
wire        fc_buser_expslv0_axis;
wire        fc_ruser_expslv0_axis;


wire [EXPSLV1_ID_WIDTH-1:0]  fc_awid_expslv1_axis;
wire [31:0] fc_awaddr_expslv1_axis;
wire [7:0]  fc_awlen_expslv1_axis;
wire [2:0]  fc_awsize_expslv1_axis;
wire [1:0]  fc_awburst_expslv1_axis;
wire        fc_awlock_expslv1_axis;
wire [3:0]  fc_awcache_expslv1_axis;
wire [2:0]  fc_awprot_expslv1_axis;
wire        fc_awvalid_expslv1_axis;
wire        fc_awready_expslv1_axis;
wire [EXPSLV1_DATA_WIDTH-1:0] fc_wdata_expslv1_axis;
wire [(EXPSLV1_DATA_WIDTH/8)-1:0]  fc_wstrb_expslv1_axis;
wire        fc_wlast_expslv1_axis;
wire        fc_wvalid_expslv1_axis;
wire        fc_wready_expslv1_axis;
wire [EXPSLV1_ID_WIDTH-1:0]  fc_bid_expslv1_axis;
wire [1:0]  fc_bresp_expslv1_axis;
wire        fc_bvalid_expslv1_axis;
wire        fc_bready_expslv1_axis;
wire [EXPSLV1_ID_WIDTH-1:0]  fc_arid_expslv1_axis;
wire [31:0] fc_araddr_expslv1_axis;
wire [7:0]  fc_arlen_expslv1_axis;
wire [2:0]  fc_arsize_expslv1_axis;
wire [1:0]  fc_arburst_expslv1_axis;
wire        fc_arlock_expslv1_axis;
wire [3:0]  fc_arcache_expslv1_axis;
wire [2:0]  fc_arprot_expslv1_axis;
wire        fc_arvalid_expslv1_axis;
wire        fc_arready_expslv1_axis;
wire [EXPSLV1_ID_WIDTH-1:0]  fc_rid_expslv1_axis;
wire [EXPSLV1_DATA_WIDTH-1:0] fc_rdata_expslv1_axis;
wire [1:0]  fc_rresp_expslv1_axis;
wire        fc_rlast_expslv1_axis;
wire        fc_rvalid_expslv1_axis;
wire        fc_rready_expslv1_axis;
wire [9:0]  fc_awuser_expslv1_axis;
wire [9:0]  fc_aruser_expslv1_axis;
wire [3:0]  fc_awqos_expslv1_axis;
wire [3:0]  fc_arqos_expslv1_axis;
wire        fc_buser_expslv1_axis;
wire        fc_ruser_expslv1_axis;

wire [GLOBAL_ID_WIDTH-1:0] fc_awid_cvm_axim;
wire [31:0] fc_awaddr_cvm_axim;
wire [7:0]  fc_awlen_cvm_axim;
wire [2:0]  fc_awsize_cvm_axim;
wire [1:0]  fc_awburst_cvm_axim;
wire        fc_awlock_cvm_axim;
wire [3:0]  fc_awcache_cvm_axim;
wire [2:0]  fc_awprot_cvm_axim;
wire        fc_awvalid_cvm_axim;
wire        fc_awready_cvm_axim;
wire [CVM_DATA_WIDTH-1:0] fc_wdata_cvm_axim;
wire [(CVM_DATA_WIDTH/8)-1:0]  fc_wstrb_cvm_axim;
wire        fc_wlast_cvm_axim;
wire        fc_wvalid_cvm_axim;
wire        fc_wready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_bid_cvm_axim;
wire [1:0]  fc_bresp_cvm_axim;
wire        fc_bvalid_cvm_axim;
wire        fc_bready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_arid_cvm_axim;
wire [31:0] fc_araddr_cvm_axim;
wire [7:0]  fc_arlen_cvm_axim;
wire [2:0]  fc_arsize_cvm_axim;
wire [1:0]  fc_arburst_cvm_axim;
wire        fc_arlock_cvm_axim;
wire [3:0]  fc_arcache_cvm_axim;
wire [2:0]  fc_arprot_cvm_axim;
wire        fc_arvalid_cvm_axim;
wire        fc_arready_cvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_rid_cvm_axim;
wire [CVM_DATA_WIDTH-1:0] fc_rdata_cvm_axim;
wire [1:0]  fc_rresp_cvm_axim;
wire        fc_rlast_cvm_axim;
wire        fc_rvalid_cvm_axim;
wire        fc_rready_cvm_axim;
wire [9:0]  fc_awuser_cvm_axim;
wire [9:0]  fc_aruser_cvm_axim;
wire [3:0]  fc_awqos_cvm_axim;
wire [3:0]  fc_arqos_cvm_axim;
wire        fc_buser_cvm_axim;
wire        fc_ruser_cvm_axim;

wire [GLOBAL_ID_WIDTH-1:0] fc_awid_xnvm_axim;
wire [31:0] fc_awaddr_xnvm_axim;
wire [7:0]  fc_awlen_xnvm_axim;
wire [2:0]  fc_awsize_xnvm_axim;
wire [1:0]  fc_awburst_xnvm_axim;
wire        fc_awlock_xnvm_axim;
wire [3:0]  fc_awcache_xnvm_axim;
wire [2:0]  fc_awprot_xnvm_axim;
wire        fc_awvalid_xnvm_axim;
wire        fc_awready_xnvm_axim;
wire [XNVM_DATA_WIDTH-1:0] fc_wdata_xnvm_axim;
wire [(XNVM_DATA_WIDTH/8)-1:0]  fc_wstrb_xnvm_axim;
wire        fc_wlast_xnvm_axim;
wire        fc_wvalid_xnvm_axim;
wire        fc_wready_xnvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_bid_xnvm_axim;
wire [1:0]  fc_bresp_xnvm_axim;
wire        fc_bvalid_xnvm_axim;
wire        fc_bready_xnvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_arid_xnvm_axim;
wire [31:0] fc_araddr_xnvm_axim;
wire [7:0]  fc_arlen_xnvm_axim;
wire [2:0]  fc_arsize_xnvm_axim;
wire [1:0]  fc_arburst_xnvm_axim;
wire        fc_arlock_xnvm_axim;
wire [3:0]  fc_arcache_xnvm_axim;
wire [2:0]  fc_arprot_xnvm_axim;
wire        fc_arvalid_xnvm_axim;
wire        fc_arready_xnvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_rid_xnvm_axim;
wire [XNVM_DATA_WIDTH-1:0] fc_rdata_xnvm_axim;
wire [1:0]  fc_rresp_xnvm_axim;
wire        fc_rlast_xnvm_axim;
wire        fc_rvalid_xnvm_axim;
wire        fc_rready_xnvm_axim;
wire [9:0]  fc_awuser_xnvm_axim;
wire [9:0]  fc_aruser_xnvm_axim;
wire [3:0]  fc_awqos_xnvm_axim;
wire [3:0]  fc_arqos_xnvm_axim;
wire        fc_buser_xnvm_axim;
wire        fc_ruser_xnvm_axim;

wire [GLOBAL_ID_WIDTH-1:0] fc_awid_expmstr0_axim;
wire [31:0] fc_awaddr_expmstr0_axim;
wire [7:0]  fc_awlen_expmstr0_axim;
wire [2:0]  fc_awsize_expmstr0_axim;
wire [1:0]  fc_awburst_expmstr0_axim;
wire        fc_awlock_expmstr0_axim;
wire [3:0]  fc_awcache_expmstr0_axim;
wire [2:0]  fc_awprot_expmstr0_axim;
wire        fc_awvalid_expmstr0_axim;
wire        fc_awready_expmstr0_axim;
wire [EXPMST0_DATA_WIDTH-1:0] fc_wdata_expmstr0_axim;
wire [(EXPMST0_DATA_WIDTH/8)-1:0]  fc_wstrb_expmstr0_axim;
wire        fc_wlast_expmstr0_axim;
wire        fc_wvalid_expmstr0_axim;
wire        fc_wready_expmstr0_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_bid_expmstr0_axim;
wire [1:0]  fc_bresp_expmstr0_axim;
wire        fc_bvalid_expmstr0_axim;
wire        fc_bready_expmstr0_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_arid_expmstr0_axim;
wire [31:0] fc_araddr_expmstr0_axim;
wire [7:0]  fc_arlen_expmstr0_axim;
wire [2:0]  fc_arsize_expmstr0_axim;
wire [1:0]  fc_arburst_expmstr0_axim;
wire        fc_arlock_expmstr0_axim;
wire [3:0]  fc_arcache_expmstr0_axim;
wire [2:0]  fc_arprot_expmstr0_axim;
wire        fc_arvalid_expmstr0_axim;
wire        fc_arready_expmstr0_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_rid_expmstr0_axim;
wire [EXPMST0_DATA_WIDTH-1:0] fc_rdata_expmstr0_axim;
wire [1:0]  fc_rresp_expmstr0_axim;
wire        fc_rlast_expmstr0_axim;
wire        fc_rvalid_expmstr0_axim;
wire        fc_rready_expmstr0_axim;
wire [9:0]  fc_awuser_expmstr0_axim;
wire [9:0]  fc_aruser_expmstr0_axim;
wire [3:0]  fc_awqos_expmstr0_axim;
wire [3:0]  fc_arqos_expmstr0_axim;
wire        fc_ruser_expmstr0_axim;
wire        fc_buser_expmstr0_axim;

wire [GLOBAL_ID_WIDTH-1:0] fc_awid_expmstr1_axim;
wire [31:0] fc_awaddr_expmstr1_axim;
wire [7:0]  fc_awlen_expmstr1_axim;
wire [2:0]  fc_awsize_expmstr1_axim;
wire [1:0]  fc_awburst_expmstr1_axim;
wire        fc_awlock_expmstr1_axim;
wire [3:0]  fc_awcache_expmstr1_axim;
wire [2:0]  fc_awprot_expmstr1_axim;
wire        fc_awvalid_expmstr1_axim;
wire        fc_awready_expmstr1_axim;
wire [EXPMST1_DATA_WIDTH-1:0] fc_wdata_expmstr1_axim;
wire [(EXPMST1_DATA_WIDTH/8)-1:0]  fc_wstrb_expmstr1_axim;
wire        fc_wlast_expmstr1_axim;
wire        fc_wvalid_expmstr1_axim;
wire        fc_wready_expmstr1_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_bid_expmstr1_axim;
wire [1:0]  fc_bresp_expmstr1_axim;
wire        fc_bvalid_expmstr1_axim;
wire        fc_bready_expmstr1_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_arid_expmstr1_axim;
wire [31:0] fc_araddr_expmstr1_axim;
wire [7:0]  fc_arlen_expmstr1_axim;
wire [2:0]  fc_arsize_expmstr1_axim;
wire [1:0]  fc_arburst_expmstr1_axim;
wire        fc_arlock_expmstr1_axim;
wire [3:0]  fc_arcache_expmstr1_axim;
wire [2:0]  fc_arprot_expmstr1_axim;
wire        fc_arvalid_expmstr1_axim;
wire        fc_arready_expmstr1_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_rid_expmstr1_axim;
wire [EXPMST1_DATA_WIDTH-1:0] fc_rdata_expmstr1_axim;
wire [1:0]  fc_rresp_expmstr1_axim;
wire        fc_rlast_expmstr1_axim;
wire        fc_rvalid_expmstr1_axim;
wire        fc_rready_expmstr1_axim;
wire [9:0]  fc_awuser_expmstr1_axim;
wire [9:0]  fc_aruser_expmstr1_axim;
wire [3:0]  fc_awqos_expmstr1_axim;
wire [3:0]  fc_arqos_expmstr1_axim;
wire        fc_ruser_expmstr1_axim;
wire        fc_buser_expmstr1_axim;

wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  fc_awid_extsys0_axis;
wire [31:0] fc_awaddr_extsys0_axis;
wire [7:0]  fc_awlen_extsys0_axis;
wire [2:0]  fc_awsize_extsys0_axis;
wire [1:0]  fc_awburst_extsys0_axis;
wire        fc_awlock_extsys0_axis;
wire [3:0]  fc_awcache_extsys0_axis;
wire [2:0]  fc_awprot_extsys0_axis;
wire        fc_awvalid_extsys0_axis;
wire        fc_awready_extsys0_axis;
wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] fc_wdata_extsys0_axis;
wire [(EXT_SYS0_MEM_DATA_WIDTH/8)-1:0]  fc_wstrb_extsys0_axis;
wire        fc_wlast_extsys0_axis;
wire        fc_wvalid_extsys0_axis;
wire        fc_wready_extsys0_axis;
wire [EXT_SYS0_MEM_AWID_WIDTH-1:0]  fc_bid_extsys0_axis;
wire [1:0]  fc_bresp_extsys0_axis;
wire        fc_bvalid_extsys0_axis;
wire        fc_bready_extsys0_axis;
wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  fc_arid_extsys0_axis;
wire [31:0] fc_araddr_extsys0_axis;
wire [7:0]  fc_arlen_extsys0_axis;
wire [2:0]  fc_arsize_extsys0_axis;
wire [1:0]  fc_arburst_extsys0_axis;
wire        fc_arlock_extsys0_axis;
wire [3:0]  fc_arcache_extsys0_axis;
wire [2:0]  fc_arprot_extsys0_axis;
wire        fc_arvalid_extsys0_axis;
wire        fc_arready_extsys0_axis;
wire [EXT_SYS0_MEM_ARID_WIDTH-1:0]  fc_rid_extsys0_axis;
wire [EXT_SYS0_MEM_DATA_WIDTH-1:0] fc_rdata_extsys0_axis;
wire [1:0]  fc_rresp_extsys0_axis;
wire        fc_rlast_extsys0_axis;
wire        fc_rvalid_extsys0_axis;
wire        fc_rready_extsys0_axis;
wire [9:0]  fc_awuser_extsys0_axis;
wire [9:0]  fc_aruser_extsys0_axis;
wire        fc_ruser_extsys0_axis;
wire        fc_buser_extsys0_axis;

wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  fc_awid_extsys1_axis;
wire [31:0] fc_awaddr_extsys1_axis;
wire [7:0]  fc_awlen_extsys1_axis;
wire [2:0]  fc_awsize_extsys1_axis;
wire [1:0]  fc_awburst_extsys1_axis;
wire        fc_awlock_extsys1_axis;
wire [3:0]  fc_awcache_extsys1_axis;
wire [2:0]  fc_awprot_extsys1_axis;
wire        fc_awvalid_extsys1_axis;
wire        fc_awready_extsys1_axis;
wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] fc_wdata_extsys1_axis;
wire [(EXT_SYS1_MEM_DATA_WIDTH/8)-1:0]  fc_wstrb_extsys1_axis;
wire        fc_wlast_extsys1_axis;
wire        fc_wvalid_extsys1_axis;
wire        fc_wready_extsys1_axis;
wire [EXT_SYS1_MEM_AWID_WIDTH-1:0]  fc_bid_extsys1_axis;
wire [1:0]  fc_bresp_extsys1_axis;
wire        fc_bvalid_extsys1_axis;
wire        fc_bready_extsys1_axis;
wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  fc_arid_extsys1_axis;
wire [31:0] fc_araddr_extsys1_axis;
wire [7:0]  fc_arlen_extsys1_axis;
wire [2:0]  fc_arsize_extsys1_axis;
wire [1:0]  fc_arburst_extsys1_axis;
wire        fc_arlock_extsys1_axis;
wire [3:0]  fc_arcache_extsys1_axis;
wire [2:0]  fc_arprot_extsys1_axis;
wire        fc_arvalid_extsys1_axis;
wire        fc_arready_extsys1_axis;
wire [EXT_SYS1_MEM_ARID_WIDTH-1:0]  fc_rid_extsys1_axis;
wire [EXT_SYS1_MEM_DATA_WIDTH-1:0] fc_rdata_extsys1_axis;
wire [1:0]  fc_rresp_extsys1_axis;
wire        fc_rlast_extsys1_axis;
wire        fc_rvalid_extsys1_axis;
wire        fc_rready_extsys1_axis;
wire [9:0]  fc_awuser_extsys1_axis;
wire [9:0]  fc_aruser_extsys1_axis;
wire        fc_ruser_extsys1_axis;
wire        fc_buser_extsys1_axis;

wire [GLOBAL_ID_WIDTH-1:0] fc_awid_ocvm_axim;
wire [31:0] fc_awaddr_ocvm_axim;
wire [7:0]  fc_awlen_ocvm_axim;
wire [2:0]  fc_awsize_ocvm_axim;
wire [1:0]  fc_awburst_ocvm_axim;
wire        fc_awlock_ocvm_axim;
wire [3:0]  fc_awcache_ocvm_axim;
wire [2:0]  fc_awprot_ocvm_axim;
wire        fc_awvalid_ocvm_axim;
wire        fc_awready_ocvm_axim;
wire [OCVM_DATA_WIDTH-1:0] fc_wdata_ocvm_axim;
wire [(OCVM_DATA_WIDTH/8)-1:0]  fc_wstrb_ocvm_axim;
wire        fc_wlast_ocvm_axim;
wire        fc_wvalid_ocvm_axim;
wire        fc_wready_ocvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_bid_ocvm_axim;
wire [1:0]  fc_bresp_ocvm_axim;
wire        fc_bvalid_ocvm_axim;
wire        fc_bready_ocvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_arid_ocvm_axim;
wire [31:0] fc_araddr_ocvm_axim;
wire [7:0]  fc_arlen_ocvm_axim;
wire [2:0]  fc_arsize_ocvm_axim;
wire [1:0]  fc_arburst_ocvm_axim;
wire        fc_arlock_ocvm_axim;
wire [3:0]  fc_arcache_ocvm_axim;
wire [2:0]  fc_arprot_ocvm_axim;
wire        fc_arvalid_ocvm_axim;
wire        fc_arready_ocvm_axim;
wire [GLOBAL_ID_WIDTH-1:0] fc_rid_ocvm_axim;
wire [OCVM_DATA_WIDTH-1:0] fc_rdata_ocvm_axim;
wire [1:0]  fc_rresp_ocvm_axim;
wire        fc_rlast_ocvm_axim;
wire        fc_rvalid_ocvm_axim;
wire        fc_rready_ocvm_axim;
wire [9:0]  fc_awuser_ocvm_axim;
wire [9:0]  fc_aruser_ocvm_axim;
wire        fc_buser_ocvm_axim;
wire        fc_ruser_ocvm_axim;
wire [3:0]  fc_awqos_ocvm_axim;
wire [3:0]  fc_arqos_ocvm_axim;
        
wire [GLOBAL_ID_WIDTH-1:0]  fc_awid_sysperi_axim;
wire [31:0]  fc_awaddr_sysperi_axim;
wire [7:0]   fc_awlen_sysperi_axim;
wire [2:0]   fc_awsize_sysperi_axim;
wire [1:0]   fc_awburst_sysperi_axim;
wire         fc_awlock_sysperi_axim;
wire [3:0]   fc_awcache_sysperi_axim;
wire [2:0]   fc_awprot_sysperi_axim;
wire         fc_awvalid_sysperi_axim;
wire         fc_awready_sysperi_axim;
wire [31:0]  fc_wdata_sysperi_axim;
wire [3:0]   fc_wstrb_sysperi_axim;
wire         fc_wlast_sysperi_axim;
wire         fc_wvalid_sysperi_axim;
wire         fc_wready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  fc_bid_sysperi_axim;
wire [1:0]   fc_bresp_sysperi_axim;
wire         fc_bvalid_sysperi_axim;
wire         fc_bready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  fc_arid_sysperi_axim;
wire [31:0]  fc_araddr_sysperi_axim;
wire [7:0]   fc_arlen_sysperi_axim;
wire [2:0]   fc_arsize_sysperi_axim;
wire [1:0]   fc_arburst_sysperi_axim;
wire         fc_arlock_sysperi_axim;
wire [3:0]   fc_arcache_sysperi_axim;
wire [2:0]   fc_arprot_sysperi_axim;
wire         fc_arvalid_sysperi_axim;
wire         fc_arready_sysperi_axim;
wire [GLOBAL_ID_WIDTH-1:0]  fc_rid_sysperi_axim;
wire [31:0]  fc_rdata_sysperi_axim;
wire [1:0]   fc_rresp_sysperi_axim;
wire         fc_rlast_sysperi_axim;
wire         fc_rvalid_sysperi_axim;
wire         fc_rready_sysperi_axim;
wire [9:0]   fc_awuser_sysperi_axim;
wire [9:0]   fc_aruser_sysperi_axim;
wire         fc_buser_sysperi_axim;
wire         fc_ruser_sysperi_axim;

wire [8:0]  fc_awid_debug_axim;
wire [31:0]  fc_awaddr_debug_axim;
wire [7:0]   fc_awlen_debug_axim;
wire [2:0]   fc_awsize_debug_axim;
wire [1:0]   fc_awburst_debug_axim;
wire         fc_awlock_debug_axim;
wire [3:0]   fc_awcache_debug_axim;
wire [2:0]   fc_awprot_debug_axim;
wire         fc_awvalid_debug_axim;
wire         fc_awready_debug_axim;
wire [31:0]  fc_wdata_debug_axim;
wire [3:0]   fc_wstrb_debug_axim;
wire         fc_wlast_debug_axim;
wire         fc_wvalid_debug_axim;
wire         fc_wready_debug_axim;
wire [8:0]  fc_bid_debug_axim;
wire [1:0]   fc_bresp_debug_axim;
wire         fc_bvalid_debug_axim;
wire         fc_bready_debug_axim;
wire [8:0]  fc_arid_debug_axim;
wire [31:0]  fc_araddr_debug_axim;
wire [7:0]   fc_arlen_debug_axim;
wire [2:0]   fc_arsize_debug_axim;
wire [1:0]   fc_arburst_debug_axim;
wire         fc_arlock_debug_axim;
wire [3:0]   fc_arcache_debug_axim;
wire [2:0]   fc_arprot_debug_axim;
wire         fc_arvalid_debug_axim;
wire         fc_arready_debug_axim;
wire [8:0]  fc_rid_debug_axim;
wire [31:0]  fc_rdata_debug_axim;
wire [1:0]   fc_rresp_debug_axim;
wire         fc_rlast_debug_axim;
wire         fc_rvalid_debug_axim;
wire         fc_rready_debug_axim;
wire [9:0]   fc_awuser_debug_axim;
wire [9:0]   fc_aruser_debug_axim;
wire         fc_buser_debug_axim;
wire         fc_ruser_debug_axim;

wire [8:0]  awid_debug_axim;
wire [31:0]  awaddr_debug_axim;
wire [7:0]   awlen_debug_axim;
wire [2:0]   awsize_debug_axim;
wire [1:0]   awburst_debug_axim;
wire         awlock_debug_axim;
wire [3:0]   awcache_debug_axim;
wire [2:0]   awprot_debug_axim;
wire         awvalid_debug_axim;
wire         awready_debug_axim;
wire [31:0]  wdata_debug_axim;
wire [3:0]   wstrb_debug_axim;
wire         wlast_debug_axim;
wire         wvalid_debug_axim;
wire         wready_debug_axim;
wire [8:0]  bid_debug_axim;
wire [1:0]   bresp_debug_axim;
wire         bvalid_debug_axim;
wire         bready_debug_axim;
wire [8:0]  arid_debug_axim;
wire [31:0]  araddr_debug_axim;
wire [7:0]   arlen_debug_axim;
wire [2:0]   arsize_debug_axim;
wire [1:0]   arburst_debug_axim;
wire         arlock_debug_axim;
wire [3:0]   arcache_debug_axim;
wire [2:0]   arprot_debug_axim;
wire         arvalid_debug_axim;
wire         arready_debug_axim;
wire [8:0]  rid_debug_axim;
wire [31:0]  rdata_debug_axim;
wire [1:0]   rresp_debug_axim;
wire         rlast_debug_axim;
wire         rvalid_debug_axim;
wire         rready_debug_axim;
wire         buser_debug_axim;
wire         ruser_debug_axim;



wire  [GLOBAL_ID_WIDTH-1:0] fc_awid_sysctrl_axim;
wire  [31:0] fc_awaddr_sysctrl_axim;
wire  [7:0]  fc_awlen_sysctrl_axim;
wire  [2:0]  fc_awsize_sysctrl_axim;
wire  [1:0]  fc_awburst_sysctrl_axim;
wire         fc_awlock_sysctrl_axim;
wire  [3:0]  fc_awcache_sysctrl_axim;
wire  [2:0]  fc_awprot_sysctrl_axim;
wire         fc_awvalid_sysctrl_axim;
wire         fc_awready_sysctrl_axim;
wire  [31:0] fc_wdata_sysctrl_axim;
wire  [3:0]  fc_wstrb_sysctrl_axim;
wire         fc_wlast_sysctrl_axim;
wire         fc_wvalid_sysctrl_axim;
wire         fc_wready_sysctrl_axim;
wire  [GLOBAL_ID_WIDTH-1:0] fc_bid_sysctrl_axim;
wire  [1:0]  fc_bresp_sysctrl_axim;
wire         fc_bvalid_sysctrl_axim;
wire         fc_bready_sysctrl_axim;
wire  [GLOBAL_ID_WIDTH-1:0] fc_arid_sysctrl_axim;
wire  [31:0] fc_araddr_sysctrl_axim;
wire  [7:0]  fc_arlen_sysctrl_axim;
wire  [2:0]  fc_arsize_sysctrl_axim;
wire  [1:0]  fc_arburst_sysctrl_axim;
wire         fc_arlock_sysctrl_axim;
wire  [3:0]  fc_arcache_sysctrl_axim;
wire  [2:0]  fc_arprot_sysctrl_axim;
wire         fc_arvalid_sysctrl_axim;
wire         fc_arready_sysctrl_axim;
wire  [GLOBAL_ID_WIDTH-1:0] fc_rid_sysctrl_axim;
wire  [31:0] fc_rdata_sysctrl_axim;
wire  [1:0]  fc_rresp_sysctrl_axim;
wire         fc_rlast_sysctrl_axim;
wire         fc_rvalid_sysctrl_axim;
wire         fc_rready_sysctrl_axim;
wire  [9:0]  fc_awuser_sysctrl_axim;
wire  [9:0]  fc_aruser_sysctrl_axim;
wire         fc_buser_sysctrl_axim;
wire         fc_ruser_sysctrl_axim;

wire [31:0] haddr_gpvmain_ahb;
wire [2:0]  hburst_gpvmain_ahb;
wire [3:0]  hprot_gpvmain_ahb;
wire [2:0]  hsize_gpvmain_ahb;
wire [1:0]  htrans_gpvmain_ahb;
wire [31:0] hwdata_gpvmain_ahb;
wire        hwrite_gpvmain_ahb;
wire [31:0] hrdata_gpvmain_ahb;
wire        hreadyout_gpvmain_ahb;
wire        hresp_gpvmain_ahb;
wire        hselx_gpvmain_ahb;
wire        hready_gpvmain_ahb;


wire        tvalid_dti_dn_s0;
wire        tready_dti_dn_s0;
wire [31:0] tdata_dti_dn_s0;
wire  [3:0] tkeep_dti_dn_s0;
wire        tlast_dti_dn_s0;
wire        tvalid_dti_dn_s1;
wire        tready_dti_dn_s1;
wire [31:0] tdata_dti_dn_s1;
wire  [3:0] tkeep_dti_dn_s1;
wire        tlast_dti_dn_s1;
wire        tvalid_dti_dn_s2;
wire        tready_dti_dn_s2;
wire [31:0] tdata_dti_dn_s2;
wire  [3:0] tkeep_dti_dn_s2;
wire        tlast_dti_dn_s2;
wire        tvalid_dti_dn_s3;
wire        tready_dti_dn_s3;
wire [31:0] tdata_dti_dn_s3;
wire  [3:0] tkeep_dti_dn_s3;
wire        tlast_dti_dn_s3;
wire        tvalid_dti_dn_s4;
wire        tready_dti_dn_s4;
wire [31:0] tdata_dti_dn_s4;
wire  [3:0] tkeep_dti_dn_s4;
wire        tlast_dti_dn_s4;
wire        tvalid_dti_dn_s5;
wire        tready_dti_dn_s5;
wire [31:0] tdata_dti_dn_s5;
wire  [3:0] tkeep_dti_dn_s5;
wire        tlast_dti_dn_s5;
wire        tvalid_dti_dn_s6;
wire        tready_dti_dn_s6;
wire [31:0] tdata_dti_dn_s6;
wire  [3:0] tkeep_dti_dn_s6;
wire        tlast_dti_dn_s6;
wire        tvalid_dti_dn_s7;
wire        tready_dti_dn_s7;
wire [31:0] tdata_dti_dn_s7;
wire  [3:0] tkeep_dti_dn_s7;
wire        tlast_dti_dn_s7;
wire        tvalid_dti_dn_s8;
wire        tready_dti_dn_s8;
wire [31:0] tdata_dti_dn_s8;
wire  [3:0] tkeep_dti_dn_s8;
wire        tlast_dti_dn_s8;
wire        tvalid_dti_dn_s9;
wire        tready_dti_dn_s9;
wire [31:0] tdata_dti_dn_s9;
wire  [3:0] tkeep_dti_dn_s9;
wire        tlast_dti_dn_s9;
wire        tvalid_dti_dn_s10;
wire        tready_dti_dn_s10;
wire [31:0] tdata_dti_dn_s10;
wire  [3:0] tkeep_dti_dn_s10;
wire        tlast_dti_dn_s10;
wire        tvalid_dti_dn_s11;
wire        tready_dti_dn_s11;
wire [31:0] tdata_dti_dn_s11;
wire  [3:0] tkeep_dti_dn_s11;
wire        tlast_dti_dn_s11;
wire        tvalid_dti_dn_s12;
wire        tready_dti_dn_s12;
wire [31:0] tdata_dti_dn_s12;
wire  [3:0] tkeep_dti_dn_s12;
wire        tlast_dti_dn_s12;
wire        tvalid_dti_dn_s13;
wire        tready_dti_dn_s13;
wire [31:0] tdata_dti_dn_s13;
wire  [3:0] tkeep_dti_dn_s13;
wire        tlast_dti_dn_s13;



wire        tvalid_dti_up_s0;
wire        tready_dti_up_s0;
wire [31:0] tdata_dti_up_s0;
wire  [3:0] tkeep_dti_up_s0;
wire        tlast_dti_up_s0;
wire        tvalid_dti_up_s1;
wire        tready_dti_up_s1;
wire [31:0] tdata_dti_up_s1;
wire  [3:0] tkeep_dti_up_s1;
wire        tlast_dti_up_s1;
wire        tvalid_dti_up_s2;
wire        tready_dti_up_s2;
wire [31:0] tdata_dti_up_s2;
wire  [3:0] tkeep_dti_up_s2;
wire        tlast_dti_up_s2;
wire        tvalid_dti_up_s3;
wire        tready_dti_up_s3;
wire [31:0] tdata_dti_up_s3;
wire  [3:0] tkeep_dti_up_s3;
wire        tlast_dti_up_s3;
wire        tvalid_dti_up_s4;
wire        tready_dti_up_s4;
wire [31:0] tdata_dti_up_s4;
wire  [3:0] tkeep_dti_up_s4;
wire        tlast_dti_up_s4;
wire        tvalid_dti_up_s5;
wire        tready_dti_up_s5;
wire [31:0] tdata_dti_up_s5;
wire  [3:0] tkeep_dti_up_s5;
wire        tlast_dti_up_s5;
wire        tvalid_dti_up_s6;
wire        tready_dti_up_s6;
wire [31:0] tdata_dti_up_s6;
wire  [3:0] tkeep_dti_up_s6;
wire        tlast_dti_up_s6;
wire        tvalid_dti_up_s7;
wire        tready_dti_up_s7;
wire [31:0] tdata_dti_up_s7;
wire  [3:0] tkeep_dti_up_s7;
wire        tlast_dti_up_s7;
wire        tvalid_dti_up_s8;
wire        tready_dti_up_s8;
wire [31:0] tdata_dti_up_s8;
wire  [3:0] tkeep_dti_up_s8;
wire        tlast_dti_up_s8;
wire        tvalid_dti_up_s9;
wire        tready_dti_up_s9;
wire [31:0] tdata_dti_up_s9;
wire  [3:0] tkeep_dti_up_s9;
wire        tlast_dti_up_s9;
wire        tvalid_dti_up_s10;
wire        tready_dti_up_s10;
wire [31:0] tdata_dti_up_s10;
wire  [3:0] tkeep_dti_up_s10;
wire        tlast_dti_up_s10;
wire        tvalid_dti_up_s11;
wire        tready_dti_up_s11;
wire [31:0] tdata_dti_up_s11;
wire  [3:0] tkeep_dti_up_s11;
wire        tlast_dti_up_s11;
wire        tvalid_dti_up_s12;
wire        tready_dti_up_s12;
wire [31:0] tdata_dti_up_s12;
wire  [3:0] tkeep_dti_up_s12;
wire        tlast_dti_up_s12;
wire        tvalid_dti_up_s13;
wire        tready_dti_up_s13;
wire [31:0] tdata_dti_up_s13;
wire  [3:0] tkeep_dti_up_s13;
wire        tlast_dti_up_s13;


wire twakeup_dti_dn_s0;  
wire twakeup_dti_dn_s1;  
wire twakeup_dti_dn_s2;  
wire twakeup_dti_dn_s3;  
wire twakeup_dti_dn_s4;  
wire twakeup_dti_dn_s5;  
wire twakeup_dti_dn_s6;  
wire twakeup_dti_dn_s7;  
wire twakeup_dti_dn_s8;  
wire twakeup_dti_dn_s9;  
wire twakeup_dti_dn_s10;  
wire twakeup_dti_dn_s11;  
wire twakeup_dti_dn_s12;  
wire twakeup_dti_dn_s13;  
 


wire twakeup_dti_up_s0;   
wire twakeup_dti_up_s1;   
wire twakeup_dti_up_s2;   
wire twakeup_dti_up_s3;   
wire twakeup_dti_up_s4;   
wire twakeup_dti_up_s5;   
wire twakeup_dti_up_s6;   
wire twakeup_dti_up_s7;   
wire twakeup_dti_up_s8;   
wire twakeup_dti_up_s9;   
wire twakeup_dti_up_s10;   
wire twakeup_dti_up_s11;   
wire twakeup_dti_up_s12;   
wire twakeup_dti_up_s13;   
 
wire [19-1:0] qch_exp_aclk_devqdeny;
wire [19-1:0] qch_exp_aclk_devqactive;
wire [19-1:0] qch_exp_aclk_devqreqn;
wire [19-1:0] qch_exp_aclk_devqacceptn;

nic400_sse710_main u_nic400_main (

  .cactive_cd_main           (cactive_cd_maingpv),
  .haddr_gpvmain_ahb         (haddr_gpvmain_ahb),     
  .hburst_gpvmain_ahb        (hburst_gpvmain_ahb),    
  .hprot_gpvmain_ahb         (hprot_gpvmain_ahb),     
  .hsize_gpvmain_ahb         (hsize_gpvmain_ahb),     
  .htrans_gpvmain_ahb        (htrans_gpvmain_ahb),    
  .hwdata_gpvmain_ahb        (hwdata_gpvmain_ahb),    
  .hwrite_gpvmain_ahb        (hwrite_gpvmain_ahb),    
  .hrdata_gpvmain_ahb        (hrdata_gpvmain_ahb),    
  .hreadyout_gpvmain_ahb     (hreadyout_gpvmain_ahb), 
  .hresp_gpvmain_ahb         (hresp_gpvmain_ahb),     
  .hselx_gpvmain_ahb         (hselx_gpvmain_ahb),     
  .hready_gpvmain_ahb        (hready_gpvmain_ahb),    


  .awid_xnvm_axim             (fc_awid_xnvm_axim   ),
  .awaddr_xnvm_axim           (fc_awaddr_xnvm_axim ),
  .awlen_xnvm_axim            (fc_awlen_xnvm_axim  ),
  .awsize_xnvm_axim           (fc_awsize_xnvm_axim ),
  .awburst_xnvm_axim          (fc_awburst_xnvm_axim),
  .awlock_xnvm_axim           (fc_awlock_xnvm_axim ),
  .awcache_xnvm_axim          (fc_awcache_xnvm_axim),
  .awprot_xnvm_axim           (fc_awprot_xnvm_axim ),
  .awvalid_xnvm_axim          (fc_awvalid_xnvm_axim),
  .awready_xnvm_axim          (fc_awready_xnvm_axim),
  .wdata_xnvm_axim            (fc_wdata_xnvm_axim  ),
  .wstrb_xnvm_axim            (fc_wstrb_xnvm_axim  ),
  .wlast_xnvm_axim            (fc_wlast_xnvm_axim  ),
  .wvalid_xnvm_axim           (fc_wvalid_xnvm_axim ),
  .wready_xnvm_axim           (fc_wready_xnvm_axim ),
  .bid_xnvm_axim              (fc_bid_xnvm_axim    ),
  .bresp_xnvm_axim            (fc_bresp_xnvm_axim  ),
  .bvalid_xnvm_axim           (fc_bvalid_xnvm_axim ),
  .bready_xnvm_axim           (fc_bready_xnvm_axim ),
  .arid_xnvm_axim             (fc_arid_xnvm_axim   ),
  .araddr_xnvm_axim           (fc_araddr_xnvm_axim ),
  .arlen_xnvm_axim            (fc_arlen_xnvm_axim  ),
  .arsize_xnvm_axim           (fc_arsize_xnvm_axim ),
  .arburst_xnvm_axim          (fc_arburst_xnvm_axim),
  .arlock_xnvm_axim           (fc_arlock_xnvm_axim ),
  .arcache_xnvm_axim          (fc_arcache_xnvm_axim),
  .arprot_xnvm_axim           (fc_arprot_xnvm_axim ),
  .arvalid_xnvm_axim          (fc_arvalid_xnvm_axim),
  .arready_xnvm_axim          (fc_arready_xnvm_axim),
  .rid_xnvm_axim              (fc_rid_xnvm_axim    ),
  .rdata_xnvm_axim            (fc_rdata_xnvm_axim  ),
  .rresp_xnvm_axim            (fc_rresp_xnvm_axim  ),
  .rlast_xnvm_axim            (fc_rlast_xnvm_axim  ),
  .rvalid_xnvm_axim           (fc_rvalid_xnvm_axim ),
  .rready_xnvm_axim           (fc_rready_xnvm_axim ),
  .awuser_xnvm_axim           (fc_awuser_xnvm_axim ),
  .aruser_xnvm_axim           (fc_aruser_xnvm_axim ),
  .ruser_xnvm_axim            (fc_ruser_xnvm_axim  ),
  .buser_xnvm_axim            (fc_buser_xnvm_axim  ),
  .awqos_xnvm_axim            (fc_awqos_xnvm_axim  ),
  .arqos_xnvm_axim            (fc_arqos_xnvm_axim  ),
  

  .awid_cvm_axim              (fc_awid_cvm_axim   ),
  .awaddr_cvm_axim            (fc_awaddr_cvm_axim ),
  .awlen_cvm_axim             (fc_awlen_cvm_axim  ),
  .awsize_cvm_axim            (fc_awsize_cvm_axim ),
  .awburst_cvm_axim           (fc_awburst_cvm_axim),
  .awlock_cvm_axim            (fc_awlock_cvm_axim ),
  .awcache_cvm_axim           (fc_awcache_cvm_axim),
  .awprot_cvm_axim            (fc_awprot_cvm_axim ),
  .awvalid_cvm_axim           (fc_awvalid_cvm_axim),
  .awready_cvm_axim           (fc_awready_cvm_axim),
  .wdata_cvm_axim             (fc_wdata_cvm_axim  ),
  .wstrb_cvm_axim             (fc_wstrb_cvm_axim  ),
  .wlast_cvm_axim             (fc_wlast_cvm_axim  ),
  .wvalid_cvm_axim            (fc_wvalid_cvm_axim ),
  .wready_cvm_axim            (fc_wready_cvm_axim ),
  .bid_cvm_axim               (fc_bid_cvm_axim    ),
  .bresp_cvm_axim             (fc_bresp_cvm_axim  ),
  .bvalid_cvm_axim            (fc_bvalid_cvm_axim ),
  .bready_cvm_axim            (fc_bready_cvm_axim ),
  .arid_cvm_axim              (fc_arid_cvm_axim   ),
  .araddr_cvm_axim            (fc_araddr_cvm_axim ),
  .arlen_cvm_axim             (fc_arlen_cvm_axim  ),
  .arsize_cvm_axim            (fc_arsize_cvm_axim ),
  .arburst_cvm_axim           (fc_arburst_cvm_axim),
  .arlock_cvm_axim            (fc_arlock_cvm_axim ),
  .arcache_cvm_axim           (fc_arcache_cvm_axim),
  .arprot_cvm_axim            (fc_arprot_cvm_axim ),
  .arvalid_cvm_axim           (fc_arvalid_cvm_axim),
  .arready_cvm_axim           (fc_arready_cvm_axim),
  .rid_cvm_axim               (fc_rid_cvm_axim    ),
  .rdata_cvm_axim             (fc_rdata_cvm_axim  ),
  .rresp_cvm_axim             (fc_rresp_cvm_axim  ),
  .rlast_cvm_axim             (fc_rlast_cvm_axim  ),
  .rvalid_cvm_axim            (fc_rvalid_cvm_axim ),
  .rready_cvm_axim            (fc_rready_cvm_axim ),
  .awuser_cvm_axim            (fc_awuser_cvm_axim ),
  .aruser_cvm_axim            (fc_aruser_cvm_axim ),
  .ruser_cvm_axim             (fc_ruser_cvm_axim  ),
  .buser_cvm_axim             (fc_buser_cvm_axim  ),
  .awqos_cvm_axim             (fc_awqos_cvm_axim  ),
  .arqos_cvm_axim             (fc_arqos_cvm_axim  ),


  .awid_expmstr0_axim         (fc_awid_expmstr0_axim   ),
  .awaddr_expmstr0_axim       (fc_awaddr_expmstr0_axim ),
  .awlen_expmstr0_axim        (fc_awlen_expmstr0_axim  ),
  .awsize_expmstr0_axim       (fc_awsize_expmstr0_axim ),
  .awburst_expmstr0_axim      (fc_awburst_expmstr0_axim),
  .awlock_expmstr0_axim       (fc_awlock_expmstr0_axim ),
  .awcache_expmstr0_axim      (fc_awcache_expmstr0_axim),
  .awprot_expmstr0_axim       (fc_awprot_expmstr0_axim ),
  .awvalid_expmstr0_axim      (fc_awvalid_expmstr0_axim),
  .awready_expmstr0_axim      (fc_awready_expmstr0_axim),
  .wdata_expmstr0_axim        (fc_wdata_expmstr0_axim  ),
  .wstrb_expmstr0_axim        (fc_wstrb_expmstr0_axim  ),
  .wlast_expmstr0_axim        (fc_wlast_expmstr0_axim  ),
  .wvalid_expmstr0_axim       (fc_wvalid_expmstr0_axim ),
  .wready_expmstr0_axim       (fc_wready_expmstr0_axim ),
  .bid_expmstr0_axim          (fc_bid_expmstr0_axim    ),
  .bresp_expmstr0_axim        (fc_bresp_expmstr0_axim  ),
  .bvalid_expmstr0_axim       (fc_bvalid_expmstr0_axim ),
  .bready_expmstr0_axim       (fc_bready_expmstr0_axim ),
  .arid_expmstr0_axim         (fc_arid_expmstr0_axim   ),
  .araddr_expmstr0_axim       (fc_araddr_expmstr0_axim ),
  .arlen_expmstr0_axim        (fc_arlen_expmstr0_axim  ),
  .arsize_expmstr0_axim       (fc_arsize_expmstr0_axim ),
  .arburst_expmstr0_axim      (fc_arburst_expmstr0_axim),
  .arlock_expmstr0_axim       (fc_arlock_expmstr0_axim ),
  .arcache_expmstr0_axim      (fc_arcache_expmstr0_axim),
  .arprot_expmstr0_axim       (fc_arprot_expmstr0_axim ),
  .arvalid_expmstr0_axim      (fc_arvalid_expmstr0_axim),
  .arready_expmstr0_axim      (fc_arready_expmstr0_axim),
  .rid_expmstr0_axim          (fc_rid_expmstr0_axim    ),
  .rdata_expmstr0_axim        (fc_rdata_expmstr0_axim  ),
  .rresp_expmstr0_axim        (fc_rresp_expmstr0_axim  ),
  .rlast_expmstr0_axim        (fc_rlast_expmstr0_axim  ),
  .rvalid_expmstr0_axim       (fc_rvalid_expmstr0_axim ),
  .rready_expmstr0_axim       (fc_rready_expmstr0_axim ),
  .awuser_expmstr0_axim       (fc_awuser_expmstr0_axim ),
  .aruser_expmstr0_axim       (fc_aruser_expmstr0_axim ),
  .ruser_expmstr0_axim        (fc_ruser_expmstr0_axim  ),
  .buser_expmstr0_axim        (fc_buser_expmstr0_axim  ),
  .awqos_expmstr0_axim        (fc_awqos_expmstr0_axim  ),
  .arqos_expmstr0_axim        (fc_arqos_expmstr0_axim  ),

  .awid_expmstr1_axim         (fc_awid_expmstr1_axim   ),
  .awaddr_expmstr1_axim       (fc_awaddr_expmstr1_axim ),
  .awlen_expmstr1_axim        (fc_awlen_expmstr1_axim  ),
  .awsize_expmstr1_axim       (fc_awsize_expmstr1_axim ),
  .awburst_expmstr1_axim      (fc_awburst_expmstr1_axim),
  .awlock_expmstr1_axim       (fc_awlock_expmstr1_axim ),
  .awcache_expmstr1_axim      (fc_awcache_expmstr1_axim),
  .awprot_expmstr1_axim       (fc_awprot_expmstr1_axim ),
  .awvalid_expmstr1_axim      (fc_awvalid_expmstr1_axim),
  .awready_expmstr1_axim      (fc_awready_expmstr1_axim),
  .wdata_expmstr1_axim        (fc_wdata_expmstr1_axim  ),
  .wstrb_expmstr1_axim        (fc_wstrb_expmstr1_axim  ),
  .wlast_expmstr1_axim        (fc_wlast_expmstr1_axim  ),
  .wvalid_expmstr1_axim       (fc_wvalid_expmstr1_axim ),
  .wready_expmstr1_axim       (fc_wready_expmstr1_axim ),
  .bid_expmstr1_axim          (fc_bid_expmstr1_axim    ),
  .bresp_expmstr1_axim        (fc_bresp_expmstr1_axim  ),
  .bvalid_expmstr1_axim       (fc_bvalid_expmstr1_axim ),
  .bready_expmstr1_axim       (fc_bready_expmstr1_axim ),
  .arid_expmstr1_axim         (fc_arid_expmstr1_axim   ),
  .araddr_expmstr1_axim       (fc_araddr_expmstr1_axim ),
  .arlen_expmstr1_axim        (fc_arlen_expmstr1_axim  ),
  .arsize_expmstr1_axim       (fc_arsize_expmstr1_axim ),
  .arburst_expmstr1_axim      (fc_arburst_expmstr1_axim),
  .arlock_expmstr1_axim       (fc_arlock_expmstr1_axim ),
  .arcache_expmstr1_axim      (fc_arcache_expmstr1_axim),
  .arprot_expmstr1_axim       (fc_arprot_expmstr1_axim ),
  .arvalid_expmstr1_axim      (fc_arvalid_expmstr1_axim),
  .arready_expmstr1_axim      (fc_arready_expmstr1_axim),
  .rid_expmstr1_axim          (fc_rid_expmstr1_axim    ),
  .rdata_expmstr1_axim        (fc_rdata_expmstr1_axim  ),
  .rresp_expmstr1_axim        (fc_rresp_expmstr1_axim  ),
  .rlast_expmstr1_axim        (fc_rlast_expmstr1_axim  ),
  .rvalid_expmstr1_axim       (fc_rvalid_expmstr1_axim ),
  .rready_expmstr1_axim       (fc_rready_expmstr1_axim ),
  .awuser_expmstr1_axim       (fc_awuser_expmstr1_axim ),
  .aruser_expmstr1_axim       (fc_aruser_expmstr1_axim ),
  .ruser_expmstr1_axim        (fc_ruser_expmstr1_axim  ),
  .buser_expmstr1_axim        (fc_buser_expmstr1_axim  ),
  .awqos_expmstr1_axim        (fc_awqos_expmstr1_axim  ),
  .arqos_expmstr1_axim        (fc_arqos_expmstr1_axim  ),
                          

  
  .awid_firewall_axim         (awid_firewall_axim   ),
  .awaddr_firewall_axim       (awaddr_firewall_axim ),
  .awlen_firewall_axim        (awlen_firewall_axim  ),
  .awsize_firewall_axim       (awsize_firewall_axim ),
  .awburst_firewall_axim      (awburst_firewall_axim),
  .awlock_firewall_axim       (awlock_firewall_axim ),
  .awcache_firewall_axim      (awcache_firewall_axim),
  .awprot_firewall_axim       (awprot_firewall_axim ),
  .awvalid_firewall_axim      (awvalid_firewall_axim),
  .awready_firewall_axim      (awready_firewall_axim),
  .wdata_firewall_axim        (wdata_firewall_axim  ),
  .wstrb_firewall_axim        (wstrb_firewall_axim  ),
  .wlast_firewall_axim        (wlast_firewall_axim  ),
  .wvalid_firewall_axim       (wvalid_firewall_axim ),
  .wready_firewall_axim       (wready_firewall_axim ),
  .bid_firewall_axim          (bid_firewall_axim    ),
  .bresp_firewall_axim        (bresp_firewall_axim  ),
  .bvalid_firewall_axim       (bvalid_firewall_axim ),
  .bready_firewall_axim       (bready_firewall_axim ),
  .arid_firewall_axim         (arid_firewall_axim   ),
  .araddr_firewall_axim       (araddr_firewall_axim ),
  .arlen_firewall_axim        (arlen_firewall_axim  ),
  .arsize_firewall_axim       (arsize_firewall_axim ),
  .arburst_firewall_axim      (arburst_firewall_axim),
  .arlock_firewall_axim       (arlock_firewall_axim ),
  .arcache_firewall_axim      (arcache_firewall_axim),
  .arprot_firewall_axim       (arprot_firewall_axim ),
  .arvalid_firewall_axim      (arvalid_firewall_axim),
  .arready_firewall_axim      (arready_firewall_axim),
  .rid_firewall_axim          (rid_firewall_axim    ),
  .rdata_firewall_axim        (rdata_firewall_axim  ),
  .rresp_firewall_axim        (rresp_firewall_axim  ),
  .rlast_firewall_axim        (rlast_firewall_axim  ),
  .rvalid_firewall_axim       (rvalid_firewall_axim ),
  .rready_firewall_axim       (rready_firewall_axim ),
  .awuser_firewall_axim       (awuser_firewall_axim ),
  .aruser_firewall_axim       (aruser_firewall_axim ),
  .ruser_firewall_axim        (ruser_firewall_axim  ),
  .buser_firewall_axim        (buser_firewall_axim  ),
  
  
  .awid_ocvm_axim             (fc_awid_ocvm_axim   ),
  .awaddr_ocvm_axim           (fc_awaddr_ocvm_axim ),
  .awlen_ocvm_axim            (fc_awlen_ocvm_axim  ),
  .awsize_ocvm_axim           (fc_awsize_ocvm_axim ),
  .awburst_ocvm_axim          (fc_awburst_ocvm_axim),
  .awlock_ocvm_axim           (fc_awlock_ocvm_axim ),
  .awcache_ocvm_axim          (fc_awcache_ocvm_axim),
  .awprot_ocvm_axim           (fc_awprot_ocvm_axim ),
  .awvalid_ocvm_axim          (fc_awvalid_ocvm_axim),
  .awready_ocvm_axim          (fc_awready_ocvm_axim),
  .wdata_ocvm_axim            (fc_wdata_ocvm_axim  ),
  .wstrb_ocvm_axim            (fc_wstrb_ocvm_axim  ),
  .wlast_ocvm_axim            (fc_wlast_ocvm_axim  ),
  .wvalid_ocvm_axim           (fc_wvalid_ocvm_axim ),
  .wready_ocvm_axim           (fc_wready_ocvm_axim ),
  .bid_ocvm_axim              (fc_bid_ocvm_axim    ),
  .bresp_ocvm_axim            (fc_bresp_ocvm_axim  ),
  .bvalid_ocvm_axim           (fc_bvalid_ocvm_axim ),
  .bready_ocvm_axim           (fc_bready_ocvm_axim ),
  .arid_ocvm_axim             (fc_arid_ocvm_axim   ),
  .araddr_ocvm_axim           (fc_araddr_ocvm_axim ),
  .arlen_ocvm_axim            (fc_arlen_ocvm_axim  ),
  .arsize_ocvm_axim           (fc_arsize_ocvm_axim ),
  .arburst_ocvm_axim          (fc_arburst_ocvm_axim),
  .arlock_ocvm_axim           (fc_arlock_ocvm_axim ),
  .arcache_ocvm_axim          (fc_arcache_ocvm_axim),
  .arprot_ocvm_axim           (fc_arprot_ocvm_axim ),
  .arvalid_ocvm_axim          (fc_arvalid_ocvm_axim),
  .arready_ocvm_axim          (fc_arready_ocvm_axim),
  .rid_ocvm_axim              (fc_rid_ocvm_axim    ),
  .rdata_ocvm_axim            (fc_rdata_ocvm_axim  ),
  .rresp_ocvm_axim            (fc_rresp_ocvm_axim  ),
  .rlast_ocvm_axim            (fc_rlast_ocvm_axim  ),
  .rvalid_ocvm_axim           (fc_rvalid_ocvm_axim ),
  .rready_ocvm_axim           (fc_rready_ocvm_axim ),
  .awuser_ocvm_axim           (fc_awuser_ocvm_axim ),
  .aruser_ocvm_axim           (fc_aruser_ocvm_axim ),
  .ruser_ocvm_axim            (fc_ruser_ocvm_axim  ),
  .buser_ocvm_axim            (fc_buser_ocvm_axim  ),
  .awqos_ocvm_axim            (fc_awqos_ocvm_axim  ),
  .arqos_ocvm_axim            (fc_arqos_ocvm_axim  ),
  

  .awid_bootreg_axim          (awid_bootreg_axim   ),
  .awaddr_bootreg_axim        (awaddr_bootreg_axim ),
  .awlen_bootreg_axim         (awlen_bootreg_axim  ),
  .awsize_bootreg_axim        (awsize_bootreg_axim ),
  .awburst_bootreg_axim       (awburst_bootreg_axim),
  .awlock_bootreg_axim        (awlock_bootreg_axim ),
  .awcache_bootreg_axim       (awcache_bootreg_axim),
  .awprot_bootreg_axim        (awprot_bootreg_axim ),
  .awvalid_bootreg_axim       (awvalid_bootreg_axim),
  .awready_bootreg_axim       (awready_bootreg_axim),
  .wdata_bootreg_axim         (wdata_bootreg_axim  ),
  .wstrb_bootreg_axim         (wstrb_bootreg_axim  ),
  .wlast_bootreg_axim         (wlast_bootreg_axim  ),
  .wvalid_bootreg_axim        (wvalid_bootreg_axim ),
  .wready_bootreg_axim        (wready_bootreg_axim ),
  .bid_bootreg_axim           (bid_bootreg_axim    ),
  .bresp_bootreg_axim         (bresp_bootreg_axim  ),
  .bvalid_bootreg_axim        (bvalid_bootreg_axim ),
  .bready_bootreg_axim        (bready_bootreg_axim ),
  .arid_bootreg_axim          (arid_bootreg_axim   ),
  .araddr_bootreg_axim        (araddr_bootreg_axim ),
  .arlen_bootreg_axim         (arlen_bootreg_axim  ),
  .arsize_bootreg_axim        (arsize_bootreg_axim ),
  .arburst_bootreg_axim       (arburst_bootreg_axim),
  .arlock_bootreg_axim        (arlock_bootreg_axim ),
  .arcache_bootreg_axim       (arcache_bootreg_axim),
  .arprot_bootreg_axim        (arprot_bootreg_axim ),
  .arvalid_bootreg_axim       (arvalid_bootreg_axim),
  .arready_bootreg_axim       (arready_bootreg_axim),
  .rid_bootreg_axim           (rid_bootreg_axim    ),
  .rdata_bootreg_axim         (rdata_bootreg_axim  ),
  .rresp_bootreg_axim         (rresp_bootreg_axim  ),
  .rlast_bootreg_axim         (rlast_bootreg_axim  ),
  .rvalid_bootreg_axim        (rvalid_bootreg_axim ),
  .rready_bootreg_axim        (rready_bootreg_axim ),
  .awuser_bootreg_axim        (awuser_bootreg_axim ),
  .aruser_bootreg_axim        (aruser_bootreg_axim ),
  

  .awid_sysctrl_axim          (fc_awid_sysctrl_axim   ),
  .awaddr_sysctrl_axim        (fc_awaddr_sysctrl_axim ),
  .awlen_sysctrl_axim         (fc_awlen_sysctrl_axim  ),
  .awsize_sysctrl_axim        (fc_awsize_sysctrl_axim ),
  .awburst_sysctrl_axim       (fc_awburst_sysctrl_axim),
  .awlock_sysctrl_axim        (fc_awlock_sysctrl_axim ),
  .awcache_sysctrl_axim       (fc_awcache_sysctrl_axim),
  .awprot_sysctrl_axim        (fc_awprot_sysctrl_axim ),
  .awvalid_sysctrl_axim       (fc_awvalid_sysctrl_axim),
  .awready_sysctrl_axim       (fc_awready_sysctrl_axim),
  .wdata_sysctrl_axim         (fc_wdata_sysctrl_axim  ),
  .wstrb_sysctrl_axim         (fc_wstrb_sysctrl_axim  ),
  .wlast_sysctrl_axim         (fc_wlast_sysctrl_axim  ),
  .wvalid_sysctrl_axim        (fc_wvalid_sysctrl_axim ),
  .wready_sysctrl_axim        (fc_wready_sysctrl_axim ),
  .bid_sysctrl_axim           (fc_bid_sysctrl_axim    ),
  .bresp_sysctrl_axim         (fc_bresp_sysctrl_axim  ),
  .bvalid_sysctrl_axim        (fc_bvalid_sysctrl_axim ),
  .bready_sysctrl_axim        (fc_bready_sysctrl_axim ),
  .arid_sysctrl_axim          (fc_arid_sysctrl_axim   ),
  .araddr_sysctrl_axim        (fc_araddr_sysctrl_axim ),
  .arlen_sysctrl_axim         (fc_arlen_sysctrl_axim  ),
  .arsize_sysctrl_axim        (fc_arsize_sysctrl_axim ),
  .arburst_sysctrl_axim       (fc_arburst_sysctrl_axim),
  .arlock_sysctrl_axim        (fc_arlock_sysctrl_axim ),
  .arcache_sysctrl_axim       (fc_arcache_sysctrl_axim),
  .arprot_sysctrl_axim        (fc_arprot_sysctrl_axim ),
  .arvalid_sysctrl_axim       (fc_arvalid_sysctrl_axim),
  .arready_sysctrl_axim       (fc_arready_sysctrl_axim),
  .rid_sysctrl_axim           (fc_rid_sysctrl_axim    ),
  .rdata_sysctrl_axim         (fc_rdata_sysctrl_axim  ),
  .rresp_sysctrl_axim         (fc_rresp_sysctrl_axim  ),
  .rlast_sysctrl_axim         (fc_rlast_sysctrl_axim  ),
  .rvalid_sysctrl_axim        (fc_rvalid_sysctrl_axim ),
  .rready_sysctrl_axim        (fc_rready_sysctrl_axim ),
  .awuser_sysctrl_axim        (fc_awuser_sysctrl_axim ),
  .aruser_sysctrl_axim        (fc_aruser_sysctrl_axim ),
  .ruser_sysctrl_axim         (fc_ruser_sysctrl_axim  ),
  .buser_sysctrl_axim         (fc_buser_sysctrl_axim  ),
  

  .awid_sysperi_axim          (fc_awid_sysperi_axim   ),
  .awaddr_sysperi_axim        (fc_awaddr_sysperi_axim ),
  .awlen_sysperi_axim         (fc_awlen_sysperi_axim  ),
  .awsize_sysperi_axim        (fc_awsize_sysperi_axim ),
  .awburst_sysperi_axim       (fc_awburst_sysperi_axim),
  .awlock_sysperi_axim        (fc_awlock_sysperi_axim ),
  .awcache_sysperi_axim       (fc_awcache_sysperi_axim),
  .awprot_sysperi_axim        (fc_awprot_sysperi_axim ),
  .awvalid_sysperi_axim       (fc_awvalid_sysperi_axim),
  .awready_sysperi_axim       (fc_awready_sysperi_axim),
  .wdata_sysperi_axim         (fc_wdata_sysperi_axim  ),
  .wstrb_sysperi_axim         (fc_wstrb_sysperi_axim  ),
  .wlast_sysperi_axim         (fc_wlast_sysperi_axim  ),
  .wvalid_sysperi_axim        (fc_wvalid_sysperi_axim ),
  .wready_sysperi_axim        (fc_wready_sysperi_axim ),
  .bid_sysperi_axim           (fc_bid_sysperi_axim    ),
  .bresp_sysperi_axim         (fc_bresp_sysperi_axim  ),
  .bvalid_sysperi_axim        (fc_bvalid_sysperi_axim ),
  .bready_sysperi_axim        (fc_bready_sysperi_axim ),
  .arid_sysperi_axim          (fc_arid_sysperi_axim   ),
  .araddr_sysperi_axim        (fc_araddr_sysperi_axim ),
  .arlen_sysperi_axim         (fc_arlen_sysperi_axim  ),
  .arsize_sysperi_axim        (fc_arsize_sysperi_axim ),
  .arburst_sysperi_axim       (fc_arburst_sysperi_axim),
  .arlock_sysperi_axim        (fc_arlock_sysperi_axim ),
  .arcache_sysperi_axim       (fc_arcache_sysperi_axim),
  .arprot_sysperi_axim        (fc_arprot_sysperi_axim ),
  .arvalid_sysperi_axim       (fc_arvalid_sysperi_axim),
  .arready_sysperi_axim       (fc_arready_sysperi_axim),
  .rid_sysperi_axim           (fc_rid_sysperi_axim    ),
  .rdata_sysperi_axim         (fc_rdata_sysperi_axim  ),
  .rresp_sysperi_axim         (fc_rresp_sysperi_axim  ),
  .rlast_sysperi_axim         (fc_rlast_sysperi_axim  ),
  .rvalid_sysperi_axim        (fc_rvalid_sysperi_axim ),
  .rready_sysperi_axim        (fc_rready_sysperi_axim ),
  .awuser_sysperi_axim        (fc_awuser_sysperi_axim ),
  .aruser_sysperi_axim        (fc_aruser_sysperi_axim ),
  .ruser_sysperi_axim         (fc_ruser_sysperi_axim  ),
  .buser_sysperi_axim         (fc_buser_sysperi_axim  ),
  

  .awid_debug_axim          (fc_awid_debug_axim   ),
  .awaddr_debug_axim        (fc_awaddr_debug_axim ),
  .awlen_debug_axim         (fc_awlen_debug_axim  ),
  .awsize_debug_axim        (fc_awsize_debug_axim ),
  .awburst_debug_axim       (fc_awburst_debug_axim),
  .awlock_debug_axim        (fc_awlock_debug_axim ),
  .awcache_debug_axim       (fc_awcache_debug_axim),
  .awprot_debug_axim        (fc_awprot_debug_axim ),
  .awvalid_debug_axim       (fc_awvalid_debug_axim),
  .awready_debug_axim       (fc_awready_debug_axim),
  .wdata_debug_axim         (fc_wdata_debug_axim  ),
  .wstrb_debug_axim         (fc_wstrb_debug_axim  ),
  .wlast_debug_axim         (fc_wlast_debug_axim  ),
  .wvalid_debug_axim        (fc_wvalid_debug_axim ),
  .wready_debug_axim        (fc_wready_debug_axim ),
  .bid_debug_axim           (fc_bid_debug_axim    ),
  .bresp_debug_axim         (fc_bresp_debug_axim  ),
  .bvalid_debug_axim        (fc_bvalid_debug_axim ),
  .bready_debug_axim        (fc_bready_debug_axim ),
  .arid_debug_axim          (fc_arid_debug_axim   ),
  .araddr_debug_axim        (fc_araddr_debug_axim ),
  .arlen_debug_axim         (fc_arlen_debug_axim  ),
  .arsize_debug_axim        (fc_arsize_debug_axim ),
  .arburst_debug_axim       (fc_arburst_debug_axim),
  .arlock_debug_axim        (fc_arlock_debug_axim ),
  .arcache_debug_axim       (fc_arcache_debug_axim),
  .arprot_debug_axim        (fc_arprot_debug_axim ),
  .arvalid_debug_axim       (fc_arvalid_debug_axim),
  .arready_debug_axim       (fc_arready_debug_axim),
  .rid_debug_axim           (fc_rid_debug_axim    ),
  .rdata_debug_axim         (fc_rdata_debug_axim  ),
  .rresp_debug_axim         (fc_rresp_debug_axim  ),
  .rlast_debug_axim         (fc_rlast_debug_axim  ),
  .rvalid_debug_axim        (fc_rvalid_debug_axim ),
  .rready_debug_axim        (fc_rready_debug_axim ),
  .awuser_debug_axim        (fc_awuser_debug_axim ),
  .aruser_debug_axim        (fc_aruser_debug_axim ),
  .ruser_debug_axim         (fc_ruser_debug_axim  ),
  .buser_debug_axim         (fc_buser_debug_axim  ),
  

  .awid_debug_axis            (awid_debug_axis   ),
  .awaddr_debug_axis          (awaddr_debug_axis ),
  .awlen_debug_axis           (awlen_debug_axis  ),
  .awsize_debug_axis          (awsize_debug_axis ),
  .awburst_debug_axis         (awburst_debug_axis),
  .awlock_debug_axis          (awlock_debug_axis ),
  .awcache_debug_axis         (awcache_debug_axis),
  .awprot_debug_axis          (awprot_debug_axis ),
  .awvalid_debug_axis         (awvalid_debug_axis),
  .awready_debug_axis         (awready_debug_axis),
  .wdata_debug_axis           (wdata_debug_axis  ),
  .wstrb_debug_axis           (wstrb_debug_axis  ),
  .wlast_debug_axis           (wlast_debug_axis  ),
  .wvalid_debug_axis          (wvalid_debug_axis ),
  .wready_debug_axis          (wready_debug_axis ),
  .bid_debug_axis             (bid_debug_axis    ),
  .bresp_debug_axis           (bresp_debug_axis  ),
  .bvalid_debug_axis          (bvalid_debug_axis ),
  .bready_debug_axis          (bready_debug_axis ),
  .arid_debug_axis            (arid_debug_axis   ),
  .araddr_debug_axis          (araddr_debug_axis ),
  .arlen_debug_axis           (arlen_debug_axis  ),
  .arsize_debug_axis          (arsize_debug_axis ),
  .arburst_debug_axis         (arburst_debug_axis),
  .arlock_debug_axis          (arlock_debug_axis ),
  .arcache_debug_axis         (arcache_debug_axis),
  .arprot_debug_axis          (arprot_debug_axis ),
  .arvalid_debug_axis         (arvalid_debug_axis),
  .arready_debug_axis         (arready_debug_axis),
  .rid_debug_axis             (rid_debug_axis    ),
  .rdata_debug_axis           (rdata_debug_axis  ),
  .rresp_debug_axis           (rresp_debug_axis  ),
  .rlast_debug_axis           (rlast_debug_axis  ),
  .rvalid_debug_axis          (rvalid_debug_axis ),
  .rready_debug_axis          (rready_debug_axis ),
  .awuser_debug_axis          (awuser_debug_axis ),
  .aruser_debug_axis          (aruser_debug_axis ),
  .ruser_debug_axis           (ruser_debug_axis  ),
  .buser_debug_axis           (buser_debug_axis  ),

 
                              
  .awid_expslv0_axis          (fc_awid_expslv0_axis    ),
  .awaddr_expslv0_axis        (fc_awaddr_expslv0_axis  ),
  .awlen_expslv0_axis         (fc_awlen_expslv0_axis   ),
  .awsize_expslv0_axis        (fc_awsize_expslv0_axis  ),
  .awburst_expslv0_axis       (fc_awburst_expslv0_axis ),
  .awlock_expslv0_axis        (fc_awlock_expslv0_axis  ),
  .awcache_expslv0_axis       (fc_awcache_expslv0_axis ),
  .awprot_expslv0_axis        (fc_awprot_expslv0_axis  ),
  .awvalid_expslv0_axis       (fc_awvalid_expslv0_axis ),
  .awready_expslv0_axis       (fc_awready_expslv0_axis ),
  .wdata_expslv0_axis         (fc_wdata_expslv0_axis   ),
  .wstrb_expslv0_axis         (fc_wstrb_expslv0_axis   ),
  .wlast_expslv0_axis         (fc_wlast_expslv0_axis   ),
  .wvalid_expslv0_axis        (fc_wvalid_expslv0_axis  ),
  .wready_expslv0_axis        (fc_wready_expslv0_axis  ),
  .bid_expslv0_axis           (fc_bid_expslv0_axis     ),
  .bresp_expslv0_axis         (fc_bresp_expslv0_axis   ),
  .bvalid_expslv0_axis        (fc_bvalid_expslv0_axis  ),
  .bready_expslv0_axis        (fc_bready_expslv0_axis  ),
  .arid_expslv0_axis          (fc_arid_expslv0_axis    ),
  .araddr_expslv0_axis        (fc_araddr_expslv0_axis  ),
  .arlen_expslv0_axis         (fc_arlen_expslv0_axis   ),
  .arsize_expslv0_axis        (fc_arsize_expslv0_axis  ),
  .arburst_expslv0_axis       (fc_arburst_expslv0_axis ),
  .arlock_expslv0_axis        (fc_arlock_expslv0_axis  ),
  .arcache_expslv0_axis       (fc_arcache_expslv0_axis ),
  .arprot_expslv0_axis        (fc_arprot_expslv0_axis  ),
  .arvalid_expslv0_axis       (fc_arvalid_expslv0_axis ),
  .arready_expslv0_axis       (fc_arready_expslv0_axis ),
  .rid_expslv0_axis           (fc_rid_expslv0_axis     ),
  .rdata_expslv0_axis         (fc_rdata_expslv0_axis   ),
  .rresp_expslv0_axis         (fc_rresp_expslv0_axis   ),
  .rlast_expslv0_axis         (fc_rlast_expslv0_axis   ),
  .rvalid_expslv0_axis        (fc_rvalid_expslv0_axis  ),
  .rready_expslv0_axis        (fc_rready_expslv0_axis  ),
  .awuser_expslv0_axis        (fc_awuser_expslv0_axis  ),
  .aruser_expslv0_axis        (fc_aruser_expslv0_axis  ),
  .ruser_expslv0_axis         (fc_ruser_expslv0_axis   ),
  .buser_expslv0_axis         (fc_buser_expslv0_axis   ),
  .awqos_expslv0_axis         (fc_awqos_expslv0_axis   ),
  .arqos_expslv0_axis         (fc_arqos_expslv0_axis   ),
 
                              
  .awid_expslv1_axis          (fc_awid_expslv1_axis    ),
  .awaddr_expslv1_axis        (fc_awaddr_expslv1_axis  ),
  .awlen_expslv1_axis         (fc_awlen_expslv1_axis   ),
  .awsize_expslv1_axis        (fc_awsize_expslv1_axis  ),
  .awburst_expslv1_axis       (fc_awburst_expslv1_axis ),
  .awlock_expslv1_axis        (fc_awlock_expslv1_axis  ),
  .awcache_expslv1_axis       (fc_awcache_expslv1_axis ),
  .awprot_expslv1_axis        (fc_awprot_expslv1_axis  ),
  .awvalid_expslv1_axis       (fc_awvalid_expslv1_axis ),
  .awready_expslv1_axis       (fc_awready_expslv1_axis ),
  .wdata_expslv1_axis         (fc_wdata_expslv1_axis   ),
  .wstrb_expslv1_axis         (fc_wstrb_expslv1_axis   ),
  .wlast_expslv1_axis         (fc_wlast_expslv1_axis   ),
  .wvalid_expslv1_axis        (fc_wvalid_expslv1_axis  ),
  .wready_expslv1_axis        (fc_wready_expslv1_axis  ),
  .bid_expslv1_axis           (fc_bid_expslv1_axis     ),
  .bresp_expslv1_axis         (fc_bresp_expslv1_axis   ),
  .bvalid_expslv1_axis        (fc_bvalid_expslv1_axis  ),
  .bready_expslv1_axis        (fc_bready_expslv1_axis  ),
  .arid_expslv1_axis          (fc_arid_expslv1_axis    ),
  .araddr_expslv1_axis        (fc_araddr_expslv1_axis  ),
  .arlen_expslv1_axis         (fc_arlen_expslv1_axis   ),
  .arsize_expslv1_axis        (fc_arsize_expslv1_axis  ),
  .arburst_expslv1_axis       (fc_arburst_expslv1_axis ),
  .arlock_expslv1_axis        (fc_arlock_expslv1_axis  ),
  .arcache_expslv1_axis       (fc_arcache_expslv1_axis ),
  .arprot_expslv1_axis        (fc_arprot_expslv1_axis  ),
  .arvalid_expslv1_axis       (fc_arvalid_expslv1_axis ),
  .arready_expslv1_axis       (fc_arready_expslv1_axis ),
  .rid_expslv1_axis           (fc_rid_expslv1_axis     ),
  .rdata_expslv1_axis         (fc_rdata_expslv1_axis   ),
  .rresp_expslv1_axis         (fc_rresp_expslv1_axis   ),
  .rlast_expslv1_axis         (fc_rlast_expslv1_axis   ),
  .rvalid_expslv1_axis        (fc_rvalid_expslv1_axis  ),
  .rready_expslv1_axis        (fc_rready_expslv1_axis  ),
  .awuser_expslv1_axis        (fc_awuser_expslv1_axis  ),
  .aruser_expslv1_axis        (fc_aruser_expslv1_axis  ),
  .ruser_expslv1_axis         (fc_ruser_expslv1_axis   ),
  .buser_expslv1_axis         (fc_buser_expslv1_axis   ),
  .awqos_expslv1_axis         (fc_awqos_expslv1_axis   ),
  .arqos_expslv1_axis         (fc_arqos_expslv1_axis   ),
 

  .awid_extsys0_axis          (fc_awid_extsys0_axis   ),
  .awaddr_extsys0_axis        (fc_awaddr_extsys0_axis ),
  .awlen_extsys0_axis         (fc_awlen_extsys0_axis  ),
  .awsize_extsys0_axis        (fc_awsize_extsys0_axis ),
  .awburst_extsys0_axis       (fc_awburst_extsys0_axis),
  .awlock_extsys0_axis        (fc_awlock_extsys0_axis ),
  .awcache_extsys0_axis       (fc_awcache_extsys0_axis),
  .awprot_extsys0_axis        (fc_awprot_extsys0_axis ),
  .awvalid_extsys0_axis       (fc_awvalid_extsys0_axis),
  .awready_extsys0_axis       (fc_awready_extsys0_axis),
  .wdata_extsys0_axis         (fc_wdata_extsys0_axis  ),
  .wstrb_extsys0_axis         (fc_wstrb_extsys0_axis  ),
  .wlast_extsys0_axis         (fc_wlast_extsys0_axis  ),
  .wvalid_extsys0_axis        (fc_wvalid_extsys0_axis ),
  .wready_extsys0_axis        (fc_wready_extsys0_axis ),
  .bid_extsys0_axis           (fc_bid_extsys0_axis    ),
  .bresp_extsys0_axis         (fc_bresp_extsys0_axis  ),
  .bvalid_extsys0_axis        (fc_bvalid_extsys0_axis ),
  .bready_extsys0_axis        (fc_bready_extsys0_axis ),
  .arid_extsys0_axis          (fc_arid_extsys0_axis   ),
  .araddr_extsys0_axis        (fc_araddr_extsys0_axis ),
  .arlen_extsys0_axis         (fc_arlen_extsys0_axis  ),
  .arsize_extsys0_axis        (fc_arsize_extsys0_axis ),
  .arburst_extsys0_axis       (fc_arburst_extsys0_axis),
  .arlock_extsys0_axis        (fc_arlock_extsys0_axis ),
  .arcache_extsys0_axis       (fc_arcache_extsys0_axis),
  .arprot_extsys0_axis        (fc_arprot_extsys0_axis ),
  .arvalid_extsys0_axis       (fc_arvalid_extsys0_axis),
  .arready_extsys0_axis       (fc_arready_extsys0_axis),
  .rid_extsys0_axis           (fc_rid_extsys0_axis    ),
  .rdata_extsys0_axis         (fc_rdata_extsys0_axis  ),
  .rresp_extsys0_axis         (fc_rresp_extsys0_axis  ),
  .rlast_extsys0_axis         (fc_rlast_extsys0_axis  ),
  .rvalid_extsys0_axis        (fc_rvalid_extsys0_axis ),
  .rready_extsys0_axis        (fc_rready_extsys0_axis ),
  .awuser_extsys0_axis        (fc_awuser_extsys0_axis ),
  .aruser_extsys0_axis        (fc_aruser_extsys0_axis ),
  .ruser_extsys0_axis         (fc_ruser_extsys0_axis  ),
  .buser_extsys0_axis         (fc_buser_extsys0_axis  ),


  .awid_extsys1_axis          (fc_awid_extsys1_axis   ),
  .awaddr_extsys1_axis        (fc_awaddr_extsys1_axis ),
  .awlen_extsys1_axis         (fc_awlen_extsys1_axis  ),
  .awsize_extsys1_axis        (fc_awsize_extsys1_axis ),
  .awburst_extsys1_axis       (fc_awburst_extsys1_axis),
  .awlock_extsys1_axis        (fc_awlock_extsys1_axis ),
  .awcache_extsys1_axis       (fc_awcache_extsys1_axis),
  .awprot_extsys1_axis        (fc_awprot_extsys1_axis ),
  .awvalid_extsys1_axis       (fc_awvalid_extsys1_axis),
  .awready_extsys1_axis       (fc_awready_extsys1_axis),
  .wdata_extsys1_axis         (fc_wdata_extsys1_axis  ),
  .wstrb_extsys1_axis         (fc_wstrb_extsys1_axis  ),
  .wlast_extsys1_axis         (fc_wlast_extsys1_axis  ),
  .wvalid_extsys1_axis        (fc_wvalid_extsys1_axis ),
  .wready_extsys1_axis        (fc_wready_extsys1_axis ),
  .bid_extsys1_axis           (fc_bid_extsys1_axis    ),
  .bresp_extsys1_axis         (fc_bresp_extsys1_axis  ),
  .bvalid_extsys1_axis        (fc_bvalid_extsys1_axis ),
  .bready_extsys1_axis        (fc_bready_extsys1_axis ),
  .arid_extsys1_axis          (fc_arid_extsys1_axis   ),
  .araddr_extsys1_axis        (fc_araddr_extsys1_axis ),
  .arlen_extsys1_axis         (fc_arlen_extsys1_axis  ),
  .arsize_extsys1_axis        (fc_arsize_extsys1_axis ),
  .arburst_extsys1_axis       (fc_arburst_extsys1_axis),
  .arlock_extsys1_axis        (fc_arlock_extsys1_axis ),
  .arcache_extsys1_axis       (fc_arcache_extsys1_axis),
  .arprot_extsys1_axis        (fc_arprot_extsys1_axis ),
  .arvalid_extsys1_axis       (fc_arvalid_extsys1_axis),
  .arready_extsys1_axis       (fc_arready_extsys1_axis),
  .rid_extsys1_axis           (fc_rid_extsys1_axis    ),
  .rdata_extsys1_axis         (fc_rdata_extsys1_axis  ),
  .rresp_extsys1_axis         (fc_rresp_extsys1_axis  ),
  .rlast_extsys1_axis         (fc_rlast_extsys1_axis  ),
  .rvalid_extsys1_axis        (fc_rvalid_extsys1_axis ),
  .rready_extsys1_axis        (fc_rready_extsys1_axis ),
  .awuser_extsys1_axis        (fc_awuser_extsys1_axis ),
  .aruser_extsys1_axis        (fc_aruser_extsys1_axis ),
  .ruser_extsys1_axis         (fc_ruser_extsys1_axis  ),
  .buser_extsys1_axis         (fc_buser_extsys1_axis  ),


  .awid_hostcpu_axis          (fc_awid_hostcpu_axis   ),
  .awaddr_hostcpu_axis        (fc_awaddr_hostcpu_axis ),
  .awlen_hostcpu_axis         (fc_awlen_hostcpu_axis  ),
  .awsize_hostcpu_axis        (fc_awsize_hostcpu_axis ),
  .awburst_hostcpu_axis       (fc_awburst_hostcpu_axis),
  .awlock_hostcpu_axis        (fc_awlock_hostcpu_axis ),
  .awcache_hostcpu_axis       (fc_awcache_hostcpu_axis),
  .awprot_hostcpu_axis        (fc_awprot_hostcpu_axis ),
  .awvalid_hostcpu_axis       (fc_awvalid_hostcpu_axis),
  .awready_hostcpu_axis       (fc_awready_hostcpu_axis),
  .wdata_hostcpu_axis         (fc_wdata_hostcpu_axis  ),
  .wstrb_hostcpu_axis         (fc_wstrb_hostcpu_axis  ),
  .wlast_hostcpu_axis         (fc_wlast_hostcpu_axis  ),
  .wvalid_hostcpu_axis        (fc_wvalid_hostcpu_axis ),
  .wready_hostcpu_axis        (fc_wready_hostcpu_axis ),
  .bid_hostcpu_axis           (fc_bid_hostcpu_axis    ),
  .bresp_hostcpu_axis         (fc_bresp_hostcpu_axis  ),
  .bvalid_hostcpu_axis        (fc_bvalid_hostcpu_axis ),
  .bready_hostcpu_axis        (fc_bready_hostcpu_axis ),
  .arid_hostcpu_axis          (fc_arid_hostcpu_axis   ),
  .araddr_hostcpu_axis        (fc_araddr_hostcpu_axis ),
  .arlen_hostcpu_axis         (fc_arlen_hostcpu_axis  ),
  .arsize_hostcpu_axis        (fc_arsize_hostcpu_axis ),
  .arburst_hostcpu_axis       (fc_arburst_hostcpu_axis),
  .arlock_hostcpu_axis        (fc_arlock_hostcpu_axis ),
  .arcache_hostcpu_axis       (fc_arcache_hostcpu_axis),
  .arprot_hostcpu_axis        (fc_arprot_hostcpu_axis ),
  .arvalid_hostcpu_axis       (fc_arvalid_hostcpu_axis),
  .arready_hostcpu_axis       (fc_arready_hostcpu_axis),
  .rid_hostcpu_axis           (fc_rid_hostcpu_axis    ),
  .rdata_hostcpu_axis         (fc_rdata_hostcpu_axis  ),
  .rresp_hostcpu_axis         (fc_rresp_hostcpu_axis  ),
  .rlast_hostcpu_axis         (fc_rlast_hostcpu_axis  ),
  .rvalid_hostcpu_axis        (fc_rvalid_hostcpu_axis ),
  .rready_hostcpu_axis        (fc_rready_hostcpu_axis ),
  .awuser_hostcpu_axis        (fc_awuser_hostcpu_axis ),
  .aruser_hostcpu_axis        (fc_aruser_hostcpu_axis ),
  .ruser_hostcpu_axis         (fc_ruser_hostcpu_axis  ),
  .buser_hostcpu_axis         (fc_buser_hostcpu_axis  ),
  

  .awid_secenc_axis           (awid_secenc_axis   ),
  .awaddr_secenc_axis         (awaddr_secenc_axis ),
  .awlen_secenc_axis          (awlen_secenc_axis  ),
  .awsize_secenc_axis         (awsize_secenc_axis ),
  .awburst_secenc_axis        (awburst_secenc_axis),
  .awlock_secenc_axis         (awlock_secenc_axis ),
  .awcache_secenc_axis        (awcache_secenc_axis),
  .awprot_secenc_axis         (awprot_secenc_axis ),
  .awvalid_secenc_axis        (awvalid_secenc_axis),
  .awready_secenc_axis        (awready_secenc_axis),
  .wdata_secenc_axis          (wdata_secenc_axis  ),
  .wstrb_secenc_axis          (wstrb_secenc_axis  ),
  .wlast_secenc_axis          (wlast_secenc_axis  ),
  .wvalid_secenc_axis         (wvalid_secenc_axis ),
  .wready_secenc_axis         (wready_secenc_axis ),
  .bid_secenc_axis            (bid_secenc_axis    ),
  .bresp_secenc_axis          (bresp_secenc_axis  ),
  .bvalid_secenc_axis         (bvalid_secenc_axis ),
  .bready_secenc_axis         (bready_secenc_axis ),
  .arid_secenc_axis           (arid_secenc_axis   ),
  .araddr_secenc_axis         (araddr_secenc_axis ),
  .arlen_secenc_axis          (arlen_secenc_axis  ),
  .arsize_secenc_axis         (arsize_secenc_axis ),
  .arburst_secenc_axis        (arburst_secenc_axis),
  .arlock_secenc_axis         (arlock_secenc_axis ),
  .arcache_secenc_axis        (arcache_secenc_axis),
  .arprot_secenc_axis         (arprot_secenc_axis ),
  .arvalid_secenc_axis        (arvalid_secenc_axis),
  .arready_secenc_axis        (arready_secenc_axis),
  .rid_secenc_axis            (rid_secenc_axis    ),
  .rdata_secenc_axis          (rdata_secenc_axis  ),
  .rresp_secenc_axis          (rresp_secenc_axis  ),
  .rlast_secenc_axis          (rlast_secenc_axis  ),
  .rvalid_secenc_axis         (rvalid_secenc_axis ),
  .rready_secenc_axis         (rready_secenc_axis ),
  .awuser_secenc_axis         (awuser_secenc_axis ),
  .aruser_secenc_axis         (aruser_secenc_axis ),
  .ruser_secenc_axis          (ruser_secenc_axis  ),
  .buser_secenc_axis          (buser_secenc_axis  ),
                              

  .csysreq_cd_a               (qch_exp_aclk_devqreqn[0]   ),
  .csysack_cd_a               (qch_exp_aclk_devqacceptn[0]),
  .cactive_cd_a               (qch_exp_aclk_devqactive[0] ), 


  .mainclk                    (aclk),
  .mainresetn                 (aresetn),
  .aclk                       (aclk),
  .aresetn                    (aresetn),
  .aclk_r                     (aclk),
  .aresetn_r                  (aresetn)

);

  assign qch_exp_aclk_devqdeny[0] = 1'b0; 
        


wire ir_tamper_ar = |armmusid_sysctrl_axim[7:0];
wire ir_tamper_aw = |awmmusid_sysctrl_axim[7:0];
wire [14:0] unused_paddr_uart;
wire [ 3:0] unused_paddr_sysctrl;

nic400_sse710_sctrl_apb u_nic400_sysctrl_apb (

  .paddr_uart_apb           ({unused_paddr_uart,paddr_uart_apb}),
  .pwdata_uart_apb          (pwdata_uart_apb  ),
  .pwrite_uart_apb          (pwrite_uart_apb  ),
  .pprot_uart_apb           (pprot_uart_apb   ),
  .pstrb_uart_apb           (pstrb_uart_apb   ),
  .penable_uart_apb         (penable_uart_apb ),
  .pselx_uart_apb           (pselx_uart_apb   ),
  .prdata_uart_apb          (prdata_uart_apb  ),
  .pslverr_uart_apb         (pslverr_uart_apb ),
  .pready_uart_apb          (pready_uart_apb  ),
  

  .paddr_sysctrl_apb        ({unused_paddr_sysctrl,paddr_sysctrl_apb}),
  .pwdata_sysctrl_apb       (pwdata_sysctrl_apb  ),
  .pwrite_sysctrl_apb       (pwrite_sysctrl_apb  ),
  .pprot_sysctrl_apb        (pprot_sysctrl_apb   ),
  .pstrb_sysctrl_apb        (pstrb_sysctrl_apb   ),
  .penable_sysctrl_apb      (penable_sysctrl_apb ),
  .pselx_sysctrl_apb        (pselx_sysctrl_apb   ),
  .prdata_sysctrl_apb       (prdata_sysctrl_apb  ),
  .pslverr_sysctrl_apb      (pslverr_sysctrl_apb ),
  .pready_sysctrl_apb       (pready_sysctrl_apb  ),
  

  .awid_sysctrl_axis        (awid_sysctrl_axim   ),
  .awaddr_sysctrl_axis      (awaddr_sysctrl_axim ),
  .awlen_sysctrl_axis       (awlen_sysctrl_axim  ),
  .awsize_sysctrl_axis      (awsize_sysctrl_axim ),
  .awburst_sysctrl_axis     (awburst_sysctrl_axim),
  .awlock_sysctrl_axis      (awlock_sysctrl_axim ),
  .awcache_sysctrl_axis     (awcache_sysctrl_axim),
  .awprot_sysctrl_axis      ({ir_tamper_aw,awprot_sysctrl_axim[1:0]}),
  .awvalid_sysctrl_axis     (awvalid_sysctrl_axim),
  .awready_sysctrl_axis     (awready_sysctrl_axim),
  .wdata_sysctrl_axis       (wdata_sysctrl_axim  ),
  .wstrb_sysctrl_axis       (wstrb_sysctrl_axim  ),
  .wlast_sysctrl_axis       (wlast_sysctrl_axim  ),
  .wvalid_sysctrl_axis      (wvalid_sysctrl_axim ),
  .wready_sysctrl_axis      (wready_sysctrl_axim ),
  .bid_sysctrl_axis         (bid_sysctrl_axim    ),
  .bresp_sysctrl_axis       (bresp_sysctrl_axim  ),
  .bvalid_sysctrl_axis      (bvalid_sysctrl_axim ),
  .bready_sysctrl_axis      (bready_sysctrl_axim ),
  .arid_sysctrl_axis        (arid_sysctrl_axim   ),
  .araddr_sysctrl_axis      (araddr_sysctrl_axim ),
  .arlen_sysctrl_axis       (arlen_sysctrl_axim  ),
  .arsize_sysctrl_axis      (arsize_sysctrl_axim ),
  .arburst_sysctrl_axis     (arburst_sysctrl_axim),
  .arlock_sysctrl_axis      (arlock_sysctrl_axim ),
  .arcache_sysctrl_axis     (arcache_sysctrl_axim),
  .arprot_sysctrl_axis      ({ir_tamper_ar,arprot_sysctrl_axim[1:0]}),
  .arvalid_sysctrl_axis     (arvalid_sysctrl_axim),
  .arready_sysctrl_axis     (arready_sysctrl_axim),
  .rid_sysctrl_axis         (rid_sysctrl_axim    ),
  .rdata_sysctrl_axis       (rdata_sysctrl_axim  ),
  .rresp_sysctrl_axis       (rresp_sysctrl_axim  ),
  .rlast_sysctrl_axis       (rlast_sysctrl_axim  ),
  .rvalid_sysctrl_axis      (rvalid_sysctrl_axim ),
  .rready_sysctrl_axis      (rready_sysctrl_axim ),
  .awqos_sysctrl_axis       (4'hf), 
  .arqos_sysctrl_axis       (4'hf), 


  .csysreq_cd_a               (qch_exp_aclk_devqreqn[1]   ),
  .csysack_cd_a               (qch_exp_aclk_devqacceptn[1]),
  .cactive_cd_a               (qch_exp_aclk_devqactive[1] ), 


  .aclk     (aclk),
  .aclken   (1'b1),  
  .aresetn  (aresetn)

);
  assign qch_exp_aclk_devqdeny[1] = 1'b0; 
        

nic400_sse710_sys_apb u_nic400_sys_apb (
  

  .csysreq_cd_a               (qch_exp_aclk_devqreqn[2]   ),
  .csysack_cd_a               (qch_exp_aclk_devqacceptn[2]),
  .cactive_cd_a               (qch_exp_aclk_devqactive[2] ), 
  
  .haddr_gpvmain_ahb          (haddr_gpvmain_ahb),    
  .hburst_gpvmain_ahb         (hburst_gpvmain_ahb),   
  .hprot_gpvmain_ahb          (hprot_gpvmain_ahb),    
  .hsize_gpvmain_ahb          (hsize_gpvmain_ahb),    
  .htrans_gpvmain_ahb         (htrans_gpvmain_ahb),   
  .hwdata_gpvmain_ahb         (hwdata_gpvmain_ahb),   
  .hwrite_gpvmain_ahb         (hwrite_gpvmain_ahb),   
  .hrdata_gpvmain_ahb         (hrdata_gpvmain_ahb),   
  .hreadyout_gpvmain_ahb      (hreadyout_gpvmain_ahb),
  .hresp_gpvmain_ahb          (hresp_gpvmain_ahb),    
  .hselx_gpvmain_ahb          (hselx_gpvmain_ahb),    
  .hready_gpvmain_ahb         (hready_gpvmain_ahb),   


  .awid_gic_axim              (awid_gic_axim   ),
  .awaddr_gic_axim            (awaddr_gic_axim ),
  .awlen_gic_axim             (awlen_gic_axim  ),
  .awsize_gic_axim            (awsize_gic_axim ),
  .awburst_gic_axim           (awburst_gic_axim),
  .awlock_gic_axim            (awlock_gic_axim ),
  .awcache_gic_axim           (awcache_gic_axim),
  .awprot_gic_axim            (awprot_gic_axim ),
  .awqos_gic_axim             (awqos_gic_axim  ),
  .awvalid_gic_axim           (awvalid_gic_axim),
  .awready_gic_axim           (awready_gic_axim),
  .wdata_gic_axim             (wdata_gic_axim  ),
  .wstrb_gic_axim             (wstrb_gic_axim  ),
  .wlast_gic_axim             (wlast_gic_axim  ),
  .wvalid_gic_axim            (wvalid_gic_axim ),
  .wready_gic_axim            (wready_gic_axim ),
  .bid_gic_axim               (bid_gic_axim    ),
  .bresp_gic_axim             (bresp_gic_axim  ),
  .bvalid_gic_axim            (bvalid_gic_axim ),
  .bready_gic_axim            (bready_gic_axim ),
  .arid_gic_axim              (arid_gic_axim   ),
  .araddr_gic_axim            (araddr_gic_axim ),
  .arlen_gic_axim             (arlen_gic_axim  ),
  .arsize_gic_axim            (arsize_gic_axim ),
  .arburst_gic_axim           (arburst_gic_axim),
  .arlock_gic_axim            (arlock_gic_axim ),
  .arcache_gic_axim           (arcache_gic_axim),
  .arprot_gic_axim            (arprot_gic_axim ),
  .arqos_gic_axim             (arqos_gic_axim  ),
  .arvalid_gic_axim           (arvalid_gic_axim),
  .arready_gic_axim           (arready_gic_axim),
  .rid_gic_axim               (rid_gic_axim    ),
  .rdata_gic_axim             (rdata_gic_axim  ),
  .rresp_gic_axim             (rresp_gic_axim  ),
  .rlast_gic_axim             (rlast_gic_axim  ),
  .rvalid_gic_axim            (rvalid_gic_axim ),
  .rready_gic_axim            (rready_gic_axim ),
  .awuser_gic_axim            (awuser_gic_axim ),
  .aruser_gic_axim            (aruser_gic_axim ),
  

  .paddr_hse_mhu0         (paddr_hse_mhu0  ),
  .pselx_hse_mhu0         (pselx_hse_mhu0  ),
  .penable_hse_mhu0       (penable_hse_mhu0),
  .pwrite_hse_mhu0        (pwrite_hse_mhu0 ),
  .prdata_hse_mhu0        (prdata_hse_mhu0 ),
  .pwdata_hse_mhu0        (pwdata_hse_mhu0 ),
  .pprot_hse_mhu0         (pprot_hse_mhu0  ),
  .pstrb_hse_mhu0         (pstrb_hse_mhu0  ),
  .pready_hse_mhu0        (pready_hse_mhu0 ),
  .pslverr_hse_mhu0       (pslverr_hse_mhu0),
  

  .paddr_hse_mhu1         (paddr_hse_mhu1  ),
  .pselx_hse_mhu1         (pselx_hse_mhu1  ),
  .penable_hse_mhu1       (penable_hse_mhu1),
  .pwrite_hse_mhu1        (pwrite_hse_mhu1 ),
  .prdata_hse_mhu1        (prdata_hse_mhu1 ),
  .pwdata_hse_mhu1        (pwdata_hse_mhu1 ),
  .pprot_hse_mhu1         (pprot_hse_mhu1  ),
  .pstrb_hse_mhu1         (pstrb_hse_mhu1  ),
  .pready_hse_mhu1        (pready_hse_mhu1 ),
  .pslverr_hse_mhu1       (pslverr_hse_mhu1),
  

  .paddr_sdc600_apb           (paddr_sdc600_apb  ),
  .pselx_sdc600_apb           (pselx_sdc600_apb  ),
  .penable_sdc600_apb         (penable_sdc600_apb),
  .pwrite_sdc600_apb          (pwrite_sdc600_apb ),
  .prdata_sdc600_apb          (prdata_sdc600_apb ),
  .pwdata_sdc600_apb          (pwdata_sdc600_apb ),
  .pprot_sdc600_apb           (pprot_sdc600_apb  ),
  .pstrb_sdc600_apb           (pstrb_sdc600_apb  ),
  .pready_sdc600_apb          (pready_sdc600_apb ),
  .pslverr_sdc600_apb         (pslverr_sdc600_apb),
  

  .paddr_seh_mhu0         (paddr_seh_mhu0  ),
  .pselx_seh_mhu0         (pselx_seh_mhu0  ),
  .penable_seh_mhu0       (penable_seh_mhu0),
  .pwrite_seh_mhu0        (pwrite_seh_mhu0 ),
  .prdata_seh_mhu0        (prdata_seh_mhu0 ),
  .pwdata_seh_mhu0        (pwdata_seh_mhu0 ),
  .pprot_seh_mhu0         (pprot_seh_mhu0  ),
  .pstrb_seh_mhu0         (pstrb_seh_mhu0  ),
  .pready_seh_mhu0        (pready_seh_mhu0 ),
  .pslverr_seh_mhu0       (pslverr_seh_mhu0),
  

  .paddr_seh_mhu1         (paddr_seh_mhu1  ),
  .pselx_seh_mhu1         (pselx_seh_mhu1  ),
  .penable_seh_mhu1       (penable_seh_mhu1),
  .pwrite_seh_mhu1        (pwrite_seh_mhu1 ),
  .prdata_seh_mhu1        (prdata_seh_mhu1 ),
  .pwdata_seh_mhu1        (pwdata_seh_mhu1 ),
  .pprot_seh_mhu1         (pprot_seh_mhu1  ),
  .pstrb_seh_mhu1         (pstrb_seh_mhu1  ),
  .pready_seh_mhu1        (pready_seh_mhu1 ),
  .pslverr_seh_mhu1       (pslverr_seh_mhu1),
  

  .awid_stm_axim              (awid_stm_axim   ),
  .awaddr_stm_axim            (awaddr_stm_axim ),
  .awlen_stm_axim             (awlen_stm_axim  ),
  .awsize_stm_axim            (awsize_stm_axim ),
  .awburst_stm_axim           (awburst_stm_axim),
  .awlock_stm_axim            (awlock_stm_axim ),
  .awcache_stm_axim           (awcache_stm_axim),
  .awprot_stm_axim            (awprot_stm_axim ),
  .awvalid_stm_axim           (awvalid_stm_axim),
  .awready_stm_axim           (awready_stm_axim),
  .wdata_stm_axim             (wdata_stm_axim  ),
  .wstrb_stm_axim             (wstrb_stm_axim  ),
  .wlast_stm_axim             (wlast_stm_axim  ),
  .wvalid_stm_axim            (wvalid_stm_axim ),
  .wready_stm_axim            (wready_stm_axim ),
  .bid_stm_axim               (bid_stm_axim    ),
  .bresp_stm_axim             (bresp_stm_axim  ),
  .bvalid_stm_axim            (bvalid_stm_axim ),
  .bready_stm_axim            (bready_stm_axim ),
  .arid_stm_axim              (arid_stm_axim   ),
  .araddr_stm_axim            (araddr_stm_axim ),
  .arlen_stm_axim             (arlen_stm_axim  ),
  .arsize_stm_axim            (arsize_stm_axim ),
  .arburst_stm_axim           (arburst_stm_axim),
  .arlock_stm_axim            (arlock_stm_axim ),
  .arcache_stm_axim           (arcache_stm_axim),
  .arprot_stm_axim            (arprot_stm_axim ),
  .arvalid_stm_axim           (arvalid_stm_axim),
  .arready_stm_axim           (arready_stm_axim),
  .rid_stm_axim               (rid_stm_axim    ),
  .rdata_stm_axim             (rdata_stm_axim  ),
  .rresp_stm_axim             (rresp_stm_axim  ),
  .rlast_stm_axim             (rlast_stm_axim  ),
  .rvalid_stm_axim            (rvalid_stm_axim ),
  .rready_stm_axim            (rready_stm_axim ),
  .awuser_stm_axim            (awuser_stm_axim ), 
  .aruser_stm_axim            (aruser_stm_axim ), 
                            
  
  .awid_sysperi_axis          (awid_sysperi_axim   ),
  .awaddr_sysperi_axis        (awaddr_sysperi_axim ),
  .awlen_sysperi_axis         (awlen_sysperi_axim  ),
  .awsize_sysperi_axis        (awsize_sysperi_axim ),
  .awburst_sysperi_axis       (awburst_sysperi_axim),
  .awlock_sysperi_axis        (awlock_sysperi_axim ),
  .awcache_sysperi_axis       (awcache_sysperi_axim),
  .awprot_sysperi_axis        (awprot_sysperi_axim ),
  .awvalid_sysperi_axis       (awvalid_sysperi_axim),
  .awready_sysperi_axis       (awready_sysperi_axim),
  .wdata_sysperi_axis         (wdata_sysperi_axim  ),
  .wstrb_sysperi_axis         (wstrb_sysperi_axim  ),
  .wlast_sysperi_axis         (wlast_sysperi_axim  ),
  .wvalid_sysperi_axis        (wvalid_sysperi_axim ),
  .wready_sysperi_axis        (wready_sysperi_axim ),
  .bid_sysperi_axis           (bid_sysperi_axim    ),
  .bresp_sysperi_axis         (bresp_sysperi_axim  ),
  .bvalid_sysperi_axis        (bvalid_sysperi_axim ),
  .bready_sysperi_axis        (bready_sysperi_axim ),
  .arid_sysperi_axis          (arid_sysperi_axim   ),
  .araddr_sysperi_axis        (araddr_sysperi_axim ),
  .arlen_sysperi_axis         (arlen_sysperi_axim  ),
  .arsize_sysperi_axis        (arsize_sysperi_axim ),
  .arburst_sysperi_axis       (arburst_sysperi_axim),
  .arlock_sysperi_axis        (arlock_sysperi_axim ),
  .arcache_sysperi_axis       (arcache_sysperi_axim),
  .arprot_sysperi_axis        (arprot_sysperi_axim ),
  .arvalid_sysperi_axis       (arvalid_sysperi_axim),
  .arready_sysperi_axis       (arready_sysperi_axim),
  .rid_sysperi_axis           (rid_sysperi_axim    ),
  .rdata_sysperi_axis         (rdata_sysperi_axim  ),
  .rresp_sysperi_axis         (rresp_sysperi_axim  ),
  .rlast_sysperi_axis         (rlast_sysperi_axim  ),
  .rvalid_sysperi_axis        (rvalid_sysperi_axim ),
  .rready_sysperi_axis        (rready_sysperi_axim ),
  .awuser_sysperi_axis        (awuser_sysperi_axim ),
  .aruser_sysperi_axis        (aruser_sysperi_axim ),
  .awqos_sysperi_axis         (4'hf), 
  .arqos_sysperi_axis         (4'hf), 
  
  
  
  .paddr_es0h_mhu0          (paddr_es0h_mhu0  ),
  .pselx_es0h_mhu0          (pselx_es0h_mhu0  ),
  .penable_es0h_mhu0        (penable_es0h_mhu0),
  .pwrite_es0h_mhu0         (pwrite_es0h_mhu0 ),
  .prdata_es0h_mhu0         (prdata_es0h_mhu0 ),
  .pwdata_es0h_mhu0         (pwdata_es0h_mhu0 ),
  .pprot_es0h_mhu0          (pprot_es0h_mhu0  ),
  .pstrb_es0h_mhu0          (pstrb_es0h_mhu0  ),
  .pready_es0h_mhu0         (pready_es0h_mhu0 ),
  .pslverr_es0h_mhu0        (pslverr_es0h_mhu0),
  
  
  .paddr_hes0_mhu0          (paddr_hes0_mhu0  ),
  .pselx_hes0_mhu0          (pselx_hes0_mhu0  ),
  .penable_hes0_mhu0        (penable_hes0_mhu0),
  .pwrite_hes0_mhu0         (pwrite_hes0_mhu0 ),
  .prdata_hes0_mhu0         (prdata_hes0_mhu0 ),
  .pwdata_hes0_mhu0         (pwdata_hes0_mhu0 ),
  .pprot_hes0_mhu0          (pprot_hes0_mhu0  ),
  .pstrb_hes0_mhu0          (pstrb_hes0_mhu0  ),
  .pready_hes0_mhu0         (pready_hes0_mhu0 ),
  .pslverr_hes0_mhu0        (pslverr_hes0_mhu0),

    
  
  .paddr_es0h_mhu1          (paddr_es0h_mhu1  ),
  .pselx_es0h_mhu1          (pselx_es0h_mhu1  ),
  .penable_es0h_mhu1        (penable_es0h_mhu1),
  .pwrite_es0h_mhu1         (pwrite_es0h_mhu1 ),
  .prdata_es0h_mhu1         (prdata_es0h_mhu1 ),
  .pwdata_es0h_mhu1         (pwdata_es0h_mhu1 ),
  .pprot_es0h_mhu1          (pprot_es0h_mhu1  ),
  .pstrb_es0h_mhu1          (pstrb_es0h_mhu1  ),
  .pready_es0h_mhu1         (pready_es0h_mhu1 ),
  .pslverr_es0h_mhu1        (pslverr_es0h_mhu1),
  

  
  .paddr_hes0_mhu1          (paddr_hes0_mhu1  ),
  .pselx_hes0_mhu1          (pselx_hes0_mhu1  ),
  .penable_hes0_mhu1        (penable_hes0_mhu1),
  .pwrite_hes0_mhu1         (pwrite_hes0_mhu1 ),
  .prdata_hes0_mhu1         (prdata_hes0_mhu1 ),
  .pwdata_hes0_mhu1         (pwdata_hes0_mhu1 ),
  .pprot_hes0_mhu1          (pprot_hes0_mhu1  ),
  .pstrb_hes0_mhu1          (pstrb_hes0_mhu1  ),
  .pready_hes0_mhu1         (pready_hes0_mhu1 ),
  .pslverr_hes0_mhu1        (pslverr_hes0_mhu1),
  
    
  .paddr_es1h_mhu0          (paddr_es1h_mhu0  ),
  .pselx_es1h_mhu0          (pselx_es1h_mhu0  ),
  .penable_es1h_mhu0        (penable_es1h_mhu0),
  .pwrite_es1h_mhu0         (pwrite_es1h_mhu0 ),
  .prdata_es1h_mhu0         (prdata_es1h_mhu0 ),
  .pwdata_es1h_mhu0         (pwdata_es1h_mhu0 ),
  .pprot_es1h_mhu0          (pprot_es1h_mhu0  ),
  .pstrb_es1h_mhu0          (pstrb_es1h_mhu0  ),
  .pready_es1h_mhu0         (pready_es1h_mhu0 ),
  .pslverr_es1h_mhu0        (pslverr_es1h_mhu0),
  
  
  .paddr_hes1_mhu0          (paddr_hes1_mhu0  ),
  .pselx_hes1_mhu0          (pselx_hes1_mhu0  ),
  .penable_hes1_mhu0        (penable_hes1_mhu0),
  .pwrite_hes1_mhu0         (pwrite_hes1_mhu0 ),
  .prdata_hes1_mhu0         (prdata_hes1_mhu0 ),
  .pwdata_hes1_mhu0         (pwdata_hes1_mhu0 ),
  .pprot_hes1_mhu0          (pprot_hes1_mhu0  ),
  .pstrb_hes1_mhu0          (pstrb_hes1_mhu0  ),
  .pready_hes1_mhu0         (pready_hes1_mhu0 ),
  .pslverr_hes1_mhu0        (pslverr_hes1_mhu0),

    
  
  .paddr_es1h_mhu1          (paddr_es1h_mhu1  ),
  .pselx_es1h_mhu1          (pselx_es1h_mhu1  ),
  .penable_es1h_mhu1        (penable_es1h_mhu1),
  .pwrite_es1h_mhu1         (pwrite_es1h_mhu1 ),
  .prdata_es1h_mhu1         (prdata_es1h_mhu1 ),
  .pwdata_es1h_mhu1         (pwdata_es1h_mhu1 ),
  .pprot_es1h_mhu1          (pprot_es1h_mhu1  ),
  .pstrb_es1h_mhu1          (pstrb_es1h_mhu1  ),
  .pready_es1h_mhu1         (pready_es1h_mhu1 ),
  .pslverr_es1h_mhu1        (pslverr_es1h_mhu1),
  

  
  .paddr_hes1_mhu1          (paddr_hes1_mhu1  ),
  .pselx_hes1_mhu1          (pselx_hes1_mhu1  ),
  .penable_hes1_mhu1        (penable_hes1_mhu1),
  .pwrite_hes1_mhu1         (pwrite_hes1_mhu1 ),
  .prdata_hes1_mhu1         (prdata_hes1_mhu1 ),
  .pwdata_hes1_mhu1         (pwdata_hes1_mhu1 ),
  .pprot_hes1_mhu1          (pprot_hes1_mhu1  ),
  .pstrb_hes1_mhu1          (pstrb_hes1_mhu1  ),
  .pready_hes1_mhu1         (pready_hes1_mhu1 ),
  .pslverr_hes1_mhu1        (pslverr_hes1_mhu1),
  
    

  .csysreq_cd_ctrl            (csysreq_cd_ctrl),
  .csysack_cd_ctrl            (csysack_cd_ctrl),
  .cactive_cd_ctrl            (cactive_cd_ctrl),
  

  .paddr_ppu_cpu_apb          (paddr_ppu_cpu_apb  ),
  .pselx_ppu_cpu_apb          (pselx_ppu_cpu_apb  ),
  .penable_ppu_cpu_apb        (penable_ppu_cpu_apb),
  .pwrite_ppu_cpu_apb         (pwrite_ppu_cpu_apb ),
  .prdata_ppu_cpu_apb         (prdata_ppu_cpu_apb ),
  .pwdata_ppu_cpu_apb         (pwdata_ppu_cpu_apb ),
  .pprot_ppu_cpu_apb          (pprot_ppu_cpu_apb  ),
  .pstrb_ppu_cpu_apb          (pstrb_ppu_cpu_apb  ),
  .pready_ppu_cpu_apb         (pready_ppu_cpu_apb ),
  .pslverr_ppu_cpu_apb        (pslverr_ppu_cpu_apb),


  .paddr_hostsysdbg_apb      (paddr_hostsysdbg_apb),
  .pwdata_hostsysdbg_apb     (pwdata_hostsysdbg_apb),
  .pwrite_hostsysdbg_apb     (pwrite_hostsysdbg_apb),
  .pprot_hostsysdbg_apb      (pprot_hostsysdbg_apb),
  .pstrb_hostsysdbg_apb      (pstrb_hostsysdbg_apb),
  .penable_hostsysdbg_apb    (penable_hostsysdbg_apb),
  .pselx_hostsysdbg_apb      (pselx_hostsysdbg_apb),
  .prdata_hostsysdbg_apb     (prdata_hostsysdbg_apb),
  .pslverr_hostsysdbg_apb    (pslverr_hostsysdbg_apb),
  .pready_hostsysdbg_apb     (pready_hostsysdbg_apb),
  

  .aclk                       (aclk      ),
  .aclken                     (1'b1      ),
  .aresetn                    (aresetn   ),
  .ctrlclk                    (ctrlclk   ),
  .ctrlclken                  (1'b1      ),
  .ctrlresetn                 (ctrlresetn)
);
  assign qch_exp_aclk_devqdeny[2] = 1'b0; 
        


nic400_sse710_dbgaxi2apb  u_nic400_dbgaxi2apb (


  .paddr_extdbg_apb     (paddr_extdbg_apb),
  .pwdata_extdbg_apb    (pwdata_extdbg_apb),
  .pwrite_extdbg_apb    (pwrite_extdbg_apb),
  .pprot_extdbg_apb     (pprot_extdbg_apb),
  .pstrb_extdbg_apb     (pstrb_extdbg_apb),
  .penable_extdbg_apb   (penable_extdbg_apb),
  .pselx_extdbg_apb     (pselx_extdbg_apb),
  .prdata_extdbg_apb    (prdata_extdbg_apb),
  .pslverr_extdbg_apb   (pslverr_extdbg_apb),
  .pready_extdbg_apb    (pready_extdbg_apb),
  

  .awid_debug_axis      (awid_debug_axim   ),
  .awaddr_debug_axis    (awaddr_debug_axim ),
  .awlen_debug_axis     (awlen_debug_axim  ),
  .awsize_debug_axis    (awsize_debug_axim ),
  .awburst_debug_axis   (awburst_debug_axim),
  .awlock_debug_axis    (awlock_debug_axim ),
  .awcache_debug_axis   (awcache_debug_axim),
  .awprot_debug_axis    (awprot_debug_axim ),
  .awvalid_debug_axis   (awvalid_debug_axim),
  .awready_debug_axis   (awready_debug_axim),
  .wdata_debug_axis     (wdata_debug_axim  ),
  .wstrb_debug_axis     (wstrb_debug_axim  ),
  .wlast_debug_axis     (wlast_debug_axim  ),
  .wvalid_debug_axis    (wvalid_debug_axim ),
  .wready_debug_axis    (wready_debug_axim ),
  .bid_debug_axis       (bid_debug_axim    ),
  .bresp_debug_axis     (bresp_debug_axim  ),
  .bvalid_debug_axis    (bvalid_debug_axim ),
  .bready_debug_axis    (bready_debug_axim ),
  .arid_debug_axis      (arid_debug_axim   ),
  .araddr_debug_axis    (araddr_debug_axim ),
  .arlen_debug_axis     (arlen_debug_axim  ),
  .arsize_debug_axis    (arsize_debug_axim ),
  .arburst_debug_axis   (arburst_debug_axim),
  .arlock_debug_axis    (arlock_debug_axim ),
  .arcache_debug_axis   (arcache_debug_axim),
  .arprot_debug_axis    (arprot_debug_axim ),
  .arvalid_debug_axis   (arvalid_debug_axim),
  .arready_debug_axis   (arready_debug_axim),
  .rid_debug_axis       (rid_debug_axim    ),
  .rdata_debug_axis     (rdata_debug_axim  ),
  .rresp_debug_axis     (rresp_debug_axim  ),
  .rlast_debug_axis     (rlast_debug_axim  ),
  .rvalid_debug_axis    (rvalid_debug_axim ),
  .rready_debug_axis    (rready_debug_axim ),

  
  .csysreq_cd_a               (qch_exp_aclk_devqreqn[3]   ),
  .csysack_cd_a               (qch_exp_aclk_devqacceptn[3]),
  .cactive_cd_a               (qch_exp_aclk_devqactive[3] ), 


  .aclk       (aclk   ),
  .aclken     (1'b1   ),
  .aresetn    (aresetn)
);

  assign qch_exp_aclk_devqdeny[3] = 1'b0; 
        



`include "firewall_f0_global_masterid_cfg_sse710.vh"
`include "firewall_f0_comp_global_cfg_sse710_sysperiph.vh" 

firewall_f0_comp #(
  `include "firewall_f0_comp_cfg_sse710_sysperiph.vh"
) u_fc_1 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_sysperi_axim),
  .awaddr_s_i           (fc_awaddr_sysperi_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_sysperi_axim),
  .awsize_s_i           (fc_awsize_sysperi_axim),
  .awburst_s_i          (fc_awburst_sysperi_axim),
  .awlock_s_i           (fc_awlock_sysperi_axim),
  .awcache_s_i          (fc_awcache_sysperi_axim),
  .awprot_s_i           (fc_awprot_sysperi_axim),
  .awqos_s_i            (4'hf), 
  .awuser_s_i           (fc_awuser_sysperi_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_sysperi_axim),
  .awready_s_o          (fc_awready_sysperi_axim),
  .awmmusid_s_i         (fc_awuser_sysperi_axim[9:2]),

  .wdata_s_i            (fc_wdata_sysperi_axim),
  .wstrb_s_i            (fc_wstrb_sysperi_axim),
  .wlast_s_i            (fc_wlast_sysperi_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_sysperi_axim),
  .wready_s_o           (fc_wready_sysperi_axim),

  .bid_s_o              (fc_bid_sysperi_axim  ),
  .bresp_s_o            (fc_bresp_sysperi_axim),
  .buser_s_o            (fc_buser_sysperi_axim),
  .bvalid_s_o           (fc_bvalid_sysperi_axim),
  .bready_s_i           (fc_bready_sysperi_axim),

  .arid_s_i             (fc_arid_sysperi_axim   ),
  .araddr_s_i           (fc_araddr_sysperi_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_sysperi_axim  ),
  .arsize_s_i           (fc_arsize_sysperi_axim ),
  .arburst_s_i          (fc_arburst_sysperi_axim),
  .arlock_s_i           (fc_arlock_sysperi_axim ),
  .arcache_s_i          (fc_arcache_sysperi_axim),
  .arprot_s_i           (fc_arprot_sysperi_axim ),
  .arqos_s_i            (4'hf), 
  .aruser_s_i           (fc_aruser_sysperi_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_sysperi_axim),
  .arready_s_o          (fc_arready_sysperi_axim),
  .armmusid_s_i         (fc_aruser_sysperi_axim[9:2]),

  .rid_s_o              (fc_rid_sysperi_axim   ),
  .rdata_s_o            (fc_rdata_sysperi_axim ),
  .rresp_s_o            (fc_rresp_sysperi_axim ),
  .rlast_s_o            (fc_rlast_sysperi_axim ),
  .ruser_s_o            (fc_ruser_sysperi_axim),
  .rvalid_s_o           (fc_rvalid_sysperi_axim),
  .rready_s_i           (fc_rready_sysperi_axim),

  .awakeup_s_i          (1'b0), 

  .awid_m_o             (awid_sysperi_axim   ),
  .awaddr_m_o           (awaddr_sysperi_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_sysperi_axim  ),
  .awsize_m_o           (awsize_sysperi_axim ),
  .awburst_m_o          (awburst_sysperi_axim),
  .awlock_m_o           (awlock_sysperi_axim ),
  .awcache_m_o          (awcache_sysperi_axim),
  .awprot_m_o           (awprot_sysperi_axim ),
  .awqos_m_o            (),
  .awuser_m_o           (awuser_sysperi_axim[1:0]),
  .awvalid_m_o          (awvalid_sysperi_axim),
  .awready_m_i          (awready_sysperi_axim),
  .awmmusid_m_o         (awuser_sysperi_axim[9:2]),

  .wdata_m_o            (wdata_sysperi_axim ),
  .wstrb_m_o            (wstrb_sysperi_axim ),
  .wlast_m_o            (wlast_sysperi_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_sysperi_axim),
  .wready_m_i           (wready_sysperi_axim),

  .bid_m_i              (bid_sysperi_axim   ),
  .bresp_m_i            (bresp_sysperi_axim ),
  .buser_m_i            (1'b0 ),
  .bvalid_m_i           (bvalid_sysperi_axim),
  .bready_m_o           (bready_sysperi_axim),

  .arid_m_o             (arid_sysperi_axim   ),
  .araddr_m_o           (araddr_sysperi_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_sysperi_axim  ),
  .arsize_m_o           (arsize_sysperi_axim ),
  .arburst_m_o          (arburst_sysperi_axim),
  .arlock_m_o           (arlock_sysperi_axim ),
  .arcache_m_o          (arcache_sysperi_axim),
  .arprot_m_o           (arprot_sysperi_axim ),
  .arqos_m_o            (),
  .aruser_m_o           (aruser_sysperi_axim[1:0]),
  .arvalid_m_o          (arvalid_sysperi_axim),
  .arready_m_i          (arready_sysperi_axim),
  .armmusid_m_o         (aruser_sysperi_axim[9:2]),

  .rid_m_i              (rid_sysperi_axim   ),
  .rdata_m_i            (rdata_sysperi_axim ),
  .rresp_m_i            (rresp_sysperi_axim ),
  .rlast_m_i            (rlast_sysperi_axim ),
  .ruser_m_i            (1'b0 ),
  .rvalid_m_i           (rvalid_sysperi_axim),
  .rready_m_o           (rready_sysperi_axim),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[4]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[4]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[4]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[4] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[0]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[0]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[0]),
  .pwr_qactive_o        (qactive_systop_base_internal[0]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s0),
  .tready_ds_i          (tready_dti_dn_s0),
  .tdata_ds_o           (tdata_dti_dn_s0),
  .tkeep_ds_o           (tkeep_dti_dn_s0),
  .tlast_ds_o           (tlast_dti_dn_s0),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s0),

  .tvalid_us_i          (tvalid_dti_up_s0),
  .tready_us_o          (tready_dti_up_s0),
  .tdata_us_i           (tdata_dti_up_s0),  
  .tkeep_us_i           (tkeep_dti_up_s0),  
  .tlast_us_i           (tlast_dti_up_s0),  
  .tdest_us_i           (4'h1), 
  .twakeup_us_i         (twakeup_dti_up_s0),

  .bypass_i             (fctrl_bypass)
);


`include "firewall_f0_comp_global_cfg_sse710_dbgperiph.vh" 

firewall_f0_comp #(
  `include "firewall_f0_comp_cfg_sse710_dbgperiph.vh"
) u_fc_2 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_debug_axim),
  .awaddr_s_i           (fc_awaddr_debug_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_debug_axim),
  .awsize_s_i           (fc_awsize_debug_axim),
  .awburst_s_i          (fc_awburst_debug_axim),
  .awlock_s_i           (fc_awlock_debug_axim),
  .awcache_s_i          (fc_awcache_debug_axim),
  .awprot_s_i           (fc_awprot_debug_axim),
  .awqos_s_i            (4'hf), 
  .awuser_s_i           (fc_awuser_debug_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_debug_axim),
  .awready_s_o          (fc_awready_debug_axim),
  .awmmusid_s_i         (fc_awuser_debug_axim[9:2]),

  .wdata_s_i            (fc_wdata_debug_axim),
  .wstrb_s_i            (fc_wstrb_debug_axim),
  .wlast_s_i            (fc_wlast_debug_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_debug_axim),
  .wready_s_o           (fc_wready_debug_axim),

  .bid_s_o              (fc_bid_debug_axim  ),
  .bresp_s_o            (fc_bresp_debug_axim),
  .buser_s_o            (fc_buser_debug_axim),
  .bvalid_s_o           (fc_bvalid_debug_axim),
  .bready_s_i           (fc_bready_debug_axim),

  .arid_s_i             (fc_arid_debug_axim   ),
  .araddr_s_i           (fc_araddr_debug_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_debug_axim  ),
  .arsize_s_i           (fc_arsize_debug_axim ),
  .arburst_s_i          (fc_arburst_debug_axim),
  .arlock_s_i           (fc_arlock_debug_axim ),
  .arcache_s_i          (fc_arcache_debug_axim),
  .arprot_s_i           (fc_arprot_debug_axim ),
  .arqos_s_i            (4'hf), 
  .aruser_s_i           (fc_aruser_debug_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_debug_axim),
  .arready_s_o          (fc_arready_debug_axim),
  .armmusid_s_i         (fc_aruser_debug_axim[9:2]),

  .rid_s_o              (fc_rid_debug_axim   ),
  .rdata_s_o            (fc_rdata_debug_axim ),
  .rresp_s_o            (fc_rresp_debug_axim ),
  .rlast_s_o            (fc_rlast_debug_axim ),
  .ruser_s_o            (fc_ruser_debug_axim),
  .rvalid_s_o           (fc_rvalid_debug_axim),
  .rready_s_i           (fc_rready_debug_axim),

  .awakeup_s_i          (1'b0), 

  .awid_m_o             (awid_debug_axim   ),
  .awaddr_m_o           (awaddr_debug_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_debug_axim  ),
  .awsize_m_o           (awsize_debug_axim ),
  .awburst_m_o          (awburst_debug_axim),
  .awlock_m_o           (awlock_debug_axim ),
  .awcache_m_o          (awcache_debug_axim),
  .awprot_m_o           (awprot_debug_axim ),
  .awqos_m_o            (),
  .awuser_m_o           (),
  .awvalid_m_o          (awvalid_debug_axim),
  .awready_m_i          (awready_debug_axim),
  .awmmusid_m_o         (),

  .wdata_m_o            (wdata_debug_axim ),
  .wstrb_m_o            (wstrb_debug_axim ),
  .wlast_m_o            (wlast_debug_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_debug_axim),
  .wready_m_i           (wready_debug_axim),

  .bid_m_i              (bid_debug_axim   ),
  .bresp_m_i            (bresp_debug_axim ),
  .buser_m_i            (1'b0 ),
  .bvalid_m_i           (bvalid_debug_axim),
  .bready_m_o           (bready_debug_axim),

  .arid_m_o             (arid_debug_axim   ),
  .araddr_m_o           (araddr_debug_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_debug_axim  ),
  .arsize_m_o           (arsize_debug_axim ),
  .arburst_m_o          (arburst_debug_axim),
  .arlock_m_o           (arlock_debug_axim ),
  .arcache_m_o          (arcache_debug_axim),
  .arprot_m_o           (arprot_debug_axim ),
  .arqos_m_o            (),
  .aruser_m_o           (),
  .arvalid_m_o          (arvalid_debug_axim),
  .arready_m_i          (arready_debug_axim),
  .armmusid_m_o         (),

  .rid_m_i              (rid_debug_axim   ),
  .rdata_m_i            (rdata_debug_axim ),
  .rresp_m_i            (rresp_debug_axim ),
  .rlast_m_i            (rlast_debug_axim ),
  .ruser_m_i            (1'b0 ),
  .rvalid_m_i           (rvalid_debug_axim),
  .rready_m_o           (rready_debug_axim),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[5]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[5]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[5]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[5] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[1]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[1]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[1]),
  .pwr_qactive_o        (qactive_systop_base_internal[1]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s1),
  .tready_ds_i          (tready_dti_dn_s1),
  .tdata_ds_o           (tdata_dti_dn_s1),
  .tkeep_ds_o           (tkeep_dti_dn_s1),
  .tlast_ds_o           (tlast_dti_dn_s1),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s1),

  .tvalid_us_i          (tvalid_dti_up_s1),
  .tready_us_o          (tready_dti_up_s1),
  .tdata_us_i           (tdata_dti_up_s1),  
  .tkeep_us_i           (tkeep_dti_up_s1),  
  .tlast_us_i           (tlast_dti_up_s1),  
  .tdest_us_i           (4'h2), 
  .twakeup_us_i         (twakeup_dti_up_s1),

  .bypass_i             (fctrl_bypass)
);


wire unused_arprot;
wire unused_awprot;
`include "firewall_f0_comp_global_cfg_sse710_aonperiph.vh" 

firewall_f0_comp #(
  `include "firewall_f0_comp_cfg_sse710_aonperiph.vh"
) u_fc_3 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_sysctrl_axim),
  .awaddr_s_i           (fc_awaddr_sysctrl_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_sysctrl_axim),
  .awsize_s_i           (fc_awsize_sysctrl_axim),
  .awburst_s_i          (fc_awburst_sysctrl_axim),
  .awlock_s_i           (fc_awlock_sysctrl_axim),
  .awcache_s_i          (fc_awcache_sysctrl_axim),
  .awprot_s_i           (fc_awprot_sysctrl_axim),
  .awqos_s_i            (4'hf), 
  .awuser_s_i           (fc_awuser_sysctrl_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_sysctrl_axim),
  .awready_s_o          (fc_awready_sysctrl_axim),
  .awmmusid_s_i         (fc_awuser_sysctrl_axim[9:2]),

  .wdata_s_i            (fc_wdata_sysctrl_axim),
  .wstrb_s_i            (fc_wstrb_sysctrl_axim),
  .wlast_s_i            (fc_wlast_sysctrl_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_sysctrl_axim),
  .wready_s_o           (fc_wready_sysctrl_axim),

  .bid_s_o              (fc_bid_sysctrl_axim   ),
  .bresp_s_o            (fc_bresp_sysctrl_axim ),
  .buser_s_o            (fc_buser_sysctrl_axim ),
  .bvalid_s_o           (fc_bvalid_sysctrl_axim),
  .bready_s_i           (fc_bready_sysctrl_axim),

  .arid_s_i             (fc_arid_sysctrl_axim   ),
  .araddr_s_i           (fc_araddr_sysctrl_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_sysctrl_axim  ),
  .arsize_s_i           (fc_arsize_sysctrl_axim ),
  .arburst_s_i          (fc_arburst_sysctrl_axim),
  .arlock_s_i           (fc_arlock_sysctrl_axim ),
  .arcache_s_i          (fc_arcache_sysctrl_axim),
  .arprot_s_i           (fc_arprot_sysctrl_axim ),
  .arqos_s_i            (4'hf), 
  .aruser_s_i           (fc_aruser_sysctrl_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_sysctrl_axim),
  .arready_s_o          (fc_arready_sysctrl_axim),
  .armmusid_s_i         (fc_aruser_sysctrl_axim[9:2]),

  .rid_s_o              (fc_rid_sysctrl_axim   ),
  .rdata_s_o            (fc_rdata_sysctrl_axim ),
  .rresp_s_o            (fc_rresp_sysctrl_axim ),
  .rlast_s_o            (fc_rlast_sysctrl_axim ),
  .ruser_s_o            (fc_ruser_sysctrl_axim ),
  .rvalid_s_o           (fc_rvalid_sysctrl_axim),
  .rready_s_i           (fc_rready_sysctrl_axim),

  .awakeup_s_i          (1'b0), 

  .awid_m_o             (awid_sysctrl_axim   ),
  .awaddr_m_o           (awaddr_sysctrl_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_sysctrl_axim  ),
  .awsize_m_o           (awsize_sysctrl_axim ),
  .awburst_m_o          (awburst_sysctrl_axim),
  .awlock_m_o           (awlock_sysctrl_axim ),
  .awcache_m_o          (awcache_sysctrl_axim),
  .awprot_m_o           ({unused_awprot,awprot_sysctrl_axim[1:0]}),
  .awqos_m_o            (), 
  .awuser_m_o           (),
  .awvalid_m_o          (awvalid_sysctrl_axim),
  .awready_m_i          (awready_sysctrl_axim),
  .awmmusid_m_o         (awmmusid_sysctrl_axim),

  .wdata_m_o            (wdata_sysctrl_axim ),
  .wstrb_m_o            (wstrb_sysctrl_axim ),
  .wlast_m_o            (wlast_sysctrl_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_sysctrl_axim),
  .wready_m_i           (wready_sysctrl_axim),

  .bid_m_i              (bid_sysctrl_axim   ),
  .bresp_m_i            (bresp_sysctrl_axim ),
  .buser_m_i            (1'b0),
  .bvalid_m_i           (bvalid_sysctrl_axim),
  .bready_m_o           (bready_sysctrl_axim),

  .arid_m_o             (arid_sysctrl_axim   ),
  .araddr_m_o           (araddr_sysctrl_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_sysctrl_axim  ),
  .arsize_m_o           (arsize_sysctrl_axim ),
  .arburst_m_o          (arburst_sysctrl_axim),
  .arlock_m_o           (arlock_sysctrl_axim ),
  .arcache_m_o          (arcache_sysctrl_axim),
  .arprot_m_o           ({unused_arprot,arprot_sysctrl_axim[1:0]}),
  .arqos_m_o            (), 
  .aruser_m_o           (),
  .arvalid_m_o          (arvalid_sysctrl_axim),
  .arready_m_i          (arready_sysctrl_axim),
  .armmusid_m_o         (armmusid_sysctrl_axim),

  .rid_m_i              (rid_sysctrl_axim   ),
  .rdata_m_i            (rdata_sysctrl_axim ),
  .rresp_m_i            (rresp_sysctrl_axim ),
  .rlast_m_i            (rlast_sysctrl_axim ),
  .ruser_m_i            (1'b0),
  .rvalid_m_i           (rvalid_sysctrl_axim),
  .rready_m_o           (rready_sysctrl_axim),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[6]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[6]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[6]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[6] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[2]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[2]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[2]),
  .pwr_qactive_o        (qactive_systop_base_internal[2]),

  .tvalid_ds_o          (tvalid_dti_dn_s2),
  .tready_ds_i          (tready_dti_dn_s2),
  .tdata_ds_o           (tdata_dti_dn_s2),
  .tkeep_ds_o           (tkeep_dti_dn_s2),
  .tlast_ds_o           (tlast_dti_dn_s2),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s2),

  .tvalid_us_i          (tvalid_dti_up_s2),
  .tready_us_o          (tready_dti_up_s2),
  .tdata_us_i           (tdata_dti_up_s2),  
  .tkeep_us_i           (tkeep_dti_up_s2),  
  .tlast_us_i           (tlast_dti_up_s2),  
  .tdest_us_i           (4'h3), 
  .twakeup_us_i         (twakeup_dti_up_s2),

  .bypass_i             (fctrl_bypass)
);


reg fc_awakeup_xnvm_axim;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fc_awakeup_xnvm_axim <= 1'b0;
  end
  else 
  begin
    fc_awakeup_xnvm_axim <= fc_awvalid_xnvm_axim | fc_arvalid_xnvm_axim | fc_wvalid_xnvm_axim;
  end
end

`include "firewall_f0_comp_global_cfg_sse710_xnvm.vh" 

firewall_f0_comp #(
  `include "firewall_f0_comp_cfg_sse710_xnvm.vh"  
) u_fc_4 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_xnvm_axim),
  .awaddr_s_i           (fc_awaddr_xnvm_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_xnvm_axim),
  .awsize_s_i           (fc_awsize_xnvm_axim),
  .awburst_s_i          (fc_awburst_xnvm_axim),
  .awlock_s_i           (fc_awlock_xnvm_axim),
  .awcache_s_i          (fc_awcache_xnvm_axim),
  .awprot_s_i           (fc_awprot_xnvm_axim),
  .awqos_s_i            (fc_awqos_xnvm_axim),
  .awuser_s_i           (fc_awuser_xnvm_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_xnvm_axim),
  .awready_s_o          (fc_awready_xnvm_axim),
  .awmmusid_s_i         (fc_awuser_xnvm_axim[9:2]),

  .wdata_s_i            (fc_wdata_xnvm_axim),
  .wstrb_s_i            (fc_wstrb_xnvm_axim),
  .wlast_s_i            (fc_wlast_xnvm_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_xnvm_axim),
  .wready_s_o           (fc_wready_xnvm_axim),

  .bid_s_o              (fc_bid_xnvm_axim  ),
  .bresp_s_o            (fc_bresp_xnvm_axim),
  .buser_s_o            (fc_buser_xnvm_axim),
  .bvalid_s_o           (fc_bvalid_xnvm_axim),
  .bready_s_i           (fc_bready_xnvm_axim),

  .arid_s_i             (fc_arid_xnvm_axim   ),
  .araddr_s_i           (fc_araddr_xnvm_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_xnvm_axim  ),
  .arsize_s_i           (fc_arsize_xnvm_axim ),
  .arburst_s_i          (fc_arburst_xnvm_axim),
  .arlock_s_i           (fc_arlock_xnvm_axim ),
  .arcache_s_i          (fc_arcache_xnvm_axim),
  .arprot_s_i           (fc_arprot_xnvm_axim ),
  .arqos_s_i            (fc_arqos_xnvm_axim  ),
  .aruser_s_i           (fc_aruser_xnvm_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_xnvm_axim),
  .arready_s_o          (fc_arready_xnvm_axim),
  .armmusid_s_i         (fc_aruser_xnvm_axim[9:2]),

  .rid_s_o              (fc_rid_xnvm_axim   ),
  .rdata_s_o            (fc_rdata_xnvm_axim ),
  .rresp_s_o            (fc_rresp_xnvm_axim ),
  .rlast_s_o            (fc_rlast_xnvm_axim ),
  .ruser_s_o            (fc_ruser_xnvm_axim),
  .rvalid_s_o           (fc_rvalid_xnvm_axim),
  .rready_s_i           (fc_rready_xnvm_axim),

  .awakeup_s_i          (fc_awakeup_xnvm_axim),

  .awid_m_o             (awid_xnvm_axim   ),
  .awaddr_m_o           (awaddr_xnvm_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_xnvm_axim  ),
  .awsize_m_o           (awsize_xnvm_axim ),
  .awburst_m_o          (awburst_xnvm_axim),
  .awlock_m_o           (awlock_xnvm_axim ),
  .awcache_m_o          (awcache_xnvm_axim),
  .awprot_m_o           (awprot_xnvm_axim ),
  .awqos_m_o            (awqos_xnvm_axim  ),
  .awuser_m_o           (awuser_xnvm_axim[1:0]),
  .awvalid_m_o          (awvalid_xnvm_axim),
  .awready_m_i          (awready_xnvm_axim),
  .awmmusid_m_o         (awuser_xnvm_axim[9:2]),

  .wdata_m_o            (wdata_xnvm_axim ),
  .wstrb_m_o            (wstrb_xnvm_axim ),
  .wlast_m_o            (wlast_xnvm_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_xnvm_axim),
  .wready_m_i           (wready_xnvm_axim),

  .bid_m_i              (bid_xnvm_axim   ),
  .bresp_m_i            (bresp_xnvm_axim ),
  .buser_m_i            (1'b0),
  .bvalid_m_i           (bvalid_xnvm_axim),
  .bready_m_o           (bready_xnvm_axim),

  .arid_m_o             (arid_xnvm_axim   ),
  .araddr_m_o           (araddr_xnvm_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_xnvm_axim  ),
  .arsize_m_o           (arsize_xnvm_axim ),
  .arburst_m_o          (arburst_xnvm_axim),
  .arlock_m_o           (arlock_xnvm_axim ),
  .arcache_m_o          (arcache_xnvm_axim),
  .arprot_m_o           (arprot_xnvm_axim ),
  .arqos_m_o            (arqos_xnvm_axim  ),
  .aruser_m_o           (aruser_xnvm_axim[1:0]),
  .arvalid_m_o          (arvalid_xnvm_axim),
  .arready_m_i          (arready_xnvm_axim),
  .armmusid_m_o         (aruser_xnvm_axim[9:2]),

  .rid_m_i              (rid_xnvm_axim   ),
  .rdata_m_i            (rdata_xnvm_axim ),
  .rresp_m_i            (rresp_xnvm_axim ),
  .rlast_m_i            (rlast_xnvm_axim ),
  .ruser_m_i            (1'b0),
  .rvalid_m_i           (rvalid_xnvm_axim),
  .rready_m_o           (rready_xnvm_axim),

  .awakeup_m_o          (awakeup_xnvm_axim),
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[7]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[7]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[7]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[7] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[3]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[3]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[3]),
  .pwr_qactive_o        (qactive_systop_base_internal[3]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s3),
  .tready_ds_i          (tready_dti_dn_s3),
  .tdata_ds_o           (tdata_dti_dn_s3),
  .tkeep_ds_o           (tkeep_dti_dn_s3),
  .tlast_ds_o           (tlast_dti_dn_s3),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s3),

  .tvalid_us_i          (tvalid_dti_up_s3),
  .tready_us_o          (tready_dti_up_s3),
  .tdata_us_i           (tdata_dti_up_s3),  
  .tkeep_us_i           (tkeep_dti_up_s3),  
  .tlast_us_i           (tlast_dti_up_s3),  
  .tdest_us_i           (4'h4), 
  .twakeup_us_i         (twakeup_dti_up_s3),

  .bypass_i             (fctrl_bypass)
);


reg fc_awakeup_cvm_axim;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fc_awakeup_cvm_axim <= 1'b0;
  end
  else 
  begin
    fc_awakeup_cvm_axim <= fc_awvalid_cvm_axim | fc_arvalid_cvm_axim | fc_wvalid_cvm_axim;
  end
end

`include "firewall_f0_comp_global_cfg_sse710_cvm.vh" 

firewall_f0_comp #(
  `include "firewall_f0_comp_cfg_sse710_cvm.vh"  
) u_fc_5 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_cvm_axim),
  .awaddr_s_i           (fc_awaddr_cvm_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_cvm_axim),
  .awsize_s_i           (fc_awsize_cvm_axim),
  .awburst_s_i          (fc_awburst_cvm_axim),
  .awlock_s_i           (fc_awlock_cvm_axim),
  .awcache_s_i          (fc_awcache_cvm_axim),
  .awprot_s_i           (fc_awprot_cvm_axim),
  .awqos_s_i            (fc_awqos_cvm_axim),
  .awuser_s_i           (fc_awuser_cvm_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_cvm_axim),
  .awready_s_o          (fc_awready_cvm_axim),
  .awmmusid_s_i         (fc_awuser_cvm_axim[9:2]),

  .wdata_s_i            (fc_wdata_cvm_axim),
  .wstrb_s_i            (fc_wstrb_cvm_axim),
  .wlast_s_i            (fc_wlast_cvm_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_cvm_axim),
  .wready_s_o           (fc_wready_cvm_axim),

  .bid_s_o              (fc_bid_cvm_axim  ),
  .bresp_s_o            (fc_bresp_cvm_axim),
  .buser_s_o            (fc_buser_cvm_axim),
  .bvalid_s_o           (fc_bvalid_cvm_axim),
  .bready_s_i           (fc_bready_cvm_axim),

  .arid_s_i             (fc_arid_cvm_axim   ),
  .araddr_s_i           (fc_araddr_cvm_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_cvm_axim  ),
  .arsize_s_i           (fc_arsize_cvm_axim ),
  .arburst_s_i          (fc_arburst_cvm_axim),
  .arlock_s_i           (fc_arlock_cvm_axim ),
  .arcache_s_i          (fc_arcache_cvm_axim),
  .arprot_s_i           (fc_arprot_cvm_axim ),
  .arqos_s_i            (fc_arqos_cvm_axim  ),
  .aruser_s_i           (fc_aruser_cvm_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_cvm_axim),
  .arready_s_o          (fc_arready_cvm_axim),
  .armmusid_s_i         (fc_aruser_cvm_axim[9:2]),

  .rid_s_o              (fc_rid_cvm_axim   ),
  .rdata_s_o            (fc_rdata_cvm_axim ),
  .rresp_s_o            (fc_rresp_cvm_axim ),
  .rlast_s_o            (fc_rlast_cvm_axim ),
  .ruser_s_o            (fc_ruser_cvm_axim),
  .rvalid_s_o           (fc_rvalid_cvm_axim),
  .rready_s_i           (fc_rready_cvm_axim),

  .awakeup_s_i          (fc_awakeup_cvm_axim),

  .awid_m_o             (awid_cvm_axim   ),
  .awaddr_m_o           (awaddr_cvm_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_cvm_axim  ),
  .awsize_m_o           (awsize_cvm_axim ),
  .awburst_m_o          (awburst_cvm_axim),
  .awlock_m_o           (awlock_cvm_axim ),
  .awcache_m_o          (awcache_cvm_axim),
  .awprot_m_o           (awprot_cvm_axim ),
  .awqos_m_o            (awqos_cvm_axim  ),
  .awuser_m_o           (awuser_cvm_axim[1:0]),
  .awvalid_m_o          (awvalid_cvm_axim),
  .awready_m_i          (awready_cvm_axim),
  .awmmusid_m_o         (awuser_cvm_axim[9:2]),

  .wdata_m_o            (wdata_cvm_axim ),
  .wstrb_m_o            (wstrb_cvm_axim ),
  .wlast_m_o            (wlast_cvm_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_cvm_axim),
  .wready_m_i           (wready_cvm_axim),

  .bid_m_i              (bid_cvm_axim   ),
  .bresp_m_i            (bresp_cvm_axim ),
  .buser_m_i            (1'b0),
  .bvalid_m_i           (bvalid_cvm_axim),
  .bready_m_o           (bready_cvm_axim),

  .arid_m_o             (arid_cvm_axim   ),
  .araddr_m_o           (araddr_cvm_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_cvm_axim  ),
  .arsize_m_o           (arsize_cvm_axim ),
  .arburst_m_o          (arburst_cvm_axim),
  .arlock_m_o           (arlock_cvm_axim ),
  .arcache_m_o          (arcache_cvm_axim),
  .arprot_m_o           (arprot_cvm_axim ),
  .arqos_m_o            (arqos_cvm_axim  ),
  .aruser_m_o           (aruser_cvm_axim[1:0]),
  .arvalid_m_o          (arvalid_cvm_axim),
  .arready_m_i          (arready_cvm_axim),
  .armmusid_m_o         (aruser_cvm_axim[9:2]),

  .rid_m_i              (rid_cvm_axim   ),
  .rdata_m_i            (rdata_cvm_axim ),
  .rresp_m_i            (rresp_cvm_axim ),
  .rlast_m_i            (rlast_cvm_axim ),
  .ruser_m_i            (1'b0),
  .rvalid_m_i           (rvalid_cvm_axim),
  .rready_m_o           (rready_cvm_axim),

  .awakeup_m_o          (awakeup_cvm_axim),
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[8]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[8]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[8]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[8] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[4]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[4]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[4]),
  .pwr_qactive_o        (qactive_systop_base_internal[4]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s4),
  .tready_ds_i          (tready_dti_dn_s4),
  .tdata_ds_o           (tdata_dti_dn_s4),
  .tkeep_ds_o           (tkeep_dti_dn_s4),
  .tlast_ds_o           (tlast_dti_dn_s4),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s4),

  .tvalid_us_i          (tvalid_dti_up_s4),
  .tready_us_o          (tready_dti_up_s4),
  .tdata_us_i           (tdata_dti_up_s4),  
  .tkeep_us_i           (tkeep_dti_up_s4),  
  .tlast_us_i           (tlast_dti_up_s4),  
  .tdest_us_i           (4'h5), 
  .twakeup_us_i         (twakeup_dti_up_s4),

  .bypass_i             (fctrl_bypass)
);


`include "firewall_f0_comp_global_cfg_sse710_host_cpu.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_host_cpu.vh"  
) u_fc_6 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (awid_hostcpu_axis),
  .awaddr_s_i           (awaddr_hostcpu_axis),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (awlen_hostcpu_axis),
  .awsize_s_i           (awsize_hostcpu_axis),
  .awburst_s_i          (awburst_hostcpu_axis),
  .awlock_s_i           (awlock_hostcpu_axis),
  .awcache_s_i          (awcache_hostcpu_axis),
  .awprot_s_i           (awprot_hostcpu_axis),
  .awqos_s_i            (4'hf), 
  .awuser_s_i           (awuser_hostcpu_axis[1:0]),
  .awvalid_s_i          (awvalid_hostcpu_axis),
  .awready_s_o          (awready_hostcpu_axis),
  .awmmusid_s_i         (awuser_hostcpu_axis[9:2]),

  .wdata_s_i            (wdata_hostcpu_axis),
  .wstrb_s_i            (wstrb_hostcpu_axis),
  .wlast_s_i            (wlast_hostcpu_axis),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (wvalid_hostcpu_axis),
  .wready_s_o           (wready_hostcpu_axis),

  .bid_s_o              (bid_hostcpu_axis  ),
  .bresp_s_o            (bresp_hostcpu_axis),
  .buser_s_o            (),
  .bvalid_s_o           (bvalid_hostcpu_axis),
  .bready_s_i           (bready_hostcpu_axis),

  .arid_s_i             (arid_hostcpu_axis   ),
  .araddr_s_i           (araddr_hostcpu_axis ),
  .arregion_s_i         (4'h0                ),
  .arlen_s_i            (arlen_hostcpu_axis  ),
  .arsize_s_i           (arsize_hostcpu_axis ),
  .arburst_s_i          (arburst_hostcpu_axis),
  .arlock_s_i           (arlock_hostcpu_axis ),
  .arcache_s_i          (arcache_hostcpu_axis),
  .arprot_s_i           (arprot_hostcpu_axis ),
  .arqos_s_i            (4'hf), 
  .aruser_s_i           (aruser_hostcpu_axis[1:0]),
  .arvalid_s_i          (arvalid_hostcpu_axis),
  .arready_s_o          (arready_hostcpu_axis),
  .armmusid_s_i         (aruser_hostcpu_axis[9:2]),

  .rid_s_o              (rid_hostcpu_axis   ),
  .rdata_s_o            (rdata_hostcpu_axis ),
  .rresp_s_o            (rresp_hostcpu_axis ),
  .rlast_s_o            (rlast_hostcpu_axis ),
  .ruser_s_o            (),
  .rvalid_s_o           (rvalid_hostcpu_axis),
  .rready_s_i           (rready_hostcpu_axis),

  .awakeup_s_i          (1'b0), 

  .awid_m_o             (fc_awid_hostcpu_axis   ),
  .awaddr_m_o           (fc_awaddr_hostcpu_axis ),
  .awregion_m_o         (                       ),
  .awlen_m_o            (fc_awlen_hostcpu_axis  ),
  .awsize_m_o           (fc_awsize_hostcpu_axis ),
  .awburst_m_o          (fc_awburst_hostcpu_axis),
  .awlock_m_o           (fc_awlock_hostcpu_axis ),
  .awcache_m_o          (fc_awcache_hostcpu_axis),
  .awprot_m_o           (fc_awprot_hostcpu_axis ),
  .awqos_m_o            (), 
  .awuser_m_o           (fc_awuser_hostcpu_axis[1:0]),
  .awvalid_m_o          (fc_awvalid_hostcpu_axis),
  .awready_m_i          (fc_awready_hostcpu_axis),
  .awmmusid_m_o         (fc_awuser_hostcpu_axis[9:2]),

  .wdata_m_o            (fc_wdata_hostcpu_axis ),
  .wstrb_m_o            (fc_wstrb_hostcpu_axis ),
  .wlast_m_o            (fc_wlast_hostcpu_axis ),
  .wuser_m_o            (                      ),
  .wvalid_m_o           (fc_wvalid_hostcpu_axis),
  .wready_m_i           (fc_wready_hostcpu_axis),

  .bid_m_i              (fc_bid_hostcpu_axis   ),
  .bresp_m_i            (fc_bresp_hostcpu_axis ),
  .buser_m_i            (fc_buser_hostcpu_axis ),
  .bvalid_m_i           (fc_bvalid_hostcpu_axis),
  .bready_m_o           (fc_bready_hostcpu_axis),

  .arid_m_o             (fc_arid_hostcpu_axis   ),
  .araddr_m_o           (fc_araddr_hostcpu_axis ),
  .arregion_m_o         (                       ),
  .arlen_m_o            (fc_arlen_hostcpu_axis  ),
  .arsize_m_o           (fc_arsize_hostcpu_axis ),
  .arburst_m_o          (fc_arburst_hostcpu_axis),
  .arlock_m_o           (fc_arlock_hostcpu_axis ),
  .arcache_m_o          (fc_arcache_hostcpu_axis),
  .arprot_m_o           (fc_arprot_hostcpu_axis ),
  .arqos_m_o            (),
  .aruser_m_o           (fc_aruser_hostcpu_axis[1:0]),
  .arvalid_m_o          (fc_arvalid_hostcpu_axis),
  .arready_m_i          (fc_arready_hostcpu_axis),
  .armmusid_m_o         (fc_aruser_hostcpu_axis[9:2]),

  .rid_m_i              (fc_rid_hostcpu_axis   ),
  .rdata_m_i            (fc_rdata_hostcpu_axis ),
  .rresp_m_i            (fc_rresp_hostcpu_axis ),
  .rlast_m_i            (fc_rlast_hostcpu_axis ),
  .ruser_m_i            (fc_ruser_hostcpu_axis ),
  .rvalid_m_i           (fc_rvalid_hostcpu_axis),
  .rready_m_o           (fc_rready_hostcpu_axis),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[9]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[9]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[9]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[9] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[5]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[5]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[5]),
  .pwr_qactive_o        (qactive_systop_base_internal[5]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s5),
  .tready_ds_i          (tready_dti_dn_s5),
  .tdata_ds_o           (tdata_dti_dn_s5),
  .tkeep_ds_o           (tkeep_dti_dn_s5),
  .tlast_ds_o           (tlast_dti_dn_s5),
  .tid_ds_o             (), 
  .twakeup_ds_o         (twakeup_dti_dn_s5),

  .tvalid_us_i          (tvalid_dti_up_s5),
  .tready_us_o          (tready_dti_up_s5),
  .tdata_us_i           (tdata_dti_up_s5),  
  .tkeep_us_i           (tkeep_dti_up_s5),  
  .tlast_us_i           (tlast_dti_up_s5),  
  .tdest_us_i           (4'h6), 
  .twakeup_us_i         (twakeup_dti_up_s5),

  .bypass_i             (fctrl_bypass)
);

`include "firewall_f0_comp_global_cfg_sse710_extsys0.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_extsys0.vh"
) u_fc_7 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (awid_extsys0_axis),
  .awaddr_s_i           (awaddr_extsys0_axis),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (awlen_extsys0_axis),
  .awsize_s_i           (awsize_extsys0_axis),
  .awburst_s_i          (awburst_extsys0_axis),
  .awlock_s_i           (awlock_extsys0_axis),
  .awcache_s_i          (awcache_extsys0_axis),
  .awprot_s_i           (awprot_extsys0_axis),
  .awqos_s_i            (4'hf), //awqos_extsys0_axis),
  .awuser_s_i           (awuser_extsys0_axis[1:0]),
  .awvalid_s_i          (awvalid_extsys0_axis),
  .awready_s_o          (awready_extsys0_axis),
  .awmmusid_s_i         (awuser_extsys0_axis[9:2]),

  .wdata_s_i            (wdata_extsys0_axis),
  .wstrb_s_i            (wstrb_extsys0_axis),
  .wlast_s_i            (wlast_extsys0_axis),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (wvalid_extsys0_axis),
  .wready_s_o           (wready_extsys0_axis),

  .bid_s_o              (bid_extsys0_axis  ),
  .bresp_s_o            (bresp_extsys0_axis),
  .buser_s_o            (),
  .bvalid_s_o           (bvalid_extsys0_axis),
  .bready_s_i           (bready_extsys0_axis),

  .arid_s_i             (arid_extsys0_axis   ),
  .araddr_s_i           (araddr_extsys0_axis ),
  .arregion_s_i         (4'h0                ),
  .arlen_s_i            (arlen_extsys0_axis  ),
  .arsize_s_i           (arsize_extsys0_axis ),
  .arburst_s_i          (arburst_extsys0_axis),
  .arlock_s_i           (arlock_extsys0_axis ),
  .arcache_s_i          (arcache_extsys0_axis),
  .arprot_s_i           (arprot_extsys0_axis ),
  .arqos_s_i            (4'hf), //arqos_extsys0_axis  ),
  .aruser_s_i           (aruser_extsys0_axis[1:0]),
  .arvalid_s_i          (arvalid_extsys0_axis),
  .arready_s_o          (arready_extsys0_axis),
  .armmusid_s_i         (aruser_extsys0_axis[9:2]),

  .rid_s_o              (rid_extsys0_axis   ),
  .rdata_s_o            (rdata_extsys0_axis ),
  .rresp_s_o            (rresp_extsys0_axis ),
  .rlast_s_o            (rlast_extsys0_axis ),
  .ruser_s_o            (                   ),
  .rvalid_s_o           (rvalid_extsys0_axis),
  .rready_s_i           (rready_extsys0_axis),

  .awakeup_s_i          (awakeup_extsys0_axis),

  .awid_m_o             (fc_awid_extsys0_axis   ),
  .awaddr_m_o           (fc_awaddr_extsys0_axis ),
  .awregion_m_o         (                       ),
  .awlen_m_o            (fc_awlen_extsys0_axis  ),
  .awsize_m_o           (fc_awsize_extsys0_axis ),
  .awburst_m_o          (fc_awburst_extsys0_axis),
  .awlock_m_o           (fc_awlock_extsys0_axis ),
  .awcache_m_o          (fc_awcache_extsys0_axis),
  .awprot_m_o           (fc_awprot_extsys0_axis ),
  .awqos_m_o            (),//fc_awqos_extsys0_axis  ),
  .awuser_m_o           (fc_awuser_extsys0_axis[1:0]),
  .awvalid_m_o          (fc_awvalid_extsys0_axis),
  .awready_m_i          (fc_awready_extsys0_axis),
  .awmmusid_m_o         (fc_awuser_extsys0_axis[9:2]),

  .wdata_m_o            (fc_wdata_extsys0_axis ),
  .wstrb_m_o            (fc_wstrb_extsys0_axis ),
  .wlast_m_o            (fc_wlast_extsys0_axis ),
  .wuser_m_o            (                      ),
  .wvalid_m_o           (fc_wvalid_extsys0_axis),
  .wready_m_i           (fc_wready_extsys0_axis),

  .bid_m_i              (fc_bid_extsys0_axis   ),
  .bresp_m_i            (fc_bresp_extsys0_axis ),
  .buser_m_i            (fc_buser_extsys0_axis ),
  .bvalid_m_i           (fc_bvalid_extsys0_axis),
  .bready_m_o           (fc_bready_extsys0_axis),

  .arid_m_o             (fc_arid_extsys0_axis   ),
  .araddr_m_o           (fc_araddr_extsys0_axis ),
  .arregion_m_o         (                       ),
  .arlen_m_o            (fc_arlen_extsys0_axis  ),
  .arsize_m_o           (fc_arsize_extsys0_axis ),
  .arburst_m_o          (fc_arburst_extsys0_axis),
  .arlock_m_o           (fc_arlock_extsys0_axis ),
  .arcache_m_o          (fc_arcache_extsys0_axis),
  .arprot_m_o           (fc_arprot_extsys0_axis ),
  .arqos_m_o            (),//fc_arqos_extsys0_axis  ),
  .aruser_m_o           (fc_aruser_extsys0_axis[1:0]),
  .arvalid_m_o          (fc_arvalid_extsys0_axis),
  .arready_m_i          (fc_arready_extsys0_axis),
  .armmusid_m_o         (fc_aruser_extsys0_axis[9:2]),

  .rid_m_i              (fc_rid_extsys0_axis   ),
  .rdata_m_i            (fc_rdata_extsys0_axis ),
  .rresp_m_i            (fc_rresp_extsys0_axis ),
  .rlast_m_i            (fc_rlast_extsys0_axis ),
  .ruser_m_i            (fc_ruser_extsys0_axis ),
  .rvalid_m_i           (fc_rvalid_extsys0_axis),
  .rready_m_o           (fc_rready_extsys0_axis),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[10]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[10]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[10]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[10] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[6]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[6]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[6]),
  .pwr_qactive_o        (qactive_systop_base_internal[6]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s6),
  .tready_ds_i          (tready_dti_dn_s6),
  .tdata_ds_o           (tdata_dti_dn_s6),
  .tkeep_ds_o           (tkeep_dti_dn_s6),
  .tlast_ds_o           (tlast_dti_dn_s6),
  .tid_ds_o             (), // tid_dti_dn_s6),
  .twakeup_ds_o         (twakeup_dti_dn_s6),

  .tvalid_us_i          (tvalid_dti_up_s6),
  .tready_us_o          (tready_dti_up_s6),
  .tdata_us_i           (tdata_dti_up_s6),  
  .tkeep_us_i           (tkeep_dti_up_s6),  
  .tlast_us_i           (tlast_dti_up_s6),  
  .tdest_us_i           (4'h7), 
  .twakeup_us_i         (twakeup_dti_up_s6),

  .bypass_i             (fctrl_bypass)
);

`include "firewall_f0_comp_global_cfg_sse710_extsys1.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_extsys1.vh"
) u_fc_8 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (awid_extsys1_axis),
  .awaddr_s_i           (awaddr_extsys1_axis),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (awlen_extsys1_axis),
  .awsize_s_i           (awsize_extsys1_axis),
  .awburst_s_i          (awburst_extsys1_axis),
  .awlock_s_i           (awlock_extsys1_axis),
  .awcache_s_i          (awcache_extsys1_axis),
  .awprot_s_i           (awprot_extsys1_axis),
  .awqos_s_i            (4'hf), //awqos_extsys1_axis),
  .awuser_s_i           (awuser_extsys1_axis[1:0]),
  .awvalid_s_i          (awvalid_extsys1_axis),
  .awready_s_o          (awready_extsys1_axis),
  .awmmusid_s_i         (awuser_extsys1_axis[9:2]),

  .wdata_s_i            (wdata_extsys1_axis),
  .wstrb_s_i            (wstrb_extsys1_axis),
  .wlast_s_i            (wlast_extsys1_axis),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (wvalid_extsys1_axis),
  .wready_s_o           (wready_extsys1_axis),

  .bid_s_o              (bid_extsys1_axis  ),
  .bresp_s_o            (bresp_extsys1_axis),
  .buser_s_o            (),
  .bvalid_s_o           (bvalid_extsys1_axis),
  .bready_s_i           (bready_extsys1_axis),

  .arid_s_i             (arid_extsys1_axis   ),
  .araddr_s_i           (araddr_extsys1_axis ),
  .arregion_s_i         (4'h0                ),
  .arlen_s_i            (arlen_extsys1_axis  ),
  .arsize_s_i           (arsize_extsys1_axis ),
  .arburst_s_i          (arburst_extsys1_axis),
  .arlock_s_i           (arlock_extsys1_axis ),
  .arcache_s_i          (arcache_extsys1_axis),
  .arprot_s_i           (arprot_extsys1_axis ),
  .arqos_s_i            (4'hf), //arqos_extsys1_axis  ),
  .aruser_s_i           (aruser_extsys1_axis[1:0]),
  .arvalid_s_i          (arvalid_extsys1_axis),
  .arready_s_o          (arready_extsys1_axis),
  .armmusid_s_i         (aruser_extsys1_axis[9:2]),

  .rid_s_o              (rid_extsys1_axis   ),
  .rdata_s_o            (rdata_extsys1_axis ),
  .rresp_s_o            (rresp_extsys1_axis ),
  .rlast_s_o            (rlast_extsys1_axis ),
  .ruser_s_o            (                   ),
  .rvalid_s_o           (rvalid_extsys1_axis),
  .rready_s_i           (rready_extsys1_axis),

  .awakeup_s_i          (awakeup_extsys1_axis),

  .awid_m_o             (fc_awid_extsys1_axis   ),
  .awaddr_m_o           (fc_awaddr_extsys1_axis ),
  .awregion_m_o         (                       ),
  .awlen_m_o            (fc_awlen_extsys1_axis  ),
  .awsize_m_o           (fc_awsize_extsys1_axis ),
  .awburst_m_o          (fc_awburst_extsys1_axis),
  .awlock_m_o           (fc_awlock_extsys1_axis ),
  .awcache_m_o          (fc_awcache_extsys1_axis),
  .awprot_m_o           (fc_awprot_extsys1_axis ),
  .awqos_m_o            (),//fc_awqos_extsys1_axis  ),
  .awuser_m_o           (fc_awuser_extsys1_axis[1:0]),
  .awvalid_m_o          (fc_awvalid_extsys1_axis),
  .awready_m_i          (fc_awready_extsys1_axis),
  .awmmusid_m_o         (fc_awuser_extsys1_axis[9:2]),

  .wdata_m_o            (fc_wdata_extsys1_axis ),
  .wstrb_m_o            (fc_wstrb_extsys1_axis ),
  .wlast_m_o            (fc_wlast_extsys1_axis ),
  .wuser_m_o            (                      ),
  .wvalid_m_o           (fc_wvalid_extsys1_axis),
  .wready_m_i           (fc_wready_extsys1_axis),

  .bid_m_i              (fc_bid_extsys1_axis   ),
  .bresp_m_i            (fc_bresp_extsys1_axis ),
  .buser_m_i            (fc_buser_extsys1_axis ),
  .bvalid_m_i           (fc_bvalid_extsys1_axis),
  .bready_m_o           (fc_bready_extsys1_axis),

  .arid_m_o             (fc_arid_extsys1_axis   ),
  .araddr_m_o           (fc_araddr_extsys1_axis ),
  .arregion_m_o         (                       ),
  .arlen_m_o            (fc_arlen_extsys1_axis  ),
  .arsize_m_o           (fc_arsize_extsys1_axis ),
  .arburst_m_o          (fc_arburst_extsys1_axis),
  .arlock_m_o           (fc_arlock_extsys1_axis ),
  .arcache_m_o          (fc_arcache_extsys1_axis),
  .arprot_m_o           (fc_arprot_extsys1_axis ),
  .arqos_m_o            (),//fc_arqos_extsys1_axis  ),
  .aruser_m_o           (fc_aruser_extsys1_axis[1:0]),
  .arvalid_m_o          (fc_arvalid_extsys1_axis),
  .arready_m_i          (fc_arready_extsys1_axis),
  .armmusid_m_o         (fc_aruser_extsys1_axis[9:2]),

  .rid_m_i              (fc_rid_extsys1_axis   ),
  .rdata_m_i            (fc_rdata_extsys1_axis ),
  .rresp_m_i            (fc_rresp_extsys1_axis ),
  .rlast_m_i            (fc_rlast_extsys1_axis ),
  .ruser_m_i            (fc_ruser_extsys1_axis ),
  .rvalid_m_i           (fc_rvalid_extsys1_axis),
  .rready_m_o           (fc_rready_extsys1_axis),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[11]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[11]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[11]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[11] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[7]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[7]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[7]),
  .pwr_qactive_o        (qactive_systop_base_internal[7]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s7),
  .tready_ds_i          (tready_dti_dn_s7),
  .tdata_ds_o           (tdata_dti_dn_s7),
  .tkeep_ds_o           (tkeep_dti_dn_s7),
  .tlast_ds_o           (tlast_dti_dn_s7),
  .tid_ds_o             (), // tid_dti_dn_s7),
  .twakeup_ds_o         (twakeup_dti_dn_s7),

  .tvalid_us_i          (tvalid_dti_up_s7),
  .tready_us_o          (tready_dti_up_s7),
  .tdata_us_i           (tdata_dti_up_s7),  
  .tkeep_us_i           (tkeep_dti_up_s7),  
  .tlast_us_i           (tlast_dti_up_s7),  
  .tdest_us_i           (4'h8), 
  .twakeup_us_i         (twakeup_dti_up_s7),

  .bypass_i             (fctrl_bypass)
);

`include "firewall_f0_comp_global_cfg_sse710_expslv0.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_expslv0.vh"  
) u_fc_9 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (awid_expslv0_axis),
  .awaddr_s_i           (awaddr_expslv0_axis),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (awlen_expslv0_axis),
  .awsize_s_i           (awsize_expslv0_axis),
  .awburst_s_i          (awburst_expslv0_axis),
  .awlock_s_i           (awlock_expslv0_axis),
  .awcache_s_i          (awcache_expslv0_axis),
  .awprot_s_i           (awprot_expslv0_axis),
  .awqos_s_i            (awqos_expslv0_axis),
  .awuser_s_i           (awuser_expslv0_axis[1:0]),
  .awvalid_s_i          (awvalid_expslv0_axis),
  .awready_s_o          (awready_expslv0_axis),
  .awmmusid_s_i         (awuser_expslv0_axis[9:2]),

  .wdata_s_i            (wdata_expslv0_axis),
  .wstrb_s_i            (wstrb_expslv0_axis),
  .wlast_s_i            (wlast_expslv0_axis),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (wvalid_expslv0_axis),
  .wready_s_o           (wready_expslv0_axis),

  .bid_s_o              (bid_expslv0_axis  ),
  .bresp_s_o            (bresp_expslv0_axis),
  .buser_s_o            (),
  .bvalid_s_o           (bvalid_expslv0_axis),
  .bready_s_i           (bready_expslv0_axis),

  .arid_s_i             (arid_expslv0_axis   ),
  .araddr_s_i           (araddr_expslv0_axis ),
  .arregion_s_i         (4'h0                ),
  .arlen_s_i            (arlen_expslv0_axis  ),
  .arsize_s_i           (arsize_expslv0_axis ),
  .arburst_s_i          (arburst_expslv0_axis),
  .arlock_s_i           (arlock_expslv0_axis ),
  .arcache_s_i          (arcache_expslv0_axis),
  .arprot_s_i           (arprot_expslv0_axis ),
  .arqos_s_i            (arqos_expslv0_axis  ),
  .aruser_s_i           (aruser_expslv0_axis[1:0]),
  .arvalid_s_i          (arvalid_expslv0_axis),
  .arready_s_o          (arready_expslv0_axis),
  .armmusid_s_i         (aruser_expslv0_axis[9:2]),

  .rid_s_o              (rid_expslv0_axis   ),
  .rdata_s_o            (rdata_expslv0_axis ),
  .rresp_s_o            (rresp_expslv0_axis ),
  .rlast_s_o            (rlast_expslv0_axis ),
  .ruser_s_o            (                   ),
  .rvalid_s_o           (rvalid_expslv0_axis),
  .rready_s_i           (rready_expslv0_axis),

  .awakeup_s_i          (awakeup_expslv0_axis),

  .awid_m_o             (fc_awid_expslv0_axis   ),
  .awaddr_m_o           (fc_awaddr_expslv0_axis ),
  .awregion_m_o         (                       ),
  .awlen_m_o            (fc_awlen_expslv0_axis  ),
  .awsize_m_o           (fc_awsize_expslv0_axis ),
  .awburst_m_o          (fc_awburst_expslv0_axis),
  .awlock_m_o           (fc_awlock_expslv0_axis ),
  .awcache_m_o          (fc_awcache_expslv0_axis),
  .awprot_m_o           (fc_awprot_expslv0_axis ),
  .awqos_m_o            (fc_awqos_expslv0_axis  ),
  .awuser_m_o           (fc_awuser_expslv0_axis[1:0]),
  .awvalid_m_o          (fc_awvalid_expslv0_axis),
  .awready_m_i          (fc_awready_expslv0_axis),
  .awmmusid_m_o         (fc_awuser_expslv0_axis[9:2]),

  .wdata_m_o            (fc_wdata_expslv0_axis ),
  .wstrb_m_o            (fc_wstrb_expslv0_axis ),
  .wlast_m_o            (fc_wlast_expslv0_axis ),
  .wuser_m_o            (                      ),
  .wvalid_m_o           (fc_wvalid_expslv0_axis),
  .wready_m_i           (fc_wready_expslv0_axis),

  .bid_m_i              (fc_bid_expslv0_axis   ),
  .bresp_m_i            (fc_bresp_expslv0_axis ),
  .buser_m_i            (fc_buser_expslv0_axis ),
  .bvalid_m_i           (fc_bvalid_expslv0_axis),
  .bready_m_o           (fc_bready_expslv0_axis),

  .arid_m_o             (fc_arid_expslv0_axis   ),
  .araddr_m_o           (fc_araddr_expslv0_axis ),
  .arregion_m_o         (                       ),
  .arlen_m_o            (fc_arlen_expslv0_axis  ),
  .arsize_m_o           (fc_arsize_expslv0_axis ),
  .arburst_m_o          (fc_arburst_expslv0_axis),
  .arlock_m_o           (fc_arlock_expslv0_axis ),
  .arcache_m_o          (fc_arcache_expslv0_axis),
  .arprot_m_o           (fc_arprot_expslv0_axis ),
  .arqos_m_o            (fc_arqos_expslv0_axis  ),
  .aruser_m_o           (fc_aruser_expslv0_axis[1:0]),
  .arvalid_m_o          (fc_arvalid_expslv0_axis),
  .arready_m_i          (fc_arready_expslv0_axis),
  .armmusid_m_o         (fc_aruser_expslv0_axis[9:2]),

  .rid_m_i              (fc_rid_expslv0_axis   ),
  .rdata_m_i            (fc_rdata_expslv0_axis ),
  .rresp_m_i            (fc_rresp_expslv0_axis ),
  .rlast_m_i            (fc_rlast_expslv0_axis ),
  .ruser_m_i            (fc_ruser_expslv0_axis ),
  .rvalid_m_i           (fc_rvalid_expslv0_axis),
  .rready_m_o           (fc_rready_expslv0_axis),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[12]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[12]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[12]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[12] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[8]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[8]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[8]),
  .pwr_qactive_o        (qactive_systop_base_internal[8]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s8),
  .tready_ds_i          (tready_dti_dn_s8),
  .tdata_ds_o           (tdata_dti_dn_s8),
  .tkeep_ds_o           (tkeep_dti_dn_s8),
  .tlast_ds_o           (tlast_dti_dn_s8),
  .tid_ds_o             (), // tid_dti_dn_s8),
  .twakeup_ds_o         (twakeup_dti_dn_s8),

  .tvalid_us_i          (tvalid_dti_up_s8),
  .tready_us_o          (tready_dti_up_s8),
  .tdata_us_i           (tdata_dti_up_s8),
  .tkeep_us_i           (tkeep_dti_up_s8),
  .tlast_us_i           (tlast_dti_up_s8),  
  .tdest_us_i           (4'h9), 
  .twakeup_us_i         (twakeup_dti_up_s8),

  .bypass_i             (fctrl_bypass)
);  
`include "firewall_f0_comp_global_cfg_sse710_expslv1.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_expslv1.vh"  
) u_fc_10 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (awid_expslv1_axis),
  .awaddr_s_i           (awaddr_expslv1_axis),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (awlen_expslv1_axis),
  .awsize_s_i           (awsize_expslv1_axis),
  .awburst_s_i          (awburst_expslv1_axis),
  .awlock_s_i           (awlock_expslv1_axis),
  .awcache_s_i          (awcache_expslv1_axis),
  .awprot_s_i           (awprot_expslv1_axis),
  .awqos_s_i            (awqos_expslv1_axis),
  .awuser_s_i           (awuser_expslv1_axis[1:0]),
  .awvalid_s_i          (awvalid_expslv1_axis),
  .awready_s_o          (awready_expslv1_axis),
  .awmmusid_s_i         (awuser_expslv1_axis[9:2]),

  .wdata_s_i            (wdata_expslv1_axis),
  .wstrb_s_i            (wstrb_expslv1_axis),
  .wlast_s_i            (wlast_expslv1_axis),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (wvalid_expslv1_axis),
  .wready_s_o           (wready_expslv1_axis),

  .bid_s_o              (bid_expslv1_axis  ),
  .bresp_s_o            (bresp_expslv1_axis),
  .buser_s_o            (),
  .bvalid_s_o           (bvalid_expslv1_axis),
  .bready_s_i           (bready_expslv1_axis),

  .arid_s_i             (arid_expslv1_axis   ),
  .araddr_s_i           (araddr_expslv1_axis ),
  .arregion_s_i         (4'h0                ),
  .arlen_s_i            (arlen_expslv1_axis  ),
  .arsize_s_i           (arsize_expslv1_axis ),
  .arburst_s_i          (arburst_expslv1_axis),
  .arlock_s_i           (arlock_expslv1_axis ),
  .arcache_s_i          (arcache_expslv1_axis),
  .arprot_s_i           (arprot_expslv1_axis ),
  .arqos_s_i            (arqos_expslv1_axis  ),
  .aruser_s_i           (aruser_expslv1_axis[1:0]),
  .arvalid_s_i          (arvalid_expslv1_axis),
  .arready_s_o          (arready_expslv1_axis),
  .armmusid_s_i         (aruser_expslv1_axis[9:2]),

  .rid_s_o              (rid_expslv1_axis   ),
  .rdata_s_o            (rdata_expslv1_axis ),
  .rresp_s_o            (rresp_expslv1_axis ),
  .rlast_s_o            (rlast_expslv1_axis ),
  .ruser_s_o            (                   ),
  .rvalid_s_o           (rvalid_expslv1_axis),
  .rready_s_i           (rready_expslv1_axis),

  .awakeup_s_i          (awakeup_expslv1_axis),

  .awid_m_o             (fc_awid_expslv1_axis   ),
  .awaddr_m_o           (fc_awaddr_expslv1_axis ),
  .awregion_m_o         (                       ),
  .awlen_m_o            (fc_awlen_expslv1_axis  ),
  .awsize_m_o           (fc_awsize_expslv1_axis ),
  .awburst_m_o          (fc_awburst_expslv1_axis),
  .awlock_m_o           (fc_awlock_expslv1_axis ),
  .awcache_m_o          (fc_awcache_expslv1_axis),
  .awprot_m_o           (fc_awprot_expslv1_axis ),
  .awqos_m_o            (fc_awqos_expslv1_axis  ),
  .awuser_m_o           (fc_awuser_expslv1_axis[1:0]),
  .awvalid_m_o          (fc_awvalid_expslv1_axis),
  .awready_m_i          (fc_awready_expslv1_axis),
  .awmmusid_m_o         (fc_awuser_expslv1_axis[9:2]),

  .wdata_m_o            (fc_wdata_expslv1_axis ),
  .wstrb_m_o            (fc_wstrb_expslv1_axis ),
  .wlast_m_o            (fc_wlast_expslv1_axis ),
  .wuser_m_o            (                      ),
  .wvalid_m_o           (fc_wvalid_expslv1_axis),
  .wready_m_i           (fc_wready_expslv1_axis),

  .bid_m_i              (fc_bid_expslv1_axis   ),
  .bresp_m_i            (fc_bresp_expslv1_axis ),
  .buser_m_i            (fc_buser_expslv1_axis ),
  .bvalid_m_i           (fc_bvalid_expslv1_axis),
  .bready_m_o           (fc_bready_expslv1_axis),

  .arid_m_o             (fc_arid_expslv1_axis   ),
  .araddr_m_o           (fc_araddr_expslv1_axis ),
  .arregion_m_o         (                       ),
  .arlen_m_o            (fc_arlen_expslv1_axis  ),
  .arsize_m_o           (fc_arsize_expslv1_axis ),
  .arburst_m_o          (fc_arburst_expslv1_axis),
  .arlock_m_o           (fc_arlock_expslv1_axis ),
  .arcache_m_o          (fc_arcache_expslv1_axis),
  .arprot_m_o           (fc_arprot_expslv1_axis ),
  .arqos_m_o            (fc_arqos_expslv1_axis  ),
  .aruser_m_o           (fc_aruser_expslv1_axis[1:0]),
  .arvalid_m_o          (fc_arvalid_expslv1_axis),
  .arready_m_i          (fc_arready_expslv1_axis),
  .armmusid_m_o         (fc_aruser_expslv1_axis[9:2]),

  .rid_m_i              (fc_rid_expslv1_axis   ),
  .rdata_m_i            (fc_rdata_expslv1_axis ),
  .rresp_m_i            (fc_rresp_expslv1_axis ),
  .rlast_m_i            (fc_rlast_expslv1_axis ),
  .ruser_m_i            (fc_ruser_expslv1_axis ),
  .rvalid_m_i           (fc_rvalid_expslv1_axis),
  .rready_m_o           (fc_rready_expslv1_axis),

  .awakeup_m_o          (),  
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[13]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[13]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[13]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[13] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[9]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[9]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[9]),
  .pwr_qactive_o        (qactive_systop_base_internal[9]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s9),
  .tready_ds_i          (tready_dti_dn_s9),
  .tdata_ds_o           (tdata_dti_dn_s9),
  .tkeep_ds_o           (tkeep_dti_dn_s9),
  .tlast_ds_o           (tlast_dti_dn_s9),
  .tid_ds_o             (), // tid_dti_dn_s9),
  .twakeup_ds_o         (twakeup_dti_dn_s9),

  .tvalid_us_i          (tvalid_dti_up_s9),
  .tready_us_o          (tready_dti_up_s9),
  .tdata_us_i           (tdata_dti_up_s9),
  .tkeep_us_i           (tkeep_dti_up_s9),
  .tlast_us_i           (tlast_dti_up_s9),  
  .tdest_us_i           (4'ha), 
  .twakeup_us_i         (twakeup_dti_up_s9),

  .bypass_i             (fctrl_bypass)
);  

 
reg fc_awakeup_expmstr0_axim;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fc_awakeup_expmstr0_axim <= 1'b0;
  end
  else 
  begin
    fc_awakeup_expmstr0_axim <= fc_awvalid_expmstr0_axim | fc_arvalid_expmstr0_axim | fc_wvalid_expmstr0_axim;
  end
end

`include "firewall_f0_comp_global_cfg_sse710_expmst0.vh" 
firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_expmst0.vh"
  ) u_fc_11 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_expmstr0_axim),
  .awaddr_s_i           (fc_awaddr_expmstr0_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_expmstr0_axim),
  .awsize_s_i           (fc_awsize_expmstr0_axim),
  .awburst_s_i          (fc_awburst_expmstr0_axim),
  .awlock_s_i           (fc_awlock_expmstr0_axim),
  .awcache_s_i          (fc_awcache_expmstr0_axim),
  .awprot_s_i           (fc_awprot_expmstr0_axim),
  .awqos_s_i            (fc_awqos_expmstr0_axim),
  .awuser_s_i           (fc_awuser_expmstr0_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_expmstr0_axim),
  .awready_s_o          (fc_awready_expmstr0_axim),
  .awmmusid_s_i         (fc_awuser_expmstr0_axim[9:2]),

  .wdata_s_i            (fc_wdata_expmstr0_axim),
  .wstrb_s_i            (fc_wstrb_expmstr0_axim),
  .wlast_s_i            (fc_wlast_expmstr0_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_expmstr0_axim),
  .wready_s_o           (fc_wready_expmstr0_axim),

  .bid_s_o              (fc_bid_expmstr0_axim  ),
  .bresp_s_o            (fc_bresp_expmstr0_axim),
  .buser_s_o            (fc_buser_expmstr0_axim),
  .bvalid_s_o           (fc_bvalid_expmstr0_axim),
  .bready_s_i           (fc_bready_expmstr0_axim),

  .arid_s_i             (fc_arid_expmstr0_axim   ),
  .araddr_s_i           (fc_araddr_expmstr0_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_expmstr0_axim  ),
  .arsize_s_i           (fc_arsize_expmstr0_axim ),
  .arburst_s_i          (fc_arburst_expmstr0_axim),
  .arlock_s_i           (fc_arlock_expmstr0_axim ),
  .arcache_s_i          (fc_arcache_expmstr0_axim),
  .arprot_s_i           (fc_arprot_expmstr0_axim ),
  .arqos_s_i            (fc_arqos_expmstr0_axim  ),
  .aruser_s_i           (fc_aruser_expmstr0_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_expmstr0_axim),
  .arready_s_o          (fc_arready_expmstr0_axim),
  .armmusid_s_i         (fc_aruser_expmstr0_axim[9:2]),

  .rid_s_o              (fc_rid_expmstr0_axim   ),
  .rdata_s_o            (fc_rdata_expmstr0_axim ),
  .rresp_s_o            (fc_rresp_expmstr0_axim ),
  .rlast_s_o            (fc_rlast_expmstr0_axim ),
  .ruser_s_o            (fc_ruser_expmstr0_axim ),
  .rvalid_s_o           (fc_rvalid_expmstr0_axim),
  .rready_s_i           (fc_rready_expmstr0_axim),

  .awakeup_s_i          (fc_awakeup_expmstr0_axim),

  .awid_m_o             (awid_expmstr0_axim   ),
  .awaddr_m_o           (awaddr_expmstr0_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_expmstr0_axim  ),
  .awsize_m_o           (awsize_expmstr0_axim ),
  .awburst_m_o          (awburst_expmstr0_axim),
  .awlock_m_o           (awlock_expmstr0_axim ),
  .awcache_m_o          (awcache_expmstr0_axim),
  .awprot_m_o           (awprot_expmstr0_axim ),
  .awqos_m_o            (awqos_expmstr0_axim  ),
  .awuser_m_o           (awuser_expmstr0_axim[1:0]),
  .awvalid_m_o          (awvalid_expmstr0_axim),
  .awready_m_i          (awready_expmstr0_axim),
  .awmmusid_m_o         (awuser_expmstr0_axim[9:2]),

  .wdata_m_o            (wdata_expmstr0_axim ),
  .wstrb_m_o            (wstrb_expmstr0_axim ),
  .wlast_m_o            (wlast_expmstr0_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_expmstr0_axim),
  .wready_m_i           (wready_expmstr0_axim),

  .bid_m_i              (bid_expmstr0_axim   ),
  .bresp_m_i            (bresp_expmstr0_axim ),
  .buser_m_i            (1'b0),
  .bvalid_m_i           (bvalid_expmstr0_axim),
  .bready_m_o           (bready_expmstr0_axim),

  .arid_m_o             (arid_expmstr0_axim   ),
  .araddr_m_o           (araddr_expmstr0_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_expmstr0_axim  ),
  .arsize_m_o           (arsize_expmstr0_axim ),
  .arburst_m_o          (arburst_expmstr0_axim),
  .arlock_m_o           (arlock_expmstr0_axim ),
  .arcache_m_o          (arcache_expmstr0_axim),
  .arprot_m_o           (arprot_expmstr0_axim ),
  .arqos_m_o            (arqos_expmstr0_axim  ),
  .aruser_m_o           (aruser_expmstr0_axim[1:0]),
  .arvalid_m_o          (arvalid_expmstr0_axim),
  .arready_m_i          (arready_expmstr0_axim),
  .armmusid_m_o         (aruser_expmstr0_axim[9:2]),

  .rid_m_i              (rid_expmstr0_axim   ),
  .rdata_m_i            (rdata_expmstr0_axim ),
  .rresp_m_i            (rresp_expmstr0_axim ),
  .rlast_m_i            (rlast_expmstr0_axim ),
  .ruser_m_i            (1'b0),
  .rvalid_m_i           (rvalid_expmstr0_axim),
  .rready_m_o           (rready_expmstr0_axim),

  .awakeup_m_o          (awakeup_expmstr0_axim),
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[14]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[14]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[14]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[14] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[10]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[10]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[10]),
  .pwr_qactive_o        (qactive_systop_base_internal[10]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s10),
  .tready_ds_i          (tready_dti_dn_s10),
  .tdata_ds_o           (tdata_dti_dn_s10),
  .tkeep_ds_o           (tkeep_dti_dn_s10),
  .tlast_ds_o           (tlast_dti_dn_s10),
  .tid_ds_o             (), // tid_dti_dn_s10),
  .twakeup_ds_o         (twakeup_dti_dn_s10),

  .tvalid_us_i          (tvalid_dti_up_s10),
  .tready_us_o          (tready_dti_up_s10),
  .tdata_us_i           (tdata_dti_up_s10),  
  .tkeep_us_i           (tkeep_dti_up_s10),  
  .tlast_us_i           (tlast_dti_up_s10),  
  .tdest_us_i           (4'hb), 
  .twakeup_us_i         (twakeup_dti_up_s10),

  .bypass_i             (fctrl_bypass)
);
 
reg fc_awakeup_expmstr1_axim;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fc_awakeup_expmstr1_axim <= 1'b0;
  end
  else 
  begin
    fc_awakeup_expmstr1_axim <= fc_awvalid_expmstr1_axim | fc_arvalid_expmstr1_axim | fc_wvalid_expmstr1_axim;
  end
end

`include "firewall_f0_comp_global_cfg_sse710_expmst1.vh" 
firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_expmst1.vh"
  ) u_fc_12 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_expmstr1_axim),
  .awaddr_s_i           (fc_awaddr_expmstr1_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_expmstr1_axim),
  .awsize_s_i           (fc_awsize_expmstr1_axim),
  .awburst_s_i          (fc_awburst_expmstr1_axim),
  .awlock_s_i           (fc_awlock_expmstr1_axim),
  .awcache_s_i          (fc_awcache_expmstr1_axim),
  .awprot_s_i           (fc_awprot_expmstr1_axim),
  .awqos_s_i            (fc_awqos_expmstr1_axim),
  .awuser_s_i           (fc_awuser_expmstr1_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_expmstr1_axim),
  .awready_s_o          (fc_awready_expmstr1_axim),
  .awmmusid_s_i         (fc_awuser_expmstr1_axim[9:2]),

  .wdata_s_i            (fc_wdata_expmstr1_axim),
  .wstrb_s_i            (fc_wstrb_expmstr1_axim),
  .wlast_s_i            (fc_wlast_expmstr1_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_expmstr1_axim),
  .wready_s_o           (fc_wready_expmstr1_axim),

  .bid_s_o              (fc_bid_expmstr1_axim  ),
  .bresp_s_o            (fc_bresp_expmstr1_axim),
  .buser_s_o            (fc_buser_expmstr1_axim),
  .bvalid_s_o           (fc_bvalid_expmstr1_axim),
  .bready_s_i           (fc_bready_expmstr1_axim),

  .arid_s_i             (fc_arid_expmstr1_axim   ),
  .araddr_s_i           (fc_araddr_expmstr1_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_expmstr1_axim  ),
  .arsize_s_i           (fc_arsize_expmstr1_axim ),
  .arburst_s_i          (fc_arburst_expmstr1_axim),
  .arlock_s_i           (fc_arlock_expmstr1_axim ),
  .arcache_s_i          (fc_arcache_expmstr1_axim),
  .arprot_s_i           (fc_arprot_expmstr1_axim ),
  .arqos_s_i            (fc_arqos_expmstr1_axim  ),
  .aruser_s_i           (fc_aruser_expmstr1_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_expmstr1_axim),
  .arready_s_o          (fc_arready_expmstr1_axim),
  .armmusid_s_i         (fc_aruser_expmstr1_axim[9:2]),

  .rid_s_o              (fc_rid_expmstr1_axim   ),
  .rdata_s_o            (fc_rdata_expmstr1_axim ),
  .rresp_s_o            (fc_rresp_expmstr1_axim ),
  .rlast_s_o            (fc_rlast_expmstr1_axim ),
  .ruser_s_o            (fc_ruser_expmstr1_axim ),
  .rvalid_s_o           (fc_rvalid_expmstr1_axim),
  .rready_s_i           (fc_rready_expmstr1_axim),

  .awakeup_s_i          (fc_awakeup_expmstr1_axim),

  .awid_m_o             (awid_expmstr1_axim   ),
  .awaddr_m_o           (awaddr_expmstr1_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_expmstr1_axim  ),
  .awsize_m_o           (awsize_expmstr1_axim ),
  .awburst_m_o          (awburst_expmstr1_axim),
  .awlock_m_o           (awlock_expmstr1_axim ),
  .awcache_m_o          (awcache_expmstr1_axim),
  .awprot_m_o           (awprot_expmstr1_axim ),
  .awqos_m_o            (awqos_expmstr1_axim  ),
  .awuser_m_o           (awuser_expmstr1_axim[1:0]),
  .awvalid_m_o          (awvalid_expmstr1_axim),
  .awready_m_i          (awready_expmstr1_axim),
  .awmmusid_m_o         (awuser_expmstr1_axim[9:2]),

  .wdata_m_o            (wdata_expmstr1_axim ),
  .wstrb_m_o            (wstrb_expmstr1_axim ),
  .wlast_m_o            (wlast_expmstr1_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_expmstr1_axim),
  .wready_m_i           (wready_expmstr1_axim),

  .bid_m_i              (bid_expmstr1_axim   ),
  .bresp_m_i            (bresp_expmstr1_axim ),
  .buser_m_i            (1'b0),
  .bvalid_m_i           (bvalid_expmstr1_axim),
  .bready_m_o           (bready_expmstr1_axim),

  .arid_m_o             (arid_expmstr1_axim   ),
  .araddr_m_o           (araddr_expmstr1_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_expmstr1_axim  ),
  .arsize_m_o           (arsize_expmstr1_axim ),
  .arburst_m_o          (arburst_expmstr1_axim),
  .arlock_m_o           (arlock_expmstr1_axim ),
  .arcache_m_o          (arcache_expmstr1_axim),
  .arprot_m_o           (arprot_expmstr1_axim ),
  .arqos_m_o            (arqos_expmstr1_axim  ),
  .aruser_m_o           (aruser_expmstr1_axim[1:0]),
  .arvalid_m_o          (arvalid_expmstr1_axim),
  .arready_m_i          (arready_expmstr1_axim),
  .armmusid_m_o         (aruser_expmstr1_axim[9:2]),

  .rid_m_i              (rid_expmstr1_axim   ),
  .rdata_m_i            (rdata_expmstr1_axim ),
  .rresp_m_i            (rresp_expmstr1_axim ),
  .rlast_m_i            (rlast_expmstr1_axim ),
  .ruser_m_i            (1'b0),
  .rvalid_m_i           (rvalid_expmstr1_axim),
  .rready_m_o           (rready_expmstr1_axim),

  .awakeup_m_o          (awakeup_expmstr1_axim),
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[15]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[15]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[15]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[15] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[11]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[11]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[11]),
  .pwr_qactive_o        (qactive_systop_base_internal[11]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s11),
  .tready_ds_i          (tready_dti_dn_s11),
  .tdata_ds_o           (tdata_dti_dn_s11),
  .tkeep_ds_o           (tkeep_dti_dn_s11),
  .tlast_ds_o           (tlast_dti_dn_s11),
  .tid_ds_o             (), // tid_dti_dn_s11),
  .twakeup_ds_o         (twakeup_dti_dn_s11),

  .tvalid_us_i          (tvalid_dti_up_s11),
  .tready_us_o          (tready_dti_up_s11),
  .tdata_us_i           (tdata_dti_up_s11),  
  .tkeep_us_i           (tkeep_dti_up_s11),  
  .tlast_us_i           (tlast_dti_up_s11),  
  .tdest_us_i           (4'hc), 
  .twakeup_us_i         (twakeup_dti_up_s11),

  .bypass_i             (fctrl_bypass)
);


reg fc_awakeup_ocvm_axim;
always @(posedge aclk or negedge aresetn)
begin
  if (~aresetn)
  begin
    fc_awakeup_ocvm_axim <= 1'b0;
  end
  else 
  begin
    fc_awakeup_ocvm_axim <= fc_awvalid_ocvm_axim | fc_arvalid_ocvm_axim  | fc_wvalid_ocvm_axim;
  end
end
`include "firewall_f0_comp_global_cfg_sse710_ocvm.vh" 

firewall_f0_comp #(
 `include "firewall_f0_comp_cfg_sse710_ocvm.vh"
) u_fc_13 (
  .clk                  (aclk),
  .reset_n              (aresetn),

  .awid_s_i             (fc_awid_ocvm_axim),
  .awaddr_s_i           (fc_awaddr_ocvm_axim),
  .awregion_s_i         (4'h0),
  .awlen_s_i            (fc_awlen_ocvm_axim),
  .awsize_s_i           (fc_awsize_ocvm_axim),
  .awburst_s_i          (fc_awburst_ocvm_axim),
  .awlock_s_i           (fc_awlock_ocvm_axim),
  .awcache_s_i          (fc_awcache_ocvm_axim),
  .awprot_s_i           (fc_awprot_ocvm_axim),
  .awqos_s_i            (fc_awqos_ocvm_axim),
  .awuser_s_i           (fc_awuser_ocvm_axim[1:0]),
  .awvalid_s_i          (fc_awvalid_ocvm_axim),
  .awready_s_o          (fc_awready_ocvm_axim),
  .awmmusid_s_i         (fc_awuser_ocvm_axim[9:2]),

  .wdata_s_i            (fc_wdata_ocvm_axim),
  .wstrb_s_i            (fc_wstrb_ocvm_axim),
  .wlast_s_i            (fc_wlast_ocvm_axim),
  .wuser_s_i            (1'b0),
  .wvalid_s_i           (fc_wvalid_ocvm_axim),
  .wready_s_o           (fc_wready_ocvm_axim),

  .bid_s_o              (fc_bid_ocvm_axim  ),
  .bresp_s_o            (fc_bresp_ocvm_axim),
  .buser_s_o            (fc_buser_ocvm_axim),
  .bvalid_s_o           (fc_bvalid_ocvm_axim),
  .bready_s_i           (fc_bready_ocvm_axim),

  .arid_s_i             (fc_arid_ocvm_axim   ),
  .araddr_s_i           (fc_araddr_ocvm_axim ),
  .arregion_s_i         (4'h0),
  .arlen_s_i            (fc_arlen_ocvm_axim  ),
  .arsize_s_i           (fc_arsize_ocvm_axim ),
  .arburst_s_i          (fc_arburst_ocvm_axim),
  .arlock_s_i           (fc_arlock_ocvm_axim ),
  .arcache_s_i          (fc_arcache_ocvm_axim),
  .arprot_s_i           (fc_arprot_ocvm_axim ),
  .arqos_s_i            (fc_arqos_ocvm_axim  ),
  .aruser_s_i           (fc_aruser_ocvm_axim[1:0]),
  .arvalid_s_i          (fc_arvalid_ocvm_axim),
  .arready_s_o          (fc_arready_ocvm_axim),
  .armmusid_s_i         (fc_aruser_ocvm_axim[9:2]),

  .rid_s_o              (fc_rid_ocvm_axim   ),
  .rdata_s_o            (fc_rdata_ocvm_axim ),
  .rresp_s_o            (fc_rresp_ocvm_axim ),
  .rlast_s_o            (fc_rlast_ocvm_axim ),
  .ruser_s_o            (fc_ruser_ocvm_axim ),
  .rvalid_s_o           (fc_rvalid_ocvm_axim),
  .rready_s_i           (fc_rready_ocvm_axim),

  .awakeup_s_i          (fc_awakeup_ocvm_axim),

  .awid_m_o             (awid_ocvm_axim   ),
  .awaddr_m_o           (awaddr_ocvm_axim ),
  .awregion_m_o         (),
  .awlen_m_o            (awlen_ocvm_axim  ),
  .awsize_m_o           (awsize_ocvm_axim ),
  .awburst_m_o          (awburst_ocvm_axim),
  .awlock_m_o           (awlock_ocvm_axim ),
  .awcache_m_o          (awcache_ocvm_axim),
  .awprot_m_o           (awprot_ocvm_axim ),
  .awqos_m_o            (awqos_ocvm_axim  ),
  .awuser_m_o           (awuser_ocvm_axim[1:0]),
  .awvalid_m_o          (awvalid_ocvm_axim),
  .awready_m_i          (awready_ocvm_axim),
  .awmmusid_m_o         (awuser_ocvm_axim[9:2]),

  .wdata_m_o            (wdata_ocvm_axim ),
  .wstrb_m_o            (wstrb_ocvm_axim ),
  .wlast_m_o            (wlast_ocvm_axim ),
  .wuser_m_o            (),
  .wvalid_m_o           (wvalid_ocvm_axim),
  .wready_m_i           (wready_ocvm_axim),

  .bid_m_i              (bid_ocvm_axim   ),
  .bresp_m_i            (bresp_ocvm_axim ),
  .buser_m_i            (1'b0 ),
  .bvalid_m_i           (bvalid_ocvm_axim),
  .bready_m_o           (bready_ocvm_axim),

  .arid_m_o             (arid_ocvm_axim   ),
  .araddr_m_o           (araddr_ocvm_axim ),
  .arregion_m_o         (),
  .arlen_m_o            (arlen_ocvm_axim  ),
  .arsize_m_o           (arsize_ocvm_axim ),
  .arburst_m_o          (arburst_ocvm_axim),
  .arlock_m_o           (arlock_ocvm_axim ),
  .arcache_m_o          (arcache_ocvm_axim),
  .arprot_m_o           (arprot_ocvm_axim ),
  .arqos_m_o            (arqos_ocvm_axim  ),
  .aruser_m_o           (aruser_ocvm_axim[1:0]),
  .arvalid_m_o          (arvalid_ocvm_axim),
  .arready_m_i          (arready_ocvm_axim),
  .armmusid_m_o         (aruser_ocvm_axim[9:2]),

  .rid_m_i              (rid_ocvm_axim   ),
  .rdata_m_i            (rdata_ocvm_axim ),
  .rresp_m_i            (rresp_ocvm_axim ),
  .rlast_m_i            (rlast_ocvm_axim ),
  .ruser_m_i            (1'b0 ),
  .rvalid_m_i           (rvalid_ocvm_axim),
  .rready_m_o           (rready_ocvm_axim),

  .awakeup_m_o          (awakeup_ocvm_axim),
  
  .dftcgen              (dftcgen),
  
  .clk_qreqn_i          (qch_exp_aclk_devqreqn[16]   ),
  .clk_qacceptn_o       (qch_exp_aclk_devqacceptn[16]),
  .clk_qdeny_o          (qch_exp_aclk_devqdeny[16]   ),
  .clk_qactive_o        (qch_exp_aclk_devqactive[16] ),

  .pwr_qreqn_i          (qreqn_systop_base_internal[12]),
  .pwr_qacceptn_o       (qacceptn_systop_base_internal[12]),
  .pwr_qdeny_o          (qdeny_systop_base_internal[12]),
  .pwr_qactive_o        (qactive_systop_base_internal[12]),

  
  .tvalid_ds_o          (tvalid_dti_dn_s12),
  .tready_ds_i          (tready_dti_dn_s12),
  .tdata_ds_o           (tdata_dti_dn_s12),
  .tkeep_ds_o           (tkeep_dti_dn_s12),
  .tlast_ds_o           (tlast_dti_dn_s12),
  .tid_ds_o             (), // tid_dti_dn_s12),
  .twakeup_ds_o         (twakeup_dti_dn_s12),

  .tvalid_us_i          (tvalid_dti_up_s12),
  .tready_us_o          (tready_dti_up_s12),
  .tdata_us_i           (tdata_dti_up_s12),
  .tkeep_us_i           (tkeep_dti_up_s12),
  .tlast_us_i           (tlast_dti_up_s12),
  .tdest_us_i           (4'hd), 
  .twakeup_us_i         (twakeup_dti_up_s12),

  .bypass_i             (fctrl_bypass)
);


sse710_bas_ic_top #(
  .DATA_WIDTH  (32),
  .ID_WIDTH    (4)
) u_fc_ic (
  .aclk               (aclk),
  .aresetn            (aresetn),

  .qactive_cg0    (qch_exp_aclk_devqactive[17] ),
  .qreqn_cg0      (qch_exp_aclk_devqreqn[17]   ),
  .qacceptn_cg0   (qch_exp_aclk_devqacceptn[17]),
  .qdeny_cg0      (qch_exp_aclk_devqdeny[17]   ),

  .qactive_cg1    (qch_exp_aclk_devqactive[18] ),
  .qreqn_cg1      (qch_exp_aclk_devqreqn[18]   ),
  .qacceptn_cg1   (qch_exp_aclk_devqacceptn[18]),
  .qdeny_cg1      (qch_exp_aclk_devqdeny[18]   ),

 
  .tvalid_dti_dn_s0           (tvalid_dti_dn_s0),
  .tready_dti_dn_s0           (tready_dti_dn_s0),
  .tdata_dti_dn_s0            (tdata_dti_dn_s0),
  .tkeep_dti_dn_s0            (tkeep_dti_dn_s0),
  .tid_dti_dn_s0              (4'h0), 
  .tlast_dti_dn_s0            (tlast_dti_dn_s0),

 
  .tvalid_dti_dn_s1           (tvalid_dti_dn_s1),
  .tready_dti_dn_s1           (tready_dti_dn_s1),
  .tdata_dti_dn_s1            (tdata_dti_dn_s1),
  .tkeep_dti_dn_s1            (tkeep_dti_dn_s1),
  .tid_dti_dn_s1              (4'h0), 
  .tlast_dti_dn_s1            (tlast_dti_dn_s1),

 
  .tvalid_dti_dn_s2           (tvalid_dti_dn_s2),
  .tready_dti_dn_s2           (tready_dti_dn_s2),
  .tdata_dti_dn_s2            (tdata_dti_dn_s2),
  .tkeep_dti_dn_s2            (tkeep_dti_dn_s2),
  .tid_dti_dn_s2              (4'h0), 
  .tlast_dti_dn_s2            (tlast_dti_dn_s2),

 
  .tvalid_dti_dn_s3           (tvalid_dti_dn_s3),
  .tready_dti_dn_s3           (tready_dti_dn_s3),
  .tdata_dti_dn_s3            (tdata_dti_dn_s3),
  .tkeep_dti_dn_s3            (tkeep_dti_dn_s3),
  .tid_dti_dn_s3              (4'h0), 
  .tlast_dti_dn_s3            (tlast_dti_dn_s3),

 
  .tvalid_dti_dn_s4           (tvalid_dti_dn_s4),
  .tready_dti_dn_s4           (tready_dti_dn_s4),
  .tdata_dti_dn_s4            (tdata_dti_dn_s4),
  .tkeep_dti_dn_s4            (tkeep_dti_dn_s4),
  .tid_dti_dn_s4              (4'h0), 
  .tlast_dti_dn_s4            (tlast_dti_dn_s4),

 
  .tvalid_dti_dn_s5           (tvalid_dti_dn_s5),
  .tready_dti_dn_s5           (tready_dti_dn_s5),
  .tdata_dti_dn_s5            (tdata_dti_dn_s5),
  .tkeep_dti_dn_s5            (tkeep_dti_dn_s5),
  .tid_dti_dn_s5              (4'h0), 
  .tlast_dti_dn_s5            (tlast_dti_dn_s5),

 
  .tvalid_dti_dn_s6           (tvalid_dti_dn_s6),
  .tready_dti_dn_s6           (tready_dti_dn_s6),
  .tdata_dti_dn_s6            (tdata_dti_dn_s6),
  .tkeep_dti_dn_s6            (tkeep_dti_dn_s6),
  .tid_dti_dn_s6              (4'h0), 
  .tlast_dti_dn_s6            (tlast_dti_dn_s6),

 
  .tvalid_dti_dn_s7           (tvalid_dti_dn_s7),
  .tready_dti_dn_s7           (tready_dti_dn_s7),
  .tdata_dti_dn_s7            (tdata_dti_dn_s7),
  .tkeep_dti_dn_s7            (tkeep_dti_dn_s7),
  .tid_dti_dn_s7              (4'h0), 
  .tlast_dti_dn_s7            (tlast_dti_dn_s7),

 
  .tvalid_dti_dn_s8           (tvalid_dti_dn_s8),
  .tready_dti_dn_s8           (tready_dti_dn_s8),
  .tdata_dti_dn_s8            (tdata_dti_dn_s8),
  .tkeep_dti_dn_s8            (tkeep_dti_dn_s8),
  .tid_dti_dn_s8              (4'h0), 
  .tlast_dti_dn_s8            (tlast_dti_dn_s8),

 
  .tvalid_dti_dn_s9           (tvalid_dti_dn_s9),
  .tready_dti_dn_s9           (tready_dti_dn_s9),
  .tdata_dti_dn_s9            (tdata_dti_dn_s9),
  .tkeep_dti_dn_s9            (tkeep_dti_dn_s9),
  .tid_dti_dn_s9              (4'h0), 
  .tlast_dti_dn_s9            (tlast_dti_dn_s9),

 
  .tvalid_dti_dn_s10           (tvalid_dti_dn_s10),
  .tready_dti_dn_s10           (tready_dti_dn_s10),
  .tdata_dti_dn_s10            (tdata_dti_dn_s10),
  .tkeep_dti_dn_s10            (tkeep_dti_dn_s10),
  .tid_dti_dn_s10              (4'h0), 
  .tlast_dti_dn_s10            (tlast_dti_dn_s10),

 
  .tvalid_dti_dn_s11           (tvalid_dti_dn_s11),
  .tready_dti_dn_s11           (tready_dti_dn_s11),
  .tdata_dti_dn_s11            (tdata_dti_dn_s11),
  .tkeep_dti_dn_s11            (tkeep_dti_dn_s11),
  .tid_dti_dn_s11              (4'h0), 
  .tlast_dti_dn_s11            (tlast_dti_dn_s11),

 
  .tvalid_dti_dn_s12           (tvalid_dti_dn_s12),
  .tready_dti_dn_s12           (tready_dti_dn_s12),
  .tdata_dti_dn_s12            (tdata_dti_dn_s12),
  .tkeep_dti_dn_s12            (tkeep_dti_dn_s12),
  .tid_dti_dn_s12              (4'h0), 
  .tlast_dti_dn_s12            (tlast_dti_dn_s12),

  .tvalid_dti_dn_m           (tvalid_dti_dn_m),
  .tready_dti_dn_m           (tready_dti_dn_m),
  .tdata_dti_dn_m            (tdata_dti_dn_m),
  .tkeep_dti_dn_m            (tkeep_dti_dn_m),
  .tid_dti_dn_m              (tid_dti_dn_m),
  .tlast_dti_dn_m            (tlast_dti_dn_m),

 
  .tvalid_dti_up_s0            (tvalid_dti_up_s0),
  .tready_dti_up_s0            (tready_dti_up_s0),
  .tdata_dti_up_s0             (tdata_dti_up_s0 ),
  .tkeep_dti_up_s0             (tkeep_dti_up_s0 ),
  .tdest_dti_up_s0             (), 
  .tlast_dti_up_s0             (tlast_dti_up_s0 ),

 
  .tvalid_dti_up_s1            (tvalid_dti_up_s1),
  .tready_dti_up_s1            (tready_dti_up_s1),
  .tdata_dti_up_s1             (tdata_dti_up_s1 ),
  .tkeep_dti_up_s1             (tkeep_dti_up_s1 ),
  .tdest_dti_up_s1             (), 
  .tlast_dti_up_s1             (tlast_dti_up_s1 ),

 
  .tvalid_dti_up_s2            (tvalid_dti_up_s2),
  .tready_dti_up_s2            (tready_dti_up_s2),
  .tdata_dti_up_s2             (tdata_dti_up_s2 ),
  .tkeep_dti_up_s2             (tkeep_dti_up_s2 ),
  .tdest_dti_up_s2             (), 
  .tlast_dti_up_s2             (tlast_dti_up_s2 ),

 
  .tvalid_dti_up_s3            (tvalid_dti_up_s3),
  .tready_dti_up_s3            (tready_dti_up_s3),
  .tdata_dti_up_s3             (tdata_dti_up_s3 ),
  .tkeep_dti_up_s3             (tkeep_dti_up_s3 ),
  .tdest_dti_up_s3             (), 
  .tlast_dti_up_s3             (tlast_dti_up_s3 ),

 
  .tvalid_dti_up_s4            (tvalid_dti_up_s4),
  .tready_dti_up_s4            (tready_dti_up_s4),
  .tdata_dti_up_s4             (tdata_dti_up_s4 ),
  .tkeep_dti_up_s4             (tkeep_dti_up_s4 ),
  .tdest_dti_up_s4             (), 
  .tlast_dti_up_s4             (tlast_dti_up_s4 ),

 
  .tvalid_dti_up_s5            (tvalid_dti_up_s5),
  .tready_dti_up_s5            (tready_dti_up_s5),
  .tdata_dti_up_s5             (tdata_dti_up_s5 ),
  .tkeep_dti_up_s5             (tkeep_dti_up_s5 ),
  .tdest_dti_up_s5             (), 
  .tlast_dti_up_s5             (tlast_dti_up_s5 ),

 
  .tvalid_dti_up_s6            (tvalid_dti_up_s6),
  .tready_dti_up_s6            (tready_dti_up_s6),
  .tdata_dti_up_s6             (tdata_dti_up_s6 ),
  .tkeep_dti_up_s6             (tkeep_dti_up_s6 ),
  .tdest_dti_up_s6             (), 
  .tlast_dti_up_s6             (tlast_dti_up_s6 ),

 
  .tvalid_dti_up_s7            (tvalid_dti_up_s7),
  .tready_dti_up_s7            (tready_dti_up_s7),
  .tdata_dti_up_s7             (tdata_dti_up_s7 ),
  .tkeep_dti_up_s7             (tkeep_dti_up_s7 ),
  .tdest_dti_up_s7             (), 
  .tlast_dti_up_s7             (tlast_dti_up_s7 ),

 
  .tvalid_dti_up_s8            (tvalid_dti_up_s8),
  .tready_dti_up_s8            (tready_dti_up_s8),
  .tdata_dti_up_s8             (tdata_dti_up_s8 ),
  .tkeep_dti_up_s8             (tkeep_dti_up_s8 ),
  .tdest_dti_up_s8             (), 
  .tlast_dti_up_s8             (tlast_dti_up_s8 ),

 
  .tvalid_dti_up_s9            (tvalid_dti_up_s9),
  .tready_dti_up_s9            (tready_dti_up_s9),
  .tdata_dti_up_s9             (tdata_dti_up_s9 ),
  .tkeep_dti_up_s9             (tkeep_dti_up_s9 ),
  .tdest_dti_up_s9             (), 
  .tlast_dti_up_s9             (tlast_dti_up_s9 ),

 
  .tvalid_dti_up_s10            (tvalid_dti_up_s10),
  .tready_dti_up_s10            (tready_dti_up_s10),
  .tdata_dti_up_s10             (tdata_dti_up_s10 ),
  .tkeep_dti_up_s10             (tkeep_dti_up_s10 ),
  .tdest_dti_up_s10             (), 
  .tlast_dti_up_s10             (tlast_dti_up_s10 ),

 
  .tvalid_dti_up_s11            (tvalid_dti_up_s11),
  .tready_dti_up_s11            (tready_dti_up_s11),
  .tdata_dti_up_s11             (tdata_dti_up_s11 ),
  .tkeep_dti_up_s11             (tkeep_dti_up_s11 ),
  .tdest_dti_up_s11             (), 
  .tlast_dti_up_s11             (tlast_dti_up_s11 ),

 
  .tvalid_dti_up_s12            (tvalid_dti_up_s12),
  .tready_dti_up_s12            (tready_dti_up_s12),
  .tdata_dti_up_s12             (tdata_dti_up_s12 ),
  .tkeep_dti_up_s12             (tkeep_dti_up_s12 ),
  .tdest_dti_up_s12             (), 
  .tlast_dti_up_s12             (tlast_dti_up_s12 ),

  .tvalid_dti_up_m              (tvalid_dti_up_m),
  .tready_dti_up_m              (tready_dti_up_m),
  .tdata_dti_up_m               (tdata_dti_up_m),
  .tkeep_dti_up_m               (tkeep_dti_up_m),
  .tdest_dti_up_m               (tdest_dti_up_m),
  .tlast_dti_up_m               (tlast_dti_up_m),

 
  .twakeup_dti_dn_s0            (twakeup_dti_dn_s0 ),
 
  .twakeup_dti_dn_s1            (twakeup_dti_dn_s1 ),
 
  .twakeup_dti_dn_s2            (twakeup_dti_dn_s2 ),
 
  .twakeup_dti_dn_s3            (twakeup_dti_dn_s3 ),
 
  .twakeup_dti_dn_s4            (twakeup_dti_dn_s4 ),
 
  .twakeup_dti_dn_s5            (twakeup_dti_dn_s5 ),
 
  .twakeup_dti_dn_s6            (twakeup_dti_dn_s6 ),
 
  .twakeup_dti_dn_s7            (twakeup_dti_dn_s7 ),
 
  .twakeup_dti_dn_s8            (twakeup_dti_dn_s8 ),
 
  .twakeup_dti_dn_s9            (twakeup_dti_dn_s9 ),
 
  .twakeup_dti_dn_s10            (twakeup_dti_dn_s10 ),
 
  .twakeup_dti_dn_s11            (twakeup_dti_dn_s11 ),
 
  .twakeup_dti_dn_s12            (twakeup_dti_dn_s12 ),
  .twakeup_dti_dn_m             (twakeup_dti_dn_m),

 
  .twakeup_dti_up_s0            (twakeup_dti_up_s0 ),
 
  .twakeup_dti_up_s1            (twakeup_dti_up_s1 ),
 
  .twakeup_dti_up_s2            (twakeup_dti_up_s2 ),
 
  .twakeup_dti_up_s3            (twakeup_dti_up_s3 ),
 
  .twakeup_dti_up_s4            (twakeup_dti_up_s4 ),
 
  .twakeup_dti_up_s5            (twakeup_dti_up_s5 ),
 
  .twakeup_dti_up_s6            (twakeup_dti_up_s6 ),
 
  .twakeup_dti_up_s7            (twakeup_dti_up_s7 ),
 
  .twakeup_dti_up_s8            (twakeup_dti_up_s8 ),
 
  .twakeup_dti_up_s9            (twakeup_dti_up_s9 ),
 
  .twakeup_dti_up_s10            (twakeup_dti_up_s10 ),
 
  .twakeup_dti_up_s11            (twakeup_dti_up_s11 ),
 
  .twakeup_dti_up_s12            (twakeup_dti_up_s12 ),
  .twakeup_dti_up_m             (twakeup_dti_up_m)
);

pck600_lpd_q   #(
  .SEQUENCER        (0), 
  .NUM_QCHL         (19), 
  .CTRL_Q_CH_SYNC   (1), 
  .DEV_Q_CH_SYNC    (1), 
  .DEV_QACTIVE_SYNC (1), 
  .ACTIVE_DENY      (1)  
  )
u_base_aclk_lpdq
  (
  .clk             (aclk),
  .reset_n         (aresetn),
  
  .ctrl_qreqn_i    (aclk_qreqn),
  .ctrl_qacceptn_o (aclk_qacceptn),
  .ctrl_qdeny_o    (aclk_qdeny),
  .ctrl_qactive_o  (aclk_qactive),
  
  .dev_qreqn_o     (qch_exp_aclk_devqreqn   ),
  .dev_qacceptn_i  (qch_exp_aclk_devqacceptn),
  .dev_qdeny_i     (qch_exp_aclk_devqdeny   ),
  .dev_qactive_i   (qch_exp_aclk_devqactive ),
  
  .clk_qactive_o   (),
  .dftcgen         (dftcgen)
);


endmodule

