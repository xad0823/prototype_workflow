//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2011,2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Fri Mar 17 13:32:16 2017 +0000
//
//      Revision            : 1102dbd
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_fileread_master  #(

  parameter  DATA_WIDTH         =  32,
  parameter  MASTER_WIDTH       =  4,
  parameter  MASTER_VALUE       =  1,
  parameter  USER_WIDTH         =  1,
  parameter  STIMULUS_FILE_NAME =  "filestim.m3d",
  parameter  MESSAGE_TAG        =  "FileReader:",
  parameter  STIM_ARRAY_SIZE    =  5000)
 (
  input  wire                    hclk,
  input  wire                    hresetn,

  output wire [1:0]              htrans,
  output wire [2:0]              hburst,
  output wire [6:0]              hprot,
  output wire [2:0]              hsize,
  output wire                    hwrite,
  output wire                    hmastlock,
  output wire [31:0]             haddr,
  output wire                    hnonsec,
  output wire                    hexcl,
  output wire [MASTER_WIDTH-1:0] hmaster,
  output wire [DATA_WIDTH-1:0]   hwdata,
  output wire [USER_WIDTH-1:0]   hauser,
  output wire [USER_WIDTH-1:0]   hwuser,

  input  wire                    hready,
  input  wire                    hresp,
  input  wire                    hexokay,
  input  wire [DATA_WIDTH-1:0]   hrdata,
  input  wire [USER_WIDTH-1:0]   hruser,

  output wire [31:0]             linenum);

  wire   [63:0]  hrdata_core;
  wire   [31:0]  haddr_core;
  wire   [63:0]  hwdata_core;
  wire   [2:0]   hresp_core;


  sie200_ahb5_fileread_core
    #(.MASTER_WIDTH(MASTER_WIDTH),
      .MASTER_VALUE(MASTER_VALUE),
      .USER_WIDTH(USER_WIDTH),
      .STIMULUS_FILE_NAME(STIMULUS_FILE_NAME),
      .MESSAGE_TAG(MESSAGE_TAG),
      .STIMULUS_ARRAY_SIZE(STIM_ARRAY_SIZE))
    u_ahb_fileread_core (

    .hclk           (hclk),
    .hresetn        (hresetn),

    .haddr          (haddr_core),
    .hnonsec        (hnonsec),
    .htrans         (htrans),
    .hsize          (hsize),
    .hwrite         (hwrite),
    .hprot          (hprot),
    .hburst         (hburst),
    .hmastlock      (hmastlock),
    .hwdata         (hwdata_core),
    .hexcl          (hexcl),
    .hmaster        (hmaster),
    .hauser         (hauser),
    .hwuser         (hwuser),
    .hunalign       (),
    .hbstrb         (),
    .linenum        (linenum),

    .hready         (hready),
    .hresp          (hresp_core),
    .hrdata         (hrdata_core),
    .hexokay        (hexokay),
    .hruser         (hruser)
    );

generate
  if (DATA_WIDTH == 32) begin: FUNNEL_PRESENT
    sie200_ahb5_fileread_funnel u_ahb_fileread_funnel (

      .hclk           (hclk),
      .hresetn        (hresetn),

      .hready_s        (hready),
      .haddr2_s        (haddr_core[2]),
      .hwdata_s        (hwdata_core),
      .hrdata_s        (hrdata_core),

      .hwdata_m        (hwdata),
      .hrdata_m        (hrdata)
    );
  end
  else begin : FUNNEL_NOT_PRESENT
    assign hwdata      = hwdata_core;
    assign hrdata_core = hrdata;
  end
endgenerate

  assign haddr          = haddr_core;
  assign hresp_core     = {2'b00, hresp};

endmodule

