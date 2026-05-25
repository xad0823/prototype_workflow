//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------



`include "nic400_asib_slave_if1_defs_secenc_f1.v"

module nic400_asib_slave_if1_secenc_f1
 (
  
    haddr_slave_if1_s,
    htrans_slave_if1_s,
    hwrite_slave_if1_s,
    hsize_slave_if1_s,
    hburst_slave_if1_s,
    hprot_slave_if1_s,
    hwdata_slave_if1_s,
    hselx_slave_if1_s,
    hrdata_slave_if1_s,
    hready_slave_if1_s,
    hreadyout_slave_if1_s,
    hresp_slave_if1_s,
    hauser_slave_if1_s,


    awid_slave_if1_m,
    awaddr_slave_if1_m,
    awlen_slave_if1_m,
    awsize_slave_if1_m,
    awburst_slave_if1_m,
    awlock_slave_if1_m,
    awcache_slave_if1_m,
    awprot_slave_if1_m,
    awvalid_slave_if1_m,
    awvalid_vect_slave_if1_m,
    awready_slave_if1_m,

    wdata_slave_if1_m,
    wstrb_slave_if1_m,
    wlast_slave_if1_m,
    wvalid_slave_if1_m,
    wready_slave_if1_m,

    bid_slave_if1_m,
    bresp_slave_if1_m,
    bvalid_slave_if1_m,
    bready_slave_if1_m,

    arid_slave_if1_m,
    araddr_slave_if1_m,
    arlen_slave_if1_m,
    arsize_slave_if1_m,
    arburst_slave_if1_m,
    arlock_slave_if1_m,
    arcache_slave_if1_m,
    arprot_slave_if1_m,
    arvalid_slave_if1_m,
    arvalid_vect_slave_if1_m,
    arready_slave_if1_m,

    rid_slave_if1_m,
    rdata_slave_if1_m,
    rresp_slave_if1_m,
    rlast_slave_if1_m,
    rvalid_slave_if1_m,
    rready_slave_if1_m,

    awuser_slave_if1_m,
    aruser_slave_if1_m,

    awqv_slave_if1_m,
    arqv_slave_if1_m,

    aclk,
    aresetn

  );




  
  input   [31:0]      haddr_slave_if1_s;             
  input   [1:0]       htrans_slave_if1_s;            
  input               hwrite_slave_if1_s;            
  input   [2:0]       hsize_slave_if1_s;             
  input   [2:0]       hburst_slave_if1_s;            
  input   [3:0]       hprot_slave_if1_s;             
  input   [31:0]      hwdata_slave_if1_s;            
  input               hselx_slave_if1_s;             
  output  [31:0]      hrdata_slave_if1_s;            
  input               hready_slave_if1_s;            
  output              hreadyout_slave_if1_s;         
  output              hresp_slave_if1_s;             
  input   [1:0]       hauser_slave_if1_s;            



  output              awid_slave_if1_m;              
  output  [31:0]      awaddr_slave_if1_m;            
  output  [7:0]       awlen_slave_if1_m;             
  output  [2:0]       awsize_slave_if1_m;            
  output  [1:0]       awburst_slave_if1_m;           
  output              awlock_slave_if1_m;            
  output  [3:0]       awcache_slave_if1_m;           
  output  [2:0]       awprot_slave_if1_m;            
  output              awvalid_slave_if1_m;           
  output  [2:0]       awvalid_vect_slave_if1_m;      
  input               awready_slave_if1_m;           

  output  [31:0]      wdata_slave_if1_m;             
  output  [3:0]       wstrb_slave_if1_m;             
  output              wlast_slave_if1_m;             
  output              wvalid_slave_if1_m;            
  input               wready_slave_if1_m;            

  input               bid_slave_if1_m;               
  input   [1:0]       bresp_slave_if1_m;             
  input               bvalid_slave_if1_m;            
  output              bready_slave_if1_m;            

  output              arid_slave_if1_m;              
  output  [31:0]      araddr_slave_if1_m;            
  output  [7:0]       arlen_slave_if1_m;             
  output  [2:0]       arsize_slave_if1_m;            
  output  [1:0]       arburst_slave_if1_m;           
  output              arlock_slave_if1_m;            
  output  [3:0]       arcache_slave_if1_m;           
  output  [2:0]       arprot_slave_if1_m;            
  output              arvalid_slave_if1_m;           
  output  [2:0]       arvalid_vect_slave_if1_m;      
  input               arready_slave_if1_m;           

  input               rid_slave_if1_m;               
  input   [31:0]      rdata_slave_if1_m;             
  input   [1:0]       rresp_slave_if1_m;             
  input               rlast_slave_if1_m;             
  input               rvalid_slave_if1_m;            
  output              rready_slave_if1_m;            

  output  [1:0]       awuser_slave_if1_m;            
  output  [1:0]       aruser_slave_if1_m;            

  output  [3:0]       awqv_slave_if1_m;              
  output  [3:0]       arqv_slave_if1_m;              

  input               aclk;                          
  input               aresetn;                       



  


  wire           w_slave_port_dst_valid;
  wire           w_slave_port_dst_ready;
  wire           w_slave_port_src_valid;
  wire           w_slave_port_src_ready;

  wire [36:0]    w_slave_port_src_data;     
  wire [36:0]    w_slave_port_dst_data;     

  wire [58:0]    a_slave_port_src_data;     
  wire [58:0]    a_slave_port_dst_data;     

  wire [35:0]    d_slave_port_src_data;     
  wire [35:0]    d_slave_port_dst_data;     

  wire                security61;
  wire                security63;
  wire [2:0]          awvalid_vector;            
  wire [2:0]          arvalid_vector;            
  wire                rvalid_maskcntl;
  wire                bvalid_master;
  wire                bready_master;

  wire                mask_w;
  wire                mask_r;


  wire                wr_cnt_empty;

  wire  [1:0]          htrans_int;
  wire                 hready_int;

  wire                r_override;          
  wire                w_override;          

  wire [3:0]          acache_int_slave_if1_s;
  wire [1:0]          ahb_alock;
  wire                awrite_slave_if1_s;
  wire [31:0]         aaddr_slave_if1_s;
  wire [7:0]             alen_slave_if1_s;
  wire [2:0]          asize_slave_if1_s;
  wire [1:0]          aburst_slave_if1_s;
  wire                   alock_slave_if1_s;
  wire [3:0]          acache_slave_if1_s;
  wire [2:0]          aprot_slave_if1_s;
  wire [1:0]          auser_slave_if1_s;
  wire [2:0]          avalid_vect_slave_if1_s;
  wire                avalid_slave_if1_s;
  wire                aready_slave_if1_s;

  wire                dbnr_slave_if1_s;
  wire [31:0]         ddata_slave_if1_s;
  wire [1:0]          dresp_slave_if1_s;
  wire                dlast_slave_if1_s;
  wire                dvalid_slave_if1_s;
  wire                dready_slave_if1_s;

  wire [31:0]         wdata_slave_if1_s;
  wire [3:0]          wstrb_slave_if1_s;
  wire                wlast_slave_if1_s;
  wire                wvalid_slave_if1_s;
  wire                wready_slave_if1_s;

  wire                awrite_slave_if1_m;
  wire [31:0]         aaddr_slave_if1_m;
  wire [7:0]             alen_slave_if1_m;
  wire [2:0]          asize_slave_if1_m;
  wire [1:0]          aburst_slave_if1_m;
  wire                   alock_slave_if1_m;
  wire [3:0]          acache_slave_if1_m;
  wire [2:0]          aprot_slave_if1_m;
  wire [1:0]          auser_slave_if1_m;
  wire [2:0]          avalid_vect_slave_if1_m;
  wire                avalid_slave_if1_m;
  wire                aready_slave_if1_m;

  wire                dbnr_slave_if1_m;
  wire [31:0]         ddata_slave_if1_m;
  wire [1:0]          dresp_slave_if1_m;
  wire                dlast_slave_if1_m;
  wire                dvalid_slave_if1_m;
  wire                dready_slave_if1_m;

  wire                arready_int_m;
  wire                awready_int_m;
  wire                arvalid_int_m;
  wire                awvalid_int_m;

  wire [31:0]         awaddr_int_m;
  wire [31:0]         araddr_int_m;
  wire [31:0]         aaddr_int_s;
  wire [31:0]         aaddr_int_m;
  wire                asib_slave_if1_siid;
  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;






  assign asib_slave_if1_siid = 1'b1;





  assign awid_slave_if1_m = {asib_slave_if1_siid};
  assign arid_slave_if1_m = {asib_slave_if1_siid};


    assign r_override    = 1'b0;
    assign w_override    = 1'b0;
    assign hrdata_slave_if1_s = ddata_slave_if1_s;

    assign htrans_int = htrans_slave_if1_s;
    assign hreadyout_slave_if1_s = hready_int;

nic400_asib_slave_if1_ahb_secenc_f1 u_asib_slave_if1_ahb
    (
        .aclk               (aclk),
        .aresetn            (aresetn),

        .r_override         (r_override),
        .w_override         (w_override),

        .hreadyout          (hready_int),
        .hready             (hready_slave_if1_s),
        .hselx              (hselx_slave_if1_s),
        .hresp              (hresp_slave_if1_s),
        .haddr              (haddr_slave_if1_s),
        .htrans             (htrans_int),
        .hwrite             (hwrite_slave_if1_s),
        .hsize              (hsize_slave_if1_s),
        .hburst             (hburst_slave_if1_s),
        .hprot              (hprot_slave_if1_s),
        .hwdata             (hwdata_slave_if1_s),
        .hauser             (hauser_slave_if1_s),

        .awrite             (awrite_slave_if1_s),
        .aaddr              (aaddr_int_s),
        .alen               (alen_slave_if1_s[3:0]),
        .asize              (asize_slave_if1_s),
        .aburst             (aburst_slave_if1_s),
        .alock              (ahb_alock),
        .acache             (acache_int_slave_if1_s),
        .aprot              (aprot_slave_if1_s),
        .auser              (auser_slave_if1_s),
        .avalid             (avalid_slave_if1_s),
        .aready             (aready_slave_if1_s),

        .dbnr               (dbnr_slave_if1_s),
        .dresp              (dresp_slave_if1_s),
        .dlast              (dlast_slave_if1_s),
        .dvalid             (dvalid_slave_if1_s),
        .dready             (dready_slave_if1_s),

        .wdata              (wdata_slave_if1_s),
        .wstrb              (wstrb_slave_if1_s),
        .wlast              (wlast_slave_if1_s),
        .wvalid             (wvalid_slave_if1_s),
        .wready             (wready_slave_if1_s)
    );

 
  assign alen_slave_if1_s[7:4] = 4'b0000;
  assign alock_slave_if1_s     = ahb_alock[0];

    nic400_asib_slave_if1_itb_to_axi_secenc_f1 u_asib_slave_if1_itb_to_axi
    (

        .awrite             (awrite_slave_if1_m),
        .aaddr              (aaddr_int_m),
        .alen               (alen_slave_if1_m),
        .asize              (asize_slave_if1_m),
        .aburst             (aburst_slave_if1_m),
        .alock              (alock_slave_if1_m),
        .acache             (acache_slave_if1_m),
        .aprot              (aprot_slave_if1_m),
        .auser              (auser_slave_if1_m),
        .avalid_vect        (avalid_vect_slave_if1_m),
        .avalid             (avalid_slave_if1_m),
        .aready             (aready_slave_if1_m),

        .dbnr               (dbnr_slave_if1_m),
        .ddata              (ddata_slave_if1_m),
        .dresp              (dresp_slave_if1_m),
        .dlast              (dlast_slave_if1_m),
        .dvalid             (dvalid_slave_if1_m),
        .dready             (dready_slave_if1_m),



        .awaddr             (awaddr_int_m),
        .awlen              (awlen_slave_if1_m),
        .awsize             (awsize_slave_if1_m),
        .awburst            (awburst_slave_if1_m),
        .awlock             (awlock_slave_if1_m),
        .awcache            (awcache_slave_if1_m),
        .awprot             (awprot_slave_if1_m),
        .awuser             (awuser_slave_if1_m),
        .awvalid_vect       (awvalid_vector),
        .awvalid            (awvalid_int_m),
        .awready            (awready_int_m),

        .bresp              (bresp_slave_if1_m),
        .bvalid             (bvalid_master),
        .bready             (bready_master),

        .araddr             (araddr_int_m),
        .arlen              (arlen_slave_if1_m),
        .arsize             (arsize_slave_if1_m),
        .arburst            (arburst_slave_if1_m),
        .arlock             (arlock_slave_if1_m),
        .arcache            (arcache_slave_if1_m),
        .arprot             (arprot_slave_if1_m),
        .aruser             (aruser_slave_if1_m),
        .arvalid_vect       (arvalid_vector),
        .arvalid            (arvalid_int_m),
        .arready            (arready_int_m),

        .rdata              (rdata_slave_if1_m),
        .rresp              (rresp_slave_if1_m),
        .rlast              (rlast_slave_if1_m),
        .rvalid             (rvalid_slave_if1_m),
        .rready             (rready_slave_if1_m),


        .aclk               (aclk),
        .aresetn            (aresetn)

    );
  assign security61 = 1'b1;
  assign security63 = 1'b1;
  assign aaddr_slave_if1_s = aaddr_int_s;
  assign aaddr_int_m = aaddr_slave_if1_m;
  assign awaddr_slave_if1_m = awaddr_int_m;
  assign araddr_slave_if1_m = araddr_int_m;


  nic400_asib_slave_if1_decode_secenc_f1 u_a_add_decode
  (
    .addr_s                         (aaddr_int_s),
    .security61                      (security61),
    .security63                      (security63),
    .aprot                          (aprot_slave_if1_s[1]),
    .acache_in                      (acache_int_slave_if1_s),
    .acache_out                     (acache_slave_if1_s),
    .avalid_int                     (avalid_vect_slave_if1_s)
    );

nic400_asib_slave_if1_rd_ss_cdas_secenc_f1 u_asib_slave_if1_rd_ss_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vector),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .resp_valid             (rvalid_slave_if1_m),
    .resp_last              (rlast_slave_if1_m),
    .resp_ready             (rready_slave_if1_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );


nic400_asib_slave_if1_wr_ss_cdas_secenc_f1 u_asib_slave_if1_wr_ss_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vector),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .wvalid                 (wvalid_slave_if1_s),
    .wready                 (wready_slave_if1_s),
    .wlast                  (wlast_slave_if1_s),
    .resp_valid             (bvalid_slave_if1_m),
    .resp_ready             (bready_slave_if1_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );





  nic400_asib_slave_if1_maskcntl_secenc_f1 u_asib_slave_if1_maskcntl (
      .awvalid_m    (awvalid_int_m),
      .arvalid_m    (arvalid_int_m),
      .awready_m    (awready_int_m),
      .arready_m    (arready_int_m),
      .bvalid_m     (bvalid_slave_if1_m),
      .bready_m     (bready_slave_if1_m),
      .rvalid_m     (rvalid_maskcntl),
      .rready_m     (rready_slave_if1_m),

      .wr_cnt_empty (wr_cnt_empty),
      .mask_w       (mask_w),
      .mask_r       (mask_r),
      .aw_qos_m     (awqv_slave_if1_m),
      .ar_qos_m     (arqv_slave_if1_m),
      .aclk         (aclk),
      .aresetn      (aresetn)
      );

  assign rvalid_maskcntl = rvalid_slave_if1_m & rlast_slave_if1_m;


  assign awvalid_slave_if1_m = (awvalid_int_m & cds_aw_enable & !mask_w);
  assign awready_int_m = (awready_slave_if1_m & cds_aw_enable & !mask_w);

  assign arvalid_slave_if1_m = (arvalid_int_m & cds_ar_enable & !mask_r);
  assign arready_int_m = (arready_slave_if1_m & cds_ar_enable & !mask_r); 

  assign bvalid_master = (bvalid_slave_if1_m & ~wr_cnt_empty);
  assign bready_slave_if1_m = (bready_master & ~wr_cnt_empty);



    
  assign awvalid_vect_slave_if1_m = ({3{awvalid_slave_if1_m}} & awvalid_vector);
  assign arvalid_vect_slave_if1_m = ({3{arvalid_slave_if1_m}} & arvalid_vector);
    

  assign w_slave_port_src_data = {wdata_slave_if1_s,
          wstrb_slave_if1_s,
          wlast_slave_if1_s};

  assign {wdata_slave_if1_m,
          wstrb_slave_if1_m,
          wlast_slave_if1_m} = w_slave_port_dst_data;



  assign wvalid_slave_if1_m = w_slave_port_dst_valid;
  assign w_slave_port_dst_ready = wready_slave_if1_m;

  assign w_slave_port_src_valid = wvalid_slave_if1_s;
  assign wready_slave_if1_s = w_slave_port_src_ready;


  assign a_slave_port_src_data = {
          aaddr_slave_if1_s,
          alen_slave_if1_s,
          asize_slave_if1_s,
          aburst_slave_if1_s,
          alock_slave_if1_s,
          acache_slave_if1_s,
          auser_slave_if1_s,
          aprot_slave_if1_s,
          awrite_slave_if1_s,
          avalid_vect_slave_if1_s};

  assign {
          aaddr_slave_if1_m,
          alen_slave_if1_m,
          asize_slave_if1_m,
          aburst_slave_if1_m,
          alock_slave_if1_m,
          acache_slave_if1_m,
          auser_slave_if1_m,
          aprot_slave_if1_m,
          awrite_slave_if1_m,
          avalid_vect_slave_if1_m} = a_slave_port_dst_data;


  assign a_slave_port_dst_data = a_slave_port_src_data;

  assign avalid_slave_if1_m = avalid_slave_if1_s;
  assign aready_slave_if1_s = aready_slave_if1_m;



  assign d_slave_port_src_data = {
          ddata_slave_if1_m,
          dresp_slave_if1_m,
          dlast_slave_if1_m,
          dbnr_slave_if1_m};

  assign {
          ddata_slave_if1_s,
          dresp_slave_if1_s,
          dlast_slave_if1_s,
          dbnr_slave_if1_s} = d_slave_port_dst_data;


  assign d_slave_port_dst_data = d_slave_port_src_data;

  assign dvalid_slave_if1_s = dvalid_slave_if1_m;
  assign dready_slave_if1_m = dready_slave_if1_s;



  nic400_asib_slave_if1_chan_slice_secenc_f1
    #(
       `RS_REV_REG,  
       37  
     )
  u_w_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (w_slave_port_src_valid),
     .src_data              (w_slave_port_src_data),
     .dst_ready             (w_slave_port_dst_ready),

     .src_ready             (w_slave_port_src_ready),
     .dst_data              (w_slave_port_dst_data),
     .dst_valid             (w_slave_port_dst_valid)
     );







`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"



  assert_zero_one_hot
    #(`OVL_FATAL, 3, `OVL_ASSERT,
      "Error: Valid vector not one-hot zero")
      ovl_avalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( avalid_slave_if1_s & avalid_vect_slave_if1_s )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: Valid vector not one-hot during AVALID")
      ovl_avalid_vect_one_hot_when_avalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( avalid_slave_if1_s & ~|avalid_vect_slave_if1_s )
      );

  assert_never
    #(`OVL_ERROR, `OVL_ASSERT,
      "AHB lock is enabled with AXI4 destination - locks are not supported")
    ovl_ahb_lock_enabled
    (
      .clk       (aclk),
      .reset_n   (aresetn),
      .test_expr (ahb_alock[1])
    );


`endif


endmodule

`include "nic400_asib_slave_if1_undefs_secenc_f1.v"



