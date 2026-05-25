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

module mhuv2_f1_snd_mhu_reg #(
  parameter [6:0] MHU_NUM_CH        = 7'd1
)
(
  input   wire                          pclk,
  input   wire                          presetn,

  input   wire                          sel_i,
  input   wire  [11:0]                  addr_i,
  input   wire                          read_en_i,
  input   wire                          write_en_i,
  input   wire  [2:0]                   wdata_i,
  input   wire                          access_rdy_i,
  input   wire                          channel_sel_i,
  input   wire  [MHU_NUM_CH-1:0]      edge_pulse_i,
  output  wire  [31:0]                  rdata_o,

  output  wire                          int_access_nr2r_o,
  output  wire                          int_access_r2nr_o,
  output  wire                          int_irqcomb_o,
  output  wire                          resp_cfg_o,
  output  wire                          access_req_o
  );


  wire          ready_resp_cfg;

  wire          ready_access_req;
  wire          ready_access_rdy;

  wire          ready_int_access_stat;
  wire          ready_int_access_clr;
  wire          ready_int_access_en;

  wire  [2:0]   wdata_en;
  
  wire [11:0]   rdata_sel;

  wire          access_rdy_rise;
  wire          access_rdy_fall;

  wire          access_req_rise;

  wire          wr_resp_cfg;
  wire          wr_access_req;

  wire          set_int_access_nr2r;
  wire          clr_int_access_nr2r;
  wire          en_int_access_nr2r;

  wire          set_int_access_r2nr;
  wire          clr_int_access_r2nr;
  wire          en_int_access_r2nr;

  wire          clr_int_access_en;

  reg           resp_cfg;

  reg           access_req;
  reg           access_rdy_reg;
  reg           access_rdy_edge_reg;

  reg [1:0]     int_access;
  reg [2:0]     int_access_en;

  reg [31:0]    rdata_mux;

  reg [MHU_NUM_CH-1:0] ch_int_st;
  reg [MHU_NUM_CH-1:0] ch_int_en;

  wire [6:0]    channel;
  wire          ready_ch_int_clr;
  wire          ready_ch_int_st;
  wire          ready_ch_int_en;
  wire          wr_ch_int_clr;
  wire          wr_ch_int_en;

  wire          ready_int_st0;
  wire          ready_int_st1;
  wire          ready_int_st2;
  wire          ready_int_st3;
  
  wire [127:0]  chcomb_int_st;
  wire [127:0]  ch_int_st_nxt;
  
  wire [127:0]  ch_int_en_ext;
  
  wire [MHU_NUM_CH-1:0] ch_clr_irq;


  assign ready_resp_cfg        = (addr_i == (12'hF84))? sel_i: 1'b0;

  assign ready_access_req      = (addr_i == (12'hF88))? sel_i: 1'b0;
  assign ready_access_rdy      = (addr_i == (12'hF8C))? sel_i: 1'b0;

  assign ready_int_access_stat = (addr_i == (12'hF90))? sel_i: 1'b0;
  assign ready_int_access_clr  = (addr_i == (12'hF94))? sel_i: 1'b0;
  assign ready_int_access_en   = (addr_i == (12'hF98))? sel_i: 1'b0;

  assign ready_int_st0         = (addr_i == (12'hFA0))? sel_i: 1'b0;
  assign ready_int_st1         = (addr_i == (12'hFA4))? sel_i: 1'b0;
  assign ready_int_st2         = (addr_i == (12'hFA8))? sel_i: 1'b0;
  assign ready_int_st3         = (addr_i == (12'hFAC))? sel_i: 1'b0;

  assign wdata_en              = (write_en_i)? wdata_i: 3'b00;

  assign ready_ch_int_st       = (addr_i[4:0] == 5'h10)? channel_sel_i: 1'b0;
  assign ready_ch_int_clr      = (addr_i[4:0] == 5'h14)? channel_sel_i: 1'b0;
  assign ready_ch_int_en       = (addr_i[4:0] == 5'h18)? channel_sel_i: 1'b0;
  assign channel               = ({7{channel_sel_i}} & addr_i[11:5]);


  assign access_rdy_rise       = (access_rdy_i == 1'b1) && (access_rdy_edge_reg == 1'b0);

  assign access_rdy_fall       = (access_rdy_i == 1'b0) && (access_rdy_edge_reg == 1'b1);

  always @(posedge pclk or negedge presetn)
  if(!presetn)
    access_rdy_edge_reg <= 1'b0;
  else
    access_rdy_edge_reg <= access_rdy_i;

  assign access_req_rise        = (access_req == 1'b0) && (ready_access_req & write_en_i & wdata_en[0]);


  assign wr_resp_cfg            = write_en_i & ready_resp_cfg;

  assign wr_access_req          = write_en_i & ready_access_req;

  assign set_int_access_nr2r    = (access_rdy_rise & access_req) | (access_rdy_i & access_req_rise);
  assign clr_int_access_nr2r    = (write_en_i & ready_int_access_clr & wdata_en[0]);
  assign en_int_access_nr2r     = set_int_access_nr2r | clr_int_access_nr2r;

  assign set_int_access_r2nr    = access_rdy_fall;
  assign clr_int_access_r2nr    = write_en_i & ready_int_access_clr & wdata_en[1];
  assign en_int_access_r2nr     = set_int_access_r2nr | clr_int_access_r2nr;

  assign clr_int_access_en      = write_en_i & ready_int_access_en;

  assign wr_ch_int_clr          = write_en_i & ready_ch_int_clr;
  assign wr_ch_int_en           = write_en_i & ready_ch_int_en;

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      resp_cfg <= 1'b0;
    else if (wr_resp_cfg)
      resp_cfg <= wdata_en[0];

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      access_req <= 1'b0;
    else if (wr_access_req)
      access_req <= wdata_en[0];

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      access_rdy_reg <= 1'b0;
    else
      access_rdy_reg <= access_rdy_i;

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      int_access[0] <= 1'b0;
    else if (en_int_access_nr2r)
      int_access[0] <= set_int_access_nr2r;

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      int_access[1] <= 1'b0;
    else if (en_int_access_r2nr)
      int_access[1] <= set_int_access_r2nr;

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      int_access_en <= 3'b100;
    else if (clr_int_access_en)
      int_access_en <= wdata_en[2:0];

    
  generate
  genvar i;
    for (i=0; i<{25'h0, MHU_NUM_CH}; i=i+1) begin : mhuv2_f1_snd_mhu_reg_genblock_1
      
      always @(posedge pclk or negedge presetn) begin
        if(!presetn)
          ch_int_st[i] <= 1'b0;
        else if (({25'h0, addr_i[11:5]} == i) | edge_pulse_i[i])
          ch_int_st[i] <= ch_int_st_nxt[i];
      end        
       
      assign ch_int_st_nxt[i] = (wr_ch_int_clr & wdata_en[0]) ? edge_pulse_i[i] : (ch_int_st[i] | edge_pulse_i[i]);
      
      always @(posedge pclk or negedge presetn) begin
      if (!presetn)
        ch_int_en[i] <= 1'b0;
      else if (({25'h0, addr_i[11:5]} == i) & wr_ch_int_en)
        ch_int_en[i] <= wdata_en[0];
      end
    end
  endgenerate
  
  assign chcomb_int_st[127:MHU_NUM_CH] = {(127-(MHU_NUM_CH-1)){1'b0}};
  assign chcomb_int_st[MHU_NUM_CH-1:0] = ch_int_st;

  assign ch_int_en_ext[127:MHU_NUM_CH] = {(127-(MHU_NUM_CH-1)){1'b0}};
  assign ch_int_en_ext[MHU_NUM_CH-1:0] = ch_int_en;
  
  assign ch_clr_irq = (ch_int_st & ch_int_en);
  

  assign rdata_sel = {ready_int_access_en, 
                      ready_access_rdy, 
                      ready_access_req, 
                      ready_int_access_stat,
                      ready_resp_cfg,
                      ready_ch_int_st,
                      ready_ch_int_clr,
                      ready_ch_int_en,
                      ready_int_st0,
                      ready_int_st1,
                      ready_int_st2,
                      ready_int_st3};

  always @(*)
    case (read_en_i)
      1'b1: begin
        rdata_mux = (&(rdata_sel ^ (~rdata_sel))) ? 32'h0000_0000 : 32'hFFFF_FFFF; 
        case(rdata_sel)
          12'b100000000000:  rdata_mux = {{29{1'b0}},int_access_en};            
          12'b010000000000:  rdata_mux = {{31{1'b0}},access_rdy_reg};           
          12'b001000000000:  rdata_mux = {{31{1'b0}},access_req};               
          12'b000100000000:  rdata_mux = {{29{1'b0}},|ch_int_st,int_access};    
          12'b000010000000:  rdata_mux = {{31{1'b0}},resp_cfg};                 
          12'b000001000000:  rdata_mux = {{31{1'b0}},chcomb_int_st[channel]};   
          12'b000000100000:  rdata_mux = { 32{1'b0}};                           
          12'b000000010000:  rdata_mux = {{31{1'b0}},ch_int_en_ext[channel]};   
          12'b000000001000:  rdata_mux = chcomb_int_st[31:0];                   
          12'b000000000100:  rdata_mux = chcomb_int_st[63:32];                  
          12'b000000000010:  rdata_mux = chcomb_int_st[95:64];                  
          12'b000000000001:  rdata_mux = chcomb_int_st[127:96];                 
        endcase
      end
      1'b0:      rdata_mux = {32{1'b0}};
      default:   rdata_mux = {32{1'bx}};
    endcase


  assign  rdata_o       = rdata_mux;

  assign  resp_cfg_o    = resp_cfg;
  assign  access_req_o  = access_req;

  assign int_access_nr2r_o = int_access[0] & int_access_en[0];
  assign int_access_r2nr_o = int_access[1] & int_access_en[1];
  assign int_irqcomb_o     = (int_access_nr2r_o | int_access_r2nr_o | (|ch_clr_irq)) & int_access_en[2];

endmodule
