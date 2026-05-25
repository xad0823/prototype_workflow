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


module gtimer_control_apbif #(
  parameter TIMER0_FI        = 1'b1,
  parameter TIMER0_FVI       = 1'b1,
  parameter TIMER0_FPL0      = 1'b1,
  parameter TIMER0_CFGBL_ACC = 1'b1,
  parameter TIMER0_NONSECURE = 1'b0,
  parameter TIMER1_FI        = 1'b1,
  parameter TIMER1_FVI       = 1'b1,
  parameter TIMER1_FPL0      = 1'b1,
  parameter TIMER1_CFGBL_ACC = 1'b1,
  parameter TIMER1_NONSECURE = 1'b0,
  parameter TIMER2_FI        = 1'b1,
  parameter TIMER2_FVI       = 1'b1,
  parameter TIMER2_FPL0      = 1'b1,
  parameter TIMER2_CFGBL_ACC = 1'b1,
  parameter TIMER2_NONSECURE = 1'b0,
  parameter TIMER3_FI        = 1'b1,
  parameter TIMER3_FVI       = 1'b1,
  parameter TIMER3_FPL0      = 1'b1,
  parameter TIMER3_CFGBL_ACC = 1'b1,
  parameter TIMER3_NONSECURE = 1'b0,
  parameter TIMER4_FI        = 1'b1,
  parameter TIMER4_FVI       = 1'b1,
  parameter TIMER4_FPL0      = 1'b1,
  parameter TIMER4_CFGBL_ACC = 1'b1,
  parameter TIMER4_NONSECURE = 1'b0,
  parameter TIMER5_FI        = 1'b1,
  parameter TIMER5_FVI       = 1'b1,
  parameter TIMER5_FPL0      = 1'b1,
  parameter TIMER5_CFGBL_ACC = 1'b1,
  parameter TIMER5_NONSECURE = 1'b0,
  parameter TIMER6_FI        = 1'b1,
  parameter TIMER6_FVI       = 1'b1,
  parameter TIMER6_FPL0      = 1'b1,
  parameter TIMER6_CFGBL_ACC = 1'b1,
  parameter TIMER6_NONSECURE = 1'b0,
  parameter TIMER7_FI        = 1'b1,
  parameter TIMER7_FVI       = 1'b1,
  parameter TIMER7_FPL0      = 1'b1,
  parameter TIMER7_CFGBL_ACC = 1'b1,
  parameter TIMER7_NONSECURE = 1'b0
  )(
  input  wire        PCLK,              
  input  wire        PRESETn,           
  
  input  wire [11:2] PADDR,             
  input  wire        PSEL,              
  input  wire        PENABLE,           
  input  wire        PWRITE,            
  input  wire  [2:0] PPROT,             
  input  wire  [3:0] PSTRB,             
  input  wire [31:0] PWDATA,            
  
  output wire        PREADY,            
  output reg  [31:0] PRDATA,            
  output wire        PSLVERR,           
  
  input  wire  [3:0] revision,          
  
  output wire [31:0] cnttidr,            
  
  output reg   [5:0] CNTACR0,           
  output wire [63:0] CNTVOFF0,          

  output reg   [5:0] CNTACR1,           
  output wire [63:0] CNTVOFF1,          
  
  output reg   [5:0] CNTACR2,           
  output wire [63:0] CNTVOFF2,          
  
  output reg   [5:0] CNTACR3,           
  output wire [63:0] CNTVOFF3,          
  
  output reg   [5:0] CNTACR4,           
  output wire [63:0] CNTVOFF4,          
  
  output reg   [5:0] CNTACR5,           
  output wire [63:0] CNTVOFF5,          
  
  output reg   [5:0] CNTACR6,           
  output wire [63:0] CNTVOFF6,          
  
  output reg   [5:0] CNTACR7,           
  output wire [63:0] CNTVOFF7           
);




`define CNTFRQ_ADDR      10'b0000000000
`define CNTNSAR_ADDR     10'b0000000001

`define CNTACR0_ADDR     10'b0000010000
`define CNTACR1_ADDR     10'b0000010001
`define CNTACR2_ADDR     10'b0000010010
`define CNTACR3_ADDR     10'b0000010011
`define CNTACR4_ADDR     10'b0000010100
`define CNTACR5_ADDR     10'b0000010101
`define CNTACR6_ADDR     10'b0000010110
`define CNTACR7_ADDR     10'b0000010111

`define CNTVLOFF0_ADDR   10'b0000100000
`define CNTVUOFF0_ADDR   10'b0000100001
`define CNTVLOFF1_ADDR   10'b0000100010
`define CNTVUOFF1_ADDR   10'b0000100011
`define CNTVLOFF2_ADDR   10'b0000100100
`define CNTVUOFF2_ADDR   10'b0000100101
`define CNTVLOFF3_ADDR   10'b0000100110
`define CNTVUOFF3_ADDR   10'b0000100111

`define CNTVLOFF4_ADDR   10'b0000101000
`define CNTVUOFF4_ADDR   10'b0000101001
`define CNTVLOFF5_ADDR   10'b0000101010
`define CNTVUOFF5_ADDR   10'b0000101011
`define CNTVLOFF6_ADDR   10'b0000101100
`define CNTVUOFF6_ADDR   10'b0000101101
`define CNTVLOFF7_ADDR   10'b0000101110
`define CNTVUOFF7_ADDR   10'b0000101111

`define CNTTIDR_ADDR      10'b0000000010

`define CNTPIDR4_ADDR    10'b1111110100

`define CNTPIDR0_ADDR    10'b1111111000
`define CNTPIDR1_ADDR    10'b1111111001
`define CNTPIDR2_ADDR    10'b1111111010
`define CNTPIDR3_ADDR    10'b1111111011

`define CNTCIDR0_ADDR    10'b1111111100
`define CNTCIDR1_ADDR    10'b1111111101
`define CNTCIDR2_ADDR    10'b1111111110
`define CNTCIDR3_ADDR    10'b1111111111



`define GTIMER_CONTROL_PART_0             8'b1010_0000
`define GTIMER_CONTROL_PART_1             4'b0000
`define GTIMER_CONTROL_DES_0              4'b1011
`define GTIMER_CONTROL_DES_1              3'b011
`define GTIMER_CONTROL_DES_2              4'b0100
`define GTIMER_CONTROL_SIZE               4'b0000
`define GTIMER_CONTROL_JEDEC              1'b1
`define GTIMER_CONTROL_CMOD               4'b0000
`define GTIMER_CONTROL_REVAND             4'b0000

`define GTIMER_CONTROL_COMPID       32'hB105F00D



wire  [4:0] timer0_pars;
wire  [4:0] timer1_pars;
wire  [4:0] timer2_pars;
wire  [4:0] timer3_pars;
wire  [4:0] timer4_pars;
wire  [4:0] timer5_pars;
wire  [4:0] timer6_pars;
wire  [4:0] timer7_pars;

wire  [7:0] timer_fixed_sec_vals;
wire  [7:0] timer_cfgbl_sec;

wire [31:0] pwdata_enabled;
wire [11:2] paddr_enabled;
wire  [3:0] write_enable;
wire        read_enable;
wire        secure_access;

reg  [31:0] cntfrq;
reg   [7:0] cntnsar;
reg  [31:0] cntvloff0;
reg  [31:0] cntvuoff0;
reg  [31:0] cntvloff1;
reg  [31:0] cntvuoff1;
reg  [31:0] cntvloff2;
reg  [31:0] cntvuoff2;
reg  [31:0] cntvloff3;
reg  [31:0] cntvuoff3;
reg  [31:0] cntvloff4;
reg  [31:0] cntvuoff4;
reg  [31:0] cntvloff5;
reg  [31:0] cntvuoff5;
reg  [31:0] cntvloff6;
reg  [31:0] cntvuoff6;
reg  [31:0] cntvloff7;
reg  [31:0] cntvuoff7;


reg  [35:0] register_select;

wire        cntfrq_select;
wire        cntnsar_select;
wire        cnttidr_select;
wire        cntacr0_select;
wire        cntacr1_select;
wire        cntacr2_select;
wire        cntacr3_select;
wire        cntacr4_select;
wire        cntacr5_select;
wire        cntacr6_select;
wire        cntacr7_select;
wire        cntvloff0_select;
wire        cntvuoff0_select;
wire        cntvloff1_select;
wire        cntvuoff1_select;
wire        cntvloff2_select;
wire        cntvuoff2_select;
wire        cntvloff3_select;
wire        cntvuoff3_select;
wire        cntvloff4_select;
wire        cntvuoff4_select;
wire        cntvloff5_select;
wire        cntvuoff5_select;
wire        cntvloff6_select;
wire        cntvuoff6_select;
wire        cntvloff7_select;
wire        cntvuoff7_select;
wire        pid4_select;
wire        pid0_select;
wire        pid1_select;
wire        pid2_select;
wire        pid3_select;
wire        compid0_select;
wire        compid1_select;
wire        compid2_select;
wire        compid3_select;

wire  [3:0] cntfrq_write;
wire  [3:0] cntnsar_write;
wire  [3:0] cntacr0_write;
wire  [3:0] cntacr1_write;
wire  [3:0] cntacr2_write;
wire  [3:0] cntacr3_write;
wire  [3:0] cntacr4_write;
wire  [3:0] cntacr5_write;
wire  [3:0] cntacr6_write;
wire  [3:0] cntacr7_write;
wire  [3:0] cntvloff0_write;
wire  [3:0] cntvuoff0_write;
wire  [3:0] cntvloff1_write;
wire  [3:0] cntvuoff1_write;
wire  [3:0] cntvloff2_write;
wire  [3:0] cntvuoff2_write;
wire  [3:0] cntvloff3_write;
wire  [3:0] cntvuoff3_write;
wire  [3:0] cntvloff4_write;
wire  [3:0] cntvuoff4_write;
wire  [3:0] cntvloff5_write;
wire  [3:0] cntvuoff5_write;
wire  [3:0] cntvloff6_write;
wire  [3:0] cntvuoff6_write;
wire  [3:0] cntvloff7_write;
wire  [3:0] cntvuoff7_write;

wire        cntfrq_read;
wire        cntnsar_read;
wire        cnttidr_read;
wire        cntacr0_read;
wire        cntacr1_read;
wire        cntacr2_read;
wire        cntacr3_read;
wire        cntacr4_read;
wire        cntacr5_read;
wire        cntacr6_read;
wire        cntacr7_read;
wire        cntvloff0_read;
wire        cntvuoff0_read;
wire        cntvloff1_read;
wire        cntvuoff1_read;
wire        cntvloff2_read;
wire        cntvuoff2_read;
wire        cntvloff3_read;
wire        cntvuoff3_read;
wire        cntvloff4_read;
wire        cntvuoff4_read;
wire        cntvloff5_read;
wire        cntvuoff5_read;
wire        cntvloff6_read;
wire        cntvuoff6_read;
wire        cntvloff7_read;
wire        cntvuoff7_read;
wire        cntpidr4_read;
wire        cntpidr0_read;
wire        cntpidr1_read;
wire        cntpidr2_read;
wire        cntpidr3_read;
wire        cntcidr0_read;
wire        cntcidr1_read;
wire        cntcidr2_read;
wire        cntcidr3_read;


wire [31:0] next_cntfrq;
wire  [7:0] next_cntnsar;
wire  [5:0] next_cntacr0;
wire  [5:0] next_cntacr1;
wire  [5:0] next_cntacr2;
wire  [5:0] next_cntacr3;
wire  [5:0] next_cntacr4;
wire  [5:0] next_cntacr5;
wire  [5:0] next_cntacr6;
wire  [5:0] next_cntacr7;
wire [31:0] next_cntvloff0;
wire [31:0] next_cntvuoff0;
wire [31:0] next_cntvloff1;
wire [31:0] next_cntvuoff1;
wire [31:0] next_cntvloff2;
wire [31:0] next_cntvuoff2;
wire [31:0] next_cntvloff3;
wire [31:0] next_cntvuoff3;
wire [31:0] next_cntvloff4;
wire [31:0] next_cntvuoff4;
wire [31:0] next_cntvloff5;
wire [31:0] next_cntvuoff5;
wire [31:0] next_cntvloff6;
wire [31:0] next_cntvuoff6;
wire [31:0] next_cntvloff7;
wire [31:0] next_cntvuoff7;

reg  [31:0] next_prdata;


wire [7:0]  cntpidr4;
wire [7:0]  cntpidr0;
wire [7:0]  cntpidr1;
wire [7:0]  cntpidr2;
wire [7:0]  cntpidr3;
wire [31:0] cntcidrall;  

assign cntpidr4           = {`GTIMER_CONTROL_SIZE, `GTIMER_CONTROL_DES_2};
assign cntpidr0           = `GTIMER_CONTROL_PART_0;
assign cntpidr1           = {`GTIMER_CONTROL_DES_0, `GTIMER_CONTROL_PART_1};
assign cntpidr2           = {revision, `GTIMER_CONTROL_JEDEC, `GTIMER_CONTROL_DES_1};
assign cntpidr3           = {`GTIMER_CONTROL_REVAND, `GTIMER_CONTROL_CMOD};

assign cntcidrall = `GTIMER_CONTROL_COMPID;

`define TIMER7_PARS2     TIMER7_FI & TIMER7_FPL0
`define TIMER7_PARS1     TIMER7_FI & TIMER7_FVI
`define TIMER7_PARS0     TIMER7_FI

`define TIMER6_PARS2     TIMER6_FI & TIMER6_FPL0
`define TIMER6_PARS1     TIMER6_FI & TIMER6_FVI
`define TIMER6_PARS0     TIMER6_FI

`define TIMER5_PARS2     TIMER5_FI & TIMER5_FPL0
`define TIMER5_PARS1     TIMER5_FI & TIMER5_FVI
`define TIMER5_PARS0     TIMER5_FI

`define TIMER4_PARS2     TIMER4_FI & TIMER4_FPL0
`define TIMER4_PARS1     TIMER4_FI & TIMER4_FVI
`define TIMER4_PARS0     TIMER4_FI

`define TIMER3_PARS2     TIMER3_FI & TIMER3_FPL0
`define TIMER3_PARS1     TIMER3_FI & TIMER3_FVI
`define TIMER3_PARS0     TIMER3_FI

`define TIMER2_PARS2     TIMER2_FI & TIMER2_FPL0
`define TIMER2_PARS1     TIMER2_FI & TIMER2_FVI
`define TIMER2_PARS0     TIMER2_FI

`define TIMER1_PARS2     TIMER1_FI & TIMER1_FPL0
`define TIMER1_PARS1     TIMER1_FI & TIMER1_FVI
`define TIMER1_PARS0     TIMER1_FI

`define TIMER0_PARS2     TIMER0_FI & TIMER0_FPL0
`define TIMER0_PARS1     TIMER0_FI & TIMER0_FVI
`define TIMER0_PARS0     TIMER0_FI

assign cnttidr = {{1'b0, `TIMER7_PARS2, `TIMER7_PARS1, `TIMER7_PARS0},
                  {1'b0, `TIMER6_PARS2, `TIMER6_PARS1, `TIMER6_PARS0},
                  {1'b0, `TIMER5_PARS2, `TIMER5_PARS1, `TIMER5_PARS0},
                  {1'b0, `TIMER4_PARS2, `TIMER4_PARS1, `TIMER4_PARS0},
                  {1'b0, `TIMER3_PARS2, `TIMER3_PARS1, `TIMER3_PARS0},
                  {1'b0, `TIMER2_PARS2, `TIMER2_PARS1, `TIMER2_PARS0},
                  {1'b0, `TIMER1_PARS2, `TIMER1_PARS1, `TIMER1_PARS0},
                  {1'b0, `TIMER0_PARS2, `TIMER0_PARS1, `TIMER0_PARS0}};


`define TIMER_FIXED_SECURITY_VALS7     TIMER7_FI & ~TIMER7_CFGBL_ACC & TIMER7_NONSECURE
`define TIMER_FIXED_SECURITY_VALS6     TIMER6_FI & ~TIMER6_CFGBL_ACC & TIMER6_NONSECURE
`define TIMER_FIXED_SECURITY_VALS5     TIMER5_FI & ~TIMER5_CFGBL_ACC & TIMER5_NONSECURE
`define TIMER_FIXED_SECURITY_VALS4     TIMER4_FI & ~TIMER4_CFGBL_ACC & TIMER4_NONSECURE
`define TIMER_FIXED_SECURITY_VALS3     TIMER3_FI & ~TIMER3_CFGBL_ACC & TIMER3_NONSECURE
`define TIMER_FIXED_SECURITY_VALS2     TIMER2_FI & ~TIMER2_CFGBL_ACC & TIMER2_NONSECURE
`define TIMER_FIXED_SECURITY_VALS1     TIMER1_FI & ~TIMER1_CFGBL_ACC & TIMER1_NONSECURE
`define TIMER_FIXED_SECURITY_VALS0     TIMER0_FI & ~TIMER0_CFGBL_ACC & TIMER0_NONSECURE


`define TIMER_CFGBL_SECURITY7          TIMER7_FI & TIMER7_CFGBL_ACC
`define TIMER_CFGBL_SECURITY6          TIMER6_FI & TIMER6_CFGBL_ACC
`define TIMER_CFGBL_SECURITY5          TIMER5_FI & TIMER5_CFGBL_ACC
`define TIMER_CFGBL_SECURITY4          TIMER4_FI & TIMER4_CFGBL_ACC
`define TIMER_CFGBL_SECURITY3          TIMER3_FI & TIMER3_CFGBL_ACC
`define TIMER_CFGBL_SECURITY2          TIMER2_FI & TIMER2_CFGBL_ACC
`define TIMER_CFGBL_SECURITY1          TIMER1_FI & TIMER1_CFGBL_ACC
`define TIMER_CFGBL_SECURITY0          TIMER0_FI & TIMER0_CFGBL_ACC

assign timer_fixed_sec_vals = {`TIMER_FIXED_SECURITY_VALS7,
                               `TIMER_FIXED_SECURITY_VALS6,
                               `TIMER_FIXED_SECURITY_VALS5,
                               `TIMER_FIXED_SECURITY_VALS4,
                               `TIMER_FIXED_SECURITY_VALS3,
                               `TIMER_FIXED_SECURITY_VALS2,
                               `TIMER_FIXED_SECURITY_VALS1,
                               `TIMER_FIXED_SECURITY_VALS0};

assign timer_cfgbl_sec      = {`TIMER_CFGBL_SECURITY7,
                               `TIMER_CFGBL_SECURITY6,
                               `TIMER_CFGBL_SECURITY5,
                               `TIMER_CFGBL_SECURITY4,
                               `TIMER_CFGBL_SECURITY3,
                               `TIMER_CFGBL_SECURITY2,
                               `TIMER_CFGBL_SECURITY1,
                               `TIMER_CFGBL_SECURITY0};

                               

assign pwdata_enabled     = (PSEL & PWRITE) ?  PWDATA : 32'h0000_0000;

assign paddr_enabled      =  PSEL ? PADDR : 10'b0000000000;

assign write_enable       =  PSTRB & {4{PSEL & PWRITE & PENABLE}};

assign read_enable        =  PSEL & (~PWRITE) & (~PENABLE);

assign secure_access      =  PSEL & ~PPROT[1];

assign PREADY             =  1'b1;
assign PSLVERR            =  1'b0;

always @*
  begin
    register_select = 36'h0_0000_0000;
  
    case (paddr_enabled)
      
      `CNTFRQ_ADDR     :  if (secure_access)
                            register_select[0] = 1'b1;

      `CNTNSAR_ADDR    :  if (secure_access)
                            register_select[1] = 1'b1;

      `CNTTIDR_ADDR    :  register_select[2] = 1'b1;

      `CNTACR0_ADDR    :  if (TIMER0_FI)
                            if (cntnsar[0] | secure_access)
                              register_select[3]  = 1'b1;
                            
      `CNTACR1_ADDR    :  if (TIMER1_FI)
                            if (cntnsar[1] | secure_access)
                              register_select[4]  = 1'b1;
                            
      `CNTACR2_ADDR    :  if (TIMER2_FI)
                            if (cntnsar[2] | secure_access)
                              register_select[5]  = 1'b1;
                            
      `CNTACR3_ADDR    :  if (TIMER3_FI)
                            if (cntnsar[3] | secure_access)
                              register_select[6]  = 1'b1;
                            
      `CNTACR4_ADDR    :  if (TIMER4_FI)
                            if (cntnsar[4] | secure_access)
                              register_select[7]  = 1'b1;
                            
      `CNTACR5_ADDR    :  if (TIMER5_FI)
                            if (cntnsar[5] | secure_access)
                              register_select[8]  = 1'b1;
                            
      `CNTACR6_ADDR    :  if (TIMER6_FI)
                            if (cntnsar[6] | secure_access)
                              register_select[9]  = 1'b1;
                            
      `CNTACR7_ADDR    :  if (TIMER7_FI)
                            if (cntnsar[7] | secure_access)
                              register_select[10] = 1'b1;

      `CNTVLOFF0_ADDR  :  if (TIMER0_FI & TIMER0_FVI)
                            if (cntnsar[0] | secure_access)
                              register_select[11] = 1'b1;
                            
      `CNTVUOFF0_ADDR  :  if (TIMER0_FI & TIMER0_FVI)
                            if (cntnsar[0] | secure_access)
                              register_select[12] = 1'b1;
                            
      `CNTVLOFF1_ADDR  :  if (TIMER1_FI & TIMER1_FVI)
                            if (cntnsar[1] | secure_access)
                              register_select[13] = 1'b1;
                            
      `CNTVUOFF1_ADDR  :  if (TIMER1_FI & TIMER1_FVI)
                            if (cntnsar[1] | secure_access)
                              register_select[14] = 1'b1;
                            
      `CNTVLOFF2_ADDR  :  if (TIMER2_FI & TIMER2_FVI)
                            if (cntnsar[2] | secure_access)
                              register_select[15] = 1'b1;
                            
      `CNTVUOFF2_ADDR  :  if (TIMER2_FI & TIMER2_FVI)
                            if (cntnsar[2] | secure_access)
                              register_select[16] = 1'b1;
                            
      `CNTVLOFF3_ADDR  :  if (TIMER3_FI & TIMER3_FVI)
                            if (cntnsar[3] | secure_access)
                              register_select[17] = 1'b1;
                            
      `CNTVUOFF3_ADDR  :  if (TIMER3_FI & TIMER3_FVI)
                            if (cntnsar[3] | secure_access)
                              register_select[18] = 1'b1;

      `CNTVLOFF4_ADDR  :  if (TIMER4_FI & TIMER4_FVI)
                            if (cntnsar[4] | secure_access)
                              register_select[19] = 1'b1;
                            
      `CNTVUOFF4_ADDR  :  if (TIMER4_FI & TIMER4_FVI)
                            if (cntnsar[4] | secure_access)
                              register_select[20] = 1'b1;
                            
      `CNTVLOFF5_ADDR  :  if (TIMER5_FI & TIMER5_FVI)
                            if (cntnsar[5] | secure_access)
                              register_select[21] = 1'b1;
                            
      `CNTVUOFF5_ADDR  :  if (TIMER5_FI & TIMER5_FVI)
                            if (cntnsar[5] | secure_access)
                              register_select[22] = 1'b1;
                            
      `CNTVLOFF6_ADDR  :  if (TIMER6_FI & TIMER6_FVI)
                            if (cntnsar[6] | secure_access)
                              register_select[23] = 1'b1;
                            
      `CNTVUOFF6_ADDR  :  if (TIMER6_FI & TIMER6_FVI)
                            if (cntnsar[6] | secure_access)
                              register_select[24] = 1'b1;
                            
      `CNTVLOFF7_ADDR  :  if (TIMER7_FI & TIMER7_FVI)
                            if (cntnsar[7] | secure_access)
                              register_select[25] = 1'b1;
                            
      `CNTVUOFF7_ADDR  :  if (TIMER7_FI & TIMER7_FVI)
                            if (cntnsar[7] | secure_access)
                              register_select[26] = 1'b1;

      `CNTPIDR4_ADDR   :  register_select[27] = 1'b1;
      
      `CNTPIDR0_ADDR   :  register_select[28] = 1'b1;
      `CNTPIDR1_ADDR   :  register_select[29] = 1'b1;
      `CNTPIDR2_ADDR   :  register_select[30] = 1'b1;
      `CNTPIDR3_ADDR   :  register_select[31] = 1'b1;

      `CNTCIDR0_ADDR   :  register_select[32] = 1'b1;
      `CNTCIDR1_ADDR   :  register_select[33] = 1'b1;
      `CNTCIDR2_ADDR   :  register_select[34] = 1'b1;
      `CNTCIDR3_ADDR   :  register_select[35] = 1'b1;
              default  :  register_select = 36'h0_0000_0000;
    endcase
  end

assign {compid3_select,   compid2_select,   compid1_select,   compid0_select,
        pid3_select,      pid2_select,      pid1_select,      pid0_select,
        pid4_select,
        cntvuoff7_select, cntvloff7_select, cntvuoff6_select, cntvloff6_select,
        cntvuoff5_select, cntvloff5_select, cntvuoff4_select, cntvloff4_select,
        cntvuoff3_select, cntvloff3_select, cntvuoff2_select, cntvloff2_select,
        cntvuoff1_select, cntvloff1_select, cntvuoff0_select, cntvloff0_select,
        cntacr7_select,   cntacr6_select,   cntacr5_select,   cntacr4_select,
        cntacr3_select,   cntacr2_select,   cntacr1_select,   cntacr0_select,
        cnttidr_select,   cntnsar_select,   cntfrq_select}
        = register_select;


assign cntfrq_write     =  ( write_enable & {4{cntfrq_select}} );
assign cntnsar_write    =  ( write_enable & {4{cntnsar_select}} );

assign cntacr0_write    =  ( write_enable & {4{cntacr0_select}} );
assign cntacr1_write    =  ( write_enable & {4{cntacr1_select}} );
assign cntacr2_write    =  ( write_enable & {4{cntacr2_select}} );
assign cntacr3_write    =  ( write_enable & {4{cntacr3_select}} );
assign cntacr4_write    =  ( write_enable & {4{cntacr4_select}} );
assign cntacr5_write    =  ( write_enable & {4{cntacr5_select}} );
assign cntacr6_write    =  ( write_enable & {4{cntacr6_select}} );
assign cntacr7_write    =  ( write_enable & {4{cntacr7_select}} );

assign cntvloff0_write  =  ( write_enable & {4{cntvloff0_select}} );
assign cntvuoff0_write  =  ( write_enable & {4{cntvuoff0_select}} );
assign cntvloff1_write  =  ( write_enable & {4{cntvloff1_select}} );
assign cntvuoff1_write  =  ( write_enable & {4{cntvuoff1_select}} );
assign cntvloff2_write  =  ( write_enable & {4{cntvloff2_select}} );
assign cntvuoff2_write  =  ( write_enable & {4{cntvuoff2_select}} );
assign cntvloff3_write  =  ( write_enable & {4{cntvloff3_select}} );
assign cntvuoff3_write  =  ( write_enable & {4{cntvuoff3_select}} );

assign cntvloff4_write  =  ( write_enable & {4{cntvloff4_select}} );
assign cntvuoff4_write  =  ( write_enable & {4{cntvuoff4_select}} );
assign cntvloff5_write  =  ( write_enable & {4{cntvloff5_select}} );
assign cntvuoff5_write  =  ( write_enable & {4{cntvuoff5_select}} );
assign cntvloff6_write  =  ( write_enable & {4{cntvloff6_select}} );
assign cntvuoff6_write  =  ( write_enable & {4{cntvuoff6_select}} );
assign cntvloff7_write  =  ( write_enable & {4{cntvloff7_select}} );
assign cntvuoff7_write  =  ( write_enable & {4{cntvuoff7_select}} );

assign cntfrq_read      =  ( read_enable & cntfrq_select );
assign cntnsar_read     =  ( read_enable & cntnsar_select);
assign cnttidr_read     =  ( read_enable & cnttidr_select );

assign cntacr0_read     =  ( read_enable & cntacr0_select );
assign cntacr1_read     =  ( read_enable & cntacr1_select );
assign cntacr2_read     =  ( read_enable & cntacr2_select );
assign cntacr3_read     =  ( read_enable & cntacr3_select );
assign cntacr4_read     =  ( read_enable & cntacr4_select );
assign cntacr5_read     =  ( read_enable & cntacr5_select );
assign cntacr6_read     =  ( read_enable & cntacr6_select );
assign cntacr7_read     =  ( read_enable & cntacr7_select );

assign cntvloff0_read   =  ( read_enable & cntvloff0_select );
assign cntvuoff0_read   =  ( read_enable & cntvuoff0_select );
assign cntvloff1_read   =  ( read_enable & cntvloff1_select );
assign cntvuoff1_read   =  ( read_enable & cntvuoff1_select );
assign cntvloff2_read   =  ( read_enable & cntvloff2_select );
assign cntvuoff2_read   =  ( read_enable & cntvuoff2_select );
assign cntvloff3_read   =  ( read_enable & cntvloff3_select );
assign cntvuoff3_read   =  ( read_enable & cntvuoff3_select );

assign cntvloff4_read   =  ( read_enable & cntvloff4_select );
assign cntvuoff4_read   =  ( read_enable & cntvuoff4_select );
assign cntvloff5_read   =  ( read_enable & cntvloff5_select );
assign cntvuoff5_read   =  ( read_enable & cntvuoff5_select );
assign cntvloff6_read   =  ( read_enable & cntvloff6_select );
assign cntvuoff6_read   =  ( read_enable & cntvuoff6_select );
assign cntvloff7_read   =  ( read_enable & cntvloff7_select );
assign cntvuoff7_read   =  ( read_enable & cntvuoff7_select );

assign cntpidr4_read    =  ( read_enable & pid4_select );

assign cntpidr0_read    =  ( read_enable & pid0_select );
assign cntpidr1_read    =  ( read_enable & pid1_select );
assign cntpidr2_read    =  ( read_enable & pid2_select );
assign cntpidr3_read    =  ( read_enable & pid3_select );

assign cntcidr0_read    =  ( read_enable & compid0_select );
assign cntcidr1_read    =  ( read_enable & compid1_select );
assign cntcidr2_read    =  ( read_enable & compid2_select );
assign cntcidr3_read    =  ( read_enable & compid3_select );



assign  next_cntfrq[7:0]   =  (cntfrq_write[0])  ?  pwdata_enabled[7:0]   :  cntfrq[7:0];
assign  next_cntfrq[15:8]  =  (cntfrq_write[1])  ?  pwdata_enabled[15:8]  :  cntfrq[15:8];
assign  next_cntfrq[23:16] =  (cntfrq_write[2])  ?  pwdata_enabled[23:16] :  cntfrq[23:16];
assign  next_cntfrq[31:24] =  (cntfrq_write[3])  ?  pwdata_enabled[31:24] :  cntfrq[31:24];

assign  next_cntnsar   =  (cntnsar_write[0])   ?  ((timer_cfgbl_sec & pwdata_enabled[7:0]) | timer_fixed_sec_vals)  :
                                               ((timer_cfgbl_sec & cntnsar) | timer_fixed_sec_vals);

assign  next_cntacr0   =  (cntacr0_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR0;
assign  next_cntacr1   =  (cntacr1_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR1;
assign  next_cntacr2   =  (cntacr2_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR2;
assign  next_cntacr3   =  (cntacr3_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR3;
assign  next_cntacr4   =  (cntacr4_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR4;
assign  next_cntacr5   =  (cntacr5_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR5;
assign  next_cntacr6   =  (cntacr6_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR6;
assign  next_cntacr7   =  (cntacr7_write[0])   ?  pwdata_enabled[5:0]  :  CNTACR7;

assign  next_cntvloff0[7:0]   =  (cntvloff0_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff0[7:0];
assign  next_cntvloff0[15:8]  =  (cntvloff0_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff0[15:8];
assign  next_cntvloff0[23:16] =  (cntvloff0_write[2])  ?  pwdata_enabled[23:16] :  cntvloff0[23:16];
assign  next_cntvloff0[31:24] =  (cntvloff0_write[3])  ?  pwdata_enabled[31:24] :  cntvloff0[31:24];

assign  next_cntvuoff0[7:0]   =  (cntvuoff0_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff0[7:0];
assign  next_cntvuoff0[15:8]  =  (cntvuoff0_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff0[15:8];
assign  next_cntvuoff0[23:16] =  (cntvuoff0_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff0[23:16];
assign  next_cntvuoff0[31:24] =  (cntvuoff0_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff0[31:24];

assign  next_cntvloff1[7:0]   =  (cntvloff1_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff1[7:0];
assign  next_cntvloff1[15:8]  =  (cntvloff1_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff1[15:8];
assign  next_cntvloff1[23:16] =  (cntvloff1_write[2])  ?  pwdata_enabled[23:16] :  cntvloff1[23:16];
assign  next_cntvloff1[31:24] =  (cntvloff1_write[3])  ?  pwdata_enabled[31:24] :  cntvloff1[31:24];

assign  next_cntvuoff1[7:0]   =  (cntvuoff1_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff1[7:0];
assign  next_cntvuoff1[15:8]  =  (cntvuoff1_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff1[15:8];
assign  next_cntvuoff1[23:16] =  (cntvuoff1_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff1[23:16];
assign  next_cntvuoff1[31:24] =  (cntvuoff1_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff1[31:24];

assign  next_cntvloff2[7:0]   =  (cntvloff2_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff2[7:0];
assign  next_cntvloff2[15:8]  =  (cntvloff2_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff2[15:8];
assign  next_cntvloff2[23:16] =  (cntvloff2_write[2])  ?  pwdata_enabled[23:16] :  cntvloff2[23:16];
assign  next_cntvloff2[31:24] =  (cntvloff2_write[3])  ?  pwdata_enabled[31:24] :  cntvloff2[31:24];

assign  next_cntvuoff2[7:0]   =  (cntvuoff2_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff2[7:0];
assign  next_cntvuoff2[15:8]  =  (cntvuoff2_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff2[15:8];
assign  next_cntvuoff2[23:16] =  (cntvuoff2_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff2[23:16];
assign  next_cntvuoff2[31:24] =  (cntvuoff2_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff2[31:24];

assign  next_cntvloff3[7:0]   =  (cntvloff3_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff3[7:0];
assign  next_cntvloff3[15:8]  =  (cntvloff3_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff3[15:8];
assign  next_cntvloff3[23:16] =  (cntvloff3_write[2])  ?  pwdata_enabled[23:16] :  cntvloff3[23:16];
assign  next_cntvloff3[31:24] =  (cntvloff3_write[3])  ?  pwdata_enabled[31:24] :  cntvloff3[31:24];

assign  next_cntvuoff3[7:0]   =  (cntvuoff3_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff3[7:0];
assign  next_cntvuoff3[15:8]  =  (cntvuoff3_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff3[15:8];
assign  next_cntvuoff3[23:16] =  (cntvuoff3_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff3[23:16];
assign  next_cntvuoff3[31:24] =  (cntvuoff3_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff3[31:24];

assign  next_cntvloff4[7:0]   =  (cntvloff4_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff4[7:0];
assign  next_cntvloff4[15:8]  =  (cntvloff4_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff4[15:8];
assign  next_cntvloff4[23:16] =  (cntvloff4_write[2])  ?  pwdata_enabled[23:16] :  cntvloff4[23:16];
assign  next_cntvloff4[31:24] =  (cntvloff4_write[3])  ?  pwdata_enabled[31:24] :  cntvloff4[31:24];

assign  next_cntvuoff4[7:0]   =  (cntvuoff4_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff4[7:0];
assign  next_cntvuoff4[15:8]  =  (cntvuoff4_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff4[15:8];
assign  next_cntvuoff4[23:16] =  (cntvuoff4_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff4[23:16];
assign  next_cntvuoff4[31:24] =  (cntvuoff4_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff4[31:24];

assign  next_cntvloff5[7:0]   =  (cntvloff5_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff5[7:0];
assign  next_cntvloff5[15:8]  =  (cntvloff5_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff5[15:8];
assign  next_cntvloff5[23:16] =  (cntvloff5_write[2])  ?  pwdata_enabled[23:16] :  cntvloff5[23:16];
assign  next_cntvloff5[31:24] =  (cntvloff5_write[3])  ?  pwdata_enabled[31:24] :  cntvloff5[31:24];

assign  next_cntvuoff5[7:0]   =  (cntvuoff5_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff5[7:0];
assign  next_cntvuoff5[15:8]  =  (cntvuoff5_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff5[15:8];
assign  next_cntvuoff5[23:16] =  (cntvuoff5_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff5[23:16];
assign  next_cntvuoff5[31:24] =  (cntvuoff5_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff5[31:24];

assign  next_cntvloff6[7:0]   =  (cntvloff6_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff6[7:0];
assign  next_cntvloff6[15:8]  =  (cntvloff6_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff6[15:8];
assign  next_cntvloff6[23:16] =  (cntvloff6_write[2])  ?  pwdata_enabled[23:16] :  cntvloff6[23:16];
assign  next_cntvloff6[31:24] =  (cntvloff6_write[3])  ?  pwdata_enabled[31:24] :  cntvloff6[31:24];

assign  next_cntvuoff6[7:0]   =  (cntvuoff6_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff6[7:0];
assign  next_cntvuoff6[15:8]  =  (cntvuoff6_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff6[15:8];
assign  next_cntvuoff6[23:16] =  (cntvuoff6_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff6[23:16];
assign  next_cntvuoff6[31:24] =  (cntvuoff6_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff6[31:24];

assign  next_cntvloff7[7:0]   =  (cntvloff7_write[0])  ?  pwdata_enabled[7:0]   :  cntvloff7[7:0];
assign  next_cntvloff7[15:8]  =  (cntvloff7_write[1])  ?  pwdata_enabled[15:8]  :  cntvloff7[15:8];
assign  next_cntvloff7[23:16] =  (cntvloff7_write[2])  ?  pwdata_enabled[23:16] :  cntvloff7[23:16];
assign  next_cntvloff7[31:24] =  (cntvloff7_write[3])  ?  pwdata_enabled[31:24] :  cntvloff7[31:24];

assign  next_cntvuoff7[7:0]   =  (cntvuoff7_write[0])  ?  pwdata_enabled[7:0]   :  cntvuoff7[7:0];
assign  next_cntvuoff7[15:8]  =  (cntvuoff7_write[1])  ?  pwdata_enabled[15:8]  :  cntvuoff7[15:8];
assign  next_cntvuoff7[23:16] =  (cntvuoff7_write[2])  ?  pwdata_enabled[23:16] :  cntvuoff7[23:16];
assign  next_cntvuoff7[31:24] =  (cntvuoff7_write[3])  ?  pwdata_enabled[31:24] :  cntvuoff7[31:24];


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntfrq     <=  32'h0000_0000;
      cntnsar    <=  timer_fixed_sec_vals;
      CNTACR0    <=  6'h00;  
      CNTACR1    <=  6'h00;  
      CNTACR2    <=  6'h00;  
      CNTACR3    <=  6'h00;  
      CNTACR4    <=  6'h00;  
      CNTACR5    <=  6'h00;  
      CNTACR6    <=  6'h00;  
      CNTACR7    <=  6'h00;  
      cntvloff0  <=  32'h0000_0000;  
      cntvuoff0  <=  32'h0000_0000;  
      cntvloff1  <=  32'h0000_0000;  
      cntvuoff1  <=  32'h0000_0000;  
      cntvloff2  <=  32'h0000_0000;  
      cntvuoff2  <=  32'h0000_0000;  
      cntvloff3  <=  32'h0000_0000;  
      cntvuoff3  <=  32'h0000_0000;  
      cntvloff4  <=  32'h0000_0000;  
      cntvuoff4  <=  32'h0000_0000;  
      cntvloff5  <=  32'h0000_0000;  
      cntvuoff5  <=  32'h0000_0000;  
      cntvloff6  <=  32'h0000_0000;  
      cntvuoff6  <=  32'h0000_0000;  
      cntvloff7  <=  32'h0000_0000;  
      cntvuoff7  <=  32'h0000_0000;  
    end
  else
    begin
      cntfrq     <=  next_cntfrq;
      cntnsar    <=  next_cntnsar;
      CNTACR0    <=  next_cntacr0;
      CNTACR1    <=  next_cntacr1;
      CNTACR2    <=  next_cntacr2;
      CNTACR3    <=  next_cntacr3;
      CNTACR4    <=  next_cntacr4;
      CNTACR5    <=  next_cntacr5;
      CNTACR6    <=  next_cntacr6;
      CNTACR7    <=  next_cntacr7;
      cntvloff0  <=  next_cntvloff0;
      cntvuoff0  <=  next_cntvuoff0;
      cntvloff1  <=  next_cntvloff1;
      cntvuoff1  <=  next_cntvuoff1;
      cntvloff2  <=  next_cntvloff2;
      cntvuoff2  <=  next_cntvuoff2;
      cntvloff3  <=  next_cntvloff3;
      cntvuoff3  <=  next_cntvuoff3;
      cntvloff4  <=  next_cntvloff4;
      cntvuoff4  <=  next_cntvuoff4;
      cntvloff5  <=  next_cntvloff5;
      cntvuoff5  <=  next_cntvuoff5;
      cntvloff6  <=  next_cntvloff6;
      cntvuoff6  <=  next_cntvuoff6;
      cntvloff7  <=  next_cntvloff7;
      cntvuoff7  <=  next_cntvuoff7;
    end


assign CNTVOFF0  =  {cntvuoff0, cntvloff0};
assign CNTVOFF1  =  {cntvuoff1, cntvloff1};
assign CNTVOFF2  =  {cntvuoff2, cntvloff2};
assign CNTVOFF3  =  {cntvuoff3, cntvloff3};
assign CNTVOFF4  =  {cntvuoff4, cntvloff4};
assign CNTVOFF5  =  {cntvuoff5, cntvloff5};
assign CNTVOFF6  =  {cntvuoff6, cntvloff6};
assign CNTVOFF7  =  {cntvuoff7, cntvloff7};


always @*
  case ({cntfrq_read, cntnsar_read, cnttidr_read,
         cntacr0_read, cntacr1_read, cntacr2_read, cntacr3_read,
         cntacr4_read, cntacr5_read, cntacr6_read, cntacr7_read,
         cntvloff0_read, cntvuoff0_read, cntvloff1_read, cntvuoff1_read,
         cntvloff2_read, cntvuoff2_read, cntvloff3_read, cntvuoff3_read,
         cntvloff4_read, cntvuoff4_read, cntvloff5_read, cntvuoff5_read,
         cntvloff6_read, cntvuoff6_read, cntvloff7_read, cntvuoff7_read,
         cntpidr4_read, cntpidr0_read, cntpidr1_read, cntpidr2_read, cntpidr3_read,
         cntcidr0_read, cntcidr1_read, cntcidr2_read, cntcidr3_read})
    36'h8_0000_0000 : next_prdata = cntfrq;
    36'h4_0000_0000 : next_prdata = {24'h00_0000, cntnsar};
    36'h2_0000_0000 : next_prdata = cnttidr;
    
    36'h1_0000_0000 : next_prdata = {26'h00_0000, CNTACR0};
    36'h0_8000_0000 : next_prdata = {26'h00_0000, CNTACR1};
    36'h0_4000_0000 : next_prdata = {26'h00_0000, CNTACR2};
    36'h0_2000_0000 : next_prdata = {26'h00_0000, CNTACR3};
    36'h0_1000_0000 : next_prdata = {26'h00_0000, CNTACR4};
    36'h0_0800_0000 : next_prdata = {26'h00_0000, CNTACR5};
    36'h0_0400_0000 : next_prdata = {26'h00_0000, CNTACR6};
    36'h0_0200_0000 : next_prdata = {26'h00_0000, CNTACR7};
    
    36'h0_0100_0000 : next_prdata = cntvloff0;
    36'h0_0080_0000 : next_prdata = cntvuoff0;
    36'h0_0040_0000 : next_prdata = cntvloff1;
    36'h0_0020_0000 : next_prdata = cntvuoff1;
    36'h0_0010_0000 : next_prdata = cntvloff2;
    36'h0_0008_0000 : next_prdata = cntvuoff2;
    36'h0_0004_0000 : next_prdata = cntvloff3;
    36'h0_0002_0000 : next_prdata = cntvuoff3;
    
    36'h0_0001_0000 : next_prdata = cntvloff4;
    36'h0_0000_8000 : next_prdata = cntvuoff4;
    36'h0_0000_4000 : next_prdata = cntvloff5;
    36'h0_0000_2000 : next_prdata = cntvuoff5;
    36'h0_0000_1000 : next_prdata = cntvloff6;
    36'h0_0000_0800 : next_prdata = cntvuoff6;
    36'h0_0000_0400 : next_prdata = cntvloff7;
    36'h0_0000_0200 : next_prdata = cntvuoff7;
    
    36'h0_0000_0100 : next_prdata = {24'h00_0000, cntpidr4};

    36'h0_0000_0080 : next_prdata = {24'h00_0000, cntpidr0};
    36'h0_0000_0040 : next_prdata = {24'h00_0000, cntpidr1};
    36'h0_0000_0020 : next_prdata = {24'h00_0000, cntpidr2};
    36'h0_0000_0010 : next_prdata = {24'h00_0000, cntpidr3};
    
    36'h0_0000_0008 : next_prdata = {24'h00_0000, cntcidrall[7:0]};
    36'h0_0000_0004 : next_prdata = {24'h00_0000, cntcidrall[15:8]};
    36'h0_0000_0002 : next_prdata = {24'h00_0000, cntcidrall[23:16]};
    36'h0_0000_0001 : next_prdata = {24'h00_0000, cntcidrall[31:24]};
            default : next_prdata = 32'h0000_0000;
  endcase

always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    PRDATA <= 32'h0000_0000;
  else
    PRDATA <= next_prdata;
end




`undef CNTFRQ_ADDR
`undef CNTNSAR_ADDR
`undef CNTACR0_ADDR
`undef CNTACR1_ADDR
`undef CNTACR2_ADDR
`undef CNTACR3_ADDR
`undef CNTACR4_ADDR
`undef CNTACR5_ADDR
`undef CNTACR6_ADDR
`undef CNTACR7_ADDR
`undef CNTVLOFF0_ADDR
`undef CNTVUOFF0_ADDR
`undef CNTVLOFF1_ADDR
`undef CNTVUOFF1_ADDR
`undef CNTVLOFF2_ADDR
`undef CNTVUOFF2_ADDR
`undef CNTVLOFF3_ADDR
`undef CNTVUOFF3_ADDR
`undef CNTVLOFF4_ADDR
`undef CNTVUOFF4_ADDR
`undef CNTVLOFF5_ADDR
`undef CNTVUOFF5_ADDR
`undef CNTVLOFF6_ADDR
`undef CNTVUOFF6_ADDR
`undef CNTVLOFF7_ADDR
`undef CNTVUOFF7_ADDR
`undef CNTTIDR_ADDR
`undef CNTPIDR4_ADDR
`undef CNTPIDR0_ADDR
`undef CNTPIDR1_ADDR
`undef CNTPIDR2_ADDR
`undef CNTPIDR3_ADDR
`undef CNTCIDR0_ADDR
`undef CNTCIDR1_ADDR
`undef CNTCIDR2_ADDR
`undef CNTCIDR3_ADDR
`undef GTIMER_CONTROL_PART_0
`undef GTIMER_CONTROL_PART_1
`undef GTIMER_CONTROL_DES_0
`undef GTIMER_CONTROL_DES_1
`undef GTIMER_CONTROL_DES_2
`undef GTIMER_CONTROL_SIZE
`undef GTIMER_CONTROL_JEDEC
`undef GTIMER_CONTROL_CMOD
`undef GTIMER_CONTROL_REVAND
`undef GTIMER_CONTROL_COMPID
`undef TIMER7_PARS2
`undef TIMER7_PARS1
`undef TIMER7_PARS0
`undef TIMER6_PARS2
`undef TIMER6_PARS1
`undef TIMER6_PARS0
`undef TIMER5_PARS2
`undef TIMER5_PARS1
`undef TIMER5_PARS0
`undef TIMER4_PARS2
`undef TIMER4_PARS1
`undef TIMER4_PARS0
`undef TIMER3_PARS2
`undef TIMER3_PARS1
`undef TIMER3_PARS0
`undef TIMER2_PARS2
`undef TIMER2_PARS1
`undef TIMER2_PARS0
`undef TIMER1_PARS2
`undef TIMER1_PARS1
`undef TIMER1_PARS0
`undef TIMER0_PARS2
`undef TIMER0_PARS1
`undef TIMER0_PARS0
`undef TIMER_FIXED_SECURITY_VALS7
`undef TIMER_FIXED_SECURITY_VALS6
`undef TIMER_FIXED_SECURITY_VALS5
`undef TIMER_FIXED_SECURITY_VALS4
`undef TIMER_FIXED_SECURITY_VALS3
`undef TIMER_FIXED_SECURITY_VALS2
`undef TIMER_FIXED_SECURITY_VALS1
`undef TIMER_FIXED_SECURITY_VALS0
`undef TIMER_CFGBL_SECURITY7
`undef TIMER_CFGBL_SECURITY6
`undef TIMER_CFGBL_SECURITY5
`undef TIMER_CFGBL_SECURITY4
`undef TIMER_CFGBL_SECURITY3
`undef TIMER_CFGBL_SECURITY2
`undef TIMER_CFGBL_SECURITY1
`undef TIMER_CFGBL_SECURITY0

endmodule
