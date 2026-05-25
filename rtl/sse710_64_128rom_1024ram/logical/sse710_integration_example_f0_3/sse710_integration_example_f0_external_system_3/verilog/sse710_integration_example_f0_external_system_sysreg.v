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

module sse710_integration_example_f0_external_system_sysreg (
    
    input  wire           extsys_aonclk,
    input  wire           extsys_fclk,
    
    input  wire           extsys_poresetn_s,
        
    output wire           sysreg_pready,
    output wire [31:0]    sysreg_prdata,
    output wire           sysreg_pslverr,
    input  wire [11:0]    sysreg_paddr,
    input  wire           sysreg_penable,
    input  wire           sysreg_pwrite,
    input  wire [31:0]    sysreg_pwdata,
    input  wire           sysreg_psel,   
    
    input  wire           sysreset_req_ss,
    input  wire           resetsyndrome_log_en, 
    input  wire [4:0]     extsys_rstsyn,

    output wire           pwrdown_en,

    output wire [8:0]     clock_override_extsystop, 
    output wire [8:0]     clock_override_aon
   
  );


  wire            selx;
  wire [11:0]     paddr;
  wire            writeen;
  wire            readen;

  reg  [31:0]     rdata_sysctrl;
  reg  [31:0]     sysreg_prdata_reg;
  
  reg  [5:0]      reg_resetsyndrome;
  wire            reg_resetsyndrome_write;
  wire [5:0]      nxt_resetsyndrome;   
  wire            reg_resetsyndrome_en;
  
  reg             reg_pwrdownen;
  wire            reg_pwrdownen_write;     
  wire            nxt_pwrdownen;
  wire            reg_pwrdownen_en;
  
  reg  [17:0]     reg_chickenbit;
  wire            reg_chickenbit_write;
  wire [17:0]     nxt_chickenbit;   
  wire            reg_chickenbit_en;
  
  wire            unused;
    

  assign  selx            = sysreg_psel;
  assign  paddr           = selx ? {sysreg_paddr[11:0]}: {12{1'b0}};
  assign  writeen         = selx & sysreg_pwrite;
  assign  readen          = selx & (~sysreg_pwrite);
  assign  sysreg_pslverr  = 1'b0;
  assign  sysreg_pready   = 1'b1;


  assign    reg_resetsyndrome_write = writeen && (paddr[11:2] == 10'h000 ? 1'b1: 1'b0);

  assign    nxt_resetsyndrome[0] = (((reg_resetsyndrome_write & sysreg_pwdata[0])) & reg_resetsyndrome[0]) | (extsys_rstsyn[0] & resetsyndrome_log_en);
  assign    nxt_resetsyndrome[1] = (((reg_resetsyndrome_write & sysreg_pwdata[1])) & reg_resetsyndrome[1]) | (extsys_rstsyn[1] & resetsyndrome_log_en);
  assign    nxt_resetsyndrome[2] = (((reg_resetsyndrome_write & sysreg_pwdata[2])) & reg_resetsyndrome[2]) | (extsys_rstsyn[2] & resetsyndrome_log_en);
  assign    nxt_resetsyndrome[3] = (((reg_resetsyndrome_write & sysreg_pwdata[3])) & reg_resetsyndrome[3]) | (extsys_rstsyn[3] & resetsyndrome_log_en);
  assign    nxt_resetsyndrome[4] = (((reg_resetsyndrome_write & sysreg_pwdata[4])) & reg_resetsyndrome[4]) | (extsys_rstsyn[4] & resetsyndrome_log_en);   
  assign    nxt_resetsyndrome[5] = (((reg_resetsyndrome_write & sysreg_pwdata[5])) & reg_resetsyndrome[5]) | sysreset_req_ss;
 
  assign    reg_resetsyndrome_en = reg_resetsyndrome_write | sysreset_req_ss | resetsyndrome_log_en ;

  always @(posedge extsys_fclk or negedge extsys_poresetn_s)
  begin
    if (~extsys_poresetn_s)
      reg_resetsyndrome <= 6'b00_0000;
    else if (reg_resetsyndrome_en)
      reg_resetsyndrome <= nxt_resetsyndrome;
   end



  assign    reg_pwrdownen_write = writeen && paddr[11:2]  == 10'h001 ? 1'b1: 1'b0;

  assign    nxt_pwrdownen = reg_pwrdownen_write & sysreg_pwdata[0];

  assign    reg_pwrdownen_en = reg_pwrdownen_write;

  always @(posedge extsys_aonclk or negedge extsys_poresetn_s)
  begin
    if (~extsys_poresetn_s)
      reg_pwrdownen <= 1'b0;      
    else if (reg_pwrdownen_en)
      reg_pwrdownen <= nxt_pwrdownen;
   end
   

  assign    reg_chickenbit_write = writeen && paddr[11:2]  == 10'h002 ? 1'b1: 1'b0;

  assign    nxt_chickenbit = {18{reg_chickenbit_write}} & sysreg_pwdata[17:0];

  assign    reg_chickenbit_en = reg_chickenbit_write;

  always @(posedge extsys_aonclk or negedge extsys_poresetn_s)
  begin
    if (~extsys_poresetn_s)
      reg_chickenbit <= 18'h0_3E1F;
    else if (reg_chickenbit_en)
      reg_chickenbit <= nxt_chickenbit;
   end
   

  always @(readen or paddr or reg_resetsyndrome or reg_pwrdownen or reg_chickenbit)
    begin : p_sysctrl_pdata_comb
      case (readen)
       1'b1: begin
         case (paddr[11:2])
          10'h000:   rdata_sysctrl = {{26{1'b0}},reg_resetsyndrome};
          10'h001:   rdata_sysctrl = {{31{1'b0}},reg_pwrdownen};
          10'h002:   rdata_sysctrl = {{14{1'b0}},reg_chickenbit};
          default:   rdata_sysctrl = {32{1'b0}};
         endcase
       end
       1'b0: begin
         rdata_sysctrl = {32{1'b0}};
       end
       default: begin
         rdata_sysctrl = {32{1'bx}};
       end
      endcase
    end 

  always @(posedge extsys_aonclk or negedge extsys_poresetn_s)
  begin
    if (~extsys_poresetn_s)
      begin
      sysreg_prdata_reg                <= {32{1'b0}};
      end
    else if (readen)
      begin
      sysreg_prdata_reg                <= rdata_sysctrl;
      end
  end
  

  assign sysreg_prdata               = sysreg_prdata_reg;
  assign pwrdown_en                  = reg_pwrdownen;
  assign clock_override_extsystop    = reg_chickenbit[17:9];  
  assign clock_override_aon          = reg_chickenbit[8:0];
 
  
  assign unused = (|sysreg_pwdata[31:18]) |
                  (|paddr[1:0])           |
                  (sysreg_penable);  

endmodule
