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



module nic400_rsb_slave_sse710_main
  (
   rclk,
   rresetn,

   rsb_data_s,
   rsb_valid_s,
   rsb_ready_s,
  
   rsb_data_m,
   rsb_valid_m,
   rsb_ready_m,

   psel,
   penable,
   pwrite,
   paddr,
   pwdata,
   prdata,
   pready,
   pslverr

   );


  parameter ADN_VALUE = 0;

  parameter NUM_ADDRESSES = 2;

  parameter BADN_VALUE_1 = 0;   
  
  input                   rclk;         
  input                   rresetn;      

  input             [7:0] rsb_data_s;
  input                   rsb_valid_s;
  output                  rsb_ready_s;
  
  output            [7:0] rsb_data_m;
  output                  rsb_valid_m;
  input                   rsb_ready_m;

  output                  psel;
  output                  penable;
  output                  pwrite;
  output           [31:0] paddr;
  output           [31:0] pwdata;
  input            [31:0] prdata;
  input                   pready;
  input                   pslverr;



  wire                  apb_done;
  wire                  bcast_addr;
  wire            [7:0] rsb_data_apb;
  wire            [7:0] rsb_data_done;
  wire            [7:0] rsb_data_pass;
  wire                  rsb_ready_apb;
  wire                  rsb_ready_done;
  wire                  rsb_ready_pass;
  wire                  rsb_valid_apb;
  wire                  rsb_valid_done;
  wire                  rsb_valid_pass;
  

  nic400_rsb_s_decode_sse710_main
    #(ADN_VALUE, NUM_ADDRESSES, BADN_VALUE_1)
  u_rsb_s_decode
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_s                        (rsb_data_s),
     .rsb_valid_s                       (rsb_valid_s),
     .rsb_ready_s                       (rsb_ready_s),
     .rsb_data_pass                     (rsb_data_pass),
     .rsb_valid_pass                    (rsb_valid_pass),
     .rsb_ready_pass                    (rsb_ready_pass),
     .rsb_data_apb                      (rsb_data_apb),
     .rsb_valid_apb                     (rsb_valid_apb),
     .rsb_ready_apb                     (rsb_ready_apb),
     .bcast_addr                        (bcast_addr),
     .apb_done                          (apb_done));

  nic400_rsb_s_format_sse710_main
  u_rsb_s_format
    (
     .rclk                              (rclk),
     .rresetn                           (rresetn),
     .rsb_data_apb                      (rsb_data_apb),
     .rsb_valid_apb                     (rsb_valid_apb),
     .rsb_ready_apb                     (rsb_ready_apb),
     .rsb_data_done                     (rsb_data_done),
     .rsb_valid_done                    (rsb_valid_done),
     .rsb_ready_done                    (rsb_ready_done),
     .psel                              (psel),
     .penable                           (penable),
     .pwrite                            (pwrite),
     .paddr                             (paddr),
     .pwdata                            (pwdata),
     .prdata                            (prdata),
     .pready                            (pready),
     .pslverr                           (pslverr),
     .bcast_addr                        (bcast_addr),
     .apb_done                          (apb_done));
    
  nic400_rsb_s_arbiter_sse710_main
  u_rsb_s_arbiter
    (
     .rsb_data_pass                     (rsb_data_pass),
     .rsb_valid_pass                    (rsb_valid_pass),
     .rsb_ready_pass                    (rsb_ready_pass),
     .rsb_data_done                     (rsb_data_done),
     .rsb_valid_done                    (rsb_valid_done),
     .rsb_ready_done                    (rsb_ready_done),
     .rsb_data_m                        (rsb_data_m),
     .rsb_valid_m                       (rsb_valid_m),
     .rsb_ready_m                       (rsb_ready_m));
    

endmodule 


