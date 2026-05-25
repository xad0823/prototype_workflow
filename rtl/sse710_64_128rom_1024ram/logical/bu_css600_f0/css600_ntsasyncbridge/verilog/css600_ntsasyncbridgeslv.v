//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_ntsasyncbridge
//
//----------------------------------------------------------------------------


module css600_ntsasyncbridgeslv #(parameter
  FF_SYNC_DEPTH = 2,
  THRESHOLD     = 8
)
(
  clk_s,
  reset_s_n,
  tsbit_s,
  tssync_s,
  tssyncready_s,
  clk_s_qreq_n,
  clk_s_qaccept_n,
  clk_s_qactive,
  pwr_qreq_n,
  pwr_qaccept_n,
  wr_ptr_encd_gry,
  rd_ptr_encd_gry,
  wr_ptr_sync_gry,
  rd_ptr_sync_gry,
  nts_fw_data,
  s_lp,
  s_lp_return,
  m_lp
);


  localparam SYNC_DEPTH      = ((FF_SYNC_DEPTH == 3) || (FF_SYNC_DEPTH == 2))
                             ? FF_SYNC_DEPTH
                             : 2;
  localparam THRESHOLD_LOCAL = ((THRESHOLD >= 6) && (THRESHOLD <= 64))
                             ? THRESHOLD
                             : 8;
  localparam FIFO_DEPTH      = (SYNC_DEPTH == 2)
                             ? 6
                             : 8;


  input  wire                    clk_s;
  input  wire                    reset_s_n;

  input  wire [6:0]              tsbit_s;
  input  wire [1:0]              tssync_s;
  output wire                    tssyncready_s;

  input  wire                    clk_s_qreq_n;
  output wire                    clk_s_qaccept_n;
  output wire                    clk_s_qactive;

  input  wire                    pwr_qreq_n;
  output wire                    pwr_qaccept_n;

  output wire [3:0]              wr_ptr_encd_gry;
  input  wire [3:0]              rd_ptr_encd_gry;
  output wire [3:0]              wr_ptr_sync_gry;
  input  wire [3:0]              rd_ptr_sync_gry;

  output wire [FIFO_DEPTH*9-1:0] nts_fw_data;

  output wire                    s_lp;
  input  wire                    s_lp_return;

  input  wire                    m_lp;


  wire [FIFO_DEPTH*7-1:0] nts_encd_data;
  wire [FIFO_DEPTH*2-1:0] syn_encd_data;

  wire s_lp_req;
  wire set_tssyncready_w;

  wire clk_lp_req_w;
  wire clk_lp_done_w;

  wire [3:0] rd_ptr_encd_gry_cdc_check;
  wire [3:0] rd_ptr_sync_gry_cdc_check;
  wire [3:0] nts_wr_ptr_gry_cdc_check;
  wire [3:0] syn_wr_ptr_gry_cdc_check;

  wire [FIFO_DEPTH*7-1:0] nts_encd_data_cdc_check;
  wire [FIFO_DEPTH*2-1:0] syn_encd_data_cdc_check;

  wire s_lp_return_cdc_check;
  wire m_lp_cdc_check;


  genvar i;

  generate
    for (i=0; i<FIFO_DEPTH; i=i+1) begin: gen_fifo
      assign nts_fw_data[(((FIFO_DEPTH-i)*9)-1) -: 7] = nts_encd_data[i*7 +: 7];
      assign nts_fw_data[(((FIFO_DEPTH-i)*9)-8) -: 2] = syn_encd_data[i*2 +: 2];
    end
  endgenerate

  css600_xor u_qactive_async (
  .in_a(pwr_qaccept_n),
  .in_b(pwr_qreq_n),
  .out_y(clk_s_qactive)
  );


  css600_ntsasyncbridgeslv_lpi #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_lpi_slave_slvif (

  .clks               (clk_s),
  .resetsn            (reset_s_n),

  .clk_s_qreq_n       (clk_s_qreq_n),
  .clk_s_qaccept_n    (clk_s_qaccept_n),

  .clk_lp_req         (clk_lp_req_w),
  .clk_lp_done        (clk_lp_done_w),

  .pwr_qreq_n         (pwr_qreq_n),
  .pwr_qaccept_n      (pwr_qaccept_n),

  .m_lp_async         (m_lp_cdc_check),

  .s_lp_async         (s_lp_return_cdc_check),
  .s_lp               (s_lp),

  .s_lp_request       (s_lp_req),
  .set_tssyncready    (set_tssyncready_w)

  );

css600_ntsasyncbridgeslv_core# (
  .FF_SYNC_DEPTH  (SYNC_DEPTH),
  .THRESHOLD      (THRESHOLD_LOCAL),
  .FIFO_DEPTH     (FIFO_DEPTH)
)
  u_slvif (

  .clks              (clk_s),
  .resetsn           (reset_s_n),

  .tsbits            (tsbit_s),
  .tssyncs           (tssync_s),
  .tssyncreadys      (tssyncready_s),

  .nts_rd_ptr_gry_s  (rd_ptr_encd_gry_cdc_check),
  .nts_wr_ptr_gry_s  (nts_wr_ptr_gry_cdc_check),

  .syn_rd_ptr_gry_s  (rd_ptr_sync_gry_cdc_check),
  .syn_wr_ptr_gry_s  (syn_wr_ptr_gry_cdc_check),

  .nts_encd_data_s  (nts_encd_data_cdc_check),
  .syn_encd_data_s  (syn_encd_data_cdc_check),

  .clk_lp_req       (clk_lp_req_w),
  .clk_lp_done      (clk_lp_done_w),

  .pwr_lp_req         (s_lp_req),
  .master_stopped  (set_tssyncready_w)
  );


  assign wr_ptr_encd_gry = nts_wr_ptr_gry_cdc_check;
  assign wr_ptr_sync_gry = syn_wr_ptr_gry_cdc_check;

  assign nts_encd_data  = nts_encd_data_cdc_check;

  assign syn_encd_data  = syn_encd_data_cdc_check;


  assign rd_ptr_encd_gry_cdc_check = rd_ptr_encd_gry;
  assign rd_ptr_sync_gry_cdc_check = rd_ptr_sync_gry;
  assign s_lp_return_cdc_check     = s_lp_return;
  assign m_lp_cdc_check            = m_lp;


endmodule

