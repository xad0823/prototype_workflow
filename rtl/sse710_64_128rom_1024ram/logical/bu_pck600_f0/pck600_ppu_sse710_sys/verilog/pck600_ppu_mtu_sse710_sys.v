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

module pck600_ppu_mtu_sse710_sys
#(
  parameter DEF_PWR_POLICY = 4'h0,
  parameter NUM_PWR_DEVACTIVE = 11,
  parameter DEVACTIVE_LSB = 1,
  parameter DYN_WRM_RST_SPT_CFG = 1'b0,
  parameter DYN_ON_SPT_CFG = 1'b1,
  parameter DYN_FUNC_RET_SPT_CFG = 1'b1,
  parameter DYN_FULL_RET_SPT_CFG = 1'b0,
  parameter DYN_MEM_OFF_SPT_CFG = 1'b0,
  parameter DYN_LGC_RET_SPT_CFG = 1'b0,
  parameter DYN_MEM_RET_EMU_SPT_CFG = 1'b0,
  parameter DYN_MEM_RET_SPT_CFG = 1'b1,
  parameter DYN_OFF_EMU_SPT_CFG = 1'b0,
  parameter DYN_OFF_SPT_CFG = 1'b1,
  parameter STA_DBG_RECOV_SPT_CFG = 1'b0,
  parameter STA_FUNC_RET_SPT_CFG = 1'b1,
  parameter STA_FULL_RET_SPT_CFG = 1'b0,
  parameter STA_MEM_OFF_SPT_CFG = 1'b0,
  parameter STA_LGC_RET_SPT_CFG = 1'b0,
  parameter STA_MEM_RET_EMU_SPT_CFG = 1'b0,
  parameter STA_MEM_RET_SPT_CFG = 1'b1,
  parameter STA_OFF_EMU_SPT_CFG = 1'b0,
  parameter TRANS_PATH_WIDTH = 5
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //Toplevel Signals
  input wire [NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] pwr_devactive_i,

  //Register Interface
  input wire [3:0]            pwr_policy_i,
  input wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactiveen_i,
  input wire                  warm_rst_devreqen_i,
  input wire [7:0]            off_del_i,
  input wire [7:0]            mem_ret_del_i,
  input wire [7:0]            func_ret_del_i,
  input wire                  flush_req_i,

  //Transition Control
  output wire                 trans_start_req_o,
  output wire [TRANS_PATH_WIDTH-1:0] trans_path_o,
  output wire [3:0]           trans_target_pwr_mode_o,
  output wire                 trans_init_o,
  input wire                  trans_comp_i,

  //PSM Interface
  input wire [3:0]            pwr_st_i,
  input wire                  pwr_dyn_st_i,

  //Initialization for PPU
  input wire                  pcsm_mode_stat_pwr_i,
  output wire                 sample_pcsm_mode_stat_o,
  output wire                 apb_stall_o,
  output wire                 pwpr_init_o,
  output wire [3:0]           pwr_policy_init_o,

  //Clock Control
  output wire                 mtu_clk_req_o,
  input wire                  clk_enable_i

);

  `include "pck600_ppu_enum_sse710_sys.v"

  localparam STA_MODES_EN = {STA_DBG_RECOV_SPT_CFG[0],
                             1'b1,
                             1'b1,
                             STA_FUNC_RET_SPT_CFG[0],
                             STA_MEM_OFF_SPT_CFG[0],
                             STA_FULL_RET_SPT_CFG[0],
                             STA_LGC_RET_SPT_CFG[0],
                             STA_MEM_RET_EMU_SPT_CFG[0],
                             STA_MEM_RET_SPT_CFG[0],
                             STA_OFF_EMU_SPT_CFG[0],
                             1'b1};
  localparam DYN_MODES_EN = {1'b0,
                             DYN_WRM_RST_SPT_CFG[0],
                             DYN_ON_SPT_CFG[0],
                             DYN_FUNC_RET_SPT_CFG[0],
                             DYN_MEM_OFF_SPT_CFG[0],
                             DYN_FULL_RET_SPT_CFG[0],
                             DYN_LGC_RET_SPT_CFG[0],
                             DYN_MEM_RET_EMU_SPT_CFG[0],
                             DYN_MEM_RET_SPT_CFG[0],
                             DYN_OFF_EMU_SPT_CFG[0],
                             DYN_OFF_SPT_CFG[0]};


localparam SM_SAMPLE_PCSM_MODE_STAT = 2'b00;
localparam SM_PWPR_INIT = 2'b01;
localparam SM_TRANS_INIT = 2'b10;
localparam SM_FINAL = 2'b11;


  reg [1:0]                   state;
  reg [1:0]                   nxt_state;
  reg                         state_en;
  reg                         sample_pcsm_mode_stat;
  reg                         apb_stall;
  reg                         pwpr_init;
  reg                         init_trans_start_pwr;
  reg                         init_comp;
  reg [TRANS_PATH_WIDTH-1:0]  ppu_init_trans_path;

  reg [3:0]                   pwr_policy_init;

  reg                         trans_pwr_req_r;
  reg [TRANS_PATH_WIDTH-1:0]  trans_path_r;
  reg [3:0]                   trans_target_pwr_mode_r;

  wire                        nxt_trans_pwr_req_r;
  wire [TRANS_PATH_WIDTH-1:0] nxt_trans_path_r;
  wire [3:0]                  nxt_trans_target_pwr_mode_r;

  wire                        pipeline_en;
  wire                        pipeline_flush;

  wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactive_req;
  reg [NUM_PWR_DEVACTIVE-1:1] enable_modes_mask;
  wire [NUM_PWR_DEVACTIVE-1:1] pwr_devactive_mask_req;
  reg [3:0]                   pwr_dev_req;

  reg                         pwr_trans_req;
  reg [TRANS_PATH_WIDTH-1:0]  pwr_trans_path;
  reg [3:0]                   pwr_trans_target_mode;


  reg [7:0]                   pwr_mode_entry_delay_r;
  reg [7:0]                   nxt_pwr_mode_entry_delay_r;
  wire                        pwr_mode_entry_delay_en;

  wire                        pwr_mode_entry_delay_load;
  wire                        pwr_mode_entry_delay_dec;
  reg [7:0]                   pwr_mode_entry_delay_load_value;

  wire                        pwr_mode_entry_delay_expired;

  reg [3:0]                   prev_pwr_trans_target_mode_r;

  wire                        target_mode_match;

  wire                        trans_requires_entry_delay;
  wire [TRANS_PATH_WIDTH-1:0] pwr_trans_path_mask;
  wire [3:0]                  pwr_trans_target_mode_mask;


  wire                        trans_req;

  reg                         mtu_clk_req_r;
  wire                        nxt_mtu_clk_req_r;
  wire                        mtu_clk_req;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[1:0] <= SM_SAMPLE_PCSM_MODE_STAT;
    end
    else if(state_en)
    begin
      state[1:0] <= nxt_state[1:0];
    end
  end

  always@*
  begin
    case(state[1:0])
    SM_SAMPLE_PCSM_MODE_STAT:
    begin
      nxt_state[1:0] = SM_PWPR_INIT;
      state_en = clk_enable_i;
      sample_pcsm_mode_stat = 1'b1;
      apb_stall = 1'b1;
      pwpr_init = 1'b0;
      init_trans_start_pwr = 1'b0;
      init_comp = 1'b0;
      pwr_policy_init[3:0] = DEF_PWR_POLICY;
      ppu_init_trans_path[TRANS_PATH_WIDTH-1:0] = UPDATE_ST;
    end
    SM_PWPR_INIT:
    begin
      nxt_state[1:0] = SM_TRANS_INIT;
      state_en = clk_enable_i;
      sample_pcsm_mode_stat = 1'b0;
      apb_stall = 1'b1;
      pwpr_init = 1'b1;
      init_trans_start_pwr = 1'b0;
      init_comp = 1'b0;
      pwr_policy_init[3:0] = (pcsm_mode_stat_pwr_i)? P_MEM_RET:P_OFF;
      ppu_init_trans_path[TRANS_PATH_WIDTH-1:0] = UPDATE_ST;
    end
    SM_TRANS_INIT:
    begin
      nxt_state[1:0] = SM_FINAL;
      state_en = trans_comp_i;
      sample_pcsm_mode_stat = 1'b0;
      apb_stall = 1'b0;
      pwpr_init = 1'b0;
      init_trans_start_pwr = 1'b1;
      init_comp = 1'b0;
      pwr_policy_init[3:0] = (pcsm_mode_stat_pwr_i)? P_MEM_RET:P_OFF;
      ppu_init_trans_path[TRANS_PATH_WIDTH-1:0] = (pcsm_mode_stat_pwr_i)? UPDATE_ST:PCSM_ONLY;
    end
    SM_FINAL:
    begin
      nxt_state[1:0] = SM_FINAL;
      state_en = 1'b0;
      sample_pcsm_mode_stat = 1'b0;
      apb_stall = 1'b0;
      pwpr_init = 1'b0;
      init_trans_start_pwr = 1'b0;
      init_comp = 1'b1;
      pwr_policy_init[3:0] = DEF_PWR_POLICY;
      ppu_init_trans_path[TRANS_PATH_WIDTH-1:0] = UPDATE_ST;
    end
    default:
    begin
      nxt_state[1:0] = 2'bxx;
      state_en = 1'bx;
      sample_pcsm_mode_stat = 1'bx;
      apb_stall = 1'bx;
      pwpr_init = 1'bx;
      init_trans_start_pwr = 1'bx;
      init_comp = 1'bx;
      pwr_policy_init[3:0] = 4'hx;
      ppu_init_trans_path[TRANS_PATH_WIDTH-1:0] = {TRANS_PATH_WIDTH{1'bx}};
    end
    endcase
  end



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      trans_pwr_req_r <= 1'b0;
      trans_path_r[TRANS_PATH_WIDTH-1:0] <= {TRANS_PATH_WIDTH{1'b0}};
      trans_target_pwr_mode_r[3:0] <= P_OFF;
    end
    else if(pipeline_en)
    begin
      trans_pwr_req_r <= nxt_trans_pwr_req_r;
      trans_path_r[TRANS_PATH_WIDTH-1:0] <= nxt_trans_path_r[TRANS_PATH_WIDTH-1:0];
      trans_target_pwr_mode_r[3:0] <= nxt_trans_target_pwr_mode_r[3:0];
    end
  end

  assign nxt_trans_pwr_req_r = pwr_trans_req & pwr_mode_entry_delay_expired & ~pipeline_flush;
  assign nxt_trans_path_r[TRANS_PATH_WIDTH-1:0] = pwr_trans_path[TRANS_PATH_WIDTH-1:0];
  assign nxt_trans_target_pwr_mode_r[3:0] = pwr_trans_target_mode[3:0];

  assign trans_req = trans_pwr_req_r;


  assign pipeline_en = (~trans_req | pipeline_flush) & clk_enable_i & init_comp;

  assign pipeline_flush = (flush_req_i & (~trans_req & init_comp)) | trans_comp_i;



  assign pwr_devactive_req[NUM_PWR_DEVACTIVE-1:1] = pwr_devactive_i[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB] & pwr_devactiveen_i[NUM_PWR_DEVACTIVE-1:DEVACTIVE_LSB];

  always@*
  begin
    case({pwr_dyn_st_i,pwr_st_i[3:0]})
    {1'b0,P_OFF}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = STA_MODES_EN[10:1];
    end
    {1'b0,P_MEM_RET}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {STA_MODES_EN[10:3],2'b11};
    end
    {1'b0,P_FUNC_RET}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {STA_MODES_EN[10:8],7'h7F};
    end
    {1'b0,P_ON}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {STA_MODES_EN[10:9],8'hFF};
    end
    {1'b0,P_WRM_RST}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {STA_MODES_EN[10],9'h1FF};
    end
    {1'b1,P_OFF}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = DYN_MODES_EN[10:1];
    end
    {1'b1,P_MEM_RET}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {DYN_MODES_EN[10:3],2'b11};
    end
    {1'b1,P_FUNC_RET}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {DYN_MODES_EN[10:8],7'h7F};
    end
    {1'b1,P_ON}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {DYN_MODES_EN[10:9],8'hFF};
    end
    {1'b1,P_WRM_RST}:
    begin
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {DYN_MODES_EN[10],9'h1FF};
    end
    default:
    begin
      //X-Prop
      enable_modes_mask[NUM_PWR_DEVACTIVE-1:1] = {(NUM_PWR_DEVACTIVE-1){1'bx}};
    end
    endcase
  end

  assign pwr_devactive_mask_req[NUM_PWR_DEVACTIVE-1:1] = pwr_devactive_req[NUM_PWR_DEVACTIVE-1:1] & enable_modes_mask[NUM_PWR_DEVACTIVE-1:1];

  //Convert mutli-hot pwr_devactive_req to correct power mode request
  //Enable mask will make sure that PACTIVE for DBG_RECOV is always 0
  //as the mode is not enabled
  always@*
  begin
    case(pwr_devactive_mask_req[NUM_PWR_DEVACTIVE-1:1])
    10'h000:
    begin
      //Device request P_OFF
      pwr_dev_req[3:0] = P_OFF;
    end
    10'h001:
    begin
      //Device request P_OFF_EMU
      pwr_dev_req[3:0] = P_OFF_EMU;
    end
    10'h002,10'h003:
    begin
      //Device request P_MEM_RET
      pwr_dev_req[3:0] = P_MEM_RET;
    end
    10'h004,10'h005,10'h006,10'h007:
    begin
      //Device request P_MEM_RET_EMU
      pwr_dev_req[3:0] = P_MEM_RET_EMU;
    end
    10'h008,10'h009,10'h00A,10'h00B,10'h00C,10'h00D,10'h00E,10'h00F:
    begin
      //Device request P_LGC_RET
      pwr_dev_req[3:0] = P_LGC_RET;
    end
    10'h010,10'h011,10'h012,10'h013,10'h014,10'h015,10'h016,10'h017,
    10'h018,10'h019,10'h01A,10'h01B,10'h01C,10'h01D,10'h01E,10'h01F:
    begin
      //Device request P_FULL_RET
      pwr_dev_req[3:0] = P_FULL_RET;
    end
    10'h020,10'h021,10'h022,10'h023,10'h024,10'h025,10'h026,10'h027,
    10'h028,10'h029,10'h02A,10'h02B,10'h02C,10'h02D,10'h02E,10'h02F,
    10'h030,10'h031,10'h032,10'h033,10'h034,10'h035,10'h036,10'h037,
    10'h038,10'h039,10'h03A,10'h03B,10'h03C,10'h03D,10'h03E,10'h03F:
    begin
      //Device request P_MEM_OFF
      pwr_dev_req[3:0] = P_MEM_OFF;
    end
    10'h040,10'h041,10'h042,10'h043,10'h044,10'h045,10'h046,10'h047,
    10'h048,10'h049,10'h04A,10'h04B,10'h04C,10'h04D,10'h04E,10'h04F,
    10'h050,10'h051,10'h052,10'h053,10'h054,10'h055,10'h056,10'h057,
    10'h058,10'h059,10'h05A,10'h05B,10'h05C,10'h05D,10'h05E,10'h05F,
    10'h060,10'h061,10'h062,10'h063,10'h064,10'h065,10'h066,10'h067,
    10'h068,10'h069,10'h06A,10'h06B,10'h06C,10'h06D,10'h06E,10'h06F,
    10'h070,10'h071,10'h072,10'h073,10'h074,10'h075,10'h076,10'h077,
    10'h078,10'h079,10'h07A,10'h07B,10'h07C,10'h07D,10'h07E,10'h07F:
    begin
      //Device request P_FUNC_RET
      pwr_dev_req[3:0] = P_FUNC_RET;
    end
    10'h080,10'h081,10'h082,10'h083,10'h084,10'h085,10'h086,10'h087,
    10'h088,10'h089,10'h08A,10'h08B,10'h08C,10'h08D,10'h08E,10'h08F,
    10'h090,10'h091,10'h092,10'h093,10'h094,10'h095,10'h096,10'h097,
    10'h098,10'h099,10'h09A,10'h09B,10'h09C,10'h09D,10'h09E,10'h09F,
    10'h0A0,10'h0A1,10'h0A2,10'h0A3,10'h0A4,10'h0A5,10'h0A6,10'h0A7,
    10'h0A8,10'h0A9,10'h0AA,10'h0AB,10'h0AC,10'h0AD,10'h0AE,10'h0AF,
    10'h0B0,10'h0B1,10'h0B2,10'h0B3,10'h0B4,10'h0B5,10'h0B6,10'h0B7,
    10'h0B8,10'h0B9,10'h0BA,10'h0BB,10'h0BC,10'h0BD,10'h0BE,10'h0BF,
    10'h0C0,10'h0C1,10'h0C2,10'h0C3,10'h0C4,10'h0C5,10'h0C6,10'h0C7,
    10'h0C8,10'h0C9,10'h0CA,10'h0CB,10'h0CC,10'h0CD,10'h0CE,10'h0CF,
    10'h0D0,10'h0D1,10'h0D2,10'h0D3,10'h0D4,10'h0D5,10'h0D6,10'h0D7,
    10'h0D8,10'h0D9,10'h0DA,10'h0DB,10'h0DC,10'h0DD,10'h0DE,10'h0DF,
    10'h0E0,10'h0E1,10'h0E2,10'h0E3,10'h0E4,10'h0E5,10'h0E6,10'h0E7,
    10'h0E8,10'h0E9,10'h0EA,10'h0EB,10'h0EC,10'h0ED,10'h0EE,10'h0EF,
    10'h0F0,10'h0F1,10'h0F2,10'h0F3,10'h0F4,10'h0F5,10'h0F6,10'h0F7,
    10'h0F8,10'h0F9,10'h0FA,10'h0FB,10'h0FC,10'h0FD,10'h0FE,10'h0FF:
    begin
      //Device request P_ON
      pwr_dev_req[3:0] = P_ON;
    end
    10'h100,10'h101,10'h102,10'h103,10'h104,10'h105,10'h106,10'h107,
    10'h108,10'h109,10'h10A,10'h10B,10'h10C,10'h10D,10'h10E,10'h10F,
    10'h110,10'h111,10'h112,10'h113,10'h114,10'h115,10'h116,10'h117,
    10'h118,10'h119,10'h11A,10'h11B,10'h11C,10'h11D,10'h11E,10'h11F,
    10'h120,10'h121,10'h122,10'h123,10'h124,10'h125,10'h126,10'h127,
    10'h128,10'h129,10'h12A,10'h12B,10'h12C,10'h12D,10'h12E,10'h12F,
    10'h130,10'h131,10'h132,10'h133,10'h134,10'h135,10'h136,10'h137,
    10'h138,10'h139,10'h13A,10'h13B,10'h13C,10'h13D,10'h13E,10'h13F,
    10'h140,10'h141,10'h142,10'h143,10'h144,10'h145,10'h146,10'h147,
    10'h148,10'h149,10'h14A,10'h14B,10'h14C,10'h14D,10'h14E,10'h14F,
    10'h150,10'h151,10'h152,10'h153,10'h154,10'h155,10'h156,10'h157,
    10'h158,10'h159,10'h15A,10'h15B,10'h15C,10'h15D,10'h15E,10'h15F,
    10'h160,10'h161,10'h162,10'h163,10'h164,10'h165,10'h166,10'h167,
    10'h168,10'h169,10'h16A,10'h16B,10'h16C,10'h16D,10'h16E,10'h16F,
    10'h170,10'h171,10'h172,10'h173,10'h174,10'h175,10'h176,10'h177,
    10'h178,10'h179,10'h17A,10'h17B,10'h17C,10'h17D,10'h17E,10'h17F,
    10'h180,10'h181,10'h182,10'h183,10'h184,10'h185,10'h186,10'h187,
    10'h188,10'h189,10'h18A,10'h18B,10'h18C,10'h18D,10'h18E,10'h18F,
    10'h190,10'h191,10'h192,10'h193,10'h194,10'h195,10'h196,10'h197,
    10'h198,10'h199,10'h19A,10'h19B,10'h19C,10'h19D,10'h19E,10'h19F,
    10'h1A0,10'h1A1,10'h1A2,10'h1A3,10'h1A4,10'h1A5,10'h1A6,10'h1A7,
    10'h1A8,10'h1A9,10'h1AA,10'h1AB,10'h1AC,10'h1AD,10'h1AE,10'h1AF,
    10'h1B0,10'h1B1,10'h1B2,10'h1B3,10'h1B4,10'h1B5,10'h1B6,10'h1B7,
    10'h1B8,10'h1B9,10'h1BA,10'h1BB,10'h1BC,10'h1BD,10'h1BE,10'h1BF,
    10'h1C0,10'h1C1,10'h1C2,10'h1C3,10'h1C4,10'h1C5,10'h1C6,10'h1C7,
    10'h1C8,10'h1C9,10'h1CA,10'h1CB,10'h1CC,10'h1CD,10'h1CE,10'h1CF,
    10'h1D0,10'h1D1,10'h1D2,10'h1D3,10'h1D4,10'h1D5,10'h1D6,10'h1D7,
    10'h1D8,10'h1D9,10'h1DA,10'h1DB,10'h1DC,10'h1DD,10'h1DE,10'h1DF,
    10'h1E0,10'h1E1,10'h1E2,10'h1E3,10'h1E4,10'h1E5,10'h1E6,10'h1E7,
    10'h1E8,10'h1E9,10'h1EA,10'h1EB,10'h1EC,10'h1ED,10'h1EE,10'h1EF,
    10'h1F0,10'h1F1,10'h1F2,10'h1F3,10'h1F4,10'h1F5,10'h1F6,10'h1F7,
    10'h1F8,10'h1F9,10'h1FA,10'h1FB,10'h1FC,10'h1FD,10'h1FE,10'h1FF:
    begin
      //Device request P_WRM_RST
      pwr_dev_req[3:0] = P_WRM_RST;
    end
    default:
    begin
      //X-Prop
      pwr_dev_req[3:0] = 4'hx;
    end
    endcase
  end


  //Calculates from the PWR_ST, PWR_POLICY, PWR_DYN_ST and Device request:
  //-If a transition is required
  //-The transition path used to transition between PWR_ST and the target Power mode
  //-The target Power mode
  always@*
  begin
    case({pwr_dyn_st_i,pwr_st_i[3:0],pwr_policy_i[3:0],pwr_dev_req[3:0]})
    {1'b0,P_OFF,P_OFF,P_OFF},{1'b1,P_OFF,P_OFF,P_OFF},
    {1'b0,P_OFF,P_OFF,P_MEM_RET},{1'b0,P_OFF,P_OFF,P_FUNC_RET},
    {1'b0,P_OFF,P_OFF,P_ON},{1'b0,P_OFF,P_OFF,P_WRM_RST},
    {1'b1,P_OFF,P_WRM_RST,P_OFF},{1'b1,P_OFF,P_WRM_RST,P_MEM_RET},
    {1'b1,P_OFF,P_WRM_RST,P_FUNC_RET},{1'b1,P_OFF,P_WRM_RST,P_ON},
    {1'b0,P_MEM_RET,P_OFF,P_OFF_EMU},{1'b1,P_MEM_RET,P_OFF,P_OFF_EMU},
    {1'b0,P_MEM_RET,P_OFF,P_MEM_RET},{1'b1,P_MEM_RET,P_OFF,P_MEM_RET},
    {1'b0,P_MEM_RET,P_OFF,P_FUNC_RET},{1'b0,P_MEM_RET,P_OFF,P_ON},
    {1'b0,P_MEM_RET,P_OFF,P_WRM_RST},{1'b0,P_MEM_RET,P_MEM_RET,P_OFF},
    {1'b1,P_MEM_RET,P_MEM_RET,P_OFF},{1'b0,P_MEM_RET,P_MEM_RET,P_OFF_EMU},
    {1'b1,P_MEM_RET,P_MEM_RET,P_OFF_EMU},{1'b0,P_MEM_RET,P_MEM_RET,P_MEM_RET},
    {1'b1,P_MEM_RET,P_MEM_RET,P_MEM_RET},{1'b0,P_MEM_RET,P_MEM_RET,P_FUNC_RET},
    {1'b0,P_MEM_RET,P_MEM_RET,P_ON},{1'b0,P_MEM_RET,P_MEM_RET,P_WRM_RST},
    {1'b1,P_MEM_RET,P_WRM_RST,P_OFF},{1'b1,P_MEM_RET,P_WRM_RST,P_OFF_EMU},
    {1'b1,P_MEM_RET,P_WRM_RST,P_MEM_RET},{1'b1,P_MEM_RET,P_WRM_RST,P_FUNC_RET},
    {1'b1,P_MEM_RET,P_WRM_RST,P_ON},{1'b0,P_FUNC_RET,P_OFF,P_OFF_EMU},
    {1'b0,P_FUNC_RET,P_OFF,P_MEM_RET},{1'b0,P_FUNC_RET,P_OFF,P_MEM_RET_EMU},
    {1'b1,P_FUNC_RET,P_OFF,P_MEM_RET_EMU},{1'b0,P_FUNC_RET,P_OFF,P_LGC_RET},
    {1'b1,P_FUNC_RET,P_OFF,P_LGC_RET},{1'b0,P_FUNC_RET,P_OFF,P_FULL_RET},
    {1'b1,P_FUNC_RET,P_OFF,P_FULL_RET},{1'b0,P_FUNC_RET,P_OFF,P_MEM_OFF},
    {1'b1,P_FUNC_RET,P_OFF,P_MEM_OFF},{1'b0,P_FUNC_RET,P_OFF,P_FUNC_RET},
    {1'b1,P_FUNC_RET,P_OFF,P_FUNC_RET},{1'b0,P_FUNC_RET,P_OFF,P_ON},
    {1'b0,P_FUNC_RET,P_OFF,P_WRM_RST},{1'b0,P_FUNC_RET,P_MEM_RET,P_MEM_RET_EMU},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_MEM_RET_EMU},{1'b0,P_FUNC_RET,P_MEM_RET,P_LGC_RET},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_LGC_RET},{1'b0,P_FUNC_RET,P_MEM_RET,P_FULL_RET},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_FULL_RET},{1'b0,P_FUNC_RET,P_MEM_RET,P_MEM_OFF},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_MEM_OFF},{1'b0,P_FUNC_RET,P_MEM_RET,P_FUNC_RET},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_FUNC_RET},{1'b0,P_FUNC_RET,P_MEM_RET,P_ON},
    {1'b0,P_FUNC_RET,P_MEM_RET,P_WRM_RST},{1'b0,P_FUNC_RET,P_FUNC_RET,P_OFF},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_OFF},{1'b0,P_FUNC_RET,P_FUNC_RET,P_OFF_EMU},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_OFF_EMU},{1'b0,P_FUNC_RET,P_FUNC_RET,P_MEM_RET},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_MEM_RET},{1'b0,P_FUNC_RET,P_FUNC_RET,P_MEM_RET_EMU},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_MEM_RET_EMU},{1'b0,P_FUNC_RET,P_FUNC_RET,P_LGC_RET},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_LGC_RET},{1'b0,P_FUNC_RET,P_FUNC_RET,P_FULL_RET},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_FULL_RET},{1'b0,P_FUNC_RET,P_FUNC_RET,P_MEM_OFF},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_MEM_OFF},{1'b0,P_FUNC_RET,P_FUNC_RET,P_FUNC_RET},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_FUNC_RET},{1'b0,P_FUNC_RET,P_FUNC_RET,P_ON},
    {1'b0,P_FUNC_RET,P_FUNC_RET,P_WRM_RST},{1'b1,P_FUNC_RET,P_WRM_RST,P_OFF},
    {1'b1,P_FUNC_RET,P_WRM_RST,P_OFF_EMU},{1'b1,P_FUNC_RET,P_WRM_RST,P_MEM_RET},
    {1'b1,P_FUNC_RET,P_WRM_RST,P_MEM_RET_EMU},{1'b1,P_FUNC_RET,P_WRM_RST,P_LGC_RET},
    {1'b1,P_FUNC_RET,P_WRM_RST,P_FULL_RET},{1'b1,P_FUNC_RET,P_WRM_RST,P_MEM_OFF},
    {1'b1,P_FUNC_RET,P_WRM_RST,P_FUNC_RET},{1'b1,P_FUNC_RET,P_WRM_RST,P_ON},
    {1'b0,P_ON,P_OFF,P_OFF_EMU},{1'b0,P_ON,P_OFF,P_MEM_RET},
    {1'b0,P_ON,P_OFF,P_MEM_RET_EMU},{1'b0,P_ON,P_OFF,P_LGC_RET},
    {1'b0,P_ON,P_OFF,P_FULL_RET},{1'b0,P_ON,P_OFF,P_MEM_OFF},
    {1'b0,P_ON,P_OFF,P_FUNC_RET},{1'b0,P_ON,P_OFF,P_ON},
    {1'b1,P_ON,P_OFF,P_ON},{1'b0,P_ON,P_OFF,P_WRM_RST},
    {1'b0,P_ON,P_MEM_RET,P_MEM_RET_EMU},{1'b0,P_ON,P_MEM_RET,P_LGC_RET},
    {1'b0,P_ON,P_MEM_RET,P_FULL_RET},{1'b0,P_ON,P_MEM_RET,P_MEM_OFF},
    {1'b0,P_ON,P_MEM_RET,P_FUNC_RET},{1'b0,P_ON,P_MEM_RET,P_ON},
    {1'b1,P_ON,P_MEM_RET,P_ON},{1'b0,P_ON,P_MEM_RET,P_WRM_RST},
    {1'b0,P_ON,P_FUNC_RET,P_ON},{1'b1,P_ON,P_FUNC_RET,P_ON},
    {1'b0,P_ON,P_FUNC_RET,P_WRM_RST},{1'b0,P_ON,P_ON,P_OFF},
    {1'b1,P_ON,P_ON,P_OFF},{1'b0,P_ON,P_ON,P_OFF_EMU},
    {1'b1,P_ON,P_ON,P_OFF_EMU},{1'b0,P_ON,P_ON,P_MEM_RET},
    {1'b1,P_ON,P_ON,P_MEM_RET},{1'b0,P_ON,P_ON,P_MEM_RET_EMU},
    {1'b1,P_ON,P_ON,P_MEM_RET_EMU},{1'b0,P_ON,P_ON,P_LGC_RET},
    {1'b1,P_ON,P_ON,P_LGC_RET},{1'b0,P_ON,P_ON,P_FULL_RET},
    {1'b1,P_ON,P_ON,P_FULL_RET},{1'b0,P_ON,P_ON,P_MEM_OFF},
    {1'b1,P_ON,P_ON,P_MEM_OFF},{1'b0,P_ON,P_ON,P_FUNC_RET},
    {1'b1,P_ON,P_ON,P_FUNC_RET},{1'b0,P_ON,P_ON,P_ON},
    {1'b1,P_ON,P_ON,P_ON},{1'b0,P_ON,P_ON,P_WRM_RST},
    {1'b1,P_ON,P_WRM_RST,P_OFF},{1'b1,P_ON,P_WRM_RST,P_OFF_EMU},
    {1'b1,P_ON,P_WRM_RST,P_MEM_RET},{1'b1,P_ON,P_WRM_RST,P_MEM_RET_EMU},
    {1'b1,P_ON,P_WRM_RST,P_LGC_RET},{1'b1,P_ON,P_WRM_RST,P_FULL_RET},
    {1'b1,P_ON,P_WRM_RST,P_MEM_OFF},{1'b1,P_ON,P_WRM_RST,P_FUNC_RET},
    {1'b1,P_ON,P_WRM_RST,P_ON},{1'b0,P_WRM_RST,P_OFF,P_OFF_EMU},
    {1'b0,P_WRM_RST,P_OFF,P_MEM_RET},{1'b0,P_WRM_RST,P_OFF,P_MEM_RET_EMU},
    {1'b0,P_WRM_RST,P_OFF,P_LGC_RET},{1'b0,P_WRM_RST,P_OFF,P_FULL_RET},
    {1'b0,P_WRM_RST,P_OFF,P_MEM_OFF},{1'b0,P_WRM_RST,P_OFF,P_FUNC_RET},
    {1'b0,P_WRM_RST,P_OFF,P_ON},{1'b0,P_WRM_RST,P_OFF,P_WRM_RST},
    {1'b1,P_WRM_RST,P_OFF,P_WRM_RST},{1'b0,P_WRM_RST,P_MEM_RET,P_MEM_RET_EMU},
    {1'b0,P_WRM_RST,P_MEM_RET,P_LGC_RET},{1'b0,P_WRM_RST,P_MEM_RET,P_FULL_RET},
    {1'b0,P_WRM_RST,P_MEM_RET,P_MEM_OFF},{1'b0,P_WRM_RST,P_MEM_RET,P_FUNC_RET},
    {1'b0,P_WRM_RST,P_MEM_RET,P_ON},{1'b0,P_WRM_RST,P_MEM_RET,P_WRM_RST},
    {1'b1,P_WRM_RST,P_MEM_RET,P_WRM_RST},{1'b0,P_WRM_RST,P_FUNC_RET,P_ON},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_WRM_RST},{1'b1,P_WRM_RST,P_FUNC_RET,P_WRM_RST},
    {1'b0,P_WRM_RST,P_ON,P_WRM_RST},{1'b1,P_WRM_RST,P_ON,P_WRM_RST},
    {1'b0,P_WRM_RST,P_WRM_RST,P_OFF},{1'b1,P_WRM_RST,P_WRM_RST,P_OFF},
    {1'b0,P_WRM_RST,P_WRM_RST,P_OFF_EMU},{1'b1,P_WRM_RST,P_WRM_RST,P_OFF_EMU},
    {1'b0,P_WRM_RST,P_WRM_RST,P_MEM_RET},{1'b1,P_WRM_RST,P_WRM_RST,P_MEM_RET},
    {1'b0,P_WRM_RST,P_WRM_RST,P_MEM_RET_EMU},{1'b1,P_WRM_RST,P_WRM_RST,P_MEM_RET_EMU},
    {1'b0,P_WRM_RST,P_WRM_RST,P_LGC_RET},{1'b1,P_WRM_RST,P_WRM_RST,P_LGC_RET},
    {1'b0,P_WRM_RST,P_WRM_RST,P_FULL_RET},{1'b1,P_WRM_RST,P_WRM_RST,P_FULL_RET},
    {1'b0,P_WRM_RST,P_WRM_RST,P_MEM_OFF},{1'b1,P_WRM_RST,P_WRM_RST,P_MEM_OFF},
    {1'b0,P_WRM_RST,P_WRM_RST,P_FUNC_RET},{1'b1,P_WRM_RST,P_WRM_RST,P_FUNC_RET},
    {1'b0,P_WRM_RST,P_WRM_RST,P_ON},{1'b1,P_WRM_RST,P_WRM_RST,P_ON},
    {1'b0,P_WRM_RST,P_WRM_RST,P_WRM_RST},{1'b1,P_WRM_RST,P_WRM_RST,P_WRM_RST}:
    begin
      //No Transition
      pwr_trans_req = 1'b0;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = L2H_PICDD;
      pwr_trans_target_mode[3:0] = 4'h0;
    end
    {1'b1,P_OFF,P_OFF,P_MEM_RET},{1'b0,P_OFF,P_MEM_RET,P_OFF},
    {1'b1,P_OFF,P_MEM_RET,P_OFF},{1'b0,P_OFF,P_MEM_RET,P_MEM_RET},
    {1'b1,P_OFF,P_MEM_RET,P_MEM_RET},{1'b0,P_OFF,P_MEM_RET,P_FUNC_RET},
    {1'b0,P_OFF,P_MEM_RET,P_ON},{1'b0,P_OFF,P_MEM_RET,P_WRM_RST}:
    begin
      //Transition to, when there is no pipeline flush, P_MEM_RET
      //Using Trans Path PCSM_ONLY
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = PCSM_ONLY;
      pwr_trans_target_mode[3:0] = P_MEM_RET;
    end
    {1'b1,P_OFF,P_OFF,P_FUNC_RET},{1'b1,P_OFF,P_OFF,P_ON},
    {1'b1,P_OFF,P_MEM_RET,P_FUNC_RET},{1'b1,P_OFF,P_MEM_RET,P_ON},
    {1'b0,P_OFF,P_FUNC_RET,P_OFF},{1'b1,P_OFF,P_FUNC_RET,P_OFF},
    {1'b0,P_OFF,P_FUNC_RET,P_MEM_RET},{1'b1,P_OFF,P_FUNC_RET,P_MEM_RET},
    {1'b0,P_OFF,P_FUNC_RET,P_FUNC_RET},{1'b1,P_OFF,P_FUNC_RET,P_FUNC_RET},
    {1'b0,P_OFF,P_FUNC_RET,P_ON},{1'b1,P_OFF,P_FUNC_RET,P_ON},
    {1'b0,P_OFF,P_FUNC_RET,P_WRM_RST},{1'b0,P_OFF,P_ON,P_OFF},
    {1'b1,P_OFF,P_ON,P_OFF},{1'b0,P_OFF,P_ON,P_MEM_RET},
    {1'b1,P_OFF,P_ON,P_MEM_RET},{1'b0,P_OFF,P_ON,P_FUNC_RET},
    {1'b1,P_OFF,P_ON,P_FUNC_RET},{1'b0,P_OFF,P_ON,P_ON},
    {1'b1,P_OFF,P_ON,P_ON},{1'b0,P_OFF,P_ON,P_WRM_RST},
    {1'b0,P_OFF,P_WRM_RST,P_OFF},{1'b0,P_OFF,P_WRM_RST,P_MEM_RET},
    {1'b0,P_OFF,P_WRM_RST,P_FUNC_RET},{1'b0,P_OFF,P_WRM_RST,P_ON},
    {1'b0,P_OFF,P_WRM_RST,P_WRM_RST},{1'b0,P_MEM_RET,P_OFF,P_OFF},
    {1'b1,P_MEM_RET,P_OFF,P_OFF},{1'b1,P_MEM_RET,P_OFF,P_FUNC_RET},
    {1'b1,P_MEM_RET,P_OFF,P_ON},{1'b1,P_MEM_RET,P_MEM_RET,P_FUNC_RET},
    {1'b1,P_MEM_RET,P_MEM_RET,P_ON},{1'b0,P_MEM_RET,P_FUNC_RET,P_OFF},
    {1'b1,P_MEM_RET,P_FUNC_RET,P_OFF},{1'b0,P_MEM_RET,P_FUNC_RET,P_OFF_EMU},
    {1'b1,P_MEM_RET,P_FUNC_RET,P_OFF_EMU},{1'b0,P_MEM_RET,P_FUNC_RET,P_MEM_RET},
    {1'b1,P_MEM_RET,P_FUNC_RET,P_MEM_RET},{1'b0,P_MEM_RET,P_FUNC_RET,P_FUNC_RET},
    {1'b1,P_MEM_RET,P_FUNC_RET,P_FUNC_RET},{1'b0,P_MEM_RET,P_FUNC_RET,P_ON},
    {1'b1,P_MEM_RET,P_FUNC_RET,P_ON},{1'b0,P_MEM_RET,P_FUNC_RET,P_WRM_RST},
    {1'b0,P_MEM_RET,P_ON,P_OFF},{1'b1,P_MEM_RET,P_ON,P_OFF},
    {1'b0,P_MEM_RET,P_ON,P_OFF_EMU},{1'b1,P_MEM_RET,P_ON,P_OFF_EMU},
    {1'b0,P_MEM_RET,P_ON,P_MEM_RET},{1'b1,P_MEM_RET,P_ON,P_MEM_RET},
    {1'b0,P_MEM_RET,P_ON,P_FUNC_RET},{1'b1,P_MEM_RET,P_ON,P_FUNC_RET},
    {1'b0,P_MEM_RET,P_ON,P_ON},{1'b1,P_MEM_RET,P_ON,P_ON},
    {1'b0,P_MEM_RET,P_ON,P_WRM_RST},{1'b0,P_MEM_RET,P_WRM_RST,P_OFF},
    {1'b0,P_MEM_RET,P_WRM_RST,P_OFF_EMU},{1'b0,P_MEM_RET,P_WRM_RST,P_MEM_RET},
    {1'b0,P_MEM_RET,P_WRM_RST,P_FUNC_RET},{1'b0,P_MEM_RET,P_WRM_RST,P_ON},
    {1'b0,P_MEM_RET,P_WRM_RST,P_WRM_RST}:
    begin
      //Transition to, when there is no pipeline flush, P_ON
      //Using Trans Path L2H_PICDD
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = L2H_PICDD;
      pwr_trans_target_mode[3:0] = P_ON;
    end
    {1'b0,P_FUNC_RET,P_OFF,P_OFF},{1'b1,P_FUNC_RET,P_OFF,P_OFF},
    {1'b1,P_FUNC_RET,P_OFF,P_OFF_EMU},{1'b1,P_FUNC_RET,P_OFF,P_MEM_RET},
    {1'b1,P_FUNC_RET,P_OFF,P_ON},{1'b0,P_FUNC_RET,P_MEM_RET,P_OFF},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_OFF},{1'b0,P_FUNC_RET,P_MEM_RET,P_OFF_EMU},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_OFF_EMU},{1'b0,P_FUNC_RET,P_MEM_RET,P_MEM_RET},
    {1'b1,P_FUNC_RET,P_MEM_RET,P_MEM_RET},{1'b1,P_FUNC_RET,P_MEM_RET,P_ON},
    {1'b1,P_FUNC_RET,P_FUNC_RET,P_ON},{1'b0,P_FUNC_RET,P_ON,P_OFF},
    {1'b1,P_FUNC_RET,P_ON,P_OFF},{1'b0,P_FUNC_RET,P_ON,P_OFF_EMU},
    {1'b1,P_FUNC_RET,P_ON,P_OFF_EMU},{1'b0,P_FUNC_RET,P_ON,P_MEM_RET},
    {1'b1,P_FUNC_RET,P_ON,P_MEM_RET},{1'b0,P_FUNC_RET,P_ON,P_MEM_RET_EMU},
    {1'b1,P_FUNC_RET,P_ON,P_MEM_RET_EMU},{1'b0,P_FUNC_RET,P_ON,P_LGC_RET},
    {1'b1,P_FUNC_RET,P_ON,P_LGC_RET},{1'b0,P_FUNC_RET,P_ON,P_FULL_RET},
    {1'b1,P_FUNC_RET,P_ON,P_FULL_RET},{1'b0,P_FUNC_RET,P_ON,P_MEM_OFF},
    {1'b1,P_FUNC_RET,P_ON,P_MEM_OFF},{1'b0,P_FUNC_RET,P_ON,P_FUNC_RET},
    {1'b1,P_FUNC_RET,P_ON,P_FUNC_RET},{1'b0,P_FUNC_RET,P_ON,P_ON},
    {1'b1,P_FUNC_RET,P_ON,P_ON},{1'b0,P_FUNC_RET,P_ON,P_WRM_RST},
    {1'b0,P_FUNC_RET,P_WRM_RST,P_OFF},{1'b0,P_FUNC_RET,P_WRM_RST,P_OFF_EMU},
    {1'b0,P_FUNC_RET,P_WRM_RST,P_MEM_RET},{1'b0,P_FUNC_RET,P_WRM_RST,P_MEM_RET_EMU},
    {1'b0,P_FUNC_RET,P_WRM_RST,P_LGC_RET},{1'b0,P_FUNC_RET,P_WRM_RST,P_FULL_RET},
    {1'b0,P_FUNC_RET,P_WRM_RST,P_MEM_OFF},{1'b0,P_FUNC_RET,P_WRM_RST,P_FUNC_RET},
    {1'b0,P_FUNC_RET,P_WRM_RST,P_ON},{1'b0,P_FUNC_RET,P_WRM_RST,P_WRM_RST}:
    begin
      //Transition to, when there is no pipeline flush, P_ON
      //Using Trans Path L2H_PD
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = L2H_PD;
      pwr_trans_target_mode[3:0] = P_ON;
    end
    {1'b0,P_ON,P_OFF,P_OFF},{1'b1,P_ON,P_OFF,P_OFF}:
    begin
      //Transition to, when there is no pipeline flush, P_OFF
      //Using Trans Path H2L_DCIRP
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = H2L_DCIRP;
      pwr_trans_target_mode[3:0] = P_OFF;
    end
    {1'b1,P_ON,P_OFF,P_OFF_EMU},{1'b1,P_ON,P_OFF,P_MEM_RET},
    {1'b0,P_ON,P_MEM_RET,P_OFF},{1'b1,P_ON,P_MEM_RET,P_OFF},
    {1'b0,P_ON,P_MEM_RET,P_OFF_EMU},{1'b1,P_ON,P_MEM_RET,P_OFF_EMU},
    {1'b0,P_ON,P_MEM_RET,P_MEM_RET},{1'b1,P_ON,P_MEM_RET,P_MEM_RET}:
    begin
      //Transition to, when there is no pipeline flush, P_MEM_RET
      //Using Trans Path H2L_DCIRP
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = H2L_DCIRP;
      pwr_trans_target_mode[3:0] = P_MEM_RET;
    end
    {1'b1,P_ON,P_OFF,P_MEM_RET_EMU},{1'b1,P_ON,P_OFF,P_LGC_RET},
    {1'b1,P_ON,P_OFF,P_FULL_RET},{1'b1,P_ON,P_OFF,P_MEM_OFF},
    {1'b1,P_ON,P_OFF,P_FUNC_RET},{1'b1,P_ON,P_MEM_RET,P_MEM_RET_EMU},
    {1'b1,P_ON,P_MEM_RET,P_LGC_RET},{1'b1,P_ON,P_MEM_RET,P_FULL_RET},
    {1'b1,P_ON,P_MEM_RET,P_MEM_OFF},{1'b1,P_ON,P_MEM_RET,P_FUNC_RET},
    {1'b0,P_ON,P_FUNC_RET,P_OFF},{1'b1,P_ON,P_FUNC_RET,P_OFF},
    {1'b0,P_ON,P_FUNC_RET,P_OFF_EMU},{1'b1,P_ON,P_FUNC_RET,P_OFF_EMU},
    {1'b0,P_ON,P_FUNC_RET,P_MEM_RET},{1'b1,P_ON,P_FUNC_RET,P_MEM_RET},
    {1'b0,P_ON,P_FUNC_RET,P_MEM_RET_EMU},{1'b1,P_ON,P_FUNC_RET,P_MEM_RET_EMU},
    {1'b0,P_ON,P_FUNC_RET,P_LGC_RET},{1'b1,P_ON,P_FUNC_RET,P_LGC_RET},
    {1'b0,P_ON,P_FUNC_RET,P_FULL_RET},{1'b1,P_ON,P_FUNC_RET,P_FULL_RET},
    {1'b0,P_ON,P_FUNC_RET,P_MEM_OFF},{1'b1,P_ON,P_FUNC_RET,P_MEM_OFF},
    {1'b0,P_ON,P_FUNC_RET,P_FUNC_RET},{1'b1,P_ON,P_FUNC_RET,P_FUNC_RET}:
    begin
      //Transition to, when there is no pipeline flush, P_FUNC_RET
      //Using Trans Path H2L_DP
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = H2L_DP;
      pwr_trans_target_mode[3:0] = P_FUNC_RET;
    end
    {1'b0,P_ON,P_WRM_RST,P_OFF},{1'b0,P_ON,P_WRM_RST,P_OFF_EMU},
    {1'b0,P_ON,P_WRM_RST,P_MEM_RET},{1'b0,P_ON,P_WRM_RST,P_MEM_RET_EMU},
    {1'b0,P_ON,P_WRM_RST,P_LGC_RET},{1'b0,P_ON,P_WRM_RST,P_FULL_RET},
    {1'b0,P_ON,P_WRM_RST,P_MEM_OFF},{1'b0,P_ON,P_WRM_RST,P_FUNC_RET},
    {1'b0,P_ON,P_WRM_RST,P_ON},{1'b0,P_ON,P_WRM_RST,P_WRM_RST}:
    begin
      //Transition to, when there is no pipeline flush, P_WRM_RST
      //Trans path depends on the value of WARM_RST_DEVREQEN:
      //0 - ON_WARM_NO_DEV
      //1 - ON_WARM_DEV
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = (warm_rst_devreqen_i)? ON_WARM_DEV:ON_WARM_NO_DEV;
      pwr_trans_target_mode[3:0] = P_WRM_RST;
    end
    {1'b0,P_WRM_RST,P_OFF,P_OFF},{1'b1,P_WRM_RST,P_OFF,P_OFF},
    {1'b1,P_WRM_RST,P_OFF,P_OFF_EMU},{1'b1,P_WRM_RST,P_OFF,P_MEM_RET},
    {1'b1,P_WRM_RST,P_OFF,P_MEM_RET_EMU},{1'b1,P_WRM_RST,P_OFF,P_LGC_RET},
    {1'b1,P_WRM_RST,P_OFF,P_FULL_RET},{1'b1,P_WRM_RST,P_OFF,P_MEM_OFF},
    {1'b1,P_WRM_RST,P_OFF,P_FUNC_RET},{1'b1,P_WRM_RST,P_OFF,P_ON},
    {1'b0,P_WRM_RST,P_MEM_RET,P_OFF},{1'b1,P_WRM_RST,P_MEM_RET,P_OFF},
    {1'b0,P_WRM_RST,P_MEM_RET,P_OFF_EMU},{1'b1,P_WRM_RST,P_MEM_RET,P_OFF_EMU},
    {1'b0,P_WRM_RST,P_MEM_RET,P_MEM_RET},{1'b1,P_WRM_RST,P_MEM_RET,P_MEM_RET},
    {1'b1,P_WRM_RST,P_MEM_RET,P_MEM_RET_EMU},{1'b1,P_WRM_RST,P_MEM_RET,P_LGC_RET},
    {1'b1,P_WRM_RST,P_MEM_RET,P_FULL_RET},{1'b1,P_WRM_RST,P_MEM_RET,P_MEM_OFF},
    {1'b1,P_WRM_RST,P_MEM_RET,P_FUNC_RET},{1'b1,P_WRM_RST,P_MEM_RET,P_ON},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_OFF},{1'b1,P_WRM_RST,P_FUNC_RET,P_OFF},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_OFF_EMU},{1'b1,P_WRM_RST,P_FUNC_RET,P_OFF_EMU},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_MEM_RET},{1'b1,P_WRM_RST,P_FUNC_RET,P_MEM_RET},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_MEM_RET_EMU},{1'b1,P_WRM_RST,P_FUNC_RET,P_MEM_RET_EMU},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_LGC_RET},{1'b1,P_WRM_RST,P_FUNC_RET,P_LGC_RET},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_FULL_RET},{1'b1,P_WRM_RST,P_FUNC_RET,P_FULL_RET},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_MEM_OFF},{1'b1,P_WRM_RST,P_FUNC_RET,P_MEM_OFF},
    {1'b0,P_WRM_RST,P_FUNC_RET,P_FUNC_RET},{1'b1,P_WRM_RST,P_FUNC_RET,P_FUNC_RET},
    {1'b1,P_WRM_RST,P_FUNC_RET,P_ON},{1'b0,P_WRM_RST,P_ON,P_OFF},
    {1'b1,P_WRM_RST,P_ON,P_OFF},{1'b0,P_WRM_RST,P_ON,P_OFF_EMU},
    {1'b1,P_WRM_RST,P_ON,P_OFF_EMU},{1'b0,P_WRM_RST,P_ON,P_MEM_RET},
    {1'b1,P_WRM_RST,P_ON,P_MEM_RET},{1'b0,P_WRM_RST,P_ON,P_MEM_RET_EMU},
    {1'b1,P_WRM_RST,P_ON,P_MEM_RET_EMU},{1'b0,P_WRM_RST,P_ON,P_LGC_RET},
    {1'b1,P_WRM_RST,P_ON,P_LGC_RET},{1'b0,P_WRM_RST,P_ON,P_FULL_RET},
    {1'b1,P_WRM_RST,P_ON,P_FULL_RET},{1'b0,P_WRM_RST,P_ON,P_MEM_OFF},
    {1'b1,P_WRM_RST,P_ON,P_MEM_OFF},{1'b0,P_WRM_RST,P_ON,P_FUNC_RET},
    {1'b1,P_WRM_RST,P_ON,P_FUNC_RET},{1'b0,P_WRM_RST,P_ON,P_ON},
    {1'b1,P_WRM_RST,P_ON,P_ON}:
    begin
      //Transition to, when there is no pipeline flush, P_ON
      //Trans path depends on the value of WARM_RST_DEVREQEN:
      //0 - WARM_ON_NO_DEV
      //1 - WARM_ON_DEV
      pwr_trans_req = 1'b1;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = (warm_rst_devreqen_i)? WARM_ON_DEV:WARM_ON_NO_DEV;
      pwr_trans_target_mode[3:0] = P_ON;
    end
    default:
    begin
      //X-Prop
      pwr_trans_req = 1'bx;
      pwr_trans_path[TRANS_PATH_WIDTH-1:0] = {TRANS_PATH_WIDTH{1'bx}};
      pwr_trans_target_mode[3:0] = 4'hx;
    end
    endcase
  end



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pwr_mode_entry_delay_r[7:0] <= 8'h00;
    end
    else if(pwr_mode_entry_delay_en)
    begin
      pwr_mode_entry_delay_r[7:0] <= nxt_pwr_mode_entry_delay_r[7:0];
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      prev_pwr_trans_target_mode_r[3:0] <= 4'hF;
    end
    else if(pipeline_en)
    begin
      prev_pwr_trans_target_mode_r[3:0] <= pwr_trans_target_mode_mask[3:0];
    end
  end

  assign target_mode_match = (pwr_trans_target_mode[3:0] == prev_pwr_trans_target_mode_r[3:0]);


  assign pwr_trans_target_mode_mask[3:0] = (pipeline_flush | ~pwr_trans_req)? 4'hF:pwr_trans_target_mode[3:0];

  assign pwr_mode_entry_delay_en = (pwr_mode_entry_delay_load | pwr_mode_entry_delay_dec) & pipeline_en;

  assign trans_requires_entry_delay = (pwr_trans_path[TRANS_PATH_WIDTH-1:0] == H2L_DCIRP) |
                                      (pwr_trans_path[TRANS_PATH_WIDTH-1:0] == H2L_DP);


  assign pwr_mode_entry_delay_load = pwr_trans_req & trans_requires_entry_delay & ~target_mode_match;
  assign pwr_mode_entry_delay_dec = pwr_trans_req & trans_requires_entry_delay & target_mode_match;

  assign pwr_mode_entry_delay_expired = ((pwr_mode_entry_delay_r[7:0] == 8'h01) & pwr_mode_entry_delay_dec) |
                                        ((~|pwr_mode_entry_delay_load_value[7:0]) & pwr_mode_entry_delay_load) |
                                        ~trans_requires_entry_delay;

  always@*
  begin
    case({pwr_mode_entry_delay_load,pwr_mode_entry_delay_dec})
    2'b01: nxt_pwr_mode_entry_delay_r[7:0] = pwr_mode_entry_delay_r[7:0] - 8'h01;
    2'b10: nxt_pwr_mode_entry_delay_r[7:0] = pwr_mode_entry_delay_load_value[7:0];
    default: nxt_pwr_mode_entry_delay_r[7:0] = 8'hxx;
    endcase
  end

  always@*
  begin
    case(pwr_trans_target_mode[3:0])
    P_OFF: pwr_mode_entry_delay_load_value[7:0] = off_del_i[7:0];
    P_MEM_RET: pwr_mode_entry_delay_load_value[7:0] = mem_ret_del_i[7:0];
    P_FUNC_RET: pwr_mode_entry_delay_load_value[7:0] = func_ret_del_i[7:0];
    P_ON: pwr_mode_entry_delay_load_value[7:0] = 8'h00;
    P_WRM_RST: pwr_mode_entry_delay_load_value[7:0] = 8'h00;
    default: pwr_mode_entry_delay_load_value[7:0] = 8'hxx;
    endcase
  end




  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      mtu_clk_req_r <= 1'b0;
    end
    else
    begin
      mtu_clk_req_r <= nxt_mtu_clk_req_r;
    end
  end

  assign nxt_mtu_clk_req_r = pipeline_flush;

  assign mtu_clk_req = ~init_comp |
                       mtu_clk_req_r |
                       pwr_mode_entry_delay_dec |
                       trans_req;


  assign trans_start_req_o = init_trans_start_pwr | trans_req;
  assign trans_path_o[TRANS_PATH_WIDTH-1:0] = (init_comp)? trans_path_r[TRANS_PATH_WIDTH-1:0]:
                                                           ppu_init_trans_path[TRANS_PATH_WIDTH-1:0];
  assign trans_target_pwr_mode_o[3:0] = (init_comp)? ((trans_pwr_req_r)? trans_target_pwr_mode_r[3:0]:pwr_st_i[3:0]):
                                                     pwr_policy_init[3:0];

  assign pwpr_init_o = pwpr_init;
  assign pwr_policy_init_o[3:0] = pwr_policy_init[3:0];

  assign trans_init_o = ~init_comp;

  assign apb_stall_o = apb_stall;

  assign sample_pcsm_mode_stat_o = sample_pcsm_mode_stat;

  assign mtu_clk_req_o = mtu_clk_req;

endmodule
