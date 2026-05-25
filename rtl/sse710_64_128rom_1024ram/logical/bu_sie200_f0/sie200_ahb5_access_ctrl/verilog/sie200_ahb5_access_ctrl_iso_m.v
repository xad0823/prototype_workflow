//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Nov 9 08:45:00 2016 +0000
//
//      Revision            : 6357d98
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//----------------------------------------------------------------------------

module sie200_ahb5_access_ctrl_iso_m #(
  parameter                       ADDR_WIDTH    = 32,
  parameter                       DATA_WIDTH    = 32,
  parameter                       MASTER_WIDTH  =  4,
  parameter                       USER_WIDTH    =  1
)
(
  input  wire                     hclk_m,
  input  wire                     hresetn_m,

  input  wire                     hsel_i,
  input  wire                     hnonsec_i,
  input  wire [ADDR_WIDTH-1:0]    haddr_i,
  input  wire [1:0]               htrans_i,
  input  wire [2:0]               hsize_i,
  input  wire                     hwrite_i,
  input  wire                     hready_i,
  input  wire [6:0]               hprot_i,
  input  wire [2:0]               hburst_i,
  input  wire                     hmastlock_i,
  input  wire [DATA_WIDTH-1:0]    hwdata_i,
  input  wire                     hexcl_i,
  input  wire [MASTER_WIDTH-1:0]  hmaster_i,
  output wire                     hreadyout_i,
  output wire                     hresp_i,
  output wire [DATA_WIDTH-1:0]    hrdata_i,
  output wire                     hexokay_i,
  input  wire [USER_WIDTH-1:0]    hauser_i,
  input  wire [USER_WIDTH-1:0]    hwuser_i,
  output wire [USER_WIDTH-1:0]    hruser_i,


  output wire                     hsel_m,
  output wire                     hnonsec_m,
  output wire [ADDR_WIDTH-1:0]    haddr_m,
  output wire [1:0]               htrans_m,
  output wire [2:0]               hsize_m,
  output wire                     hwrite_m,
  output wire                     hready_m,
  output wire [6:0]               hprot_m,
  output wire [2:0]               hburst_m,
  output wire                     hmastlock_m,
  output wire [DATA_WIDTH-1:0]    hwdata_m,
  output wire                     hexcl_m,
  output wire [MASTER_WIDTH-1:0]  hmaster_m,
  input  wire                     hreadyout_m,
  input  wire                     hresp_m,
  input  wire [DATA_WIDTH-1:0]    hrdata_m,
  input  wire                     hexokay_m,
  output wire [USER_WIDTH-1:0]    hauser_m,
  output wire [USER_WIDTH-1:0]    hwuser_m,
  input  wire [USER_WIDTH-1:0]    hruser_m,

  input  wire                     brg_pwr_req_m,
  output wire                     brg_pwr_ack_m
);


wire [1:0] unused = {hclk_m, hresetn_m};


sie200_or   u_mux_iso_hreadyout   (.in_a( brg_pwr_req_m), .in_b(hreadyout_m), .out_y(hreadyout_i));
sie200_and  u_mux_iso_hresp       (.in_a(~brg_pwr_req_m), .in_b(hresp_m),     .out_y(hresp_i));
sie200_and  u_mux_iso_hexokay     (.in_a(~brg_pwr_req_m), .in_b(hexokay_m),   .out_y(hexokay_i));
sie200_and #(.DATA_WIDTH(DATA_WIDTH)) u_mux_iso_hrdata   (.in_a(~{DATA_WIDTH{brg_pwr_req_m}}), .in_b(hrdata_m), .out_y(hrdata_i));
sie200_and #(.DATA_WIDTH(USER_WIDTH)) u_mux_iso_hruser   (.in_a(~{USER_WIDTH{brg_pwr_req_m}}), .in_b(hruser_m), .out_y(hruser_i));

assign brg_pwr_ack_m  = brg_pwr_req_m;

assign hsel_m         = hsel_i;
assign hnonsec_m      = hnonsec_i;
assign haddr_m        = haddr_i;
assign htrans_m       = htrans_i;
assign hsize_m        = hsize_i;
assign hwrite_m       = hwrite_i;
assign hready_m       = hready_i;
assign hprot_m        = hprot_i;
assign hburst_m       = hburst_i;
assign hmastlock_m    = hmastlock_i;
assign hwdata_m       = hwdata_i;
assign hexcl_m        = hexcl_i;
assign hmaster_m      = hmaster_i;
assign hauser_m       = hauser_i;
assign hwuser_m       = hwuser_i;


endmodule

