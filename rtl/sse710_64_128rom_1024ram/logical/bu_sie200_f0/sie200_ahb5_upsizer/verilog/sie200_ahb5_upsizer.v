//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Tue Aug 9 08:12:07 2016 +0100
//
//      Revision            : 8ac0ed4
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_upsizer
  #(
  parameter                             DATA_WIDTH   = 32,
  parameter                             ADDR_WIDTH   = 32,
  parameter                             MASTER_WIDTH = 4,
  parameter                             USER_WIDTH   = 1,
  parameter                             ENDIANNESS   = 0
  )

 (input  wire                           hclk,
  input  wire                           hresetn,

  input  wire                           hsel_s,
  input  wire                           hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]          haddr_s,
  input  wire [1:0]                     htrans_s,
  input  wire [2:0]                     hsize_s,
  input  wire                           hwrite_s,
  input  wire                           hready_s,
  input  wire [6:0]                     hprot_s,
  input  wire [2:0]                     hburst_s,
  input  wire                           hmastlock_s,
  input  wire [DATA_WIDTH-1:0]          hwdata_s,
  input  wire                           hexcl_s,
  input  wire [MASTER_WIDTH-1:0]        hmaster_s,

  output wire                           hreadyout_s,
  output wire                           hresp_s,
  output wire [DATA_WIDTH-1:0]          hrdata_s,
  output wire                           hexokay_s,

  input  wire [USER_WIDTH-1:0]          hauser_s,
  input  wire [USER_WIDTH-1:0]          hwuser_s,
  output wire [USER_WIDTH-1:0]          hruser_s,

  output wire                           hsel_m,
  output wire                           hnonsec_m,
  output wire [ADDR_WIDTH-1:0]          haddr_m,
  output wire [1:0]                     htrans_m,
  output wire [2:0]                     hsize_m,
  output wire                           hwrite_m,
  output wire                           hready_m,
  output wire [6:0]                     hprot_m,
  output wire [2:0]                     hburst_m,
  output wire                           hmastlock_m,
  output wire [2*DATA_WIDTH-1:0]        hwdata_m,
  output wire                           hexcl_m,
  output wire [MASTER_WIDTH-1:0]        hmaster_m,

  input  wire                           hreadyout_m,
  input  wire                           hresp_m,
  input  wire [2*DATA_WIDTH-1:0]        hrdata_m,
  input  wire                           hexokay_m,

  output wire [USER_WIDTH-1:0]          hauser_m,
  output wire [USER_WIDTH-1:0]          hwuser_m,
  input  wire [USER_WIDTH-1:0]          hruser_m

  );

  wire                                  hrdata_sel;
  reg                                   hrdata_sel_reg;


  generate
    if(ENDIANNESS == 2) begin: WORD_BIG_ENDIAN
      assign hrdata_sel = (DATA_WIDTH == 512) ?  haddr_s[6] :
                          (DATA_WIDTH == 256) ?  haddr_s[5] :
                          (DATA_WIDTH == 128) ?  haddr_s[4] :
                          (DATA_WIDTH == 64 ) ?  haddr_s[3] :
                          (DATA_WIDTH == 32 ) ?  haddr_s[2] :
                          (DATA_WIDTH == 16 ) ? ~haddr_s[1] :
                                                ~haddr_s[0] ;
    end
    else begin : LITTLE_OR_BYTE_BIG_ENDIAN
      assign hrdata_sel = (DATA_WIDTH == 512) ?  haddr_s[6] :
                          (DATA_WIDTH == 256) ?  haddr_s[5] :
                          (DATA_WIDTH == 128) ?  haddr_s[4] :
                          (DATA_WIDTH == 64 ) ?  haddr_s[3] :
                          (DATA_WIDTH == 32 ) ?  haddr_s[2] :
                          (DATA_WIDTH == 16 ) ?  haddr_s[1] :
                                                 haddr_s[0] ;
    end
  endgenerate


  always @(posedge hclk or negedge hresetn)
    if (~hresetn)
      hrdata_sel_reg <= 1'b0;
    else if (hready_s & hsel_s & htrans_s[1])
      hrdata_sel_reg <= hrdata_sel;



  assign hreadyout_s = hreadyout_m;
  assign hresp_s     = hresp_m;
  assign hrdata_s    = hrdata_sel_reg ? hrdata_m[2*DATA_WIDTH-1:DATA_WIDTH] :
                                        hrdata_m[  DATA_WIDTH-1:         0] ;
  assign hexokay_s   = hexokay_m;
  assign hruser_s    = hruser_m;

  assign hsel_m      = hsel_s;
  assign hnonsec_m   = hnonsec_s;
  assign haddr_m     = haddr_s;
  assign htrans_m    = htrans_s;
  assign hready_m    = hready_s;
  assign hsize_m     = hsize_s;
  assign hwrite_m    = hwrite_s;
  assign hprot_m     = hprot_s;
  assign hburst_m    = hburst_s;
  assign hmastlock_m = hmastlock_s;
  assign hwdata_m    = {hwdata_s,hwdata_s};
  assign hexcl_m     = hexcl_s;
  assign hmaster_m   = hmaster_s;
  assign hauser_m    = hauser_s;
  assign hwuser_m    = hwuser_s;


endmodule
