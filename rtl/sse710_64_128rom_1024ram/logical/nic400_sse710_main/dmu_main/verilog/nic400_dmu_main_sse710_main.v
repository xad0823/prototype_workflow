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




`include "nic400_dmu_main_defs_sse710_main.v"

module nic400_dmu_main_sse710_main
  (
    gpvmain_ahb_cactive,

    gpvmain_ahb_cactive_wakeup,

    gpvmain_ahb_port_enable,

    cd_main_clk,
    cd_main_resetn,
    cd_main_cactive

  );


  

  input               gpvmain_ahb_cactive;             


  input               gpvmain_ahb_cactive_wakeup;      


  output              gpvmain_ahb_port_enable;         


  input               cd_main_clk;                     
  input               cd_main_resetn;                  
  output              cd_main_cactive;                 



  wire          gpvmain_ahb_cactive;
  wire          gpvmain_ahb_cactive_wakeup;
  wire          domain_active;
  wire          cactive_wakeup;
  wire          cactive_ot;

  
  wire          port_enable_reg;
  




  assign cactive_ot = (gpvmain_ahb_cactive); 

  

  assign cactive_wakeup = gpvmain_ahb_cactive_wakeup;
  
  nic400_cdc_comb_or2_sse710_main u_nic400_cdc_comb_or2_sse710_main (
       .din1_async       (cactive_ot),
       .din2_async       (cactive_wakeup),
       .dout_async       (domain_active)
   );
    
  assign cd_main_cactive     = domain_active;  

  assign port_enable_reg = 1'b1;
  

  assign gpvmain_ahb_port_enable = port_enable_reg;

endmodule

`include "nic400_dmu_main_undefs_sse710_main.v"



