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


module css600_ntsasyncbridgemstr #(parameter
  FF_SYNC_DEPTH = 2,
  THRESHOLD     = 8
)
(
  clk_m,
  reset_m_n,
  tsbit_m,
  tssync_m,
  tssyncready_m,
  clk_m_qreq_n,
  clk_m_qaccept_n,
  clk_m_qactive,
  wr_ptr_encd_gry,
  rd_ptr_encd_gry,
  wr_ptr_sync_gry,
  rd_ptr_sync_gry,
  nts_fw_data,
  s_lp,
  s_lp_return,
  m_lp
);


  localparam SYNC_DEPTH       = ((FF_SYNC_DEPTH == 3) || (FF_SYNC_DEPTH == 2))  ? FF_SYNC_DEPTH  : 2;
  localparam FIFO_DEPTH       = (SYNC_DEPTH == 2) ? 6 : 8;


  input wire clk_m;

  input wire reset_m_n;

  output wire [6:0] tsbit_m;
  output wire [1:0] tssync_m;
  input wire tssyncready_m;

  input wire clk_m_qreq_n;
  output wire clk_m_qaccept_n;
  output wire clk_m_qactive;

  input  wire [3:0] wr_ptr_encd_gry;
  output wire [3:0] rd_ptr_encd_gry;
  input  wire [3:0] wr_ptr_sync_gry;
  output wire [3:0] rd_ptr_sync_gry;

  input  wire [FIFO_DEPTH*9-1:0] nts_fw_data;

  input  wire s_lp;
  output wire s_lp_return;

  output wire m_lp;


  wire [3:0] wr_ptr_encd_gry_cdc_check;
  wire [3:0] wr_ptr_sync_gry_cdc_check;

  wire [FIFO_DEPTH*7-1:0] nts_encd_data;
  wire [FIFO_DEPTH*7-1:0] nts_encd_data_cdc_check;
  wire [FIFO_DEPTH*2-1:0] syn_encd_data;
  wire [FIFO_DEPTH*2-1:0] syn_encd_data_cdc_check;

  wire m_lp_req;
  wire master_stopped_w;

  wire clk_lp_req_w;
  wire clk_lp_done_w;

  wire [3:0] nts_rd_ptr_gry_cdc_check;
  wire [3:0] syn_rd_ptr_gry_cdc_check;
  wire s_lp_cdc_check;


  genvar i;
  generate
    for (i=0; i<FIFO_DEPTH; i=i+1) begin: gen_read_path
      assign nts_encd_data[i*7 +: 7] = nts_fw_data[(((FIFO_DEPTH-i)*9)-1) -: 7];
      assign syn_encd_data[i*2 +: 2] = nts_fw_data[(((FIFO_DEPTH-i)*9)-8) -: 2];
    end
  endgenerate

css600_xor u_qactive_async (
  .in_a(s_lp),
  .in_b(s_lp_return),
  .out_y(clk_m_qactive)
  );

css600_ntsasyncbridgemstr_lpi  #(
    .FF_SYNC_DEPTH  (SYNC_DEPTH)
  )
  u_lpi_master_mstif (

  .clkm(clk_m),
  .resetmn(reset_m_n),

  .clk_m_qreq_n(clk_m_qreq_n),
  .clk_m_qaccept_n(clk_m_qaccept_n),

  .s_lp_async(s_lp_cdc_check),
  .s_lp(s_lp_return),

  .clk_lp_req (clk_lp_req_w),
  .clk_lp_done (clk_lp_done_w),

  .m_lp(m_lp),
  .master_stopped(master_stopped_w),

  .m_lp_request(m_lp_req)
  );

css600_ntsasyncbridgemstr_core # (
  .FF_SYNC_DEPTH (SYNC_DEPTH),
  .FIFO_DEPTH    (FIFO_DEPTH)
)
  u_mstif (

  .clkm (clk_m),
  .resetmn (reset_m_n),

  .tsbitm (tsbit_m),
  .tssyncm (tssync_m),
  .tssyncreadym (tssyncready_m),

  .nts_rd_ptr_gry_m (nts_rd_ptr_gry_cdc_check),
  .nts_wr_ptr_gry_m (wr_ptr_encd_gry_cdc_check),

  .syn_rd_ptr_gry_m (syn_rd_ptr_gry_cdc_check),
  .syn_wr_ptr_gry_m (wr_ptr_sync_gry_cdc_check),

  .nts_encd_data_m  (nts_encd_data_cdc_check),

  .syn_encd_data_m  (syn_encd_data_cdc_check),

  .clk_lp_req       (clk_lp_req_w),
  .clk_lp_done      (clk_lp_done_w),

  .pwr_lp_req       (m_lp_req),
  .master_stopped   (master_stopped_w)
  );


  assign wr_ptr_encd_gry_cdc_check = wr_ptr_encd_gry;
  assign wr_ptr_sync_gry_cdc_check = wr_ptr_sync_gry;

  assign nts_encd_data_cdc_check = nts_encd_data;

  assign syn_encd_data_cdc_check = syn_encd_data;

  assign s_lp_cdc_check = s_lp;


  assign rd_ptr_encd_gry = nts_rd_ptr_gry_cdc_check;
  assign rd_ptr_sync_gry = syn_rd_ptr_gry_cdc_check;


endmodule

