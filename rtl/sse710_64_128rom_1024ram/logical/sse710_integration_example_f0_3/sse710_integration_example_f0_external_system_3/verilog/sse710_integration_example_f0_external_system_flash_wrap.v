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

module sse710_integration_example_f0_flash_wrap (
    
    input  wire                                 hclk,
    input  wire                                 pclk,
    input  wire                                 pclkg,
    
    input  wire                                 hresetn,
        
    input  wire                                 targflash0_hsel_i,         
    input  wire [31:0]                          targflash0_haddr_i,        
    input  wire [1:0]                           targflash0_htrans_i,       
    input  wire                                 targflash0_hwrite_i,       
    input  wire [2:0]                           targflash0_hsize_i,        
    input  wire [2:0]                           targflash0_hburst_i,       
    input  wire [3:0]                           targflash0_hprot_i,        
    input  wire [1:0]                           targflash0_memattr_i,
    input  wire                                 targflash0_exreq_i,
    input  wire [3:0]                           targflash0_hmaster_i,
    input  wire [31:0]                          targflash0_hwdata_i,       
    input  wire                                 targflash0_hmastlock_i,    
    input  wire                                 targflash0_hreadymux_i,    
    input  wire                                 targflash0_hauser_i,       
    input  wire [3:0]                           targflash0_hwuser_i,       

    output wire [31:0]                          targflash0_hrdata_o,       
    output wire                                 targflash0_hreadyout_o,    
    output wire                                 targflash0_hresp_o,        
    output wire                                 targflash0_exresp_o,
    output wire [2:0]                           targflash0_hruser_o,       

    output wire                                 flash_err_o,               
    output wire                                 flash_int_o,               

    input  wire                                 apbtargexp3_psel_i,        
    input  wire                                 apbtargexp3_penable_i,     
    input  wire [11:0]                          apbtargexp3_paddr_i,       
    input  wire                                 apbtargexp3_pwrite_i,      
    input  wire [31:0]                          apbtargexp3_pwdata_i,      
    output wire [31:0]                          apbtargexp3_prdata_o,      
    output wire                                 apbtargexp3_pready_o,      
    output wire                                 apbtargexp3_pslverr_o,     
    input  wire [3:0]                           apbtargexp3_pstrb_i,       
    input  wire [2:0]                           apbtargexp3_pprot_i,       

    input  wire                                 apbtargexp9_psel_i,        
    input  wire                                 apbtargexp9_penable_i,     
    input  wire [11:0]                          apbtargexp9_paddr_i,       
    input  wire                                 apbtargexp9_pwrite_i,      
    input  wire [31:0]                          apbtargexp9_pwdata_i,      
    output wire [31:0]                          apbtargexp9_prdata_o,      
    output wire                                 apbtargexp9_pready_o,      
    output wire                                 apbtargexp9_pslverr_o,     
    input  wire [3:0]                           apbtargexp9_pstrb_i,       
    input  wire [2:0]                           apbtargexp9_pprot_i,       

    input  wire                                 apbtargexp10_psel_i,       
    input  wire                                 apbtargexp10_penable_i,    
    input  wire [11:0]                          apbtargexp10_paddr_i,      
    input  wire                                 apbtargexp10_pwrite_i,     
    input  wire [31:0]                          apbtargexp10_pwdata_i,     
    output wire [31:0]                          apbtargexp10_prdata_o,     
    output wire                                 apbtargexp10_pready_o,     
    output wire                                 apbtargexp10_pslverr_o,    
    input  wire [3:0]                           apbtargexp10_pstrb_i,      
    input  wire [2:0]                           apbtargexp10_pprot_i       
  );


  reg  [1:0]   targflash0haddr_3_2_q;
  reg  [31:0]  targflash0hrdata;
  wire [127:0] targflash0hrdata_128;

  wire unused = pclk                     | pclkg                    |
                (|targflash0_hprot_i)    |(|targflash0_haddr_i[31:18]) |
                (|targflash0_memattr_i)  |
                targflash0_exreq_i       | (|targflash0_hmaster_i)  |
                targflash0_hmastlock_i   | targflash0_hauser_i      |
                (|targflash0_hwuser_i)   | (|targflash0_hburst_i)   |
                apbtargexp3_psel_i       | apbtargexp3_penable_i    |
                (|apbtargexp3_paddr_i)   | apbtargexp3_pwrite_i     |
                (|apbtargexp3_pwdata_i)  | (|apbtargexp3_pstrb_i)   |
                (|apbtargexp3_pprot_i)   |
                apbtargexp9_psel_i       | apbtargexp9_penable_i    |
                (|apbtargexp9_paddr_i)   | apbtargexp9_pwrite_i     |
                (|apbtargexp9_pwdata_i)  | (|apbtargexp9_pstrb_i)   |
                (|apbtargexp9_pprot_i)   |
                apbtargexp10_psel_i      | apbtargexp10_penable_i   |
                (|apbtargexp10_paddr_i)  | apbtargexp10_pwrite_i    |
                (|apbtargexp10_pwdata_i) | (|apbtargexp10_pstrb_i)  |
                (|apbtargexp10_pprot_i);
                

    sse710_integration_example_f0_blockram_128
    #(.ADDRESSWIDTH(18)) 
    u_sse710_integration_example_f0_blockram_128
    (
    .HCLK                 (hclk),
    .HRESETn              (hresetn),
    .HSELBRAM             (targflash0_hsel_i),
    .HREADY               (targflash0_hreadymux_i),
    .HTRANS               (targflash0_htrans_i),
    .HSIZE                (targflash0_hsize_i),
    .HWRITE               (targflash0_hwrite_i),
    .HADDR                (targflash0_haddr_i[17:0]),
    .HWDATA               ({4{targflash0_hwdata_i}}),
    .HREADYOUT            (targflash0_hreadyout_o),
    .HRESP                (targflash0_hresp_o),
    .HRDATA               (targflash0hrdata_128)
    );

  assign targflash0_exresp_o = 1'b0;
  assign targflash0_hruser_o = 3'b000;

  always @(posedge hclk)
      targflash0haddr_3_2_q <= targflash0_haddr_i[3:2];

  always @(targflash0hrdata_128 or targflash0haddr_3_2_q)
      case (targflash0haddr_3_2_q)
          2'b00   : targflash0hrdata = targflash0hrdata_128[31:0];
          2'b01   : targflash0hrdata = targflash0hrdata_128[63:32];
          2'b10   : targflash0hrdata = targflash0hrdata_128[95:64];
          2'b11   : targflash0hrdata = targflash0hrdata_128[127:96];
          default : targflash0hrdata = {32{1'bx}};
      endcase

  assign targflash0_hrdata_o = targflash0hrdata;

  assign flash_err_o = 1'b0;      
  assign flash_int_o = 1'b0;      


  assign apbtargexp3_prdata_o  = {32{1'b0}};
  assign apbtargexp3_pready_o  = 1'b1;
  assign apbtargexp3_pslverr_o = 1'b0;
  assign apbtargexp9_prdata_o  = {32{1'b0}};
  assign apbtargexp9_pready_o  = 1'b1;
  assign apbtargexp9_pslverr_o = 1'b0;
  assign apbtargexp10_prdata_o  = {32{1'b0}};
  assign apbtargexp10_pready_o  = 1'b1;
  assign apbtargexp10_pslverr_o = 1'b0;

endmodule
