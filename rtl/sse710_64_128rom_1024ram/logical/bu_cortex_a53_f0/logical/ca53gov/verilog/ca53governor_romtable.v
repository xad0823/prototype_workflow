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
// Description: Debug Sub System ROM Table
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53governor_romtable `CA53_GOVERNOR_PARAM_DECL (
  // Inputs
  input  wire [11:2]                         apb_bridge_paddrdbg_i,
  input  wire                                apb_dec_pseldbg_rom_i,
  // Outputs
  output wire                                preadydbg_rom_o,
  output wire                                pslverrdbg_rom_o,
  output wire [31:0]                         prdatadbg_rom_o);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire                                 addr_cid_0;
  wire                                 addr_cid_1;
  wire                                 addr_cid_2;
  wire                                 addr_cid_3;
  wire                                 addr_entry_0;
  wire                                 addr_entry_1;
  wire                                 addr_entry_2;
  wire                                 addr_entry_3;
  wire                                 addr_entry_4;
  wire                                 addr_entry_5;
  wire                                 addr_entry_6;
  wire                                 addr_entry_7;
  wire                                 addr_entry_8;
  wire                                 addr_entry_9;
  wire                                 addr_entry_a;
  wire                                 addr_entry_b;
  wire                                 addr_entry_c;
  wire                                 addr_entry_d;
  wire                                 addr_entry_e;
  wire                                 addr_entry_f;
  wire                                 addr_pid_0;
  wire                                 addr_pid_1;
  wire                                 addr_pid_2;
  wire                                 addr_pid_4;
  wire [ 31:  0]                       entry_cti_0;
  wire [ 31:  0]                       entry_cti_1;
  wire [ 31:  0]                       entry_cti_2;
  wire [ 31:  0]                       entry_cti_3;
  wire [ 31:  0]                       entry_dbg_0;
  wire [ 31:  0]                       entry_dbg_1;
  wire [ 31:  0]                       entry_dbg_2;
  wire [ 31:  0]                       entry_dbg_3;
  wire [ 31:  0]                       entry_etm_0;
  wire [ 31:  0]                       entry_etm_1;
  wire [ 31:  0]                       entry_etm_2;
  wire [ 31:  0]                       entry_etm_3;
  wire [ 31:  0]                       entry_pmu_0;
  wire [ 31:  0]                       entry_pmu_1;
  wire [ 31:  0]                       entry_pmu_2;
  wire [ 31:  0]                       entry_pmu_3;

  // -----------------------------
  // Parameter declarations
  // -----------------------------

  localparam [31:0] CA53_ROM_PERIPHID0_VAL = LEGACY_V7_DEBUG_MAP ? 32'h0000_00A3 : 32'h0000_00A1;
  localparam [31:0] CA53_ROM_PERIPHID1_VAL = 32'h0000_00B4;
  localparam [31:0] CA53_ROM_PERIPHID2_VAL = {24'h0000_00, `CA53_PERPH_REVISION, 4'hB};
  localparam [31:0] CA53_ROM_PERIPHID4_VAL = 32'h0000_0004;
  localparam [31:0] CA53_ROM_COMPONID0_VAL = 32'h0000_000D;
  localparam [31:0] CA53_ROM_COMPONID1_VAL = 32'h0000_0010;
  localparam [31:0] CA53_ROM_COMPONID2_VAL = 32'h0000_0005;
  localparam [31:0] CA53_ROM_COMPONID3_VAL = 32'h0000_00B1;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // ROM table entries
  // ------------------------------------------------------

  // Entries take the following format:
  //
  // |-------|----------------|--------------------------------------------------
  // | Bits  | Name           | Description                                     |
  // |-------|----------------|-------------------------------------------------|
  // | 31:22 |      -         | Reserved RAZ                                    |
  // |-------|----------------|-------------------------------------------------|
  // | 21:12 | Address offset | {Bits[7:2],4'b0000} of the ROM Index            |
  // |-------|----------------|-------------------------------------------------|
  // | 11:2  |      -         | Reserved RAZ                                    |
  // |-------|----------------|-------------------------------------------------|
  // | 1     |      -         | 32 bit format RAO
  // |-------|----------------|-------------------------------------------------|
  // | 0     | Entry present  | Set if corresponding unit exists                |
  // |-------|----------------|-------------------------------------------------|

  // Note: If a cpu is present then DBG, PMU, CTI and ETM corresponding to that
  // cpu will always be present.

  // CPU0 always present
  generate if (LEGACY_V7_DEBUG_MAP[0] == 0) begin : cpu0_v8_romtable
    assign entry_dbg_0[31:0] = 32'h0001_0003;
    assign entry_cti_0[31:0] = 32'h0002_0003;
    assign entry_pmu_0[31:0] = 32'h0003_0003;
    assign entry_etm_0[31:0] = 32'h0004_0003;
  end else if (LEGACY_V7_DEBUG_MAP[0] == 1) begin : cpu0_v7_romtable
    assign entry_dbg_0[31:0] = 32'h0001_0003;
    assign entry_cti_0[31:0] = 32'h0001_8003;
    assign entry_pmu_0[31:0] = 32'h0001_1003;
    assign entry_etm_0[31:0] = 32'h0001_C003;
  end
  endgenerate

  // CPU1
  generate if (LEGACY_V7_DEBUG_MAP[0] == 0 && NUM_CPUS >= 2) begin : cpu1_v8_romtable
    assign entry_dbg_1[31:0] = 32'h0011_0003;
    assign entry_cti_1[31:0] = 32'h0012_0003;
    assign entry_pmu_1[31:0] = 32'h0013_0003;
    assign entry_etm_1[31:0] = 32'h0014_0003;
  end else if (LEGACY_V7_DEBUG_MAP[0] == 1 && NUM_CPUS >= 2) begin : cpu1_v7_romtable
    assign entry_dbg_1[31:0] = 32'h0001_2003;
    assign entry_cti_1[31:0] = 32'h0001_9003;
    assign entry_pmu_1[31:0] = 32'h0001_3003;
    assign entry_etm_1[31:0] = 32'h0001_D003;
  end else begin : cpu1_tieoffs
    assign entry_dbg_1[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_cti_1[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_pmu_1[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_etm_1[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
  end
  endgenerate

  // CPU2
  generate if (LEGACY_V7_DEBUG_MAP[0] == 0 && NUM_CPUS >= 3) begin : cpu2_v8_romtable
    assign entry_dbg_2[31:0] = 32'h0021_0003;
    assign entry_cti_2[31:0] = 32'h0022_0003;
    assign entry_pmu_2[31:0] = 32'h0023_0003;
    assign entry_etm_2[31:0] = 32'h0024_0003;
  end else if (LEGACY_V7_DEBUG_MAP[0] == 1 && NUM_CPUS >= 3) begin : cpu2_v7_romtable
    assign entry_dbg_2[31:0] = 32'h0001_4003;
    assign entry_cti_2[31:0] = 32'h0001_A003;
    assign entry_pmu_2[31:0] = 32'h0001_5003;
    assign entry_etm_2[31:0] = 32'h0001_E003;
  end else begin : cpu2_tieoffs
    assign entry_dbg_2[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_cti_2[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_pmu_2[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_etm_2[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
  end
  endgenerate

  // CPU3
  generate if (LEGACY_V7_DEBUG_MAP[0] == 0 && NUM_CPUS >= 4) begin : cpu3_v8_romtable
    assign entry_dbg_3[31:0] = 32'h0031_0003;
    assign entry_cti_3[31:0] = 32'h0032_0003;
    assign entry_pmu_3[31:0] = 32'h0033_0003;
    assign entry_etm_3[31:0] = 32'h0034_0003;
  end else if (LEGACY_V7_DEBUG_MAP[0] == 1 && NUM_CPUS >= 4) begin : cpu3_v7_romtable
    assign entry_dbg_3[31:0] = 32'h0001_6003;
    assign entry_cti_3[31:0] = 32'h0001_B003;
    assign entry_pmu_3[31:0] = 32'h0001_7003;
    assign entry_etm_3[31:0] = 32'h0001_F003;
  end else begin : cpu3_tieoffs
    assign entry_dbg_3[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_cti_3[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_pmu_3[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
    assign entry_etm_3[31:0] = LEGACY_V7_DEBUG_MAP[0] ? 32'h0000_0002 : 32'h0000_0000;
  end
  endgenerate

  // ------------------------------------------------------
  // Decode address
  // ------------------------------------------------------

  assign addr_entry_0 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0000_00);
  assign addr_entry_1 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0000_01);
  assign addr_entry_2 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0000_10);
  assign addr_entry_3 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0000_11);
  assign addr_entry_4 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0001_00);
  assign addr_entry_5 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0001_01);
  assign addr_entry_6 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0001_10);
  assign addr_entry_7 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0001_11);
  assign addr_entry_8 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0010_00);
  assign addr_entry_9 = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0010_01);
  assign addr_entry_a = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0010_10);
  assign addr_entry_b = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0010_11);
  assign addr_entry_c = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0011_00);
  assign addr_entry_d = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0011_01);
  assign addr_entry_e = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0011_10);
  assign addr_entry_f = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b0000_0011_11);

  assign addr_pid_4   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1101_00);

  assign addr_pid_0   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1110_00);
  assign addr_pid_1   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1110_01);
  assign addr_pid_2   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1110_10);

  assign addr_cid_0   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1111_00);
  assign addr_cid_1   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1111_01);
  assign addr_cid_2   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1111_10);
  assign addr_cid_3   = apb_dec_pseldbg_rom_i & (apb_bridge_paddrdbg_i[11:2] == 10'b1111_1111_11);

  // ------------------------------------------------------
  // Read Data Mux
  // ------------------------------------------------------

  generate if (LEGACY_V7_DEBUG_MAP[0] == 0) begin : v8_romtable_order
    assign prdatadbg_rom_o[31:0] = (// CPU0
                                    ({32{addr_entry_0}} & entry_dbg_0[31:0]) |
                                    ({32{addr_entry_1}} & entry_cti_0[31:0]) |
                                    ({32{addr_entry_2}} & entry_pmu_0[31:0]) |
                                    ({32{addr_entry_3}} & entry_etm_0[31:0]) |
                                    // CPU1
                                    ({32{addr_entry_4}} & entry_dbg_1[31:0]) |
                                    ({32{addr_entry_5}} & entry_cti_1[31:0]) |
                                    ({32{addr_entry_6}} & entry_pmu_1[31:0]) |
                                    ({32{addr_entry_7}} & entry_etm_1[31:0]) |
                                    // CPU2
                                    ({32{addr_entry_8}} & entry_dbg_2[31:0]) |
                                    ({32{addr_entry_9}} & entry_cti_2[31:0]) |
                                    ({32{addr_entry_a}} & entry_pmu_2[31:0]) |
                                    ({32{addr_entry_b}} & entry_etm_2[31:0]) |
                                    // CPU3
                                    ({32{addr_entry_c}} & entry_dbg_3[31:0]) |
                                    ({32{addr_entry_d}} & entry_cti_3[31:0]) |
                                    ({32{addr_entry_e}} & entry_pmu_3[31:0]) |
                                    ({32{addr_entry_f}} & entry_etm_3[31:0]) |
                                    // Management Registers
                                    ({32{addr_pid_0}} & CA53_ROM_PERIPHID0_VAL) |
                                    ({32{addr_pid_1}} & CA53_ROM_PERIPHID1_VAL) |
                                    ({32{addr_pid_2}} & CA53_ROM_PERIPHID2_VAL) |
                                    ({32{addr_pid_4}} & CA53_ROM_PERIPHID4_VAL) |
                                    ({32{addr_cid_0}} & CA53_ROM_COMPONID0_VAL) |
                                    ({32{addr_cid_1}} & CA53_ROM_COMPONID1_VAL) |
                                    ({32{addr_cid_2}} & CA53_ROM_COMPONID2_VAL) |
                                    ({32{addr_cid_3}} & CA53_ROM_COMPONID3_VAL));
  end else begin : v7_romtable_order
    assign prdatadbg_rom_o[31:0] = (// CPU0-3 Debug & PMU
                                    ({32{addr_entry_0}} & entry_dbg_0[31:0]) |
                                    ({32{addr_entry_1}} & entry_pmu_0[31:0]) |
                                    ({32{addr_entry_2}} & entry_dbg_1[31:0]) |
                                    ({32{addr_entry_3}} & entry_pmu_1[31:0]) |
                                    ({32{addr_entry_4}} & entry_dbg_2[31:0]) |
                                    ({32{addr_entry_5}} & entry_pmu_2[31:0]) |
                                    ({32{addr_entry_6}} & entry_dbg_3[31:0]) |
                                    ({32{addr_entry_7}} & entry_pmu_3[31:0]) |
                                    // CTI0-3
                                    ({32{addr_entry_8}} & entry_cti_0[31:0]) |
                                    ({32{addr_entry_9}} & entry_cti_1[31:0]) |
                                    ({32{addr_entry_a}} & entry_cti_2[31:0]) |
                                    ({32{addr_entry_b}} & entry_cti_3[31:0]) |
                                    // ETM0-3
                                    ({32{addr_entry_c}} & entry_etm_0[31:0]) |
                                    ({32{addr_entry_d}} & entry_etm_1[31:0]) |
                                    ({32{addr_entry_e}} & entry_etm_2[31:0]) |
                                    ({32{addr_entry_f}} & entry_etm_3[31:0]) |
                                    // Management Registers
                                    ({32{addr_pid_0}} & CA53_ROM_PERIPHID0_VAL) |
                                    ({32{addr_pid_1}} & CA53_ROM_PERIPHID1_VAL) |
                                    ({32{addr_pid_2}} & {{24{1'b0}}, {4{1'b0}}, CA53_ROM_PERIPHID2_VAL}) |
                                    ({32{addr_pid_4}} & CA53_ROM_PERIPHID4_VAL) |
                                    ({32{addr_cid_0}} & CA53_ROM_COMPONID0_VAL) |
                                    ({32{addr_cid_1}} & CA53_ROM_COMPONID1_VAL) |
                                    ({32{addr_cid_2}} & CA53_ROM_COMPONID2_VAL) |
                                    ({32{addr_cid_3}} & CA53_ROM_COMPONID3_VAL));
  end
  endgenerate

  assign preadydbg_rom_o  = 1'b1;
  assign pslverrdbg_rom_o = 1'b0;

endmodule // ca53governor_romtable

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
