// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_ppu_sse710_clus
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //DFT
  input wire                  dftcgen,
  input wire                  dftisodisable,
  input wire                  dftrstdisable,

  //APB Slave port
  input wire                  psel_i,
  input wire                  penable_i,
  input wire [31:0]           paddr_i,
  input wire                  pwrite_i,
  input wire [31:0]           pwdata_i,
  output wire [31:0]          prdata_o,
  output wire                 pready_o,
  output wire                 pslverr_o,
  input wire                  pwakeup_i,

  //Interrupt
  output wire                 irq_o,

  //Device P-Channel
  output wire                 dev_preq_o,
  output wire [3:0]           dev_pstate_o,
  input wire                  dev_paccept_i,
  input wire                  dev_pdeny_i,
  input wire [10:0]           dev_pactive_i,

  //Device Control Signals
  output wire [15:0]          ppuhwstat_o,
  output wire                 devclken_o,
  output wire                 devemuclken_o,
  output wire                 devisolaten_o,
  output wire                 devemuisolaten_o,
  output wire                 devwarmresetn_o,
  output wire                 devretresetn_o,
  output wire                 devporesetn_o,

  //PCSM Interface
  output wire                 pcsm_preq_o,
  output wire [3:0]           pcsm_pstate_o,
  input wire                  pcsm_paccept_i,
  input wire [3:0]            pcsm_mode_stat_i,

  //PPUCLK Q-Channel
  input wire                  ppuclk_qreqn_i,
  output wire                 ppuclk_qacceptn_o,
  output wire                 ppuclk_qdeny_o,
  output wire                 ppuclk_qactive_o,

  //Static tie off
  input wire [3:0]            ecorevnum_i

);

  `include "pck600_ppu_config_sse710_clus.v"


  genvar                      I;

  wire                        cg_enable;

  wire                        clk_enable;

  wire                        clk_gated;

  wire                        devisolaten;
  wire                        devemuisolaten;

  wire                        devwarmresetn;
  wire                        devretresetn;
  wire                        devporesetn;

  wire                        dev_paccept_ss;
  wire                        dev_pdeny_ss;
  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_ss;
  wire                        pcsm_paccept_ss;
  wire                        ppuclk_qreqn_ss;

  wire                        sample_pcsm_mode_stat;
  wire                        pcsm_mode_stat_pwr_ss;

  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_st;

  wire                        reg_clk_req;
  wire                        edge_clk_req;

  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactiveen;
  wire [NUM_DEV_LPI-1:0]      devreqen;


  wire                        warm_rst_devreqen;
  wire [CRI_COUNTER_WIDTH-1:0] clken_rst_dly;
  wire [CRI_COUNTER_WIDTH-1:0] iso_clken_dly;
  wire [CRI_COUNTER_WIDTH-1:0] rst_hwstat_dly;
  wire [CRI_COUNTER_WIDTH-1:0] iso_rst_dly;
  wire [CRI_COUNTER_WIDTH-1:0] clken_iso_dly;
  wire [3:0]                  pwr_st;
  wire                        pwr_dyn_st;

  wire [3:0]                  pwr_policy;
  wire                        pwr_dyn_en;

  wire                        flush_req;
  wire                        apb_stall;
  wire                        pwpr_init;
  wire [3:0]                  pwr_policy_init;

  wire                        pwpr_legal_write_en;
  wire                        pwpr_nxt_pwr_dyn_en;

  wire [1:0]                  diu_req;
  wire [3:0]                  diu_pwr_mode;
  wire                        diu_stall;
  wire                        diu_comp;
  wire                        diu_accept;
  wire                        diu_req_high;

  wire                        piu_req;
  wire [3:0]                  piu_pwr_mode;
  wire                        piu_comp;

  wire                        mtu_clk_req;

  wire                        trans_start_req;
  wire [TRANS_PATH_WIDTH-1:0] trans_path;
  wire [3:0]                  trans_target_pwr_mode;
  wire                        trans_comp;
  wire                        trans_comp_accept;
  wire                        trans_comp_deny;
  wire                        trans_init;
  wire                        pwr_policy_revert;
  wire                        psm_idle;




  pck600_ppu_reg_sse710_clus
  #(
    .DEF_PWR_POLICY         (DEF_PWR_POLICY),
    .DEF_PWR_DYN_EN         (DEF_PWR_DYN_EN),
    .NUM_PWR_DEVACTIVE      (NUM_PWR_DEVACTIVE),
    .DEVACTIVE_LSB          (DEVACTIVE_LSB),
    .NUM_DEV_LPI            (NUM_DEV_LPI),
    .WARM_RST_DEVREQEN_CFG  (WARM_RST_DEVREQEN_CFG),
    .CLKEN_RST_DLY_CFG      (CLKEN_RST_DLY_CFG),
    .ISO_CLKEN_DLY_CFG      (ISO_CLKEN_DLY_CFG),
    .RST_HWSTAT_DLY_CFG     (RST_HWSTAT_DLY_CFG),
    .CLKEN_ISO_DLY_CFG      (CLKEN_ISO_DLY_CFG),
    .ISO_RST_DLY_CFG        (ISO_RST_DLY_CFG),
    .DYN_WRM_RST_SPT_CFG    (DYN_WRM_RST_SPT_CFG),
    .DYN_ON_SPT_CFG         (DYN_ON_SPT_CFG),
    .DYN_FUNC_RET_SPT_CFG   (DYN_FUNC_RET_SPT_CFG),
    .DYN_FULL_RET_SPT_CFG   (DYN_FULL_RET_SPT_CFG),
    .DYN_MEM_OFF_SPT_CFG    (DYN_MEM_OFF_SPT_CFG),
    .DYN_LGC_RET_SPT_CFG    (DYN_LGC_RET_SPT_CFG),
    .DYN_MEM_RET_EMU_SPT_CFG(DYN_MEM_RET_EMU_SPT_CFG),
    .DYN_MEM_RET_SPT_CFG    (DYN_MEM_RET_SPT_CFG),
    .DYN_OFF_EMU_SPT_CFG    (DYN_OFF_EMU_SPT_CFG),
    .DYN_OFF_SPT_CFG        (DYN_OFF_SPT_CFG),
    .STA_DBG_RECOV_SPT_CFG  (STA_DBG_RECOV_SPT_CFG),
    .STA_FUNC_RET_SPT_CFG   (STA_FUNC_RET_SPT_CFG),
    .STA_FULL_RET_SPT_CFG   (STA_FULL_RET_SPT_CFG),
    .STA_MEM_OFF_SPT_CFG    (STA_MEM_OFF_SPT_CFG),
    .STA_LGC_RET_SPT_CFG    (STA_LGC_RET_SPT_CFG),
    .STA_MEM_RET_EMU_SPT_CFG(STA_MEM_RET_EMU_SPT_CFG),
    .STA_MEM_RET_SPT_CFG    (STA_MEM_RET_SPT_CFG),
    .STA_OFF_EMU_SPT_CFG    (STA_OFF_EMU_SPT_CFG),
    .NUM_OPMODE_CFG         (NUM_OPMODE_CFG),
    .DEVCHAN_CFG            (DEVCHAN_CFG),
    .OP_ACTIVE_CFG          (OP_ACTIVE_CFG),
    .STA_POLICY_OP_IRQ_CFG  (STA_POLICY_OP_IRQ_CFG),
    .STA_POLICY_PWR_IRQ_CFG (STA_POLICY_PWR_IRQ_CFG),
    .FUNC_RET_RAM_REG_CFG   (FUNC_RET_RAM_REG_CFG),
    .FULL_RET_RAM_REG_CFG   (FULL_RET_RAM_REG_CFG),
    .MEM_RET_RAM_REG_CFG    (MEM_RET_RAM_REG_CFG),
    .LOCK_CFG               (LOCK_CFG),
    .SW_DEV_DEL_CFG         (SW_DEV_DEL_CFG),
    .PWR_MODE_ENTRY_DEL_CFG (PWR_MODE_ENTRY_DEL_CFG),
    .OFF_MEM_RET_TRANS_CFG  (OFF_MEM_RET_TRANS_CFG),
    .CRI_COUNTER_WIDTH      (CRI_COUNTER_WIDTH)
  )
  u_pck600_ppu_reg
  (
    //Clock and Reset
    .clk                    (clk_gated),
    .reset_n                (reset_n),
    //APB Slave port
    .psel_i                 (psel_i),
    .penable_i              (penable_i),
    .paddr_i                (paddr_i),
    .pwrite_i               (pwrite_i),
    .pwdata_i               (pwdata_i),
    .prdata_o               (prdata_o),
    .pready_o               (pready_o),
    .pslverr_o              (pslverr_o),
    //Interrupt
    .irq_o                  (irq_o),
    //Registers
    //PPU_PWPR
    .pwr_policy_o           (pwr_policy),
    .pwr_dyn_en_o           (pwr_dyn_en),
    //PPU_PWSR
    .pwr_st_i               (pwr_st),
    .pwr_dyn_st_i           (pwr_dyn_st),
    //PPU_DISR
    .pwr_devactive_i        (pwr_devactive_ss),
    //PPU_MISR
    .pcsm_paccept_i         (pcsm_paccept_ss),
    .devaccept_i            (dev_paccept_ss),
    .devdeny_i              (dev_pdeny_ss),
    //PPU_STSR
    //PPU_PWCR
    .devreqen_o             (devreqen),
    .pwr_devactiveen_o      (pwr_devactiveen),
    //PPU_PTCR
    .warm_rst_devreqen_o    (warm_rst_devreqen),
    //PPU_DCDR0
    .clken_rst_dly_o        (clken_rst_dly),
    .iso_clken_dly_o        (iso_clken_dly),
    .rst_hwstat_dly_o       (rst_hwstat_dly),
    //PPU_DCDR1
    .iso_rst_dly_o          (iso_rst_dly),
    .clken_iso_dly_o        (clken_iso_dly),
    //PPU_PWPR update
    .pwpr_legal_write_en_o  (pwpr_legal_write_en),
    .pwpr_nxt_pwr_dyn_en_o  (pwpr_nxt_pwr_dyn_en),
    //Flush request and PWPR initialization
    .flush_req_o            (flush_req),
    .apb_stall_i            (apb_stall),
    .pwpr_init_i            (pwpr_init),
    .pwr_policy_init_i      (pwr_policy_init),
    //Transition Control
    .trans_target_pwr_mode_i(trans_target_pwr_mode),
    .trans_comp_i           (trans_comp),
    .trans_comp_accept_i    (trans_comp_accept),
    .trans_comp_deny_i      (trans_comp_deny),
    .trans_init_i           (trans_init),
    .pwr_policy_revert_i    (pwr_policy_revert),
    .psm_idle_i             (psm_idle),
    //Clock Control
    .reg_clk_req_o          (reg_clk_req),
    .edge_clk_req_o         (edge_clk_req),
    .clk_enable_i           (clk_enable),
    .pwr_devactive_st_o     (pwr_devactive_st),
    //Static tie off
    .ecorevnum_i            (ecorevnum_i)
  );


  pck600_ppu_diu_sse710_clus
  #(
    .DEV_PREQ_DLY   (DEV_PREQ_DLY),
    .DEVPSTATE_WIDTH(DEVPSTATE_WIDTH),
    .NUM_DEV_LPI    (NUM_DEV_LPI)
  )
  u_pck600_ppu_diu
  (
    //Clock and Reset
    .clk                 (clk_gated),
    .reset_n             (reset_n),
    //Device Interface
    .dev_preq_o          (dev_preq_o),
    .dev_pstate_o        (dev_pstate_o),
    .dev_paccept_i       (dev_paccept_ss),
    .dev_pdeny_i         (dev_pdeny_ss),
    //PSM Interface
    .diu_req_i           (diu_req),
    .diu_pwr_mode_i      (diu_pwr_mode),
    .diu_stall_i         (diu_stall),
    .diu_accept_o        (diu_accept),
    .diu_comp_o          (diu_comp),
    .diu_req_high_o      (diu_req_high),
    //REG Interface
    .devreqen_i          (devreqen)
  );


  pck600_ppu_piu_sse710_clus
  #(
    .PCSM_PREQ_DLY   (PCSM_PREQ_DLY),
    .DEF_PWR_POLICY  (DEF_PWR_POLICY),
    .PCSMPSTATE_WIDTH(PCSMPSTATE_WIDTH)
  )
  u_pck600_ppu_piu
  (
    //Clock and Reset
    .clk               (clk_gated),
    .reset_n           (reset_n),
    //PCSM P-Channel
    .pcsm_preq_o       (pcsm_preq_o),
    .pcsm_pstate_o     (pcsm_pstate_o),
    .pcsm_paccept_i    (pcsm_paccept_ss),
    //PSM Interface
    .piu_req_i         (piu_req),
    .piu_pwr_mode_i    (piu_pwr_mode),
    .piu_comp_o        (piu_comp)
  );


  pck600_ppu_mtu_sse710_clus
  #(
    .DEF_PWR_POLICY         (DEF_PWR_POLICY),
    .NUM_PWR_DEVACTIVE      (NUM_PWR_DEVACTIVE),
    .DEVACTIVE_LSB          (DEVACTIVE_LSB),
    .DYN_WRM_RST_SPT_CFG    (DYN_WRM_RST_SPT_CFG),
    .DYN_ON_SPT_CFG         (DYN_ON_SPT_CFG),
    .DYN_FUNC_RET_SPT_CFG   (DYN_FUNC_RET_SPT_CFG),
    .DYN_FULL_RET_SPT_CFG   (DYN_FULL_RET_SPT_CFG),
    .DYN_MEM_OFF_SPT_CFG    (DYN_MEM_OFF_SPT_CFG),
    .DYN_LGC_RET_SPT_CFG    (DYN_LGC_RET_SPT_CFG),
    .DYN_MEM_RET_EMU_SPT_CFG(DYN_MEM_RET_EMU_SPT_CFG),
    .DYN_MEM_RET_SPT_CFG    (DYN_MEM_RET_SPT_CFG),
    .DYN_OFF_EMU_SPT_CFG    (DYN_OFF_EMU_SPT_CFG),
    .DYN_OFF_SPT_CFG        (DYN_OFF_SPT_CFG),
    .STA_DBG_RECOV_SPT_CFG  (STA_DBG_RECOV_SPT_CFG),
    .STA_FUNC_RET_SPT_CFG   (STA_FUNC_RET_SPT_CFG),
    .STA_FULL_RET_SPT_CFG   (STA_FULL_RET_SPT_CFG),
    .STA_MEM_OFF_SPT_CFG    (STA_MEM_OFF_SPT_CFG),
    .STA_LGC_RET_SPT_CFG    (STA_LGC_RET_SPT_CFG),
    .STA_MEM_RET_EMU_SPT_CFG(STA_MEM_RET_EMU_SPT_CFG),
    .STA_MEM_RET_SPT_CFG    (STA_MEM_RET_SPT_CFG),
    .STA_OFF_EMU_SPT_CFG    (STA_OFF_EMU_SPT_CFG),
    .TRANS_PATH_WIDTH       (TRANS_PATH_WIDTH)
  )
  u_pck600_ppu_mtu
  (
    //Clock and Reset
    .clk                    (clk_gated),
    .reset_n                (reset_n),
    //Toplevel Signals
    .pwr_devactive_i        (pwr_devactive_ss),
    //Register Interface
    .pwr_policy_i           (pwr_policy),
    .pwr_devactiveen_i      (pwr_devactiveen),
    .warm_rst_devreqen_i    (warm_rst_devreqen),
    .flush_req_i            (flush_req),
    //Transition Control
    .trans_start_req_o      (trans_start_req),
    .trans_path_o           (trans_path),
    .trans_target_pwr_mode_o(trans_target_pwr_mode),
    .trans_init_o           (trans_init),
    .trans_comp_i           (trans_comp),
    //PSM Interface
    .pwr_st_i               (pwr_st),
    .pwr_dyn_st_i           (pwr_dyn_st),
    //Initialization for PPU
    .pcsm_mode_stat_pwr_i   (pcsm_mode_stat_pwr_ss),
    .sample_pcsm_mode_stat_o(sample_pcsm_mode_stat),
    .apb_stall_o            (apb_stall),
    .pwpr_init_o            (pwpr_init),
    .pwr_policy_init_o      (pwr_policy_init),
    //Clock Control
    .mtu_clk_req_o          (mtu_clk_req),
    .clk_enable_i           (clk_enable)
  );


  pck600_ppu_psm_sse710_clus
  #(
    .DEF_PWR_DYN_ST    (DEF_PWR_DYN_ST),
    .TRANS_PATH_WIDTH  (TRANS_PATH_WIDTH),
    .PPUHWSTAT_WIDTH   (PPUHWSTAT_WIDTH),
    .CRI_COUNTER_EN    (CRI_COUNTER_EN),
    .CRI_COUNTER_WIDTH (CRI_COUNTER_WIDTH)
  )
  u_pck600_ppu_psm
  (
    //Clock and Reset
    .clk                    (clk_gated),
    .reset_n                (reset_n),
    //DIU Interface
    .diu_req_o              (diu_req),
    .diu_pwr_mode_o         (diu_pwr_mode),
    .diu_stall_o            (diu_stall),
    .diu_accept_i           (diu_accept),
    .diu_comp_i             (diu_comp),
    .diu_req_high_i         (diu_req_high),
    //PIU Interface
    .piu_req_o              (piu_req),
    .piu_pwr_mode_o         (piu_pwr_mode),
    .piu_comp_i             (piu_comp),
    //Transition Control
    .trans_start_req_i      (trans_start_req),
    .trans_path_i           (trans_path),
    .trans_target_pwr_mode_i(trans_target_pwr_mode),
    .trans_comp_o           (trans_comp),
    .trans_comp_accept_o    (trans_comp_accept),
    .trans_comp_deny_o      (trans_comp_deny),
    .pwr_policy_revert_o    (pwr_policy_revert),
    .psm_idle_o             (psm_idle),
    //PPU_PWPR update
    .pwpr_legal_write_en_i  (pwpr_legal_write_en),
    .pwpr_nxt_pwr_dyn_en_i  (pwpr_nxt_pwr_dyn_en),
    //PWPR Current Values
    .pwr_dyn_en_i           (pwr_dyn_en),
    //PPU_PWSR
    .pwr_st_o               (pwr_st),
    .pwr_dyn_st_o           (pwr_dyn_st),
    //Device Control Signals
    .ppuhwstat_o            (ppuhwstat_o),
    .devclken_o             (devclken_o),
    .devemuclken_o          (devemuclken_o),
    .devisolaten_o          (devisolaten),
    .devemuisolaten_o       (devemuisolaten),
    .devwarmresetn_o        (devwarmresetn),
    .devretresetn_o         (devretresetn),
    .devporesetn_o          (devporesetn),
    //PPU_DCDR0
    .clken_rst_dly_i        (clken_rst_dly),
    .iso_clken_dly_i        (iso_clken_dly),
    .rst_hwstat_dly_i       (rst_hwstat_dly),
    //PPU_DCDR1
    .iso_rst_dly_i          (iso_rst_dly),
    .clken_iso_dly_i        (clken_iso_dly)
  );


  pck600_ppu_ccu_sse710_clus
  #(
    .NUM_PWR_DEVACTIVE(NUM_PWR_DEVACTIVE),
    .DEVACTIVE_LSB    (DEVACTIVE_LSB)
  )
  u_pck600_ppu_ccu
  (
    //Clock and Reset
    .clk                  (clk),
    .reset_n              (reset_n),
    //PPUCLK Q-Channel Interface
    .ppuclk_qreqn_i       (ppuclk_qreqn_ss),
    .ppuclk_qacceptn_o    (ppuclk_qacceptn_o),
    .ppuclk_qdeny_o       (ppuclk_qdeny_o),
    .ppuclk_qactive_o     (ppuclk_qactive_o),
    //Module Clock Requests
    .reg_clk_req_i        (reg_clk_req),
    .edge_clk_req_i       (edge_clk_req),
    .mtu_clk_req_i        (mtu_clk_req),
    //External Clock Request
    .pwr_devactive_async_i(dev_pactive_i[10:1]),
    .pwr_devactive_st_i   (pwr_devactive_st),
    .pwakeup_i            (pwakeup_i),
    //Clock Gate Enable
    .cg_enable_o          (cg_enable),
    //Clock Enable
    .clk_enable_o         (clk_enable)
  );


  pck600_clock_gate
  u_pck600_clock_gate
  (
    .clk_in  (clk),
    .enable  (cg_enable),
    .clk_out (clk_gated),
    .dftcgen (dftcgen)
  );


  pck600_std_or2
  u_pck600_or2_devisolaten
  (
    .A  (devisolaten),
    .B  (dftisodisable),
    .Y  (devisolaten_o)
  );

  pck600_std_or2
  u_pck600_or2_devemuisolaten
  (
    .A  (devemuisolaten),
    .B  (dftisodisable),
    .Y  (devemuisolaten_o)
  );


  pck600_std_or2
  u_pck600_or2_devwarmreset_n
  (
    .A  (devwarmresetn),
    .B  (dftrstdisable),
    .Y  (devwarmresetn_o)
  );

  pck600_std_or2
  u_pck600_or2_devretreset_n
  (
    .A  (devretresetn),
    .B  (dftrstdisable),
    .Y  (devretresetn_o)
  );

  pck600_std_or2
  u_pck600_or2_devporeset_n
  (
    .A  (devporesetn),
    .B  (dftrstdisable),
    .Y  (devporesetn_o)
  );


  pck600_ppu_input_block_sse710_clus
  #(
    .SYNC_EN(DEV_SYNC_EN)
  )
  u_pck600_ppu_input_block_accept
  (
    .clk    (clk_gated),
    .reset_n(reset_n),
    .sig_i  (dev_paccept_i),
    .sig_o  (dev_paccept_ss)
  );

  pck600_ppu_input_block_sse710_clus
  #(
    .SYNC_EN(DEV_SYNC_EN)
  )
  u_pck600_ppu_input_block_deny
  (
    .clk    (clk_gated),
    .reset_n(reset_n),
    .sig_i  (dev_pdeny_i),
    .sig_o  (dev_pdeny_ss)
  );

generate
for(I=DEVACTIVE_LSB; I<NUM_PWR_DEVACTIVE; I=I+1)
begin:pactive_input_block_loop

  pck600_ppu_input_block_sse710_clus
  #(
    .SYNC_EN(DEV_ACTIVE_SYNC_EN)
  )
  u_pck600_ppu_input_block_active
  (
    .clk    (clk),
    .reset_n(reset_n),
    .sig_i  (dev_pactive_i[I]),
    .sig_o  (pwr_devactive_ss[I])
  );

end

endgenerate


  pck600_ppu_input_block_sse710_clus
  #(
    .SYNC_EN(QCLK_SYNC_EN)
  )
  u_pck600_ppu_input_block_ppuclkqreqn
  (
    .clk    (clk),
    .reset_n(reset_n),
    .sig_i  (ppuclk_qreqn_i),
    .sig_o  (ppuclk_qreqn_ss)
  );

  pck600_ppu_input_block_sse710_clus
  #(
    .SYNC_EN(PCSM_SYNC_EN)
  )
  u_pck600_ppu_input_block_pcsmpaccept
  (
    .clk    (clk_gated),
    .reset_n(reset_n),
    .sig_i  (pcsm_paccept_i),
    .sig_o  (pcsm_paccept_ss)
  );

  pck600_cdc_capt_nosync
  #(
    .IH(0),
    .IL(0)
  )
  u_pck600_cdc_capt_nosync_pcsm_mode_stat
  (
    .clk      (clk_gated),
    .reset_n  (reset_n),
    .en       (sample_pcsm_mode_stat),
    .async    (pcsm_mode_stat_i[1]),
    .sync     (pcsm_mode_stat_pwr_ss)
  );

endmodule
