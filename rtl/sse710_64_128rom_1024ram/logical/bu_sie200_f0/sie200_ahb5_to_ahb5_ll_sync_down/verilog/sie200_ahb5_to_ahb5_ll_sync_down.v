//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Feb 8 17:30:08 2017 +0100
//
//      Revision            : f7f5ee3
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_ll_sync_down #(

 parameter ADDR_WIDTH    = 32,
 parameter DATA_WIDTH    = 32,
 parameter MASTER_WIDTH  = 4,
 parameter USER_WIDTH    = 1,
 parameter BURST         = 0,
 parameter WRITE_BUFFER  = 0
)
(
  input  wire                    hclk,
  input  wire                    hresetn,
  input  wire                    hclk_en,

  input  wire                    hsel_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hmastlock_s,
  input  wire                    hexcl_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire   [2:0]            hburst_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  output wire                    ahb5_ll_sync_down_irq,
  input  wire                    ahb5_ll_sync_down_irq_clear
  );


wire                    hsels_i;
wire                    hnonsecs_i;
wire [ADDR_WIDTH-1:0]   haddrs_i;
wire [1:0]              htranss_i;
wire [2:0]              hsizes_i;
wire                    hwrites_i;
wire                    hreadys_i;
wire [6:0]              hprots_i;
wire [2:0]              hbursts_i;
wire                    hmastlocks_i;
wire                    hexcls_i;
wire [DATA_WIDTH-1:0]   hwdatas_i;
wire [MASTER_WIDTH-1:0] hmasters_i;
wire [USER_WIDTH-1:0]   hausers_i;
wire [USER_WIDTH-1:0]   hwusers_i;

wire [DATA_WIDTH-1:0]   hrdatas_i;
wire                    hreadyouts_i;
wire                    hresps_i;
wire                    hexokays_i;
wire [USER_WIDTH-1:0]   hrusers_i;




sie200_ahb5_to_ahb5_ll_sync_down_core # (
    .ADDR_WIDTH   (ADDR_WIDTH  ),
    .DATA_WIDTH   (DATA_WIDTH  ),
    .MASTER_WIDTH (MASTER_WIDTH),
    .USER_WIDTH   (USER_WIDTH  ),
    .BURST        (BURST       ))
  u_core_s(
    .hclk         (hclk        ),
    .hresetn      (hresetn     ),
    .hclk_en      (hclk_en     ),
    .hsel_s       (hsels_i     ),
    .hnonsec_s    (hnonsecs_i  ),
    .haddr_s      (haddrs_i    ),
    .htrans_s     (htranss_i   ),
    .hsize_s      (hsizes_i    ),
    .hwrite_s     (hwrites_i   ),
    .hready_s     (hreadys_i   ),
    .hprot_s      (hprots_i    ),
    .hburst_s     (hbursts_i   ),
    .hmastlock_s  (hmastlocks_i),
    .hexcl_s      (hexcls_i    ),
    .hwdata_s     (hwdatas_i   ),
    .hmaster_s    (hmasters_i  ),
    .hauser_s     (hausers_i   ),
    .hwuser_s     (hwusers_i   ),
    .hrdata_s     (hrdatas_i   ),
    .hreadyout_s  (hreadyouts_i),
    .hresp_s      (hresps_i    ),
    .hexokay_s    (hexokays_i  ),
    .hruser_s     (hrusers_i   ),
    .hnonsec_m    (hnonsec_m   ),
    .haddr_m      (haddr_m     ),
    .htrans_m     (htrans_m    ),
    .hsize_m      (hsize_m     ),
    .hwrite_m     (hwrite_m    ),
    .hprot_m      (hprot_m     ),
    .hburst_m     (hburst_m    ),
    .hmastlock_m  (hmastlock_m ),
    .hwdata_m     (hwdata_m    ),
    .hexcl_m      (hexcl_m     ),
    .hmaster_m    (hmaster_m   ),
    .hauser_m     (hauser_m    ),
    .hwuser_m     (hwuser_m    ),
    .hrdata_m     (hrdata_m    ),
    .hready_m     (hready_m    ),
    .hresp_m      (hresp_m     ),
    .hexokay_m    (hexokay_m   ),
    .hruser_m     (hruser_m    )
);


generate
  if (WRITE_BUFFER == 1) begin: gen_wb_support

    sie200_ahb5_ll_write_buffer # (
        .AW               (ADDR_WIDTH  ),
        .DW               (DATA_WIDTH  ),
        .MW               (MASTER_WIDTH),
        .UW               (USER_WIDTH  ))
      u_wb(
        .hclk             (hclk        ),
        .hresetn          (hresetn     ),
        .hclk_en          (1'b1        ),
        .hsel_s           (hsel_s      ),
        .hnonsec_s        (hnonsec_s   ),
        .haddr_s          (haddr_s     ),
        .htrans_s         (htrans_s    ),
        .hsize_s          (hsize_s     ),
        .hwrite_s         (hwrite_s    ),
        .hready_s         (hready_s    ),
        .hprot_s          (hprot_s     ),
        .hmaster_s        (hmaster_s   ),
        .hmastlock_s      (hmastlock_s ),
        .hwdata_s         (hwdata_s    ),
        .hburst_s         (hburst_s    ),
        .hexcl_s          (hexcl_s     ),
        .hauser_s         (hauser_s    ),
        .hwuser_s         (hwuser_s    ),
        .hreadyout_s      (hreadyout_s ),
        .hresp_s          (hresp_s     ),
        .hexokay_s        (hexokay_s   ),
        .hrdata_s         (hrdata_s    ),
        .hruser_s         (hruser_s    ),
        .hsel_m           (hsels_i     ),
        .hnonsec_m        (hnonsecs_i  ),
        .haddr_m          (haddrs_i    ),
        .htrans_m         (htranss_i   ),
        .hsize_m          (hsizes_i    ),
        .hwrite_m         (hwrites_i   ),
        .hready_m         (hreadys_i   ),
        .hprot_m          (hprots_i    ),
        .hmaster_m        (hmasters_i  ),
        .hmastlock_m      (hmastlocks_i),
        .hwdata_m         (hwdatas_i   ),
        .hburst_m         (hbursts_i   ),
        .hexcl_m          (hexcls_i    ),
        .hauser_m         (hausers_i   ),
        .hwuser_m         (hwusers_i   ),
        .hreadyout_m      (hreadyouts_i),
        .hresp_m          (hresps_i    ),
        .hexokay_m        (hexokays_i  ),
        .hrdata_m         (hrdatas_i   ),
        .hruser_m         (hrusers_i   ),
        .bwerr_clear      (ahb5_ll_sync_down_irq_clear),
        .bwerr            (ahb5_ll_sync_down_irq      )
    );

  end
  else begin: gen_no_wb_support
    assign hsels_i       = hsel_s;
    assign hnonsecs_i    = hnonsec_s;
    assign haddrs_i      = haddr_s;
    assign htranss_i     = htrans_s;
    assign hsizes_i      = hsize_s;
    assign hwrites_i     = hwrite_s;
    assign hreadys_i     = hready_s;
    assign hprots_i      = hprot_s;
    assign hmasters_i    = hmaster_s;
    assign hmastlocks_i  = hmastlock_s;
    assign hwdatas_i     = hwdata_s;
    assign hbursts_i     = hburst_s;
    assign hexcls_i      = hexcl_s;
    assign hausers_i     = hauser_s;
    assign hwusers_i     = hwuser_s;
    assign hreadyout_s   = hreadyouts_i;
    assign hresp_s       = hresps_i;
    assign hexokay_s     = hexokays_i;
    assign hrdata_s      = hrdatas_i;
    assign hruser_s      = hrusers_i;

    assign ahb5_ll_sync_down_irq = 1'b0;
  end
endgenerate

endmodule






















