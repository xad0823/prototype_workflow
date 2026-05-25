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


module sse710_integration_example_f0_timer (
  input  wire        PCLK,     
  input  wire        PCLKG,    
  input  wire        PRESETn,  

  input  wire        PSEL,     
  input  wire [11:2] PADDR,    
  input  wire        PENABLE,  
  input  wire        PWRITE,   
  input  wire [31:0] PWDATA,   

  input  wire [2:0]  PPROT,    
  input  wire [3:0]  PSTRB,    

  input  wire  [3:0] ECOREVNUM ,

  output wire [31:0] PRDATA,   
  output wire        PREADY,   
  output wire        PSLVERR,  
  input  wire        PRIVMODEN,
  input  wire        EXTIN,    

  output wire        TIMERINT); 

localparam  ARM_CMSDK_APB_TIMER_PID0 = 8'h22;
localparam  ARM_CMSDK_APB_TIMER_PID1 = 8'hB8;
localparam  ARM_CMSDK_APB_TIMER_PID2 = 8'h1B;
localparam  ARM_CMSDK_APB_TIMER_PID3 = 4'h0;
localparam  ARM_CMSDK_APB_TIMER_PID4 = 8'h04;
localparam  ARM_CMSDK_APB_TIMER_PID5 = 8'h00;
localparam  ARM_CMSDK_APB_TIMER_PID6 = 8'h00;
localparam  ARM_CMSDK_APB_TIMER_PID7 = 8'h00;
localparam  ARM_CMSDK_APB_TIMER_CID0 = 8'h0D;
localparam  ARM_CMSDK_APB_TIMER_CID1 = 8'hF0;
localparam  ARM_CMSDK_APB_TIMER_CID2 = 8'h05;
localparam  ARM_CMSDK_APB_TIMER_CID3 = 8'hB1;

wire          read_enable;
wire          write_enable;
wire          write_enable00; 
wire          write_enable04; 
wire          write_enable08; 
wire          write_enable0c; 
reg     [7:0] read_mux_byte0;
reg     [7:0] read_mux_byte0_reg;
reg    [31:0] read_mux_word;
wire    [3:0] pid3_value;

reg     [3:0] reg_ctrl;
reg    [31:0] reg_curr_val;
reg    [31:0] reg_reload_val;
reg    [31:0] nxt_curr_val;

reg           ext_in_sync1;  
reg           ext_in_sync2;  
reg           ext_in_delay;  
wire          ext_in_enable; 
wire          dec_ctrl;      
wire          clk_ctrl;      
wire          enable_ctrl;   
wire          edge_detect;   
reg           reg_timer_int; 
wire          timer_int_clear; 
wire          timer_int_set;   
wire          update_timer_int;

assign  read_enable  = PSEL & (~PWRITE); 
assign  write_enable = PSEL & (~PENABLE) & PWRITE & (PPROT[0] | ~PRIVMODEN); 
assign  write_enable00 = write_enable & (PADDR[11:2] == 10'h000);
assign  write_enable04 = write_enable & (PADDR[11:2] == 10'h001);
assign  write_enable08 = write_enable & (PADDR[11:2] == 10'h002);
assign  write_enable0c = write_enable & (PADDR[11:2] == 10'h003);

  always @(posedge PCLKG or negedge PRESETn)
  begin
    if (~PRESETn)
      reg_ctrl <= {4{1'b0}};
    else if (write_enable00)
      reg_ctrl <= PWDATA[3:0];
  end

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      reg_curr_val <= {32{1'b0}};
    else if (write_enable04 | dec_ctrl)
      reg_curr_val <= nxt_curr_val;
  end

  always @(posedge PCLKG or negedge PRESETn)
  begin
    if (~PRESETn)
      reg_reload_val <= {32{1'b0}};
    else if (write_enable08)
      reg_reload_val <= PWDATA[31:0];
  end

  assign pid3_value  = ARM_CMSDK_APB_TIMER_PID3;

always @(PADDR or reg_ctrl or reg_reload_val or reg_timer_int or
   ECOREVNUM or pid3_value)
  begin
   if (PADDR[11:4] == 8'h00) begin
     case (PADDR[3:2])
     2'h0: read_mux_byte0 =  {{4{1'b0}}, reg_ctrl};
     2'h1: read_mux_byte0 =   {8{1'b0}};
     2'h2: read_mux_byte0 =  reg_reload_val[7:0];
     2'h3: read_mux_byte0 =  {{7{1'b0}}, reg_timer_int};
     default:  read_mux_byte0 =   {8{1'bx}};
     endcase
   end
   else if (PADDR[11:6] == 6'h3F) begin
     case  (PADDR[5:2])
       4'h0, 4'h1,4'h2,4'h3: read_mux_byte0 =   {8{1'b0}};
       4'h4: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID4; 
       4'h5: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID5; 
       4'h6: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID6; 
       4'h7: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID7; 
       4'h8: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID0; 
       4'h9: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID1; 
       4'hA: read_mux_byte0 = ARM_CMSDK_APB_TIMER_PID2; 
       4'hB: read_mux_byte0 = {ECOREVNUM[3:0],pid3_value[3:0]};
       4'hC: read_mux_byte0 = ARM_CMSDK_APB_TIMER_CID0; 
       4'hD: read_mux_byte0 = ARM_CMSDK_APB_TIMER_CID1; 
       4'hE: read_mux_byte0 = ARM_CMSDK_APB_TIMER_CID2; 
       4'hF: read_mux_byte0 = ARM_CMSDK_APB_TIMER_CID3; 
       default : read_mux_byte0 = {8{1'bx}}; 
      endcase
    end
    else begin
       read_mux_byte0 =   {8{1'b0}};     
    end
  end

  always @(posedge PCLKG or negedge PRESETn)
  begin
    if (~PRESETn)
      read_mux_byte0_reg <= {8{1'b0}};
    else if (read_enable)
      read_mux_byte0_reg <= read_mux_byte0;
  end

  always @(PADDR or read_mux_byte0_reg or reg_curr_val or reg_reload_val)
  begin
  if (PADDR[11:4] == 8'h00) begin
    case (PADDR[3:2])
      2'b01:   read_mux_word = {reg_curr_val[31:0]};
      2'b10:   read_mux_word = {reg_reload_val[31:8],read_mux_byte0_reg};
      2'b00,2'b11:  read_mux_word = {{24{1'b0}} ,read_mux_byte0_reg};
      default : read_mux_word = {32{1'bx}};
    endcase
  end
  else begin
    read_mux_word = {{24{1'b0}}  ,read_mux_byte0_reg};
  end
  end

  assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
  assign PREADY  = 1'b1; 
  assign PSLVERR = 1'b0; 

  assign ext_in_enable = reg_ctrl[1] | reg_ctrl[2] | PSEL;

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      begin
      ext_in_sync1 <= 1'b0;
      ext_in_sync2 <= 1'b0;
      ext_in_delay <= 1'b0;
      end
    else if (ext_in_enable)
      begin
      ext_in_sync1 <= EXTIN;
      ext_in_sync2 <= ext_in_sync1;
      ext_in_delay <= ext_in_sync2;
      end
  end

  assign edge_detect = ext_in_sync2 & (~ext_in_delay);

  assign clk_ctrl    = reg_ctrl[2] ? edge_detect : 1'b1;

  assign enable_ctrl = reg_ctrl[1] ? ext_in_sync2 : 1'b1;

  assign dec_ctrl    = reg_ctrl[0] & enable_ctrl & clk_ctrl;

  always @(write_enable04 or PWDATA or dec_ctrl or reg_curr_val or
  reg_reload_val)
  begin
  if (write_enable04)
    nxt_curr_val = PWDATA[31:0]; 
  else if (dec_ctrl)
    begin
    if (reg_curr_val == {32{1'b0}})
      nxt_curr_val = reg_reload_val; 
    else
      nxt_curr_val = reg_curr_val - 1'b1; 
    end
  else
    nxt_curr_val = reg_curr_val; 
  end

  assign timer_int_set   = (dec_ctrl & reg_ctrl[3] & (reg_curr_val==32'h00000001));
  assign timer_int_clear = write_enable0c & PWDATA[0];
  assign update_timer_int= timer_int_set | timer_int_clear;

  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)
      reg_timer_int <= 1'b0;
    else if (update_timer_int)
      reg_timer_int <= timer_int_set;
  end

  assign TIMERINT = reg_timer_int;

`ifdef ARM_APB_ASSERT_ON
`include "std_ovl_defines.h"

   wire ovl_write_setup     = PSEL & (~PENABLE) &  PWRITE ;

   wire ovl_read_access     = PSEL & (~PWRITE) & PENABLE & PREADY;
   wire ovl_write_access    = PSEL & ( PWRITE) & PENABLE & PREADY;

   wire [7:0] ovl_apb_timer_pid3      = {ECOREVNUM[3:0], pid3_value[3:0]};
   reg  [7:0] ovl_apb_timer_pid3_d1;

   reg ovl_write_access_d1;
   reg ovl_write_setup_d1;

   reg [9:0] ovl_paddr_d1;
   reg [31:0] ovl_pwdata_d1;

   reg [3:0] ovl_reg_ctrl_d1;
   reg ovl_reg_timer_int_d1, ovl_timer_int_set_d1;

   always @(posedge PCLK or negedge PRESETn)
   if (~PRESETn)
     begin
       ovl_write_access_d1 <= 1'b0;
       ovl_write_setup_d1 <= 1'b0;
     end
   else
     begin
       ovl_write_setup_d1 <= ovl_write_setup;
       ovl_write_access_d1 <= ovl_write_access;
     end

   always @(posedge PCLK or negedge PRESETn)
   if (~PRESETn)
     begin
       ovl_paddr_d1 <= 10'b0000;
       ovl_pwdata_d1 <= 32'h00000000;
       ovl_apb_timer_pid3_d1 <= 8'h00;
     end
   else
     begin
       ovl_paddr_d1 <= PADDR;
       ovl_pwdata_d1 <= PWDATA;
       ovl_apb_timer_pid3_d1 <= ovl_apb_timer_pid3;
     end

   always @(posedge PCLK or negedge PRESETn)
   if (~PRESETn)
     begin
       ovl_reg_ctrl_d1 <= 4'b0000;
       ovl_reg_timer_int_d1 <= 1'b0;
       ovl_timer_int_set_d1 <= 1'b0;
     end
   else
     begin
       ovl_reg_timer_int_d1 <= reg_timer_int;
       ovl_timer_int_set_d1 <= timer_int_set;
       ovl_reg_ctrl_d1 <= reg_ctrl;
     end


   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 4 value must be equal to the expected value.")
   u_ovl_pid4_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F4)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID4)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 5 value must be equal to the expected value.")
   u_ovl_pid5_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F5)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID5)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 6 value must be equal to the expected value.")
   u_ovl_pid6_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F6)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID6)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 7 value must be equal to the expected value.")
   u_ovl_pid7_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F7)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID7)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 0 value must be equal to the expected value.")
   u_ovl_pid0_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F8)),
      .consequent_expr  (PRDATA[7:0] ==  ARM_CMSDK_APB_TIMER_PID0)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 1 value must be equal to the expected value.")
   u_ovl_pid1_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3F9)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID1)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 2 value must be equal to the expected value.")
   u_ovl_pid2_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FA)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_PID2)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The PID 3 value must be equal to the expected value.")
   u_ovl_pid3_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FB)),
      .consequent_expr  (PRDATA[7:0] == ovl_apb_timer_pid3_d1)
      );


   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The CID 0 value must be equal to the expected value.")
   u_ovl_cid0_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FC)),
      .consequent_expr  (PRDATA[7:0] ==  ARM_CMSDK_APB_TIMER_CID0)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The CID 1 value must be equal to the expected value.")
   u_ovl_cid1_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FD)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_CID1)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The CID 2 value must be equal to the expected value.")
   u_ovl_cid2_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FE)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_CID2)
      );

   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "The CID 3 value must be equal to the expected value.")
   u_ovl_cid3_read_value
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_read_access & (PADDR[11:2] == 10'h3FF)),
      .consequent_expr  (PRDATA[7:0] == ARM_CMSDK_APB_TIMER_CID3)
      );


   assert_implication
     #(`OVL_ERROR, `OVL_ASSERT,
       "A software clear must clear the interrupt correctly.")
   u_ovl_interrupt_clear
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (ovl_write_setup_d1 & (ovl_paddr_d1[9:0] == 10'h003) & ovl_pwdata_d1[0]
                         & (ovl_reg_timer_int_d1 == 1'b1) & (~ovl_timer_int_set_d1)),
      .consequent_expr  (reg_timer_int == 1'b0)
      );



   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Timer Interrupt Enable"
      )
    u_ovl_apb_timer_set_reg_ctrl_3
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_access_d1 & (ovl_paddr_d1[9:0] == 10'h000) ),
     .consequent_expr   (reg_ctrl == (ovl_reg_ctrl_d1 | ({ovl_pwdata_d1[3], 1'b0, 1'b0, 1'b0})))
     );


   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Timer External In as clock"
      )
    u_ovl_apb_timer_set_reg_ctrl_2
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_access_d1 & (ovl_paddr_d1[9:0] == 10'h000) ),
     .consequent_expr   (reg_ctrl == (ovl_reg_ctrl_d1 | ({1'b0, ovl_pwdata_d1[2], 1'b0, 1'b0})))
     );


   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Timer External In as enable"
      )
    u_ovl_apb_timer_set_reg_ctrl_1
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_access_d1 & (ovl_paddr_d1[9:0] == 10'h000) ),
     .consequent_expr   (reg_ctrl == (ovl_reg_ctrl_d1 | ({1'b0, 1'b0, ovl_pwdata_d1[1], 1'b0})))
     );


   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Enable"
      )
    u_ovl_apb_timer_set_reg_ctrl_0
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_access_d1 & (ovl_paddr_d1[9:0] == 10'h000) ),
     .consequent_expr   (reg_ctrl == (ovl_reg_ctrl_d1 | ({1'b0, 1'b0, 1'b0, ovl_pwdata_d1[0]})))
     );


   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Enable"
      )
    u_ovl_apb_timer_value_reg
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_setup_d1 & (ovl_paddr_d1[9:0] == 10'h001) ),
     .consequent_expr   (reg_curr_val == (ovl_pwdata_d1))
     );


   assert_implication
    #(`OVL_ERROR, 
      `OVL_ASSERT,
      "Write 1 to set the Enable"
      )
    u_ovl_apb_timer_reload_reg
    (.clk               (PCLK ),
     .reset_n           (PRESETn),
     .antecedent_expr   (ovl_write_access_d1 & (ovl_paddr_d1[9:0] == 10'h002) ),
     .consequent_expr   (reg_reload_val == (ovl_pwdata_d1))
     );


   assert_always
     #(`OVL_ERROR,`OVL_ASSERT,
       "The APB interface must only respond with OKAY.")
   u_ovl_no_apb_error
     (.clk      (PCLK),
      .reset_n  (PRESETn),
      .test_expr(PSLVERR == 1'b0)
      );


   assert_always
     #(`OVL_ERROR,`OVL_ASSERT,
       "The APB interface must have only zero wait states.")
   u_ovl_no_apb_wait_states
     (.clk      (PCLK),
      .reset_n  (PRESETn),
      .test_expr(PREADY == 1'b1)
      );




    assert_never_unknown
    #(`OVL_ERROR, 1, `OVL_ASSERT,
      "APB Timer TIMERINT went X")
     u_ovl_apb_timer_timerint_x (
     .clk(PCLK),
     .reset_n(PRESETn),
     .qualifier(1'b1),
     .test_expr(TIMERINT)
     );


    assert_never_unknown
    #(`OVL_ERROR, 32, `OVL_ASSERT,
      "APB Timer PRDATA went X")
     u_ovl_apb_timer_prdata_x (
     .clk (PCLK),
     .reset_n (PRESETn),
     .qualifier (1'b1),
     .test_expr (PRDATA)
     );

`endif

endmodule
