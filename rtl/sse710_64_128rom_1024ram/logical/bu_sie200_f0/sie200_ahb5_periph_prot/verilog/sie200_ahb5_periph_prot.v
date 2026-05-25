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
//      Checked In          : Thu Sep 22 17:51:33 2016 +0200
//
//      Revision            : a51cabd
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//------------------------------------------------------------------------------


module sie200_ahb5_periph_prot #(

    parameter PORT0_ENABLE = 1,
    parameter PORT1_ENABLE = 1,
    parameter PORT2_ENABLE = 1,
    parameter PORT3_ENABLE = 1,
    parameter PORT4_ENABLE = 1,
    parameter PORT5_ENABLE = 1,
    parameter PORT6_ENABLE = 1,
    parameter PORT7_ENABLE = 1,
    parameter PORT8_ENABLE = 1,
    parameter PORT9_ENABLE = 1,
    parameter PORT10_ENABLE = 1,
    parameter PORT11_ENABLE = 1,
    parameter PORT12_ENABLE = 1,
    parameter PORT13_ENABLE = 1,
    parameter PORT14_ENABLE = 1,
    parameter PORT15_ENABLE = 1,
    parameter ADDR_WIDTH   = 32,
    parameter DATA_WIDTH   = 32,
    parameter MASTER_WIDTH = 4,
    parameter USER_WIDTH   = 1,
    parameter [15:0] NONSEC_MASK  = 16'h0
)
(

  input wire hclk                             ,
  input wire hresetn                          ,

  input wire  [15:0] cfg_ap                   ,
  input wire  [15:0] cfg_nonsec               ,
  input wire         cfg_sec_resp             ,

  output reg         ahb_ppc_irq              ,
  input  wire        ahb_ppc_irq_clear        ,
  input  wire        ahb_ppc_irq_enable       ,
  input  wire [16:0]             hsel_s       ,
  input  wire                    hnonsec_s    ,
  input  wire [ADDR_WIDTH-1:0]   haddr_s      ,
  input  wire [1:0]              htrans_s     ,
  input  wire [2:0]              hsize_s      ,
  input  wire                    hwrite_s     ,
  input  wire                    hready_s     ,
  input  wire [6:0]              hprot_s      ,
  input  wire [2:0]              hburst_s     ,
  input  wire                    hmastlock_s  ,
  input  wire [DATA_WIDTH-1:0]   hwdata_s     ,
  input  wire                    hexcl_s      ,
  input  wire [MASTER_WIDTH-1:0] hmaster_s    ,
  output wire [DATA_WIDTH-1:0]   hrdata_s     ,
  output wire                    hreadyout_s  ,
  output wire                    hresp_s      ,
  output wire                    hexokay_s    ,
  input  wire [USER_WIDTH-1:0]   hauser_s     ,
  input  wire [USER_WIDTH-1:0]   hwuser_s     ,
  output wire [USER_WIDTH-1:0]   hruser_s     ,


  output reg                     hsel_m0      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m0     ,
  output reg  [1:0]              htrans_m0    ,
  output reg  [2:0]              hsize_m0     ,
  output reg                     hwrite_m0    ,
  output wire                    hready_m0    ,
  output reg  [6:0]              hprot_m0     ,
  output reg  [2:0]              hburst_m0    ,
  output reg                     hmastlock_m0 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m0    ,
  output reg                     hnonsec_m0   ,
  output reg                     hexcl_m0     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m0   ,
  input  wire                    hreadyout_m0 ,
  input  wire                    hresp_m0     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m0    ,
  input  wire                    hexokay_m0   ,
  output reg  [USER_WIDTH-1:0]   hauser_m0    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m0    ,
  input  wire [USER_WIDTH-1:0]   hruser_m0    ,

  output reg                     hsel_m1      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m1     ,
  output reg  [1:0]              htrans_m1    ,
  output reg  [2:0]              hsize_m1     ,
  output reg                     hwrite_m1    ,
  output wire                    hready_m1    ,
  output reg  [6:0]              hprot_m1     ,
  output reg  [2:0]              hburst_m1    ,
  output reg                     hmastlock_m1 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m1    ,
  output reg                     hnonsec_m1   ,
  output reg                     hexcl_m1     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m1   ,
  input  wire                    hreadyout_m1 ,
  input  wire                    hresp_m1     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m1    ,
  input  wire                    hexokay_m1   ,
  output reg  [USER_WIDTH-1:0]   hauser_m1    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m1    ,
  input  wire [USER_WIDTH-1:0]   hruser_m1    ,

  output reg                     hsel_m2      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m2     ,
  output reg  [1:0]              htrans_m2    ,
  output reg  [2:0]              hsize_m2     ,
  output reg                     hwrite_m2    ,
  output wire                    hready_m2    ,
  output reg  [6:0]              hprot_m2     ,
  output reg  [2:0]              hburst_m2    ,
  output reg                     hmastlock_m2 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m2    ,
  output reg                     hnonsec_m2   ,
  output reg                     hexcl_m2     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m2   ,
  input  wire                    hreadyout_m2 ,
  input  wire                    hresp_m2     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m2    ,
  input  wire                    hexokay_m2   ,
  output reg  [USER_WIDTH-1:0]   hauser_m2    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m2    ,
  input  wire [USER_WIDTH-1:0]   hruser_m2    ,

  output reg                     hsel_m3      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m3     ,
  output reg  [1:0]              htrans_m3    ,
  output reg  [2:0]              hsize_m3     ,
  output reg                     hwrite_m3    ,
  output wire                    hready_m3    ,
  output reg  [6:0]              hprot_m3     ,
  output reg  [2:0]              hburst_m3    ,
  output reg                     hmastlock_m3 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m3    ,
  output reg                     hnonsec_m3   ,
  output reg                     hexcl_m3     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m3   ,
  input  wire                    hreadyout_m3 ,
  input  wire                    hresp_m3     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m3    ,
  input  wire                    hexokay_m3   ,
  output reg  [USER_WIDTH-1:0]   hauser_m3    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m3    ,
  input  wire [USER_WIDTH-1:0]   hruser_m3    ,

  output reg                     hsel_m4      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m4     ,
  output reg  [1:0]              htrans_m4    ,
  output reg  [2:0]              hsize_m4     ,
  output reg                     hwrite_m4    ,
  output wire                    hready_m4    ,
  output reg  [6:0]              hprot_m4     ,
  output reg  [2:0]              hburst_m4    ,
  output reg                     hmastlock_m4 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m4    ,
  output reg                     hnonsec_m4   ,
  output reg                     hexcl_m4     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m4   ,
  input  wire                    hreadyout_m4 ,
  input  wire                    hresp_m4     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m4    ,
  input  wire                    hexokay_m4   ,
  output reg  [USER_WIDTH-1:0]   hauser_m4    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m4    ,
  input  wire [USER_WIDTH-1:0]   hruser_m4    ,

  output reg                     hsel_m5      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m5     ,
  output reg  [1:0]              htrans_m5    ,
  output reg  [2:0]              hsize_m5     ,
  output reg                     hwrite_m5    ,
  output wire                    hready_m5    ,
  output reg  [6:0]              hprot_m5     ,
  output reg  [2:0]              hburst_m5    ,
  output reg                     hmastlock_m5 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m5    ,
  output reg                     hnonsec_m5   ,
  output reg                     hexcl_m5     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m5   ,
  input  wire                    hreadyout_m5 ,
  input  wire                    hresp_m5     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m5    ,
  input  wire                    hexokay_m5   ,
  output reg  [USER_WIDTH-1:0]   hauser_m5    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m5    ,
  input  wire [USER_WIDTH-1:0]   hruser_m5    ,

  output reg                     hsel_m6      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m6     ,
  output reg  [1:0]              htrans_m6    ,
  output reg  [2:0]              hsize_m6     ,
  output reg                     hwrite_m6    ,
  output wire                    hready_m6    ,
  output reg  [6:0]              hprot_m6     ,
  output reg  [2:0]              hburst_m6    ,
  output reg                     hmastlock_m6 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m6    ,
  output reg                     hnonsec_m6   ,
  output reg                     hexcl_m6     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m6   ,
  input  wire                    hreadyout_m6 ,
  input  wire                    hresp_m6     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m6    ,
  input  wire                    hexokay_m6   ,
  output reg  [USER_WIDTH-1:0]   hauser_m6    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m6    ,
  input  wire [USER_WIDTH-1:0]   hruser_m6    ,

  output reg                     hsel_m7      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m7     ,
  output reg  [1:0]              htrans_m7    ,
  output reg  [2:0]              hsize_m7     ,
  output reg                     hwrite_m7    ,
  output wire                    hready_m7    ,
  output reg  [6:0]              hprot_m7     ,
  output reg  [2:0]              hburst_m7    ,
  output reg                     hmastlock_m7 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m7    ,
  output reg                     hnonsec_m7   ,
  output reg                     hexcl_m7     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m7   ,
  input  wire                    hreadyout_m7 ,
  input  wire                    hresp_m7     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m7    ,
  input  wire                    hexokay_m7   ,
  output reg  [USER_WIDTH-1:0]   hauser_m7    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m7    ,
  input  wire [USER_WIDTH-1:0]   hruser_m7    ,

  output reg                     hsel_m8      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m8     ,
  output reg  [1:0]              htrans_m8    ,
  output reg  [2:0]              hsize_m8     ,
  output reg                     hwrite_m8    ,
  output wire                    hready_m8    ,
  output reg  [6:0]              hprot_m8     ,
  output reg  [2:0]              hburst_m8    ,
  output reg                     hmastlock_m8 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m8    ,
  output reg                     hnonsec_m8   ,
  output reg                     hexcl_m8     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m8   ,
  input  wire                    hreadyout_m8 ,
  input  wire                    hresp_m8     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m8    ,
  input  wire                    hexokay_m8   ,
  output reg  [USER_WIDTH-1:0]   hauser_m8    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m8    ,
  input  wire [USER_WIDTH-1:0]   hruser_m8    ,

  output reg                     hsel_m9      ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m9     ,
  output reg  [1:0]              htrans_m9    ,
  output reg  [2:0]              hsize_m9     ,
  output reg                     hwrite_m9    ,
  output wire                    hready_m9    ,
  output reg  [6:0]              hprot_m9     ,
  output reg  [2:0]              hburst_m9    ,
  output reg                     hmastlock_m9 ,
  output reg  [DATA_WIDTH-1:0]   hwdata_m9    ,
  output reg                     hnonsec_m9   ,
  output reg                     hexcl_m9     ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m9   ,
  input  wire                    hreadyout_m9 ,
  input  wire                    hresp_m9     ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m9    ,
  input  wire                    hexokay_m9   ,
  output reg  [USER_WIDTH-1:0]   hauser_m9    ,
  output reg  [USER_WIDTH-1:0]   hwuser_m9    ,
  input  wire [USER_WIDTH-1:0]   hruser_m9    ,

  output reg                     hsel_m10     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m10    ,
  output reg  [1:0]              htrans_m10   ,
  output reg  [2:0]              hsize_m10    ,
  output reg                     hwrite_m10   ,
  output wire                    hready_m10   ,
  output reg  [6:0]              hprot_m10    ,
  output reg  [2:0]              hburst_m10   ,
  output reg                     hmastlock_m10,
  output reg  [DATA_WIDTH-1:0]   hwdata_m10   ,
  output reg                     hnonsec_m10  ,
  output reg                     hexcl_m10    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m10  ,
  input  wire                    hreadyout_m10,
  input  wire                    hresp_m10    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m10   ,
  input  wire                    hexokay_m10  ,
  output reg  [USER_WIDTH-1:0]   hauser_m10   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m10   ,
  input  wire [USER_WIDTH-1:0]   hruser_m10   ,

  output reg                     hsel_m11     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m11    ,
  output reg  [1:0]              htrans_m11   ,
  output reg  [2:0]              hsize_m11    ,
  output reg                     hwrite_m11   ,
  output wire                    hready_m11   ,
  output reg  [6:0]              hprot_m11    ,
  output reg  [2:0]              hburst_m11   ,
  output reg                     hmastlock_m11,
  output reg  [DATA_WIDTH-1:0]   hwdata_m11   ,
  output reg                     hnonsec_m11  ,
  output reg                     hexcl_m11    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m11  ,
  input  wire                    hreadyout_m11,
  input  wire                    hresp_m11    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m11   ,
  input  wire                    hexokay_m11  ,
  output reg  [USER_WIDTH-1:0]   hauser_m11   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m11   ,
  input  wire [USER_WIDTH-1:0]   hruser_m11   ,

  output reg                     hsel_m12     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m12    ,
  output reg  [1:0]              htrans_m12   ,
  output reg  [2:0]              hsize_m12    ,
  output reg                     hwrite_m12   ,
  output wire                    hready_m12   ,
  output reg  [6:0]              hprot_m12    ,
  output reg  [2:0]              hburst_m12   ,
  output reg                     hmastlock_m12,
  output reg  [DATA_WIDTH-1:0]   hwdata_m12   ,
  output reg                     hnonsec_m12  ,
  output reg                     hexcl_m12    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m12  ,
  input  wire                    hreadyout_m12,
  input  wire                    hresp_m12    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m12   ,
  input  wire                    hexokay_m12  ,
  output reg  [USER_WIDTH-1:0]   hauser_m12   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m12   ,
  input  wire [USER_WIDTH-1:0]   hruser_m12   ,

  output reg                     hsel_m13     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m13    ,
  output reg  [1:0]              htrans_m13   ,
  output reg  [2:0]              hsize_m13    ,
  output reg                     hwrite_m13   ,
  output wire                    hready_m13   ,
  output reg  [6:0]              hprot_m13    ,
  output reg  [2:0]              hburst_m13   ,
  output reg                     hmastlock_m13,
  output reg  [DATA_WIDTH-1:0]   hwdata_m13   ,
  output reg                     hnonsec_m13  ,
  output reg                     hexcl_m13    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m13  ,
  input  wire                    hreadyout_m13,
  input  wire                    hresp_m13    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m13   ,
  input  wire                    hexokay_m13  ,
  output reg  [USER_WIDTH-1:0]   hauser_m13   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m13   ,
  input  wire [USER_WIDTH-1:0]   hruser_m13   ,

  output reg                     hsel_m14     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m14    ,
  output reg  [1:0]              htrans_m14   ,
  output reg  [2:0]              hsize_m14    ,
  output reg                     hwrite_m14   ,
  output wire                    hready_m14   ,
  output reg  [6:0]              hprot_m14    ,
  output reg  [2:0]              hburst_m14   ,
  output reg                     hmastlock_m14,
  output reg  [DATA_WIDTH-1:0]   hwdata_m14   ,
  output reg                     hnonsec_m14  ,
  output reg                     hexcl_m14    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m14  ,
  input  wire                    hreadyout_m14,
  input  wire                    hresp_m14    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m14   ,
  input  wire                    hexokay_m14  ,
  output reg  [USER_WIDTH-1:0]   hauser_m14   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m14   ,
  input  wire [USER_WIDTH-1:0]   hruser_m14   ,

  output reg                     hsel_m15     ,
  output reg  [ADDR_WIDTH-1:0]   haddr_m15    ,
  output reg  [1:0]              htrans_m15   ,
  output reg  [2:0]              hsize_m15    ,
  output reg                     hwrite_m15   ,
  output wire                    hready_m15   ,
  output reg  [6:0]              hprot_m15    ,
  output reg  [2:0]              hburst_m15   ,
  output reg                     hmastlock_m15,
  output reg  [DATA_WIDTH-1:0]   hwdata_m15   ,
  output reg                     hnonsec_m15  ,
  output reg                     hexcl_m15    ,
  output reg  [MASTER_WIDTH-1:0] hmaster_m15  ,
  input  wire                    hreadyout_m15,
  input  wire                    hresp_m15    ,
  input  wire [DATA_WIDTH-1:0]   hrdata_m15   ,
  input  wire                    hexokay_m15  ,
  output reg  [USER_WIDTH-1:0]   hauser_m15   ,
  output reg  [USER_WIDTH-1:0]   hwuser_m15   ,
  input  wire [USER_WIDTH-1:0]   hruser_m15   ,

  output reg                     hsel_ds      ,
  output reg  [1:0]              htrans_ds    ,
  output wire                    hready_ds    ,
  input  wire                    hexokay_ds   ,
  input  wire                    hreadyout_ds ,
  input  wire                    hresp_ds
);



wire [15:0] secure_filter;
wire [15:0] privilege_filter;
wire [16:0] portsel;
wire [15:0] legal_access;
wire        secure_access_violation;
wire        mux_hready;
wire        hreadyo;
wire [15:0] cfg_ap_nonseq;
wire [15:0] cfg_nonsec_nonseq;
wire        cfg_sec_resp_nonseq;
wire [15:0] cfg_ap_seq;
wire [15:0] cfg_nonsec_seq;
wire        cfg_sec_resp_seq;
wire        ahb_ppc_irq_set;

reg  [16:0] hselo_reg;
reg  [15:0] legal_access_reg;
reg  [15:0] cfg_ap_reg;
reg  [15:0] cfg_nonsec_reg;
reg         cfg_sec_resp_reg;
reg         nonseq_wait_state;
reg  [1:0]  err_state;


always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    cfg_ap_reg <= 16'h0;
    cfg_nonsec_reg <= 16'h0;
    cfg_sec_resp_reg <= 1'b0;
  end
  else if (htrans_s == 2'b10 && !nonseq_wait_state) begin
    cfg_ap_reg <= cfg_ap;
    cfg_nonsec_reg <= cfg_nonsec;
    cfg_sec_resp_reg <= cfg_sec_resp;
  end
end

always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    nonseq_wait_state <= 1'b0;
  end
  else if (hready_s) begin
    nonseq_wait_state <= 1'b0;
  end
  else if (htrans_s == 2'b10 && !hready_s) begin
    nonseq_wait_state <= 1'b1;
  end
end


assign cfg_ap_nonseq = nonseq_wait_state ? cfg_ap_reg : cfg_ap;
assign cfg_nonsec_nonseq = nonseq_wait_state ? cfg_nonsec_reg : cfg_nonsec;
assign cfg_sec_resp_nonseq = nonseq_wait_state ? cfg_sec_resp_reg : cfg_sec_resp;

assign cfg_ap_seq = cfg_ap_reg;
assign cfg_nonsec_seq = cfg_nonsec_reg;
assign cfg_sec_resp_seq = cfg_sec_resp_reg;

assign secure_filter[15:0] = ~NONSEC_MASK &
                             (({16{htrans_s[0]}} & (cfg_nonsec_seq ^ {16{hnonsec_s}})) |
                             ({16{htrans_s[1]}} & {16{~htrans_s[0]}} & (cfg_nonsec_nonseq ^ {16{hnonsec_s}})));

assign privilege_filter[15:0] = ({16{htrans_s[0]}} & ~cfg_ap_seq & {16{~hprot_s[1]}}) |
                                ({16{htrans_s[1]}} & {16{~htrans_s[0]}} & ~cfg_ap_nonseq & {16{~hprot_s[1]}});

assign portsel[0] = hsel_s[0] & (PORT0_ENABLE != 0);
assign portsel[1] = hsel_s[1] & (PORT1_ENABLE != 0);
assign portsel[2] = hsel_s[2] & (PORT2_ENABLE != 0);
assign portsel[3] = hsel_s[3] & (PORT3_ENABLE != 0);
assign portsel[4] = hsel_s[4] & (PORT4_ENABLE != 0);
assign portsel[5] = hsel_s[5] & (PORT5_ENABLE != 0);
assign portsel[6] = hsel_s[6] & (PORT6_ENABLE != 0);
assign portsel[7] = hsel_s[7] & (PORT7_ENABLE != 0);
assign portsel[8] = hsel_s[8] & (PORT8_ENABLE != 0);
assign portsel[9] = hsel_s[9] & (PORT9_ENABLE != 0);
assign portsel[10] = hsel_s[10] & (PORT10_ENABLE != 0);
assign portsel[11] = hsel_s[11] & (PORT11_ENABLE != 0);
assign portsel[12] = hsel_s[12] & (PORT12_ENABLE != 0);
assign portsel[13] = hsel_s[13] & (PORT13_ENABLE != 0);
assign portsel[14] = hsel_s[14] & (PORT14_ENABLE != 0);
assign portsel[15] = hsel_s[15] & (PORT15_ENABLE != 0);
assign portsel[16] = hsel_s[16];


assign legal_access[15:0] = portsel[15:0] & ~secure_filter[15:0] & ~privilege_filter[15:0] & {16{~err_state[0]}} & ({16{mux_hready}} & {16{hready_s}} | hselo_reg[15:0]);

assign secure_access_violation = htrans_s[1] & ((portsel[15:0] & secure_filter[15:0]) != 16'h0);


always @*
begin
  if (portsel[0]) begin
    hsel_m0 = 1'b1;
    haddr_m0 = haddr_s;
    hmastlock_m0 = hmastlock_s;
  end
  else begin
    hsel_m0  = 1'b0;
    haddr_m0 = {ADDR_WIDTH{1'b0}};
    hmastlock_m0 = 1'b0;
  end
  if (legal_access[0]) begin
    htrans_m0 = htrans_s;
    hsize_m0 = hsize_s;
    hwrite_m0 = hwrite_s;
    hprot_m0 = hprot_s;
    hburst_m0 = hburst_s;
    hnonsec_m0 = hnonsec_s;
    hexcl_m0 = hexcl_s;
    hmaster_m0 = hmaster_s;
    hauser_m0 = hauser_s;
  end
  else begin
    htrans_m0 = 2'h0;
    hsize_m0  = 3'h0;
    hwrite_m0 = 1'b0;
    hprot_m0  = 7'h0;
    hburst_m0 = 3'h0;
    hnonsec_m0 = 1'b0;
    hexcl_m0 = 1'b0;
    hmaster_m0 = {MASTER_WIDTH{1'b0}};
    hauser_m0 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[0]) begin
    hwdata_m0 = hwdata_s;
    hwuser_m0 = hwuser_s;
  end
  else begin
    hwdata_m0 = {DATA_WIDTH{1'b0}};
    hwuser_m0 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[1]) begin
    hsel_m1 = 1'b1;
    haddr_m1 = haddr_s;
    hmastlock_m1 = hmastlock_s;
  end
  else begin
    hsel_m1  = 1'b0;
    haddr_m1 = {ADDR_WIDTH{1'b0}};
    hmastlock_m1 = 1'b0;
  end
  if (legal_access[1]) begin
    htrans_m1 = htrans_s;
    hsize_m1 = hsize_s;
    hwrite_m1 = hwrite_s;
    hprot_m1 = hprot_s;
    hburst_m1 = hburst_s;
    hnonsec_m1 = hnonsec_s;
    hexcl_m1 = hexcl_s;
    hmaster_m1 = hmaster_s;
    hauser_m1 = hauser_s;
  end
  else begin
    htrans_m1 = 2'h0;
    hsize_m1  = 3'h0;
    hwrite_m1 = 1'b0;
    hprot_m1  = 7'h0;
    hburst_m1 = 3'h0;
    hnonsec_m1 = 1'b0;
    hexcl_m1 = 1'b0;
    hmaster_m1 = {MASTER_WIDTH{1'b0}};
    hauser_m1 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[1]) begin
    hwdata_m1 = hwdata_s;
    hwuser_m1 = hwuser_s;
  end
  else begin
    hwdata_m1 = {DATA_WIDTH{1'b0}};
    hwuser_m1 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[2]) begin
    hsel_m2 = 1'b1;
    haddr_m2 = haddr_s;
    hmastlock_m2 = hmastlock_s;
  end
  else begin
    hsel_m2  = 1'b0;
    haddr_m2 = {ADDR_WIDTH{1'b0}};
    hmastlock_m2 = 1'b0;
  end
  if (legal_access[2]) begin
    htrans_m2 = htrans_s;
    hsize_m2 = hsize_s;
    hwrite_m2 = hwrite_s;
    hprot_m2 = hprot_s;
    hburst_m2 = hburst_s;
    hnonsec_m2 = hnonsec_s;
    hexcl_m2 = hexcl_s;
    hmaster_m2 = hmaster_s;
    hauser_m2 = hauser_s;
  end
  else begin
    htrans_m2 = 2'h0;
    hsize_m2  = 3'h0;
    hwrite_m2 = 1'b0;
    hprot_m2  = 7'h0;
    hburst_m2 = 3'h0;
    hnonsec_m2 = 1'b0;
    hexcl_m2 = 1'b0;
    hmaster_m2 = {MASTER_WIDTH{1'b0}};
    hauser_m2 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[2]) begin
    hwdata_m2 = hwdata_s;
    hwuser_m2 = hwuser_s;
  end
  else begin
    hwdata_m2 = {DATA_WIDTH{1'b0}};
    hwuser_m2 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[3]) begin
    hsel_m3 = 1'b1;
    haddr_m3 = haddr_s;
    hmastlock_m3 = hmastlock_s;
  end
  else begin
    hsel_m3  = 1'b0;
    haddr_m3 = {ADDR_WIDTH{1'b0}};
    hmastlock_m3 = 1'b0;
  end
  if (legal_access[3]) begin
    htrans_m3 = htrans_s;
    hsize_m3 = hsize_s;
    hwrite_m3 = hwrite_s;
    hprot_m3 = hprot_s;
    hburst_m3 = hburst_s;
    hnonsec_m3 = hnonsec_s;
    hexcl_m3 = hexcl_s;
    hmaster_m3 = hmaster_s;
    hauser_m3 = hauser_s;
  end
  else begin
    htrans_m3 = 2'h0;
    hsize_m3  = 3'h0;
    hwrite_m3 = 1'b0;
    hprot_m3  = 7'h0;
    hburst_m3 = 3'h0;
    hnonsec_m3 = 1'b0;
    hexcl_m3 = 1'b0;
    hmaster_m3 = {MASTER_WIDTH{1'b0}};
    hauser_m3 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[3]) begin
    hwdata_m3 = hwdata_s;
    hwuser_m3 = hwuser_s;
  end
  else begin
    hwdata_m3 = {DATA_WIDTH{1'b0}};
    hwuser_m3 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[4]) begin
    hsel_m4 = 1'b1;
    haddr_m4 = haddr_s;
    hmastlock_m4 = hmastlock_s;
  end
  else begin
    hsel_m4  = 1'b0;
    haddr_m4 = {ADDR_WIDTH{1'b0}};
    hmastlock_m4 = 1'b0;
  end
  if (legal_access[4]) begin
    htrans_m4 = htrans_s;
    hsize_m4 = hsize_s;
    hwrite_m4 = hwrite_s;
    hprot_m4 = hprot_s;
    hburst_m4 = hburst_s;
    hnonsec_m4 = hnonsec_s;
    hexcl_m4 = hexcl_s;
    hmaster_m4 = hmaster_s;
    hauser_m4 = hauser_s;
  end
  else begin
    htrans_m4 = 2'h0;
    hsize_m4  = 3'h0;
    hwrite_m4 = 1'b0;
    hprot_m4  = 7'h0;
    hburst_m4 = 3'h0;
    hnonsec_m4 = 1'b0;
    hexcl_m4 = 1'b0;
    hmaster_m4 = {MASTER_WIDTH{1'b0}};
    hauser_m4 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[4]) begin
    hwdata_m4 = hwdata_s;
    hwuser_m4 = hwuser_s;
  end
  else begin
    hwdata_m4 = {DATA_WIDTH{1'b0}};
    hwuser_m4 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[5]) begin
    hsel_m5 = 1'b1;
    haddr_m5 = haddr_s;
    hmastlock_m5 = hmastlock_s;
  end
  else begin
    hsel_m5  = 1'b0;
    haddr_m5 = {ADDR_WIDTH{1'b0}};
    hmastlock_m5 = 1'b0;
  end
  if (legal_access[5]) begin
    htrans_m5 = htrans_s;
    hsize_m5 = hsize_s;
    hwrite_m5 = hwrite_s;
    hprot_m5 = hprot_s;
    hburst_m5 = hburst_s;
    hnonsec_m5 = hnonsec_s;
    hexcl_m5 = hexcl_s;
    hmaster_m5 = hmaster_s;
    hauser_m5 = hauser_s;
  end
  else begin
    htrans_m5 = 2'h0;
    hsize_m5  = 3'h0;
    hwrite_m5 = 1'b0;
    hprot_m5  = 7'h0;
    hburst_m5 = 3'h0;
    hnonsec_m5 = 1'b0;
    hexcl_m5 = 1'b0;
    hmaster_m5 = {MASTER_WIDTH{1'b0}};
    hauser_m5 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[5]) begin
    hwdata_m5 = hwdata_s;
    hwuser_m5 = hwuser_s;
  end
  else begin
    hwdata_m5 = {DATA_WIDTH{1'b0}};
    hwuser_m5 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[6]) begin
    hsel_m6 = 1'b1;
    haddr_m6 = haddr_s;
    hmastlock_m6 = hmastlock_s;
  end
  else begin
    hsel_m6  = 1'b0;
    haddr_m6 = {ADDR_WIDTH{1'b0}};
    hmastlock_m6 = 1'b0;
  end
  if (legal_access[6]) begin
    htrans_m6 = htrans_s;
    hsize_m6 = hsize_s;
    hwrite_m6 = hwrite_s;
    hprot_m6 = hprot_s;
    hburst_m6 = hburst_s;
    hnonsec_m6 = hnonsec_s;
    hexcl_m6 = hexcl_s;
    hmaster_m6 = hmaster_s;
    hauser_m6 = hauser_s;
  end
  else begin
    htrans_m6 = 2'h0;
    hsize_m6  = 3'h0;
    hwrite_m6 = 1'b0;
    hprot_m6  = 7'h0;
    hburst_m6 = 3'h0;
    hnonsec_m6 = 1'b0;
    hexcl_m6 = 1'b0;
    hmaster_m6 = {MASTER_WIDTH{1'b0}};
    hauser_m6 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[6]) begin
    hwdata_m6 = hwdata_s;
    hwuser_m6 = hwuser_s;
  end
  else begin
    hwdata_m6 = {DATA_WIDTH{1'b0}};
    hwuser_m6 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[7]) begin
    hsel_m7 = 1'b1;
    haddr_m7 = haddr_s;
    hmastlock_m7 = hmastlock_s;
  end
  else begin
    hsel_m7  = 1'b0;
    haddr_m7 = {ADDR_WIDTH{1'b0}};
    hmastlock_m7 = 1'b0;
  end
  if (legal_access[7]) begin
    htrans_m7 = htrans_s;
    hsize_m7 = hsize_s;
    hwrite_m7 = hwrite_s;
    hprot_m7 = hprot_s;
    hburst_m7 = hburst_s;
    hnonsec_m7 = hnonsec_s;
    hexcl_m7 = hexcl_s;
    hmaster_m7 = hmaster_s;
    hauser_m7 = hauser_s;
  end
  else begin
    htrans_m7 = 2'h0;
    hsize_m7  = 3'h0;
    hwrite_m7 = 1'b0;
    hprot_m7  = 7'h0;
    hburst_m7 = 3'h0;
    hnonsec_m7 = 1'b0;
    hexcl_m7 = 1'b0;
    hmaster_m7 = {MASTER_WIDTH{1'b0}};
    hauser_m7 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[7]) begin
    hwdata_m7 = hwdata_s;
    hwuser_m7 = hwuser_s;
  end
  else begin
    hwdata_m7 = {DATA_WIDTH{1'b0}};
    hwuser_m7 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[8]) begin
    hsel_m8 = 1'b1;
    haddr_m8 = haddr_s;
    hmastlock_m8 = hmastlock_s;
  end
  else begin
    hsel_m8  = 1'b0;
    haddr_m8 = {ADDR_WIDTH{1'b0}};
    hmastlock_m8 = 1'b0;
  end
  if (legal_access[8]) begin
    htrans_m8 = htrans_s;
    hsize_m8 = hsize_s;
    hwrite_m8 = hwrite_s;
    hprot_m8 = hprot_s;
    hburst_m8 = hburst_s;
    hnonsec_m8 = hnonsec_s;
    hexcl_m8 = hexcl_s;
    hmaster_m8 = hmaster_s;
    hauser_m8 = hauser_s;
  end
  else begin
    htrans_m8 = 2'h0;
    hsize_m8  = 3'h0;
    hwrite_m8 = 1'b0;
    hprot_m8  = 7'h0;
    hburst_m8 = 3'h0;
    hnonsec_m8 = 1'b0;
    hexcl_m8 = 1'b0;
    hmaster_m8 = {MASTER_WIDTH{1'b0}};
    hauser_m8 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[8]) begin
    hwdata_m8 = hwdata_s;
    hwuser_m8 = hwuser_s;
  end
  else begin
    hwdata_m8 = {DATA_WIDTH{1'b0}};
    hwuser_m8 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[9]) begin
    hsel_m9 = 1'b1;
    haddr_m9 = haddr_s;
    hmastlock_m9 = hmastlock_s;
  end
  else begin
    hsel_m9  = 1'b0;
    haddr_m9 = {ADDR_WIDTH{1'b0}};
    hmastlock_m9 = 1'b0;
  end
  if (legal_access[9]) begin
    htrans_m9 = htrans_s;
    hsize_m9 = hsize_s;
    hwrite_m9 = hwrite_s;
    hprot_m9 = hprot_s;
    hburst_m9 = hburst_s;
    hnonsec_m9 = hnonsec_s;
    hexcl_m9 = hexcl_s;
    hmaster_m9 = hmaster_s;
    hauser_m9 = hauser_s;
  end
  else begin
    htrans_m9 = 2'h0;
    hsize_m9  = 3'h0;
    hwrite_m9 = 1'b0;
    hprot_m9  = 7'h0;
    hburst_m9 = 3'h0;
    hnonsec_m9 = 1'b0;
    hexcl_m9 = 1'b0;
    hmaster_m9 = {MASTER_WIDTH{1'b0}};
    hauser_m9 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[9]) begin
    hwdata_m9 = hwdata_s;
    hwuser_m9 = hwuser_s;
  end
  else begin
    hwdata_m9 = {DATA_WIDTH{1'b0}};
    hwuser_m9 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[10]) begin
    hsel_m10 = 1'b1;
    haddr_m10 = haddr_s;
    hmastlock_m10 = hmastlock_s;
  end
  else begin
    hsel_m10  = 1'b0;
    haddr_m10 = {ADDR_WIDTH{1'b0}};
    hmastlock_m10 = 1'b0;
  end
  if (legal_access[10]) begin
    htrans_m10 = htrans_s;
    hsize_m10 = hsize_s;
    hwrite_m10 = hwrite_s;
    hprot_m10 = hprot_s;
    hburst_m10 = hburst_s;
    hnonsec_m10 = hnonsec_s;
    hexcl_m10 = hexcl_s;
    hmaster_m10 = hmaster_s;
    hauser_m10 = hauser_s;
  end
  else begin
    htrans_m10 = 2'h0;
    hsize_m10  = 3'h0;
    hwrite_m10 = 1'b0;
    hprot_m10  = 7'h0;
    hburst_m10 = 3'h0;
    hnonsec_m10 = 1'b0;
    hexcl_m10 = 1'b0;
    hmaster_m10 = {MASTER_WIDTH{1'b0}};
    hauser_m10 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[10]) begin
    hwdata_m10 = hwdata_s;
    hwuser_m10 = hwuser_s;
  end
  else begin
    hwdata_m10 = {DATA_WIDTH{1'b0}};
    hwuser_m10 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[11]) begin
    hsel_m11 = 1'b1;
    haddr_m11 = haddr_s;
    hmastlock_m11 = hmastlock_s;
  end
  else begin
    hsel_m11  = 1'b0;
    haddr_m11 = {ADDR_WIDTH{1'b0}};
    hmastlock_m11 = 1'b0;
  end
  if (legal_access[11]) begin
    htrans_m11 = htrans_s;
    hsize_m11 = hsize_s;
    hwrite_m11 = hwrite_s;
    hprot_m11 = hprot_s;
    hburst_m11 = hburst_s;
    hnonsec_m11 = hnonsec_s;
    hexcl_m11 = hexcl_s;
    hmaster_m11 = hmaster_s;
    hauser_m11 = hauser_s;
  end
  else begin
    htrans_m11 = 2'h0;
    hsize_m11  = 3'h0;
    hwrite_m11 = 1'b0;
    hprot_m11  = 7'h0;
    hburst_m11 = 3'h0;
    hnonsec_m11 = 1'b0;
    hexcl_m11 = 1'b0;
    hmaster_m11 = {MASTER_WIDTH{1'b0}};
    hauser_m11 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[11]) begin
    hwdata_m11 = hwdata_s;
    hwuser_m11 = hwuser_s;
  end
  else begin
    hwdata_m11 = {DATA_WIDTH{1'b0}};
    hwuser_m11 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[12]) begin
    hsel_m12 = 1'b1;
    haddr_m12 = haddr_s;
    hmastlock_m12 = hmastlock_s;
  end
  else begin
    hsel_m12  = 1'b0;
    haddr_m12 = {ADDR_WIDTH{1'b0}};
    hmastlock_m12 = 1'b0;
  end
  if (legal_access[12]) begin
    htrans_m12 = htrans_s;
    hsize_m12 = hsize_s;
    hwrite_m12 = hwrite_s;
    hprot_m12 = hprot_s;
    hburst_m12 = hburst_s;
    hnonsec_m12 = hnonsec_s;
    hexcl_m12 = hexcl_s;
    hmaster_m12 = hmaster_s;
    hauser_m12 = hauser_s;
  end
  else begin
    htrans_m12 = 2'h0;
    hsize_m12  = 3'h0;
    hwrite_m12 = 1'b0;
    hprot_m12  = 7'h0;
    hburst_m12 = 3'h0;
    hnonsec_m12 = 1'b0;
    hexcl_m12 = 1'b0;
    hmaster_m12 = {MASTER_WIDTH{1'b0}};
    hauser_m12 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[12]) begin
    hwdata_m12 = hwdata_s;
    hwuser_m12 = hwuser_s;
  end
  else begin
    hwdata_m12 = {DATA_WIDTH{1'b0}};
    hwuser_m12 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[13]) begin
    hsel_m13 = 1'b1;
    haddr_m13 = haddr_s;
    hmastlock_m13 = hmastlock_s;
  end
  else begin
    hsel_m13  = 1'b0;
    haddr_m13 = {ADDR_WIDTH{1'b0}};
    hmastlock_m13 = 1'b0;
  end
  if (legal_access[13]) begin
    htrans_m13 = htrans_s;
    hsize_m13 = hsize_s;
    hwrite_m13 = hwrite_s;
    hprot_m13 = hprot_s;
    hburst_m13 = hburst_s;
    hnonsec_m13 = hnonsec_s;
    hexcl_m13 = hexcl_s;
    hmaster_m13 = hmaster_s;
    hauser_m13 = hauser_s;
  end
  else begin
    htrans_m13 = 2'h0;
    hsize_m13  = 3'h0;
    hwrite_m13 = 1'b0;
    hprot_m13  = 7'h0;
    hburst_m13 = 3'h0;
    hnonsec_m13 = 1'b0;
    hexcl_m13 = 1'b0;
    hmaster_m13 = {MASTER_WIDTH{1'b0}};
    hauser_m13 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[13]) begin
    hwdata_m13 = hwdata_s;
    hwuser_m13 = hwuser_s;
  end
  else begin
    hwdata_m13 = {DATA_WIDTH{1'b0}};
    hwuser_m13 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[14]) begin
    hsel_m14 = 1'b1;
    haddr_m14 = haddr_s;
    hmastlock_m14 = hmastlock_s;
  end
  else begin
    hsel_m14  = 1'b0;
    haddr_m14 = {ADDR_WIDTH{1'b0}};
    hmastlock_m14 = 1'b0;
  end
  if (legal_access[14]) begin
    htrans_m14 = htrans_s;
    hsize_m14 = hsize_s;
    hwrite_m14 = hwrite_s;
    hprot_m14 = hprot_s;
    hburst_m14 = hburst_s;
    hnonsec_m14 = hnonsec_s;
    hexcl_m14 = hexcl_s;
    hmaster_m14 = hmaster_s;
    hauser_m14 = hauser_s;
  end
  else begin
    htrans_m14 = 2'h0;
    hsize_m14  = 3'h0;
    hwrite_m14 = 1'b0;
    hprot_m14  = 7'h0;
    hburst_m14 = 3'h0;
    hnonsec_m14 = 1'b0;
    hexcl_m14 = 1'b0;
    hmaster_m14 = {MASTER_WIDTH{1'b0}};
    hauser_m14 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[14]) begin
    hwdata_m14 = hwdata_s;
    hwuser_m14 = hwuser_s;
  end
  else begin
    hwdata_m14 = {DATA_WIDTH{1'b0}};
    hwuser_m14 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[15]) begin
    hsel_m15 = 1'b1;
    haddr_m15 = haddr_s;
    hmastlock_m15 = hmastlock_s;
  end
  else begin
    hsel_m15  = 1'b0;
    haddr_m15 = {ADDR_WIDTH{1'b0}};
    hmastlock_m15 = 1'b0;
  end
  if (legal_access[15]) begin
    htrans_m15 = htrans_s;
    hsize_m15 = hsize_s;
    hwrite_m15 = hwrite_s;
    hprot_m15 = hprot_s;
    hburst_m15 = hburst_s;
    hnonsec_m15 = hnonsec_s;
    hexcl_m15 = hexcl_s;
    hmaster_m15 = hmaster_s;
    hauser_m15 = hauser_s;
  end
  else begin
    htrans_m15 = 2'h0;
    hsize_m15  = 3'h0;
    hwrite_m15 = 1'b0;
    hprot_m15  = 7'h0;
    hburst_m15 = 3'h0;
    hnonsec_m15 = 1'b0;
    hexcl_m15 = 1'b0;
    hmaster_m15 = {MASTER_WIDTH{1'b0}};
    hauser_m15 = {USER_WIDTH{1'b0}};
  end
  if (legal_access_reg[15]) begin
    hwdata_m15 = hwdata_s;
    hwuser_m15 = hwuser_s;
  end
  else begin
    hwdata_m15 = {DATA_WIDTH{1'b0}};
    hwuser_m15 = {USER_WIDTH{1'b0}};
  end
end

always @*
begin
  if (portsel[16]) begin
    hsel_ds = 1'b1;
    if (mux_hready & hready_s | hselo_reg[16]) begin
      htrans_ds = htrans_s;
    end
    else begin
      htrans_ds = 2'h0;
    end
  end
  else begin
    hsel_ds  = 1'b0;
    htrans_ds = 2'h0;
  end
end


always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    legal_access_reg <= 16'h0;
  end
  else if (hready_s && htrans_s[1]) begin
    legal_access_reg <= legal_access;
  end
end

always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    hselo_reg <= 17'h0;
  end
  else if (hready_s) begin
    hselo_reg <= portsel;
  end
end

always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    err_state <= 2'b00;
  end
  else if (hready_s && secure_access_violation) begin
    if ((htrans_s[0] && cfg_sec_resp_seq) || (htrans_s == 2'b10 && cfg_sec_resp_nonseq)) begin
      err_state <= 2'b01;
    end
  end
  else begin
     err_state <= {err_state[0], 1'b0};
  end
end

assign ahb_ppc_irq_set = hready_s & secure_access_violation & ahb_ppc_irq_enable;

always @(posedge hclk or negedge hresetn)
begin
  if (!hresetn) begin
    ahb_ppc_irq <= 1'b0;
  end
  else if (ahb_ppc_irq_clear) begin
     ahb_ppc_irq <= 1'b0;
  end
  else if (ahb_ppc_irq_set) begin
    ahb_ppc_irq <= 1'b1;
  end
end

assign mux_hready =
         (~hselo_reg[0] | hreadyout_m0 | (PORT0_ENABLE==0)) &
         (~hselo_reg[1] | hreadyout_m1 | (PORT1_ENABLE==0)) &
         (~hselo_reg[2] | hreadyout_m2 | (PORT2_ENABLE==0)) &
         (~hselo_reg[3] | hreadyout_m3 | (PORT3_ENABLE==0)) &
         (~hselo_reg[4] | hreadyout_m4 | (PORT4_ENABLE==0)) &
         (~hselo_reg[5] | hreadyout_m5 | (PORT5_ENABLE==0)) &
         (~hselo_reg[6] | hreadyout_m6 | (PORT6_ENABLE==0)) &
         (~hselo_reg[7] | hreadyout_m7 | (PORT7_ENABLE==0)) &
         (~hselo_reg[8] | hreadyout_m8 | (PORT8_ENABLE==0)) &
         (~hselo_reg[9] | hreadyout_m9 | (PORT9_ENABLE==0)) &
         (~hselo_reg[10] | hreadyout_m10 | (PORT10_ENABLE==0)) &
         (~hselo_reg[11] | hreadyout_m11 | (PORT11_ENABLE==0)) &
         (~hselo_reg[12] | hreadyout_m12 | (PORT12_ENABLE==0)) &
         (~hselo_reg[13] | hreadyout_m13 | (PORT13_ENABLE==0)) &
         (~hselo_reg[14] | hreadyout_m14 | (PORT14_ENABLE==0)) &
         (~hselo_reg[15] | hreadyout_m15 | (PORT15_ENABLE==0)) &
         (~hselo_reg[16] | hreadyout_ds);

assign hreadyo = |err_state ? err_state[1] : mux_hready;


assign hreadyout_s = hreadyo;
assign hready_m0   = ~hselo_reg[0] | mux_hready | (|err_state);
assign hready_m1   = ~hselo_reg[1] | mux_hready | (|err_state);
assign hready_m2   = ~hselo_reg[2] | mux_hready | (|err_state);
assign hready_m3   = ~hselo_reg[3] | mux_hready | (|err_state);
assign hready_m4   = ~hselo_reg[4] | mux_hready | (|err_state);
assign hready_m5   = ~hselo_reg[5] | mux_hready | (|err_state);
assign hready_m6   = ~hselo_reg[6] | mux_hready | (|err_state);
assign hready_m7   = ~hselo_reg[7] | mux_hready | (|err_state);
assign hready_m8   = ~hselo_reg[8] | mux_hready | (|err_state);
assign hready_m9   = ~hselo_reg[9] | mux_hready | (|err_state);
assign hready_m10  = ~hselo_reg[10] |mux_hready | (|err_state);
assign hready_m11  = ~hselo_reg[11] |mux_hready | (|err_state);
assign hready_m12  = ~hselo_reg[12] |mux_hready | (|err_state);
assign hready_m13  = ~hselo_reg[13] |mux_hready | (|err_state);
assign hready_m14  = ~hselo_reg[14] |mux_hready | (|err_state);
assign hready_m15  = ~hselo_reg[15] |mux_hready | (|err_state);
assign hready_ds   = ~hselo_reg[16] |mux_hready | (|err_state);

assign hrdata_s =
         ({DATA_WIDTH{(legal_access_reg[0] & (PORT0_ENABLE!=0))}} & hrdata_m0) |
         ({DATA_WIDTH{(legal_access_reg[1] & (PORT1_ENABLE!=0))}} & hrdata_m1) |
         ({DATA_WIDTH{(legal_access_reg[2] & (PORT2_ENABLE!=0))}} & hrdata_m2) |
         ({DATA_WIDTH{(legal_access_reg[3] & (PORT3_ENABLE!=0))}} & hrdata_m3) |
         ({DATA_WIDTH{(legal_access_reg[4] & (PORT4_ENABLE!=0))}} & hrdata_m4) |
         ({DATA_WIDTH{(legal_access_reg[5] & (PORT5_ENABLE!=0))}} & hrdata_m5) |
         ({DATA_WIDTH{(legal_access_reg[6] & (PORT6_ENABLE!=0))}} & hrdata_m6) |
         ({DATA_WIDTH{(legal_access_reg[7] & (PORT7_ENABLE!=0))}} & hrdata_m7) |
         ({DATA_WIDTH{(legal_access_reg[8] & (PORT8_ENABLE!=0))}} & hrdata_m8) |
         ({DATA_WIDTH{(legal_access_reg[9] & (PORT9_ENABLE!=0))}} & hrdata_m9) |
         ({DATA_WIDTH{(legal_access_reg[10] & (PORT10_ENABLE!=0))}} & hrdata_m10) |
         ({DATA_WIDTH{(legal_access_reg[11] & (PORT11_ENABLE!=0))}} & hrdata_m11) |
         ({DATA_WIDTH{(legal_access_reg[12] & (PORT12_ENABLE!=0))}} & hrdata_m12) |
         ({DATA_WIDTH{(legal_access_reg[13] & (PORT13_ENABLE!=0))}} & hrdata_m13) |
         ({DATA_WIDTH{(legal_access_reg[14] & (PORT14_ENABLE!=0))}} & hrdata_m14) |
         ({DATA_WIDTH{(legal_access_reg[15] & (PORT15_ENABLE!=0))}} & hrdata_m15);

assign hruser_s =
         ({USER_WIDTH{(legal_access_reg[0] & (PORT0_ENABLE!=0))}} & hruser_m0) |
         ({USER_WIDTH{(legal_access_reg[1] & (PORT1_ENABLE!=0))}} & hruser_m1) |
         ({USER_WIDTH{(legal_access_reg[2] & (PORT2_ENABLE!=0))}} & hruser_m2) |
         ({USER_WIDTH{(legal_access_reg[3] & (PORT3_ENABLE!=0))}} & hruser_m3) |
         ({USER_WIDTH{(legal_access_reg[4] & (PORT4_ENABLE!=0))}} & hruser_m4) |
         ({USER_WIDTH{(legal_access_reg[5] & (PORT5_ENABLE!=0))}} & hruser_m5) |
         ({USER_WIDTH{(legal_access_reg[6] & (PORT6_ENABLE!=0))}} & hruser_m6) |
         ({USER_WIDTH{(legal_access_reg[7] & (PORT7_ENABLE!=0))}} & hruser_m7) |
         ({USER_WIDTH{(legal_access_reg[8] & (PORT8_ENABLE!=0))}} & hruser_m8) |
         ({USER_WIDTH{(legal_access_reg[9] & (PORT9_ENABLE!=0))}} & hruser_m9) |
         ({USER_WIDTH{(legal_access_reg[10] & (PORT10_ENABLE!=0))}} & hruser_m10) |
         ({USER_WIDTH{(legal_access_reg[11] & (PORT11_ENABLE!=0))}} & hruser_m11) |
         ({USER_WIDTH{(legal_access_reg[12] & (PORT12_ENABLE!=0))}} & hruser_m12) |
         ({USER_WIDTH{(legal_access_reg[13] & (PORT13_ENABLE!=0))}} & hruser_m13) |
         ({USER_WIDTH{(legal_access_reg[14] & (PORT14_ENABLE!=0))}} & hruser_m14) |
         ({USER_WIDTH{(legal_access_reg[15] & (PORT15_ENABLE!=0))}} & hruser_m15);

assign hresp_s =
         (hselo_reg[0] & hresp_m0 & (PORT0_ENABLE!=0)) |
         (hselo_reg[1] & hresp_m1 & (PORT1_ENABLE!=0)) |
         (hselo_reg[2] & hresp_m2 & (PORT2_ENABLE!=0)) |
         (hselo_reg[3] & hresp_m3 & (PORT3_ENABLE!=0)) |
         (hselo_reg[4] & hresp_m4 & (PORT4_ENABLE!=0)) |
         (hselo_reg[5] & hresp_m5 & (PORT5_ENABLE!=0)) |
         (hselo_reg[6] & hresp_m6 & (PORT6_ENABLE!=0)) |
         (hselo_reg[7] & hresp_m7 & (PORT7_ENABLE!=0)) |
         (hselo_reg[8] & hresp_m8 & (PORT8_ENABLE!=0)) |
         (hselo_reg[9] & hresp_m9 & (PORT9_ENABLE!=0)) |
         (hselo_reg[10] & hresp_m10 & (PORT10_ENABLE!=0)) |
         (hselo_reg[11] & hresp_m11 & (PORT11_ENABLE!=0)) |
         (hselo_reg[12] & hresp_m12 & (PORT12_ENABLE!=0)) |
         (hselo_reg[13] & hresp_m13 & (PORT13_ENABLE!=0)) |
         (hselo_reg[14] & hresp_m14 & (PORT14_ENABLE!=0)) |
         (hselo_reg[15] & hresp_m15 & (PORT15_ENABLE!=0)) |
         (hselo_reg[16] & hresp_ds) |
         (err_state != 2'h0);

assign hexokay_s =
         (legal_access_reg[0] & hexokay_m0 & (PORT0_ENABLE!=0)) |
         (legal_access_reg[1] & hexokay_m1 & (PORT1_ENABLE!=0)) |
         (legal_access_reg[2] & hexokay_m2 & (PORT2_ENABLE!=0)) |
         (legal_access_reg[3] & hexokay_m3 & (PORT3_ENABLE!=0)) |
         (legal_access_reg[4] & hexokay_m4 & (PORT4_ENABLE!=0)) |
         (legal_access_reg[5] & hexokay_m5 & (PORT5_ENABLE!=0)) |
         (legal_access_reg[6] & hexokay_m6 & (PORT6_ENABLE!=0)) |
         (legal_access_reg[7] & hexokay_m7 & (PORT7_ENABLE!=0)) |
         (legal_access_reg[8] & hexokay_m8 & (PORT8_ENABLE!=0)) |
         (legal_access_reg[9] & hexokay_m9 & (PORT9_ENABLE!=0)) |
         (legal_access_reg[10] & hexokay_m10 & (PORT10_ENABLE!=0)) |
         (legal_access_reg[11] & hexokay_m11 & (PORT11_ENABLE!=0)) |
         (legal_access_reg[12] & hexokay_m12 & (PORT12_ENABLE!=0)) |
         (legal_access_reg[13] & hexokay_m13 & (PORT13_ENABLE!=0)) |
         (legal_access_reg[14] & hexokay_m14 & (PORT14_ENABLE!=0)) |
         (legal_access_reg[15] & hexokay_m15 & (PORT15_ENABLE!=0)) |
         (hselo_reg[16] & hexokay_ds);










endmodule


