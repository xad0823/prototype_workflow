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

module apb4_arbiter
#(
    parameter SLAVE_CNT = 1    
)
(
  input wire                    clk,
  input wire                    resetn,
  
  input wire [31:0]             paddr_s,   
  input wire                    psel_s,    
  input wire [2:0]              pprot_s,   
  input wire                    penable_s, 
  output wire                   pready_s,  
  output wire [31:0]            prdata_s,  
  output wire                   pslverr_s, 
  
  output wire [SLAVE_CNT-1:0]   psel_m,    
  input  wire [SLAVE_CNT-1:0]   pready_m,  
  input  wire [SLAVE_CNT*32-1:0] prdata_m, 
  input  wire [SLAVE_CNT-1:0]   pslverr_m, 
  
  output wire [31:0]            addr_arb,
  input  wire [SLAVE_CNT-1:0]   sel_arb,
  
  input  wire [SLAVE_CNT-1:0]   slv_sec,
  
  output wire                   qactive
 );
 
 genvar i;
 genvar j;
 
 wire [SLAVE_CNT*32-1:0] prdata_bits; 
 wire [SLAVE_CNT-1:0]    security_mask;

 reg  [SLAVE_CNT-1:0]    reg_sel_arb;
 wire [SLAVE_CNT-1:0]    nx_sel_arb;

 reg                     reg_slave_err; 
 wire                    nx_slave_err; 
 
 assign nx_sel_arb = (psel_s && penable_s && pready_s) ? {SLAVE_CNT{1'b0}} : 
                                                        (sel_arb & security_mask);
 assign addr_arb = paddr_s;

 assign qactive   = psel_s;
 
 
 assign security_mask = ~(slv_sec & {SLAVE_CNT{pprot_s[1]}});
 
 assign psel_m = sel_arb & {SLAVE_CNT{psel_s}} & security_mask;
   
 assign nx_slave_err = (psel_s & !penable_s) ? (nx_sel_arb == {SLAVE_CNT{1'b0}}) : 1'b0;
 
  
 
 assign pready_s    = reg_slave_err ? 1'b1 : |(pready_m  & reg_sel_arb); 
 assign pslverr_s   = reg_slave_err ? 1'b1 : |(pslverr_m & reg_sel_arb);
 
 generate 
 for(i=0;i<32;i=i+1)  begin : prdata     
       assign prdata_s[i]  = |(reg_sel_arb & prdata_bits[i*SLAVE_CNT +: SLAVE_CNT]);
 end
 endgenerate
 
 generate
    for(i=0;i<32;i=i+1)
    begin : prdata_t
        for(j=0;j<SLAVE_CNT;j=j+1)
        begin : prdata_t_1
            assign prdata_bits[i*SLAVE_CNT+j] = prdata_m[32*j+i];
        end
    end        
 endgenerate
 
 
 always @(posedge clk or negedge resetn)
 begin
    if(!resetn)
    begin
        reg_sel_arb<={SLAVE_CNT{1'b0}};
        reg_slave_err<=1'b0;
    end
    else
    begin
        if(psel_s)
        begin
            reg_sel_arb<=nx_sel_arb;     
        end
        reg_slave_err<=nx_slave_err;
    end 
 end
 

endmodule 
 

