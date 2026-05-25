//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_trace_sync
#(
  parameter FF_SYNC_DEPTH = 2
)
(
  input  wire        traceclk_in,
  input  wire        treset_n,


  input  wire        trig_port_cdc_t,
  input  wire        tp_xfer_req,
  input  wire        tp_xfer_type,
  input  wire  [1:0] tp_addr_enc,
  input  wire [31:0] tp_wdata,
  input  wire  [3:0] wr_ptr_gray,

  output wire        trig_port_sync,
  output wire        tp_xfer_req_sync,
  output wire        tp_xfer_type_sync,
  output wire  [1:0] tp_addr_enc_sync,
  output wire [31:0] tp_wdata_sync,
  output wire  [3:0] wr_ptr_gray_sync
);

  wire [34:0] tp_req_bus;
  wire [34:0] tp_req_bus_sync;


    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_wrptrgray0
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (wr_ptr_gray[0]),
                                .q_sync_o  (wr_ptr_gray_sync[0])
                               );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_wrptrgray1
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (wr_ptr_gray[1]),
                                .q_sync_o  (wr_ptr_gray_sync[1])
                               );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_wrptrgray2
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (wr_ptr_gray[2]),
                                .q_sync_o  (wr_ptr_gray_sync[2])
                               );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_wrptrgray3
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (wr_ptr_gray[3]),
                                .q_sync_o  (wr_ptr_gray_sync[3])
                               );


    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_tpxferreq
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (tp_xfer_req),
                                .q_sync_o  (tp_xfer_req_sync)
                               );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_trigport
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .d_async_i (trig_port_cdc_t),
                                .q_sync_o  (trig_port_sync)
                               );


    css600_cdc_capt_nosync #(.IH(34),.IL(0))
      u_css600_cdc_capt_nosync_tpreqbus
                               (
                                .clk       (traceclk_in),
                                .reset_n   (treset_n),
                                .en        (tp_xfer_req_sync),
                                .d_async_i (tp_req_bus[34:0]),
                                .q_sync_o  (tp_req_bus_sync[34:0])
                               );

  assign tp_req_bus[34:0] = {tp_xfer_type,
                             tp_addr_enc[1:0],
                             tp_wdata[31:0]};

  assign {tp_xfer_type_sync,
          tp_addr_enc_sync[1:0],
          tp_wdata_sync[31:0]}   = tp_req_bus_sync[34:0];

endmodule

