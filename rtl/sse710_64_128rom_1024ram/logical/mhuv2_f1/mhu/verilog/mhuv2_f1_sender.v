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

module mhuv2_f1_sender
#(
   parameter [6:0] MHU_NUM_CH        = 7'd1
 )(

  input  wire                       pclk_snd,
  input  wire                       presetn_snd,

  output  wire                      apb_async_req,
  output  wire [48:0]               apb_async_req_payload,
  input   wire [32:0]               apb_async_resp_payload,
  input   wire                      apb_async_ack,
  input   wire                      recawake_async,
  output  wire                      recwakeup_async,

  input   wire                      pwakeup_snd,
  input   wire   [31:0]             paddr_snd,
  input   wire                      pwrite_snd,
  input   wire   [31:0]             pwdata_snd,
  input   wire                      penable_snd,
  input   wire                      pselx_snd,
  output  wire   [31:0]             prdata_snd,
  output  wire                      pready_snd,
  output  wire                      pslverr_snd,

  input   wire                      qreqn_pclk_snd,
  output  wire                      qacceptn_pclk_snd,
  output  wire                      qdeny_pclk_snd,
  output  wire                      qactive_pclk_snd,

  output  wire                      int_access_nr2r,
  output  wire                      int_access_r2nr,
  output wire                       int_irqcomb,

  input  wire  [MHU_NUM_CH-1:0]   edge_async_req,
  output wire  [MHU_NUM_CH-1:0]   edge_async_ack,

  input   wire                      dftcgen

 );



  wire  [1:1]         config_checker_0;

  wire                ctrl_addr;
  wire                ctrl_sel;
  wire                channel_sel;

  wire                access_select;
  wire                channel_access_r;
  wire                channel_access_s;
  wire                err_resp_access;

  wire                access_ready;
  wire                access_request;

  wire                pready_fromadb;
  wire                pready_fromerb;
  wire                pslverr_fromadb;
  wire                pslverr_fromerb;
  wire [31:0]         prdata_fromadb;
  wire [31:0]         prdata_fromerb;
  reg  [31:0]         prdata_fromctrl;
  wire [31:0]         prdata_fromctrl_nxt;

  reg                 pready_mux;
  reg                 pslverr_mux;
  reg [31:0]          prdata_mux;

  wire [11:0]         addr_ctrl;
  wire                write_en_ctrl;
  wire                read_en;
  wire                resp_cfg;

  wire  [31:0]        rdata_mhu_reg;
  wire  [31:0]        rdata_msg_no_cap;
  wire  [31:0]        rdata_pid_0;
  wire  [31:0]        rdata_pid_1;
  wire  [31:0]        rdata_pid_2;
  wire  [31:0]        rdata_pid_3;
  wire  [31:0]        rdata_pid_4;
  wire  [31:0]        rdata_compid_0;
  wire  [31:0]        rdata_compid_1;
  wire  [31:0]        rdata_compid_2;
  wire  [31:0]        rdata_compid_3;
  wire  [31:0]        rdata_iidr;
  wire  [31:0]        rdata_aidr;
  wire  [3:0]         sreg_pid2;
  wire  [3:0]         sreg_pid3;

  wire                pclks_clken;
  wire                en_clk;
  wire                clk_request_snd;
  wire                recawake_async_sss;
  wire                recawake_async_ssss;
  wire                clk_request_edge;
  wire                pclksqreqn_ss;
  wire                clk_comb_request;

  wire                clk_qactive_pclk_snd;
  wire                ctrl_qactive_pclk_snd;

  wire                    edge_qreqn_pclk_snd;
  wire                    edge_qacceptn_pclk_snd;
  wire                    edge_qactive_pclk_snd;
  wire [MHU_NUM_CH-1:0] edge_pulse_snd;

  wire [21:0]         unused_addr;
  wire [3:0]          pstrb_snd;

  assign config_checker_0[((MHU_NUM_CH > 7'd0) & (MHU_NUM_CH < 7'd125) )] = 1'b1;


  assign ctrl_addr    = (paddr_snd[11:7] == 5'b11111) ? 1'b1 : 1'b0;
  assign ctrl_sel     = ctrl_addr ? pselx_snd : 1'b0;
  assign channel_sel  = ctrl_addr ? 1'b0 : pselx_snd;

  
  assign access_select      = access_ready & access_request;
  
  assign channel_access_r   = access_select & channel_sel & (paddr_snd[4] == 1'b0);
  
  assign channel_access_s   = channel_sel & (paddr_snd[4] == 1'b1);
  
  assign err_resp_access    = (~access_select) & (channel_sel & (paddr_snd[4] == 1'b0));


  assign pready_snd   = pready_mux  & qacceptn_pclk_snd;
  assign pslverr_snd  = pslverr_mux & pready_snd & penable_snd;
  assign prdata_snd   = prdata_mux;

  always @(*)
  begin
    case({err_resp_access, channel_access_r, channel_access_s, ctrl_sel})
      4'b0000,
      4'b0011,
      4'b0101,
      4'b0110,
      4'b0111,
      4'b1001,
      4'b1010,
      4'b1011,
      4'b1100,
      4'b1101,
      4'b1110,
      4'b1111:  pready_mux  = 1'b0;
      4'b0001:  pready_mux  = 1'b1;
      4'b0010:  pready_mux  = 1'b1;
      4'b0100:  pready_mux  = pready_fromadb;
      4'b1000:  pready_mux  = pready_fromerb;
      default: pready_mux  = 1'bx;
    endcase
  end

  always @(*)
    begin
    case({err_resp_access, channel_access_r, channel_access_s, ctrl_sel})
      4'b0000,
      4'b0011,
      4'b0101,
      4'b0110,
      4'b0111,
      4'b1001,
      4'b1010,
      4'b1011,
      4'b1100,
      4'b1101,
      4'b1110,
      4'b1111:  pslverr_mux  = 1'b0;
      4'b0001:  pslverr_mux  = 1'b0;
      4'b0010:  pslverr_mux  = 1'b0;
      4'b0100:  pslverr_mux  = pslverr_fromadb;
      4'b1000:  pslverr_mux  = pslverr_fromerb;
      default: pslverr_mux  = 1'bx;
    endcase
  end

  always @(*)
  begin
    case({err_resp_access, channel_access_r, channel_access_s, ctrl_sel})
      4'b0000,
      4'b0011,
      4'b0101,
      4'b0110,
      4'b0111,
      4'b1001,
      4'b1010,
      4'b1011,
      4'b1100,
      4'b1101,
      4'b1110,
      4'b1111:  prdata_mux  = {32{1'b0}};
      4'b0001:  prdata_mux  = prdata_fromctrl;
      4'b0010:  prdata_mux  = prdata_fromctrl;
      4'b0100:  prdata_mux  = prdata_fromadb;
      4'b1000:  prdata_mux  = prdata_fromerb;
      default: prdata_mux  = {32{1'bx}};
    endcase
  end


  mhuv2_f1_adb_apb3_slv u_mhuv2_f1_adb_apb3_slv  (
    .pclk                     (pclk_snd),
    .presetn                  (presetn_snd),
    .dftcgen                  (dftcgen),
    .psel_adb_i               (channel_access_r),
    .penable_i                (penable_snd),
    .paddr_i                  (paddr_snd[11:0]),
    .pwrite_i                 (pwrite_snd),
    .pwdata_i                 (pwdata_snd),
    .pstrb_i                  (pstrb_snd),
    .prdata_o                 (prdata_fromadb),
    .pready_o                 (pready_fromadb),
    .pslverr_o                (pslverr_fromadb),
    .recawake_async_sss_o     (recawake_async_sss),
    .recawake_async_ssss_o    (recawake_async_ssss),
    .apb_async_req_o          (apb_async_req),
    .apb_async_req_payload_o  (apb_async_req_payload),
    .apb_async_resp_payload_i (apb_async_resp_payload),
    .apb_async_ack_i          (apb_async_ack),
    .recawake_async_i         (recawake_async),
    .recawake_async_ss_o      (access_ready),
    .pwakeup_i                (pwakeup_snd),
    .clk_request_o            (clk_request_snd),
    .en_clk_i                 (en_clk),
    .pclks_clken_i            (pclks_clken)
  );

  assign recwakeup_async  = access_request;


  mhuv2_f1_adb_posedge_master #(
    .WIDTH(MHU_NUM_CH)
  )u_mhuv2_f1_adb_posedge_master (
    .CLK                      (pclk_snd),
    .RESETn                   (presetn_snd),
    .EDGEREQASYNC             (edge_async_req),
    .EDGEACKASYNC             (edge_async_ack),
    .EDGESYNC                 (edge_pulse_snd),
    .CLKEN                    (en_clk),
    .CLKREQUEST               (clk_request_edge)
  );

 mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_pclksqreqn
  (
    .CLK    (pclk_snd),
    .RESETn (presetn_snd),
    .ASYNC  (qreqn_pclk_snd),
    .SYNC   (pclksqreqn_ss)
  );

  assign clk_comb_request = (clk_request_snd | clk_request_edge);

  mhuv2_f1_adb_apb3_q_channel
  u_mhuv2_f1_snd_qch_clk
  (
    .pclk       (pclk_snd),
    .presetn    (presetn_snd),
    .qreqn_i    (pclksqreqn_ss),
    .qacceptn_o (qacceptn_pclk_snd),
    .qdeny_o    (qdeny_pclk_snd),
    .request_i  (clk_comb_request),
    .en_o       (en_clk),
    .clken_o    (pclks_clken)
  );

  mhuv2_f1_adb_apb3_slv_async #(
    .MHU_NUM_CH           (MHU_NUM_CH)
  ) u_mhuv2_f1_adb_apb3_slv_async
  (
    .recawake_async_i       (recawake_async),
    .recawake_async_sss_i   (recawake_async_sss),
    .recawake_async_ssss_i  (recawake_async_ssss),
    .pwakeup_i              (pwakeup_snd),
    .edge_async_req_i       (edge_async_req),
    .pclksqactive_o         (qactive_pclk_snd)
  );


  assign pslverr_fromerb  = resp_cfg;
  assign pready_fromerb   = 1'b1;
  assign prdata_fromerb   = 32'b0;


  assign  addr_ctrl       = {paddr_snd[11:2], 2'b0};
  assign  write_en_ctrl   = (ctrl_sel|channel_sel) & pwrite_snd & pstrb_snd[0] & penable_snd;
  assign  read_en         = (ctrl_sel|channel_sel) & (~pwrite_snd) & pstrb_snd[0];

  mhuv2_f1_snd_mhu_reg  #(
    .MHU_NUM_CH(MHU_NUM_CH))
    u_mhuv2_f1_snd_mhu_reg (

    .pclk                               (pclk_snd),
    .presetn                            (presetn_snd),
    .sel_i                              (ctrl_sel),
    .addr_i                             (addr_ctrl),
    .write_en_i                         (write_en_ctrl),
    .read_en_i                          (read_en),
    .wdata_i                            (pwdata_snd[2:0]),
    .rdata_o                            (rdata_mhu_reg),
    .access_rdy_i                       (access_ready),
    .int_access_nr2r_o                  (int_access_nr2r),
    .int_access_r2nr_o                  (int_access_r2nr),
    .resp_cfg_o                         (resp_cfg),
    .access_req_o                       (access_request),
    .edge_pulse_i                       (edge_pulse_snd),
    .channel_sel_i                      (channel_sel & paddr_snd[4]), 
    .int_irqcomb_o                      (int_irqcomb)
  );

  mhuv2_f1_static_reg
  #(
    .WIDTH        (4)
  )
  u_mhuv2_f1_static_reg_pid2_snd  (
    .clk          (pclk_snd),
    .reset_n      (presetn_snd),
    .static_i     (4'b0000),
    .static_o     (sreg_pid2)
  );

  mhuv2_f1_static_reg
  #(
    .WIDTH        (4)
  )
  u_mhuv2_f1_static_reg_pid3_snd  (
    .clk          (pclk_snd),
    .reset_n      (presetn_snd),
    .static_i     (4'b0000),
    .static_o     (sreg_pid3)
  );

  assign  rdata_msg_no_cap[31:7]  = {25{1'b0}};
  assign  rdata_msg_no_cap[6:0]   = (addr_ctrl == 12'hf80)& ctrl_sel? MHU_NUM_CH[6:0]: {7{1'b0}};

  assign  rdata_iidr      = (addr_ctrl == 12'hfc8)& ctrl_sel? {12'h076,sreg_pid2, sreg_pid3, 12'h43b}: {32{1'b0}};
  assign  rdata_aidr      = (addr_ctrl == 12'hfcc)& ctrl_sel? 32'h0000_0011: {32{1'b0}};

  assign  rdata_pid_0     = (addr_ctrl == 12'hfe0)& ctrl_sel? 32'h0000_0076: {32{1'b0}};
  assign  rdata_pid_1     = (addr_ctrl == 12'hfe4)& ctrl_sel? 32'h0000_00b0: {32{1'b0}};
  assign  rdata_pid_2     = (addr_ctrl == 12'hfe8)& ctrl_sel? {24'h0000_00,sreg_pid2,4'hb}: {32{1'b0}};
  assign  rdata_pid_3     = (addr_ctrl == 12'hfec)& ctrl_sel? {24'h0000_00,sreg_pid3,4'h0}: {32{1'b0}};
  assign  rdata_pid_4     = (addr_ctrl == 12'hfd0)& ctrl_sel? 32'h0000_0004: {32{1'b0}};

  assign  rdata_compid_0  = (addr_ctrl == 12'hff0)& ctrl_sel? 32'h0000_000d: {32{1'b0}};
  assign  rdata_compid_1  = (addr_ctrl == 12'hff4)& ctrl_sel? 32'h0000_00f0: {32{1'b0}};
  assign  rdata_compid_2  = (addr_ctrl == 12'hff8)& ctrl_sel? 32'h0000_0005: {32{1'b0}};
  assign  rdata_compid_3  = (addr_ctrl == 12'hffc)& ctrl_sel? 32'h0000_00b1: {32{1'b0}};

  assign prdata_fromctrl_nxt = rdata_mhu_reg     |
                               rdata_msg_no_cap  |
                               rdata_pid_4       |
                               rdata_pid_0       |
                               rdata_pid_1       |
                               rdata_pid_2       |
                               rdata_pid_3       |
                               rdata_compid_0    |
                               rdata_compid_1    |
                               rdata_compid_2    |
                               rdata_compid_3    |
                               rdata_iidr        |
                               rdata_aidr;

  always @(posedge pclk_snd or negedge presetn_snd)
    if(!presetn_snd)
      prdata_fromctrl <=  32'b0000_0000;
    else if(pselx_snd)
      prdata_fromctrl <= prdata_fromctrl_nxt;


  assign unused_addr  = {paddr_snd[31:12], paddr_snd[1:0]};


  assign pstrb_snd = 4'b1111;

endmodule
