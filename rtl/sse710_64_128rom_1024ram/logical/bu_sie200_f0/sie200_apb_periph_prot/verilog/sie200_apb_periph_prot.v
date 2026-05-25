// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Sep 15 11:45:39 2016 +0200
//
//      Revision            : 289e59f
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_apb_periph_prot #(
  parameter PORT0_ENABLE  = 1,
  parameter PORT1_ENABLE  = 1,
  parameter PORT2_ENABLE  = 1,
  parameter PORT3_ENABLE  = 1,
  parameter PORT4_ENABLE  = 1,
  parameter PORT5_ENABLE  = 1,
  parameter PORT6_ENABLE  = 1,
  parameter PORT7_ENABLE  = 1,
  parameter PORT8_ENABLE  = 1,
  parameter PORT9_ENABLE  = 1,
  parameter PORT10_ENABLE = 1,
  parameter PORT11_ENABLE = 1,
  parameter PORT12_ENABLE = 1,
  parameter PORT13_ENABLE = 1,
  parameter PORT14_ENABLE = 1,
  parameter PORT15_ENABLE = 1,
  parameter ADDR_WIDTH    = 32,
  parameter DATA_WIDTH    = 32,
  parameter [15:0] NONSEC_MASK  = 16'h0
)
(
  input  wire                    pclk,
  input  wire                    presetn,

  input  wire [15:0]             cfg_ap,
  input  wire [15:0]             cfg_nonsec,
  input  wire                    cfg_sec_resp,

  output reg                     apb_ppc_irq,
  input  wire                    apb_ppc_irq_clear,
  input  wire                    apb_ppc_irq_enable,

  input  wire [15:0]             psel_s,
  input  wire [ADDR_WIDTH-1:0]   paddr_s,
  input  wire [DATA_WIDTH/8-1:0] pstrb_s,
  input  wire                    pwrite_s,
  input  wire                    penable_s,
  input  wire [2:0]              pprot_s,
  input  wire [DATA_WIDTH-1:0]   pwdata_s,
  output wire [DATA_WIDTH-1:0]   prdata_s,
  output wire                    pready_s,
  output wire                    pslverr_s,

  output reg                     psel_m0,
  output reg  [ADDR_WIDTH-1:0]   paddr_m0,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m0,
  output reg                     pwrite_m0,
  output reg                     penable_m0,
  output reg  [2:0]              pprot_m0,
  output reg  [DATA_WIDTH-1:0]   pwdata_m0,
  input  wire [DATA_WIDTH-1:0]   prdata_m0,
  input  wire                    pready_m0,
  input  wire                    pslverr_m0,

  output reg                     psel_m1,
  output reg  [ADDR_WIDTH-1:0]   paddr_m1,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m1,
  output reg                     pwrite_m1,
  output reg                     penable_m1,
  output reg  [2:0]              pprot_m1,
  output reg  [DATA_WIDTH-1:0]   pwdata_m1,
  input  wire [DATA_WIDTH-1:0]   prdata_m1,
  input  wire                    pready_m1,
  input  wire                    pslverr_m1,

  output reg                     psel_m2,
  output reg  [ADDR_WIDTH-1:0]   paddr_m2,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m2,
  output reg                     pwrite_m2,
  output reg                     penable_m2,
  output reg  [2:0]              pprot_m2,
  output reg  [DATA_WIDTH-1:0]   pwdata_m2,
  input  wire [DATA_WIDTH-1:0]   prdata_m2,
  input  wire                    pready_m2,
  input  wire                    pslverr_m2,

  output reg                     psel_m3,
  output reg  [ADDR_WIDTH-1:0]   paddr_m3,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m3,
  output reg                     pwrite_m3,
  output reg                     penable_m3,
  output reg  [2:0]              pprot_m3,
  output reg  [DATA_WIDTH-1:0]   pwdata_m3,
  input  wire [DATA_WIDTH-1:0]   prdata_m3,
  input  wire                    pready_m3,
  input  wire                    pslverr_m3,

  output reg                     psel_m4,
  output reg  [ADDR_WIDTH-1:0]   paddr_m4,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m4,
  output reg                     pwrite_m4,
  output reg                     penable_m4,
  output reg  [2:0]              pprot_m4,
  output reg  [DATA_WIDTH-1:0]   pwdata_m4,
  input  wire [DATA_WIDTH-1:0]   prdata_m4,
  input  wire                    pready_m4,
  input  wire                    pslverr_m4,

  output reg                     psel_m5,
  output reg  [ADDR_WIDTH-1:0]   paddr_m5,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m5,
  output reg                     pwrite_m5,
  output reg                     penable_m5,
  output reg  [2:0]              pprot_m5,
  output reg  [DATA_WIDTH-1:0]   pwdata_m5,
  input  wire [DATA_WIDTH-1:0]   prdata_m5,
  input  wire                    pready_m5,
  input  wire                    pslverr_m5,

  output reg                     psel_m6,
  output reg  [ADDR_WIDTH-1:0]   paddr_m6,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m6,
  output reg                     pwrite_m6,
  output reg                     penable_m6,
  output reg  [2:0]              pprot_m6,
  output reg  [DATA_WIDTH-1:0]   pwdata_m6,
  input  wire [DATA_WIDTH-1:0]   prdata_m6,
  input  wire                    pready_m6,
  input  wire                    pslverr_m6,

  output reg                     psel_m7,
  output reg  [ADDR_WIDTH-1:0]   paddr_m7,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m7,
  output reg                     pwrite_m7,
  output reg                     penable_m7,
  output reg  [2:0]              pprot_m7,
  output reg  [DATA_WIDTH-1:0]   pwdata_m7,
  input  wire [DATA_WIDTH-1:0]   prdata_m7,
  input  wire                    pready_m7,
  input  wire                    pslverr_m7,

  output reg                     psel_m8,
  output reg  [ADDR_WIDTH-1:0]   paddr_m8,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m8,
  output reg                     pwrite_m8,
  output reg                     penable_m8,
  output reg  [2:0]              pprot_m8,
  output reg  [DATA_WIDTH-1:0]   pwdata_m8,
  input  wire [DATA_WIDTH-1:0]   prdata_m8,
  input  wire                    pready_m8,
  input  wire                    pslverr_m8,

  output reg                     psel_m9,
  output reg  [ADDR_WIDTH-1:0]   paddr_m9,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m9,
  output reg                     pwrite_m9,
  output reg                     penable_m9,
  output reg  [2:0]              pprot_m9,
  output reg  [DATA_WIDTH-1:0]   pwdata_m9,
  input  wire [DATA_WIDTH-1:0]   prdata_m9,
  input  wire                    pready_m9,
  input  wire                    pslverr_m9,

  output reg                     psel_m10,
  output reg  [ADDR_WIDTH-1:0]   paddr_m10,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m10,
  output reg                     pwrite_m10,
  output reg                     penable_m10,
  output reg  [2:0]              pprot_m10,
  output reg  [DATA_WIDTH-1:0]   pwdata_m10,
  input  wire [DATA_WIDTH-1:0]   prdata_m10,
  input  wire                    pready_m10,
  input  wire                    pslverr_m10,

  output reg                     psel_m11,
  output reg  [ADDR_WIDTH-1:0]   paddr_m11,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m11,
  output reg                     pwrite_m11,
  output reg                     penable_m11,
  output reg  [2:0]              pprot_m11,
  output reg  [DATA_WIDTH-1:0]   pwdata_m11,
  input  wire [DATA_WIDTH-1:0]   prdata_m11,
  input  wire                    pready_m11,
  input  wire                    pslverr_m11,

  output reg                     psel_m12,
  output reg  [ADDR_WIDTH-1:0]   paddr_m12,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m12,
  output reg                     pwrite_m12,
  output reg                     penable_m12,
  output reg  [2:0]              pprot_m12,
  output reg  [DATA_WIDTH-1:0]   pwdata_m12,
  input  wire [DATA_WIDTH-1:0]   prdata_m12,
  input  wire                    pready_m12,
  input  wire                    pslverr_m12,

  output reg                     psel_m13,
  output reg  [ADDR_WIDTH-1:0]   paddr_m13,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m13,
  output reg                     pwrite_m13,
  output reg                     penable_m13,
  output reg  [2:0]              pprot_m13,
  output reg  [DATA_WIDTH-1:0]   pwdata_m13,
  input  wire [DATA_WIDTH-1:0]   prdata_m13,
  input  wire                    pready_m13,
  input  wire                    pslverr_m13,

  output reg                     psel_m14,
  output reg  [ADDR_WIDTH-1:0]   paddr_m14,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m14,
  output reg                     pwrite_m14,
  output reg                     penable_m14,
  output reg  [2:0]              pprot_m14,
  output reg  [DATA_WIDTH-1:0]   pwdata_m14,
  input  wire [DATA_WIDTH-1:0]   prdata_m14,
  input  wire                    pready_m14,
  input  wire                    pslverr_m14,

  output reg                     psel_m15,
  output reg  [ADDR_WIDTH-1:0]   paddr_m15,
  output reg  [DATA_WIDTH/8-1:0] pstrb_m15,
  output reg                     pwrite_m15,
  output reg                     penable_m15,
  output reg  [2:0]              pprot_m15,
  output reg  [DATA_WIDTH-1:0]   pwdata_m15,
  input  wire [DATA_WIDTH-1:0]   prdata_m15,
  input  wire                    pready_m15,
  input  wire                    pslverr_m15
  );


wire [15:0] legal_access;
wire [15:0] secure_filter;
wire [15:0] privilege_filter;
wire [15:0] portsel;
wire        secure_access_violation;
reg  [15:0] cfg_ap_reg;
reg  [15:0] cfg_nonsec_reg;
reg         cfg_sec_resp_reg;
wire        apb_ppc_irq_set;
reg         err_response;




always @(posedge pclk or negedge presetn)
begin
  if (!presetn) begin
    cfg_ap_reg <= 16'h0;
    cfg_nonsec_reg <= 16'h0;
    cfg_sec_resp_reg <= 1'b0;
  end
  else if ((cfg_ap != cfg_ap_reg || cfg_nonsec != cfg_nonsec_reg || cfg_sec_resp != cfg_sec_resp_reg) &&
           (psel_s == 16'h0 || (penable_s && pready_s))) begin
    cfg_ap_reg <= cfg_ap;
    cfg_nonsec_reg <= cfg_nonsec;
    cfg_sec_resp_reg <= cfg_sec_resp;
  end
end


assign secure_filter[15:0] =  ~NONSEC_MASK & (cfg_nonsec_reg ^ {16{pprot_s[1]}});

assign privilege_filter[15:0] = ~cfg_ap_reg & {16{~pprot_s[0]}};

assign portsel[0] = psel_s[0] & (PORT0_ENABLE != 0);
assign portsel[1] = psel_s[1] & (PORT1_ENABLE != 0);
assign portsel[2] = psel_s[2] & (PORT2_ENABLE != 0);
assign portsel[3] = psel_s[3] & (PORT3_ENABLE != 0);
assign portsel[4] = psel_s[4] & (PORT4_ENABLE != 0);
assign portsel[5] = psel_s[5] & (PORT5_ENABLE != 0);
assign portsel[6] = psel_s[6] & (PORT6_ENABLE != 0);
assign portsel[7] = psel_s[7] & (PORT7_ENABLE != 0);
assign portsel[8] = psel_s[8] & (PORT8_ENABLE != 0);
assign portsel[9] = psel_s[9] & (PORT9_ENABLE != 0);
assign portsel[10] = psel_s[10] & (PORT10_ENABLE != 0);
assign portsel[11] = psel_s[11] & (PORT11_ENABLE != 0);
assign portsel[12] = psel_s[12] & (PORT12_ENABLE != 0);
assign portsel[13] = psel_s[13] & (PORT13_ENABLE != 0);
assign portsel[14] = psel_s[14] & (PORT14_ENABLE != 0);
assign portsel[15] = psel_s[15] & (PORT15_ENABLE != 0);

assign legal_access[15:0] = portsel[15:0] & ~secure_filter[15:0] & ~privilege_filter[15:0];

assign secure_access_violation = ((portsel[15:0] & secure_filter[15:0]) != 16'h0);


always @*
begin
  if (legal_access[0]) begin
    psel_m0 = 1'b1;
    paddr_m0 = paddr_s;
    pstrb_m0 = pstrb_s;
    pwrite_m0 = pwrite_s;
    penable_m0 = penable_s;
    pprot_m0 = pprot_s;
    pwdata_m0 = pwdata_s;
  end
  else begin
    psel_m0 = 1'b0;
    paddr_m0 = 'h0;
    pstrb_m0 = 'h0;
    pwrite_m0 = 1'b0;
    penable_m0 = 1'b0;
    pprot_m0 = 'h0;
    pwdata_m0 = 'h0;
  end
end

always @*
begin
  if (legal_access[1]) begin
    psel_m1 = 1'b1;
    paddr_m1 = paddr_s;
    pstrb_m1 = pstrb_s;
    pwrite_m1 = pwrite_s;
    penable_m1 = penable_s;
    pprot_m1 = pprot_s;
    pwdata_m1 = pwdata_s;
  end
  else begin
    psel_m1 = 1'b0;
    paddr_m1 = 'h0;
    pstrb_m1 = 'h0;
    pwrite_m1 = 1'b0;
    penable_m1 = 1'b0;
    pprot_m1 = 'h0;
    pwdata_m1 = 'h0;
  end
end

always @*
begin
  if (legal_access[2]) begin
    psel_m2 = 1'b1;
    paddr_m2 = paddr_s;
    pstrb_m2 = pstrb_s;
    pwrite_m2 = pwrite_s;
    penable_m2 = penable_s;
    pprot_m2 = pprot_s;
    pwdata_m2 = pwdata_s;
  end
  else begin
    psel_m2 = 1'b0;
    paddr_m2 = 'h0;
    pstrb_m2 = 'h0;
    pwrite_m2 = 1'b0;
    penable_m2 = 1'b0;
    pprot_m2 = 'h0;
    pwdata_m2 = 'h0;
  end
end

always @*
begin
  if (legal_access[3]) begin
    psel_m3 = 1'b1;
    paddr_m3 = paddr_s;
    pstrb_m3 = pstrb_s;
    pwrite_m3 = pwrite_s;
    penable_m3 = penable_s;
    pprot_m3 = pprot_s;
    pwdata_m3 = pwdata_s;
  end
  else begin
    psel_m3 = 1'b0;
    paddr_m3 = 'h0;
    pstrb_m3 = 'h0;
    pwrite_m3 = 1'b0;
    penable_m3 = 1'b0;
    pprot_m3 = 'h0;
    pwdata_m3 = 'h0;
  end
end

always @*
begin
  if (legal_access[4]) begin
    psel_m4 = 1'b1;
    paddr_m4 = paddr_s;
    pstrb_m4 = pstrb_s;
    pwrite_m4 = pwrite_s;
    penable_m4 = penable_s;
    pprot_m4 = pprot_s;
    pwdata_m4 = pwdata_s;
  end
  else begin
    psel_m4 = 1'b0;
    paddr_m4 = 'h0;
    pstrb_m4 = 'h0;
    pwrite_m4 = 1'b0;
    penable_m4 = 1'b0;
    pprot_m4 = 'h0;
    pwdata_m4 = 'h0;
  end
end

always @*
begin
  if (legal_access[5]) begin
    psel_m5 = 1'b1;
    paddr_m5 = paddr_s;
    pstrb_m5 = pstrb_s;
    pwrite_m5 = pwrite_s;
    penable_m5 = penable_s;
    pprot_m5 = pprot_s;
    pwdata_m5 = pwdata_s;
  end
  else begin
    psel_m5 = 1'b0;
    paddr_m5 = 'h0;
    pstrb_m5 = 'h0;
    pwrite_m5 = 1'b0;
    penable_m5 = 1'b0;
    pprot_m5 = 'h0;
    pwdata_m5 = 'h0;
  end
end

always @*
begin
  if (legal_access[6]) begin
    psel_m6 = 1'b1;
    paddr_m6 = paddr_s;
    pstrb_m6 = pstrb_s;
    pwrite_m6 = pwrite_s;
    penable_m6 = penable_s;
    pprot_m6 = pprot_s;
    pwdata_m6 = pwdata_s;
  end
  else begin
    psel_m6 = 1'b0;
    paddr_m6 = 'h0;
    pstrb_m6 = 'h0;
    pwrite_m6 = 1'b0;
    penable_m6 = 1'b0;
    pprot_m6 = 'h0;
    pwdata_m6 = 'h0;
  end
end

always @*
begin
  if (legal_access[7]) begin
    psel_m7 = 1'b1;
    paddr_m7 = paddr_s;
    pstrb_m7 = pstrb_s;
    pwrite_m7 = pwrite_s;
    penable_m7 = penable_s;
    pprot_m7 = pprot_s;
    pwdata_m7 = pwdata_s;
  end
  else begin
    psel_m7 = 1'b0;
    paddr_m7 = 'h0;
    pstrb_m7 = 'h0;
    pwrite_m7 = 1'b0;
    penable_m7 = 1'b0;
    pprot_m7 = 'h0;
    pwdata_m7 = 'h0;
  end
end

always @*
begin
  if (legal_access[8]) begin
    psel_m8 = 1'b1;
    paddr_m8 = paddr_s;
    pstrb_m8 = pstrb_s;
    pwrite_m8 = pwrite_s;
    penable_m8 = penable_s;
    pprot_m8 = pprot_s;
    pwdata_m8 = pwdata_s;
  end
  else begin
    psel_m8 = 1'b0;
    paddr_m8 = 'h0;
    pstrb_m8 = 'h0;
    pwrite_m8 = 1'b0;
    penable_m8 = 1'b0;
    pprot_m8 = 'h0;
    pwdata_m8 = 'h0;
  end
end

always @*
begin
  if (legal_access[9]) begin
    psel_m9 = 1'b1;
    paddr_m9 = paddr_s;
    pstrb_m9 = pstrb_s;
    pwrite_m9 = pwrite_s;
    penable_m9 = penable_s;
    pprot_m9 = pprot_s;
    pwdata_m9 = pwdata_s;
  end
  else begin
    psel_m9 = 1'b0;
    paddr_m9 = 'h0;
    pstrb_m9 = 'h0;
    pwrite_m9 = 1'b0;
    penable_m9 = 1'b0;
    pprot_m9 = 'h0;
    pwdata_m9 = 'h0;
  end
end

always @*
begin
  if (legal_access[10]) begin
    psel_m10 = 1'b1;
    paddr_m10 = paddr_s;
    pstrb_m10 = pstrb_s;
    pwrite_m10 = pwrite_s;
    penable_m10 = penable_s;
    pprot_m10 = pprot_s;
    pwdata_m10 = pwdata_s;
  end
  else begin
    psel_m10 = 1'b0;
    paddr_m10 = 'h0;
    pstrb_m10 = 'h0;
    pwrite_m10 = 1'b0;
    penable_m10 = 1'b0;
    pprot_m10 = 'h0;
    pwdata_m10 = 'h0;
  end
end

always @*
begin
  if (legal_access[11]) begin
    psel_m11 = 1'b1;
    paddr_m11 = paddr_s;
    pstrb_m11 = pstrb_s;
    pwrite_m11 = pwrite_s;
    penable_m11 = penable_s;
    pprot_m11 = pprot_s;
    pwdata_m11 = pwdata_s;
  end
  else begin
    psel_m11 = 1'b0;
    paddr_m11 = 'h0;
    pstrb_m11 = 'h0;
    pwrite_m11 = 1'b0;
    penable_m11 = 1'b0;
    pprot_m11 = 'h0;
    pwdata_m11 = 'h0;
  end
end

always @*
begin
  if (legal_access[12]) begin
    psel_m12 = 1'b1;
    paddr_m12 = paddr_s;
    pstrb_m12 = pstrb_s;
    pwrite_m12 = pwrite_s;
    penable_m12 = penable_s;
    pprot_m12 = pprot_s;
    pwdata_m12 = pwdata_s;
  end
  else begin
    psel_m12 = 1'b0;
    paddr_m12 = 'h0;
    pstrb_m12 = 'h0;
    pwrite_m12 = 1'b0;
    penable_m12 = 1'b0;
    pprot_m12 = 'h0;
    pwdata_m12 = 'h0;
  end
end

always @*
begin
  if (legal_access[13]) begin
    psel_m13 = 1'b1;
    paddr_m13 = paddr_s;
    pstrb_m13 = pstrb_s;
    pwrite_m13 = pwrite_s;
    penable_m13 = penable_s;
    pprot_m13 = pprot_s;
    pwdata_m13 = pwdata_s;
  end
  else begin
    psel_m13 = 1'b0;
    paddr_m13 = 'h0;
    pstrb_m13 = 'h0;
    pwrite_m13 = 1'b0;
    penable_m13 = 1'b0;
    pprot_m13 = 'h0;
    pwdata_m13 = 'h0;
  end
end

always @*
begin
  if (legal_access[14]) begin
    psel_m14 = 1'b1;
    paddr_m14 = paddr_s;
    pstrb_m14 = pstrb_s;
    pwrite_m14 = pwrite_s;
    penable_m14 = penable_s;
    pprot_m14 = pprot_s;
    pwdata_m14 = pwdata_s;
  end
  else begin
    psel_m14 = 1'b0;
    paddr_m14 = 'h0;
    pstrb_m14 = 'h0;
    pwrite_m14 = 1'b0;
    penable_m14 = 1'b0;
    pprot_m14 = 'h0;
    pwdata_m14 = 'h0;
  end
end

always @*
begin
  if (legal_access[15]) begin
    psel_m15 = 1'b1;
    paddr_m15 = paddr_s;
    pstrb_m15 = pstrb_s;
    pwrite_m15 = pwrite_s;
    penable_m15 = penable_s;
    pprot_m15 = pprot_s;
    pwdata_m15 = pwdata_s;
  end
  else begin
    psel_m15 = 1'b0;
    paddr_m15 = 'h0;
    pstrb_m15 = 'h0;
    pwrite_m15 = 1'b0;
    penable_m15 = 1'b0;
    pprot_m15 = 'h0;
    pwdata_m15 = 'h0;
  end
end


always @(posedge pclk or negedge presetn)
begin
  if (!presetn) begin
    err_response <= 1'b0;
  end
  else if (secure_access_violation && !penable_s && cfg_sec_resp_reg) begin
    err_response <= 1'b1;
  end
  else begin
    err_response <= 1'b0;
  end
end


assign apb_ppc_irq_set = ~penable_s & secure_access_violation & apb_ppc_irq_enable;

always @(posedge pclk or negedge presetn)
begin
  if (!presetn) begin
    apb_ppc_irq <= 1'b0;
  end
  else if (apb_ppc_irq_clear) begin
    apb_ppc_irq <= 1'b0;
  end
  else if (apb_ppc_irq_set) begin
    apb_ppc_irq <= 1'b1;
  end
end

assign pready_s  = (~psel_m0 | pready_m0) &
                   (~psel_m1 | pready_m1) &
                   (~psel_m2 | pready_m2) &
                   (~psel_m3 | pready_m3) &
                   (~psel_m4 | pready_m4) &
                   (~psel_m5 | pready_m5) &
                   (~psel_m6 | pready_m6) &
                   (~psel_m7 | pready_m7) &
                   (~psel_m8 | pready_m8) &
                   (~psel_m9 | pready_m9) &
                   (~psel_m10 | pready_m10) &
                   (~psel_m11 | pready_m11) &
                   (~psel_m12 | pready_m12) &
                   (~psel_m13 | pready_m13) &
                   (~psel_m14 | pready_m14) &
                   (~psel_m15 | pready_m15);


assign prdata_s  = ({DATA_WIDTH{psel_m0}} & prdata_m0) |
                   ({DATA_WIDTH{psel_m1}} & prdata_m1) |
                   ({DATA_WIDTH{psel_m2}} & prdata_m2) |
                   ({DATA_WIDTH{psel_m3}} & prdata_m3) |
                   ({DATA_WIDTH{psel_m4}} & prdata_m4) |
                   ({DATA_WIDTH{psel_m5}} & prdata_m5) |
                   ({DATA_WIDTH{psel_m6}} & prdata_m6) |
                   ({DATA_WIDTH{psel_m7}} & prdata_m7) |
                   ({DATA_WIDTH{psel_m8}} & prdata_m8) |
                   ({DATA_WIDTH{psel_m9}} & prdata_m9) |
                   ({DATA_WIDTH{psel_m10}} & prdata_m10) |
                   ({DATA_WIDTH{psel_m11}} & prdata_m11) |
                   ({DATA_WIDTH{psel_m12}} & prdata_m12) |
                   ({DATA_WIDTH{psel_m13}} & prdata_m13) |
                   ({DATA_WIDTH{psel_m14}} & prdata_m14) |
                   ({DATA_WIDTH{psel_m15}} & prdata_m15);


assign pslverr_s = (psel_m0 & pslverr_m0 ) |
                   (psel_m1 & pslverr_m1 ) |
                   (psel_m2 & pslverr_m2 ) |
                   (psel_m3 & pslverr_m3 ) |
                   (psel_m4 & pslverr_m4 ) |
                   (psel_m5 & pslverr_m5 ) |
                   (psel_m6 & pslverr_m6 ) |
                   (psel_m7 & pslverr_m7 ) |
                   (psel_m8 & pslverr_m8 ) |
                   (psel_m9 & pslverr_m9 ) |
                   (psel_m10 & pslverr_m10 ) |
                   (psel_m11 & pslverr_m11 ) |
                   (psel_m12 & pslverr_m12 ) |
                   (psel_m13 & pslverr_m13 ) |
                   (psel_m14 & pslverr_m14 ) |
                   (psel_m15 & pslverr_m15 ) |
                   err_response;







endmodule
