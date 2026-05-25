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
//      Checked In          : Mon Feb 19 12:27:52 2018 +0000
//
//      Revision            : bdc4508
//
//      Release Information : TM210-MN-22110-r0p2-00rel0
//
//----------------------------------------------------------------------------

module sdc600_ahb5_slave_mux #(
  parameter PORT0_ENABLE=1,
  parameter PORT1_ENABLE=1,
  parameter PORT2_ENABLE=1,
  parameter PORT3_ENABLE=1,
  parameter PORT4_ENABLE=1,
  parameter PORT5_ENABLE=1,
  parameter PORT6_ENABLE=1,
  parameter PORT7_ENABLE=1,
  parameter PORT8_ENABLE=1,
  parameter PORT9_ENABLE=1,
  parameter PORT10_ENABLE=1,
  parameter PORT11_ENABLE=1,
  parameter PORT12_ENABLE=1,
  parameter PORT13_ENABLE=1,
  parameter PORT14_ENABLE=1,
  parameter PORT15_ENABLE=1,
  parameter ADDR_WIDTH  =32,
  parameter DATA_WIDTH  =32,
  parameter MASTER_WIDTH=4,
  parameter USER_WIDTH  =1
  )
  (
    input wire                      hclk,
    input wire                      hresetn,

    input  wire [ADDR_WIDTH-1:0]    haddr_s,
    input  wire [2:0]               hburst_s,
    input  wire                     hmastlock_s,
    input  wire [6:0]               hprot_s,
    input  wire [2:0]               hsize_s,
    input  wire                     hnonsec_s,
    input  wire                     hexcl_s,
    input  wire [MASTER_WIDTH-1:0]  hmaster_s,
    input  wire [1:0]               htrans_s,
    input  wire [DATA_WIDTH-1:0]    hwdata_s,
    input  wire                     hwrite_s,
    output wire [DATA_WIDTH-1:0]    hrdata_s,
    output wire                     hreadyout_s,
    output wire                     hresp_s,
    output wire                     hexokay_s,
    input  wire [15:0]              hsel_s,
    input  wire                     hready_s,
    input  wire [USER_WIDTH-1:0]    hauser_s,
    input  wire [USER_WIDTH-1:0]    hwuser_s,
    output wire [USER_WIDTH-1:0]    hruser_s,

    output wire [ADDR_WIDTH-1:0]    haddr_m0,
    output wire [2:0]               hburst_m0,
    output wire                     hmastlock_m0,
    output wire [6:0]               hprot_m0,
    output wire [2:0]               hsize_m0,
    output wire                     hnonsec_m0,
    output wire                     hexcl_m0,
    output wire [MASTER_WIDTH-1:0]  hmaster_m0,
    output wire [1:0]               htrans_m0,
    output wire [DATA_WIDTH-1:0]    hwdata_m0,
    output wire                     hwrite_m0,
    input  wire [DATA_WIDTH-1:0]    hrdata_m0,
    input  wire                     hreadyout_m0,
    input  wire                     hresp_m0,
    input  wire                     hexokay_m0,
    output wire                     hsel_m0,
    output wire                     hready_m0,
    output wire [USER_WIDTH-1:0]    hauser_m0,
    output wire [USER_WIDTH-1:0]    hwuser_m0,
    input  wire [USER_WIDTH-1:0]    hruser_m0,

    output wire [ADDR_WIDTH-1:0]    haddr_m1,
    output wire [2:0]               hburst_m1,
    output wire                     hmastlock_m1,
    output wire [6:0]               hprot_m1,
    output wire [2:0]               hsize_m1,
    output wire                     hnonsec_m1,
    output wire                     hexcl_m1,
    output wire [MASTER_WIDTH-1:0]  hmaster_m1,
    output wire [1:0]               htrans_m1,
    output wire [DATA_WIDTH-1:0]    hwdata_m1,
    output wire                     hwrite_m1,
    input  wire [DATA_WIDTH-1:0]    hrdata_m1,
    input  wire                     hreadyout_m1,
    input  wire                     hresp_m1,
    input  wire                     hexokay_m1,
    output wire                     hsel_m1,
    output wire                     hready_m1,
    output wire [USER_WIDTH-1:0]    hauser_m1,
    output wire [USER_WIDTH-1:0]    hwuser_m1,
    input  wire [USER_WIDTH-1:0]    hruser_m1,

    output wire [ADDR_WIDTH-1:0]    haddr_m2,
    output wire [2:0]               hburst_m2,
    output wire                     hmastlock_m2,
    output wire [6:0]               hprot_m2,
    output wire [2:0]               hsize_m2,
    output wire                     hnonsec_m2,
    output wire                     hexcl_m2,
    output wire [MASTER_WIDTH-1:0]  hmaster_m2,
    output wire [1:0]               htrans_m2,
    output wire [DATA_WIDTH-1:0]    hwdata_m2,
    output wire                     hwrite_m2,
    input  wire [DATA_WIDTH-1:0]    hrdata_m2,
    input  wire                     hreadyout_m2,
    input  wire                     hresp_m2,
    input  wire                     hexokay_m2,
    output wire                     hsel_m2,
    output wire                     hready_m2,
    output wire [USER_WIDTH-1:0]    hauser_m2,
    output wire [USER_WIDTH-1:0]    hwuser_m2,
    input  wire [USER_WIDTH-1:0]    hruser_m2,

    output wire [ADDR_WIDTH-1:0]    haddr_m3,
    output wire [2:0]               hburst_m3,
    output wire                     hmastlock_m3,
    output wire [6:0]               hprot_m3,
    output wire [2:0]               hsize_m3,
    output wire                     hnonsec_m3,
    output wire                     hexcl_m3,
    output wire [MASTER_WIDTH-1:0]  hmaster_m3,
    output wire [1:0]               htrans_m3,
    output wire [DATA_WIDTH-1:0]    hwdata_m3,
    output wire                     hwrite_m3,
    input  wire [DATA_WIDTH-1:0]    hrdata_m3,
    input  wire                     hreadyout_m3,
    input  wire                     hresp_m3,
    input  wire                     hexokay_m3,
    output wire                     hsel_m3,
    output wire                     hready_m3,
    output wire [USER_WIDTH-1:0]    hauser_m3,
    output wire [USER_WIDTH-1:0]    hwuser_m3,
    input  wire [USER_WIDTH-1:0]    hruser_m3,

    output wire [ADDR_WIDTH-1:0]    haddr_m4,
    output wire [2:0]               hburst_m4,
    output wire                     hmastlock_m4,
    output wire [6:0]               hprot_m4,
    output wire [2:0]               hsize_m4,
    output wire                     hnonsec_m4,
    output wire                     hexcl_m4,
    output wire [MASTER_WIDTH-1:0]  hmaster_m4,
    output wire [1:0]               htrans_m4,
    output wire [DATA_WIDTH-1:0]    hwdata_m4,
    output wire                     hwrite_m4,
    input  wire [DATA_WIDTH-1:0]    hrdata_m4,
    input  wire                     hreadyout_m4,
    input  wire                     hresp_m4,
    input  wire                     hexokay_m4,
    output wire                     hsel_m4,
    output wire                     hready_m4,
    output wire [USER_WIDTH-1:0]    hauser_m4,
    output wire [USER_WIDTH-1:0]    hwuser_m4,
    input  wire [USER_WIDTH-1:0]    hruser_m4,

    output wire [ADDR_WIDTH-1:0]    haddr_m5,
    output wire [2:0]               hburst_m5,
    output wire                     hmastlock_m5,
    output wire [6:0]               hprot_m5,
    output wire [2:0]               hsize_m5,
    output wire                     hnonsec_m5,
    output wire                     hexcl_m5,
    output wire [MASTER_WIDTH-1:0]  hmaster_m5,
    output wire [1:0]               htrans_m5,
    output wire [DATA_WIDTH-1:0]    hwdata_m5,
    output wire                     hwrite_m5,
    input  wire [DATA_WIDTH-1:0]    hrdata_m5,
    input  wire                     hreadyout_m5,
    input  wire                     hresp_m5,
    input  wire                     hexokay_m5,
    output wire                     hsel_m5,
    output wire                     hready_m5,
    output wire [USER_WIDTH-1:0]    hauser_m5,
    output wire [USER_WIDTH-1:0]    hwuser_m5,
    input  wire [USER_WIDTH-1:0]    hruser_m5,

    output wire [ADDR_WIDTH-1:0]    haddr_m6,
    output wire [2:0]               hburst_m6,
    output wire                     hmastlock_m6,
    output wire [6:0]               hprot_m6,
    output wire [2:0]               hsize_m6,
    output wire                     hnonsec_m6,
    output wire                     hexcl_m6,
    output wire [MASTER_WIDTH-1:0]  hmaster_m6,
    output wire [1:0]               htrans_m6,
    output wire [DATA_WIDTH-1:0]    hwdata_m6,
    output wire                     hwrite_m6,
    input  wire [DATA_WIDTH-1:0]    hrdata_m6,
    input  wire                     hreadyout_m6,
    input  wire                     hresp_m6,
    input  wire                     hexokay_m6,
    output wire                     hsel_m6,
    output wire                     hready_m6,
    output wire [USER_WIDTH-1:0]    hauser_m6,
    output wire [USER_WIDTH-1:0]    hwuser_m6,
    input  wire [USER_WIDTH-1:0]    hruser_m6,

    output wire [ADDR_WIDTH-1:0]    haddr_m7,
    output wire [2:0]               hburst_m7,
    output wire                     hmastlock_m7,
    output wire [6:0]               hprot_m7,
    output wire [2:0]               hsize_m7,
    output wire                     hnonsec_m7,
    output wire                     hexcl_m7,
    output wire [MASTER_WIDTH-1:0]  hmaster_m7,
    output wire [1:0]               htrans_m7,
    output wire [DATA_WIDTH-1:0]    hwdata_m7,
    output wire                     hwrite_m7,
    input  wire [DATA_WIDTH-1:0]    hrdata_m7,
    input  wire                     hreadyout_m7,
    input  wire                     hresp_m7,
    input  wire                     hexokay_m7,
    output wire                     hsel_m7,
    output wire                     hready_m7,
    output wire [USER_WIDTH-1:0]    hauser_m7,
    output wire [USER_WIDTH-1:0]    hwuser_m7,
    input  wire [USER_WIDTH-1:0]    hruser_m7,

    output wire [ADDR_WIDTH-1:0]    haddr_m8,
    output wire [2:0]               hburst_m8,
    output wire                     hmastlock_m8,
    output wire [6:0]               hprot_m8,
    output wire [2:0]               hsize_m8,
    output wire                     hnonsec_m8,
    output wire                     hexcl_m8,
    output wire [MASTER_WIDTH-1:0]  hmaster_m8,
    output wire [1:0]               htrans_m8,
    output wire [DATA_WIDTH-1:0]    hwdata_m8,
    output wire                     hwrite_m8,
    input  wire [DATA_WIDTH-1:0]    hrdata_m8,
    input  wire                     hreadyout_m8,
    input  wire                     hresp_m8,
    input  wire                     hexokay_m8,
    output wire                     hsel_m8,
    output wire                     hready_m8,
    output wire [USER_WIDTH-1:0]    hauser_m8,
    output wire [USER_WIDTH-1:0]    hwuser_m8,
    input  wire [USER_WIDTH-1:0]    hruser_m8,

    output wire [ADDR_WIDTH-1:0]    haddr_m9,
    output wire [2:0]               hburst_m9,
    output wire                     hmastlock_m9,
    output wire [6:0]               hprot_m9,
    output wire [2:0]               hsize_m9,
    output wire                     hnonsec_m9,
    output wire                     hexcl_m9,
    output wire [MASTER_WIDTH-1:0]  hmaster_m9,
    output wire [1:0]               htrans_m9,
    output wire [DATA_WIDTH-1:0]    hwdata_m9,
    output wire                     hwrite_m9,
    input  wire [DATA_WIDTH-1:0]    hrdata_m9,
    input  wire                     hreadyout_m9,
    input  wire                     hresp_m9,
    input  wire                     hexokay_m9,
    output wire                     hsel_m9,
    output wire                     hready_m9,
    output wire [USER_WIDTH-1:0]    hauser_m9,
    output wire [USER_WIDTH-1:0]    hwuser_m9,
    input  wire [USER_WIDTH-1:0]    hruser_m9,

    output wire [ADDR_WIDTH-1:0]    haddr_m10,
    output wire [2:0]               hburst_m10,
    output wire                     hmastlock_m10,
    output wire [6:0]               hprot_m10,
    output wire [2:0]               hsize_m10,
    output wire                     hnonsec_m10,
    output wire                     hexcl_m10,
    output wire [MASTER_WIDTH-1:0]  hmaster_m10,
    output wire [1:0]               htrans_m10,
    output wire [DATA_WIDTH-1:0]    hwdata_m10,
    output wire                     hwrite_m10,
    input  wire [DATA_WIDTH-1:0]    hrdata_m10,
    input  wire                     hreadyout_m10,
    input  wire                     hresp_m10,
    input  wire                     hexokay_m10,
    output wire                     hsel_m10,
    output wire                     hready_m10,
    output wire [USER_WIDTH-1:0]    hauser_m10,
    output wire [USER_WIDTH-1:0]    hwuser_m10,
    input  wire [USER_WIDTH-1:0]    hruser_m10,

    output wire [ADDR_WIDTH-1:0]    haddr_m11,
    output wire [2:0]               hburst_m11,
    output wire                     hmastlock_m11,
    output wire [6:0]               hprot_m11,
    output wire [2:0]               hsize_m11,
    output wire                     hnonsec_m11,
    output wire                     hexcl_m11,
    output wire [MASTER_WIDTH-1:0]  hmaster_m11,
    output wire [1:0]               htrans_m11,
    output wire [DATA_WIDTH-1:0]    hwdata_m11,
    output wire                     hwrite_m11,
    input  wire [DATA_WIDTH-1:0]    hrdata_m11,
    input  wire                     hreadyout_m11,
    input  wire                     hresp_m11,
    input  wire                     hexokay_m11,
    output wire                     hsel_m11,
    output wire                     hready_m11,
    output wire [USER_WIDTH-1:0]    hauser_m11,
    output wire [USER_WIDTH-1:0]    hwuser_m11,
    input  wire [USER_WIDTH-1:0]    hruser_m11,

    output wire [ADDR_WIDTH-1:0]    haddr_m12,
    output wire [2:0]               hburst_m12,
    output wire                     hmastlock_m12,
    output wire [6:0]               hprot_m12,
    output wire [2:0]               hsize_m12,
    output wire                     hnonsec_m12,
    output wire                     hexcl_m12,
    output wire [MASTER_WIDTH-1:0]  hmaster_m12,
    output wire [1:0]               htrans_m12,
    output wire [DATA_WIDTH-1:0]    hwdata_m12,
    output wire                     hwrite_m12,
    input  wire [DATA_WIDTH-1:0]    hrdata_m12,
    input  wire                     hreadyout_m12,
    input  wire                     hresp_m12,
    input  wire                     hexokay_m12,
    output wire                     hsel_m12,
    output wire                     hready_m12,
    output wire [USER_WIDTH-1:0]    hauser_m12,
    output wire [USER_WIDTH-1:0]    hwuser_m12,
    input  wire [USER_WIDTH-1:0]    hruser_m12,

    output wire [ADDR_WIDTH-1:0]    haddr_m13,
    output wire [2:0]               hburst_m13,
    output wire                     hmastlock_m13,
    output wire [6:0]               hprot_m13,
    output wire [2:0]               hsize_m13,
    output wire                     hnonsec_m13,
    output wire                     hexcl_m13,
    output wire [MASTER_WIDTH-1:0]  hmaster_m13,
    output wire [1:0]               htrans_m13,
    output wire [DATA_WIDTH-1:0]    hwdata_m13,
    output wire                     hwrite_m13,
    input  wire [DATA_WIDTH-1:0]    hrdata_m13,
    input  wire                     hreadyout_m13,
    input  wire                     hresp_m13,
    input  wire                     hexokay_m13,
    output wire                     hsel_m13,
    output wire                     hready_m13,
    output wire [USER_WIDTH-1:0]    hauser_m13,
    output wire [USER_WIDTH-1:0]    hwuser_m13,
    input  wire [USER_WIDTH-1:0]    hruser_m13,

    output wire [ADDR_WIDTH-1:0]    haddr_m14,
    output wire [2:0]               hburst_m14,
    output wire                     hmastlock_m14,
    output wire [6:0]               hprot_m14,
    output wire [2:0]               hsize_m14,
    output wire                     hnonsec_m14,
    output wire                     hexcl_m14,
    output wire [MASTER_WIDTH-1:0]  hmaster_m14,
    output wire [1:0]               htrans_m14,
    output wire [DATA_WIDTH-1:0]    hwdata_m14,
    output wire                     hwrite_m14,
    input  wire [DATA_WIDTH-1:0]    hrdata_m14,
    input  wire                     hreadyout_m14,
    input  wire                     hresp_m14,
    input  wire                     hexokay_m14,
    output wire                     hsel_m14,
    output wire                     hready_m14,
    output wire [USER_WIDTH-1:0]    hauser_m14,
    output wire [USER_WIDTH-1:0]    hwuser_m14,
    input  wire [USER_WIDTH-1:0]    hruser_m14,

    output wire [ADDR_WIDTH-1:0]    haddr_m15,
    output wire [2:0]               hburst_m15,
    output wire                     hmastlock_m15,
    output wire [6:0]               hprot_m15,
    output wire [2:0]               hsize_m15,
    output wire                     hnonsec_m15,
    output wire                     hexcl_m15,
    output wire [MASTER_WIDTH-1:0]  hmaster_m15,
    output wire [1:0]               htrans_m15,
    output wire [DATA_WIDTH-1:0]    hwdata_m15,
    output wire                     hwrite_m15,
    input  wire [DATA_WIDTH-1:0]    hrdata_m15,
    input  wire                     hreadyout_m15,
    input  wire                     hresp_m15,
    input  wire                     hexokay_m15,
    output wire                     hsel_m15,
    output wire                     hready_m15,
    output wire [USER_WIDTH-1:0]    hauser_m15,
    output wire [USER_WIDTH-1:0]    hwuser_m15,
    input  wire [USER_WIDTH-1:0]    hruser_m15


  );

  wire [15:0]               portsel;
  reg  [15:0]               reg_hsel_s;

  assign portsel[0] = hsel_s[0] & (PORT0_ENABLE!=0);
  assign portsel[1] = hsel_s[1] & (PORT1_ENABLE!=0);
  assign portsel[2] = hsel_s[2] & (PORT2_ENABLE!=0);
  assign portsel[3] = hsel_s[3] & (PORT3_ENABLE!=0);
  assign portsel[4] = hsel_s[4] & (PORT4_ENABLE!=0);
  assign portsel[5] = hsel_s[5] & (PORT5_ENABLE!=0);
  assign portsel[6] = hsel_s[6] & (PORT6_ENABLE!=0);
  assign portsel[7] = hsel_s[7] & (PORT7_ENABLE!=0);
  assign portsel[8] = hsel_s[8] & (PORT8_ENABLE!=0);
  assign portsel[9] = hsel_s[9] & (PORT9_ENABLE!=0);
  assign portsel[10] = hsel_s[10] & (PORT10_ENABLE!=0);
  assign portsel[11] = hsel_s[11] & (PORT11_ENABLE!=0);
  assign portsel[12] = hsel_s[12] & (PORT12_ENABLE!=0);
  assign portsel[13] = hsel_s[13] & (PORT13_ENABLE!=0);
  assign portsel[14] = hsel_s[14] & (PORT14_ENABLE!=0);
  assign portsel[15] = hsel_s[15] & (PORT15_ENABLE!=0);

  assign hsel_m0 = portsel[0];
  assign hsel_m1 = portsel[1];
  assign hsel_m2 = portsel[2];
  assign hsel_m3 = portsel[3];
  assign hsel_m4 = portsel[4];
  assign hsel_m5 = portsel[5];
  assign hsel_m6 = portsel[6];
  assign hsel_m7 = portsel[7];
  assign hsel_m8 = portsel[8];
  assign hsel_m9 = portsel[9];
  assign hsel_m10 = portsel[10];
  assign hsel_m11 = portsel[11];
  assign hsel_m12 = portsel[12];
  assign hsel_m13 = portsel[13];
  assign hsel_m14 = portsel[14];
  assign hsel_m15 = portsel[15];

  always @(posedge hclk or negedge hresetn)
  begin
    if (!hresetn) begin
      reg_hsel_s      <= 16'b0;
    end else if (hready_s) begin
      reg_hsel_s      <= portsel;
    end
  end

  assign hreadyout_s =
           ((~reg_hsel_s[0]) | hreadyout_m0 | (PORT0_ENABLE==0)) &
           ((~reg_hsel_s[1]) | hreadyout_m1 | (PORT1_ENABLE==0)) &
           ((~reg_hsel_s[2]) | hreadyout_m2 | (PORT2_ENABLE==0)) &
           ((~reg_hsel_s[3]) | hreadyout_m3 | (PORT3_ENABLE==0)) &
           ((~reg_hsel_s[4]) | hreadyout_m4 | (PORT4_ENABLE==0)) &
           ((~reg_hsel_s[5]) | hreadyout_m5 | (PORT5_ENABLE==0)) &
           ((~reg_hsel_s[6]) | hreadyout_m6 | (PORT6_ENABLE==0)) &
           ((~reg_hsel_s[7]) | hreadyout_m7 | (PORT7_ENABLE==0)) &
           ((~reg_hsel_s[8]) | hreadyout_m8 | (PORT8_ENABLE==0)) &
           ((~reg_hsel_s[9]) | hreadyout_m9 | (PORT9_ENABLE==0)) &
           ((~reg_hsel_s[10]) | hreadyout_m10 | (PORT10_ENABLE==0)) &
           ((~reg_hsel_s[11]) | hreadyout_m11 | (PORT11_ENABLE==0)) &
           ((~reg_hsel_s[12]) | hreadyout_m12 | (PORT12_ENABLE==0)) &
           ((~reg_hsel_s[13]) | hreadyout_m13 | (PORT13_ENABLE==0)) &
           ((~reg_hsel_s[14]) | hreadyout_m14 | (PORT14_ENABLE==0)) &
           ((~reg_hsel_s[15]) | hreadyout_m15 | (PORT15_ENABLE==0)) ;

  assign hrdata_s =
           ({DATA_WIDTH{(reg_hsel_s[0] & (PORT0_ENABLE!=0))}} & hrdata_m0) |
           ({DATA_WIDTH{(reg_hsel_s[1] & (PORT1_ENABLE!=0))}} & hrdata_m1) |
           ({DATA_WIDTH{(reg_hsel_s[2] & (PORT2_ENABLE!=0))}} & hrdata_m2) |
           ({DATA_WIDTH{(reg_hsel_s[3] & (PORT3_ENABLE!=0))}} & hrdata_m3) |
           ({DATA_WIDTH{(reg_hsel_s[4] & (PORT4_ENABLE!=0))}} & hrdata_m4) |
           ({DATA_WIDTH{(reg_hsel_s[5] & (PORT5_ENABLE!=0))}} & hrdata_m5) |
           ({DATA_WIDTH{(reg_hsel_s[6] & (PORT6_ENABLE!=0))}} & hrdata_m6) |
           ({DATA_WIDTH{(reg_hsel_s[7] & (PORT7_ENABLE!=0))}} & hrdata_m7) |
           ({DATA_WIDTH{(reg_hsel_s[8] & (PORT8_ENABLE!=0))}} & hrdata_m8) |
           ({DATA_WIDTH{(reg_hsel_s[9] & (PORT9_ENABLE!=0))}} & hrdata_m9) |
           ({DATA_WIDTH{(reg_hsel_s[10] & (PORT10_ENABLE!=0))}} & hrdata_m10) |
           ({DATA_WIDTH{(reg_hsel_s[11] & (PORT11_ENABLE!=0))}} & hrdata_m11) |
           ({DATA_WIDTH{(reg_hsel_s[12] & (PORT12_ENABLE!=0))}} & hrdata_m12) |
           ({DATA_WIDTH{(reg_hsel_s[13] & (PORT13_ENABLE!=0))}} & hrdata_m13) |
           ({DATA_WIDTH{(reg_hsel_s[14] & (PORT14_ENABLE!=0))}} & hrdata_m14) |
           ({DATA_WIDTH{(reg_hsel_s[15] & (PORT15_ENABLE!=0))}} & hrdata_m15) ;

  assign hruser_s =
           ({USER_WIDTH{(reg_hsel_s[0] & (PORT0_ENABLE!=0))}} & hruser_m0) |
           ({USER_WIDTH{(reg_hsel_s[1] & (PORT1_ENABLE!=0))}} & hruser_m1) |
           ({USER_WIDTH{(reg_hsel_s[2] & (PORT2_ENABLE!=0))}} & hruser_m2) |
           ({USER_WIDTH{(reg_hsel_s[3] & (PORT3_ENABLE!=0))}} & hruser_m3) |
           ({USER_WIDTH{(reg_hsel_s[4] & (PORT4_ENABLE!=0))}} & hruser_m4) |
           ({USER_WIDTH{(reg_hsel_s[5] & (PORT5_ENABLE!=0))}} & hruser_m5) |
           ({USER_WIDTH{(reg_hsel_s[6] & (PORT6_ENABLE!=0))}} & hruser_m6) |
           ({USER_WIDTH{(reg_hsel_s[7] & (PORT7_ENABLE!=0))}} & hruser_m7) |
           ({USER_WIDTH{(reg_hsel_s[8] & (PORT8_ENABLE!=0))}} & hruser_m8) |
           ({USER_WIDTH{(reg_hsel_s[9] & (PORT9_ENABLE!=0))}} & hruser_m9) |
           ({USER_WIDTH{(reg_hsel_s[10] & (PORT10_ENABLE!=0))}} & hruser_m10) |
           ({USER_WIDTH{(reg_hsel_s[11] & (PORT11_ENABLE!=0))}} & hruser_m11) |
           ({USER_WIDTH{(reg_hsel_s[12] & (PORT12_ENABLE!=0))}} & hruser_m12) |
           ({USER_WIDTH{(reg_hsel_s[13] & (PORT13_ENABLE!=0))}} & hruser_m13) |
           ({USER_WIDTH{(reg_hsel_s[14] & (PORT14_ENABLE!=0))}} & hruser_m14) |
           ({USER_WIDTH{(reg_hsel_s[15] & (PORT15_ENABLE!=0))}} & hruser_m15) ;

  assign hresp_s =
           (reg_hsel_s[0] & hresp_m0 & (PORT0_ENABLE!=0)) |
           (reg_hsel_s[1] & hresp_m1 & (PORT1_ENABLE!=0)) |
           (reg_hsel_s[2] & hresp_m2 & (PORT2_ENABLE!=0)) |
           (reg_hsel_s[3] & hresp_m3 & (PORT3_ENABLE!=0)) |
           (reg_hsel_s[4] & hresp_m4 & (PORT4_ENABLE!=0)) |
           (reg_hsel_s[5] & hresp_m5 & (PORT5_ENABLE!=0)) |
           (reg_hsel_s[6] & hresp_m6 & (PORT6_ENABLE!=0)) |
           (reg_hsel_s[7] & hresp_m7 & (PORT7_ENABLE!=0)) |
           (reg_hsel_s[8] & hresp_m8 & (PORT8_ENABLE!=0)) |
           (reg_hsel_s[9] & hresp_m9 & (PORT9_ENABLE!=0)) |
           (reg_hsel_s[10] & hresp_m10 & (PORT10_ENABLE!=0)) |
           (reg_hsel_s[11] & hresp_m11 & (PORT11_ENABLE!=0)) |
           (reg_hsel_s[12] & hresp_m12 & (PORT12_ENABLE!=0)) |
           (reg_hsel_s[13] & hresp_m13 & (PORT13_ENABLE!=0)) |
           (reg_hsel_s[14] & hresp_m14 & (PORT14_ENABLE!=0)) |
           (reg_hsel_s[15] & hresp_m15 & (PORT15_ENABLE!=0)) ;

  assign hexokay_s =
           (reg_hsel_s[0] & hexokay_m0 & (PORT0_ENABLE!=0)) |
           (reg_hsel_s[1] & hexokay_m1 & (PORT1_ENABLE!=0)) |
           (reg_hsel_s[2] & hexokay_m2 & (PORT2_ENABLE!=0)) |
           (reg_hsel_s[3] & hexokay_m3 & (PORT3_ENABLE!=0)) |
           (reg_hsel_s[4] & hexokay_m4 & (PORT4_ENABLE!=0)) |
           (reg_hsel_s[5] & hexokay_m5 & (PORT5_ENABLE!=0)) |
           (reg_hsel_s[6] & hexokay_m6 & (PORT6_ENABLE!=0)) |
           (reg_hsel_s[7] & hexokay_m7 & (PORT7_ENABLE!=0)) |
           (reg_hsel_s[8] & hexokay_m8 & (PORT8_ENABLE!=0)) |
           (reg_hsel_s[9] & hexokay_m9 & (PORT9_ENABLE!=0)) |
           (reg_hsel_s[10] & hexokay_m10 & (PORT10_ENABLE!=0)) |
           (reg_hsel_s[11] & hexokay_m11 & (PORT11_ENABLE!=0)) |
           (reg_hsel_s[12] & hexokay_m12 & (PORT12_ENABLE!=0)) |
           (reg_hsel_s[13] & hexokay_m13 & (PORT13_ENABLE!=0)) |
           (reg_hsel_s[14] & hexokay_m14 & (PORT14_ENABLE!=0)) |
           (reg_hsel_s[15] & hexokay_m15 & (PORT15_ENABLE!=0)) ;

  assign htrans_m0    = htrans_s;
  assign htrans_m1    = htrans_s;
  assign htrans_m2    = htrans_s;
  assign htrans_m3    = htrans_s;
  assign htrans_m4    = htrans_s;
  assign htrans_m5    = htrans_s;
  assign htrans_m6    = htrans_s;
  assign htrans_m7    = htrans_s;
  assign htrans_m8    = htrans_s;
  assign htrans_m9    = htrans_s;
  assign htrans_m10   = htrans_s;
  assign htrans_m11   = htrans_s;
  assign htrans_m12   = htrans_s;
  assign htrans_m13   = htrans_s;
  assign htrans_m14   = htrans_s;
  assign htrans_m15   = htrans_s;

  assign hready_m0    = hready_s;
  assign hready_m1    = hready_s;
  assign hready_m2    = hready_s;
  assign hready_m3    = hready_s;
  assign hready_m4    = hready_s;
  assign hready_m5    = hready_s;
  assign hready_m6    = hready_s;
  assign hready_m7    = hready_s;
  assign hready_m8    = hready_s;
  assign hready_m9    = hready_s;
  assign hready_m10   = hready_s;
  assign hready_m11   = hready_s;
  assign hready_m12   = hready_s;
  assign hready_m13   = hready_s;
  assign hready_m14   = hready_s;
  assign hready_m15   = hready_s;

  assign haddr_m0     = haddr_s;
  assign haddr_m1     = haddr_s;
  assign haddr_m2     = haddr_s;
  assign haddr_m3     = haddr_s;
  assign haddr_m4     = haddr_s;
  assign haddr_m5     = haddr_s;
  assign haddr_m6     = haddr_s;
  assign haddr_m7     = haddr_s;
  assign haddr_m8     = haddr_s;
  assign haddr_m9     = haddr_s;
  assign haddr_m10    = haddr_s;
  assign haddr_m11    = haddr_s;
  assign haddr_m12    = haddr_s;
  assign haddr_m13    = haddr_s;
  assign haddr_m14    = haddr_s;
  assign haddr_m15    = haddr_s;

  assign hburst_m0    = hburst_s;
  assign hburst_m1    = hburst_s;
  assign hburst_m2    = hburst_s;
  assign hburst_m3    = hburst_s;
  assign hburst_m4    = hburst_s;
  assign hburst_m5    = hburst_s;
  assign hburst_m6    = hburst_s;
  assign hburst_m7    = hburst_s;
  assign hburst_m8    = hburst_s;
  assign hburst_m9    = hburst_s;
  assign hburst_m10   = hburst_s;
  assign hburst_m11   = hburst_s;
  assign hburst_m12   = hburst_s;
  assign hburst_m13   = hburst_s;
  assign hburst_m14   = hburst_s;
  assign hburst_m15   = hburst_s;

  assign hmastlock_m0 = hmastlock_s;
  assign hmastlock_m1 = hmastlock_s;
  assign hmastlock_m2 = hmastlock_s;
  assign hmastlock_m3 = hmastlock_s;
  assign hmastlock_m4 = hmastlock_s;
  assign hmastlock_m5 = hmastlock_s;
  assign hmastlock_m6 = hmastlock_s;
  assign hmastlock_m7 = hmastlock_s;
  assign hmastlock_m8 = hmastlock_s;
  assign hmastlock_m9 = hmastlock_s;
  assign hmastlock_m10 = hmastlock_s;
  assign hmastlock_m11 = hmastlock_s;
  assign hmastlock_m12 = hmastlock_s;
  assign hmastlock_m13 = hmastlock_s;
  assign hmastlock_m14 = hmastlock_s;
  assign hmastlock_m15 = hmastlock_s;

  assign hprot_m0     = hprot_s;
  assign hprot_m1     = hprot_s;
  assign hprot_m2     = hprot_s;
  assign hprot_m3     = hprot_s;
  assign hprot_m4     = hprot_s;
  assign hprot_m5     = hprot_s;
  assign hprot_m6     = hprot_s;
  assign hprot_m7     = hprot_s;
  assign hprot_m8     = hprot_s;
  assign hprot_m9     = hprot_s;
  assign hprot_m10    = hprot_s;
  assign hprot_m11    = hprot_s;
  assign hprot_m12    = hprot_s;
  assign hprot_m13    = hprot_s;
  assign hprot_m14    = hprot_s;
  assign hprot_m15    = hprot_s;

  assign hsize_m0     = hsize_s;
  assign hsize_m1     = hsize_s;
  assign hsize_m2     = hsize_s;
  assign hsize_m3     = hsize_s;
  assign hsize_m4     = hsize_s;
  assign hsize_m5     = hsize_s;
  assign hsize_m6     = hsize_s;
  assign hsize_m7     = hsize_s;
  assign hsize_m8     = hsize_s;
  assign hsize_m9     = hsize_s;
  assign hsize_m10    = hsize_s;
  assign hsize_m11    = hsize_s;
  assign hsize_m12    = hsize_s;
  assign hsize_m13    = hsize_s;
  assign hsize_m14    = hsize_s;
  assign hsize_m15    = hsize_s;

  assign hnonsec_m0   = hnonsec_s;
  assign hnonsec_m1   = hnonsec_s;
  assign hnonsec_m2   = hnonsec_s;
  assign hnonsec_m3   = hnonsec_s;
  assign hnonsec_m4   = hnonsec_s;
  assign hnonsec_m5   = hnonsec_s;
  assign hnonsec_m6   = hnonsec_s;
  assign hnonsec_m7   = hnonsec_s;
  assign hnonsec_m8   = hnonsec_s;
  assign hnonsec_m9   = hnonsec_s;
  assign hnonsec_m10  = hnonsec_s;
  assign hnonsec_m11  = hnonsec_s;
  assign hnonsec_m12  = hnonsec_s;
  assign hnonsec_m13  = hnonsec_s;
  assign hnonsec_m14  = hnonsec_s;
  assign hnonsec_m15  = hnonsec_s;

  assign hexcl_m0     = hexcl_s;
  assign hexcl_m1     = hexcl_s;
  assign hexcl_m2     = hexcl_s;
  assign hexcl_m3     = hexcl_s;
  assign hexcl_m4     = hexcl_s;
  assign hexcl_m5     = hexcl_s;
  assign hexcl_m6     = hexcl_s;
  assign hexcl_m7     = hexcl_s;
  assign hexcl_m8     = hexcl_s;
  assign hexcl_m9     = hexcl_s;
  assign hexcl_m10    = hexcl_s;
  assign hexcl_m11    = hexcl_s;
  assign hexcl_m12    = hexcl_s;
  assign hexcl_m13    = hexcl_s;
  assign hexcl_m14    = hexcl_s;
  assign hexcl_m15    = hexcl_s;

  assign hmaster_m0   = hmaster_s;
  assign hmaster_m1   = hmaster_s;
  assign hmaster_m2   = hmaster_s;
  assign hmaster_m3   = hmaster_s;
  assign hmaster_m4   = hmaster_s;
  assign hmaster_m5   = hmaster_s;
  assign hmaster_m6   = hmaster_s;
  assign hmaster_m7   = hmaster_s;
  assign hmaster_m8   = hmaster_s;
  assign hmaster_m9   = hmaster_s;
  assign hmaster_m10  = hmaster_s;
  assign hmaster_m11  = hmaster_s;
  assign hmaster_m12  = hmaster_s;
  assign hmaster_m13  = hmaster_s;
  assign hmaster_m14  = hmaster_s;
  assign hmaster_m15  = hmaster_s;

  assign hwdata_m0    = hwdata_s;
  assign hwdata_m1    = hwdata_s;
  assign hwdata_m2    = hwdata_s;
  assign hwdata_m3    = hwdata_s;
  assign hwdata_m4    = hwdata_s;
  assign hwdata_m5    = hwdata_s;
  assign hwdata_m6    = hwdata_s;
  assign hwdata_m7    = hwdata_s;
  assign hwdata_m8    = hwdata_s;
  assign hwdata_m9    = hwdata_s;
  assign hwdata_m10   = hwdata_s;
  assign hwdata_m11   = hwdata_s;
  assign hwdata_m12   = hwdata_s;
  assign hwdata_m13   = hwdata_s;
  assign hwdata_m14   = hwdata_s;
  assign hwdata_m15   = hwdata_s;

  assign hwrite_m0    = hwrite_s;
  assign hwrite_m1    = hwrite_s;
  assign hwrite_m2    = hwrite_s;
  assign hwrite_m3    = hwrite_s;
  assign hwrite_m4    = hwrite_s;
  assign hwrite_m5    = hwrite_s;
  assign hwrite_m6    = hwrite_s;
  assign hwrite_m7    = hwrite_s;
  assign hwrite_m8    = hwrite_s;
  assign hwrite_m9    = hwrite_s;
  assign hwrite_m10   = hwrite_s;
  assign hwrite_m11   = hwrite_s;
  assign hwrite_m12   = hwrite_s;
  assign hwrite_m13   = hwrite_s;
  assign hwrite_m14   = hwrite_s;
  assign hwrite_m15   = hwrite_s;

  assign hauser_m0    = hauser_s;
  assign hauser_m1    = hauser_s;
  assign hauser_m2    = hauser_s;
  assign hauser_m3    = hauser_s;
  assign hauser_m4    = hauser_s;
  assign hauser_m5    = hauser_s;
  assign hauser_m6    = hauser_s;
  assign hauser_m7    = hauser_s;
  assign hauser_m8    = hauser_s;
  assign hauser_m9    = hauser_s;
  assign hauser_m10   = hauser_s;
  assign hauser_m11   = hauser_s;
  assign hauser_m12   = hauser_s;
  assign hauser_m13   = hauser_s;
  assign hauser_m14   = hauser_s;
  assign hauser_m15   = hauser_s;

  assign hwuser_m0    = hwuser_s;
  assign hwuser_m1    = hwuser_s;
  assign hwuser_m2    = hwuser_s;
  assign hwuser_m3    = hwuser_s;
  assign hwuser_m4    = hwuser_s;
  assign hwuser_m5    = hwuser_s;
  assign hwuser_m6    = hwuser_s;
  assign hwuser_m7    = hwuser_s;
  assign hwuser_m8    = hwuser_s;
  assign hwuser_m9    = hwuser_s;
  assign hwuser_m10   = hwuser_s;
  assign hwuser_m11   = hwuser_s;
  assign hwuser_m12   = hwuser_s;
  assign hwuser_m13   = hwuser_s;
  assign hwuser_m14   = hwuser_s;
  assign hwuser_m15   = hwuser_s;


endmodule
