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



module reset_controller_f1_core #(
  parameter SOC_RST_DLY   = 3'b111,
  parameter NUM_EXT_SYS   = 2
) (

  input  wire                         clk,
  input  wire                         resetn,

  input  wire                         secenc_cae_rst_req,
  input  wire                         soc_wdog_rst_req,
  input  wire                         secenc_wdog_rst_req,
  input  wire                         cdbgrstreq_dp,
  input  wire                         soc_rst_req,
  input  wire                         secenc_sw_rst_req,
  input  wire                         nsrst,
  input  wire                         csysrstreq_dprom,
  input  wire                         host_sys_rst_req,
  input  wire [NUM_EXT_SYS-1:0]       extsys_rst_req,

  output wire                         aontopporesetn,
  output wire                         aontopwarmresetn,
  output wire                         secporesetn,
  output wire [NUM_EXT_SYS-1:0]       extsysporesetn,

  output wire                         cdbgrstack_dp,
  output wire                         csysrstack_dprom,
  output wire [1:0]                   host_sys_rst_ack,
  output wire [(NUM_EXT_SYS*2)-1:0]   extsys_rst_ack,

  output wire                         secenccpuwait,
  output wire [NUM_EXT_SYS-1:0]       extsyscpuwait,

  output wire [4:0]                   soc_rst_syn,
  output wire [3:0]                   host_rst_syn,
  output wire [(NUM_EXT_SYS*5)-1:0]   extsys_rst_syn,
  output wire [2:0]                   se_rst_syn,
  
  output wire                         aontoppo_aontopwarm_qreqn,
  input  wire                         aontoppo_aontopwarm_qacceptn, 
  input  wire                         aontoppo_aontopwarm_qdeny, 

  output wire                         secenc_hostsys_qreqn,
  input  wire                         secenc_hostsys_qacceptn, 
  input  wire                         secenc_hostsys_qdeny, 

  output wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qreqn,
  input  wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qacceptn, 
  input  wire [NUM_EXT_SYS-1:0]        extsys_hostsys_qdeny 

);


reset_controller_f1_fsm #(
  .SOC_RST_DLY  (SOC_RST_DLY),
  .NUM_EXT_SYS  (NUM_EXT_SYS)
) u_rst_ctlr_fsm
(
 
  .clk                    (clk),
  .resetn                 (resetn),
  
  .secenc_cae_rst_req     (secenc_cae_rst_req),
  .soc_wdog_rst_req       (soc_wdog_rst_req),
  .secenc_wdog_rst_req    (secenc_wdog_rst_req),
  .cdbgrstreq_dp          (cdbgrstreq_dp),
  .soc_rst_req            (soc_rst_req),
  .secenc_sw_rst_req      (secenc_sw_rst_req),
  .nsrst                  (nsrst),
  .csysrstreq_dprom       (csysrstreq_dprom),
  .host_sys_rst_req       (host_sys_rst_req),
  .extsys_rst_req         (extsys_rst_req),

  .aontopporesetn         (aontopporesetn),
  .aontopwarmresetn       (aontopwarmresetn),
  .secporesetn            (secporesetn),
  .extsysporesetn         (extsysporesetn),

  .cdbgrstack_dp          (cdbgrstack_dp),
  .csysrstack_dprom       (csysrstack_dprom),
  .host_sys_rst_ack       (host_sys_rst_ack),
  .extsys_rst_ack         (extsys_rst_ack),

  .secenccpuwait          (secenccpuwait),
  .extsyscpuwait          (extsyscpuwait),

  .soc_rst_syn            (soc_rst_syn),
  .host_rst_syn           (host_rst_syn),
  .extsys_rst_syn         (extsys_rst_syn),
  .se_rst_syn             (se_rst_syn),

  .aontoppo_aontopwarm_qreqn    (aontoppo_aontopwarm_qreqn),
  .aontoppo_aontopwarm_qacceptn (aontoppo_aontopwarm_qacceptn),
  .aontoppo_aontopwarm_qdeny    (aontoppo_aontopwarm_qdeny),

  .secenc_hostsys_qreqn         (secenc_hostsys_qreqn   ),
  .secenc_hostsys_qacceptn      (secenc_hostsys_qacceptn),
  .secenc_hostsys_qdeny         (secenc_hostsys_qdeny   ),
                                                        
  .extsys_hostsys_qreqn         (extsys_hostsys_qreqn   ),
  .extsys_hostsys_qacceptn      (extsys_hostsys_qacceptn),
  .extsys_hostsys_qdeny         (extsys_hostsys_qdeny   )

);

endmodule


