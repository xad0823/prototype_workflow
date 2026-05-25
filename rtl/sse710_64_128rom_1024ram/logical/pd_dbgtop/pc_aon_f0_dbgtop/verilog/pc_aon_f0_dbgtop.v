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
module pc_aon_f0_dbgtop
  #(parameter
      DATA_WIDTH           = 32,
      ID_WIDTH             = 4,
      A4S_FIFO_WIDTH       = 4,
      A4S_PAYLOAD_WIDTH    = 180,
      CTI_PULSE_CNT        = 4
  )
(
    input  wire                                  dbgclk,
    input  wire                                  reset_n,
    input  wire                                  dftcgen,
    input  wire                                  dftrstdisable,

    output wire                                  apbdbg_mst_psel_o,
    output wire                                  apbdbg_mst_penable_o,
    output wire [31:0]                           apbdbg_mst_paddr_o,
    output wire                                  apbdbg_mst_pwrite_o,
    output wire [31:0]                           apbdbg_mst_pwdata_o,
    output wire [2:0]                            apbdbg_mst_pprot_o,
    input  wire [31:0]                           apbdbg_mst_prdata_i,
    input  wire                                  apbdbg_mst_pready_i,
    input  wire                                  apbdbg_mst_pslverr_i,
    output wire                                  apbdbg_mst_pwakeup_o,


    input  wire                                  apb_async_req_i_aon,
    input  wire [67:0]                           apb_async_req_payload_i_aon,
    output wire [32:0]                           apb_async_resp_payload_o_aon,
    output wire                                  apb_async_ack_o_aon,



    input  wire                                  wakeups_i,
    input  wire                                  tvalids,
    output wire                                  treadys,
    input  wire [DATA_WIDTH-1:0]                 tdatas,
    input  wire                                  tstrbs,
    input  wire [3:0]                            tkeeps,
    input  wire                                  tlasts,
    input  wire [ID_WIDTH-1:0]                   tids,
    input  wire [ID_WIDTH-1:0]                   tdests,
    input  wire                                  tusers,
    output wire                                  wakeupm_o,
    output wire                                  tvalidm,
    input  wire                                  treadym,
    output wire [DATA_WIDTH-1:0]                 tdatam,
    output wire                                  tstrbm,
    output wire [3:0]                            tkeepm,
    output wire                                  tlastm,
    output wire [ID_WIDTH-1:0]                   tidm,
    output wire [ID_WIDTH-1:0]                            tdestm,
    output wire                                  tuserm,    
    
    input  wire [CTI_PULSE_CNT-1:0]              cti_pulse_in,
    output wire [CTI_PULSE_CNT-1:0]              cti_pulse_req,
    input  wire [CTI_PULSE_CNT-1:0]              cti_pulse_ack,
        
    output wire                                  slvmustacceptreqn_async_slv,
    output wire                                  slvcandenyreqn_async_slv,
    input  wire                                  slvacceptn_async_slv,
    input  wire                                  slvdeny_async_slv,

    output wire                                  si_to_mi_wakeup_async_slv,
    input  wire                                  mi_to_si_wakeup_async_slv,

    output wire [A4S_FIFO_WIDTH-1:0]             wr_ptr_async_slv,
    input  wire [A4S_FIFO_WIDTH-1:0]             rd_ptr_async_slv,
    output wire [A4S_PAYLOAD_WIDTH-1:0]          payld_async_slv,
    
    input  wire                                  slvmustacceptreqn_async_mst,
    input  wire                                  slvcandenyreqn_async_mst,
    output wire                                  slvacceptn_async_mst,
    output wire                                  slvdeny_async_mst,

    input  wire                                  si_to_mi_wakeup_async_mst,
    output wire                                  mi_to_si_wakeup_async_mst,
    
    input  wire                                  dp_abort_pulse_req,
    output wire                                  dp_abort_pulse_ack,
    output wire                                  dp_abort,
    
    input wire  [3:0] dbgclk_qreqn    ,
    output wire [3:0] dbgclk_qacceptn,    
    output wire [3:0] dbgclk_qdeny   ,    
    output wire [3:0] dbgclk_qactive,    
    output wire       dbgclk_qactive_only,

    input  wire         dbgtop_internal_qreqn,
    output wire         dbgtop_internal_qacceptn,
    output wire         dbgtop_internal_qdeny,
    output wire         dbgtop_internal_qactive,
    
    input  wire         dbgtop_egress_qreqn,
    output wire         dbgtop_egress_qacceptn,
    output wire         dbgtop_egress_qdeny,
    output wire         dbgtop_egress_qactive,
    
    input  wire [A4S_FIFO_WIDTH-1:0]             wr_ptr_async_mst,
    output wire [A4S_FIFO_WIDTH-1:0]             rd_ptr_async_mst,
    input  wire [A4S_PAYLOAD_WIDTH-1:0]          payld_async_mst
);


css600_pulseasyncbridgemstr u_dpabort_slv_dbgtopap (
    .clk_m          (dbgclk),
    .reset_m_n      (reset_n),
    .pulse_out      (dp_abort),
    .pulse_req      (dp_abort_pulse_req),
    .pulse_ack      (dp_abort_pulse_ack),
    .clk_m_qreq_n   (dbgclk_qreqn   [0]),
    .clk_m_qaccept_n(dbgclk_qacceptn[0]),
    .clk_m_qactive  (dbgclk_qactive [0])
                     
);

    assign dbgclk_qdeny[0]  = 1'b0;
  
  css600_apbasyncbridgemstr #(
   .APB_ADDR_WIDTH (32),
   .FF_SYNC_DEPTH  (2)
 ) u_mst_apb
 (
   .clk_m                    (dbgclk),
   .reset_m_n                (reset_n),
   .dftcgen                  (dftcgen),
   .psel_m                   (apbdbg_mst_psel_o),
   .penable_m                (apbdbg_mst_penable_o),
   .paddr_m                  (apbdbg_mst_paddr_o),
   .pwrite_m                 (apbdbg_mst_pwrite_o),
   .pwdata_m                 (apbdbg_mst_pwdata_o),
   .pprot_m                  (apbdbg_mst_pprot_o),
   .prdata_m                 (apbdbg_mst_prdata_i),
   .pready_m                 (apbdbg_mst_pready_i),
   .pslverr_m                (apbdbg_mst_pslverr_i),
   .pwakeup_m                (apbdbg_mst_pwakeup_o),
   .clk_m_qreq_n             (dbgclk_qreqn   [1]),   
   .clk_m_qaccept_n          (dbgclk_qacceptn[1]),
   .clk_m_qdeny              (dbgclk_qdeny   [1]),
   .clk_m_qactive            (dbgclk_qactive [1]),
   .apb_async_req            (apb_async_req_i_aon),
   .apb_async_req_payload    (apb_async_req_payload_i_aon),
   .apb_async_resp_payload   (apb_async_resp_payload_o_aon),
   .apb_async_ack            (apb_async_ack_o_aon)
  );
   

  adb400_r3_axi4_stream_slv #(
      
      .DATA_WIDTH       (DATA_WIDTH),
      .ID_WIDTH         (ID_WIDTH),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .DEST_WIDTH       (ID_WIDTH),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (A4S_FIFO_WIDTH)
    ) u_slv (
      .aclks                   (dbgclk),
      .aresetns                (reset_n),

      .dftrstdisables          (dftrstdisable),

      .pwrq_permit_deny_sar_i  (1'b1),

      .pwrqreqns_i             (dbgtop_egress_qreqn),
      .pwrqacceptns_o          (dbgtop_egress_qacceptn),
      .pwrqdenys_o             (dbgtop_egress_qdeny),
      .pwrqactives_o           (dbgtop_egress_qactive),

      .clkqreqns_i             (dbgclk_qreqn   [2]),
      .clkqacceptns_o          (dbgclk_qacceptn[2]),
      .clkqdenys_o             (dbgclk_qdeny   [2]),
      .clkqactives_o           (dbgclk_qactive [2]),
      
      .wakeups_i               (wakeups_i),

      .tvalids                 (tvalids),
      .treadys                 (treadys),
      .tdatas                  (tdatas),
      .tstrbs                  (tstrbs),
      .tkeeps                  (tkeeps),
      .tlasts                  (tlasts),
      .tids                    (tids),
      .tdests                  (tdests),
      .tusers                  (tusers),

      .slvmustacceptreqn_async (slvmustacceptreqn_async_slv),
      .slvcandenyreqn_async    (slvcandenyreqn_async_slv),
      .slvacceptn_async        (slvacceptn_async_slv),
      .slvdeny_async           (slvdeny_async_slv),

      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async_slv),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async_slv),

      .wr_ptr_async            (wr_ptr_async_slv),
      .rd_ptr_async            (rd_ptr_async_slv),
      .payld_async             (payld_async_slv)
    );

  sse710_adb400_r3_axi4_stream_mst_wrapper
  #(
      .DATA_WIDTH       (DATA_WIDTH),
      .ID_WIDTH         (ID_WIDTH),
      .STRB_WIDTH       (0),
      .KEEP_WIDTH       (4),
      .LAST_WIDTH       (4),
      .DEST_WIDTH       (ID_WIDTH),
      .USER_WIDTH       (0),
      .FIFO_DEPTH       (A4S_FIFO_WIDTH),
      .OPREG            (1),
      .MI_SYNC_LEVELS   (2),
      .PAYLOAD_WIDTH    (A4S_PAYLOAD_WIDTH)

    ) u_sse710_adb400_r3_axi4_stream_mst_wrapper (
      .aclkm                   (dbgclk),
      .aresetnm                (reset_n),

      .dftrstdisablem          (dftrstdisable),

      .clkqreqnm_i             (dbgclk_qreqn   [3]),
      .clkqacceptnm_o          (dbgclk_qacceptn[3]),
      .clkqdenym_o             (dbgclk_qdeny   [3]),
      .clkqactivem_o           (dbgclk_qactive [3]),
      .wakeupm_o               (wakeupm_o),

      .tvalidm                 (tvalidm),
      .treadym                 (treadym),
      .tdatam                  (tdatam),
      .tstrbm                  (tstrbm),
      .tkeepm                  (tkeepm),
      .tlastm                  (tlastm),
      .tidm                    (tidm),
      .tdestm                  (tdestm),
      .tuserm                  (tuserm),

      .slvmustacceptreqn_async (slvmustacceptreqn_async_mst),
      .slvcandenyreqn_async    (slvcandenyreqn_async_mst),
      .slvacceptn_async        (slvacceptn_async_mst),
      .slvdeny_async           (slvdeny_async_mst),

      .si_to_mi_wakeup_async   (si_to_mi_wakeup_async_mst),
      .mi_to_si_wakeup_async   (mi_to_si_wakeup_async_mst),

      .wr_ptr_async            (wr_ptr_async_mst),
      .rd_ptr_async            (rd_ptr_async_mst),
      .payld_async             (payld_async_mst)
    );

    
    css600_pulseasyncbridgeslv #(
                .WIDTH(CTI_PULSE_CNT),
                .WAKE_ON_PULSE(0)
    )
    u_css600_pulseasyncbridgeslv_counter
    (
        .clk_s          (dbgclk),
        .reset_s_n      (reset_n),
        .pulse_in       (cti_pulse_in ),
        .pulse_req      (cti_pulse_req),
        .pulse_ack      (cti_pulse_ack),
        .clk_s_qactive  (dbgclk_qactive_only),
        .pwr_qreq_n     (dbgtop_internal_qreqn),
        .pwr_qaccept_n  (dbgtop_internal_qacceptn),
        .pwr_qactive    (dbgtop_internal_qactive)
    );
  
    assign dbgtop_internal_qdeny = 1'b0;
    
endmodule
