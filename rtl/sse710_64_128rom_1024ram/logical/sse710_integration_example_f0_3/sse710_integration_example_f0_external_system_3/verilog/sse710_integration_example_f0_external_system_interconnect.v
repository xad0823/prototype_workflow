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

module sse710_integration_example_f0_external_system_interconnect #(
  
    parameter             MEM_DATA_WIDTH = 64 
  
  )(
    
    input  wire           extsys_hclk,
    
    input  wire           extsys_mtx_resetn,

    input  wire           expclk_qreqn,        
    output wire           expclk_qacceptn,    
    output wire           expclk_qdeny,      
    output wire           expclk_qactive,                      
    
    input  wire           targexp1_hsel,           
    input  wire [31:0]    targexp1_haddr,         
    input  wire  [1:0]    targexp1_htrans,         
    input  wire           targexp1_hwrite,         
    input  wire  [2:0]    targexp1_hsize,          
    input  wire  [2:0]    targexp1_hburst,         
    input  wire  [3:0]    targexp1_hprot,          
    input  wire  [1:0]    targexp1_memattr,
    input  wire           targexp1_exreq,
    input  wire  [3:0]    targexp1_hmaster,
    input  wire [31:0]    targexp1_hwdata,         
    input  wire           targexp1_hmastlock,      
    input  wire           targexp1_hreadymux,     
    input  wire           targexp1_hauser,         
    input  wire  [3:0]    targexp1_hwuser,        
    output wire [31:0]    targexp1_hrdata,         
    output wire           targexp1_hreadyout,     
    output wire           targexp1_hresp,          
    output wire           targexp1_exresp,
    output wire  [2:0]    targexp1_hruser,    
    
    output wire           initexp0_hsel,           
    output wire [31:0]    initexp0_haddr,         
    output wire  [1:0]    initexp0_htrans,         
    output wire           initexp0_hwrite,         
    output wire  [2:0]    initexp0_hsize,          
    output wire  [2:0]    initexp0_hburst,         
    output wire  [3:0]    initexp0_hprot,          
    output wire  [1:0]    initexp0_memattr,
    output wire           initexp0_exreq,
    output wire  [3:0]    initexp0_hmaster,
    output wire [31:0]    initexp0_hwdata,         
    output wire           initexp0_hmastlock,      
    output wire           initexp0_hauser,         
    output wire  [3:0]    initexp0_hwuser,        
    input  wire           initexp0_hready,     
    input  wire [31:0]    initexp0_hrdata,         
    input  wire           initexp0_hresp,          
    input  wire           initexp0_exresp,
    input  wire  [2:0]    initexp0_hruser, 

    input  wire           apbtargexp2_psel,        
    input  wire           apbtargexp2_penable,     
    input  wire [11:0]    apbtargexp2_paddr,       
    input  wire           apbtargexp2_pwrite,     
    input  wire [31:0]    apbtargexp2_pwdata, 
    input  wire [3:0]     apbtargexp2_pstrb,       
    input  wire [2:0]     apbtargexp2_pprot,         
    output wire [31:0]    apbtargexp2_prdata,     
    output wire           apbtargexp2_pready,     
    output wire           apbtargexp2_pslverr, 

    input  wire           apbtargexp11_psel,        
    input  wire           apbtargexp11_penable,     
    input  wire [11:0]    apbtargexp11_paddr,       
    input  wire           apbtargexp11_pwrite,     
    input  wire [31:0]    apbtargexp11_pwdata, 
    input  wire [3:0]     apbtargexp11_pstrb,       
    input  wire [2:0]     apbtargexp11_pprot,         
    output wire [31:0]    apbtargexp11_prdata,     
    output wire           apbtargexp11_pready,     
    output wire           apbtargexp11_pslverr,     
    
    output wire           mem_awakeup,
    output wire           mem_awid,
    output wire [31:0]    mem_awaddr,
    output wire [7:0]     mem_awlen,
    output wire [2:0]     mem_awsize,
    output wire [1:0]     mem_awburst,
    output wire           mem_awlock,
    output wire [3:0]     mem_awcache,
    output wire [2:0]     mem_awprot,    
    output wire           mem_awvalid,
    input  wire           mem_awready,

    output wire [(MEM_DATA_WIDTH/8)-1:0]     mem_wstrb,
    output wire           mem_wlast,
    output wire           mem_wvalid,
    output wire [MEM_DATA_WIDTH-1:0]    mem_wdata,
    input  wire           mem_wready,

    input  wire           mem_bid,
    input  wire [1:0]     mem_bresp,
    input  wire           mem_bvalid,
    output wire           mem_bready,

    output wire           mem_arid, 
    output wire [31:0]    mem_araddr,
    output wire [7:0]     mem_arlen,
    output wire [2:0]     mem_arsize,
    output wire [1:0]     mem_arburst,
    output wire           mem_arlock,
    output wire [3:0]     mem_arcache,
    output wire [2:0]     mem_arprot,     
    output wire           mem_arvalid,
    input  wire           mem_arready,

    input  wire           mem_rid, 
    input  wire [1:0]     mem_rresp,
    input  wire           mem_rlast,
    input  wire           mem_rvalid,
    input  wire [MEM_DATA_WIDTH-1:0]    mem_rdata,
    output wire           mem_rready,
    
    input  wire           slvmustacceptreqn_async,
    input  wire           slvcandenyreqn_async,
    output wire           slvacceptn_async,
    output wire           slvdeny_async,

    input  wire           si_to_mi_wakeup_async,
    output wire           mi_to_si_wakeup_async,

    input  wire [3:0]     aw_wr_ptr_async,
    output wire [3:0]     aw_rd_ptr_async,
    input  wire [315:0]   aw_payld_async,
                       
    input  wire [5:0]     w_wr_ptr_async,
    output wire [5:0]     w_rd_ptr_async,
    input  wire [221:0]   w_payld_async,
                       
    output wire [1:0]     b_wr_ptr_async,
    input  wire [1:0]     b_rd_ptr_async,
    output wire [39:0]    b_payld_async,
                       
    input  wire [3:0]     ar_wr_ptr_async,
    output wire [3:0]     ar_rd_ptr_async,
    input  wire [315:0]   ar_payld_async,
                       
    output wire [3:0]     r_wr_ptr_async,
    input  wire [3:0]     r_rd_ptr_async,
    output wire [211:0]   r_payld_async,  
    
    output wire           mhu_psel,      
    output wire           mhu_pwakeup,
    output wire           mhu_penable,     
    output wire [18:0]    mhu_paddr,       
    output wire           mhu_pwrite,    
    output wire [31:0]    mhu_pwdata,      
    output wire [3:0]     mhu_pstrb,       
    output wire [2:0]     mhu_pprot,      
    input  wire [31:0]    mhu_prdata,    
    input  wire           mhu_pready,     
    input  wire           mhu_pslverr,        
    
    output wire           extdbg_psel,      
    output wire           extdbg_pwakeup,
    output wire           extdbg_penable,     
    output wire [31:0]    extdbg_paddr,       
    output wire           extdbg_pwrite,    
    output wire [31:0]    extdbg_pwdata,      
    output wire [3:0]     extdbg_pstrb,       
    output wire [2:0]     extdbg_pprot,      
    input  wire [31:0]    extdbg_prdata,    
    input  wire           extdbg_pready,     
    input  wire           extdbg_pslverr,   
    
    output wire           sysreg_apb_async_req,
    output wire [47:0]    sysreg_apb_async_req_payload,
    input  wire [32:0]    sysreg_apb_async_resp_payload,
    input  wire           sysreg_apb_async_ack,
    
    output wire           uart_apb_async_req,
    output wire [47:0]    uart_apb_async_req_payload,
    input  wire [32:0]    uart_apb_async_resp_payload,
    input  wire           uart_apb_async_ack,    
   
    output wire           hxb_err_irq,
    
    input  wire           hxb_clk_qreqn,        
    output wire           hxb_clk_qacceptn,    
    output wire           hxb_clk_qdeny,      
    output wire           hxb_clk_qactive,    
   
    input  wire           dftcgen,
    input  wire           dftrstdisable
  );

  
  wire [15:0]       ahbmux_hsel;

  wire              xhb_wakeup;
  wire              xhb_awvalid;
  wire              xhb_awready;
  wire              xhb_awuser;
  wire [17:0]       xhb_awid;
  wire [31:0]       xhb_awaddr;
  wire [3:0]        xhb_awregion;
  wire [7:0]        xhb_awlen;
  wire [2:0]        xhb_awsize;
  wire [1:0]        xhb_awburst;
  wire              xhb_awlock;
  wire [3:0]        xhb_awcache;
  wire [2:0]        xhb_awprot;
  wire [3:0]        xhb_awqos;
                    
  wire              xhb_wvalid;
  wire              xhb_wready;
  wire              xhb_wuser;
  wire [31:0]       xhb_wdata;
  wire [3:0]        xhb_wstrb;
  wire              xhb_wlast;
                    
  wire              xhb_bvalid;
  wire              xhb_bready;
  wire [17:0]       xhb_bid;
  wire [1:0]        xhb_bresp;
                    
  wire              xhb_arvalid;
  wire              xhb_arready;
  wire              xhb_aruser;
  wire [17:0]       xhb_arid;
  wire [31:0]       xhb_araddr;
  wire [3:0]        xhb_arregion;
  wire [7:0]        xhb_arlen;
  wire [2:0]        xhb_arsize;
  wire [1:0]        xhb_arburst;
  wire              xhb_arlock;
  wire [3:0]        xhb_arcache;
  wire [2:0]        xhb_arprot;
  wire [3:0]        xhb_arqos;
                    
  wire              xhb_rvalid;
  wire              xhb_rready;
  wire [17:0]       xhb_rid;
  wire [31:0]       xhb_rdata;
  wire [1:0]        xhb_rresp;
  wire              xhb_rlast;  
                    
  wire [6:0]        xhb_hprot;
  
  wire              mem_hsel;           
  wire [31:0]       mem_haddr;         
  wire  [1:0]       mem_htrans;         
  wire              mem_hwrite;         
  wire  [2:0]       mem_hsize;          
  wire  [2:0]       mem_hburst;         
  wire  [6:0]       mem_hprot;          
  wire              mem_hexcl;
  wire  [3:0]       mem_hmaster;
  wire [31:0]       mem_hwdata;         
  wire              mem_hmastlock;      
  wire [31:0]       mem_hrdata;         
  wire              mem_hreadyout;     
  wire              mem_hresp;          
  wire              mem_hexokay;
  wire              mem_hready;
  
  reg               mem_awakeup_r;
  wire              mem_awakeup_nxt;
  wire              mem_awvalid_i;
  wire              mem_arvalid_i;
  
  wire              mhu_hsel;           
  wire [31:0]       mhu_haddr;         
  wire  [1:0]       mhu_htrans;         
  wire              mhu_hwrite;         
  wire  [2:0]       mhu_hsize;          
  wire  [6:0]       mhu_hprot;          
  wire [31:0]       mhu_hwdata;         
  wire              mhu_hready;     
  wire [31:0]       mhu_hrdata;         
  wire              mhu_hreadyout;     
  wire              mhu_hresp;  
  
  reg               mhu_pwakeup_r;  
  wire              mhu_apbactive;
  
  wire              extdbg_hsel;           
  wire [31:0]       extdbg_haddr;         
  wire  [1:0]       extdbg_htrans;         
  wire              extdbg_hwrite;         
  wire  [2:0]       extdbg_hsize;          
  wire  [6:0]       extdbg_hprot;          
  wire [31:0]       extdbg_hwdata;         
  wire              extdbg_hready;     
  wire [31:0]       extdbg_hrdata;         
  wire              extdbg_hreadyout;     
  wire              extdbg_hresp; 
  
  reg               extdbg_pwakeup_r;
  wire              extdbg_apbactive;
  
  wire              hxb_awvalid;
  wire              hxb_awready;
  wire              hxb_awid;
  wire [31:0]       hxb_awaddr;
  wire [7:0]        hxb_awlen;
  wire [2:0]        hxb_awsize;
  wire [1:0]        hxb_awburst;
  wire              hxb_awlock;
  wire [3:0]        hxb_awcache;
  wire [2:0]        hxb_awprot;
                    
  wire              hxb_wvalid;
  wire              hxb_wready;
  wire [31:0]       hxb_wdata;
  wire [3:0]        hxb_wstrb;
  wire              hxb_wlast;
                    
  wire              hxb_bvalid;
  wire              hxb_bready;
  wire              hxb_bid;
  wire [1:0]        hxb_bresp;
                    
  wire              hxb_arvalid;
  wire              hxb_arready;
  wire              hxb_arid;
  wire [31:0]       hxb_araddr;
  wire [7:0]        hxb_arlen;
  wire [2:0]        hxb_arsize;
  wire [1:0]        hxb_arburst;
  wire              hxb_arlock;
  wire [3:0]        hxb_arcache;
  wire [2:0]        hxb_arprot;
                    
  wire              hxb_rvalid;
  wire              hxb_rready;
  wire              hxb_rid;
  wire [31:0]       hxb_rdata;
  wire [1:0]        hxb_rresp;
  wire              hxb_rlast; 
  
  wire              targexp1_hexcl;
  wire              targexp1_hexokay;
  wire              targexp1_hprot_4;
  wire              targexp1_hprot_5;
  wire              targexp1_hprot_6;
  
  wire              unused; 
  wire [13:0]        unused_initexp0_hmaster;  


  xhb500_axi_to_ahb_bridge_external_system u_xhb500_axi_to_ahb_bridge_external_system (
    
    .clk               (extsys_hclk),
    .resetn            (extsys_mtx_resetn),
  
    .clk_qreqn         (1'b1),
    .clk_qacceptn      (),
    .clk_qdeny         (),
    .clk_qactive       (),
  
    .pwr_qreqn         (1'b1),
    .pwr_qacceptn      (),
    .pwr_qdeny         (),
    .pwr_qactive       (),
  
    .awvalid           (xhb_awvalid),
    .awready           (xhb_awready),
    .awaddr            (xhb_awaddr),
    .awburst           (xhb_awburst),
    .awid              (xhb_awid),
    .awlen             (xhb_awlen),
    .awsize            (xhb_awsize),
    .awlock            (xhb_awlock),
    .awprot            (xhb_awprot),
    .awcache           (xhb_awcache),
  
    .arvalid           (xhb_arvalid),
    .arready           (xhb_arready),
    .araddr            (xhb_araddr),
    .arburst           (xhb_arburst),
    .arid              (xhb_arid),
    .arlen             (xhb_arlen),
    .arsize            (xhb_arsize),
    .arlock            (xhb_arlock),
    .arprot            (xhb_arprot),
    .arcache           (xhb_arcache),
  
    .wvalid            (xhb_wvalid),
    .wready            (xhb_wready),
    .wlast             (xhb_wlast),
    .wstrb             (xhb_wstrb),
    .wdata             (xhb_wdata),
  
    .rvalid            (xhb_rvalid),
    .rready            (xhb_rready),
    .rid               (xhb_rid),
    .rlast             (xhb_rlast),
    .rdata             (xhb_rdata),
    .rresp             (xhb_rresp),
  
    .bvalid            (xhb_bvalid),
    .bready            (xhb_bready),
    .bid               (xhb_bid),
    .bresp             (xhb_bresp),                                      
  
    .ardomain          (2'b00),
    .awdomain          (2'b00),
  
    .awakeup           (xhb_wakeup),
    .awnsaid           (4'h0),
    .arnsaid           (4'h0),
    .awqos             (xhb_awqos),
    .arqos             (xhb_arqos),
    .awregion          (xhb_awregion),
    .arregion          (xhb_arregion),
    
    .awsparse          (1'b1), 
    
    .hnsaid            (),
    .hregion           (),
    .hqos              (),
    
    .hnonsec           (),                  
    .haddr             (initexp0_haddr),
    .htrans            (initexp0_htrans),
    .hsize             (initexp0_hsize),
    .hwrite            (initexp0_hwrite),
    .hprot             (xhb_hprot),
    .hburst            (initexp0_hburst),
    .hmastlock         (initexp0_hmastlock),
    .hwdata            (initexp0_hwdata),
    .hexcl             (),                 
    .hmaster           ({unused_initexp0_hmaster, initexp0_hmaster}),
    .hrdata            (initexp0_hrdata),
    .hready            (initexp0_hready),
    .hresp             (initexp0_hresp),
    .hexokay           (1'b0)              
    );
  
  assign initexp0_hsel       = 1'b1;
  assign initexp0_hprot      = xhb_hprot[3:0];
  assign initexp0_memattr[0] = xhb_hprot[5]; 
  assign initexp0_memattr[1] = xhb_hprot[6]; 
  assign initexp0_hauser     = 1'b0;
  assign initexp0_hwuser     = 4'h0;
  
  assign initexp0_exreq      = 1'b0; 
  

 sse710_adb400_r3_axi4_mst_wrapper #(
    .ADDR_WIDTH             (32),
    .DATA_WIDTH             (32),
    .AWID_WIDTH             (18),
    .ARID_WIDTH             (18),
    .AWUSER_WIDTH           (0), 
    .WUSER_WIDTH            (0), 
    .BUSER_WIDTH            (0), 
    .ARUSER_WIDTH           (0), 
    .RUSER_WIDTH            (0), 
    .AW_FIFO_DEPTH          (4), 
    .W_FIFO_DEPTH           (6), 
    .B_FIFO_DEPTH           (2), 
    .AR_FIFO_DEPTH          (4), 
    .R_FIFO_DEPTH           (4), 
    .AW_OPREG               (1), 
    .W_OPREG                (1), 
    .AR_OPREG               (1), 
    .MI_SYNC_LEVELS         (2),
    .AW_PAYLOAD_WIDTH       (316),
    .W_PAYLOAD_WIDTH        (222),
    .B_PAYLOAD_WIDTH        (40),
    .AR_PAYLOAD_WIDTH       (316),
    .R_PAYLOAD_WIDTH        (212)    
  ) u_sse710_adb400_r3_axi4_mst_wrapper (
    .aclkm                          (extsys_hclk),
    .aresetnm                       (extsys_mtx_resetn),
    
    .clkqreqnm_i                    (expclk_qreqn),
    .clkqacceptnm_o                 (expclk_qacceptn),
    .clkqdenym_o                    (expclk_qdeny),
    .clkqactivem_o                  (expclk_qactive),
    
    .wakeupm_o                      (xhb_wakeup),
    .awvalidm                       (xhb_awvalid),
    .awreadym                       (xhb_awready),
    .awuserm                        (xhb_awuser),
    .awidm                          (xhb_awid),
    .awaddrm                        (xhb_awaddr), 
    .awregionm                      (xhb_awregion),
    .awlenm                         (xhb_awlen),
    .awsizem                        (xhb_awsize),
    .awburstm                       (xhb_awburst),
    .awlockm                        (xhb_awlock),
    .awcachem                       (xhb_awcache),
    .awprotm                        (xhb_awprot),
    .awqosm                         (xhb_awqos),
                                     
    .wvalidm                        (xhb_wvalid),
    .wreadym                        (xhb_wready),
    .wuserm                         (xhb_wuser),
    .wdatam                         (xhb_wdata),
    .wstrbm                         (xhb_wstrb),
    .wlastm                         (xhb_wlast),
                                     
    .bvalidm                        (xhb_bvalid),
    .breadym                        (xhb_bready),
    .buserm                         (1'b0),
    .bidm                           (xhb_bid),
    .brespm                         (xhb_bresp),
                                     
    .arvalidm                       (xhb_arvalid),
    .arreadym                       (xhb_arready),
    .aruserm                        (xhb_aruser),
    .aridm                          (xhb_arid),
    .araddrm                        (xhb_araddr),
    .arregionm                      (xhb_arregion),
    .arlenm                         (xhb_arlen),
    .arsizem                        (xhb_arsize),
    .arburstm                       (xhb_arburst),
    .arlockm                        (xhb_arlock),
    .arcachem                       (xhb_arcache),
    .arprotm                        (xhb_arprot),
    .arqosm                         (xhb_arqos),
                                     
    .rvalidm                        (xhb_rvalid),
    .rreadym                        (xhb_rready),
    .ruserm                         (1'b0),
    .ridm                           (xhb_rid),
    .rdatam                         (xhb_rdata),
    .rrespm                         (xhb_rresp),
    .rlastm                         (xhb_rlast),
    
    .slvmustacceptreqn_async        (slvmustacceptreqn_async),
    .slvcandenyreqn_async           (slvcandenyreqn_async),
    .slvacceptn_async               (slvacceptn_async),
    .slvdeny_async                  (slvdeny_async),
    
    .si_to_mi_wakeup_async          (si_to_mi_wakeup_async),
    .mi_to_si_wakeup_async          (mi_to_si_wakeup_async),
    
    .aw_wr_ptr_async                (aw_wr_ptr_async),
    .aw_rd_ptr_async                (aw_rd_ptr_async),
    .aw_payld_async                 (aw_payld_async),
    
    .w_wr_ptr_async                 (w_wr_ptr_async),
    .w_rd_ptr_async                 (w_rd_ptr_async),
    .w_payld_async                  (w_payld_async),
    
    .b_wr_ptr_async                 (b_wr_ptr_async),
    .b_rd_ptr_async                 (b_rd_ptr_async),
    .b_payld_async                  (b_payld_async),
    
    .ar_wr_ptr_async                (ar_wr_ptr_async),
    .ar_rd_ptr_async                (ar_rd_ptr_async),
    .ar_payld_async                 (ar_payld_async),
    
    .r_wr_ptr_async                 (r_wr_ptr_async),
    .r_rd_ptr_async                 (r_rd_ptr_async),
    .r_payld_async                  (r_payld_async),
    
    .dftrstdisablem                 (dftrstdisable)
  );

  
  assign ahbmux_hsel[0]    = (ahbmux_hsel[1] | ahbmux_hsel[2]) ? 1'b0 : targexp1_hsel;
  
  assign ahbmux_hsel[1]    = (targexp1_haddr[31:19] == {12'h401, 1'b0})  ? targexp1_hsel : 1'b0;
  
  assign ahbmux_hsel[2]    = (targexp1_haddr[31:23] == {8'h44, 1'b0}) ? targexp1_hsel : 1'b0;
  assign ahbmux_hsel[15:3] = 13'h0000;
  
  
  sie200_m3_m4_ahb5_adapter_ex_conv u_sie200_m3_m4_ahb5_adapter_ex_conv (
    .hclk    (extsys_hclk),
    .hresetn (extsys_mtx_resetn),
    .exreq   (targexp1_exreq),
    .exresp  (targexp1_exresp),
    .hready  (targexp1_hreadyout),
    .hresp   (targexp1_hresp),
    .hexcl   (targexp1_hexcl),
    .hexokay (targexp1_hexokay)
  );
    

  sie200_ahb5_slave_mux #(
    .PORT0_ENABLE    (1),
    .PORT1_ENABLE    (1),
    .PORT2_ENABLE    (1),
    .PORT3_ENABLE    (0),
    .PORT4_ENABLE    (0),
    .PORT5_ENABLE    (0),
    .PORT6_ENABLE    (0),
    .PORT7_ENABLE    (0),
    .PORT8_ENABLE    (0),
    .PORT9_ENABLE    (0),
    .PORT10_ENABLE   (0),
    .PORT11_ENABLE   (0),
    .PORT12_ENABLE   (0),
    .PORT13_ENABLE   (0),
    .PORT14_ENABLE   (0),
    .PORT15_ENABLE   (0),
    .ADDR_WIDTH      (32),
    .DATA_WIDTH      (32),
    .MASTER_WIDTH    (4),
    .USER_WIDTH      (1)
  ) u_sie200_ahb5_slave_mux (
    .hclk                (extsys_hclk),      
    .hresetn             (extsys_mtx_resetn),
    
    .haddr_s             (targexp1_haddr),
    .hburst_s            (targexp1_hburst),
    .hmastlock_s         (targexp1_hmastlock),
    .hprot_s             ({targexp1_hprot_6, targexp1_hprot_5, targexp1_hprot_4, targexp1_hprot}),
    .hsize_s             (targexp1_hsize),
    .hnonsec_s           (1'b1),
    .hexcl_s             (targexp1_hexcl),
    .hmaster_s           (targexp1_hmaster),
    .htrans_s            (targexp1_htrans),
    .hwdata_s            (targexp1_hwdata),
    .hwrite_s            (targexp1_hwrite),
    .hrdata_s            (targexp1_hrdata),
    .hreadyout_s         (targexp1_hreadyout),
    .hresp_s             (targexp1_hresp),
    .hexokay_s           (targexp1_hexokay),
    .hsel_s              (ahbmux_hsel),
    .hready_s            (targexp1_hreadymux),
    .hauser_s            (1'b0),
    .hwuser_s            (1'b0),
    .hruser_s            (),
    
    .haddr_m0            (mem_haddr),    
    .hburst_m0           (mem_hburst),   
    .hmastlock_m0        (mem_hmastlock),
    .hprot_m0            (mem_hprot),    
    .hsize_m0            (mem_hsize),    
    .hnonsec_m0          (),              
    .hexcl_m0            (mem_hexcl),    
    .hmaster_m0          (mem_hmaster),  
    .htrans_m0           (mem_htrans),   
    .hwdata_m0           (mem_hwdata),   
    .hwrite_m0           (mem_hwrite),   
    .hrdata_m0           (mem_hrdata),   
    .hreadyout_m0        (mem_hreadyout),
    .hresp_m0            (mem_hresp),    
    .hexokay_m0          (mem_hexokay),       
    .hsel_m0             (mem_hsel),     
    .hready_m0           (mem_hready),   
    .hauser_m0           (),              
    .hwuser_m0           (),              
    .hruser_m0           (1'b0),                  
    
    .haddr_m1            (mhu_haddr),    
    .hburst_m1           (),   
    .hmastlock_m1        (),
    .hprot_m1            (mhu_hprot),    
    .hsize_m1            (mhu_hsize),    
    .hnonsec_m1          (),             
    .hexcl_m1            (),    
    .hmaster_m1          (),  
    .htrans_m1           (mhu_htrans),   
    .hwdata_m1           (mhu_hwdata),   
    .hwrite_m1           (mhu_hwrite),   
    .hrdata_m1           (mhu_hrdata),   
    .hreadyout_m1        (mhu_hreadyout),
    .hresp_m1            (mhu_hresp),    
    .hexokay_m1          (1'b0), 
    .hsel_m1             (mhu_hsel),     
    .hready_m1           (mhu_hready),   
    .hauser_m1           (),             
    .hwuser_m1           (),             
    .hruser_m1           (1'b0),         
    
    .haddr_m2            (extdbg_haddr),    
    .hburst_m2           (),   
    .hmastlock_m2        (),
    .hprot_m2            (extdbg_hprot),    
    .hsize_m2            (extdbg_hsize),    
    .hnonsec_m2          (),             
    .hexcl_m2            (),    
    .hmaster_m2          (),  
    .htrans_m2           (extdbg_htrans),   
    .hwdata_m2           (extdbg_hwdata),   
    .hwrite_m2           (extdbg_hwrite),   
    .hrdata_m2           (extdbg_hrdata),   
    .hreadyout_m2        (extdbg_hreadyout),
    .hresp_m2            (extdbg_hresp),    
    .hexokay_m2          (1'b0), 
    .hsel_m2             (extdbg_hsel),     
    .hready_m2           (extdbg_hready),   
    .hauser_m2           (),             
    .hwuser_m2           (),             
    .hruser_m2           (1'b0),         
    
    .haddr_m3            (),
    .hburst_m3           (),
    .hmastlock_m3        (),
    .hprot_m3            (),
    .hsize_m3            (),
    .hnonsec_m3          (),
    .hexcl_m3            (),
    .hmaster_m3          (),
    .htrans_m3           (),
    .hwdata_m3           (),
    .hwrite_m3           (),
    .hrdata_m3           (32'h0000_0000),
    .hreadyout_m3        (1'b0),
    .hresp_m3            (1'b0),
    .hexokay_m3          (1'b0),
    .hsel_m3             (),
    .hready_m3           (),
    .hauser_m3           (),
    .hwuser_m3           (),
    .hruser_m3           (1'b0),
    
    .haddr_m4            (),             
    .hburst_m4           (),             
    .hmastlock_m4        (),             
    .hprot_m4            (),             
    .hsize_m4            (),             
    .hnonsec_m4          (),             
    .hexcl_m4            (),             
    .hmaster_m4          (),             
    .htrans_m4           (),             
    .hwdata_m4           (),             
    .hwrite_m4           (),             
    .hrdata_m4           (32'h0000_0000),
    .hreadyout_m4        (1'b0),         
    .hresp_m4            (1'b0),         
    .hexokay_m4          (1'b0),         
    .hsel_m4             (),             
    .hready_m4           (),             
    .hauser_m4           (),             
    .hwuser_m4           (),             
    .hruser_m4           (1'b0),         
    
    .haddr_m5            (),             
    .hburst_m5           (),             
    .hmastlock_m5        (),             
    .hprot_m5            (),             
    .hsize_m5            (),             
    .hnonsec_m5          (),             
    .hexcl_m5            (),             
    .hmaster_m5          (),             
    .htrans_m5           (),             
    .hwdata_m5           (),             
    .hwrite_m5           (),             
    .hrdata_m5           (32'h0000_0000),
    .hreadyout_m5        (1'b0),         
    .hresp_m5            (1'b0),         
    .hexokay_m5          (1'b0),         
    .hsel_m5             (),             
    .hready_m5           (),             
    .hauser_m5           (),             
    .hwuser_m5           (),             
    .hruser_m5           (1'b0),         
    
    .haddr_m6            (),             
    .hburst_m6           (),             
    .hmastlock_m6        (),             
    .hprot_m6            (),             
    .hsize_m6            (),             
    .hnonsec_m6          (),             
    .hexcl_m6            (),             
    .hmaster_m6          (),             
    .htrans_m6           (),             
    .hwdata_m6           (),             
    .hwrite_m6           (),             
    .hrdata_m6           (32'h0000_0000),
    .hreadyout_m6        (1'b0),         
    .hresp_m6            (1'b0),         
    .hexokay_m6          (1'b0),         
    .hsel_m6             (),             
    .hready_m6           (),             
    .hauser_m6           (),             
    .hwuser_m6           (),             
    .hruser_m6           (1'b0),         
    
    .haddr_m7            (),             
    .hburst_m7           (),             
    .hmastlock_m7        (),             
    .hprot_m7            (),             
    .hsize_m7            (),             
    .hnonsec_m7          (),             
    .hexcl_m7            (),             
    .hmaster_m7          (),             
    .htrans_m7           (),             
    .hwdata_m7           (),             
    .hwrite_m7           (),             
    .hrdata_m7           (32'h0000_0000),
    .hreadyout_m7        (1'b0),         
    .hresp_m7            (1'b0),         
    .hexokay_m7          (1'b0),         
    .hsel_m7             (),             
    .hready_m7           (),             
    .hauser_m7           (),             
    .hwuser_m7           (),             
    .hruser_m7           (1'b0),         
    
    .haddr_m8            (),             
    .hburst_m8           (),             
    .hmastlock_m8        (),             
    .hprot_m8            (),             
    .hsize_m8            (),             
    .hnonsec_m8          (),             
    .hexcl_m8            (),             
    .hmaster_m8          (),             
    .htrans_m8           (),             
    .hwdata_m8           (),             
    .hwrite_m8           (),             
    .hrdata_m8           (32'h0000_0000),
    .hreadyout_m8        (1'b0),         
    .hresp_m8            (1'b0),         
    .hexokay_m8          (1'b0),         
    .hsel_m8             (),             
    .hready_m8           (),             
    .hauser_m8           (),             
    .hwuser_m8           (),             
    .hruser_m8           (1'b0),         
    
    .haddr_m9            (),             
    .hburst_m9           (),             
    .hmastlock_m9        (),             
    .hprot_m9            (),             
    .hsize_m9            (),             
    .hnonsec_m9          (),             
    .hexcl_m9            (),             
    .hmaster_m9          (),             
    .htrans_m9           (),             
    .hwdata_m9           (),             
    .hwrite_m9           (),             
    .hrdata_m9           (32'h0000_0000),
    .hreadyout_m9        (1'b0),         
    .hresp_m9            (1'b0),         
    .hexokay_m9          (1'b0),         
    .hsel_m9             (),             
    .hready_m9           (),             
    .hauser_m9           (),             
    .hwuser_m9           (),             
    .hruser_m9           (1'b0),         
    
    .haddr_m10           (),             
    .hburst_m10          (),             
    .hmastlock_m10       (),             
    .hprot_m10           (),             
    .hsize_m10           (),             
    .hnonsec_m10         (),             
    .hexcl_m10           (),             
    .hmaster_m10         (),             
    .htrans_m10          (),             
    .hwdata_m10          (),             
    .hwrite_m10          (),             
    .hrdata_m10          (32'h0000_0000),
    .hreadyout_m10       (1'b0),         
    .hresp_m10           (1'b0),         
    .hexokay_m10         (1'b0),         
    .hsel_m10            (),             
    .hready_m10          (),             
    .hauser_m10          (),             
    .hwuser_m10          (),             
    .hruser_m10          (1'b0),         
    
    .haddr_m11           (),             
    .hburst_m11          (),             
    .hmastlock_m11       (),             
    .hprot_m11           (),             
    .hsize_m11           (),             
    .hnonsec_m11         (),             
    .hexcl_m11           (),             
    .hmaster_m11         (),             
    .htrans_m11          (),             
    .hwdata_m11          (),             
    .hwrite_m11          (),             
    .hrdata_m11          (32'h0000_0000),
    .hreadyout_m11       (1'b0),         
    .hresp_m11           (1'b0),         
    .hexokay_m11         (1'b0),         
    .hsel_m11            (),             
    .hready_m11          (),             
    .hauser_m11          (),             
    .hwuser_m11          (),             
    .hruser_m11          (1'b0),         
    
    .haddr_m12           (),             
    .hburst_m12          (),             
    .hmastlock_m12       (),             
    .hprot_m12           (),             
    .hsize_m12           (),             
    .hnonsec_m12         (),             
    .hexcl_m12           (),             
    .hmaster_m12         (),             
    .htrans_m12          (),             
    .hwdata_m12          (),             
    .hwrite_m12          (),             
    .hrdata_m12          (32'h0000_0000),
    .hreadyout_m12       (1'b0),         
    .hresp_m12           (1'b0),         
    .hexokay_m12         (1'b0),         
    .hsel_m12            (),             
    .hready_m12          (),             
    .hauser_m12          (),             
    .hwuser_m12          (),             
    .hruser_m12          (1'b0),         
    
    .haddr_m13           (),             
    .hburst_m13          (),             
    .hmastlock_m13       (),             
    .hprot_m13           (),             
    .hsize_m13           (),             
    .hnonsec_m13         (),             
    .hexcl_m13           (),             
    .hmaster_m13         (),             
    .htrans_m13          (),             
    .hwdata_m13          (),             
    .hwrite_m13          (),             
    .hrdata_m13          (32'h0000_0000),
    .hreadyout_m13       (1'b0),         
    .hresp_m13           (1'b0),         
    .hexokay_m13         (1'b0),         
    .hsel_m13            (),             
    .hready_m13          (),             
    .hauser_m13          (),             
    .hwuser_m13          (),             
    .hruser_m13          (1'b0),         
    
    .haddr_m14           (),             
    .hburst_m14          (),             
    .hmastlock_m14       (),             
    .hprot_m14           (),             
    .hsize_m14           (),             
    .hnonsec_m14         (),             
    .hexcl_m14           (),             
    .hmaster_m14         (),             
    .htrans_m14          (),             
    .hwdata_m14          (),             
    .hwrite_m14          (),             
    .hrdata_m14          (32'h0000_0000),
    .hreadyout_m14       (1'b0),         
    .hresp_m14           (1'b0),         
    .hexokay_m14         (1'b0),         
    .hsel_m14            (),             
    .hready_m14          (),             
    .hauser_m14          (),             
    .hwuser_m14          (),             
    .hruser_m14          (1'b0),         
    
    .haddr_m15           (),             
    .hburst_m15          (),             
    .hmastlock_m15       (),             
    .hprot_m15           (),             
    .hsize_m15           (),             
    .hnonsec_m15         (),             
    .hexcl_m15           (),             
    .hmaster_m15         (),             
    .htrans_m15          (),             
    .hwdata_m15          (),             
    .hwrite_m15          (),             
    .hrdata_m15          (32'h0000_0000),
    .hreadyout_m15       (1'b0),         
    .hresp_m15           (1'b0),         
    .hexokay_m15         (1'b0),         
    .hsel_m15            (),             
    .hready_m15          (),             
    .hauser_m15          (),             
    .hwuser_m15          (),             
    .hruser_m15          (1'b0)         
    );
  
  assign targexp1_hruser = 3'h0;
  
  assign targexp1_hprot_4 = targexp1_hprot[3];
  assign targexp1_hprot_5 = targexp1_memattr[0];
  assign targexp1_hprot_6 = ({targexp1_hprot_4, targexp1_hprot[3]} == 2'b00) ? 1'b0 : targexp1_memattr[1];
  

  xhb500_ahb_to_axi_bridge_external_system u_xhb500_ahb_to_axi_bridge_external_system (
    .clk                  (extsys_hclk),     
    .resetn               (extsys_mtx_resetn),
    
    .buf_write_error_irq  (hxb_err_irq),
    .irq_en               (1'b1),
    
    .hsel                 (mem_hsel),
    .hnonsec              (1'b1),       
    .haddr                (mem_haddr),
    .htrans               (mem_htrans),
    .hsize                (mem_hsize),
    .hwrite               (mem_hwrite),
    .hready               (mem_hready),
    .hprot                (mem_hprot),
    .hburst               (mem_hburst),
    .hmastlock            (mem_hmastlock),
    .hwdata               (mem_hwdata),
    .hexcl                (mem_hexcl),
    .hmaster              (mem_hmaster[0]), 
    .hrdata               (mem_hrdata),
    .hreadyout            (mem_hreadyout),
    .hresp                (mem_hresp),
    .hexokay              (mem_hexokay),
    
    .hqos                 (4'h0),
    .hregion              (4'h0),
    .hnsaid               (4'h0),
    
    .awvalid              (hxb_awvalid),
    .awaddr               (hxb_awaddr),
    .awdomain             (),          
    .awburst              (hxb_awburst),
    .awid                 (hxb_awid),
    .awlen                (hxb_awlen),
    .awsize               (hxb_awsize),
    .awlock               (hxb_awlock),
    .awprot               (hxb_awprot),
    .awready              (hxb_awready),
    .awcache              (hxb_awcache),
    .awregion             (),
    .awnsaid              (),
    .awqos                (),
    .arvalid              (hxb_arvalid),
    .araddr               (hxb_araddr),
    .ardomain             (),         
    .arburst              (hxb_arburst),
    .arid                 (hxb_arid),
    .arlen                (hxb_arlen),
    .arsize               (hxb_arsize),
    .arlock               (hxb_arlock),
    .arprot               (hxb_arprot),
    .arready              (hxb_arready),
    .arcache              (hxb_arcache),
    .arregion             (),
    .arnsaid              (),
    .arqos                (),
    .wvalid               (hxb_wvalid),
    .wlast                (hxb_wlast),
    .wstrb                (hxb_wstrb),
    .wdata                (hxb_wdata),
    .wready               (hxb_wready),
    .rvalid               (hxb_rvalid),
    .rid                  (hxb_rid),
    .rlast                (hxb_rlast),
    .rdata                (hxb_rdata),
    .rresp                (hxb_rresp),
    .rready               (hxb_rready),
    .bvalid               (hxb_bvalid),
    .bid                  (hxb_bid),
    .bresp                (hxb_bresp),
    .bready               (hxb_bready),
    
    .awakeup              (),
    
    .clk_qreqn            (hxb_clk_qreqn),   
    .clk_qacceptn         (hxb_clk_qacceptn),
    .clk_qdeny            (hxb_clk_qdeny),   
    .clk_qactive          (hxb_clk_qactive), 
    
    .pwr_qreqn            (1'b1),
    .pwr_qacceptn         (),
    .pwr_qdeny            (),
    .pwr_qactive          ()
  );
  

  generate 
    if(MEM_DATA_WIDTH == 64) 
    begin : gen_upsizer_64
      nic400_sse710_integration_example_f0_upsizer u_nic400_sse710_integration_example_f0_upsizer (
        .awid_axi_m            (mem_awid), 
        .awaddr_axi_m          (mem_awaddr), 
        .awlen_axi_m           (mem_awlen),  
        .awsize_axi_m          (mem_awsize), 
        .awburst_axi_m         (mem_awburst),
        .awlock_axi_m          (mem_awlock), 
        .awcache_axi_m         (mem_awcache),
        .awprot_axi_m          (mem_awprot), 
        .awvalid_axi_m         (mem_awvalid_i),
        .awready_axi_m         (mem_awready),
        .wdata_axi_m           (mem_wdata),  
        .wstrb_axi_m           (mem_wstrb),  
        .wlast_axi_m           (mem_wlast),  
        .wvalid_axi_m          (mem_wvalid), 
        .wready_axi_m          (mem_wready), 
        .bid_axi_m             (mem_bid),
        .bresp_axi_m           (mem_bresp),  
        .bvalid_axi_m          (mem_bvalid), 
        .bready_axi_m          (mem_bready),
        .arid_axi_m            (mem_arid),
        .araddr_axi_m          (mem_araddr), 
        .arlen_axi_m           (mem_arlen),  
        .arsize_axi_m          (mem_arsize), 
        .arburst_axi_m         (mem_arburst),
        .arlock_axi_m          (mem_arlock), 
        .arcache_axi_m         (mem_arcache),
        .arprot_axi_m          (mem_arprot), 
        .arvalid_axi_m         (mem_arvalid_i),
        .arready_axi_m         (mem_arready),
        .rid_axi_m             (mem_rid),
        .rdata_axi_m           (mem_rdata),  
        .rresp_axi_m           (mem_rresp),  
        .rlast_axi_m           (mem_rlast),  
        .rvalid_axi_m          (mem_rvalid), 
        .rready_axi_m          (mem_rready), 
      
        .awid_axi_m_s          (hxb_awid),
        .awaddr_axi_m_s        (hxb_awaddr),
        .awlen_axi_m_s         (hxb_awlen),
        .awsize_axi_m_s        (hxb_awsize),
        .awburst_axi_m_s       (hxb_awburst),
        .awlock_axi_m_s        (hxb_awlock),
        .awcache_axi_m_s       (hxb_awcache),
        .awprot_axi_m_s        (hxb_awprot),
        .awvalid_axi_m_s       (hxb_awvalid),
        .awready_axi_m_s       (hxb_awready),
        .wdata_axi_m_s         (hxb_wdata),
        .wstrb_axi_m_s         (hxb_wstrb),
        .wlast_axi_m_s         (hxb_wlast),
        .wvalid_axi_m_s        (hxb_wvalid),
        .wready_axi_m_s        (hxb_wready),
        .bid_axi_m_s           (hxb_bid),
        .bresp_axi_m_s         (hxb_bresp),
        .bvalid_axi_m_s        (hxb_bvalid),
        .bready_axi_m_s        (hxb_bready),
        .arid_axi_m_s          (hxb_arid),
        .araddr_axi_m_s        (hxb_araddr),
        .arlen_axi_m_s         (hxb_arlen),
        .arsize_axi_m_s        (hxb_arsize),
        .arburst_axi_m_s       (hxb_arburst),
        .arlock_axi_m_s        (hxb_arlock),
        .arcache_axi_m_s       (hxb_arcache),
        .arprot_axi_m_s        (hxb_arprot),
        .arvalid_axi_m_s       (hxb_arvalid),
        .arready_axi_m_s       (hxb_arready),
        .rid_axi_m_s           (hxb_rid),
        .rdata_axi_m_s         (hxb_rdata),
        .rresp_axi_m_s         (hxb_rresp),
        .rlast_axi_m_s         (hxb_rlast),
        .rvalid_axi_m_s        (hxb_rvalid),
        .rready_axi_m_s        (hxb_rready),
      
        .clk0clk               (extsys_hclk),
        .clk0resetn            (extsys_mtx_resetn)
      );
    end else if (MEM_DATA_WIDTH == 128)
    begin : gen_upsizer_64
      nic400_sse710_integration_example_f0_upsizer_32_128 u_nic400_sse710_integration_example_f0_upsizer_32_128 (
        .awid_axi_m            (mem_awid), 
        .awaddr_axi_m          (mem_awaddr), 
        .awlen_axi_m           (mem_awlen),  
        .awsize_axi_m          (mem_awsize), 
        .awburst_axi_m         (mem_awburst),
        .awlock_axi_m          (mem_awlock), 
        .awcache_axi_m         (mem_awcache),
        .awprot_axi_m          (mem_awprot), 
        .awvalid_axi_m         (mem_awvalid_i),
        .awready_axi_m         (mem_awready),
        .wdata_axi_m           (mem_wdata),  
        .wstrb_axi_m           (mem_wstrb),  
        .wlast_axi_m           (mem_wlast),  
        .wvalid_axi_m          (mem_wvalid), 
        .wready_axi_m          (mem_wready), 
        .bid_axi_m             (mem_bid),
        .bresp_axi_m           (mem_bresp),  
        .bvalid_axi_m          (mem_bvalid), 
        .bready_axi_m          (mem_bready),
        .arid_axi_m            (mem_arid),
        .araddr_axi_m          (mem_araddr), 
        .arlen_axi_m           (mem_arlen),  
        .arsize_axi_m          (mem_arsize), 
        .arburst_axi_m         (mem_arburst),
        .arlock_axi_m          (mem_arlock), 
        .arcache_axi_m         (mem_arcache),
        .arprot_axi_m          (mem_arprot), 
        .arvalid_axi_m         (mem_arvalid_i),
        .arready_axi_m         (mem_arready),
        .rid_axi_m             (mem_rid),
        .rdata_axi_m           (mem_rdata),  
        .rresp_axi_m           (mem_rresp),  
        .rlast_axi_m           (mem_rlast),  
        .rvalid_axi_m          (mem_rvalid), 
        .rready_axi_m          (mem_rready), 
      
        .awid_axi_m_s          (hxb_awid),
        .awaddr_axi_m_s        (hxb_awaddr),
        .awlen_axi_m_s         (hxb_awlen),
        .awsize_axi_m_s        (hxb_awsize),
        .awburst_axi_m_s       (hxb_awburst),
        .awlock_axi_m_s        (hxb_awlock),
        .awcache_axi_m_s       (hxb_awcache),
        .awprot_axi_m_s        (hxb_awprot),
        .awvalid_axi_m_s       (hxb_awvalid),
        .awready_axi_m_s       (hxb_awready),
        .wdata_axi_m_s         (hxb_wdata),
        .wstrb_axi_m_s         (hxb_wstrb),
        .wlast_axi_m_s         (hxb_wlast),
        .wvalid_axi_m_s        (hxb_wvalid),
        .wready_axi_m_s        (hxb_wready),
        .bid_axi_m_s           (hxb_bid),
        .bresp_axi_m_s         (hxb_bresp),
        .bvalid_axi_m_s        (hxb_bvalid),
        .bready_axi_m_s        (hxb_bready),
        .arid_axi_m_s          (hxb_arid),
        .araddr_axi_m_s        (hxb_araddr),
        .arlen_axi_m_s         (hxb_arlen),
        .arsize_axi_m_s        (hxb_arsize),
        .arburst_axi_m_s       (hxb_arburst),
        .arlock_axi_m_s        (hxb_arlock),
        .arcache_axi_m_s       (hxb_arcache),
        .arprot_axi_m_s        (hxb_arprot),
        .arvalid_axi_m_s       (hxb_arvalid),
        .arready_axi_m_s       (hxb_arready),
        .rid_axi_m_s           (hxb_rid),
        .rdata_axi_m_s         (hxb_rdata),
        .rresp_axi_m_s         (hxb_rresp),
        .rlast_axi_m_s         (hxb_rlast),
        .rvalid_axi_m_s        (hxb_rvalid),
        .rready_axi_m_s        (hxb_rready),
      
        .clk0clk               (extsys_hclk),
        .clk0resetn            (extsys_mtx_resetn)
      );  
    end else begin :  gen_upsizer_32

      assign mem_awid      = hxb_awid;   
      assign mem_awaddr    = hxb_awaddr; 
      assign mem_awlen     = hxb_awlen;  
      assign mem_awsize    = hxb_awsize; 
      assign mem_awburst   = hxb_awburst;
      assign mem_awlock    = hxb_awlock; 
      assign mem_awcache   = hxb_awcache;
      assign mem_awprot    = hxb_awprot;    
      assign mem_awvalid_i = hxb_awvalid;
      assign hxb_awready   = mem_awready;
      
      assign mem_wstrb    = hxb_wstrb; 
      assign mem_wlast    = hxb_wlast; 
      assign mem_wvalid   = hxb_wvalid;
      assign mem_wdata    = hxb_wdata; 
      assign hxb_wready   = mem_wready;
      
      assign hxb_bid      = mem_bid;   
      assign hxb_bresp    = mem_bresp; 
      assign hxb_bvalid   = mem_bvalid;
      assign mem_bready   = hxb_bready;
      
      assign mem_arid      = hxb_arid;   
      assign mem_araddr    = hxb_araddr; 
      assign mem_arlen     = hxb_arlen;  
      assign mem_arsize    = hxb_arsize; 
      assign mem_arburst   = hxb_arburst;
      assign mem_arlock    = hxb_arlock; 
      assign mem_arcache   = hxb_arcache;
      assign mem_arprot    = hxb_arprot;    
      assign mem_arvalid_i = hxb_arvalid;
      assign hxb_arready   = mem_arready;
      
      assign hxb_rid      = mem_rid;    
      assign hxb_rresp    = mem_rresp;  
      assign hxb_rlast    = mem_rlast;  
      assign hxb_rvalid   = mem_rvalid; 
      assign hxb_rdata    = mem_rdata; 
      assign mem_rready   = hxb_rready;   
    
    end
  endgenerate

  always @(posedge extsys_hclk or negedge extsys_mtx_resetn)
    if(~extsys_mtx_resetn)
      mem_awakeup_r <= 1'b0;
    else
      mem_awakeup_r <= mem_awakeup_nxt;
  
  assign mem_awakeup_nxt = mem_awvalid_i | mem_arvalid_i;
  assign mem_awakeup     = mem_awakeup_r;  
    
  assign mem_awvalid = mem_awvalid_i;
  assign mem_arvalid = mem_arvalid_i;
  
  
  cmsdk_ahb_to_apb #(
    .ADDRWIDTH      (19),
    .REGISTER_RDATA (1),
    .REGISTER_WDATA (0)
  ) u_cmsdk_ahb_to_apb_mhu (
    .HCLK          (extsys_hclk),
    .HRESETn       (extsys_mtx_resetn),
    .PCLKEN        (1'b1),    

    .HSEL          (mhu_hsel),
    .HADDR         (mhu_haddr[18:0]),
    .HTRANS        (mhu_htrans),
    .HSIZE         (mhu_hsize),
    .HPROT         (mhu_hprot[3:0]),
    .HWRITE        (mhu_hwrite),
    .HREADY        (mhu_hready),
    .HWDATA        (mhu_hwdata),

    .HREADYOUT     (mhu_hreadyout),
    .HRDATA        (mhu_hrdata),
    .HRESP         (mhu_hresp),

    .PADDR         (mhu_paddr),
    .PENABLE       (mhu_penable),
    .PWRITE        (mhu_pwrite),
    .PSTRB         (mhu_pstrb),
    .PPROT         (mhu_pprot),
    .PWDATA        (mhu_pwdata),
    .PSEL          (mhu_psel),

    .APBACTIVE     (mhu_apbactive),

    .PRDATA        (mhu_prdata),
    .PREADY        (mhu_pready),
    .PSLVERR       (mhu_pslverr)
  );
    
  always @(posedge extsys_hclk or negedge extsys_mtx_resetn)
    if(~extsys_mtx_resetn)
      mhu_pwakeup_r <= 1'b0;
    else
      mhu_pwakeup_r <= mhu_apbactive;
    
  assign mhu_pwakeup = mhu_pwakeup_r;    
  



  cmsdk_ahb_to_apb #(
    .ADDRWIDTH      (23),
    .REGISTER_RDATA (1),
    .REGISTER_WDATA (0)
  ) u_cmsdk_ahb_to_apb_extdbg (
    .HCLK          (extsys_hclk),
    .HRESETn       (extsys_mtx_resetn),
    .PCLKEN        (1'b1),    

    .HSEL          (extdbg_hsel),
    .HADDR         (extdbg_haddr[22:0]),
    .HTRANS        (extdbg_htrans),
    .HSIZE         (extdbg_hsize),
    .HPROT         (extdbg_hprot[3:0]),
    .HWRITE        (extdbg_hwrite),
    .HREADY        (extdbg_hready),
    .HWDATA        (extdbg_hwdata),

    .HREADYOUT     (extdbg_hreadyout),
    .HRDATA        (extdbg_hrdata),
    .HRESP         (extdbg_hresp),

    .PADDR         (extdbg_paddr[22:0]),
    .PENABLE       (extdbg_penable),
    .PWRITE        (extdbg_pwrite),
    .PSTRB         (extdbg_pstrb),
    .PPROT         (extdbg_pprot),
    .PWDATA        (extdbg_pwdata),
    .PSEL          (extdbg_psel),

    .APBACTIVE     (extdbg_apbactive),

    .PRDATA        (extdbg_prdata),
    .PREADY        (extdbg_pready),
    .PSLVERR       (extdbg_pslverr)
  );
  
  assign extdbg_paddr[31:23] = 9'h000;
  
  always @(posedge extsys_hclk or negedge extsys_mtx_resetn)
    if(~extsys_mtx_resetn)
      extdbg_pwakeup_r <= 1'b0;
    else
      extdbg_pwakeup_r <= extdbg_apbactive;
    
  assign extdbg_pwakeup = extdbg_pwakeup_r;
  
  

 css600_apbasyncbridgeslv u_css600_apbasyncbridgeslv_sysreg (
  .clk_s                      (extsys_hclk),
  .reset_s_n                  (extsys_mtx_resetn),
  .dftcgen                    (dftcgen),
  
  .psel_s                     (apbtargexp11_psel),
  .penable_s                  (apbtargexp11_penable),
  .paddr_s                    (apbtargexp11_paddr),
  .pwrite_s                   (apbtargexp11_pwrite),
  .pwdata_s                   (apbtargexp11_pwdata),
  .pprot_s                    (apbtargexp11_pprot),
  .prdata_s                   (apbtargexp11_prdata),
  .pready_s                   (apbtargexp11_pready),
  .pslverr_s                  (apbtargexp11_pslverr),
  .pwakeup_s                  (apbtargexp11_psel),
  
  .clk_s_qreq_n               (1'b1),
  .clk_s_qaccept_n            (),
  .clk_s_qdeny                (),
  .clk_s_qactive              (),
  
  .pwr_qreq_n                 (1'b1),
  .pwr_qaccept_n              (),
  .pwr_qdeny                  (),
  .pwr_qactive                (),
  
  .apb_async_req              (sysreg_apb_async_req),
  .apb_async_req_payload      (sysreg_apb_async_req_payload),
  .apb_async_resp_payload     (sysreg_apb_async_resp_payload),
  .apb_async_ack              (sysreg_apb_async_ack)
);


 css600_apbasyncbridgeslv u_css600_apbasyncbridgeslv_uart (
  .clk_s                      (extsys_hclk),
  .reset_s_n                  (extsys_mtx_resetn),
  .dftcgen                    (dftcgen),
  
  .psel_s                     (apbtargexp2_psel),
  .penable_s                  (apbtargexp2_penable),
  .paddr_s                    (apbtargexp2_paddr),
  .pwrite_s                   (apbtargexp2_pwrite),
  .pwdata_s                   (apbtargexp2_pwdata),
  .pprot_s                    (apbtargexp2_pprot),
  .prdata_s                   (apbtargexp2_prdata),
  .pready_s                   (apbtargexp2_pready),
  .pslverr_s                  (apbtargexp2_pslverr),
  .pwakeup_s                  (apbtargexp2_psel),
  
  .clk_s_qreq_n               (1'b1),
  .clk_s_qaccept_n            (),
  .clk_s_qdeny                (),
  .clk_s_qactive              (),
  
  .pwr_qreq_n                 (1'b1),
  .pwr_qaccept_n              (),
  .pwr_qdeny                  (),
  .pwr_qactive                (),
  
  .apb_async_req              (uart_apb_async_req),
  .apb_async_req_payload      (uart_apb_async_req_payload),
  .apb_async_resp_payload     (uart_apb_async_resp_payload),
  .apb_async_ack              (uart_apb_async_ack)
);

  assign unused = |{apbtargexp11_pstrb,
                    apbtargexp2_pstrb,
                    targexp1_hauser,
                    targexp1_hwuser,
                    mhu_hprot[6:4],
                    mhu_haddr[31:19],
                    extdbg_hprot[6:4],
                    initexp0_hruser,
                    initexp0_exresp,
                    xhb_awuser,
                    xhb_aruser,
                    xhb_wuser,
                    xhb_hprot[4],
                    unused_initexp0_hmaster,
                    extdbg_haddr[31:23],
                    mem_hmaster[3:1]};

endmodule
