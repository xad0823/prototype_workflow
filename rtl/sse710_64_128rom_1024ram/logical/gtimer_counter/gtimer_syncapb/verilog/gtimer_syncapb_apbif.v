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


module gtimer_syncapb_apbif (
  input  wire         PCLK,
  input  wire         PRESETn,

  input  wire [11:2]  PADDRCNTBASEN,
  input  wire         PSELCNTBASEN,
  input  wire         PENABLECNTBASEN,
  input  wire         PWRITECNTBASEN,
  input  wire [31:0]  PWDATACNTBASEN,

  output wire         PREADYCNTBASEN,
  output reg  [31:0]  PRDATACNTBASEN,
  output wire         PSLVERRCNTBASEN,
                      
  input  wire [11:2]  PADDRCNTPL0BASEN,
  input  wire         PSELCNTPL0BASEN,
  input  wire         PENABLECNTPL0BASEN,
  input  wire         PWRITECNTPL0BASEN,
  input  wire [31:0]  PWDATACNTPL0BASEN,

  output reg          PREADYCNTPL0BASEN,
  output reg  [31:0]  PRDATACNTPL0BASEN,
  output wire         PSLVERRCNTPL0BASEN,
                      
  input  wire  [3:0]  revision,

  input  wire         TIMERFVIREG,
  input  wire         TIMERFPL0REG,
  input  wire  [5:0]  access_control,

  output wire         cntpu_cval_write_cntbasen,
  output wire         cntpl_cval_write_cntbasen,
  output wire         cntp_tval_write_cntbasen,
  output wire         cntp_ctl_write_cntbasen,
  output wire         cntvu_cval_write_cntbasen,
  output wire         cntvl_cval_write_cntbasen,
  output wire         cntv_tval_write_cntbasen,
  output wire         cntv_ctl_write_cntbasen,
  output wire [31:0]  pwdata_enabled_cntbasen,

  output wire         cntpu_cval_write_cntpl0basen,
  output wire         cntpl_cval_write_cntpl0basen,
  output wire         cntp_tval_write_cntpl0basen,
  output wire         cntp_ctl_write_cntpl0basen,
  output wire         cntvu_cval_write_cntpl0basen,
  output wire         cntvl_cval_write_cntpl0basen,
  output wire         cntv_tval_write_cntpl0basen,
  output wire         cntv_ctl_write_cntpl0basen,
  output wire [31:0]  pwdata_enabled_cntpl0basen,

  input  wire [63:0]  virtual_offset,
  input  wire [63:0]  timer_count_phys_in,
  input  wire [63:0]  compare_value_phys_in,
  input  wire [31:0]  timer_value_phys_in,
  input  wire  [2:0]  timer_control_phys_in,                    
  input  wire [63:0]  timer_count_virt_in,
  input  wire [63:0]  compare_value_virt_in,
  input  wire [31:0]  timer_value_virt_in,
  input  wire  [2:0]  timer_control_virt_in
);






`define CNTLPCT_ADDR      10'b0000000000
`define CNTUPCT_ADDR      10'b0000000001
`define CNTLVCT_ADDR      10'b0000000010
`define CNTUVCT_ADDR      10'b0000000011
`define CNTFRQ_ADDR       10'b0000000100
`define CNTPL0ACR_ADDR    10'b0000000101
`define CNTLVOFF_ADDR     10'b0000000110
`define CNTUVOFF_ADDR     10'b0000000111
`define CNTPL_CVAL_ADDR   10'b0000001000
`define CNTPU_CVAL_ADDR   10'b0000001001
`define CNTP_TVAL_ADDR    10'b0000001010
`define CNTP_CTL_ADDR     10'b0000001011
`define CNTVL_CVAL_ADDR   10'b0000001100
`define CNTVU_CVAL_ADDR   10'b0000001101
`define CNTV_TVAL_ADDR    10'b0000001110
`define CNTV_CTL_ADDR     10'b0000001111

`define CNTPIDR4_ADDR     10'b1111110100

`define CNTPIDR0_ADDR     10'b1111111000
`define CNTPIDR1_ADDR     10'b1111111001
`define CNTPIDR2_ADDR     10'b1111111010
`define CNTPIDR3_ADDR     10'b1111111011

`define CNTCIDR0_ADDR     10'b1111111100
`define CNTCIDR1_ADDR     10'b1111111101
`define CNTCIDR2_ADDR     10'b1111111110
`define CNTCIDR3_ADDR     10'b1111111111

   

`define GTIMER_PART_0_CNTBASEN      8'b1010_0010
`define GTIMER_PART_0_CNTPL0BASEN   8'b1010_0011
`define GTIMER_PART_1               4'b0000
`define GTIMER_DES_0                4'b1011
`define GTIMER_DES_1                3'b011
`define GTIMER_DES_2                4'b0100
`define GTIMER_SIZE                 4'b0000
`define GTIMER_JEDEC                1'b1
`define GTIMER_CMOD                 4'b0000
`define GTIMER_REVAND               4'b0000

`define GTIMER_CNTCIDR       32'hB105F00D



wire         bad_address_combination;

wire [31:0]  next_cntfrq;
reg  [31:0]  cntfrq;
wire  [9:0]  next_cntpl0acr;
wire  [9:0]  cntpl0acr_mask;
reg   [9:0]  cntpl0acr;

wire         RWPT;
wire         RWVT;
wire         RVOFF;
wire         RFRQ;
wire         RVCT;
wire         RPCT;
wire  [5:0]  dum;
wire         PL0VTEN;
wire         PL0PTEN;
wire         PL0VCTEN;
wire         PL0PCTEN; 


wire [11:2]  paddr_enabled_cntbasen;
wire         write_enable_cntbasen;
wire         read_enable_cntbasen;

reg  [24:0]  register_select_cntbasen;
wire         cntlpct_select_cntbasen;
wire         cntupct_select_cntbasen;
wire         cntlvct_select_cntbasen;
wire         cntuvct_select_cntbasen;
wire         cntfrq_select_cntbasen;
wire         cntpl0acr_select_cntbasen;
wire         cntlvoff_select_cntbasen;
wire         cntuvoff_select_cntbasen;
wire         cntpl_cval_select_cntbasen;
wire         cntpu_cval_select_cntbasen;
wire         cntp_tval_select_cntbasen;
wire         cntp_ctl_select_cntbasen;
wire         cntvl_cval_select_cntbasen;
wire         cntvu_cval_select_cntbasen;
wire         cntv_tval_select_cntbasen;
wire         cntv_ctl_select_cntbasen;
wire         cntcidr0_select_cntbasen;
wire         cntcidr1_select_cntbasen;
wire         cntcidr2_select_cntbasen;
wire         cntcidr3_select_cntbasen;
wire         cntpidr4_select_cntbasen;
wire         cntpidr0_select_cntbasen;
wire         cntpidr1_select_cntbasen;
wire         cntpidr2_select_cntbasen;
wire         cntpidr3_select_cntbasen;

wire         cntpct_access_enable_cntbasen;
wire         cntvct_access_enable_cntbasen;
wire         cntfrq_access_enable_cntbasen;
wire         cntpl0acr_access_enable_cntbasen;
wire         cntvoff_access_enable_cntbasen;
wire         cntp_star_access_enable_cntbasen;
wire         cntv_star_access_enable_cntbasen;

wire         cntfrq_write_cntbasen;
wire         cntpl0acr_write_cntbasen;

wire         cntlpct_read_cntbasen;
wire         cntupct_read_cntbasen;
wire         cntlvct_read_cntbasen;
wire         cntuvct_read_cntbasen;
wire         cntfrq_read_cntbasen;
wire         cntpl0acr_read_cntbasen;
wire         cntlvoff_read_cntbasen;
wire         cntuvoff_read_cntbasen;
wire         cntpl_cval_read_cntbasen;
wire         cntpu_cval_read_cntbasen;
wire         cntp_tval_read_cntbasen;
wire         cntp_ctl_read_cntbasen;
wire         cntvl_cval_read_cntbasen;
wire         cntvu_cval_read_cntbasen;
wire         cntv_tval_read_cntbasen;
wire         cntv_ctl_read_cntbasen;
wire         cntpidr4_read_cntbasen;
wire         cntpidr0_read_cntbasen;
wire         cntpidr1_read_cntbasen;
wire         cntpidr2_read_cntbasen;
wire         cntpidr3_read_cntbasen;
wire         cntcidr0_read_cntbasen;
wire         cntcidr1_read_cntbasen;
wire         cntcidr2_read_cntbasen;
wire         cntcidr3_read_cntbasen;

reg  [31:0]  next_prdata_cntbasen;


wire [11:2]  paddr_enabled_cntpl0basen;
wire         write_enable_cntpl0basen;
wire         read_enable_cntpl0basen;
wire         next_preadycntpl0basen;


reg  [21:0]  register_select_cntpl0basen;
wire         cntlpct_select_cntpl0basen;
wire         cntupct_select_cntpl0basen;
wire         cntlvct_select_cntpl0basen;
wire         cntuvct_select_cntpl0basen;
wire         cntfrq_select_cntpl0basen;
wire         cntpl_cval_select_cntpl0basen;
wire         cntpu_cval_select_cntpl0basen;
wire         cntp_tval_select_cntpl0basen;
wire         cntp_ctl_select_cntpl0basen;
wire         cntvl_cval_select_cntpl0basen;
wire         cntvu_cval_select_cntpl0basen;
wire         cntv_tval_select_cntpl0basen;
wire         cntv_ctl_select_cntpl0basen;
wire         cntcidr0_select_cntpl0basen;
wire         cntcidr1_select_cntpl0basen;
wire         cntcidr2_select_cntpl0basen;
wire         cntcidr3_select_cntpl0basen;
wire         cntpidr4_select_cntpl0basen;
wire         cntpidr0_select_cntpl0basen;
wire         cntpidr1_select_cntpl0basen;
wire         cntpidr2_select_cntpl0basen;
wire         cntpidr3_select_cntpl0basen;

wire         cntpct_access_enable_cntpl0basen;
wire         cntvct_access_enable_cntpl0basen;
wire         cntfrq_rdaccess_enable_cntpl0basen;
wire         cntp_star_access_enable_cntpl0basen;
wire         cntv_star_access_enable_cntpl0basen;
wire         cntpidr_access_enable_cntpl0basen;
wire         cntcidr_access_enable_cntpl0basen;

wire         cntlpct_read_cntpl0basen;
wire         cntupct_read_cntpl0basen;
wire         cntlvct_read_cntpl0basen;
wire         cntuvct_read_cntpl0basen;
wire         cntfrq_read_cntpl0basen;
wire         cntpl_cval_read_cntpl0basen;
wire         cntpu_cval_read_cntpl0basen;
wire         cntp_tval_read_cntpl0basen;
wire         cntp_ctl_read_cntpl0basen;
wire         cntvl_cval_read_cntpl0basen;
wire         cntvu_cval_read_cntpl0basen;
wire         cntv_tval_read_cntpl0basen;
wire         cntv_ctl_read_cntpl0basen;
wire         cntpidr4_read_cntpl0basen;
wire         cntpidr0_read_cntpl0basen;
wire         cntpidr1_read_cntpl0basen;
wire         cntpidr2_read_cntpl0basen;
wire         cntpidr3_read_cntpl0basen;
wire         cntcidr0_read_cntpl0basen;
wire         cntcidr1_read_cntpl0basen;
wire         cntcidr2_read_cntpl0basen;
wire         cntcidr3_read_cntpl0basen;

reg  [31:0]  next_prdata_cntpl0basen;


wire [7:0]  cntpidr4;
wire [7:0]  cntpidr0_cntbasen;
wire [7:0]  cntpidr0_cntpl0basen;
wire [7:0]  cntpidr1;
wire [7:0]  cntpidr2;
wire [7:0]  cntpidr3;
wire [31:0] cntcidrall;  

assign cntpidr4              =  {`GTIMER_SIZE, `GTIMER_DES_2};
assign cntpidr0_cntbasen     =  `GTIMER_PART_0_CNTBASEN;
assign cntpidr0_cntpl0basen  =  `GTIMER_PART_0_CNTPL0BASEN;
assign cntpidr1              =  {`GTIMER_DES_0, `GTIMER_PART_1};
assign cntpidr2              =  {revision, `GTIMER_JEDEC, `GTIMER_DES_1};
assign cntpidr3              =  {`GTIMER_REVAND, `GTIMER_CMOD};

assign cntcidrall            =  `GTIMER_CNTCIDR;


assign pwdata_enabled_cntbasen = (PSELCNTBASEN & PWRITECNTBASEN) ?  PWDATACNTBASEN : 32'h0000_0000;

assign paddr_enabled_cntbasen  =  PSELCNTBASEN ? PADDRCNTBASEN : 10'b0000000000;

assign write_enable_cntbasen   =  PSELCNTBASEN & PWRITECNTBASEN & PENABLECNTBASEN;

assign read_enable_cntbasen    =  PSELCNTBASEN & (~PWRITECNTBASEN) & (~PENABLECNTBASEN);

assign PREADYCNTBASEN          =  1'b1;
assign PSLVERRCNTBASEN         =  1'b0;

assign pwdata_enabled_cntpl0basen   = (PSELCNTPL0BASEN & PWRITECNTPL0BASEN) ?  PWDATACNTPL0BASEN : 32'h0000_0000;

assign paddr_enabled_cntpl0basen    =  PSELCNTPL0BASEN ? PADDRCNTPL0BASEN : 10'b0000000000;

assign bad_address_combination      = (PADDRCNTBASEN == PADDRCNTPL0BASEN) |
                                      (((PADDRCNTBASEN == `CNTPL_CVAL_ADDR) | (PADDRCNTBASEN == `CNTPU_CVAL_ADDR) | (PADDRCNTBASEN == `CNTP_TVAL_ADDR)) & ((PADDRCNTPL0BASEN == `CNTPL_CVAL_ADDR) | (PADDRCNTPL0BASEN == `CNTPU_CVAL_ADDR) | (PADDRCNTPL0BASEN == `CNTP_TVAL_ADDR))) |
                                      (((PADDRCNTBASEN == `CNTVL_CVAL_ADDR) | (PADDRCNTBASEN == `CNTVU_CVAL_ADDR) | (PADDRCNTBASEN == `CNTV_TVAL_ADDR)) & ((PADDRCNTPL0BASEN == `CNTVL_CVAL_ADDR) | (PADDRCNTPL0BASEN == `CNTVU_CVAL_ADDR) | (PADDRCNTPL0BASEN == `CNTV_TVAL_ADDR)));

assign next_preadycntpl0basen = ~(PSELCNTBASEN & PSELCNTPL0BASEN & ~PENABLECNTBASEN & ~PENABLECNTPL0BASEN & (PWRITECNTBASEN | PWRITECNTPL0BASEN) & (bad_address_combination));

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    PREADYCNTPL0BASEN <= 1'b1;
  else
    PREADYCNTPL0BASEN <= next_preadycntpl0basen;


assign write_enable_cntpl0basen     =  PSELCNTPL0BASEN & PENABLECNTPL0BASEN & PWRITECNTPL0BASEN & PREADYCNTPL0BASEN;

assign read_enable_cntpl0basen      =  (PSELCNTPL0BASEN & (~PWRITECNTPL0BASEN) & (~PENABLECNTPL0BASEN)) | (PSELCNTPL0BASEN & (~PWRITECNTPL0BASEN) & PENABLECNTPL0BASEN & (~PREADYCNTPL0BASEN));

assign PSLVERRCNTPL0BASEN           =  1'b0;






always @*
  begin
    register_select_cntbasen = 25'h00_0000;
  
    case (paddr_enabled_cntbasen)
      `CNTLPCT_ADDR    :  register_select_cntbasen[0] = 1'b1;
      `CNTUPCT_ADDR    :  register_select_cntbasen[1] = 1'b1;
      `CNTLVCT_ADDR    :  register_select_cntbasen[2] = 1'b1;
      `CNTUVCT_ADDR    :  register_select_cntbasen[3] = 1'b1;
      `CNTFRQ_ADDR     :  register_select_cntbasen[4] = 1'b1;
      `CNTPL0ACR_ADDR  :  register_select_cntbasen[5] = 1'b1;
      `CNTLVOFF_ADDR   :  register_select_cntbasen[6] = 1'b1;
      `CNTUVOFF_ADDR   :  register_select_cntbasen[7] = 1'b1;
      `CNTPL_CVAL_ADDR :  register_select_cntbasen[8] = 1'b1;
      `CNTPU_CVAL_ADDR :  register_select_cntbasen[9] = 1'b1;
      `CNTP_TVAL_ADDR  :  register_select_cntbasen[10] = 1'b1;
      `CNTP_CTL_ADDR   :  register_select_cntbasen[11] = 1'b1;
      `CNTVL_CVAL_ADDR :  register_select_cntbasen[12] = 1'b1;
      `CNTVU_CVAL_ADDR :  register_select_cntbasen[13] = 1'b1;
      `CNTV_TVAL_ADDR  :  register_select_cntbasen[14] = 1'b1;
      `CNTV_CTL_ADDR   :  register_select_cntbasen[15] = 1'b1;
      `CNTPIDR4_ADDR   :  register_select_cntbasen[16] = 1'b1;
      `CNTPIDR0_ADDR   :  register_select_cntbasen[17] = 1'b1;
      `CNTPIDR1_ADDR   :  register_select_cntbasen[18] = 1'b1;
      `CNTPIDR2_ADDR   :  register_select_cntbasen[19] = 1'b1;
      `CNTPIDR3_ADDR   :  register_select_cntbasen[20] = 1'b1;
      `CNTCIDR0_ADDR   :  register_select_cntbasen[21] = 1'b1;
      `CNTCIDR1_ADDR   :  register_select_cntbasen[22] = 1'b1;
      `CNTCIDR2_ADDR   :  register_select_cntbasen[23] = 1'b1;
      `CNTCIDR3_ADDR   :  register_select_cntbasen[24] = 1'b1;
              default  :  register_select_cntbasen = 25'h00_0000;
    endcase
  end

assign {cntcidr3_select_cntbasen,   cntcidr2_select_cntbasen,   cntcidr1_select_cntbasen,   cntcidr0_select_cntbasen,
        cntpidr3_select_cntbasen,   cntpidr2_select_cntbasen,   cntpidr1_select_cntbasen,   cntpidr0_select_cntbasen,
        cntpidr4_select_cntbasen,
        cntv_ctl_select_cntbasen,   cntv_tval_select_cntbasen,  cntvu_cval_select_cntbasen, cntvl_cval_select_cntbasen,
        cntp_ctl_select_cntbasen,   cntp_tval_select_cntbasen,  cntpu_cval_select_cntbasen, cntpl_cval_select_cntbasen,
        cntuvoff_select_cntbasen,   cntlvoff_select_cntbasen,   cntpl0acr_select_cntbasen,  cntfrq_select_cntbasen,
        cntuvct_select_cntbasen,    cntlvct_select_cntbasen,    cntupct_select_cntbasen,    cntlpct_select_cntbasen}
        = register_select_cntbasen;


assign {RWPT, RWVT, RVOFF, RFRQ, RVCT, RPCT} = access_control;

assign cntpct_access_enable_cntbasen     =  RPCT;
assign cntvct_access_enable_cntbasen     =  RVCT;
assign cntfrq_access_enable_cntbasen     =  RFRQ;
assign cntpl0acr_access_enable_cntbasen  =  TIMERFPL0REG;
assign cntvoff_access_enable_cntbasen    =  TIMERFVIREG & RVOFF;
assign cntp_star_access_enable_cntbasen  =  RWPT;
assign cntv_star_access_enable_cntbasen  =  TIMERFVIREG & RWVT;


assign cntfrq_write_cntbasen      =  ( cntfrq_access_enable_cntbasen    & write_enable_cntbasen & cntfrq_select_cntbasen );
assign cntpl0acr_write_cntbasen   =  ( cntpl0acr_access_enable_cntbasen & write_enable_cntbasen & cntpl0acr_select_cntbasen );
assign cntpl_cval_write_cntbasen  =  ( cntp_star_access_enable_cntbasen & write_enable_cntbasen & cntpl_cval_select_cntbasen );
assign cntpu_cval_write_cntbasen  =  ( cntp_star_access_enable_cntbasen & write_enable_cntbasen & cntpu_cval_select_cntbasen );
assign cntp_tval_write_cntbasen   =  ( cntp_star_access_enable_cntbasen & write_enable_cntbasen & cntp_tval_select_cntbasen );
assign cntp_ctl_write_cntbasen    =  ( cntp_star_access_enable_cntbasen & write_enable_cntbasen & cntp_ctl_select_cntbasen );
assign cntvl_cval_write_cntbasen  =  ( cntv_star_access_enable_cntbasen & write_enable_cntbasen & cntvl_cval_select_cntbasen );
assign cntvu_cval_write_cntbasen  =  ( cntv_star_access_enable_cntbasen & write_enable_cntbasen & cntvu_cval_select_cntbasen );
assign cntv_tval_write_cntbasen   =  ( cntv_star_access_enable_cntbasen & write_enable_cntbasen & cntv_tval_select_cntbasen );
assign cntv_ctl_write_cntbasen    =  ( cntv_star_access_enable_cntbasen & write_enable_cntbasen & cntv_ctl_select_cntbasen );

assign cntlpct_read_cntbasen      =  ( cntpct_access_enable_cntbasen & read_enable_cntbasen & cntlpct_select_cntbasen );
assign cntupct_read_cntbasen      =  ( cntpct_access_enable_cntbasen & read_enable_cntbasen & cntupct_select_cntbasen );
assign cntlvct_read_cntbasen      =  ( cntvct_access_enable_cntbasen & read_enable_cntbasen & cntlvct_select_cntbasen );
assign cntuvct_read_cntbasen      =  ( cntvct_access_enable_cntbasen & read_enable_cntbasen & cntuvct_select_cntbasen );
assign cntfrq_read_cntbasen       =  ( cntfrq_access_enable_cntbasen & read_enable_cntbasen & cntfrq_select_cntbasen );
assign cntpl0acr_read_cntbasen    =  ( cntpl0acr_access_enable_cntbasen & read_enable_cntbasen & cntpl0acr_select_cntbasen );
assign cntlvoff_read_cntbasen     =  ( cntvoff_access_enable_cntbasen   & read_enable_cntbasen & cntlvoff_select_cntbasen );
assign cntuvoff_read_cntbasen     =  ( cntvoff_access_enable_cntbasen   & read_enable_cntbasen & cntuvoff_select_cntbasen );
assign cntpl_cval_read_cntbasen   =  ( cntp_star_access_enable_cntbasen & read_enable_cntbasen & cntpl_cval_select_cntbasen );
assign cntpu_cval_read_cntbasen   =  ( cntp_star_access_enable_cntbasen & read_enable_cntbasen & cntpu_cval_select_cntbasen );
assign cntp_tval_read_cntbasen    =  ( cntp_star_access_enable_cntbasen & read_enable_cntbasen & cntp_tval_select_cntbasen );
assign cntp_ctl_read_cntbasen     =  ( cntp_star_access_enable_cntbasen & read_enable_cntbasen & cntp_ctl_select_cntbasen );
assign cntvl_cval_read_cntbasen   =  ( cntv_star_access_enable_cntbasen & read_enable_cntbasen & cntvl_cval_select_cntbasen );
assign cntvu_cval_read_cntbasen   =  ( cntv_star_access_enable_cntbasen & read_enable_cntbasen & cntvu_cval_select_cntbasen );
assign cntv_tval_read_cntbasen    =  ( cntv_star_access_enable_cntbasen & read_enable_cntbasen & cntv_tval_select_cntbasen );
assign cntv_ctl_read_cntbasen     =  ( cntv_star_access_enable_cntbasen & read_enable_cntbasen & cntv_ctl_select_cntbasen );
assign cntpidr4_read_cntbasen     =  ( read_enable_cntbasen & cntpidr4_select_cntbasen );
assign cntpidr0_read_cntbasen     =  ( read_enable_cntbasen & cntpidr0_select_cntbasen );
assign cntpidr1_read_cntbasen     =  ( read_enable_cntbasen & cntpidr1_select_cntbasen );
assign cntpidr2_read_cntbasen     =  ( read_enable_cntbasen & cntpidr2_select_cntbasen );
assign cntpidr3_read_cntbasen     =  ( read_enable_cntbasen & cntpidr3_select_cntbasen );
assign cntcidr0_read_cntbasen     =  ( read_enable_cntbasen & cntcidr0_select_cntbasen );
assign cntcidr1_read_cntbasen     =  ( read_enable_cntbasen & cntcidr1_select_cntbasen );
assign cntcidr2_read_cntbasen     =  ( read_enable_cntbasen & cntcidr2_select_cntbasen );
assign cntcidr3_read_cntbasen     =  ( read_enable_cntbasen & cntcidr3_select_cntbasen );



assign  next_cntfrq      =  (cntfrq_write_cntbasen)  ?  pwdata_enabled_cntbasen  :  cntfrq;

assign  cntpl0acr_mask   =  10'h303;
assign  next_cntpl0acr   =  (cntpl0acr_write_cntbasen)  ?  (pwdata_enabled_cntbasen[9:0] & cntpl0acr_mask) :  cntpl0acr;
        
 
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntfrq     <=  32'h0000_0000;
      cntpl0acr  <=  10'h00;  
    end
  else
    begin
      cntfrq     <=  next_cntfrq;
      cntpl0acr  <=  next_cntpl0acr;
    end


always @*
  case ({cntlpct_read_cntbasen,    cntupct_read_cntbasen,    cntlvct_read_cntbasen,   cntuvct_read_cntbasen,
         cntfrq_read_cntbasen,     cntpl0acr_read_cntbasen,  cntlvoff_read_cntbasen,  cntuvoff_read_cntbasen,
         cntpl_cval_read_cntbasen, cntpu_cval_read_cntbasen, cntp_tval_read_cntbasen, cntp_ctl_read_cntbasen,
         cntvl_cval_read_cntbasen, cntvu_cval_read_cntbasen, cntv_tval_read_cntbasen, cntv_ctl_read_cntbasen,
         cntpidr4_read_cntbasen,
         cntpidr0_read_cntbasen,   cntpidr1_read_cntbasen,   cntpidr2_read_cntbasen,  cntpidr3_read_cntbasen,
         cntcidr0_read_cntbasen,   cntcidr1_read_cntbasen,   cntcidr2_read_cntbasen,  cntcidr3_read_cntbasen})
    25'h100_0000 : next_prdata_cntbasen = timer_count_phys_in[31:0];
    25'h080_0000 : next_prdata_cntbasen = timer_count_phys_in[63:32];
    25'h040_0000 : next_prdata_cntbasen = timer_count_virt_in[31:0];
    25'h020_0000 : next_prdata_cntbasen = timer_count_virt_in[63:32];
    25'h010_0000 : next_prdata_cntbasen = cntfrq;
    25'h008_0000 : next_prdata_cntbasen = {22'h00_0000, cntpl0acr};
    25'h004_0000 : next_prdata_cntbasen = virtual_offset[31:0];
    25'h002_0000 : next_prdata_cntbasen = virtual_offset[63:32];
    25'h001_0000 : next_prdata_cntbasen = compare_value_phys_in[31:0];
    25'h000_8000 : next_prdata_cntbasen = compare_value_phys_in[63:32];
    25'h000_4000 : next_prdata_cntbasen = timer_value_phys_in;
    25'h000_2000 : next_prdata_cntbasen = {29'h000_0000, timer_control_phys_in};
    25'h000_1000 : next_prdata_cntbasen = compare_value_virt_in[31:0];
    25'h000_0800 : next_prdata_cntbasen = compare_value_virt_in[63:32];
    25'h000_0400 : next_prdata_cntbasen = timer_value_virt_in;
    25'h000_0200 : next_prdata_cntbasen = {29'h000_0000, timer_control_virt_in};
    
    25'h000_0100 : next_prdata_cntbasen = {24'h00_0000, cntpidr4};
    
    25'h000_0080 : next_prdata_cntbasen = {24'h00_0000, cntpidr0_cntbasen};
    25'h000_0040 : next_prdata_cntbasen = {24'h00_0000, cntpidr1};
    25'h000_0020 : next_prdata_cntbasen = {24'h00_0000, cntpidr2};
    25'h000_0010 : next_prdata_cntbasen = {24'h00_0000, cntpidr3};
    
    25'h000_0008 : next_prdata_cntbasen = {24'h00_0000, cntcidrall[7:0]};
    25'h000_0004 : next_prdata_cntbasen = {24'h00_0000, cntcidrall[15:8]};
    25'h000_0002 : next_prdata_cntbasen = {24'h00_0000, cntcidrall[23:16]};
    25'h000_0001 : next_prdata_cntbasen = {24'h00_0000, cntcidrall[31:24]};
        default : next_prdata_cntbasen = 32'h0000_0000;
  endcase

always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    PRDATACNTBASEN <= 32'h0000_0000;
  else
    PRDATACNTBASEN <= next_prdata_cntbasen;
end




always @*
  begin
    register_select_cntpl0basen = 22'h00_0000;
  
    case (paddr_enabled_cntpl0basen)
      `CNTLPCT_ADDR    :  register_select_cntpl0basen[0] = 1'b1;
      `CNTUPCT_ADDR    :  register_select_cntpl0basen[1] = 1'b1;
      `CNTLVCT_ADDR    :  register_select_cntpl0basen[2] = 1'b1;
      `CNTUVCT_ADDR    :  register_select_cntpl0basen[3] = 1'b1;
      `CNTFRQ_ADDR     :  register_select_cntpl0basen[4] = 1'b1;
      `CNTPL_CVAL_ADDR :  register_select_cntpl0basen[5] = 1'b1;
      `CNTPU_CVAL_ADDR :  register_select_cntpl0basen[6] = 1'b1;
      `CNTP_TVAL_ADDR  :  register_select_cntpl0basen[7] = 1'b1;
      `CNTP_CTL_ADDR   :  register_select_cntpl0basen[8] = 1'b1;
      `CNTVL_CVAL_ADDR :  register_select_cntpl0basen[9] = 1'b1;
      `CNTVU_CVAL_ADDR :  register_select_cntpl0basen[10] = 1'b1;
      `CNTV_TVAL_ADDR  :  register_select_cntpl0basen[11] = 1'b1;
      `CNTV_CTL_ADDR   :  register_select_cntpl0basen[12] = 1'b1;
      `CNTPIDR4_ADDR   :  register_select_cntpl0basen[13] = 1'b1;
      `CNTPIDR0_ADDR   :  register_select_cntpl0basen[14] = 1'b1;
      `CNTPIDR1_ADDR   :  register_select_cntpl0basen[15] = 1'b1;
      `CNTPIDR2_ADDR   :  register_select_cntpl0basen[16] = 1'b1;
      `CNTPIDR3_ADDR   :  register_select_cntpl0basen[17] = 1'b1;
      `CNTCIDR0_ADDR   :  register_select_cntpl0basen[18] = 1'b1;
      `CNTCIDR1_ADDR   :  register_select_cntpl0basen[19] = 1'b1;
      `CNTCIDR2_ADDR   :  register_select_cntpl0basen[20] = 1'b1;
      `CNTCIDR3_ADDR   :  register_select_cntpl0basen[21] = 1'b1;
              default  :  register_select_cntpl0basen = 22'h00_0000;
    endcase
  end

assign {cntcidr3_select_cntpl0basen,   cntcidr2_select_cntpl0basen,   cntcidr1_select_cntpl0basen,   cntcidr0_select_cntpl0basen,
        cntpidr3_select_cntpl0basen,   cntpidr2_select_cntpl0basen,   cntpidr1_select_cntpl0basen,   cntpidr0_select_cntpl0basen,
        cntpidr4_select_cntpl0basen,
        cntv_ctl_select_cntpl0basen,   cntv_tval_select_cntpl0basen,  cntvu_cval_select_cntpl0basen, cntvl_cval_select_cntpl0basen,
        cntp_ctl_select_cntpl0basen,   cntp_tval_select_cntpl0basen,  cntpu_cval_select_cntpl0basen, cntpl_cval_select_cntpl0basen,
        cntfrq_select_cntpl0basen,
        cntuvct_select_cntpl0basen,    cntlvct_select_cntpl0basen,    cntupct_select_cntpl0basen,    cntlpct_select_cntpl0basen}
        = register_select_cntpl0basen;


assign {PL0PTEN, PL0VTEN, dum[5:0], PL0VCTEN, PL0PCTEN} = cntpl0acr;

assign cntpct_access_enable_cntpl0basen     =  TIMERFPL0REG & PL0PCTEN & RPCT;
assign cntvct_access_enable_cntpl0basen     =  TIMERFPL0REG & PL0VCTEN & RVCT;
assign cntfrq_rdaccess_enable_cntpl0basen   =  (TIMERFPL0REG & PL0PCTEN & RFRQ) | (TIMERFPL0REG & PL0VCTEN & RFRQ);
assign cntp_star_access_enable_cntpl0basen  =  TIMERFPL0REG & PL0PTEN & RWPT;
assign cntv_star_access_enable_cntpl0basen  =  TIMERFPL0REG & TIMERFVIREG & PL0VTEN & RWVT;
assign cntpidr_access_enable_cntpl0basen    =  TIMERFPL0REG;
assign cntcidr_access_enable_cntpl0basen    =  TIMERFPL0REG;


assign cntpl_cval_write_cntpl0basen  =  ( cntp_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntpl_cval_select_cntpl0basen );
assign cntpu_cval_write_cntpl0basen  =  ( cntp_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntpu_cval_select_cntpl0basen );
assign cntp_tval_write_cntpl0basen   =  ( cntp_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntp_tval_select_cntpl0basen );
assign cntp_ctl_write_cntpl0basen    =  ( cntp_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntp_ctl_select_cntpl0basen );
assign cntvl_cval_write_cntpl0basen  =  ( cntv_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntvl_cval_select_cntpl0basen );
assign cntvu_cval_write_cntpl0basen  =  ( cntv_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntvu_cval_select_cntpl0basen );
assign cntv_tval_write_cntpl0basen   =  ( cntv_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntv_tval_select_cntpl0basen );
assign cntv_ctl_write_cntpl0basen    =  ( cntv_star_access_enable_cntpl0basen & write_enable_cntpl0basen & cntv_ctl_select_cntpl0basen );

assign cntlpct_read_cntpl0basen      =  ( cntpct_access_enable_cntpl0basen & read_enable_cntpl0basen & cntlpct_select_cntpl0basen );
assign cntupct_read_cntpl0basen      =  ( cntpct_access_enable_cntpl0basen & read_enable_cntpl0basen & cntupct_select_cntpl0basen );
assign cntlvct_read_cntpl0basen      =  ( cntvct_access_enable_cntpl0basen & read_enable_cntpl0basen & cntlvct_select_cntpl0basen );
assign cntuvct_read_cntpl0basen      =  ( cntvct_access_enable_cntpl0basen & read_enable_cntpl0basen & cntuvct_select_cntpl0basen );
assign cntfrq_read_cntpl0basen       =  ( cntfrq_rdaccess_enable_cntpl0basen  & read_enable_cntpl0basen & cntfrq_select_cntpl0basen );
assign cntpl_cval_read_cntpl0basen   =  ( cntp_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpl_cval_select_cntpl0basen );
assign cntpu_cval_read_cntpl0basen   =  ( cntp_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpu_cval_select_cntpl0basen );
assign cntp_tval_read_cntpl0basen    =  ( cntp_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntp_tval_select_cntpl0basen );
assign cntp_ctl_read_cntpl0basen     =  ( cntp_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntp_ctl_select_cntpl0basen );
assign cntvl_cval_read_cntpl0basen   =  ( cntv_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntvl_cval_select_cntpl0basen );
assign cntvu_cval_read_cntpl0basen   =  ( cntv_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntvu_cval_select_cntpl0basen );
assign cntv_tval_read_cntpl0basen    =  ( cntv_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntv_tval_select_cntpl0basen );
assign cntv_ctl_read_cntpl0basen     =  ( cntv_star_access_enable_cntpl0basen & read_enable_cntpl0basen & cntv_ctl_select_cntpl0basen );
assign cntpidr4_read_cntpl0basen     =  ( cntpidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpidr4_select_cntpl0basen );
assign cntpidr0_read_cntpl0basen     =  ( cntpidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpidr0_select_cntpl0basen );
assign cntpidr1_read_cntpl0basen     =  ( cntpidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpidr1_select_cntpl0basen );
assign cntpidr2_read_cntpl0basen     =  ( cntpidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpidr2_select_cntpl0basen );
assign cntpidr3_read_cntpl0basen     =  ( cntpidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntpidr3_select_cntpl0basen );
assign cntcidr0_read_cntpl0basen     =  ( cntcidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntcidr0_select_cntpl0basen );
assign cntcidr1_read_cntpl0basen     =  ( cntcidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntcidr1_select_cntpl0basen );
assign cntcidr2_read_cntpl0basen     =  ( cntcidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntcidr2_select_cntpl0basen );
assign cntcidr3_read_cntpl0basen     =  ( cntcidr_access_enable_cntpl0basen & read_enable_cntpl0basen & cntcidr3_select_cntpl0basen );


always @*
  case ({cntlpct_read_cntpl0basen,    cntupct_read_cntpl0basen,    cntlvct_read_cntpl0basen,   cntuvct_read_cntpl0basen,
         cntfrq_read_cntpl0basen,
         cntpl_cval_read_cntpl0basen, cntpu_cval_read_cntpl0basen, cntp_tval_read_cntpl0basen, cntp_ctl_read_cntpl0basen,
         cntvl_cval_read_cntpl0basen, cntvu_cval_read_cntpl0basen, cntv_tval_read_cntpl0basen, cntv_ctl_read_cntpl0basen,
         cntpidr4_read_cntpl0basen,
         cntpidr0_read_cntpl0basen,   cntpidr1_read_cntpl0basen,   cntpidr2_read_cntpl0basen,  cntpidr3_read_cntpl0basen,
         cntcidr0_read_cntpl0basen,   cntcidr1_read_cntpl0basen,   cntcidr2_read_cntpl0basen,  cntcidr3_read_cntpl0basen})
    22'h20_0000 : next_prdata_cntpl0basen = timer_count_phys_in[31:0];
    22'h10_0000 : next_prdata_cntpl0basen = timer_count_phys_in[63:32];
    22'h08_0000 : next_prdata_cntpl0basen = timer_count_virt_in[31:0];
    22'h04_0000 : next_prdata_cntpl0basen = timer_count_virt_in[63:32];
    22'h02_0000 : next_prdata_cntpl0basen = cntfrq;
    22'h01_0000 : next_prdata_cntpl0basen = compare_value_phys_in[31:0];
    22'h00_8000 : next_prdata_cntpl0basen = compare_value_phys_in[63:32];
    22'h00_4000 : next_prdata_cntpl0basen = timer_value_phys_in;
    22'h00_2000 : next_prdata_cntpl0basen = {29'h000_0000, timer_control_phys_in};
    22'h00_1000 : next_prdata_cntpl0basen = compare_value_virt_in[31:0];
    22'h00_0800 : next_prdata_cntpl0basen = compare_value_virt_in[63:32];
    22'h00_0400 : next_prdata_cntpl0basen = timer_value_virt_in;
    22'h00_0200 : next_prdata_cntpl0basen = {29'h000_0000, timer_control_virt_in};
    
    22'h00_0100 : next_prdata_cntpl0basen = {24'h00_0000, cntpidr4};
    
    22'h00_0080 : next_prdata_cntpl0basen = {24'h00_0000, cntpidr0_cntpl0basen};
    22'h00_0040 : next_prdata_cntpl0basen = {24'h00_0000, cntpidr1};
    22'h00_0020 : next_prdata_cntpl0basen = {24'h00_0000, cntpidr2};
    22'h00_0010 : next_prdata_cntpl0basen = {24'h00_0000, cntpidr3};
    
    22'h00_0008 : next_prdata_cntpl0basen = {24'h00_0000, cntcidrall[7:0]};
    22'h00_0004 : next_prdata_cntpl0basen = {24'h00_0000, cntcidrall[15:8]};
    22'h00_0002 : next_prdata_cntpl0basen = {24'h00_0000, cntcidrall[23:16]};
    22'h00_0001 : next_prdata_cntpl0basen = {24'h00_0000, cntcidrall[31:24]};
        default : next_prdata_cntpl0basen = 32'h0000_0000;
  endcase

always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    PRDATACNTPL0BASEN <= 32'h0000_0000;
  else
    PRDATACNTPL0BASEN <= next_prdata_cntpl0basen;
end


`undef CNTPCTL_ADDR
`undef CNTPCTU_ADDR
`undef CNTVCTL_ADDR
`undef CNTVCTU_ADDR
`undef CNTFRQ_ADDR
`undef CNTPL0ACR_ADDR
`undef CNTVOFFL_ADDR
`undef CNTVOFFU_ADDR
`undef CNTP_CVALL_ADDR
`undef CNTP_CVALU_ADDR
`undef CNTP_TVAL_ADDR
`undef CNTP_CTL_ADDR
`undef CNTV_CVALL_ADDR
`undef CNTV_CVALU_ADDR
`undef CNTV_TVAL_ADDR
`undef CNTV_CTL_ADDR
`undef CNTPIDR4_ADDR
`undef CNTPIDR0_ADDR
`undef CNTPIDR1_ADDR
`undef CNTPIDR2_ADDR
`undef CNTPIDR3_ADDR
`undef CNTCIDR0_ADDR
`undef CNTCIDR1_ADDR
`undef CNTCIDR2_ADDR
`undef CNTCIDR3_ADDR
`undef GTIMER_PART_0_CNTBASEN
`undef GTIMER_PART_0_CNTPL0BASEN
`undef GTIMER_PART_1
`undef GTIMER_DES_0
`undef GTIMER_DES_1
`undef GTIMER_DES_2
`undef GTIMER_SIZE
`undef GTIMER_JEDEC
`undef GTIMER_CMOD
`undef GTIMER_REVAND

endmodule
