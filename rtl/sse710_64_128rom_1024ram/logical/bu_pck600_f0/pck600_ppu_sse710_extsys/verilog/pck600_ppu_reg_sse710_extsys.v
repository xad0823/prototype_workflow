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


module pck600_ppu_reg_sse710_extsys
#(
  parameter DEF_PWR_POLICY = 4'h0,
  parameter DEF_PWR_DYN_EN = 1'b1,
  parameter NUM_PWR_DEVACTIVE = 11,
  parameter DEVACTIVE_LSB = 1,
  parameter NUM_DEV_LPI = 1,
  parameter WARM_RST_DEVREQEN_CFG = 1'b1,
  parameter CLKEN_RST_DLY_CFG = 8'h00,
  parameter ISO_CLKEN_DLY_CFG = 8'h00,
  parameter RST_HWSTAT_DLY_CFG = 8'h00,
  parameter CLKEN_ISO_DLY_CFG = 8'h00,
  parameter ISO_RST_DLY_CFG = 8'h00,
  parameter DYN_WRM_RST_SPT_CFG = 1'b1,
  parameter DYN_ON_SPT_CFG = 1'b1,
  parameter DYN_FUNC_RET_SPT_CFG = 1'b0,
  parameter DYN_FULL_RET_SPT_CFG = 1'b0,
  parameter DYN_MEM_OFF_SPT_CFG = 1'b0,
  parameter DYN_LGC_RET_SPT_CFG = 1'b0,
  parameter DYN_MEM_RET_EMU_SPT_CFG = 1'b0,
  parameter DYN_MEM_RET_SPT_CFG = 1'b0,
  parameter DYN_OFF_EMU_SPT_CFG = 1'b0,
  parameter DYN_OFF_SPT_CFG = 1'b1,
  parameter STA_DBG_RECOV_SPT_CFG = 1'b0,
  parameter STA_FUNC_RET_SPT_CFG = 1'b0,
  parameter STA_FULL_RET_SPT_CFG = 1'b0,
  parameter STA_MEM_OFF_SPT_CFG = 1'b0,
  parameter STA_LGC_RET_SPT_CFG = 1'b0,
  parameter STA_MEM_RET_EMU_SPT_CFG = 1'b0,
  parameter STA_MEM_RET_SPT_CFG = 1'b0,
  parameter STA_OFF_EMU_SPT_CFG = 1'b0,
  parameter NUM_OPMODE_CFG = 4'h0,
  parameter DEVCHAN_CFG = 4'h0,
  parameter OP_ACTIVE_CFG = 1'b0,
  parameter STA_POLICY_OP_IRQ_CFG = 1'b0,
  parameter STA_POLICY_PWR_IRQ_CFG = 1'b0,
  parameter FUNC_RET_RAM_REG_CFG = 1'b0,
  parameter FULL_RET_RAM_REG_CFG = 1'b0,
  parameter MEM_RET_RAM_REG_CFG = 1'b0,
  parameter LOCK_CFG = 1'b0,
  parameter SW_DEV_DEL_CFG = 1'b0,
  parameter PWR_MODE_ENTRY_DEL_CFG = 1'b1,
  parameter OFF_MEM_RET_TRANS_CFG = 1'b0,
  parameter CRI_COUNTER_WIDTH = 8
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //APB Slave port
  input wire                  psel_i,
  input wire                  penable_i,
  input wire [31:0]           paddr_i,
  input wire                  pwrite_i,
  input wire [31:0]           pwdata_i,
  output wire [31:0]          prdata_o,
  output wire                 pready_o,
  output wire                 pslverr_o,

  //Interrupt
  output wire                 irq_o,

  //Registers
  //PPU_PWPR
  output wire [3:0]           pwr_policy_o,
  output wire                 pwr_dyn_en_o,
  //PPU_PWSR
  input wire [3:0]            pwr_st_i,
  input wire                  pwr_dyn_st_i,
  //PPU_DISR
  input wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactive_i,
  //PPU_MISR
  input wire                  pcsm_paccept_i,
  input wire [NUM_DEV_LPI-1:0] devaccept_i,
  input wire [NUM_DEV_LPI-1:0] devdeny_i,
  //PPU_STSR
  //PPU_PWCR
  output wire [NUM_DEV_LPI-1:0] devreqen_o,
  output wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactiveen_o,
  //PPU_PTCR
  output wire                 warm_rst_devreqen_o,
  //PPU_EDTR0
  output wire [7:0]           off_del_o,
  //PPU_DCDR0
  output wire [CRI_COUNTER_WIDTH-1:0] clken_rst_dly_o,
  output wire [CRI_COUNTER_WIDTH-1:0] iso_clken_dly_o,
  output wire [CRI_COUNTER_WIDTH-1:0] rst_hwstat_dly_o,
  //PPU_DCDR1
  output wire [CRI_COUNTER_WIDTH-1:0] iso_rst_dly_o,
  output wire [CRI_COUNTER_WIDTH-1:0] clken_iso_dly_o,

  //PPU_PWPR update
  output wire                 pwpr_legal_write_en_o,
  output wire                 pwpr_nxt_pwr_dyn_en_o,

  //Flush request and PWPR initialization
  output wire                 flush_req_o,
  input wire                  apb_stall_i,
  input wire                  pwpr_init_i,
  input wire [3:0]            pwr_policy_init_i,

  //Transition Control
  input wire [3:0]            trans_target_pwr_mode_i,
  input wire                  trans_comp_i,
  input wire                  trans_comp_accept_i,
  input wire                  trans_comp_deny_i,
  input wire                  trans_init_i,
  input wire                  pwr_policy_revert_i,
  input wire                  psm_idle_i,

  //Clock Control
  output wire                 reg_clk_req_o,
  output wire                 edge_clk_req_o,
  input wire                  clk_enable_i,
  output wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactive_st_o,

  //Static tie off
  input wire [3:0]            ecorevnum_i

);


  `include "pck600_ppu_enum_sse710_extsys.v"

  localparam SM_IDLE = 2'b00;
  localparam SM_SETUP = 2'b01;
  localparam SM_ACCESS = 2'b10;

  localparam PPU_PWPR = 12'h000;
  localparam PPU_PWSR = 12'h008;
  localparam PPU_DISR = 12'h010;
  localparam PPU_MISR = 12'h014;
  localparam PPU_PWCR = 12'h020;
  localparam PPU_PTCR = 12'h024;
  localparam PPU_IMR = 12'h030;
  localparam PPU_AIMR = 12'h034;
  localparam PPU_ISR = 12'h038;
  localparam PPU_AISR = 12'h03C;
  localparam PPU_IESR = 12'h040;
  localparam PPU_EDTR0 = 12'h160;
  localparam PPU_DCCR0 = 12'h170;
  localparam PPU_DCCR1 = 12'h174;
  localparam PPU_IDR0 = 12'hFB0;
  localparam PPU_IDR1 = 12'hFB4;
  localparam PPU_IIDR = 12'hFC8;
  localparam PPU_AIDR = 12'hFCC;
  localparam PID4 = 12'hFD0;
  localparam PID0 = 12'hFE0;
  localparam PID1 = 12'hFE4;
  localparam PID2 = 12'hFE8;
  localparam PID3 = 12'hFEC;
  localparam ID0 = 12'hFF0;
  localparam ID1 = 12'hFF4;
  localparam ID2 = 12'hFF8;
  localparam ID3 = 12'hFFC;

  localparam REV = 4'h1;
  localparam PART_NUM = 12'h0B6;
  localparam JEP106_CONT = 4'h4;
  localparam JEP106_ID = 7'h3B;
  localparam IMPLEMENTER = {JEP106_CONT[3:0],1'b0,JEP106_ID[6:0]};
  localparam ARCH_REV_MAJOR = 4'h1;
  localparam ARCH_REV_MINOR = 4'h1;


  genvar                      I;

  reg [11:2]                  paddr_r;
  reg                         pwrite_r;
  reg [31:0]                  pwdata_r;
  reg [31:0]                  prdata_r;
  reg                         pready_r;

  wire                        apb_en;

  reg [1:0]                   state;
  reg [1:0]                   nxt_state;
  reg                         state_en;

  reg                         nxt_pready_r;
  reg                         prdata_en;
  reg                         global_write_en;

  wire [11:2]                 paddr;
  wire                        pwrite;
  wire [31:0]                 pwdata;

  wire                        pwpr_write_en;
  wire                        pwcr_write_en;
  wire                        ptcr_write_en;
  wire                        imr_write_en;
  wire                        aimr_write_en;
  wire                        isr_write_en;
  wire                        aisr_write_en;
  wire                        iesr_write_en;
  wire                        edtr0_write_en;

  wire                        pwpr_read_en;
  wire                        pwsr_read_en;
  wire                        disr_read_en;
  wire                        misr_read_en;
  wire                        pwcr_read_en;
  wire                        ptcr_read_en;
  wire                        imr_read_en;
  wire                        aimr_read_en;
  wire                        isr_read_en;
  wire                        aisr_read_en;
  wire                        iesr_read_en;
  wire                        edtr0_read_en;
  wire                        dcdr0_read_en;
  wire                        dcdr1_read_en;
  wire                        idr0_read_en;
  wire                        idr1_read_en;
  wire                        iidr_read_en;
  wire                        aidr_read_en;
  wire                        pid4_read_en;
  wire                        pid0_read_en;
  wire                        pid1_read_en;
  wire                        pid2_read_en;
  wire                        pid3_read_en;
  wire                        id0_read_en;
  wire                        id1_read_en;
  wire                        id2_read_en;
  wire                        id3_read_en;

  wire [31:0]                 pwpr_rdata;
  wire [31:0]                 pwsr_rdata;
  wire [31:0]                 disr_rdata;
  wire [31:0]                 misr_rdata;
  wire [31:0]                 pwcr_rdata;
  wire [31:0]                 ptcr_rdata;
  wire [31:0]                 imr_rdata;
  wire [31:0]                 aimr_rdata;
  wire [31:0]                 isr_rdata;
  wire [31:0]                 aisr_rdata;
  wire [31:0]                 iesr_rdata;
  wire [31:0]                 edtr0_rdata;
  wire [31:0]                 dcdr0_rdata;
  wire [31:0]                 dcdr1_rdata;
  wire [31:0]                 idr0_rdata;
  wire [31:0]                 idr1_rdata;
  wire [31:0]                 iidr_rdata;
  wire [31:0]                 aidr_rdata;
  wire [31:0]                 pid4_rdata;
  wire [31:0]                 pid5_rdata;
  wire [31:0]                 pid6_rdata;
  wire [31:0]                 pid7_rdata;
  wire [31:0]                 pid0_rdata;
  wire [31:0]                 pid1_rdata;
  wire [31:0]                 pid2_rdata;
  wire [31:0]                 pid3_rdata;
  wire [31:0]                 id0_rdata;
  wire [31:0]                 id1_rdata;
  wire [31:0]                 id2_rdata;
  wire [31:0]                 id3_rdata;

  wire [31:0]                 read_data;

  wire                        flush_req;

  reg                         legal_pwr_policy;
  wire                        pwpr_legal_write;
  wire                        unspt_policy_irq_pulse;

  reg                         pwr_policy_3_r;
  reg                         pwr_policy_0_r;
  reg                         pwr_dyn_en_r;
  reg                         nxt_pwr_policy_3_r;
  reg                         nxt_pwr_policy_0_r;
  reg                         nxt_pwr_dyn_en_r;
  wire                        pwpr_en;
  wire [3:0]                  pwr_policy;


  reg [NUM_DEV_LPI-1:0]       devreqen_r;
  reg [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactiveen_r;

  reg                         warm_rst_devreqen_r;

  reg                         sta_policy_trn_irq_mask_r;
  reg                         sta_accept_irq_mask_r;
  reg                         sta_deny_irq_mask_r;

  reg                         unspt_policy_irq_mask_r;
  reg                         dyn_accept_irq_mask_r;
  reg                         dyn_deny_irq_mask_r;

  reg                         sta_policy_trn_irq_st_r;
  reg                         sta_accept_irq_st_r;
  reg                         sta_deny_irq_st_r;
  reg [NUM_PWR_DEVACTIVE-1:1] pwr_active_edge_irq_st_r;
  reg                         nxt_sta_policy_trn_irq_st_r;
  reg                         nxt_sta_accept_irq_st_r;
  reg                         nxt_sta_deny_irq_st_r;
  reg [NUM_PWR_DEVACTIVE-1:1] nxt_pwr_active_edge_irq_st_r;

  reg                         unspt_policy_irq_st_r;
  reg                         dyn_accept_irq_st_r;
  reg                         dyn_deny_irq_st_r;
  reg                         nxt_unspt_policy_irq_st_r;
  reg                         nxt_dyn_accept_irq_st_r;
  reg                         nxt_dyn_deny_irq_st_r;
  wire                        other_irq;

  reg [NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2] devactive_edge_r;

  reg [7:0]                   off_del_r;



  wire [3:0]                  pwr_policy_compare;
  wire                        pwr_dyn_en_compare;
  wire [3:0]                  pwr_st_compare;
  reg                         pwr_policy_match;

  reg                         policy_writtern_r;
  reg                         nxt_policy_writtern_r;

  wire                        sta_policy_trn_irq_write;
  wire                        sta_policy_trn_irq_trans_accept;
  wire                        sta_policy_trn_irq_trans_deny;
  wire                        sta_policy_trn_irq_trans_comp;
  wire                        sta_policy_trn_irq_pulse_mask;
  wire                        sta_accept_irq_pulse_mask;
  wire                        sta_deny_irq_pulse_mask;
  wire [NUM_PWR_DEVACTIVE-1:1] pwr_active_edge_irq_pulse_mask;
  wire                        unspt_policy_irq_pulse_mask;
  wire                        dyn_accept_irq_pulse_mask;
  wire                        dyn_deny_irq_pulse_mask;

  wire                        sta_policy_trn_irq_clear;
  wire                        sta_accept_irq_clear;
  wire                        sta_deny_irq_clear;
  wire [NUM_PWR_DEVACTIVE-1:1] pwr_active_edge_irq_clear;
  wire                        unspt_policy_irq_clear;
  wire                        dyn_accept_irq_clear;
  wire                        dyn_deny_irq_clear;

  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] devactive_int;
  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] devactive_st_int;
  wire [NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2] irq_edge_ctrl;
  wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] irq_edge_pulse;

  reg                         irq_r;
  wire                        nxt_irq_r;

  wire                        clk_req;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      paddr_r[11:2] <= 10'h000;
      pwrite_r <= 1'b0;
      pwdata_r <= 32'h00000000;
    end
    else if(apb_en)
    begin
      paddr_r[11:2] <= paddr_i[11:2];
      pwrite_r <= pwrite_i;
      pwdata_r[31:0] <= pwdata_i[31:0];
    end
  end

  assign apb_en = psel_i;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pready_r <= 1'b0;
    end
    else
    begin
      pready_r <= nxt_pready_r;
    end
  end

  always@(posedge clk)
  begin
    if(prdata_en)
    begin
      prdata_r[31:0] <= read_data[31:0];
    end
  end

  assign paddr[11:2] = paddr_r[11:2];
  assign pwrite = pwrite_r;
  assign pwdata[31:0] = pwdata_r[31:0];


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[1:0] <= SM_IDLE;
    end
    else if(state_en)
    begin
      state[1:0] <= nxt_state[1:0];
    end
  end

  always@*
  begin
    case(state[1:0])
    SM_IDLE:
    begin
      nxt_state[1:0] = SM_SETUP;
      state_en = psel_i & clk_enable_i & ~apb_stall_i;
      prdata_en = 1'b0;
      nxt_pready_r = 1'b0;
      global_write_en = 1'b0;
    end
    SM_SETUP:
    begin
      nxt_state[1:0] = SM_ACCESS;
      state_en = 1'b1;
      prdata_en = ~pwrite;
      nxt_pready_r = 1'b1;
      global_write_en = 1'b0;
    end
    SM_ACCESS:
    begin
      nxt_state[1:0] = SM_IDLE;
      state_en = 1'b1;
      prdata_en = 1'b0;
      nxt_pready_r = 1'b0;
      global_write_en = pwrite;
    end
    default:
    begin
      nxt_state[1:0] = 2'bxx;
      state_en = 1'bx;
      prdata_en = 1'bx;
      nxt_pready_r = 1'bx;
      global_write_en = 1'bx;
    end
    endcase
  end


  assign clk_req = psel_i;


  assign pwpr_read_en = (paddr[11:2] == PPU_PWPR[11:2]);
  assign pwsr_read_en = (paddr[11:2] == PPU_PWSR[11:2]);
  assign disr_read_en = (paddr[11:2] == PPU_DISR[11:2]);
  assign misr_read_en = (paddr[11:2] == PPU_MISR[11:2]);
  assign pwcr_read_en = (paddr[11:2] == PPU_PWCR[11:2]);
  assign ptcr_read_en = (paddr[11:2] == PPU_PTCR[11:2]);
  assign imr_read_en = (paddr[11:2] == PPU_IMR[11:2]);
  assign aimr_read_en = (paddr[11:2] == PPU_AIMR[11:2]);
  assign isr_read_en = (paddr[11:2] == PPU_ISR[11:2]);
  assign aisr_read_en = (paddr[11:2] == PPU_AISR[11:2]);
  assign iesr_read_en = (paddr[11:2] == PPU_IESR[11:2]);
  assign edtr0_read_en = (paddr[11:2] == PPU_EDTR0[11:2]);
  assign dcdr0_read_en = (paddr[11:2] == PPU_DCCR0[11:2]);
  assign dcdr1_read_en = (paddr[11:2] == PPU_DCCR1[11:2]);
  assign idr0_read_en = (paddr[11:2] == PPU_IDR0[11:2]);
  assign idr1_read_en = (paddr[11:2] == PPU_IDR1[11:2]);
  assign iidr_read_en = (paddr[11:2] == PPU_IIDR[11:2]);
  assign aidr_read_en = (paddr[11:2] == PPU_AIDR[11:2]);
  assign pid4_read_en = (paddr[11:2] == PID4[11:2]);
  assign pid0_read_en = (paddr[11:2] == PID0[11:2]);
  assign pid1_read_en = (paddr[11:2] == PID1[11:2]);
  assign pid2_read_en = (paddr[11:2] == PID2[11:2]);
  assign pid3_read_en = (paddr[11:2] == PID3[11:2]);
  assign id0_read_en = (paddr[11:2] == ID0[11:2]);
  assign id1_read_en = (paddr[11:2] == ID1[11:2]);
  assign id2_read_en = (paddr[11:2] == ID2[11:2]);
  assign id3_read_en = (paddr[11:2] == ID3[11:2]);


  assign pwpr_write_en = (paddr[11:2] == PPU_PWPR[11:2]) & global_write_en;
  assign pwcr_write_en = (paddr[11:2] == PPU_PWCR[11:2]) & global_write_en;
  assign ptcr_write_en = (paddr[11:2] == PPU_PTCR[11:2]) & global_write_en;
  assign imr_write_en = (paddr[11:2] == PPU_IMR[11:2]) & global_write_en;
  assign aimr_write_en = (paddr[11:2] == PPU_AIMR[11:2]) & global_write_en;
  assign isr_write_en = (paddr[11:2] == PPU_ISR[11:2]) & global_write_en;
  assign aisr_write_en = (paddr[11:2] == PPU_AISR[11:2]) & global_write_en;
  assign iesr_write_en = (paddr[11:2] == PPU_IESR[11:2]) & global_write_en;
  assign edtr0_write_en = (paddr[11:2] == PPU_EDTR0[11:2]) & global_write_en;


  assign read_data[31:0] = pwpr_rdata[31:0] |
                            pwsr_rdata[31:0] |
                            disr_rdata[31:0] |
                            misr_rdata[31:0] |
                            pwcr_rdata[31:0] |
                            ptcr_rdata[31:0] |
                            imr_rdata[31:0] |
                            aimr_rdata[31:0] |
                            isr_rdata[31:0] |
                            aisr_rdata[31:0] |
                            iesr_rdata[31:0] |
                            edtr0_rdata[31:0] |
                            dcdr0_rdata[31:0] |
                            dcdr1_rdata[31:0] |
                            idr0_rdata[31:0] |
                            idr1_rdata[31:0] |
                            iidr_rdata[31:0] |
                            aidr_rdata[31:0] |
                            pid4_rdata[31:0] |
                            pid5_rdata[31:0] |
                            pid6_rdata[31:0] |
                            pid7_rdata[31:0] |
                            pid0_rdata[31:0] |
                            pid1_rdata[31:0] |
                            pid2_rdata[31:0] |
                            pid3_rdata[31:0] |
                            id0_rdata[31:0] |
                            id1_rdata[31:0] |
                            id2_rdata[31:0] |
                            id3_rdata[31:0];



  assign flush_req = pwpr_write_en |
                      pwcr_write_en |
                      ptcr_write_en;


  always@*
  begin
    case({pwdata[8],pwdata[3:0]})
    {1'b0,P_OFF}:         legal_pwr_policy = 1'b1;
    {1'b0,P_OFF_EMU}:     legal_pwr_policy = STA_OFF_EMU_SPT_CFG[0];
    {1'b0,P_MEM_RET}:     legal_pwr_policy = STA_MEM_RET_SPT_CFG[0];
    {1'b0,P_MEM_RET_EMU}: legal_pwr_policy = STA_MEM_RET_EMU_SPT_CFG[0];
    {1'b0,P_LGC_RET}:     legal_pwr_policy = STA_LGC_RET_SPT_CFG[0];
    {1'b0,P_FULL_RET}:    legal_pwr_policy = STA_FULL_RET_SPT_CFG[0];
    {1'b0,P_MEM_OFF}:     legal_pwr_policy = STA_MEM_OFF_SPT_CFG[0];
    {1'b0,P_FUNC_RET}:    legal_pwr_policy = STA_FUNC_RET_SPT_CFG[0];
    {1'b0,P_ON}:          legal_pwr_policy = 1'b1;
    {1'b0,P_WRM_RST}:     legal_pwr_policy = 1'b1;
    {1'b0,P_DBG_RECOV}:   legal_pwr_policy = STA_DBG_RECOV_SPT_CFG[0];
    {1'b0,P_UNUSED_11}:   legal_pwr_policy = 1'b0;
    {1'b0,P_UNUSED_12}:   legal_pwr_policy = 1'b0;
    {1'b0,P_UNUSED_13}:   legal_pwr_policy = 1'b0;
    {1'b0,P_UNUSED_14}:   legal_pwr_policy = 1'b0;
    {1'b0,P_UNUSED_15}:   legal_pwr_policy = 1'b0;
    {1'b1,P_OFF}:         legal_pwr_policy = DYN_OFF_SPT_CFG[0];
    {1'b1,P_OFF_EMU}:     legal_pwr_policy = DYN_OFF_EMU_SPT_CFG[0];
    {1'b1,P_MEM_RET}:     legal_pwr_policy = DYN_MEM_RET_SPT_CFG[0];
    {1'b1,P_MEM_RET_EMU}: legal_pwr_policy = DYN_MEM_RET_EMU_SPT_CFG[0];
    {1'b1,P_LGC_RET}:     legal_pwr_policy = DYN_LGC_RET_SPT_CFG[0];
    {1'b1,P_FULL_RET}:    legal_pwr_policy = DYN_FULL_RET_SPT_CFG[0];
    {1'b1,P_MEM_OFF}:     legal_pwr_policy = DYN_MEM_OFF_SPT_CFG[0];
    {1'b1,P_FUNC_RET}:    legal_pwr_policy = DYN_FUNC_RET_SPT_CFG[0];
    {1'b1,P_ON}:          legal_pwr_policy = DYN_ON_SPT_CFG[0];
    {1'b1,P_WRM_RST}:     legal_pwr_policy = DYN_WRM_RST_SPT_CFG[0];
    {1'b1,P_DBG_RECOV}:   legal_pwr_policy = 1'b0;
    {1'b1,P_UNUSED_11}:   legal_pwr_policy = 1'b0;
    {1'b1,P_UNUSED_12}:   legal_pwr_policy = 1'b0;
    {1'b1,P_UNUSED_13}:   legal_pwr_policy = 1'b0;
    {1'b1,P_UNUSED_14}:   legal_pwr_policy = 1'b0;
    {1'b1,P_UNUSED_15}:   legal_pwr_policy = 1'b0;
    default:              legal_pwr_policy = 1'bx;
    endcase
  end

  assign pwpr_legal_write = pwpr_write_en & legal_pwr_policy;

  assign unspt_policy_irq_pulse = pwpr_write_en & ~legal_pwr_policy;


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pwr_policy_3_r <= DEF_PWR_POLICY[3];
      pwr_policy_0_r <= DEF_PWR_POLICY[0];
      pwr_dyn_en_r <= DEF_PWR_DYN_EN[0];
    end
    else if(pwpr_en)
    begin
      pwr_policy_3_r <= nxt_pwr_policy_3_r;
      pwr_policy_0_r <= nxt_pwr_policy_0_r;
      pwr_dyn_en_r <= nxt_pwr_dyn_en_r;
    end
  end

  assign pwr_policy[3:0] = {pwr_policy_3_r,
                            1'b0,
                            1'b0,
                            pwr_policy_0_r};


  assign pwpr_en = pwpr_legal_write | pwr_policy_revert_i | pwpr_init_i;

  assign pwpr_rdata[31:0] = {7'h00,
                            9'h000,
                            3'b000,
                            1'b0,
                            3'b000,
                            (pwpr_read_en & pwr_dyn_en_r),
                            4'h0,
                            ({4{pwpr_read_en}} & pwr_policy[3:0])};

  always@*
  begin
    case(pwpr_init_i)
    1'b0:
    begin
      case({pwpr_legal_write,pwr_policy_revert_i})
      2'b00:
      begin
        nxt_pwr_policy_3_r = pwr_policy_3_r;
        nxt_pwr_policy_0_r = pwr_policy_0_r;
      end
      2'b01:
      begin
        nxt_pwr_policy_3_r = pwr_st_i[3];
        nxt_pwr_policy_0_r = pwr_st_i[0];
      end
      2'b10,2'b11:
      begin
        nxt_pwr_policy_3_r = pwdata[3];
        nxt_pwr_policy_0_r = pwdata[0];
      end
      default:
      begin
        nxt_pwr_policy_3_r = 1'bx;
        nxt_pwr_policy_0_r = 1'bx;
      end
      endcase
    end
    1'b1:
    begin
      nxt_pwr_policy_3_r = pwr_policy_init_i[3];
      nxt_pwr_policy_0_r = pwr_policy_init_i[0];
    end
    endcase
  end

  always@*
  begin
    case({pwpr_legal_write,pwr_policy_revert_i})
    2'b00:
    begin
      nxt_pwr_dyn_en_r = pwr_dyn_en_r;
    end
    2'b01:
    begin
      nxt_pwr_dyn_en_r = pwr_dyn_st_i;
    end
    2'b10,2'b11:
    begin
      nxt_pwr_dyn_en_r = pwdata[8];
    end
    default:
    begin
      nxt_pwr_dyn_en_r = 1'bx;
    end
    endcase
  end




  assign pwsr_rdata[31:0] = {7'h00,
                            9'h000,
                            3'b000,
                            1'b0,
                            3'b000,
                            (pwsr_read_en & pwr_dyn_st_i),
                            4'h0,
                            ({4{pwsr_read_en}} & pwr_st_i[3:0])};



  assign disr_rdata[31:0] = {{(32-NUM_PWR_DEVACTIVE){1'b0}},
                              ({(NUM_PWR_DEVACTIVE-DEVACTIVE_LSB){disr_read_en}} & pwr_devactive_i[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB]),
                            1'b0};



  assign misr_rdata[31:0] = {8'h00,
                            {8-NUM_DEV_LPI{1'b0}},
                            ({NUM_DEV_LPI{misr_read_en}} & devdeny_i[NUM_DEV_LPI-1:0]),
                            {8-NUM_DEV_LPI{1'b0}},
                            ({NUM_DEV_LPI{misr_read_en}} & devaccept_i[NUM_DEV_LPI-1:0]),
                            7'h00,
                            (misr_read_en & pcsm_paccept_i)};



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devreqen_r[NUM_DEV_LPI-1:0] <= {NUM_DEV_LPI{1'b1}};
      pwr_devactiveen_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] <= {NUM_PWR_DEVACTIVE-DEVACTIVE_LSB{1'b1}};
    end
    else if(pwcr_write_en)
    begin
      devreqen_r[NUM_DEV_LPI-1:0] <= pwdata[0 +: NUM_DEV_LPI];
      pwr_devactiveen_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] <= pwdata[(8+DEVACTIVE_LSB) +: (NUM_PWR_DEVACTIVE-DEVACTIVE_LSB)];
    end
  end

  assign pwcr_rdata[31:0] = {8'h00,
                            5'h00,
                            ({NUM_PWR_DEVACTIVE-DEVACTIVE_LSB{pwcr_read_en}} & pwr_devactiveen_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB]),
                            1'b0,
                            7'h00,
                            (pwcr_read_en & devreqen_r[0])};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      warm_rst_devreqen_r <= WARM_RST_DEVREQEN_CFG[0];
    end
    else if(ptcr_write_en)
    begin
      warm_rst_devreqen_r <= pwdata[0];
    end
  end

  assign ptcr_rdata[31:0] = {30'h00000000,
                            1'b0,
                            (ptcr_read_en & warm_rst_devreqen_r)};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      sta_policy_trn_irq_mask_r <= 1'b0;
      sta_accept_irq_mask_r <= 1'b1;
      sta_deny_irq_mask_r <= 1'b0;
    end
    else if(imr_write_en)
    begin
      sta_policy_trn_irq_mask_r <= pwdata[0];
      sta_accept_irq_mask_r <= pwdata[1];
      sta_deny_irq_mask_r <= pwdata[2];
    end
  end

  assign imr_rdata[31:0] = {26'h0000000,
                           1'b0,
                           2'b00,
                           (imr_read_en & sta_deny_irq_mask_r),
                           (imr_read_en & sta_accept_irq_mask_r),
                           (imr_read_en & sta_policy_trn_irq_mask_r)};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      unspt_policy_irq_mask_r <= 1'b0;
      dyn_accept_irq_mask_r <= 1'b1;
      dyn_deny_irq_mask_r <= 1'b1;
    end
    else if(aimr_write_en)
    begin
      unspt_policy_irq_mask_r <= pwdata[0];
      dyn_accept_irq_mask_r <= pwdata[1];
      dyn_deny_irq_mask_r <= pwdata[2];
    end
  end

  assign aimr_rdata[31:0] = {27'h0000000,
                            1'b0,
                            1'b0,
                            (aimr_read_en & dyn_deny_irq_mask_r),
                            (aimr_read_en & dyn_accept_irq_mask_r),
                            (aimr_read_en & unspt_policy_irq_mask_r)};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      sta_policy_trn_irq_st_r <= 1'b0;
      sta_accept_irq_st_r <= 1'b0;
      sta_deny_irq_st_r <= 1'b0;
      pwr_active_edge_irq_st_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] <= {NUM_PWR_DEVACTIVE-DEVACTIVE_LSB{1'b0}};
    end
    else
    begin
      sta_policy_trn_irq_st_r <= nxt_sta_policy_trn_irq_st_r;
      sta_accept_irq_st_r <= nxt_sta_accept_irq_st_r;
      sta_deny_irq_st_r <= nxt_sta_deny_irq_st_r;
      pwr_active_edge_irq_st_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] <= nxt_pwr_active_edge_irq_st_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];
    end
  end

  assign isr_rdata[31:0] = {8'h00,
                           5'h00,
                           ({NUM_PWR_DEVACTIVE-DEVACTIVE_LSB{isr_read_en}} & pwr_active_edge_irq_st_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB]),
                           1'b0,
                           (isr_read_en & other_irq),
                           1'b0,
                           1'b0,
                           2'b00,
                           (isr_read_en & sta_deny_irq_st_r),
                           (isr_read_en & sta_accept_irq_st_r),
                           (isr_read_en & sta_policy_trn_irq_st_r)};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      unspt_policy_irq_st_r <= 1'b0;
      dyn_accept_irq_st_r <= 1'b0;
      dyn_deny_irq_st_r <= 1'b0;
    end
    else
    begin
      unspt_policy_irq_st_r <= nxt_unspt_policy_irq_st_r;
      dyn_accept_irq_st_r <= nxt_dyn_accept_irq_st_r;
      dyn_deny_irq_st_r <= nxt_dyn_deny_irq_st_r;
    end
  end

  assign aisr_rdata[31:0] = {27'h0000000,
                            1'b0,
                            1'b0,
                            (aisr_read_en & dyn_deny_irq_st_r),
                            (aisr_read_en & dyn_accept_irq_st_r),
                            (aisr_read_en & unspt_policy_irq_st_r)};

  assign other_irq = |({
                        dyn_deny_irq_st_r,
                        dyn_accept_irq_st_r,
                        unspt_policy_irq_st_r});



  assign pwr_policy_compare[3:0] = (pwpr_legal_write)? pwdata[3:0]:pwr_policy[3:0];
  assign pwr_dyn_en_compare = (pwpr_legal_write)? pwdata[8]:pwr_dyn_en_r;
  assign pwr_st_compare[3:0] = (trans_comp_accept_i)? trans_target_pwr_mode_i[3:0]:pwr_st_i[3:0];

  //Calculate when policy and current mode match
  always@*
  begin
    case({pwr_policy_compare[3:0],pwr_st_compare[3:0]})
    {P_OFF,P_OFF},{P_ON,P_ON},
    {P_WRM_RST,P_WRM_RST}:
    begin
      pwr_policy_match = 1'b1;
    end
    {P_OFF,P_ON},{P_OFF,P_WRM_RST},{P_ON,P_OFF},{P_ON,P_WRM_RST},
    {P_WRM_RST,P_OFF},{P_WRM_RST,P_ON}:
    begin
      pwr_policy_match = 1'b0;
    end
    default:
    begin
      //X-Prop
      pwr_policy_match = 1'bx;
    end
    endcase
  end


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      policy_writtern_r <= 1'b0;
    end
    else
    begin
      policy_writtern_r <= nxt_policy_writtern_r;
    end
  end

  always@*
  begin
    case({(pwpr_legal_write & ~psm_idle_i),trans_comp_i})
    2'b00: nxt_policy_writtern_r = policy_writtern_r;
    2'b01: nxt_policy_writtern_r = 1'b0;
    2'b10: nxt_policy_writtern_r = 1'b1;
    2'b11: nxt_policy_writtern_r = 1'b0;
    default: nxt_policy_writtern_r = 1'bx;
    endcase
  end

  always@*
  begin
    case({sta_policy_trn_irq_pulse_mask,sta_policy_trn_irq_clear})
    2'b00:  nxt_sta_policy_trn_irq_st_r = sta_policy_trn_irq_st_r;
    2'b01:  nxt_sta_policy_trn_irq_st_r = 1'b0;
    2'b10:  nxt_sta_policy_trn_irq_st_r = 1'b1;
    2'b11:  nxt_sta_policy_trn_irq_st_r = 1'b1;
    default:nxt_sta_policy_trn_irq_st_r = 1'bx;
    endcase
  end

  assign sta_policy_trn_irq_clear = isr_write_en & pwdata[0];
  assign sta_policy_trn_irq_write = psm_idle_i & pwpr_legal_write &
                                    ~pwr_dyn_en_compare & pwr_policy_match;
  assign sta_policy_trn_irq_trans_accept = trans_comp_accept_i & ~pwr_dyn_st_i & pwr_policy_match &
                                           (~trans_init_i | policy_writtern_r | pwpr_legal_write);
  assign sta_policy_trn_irq_trans_deny = trans_comp_deny_i & ~pwr_dyn_st_i & pwr_policy_match & (policy_writtern_r | pwpr_legal_write);
  assign sta_policy_trn_irq_trans_comp = trans_comp_i & pwr_dyn_st_i & ~pwr_dyn_en_compare & pwr_policy_match &
                                         (~trans_init_i | policy_writtern_r | pwpr_legal_write);

  assign sta_policy_trn_irq_pulse_mask = (sta_policy_trn_irq_write |
                                          sta_policy_trn_irq_trans_accept |
                                          sta_policy_trn_irq_trans_deny |
                                          sta_policy_trn_irq_trans_comp) & ~sta_policy_trn_irq_mask_r;

  always@*
  begin
    case({sta_accept_irq_pulse_mask,sta_accept_irq_clear})
    2'b00:  nxt_sta_accept_irq_st_r = sta_accept_irq_st_r;
    2'b01:  nxt_sta_accept_irq_st_r = 1'b0;
    2'b10:  nxt_sta_accept_irq_st_r = 1'b1;
    2'b11:  nxt_sta_accept_irq_st_r = 1'b1;
    default:nxt_sta_accept_irq_st_r = 1'bx;
    endcase
  end

  assign sta_accept_irq_clear = isr_write_en & pwdata[1];
  assign sta_accept_irq_pulse_mask = ~pwr_dyn_st_i & trans_comp_accept_i &
                                     ~trans_init_i &
                                     ~sta_accept_irq_mask_r;

  always@*
  begin
    case({sta_deny_irq_pulse_mask,sta_deny_irq_clear})
    2'b00:  nxt_sta_deny_irq_st_r = sta_deny_irq_st_r;
    2'b01:  nxt_sta_deny_irq_st_r = 1'b0;
    2'b10:  nxt_sta_deny_irq_st_r = 1'b1;
    2'b11:  nxt_sta_deny_irq_st_r = 1'b1;
    default:nxt_sta_deny_irq_st_r = 1'bx;
    endcase
  end

  assign sta_deny_irq_clear = isr_write_en & pwdata[2];
  assign sta_deny_irq_pulse_mask = ~pwr_dyn_st_i & trans_comp_deny_i &
                                   ~trans_init_i &
                                   ~sta_deny_irq_mask_r;


generate
for(I=DEVACTIVE_LSB; I<NUM_PWR_DEVACTIVE; I=I+1)
begin:nxt_pwr_active_edge_irq_st_loop

  always@*
  begin
    case({pwr_active_edge_irq_pulse_mask[I],pwr_active_edge_irq_clear[I]})
    2'b00:  nxt_pwr_active_edge_irq_st_r[I] = pwr_active_edge_irq_st_r[I];
    2'b01:  nxt_pwr_active_edge_irq_st_r[I] = 1'b0;
    2'b10:  nxt_pwr_active_edge_irq_st_r[I] = 1'b1;
    2'b11:  nxt_pwr_active_edge_irq_st_r[I] = 1'b1;
    default:nxt_pwr_active_edge_irq_st_r[I] = 1'bx;
    endcase
  end

  assign pwr_active_edge_irq_clear[I] = isr_write_en & pwdata[8+I];

end
endgenerate

  always@*
  begin
    case({unspt_policy_irq_pulse_mask,unspt_policy_irq_clear})
    2'b00:  nxt_unspt_policy_irq_st_r = unspt_policy_irq_st_r;
    2'b01:  nxt_unspt_policy_irq_st_r = 1'b0;
    2'b10:  nxt_unspt_policy_irq_st_r = 1'b1;
    default:nxt_unspt_policy_irq_st_r = 1'bx;
    endcase
  end

  assign unspt_policy_irq_clear = aisr_write_en & pwdata[0];
  assign unspt_policy_irq_pulse_mask = unspt_policy_irq_pulse & ~unspt_policy_irq_mask_r;

  always@*
  begin
    case({dyn_accept_irq_pulse_mask,dyn_accept_irq_clear})
    2'b00:  nxt_dyn_accept_irq_st_r = dyn_accept_irq_st_r;
    2'b01:  nxt_dyn_accept_irq_st_r = 1'b0;
    2'b10:  nxt_dyn_accept_irq_st_r = 1'b1;
    2'b11:  nxt_dyn_accept_irq_st_r = 1'b1;
    default:nxt_dyn_accept_irq_st_r = 1'bx;
    endcase
  end

  assign dyn_accept_irq_clear = aisr_write_en & pwdata[1];
  assign dyn_accept_irq_pulse_mask = pwr_dyn_st_i & trans_comp_accept_i &
                                     ~trans_init_i &
                                     ~dyn_accept_irq_mask_r;

  always@*
  begin
    case({dyn_deny_irq_pulse_mask,dyn_deny_irq_clear})
    2'b00:  nxt_dyn_deny_irq_st_r = dyn_deny_irq_st_r;
    2'b01:  nxt_dyn_deny_irq_st_r = 1'b0;
    2'b10:  nxt_dyn_deny_irq_st_r = 1'b1;
    2'b11:  nxt_dyn_deny_irq_st_r = 1'b1;
    default:nxt_dyn_deny_irq_st_r = 1'bx;
    endcase
  end

  assign dyn_deny_irq_clear = aisr_write_en & pwdata[2];
  assign dyn_deny_irq_pulse_mask = pwr_dyn_st_i & trans_comp_deny_i &
                                   ~trans_init_i &
                                   ~dyn_deny_irq_mask_r;


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      irq_r <= 1'b0;
    end
    else
    begin
      irq_r <= nxt_irq_r;
    end
  end

  assign nxt_irq_r = |({nxt_pwr_active_edge_irq_st_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB],
                        nxt_sta_deny_irq_st_r,
                        nxt_sta_accept_irq_st_r,
                        nxt_sta_policy_trn_irq_st_r,
                        nxt_dyn_deny_irq_st_r,
                        nxt_dyn_accept_irq_st_r,
                        nxt_unspt_policy_irq_st_r});


  pck600_ppu_edge_detector_sse710_extsys
  #(
    .WIDTH(NUM_PWR_DEVACTIVE-DEVACTIVE_LSB)
  )
  u_pck600_ppu_edge_detector
  (
    .clk                    (clk),
    .reset_n                 (reset_n),
    .devactive_i            (devactive_int),
    .devactive_edge_i       (irq_edge_ctrl),
    .devactive_pulse_mask_o (irq_edge_pulse),
    .devactive_st_o         (devactive_st_int),
    .clk_req_o              (edge_clk_req_o),
    .clk_enable_i           (clk_enable_i)
  );


  assign devactive_int[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] = pwr_devactive_i[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];
  assign irq_edge_ctrl[NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2] = devactive_edge_r[NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2];
  assign pwr_active_edge_irq_pulse_mask[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] = irq_edge_pulse[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devactive_edge_r[NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2] <= {NUM_PWR_DEVACTIVE-DEVACTIVE_LSB{2'b00}};
    end
    else if(iesr_write_en)
    begin
      devactive_edge_r[NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2] <= pwdata[NUM_PWR_DEVACTIVE*2-1:DEVACTIVE_LSB*2];
    end
  end

  assign iesr_rdata[31:0] = {10'h000,
                            ({(NUM_PWR_DEVACTIVE-1)*2{iesr_read_en}} & devactive_edge_r[NUM_PWR_DEVACTIVE*2-1:2]),
                            2'b00};


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      off_del_r[7:0] <= 8'h00;
    end
    else if(edtr0_write_en)
    begin
      off_del_r[7:0] <= pwdata[7:0];
    end
  end

  assign edtr0_rdata[31:0] = {8'h00,
                             8'h00,
                             8'h00,
                             ({8{edtr0_read_en}} & off_del_r[7:0])};


  assign dcdr0_rdata[31:0] = {8'h00,
                             ({8{dcdr0_read_en}} & RST_HWSTAT_DLY_CFG[7:0]),
                             ({8{dcdr0_read_en}} & ISO_CLKEN_DLY_CFG[7:0]),
                             ({8{dcdr0_read_en}} & CLKEN_RST_DLY_CFG[7:0])};



  assign dcdr1_rdata[31:0] = {16'h0000,
                             ({8{dcdr1_read_en}} & CLKEN_ISO_DLY_CFG[7:0]),
                             ({8{dcdr1_read_en}} & ISO_RST_DLY_CFG[7:0])};



  assign idr0_rdata[31:0] = {2'b00,
                            (idr0_read_en & DYN_WRM_RST_SPT_CFG[0]),
                            (idr0_read_en & DYN_ON_SPT_CFG[0]),
                            (idr0_read_en & DYN_FUNC_RET_SPT_CFG[0]),
                            (idr0_read_en & DYN_FULL_RET_SPT_CFG[0]),
                            (idr0_read_en & DYN_MEM_OFF_SPT_CFG[0]),
                            (idr0_read_en & DYN_LGC_RET_SPT_CFG[0]),
                            (idr0_read_en & DYN_MEM_RET_EMU_SPT_CFG[0]),
                            (idr0_read_en & DYN_MEM_RET_SPT_CFG[0]),
                            (idr0_read_en & DYN_OFF_EMU_SPT_CFG[0]),
                            (idr0_read_en & DYN_OFF_SPT_CFG[0]),
                            1'b0,
                            (idr0_read_en & STA_DBG_RECOV_SPT_CFG[0]),
                            (idr0_read_en & 1'b1),
                            (idr0_read_en & 1'b1),
                            (idr0_read_en & STA_FUNC_RET_SPT_CFG[0]),
                            (idr0_read_en & STA_FULL_RET_SPT_CFG[0]),
                            (idr0_read_en & STA_MEM_OFF_SPT_CFG[0]),
                            (idr0_read_en & STA_LGC_RET_SPT_CFG[0]),
                            (idr0_read_en & STA_MEM_RET_EMU_SPT_CFG[0]),
                            (idr0_read_en & STA_MEM_RET_SPT_CFG[0]),
                            (idr0_read_en & STA_OFF_EMU_SPT_CFG[0]),
                            (idr0_read_en & 1'b1),
                            ({4{idr0_read_en}} & NUM_OPMODE_CFG[3:0]),
                            ({4{idr0_read_en}} & DEVCHAN_CFG[3:0])};


  assign idr1_rdata[31:0] = {19'h00000,
                            (idr1_read_en & OFF_MEM_RET_TRANS_CFG[0]),
                            1'b0,
                            (idr1_read_en & OP_ACTIVE_CFG[0]),
                            (idr1_read_en & STA_POLICY_OP_IRQ_CFG[0]),
                            (idr1_read_en & STA_POLICY_PWR_IRQ_CFG[0]),
                            1'b0,
                            (idr1_read_en & FUNC_RET_RAM_REG_CFG[0]),
                            (idr1_read_en & FULL_RET_RAM_REG_CFG[0]),
                            (idr1_read_en & MEM_RET_RAM_REG_CFG[0]),
                            1'b0,
                            (idr1_read_en & LOCK_CFG[0]),
                            (idr1_read_en & SW_DEV_DEL_CFG[0]),
                            (idr1_read_en & PWR_MODE_ENTRY_DEL_CFG[0])};


  assign iidr_rdata[31:0] = {32{iidr_read_en}} & {PART_NUM[11:0],
                                                  REV[3:0],
                                                  ecorevnum_i[3:0],
                                                  IMPLEMENTER[11:0]};


  assign aidr_rdata[31:0] = {24'h000000,
                            ({8{aidr_read_en}} & {ARCH_REV_MAJOR[3:0],
                                                  ARCH_REV_MINOR[3:0]})};


  assign pid4_rdata[31:0] = {24'h000000,
                             ({8{pid4_read_en}} & {4'h0,
                                                   JEP106_CONT[3:0]})};


  assign pid5_rdata[31:0] = 32'h00000000;


  assign pid6_rdata[31:0] = 32'h00000000;


  assign pid7_rdata[31:0] = 32'h00000000;


  assign pid0_rdata[31:0] = {24'h000000,
                            ({8{pid0_read_en}} & PART_NUM[7:0])};


  assign pid1_rdata[31:0] = {24'h000000,
                             ({8{pid1_read_en}} & {JEP106_ID[3:0],
                                                   PART_NUM[11:8]})};


  assign pid2_rdata[31:0] = {24'h000000,
                             ({8{pid2_read_en}} & {REV[3:0],
                                                   1'b1,
                                                   JEP106_ID[6:4]})};


  assign pid3_rdata[31:0] = {24'h000000,
                             ({4{pid3_read_en}} & ecorevnum_i),
                                                   4'h0};


  assign id0_rdata[31:0] = {24'h000000,
                            ({8{id0_read_en}} & 8'h0D)};


  assign id1_rdata[31:0] = {24'h000000,
                            ({8{id1_read_en}} & 8'hF0)};


  assign id2_rdata[31:0] = {24'h000000,
                            ({8{id2_read_en}} & 8'h05)};


  assign id3_rdata[31:0] = {24'h000000,
                             ({8{id3_read_en}} & 8'hB1)};


  assign prdata_o[31:0] = prdata_r[31:0];
  assign pready_o = pready_r;
  assign pslverr_o = 1'b0;

  assign irq_o = irq_r;

  assign reg_clk_req_o = clk_req;

  assign pwr_devactive_st_o[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] = devactive_st_int[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];

  assign pwr_policy_o[3:0] = pwr_policy[3:0];
  assign pwr_dyn_en_o = pwr_dyn_en_r;
  assign devreqen_o[NUM_DEV_LPI-1:0] = devreqen_r[NUM_DEV_LPI-1:0];
  assign pwr_devactiveen_o[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] = pwr_devactiveen_r[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];
  assign warm_rst_devreqen_o = warm_rst_devreqen_r;
  assign off_del_o[7:0] = off_del_r[7:0];
  assign clken_rst_dly_o[CRI_COUNTER_WIDTH-1:0] = CLKEN_RST_DLY_CFG[CRI_COUNTER_WIDTH-1:0];
  assign iso_clken_dly_o[CRI_COUNTER_WIDTH-1:0] = ISO_CLKEN_DLY_CFG[CRI_COUNTER_WIDTH-1:0];
  assign rst_hwstat_dly_o[CRI_COUNTER_WIDTH-1:0] = RST_HWSTAT_DLY_CFG[CRI_COUNTER_WIDTH-1:0];
  assign clken_iso_dly_o[CRI_COUNTER_WIDTH-1:0] = CLKEN_ISO_DLY_CFG[CRI_COUNTER_WIDTH-1:0];
  assign iso_rst_dly_o[CRI_COUNTER_WIDTH-1:0] = ISO_RST_DLY_CFG[CRI_COUNTER_WIDTH-1:0];

  assign pwpr_legal_write_en_o = pwpr_legal_write;
  assign pwpr_nxt_pwr_dyn_en_o = pwdata[8];

  assign flush_req_o = flush_req;

endmodule
