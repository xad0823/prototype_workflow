//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016 Arm Limited or its affiliates.
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
//   Sub-module of css600_dp
//
//----------------------------------------------------------------------------


module css600_dpslv_sync
  #(parameter SYNC_DEPTH = 2)
   (
    input  wire        swclktck,
    input  wire        porst_n,

    input  wire         dp_eventstatus_i,
    output wire         dp_eventstatus_o,

    input   wire        cdbgpwrupack_i,
    input   wire        csyspwrupack_i,
    input   wire        cdbgrstack_i,
    output  wire        cdbgpwrupack_o,
    output  wire        csyspwrupack_o,
    output  wire        cdbgrstack_o

    );


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
    u_css600_cdc_capt_sync_eventstatus(
                                    .clk       (swclktck),
                                    .reset_n   (porst_n),
                                    .d_async_i (dp_eventstatus_i),
                                    .q_sync_o  (dp_eventstatus_o)
                                   );


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
    u_css600_cdc_capt_sync_cdbgpwrupack(
                                    .clk       (swclktck),
                                    .reset_n   (porst_n),
                                    .d_async_i (cdbgpwrupack_i),
                                    .q_sync_o  (cdbgpwrupack_o)
                                   );


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
    u_css600_cdc_capt_sync_csyspwrupack(
                                    .clk       (swclktck),
                                    .reset_n   (porst_n),
                                    .d_async_i (csyspwrupack_i),
                                    .q_sync_o  (csyspwrupack_o)
                                   );


  css600_cdc_capt_sync
    #(.FF_SYNC_DEPTH (SYNC_DEPTH))
    u_css600_cdc_capt_sync_cdbgrstack(
                                    .clk       (swclktck),
                                    .reset_n   (porst_n),
                                    .d_async_i (cdbgrstack_i),
                                    .q_sync_o  (cdbgrstack_o)
                                   );

endmodule


