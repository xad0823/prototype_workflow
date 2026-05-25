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



`include "nic400_ib_gpvmain_ahb_ib_defs_sse710_main.v"



module nic400_ib_gpvmain_ahb_ib_master_domain_sse710_main
  (
  

    awid_axi4_m,
    awaddr_axi4_m,
    awlen_axi4_m,
    awsize_axi4_m,
    awburst_axi4_m,
    awlock_axi4_m,
    awcache_axi4_m,
    awprot_axi4_m,
    awvalid_axi4_m,
    awvalid_vect_axi4_m,
    awready_axi4_m,

    wdata_axi4_m,
    wstrb_axi4_m,
    wlast_axi4_m,
    wvalid_axi4_m,
    wready_axi4_m,

    bid_axi4_m,
    bresp_axi4_m,
    bvalid_axi4_m,
    bready_axi4_m,

    arid_axi4_m,
    araddr_axi4_m,
    arlen_axi4_m,
    arsize_axi4_m,
    arburst_axi4_m,
    arlock_axi4_m,
    arcache_axi4_m,
    arprot_axi4_m,
    arvalid_axi4_m,
    arvalid_vect_axi4_m,
    arready_axi4_m,

    rid_axi4_m,
    rdata_axi4_m,
    rresp_axi4_m,
    rlast_axi4_m,
    rvalid_axi4_m,
    rready_axi4_m,

    awqv_axi4_m,
    arqv_axi4_m,


    a_data,
    a_valid,
    a_ready,

    d_data,
    d_valid,
    d_ready,

    w_data,
    w_valid,
    w_ready,
    empty,

    gpvmain_ahb_ib_cactive,

    gpvmain_ahb_ib_cactive_wakeup,

    gpvmain_ahb_ib_port_enable,

    aclk_m,
    aresetn_m

  );




  


  output  [11:0]      awid_axi4_m;                        
  output  [39:0]      awaddr_axi4_m;                      
  output  [7:0]       awlen_axi4_m;                       
  output  [2:0]       awsize_axi4_m;                      
  output  [1:0]       awburst_axi4_m;                     
  output              awlock_axi4_m;                      
  output  [3:0]       awcache_axi4_m;                     
  output  [2:0]       awprot_axi4_m;                      
  output              awvalid_axi4_m;                     
  output  [1:0]       awvalid_vect_axi4_m;                
  input               awready_axi4_m;                     

  output  [31:0]      wdata_axi4_m;                       
  output  [3:0]       wstrb_axi4_m;                       
  output              wlast_axi4_m;                       
  output              wvalid_axi4_m;                      
  input               wready_axi4_m;                      

  input   [11:0]      bid_axi4_m;                         
  input   [1:0]       bresp_axi4_m;                       
  input               bvalid_axi4_m;                      
  output              bready_axi4_m;                      

  output  [11:0]      arid_axi4_m;                        
  output  [39:0]      araddr_axi4_m;                      
  output  [7:0]       arlen_axi4_m;                       
  output  [2:0]       arsize_axi4_m;                      
  output  [1:0]       arburst_axi4_m;                     
  output              arlock_axi4_m;                      
  output  [3:0]       arcache_axi4_m;                     
  output  [2:0]       arprot_axi4_m;                      
  output              arvalid_axi4_m;                     
  output  [1:0]       arvalid_vect_axi4_m;                
  input               arready_axi4_m;                     

  input   [11:0]      rid_axi4_m;                         
  input   [31:0]      rdata_axi4_m;                       
  input   [1:0]       rresp_axi4_m;                       
  input               rlast_axi4_m;                       
  input               rvalid_axi4_m;                      
  output              rready_axi4_m;                      

  output  [3:0]       awqv_axi4_m;                        
  output  [3:0]       arqv_axi4_m;                        



  input   [51:0]      a_data;                             
  input               a_valid;                            
  output              a_ready;                            

  output  [35:0]      d_data;                             
  output              d_valid;                            
  input               d_ready;                            

  input   [36:0]      w_data;                             
  input               w_valid;                            
  output              w_ready;                            
  input               empty;                              


  output              gpvmain_ahb_ib_cactive;             


  output              gpvmain_ahb_ib_cactive_wakeup;      


  input               gpvmain_ahb_ib_port_enable;         

  input               aclk_m;                       
  input               aresetn_m;                    



  wire                awvalid_master;
  wire                awready_master;
  wire                arvalid_master;
  wire                arready_master;
  wire                bvalid_master;
  wire                bready_master;
  wire                rvalid_master;



  wire [1:0]          awvalid_vector;
  wire [1:0]          arvalid_vector;

  wire                wr_cnt_empty;
  wire                mask_w;
  wire                mask_r;



  wire                awrite_iif;
  wire                avalid_iif;
  wire [1:0]          avalid_vect_iif;
  wire [31:0]         aaddr_iif;
  wire [3:0]          alen_iif;
  wire [2:0]          asize_iif;
  wire [1:0]          aburst_iif;
  wire           alock_iif;
  wire [3:0]          acache_iif;
  wire [2:0]          aprot_iif;
  wire                aready_iif;


  wire                dbnr_iif;
  wire                dvalid_iif;
  wire                dlast_iif;
  wire [31:0]         ddata_iif;
  wire [1:0]          dresp_iif;
  wire                dready_iif;
  wire [1:0]          alock_iif_i;
  wire [1:0]          awlock_axi4_m_i;
  wire [1:0]          arlock_axi4_m_i;

  wire                awid;

  wire                wid;
  wire                arid;
  wire [7:0]          zero_pad;
      
  wire [2:0]          asib_gpvmain_ahb_ib_siid;
  
  wire                iid;
  wire                tracker_busy;

  reg [2:0]           wr_post_count;
  wire [2:0]          next_wr_post_count;
  reg                 leading_write;
  wire                next_leading_write;
  wire                push_wr_post_count;
  wire                pop_wr_post_count;
  
  wire                pause_a;
  wire                pause_w;




  assign gpvmain_ahb_ib_cactive = tracker_busy | awvalid_master | arvalid_master
                            | d_valid  |
                              arvalid_axi4_m | awvalid_axi4_m | wvalid_axi4_m |
                              pause_w | leading_write;

  assign gpvmain_ahb_ib_cactive_wakeup = empty;






  assign {
          wdata_axi4_m,
          wstrb_axi4_m,
          wlast_axi4_m} = w_data;

  

  assign wvalid_axi4_m = w_valid & gpvmain_ahb_ib_port_enable & ~pause_w;
  assign w_ready = wready_axi4_m & gpvmain_ahb_ib_port_enable & ~pause_w;



  
  assign push_wr_post_count = avalid_iif & aready_iif & awrite_iif;
  assign pop_wr_post_count = wlast_axi4_m & wvalid_axi4_m & wready_axi4_m;

  assign next_wr_post_count = (push_wr_post_count & ~pop_wr_post_count) ? wr_post_count + 3'b001 :
                               ((pop_wr_post_count & ~push_wr_post_count) ? wr_post_count - 3'b001 :
                               wr_post_count);

  assign next_leading_write = (wvalid_axi4_m & wready_axi4_m & ~push_wr_post_count & (wr_post_count == 3'b001)) ? 1'b1 :
                              ((push_wr_post_count & ~(wvalid_axi4_m & wready_axi4_m & (wr_post_count == 3'b000))) ? 1'b0 :
                               leading_write);

  always @(posedge aclk_m or negedge aresetn_m)
   begin
        if (!aresetn_m)
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

   
   assign pause_a = &wr_post_count & awrite_iif;
   assign pause_w = ~|wr_post_count;
   




  assign {
          awrite_iif,
          aaddr_iif,
          alen_iif,
          asize_iif,
          aburst_iif,
          alock_iif,
          acache_iif,
          aprot_iif,
          avalid_vect_iif} = a_data;

  

  assign avalid_iif = a_valid & gpvmain_ahb_ib_port_enable & ~pause_a;
  assign a_ready = aready_iif & gpvmain_ahb_ib_port_enable & ~pause_a;





  assign d_data = {
          dbnr_iif,
          ddata_iif,
          dresp_iif,
          dlast_iif};

  assign d_valid = dvalid_iif;
  assign dready_iif = d_ready;





  nic400_ib_gpvmain_ahb_ib_itb_to_axi_sse710_main u_itb_to_axi
  (
    .awrite         (awrite_iif),
    .aaddr          (aaddr_iif),
    .alen           (alen_iif),
    .asize          (asize_iif),
    .aburst         (aburst_iif),
    .alock          (alock_iif_i),
    .acache         (acache_iif),
    .aprot          (aprot_iif),
    .avalid_vect    (avalid_vect_iif),
    .avalid         (avalid_iif),
    .aready         (aready_iif),

    .dbnr           (dbnr_iif),
    .ddata          (ddata_iif),
    .dresp          (dresp_iif),
    .dlast          (dlast_iif),
    .dvalid         (dvalid_iif),
    .dready         (dready_iif),

    .awaddr         (awaddr_axi4_m[31:0]),
    .awlen          (awlen_axi4_m[3:0]),
    .awsize         (awsize_axi4_m),
    .awburst        (awburst_axi4_m),
    .awlock         (awlock_axi4_m_i),
    .awcache        (awcache_axi4_m),
    .awprot         (awprot_axi4_m),
    .awvalid_vect   (awvalid_vector),
    .awvalid        (awvalid_master),
    .awready        (awready_master),

    .bresp          (bresp_axi4_m),
    .bvalid         (bvalid_master),
    .bready         (bready_master),

    .araddr         (araddr_axi4_m[31:0]),
    .arlen          (arlen_axi4_m[3:0]),
    .arsize         (arsize_axi4_m),
    .arburst        (arburst_axi4_m),
    .arlock         (arlock_axi4_m_i),
    .arcache        (arcache_axi4_m),
    .arprot         (arprot_axi4_m),
    .arvalid_vect   (arvalid_vector),
    .arvalid        (arvalid_master),
    .arready        (arready_master),

    .rdata          (rdata_axi4_m),
    .rresp          (rresp_axi4_m),
    .rlast          (rlast_axi4_m),
    .rvalid         (rvalid_axi4_m),
    .rready         (rready_axi4_m),

    .aclk           (aclk_m),
    .aresetn        (aresetn_m)
  );


  assign alock_iif_i = {1'b0,alock_iif};
  assign awlock_axi4_m = awlock_axi4_m_i[0];
  assign arlock_axi4_m = arlock_axi4_m_i[0];

  
  assign awlen_axi4_m[7:4] = 4'b0000;
  assign arlen_axi4_m[7:4] = 4'b0000;
  


  assign awaddr_axi4_m[39:32] = {8{1'b0}};
  assign araddr_axi4_m[39:32] = {8{1'b0}};






  assign asib_gpvmain_ahb_ib_siid = 3'b0;
  assign iid = 1'd1;


  assign zero_pad = 8'b0;

  assign awid_axi4_m = {iid,zero_pad,asib_gpvmain_ahb_ib_siid};
  assign arid_axi4_m = {iid,zero_pad,asib_gpvmain_ahb_ib_siid};




nic400_ib_gpvmain_ahb_ib_maskcntl_sse710_main u_maskcntl (
        .awvalid_m    (awvalid_master),
        .arvalid_m    (arvalid_master),
        .awready_m    (awready_master),
        .arready_m    (arready_master),
        .bvalid_m     (bvalid_master),
        .bready_m     (bready_master),
        .rvalid_m     (rvalid_master),
        .rready_m     (rready_axi4_m),
        .wr_cnt_empty (wr_cnt_empty),
        .mask_w       (mask_w),
        .mask_r       (mask_r),
        .aw_qos_m     (awqv_axi4_m),
        .ar_qos_m     (arqv_axi4_m),
        .tracker_busy (tracker_busy),
        .aclk         (aclk_m),
        .aresetn      (aresetn_m)
        );


  
  assign awvalid_axi4_m = (awvalid_master & !mask_w);
  assign arvalid_axi4_m = (arvalid_master & !mask_r);

  assign awready_master = (awready_axi4_m & !mask_w);
  assign arready_master = (arready_axi4_m & !mask_r);

  assign bvalid_master = (bvalid_axi4_m & !wr_cnt_empty);
  assign bready_axi4_m = (bready_master & !wr_cnt_empty);



  assign rvalid_master = rvalid_axi4_m & rlast_axi4_m;

  
  assign awvalid_vect_axi4_m = ({2{awvalid_axi4_m}} & awvalid_vector);
  assign arvalid_vect_axi4_m = ({2{arvalid_axi4_m}} & arvalid_vector);
  














endmodule
`include "nic400_ib_gpvmain_ahb_ib_undefs_sse710_main.v"




