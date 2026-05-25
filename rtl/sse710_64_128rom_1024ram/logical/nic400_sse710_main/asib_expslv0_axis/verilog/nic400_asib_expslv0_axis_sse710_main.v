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



`include "nic400_asib_expslv0_axis_defs_sse710_main.v"

module nic400_asib_expslv0_axis_sse710_main
 (
  

    awid_expslv0_axis_s,
    awaddr_expslv0_axis_s,
    awlen_expslv0_axis_s,
    awsize_expslv0_axis_s,
    awburst_expslv0_axis_s,
    awlock_expslv0_axis_s,
    awcache_expslv0_axis_s,
    awprot_expslv0_axis_s,
    awvalid_expslv0_axis_s,
    awready_expslv0_axis_s,

    wdata_expslv0_axis_s,
    wstrb_expslv0_axis_s,
    wlast_expslv0_axis_s,
    wvalid_expslv0_axis_s,
    wready_expslv0_axis_s,

    bid_expslv0_axis_s,
    bresp_expslv0_axis_s,
    bvalid_expslv0_axis_s,
    bready_expslv0_axis_s,

    arid_expslv0_axis_s,
    araddr_expslv0_axis_s,
    arlen_expslv0_axis_s,
    arsize_expslv0_axis_s,
    arburst_expslv0_axis_s,
    arlock_expslv0_axis_s,
    arcache_expslv0_axis_s,
    arprot_expslv0_axis_s,
    arvalid_expslv0_axis_s,
    arready_expslv0_axis_s,

    rid_expslv0_axis_s,
    rdata_expslv0_axis_s,
    rresp_expslv0_axis_s,
    rlast_expslv0_axis_s,
    rvalid_expslv0_axis_s,
    rready_expslv0_axis_s,

    awuser_expslv0_axis_s,
    buser_expslv0_axis_s,
    aruser_expslv0_axis_s,
    ruser_expslv0_axis_s,

    awqv_expslv0_axis_s,
    arqv_expslv0_axis_s,


    awid_expslv0_axis_m,
    awaddr_expslv0_axis_m,
    awlen_expslv0_axis_m,
    awsize_expslv0_axis_m,
    awburst_expslv0_axis_m,
    awlock_expslv0_axis_m,
    awcache_expslv0_axis_m,
    awprot_expslv0_axis_m,
    awvalid_expslv0_axis_m,
    awvalid_vect_expslv0_axis_m,
    awready_expslv0_axis_m,

    wdata_expslv0_axis_m,
    wstrb_expslv0_axis_m,
    wlast_expslv0_axis_m,
    wvalid_expslv0_axis_m,
    wready_expslv0_axis_m,

    bid_expslv0_axis_m,
    bresp_expslv0_axis_m,
    bvalid_expslv0_axis_m,
    bready_expslv0_axis_m,

    arid_expslv0_axis_m,
    araddr_expslv0_axis_m,
    arlen_expslv0_axis_m,
    arsize_expslv0_axis_m,
    arburst_expslv0_axis_m,
    arlock_expslv0_axis_m,
    arcache_expslv0_axis_m,
    arprot_expslv0_axis_m,
    arvalid_expslv0_axis_m,
    arvalid_vect_expslv0_axis_m,
    arready_expslv0_axis_m,

    rid_expslv0_axis_m,
    rdata_expslv0_axis_m,
    rresp_expslv0_axis_m,
    rlast_expslv0_axis_m,
    rvalid_expslv0_axis_m,
    rready_expslv0_axis_m,

    awuser_expslv0_axis_m,
    buser_expslv0_axis_m,
    aruser_expslv0_axis_m,
    ruser_expslv0_axis_m,

    awqv_expslv0_axis_m,
    arqv_expslv0_axis_m,

    expslv0_axis_cactive,

    expslv0_axis_cactive_wakeup,

    expslv0_axis_port_enable,

    aclk,
    aresetn

  );




  


  input   [7:0]       awid_expslv0_axis_s;              
  input   [31:0]      awaddr_expslv0_axis_s;            
  input   [7:0]       awlen_expslv0_axis_s;             
  input   [2:0]       awsize_expslv0_axis_s;            
  input   [1:0]       awburst_expslv0_axis_s;           
  input               awlock_expslv0_axis_s;            
  input   [3:0]       awcache_expslv0_axis_s;           
  input   [2:0]       awprot_expslv0_axis_s;            
  input               awvalid_expslv0_axis_s;           
  output              awready_expslv0_axis_s;           

  input   [63:0]      wdata_expslv0_axis_s;             
  input   [7:0]       wstrb_expslv0_axis_s;             
  input               wlast_expslv0_axis_s;             
  input               wvalid_expslv0_axis_s;            
  output              wready_expslv0_axis_s;            

  output  [7:0]       bid_expslv0_axis_s;               
  output  [1:0]       bresp_expslv0_axis_s;             
  output              bvalid_expslv0_axis_s;            
  input               bready_expslv0_axis_s;            

  input   [7:0]       arid_expslv0_axis_s;              
  input   [31:0]      araddr_expslv0_axis_s;            
  input   [7:0]       arlen_expslv0_axis_s;             
  input   [2:0]       arsize_expslv0_axis_s;            
  input   [1:0]       arburst_expslv0_axis_s;           
  input               arlock_expslv0_axis_s;            
  input   [3:0]       arcache_expslv0_axis_s;           
  input   [2:0]       arprot_expslv0_axis_s;            
  input               arvalid_expslv0_axis_s;           
  output              arready_expslv0_axis_s;           

  output  [7:0]       rid_expslv0_axis_s;               
  output  [63:0]      rdata_expslv0_axis_s;             
  output  [1:0]       rresp_expslv0_axis_s;             
  output              rlast_expslv0_axis_s;             
  output              rvalid_expslv0_axis_s;            
  input               rready_expslv0_axis_s;            

  input   [9:0]       awuser_expslv0_axis_s;            
  output              buser_expslv0_axis_s;             
  input   [9:0]       aruser_expslv0_axis_s;            
  output              ruser_expslv0_axis_s;             

  input   [3:0]       awqv_expslv0_axis_s;              
  input   [3:0]       arqv_expslv0_axis_s;              



  output  [7:0]       awid_expslv0_axis_m;              
  output  [31:0]      awaddr_expslv0_axis_m;            
  output  [7:0]       awlen_expslv0_axis_m;             
  output  [2:0]       awsize_expslv0_axis_m;            
  output  [1:0]       awburst_expslv0_axis_m;           
  output              awlock_expslv0_axis_m;            
  output  [3:0]       awcache_expslv0_axis_m;           
  output  [2:0]       awprot_expslv0_axis_m;            
  output              awvalid_expslv0_axis_m;           
  output  [9:0]       awvalid_vect_expslv0_axis_m;      
  input               awready_expslv0_axis_m;           

  output  [63:0]      wdata_expslv0_axis_m;             
  output  [7:0]       wstrb_expslv0_axis_m;             
  output              wlast_expslv0_axis_m;             
  output              wvalid_expslv0_axis_m;            
  input               wready_expslv0_axis_m;            

  input   [7:0]       bid_expslv0_axis_m;               
  input   [1:0]       bresp_expslv0_axis_m;             
  input               bvalid_expslv0_axis_m;            
  output              bready_expslv0_axis_m;            

  output  [7:0]       arid_expslv0_axis_m;              
  output  [31:0]      araddr_expslv0_axis_m;            
  output  [7:0]       arlen_expslv0_axis_m;             
  output  [2:0]       arsize_expslv0_axis_m;            
  output  [1:0]       arburst_expslv0_axis_m;           
  output              arlock_expslv0_axis_m;            
  output  [3:0]       arcache_expslv0_axis_m;           
  output  [2:0]       arprot_expslv0_axis_m;            
  output              arvalid_expslv0_axis_m;           
  output  [9:0]       arvalid_vect_expslv0_axis_m;      
  input               arready_expslv0_axis_m;           

  input   [7:0]       rid_expslv0_axis_m;               
  input   [63:0]      rdata_expslv0_axis_m;             
  input   [1:0]       rresp_expslv0_axis_m;             
  input               rlast_expslv0_axis_m;             
  input               rvalid_expslv0_axis_m;            
  output              rready_expslv0_axis_m;            

  output  [9:0]       awuser_expslv0_axis_m;            
  input               buser_expslv0_axis_m;             
  output  [9:0]       aruser_expslv0_axis_m;            
  input               ruser_expslv0_axis_m;             

  output  [3:0]       awqv_expslv0_axis_m;              
  output  [3:0]       arqv_expslv0_axis_m;              


  output              expslv0_axis_cactive;             


  output              expslv0_axis_cactive_wakeup;      


  input               expslv0_axis_port_enable;         

  input               aclk;                             
  input               aresetn;                          



  wire                expslv0_axis_ar_enable;
  wire                expslv0_axis_aw_enable;
  wire                expslv0_axis_w_enable;

  


  wire           aw_slave_port_dst_valid;
  wire           aw_slave_port_dst_ready;
  wire           aw_slave_port_src_valid;
  wire           aw_slave_port_src_ready;

  wire [74:0]    aw_slave_port_src_data;     
  wire [74:0]    aw_slave_port_dst_data;     

  wire           ar_slave_port_dst_valid;
  wire           ar_slave_port_dst_ready;
  wire           ar_slave_port_src_valid;
  wire           ar_slave_port_src_ready;

  wire [74:0]    ar_slave_port_src_data;     
  wire [74:0]    ar_slave_port_dst_data;     

  wire           w_slave_port_dst_valid;
  wire           w_slave_port_dst_ready;
  wire           w_slave_port_src_valid;
  wire           w_slave_port_src_ready;

  wire [72:0]    w_slave_port_src_data;     
  wire [72:0]    w_slave_port_dst_data;     

  wire           r_slave_port_dst_valid;
  wire           r_slave_port_dst_ready;
  wire           r_slave_port_src_valid;
  wire           r_slave_port_src_ready;

  wire [75:0]    r_slave_port_src_data;     
  wire [75:0]    r_slave_port_dst_data;     

  wire           b_slave_port_dst_valid;
  wire           b_slave_port_dst_ready;
  wire           b_slave_port_src_valid;
  wire           b_slave_port_src_ready;

  wire [10:0]    b_slave_port_src_data;     
  wire [10:0]    b_slave_port_dst_data;     

  wire                security62;
  wire                security61;
  wire                security55;
  wire                security58;
  wire                security57;
  wire                security60;
  wire                security59;
  wire [9:0]          awvalid_vect_expslv0_axis_m;            
  wire [9:0]          arvalid_vect_expslv0_axis_m;            
  wire                rvalid_maskcntl;
  wire                wr_cnt_empty;

  wire [3:0]          arcache_int_expslv0_axis_m;
  wire [3:0]          awcache_int_expslv0_axis_m;
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
  wire                expslv0_axis_ot;
  reg                 cactive_wakeup_reg;
  wire                cds_aw_enable;
  wire                cds_ar_enable;
  wire                cds_w_enable;



  assign push_wr_post_count = awvalid_int_s & awready_int_s;
  assign pop_wr_post_count  = wlast_expslv0_axis_m & wvalid_expslv0_axis_m & wready_expslv0_axis_m;

  assign next_wr_post_count = (push_wr_post_count & ~pop_wr_post_count) ? wr_post_count + 3'b001 :
                              ((pop_wr_post_count & ~push_wr_post_count) ? wr_post_count - 3'b001 :
                               wr_post_count);

  assign next_leading_write = (wvalid_expslv0_axis_m & wready_expslv0_axis_m & ~push_wr_post_count & (wr_post_count == 3'b001)) ? 1'b1 :
                              ((push_wr_post_count & ~(wvalid_expslv0_axis_m & wready_expslv0_axis_m & (wr_post_count == 3'b000))) ? 1'b0 :
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




  assign expslv0_axis_ot = (tracker_busy | ar_slave_port_dst_valid | aw_slave_port_dst_valid | w_slave_port_dst_valid | b_slave_port_dst_valid | r_slave_port_dst_valid | leading_write | cactive_wakeup_reg);


  assign expslv0_axis_cactive_wakeup = awvalid_expslv0_axis_s | arvalid_expslv0_axis_s | wvalid_expslv0_axis_s;

  always @(posedge aclk or negedge aresetn)
    begin : p_cactive_wakeup_seq
      if (!aresetn)
        cactive_wakeup_reg <= 1'b0;
      else if (expslv0_axis_port_enable)
        cactive_wakeup_reg <= expslv0_axis_cactive_wakeup;
    end


  assign expslv0_axis_cactive = expslv0_axis_ot;
  assign expslv0_axis_ar_enable = expslv0_axis_port_enable;
  assign expslv0_axis_aw_enable = expslv0_axis_port_enable;
  assign expslv0_axis_w_enable  = expslv0_axis_port_enable;


  assign security62 = 1'b0;
  assign security61 = 1'b0;
  assign security55 = 1'b0;
  assign security58 = 1'b0;
  assign security57 = 1'b0;
  assign security60 = 1'b0;
  assign security59 = 1'b0;


  assign arvalid_int_m = arvalid_int_s;
  assign awvalid_int_m = awvalid_int_s;

  assign arready_int_s = arready_int_m;
  assign awready_int_s = awready_int_m;



  assign arvalid_expslv0_axis_m = arvalid_int_m & cds_ar_enable;
  assign awvalid_expslv0_axis_m = awvalid_int_m & cds_aw_enable;
  assign arready_int_m  = arready_expslv0_axis_m & cds_ar_enable;
  assign awready_int_m  = awready_expslv0_axis_m & cds_aw_enable;

  assign awaddr_int_m = awaddr_int_s;
  assign araddr_int_m = araddr_int_s;

  assign awaddr_expslv0_axis_m = awaddr_int_m;
  assign araddr_expslv0_axis_m = araddr_int_m;


  nic400_asib_expslv0_axis_decode_sse710_main u_aw_add_decode
  (
    .addr_s                 (awaddr_int_s),
    .security62               (security62),
    .security61               (security61),
    .security55               (security55),
    .security58               (security58),
    .security57               (security57),
    .security60               (security60),
    .security59               (security59),
    .aprot                  (awprot_expslv0_axis_m[1]),
    .acache_in              (awcache_int_expslv0_axis_m),
    .acache_out             (awcache_expslv0_axis_m),
    .avalid_int             (awvalid_vect_expslv0_axis_m)

  );

nic400_asib_expslv0_axis_wr_spi_cdas_sse710_main u_asib_expslv0_axis_wr_spi_cdas
  (
    .aw_enable              (cds_aw_enable),
    .wr_enable              (cds_w_enable),
    .asel                   (awvalid_vect_expslv0_axis_m),
    .avalid                 (awvalid_int_m),
    .aready                 (awready_int_m),
    .aid                    (awid_expslv0_axis_m),
    .wvalid                 (wvalid_expslv0_axis_m),
    .wready                 (wready_expslv0_axis_m),
    .wlast                  (wlast_expslv0_axis_m),
    .resp_valid             (bvalid_expslv0_axis_m),
    .resp_ready             (bready_expslv0_axis_m),
    .resp_id                (bid_expslv0_axis_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_expslv0_axis_decode_sse710_main u_ar_add_decode
  (
    .addr_s                 (araddr_int_s),
    .security62               (security62),
    .security61               (security61),
    .security55               (security55),
    .security58               (security58),
    .security57               (security57),
    .security60               (security60),
    .security59               (security59),
    .aprot                  (arprot_expslv0_axis_m[1]),
    .acache_in              (arcache_int_expslv0_axis_m),
    .acache_out             (arcache_expslv0_axis_m),
    .avalid_int             (arvalid_vect_expslv0_axis_m)

  );

nic400_asib_expslv0_axis_rd_spi_cdas_sse710_main u_asib_expslv0_axis_rd_spi_cdas
  (
    .ar_enable              (cds_ar_enable),
    .asel                   (arvalid_vect_expslv0_axis_m),
    .avalid                 (arvalid_int_m),
    .aready                 (arready_int_m),
    .aid                    (arid_expslv0_axis_m),
    .resp_valid             (rvalid_expslv0_axis_m),
    .resp_last              (rlast_expslv0_axis_m),
    .resp_ready             (rready_expslv0_axis_m),
    .resp_id                (rid_expslv0_axis_m),

    .aclk                   (aclk),
    .aresetn                (aresetn)
  );



  nic400_asib_expslv0_axis_maskcntl_sse710_main u_asib_expslv0_axis_maskcntl (
      .awvalid_m    (awvalid_int_m),
      .arvalid_m    (arvalid_int_m),
      .awready_m    (awready_int_m),
      .arready_m    (arready_int_m),
      .bvalid_m     (bvalid_expslv0_axis_m),
      .bready_m     (bready_expslv0_axis_m),
      .rvalid_m     (rvalid_maskcntl),
      .rready_m     (rready_expslv0_axis_m),

      .wr_cnt_empty (wr_cnt_empty),
      .tracker_busy (tracker_busy),
      .aclk         (aclk),
      .aresetn      (aresetn)
      );

  assign rvalid_maskcntl = rvalid_expslv0_axis_m & rlast_expslv0_axis_m;






  assign aw_slave_port_src_data = {awid_expslv0_axis_s,
          awaddr_expslv0_axis_s,
          awlen_expslv0_axis_s,
          awsize_expslv0_axis_s,
          awburst_expslv0_axis_s,
          awlock_expslv0_axis_s,
          awcache_expslv0_axis_s,
          awuser_expslv0_axis_s,
          awqv_expslv0_axis_s,
          awprot_expslv0_axis_s};

  assign {awid_expslv0_axis_m,
          awaddr_int_s,
          awlen_expslv0_axis_m,
          awsize_expslv0_axis_m,
          awburst_expslv0_axis_m,
          awlock_expslv0_axis_m,
          awcache_int_expslv0_axis_m,
          awuser_expslv0_axis_m,
          awqv_expslv0_axis_m,
          awprot_expslv0_axis_m} = aw_slave_port_dst_data;



  assign awvalid_int_s = aw_slave_port_dst_valid & lwrite_en_aw;
  assign aw_slave_port_dst_ready = awready_int_s & lwrite_en_aw;

  assign aw_slave_port_src_valid = awvalid_expslv0_axis_s & expslv0_axis_aw_enable;
  assign awready_expslv0_axis_s = aw_slave_port_src_ready & expslv0_axis_aw_enable;


  assign ar_slave_port_src_data = {arid_expslv0_axis_s,
          araddr_expslv0_axis_s,
          arlen_expslv0_axis_s,
          arsize_expslv0_axis_s,
          arburst_expslv0_axis_s,
          arlock_expslv0_axis_s,
          arcache_expslv0_axis_s,
          aruser_expslv0_axis_s,
          arqv_expslv0_axis_s,
          arprot_expslv0_axis_s};

  assign {arid_expslv0_axis_m,
          araddr_int_s,
          arlen_expslv0_axis_m,
          arsize_expslv0_axis_m,
          arburst_expslv0_axis_m,
          arlock_expslv0_axis_m,
          arcache_int_expslv0_axis_m,
          aruser_expslv0_axis_m,
          arqv_expslv0_axis_m,
          arprot_expslv0_axis_m} = ar_slave_port_dst_data;



  assign arvalid_int_s = ar_slave_port_dst_valid;
  assign ar_slave_port_dst_ready = arready_int_s;

  assign ar_slave_port_src_valid = arvalid_expslv0_axis_s & expslv0_axis_ar_enable;
  assign arready_expslv0_axis_s = ar_slave_port_src_ready & expslv0_axis_ar_enable;


  assign w_slave_port_src_data = {wdata_expslv0_axis_s,
          wstrb_expslv0_axis_s,
          wlast_expslv0_axis_s};

  assign {wdata_expslv0_axis_m,
          wstrb_expslv0_axis_m,
          wlast_expslv0_axis_m} = w_slave_port_dst_data;



  assign wvalid_expslv0_axis_m = w_slave_port_dst_valid & lwrite_en_w;
  assign w_slave_port_dst_ready = wready_expslv0_axis_m & lwrite_en_w;

  assign w_slave_port_src_valid = wvalid_expslv0_axis_s & expslv0_axis_w_enable;
  assign wready_expslv0_axis_s = w_slave_port_src_ready & expslv0_axis_w_enable;



  assign r_slave_port_src_data = {rid_expslv0_axis_m,
          rdata_expslv0_axis_m,
          rresp_expslv0_axis_m,
          ruser_expslv0_axis_m,
          rlast_expslv0_axis_m};

  assign {rid_expslv0_axis_s,
          rdata_expslv0_axis_s,
          rresp_expslv0_axis_s,
          ruser_expslv0_axis_s,
          rlast_expslv0_axis_s} = r_slave_port_dst_data;


  assign rvalid_expslv0_axis_s =  r_slave_port_dst_valid;
  assign r_slave_port_dst_ready = rready_expslv0_axis_s;

  assign r_slave_port_src_valid = rvalid_expslv0_axis_m;
  assign rready_expslv0_axis_m = r_slave_port_src_ready;



  assign b_slave_port_src_data = {bid_expslv0_axis_m,
          bresp_expslv0_axis_m,
          buser_expslv0_axis_m};

  assign {bid_expslv0_axis_s,
          bresp_expslv0_axis_s,
          buser_expslv0_axis_s} = b_slave_port_dst_data;


  assign bvalid_expslv0_axis_s =  b_slave_port_dst_valid;
  assign b_slave_port_dst_ready = bready_expslv0_axis_s;

  assign b_slave_port_src_valid = bvalid_expslv0_axis_m;
  assign bready_expslv0_axis_m = b_slave_port_src_ready;



  nic400_asib_expslv0_axis_chan_slice_sse710_main
    #(
       `RS_REGD,  
       75  
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




  nic400_asib_expslv0_axis_chan_slice_sse710_main
    #(
       `RS_REGD,  
       75  
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




  nic400_asib_expslv0_axis_chan_slice_sse710_main
    #(
       `RS_REGD,  
       73  
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




  nic400_asib_expslv0_axis_chan_slice_sse710_main
    #(
       `RS_REGD,  
       76  
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




  nic400_asib_expslv0_axis_chan_slice_sse710_main
    #(
       `RS_REGD,  
       11  
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
    #(`OVL_FATAL, 10, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot zero")
      ovl_arvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {10{arvalid_int_m}} & arvalid_vect_expslv0_axis_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AR Valid vector not one-hot during ARVALID")
      ovl_arvalid_vect_one_hot_when_arvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( arvalid_int_m & ~|arvalid_vect_expslv0_axis_m )
      );

  assert_zero_one_hot
    #(`OVL_FATAL, 10, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot zero")
      ovl_awvalid_vect_one_hot_zero
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( {10{awvalid_int_m}} & awvalid_vect_expslv0_axis_m )
      );
  assert_never
    #(`OVL_FATAL, `OVL_ASSERT,
      "Error: AW Valid vector not one-hot during AWVALID")
      ovl_awvalid_vect_one_hot_when_awvalid
      (
        .clk (aclk),
        .reset_n (aresetn),
        .test_expr ( awvalid_int_m & ~|awvalid_vect_expslv0_axis_m )
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

`include "nic400_asib_expslv0_axis_undefs_sse710_main.v"



