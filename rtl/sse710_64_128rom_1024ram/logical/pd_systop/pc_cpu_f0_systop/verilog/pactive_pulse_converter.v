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
module pactive_pulse_converter #(
    parameter PACTIVE_SYNC      = 1'b0
)
(
    input wire clk,
    input wire resetn,
    
    input wire  [9:0] pactive_in,
    output wire [9:0] pactive_out,
    
    input wire [8:0] ppuhwstat,
    
    output wire qactive    
);
    wire  [8:0] qactive_sync_hwstat_xor;
    
    wire  [9:0] pactive_in_ss;
    wire  [8:0] ppuhwstat_ss_d;
    reg   [8:0] ppuhwstat_ss_r;
    wire  [8:0] ppuhwstat_ss;
    wire  [9:0] pactive_mask;
    reg   [9:0] pactive_reg;
    wire  [9:0] nx_pactive_reg;        
    wire  [9:0] qactive_sync_dd;
    wire  [9:0] qactive_sync_dd2;
    
    wire        qactive_sync_hwstat;
    reg   [9:0] pactive_in_ss2;
    wire  [9:0] qactive_reg;
    
    
    
    genvar i;  
    
    if( PACTIVE_SYNC == 1'b1)
    begin : has_sync
        
        
        for(i=0;i<10;i=i+1)
        begin : sync    
            arm_element_cdc_capt_sync 
            u_pactive_ss (
            .clk    (clk),
            .nreset (resetn),
            
            .d_async (pactive_in[i]),
            .q       (pactive_in_ss[i])
            );            
            arm_element_std_xor2 u_qactive_sync_gen (
            .A (pactive_in[i]),
            .B (pactive_in_ss[i]),
            
            .Y (qactive_sync_dd[i])
            );
            
            arm_element_std_xor2 u_qactive_sync_gen2 (
            .A (pactive_in_ss[i]),
            .B (pactive_in_ss2[i]),
            
            .Y (qactive_sync_dd2[i])
            );
        end
        
        for(i=0;i<9;i=i+1)
        begin : sync2           
            arm_element_cdc_capt_sync 
            u_ppuhwstat_delay (
            .clk    (clk),
            .nreset (resetn),
            
            .d_async (ppuhwstat[i]),
            .q       (ppuhwstat_ss_d[i])
            );
            arm_element_std_xor2 u_qactive_gen_hwstat_xor1 (
            .A (ppuhwstat[i]),
            .B (ppuhwstat_ss[i]),            
            .Y (qactive_sync_hwstat_xor[i])
            );            
        end
        
        always @(posedge clk or negedge resetn)
        begin
            if(!resetn)
            begin
                ppuhwstat_ss_r<=9'd0;
                pactive_in_ss2<=10'd0;
            end
            else
            begin
                ppuhwstat_ss_r<=ppuhwstat_ss_d;
                pactive_in_ss2<=pactive_in_ss;
            end
        end
        
        assign ppuhwstat_ss = ppuhwstat_ss_r;
        
         
        arm_element_or_tree #(
        .NUM_OR_TREE_INPUTS(9)
        ) 
        u_qactive_gen_hwstat_or (
        .or_tree_i (qactive_sync_hwstat_xor),        
        .or_tree_o (qactive_sync_hwstat)
        );      
        
    end
    
    if( PACTIVE_SYNC == 1'b0)
    begin : no_sync
        assign pactive_in_ss = pactive_in;
        assign ppuhwstat_ss = ppuhwstat;
        assign qactive_sync_hwstat = 1'd0;
        assign qactive_sync_dd     = 10'd0;
        assign qactive_sync_dd2    = 10'd0;
    end
    
    assign pactive_mask[0] = 1'b0;
    
    for(i=1;i<10;i=i+1)
    begin : pactive_loop       
        assign pactive_mask[i] = pactive_mask[i-1] | ppuhwstat_ss[i-1];                      
    end
    
    assign nx_pactive_reg = (pactive_mask & pactive_reg) | pactive_in_ss;
    
    always @(posedge clk or negedge resetn)
    begin
         if(!resetn)
         begin
             pactive_reg<=10'd0;
         end
         else
         begin
             pactive_reg<=nx_pactive_reg;           
         end
    end
            
    arm_element_or_tree #(
        .NUM_OR_TREE_INPUTS(21)
    ) 
    u_qactive_gen (
    .or_tree_i ({qactive_sync_dd,
                 qactive_sync_dd2,
                qactive_sync_hwstat
                }),
    
    .or_tree_o (qactive)
    );
    
    assign pactive_out = pactive_reg;
    
endmodule     
    
