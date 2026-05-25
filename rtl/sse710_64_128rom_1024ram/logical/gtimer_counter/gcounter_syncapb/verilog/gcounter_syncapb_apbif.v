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


module gcounter_syncapb_apbif (
  input  wire        PCLK,              
  input  wire        PRESETn,           
  
  input  wire [11:2] PADDRCNTCONTROL,   
  input  wire        PSELCNTCONTROL,    
  input  wire        PENABLECNTCONTROL, 
  input  wire        PWRITECNTCONTROL,  
  input  wire [31:0] PWDATACNTCONTROL,  
  
  output wire        PREADYCNTCONTROL,  
  output reg  [31:0] PRDATACNTCONTROL,  
  output wire        PSLVERRCNTCONTROL, 
  
  input  wire [11:2] PADDRCNTREAD,      
  input  wire        PSELCNTREAD,       
  input  wire        PENABLECNTREAD,    
  input  wire        PWRITECNTREAD,     
  input  wire [31:0] PWDATACNTREAD,     
  
  output wire        PREADYCNTREAD,     
  output reg  [31:0] PRDATACNTREAD,     
  output wire        PSLVERRCNTREAD,    
  
  input  wire  [3:0] revision,          
  input  wire [63:0] tsvalueb,          
  input  wire        dbgh,              
  input  wire [63:0] cntsv,             
  
  output reg         hdbg,              
  output reg         enable_cnt,        
  output reg         ensync,            
  output wire        preload_cnt_l,     
  output wire        preload_cnt_u,     
  output wire [31:0] preload_cnt_data   
);






`define CNTCR_ADDR      10'b0000000000
`define CNTSR_ADDR      10'b0000000001
`define CNTCVL_ADDR     10'b0000000010
`define CNTCVU_ADDR     10'b0000000011
`define CNTFID0_ADDR    10'b0000001000
`define CNTFIDEND_ADDR  10'b0000001001
`define CNTSCR_ADDR     10'b0000110000
`define CNTSVL_ADDR     10'b0000110010
`define CNTSVU_ADDR     10'b0000110011

`define CNTCVLW_ADDR    10'b0000000000
`define CNTCVUP_ADDR    10'b0000000001

`define CNTPIDR4_ADDR   10'b1111110100

`define CNTPIDR0_ADDR   10'b1111111000
`define CNTPIDR1_ADDR   10'b1111111001
`define CNTPIDR2_ADDR   10'b1111111010
`define CNTPIDR3_ADDR   10'b1111111011

`define CNTCIDR0_ADDR   10'b1111111100
`define CNTCIDR1_ADDR   10'b1111111101
`define CNTCIDR2_ADDR   10'b1111111110
`define CNTCIDR3_ADDR   10'b1111111111


`define GCOUNTER_PART_0_CONTROL     8'b1001_1100
`define GCOUNTER_PART_0_READ        8'b1001_1101
`define GCOUNTER_PART_1             4'b0000
`define GCOUNTER_DES_0              4'b1011
`define GCOUNTER_DES_1              3'b011
`define GCOUNTER_DES_2              4'b0100
`define GCOUNTER_SIZE               4'b0000
`define GCOUNTER_JEDEC              1'b1
`define GCOUNTER_CMOD               4'b0000
`define GCOUNTER_REVAND             4'b0000

`define GCOUNTER_COMPID       32'hB105F00D

`define GCOUNTER_CNTFIDEND             32'h0000_0000

wire [11:2] paddr_enabled_cntctl;       
wire [31:0] pwdata_enabled_cntctl;      
wire        write_enable_cntctl;
wire        read_enable_cntctl;
reg  [31:0] next_prdata_cntctl;

wire        cntcr_write_cntctl;
wire        cntfid0_write_cntctl;
wire        cntscr_write_cntctl;

wire        cntcr_read_cntctl;
wire        cntsr_read_cntctl;
wire        cntcvl_read_cntctl;
wire        cntcvu_read_cntctl;
wire        cntfid0_read_cntctl;
wire        cntfidend_read_cntctl;
wire        cntscr_read_cntctl;
wire        cntsvl_read_cntctl;
wire        cntsvu_read_cntctl;

wire        cntpidr4_read_cntctl;
wire        cntpidr0_read_cntctl;
wire        cntpidr1_read_cntctl;
wire        cntpidr2_read_cntctl;
wire        cntpidr3_read_cntctl;
wire        cntcidr0_read_cntctl;
wire        cntcidr1_read_cntctl;
wire        cntcidr2_read_cntctl;
wire        cntcidr3_read_cntctl;

reg  [31:0] cntfid0;
reg         fcreq;
reg         fcack;

reg         next_fcreq;
wire        next_hdbg;
wire        next_enable_cnt;
wire [31:0] next_cntfid0;
wire        next_ensync;


wire [11:2] paddr_enabled_cntrd;       
wire        read_enable_cntrd;
reg  [31:0] next_prdata_cntrd;

wire        cntcvlw_read_cntrd;
wire        cntcvup_read_cntrd;

wire        cntpidr4_read_cntrd;
wire        cntpidr0_read_cntrd;
wire        cntpidr1_read_cntrd;
wire        cntpidr2_read_cntrd;
wire        cntpidr3_read_cntrd;
wire        cntcidr0_read_cntrd;
wire        cntcidr1_read_cntrd;
wire        cntcidr2_read_cntrd;
wire        cntcidr3_read_cntrd;


wire [7:0]  cntpidr4;
wire [7:0]  cntpidr0_control;
wire [7:0]  cntpidr0_read;
wire [7:0]  cntpidr1;
wire [7:0]  cntpidr2;
wire [7:0]  cntpidr3;
wire [31:0] cntcidrall;  

assign cntpidr4         = {`GCOUNTER_SIZE, `GCOUNTER_DES_2};
assign cntpidr0_control = `GCOUNTER_PART_0_CONTROL;
assign cntpidr0_read    = `GCOUNTER_PART_0_READ;
assign cntpidr1         = {`GCOUNTER_DES_0, `GCOUNTER_PART_1};
assign cntpidr2         = {revision, `GCOUNTER_JEDEC, `GCOUNTER_DES_1};
assign cntpidr3         = {`GCOUNTER_REVAND, `GCOUNTER_CMOD};

assign cntcidrall = `GCOUNTER_COMPID;


assign pwdata_enabled_cntctl = (PSELCNTCONTROL & PWRITECNTCONTROL) ?  PWDATACNTCONTROL : 32'h0000_0000;

assign paddr_enabled_cntctl  = PSELCNTCONTROL ? PADDRCNTCONTROL : 10'b0000000000;

assign write_enable_cntctl   = PSELCNTCONTROL & PWRITECNTCONTROL & PENABLECNTCONTROL;

assign read_enable_cntctl    = PSELCNTCONTROL & (~PWRITECNTCONTROL) & (~PENABLECNTCONTROL);

assign PREADYCNTCONTROL   = 1'b1;
assign PSLVERRCNTCONTROL  = 1'b0;

assign cntcr_write_cntctl    = (write_enable_cntctl && (paddr_enabled_cntctl == `CNTCR_ADDR));
assign cntfid0_write_cntctl  = (write_enable_cntctl && (paddr_enabled_cntctl == `CNTFID0_ADDR));
assign cntscr_write_cntctl   = (write_enable_cntctl && (paddr_enabled_cntctl == `CNTSCR_ADDR));

assign preload_cnt_l      = (write_enable_cntctl && (paddr_enabled_cntctl == `CNTCVL_ADDR));
assign preload_cnt_u      = (write_enable_cntctl && (paddr_enabled_cntctl == `CNTCVU_ADDR));


assign cntcr_read_cntctl     = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCR_ADDR));
assign cntsr_read_cntctl     = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTSR_ADDR));
assign cntcvl_read_cntctl    = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCVL_ADDR));
assign cntcvu_read_cntctl    = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCVU_ADDR));
assign cntfid0_read_cntctl   = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTFID0_ADDR));
assign cntfidend_read_cntctl = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTFIDEND_ADDR));
assign cntscr_read_cntctl    = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTSCR_ADDR));
assign cntsvl_read_cntctl    = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTSVL_ADDR));
assign cntsvu_read_cntctl    = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTSVU_ADDR));

assign cntpidr4_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTPIDR4_ADDR));
assign cntpidr0_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTPIDR0_ADDR));
assign cntpidr1_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTPIDR1_ADDR));
assign cntpidr2_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTPIDR2_ADDR));
assign cntpidr3_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTPIDR3_ADDR));

assign cntcidr0_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCIDR0_ADDR));
assign cntcidr1_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCIDR1_ADDR));
assign cntcidr2_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCIDR2_ADDR));
assign cntcidr3_read_cntctl  = (read_enable_cntctl && (paddr_enabled_cntctl == `CNTCIDR3_ADDR));

always @*
begin
  next_fcreq = fcreq;

  if (cntcr_write_cntctl)
    if (pwdata_enabled_cntctl[8] == 1'b1)
      next_fcreq = pwdata_enabled_cntctl[8];

end

assign next_hdbg          = cntcr_write_cntctl   ? pwdata_enabled_cntctl[1] : hdbg;
assign next_enable_cnt    = cntcr_write_cntctl   ? pwdata_enabled_cntctl[0] : enable_cnt;

assign next_cntfid0       = cntfid0_write_cntctl ? pwdata_enabled_cntctl : cntfid0;

assign next_ensync        = cntscr_write_cntctl  ? pwdata_enabled_cntctl[0] : ensync;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      fcreq       <=  1'b0;
      hdbg        <=  1'b0;
      enable_cnt  <=  1'b0;
      cntfid0     <=  32'h0000_0000;
      ensync      <=  1'b0;
    end
  else
    begin
      fcreq       <=  next_fcreq;
      hdbg        <=  next_hdbg;
      enable_cnt  <=  next_enable_cnt;
      cntfid0     <=  next_cntfid0;
      ensync      <=  next_ensync;
    end

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    fcack       <=  1'b0;
  else
    fcack       <=  fcreq;
  

assign preload_cnt_data          = pwdata_enabled_cntctl;



always @*
  case ({cntcr_read_cntctl, cntsr_read_cntctl, cntcvl_read_cntctl, cntcvu_read_cntctl, cntfid0_read_cntctl,
         cntfidend_read_cntctl, cntscr_read_cntctl, cntsvl_read_cntctl, cntsvu_read_cntctl,
         cntpidr4_read_cntctl, cntpidr0_read_cntctl, cntpidr1_read_cntctl, cntpidr2_read_cntctl, cntpidr3_read_cntctl,
         cntcidr0_read_cntctl, cntcidr1_read_cntctl, cntcidr2_read_cntctl,
         cntcidr3_read_cntctl})
    18'b10_0000_0000_0000_0000 : next_prdata_cntctl = {23'h0000_00, fcreq, 6'h00, hdbg, enable_cnt};
    18'b01_0000_0000_0000_0000 : next_prdata_cntctl = {23'h00_0000, fcack, 6'h00, dbgh, 1'b0};
    18'b00_1000_0000_0000_0000 : next_prdata_cntctl = tsvalueb[31:0];
    18'b00_0100_0000_0000_0000 : next_prdata_cntctl = tsvalueb[63:32];
    18'b00_0010_0000_0000_0000 : next_prdata_cntctl = cntfid0;
    18'b00_0001_0000_0000_0000 : next_prdata_cntctl = `GCOUNTER_CNTFIDEND;
    18'b00_0000_1000_0000_0000 : next_prdata_cntctl = {31'h0000_0000, ensync};
    18'b00_0000_0100_0000_0000 : next_prdata_cntctl = cntsv[31:0];
    18'b00_0000_0010_0000_0000 : next_prdata_cntctl = cntsv[63:32];
    18'b00_0000_0001_0000_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr4};
    18'b00_0000_0000_1000_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr0_control};
    18'b00_0000_0000_0100_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr1};
    18'b00_0000_0000_0010_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr2};
    18'b00_0000_0000_0001_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr3};
    18'b00_0000_0000_0000_1000 : next_prdata_cntctl = {24'h00_0000, cntcidrall[7:0]};
    18'b00_0000_0000_0000_0100 : next_prdata_cntctl = {24'h00_0000, cntcidrall[15:8]};
    18'b00_0000_0000_0000_0010 : next_prdata_cntctl = {24'h00_0000, cntcidrall[23:16]};
    18'b00_0000_0000_0000_0001 : next_prdata_cntctl = {24'h00_0000, cntcidrall[31:24]};
                 default : next_prdata_cntctl = 32'h0000_0000;
  endcase

always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    PRDATACNTCONTROL <= 32'h0000_0000;
  else
    PRDATACNTCONTROL <= next_prdata_cntctl;
end



assign paddr_enabled_cntrd  = PSELCNTREAD ? PADDRCNTREAD : 10'b0000000000;

assign read_enable_cntrd    = PSELCNTREAD & (~PWRITECNTREAD) & (~PENABLECNTREAD);

assign PREADYCNTREAD   = 1'b1;
assign PSLVERRCNTREAD  = 1'b0;



assign cntcvlw_read_cntrd   = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCVLW_ADDR));
assign cntcvup_read_cntrd   = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCVUP_ADDR));

assign cntpidr4_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTPIDR4_ADDR));
assign cntpidr0_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTPIDR0_ADDR));
assign cntpidr1_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTPIDR1_ADDR));
assign cntpidr2_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTPIDR2_ADDR));
assign cntpidr3_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTPIDR3_ADDR));

assign cntcidr0_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCIDR0_ADDR));
assign cntcidr1_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCIDR1_ADDR));
assign cntcidr2_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCIDR2_ADDR));
assign cntcidr3_read_cntrd  = (read_enable_cntrd && (paddr_enabled_cntrd == `CNTCIDR3_ADDR));


always @*
  case ({cntcvlw_read_cntrd, cntcvup_read_cntrd, cntpidr4_read_cntrd, cntpidr0_read_cntrd,
          cntpidr1_read_cntrd, cntpidr2_read_cntrd, cntpidr3_read_cntrd, cntcidr0_read_cntrd,
        cntcidr1_read_cntrd, cntcidr2_read_cntrd, cntcidr3_read_cntrd})
    11'b100_0000_0000 : next_prdata_cntrd = tsvalueb[31:0];
    11'b010_0000_0000 : next_prdata_cntrd = tsvalueb[63:32];
    11'b001_0000_0000 : next_prdata_cntrd = {24'h00_0000, cntpidr4};
    11'b000_1000_0000 : next_prdata_cntrd = {24'h00_0000, cntpidr0_read};
    11'b000_0100_0000 : next_prdata_cntrd = {24'h00_0000, cntpidr1};
    11'b000_0010_0000 : next_prdata_cntrd = {24'h00_0000, cntpidr2};
    11'b000_0001_0000 : next_prdata_cntrd = {24'h00_0000, cntpidr3};
    11'b000_0000_1000 : next_prdata_cntrd = {24'h00_0000, cntcidrall[7:0]};
    11'b000_0000_0100 : next_prdata_cntrd = {24'h00_0000, cntcidrall[15:8]};
    11'b000_0000_0010 : next_prdata_cntrd = {24'h00_0000, cntcidrall[23:16]};
    11'b000_0000_0001 : next_prdata_cntrd = {24'h00_0000, cntcidrall[31:24]};
             default : next_prdata_cntrd = 32'h0000_0000;
  endcase

always @(posedge PCLK or negedge PRESETn)
begin
  if (~PRESETn)
    PRDATACNTREAD <= 32'h0000_0000;
  else
    PRDATACNTREAD <= next_prdata_cntrd;
end

`undef CNTCR_ADDR
`undef CNTSR_ADDR
`undef CNTCVL_ADDR
`undef CNTCVU_ADDR
`undef CNTFID0_ADDR
`undef CNTFIDEND_ADDR
`undef CNTSCR_ADDR
`undef CNTSVL_ADDR
`undef CNTSVU_ADDR
`undef CNTCVLW_ADDR
`undef CNTCVUP_ADDR
`undef CNTPIDR4_ADDR
`undef CNTPIDR0_ADDR
`undef CNTPIDR1_ADDR
`undef CNTPIDR2_ADDR
`undef CNTPIDR3_ADDR
`undef CNTCIDR0_ADDR
`undef CNTCIDR1_ADDR
`undef CNTCIDR2_ADDR
`undef CNTCIDR3_ADDR
`undef GCOUNTER_PART_0_CONTROL
`undef GCOUNTER_PART_0_READ
`undef GCOUNTER_PART_1
`undef GCOUNTER_DES_0
`undef GCOUNTER_DES_1
`undef GCOUNTER_DES_2
`undef GCOUNTER_SIZE
`undef GCOUNTER_JEDEC
`undef GCOUNTER_CMOD
`undef GCOUNTER_REVAND
`undef GCOUNTER_COMPID
`undef GCOUNTER_CNTFIDEND

endmodule

