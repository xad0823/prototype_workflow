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


module css600_tpiu_core_sync
#(
  parameter FF_SYNC_DEPTH = 2
)
(
  input  wire        clk,
  input  wire        reset_n,

  input  wire        tp_xfer_ack,
  input  wire [31:0] tp_rdata,
  input  wire  [3:0] rd_ptr_gray,
  input  wire        trig_port_done,

  output wire        tp_xfer_ack_sync,
  output wire [31:0] tp_rdata_sync,
  output wire  [3:0] rd_ptr_gray_sync,
  output wire        trig_port_done_sync
);


    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_tpxferack(
                                       .clk       (clk),
                                       .reset_n   (reset_n),
                                       .d_async_i (tp_xfer_ack),
                                       .q_sync_o  (tp_xfer_ack_sync)
                                      );
    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_trigportdone(
                                          .clk       (clk),
                                          .reset_n   (reset_n),
                                          .d_async_i (trig_port_done),
                                          .q_sync_o  (trig_port_done_sync)
                                         );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_rdptrgray0(
                                        .clk       (clk),
                                        .reset_n   (reset_n),
                                        .d_async_i (rd_ptr_gray[0]),
                                        .q_sync_o  (rd_ptr_gray_sync[0])
                                       );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_rdptrgray1(
                                        .clk       (clk),
                                        .reset_n   (reset_n),
                                        .d_async_i (rd_ptr_gray[1]),
                                        .q_sync_o  (rd_ptr_gray_sync[1])
                                       );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_rdptrgray2(
                                        .clk       (clk),
                                        .reset_n   (reset_n),
                                        .d_async_i (rd_ptr_gray[2]),
                                        .q_sync_o  (rd_ptr_gray_sync[2])
                                       );

    css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (FF_SYNC_DEPTH))
      u_css600_cdc_capt_sync_rdptrgray3(
                                        .clk       (clk),
                                        .reset_n   (reset_n),
                                        .d_async_i (rd_ptr_gray[3]),
                                        .q_sync_o  (rd_ptr_gray_sync[3])
                                       );


    css600_cdc_capt_nosync #(.IH(31),.IL(0))
      u_css600_cdc_capt_nosync_tprdata(
                                       .clk       (clk),
                                       .reset_n   (reset_n),
                                       .en        (tp_xfer_ack_sync),
                                       .d_async_i (tp_rdata[31:0]),
                                       .q_sync_o  (tp_rdata_sync[31:0])
                                      );

endmodule

