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




module nic400_rsb_master_gpv_0_sse710_main
  (
   rclk,
   rresetn,
   awrite,
   aid,
   aaddr,
   alen,
   asize,
   alock,
   aburst,
   acache,
   aprot,
   avalid,
   aready,
   dbnr,
   did,
   ddata,
   dresp,
   dlast,
   dvalid,
   dready,
   wdata,
   wstrb,
   wlast,
   wvalid,
   wready,

   rsb_data_s,
   rsb_valid_s,
   rsb_ready_s,
  
   rsb_data_m,
   rsb_valid_m,
   rsb_ready_m
   );

  parameter MID_VALUE = 0;
  parameter ID_WIDTH = 12;

  parameter ADR_LENGTH = 2;
  parameter DAT_LENGTH = 4;

  parameter ID_MAX = ID_WIDTH - 1;

  input                   rclk;         
  input                   rresetn;      
  input                   awrite;       
  input        [ID_MAX:0] aid;          
  input            [31:0] aaddr;        
  input          [7:0]    alen;         
  input             [2:0] asize;        
  input             [1:0] aburst;       
  input                   alock;        
  input             [3:0] acache;       
  input             [2:0] aprot;        
  input                   avalid;       
  output                  aready;       
  output                  dbnr;         
  output       [ID_MAX:0] did;          
  output           [31:0] ddata;        
  output            [1:0] dresp;        
  output                  dlast;        
  output                  dvalid;       
  input                   dready;       
  
  input            [31:0] wdata;        
  input             [3:0] wstrb;        
  input                   wlast;        
  input                   wvalid;       
  output                  wready;       
  input             [7:0] rsb_data_s;
  input                   rsb_valid_s;
  output                  rsb_ready_s;
  
  output            [7:0] rsb_data_m;
  output                  rsb_valid_m;
  input                   rsb_ready_m;


   
  

  wire              [7:0] rsb_data_pass;
  wire                    rsb_valid_pass;
  wire                    rsb_ready_pass;

  wire              [7:0] rsb_data_new;
  wire                    rsb_valid_new;
  wire                    rsb_ready_new;

  wire                    tx_done;

  wire                    tx_last;
  
  wire         [ID_MAX:0] tx_id;
  
  wire                    wlast_strbless;



  nic400_rsb_m_decode_sse710_main
    #(MID_VALUE,ADR_LENGTH,DAT_LENGTH)
  u_rsb_m_decode
    (
     .rclk            (rclk),
     .rresetn         (rresetn),

     .rsb_data_s      (rsb_data_s),
     .rsb_valid_s     (rsb_valid_s),
     .rsb_ready_s     (rsb_ready_s),

     .rsb_data_pass   (rsb_data_pass),
     .rsb_valid_pass  (rsb_valid_pass),
     .rsb_ready_pass  (rsb_ready_pass),

     .wlast_strbless  (wlast_strbless),

     .tx_done         (tx_done),

     .tx_last         (tx_last),

     .dbnr            (dbnr),
     .ddata           (ddata),
     .dresp           (dresp),
     .dlast           (dlast),
     .dvalid          (dvalid),
     .dready          (dready)
     );

  assign did = tx_id;

  nic400_rsb_m_format_gpv_0_sse710_main
    #(MID_VALUE, ID_WIDTH)
  u_rsb_m_format_gpv_0
    (
     .rclk            (rclk),
     .rresetn         (rresetn),

     .awrite          (awrite),
     .aid             (aid),
     .aaddr           (aaddr),
     .alen            (alen),
     .asize           (asize),
     .alock           (alock),
     .aburst          (aburst),
     .acache          (acache),
     .aprot           (aprot),
     .avalid          (avalid),
     .aready          (aready),
     .wdata           (wdata),
     .wstrb           (wstrb),
     .wlast           (wlast),
     .wvalid          (wvalid),
     .wready          (wready),

     .tx_done         (tx_done),

     .tx_last         (tx_last),

     .tx_id           (tx_id),

     .rsb_data_new    (rsb_data_new),
     .rsb_valid_new   (rsb_valid_new),
     .rsb_ready_new   (rsb_ready_new),

     .wlast_strbless  (wlast_strbless)
     );
  
  nic400_rsb_m_arbiter_sse710_main
  u_rsb_m_arbiter
    (
     .rclk            (rclk),
     .rresetn         (rresetn),

     .rsb_data_pass   (rsb_data_pass),
     .rsb_valid_pass  (rsb_valid_pass),
     .rsb_ready_pass  (rsb_ready_pass),

     .rsb_data_new    (rsb_data_new),
     .rsb_valid_new   (rsb_valid_new),
     .rsb_ready_new   (rsb_ready_new),

     .rsb_data_m      (rsb_data_m),
     .rsb_valid_m     (rsb_valid_m),
     .rsb_ready_m     (rsb_ready_m)
     );


endmodule  

