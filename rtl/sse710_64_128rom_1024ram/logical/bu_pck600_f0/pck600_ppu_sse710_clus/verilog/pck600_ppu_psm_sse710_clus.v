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


module pck600_ppu_psm_sse710_clus
#(
  parameter DEF_PWR_DYN_ST = 1'b1,
  parameter TRANS_PATH_WIDTH = 5,
  parameter PPUHWSTAT_WIDTH = 16,
  parameter CRI_COUNTER_EN = 1,
  parameter CRI_COUNTER_WIDTH = 8
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //DIU Interface
  output wire [1:0]           diu_req_o,
  output wire [3:0]           diu_pwr_mode_o,
  output wire                 diu_stall_o,
  input wire                  diu_accept_i,
  input wire                  diu_comp_i,
  input wire                  diu_req_high_i,

  //PIU Interface
  output wire                 piu_req_o,
  output wire [3:0]           piu_pwr_mode_o,
  input wire                  piu_comp_i,

  //Transition Control
  input wire                  trans_start_req_i,
  input wire [TRANS_PATH_WIDTH-1:0] trans_path_i,
  input wire [3:0]            trans_target_pwr_mode_i,
  output wire                 trans_comp_o,
  output wire                 trans_comp_accept_o,
  output wire                 trans_comp_deny_o,
  output wire                 pwr_policy_revert_o,
  output wire                 psm_idle_o,

  //PPU_PWPR update
  input wire                  pwpr_legal_write_en_i,
  input wire                  pwpr_nxt_pwr_dyn_en_i,
  //PWPR Current Values
  input wire                  pwr_dyn_en_i,

  //PPU_PWSR
  output wire [3:0]           pwr_st_o,
  output wire                 pwr_dyn_st_o,

  //Device Control Signals
  output wire [PPUHWSTAT_WIDTH-1:0] ppuhwstat_o,
  output wire                 devclken_o,
  output wire                 devemuclken_o,
  output wire                 devisolaten_o,
  output wire                 devemuisolaten_o,
  output wire                 devwarmresetn_o,
  output wire                 devretresetn_o,
  output wire                 devporesetn_o,
  //PPU_DCDR0
  input wire [CRI_COUNTER_WIDTH-1:0] clken_rst_dly_i,
  input wire [CRI_COUNTER_WIDTH-1:0] iso_clken_dly_i,
  input wire [CRI_COUNTER_WIDTH-1:0] rst_hwstat_dly_i,
  //PPU_DCDR1
  input wire [CRI_COUNTER_WIDTH-1:0] iso_rst_dly_i,
  input wire [CRI_COUNTER_WIDTH-1:0] clken_iso_dly_i

);

  `include "pck600_ppu_enum_sse710_clus.v"

  localparam SM_STABLE = 4'h0;
  localparam SM_DEV = 4'h1;
  localparam SM_ISO = 4'h2;
  localparam SM_CLK = 4'h3;
  localparam SM_RST = 4'h4;
  localparam SM_PWR = 4'h5;
  localparam SM_DEV_REQ = 4'h6;
  localparam SM_DEV_WAIT = 4'h7;
  localparam SM_PWR_OR = 4'h8;
  localparam SM_RES_CLK = 4'h9;
  localparam SM_RES_ISO = 4'hA;
  localparam SM_RES_RST = 4'hB;
  localparam SM_RES_PWR = 4'hC;
  localparam SM_TRANS_COMP = 4'hD;


  reg                         pwr_st_3_r;
  reg                         pwr_st_2_r;
  reg                         pwr_st_1_r;
  reg                         pwr_st_0_r;
  reg                         pwr_dyn_st_r;

  wire [3:0]                  nxt_pwr_st_r;
  reg                         nxt_pwr_dyn_st_r;

  wire [3:0]                  pwr_st;

  wire                        pwsr_en;

  reg [3:0]                   state;
  reg                         trans_comp_accept_r;
  reg                         state_en;
  reg [3:0]                   nxt_state;
  reg                         nxt_trans_comp_accept_r;
  reg [1:0]                   diu_req;
  wire                        diu_stall;
  reg                         diu_curr_value;
  reg                         piu_req;
  reg                         piu_curr_value;
  reg                         cri_counter_load;
  reg [CRI_COUNTER_WIDTH-1:0] cri_counter_load_value;
  reg                         clk_en;
  reg                         iso_en;
  reg                         rst_en;
  reg                         hwstat_en;
  wire                        trans_comp;

  wire                        pwr_dyn_st_update;
  wire                        pwr_policy_revert;

  wire [3:0]                  diu_pwr_mode;

  wire [3:0]                  piu_pwr_mode_target;
  reg [3:0]                   piu_pwr_mode;

  wire                        cri_counter_expired;

  wire [3:0]                  cri_lookup_value;
  wire                        cri_lookup_sel;

  reg                         devclken_r;
  reg                         devisolaten_r;
  reg                         devwarmresetn_r;
  reg                         devporesetn_r;

  reg                         nxt_devclken_r;
  reg                         nxt_devisolaten_r;
  reg                         nxt_devwarmresetn_r;
  reg                         nxt_devporesetn_r;


  reg [15:0]                  ppuhwstat_pwr_mode_r;

  reg [15:0]                  nxt_ppuhwstat_pwr_mode_r;





  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pwr_st_3_r <= 1'b0;
      pwr_st_2_r <= 1'b0;
      pwr_st_1_r <= 1'b0;
      pwr_st_0_r <= 1'b0;
      pwr_dyn_st_r <= DEF_PWR_DYN_ST[0];
    end
    else if(pwsr_en)
    begin
      pwr_st_3_r <= nxt_pwr_st_r[3];
      pwr_st_2_r <= nxt_pwr_st_r[2];
      pwr_st_1_r <= nxt_pwr_st_r[1];
      pwr_st_0_r <= nxt_pwr_st_r[0];
      pwr_dyn_st_r <= nxt_pwr_dyn_st_r;
    end
  end

  assign pwr_st[3:0] = {pwr_st_3_r,
                        pwr_st_2_r,
                        pwr_st_1_r,
                        pwr_st_0_r};

  assign pwsr_en = trans_comp | (pwpr_legal_write_en_i & ~trans_start_req_i);

  always@*
  begin
    case({pwr_dyn_st_update,pwpr_legal_write_en_i})
    2'b00:
    begin
      nxt_pwr_dyn_st_r = pwr_dyn_st_r;
    end
    2'b01:
    begin
      nxt_pwr_dyn_st_r = pwpr_nxt_pwr_dyn_en_i;
    end
    2'b10:
    begin
      nxt_pwr_dyn_st_r = pwr_dyn_en_i;
    end
    2'b11:
    begin
      nxt_pwr_dyn_st_r = pwpr_nxt_pwr_dyn_en_i;
    end
    default:
    begin
      nxt_pwr_dyn_st_r = 1'bx;
    end
    endcase
  end

  assign nxt_pwr_st_r[3:0] = (trans_comp & trans_comp_accept_r)? trans_target_pwr_mode_i[3:0]:pwr_st[3:0];


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[3:0] <= SM_STABLE;
      trans_comp_accept_r <= 1'b0;
    end
    else if(state_en)
    begin
      state[3:0] <= nxt_state[3:0];
      trans_comp_accept_r <= nxt_trans_comp_accept_r;
    end
  end

  //Calculate whether transition was accepted or not.
  always@*
  begin
    case(trans_path_i[TRANS_PATH_WIDTH-1:0])
    H2L_DCIRP,H2L_DP,L2H_PICDD,L2H_PD,
    ON_WARM_DEV,WARM_ON_DEV:
    begin
      //Transition includes a Device Handshake.
      //The transition was accepted only if the device handshake was accepted.
      nxt_trans_comp_accept_r = diu_accept_i;
    end
    ON_WARM_NO_DEV,WARM_ON_NO_DEV,PCSM_ONLY,UPDATE_ST:
    begin
      //Transition doesn't include a Device Handshake.
      //The transition will always be accepted.
      nxt_trans_comp_accept_r = 1'b1;
    end
    default:
    begin
      //X-Prop
      nxt_trans_comp_accept_r = 1'bx;
    end
    endcase
  end

  //Sequence the steps to transition between PWR_ST and the target mode.
  always@*
  begin
    case(state[3:0])
    SM_STABLE:
    begin
      state_en = trans_start_req_i;
      clk_en = 1'b0;
      case(trans_start_req_i)
      1'b0:
      begin
        //No transition requested
        nxt_state[3:0] = SM_STABLE;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        iso_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      1'b1:
      begin
        case(trans_path_i[TRANS_PATH_WIDTH-1:0])
        H2L_DCIRP,H2L_DP,
        ON_WARM_DEV:
        begin
          //Transition to SM_DEV requesting handshake to target mode
          nxt_state[3:0] = SM_DEV;
          diu_req[1:0] = 2'b11;
          diu_curr_value = 1'b0;
          piu_req = 1'b0;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b0;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
          iso_en = 1'b0;
          rst_en = 1'b0;
          hwstat_en = 1'b0;
        end
        L2H_PICDD,L2H_PD,
        PCSM_ONLY:
        begin
          //Transition to SM_PWR requesting handshake to target mode
          nxt_state[3:0] = SM_PWR;
          diu_req[1:0] = 2'b00;
          diu_curr_value = 1'b0;
          piu_req = 1'b1;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b0;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
          iso_en = 1'b0;
          rst_en = 1'b0;
          hwstat_en = 1'b0;
        end
        ON_WARM_NO_DEV:
        begin
          //Transition to SM_RST
          nxt_state[3:0] = SM_RST;
          diu_req[1:0] = 2'b00;
          diu_curr_value = 1'b0;
          piu_req = 1'b0;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b0;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
          iso_en = 1'b0;
          rst_en = 1'b1;
          hwstat_en = 1'b0;
        end
        WARM_ON_NO_DEV:
        begin
          //Transition to SM_RST and load CRI counter with RST_HWSTAT_DLY
          nxt_state[3:0] = SM_RST;
          diu_req[1:0] = 2'b00;
          diu_curr_value = 1'b0;
          piu_req = 1'b0;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b1;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = rst_hwstat_dly_i[CRI_COUNTER_WIDTH-1:0];
          iso_en = 1'b0;
          rst_en = 1'b1;
          hwstat_en = 1'b0;
        end
        WARM_ON_DEV:
        begin
          //Transition to SM_DEV_REQ requesting handshake to target mode
          nxt_state[3:0] = SM_DEV_REQ;
          diu_req[1:0] = 2'b11;
          diu_curr_value = 1'b0;
          piu_req = 1'b0;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b0;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
          iso_en = 1'b0;
          rst_en = 1'b0;
          hwstat_en = 1'b0;
        end
        UPDATE_ST:
        begin
          //Transition to SM_TRANS_COMP as only a status update is required
          nxt_state[3:0] = SM_TRANS_COMP;
          diu_req[1:0] = 2'b00;
          diu_curr_value = 1'b0;
          piu_req = 1'b0;
          piu_curr_value = 1'b0;
          cri_counter_load = 1'b0;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
          iso_en = 1'b0;
          rst_en = 1'b0;
          hwstat_en = 1'b1;
        end
        default:
        begin
          //X-Prop
          nxt_state[3:0] = 4'hx;
          diu_req[1:0] = 2'bxx;
          diu_curr_value = 1'bx;
          piu_req = 1'bx;
          piu_curr_value = 1'bx;
          cri_counter_load = 1'bx;
          cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
          iso_en = 1'bx;
          rst_en = 1'bx;
          hwstat_en = 1'bx;
        end
        endcase
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        diu_req[1:0] = 2'bxx;
        diu_curr_value = 1'bx;
        piu_req = 1'bx;
        piu_curr_value = 1'bx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        iso_en = 1'bx;
        rst_en = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_DEV:
    begin
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      iso_en = 1'b0;
      case({diu_accept_i,trans_path_i[TRANS_PATH_WIDTH-1:0]})
      {1'b0,H2L_DCIRP},{1'b0,H2L_DP},
      {1'b0,ON_WARM_DEV}:
      begin
        //Wait for Device Handshake to complete. If denied transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b0,L2H_PICDD}:
      begin
        //Wait for Device Handshake to complete. If denied transition to SM_RES_CLK
        //Load CRI counter with CLKEN_ISO_DLY
        nxt_state[3:0] = SM_RES_CLK;
        state_en = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = diu_comp_i;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = clken_iso_dly_i[CRI_COUNTER_WIDTH-1:0];
        clk_en = diu_comp_i;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b0,L2H_PD}:
      begin
        //Wait for Device Handshake to complete. If denied transition to SM_RES_PWR
        //Requesting a handshake to the current mode
        nxt_state[3:0] = SM_RES_PWR;
        state_en = diu_comp_i;
        piu_req = diu_comp_i;
        piu_curr_value = 1'b1;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b1,H2L_DCIRP}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_CLK
        //Load CRI counter with CLKEN_ISO_DLY
        nxt_state[3:0] = SM_CLK;
        state_en = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = diu_comp_i;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = clken_iso_dly_i[CRI_COUNTER_WIDTH-1:0];
        clk_en = diu_comp_i;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b1,H2L_DP}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_PWR
        //Requesting a handshake to the target mode
        nxt_state[3:0] = SM_PWR;
        state_en = diu_comp_i;
        piu_req = diu_comp_i;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b1,ON_WARM_DEV}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_RST
        nxt_state[3:0] = SM_RST;
        state_en = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = diu_comp_i;
        hwstat_en = 1'b0;
      end
      {1'b1,L2H_PICDD}:
      begin
        //Wait for Device Handshake to complete and CRI counter to expire. If accepted transition to
        //SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = diu_comp_i & cri_counter_expired;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = diu_comp_i & cri_counter_expired;
      end
      {1'b1,L2H_PD}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = diu_comp_i;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        state_en = 1'bx;
        piu_req = 1'bx;
        piu_curr_value = 1'bx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        clk_en = 1'bx;
        rst_en = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_CLK:
    begin
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      clk_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      H2L_DCIRP:
      begin
        //When CRI counter has expired transition to SM_ISO
        //and load CRI counter with ISO_RST_DLY
        nxt_state[3:0] = SM_ISO;
        state_en = cri_counter_expired;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = cri_counter_expired;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = iso_rst_dly_i[CRI_COUNTER_WIDTH-1:0];
        iso_en = cri_counter_expired;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      L2H_PICDD:
      begin
        //Wait in this state for 1 cycle then transition to SM_DEV_REQ
        //requesting a handshake with current mode
        nxt_state[3:0] = SM_DEV_REQ;
        state_en = 1'b1;
        diu_req[1:0] = 2'b11;
        diu_curr_value = 1'b1;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        iso_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        state_en = 1'bx;
        diu_req[1:0] = 2'bxx;
        diu_curr_value = 1'bx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        iso_en = 1'bx;
        rst_en = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_ISO:
    begin
      state_en = cri_counter_expired;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      iso_en = 1'b0;
      hwstat_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      H2L_DCIRP:
      begin
        //When CRI counter has expired transition to SM_RST
        nxt_state[3:0] = SM_RST;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = cri_counter_expired;
      end
      L2H_PICDD:
      begin
        //When CRI counter has expired transition to SM_CLK
        //and load CRI counter with CLKEN_RST_DLY
        nxt_state[3:0] = SM_CLK;
        cri_counter_load = cri_counter_expired;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = clken_rst_dly_i[CRI_COUNTER_WIDTH-1:0];
        clk_en = cri_counter_expired;
        rst_en = 1'b0;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        clk_en = 1'bx;
        rst_en = 1'bx;
      end
      endcase
    end
    SM_RST:
    begin
      cri_counter_load = 1'b0;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
      clk_en = 1'b0;
      iso_en = 1'b0;
      rst_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      H2L_DCIRP:
      begin
        //Only stay in this state for 1 cycle then transition to SM_PWR
        //Requesting a PCSM handshake with the target mode
        nxt_state[3:0] = SM_PWR;
        state_en = 1'b1;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        piu_req = 1'b1;
        piu_curr_value = 1'b0;
        hwstat_en = 1'b0;
      end
      ON_WARM_NO_DEV,ON_WARM_DEV:
      begin
        //Only stay in this state for 1 cycle then transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = 1'b1;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        hwstat_en = 1'b1;
      end
      WARM_ON_NO_DEV:
      begin
        //When CRI counter has expired transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = cri_counter_expired;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        hwstat_en = cri_counter_expired;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        state_en = 1'bx;
        diu_req[1:0] = 2'bxx;
        diu_curr_value = 1'bx;
        piu_req = 1'bx;
        piu_curr_value = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_PWR:
    begin
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      clk_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      H2L_DCIRP,H2L_DP:
      begin
        //When PCSM handshake is complete transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = piu_comp_i;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        iso_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = piu_comp_i;
      end
      PCSM_ONLY:
      begin
        //When PCSM handshake is complete transition to SM_TRANS_COMP
        //whilst requesting that DEVPSTATE is updated to the target mode
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = piu_comp_i;
        diu_req[1:0] = {piu_comp_i,1'b0};
        diu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        iso_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = piu_comp_i;
      end
      L2H_PICDD:
      begin
        //When PCSM handshake is complete transition to SM_ISO
        //Load CRI counter with ISO_CLKEN_DLY
        nxt_state[3:0] = SM_ISO;
        state_en = piu_comp_i;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = piu_comp_i;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = iso_clken_dly_i[CRI_COUNTER_WIDTH-1:0];
        iso_en = piu_comp_i;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      L2H_PD:
      begin
        //When PCSM handshake is complete transition to SM_DEV
        //Request a handshake to target mode
        nxt_state[3:0] = SM_DEV;
        state_en = piu_comp_i;
        diu_req[1:0] = {2{piu_comp_i}};
        diu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        iso_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        state_en = 1'bx;
        diu_req[1:0] = 2'bxx;
        diu_curr_value = 1'bx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        iso_en = 1'bx;
        rst_en = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_DEV_REQ:
    begin
      nxt_state[3:0] = SM_DEV_WAIT;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      clk_en = 1'b0;
      iso_en = 1'b0;
      hwstat_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      L2H_PICDD:
      begin
        //Wait for PREQ to be high and the CRI counter to expired then transition to SM_DEV_WAIT
        //De-assert reset and load the CRI counter with RST_HWSTAT_DLY
        state_en = diu_req_high_i & cri_counter_expired;
        cri_counter_load = diu_req_high_i & cri_counter_expired;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = rst_hwstat_dly_i[CRI_COUNTER_WIDTH-1:0];
        rst_en = diu_req_high_i & cri_counter_expired;
      end
      WARM_ON_DEV:
      begin
        //Wait for PREQ to be high then transition to SM_DEV_WAIT.
        //De-assert reset and load the CRI counter with RST_HWSTAT_DLY
        state_en = diu_req_high_i;
        cri_counter_load = diu_req_high_i;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = rst_hwstat_dly_i[CRI_COUNTER_WIDTH-1:0];
        rst_en = diu_req_high_i;
      end
      default:
      begin
        //X-Prop
        state_en = 1'bx;
        cri_counter_load = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        rst_en = 1'bx;
      end
      endcase
    end
    SM_DEV_WAIT:
    begin
      iso_en = 1'b0;
      case({diu_accept_i,trans_path_i[TRANS_PATH_WIDTH-1:0]})
      {1'b0,WARM_ON_DEV}:
      begin
        //Wait for Device Handshake to complete. If denied transition to SM_RES_RST
        //Load CRI counter with 0 to stop it from counting
        nxt_state[3:0] = SM_RES_RST;
        state_en = diu_comp_i;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = diu_comp_i;
        hwstat_en = 1'b0;
      end
      {1'b0,L2H_PICDD}:
      begin
        //Wait for Device Handshake to complete. If denied transition to SM_RES_CLK
        //Load CRI counter with CLKEN_ISO_DLY
        nxt_state[3:0] = SM_RES_CLK;
        state_en = diu_comp_i;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = diu_comp_i;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = clken_iso_dly_i[CRI_COUNTER_WIDTH-1:0];
        clk_en = diu_comp_i;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b1,L2H_PICDD}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_DEV
        //requesting handshake to the target value
        nxt_state[3:0] = SM_DEV;
        state_en = diu_comp_i;
        diu_req[1:0] = {2{diu_comp_i}};
        diu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = 1'b0;
      end
      {1'b1,WARM_ON_DEV}:
      begin
        //Wait for Device Handshake to complete. If accepted transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        state_en = diu_comp_i & cri_counter_expired;
        diu_req[1:0] = 2'b00;
        diu_curr_value = 1'b0;
        cri_counter_load = 1'b0;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
        clk_en = 1'b0;
        rst_en = 1'b0;
        hwstat_en = diu_comp_i & cri_counter_expired;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        state_en = 1'bx;
        diu_req[1:0] = 2'bxx;
        diu_curr_value = 1'bx;
        cri_counter_load = 1'bx;
        piu_req = 1'bx;
        piu_curr_value = 1'bx;
        cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
        clk_en = 1'bx;
        rst_en = 1'bx;
        hwstat_en = 1'bx;
      end
      endcase
    end
    SM_RES_CLK:
    begin
      //Wait for CRI Counter to expired then transition to SM_RES_ISO
      //and loading the CRI counter with ISO_RST_DLY
      nxt_state[3:0] = SM_RES_ISO;
      state_en = cri_counter_expired;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      cri_counter_load = cri_counter_expired;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = iso_rst_dly_i[CRI_COUNTER_WIDTH-1:0];
      clk_en = 1'b0;
      iso_en = cri_counter_expired;
      rst_en = 1'b0;
      hwstat_en = 1'b0;
    end
    SM_RES_ISO:
    begin
      nxt_state[3:0] = SM_RES_RST;
      state_en = cri_counter_expired;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      cri_counter_load = 1'b0;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
      clk_en = 1'b0;
      iso_en = 1'b0;
      rst_en = cri_counter_expired;
      hwstat_en = 1'b0;
    end
    SM_RES_RST:
    begin
      state_en = 1'b1;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      cri_counter_load = 1'b0;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
      clk_en = 1'b0;
      iso_en = 1'b0;
      rst_en = 1'b0;
      hwstat_en = 1'b0;
      case(trans_path_i[TRANS_PATH_WIDTH-1:0])
      L2H_PICDD:
      begin
        //Wait in this state for 1 cycle then transition to SM_PWR
        //requesting a handshake to current mode
        nxt_state[3:0] = SM_RES_PWR;
        piu_req = 1'b1;
        piu_curr_value = 1'b1;
      end
      WARM_ON_DEV:
      begin
        //Wait in this state for 1 cycle then transition to SM_TRANS_COMP
        nxt_state[3:0] = SM_TRANS_COMP;
        piu_req = 1'b0;
        piu_curr_value = 1'b0;
      end
      default:
      begin
        //X-Prop
        nxt_state[3:0] = 4'hx;
        piu_req = 1'bx;
        piu_curr_value = 1'bx;
      end
      endcase
    end
    SM_RES_PWR:
    begin
      //Wait for PCSM handshake to complete then transition to SM_TRANS_COMP
      nxt_state[3:0] = SM_TRANS_COMP;
      state_en = piu_comp_i;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      cri_counter_load = 1'b0;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
      clk_en = 1'b0;
      iso_en = 1'b0;
      rst_en = 1'b0;
      hwstat_en = 1'b0;
    end
    SM_TRANS_COMP:
    begin
      //Indicate transition completed to update of PWSR
      //Generate the required interrupts
      nxt_state[3:0] = SM_STABLE;
      state_en = 1'b1;
      diu_req[1:0] = 2'b00;
      diu_curr_value = 1'b0;
      piu_req = 1'b0;
      piu_curr_value = 1'b0;
      cri_counter_load = 1'b0;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'b0}};
      clk_en = 1'b0;
      iso_en = 1'b0;
      rst_en = 1'b0;
      hwstat_en = 1'b0;
    end
    default:
    begin
      //X-Prop
      nxt_state[3:0] = 4'hx;
      state_en = 1'bx;
      diu_req[1:0] = 2'bxx;
      diu_curr_value = 1'bx;
      piu_req = 1'bx;
      piu_curr_value = 1'bx;
      cri_counter_load = 1'bx;
      cri_counter_load_value[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
      clk_en = 1'bx;
      iso_en = 1'bx;
      rst_en = 1'bx;
      hwstat_en = 1'bx;
    end
    endcase
  end

  assign trans_comp = (state[3:0] == SM_TRANS_COMP);


  assign pwr_dyn_st_update = trans_comp & (trans_comp_accept_r | (~trans_comp_accept_r & ~pwr_policy_revert));

  assign pwr_policy_revert = ~pwr_dyn_st_r & trans_comp & ~trans_comp_accept_r;



  assign diu_pwr_mode[3:0] = (diu_curr_value)? pwr_st[3:0]:trans_target_pwr_mode_i[3:0];


  assign diu_stall = (state[3:0] == SM_DEV_REQ);


  assign piu_pwr_mode_target[3:0] = (piu_curr_value)? pwr_st[3:0]:trans_target_pwr_mode_i[3:0];

  //Calculate PIU Power Mode requested mode.
  always@*
  begin
    case(piu_pwr_mode_target[3:0])
    P_OFF:
    begin
      //OFF
      piu_pwr_mode[3:0] = P_OFF;
    end
    P_MEM_RET:
    begin
      //MEM_RET
      piu_pwr_mode[3:0] = P_MEM_RET;
    end
    P_MEM_OFF:
    begin
      //MEM_OFF
      piu_pwr_mode[3:0] = P_MEM_OFF;
    end
    P_FUNC_RET:
    begin
      //FUNC_RET
      piu_pwr_mode[3:0] = P_FUNC_RET;
    end
    P_ON,P_WRM_RST:
    begin
      //ON
      //WRM_RST
      piu_pwr_mode[3:0] = P_ON;
    end
    default:
    begin
      //X-Prop
      piu_pwr_mode[3:0] = 4'hx;
    end
    endcase
  end


generate
if(CRI_COUNTER_EN == 1 && CRI_COUNTER_WIDTH > 1)
begin:cri_counter_multi_bit

  reg [CRI_COUNTER_WIDTH-1:0] cri_counter_r;
  reg [CRI_COUNTER_WIDTH-1:0] nxt_cri_counter_r;
  wire                        cri_counter_en;
  wire                        cri_counter_dec;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      cri_counter_r[CRI_COUNTER_WIDTH-1:0] <= {CRI_COUNTER_WIDTH{1'b0}};
    end
    else if(cri_counter_en)
    begin
      cri_counter_r[CRI_COUNTER_WIDTH-1:0] <= nxt_cri_counter_r[CRI_COUNTER_WIDTH-1:0];
    end
  end

  assign cri_counter_en = cri_counter_load | cri_counter_dec;

  always@*
  begin
    case({cri_counter_load,cri_counter_dec})
    2'b01: nxt_cri_counter_r[CRI_COUNTER_WIDTH-1:0] = cri_counter_r[CRI_COUNTER_WIDTH-1:0] - {{(CRI_COUNTER_WIDTH-1){1'b0}},1'b1};
    2'b10: nxt_cri_counter_r[CRI_COUNTER_WIDTH-1:0] = cri_counter_load_value[CRI_COUNTER_WIDTH-1:0];
    2'b11: nxt_cri_counter_r[CRI_COUNTER_WIDTH-1:0] = cri_counter_load_value[CRI_COUNTER_WIDTH-1:0];
    default: nxt_cri_counter_r[CRI_COUNTER_WIDTH-1:0] = {CRI_COUNTER_WIDTH{1'bx}};
    endcase
  end

  assign cri_counter_dec = ~cri_counter_expired;

  assign cri_counter_expired = ~|cri_counter_r[CRI_COUNTER_WIDTH-1:0];

end
else if(CRI_COUNTER_EN == 1 && CRI_COUNTER_WIDTH == 1)
begin:cri_counter_single_bit

  reg                         cri_counter_r;
  reg                         nxt_cri_counter_r;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      cri_counter_r <= 1'b0;
    end
    else
    begin
      cri_counter_r <= nxt_cri_counter_r;
    end
  end

  always@*
  begin
    case({cri_counter_load,cri_counter_r})
    2'b00: nxt_cri_counter_r = 1'b0;
    2'b01: nxt_cri_counter_r = 1'b0;
    2'b10: nxt_cri_counter_r = cri_counter_load_value[CRI_COUNTER_WIDTH-1:0];
    2'b11: nxt_cri_counter_r = cri_counter_load_value[CRI_COUNTER_WIDTH-1:0];
    default: nxt_cri_counter_r = 1'bx;
    endcase
  end

  assign cri_counter_expired = ~cri_counter_r;

end
else
begin:cri_counter_disabled

  assign cri_counter_expired = 1'b1;

end
endgenerate


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devclken_r <= 1'b0;
    end
    else if(clk_en)
    begin
      devclken_r <= nxt_devclken_r;
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devisolaten_r <= 1'b0;
    end
    else if(iso_en)
    begin
      devisolaten_r <= nxt_devisolaten_r;
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      devwarmresetn_r <= 1'b0;
      devporesetn_r <= 1'b0;
    end
    else if(rst_en)
    begin
      devwarmresetn_r <= nxt_devwarmresetn_r;
      devporesetn_r <= nxt_devporesetn_r;
    end
  end

  assign cri_lookup_sel = (state[3:0] == SM_RES_CLK) | (state[3:0] == SM_RES_ISO) |
                          (state[3:0] == SM_RES_RST) | (state[3:0] == SM_RES_PWR) |
                          (((state[3:0] == SM_DEV) | (state[3:0] == SM_DEV_WAIT)) & ~diu_accept_i);


  assign cri_lookup_value[3:0] = (cri_lookup_sel)? pwr_st[3:0]:trans_target_pwr_mode_i[3:0];

  //Calculate next values for:
  //-DEVxCLKEN
  //-DEVxISOLATEn
  //-DEVxRESETn
  //Next values depend on:
  //Target Power Mode if transition has not been denied
  //PWR_ST if transition has been denied
  always@*
  begin
    case(cri_lookup_value[3:0])
    P_OFF:
    begin
      //OFF
      nxt_devclken_r = 1'b0;
      nxt_devisolaten_r = 1'b0;
      nxt_devwarmresetn_r = 1'b0;
      nxt_devporesetn_r = 1'b0;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_OFF;
    end
    P_MEM_RET:
    begin
      //MEM_RET
      nxt_devclken_r = 1'b0;
      nxt_devisolaten_r = 1'b0;
      nxt_devwarmresetn_r = 1'b0;
      nxt_devporesetn_r = 1'b0;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_MEM_RET;
    end
    P_MEM_OFF:
    begin
      //MEM_OFF
      nxt_devclken_r = 1'b1;
      nxt_devisolaten_r = 1'b1;
      nxt_devwarmresetn_r = 1'b1;
      nxt_devporesetn_r = 1'b1;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_MEM_OFF;
    end
    P_FUNC_RET:
    begin
      //FUNC_RET
      nxt_devclken_r = 1'b1;
      nxt_devisolaten_r = 1'b1;
      nxt_devwarmresetn_r = 1'b1;
      nxt_devporesetn_r = 1'b1;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_FUNC_RET;
    end
    P_ON:
    begin
      //ON
      nxt_devclken_r = 1'b1;
      nxt_devisolaten_r = 1'b1;
      nxt_devwarmresetn_r = 1'b1;
      nxt_devporesetn_r = 1'b1;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_ON;
    end
    P_WRM_RST:
    begin
      //WRM_RST
      nxt_devclken_r = 1'b1;
      nxt_devisolaten_r = 1'b1;
      nxt_devwarmresetn_r = 1'b0;
      nxt_devporesetn_r = 1'b1;
      nxt_ppuhwstat_pwr_mode_r[15:0] = PPUHWSTAT_WRM_RST;
    end
    default:
    begin
      //X-Prop
      nxt_devclken_r = 1'bx;
      nxt_devisolaten_r = 1'bx;
      nxt_devwarmresetn_r = 1'bx;
      nxt_devporesetn_r = 1'bx;
      nxt_ppuhwstat_pwr_mode_r[15:0] = 16'hxxxx;
    end
    endcase
  end


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      ppuhwstat_pwr_mode_r[15:0] <= PPUHWSTAT_OFF;
    end
    else if(hwstat_en)
    begin
      ppuhwstat_pwr_mode_r[15:0] <= nxt_ppuhwstat_pwr_mode_r[15:0];
    end
  end



  assign diu_req_o[1:0] = diu_req[1:0];
  assign diu_pwr_mode_o[3:0] = diu_pwr_mode[3:0];
  assign diu_stall_o = diu_stall;

  assign piu_req_o = piu_req;
  assign piu_pwr_mode_o[3:0] = piu_pwr_mode[3:0];

  assign pwr_st_o[3:0] = pwr_st[3:0];
  assign pwr_dyn_st_o = pwr_dyn_st_r;

  assign devclken_o = devclken_r;
  assign devemuclken_o = devclken_r;
  assign devisolaten_o = devisolaten_r;
  assign devemuisolaten_o = devisolaten_r;
  assign devwarmresetn_o = devwarmresetn_r;
  assign devretresetn_o = devwarmresetn_r;
  assign devporesetn_o = devporesetn_r;

  assign ppuhwstat_o[PPUHWSTAT_WIDTH-1:0] = ppuhwstat_pwr_mode_r[15:0];

  assign trans_comp_o = trans_comp;
  assign trans_comp_accept_o = trans_comp & trans_comp_accept_r;
  assign trans_comp_deny_o = trans_comp & ~trans_comp_accept_r;
  assign pwr_policy_revert_o = pwr_policy_revert;

  assign psm_idle_o = ~trans_start_req_i;

endmodule
