//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      Wrapper for STM AXI Slave Interface, instantiating the separate AXI read
//      and write sub-blocks.
//-----------------------------------------------------------------------------

module cxstm500_axislvif
#(
  parameter   AXI_ID_WIDTH = 8,    // AXI ID width, set when stitching with interconnect
  parameter   STM_DATA_WIDTH = 64  // STM Data Width
)
(
  // Clock and Reset
  input wire                          CLK,                // AXI Clock
  input wire                          ARESETn,            // AXI Reset

  // AMBA3 AXI Interface
  // AW channel
  input wire [AXI_ID_WIDTH-1:0]       AWIDS,              // Write Address ID
  input wire                          AWVALIDS,           // Write Address Valid
  input wire [31:0]                   AWADDRS,            // Write Address
  input wire [2:0]                    AWSIZES,            // Write Size
  input wire [7:0]                    AWLENS,             // Burst Length
  input wire [1:0]                    AWBURSTS,           // Write Burst Type
  input wire [2:0]                    AWPROTS,            // Write Authentication
  output wire                         AWREADYS,           // Write Address Ready

  // W channel
  input wire                          WVALIDS,            // Write Data Valid
  input wire [STM_DATA_WIDTH-1:0]     WDATAS,             // Write Data
  input wire [(STM_DATA_WIDTH/8)-1:0] WSTRBS,             // Write Strobes
  input wire                          WLASTS,             // Write Data Last
  output wire                         WREADYS,            // Write Data Ready

  // B channel
  input wire                          BREADYS,            // Write Response Ready
  output wire                         BVALIDS,            // Write Response Valid
  output wire [AXI_ID_WIDTH-1:0]      BIDS,               // Write Response ID
  output wire [1:0]                   BRESPS,             // Write Response

  // AR channel
  input wire                          ARVALIDS,           // Read Address Valid
  input wire [AXI_ID_WIDTH-1:0]       ARIDS,              // Read Address ID
  input wire [7:0]                    ARLENS,             // Read Burst Length
  output wire                         ARREADYS,           // Read Address Ready

  // R channel
  input wire                          RREADYS,            // Read Data Ready
  output wire                         RVALIDS,            // Read Data Valid
  output wire [AXI_ID_WIDTH-1:0]      RIDS,               // Read Data ID
  output wire [STM_DATA_WIDTH-1:0]    RDATAS,             // Read Data
  output wire [1:0]                   RRESPS,             // Read Response
  output wire                         RLASTS,             // Read Data Last

  // TGU data Interface
  input wire                          tgu_ready_i,          // TGU Transfer Ready
  input wire                          tgu_timestamped_i,    // Timestamp Indicator
  input wire                          tgu_fvalid_i,         // Data flush request
  output wire                         tgu_valid_o,          // TGU Transfer Valid
  output wire [7:0]                   tgu_master_o,         // Master Number
  output wire [15:0]                  tgu_channel_o,        // STPv2 Channel Number
  output wire [2:0]                   tgu_packet_type_o,    // STPv2 Packet Type
  output wire [(STM_DATA_WIDTH/32):0] tgu_size_o,           // Payload Size
  output wire [STM_DATA_WIDTH-1:0]    tgu_payload_o,        // Payload
  output wire [1:0]                   tgu_ts_req_o,         // Timestamp Qualifier
  output wire                         tgu_fready_o,         // Data flush completed

  // Configuration and Status Interface
  input wire                          axi_enable_i,         // STM Enable
  input wire [31:0]                   axi_sper_i,           // SPER value
  input wire [31:0]                   axi_spter_i,          // SPTER value
  input wire                          axi_singleshot_i,     // SPTE singleshot mode
  input wire                          axi_trigstatusspte_i, // SPTE trigger status in singleshot mode
  input wire [11:0]                   axi_banksel_i,        // STMSPSCR.PORTSEL
  input wire [1:0]                    axi_portctl_i,        // STMSPSCR.PORTCTL
  input wire [7:0]                    axi_mastsel_i,        // STMSPMSCR.MASTSEL
  input wire                          axi_mastctl_i,        // STMSPMSCR.MASTCTL
  input wire [16:0]                   axi_overportsel_i,    // STMSPOVERRIDER.PORTSEL
  input wire                          axi_overts_i,         // Timestamp Override
  input wire [1:0]                    axi_overportctl_i,    // STMSPOVERRIDER.OVERCTL
  input wire [7:0]                    axi_overmastsel_i,    // STMSPMOVERRIDER.MASTSEL
  input wire                          axi_overmastctl_i,    // STMSPMOVERRIDER.MASTCTL
  input wire                          axi_tsen_i,           // Timestamping Enable
  input wire                          axi_buf_clr_i,        // AXI Buffer Clear
  output wire                         axi_busy_q_channel_o, // Busy Status
  output wire                         axi_busy_stm_o,       // Busy Status

  // Trigger Interface
  output wire                         triggerspte_o,        // Trigger, matches using STMSPTER
  output wire                         TRIGOUTSPTE,          // Trigger output event, matches using STMSPTER
  output wire                         triggersw_o,          // Trigger, writes to TRIG location
  output wire                         TRIGOUTSW,            // Trigger output event, writes to TRIG location

  // Authentication Interface
  input wire                          dbgen_r_i,            // Invasive debug enable
  input wire                          niden_r_i,            // Non-invasive debug enable
  input wire                          spiden_r_i,           // Secure invasive debug enable
  input wire                          spniden_r_i,          // Secure non-invasive debug enable
  input wire                          nsguaren_r_i,         // Enable non-secure guaranteed stimulus port accesses

  // Integartion testing interface
  input wire                          itctl_i,              // integration mode
  input wire                          ittrigger_we_i,       // write to ITTRIGGER register
  input wire [1:0]                    pwdatadbg1_0_r_i,     // APB data 1:0

  input wire                          q_stop_i              // Q-Channel Stopped
  );


  //----------------------------------------------------------------------------
  // Local Wires
  //----------------------------------------------------------------------------

  wire axi_busy_read;
  wire axi_busy_write;

  //----------------------------------------------------------------------------
  // Module Instantiations
  //----------------------------------------------------------------------------

  // AXI Read
  cxstm500_axislvif_read
  #(
    .AXI_ID_WIDTH           (AXI_ID_WIDTH),
    .STM_DATA_WIDTH         (STM_DATA_WIDTH)
  )
  u_cxstm500_axislvif_read
  (
    .ACLK                   (CLK),
    .ARESETn                (ARESETn),
    .ARVALIDS               (ARVALIDS),
    .ARREADYS               (ARREADYS),
    .ARIDS                  (ARIDS[AXI_ID_WIDTH-1:0]),
    .ARLENS                 (ARLENS[7:0]),
    .RVALIDS                (RVALIDS),
    .RREADYS                (RREADYS),
    .RIDS                   (RIDS[AXI_ID_WIDTH-1:0]),
    .RDATAS                 (RDATAS[STM_DATA_WIDTH-1:0]),
    .RRESPS                 (RRESPS[1:0]),
    .RLASTS                 (RLASTS),
    //Q-Channel
    .q_stop_i               (q_stop_i),
    .axi_busy_o             (axi_busy_read)
  );

  // AXI Write
  cxstm500_axislvif_write
  #(
    .AXI_ID_WIDTH           (AXI_ID_WIDTH),
    .STM_DATA_WIDTH         (STM_DATA_WIDTH)
  )
  u_cxstm500_axislvif_write
  (
    // AXI
    .CLK                    (CLK),
    .ARESETn                (ARESETn),

    .AWIDS                  (AWIDS),
    .AWVALIDS               (AWVALIDS),
    .AWREADYS               (AWREADYS),
    .AWADDRS                (AWADDRS[31:0]),
    .AWSIZES                (AWSIZES[2:0]),
    .AWLENS                 (AWLENS[7:0]),
    .AWBURSTS               (AWBURSTS[1:0]),
    .AWPROTS                (AWPROTS),
    .WVALIDS                (WVALIDS),
    .WREADYS                (WREADYS),
    .WDATAS                 (WDATAS[STM_DATA_WIDTH-1:0]),
    .WSTRBS                 (WSTRBS),
    .WLASTS                 (WLASTS),
    .BVALIDS                (BVALIDS),
    .BREADYS                (BREADYS),
    .BIDS                   (BIDS[AXI_ID_WIDTH-1:0]),
    .BRESPS                 (BRESPS[1:0]),
    // TGU Interface
    .tgu_valid_o            (tgu_valid_o),
    .tgu_ready_i            (tgu_ready_i),
    .tgu_master_o           (tgu_master_o[7:0]),
    .tgu_channel_o          (tgu_channel_o[15:0]),
    .tgu_packet_type_o      (tgu_packet_type_o[2:0]),
    .tgu_size_o             (tgu_size_o),
    .tgu_payload_o          (tgu_payload_o[STM_DATA_WIDTH-1:0]),
    .tgu_ts_req_o           (tgu_ts_req_o[1:0]),
    .tgu_timestamped_i      (tgu_timestamped_i),
    .tgu_fvalid_i           (tgu_fvalid_i),
    .tgu_fready_o           (tgu_fready_o),
    // Configuration Interface
    .axi_enable_i           (axi_enable_i),
    .axi_sper_i             (axi_sper_i[31:0]),
    .axi_spter_i            (axi_spter_i[31:0]),
    .axi_singleshot_i       (axi_singleshot_i),
    .axi_trigstatusspte_i   (axi_trigstatusspte_i),
    .axi_banksel_i          (axi_banksel_i[11:0]),
    .axi_portctl_i          (axi_portctl_i[1:0]),
    .axi_mastsel_i          (axi_mastsel_i[7:0]),
    .axi_mastctl_i          (axi_mastctl_i),
    .axi_overportsel_i      (axi_overportsel_i[16:0]),
    .axi_overts_i           (axi_overts_i),
    .axi_overportctl_i      (axi_overportctl_i[1:0]),
    .axi_overmastsel_i      (axi_overmastsel_i[7:0]),
    .axi_overmastctl_i      (axi_overmastctl_i),
    .axi_tsen_i             (axi_tsen_i),
    .axi_buf_clr_i          (axi_buf_clr_i),
    .axi_busy_q_channel_o   (axi_busy_write),
    .axi_busy_stm_o         (axi_busy_stm_o),
    // Trigger Interface
    .triggerspte_o          (triggerspte_o),
    .TRIGOUTSPTE            (TRIGOUTSPTE),
    .triggersw_o            (triggersw_o),
    .TRIGOUTSW              (TRIGOUTSW),
    // Authentication Interface
    .dbgen_r_i              (dbgen_r_i),
    .niden_r_i              (niden_r_i),
    .spiden_r_i             (spiden_r_i),
    .spniden_r_i            (spniden_r_i),
    .nsguaren_r_i           (nsguaren_r_i),
    // Integartion testing interface
    .itctl_i                (itctl_i),
    .ittrigger_we_i         (ittrigger_we_i),
    .pwdatadbg1_0_r_i       (pwdatadbg1_0_r_i[1:0]),
    //Q-Channel
    .q_stop_i               (q_stop_i)
  );

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  assign axi_busy_q_channel_o = axi_busy_read | axi_busy_write;

endmodule
