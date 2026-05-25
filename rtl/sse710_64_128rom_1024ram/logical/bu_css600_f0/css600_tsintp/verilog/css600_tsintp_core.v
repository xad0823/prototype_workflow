//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2012, 2016-2017, 2019-2020 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_tsintp
//
//----------------------------------------------------------------------------


module css600_tsintp_core
  (
  input wire clk,
  input wire resetn,

  input wire [63:0] tsvalueb,

  output reg [63:0] tsvalueintpb,

  input  lp_req,
  output lp_ack

);

localparam CLK_SCLK_R = 256;

localparam CLK_SCLK_R_WIDTH = 8;


localparam SCLK_R_WIDTH = 6;

localparam NUM_FRACT_BITS = 4;

localparam INCRMNTR_WIDTH = CLK_SCLK_R_WIDTH+SCLK_R_WIDTH+NUM_FRACT_BITS;


localparam LUT_ENTRY_WIDTH = CLK_SCLK_R_WIDTH+NUM_FRACT_BITS+1;
localparam CLK_SCLK_R_BIN = 8'b11111111;
localparam SCLK_R_ENC_WIDTH = 3;

reg [(SCLK_R_ENC_WIDTH-1):0] nxt_sclk_ratio;
reg [2:0] sclk_ratio_high_sel1;
reg [2:0] sclk_ratio_high_sel2;
wire intp_restart;
wire [(INCRMNTR_WIDTH-1):0] incrmntr_max_val_minus_incrmntr;
wire [(INCRMNTR_WIDTH-1):0] nxt_incrmntr;
wire [(INCRMNTR_WIDTH-1):0] incrmntr_incr_val;
wire [(INCRMNTR_WIDTH-1):0] incrmntr_incr_sat;
wire tsvalueb_zero;
wire [INCRMNTR_WIDTH-1:0] incr;


wire quiescence;
wire lp_req_en;

reg [(SCLK_R_ENC_WIDTH-1):0] sclk_ratio;
wire [(SCLK_R_ENC_WIDTH-1):0] sclk_ratio_muxed;
reg [(63-CLK_SCLK_R_WIDTH):0] tsvalueb_reg;
reg [(INCRMNTR_WIDTH-1):0] incrmntr;


reg lp_ack_rg;


  reg [1:0] sclk_quisc_cnt;
  reg [1:0] nxt_sclk_quisc_cnt;
  wire input_chg;
  wire intp_en;

  assign lp_req_en = (lp_ack_rg != lp_req);

  always @(posedge clk or negedge resetn)
    begin
      if (!resetn)
        lp_ack_rg <= 1'b0;
      else if (lp_req_en)
      begin
        lp_ack_rg <= lp_req;
      end
    end

  always @(posedge clk or negedge resetn)
    begin
      if (!resetn)
        sclk_quisc_cnt <= 2'b0;
      else
        sclk_quisc_cnt <= nxt_sclk_quisc_cnt;
    end

always @*
begin
  if (quiescence)
    nxt_sclk_quisc_cnt = 2'b10;
  else if (input_chg)
    nxt_sclk_quisc_cnt = (|(sclk_quisc_cnt)) ? sclk_quisc_cnt - 2'b1 : sclk_quisc_cnt;
  else
    nxt_sclk_quisc_cnt = sclk_quisc_cnt;
end


  assign lp_ack = lp_ack_rg;
  assign quiescence = lp_ack_rg & lp_req;

  assign input_chg = |(tsvalueb[(63-CLK_SCLK_R_WIDTH):0] ^ tsvalueb_reg);
  assign intp_en = ~|(nxt_sclk_quisc_cnt);


always @*
begin
  if (tsvalueb[0] != tsvalueb_reg[0])
    nxt_sclk_ratio = 3'b000;
  else if (tsvalueb[1] != tsvalueb_reg[1])
    nxt_sclk_ratio = 3'b001;
  else
    nxt_sclk_ratio = sclk_ratio_high_sel1;
end

always @*
begin
  if (tsvalueb[2] != tsvalueb_reg[2])
    sclk_ratio_high_sel1 = 3'b010;
  else if (tsvalueb[3] != tsvalueb_reg[3])
    sclk_ratio_high_sel1 = 3'b011;
  else
    sclk_ratio_high_sel1 = sclk_ratio_high_sel2;
end

always @*
begin
  if (tsvalueb[4] != tsvalueb_reg[4])
    sclk_ratio_high_sel2 = 3'b100;
  else if (tsvalueb[5] != tsvalueb_reg[5])
    sclk_ratio_high_sel2 = 3'b101;
  else
    sclk_ratio_high_sel2 = 3'b110;
end

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    begin
      sclk_ratio <= {SCLK_R_ENC_WIDTH{1'b0}};
    end
  else if (intp_restart)
    begin
      sclk_ratio <= nxt_sclk_ratio;
    end
end

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    begin
      tsvalueb_reg <= {(64-CLK_SCLK_R_WIDTH){1'b0}};
    end
  else if (intp_restart)
    begin
      tsvalueb_reg <= tsvalueb[(63-CLK_SCLK_R_WIDTH):0];
    end
end

assign tsvalueb_zero = ~|(tsvalueb[(63-CLK_SCLK_R_WIDTH):0]);

assign intp_restart = |(tsvalueb[(63-CLK_SCLK_R_WIDTH):0] ^ tsvalueb_reg) | quiescence;

localparam CLK_RATIO_CNT_WIDTH = CLK_SCLK_R_WIDTH + SCLK_R_WIDTH;

reg [(CLK_RATIO_CNT_WIDTH-1):0] clock_ratio_cnt;
wire [(CLK_RATIO_CNT_WIDTH-1):0] clock_ratio_cnt_incr;
wire [(CLK_RATIO_CNT_WIDTH-1):0] nxt_clock_ratio_cnt;

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    clock_ratio_cnt <= {CLK_RATIO_CNT_WIDTH{1'b0}};
  else
    clock_ratio_cnt <= nxt_clock_ratio_cnt;
end

assign nxt_clock_ratio_cnt = intp_restart ?
                               {CLK_RATIO_CNT_WIDTH{1'b0}} :
                               clock_ratio_cnt_incr;

assign clock_ratio_cnt_incr =
                               (&(clock_ratio_cnt)) ?
                               clock_ratio_cnt :
                               (clock_ratio_cnt +
                                 {{(CLK_RATIO_CNT_WIDTH-1){1'b0}}, 1'b1});

reg [(CLK_RATIO_CNT_WIDTH-1):0] clock_ratio;
wire [(CLK_RATIO_CNT_WIDTH-1):0] nxt_clock_ratio;

always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    clock_ratio <= {CLK_RATIO_CNT_WIDTH{1'b0}};
  else if (intp_restart)
    clock_ratio <= nxt_clock_ratio;
end

assign nxt_clock_ratio = clock_ratio_cnt;


reg [(CLK_RATIO_CNT_WIDTH-1):0] clock_ratio_shft;

always @*
begin
  case (sclk_ratio)
    3'b000 : clock_ratio_shft = clock_ratio;
    3'b001 : clock_ratio_shft =
      {1'b0, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):1]};
    3'b010 : clock_ratio_shft =
      {2'b00, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):2]};
    3'b011 : clock_ratio_shft =
      {3'b000, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):3]};
    3'b100 : clock_ratio_shft =
      {4'b0000, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):4]};
    3'b101 : clock_ratio_shft =
      {5'b00000, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):5]};
    3'b110 : clock_ratio_shft =
      {6'b000000, clock_ratio[(CLK_RATIO_CNT_WIDTH-1):6]};


    default : clock_ratio_shft = {CLK_RATIO_CNT_WIDTH{1'bx}};
  endcase
end

wire [(CLK_SCLK_R_WIDTH-1):0] clock_ratio_adj;

assign clock_ratio_adj = (clock_ratio_shft >
                           {{(CLK_RATIO_CNT_WIDTH-CLK_SCLK_R_WIDTH){1'b0}},
                           CLK_SCLK_R_BIN}) ?
                           CLK_SCLK_R_BIN :
                           clock_ratio_shft[(CLK_SCLK_R_WIDTH-1):0];


wire [(LUT_ENTRY_WIDTH-1) : 0] lut_incr [(CLK_SCLK_R-1):0];

assign lut_incr[0] = 13'b1000000000000;
assign lut_incr[1] = 13'b0100000000000;
assign lut_incr[2] = 13'b0010101010101;
assign lut_incr[3] = 13'b0010000000000;
assign lut_incr[4] = 13'b0001100110011;
assign lut_incr[5] = 13'b0001010101010;
assign lut_incr[6] = 13'b0001001001001;
assign lut_incr[7] = 13'b0001000000000;
assign lut_incr[8] = 13'b0000111000111;
assign lut_incr[9] = 13'b0000110011001;
assign lut_incr[10] = 13'b0000101110100;
assign lut_incr[11] = 13'b0000101010101;
assign lut_incr[12] = 13'b0000100111011;
assign lut_incr[13] = 13'b0000100100100;
assign lut_incr[14] = 13'b0000100010001;
assign lut_incr[15] = 13'b0000100000000;
assign lut_incr[16] = 13'b0000011110000;
assign lut_incr[17] = 13'b0000011100011;
assign lut_incr[18] = 13'b0000011010111;
assign lut_incr[19] = 13'b0000011001100;
assign lut_incr[20] = 13'b0000011000011;
assign lut_incr[21] = 13'b0000010111010;
assign lut_incr[22] = 13'b0000010110010;
assign lut_incr[23] = 13'b0000010101010;
assign lut_incr[24] = 13'b0000010100011;
assign lut_incr[25] = 13'b0000010011101;
assign lut_incr[26] = 13'b0000010010111;
assign lut_incr[27] = 13'b0000010010010;
assign lut_incr[28] = 13'b0000010001101;
assign lut_incr[29] = 13'b0000010001000;
assign lut_incr[30] = 13'b0000010000100;
assign lut_incr[31] = 13'b0000010000000;
assign lut_incr[32] = 13'b0000001111100;
assign lut_incr[33] = 13'b0000001111000;
assign lut_incr[34] = 13'b0000001110101;
assign lut_incr[35] = 13'b0000001110001;
assign lut_incr[36] = 13'b0000001101110;
assign lut_incr[37] = 13'b0000001101011;
assign lut_incr[38] = 13'b0000001101001;
assign lut_incr[39] = 13'b0000001100110;
assign lut_incr[40] = 13'b0000001100011;
assign lut_incr[41] = 13'b0000001100001;
assign lut_incr[42] = 13'b0000001011111;
assign lut_incr[43] = 13'b0000001011101;
assign lut_incr[44] = 13'b0000001011011;
assign lut_incr[45] = 13'b0000001011001;
assign lut_incr[46] = 13'b0000001010111;
assign lut_incr[47] = 13'b0000001010101;
assign lut_incr[48] = 13'b0000001010011;
assign lut_incr[49] = 13'b0000001010001;
assign lut_incr[50] = 13'b0000001010000;
assign lut_incr[51] = 13'b0000001001110;
assign lut_incr[52] = 13'b0000001001101;
assign lut_incr[53] = 13'b0000001001011;
assign lut_incr[54] = 13'b0000001001010;
assign lut_incr[55] = 13'b0000001001001;
assign lut_incr[56] = 13'b0000001000111;
assign lut_incr[57] = 13'b0000001000110;
assign lut_incr[58] = 13'b0000001000101;
assign lut_incr[59] = 13'b0000001000100;
assign lut_incr[60] = 13'b0000001000011;
assign lut_incr[61] = 13'b0000001000010;
assign lut_incr[62] = 13'b0000001000001;
assign lut_incr[63] = 13'b0000001000000;
assign lut_incr[64] = 13'b0000000111111;
assign lut_incr[65] = 13'b0000000111110;
assign lut_incr[66] = 13'b0000000111101;
assign lut_incr[67] = 13'b0000000111100;
assign lut_incr[68] = 13'b0000000111011;
assign lut_incr[69] = 13'b0000000111010;
assign lut_incr[70] = 13'b0000000111001;
assign lut_incr[71] = 13'b0000000111000;
assign lut_incr[72] = 13'b0000000111000;
assign lut_incr[73] = 13'b0000000110111;
assign lut_incr[74] = 13'b0000000110110;
assign lut_incr[75] = 13'b0000000110101;
assign lut_incr[76] = 13'b0000000110101;
assign lut_incr[77] = 13'b0000000110100;
assign lut_incr[78] = 13'b0000000110011;
assign lut_incr[79] = 13'b0000000110011;
assign lut_incr[80] = 13'b0000000110010;
assign lut_incr[81] = 13'b0000000110001;
assign lut_incr[82] = 13'b0000000110001;
assign lut_incr[83] = 13'b0000000110000;
assign lut_incr[84] = 13'b0000000110000;
assign lut_incr[85] = 13'b0000000101111;
assign lut_incr[86] = 13'b0000000101111;
assign lut_incr[87] = 13'b0000000101110;
assign lut_incr[88] = 13'b0000000101110;
assign lut_incr[89] = 13'b0000000101101;
assign lut_incr[90] = 13'b0000000101101;
assign lut_incr[91] = 13'b0000000101100;
assign lut_incr[92] = 13'b0000000101100;
assign lut_incr[93] = 13'b0000000101011;
assign lut_incr[94] = 13'b0000000101011;
assign lut_incr[95] = 13'b0000000101010;
assign lut_incr[96] = 13'b0000000101010;
assign lut_incr[97] = 13'b0000000101001;
assign lut_incr[98] = 13'b0000000101001;
assign lut_incr[99] = 13'b0000000101000;
assign lut_incr[100] = 13'b0000000101000;
assign lut_incr[101] = 13'b0000000101000;
assign lut_incr[102] = 13'b0000000100111;
assign lut_incr[103] = 13'b0000000100111;
assign lut_incr[104] = 13'b0000000100111;
assign lut_incr[105] = 13'b0000000100110;
assign lut_incr[106] = 13'b0000000100110;
assign lut_incr[107] = 13'b0000000100101;
assign lut_incr[108] = 13'b0000000100101;
assign lut_incr[109] = 13'b0000000100101;
assign lut_incr[110] = 13'b0000000100100;
assign lut_incr[111] = 13'b0000000100100;
assign lut_incr[112] = 13'b0000000100100;
assign lut_incr[113] = 13'b0000000100011;
assign lut_incr[114] = 13'b0000000100011;
assign lut_incr[115] = 13'b0000000100011;
assign lut_incr[116] = 13'b0000000100011;
assign lut_incr[117] = 13'b0000000100010;
assign lut_incr[118] = 13'b0000000100010;
assign lut_incr[119] = 13'b0000000100010;
assign lut_incr[120] = 13'b0000000100001;
assign lut_incr[121] = 13'b0000000100001;
assign lut_incr[122] = 13'b0000000100001;
assign lut_incr[123] = 13'b0000000100001;
assign lut_incr[124] = 13'b0000000100000;
assign lut_incr[125] = 13'b0000000100000;
assign lut_incr[126] = 13'b0000000100000;
assign lut_incr[127] = 13'b0000000100000;
assign lut_incr[128] = 13'b0000000011111;
assign lut_incr[129] = 13'b0000000011111;
assign lut_incr[130] = 13'b0000000011111;
assign lut_incr[131] = 13'b0000000011111;
assign lut_incr[132] = 13'b0000000011110;
assign lut_incr[133] = 13'b0000000011110;
assign lut_incr[134] = 13'b0000000011110;
assign lut_incr[135] = 13'b0000000011110;
assign lut_incr[136] = 13'b0000000011101;
assign lut_incr[137] = 13'b0000000011101;
assign lut_incr[138] = 13'b0000000011101;
assign lut_incr[139] = 13'b0000000011101;
assign lut_incr[140] = 13'b0000000011101;
assign lut_incr[141] = 13'b0000000011100;
assign lut_incr[142] = 13'b0000000011100;
assign lut_incr[143] = 13'b0000000011100;
assign lut_incr[144] = 13'b0000000011100;
assign lut_incr[145] = 13'b0000000011100;
assign lut_incr[146] = 13'b0000000011011;
assign lut_incr[147] = 13'b0000000011011;
assign lut_incr[148] = 13'b0000000011011;
assign lut_incr[149] = 13'b0000000011011;
assign lut_incr[150] = 13'b0000000011011;
assign lut_incr[151] = 13'b0000000011010;
assign lut_incr[152] = 13'b0000000011010;
assign lut_incr[153] = 13'b0000000011010;
assign lut_incr[154] = 13'b0000000011010;
assign lut_incr[155] = 13'b0000000011010;
assign lut_incr[156] = 13'b0000000011010;
assign lut_incr[157] = 13'b0000000011001;
assign lut_incr[158] = 13'b0000000011001;
assign lut_incr[159] = 13'b0000000011001;
assign lut_incr[160] = 13'b0000000011001;
assign lut_incr[161] = 13'b0000000011001;
assign lut_incr[162] = 13'b0000000011001;
assign lut_incr[163] = 13'b0000000011000;
assign lut_incr[164] = 13'b0000000011000;
assign lut_incr[165] = 13'b0000000011000;
assign lut_incr[166] = 13'b0000000011000;
assign lut_incr[167] = 13'b0000000011000;
assign lut_incr[168] = 13'b0000000011000;
assign lut_incr[169] = 13'b0000000011000;
assign lut_incr[170] = 13'b0000000010111;
assign lut_incr[171] = 13'b0000000010111;
assign lut_incr[172] = 13'b0000000010111;
assign lut_incr[173] = 13'b0000000010111;
assign lut_incr[174] = 13'b0000000010111;
assign lut_incr[175] = 13'b0000000010111;
assign lut_incr[176] = 13'b0000000010111;
assign lut_incr[177] = 13'b0000000010111;
assign lut_incr[178] = 13'b0000000010110;
assign lut_incr[179] = 13'b0000000010110;
assign lut_incr[180] = 13'b0000000010110;
assign lut_incr[181] = 13'b0000000010110;
assign lut_incr[182] = 13'b0000000010110;
assign lut_incr[183] = 13'b0000000010110;
assign lut_incr[184] = 13'b0000000010110;
assign lut_incr[185] = 13'b0000000010110;
assign lut_incr[186] = 13'b0000000010101;
assign lut_incr[187] = 13'b0000000010101;
assign lut_incr[188] = 13'b0000000010101;
assign lut_incr[189] = 13'b0000000010101;
assign lut_incr[190] = 13'b0000000010101;
assign lut_incr[191] = 13'b0000000010101;
assign lut_incr[192] = 13'b0000000010101;
assign lut_incr[193] = 13'b0000000010101;
assign lut_incr[194] = 13'b0000000010101;
assign lut_incr[195] = 13'b0000000010100;
assign lut_incr[196] = 13'b0000000010100;
assign lut_incr[197] = 13'b0000000010100;
assign lut_incr[198] = 13'b0000000010100;
assign lut_incr[199] = 13'b0000000010100;
assign lut_incr[200] = 13'b0000000010100;
assign lut_incr[201] = 13'b0000000010100;
assign lut_incr[202] = 13'b0000000010100;
assign lut_incr[203] = 13'b0000000010100;
assign lut_incr[204] = 13'b0000000010011;
assign lut_incr[205] = 13'b0000000010011;
assign lut_incr[206] = 13'b0000000010011;
assign lut_incr[207] = 13'b0000000010011;
assign lut_incr[208] = 13'b0000000010011;
assign lut_incr[209] = 13'b0000000010011;
assign lut_incr[210] = 13'b0000000010011;
assign lut_incr[211] = 13'b0000000010011;
assign lut_incr[212] = 13'b0000000010011;
assign lut_incr[213] = 13'b0000000010011;
assign lut_incr[214] = 13'b0000000010011;
assign lut_incr[215] = 13'b0000000010010;
assign lut_incr[216] = 13'b0000000010010;
assign lut_incr[217] = 13'b0000000010010;
assign lut_incr[218] = 13'b0000000010010;
assign lut_incr[219] = 13'b0000000010010;
assign lut_incr[220] = 13'b0000000010010;
assign lut_incr[221] = 13'b0000000010010;
assign lut_incr[222] = 13'b0000000010010;
assign lut_incr[223] = 13'b0000000010010;
assign lut_incr[224] = 13'b0000000010010;
assign lut_incr[225] = 13'b0000000010010;
assign lut_incr[226] = 13'b0000000010010;
assign lut_incr[227] = 13'b0000000010001;
assign lut_incr[228] = 13'b0000000010001;
assign lut_incr[229] = 13'b0000000010001;
assign lut_incr[230] = 13'b0000000010001;
assign lut_incr[231] = 13'b0000000010001;
assign lut_incr[232] = 13'b0000000010001;
assign lut_incr[233] = 13'b0000000010001;
assign lut_incr[234] = 13'b0000000010001;
assign lut_incr[235] = 13'b0000000010001;
assign lut_incr[236] = 13'b0000000010001;
assign lut_incr[237] = 13'b0000000010001;
assign lut_incr[238] = 13'b0000000010001;
assign lut_incr[239] = 13'b0000000010001;
assign lut_incr[240] = 13'b0000000010000;
assign lut_incr[241] = 13'b0000000010000;
assign lut_incr[242] = 13'b0000000010000;
assign lut_incr[243] = 13'b0000000010000;
assign lut_incr[244] = 13'b0000000010000;
assign lut_incr[245] = 13'b0000000010000;
assign lut_incr[246] = 13'b0000000010000;
assign lut_incr[247] = 13'b0000000010000;
assign lut_incr[248] = 13'b0000000010000;
assign lut_incr[249] = 13'b0000000010000;
assign lut_incr[250] = 13'b0000000010000;
assign lut_incr[251] = 13'b0000000010000;
assign lut_incr[252] = 13'b0000000010000;
assign lut_incr[253] = 13'b0000000010000;
assign lut_incr[254] = 13'b0000000010000;
assign lut_incr[255] = 13'b0000000010000;


always @(posedge clk or negedge resetn)
begin
  if (!resetn)
    incrmntr <= {INCRMNTR_WIDTH{1'b0}};
  else if (intp_en)
    incrmntr <= nxt_incrmntr;
end


reg [INCRMNTR_WIDTH-1:0] incrmntr_max_val;
always @*
begin
  case (sclk_ratio)
    3'b000 : incrmntr_max_val =
               {{SCLK_R_WIDTH{1'b0}}, {(INCRMNTR_WIDTH-SCLK_R_WIDTH){1'b1}}};
    3'b001 : incrmntr_max_val =
               {{(SCLK_R_WIDTH-1){1'b0}},
               {(INCRMNTR_WIDTH-SCLK_R_WIDTH+1){1'b1}}};
    3'b010 : incrmntr_max_val =
               {{(SCLK_R_WIDTH-2){1'b0}},
               {(INCRMNTR_WIDTH-SCLK_R_WIDTH+2){1'b1}}};
    3'b011 : incrmntr_max_val =
               {{(SCLK_R_WIDTH-3){1'b0}},
               {(INCRMNTR_WIDTH-SCLK_R_WIDTH+3){1'b1}}};
    3'b100 : incrmntr_max_val =
               {{(SCLK_R_WIDTH-4){1'b0}},
               {(INCRMNTR_WIDTH-SCLK_R_WIDTH+4){1'b1}}};
    3'b101 : incrmntr_max_val =
               {{(SCLK_R_WIDTH-5){1'b0}},
               {(INCRMNTR_WIDTH-SCLK_R_WIDTH+5){1'b1}}};
    3'b110 : incrmntr_max_val =
               {INCRMNTR_WIDTH{1'b1}};

    default : incrmntr_max_val = {INCRMNTR_WIDTH{1'bx}};
  endcase
end
assign incr = |(clock_ratio) ? {{(INCRMNTR_WIDTH-LUT_ENTRY_WIDTH){1'b0}}, lut_incr[clock_ratio_adj]} :
                               {INCRMNTR_WIDTH{1'b0}};


assign nxt_incrmntr = incrmntr_incr_val;

assign incrmntr_max_val_minus_incrmntr = (incrmntr_max_val - incrmntr);
assign incrmntr_incr_sat = (incr > incrmntr_max_val_minus_incrmntr) ?
                             incrmntr_max_val :
                             (incrmntr + incr);
assign incrmntr_incr_val = (intp_restart || tsvalueb_zero) ?
                             {INCRMNTR_WIDTH{1'b0}} :
                             incrmntr_incr_sat;

assign sclk_ratio_muxed = (|(clock_ratio) && ~quiescence) ? sclk_ratio : 3'b000;

always @*
begin
  case (sclk_ratio_muxed)
    3'b000 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 0],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS - 1):
                NUM_FRACT_BITS]};
    3'b001 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 1],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS):
                NUM_FRACT_BITS]};
    3'b010 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 2],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS + 1):
                NUM_FRACT_BITS]};
    3'b011 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 3],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS + 2):
                NUM_FRACT_BITS]};
    3'b100 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 4],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS + 3):
                NUM_FRACT_BITS]};
    3'b101 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 5],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS + 4):
                NUM_FRACT_BITS]};
    3'b110 : tsvalueintpb =
               {tsvalueb_reg[(63 - CLK_SCLK_R_WIDTH) : 6],
                incrmntr[(CLK_SCLK_R_WIDTH + NUM_FRACT_BITS + 5):
                NUM_FRACT_BITS]};


    default : tsvalueintpb = {64{1'bx}};
  endcase
end


endmodule

