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


module pck600_ppu_pcsm_sse710_extsys
#(
  //Logic Control Delays
  parameter LGC_OFF_ON_DLY = 8'h08,
  parameter LGC_ON_OFF_DLY = 8'h08,
  parameter LGC_ON_ONRET_DLY = 8'h08,
  parameter LGC_ONRET_RET_DLY = 8'h08,
  parameter LGC_ONRET_ON_DLY = 8'h08,
  parameter LGC_RET_ONRET_DLY = 8'h08,

  //RAM Control Delays
  parameter RAM_OFF_ON_DLY = 8'h08,
  parameter RAM_ON_OFF_DLY = 8'h08,
  parameter RAM_ON_ONRET_DLY = 8'h08,
  parameter RAM_ONRET_RET_DLY = 8'h08,
  parameter RAM_ONRET_ON_DLY = 8'h08,
  parameter RAM_RET_ONRET_DLY = 8'h08,
  parameter RAM_OFF_RET_DLY = 8'h08
)
(

  //Clock and Reset
  input wire                  clk,
  input wire                  reset_n,

  //DFT
  input wire                  dftpwrup,
  input wire                  dftretdisable,

  //PCSM P-Channel
  input wire                  pcsm_preq_i,
  input wire [3:0]            pcsm_pstate_i,
  output wire                 pcsm_paccept_o,

  //Power Switch Control
  output wire                 lgcpwrn_o,
  output wire                 lgcretn_o,
  output wire                 rampwrn_o,
  output wire                 ramretn_o

);

  `include "pck600_ppu_config_sse710_extsys.v"
  `include "pck600_ppu_enum_sse710_extsys.v"

  localparam NUM_RAM_BANK = (OPMODE_PCSM_SPT_CFG)? NUM_OP_DEVACTIVE:1;

  localparam TINT = 5'h00;
  localparam LGC_ON_INIT = 5'h01;
  localparam RAM_ON_INIT = 5'h02;
  localparam P_STABLE_OFF = 5'h03;
  localparam P_STABLE_MEM_RET = 5'h04;
  localparam P_STABLE_LGC_RET = 5'h05;
  localparam P_STABLE_FULL_RET = 5'h06;
  localparam P_STABLE_MEM_OFF = 5'h07;
  localparam P_STABLE_FUNC_RET = 5'h08;
  localparam P_STABLE_ON = 5'h09;
  localparam LGC_ON = 5'h0A;
  localparam LGC_RETON = 5'h0B;
  localparam LGC_ONRET = 5'h0C;
  localparam LGC_OFF = 5'h0D;
  localparam LGC_RET = 5'h0E;
  localparam RAM_ON = 5'h0F;
  localparam RAM_RETON = 5'h10;
  localparam RAM_ONRET = 5'h11;
  localparam RAM_OFF = 5'h12;
  localparam RAM_RET = 5'h13;
  localparam RAM_OFF_RET = 5'h14;
  localparam P_ACCEPT_OFF = 5'h15;
  localparam P_ACCEPT_MEM_RET = 5'h16;
  localparam P_ACCEPT_LGC_RET = 5'h17;
  localparam P_ACCEPT_FULL_RET = 5'h18;
  localparam P_ACCEPT_MEM_OFF = 5'h19;
  localparam P_ACCEPT_FUNC_RET = 5'h1A;
  localparam P_ACCEPT_ON = 5'h1B;

  localparam SEL_LGC_OFF_ON_DLY = 4'h0;
  localparam SEL_LGC_ON_OFF_DLY = 4'h1;
  localparam SEL_LGC_ON_ONRET_DLY = 4'h2;
  localparam SEL_LGC_ONRET_RET_DLY = 4'h3;
  localparam SEL_LGC_RET_ONRET_DLY = 4'h4;
  localparam SEL_LGC_ONRET_ON_DLY = 4'h5;
  localparam SEL_RAM_OFF_ON_DLY = 4'h8;
  localparam SEL_RAM_ON_OFF_DLY = 4'h9;
  localparam SEL_RAM_ON_ONRET_DLY = 4'hA;
  localparam SEL_RAM_ONRET_RET_DLY = 4'hB;
  localparam SEL_RAM_RET_ONRET_DLY = 4'hC;
  localparam SEL_RAM_ONRET_ON_DLY = 4'hD;
  localparam SEL_RAM_OFF_RET_DLY = 4'hE;
  localparam SEL_ZERO_DLY = 4'hF;


  genvar                      I;

  reg                         pcsm_preq_r;
  wire                        pcsm_pstate_en;
  wire [PCSMPSTATE_WIDTH-1:0] pcsm_pstate_sync;

  reg                         tinit_r;
  wire                        tinit_preq_delay;
  wire                        tinit_req;

  wire [3:0]                  pcsm_pwr_mode;
  wire                        turn_ram_bank_off;
  wire                        turn_ram_bank_on;
  wire [NUM_RAM_BANK-1:0]     ram_bank_pwr_status;
  wire [NUM_RAM_BANK-1:0]     ram_bank_ret_status;

  reg [3:0]                   curr_pwr_mode_r;
  wire                        curr_mode_en;

  reg [4:0]                   state;
  reg                         pcsm_paccept_r;
  reg                         lgc_pwr_n_r;
  reg                         lgc_ret_n_r;
  reg [NUM_RAM_BANK-1:0]      ram_pwr_n_r;
  reg [NUM_RAM_BANK-1:0]      ram_ret_n_r;
  wire                        sm_idle;

  reg [4:0]                   nxt_state;
  reg                         state_en;
  reg                         nxt_pcsm_paccept_r;
  reg                         nxt_lgc_pwr_n_r;
  reg                         nxt_lgc_ret_n_r;
  reg [NUM_RAM_BANK-1:0]      nxt_ram_pwr_n_r;
  reg [NUM_RAM_BANK-1:0]      nxt_ram_ret_n_r;

  reg [PCSMPSTATE_WIDTH-1:0]  pcsm_mode_stat_r;
  wire                        pcsm_mode_stat_en;

  reg [7:0]                   dly_counter_r;
  reg [7:0]                   nxt_dly_counter_r;
  wire                        dly_counter_en;
  wire                        dly_counter_load;
  wire                        dly_counter_dec;
  wire                        dly_counter_expired;
  reg [3:0]                   dly_counter_sel;
  reg [7:0]                   dly_counter_load_value;

  wire [7:0]                  lgc_off_on_dly_int;
  wire [7:0]                  lgc_on_off_dly_int;
  wire [7:0]                  lgc_on_onret_dly_int;
  wire [7:0]                  lgc_onret_ret_dly_int;
  wire [7:0]                  lgc_ret_onret_dly_int;
  wire [7:0]                  lgc_onret_on_dly_int;
  wire [7:0]                  ram_off_on_dly_int;
  wire [7:0]                  ram_on_off_dly_int;
  wire [7:0]                  ram_on_onret_dly_int;
  wire [7:0]                  ram_onret_ret_dly_int;
  wire [7:0]                  ram_ret_onret_dly_int;
  wire [7:0]                  ram_onret_on_dly_int;
  wire [7:0]                  ram_off_ret_dly_int;

  wire                        pcsm_preq_ss;



generate
if(PCSM_SYNC_EN)
begin:pchannel_async

  pck600_cdc_capt_sync
  u_pck600_cdc_capt_sync_pcsm_preq
  (
    .clk     (clk),
    .reset_n (reset_n),
    .async   (pcsm_preq_i),
    .sync    (pcsm_preq_ss)
  );

  pck600_cdc_capt_sync
  u_pck600_cdc_capt_sync_preq_delay
  (
    .clk      (clk),
    .reset_n  (reset_n),
    .async    (1'b1),
    .sync     (tinit_preq_delay)
  );

  pck600_cdc_capt_nosync
  #(
    .IH  (PCSMPSTATE_WIDTH-1),
    .IL  (0)
  )
  u_pck600_cdc_capt_nosync_pcsm_pstate
  (
    .clk     (clk),
    .reset_n (reset_n),
    .en      (pcsm_pstate_en),
    .async   (pcsm_pstate_i),
    .sync    (pcsm_pstate_sync)
  );

end
else
begin:pchannel_sync

  reg [PCSMPSTATE_WIDTH-1:0]  pcsm_pstate_r;

  assign pcsm_preq_ss = pcsm_preq_i;
  assign tinit_preq_delay = 1'b1;

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] <= {PCSMPSTATE_WIDTH{1'b0}};
    end
    else if(pcsm_pstate_en)
    begin
      pcsm_pstate_r[PCSMPSTATE_WIDTH-1:0] <= pcsm_pstate_i[PCSMPSTATE_WIDTH-1:0];
    end
  end

  assign pcsm_pstate_sync = pcsm_pstate_r;

end
endgenerate

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pcsm_preq_r <= 1'b0;
    end
    else
    begin
      pcsm_preq_r <= pcsm_preq_ss;
    end
  end

  assign pcsm_pstate_en = ((pcsm_preq_ss & ~pcsm_preq_r) & sm_idle) | ~tinit_preq_delay;


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      tinit_r <= 1'b0;
    end
    else
    begin
      tinit_r <= tinit_preq_delay;
    end
  end

  assign tinit_req = ~tinit_r & tinit_preq_delay;


generate
if(OPMODE_PCSM_SPT_CFG > 0)
begin:op_mode_pcsm_spt

  wire [OP_MODE_WIDTH-1:0]    pcsm_op_mode;
  reg [OP_MODE_WIDTH-1:0]     curr_op_mode_r;

  assign pcsm_pwr_mode[3:0] = pcsm_pstate_sync[3:0];
  assign pcsm_op_mode[OP_MODE_WIDTH-1:0] = pcsm_pstate_sync[4 +: OP_MODE_WIDTH];

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      curr_pwr_mode_r[3:0] <= P_OFF;
      curr_op_mode_r[OP_MODE_WIDTH-1:0] <= {OP_MODE_WIDTH{1'b0}};
    end
    else if(curr_mode_en)
    begin
      curr_pwr_mode_r[3:0] <= pcsm_pwr_mode[3:0];
      curr_op_mode_r[OP_MODE_WIDTH-1:0] <= pcsm_op_mode[OP_MODE_WIDTH-1:0];
    end
  end

  assign curr_mode_en = state_en & ((nxt_state[4:0] == P_STABLE_OFF) |
                                    (nxt_state[4:0] == P_STABLE_MEM_RET) |
                                    (nxt_state[4:0] == P_STABLE_LGC_RET) |
                                    (nxt_state[4:0] == P_STABLE_FULL_RET) |
                                    (nxt_state[4:0] == P_STABLE_MEM_OFF) |
                                    (nxt_state[4:0] == P_STABLE_FUNC_RET) |
                                    (nxt_state[4:0] == P_STABLE_ON));


  if(OP_ACTIVE_CFG)
  begin:independent_op_modes

    assign turn_ram_bank_off = |(curr_op_mode_r[OP_MODE_WIDTH-1:0] & ~pcsm_op_mode[OP_MODE_WIDTH-1:0]);
    assign turn_ram_bank_on = |(~curr_op_mode_r[OP_MODE_WIDTH-1:0] & pcsm_op_mode[OP_MODE_WIDTH-1:0]);

    assign ram_bank_pwr_status[NUM_RAM_BANK-1:0] = ~(pcsm_op_mode[OP_MODE_WIDTH-1:0] & {OP_MODE_WIDTH{(pcsm_pwr_mode[3:0] == P_ON)}});
    assign ram_bank_ret_status[NUM_RAM_BANK-1:0] = ~(pcsm_op_mode[OP_MODE_WIDTH-1:0] & {OP_MODE_WIDTH{((pcsm_pwr_mode[3:0] == P_FUNC_RET) |
                                                                                                    (pcsm_pwr_mode[3:0] == P_FULL_RET) |
                                                                                                    (pcsm_pwr_mode[3:0] == P_MEM_RET))}});

  end
  else
  begin:ladder_op_modes

    assign turn_ram_bank_off = (curr_op_mode_r[OP_MODE_WIDTH-1:0] > pcsm_op_mode[OP_MODE_WIDTH-1:0]);
    assign turn_ram_bank_on = (curr_op_mode_r[OP_MODE_WIDTH-1:0] < pcsm_op_mode[OP_MODE_WIDTH-1:0]);

    for(I=0; I<NUM_OPMODE_CFG; I=I+1)
    begin:ram_bank_status

      assign ram_bank_pwr_status[I] = ~((pcsm_op_mode[OP_MODE_WIDTH-1:0] > I[OP_MODE_WIDTH-1:0]) & (pcsm_pwr_mode[3:0] == P_ON));
      assign ram_bank_ret_status[I] = ~((pcsm_op_mode[OP_MODE_WIDTH-1:0] > I[OP_MODE_WIDTH-1:0]) & ((pcsm_pwr_mode[3:0] == P_FUNC_RET) |
                                                                                                 (pcsm_pwr_mode[3:0] == P_FULL_RET) |
                                                                                                 (pcsm_pwr_mode[3:0] == P_MEM_RET)));

    end

  end

end
else
begin:op_mode_no_pcsm_spt

  assign pcsm_pwr_mode[3:0] = pcsm_pstate_sync[3:0];

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      curr_pwr_mode_r[3:0] <= P_OFF;
    end
    else if(curr_mode_en)
    begin
      curr_pwr_mode_r[3:0] <= pcsm_pwr_mode[3:0];
    end
  end

  assign curr_mode_en = state_en & ((nxt_state[4:0] == P_STABLE_OFF) |
                                    (nxt_state[4:0] == P_STABLE_MEM_RET) |
                                    (nxt_state[4:0] == P_STABLE_LGC_RET) |
                                    (nxt_state[4:0] == P_STABLE_FULL_RET) |
                                    (nxt_state[4:0] == P_STABLE_MEM_OFF) |
                                    (nxt_state[4:0] == P_STABLE_FUNC_RET) |
                                    (nxt_state[4:0] == P_STABLE_ON));

  assign turn_ram_bank_off = 1'b0;
  assign turn_ram_bank_on = 1'b0;

  assign ram_bank_pwr_status[NUM_RAM_BANK-1:0] = ~({NUM_RAM_BANK{(pcsm_pwr_mode[3:0] == P_ON)}});
  assign ram_bank_ret_status[NUM_RAM_BANK-1:0] = ~({NUM_RAM_BANK{((pcsm_pwr_mode[3:0] == P_FUNC_RET) |
                                                                 (pcsm_pwr_mode[3:0] == P_FULL_RET) |
                                                                 (pcsm_pwr_mode[3:0] == P_MEM_RET))}});

end
endgenerate


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state[4:0] <= TINT;
      pcsm_paccept_r <= 1'b0;
      lgc_pwr_n_r <= 1'b1;
      lgc_ret_n_r <= 1'b1;
      ram_pwr_n_r[NUM_RAM_BANK-1:0] <= {NUM_RAM_BANK{1'b1}};
      ram_ret_n_r[NUM_RAM_BANK-1:0] <= {NUM_RAM_BANK{1'b1}};
    end
    else if(state_en)
    begin
      state <= nxt_state;
      pcsm_paccept_r <= nxt_pcsm_paccept_r;
      lgc_pwr_n_r <= nxt_lgc_pwr_n_r;
      lgc_ret_n_r <= nxt_lgc_ret_n_r;
      ram_pwr_n_r[NUM_RAM_BANK-1:0] <= nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0];
      ram_ret_n_r[NUM_RAM_BANK-1:0] <= nxt_ram_ret_n_r[NUM_RAM_BANK-1:0];
    end
  end

  assign sm_idle = ~pcsm_preq_r & ((state[4:0] == P_STABLE_OFF) |
                                   (state[4:0] == P_STABLE_MEM_RET) |
                                   (state[4:0] == P_STABLE_LGC_RET) |
                                   (state[4:0] == P_STABLE_FULL_RET) |
                                   (state[4:0] == P_STABLE_MEM_OFF) |
                                   (state[4:0] == P_STABLE_FUNC_RET) |
                                   (state[4:0] == P_STABLE_ON));

  always@*
  begin
    nxt_pcsm_paccept_r = pcsm_paccept_r;
    nxt_lgc_pwr_n_r = lgc_pwr_n_r;
    nxt_lgc_ret_n_r = lgc_ret_n_r;
    nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_pwr_n_r[NUM_RAM_BANK-1:0];
    nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = ram_ret_n_r[NUM_RAM_BANK-1:0];
    dly_counter_sel[3:0] = SEL_ZERO_DLY;
    case(state[4:0])
    TINT:
    begin
      state_en = tinit_req;
      case(pcsm_pwr_mode[3:0])
      P_OFF:
      begin
        nxt_state [4:0] = P_STABLE_OFF;
        nxt_lgc_pwr_n_r = 1'b1;
      end
      P_ON:
      begin
        nxt_state[4:0] = LGC_ON_INIT;
        nxt_lgc_pwr_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_OFF_ON_DLY;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_lgc_pwr_n_r = 1'bx;
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    LGC_ON_INIT:
    begin
      nxt_state[4:0] = RAM_ON_INIT;
      state_en = dly_counter_expired;
      nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
      dly_counter_sel[3:0] = SEL_RAM_OFF_ON_DLY;
    end 
    RAM_ON_INIT:
    begin
      nxt_state[4:0] = P_STABLE_ON;
      state_en = dly_counter_expired;
    end
    P_STABLE_OFF:
    begin
      state_en = pcsm_preq_r;
      case(pcsm_pwr_mode[3:0])
      P_OFF:
      begin
        nxt_state[4:0] = P_ACCEPT_OFF;
        nxt_pcsm_paccept_r = 1'b1;
      end
      P_MEM_RET:
      begin
        nxt_state[4:0] = RAM_OFF_RET;
        nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = ram_bank_ret_status[NUM_RAM_BANK-1:0];
        dly_counter_sel[3:0] = SEL_RAM_OFF_RET_DLY;
      end
      P_MEM_OFF,P_ON:
      begin
        nxt_state[4:0] = LGC_ON;
        nxt_lgc_pwr_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_OFF_ON_DLY;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_pcsm_paccept_r = 1'bx;
        nxt_lgc_pwr_n_r = 1'bx;
        nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    P_STABLE_MEM_RET:
    begin
      state_en = pcsm_preq_r;
      case(pcsm_pwr_mode[3:0])
      P_MEM_RET:
      begin
        nxt_state[4:0] = P_ACCEPT_MEM_RET;
        nxt_pcsm_paccept_r = 1'b1;
      end
      P_ON:
      begin
        nxt_state[4:0] = LGC_ON;
        nxt_lgc_pwr_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_OFF_ON_DLY;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_pcsm_paccept_r = 1'bx;
        nxt_lgc_pwr_n_r = 1'bx;
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    P_STABLE_LGC_RET:
    begin
      nxt_state[4:0] = LGC_RETON;
      state_en = pcsm_preq_r;
      nxt_lgc_pwr_n_r = 1'b0;
      dly_counter_sel[3:0] = SEL_LGC_RET_ONRET_DLY;
    end
    P_STABLE_FULL_RET:
    begin
      nxt_state[4:0] = LGC_RETON;
      state_en = pcsm_preq_r;
      nxt_lgc_pwr_n_r = 1'b0;
      dly_counter_sel[3:0] = SEL_LGC_RET_ONRET_DLY;
    end
    P_STABLE_MEM_OFF:
    begin
      state_en = pcsm_preq_r;
      case(pcsm_pwr_mode[3:0])
      P_OFF:
      begin
        nxt_state[4:0] = LGC_OFF;
        nxt_lgc_pwr_n_r = 1'b1;
        dly_counter_sel[3:0] = SEL_LGC_ON_OFF_DLY;
      end
      P_LGC_RET:
      begin
        nxt_state[4:0] = LGC_ONRET;
        nxt_lgc_ret_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_ON_ONRET_DLY;
      end
      P_ON:
      begin
        nxt_state[4:0] = RAM_ON;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
        dly_counter_sel[3:0] = SEL_RAM_OFF_ON_DLY;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_lgc_pwr_n_r = 1'bx;
        nxt_lgc_ret_n_r = 1'bx;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    P_STABLE_FUNC_RET:
    begin
      state_en = pcsm_preq_r;
      case(pcsm_pwr_mode[3:0])
      P_FULL_RET:
      begin
        nxt_state[4:0] = LGC_ONRET;
        nxt_lgc_ret_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_ON_ONRET_DLY;
      end
      P_ON:
      begin
        nxt_state[4:0] = RAM_RETON;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
        dly_counter_sel[3:0] = SEL_RAM_RET_ONRET_DLY;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_lgc_ret_n_r = 1'bx;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    P_STABLE_ON:
    begin
      state_en = pcsm_preq_r;
      case(pcsm_pwr_mode[3:0])
      P_OFF,P_MEM_OFF:
      begin
        nxt_state[4:0] = RAM_OFF;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
        dly_counter_sel[3:0] = SEL_RAM_ON_OFF_DLY;
      end
      P_MEM_RET,P_FULL_RET,P_FUNC_RET:
      begin
        nxt_state[4:0] = RAM_ONRET;
        nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = ram_bank_ret_status[NUM_RAM_BANK-1:0];
        dly_counter_sel[3:0] = SEL_RAM_ON_ONRET_DLY;
      end
      P_ON:
      begin
        case({turn_ram_bank_on,turn_ram_bank_off})
        2'b00:
        begin
          nxt_state[4:0] = P_ACCEPT_ON;
          nxt_pcsm_paccept_r = 1'b1;
        end
        2'b01,2'b11:
        begin
          nxt_state[4:0] = RAM_OFF;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
          dly_counter_sel[3:0] = SEL_RAM_ON_OFF_DLY;
        end
        2'b10:
        begin
          nxt_state[4:0] = RAM_ON;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
          dly_counter_sel[3:0] = SEL_RAM_OFF_ON_DLY;
        end
        default:
        begin
          nxt_state[4:0] = 5'hxx;
          nxt_pcsm_paccept_r = 1'bx;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
          dly_counter_sel[3:0] = 4'hx;
        end
        endcase
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
        nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    LGC_ON:
    begin
      state_en = dly_counter_expired;
      case(pcsm_pwr_mode[3:0])
      P_MEM_OFF:
      begin
        nxt_state[4:0] = P_ACCEPT_MEM_OFF;
        nxt_pcsm_paccept_r = 1'b1;
      end
      P_FUNC_RET:
      begin
        nxt_state[4:0] = P_ACCEPT_FUNC_RET;
        nxt_pcsm_paccept_r = 1'b1;
      end
      P_ON:
      begin
        case(curr_pwr_mode_r[3:0])
        P_OFF,P_LGC_RET:
        begin
          nxt_state[4:0] = RAM_ON;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
          dly_counter_sel[3:0] = SEL_RAM_OFF_ON_DLY;
        end
        P_MEM_RET,P_FULL_RET:
        begin
          nxt_state[4:0] = RAM_RETON;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
          dly_counter_sel[3:0] = SEL_RAM_RET_ONRET_DLY;
        end
        default:
        begin
          nxt_state[4:0] = 5'hxx;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
          dly_counter_sel[3:0] = 4'hx;
        end
        endcase
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_pcsm_paccept_r = 1'bx;
      end
      endcase
    end
    LGC_RETON:
    begin
      nxt_state[4:0] = LGC_ON;
      state_en = dly_counter_expired;
      nxt_lgc_ret_n_r = 1'b1;
      dly_counter_sel[3:0] = SEL_LGC_ONRET_ON_DLY;
    end
    LGC_ONRET:
    begin
      nxt_state[4:0] = LGC_RET;
      state_en = dly_counter_expired;
      nxt_lgc_pwr_n_r = 1'b1;
      dly_counter_sel[3:0] = SEL_LGC_ONRET_RET_DLY;
    end
    LGC_OFF:
    begin
      state_en = dly_counter_expired;
      nxt_pcsm_paccept_r = 1'b1;
      case(pcsm_pwr_mode[3:0])
      P_OFF:          nxt_state[4:0] = P_ACCEPT_OFF;
      P_MEM_RET[3:0]: nxt_state[4:0] = P_ACCEPT_MEM_RET;
      default:        nxt_state[4:0] = 5'hxx;
      endcase
    end
    LGC_RET:
    begin
      state_en = dly_counter_expired;
      nxt_pcsm_paccept_r = 1'b1;
      case(pcsm_pwr_mode[3:0])
      P_LGC_RET:  nxt_state[4:0] = P_ACCEPT_LGC_RET;
      P_FULL_RET: nxt_state[4:0] = P_ACCEPT_FULL_RET;
      default:    nxt_state[4:0] = 5'hxx;
      endcase
    end
    RAM_ON:
    begin
      nxt_state[4:0] = P_ACCEPT_ON;
      state_en = dly_counter_expired;
      nxt_pcsm_paccept_r = 1'b1;
    end
    RAM_RETON:
    begin
      nxt_state[4:0] = RAM_ON;
      state_en = dly_counter_expired;
      nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = ram_bank_ret_status[NUM_RAM_BANK-1:0];
      dly_counter_sel[3:0] = SEL_RAM_ONRET_ON_DLY;
    end
    RAM_ONRET:
    begin
      nxt_state[4:0] = RAM_RET;
      state_en = dly_counter_expired;
      nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
      dly_counter_sel[3:0] = SEL_RAM_ONRET_RET_DLY;
    end
    RAM_OFF:
    begin
      state_en = dly_counter_expired;
      case(pcsm_pwr_mode)
      P_OFF:
      begin
        nxt_state[4:0] = LGC_OFF;
        nxt_lgc_pwr_n_r = 1'b1;
        dly_counter_sel[3:0] = SEL_LGC_ON_OFF_DLY;
      end
      P_MEM_OFF:
      begin
        nxt_state[4:0] = P_ACCEPT_MEM_OFF;
        nxt_pcsm_paccept_r = 1'b1;
      end
      P_ON:
      begin
        case(turn_ram_bank_on)
        1'b0:
        begin
          nxt_state[4:0] = P_ACCEPT_ON;
          nxt_pcsm_paccept_r = 1'b1;
        end
        1'b1:
        begin
          nxt_state[4:0] = RAM_ON;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = ram_bank_pwr_status[NUM_RAM_BANK-1:0];
          dly_counter_sel[3:0] = SEL_RAM_OFF_ON_DLY;
        end
        default:
        begin
          nxt_state[4:0] = 5'hxx;
          nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
          dly_counter_sel[3:0] = 4'hx;
        end
        endcase
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_lgc_pwr_n_r = 1'bx;
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    RAM_RET:
    begin
      state_en = dly_counter_expired;
      case(pcsm_pwr_mode[3:0])
      P_MEM_RET:
      begin
        nxt_state[4:0] = LGC_OFF;
        nxt_lgc_pwr_n_r = 1'b1;
        dly_counter_sel[3:0] = SEL_LGC_ON_OFF_DLY;
      end
      P_FULL_RET:
      begin
        nxt_state[4:0] = LGC_ONRET;
        nxt_lgc_ret_n_r = 1'b0;
        dly_counter_sel[3:0] = SEL_LGC_ON_ONRET_DLY;
      end
      P_FUNC_RET:
      begin
        nxt_state[4:0] = P_ACCEPT_FUNC_RET;
        nxt_pcsm_paccept_r = 1'b1;
      end
      default:
      begin
        nxt_state[4:0] = 5'hxx;
        nxt_pcsm_paccept_r = 1'bx;
        nxt_lgc_pwr_n_r = 1'bx;
        nxt_lgc_ret_n_r = 1'bx;
        dly_counter_sel[3:0] = 4'hx;
      end
      endcase
    end
    RAM_OFF_RET:
    begin
      nxt_state[4:0] = P_ACCEPT_MEM_RET;
      state_en = dly_counter_expired;
      nxt_pcsm_paccept_r = 1'b1;
    end
    P_ACCEPT_OFF:
    begin
      nxt_state[4:0] = P_STABLE_OFF;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_MEM_RET:
    begin
      nxt_state[4:0] = P_STABLE_MEM_RET;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_LGC_RET:
    begin
      nxt_state[4:0] = P_STABLE_LGC_RET;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_FULL_RET:
    begin
      nxt_state[4:0] = P_STABLE_FULL_RET;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_MEM_OFF:
    begin
      nxt_state[4:0] = P_STABLE_MEM_OFF;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_FUNC_RET:
    begin
      nxt_state[4:0] = P_STABLE_FUNC_RET;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    P_ACCEPT_ON:
    begin
      nxt_state[4:0] = P_STABLE_ON;
      state_en = ~pcsm_preq_ss;
      nxt_pcsm_paccept_r = 1'b0;
    end
    default:
    begin
      nxt_state[4:0] = 5'hxx;
      state_en = 1'bx;
      nxt_pcsm_paccept_r = 1'bx;
      nxt_lgc_pwr_n_r = 1'bx;
      nxt_lgc_ret_n_r = 1'bx;
      nxt_ram_pwr_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
      nxt_ram_ret_n_r[NUM_RAM_BANK-1:0] = {NUM_RAM_BANK{1'bx}};
    end
    endcase
  end


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      pcsm_mode_stat_r[PCSMPSTATE_WIDTH-1:0] <= {PCSMPSTATE_WIDTH{1'b0}};
    end
    else if(pcsm_mode_stat_en)
    begin
      pcsm_mode_stat_r[PCSMPSTATE_WIDTH-1:0] <= pcsm_pstate_sync[PCSMPSTATE_WIDTH-1:0];
    end
  end


  assign pcsm_mode_stat_en = ((state[4:0] == P_ACCEPT_OFF) |
                             (state[4:0] == P_ACCEPT_MEM_RET) |
                             (state[4:0] == P_ACCEPT_LGC_RET) |
                             (state[4:0] == P_ACCEPT_FULL_RET) |
                             (state[4:0] == P_ACCEPT_MEM_OFF) |
                             (state[4:0] == P_ACCEPT_FUNC_RET) |
                             (state[4:0] == P_ACCEPT_ON)) & state_en;


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dly_counter_r[7:0] <= 8'h00;
    end
    else if(dly_counter_en)
    begin
      dly_counter_r[7:0] <= nxt_dly_counter_r[7:0];
    end
  end

  assign dly_counter_en = dly_counter_load | dly_counter_dec;

  always@*
  begin
    case({dly_counter_load,dly_counter_dec})
    2'b00:    nxt_dly_counter_r[7:0] = dly_counter_r[7:0];
    2'b01:    nxt_dly_counter_r[7:0] = dly_counter_r[7:0] - 8'h01;
    2'b10:    nxt_dly_counter_r[7:0] = dly_counter_load_value[7:0];
    2'b11:    nxt_dly_counter_r[7:0] = dly_counter_load_value[7:0];
    default:  nxt_dly_counter_r[7:0] = 8'hxx;
    endcase
  end

  assign dly_counter_load = state_en;

  assign dly_counter_dec = |dly_counter_r[7:0];

  assign dly_counter_expired = (dly_counter_r[7:0] == 8'h00);

  always@*
  begin
    case(dly_counter_sel[3:0])
    SEL_LGC_OFF_ON_DLY:     dly_counter_load_value[7:0] = lgc_off_on_dly_int[7:0];
    SEL_LGC_ON_OFF_DLY:     dly_counter_load_value[7:0] = lgc_on_off_dly_int[7:0];
    SEL_LGC_ON_ONRET_DLY:   dly_counter_load_value[7:0] = lgc_on_onret_dly_int[7:0];
    SEL_LGC_ONRET_RET_DLY:  dly_counter_load_value[7:0] = lgc_onret_ret_dly_int[7:0];
    SEL_LGC_RET_ONRET_DLY:  dly_counter_load_value[7:0] = lgc_ret_onret_dly_int[7:0];
    SEL_LGC_ONRET_ON_DLY:   dly_counter_load_value[7:0] = lgc_onret_on_dly_int[7:0];
    SEL_RAM_OFF_ON_DLY:     dly_counter_load_value[7:0] = ram_off_on_dly_int[7:0];
    SEL_RAM_ON_OFF_DLY:     dly_counter_load_value[7:0] = ram_on_off_dly_int[7:0];
    SEL_RAM_ON_ONRET_DLY:   dly_counter_load_value[7:0] = ram_on_onret_dly_int[7:0];
    SEL_RAM_ONRET_RET_DLY:  dly_counter_load_value[7:0] = ram_onret_ret_dly_int[7:0];
    SEL_RAM_RET_ONRET_DLY:  dly_counter_load_value[7:0] = ram_ret_onret_dly_int[7:0];
    SEL_RAM_ONRET_ON_DLY:   dly_counter_load_value[7:0] = ram_onret_on_dly_int[7:0];
    SEL_RAM_OFF_RET_DLY:    dly_counter_load_value[7:0] = ram_off_ret_dly_int[7:0];
    SEL_ZERO_DLY:           dly_counter_load_value[7:0] = 8'h00;
    default:                dly_counter_load_value[7:0] = 8'hxx;
    endcase
  end

  assign lgc_off_on_dly_int[7:0] = LGC_OFF_ON_DLY[7:0];
  assign lgc_on_off_dly_int[7:0] = LGC_ON_OFF_DLY[7:0];
  assign lgc_on_onret_dly_int[7:0] = LGC_ON_ONRET_DLY[7:0];
  assign lgc_onret_ret_dly_int[7:0] = LGC_ONRET_RET_DLY[7:0];
  assign lgc_ret_onret_dly_int[7:0] = LGC_RET_ONRET_DLY[7:0];
  assign lgc_onret_on_dly_int[7:0] = LGC_ONRET_ON_DLY[7:0];
  assign ram_off_on_dly_int[7:0] = RAM_OFF_ON_DLY[7:0];
  assign ram_on_off_dly_int[7:0] = RAM_ON_OFF_DLY[7:0];
  assign ram_on_onret_dly_int[7:0] = RAM_ON_ONRET_DLY[7:0];
  assign ram_onret_ret_dly_int[7:0] = RAM_ONRET_RET_DLY[7:0];
  assign ram_ret_onret_dly_int[7:0] = RAM_RET_ONRET_DLY[7:0];
  assign ram_onret_on_dly_int[7:0] = RAM_ONRET_ON_DLY[7:0];
  assign ram_off_ret_dly_int[7:0] = RAM_OFF_RET_DLY[7:0];


  assign pcsm_paccept_o = pcsm_paccept_r;

  assign lgcpwrn_o = lgc_pwr_n_r & ~dftpwrup;
  assign lgcretn_o = lgc_ret_n_r | dftretdisable;
  assign rampwrn_o = ram_pwr_n_r[0] & ~dftpwrup;
  assign ramretn_o = ram_ret_n_r[0] | dftretdisable;

endmodule

