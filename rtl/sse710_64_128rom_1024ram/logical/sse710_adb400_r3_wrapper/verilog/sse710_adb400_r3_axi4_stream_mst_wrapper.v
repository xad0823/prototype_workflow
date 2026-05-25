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

module sse710_adb400_r3_axi4_stream_mst_wrapper
  #(
    parameter DATA_WIDTH     = 8,
    parameter ID_WIDTH       = 1,
    parameter DEST_WIDTH     = 1,
    parameter USER_WIDTH     = 1,
    parameter FIFO_DEPTH     = 6,
    parameter OPREG          = 1,
    parameter MI_SYNC_LEVELS = 2,
    parameter STRB_WIDTH     = (DATA_WIDTH/8),
    parameter KEEP_WIDTH     = (DATA_WIDTH/8),
    parameter LAST_WIDTH     = 1,
    parameter PAYLOAD_WIDTH  = 50
  )
  (

    input  wire                                             aclkm,
    input  wire                                             aresetnm,
    input  wire                                             dftrstdisablem,

    input  wire                                             clkqreqnm_i,
    output wire                                             clkqacceptnm_o,
    output wire                                             clkqdenym_o,

    output wire                                             clkqactivem_o,

    output wire                                             wakeupm_o,

    output wire                                             tvalidm,
    input  wire                                             treadym,
    output wire [((DATA_WIDTH>0)?(DATA_WIDTH-1):0):0]       tdatam,
    output wire [((STRB_WIDTH>0)?(STRB_WIDTH-1):0):0]       tstrbm,
    output wire [((KEEP_WIDTH>0)?(KEEP_WIDTH-1):0):0]       tkeepm,
    output wire                                             tlastm,
    output wire [((ID_WIDTH>0)?(ID_WIDTH-1):0):0]           tidm,
    output wire [((DEST_WIDTH>0)?(DEST_WIDTH-1):0):0]       tdestm,
    output wire [((USER_WIDTH>0)?(USER_WIDTH-1):0):0]       tuserm,


    input  wire                                             slvmustacceptreqn_async,
    input  wire                                             slvcandenyreqn_async,
    output wire                                             slvacceptn_async,
    output wire                                             slvdeny_async,

    input  wire                                             si_to_mi_wakeup_async,
    output wire                                             mi_to_si_wakeup_async,

    input  wire [FIFO_DEPTH-1:0]                            wr_ptr_async,
    output wire [FIFO_DEPTH-1:0]                            rd_ptr_async,
    input  wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] payld_async
);


  wire [((DATA_WIDTH>0)?(DATA_WIDTH-1):0):0]       tdatam_int;
  wire [((STRB_WIDTH>0)?(STRB_WIDTH-1):0):0]       tstrbm_int;
  wire [((KEEP_WIDTH>0)?(KEEP_WIDTH-1):0):0]       tkeepm_int;
  wire                                             tlastm_int;
  wire [((ID_WIDTH>0)?(ID_WIDTH-1):0):0]           tidm_int;
  wire [((DEST_WIDTH>0)?(DEST_WIDTH-1):0):0]       tdestm_int;
  wire [((USER_WIDTH>0)?(USER_WIDTH-1):0):0]       tuserm_int;   
  

  adb400_r3_axi4_stream_mst
    #(
      .DATA_WIDTH       (DATA_WIDTH),
      .STRB_WIDTH       (STRB_WIDTH),
      .KEEP_WIDTH       (KEEP_WIDTH),
      .LAST_WIDTH       (LAST_WIDTH),
      .ID_WIDTH         (ID_WIDTH),
      .DEST_WIDTH       (DEST_WIDTH),
      .USER_WIDTH       (USER_WIDTH),
      .FIFO_DEPTH       (FIFO_DEPTH),
      .OPREG            (OPREG),
      .MI_SYNC_LEVELS   (MI_SYNC_LEVELS)
    )
  u_adb400_r3_axi4_stream_mst
    (
      .aclkm                   (aclkm       ),
      .aresetnm                (aresetnm),
      .dftrstdisablem          (dftrstdisablem),
      .clkqreqnm_i             (clkqreqnm_i),
      .clkqacceptnm_o          (clkqacceptnm_o),
      .clkqdenym_o             (clkqdenym_o),
      .clkqactivem_o           (clkqactivem_o),
      .wakeupm_o               (wakeupm_o),
      .tvalidm                 (tvalidm),
      .treadym                 (treadym),
      .tdatam                  (tdatam_int),
      .tstrbm                  (tstrbm_int),
      .tkeepm                  (tkeepm_int),
      .tlastm                  (tlastm_int),
      .tidm                    (tidm_int),
      .tdestm                  (tdestm_int),
      .tuserm                  (tuserm_int),
      .slvmustacceptreqn_async (slvmustacceptreqn_async),
      .slvcandenyreqn_async    (slvcandenyreqn_async),
      .slvacceptn_async        (slvacceptn_async),
      .slvdeny_async           (slvdeny_async),
      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async),
      .wr_ptr_async            (wr_ptr_async),
      .rd_ptr_async            (rd_ptr_async),
      .payld_async             (payld_async)
  );

  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((DATA_WIDTH>0)?(DATA_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tdatam (
    .din1_async   (tdatam_int),
    .din2_async   ({((DATA_WIDTH>0)?(DATA_WIDTH):1){tvalidm}}),
    .dout_async   (tdatam)
  );
  
  arm_element_cdc_comb_and2 #(
    .WIDTH (((STRB_WIDTH>0)?(STRB_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tstrbm (
    .din1_async   (tstrbm_int),
    .din2_async   ({((STRB_WIDTH>0)?(STRB_WIDTH):1){tvalidm}}),
    .dout_async   (tstrbm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (((KEEP_WIDTH>0)?(KEEP_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tkeepm (
    .din1_async   (tkeepm_int),
    .din2_async   ({((KEEP_WIDTH>0)?(KEEP_WIDTH):1){tvalidm}}),
    .dout_async   (tkeepm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (1)
  ) u_arm_element_cdc_comb_and2_tlastm (
    .din1_async   (tlastm_int),
    .din2_async   (tvalidm),
    .dout_async   (tlastm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (((ID_WIDTH>0)?(ID_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tidm (
    .din1_async   (tidm_int),
    .din2_async   ({((ID_WIDTH>0)?(ID_WIDTH):1){tvalidm}}),
    .dout_async   (tidm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (((DEST_WIDTH>0)?(DEST_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tdestm (
    .din1_async   (tdestm_int),
    .din2_async   ({((DEST_WIDTH>0)?(DEST_WIDTH):1){tvalidm}}),
    .dout_async   (tdestm)
  );

  arm_element_cdc_comb_and2 #(
    .WIDTH (((USER_WIDTH>0)?(USER_WIDTH):1))
  ) u_arm_element_cdc_comb_and2_tuserm (
    .din1_async   (tuserm_int),
    .din2_async   ({((USER_WIDTH>0)?(USER_WIDTH):1){tvalidm}}),
    .dout_async   (tuserm)
  );  

endmodule
