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



`include "nic400_asib_sysperi_axis_defs_sse710_sys_apb.v"

module nic400_asib_sysperi_axis_sse710_sys_apb
 (
  

    awid_sysperi_axis_s,
    awaddr_sysperi_axis_s,
    awlen_sysperi_axis_s,
    awsize_sysperi_axis_s,
    awburst_sysperi_axis_s,
    awlock_sysperi_axis_s,
    awcache_sysperi_axis_s,
    awprot_sysperi_axis_s,
    awvalid_sysperi_axis_s,
    awready_sysperi_axis_s,

    wdata_sysperi_axis_s,
    wstrb_sysperi_axis_s,
    wlast_sysperi_axis_s,
    wvalid_sysperi_axis_s,
    wready_sysperi_axis_s,

    bid_sysperi_axis_s,
    bresp_sysperi_axis_s,
    bvalid_sysperi_axis_s,
    bready_sysperi_axis_s,

    arid_sysperi_axis_s,
    araddr_sysperi_axis_s,
    arlen_sysperi_axis_s,
    arsize_sysperi_axis_s,
    arburst_sysperi_axis_s,
    arlock_sysperi_axis_s,
    arcache_sysperi_axis_s,
    arprot_sysperi_axis_s,
    arvalid_sysperi_axis_s,
    arready_sysperi_axis_s,

    rid_sysperi_axis_s,
    rdata_sysperi_axis_s,
    rresp_sysperi_axis_s,
    rlast_sysperi_axis_s,
    rvalid_sysperi_axis_s,
    rready_sysperi_axis_s,

    awuser_sysperi_axis_s,
    aruser_sysperi_axis_s,

    awqv_sysperi_axis_s,
    arqv_sysperi_axis_s,


    awid_sysperi_axis_m,
    awaddr_sysperi_axis_m,
    awlen_sysperi_axis_m,
    awsize_sysperi_axis_m,
    awburst_sysperi_axis_m,
    awlock_sysperi_axis_m,
    awcache_sysperi_axis_m,
    awprot_sysperi_axis_m,
    awvalid_sysperi_axis_m,
    awvalid_vect_sysperi_axis_m,
    awregion_sysperi_axis_m,
    awready_sysperi_axis_m,

    wdata_sysperi_axis_m,
    wstrb_sysperi_axis_m,
    wlast_sysperi_axis_m,
    wvalid_sysperi_axis_m,
    wready_sysperi_axis_m,

    bid_sysperi_axis_m,
    bresp_sysperi_axis_m,
    bvalid_sysperi_axis_m,
    bready_sysperi_axis_m,

    arid_sysperi_axis_m,
    araddr_sysperi_axis_m,
    arlen_sysperi_axis_m,
    arsize_sysperi_axis_m,
    arburst_sysperi_axis_m,
    arlock_sysperi_axis_m,
    arcache_sysperi_axis_m,
    arprot_sysperi_axis_m,
    arvalid_sysperi_axis_m,
    arvalid_vect_sysperi_axis_m,
    arregion_sysperi_axis_m,
    arready_sysperi_axis_m,

    rid_sysperi_axis_m,
    rdata_sysperi_axis_m,
    rresp_sysperi_axis_m,
    rlast_sysperi_axis_m,
    rvalid_sysperi_axis_m,
    rready_sysperi_axis_m,

    awuser_sysperi_axis_m,
    aruser_sysperi_axis_m,

    awqv_sysperi_axis_m,
    arqv_sysperi_axis_m,

    sysperi_axis_cactive,

    sysperi_axis_cactive_wakeup,

    sysperi_axis_port_enable,

    aclk,
    aresetn

  );




  


  input   [11:0]      awid_sysperi_axis_s;              
  input   [31:0]      awaddr_sysperi_axis_s;            
  input   [7:0]       awlen_sysperi_axis_s;             
  input   [2:0]       awsize_sysperi_axis_s;            
  input   [1:0]       awburst_sysperi_axis_s;           
  input               awlock_sysperi_axis_s;            
  input   [3:0]       awcache_sysperi_axis_s;           
  input   [2:0]       awprot_sysperi_axis_s;            
  input               awvalid_sysperi_axis_s;           
  output              awready_sysperi_axis_s;           

  input   [31:0]      wdata_sysperi_axis_s;             
  input   [3:0]       wstrb_sysperi_axis_s;             
  input               wlast_sysperi_axis_s;             
  input               wvalid_sysperi_axis_s;            
  output              wready_sysperi_axis_s;            

  output  [11:0]      bid_sysperi_axis_s;               
  output  [1:0]       bresp_sysperi_axis_s;             
  output              bvalid_sysperi_axis_s;            
  input               bready_sysperi_axis_s;            

  input   [11:0]      arid_sysperi_axis_s;              
  input   [31:0]      araddr_sysperi_axis_s;            
  input   [7:0]       arlen_sysperi_axis_s;             
  input   [2:0]       arsize_sysperi_axis_s;            
  input   [1:0]       arburst_sysperi_axis_s;           
  input               arlock_sysperi_axis_s;            
  input   [3:0]       arcache_sysperi_axis_s;           
  input   [2:0]       arprot_sysperi_axis_s;            
  input               arvalid_sysperi_axis_s;           
  output              arready_sysperi_axis_s;           

  output  [11:0]      rid_sysperi_axis_s;               
  output  [31:0]      rdata_sysperi_axis_s;             
  output  [1:0]       rresp_sysperi_axis_s;             
  output              rlast_sysperi_axis_s;             
  output              rvalid_sysperi_axis_s;            
  input               rready_sysperi_axis_s;            

  input   [9:0]       awuser_sysperi_axis_s;            
  input   [9:0]       aruser_sysperi_axis_s;            

  input   [3:0]       awqv_sysperi_axis_s;              
  input   [3:0]       arqv_sysperi_axis_s;              



  output  [11:0]      awid_sysperi_axis_m;              
  output  [31:0]      awaddr_sysperi_axis_m;            
  output  [7:0]       awlen_sysperi_axis_m;             
  output  [2:0]       awsize_sysperi_axis_m;            
  output  [1:0]       awburst_sysperi_axis_m;           
  output              awlock_sysperi_axis_m;            
  output  [3:0]       awcache_sysperi_axis_m;           
  output  [2:0]       awprot_sysperi_axis_m;            
  output              awvalid_sysperi_axis_m;           
  output  [6:0]       awvalid_vect_sysperi_axis_m;      
  output  [3:0]       awregion_sysperi_axis_m;          
  input               awready_sysperi_axis_m;           

  output  [31:0]      wdata_sysperi_axis_m;             
  output  [3:0]       wstrb_sysperi_axis_m;             
  output              wlast_sysperi_axis_m;             
  output              wvalid_sysperi_axis_m;            
  input               wready_sysperi_axis_m;            

  input   [11:0]      bid_sysperi_axis_m;               
  input   [1:0]       bresp_sysperi_axis_m;             
  input               bvalid_sysperi_axis_m;            
  output              bready_sysperi_axis_m;            

  output  [11:0]      arid_sysperi_axis_m;              
  output  [31:0]      araddr_sysperi_axis_m;            
  output  [7:0]       arlen_sysperi_axis_m;             
  output  [2:0]       arsize_sysperi_axis_m;            
  output  [1:0]       arburst_sysperi_axis_m;           
  output              arlock_sysperi_axis_m;            
  output  [3:0]       arcache_sysperi_axis_m;           
  output  [2:0]       arprot_sysperi_axis_m;            
  output              arvalid_sysperi_axis_m;           
  output  [6:0]       arvalid_vect_sysperi_axis_m;      
  output  [3:0]       arregion_sysperi_axis_m;          
  input               arready_sysperi_axis_m;           

  input   [11:0]      rid_sysperi_axis_m;               
  input   [31:0]      rdata_sysperi_axis_m;             
  input   [1:0]       rresp_sysperi_axis_m;             
  input               rlast_sysperi_axis_m;             
  input               rvalid_sysperi_axis_m;            
  output              rready_sysperi_axis_m;            

  output  [9:0]       awuser_sysperi_axis_m;            
  output  [9:0]       aruser_sysperi_axis_m;            

  output  [3:0]       awqv_sysperi_axis_m;              
  output  [3:0]       arqv_sysperi_axis_m;              


  output              sysperi_axis_cactive;             


  output              sysperi_axis_cactive_wakeup;      


  input               sysperi_axis_port_enable;         

  input               aclk;                             
  input               aresetn;                          



  wire                sysperi_axis_ar_enable;
  wire                sysperi_axis_aw_enable;
  wire                sysperi_axis_w_enable;

  


  wire           aw_slave_port_dst_valid;
  wire           aw_slave_port_dst_ready;
  wire           aw_slave_port_src_valid;
  wire           aw_slave_port_src_ready;

  wire [78:0]    aw_slave_port_src_data;     
  wire [78:0]    aw_slave_port_dst_data;     

  wire           ar_slave_port_dst_valid;
  wire           ar_slave_port_dst_ready;
  wire           ar_slave_port_src_valid;
  wire           ar_slave_port_src_ready;

  wire [78:0]    ar_slave_port_src_data;     
  wire [78:0]    ar_slave_port_dst_data;     

  wire           w_slave_port_dst_valid;
  wire           w_slave_port_dst_ready;
  wire           w_slave_port_src_valid;
  wire           w_slave_port_src_ready;

  wire [36:0]    w_slave_port_src_data;     
  wire [36:0]    w_slave_port_dst_data;     

  wire           r_slave_port_dst_valid;
  wire           r_slave_port_dst_ready;
  wire           r_slave_port_src_valid;
  wire           r_slave_port_src_ready;

  wire [46:0]    r_slave_port_src_data;     
  wire [46:0]    r_slave_port_dst_data;     

  wire           b_slave_port_dst_valid;
  wire           b_slave_port_dst_ready;
  wire           b_slave_port_src_valid;
  wire           b_slave_port_src_ready;

  wire [13:0]    b_slave_port_src_data;     
  wire [13:0]    b_slave_port_dst_data;     

  wire                security57;
  wire                security63;
  wire [15:0]         security58;
  wire                security62;
  wire [15:0]         security60;
  wire                security61;
  wire [6:0]          awvalid_vect_sysperi_axis_m;            
  wire [6:0]          arvalid_vect_sysperi_axis_m;            
  wire                rvalid_maskcntl;
  wire                wr_cnt_empty;

  wire [3:0]          arcache_int_sysperi_axis_m;
  wire [3:0]          awcache_int_sysperi_axis_m;
  wire                arready_int_m;
  wire                awready_int_m;
  wire                arvalid_int_m;
  wire                awvalid_int_m;
  wire                arready_int_s;
  wire                awready_int_s;
  wire                arvalid_int_s;
  wire                awvalid_int_s;
  wire [31:0]         awaddr_int_s;
  wire [31:0]         araddr_int_s;
  wire [31:0]         awaddr_int_m;
  wire [31:0]         araddr_int_m;
  reg  [2:0]          wr_post_count;
  wire [2:0]          next_wr_post_count;
  reg                 leading_write;
  wire                next_leading_write;
  wire                push_wr_post_count;
  wire                pop_wr_post_count;
  wire                lwrite_en_aw;
  wire                lwrite_en_w;

  wire                tracker_busy;
  wire                sysperi_axis_ot;
  reg                 cactive_wakeup_reg;
  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;



  assign push_wr_post_count = awvalid_int_s & awready_int_s;
  assign pop_wr_post_count  = wlast_sysperi_axis_m & wvalid_sysperi_axis_m & wready_sysperi_axis_m;

  assign next_wr_post_count = (push_wr_post_count & ~pop_wr_post_count) ? wr_post_count + 3'b001 :
                              ((pop_wr_post_count & ~push_wr_post_count) ? wr_post_count - 3'b001 :
                               wr_post_count);

  assign next_leading_write = (wvalid_sysperi_axis_m & wready_sysperi_axis_m & ~push_wr_post_count & (wr_post_count == 3'b001)) ? 1'b1 :
                              ((push_wr_post_count & ~(wvalid_sysperi_axis_m & wready_sysperi_axis_m & (wr_post_count == 3'b000))) ? 1'b0 :
                               leading_write);

  always @(posedge aclk or negedge aresetn)
  begin : p_wr_post_count_seq
    if (!aresetn)
    begin
      wr_post_count <= 3'b001;
      leading_write <= 1'b0;
    end
    else
    begin
      wr_post_count <= next_wr_post_count;
      leading_write <= next_leading_write;
    end
  end

  assign lwrite_en_aw = ~(&wr_post_count);
  assign lwrite_en_w  = (|wr_post_count);




  assign sysperi_axis_ot = (tracker_busy | ar_slave_port_dst_valid | aw_slave_port_dst_valid | w_slave_port_dst_valid | b_slave_port_dst_valid | r_slave_port_dst_valid | leading_write | cactive_wakeup_reg);


  assign sysperi_axis_cactive_wakeup = awvalid_sysperi_axis_s | arvalid_sysperi_axis_s | wvalid_sysperi_axis_s;

  always @(posedge aclk or negedge aresetn)
    begin : p_cactive_wakeup_seq
      if (!aresetn)
        cactive_wakeup_reg <= 1'b0;
      else if (sysperi_axis_port_enable)
        cactive_wakeup_reg <= sysperi_axis_cactive_wakeup;
    end


  assign sysperi_axis_cactive = sysperi_axis_ot;
  assign sysperi_axis_ar_enable = sysperi_axis_port_enable;
  assign sysperi_axis_aw_enable = sysperi_axis_port_enable;
  assign sysperi_axis_w_enable  = sysperi_axis_port_enable;


  assign security57 = 1'b0;
  assign security63 = 1'b0;
  assign security58 = 16'hF000;
  assign security62 = 1'b0;
  assign security60 = 16'hFFFC;
  assign security61 = 1'b1;


  assign arvalid_int_m = arvalid_int_s;
  assign awvalid_int_m = awvalid_int_s;

  assign arready_int_s = arready_int_m;
  assign awready_int_s = awready_int_m;



  assign arvalid_sysperi_axis_m = arvalid_int_m & cds_ar_enable;
  assign awvalid_sysperi_axis_m = awvalid_int_m & cds_aw_enable;
  assign arready_int_m  = arready_sysperi_axis_m & cds_ar_enable;
  assign awready_int_m  = awready_sysperi_axis_m & cds_aw_enable;

  assign awaddr_int_m = awaddr_int_s;
  assign araddr_int_m = araddr_int_s;

  assign awaddr_sysperi_axis_m = awaddr_int_m;
  assign araddr_sysperi_axis_m = araddr_int_m;


  nic400_asib_sysperi_axis_decode_sse710_sys_apb u_aw_add_decode
  (
    .addr_s                 (awaddr_int_s),
    .aregion_out            (awregion_sysperi_axis_m),
    .security57               (security57),
    .security63               (security63),
    .security58               (security58),
    .security62               (security62),
    .security60               (security60),
    .security61               (security61),
    .aprot                  (awprot_sysperi_axis_m[1]),
    .acache_in              (awcache_int_sysperi_axis_m),
    .acache_out             (awcache_sysperi_axis_m),
    .avalid_int             (awvalid_vect_sysperi_axis_m)

  );

nic400_asib_sysperi_axis_wr_spi_cdas_sse710_sys_apb u_asib_sysperi_axis_wr_spi_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vect_sysperi_axis_m),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .aid                    (awid_sysperi_axis_m),
    .wvalid                 (wvalid_sysperi_axis_m),
    .wready                 (wready_sysperi_axis_m),
    .wlast                  (wlast_sysperi_axis_m),
    .resp_valid             (bvalid_sysperi_axis_m),
    .resp_ready             (bready_sysperi_axis_m),
    .resp_id                (bid_sysperi_axis_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_sysperi_axis_decode_sse710_sys_apb u_ar_add_decode
  (
    .addr_s                 (araddr_int_s),
    .aregion_out            (arregion_sysperi_axis_m),
    .security57               (security57),
    .security63               (security63),
    .security58               (security58),
    .security62               (security62),
    .security60               (security60),
    .security61               (security61),
    .aprot                  (arprot_sysperi_axis_m[1]),
    .acache_in              (arcache_int_sysperi_axis_m),
    .acache_out             (arcache_sysperi_axis_m),
    .avalid_int             (arvalid_vect_sysperi_axis_m)

  );

nic400_asib_sysperi_axis_rd_spi_cdas_sse710_sys_apb u_asib_sysperi_axis_rd_spi_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vect_sysperi_axis_m),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .aid                    (arid_sysperi_axis_m),
    .resp_valid             (rvalid_sysperi_axis_m),
    .resp_last              (rlast_sysperi_axis_m),
    .resp_ready             (rready_sysperi_axis_m),
    .resp_id                (rid_sysperi_axis_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_sysperi_axis_maskcntl_sse710_sys_apb u_asib_sysperi_axis_maskcntl (
      .awvalid_m    (awvalid_int_m),
      .arvalid_m    (arvalid_int_m),
      .awready_m    (awready_int_m),
      .arready_m    (arready_int_m),
      .bvalid_m     (bvalid_sysperi_axis_m),
      .bready_m     (bready_sysperi_axis_m),
      .rvalid_m     (rvalid_maskcntl),
      .rready_m     (rready_sysperi_axis_m),

      .wr_cnt_empty (wr_cnt_empty),
      .tracker_busy (tracker_busy),
      .aclk         (aclk),
      .aresetn      (aresetn)
      );

  assign rvalid_maskcntl = rvalid_sysperi_axis_m & rlast_sysperi_axis_m;






  assign aw_slave_port_src_data = {awid_sysperi_axis_s,
          awaddr_sysperi_axis_s,
          awlen_sysperi_axis_s,
          awsize_sysperi_axis_s,
          awburst_sysperi_axis_s,
          awlock_sysperi_axis_s,
          awcache_sysperi_axis_s,
          awuser_sysperi_axis_s,
          awqv_sysperi_axis_s,
          awprot_sysperi_axis_s};

  assign {awid_sysperi_axis_m,
          awaddr_int_s,
          awlen_sysperi_axis_m,
          awsize_sysperi_axis_m,
          awburst_sysperi_axis_m,
          awlock_sysperi_axis_m,
          awcache_int_sysperi_axis_m,
          awuser_sysperi_axis_m,
          awqv_sysperi_axis_m,
          awprot_sysperi_axis_m} = aw_slave_port_dst_data;



  assign awvalid_int_s = aw_slave_port_dst_valid & lwrite_en_aw;
  assign aw_slave_port_dst_ready = awready_int_s & lwrite_en_aw;

  assign aw_slave_port_src_valid = awvalid_sysperi_axis_s & sysperi_axis_aw_enable;
  assign awready_sysperi_axis_s = aw_slave_port_src_ready & sysperi_axis_aw_enable;


  assign ar_slave_port_src_data = {arid_sysperi_axis_s,
          araddr_sysperi_axis_s,
          arlen_sysperi_axis_s,
          arsize_sysperi_axis_s,
          arburst_sysperi_axis_s,
          arlock_sysperi_axis_s,
          arcache_sysperi_axis_s,
          aruser_sysperi_axis_s,
          arqv_sysperi_axis_s,
          arprot_sysperi_axis_s};

  assign {arid_sysperi_axis_m,
          araddr_int_s,
          arlen_sysperi_axis_m,
          arsize_sysperi_axis_m,
          arburst_sysperi_axis_m,
          arlock_sysperi_axis_m,
          arcache_int_sysperi_axis_m,
          aruser_sysperi_axis_m,
          arqv_sysperi_axis_m,
          arprot_sysperi_axis_m} = ar_slave_port_dst_data;



  assign arvalid_int_s = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_int_s;

  assign ar_slave_port_src_valid = arvalid_sysperi_axis_s & sysperi_axis_ar_enable;
  assign arready_sysperi_axis_s = ar_slave_port_src_ready & sysperi_axis_ar_enable;


  assign w_slave_port_src_data = {wdata_sysperi_axis_s,
          wstrb_sysperi_axis_s,
          wlast_sysperi_axis_s};

  assign {wdata_sysperi_axis_m,
          wstrb_sysperi_axis_m,
          wlast_sysperi_axis_m} = w_slave_port_dst_data;



  assign wvalid_sysperi_axis_m = w_slave_port_dst_valid & lwrite_en_w;
  assign w_slave_port_dst_ready = wready_sysperi_axis_m & lwrite_en_w;

  assign w_slave_port_src_valid = wvalid_sysperi_axis_s & sysperi_axis_w_enable;
  assign wready_sysperi_axis_s = w_slave_port_src_ready & sysperi_axis_w_enable;



  assign r_slave_port_src_data = {rid_sysperi_axis_m,
          rdata_sysperi_axis_m,
          rresp_sysperi_axis_m,
          rlast_sysperi_axis_m};

  assign {rid_sysperi_axis_s,
          rdata_sysperi_axis_s,
          rresp_sysperi_axis_s,
          rlast_sysperi_axis_s} = r_slave_port_dst_data;


  assign rvalid_sysperi_axis_s =  r_slave_port_dst_valid;
  assign r_slave_port_dst_ready = rready_sysperi_axis_s;

  assign r_slave_port_src_valid = rvalid_sysperi_axis_m;
  assign rready_sysperi_axis_m = r_slave_port_src_ready;



  assign b_slave_port_src_data = {bid_sysperi_axis_m,
          bresp_sysperi_axis_m};

  assign {bid_sysperi_axis_s,
          bresp_sysperi_axis_s} = b_slave_port_dst_data;


  assign bvalid_sysperi_axis_s =  b_slave_port_dst_valid;
  assign b_slave_port_dst_ready = bready_sysperi_axis_s;

  assign b_slave_port_src_valid = bvalid_sysperi_axis_m;
  assign bready_sysperi_axis_m = b_slave_port_src_ready;



  nic400_asib_sysperi_axis_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       79  
     )
  u_aw_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (aw_slave_port_src_valid),
     .src_data              (aw_slave_port_src_data),
     .dst_ready             (aw_slave_port_dst_ready),

     .src_ready             (aw_slave_port_src_ready),
     .dst_data              (aw_slave_port_dst_data),
     .dst_valid             (aw_slave_port_dst_valid)
     );




  nic400_asib_sysperi_axis_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       79  
     )
  u_ar_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (ar_slave_port_src_valid),
     .src_data              (ar_slave_port_src_data),
     .dst_ready             (ar_slave_port_dst_ready),

     .src_ready             (ar_slave_port_src_ready),
     .dst_data              (ar_slave_port_dst_data),
     .dst_valid             (ar_slave_port_dst_valid)
     );




  nic400_asib_sysperi_axis_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
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




  nic400_asib_sysperi_axis_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       47  
     )
  u_r_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (r_slave_port_src_valid),
     .src_data              (r_slave_port_src_data),
     .dst_ready             (r_slave_port_dst_ready),

     .src_ready             (r_slave_port_src_ready),
     .dst_data              (r_slave_port_dst_data),
     .dst_valid             (r_slave_port_dst_valid)
     );




  nic400_asib_sysperi_axis_chan_slice_sse710_sys_apb
    #(
       `RS_REGD,  
       14  
     )
  u_b_slave_port_chan_slice
    (
     .aresetn               (aresetn),
     .aclk                  (aclk),
     .src_valid             (b_slave_port_src_valid),
     .src_data              (b_slave_port_src_data),
     .dst_ready             (b_slave_port_dst_ready),

     .src_ready             (b_slave_port_src_ready),
     .dst_data              (b_slave_port_dst_data),
     .dst_valid             (b_slave_port_dst_valid)
     );







`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"



  assert_zero_one_hot
    #(`OVL_FATAL, 7, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot zero")
      ovl_arvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {7{arvalid_int_m}} & arvalid_vect_sysperi_axis_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot during ARVALID")
      ovl_arvalid_vect_one_hot_when_arvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( arvalid_int_m & ~|arvalid_vect_sysperi_axis_m )
      );

  assert_zero_one_hot
    #(`OVL_FATAL, 7, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot zero")
      ovl_awvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {7{awvalid_int_m}} & awvalid_vect_sysperi_axis_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot during AWVALID")
      ovl_awvalid_vect_one_hot_when_awvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( awvalid_int_m & ~|awvalid_vect_sysperi_axis_m )
      );

  assert_no_overflow #(
                       `OVL_FATAL,
                       3,
                       0,
                       7,
                       `OVL_ASSERT,
                       "Leading write tracker counter has overflowed"
                      )
  ovl_wr_post_count_overflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_post_count)
  );

  assert_no_underflow #(
                        `OVL_FATAL,
                        3,
                        0,
                        7,
                        `OVL_ASSERT,
                        "Leading write tracker counter has underflowed"
                       )
  ovl_wr_post_count_underflow
  (
    .clk       (aclk),
    .reset_n   (aresetn),
    .test_expr (wr_post_count)
  );


`endif


endmodule

`include "nic400_asib_sysperi_axis_undefs_sse710_sys_apb.v"



