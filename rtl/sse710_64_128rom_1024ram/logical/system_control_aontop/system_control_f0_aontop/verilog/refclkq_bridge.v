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
module refclkq_bridge (

  input wire                  clk,
  input wire                  ctrl_resetn_sync,
  input wire                  dev_resetn_sync,
                                
  input wire                  ctrl_qreqn_i,
  output wire                 ctrl_qacceptn_o,
  output wire                 ctrl_qdeny_o,

  output wire                 dev_qreqn_o,
  input wire                  dev_qacceptn_i,
  input wire                  dev_qdeny_i
);


  reg dev_reset_status;
  reg [1:0] dev_qacceptn_delay;
  reg [1:0] dev_qdeny_delay;
  
  wire dev_qacceptn_ss;
  wire dev_qdeny_ss;
  
  wire dev_reset_status_ss;
  
  wire ctrl_qreqn_ss;
  
  always @(posedge clk or negedge dev_resetn_sync)
  begin
    if(dev_resetn_sync == 1'b0)
        dev_reset_status<=1'b1;
    else
        dev_reset_status<=1'b0;
  end
  
  arm_element_cdc_capt_sync u_dev_reset_status_ss   
  ( 
      .clk(clk), 
      .nreset(ctrl_resetn_sync),   
      .d_async(dev_reset_status), 
      .q(dev_reset_status_ss) 
  );

  arm_element_cdc_capt_sync u_dev_acceptn_i_ss
  ( 
      .clk(clk), 
      .nreset(ctrl_resetn_sync),   
      .d_async(dev_qacceptn_i), 
      .q(dev_qacceptn_ss) 
  );  
  arm_element_cdc_capt_sync u_ctrl_deny_o_ss   
  ( 
      .clk(clk), 
      .nreset(ctrl_resetn_sync),   
      .d_async(dev_qdeny_i), 
      .q(dev_qdeny_ss) 
  );
        
  always @(posedge clk or negedge ctrl_resetn_sync)
  begin
    if(ctrl_resetn_sync == 1'b0)
    begin
        dev_qdeny_delay<=2'd0;
        dev_qacceptn_delay <=2'd0;
    end
    else
    begin
        dev_qacceptn_delay[1]<=dev_qacceptn_ss;
        dev_qacceptn_delay[0]<=dev_qacceptn_delay[1];
        
        dev_qdeny_delay[1]<=dev_qdeny_ss;
        dev_qdeny_delay[0]<=dev_qdeny_delay[1];
    end
  end
  
  
  sse710_q_ch_bridge u_clkqbridge
  (
    .clk                  (clk),
    .resetn               (ctrl_resetn_sync),  
                          
    .ctrl_qreqn_i         (ctrl_qreqn_ss),
    .ctrl_pstate_i        (4'b0000),
    .ctrl_qacceptn_o      (ctrl_qacceptn_o),
    .ctrl_qdeny_o         (ctrl_qdeny_o),
                          
    .dev_qreqn_o          (dev_qreqn_o),
    .dev_qacceptn_i       (dev_qacceptn_delay[0]),
    .dev_qdeny_i          (dev_qdeny_delay[0]),

    .standbywfi_i         (1'b1),
    .dbgrstreq_i          (1'b0),
                          
    .dev_reset_status_i   (dev_reset_status_ss),

    .cpuwait_o            ()
  );
  
  
  arm_element_cdc_capt_sync u_ctrl_qreqn_ss   
  ( 
      .clk(clk), 
      .nreset(ctrl_resetn_sync),   
      .d_async(ctrl_qreqn_i), 
      .q(ctrl_qreqn_ss) 
  );
  
endmodule
