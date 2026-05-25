//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: APB Decoder
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_apb_dec `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire                                  apb_bridge_pseldbg_i,
  input  wire [ 21:12]                         apb_bridge_paddrdbg_i,
  // Outputs
  output wire [NUM_CPUS-1: 0]                  apb_dec_pseldbg_dbg_o,
  output wire [NUM_CPUS-1: 0]                  apb_dec_pseldbg_pmu_o,
  output wire [NUM_CPUS-1: 0]                  apb_dec_pseldbg_etm_o,
  output wire [NUM_CPUS-1: 0]                  apb_dec_pseldbg_cti_o,
  output wire                                  apb_dec_pseldbg_rom_o,
  output wire                                  apb_dec_pseldbg_none_o
);

  // -----------------------------
  // Local parameters
  // -----------------------------

  localparam [21:12] CA53_APBADDR_DBG_0 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0000 : 10'b00_0001_0000;
  localparam [21:12] CA53_APBADDR_CTI_0 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1000 : 10'b00_0010_0000;
  localparam [21:12] CA53_APBADDR_PMU_0 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0001 : 10'b00_0011_0000;
  localparam [21:12] CA53_APBADDR_ETM_0 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1100 : 10'b00_0100_0000;

  localparam [21:12] CA53_APBADDR_DBG_1 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0010 : 10'b01_0001_0000;
  localparam [21:12] CA53_APBADDR_CTI_1 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1001 : 10'b01_0010_0000;
  localparam [21:12] CA53_APBADDR_PMU_1 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0011 : 10'b01_0011_0000;
  localparam [21:12] CA53_APBADDR_ETM_1 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1101 : 10'b01_0100_0000;

  localparam [21:12] CA53_APBADDR_DBG_2 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0100 : 10'b10_0001_0000;
  localparam [21:12] CA53_APBADDR_CTI_2 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1010 : 10'b10_0010_0000;
  localparam [21:12] CA53_APBADDR_PMU_2 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0101 : 10'b10_0011_0000;
  localparam [21:12] CA53_APBADDR_ETM_2 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1110 : 10'b10_0100_0000;

  localparam [21:12] CA53_APBADDR_DBG_3 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0110 : 10'b11_0001_0000;
  localparam [21:12] CA53_APBADDR_CTI_3 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1011 : 10'b11_0010_0000;
  localparam [21:12] CA53_APBADDR_PMU_3 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_0111 : 10'b11_0011_0000;
  localparam [21:12] CA53_APBADDR_ETM_3 = LEGACY_V7_DEBUG_MAP ? 10'b00_0001_1111 : 10'b11_0100_0000;

  localparam [21:12] CA53_APBADDR_ROM   = 10'b00_0000_0000;

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire [NUM_CPUS-1:0]  apb_dec_pseldbg_dbg;
  wire [NUM_CPUS-1:0]  apb_dec_pseldbg_pmu;
  wire [NUM_CPUS-1:0]  apb_dec_pseldbg_etm;
  wire [NUM_CPUS-1:0]  apb_dec_pseldbg_cti;
  wire                 apb_dec_pseldbg_rom;
  wire                 apb_dec_pseldbg_none;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // CPU 0
  // ------------------------------------------------------

  assign apb_dec_pseldbg_dbg[0] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_DBG_0[21:12]);
  assign apb_dec_pseldbg_pmu[0] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_PMU_0[21:12]);
  assign apb_dec_pseldbg_etm[0] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_ETM_0[21:12]);
  assign apb_dec_pseldbg_cti[0] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_CTI_0[21:12]);

  // ------------------------------------------------------
  // CPU 1
  // ------------------------------------------------------

generate if (NUM_CPUS >= 2) begin
  assign apb_dec_pseldbg_dbg[1] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_DBG_1[21:12]);
  assign apb_dec_pseldbg_pmu[1] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_PMU_1[21:12]);
  assign apb_dec_pseldbg_etm[1] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_ETM_1[21:12]);
  assign apb_dec_pseldbg_cti[1] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_CTI_1[21:12]);
end endgenerate

  // ------------------------------------------------------
  // CPU 2
  // ------------------------------------------------------

generate if (NUM_CPUS >= 3) begin
  assign apb_dec_pseldbg_dbg[2] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_DBG_2[21:12]);
  assign apb_dec_pseldbg_pmu[2] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_PMU_2[21:12]);
  assign apb_dec_pseldbg_etm[2] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_ETM_2[21:12]);
  assign apb_dec_pseldbg_cti[2] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_CTI_2[21:12]);
end endgenerate

  // ------------------------------------------------------
  // CPU 3
  // ------------------------------------------------------

generate if (NUM_CPUS >= 4) begin
  assign apb_dec_pseldbg_dbg[3] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_DBG_3[21:12]);
  assign apb_dec_pseldbg_pmu[3] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_PMU_3[21:12]);
  assign apb_dec_pseldbg_etm[3] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_ETM_3[21:12]);
  assign apb_dec_pseldbg_cti[3] = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_CTI_3[21:12]);
end endgenerate

  // ------------------------------------------------------
  // ROM Decode
  // ------------------------------------------------------

  assign apb_dec_pseldbg_rom = apb_bridge_pseldbg_i & (apb_bridge_paddrdbg_i[21:12] == CA53_APBADDR_ROM[21:12]);

  // ------------------------------------------------------
  // Identify 'none' condition
  // ------------------------------------------------------

  assign apb_dec_pseldbg_none = ~(|apb_dec_pseldbg_dbg) &
                                ~(|apb_dec_pseldbg_pmu) &
                                ~(|apb_dec_pseldbg_etm) &
                                ~(|apb_dec_pseldbg_cti) &
                                  ~apb_dec_pseldbg_rom;

  // ------------------------------------------------------
  // Output assignments
  // ------------------------------------------------------

  assign apb_dec_pseldbg_dbg_o  = apb_dec_pseldbg_dbg;
  assign apb_dec_pseldbg_pmu_o  = apb_dec_pseldbg_pmu;
  assign apb_dec_pseldbg_etm_o  = apb_dec_pseldbg_etm;
  assign apb_dec_pseldbg_cti_o  = apb_dec_pseldbg_cti;
  assign apb_dec_pseldbg_rom_o  = apb_dec_pseldbg_rom;
  assign apb_dec_pseldbg_none_o = apb_dec_pseldbg_none;

endmodule // ca53governor_apb_dec

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
