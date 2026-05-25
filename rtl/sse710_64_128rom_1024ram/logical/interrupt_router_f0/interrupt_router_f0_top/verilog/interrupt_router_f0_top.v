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



`ifndef INT_RTR_PARAMS
`include "interrupt_router_f0_params.v"
`endif

`ifndef INT_RTR_UNIT_PARAMS
`include "interrupt_router_f0_unit_params.v"
`endif

module interrupt_router_f0_top
#(

  `SI_DEF_ICI_DST
  `SI_DEF_ICI_EN
  parameter LDE_LVL     = 2,
  parameter MASTER_ID_WIDTH  = 1,
  `INT_RTR_CFG
)

(
  input wire [NUM_SHD_INT-1:0]      SII,

  output wire [NUM_SHD_INT-1:0]      ICI0,
  output wire [NUM_SHD_INT-1:0]      ICI1,
  output wire [NUM_SHD_INT-1:0]      ICI2,
  output wire [NUM_SHD_INT-1:0]      ICI3,

  input  wire                       LOCK_I,

  output wire                       TAMPER_INTERRUPT_O,

  input  wire [MASTER_ID_WIDTH-1:0] MASTER_ID_I,

  input  wire                       PCLK,
  input  wire                       PRESETn,

  input  wire                       PSEL_I,
  input  wire                       PENABLE_I,
  input  wire [11:0]                PADDR_I,
  input  wire                       PWRITE_I,
  input  wire [31:0]                PWDATA_I,
  input  wire [2:0]                 PPROT_I,
  input  wire [3:0]                 PSTRB_I,
  output wire [31:0]                PRDATA_O,
  output wire                       PREADY_O,
  output wire                       PSLVERR_O
);

`include "interrupt_router_f0_addr_map.v"
localparam SECURE_MASTER_ID = 0;


  wire                    tamper_int;
  wire                    int_rtr_tmp_st_vld;
  wire                    int_rtr_tmp_st_ovrflw;
  wire [11:0]             paddr_r_int;
  wire [1:0]              pprot_r_int;
  wire [MASTER_ID_WIDTH-1:0] master_id_r_int;
  wire [1:0]              ld_ctrl_lock_int;
  wire                    shd_int_lctrl_lock_int;
  wire                    global_write_en_int;
  wire                    prdata_en_int;
  wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici0_en_int;
  wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici1_en_int;
  wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici2_en_int;
  wire [NUM_SHD_INT-1:0]  shd_int_cfg_ici3_en_int;

  wire [NUM_ICI-1:0] si_ici_dst_wire [NUM_SHD_INT-1:0];
  wire [NUM_ICI-1:0] si_def_ici_wire [NUM_SHD_INT-1:0];

  assign si_ici_dst_wire[0] = SI0_ICI_DST;
  assign si_ici_dst_wire[1] = SI1_ICI_DST;
  assign si_ici_dst_wire[2] = SI2_ICI_DST;
  assign si_ici_dst_wire[3] = SI3_ICI_DST;
  assign si_ici_dst_wire[4] = SI4_ICI_DST;
  assign si_ici_dst_wire[5] = SI5_ICI_DST;
  assign si_ici_dst_wire[6] = SI6_ICI_DST;
  assign si_ici_dst_wire[7] = SI7_ICI_DST;
  assign si_ici_dst_wire[8] = SI8_ICI_DST;
  assign si_ici_dst_wire[9] = SI9_ICI_DST;
  assign si_ici_dst_wire[10] = SI10_ICI_DST;
  assign si_ici_dst_wire[11] = SI11_ICI_DST;
  assign si_ici_dst_wire[12] = SI12_ICI_DST;
  assign si_ici_dst_wire[13] = SI13_ICI_DST;
  assign si_ici_dst_wire[14] = SI14_ICI_DST;
  assign si_ici_dst_wire[15] = SI15_ICI_DST;
  assign si_ici_dst_wire[16] = SI16_ICI_DST;
  assign si_ici_dst_wire[17] = SI17_ICI_DST;
  assign si_ici_dst_wire[18] = SI18_ICI_DST;
  assign si_ici_dst_wire[19] = SI19_ICI_DST;
  assign si_ici_dst_wire[20] = SI20_ICI_DST;
  assign si_ici_dst_wire[21] = SI21_ICI_DST;
  assign si_ici_dst_wire[22] = SI22_ICI_DST;
  assign si_ici_dst_wire[23] = SI23_ICI_DST;
  assign si_ici_dst_wire[24] = SI24_ICI_DST;
  assign si_ici_dst_wire[25] = SI25_ICI_DST;
  assign si_ici_dst_wire[26] = SI26_ICI_DST;
  assign si_ici_dst_wire[27] = SI27_ICI_DST;
  assign si_ici_dst_wire[28] = SI28_ICI_DST;
  assign si_ici_dst_wire[29] = SI29_ICI_DST;
  assign si_ici_dst_wire[30] = SI30_ICI_DST;
  assign si_ici_dst_wire[31] = SI31_ICI_DST;
  assign si_ici_dst_wire[32] = SI32_ICI_DST;
  assign si_ici_dst_wire[33] = SI33_ICI_DST;
  assign si_ici_dst_wire[34] = SI34_ICI_DST;
  assign si_ici_dst_wire[35] = SI35_ICI_DST;
  assign si_ici_dst_wire[36] = SI36_ICI_DST;
  assign si_ici_dst_wire[37] = SI37_ICI_DST;
  assign si_ici_dst_wire[38] = SI38_ICI_DST;
  assign si_ici_dst_wire[39] = SI39_ICI_DST;
  assign si_ici_dst_wire[40] = SI40_ICI_DST;
  assign si_ici_dst_wire[41] = SI41_ICI_DST;
  assign si_ici_dst_wire[42] = SI42_ICI_DST;
  assign si_ici_dst_wire[43] = SI43_ICI_DST;
  assign si_ici_dst_wire[44] = SI44_ICI_DST;
  assign si_ici_dst_wire[45] = SI45_ICI_DST;
  assign si_ici_dst_wire[46] = SI46_ICI_DST;
  assign si_ici_dst_wire[47] = SI47_ICI_DST;
  assign si_ici_dst_wire[48] = SI48_ICI_DST;
  assign si_ici_dst_wire[49] = SI49_ICI_DST;
  assign si_ici_dst_wire[50] = SI50_ICI_DST;
  assign si_ici_dst_wire[51] = SI51_ICI_DST;
  assign si_ici_dst_wire[52] = SI52_ICI_DST;
  assign si_ici_dst_wire[53] = SI53_ICI_DST;
  assign si_ici_dst_wire[54] = SI54_ICI_DST;
  assign si_ici_dst_wire[55] = SI55_ICI_DST;
  assign si_ici_dst_wire[56] = SI56_ICI_DST;
  assign si_ici_dst_wire[57] = SI57_ICI_DST;
  assign si_ici_dst_wire[58] = SI58_ICI_DST;
  assign si_ici_dst_wire[59] = SI59_ICI_DST;
  assign si_ici_dst_wire[60] = SI60_ICI_DST;
  assign si_ici_dst_wire[61] = SI61_ICI_DST;
  assign si_ici_dst_wire[62] = SI62_ICI_DST;
  assign si_ici_dst_wire[63] = SI63_ICI_DST;
  assign si_ici_dst_wire[64] = SI64_ICI_DST;
  assign si_ici_dst_wire[65] = SI65_ICI_DST;
  assign si_ici_dst_wire[66] = SI66_ICI_DST;
  assign si_ici_dst_wire[67] = SI67_ICI_DST;
  assign si_ici_dst_wire[68] = SI68_ICI_DST;
  assign si_ici_dst_wire[69] = SI69_ICI_DST;
  assign si_ici_dst_wire[70] = SI70_ICI_DST;
  assign si_ici_dst_wire[71] = SI71_ICI_DST;
  assign si_ici_dst_wire[72] = SI72_ICI_DST;
  assign si_ici_dst_wire[73] = SI73_ICI_DST;
  assign si_ici_dst_wire[74] = SI74_ICI_DST;
  assign si_ici_dst_wire[75] = SI75_ICI_DST;
  assign si_ici_dst_wire[76] = SI76_ICI_DST;
  assign si_ici_dst_wire[77] = SI77_ICI_DST;
  assign si_ici_dst_wire[78] = SI78_ICI_DST;
  assign si_ici_dst_wire[79] = SI79_ICI_DST;
  assign si_ici_dst_wire[80] = SI80_ICI_DST;
  assign si_ici_dst_wire[81] = SI81_ICI_DST;
  assign si_ici_dst_wire[82] = SI82_ICI_DST;
  assign si_ici_dst_wire[83] = SI83_ICI_DST;
  assign si_ici_dst_wire[84] = SI84_ICI_DST;
  assign si_ici_dst_wire[85] = SI85_ICI_DST;
  assign si_ici_dst_wire[86] = SI86_ICI_DST;
  assign si_ici_dst_wire[87] = SI87_ICI_DST;
  assign si_ici_dst_wire[88] = SI88_ICI_DST;
  assign si_ici_dst_wire[89] = SI89_ICI_DST;
  assign si_ici_dst_wire[90] = SI90_ICI_DST;
  assign si_ici_dst_wire[91] = SI91_ICI_DST;
  assign si_ici_dst_wire[92] = SI92_ICI_DST;
  assign si_ici_dst_wire[93] = SI93_ICI_DST;
  assign si_ici_dst_wire[94] = SI94_ICI_DST;
  assign si_ici_dst_wire[95] = SI95_ICI_DST;

  assign si_def_ici_wire[0] = SI0_DEF_ICI;
  assign si_def_ici_wire[1] = SI1_DEF_ICI;
  assign si_def_ici_wire[2] = SI2_DEF_ICI;
  assign si_def_ici_wire[3] = SI3_DEF_ICI;
  assign si_def_ici_wire[4] = SI4_DEF_ICI;
  assign si_def_ici_wire[5] = SI5_DEF_ICI;
  assign si_def_ici_wire[6] = SI6_DEF_ICI;
  assign si_def_ici_wire[7] = SI7_DEF_ICI;
  assign si_def_ici_wire[8] = SI8_DEF_ICI;
  assign si_def_ici_wire[9] = SI9_DEF_ICI;
  assign si_def_ici_wire[10] = SI10_DEF_ICI;
  assign si_def_ici_wire[11] = SI11_DEF_ICI;
  assign si_def_ici_wire[12] = SI12_DEF_ICI;
  assign si_def_ici_wire[13] = SI13_DEF_ICI;
  assign si_def_ici_wire[14] = SI14_DEF_ICI;
  assign si_def_ici_wire[15] = SI15_DEF_ICI;
  assign si_def_ici_wire[16] = SI16_DEF_ICI;
  assign si_def_ici_wire[17] = SI17_DEF_ICI;
  assign si_def_ici_wire[18] = SI18_DEF_ICI;
  assign si_def_ici_wire[19] = SI19_DEF_ICI;
  assign si_def_ici_wire[20] = SI20_DEF_ICI;
  assign si_def_ici_wire[21] = SI21_DEF_ICI;
  assign si_def_ici_wire[22] = SI22_DEF_ICI;
  assign si_def_ici_wire[23] = SI23_DEF_ICI;
  assign si_def_ici_wire[24] = SI24_DEF_ICI;
  assign si_def_ici_wire[25] = SI25_DEF_ICI;
  assign si_def_ici_wire[26] = SI26_DEF_ICI;
  assign si_def_ici_wire[27] = SI27_DEF_ICI;
  assign si_def_ici_wire[28] = SI28_DEF_ICI;
  assign si_def_ici_wire[29] = SI29_DEF_ICI;
  assign si_def_ici_wire[30] = SI30_DEF_ICI;
  assign si_def_ici_wire[31] = SI31_DEF_ICI;
  assign si_def_ici_wire[32] = SI32_DEF_ICI;
  assign si_def_ici_wire[33] = SI33_DEF_ICI;
  assign si_def_ici_wire[34] = SI34_DEF_ICI;
  assign si_def_ici_wire[35] = SI35_DEF_ICI;
  assign si_def_ici_wire[36] = SI36_DEF_ICI;
  assign si_def_ici_wire[37] = SI37_DEF_ICI;
  assign si_def_ici_wire[38] = SI38_DEF_ICI;
  assign si_def_ici_wire[39] = SI39_DEF_ICI;
  assign si_def_ici_wire[40] = SI40_DEF_ICI;
  assign si_def_ici_wire[41] = SI41_DEF_ICI;
  assign si_def_ici_wire[42] = SI42_DEF_ICI;
  assign si_def_ici_wire[43] = SI43_DEF_ICI;
  assign si_def_ici_wire[44] = SI44_DEF_ICI;
  assign si_def_ici_wire[45] = SI45_DEF_ICI;
  assign si_def_ici_wire[46] = SI46_DEF_ICI;
  assign si_def_ici_wire[47] = SI47_DEF_ICI;
  assign si_def_ici_wire[48] = SI48_DEF_ICI;
  assign si_def_ici_wire[49] = SI49_DEF_ICI;
  assign si_def_ici_wire[50] = SI50_DEF_ICI;
  assign si_def_ici_wire[51] = SI51_DEF_ICI;
  assign si_def_ici_wire[52] = SI52_DEF_ICI;
  assign si_def_ici_wire[53] = SI53_DEF_ICI;
  assign si_def_ici_wire[54] = SI54_DEF_ICI;
  assign si_def_ici_wire[55] = SI55_DEF_ICI;
  assign si_def_ici_wire[56] = SI56_DEF_ICI;
  assign si_def_ici_wire[57] = SI57_DEF_ICI;
  assign si_def_ici_wire[58] = SI58_DEF_ICI;
  assign si_def_ici_wire[59] = SI59_DEF_ICI;
  assign si_def_ici_wire[60] = SI60_DEF_ICI;
  assign si_def_ici_wire[61] = SI61_DEF_ICI;
  assign si_def_ici_wire[62] = SI62_DEF_ICI;
  assign si_def_ici_wire[63] = SI63_DEF_ICI;
  assign si_def_ici_wire[64] = SI64_DEF_ICI;
  assign si_def_ici_wire[65] = SI65_DEF_ICI;
  assign si_def_ici_wire[66] = SI66_DEF_ICI;
  assign si_def_ici_wire[67] = SI67_DEF_ICI;
  assign si_def_ici_wire[68] = SI68_DEF_ICI;
  assign si_def_ici_wire[69] = SI69_DEF_ICI;
  assign si_def_ici_wire[70] = SI70_DEF_ICI;
  assign si_def_ici_wire[71] = SI71_DEF_ICI;
  assign si_def_ici_wire[72] = SI72_DEF_ICI;
  assign si_def_ici_wire[73] = SI73_DEF_ICI;
  assign si_def_ici_wire[74] = SI74_DEF_ICI;
  assign si_def_ici_wire[75] = SI75_DEF_ICI;
  assign si_def_ici_wire[76] = SI76_DEF_ICI;
  assign si_def_ici_wire[77] = SI77_DEF_ICI;
  assign si_def_ici_wire[78] = SI78_DEF_ICI;
  assign si_def_ici_wire[79] = SI79_DEF_ICI;
  assign si_def_ici_wire[80] = SI80_DEF_ICI;
  assign si_def_ici_wire[81] = SI81_DEF_ICI;
  assign si_def_ici_wire[82] = SI82_DEF_ICI;
  assign si_def_ici_wire[83] = SI83_DEF_ICI;
  assign si_def_ici_wire[84] = SI84_DEF_ICI;
  assign si_def_ici_wire[85] = SI85_DEF_ICI;
  assign si_def_ici_wire[86] = SI86_DEF_ICI;
  assign si_def_ici_wire[87] = SI87_DEF_ICI;
  assign si_def_ici_wire[88] = SI88_DEF_ICI;
  assign si_def_ici_wire[89] = SI89_DEF_ICI;
  assign si_def_ici_wire[90] = SI90_DEF_ICI;
  assign si_def_ici_wire[91] = SI91_DEF_ICI;
  assign si_def_ici_wire[92] = SI92_DEF_ICI;
  assign si_def_ici_wire[93] = SI93_DEF_ICI;
  assign si_def_ici_wire[94] = SI94_DEF_ICI;
  assign si_def_ici_wire[95] = SI95_DEF_ICI;

interrupt_router_f0_reg_bank #(

  `INT_RTR_ADDR_MAP_OVERRIDE
  .NUM_SHD_INT      (NUM_SHD_INT),
  .LDE_LVL          (LDE_LVL),
  .NUM_ICI          (NUM_ICI),
  .SECURE_MASTER_ID (SECURE_MASTER_ID),
  .MASTER_ID_WIDTH  (MASTER_ID_WIDTH)


)
u_interrupt_router_reg_bank
(
  `ICI_DST_OVERRIDE_fix
  `DEF_ICI_OVERRIDE_fix
  .pclk                       (PCLK),
  .presetn                    (PRESETn),
  .psel_i                     (PSEL_I),
  .pprot_i                    (PPROT_I),
  .pstrb_i                    (PSTRB_I),
  .penable_i                  (PENABLE_I),
  .paddr_i                    (PADDR_I),
  .pwrite_i                   (PWRITE_I),
  .pwdata_i                   (PWDATA_I),
  .prdata_o                   (PRDATA_O),
  .pready_o                   (PREADY_O),
  .pslverr_o                  (PSLVERR_O),
  .lock_i                     (LOCK_I),
  .tamper_i                   (tamper_int),

  .master_id_i                (MASTER_ID_I),

  .paddr_r_o                  (paddr_r_int),
  .pprot_r_o                  (pprot_r_int),
  .master_id_r_o              (master_id_r_int),
  .ld_ctrl_lock_o             (ld_ctrl_lock_int),
  .shd_int_lctrl_lock_o       (shd_int_lctrl_lock_int),

  .int_rtr_tmp_st_vld_o       (int_rtr_tmp_st_vld),
  .int_rtr_tmp_st_ovrflw_o    (int_rtr_tmp_st_ovrflw),

  .shd_int_cfg_ici0_en_o      (shd_int_cfg_ici0_en_int),
  .shd_int_cfg_ici1_en_o      (shd_int_cfg_ici1_en_int),
  .shd_int_cfg_ici2_en_o      (shd_int_cfg_ici2_en_int),
  .shd_int_cfg_ici3_en_o      (shd_int_cfg_ici3_en_int),
  .prdata_en_o                (prdata_en_int),
  .global_write_en_o          (global_write_en_int)

);

arm_element_std_or2 u_tamper_interrupt_or2 (.A (int_rtr_tmp_st_vld), .B (int_rtr_tmp_st_ovrflw), .Y (TAMPER_INTERRUPT_O));

interrupt_router_f0_tamper_logic_async #(
.SHD_INT_CFG      (SHD_INT_CFG),
.SHD_INT_LCTRL    (SHD_INT_LCTRL),
.INT_RTR_TMP_ST   (INT_RTR_TMP_ST),
.LD_CTRL          (LD_CTRL),
.MASTER_ID_WIDTH  (MASTER_ID_WIDTH),
.SECURE_MASTER_ID (SECURE_MASTER_ID),
.LDE_LVL          (LDE_LVL)
)
u_interrupt_router_tamper
(
  .paddr_r_i                (paddr_r_int),
  .ld_ctrl_ldi_st           (LOCK_I),
  .ld_ctrl_lock             (ld_ctrl_lock_int),
  .shd_int_lctrl_lock       (shd_int_lctrl_lock_int),
  .prdata_en                (prdata_en_int),
  .global_write_en          (global_write_en_int),
  .pprot_r_i                (pprot_r_int),
  .master_id_i              (master_id_r_int),
  .tamper_o                 (tamper_int)
);

interrupt_router_f0_core_logic_async #(
  .NUM_SHD_INT  (NUM_SHD_INT),
  .NUM_ICI      (NUM_ICI)
)
u_interrupt_router_logic
(
  `ICI_DST_OVERRIDE_fix
  .shd_int_cfg_ici0_en_in         (shd_int_cfg_ici0_en_int),
  .interrupt_controller_output_0  (ICI0),
  .shd_int_cfg_ici1_en_in         (shd_int_cfg_ici1_en_int),
  .interrupt_controller_output_1  (ICI1),
  .shd_int_cfg_ici2_en_in         (shd_int_cfg_ici2_en_int),
  .interrupt_controller_output_2  (ICI2),
  .shd_int_cfg_ici3_en_in         (shd_int_cfg_ici3_en_int),
  .interrupt_controller_output_3  (ICI3),
  .shared_interrupt_input         (SII)
);

endmodule

`ifdef INT_RTR_PARAMS
`include "interrupt_router_f0_undefs.v"
`endif


