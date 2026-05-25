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

module mhuv2_f1_rec_mhu_reg #(

  parameter [31:0] BASE_ADDR = 32'h0000_0000 
)

(
  input   wire                          pclk,
  input   wire                          presetn,

  input   wire                          sel_rec_i,
  input   wire  [11:0]                  addr_rec_i,
  input   wire  [3:0]                   writeen_rec_i,
  input   wire  [31:0]                  wdata_rec_i,
  output  wire  [31:0]                  rdata_rec_o,

  input   wire                          sel_snd_i,
  input   wire  [11:0]                  addr_snd_i,
  input   wire  [3:0]                   writeen_snd_i,
  input   wire  [31:0]                  wdata_snd_i,
  output  wire  [31:0]                  rdata_snd_o,

  output  wire                          reg_irq_o,
  output  wire                          edge_pulse_o
  );


  wire          ready_rec;
  wire          ready_stat_rec;
  wire          ready_stat_pend;
  wire          ready_statclr;
  wire          ready_mask;
  wire          ready_maskset;
  wire          ready_maskclr;

  wire          ready_snd;
  wire          ready_stat_snd;
  wire          ready_statset;

  wire  [7:0]   wdata_snd_0;
  wire  [7:0]   wdata_snd_1;
  wire  [7:0]   wdata_snd_2;
  wire  [7:0]   wdata_snd_3;
  wire  [31:0]  wdata_snd_en;
  wire          write_snd_en;

  wire  [7:0]   wdata_rec_0;
  wire  [7:0]   wdata_rec_1;
  wire  [7:0]   wdata_rec_2;
  wire  [7:0]   wdata_rec_3;
  wire  [31:0]  wdata_rec_en;
  wire          write_rec_en;

  wire          write_snd_rec_en;

  wire [31:0]   masked_stat_reg;

  reg   [31:0]  stat_reg;
  reg   [31:0]  stat_reg_comb;
  reg   [31:0]  mask_reg;
  reg   [31:0]  mask_reg_comb;

  reg [31:0]    rdata_rec_mux;
  reg [31:0]    rdata_snd_mux;


  assign ready_rec        = ({addr_rec_i[11:5],5'b00000} == BASE_ADDR[11:0])? 1'b1: 1'b0;
  assign ready_stat_rec   = (ready_rec && (addr_rec_i[4:0] == 5'h00))? sel_rec_i: 1'b0;
  assign ready_stat_pend  = (ready_rec && (addr_rec_i[4:0] == 5'h04))? sel_rec_i: 1'b0;
  assign ready_statclr    = (ready_rec && (addr_rec_i[4:0] == 5'h08))? sel_rec_i: 1'b0;
  assign ready_mask       = (ready_rec && (addr_rec_i[4:0] == 5'h10))? sel_rec_i: 1'b0;
  assign ready_maskset    = (ready_rec && (addr_rec_i[4:0] == 5'h14))? sel_rec_i: 1'b0;
  assign ready_maskclr    = (ready_rec && (addr_rec_i[4:0] == 5'h18))? sel_rec_i: 1'b0;

  assign ready_snd        = ({addr_snd_i[11:5],5'b00000} == BASE_ADDR[11:0]) ? 1'b1 : 1'b0;
  assign ready_stat_snd   = (ready_snd && (addr_snd_i[4:0] == 5'h00))? sel_snd_i: 1'b0;
  assign ready_statset    = (ready_snd && (addr_snd_i[4:0] == 5'h0C))? sel_snd_i: 1'b0;

  assign wdata_snd_0      = writeen_snd_i[0]? wdata_snd_i[7:0]   : 8'h00;
  assign wdata_snd_1      = writeen_snd_i[1]? wdata_snd_i[15:8]  : 8'h00;
  assign wdata_snd_2      = writeen_snd_i[2]? wdata_snd_i[23:16] : 8'h00;
  assign wdata_snd_3      = writeen_snd_i[3]? wdata_snd_i[31:24] : 8'h00;
  assign wdata_snd_en     = {wdata_snd_3, wdata_snd_2, wdata_snd_1, wdata_snd_0};
  assign write_snd_en     = (|writeen_snd_i) & sel_snd_i;

  assign wdata_rec_0      = writeen_rec_i[0]? wdata_rec_i[7:0]   : 8'h00;
  assign wdata_rec_1      = writeen_rec_i[1]? wdata_rec_i[15:8]  : 8'h00;
  assign wdata_rec_2      = writeen_rec_i[2]? wdata_rec_i[23:16] : 8'h00;
  assign wdata_rec_3      = writeen_rec_i[3]? wdata_rec_i[31:24] : 8'h00;
  assign wdata_rec_en     = {wdata_rec_3, wdata_rec_2, wdata_rec_1, wdata_rec_0};
  assign write_rec_en     = (|writeen_rec_i) & sel_rec_i;

  assign write_snd_rec_en = write_snd_en | write_rec_en;

  always @(*)
    case({write_snd_rec_en, ready_statset, ready_statclr})
      3'b000,
      3'b001,
      3'b010,
      3'b011,
      3'b100:   stat_reg_comb = stat_reg;
      3'b101:   stat_reg_comb = stat_reg & ~wdata_rec_en;
      3'b110:   stat_reg_comb = stat_reg | wdata_snd_en;
      3'b111:   stat_reg_comb = (stat_reg & ~wdata_rec_en) | wdata_snd_en;
      default:  stat_reg_comb = {32{1'bx}};
    endcase

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      stat_reg <= {32{1'b0}};
    else
      stat_reg <= stat_reg_comb;

  always @(*)
    case({write_rec_en, ready_maskset, ready_maskclr})
      3'b000,
      3'b001,
      3'b010,
      3'b011,
      3'b100,
      3'b111:   mask_reg_comb = mask_reg;
      3'b101:   mask_reg_comb = mask_reg & ~wdata_rec_en;
      3'b110:   mask_reg_comb = mask_reg | wdata_rec_en;
      default:  mask_reg_comb = {32{1'bx}};
    endcase

  always @(posedge pclk or negedge presetn)
    if(!presetn)
      mask_reg <= {32{1'b0}};
    else
      mask_reg <= mask_reg_comb;

  assign masked_stat_reg = stat_reg & ~mask_reg;


  always @(*)
    case({ready_stat_rec, ready_stat_pend, ready_mask})
      3'b000,
      3'b011,
      3'b101,
      3'b110,
      3'b111:  rdata_rec_mux = {32{1'b0}};
      3'b100:  rdata_rec_mux = stat_reg;
      3'b010:  rdata_rec_mux = masked_stat_reg;
      3'b001:  rdata_rec_mux = mask_reg;
      default: rdata_rec_mux = {32{1'bx}};
    endcase

  always @(*)
    case(ready_stat_snd)
      1'b0:   rdata_snd_mux = {32{1'b0}};
      1'b1:   rdata_snd_mux = stat_reg;
      default: rdata_snd_mux = {32{1'bx}};
    endcase



  assign rdata_rec_o = rdata_rec_mux;
  assign rdata_snd_o = rdata_snd_mux;

  assign  reg_irq_o = |(stat_reg & ~mask_reg) ;

  assign  edge_pulse_o = ready_statclr & write_rec_en;

endmodule
