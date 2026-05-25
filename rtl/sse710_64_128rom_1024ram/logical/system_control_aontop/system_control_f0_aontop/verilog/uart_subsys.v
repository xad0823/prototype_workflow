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

module uart_subsys  
(
  input wire                uartclk,
  input wire                uartresetn,
  
  input  wire               apb_async_req,
  input  wire [52:0]        apb_async_req_payload,
  output wire [32:0]        apb_async_resp_payload,
  output wire               apb_async_ack,
          
  output reg                uart0_intr,
  output reg                uart1_intr,

  output wire               uart0_out2n,
  output wire               uart0_out1n,
  output wire               uart0_rtsn,
  output wire               uart0_dtrn,
  output wire               uart0_txd,
  input  wire               uart0_ctsn,
  input  wire               uart0_dcdn,
  input  wire               uart0_dsrn,
  input  wire               uart0_ri,
  input  wire               uart0_rxd,

  output wire               uart1_out2n,
  output wire               uart1_out1n,
  output wire               uart1_rtsn,
  output wire               uart1_dtrn,
  output wire               uart1_txd,
  input  wire               uart1_ctsn,
  input  wire               uart1_dcdn,
  input  wire               uart1_dsrn,
  input  wire               uart1_ri,
  input  wire               uart1_rxd,
  
  input wire                dftcgen
  );

  wire                psel; 
  wire [15:0]         prdata;  
  wire                penable;
  wire [16:0]         paddr;
  wire                pwrite;
  wire [31:0]         pwdata;

  wire                psel_uart0;
  wire                psel_uart1;
  wire [15:0]         prdata_uart0;
  wire [15:0]         prdata_uart1;
  wire                uart_arb;
  
  wire [15:0]         unused_prdata;
  
  wire                uart0_intr_comb;
  wire                uart1_intr_comb;
  
  wire               uart0_rxd_ss;
  wire               uart0_ctsn_ss;
  wire               uart0_dcdn_ss;
  wire               uart0_dsrn_ss;
  wire               uart0_ri_ss;
  
  wire               uart1_rxd_ss;
  wire               uart1_ctsn_ss;
  wire               uart1_dcdn_ss;
  wire               uart1_dsrn_ss;
  wire               uart1_ri_ss;
    
  arm_element_cdc_capt_sync u_uart0_rxd_ss  ( .clk(uartclk), .nreset(uartresetn), .d_async(uart0_rxd),  .q(uart0_rxd_ss) );
  arm_element_cdc_capt_sync u_uart0_ctsn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart0_ctsn), .q(uart0_ctsn_ss));
  arm_element_cdc_capt_sync u_uart0_dcdn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart0_dcdn), .q(uart0_dcdn_ss));
  arm_element_cdc_capt_sync u_uart0_dsrn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart0_dsrn), .q(uart0_dsrn_ss));
  arm_element_cdc_capt_sync u_uart0_ri_ss   ( .clk(uartclk), .nreset(uartresetn), .d_async(uart0_ri  ), .q(uart0_ri_ss)  );
  
  arm_element_cdc_capt_sync u_uart1_rxd_ss  ( .clk(uartclk), .nreset(uartresetn), .d_async(uart1_rxd),  .q(uart1_rxd_ss) );
  arm_element_cdc_capt_sync u_uart1_ctsn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart1_ctsn), .q(uart1_ctsn_ss));
  arm_element_cdc_capt_sync u_uart1_dcdn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart1_dcdn), .q(uart1_dcdn_ss));
  arm_element_cdc_capt_sync u_uart1_dsrn_ss ( .clk(uartclk), .nreset(uartresetn), .d_async(uart1_dsrn), .q(uart1_dsrn_ss));
  arm_element_cdc_capt_sync u_uart1_ri_ss   ( .clk(uartclk), .nreset(uartresetn), .d_async(uart1_ri  ), .q(uart1_ri_ss)  );
  
  assign uart_arb   = paddr[16];
  assign psel_uart0 = psel & (uart_arb);
  assign psel_uart1 = psel & (~uart_arb);
  assign prdata     = uart_arb ? prdata_uart0 : prdata_uart1;
  
  always @(posedge uartclk or negedge uartresetn)
  begin
    if( uartresetn == 1'b0 )
    begin
      uart0_intr<=1'b0;
      uart1_intr<=1'b0;
    end
    else
    begin
      uart0_intr<=uart0_intr_comb;
      uart1_intr<=uart1_intr_comb;
    end
  end

  css600_apbasyncbridgemstr #(
   .APB_ADDR_WIDTH (17),
   .FF_SYNC_DEPTH  (2)
 ) u_mst_apb
 (
   .clk_m                    (uartclk),
   .reset_m_n                (uartresetn),
   .dftcgen                  (dftcgen),
   .psel_m                   (psel),
   .penable_m                (penable),
   .paddr_m                  (paddr),
   .pwrite_m                 (pwrite),
   .pwdata_m                 (pwdata),
   .pprot_m                  (),
   .prdata_m                 ({16'd0,prdata}),
   .pready_m                 (1'b1),
   .pslverr_m                (1'b0),
   .pwakeup_m                (),
   .clk_m_qreq_n             (1'b1),   
   .clk_m_qaccept_n          (),
   .clk_m_qdeny              (),
   .clk_m_qactive            (),
   .apb_async_req            (apb_async_req         ),
   .apb_async_req_payload    (apb_async_req_payload ),
   .apb_async_resp_payload   (apb_async_resp_payload),
   .apb_async_ack            (apb_async_ack         )
  );
   
   
  
  Uart u_uart0
  (
  
    .PCLK           (  uartclk ),
    .UARTCLK        (  uartclk ),
    .PRESETn        (  uartresetn),
    .nUARTRST       (  uartresetn),
    
    .PSEL           (psel_uart0),
    .PENABLE        (penable),
    .PWRITE         (pwrite),
    .PADDR          (paddr[11:2]),
    .PWDATA         (pwdata[15:0]),
    .nUARTCTS       (uart0_ctsn_ss),
    .nUARTDCD       (uart0_dcdn_ss),
    .nUARTDSR       (uart0_dsrn_ss),
    .nUARTRI        (uart0_ri_ss),
    .UARTRXD        (uart0_rxd_ss),
    .SIRIN          (1'b0),       
    .UARTTXDMACLR   (1'b0),
    .UARTRXDMACLR   (1'b0),
    .UARTMSINTR     (),
    .UARTRXINTR     (),
    .UARTTXINTR     (),
    .UARTRTINTR     (),
    .UARTEINTR      (),
    .UARTINTR       (uart0_intr_comb),
    .PRDATA         (prdata_uart0),
    .UARTTXD        (uart0_txd),
    .nSIROUT        (),
    .nUARTOut2      (uart0_out2n),
    .nUARTOut1      (uart0_out1n),
    .nUARTRTS       (uart0_rtsn),
    .nUARTDTR       (uart0_dtrn),
    .UARTTXDMASREQ  (),
    .UARTTXDMABREQ  (),
    .UARTRXDMASREQ  (),
    .UARTRXDMABREQ  (),
    .SCANENABLE     (1'b0),
    .SCANINPCLK     (1'b0),
    .SCANINUCLK     (1'b0),
    .SCANOUTPCLK    (),
    .SCANOUTUCLK    (              )

  );
 
 Uart u_uart1
 (
    .PCLK           (  uartclk ),
    .UARTCLK        (  uartclk ),
    .PRESETn        (  uartresetn),
    .nUARTRST       (  uartresetn),
    .PSEL           (psel_uart1),
    .PENABLE        (penable),
    .PWRITE         (pwrite),
    .PADDR          (paddr[11:2]),
    .PWDATA         (pwdata[15:0]),
    .nUARTCTS       (uart1_ctsn_ss),
    .nUARTDCD       (uart1_dcdn_ss),
    .nUARTDSR       (uart1_dsrn_ss),
    .nUARTRI        (uart1_ri_ss),
    .UARTRXD        (uart1_rxd_ss),
    .SIRIN          (1'b0),       
    .UARTTXDMACLR   (1'b0),
    .UARTRXDMACLR   (1'b0),
    .UARTMSINTR     (),
    .UARTRXINTR     (),
    .UARTTXINTR     (),
    .UARTRTINTR     (),
    .UARTEINTR      (),
    .UARTINTR       (uart1_intr_comb),
    .PRDATA         (prdata_uart1),
    .UARTTXD        (uart1_txd),
    .nSIROUT        (),
    .nUARTOut2      (uart1_out2n),
    .nUARTOut1      (uart1_out1n),
    .nUARTRTS       (uart1_rtsn),
    .nUARTDTR       (uart1_dtrn),
    .UARTTXDMASREQ  (),
    .UARTTXDMABREQ  (),
    .UARTRXDMASREQ  (),
    .UARTRXDMABREQ  (),
    .SCANENABLE     (1'b0),
    .SCANINPCLK     (1'b0),
    .SCANINUCLK     (1'b0),
    .SCANOUTPCLK    (),
    .SCANOUTUCLK    (              )

 );
    wire unused;
    
    assign unused = (|paddr[1:0])    | 
                    (|paddr[15:12])  |
                    (|pwdata[31:16]); 

endmodule
