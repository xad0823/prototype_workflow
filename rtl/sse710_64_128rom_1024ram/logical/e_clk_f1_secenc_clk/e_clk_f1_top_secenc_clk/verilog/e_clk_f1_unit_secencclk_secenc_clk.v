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



 

module e_clk_f1_unit_secencclk_secenc_clk (
    input   wire                        SYSTOP_RESETn,  
    
    input   wire                        SECENCCLK_AON,
 
    output  wire                        SECENCCLK,

    input   wire                        SECENCCLK_DCT_CG,

 

    input   wire                        DFTCGEN,
    input   wire                        DFTRSTDISABLE
);


 

 
 


wire            dct_cg_resetn_sync;

e_clk_f1_reset_sync_secenc_clk u_e_clk_f1_reset_sync_dct_cg
(
    .CLK                    (SECENCCLK_AON), 
    .ASYNCRESETn            (SYSTOP_RESETn), 
    .SYNCRESETn             (dct_cg_resetn_sync), 
    .DFTRSTDISABLE          (DFTRSTDISABLE) 
);

wire            dct_cg_sync;

e_clk_f1_cdc_capt_sync_secenc_clk u_e_clk_f1_cdc_capt_sync_dct_cg
(
    .clk                    (SECENCCLK_AON), 
    .nreset                 (dct_cg_resetn_sync), 
    .d_async                (SECENCCLK_DCT_CG), 
    .q                      (dct_cg_sync) 
);

wire            clk_dct_cg;

e_clk_f1_clock_gate_secenc_clk u_e_clk_f1_clock_gate_dct_cg
(
    .CLKIN                  (SECENCCLK_AON), 
    .CLKOUT                 (clk_dct_cg), 
    .ENABLE                 (dct_cg_sync), 
    .DFTSE                  (DFTCGEN) 
);


wire            c_clk_buf;  

e_clk_f1_clock_buffer_secenc_clk 
#(
    .CLOCK_DELAY    (0)
)
u_e_clk_f1_clock_buffer_secencclk 
(
    .clk_in                 (clk_dct_cg), 
    .clk_out                (c_clk_buf) 
);
  
  
assign SECENCCLK = c_clk_buf;



 
endmodule

 

