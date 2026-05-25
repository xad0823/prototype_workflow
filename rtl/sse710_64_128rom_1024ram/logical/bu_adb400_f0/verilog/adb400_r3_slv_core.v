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
// Checked In :  2016-04-21 13:53:38 +0100 (Thu, 21 Apr 2016)
// Revision : 209695
//
// Release Information : PL405-r3p0-01rel0
//
//-----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//-----------------------------------------------------------------------------
// File: adb400_r3_slv_core.v
//-----------------------------------------------------------------------------
// Purpose : Slave interface half of all the protocol variants of the 
//           domain bridge. This is wrapped in an additional layer to
//           provide protocol-specific parameter setting and remove
//           unused ports.
//-----------------------------------------------------------------------------

module adb400_r3_slv_core
  #(parameter
      // Parameters that the user can be set from the top level (in some cases)
      AW_FIFO_DEPTH       = 4,
      W_FIFO_DEPTH        = 6,
      B_FIFO_DEPTH        = 2,
      AR_FIFO_DEPTH       = 4,
      R_FIFO_DEPTH        = 6,
      AC_FIFO_DEPTH       = 2,
      CR_FIFO_DEPTH       = 2,
      CD_FIFO_DEPTH       = 4,
      ACK_FIFO_DEPTH      = 6,
      TKN_FIFO_DEPTH      = 6,
      B_OPREG             = 1,
      R_OPREG             = 1,
      AC_OPREG            = 1,
      SYNC_LEVELS         = 2,
      AW_QVN_DEPTH        = AW_FIFO_DEPTH, // Only used if AW_VN>0
      W_QVN_DEPTH         = W_FIFO_DEPTH,  // Only used if AW_VN>0
      AR_QVN_DEPTH        = AR_FIFO_DEPTH, // Only used if AR_VN>0
      // Parameters that cannot be set on the top level
      AR_VN               = 4,
      AW_VN               = 2,
      // Indices into payload vectors for various fields
      AWBAR_OFFSET        = 0,
      AWSNOOP_OFFSET      = 1,
      AWVNET_OFFSET       = 4, // Only used if AW_VN>0
      WLAST_OFFSET        = 0,
      WVNET_OFFSET        = 1, // Only used if AW_VN>0
      ARBAR_OFFSET        = 0,
      ARVNET_OFFSET       = 1, // Only used if AR_VN>0
      ARSNOOP_OFFSET      = 5, // Only used if AC_FIFO_DEPTH>0
      ARADDR_OFFSET       = 9, // Only used if AC_FIFO_DEPTH>0
      RLAST_OFFSET        = 0,
      ACSNOOP_OFFSET      = 5, // Only used if AC_FIFO_DEPTH>0
      ACADDR_OFFSET       = 9, // Only used if AC_FIFO_DEPTH>0
      CRRESP_OFFSET       = 0, // Only used if CR_FIFO_DEPTH>0
      CDLAST_OFFSET       = 0, // Only used if CD_FIFO_DEPTH>0
      // Widths of the payload vectors (default to the minimum needed for the extraction offsets above)
      AW_PAYLOAD_WIDTH    = 8,
      W_PAYLOAD_WIDTH     = 5,
      B_PAYLOAD_WIDTH     = 1,
      AR_PAYLOAD_WIDTH    = 24,
      R_PAYLOAD_WIDTH     = 1,
      AC_PAYLOAD_WIDTH    = 24, // Only used if AC_FIFO_DEPTH>0
      CR_PAYLOAD_WIDTH    = 1,  // Only used if CR_FIFO_DEPTH>0
      CD_PAYLOAD_WIDTH    = 1,  // Only used if CD_FIFO_DEPTH>0
      // Must not be overridden
      MAX_RD              = 511,
      MAX_WR              = 255,
      MAX_SN              = 255
  )
  (
    // Configuration inputs
    input  wire [((AR_VN==0)?0:(AR_VN-1)):0]     var_prealloc_sar_i,
    input  wire [((AW_VN==0)?0:(AW_VN-1)):0]     vaw_prealloc_sar_i,
    input  wire [((AR_VN==0)?0:((4*AR_VN)-1)):0] var_id_sar_i,
    input  wire [((AW_VN==0)?0:((4*AW_VN)-1)):0] vaw_id_sar_i,
    input  wire                                  pwrq_permit_deny_sar_i,

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
    // NOTE: Only needed for snoops waking up an attached upstream master or subsystem
    output wire                   wakeup_o,

    //
    // Synchronous interfaces
    //

    // AW channel signalling
    input  wire awvalid,
    output wire awready,
    input  wire [AW_PAYLOAD_WIDTH-1:0] aw_payld,

    // W channel signalling
    input  wire wvalid,
    output wire wready,
    input  wire [W_PAYLOAD_WIDTH-1:0] w_payld,

    // B channel signalling
    output wire bvalid,
    input  wire bready,
    output wire [B_PAYLOAD_WIDTH-1:0] b_payld,

    // AR channel signalling
    input  wire arvalid,
    output wire arready,
    input  wire [AR_PAYLOAD_WIDTH-1:0] ar_payld,

    // R channel signalling
    output wire rvalid,
    input  wire rready,
    output wire [R_PAYLOAD_WIDTH-1:0] r_payld,

    // AC channel signalling
    output wire acvalid,
    input  wire acready,
    output wire [((AC_FIFO_DEPTH==0)?0:(AC_PAYLOAD_WIDTH-1)):0] ac_payld,

    // CR channel signalling
    input  wire crvalid,
    output wire crready,
    input  wire [((CR_FIFO_DEPTH==0)?0:(CR_PAYLOAD_WIDTH-1)):0] cr_payld,

    // CD channel signalling
    input  wire cdvalid,
    output wire cdready,
    input  wire [((CD_FIFO_DEPTH==0)?0:(CD_PAYLOAD_WIDTH-1)):0] cd_payld,

    // WACK signalling
    input  wire wack,

    // RACK signalling
    input  wire rack,

    // VN signalling
    input  wire [((AR_VN==0)?0:(AR_VN-1)):0] varvalid,
    output wire [((AR_VN==0)?0:(AR_VN-1)):0] varready,
    input  wire [((AR_VN==0)?0:((4*AR_VN)-1)):0] varqos,

    input  wire [((AW_VN==0)?0:(AW_VN-1)):0] vawvalid,
    output wire [((AW_VN==0)?0:(AW_VN-1)):0] vawready,
    input  wire [((AW_VN==0)?0:((4*AW_VN)-1)):0] vawqos,

    input  wire [((AW_VN==0)?0:(AW_VN-1)):0] vwvalid,
    output wire [((AW_VN==0)?0:(AW_VN-1)):0] vwready,

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

    // P channel signalling
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:1):0]  p_wr_ptr_async,
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:1):0]  p_rd_ptr_async,
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:(2*((AR_VN*4)+(AW_VN*4)))-1):0] p_payld_async,

    // T channel signalling
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:(TKN_FIFO_DEPTH-1)):0]  t_wr_ptr_async,
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:(TKN_FIFO_DEPTH-1)):0]  t_rd_ptr_async,
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:((TKN_FIFO_DEPTH*(((AR_VN<=0)?0:(AR_VN*clogb2(AR_QVN_DEPTH)))+((AW_VN<=0)?0:(AW_VN*clogb2(AW_QVN_DEPTH)))+((AW_VN<=0)?0:(AW_VN*clogb2(W_QVN_DEPTH)))))-1)):0] t_payld_async,

    // AW channel signalling
    output wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    input  wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    output wire [((AW_PAYLOAD_WIDTH+AW_VN)*AW_FIFO_DEPTH)-1:0] aw_payld_async,

    // W channel signalling
    output wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    input  wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    output wire [(( W_PAYLOAD_WIDTH+AW_VN)* W_FIFO_DEPTH)-1:0] w_payld_async,

    // B channel signalling
    input  wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    output wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    input  wire [( B_PAYLOAD_WIDTH* B_FIFO_DEPTH)-1:0] b_payld_async,

    // AR channel signalling
    output wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    input  wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    output wire [((AR_PAYLOAD_WIDTH+AR_VN)*AR_FIFO_DEPTH)-1:0] ar_payld_async,

    // R channel signalling
    input  wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    output wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    input  wire [( R_PAYLOAD_WIDTH* R_FIFO_DEPTH)-1:0] r_payld_async,

    // AC channel signalling
    input  wire [((  AC_FIFO_DEPTH==0)?0:  AC_FIFO_DEPTH-1):0]   ac_wr_ptr_async,
    output wire [((  AC_FIFO_DEPTH==0)?0:  AC_FIFO_DEPTH-1):0]   ac_rd_ptr_async,
    input  wire [((  AC_FIFO_DEPTH==0)?0:((AC_PAYLOAD_WIDTH*AC_FIFO_DEPTH)-1)):0] ac_payld_async,

    // CR channel signalling
    output wire [((  CR_FIFO_DEPTH==0)?0:  CR_FIFO_DEPTH-1):0]   cr_wr_ptr_async,
    input  wire [((  CR_FIFO_DEPTH==0)?0:  CR_FIFO_DEPTH-1):0]   cr_rd_ptr_async,
    output wire [((  CR_FIFO_DEPTH==0)?0:((CR_PAYLOAD_WIDTH*CR_FIFO_DEPTH)-1)):0] cr_payld_async,

    // CD channel signalling
    output wire [((  CD_FIFO_DEPTH==0)?0:  CD_FIFO_DEPTH-1):0]   cd_wr_ptr_async,
    input  wire [((  CD_FIFO_DEPTH==0)?0:  CD_FIFO_DEPTH-1):0]   cd_rd_ptr_async,
    output wire [((  CD_FIFO_DEPTH==0)?0:(CD_PAYLOAD_WIDTH*CD_FIFO_DEPTH)-1):0] cd_payld_async,

    // WACK channel signalling
    output wire [((CD_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] wack_wr_ptr_async,
    input  wire [((CD_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] wack_rd_ptr_async,

    // RACK channel signalling
    output wire [((CD_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] rack_wr_ptr_async,
    input  wire [((CD_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] rack_rd_ptr_async
  );

`include "adb400_r3_functions.v"

  localparam PROTOCOL_CHANNELS = ((CD_FIFO_DEPTH==0)?((AC_FIFO_DEPTH==0)?5:7):10);

  // ----------------------------------------------------------------------
  // Some limits on types of transactions from the ACE Specification
  // ----------------------------------------------------------------------

  // Maximum number of barriers
  localparam MAX_BARRIERS          = 256; // From the ACE spec C8.4.1

  // Maximum number of parts in a multipart DVM message
  localparam MAX_MULTIPART_DVM_PARTS = 2; // Not specified, but implied

  // ----------------------------------------------------------------------
  // Some minimum values for the max-OT limits required for forward progress
  // ----------------------------------------------------------------------

  // In an ACE variant, we must permit >MAX_BARRIERS writes to be
  // outstanding so AW->X counters must be sized to cope with that.
  // Because the registering in the code means it si not possible to achieve
  // the maximum number unless the last two are back-to-back, make this +2 instead of +1
  localparam MIN_WR_OT_COUNT = ((PROTOCOL_CHANNELS<10) ? 1 : (MAX_BARRIERS+2));

  // In an ACE variant, it is possible (but wrong) that a master needs to
  // have issued all MAX_BARRIER_COUNT AR barriers before it issues the 
  // MAX_BARRIER_COUNT'th AW barrier, ahead of its post-max-barriers WB.
  //
  // An ACE-Lite+DVM slave (e.g. an interconnect) might require all parts of
  // a multipart DVM before it can give any response
  localparam MIN_RD_OT_COUNT = ((PROTOCOL_CHANNELS<10) ? ((PROTOCOL_CHANNELS<7) ? 1 : MAX_MULTIPART_DVM_PARTS) : (MAX_BARRIERS+2));

  // An ACE-Lite+DVM master might require all parts of amultipart DVM before
  // it can give any response.
  localparam MIN_SN_OT_COUNT = MAX_MULTIPART_DVM_PARTS;

  // ----------------------------------------------------------------------
  // Resultant counter widths
  // ----------------------------------------------------------------------

  // Work out the maximum of the architecturally-required value and the specified
  // value, find the width required for that, and then get that width's maximum

  localparam WR_OT_WIDTH = clogb2((MIN_WR_OT_COUNT>MAX_WR) ? MIN_WR_OT_COUNT : MAX_WR);
  localparam RD_OT_WIDTH = clogb2((MIN_RD_OT_COUNT>MAX_RD) ? MIN_RD_OT_COUNT : MAX_RD);
  localparam SN_OT_WIDTH = clogb2((MIN_SN_OT_COUNT>MAX_SN) ? MIN_SN_OT_COUNT : MAX_SN);

  // The max xACK must match the max RD/WR OT
  localparam MAX_WACK = ((1<<WR_OT_WIDTH)-1);
  localparam MAX_RACK = ((1<<RD_OT_WIDTH)-1);

  // QVN token counter widths must be set to 0 if not used as they affect the
  // size of the token return channel

  localparam VAR_TKN_WIDTH  = ((AR_VN<=0)?0:clogb2(AR_QVN_DEPTH));
  localparam VAW_TKN_WIDTH  = ((AW_VN<=0)?0:clogb2(AW_QVN_DEPTH));
  localparam  VW_TKN_WIDTH  = ((AW_VN<=0)?0:clogb2( W_QVN_DEPTH));

  // ----------------------------------------------------------------------
  // Some ACE values
  // ----------------------------------------------------------------------

  localparam [2:0] AWSNOOP_EVICT        = 3'b100;
  localparam [3:0] ARSNOOP_DVM_COMPLETE = 4'b1110;
  localparam [3:0] ARSNOOP_DVM_MESSAGE  = 4'b1111;
  localparam [2:0] ARADDR_DVM_SYNC      = 3'b100;
  localparam [3:0] ACSNOOP_DVM_COMPLETE = 4'b1110;
  localparam [3:0] ACSNOOP_DVM_MESSAGE  = 4'b1111;
  localparam [2:0] ACADDR_DVM_SYNC      = 3'b100;


  // ----------------------------------------------------------------------------
  // Reset Synchroniser
  // ----------------------------------------------------------------------------

  wire internal_reset_n;
  wire aresetn_ss;

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
  // Control the fences, draining, and the MI side, plus interface to the 
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

  wire wakeup_local;

  wire read_write_quiescent;
  wire snoop_quiescent;
  wire ar_dvm_multipart_quiescent;
  wire ac_dvm_multipart_quiescent;
  wire dvm_sync_complete_quiescent;
  wire read_write_quiescent_and_stalled;
  wire snoop_quiescent_and_stalled;

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

      .ar_dvm_multipart_quiescent_i (ar_dvm_multipart_quiescent),
      .ac_dvm_multipart_quiescent_i (ac_dvm_multipart_quiescent),
      .dvm_sync_complete_quiescent_i (dvm_sync_complete_quiescent),
      .initiator_quiescent_i  (read_write_quiescent),
      .responder_quiescent_i  (snoop_quiescent),
      .initiator_quiescent_and_stalled_i (read_write_quiescent_and_stalled),
      .responder_quiescent_and_stalled_i (snoop_quiescent_and_stalled),

      .initiator_fencen_o     (initiator_fence_n),   
      .responder_fencen_o     (responder_fence_n),   
      .inner_fencen_o         (inner_fence_n),       
      .outer_fencen_o         (outer_fence_n),       
      .internal_resetn_o      (internal_reset_n)     
    );


  //---------------------------------------------------------------------------
  // Apply the Q channel outer fence and the protocol-tracker capacity fence
  // to the bare interfaces before using them everywhere else
  //---------------------------------------------------------------------------

  // The protocol tracker capacity stall signals
  wire stall_aw_n;
  wire stall_w_n;
  wire stall_b_n_unused;
  wire stall_ar_n;
  wire stall_ac_n;
  wire [((AR_VN>0)?(AR_VN-1):0):0] stall_var_n;
  wire [((AW_VN>0)?(AW_VN-1):0):0] stall_vaw_n;
  wire [((AW_VN>0)?(AW_VN-1):0):0] stall_vw_n;

  wire   awvalid_int  = (outer_fence_n & stall_aw_n & awvalid);
  wire   awready_int;
  assign awready      = (outer_fence_n & stall_aw_n & awready_int);
  wire   wvalid_int   = (outer_fence_n & stall_w_n  & wvalid);
  wire   wready_int;
  assign wready       = (outer_fence_n & stall_w_n  & wready_int);
  wire   arvalid_int  = (outer_fence_n & stall_ar_n & arvalid);
  wire   arready_int;
  assign arready      = (outer_fence_n & stall_ar_n & arready_int);

  wire   acvalid_int;
  wire   acready_int;
  generate  
    if (AC_FIFO_DEPTH<=0)
      begin : g_no_ac_no_fence
        assign acvalid      = 1'b0;
        assign acready_int  = 1'b0;
        wire stall_ac_n_unused  = stall_ac_n;
        wire acvalid_int_unused = acvalid_int;
      end
    else
      begin : g_ac_so_fence
        assign acvalid      = (outer_fence_n & stall_ac_n & acvalid_int);
        assign acready_int  = (outer_fence_n & stall_ac_n & acready);
      end
  endgenerate

  wire   bvalid_int;
  assign bvalid       = (outer_fence_n & bvalid_int);
  wire   bready_int   = (outer_fence_n & bready);
  wire   rvalid_int;
  assign rvalid       = (outer_fence_n & rvalid_int);
  wire   rready_int   = (outer_fence_n & rready);

  wire   crvalid_int;
  wire   crready_int;
  generate  
    if (CR_FIFO_DEPTH<=0)
      begin : g_no_cr_no_fence
        assign crvalid_int  = 1'b0;
        assign crready      = 1'b0;
        wire crready_int_unused = crready_int;
      end
    else
      begin : g_cr_so_fence
        assign crvalid_int  = (outer_fence_n & crvalid);
        assign crready      = (outer_fence_n & crready_int);
      end
  endgenerate

  wire   cdvalid_int;
  wire   cdready_int;
  generate  
    if (CD_FIFO_DEPTH<=0)
      begin : g_no_cd_no_fence
        assign cdvalid_int  = 1'b0;
        assign cdready      = 1'b0;
        wire cdready_int_unused = cdready_int;
      end
    else
      begin : g_cd_so_fence
        assign cdvalid_int  = (outer_fence_n & cdvalid);
        assign cdready      = (outer_fence_n & cdready_int);
      end
  endgenerate

  // Assignment of these is inside the QVN handling generate block
  wire [((AR_VN>0)?(AR_VN-1):0):0] varvalid_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vawvalid_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vwvalid_int;


  //---------------------------------------------------------------------------
  // Track protocol quiescence (and stall channels that would otherwise
  // overflow the tracker)
  //---------------------------------------------------------------------------

  wire rlast = r_payld[RLAST_OFFSET];
  wire wlast = w_payld[WLAST_OFFSET];

  wire arbar;
  wire awbar;
  wire aw_evict;

  wire ar_dvm_sync;
  wire ar_dvm_complete;
  wire ac_dvm_sync;
  wire ac_dvm_complete;

  wire cr_pass_data;
  wire cdlast;

  generate
    if (AWSNOOP_OFFSET<0)
      begin : g_awsnoop_absent
        assign aw_evict = 1'b0;
      end
    else
      begin : g_awsnoop_present
        assign aw_evict = (AWSNOOP_EVICT == aw_payld[AWSNOOP_OFFSET+:3]);
      end

    if (ARBAR_OFFSET<0)
      begin : g_arbar_absent
        assign arbar = 1'b0;
      end
    else
      begin : g_arbar_present
        assign arbar = ar_payld[ARBAR_OFFSET];
      end
    if (AWBAR_OFFSET<0)
      begin : g_awbar_absent
        assign awbar = 1'b0;
      end
    else
      begin : g_awbar_present
        assign awbar = aw_payld[AWBAR_OFFSET];
      end

    if (AC_FIFO_DEPTH<=0)
      begin : g_ar_ac_dvm_sync_complete_absent
        assign ar_dvm_sync     = 1'b0;
        assign ar_dvm_complete = 1'b0;
        assign ac_dvm_sync     = 1'b0;
        assign ac_dvm_complete = 1'b0;
        assign ar_dvm_multipart_quiescent = 1'b1;
        assign ac_dvm_multipart_quiescent = 1'b1;
      end
    else
      begin : g_ar_ac_dvm_sync_complete_present
        reg  ar_dvm_multipart_in_progress_q;
        wire ar_dvm_multipart_in_progress_nxt = ar_payld[ARADDR_OFFSET];
        wire ar_dvm_multipart_in_progress_upd_en = (arvalid & arready &
                                                    (ARSNOOP_DVM_MESSAGE  == ar_payld[ARSNOOP_OFFSET+:4]));

        always @(posedge aclk or negedge resetn_forced)
          begin : p_ar_dvm_multipart_in_progress
            if (! resetn_forced)
              ar_dvm_multipart_in_progress_q <= 1'b0;
            else if (ar_dvm_multipart_in_progress_upd_en)
              ar_dvm_multipart_in_progress_q <= ar_dvm_multipart_in_progress_nxt;
          end

        assign ar_dvm_sync     = ((ARSNOOP_DVM_MESSAGE  == ar_payld[ARSNOOP_OFFSET+:4]) &
                                  (ARADDR_DVM_SYNC      == ar_payld[ARADDR_OFFSET+12+:3]) &
                                  ~ar_dvm_multipart_in_progress_q);
        assign ar_dvm_complete =  (ARSNOOP_DVM_COMPLETE == ar_payld[ARSNOOP_OFFSET+:4]);


        reg  ac_dvm_multipart_in_progress_q;
        wire ac_dvm_multipart_in_progress_nxt = ac_payld[ACADDR_OFFSET];
        wire ac_dvm_multipart_in_progress_upd_en = (acvalid & acready &
                                                    (ACSNOOP_DVM_MESSAGE  == ac_payld[ACSNOOP_OFFSET+:4]));

        always @(posedge aclk or negedge resetn_forced)
          begin : p_ac_dvm_multipart_in_progress
            if (! resetn_forced)
              ac_dvm_multipart_in_progress_q <= 1'b0;
            else if (ac_dvm_multipart_in_progress_upd_en)
              ac_dvm_multipart_in_progress_q <= ac_dvm_multipart_in_progress_nxt;
          end

        assign ac_dvm_sync     = ((ACSNOOP_DVM_MESSAGE  == ac_payld[ACSNOOP_OFFSET+:4]) &
                                  (ACADDR_DVM_SYNC      == ac_payld[ACADDR_OFFSET+12+:3]) &
                                  ~ac_dvm_multipart_in_progress_q);
        assign ac_dvm_complete =  (ACSNOOP_DVM_COMPLETE == ac_payld[ACSNOOP_OFFSET+:4]);

        assign ar_dvm_multipart_quiescent = ~ar_dvm_multipart_in_progress_q;
        assign ac_dvm_multipart_quiescent = ~ac_dvm_multipart_in_progress_q;
      end
  endgenerate

  wire rack_hndshk;
  wire wack_hndshk;

  wire [((AR_VN>0)?AR_VN:1)-1:0] ar_vnpid;
  wire [((AW_VN>0)?AW_VN:1)-1:0] aw_vnpid;
  wire [((AW_VN>0)?AW_VN:1)-1:0] w_vnpid;

  adb400_r3_protocol_quiescent
    #(
      .PROTOCOL_CHANNELS (PROTOCOL_CHANNELS),
      .AR_VN             (AR_VN),
      .AW_VN             (AW_VN),
      .AR_QVN_DEPTH      (AR_QVN_DEPTH),
      .AW_QVN_DEPTH      (AW_QVN_DEPTH),
      .W_QVN_DEPTH       (W_QVN_DEPTH),
      .RD_OT_WIDTH       (RD_OT_WIDTH),
      .WR_OT_WIDTH       (WR_OT_WIDTH),
      .SN_OT_WIDTH       (SN_OT_WIDTH)
    )
  u_protocol_quiescent
    (
      .aclk    (aclk),
      .aresetn (resetn_forced),

      .dvm_sync_complete_quiescent_o (dvm_sync_complete_quiescent),
      .read_write_quiescent_o (read_write_quiescent),
      .snoop_quiescent_o      (snoop_quiescent),
      .read_write_quiescent_and_stalled_o (read_write_quiescent_and_stalled),
      .snoop_quiescent_and_stalled_o (snoop_quiescent_and_stalled),

      .force_read_write_quiescence_n_i (initiator_fence_n),
      .force_snoop_quiescence_n_i      (responder_fence_n),
      .stall_ar_n_o           (stall_ar_n),
      .stall_aw_n_o           (stall_aw_n),
      .stall_w_n_o            (stall_w_n),
      .stall_b_n_o            (stall_b_n_unused),
      .stall_ac_n_o           (stall_ac_n),

      .arvalid_i              (arvalid_int),
      .arready_i              (arready),
      .rvalid_i               (rvalid),
      .rready_i               (rready_int),
      .rlast_i                (rlast),
      .awvalid_i              (awvalid_int),
      .awready_i              (awready),
      .awbar_i                (awbar),
      .wvalid_i               (wvalid_int),
      .wready_i               (wready),
      .wlast_i                (wlast),
      .bvalid_i               (bvalid),
      .bready_i               (bready_int),
      .ar_dvm_sync_i          (ar_dvm_sync),
      .ar_dvm_complete_i      (ar_dvm_complete),
      .acvalid_i              (acvalid),
      .acready_i              (acready_int),
      .ac_dvm_sync_i          (ac_dvm_sync),
      .ac_dvm_complete_i      (ac_dvm_complete),
      .crvalid_i              (crvalid_int),
      .crready_i              (crready),
      .aw_evict_i             (aw_evict),
      .cr_pass_data_i         (cr_pass_data),
      .cdvalid_i              (cdvalid_int),
      .cdready_i              (cdready),
      .cdlast_i               (cdlast),
      .rack_i                 (rack_hndshk),
      .wack_i                 (wack_hndshk),
      .arbar_i                (arbar),
      .varvalid_i             (varvalid_int),
      .varready_i             (varready),
      .arvnpid_i              (ar_vnpid),
      .vawvalid_i             (vawvalid_int),
      .vawready_i             (vawready),
      .awvnpid_i              (aw_vnpid),
      .vwvalid_i              (vwvalid_int),
      .vwready_i              (vwready),
      .wvnpid_i               (w_vnpid),
      .stall_var_n_o          (stall_var_n),
      .stall_vaw_n_o          (stall_vaw_n),
      .stall_vw_n_o           (stall_vw_n)
    );

  //--------------------------------------------------------------------
  // The VN token mechanism and QoS promotion
  //--------------------------------------------------------------------

  genvar i, j, k;
  generate
    if ((AW_VN==0) && (AR_VN==0))
      begin : g_not_vn_enabled

        assign varvalid_int = 1'b0;
        assign varready     = 1'b0;
        assign vawvalid_int = 1'b0;
        assign vawready     = 1'b0;
        assign  vwvalid_int = 1'b0;
        assign  vwready     = 1'b0;

        assign ar_vnpid     = 1'b0;
        assign aw_vnpid     = 1'b0;
        assign  w_vnpid     = 1'b0;

        assign p_wr_ptr_async = 1'b0;
        assign p_payld_async = 1'b0;

        assign t_rd_ptr_async = 1'b0;

        wire vawvalid_unused = vawvalid;
        wire vawqos_unused = vawqos;
        wire vwvalid_unused = vwvalid;
        wire varvalid_unused = varvalid;
        wire varqos_unused = varqos;

        wire stall_var_n_unused = stall_var_n;
        wire stall_vaw_n_unused = stall_vaw_n;
        wire stall_vw_n_unused  = stall_vw_n;

        wire var_prealloc_sar_i_unused = var_prealloc_sar_i;
        wire vaw_prealloc_sar_i_unused = vaw_prealloc_sar_i;

        wire p_rd_ptr_async_unused = p_rd_ptr_async;
        wire t_wr_ptr_async_unused = t_wr_ptr_async;
        wire t_payld_async_unused = t_payld_async;


      end
    else
      begin : g_vn_enabled

        wire ar_promote;
        wire aw_promote;

        wire pready;
        wire pvalid;
        wire [(AW_VN*4)+(AR_VN*4)-1:0] p_payld;

        // Put something into the channel when there is a promotion value or
        // the last thing in was a non-zero value
        // pready not required functionally, but input stability checks on the
        // channel require it to avoid firing when the promotion value changes
        // while there is backpressure

        wire p_chan_cactive_unused;
        assign pvalid = ((aw_promote | ar_promote) & pready); 
 
        adb400_r3_upstrm_payld
          #(
            .WIDTH            ((AW_VN*4)+(AR_VN*4)),
            .DEPTH            (2),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_p
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (p_chan_cactive_unused),
        
            .src_valid (pvalid),
            .src_ready (pready),
            .src_payld (p_payld),
           
            .wr_ptr_async    (p_wr_ptr_async),
            .rd_ptr_async    (p_rd_ptr_async),
            .payld_async     (p_payld_async)
          );

        // The async FIFO returning tokens to the slave interface side

        wire t_chan_cactive_unused;
        wire tvalid;
        wire [(AW_VN*VAW_TKN_WIDTH)+(AW_VN*VW_TKN_WIDTH)+(AR_VN*VAR_TKN_WIDTH)-1:0] t_payld;
      
        adb400_r3_dnstrm_payld
          #(
            .WIDTH            ((AW_VN*VAW_TKN_WIDTH)+(AW_VN*VW_TKN_WIDTH)+(AR_VN*VAR_TKN_WIDTH)),
            .DEPTH            (TKN_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_tokens
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (t_chan_cactive_unused),
      
            .dst_valid (tvalid),
            .dst_ready (1'b1),
            .dst_payld (t_payld),
           
            .wr_ptr_async    (t_wr_ptr_async),
            .rd_ptr_async    (t_rd_ptr_async),
            .payld_async     (t_payld_async)
          );

      
        if (AR_VN==0)
          begin : g_AR_VN_eq_0

            assign varvalid_int = 1'b0;
            assign varready     = 1'b0;

            assign ar_vnpid     = 1'b0;

            assign ar_promote   = 1'b0;

            wire varvalid_unused = varvalid;
            wire varqos_unused = varqos;
            wire stall_var_n_unused = stall_var_n;
            wire var_prealloc_sar_i_unused = var_prealloc_sar_i;
            wire var_id_sar_i_unused = var_id_sar_i;

          end
        else
          begin : g_AR_VN_gt_0

            wire [((AR_VN>0)?(AR_VN-1):0):0] varready_int;

            // Register static configuration inputs
            wire [AR_VN-1:0] ar_tkn_prealloc;
           
            adb400_r3_sar
              #(.WIDTH(AR_VN))
            u_sar_prealloc_ar
              (
                .aclk     (aclk),
                .aresetn  (resetn_unforced),
                .sample_i (var_prealloc_sar_i),
                .sample_o (ar_tkn_prealloc)
              );

            wire [(4*AR_VN)-1:0] ar_vnlid;
          
            adb400_r3_sar
              #(.WIDTH(4*AR_VN))
            u_sar_ar_vnid
              (
                .aclk (aclk),
                .aresetn (resetn_unforced),
                .sample_i (var_id_sar_i),
                .sample_o (ar_vnlid)
              );

            assign varvalid_int = ({AR_VN{outer_fence_n}} & stall_var_n & varvalid);
            assign varready     = ({AR_VN{outer_fence_n}} & stall_var_n & varready_int);

            wire [(AR_VN*VAR_TKN_WIDTH)-1:0] ar_tkn_return_count = 
              t_payld[0+:(AR_VN*VAR_TKN_WIDTH)];

            wire [(4*AR_VN)-1:0] ar_promotion_qv;

            assign p_payld [0+:(4*AR_VN)] = ar_promotion_qv;

            adb400_r3_upstrm_qvn
              #(
                .DEPTH            (AR_QVN_DEPTH),
                .VN               (AR_VN),
                .QOS_PRESENT      (1)
              )
            u_upstrm_qvn_ar
              (
                .aclk             (aclk),
                .aresetn          (resetn_forced),
            
                .vx_prealloc_i    (ar_tkn_prealloc),
                .vx_id_i          (ar_vnlid),
            
                .valid_i          (arvalid_int),
                .ready_i          (arready_int),
                .bar_i            (arbar),
                .vnet_i           (ar_payld[ARVNET_OFFSET+:4]),
                .vnpid_1h_o       (ar_vnpid),
               
                .vxvalid          (varvalid_int),
                .vxready          (varready_int),
                .vxqos            (varqos),
            
                .tkn_return       (tvalid),
                .tkn_return_count (ar_tkn_return_count),
            
                .promotion_qv     (ar_promotion_qv),
                .promote          (ar_promote),
                .promote_ack      (pvalid)
              );

          end

        if (AW_VN==0)
          begin : g_AW_VN_eq_0

            assign vawvalid_int = 1'b0;
            assign vawready     = 1'b0;
            assign  vwvalid_int = 1'b0;
            assign  vwready     = 1'b0;

            assign aw_vnpid     = 1'b0;
            assign  w_vnpid     = 1'b0;

            assign aw_promote   = 1'b0;

            wire vawvalid_unused = vawvalid;
            wire vawqos_unused = vawqos;
            wire vwvalid_unused = vwvalid;
            wire stall_vaw_n_unused = stall_vaw_n;
            wire stall_vw_n_unused  = stall_vw_n;
            wire vaw_prealloc_sar_i_unused = vaw_prealloc_sar_i;

          end
        else
          begin : g_AW_VN_gt_0

            wire [((AW_VN>0)?(AW_VN-1):0):0] vawready_int;
            wire [((AW_VN>0)?(AW_VN-1):0):0] vwready_int;

            // Register static configuration inputs
            wire [AW_VN-1:0] aw_tkn_prealloc;
            
            adb400_r3_sar
              #(.WIDTH(AW_VN))
            u_sar_prealloc
              (
                .aclk     (aclk),
                .aresetn  (resetn_unforced),
                .sample_i (vaw_prealloc_sar_i),
                .sample_o (aw_tkn_prealloc)
              );

            wire [(4*AW_VN)-1:0] aw_vnlid;
          
            adb400_r3_sar
              #(.WIDTH(4*AW_VN))
            u_sar_aw_vnlid
              (
                .aclk (aclk),
                .aresetn (resetn_unforced),
                .sample_i (vaw_id_sar_i),
                .sample_o (aw_vnlid)
              );

            assign vawvalid_int = ({AW_VN{outer_fence_n}} & stall_vaw_n & vawvalid);
            assign vawready     = ({AW_VN{outer_fence_n}} & stall_vaw_n & vawready_int);
            assign  vwvalid_int = ({AW_VN{outer_fence_n}} & stall_vw_n & vwvalid);
            assign  vwready     = ({AW_VN{outer_fence_n}} & stall_vw_n & vwready_int);

            wire [(AW_VN*VAW_TKN_WIDTH)-1:0] aw_tkn_return_count =
              t_payld[(AR_VN*VAR_TKN_WIDTH)+:(AW_VN*VAW_TKN_WIDTH)];
            wire [(AW_VN* VW_TKN_WIDTH)-1:0]  w_tkn_return_count =
              t_payld[(AR_VN*VAR_TKN_WIDTH)+(AW_VN*VAW_TKN_WIDTH)+:(AW_VN*VW_TKN_WIDTH)];

            wire [(4*AW_VN)-1:0] aw_promotion_qv;

            assign p_payld [(4*AR_VN)+:(4*AW_VN)] = aw_promotion_qv;

            adb400_r3_upstrm_qvn
              #(
                .DEPTH            (AW_QVN_DEPTH),
                .VN               (AW_VN),
                .QOS_PRESENT      (1)
              )
            u_upstrm_qvn_aw
              (
                .aclk             (aclk),
                .aresetn          (resetn_forced),
            
                .vx_prealloc_i    (aw_tkn_prealloc),
                .vx_id_i          (aw_vnlid),
            
                .valid_i          (awvalid_int),
                .ready_i          (awready_int),
                .bar_i            (awbar),
                .vnet_i           (aw_payld[AWVNET_OFFSET+:4]),
                .vnpid_1h_o       (aw_vnpid),
            
                .vxvalid          (vawvalid_int),
                .vxready          (vawready_int),
                .vxqos            (vawqos),
            
                .tkn_return       (tvalid),
                .tkn_return_count (aw_tkn_return_count),
            
                .promotion_qv     (aw_promotion_qv),
                .promote          (aw_promote),
                .promote_ack      (pvalid)
              );


            wire w_promotion_qv_unused;
            wire w_promote_unused;
    
            adb400_r3_upstrm_qvn
              #(
                .DEPTH            (W_QVN_DEPTH),
                .VN               (AW_VN),
                .QOS_PRESENT      (0)
              )
            u_upstrm_qvn_w
              (
                .aclk             (aclk),
                .aresetn          (resetn_forced),
    
                .vx_prealloc_i    ({AW_VN{1'b0}}),
                .vx_id_i          (aw_vnlid),
    
                .valid_i          (wvalid_int),
                .ready_i          (wready_int),
                .bar_i            (1'b0),
                .vnet_i           (w_payld[WVNET_OFFSET+:4]),
                .vnpid_1h_o       (w_vnpid),
               
                .vxvalid          (vwvalid_int),
                .vxready          (vwready_int),
                .vxqos            (1'b0),
          
                .tkn_return       (tvalid),
                .tkn_return_count (w_tkn_return_count),
          
                .promotion_qv     (w_promotion_qv_unused),
                .promote          (w_promote_unused),
                .promote_ack      (1'b0)
              );
    
          end

      end

  endgenerate


  //--------------------------------------------------------------------
  // The upstream and downstream channel half instances.
  //--------------------------------------------------------------------

  // AW channel

  localparam AW_QVN_PAYLOAD_WIDTH = (AW_PAYLOAD_WIDTH + AW_VN);

  wire [AW_QVN_PAYLOAD_WIDTH-1:0] aw_payld_int;

  generate
    if (AW_VN==0)
      begin : g_no_aw_qvn
        assign aw_payld_int =  aw_payld;
      end
    else
      begin : g_aw_qvn
        assign aw_payld_int = {aw_payld,aw_vnpid};
      end
  endgenerate

  wire aw_chan_cactive_unused;

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (AW_QVN_PAYLOAD_WIDTH),
      .DEPTH            (AW_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_upstrm_aw
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (aw_chan_cactive_unused),

      .src_valid (awvalid_int),
      .src_ready (awready_int),
      .src_payld (aw_payld_int),
     
      .wr_ptr_async    (aw_wr_ptr_async),
      .rd_ptr_async    (aw_rd_ptr_async),
      .payld_async     (aw_payld_async)
    );


  // W channel

  localparam W_QVN_PAYLOAD_WIDTH = (W_PAYLOAD_WIDTH + AW_VN);

  wire [W_QVN_PAYLOAD_WIDTH-1:0] w_payld_int;

  generate
    if (AW_VN==0)
      begin : g_no_w_qvn
        assign w_payld_int =  w_payld;
      end
    else
      begin : g_w_qvn
        assign w_payld_int = {w_payld,w_vnpid};
      end
  endgenerate

  wire w_chan_cactive_unused;

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (W_QVN_PAYLOAD_WIDTH),
      .DEPTH            (W_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_upstrm_w
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (w_chan_cactive_unused),

      .src_valid (wvalid_int),
      .src_ready (wready_int),
      .src_payld (w_payld_int),
     
      .wr_ptr_async    (w_wr_ptr_async),
      .rd_ptr_async    (w_rd_ptr_async),
      .payld_async     (w_payld_async)
    );


  // B channel

  wire                       bvalid_reg;
  wire                       bready_reg;
  wire [B_PAYLOAD_WIDTH-1:0] b_payld_reg;

  wire bvalid_chan;
  assign bvalid_reg = (bvalid_chan & inner_fence_n);

  wire b_chan_cactive_unused;

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (B_PAYLOAD_WIDTH),
      .DEPTH            (B_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_dnstrm_b
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (b_chan_cactive_unused),
  
      .dst_valid (bvalid_chan),
      .dst_ready (bready_reg),
      .dst_payld (b_payld_reg),
     
      .wr_ptr_async    (b_wr_ptr_async),
      .rd_ptr_async    (b_rd_ptr_async),
      .payld_async     (b_payld_async)
    );

  generate
    if (B_OPREG==0)
      begin : g_no_b_opreg
        assign bvalid_int = bvalid_reg;
        assign bready_reg = bready_int;
        assign b_payld    = b_payld_reg;
      end
    else
      begin : g_b_opreg
        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(B_PAYLOAD_WIDTH))
        u_b_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (bvalid_reg),
           .ready_src (bready_reg),
           .payld_src (b_payld_reg),
           .valid_dst (bvalid_int),
           .ready_dst (bready_int),
           .payld_dst (b_payld)
          );
      end
  endgenerate


  // AR channel

  localparam AR_QVN_PAYLOAD_WIDTH = (AR_PAYLOAD_WIDTH + AR_VN);

  wire [AR_QVN_PAYLOAD_WIDTH-1:0] ar_payld_int;

  generate
    if (AR_VN==0)
      begin : g_no_ar_qvn
        assign ar_payld_int =  ar_payld;
      end
    else
      begin : g_ar_qvn
        assign ar_payld_int = {ar_payld,ar_vnpid};
      end
  endgenerate

  wire ar_chan_cactive_unused;

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (AR_QVN_PAYLOAD_WIDTH),
      .DEPTH            (AR_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_upstrm_ar
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (ar_chan_cactive_unused),

      .src_valid (arvalid_int),
      .src_ready (arready_int),
      .src_payld (ar_payld_int),
     
      .wr_ptr_async    (ar_wr_ptr_async),
      .rd_ptr_async    (ar_rd_ptr_async),
      .payld_async     (ar_payld_async)
    );


  // R channel

  wire                       rvalid_reg;
  wire                       rready_reg;
  wire [R_PAYLOAD_WIDTH-1:0] r_payld_reg;
  
  wire rvalid_chan;
  assign rvalid_reg = (rvalid_chan & inner_fence_n);

  wire r_chan_cactive_unused;

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (R_PAYLOAD_WIDTH),
      .DEPTH            (R_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_dnstrm_r
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (r_chan_cactive_unused),
  
      .dst_valid (rvalid_chan),
      .dst_ready (rready_reg),
      .dst_payld (r_payld_reg),
     
      .wr_ptr_async    (r_wr_ptr_async),
      .rd_ptr_async    (r_rd_ptr_async),
      .payld_async     (r_payld_async)
    );

  generate
    if (R_OPREG==0)
      begin : g_no_r_opreg
        assign rvalid_int = rvalid_reg;
        assign rready_reg = rready_int;
        assign r_payld    = r_payld_reg;
      end
    else
      begin : g_r_opreg

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(R_PAYLOAD_WIDTH))
        u_r_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (rvalid_reg),
           .ready_src (rready_reg),
           .payld_src (r_payld_reg),
           .valid_dst (rvalid_int),
           .ready_dst (rready_int),
           .payld_dst (r_payld)
          );
      end
  endgenerate

  generate

    // AC channel

    if (AC_FIFO_DEPTH<=0)
      begin : g_AC_FIFO_DEPTH_le_0

        assign wakeup_local = 1'b0;

        assign acvalid_int = 1'b0;
        assign ac_payld = 1'b0;
        assign ac_rd_ptr_async = 1'b0;

        wire ac_wr_ptr_async_unused = ac_wr_ptr_async;

      end
    else
      begin : g_AC_FIFO_DEPTH_gt_0

        wire                        acvalid_reg;
        wire                        acready_reg;
        wire [AC_PAYLOAD_WIDTH-1:0] ac_payld_reg;

        wire acvalid_chan;
        assign acvalid_reg = (acvalid_chan & inner_fence_n);

        wire ac_chan_cactive_unused;

        assign wakeup_local = (acvalid_reg | acvalid_int);

        adb400_r3_dnstrm_payld
          #(
            .WIDTH            (AC_PAYLOAD_WIDTH),
            .DEPTH            (AC_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_ac
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (ac_chan_cactive_unused),
      
            .dst_valid (acvalid_chan),
            .dst_ready (acready_reg),
            .dst_payld (ac_payld_reg),
           
            .wr_ptr_async    (ac_wr_ptr_async),
            .rd_ptr_async    (ac_rd_ptr_async),
            .payld_async     (ac_payld_async)
          );

        if (AC_OPREG==0)
          begin : g_no_ac_opreg
            assign acvalid_int = acvalid_reg;
            assign acready_reg = acready_int;
            assign ac_payld    = ac_payld_reg;
          end
        else
          begin : g_ac_opreg
            adb400_r3_ful_regd_slice
              #(.PAYLD_WIDTH(AC_PAYLOAD_WIDTH))
            u_ac_opreg
              (
               .aclk      (aclk),
               .aresetn   (resetn_forced),
               .valid_src (acvalid_reg),
               .ready_src (acready_reg),
               .payld_src (ac_payld_reg),
               .valid_dst (acvalid_int),
               .ready_dst (acready_int),
               .payld_dst (ac_payld)
              );
          end
      end


    // CR channel

    if (CR_FIFO_DEPTH<=0)
      begin : g_CR_FIFO_DEPTH_le_0

        assign crready_int = 1'b0;
        assign cr_wr_ptr_async = 1'b0;
        assign cr_payld_async = 1'b0;
        assign cr_pass_data = 1'b0;

        wire cr_rd_ptr_async_unused = cr_rd_ptr_async;
        wire cr_payld_unused = cr_payld[0];

      end
    else
      begin : g_CR_FIFO_DEPTH_gt_0

        assign cr_pass_data = cr_payld[CRRESP_OFFSET];

        wire cr_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .WIDTH            (CR_PAYLOAD_WIDTH),
            .DEPTH            (CR_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_cr
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (cr_chan_cactive_unused),
        
            .src_valid (crvalid_int),
            .src_ready (crready_int),
            .src_payld (cr_payld),
           
            .wr_ptr_async    (cr_wr_ptr_async),
            .rd_ptr_async    (cr_rd_ptr_async),
            .payld_async     (cr_payld_async)
          );

      end


    // CD channel

    if (CD_FIFO_DEPTH<=0)
      begin : g_CD_FIFO_DEPTH_le_0

        assign cdready_int = 1'b0;
        assign cd_wr_ptr_async = 1'b0;
        assign cd_payld_async = 1'b0;
        assign cdlast = 1'b0;

        wire cd_rd_ptr_async_unused = cd_rd_ptr_async;
        wire cd_payld_unused = cd_payld;

      end
    else
      begin : g_CD_FIFO_DEPTH_gt_0

        assign cdlast = cd_payld[CDLAST_OFFSET];

        wire cd_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .WIDTH            (CD_PAYLOAD_WIDTH),
            .DEPTH            (CD_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_cd
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (cd_chan_cactive_unused),
        
            .src_valid (cdvalid_int),
            .src_ready (cdready_int),
            .src_payld (cd_payld),
           
            .wr_ptr_async    (cd_wr_ptr_async),
            .rd_ptr_async    (cd_rd_ptr_async),
            .payld_async     (cd_payld_async)
          );

      end

    if (ACK_FIFO_DEPTH<=0)
      begin : g_ACK_FIFO_DEPTH_le_0

        assign wack_wr_ptr_async = 1'b0;
        assign wack_hndshk = 1'b0;
        
        assign rack_wr_ptr_async = 1'b0;
        assign rack_hndshk = 1'b0;

        wire rack_unused = rack;
        wire wack_unused = wack;

        wire wack_rd_ptr_async_unused = wack_rd_ptr_async;
        wire rack_rd_ptr_async_unused = rack_rd_ptr_async;

      end
    else
      begin : g_ACK_FIFO_DEPTH_gt_0

        wire   wack_int     = (outer_fence_n & wack);
        wire   rack_int     = (outer_fence_n & rack);

        // As a master cannot track xACK once issued, it cannot know when it
        // has passed into the bridge so the event_to_hndshk module's cactive is
        // used to prevent the xACK channels from having their ingress
        // blocked by a powerdown sequence before all xACK are in the bridge.
        // Masters must still ensure that they do not cause a powerdown to
        // start before *they* have protocologically quiescent.

        // WACK channel

        wire wack_valid;
        wire wack_ready;
        wire wack_payld_async_unused;

        adb400_r3_event_to_hndshk
          #(
            .EVENT_COUNT_MAX  (MAX_WACK)
          )
        u_count_wack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
        
            .src_event_i      (wack_int),
            .dst_valid_o      (wack_valid),
            .dst_ready_i      (wack_ready)
          );

        wire wack_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .DEPTH            (ACK_FIFO_DEPTH),
            .WIDTH            (0),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_wack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
            .cactive          (wack_chan_cactive_unused),
        
            .src_valid        (wack_valid),
            .src_ready        (wack_ready),
            .src_payld        (1'b0),

            .wr_ptr_async     (wack_wr_ptr_async),
            .rd_ptr_async     (wack_rd_ptr_async),
            .payld_async      (wack_payld_async_unused)
          );

        assign wack_hndshk = (wack_valid & wack_ready);


        // RACK channel

        wire rack_valid;
        wire rack_ready;
        wire rack_payld_async_unused;

        adb400_r3_event_to_hndshk
          #(
            .EVENT_COUNT_MAX  (MAX_RACK)
          )
        u_count_rack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
        
            .src_event_i      (rack_int),
            .dst_valid_o      (rack_valid),
            .dst_ready_i      (rack_ready)
          );

        wire rack_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .DEPTH            (ACK_FIFO_DEPTH),
            .WIDTH            (0),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_rack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
            .cactive          (rack_chan_cactive_unused),
        
            .src_valid        (rack_valid),
            .src_ready        (rack_ready),
            .src_payld        (1'b0),

            .wr_ptr_async     (rack_wr_ptr_async),
            .rd_ptr_async     (rack_rd_ptr_async),
            .payld_async      (rack_payld_async_unused)
          );

        assign rack_hndshk = (rack_valid & rack_ready);

      end

  endgenerate

endmodule

