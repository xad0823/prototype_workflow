//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2015-02-17 13:54:57 +0000 (Tue, 17 Feb 2015) $
//
//      Revision            : $Revision: 302088 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//------------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description: Caches and TLB RAMs wrapper
//-----------------------------------------------------------------------------

`include "cortexa53params.v"

module ca53_caches_tlb_rams `CA53_L1_RAM_PARAM_DECL
(
  // Control
  input  wire                               clk,
  input  wire                               DFTSE,

  // Size signalling
  output wire [2:0]                         ic_size_o,
  output wire [2:0]                         dc_size_o,

  // L1 Data Cache Data RAMs
  // 8 banks (byte enable without ECC, global enable with ECC)
  input  wire [7:0]                         dc_dataram_en_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb0_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb1_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb2_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb3_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb4_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb5_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb6_i,
  input  wire [`CA53_DDATA_WEN_W-1:0]       dc_dataram_strb7_i,
  input  wire                               dc_dataram_wr_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata0_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata1_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata2_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata3_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata4_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata5_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata6_i,
  input  wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_wdata7_i,
  input  wire [10:0]                        dc_dataram_addr0_i,
  input  wire [10:0]                        dc_dataram_addr1_i,
  input  wire [10:0]                        dc_dataram_addr2_i,
  input  wire [10:0]                        dc_dataram_addr3_i,
  input  wire [10:0]                        dc_dataram_addr4_i,
  input  wire [10:0]                        dc_dataram_addr5_i,
  input  wire [10:0]                        dc_dataram_addr6_i,
  input  wire [10:0]                        dc_dataram_addr7_i,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata0_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata1_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata2_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata3_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata4_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata5_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata6_o,
  output wire [`CA53_DDATA_RAM_W-1:0]       dc_dataram_rdata7_o,

  // L1 Data Cache Tag RAMs
  // 4 banks (global enable)
  input  wire [3:0]                         dc_tagram_en_i,
  input  wire                               dc_tagram_wr_i,
  input  wire [`CA53_DTAG_RAM_W-1:0]        dc_tagram_wdata_i,
  input  wire [7:0]                         dc_tagram_addr_i,
  output wire [`CA53_DTAG_RAM_W-1:0]        dc_tagram_rdata0_o,
  output wire [`CA53_DTAG_RAM_W-1:0]        dc_tagram_rdata1_o,
  output wire [`CA53_DTAG_RAM_W-1:0]        dc_tagram_rdata2_o,
  output wire [`CA53_DTAG_RAM_W-1:0]        dc_tagram_rdata3_o,

  // L1 Data Cache Dirty RAM
  // 1 bank (bit enable)
  input  wire                               dc_dirtyram_en_i,
  input  wire [`CA53_DDIRTY_RAM_W-1:0]      dc_dirtyram_strb_i,
  input  wire                               dc_dirtyram_wr_i,
  input  wire [`CA53_DDIRTY_RAM_W-1:0]      dc_dirtyram_wdata_i,
  input  wire [8:0]                         dc_dirtyram_addr_i,
  output wire [`CA53_DDIRTY_RAM_W-1:0]      dc_dirtyram_rdata_o,

  // L1 Instruction Cache Data RAMs
  // 2 banks (sub-data enable)
  input  wire [3:0]                         ic_dataram_en_i,
  input  wire                               ic_dataram_wr_i,
  input  wire [11:0]                        ic_dataram_addr0_i,
  input  wire [11:0]                        ic_dataram_addr1_i,
  input  wire [`CA53_IDATA_WEN_W-1:0]       ic_dataram_strb0_i,
  input  wire [`CA53_IDATA_WEN_W-1:0]       ic_dataram_strb1_i,
  input  wire [`CA53_IDATA_RAM_W-1:0]       ic_dataram_wdata0_i,
  input  wire [`CA53_IDATA_RAM_W-1:0]       ic_dataram_wdata1_i,
  output wire [`CA53_IDATA_RAM_W-1:0]       ic_dataram_rdata0_o,
  output wire [`CA53_IDATA_RAM_W-1:0]       ic_dataram_rdata1_o,

  // L1 Instruction Cache Tag RAMs
  // 2 banks (global enable)
  input  wire [1:0]                         ic_tagram_en_i,
  input  wire                               ic_tagram_wr_i,
  input  wire [`CA53_ITAG_RAM_W-1:0]        ic_tagram_wdata_i,
  input  wire [8:0]                         ic_tagram_addr_i,
  output wire [`CA53_ITAG_RAM_W-1:0]        ic_tagram_rdata0_o,
  output wire [`CA53_ITAG_RAM_W-1:0]        ic_tagram_rdata1_o,

  // TLB RAMs
  // 2 banks (global enable)
  input  wire [3:0]                         tlb_ram_en_i,
  input  wire                               tlb_ram_wr_i,
  input  wire [`CA53_TLB_RAM_W-1:0]         tlb_ram_wdata_i,
  input  wire [`CA53_TLB_RAM_ADDR_W-1:0]    tlb_ram_addr_i,
  output wire [`CA53_TLB_RAM_W-1:0]         tlb_ram_rdata0_o,
  output wire [`CA53_TLB_RAM_W-1:0]         tlb_ram_rdata1_o,
  output wire [`CA53_TLB_RAM_W-1:0]         tlb_ram_rdata2_o,
  output wire [`CA53_TLB_RAM_W-1:0]         tlb_ram_rdata3_o,

  // BTAC RAM Interface
  // 2 banks (global enable)
  input  wire                               btac_stg0_ram_en_i,
  input  wire                               btac_stg0_ram_wr_i,
  input  wire [(`CA53_BTAC_RAM_S0D_W-1):0]  btac_stg0_ram_wdata_i,
  input  wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg0_ram_addr_i,
  input  wire                               btac_stg1_ram_en_i,
  input  wire                               btac_stg1_ram_wr_i,
  input  wire [(`CA53_BTAC_RAM_S1D_W-1):0]  btac_stg1_ram_wdata_i,
  input  wire [(`CA53_BTAC_RAM_ADDR_W-1):0] btac_stg1_ram_addr_i,
  output wire [(`CA53_BTAC_RAM_S0D_W-1):0]  btac_stg0_ram_rdata_o,
  output wire [(`CA53_BTAC_RAM_S1D_W-1):0]  btac_stg1_ram_rdata_o
  );

  // -----------------------------
  // Wire declarations
  // -----------------------------

  // Local size signals declaration which can be used to force a value
  // for dynamic verification and it can be used as a mask to set
  // generic RAM modules
  wire [2:0]                     i_size_mask;
  wire [2:0]                     d_size_mask;

  // Instruction cache wires
  wire [11:0]                    ic_dataram_addr0_masked;
  wire [11:0]                    ic_dataram_addr1_masked;
  wire [8:0]                     ic_tagram_addr_masked;

  // Data cache wires
  wire [10:0]                    dc_dataram_addr0_masked;
  wire [10:0]                    dc_dataram_addr1_masked;
  wire [10:0]                    dc_dataram_addr2_masked;
  wire [10:0]                    dc_dataram_addr3_masked;
  wire [10:0]                    dc_dataram_addr4_masked;
  wire [10:0]                    dc_dataram_addr5_masked;
  wire [10:0]                    dc_dataram_addr6_masked;
  wire [10:0]                    dc_dataram_addr7_masked;
  wire [7:0]                     dc_tagram_addr_masked;
  wire [8:0]                     dc_dirtyram_addr_masked;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Cache size signalling
  // ------------------------------------------------------

  assign i_size_mask = L1_ICACHE_SIZE;
  assign d_size_mask = L1_DCACHE_SIZE;

  assign ic_size_o = i_size_mask;
  assign dc_size_o = d_size_mask;

  // ------------------------------------------------------
  // Instruction Cache Data RAM Instantiation
  // ------------------------------------------------------

  // Address masking. This is only required for the generic RAMs that support
  // multiple cache sizes. For an implementation that has a fixed size there
  // is no need to mask, simply connect the address directly, leaving any
  // unused upper bits of the address unconnected.
  assign ic_dataram_addr0_masked[11:0] = ic_dataram_addr0_i & {i_size_mask, 9'b111111111};
  assign ic_dataram_addr1_masked[11:0] = ic_dataram_addr1_i & {i_size_mask, 9'b111111111};

  ca53_generic_ram #(.addr_bits(12), .data_bits(`CA53_IDATA_RAM_W/2), .we_size(`CA53_IDATA_RAM_W/4), .reset(0), .reset_high(0)) u_idata_bank0_lo
    (
     .clk    (clk),
     .addr_i (ic_dataram_addr0_masked[11:0]),
     .rd_o   (ic_dataram_rdata0_o[(`CA53_IDATA_RAM_W/2)-1:0]),
     .wd_i   (ic_dataram_wdata0_i[(`CA53_IDATA_RAM_W/2)-1:0]),
     .cs_i   (ic_dataram_en_i[0]),
     .we_i   (ic_dataram_strb0_i[1:0])
     );

  ca53_generic_ram #(.addr_bits(12), .data_bits(`CA53_IDATA_RAM_W/2), .we_size(`CA53_IDATA_RAM_W/4), .reset(0), .reset_high(0)) u_idata_bank0_hi
    (
     .clk    (clk),
     .addr_i (ic_dataram_addr0_masked[11:0]),
     .rd_o   (ic_dataram_rdata0_o[`CA53_IDATA_RAM_W-1:(`CA53_IDATA_RAM_W/2)]),
     .wd_i   (ic_dataram_wdata0_i[`CA53_IDATA_RAM_W-1:(`CA53_IDATA_RAM_W/2)]),
     .cs_i   (ic_dataram_en_i[1]),
     .we_i   (ic_dataram_strb0_i[3:2])
     );

  ca53_generic_ram #(.addr_bits(12), .data_bits(`CA53_IDATA_RAM_W/2), .we_size(`CA53_IDATA_RAM_W/4), .reset(0), .reset_high(0)) u_idata_bank1_lo
    (
     .clk    (clk),
     .addr_i (ic_dataram_addr1_masked[11:0]),
     .rd_o   (ic_dataram_rdata1_o[(`CA53_IDATA_RAM_W/2)-1:0]),
     .wd_i   (ic_dataram_wdata1_i[(`CA53_IDATA_RAM_W/2)-1:0]),
     .cs_i   (ic_dataram_en_i[2]),
     .we_i   (ic_dataram_strb1_i[1:0])
     );

  ca53_generic_ram #(.addr_bits(12), .data_bits(`CA53_IDATA_RAM_W/2), .we_size(`CA53_IDATA_RAM_W/4), .reset(0), .reset_high(0)) u_idata_bank1_hi
    (
     .clk    (clk),
     .addr_i (ic_dataram_addr1_masked[11:0]),
     .rd_o   (ic_dataram_rdata1_o[`CA53_IDATA_RAM_W-1:(`CA53_IDATA_RAM_W/2)]),
     .wd_i   (ic_dataram_wdata1_i[`CA53_IDATA_RAM_W-1:(`CA53_IDATA_RAM_W/2)]),
     .cs_i   (ic_dataram_en_i[3]),
     .we_i   (ic_dataram_strb1_i[3:2])
     );

  // ------------------------------------------------------
  // Instruction Cache Tag RAM Instantiation
  // ------------------------------------------------------

  // Address masking. This is only required for the generic RAMs that support
  // multiple cache sizes. For an implementation that has a fixed size there
  // is no need to mask, simply connect the address directly, leaving any
  // unused upper bits of the address unconnected.
  assign ic_tagram_addr_masked[8:0] = ic_tagram_addr_i & {i_size_mask, 6'b111111};

  ca53_generic_ram #(.addr_bits(9), .data_bits(`CA53_ITAG_RAM_W), .we_size(`CA53_ITAG_RAM_W), .reset(1), .reset_high(1)) u_itag_ram0
    (
     .clk    (clk),
     .addr_i (ic_tagram_addr_masked[8:0]),
     .rd_o   (ic_tagram_rdata0_o[`CA53_ITAG_RAM_W-1:0]),
     .wd_i   (ic_tagram_wdata_i[`CA53_ITAG_RAM_W-1:0]),
     .cs_i   (ic_tagram_en_i[0]),
     .we_i   (ic_tagram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(9), .data_bits(`CA53_ITAG_RAM_W), .we_size(`CA53_ITAG_RAM_W), .reset(1), .reset_high(1)) u_itag_ram1
    (
     .clk    (clk),
     .addr_i (ic_tagram_addr_masked[8:0]),
     .rd_o   (ic_tagram_rdata1_o[`CA53_ITAG_RAM_W-1:0]),
     .wd_i   (ic_tagram_wdata_i[`CA53_ITAG_RAM_W-1:0]),
     .cs_i   (ic_tagram_en_i[1]),
     .we_i   (ic_tagram_wr_i)
     );

  // ------------------------------------------------------
  // Data Cache Data RAM Instantiation
  // ------------------------------------------------------

  // Address masking. This is only required for the generic RAMs that support
  // multiple cache sizes. For an implementation that has a fixed size there
  // is no need to mask, simply connect the address directly, leaving any
  // unused upper bits of the address unconnected.
  assign dc_dataram_addr0_masked[10:0] = dc_dataram_addr0_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr1_masked[10:0] = dc_dataram_addr1_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr2_masked[10:0] = dc_dataram_addr2_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr3_masked[10:0] = dc_dataram_addr3_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr4_masked[10:0] = dc_dataram_addr4_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr5_masked[10:0] = dc_dataram_addr5_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr6_masked[10:0] = dc_dataram_addr6_i & {d_size_mask, 8'b11111111};
  assign dc_dataram_addr7_masked[10:0] = dc_dataram_addr7_i & {d_size_mask, 8'b11111111};

  generate if (CPU_CACHE_PROTECTION) begin : g_cpu_cache_protection

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank0
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr0_masked[10:0]),
       .rd_o   (dc_dataram_rdata0_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata0_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[0]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank1
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr1_masked[10:0]),
       .rd_o   (dc_dataram_rdata1_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata1_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[1]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank2
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr2_masked[10:0]),
       .rd_o   (dc_dataram_rdata2_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata2_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[2]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank3
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr3_masked[10:0]),
       .rd_o   (dc_dataram_rdata3_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata3_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[3]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank4
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr4_masked[10:0]),
       .rd_o   (dc_dataram_rdata4_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata4_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[4]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank5
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr5_masked[10:0]),
       .rd_o   (dc_dataram_rdata5_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata5_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[5]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank6
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr6_masked[10:0]),
       .rd_o   (dc_dataram_rdata6_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata6_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[6]),
       .we_i   (dc_dataram_wr_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(`CA53_DDATA_RAM_W)) u_ddata_bank7
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr7_masked[10:0]),
       .rd_o   (dc_dataram_rdata7_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata7_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[7]),
       .we_i   (dc_dataram_wr_i)
       );

  end else begin : g_no_cpu_cache_protection

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank0
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr0_masked[10:0]),
       .rd_o   (dc_dataram_rdata0_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata0_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[0]),
       .we_i   (dc_dataram_strb0_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank1
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr1_masked[10:0]),
       .rd_o   (dc_dataram_rdata1_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata1_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[1]),
       .we_i   (dc_dataram_strb1_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank2
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr2_masked[10:0]),
       .rd_o   (dc_dataram_rdata2_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata2_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[2]),
       .we_i   (dc_dataram_strb2_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank3
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr3_masked[10:0]),
       .rd_o   (dc_dataram_rdata3_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata3_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[3]),
       .we_i   (dc_dataram_strb3_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank4
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr4_masked[10:0]),
       .rd_o   (dc_dataram_rdata4_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata4_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[4]),
       .we_i   (dc_dataram_strb4_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank5
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr5_masked[10:0]),
       .rd_o   (dc_dataram_rdata5_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata5_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[5]),
       .we_i   (dc_dataram_strb5_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank6
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr6_masked[10:0]),
       .rd_o   (dc_dataram_rdata6_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata6_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[6]),
       .we_i   (dc_dataram_strb6_i)
       );

    ca53_generic_ram #(.addr_bits(11), .data_bits(`CA53_DDATA_RAM_W), .we_size(8)) u_ddata_bank7
      (
       .clk    (clk),
       .addr_i (dc_dataram_addr7_masked[10:0]),
       .rd_o   (dc_dataram_rdata7_o[`CA53_DDATA_RAM_W-1:0]),
       .wd_i   (dc_dataram_wdata7_i[`CA53_DDATA_RAM_W-1:0]),
       .cs_i   (dc_dataram_en_i[7]),
       .we_i   (dc_dataram_strb7_i)
       );

  end
  endgenerate

  // ------------------------------------------------------
  // Data Cache Tag RAM Instantiation
  // ------------------------------------------------------

  // Address masking. This is only required for the generic RAMs that support
  // multiple cache sizes. For an implementation that has a fixed size there
  // is no need to mask, simply connect the address directly, leaving any
  // unused upper bits of the address unconnected.
  assign dc_tagram_addr_masked[7:0] = dc_tagram_addr_i & {d_size_mask, 5'b11111};

  ca53_generic_ram #(.addr_bits(8), .data_bits(`CA53_DTAG_RAM_W), .we_size(`CA53_DTAG_RAM_W), .reset(0), .reset_high(0)) u_dtag_bank0
    (
     .clk    (clk),
     .addr_i (dc_tagram_addr_masked[7:0]),
     .rd_o   (dc_tagram_rdata0_o[`CA53_DTAG_RAM_W-1:0]),
     .wd_i   (dc_tagram_wdata_i[`CA53_DTAG_RAM_W-1:0]),
     .cs_i   (dc_tagram_en_i[0]),
     .we_i   (dc_tagram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(8), .data_bits(`CA53_DTAG_RAM_W), .we_size(`CA53_DTAG_RAM_W), .reset(0), .reset_high(0)) u_dtag_bank1
    (
     .clk    (clk),
     .addr_i (dc_tagram_addr_masked[7:0]),
     .rd_o   (dc_tagram_rdata1_o[`CA53_DTAG_RAM_W-1:0]),
     .wd_i   (dc_tagram_wdata_i[`CA53_DTAG_RAM_W-1:0]),
     .cs_i   (dc_tagram_en_i[1]),
     .we_i   (dc_tagram_wr_i)
     );


  ca53_generic_ram #(.addr_bits(8), .data_bits(`CA53_DTAG_RAM_W), .we_size(`CA53_DTAG_RAM_W), .reset(0), .reset_high(0)) u_dtag_bank2
    (
     .clk    (clk),
     .addr_i (dc_tagram_addr_masked[7:0]),
     .rd_o   (dc_tagram_rdata2_o[`CA53_DTAG_RAM_W-1:0]),
     .wd_i   (dc_tagram_wdata_i[`CA53_DTAG_RAM_W-1:0]),
     .cs_i   (dc_tagram_en_i[2]),
     .we_i   (dc_tagram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(8), .data_bits(`CA53_DTAG_RAM_W), .we_size(`CA53_DTAG_RAM_W), .reset(0), .reset_high(0)) u_dtag_bank3
    (
     .clk    (clk),
     .addr_i (dc_tagram_addr_masked[7:0]),
     .rd_o   (dc_tagram_rdata3_o[`CA53_DTAG_RAM_W-1:0]),
     .wd_i   (dc_tagram_wdata_i[`CA53_DTAG_RAM_W-1:0]),
     .cs_i   (dc_tagram_en_i[3]),
     .we_i   (dc_tagram_wr_i)
     );

  // ------------------------------------------------------
  // Data Cache Dirty RAM Instantiation
  // ------------------------------------------------------

  // Address masking. This is only required for the generic RAMs that support
  // multiple cache sizes. For an implementation that has a fixed size there
  // is no need to mask, simply connect the address directly, leaving any
  // unused upper bits of the address unconnected.
  assign dc_dirtyram_addr_masked[8:0] = dc_dirtyram_addr_i & {d_size_mask, 6'b111111};

  ca53_generic_ram #(.addr_bits(9), .data_bits(`CA53_DDIRTY_RAM_W), .we_size(1), .reset(0), .reset_high(0)) u_ddirty_ram
    (
     .clk    (clk),
     .addr_i (dc_dirtyram_addr_masked[8:0]),
     .rd_o   (dc_dirtyram_rdata_o[`CA53_DDIRTY_RAM_W-1:0]),
     .wd_i   (dc_dirtyram_wdata_i[`CA53_DDIRTY_RAM_W-1:0]),
     .cs_i   (dc_dirtyram_en_i),
     .we_i   (dc_dirtyram_strb_i)
     );

  // ------------------------------------------------------
  // TLB RAM Instantiation
  // ------------------------------------------------------

  ca53_generic_ram #(.addr_bits(`CA53_TLB_RAM_ADDR_W), .data_bits(`CA53_TLB_RAM_W), .we_size(`CA53_TLB_RAM_W), .reset(0), .reset_high(0)) u_tlb_bank0
    (
     .clk    (clk),
     .addr_i (tlb_ram_addr_i),
     .rd_o   (tlb_ram_rdata0_o[`CA53_TLB_RAM_W-1:0]),
     .wd_i   (tlb_ram_wdata_i[`CA53_TLB_RAM_W-1:0]),
     .cs_i   (tlb_ram_en_i[0]),
     .we_i   (tlb_ram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(`CA53_TLB_RAM_ADDR_W), .data_bits(`CA53_TLB_RAM_W), .we_size(`CA53_TLB_RAM_W), .reset(0), .reset_high(0)) u_tlb_bank1
    (
     .clk    (clk),
     .addr_i (tlb_ram_addr_i),
     .rd_o   (tlb_ram_rdata1_o[`CA53_TLB_RAM_W-1:0]),
     .wd_i   (tlb_ram_wdata_i[`CA53_TLB_RAM_W-1:0]),
     .cs_i   (tlb_ram_en_i[1]),
     .we_i   (tlb_ram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(`CA53_TLB_RAM_ADDR_W), .data_bits(`CA53_TLB_RAM_W), .we_size(`CA53_TLB_RAM_W), .reset(0), .reset_high(0)) u_tlb_bank2
    (
     .clk    (clk),
     .addr_i (tlb_ram_addr_i),
     .rd_o   (tlb_ram_rdata2_o[`CA53_TLB_RAM_W-1:0]),
     .wd_i   (tlb_ram_wdata_i[`CA53_TLB_RAM_W-1:0]),
     .cs_i   (tlb_ram_en_i[2]),
     .we_i   (tlb_ram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(`CA53_TLB_RAM_ADDR_W), .data_bits(`CA53_TLB_RAM_W), .we_size(`CA53_TLB_RAM_W), .reset(0), .reset_high(0)) u_tlb_bank3
    (
     .clk    (clk),
     .addr_i (tlb_ram_addr_i),
     .rd_o   (tlb_ram_rdata3_o[`CA53_TLB_RAM_W-1:0]),
     .wd_i   (tlb_ram_wdata_i[`CA53_TLB_RAM_W-1:0]),
     .cs_i   (tlb_ram_en_i[3]),
     .we_i   (tlb_ram_wr_i)
     );

  // ------------------------------------------------------
  // BTAC RAM Instantiation
  // ------------------------------------------------------

  ca53_generic_ram #(.addr_bits(`CA53_BTAC_RAM_ADDR_W), .data_bits(`CA53_BTAC_RAM_S0D_W), .we_size(`CA53_BTAC_RAM_S0D_W), .reset(0), .reset_high(0)) u_btac_stg0
    (
     .clk    (clk),
     .addr_i (btac_stg0_ram_addr_i),
     .rd_o   (btac_stg0_ram_rdata_o[(`CA53_BTAC_RAM_S0D_W-1):0]),
     .wd_i   (btac_stg0_ram_wdata_i[(`CA53_BTAC_RAM_S0D_W-1):0]),
     .cs_i   (btac_stg0_ram_en_i),
     .we_i   (btac_stg0_ram_wr_i)
     );

  ca53_generic_ram #(.addr_bits(`CA53_BTAC_RAM_ADDR_W), .data_bits(`CA53_BTAC_RAM_S1D_W), .we_size(`CA53_BTAC_RAM_S1D_W), .reset(0), .reset_high(0)) u_btac_stg1
    (
     .clk    (clk),
     .addr_i (btac_stg1_ram_addr_i),
     .rd_o   (btac_stg1_ram_rdata_o[(`CA53_BTAC_RAM_S1D_W-1):0]),
     .wd_i   (btac_stg1_ram_wdata_i[(`CA53_BTAC_RAM_S1D_W-1):0]),
     .cs_i   (btac_stg1_ram_en_i),
     .we_i   (btac_stg1_ram_wr_i)
     );

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/
