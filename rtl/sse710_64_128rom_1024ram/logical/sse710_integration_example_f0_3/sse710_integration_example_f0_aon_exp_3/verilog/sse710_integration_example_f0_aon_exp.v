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

module sse710_integration_example_f0_aon_exp (

    input  wire           s32kclk,
    input  wire           hostaonexpclk,
    input  wire           refclk,

    input  wire           aontop_warmresetn_s_s32kclk,
    input  wire           aontop_warmresetn_s_hostaonexpclk,

    input  wire           aonexp_psel,
    input  wire           aonexp_penable,
    input  wire           aonexp_pwrite,
    input  wire [2:0]     aonexp_pprot,
    input  wire [3:0]     aonexp_pstrb,
    input  wire [31:0]    aonexp_paddr,
    input  wire [31:0]    aonexp_pwdata,
    output wire [31:0]    aonexp_prdata,
    output wire           aonexp_pready,
    output wire           aonexp_pslverr,

    output wire           rtc_irq,
    
    input  wire           dftcgen,
    //change for qinglongv200
    output wire           qspi_psel,
    input wire [31:0]    qspi_prdata,
    input wire           qspi_pready
  );


  wire           rtc_psel;
  wire           rtc_penable;
  wire           rtc_pwrite;
  wire [9:0]     rtc_paddr;
  wire [31:0]    rtc_pwdata;
  wire [31:0]    rtc_prdata;
  wire           rtc_pslverr;
  wire           rtc_pready;
  
  reg            rtc_irq_r;
  wire           rtc_irq_int;  
  
  wire           refcl_gated_en;
  wire           refclk_gated;
  reg            s32k_toggle;
  wire           s32k_toggle_ss;
  reg            s32k_toggle_sss;
    
  
  wire  [3:0]    decode4bit;
  
  wire           unused;

  //change for qinglongv200
  assign decode4bit = (aonexp_paddr[19:16] == 4'h0000) ? 4'b0000 :
                      (aonexp_paddr[19:16] == 4'h0001) ? 4'b0001 :
                      (aonexp_paddr[19:16] == 4'h0002) ? 4'b0010 :
                      (aonexp_paddr[19:16] == 4'h0003) ? 4'b0011 :
                      (aonexp_paddr[19:16] == 4'h0004) ? 4'b0100 :
                      (aonexp_paddr[19:16] == 4'h0005) ? 4'b0101 :
                      (aonexp_paddr[19:16] == 4'h0006) ? 4'b0110 :
                      (aonexp_paddr[19:16] == 4'h0007) ? 4'b0111 :
                      (aonexp_paddr[19:16] == 4'h0008) ? 4'b1000 :
                      (aonexp_paddr[19:16] == 4'h0009) ? 4'b1001 :
                      (aonexp_paddr[19:16] == 4'h000a) ? 4'b1010 :
                      (aonexp_paddr[19:16] == 4'h000b) ? 4'b1011 :
                      (aonexp_paddr[19:16] == 4'h000c) ? 4'b1100 :
                      (aonexp_paddr[19:16] == 4'h000d) ? 4'b1101 :
                      (aonexp_paddr[19:16] == 4'h000e) ? 4'b1110 :
                      (aonexp_paddr[19:16] == 4'h000f) ? 4'b1111 :
                      4'b0000;
  //assign decode4bit = (aonexp_paddr[19:12] == 8'h00) ? 4'b0000 : 4'b0001;
  

  cmsdk_apb_slave_mux #(
    .PORT0_ENABLE   (1),
    .PORT1_ENABLE   (1),  
    .PORT2_ENABLE   (0),
    .PORT3_ENABLE   (0),  
    .PORT4_ENABLE   (0),
    .PORT5_ENABLE   (0),
    .PORT6_ENABLE   (0),
    .PORT7_ENABLE   (0),
    .PORT8_ENABLE   (0),
    .PORT9_ENABLE   (0),
    .PORT10_ENABLE  (0),
    .PORT11_ENABLE  (0),
    .PORT12_ENABLE  (0),
    .PORT13_ENABLE  (0),
    .PORT14_ENABLE  (0),
    .PORT15_ENABLE  (0)
    )
  u_cmsdk_apb_slave_mux (
    .DECODE4BIT     (decode4bit),
    .PSEL           (aonexp_psel),
  
    .PSEL0          (rtc_psel),
    .PREADY0        (rtc_pready),
    .PRDATA0        (rtc_prdata),
    .PSLVERR0       (rtc_pslverr),
  
    .PSEL1          (qspi_psel),            
    .PREADY1        (qspi_pready),        
    .PRDATA1        (qspi_prdata),
    .PSLVERR1       (1'b0),        
  
    .PSEL2          (),            
    .PREADY2        (1'b1),        
    .PRDATA2        (32'h00000000),
    .PSLVERR2       (1'b1),        
  
    .PSEL3          (),
    .PREADY3        (1'b1),
    .PRDATA3        (32'h00000000),
    .PSLVERR3       (1'b1),
  
    .PSEL4          (),
    .PREADY4        (1'b1),
    .PRDATA4        (32'h00000000),
    .PSLVERR4       (1'b1),
  
    .PSEL5          (),
    .PREADY5        (1'b1),
    .PRDATA5        (32'h00000000),
    .PSLVERR5       (1'b1),
  
    .PSEL6          (),
    .PREADY6        (1'b1),
    .PRDATA6        (32'h00000000),
    .PSLVERR6       (1'b1),
  
    .PSEL7          (),
    .PREADY7        (1'b1),
    .PRDATA7        (32'h00000000),
    .PSLVERR7       (1'b1),
  
    .PSEL8          (),
    .PREADY8        (1'b1),
    .PRDATA8        (32'h00000000),
    .PSLVERR8       (1'b1),
  
    .PSEL9          (),
    .PREADY9        (1'b1),
    .PRDATA9        (32'h00000000),
    .PSLVERR9       (1'b1),
  
    .PSEL10         (),
    .PREADY10       (1'b1),
    .PRDATA10       (32'h00000000),
    .PSLVERR10      (1'b1),
  
    .PSEL11         (),
    .PREADY11       (1'b1),
    .PRDATA11       (32'h00000000),
    .PSLVERR11      (1'b1),
  
    .PSEL12         (),
    .PREADY12       (1'b1),
    .PRDATA12       (32'h00000000),
    .PSLVERR12      (1'b1),
  
    .PSEL13         (),
    .PREADY13       (1'b1),
    .PRDATA13       (32'h00000000),
    .PSLVERR13      (1'b1),
  
    .PSEL14         (),
    .PREADY14       (1'b1),
    .PRDATA14       (32'h00000000),
    .PSLVERR14      (1'b1),
  
    .PSEL15         (),
    .PREADY15       (1'b1),
    .PRDATA15       (32'h00000000),
    .PSLVERR15      (1'b1),
  
    .PREADY         (aonexp_pready),
    .PRDATA         (aonexp_prdata),
    .PSLVERR        (aonexp_pslverr)
  );



  assign rtc_penable  = aonexp_penable;
  assign rtc_pwrite   = aonexp_pwrite;
  assign rtc_paddr    = aonexp_paddr[11:2];
  assign rtc_pwdata   = aonexp_pwdata;
  assign rtc_pslverr  = 1'b0;     


  Rtc u_Rtc (
    .PCLK              (hostaonexpclk),
    .PRESETn           (aontop_warmresetn_s_hostaonexpclk),
    .PSEL              (rtc_psel),
    .PENABLE           (rtc_penable),
    .PWRITE            (rtc_pwrite),
    .PADDR             (rtc_paddr),
    .PWDATA            (rtc_pwdata),
    .CLK1HZ            (refclk_gated),
    .nRTCRST           (aontop_warmresetn_s_hostaonexpclk),
    .nPOR              (aontop_warmresetn_s_hostaonexpclk),
    .SCANENABLE        (1'b0),
    .SCANINPCLK        (1'b0),
    .SCANINCLK1HZ      (1'b0),
    .PRDATA            (rtc_prdata),
    .RTCINTR           (rtc_irq_int),
    .SCANOUTPCLK       (),
    .SCANOUTCLK1HZ     ()
    );
  
  assign rtc_pready = 1'b1;
    
  always @(posedge s32kclk or negedge aontop_warmresetn_s_s32kclk)
  begin
    if(!aontop_warmresetn_s_s32kclk)
      s32k_toggle <= 1'b0;
    else
      s32k_toggle <= ~s32k_toggle;
  end
  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync ( 
    .clk      (refclk),
    .nreset   (aontop_warmresetn_s_hostaonexpclk),
    .d_async  (s32k_toggle),
    .q        (s32k_toggle_ss)
  );
  
  always @(posedge refclk or negedge aontop_warmresetn_s_hostaonexpclk)
  begin
    if(!aontop_warmresetn_s_hostaonexpclk)
      s32k_toggle_sss <= 1'b0;
    else
      s32k_toggle_sss <= s32k_toggle_ss;
  end  
  
  arm_element_std_xor2 u_arm_element_std_xor2
  (
    .A   (s32k_toggle_ss),
    .B   (s32k_toggle_sss),
    .Y   (refcl_gated_en)
  );
  
  arm_element_clock_gate u_arm_element_clock_gate (
    .clk_in    (refclk),
    .enable    (refcl_gated_en),
    .clk_out   (refclk_gated),
    .dftcgen   (dftcgen)
  );
  
  always @(posedge refclk or negedge aontop_warmresetn_s_hostaonexpclk)
  begin
    if(!aontop_warmresetn_s_hostaonexpclk)
      rtc_irq_r <= 1'b0;
    else
      rtc_irq_r <= rtc_irq_int;
  end    
  
  assign rtc_irq = rtc_irq_r;

  assign unused = (|aonexp_paddr[1:0])   | 
                  (|aonexp_paddr[31:20]) |
                  (|aonexp_pstrb)        |
                  (|aonexp_pprot);

endmodule
