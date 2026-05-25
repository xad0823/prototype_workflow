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



`include "nic400_ib_slave_if0_0_m_ib_defs_sse710_boot_reg.v"



module nic400_ib_slave_if0_0_m_ib_master_domain_sse710_boot_reg
  (
  

    aid_itb_m,
    aaddr_itb_m,
    alen_itb_m,
    asize_itb_m,
    aburst_itb_m,
    alock_itb_m,
    acache_itb_m,
    aprot_itb_m,
    awrite_itb_m,
    avalid_itb_m,
    aready_itb_m,

    wdata_itb_m,
    wstrb_itb_m,
    wlast_itb_m,
    wvalid_itb_m,
    wready_itb_m,

    did_itb_m,
    ddata_itb_m,
    dresp_itb_m,
    dlast_itb_m,
    dbnr_itb_m,
    dvalid_itb_m,
    dready_itb_m,


    a_data_async,
    a_rpntr_gry_async,
    a_rpntr_bin,
    a_wpntr_gry_async,

    d_data_async,
    d_rpntr_gry_async,
    d_rpntr_bin,
    d_wpntr_gry_async,

    w_data_async,
    w_rpntr_gry_async,
    w_rpntr_bin,
    w_wpntr_gry_async,
    empty_async,

    slave_if0_0_m_ib_cactive,

    slave_if0_0_m_ib_cactive_wakeup,

    slave_if0_0_m_ib_port_enable,

    aclk_m,
    aresetn_m

  );




  


  output  [9:0]       aid_itb_m;                            
  output  [31:0]      aaddr_itb_m;                          
  output  [7:0]       alen_itb_m;                           
  output  [2:0]       asize_itb_m;                          
  output  [1:0]       aburst_itb_m;                         
  output              alock_itb_m;                          
  output  [3:0]       acache_itb_m;                         
  output  [2:0]       aprot_itb_m;                          
  output              awrite_itb_m;                         
  output              avalid_itb_m;                         
  input               aready_itb_m;                         

  output  [31:0]      wdata_itb_m;                          
  output  [3:0]       wstrb_itb_m;                          
  output              wlast_itb_m;                          
  output              wvalid_itb_m;                         
  input               wready_itb_m;                         

  input   [9:0]       did_itb_m;                            
  input   [31:0]      ddata_itb_m;                          
  input   [1:0]       dresp_itb_m;                          
  input               dlast_itb_m;                          
  input               dbnr_itb_m;                           
  input               dvalid_itb_m;                         
  output              dready_itb_m;                         



  input   [63:0]      a_data_async;                         
  output  [1:0]       a_rpntr_gry_async;                    
  output              a_rpntr_bin;                          
  input   [1:0]       a_wpntr_gry_async;                    

  output  [45:0]      d_data_async;                         
  input   [1:0]       d_rpntr_gry_async;                    
  input               d_rpntr_bin;                          
  output  [1:0]       d_wpntr_gry_async;                    

  input   [36:0]      w_data_async;                         
  output  [1:0]       w_rpntr_gry_async;                    
  output              w_rpntr_bin;                          
  input   [1:0]       w_wpntr_gry_async;                    
  input               empty_async;                          


  output              slave_if0_0_m_ib_cactive;             


  output              slave_if0_0_m_ib_cactive_wakeup;      


  input               slave_if0_0_m_ib_port_enable;         

  input               aclk_m;                         
  input               aresetn_m;                      



  
  wire                a_boundary_dst_valid;
  wire                a_boundary_dst_ready;

  wire [63:0]         a_boundary_dst_data;     


  
  wire                w_boundary_dst_valid;
  wire                w_boundary_dst_ready;

  wire [36:0]         w_boundary_dst_data;     


  
  wire                d_boundary_src_valid;
  wire                d_boundary_src_ready;

  wire [45:0]         d_boundary_src_data;     
  wire [45:0]         d_boundary_dst_data;     


  wire [1:0]          a_rpntr_gry_async;           
  wire                a_rpntr_bin;           
  wire [1:0]          a_wpntr_gry_async;           

  wire [1:0]          w_rpntr_gry_async;           
  wire                w_rpntr_bin;           
  wire [1:0]          w_wpntr_gry_async;           

  wire [1:0]          d_rpntr_gry_async;           
  wire                d_rpntr_bin;           
  wire [1:0]          d_wpntr_gry_async;           


  wire                avalid_itb_m;
  wire                aready_itb_m;

  wire                dbnr_itb_m;
  wire                dvalid_itb_m;
  wire                dlast_itb_m;
  wire [31:0]         ddata_itb_m;
  wire [1:0]          dresp_itb_m;
  wire [9:0]          did_itb_m;
  wire                dready_itb_m;
  wire                tracker_busy;

  wire                tracker_full;
  wire                tracker_empty;

  reg [2:0]           wr_post_count;
  wire [2:0]          next_wr_post_count;
  reg                 leading_write;
  wire                next_leading_write;
  wire                push_wr_post_count;
  wire                pop_wr_post_count;
  
  wire                pause_a;
  wire                pause_w;




  assign slave_if0_0_m_ib_cactive = tracker_busy |
                              a_boundary_dst_valid |
                              w_boundary_dst_valid
                            | d_boundary_src_valid  |
                              avalid_itb_m | wvalid_itb_m |
                              pause_w | leading_write;

  assign slave_if0_0_m_ib_cactive_wakeup = empty_async;






  assign {
          aid_itb_m,
          awrite_itb_m,
          aaddr_itb_m[31:0],
          alen_itb_m,
          asize_itb_m,
          aburst_itb_m,
          alock_itb_m,
          acache_itb_m,
          aprot_itb_m} = a_boundary_dst_data;

  

  assign avalid_itb_m = a_boundary_dst_valid & slave_if0_0_m_ib_port_enable & ~pause_a & ~tracker_full;
  assign a_boundary_dst_ready = aready_itb_m & slave_if0_0_m_ib_port_enable & ~pause_a & ~tracker_full;







  assign {
          wdata_itb_m,
          wstrb_itb_m,
          wlast_itb_m} = w_boundary_dst_data;

  

  assign wvalid_itb_m = w_boundary_dst_valid & slave_if0_0_m_ib_port_enable & ~pause_w;
  assign w_boundary_dst_ready = wready_itb_m & slave_if0_0_m_ib_port_enable & ~pause_w;



  
  assign push_wr_post_count = avalid_itb_m & aready_itb_m & awrite_itb_m;
  assign pop_wr_post_count = wlast_itb_m & wvalid_itb_m & wready_itb_m;

  assign next_wr_post_count = (push_wr_post_count & ~pop_wr_post_count) ? wr_post_count + 3'b001 :
                               ((pop_wr_post_count & ~push_wr_post_count) ? wr_post_count - 3'b001 :
                               wr_post_count);

  assign next_leading_write = (wvalid_itb_m & wready_itb_m & ~push_wr_post_count & (wr_post_count == 3'b001)) ? 1'b1 :
                              ((push_wr_post_count & ~(wvalid_itb_m & wready_itb_m & (wr_post_count == 3'b000))) ? 1'b0 :
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

   
   assign pause_a = &wr_post_count & awrite_itb_m;
   assign pause_w = ~|wr_post_count;
   


  assign d_boundary_src_data = {
          did_itb_m,
          dbnr_itb_m,
          ddata_itb_m,
          dresp_itb_m,
          dlast_itb_m};

  assign d_boundary_src_valid = dvalid_itb_m & ~tracker_empty;
  assign dready_itb_m = d_boundary_src_ready & ~tracker_empty;

  assign d_data_async = d_boundary_dst_data;
  

  nic400_ib_slave_if0_0_m_ib_a_fifo_rd_sse710_boot_reg
  u_a_fifo_rd
    (
     .rresetn               (aresetn_m),
     .rclk                  (aclk_m),
     .src_data              (a_data_async),
     .dst_ready             (a_boundary_dst_ready),
     .wpntr_gry_async       (a_wpntr_gry_async),

     .dst_data              (a_boundary_dst_data),
     .dst_valid             (a_boundary_dst_valid),
     .rpntr_gry_async       (a_rpntr_gry_async),
     .rpntr_bin             (a_rpntr_bin)
     );




  nic400_ib_slave_if0_0_m_ib_w_fifo_rd_sse710_boot_reg
  u_w_fifo_rd
    (
     .rresetn               (aresetn_m),
     .rclk                  (aclk_m),
     .src_data              (w_data_async),
     .dst_ready             (w_boundary_dst_ready),
     .wpntr_gry_async       (w_wpntr_gry_async),

     .dst_data              (w_boundary_dst_data),
     .dst_valid             (w_boundary_dst_valid),
     .rpntr_gry_async       (w_rpntr_gry_async),
     .rpntr_bin             (w_rpntr_bin)
     );




  nic400_ib_slave_if0_0_m_ib_d_fifo_wr_sse710_boot_reg
  u_d_fifo_wr
    (
     .wresetn               (aresetn_m),
     .wclk                  (aclk_m),
     .src_valid             (d_boundary_src_valid),
     .src_data              (d_boundary_src_data),
     .rpntr_gry_async       (d_rpntr_gry_async),
     .rpntr_bin             (d_rpntr_bin),

     .src_ready             (d_boundary_src_ready),
     .dst_data              (d_boundary_dst_data),
     .wpntr_gry_async       (d_wpntr_gry_async)
     );






  nic400_ib_slave_if0_0_m_ib_itb_trans_counter_sse710_boot_reg u_itb_trans_counter (
        .avalid_m     (avalid_itb_m),
        .aready_m     (aready_itb_m),
        .dvalid_m     (dvalid_itb_m),
        .dready_m     (dready_itb_m),
        .dbnr_m       (dbnr_itb_m),
        .dlast_m      (dlast_itb_m),
        .tracker_busy (tracker_busy),
        .tracker_full (tracker_full),
        .tracker_empty (tracker_empty),
        .aclk         (aclk_m),
        .aresetn      (aresetn_m)
        );






endmodule
`include "nic400_ib_slave_if0_0_m_ib_undefs_sse710_boot_reg.v"




