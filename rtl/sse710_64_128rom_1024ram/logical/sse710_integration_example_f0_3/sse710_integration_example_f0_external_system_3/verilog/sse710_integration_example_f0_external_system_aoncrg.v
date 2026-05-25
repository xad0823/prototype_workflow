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

module sse710_integration_example_f0_external_system_aoncrg (
    
    input  wire           extsys_fclk,
    output wire           extsys_aonclk,
    output wire           extsys_clk,
    
    input  wire           extsys_poresetn,
    input  wire           extsys_cpuwait,
    input  wire           ppu_devwarmresetn,
        
    output wire           extsys_poresetn_s,
    output wire           extsys_core_resetn,
    
    
    output wire           ppuclk_qreqn,        
    input  wire           ppuclk_qacceptn,    
    input  wire           ppuclk_qdeny,     
    input  wire           ppuclk_qactive,    
    
    output wire           sysreg_adb_clk_qreqn,        
    input  wire           sysreg_adb_clk_qacceptn,    
    input  wire           sysreg_adb_clk_qdeny,     
    input  wire           sysreg_adb_clk_qactive,    
    
    output wire           uart_adb_clk_qreqn,        
    input  wire           uart_adb_clk_qacceptn,    
    input  wire           uart_adb_clk_qdeny,     
    input  wire           uart_adb_clk_qactive,     
    
    output wire           ppu_adb_clk_qreqn,        
    input  wire           ppu_adb_clk_qacceptn,    
    input  wire           ppu_adb_clk_qdeny,     
    input  wire           ppu_adb_clk_qactive,    
    
    input  wire           lpdp_clk_qactive,
    
    input  wire           p2q_core_clk_qactive,
    
    input  wire           p2q_dbg_clk_qactive,
    
    input  wire           lpdq_core_clk_qactive,
    
    input  wire           lpdq_dbg_clk_qactive,
    
    input  wire           lpdq_systop_clk_qactive,    
    
    input  wire           lpcq_systop_clk_qactive,
    
    input  wire           lpcq_dbgtop_clk_qactive,
    
    input  wire           lpcq_aontop_clk_qactive,    
    
    input  wire           extdbgrom_reqack_clk_qactive,
    input  wire           axiaprom_reqack_clk_qactive,
    
    input  wire           cpu_pwrctrl_qactive,
    
    input  wire           ppu_devclken,
    
    input  wire [8:0]     clock_override,
    
    output wire           resetsyndrome_log_en,
    
    input  wire           warm_rst_state,
    
    input  wire           mbistreq,
    input  wire           dftcgen,
    input  wire           dftrstdisable    
    
  );

  
  wire            extsys_cpuwait_ss;
  wire            extsys_cpuwait_ss_n;
  wire            extsys_core_resetn_int;
  
  wire            merged_clk_qactive;
  wire [11:0]     or_tree_i;
  
  wire [3:0]      clk_qreqn;
  wire [3:0]      clk_qacceptn;
  wire [3:0]      clk_qdeny;
  wire [3:0]      clk_qactive;
  
  wire            extsys_aonclk_en;  
  wire            extsys_clk_en;
  
  wire            static_en;
  reg             static_up;
  
  wire            dftcgen_or_mbistreq;

  
  arm_element_cdc_capt_sync u_arm_element_cdc_capt_sync (
    .clk     (extsys_fclk),
    .nreset  (extsys_poresetn_s),
    .d_async (extsys_cpuwait),
    .q       (extsys_cpuwait_ss)
  ); 
  
  arm_element_std_inverter u_arm_element_std_inverter(
    .inv_in  (extsys_cpuwait_ss),
    .inv_out (extsys_cpuwait_ss_n)
  );

  arm_element_cdc_comb_and2 u_arm_element_cdc_comb_and2 (
    .din1_async (extsys_cpuwait_ss_n),
    .din2_async (ppu_devwarmresetn),
    .dout_async (extsys_core_resetn_int)
  );
  
  arm_element_std_or2 u_arm_element_std_or2(
    .A  (dftrstdisable),
    .B  (extsys_core_resetn_int),
    .Y  (extsys_core_resetn)
  );
  
  arm_element_reset_sync u_arm_element_reset_sync_extsys_poreset (
    .clk                (extsys_fclk),
    .resetn_async       (extsys_poresetn),
    .resetn_sync        (extsys_poresetn_s),
    .dftrstdisable      (dftrstdisable)
  );


  assign {ppuclk_qreqn, sysreg_adb_clk_qreqn, uart_adb_clk_qreqn, ppu_adb_clk_qreqn} = clk_qreqn;
                      
  assign clk_qacceptn = {ppuclk_qacceptn,
                         sysreg_adb_clk_qacceptn,
                         uart_adb_clk_qacceptn,
                         ppu_adb_clk_qacceptn};
                      
  assign clk_qdeny    = {ppuclk_qdeny,
                         sysreg_adb_clk_qdeny,
                         uart_adb_clk_qdeny,
                         ppu_adb_clk_qdeny};
                      
  assign clk_qactive  = {ppuclk_qactive,
                         sysreg_adb_clk_qactive,
                         uart_adb_clk_qactive,
                         ppu_adb_clk_qactive}; 
     

  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (12)
  ) u_arm_element_or_tree_1 (
    .or_tree_i  (or_tree_i),
    .or_tree_o  (merged_clk_qactive)
  );  
  
  assign or_tree_i = {lpdp_clk_qactive              ,
                      p2q_core_clk_qactive          , 
                      p2q_dbg_clk_qactive           ,
                      lpdq_core_clk_qactive         ,
                      lpdq_dbg_clk_qactive          ,
                      lpdq_systop_clk_qactive       ,
                      lpcq_systop_clk_qactive       ,
                      lpcq_dbgtop_clk_qactive       ,
                      lpcq_aontop_clk_qactive       ,
                      extdbgrom_reqack_clk_qactive  ,
                      axiaprom_reqack_clk_qactive   ,
                      cpu_pwrctrl_qactive};                      

  
  pck600_clk_ctrl #(
    .NUM_Q_CHL            (4),
    .NUM_QACTIVE_ONLY     (1),
    .HC_Q_CH_SYNC         (0),
    .PWR_Q_CH_SYNC        (0),
    .CLK_Q_CH_SYNC        (1),
    .CLK_QACTIVE_SYNC     (1),
    .ACTIVE_DENY_EN       (0)
  ) u_pck600_clk_ctrl (
    .clk                 (extsys_fclk),
    .reset_n             (extsys_poresetn_s),

    .dftcgen             (dftcgen),

    .hc_qreqn_i          (1'b1),
    .hc_qacceptn_o       (),
    .hc_qdeny_o          (),
    .hc_qactive_o        (),

    .pwr_qreqn_i         (1'b1),
    .pwr_qacceptn_o      (),
    .pwr_qdeny_o         (),
    .pwr_qactive_o       (),

    .clk_qreqn_o         (clk_qreqn),
    .clk_qacceptn_i      (clk_qacceptn),
    .clk_qactive_i       ({merged_clk_qactive, clk_qactive}),
    .clk_qdeny_i         (clk_qdeny),

    .clk_force_i         (clock_override[0]),

    .entry_delay_i       (clock_override[8:1]),

    .clken_o             (extsys_aonclk_en)
  );
                               

  arm_element_clock_gate u_arm_element_clock_gate_aonclk (
    .clk_in              (extsys_fclk),
    .enable              (extsys_aonclk_en),
    .clk_out             (extsys_aonclk),
    .dftcgen             (dftcgen)
  );
  
  assign extsys_clk_en = ppu_devclken & ~warm_rst_state;
  
  arm_element_clock_gate u_arm_element_clock_gate_extsys_clk (
    .clk_in              (extsys_fclk),
    .enable              (extsys_clk_en),
    .clk_out             (extsys_clk),
    .dftcgen             (dftcgen_or_mbistreq)
  );
  
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_arm_element_or_tree_2 (
    .or_tree_i  ({dftcgen, mbistreq}),
    .or_tree_o  (dftcgen_or_mbistreq)
  );
  
  
  always@(posedge extsys_fclk or negedge extsys_poresetn_s)
  begin
    if(!extsys_poresetn_s)
    begin
      static_up <= 1'b1;
    end
    else if(static_en)
    begin
      static_up <= 1'b0;
    end
  end
  
  assign static_en            = static_up;
  assign resetsyndrome_log_en = static_up;
  
endmodule
