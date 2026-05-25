//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
// (C) COPYRIGHT 2011-2016 ARM Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Checked In :  2016-02-12 14:23:46 +0000 (Fri, 12 Feb 2016)
// Revision : 206763
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_slv_transport_f1r1.v
//-----------------------------------------------------------------------------
// Purpose : Slave interface half of a 2-channel transport bridge (i.e. no
//           protocol). This is wrapped in an additional layer to
//           provide specific parameters setting and remove unused ports.
//-----------------------------------------------------------------------------

module adb400_r3_slv_transport_f1r1
  #(parameter
      FW_FIFO_DEPTH       = 6,
      RV_FIFO_DEPTH       = 6,
      RV_OPREG            = 1,
      SYNC_LEVELS         = 2,
      FW_PAYLOAD_WIDTH    = 1,
      RV_PAYLOAD_WIDTH    = 1
  )
  (
    // Configuration inputs
    input  wire                   pwrq_permit_deny_sar_i,

    // Power state control
    input  wire                   pwrqreqn_i,
    output wire                   pwrqacceptn_o,
    output wire                   pwrqdeny_o,

    // Global signals
    input  wire                   aclk,
    input  wire                   aresetn,
    input  wire                   dftrstdisable,

    // Clock control
    input  wire                   clkqreqn_i,
    output wire                   clkqacceptn_o,
    output wire                   clkqdeny_o,

    // Clock requirement
    output wire                   clkqactive_o,

    // Power requirement
    output wire                   pwrqactive_o,

    // Wake-up
    input  wire                   wakeup_i,
    output wire                   wakeup_o,

    //
    // Synchronous interfaces
    //

    // FW channel signalling
    input  wire fwvalid,
    output wire fwready,
    input  wire [((FW_PAYLOAD_WIDTH>0)?(FW_PAYLOAD_WIDTH-1):0):0] fw_payld,

    // RV channel signalling
    output wire rvvalid,
    input  wire rvready,
    output wire [((RV_PAYLOAD_WIDTH>0)?(RV_PAYLOAD_WIDTH-1):0):0] rv_payld,

    //
    // Asynchronous interfaces
    //

    // Cross-domain power state control
    output wire                   slvmustacceptreqn_async,
    output wire                   slvcandenyreqn_async,
    input  wire                   slvacceptn_async,
    input  wire                   slvdeny_async,

    // Cross-domain wakeup
    output wire                   si_to_mi_wakeup_async,
    input  wire                   mi_to_si_wakeup_async,

    // FW channel signalling
    output wire [FW_FIFO_DEPTH-1:0] fw_wr_ptr_async,
    input  wire [FW_FIFO_DEPTH-1:0] fw_rd_ptr_async,
    output wire [((FW_PAYLOAD_WIDTH>0)?((FW_PAYLOAD_WIDTH*FW_FIFO_DEPTH)-1):0):0] fw_payld_async,

    // RV channel signalling
    input  wire [RV_FIFO_DEPTH-1:0]  rv_wr_ptr_async,
    output wire [RV_FIFO_DEPTH-1:0]  rv_rd_ptr_async,
    input  wire [((RV_PAYLOAD_WIDTH>0)?((RV_PAYLOAD_WIDTH*RV_FIFO_DEPTH)-1):0):0] rv_payld_async
  );

  // ----------------------------------------------------------------------------
  // Reset Synchroniser
  // ----------------------------------------------------------------------------

  wire aresetn_ss;
  wire internal_reset_n;

  adb400_r3_syncn
    #(
      .LEVELS           (SYNC_LEVELS)
    )
    u_syncn_aresetn
    (
      .aclk    (aclk),
      .aresetn (aresetn),
      .din     (1'b1),
      .dout    (aresetn_ss)
    );

  wire resetn_unforced = (dftrstdisable | aresetn_ss);
  wire resetn_forced   = (dftrstdisable | (aresetn_ss & internal_reset_n));

  //---------------------------------------------------------------------------
  // Control the fences, draining, and the SI side, plus interface to the 
  // upstream Q channels
  //---------------------------------------------------------------------------

  // Register static configuration input
  wire pwrq_permit_deny;
 
  adb400_r3_sar
    #(.WIDTH(1))
  u_sar_pwrq_permit_deny
    (
      .aclk     (aclk),
      .aresetn  (resetn_unforced),
      .sample_i (pwrq_permit_deny_sar_i),
      .sample_o (pwrq_permit_deny)
    );

  reg  initiator_quiescentn_q;
  reg  responder_quiescentn_q;
  reg  initiator_quiescent_and_stalledn_q;
  reg  responder_quiescent_and_stalledn_q;

  wire wakeup_local;

  wire initiator_fence_n;
  wire responder_fence_n;
  wire inner_fence_n;
  wire outer_fence_n;

  adb400_r3_si_ctrl
    #(
      .SYNC_LEVELS (SYNC_LEVELS)
    )
  u_si_ctrl
    (
      .aclk                   (aclk),
      .aresetn                (resetn_unforced),

      .pwrq_permit_deny_i     (pwrq_permit_deny),

      .clkqreqn_i             (clkqreqn_i),
      .clkqacceptn_o          (clkqacceptn_o),
      .clkqdeny_o             (clkqdeny_o),
      .clkqactive_o           (clkqactive_o),
      .pwrqreqn_i             (pwrqreqn_i),
      .pwrqacceptn_o          (pwrqacceptn_o),
      .pwrqdeny_o             (pwrqdeny_o),
      .pwrqactive_o           (pwrqactive_o),

      .wakeup_i               (wakeup_i),
      .wakeup_o               (wakeup_o),
      .wakeup_sync_i          (wakeup_local),

      .slvmustacceptreqn_o    (slvmustacceptreqn_async),
      .slvcandenyreqn_o       (slvcandenyreqn_async),
      .slvacceptn_async_i     (slvacceptn_async),
      .slvdeny_async_i        (slvdeny_async),

      .wakeup_async_o         (si_to_mi_wakeup_async),
      .wakeup_async_i         (mi_to_si_wakeup_async),

      .ar_dvm_multipart_quiescent_i (1'b1),
      .ac_dvm_multipart_quiescent_i (1'b1),
      .dvm_sync_complete_quiescent_i (1'b1),
      .initiator_quiescent_i  (~initiator_quiescentn_q),
      .responder_quiescent_i  (~responder_quiescentn_q),
      .initiator_quiescent_and_stalled_i  (~initiator_quiescent_and_stalledn_q),
      .responder_quiescent_and_stalled_i  (~responder_quiescent_and_stalledn_q),

      .initiator_fencen_o     (initiator_fence_n),   
      .responder_fencen_o     (responder_fence_n),
      .inner_fencen_o         (inner_fence_n),       
      .outer_fencen_o         (outer_fence_n),       
      .internal_resetn_o      (internal_reset_n)     
    );


  //---------------------------------------------------------------------------
  // Apply the Q channel outer fence and the quiescence-enforcer fence
  // to the bare interfaces before using them everywhere else
  //---------------------------------------------------------------------------

  reg    fw_hndshk_sticky_q;

  wire   fwvalid_int  = (outer_fence_n & (initiator_fence_n | fw_hndshk_sticky_q) & fwvalid);
  wire   fwready_int;
  assign fwready      = (outer_fence_n & (initiator_fence_n | fw_hndshk_sticky_q) & fwready_int);

  reg    rv_hndshk_sticky_q;

  wire   rvvalid_int;
  assign rvvalid      = (outer_fence_n & (responder_fence_n | rv_hndshk_sticky_q) & rvvalid_int);
  wire   rvready_int  = (outer_fence_n & (responder_fence_n | rv_hndshk_sticky_q) & rvready);

  wire fw_hndshk_sticky_nxt = (fwvalid_int & ~fwready_int);
  wire fw_hndshk_sticky_upd_en = 1'b1;
  always @(posedge aclk or negedge resetn_forced)
    begin : p_hndshk_sticky_fw
      if (! resetn_forced)
        fw_hndshk_sticky_q <= 1'b0;
      else if (fw_hndshk_sticky_upd_en)
        fw_hndshk_sticky_q <= fw_hndshk_sticky_nxt;
    end

  wire rv_hndshk_sticky_nxt = (rvvalid_int & ~rvready_int);
  wire rv_hndshk_sticky_upd_en = 1'b1;
  always @(posedge aclk or negedge resetn_forced)
    begin : p_hndshk_sticky_rv
      if (! resetn_forced)
        rv_hndshk_sticky_q <= 1'b0;
      else if (rv_hndshk_sticky_upd_en)
        rv_hndshk_sticky_q <= rv_hndshk_sticky_nxt;
    end

  //---------------------------------------------------------------------------
  // Signals for all the channel components to use to indicate their non-emptiness
  //---------------------------------------------------------------------------

  wire fw_chan_cactive;
  wire rv_chan_cactive;
  wire rv_reg_cactive;
  wire rvvalid_reg;

  //--------------------------------------------------------------------
  // Combine the activity indicators
  //--------------------------------------------------------------------

  // Must avoid a chan_cactive *alone* causing quiescentn to go high
  // as that would only happen in the reset phase, which we want to avoid.
  
  // Predeclared above
  //reg  initiator_quiescentn_q;
  wire initiator_quiescentn_nxt    = (// Drive high because of a new transfer
                                      (fwvalid_int & fwready_int) |
                                      // Keep high till the transfer has completely left the channel
                                      (initiator_quiescentn_q & fw_chan_cactive)
                                     );
  wire initiator_quiescentn_upd_en = (initiator_quiescentn_q | initiator_quiescentn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_initiator_quiescentn
      if (! resetn_forced)
        initiator_quiescentn_q <= 1'b0;
      else if (initiator_quiescentn_upd_en)
        initiator_quiescentn_q <= initiator_quiescentn_nxt;
    end

  // Predeclared above
  //reg  initiator_quiescent_and_stalledn_q;
  wire initiator_quiescent_and_stalledn_nxt    = (// Drive high because of a new transfer
                                                  (fwvalid_int & fwready_int) |
                                                  // The channel is not stalled
                                                  initiator_fence_n |
                                                  // Keep high till the transfer has completely left the channel
                                                  (initiator_quiescent_and_stalledn_q & fw_chan_cactive)
                                                 );
  wire initiator_quiescent_and_stalledn_upd_en = (initiator_quiescent_and_stalledn_q | initiator_quiescent_and_stalledn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_initiator_quiescent_and_stalledn
      if (! resetn_forced)
        initiator_quiescent_and_stalledn_q <= 1'b0;
      else if (initiator_quiescent_and_stalledn_upd_en)
        initiator_quiescent_and_stalledn_q <= initiator_quiescent_and_stalledn_nxt;
    end

  // Predeclared above
  //reg  responder_quiescentn_q;
  wire responder_quiescentn_nxt    = (// Drive high because of a new transfer
                                      rvvalid_reg |
                                      // Keep high till the transfer has completely left the channel
                                      (responder_quiescentn_q & (rv_chan_cactive | rv_reg_cactive))
                                     );
  wire responder_quiescentn_upd_en = (responder_quiescentn_q | responder_quiescentn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_responder_quiescentn
      if (! resetn_forced)
        responder_quiescentn_q <= 1'b0;
      else if (responder_quiescentn_upd_en)
        responder_quiescentn_q <= responder_quiescentn_nxt;
    end

  // Predeclared above
  //reg  responder_quiescent_and_stalledn_q;
  wire responder_quiescent_and_stalledn_nxt    = (// Drive high because of a new transfer
                                                  rvvalid_reg |
                                                  // The channel is not stalled
                                                  responder_fence_n |
                                                  // Keep high till the transfer has completely left the channel
                                                  (responder_quiescent_and_stalledn_q & (rv_chan_cactive | rv_reg_cactive))
                                                 );
  wire responder_quiescent_and_stalledn_upd_en = (responder_quiescent_and_stalledn_q | responder_quiescent_and_stalledn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_responder_quiescent_and_stalledn
      if (! resetn_forced)
        responder_quiescent_and_stalledn_q <= 1'b0;
      else if (responder_quiescent_and_stalledn_upd_en)
        responder_quiescent_and_stalledn_q <= responder_quiescent_and_stalledn_nxt;
    end


  //--------------------------------------------------------------------
  // The upstream and downstream channel half instances.
  //--------------------------------------------------------------------

  // FW channel

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (FW_PAYLOAD_WIDTH),
      .DEPTH            (FW_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (1)
    )
  u_upstrm_fw
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (fw_chan_cactive),

      .src_valid (fwvalid_int),
      .src_ready (fwready_int),
      .src_payld (fw_payld),
     
      .wr_ptr_async    (fw_wr_ptr_async),
      .rd_ptr_async    (fw_rd_ptr_async),
      .payld_async     (fw_payld_async)
    );

  // RV channel

  // Predeclared above
  //wire                        rvvalid_reg;
  wire                        rvready_reg;
  wire [((RV_PAYLOAD_WIDTH>0)?(RV_PAYLOAD_WIDTH-1):0):0] rv_payld_reg;

  wire rvvalid_chan;
  assign rvvalid_reg = (rvvalid_chan & inner_fence_n);

  assign wakeup_local = (rvvalid_reg | rvvalid_int);

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (RV_PAYLOAD_WIDTH),
      .DEPTH            (RV_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (1)
    )
  u_dnstrm_rv
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (rv_chan_cactive),
  
      .dst_valid (rvvalid_chan),
      .dst_ready (rvready_reg),
      .dst_payld (rv_payld_reg),
     
      .wr_ptr_async    (rv_wr_ptr_async),
      .rd_ptr_async    (rv_rd_ptr_async),
      .payld_async     (rv_payld_async)
    );

  generate
    if ((RV_OPREG==0) || (RV_PAYLOAD_WIDTH==0))
      begin : g_no_rv_opreg
        assign rvvalid_int = rvvalid_reg;
        assign rvready_reg = rvready_int;
        assign rv_payld    = rv_payld_reg;

        assign rv_reg_cactive = 1'b0;
      end
    else
      begin : g_rv_opreg
        assign rv_reg_cactive = rvvalid_int;

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(RV_PAYLOAD_WIDTH))
        u_rv_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (rvvalid_reg),
           .ready_src (rvready_reg),
           .payld_src (rv_payld_reg),
           .valid_dst (rvvalid_int),
           .ready_dst (rvready_int),
           .payld_dst (rv_payld)
          );
      end
  endgenerate

endmodule

