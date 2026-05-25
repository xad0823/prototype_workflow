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

module sse710_integration_example_f0_external_system_memories (
    
    input  wire            extsys_hclk,
    
    input  wire            extsys_mtx_resetn,
        
    input  wire            targflash0_hsel,         
    input  wire [31:0]     targflash0_haddr,        
    input  wire [1:0]      targflash0_htrans,       
    input  wire            targflash0_hwrite,       
    input  wire [2:0]      targflash0_hsize,        
    input  wire [2:0]      targflash0_hburst,       
    input  wire [3:0]      targflash0_hprot,        
    input  wire [1:0]      targflash0_memattr,
    input  wire            targflash0_exreq,
    input  wire [3:0]      targflash0_hmaster,
    input  wire [31:0]     targflash0_hwdata,       
    input  wire            targflash0_hmastlock,    
    input  wire            targflash0_hreadymux,    
    input  wire            targflash0_hauser,       
    input  wire [3:0]      targflash0_hwuser,       

    output wire [31:0]     targflash0_hrdata,       
    output wire            targflash0_hreadyout,    
    output wire            targflash0_hresp,        
    output wire            targflash0_exresp,
    output wire [2:0]      targflash0_hruser,       

    output wire            flash_err,               
    output wire            flash_int,               

    input  wire            apbtargexp3_psel,        
    input  wire            apbtargexp3_penable,     
    input  wire [11:0]     apbtargexp3_paddr,       
    input  wire            apbtargexp3_pwrite,      
    input  wire [31:0]     apbtargexp3_pwdata,      
    output wire [31:0]     apbtargexp3_prdata,      
    output wire            apbtargexp3_pready,      
    output wire            apbtargexp3_pslverr,     
    input  wire [3:0]      apbtargexp3_pstrb,       
    input  wire [2:0]      apbtargexp3_pprot,       

    input  wire            apbtargexp9_psel,        
    input  wire            apbtargexp9_penable,     
    input  wire [11:0]     apbtargexp9_paddr,       
    input  wire            apbtargexp9_pwrite,      
    input  wire [31:0]     apbtargexp9_pwdata,      
    output wire [31:0]     apbtargexp9_prdata,      
    output wire            apbtargexp9_pready,      
    output wire            apbtargexp9_pslverr,     
    input  wire [3:0]      apbtargexp9_pstrb,       
    input  wire [2:0]      apbtargexp9_pprot,       

    input  wire            apbtargexp10_psel,       
    input  wire            apbtargexp10_penable,    
    input  wire [11:0]     apbtargexp10_paddr,      
    input  wire            apbtargexp10_pwrite,     
    input  wire [31:0]     apbtargexp10_pwdata,     
    output wire [31:0]     apbtargexp10_prdata,     
    output wire            apbtargexp10_pready,     
    output wire            apbtargexp10_pslverr,    
    input  wire [3:0]      apbtargexp10_pstrb,      
    input  wire [2:0]      apbtargexp10_pprot,      
    
    
    output  wire [31:0]    sram0_rdata,       
    input   wire [12:0]    sram0_addr,        
    input   wire [3:0]     sram0_wren,        
    input   wire [31:0]    sram0_wdata,       
    input   wire           sram0_cs,

    input  wire            dftramhold    
    
  );


  sse710_integration_example_f0_flash_wrap u_sse710_integration_example_f0_flash_wrap(
    .hclk                  (extsys_hclk),
    .hresetn               (extsys_mtx_resetn),
    .targflash0_hsel_i     (targflash0_hsel),
    .targflash0_haddr_i    (targflash0_haddr),
    .targflash0_htrans_i   (targflash0_htrans),
    .targflash0_hwrite_i   (targflash0_hwrite),
    .targflash0_hsize_i    (targflash0_hsize),
    .targflash0_hburst_i   (targflash0_hburst),
    .targflash0_hprot_i    (targflash0_hprot),
    .targflash0_memattr_i  (targflash0_memattr),
    .targflash0_exreq_i    (targflash0_exreq),
    .targflash0_hmaster_i  (targflash0_hmaster),
    .targflash0_hwdata_i   (targflash0_hwdata),
    .targflash0_hmastlock_i(targflash0_hmastlock),
    .targflash0_hreadymux_i(targflash0_hreadymux),
    .targflash0_hauser_i   (targflash0_hauser),
    .targflash0_hwuser_i   (targflash0_hwuser),
    .targflash0_hrdata_o   (targflash0_hrdata),
    .targflash0_hreadyout_o(targflash0_hreadyout),
    .targflash0_hresp_o    (targflash0_hresp),
    .targflash0_exresp_o   (targflash0_exresp),
    .targflash0_hruser_o   (targflash0_hruser),
    .flash_err_o           (flash_err),    
    .flash_int_o           (flash_int),    

    .pclk                  (extsys_hclk),
    .pclkg                 (extsys_hclk),
    .apbtargexp3_psel_i    (apbtargexp3_psel),
    .apbtargexp3_penable_i (apbtargexp3_penable),
    .apbtargexp3_paddr_i   (apbtargexp3_paddr),
    .apbtargexp3_pwrite_i  (apbtargexp3_pwrite),
    .apbtargexp3_pwdata_i  (apbtargexp3_pwdata),
    .apbtargexp3_prdata_o  (apbtargexp3_prdata),
    .apbtargexp3_pready_o  (apbtargexp3_pready),
    .apbtargexp3_pslverr_o (apbtargexp3_pslverr),
    .apbtargexp3_pstrb_i   (apbtargexp3_pstrb),
    .apbtargexp3_pprot_i   (apbtargexp3_pprot),

    .apbtargexp9_psel_i    (apbtargexp9_psel),
    .apbtargexp9_penable_i (apbtargexp9_penable),
    .apbtargexp9_paddr_i   (apbtargexp9_paddr),
    .apbtargexp9_pwrite_i  (apbtargexp9_pwrite),
    .apbtargexp9_pwdata_i  (apbtargexp9_pwdata),
    .apbtargexp9_prdata_o  (apbtargexp9_prdata),
    .apbtargexp9_pready_o  (apbtargexp9_pready),
    .apbtargexp9_pslverr_o (apbtargexp9_pslverr),
    .apbtargexp9_pstrb_i   (apbtargexp9_pstrb),
    .apbtargexp9_pprot_i   (apbtargexp9_pprot),

    .apbtargexp10_psel_i   (apbtargexp10_psel),
    .apbtargexp10_penable_i(apbtargexp10_penable),
    .apbtargexp10_paddr_i  (apbtargexp10_paddr),
    .apbtargexp10_pwrite_i (apbtargexp10_pwrite),
    .apbtargexp10_pwdata_i (apbtargexp10_pwdata),
    .apbtargexp10_prdata_o (apbtargexp10_prdata),
    .apbtargexp10_pready_o (apbtargexp10_pready),
    .apbtargexp10_pslverr_o(apbtargexp10_pslverr),
    .apbtargexp10_pstrb_i  (apbtargexp10_pstrb),
    .apbtargexp10_pprot_i  (apbtargexp10_pprot)
  );


  `ifdef QL_FPGA
 ram8192x32 mem (
       .clka  ( extsys_hclk ),
       .dina  ( sram0_wdata ),
       .ena   ( ~(((~sram0_cs) | dftramhold)) ),
       .addra ( sram0_addr ),
       .wea   ( ~((~sram0_wren)) ),
       .douta ( sram0_rdata ));
`else
arm_element_sp_ram_wstrb #(
    .DATA_WIDTH       (32),
    .MEMORY_DEPTH     (8192)    
  ) u_arm_element_sp_ram (
    .CLK              (extsys_hclk),
    .A                (sram0_addr),
    .CEN              ((~sram0_cs) | dftramhold),   
    .WEN              (~sram0_wren),                
    .Q                (sram0_rdata),
    .D                (sram0_wdata)
  );
`endif



endmodule
