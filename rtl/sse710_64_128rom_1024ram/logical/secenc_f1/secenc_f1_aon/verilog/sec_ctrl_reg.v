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


module sec_ctrl_reg #(
  parameter   [15:0] SEC_ENC_ROM_SIZE = 16'd32,   
  parameter   [15:0] SEC_ENC_RAM_SIZE = 16'd128   
) (
  input  wire        clk,
  input  wire        rst_n,

  input  wire [11:0] paddr,
  input  wire [31:0] pwdata,
  input  wire        pwrite,
  input  wire        psel,
  input  wire        penable,
  output wire [31:0] prdata,

  input wire  [2:0]  se_rst_syn,
  input wire  [4:0]  cm0_clkdiv_cur,
  output wire        pwr_gate_en,
  output wire  [4:0] clk_divider,
  output wire        se_rst_msk_ca_err_msk
);


  localparam [9:0] ADDR_SE_RST_SYN           = 12'h000 >> 2;
  localparam [9:0] ADDR_SE_RST_MSK           = 12'h004 >> 2;
  localparam [9:0] ADDR_SE_PWR_CTRL          = 12'h008 >> 2;
  localparam [9:0] ADDR_SE_GP0               = 12'h014 >> 2;
  localparam [9:0] ADDR_SE_GP1               = 12'h018 >> 2;
  localparam [9:0] ADDR_SE_GP2               = 12'h01C >> 2;
  localparam [9:0] ADDR_SE_GP3               = 12'h020 >> 2;
  localparam [9:0] ADDR_SE_CLK_DIV           = 12'h030 >> 2;
  localparam [9:0] ADDR_SE_BLD_CFG           = 12'h0F8 >> 2;
  localparam [9:0] ADDR_PID4                 = 12'hFD0 >> 2;
  localparam [9:0] ADDR_PID0                 = 12'hFE0 >> 2;
  localparam [9:0] ADDR_PID1                 = 12'hFE4 >> 2;
  localparam [9:0] ADDR_PID2                 = 12'hFE8 >> 2;
  localparam [9:0] ADDR_PID3                 = 12'hFEC >> 2;
  localparam [9:0] ADDR_COMPID0              = 12'hFF0 >> 2;
  localparam [9:0] ADDR_COMPID1              = 12'hFF4 >> 2;
  localparam [9:0] ADDR_COMPID2              = 12'hFF8 >> 2;
  localparam [9:0] ADDR_COMPID3              = 12'hFFC >> 2;


  wire  [9:0] addr_int;
  wire        writeen;
  wire        readen;
  reg  [31:0] rdata_int;
  wire [31:0] prdata_nxt;
  reg  [31:0] prdata_i;


  wire  [3:0] pid2_eco;
  wire  [3:0] pid3_eco;

  wire [31:0] data_se_rst_syn;                   
  reg         data_se_rst_msk;                   
  reg         data_se_pwr_ctrl;                  
  reg  [31:0] data_se_gp0;                       
  reg  [31:0] data_se_gp1;                       
  reg  [31:0] data_se_gp2;                       
  reg  [31:0] data_se_gp3;                       
  reg   [4:0] data_se_clk_div;                   
  wire [31:0] data_se_bld_cfg;                   
  wire [31:0] data_pid4;                         
  wire [31:0] data_pid0;                         
  wire [31:0] data_pid1;                         
  wire [31:0] data_pid2;                         
  wire [31:0] data_pid3;                         
  wire [31:0] data_compid0;                      
  wire [31:0] data_compid1;                      
  wire [31:0] data_compid2;                      
  wire [31:0] data_compid3;                      

  reg         data_se_rst_msk_nxt;
  reg         data_se_pwr_ctrl_nxt;
  reg  [31:0] data_se_gp0_nxt;
  reg  [31:0] data_se_gp1_nxt;
  reg  [31:0] data_se_gp2_nxt;
  reg  [31:0] data_se_gp3_nxt;
  reg   [4:0] data_se_clk_div_nxt;

  wire  [2:0] se_rst_syn_ss;
  
  wire [4:0] cm0_clkdiv_cur_ss;
  reg  [4:0] cm0_clkdiv_cur_sw_reg;
  wire       cm0_clkdiv_cur_sw_reg_en;  
  
  wire        unused;

  assign unused = &paddr[1:0];


  assign addr_int = psel ? {paddr[11:2]} : 10'b0;
  assign writeen  = psel & pwrite & (~penable);
  assign readen   = psel & (~pwrite) & (~penable);

  
  assign data_se_rst_syn = {29'h0, se_rst_syn_ss};
  assign data_se_bld_cfg = {SEC_ENC_RAM_SIZE, SEC_ENC_ROM_SIZE};
  assign data_pid4       = 32'h0000_0004;
  assign data_pid0       = 32'h0000_0079; 
  assign data_pid1       = 32'h0000_00b0;
  assign data_pid2       = {24'h0, pid2_eco, 4'hb};
  assign data_pid3       = {24'h0, pid3_eco, 4'h0};
  assign data_compid0    = 32'h0000_000d;
  assign data_compid1    = 32'h0000_00f0;
  assign data_compid2    = 32'h0000_0005;
  assign data_compid3    = 32'h0000_00b1;

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_0 (
    .ecorevnum (pid2_eco)
  );

  sec_ecorevnum #(
    .WIDTH     (4),
    .ECOREVVAL (4'b0)
  ) u_sec_ecorevnum_1 (
    .ecorevnum (pid3_eco)
  );

  
  always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
      begin
       data_se_rst_msk     <=  1'b0;
       data_se_pwr_ctrl    <=  1'b0;
       data_se_gp0         <= 32'h0000_0000;
       data_se_gp1         <= 32'h0000_0000;
       data_se_gp2         <= 32'h0000_0000;
       data_se_gp3         <= 32'h0000_0000;
       data_se_clk_div     <=  5'b00001;
      end
    else
      begin
       data_se_rst_msk     <= data_se_rst_msk_nxt;
       data_se_pwr_ctrl    <= data_se_pwr_ctrl_nxt;
       data_se_gp0         <= data_se_gp0_nxt;
       data_se_gp1         <= data_se_gp1_nxt;
       data_se_gp2         <= data_se_gp2_nxt;
       data_se_gp3         <= data_se_gp3_nxt;
       data_se_clk_div     <= data_se_clk_div_nxt;
      end
   end
   
  sec_cdc_capt_sync u_sec_cdc_capt_sync_0 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (se_rst_syn[0]),
    .q          (se_rst_syn_ss[0])
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_1 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (se_rst_syn[1]),
    .q          (se_rst_syn_ss[1])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_2 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (se_rst_syn[2]),
    .q          (se_rst_syn_ss[2])
  );


  always @(*)
    begin
      data_se_rst_msk_nxt     = data_se_rst_msk;
      data_se_pwr_ctrl_nxt    = data_se_pwr_ctrl;
      data_se_gp0_nxt         = data_se_gp0;
      data_se_gp1_nxt         = data_se_gp1;
      data_se_gp2_nxt         = data_se_gp2;
      data_se_gp3_nxt         = data_se_gp3;
      data_se_clk_div_nxt     = data_se_clk_div;
      if (writeen)
        case (addr_int)
          ADDR_SE_RST_MSK     : data_se_rst_msk_nxt     = pwdata[2];
          ADDR_SE_PWR_CTRL    : data_se_pwr_ctrl_nxt    = pwdata[0];
          ADDR_SE_GP0         : data_se_gp0_nxt         = pwdata[31:0];
          ADDR_SE_GP1         : data_se_gp1_nxt         = pwdata[31:0];
          ADDR_SE_GP2         : data_se_gp2_nxt         = pwdata[31:0];
          ADDR_SE_GP3         : data_se_gp3_nxt         = pwdata[31:0];
          ADDR_SE_CLK_DIV     : data_se_clk_div_nxt     = pwdata[4:0];
        endcase
    end


  always @(*)
    begin
      rdata_int =  (&(addr_int ^ (~addr_int))) ? 32'h0000_0000 : 32'hFFFF_FFFF;  
      case (addr_int)
        ADDR_SE_RST_SYN       : rdata_int = data_se_rst_syn;
        ADDR_SE_RST_MSK       : rdata_int = {29'b0, data_se_rst_msk, 2'b0};
        ADDR_SE_PWR_CTRL      : rdata_int = {31'b0, data_se_pwr_ctrl};
        ADDR_SE_GP0           : rdata_int = data_se_gp0;
        ADDR_SE_GP1           : rdata_int = data_se_gp1;
        ADDR_SE_GP2           : rdata_int = data_se_gp2;
        ADDR_SE_GP3           : rdata_int = data_se_gp3;
        ADDR_SE_CLK_DIV       : rdata_int = {11'b0, cm0_clkdiv_cur_sw_reg, 11'b0, data_se_clk_div};
        ADDR_SE_BLD_CFG       : rdata_int = data_se_bld_cfg;
        ADDR_PID4             : rdata_int = data_pid4;
        ADDR_PID0             : rdata_int = data_pid0;
        ADDR_PID1             : rdata_int = data_pid1;
        ADDR_PID2             : rdata_int = data_pid2;
        ADDR_PID3             : rdata_int = data_pid3;
        ADDR_COMPID0          : rdata_int = data_compid0;
        ADDR_COMPID1          : rdata_int = data_compid1;
        ADDR_COMPID2          : rdata_int = data_compid2;
        ADDR_COMPID3          : rdata_int = data_compid3;
      endcase
    end

  assign prdata_nxt = readen ? rdata_int : 32'b0;
  
  
  genvar idx;
  generate for (idx = 0; idx < 5; idx = idx + 1)
  begin: sync_loop    
    sec_cdc_capt_sync u_sec_cdc_capt_sync (
      .clk        (clk),
      .nreset     (rst_n),
      .d_async    (cm0_clkdiv_cur[idx]),
      .q          (cm0_clkdiv_cur_ss[idx])
    );
  end 
  endgenerate
  
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      cm0_clkdiv_cur_sw_reg <= 5'h00;
    else if (cm0_clkdiv_cur_sw_reg_en)
      cm0_clkdiv_cur_sw_reg <= cm0_clkdiv_cur_ss; 
  
  assign cm0_clkdiv_cur_sw_reg_en = (cm0_clkdiv_cur_ss == data_se_clk_div) ? 1'b1 : 1'b0;  
    
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      prdata_i <= 32'h0000_0000;
    else if (psel)
      prdata_i <= prdata_nxt;
      
  
  assign prdata                = prdata_i;
  assign se_rst_msk_ca_err_msk = data_se_rst_msk;
  assign pwr_gate_en           = data_se_pwr_ctrl;
  assign clk_divider           = data_se_clk_div[4:0];

endmodule
