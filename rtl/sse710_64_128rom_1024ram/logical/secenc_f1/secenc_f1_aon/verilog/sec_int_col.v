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


module sec_int_col #(
  parameter   [127:0] IRQCOL = 128'h0000_0000_0000_00FF_FFFF_FFFF_0000_01FF 
) (
  input  wire         clk,
  input  wire         rst_n,

  input  wire [127:0] int_i,
  input  wire [127:0] mask,
  output wire [127:0] int_st,
  output wire         comb_int_o
);

  wire [127:0] irq_sync;    
  wire [127:0] enabled_irq; 
  wire         unused;      
    
  genvar idx;
  generate for (idx = 0; idx < 128; idx = idx + 1)
  begin: sync_loop
  
    if (IRQCOL[idx] == 1'b1)
    begin: gen_sync
    
      sec_cdc_capt_sync u_sec_cdc_capt_sync (
        .clk        (clk),
        .nreset     (rst_n),
        .d_async    (int_i[idx]),
        .q          (irq_sync[idx])
      );
      
    end else 
    begin: gen_tieoff
    
      assign irq_sync[idx] = 1'b0;
      
    end 
    
  end 
  endgenerate
  
  assign enabled_irq = irq_sync & (~mask);
  
  assign int_st = enabled_irq;
  
  assign comb_int_o = |enabled_irq;
  
  assign unused = |int_i;

endmodule
