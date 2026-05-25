//-----------------------------------------------------------------------------
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
//      Checked In          : Mon May 29 14:00:28 2017 +0100
//
//      Revision            : 166463d
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_m3_m4_ahb5_adapter #(


    parameter MSC_PRESENT = 1,
    parameter CODE_MUXED  = 0

)
(



  input  wire                     hclk            ,
  input  wire                     hresetn         ,


  input  wire             [31:0]  haddri_s        ,
  input  wire                     hwritei_s       ,
  input  wire             [31:0]  hwdatai_s       ,
  output wire             [31:0]  hrdatai_s       ,

  output wire                     hreadyi_s       ,
  output wire              [1:0]  hrespi_s        ,
  input  wire              [3:0]  hproti_s        ,

  input  wire              [1:0]  htransi_s       ,
  input  wire              [2:0]  hsizei_s        ,
  input  wire              [2:0]  hbursti_s       ,

  input  wire              [1:0]  memattri_s      ,

  output wire             [26:0]  idauaddr_i      ,
  input  wire                     idauns_i        ,
  input  wire                     idaunchk_i      ,

  output wire                     msc_irq_i       ,
  input  wire                     msc_irq_clear_i ,
  input  wire                     msc_irq_enable_i,

  input  wire             [31:0]  haddrd_s        ,
  input  wire                     hwrited_s       ,
  input  wire             [31:0]  hwdatad_s       ,
  output wire             [31:0]  hrdatad_s       ,

  output wire                     hreadyd_s       ,
  output wire              [1:0]  hrespd_s        ,
  input  wire              [3:0]  hprotd_s        ,

  input  wire              [1:0]  htransd_s       ,
  input  wire              [2:0]  hsized_s        ,
  input  wire              [2:0]  hburstd_s       ,
  input  wire              [1:0]  hmasterd_s      ,

  input  wire              [1:0]  memattrd_s      ,
  input  wire                     exreqd_s        ,
  output wire                     exrespd_s       ,

  output wire             [26:0]  idauaddr_d      ,
  input  wire                     idauns_d        ,
  input  wire                     idaunchk_d      ,

  output wire                     msc_irq_d       ,
  input  wire                     msc_irq_clear_d ,
  input  wire                     msc_irq_enable_d,

  input  wire             [31:0]  haddrs_s        ,
  input  wire                     hwrites_s       ,
  input  wire             [31:0]  hwdatas_s       ,
  output wire             [31:0]  hrdatas_s       ,

  output wire                     hreadys_s       ,
  output wire              [1:0]  hresps_s        ,
  input  wire                     hmastlocks_s    ,
  input  wire              [3:0]  hprots_s        ,

  input  wire              [1:0]  htranss_s       ,
  input  wire              [2:0]  hsizes_s        ,
  input  wire              [2:0]  hbursts_s       ,
  input  wire              [1:0]  hmasters_s      ,

  input  wire              [1:0]  memattrs_s      ,
  input  wire                     exreqs_s        ,
  output wire                     exresps_s       ,

  output wire             [26:0]  idauaddr_s      ,
  input  wire                     idauns_s        ,
  input  wire                     idaunchk_s      ,

  output wire                     msc_irq_s       ,
  input  wire                     msc_irq_clear_s ,
  input  wire                     msc_irq_enable_s,

  input  wire                     cfg_sec_resp    ,
  input  wire                     cfg_nonsec      ,

  output wire             [31:0]  haddri_m        ,
  output wire                     hwritei_m       ,
  output wire             [31:0]  hwdatai_m       ,
  input  wire             [31:0]  hrdatai_m       ,

  input  wire                     hreadyi_m       ,
  input  wire                     hrespi_m        ,
  output wire              [6:0]  hproti_m        ,

  output wire              [1:0]  htransi_m       ,
  output wire              [2:0]  hsizei_m        ,
  output wire              [2:0]  hbursti_m       ,
  output wire                     hnonseci_m      ,

  output wire             [31:0]  haddrd_m        ,
  output wire                     hwrited_m       ,
  output wire             [31:0]  hwdatad_m       ,
  input  wire             [31:0]  hrdatad_m       ,

  input  wire                     hreadyd_m       ,
  input  wire                     hrespd_m        ,
  output wire              [6:0]  hprotd_m        ,
  output wire                     hexcld_m        ,
  input  wire                     hexokayd_m      ,

  output wire              [1:0]  htransd_m       ,
  output wire              [2:0]  hsized_m        ,
  output wire              [2:0]  hburstd_m       ,
  output wire              [1:0]  hmasterd_m      ,
  output wire                     hnonsecd_m      ,

  output wire             [31:0]  haddrs_m        ,
  output wire                     hwrites_m       ,
  output wire             [31:0]  hwdatas_m       ,
  input  wire             [31:0]  hrdatas_m       ,

  input  wire                     hreadys_m       ,
  input  wire                     hresps_m        ,
  output wire                     hmastlocks_m    ,
  output wire              [6:0]  hprots_m        ,
  output wire                     hexcls_m        ,
  input  wire                     hexokays_m      ,

  output wire              [1:0]  htranss_m       ,
  output wire              [2:0]  hsizes_m        ,
  output wire              [2:0]  hbursts_m       ,
  output wire              [1:0]  hmasters_m      ,
  output wire                     hnonsecs_m
);


wire [6:0] hprot_d;
wire       hexcld_s;
wire       hexokayd_s;



generate
  if (CODE_MUXED == 0) begin: I_AHB_PRESENT

    wire [6:0] hprot_i;
    assign hprot_i = {memattri_s, hproti_s[3], hproti_s};

    if(MSC_PRESENT == 1) begin: I_MSC_PRESENT

      sie200_ahb5_master_sec #(
        .DATA_WIDTH     (32),
        .MASTER_WIDTH   (1) ,
        .USER_WIDTH     (1)
      )u_sie200_ahb5_master_sec_i (
        .hclk           (hclk)            ,
        .hresetn        (hresetn)         ,

        .haddr_s        (haddri_s)        ,
        .hwrite_s       (hwritei_s)       ,
        .hwdata_s       (hwdatai_s)       ,
        .hrdata_s       (hrdatai_s)       ,

        .hready_s       (hreadyi_s)       ,
        .hresp_s        (hrespi_s[0])     ,
        .hmastlock_s    (1'b0)            ,
        .hprot_s        (hprot_i)         ,

        .htrans_s       (htransi_s)       ,
        .hsize_s        (hsizei_s)        ,
        .hburst_s       (hbursti_s)       ,
        .hmaster_s      (1'b0)            ,

        .hexcl_s        (1'b0)            ,
        .hexokay_s      ()                ,

        .hauser_s       (1'b0)            ,
        .hwuser_s       (1'b0)            ,
        .hruser_s       ()                ,

        .cfg_nonsec     (cfg_nonsec)      ,

        .haddr_m        (haddri_m)        ,
        .hwrite_m       (hwritei_m)       ,
        .hwdata_m       (hwdatai_m)       ,
        .hrdata_m       (hrdatai_m)       ,

        .hready_m       (hreadyi_m)       ,
        .hresp_m        (hrespi_m)        ,
        .hmastlock_m    ()                ,

        .htrans_m       (htransi_m)       ,
        .hsize_m        (hsizei_m)        ,
        .hburst_m       (hbursti_m)       ,
        .hmaster_m      ()                ,

        .hexcl_m        ()                ,
        .hexokay_m      ()                ,

        .hprot_m        (hproti_m)        ,
        .hnonsec_m      (hnonseci_m)      ,

        .hauser_m       ()                ,
        .hwuser_m       ()                ,
        .hruser_m       (1'b0)            ,

        .idauaddr       (idauaddr_i)      ,
        .idauns         (idauns_i)        ,
        .idaunchk       (idaunchk_i)      ,

        .cfg_sec_resp   (cfg_sec_resp)    ,
        .msc_irq        (msc_irq_i)       ,
        .msc_irq_clear  (msc_irq_clear_i) ,
        .msc_irq_enable (msc_irq_enable_i)
      );

      assign hrespi_s[1] = 1'b0;

    end else begin: I_MSC_NOT_PRESENT

      assign haddri_m    = haddri_s;
      assign hwritei_m   = hwritei_s;
      assign hwdatai_m   = hwdatai_s;
      assign hrdatai_s   = hrdatai_m;
      assign hreadyi_s   = hreadyi_m;
      assign hrespi_s    = {1'b0, hrespi_m};
      assign htransi_m   = htransi_s;
      assign hsizei_m    = hsizei_s;
      assign hbursti_m   = hbursti_s;
      assign hproti_m    = hprot_i;
      assign hnonseci_m  = 1'b1;
      assign idauaddr_i  = {27{1'b0}};
      assign msc_irq_i   = 1'b0;

    end

  end else begin: I_AHB_NOT_PRESENT

    assign haddri_m     = {32{1'b0}};
    assign hwritei_m    = 1'b0;
    assign hrdatai_s    = {32{1'b0}};
    assign hwdatai_m    = {32{1'b0}};
    assign hreadyi_s    = 1'b1;
    assign hrespi_s     = {2{1'b0}};
    assign htransi_m    = {2{1'b0}};
    assign hsizei_m     = {3{1'b0}};
    assign hbursti_m    = {3{1'b0}};
    assign hproti_m     = {7{1'b0}};
    assign hnonseci_m   = 1'b1;
    assign idauaddr_i   = {27{1'b0}};
    assign msc_irq_i    = 1'b0;

  end

endgenerate


assign hprot_d = {memattrd_s, hprotd_s[3], hprotd_s};

sie200_m3_m4_ahb5_adapter_ex_conv u_sie200_m3_m4_ahb5_adapter_ex_conv_d (
  .hclk            (hclk),
  .hresetn         (hresetn),

  .exreq           (exreqd_s),
  .exresp          (exrespd_s),

  .hready          (hreadyd_s),
  .hresp           (hrespd_s[0]),
  .hexcl           (hexcld_s),
  .hexokay         (hexokayd_s)
);

generate
  if(MSC_PRESENT == 1) begin: D_MSC_PRESENT

    sie200_ahb5_master_sec #(
      .DATA_WIDTH     (32),
      .MASTER_WIDTH   (2) ,
      .USER_WIDTH     (1)
    )u_sie200_ahb5_master_sec_d (
      .hclk           (hclk)            ,
      .hresetn        (hresetn)         ,

      .haddr_s        (haddrd_s)        ,
      .hwrite_s       (hwrited_s)       ,
      .hwdata_s       (hwdatad_s)       ,
      .hrdata_s       (hrdatad_s)       ,

      .hready_s       (hreadyd_s)       ,
      .hresp_s        (hrespd_s[0])     ,
      .hmastlock_s    (1'b0)            ,
      .hprot_s        (hprot_d)         ,

      .htrans_s       (htransd_s)       ,
      .hsize_s        (hsized_s)        ,
      .hburst_s       (hburstd_s)       ,
      .hmaster_s      (hmasterd_s)      ,

      .hexcl_s        (hexcld_s)        ,
      .hexokay_s      (hexokayd_s)      ,

      .hauser_s       (1'b0)            ,
      .hwuser_s       (1'b0)            ,
      .hruser_s       ()                ,

      .cfg_nonsec     (cfg_nonsec)      ,

      .haddr_m        (haddrd_m)        ,
      .hwrite_m       (hwrited_m)       ,
      .hwdata_m       (hwdatad_m)       ,
      .hrdata_m       (hrdatad_m)       ,

      .hready_m       (hreadyd_m)       ,
      .hresp_m        (hrespd_m)        ,
      .hmastlock_m    ()                ,

      .htrans_m       (htransd_m)       ,
      .hsize_m        (hsized_m)        ,
      .hburst_m       (hburstd_m)       ,
      .hmaster_m      (hmasterd_m)      ,

      .hexcl_m        (hexcld_m)        ,
      .hexokay_m      (hexokayd_m)      ,

      .hprot_m        (hprotd_m)        ,
      .hnonsec_m      (hnonsecd_m)      ,

      .hauser_m       ()                ,
      .hwuser_m       ()                ,
      .hruser_m       (1'b0)            ,

      .idauaddr       (idauaddr_d)      ,
      .idauns         (idauns_d)        ,
      .idaunchk       (idaunchk_d)      ,

      .cfg_sec_resp   (cfg_sec_resp)    ,
      .msc_irq        (msc_irq_d)       ,
      .msc_irq_clear  (msc_irq_clear_d) ,
      .msc_irq_enable (msc_irq_enable_d)
    );

    assign hrespd_s[1] = 1'b0;

  end else begin: D_MSC_NOT_PRESENT

    assign haddrd_m    = haddrd_s;
    assign hwrited_m   = hwrited_s;
    assign hrdatad_s   = hrdatad_m;
    assign hwdatad_m   = hwdatad_s;
    assign hreadyd_s   = hreadyd_m;
    assign hrespd_s    = {1'b0, hrespd_m};
    assign htransd_m   = htransd_s;
    assign hsized_m    = hsized_s;
    assign hburstd_m   = hburstd_s;
    assign hprotd_m    = hprot_d;
    assign hmasterd_m  = hmasterd_s;
    assign hexcld_m    = hexcld_s;
    assign hexokayd_s  = hexokayd_m;
    assign hnonsecd_m  = 1'b1;
    assign idauaddr_d  = {27{1'b0}};
    assign msc_irq_d   = 1'b0;

  end
endgenerate


wire [6:0] hprot_s;
wire       hexcls_s;
wire       hexokays_s;

assign hprot_s = {memattrs_s, hprots_s[3], hprots_s};

sie200_m3_m4_ahb5_adapter_ex_conv u_sie200_m3_m4_ahb5_adapter_ex_conv_s (
  .hclk            (hclk),
  .hresetn         (hresetn),

  .exreq           (exreqs_s),
  .exresp          (exresps_s),

  .hready          (hreadys_s),
  .hresp           (hresps_s[0]),
  .hexcl           (hexcls_s),
  .hexokay         (hexokays_s)
);

generate
  if(MSC_PRESENT == 1) begin: S_MSC_PRESENT
    sie200_ahb5_master_sec #(
      .DATA_WIDTH     (32),
      .MASTER_WIDTH   (2) ,
      .USER_WIDTH     (1)
    )u_sie200_ahb5_master_sec_s (
      .hclk           (hclk)            ,
      .hresetn        (hresetn)         ,

      .haddr_s        (haddrs_s)        ,
      .hwrite_s       (hwrites_s)       ,
      .hwdata_s       (hwdatas_s)       ,
      .hrdata_s       (hrdatas_s)       ,

      .hready_s       (hreadys_s)       ,
      .hresp_s        (hresps_s[0])     ,
      .hmastlock_s    (hmastlocks_s)    ,
      .hprot_s        (hprot_s)         ,

      .htrans_s       (htranss_s)       ,
      .hsize_s        (hsizes_s)        ,
      .hburst_s       (hbursts_s)       ,
      .hmaster_s      (hmasters_s)      ,

      .hexcl_s        (hexcls_s)        ,
      .hexokay_s      (hexokays_s)      ,

      .hauser_s       (1'b0)            ,
      .hwuser_s       (1'b0)            ,
      .hruser_s       ()                ,

      .cfg_nonsec     (cfg_nonsec)      ,

      .haddr_m        (haddrs_m)        ,
      .hwrite_m       (hwrites_m)       ,
      .hwdata_m       (hwdatas_m)       ,
      .hrdata_m       (hrdatas_m)       ,

      .hready_m       (hreadys_m)       ,
      .hresp_m        (hresps_m)        ,
      .hmastlock_m    (hmastlocks_m)    ,

      .htrans_m       (htranss_m)       ,
      .hsize_m        (hsizes_m)        ,
      .hburst_m       (hbursts_m)       ,
      .hmaster_m      (hmasters_m)      ,

      .hexcl_m        (hexcls_m)        ,
      .hexokay_m      (hexokays_m)      ,

      .hprot_m        (hprots_m)        ,
      .hnonsec_m      (hnonsecs_m)      ,

      .hauser_m       ()                ,
      .hwuser_m       ()                ,
      .hruser_m       (1'b0)            ,

      .idauaddr       (idauaddr_s)      ,
      .idauns         (idauns_s)        ,
      .idaunchk       (idaunchk_s)      ,

      .cfg_sec_resp   (cfg_sec_resp)    ,
      .msc_irq        (msc_irq_s)       ,
      .msc_irq_clear  (msc_irq_clear_s) ,
      .msc_irq_enable (msc_irq_enable_s)
    );

    assign hresps_s[1] = 1'b0;

  end else begin: S_MSC_NOT_PRESENT

    assign haddrs_m     = haddrs_s;
    assign hwrites_m    = hwrites_s;
    assign hrdatas_s    = hrdatas_m;
    assign hwdatas_m    = hwdatas_s;
    assign hreadys_s    = hreadys_m;
    assign hresps_s     = {1'b0, hresps_m};
    assign htranss_m    = htranss_s;
    assign hsizes_m     = hsizes_s;
    assign hbursts_m    = hbursts_s;
    assign hprots_m     = hprot_s;
    assign hmasters_m   = hmasters_s;
    assign hexcls_m     = hexcls_s;
    assign hexokays_s   = hexokays_m;
    assign hmastlocks_m = hmastlocks_s;
    assign hnonsecs_m   = 1'b1;
    assign idauaddr_s   = {27{1'b0}};
    assign msc_irq_s    = 1'b0;

  end
endgenerate

endmodule
