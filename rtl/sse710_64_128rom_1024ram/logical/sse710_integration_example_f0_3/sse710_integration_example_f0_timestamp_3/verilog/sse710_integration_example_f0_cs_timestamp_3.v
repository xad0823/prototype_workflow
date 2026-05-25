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

module sse710_integration_example_f0_cs_timestamp_gen(
  input  wire           refclk,
  input  wire           dbgtop_warmresetn_s,

 
  
  output wire [3:0]     extsys0_nts_wr_ptr_encd_gry,
  input  wire [3:0]     extsys0_nts_rd_ptr_encd_gry,
  output wire [3:0]     extsys0_nts_wr_ptr_sync_gry,
  input  wire [3:0]     extsys0_nts_rd_ptr_sync_gry,
  output wire [53:0]    extsys0_nts_fw_data,
  output wire           extsys0_nts_s_lp,
  input  wire           extsys0_nts_s_lp_return,
  input  wire           extsys0_nts_m_lp,
  
  input  wire           extsys0_nts_qreqn,
  output wire           extsys0_nts_qacceptn,
  output wire           extsys0_nts_qdeny,
  output wire           extsys0_nts_qactive,
 
  
  output wire [3:0]     extsys1_nts_wr_ptr_encd_gry,
  input  wire [3:0]     extsys1_nts_rd_ptr_encd_gry,
  output wire [3:0]     extsys1_nts_wr_ptr_sync_gry,
  input  wire [3:0]     extsys1_nts_rd_ptr_sync_gry,
  output wire [53:0]    extsys1_nts_fw_data,
  output wire           extsys1_nts_s_lp,
  input  wire           extsys1_nts_s_lp_return,
  input  wire           extsys1_nts_m_lp,
  
  input  wire           extsys1_nts_qreqn,
  output wire           extsys1_nts_qacceptn,
  output wire           extsys1_nts_qdeny,
  output wire           extsys1_nts_qactive,
 
  
  output wire [63:0]    host_tsvalueb
  );

  
  reg [63:0] reg_host_tsvalueb; 
  
  wire tsforcesync;

  
  wire [6:0] tsbit_extsys0;
  wire [1:0] tssync_extsys0;
  wire       tssyncready_m_extsys0;  
  
  wire [6:0] tsbit_extsys1;
  wire [1:0] tssync_extsys1;
  wire       tssyncready_m_extsys1;  
 

  
  always @(posedge refclk or negedge dbgtop_warmresetn_s)
  begin 
  if (~dbgtop_warmresetn_s)
    reg_host_tsvalueb <= {64{1'b0}};
  else
    reg_host_tsvalueb <= reg_host_tsvalueb + 64'b1;
  end

  assign host_tsvalueb = reg_host_tsvalueb;
  
  assign tsforcesync   = &reg_host_tsvalueb;
  

 
  css600_ntsencoder  #(
    .RESYNC_THRESHOLD   (8)
  ) u_css600_ntsencoder_extsys0 (
    .clk              (refclk),
    .reset_n          (dbgtop_warmresetn_s),
    .tsvalue_b_s      (reg_host_tsvalueb),
    .tsforcesync_s    (tsforcesync),
    .tsbit_m          (tsbit_extsys0),
    .tssync_m         (tssync_extsys0),
    .tssyncready_m    (tssyncready_m_extsys0)
  );
 
  css600_ntsencoder  #(
    .RESYNC_THRESHOLD   (8)
  ) u_css600_ntsencoder_extsys1 (
    .clk              (refclk),
    .reset_n          (dbgtop_warmresetn_s),
    .tsvalue_b_s      (reg_host_tsvalueb),
    .tsforcesync_s    (tsforcesync),
    .tsbit_m          (tsbit_extsys1),
    .tssync_m         (tssync_extsys1),
    .tssyncready_m    (tssyncready_m_extsys1)
  );
 

 

  css600_ntsasyncbridgeslv #(
    .FF_SYNC_DEPTH (2),
    .THRESHOLD     (8)
  ) u_css600_ntsasyncbridgeslv_extsys0 (
    .clk_s                   (refclk),
    .reset_s_n               (dbgtop_warmresetn_s),
    .tsbit_s                 (tsbit_extsys0),
    .tssync_s                (tssync_extsys0),
    .tssyncready_s           (tssyncready_m_extsys0),
    .clk_s_qreq_n            (1'b1),
    .clk_s_qaccept_n         (),
    .clk_s_qactive           (),
    .pwr_qreq_n              (extsys0_nts_qreqn),
    .pwr_qaccept_n           (extsys0_nts_qacceptn),
    .wr_ptr_encd_gry         (extsys0_nts_wr_ptr_encd_gry),
    .rd_ptr_encd_gry         (extsys0_nts_rd_ptr_encd_gry),
    .wr_ptr_sync_gry         (extsys0_nts_wr_ptr_sync_gry),
    .rd_ptr_sync_gry         (extsys0_nts_rd_ptr_sync_gry),
    .nts_fw_data             (extsys0_nts_fw_data),
    .s_lp                    (extsys0_nts_s_lp),
    .s_lp_return             (extsys0_nts_s_lp_return),
    .m_lp                    (extsys0_nts_m_lp)
    );
  
  assign extsys0_nts_qdeny   = 1'b0;
  assign extsys0_nts_qactive = 1'b0;  
 

  css600_ntsasyncbridgeslv #(
    .FF_SYNC_DEPTH (2),
    .THRESHOLD     (8)
  ) u_css600_ntsasyncbridgeslv_extsys1 (
    .clk_s                   (refclk),
    .reset_s_n               (dbgtop_warmresetn_s),
    .tsbit_s                 (tsbit_extsys1),
    .tssync_s                (tssync_extsys1),
    .tssyncready_s           (tssyncready_m_extsys1),
    .clk_s_qreq_n            (1'b1),
    .clk_s_qaccept_n         (),
    .clk_s_qactive           (),
    .pwr_qreq_n              (extsys1_nts_qreqn),
    .pwr_qaccept_n           (extsys1_nts_qacceptn),
    .wr_ptr_encd_gry         (extsys1_nts_wr_ptr_encd_gry),
    .rd_ptr_encd_gry         (extsys1_nts_rd_ptr_encd_gry),
    .wr_ptr_sync_gry         (extsys1_nts_wr_ptr_sync_gry),
    .rd_ptr_sync_gry         (extsys1_nts_rd_ptr_sync_gry),
    .nts_fw_data             (extsys1_nts_fw_data),
    .s_lp                    (extsys1_nts_s_lp),
    .s_lp_return             (extsys1_nts_s_lp_return),
    .m_lp                    (extsys1_nts_m_lp)
    );
  
  assign extsys1_nts_qdeny   = 1'b0;
  assign extsys1_nts_qactive = 1'b0;  
 

endmodule

