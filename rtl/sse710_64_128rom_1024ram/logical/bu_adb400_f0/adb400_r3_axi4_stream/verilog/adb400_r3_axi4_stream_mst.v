//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-07 15:48:44 +0000 (Sun, 07 Feb 2016)
// Revision : 206511
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_axi4_stream_mst.v
//-----------------------------------------------------------------------------
// Purpose : Master side of bridge with bi-directional AXI4-Stream interfaces.
//-----------------------------------------------------------------------------

module adb400_r3_axi4_stream_mst
  #(parameter
      DATA_WIDTH     = 8,
      ID_WIDTH       = 1,
      DEST_WIDTH     = 1,
      USER_WIDTH     = 1,

      FIFO_DEPTH     = 6,
      OPREG          = 1,

      MI_SYNC_LEVELS = 2,

      // If they are overridden is should only be to 0.

      // These are generally derived from DATA width.
      STRB_WIDTH     = (DATA_WIDTH/8),
      KEEP_WIDTH     = (DATA_WIDTH/8),

      // Normally present, but can be removed
      LAST_WIDTH     = 1
  )
  (
    //
    // Synchronous interfaces
    //

    // Global signals
    input  wire                                             aclkm,
    input  wire                                             aresetnm,
    input  wire                                             dftrstdisablem,

    // Clock control
    input  wire                                             clkqreqnm_i,
    output wire                                             clkqacceptnm_o,
    output wire                                             clkqdenym_o,

    // Clock requirement
    output wire                                             clkqactivem_o,

    // Wake-up
    output wire                                             wakeupm_o,

    // Channel signalling
    output wire                                             tvalidm,
    input  wire                                             treadym,
    output wire [((DATA_WIDTH>0)?(DATA_WIDTH-1):0):0]       tdatam,
    output wire [((STRB_WIDTH>0)?(STRB_WIDTH-1):0):0]       tstrbm,
    output wire [((KEEP_WIDTH>0)?(KEEP_WIDTH-1):0):0]       tkeepm,
    output wire                                             tlastm,
    output wire [((ID_WIDTH>0)?(ID_WIDTH-1):0):0]           tidm,
    output wire [((DEST_WIDTH>0)?(DEST_WIDTH-1):0):0]       tdestm,
    output wire [((USER_WIDTH>0)?(USER_WIDTH-1):0):0]       tuserm,

    // Async interfaces 

    input  wire                                             slvmustacceptreqn_async,
    input  wire                                             slvcandenyreqn_async,
    output wire                                             slvacceptn_async,
    output wire                                             slvdeny_async,

    input  wire                                             si_to_mi_wakeup_async,
    output wire                                             mi_to_si_wakeup_async,

    input  wire [FIFO_DEPTH-1:0]                            wr_ptr_async,
    output wire [FIFO_DEPTH-1:0]                            rd_ptr_async,
    input  wire [((payload_width_fn(
                                    LAST_WIDTH,
                                    DATA_WIDTH,
                                    STRB_WIDTH,
                                    KEEP_WIDTH,
                                    ID_WIDTH,
                                    DEST_WIDTH,
                                    USER_WIDTH
                                   )>0)?
                  ((payload_width_fn(
                                     LAST_WIDTH,
                                     DATA_WIDTH,
                                     STRB_WIDTH,
                                     KEEP_WIDTH,
                                     ID_WIDTH,
                                     DEST_WIDTH,
                                     USER_WIDTH
                                     )*FIFO_DEPTH)-1):
                  0):0]                                     payld_async
   );


  function automatic integer payload_width_fn
    (
      input integer last_width,
      input integer data_width,
      input integer strb_width,
      input integer keep_width,
      input integer id_width,
      input integer dest_width,
      input integer user_width
    );
    begin : fn_payload_width_fn
// ACS_off ARITHMETIC_OVERFLOW Some elements on RHS are integers, but no chance of overflow calculating a payload width
      payload_width_fn = 
               ((last_width>0)?1:0) +
               data_width +
               strb_width +
               keep_width +
               id_width +
               dest_width +
               user_width +
               0;
    end
  endfunction

  localparam PAYLOAD_WIDTH =
    payload_width_fn (
                      LAST_WIDTH,
                      DATA_WIDTH,
                      STRB_WIDTH,
                      KEEP_WIDTH,
                      ID_WIDTH,
                      DEST_WIDTH,
                      USER_WIDTH
                     );

  wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] tpayldm;

  generate

    if (PAYLOAD_WIDTH==0)
      begin : g_no_payld
        wire tpayldm_unused = tpayldm;
        assign tlastm = 1'b0;
        assign tdatam = 1'b0;
        assign tstrbm = 1'b0;
        assign tkeepm = 1'b0;
        assign tidm   = 1'b0;
        assign tdestm = 1'b0;
        assign tuserm = 1'b0;
      end
    else
      begin : g_has_payld
        if (LAST_WIDTH>0)
          begin : g_has_last
            assign tlastm = tpayldm[
                                    DATA_WIDTH +
                                    STRB_WIDTH +
                                    KEEP_WIDTH +
                                    ID_WIDTH +
                                    DEST_WIDTH +
                                    USER_WIDTH +
                                    0 +: 1];
          end
        else
          begin : g_no_last
            assign tlastm = 1'b0;
          end

        if (DATA_WIDTH>0)
          begin : g_has_data
            assign tdatam = tpayldm[
                                    STRB_WIDTH +
                                    KEEP_WIDTH +
                                    ID_WIDTH +
                                    DEST_WIDTH +
                                    USER_WIDTH +
                                    0 +: DATA_WIDTH];
          end
        else
          begin : g_no_data
            assign tdatam = 1'b0;
          end
    
        if (STRB_WIDTH>0)
          begin : g_has_strb
            assign tstrbm = tpayldm[
                                    KEEP_WIDTH +
                                    ID_WIDTH +
                                    DEST_WIDTH +
                                    USER_WIDTH +
                                    0 +: STRB_WIDTH];
          end
        else
          begin : g_no_strb
            assign tstrbm = 1'b0;
          end
    
        if (KEEP_WIDTH>0)
          begin : g_has_keep
            assign tkeepm = tpayldm[
                                    ID_WIDTH +
                                    DEST_WIDTH +
                                    USER_WIDTH +
                                    0 +: KEEP_WIDTH];
          end
        else
          begin : g_no_keep
            assign tkeepm = 1'b0;
          end
    
        if (ID_WIDTH>0)
          begin : g_has_id
            assign tidm   = tpayldm[
                                    DEST_WIDTH +
                                    USER_WIDTH +
                                    0 +: ID_WIDTH];
          end
        else
          begin : g_no_id
            assign tidm   = 1'b0;
          end
    
        if (DEST_WIDTH>0)
          begin : g_has_dest
            assign tdestm = tpayldm[
                                    USER_WIDTH +
                                    0 +: DEST_WIDTH];
          end
        else
          begin : g_no_dest
            assign tdestm = 1'b0;
          end
    
        if (USER_WIDTH>0)
          begin : g_has_user
            assign tuserm = tpayldm[
                                    0 +: USER_WIDTH];
          end
        else
          begin : g_no_user
            assign tuserm = 1'b0;
          end
      end

  endgenerate

  adb400_r3_mst_transport_f1
    #(
      .FIFO_DEPTH       (FIFO_DEPTH),
      .OPREG            (OPREG),
      .SYNC_LEVELS      (MI_SYNC_LEVELS),
      .PAYLOAD_WIDTH    (PAYLOAD_WIDTH)
    )
  u_mst
    (
      .aclk                    (aclkm),
      .aresetn                 (aresetnm),

      .dftrstdisable           (dftrstdisablem),

      .clkqreqn_i              (clkqreqnm_i),
      .clkqacceptn_o           (clkqacceptnm_o),
      .clkqdeny_o              (clkqdenym_o),
      .clkqactive_o            (clkqactivem_o),
      .wakeup_o                (wakeupm_o),

      .valid                   (tvalidm),
      .ready                   (treadym),
      .payld                   (tpayldm),

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

endmodule

