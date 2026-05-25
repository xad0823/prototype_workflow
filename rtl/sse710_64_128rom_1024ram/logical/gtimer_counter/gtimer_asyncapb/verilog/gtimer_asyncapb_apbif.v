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


module gtimer_asyncapb_apbif (
  input  wire         PCLK,
  input  wire         PRESETn,

  input  wire [11:2]  PADDRCNTBASEN,
  input  wire         PSELCNTBASEN,
  input  wire         PENABLECNTBASEN,
  input  wire         PWRITECNTBASEN,
  input  wire [31:0]  PWDATACNTBASEN,

  output reg          PREADYCNTBASEN,
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
  input  wire  [5:0]  CNTACR,
  input  wire [63:0]  CNTVOFF,
  input  wire         cntvoff_sync,
  output reg  [63:0]  int_cntvoff,

  output wire         cntpl_cval_write_in_progress_toggle,
  input  wire         cntpl_cval_write_complete,
  output wire [31:0]  cntpl_cval_write_val,
    
  output wire         cntpu_cval_write_in_progress_toggle,
  input  wire         cntpu_cval_write_complete,
  output wire [31:0]  cntpu_cval_write_val,

  output wire         cntp_tval_write_in_progress_toggle,
  input  wire         cntp_tval_write_complete,
  output wire [31:0]  cntp_tval_write_val,

  output wire         cntp_ctl_write_in_progress_toggle,
  input  wire         cntp_ctl_write_complete,
  output wire [1:0]   cntp_ctl_write_val,

  output wire         cntvl_cval_write_in_progress_toggle,
  input  wire         cntvl_cval_write_complete,
  output wire [31:0]  cntvl_cval_write_val,

  output wire         cntvu_cval_write_in_progress_toggle,
  input  wire         cntvu_cval_write_complete,
  output wire [31:0]  cntvu_cval_write_val,

  output wire         cntv_tval_write_in_progress_toggle,
  input  wire         cntv_tval_write_complete,
  output wire [31:0]  cntv_tval_write_val,

  output wire         cntv_ctl_write_in_progress_toggle,
  input  wire         cntv_ctl_write_complete,
  output wire [1:0]   cntv_ctl_write_val,

  input  wire [63:0]  cntpct_rd_data,
  input  wire [31:0]  cntptval_rd,
  input  wire [63:0]  cntpcval_rd,
  input  wire  [2:0]  cntpctl_rd,
  input  wire         cntp_update_timer_regs,

  input  wire [63:0]  cntvct_rd_data,
  input  wire [31:0]  cntvtval_rd,
  input  wire [63:0]  cntvcval_rd,
  input  wire  [2:0]  cntvctl_rd,
  input  wire         cntv_update_timer_regs
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

   

`define GTIMER_PART_0_CNTBASEN      8'b1010_0100
`define GTIMER_PART_0_CNTPL0BASEN   8'b1010_0101
`define GTIMER_PART_1               4'b0000
`define GTIMER_DES_0                4'b1011
`define GTIMER_DES_1                3'b011
`define GTIMER_DES_2                4'b0100
`define GTIMER_SIZE                 4'b0000
`define GTIMER_JEDEC                1'b1
`define GTIMER_CMOD                 4'b0000
`define GTIMER_REVAND               4'b0000

`define GTIMER_CNTCIDR       32'hB105F00D




wire         cntvoff_sync_pulse;

wire [63:0]  next_int_cntvoff;
reg  [63:0]  cntvoff_rd_data;
wire [63:0]  next_cntvoff_rd_data;
reg   [5:0]  int_cntacr;                     

wire         write_setup_cntbasen;
wire         write_setup_cntpl0basen;

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
wire [31:0]  pwdata_enabled_cntbasen;

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

wire         cntpl_cval_wsetup_cntbasen;
wire         cntpu_cval_wsetup_cntbasen;
wire         cntp_tval_wsetup_cntbasen;
wire         cntp_ctl_wsetup_cntbasen;
wire         cntvl_cval_wsetup_cntbasen;
wire         cntvu_cval_wsetup_cntbasen;
wire         cntv_tval_wsetup_cntbasen;
wire         cntv_ctl_wsetup_cntbasen;

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
wire [31:0]  pwdata_enabled_cntpl0basen;
wire         write_enable_cntpl0basen;
wire         read_enable_cntpl0basen;

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
wire         cntp_star_access_enable_cntpl0basen;
wire         cntv_star_access_enable_cntpl0basen;
wire         cntpidr_access_enable_cntpl0basen;
wire         cntcidr_access_enable_cntpl0basen;

wire         cntpl_cval_wsetup_cntpl0basen;
wire         cntpu_cval_wsetup_cntpl0basen;
wire         cntp_tval_wsetup_cntpl0basen;
wire         cntp_ctl_wsetup_cntpl0basen;
wire         cntvl_cval_wsetup_cntpl0basen;
wire         cntvu_cval_wsetup_cntpl0basen;
wire         cntv_tval_wsetup_cntpl0basen;
wire         cntv_ctl_wsetup_cntpl0basen;

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

wire         cntpl_cval_latch_wdata;
wire         cntpu_cval_latch_wdata;
reg          latched_cntpl_cval_latch_wdata;
reg          latched_cntpu_cval_latch_wdata;
wire         cntp_tval_latch_wdata;
wire         cntp_ctl_latch_wdata;
reg          latched_cntp_ctl_latch_wdata;

wire [63:0]  next_cntpct_rd_val;
reg  [63:0]  cntpct_rd_val;
wire         cntp_update_timer_regs_pulse;
reg  [63:0]  next_cntpcval_rd_data;
reg  [63:0]  cntpcval_rd_data;
reg   [1:0]  next_cntpctl_rd_data;
wire   [2:0]  cntpctl_rd_data;
wire [31:0]  next_cntptval_rd_val;
reg  [31:0]  cntptval_rd_val;
wire [31:0]  cntptval_rd_data;

wire         cntpl_cval_write_in_progress;
wire         cntpu_cval_write_in_progress;
wire         cntp_tval_write_in_progress;
wire         cntp_ctl_write_in_progress;
wire         cntvl_cval_write_in_progress;
wire         cntvu_cval_write_in_progress;
wire         cntv_tval_write_in_progress;
wire         cntv_ctl_write_in_progress;

wire         cntvl_cval_latch_wdata;
wire         cntvu_cval_latch_wdata;
reg          latched_cntvl_cval_latch_wdata;
reg          latched_cntvu_cval_latch_wdata;
wire         cntv_tval_latch_wdata;
wire         cntv_ctl_latch_wdata;
reg          latched_cntv_ctl_latch_wdata;

wire [63:0]  next_cntvct_rd_val;
reg  [63:0]  cntvct_rd_val;
wire         cntv_update_timer_regs_pulse;
reg  [63:0]  next_cntvcval_rd_data;
reg  [63:0]  cntvcval_rd_data;
reg   [1:0]  next_cntvctl_rd_data;
wire  [2:0]  cntvctl_rd_data;
reg   [1:0]  cntvctl_rd_data_1_0;
wire [31:0]  next_cntvtval_rd_val;
reg  [31:0]  cntvtval_rd_val;
wire [31:0]  cntvtval_rd_data;

wire         cntpl_cval_write_complete_pulse;
wire         cntpu_cval_write_complete_pulse;
wire         cntp_tval_write_complete_pulse;
wire         cntp_ctl_write_complete_pulse;
wire         next_preadycntbasen_phys;
wire         next_preadycntpl0basen_phys;

wire         cntvl_cval_write_complete_pulse;
wire         cntvu_cval_write_complete_pulse;
wire         cntv_tval_write_complete_pulse;
wire         cntv_ctl_write_complete_pulse;
wire         next_preadycntbasen_virt;
wire         next_preadycntpl0basen_virt;
wire         cntfrq_wsetup_cntbasen;  
wire         cntpl0acr_wsetup_cntbasen;
wire         cntpl_cval_write_cntbasen;
wire         next_preadycntbasen;
wire         cntpu_cval_write_cntbasen;
wire         cntp_tval_write_cntbasen;
wire         cntp_ctl_write_cntbasen;
wire         cntvl_cval_write_cntbasen;
wire         cntvu_cval_write_cntbasen;
wire         cntv_tval_write_cntbasen;
wire         cntv_ctl_write_cntbasen;
wire         next_preadycntpl0basen;
wire         cntfrq_rdaccess_enable_cntpl0basen;
wire         cntpl_cval_write_cntpl0basen;
wire         cntpu_cval_write_cntpl0basen;
wire         cntp_tval_write_cntpl0basen;
wire         cntp_ctl_write_cntpl0basen;
wire         cntvl_cval_write_cntpl0basen;
wire         cntvu_cval_write_cntpl0basen;
wire         cntv_tval_write_cntpl0basen;
wire         cntv_ctl_write_cntpl0basen;

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


gct_syncpulse u_gct_syncpulse_cntvoff_sync (
                    .clk     ( PCLK                    ),
                    .reset_n ( PRESETn                 ),
                    .data_i  ( cntvoff_sync            ),
                    .pulse_o ( cntvoff_sync_pulse      ),
                    .ack_o   (                 )
                    );
  
assign next_int_cntvoff       =  cntvoff_sync_pulse ? CNTVOFF     : int_cntvoff;
assign next_cntvoff_rd_data   =  cntvoff_sync_pulse ? int_cntvoff : cntvoff_rd_data;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      int_cntvoff      <= 64'h0000_0000_0000_0000;
      cntvoff_rd_data  <= 64'h0000_0000_0000_0000;
      int_cntacr  <= 6'h00;
    end
  else
    begin
      int_cntvoff      <= next_int_cntvoff;
      cntvoff_rd_data  <= next_cntvoff_rd_data;
      int_cntacr  <= CNTACR;
    end
      

assign pwdata_enabled_cntbasen = (PSELCNTBASEN & PWRITECNTBASEN) ?  PWDATACNTBASEN : 32'h0000_0000;

assign paddr_enabled_cntbasen  =  PSELCNTBASEN ? PADDRCNTBASEN : 10'b0000000000;

assign write_setup_cntbasen    =  PSELCNTBASEN & PWRITECNTBASEN & (~PENABLECNTBASEN);
assign write_enable_cntbasen   =  PSELCNTBASEN & PWRITECNTBASEN & PENABLECNTBASEN & PREADYCNTBASEN;

assign read_enable_cntbasen    =  PSELCNTBASEN & (~PWRITECNTBASEN) & (~PENABLECNTBASEN);

assign PSLVERRCNTBASEN         =  1'b0;

assign next_preadycntbasen       =  next_preadycntbasen_phys & next_preadycntbasen_virt;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    PREADYCNTBASEN <= 1'b1;
  else
    PREADYCNTBASEN <= next_preadycntbasen;


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


assign {RWPT, RWVT, RVOFF, RFRQ, RVCT, RPCT} = int_cntacr;

assign cntpct_access_enable_cntbasen     =  RPCT;
assign cntvct_access_enable_cntbasen     =  RVCT;
assign cntfrq_access_enable_cntbasen     =  RFRQ;
assign cntpl0acr_access_enable_cntbasen  =  TIMERFPL0REG;
assign cntvoff_access_enable_cntbasen    =  TIMERFVIREG & RVOFF;
assign cntp_star_access_enable_cntbasen  =  RWPT;
assign cntv_star_access_enable_cntbasen  =  TIMERFVIREG & RWVT;


assign cntfrq_wsetup_cntbasen      =  ( cntfrq_access_enable_cntbasen    & write_setup_cntbasen & cntfrq_select_cntbasen );
assign cntpl0acr_wsetup_cntbasen   =  ( cntpl0acr_access_enable_cntbasen & write_setup_cntbasen & cntpl0acr_select_cntbasen );
assign cntpl_cval_wsetup_cntbasen  =  ( cntp_star_access_enable_cntbasen & write_setup_cntbasen & cntpl_cval_select_cntbasen );
assign cntpu_cval_wsetup_cntbasen  =  ( cntp_star_access_enable_cntbasen & write_setup_cntbasen & cntpu_cval_select_cntbasen );
assign cntp_tval_wsetup_cntbasen   =  ( cntp_star_access_enable_cntbasen & write_setup_cntbasen & cntp_tval_select_cntbasen );
assign cntp_ctl_wsetup_cntbasen    =  ( cntp_star_access_enable_cntbasen & write_setup_cntbasen & cntp_ctl_select_cntbasen );
assign cntvl_cval_wsetup_cntbasen  =  ( cntv_star_access_enable_cntbasen & write_setup_cntbasen & cntvl_cval_select_cntbasen );
assign cntvu_cval_wsetup_cntbasen  =  ( cntv_star_access_enable_cntbasen & write_setup_cntbasen & cntvu_cval_select_cntbasen );
assign cntv_tval_wsetup_cntbasen   =  ( cntv_star_access_enable_cntbasen & write_setup_cntbasen & cntv_tval_select_cntbasen );
assign cntv_ctl_wsetup_cntbasen    =  ( cntv_star_access_enable_cntbasen & write_setup_cntbasen & cntv_ctl_select_cntbasen );

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


assign pwdata_enabled_cntpl0basen   = (PSELCNTPL0BASEN & PWRITECNTPL0BASEN) ?  PWDATACNTPL0BASEN : 32'h0000_0000;

assign paddr_enabled_cntpl0basen    =  PSELCNTPL0BASEN ? PADDRCNTPL0BASEN : 10'b0000000000;

assign write_setup_cntpl0basen      =  PSELCNTPL0BASEN & (~PENABLECNTPL0BASEN) & PWRITECNTPL0BASEN;
assign write_enable_cntpl0basen     =  PSELCNTPL0BASEN & PENABLECNTPL0BASEN & PWRITECNTPL0BASEN & PREADYCNTPL0BASEN;

assign read_enable_cntpl0basen      =  (PSELCNTPL0BASEN & (~PWRITECNTPL0BASEN) & (~PENABLECNTPL0BASEN)) | (PSELCNTPL0BASEN & (~PWRITECNTPL0BASEN) & PENABLECNTPL0BASEN & (~PREADYCNTPL0BASEN));

assign PSLVERRCNTPL0BASEN           =  1'b0;

assign next_preadycntpl0basen       =  next_preadycntpl0basen_phys & next_preadycntpl0basen_virt;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    PREADYCNTPL0BASEN <= 1'b1;
  else
    PREADYCNTPL0BASEN <= next_preadycntpl0basen;


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


assign cntpl_cval_wsetup_cntpl0basen  =  ( cntp_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntpl_cval_select_cntpl0basen );
assign cntpu_cval_wsetup_cntpl0basen  =  ( cntp_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntpu_cval_select_cntpl0basen );
assign cntp_tval_wsetup_cntpl0basen   =  ( cntp_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntp_tval_select_cntpl0basen );
assign cntp_ctl_wsetup_cntpl0basen    =  ( cntp_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntp_ctl_select_cntpl0basen );
assign cntvl_cval_wsetup_cntpl0basen  =  ( cntv_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntvl_cval_select_cntpl0basen );
assign cntvu_cval_wsetup_cntpl0basen  =  ( cntv_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntvu_cval_select_cntpl0basen );
assign cntv_tval_wsetup_cntpl0basen   =  ( cntv_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntv_tval_select_cntpl0basen );
assign cntv_ctl_wsetup_cntpl0basen    =  ( cntv_star_access_enable_cntpl0basen & write_setup_cntpl0basen & cntv_ctl_select_cntpl0basen );

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




gct_syncpulse u_gct_syncpulse_cntpl_cval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntpl_cval_write_complete       ),
                    .pulse_o ( cntpl_cval_write_complete_pulse ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntpu_cval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntpu_cval_write_complete       ),
                    .pulse_o ( cntpu_cval_write_complete_pulse ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntp_tval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntp_tval_write_complete        ),
                    .pulse_o ( cntp_tval_write_complete_pulse  ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntp_ctl_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntp_ctl_write_complete         ),
                    .pulse_o ( cntp_ctl_write_complete_pulse   ),
                    .ack_o   (                         )
                    );

gtimer_asyncapb_regwrite_logic u_gtimer_asyncapb_regwrite_logic_physical (
                    .PCLK                                ( PCLK                                 ),  
                    .PRESETn                             ( PRESETn                              ),  
                    .pwdata_enabled_cntbasen             ( pwdata_enabled_cntbasen              ),  
                    .pwdata_enabled_cntpl0basen          ( pwdata_enabled_cntpl0basen           ),  

                    .cntl_cval_wsetup_cntbasen           ( cntpl_cval_wsetup_cntbasen           ),  
                    .cntl_cval_wsetup_cntpl0basen        ( cntpl_cval_wsetup_cntpl0basen        ),  
                    .cntl_cval_write_complete_pulse      ( cntpl_cval_write_complete_pulse      ),  
                    .cntl_cval_latch_wdata               ( cntpl_cval_latch_wdata               ),  
                    .cntl_cval_write_in_progress         ( cntpl_cval_write_in_progress         ),  
                    .cntl_cval_write_in_progress_toggle  ( cntpl_cval_write_in_progress_toggle  ),  
                    .cntl_cval_write_val                 ( cntpl_cval_write_val                 ),  

                    .cntu_cval_wsetup_cntbasen           ( cntpu_cval_wsetup_cntbasen           ),  
                    .cntu_cval_wsetup_cntpl0basen        ( cntpu_cval_wsetup_cntpl0basen        ),  
                    .cntu_cval_write_complete_pulse      ( cntpu_cval_write_complete_pulse      ),  
                    .cntu_cval_latch_wdata               ( cntpu_cval_latch_wdata               ),  
                    .cntu_cval_write_in_progress         ( cntpu_cval_write_in_progress         ),  
                    .cntu_cval_write_in_progress_toggle  ( cntpu_cval_write_in_progress_toggle  ),  
                    .cntu_cval_write_val                 ( cntpu_cval_write_val                 ),  

                    .cnt_tval_wsetup_cntbasen            ( cntp_tval_wsetup_cntbasen            ),  
                    .cnt_tval_wsetup_cntpl0basen         ( cntp_tval_wsetup_cntpl0basen         ),  
                    .cnt_tval_write_complete_pulse       ( cntp_tval_write_complete_pulse       ),  
                    .cnt_tval_latch_wdata                ( cntp_tval_latch_wdata                ),  
                    .cnt_tval_write_in_progress          ( cntp_tval_write_in_progress          ),  
                    .cnt_tval_write_in_progress_toggle   ( cntp_tval_write_in_progress_toggle   ),  
                    .cnt_tval_write_val                  ( cntp_tval_write_val                  ),  

                    .cnt_ctl_wsetup_cntbasen             ( cntp_ctl_wsetup_cntbasen             ),  
                    .cnt_ctl_wsetup_cntpl0basen          ( cntp_ctl_wsetup_cntpl0basen          ),  
                    .cnt_ctl_write_complete_pulse        ( cntp_ctl_write_complete_pulse        ),  
                    .cnt_ctl_latch_wdata                 ( cntp_ctl_latch_wdata                 ),  
                    .cnt_ctl_write_in_progress           ( cntp_ctl_write_in_progress           ),  
                    .cnt_ctl_write_in_progress_toggle    ( cntp_ctl_write_in_progress_toggle    ),  
                    .cnt_ctl_write_val                   ( cntp_ctl_write_val                   ),  

                    .next_preadycntbasen                 ( next_preadycntbasen_phys             ),  
                    .next_preadycntpl0basen              ( next_preadycntpl0basen_phys          )   
                    );



gct_syncpulse u_gct_syncpulse_cntvl_cval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntvl_cval_write_complete       ),
                    .pulse_o ( cntvl_cval_write_complete_pulse ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntvu_cval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntvu_cval_write_complete       ),
                    .pulse_o ( cntvu_cval_write_complete_pulse ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntv_tval_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntv_tval_write_complete        ),
                    .pulse_o ( cntv_tval_write_complete_pulse  ),
                    .ack_o   (                         )
                    );

gct_syncpulse u_gct_syncpulse_cntv_ctl_write_complete (
                    .clk     ( PCLK                            ),
                    .reset_n ( PRESETn                         ),
                    .data_i  ( cntv_ctl_write_complete         ),
                    .pulse_o ( cntv_ctl_write_complete_pulse   ),
                    .ack_o   (                         )
                    );

gtimer_asyncapb_regwrite_logic u_gtimer_asyncapb_regwrite_logic_virtual (
                    .PCLK                                ( PCLK                                 ),  
                    .PRESETn                             ( PRESETn                              ),  
                    .pwdata_enabled_cntbasen             ( pwdata_enabled_cntbasen              ),  
                    .pwdata_enabled_cntpl0basen          ( pwdata_enabled_cntpl0basen           ),  

                    .cntl_cval_wsetup_cntbasen           ( cntvl_cval_wsetup_cntbasen           ),  
                    .cntl_cval_wsetup_cntpl0basen        ( cntvl_cval_wsetup_cntpl0basen        ),  
                    .cntl_cval_write_complete_pulse      ( cntvl_cval_write_complete_pulse      ),  
                    .cntl_cval_latch_wdata               ( cntvl_cval_latch_wdata               ),  
                    .cntl_cval_write_in_progress         ( cntvl_cval_write_in_progress         ),  
                    .cntl_cval_write_in_progress_toggle  ( cntvl_cval_write_in_progress_toggle  ),  
                    .cntl_cval_write_val                 ( cntvl_cval_write_val                 ),  

                    .cntu_cval_wsetup_cntbasen           ( cntvu_cval_wsetup_cntbasen           ),  
                    .cntu_cval_wsetup_cntpl0basen        ( cntvu_cval_wsetup_cntpl0basen        ),  
                    .cntu_cval_write_complete_pulse      ( cntvu_cval_write_complete_pulse      ),  
                    .cntu_cval_latch_wdata               ( cntvu_cval_latch_wdata               ),  
                    .cntu_cval_write_in_progress         ( cntvu_cval_write_in_progress         ),  
                    .cntu_cval_write_in_progress_toggle  ( cntvu_cval_write_in_progress_toggle  ),  
                    .cntu_cval_write_val                 ( cntvu_cval_write_val                 ),  

                    .cnt_tval_wsetup_cntbasen            ( cntv_tval_wsetup_cntbasen            ),  
                    .cnt_tval_wsetup_cntpl0basen         ( cntv_tval_wsetup_cntpl0basen         ),  
                    .cnt_tval_write_complete_pulse       ( cntv_tval_write_complete_pulse       ),  
                    .cnt_tval_latch_wdata                ( cntv_tval_latch_wdata                ),  
                    .cnt_tval_write_in_progress          ( cntv_tval_write_in_progress          ),  
                    .cnt_tval_write_in_progress_toggle   ( cntv_tval_write_in_progress_toggle   ),  
                    .cnt_tval_write_val                  ( cntv_tval_write_val                  ),  

                    .cnt_ctl_wsetup_cntbasen             ( cntv_ctl_wsetup_cntbasen             ),  
                    .cnt_ctl_wsetup_cntpl0basen          ( cntv_ctl_wsetup_cntpl0basen          ),  
                    .cnt_ctl_write_complete_pulse        ( cntv_ctl_write_complete_pulse        ),  
                    .cnt_ctl_latch_wdata                 ( cntv_ctl_latch_wdata                 ),  
                    .cnt_ctl_write_in_progress           ( cntv_ctl_write_in_progress           ),  
                    .cnt_ctl_write_in_progress_toggle    ( cntv_ctl_write_in_progress_toggle    ),  
                    .cnt_ctl_write_val                   ( cntv_ctl_write_val                   ),  

                    .next_preadycntbasen                 ( next_preadycntbasen_virt             ),  
                    .next_preadycntpl0basen              ( next_preadycntpl0basen_virt          )   
                    );

gct_syncpulse u_gct_syncpulse_cntp_update_timer (
                    .clk     ( PCLK                         ),
                    .reset_n ( PRESETn                      ),
                    .data_i  ( cntp_update_timer_regs       ),
                    .pulse_o ( cntp_update_timer_regs_pulse ),
                    .ack_o   (                      )
                    );



  wire [63:0] cntpct_rd_data_glitch_gated;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(64) 
  )
  u_cntpct_rd_data_glitch_gated (         
      .async_in (cntpct_rd_data),
      .async_out(cntpct_rd_data_glitch_gated),
      .input_valid(cntp_update_timer_regs_pulse)        
  );
  assign next_cntpct_rd_val = cntp_update_timer_regs_pulse ? cntpct_rd_data_glitch_gated : cntpct_rd_val;
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    cntpct_rd_val  <=  64'h0000_0000_0000_0000;
  else
    cntpct_rd_val  <=  next_cntpct_rd_val;
    


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      latched_cntpu_cval_latch_wdata  <=  1'b0;
      latched_cntpl_cval_latch_wdata  <=  1'b0;
      latched_cntp_ctl_latch_wdata    <=  1'b0;
    end
  else
    begin
      latched_cntpu_cval_latch_wdata  <=  cntpu_cval_latch_wdata;
      latched_cntpl_cval_latch_wdata  <=  cntpl_cval_latch_wdata;
      latched_cntp_ctl_latch_wdata    <=  cntp_ctl_latch_wdata;
    end


    
    wire [63:0] cntpcval_rd_glitch_gated;     
     
    gtimer_counter_glitch_gate #( 
    .WIDTH(64) 
    )
    u_cntpcval_rd_glitch_gated (         
        .async_in (cntpcval_rd),
        .async_out(cntpcval_rd_glitch_gated),
        .input_valid(cntp_update_timer_regs_pulse)        
    );
always @*
  case ({cntpu_cval_write_in_progress, cntpl_cval_write_in_progress, cntp_update_timer_regs_pulse,
         latched_cntpu_cval_latch_wdata, latched_cntpl_cval_latch_wdata})
    5'b00000 :  next_cntpcval_rd_data  =  cntpcval_rd_data;
    5'b00001 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b00010 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b00011 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    5'b00100 :  next_cntpcval_rd_data  =  cntpcval_rd_glitch_gated;
    5'b00101 :  next_cntpcval_rd_data  = {cntpcval_rd_glitch_gated[63:32],      cntpl_cval_write_val};
    5'b00110 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_glitch_gated[31:0]};
    5'b00111 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    
    5'b01000 :  next_cntpcval_rd_data  = cntpcval_rd_data;
    5'b01001 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b01010 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b01011 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    5'b01100 :  next_cntpcval_rd_data  = {cntpcval_rd_glitch_gated[63:32],      cntpcval_rd_data[31:0]};
    5'b01101 :  next_cntpcval_rd_data  = {cntpcval_rd_glitch_gated[63:32],      cntpl_cval_write_val};
    5'b01110 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b01111 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};  
    
    5'b10000 :  next_cntpcval_rd_data  =  cntpcval_rd_data;
    5'b10001 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b10010 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b10011 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    5'b10100 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpcval_rd_glitch_gated[31:0]};
    5'b10101 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b10110 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_glitch_gated[31:0]};
    5'b10111 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    
    5'b11000 :  next_cntpcval_rd_data  =  cntpcval_rd_data;
    5'b11001 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b11010 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b11011 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
    5'b11100 :  next_cntpcval_rd_data  =  cntpcval_rd_data;
    5'b11101 :  next_cntpcval_rd_data  = {cntpcval_rd_data[63:32], cntpl_cval_write_val};
    5'b11110 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpcval_rd_data[31:0]};
    5'b11111 :  next_cntpcval_rd_data  = {cntpu_cval_write_val,    cntpl_cval_write_val};
  default :  next_cntpcval_rd_data  = cntpcval_rd_data;
  endcase

  
  reg [1:0] cntpctl_rd_data_1_0;
  
  wire [1:0] cntpctl_rd_glitch_gated;
  wire       cntpctl_rd_glitch_gated_gate_en;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(2) 
  )
  u_cntpctl_rd_glitch_gated (         
      .async_in (cntpctl_rd[1:0]),
      .async_out(cntpctl_rd_glitch_gated),
      .input_valid(cntpctl_rd_glitch_gated_gate_en)        
  );
  assign cntpctl_rd_glitch_gated_gate_en = {cntp_ctl_write_in_progress, cntp_update_timer_regs_pulse, latched_cntp_ctl_latch_wdata} == 3'b010;
always @*
  case ({cntp_ctl_write_in_progress, cntp_update_timer_regs_pulse, latched_cntp_ctl_latch_wdata})
    3'b000 : next_cntpctl_rd_data  = { cntpctl_rd_data[1:0]};
    3'b001 : next_cntpctl_rd_data  = { cntp_ctl_write_val};
    3'b010 : next_cntpctl_rd_data  =   cntpctl_rd_glitch_gated[1:0];
    3'b011 : next_cntpctl_rd_data  = { cntp_ctl_write_val};
    3'b100 : next_cntpctl_rd_data  = { cntpctl_rd_data[1:0]};
    3'b101 : next_cntpctl_rd_data  = { cntp_ctl_write_val};
    3'b110 : next_cntpctl_rd_data  = { cntpctl_rd_data[1:0]};
    3'b111 : next_cntpctl_rd_data  = { cntp_ctl_write_val};
  default :  next_cntpctl_rd_data  = { cntpctl_rd_data[1:0]};
  endcase


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntpcval_rd_data  <=  64'h0000_0000_0000_0000;
      cntpctl_rd_data_1_0 <=  2'b00;      
    end
  else
    begin
      cntpcval_rd_data  <=  next_cntpcval_rd_data;
      cntpctl_rd_data_1_0 <=  next_cntpctl_rd_data;      
    end
    
    gct_synchronizer u_cntpctl_rd_data_2 (
            .clk     (PCLK),
            .reset_n (PRESETn),
            .data_i  (cntpctl_rd[2]),         
            .data_o  (cntpctl_rd_data[2])
        );
    
    
    assign cntpctl_rd_data[1:0] = {cntpctl_rd_data_1_0};



  wire [31:0] cntptval_rd_glitch_gated;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(32) 
  )
  u_cntptval_rd_glitch_gated (         
      .async_in (cntptval_rd),
      .async_out(cntptval_rd_glitch_gated),
      .input_valid(cntp_update_timer_regs_pulse)        
  );
assign next_cntptval_rd_val = cntp_update_timer_regs_pulse ? cntptval_rd_glitch_gated : cntptval_rd_val;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    cntptval_rd_val <= 32'h0000_0000;
  else
    cntptval_rd_val <= next_cntptval_rd_val;

assign cntptval_rd_data = cntp_tval_write_in_progress ? cntp_tval_write_val : cntptval_rd_val;



gct_syncpulse u_gct_syncpulse_cntv_update_timer (
                    .clk     ( PCLK                         ),
                    .reset_n ( PRESETn                      ),
                    .data_i  ( cntv_update_timer_regs       ),
                    .pulse_o ( cntv_update_timer_regs_pulse ),
                    .ack_o   (                      )
                    );


  wire [63:0] cntvct_rd_data_glitch_gated;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(64) 
  )
  u_cntvct_rd_data_glitch_gated (         
      .async_in (cntvct_rd_data),
      .async_out(cntvct_rd_data_glitch_gated),
      .input_valid(cntv_update_timer_regs_pulse)        
  );
                    
assign next_cntvct_rd_val  =  cntv_update_timer_regs_pulse ? cntvct_rd_data_glitch_gated : cntvct_rd_val;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    cntvct_rd_val  <=  64'h0000_0000_0000_0000;
  else
    cntvct_rd_val  <=  next_cntvct_rd_val;



always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      latched_cntvu_cval_latch_wdata  <=  1'b0;
      latched_cntvl_cval_latch_wdata  <=  1'b0;
      latched_cntv_ctl_latch_wdata    <=  1'b0;
    end
  else
    begin
      latched_cntvu_cval_latch_wdata  <=  cntvu_cval_latch_wdata;
      latched_cntvl_cval_latch_wdata  <=  cntvl_cval_latch_wdata;
      latched_cntv_ctl_latch_wdata    <=  cntv_ctl_latch_wdata;
    end


    wire [63:0] cntvcval_rd_glitch_gated;
     
    gtimer_counter_glitch_gate #( 
    .WIDTH(64) 
    )
    u_cntvcval_rd_glitch_gated (         
        .async_in(cntvcval_rd),
        .async_out(cntvcval_rd_glitch_gated),
        .input_valid(cntv_update_timer_regs_pulse)        
    );
      
always @*
  case ({cntvu_cval_write_in_progress, cntvl_cval_write_in_progress, cntv_update_timer_regs_pulse,
         latched_cntvu_cval_latch_wdata, latched_cntvl_cval_latch_wdata})
    5'b00000 :  next_cntvcval_rd_data  =  cntvcval_rd_data;
    5'b00001 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b00010 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b00011 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    5'b00100 :  next_cntvcval_rd_data  =  cntvcval_rd_glitch_gated;
    5'b00101 :  next_cntvcval_rd_data  = {cntvcval_rd_glitch_gated[63:32],      cntvl_cval_write_val};
    5'b00110 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,                 cntvcval_rd_glitch_gated[31:0]};
    5'b00111 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    
    5'b01000 :  next_cntvcval_rd_data  = cntvcval_rd_data;
    5'b01001 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b01010 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b01011 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    5'b01100 :  next_cntvcval_rd_data  = {cntvcval_rd_glitch_gated[63:32],      cntvcval_rd_data[31:0]};
    5'b01101 :  next_cntvcval_rd_data  = {cntvcval_rd_glitch_gated[63:32],      cntvl_cval_write_val};
    5'b01110 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b01111 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};  
    
    5'b10000 :  next_cntvcval_rd_data  =  cntvcval_rd_data;
    5'b10001 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b10010 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b10011 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    5'b10100 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvcval_rd_glitch_gated[31:0]};
    5'b10101 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b10110 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_glitch_gated[31:0]};
    5'b10111 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    
    5'b11000 :  next_cntvcval_rd_data  =  cntvcval_rd_data;
    5'b11001 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b11010 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b11011 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
    5'b11100 :  next_cntvcval_rd_data  =  cntvcval_rd_data;
    5'b11101 :  next_cntvcval_rd_data  = {cntvcval_rd_data[63:32], cntvl_cval_write_val};
    5'b11110 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvcval_rd_data[31:0]};
    5'b11111 :  next_cntvcval_rd_data  = {cntvu_cval_write_val,    cntvl_cval_write_val};
  default :  next_cntvcval_rd_data  = cntvcval_rd_data;
  endcase



  wire [1:0] cntvctl_rd_0_1_glitch_gated;
  wire cntvctl_rd_0_1_glitch_gated_en;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(2) 
  )
  u_cntvctl_rd_0_1_glitch_gated (         
      .async_in (cntvctl_rd[1:0]),
      .async_out(cntvctl_rd_0_1_glitch_gated),
      .input_valid(cntvctl_rd_0_1_glitch_gated_en)        
  );  
  assign cntvctl_rd_0_1_glitch_gated_en = {cntv_ctl_write_in_progress, cntv_update_timer_regs_pulse, latched_cntv_ctl_latch_wdata} == 3'b010;
  
always @*
  case ({cntv_ctl_write_in_progress, cntv_update_timer_regs_pulse, latched_cntv_ctl_latch_wdata})
    3'b000 : next_cntvctl_rd_data[1:0]  = { cntvctl_rd_data[1:0]};
    3'b001 : next_cntvctl_rd_data[1:0]  = { cntv_ctl_write_val};
    3'b010 : next_cntvctl_rd_data[1:0]  =  cntvctl_rd_0_1_glitch_gated;
    3'b011 : next_cntvctl_rd_data[1:0]  = { cntv_ctl_write_val};
    3'b100 : next_cntvctl_rd_data[1:0]  = { cntvctl_rd_data[1:0]};
    3'b101 : next_cntvctl_rd_data[1:0]  = { cntv_ctl_write_val};
    3'b110 : next_cntvctl_rd_data[1:0]  = { cntvctl_rd_data[1:0]};
    3'b111 : next_cntvctl_rd_data[1:0]  = { cntv_ctl_write_val};
  default :  next_cntvctl_rd_data[1:0]  = { cntvctl_rd_data[1:0]};
  endcase
 
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntvcval_rd_data  <=  64'h0000_0000_0000_0000;
      cntvctl_rd_data_1_0  <=  2'b00;      
    end
  else
    begin
      cntvcval_rd_data    <=  next_cntvcval_rd_data;
      cntvctl_rd_data_1_0 <=  next_cntvctl_rd_data;      
    end
    
    gct_synchronizer u_cntvctl_rd_data_2 (
            .clk     (PCLK),
            .reset_n (PRESETn),
            .data_i  (cntvctl_rd[2]),         
            .data_o  (cntvctl_rd_data[2])
        );
    
   assign cntvctl_rd_data[1:0] = {cntvctl_rd_data_1_0};

wire [31:0] cntvtval_rd_glitch_gated;
  
  gtimer_counter_glitch_gate #( 
  .WIDTH(32) 
  )
  u_cntvtval_rd_glitch_gated (         
      .async_in (cntvtval_rd),
      .async_out(cntvtval_rd_glitch_gated),
      .input_valid(cntv_update_timer_regs_pulse)        
  );
assign next_cntvtval_rd_val = cntv_update_timer_regs_pulse ? cntvtval_rd_glitch_gated : cntvtval_rd_val;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    cntvtval_rd_val <= 32'h0000_0000;
  else
    cntvtval_rd_val <= next_cntvtval_rd_val;

assign cntvtval_rd_data = cntv_tval_write_in_progress ? cntv_tval_write_val : cntvtval_rd_val;



always @*
  case ({cntlpct_read_cntbasen,    cntupct_read_cntbasen,    cntlvct_read_cntbasen,   cntuvct_read_cntbasen,
         cntfrq_read_cntbasen,     cntpl0acr_read_cntbasen,  cntlvoff_read_cntbasen,  cntuvoff_read_cntbasen,
         cntpl_cval_read_cntbasen, cntpu_cval_read_cntbasen, cntp_tval_read_cntbasen, cntp_ctl_read_cntbasen,
         cntvl_cval_read_cntbasen, cntvu_cval_read_cntbasen, cntv_tval_read_cntbasen, cntv_ctl_read_cntbasen,
         cntpidr4_read_cntbasen,
         cntpidr0_read_cntbasen,   cntpidr1_read_cntbasen,   cntpidr2_read_cntbasen,  cntpidr3_read_cntbasen,
         cntcidr0_read_cntbasen,   cntcidr1_read_cntbasen,   cntcidr2_read_cntbasen,  cntcidr3_read_cntbasen})
    25'h100_0000 : next_prdata_cntbasen = cntpct_rd_val[31:0];
    25'h080_0000 : next_prdata_cntbasen = cntpct_rd_val[63:32];
    25'h040_0000 : next_prdata_cntbasen = cntvct_rd_val[31:0];
    25'h020_0000 : next_prdata_cntbasen = cntvct_rd_val[63:32];
    25'h010_0000 : next_prdata_cntbasen = cntfrq;
    25'h008_0000 : next_prdata_cntbasen = {22'h00_0000, cntpl0acr};
    25'h004_0000 : next_prdata_cntbasen = cntvoff_rd_data[31:0];
    25'h002_0000 : next_prdata_cntbasen = cntvoff_rd_data[63:32];
    25'h001_0000 : next_prdata_cntbasen = cntpcval_rd_data[31:0];
    25'h000_8000 : next_prdata_cntbasen = cntpcval_rd_data[63:32];
    25'h000_4000 : next_prdata_cntbasen = cntptval_rd_data;
    25'h000_2000 : next_prdata_cntbasen = {29'h000_0000, cntpctl_rd_data};
    25'h000_1000 : next_prdata_cntbasen = cntvcval_rd_data[31:0];
    25'h000_0800 : next_prdata_cntbasen = cntvcval_rd_data[63:32];
    25'h000_0400 : next_prdata_cntbasen = cntvtval_rd_data;
    25'h000_0200 : next_prdata_cntbasen = {29'h000_0000, cntvctl_rd_data};    

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
  case ({cntlpct_read_cntpl0basen,    cntupct_read_cntpl0basen,    cntlvct_read_cntpl0basen,   cntuvct_read_cntpl0basen,
         cntfrq_read_cntpl0basen,
         cntpl_cval_read_cntpl0basen, cntpu_cval_read_cntpl0basen, cntp_tval_read_cntpl0basen, cntp_ctl_read_cntpl0basen,
         cntvl_cval_read_cntpl0basen, cntvu_cval_read_cntpl0basen, cntv_tval_read_cntpl0basen, cntv_ctl_read_cntpl0basen,
         cntpidr4_read_cntpl0basen,
         cntpidr0_read_cntpl0basen,   cntpidr1_read_cntpl0basen,   cntpidr2_read_cntpl0basen,  cntpidr3_read_cntpl0basen,
         cntcidr0_read_cntpl0basen,   cntcidr1_read_cntpl0basen,   cntcidr2_read_cntpl0basen,  cntcidr3_read_cntpl0basen})
    22'h20_0000 : next_prdata_cntpl0basen = cntpct_rd_val[31:0];
    22'h10_0000 : next_prdata_cntpl0basen = cntpct_rd_val[63:32];
    22'h08_0000 : next_prdata_cntpl0basen = cntvct_rd_val[31:0];
    22'h04_0000 : next_prdata_cntpl0basen = cntvct_rd_val[63:32];
    22'h02_0000 : next_prdata_cntpl0basen = cntfrq;
    22'h01_0000 : next_prdata_cntpl0basen = cntpcval_rd_data[31:0];
    22'h00_8000 : next_prdata_cntpl0basen = cntpcval_rd_data[63:32];
    22'h00_4000 : next_prdata_cntpl0basen = cntptval_rd_data;
    22'h00_2000 : next_prdata_cntpl0basen = {29'h000_0000, cntpctl_rd_data};
    22'h00_1000 : next_prdata_cntpl0basen = cntvcval_rd_data[31:0];
    22'h00_0800 : next_prdata_cntpl0basen = cntvcval_rd_data[63:32];
    22'h00_0400 : next_prdata_cntpl0basen = cntvtval_rd_data;
    22'h00_0200 : next_prdata_cntpl0basen = {29'h000_0000, cntvctl_rd_data};
    
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


`undef CNTLPCT_ADDR
`undef CNTUPCT_ADDR
`undef CNTLVCT_ADDR
`undef CNTUVCT_ADDR
`undef CNTFRQ_ADDR
`undef CNTPL0ACR_ADDR
`undef CNTLVOFF_ADDR
`undef CNTUVOFF_ADDR
`undef CNTPL_CVAL_ADDR
`undef CNTPU_CVAL_ADDR
`undef CNTP_TVAL_ADDR
`undef CNTP_CTL_ADDR
`undef CNTVL_CVAL_ADDR
`undef CNTVU_CVAL_ADDR
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
`undef GTIMER_CNTCIDR


endmodule
