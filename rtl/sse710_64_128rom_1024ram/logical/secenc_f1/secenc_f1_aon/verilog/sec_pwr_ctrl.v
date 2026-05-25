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

                
module sec_pwr_ctrl #(
  parameter         DEV_PREQ_DLY_SECENC       = 0, 
  parameter         PCSM_PREQ_DLY_SECENC      = 0, 
  parameter         ISO_CLKEN_DLY_CFG_SECENC  = 0, 
  parameter         CLKEN_RST_DLY_CFG_SECENC  = 0, 
  parameter         RST_HWSTAT_DLY_CFG_SECENC = 0, 
  parameter         CLKEN_ISO_DLY_CFG_SECENC  = 0, 
  parameter         ISO_RST_DLY_CFG_SECENC    = 0  
)(
  input  wire         clk,
  input  wire         rst_n,

  input  wire         ppu_psel,
  input  wire         ppu_penable,
  input  wire  [31:0] ppu_paddr,
  input  wire         ppu_pwrite,
  input  wire  [31:0] ppu_pwdata,
  output wire  [31:0] ppu_prdata,
  output wire         ppu_pready,
  output wire         ppu_pslverr,

  output wire         ppu_irq,

  output wire         ppu_clken,
  output wire         devwarmresetn,
  output wire         devporesetn,

  output wire         pcsm_preq,
  output wire   [3:0] pcsm_pstate,
  input  wire         pcsm_paccept,

  output wire   [3:0] dev0_qreqn,
  input  wire   [3:0] dev0_qacceptn,
  input  wire   [3:0] dev0_qdeny,
  input  wire   [3:0] dev0_qactive,  
  
  output wire         dev1_qreqn,
  input  wire         dev1_qacceptn,
  input  wire         dev1_qdeny,
  input  wire         dev1_qactive,
  
  output wire   [3:0] dev2_qreqn,
  input  wire   [3:0] dev2_qacceptn,
  input  wire   [3:0] dev2_qdeny,
  input  wire   [3:0] dev2_qactive,
  output wire         dev2_es00_qreqn,
  input  wire         dev2_es00_qacceptn,
  input  wire         dev2_es00_qdeny,
  input  wire         dev2_es00_qactive,
    output wire         dev2_es01_qreqn,
  input  wire         dev2_es01_qacceptn,
  input  wire         dev2_es01_qdeny,
  input  wire         dev2_es01_qactive,
    output wire         dev2_es10_qreqn,
  input  wire         dev2_es10_qacceptn,
  input  wire         dev2_es10_qdeny,
  input  wire         dev2_es10_qactive,
    output wire         dev2_es11_qreqn,
  input  wire         dev2_es11_qacceptn,
  input  wire         dev2_es11_qdeny,
  input  wire         dev2_es11_qactive,
    
  input  wire         ctrl0_qreqn,
  output wire         ctrl0_qacceptn,
  output wire         ctrl0_qdeny,
  output wire         ctrl0_qactive,
  
  input  wire         ctrl1_qreqn,
  output wire         ctrl1_qacceptn,
  output wire         ctrl1_qdeny,
  output wire         ctrl1_qactive,  

  input  wire         pwr_gate_en,
  input  wire         mhu0_recwakeup,
  input  wire         mhu1_recwakeup,
  input  wire         mhu2_recwakeup,
    input  wire         mhu3_recwakeup,
    input  wire         mhu4_recwakeup,
    input  wire         mhu5_recwakeup,
    input  wire         irq_wakeup,
  input  wire         cdbg_pwrup_req0,
  output wire         cdbg_pwrup_ack0,

  input  wire         dftrstdisable,
  input  wire         dftisodisable,
  input  wire         dftcgen
);
  
  
  wire        ppu_preq;
  wire  [3:0] ppu_pstate;
  wire [10:0] ppu_pactive;  
  wire [31:0] p2q_pactive;  
  wire        ppu_paccept;
  wire        ppu_pdeny;
  
  wire  [3:0] ppu_ecorevnum;
  wire [15:0] ppu_hwstat;
  
  wire        lpdqs_qreqn;
  wire        lpdqs_qacceptn;
  wire        lpdqs_qdeny;
  wire        lpdqs_qactive;  
  
  wire        lpdq0_qreqn;
  wire        lpdq0_qacceptn;
  wire        lpdq0_qdeny;
  wire        lpdq0_qactive; 

  wire        lpcq0_qreqn;
  wire        lpcq0_qacceptn;
  wire        lpcq0_qdeny;
  wire        lpcq0_qactive;  
  
  wire        lpdq2s_qreqn;
  wire        lpdq2s_qacceptn;
  wire        lpdq2s_qdeny;
  wire        lpdq2s_qactive;
  
  wire        lpdq2_qreqn;
  wire        lpdq2_qacceptn;
  wire        lpdq2_qdeny;
  wire        lpdq2_qactive;
  
  wire        lpcq2_qreqn;
  wire        lpcq2_qacceptn;
  wire        lpcq2_qdeny;
  wire        lpcq2_qactive;
  
  wire        reqack_qreqn;
  wire        reqack_qacceptn;
  wire        reqack_qdeny;
  wire        reqack_qactive;  
  
  wire [3:0] lpd_q_2_qreqn;
  wire [3:0] lpd_q_2_qacceptn;
  wire [3:0] lpd_q_2_qdeny;
  wire [3:0] lpd_q_2_qactive;

  wire        unused;
  
  
  sec_pactive u_sec_pactive (
    .p2q_pactive            (p2q_pactive[10:0]),
    .ppu_hwstat             (ppu_hwstat),
    .pwr_gate_en            (pwr_gate_en),
    .mhu0_recwakeup         (mhu0_recwakeup),
    .mhu1_recwakeup         (mhu1_recwakeup),
    .mhu2_recwakeup         (mhu2_recwakeup),
      .mhu3_recwakeup         (mhu3_recwakeup),
    
    .mhu4_recwakeup         (mhu4_recwakeup),
      .mhu5_recwakeup         (mhu5_recwakeup),
    
  
    .irq_wakeup             (irq_wakeup),
    .ppu_pactive            (ppu_pactive)
  );
  
  
  pck600_ppu_sse710_secenc #(
    .DEV_PREQ_DLY           (DEV_PREQ_DLY_SECENC),
    .PCSM_PREQ_DLY          (PCSM_PREQ_DLY_SECENC),
    .ISO_CLKEN_DLY_CFG      (ISO_CLKEN_DLY_CFG_SECENC),
    .CLKEN_RST_DLY_CFG      (CLKEN_RST_DLY_CFG_SECENC),
    .RST_HWSTAT_DLY_CFG     (RST_HWSTAT_DLY_CFG_SECENC),
    .CLKEN_ISO_DLY_CFG      (CLKEN_ISO_DLY_CFG_SECENC),
    .ISO_RST_DLY_CFG        (ISO_RST_DLY_CFG_SECENC)
  ) u_pck600_ppu_sse710_secenc (
    .clk                    (clk),
    .reset_n                (rst_n),
    .dftcgen                (dftcgen),
    .dftisodisable          (dftisodisable),
    .dftrstdisable          (dftrstdisable),
    .psel_i                 (ppu_psel),
    .penable_i              (ppu_penable),
    .paddr_i                (ppu_paddr),
    .pwrite_i               (ppu_pwrite),
    .pwdata_i               (ppu_pwdata),
    .prdata_o               (ppu_prdata),
    .pready_o               (ppu_pready),
    .pslverr_o              (ppu_pslverr),
    .pwakeup_i              (1'b1), 
    .irq_o                  (ppu_irq),
    .dev_preq_o             (ppu_preq),
    .dev_pstate_o           (ppu_pstate),
    .dev_paccept_i          (ppu_paccept),
    .dev_pdeny_i            (ppu_pdeny),
    .dev_pactive_i          (ppu_pactive),
    .ppuhwstat_o            (ppu_hwstat),
    .devclken_o             (ppu_clken),
    .devemuclken_o          (),
    .devisolaten_o          (),
    .devemuisolaten_o       (),
    .devwarmresetn_o        (devwarmresetn),
    .devretresetn_o         (),
    .devporesetn_o          (devporesetn),
    .pcsm_preq_o            (pcsm_preq),
    .pcsm_pstate_o          (pcsm_pstate),
    .pcsm_paccept_i         (pcsm_paccept),
    .ppuclk_qreqn_i         (1'b1),
    .ppuclk_qacceptn_o      (),
    .ppuclk_qdeny_o         (),
    .ppuclk_qactive_o       (),
    .ecorevnum_i            (ppu_ecorevnum)
  );

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_0 (
    .ecorevnum (ppu_ecorevnum)
  );
  
 
  pck600_p2q #(
    .CTRL_P_CH_SYNC           (0),                                          
    .DEV_Q_CH_SYNC            (0),                                          
    .CTRL_P_CH_PWR_PSTATE_MAP (16'b0000_0001_0000_0000),                    
    .CTRL_P_CH_OP_PSTATE_MAP  (16'b1111_1111_1111_1111),                    
    .CTRL_P_CH_PACTIVE        (32'b0000_0000_0000_0000_0000_0001_0000_0000) 
  ) u_pck600_p2q (
    .clk                      (clk),
    .reset_n                  (rst_n),
    .ctrl_pstate_i            ({4'b0, ppu_pstate}),
    .ctrl_preq_i              (ppu_preq),
    .ctrl_paccept_o           (ppu_paccept),
    .ctrl_pdeny_o             (ppu_pdeny),
    .ctrl_pactive_o           (p2q_pactive),
    .dev_qreqn_o              (lpdqs_qreqn),
    .dev_qacceptn_i           (lpdqs_qacceptn),
    .dev_qdeny_i              (lpdqs_qdeny),
    .dev_qactive_i            (lpdqs_qactive),
    .clk_qactive_o            (),
    .dftcgen                  (dftcgen)
  );

  
  pck600_lpd_q #(
    .SEQUENCER            (1), 
    .NUM_QCHL             (3), 
    .CTRL_Q_CH_SYNC       (0), 
    .DEV_Q_CH_SYNC        (1), 
    .ACTIVE_DENY          (0)  
  ) u_pck600_lpd_q_s (
    .clk                  (clk),
    .reset_n              (rst_n),
    .ctrl_qreqn_i         (lpdqs_qreqn),
    .ctrl_qacceptn_o      (lpdqs_qacceptn),
    .ctrl_qdeny_o         (lpdqs_qdeny),
    .ctrl_qactive_o       (lpdqs_qactive),
    .dev_qreqn_o          ({lpdq2s_qreqn   , dev1_qreqn   , lpdq0_qreqn   }),
    .dev_qacceptn_i       ({lpdq2s_qacceptn, dev1_qacceptn, lpdq0_qacceptn}),
    .dev_qdeny_i          ({lpdq2s_qdeny   , dev1_qdeny   , lpdq0_qdeny   }),
    .dev_qactive_i        ({lpdq2s_qactive , dev1_qactive , lpdq0_qactive }),
    .clk_qactive_o        (),
    .dftcgen              (dftcgen)
  ); 
  
  pck600_lpd_q #(
    .SEQUENCER            (0), 
    .NUM_QCHL             (4), 
    .CTRL_Q_CH_SYNC       (0), 
    .DEV_Q_CH_SYNC        (1), 
    .ACTIVE_DENY          (0)  
  ) u_pck600_lpd_q_0 (
    .clk                  (clk),
    .reset_n              (rst_n),
    .ctrl_qreqn_i         (lpdq0_qreqn),
    .ctrl_qacceptn_o      (lpdq0_qacceptn),
    .ctrl_qdeny_o         (lpdq0_qdeny),
    .ctrl_qactive_o       (lpdq0_qactive),
    .dev_qreqn_o          ({dev0_qreqn[3:1]   , lpcq0_qreqn   }),
    .dev_qacceptn_i       ({dev0_qacceptn[3:1], lpcq0_qacceptn}),
    .dev_qdeny_i          ({dev0_qdeny[3:1]   , lpcq0_qdeny   }),
    .dev_qactive_i        ({dev0_qactive[3:1] , lpcq0_qactive }),
    .clk_qactive_o        (),
    .dftcgen              (dftcgen)
  ); 
  
  pck600_lpd_q #(
    .SEQUENCER            (1), 
    .NUM_QCHL             (2), 
    .CTRL_Q_CH_SYNC       (0), 
    .DEV_Q_CH_SYNC        (0), 
    .ACTIVE_DENY          (0)  
  ) u_pck600_lpd_q_2s (
    .clk                  (clk),
    .reset_n              (rst_n),
    .ctrl_qreqn_i         (lpdq2s_qreqn),
    .ctrl_qacceptn_o      (lpdq2s_qacceptn),
    .ctrl_qdeny_o         (lpdq2s_qdeny),
    .ctrl_qactive_o       (lpdq2s_qactive),
    .dev_qreqn_o          ({reqack_qreqn    ,lpdq2_qreqn   }),
    .dev_qacceptn_i       ({reqack_qacceptn ,lpdq2_qacceptn}),
    .dev_qdeny_i          ({reqack_qdeny    ,lpdq2_qdeny   }),
    .dev_qactive_i        ({reqack_qactive  ,lpdq2_qactive }),
    .clk_qactive_o        (),
    .dftcgen              (dftcgen)
  ); 
  
          
  pck600_lpd_q #(
    .SEQUENCER            (0),  
    .NUM_QCHL             (7), 
    .CTRL_Q_CH_SYNC       (0),  
    .DEV_Q_CH_SYNC        (1),  // DEV0-5 are asynchronous
    .ACTIVE_DENY          (0)   
  ) u_pck600_lpd_q_2 (
    .clk                  (clk),
    .reset_n              (rst_n),
    .ctrl_qreqn_i         (lpdq2_qreqn),
    .ctrl_qacceptn_o      (lpdq2_qacceptn),
    .ctrl_qdeny_o         (lpdq2_qdeny),
    .ctrl_qactive_o       (lpdq2_qactive),
    .dev_qreqn_o          ({lpcq2_qreqn   , lpd_q_2_qreqn   , dev2_qreqn[2:1]   }),
    .dev_qacceptn_i       ({lpcq2_qacceptn, lpd_q_2_qacceptn, dev2_qacceptn[2:1]}),
    .dev_qdeny_i          ({lpcq2_qdeny   , lpd_q_2_qdeny   , dev2_qdeny[2:1]   }),
    .dev_qactive_i        ({lpcq2_qactive , lpd_q_2_qactive , dev2_qactive[2:1] }),
    .clk_qactive_o        (),
    .dftcgen              (dftcgen)
  ); 
  
        assign dev2_es00_qreqn     = lpd_q_2_qreqn[0];
    assign lpd_q_2_qacceptn[0] = dev2_es00_qacceptn;
    assign lpd_q_2_qdeny[0]    = dev2_es00_qdeny;
    assign lpd_q_2_qactive[0]  = dev2_es00_qactive;
              assign dev2_es01_qreqn     = lpd_q_2_qreqn[1];
      assign lpd_q_2_qacceptn[1] = dev2_es01_qacceptn;
      assign lpd_q_2_qdeny[1]    = dev2_es01_qdeny;
      assign lpd_q_2_qactive[1]  = dev2_es01_qactive;
                assign dev2_es10_qreqn     = lpd_q_2_qreqn[2];
    assign lpd_q_2_qacceptn[2] = dev2_es10_qacceptn;
    assign lpd_q_2_qdeny[2]    = dev2_es10_qdeny;
    assign lpd_q_2_qactive[2]  = dev2_es10_qactive;
              assign dev2_es11_qreqn     = lpd_q_2_qreqn[3];
      assign lpd_q_2_qacceptn[3] = dev2_es11_qacceptn;
      assign lpd_q_2_qdeny[3]    = dev2_es11_qdeny;
      assign lpd_q_2_qactive[3]  = dev2_es11_qactive;
              
     
      
  
  pck600_lpc_q #(
    .NUM_CTRL_Q_CHL       (2), 
    .NUM_DEV_Q_CHL        (1), 
    .CTRL_Q_CH_SYNC       (1), 
    .DEV_Q_CH_SYNC        (1)  
  ) u_pck600_lpc_q_0 (
    .clk                  (clk),
    .reset_n              (rst_n),
    .dftcgen              (dftcgen),
    .ctrl_qreqn_i         ({ctrl0_qreqn    ,lpcq0_qreqn   }),
    .ctrl_qacceptn_o      ({ctrl0_qacceptn ,lpcq0_qacceptn}),
    .ctrl_qdeny_o         ({ctrl0_qdeny    ,lpcq0_qdeny   }),
    .ctrl_qactive_o       ({ctrl0_qactive  ,lpcq0_qactive }),
    .dev_qreqn_o          (dev0_qreqn[0]),
    .dev_qacceptn_i       (dev0_qacceptn[0]),
    .dev_qdeny_i          (dev0_qdeny[0]),
    .dev_qactive_i        (dev0_qactive[0]),
    .clk_qactive_o        ()
  );
    
  pck600_lpc_q #(
    .NUM_CTRL_Q_CHL       (2), 
    .NUM_DEV_Q_CHL        (2), 
    .CTRL_Q_CH_SYNC       (1), 
    .DEV_Q_CH_SYNC        (1)  
  ) u_pck600_lpc_q_2 (
    .clk                  (clk),
    .reset_n              (rst_n),
    .dftcgen              (dftcgen),
    .ctrl_qreqn_i         ({ctrl1_qreqn     , lpcq2_qreqn   }),
    .ctrl_qacceptn_o      ({ctrl1_qacceptn  , lpcq2_qacceptn}),
    .ctrl_qdeny_o         ({ctrl1_qdeny     , lpcq2_qdeny   }),
    .ctrl_qactive_o       ({ctrl1_qactive   , lpcq2_qactive }),
    .dev_qreqn_o          ({dev2_qreqn[0]   , dev2_qreqn[3]   }),
    .dev_qacceptn_i       ({dev2_qacceptn[0], dev2_qacceptn[3]}),
    .dev_qdeny_i          ({dev2_qdeny[0]   , dev2_qdeny[3]   }),
    .dev_qactive_i        ({dev2_qactive[0] , dev2_qactive[3] }),
    .clk_qactive_o        ()
  );  
  
  
  p_reqack_to_qchan_f0_top u_p_reqack_to_qchan_f0_top (
    .CLK          (clk),
    .RESETn       (rst_n),
    .PWRUPREQ     (cdbg_pwrup_req0),
    .PWRUPACK     (cdbg_pwrup_ack0),
    .PWRQREQn     (reqack_qreqn),
    .PWRQACCEPTn  (reqack_qacceptn),
    .PWRQDENY     (reqack_qdeny),
    .PWRQACTIVE   (reqack_qactive),
    .CLKQACTIVE   ()
  );
  
  
  assign unused = |p2q_pactive[31:11];
  
endmodule
