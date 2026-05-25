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
//   Sub-module of css600_apv1adapter
//
//----------------------------------------------------------------------------


module css600_apv1adapter_reg_block
#( parameter
APB_ADDR_WIDTH = 12
)
(
  pclk,
  preset_n,

  ime,
  itdpabort_rd,
  itdpabort_rd_data,
  claim_set_wr,
  claim_set_wr_data,
  claim_set_rd,
  claim_set_rd_data,
  claim_clr_wr,
  claim_clr_wr_data,
  claim_clr_rd,
  claim_clr_rd_data,

  psel,
  penable,
  paddr,
  pwrite,
  pwdata,
  prdata,
  pready,
  revand
);


`include  "css600_apv1adapter_reg_block_params.v"

localparam NUM_REGS           = 18;

localparam APB_FSM_SETUP      = 1'b0;
localparam APB_FSM_ACCESS     = 1'b1;


  input  wire                          pclk;
  input  wire                          preset_n;

  output reg  [REG_IME_MSB:0]       ime;
  output                            itdpabort_rd;
  input  wire [REG_ITDPABORT_MSB:0] itdpabort_rd_data;
  output                            claim_set_wr;
  output                            claim_set_rd;
  output wire [REG_CLAIM_SET_MSB:0] claim_set_wr_data;
  input  wire [REG_CLAIM_SET_MSB:0] claim_set_rd_data;
  output                            claim_clr_wr;
  output                            claim_clr_rd;
  output wire [REG_CLAIM_CLR_MSB:0] claim_clr_wr_data;
  input  wire [REG_CLAIM_CLR_MSB:0] claim_clr_rd_data;

  input  wire                          psel;
  input  wire                          penable;
  input  wire     [APB_ADDR_WIDTH-1:0] paddr;
  input  wire                          pwrite;
  input  wire                   [31:0] pwdata;
  output wire                   [31:0] prdata;
  output wire                          pready;
  input  wire                    [3:0] revand;


reg         next_state;
reg         state;

wire        first_enable;

wire        apb_wr;
wire        apb_rd;


assign first_enable = (psel & ~penable) | (psel & penable & (state == APB_FSM_SETUP));


always @*
begin : p_state_machine_comb

  next_state     = state;

  case (state)
    APB_FSM_SETUP:
    begin
      next_state = (first_enable) ? APB_FSM_ACCESS : APB_FSM_SETUP;
    end
    APB_FSM_ACCESS:
    begin
      next_state = APB_FSM_SETUP;
    end
    default:
    begin
      next_state = 1'bx;
    end
  endcase
end

always @(posedge pclk or negedge preset_n)
begin : p_state_machine_seq
  if (!preset_n)
  begin
    state <= APB_FSM_SETUP;
  end
  else
  begin
    state <= next_state;
  end
end

assign apb_wr       = (state == APB_FSM_ACCESS) & ( pwrite);
assign apb_rd       = (state == APB_FSM_ACCESS) & (~pwrite);

assign pready  = (state == APB_FSM_ACCESS);


wire sel_itstatus = (paddr == REGA_ITSTATUS);

reg  [31:0] reg_itstatus;
wire rd_itstatus = (sel_itstatus);
wire [REG_ITDPABORT_MSB:0] itdpabort = itdpabort_rd_data;


  always @*
  begin : p_itstatus_comb
    reg_itstatus = 32'd0;
    reg_itstatus[REG_ITDPABORT_SLICE_MSB:REG_ITDPABORT_SLICE_LSB] = itdpabort;
  end


  assign itdpabort_rd      = rd_itstatus & (apb_rd);


wire sel_itcontrol = (paddr == REGA_ITCONTROL);

reg  [31:0] reg_itcontrol;
wire wr_itcontrol = (sel_itcontrol) & (apb_wr);
wire rd_itcontrol = (sel_itcontrol);


wire [REG_IME_MSB:0] ime_nxt = (wr_itcontrol) ? pwdata[REG_IME_SLICE_MSB:REG_IME_SLICE_LSB] : ime;

  always @(posedge pclk or negedge preset_n)
  begin : p_itcontrol_seq
    if (!preset_n) begin
      ime <= REG_IME_INIT;
    end else if (wr_itcontrol) begin
      ime <= ime_nxt;
    end
  end

  always @*
  begin : p_itcontrol_comb
    reg_itcontrol = 32'd0;
    reg_itcontrol[REG_IME_SLICE_MSB:REG_IME_SLICE_LSB] = ime;
  end


wire sel_claimset = (paddr == REGA_CLAIMSET);

reg  [31:0] reg_claimset;
wire wr_claimset = (sel_claimset) & (apb_wr);
wire rd_claimset = (sel_claimset);
wire [REG_CLAIM_SET_MSB:0] claim_set = claim_set_rd_data;


  always @*
  begin : p_claimset_comb
    reg_claimset = 32'd0;
    reg_claimset[REG_CLAIM_SET_SLICE_MSB:REG_CLAIM_SET_SLICE_LSB] = claim_set;
  end


  assign claim_set_rd      = rd_claimset & (apb_rd);
  assign claim_set_wr      = wr_claimset;
  assign claim_set_wr_data = pwdata[REG_CLAIM_SET_SLICE_MSB:REG_CLAIM_SET_SLICE_LSB];


wire sel_claimclr = (paddr == REGA_CLAIMCLR);

reg  [31:0] reg_claimclr;
wire wr_claimclr = (sel_claimclr) & (apb_wr);
wire rd_claimclr = (sel_claimclr);
wire [REG_CLAIM_CLR_MSB:0] claim_clr = claim_clr_rd_data;


  always @*
  begin : p_claimclr_comb
    reg_claimclr = 32'd0;
    reg_claimclr[REG_CLAIM_CLR_SLICE_MSB:REG_CLAIM_CLR_SLICE_LSB] = claim_clr;
  end


  assign claim_clr_rd      = rd_claimclr & (apb_rd);
  assign claim_clr_wr      = wr_claimclr;
  assign claim_clr_wr_data = pwdata[REG_CLAIM_CLR_SLICE_MSB:REG_CLAIM_CLR_SLICE_LSB];


wire sel_devarch = (paddr == REGA_DEVARCH);

reg  [31:0] reg_devarch;
wire rd_devarch = (sel_devarch);

wire [REG_ARCHID_MSB:0] archid = REG_ARCHID_INIT;
wire [REG_ARCH_REVISION_MSB:0] arch_revision = REG_ARCH_REVISION_INIT;
wire [REG_PRESENT_MSB:0] present = REG_PRESENT_INIT;
wire [REG_ARCHITECT_MSB:0] architect = REG_ARCHITECT_INIT;


  always @*
  begin : p_devarch_comb
    reg_devarch = 32'd0;
    reg_devarch[REG_ARCHID_SLICE_MSB:REG_ARCHID_SLICE_LSB] = archid;
    reg_devarch[REG_ARCH_REVISION_SLICE_MSB:REG_ARCH_REVISION_SLICE_LSB] = arch_revision;
    reg_devarch[REG_PRESENT_SLICE_MSB:REG_PRESENT_SLICE_LSB] = present;
    reg_devarch[REG_ARCHITECT_SLICE_MSB:REG_ARCHITECT_SLICE_LSB] = architect;
  end


wire sel_devtype = (paddr == REGA_DEVTYPE);

reg  [31:0] reg_devtype;
wire rd_devtype = (sel_devtype);

wire [REG_MAJOR_MSB:0] major = REG_MAJOR_INIT;
wire [REG_SUB_MSB:0] sub = REG_SUB_INIT;


  always @*
  begin : p_devtype_comb
    reg_devtype = 32'd0;
    reg_devtype[REG_MAJOR_SLICE_MSB:REG_MAJOR_SLICE_LSB] = major;
    reg_devtype[REG_SUB_SLICE_MSB:REG_SUB_SLICE_LSB] = sub;
  end


wire sel_pidr0 = (paddr == REGA_PIDR0);

reg  [31:0] reg_pidr0;
wire rd_pidr0 = (sel_pidr0);

wire [REG_PART_0_MSB:0] part_0 = REG_PART_0_INIT;


  always @*
  begin : p_pidr0_comb
    reg_pidr0 = 32'd0;
    reg_pidr0[REG_PART_0_SLICE_MSB:REG_PART_0_SLICE_LSB] = part_0;
  end


wire sel_pidr1 = (paddr == REGA_PIDR1);

reg  [31:0] reg_pidr1;
wire rd_pidr1 = (sel_pidr1);

wire [REG_PART_1_MSB:0] part_1 = REG_PART_1_INIT;
wire [REG_DES_0_MSB:0] des_0 = REG_DES_0_INIT;


  always @*
  begin : p_pidr1_comb
    reg_pidr1 = 32'd0;
    reg_pidr1[REG_PART_1_SLICE_MSB:REG_PART_1_SLICE_LSB] = part_1;
    reg_pidr1[REG_DES_0_SLICE_MSB:REG_DES_0_SLICE_LSB] = des_0;
  end


wire sel_pidr2 = (paddr == REGA_PIDR2);

reg  [31:0] reg_pidr2;
wire rd_pidr2 = (sel_pidr2);

wire [REG_DES_1_MSB:0] des_1 = REG_DES_1_INIT;
wire [REG_JEDEC_MSB:0] jedec = REG_JEDEC_INIT;
wire [REG_REVISION_MSB:0] revision = REG_REVISION_INIT;


  always @*
  begin : p_pidr2_comb
    reg_pidr2 = 32'd0;
    reg_pidr2[REG_DES_1_SLICE_MSB:REG_DES_1_SLICE_LSB] = des_1;
    reg_pidr2[REG_JEDEC_SLICE_MSB:REG_JEDEC_SLICE_LSB] = jedec;
    reg_pidr2[REG_REVISION_SLICE_MSB:REG_REVISION_SLICE_LSB] = revision;
  end


wire sel_pidr3 = (paddr == REGA_PIDR3);

reg  [31:0] reg_pidr3;
wire rd_pidr3 = (sel_pidr3);

wire [REG_CMOD_MSB:0] cmod = REG_CMOD_INIT;

  always @*
  begin : p_pidr3_comb
    reg_pidr3 = 32'd0;
    reg_pidr3[REG_CMOD_SLICE_MSB:REG_CMOD_SLICE_LSB] = cmod;
    reg_pidr3[REG_REVAND_SLICE_MSB:REG_REVAND_SLICE_LSB] = revand;
  end


wire sel_pidr4 = (paddr == REGA_PIDR4);

reg  [31:0] reg_pidr4;
wire rd_pidr4 = (sel_pidr4);

wire [REG_DES_2_MSB:0] des_2 = REG_DES_2_INIT;
wire [REG_SIZE_MSB:0] size = REG_SIZE_INIT;


  always @*
  begin : p_pidr4_comb
    reg_pidr4 = 32'd0;
    reg_pidr4[REG_DES_2_SLICE_MSB:REG_DES_2_SLICE_LSB] = des_2;
    reg_pidr4[REG_SIZE_SLICE_MSB:REG_SIZE_SLICE_LSB] = size;
  end


wire sel_pidr5 = (paddr == REGA_PIDR5);

reg  [31:0] reg_pidr5;
wire rd_pidr5 = (sel_pidr5);

wire [REG_PIDR5_MSB:0] pidr5 = REG_PIDR5_INIT;


  always @*
  begin : p_pidr5_comb
    reg_pidr5 = 32'd0;
    reg_pidr5[REG_PIDR5_SLICE_MSB:REG_PIDR5_SLICE_LSB] = pidr5;
  end


wire sel_pidr6 = (paddr == REGA_PIDR6);

reg  [31:0] reg_pidr6;
wire rd_pidr6 = (sel_pidr6);

wire [REG_PIDR6_MSB:0] pidr6 = REG_PIDR6_INIT;


  always @*
  begin : p_pidr6_comb
    reg_pidr6 = 32'd0;
    reg_pidr6[REG_PIDR6_SLICE_MSB:REG_PIDR6_SLICE_LSB] = pidr6;
  end


wire sel_pidr7 = (paddr == REGA_PIDR7);

reg  [31:0] reg_pidr7;
wire rd_pidr7 = (sel_pidr7);

wire [REG_PIDR7_MSB:0] pidr7 = REG_PIDR7_INIT;


  always @*
  begin : p_pidr7_comb
    reg_pidr7 = 32'd0;
    reg_pidr7[REG_PIDR7_SLICE_MSB:REG_PIDR7_SLICE_LSB] = pidr7;
  end


wire sel_cidr0 = (paddr == REGA_CIDR0);

reg  [31:0] reg_cidr0;
wire rd_cidr0 = (sel_cidr0);

wire [REG_PRMBL_0_MSB:0] prmbl_0 = REG_PRMBL_0_INIT;


  always @*
  begin : p_cidr0_comb
    reg_cidr0 = 32'd0;
    reg_cidr0[REG_PRMBL_0_SLICE_MSB:REG_PRMBL_0_SLICE_LSB] = prmbl_0;
  end


wire sel_cidr1 = (paddr == REGA_CIDR1);

reg  [31:0] reg_cidr1;
wire rd_cidr1 = (sel_cidr1);

wire [REG_PRMBL_1_MSB:0] prmbl_1 = REG_PRMBL_1_INIT;
wire [REG_COMP_CLASS_MSB:0] comp_class = REG_COMP_CLASS_INIT;


  always @*
  begin : p_cidr1_comb
    reg_cidr1 = 32'd0;
    reg_cidr1[REG_PRMBL_1_SLICE_MSB:REG_PRMBL_1_SLICE_LSB] = prmbl_1;
    reg_cidr1[REG_COMP_CLASS_SLICE_MSB:REG_COMP_CLASS_SLICE_LSB] = comp_class;
  end


wire sel_cidr2 = (paddr == REGA_CIDR2);

reg  [31:0] reg_cidr2;
wire rd_cidr2 = (sel_cidr2);

wire [REG_PRMBL_2_MSB:0] prmbl_2 = REG_PRMBL_2_INIT;


  always @*
  begin : p_cidr2_comb
    reg_cidr2 = 32'd0;
    reg_cidr2[REG_PRMBL_2_SLICE_MSB:REG_PRMBL_2_SLICE_LSB] = prmbl_2;
  end


wire sel_cidr3 = (paddr == REGA_CIDR3);

reg  [31:0] reg_cidr3;
wire rd_cidr3 = (sel_cidr3);

wire [REG_PRMBL_3_MSB:0] prmbl_3 = REG_PRMBL_3_INIT;


  always @*
  begin : p_cidr3_comb
    reg_cidr3 = 32'd0;
    reg_cidr3[REG_PRMBL_3_SLICE_MSB:REG_PRMBL_3_SLICE_LSB] = prmbl_3;
  end


  wire      [NUM_REGS-1:0] rddata_sel   = {
    {rd_itstatus},
    {rd_itcontrol},
    {rd_claimset},
    {rd_claimclr},
    {rd_devarch},
    {rd_devtype},
    {rd_pidr0},
    {rd_pidr1},
    {rd_pidr2},
    {rd_pidr3},
    {rd_pidr4},
    {rd_pidr5},
    {rd_pidr6},
    {rd_pidr7},
    {rd_cidr0},
    {rd_cidr1},
    {rd_cidr2},
    {rd_cidr3}
  };

  wire [(NUM_REGS*32)-1:0] rddata_array = {
    {reg_itstatus},
    {reg_itcontrol},
    {reg_claimset},
    {reg_claimclr},
    {reg_devarch},
    {reg_devtype},
    {reg_pidr0},
    {reg_pidr1},
    {reg_pidr2},
    {reg_pidr3},
    {reg_pidr4},
    {reg_pidr5},
    {reg_pidr6},
    {reg_pidr7},
    {reg_cidr0},
    {reg_cidr1},
    {reg_cidr2},
    {reg_cidr3}
  };

  css600_one_hot_mux
  #(
    .SEL_WIDTH      (18),
    .DATA_WIDTH     (32)
  )
  u_apb_rdata_mux
  (
    .inp_sel   (rddata_sel),
    .inp_data  (rddata_array),
    .out_data  (prdata)
  );


endmodule

