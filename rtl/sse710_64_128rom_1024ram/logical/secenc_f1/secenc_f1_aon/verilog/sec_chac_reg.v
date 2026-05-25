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


module sec_chac_reg (
  input  wire        clk,
  input  wire        rst_n,

  input  wire [11:0] paddr,
  input  wire [31:0] pwdata,
  input  wire        pwrite,
  input  wire        psel,
  input  wire        penable,
  output wire [31:0] prdata,

  input  wire  [1:0] host_rst_ack,
  input  wire  [4:0] soc_rst_synd,
  input  wire [31:0] int_st0,
  input  wire [31:0] int_st1,
  input  wire  [7:0] int_st2,
  input  wire  [5:0] chs_pwr_st,
  input  wire        host_cpuwait_wen,
  output wire  [7:0] entry_delay,
  input  wire  [1:0] clkselect_cur,
  input  wire  [4:0] clkdiv_cur,
  input  wire        sysplllock_st,
  output wire        host_rst_req,
  output wire        host_cpuwait,
  output wire        soc_rst_req,
  output wire [31:0] int_msk0,
  output wire [31:0] int_msk1,
  output wire [31:0] int_msk2,
  output wire  [6:0] chs_pwr_req,
  output wire  [1:0] clkselect,
  output wire  [4:0] clkdiv,
  output wire        clkforce
);


  localparam [9:0] ADDR_HOST_SYS_RST_CTRL     = 12'h000 >> 2;
  localparam [9:0] ADDR_HOST_SYS_RST_ST       = 12'h004 >> 2;
  localparam [9:0] ADDR_SOC_RST_CTRL          = 12'h008 >> 2;
  localparam [9:0] ADDR_SOC_RST_SYN           = 12'h00C >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_ST0   = 12'h010 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_ST1   = 12'h014 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_ST2   = 12'h018 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_ST3   = 12'h01C >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_MSK0  = 12'h020 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_MSK1  = 12'h024 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_MSK2  = 12'h028 >> 2;
  localparam [9:0] ADDR_SEC_ENC_CHS_INT_MSK3  = 12'h02C >> 2;
  localparam [9:0] ADDR_CHS_PWR_REQ           = 12'h400 >> 2;
  localparam [9:0] ADDR_CHS_PWR_ST            = 12'h404 >> 2;
  localparam [9:0] ADDR_SECENCCLK_CTRL        = 12'h800 >> 2;
  localparam [9:0] ADDR_SECENCCLK_DIV         = 12'h804 >> 2;
  localparam [9:0] ADDR_CLOCKFORCE_ST         = 12'hA00 >> 2;
  localparam [9:0] ADDR_CLOCKFORCE_SET        = 12'hA04 >> 2;
  localparam [9:0] ADDR_CLOCKFORCE_CLR        = 12'hA08 >> 2;
  localparam [9:0] ADDR_SEC_ENC_PLL_ST        = 12'hA10 >> 2;
  localparam [9:0] ADDR_PID4                  = 12'hFD0 >> 2;
  localparam [9:0] ADDR_PID5                  = 12'hFD4 >> 2;
  localparam [9:0] ADDR_PID6                  = 12'hFD8 >> 2;
  localparam [9:0] ADDR_PID7                  = 12'hFDC >> 2;
  localparam [9:0] ADDR_PID0                  = 12'hFE0 >> 2;
  localparam [9:0] ADDR_PID1                  = 12'hFE4 >> 2;
  localparam [9:0] ADDR_PID2                  = 12'hFE8 >> 2;
  localparam [9:0] ADDR_PID3                  = 12'hFEC >> 2;
  localparam [9:0] ADDR_ID0                   = 12'hFF0 >> 2;
  localparam [9:0] ADDR_ID1                   = 12'hFF4 >> 2;
  localparam [9:0] ADDR_ID2                   = 12'hFF8 >> 2;
  localparam [9:0] ADDR_ID3                   = 12'hFFC >> 2;
  
  
  reg   [1:0] data_host_sys_rst_ctrl;    
  wire [31:0] data_host_sys_rst_st;      
  reg         data_soc_rst_ctrl;         
  wire [31:0] data_soc_rst_syn;          
  wire [31:0] data_sec_enc_chs_int_st0;  
  wire [31:0] data_sec_enc_chs_int_st1;  
  wire [31:0] data_sec_enc_chs_int_st2;  
  wire [31:0] data_sec_enc_chs_int_st3;  
  reg  [31:0] data_sec_enc_chs_int_msk0; 
  reg  [31:0] data_sec_enc_chs_int_msk1; 
  reg  [31:0] data_sec_enc_chs_int_msk2; 
  wire [31:0] data_sec_enc_chs_int_msk3; 
  reg   [5:0] data_chs_pwr_req;          
  wire [31:0] data_chs_pwr_st;           
  reg  [15:0] data_secencclk_ctrl;       
  reg   [4:0] data_secencclk_div;        
  wire [31:0] data_sec_enc_pll_st;       
  wire [31:0] data_pid4;                 
  wire [31:0] data_pid5;                 
  wire [31:0] data_pid6;                 
  wire [31:0] data_pid7;                 
  wire [31:0] data_pid0;                 
  wire [31:0] data_pid1;                 
  wire [31:0] data_pid2;                 
  wire [31:0] data_pid3;                 
  wire [31:0] data_id0;                  
  wire [31:0] data_id1;                  
  wire [31:0] data_id2;                  
  wire [31:0] data_id3;                  

  reg   [1:0] data_host_sys_rst_ctrl_nxt;
  reg         data_soc_rst_ctrl_nxt;
  reg  [31:0] data_sec_enc_chs_int_msk0_nxt;
  reg  [31:0] data_sec_enc_chs_int_msk1_nxt;
  reg  [31:0] data_sec_enc_chs_int_msk2_nxt;
  reg   [5:0] data_chs_pwr_req_nxt;
  reg  [15:0] data_secencclk_ctrl_nxt;
  reg   [4:0] data_secencclk_div_nxt;
  
  reg         secenc_clockforce_st;

  wire  [9:0] addr_int;
  wire        writeen;
  wire        readen;
  reg  [31:0] rdata_int;
  wire [31:0] prdata_nxt;
  reg  [31:0] prdata_i;

  wire  [3:0] pid2_eco;
  wire  [3:0] pid3_eco;
  
  wire        dbgtop_pwr_st_ss;
  wire        dbgtop_pwr_st_sw_reg;

  wire  [4:0] systop_pwr_st_ss;
  reg   [2:0] systop_pwr_st_sw_reg;
  wire        systop_pwr_st_sw_reg_en;
    
  wire [1:0]  clkselect_cur_ss;
  
  wire [4:0]  clkdiv_cur_ss;
  reg  [4:0]  clkdiv_cur_sw_reg;
  wire        clkdiv_cur_sw_reg_en;

  wire [1:0] host_rst_ack_ss;
  reg        host_rst_ack_acc;
  
  wire       host_sys_cpuwait_set;

  wire [4:0] soc_rst_synd_ss;
  reg  [4:0] soc_rst_synd_sw_reg;    
  wire       soc_rst_synd_sw_reg_en;
  
  reg  [3:0] chs_pwr_req_systop_r;
  reg  [3:0] chs_pwr_req_systop_nxt;
  
  wire        unused;


  assign addr_int = psel ? {paddr[11:2]} : 10'b0;
  assign writeen  = psel & pwrite & (~penable);
  assign readen   = psel & (~pwrite) & (~penable);

  
  assign data_host_sys_rst_st      = {29'b0, host_rst_ack_ss, 1'b0};
  assign data_soc_rst_syn          = {soc_rst_synd_sw_reg[4], 27'b0, soc_rst_synd_sw_reg[3:0]};
  assign data_sec_enc_chs_int_st0  = int_st0;
  assign data_sec_enc_chs_int_st1  = int_st1;
  assign data_sec_enc_chs_int_st2  = {24'h0, int_st2};
  assign data_sec_enc_chs_int_st3  = 32'h0000_0000;
  assign data_sec_enc_chs_int_msk3 = 32'h0000_0000;
  assign data_chs_pwr_st           = {26'b0, systop_pwr_st_sw_reg, dbgtop_pwr_st_sw_reg, 2'b0};
  assign data_sec_enc_pll_st       = {31'b0, sysplllock_st};
  assign data_pid4                 = 32'h0000_0004;
  assign data_pid5                 = 32'h0000_0000;
  assign data_pid6                 = 32'h0000_0000;
  assign data_pid7                 = 32'h0000_0000;
  assign data_pid0                 = 32'h0000_0077;
  assign data_pid1                 = 32'h0000_00b0;
  assign data_pid2                 = {24'h0, pid2_eco, 4'hb};
  assign data_pid3                 = {24'h0, pid3_eco, 4'h0};
  assign data_id0                  = 32'h0000_000d;
  assign data_id1                  = 32'h0000_00f0;
  assign data_id2                  = 32'h0000_0005;
  assign data_id3                  = 32'h0000_00b1;

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
       data_host_sys_rst_ctrl    <=  2'b01;
       data_soc_rst_ctrl         <=  1'b0;
       data_sec_enc_chs_int_msk0 <= 32'h0000_0000;
       data_sec_enc_chs_int_msk1 <= 32'h0000_0000;
       data_sec_enc_chs_int_msk2 <= 32'h0000_0000;
       data_chs_pwr_req          <=  6'h00;
       data_secencclk_ctrl       <= 16'h0001;
       data_secencclk_div        <=  5'b0_0000;
      end
    else
      begin
        data_host_sys_rst_ctrl    <= data_host_sys_rst_ctrl_nxt;
        data_soc_rst_ctrl         <= data_soc_rst_ctrl_nxt;
        data_sec_enc_chs_int_msk0 <= data_sec_enc_chs_int_msk0_nxt;
        data_sec_enc_chs_int_msk1 <= data_sec_enc_chs_int_msk1_nxt;
        data_sec_enc_chs_int_msk2 <= data_sec_enc_chs_int_msk2_nxt;
        data_chs_pwr_req          <= data_chs_pwr_req_nxt;
        data_secencclk_ctrl       <= data_secencclk_ctrl_nxt;
        data_secencclk_div        <= data_secencclk_div_nxt;
      end
   end


  always @(*)
    begin
      data_host_sys_rst_ctrl_nxt[1] = data_host_sys_rst_ctrl[1];
      data_soc_rst_ctrl_nxt         = data_soc_rst_ctrl;
      data_sec_enc_chs_int_msk0_nxt = data_sec_enc_chs_int_msk0;
      data_sec_enc_chs_int_msk1_nxt = data_sec_enc_chs_int_msk1;
      data_sec_enc_chs_int_msk2_nxt = data_sec_enc_chs_int_msk2;
      data_chs_pwr_req_nxt          = data_chs_pwr_req;
      data_secencclk_ctrl_nxt       = data_secencclk_ctrl;
      data_secencclk_div_nxt        = data_secencclk_div;
      if (writeen)
        case (addr_int)
          ADDR_HOST_SYS_RST_CTRL    : data_host_sys_rst_ctrl_nxt[1] = pwdata[1];
          ADDR_SOC_RST_CTRL         : data_soc_rst_ctrl_nxt         = pwdata[1];
          ADDR_SEC_ENC_CHS_INT_MSK0 : data_sec_enc_chs_int_msk0_nxt = pwdata[31:0];
          ADDR_SEC_ENC_CHS_INT_MSK1 : data_sec_enc_chs_int_msk1_nxt = pwdata[31:0];
          ADDR_SEC_ENC_CHS_INT_MSK2 : data_sec_enc_chs_int_msk2_nxt = pwdata[31:0];
          ADDR_CHS_PWR_REQ          : data_chs_pwr_req_nxt          = pwdata[5:0];
          ADDR_SECENCCLK_CTRL       : data_secencclk_ctrl_nxt       = {pwdata[31:24],pwdata[7:0]};
          ADDR_SECENCCLK_DIV        : data_secencclk_div_nxt        = pwdata[4:0];
        endcase
    end

  always @(*)
    begin
      if (writeen & (addr_int == ADDR_HOST_SYS_RST_CTRL) & (host_cpuwait_wen)) 
        data_host_sys_rst_ctrl_nxt[0] = data_host_sys_rst_ctrl[0] & pwdata[0] | host_sys_cpuwait_set;
      else 
        data_host_sys_rst_ctrl_nxt[0] = data_host_sys_rst_ctrl[0] | host_sys_cpuwait_set;
    end  

  
  always @(posedge clk or negedge rst_n)
    begin
      if (~rst_n)
        secenc_clockforce_st <= 1'b0;
      else
        begin
          if (writeen & (addr_int == ADDR_CLOCKFORCE_CLR) & (pwdata[0] == 1'b1)) 
            secenc_clockforce_st <= 1'b0;
          else if (writeen & (addr_int == ADDR_CLOCKFORCE_SET) & (pwdata[0] == 1'b1)) 
            secenc_clockforce_st <= 1'b1;
        end
    end


  always @(*)
    begin
      rdata_int =  (&(addr_int ^ (~addr_int))) ? 32'h0000_0000 : 32'hFFFF_FFFF;  
      case (addr_int)
        ADDR_HOST_SYS_RST_CTRL    : rdata_int = {30'b0, data_host_sys_rst_ctrl};
        ADDR_HOST_SYS_RST_ST      : rdata_int = data_host_sys_rst_st;
        ADDR_SOC_RST_CTRL         : rdata_int = {30'b0, data_soc_rst_ctrl, 1'b0};
        ADDR_SOC_RST_SYN          : rdata_int = data_soc_rst_syn;
        ADDR_SEC_ENC_CHS_INT_ST0  : rdata_int = data_sec_enc_chs_int_st0;
        ADDR_SEC_ENC_CHS_INT_ST1  : rdata_int = data_sec_enc_chs_int_st1;
        ADDR_SEC_ENC_CHS_INT_ST2  : rdata_int = data_sec_enc_chs_int_st2;
        ADDR_SEC_ENC_CHS_INT_ST3  : rdata_int = data_sec_enc_chs_int_st3;
        ADDR_SEC_ENC_CHS_INT_MSK0 : rdata_int = data_sec_enc_chs_int_msk0;
        ADDR_SEC_ENC_CHS_INT_MSK1 : rdata_int = data_sec_enc_chs_int_msk1;
        ADDR_SEC_ENC_CHS_INT_MSK2 : rdata_int = data_sec_enc_chs_int_msk2;
        ADDR_SEC_ENC_CHS_INT_MSK3 : rdata_int = data_sec_enc_chs_int_msk3;
        ADDR_CHS_PWR_REQ          : rdata_int = {26'b0, data_chs_pwr_req};
        ADDR_CHS_PWR_ST           : rdata_int = data_chs_pwr_st;
        ADDR_SECENCCLK_CTRL       : rdata_int = {data_secencclk_ctrl[15:8], 8'b0, data_secencclk_ctrl[7:2], clkselect_cur_ss, data_secencclk_ctrl[7:0]};
        ADDR_SECENCCLK_DIV        : rdata_int = {11'b0, clkdiv_cur_sw_reg, 11'b0, data_secencclk_div};
        ADDR_CLOCKFORCE_ST        : rdata_int = {31'b0, secenc_clockforce_st};
        ADDR_CLOCKFORCE_SET       : rdata_int = 32'b0;
        ADDR_CLOCKFORCE_CLR       : rdata_int = 32'b0;
        ADDR_SEC_ENC_PLL_ST       : rdata_int = data_sec_enc_pll_st;
        ADDR_PID4                 : rdata_int = data_pid4;
        ADDR_PID5                 : rdata_int = data_pid5;
        ADDR_PID6                 : rdata_int = data_pid6;
        ADDR_PID7                 : rdata_int = data_pid7;
        ADDR_PID0                 : rdata_int = data_pid0;
        ADDR_PID1                 : rdata_int = data_pid1;
        ADDR_PID2                 : rdata_int = data_pid2;
        ADDR_PID3                 : rdata_int = data_pid3;
        ADDR_ID0                  : rdata_int = data_id0;
        ADDR_ID1                  : rdata_int = data_id1;
        ADDR_ID2                  : rdata_int = data_id2;
        ADDR_ID3                  : rdata_int = data_id3;
      endcase
    end

  assign prdata_nxt = readen ? rdata_int : 32'b0;
  
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      prdata_i <= 32'h0000_0000;
    else if (psel)
      prdata_i <= prdata_nxt;

  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_0 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[0]),
    .q          (dbgtop_pwr_st_ss)
  ); 
  
  assign dbgtop_pwr_st_sw_reg = dbgtop_pwr_st_ss;
  
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_1 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[1]),
    .q          (systop_pwr_st_ss[0])
  ); 
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_2 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[2]),
    .q          (systop_pwr_st_ss[1])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_3 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[3]),
    .q          (systop_pwr_st_ss[2])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_4 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[4]),
    .q          (systop_pwr_st_ss[3])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_5 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (chs_pwr_st[5]),
    .q          (systop_pwr_st_ss[4])
  );  
  
  
  assign systop_pwr_st_sw_reg_en = (systop_pwr_st_ss == 5'h01) ? 1'b1 :
                                   (systop_pwr_st_ss == 5'h02) ? 1'b1 :
                                   (systop_pwr_st_ss == 5'h04) ? 1'b1 :
                                   (systop_pwr_st_ss == 5'h08) ? 1'b1 :
                                   (systop_pwr_st_ss == 5'h10) ? 1'b1 : 1'b0;  
  
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      systop_pwr_st_sw_reg <= 3'h0;
    else if (systop_pwr_st_sw_reg_en)
      systop_pwr_st_sw_reg <= {systop_pwr_st_ss[4], systop_pwr_st_ss[3], systop_pwr_st_ss[2]};

  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_6 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (clkselect_cur[0]),
    .q          (clkselect_cur_ss[0])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_7 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (clkselect_cur[1]),
    .q          (clkselect_cur_ss[1])
  );
  
  
  genvar idx;
  generate for (idx = 0; idx < 5; idx = idx + 1)
  begin: sync_loop    
    sec_cdc_capt_sync u_sec_cdc_capt_sync (
      .clk        (clk),
      .nreset     (rst_n),
      .d_async    (clkdiv_cur[idx]),
      .q          (clkdiv_cur_ss[idx])
    );
  end 
  endgenerate
  
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      clkdiv_cur_sw_reg <= 5'h00;
    else if (clkdiv_cur_sw_reg_en)
      clkdiv_cur_sw_reg <= clkdiv_cur_ss; 
  
  assign clkdiv_cur_sw_reg_en = (clkdiv_cur_ss == data_secencclk_div) ? 1'b1 : 1'b0;
  
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_8 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (host_rst_ack[0]),
    .q          (host_rst_ack_ss[0])
  ); 
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_9 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (host_rst_ack[1]),
    .q          (host_rst_ack_ss[1])
  );
  
  always @(posedge clk or negedge rst_n)
    if (!rst_n)
      host_rst_ack_acc <= 1'b0;
    else
      host_rst_ack_acc <= host_rst_ack_ss[1];   
  
  assign host_sys_cpuwait_set = (~host_rst_ack_acc & host_rst_ack_ss[1]) ? 1'b1 : 1'b0;

  sec_cdc_capt_sync u_sec_cdc_capt_sync_10 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (soc_rst_synd[0]),
    .q          (soc_rst_synd_ss[0])
  );

  sec_cdc_capt_sync u_sec_cdc_capt_sync_11 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (soc_rst_synd[1]),
    .q          (soc_rst_synd_ss[1])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_12 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (soc_rst_synd[2]),
    .q          (soc_rst_synd_ss[2])
  );
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_13 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (soc_rst_synd[3]),
    .q          (soc_rst_synd_ss[3])
  );  
  
  sec_cdc_capt_sync u_sec_cdc_capt_sync_14 (
    .clk        (clk),
    .nreset     (rst_n),
    .d_async    (soc_rst_synd[4]),
    .q          (soc_rst_synd_ss[4])
  ); 

  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      soc_rst_synd_sw_reg <= 5'h00;
    else if (soc_rst_synd_sw_reg_en)
      soc_rst_synd_sw_reg <= soc_rst_synd_ss;

  assign soc_rst_synd_sw_reg_en = (soc_rst_synd_ss == 5'h01) ? 1'b1 :
                                  (soc_rst_synd_ss == 5'h02) ? 1'b1 :
                                  (soc_rst_synd_ss == 5'h04) ? 1'b1 :
                                  (soc_rst_synd_ss == 5'h08) ? 1'b1 :
                                  (soc_rst_synd_ss == 5'h10) ? 1'b1 : 1'b0;
  
  
  always @(posedge clk or negedge rst_n)
    if (~rst_n)
      chs_pwr_req_systop_r <= 4'h8;
    else
      chs_pwr_req_systop_r <= chs_pwr_req_systop_nxt;  
  
  always @(*)
    begin
      case (data_chs_pwr_req[5:3])
        3'b000 : chs_pwr_req_systop_nxt = 4'b1000;
        3'b001 : chs_pwr_req_systop_nxt = 4'b0001;
        3'b010 : chs_pwr_req_systop_nxt = 4'b0010;
        3'b011 : chs_pwr_req_systop_nxt = 4'b0010;
        3'b100 : chs_pwr_req_systop_nxt = 4'b0100;
        3'b101 : chs_pwr_req_systop_nxt = 4'b0100;
        3'b110 : chs_pwr_req_systop_nxt = 4'b0100;
        3'b111 : chs_pwr_req_systop_nxt = 4'b0100;
        default: chs_pwr_req_systop_nxt = 4'bxxxx;
      endcase
    end
  
  
  assign prdata       = prdata_i;
  assign host_rst_req = data_host_sys_rst_ctrl[1];
  assign host_cpuwait = data_host_sys_rst_ctrl[0];
  assign soc_rst_req  = data_soc_rst_ctrl;
  assign int_msk0     = data_sec_enc_chs_int_msk0;
  assign int_msk1     = data_sec_enc_chs_int_msk1;
  assign int_msk2     = data_sec_enc_chs_int_msk2;
  assign chs_pwr_req  = {chs_pwr_req_systop_r, data_chs_pwr_req[2:0]};
  assign entry_delay  = data_secencclk_ctrl[15:8];
  assign clkselect    = data_secencclk_ctrl[1:0];
  assign clkdiv       = data_secencclk_div;
  assign clkforce     = secenc_clockforce_st;


  assign unused = &paddr;

endmodule
