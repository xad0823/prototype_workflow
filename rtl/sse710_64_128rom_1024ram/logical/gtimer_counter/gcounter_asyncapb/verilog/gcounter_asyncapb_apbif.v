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


module gcounter_asyncapb_apbif (
  input  wire        PCLK,                      
  input  wire        PRESETn,                   
  
  input  wire [11:2] PADDRCNTCONTROL,           
  input  wire        PSELCNTCONTROL,            
  input  wire        PENABLECNTCONTROL,         
  input  wire        PWRITECNTCONTROL,          
  input  wire [31:0] PWDATACNTCONTROL,          
  
  output reg         PREADYCNTCONTROL,          
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
  input  wire        dbgh,                      
  
  output reg         cntcr_write_in_progress,   
  input  wire        cntcr_write_complete,
  output reg         hdbg,                      
  output reg         enable_cnt,                
  
  output reg         cntcvl_write_in_progress,  
  input  wire        cntcvl_write_complete,
  output reg         cntcvu_write_in_progress,  
  input  wire        cntcvu_write_complete,
  output reg  [31:0] preload_cntcvl_data,       
  output reg  [31:0] preload_cntcvu_data,       
  
  input  wire [63:0] TSVALUEB,                  
  input  wire        cclktoggle                 
);






wire        next_cntcvl_new_wip;
wire        next_cntcvu_new_wip;

`define CNTCR_ADDR      10'b0000000000
`define CNTSR_ADDR      10'b0000000001
`define CNTCVL_ADDR     10'b0000000010
`define CNTCVU_ADDR     10'b0000000011
`define CNTFID0_ADDR    10'b0000001000
`define CNTFIDEND_ADDR  10'b0000001001

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


`define GCOUNTER_PART_0_CONTROL     8'b1001_1110
`define GCOUNTER_PART_0_READ        8'b1001_1111
`define GCOUNTER_PART_1             4'b0000
`define GCOUNTER_DES_0              4'b1011
`define GCOUNTER_DES_1              3'b011
`define GCOUNTER_DES_2              4'b0100
`define GCOUNTER_SIZE               4'b0000
`define GCOUNTER_JEDEC              1'b1
`define GCOUNTER_CMOD               4'b0000
`define GCOUNTER_REVAND             4'b0000

`define GCOUNTER_COMPID       32'hB105F00D

`define GCOUNTER_CNTFIDEND         32'h0000_0000

wire [11:2] paddr_enabled_cntctl;       
wire [31:0] pwdata_enabled_cntctl;      
wire        write_setup_cntctl;
wire        write_enable_cntctl;
wire        read_enable_cntctl;
reg  [31:0] next_prdata_cntctl;

wire        cntcr_pready_low_n;
wire        cntcvl_pready_low_n;
wire        cntcvu_pready_low_n;
wire        internal_cntcvl_pready_low_n;
wire        internal_cntcvu_pready_low_n;
wire        next_preadycntcontrol;

wire        cntcvl_wsetup_cntctl;
wire        cntcvu_wsetup_cntctl;
wire        cntfid0_wsetup_cntctl;
wire        cntcr_wsetup_cntctl;
reg         cntcr_access1_cntctl;
reg         cntcvl_access1_cntctl;
reg         cntcvu_access1_cntctl;

wire        cntcvl_write_cntctl;
wire        cntcvu_write_cntctl;
wire        cntfid0_write_cntctl;
wire        cntcr_write_cntctl;

wire        next_cntcr_wr_in_prog;
reg         cntcr_wr_in_prog;
wire        next_cntcr_write_in_progress;
wire        cntcr_write_complete_pulse;
wire        cntcr_latch_wdata;

wire        next_cntcvl_wr_in_prog;
reg         cntcvl_wr_in_prog;
wire        next_cntcvl_write_in_progress;
wire        cntcvl_write_complete_pulse;
wire        cntcvl_latch_wdata;

wire        next_cntcvu_wr_in_prog;
reg         cntcvu_wr_in_prog;
wire        next_cntcvu_write_in_progress;
wire        cntcvu_write_complete_pulse;
wire        cntcvu_latch_wdata;


wire [31:0] next_preload_cntcvl_data;
wire [31:0] next_preload_cntcvu_data;

wire        cntcr_read_cntctl;
wire        cntsr_read_cntctl;
wire        cntcvl_read_cntctl;
wire        cntcvu_read_cntctl;
wire        cntfid0_read_cntctl;
wire        cntfidend_read_cntctl;

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


wire         dbgh_ss;

wire        cclktoggle_sync;
wire [63:0] next_tsvalueb_rd_data_val;
reg  [63:0] tsvalueb_rd_data_val;
wire [31:0] cntcvl_read_val;
wire [31:0] cntcvu_read_val;

reg         next_fcreq;
wire        next_hdbg;
wire        next_enable_cnt;
wire [31:0] next_cntfid0;


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

assign write_setup_cntctl    = PSELCNTCONTROL & PWRITECNTCONTROL & (~PENABLECNTCONTROL);
assign write_enable_cntctl   = PSELCNTCONTROL & PWRITECNTCONTROL & PENABLECNTCONTROL;

assign read_enable_cntctl    = PSELCNTCONTROL & (~PWRITECNTCONTROL) & (~PENABLECNTCONTROL);

assign PSLVERRCNTCONTROL  = 1'b0;

assign cntcr_pready_low_n   =  ~(cntcr_wsetup_cntctl  | (cntcr_write_cntctl & cntcr_access1_cntctl)   | next_cntcr_wr_in_prog);
assign cntcvl_pready_low_n  =  ~(cntcvl_wsetup_cntctl | (cntcvl_write_cntctl & cntcvl_access1_cntctl) | next_cntcvl_wr_in_prog);
assign cntcvu_pready_low_n  =  ~(cntcvu_wsetup_cntctl | (cntcvu_write_cntctl & cntcvu_access1_cntctl) | next_cntcvu_wr_in_prog);


assign next_preadycntcontrol = cntcr_pready_low_n & cntcvl_pready_low_n & cntcvu_pready_low_n;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    PREADYCNTCONTROL   <=  1'b1;
  else
    PREADYCNTCONTROL   <=  next_preadycntcontrol;
  
  
assign cntcr_wsetup_cntctl    = (write_setup_cntctl & (paddr_enabled_cntctl == `CNTCR_ADDR));
assign cntfid0_wsetup_cntctl  = (write_setup_cntctl & (paddr_enabled_cntctl == `CNTFID0_ADDR));

assign cntcvl_wsetup_cntctl   = (write_setup_cntctl & (paddr_enabled_cntctl == `CNTCVL_ADDR) & (~enable_cnt));
assign cntcvu_wsetup_cntctl   = (write_setup_cntctl & (paddr_enabled_cntctl == `CNTCVU_ADDR) & (~enable_cnt));

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntcr_access1_cntctl    <=  1'b0;
      cntcvl_access1_cntctl   <=  1'b0;
      cntcvu_access1_cntctl   <=  1'b0;
    end
  else
    begin
      cntcr_access1_cntctl    <=  cntcr_wsetup_cntctl;
      cntcvl_access1_cntctl   <=  cntcvl_wsetup_cntctl;
      cntcvu_access1_cntctl   <=  cntcvu_wsetup_cntctl;
    end


assign cntcr_write_cntctl    = (write_enable_cntctl & (paddr_enabled_cntctl == `CNTCR_ADDR));
assign cntfid0_write_cntctl  = (write_enable_cntctl & (paddr_enabled_cntctl == `CNTFID0_ADDR));

assign cntcvl_write_cntctl   = (write_enable_cntctl & (paddr_enabled_cntctl == `CNTCVL_ADDR) & (~enable_cnt));
assign cntcvu_write_cntctl   = (write_enable_cntctl & (paddr_enabled_cntctl == `CNTCVU_ADDR) & (~enable_cnt));


assign cntcr_read_cntctl     = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCR_ADDR));
assign cntsr_read_cntctl     = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTSR_ADDR));
assign cntcvl_read_cntctl    = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCVL_ADDR));
assign cntcvu_read_cntctl    = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCVU_ADDR));
assign cntfid0_read_cntctl   = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTFID0_ADDR));
assign cntfidend_read_cntctl = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTFIDEND_ADDR));

assign cntpidr4_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTPIDR4_ADDR));
assign cntpidr0_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTPIDR0_ADDR));
assign cntpidr1_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTPIDR1_ADDR));
assign cntpidr2_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTPIDR2_ADDR));
assign cntpidr3_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTPIDR3_ADDR));

assign cntcidr0_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCIDR0_ADDR));
assign cntcidr1_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCIDR1_ADDR));
assign cntcidr2_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCIDR2_ADDR));
assign cntcidr3_read_cntctl  = (read_enable_cntctl & (paddr_enabled_cntctl == `CNTCIDR3_ADDR));


assign next_cntcr_wr_in_prog = (~cntcr_write_complete_pulse & ((cntcr_write_cntctl & cntcr_access1_cntctl) | cntcr_wr_in_prog));

assign cntcr_latch_wdata = next_cntcr_wr_in_prog & (~cntcr_wr_in_prog);

assign next_hdbg        = cntcr_latch_wdata ? pwdata_enabled_cntctl[1] : hdbg;
assign next_enable_cnt  = cntcr_latch_wdata ? pwdata_enabled_cntctl[0] : enable_cnt;

always @*
begin
  next_fcreq = fcreq;

  if (cntcr_latch_wdata)
    if (pwdata_enabled_cntctl[8] == 1'b1)
      next_fcreq = pwdata_enabled_cntctl[8];
end

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      fcreq       <=  1'b0;
      hdbg        <=  1'b0;
      enable_cnt  <=  1'b0;
    end
  else
    begin
      fcreq       <=  next_fcreq;
      hdbg        <=  next_hdbg;
      enable_cnt  <=  next_enable_cnt;
    end

gct_syncpulse u_gct_syncpulse_cntcr_sync (
                    .clk     ( PCLK                       ),
                    .reset_n ( PRESETn                    ),
                    .data_i  ( cntcr_write_complete       ),
                    .pulse_o ( cntcr_write_complete_pulse ),
                    .ack_o   (                    )
                    );


assign next_cntfid0       = cntfid0_write_cntctl ? pwdata_enabled_cntctl : cntfid0;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      cntfid0     <=  32'h0000_0000;
    end
  else
    begin
      cntfid0     <=  next_cntfid0;
    end


assign next_cntcvl_wr_in_prog = (~cntcvl_write_complete_pulse & ((cntcvl_write_cntctl & cntcvl_access1_cntctl) | cntcvl_wr_in_prog));
assign next_cntcvu_wr_in_prog = (~cntcvu_write_complete_pulse & ((cntcvu_write_cntctl & cntcvu_access1_cntctl) | cntcvu_wr_in_prog));

always @(posedge PCLK or negedge PRESETn)
  if ( ~PRESETn )
    begin
      cntcr_wr_in_prog   <=  1'b0;
      cntcvl_wr_in_prog  <=  1'b0;
      cntcvu_wr_in_prog  <=  1'b0;
    end
  else
    begin
      cntcr_wr_in_prog   <=  next_cntcr_wr_in_prog;
      cntcvl_wr_in_prog  <=  next_cntcvl_wr_in_prog;
      cntcvu_wr_in_prog  <=  next_cntcvu_wr_in_prog;
    end

assign cntcvl_latch_wdata = next_cntcvl_wr_in_prog & (~cntcvl_wr_in_prog);
assign cntcvu_latch_wdata = next_cntcvu_wr_in_prog & (~cntcvu_wr_in_prog);

assign next_cntcr_write_in_progress   = cntcr_latch_wdata  ? ~cntcr_write_in_progress  : cntcr_write_in_progress;
assign next_cntcvl_write_in_progress  = cntcvl_latch_wdata ? ~cntcvl_write_in_progress : cntcvl_write_in_progress;
assign next_cntcvu_write_in_progress  = cntcvu_latch_wdata ? ~cntcvu_write_in_progress : cntcvu_write_in_progress;

always @(posedge PCLK or negedge PRESETn)
  if ( ~PRESETn )
    begin
      cntcr_write_in_progress  <= 1'b0;
      cntcvl_write_in_progress <= 1'b0;
      cntcvu_write_in_progress <= 1'b0;
    end
  else
    begin
      cntcr_write_in_progress  <= next_cntcr_write_in_progress;
      cntcvl_write_in_progress <= next_cntcvl_write_in_progress;
      cntcvu_write_in_progress <= next_cntcvu_write_in_progress;
    end


gct_syncpulse u_gct_syncpulse_cntcvl_sync (
                    .clk     ( PCLK                        ),
                    .reset_n ( PRESETn                     ),
                    .data_i  ( cntcvl_write_complete       ),
                    .pulse_o ( cntcvl_write_complete_pulse ),
                    .ack_o   (                     )
                    );


gct_syncpulse u_gct_syncpulse_cntcvu_sync (
                    .clk     ( PCLK                        ),
                    .reset_n ( PRESETn                     ),
                    .data_i  ( cntcvu_write_complete       ),
                    .pulse_o ( cntcvu_write_complete_pulse ),
                    .ack_o   (                     )
                    );


assign next_preload_cntcvl_data = cntcvl_latch_wdata ? pwdata_enabled_cntctl : preload_cntcvl_data;
assign next_preload_cntcvu_data = cntcvu_latch_wdata ? pwdata_enabled_cntctl : preload_cntcvu_data;

always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    begin
      preload_cntcvl_data  <=  32'h0000_0000;
      preload_cntcvu_data  <=  32'h0000_0000;
    end
  else
    begin
      preload_cntcvl_data  <=  next_preload_cntcvl_data;
      preload_cntcvu_data  <=  next_preload_cntcvu_data;
    end


always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    fcack       <=  1'b0;
  else
    fcack       <=  fcreq;
    
    
  gct_synchronizer u_dbgh_ss ( .clk( PCLK), .reset_n(PRESETn), .data_i(dbgh), .data_o(dbgh_ss) );
  
    

gct_syncpulse u_gct_syncpulse_cclktoggle_sync (
                    .clk     ( PCLK                        ),
                    .reset_n ( PRESETn                     ),
                    .data_i  ( cclktoggle                  ),
                    .pulse_o ( cclktoggle_sync             ),
                    .ack_o   (                     )
                    );


  wire [63:0] tsvalueb_glitchless;
  
  gtimer_counter_glitch_gate 
  #(
      .WIDTH(64)
   )
  u_tsvalueb 
  (
     .async_in    (TSVALUEB),
     .async_out   (tsvalueb_glitchless),
     .input_valid (cclktoggle_sync)
  );

  assign next_tsvalueb_rd_data_val = cclktoggle_sync ? tsvalueb_glitchless : tsvalueb_rd_data_val; 
  
always @(posedge PCLK or negedge PRESETn)
  if (~PRESETn)
    tsvalueb_rd_data_val <= 64'h0000_0000_0000_0000;
  else
    tsvalueb_rd_data_val <= next_tsvalueb_rd_data_val;

assign  cntcvl_read_val = cntcvl_wr_in_prog ? preload_cntcvl_data : tsvalueb_rd_data_val[31:0];
assign  cntcvu_read_val = cntcvu_wr_in_prog ? preload_cntcvu_data : tsvalueb_rd_data_val[63:32];



always @*
  case ({cntcr_read_cntctl, cntsr_read_cntctl, cntcvl_read_cntctl, cntcvu_read_cntctl, cntfid0_read_cntctl,
         cntfidend_read_cntctl,
         cntpidr4_read_cntctl, cntpidr0_read_cntctl, cntpidr1_read_cntctl, cntpidr2_read_cntctl, cntpidr3_read_cntctl,
         cntcidr0_read_cntctl, cntcidr1_read_cntctl, cntcidr2_read_cntctl,
         cntcidr3_read_cntctl})
    15'b100_0000_0000_0000 : next_prdata_cntctl = {23'h0000_00, fcreq, 6'h00, hdbg, enable_cnt};
    15'b010_0000_0000_0000 : next_prdata_cntctl = {23'h00_0000, fcack, 6'h00, dbgh_ss, 1'b0};
    15'b001_0000_0000_0000 : next_prdata_cntctl = cntcvl_read_val;
    15'b000_1000_0000_0000 : next_prdata_cntctl = cntcvu_read_val;
    15'b000_0100_0000_0000 : next_prdata_cntctl = cntfid0;
    15'b000_0010_0000_0000 : next_prdata_cntctl = `GCOUNTER_CNTFIDEND;
    15'b000_0001_0000_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr4};
    15'b000_0000_1000_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr0_control};
    15'b000_0000_0100_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr1};
    15'b000_0000_0010_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr2};
    15'b000_0000_0001_0000 : next_prdata_cntctl = {24'h00_0000, cntpidr3};
    15'b000_0000_0000_1000 : next_prdata_cntctl = {24'h00_0000, cntcidrall[7:0]};
    15'b000_0000_0000_0100 : next_prdata_cntctl = {24'h00_0000, cntcidrall[15:8]};
    15'b000_0000_0000_0010 : next_prdata_cntctl = {24'h00_0000, cntcidrall[23:16]};
    15'b000_0000_0000_0001 : next_prdata_cntctl = {24'h00_0000, cntcidrall[31:24]};
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
    11'b100_0000_0000 : next_prdata_cntrd = cntcvl_read_val;
    11'b010_0000_0000 : next_prdata_cntrd = cntcvu_read_val;
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

