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
// File: adb400_r3_slv_transport_f1.v
//-----------------------------------------------------------------------------
// Purpose : Slave interface half of a 1-channel transport bridge (i.e. no
//           protocol). This is wrapped in an additional layer to
//           provide specific parameters setting and remove unused ports.
//-----------------------------------------------------------------------------

module adb400_r3_slv_transport_f1
  #(parameter
      FIFO_DEPTH       = 6,
      SYNC_LEVELS      = 2,
      PAYLOAD_WIDTH    = 1
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

    //
    // Synchronous interfaces
    //

    // FW channel signalling
    input  wire valid,
    output wire ready,
    input  wire [((PAYLOAD_WIDTH>0)?(PAYLOAD_WIDTH-1):0):0] payld,

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
    output wire [FIFO_DEPTH-1:0] wr_ptr_async,
    input  wire [FIFO_DEPTH-1:0] rd_ptr_async,
    output wire [((PAYLOAD_WIDTH>0)?((PAYLOAD_WIDTH*FIFO_DEPTH)-1):0):0] payld_async
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
  wire responder_quiescent;
  reg  initiator_quiescent_and_stalledn_q;
  wire responder_quiescent_and_stalled;

  wire initiator_fence_n;
  wire responder_fence_n_unused;
  wire inner_fence_n_unused;
  wire outer_fence_n;
  wire wakeup_o_unused;

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
      .wakeup_o               (wakeup_o_unused),
      .wakeup_sync_i          (1'b0),

      .slvmustacceptreqn_o    (slvmustacceptreqn_async),
      .slvcandenyreqn_o       (slvcandenyreqn_async),
      .slvacceptn_async_i     (slvacceptn_async),
      .slvdeny_async_i        (slvdeny_async),

      .wakeup_async_i         (mi_to_si_wakeup_async),
      .wakeup_async_o         (si_to_mi_wakeup_async),

      .ar_dvm_multipart_quiescent_i (1'b1),
      .ac_dvm_multipart_quiescent_i (1'b1),
      .dvm_sync_complete_quiescent_i (1'b1),
      .initiator_quiescent_i  (~initiator_quiescentn_q),
      .responder_quiescent_i  (responder_quiescent),
      .initiator_quiescent_and_stalled_i  (~initiator_quiescent_and_stalledn_q),
      .responder_quiescent_and_stalled_i  (responder_quiescent_and_stalled),

      .initiator_fencen_o     (initiator_fence_n),
      .responder_fencen_o     (responder_fence_n_unused),
      .inner_fencen_o         (inner_fence_n_unused),       
      .outer_fencen_o         (outer_fence_n),       
      .internal_resetn_o      (internal_reset_n)     
    );


  //---------------------------------------------------------------------------
  // Apply the Q channel outer fence and the quiescence-enforcer fence
  // to the bare interfaces before using them everywhere else
  //---------------------------------------------------------------------------

  reg  hndshk_sticky_q;

  wire   valid_int  = (outer_fence_n & (initiator_fence_n | hndshk_sticky_q) & valid);
  wire   ready_int;
  assign ready      = (outer_fence_n & (initiator_fence_n | hndshk_sticky_q) & ready_int);

  wire hndshk_sticky_nxt = (valid_int & ~ready_int);
  wire hndshk_sticky_upd_en = 1'b1;
  always @(posedge aclk or negedge resetn_forced)
    begin : p_hndshk_sticky
      if (! resetn_forced)
        hndshk_sticky_q <= 1'b0;
      else if (hndshk_sticky_upd_en)
        hndshk_sticky_q <= hndshk_sticky_nxt;
    end

  //---------------------------------------------------------------------------
  // Signals for all the channel components to use to indicate their non-emptiness
  //---------------------------------------------------------------------------

  wire chan_cactive;

  //--------------------------------------------------------------------
  // Combine the activity indicators
  //--------------------------------------------------------------------

  // Must avoid a chan_cactive *alone* causing quiescentn to go high
  // as that would only happen in the reset phase, which we want to avoid.
  
  // Predeclared above
  //reg  initiator_quiescentn_q;
  wire initiator_quiescentn_nxt    = (// Drive high because of a new transfer
                                      (valid_int & ready_int) |
                                      // Keep high till the transfer has completely left the channel
                                      (initiator_quiescentn_q & chan_cactive)
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
                                                  (valid_int & ready_int) |
                                                  // The channel is not stalled
                                                  initiator_fence_n |
                                                  // Keep high till the transfer has completely left the channel
                                                  (initiator_quiescent_and_stalledn_q & chan_cactive)
                                                 );
  wire initiator_quiescent_and_stalledn_upd_en = (initiator_quiescent_and_stalledn_q | initiator_quiescent_and_stalledn_nxt);

  always @(posedge aclk or negedge resetn_forced)
    begin : p_initiator_quiescent_and_stalledn
      if (! resetn_forced)
        initiator_quiescent_and_stalledn_q <= 1'b0;
      else if (initiator_quiescent_and_stalledn_upd_en)
        initiator_quiescent_and_stalledn_q <= initiator_quiescent_and_stalledn_nxt;
    end

  assign responder_quiescent = 1'b1;
  assign responder_quiescent_and_stalled = 1'b1;

  //--------------------------------------------------------------------
  // The upstream and downstream channel half instances.
  //--------------------------------------------------------------------

  // Channel

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (PAYLOAD_WIDTH),
      .DEPTH            (FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (1)
    )
  u_upstrm
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (chan_cactive),

      .src_valid (valid_int),
      .src_ready (ready_int),
      .src_payld (payld),
     
      .wr_ptr_async    (wr_ptr_async),
      .rd_ptr_async    (rd_ptr_async),
      .payld_async     (payld_async)
    );

 endmodule

