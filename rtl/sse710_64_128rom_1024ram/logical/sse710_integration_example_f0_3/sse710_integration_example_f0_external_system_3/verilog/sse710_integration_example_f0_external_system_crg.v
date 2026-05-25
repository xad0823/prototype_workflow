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

module sse710_integration_example_f0_external_system_crg (
    
    input  wire           extsys_clk,
    output wire           extsys_hclk,
    output wire           extsys_dclk,
    output wire           extsys_timer0pclkg,
    output wire           extsys_timer1pclkg,

    input  wire           core_resetn,
    input  wire           mtx_resetn,
    input  wire           dbg_resetn,
    
    output wire           core_resetn_s,
    output wire           mtx_resetn_s,
    output wire           dbg_resetn_s,    

    output wire           aclk_qreqn,        
    input  wire           aclk_qacceptn,    
    input  wire           aclk_qdeny,      
    input  wire           aclk_qactive,      

    output wire           mhuclk_qreqn,        
    input  wire           mhuclk_qacceptn,    
    input  wire           mhuclk_qdeny,      
    input  wire           mhuclk_qactive,
    
    output wire           atclk_qreqn,        
    input  wire           atclk_qacceptn,    
    input  wire           atclk_qdeny,      
    input  wire           atclk_qactive,
    
    output wire           dbgclkm_qreqn,        
    input  wire           dbgclkm_qacceptn,    
    input  wire           dbgclkm_qdeny,      
    input  wire           dbgclkm_qactive,

    output wire           dbgclks_qreqn,        
    input  wire           dbgclks_qacceptn,    
    input  wire           dbgclks_qdeny,      
    input  wire           dbgclks_qactive,

    output wire           cticlk_qreqn,        
    input  wire           cticlk_qacceptn,    
    input  wire           cticlk_qdeny,      
    input  wire           cticlk_qactive,

    output wire           expclk_qreqn,        
    input  wire           expclk_qacceptn,    
    input  wire           expclk_qdeny,      
    input  wire           expclk_qactive,    

    output wire           hxb_clk_qreqn,        
    input  wire           hxb_clk_qacceptn,    
    input  wire           hxb_clk_qdeny,      
    input  wire           hxb_clk_qactive,    
    
    input  wire           extdbgrom_cdbgpwrupack_ss,
    input  wire           axiaprom_csyspwrupack_ss,
    input  wire           sleeping,
    input  wire           timer0pclk_qactive,
    input  wire           timer1pclk_qactive,
    
    input  wire [8:0]     clock_override_extsystop,
    
    input  wire           mbistreq,
    input  wire           dftcgen,
    input  wire [1:0]     dftrstdisable
    
  );

  
  wire [4:0]      hclk_qreqn;
  wire [4:0]      hclk_qacceptn;
  wire [4:0]      hclk_qdeny;
  wire [4:0]      hclk_qactive;
  
  wire [2:0]      dclk_qreqn;
  wire [2:0]      dclk_qacceptn;
  wire [2:0]      dclk_qdeny;
  wire [2:0]      dclk_qactive;

  wire            hclk_en_bridges;
  wire            dclk_en_bridges;
  wire            extsys_hclk_en;
  wire            extsys_dclk_en;
  wire            extsys_timer0pclkg_en;
  wire            extsys_timer1pclkg_en;
  
  wire            dftcgen_or_mbistreq;


  assign {hxb_clk_qreqn, aclk_qreqn, mhuclk_qreqn, dbgclks_qreqn, expclk_qreqn} = hclk_qreqn;
                      
  assign hclk_qacceptn = {hxb_clk_qacceptn,
                      aclk_qacceptn,
                      mhuclk_qacceptn,
                      dbgclks_qacceptn,
                      expclk_qacceptn
                      };
                      
  assign hclk_qdeny = {hxb_clk_qdeny,
                      aclk_qdeny,
                      mhuclk_qdeny,
                      dbgclks_qdeny,
                      expclk_qdeny};
                      
  assign hclk_qactive = {hxb_clk_qactive,
                         aclk_qactive,
                         mhuclk_qactive,
                         dbgclks_qactive,
                         expclk_qactive};      


  assign {atclk_qreqn, dbgclkm_qreqn, cticlk_qreqn} = dclk_qreqn;
                      
  assign dclk_qacceptn = {atclk_qacceptn,
                          dbgclkm_qacceptn,
                          cticlk_qacceptn};
                      
  assign dclk_qdeny = {atclk_qdeny,
                       dbgclkm_qdeny,
                       cticlk_qdeny};
                      
  assign dclk_qactive = {atclk_qactive,
                         dbgclkm_qactive,
                         cticlk_qactive};                         
  
  
  pck600_clk_ctrl #(
    .NUM_Q_CHL            (5),
    .NUM_QACTIVE_ONLY     (0),
    .HC_Q_CH_SYNC         (0),
    .PWR_Q_CH_SYNC        (0),
    .CLK_Q_CH_SYNC        (1),
    .CLK_QACTIVE_SYNC     (1),
    .ACTIVE_DENY_EN       (0)
  ) u_pck600_clk_ctrl_hclk (
    .clk                 (extsys_clk),
    .reset_n             (mtx_resetn_s),

    .dftcgen             (dftcgen),

    .hc_qreqn_i          (1'b1),
    .hc_qacceptn_o       (),
    .hc_qdeny_o          (),
    .hc_qactive_o        (),

    .pwr_qreqn_i         (1'b1),
    .pwr_qacceptn_o      (),
    .pwr_qdeny_o         (),
    .pwr_qactive_o       (),

    .clk_qreqn_o         (hclk_qreqn),
    .clk_qacceptn_i      (hclk_qacceptn),
    .clk_qactive_i       (hclk_qactive),
    .clk_qdeny_i         (hclk_qdeny),

    .clk_force_i         (clock_override_extsystop[0]),

    .entry_delay_i       (clock_override_extsystop[8:1]),

    .clken_o             (hclk_en_bridges)
    );
    
  pck600_clk_ctrl #(
    .NUM_Q_CHL            (3),
    .NUM_QACTIVE_ONLY     (0),
    .HC_Q_CH_SYNC         (0),
    .PWR_Q_CH_SYNC        (0),
    .CLK_Q_CH_SYNC        (1),
    .CLK_QACTIVE_SYNC     (1),
    .ACTIVE_DENY_EN       (0)
  ) u_pck600_clk_ctrl_dclk (
    .clk                 (extsys_clk),
    .reset_n             (dbg_resetn_s),

    .dftcgen             (dftcgen),

    .hc_qreqn_i          (1'b1),
    .hc_qacceptn_o       (),
    .hc_qdeny_o          (),
    .hc_qactive_o        (),

    .pwr_qreqn_i         (1'b1),
    .pwr_qacceptn_o      (),
    .pwr_qdeny_o         (),
    .pwr_qactive_o       (),

    .clk_qreqn_o         (dclk_qreqn),
    .clk_qacceptn_i      (dclk_qacceptn),
    .clk_qactive_i       (dclk_qactive),
    .clk_qdeny_i         (dclk_qdeny),

    .clk_force_i         (clock_override_extsystop[0]),

    .entry_delay_i       (clock_override_extsystop[8:1]),

    .clken_o             (dclk_en_bridges)
    );    
  

  assign extsys_hclk_en         = extdbgrom_cdbgpwrupack_ss | axiaprom_csyspwrupack_ss | hclk_en_bridges | ~sleeping;
  assign extsys_dclk_en         = extdbgrom_cdbgpwrupack_ss | axiaprom_csyspwrupack_ss | dclk_en_bridges | ~sleeping;
  assign extsys_timer0pclkg_en  = timer0pclk_qactive;
  assign extsys_timer1pclkg_en  = timer1pclk_qactive;
  
  arm_element_or_tree #(
    .NUM_OR_TREE_INPUTS (2)
  ) u_arm_element_or_tree (
    .or_tree_i  ({dftcgen, mbistreq}),
    .or_tree_o  (dftcgen_or_mbistreq)
  );


  arm_element_clock_gate u_arm_element_clock_gate_hclk (
    .clk_in              (extsys_clk),
    .enable              (extsys_hclk_en),
    .clk_out             (extsys_hclk),
    .dftcgen             (dftcgen_or_mbistreq)
  );
  
  arm_element_clock_gate u_arm_element_clock_gate_dclk (
    .clk_in              (extsys_clk),
    .enable              (extsys_dclk_en),
    .clk_out             (extsys_dclk),
    .dftcgen             (dftcgen)
  );  
  
  arm_element_clock_gate u_arm_element_clock_gate_timer0 (
    .clk_in              (extsys_clk),
    .enable              (extsys_timer0pclkg_en),
    .clk_out             (extsys_timer0pclkg),
    .dftcgen             (dftcgen)
  );
  
  arm_element_clock_gate u_arm_element_clock_gate_timer1 (
    .clk_in              (extsys_clk),
    .enable              (extsys_timer1pclkg_en),
    .clk_out             (extsys_timer1pclkg),
    .dftcgen             (dftcgen)
    );  
  
  
  arm_element_reset_sync u_arm_element_reset_sync_extsys_core_rst (
    .clk                (extsys_clk),
    .resetn_async       (core_resetn),
    .resetn_sync        (core_resetn_s),
    .dftrstdisable      (dftrstdisable[1])
  );  
  
  arm_element_reset_sync u_arm_element_reset_sync_extsys_mtx_rst (
    .clk                (extsys_clk),
    .resetn_async       (mtx_resetn),
    .resetn_sync        (mtx_resetn_s),
    .dftrstdisable      (dftrstdisable[0])
  );

    arm_element_reset_sync u_arm_element_reset_sync_extsys_dbg_rst (
    .clk                (extsys_clk),
    .resetn_async       (dbg_resetn),
    .resetn_sync        (dbg_resetn_s),
    .dftrstdisable      (dftrstdisable[0])
  );
  
endmodule
