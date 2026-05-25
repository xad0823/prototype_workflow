//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti_reg_block
#(
  parameter NUM_EVENT_SLAVES  = 1,
  parameter NUM_EVENT_MASTERS = 1,
  parameter SW_HANDSHAKE      = 32'h0000_0000,
  parameter CHANNEL_WIDTH     = 4,
  parameter APB_ADDR_WIDTH    = 12,
  parameter APB_DATA_WIDTH    = 32,
  parameter EXT_MUX_NUM       = 0
)(
  input  wire                                       clk,
  input  wire                                       reset_n,
  input  wire                                       apb_write,
  input  wire                                       apb_read,
  input  wire [APB_ADDR_WIDTH-1:0]                  apb_addr,
  input  wire [APB_DATA_WIDTH-1:0]                  apb_wdata,
  output wire [APB_DATA_WIDTH-1:0]                  apb_rdata,
  input  wire [NUM_EVENT_SLAVES-1:0]                trig_in_status,
  input  wire [NUM_EVENT_MASTERS-1:0]               trig_out_status,
  input  wire [CHANNEL_WIDTH-1:0]                   ch_in_status,
  input  wire [CHANNEL_WIDTH-1:0]                   ch_out_status,
  input  wire                                       niden_status,
  input  wire                                       dbgen_status,
  input  wire [63:0]                                devaff,
  output wire                                       cti_en,
  output wire [CHANNEL_WIDTH-1:0]                   ch_out_enable,
  output wire [CHANNEL_WIDTH*NUM_EVENT_SLAVES-1:0]  trig_in_en,
  output wire [CHANNEL_WIDTH*NUM_EVENT_MASTERS-1:0] trig_out_en,
  output wire [CHANNEL_WIDTH-1:0]                   app_trigger,
  output wire [NUM_EVENT_MASTERS-1:0]               cti_int_ack,
  output wire [7:0]                                 asicctrl,
  output wire                                       iten,
  output wire [CHANNEL_WIDTH-1:0]                   it_ch_out,
  output wire [NUM_EVENT_MASTERS-1:0]               it_trig_out,
  input  wire [3:0]                                 revand
);

`include "css600_cti_localparams.v"

  localparam [7:0] NUM_TRIG   = (NUM_EVENT_SLAVES > NUM_EVENT_MASTERS) ? NUM_EVENT_SLAVES[7:0] : NUM_EVENT_MASTERS[7:0];
  localparam [3:0] NUM_CH     = CHANNEL_WIDTH[3:0];
  localparam [4:0] NUM_EXTMUX = EXT_MUX_NUM[4:0];

  wire                      cti_control_sel;
  wire                      cti_int_ack_sel;
  wire                      cti_app_set_sel;
  wire                      cti_app_clear_sel;
  wire                      cti_app_pulse_sel;
  wire                      cti_ch_gate_sel;
  wire                      asic_ctrl_sel;
  wire                      it_ctrl_sel;
  wire                      it_chout_sel;
  wire                      it_trigout_sel;
  wire                      it_chin_sel;
  wire                      it_trigin_sel;
  wire                      trigin_status_sel;
  wire                      trigout_status_sel;
  wire                      chin_status_sel;
  wire                      chout_status_sel;
  wire                      claim_tag_set_sel;
  wire                      claim_tag_clear_sel;
  wire                      devaff0_sel;
  wire                      devaff1_sel;
  wire                      auth_status_sel;
  wire                      devarch_sel;
  wire                      devid_sel;
  wire                      devtype_sel;
  wire                      pidr4_sel;
  wire                      pidr0_sel;
  wire                      pidr1_sel;
  wire                      pidr2_sel;
  wire                      pidr3_sel;
  wire                      cidr0_sel;
  wire                      cidr1_sel;
  wire                      cidr2_sel;
  wire                      cidr3_sel;

  wire                      cti_control_wr_en;
  wire                      cti_int_ack_wr_en;
  wire                      cti_app_set_wr_en;
  wire                      cti_app_clear_wr_en;
  wire                      cti_app_pulse_wr_en;
  wire                      cti_ch_gate_wr_en;
  wire                      asic_ctrl_wr_en;
  wire                      it_ctrl_wr_en;
  wire                      it_chout_wr_en;
  wire                      it_trigout_wr_en;
  wire                      claim_tag_set_wr_en;
  wire                      claim_tag_clear_wr_en;

  wire                      cti_control_rd_en;
  wire                      cti_app_set_rd_en;
  wire                      cti_ch_gate_rd_en;
  wire                      asic_ctrl_rd_en;
  wire                      it_ctrl_rd_en;
  wire                      it_chin_rd_en;
  wire                      it_trigin_rd_en;
  wire                      trigin_status_rd_en;
  wire                      trigout_status_rd_en;
  wire                      chin_status_rd_en;
  wire                      chout_status_rd_en;
  wire                      claim_tag_set_rd_en;
  wire                      claim_tag_clear_rd_en;
  wire                      devaff0_rd_en;
  wire                      devaff1_rd_en;
  wire                      auth_status_rd_en;
  wire                      devarch_rd_en;
  wire                      devid_rd_en;
  wire                      devtype_rd_en;
  wire                      pidr4_rd_en;
  wire                      pidr0_rd_en;
  wire                      pidr1_rd_en;
  wire                      pidr2_rd_en;
  wire                      pidr3_rd_en;
  wire                      cidr0_rd_en;
  wire                      cidr1_rd_en;
  wire                      cidr2_rd_en;
  wire                      cidr3_rd_en;

  wire                         cti_control_rd_data;
  wire [CHANNEL_WIDTH-1:0]     cti_app_set_rd_data;
  wire [CHANNEL_WIDTH-1:0]     cti_ch_gate_rd_data;
  wire [7:0]                   asic_ctrl_rd_data;
  wire [CHANNEL_WIDTH-1:0]     cti_in_en_rd_data;
  wire [NUM_EVENT_SLAVES-1:0]  cti_in_en_rd_data0;
  wire [NUM_EVENT_SLAVES-1:0]  cti_in_en_rd_data1;
  wire [NUM_EVENT_SLAVES-1:0]  cti_in_en_rd_data2;
  wire [NUM_EVENT_SLAVES-1:0]  cti_in_en_rd_data3;
  wire [CHANNEL_WIDTH-1:0]     cti_out_en_rd_data;
  wire [NUM_EVENT_MASTERS-1:0] cti_out_en_rd_data0;
  wire [NUM_EVENT_MASTERS-1:0] cti_out_en_rd_data1;
  wire [NUM_EVENT_MASTERS-1:0] cti_out_en_rd_data2;
  wire [NUM_EVENT_MASTERS-1:0] cti_out_en_rd_data3;
  wire                         it_ctrl_rd_data;
  wire [NUM_EVENT_MASTERS-1:0] it_trigout_rd_data;
  wire [CHANNEL_WIDTH-1:0]     it_chin_rd_data;
  wire [NUM_EVENT_SLAVES-1:0]  it_trigin_rd_data;
  wire [NUM_EVENT_SLAVES-1:0]  trigin_status_rd_data;
  wire [NUM_EVENT_MASTERS-1:0] trigout_status_rd_data;
  wire [CHANNEL_WIDTH-1:0]     chin_status_rd_data;
  wire [CHANNEL_WIDTH-1:0]     chout_status_rd_data;
  wire [3:0]                   claim_tag_set_rd_data;
  wire [3:0]                   claim_tag_clear_rd_data;
  wire [31:0]                  devaff0_rd_data;
  wire [31:0]                  devaff1_rd_data;
  wire [7:0]                   auth_status_rd_data;
  wire [31:0]                  devarch_rd_data;
  wire [25:0]                  devid_rd_data;
  wire [7:0]                   devtype_rd_data;
  wire [7:0]                   pidr4_rd_data;
  wire [7:0]                   pidr0_rd_data;
  wire [7:0]                   pidr1_rd_data;
  wire [7:0]                   pidr2_rd_data;
  wire [7:0]                   pidr3_rd_data;
  wire [7:0]                   cidr0_rd_data;
  wire [7:0]                   cidr1_rd_data;
  wire [7:0]                   cidr2_rd_data;
  wire [7:0]                   cidr3_rd_data;

  reg                          cti_control_q;
  reg  [CHANNEL_WIDTH-1:0]     cti_app_level_q;
  wire [CHANNEL_WIDTH-1:0]     cti_app_level;
  wire [CHANNEL_WIDTH-1:0]     cti_app_pulse;
  reg  [CHANNEL_WIDTH-1:0]     cti_ch_gate_q;
  reg  [7:0]                   asic_ctrl_q;
  reg                          it_ctrl_q;
  wire [CHANNEL_WIDTH-1:0]     it_chout;
  reg  [NUM_EVENT_MASTERS-1:0] it_trigout_q;
  reg  [CHANNEL_WIDTH-1:0]     it_chin_q;
  wire                         it_chin_q_en;
  wire [CHANNEL_WIDTH-1:0]     it_chin;
  reg  [NUM_EVENT_SLAVES-1:0]  it_trigin_q;
  wire                         it_trigin_q_en;
  wire [NUM_EVENT_SLAVES-1:0]  it_trigin;
  reg  [3:0]                   claim_tag_q;
  wire [3:0]                   claim_tag;

  genvar i;


  assign cti_control_sel       = (apb_addr[11:2] == CTICONTROL_ADDR);
  assign cti_control_wr_en     = apb_write & cti_control_sel;
  assign cti_control_rd_en     = apb_read & cti_control_sel;

  assign cti_control_rd_data   = cti_control_rd_en & cti_control_q;
  always @(posedge clk or negedge reset_n)
  begin : reg_cti_control
    if (!reset_n)
      cti_control_q <= 1'b0;
    else if (cti_control_wr_en)
      cti_control_q <= apb_wdata[0];
  end

  assign cti_en = cti_control_q;

  assign cti_int_ack_sel       = (apb_addr[11:2] == CTIINTACK_ADDR);
  assign cti_int_ack_wr_en     = apb_write & cti_int_ack_sel;

  assign cti_int_ack           = {NUM_EVENT_MASTERS{cti_int_ack_wr_en & cti_int_ack_sel}} & apb_wdata[NUM_EVENT_MASTERS-1:0];

  assign cti_app_set_sel       = (apb_addr[11:2] == CTIAPPSET_ADDR);
  assign cti_app_set_wr_en     = apb_write & cti_app_set_sel;
  assign cti_app_set_rd_en     = apb_read & cti_app_set_sel;
  assign cti_app_set_rd_data   = {CHANNEL_WIDTH{cti_app_set_rd_en}} & cti_app_level_q;
  assign cti_app_level = (
                           ({CHANNEL_WIDTH{cti_app_set_wr_en}}   & (cti_app_level_q |  apb_wdata[CHANNEL_WIDTH-1:0])) |
                           ({CHANNEL_WIDTH{cti_app_clear_wr_en}} & (cti_app_level_q & ~apb_wdata[CHANNEL_WIDTH-1:0]))
                         );
  always @(posedge clk or negedge reset_n)
  begin : reg_cti_app_level
    if (!reset_n)
       cti_app_level_q <= {CHANNEL_WIDTH{1'b0}};
    else if (cti_app_set_wr_en || cti_app_clear_wr_en)
       cti_app_level_q <= cti_app_level;
  end

  assign cti_app_clear_sel     = (apb_addr[11:2] == CTIAPPCLEAR_ADDR);
  assign cti_app_clear_wr_en   = apb_write & cti_app_clear_sel;

  assign cti_app_pulse_sel     = (apb_addr[11:2] == CTIAPPPULSE_ADDR);
  assign cti_app_pulse_wr_en   = apb_write & cti_app_pulse_sel;
  assign cti_app_pulse         = cti_app_pulse_wr_en ? apb_wdata[CHANNEL_WIDTH-1:0] : {CHANNEL_WIDTH{1'b0}};

  assign app_trigger = cti_app_pulse | cti_app_level_q;

  assign cti_ch_gate_sel       = (apb_addr[11:2] == CTIGATE_ADDR);
  assign cti_ch_gate_wr_en     = apb_write & cti_ch_gate_sel;
  assign cti_ch_gate_rd_en     = apb_read & cti_ch_gate_sel;
  assign cti_ch_gate_rd_data   = {CHANNEL_WIDTH{cti_ch_gate_rd_en}} & cti_ch_gate_q;
  always @(posedge clk or negedge reset_n)
  begin : reg_cti_ch_gate
    if (!reset_n)
       cti_ch_gate_q <= {CHANNEL_WIDTH{1'b1}};
    else if (cti_ch_gate_wr_en)
       cti_ch_gate_q <= apb_wdata[CHANNEL_WIDTH-1:0];
  end

  assign ch_out_enable = cti_ch_gate_q;

  assign asic_ctrl_sel       = (apb_addr[11:2] == ASICCTRL_ADDR);
  assign asic_ctrl_wr_en     = apb_write & asic_ctrl_sel;
  assign asic_ctrl_rd_en     = apb_read & asic_ctrl_sel;
  assign asic_ctrl_rd_data   = {8{asic_ctrl_rd_en}} & asic_ctrl_q;
  always @(posedge clk or negedge reset_n)
  begin : reg_asic_ctrl
    if (!reset_n)
       asic_ctrl_q <= {8{1'b0}};
    else if (asic_ctrl_wr_en)
       asic_ctrl_q <= apb_wdata[7:0];
  end

  assign asicctrl = asic_ctrl_q;

  generate
    for (i = 0; i < NUM_EVENT_SLAVES; i=i+1)
    begin : gen_cti_in_en

      reg  [CHANNEL_WIDTH-1:0]  cti_in_en_q;
      wire                      cti_in_en_sel;
      wire                      cti_in_en_wr_en;
      wire                      cti_in_en_rd_en;

      assign cti_in_en_sel       = ( apb_addr[11:2] == (CTIINEN0_ADDR+i[9:0]) );
      assign cti_in_en_wr_en     = apb_write & cti_in_en_sel;
      assign cti_in_en_rd_en     = apb_read & cti_in_en_sel;
      always @(posedge clk or negedge reset_n)
      begin : reg_cti_in_en
        if (!reset_n)
           cti_in_en_q <= {CHANNEL_WIDTH{1'b0}};
        else if (cti_in_en_wr_en)
           cti_in_en_q <= apb_wdata[CHANNEL_WIDTH-1:0];
      end

      assign cti_in_en_rd_data0[i] = cti_in_en_rd_en & cti_in_en_q[0];
      assign cti_in_en_rd_data1[i] = cti_in_en_rd_en & cti_in_en_q[1];
      assign cti_in_en_rd_data2[i] = cti_in_en_rd_en & cti_in_en_q[2];
      assign cti_in_en_rd_data3[i] = cti_in_en_rd_en & cti_in_en_q[3];

      assign trig_in_en[CHANNEL_WIDTH*i+CHANNEL_WIDTH-1:CHANNEL_WIDTH*i] = cti_in_en_q;

    end

  endgenerate

  assign cti_in_en_rd_data = { |cti_in_en_rd_data3, |cti_in_en_rd_data2, |cti_in_en_rd_data1, |cti_in_en_rd_data0 };

  generate
    for (i = 0; i < NUM_EVENT_MASTERS; i=i+1)
    begin : gen_cti_out_en

      reg  [CHANNEL_WIDTH-1:0]  cti_out_en_q;
      wire                      cti_out_en_sel;
      wire                      cti_out_en_wr_en;
      wire                      cti_out_en_rd_en;

      assign cti_out_en_sel       = ( apb_addr[11:2] == (CTIOUTEN0_ADDR+i[9:0]) );
      assign cti_out_en_wr_en     = apb_write & cti_out_en_sel;
      assign cti_out_en_rd_en     = apb_read & cti_out_en_sel;
      always @(posedge clk or negedge reset_n)
      begin : reg_cti_out_en
        if (!reset_n)
           cti_out_en_q <= {CHANNEL_WIDTH{1'b0}};
        else if (cti_out_en_wr_en)
           cti_out_en_q <= apb_wdata[CHANNEL_WIDTH-1:0];
      end

      assign cti_out_en_rd_data0[i] = cti_out_en_rd_en & cti_out_en_q[0];
      assign cti_out_en_rd_data1[i] = cti_out_en_rd_en & cti_out_en_q[1];
      assign cti_out_en_rd_data2[i] = cti_out_en_rd_en & cti_out_en_q[2];
      assign cti_out_en_rd_data3[i] = cti_out_en_rd_en & cti_out_en_q[3];

      assign trig_out_en[CHANNEL_WIDTH*i+CHANNEL_WIDTH-1:CHANNEL_WIDTH*i] = cti_out_en_q;

    end

  endgenerate

  assign cti_out_en_rd_data = { |cti_out_en_rd_data3, |cti_out_en_rd_data2, |cti_out_en_rd_data1, |cti_out_en_rd_data0 };


  assign trigin_status_sel      = (apb_addr[11:2] == TRIGINSTATUS_ADDR);
  assign trigin_status_rd_en    = apb_read & trigin_status_sel;
  assign trigin_status_rd_data  = {NUM_EVENT_SLAVES{trigin_status_rd_en}} & trig_in_status;

  assign trigout_status_sel     = (apb_addr[11:2] == TRIGOUTSTATUS_ADDR);
  assign trigout_status_rd_en   = apb_read & trigout_status_sel;
  assign trigout_status_rd_data = {NUM_EVENT_MASTERS{trigout_status_rd_en}} & trig_out_status;

  assign chin_status_sel        = (apb_addr[11:2] == CHINSTATUS_ADDR);
  assign chin_status_rd_en      = apb_read & chin_status_sel;
  assign chin_status_rd_data    = {CHANNEL_WIDTH{chin_status_rd_en}} & ch_in_status;

  assign chout_status_sel       = (apb_addr[11:2] == CHOUTSTATUS_ADDR);
  assign chout_status_rd_en     = apb_read & chout_status_sel;
  assign chout_status_rd_data   = {CHANNEL_WIDTH{chout_status_rd_en}} & ch_out_status;


  assign it_ctrl_sel       = (apb_addr[11:2] == ITCTRL_ADDR);
  assign it_ctrl_wr_en     = apb_write & it_ctrl_sel;
  assign it_ctrl_rd_en     = apb_read & it_ctrl_sel;

  assign it_ctrl_rd_data   = it_ctrl_rd_en & it_ctrl_q;
  always @(posedge clk or negedge reset_n)
  begin : reg_itctrl
    if (!reset_n)
      it_ctrl_q <= 1'b0;
    else if (it_ctrl_wr_en)
      it_ctrl_q <= apb_wdata[0];
  end

  assign iten = it_ctrl_q;

  assign it_chout_sel    = (apb_addr[11:2] == ITCHOUT_ADDR);
  assign it_chout_wr_en  = apb_write & it_chout_sel;
  assign it_chout        = it_chout_wr_en ? apb_wdata[CHANNEL_WIDTH-1:0] : {CHANNEL_WIDTH{1'b0}};

  assign it_ch_out = it_chout;

  assign it_trigout_sel       = (apb_addr[11:2] == ITTRIGOUT_ADDR);
  assign it_trigout_wr_en     = apb_write & it_trigout_sel;

  generate
  for (i = 0; i < NUM_EVENT_MASTERS; i=i+1)
  begin : gen_sw_handshake

    if ( SW_HANDSHAKE[i] == 1'b1 )
    begin : sw_handshake_enabled
      assign it_trigout_rd_data[i] = apb_read & it_trigout_sel & it_trigout_q[i];
      always @(posedge clk or negedge reset_n)
      begin : reg_it_trigout
        if (!reset_n)
           it_trigout_q[i] <= 1'b0;
        else if (it_trigout_wr_en)
           it_trigout_q[i] <= apb_wdata[i];
      end
      assign it_trig_out[i] = it_trigout_q[i];
    end

    else
    begin : sw_handshake_disabled
      assign it_trigout_rd_data[i] = 1'b0;
      assign it_trig_out[i]        = it_trigout_wr_en ? apb_wdata[i] : 1'b0;
    end

  end
  endgenerate

  assign it_chin_sel     = (apb_addr[11:2] == ITCHIN_ADDR);
  assign it_chin_rd_en   = apb_read & it_chin_sel;
  assign it_chin_rd_data = {CHANNEL_WIDTH{it_chin_rd_en}} & it_chin_q;
  generate
  for (i = 0; i < CHANNEL_WIDTH; i=i+1)
  begin : gen_it_chin
    assign it_chin[i] = ( iten && !(it_chin_rd_en && !ch_in_status[i]) ) ?
                        ( ch_in_status[i] | it_chin_q[i] )               :
                        1'b0;
  end
  endgenerate

  assign it_chin_q_en = |(it_chin_q ^ it_chin);
  always @(posedge clk or negedge reset_n)
  begin : reg_it_chin
    if (!reset_n)
       it_chin_q <= {CHANNEL_WIDTH{1'b0}};
    else if (it_chin_q_en)
       it_chin_q <= it_chin;
  end

  assign it_trigin_sel     = (apb_addr[11:2] == ITTRIGIN_ADDR);
  assign it_trigin_rd_en   = apb_read & it_trigin_sel;
  assign it_trigin_rd_data = {NUM_EVENT_SLAVES{it_trigin_rd_en}} & it_trigin_q;
  generate
  for (i = 0; i < NUM_EVENT_SLAVES; i=i+1)
  begin : gen_it_trigin
    assign it_trigin[i] = ( iten && !(it_trigin_rd_en && !trig_in_status[i]) ) ?
                          ( trig_in_status[i] | it_trigin_q[i] ) :
                          1'b0;
  end
  endgenerate

  assign it_trigin_q_en = |(it_trigin_q ^ it_trigin);
  always @(posedge clk or negedge reset_n)
  begin : reg_it_trigin
    if (!reset_n)
       it_trigin_q <= {NUM_EVENT_SLAVES{1'b0}};
    else if (it_trigin_q_en)
       it_trigin_q <= it_trigin;
  end


  assign claim_tag_set_sel       = (apb_addr[11:2] == CLAIMSET_ADDR);
  assign claim_tag_set_wr_en     = apb_write & claim_tag_set_sel;
  assign claim_tag_set_rd_en     = apb_read & claim_tag_set_sel;
  assign claim_tag_set_rd_data   = {4{claim_tag_set_rd_en}} & CLAIMSET_VAL;

  assign claim_tag_clear_sel     = (apb_addr[11:2] == CLAIMCLR_ADDR);
  assign claim_tag_clear_wr_en   = apb_write & claim_tag_clear_sel;
  assign claim_tag_clear_rd_en   = apb_read & claim_tag_clear_sel;
  assign claim_tag_clear_rd_data = {4{claim_tag_clear_rd_en}} & claim_tag_q;

  assign claim_tag = claim_tag_set_sel ? ( claim_tag_q |  apb_wdata[3:0])  :
                                         ( claim_tag_q & ~apb_wdata[3:0]);

  always @(posedge clk or negedge reset_n)
  begin : reg_claim_tag
    if (!reset_n)
       claim_tag_q <= 4'h0;
    else if (claim_tag_set_wr_en || claim_tag_clear_wr_en)
       claim_tag_q <= claim_tag;
  end

  assign devaff0_sel       = (apb_addr[11:2] == DEVAFF0_ADDR);
  assign devaff0_rd_en     = apb_read & devaff0_sel;
  assign devaff0_rd_data   = {32{devaff0_rd_en}} & devaff[31:0];

  assign devaff1_sel       = (apb_addr[11:2] == DEVAFF1_ADDR);
  assign devaff1_rd_en     = apb_read & devaff1_sel;
  assign devaff1_rd_data   = {32{devaff1_rd_en}} & devaff[63:32];


  assign auth_status_sel       = (apb_addr[11:2] == AUTHSTATUS_ADDR);
  assign auth_status_rd_en     = apb_read & auth_status_sel;
  assign auth_status_rd_data   = {8{auth_status_rd_en}} & { AUTHSTATUS_SNID_VAL , 1'b0,
                                                            AUTHSTATUS_SID_VAL  , 1'b0,
                                                            AUTHSTATUS_NSNID_VAL, niden_status | dbgen_status,
                                                            AUTHSTATUS_NSID_VAL , dbgen_status
                                                          };

  assign devarch_sel       = (apb_addr[11:2] == DEVARCH_ADDR);
  assign devarch_rd_en     = apb_read & devarch_sel;
  assign devarch_rd_data   = {32{devarch_rd_en}} & { DEVARCH_ARCHITECT_VAL,
                                                     DEVARCH_PRESENT_VAL,
                                                     DEVARCH_REVISION_VAL,
                                                     DEVARCH_ARCHID_VAL
                                                   };


  assign devid_sel       = (apb_addr[11:2] == DEVID_ADDR);
  assign devid_rd_en     = apb_read & devid_sel;
  assign devid_rd_data   = {26{devid_rd_en}} & { 2'h1,
                                                 4'h0,
                                                 NUM_CH,
                                                 NUM_TRIG,
                                                 3'h0,
                                                 NUM_EXTMUX
                                               };

  assign devtype_sel       = (apb_addr[11:2] == DEVTYPE_ADDR);
  assign devtype_rd_en     = apb_read & devtype_sel;
  assign devtype_rd_data   = {8{devtype_rd_en}} & { DEVTYPE_SUB_VAL,
                                                    DEVTYPE_MAJOR_VAL
                                                  };

  assign pidr4_sel       = (apb_addr[11:2] == PIDR4_ADDR);
  assign pidr4_rd_en     = apb_read & pidr4_sel;
  assign pidr4_rd_data   = {8{pidr4_rd_en}} & { PIDR4_SIZE_VAL,
                                                PIDR4_DES2_VAL
                                              };


  assign pidr0_sel       = (apb_addr[11:2] == PIDR0_ADDR);
  assign pidr0_rd_en     = apb_read & pidr0_sel;
  assign pidr0_rd_data   = {8{pidr0_rd_en}} & PIDR0_PART0_VAL;

  assign pidr1_sel       = (apb_addr[11:2] == PIDR1_ADDR);
  assign pidr1_rd_en     = apb_read & pidr1_sel;
  assign pidr1_rd_data   = {8{pidr1_rd_en}} & { PIDR1_DES0_VAL,
                                                PIDR1_PART1_VAL
                                              };

  assign pidr2_sel       = (apb_addr[11:2] == PIDR2_ADDR);
  assign pidr2_rd_en     = apb_read & pidr2_sel;
  assign pidr2_rd_data   = {8{pidr2_rd_en}} & { PIDR2_REVISION_VAL,
                                                PIDR2_JEDEC_VAL,
                                                PIDR2_DES1_VAL
                                              };

  assign pidr3_sel       = (apb_addr[11:2] == PIDR3_ADDR);
  assign pidr3_rd_en     = apb_read & pidr3_sel;
  assign pidr3_rd_data   = {8{pidr3_rd_en}} & { revand,
                                                PIDR3_CMOD_VAL
                                              };

  assign cidr0_sel       = (apb_addr[11:2] == CIDR0_ADDR);
  assign cidr0_rd_en     = apb_read & cidr0_sel;
  assign cidr0_rd_data   = {8{cidr0_rd_en}} & CIDR0_VAL;

  assign cidr1_sel       = (apb_addr[11:2] == CIDR1_ADDR);
  assign cidr1_rd_en     = apb_read & cidr1_sel;
  assign cidr1_rd_data   = {8{cidr1_rd_en}} & CIDR1_VAL;

  assign cidr2_sel       = (apb_addr[11:2] == CIDR2_ADDR);
  assign cidr2_rd_en     = apb_read & cidr2_sel;
  assign cidr2_rd_data   = {8{cidr2_rd_en}} & CIDR2_VAL;

  assign cidr3_sel       = (apb_addr[11:2] == CIDR3_ADDR);
  assign cidr3_rd_en     = apb_read & cidr3_sel;
  assign cidr3_rd_data   = {8{cidr3_rd_en}} & CIDR3_VAL;


  assign apb_rdata = (
                       ( { {(APB_DATA_WIDTH-1){1'b0}}                , cti_control_rd_data     } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , cti_app_set_rd_data     } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , cti_ch_gate_rd_data     } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , asic_ctrl_rd_data       } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , cti_in_en_rd_data       } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , cti_out_en_rd_data      } )   |
                       ( { {(APB_DATA_WIDTH-1){1'b0}}                , it_ctrl_rd_data         } )   |
                       ( { {(APB_DATA_WIDTH-NUM_EVENT_MASTERS){1'b0}}, it_trigout_rd_data      } )   |
                       ( { {(APB_DATA_WIDTH-NUM_EVENT_SLAVES){1'b0}} , trigin_status_rd_data   } )   |
                       ( { {(APB_DATA_WIDTH-NUM_EVENT_MASTERS){1'b0}}, trigout_status_rd_data  } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , chin_status_rd_data     } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , chout_status_rd_data    } )   |
                       ( { {(APB_DATA_WIDTH-CHANNEL_WIDTH){1'b0}}    , it_chin_rd_data         } )   |
                       ( { {(APB_DATA_WIDTH-NUM_EVENT_SLAVES){1'b0}} , it_trigin_rd_data       } )   |
                       ( { {(APB_DATA_WIDTH-4){1'b0}}                , claim_tag_set_rd_data   } )   |
                       ( { {(APB_DATA_WIDTH-4){1'b0}}                , claim_tag_clear_rd_data } )   |
                       (                                               devaff0_rd_data           )   |
                       (                                               devaff1_rd_data           )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , auth_status_rd_data     } )   |
                       (                                               devarch_rd_data           )   |
                       ( { {(APB_DATA_WIDTH-26){1'b0}}               , devid_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , devtype_rd_data         } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , pidr4_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , pidr0_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , pidr1_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , pidr2_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , pidr3_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , cidr0_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , cidr1_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , cidr2_rd_data           } )   |
                       ( { {(APB_DATA_WIDTH-8){1'b0}}                , cidr3_rd_data           } )
                     );


endmodule

