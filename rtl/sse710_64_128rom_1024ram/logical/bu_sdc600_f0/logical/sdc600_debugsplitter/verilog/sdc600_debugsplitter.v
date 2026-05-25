//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2017-2018 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Tue May 22 09:27:48 2018 +0100
//
//      Revision            : 5b82019
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_debugsplitter #(
  parameter [31:0]  COM_BASE_ADDR     = 32'hFFFF_E000

 )(

  input  wire                     clk,
  input  wire                     reset_n,

  input  wire                     dbgen,
  input  wire                     niden,
  input  wire                     spiden,
  input  wire                     spniden,

  input  wire             [31:0]  slvaddr_s,
  input  wire             [ 6:0]  slvprot_s,
  input  wire             [ 1:0]  slvsize_s,
  input  wire                     slvnonsec_s,
  input  wire             [ 1:0]  slvtrans_s,
  input  wire             [31:0]  slvwdata_s,
  input  wire                     slvwrite_s,
  output wire             [31:0]  slvrdata_s,
  output wire                     slvresp_s,
  output wire                     slvready_s,

  output wire             [31:0]  slvaddr_m,
  output wire             [ 6:0]  slvprot_m,
  output wire             [ 1:0]  slvsize_m,
  output wire                     slvnonsec_m,
  output wire             [ 1:0]  slvtrans_m,
  output wire             [31:0]  slvwdata_m,
  output wire                     slvwrite_m,
  input  wire             [31:0]  slvrdata_m,
  input  wire                     slvresp_m,
  input  wire                     slvready_m,

  output wire             [11:0]  paddr_m,
  output wire                     psel_m,
  output wire                     penable_m,
  output wire                     pwrite_m,
  output wire             [31:0]  pwdata_m,
  input  wire             [31:0]  prdata_m,
  input  wire                     pready_m,
  input  wire                     pslverr_m
);

wire          slvsel_ahb2apb;
wire [31: 0]  slvaddr_ahb2apb;
wire [ 1: 0]  slvtrans_ahb2apb;
wire [ 2: 0]  slvsize_ahb2apb;
wire [31: 0]  slvwdata_ahb2apb;
wire [31: 0]  slvrdata_ahb2apb;
wire          slvreadyout_ahb2apb;
wire          slvready_ahb2apb;
wire          slvresp_ahb2apb;
wire          slvwrite_ahb2apb;

wire          slvsel_defslv;
wire [ 1: 0]  slvtrans_defslv;
wire          slvexokay_defslv;
wire          slvresp_defslv;
wire          slvready_defslv;
wire          slvreadyout_defslv;

wire [ 2: 0]  slvsel_decoder;

wire          slvready_s_fb;
assign        slvready_s = slvready_s_fb;

wire          tie_low   = 1'b0;
wire          tie_high  = 1'b1;

wire [ 1: 0]  slvtrans_defslv_gated  = slvtrans_defslv          & {2{slvsel_decoder[2]}};
wire [ 1: 0]  slvtrans_defslv_nongated;
assign        slvtrans_m             = slvtrans_defslv_nongated & {2{slvsel_decoder[0]}};

wire [2:0] slvsize_s_long;
wire [2:0] slvsize_m_long;
assign slvsize_s_long = {tie_low, slvsize_s};
assign slvsize_m  = slvsize_m_long[1:0];

wire [19:0] unused_slvaddr_ahb2apb = slvaddr_ahb2apb[31:12];

sdc600_ahb5_slave_mux #(
  .PORT0_ENABLE    ( 1),
  .PORT1_ENABLE    ( 1),
  .PORT2_ENABLE    ( 1),
  .PORT3_ENABLE    ( 0),
  .PORT4_ENABLE    ( 0),
  .PORT5_ENABLE    ( 0),
  .PORT6_ENABLE    ( 0),
  .PORT7_ENABLE    ( 0),
  .PORT8_ENABLE    ( 0),
  .PORT9_ENABLE    ( 0),
  .PORT10_ENABLE   ( 0),
  .PORT11_ENABLE   ( 0),
  .PORT12_ENABLE   ( 0),
  .PORT13_ENABLE   ( 0),
  .PORT14_ENABLE   ( 0),
  .PORT15_ENABLE   ( 0),
  .ADDR_WIDTH      (32),
  .DATA_WIDTH      (32),
  .MASTER_WIDTH    ( 1),
  .USER_WIDTH      ( 1)
) u_sdc600_ahb_slave_mux (

  .hclk             (clk),
  .hresetn          (reset_n),

  .haddr_s          (slvaddr_s),
  .hburst_s         ({3{tie_low}}),
  .hmastlock_s      (tie_low),
  .hprot_s          (slvprot_s),
  .hsize_s          (slvsize_s_long),
  .hnonsec_s        (slvnonsec_s),
  .hexcl_s          (tie_low),
  .hmaster_s        (tie_low),
  .htrans_s         (slvtrans_s),
  .hwdata_s         (slvwdata_s),
  .hwrite_s         (slvwrite_s),
  .hrdata_s         (slvrdata_s),
  .hreadyout_s      (slvready_s_fb),
  .hresp_s          (slvresp_s),
  .hexokay_s        (),
  .hsel_s           ({{13{tie_low}},slvsel_decoder}),
  .hready_s         (slvready_s_fb),
  .hauser_s         (tie_low),
  .hwuser_s         (tie_low),
  .hruser_s         (),

  .haddr_m0         (slvaddr_m),
  .hburst_m0        (),
  .hmastlock_m0     (),
  .hprot_m0         (slvprot_m),
  .hsize_m0         (slvsize_m_long),
  .hnonsec_m0       (slvnonsec_m),
  .hexcl_m0         (),
  .hmaster_m0       (),
  .htrans_m0        (slvtrans_defslv_nongated),
  .hwdata_m0        (slvwdata_m),
  .hwrite_m0        (slvwrite_m),
  .hrdata_m0        (slvrdata_m),
  .hreadyout_m0     (slvready_m),
  .hresp_m0         (slvresp_m),
  .hexokay_m0       (tie_high),
  .hsel_m0          (),
  .hready_m0        (),
  .hauser_m0        (),
  .hwuser_m0        (),
  .hruser_m0        (tie_low),

  .haddr_m1         (slvaddr_ahb2apb),
  .hburst_m1        (),
  .hmastlock_m1     (),
  .hprot_m1         (),
  .hsize_m1         (slvsize_ahb2apb),
  .hnonsec_m1       (),
  .hexcl_m1         (),
  .hmaster_m1       (),
  .htrans_m1        (slvtrans_ahb2apb),
  .hwdata_m1        (slvwdata_ahb2apb),
  .hwrite_m1        (slvwrite_ahb2apb),
  .hrdata_m1        (slvrdata_ahb2apb),
  .hreadyout_m1     (slvreadyout_ahb2apb),
  .hresp_m1         (slvresp_ahb2apb),
  .hexokay_m1       (tie_high),
  .hsel_m1          (slvsel_ahb2apb),
  .hready_m1        (slvready_ahb2apb),
  .hauser_m1        (),
  .hwuser_m1        (),
  .hruser_m1        (tie_low),

  .haddr_m2         (),
  .hburst_m2        (),
  .hmastlock_m2     (),
  .hprot_m2         (),
  .hsize_m2         (),
  .hnonsec_m2       (),
  .hexcl_m2         (),
  .hmaster_m2       (),
  .htrans_m2        (slvtrans_defslv),
  .hwdata_m2        (),
  .hwrite_m2        (),
  .hrdata_m2        ({(32){tie_low}}),
  .hreadyout_m2     (slvreadyout_defslv),
  .hresp_m2         (slvresp_defslv),
  .hexokay_m2       (slvexokay_defslv),
  .hsel_m2          (slvsel_defslv),
  .hready_m2        (slvready_defslv),
  .hauser_m2        (),
  .hwuser_m2        (),
  .hruser_m2        (tie_low),

  .hrdata_m3        ({(32){tie_low}}),
  .hreadyout_m3     (tie_high),
  .hresp_m3         (tie_low),
  .hexokay_m3       (tie_high),
  .hruser_m3        (tie_low),

  .haddr_m3         (),
  .hburst_m3        (),
  .hmastlock_m3     (),
  .hprot_m3         (),
  .hsize_m3         (),
  .hnonsec_m3       (),
  .hexcl_m3         (),
  .hmaster_m3       (),
  .htrans_m3        (),
  .hwdata_m3        (),
  .hwrite_m3        (),
  .hsel_m3          (),
  .hready_m3        (),
  .hauser_m3        (),
  .hwuser_m3        (),

  .hrdata_m4        ({(32){tie_low}}),
  .hreadyout_m4     (tie_high),
  .hresp_m4         (tie_low),
  .hexokay_m4       (tie_high),
  .hruser_m4        (tie_low),

  .haddr_m4         (),
  .hburst_m4        (),
  .hmastlock_m4     (),
  .hprot_m4         (),
  .hsize_m4         (),
  .hnonsec_m4       (),
  .hexcl_m4         (),
  .hmaster_m4       (),
  .htrans_m4        (),
  .hwdata_m4        (),
  .hwrite_m4        (),
  .hsel_m4          (),
  .hready_m4        (),
  .hauser_m4        (),
  .hwuser_m4        (),

  .hrdata_m5        ({(32){tie_low}}),
  .hreadyout_m5     (tie_high),
  .hresp_m5         (tie_low),
  .hexokay_m5       (tie_high),
  .hruser_m5        (tie_low),

  .haddr_m5         (),
  .hburst_m5        (),
  .hmastlock_m5     (),
  .hprot_m5         (),
  .hsize_m5         (),
  .hnonsec_m5       (),
  .hexcl_m5         (),
  .hmaster_m5       (),
  .htrans_m5        (),
  .hwdata_m5        (),
  .hwrite_m5        (),
  .hsel_m5          (),
  .hready_m5        (),
  .hauser_m5        (),
  .hwuser_m5        (),

  .hrdata_m6        ({(32){tie_low}}),
  .hreadyout_m6     (tie_high),
  .hresp_m6         (tie_low),
  .hexokay_m6       (tie_high),
  .hruser_m6        (tie_low),

  .haddr_m6         (),
  .hburst_m6        (),
  .hmastlock_m6     (),
  .hprot_m6         (),
  .hsize_m6         (),
  .hnonsec_m6       (),
  .hexcl_m6         (),
  .hmaster_m6       (),
  .htrans_m6        (),
  .hwdata_m6        (),
  .hwrite_m6        (),
  .hsel_m6          (),
  .hready_m6        (),
  .hauser_m6        (),
  .hwuser_m6        (),

  .hrdata_m7        ({(32){tie_low}}),
  .hreadyout_m7     (tie_high),
  .hresp_m7         (tie_low),
  .hexokay_m7       (tie_high),
  .hruser_m7        (tie_low),

  .haddr_m7         (),
  .hburst_m7        (),
  .hmastlock_m7     (),
  .hprot_m7         (),
  .hsize_m7         (),
  .hnonsec_m7       (),
  .hexcl_m7         (),
  .hmaster_m7       (),
  .htrans_m7        (),
  .hwdata_m7        (),
  .hwrite_m7        (),
  .hsel_m7          (),
  .hready_m7        (),
  .hauser_m7        (),
  .hwuser_m7        (),

  .hrdata_m8        ({(32){tie_low}}),
  .hreadyout_m8     (tie_high),
  .hresp_m8         (tie_low),
  .hexokay_m8       (tie_high),
  .hruser_m8        (tie_low),

  .haddr_m8         (),
  .hburst_m8        (),
  .hmastlock_m8     (),
  .hprot_m8         (),
  .hsize_m8         (),
  .hnonsec_m8       (),
  .hexcl_m8         (),
  .hmaster_m8       (),
  .htrans_m8        (),
  .hwdata_m8        (),
  .hwrite_m8        (),
  .hsel_m8          (),
  .hready_m8        (),
  .hauser_m8        (),
  .hwuser_m8        (),

  .hrdata_m9        ({(32){tie_low}}),
  .hreadyout_m9     (tie_high),
  .hresp_m9         (tie_low),
  .hexokay_m9       (tie_high),
  .hruser_m9        (tie_low),

  .haddr_m9         (),
  .hburst_m9        (),
  .hmastlock_m9     (),
  .hprot_m9         (),
  .hsize_m9         (),
  .hnonsec_m9       (),
  .hexcl_m9         (),
  .hmaster_m9       (),
  .htrans_m9        (),
  .hwdata_m9        (),
  .hwrite_m9        (),
  .hsel_m9          (),
  .hready_m9        (),
  .hauser_m9        (),
  .hwuser_m9        (),

  .hrdata_m10       ({(32){tie_low}}),
  .hreadyout_m10    (tie_high),
  .hresp_m10        (tie_low),
  .hexokay_m10      (tie_high),
  .hruser_m10       (tie_low),

  .haddr_m10        (),
  .hburst_m10       (),
  .hmastlock_m10    (),
  .hprot_m10        (),
  .hsize_m10        (),
  .hnonsec_m10      (),
  .hexcl_m10        (),
  .hmaster_m10      (),
  .htrans_m10       (),
  .hwdata_m10       (),
  .hwrite_m10       (),
  .hsel_m10         (),
  .hready_m10       (),
  .hauser_m10       (),
  .hwuser_m10       (),

  .hrdata_m11       ({(32){tie_low}}),
  .hreadyout_m11    (tie_high),
  .hresp_m11        (tie_low),
  .hexokay_m11      (tie_high),
  .hruser_m11       (tie_low),

  .haddr_m11        (),
  .hburst_m11       (),
  .hmastlock_m11    (),
  .hprot_m11        (),
  .hsize_m11        (),
  .hnonsec_m11      (),
  .hexcl_m11        (),
  .hmaster_m11      (),
  .htrans_m11       (),
  .hwdata_m11       (),
  .hwrite_m11       (),
  .hsel_m11         (),
  .hready_m11       (),
  .hauser_m11       (),
  .hwuser_m11       (),

  .hrdata_m12       ({(32){tie_low}}),
  .hreadyout_m12    (tie_high),
  .hresp_m12        (tie_low),
  .hexokay_m12      (tie_high),
  .hruser_m12       (tie_low),

  .haddr_m12        (),
  .hburst_m12       (),
  .hmastlock_m12    (),
  .hprot_m12        (),
  .hsize_m12        (),
  .hnonsec_m12      (),
  .hexcl_m12        (),
  .hmaster_m12      (),
  .htrans_m12       (),
  .hwdata_m12       (),
  .hwrite_m12       (),
  .hsel_m12         (),
  .hready_m12       (),
  .hauser_m12       (),
  .hwuser_m12       (),

  .hrdata_m13       ({(32){tie_low}}),
  .hreadyout_m13    (tie_high),
  .hresp_m13        (tie_low),
  .hexokay_m13      (tie_high),
  .hruser_m13       (tie_low),

  .haddr_m13        (),
  .hburst_m13       (),
  .hmastlock_m13    (),
  .hprot_m13        (),
  .hsize_m13        (),
  .hnonsec_m13      (),
  .hexcl_m13        (),
  .hmaster_m13      (),
  .htrans_m13       (),
  .hwdata_m13       (),
  .hwrite_m13       (),
  .hsel_m13         (),
  .hready_m13       (),
  .hauser_m13       (),
  .hwuser_m13       (),

  .hrdata_m14       ({(32){tie_low}}),
  .hreadyout_m14    (tie_high),
  .hresp_m14        (tie_low),
  .hexokay_m14      (tie_high),
  .hruser_m14       (tie_low),

  .haddr_m14        (),
  .hburst_m14       (),
  .hmastlock_m14    (),
  .hprot_m14        (),
  .hsize_m14        (),
  .hnonsec_m14      (),
  .hexcl_m14        (),
  .hmaster_m14      (),
  .htrans_m14       (),
  .hwdata_m14       (),
  .hwrite_m14       (),
  .hsel_m14         (),
  .hready_m14       (),
  .hauser_m14       (),
  .hwuser_m14       (),

  .hrdata_m15       ({(32){tie_low}}),
  .hreadyout_m15    (tie_high),
  .hresp_m15        (tie_low),
  .hexokay_m15      (tie_high),
  .hruser_m15       (tie_low),

  .haddr_m15        (),
  .hburst_m15       (),
  .hmastlock_m15    (),
  .hprot_m15        (),
  .hsize_m15        (),
  .hnonsec_m15      (),
  .hexcl_m15        (),
  .hmaster_m15      (),
  .htrans_m15       (),
  .hwdata_m15       (),
  .hwrite_m15       (),
  .hsel_m15         (),
  .hready_m15       (),
  .hauser_m15       (),
  .hwuser_m15       ()
);

sdc600_ahb5_to_apb_sync_wrapper u_sdc600_ahb_to_apb_sync_wrapper (
  .hclk       (clk),
  .hresetn    (reset_n),
  .hsel       (slvsel_ahb2apb),
  .haddr      (slvaddr_ahb2apb[11:0]),
  .htrans     (slvtrans_ahb2apb),
  .hsize      (slvsize_ahb2apb),
  .hwrite     (slvwrite_ahb2apb),
  .hready     (slvready_ahb2apb),
  .hwdata     (slvwdata_ahb2apb),
  .hreadyout  (slvreadyout_ahb2apb),
  .hrdata     (slvrdata_ahb2apb),
  .hresp      (slvresp_ahb2apb),
  .paddr      (paddr_m),
  .penable    (penable_m),
  .pwrite     (pwrite_m),
  .pwdata     (pwdata_m),
  .psel       (psel_m),
  .prdata     (prdata_m),
  .pready     (pready_m),
  .pslverr    (pslverr_m)
);

sdc600_ahb5_default_slave u_sdc600_ahb5_default_slave (
  .hclk       (clk),
  .hresetn    (reset_n),
  .hsel       (slvsel_defslv),
  .htrans     (slvtrans_defslv_gated),
  .hready     (slvready_defslv),
  .hexokay    (slvexokay_defslv),
  .hreadyout  (slvreadyout_defslv),
  .hresp      (slvresp_defslv)
);

sdc600_debugsplitter_address_decoder #(
  .ADDR_WIDTH     (32),
  .COM_BASE_ADDR  (COM_BASE_ADDR)
) u_sdc600_debugsplitter_address_decoder (
  .slvaddr    (slvaddr_s),
  .dbgen      (dbgen),
  .niden      (niden),
  .spiden     (spiden),
  .spniden    (spniden),
  .slvsize    (slvsize_s_long),
  .slvsel_m   (slvsel_decoder)
);


endmodule
