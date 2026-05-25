//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2010-2014, 2016-2017, 2019-2020 Arm Limited or its affiliates.
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
//   Sub-module of css600_atbfunnel
//
//----------------------------------------------------------------------------


module css600_atbfunnel_reg_blk
 #(parameter CSS600_FIXED_CONFIG_HOLD_TIME = 4'b0011,
   parameter WRITE_REG_WIDTH = 23,
   parameter ATB_DATA_WIDTH = 32,
   parameter ATBYTES_WIDTH= 2,
   parameter NUM_ATB_SLAVES = 8)
  (
 input   wire                                   clk,
 input   wire                                   reset_n,

 input   wire                                   reg_write,
 input   wire                                   reg_read,
 input   wire                           [9:0]   reg_addr,
 input   wire [(ATB_DATA_WIDTH/8):0]   it_atb_data_0_rd_reg,
 input   wire [3:0]                    it_atb_ctr_0_rd_reg,
 input   wire [6:0]                    it_atb_ctr_1_rd_reg,
 input   wire [1:0]                    it_atb_ctr_2_rd_reg,
 input   wire                          syncreq_reg,
 input   wire [WRITE_REG_WIDTH:0]      write_data,

 input   wire [NUM_ATB_SLAVES-1:0]    atready_s,
 input   wire [NUM_ATB_SLAVES-1:0]    atvalid_s,
 input   wire [NUM_ATB_SLAVES-1:0]    afvalid_s,

 output  wire [31:0]                  read_data,
  output  wire [NUM_ATB_SLAVES-1:0]     en_port,
  output  wire [3*NUM_ATB_SLAVES-1:0]   pri_port,

  output  wire                          itc_reg,
  output  reg  [(ATB_DATA_WIDTH/8):0]   it_atb_data_0_wr_reg,
  output  reg  [3:0]                    it_atb_ctr_0_wr_reg,
  output  reg  [6:0]                    it_atb_ctr_1_wr_reg,
  output  reg  [1:0]                    it_atb_ctr_2_wr_reg,
  output  wire                          syncreq_apb,
  output  wire [3:0]  min_hold_time,
  output  wire        fl_normal,
  input   wire [3:0]  revand

  );


  localparam FUNNEL_IT_DATA0_WIDTH = (ATB_DATA_WIDTH == 128)? 17 :
                                       (ATB_DATA_WIDTH == 64)? 9 :
                                       (ATB_DATA_WIDTH == 32)? 5 :
                                       (ATB_DATA_WIDTH == 16)? 3 :
                                        2 ;

  localparam FUNNEL_FUNCTL = 12'h000;
  localparam FUNNEL_PRICTL = 12'h004;

  localparam  FUNNEL_ITCTL      = 12'hF00;
  localparam  FUNNEL_CLAIMSET   = 12'hFA0;
  localparam  FUNNEL_CLAIMCLR   = 12'hFA4;
  localparam  FUNNEL_DEVAFF0    = 12'hFA8;
  localparam  FUNNEL_DEVAFF1    = 12'hFAC;
  localparam  FUNNEL_LAR        = 12'hFB0;
  localparam  FUNNEL_LSR        = 12'hFB4;
  localparam  FUNNEL_DEVICEID1  = 12'hFC4;
  localparam  FUNNEL_DEVICEID2  = 12'hFC0;
  localparam  FUNNEL_DEVARCH    = 12'hFBC;
  localparam  FUNNEL_AUTHSTATUS = 12'hFB8;
  localparam  FUNNEL_DEVICEID   = 12'hFC8;
  localparam  FUNNEL_DEVICETYPE = 12'hFCC;

  localparam FUNNEL_IT_ATB_DATA_0 = 12'hEEC;
  localparam FUNNEL_IT_ATB_CTR_3 = 12'hEF0;
  localparam FUNNEL_IT_ATB_CTR_2 = 12'hEF4;
  localparam FUNNEL_IT_ATB_CTR_1 = 12'hEF8;
  localparam FUNNEL_IT_ATB_CTR_0 = 12'hEFC;

  localparam FUNNEL_PERIPH_ID_4 = 12'hFD0;
  localparam FUNNEL_PERIPH_ID_5 = 12'hFD4;
  localparam FUNNEL_PERIPH_ID_6 = 12'hFD8;
  localparam FUNNEL_PERIPH_ID_7 = 12'hFDC;
  localparam FUNNEL_PERIPH_ID_0 = 12'hFE0;
  localparam FUNNEL_PERIPH_ID_1 = 12'hFE4;
  localparam FUNNEL_PERIPH_ID_2 = 12'hFE8;
  localparam FUNNEL_PERIPH_ID_3 = 12'hFEC;
  localparam FUNNEL_COMP_ID_0   = 12'hFF0;
  localparam FUNNEL_COMP_ID_1   = 12'hFF4;
  localparam FUNNEL_COMP_ID_2   = 12'hFF8;
  localparam FUNNEL_COMP_ID_3   = 12'hFFC;

  localparam FUNNEL_PERIPH_ID_4_VAL = 8'h04;
  localparam FUNNEL_PERIPH_ID_5_VAL = 8'h00;
  localparam FUNNEL_PERIPH_ID_6_VAL = 8'h00;
  localparam FUNNEL_PERIPH_ID_7_VAL = 8'h00;
  localparam FUNNEL_PERIPH_ID_0_VAL = 8'hEB;
  localparam FUNNEL_PERIPH_ID_1_VAL = 8'hB9;
  localparam FUNNEL_PERIPH_ID_2_VAL = 8'h2B;
  localparam FUNNEL_PERIPH_ID_3_CUSTOM_VAL = 4'h0;

  localparam FUNNEL_COMP_ID_0_VAL = 8'h0D;
  localparam FUNNEL_COMP_ID_1_VAL = 8'h90;
  localparam FUNNEL_COMP_ID_2_VAL = 8'h05;
  localparam FUNNEL_COMP_ID_3_VAL = 8'hB1;
  localparam FUNNEL_DEVICEID_VAL_2PORTS   = 8'h32;
  localparam FUNNEL_DEVICEID_VAL_3PORTS   = 8'h33;
  localparam FUNNEL_DEVICEID_VAL_4PORTS   = 8'h34;
  localparam FUNNEL_DEVICEID_VAL_5PORTS   = 8'h35;
  localparam FUNNEL_DEVICEID_VAL_6PORTS   = 8'h36;
  localparam FUNNEL_DEVICEID_VAL_7PORTS   = 8'h37;
  localparam FUNNEL_DEVICEID_VAL_8PORTS   = 8'h38;
  localparam FUNNEL_DEVICETYPE_VAL = 8'h12;
  localparam FUNNEL_CLAIM_TAG_VAL  = 4'hF;

  localparam FUNNEL_AUTHSTATUS_HNID_VAL    = 1'b0;
  localparam FUNNEL_AUTHSTATUS_HID_VAL    = 1'b0;
  localparam FUNNEL_AUTHSTATUS_SNID_VAL    = 1'b0;
  localparam FUNNEL_AUTHSTATUS_SID_VAL     = 1'b0;
  localparam FUNNEL_AUTHSTATUS_NSNID_VAL   = 1'b0;
  localparam FUNNEL_AUTHSTATUS_NSID_VAL    = 1'b0;

  localparam  FUNNEL_DEVAFF0_VAL    = 8'h00;
  localparam  FUNNEL_DEVAFF1_VAL    = 8'h00;
  localparam  FUNNEL_LAR_VAL        = 8'h00;
  localparam  FUNNEL_LSR_VAL        = 8'h00;
  localparam  FUNNEL_DEVICEID1_VAL  = 8'h00;
  localparam  FUNNEL_DEVICEID2_VAL  = 8'h00;
  localparam  FUNNEL_DEVARCH_VAL    = 8'h00;


  wire [3*NUM_ATB_SLAVES-1:0]     pri_ctl_write_data;
  reg [NUM_ATB_SLAVES-1:0]      en_port_int;
  wire          fun_ctl_sel;
  wire          pri_ctl_sel;
  wire          itc_sel;
  wire          claim_set_sel;
  wire          claim_clr_sel;
  wire          it_atb_data_0_sel;
  wire          it_atb_ctr_0_sel;
  wire          it_atb_ctr_1_sel;
  wire          it_atb_ctr_2_sel;
  wire          it_atb_ctr_3_sel;
  wire          fun_ctl_wr_en;
  wire          pri_ctl_wr_en;
  wire          itc_wr_en;
  wire          claim_tag_wr_en;
  wire          it_atb_data_0_wr_en;
  wire          it_atb_ctr_3_wr_en;
  wire          it_atb_ctr_2_wr_en;
  wire          it_atb_ctr_1_wr_en;
  wire          it_atb_ctr_0_wr_en;
  wire          itc_rd_en;
  wire          it_atb_data_0_rd_en;
  wire          it_atb_ctr_0_rd_en;
  wire          it_atb_ctr_1_rd_en;
  wire          it_atb_ctr_2_rd_en;
  wire          it_atb_ctr_3_rd_en;

  wire          fun_ctl_rd_en;
  wire          pri_ctl_rd_en;
  wire          periph_id_0_rd_en;
  wire          periph_id_1_rd_en;
  wire          periph_id_2_rd_en;
  wire          periph_id_3_rd_en;
  wire          periph_id_4_rd_en;
  wire          periph_id_5_rd_en;
  wire          periph_id_6_rd_en;
  wire          periph_id_7_rd_en;
  wire          comp_id_0_rd_en;
  wire          comp_id_1_rd_en;
  wire          comp_id_2_rd_en;
  wire          comp_id_3_rd_en;
  wire          claim_tag_set_rd_en;
  wire          claim_tag_clr_rd_en;
  wire          auth_status_rd_en;
  wire          device_id_rd_en;
  wire          device_type_rd_en;
  wire          devaff0_rd_en;
  wire          devaff1_rd_en;
  wire          lar_rd_en;
  wire          lsr_rd_en;
  wire          devarch_rd_en;
  wire          devid1_rd_en;
  wire          devid2_rd_en;

  wire          it_rd;
  wire          it_wr;
  wire [3:0]    next_claim_tag_reg;
  wire [31:0]   fun_ctl_rd_data;
  wire [31:0]   pri_ctl_rd_data;
  wire [31:0]   itc_rd_data;
  wire [31:0]   it_atb_data_0_rd_data;
  wire [31:0]   it_atb_ctr_0_rd_data;
  wire [31:0]   it_atb_ctr_1_rd_data;
  wire [31:0]   it_atb_ctr_2_rd_data;
  wire [31:0]   it_atb_ctr_3_rd_data;
  wire [31:0]   claim_tag_set_rd_data;
  wire [31:0]   claim_tag_clr_rd_data;
  wire [31:0]   auth_status_rd_data;
  wire [31:0]   device_id_rd_data;
  wire [31:0]   device_type_rd_data;
  wire [31:0]   periph_id_0_rd_data;
  wire [31:0]   periph_id_1_rd_data;
  wire [31:0]   periph_id_2_rd_data;
  wire [31:0]   periph_id_3_rd_data;
  wire [31:0]   periph_id_4_rd_data;
  wire [31:0]   periph_id_5_rd_data;
  wire [31:0]   periph_id_6_rd_data;
  wire [31:0]   periph_id_7_rd_data;
  wire [31:0]   comp_id_0_rd_data;
  wire [31:0]   comp_id_1_rd_data;
  wire [31:0]   comp_id_2_rd_data;
  wire [31:0]   comp_id_3_rd_data;
  wire [31:0]   devaff0_rd_data;
  wire [31:0]   devaff1_rd_data;
  wire [31:0]   lsr_rd_data;
  wire [31:0]   lar_rd_data;
  wire [31:0]   devid1_rd_data;
  wire [31:0]   devid2_rd_data;
  wire [31:0]   devarch_rd_data;


  wire ports_disabled;
  wire [NUM_ATB_SLAVES-1:0]    pending_transfer;
  reg [3:0]     claim_tag_reg;
  reg [12:0]    fun_ctl_reg;
  reg [3:0]     ht_reg;
  reg           itc_reg_int;
  reg [NUM_ATB_SLAVES-1:0]      slv_port_en_reg;
  reg [3*NUM_ATB_SLAVES-1:0]    pri_ctl_reg;

  reg           syncreq_apb_int;
  reg           syncreq_reg_q;

  reg           fl_normal_reg;


  assign fun_ctl_sel       = (reg_addr == FUNNEL_FUNCTL[11:2]);
  assign pri_ctl_sel       = (reg_addr == FUNNEL_PRICTL[11:2]);
  assign itc_sel           = (reg_addr == FUNNEL_ITCTL[11:2]);
  assign claim_set_sel     = (reg_addr == FUNNEL_CLAIMSET[11:2]);
  assign claim_clr_sel     = (reg_addr == FUNNEL_CLAIMCLR[11:2]);
  assign it_atb_data_0_sel = (reg_addr == FUNNEL_IT_ATB_DATA_0[11:2]);
  assign it_atb_ctr_0_sel  = (reg_addr == FUNNEL_IT_ATB_CTR_0[11:2]);
  assign it_atb_ctr_1_sel  = (reg_addr == FUNNEL_IT_ATB_CTR_1[11:2]);
  assign it_atb_ctr_2_sel  = (reg_addr == FUNNEL_IT_ATB_CTR_2[11:2]);
  assign it_atb_ctr_3_sel  = (reg_addr == FUNNEL_IT_ATB_CTR_3[11:2]);


  always @(posedge clk or negedge reset_n)
    begin : p_fun_ctl_wr
      if (!reset_n)
        begin
          ht_reg[3:0] <= CSS600_FIXED_CONFIG_HOLD_TIME;
          slv_port_en_reg[NUM_ATB_SLAVES-1:0] <= {NUM_ATB_SLAVES{1'b0}};
          fl_normal_reg <= 1'b0;
        end
      else if(fun_ctl_wr_en)
          begin
            fl_normal_reg <= write_data[12];
            ht_reg[3:0] <= write_data[11:8];
            slv_port_en_reg[NUM_ATB_SLAVES-1:0] <= write_data[NUM_ATB_SLAVES-1:0];
          end
    end


  always @*
    begin
      fun_ctl_reg[12]   = fl_normal_reg;
      fun_ctl_reg[11:8] = ht_reg;
      fun_ctl_reg[7:0] = {8{1'b0}};
      fun_ctl_reg[NUM_ATB_SLAVES-1:0] = slv_port_en_reg;
    end

  assign fun_ctl_wr_en   = reg_write & fun_ctl_sel;
  assign fun_ctl_rd_en   = reg_read  & fun_ctl_sel;
  assign fun_ctl_rd_data = {{19{1'b0}},fun_ctl_reg};


  genvar a;
  generate
  for (a=0; a< NUM_ATB_SLAVES; a=a+1) begin: pending_transfer_assign
    assign pending_transfer[a] = (~itc_reg_int & ((atvalid_s[a] & ~atready_s[a]) | afvalid_s[a]) & en_port_int[a]);
  end
  endgenerate

  genvar b;
  generate

  for (b=0; b< NUM_ATB_SLAVES; b=b+1) begin: en_port_assign

    always @(posedge clk or negedge reset_n)
    begin : p_en_port
      if (!reset_n)
        en_port_int[b] <= 1'b0;
      else
        if (!pending_transfer[b])
          en_port_int[b] <= fun_ctl_reg[b];
      end

    assign en_port[b] = en_port_int[b];
  end
  endgenerate

  assign min_hold_time  = fun_ctl_reg[11:8];
  assign fl_normal      = fun_ctl_reg[12];

  always @(posedge clk or negedge reset_n)
  begin : p_pri_ctl_wr
    if (!reset_n)
      pri_ctl_reg <= {3*NUM_ATB_SLAVES{1'b0}};
    else
      if(pri_ctl_wr_en)
        pri_ctl_reg <= pri_ctl_write_data[3*NUM_ATB_SLAVES-1:0];
   end

  assign pri_ctl_wr_en   = reg_write & pri_ctl_sel;
  assign pri_ctl_rd_en   = reg_read  & pri_ctl_sel;
  assign pri_ctl_rd_data = {{(32-3*NUM_ATB_SLAVES){1'b0}}, pri_ctl_reg};


  assign ports_disabled = |en_port_int;

  assign pri_ctl_write_data[0 +: 3] = ports_disabled ? pri_ctl_reg[2:0] : write_data[2:0];
  assign pri_ctl_write_data[3 +: 3] = ports_disabled ? pri_ctl_reg[5:3] : write_data[5:3];

  generate

  if (NUM_ATB_SLAVES>2) begin: pri_ctl_wr_data_slv2
    assign pri_ctl_write_data[6 +: 3] = ports_disabled ? pri_ctl_reg[8:6] : write_data[8:6];
  end

  if (NUM_ATB_SLAVES>3) begin: pri_ctl_wr_data_slv3
    assign pri_ctl_write_data[9 +: 3] = ports_disabled ? pri_ctl_reg[11:9] : write_data[11:9];
  end

  if (NUM_ATB_SLAVES>4) begin: pri_ctl_wr_data_slv4
    assign pri_ctl_write_data[12 +: 3] = ports_disabled ? pri_ctl_reg[14:12] : write_data[14:12];
  end

  if (NUM_ATB_SLAVES>5) begin: pri_ctl_wr_data_slv5
    assign pri_ctl_write_data[15 +: 3] = ports_disabled ? pri_ctl_reg[17:15] : write_data[17:15];
  end

  if (NUM_ATB_SLAVES>6) begin: pri_ctl_wr_data_slv6
    assign pri_ctl_write_data[18 +: 3] = ports_disabled ? pri_ctl_reg[20:18] : write_data[20:18];
  end

  if (NUM_ATB_SLAVES>7) begin: pri_ctl_wr_data_slv7
    assign pri_ctl_write_data[21 +: 3] = ports_disabled ? pri_ctl_reg[23:21] : write_data[23:21];
  end

  endgenerate


  assign pri_port[0   +:3] = pri_ctl_reg[2:0];
  assign pri_port[1*3 +:3] = pri_ctl_reg[5:3];

  generate

  if (NUM_ATB_SLAVES>2) begin: pri_port_slv2
    assign pri_port[2*3 +:3] = pri_ctl_reg[8:6];
  end

  if (NUM_ATB_SLAVES>3) begin: pri_port_slv3
    assign pri_port[3*3 +:3] = pri_ctl_reg[11:9];
  end

  if (NUM_ATB_SLAVES>4) begin: pri_port_slv4
    assign pri_port[4*3 +:3] = pri_ctl_reg[14:12];
  end

  if (NUM_ATB_SLAVES>5) begin: pri_port_slv5
    assign pri_port[5*3 +:3] = pri_ctl_reg[17:15];
  end

  if (NUM_ATB_SLAVES>6) begin: pri_port_slv6
    assign pri_port[6*3 +:3] = pri_ctl_reg[20:18];
  end

  if (NUM_ATB_SLAVES>7) begin: pri_port_slv7
    assign pri_port[7*3 +:3] = pri_ctl_reg[23:21];
  end

  endgenerate

  always @(posedge clk or negedge reset_n)
  begin : p_itc_wr
    if (!reset_n)
      itc_reg_int <= 1'b0;
    else
      if(itc_wr_en)
        itc_reg_int <= write_data[0];
   end

   assign itc_reg = itc_reg_int;

  assign itc_wr_en   = reg_write & itc_sel;
  assign itc_rd_en   = reg_read  & itc_sel;
  assign itc_rd_data = {{31{1'b0}},itc_reg_int};

  always @(posedge clk or negedge reset_n)
  begin : p_claim_tag_wr
    if (!reset_n)
      claim_tag_reg <= {4{1'b0}};
    else
      if(claim_tag_wr_en)
        claim_tag_reg <= next_claim_tag_reg;
   end

  assign claim_tag_wr_en = reg_write & (claim_set_sel | claim_clr_sel);

  assign next_claim_tag_reg = claim_set_sel ?
                              (claim_tag_reg | write_data[3:0]):
                              (claim_tag_reg & ~write_data[3:0]);

  assign claim_tag_set_rd_en   = reg_read & claim_set_sel;
  assign claim_tag_clr_rd_en   = reg_read & claim_clr_sel;
  assign claim_tag_set_rd_data = {{28{1'b0}},FUNNEL_CLAIM_TAG_VAL};
  assign claim_tag_clr_rd_data = {{28{1'b0}},claim_tag_reg};

  assign auth_status_rd_en   = reg_read & (reg_addr == FUNNEL_AUTHSTATUS[11:2]);
  assign auth_status_rd_data = {{20{1'b0}},
                                 1'b0,FUNNEL_AUTHSTATUS_HNID_VAL,
                                 1'b0,FUNNEL_AUTHSTATUS_HID_VAL,
                                 1'b0,FUNNEL_AUTHSTATUS_SNID_VAL,
                                 1'b0,FUNNEL_AUTHSTATUS_SID_VAL,
                                 1'b0,FUNNEL_AUTHSTATUS_NSNID_VAL,
                                 1'b0,FUNNEL_AUTHSTATUS_NSID_VAL};


  assign device_id_rd_en   = reg_read & (reg_addr == FUNNEL_DEVICEID[11:2]);

  generate

  if (NUM_ATB_SLAVES==2) begin: devid_slv2
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_2PORTS};
  end
  else if (NUM_ATB_SLAVES==3) begin: devid_slv3
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_3PORTS};
  end
  else if (NUM_ATB_SLAVES==4) begin: devid_slv4
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_4PORTS};
  end
  else if (NUM_ATB_SLAVES==5) begin: devid_slv5
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_5PORTS};
  end
  else if (NUM_ATB_SLAVES==6) begin: devid_slv6
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_6PORTS};
  end
  else if (NUM_ATB_SLAVES==7) begin: devid_slv7
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_7PORTS};
  end
  else if (NUM_ATB_SLAVES==8) begin: devid_slv8
    assign device_id_rd_data = {{24{1'b0}}, FUNNEL_DEVICEID_VAL_8PORTS};
  end

  endgenerate


  assign devaff0_rd_en   = reg_read & (reg_addr == FUNNEL_DEVAFF0[11:2]);
  assign devaff0_rd_data = {{24{1'b0}},FUNNEL_DEVAFF0_VAL};

  assign devaff1_rd_en   = reg_read & (reg_addr == FUNNEL_DEVAFF1[11:2]);
  assign devaff1_rd_data = {{24{1'b0}},FUNNEL_DEVAFF1_VAL};

  assign lar_rd_en   = reg_read & (reg_addr == FUNNEL_LAR[11:2]);
  assign lar_rd_data = {{24{1'b0}},FUNNEL_LAR_VAL};

  assign lsr_rd_en   = reg_read & (reg_addr == FUNNEL_LSR[11:2]);
  assign lsr_rd_data = {{24{1'b0}},FUNNEL_LSR_VAL};

  assign devarch_rd_en   = reg_read & (reg_addr == FUNNEL_DEVARCH[11:2]);
  assign devarch_rd_data = {{24{1'b0}},FUNNEL_DEVARCH_VAL};

  assign devid1_rd_en   = reg_read & (reg_addr == FUNNEL_DEVICEID1[11:2]);
  assign devid1_rd_data = {{24{1'b0}},FUNNEL_DEVICEID1_VAL};

  assign devid2_rd_en   = reg_read & (reg_addr == FUNNEL_DEVICEID2[11:2]);
  assign devid2_rd_data = {{24{1'b0}},FUNNEL_DEVICEID2_VAL};

  assign device_type_rd_en   = reg_read & (reg_addr == FUNNEL_DEVICETYPE[11:2]);
  assign device_type_rd_data = {{24{1'b0}},FUNNEL_DEVICETYPE_VAL};

  assign periph_id_4_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_4[11:2]);
  assign periph_id_4_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_4_VAL};

  assign periph_id_5_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_5[11:2]);
  assign periph_id_5_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_5_VAL};

  assign periph_id_6_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_6[11:2]);
  assign periph_id_6_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_6_VAL};

  assign periph_id_7_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_7[11:2]);
  assign periph_id_7_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_7_VAL};

  assign periph_id_0_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_0[11:2]);
  assign periph_id_0_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_0_VAL};

  assign periph_id_1_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_1[11:2]);
  assign periph_id_1_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_1_VAL};

  assign periph_id_2_rd_en   = reg_read & (reg_addr == FUNNEL_PERIPH_ID_2[11:2]);
  assign periph_id_2_rd_data = {{24{1'b0}},FUNNEL_PERIPH_ID_2_VAL};

  assign periph_id_3_rd_en    = reg_read & (reg_addr == FUNNEL_PERIPH_ID_3[11:2]);
  assign periph_id_3_rd_data  = {{24{1'b0}}, revand,
                            FUNNEL_PERIPH_ID_3_CUSTOM_VAL };

  assign comp_id_0_rd_en   = reg_read & (reg_addr == FUNNEL_COMP_ID_0[11:2]);
  assign comp_id_0_rd_data = {{24{1'b0}},FUNNEL_COMP_ID_0_VAL};

  assign comp_id_1_rd_en   = reg_read & (reg_addr == FUNNEL_COMP_ID_1[11:2]);
  assign comp_id_1_rd_data = {{24{1'b0}},FUNNEL_COMP_ID_1_VAL};

  assign comp_id_2_rd_en   = reg_read & (reg_addr == FUNNEL_COMP_ID_2[11:2]);
  assign comp_id_2_rd_data = {{24{1'b0}},FUNNEL_COMP_ID_2_VAL};

  assign comp_id_3_rd_en   = reg_read & (reg_addr == FUNNEL_COMP_ID_3[11:2]);
  assign comp_id_3_rd_data = {{24{1'b0}},FUNNEL_COMP_ID_3_VAL};

  assign it_wr = reg_write & itc_reg_int;
  assign it_rd = reg_read  & itc_reg_int;

  assign it_atb_data_0_wr_en   = it_atb_data_0_sel & it_wr;
  assign it_atb_data_0_rd_en   = it_atb_data_0_sel & it_rd;
  assign it_atb_data_0_rd_data = {{31-(ATB_DATA_WIDTH/8){1'b0}},it_atb_data_0_rd_reg};

  always @(posedge clk or negedge reset_n)
  begin : p_it_atb_data_0_wr_reg
    if (!reset_n)
      it_atb_data_0_wr_reg <= {(ATB_DATA_WIDTH/8)+1{1'b0}};
    else
      if(it_atb_data_0_wr_en)
        it_atb_data_0_wr_reg <= write_data[(ATB_DATA_WIDTH/8):0];
   end

  always @(posedge clk or negedge reset_n)
  begin : p_it_atb_ctr_0_wr_reg
    if (!reset_n)
      begin
      it_atb_ctr_0_wr_reg[3:0] <= {4{1'b0}};
      end
    else
      if(it_atb_ctr_0_wr_en)
        begin
        it_atb_ctr_0_wr_reg[3:2]<= write_data[9:8];
        it_atb_ctr_0_wr_reg[1:0]<= write_data[1:0];
        end
   end


  always @(posedge clk or negedge reset_n)
  begin : p_it_atb_ctr_1_wr_reg
    if (!reset_n)
      it_atb_ctr_1_wr_reg <= {7{1'b0}};
    else
      if(it_atb_ctr_1_wr_en)
        it_atb_ctr_1_wr_reg <= write_data[6:0];
   end

  always @(posedge clk or negedge reset_n)
  begin : p_it_atb_ctr_2_wr_reg
    if (!reset_n)
      it_atb_ctr_2_wr_reg <= {2{1'b0}};
    else
      if(it_atb_ctr_2_wr_en)
        it_atb_ctr_2_wr_reg <= write_data[1:0];
   end

  always @(posedge clk or negedge reset_n)
  begin : syncreq_apb_reg
    if (!reset_n)
      syncreq_apb_int <= 1'b0;
    else
      if(it_atb_ctr_3_wr_en)
        syncreq_apb_int <= write_data[0];
      else if (syncreq_apb_int)
        syncreq_apb_int <= 1'b0;
   end

   assign syncreq_apb = syncreq_apb_int;

  always @(posedge clk or negedge reset_n)
  begin : p_it_atb_ctr_3_rd_reg
    if (!reset_n)
      syncreq_reg_q <= 1'b0;
    else
      if (it_atb_ctr_3_rd_en)
        syncreq_reg_q <= 1'b0;
      else if(syncreq_reg)
        syncreq_reg_q <= syncreq_reg;
   end


  assign it_atb_ctr_3_wr_en   = it_atb_ctr_3_sel & it_wr;
  assign it_atb_ctr_3_rd_en   = it_atb_ctr_3_sel & it_rd;
  assign it_atb_ctr_3_rd_data = {{31{1'b0}},syncreq_reg_q};


  assign it_atb_ctr_2_wr_en   = it_atb_ctr_2_sel & it_wr;
  assign it_atb_ctr_2_rd_en   = it_atb_ctr_2_sel & it_rd;
  assign it_atb_ctr_2_rd_data = {{30{1'b0}},it_atb_ctr_2_rd_reg};

  assign it_atb_ctr_1_wr_en   = it_atb_ctr_1_sel & it_wr;
  assign it_atb_ctr_1_rd_en   = it_atb_ctr_1_sel & it_rd;
  assign it_atb_ctr_1_rd_data = {{25{1'b0}},it_atb_ctr_1_rd_reg};

  assign it_atb_ctr_0_wr_en   = it_atb_ctr_0_sel & it_wr;
  assign it_atb_ctr_0_rd_en   = it_atb_ctr_0_sel & it_rd;
  assign it_atb_ctr_0_rd_data = {{22{1'b0}},it_atb_ctr_0_rd_reg[3:2],{6{1'b0}},it_atb_ctr_0_rd_reg[1:0]};

  assign read_data   = (
                      ({32{fun_ctl_rd_en}}       & fun_ctl_rd_data)       |
                      ({32{pri_ctl_rd_en}}       & pri_ctl_rd_data)       |
                      ({32{itc_rd_en}}           & itc_rd_data)           |
                      ({32{it_atb_data_0_rd_en}} & it_atb_data_0_rd_data) |
                      ({32{it_atb_ctr_0_rd_en}}  & it_atb_ctr_0_rd_data)  |
                      ({32{it_atb_ctr_1_rd_en}}  & it_atb_ctr_1_rd_data)  |
                      ({32{it_atb_ctr_2_rd_en}}  & it_atb_ctr_2_rd_data)  |
                      ({32{it_atb_ctr_3_rd_en}}  & it_atb_ctr_3_rd_data)  |
                      ({32{claim_tag_set_rd_en}} & claim_tag_set_rd_data) |
                      ({32{claim_tag_clr_rd_en}} & claim_tag_clr_rd_data) |
                      ({32{devaff0_rd_en}}       & devaff0_rd_data)       |
                      ({32{devaff1_rd_en}}       & devaff1_rd_data)       |
                      ({32{lar_rd_en}}           & lar_rd_data)           |
                      ({32{lsr_rd_en}}           & lsr_rd_data)           |
                      ({32{devarch_rd_en}}       & devarch_rd_data)       |
                      ({32{devid1_rd_en}}        & devid1_rd_data)           |
                      ({32{devid2_rd_en}}        & devid2_rd_data)        |
                      ({32{auth_status_rd_en}}   & auth_status_rd_data)   |
                      ({32{device_id_rd_en}}     & device_id_rd_data)     |
                      ({32{device_type_rd_en}}   & device_type_rd_data)   |
                      ({32{periph_id_0_rd_en}}   & periph_id_0_rd_data)   |
                      ({32{periph_id_1_rd_en}}   & periph_id_1_rd_data)   |
                      ({32{periph_id_2_rd_en}}   & periph_id_2_rd_data)   |
                      ({32{periph_id_3_rd_en}}   & periph_id_3_rd_data)   |
                      ({32{periph_id_4_rd_en}}   & periph_id_4_rd_data)   |
                      ({32{periph_id_5_rd_en}}   & periph_id_5_rd_data)   |
                      ({32{periph_id_6_rd_en}}   & periph_id_6_rd_data)   |
                      ({32{periph_id_7_rd_en}}   & periph_id_7_rd_data)   |
                      ({32{comp_id_0_rd_en}}     & comp_id_0_rd_data)     |
                      ({32{comp_id_1_rd_en}}     & comp_id_1_rd_data)     |
                      ({32{comp_id_2_rd_en}}     & comp_id_2_rd_data)     |
                      ({32{comp_id_3_rd_en}}     & comp_id_3_rd_data)
                     );


endmodule
