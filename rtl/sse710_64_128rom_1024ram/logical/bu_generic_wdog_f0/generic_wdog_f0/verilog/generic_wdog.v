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


module generic_wdog 

#(parameter NONSECURE = 1'b1)
(

  input wire clk,
  input wire reset_n,


  input wire [63:0] tsvalueb,     


  output reg  [1:0]  intr,  


  
  output wire [31:0] prdata,
  output wire        pready,

  input wire         penable,
  input wire         psel,
  input wire [16:0]  paddr,
  input wire         pwrite,
  input wire [31:0]  pwdata,
  input wire [3:0]   pstrb,    
  input wire [2:0]   pprot
);

  localparam CONTROL_FRAME_BASE_ADDR = 17'h0_0000;
  localparam REFRESH_FRAME_BASE_ADDR = 17'h1_0000;



  localparam WDOG_STATE_CLEAR  = 2'b00;
  localparam WDOG_STATE_FIRST  = 2'b01;
  localparam WDOG_STATE_SECOND = 2'b11;



  localparam REFRESH_WRR_OFFSET_ADDR    = 12'h000;  

  localparam REFRESH_IIDR_OFFSET_ADDR  = 12'hFCC;  

  localparam REFRESH_CID0_OFFSET_ADDR   = 12'hFF0;  
  localparam REFRESH_CID1_OFFSET_ADDR   = 12'hFF4;  
  localparam REFRESH_CID2_OFFSET_ADDR   = 12'hFF8;  
  localparam REFRESH_CID3_OFFSET_ADDR   = 12'hFFC;  

  localparam REFRESH_PID0_OFFSET_ADDR   = 12'hFE0;  
  localparam REFRESH_PID1_OFFSET_ADDR   = 12'hFE4;  
  localparam REFRESH_PID2_OFFSET_ADDR   = 12'hFE8;  
  localparam REFRESH_PID3_OFFSET_ADDR   = 12'hFEC;  
  localparam REFRESH_PID4_OFFSET_ADDR   = 12'hFD0;  
  

  wire [16:0] refresh_wrr_addr  = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_WRR_OFFSET_ADDR};
  wire [16:0] refresh_iidr_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_IIDR_OFFSET_ADDR};
  wire [16:0] refresh_pid0_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_PID0_OFFSET_ADDR};
  wire [16:0] refresh_pid1_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_PID1_OFFSET_ADDR};
  wire [16:0] refresh_pid2_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_PID2_OFFSET_ADDR};
  wire [16:0] refresh_pid3_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_PID3_OFFSET_ADDR};
  wire [16:0] refresh_pid4_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_PID4_OFFSET_ADDR};
  wire [16:0] refresh_cid0_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_CID0_OFFSET_ADDR};
  wire [16:0] refresh_cid1_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_CID1_OFFSET_ADDR};
  wire [16:0] refresh_cid2_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_CID2_OFFSET_ADDR};
  wire [16:0] refresh_cid3_addr = REFRESH_FRAME_BASE_ADDR | {5'b00000, REFRESH_CID3_OFFSET_ADDR};


  localparam CONTROL_WCSR_OFFSET_ADDR   = 12'h000;  
  localparam CONTROL_WOR_OFFSET_ADDR    = 12'h008;  
  localparam CONTROL_WCVR_L_OFFSET_ADDR = 12'h010;  
  localparam CONTROL_WCVR_H_OFFSET_ADDR = 12'h014;  

  localparam CONTROL_IIDR_OFFSET_ADDR   = 12'hFCC;  

  localparam CONTROL_CID0_OFFSET_ADDR   = 12'hFF0;  
  localparam CONTROL_CID1_OFFSET_ADDR   = 12'hFF4;  
  localparam CONTROL_CID2_OFFSET_ADDR   = 12'hFF8;  
  localparam CONTROL_CID3_OFFSET_ADDR   = 12'hFFC;  

  localparam CONTROL_PID0_OFFSET_ADDR   = 12'hFE0;  
  localparam CONTROL_PID1_OFFSET_ADDR   = 12'hFE4;  
  localparam CONTROL_PID2_OFFSET_ADDR   = 12'hFE8;  
  localparam CONTROL_PID3_OFFSET_ADDR   = 12'hFEC;  
  localparam CONTROL_PID4_OFFSET_ADDR   = 12'hFD0;  


  wire [16:0] control_wcsr_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_WCSR_OFFSET_ADDR};
  wire [16:0] control_wor_addr    = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_WOR_OFFSET_ADDR};
  wire [16:0] control_wcvr_l_addr = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_WCVR_L_OFFSET_ADDR};
  wire [16:0] control_wcvr_h_addr = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_WCVR_H_OFFSET_ADDR};
  wire [16:0] control_iidr_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_IIDR_OFFSET_ADDR};
  wire [16:0] control_pid0_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_PID0_OFFSET_ADDR};
  wire [16:0] control_pid1_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_PID1_OFFSET_ADDR};
  wire [16:0] control_pid2_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_PID2_OFFSET_ADDR};
  wire [16:0] control_pid3_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_PID3_OFFSET_ADDR};
  wire [16:0] control_pid4_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_PID4_OFFSET_ADDR};
  wire [16:0] control_cid0_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_CID0_OFFSET_ADDR};
  wire [16:0] control_cid1_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_CID1_OFFSET_ADDR};
  wire [16:0] control_cid2_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_CID2_OFFSET_ADDR};
  wire [16:0] control_cid3_addr   = CONTROL_FRAME_BASE_ADDR | {5'b00000, CONTROL_CID3_OFFSET_ADDR};


  
  
  reg [63:0] control_wcvr;
  reg [31:0] control_wor;

  reg        control_wcsr_watchdog_enable;
  wire       control_wcsr_write_enable;

  
  reg [16:2] paddr_reg;
  reg [31:0] pwdata_reg;

  wire       timeout_refresh;  
  wire       explicit_refresh; 
  wire       refresh;          

  reg [1:0]  wdog_state;
  reg [1:0]  nxt_wdog_state;

  wire [63:0] nxt_control_wcvr;
  wire [31:0] nxt_control_wor;

  wire        control_wcsr_read_enable;
  wire        control_wor_read_enable;
  wire        control_wcvr_l_read_enable;
  wire        control_wcvr_h_read_enable;
  wire        control_iidr_read_enable;
  wire        control_pid0_read_enable;
  wire        control_pid1_read_enable;
  wire        control_pid2_read_enable;
  wire        control_pid3_read_enable;
  wire        control_pid4_read_enable;
  wire        control_cid0_read_enable;
  wire        control_cid1_read_enable;
  wire        control_cid2_read_enable;
  wire        control_cid3_read_enable;
  wire        refresh_iidr_read_enable;
  wire        refresh_pid0_read_enable;
  wire        refresh_pid1_read_enable;
  wire        refresh_pid2_read_enable;
  wire        refresh_pid3_read_enable;
  wire        refresh_pid4_read_enable;
  wire        refresh_cid0_read_enable;
  wire        refresh_cid1_read_enable;
  wire        refresh_cid2_read_enable;
  wire        refresh_cid3_read_enable;
  wire [31:0] control_wcsr_read_data;

  wire        secure_permission_check;

  reg  [1:0]  i_intr;

  wire        refresh_wrr_write_enable;
  wire        control_wor_write_enable;
  wire        control_wcvr_l_write_enable;
  wire        control_wcvr_h_write_enable;


  assign secure_permission_check = NONSECURE | ~pprot[1];



  always @(posedge clk or negedge reset_n)
    if (!reset_n)
    begin
      paddr_reg[16:2]  <= {15{1'b0}};
      pwdata_reg[31:0] <= {32{1'b0}};
    end
    else
    begin
      if (psel & ~penable)
      begin
        paddr_reg[16:2]  <= paddr[16:2];
        pwdata_reg[31:0] <= pwdata[31:0];
      end
    end


  assign pready = 1'b1;

  
  assign refresh_wrr_write_enable = psel & penable & pwrite & (paddr_reg[16:2] == refresh_wrr_addr[16:2]) & 
                                    secure_permission_check;


  
  assign control_wcsr_write_enable = psel & penable & pwrite & (paddr_reg[16:2] == control_wcsr_addr[16:2]) &
                                     secure_permission_check;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      control_wcsr_watchdog_enable <= 1'b0;
    else
      if (control_wcsr_write_enable)
        control_wcsr_watchdog_enable <= pwdata_reg[0];



  assign control_wor_write_enable = psel & penable & pwrite & (paddr_reg[16:2] == control_wor_addr[16:2]) &
                                    secure_permission_check;

  assign nxt_control_wor = control_wor_write_enable ? pwdata_reg[31:0] : control_wor[31:0];

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      control_wor <= 32'h0000_0000;
    else
      if (control_wor_write_enable)
        control_wor <= pwdata_reg[31:0];




  assign control_wcvr_l_write_enable = (psel & penable & pwrite & (paddr[16:2] == control_wcvr_l_addr[16:2]) &
                                          secure_permission_check)
                                        | explicit_refresh
                                        | (timeout_refresh & (wdog_state==WDOG_STATE_CLEAR));

  assign control_wcvr_h_write_enable = (psel & penable & pwrite & (paddr[16:2] == control_wcvr_h_addr[16:2]) &
                                          secure_permission_check)
                                        | explicit_refresh
                                        | (timeout_refresh & (wdog_state==WDOG_STATE_CLEAR));



  assign nxt_control_wcvr = refresh ? tsvalueb + {32'h0000_0000, nxt_control_wor[31:0]}
                                    : {2{pwdata[31:0]}};


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      control_wcvr[31:0] <= 32'h0000_0000;
    else
      if (control_wcvr_l_write_enable)
       control_wcvr[31:0] <= nxt_control_wcvr[31:0];


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      control_wcvr[63:32] <= 32'h0000_0000;
    else
      if (control_wcvr_h_write_enable)
       control_wcvr[63:32] <= nxt_control_wcvr[63:32];

  
  assign control_wcsr_read_enable    = (paddr_reg[16:2] == control_wcsr_addr[16:2]);
  assign control_wor_read_enable     = (paddr_reg[16:2] == control_wor_addr[16:2]);
  assign control_wcvr_l_read_enable  = (paddr_reg[16:2] == control_wcvr_l_addr[16:2]);
  assign control_wcvr_h_read_enable  = (paddr_reg[16:2] == control_wcvr_h_addr[16:2]);
  assign control_iidr_read_enable    = (paddr_reg[16:2] == control_iidr_addr[16:2]);
  assign control_pid0_read_enable    = (paddr_reg[16:2] == control_pid0_addr[16:2]);
  assign control_pid1_read_enable    = (paddr_reg[16:2] == control_pid1_addr[16:2]);
  assign control_pid2_read_enable    = (paddr_reg[16:2] == control_pid2_addr[16:2]);
  assign control_pid3_read_enable    = (paddr_reg[16:2] == control_pid3_addr[16:2]);
  assign control_pid4_read_enable    = (paddr_reg[16:2] == control_pid4_addr[16:2]);
  assign control_cid0_read_enable    = (paddr_reg[16:2] == control_cid0_addr[16:2]);
  assign control_cid1_read_enable    = (paddr_reg[16:2] == control_cid1_addr[16:2]);
  assign control_cid2_read_enable    = (paddr_reg[16:2] == control_cid2_addr[16:2]);
  assign control_cid3_read_enable    = (paddr_reg[16:2] == control_cid3_addr[16:2]);
  assign refresh_iidr_read_enable    = (paddr_reg[16:2] == refresh_iidr_addr[16:2]);
  assign refresh_pid0_read_enable    = (paddr_reg[16:2] == refresh_pid0_addr[16:2]);
  assign refresh_pid1_read_enable    = (paddr_reg[16:2] == refresh_pid1_addr[16:2]);
  assign refresh_pid2_read_enable    = (paddr_reg[16:2] == refresh_pid2_addr[16:2]);
  assign refresh_pid3_read_enable    = (paddr_reg[16:2] == refresh_pid3_addr[16:2]);
  assign refresh_pid4_read_enable    = (paddr_reg[16:2] == refresh_pid4_addr[16:2]);
  assign refresh_cid0_read_enable    = (paddr_reg[16:2] == refresh_cid0_addr[16:2]);
  assign refresh_cid1_read_enable    = (paddr_reg[16:2] == refresh_cid1_addr[16:2]);
  assign refresh_cid2_read_enable    = (paddr_reg[16:2] == refresh_cid2_addr[16:2]);
  assign refresh_cid3_read_enable    = (paddr_reg[16:2] == refresh_cid3_addr[16:2]);

  assign control_wcsr_read_data = {29'b0000_0000_0000_0, i_intr[1:0], control_wcsr_watchdog_enable};






  reg  [31:0]       ctrl_static_r;
  wire [31:0]       ctrl_static_o;
  reg               ctrl_static_up;
  wire              ctrl_static_en;

  always@(posedge clk)
  begin
    if(ctrl_static_en)
    begin
      ctrl_static_r <= 32'h0000_143B;
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      ctrl_static_up <= 1'b1;
    end
    else if(ctrl_static_en)
    begin
      ctrl_static_up <= 1'b0;
    end
  end

  assign ctrl_static_en = ctrl_static_up;

  assign ctrl_static_o = ctrl_static_r;



  reg  [31:0]       refresh_static_r;
  wire [31:0]       refresh_static_o;
  reg               refresh_static_up;
  wire              refresh_static_en;

  always@(posedge clk)
  begin
    if(refresh_static_en)
    begin
      refresh_static_r <= 32'h0000_143B;
    end
  end

  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      refresh_static_up <= 1'b1;
    end
    else if(refresh_static_en)
    begin
      refresh_static_up <= 1'b0;
    end
  end

  assign refresh_static_en = refresh_static_up;

  assign refresh_static_o = refresh_static_r;


  assign prdata[31:0] = {32{secure_permission_check}} &  

                        (({32{control_wcsr_read_enable}}   &  control_wcsr_read_data[31:0]) |
                         ({32{control_wor_read_enable}}    &  control_wor[31:0])            |
                         ({32{control_wcvr_l_read_enable}} &  control_wcvr[31:0])           |
                         ({32{control_wcvr_h_read_enable}} &  control_wcvr[63:32])          |
                         ({32{control_iidr_read_enable}}   &  ctrl_static_o)                |
                         ({32{control_pid0_read_enable}}   &  32'h0000_00B1)                |
                         ({32{control_pid1_read_enable}}   &  32'h0000_00B0)                |
                         ({32{control_pid2_read_enable}}   &  32'h0000_002B)                |
                         ({32{control_pid3_read_enable}}   &  32'h0000_0000)                |
                         ({32{control_pid4_read_enable}}   &  32'h0000_0004)                |
                         ({32{control_cid0_read_enable}}   &  32'h0000_000D)                |
                         ({32{control_cid1_read_enable}}   &  32'h0000_00F0)                |
                         ({32{control_cid2_read_enable}}   &  32'h0000_0005)                |
                         ({32{control_cid3_read_enable}}   &  32'h0000_00B1)                |
                         ({32{refresh_iidr_read_enable}}   &  refresh_static_o)             |
                         ({32{refresh_pid0_read_enable}}   &  32'h0000_00B0)                |
                         ({32{refresh_pid1_read_enable}}   &  32'h0000_00B0)                |
                         ({32{refresh_pid2_read_enable}}   &  32'h0000_002B)                |
                         ({32{refresh_pid3_read_enable}}   &  32'h0000_0000)                |
                         ({32{refresh_pid4_read_enable}}   &  32'h0000_0004)                |
                         ({32{refresh_cid0_read_enable}}   &  32'h0000_000D)                |
                         ({32{refresh_cid1_read_enable}}   &  32'h0000_00F0)                |
                         ({32{refresh_cid2_read_enable}}   &  32'h0000_0005)                |
                         ({32{refresh_cid3_read_enable}}   &  32'h0000_00B1));





  assign timeout_refresh  = (tsvalueb > control_wcvr) & control_wcsr_watchdog_enable;

  assign explicit_refresh = control_wor_write_enable   | 
                            control_wcsr_write_enable  |
                            refresh_wrr_write_enable;


  assign refresh = timeout_refresh | explicit_refresh;


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      wdog_state <= WDOG_STATE_CLEAR;
    else if(refresh)
      wdog_state <= nxt_wdog_state;


  always @*
    case(wdog_state)
      WDOG_STATE_CLEAR :
        case({timeout_refresh, explicit_refresh})
          2'b10 : nxt_wdog_state = WDOG_STATE_FIRST;
          2'b00,
          2'b01,
          2'b11 : nxt_wdog_state = WDOG_STATE_CLEAR;
          default : nxt_wdog_state = 2'bxx;
        endcase
      WDOG_STATE_FIRST :
        case({timeout_refresh, explicit_refresh})
          2'b00 : nxt_wdog_state = WDOG_STATE_FIRST;
          2'b10 : nxt_wdog_state = WDOG_STATE_SECOND;
          2'b01,
          2'b11 : nxt_wdog_state = WDOG_STATE_CLEAR;
          default : nxt_wdog_state = 2'bxx;
        endcase
      WDOG_STATE_SECOND : nxt_wdog_state = explicit_refresh ? WDOG_STATE_CLEAR : WDOG_STATE_SECOND;
      default           : nxt_wdog_state = 2'bxx;
    endcase


  always @*
    case(wdog_state)
      WDOG_STATE_CLEAR  : i_intr = 2'b00;
      WDOG_STATE_FIRST  : i_intr = 2'b01;
      WDOG_STATE_SECOND : i_intr = 2'b11;
      default           : i_intr = 2'bxx;
    endcase

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      intr <= 2'b00;
    else
      intr <= i_intr;


endmodule
