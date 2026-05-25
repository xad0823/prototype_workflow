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


module sec_mem_integration #(
  parameter RAM_AW       = 20, 
  parameter ROM_AW       = 17  
) (
  input    wire            HCLK,
  input    wire            HRESETn,

  input  wire              RAM_HSEL,      
  input  wire              RAM_HREADY,    
  input  wire        [1:0] RAM_HTRANS,    
  input  wire        [2:0] RAM_HSIZE,     
  input  wire              RAM_HWRITE,    
  input  wire [RAM_AW-1:0] RAM_HADDR,     
  input  wire       [31:0] RAM_HWDATA,    
  output wire              RAM_HREADYOUT, 
  output wire              RAM_HRESP,     
  output wire       [31:0] RAM_HRDATA,    

  input  wire              ROM_HSEL,      
  input  wire              ROM_HREADY,    
  input  wire        [1:0] ROM_HTRANS,    
  input  wire        [2:0] ROM_HSIZE,     
  input  wire              ROM_HWRITE,    
  input  wire [ROM_AW-1:0] ROM_HADDR,     
  input  wire       [31:0] ROM_HWDATA,    
  output wire              ROM_HREADYOUT, 
  output wire              ROM_HRESP,     
  output wire       [31:0] ROM_HRDATA,    
  input  wire              DFTRAMHOLD
);

  wire       [31:0]  ramrdata;        
  wire [RAM_AW-3:0]  ramaddr;         
  wire        [3:0]  ramwen;          
  wire       [31:0]  ramwdata;        
  wire               ramcs;           

  wire       [31:0]  romrdata;        
  wire [ROM_AW-3:0]  romaddr;         
  wire        [3:0]  unused_romwen;   
  wire       [31:0]  romwdata;        
  wire               romcs;           
  
  wire               rom_ahb2sram_hsel;     
  wire               rom_ahb2sram_hready;   
  wire        [1:0]  rom_ahb2sram_htrans;   
  wire        [2:0]  rom_ahb2sram_hsize;    
  wire               rom_ahb2sram_hwrite;   
  wire [ROM_AW-1:0]  rom_ahb2sram_haddr;    
  wire       [31:0]  rom_ahb2sram_hwdata;   
  wire               rom_ahb2sram_hreadyout;
  wire               rom_ahb2sram_hresp;    
  wire       [31:0]  rom_ahb2sram_hrdata;   
  
  wire               ds_hsel;     
  wire               ds_hready;
  wire        [1:0]  ds_htrans;   
  wire               ds_hreadyout;
  wire               ds_hresp;    

  cmsdk_ahb_to_sram #(
    .AW           (RAM_AW)
  ) u_cmsdk_ahb_to_sram_0 (
    .HCLK         (HCLK         ),
    .HRESETn      (HRESETn      ),
    .HSEL         (RAM_HSEL     ),
    .HREADY       (RAM_HREADY   ),
    .HTRANS       (RAM_HTRANS   ),
    .HSIZE        (RAM_HSIZE    ),
    .HWRITE       (RAM_HWRITE   ),
    .HADDR        (RAM_HADDR    ),
    .HWDATA       (RAM_HWDATA   ),
    .HREADYOUT    (RAM_HREADYOUT),
    .HRESP        (RAM_HRESP    ),
    .HRDATA       (RAM_HRDATA   ),

    .SRAMRDATA    (ramrdata     ),
    .SRAMADDR     (ramaddr      ),
    .SRAMWEN      (ramwen       ),
    .SRAMWDATA    (ramwdata     ),
    .SRAMCS       (ramcs        )
  );

  secenc_f1_ram_wrapper #(
    .DATA_WIDTH   (32),
    .ADDR_WIDTH   (RAM_AW-2)
  ) u_secenc_f1_ram_wrapper (
    .clk          (HCLK),
    .a            (ramaddr),
    .cena         (ramcs),
    .wena         (ramwen),
    .q            (ramrdata),
    .d            (ramwdata),
    .DFTRAMHOLD   (DFTRAMHOLD)
  );


  assign ds_hsel           = ROM_HWRITE ? ROM_HSEL : 1'b0;
  assign rom_ahb2sram_hsel = ROM_HWRITE ? 1'b0     : ROM_HSEL;
  
  cmsdk_ahb_slave_mux #(
    .PORT0_ENABLE  (1),
    .PORT1_ENABLE  (1),
    .PORT2_ENABLE  (0),
    .PORT3_ENABLE  (0),
    .PORT4_ENABLE  (0),
    .PORT5_ENABLE  (0),
    .PORT6_ENABLE  (0),
    .PORT7_ENABLE  (0),
    .PORT8_ENABLE  (0),
    .PORT9_ENABLE  (0),
    .DW            (32)
  ) u_cmsdk_ahb_slave_mux (
  .HCLK          (HCLK),
  .HRESETn       (HRESETn),
  
  .HREADY        (ROM_HREADY),
  
  .HSEL0         (ds_hsel),
  .HREADYOUT0    (ds_hreadyout),
  .HRESP0        (ds_hresp),
  .HRDATA0       (32'h0000_0000),
  
  .HSEL1         (rom_ahb2sram_hsel),
  .HREADYOUT1    (rom_ahb2sram_hreadyout),
  .HRESP1        (rom_ahb2sram_hresp),
  .HRDATA1       (rom_ahb2sram_hrdata),
  
  .HSEL2         (1'b0),
  .HREADYOUT2    (1'b0),
  .HRESP2        (1'b0),
  .HRDATA2       (32'h0000_0000),
  
  .HSEL3         (1'b0),
  .HREADYOUT3    (1'b0),
  .HRESP3        (1'b0),
  .HRDATA3       (32'h0000_0000),
  
  .HSEL4         (1'b0),
  .HREADYOUT4    (1'b0),
  .HRESP4        (1'b0),
  .HRDATA4       (32'h0000_0000),
  
  .HSEL5         (1'b0),
  .HREADYOUT5    (1'b0),
  .HRESP5        (1'b0),
  .HRDATA5       (32'h0000_0000),
  
  .HSEL6         (1'b0),
  .HREADYOUT6    (1'b0),
  .HRESP6        (1'b0),
  .HRDATA6       (32'h0000_0000),
  
  .HSEL7         (1'b0),
  .HREADYOUT7    (1'b0),
  .HRESP7        (1'b0),
  .HRDATA7       (32'h0000_0000),
  
  .HSEL8         (1'b0),
  .HREADYOUT8    (1'b0),
  .HRESP8        (1'b0),
  .HRDATA8       (32'h0000_0000),
  
  .HSEL9         (1'b0),
  .HREADYOUT9    (1'b0),
  .HRESP9        (1'b0),
  .HRDATA9       (32'h0000_0000),
  
  .HREADYOUT     (ROM_HREADYOUT),
  .HRESP         (ROM_HRESP),
  .HRDATA        (ROM_HRDATA)
  );   
 
  assign ds_htrans = ROM_HTRANS;
  assign ds_hready = ROM_HREADY;
  
  assign rom_ahb2sram_htrans = ROM_HTRANS;
  assign rom_ahb2sram_hready = ROM_HREADY;
  assign rom_ahb2sram_hsize  = ROM_HSIZE;
  assign rom_ahb2sram_haddr  = ROM_HADDR;
  assign rom_ahb2sram_hwdata = ROM_HWDATA;
  assign rom_ahb2sram_hwrite = 1'b0;
 
  
  cmsdk_ahb_default_slave u_cmsdk_ahb_default_slave (
   .HCLK        (HCLK),      
   .HRESETn     (HRESETn),   
   .HSEL        (ds_hsel),      
   .HTRANS      (ds_htrans),    
   .HREADY      (ds_hready),

   .HREADYOUT   (ds_hreadyout),
  . HRESP       (ds_hresp)
 );
  
  cmsdk_ahb_to_sram #(
    .AW           (ROM_AW)
  ) u_cmsdk_ahb_to_sram_1 (
    .HCLK         (HCLK                  ),
    .HRESETn      (HRESETn               ),
    .HSEL         (rom_ahb2sram_hsel     ),
    .HREADY       (rom_ahb2sram_hready   ),
    .HTRANS       (rom_ahb2sram_htrans   ),
    .HSIZE        (rom_ahb2sram_hsize    ),
    .HWRITE       (rom_ahb2sram_hwrite   ),
    .HADDR        (rom_ahb2sram_haddr    ),
    .HWDATA       (rom_ahb2sram_hwdata   ),
    .HREADYOUT    (rom_ahb2sram_hreadyout),
    .HRESP        (rom_ahb2sram_hresp    ),
    .HRDATA       (rom_ahb2sram_hrdata   ),

    .SRAMRDATA    (romrdata     ),
    .SRAMADDR     (romaddr      ),
    .SRAMWEN      (unused_romwen),
    .SRAMWDATA    (romwdata     ),
    .SRAMCS       (romcs        )
  );

  secenc_f1_rom_wrapper #(
    .DATA_WIDTH   (32),
    .ADDR_WIDTH   (ROM_AW-2)
  ) u_secenc_f1_rom_wrapper (
    .clk          (HCLK),
    .a            (romaddr),
    .cena         (romcs),
  `ifdef FPGA
    .wena         (unused_romwen),
  `else
    .wena         (4'b1111),
  `endif
    .q            (romrdata),
    .d            (romwdata)
  );

endmodule
