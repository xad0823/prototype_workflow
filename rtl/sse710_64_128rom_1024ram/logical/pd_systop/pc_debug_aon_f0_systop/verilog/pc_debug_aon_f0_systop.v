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

module pc_debug_aon_f0_systop (

input  wire        aclk,
input  wire        aresetn,
    
output wire        extdbg_async_req,
output wire [67:0] extdbg_async_req_payload,
input  wire [32:0] extdbg_async_resp_payload,
input  wire        extdbg_async_ack,    

input  wire        psel_extdbg,
input  wire        penable_extdbg,
input  wire [31:0] paddr_extdbg,
input  wire        pwrite_extdbg,
input  wire [31:0] pwdata_extdbg,
input  wire [3:0]  pstrb_extdbg,
input  wire [2:0]  pprot_extdbg,
output wire [31:0] prdata_extdbg,
output wire        pready_extdbg,
output wire        pslverr_extdbg,

input  wire        psel_sdc600,
input  wire        penable_sdc600,
input  wire [31:0] paddr_sdc600,
input  wire        pwrite_sdc600,
input  wire [31:0] pwdata_sdc600,
input  wire [3:0]  pstrb_sdc600,
input  wire [2:0]  pprot_sdc600,
output wire [31:0] prdata_sdc600,
output wire        pready_sdc600,
output wire        pslverr_sdc600,

input  wire [2:0]  aclk_qreqn,
output wire [2:0]  aclk_qacceptn,
output wire [2:0]  aclk_qdeny,
output wire [2:0]  aclk_qactive,

input  wire        pwrqreqn,
output wire        pwrqacceptn,
output wire        pwrqdeny,
output wire        pwrqactive,

input  wire [1:0]  pwr_toaon_qreqn,
output wire [1:0]  pwr_toaon_qacceptn,
output wire [1:0]  pwr_toaon_qdeny,
output wire [1:0]  pwr_toaon_qactive,
    
output wire        irq_sdc600,

output wire [7:0]  ie_data_sdc600,
output wire        ie_req_sdc600,
input  wire        ie_ack_sdc600,
input  wire        ie_linkup_sdc600,
output wire        ie_linkest_sdc600,
input  wire [7:0]  ei_data_sdc600,
input  wire        ei_req_sdc600,
output wire        ei_ack_sdc600,
output wire        ei_linkup_sdc600,
input  wire        ei_linkest_sdc600,

input  wire        dftcgen
);
 
wire  [ 7:0]  rx_data_sdc600;
wire          rx_valid_sdc600;
wire          rx_linkest_sdc600;
wire          rx_ready_sdc600;
wire          rx_linkup_sdc600;

wire          tx_ready_sdc600;
wire          tx_linkup_sdc600;
wire  [ 7:0]  tx_data_sdc600;
wire          tx_valid_sdc600;
wire          tx_linkest_sdc600;

wire          unused;

assign pslverr_sdc600 = 1'b0;

  reg pwakeup_extdbg;
  
  always @(posedge aclk or negedge aresetn)
  begin
    if(!aresetn)
        pwakeup_extdbg<=1'b0;
    else
        pwakeup_extdbg<=psel_extdbg;
  end
  
  css600_apbasyncbridgeslv #(
    .WAKE_ON_TRANSACTION (0), 
    .APB_ADDR_WIDTH      (32),
    .FF_SYNC_DEPTH       (2)
  ) u_adb_apb4_slv (
    .clk_s                      (aclk),
    .reset_s_n                  (aresetn),
    .dftcgen                    (dftcgen),
    
    .psel_s                     (psel_extdbg),
    .penable_s                  (penable_extdbg),
    .paddr_s                    (paddr_extdbg),
    .pwrite_s                   (pwrite_extdbg),
    .pwdata_s                   (pwdata_extdbg),
    .pprot_s                    (pprot_extdbg),
    .prdata_s                   (prdata_extdbg),
    .pready_s                   (pready_extdbg),
    .pslverr_s                  (pslverr_extdbg),
    .pwakeup_s                  (pwakeup_extdbg),
    
    .clk_s_qreq_n               (aclk_qreqn[0]),
    .clk_s_qaccept_n            (aclk_qacceptn[0]),
    .clk_s_qdeny                (aclk_qdeny[0]),
    .clk_s_qactive              (aclk_qactive[0]),
    
    .pwr_qreq_n                 (pwr_toaon_qreqn[0]),
    .pwr_qaccept_n              (pwr_toaon_qacceptn[0]),
    .pwr_qdeny                  (pwr_toaon_qdeny[0]),
    .pwr_qactive                (pwr_toaon_qactive[0]),
    
    .apb_async_req              (extdbg_async_req),
    .apb_async_req_payload      (extdbg_async_req_payload),
    .apb_async_resp_payload     (extdbg_async_resp_payload),
    .apb_async_ack              (extdbg_async_ack)
  );
 reg pwakeup_sdc600;
  
  always @(posedge aclk or negedge aresetn)
  begin
    if(!aresetn)
        pwakeup_sdc600<=1'b0;
    else
        pwakeup_sdc600<=psel_sdc600;
  end
  
sdc600_apbcom_int u_sdc600_apbcom_int (
  .pclk          (aclk),
  .preset_n      (aresetn),

  .paddr_s       (paddr_sdc600[11:0]),
  .pwrite_s      (pwrite_sdc600 ),
  .psel_s        (psel_sdc600  ),
  .pwakeup_s     (pwakeup_sdc600  ),
  .penable_s     (penable_sdc600),
  .pwdata_s      (pwdata_sdc600 ), 
  .prdata_s      (prdata_sdc600 ),
  .pready_s      (pready_sdc600 ),

  .rx_data       (rx_data_sdc600),
  .rx_valid      (rx_valid_sdc600),
  .rx_linkest    (rx_linkest_sdc600),
  .rx_ready      (rx_ready_sdc600),
  .rx_linkup     (rx_linkup_sdc600),
               
  .tx_ready      (tx_ready_sdc600),
  .tx_linkup     (tx_linkup_sdc600),
  .tx_data       (tx_data_sdc600),
  .tx_valid      (tx_valid_sdc600),
  .tx_linkest    (tx_linkest_sdc600),
               
  .irq           (irq_sdc600),
               
  .pwr_qreq_n    (pwrqreqn),
  .pwr_qaccept_n (pwrqacceptn),
  .pwr_qdeny     (pwrqdeny),
  .pwr_qactive   (pwrqactive),
               
  .clk_qreq_n    (aclk_qreqn[1]),
  .clk_qaccept_n (aclk_qacceptn[1]),
  .clk_qdeny     (aclk_qdeny[1]),
  .clk_qactive   (aclk_qactive[1])
);


sdc600_comasyncbridge_indirect_half_int u_sdc600_comasyncbridge_indirect_half_int (
  .resetn_int           (aresetn),
  .clk_int              (aclk),
  .int_rx_data          (tx_data_sdc600),
  .int_rx_valid         (tx_valid_sdc600),
  .int_rx_ready         (tx_ready_sdc600),
  .int_rx_linkup        (tx_linkup_sdc600),
  .int_rx_linkest       (tx_linkest_sdc600),
  .int_async_ie_data    (ie_data_sdc600   ),
  .int_async_ie_req     (ie_req_sdc600    ),
  .int_async_ie_ack     (ie_ack_sdc600    ),
  .int_async_ie_linkup  (ie_linkup_sdc600 ),
  .int_async_ie_linkest (ie_linkest_sdc600),
  .int_async_ei_data    (ei_data_sdc600   ),
  .int_async_ei_req     (ei_req_sdc600    ),
  .int_async_ei_ack     (ei_ack_sdc600    ),
  .int_async_ei_linkup  (ei_linkup_sdc600 ),
  .int_async_ei_linkest (ei_linkest_sdc600),
  .int_tx_data          (rx_data_sdc600),
  .int_tx_valid         (rx_valid_sdc600),
  .int_tx_ready         (rx_ready_sdc600),
  .int_tx_linkup        (rx_linkup_sdc600),
  .int_tx_linkest       (rx_linkest_sdc600),
 
  .int_clk_qreq_n       (aclk_qreqn[2]),
  .int_clk_qaccept_n    (aclk_qacceptn[2]),
  .int_clk_qdeny        (aclk_qdeny[2]),
  .int_clk_qactive      (aclk_qactive[2]),
  
  .int_pwr_qreq_n       (pwr_toaon_qreqn[1]),
  .int_pwr_qaccept_n    (pwr_toaon_qacceptn[1]),
  .int_pwr_qdeny        (pwr_toaon_qdeny[1]),
  .int_pwr_qactive      (pwr_toaon_qactive[1]),
  
  .int_pwr_wake         ()
);
assign unused = (|paddr_sdc600[31:12]) | (|pstrb_extdbg) | (|pstrb_sdc600) | (|pprot_sdc600);
endmodule

