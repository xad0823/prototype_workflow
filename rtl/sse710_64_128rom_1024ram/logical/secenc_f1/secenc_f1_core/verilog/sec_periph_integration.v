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


module sec_periph_integration #(
  

  parameter                         MHU_SEES00_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES01_NUM_CH         = 7'd1,     
  parameter                         MHU_ES0SE1_NUM_CH         = 7'd1,     

  
  parameter                         MHU_SEES10_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE0_NUM_CH         = 7'd1,     
    parameter                         MHU_SEES11_NUM_CH         = 7'd1,     
  parameter                         MHU_ES1SE1_NUM_CH         = 7'd1,     

  
  parameter           MHU_HSE0_NUM_CH    = 7'd32,   
  parameter           MHU_SEH0_NUM_CH    = 7'd32,   
  parameter           MHU_HSE1_NUM_CH    = 7'd32,   
  parameter           MHU_SEH1_NUM_CH    = 7'd32    
  
) (
  input  wire                         clk,
  input  wire                         rst_n,
                                      
  input  wire                         m0_halted,

  input  wire                         periph_hsel,
  input  wire                [31:0]   periph_haddr,
  input  wire                 [3:0]   periph_hprot,
  input  wire                 [2:0]   periph_hsize,
  input  wire                 [1:0]   periph_htrans,
  input  wire                [31:0]   periph_hwdata,
  input  wire                         periph_hready,
  input  wire                         periph_hwrite,
  output wire                [31:0]   periph_hrdata,
  output wire                         periph_hreadyout,
  output wire                 [1:0]   periph_hresp,

  output wire                         aon_psel,         
  output wire                         aon_penable,      
  output wire                [19:0]   aon_paddr,        
  output wire                         aon_pwrite,       
  output wire                [31:0]   aon_pwdata,       
  input  wire                         aon_pready,       
  input  wire                [31:0]   aon_prdata,       
  input  wire                         aon_pslverr,      
  
  output wire                         socwd_psel,       
  output wire                         socwd_penable,    
  output wire                [11:0]   socwd_paddr,      
  output wire                         socwd_pwrite,     
  output wire                [31:0]   socwd_pwdata,     
  input  wire                         socwd_pready,     
  input  wire                [31:0]   socwd_prdata,     
  input  wire                         socwd_pslverr,    

  input  wire                         mhu0r_async_req,
  input  wire                [48:0]   mhu0r_async_req_payload,
  output wire                [32:0]   mhu0r_async_resp_payload,
  output wire                         mhu0r_async_ack,
  output wire                         mhu0r_recawake_async,
  input  wire                         mhu0r_recwakeup_async,
  output wire [MHU_HSE0_NUM_CH-1:0]   mhu0r_edge_async_req,
  input  wire [MHU_HSE0_NUM_CH-1:0]   mhu0r_edge_async_ack,

  output wire                         mhu0s_async_req,
  output wire                [48:0]   mhu0s_async_req_payload,
  input  wire                [32:0]   mhu0s_async_resp_payload,
  input  wire                         mhu0s_async_ack,
  input  wire                         mhu0s_recawake_async,
  output wire                         mhu0s_recwakeup_async,
  input  wire [MHU_SEH0_NUM_CH-1:0]   mhu0s_edge_async_req,
  output wire [MHU_SEH0_NUM_CH-1:0]   mhu0s_edge_async_ack,

  input  wire                         mhu1r_async_req,
  input  wire                [48:0]   mhu1r_async_req_payload,
  output wire                [32:0]   mhu1r_async_resp_payload,
  output wire                         mhu1r_async_ack,
  output wire                         mhu1r_recawake_async,
  input  wire                         mhu1r_recwakeup_async,
  output wire [MHU_HSE1_NUM_CH-1:0]   mhu1r_edge_async_req,
  input  wire [MHU_HSE1_NUM_CH-1:0]   mhu1r_edge_async_ack,

  output wire                         mhu1s_async_req,
  output wire                [48:0]   mhu1s_async_req_payload,
  input  wire                [32:0]   mhu1s_async_resp_payload,
  input  wire                         mhu1s_async_ack,
  input  wire                         mhu1s_recawake_async,
  output wire                         mhu1s_recwakeup_async,
  input  wire [MHU_SEH1_NUM_CH-1:0]   mhu1s_edge_async_req,
  output wire [MHU_SEH1_NUM_CH-1:0]   mhu1s_edge_async_ack,


  input  wire                                       mhu2r_async_req,
  input  wire                [48:0]                 mhu2r_async_req_payload,
  output wire                [32:0]                 mhu2r_async_resp_payload,
  output wire                                       mhu2r_async_ack,
  output wire                                       mhu2r_recawake_async,
  input  wire                                       mhu2r_recwakeup_async,
  output wire [MHU_ES0SE0_NUM_CH-1:0] mhu2r_edge_async_req,
  input  wire [MHU_ES0SE0_NUM_CH-1:0] mhu2r_edge_async_ack,

  output wire                                       mhu2s_async_req,
  output wire                [48:0]                 mhu2s_async_req_payload,
  input  wire                [32:0]                 mhu2s_async_resp_payload,
  input  wire                                       mhu2s_async_ack,
  input  wire                                       mhu2s_recawake_async,
  output wire                                       mhu2s_recwakeup_async,
  input  wire [MHU_SEES00_NUM_CH-1:0] mhu2s_edge_async_req,
  output wire [MHU_SEES00_NUM_CH-1:0] mhu2s_edge_async_ack,
  
  
  input  wire                                       mhu3r_async_req,
  input  wire                [48:0]                 mhu3r_async_req_payload,
  output wire                [32:0]                 mhu3r_async_resp_payload,
  output wire                                       mhu3r_async_ack,
  output wire                                       mhu3r_recawake_async,
  input  wire                                       mhu3r_recwakeup_async,
  output wire [MHU_ES0SE1_NUM_CH-1:0] mhu3r_edge_async_req,
  input  wire [MHU_ES0SE1_NUM_CH-1:0] mhu3r_edge_async_ack,

  output wire                                       mhu3s_async_req,
  output wire                [48:0]                 mhu3s_async_req_payload,
  input  wire                [32:0]                 mhu3s_async_resp_payload,
  input  wire                                       mhu3s_async_ack,
  input  wire                                       mhu3s_recawake_async,
  output wire                                       mhu3s_recwakeup_async,
  input  wire [MHU_SEES01_NUM_CH-1:0] mhu3s_edge_async_req,
  output wire [MHU_SEES01_NUM_CH-1:0] mhu3s_edge_async_ack,

  
  input  wire                                       mhu4r_async_req,
  input  wire                [48:0]                 mhu4r_async_req_payload,
  output wire                [32:0]                 mhu4r_async_resp_payload,
  output wire                                       mhu4r_async_ack,
  output wire                                       mhu4r_recawake_async,
  input  wire                                       mhu4r_recwakeup_async,
  output wire [MHU_ES1SE0_NUM_CH-1:0] mhu4r_edge_async_req,
  input  wire [MHU_ES1SE0_NUM_CH-1:0] mhu4r_edge_async_ack,

  output wire                                       mhu4s_async_req,
  output wire                [48:0]                 mhu4s_async_req_payload,
  input  wire                [32:0]                 mhu4s_async_resp_payload,
  input  wire                                       mhu4s_async_ack,
  input  wire                                       mhu4s_recawake_async,
  output wire                                       mhu4s_recwakeup_async,
  input  wire [MHU_SEES10_NUM_CH-1:0] mhu4s_edge_async_req,
  output wire [MHU_SEES10_NUM_CH-1:0] mhu4s_edge_async_ack,
  
  
  input  wire                                       mhu5r_async_req,
  input  wire                [48:0]                 mhu5r_async_req_payload,
  output wire                [32:0]                 mhu5r_async_resp_payload,
  output wire                                       mhu5r_async_ack,
  output wire                                       mhu5r_recawake_async,
  input  wire                                       mhu5r_recwakeup_async,
  output wire [MHU_ES1SE1_NUM_CH-1:0] mhu5r_edge_async_req,
  input  wire [MHU_ES1SE1_NUM_CH-1:0] mhu5r_edge_async_ack,

  output wire                                       mhu5s_async_req,
  output wire                [48:0]                 mhu5s_async_req_payload,
  input  wire                [32:0]                 mhu5s_async_resp_payload,
  input  wire                                       mhu5s_async_ack,
  input  wire                                       mhu5s_recawake_async,
  output wire                                       mhu5s_recwakeup_async,
  input  wire [MHU_SEES11_NUM_CH-1:0] mhu5s_edge_async_req,
  output wire [MHU_SEES11_NUM_CH-1:0] mhu5s_edge_async_ack,

    
  input  wire                         mhu0_qreqn,
  output wire                         mhu0_qacceptn,
  output wire                         mhu0_qdeny,
  input  wire                         mhu1_qreqn,
  output wire                         mhu1_qacceptn,
  output wire                         mhu1_qdeny,
  
  input  wire                         mhu2_qreqn,
  output wire                         mhu2_qacceptn,
  output wire                         mhu2_qdeny,
    input  wire                         mhu3_qreqn,
  output wire                         mhu3_qacceptn,
  output wire                         mhu3_qdeny,
    
  
  input  wire                         mhu4_qreqn,
  output wire                         mhu4_qacceptn,
  output wire                         mhu4_qdeny,
    input  wire                         mhu5_qreqn,
  output wire                         mhu5_qacceptn,
  output wire                         mhu5_qdeny,
    
  
                                      
  output wire                         timer0_irq,
  output wire                         timer1_irq,
  output wire                         wdog_irq,
  output wire                         mhu0r_cirq,
  output wire                         mhu0s_cirq,
  output wire                         mhu1r_cirq,
  output wire                         mhu1s_cirq,
  output wire                       mhu2r_cirq,
  output wire                       mhu2s_cirq,
    output wire                       mhu3r_cirq,
  output wire                       mhu3s_cirq,
    output wire                       mhu4r_cirq,
  output wire                       mhu4s_cirq,
    output wire                       mhu5r_cirq,
  output wire                       mhu5s_cirq,
                                        
  output wire                         wdog_rst_req,
                                      
  input  wire                         dft_cgen
);


  
  wire        apbmux_psel;
  wire        apbmux_penable;
  wire [19:0] apbmux_paddr;
  wire        apbmux_pwrite;
  wire [31:0] apbmux_pwdata;
  wire        apbmux_pready;
  wire [31:0] apbmux_prdata;
  wire        apbmux_pslverr;  
  
  wire        ahb2apb_psel;
  wire        ahb2apb_penable;
  wire [19:0] ahb2apb_paddr;
  wire        ahb2apb_pwrite;
  wire [31:0] ahb2apb_pwdata;
  wire        ahb2apb_pready;
  wire [31:0] ahb2apb_prdata;
  wire        ahb2apb_pslverr;

  wire        timer0_psel;
  wire        timer0_penable;
  wire  [9:0] timer0_paddr;
  wire        timer0_pwrite;
  wire [31:0] timer0_pwdata;
  wire [31:0] timer0_prdata;
  wire        timer0_pready;
  wire        timer0_pslverr;
  wire  [3:0] timer0_ecorevnum;

  wire        timer1_psel;
  wire        timer1_penable;
  wire  [9:0] timer1_paddr;
  wire        timer1_pwrite;
  wire [31:0] timer1_pwdata;
  wire [31:0] timer1_prdata;
  wire        timer1_pready;
  wire        timer1_pslverr;
  wire  [3:0] timer1_ecorevnum;

  wire        wdog_psel;
  wire        wdog_penable;
  wire  [9:0] wdog_paddr;
  wire        wdog_pwrite;
  wire [31:0] wdog_pwdata;
  wire [31:0] wdog_prdata;
  wire  [3:0] wdog_ecorevnum;

  wire        mhu0s_psel;
  wire        mhu0s_penable;
  wire [31:0] mhu0s_paddr;
  wire        mhu0s_pwrite;
  wire [31:0] mhu0s_pwdata;
  wire [31:0] mhu0s_prdata;
  wire        mhu0s_pready;
  wire        mhu0s_pslverr;

  wire        mhu0r_psel;
  wire        mhu0r_penable;
  wire [31:0] mhu0r_paddr;
  wire        mhu0r_pwrite;
  wire [31:0] mhu0r_pwdata;
  wire [31:0] mhu0r_prdata;
  wire        mhu0r_pready;
  wire        mhu0r_pslverr;

  wire        mhu1s_psel;
  wire        mhu1s_penable;
  wire [31:0] mhu1s_paddr;
  wire        mhu1s_pwrite;
  wire [31:0] mhu1s_pwdata;
  wire [31:0] mhu1s_prdata;
  wire        mhu1s_pready;
  wire        mhu1s_pslverr;

  wire        mhu1r_psel;
  wire        mhu1r_penable;
  wire [31:0] mhu1r_paddr;
  wire        mhu1r_pwrite;
  wire [31:0] mhu1r_pwdata;
  wire [31:0] mhu1r_prdata;
  wire        mhu1r_pready;
  wire        mhu1r_pslverr;

  
  wire        mhu2s_psel;
  wire        mhu2s_penable;
  wire [31:0] mhu2s_paddr;
  wire        mhu2s_pwrite;
  wire [31:0] mhu2s_pwdata;
  wire [31:0] mhu2s_prdata;
  wire        mhu2s_pready;
  wire        mhu2s_pslverr;

  wire        mhu2r_psel;
  wire        mhu2r_penable;
  wire [31:0] mhu2r_paddr;
  wire        mhu2r_pwrite;
  wire [31:0] mhu2r_pwdata;
  wire [31:0] mhu2r_prdata;
  wire        mhu2r_pready;
  wire        mhu2r_pslverr;
  
  
  wire        mhu3s_psel;
  wire        mhu3s_penable;
  wire [31:0] mhu3s_paddr;
  wire        mhu3s_pwrite;
  wire [31:0] mhu3s_pwdata;
  wire [31:0] mhu3s_prdata;
  wire        mhu3s_pready;
  wire        mhu3s_pslverr;

  wire        mhu3r_psel;
  wire        mhu3r_penable;
  wire [31:0] mhu3r_paddr;
  wire        mhu3r_pwrite;
  wire [31:0] mhu3r_pwdata;
  wire [31:0] mhu3r_prdata;
  wire        mhu3r_pready;
  wire        mhu3r_pslverr;  
    
  
  wire        mhu4s_psel;
  wire        mhu4s_penable;
  wire [31:0] mhu4s_paddr;
  wire        mhu4s_pwrite;
  wire [31:0] mhu4s_pwdata;
  wire [31:0] mhu4s_prdata;
  wire        mhu4s_pready;
  wire        mhu4s_pslverr;

  wire        mhu4r_psel;
  wire        mhu4r_penable;
  wire [31:0] mhu4r_paddr;
  wire        mhu4r_pwrite;
  wire [31:0] mhu4r_pwdata;
  wire [31:0] mhu4r_prdata;
  wire        mhu4r_pready;
  wire        mhu4r_pslverr;
  
  
  wire        mhu5s_psel;
  wire        mhu5s_penable;
  wire [31:0] mhu5s_paddr;
  wire        mhu5s_pwrite;
  wire [31:0] mhu5s_pwdata;
  wire [31:0] mhu5s_prdata;
  wire        mhu5s_pready;
  wire        mhu5s_pslverr;

  wire        mhu5r_psel;
  wire        mhu5r_penable;
  wire [31:0] mhu5r_paddr;
  wire        mhu5r_pwrite;
  wire [31:0] mhu5r_pwdata;
  wire [31:0] mhu5r_prdata;
  wire        mhu5r_pready;
  wire        mhu5r_pslverr;  
    
  
  
  reg   [3:0] remap_select_0;
  reg   [3:0] remap_select_1;

  wire        count_en;

  wire        unused; 
  
  assign unused = (&periph_haddr[31:20]);

  assign periph_hresp[1] = 1'b0; 

  assign count_en = !m0_halted; 

  
  cmsdk_ahb_to_apb #(
    .ADDRWIDTH       (20),
    .REGISTER_RDATA  (1),
    .REGISTER_WDATA  (1)
  ) u_cmsdk_ahb_to_apb (
    .HCLK            (clk),
    .HRESETn         (rst_n),
    .PCLKEN          (1'b1),
    .HSEL            (periph_hsel),
    .HADDR           (periph_haddr[19:0]),
    .HTRANS          (periph_htrans),
    .HSIZE           (periph_hsize),
    .HPROT           (periph_hprot),
    .HWRITE          (periph_hwrite),
    .HREADY          (periph_hready),
    .HWDATA          (periph_hwdata),
    .HREADYOUT       (periph_hreadyout),
    .HRDATA          (periph_hrdata),
    .HRESP           (periph_hresp[0]),
    .PADDR           (ahb2apb_paddr),
    .PENABLE         (ahb2apb_penable),
    .PWRITE          (ahb2apb_pwrite),
    .PSTRB           (),
    .PPROT           (),
    .PWDATA          (ahb2apb_pwdata),
    .PSEL            (ahb2apb_psel),
    .APBACTIVE       (),
    .PRDATA          (ahb2apb_prdata),
    .PREADY          (ahb2apb_pready),
    .PSLVERR         (ahb2apb_pslverr)
  );

  always @(*)
    begin
      remap_select_0 =  (&(ahb2apb_paddr[19:12] ^ (~ahb2apb_paddr[19:12]))) ? 4'b0000 : 4'b1111;  
      case (ahb2apb_paddr[19:12])
        8'h00 : 
          remap_select_0 = 4'b0001;
        8'h01 : 
          remap_select_0 = 4'b0010;
        8'h81 : 
          remap_select_0 = 4'b0011;
        8'h03 : 
          remap_select_0 = 4'b0100;
        8'h04 : 
          remap_select_0 = 4'b0101;
        8'h05 : 
          remap_select_0 = 4'b0110;
        8'h06 : 
          remap_select_0 = 4'b0111;
        8'h10 : 
          remap_select_0 = 4'b1000;
        8'h11 : 
          remap_select_0 = 4'b1001;
        8'h12 : 
          remap_select_0 = 4'b1010;
        8'h13 : 
          remap_select_0 = 4'b1011;           
        8'h14 : 
          remap_select_0 = 4'b1100;
        8'h15 : 
          remap_select_0 = 4'b1101;
        8'h16 : 
          remap_select_0 = 4'b1110;
        8'h17 : 
          remap_select_0 = 4'b1111;          
      endcase
    end

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE   (1), 
    .PORT1_ENABLE   (1), 
    .PORT2_ENABLE   (1), 
    .PORT3_ENABLE   (1), 
    .PORT4_ENABLE   (1), 
    .PORT5_ENABLE   (1), 
    .PORT6_ENABLE   (1), 
    .PORT7_ENABLE   (1), 
    .PORT8_ENABLE   (1), 
    .PORT9_ENABLE   (1), 
    .PORT10_ENABLE  (1), 
    .PORT11_ENABLE  (1), 
    .PORT12_ENABLE  (1), 
    .PORT13_ENABLE  (1), 
    .PORT14_ENABLE  (1), 
    .PORT15_ENABLE  (1)  
  ) u_cmsdk_apb_slave_mux_0 (
    .DECODE4BIT     (remap_select_0),
    .PSEL           (ahb2apb_psel),
    .PSEL0          (apbmux_psel),
    .PREADY0        (apbmux_pready),
    .PRDATA0        (apbmux_prdata),
    .PSLVERR0       (apbmux_pslverr),
    .PSEL1          (timer0_psel),
    .PREADY1        (timer0_pready),
    .PRDATA1        (timer0_prdata),
    .PSLVERR1       (timer0_pslverr),
    .PSEL2          (timer1_psel),
    .PREADY2        (timer1_pready),
    .PRDATA2        (timer1_prdata),
    .PSLVERR2       (timer1_pslverr),
    .PSEL3          (wdog_psel),
    .PREADY3        (1'b1),
    .PRDATA3        (wdog_prdata),
    .PSLVERR3       (1'b0),
    .PSEL4          (mhu0s_psel),
    .PREADY4        (mhu0s_pready),
    .PRDATA4        (mhu0s_prdata),
    .PSLVERR4       (mhu0s_pslverr),
    .PSEL5          (mhu0r_psel),
    .PREADY5        (mhu0r_pready),
    .PRDATA5        (mhu0r_prdata),
    .PSLVERR5       (mhu0r_pslverr),
    .PSEL6          (mhu1s_psel),
    .PREADY6        (mhu1s_pready),
    .PRDATA6        (mhu1s_prdata),
    .PSLVERR6       (mhu1s_pslverr),
    .PSEL7          (mhu1r_psel),
    .PREADY7        (mhu1r_pready),
    .PRDATA7        (mhu1r_prdata),
    .PSLVERR7       (mhu1r_pslverr),
      .PSEL8          (mhu2s_psel),
    .PREADY8        (mhu2s_pready),
    .PRDATA8        (mhu2s_prdata),
    .PSLVERR8       (mhu2s_pslverr),
    .PSEL9          (mhu2r_psel),
    .PREADY9        (mhu2r_pready),
    .PRDATA9        (mhu2r_prdata),
    .PSLVERR9       (mhu2r_pslverr),
        .PSEL10         (mhu3s_psel),
    .PREADY10       (mhu3s_pready),
    .PRDATA10       (mhu3s_prdata),
    .PSLVERR10      (mhu3s_pslverr),
    .PSEL11         (mhu3r_psel),
    .PREADY11       (mhu3r_pready),
    .PRDATA11       (mhu3r_prdata),
    .PSLVERR11      (mhu3r_pslverr),
            .PSEL12          (mhu4s_psel),
    .PREADY12        (mhu4s_pready),
    .PRDATA12        (mhu4s_prdata),
    .PSLVERR12       (mhu4s_pslverr),
    .PSEL13          (mhu4r_psel),
    .PREADY13        (mhu4r_pready),
    .PRDATA13        (mhu4r_prdata),
    .PSLVERR13       (mhu4r_pslverr),
        .PSEL14         (mhu5s_psel),
    .PREADY14       (mhu5s_pready),
    .PRDATA14       (mhu5s_prdata),
    .PSLVERR14      (mhu5s_pslverr),
    .PSEL15         (mhu5r_psel),
    .PREADY15       (mhu5r_pready),
    .PRDATA15       (mhu5r_prdata),
    .PSLVERR15      (mhu5r_pslverr),
          
    .PREADY         (ahb2apb_pready),
    .PRDATA         (ahb2apb_prdata),
    .PSLVERR        (ahb2apb_pslverr)
  );

  assign apbmux_paddr   = ahb2apb_paddr;
  assign apbmux_pwdata  = ahb2apb_pwdata;
  assign apbmux_penable = ahb2apb_penable;
  assign apbmux_pwrite  = ahb2apb_pwrite;

  assign timer0_paddr   = ahb2apb_paddr[11:2];
  assign timer0_pwdata  = ahb2apb_pwdata;
  assign timer0_penable = ahb2apb_penable;
  assign timer0_pwrite  = ahb2apb_pwrite;

  assign timer1_paddr   = ahb2apb_paddr[11:2];
  assign timer1_pwdata  = ahb2apb_pwdata;
  assign timer1_penable = ahb2apb_penable;
  assign timer1_pwrite  = ahb2apb_pwrite;

  assign wdog_paddr     = ahb2apb_paddr[11:2];
  assign wdog_pwdata    = ahb2apb_pwdata;
  assign wdog_penable   = ahb2apb_penable;
  assign wdog_pwrite    = ahb2apb_pwrite;

  assign mhu0s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu0s_pwdata   = ahb2apb_pwdata;
  assign mhu0s_penable  = ahb2apb_penable;
  assign mhu0s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu0r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu0r_pwdata   = ahb2apb_pwdata;
  assign mhu0r_penable  = ahb2apb_penable;
  assign mhu0r_pwrite   = ahb2apb_pwrite;
                        
  assign mhu1s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu1s_pwdata   = ahb2apb_pwdata;
  assign mhu1s_penable  = ahb2apb_penable;
  assign mhu1s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu1r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu1r_pwdata   = ahb2apb_pwdata;
  assign mhu1r_penable  = ahb2apb_penable;
  assign mhu1r_pwrite   = ahb2apb_pwrite;

  
  assign mhu2s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu2s_pwdata   = ahb2apb_pwdata;
  assign mhu2s_penable  = ahb2apb_penable;
  assign mhu2s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu2r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu2r_pwdata   = ahb2apb_pwdata;
  assign mhu2r_penable  = ahb2apb_penable;
  assign mhu2r_pwrite   = ahb2apb_pwrite;
  
                          
  assign mhu3s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu3s_pwdata   = ahb2apb_pwdata;
  assign mhu3s_penable  = ahb2apb_penable;
  assign mhu3s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu3r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu3r_pwdata   = ahb2apb_pwdata;
  assign mhu3r_penable  = ahb2apb_penable;
  assign mhu3r_pwrite   = ahb2apb_pwrite;
    
  assign mhu4s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu4s_pwdata   = ahb2apb_pwdata;
  assign mhu4s_penable  = ahb2apb_penable;
  assign mhu4s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu4r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu4r_pwdata   = ahb2apb_pwdata;
  assign mhu4r_penable  = ahb2apb_penable;
  assign mhu4r_pwrite   = ahb2apb_pwrite;
  
                          
  assign mhu5s_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu5s_pwdata   = ahb2apb_pwdata;
  assign mhu5s_penable  = ahb2apb_penable;
  assign mhu5s_pwrite   = ahb2apb_pwrite;
                        
  assign mhu5r_paddr    = {12'b0, ahb2apb_paddr};
  assign mhu5r_pwdata   = ahb2apb_pwdata;
  assign mhu5r_penable  = ahb2apb_penable;
  assign mhu5r_pwrite   = ahb2apb_pwrite;
    
  always @(*)
    begin
      remap_select_1 =  (&(ahb2apb_paddr[19:12] ^ (~ahb2apb_paddr[19:12]))) ? 4'b0000 : 4'b1111;  
      case (ahb2apb_paddr[19:12])
        8'h8F :   
          remap_select_1 = 4'b0001;
        8'h18 : 
          remap_select_1 = 4'b0010;
        8'h19 : 
          remap_select_1 = 4'b0011;
        8'h1A : 
          remap_select_1 = 4'b0100;
        8'h1B : 
          remap_select_1 = 4'b0101;           
        8'h1C : 
          remap_select_1 = 4'b0110;
        8'h1D : 
          remap_select_1 = 4'b0111;
        8'h1E : 
          remap_select_1 = 4'b1000;
        8'h1F : 
          remap_select_1 = 4'b1001;
      endcase
    end

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE   (1), 
    .PORT1_ENABLE   (1), 
    .PORT2_ENABLE   (1), 
    .PORT3_ENABLE   (1), 
    .PORT4_ENABLE   (1), 
    .PORT5_ENABLE   (1), 
    .PORT6_ENABLE   (1), 
    .PORT7_ENABLE   (1), 
    .PORT8_ENABLE   (1), 
    .PORT9_ENABLE   (1), 
    .PORT10_ENABLE  (0),
    .PORT11_ENABLE  (0),
    .PORT12_ENABLE  (0),
    .PORT13_ENABLE  (0),
    .PORT14_ENABLE  (0),
    .PORT15_ENABLE  (0) 
  ) u_cmsdk_apb_slave_mux_1 (
    .DECODE4BIT     (remap_select_1),
    .PSEL           (apbmux_psel),
    .PSEL0          (aon_psel),
    .PREADY0        (aon_pready),
    .PRDATA0        (aon_prdata),
    .PSLVERR0       (aon_pslverr),
    .PSEL1          (socwd_psel),
    .PREADY1        (socwd_pready),
    .PRDATA1        (socwd_prdata),
    .PSLVERR1       (socwd_pslverr),
      .PSEL2         (),
    .PREADY2       (1'b1),
    .PRDATA2       (32'h0000_0000),
    .PSLVERR2      (1'b1),
    .PSEL3         (),
    .PREADY3       (1'b1),
    .PRDATA3       (32'h0000_0000),
    .PSLVERR3      (1'b1),
    .PSEL4         (),
    .PREADY4       (1'b1),
    .PRDATA4       (32'h0000_0000),
    .PSLVERR4      (1'b1),
    .PSEL5         (),
    .PREADY5       (1'b1),
    .PRDATA5       (32'h0000_0000),
    .PSLVERR5      (1'b1),
        .PSEL6         (),
    .PREADY6       (1'b1),
    .PRDATA6       (32'h0000_0000),
    .PSLVERR6      (1'b1),
    .PSEL7         (),
    .PREADY7       (1'b1),
    .PRDATA7       (32'h0000_0000),
    .PSLVERR7      (1'b1),
    .PSEL8         (),
    .PREADY8       (1'b1),
    .PRDATA8       (32'h0000_0000),
    .PSLVERR8      (1'b1),
    .PSEL9         (),
    .PREADY9       (1'b1),
    .PRDATA9       (32'h0000_0000),
    .PSLVERR9      (1'b1),
   
    .PSEL10         (),
    .PREADY10       (1'b0),
    .PRDATA10       (32'h0000_0000),
    .PSLVERR10      (1'b0),
    .PSEL11         (),
    .PREADY11       (1'b0),
    .PRDATA11       (32'h0000_0000),
    .PSLVERR11      (1'b0),
    .PSEL12         (),
    .PREADY12       (1'b0),
    .PRDATA12       (32'h0000_0000),
    .PSLVERR12      (1'b0),
    .PSEL13         (),
    .PREADY13       (1'b0),
    .PRDATA13       (32'h0000_0000),
    .PSLVERR13      (1'b0),
    .PSEL14         (),
    .PREADY14       (1'b0),
    .PRDATA14       (32'h0000_0000),
    .PSLVERR14      (1'b0),
    .PSEL15         (),
    .PREADY15       (1'b0),
    .PRDATA15       (32'h0000_0000),
    .PSLVERR15      (1'b0),
    .PREADY         (apbmux_pready),
    .PRDATA         (apbmux_prdata),
    .PSLVERR        (apbmux_pslverr)
  );

  assign aon_paddr     = apbmux_paddr;
  assign aon_pwdata    = apbmux_pwdata;
  assign aon_penable   = apbmux_penable;
  assign aon_pwrite    = apbmux_pwrite;

  assign socwd_paddr   = apbmux_paddr[11:0];
  assign socwd_pwdata  = apbmux_pwdata;
  assign socwd_penable = apbmux_penable;
  assign socwd_pwrite  = apbmux_pwrite;  


  
  cmsdk_apb_timer u_cmsdk_apb_timer_0 (
    .PCLK       (clk),
    .PCLKG      (clk),
    .PRESETn    (rst_n),
    .PSEL       (timer0_psel),
    .PADDR      (timer0_paddr),
    .PENABLE    (timer0_penable),
    .PWRITE     (timer0_pwrite),
    .PWDATA     (timer0_pwdata),
    .ECOREVNUM  (timer0_ecorevnum),
    .PRDATA     (timer0_prdata),
    .PREADY     (timer0_pready),
    .PSLVERR    (timer0_pslverr),
    .EXTIN      (count_en),
    .TIMERINT   (timer0_irq)
  );

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_0 (
    .ecorevnum (timer0_ecorevnum)
  );

  cmsdk_apb_timer u_cmsdk_apb_timer_1 (
    .PCLK       (clk),
    .PCLKG      (clk),
    .PRESETn    (rst_n),
    .PSEL       (timer1_psel),
    .PADDR      (timer1_paddr),
    .PENABLE    (timer1_penable),
    .PWRITE     (timer1_pwrite),
    .PWDATA     (timer1_pwdata),
    .ECOREVNUM  (timer1_ecorevnum),
    .PRDATA     (timer1_prdata),
    .PREADY     (timer1_pready),
    .PSLVERR    (timer1_pslverr),
    .EXTIN      (count_en),
    .TIMERINT   (timer1_irq)
  );

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_1 (
    .ecorevnum (timer1_ecorevnum)
  );

  
  cmsdk_apb_watchdog u_cmsdk_apb_watchdog (
    .PCLK       (clk),
    .PRESETn    (rst_n),
    .PENABLE    (wdog_penable),
    .PSEL       (wdog_psel),
    .PADDR      (wdog_paddr),
    .PWRITE     (wdog_pwrite),
    .PWDATA     (wdog_pwdata),
    .WDOGCLK    (clk),
    .WDOGCLKEN  (count_en),
    .WDOGRESn   (rst_n),
    .ECOREVNUM  (wdog_ecorevnum),
    .PRDATA     (wdog_prdata),
    .WDOGINT    (wdog_irq),
    .WDOGRES    (wdog_rst_req)
  );

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_2 (
    .ecorevnum (wdog_ecorevnum)
  );
  
  
  mhuv2_f1_receiver #( 
    .MHU_NUM_CH             (MHU_HSE0_NUM_CH)
  ) u_mhuv2_f1_receiver_hse0 (
    .pclk_rec                 (clk),
    .presetn_rec              (rst_n),
    .pwakeup_rec              (1'b0), 
    .paddr_rec                (mhu0r_paddr),
    .pwrite_rec               (mhu0r_pwrite),
    .pwdata_rec               (mhu0r_pwdata),
    .penable_rec              (mhu0r_penable),
    .pselx_rec                (mhu0r_psel),
    .prdata_rec               (mhu0r_prdata),
    .pready_rec               (mhu0r_pready),
    .pslverr_rec              (mhu0r_pslverr),
    .qreqn_pclk_rec           (1'b1),
    .qacceptn_pclk_rec        (),
    .qdeny_pclk_rec           (),
    .qactive_pclk_rec         (),
    .qreqn_pwr_rec            (mhu0_qreqn),
    .qacceptn_pwr_rec         (mhu0_qacceptn),
    .qdeny_pwr_rec            (mhu0_qdeny),
    .mhu_irqcomb              (mhu0r_cirq),
    .mhu_irq_reg              (),
    .apb_async_req            (mhu0r_async_req),
    .apb_async_req_payload    (mhu0r_async_req_payload),
    .apb_async_resp_payload   (mhu0r_async_resp_payload),
    .apb_async_ack            (mhu0r_async_ack),
    .recawake_async           (mhu0r_recawake_async),
    .recwakeup_async          (mhu0r_recwakeup_async),
    .edge_async_req           (mhu0r_edge_async_req),
    .edge_async_ack           (mhu0r_edge_async_ack),
    .dftcgen                  (dft_cgen)
  );

  mhuv2_f1_sender #( 
    .MHU_NUM_CH             (MHU_SEH0_NUM_CH)
  ) u_mhuv2_f1_sender_seh0 (
    .pclk_snd                 (clk),
    .presetn_snd              (rst_n),
    .pwakeup_snd              (1'b0), 
    .paddr_snd                (mhu0s_paddr),
    .pwrite_snd               (mhu0s_pwrite),
    .pwdata_snd               (mhu0s_pwdata),
    .penable_snd              (mhu0s_penable),
    .pselx_snd                (mhu0s_psel),
    .prdata_snd               (mhu0s_prdata),
    .pready_snd               (mhu0s_pready),
    .pslverr_snd              (mhu0s_pslverr),
    .qreqn_pclk_snd           (1'b1),
    .qacceptn_pclk_snd        (),
    .qdeny_pclk_snd           (),
    .qactive_pclk_snd         (),
    .apb_async_req            (mhu0s_async_req),
    .apb_async_req_payload    (mhu0s_async_req_payload),
    .apb_async_resp_payload   (mhu0s_async_resp_payload),
    .apb_async_ack            (mhu0s_async_ack),
    .recawake_async           (mhu0s_recawake_async),
    .recwakeup_async          (mhu0s_recwakeup_async),
    .int_access_nr2r          (),
    .int_access_r2nr          (),
    .int_irqcomb              (mhu0s_cirq),
    .edge_async_req           (mhu0s_edge_async_req),
    .edge_async_ack           (mhu0s_edge_async_ack),
    .dftcgen                  (dft_cgen)
  );

  mhuv2_f1_receiver #( 
    .MHU_NUM_CH             (MHU_HSE1_NUM_CH)
  ) u_mhuv2_f1_receiver_hse1 (
    .pclk_rec                 (clk),
    .presetn_rec              (rst_n),
    .pwakeup_rec              (1'b0), 
    .paddr_rec                (mhu1r_paddr),
    .pwrite_rec               (mhu1r_pwrite),
    .pwdata_rec               (mhu1r_pwdata),
    .penable_rec              (mhu1r_penable),
    .pselx_rec                (mhu1r_psel),
    .prdata_rec               (mhu1r_prdata),
    .pready_rec               (mhu1r_pready),
    .pslverr_rec              (mhu1r_pslverr),
    .qreqn_pclk_rec           (1'b1),
    .qacceptn_pclk_rec        (),
    .qdeny_pclk_rec           (),
    .qactive_pclk_rec         (),
    .qreqn_pwr_rec            (mhu1_qreqn),
    .qacceptn_pwr_rec         (mhu1_qacceptn),
    .qdeny_pwr_rec            (mhu1_qdeny),
    .mhu_irqcomb              (mhu1r_cirq),
    .mhu_irq_reg              (),
    .apb_async_req            (mhu1r_async_req),
    .apb_async_req_payload    (mhu1r_async_req_payload),
    .apb_async_resp_payload   (mhu1r_async_resp_payload),
    .apb_async_ack            (mhu1r_async_ack),
    .recawake_async           (mhu1r_recawake_async),
    .recwakeup_async          (mhu1r_recwakeup_async),
    .edge_async_req           (mhu1r_edge_async_req),
    .edge_async_ack           (mhu1r_edge_async_ack),
    .dftcgen                  (dft_cgen)
  );

  mhuv2_f1_sender #( 
    .MHU_NUM_CH             (MHU_SEH1_NUM_CH)
  ) u_mhuv2_f1_sender_seh1 (
    .pclk_snd                 (clk),
    .presetn_snd              (rst_n),
    .pwakeup_snd              (1'b0), 
    .paddr_snd                (mhu1s_paddr),
    .pwrite_snd               (mhu1s_pwrite),
    .pwdata_snd               (mhu1s_pwdata),
    .penable_snd              (mhu1s_penable),
    .pselx_snd                (mhu1s_psel),
    .prdata_snd               (mhu1s_prdata),
    .pready_snd               (mhu1s_pready),
    .pslverr_snd              (mhu1s_pslverr),
    .qreqn_pclk_snd           (1'b1),
    .qacceptn_pclk_snd        (),
    .qdeny_pclk_snd           (),
    .qactive_pclk_snd         (),
    .apb_async_req            (mhu1s_async_req),
    .apb_async_req_payload    (mhu1s_async_req_payload),
    .apb_async_resp_payload   (mhu1s_async_resp_payload),
    .apb_async_ack            (mhu1s_async_ack),
    .recawake_async           (mhu1s_recawake_async),
    .recwakeup_async          (mhu1s_recwakeup_async),
    .int_access_nr2r          (),
    .int_access_r2nr          (),
    .int_irqcomb              (mhu1s_cirq),
    .edge_async_req           (mhu1s_edge_async_req),
    .edge_async_ack           (mhu1s_edge_async_ack),
    .dftcgen                  (dft_cgen)
  );

  

   mhuv2_f1_receiver #( // Local interface is receiver, integration interface is from external system 0 receiver
     .MHU_NUM_CH             (MHU_ES0SE0_NUM_CH)
   ) u_mhuv2_f1_receiver_es0se0 (
     .pclk_rec                 (clk),
     .presetn_rec              (rst_n),
     .pwakeup_rec              (1'b0), 
     .paddr_rec                (mhu2r_paddr),
     .pwrite_rec               (mhu2r_pwrite),
     .pwdata_rec               (mhu2r_pwdata),
     .penable_rec              (mhu2r_penable),
     .pselx_rec                (mhu2r_psel),
     .prdata_rec               (mhu2r_prdata),
     .pready_rec               (mhu2r_pready),
     .pslverr_rec              (mhu2r_pslverr),
     .qreqn_pclk_rec           (1'b1),
     .qacceptn_pclk_rec        (),
     .qdeny_pclk_rec           (),
     .qactive_pclk_rec         (),
     .qreqn_pwr_rec            (mhu2_qreqn),
     .qacceptn_pwr_rec         (mhu2_qacceptn),
     .qdeny_pwr_rec            (mhu2_qdeny),
     .mhu_irqcomb              (mhu2r_cirq),
     .mhu_irq_reg              (),
     .apb_async_req            (mhu2r_async_req),
     .apb_async_req_payload    (mhu2r_async_req_payload),
     .apb_async_resp_payload   (mhu2r_async_resp_payload),
     .apb_async_ack            (mhu2r_async_ack),
     .recawake_async           (mhu2r_recawake_async),
     .recwakeup_async          (mhu2r_recwakeup_async),
     .edge_async_req           (mhu2r_edge_async_req),
     .edge_async_ack           (mhu2r_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

   mhuv2_f1_sender #( 
     .MHU_NUM_CH             (MHU_SEES00_NUM_CH)
   ) u_mhuv2_f1_sender_sees00 (
     .pclk_snd                 (clk),
     .presetn_snd              (rst_n),
     .pwakeup_snd              (1'b0), 
     .paddr_snd                (mhu2s_paddr),
     .pwrite_snd               (mhu2s_pwrite),
     .pwdata_snd               (mhu2s_pwdata),
     .penable_snd              (mhu2s_penable),
     .pselx_snd                (mhu2s_psel),
     .prdata_snd               (mhu2s_prdata),
     .pready_snd               (mhu2s_pready),
     .pslverr_snd              (mhu2s_pslverr),
     .qreqn_pclk_snd           (1'b1),
     .qacceptn_pclk_snd        (),
     .qdeny_pclk_snd           (),
     .qactive_pclk_snd         (),
     .apb_async_req            (mhu2s_async_req),
     .apb_async_req_payload    (mhu2s_async_req_payload),
     .apb_async_resp_payload   (mhu2s_async_resp_payload),
     .apb_async_ack            (mhu2s_async_ack),
     .recawake_async           (mhu2s_recawake_async),
     .recwakeup_async          (mhu2s_recwakeup_async),
     .int_access_nr2r          (),
     .int_access_r2nr          (),
     .int_irqcomb              (mhu2s_cirq),
     .edge_async_req           (mhu2s_edge_async_req),
     .edge_async_ack           (mhu2s_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

     mhuv2_f1_receiver #( // Local interface is receiver, integration interface is from external system 0 receiver
     .MHU_NUM_CH             (MHU_ES0SE1_NUM_CH)
   ) u_mhuv2_f1_receiver_es0se1 (
     .pclk_rec                 (clk),
     .presetn_rec              (rst_n),
     .pwakeup_rec              (1'b0), 
     .paddr_rec                (mhu3r_paddr),
     .pwrite_rec               (mhu3r_pwrite),
     .pwdata_rec               (mhu3r_pwdata),
     .penable_rec              (mhu3r_penable),
     .pselx_rec                (mhu3r_psel),
     .prdata_rec               (mhu3r_prdata),
     .pready_rec               (mhu3r_pready),
     .pslverr_rec              (mhu3r_pslverr),
     .qreqn_pclk_rec           (1'b1),
     .qacceptn_pclk_rec        (),
     .qdeny_pclk_rec           (),
     .qactive_pclk_rec         (),
     .qreqn_pwr_rec            (mhu3_qreqn),
     .qacceptn_pwr_rec         (mhu3_qacceptn),
     .qdeny_pwr_rec            (mhu3_qdeny),
     .mhu_irqcomb              (mhu3r_cirq),
     .mhu_irq_reg              (),
     .apb_async_req            (mhu3r_async_req),
     .apb_async_req_payload    (mhu3r_async_req_payload),
     .apb_async_resp_payload   (mhu3r_async_resp_payload),
     .apb_async_ack            (mhu3r_async_ack),
     .recawake_async           (mhu3r_recawake_async),
     .recwakeup_async          (mhu3r_recwakeup_async),
     .edge_async_req           (mhu3r_edge_async_req),
     .edge_async_ack           (mhu3r_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

   mhuv2_f1_sender #( 
     .MHU_NUM_CH             (MHU_SEES01_NUM_CH)
   ) u_mhuv2_f1_sender_sees01 (
     .pclk_snd                 (clk),
     .presetn_snd              (rst_n),
     .pwakeup_snd              (1'b0), 
     .paddr_snd                (mhu3s_paddr),
     .pwrite_snd               (mhu3s_pwrite),
     .pwdata_snd               (mhu3s_pwdata),
     .penable_snd              (mhu3s_penable),
     .pselx_snd                (mhu3s_psel),
     .prdata_snd               (mhu3s_prdata),
     .pready_snd               (mhu3s_pready),
     .pslverr_snd              (mhu3s_pslverr),
     .qreqn_pclk_snd           (1'b1),
     .qacceptn_pclk_snd        (),
     .qdeny_pclk_snd           (),
     .qactive_pclk_snd         (),
     .apb_async_req            (mhu3s_async_req),
     .apb_async_req_payload    (mhu3s_async_req_payload),
     .apb_async_resp_payload   (mhu3s_async_resp_payload),
     .apb_async_ack            (mhu3s_async_ack),
     .recawake_async           (mhu3s_recawake_async),
     .recwakeup_async          (mhu3s_recwakeup_async),
     .int_access_nr2r          (),
     .int_access_r2nr          (),
     .int_irqcomb              (mhu3s_cirq),
     .edge_async_req           (mhu3s_edge_async_req),
     .edge_async_ack           (mhu3s_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );
        
    

   mhuv2_f1_receiver #( // Local interface is receiver, integration interface is from external system 1 receiver
     .MHU_NUM_CH             (MHU_ES1SE0_NUM_CH)
   ) u_mhuv2_f1_receiver_es1se0 (
     .pclk_rec                 (clk),
     .presetn_rec              (rst_n),
     .pwakeup_rec              (1'b0), 
     .paddr_rec                (mhu4r_paddr),
     .pwrite_rec               (mhu4r_pwrite),
     .pwdata_rec               (mhu4r_pwdata),
     .penable_rec              (mhu4r_penable),
     .pselx_rec                (mhu4r_psel),
     .prdata_rec               (mhu4r_prdata),
     .pready_rec               (mhu4r_pready),
     .pslverr_rec              (mhu4r_pslverr),
     .qreqn_pclk_rec           (1'b1),
     .qacceptn_pclk_rec        (),
     .qdeny_pclk_rec           (),
     .qactive_pclk_rec         (),
     .qreqn_pwr_rec            (mhu4_qreqn),
     .qacceptn_pwr_rec         (mhu4_qacceptn),
     .qdeny_pwr_rec            (mhu4_qdeny),
     .mhu_irqcomb              (mhu4r_cirq),
     .mhu_irq_reg              (),
     .apb_async_req            (mhu4r_async_req),
     .apb_async_req_payload    (mhu4r_async_req_payload),
     .apb_async_resp_payload   (mhu4r_async_resp_payload),
     .apb_async_ack            (mhu4r_async_ack),
     .recawake_async           (mhu4r_recawake_async),
     .recwakeup_async          (mhu4r_recwakeup_async),
     .edge_async_req           (mhu4r_edge_async_req),
     .edge_async_ack           (mhu4r_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

   mhuv2_f1_sender #( 
     .MHU_NUM_CH             (MHU_SEES10_NUM_CH)
   ) u_mhuv2_f1_sender_sees10 (
     .pclk_snd                 (clk),
     .presetn_snd              (rst_n),
     .pwakeup_snd              (1'b0), 
     .paddr_snd                (mhu4s_paddr),
     .pwrite_snd               (mhu4s_pwrite),
     .pwdata_snd               (mhu4s_pwdata),
     .penable_snd              (mhu4s_penable),
     .pselx_snd                (mhu4s_psel),
     .prdata_snd               (mhu4s_prdata),
     .pready_snd               (mhu4s_pready),
     .pslverr_snd              (mhu4s_pslverr),
     .qreqn_pclk_snd           (1'b1),
     .qacceptn_pclk_snd        (),
     .qdeny_pclk_snd           (),
     .qactive_pclk_snd         (),
     .apb_async_req            (mhu4s_async_req),
     .apb_async_req_payload    (mhu4s_async_req_payload),
     .apb_async_resp_payload   (mhu4s_async_resp_payload),
     .apb_async_ack            (mhu4s_async_ack),
     .recawake_async           (mhu4s_recawake_async),
     .recwakeup_async          (mhu4s_recwakeup_async),
     .int_access_nr2r          (),
     .int_access_r2nr          (),
     .int_irqcomb              (mhu4s_cirq),
     .edge_async_req           (mhu4s_edge_async_req),
     .edge_async_ack           (mhu4s_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

     mhuv2_f1_receiver #( // Local interface is receiver, integration interface is from external system 1 receiver
     .MHU_NUM_CH             (MHU_ES1SE1_NUM_CH)
   ) u_mhuv2_f1_receiver_es1se1 (
     .pclk_rec                 (clk),
     .presetn_rec              (rst_n),
     .pwakeup_rec              (1'b0), 
     .paddr_rec                (mhu5r_paddr),
     .pwrite_rec               (mhu5r_pwrite),
     .pwdata_rec               (mhu5r_pwdata),
     .penable_rec              (mhu5r_penable),
     .pselx_rec                (mhu5r_psel),
     .prdata_rec               (mhu5r_prdata),
     .pready_rec               (mhu5r_pready),
     .pslverr_rec              (mhu5r_pslverr),
     .qreqn_pclk_rec           (1'b1),
     .qacceptn_pclk_rec        (),
     .qdeny_pclk_rec           (),
     .qactive_pclk_rec         (),
     .qreqn_pwr_rec            (mhu5_qreqn),
     .qacceptn_pwr_rec         (mhu5_qacceptn),
     .qdeny_pwr_rec            (mhu5_qdeny),
     .mhu_irqcomb              (mhu5r_cirq),
     .mhu_irq_reg              (),
     .apb_async_req            (mhu5r_async_req),
     .apb_async_req_payload    (mhu5r_async_req_payload),
     .apb_async_resp_payload   (mhu5r_async_resp_payload),
     .apb_async_ack            (mhu5r_async_ack),
     .recawake_async           (mhu5r_recawake_async),
     .recwakeup_async          (mhu5r_recwakeup_async),
     .edge_async_req           (mhu5r_edge_async_req),
     .edge_async_ack           (mhu5r_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );

   mhuv2_f1_sender #( 
     .MHU_NUM_CH             (MHU_SEES11_NUM_CH)
   ) u_mhuv2_f1_sender_sees11 (
     .pclk_snd                 (clk),
     .presetn_snd              (rst_n),
     .pwakeup_snd              (1'b0), 
     .paddr_snd                (mhu5s_paddr),
     .pwrite_snd               (mhu5s_pwrite),
     .pwdata_snd               (mhu5s_pwdata),
     .penable_snd              (mhu5s_penable),
     .pselx_snd                (mhu5s_psel),
     .prdata_snd               (mhu5s_prdata),
     .pready_snd               (mhu5s_pready),
     .pslverr_snd              (mhu5s_pslverr),
     .qreqn_pclk_snd           (1'b1),
     .qacceptn_pclk_snd        (),
     .qdeny_pclk_snd           (),
     .qactive_pclk_snd         (),
     .apb_async_req            (mhu5s_async_req),
     .apb_async_req_payload    (mhu5s_async_req_payload),
     .apb_async_resp_payload   (mhu5s_async_resp_payload),
     .apb_async_ack            (mhu5s_async_ack),
     .recawake_async           (mhu5s_recawake_async),
     .recwakeup_async          (mhu5s_recwakeup_async),
     .int_access_nr2r          (),
     .int_access_r2nr          (),
     .int_irqcomb              (mhu5s_cirq),
     .edge_async_req           (mhu5s_edge_async_req),
     .edge_async_ack           (mhu5s_edge_async_ack),
     .dftcgen                  (dft_cgen)
   );
        
    
endmodule
