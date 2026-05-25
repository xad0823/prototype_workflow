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
// File: adb400_r3_mst_core.v
//-----------------------------------------------------------------------------
// Purpose : Master interface half of all the protocol variants of the 
//           domain bridge. This is wrapped in an additional layer to
//           provide protocol-specific parameter setting and remove
//           unused ports.
//-----------------------------------------------------------------------------

module adb400_r3_mst_core
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
      TKN_FIFO_DEPTH      = 6, // Only used if AR_VN>0 or AW_VN>0
      AW_OPREG            = 1,
      W_OPREG             = 1,
      AR_OPREG            = 1,
      CR_OPREG            = 1, // Only used if CR_FIFO_DEPTH>0
      CD_OPREG            = 1, // Only used if CD_FIFO_DEPTH>0
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
      AWQOS_OFFSET        = 8, // Only used if AW_VN>0
      WLAST_OFFSET        = 0,
      ARBAR_OFFSET        = 0,
      ARQOS_OFFSET        = 5, // Only used if AR_VN>0
      ARSNOOP_OFFSET      = 5, // Only used if AC_FIFO_DEPTH>0
      ARADDR_OFFSET       = 9, // Only used if AC_FIFO_DEPTH>0
      RLAST_OFFSET        = 0,
      ACSNOOP_OFFSET      = 5, // Only used if AC_FIFO_DEPTH>0
      ACADDR_OFFSET       = 9, // Only used if AC_FIFO_DEPTH>0
      CRRESP_OFFSET       = 0, // Only used of CR_FIFO_DEPTH>0
      CDLAST_OFFSET       = 0, // Only used if CD_FIFO_DEPTH>0
      // Widths of the payload vectors (default to the minimum needed for the extraction offsets above)
      AW_PAYLOAD_WIDTH    = 12,
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
    input  wire [((AR_VN==0)?0:(AR_VN-1)):0] var_prealloc_sar_i,
    input  wire [((AW_VN==0)?0:(AW_VN-1)):0] vaw_prealloc_sar_i,

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
    // NOTE: Only needed for snoops waking up an attached upstream master or subsystem
    input  wire                   wakeup_i,
    output wire                   wakeup_o,

    //
    // Synchronous interfaces
    //

    // AW channel signalling
    output wire awvalid,
    input  wire awready,
    // NOTE awvnet must be packed in the bottom bits of the payload
    output wire [AW_PAYLOAD_WIDTH-1:0] aw_payld,

    // W channel signalling
    output wire wvalid,
    input  wire wready,
    output wire [W_PAYLOAD_WIDTH-1:0] w_payld,

    // B channel signalling
    input  wire bvalid,
    output wire bready,
    input  wire [B_PAYLOAD_WIDTH-1:0] b_payld,

    // AR channel signalling
    output wire arvalid,
    input  wire arready,
    // NOTE arvnet must be packed in the bottom bits of the payload
    output wire [AR_PAYLOAD_WIDTH-1:0] ar_payld,

    // R channel signalling
    input  wire rvalid,
    output wire rready,
    input  wire [R_PAYLOAD_WIDTH-1:0] r_payld,

    // AC channel signalling
    input  wire acvalid,
    output wire acready,
    input  wire [((AC_FIFO_DEPTH==0)?0:(AC_PAYLOAD_WIDTH-1)):0] ac_payld,

    // CR channel signalling
    output wire crvalid,
    input  wire crready,
    output wire [((CR_FIFO_DEPTH==0)?0:(CR_PAYLOAD_WIDTH-1)):0] cr_payld,

    // CD channel signalling
    output wire cdvalid,
    input  wire cdready,
    output wire [((CD_FIFO_DEPTH==0)?0:(CD_PAYLOAD_WIDTH-1)):0] cd_payld,

    // WACK signalling
    output wire wack,

    // RACK signalling
    output wire rack,

    // VN signalling
    output wire [((AR_VN==0)?0:(AR_VN-1)):0] varvalid,
    input  wire [((AR_VN==0)?0:(AR_VN-1)):0] varready,
    output wire [((AR_VN==0)?0:((4*AR_VN)-1)):0] varqos,

    output wire [((AW_VN==0)?0:(AW_VN-1)):0] vawvalid,
    input  wire [((AW_VN==0)?0:(AW_VN-1)):0] vawready,
    output wire [((AW_VN==0)?0:((4*AW_VN)-1)):0] vawqos,

    output wire [((AW_VN==0)?0:(AW_VN-1)):0] vwvalid,
    input  wire [((AW_VN==0)?0:(AW_VN-1)):0] vwready,

    //
    // Asynchronous interfaces
    //

    // Cross-domain power state control
    input  wire                   slvmustacceptreqn_async,
    input  wire                   slvcandenyreqn_async,
    output wire                   slvacceptn_async,
    output wire                   slvdeny_async,

    // Cross-domain wakeup
    input  wire                   si_to_mi_wakeup_async,
    output wire                   mi_to_si_wakeup_async,

    // P channel signalling
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:1):0]  p_wr_ptr_async,
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:1):0]  p_rd_ptr_async,
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:(2*((AR_VN*4)+(AW_VN*4)))-1):0] p_payld_async,

    // T channel signalling
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:(TKN_FIFO_DEPTH-1)):0]  t_wr_ptr_async,
    input  wire [(((AR_VN==0)&&(AW_VN==0))?0:(TKN_FIFO_DEPTH-1)):0]  t_rd_ptr_async,
    output wire [(((AR_VN==0)&&(AW_VN==0))?0:((TKN_FIFO_DEPTH*(((AR_VN<=0)?0:(AR_VN*clogb2(AR_QVN_DEPTH)))+((AW_VN<=0)?0:(AW_VN*clogb2(AW_QVN_DEPTH)))+((AW_VN<=0)?0:(AW_VN*clogb2(W_QVN_DEPTH)))))-1)):0] t_payld_async,

    // AW channel signalling
    input  wire [AW_FIFO_DEPTH-1:0] aw_wr_ptr_async,
    output wire [AW_FIFO_DEPTH-1:0] aw_rd_ptr_async,
    input  wire [((AW_PAYLOAD_WIDTH+AW_VN)*AW_FIFO_DEPTH)-1:0] aw_payld_async,

    // W channel signalling
    input  wire [ W_FIFO_DEPTH-1:0]  w_wr_ptr_async,
    output wire [ W_FIFO_DEPTH-1:0]  w_rd_ptr_async,
    input  wire [(( W_PAYLOAD_WIDTH+AW_VN)* W_FIFO_DEPTH)-1:0] w_payld_async,

    // B channel signalling
    output wire [ B_FIFO_DEPTH-1:0]  b_wr_ptr_async,
    input  wire [ B_FIFO_DEPTH-1:0]  b_rd_ptr_async,
    output wire [( B_PAYLOAD_WIDTH* B_FIFO_DEPTH)-1:0] b_payld_async,

    // AR channel signalling
    input  wire [AR_FIFO_DEPTH-1:0] ar_wr_ptr_async,
    output wire [AR_FIFO_DEPTH-1:0] ar_rd_ptr_async,
    input  wire [((AR_PAYLOAD_WIDTH+AR_VN)*AR_FIFO_DEPTH)-1:0] ar_payld_async,

    // R channel signalling
    output wire [ R_FIFO_DEPTH-1:0]  r_wr_ptr_async,
    input  wire [ R_FIFO_DEPTH-1:0]  r_rd_ptr_async,
    output wire [( R_PAYLOAD_WIDTH* R_FIFO_DEPTH)-1:0] r_payld_async,

    // AC channel signalling
    output wire [((  AC_FIFO_DEPTH==0)?0:  AC_FIFO_DEPTH-1):0]   ac_wr_ptr_async,
    input  wire [((  AC_FIFO_DEPTH==0)?0:  AC_FIFO_DEPTH-1):0]   ac_rd_ptr_async,
    output wire [((  AC_FIFO_DEPTH==0)?0:((AC_PAYLOAD_WIDTH*AC_FIFO_DEPTH)-1)):0] ac_payld_async,

    // CR channel signalling
    input  wire [((  CR_FIFO_DEPTH==0)?0:  CR_FIFO_DEPTH-1):0]   cr_wr_ptr_async,
    output wire [((  CR_FIFO_DEPTH==0)?0:  CR_FIFO_DEPTH-1):0]   cr_rd_ptr_async,
    input  wire [((  CR_FIFO_DEPTH==0)?0:((CR_PAYLOAD_WIDTH*CR_FIFO_DEPTH)-1)):0] cr_payld_async,

    // CD channel signalling
    input  wire [((  CD_FIFO_DEPTH==0)?0:  CD_FIFO_DEPTH-1):0]   cd_wr_ptr_async,
    output wire [((  CD_FIFO_DEPTH==0)?0:  CD_FIFO_DEPTH-1):0]   cd_rd_ptr_async,
    input  wire [((  CD_FIFO_DEPTH==0)?0:(CD_PAYLOAD_WIDTH*CD_FIFO_DEPTH)-1):0] cd_payld_async,

    // WACK channel signalling
    input  wire [((ACK_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] wack_wr_ptr_async,
    output wire [((ACK_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] wack_rd_ptr_async,

    // RACK channel signalling
    input  wire [((ACK_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] rack_wr_ptr_async,
    output wire [((ACK_FIFO_DEPTH==0)?0:(ACK_FIFO_DEPTH-1)):0] rack_rd_ptr_async
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

  // An ACE-Lite+DVM master might require all parts of a multipart DVM before
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

  // QVN token counter widths must be set to 0 if not used as they affect the
  // size of the token return channel

  localparam VAR_TKN_WIDTH  = ((AR_VN<=0)?0:clogb2(AR_QVN_DEPTH));
  localparam VAW_TKN_WIDTH  = ((AW_VN<=0)?0:clogb2(AW_QVN_DEPTH));
  localparam  VW_TKN_WIDTH  = ((AW_VN<=0)?0:clogb2( W_QVN_DEPTH));

  // ----------------------------------------------------------------------
  // Some ACE values
  // ----------------------------------------------------------------------

  localparam [2:0] AWSNOOP_EVICT = 3'b100;
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

  adb400_r3_mi_ctrl
    #(
      .SYNC_LEVELS (SYNC_LEVELS)
    )
  u_mi_ctrl
    (
      .aclk                   (aclk),
      .aresetn                (resetn_unforced),

      .clkqreqn_i             (clkqreqn_i),
      .clkqacceptn_o          (clkqacceptn_o),
      .clkqdeny_o             (clkqdeny_o),
      .clkqactive_o           (clkqactive_o),

      .pwrqactive_o           (pwrqactive_o),

      .wakeup_i               (wakeup_i),
      .wakeup_o               (wakeup_o),
      .wakeup_sync_i          (wakeup_local),

      .slvmustacceptreqn_async_i (slvmustacceptreqn_async),
      .slvcandenyreqn_async_i (slvcandenyreqn_async),
      .slvacceptn_o           (slvacceptn_async),
      .slvdeny_o              (slvdeny_async),

      .wakeup_async_i         (si_to_mi_wakeup_async),
      .wakeup_async_o         (mi_to_si_wakeup_async),

      .ar_dvm_multipart_quiescent_i (ar_dvm_multipart_quiescent),
      .ac_dvm_multipart_quiescent_i (ac_dvm_multipart_quiescent),
      .dvm_sync_complete_quiescent_i (dvm_sync_complete_quiescent),
      .initiator_quiescent_i  (snoop_quiescent),
      .responder_quiescent_i  (read_write_quiescent),
      .initiator_quiescent_and_stalled_i  (snoop_quiescent_and_stalled),
      .responder_quiescent_and_stalled_i  (read_write_quiescent_and_stalled),

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
  wire stall_b_n;
  wire stall_ar_n;
  wire stall_ac_n;
  wire [((AR_VN>0)?(AR_VN-1):0):0] stall_var_n;
  wire [((AW_VN>0)?(AW_VN-1):0):0] stall_vaw_n;
  wire [((AW_VN>0)?(AW_VN-1):0):0] stall_vw_n;

  wire   awvalid_int;
  assign awvalid      = (outer_fence_n & stall_aw_n & awvalid_int);
  wire   awready_int  = (outer_fence_n & stall_aw_n & awready);
  wire   wvalid_int;
  assign wvalid       = (outer_fence_n & stall_w_n  & wvalid_int);
  wire   wready_int   = (outer_fence_n & stall_w_n  & wready);
  wire   arvalid_int;
  assign arvalid      = (outer_fence_n & stall_ar_n & arvalid_int);
  wire   arready_int  = (outer_fence_n & stall_ar_n & arready);

  wire   acvalid_int;
  wire   acready_int;
  generate  
    if (AC_FIFO_DEPTH<=0)
      begin : g_no_ac_no_fence
        assign acvalid_int  = 1'b0;
        assign acready      = 1'b0;
        wire stall_ac_n_unused  = stall_ac_n;
        wire acready_int_unused = acready_int;
      end
    else
      begin : g_ac_so_fence
        assign acvalid_int  = (outer_fence_n & stall_ac_n & acvalid);
        assign acready      = (outer_fence_n & stall_ac_n & acready_int);
      end
  endgenerate

  wire   bvalid_int   = (outer_fence_n & stall_b_n  & bvalid);
  wire   bready_int;
  assign bready       = (outer_fence_n & stall_b_n  & bready_int);
  wire   rvalid_int   = (outer_fence_n & rvalid);
  wire   rready_int;
  assign rready       = (outer_fence_n & rready_int);

  wire   crvalid_int;
  wire   crready_int;
  generate  
    if (CR_FIFO_DEPTH<=0)
      begin : g_no_cr_no_fence
        assign crvalid      = 1'b0;
        assign crready_int  = 1'b0;
        wire crvalid_int_unused = crvalid_int;
      end
    else
      begin : g_cr_so_fence
        assign crvalid      = (outer_fence_n & crvalid_int);
        assign crready_int  = (outer_fence_n & crready);
      end
  endgenerate

  wire   cdvalid_int;
  wire   cdready_int;
  generate  
    if (CD_FIFO_DEPTH<=0)
      begin : g_no_cd_no_fence
        assign cdvalid      = 1'b0;
        assign cdready_int  = 1'b0;
        wire cdvalid_int_unused = cdvalid_int;
      end
    else
      begin : g_cd_so_fence
        assign cdvalid      = (outer_fence_n & cdvalid_int);
        assign cdready_int  = (outer_fence_n & cdready);
      end
  endgenerate

  // Assignment of these is inside the QVN handling generate block
  wire [((AR_VN>0)?(AR_VN-1):0):0] varvalid_int;
  wire [((AR_VN>0)?(AR_VN-1):0):0] varready_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vawvalid_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vawready_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vwvalid_int;
  wire [((AW_VN>0)?(AW_VN-1):0):0] vwready_int;


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

  wire [((AR_VN>0)?(AR_VN-1):0):0] ar_vnpid;
  wire [((AW_VN>0)?(AW_VN-1):0):0] aw_vnpid;
  wire [((AW_VN>0)?(AW_VN-1):0):0] w_vnpid;

  adb400_r3_protocol_quiescent
    #(
      .PROTOCOL_CHANNELS (PROTOCOL_CHANNELS),
      .AW_VN             (AW_VN),
      .AR_VN             (AR_VN),
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

      .force_read_write_quiescence_n_i (responder_fence_n),
      .force_snoop_quiescence_n_i      (initiator_fence_n),
      .stall_ar_n_o           (stall_ar_n),
      .stall_aw_n_o           (stall_aw_n),
      .stall_w_n_o            (stall_w_n),
      .stall_b_n_o            (stall_b_n),
      .stall_ac_n_o           (stall_ac_n),

      .arvalid_i              (arvalid),
      .arready_i              (arready_int),
      .rvalid_i               (rvalid_int),
      .rready_i               (rready),
      .rlast_i                (rlast),
      .awvalid_i              (awvalid),
      .awready_i              (awready_int),
      .awbar_i                (awbar),
      .wvalid_i               (wvalid),
      .wready_i               (wready_int),
      .wlast_i                (wlast),
      .bvalid_i               (bvalid_int),
      .bready_i               (bready),
      .ar_dvm_sync_i          (ar_dvm_sync),
      .ar_dvm_complete_i      (ar_dvm_complete),
      .acvalid_i              (acvalid_int),
      .acready_i              (acready),
      .ac_dvm_sync_i          (ac_dvm_sync),
      .ac_dvm_complete_i      (ac_dvm_complete),
      .crvalid_i              (crvalid),
      .crready_i              (crready_int),
      .aw_evict_i             (aw_evict),
      .cr_pass_data_i         (cr_pass_data),
      .cdvalid_i              (cdvalid),
      .cdready_i              (cdready_int),
      .cdlast_i               (cdlast),
      .rack_i                 (rack),
      .wack_i                 (wack),
      .arbar_i                (arbar),
      .varvalid_i             (varvalid),
      .varready_i             (varready_int),
      .arvnpid_i              (ar_vnpid),
      .vawvalid_i             (vawvalid),
      .vawready_i             (vawready_int),
      .awvnpid_i              (aw_vnpid),
      .vwvalid_i              (vwvalid),
      .vwready_i              (vwready_int),
      .wvnpid_i               (w_vnpid),
      .stall_var_n_o          (stall_var_n),
      .stall_vaw_n_o          (stall_vaw_n),
      .stall_vw_n_o           (stall_vw_n)
    );

  //--------------------------------------------------------------------
  // The VN token mechanism
  //--------------------------------------------------------------------

  // Indications of released tokens
  wire [((AR_VN>0)?(AR_VN-1):0):0] ar_tkn_released;
  wire [((AW_VN>0)?(AW_VN-1):0):0] aw_tkn_released;
  wire [((AW_VN>0)?(AW_VN-1):0):0]  w_tkn_released;

  wire                                 promotion_qv_update;
  wire [((AR_VN>0)?((AR_VN*4)-1):0):0] ar_p_qos;
  wire [((AW_VN>0)?((AW_VN*4)-1):0):0] aw_p_qos;

  genvar i, j, k;

  generate
    if ((AW_VN==0) && (AR_VN==0))
      begin : g_not_vn_enabled_pt

        assign p_rd_ptr_async = 1'b0;
        assign promotion_qv_update = 1'b0;
        assign ar_p_qos = 1'b0;
        assign aw_p_qos = 1'b0;

        assign t_wr_ptr_async = 1'b0;
        assign t_payld_async = 1'b0;

        wire ar_tkn_released_unused = ar_tkn_released;
        wire aw_tkn_released_unused = aw_tkn_released;
        wire  w_tkn_released_unused =  w_tkn_released;
        wire promotion_qv_update_unused = promotion_qv_update;
        wire ar_p_qos_unused = ar_p_qos;
        wire aw_p_qos_unused = aw_p_qos;

      end // g_not_vn_enabled_pt
    else
      begin : g_vn_enabled_pt

        // The async FIFO bringing the priority promotion value
        // from the SI side
        wire pvalid;
        wire pready = pvalid;
        wire [((AR_VN*4)+(AW_VN*4))-1:0] p_payld;

        wire p_chan_cactive_unused;

        adb400_r3_dnstrm_payld
          #(
            .WIDTH            ((AR_VN*4)+(AW_VN*4)),
            .DEPTH            (2),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)

          )
        u_dnstrm_p
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (p_chan_cactive_unused),
        
            .dst_valid (pvalid),
            .dst_ready (pready),
            .dst_payld (p_payld),
           
            .wr_ptr_async    (p_wr_ptr_async),
            .rd_ptr_async    (p_rd_ptr_async),
            .payld_async     (p_payld_async)
          );


        assign promotion_qv_update = pvalid;

        // The async FIFO returning tokens to the slave interface side
        wire [AR_VN+AW_VN+AW_VN-1:0] tvalid_vn;
        wire tready;
        wire tvalid = (|tvalid_vn) & tready;
        wire [(AW_VN*VAW_TKN_WIDTH)+(AW_VN*VW_TKN_WIDTH)+(AR_VN*VAR_TKN_WIDTH)-1:0] t_payld;
        wire t_hndshk = tvalid & tready;

        wire t_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .WIDTH            ((AW_VN*VAW_TKN_WIDTH)+(AW_VN*VW_TKN_WIDTH)+(AR_VN*VAR_TKN_WIDTH)),
            .DEPTH            (TKN_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_tokens
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (t_chan_cactive_unused),
        
            .src_valid (tvalid),
            .src_ready (tready),
            .src_payld (t_payld),
           
            .wr_ptr_async    (t_wr_ptr_async),
            .rd_ptr_async    (t_rd_ptr_async),
            .payld_async     (t_payld_async)
          );
      
        if (AR_VN<=0)
          begin : g_promo_AR_VN_le_0
            assign ar_p_qos = 1'b0;
            wire ar_p_qos_unused = ar_p_qos;
            wire ar_tkn_released_unused = ar_tkn_released;
          end
        else
          begin : g_tokens_AR_VN_gt_0

            // Drive the AR QOS promotion signal
            assign ar_p_qos = p_payld[0+:(4*AR_VN)];
            

            // Keep a count of how many tokens are available
            reg  [VAR_TKN_WIDTH-1:0] arvnet_tokens        [AR_VN-1:0];
            wire [VAR_TKN_WIDTH-1:0] arvnet_tokens_nxt    [AR_VN-1:0];
            wire                          arvnet_tokens_upd_en [AR_VN-1:0];

            // Loop over each VN
            for (i=0; i<AR_VN ; i=i+1)
              begin : g_i

                // Show the right number to go into the FIFO
                assign t_payld[(i*VAR_TKN_WIDTH)+:VAR_TKN_WIDTH] = arvnet_tokens[i];

                // Indicate that something needs to go into the FIFO
                assign tvalid_vn[i] = |(arvnet_tokens[i]);

                // If there is a handshake into the token return IFO the new value is
                // 0 or 1. If there is no handshake it either stays the
                // same or increments.
                wire arvnet_tokens_ovrflw;
                assign {arvnet_tokens_ovrflw,arvnet_tokens_nxt[i]} =
                                                   (t_hndshk ? {VAR_TKN_WIDTH{1'b0}} : arvnet_tokens[i]) +
                                                   {{(VAR_TKN_WIDTH-1){1'b0}},ar_tkn_released[i]};
                
                // When to update the counters
                assign arvnet_tokens_upd_en[i] = ar_tkn_released[i] | tvalid;

                // Update the counters
                always @(posedge aclk or negedge resetn_forced)
                  begin : p_arvnet_tokens
                    if (!resetn_forced)
                      arvnet_tokens[i] <= {VAR_TKN_WIDTH{1'b0}};
                    else if (arvnet_tokens_upd_en[i])
                      arvnet_tokens[i] <= arvnet_tokens_nxt[i];
                  end

              end
    
          end

        if (AW_VN<=0)
          begin : g_promo_AW_VN_le_0
            assign aw_p_qos = 1'b0;
            wire aw_p_qos_unused = aw_p_qos;
            wire aw_tkn_released_unused = aw_tkn_released;
            wire  w_tkn_released_unused =  w_tkn_released;
          end
        else
          begin : g_tokens_AW_VN_gt_0

            // Drive the AW QOS promotion signal
            assign aw_p_qos = p_payld[(4*AR_VN)+:(4*AW_VN)];

            // Keep a count of how many tokens are available
            reg  [VAW_TKN_WIDTH-1:0] awvnet_tokens        [AW_VN-1:0];
            wire [VAW_TKN_WIDTH-1:0] awvnet_tokens_nxt    [AW_VN-1:0];
            wire                          awvnet_tokens_upd_en [AW_VN-1:0];

            reg  [ VW_TKN_WIDTH-1:0] wvnet_tokens         [AW_VN-1:0];
            wire [ VW_TKN_WIDTH-1:0] wvnet_tokens_nxt     [AW_VN-1:0];
            wire                          wvnet_tokens_upd_en  [AW_VN-1:0];

            // Loop over each VN
            for (j=0; j<AW_VN ; j=j+1)
              begin : g_j

                // AW

                // Show the right number to go into the FIFO
                assign t_payld[(AR_VN*VAR_TKN_WIDTH)+(j*VAW_TKN_WIDTH)+:VAW_TKN_WIDTH] = awvnet_tokens[j];

                // Indicate that something needs to go into the FIFO
                assign tvalid_vn[j+AR_VN] = |(awvnet_tokens[j]);

                // If there is a handshake into the FIFO its new value is
                // 0 or 1. If there is no handshake it either stays the
                // same or increments.
                wire awvnet_tokens_ovrflw;
                assign {awvnet_tokens_ovrflw,awvnet_tokens_nxt[j]} =
                                                   (t_hndshk ? {VAW_TKN_WIDTH{1'b0}} : awvnet_tokens[j]) +
                                                   {{(VAW_TKN_WIDTH-1){1'b0}},aw_tkn_released[j]};
                
                // When to update the counters
                assign awvnet_tokens_upd_en[j] = aw_tkn_released[j] | tvalid;

                // Update the counters
                always @(posedge aclk or negedge resetn_forced)
                  begin : p_awvnet_tokens
                    if (!resetn_forced)
                      awvnet_tokens[j] <= {VAW_TKN_WIDTH{1'b0}};
                    else if (awvnet_tokens_upd_en[j])
                      awvnet_tokens[j] <= awvnet_tokens_nxt[j];
                  end

                // W

                // Show the right number to go into the FIFO
                assign t_payld[(AR_VN*VAR_TKN_WIDTH)+(AW_VN*VAW_TKN_WIDTH)+(j*VW_TKN_WIDTH)+:VW_TKN_WIDTH] = wvnet_tokens[j];

                // Indicate that something needs to go into the FIFO
                assign tvalid_vn[j+AR_VN+AW_VN] = |(wvnet_tokens[j]);

                // If there is a handshake into the FIFO its new value is
                // 0 or 1. If there is no handshake it either stays the
                // same or increments.
                wire wvnet_tokens_ovrflw;
                assign {wvnet_tokens_ovrflw,wvnet_tokens_nxt[j]} =
                                                   (t_hndshk ? {VW_TKN_WIDTH{1'b0}} : wvnet_tokens[j]) +
                                                   {{(VW_TKN_WIDTH-1){1'b0}},w_tkn_released[j]};
                
                // When to update the counters
                assign wvnet_tokens_upd_en[j] = w_tkn_released[j] | tvalid;

                // Update the counters
                always @(posedge aclk or negedge resetn_forced)
                  begin : p_wvnet_tokens
                    if (!resetn_forced)
                      wvnet_tokens[j] <= {VW_TKN_WIDTH{1'b0}};
                    else if (wvnet_tokens_upd_en[j])
                      wvnet_tokens[j] <= wvnet_tokens_nxt[j];
                  end

              end
    
          end

      end

  endgenerate


  //--------------------------------------------------------------------
  // The upstream and downstream channel half instances.
  //--------------------------------------------------------------------

  wire wakeup_local_aw;
  wire wakeup_local_w;
  wire wakeup_local_ar;

  assign wakeup_local = (wakeup_local_aw | wakeup_local_w | wakeup_local_ar);

  // AW channel

  localparam AW_QVN_PAYLOAD_WIDTH = (AW_PAYLOAD_WIDTH + AW_VN);

  wire                            awvalid_qvn;
  wire                            awready_qvn;
  wire [AW_QVN_PAYLOAD_WIDTH-1:0] aw_payld_qvn;

  wire                            awvalid_reg;
  wire                            awready_reg;
  wire [AW_PAYLOAD_WIDTH-1:0]     aw_payld_reg;

  wire awvalid_chan;
  assign awvalid_qvn = (awvalid_chan & inner_fence_n);

  wire aw_chan_cactive_unused;

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (AW_QVN_PAYLOAD_WIDTH),
      .DEPTH            (AW_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_dnstrm_aw
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (aw_chan_cactive_unused),

      .dst_valid (awvalid_chan),
      .dst_ready (awready_qvn),
      .dst_payld (aw_payld_qvn),
     
      .wr_ptr_async    (aw_wr_ptr_async),
      .rd_ptr_async    (aw_rd_ptr_async),
      .payld_async     (aw_payld_async)
    );

  generate
    if (AW_VN==0)
      begin : g_no_aw_qvn

        assign wakeup_local_aw = (awvalid_reg | awvalid_int);

        assign awvalid_reg = awvalid_qvn;
        assign awready_qvn = awready_reg;
        assign aw_payld_reg = aw_payld_qvn;

        assign aw_tkn_released      = 1'b0;

        assign vawvalid     = 1'b0;
        assign vawvalid_int = 1'b0;
        assign vawready_int = 1'b0;
        assign vawqos       = 1'b0;

        wire stall_vaw_n_unused = stall_vaw_n;
        wire vawvalid_unused = vawvalid_int;

      end
    else
      begin : g_aw_qvn

        assign wakeup_local_aw = (awvalid_qvn | awvalid_reg | awvalid_int | (|(vawvalid_int)));

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

        assign vawvalid     = ({AW_VN{outer_fence_n}} & stall_vaw_n & vawvalid_int);
        assign vawready_int = ({AW_VN{outer_fence_n}} & stall_vaw_n & vawready);

        // Separate the VNPID from the rest of the payld
        wire [AW_VN-1:0]            aw_vnpid_qvn  = aw_payld_qvn[0+:AW_VN];
        wire [AW_PAYLOAD_WIDTH-1:0] aw_real_payld = aw_payld_qvn[AW_VN+:AW_PAYLOAD_WIDTH];

        // If there is a bar bit, extract it
        wire awbar;
        if (AWBAR_OFFSET<0)
          begin : g_no_bar
            assign awbar = 1'b0;
          end
        else
          begin : g_has_bar
            assign awbar = aw_real_payld[AWBAR_OFFSET];
          end

        // If there is a QOS field extract it
        wire [((AWQOS_OFFSET<0)?0:3):0] awqos;
        if (AWQOS_OFFSET<0)
          begin : g_no_qos
            assign awqos = 1'b0;
          end
        else
          begin : g_has_qos
            assign awqos = aw_real_payld[AWQOS_OFFSET+:4];
          end
 
        adb400_r3_vns_fifo
          #(
            .FIFO_WIDTH    (AW_PAYLOAD_WIDTH),
            .FIFO_DEPTH    (AW_QVN_DEPTH),
            .VN            (AW_VN),
            .QOS_PRESENT   (1),
            .REARB_CONTROL_PRESENT (0)
         )
        u_adb_vns_fifo
          (
            .aclk         (aclk),
            .aresetn      (resetn_forced),
            .vnpid_1h     (aw_vnpid_qvn),
            .valid_src    (awvalid_qvn),
            .ready_src    (awready_qvn),
            .payld_src    (aw_real_payld),
            .bar_src      (awbar),
            .qv_src       (awqos),
            .promotion_qv_update (promotion_qv_update),
            .promotion_qv (aw_p_qos),
            .valid_dst    (awvalid_reg),
            .ready_dst    (awready_reg),
            .payld_dst    (aw_payld_reg),
            .vn_rearb     (1'b0),
            .tkn_req      (vawvalid_int),
            .tkn_gnt      (vawready_int),
            .tkn_qv       (vawqos),
            .tkn_prealloc_i (aw_tkn_prealloc),
            .tkn_release  (aw_tkn_released)
          );

      end

    if (AW_OPREG==0)
      begin : g_no_aw_opreg
        assign awvalid_int = awvalid_reg;
        assign awready_reg = awready_int;
        assign aw_payld    = aw_payld_reg;
        assign aw_vnpid    = aw_tkn_released;
      end
    else if (AW_VN>0)
      begin : g_aw_opreg_with_tkn

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(AW_QVN_PAYLOAD_WIDTH))
        u_aw_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (awvalid_reg),
           .ready_src (awready_reg),
           .payld_src ({aw_payld_reg,aw_tkn_released}),
           .valid_dst (awvalid_int),
           .ready_dst (awready_int),
           .payld_dst ({aw_payld,aw_vnpid})
          );

      end
    else
      begin : g_aw_opreg_no_tkn

        assign aw_vnpid = 1'b0;

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(AW_PAYLOAD_WIDTH))
        u_aw_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (awvalid_reg),
           .ready_src (awready_reg),
           .payld_src (aw_payld_reg),
           .valid_dst (awvalid_int),
           .ready_dst (awready_int),
           .payld_dst (aw_payld)
          );

      end
  endgenerate


  // W channel

  localparam W_QVN_PAYLOAD_WIDTH = (W_PAYLOAD_WIDTH + AW_VN);

  wire                             wvalid_qvn;
  wire                             wready_qvn;
  wire [W_QVN_PAYLOAD_WIDTH-1:0]   w_payld_qvn;

  wire                             wvalid_reg;
  wire                             wready_reg;
  wire [W_PAYLOAD_WIDTH-1:0]       w_payld_reg;

  wire wvalid_chan;
  assign wvalid_qvn = (wvalid_chan & inner_fence_n);

  wire w_chan_cactive_unused;

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (W_QVN_PAYLOAD_WIDTH),
      .DEPTH            (W_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_dnstrm_w
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (w_chan_cactive_unused),

      .dst_valid (wvalid_chan),
      .dst_ready (wready_qvn),
      .dst_payld (w_payld_qvn),
     
      .wr_ptr_async    (w_wr_ptr_async),
      .rd_ptr_async    (w_rd_ptr_async),
      .payld_async     (w_payld_async)
    );

  generate
    if (AW_VN==0)
      begin : g_no_w_qvn

        assign wakeup_local_w  = (wvalid_reg  | wvalid_int);

        assign wvalid_reg = wvalid_qvn;
        assign wready_qvn = wready_reg;
        assign w_payld_reg = w_payld_qvn;

        assign w_tkn_released      = 1'b0;

        assign  vwvalid     = 1'b0;
        assign  vwvalid_int = 1'b0;
        assign  vwready_int = 1'b0;

        wire stall_vw_n_unused = stall_vw_n;
        wire vwvalid_unused = vwvalid_int;

      end
    else
      begin : g_w_qvn

        assign wakeup_local_w  = (wvalid_qvn  | wvalid_reg  | wvalid_int | (|(vwvalid_int)));

        assign  vwvalid     = ({AW_VN{outer_fence_n}} & stall_vw_n & vwvalid_int);
        assign  vwready_int = ({AW_VN{outer_fence_n}} & stall_vw_n & vwready);
        wire vwqos_unused;

        // Separate the VNPID from the rest of the payld
        wire [AW_VN-1:0]           w_vnpid_qvn  = w_payld_qvn[0+:AW_VN];
        wire [W_PAYLOAD_WIDTH-1:0] w_real_payld = w_payld_qvn[AW_VN+:W_PAYLOAD_WIDTH];
 
        // Detect the burst stickiness
        // Record when the last transfer was a WLAST
        reg  wlast_lst_q;
        wire wlast_lst_nxt = w_payld_reg[WLAST_OFFSET];
        wire wlast_lst_upd_en = wvalid_reg & wready_reg;
      
        always @(posedge aclk or negedge resetn_forced)
          begin : p_wlast_lst_reg
            if (!resetn_forced)
              wlast_lst_q <= 1'b1;
            else if (wlast_lst_upd_en)
              wlast_lst_q <= wlast_lst_nxt;
          end

        adb400_r3_vns_fifo
          #(
            .FIFO_WIDTH    (W_PAYLOAD_WIDTH),
            .FIFO_DEPTH    (W_QVN_DEPTH),
            .VN            (AW_VN),
            .QOS_PRESENT   (0),
            .REARB_CONTROL_PRESENT (1)
          )
        u_adb_vns_fifo
          (
            .aclk         (aclk),
            .aresetn      (resetn_forced),
            .vnpid_1h     (w_vnpid_qvn),
            .valid_src    (wvalid_qvn),
            .ready_src    (wready_qvn),
            .payld_src    (w_real_payld),
            .bar_src      (1'b0),
            .qv_src       (1'b0),
            .promotion_qv_update (1'b0),
            .promotion_qv (1'b0),
            .valid_dst    (wvalid_reg),
            .ready_dst    (wready_reg),
            .payld_dst    (w_payld_reg),
            .vn_rearb     (wlast_lst_q),
            .tkn_req      (vwvalid_int),
            .tkn_gnt      (vwready_int),
            .tkn_qv       (vwqos_unused),
            .tkn_prealloc_i ({AW_VN{1'b0}}),
            .tkn_release  (w_tkn_released)
          );

      end

    if (W_OPREG==0)
      begin : g_no_w_opreg
        assign wvalid_int = wvalid_reg;
        assign wready_reg = wready_int;
        assign w_payld    = w_payld_reg;
        assign w_vnpid    = w_tkn_released;
      end
    else if (AW_VN>0)
      begin : g_w_opreg_with_tkn

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(W_QVN_PAYLOAD_WIDTH))
        u_w_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (wvalid_reg),
           .ready_src (wready_reg),
           .payld_src ({w_payld_reg,w_tkn_released}),
           .valid_dst (wvalid_int),
           .ready_dst (wready_int),
           .payld_dst ({w_payld,w_vnpid})
          );

      end
    else
      begin : g_w_opreg_no_tkn

        assign w_vnpid = 1'b0;

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(W_PAYLOAD_WIDTH))
        u_w_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (wvalid_reg),
           .ready_src (wready_reg),
           .payld_src (w_payld_reg),
           .valid_dst (wvalid_int),
           .ready_dst (wready_int),
           .payld_dst (w_payld)
          );

      end
  endgenerate


  // B channel

  wire b_chan_cactive_unused;

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (B_PAYLOAD_WIDTH),
      .DEPTH            (B_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_upstrm_b
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (b_chan_cactive_unused),
  
      .src_valid (bvalid_int),
      .src_ready (bready_int),
      .src_payld (b_payld),
     
      .wr_ptr_async    (b_wr_ptr_async),
      .rd_ptr_async    (b_rd_ptr_async),
      .payld_async     (b_payld_async)
    );


  // AR channel

  localparam AR_QVN_PAYLOAD_WIDTH = (AR_PAYLOAD_WIDTH + AR_VN);

  wire                            arvalid_qvn;
  wire                            arready_qvn;
  wire [AR_QVN_PAYLOAD_WIDTH-1:0] ar_payld_qvn;

  wire                            arvalid_reg;
  wire                            arready_reg;
  wire [AR_PAYLOAD_WIDTH-1:0]     ar_payld_reg;

  wire arvalid_chan;
  assign arvalid_qvn = (arvalid_chan & inner_fence_n);

  wire ar_chan_cactive_unused;

  adb400_r3_dnstrm_payld
    #(
      .WIDTH            (AR_QVN_PAYLOAD_WIDTH),
      .DEPTH            (AR_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_dnstrm_ar
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (ar_chan_cactive_unused),

      .dst_valid (arvalid_chan),
      .dst_ready (arready_qvn),
      .dst_payld (ar_payld_qvn),
     
      .wr_ptr_async    (ar_wr_ptr_async),
      .rd_ptr_async    (ar_rd_ptr_async),
      .payld_async     (ar_payld_async)
    );

  generate
    if (AR_VN==0)
      begin : g_no_ar_qvn

        assign wakeup_local_ar = (arvalid_reg | arvalid_int);

        assign arvalid_reg = arvalid_qvn;
        assign arready_qvn = arready_reg;
        assign ar_payld_reg = ar_payld_qvn;

        assign ar_tkn_released      = 1'b0;

        assign varvalid     = 1'b0;
        assign varvalid_int = 1'b0;
        assign varready_int = 1'b0;
        assign varqos       = 1'b0;

        wire stall_var_n_unused = stall_var_n;
        wire var_prealloc_sar_i_unused = var_prealloc_sar_i;
        wire varvalid_unused = varvalid_int;

      end
    else
      begin : g_ar_qvn

        assign wakeup_local_ar = (arvalid_qvn | arvalid_reg | arvalid_int | (|(varvalid_int)));

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

        assign varvalid     = ({AR_VN{outer_fence_n}} & stall_var_n & varvalid_int);
        assign varready_int = ({AR_VN{outer_fence_n}} & stall_var_n & varready);

        // Separate the VNPID from the rest of the payld
        wire [AR_VN-1:0]            ar_vnpid_qvn  = ar_payld_qvn[0+:AR_VN];
        wire [AR_PAYLOAD_WIDTH-1:0] ar_real_payld = ar_payld_qvn[AR_VN+:AR_PAYLOAD_WIDTH];
 
        // If there is a bar bit, extract it
        wire arbar;
        if (ARBAR_OFFSET<0)
          begin : g_no_bar
            assign arbar = 1'b0;
          end
        else
          begin : g_has_bar
            assign arbar = ar_real_payld[ARBAR_OFFSET];
          end

        // If there is a QOS field extract it
        wire [((ARQOS_OFFSET<0)?0:3):0] arqos;
        if (ARQOS_OFFSET<0)
          begin : g_no_qos
            assign arqos = 1'b0;
          end
        else
          begin : g_has_qos
            assign arqos = ar_real_payld[ARQOS_OFFSET+:4];
          end
 
        adb400_r3_vns_fifo
          #(
            .FIFO_WIDTH    (AR_PAYLOAD_WIDTH),
            .FIFO_DEPTH    (AR_QVN_DEPTH),
            .VN            (AR_VN),
            .QOS_PRESENT   (1),
            .REARB_CONTROL_PRESENT (0)
          )
        u_adb_vns_fifo
          (
            .aclk         (aclk),
            .aresetn      (resetn_forced),
            .vnpid_1h     (ar_vnpid_qvn),
            .valid_src    (arvalid_qvn),
            .ready_src    (arready_qvn),
            .payld_src    (ar_real_payld),
            .bar_src      (arbar),
            .qv_src       (arqos),
            .promotion_qv_update (promotion_qv_update),
            .promotion_qv (ar_p_qos),
            .valid_dst    (arvalid_reg),
            .ready_dst    (arready_reg),
            .payld_dst    (ar_payld_reg),
            .vn_rearb     (1'b0),
            .tkn_req      (varvalid_int),
            .tkn_gnt      (varready_int),
            .tkn_qv       (varqos),
            .tkn_prealloc_i (ar_tkn_prealloc),
            .tkn_release  (ar_tkn_released)
          );

      end

    if (AR_OPREG==0)
      begin : g_no_ar_opreg
        assign arvalid_int = arvalid_reg;
        assign arready_reg = arready_int;
        assign ar_payld    = ar_payld_reg;
        assign ar_vnpid    = ar_tkn_released;
      end
    else if (AR_VN>0)
      begin : g_ar_opreg_with_tkn

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(AR_QVN_PAYLOAD_WIDTH))
        u_ar_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (arvalid_reg),
           .ready_src (arready_reg),
           .payld_src ({ar_payld_reg,ar_tkn_released}),
           .valid_dst (arvalid_int),
           .ready_dst (arready_int),
           .payld_dst ({ar_payld,ar_vnpid})
          );

      end
    else
      begin : g_ar_opreg_no_tkn

        assign ar_vnpid = 1'b0;

        adb400_r3_ful_regd_slice
          #(.PAYLD_WIDTH(AR_PAYLOAD_WIDTH))
        u_ar_opreg
          (
           .aclk      (aclk),
           .aresetn   (resetn_forced),
           .valid_src (arvalid_reg),
           .ready_src (arready_reg),
           .payld_src (ar_payld_reg),
           .valid_dst (arvalid_int),
           .ready_dst (arready_int),
           .payld_dst (ar_payld)
          );

      end
  endgenerate

  // R channel

  wire r_chan_cactive_unused;

  adb400_r3_upstrm_payld
    #(
      .WIDTH            (R_PAYLOAD_WIDTH),
      .DEPTH            (R_FIFO_DEPTH),
      .SYNC_LEVELS      (SYNC_LEVELS),
      .CACTIVE_OUTPUT   (0)
    )
  u_upstrm_r
    (
      .aclk      (aclk),
      .aresetn   (resetn_forced),
      .cactive   (r_chan_cactive_unused),
  
      .src_valid (rvalid_int),
      .src_ready (rready_int),
      .src_payld (r_payld),
     
      .wr_ptr_async    (r_wr_ptr_async),
      .rd_ptr_async    (r_rd_ptr_async),
      .payld_async     (r_payld_async)
    );

  generate

    // AC channel

    if (AC_FIFO_DEPTH<=0)
      begin : g_AC_FIFO_DEPTH_le_0

        assign acready_int = 1'b0;
        assign ac_wr_ptr_async = 1'b0;
        assign ac_payld_async = 1'b0;

        wire ac_rd_ptr_async_unused = ac_rd_ptr_async;

      end
    else
      begin : g_AC_FIFO_DEPTH_gt_0

        wire ac_chan_cactive_unused;

        adb400_r3_upstrm_payld
          #(
            .WIDTH            (AC_PAYLOAD_WIDTH),
            .DEPTH            (AC_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_upstrm_ac
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (ac_chan_cactive_unused),
        
            .src_valid (acvalid_int),
            .src_ready (acready_int),
            .src_payld (ac_payld),
           
            .wr_ptr_async    (ac_wr_ptr_async),
            .rd_ptr_async    (ac_rd_ptr_async),
            .payld_async     (ac_payld_async)
          );

      end


    // CR channel

    if (CR_FIFO_DEPTH<=0)
      begin : g_CR_FIFO_DEPTH_le_0

        assign crvalid_int = 1'b0;
        assign cr_payld = 1'b0;
        assign cr_rd_ptr_async = 1'b0;

        assign cr_pass_data = 1'b0;

        wire cr_wr_ptr_async_unused = cr_wr_ptr_async;
        wire cr_payld_async_unused = cr_payld_async;

      end
    else
      begin : g_CR_FIFO_DEPTH_gt_0

        wire                        crvalid_reg;
        wire                        crready_reg;
        wire [CR_PAYLOAD_WIDTH-1:0] cr_payld_reg;

        assign cr_pass_data = cr_payld[CRRESP_OFFSET];

        wire crvalid_chan;
        assign crvalid_reg = (crvalid_chan & inner_fence_n);

        wire cr_chan_cactive_unused;

        adb400_r3_dnstrm_payld
          #(
            .WIDTH            (CR_PAYLOAD_WIDTH),
            .DEPTH            (CR_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_cr
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (cr_chan_cactive_unused),
      
            .dst_valid (crvalid_chan),
            .dst_ready (crready_reg),
            .dst_payld (cr_payld_reg),
           
            .wr_ptr_async    (cr_wr_ptr_async),
            .rd_ptr_async    (cr_rd_ptr_async),
            .payld_async     (cr_payld_async)
          );

        if (CR_OPREG==0)
          begin : g_no_cr_opreg
            assign crvalid_int = crvalid_reg;
            assign crready_reg = crready_int;
            assign cr_payld    = cr_payld_reg;
          end
        else
          begin : g_cr_opreg

            adb400_r3_ful_regd_slice
              #(.PAYLD_WIDTH(CR_PAYLOAD_WIDTH))
            u_cr_opreg
              (
               .aclk      (aclk),
               .aresetn   (resetn_forced),
               .valid_src (crvalid_reg),
               .ready_src (crready_reg),
               .payld_src (cr_payld_reg),
               .valid_dst (crvalid_int),
               .ready_dst (crready_int),
               .payld_dst (cr_payld)
              );
          end
      end


    // CD channel

    if (CD_FIFO_DEPTH<=0)
      begin : g_CD_FIFO_DEPTH_le_0

        assign cdvalid_int = 1'b0;
        assign cd_payld = 1'b0;
        assign cd_rd_ptr_async = 1'b0;

        assign cdlast = 1'b0;

        wire cd_wr_ptr_async_unused = cd_wr_ptr_async;
        wire cd_payld_async_unused = cd_payld_async;

      end
    else
      begin : g_CD_FIFO_DEPTH_gt_0

        wire                        cdvalid_reg;
        wire                        cdready_reg;
        wire [CD_PAYLOAD_WIDTH-1:0] cd_payld_reg;

        assign cdlast = cd_payld[CDLAST_OFFSET];

        wire cdvalid_chan;
        assign cdvalid_reg = (cdvalid_chan & inner_fence_n);

        wire cd_chan_cactive_unused;

        adb400_r3_dnstrm_payld
          #(
            .WIDTH            (CD_PAYLOAD_WIDTH),
            .DEPTH            (CD_FIFO_DEPTH),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_cd
          (
            .aclk      (aclk),
            .aresetn   (resetn_forced),
            .cactive   (cd_chan_cactive_unused),
      
            .dst_valid (cdvalid_chan),
            .dst_ready (cdready_reg),
            .dst_payld (cd_payld_reg),
           
            .wr_ptr_async    (cd_wr_ptr_async),
            .rd_ptr_async    (cd_rd_ptr_async),
            .payld_async     (cd_payld_async)
          );

        if (CD_OPREG==0)
          begin : g_no_cd_opreg
            assign cdvalid_int = cdvalid_reg;
            assign cdready_reg = cdready_int;
            assign cd_payld    = cd_payld_reg;
          end
        else
          begin : g_cd_opreg

            adb400_r3_ful_regd_slice
              #(.PAYLD_WIDTH(CD_PAYLOAD_WIDTH))
            u_cd_opreg
              (
               .aclk      (aclk),
               .aresetn   (resetn_forced),
               .valid_src (cdvalid_reg),
               .ready_src (cdready_reg),
               .payld_src (cd_payld_reg),
               .valid_dst (cdvalid_int),
               .ready_dst (cdready_int),
               .payld_dst (cd_payld)
              );
          end
      end

    if (ACK_FIFO_DEPTH<=0)
      begin : g_ACK_FIFO_DEPTH_le_0

        assign wack_rd_ptr_async = 1'b0;
        
        assign rack_rd_ptr_async = 1'b0;

        assign wack = 1'b0;
        assign rack = 1'b0;

        wire wack_wr_ptr_async_unused = wack_wr_ptr_async;
        wire rack_wr_ptr_async_unused = rack_wr_ptr_async;

      end
    else
      begin : g_ACK_FIFO_DEPTH_gt_0

        wire   wack_valid_int;
        assign wack         = (outer_fence_n & wack_valid_int);
        wire   wack_ready_int = outer_fence_n;
        wire   rack_valid_int;
        assign rack         = (outer_fence_n & rack_valid_int);
        wire   rack_ready_int = outer_fence_n;

        // WACK channel

        wire wack_valid_chan;
        assign wack_valid_int = (wack_valid_chan & inner_fence_n);

        wire wack_payld_unused;

        wire wack_chan_cactive_unused;

        adb400_r3_dnstrm_payld
          #(
            .DEPTH            (ACK_FIFO_DEPTH),
            .WIDTH            (0),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_wack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
            .cactive          (wack_chan_cactive_unused),
        
            .dst_valid        (wack_valid_chan),
            .dst_ready        (wack_ready_int),
            .dst_payld        (wack_payld_unused),

            .wr_ptr_async     (wack_wr_ptr_async),
            .rd_ptr_async     (wack_rd_ptr_async),
            .payld_async      (1'b0)
          );


        // RACK channel

        wire rack_valid_chan;
        assign rack_valid_int = (rack_valid_chan & inner_fence_n);

        wire rack_payld_unused;

        wire rack_chan_cactive_unused;

        adb400_r3_dnstrm_payld
          #(
            .DEPTH            (ACK_FIFO_DEPTH),
            .WIDTH            (0),
            .SYNC_LEVELS      (SYNC_LEVELS),
            .CACTIVE_OUTPUT   (0)
          )
        u_dnstrm_rack
          (
            .aclk             (aclk),
            .aresetn          (resetn_forced),
            .cactive          (rack_chan_cactive_unused),
        
            .dst_valid        (rack_valid_chan),
            .dst_ready        (rack_ready_int),
            .dst_payld        (rack_payld_unused),

            .wr_ptr_async     (rack_wr_ptr_async),
            .rd_ptr_async     (rack_rd_ptr_async),
            .payld_async      (1'b0)
          );

      end

  endgenerate


//------------------------------------------------------------------------------
// OVL assertions
//------------------------------------------------------------------------------
`ifdef ASSERT_ON
`ifdef ARM_ASSERT_ON
`ifdef OVL_ASSERT_ON

// ACS_off start COVERAGE_OFF Do not collect coverage data on OVLs

  `include "std_ovl_defines.h"

  wire powered = 1'b1;
  reg  has_been_reset_if_not_x;
  always @(posedge powered or negedge aresetn)
    if ((has_been_reset_if_not_x === 1'bx) & (aresetn === 1'b0))
      has_been_reset_if_not_x <= 1'b1;

  // ----------------------------------------------------------------------------------
  // OVL_ASSERT: stall_b_n should not actually prevent a B - if it does it may impact performance
  // ----------------------------------------------------------------------------------
  assert_never #(
    .severity_level (`OVL_WARNING),
    .property_type  (`OVL_ASSERT),
    .msg            ("B handshakes are being prevented because there are no outstanding AW. B before AW is permitted but not expected in AXI3, and not permitted in later protools. If this condition occurs it may indicate an associated performance problem"))
  assert_no_actual_b_stall (
    .clk        (aclk),
    .reset_n    (aresetn),
    .test_expr  ((has_been_reset_if_not_x !== 1'bx) & (~stall_b_n & bvalid))
  );

// ACS_off end COVERAGE_OFF

`endif
`endif
`endif

endmodule

