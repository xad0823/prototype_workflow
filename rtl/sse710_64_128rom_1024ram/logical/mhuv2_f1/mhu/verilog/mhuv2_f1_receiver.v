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

module mhuv2_f1_receiver
#(
   parameter [6:0] MHU_NUM_CH        = 7'd1
 )(

  input  wire                        pclk_rec,
  input  wire                        presetn_rec,

  input  wire                        apb_async_req,
  input  wire  [48:0]                apb_async_req_payload,
  output wire  [32:0]                apb_async_resp_payload,
  output wire                        apb_async_ack,
  output wire                        recawake_async,
  input wire                         recwakeup_async,

  input wire                         pwakeup_rec,
  input wire   [31:0]                paddr_rec,
  input wire                         pwrite_rec,
  input wire   [31:0]                pwdata_rec,
  input wire                         penable_rec,
  input wire                         pselx_rec,
  output wire  [31:0]                prdata_rec,
  output wire                        pready_rec,
  output wire                        pslverr_rec,

  input  wire                        qreqn_pclk_rec,
  output wire                        qacceptn_pclk_rec,
  output wire                        qdeny_pclk_rec,
  output wire                        qactive_pclk_rec,

  input  wire                        qreqn_pwr_rec,
  output wire                        qacceptn_pwr_rec,
  output wire                        qdeny_pwr_rec,

  output wire                        mhu_irqcomb,
  output wire   [MHU_NUM_CH-1:0]   mhu_irq_reg,

  output wire   [MHU_NUM_CH-1:0]   edge_async_req,
  input  wire   [MHU_NUM_CH-1:0]   edge_async_ack,

  input wire                         dftcgen

 );


  wire  [1:1]                 config_checker_0;

  wire  [11:0]                paddr_fromsnd;
  wire                        pwrite_fromsnd;
  wire  [31:0]                pwdata_fromsnd;
  wire  [3:0]                 pstrb_fromsnd;
  wire                        penable_fromsnd;
  wire                        pselx_fromsnd;
  wire  [31:0]                prdata_fromsnd;
  wire                        pready_fromsnd;
  wire                        pslverr_fromsnd;

  wire  [11:0]                addr_snd;
  wire  [3:0]                 writeen_snd;
  wire  [11:0]                addr_rec;
  wire  [3:0]                 writeen_rec;

  wire  [31:0]                rdata_sndreg      [MHU_NUM_CH-1:0];
  wire  [31:0]                rdata_sndreg_ored [MHU_NUM_CH-1:0];
  wire  [31:0]                rdata_recreg      [MHU_NUM_CH-1:0];
  wire  [31:0]                rdata_recreg_ored [MHU_NUM_CH-1:0];

  wire  [MHU_NUM_CH-1:0]    reg_irq;

  wire  [31:0]                rdata_msg_no_cap;
  wire  [31:0]                rdata_pid_0;
  wire  [31:0]                rdata_pid_1;
  wire  [31:0]                rdata_pid_2;
  wire  [31:0]                rdata_pid_3;
  wire  [31:0]                rdata_pid_4;
  wire  [31:0]                rdata_compid_0;
  wire  [31:0]                rdata_compid_1;
  wire  [31:0]                rdata_compid_2;
  wire  [31:0]                rdata_compid_3;
  wire  [31:0]                rdata_iidr;
  wire  [31:0]                rdata_aidr;
  wire  [3:0]                 sreg_pid2;
  wire  [3:0]                 sreg_pid3;

  wire                        pwrrec_qrun;

  wire  [MHU_NUM_CH-1:0]    edge_pulse_rec;

  wire pclk_rec_gated;
  wire reg_clk_en;

  wire  [31:0]                rdata_int_st0;
  wire  [31:0]                rdata_int_st1;
  wire  [31:0]                rdata_int_st2;
  wire  [27:0]                rdata_int_st3;
  wire  [31:0]                rdata_int_st;
  wire  [31:0]                rdata_int_en;

  wire                        ready_int_st_en;
  wire  [123:0]               int_st_comb_rec;
  reg                         int_st_en_rec;
  reg                         int_st_rec;
  
  reg   [31:0]                rdata_recreg_ored_r;
  
  wire  [1:0]                 unused_paddr_fromsnd;
  wire  [21:0]                unused_paddr_rec;
  wire  [3:0]                 pstrb_rec;

  wire                        clk_request_rec;
  wire                        en_clk;
  wire                        pclkm_clken;

  wire                        pwr_request_rec;
  wire                        pwr_clken;

  wire                        clk_request_edge;
  wire                        pwr_request_edge;

  wire                        clk_comb_request;
  wire                        pwr_comb_request;

  wire                        recwakeup_async_sss;
  wire                        pclkmqreqn_ss;
  wire                        pwrqreqn_ss;

  assign config_checker_0[((MHU_NUM_CH > 7'd0) & (MHU_NUM_CH < 7'd125) )] = 1'b1;
 


  mhuv2_f1_adb_apb3_mst   u_mhuv2_f1_adb_apb3_mst   (
    .pclk                     (pclk_rec),
    .presetn                  (presetn_rec),
    .dftcgen                  (dftcgen),
    .psel_o                   (pselx_fromsnd),
    .penable_o                (penable_fromsnd),
    .paddr_o                  (paddr_fromsnd),
    .pwrite_o                 (pwrite_fromsnd),
    .pwdata_o                 (pwdata_fromsnd),
    .pstrb_o                  (pstrb_fromsnd),
    .prdata_i                 (prdata_fromsnd),
    .pready_i                 (pready_fromsnd),
    .pslverr_i                (pslverr_fromsnd),
    .recwakeup_async_sss_o    (recwakeup_async_sss),
    .pwrrec_qrun_i            (pwrrec_qrun),
    .apb_async_req_i          (apb_async_req),
    .apb_async_req_payload_i  (apb_async_req_payload),
    .apb_async_resp_payload_o (apb_async_resp_payload),
    .apb_async_ack_o          (apb_async_ack),
    .recawake_async_o         (recawake_async),
    .recwakeup_async_i        (recwakeup_async),
    .pwakeup_i                (pwakeup_rec),
    .clk_request_o            (clk_request_rec),
    .en_clk_i                 (en_clk),
    .pclkm_clken_i            (pclkm_clken),
    .pwr_request_o            (pwr_request_rec),
    .pwr_clken_i              (pwr_clken)
  );


  mhuv2_f1_adb_apb3_mst_async
  u_mhuv2_f1_adb_apb3_mst_async
  (
    .apb_async_req_i        (apb_async_req),
    .apb_async_ack_i        (apb_async_ack),
    .recwakeup_async_i      (recwakeup_async),
    .recwakeup_async_sss_i  (recwakeup_async_sss),
    .pwrqreqn_i             (qreqn_pwr_rec),
    .pwrqacceptn_i          (qacceptn_pwr_rec),
    .pwakeup_i              (pwakeup_rec),
    .pclkmqactive_o         (qactive_pclk_rec)
  );


  mhuv2_f1_adb_posedge_slave #(
    .WIDTH(MHU_NUM_CH)
  )u_mhuv2_f1_adb_posedge_slave (
    .CLK                      (pclk_rec),
    .RESETn                   (presetn_rec),
    .EDGEREQASYNC             (edge_async_req),
    .EDGEACKASYNC             (edge_async_ack),
    .EDGESYNC                 (edge_pulse_rec),
    .CLKEN                    (en_clk),
    .CLKREQUEST               (clk_request_edge),
    .PWREN                    (pwrrec_qrun),
    .PWRREQUEST               (pwr_request_edge)
  );


 mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_pclkmqreqn
  (
    .CLK    (pclk_rec),
    .RESETn (presetn_rec),
    .ASYNC  (qreqn_pclk_rec),
    .SYNC   (pclkmqreqn_ss)
  );

   mhuv2_f1_adb_sync
  u_mhuv2_f1_adb_sync_pwrqreqn
  (
    .CLK    (pclk_rec),
    .RESETn (presetn_rec),
    .ASYNC  (qreqn_pwr_rec),
    .SYNC   (pwrqreqn_ss)
  );

  mhuv2_f1_adb_apb3_q_channel
  u_mhuv2_f1_rec_qch_clk
  (
    .pclk       (pclk_rec),
    .presetn    (presetn_rec),
    .qreqn_i    (pclkmqreqn_ss),
    .qacceptn_o (qacceptn_pclk_rec),
    .qdeny_o    (qdeny_pclk_rec),
    .request_i  (clk_comb_request),
    .en_o       (en_clk),
    .clken_o    (pclkm_clken)
  );

  mhuv2_f1_adb_apb3_q_channel
    u_mhuv2_f1_rec_qch_pwr
    (
      .pclk       (pclk_rec),
      .presetn    (presetn_rec),
      .qreqn_i    (pwrqreqn_ss),
      .qacceptn_o (qacceptn_pwr_rec),
      .qdeny_o    (qdeny_pwr_rec),
      .request_i  (pwr_comb_request),
      .en_o       (pwrrec_qrun),
      .clken_o    (pwr_clken)
    );

  assign clk_comb_request = (clk_request_rec | clk_request_edge);
  assign pwr_comb_request = (pwr_request_rec | pwr_request_edge);


  assign  addr_snd        = {paddr_fromsnd[11:2], 2'b0};
  assign  writeen_snd     = {4{pwrite_fromsnd & penable_fromsnd}} & pstrb_fromsnd;

  assign  addr_rec        = {paddr_rec[11:2], 2'b0};
  assign  writeen_rec     = {4{pwrite_rec & penable_rec & pready_rec}} & pstrb_rec;

  assign  reg_clk_en      = pselx_rec | pselx_fromsnd;

  assign  ready_int_st_en = (addr_rec == 12'hf98)? pselx_rec: 1'b0;

  generate
    if (MHU_NUM_CH < 7'd124) begin: below_max_reg
      assign int_st_comb_rec  = {{(7'd124-MHU_NUM_CH){1'b0}},reg_irq} & {{(7'd124-MHU_NUM_CH){1'b0}}, {MHU_NUM_CH{int_st_en_rec}}};
    end
    else if (MHU_NUM_CH == 7'd124) begin: max_reg
      assign int_st_comb_rec  = reg_irq & {MHU_NUM_CH{int_st_en_rec}};
    end
  endgenerate

  mhuv2_f1_adb_cg
  u_mhuv2_f1_adb_cg
  (
    .clk_in (pclk_rec),
    .enable (reg_clk_en),
    .clk_out(pclk_rec_gated),
    .dftcgen(dftcgen)
  );

  generate
  genvar i;
    for (i=0; i<{25'h0,MHU_NUM_CH}; i=i+1) begin : mhuv2_f1_rec_mhu_reg_genblock_1
      mhuv2_f1_rec_mhu_reg #(
        .BASE_ADDR                          (i * 32'h020)

      ) u_mhuv2_f1_rec_mhu_reg_l (

        .pclk                                 (pclk_rec_gated),
        .presetn                              (presetn_rec),
        .sel_rec_i                            (pselx_rec),
        .addr_rec_i                           (addr_rec),
        .writeen_rec_i                        (writeen_rec),
        .wdata_rec_i                          (pwdata_rec),
        .rdata_rec_o                          (rdata_recreg[i]),
        .sel_snd_i                            (pselx_fromsnd),
        .addr_snd_i                           (addr_snd),
        .writeen_snd_i                        (writeen_snd),
        .wdata_snd_i                          (pwdata_fromsnd),
        .rdata_snd_o                          (rdata_sndreg[i]),
        .reg_irq_o                            (reg_irq[i]),
        .edge_pulse_o                         (edge_pulse_rec[i])
      );
      if (i>0)
      begin : rec_mhu_reg_output_1
        assign rdata_sndreg_ored[i] = rdata_sndreg_ored[i-1] | rdata_sndreg[i];
        assign rdata_recreg_ored[i] = rdata_recreg_ored[i-1] | rdata_recreg[i];
      end
      else
      begin : rec_mhu_reg_output_2
        assign rdata_sndreg_ored[i] = rdata_sndreg[i];
        assign rdata_recreg_ored[i] = rdata_recreg[i];
      end
    end
  endgenerate
  
  always @(posedge pclk_rec_gated or negedge presetn_rec)
    if(!presetn_rec)
      rdata_recreg_ored_r <=  32'b0000_0000;
    else if(pselx_rec)
      rdata_recreg_ored_r <= rdata_recreg_ored[MHU_NUM_CH - 1];

  mhuv2_f1_static_reg
  #(
    .WIDTH        (4)
  )
  u_mhuv2_f1_static_reg_pid2_rec  (
    .clk          (pclk_rec),
    .reset_n      (presetn_rec),
    .static_i     (4'b0000),
    .static_o     (sreg_pid2)
  );

  mhuv2_f1_static_reg
  #(
    .WIDTH        (4)
  )
  u_mhuv2_f1_static_reg_pid3_rec  (
    .clk          (pclk_rec),
    .reset_n      (presetn_rec),
    .static_i     (4'b0000),
    .static_o     (sreg_pid3)
  );


  always @(posedge pclk_rec_gated or negedge presetn_rec)
    if(!presetn_rec)
      int_st_rec <=  1'b0;
    else
      int_st_rec <= (|int_st_comb_rec);

  always @(posedge pclk_rec_gated or negedge presetn_rec)
    if(!presetn_rec)
      int_st_en_rec <=  1'b1;        
    else if(ready_int_st_en & writeen_rec[0])
      int_st_en_rec <= pwdata_rec[2];

  assign  rdata_msg_no_cap[31:7]   = {25{1'b0}};
  assign  rdata_msg_no_cap[6:0]    = (addr_rec == 12'hf80)& pselx_rec? MHU_NUM_CH[6:0]: {7{1'b0}};

  assign  rdata_iidr               = (addr_rec == 12'hfc8)& pselx_rec? {12'h076,sreg_pid2, sreg_pid3, 12'h43b}: {32{1'b0}};
  assign  rdata_aidr               = (addr_rec == 12'hfcc)& pselx_rec? 32'h0000_0011: {32{1'b0}};

  assign  rdata_pid_0              = (addr_rec == 12'hfe0)& pselx_rec? 32'h0000_0076: {32{1'b0}};
  assign  rdata_pid_1              = (addr_rec == 12'hfe4)& pselx_rec? 32'h0000_00b0: {32{1'b0}};
  assign  rdata_pid_2              = (addr_rec == 12'hfe8)& pselx_rec? {24'h0000_00,sreg_pid2,4'hb}: {32{1'b0}};
  assign  rdata_pid_3              = (addr_rec == 12'hfec)& pselx_rec? {24'h0000_00,sreg_pid3,4'h0}: {32{1'b0}};
  assign  rdata_pid_4              = (addr_rec == 12'hfd0)& pselx_rec? 32'h0000_0004: {32{1'b0}};

  assign  rdata_compid_0           = (addr_rec == 12'hff0)& pselx_rec? 32'h0000_000d: {32{1'b0}};
  assign  rdata_compid_1           = (addr_rec == 12'hff4)& pselx_rec? 32'h0000_00f0: {32{1'b0}};
  assign  rdata_compid_2           = (addr_rec == 12'hff8)& pselx_rec? 32'h0000_0005: {32{1'b0}};
  assign  rdata_compid_3           = (addr_rec == 12'hffc)& pselx_rec? 32'h0000_00b1: {32{1'b0}};

  assign rdata_int_st0             = (addr_rec == 12'hfa0)& pselx_rec? int_st_comb_rec[31:0]: {32{1'b0}};
  assign rdata_int_st1             = (addr_rec == 12'hfa4)& pselx_rec? int_st_comb_rec[63:32]: {32{1'b0}};
  assign rdata_int_st2             = (addr_rec == 12'hfa8)& pselx_rec? int_st_comb_rec[95:64]: {32{1'b0}};
  assign rdata_int_st3             = (addr_rec == 12'hfac)& pselx_rec? int_st_comb_rec[123:96]: {28{1'b0}};

  assign rdata_int_st              = (addr_rec == 12'hf90)& pselx_rec?  {{29{1'b0}}, int_st_rec, {2{1'b0}}}: {32{1'b0}};
  assign rdata_int_en              = ready_int_st_en? {{29{1'b0}}, int_st_en_rec, {2{1'b0}}}: {32{1'b0}};
  assign prdata_fromsnd       = rdata_sndreg_ored[MHU_NUM_CH - 1];
  assign pslverr_fromsnd      = 1'b0;
  assign pready_fromsnd       = penable_fromsnd;

  
  assign prdata_rec = rdata_recreg_ored_r                        |
                      rdata_msg_no_cap                           |
                      rdata_pid_0                                |
                      rdata_pid_1                                |
                      rdata_pid_2                                |
                      rdata_pid_3                                |
                      rdata_pid_4                                |
                      rdata_compid_0                             |
                      rdata_compid_1                             |
                      rdata_compid_2                             |
                      rdata_compid_3                             |
                      rdata_int_st                               |
                      rdata_int_st0                              |
                      rdata_int_st1                              |
                      rdata_int_st2                              |
                      {4'h0, rdata_int_st3}                      |
                      rdata_int_en                               |
                      rdata_iidr                                 |
                      rdata_aidr;

  assign pslverr_rec          = 1'b0;
  assign pready_rec           = qacceptn_pclk_rec;


  assign mhu_irqcomb          = pwrrec_qrun & (| reg_irq) & int_st_en_rec;
  assign mhu_irq_reg          = {MHU_NUM_CH{pwrrec_qrun}} & reg_irq;



  assign unused_paddr_fromsnd = {paddr_fromsnd[1:0]};
  assign unused_paddr_rec     = {paddr_rec[31:12], paddr_rec[1:0]};


  assign pstrb_rec = 4'b1111;

endmodule
