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

module pc_sysctrl_f0_systop # (
  parameter AXI4S_ID_WIDTH          = 4,
  parameter FW2SYSTOP_FIFO_DEPTH    = 4,
  parameter FW_AXI_ADDR_WIDTH       = 32,
  parameter FW_AXI_DATA_WIDTH       = 32,
  parameter FW_AXI_AWID_WIDTH       = 10,
  parameter FW_AXI_ARID_WIDTH       = 10,
  parameter FW_AXI_AWUSER_WIDTH     = 10,
  parameter FW_AXI_WUSER_WIDTH      = 0,
  parameter FW_AXI_BUSER_WIDTH      = 0,
  parameter FW_AXI_ARUSER_WIDTH     = 10,
  parameter FW_AXI_RUSER_WIDTH      = 0,
  parameter FW_AXI_AW_FIFO_DEPTH    = 4,
  parameter FW_AXI_W_FIFO_DEPTH     = 6,
  parameter FW_AXI_B_FIFO_DEPTH     = 2,
  parameter FW_AXI_AR_FIFO_DEPTH    = 4,
  parameter FW_AXI_R_FIFO_DEPTH     = 6,
  parameter FW_AXI_AW_PAYLOAD_WIDTH = 20,
  parameter FW_AXI_W_PAYLOAD_WIDTH  = 20,
  parameter FW_AXI_B_PAYLOAD_WIDTH  = 20,
  parameter FW_AXI_AR_PAYLOAD_WIDTH = 20,
  parameter FW_AXI_R_PAYLOAD_WIDTH  = 20,
  parameter FW2SYSTOP_UP_PAYLD_WIDTH = ((payload_width_fn(1,32,0,4,AXI4S_ID_WIDTH,AXI4S_ID_WIDTH,0)>0)? ((payload_width_fn(1,32,0,4,AXI4S_ID_WIDTH,AXI4S_ID_WIDTH,0)*FW2SYSTOP_FIFO_DEPTH)):0)
 
)(
input  wire            aclk,
input  wire            aresetn,

output wire            periph_async_req,
output wire  [67:0]    periph_async_req_payload,
input  wire  [32:0]    periph_async_resp_payload,
input  wire            periph_async_ack,

output wire            uart_async_req,
output wire  [52:0]    uart_async_req_payload,
input  wire  [32:0]    uart_async_resp_payload,
input  wire            uart_async_ack,

output wire            bootreg_async_req,
output wire  [61:0]    bootreg_async_req_payload,
input  wire  [32:0]    bootreg_async_resp_payload,
input  wire            bootreg_async_ack,

input  wire            psel_periph,
input  wire            penable_periph,
input  wire [27:0]     paddr_periph,
input  wire            pwrite_periph,
input  wire [31:0]     pwdata_periph,
input  wire [3:0]      pstrb_periph,
input  wire [2:0]      pprot_periph,
output wire [31:0]     prdata_periph,
output wire            pready_periph,
output wire            pslverr_periph,

input  wire            psel_uart,
input  wire            penable_uart,
input  wire [16:0]     paddr_uart,
input  wire            pwrite_uart,
input  wire [31:0]     pwdata_uart,
input  wire [3:0]      pstrb_uart,
input  wire [2:0]      pprot_uart,
output wire [31:0]     prdata_uart,
output wire            pready_uart,
output wire            pslverr_uart,


input  wire [9:0]  awid_firewall_axim,
input  wire [31:0] awaddr_firewall_axim,
input  wire [7:0]  awlen_firewall_axim,
input  wire [2:0]  awsize_firewall_axim,
input  wire [1:0]  awburst_firewall_axim,
input  wire        awlock_firewall_axim,
input  wire [3:0]  awcache_firewall_axim,
input  wire [2:0]  awprot_firewall_axim,
input  wire        awvalid_firewall_axim,
output wire        awready_firewall_axim,
input  wire [31:0] wdata_firewall_axim,
input  wire [3:0]  wstrb_firewall_axim,
input  wire        wlast_firewall_axim,
input  wire        wvalid_firewall_axim,
output wire        wready_firewall_axim,
output wire [9:0]  bid_firewall_axim,
output wire [1:0]  bresp_firewall_axim,
output wire        bvalid_firewall_axim,
input  wire        bready_firewall_axim,
input  wire [9:0]  arid_firewall_axim,
input  wire [31:0] araddr_firewall_axim,
input  wire [7:0]  arlen_firewall_axim,
input  wire [2:0]  arsize_firewall_axim,
input  wire [1:0]  arburst_firewall_axim,
input  wire        arlock_firewall_axim,
input  wire [3:0]  arcache_firewall_axim,
input  wire [2:0]  arprot_firewall_axim,
input  wire        arvalid_firewall_axim,
output wire        arready_firewall_axim,
output wire [9:0]  rid_firewall_axim,
output wire [31:0] rdata_firewall_axim,
output wire [1:0]  rresp_firewall_axim,
output wire        rlast_firewall_axim,
output wire        rvalid_firewall_axim,
input  wire        rready_firewall_axim,
input  wire [9:0]  awuser_firewall_axim,
input  wire [9:0]  aruser_firewall_axim,
output wire        buser_firewall_axim,
output wire        ruser_firewall_axim,


output wire firewall_slvmustacceptreqn_async,
output wire firewall_slvcandenyreqn_async,
input  wire firewall_slvacceptn_async,
input  wire firewall_slvdeny_async,

output wire firewall_si_to_mi_wakeup_async,
input  wire firewall_mi_to_si_wakeup_async,

output wire [FW_AXI_AW_FIFO_DEPTH-1:0] firewall_aw_wr_ptr_async,
input  wire [FW_AXI_AW_FIFO_DEPTH-1:0] firewall_aw_rd_ptr_async,
output wire [FW_AXI_AW_PAYLOAD_WIDTH-1:0] firewall_aw_payld_async,

output wire [FW_AXI_W_FIFO_DEPTH-1:0] firewall_w_wr_ptr_async,
input  wire [FW_AXI_W_FIFO_DEPTH-1:0] firewall_w_rd_ptr_async,
output wire [FW_AXI_W_PAYLOAD_WIDTH-1:0] firewall_w_payld_async,

input  wire [FW_AXI_B_FIFO_DEPTH-1:0] firewall_b_wr_ptr_async,
output wire [FW_AXI_B_FIFO_DEPTH-1:0] firewall_b_rd_ptr_async,
input  wire [FW_AXI_B_PAYLOAD_WIDTH-1:0] firewall_b_payld_async,

output wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_wr_ptr_async,
input  wire [FW_AXI_AR_FIFO_DEPTH-1:0]    firewall_ar_rd_ptr_async,
output wire [FW_AXI_AR_PAYLOAD_WIDTH-1:0] firewall_ar_payld_async,

input  wire [FW_AXI_R_FIFO_DEPTH -1:0]   firewall_r_wr_ptr_async,
output wire [FW_AXI_R_FIFO_DEPTH -1:0]   firewall_r_rd_ptr_async,
input  wire [FW_AXI_R_PAYLOAD_WIDTH-1:0] firewall_r_payld_async,

input  wire  [9:0]     awid_bootreg_axim,
input  wire  [39:0]    awaddr_bootreg_axim,
input  wire  [7:0]     awlen_bootreg_axim,
input  wire  [2:0]     awsize_bootreg_axim,
input  wire  [1:0]     awburst_bootreg_axim,
input  wire            awlock_bootreg_axim,
input  wire  [3:0]     awcache_bootreg_axim,
input  wire  [2:0]     awprot_bootreg_axim,
input  wire            awvalid_bootreg_axim,
output wire            awready_bootreg_axim,
input  wire  [31:0]    wdata_bootreg_axim,
input  wire  [3:0]     wstrb_bootreg_axim,
input  wire            wlast_bootreg_axim,
input  wire            wvalid_bootreg_axim,
output wire            wready_bootreg_axim,
output wire  [9:0]     bid_bootreg_axim,
output wire  [1:0]     bresp_bootreg_axim,
output wire            bvalid_bootreg_axim,
input  wire            bready_bootreg_axim,
input  wire  [9:0]     arid_bootreg_axim,
input  wire  [39:0]    araddr_bootreg_axim,
input  wire  [7:0]     arlen_bootreg_axim,
input  wire  [2:0]     arsize_bootreg_axim,
input  wire  [1:0]     arburst_bootreg_axim,
input  wire            arlock_bootreg_axim,
input  wire  [3:0]     arcache_bootreg_axim,
input  wire  [2:0]     arprot_bootreg_axim,
input  wire            arvalid_bootreg_axim,
output wire            arready_bootreg_axim,
output wire  [9:0]     rid_bootreg_axim,
output wire  [31:0]    rdata_bootreg_axim,
output wire  [1:0]     rresp_bootreg_axim,
output wire            rlast_bootreg_axim,
output wire            rvalid_bootreg_axim,
input  wire            rready_bootreg_axim,
input  wire  [9:0]     awuser_bootreg_axim,
input  wire  [9:0]     aruser_bootreg_axim,

output wire                             fw2systop_dn_slvmustacceptreqn_async,
output wire                             fw2systop_dn_slvcandenyreqn_async,
input  wire                             fw2systop_dn_slvacceptn_async,
input  wire                             fw2systop_dn_slvdeny_async,
output wire                             fw2systop_dn_si_to_mi_wakeup_async,
input  wire                             fw2systop_dn_mi_to_si_wakeup_async,
output wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_wr_ptr_async,
input  wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_dn_rd_ptr_async,
output wire [((payload_width_fn(1,32,0,4,AXI4S_ID_WIDTH,AXI4S_ID_WIDTH,0)>0)?
             ((payload_width_fn(1,32,0,4,AXI4S_ID_WIDTH,AXI4S_ID_WIDTH,0)*FW2SYSTOP_FIFO_DEPTH)-1):
              0):0]                     fw2systop_dn_payld_async,

output wire                             fw2systop_dn_wakeupm_o,

output wire                             tvalid_dti_up_m,
input  wire                             tready_dti_up_m,
output wire [31:0]                      tdata_dti_up_m,
output wire [3:0]                       tkeep_dti_up_m,
output wire                             tlast_dti_up_m,
output wire [AXI4S_ID_WIDTH-1:0]        tdest_dti_up_m,

input  wire                             fw2systop_up_slvmustacceptreqn_async,
input  wire                             fw2systop_up_slvcandenyreqn_async,
output wire                             fw2systop_up_slvacceptn_async,
output wire                             fw2systop_up_slvdeny_async,
input  wire                             fw2systop_up_si_to_mi_wakeup_async,
output wire                             fw2systop_up_mi_to_si_wakeup_async,
input  wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_wr_ptr_async,
output wire [FW2SYSTOP_FIFO_DEPTH-1:0]  fw2systop_up_rd_ptr_async,
input  wire [FW2SYSTOP_UP_PAYLD_WIDTH-1:0] fw2systop_up_payld_async,


input  wire                             fw2systop_up_pwrq_permit_deny_sar_i,
input  wire                             firewall_adb_pwrq_permit_deny_sar_i,

input  wire                             fw2systop_up_wakeups_i,
input  wire                             firewall_adb_wakeups_i,

input  wire                       tvalid_dti_dn_m,
output wire                       tready_dti_dn_m,
input  wire [31:0]                tdata_dti_dn_m,
input  wire [3:0]                 tkeep_dti_dn_m,
input  wire                       tlast_dti_dn_m,
input  wire [AXI4S_ID_WIDTH-1:0]  tid_dti_dn_m,
input  wire  [6:0] aclk_qreqn,
output wire  [6:0] aclk_qacceptn,
output wire  [6:0] aclk_qdeny,
output wire  [6:0] aclk_qactive,

input  wire  [4:0] pwrqreqn,
output wire  [4:0] pwrqacceptn,
output wire  [4:0] pwrqdeny,
output wire  [4:0] pwrqactive,

input  wire        dftrstdisable,
input  wire        dftcgen
);

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

  reg pwakeup_periph;
  always @(posedge aclk or negedge aresetn)
  begin
    if(!aresetn)
        pwakeup_periph<=1'b0;
    else
        pwakeup_periph<=psel_periph;
  end  
  
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_adb_apb4_slv (
    .clk_s                      (aclk),
    .reset_s_n                  (aresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_periph),
    .penable_s                  (penable_periph),
    .paddr_s                    ({pstrb_periph,paddr_periph[27:0]}),
    .pwrite_s                   (pwrite_periph),
    .pwdata_s                   (pwdata_periph),
    .pprot_s                    (pprot_periph),
    .prdata_s                   (prdata_periph),
    .pready_s                   (pready_periph),
    .pslverr_s                  (pslverr_periph),
    .pwakeup_s                  (pwakeup_periph),
    
    .clk_s_qreq_n               (aclk_qreqn[0]),
    .clk_s_qaccept_n            (aclk_qacceptn[0]),
    .clk_s_qdeny                (aclk_qdeny[0]),
    .clk_s_qactive              (aclk_qactive[0]),
    
    .pwr_qreq_n                 (pwrqreqn[0]),
    .pwr_qaccept_n              (pwrqacceptn[0]),
    .pwr_qdeny                  (pwrqdeny[0]),
    .pwr_qactive                (pwrqactive[0]),
    
    .apb_async_req              (periph_async_req),
    .apb_async_req_payload      (periph_async_req_payload),
    .apb_async_resp_payload     (periph_async_resp_payload),
    .apb_async_ack              (periph_async_ack)
  );
  reg pwakeup_uart;
  always @(posedge aclk or negedge aresetn)
  begin
    if(!aresetn)
        pwakeup_uart<=1'b0;
    else
        pwakeup_uart<=psel_uart;
  end
  
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (17),
    .FF_SYNC_DEPTH       (2)
  ) u_adb_uart_apb4_slv (
    .clk_s                      (aclk),
    .reset_s_n                  (aresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_uart),
    .penable_s                  (penable_uart),
    .paddr_s                    (paddr_uart[16:0]),
    .pwrite_s                   (pwrite_uart),
    .pwdata_s                   (pwdata_uart),
    .pprot_s                    (pprot_uart),
    .prdata_s                   (prdata_uart),
    .pready_s                   (pready_uart),
    .pslverr_s                  (pslverr_uart),
    .pwakeup_s                  (pwakeup_uart),
    
    .clk_s_qreq_n               (aclk_qreqn[6]),
    .clk_s_qaccept_n            (aclk_qacceptn[6]),
    .clk_s_qdeny                (aclk_qdeny[6]),
    .clk_s_qactive              (aclk_qactive[6]),
    
    .pwr_qreq_n                 (pwrqreqn[4]),
    .pwr_qaccept_n              (pwrqacceptn[4]),
    .pwr_qdeny                  (pwrqdeny[4]),
    .pwr_qactive                (pwrqactive[4]),
    
    .apb_async_req              (uart_async_req),
    .apb_async_req_payload      (uart_async_req_payload),
    .apb_async_resp_payload     (uart_async_resp_payload),
    .apb_async_ack              (uart_async_ack)
  );

  sse710_boot_reg_f0_systop u_bootreg_systop
  (   
    .aclk                   (aclk),
    .aresetn                (aresetn),
    
    .qreqn_bootreg_aclk_nic     (aclk_qreqn[1]),
    .qacceptn_bootreg_aclk_nic  (aclk_qacceptn[1]),
    .qdeny_bootreg_aclk_nic     (aclk_qdeny[1]),
    .qactive_bootreg_aclk_nic   (aclk_qactive[1]),
    
    .qreqn_bootreg_aclk_adb     (aclk_qreqn[5]),
    .qacceptn_bootreg_aclk_adb  (aclk_qacceptn[5]),
    .qdeny_bootreg_aclk_adb     (aclk_qdeny[5]),
    .qactive_bootreg_aclk_adb   (aclk_qactive[5]),
    
    .awid_bootreg_axim      (awid_bootreg_axim),
    .awaddr_bootreg_axim    (awaddr_bootreg_axim),
    .awlen_bootreg_axim     (awlen_bootreg_axim),
    .awsize_bootreg_axim    (awsize_bootreg_axim),
    .awburst_bootreg_axim   (awburst_bootreg_axim),
    .awlock_bootreg_axim    (awlock_bootreg_axim),
    .awcache_bootreg_axim   (awcache_bootreg_axim),
    .awprot_bootreg_axim    (awprot_bootreg_axim),
    .awvalid_bootreg_axim   (awvalid_bootreg_axim),
    .awready_bootreg_axim   (awready_bootreg_axim),
    .awuser_bootreg_axim    (awuser_bootreg_axim),
    .wdata_bootreg_axim     (wdata_bootreg_axim),
    .wstrb_bootreg_axim     (wstrb_bootreg_axim),
    .wlast_bootreg_axim     (wlast_bootreg_axim),
    .wvalid_bootreg_axim    (wvalid_bootreg_axim),
    .wready_bootreg_axim    (wready_bootreg_axim),
    .bid_bootreg_axim       (bid_bootreg_axim),
    .bresp_bootreg_axim     (bresp_bootreg_axim),
    .bvalid_bootreg_axim    (bvalid_bootreg_axim),
    .bready_bootreg_axim    (bready_bootreg_axim),
    .arid_bootreg_axim      (arid_bootreg_axim),
    .araddr_bootreg_axim    (araddr_bootreg_axim),
    .arlen_bootreg_axim     (arlen_bootreg_axim),
    .arsize_bootreg_axim    (arsize_bootreg_axim),
    .arburst_bootreg_axim   (arburst_bootreg_axim),
    .arlock_bootreg_axim    (arlock_bootreg_axim),
    .arcache_bootreg_axim   (arcache_bootreg_axim),
    .arprot_bootreg_axim    (arprot_bootreg_axim),
    .arvalid_bootreg_axim   (arvalid_bootreg_axim),
    .arready_bootreg_axim   (arready_bootreg_axim),
    .aruser_bootreg_axim    (aruser_bootreg_axim),
    .rid_bootreg_axim       (rid_bootreg_axim),
    .rdata_bootreg_axim     (rdata_bootreg_axim),
    .rresp_bootreg_axim     (rresp_bootreg_axim),
    .rlast_bootreg_axim     (rlast_bootreg_axim),
    .rvalid_bootreg_axim    (rvalid_bootreg_axim),
    .rready_bootreg_axim    (rready_bootreg_axim),
    
    .qreqn_bootreg_pwr      (pwrqreqn[1]),
    .qacceptn_bootreg_pwr   (pwrqacceptn[1]),
    .qdeny_bootreg_pwr      (pwrqdeny[1]),
    .qactive_bootreg_pwr    (pwrqactive[1]),
    
    
    .apb_async_req_bootreg           (bootreg_async_req),
    .apb_async_req_payload_bootreg   (bootreg_async_req_payload),
    .apb_async_resp_payload_bootreg  (bootreg_async_resp_payload),
    .apb_async_ack_bootreg           (bootreg_async_ack),
    
    .dftcgen                         (dftcgen)
  );  


  sse710_adb400_r3_axi4_stream_mst_wrapper
    #(
      .DATA_WIDTH       (32),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (AXI4S_ID_WIDTH),
      .DEST_WIDTH       (AXI4S_ID_WIDTH),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FW2SYSTOP_FIFO_DEPTH),
      .OPREG            (1),
      .MI_SYNC_LEVELS   (2),
      .PAYLOAD_WIDTH    (FW2SYSTOP_UP_PAYLD_WIDTH)
    )
  u_sse710_adb400_r3_axi4_stream_mst_wrapper
    (
      .aclkm            (aclk),
      .aresetnm         (aresetn),

      .dftrstdisablem   (dftrstdisable),

      .clkqreqnm_i      (aclk_qreqn[2]   ),
      .clkqacceptnm_o   (aclk_qacceptn[2]),
      .clkqdenym_o      (aclk_qdeny[2]   ),
      .clkqactivem_o    (aclk_qactive[2] ),
      .wakeupm_o        (fw2systop_dn_wakeupm_o),

      .tvalidm          (tvalid_dti_up_m),
      .treadym          (tready_dti_up_m),
      .tdatam           (tdata_dti_up_m),
      .tstrbm           (              ),
      .tkeepm           (tkeep_dti_up_m),
      .tlastm           (tlast_dti_up_m),
      .tidm             (              ),
      .tdestm           (tdest_dti_up_m),
      .tuserm           (              ),

      .slvmustacceptreqn_async (fw2systop_up_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fw2systop_up_slvcandenyreqn_async),
      .slvacceptn_async        (fw2systop_up_slvacceptn_async),
      .slvdeny_async           (fw2systop_up_slvdeny_async),

      .si_to_mi_wakeup_async   (fw2systop_up_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fw2systop_up_mi_to_si_wakeup_async),

      .wr_ptr_async            (fw2systop_up_wr_ptr_async),
      .rd_ptr_async            (fw2systop_up_rd_ptr_async),
      .payld_async             (fw2systop_up_payld_async)
    );



  adb400_r3_axi4_stream_slv
    #(
      .DATA_WIDTH       (32),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .ID_WIDTH         (AXI4S_ID_WIDTH),
      .DEST_WIDTH       (AXI4S_ID_WIDTH),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (FW2SYSTOP_FIFO_DEPTH),
      .SI_SYNC_LEVELS   (2)
    )
  u_a4s_slv
    (
      .pwrqreqns_i     (pwrqreqn[2]),
      .pwrqacceptns_o  (pwrqacceptn[2]),
      .pwrqdenys_o     (pwrqdeny[2]),
      .pwrqactives_o   (pwrqactive[2]),

      .aclks           (aclk),
      .aresetns        (aresetn),

      .dftrstdisables  (dftrstdisable),

      .clkqreqns_i     (aclk_qreqn[3]   ),
      .clkqacceptns_o  (aclk_qacceptn[3]),
      .clkqdenys_o     (aclk_qdeny[3]   ),
      .clkqactives_o   (aclk_qactive[3] ),
      .wakeups_i       (fw2systop_up_wakeups_i),

      .tvalids         (tvalid_dti_dn_m),
      .treadys         (tready_dti_dn_m),
      .tdatas          (tdata_dti_dn_m),
      .tstrbs          (1'b1), 
      .tkeeps          (tkeep_dti_dn_m),
      .tlasts          (tlast_dti_dn_m),
      .tids            (tid_dti_dn_m),
      .tdests          ({AXI4S_ID_WIDTH{1'b1}}), 
      .tusers          (1'b0),
      
      .pwrq_permit_deny_sar_i  (fw2systop_up_pwrq_permit_deny_sar_i),

      .slvmustacceptreqn_async (fw2systop_dn_slvmustacceptreqn_async),
      .slvcandenyreqn_async    (fw2systop_dn_slvcandenyreqn_async),
      .slvacceptn_async        (fw2systop_dn_slvacceptn_async),
      .slvdeny_async           (fw2systop_dn_slvdeny_async),

      .si_to_mi_wakeup_async   (fw2systop_dn_si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (fw2systop_dn_mi_to_si_wakeup_async),

      .wr_ptr_async            (fw2systop_dn_wr_ptr_async),
      .rd_ptr_async            (fw2systop_dn_rd_ptr_async),
      .payld_async             (fw2systop_dn_payld_async)
    );

  sse710_adb400_r3_axi4_slv_wrapper
    #(
      .ADDR_WIDTH       (FW_AXI_ADDR_WIDTH),
      .DATA_WIDTH       (FW_AXI_DATA_WIDTH),
      .AWID_WIDTH       (FW_AXI_AWID_WIDTH),
      .ARID_WIDTH       (FW_AXI_ARID_WIDTH),
      .AWUSER_WIDTH     (FW_AXI_AWUSER_WIDTH),
      .WUSER_WIDTH      (FW_AXI_WUSER_WIDTH),
      .BUSER_WIDTH      (FW_AXI_BUSER_WIDTH),
      .ARUSER_WIDTH     (FW_AXI_ARUSER_WIDTH),
      .RUSER_WIDTH      (FW_AXI_RUSER_WIDTH),
      .AW_FIFO_DEPTH    (FW_AXI_AW_FIFO_DEPTH),
      .W_FIFO_DEPTH     (FW_AXI_W_FIFO_DEPTH),
      .B_FIFO_DEPTH     (FW_AXI_B_FIFO_DEPTH),
      .AR_FIFO_DEPTH    (FW_AXI_AR_FIFO_DEPTH),
      .R_FIFO_DEPTH     (FW_AXI_R_FIFO_DEPTH),
      .B_OPREG          (1),
      .R_OPREG          (1),
      .SI_SYNC_LEVELS   (2),
      .AW_PAYLOAD_WIDTH (FW_AXI_AW_PAYLOAD_WIDTH),
      .W_PAYLOAD_WIDTH  (FW_AXI_W_PAYLOAD_WIDTH),
      .B_PAYLOAD_WIDTH  (FW_AXI_B_PAYLOAD_WIDTH),
      .AR_PAYLOAD_WIDTH (FW_AXI_AR_PAYLOAD_WIDTH),
      .R_PAYLOAD_WIDTH  (FW_AXI_R_PAYLOAD_WIDTH)
      
    )
  u_sse710_adb400_r3_axi4_slv_wrapper
    (
    .pwrq_permit_deny_sar_i  (firewall_adb_pwrq_permit_deny_sar_i),

    .aclks                   (aclk),
    .aresetns                (aresetn),

    .clkqreqns_i             (aclk_qreqn[4]   ),
    .clkqacceptns_o          (aclk_qacceptn[4]),
    .clkqdenys_o             (aclk_qdeny[4]   ),
    .clkqactives_o           (aclk_qactive[4] ),
    
    .pwrqreqns_i             (pwrqreqn[3]),
    .pwrqacceptns_o          (pwrqacceptn[3]),
    .pwrqdenys_o             (pwrqdeny[3]),
    .pwrqactives_o           (pwrqactive[3]),

    .wakeups_i               (firewall_adb_wakeups_i),

    .awvalids                (awvalid_firewall_axim ),
    .awreadys                (awready_firewall_axim ),
    .awusers                 (awuser_firewall_axim  ),
    .awids                   (awid_firewall_axim    ),
    .awaddrs                 (awaddr_firewall_axim  ),
    .awregions               (4'h0),  
    .awlens                  (awlen_firewall_axim   ),
    .awsizes                 (awsize_firewall_axim  ),
    .awlocks                 (awlock_firewall_axim  ),
    .awcaches                (awcache_firewall_axim ),
    .awprots                 (awprot_firewall_axim  ),
    .awqoss                  (4'hf), 
    .awbursts                (awburst_firewall_axim ),

    .wvalids                 (wvalid_firewall_axim  ),
    .wreadys                 (wready_firewall_axim  ),
    .wusers                  (1'b0), 
    .wdatas                  (wdata_firewall_axim   ),
    .wstrbs                  (wstrb_firewall_axim   ),
    .wlasts                  (wlast_firewall_axim),

    .bvalids                 (bvalid_firewall_axim  ),
    .breadys                 (bready_firewall_axim  ),
    .busers                  (buser_firewall_axim   ),
    .bids                    (bid_firewall_axim     ),
    .bresps                  (bresp_firewall_axim   ),

    .arvalids                (arvalid_firewall_axim ),
    .arreadys                (arready_firewall_axim ),
    .arusers                 (aruser_firewall_axim  ),
    .arids                   (arid_firewall_axim    ),
    .araddrs                 (araddr_firewall_axim  ),
    .arregions               (4'h0),  
    .arlens                  (arlen_firewall_axim   ),
    .arsizes                 (arsize_firewall_axim  ),
    .arlocks                 (arlock_firewall_axim),
    .arcaches                (arcache_firewall_axim),
    .arprots                 (arprot_firewall_axim  ),
    .arqoss                  (4'hf), 
    .arbursts                (arburst_firewall_axim ),

    .rvalids                 (rvalid_firewall_axim  ),
    .rreadys                 (rready_firewall_axim  ),
    .rusers                  (ruser_firewall_axim   ),
    .rids                    (rid_firewall_axim     ),
    .rdatas                  (rdata_firewall_axim   ),
    .rresps                  (rresp_firewall_axim   ),
    .rlasts                  (rlast_firewall_axim   ),

    .slvmustacceptreqn_async (firewall_slvmustacceptreqn_async),
    .slvcandenyreqn_async    (firewall_slvcandenyreqn_async),
    .slvacceptn_async        (firewall_slvacceptn_async),
    .slvdeny_async           (firewall_slvdeny_async),
    .si_to_mi_wakeup_async   (firewall_si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async   (firewall_mi_to_si_wakeup_async),

    .aw_wr_ptr_async         (firewall_aw_wr_ptr_async),
    .aw_rd_ptr_async         (firewall_aw_rd_ptr_async),
    .aw_payld_async          (firewall_aw_payld_async),
    .w_wr_ptr_async          (firewall_w_wr_ptr_async),
    .w_rd_ptr_async          (firewall_w_rd_ptr_async),
    .w_payld_async           (firewall_w_payld_async),
    .b_wr_ptr_async          (firewall_b_wr_ptr_async),
    .b_rd_ptr_async          (firewall_b_rd_ptr_async),
    .b_payld_async           (firewall_b_payld_async),
    .ar_wr_ptr_async         (firewall_ar_wr_ptr_async),
    .ar_rd_ptr_async         (firewall_ar_rd_ptr_async),
    .ar_payld_async          (firewall_ar_payld_async),
    .r_wr_ptr_async          (firewall_r_wr_ptr_async),
    .r_rd_ptr_async          (firewall_r_rd_ptr_async),
    .r_payld_async           (firewall_r_payld_async),

    .dftrstdisables          (dftrstdisable)
    );

wire unused;

assign unused =  (|pstrb_uart);
  
endmodule

