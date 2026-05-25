//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2012  ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-07-30 17:43:20 +0100 (Mon, 30 Jul 2012) $
//
//      Revision            : $Revision: 216978 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//
//  This module implements the following registers:
//
//     DCR      Distributor Control Register
//     ICTR     Interrupt Controller Type Register
//     IIDR     Distributor Implementer Identification Register
//     SGIR     Software Generated Interrupt Register
//     PIDn     Peripheral ID Registers
//     CIDn     Component ID Registers

module gic400_distributor #(parameter NUM_CPUS = 4,
                            parameter NUM_SPIS = 224,
                            parameter _CORTEXA7_INTERNAL = 0)
(
  // Clocks and resets
  input  wire                       clk,
  input  wire                       clk_p,
  input  wire                       clk_pri,
  input  wire                       reset_n,
  input  wire                       load_initial_i,

  output wire                       clk_pri_en_o,

  // Configuration inputs
  input  wire                       cfgsdisable_i,
  output wire                       gic_cfgsdisable_o,

  // IRQs
  input  wire [NUM_CPUS-1:0]        cpu_vinterface_maintenance_i,
  input  wire [NUM_CPUS-1:0]        cpu_tm_cnthp_nirq_i,
  input  wire [NUM_CPUS-1:0]        cpu_tm_cntv_nirq_i,
  input  wire [NUM_CPUS-1:0]        cpu_tm_cntp_ns_nirq_i,
  input  wire [NUM_CPUS-1:0]        cpu_tm_cntp_s_nirq_i,
  input  wire [NUM_CPUS-1:0]        ppi_legacy_nirq_i,
  input  wire [NUM_CPUS-1:0]        ppi_legacy_nfiq_i,
  input  wire [spi_msb(NUM_SPIS):0] irqs_i,

  // Programming interface
  input  wire                       p_write_i,
  input  wire                       p_vcpuif_write_i,
  input  wire [3:0]                 p_rd_op_i,
  input  wire [2:0]                 p_rcpu_i,
  input  wire [3:0]                 p_rd_block_i,
  input  wire [2:0]                 p_rindex_i,
  input  wire                       p_rnsecure_i,
  output wire [31:0]                p_rdata_o,
  input  wire [3:0]                 p_wr_op_i,
  input  wire [2:0]                 p_wcpu_i,
  input  wire [3:0]                 p_wr_block_i,
  input  wire [2:0]                 p_windex_i,
  input  wire                       p_wnsecure_i,
  input  wire [3:0]                 p_strb_i,
  input  wire [31:0]                p_wdata_i,
  output wire                       p_priority_recalc_stall_o,
  output wire                       pri_write_allowed_o,
  output wire                       ns_sgi_write_allowed_o,

  // CPU/VCPU interfaces
  input  wire [NUM_CPUS-1:0]        cpu_interface_ack_i,
  input  wire [NUM_CPUS-1:0]        cpu_deactivate_i,
  input  wire [NUM_CPUS-1:0]        cpu_vdeactivate_i,
  input  wire [8:0]                 vdeactivate_id_i,


  output wire [NUM_CPUS-1:0]        cpu_high_valid_o,
  output wire [NUM_CPUS-1:0]        cpu_high_nsecure_o,
  output wire [5*NUM_CPUS-1:0]      cpu_high_priority_o,
  output wire [9*NUM_CPUS-1:0]      cpu_high_id_o,
  output wire [3*NUM_CPUS-1:0]      cpu_high_cpu_o

);


  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"

  localparam [3:0] DIST_IIDR_REVISION = 4'h1;
  localparam [3:0] PIDR3_REVISION     = 4'h0;

  localparam [7:0] PRODUCT_ID = _CORTEXA7_INTERNAL ? 8'h01 : 8'h02;

  localparam NUM_CPUS_MINUS_ONE = NUM_CPUS - 1;
  localparam NUM_SPIS_DIV_32    = NUM_SPIS / 32;
  localparam NUM_INTS           = NUM_SPIS + 32;


  //----------------------------------------------------------------------------
  // Signal/wire declarations
  //----------------------------------------------------------------------------

  wire [  2:  0] cpu_num;
  wire           enable_ns_en;
  reg            enable_ns_q;
  wire           enable_s_en;
  reg            enable_s_q;
  wire [  4:  0] int_num;
  wire           nxt_enable_ns;
  wire [  7:  0] p_wcpu_onehot;
  wire           p_ctrl_en;
  wire [ 31:  0] p_rdata_block[NUM_SPIS_DIV_32:0];
  reg  [ 31:  0] p_rdata_block_allblock;
  wire [ 31:  0] p_rdata_iidr;
  reg  [ 31:  0] p_rdata_common;
  reg  [  7:  0] p_sgi_wr_targets;
  wire [  7:  0] p_sgi_write;
  wire [ 31:  0] p_strobes_mask;
  wire           p_secure_rd;
  wire           p_enable_set_rd;
  wire           p_enable_clear_rd;
  wire           p_pend_set_rd;
  wire           p_pend_clear_rd;
  wire           p_active_set_rd;
  wire           p_active_clear_rd;
  wire           p_priority_rd;
  wire           p_cpu_rd;
  wire           p_conf_rd;
  wire           p_status_rd;
  wire           p_sgi_pend_clear_rd;
  wire           p_sgi_pend_set_rd;
  wire           p_secure_wr;
  wire           p_enable_set_wr;
  wire           p_enable_clear_wr;
  wire           p_pend_set_wr;
  wire           p_pend_clear_wr;
  wire           p_active_set_wr;
  wire           p_active_clear_wr;
  wire           p_priority_wr;
  wire           p_cpu_wr;
  wire           p_conf_wr;
  wire           p_sgi_pend_clear_wr;
  wire           p_sgi_pend_set_wr;
  wire           p_sgir_wr;
  wire [ 15:  0] p_block_write;
  reg  [  3:  0] gicd_iidr_revid;   // Revision ID (for distributor IIDR register)
  reg  [  3:  0] gicd_pidr3_revid;  // Revision ID (for Peripheral ID PIDR3 register)
  wire [ 31:  0] p_lowid_rdata_cpu[NUM_CPUS-1:0];
  reg  [ 31:  0] p_lowid_rdata_allcpu;
  reg  [  8:  0] ack_id;
  reg  [  2:  0] ack_cpu;
  wire [  8:  0] deactivate_id;
  reg  [  8:  0] deactivate_id_q;
  reg  [  2:  0] ack_cpu_q;
  reg  [  8:  0] ack_id_q;
  wire           int_ack;
  wire           int_deactivate;
  reg            int_ack_q;
  reg            int_deactivate_q;
  reg            deactivate_is_vcpu_q;
  wire [  7:  0] ack_src;
  wire [  7:  0] deactivate_src;
  wire [ 31:  0] ack_onehot_id;
  wire [ 31:  0] deactivate_onehot_id;
  wire [ 15:  0] deactivate_req_blk;
  wire [ 15:  0] ack_req_blk;
  wire [ 15:  0] p_sgi_onehot_id;
  wire           p_common_rd;
  wire           p_common_wr;
  wire           priority_recalc_needed;
  reg  [  2:  0] priority_state_q;
  reg            priority_resample_pending_q;
  wire           nxt_suppress_high_en;
  reg            suppress_high_en_q;
  wire           nxt_priority_resample_pending;
  reg            clk_pri_en_q;
  wire           nxt_clk_pri_en;
  wire [  2:  0] nxt_priority_state;
  wire           p_priority_recalc_needed;
  wire           nxt_p_priority_recalc_in_progress;
  wire           nxt_p_priority_resample_pending;
  reg            p_priority_recalc_in_progress_q;
  reg            p_priority_resample_pending_q;
  reg            gic_cfgsdisable_q;
  wire           priority_state_en;

  wire [spi_msb(NUM_SPIS_DIV_32):  0] spi_cfgsdisable;
  wire [              NUM_INTS-1:  0] irqs_valid         [7:0];
  wire [                      31:  0] lowids_nsecurity   [NUM_CPUS-1:0];
  wire [                  5*32-1:  0] lowid_priorities   [NUM_CPUS-1:0];
  wire [       spi_msb(NUM_SPIS):  0] spis_nsecurity;
  wire [     spi_msb(5*NUM_SPIS):  0] spi_priorities;
  wire [              NUM_CPUS-1:  0] cpu_high_valid;
  wire [              NUM_CPUS-1:  0] cpu_high_valid_pre_enable;
  wire [              NUM_CPUS-1:  0] cpu_high_nsecure;
  wire [            9*NUM_CPUS-1:  0] cpu_high_id;
  wire [            5*NUM_CPUS-1:  0] cpu_high_priority;
  wire [            3*NUM_CPUS-1:  0] cpu_high_cpu;
  wire [              NUM_CPUS-1:  0] lowid_int_deactivate_req;
  wire [              NUM_CPUS-1:  0] lowid_int_ack_req;
  wire [                  3*16-1:  0] sgi_cpus           [NUM_CPUS-1:0];
  wire [              NUM_INTS-1:  0] irqs_nsecurity     [NUM_CPUS-1:0];
  wire [            5*NUM_INTS-1:  0] irq_priorities     [NUM_CPUS-1:0];
  wire [spi_msb(NUM_SPIS_DIV_32):  0] spis_changed;
  wire [              NUM_CPUS-1:  0] lowids_changed;

  genvar spi_blk, lowid_cpu, pri_cpu;

  //----------------------------------------------------------------------------
  // Top level inputs
  //----------------------------------------------------------------------------

  // CFGSDISABLE is a top level input and so needs registering
  always @(posedge clk)
    gic_cfgsdisable_q <= cfgsdisable_i;

  // This signal is also required by the CPU interfaces
  assign gic_cfgsdisable_o = gic_cfgsdisable_q;

  //----------------------------------------------------------------------------
  // Programming Interface Register Decode
  //----------------------------------------------------------------------------

  assign p_secure_rd           = (p_rd_op_i == D_IGROUPR);
  assign p_enable_set_rd       = (p_rd_op_i == D_ISENABLER);
  assign p_enable_clear_rd     = (p_rd_op_i == D_ICENABLER);
  assign p_pend_set_rd         = (p_rd_op_i == D_ISPENDR);
  assign p_pend_clear_rd       = (p_rd_op_i == D_ICPENDR);
  assign p_active_set_rd       = (p_rd_op_i == D_ISACTIVER);
  assign p_active_clear_rd     = (p_rd_op_i == D_ICACTIVER);
  assign p_priority_rd         = (p_rd_op_i == D_IPRIORITYR);
  assign p_cpu_rd              = (p_rd_op_i == D_ITARGETSR);
  assign p_conf_rd             = (p_rd_op_i == D_ICFGR);
  assign p_status_rd           = (p_rd_op_i == D_ISTATUSR);   // RO
  assign p_sgi_pend_clear_rd   = (p_rd_op_i == D_CPENDSGIR);
  assign p_sgi_pend_set_rd     = (p_rd_op_i == D_SPENDSGIR);
  assign p_common_rd           = (p_rd_op_i == D_COMMON);

  assign p_secure_wr           = (p_wr_op_i == D_IGROUPR);
  assign p_enable_set_wr       = (p_wr_op_i == D_ISENABLER);
  assign p_enable_clear_wr     = (p_wr_op_i == D_ICENABLER);
  assign p_pend_set_wr         = (p_wr_op_i == D_ISPENDR);
  assign p_pend_clear_wr       = (p_wr_op_i == D_ICPENDR);
  assign p_active_set_wr       = (p_wr_op_i == D_ISACTIVER);
  assign p_active_clear_wr     = (p_wr_op_i == D_ICACTIVER);
  assign p_priority_wr         = (p_wr_op_i == D_IPRIORITYR);
  assign p_cpu_wr              = (p_wr_op_i == D_ITARGETSR);
  assign p_conf_wr             = (p_wr_op_i == D_ICFGR);
  assign p_sgi_pend_clear_wr   = (p_wr_op_i == D_CPENDSGIR);
  assign p_sgi_pend_set_wr     = (p_wr_op_i == D_SPENDSGIR);
  assign p_sgir_wr             = (p_wr_op_i == D_SGIR);       // WO
  assign p_common_wr           = (p_wr_op_i == D_COMMON);

  // Generate the write enable for each block. The block being written to is
  // indicated by p_wr_block_i.
  assign p_block_write         = (16'h0001 << p_wr_block_i) & {16{p_write_i}};

  assign p_strobes_mask[7:0]   = {8{p_strb_i[0]}};
  assign p_strobes_mask[15:8]  = {8{p_strb_i[1]}};
  assign p_strobes_mask[23:16] = {8{p_strb_i[2]}};
  assign p_strobes_mask[31:24] = {8{p_strb_i[3]}};

  //----------------------------------------------------------------------------
  // Common Distributor Registers
  //----------------------------------------------------------------------------
  // The distributor programmers model has a common control register
  // (GICD_CTLR), which implements the global secure and non-secure enable
  // bits, as well as several Read Only ID registers.
  //
  // The common distributor registers are selected with the opcode D_COMMON,
  // and the specific register is selected by the block select input.

  // CTLR Writes
  assign p_ctrl_en = p_write_i & p_common_wr; // CTLR is only writeable common register and decode is qualified so only set when strobe[0] is set

  assign enable_s_en  = p_ctrl_en & ~p_wnsecure_i & ~gic_cfgsdisable_q; // Secure bit can only be written in secure mode when security enabled
  assign enable_ns_en = p_ctrl_en;
  assign nxt_enable_ns = p_wnsecure_i ? p_wdata_i[0] : p_wdata_i[1];

  always @ (posedge clk_p or negedge reset_n)
    if (!reset_n)
      enable_s_q <= 1'b0;
    else if (enable_s_en)
      enable_s_q <= p_wdata_i[0];

  always @ (posedge clk_p or negedge reset_n)
    if (!reset_n)
      enable_ns_q <= 1'b0;
    else if (enable_ns_en)
      enable_ns_q <= nxt_enable_ns;

  // CTLR, TYPER, IIDR, ICPIDR, ICCIDR Reads

  // - Number of cores and number of supported interrupts fields
  assign int_num[4:0] = NUM_SPIS_DIV_32[4:0];
  assign cpu_num[2:0] = NUM_CPUS_MINUS_ONE[2:0];

  // - Register for revision fields to allow easy modification
  always @(posedge clk)
    if (load_initial_i) begin
      gicd_iidr_revid[3:0]  <= DIST_IIDR_REVISION;
      gicd_pidr3_revid[3:0] <= PIDR3_REVISION;
    end

  assign p_rdata_iidr[31:0] = {PRODUCT_ID[7:0],      // [31:24] = Product ID
                               4'h0,                 // [23:20] = Reserved
                               4'h0,                 // [19:16] = Variant
                               gicd_iidr_revid[3:0], // [15:12] = Revision
                               12'h43b};             // [11:0]  = Implementer

  always @*
    case (p_rd_block_i[3:0])
      4'b0000: p_rdata_common[31:0] = { {30{1'b0}}, {2{~p_rnsecure_i}} & {enable_ns_q, enable_s_q} |    // CTLR
                                                    {2{ p_rnsecure_i}} & {1'b0, enable_ns_q} };
      4'b0001: p_rdata_common[31:0] = { 16'h0000, 5'b11111, 1'b1, 2'b00, cpu_num[2:0], int_num[4:0] };  // TYPER
      4'b0010: p_rdata_common[31:0] = p_rdata_iidr[31:0];                                               // IIDR
      4'b0011: p_rdata_common[31:0] = {32{1'b0}};                                                       // Unused (RAZ)
      4'b0100: p_rdata_common[31:0] = 32'h0000_0004;                                                    // ICPIDR4
      4'b0101: p_rdata_common[31:0] = 32'h0000_0000;                                                    // ICPIDR5
      4'b0110: p_rdata_common[31:0] = 32'h0000_0000;                                                    // ICPIDR6
      4'b0111: p_rdata_common[31:0] = 32'h0000_0000;                                                    // ICPIDR7
      4'b1000: p_rdata_common[31:0] = 32'h0000_0090;                                                    // ICPIDR0
      4'b1001: p_rdata_common[31:0] = 32'h0000_00b4;                                                    // ICPIDR1
      4'b1010: p_rdata_common[31:0] = 32'h0000_002b;                                                    // ICPIDR2
      4'b1011: p_rdata_common[31:0] = { {24{1'b0}}, gicd_pidr3_revid[3:0], 4'h0 };                      // ICPIDR3
      4'b1100: p_rdata_common[31:0] = 32'h0000_000d;                                                    // ICCIDR0
      4'b1101: p_rdata_common[31:0] = 32'h0000_00f0;                                                    // ICCIDR1
      4'b1110: p_rdata_common[31:0] = 32'h0000_0005;                                                    // ICCIDR2
      4'b1111: p_rdata_common[31:0] = 32'h0000_00b1;                                                    // ICCIDR3
      default: p_rdata_common[31:0] = {32{1'bx}};
    endcase

  //----------------------------------------------------------------------------
  // ACK and EOI from interfaces
  //----------------------------------------------------------------------------

  // The CPU and VCPU interface indicate when there has been an
  // Ack/EOI/Deactivate late in the cycle. These inputs are registered and
  // used to update the distributor state on the next cycle.

  assign int_ack        = |cpu_interface_ack_i;
  assign int_deactivate = |(cpu_deactivate_i | cpu_vdeactivate_i);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      int_ack_q        <= 1'b0;
      int_deactivate_q <= 1'b0;
    end else begin
      int_ack_q        <= int_ack;
      int_deactivate_q <= int_deactivate;
    end

  // Activate ID and CPU are the pending values from the priority logic on
  // the interface whose IAR is being read.
  always @* begin : g_ack
    integer cpu;
    reg[8:0] ack_id_tmp;
    reg[2:0] ack_cpu_tmp;

    ack_id_tmp[8:0]   = 9'b000000000;
    ack_cpu_tmp[2:0]  = 3'b000;

    for (cpu=0; cpu<NUM_CPUS; cpu=cpu+1) begin
      ack_id_tmp  = ack_id_tmp  | ({9{cpu[2:0] == p_rcpu_i[2:0]}} & cpu_high_id[9*cpu +: 9]);
      ack_cpu_tmp = ack_cpu_tmp | ({3{cpu[2:0] == p_rcpu_i[2:0]}} & cpu_high_cpu[3*cpu +: 3]);
    end

    ack_id  = ack_id_tmp;
    ack_cpu = ack_cpu_tmp;
  end

  always @(posedge clk_p)
    if (int_ack) begin
      ack_id_q  <= ack_id;
      ack_cpu_q <= ack_cpu;
    end

  // The Deactivate ID comes from the write data on a CPU interface
  // deactivate, and from the list registers in the VCPU interface on VCPU
  // deactivate.
  assign deactivate_id = p_vcpuif_write_i ? vdeactivate_id_i : p_wdata_i[8:0];

  always @(posedge clk_p)
    if (int_deactivate) begin
      deactivate_id_q       <= deactivate_id;
      deactivate_is_vcpu_q  <= p_vcpuif_write_i;
    end

  // Select the IRQ block to send the Ack/Deactivate to based on the ID, and
  // indicate which IRQ within each block the ID maps to.

  // - Upper bits determine which int block. Bottom bits are sub-block ID.
  assign deactivate_req_blk[15:0] = (16'h0001 << deactivate_id_q[8:5]) & {16{int_deactivate_q}};
  assign ack_req_blk[15:0]        = (16'h0001 << ack_id_q[8:5])        & {16{int_ack_q}};

  // - Lower 5-bits determine which 32 id within an int block
  assign deactivate_onehot_id = 32'h00000001 << deactivate_id_q[4:0];
  assign ack_onehot_id        = 32'h00000001 << ack_id_q[4:0];

  // The source CPU for an Ack/Deactivate will be the currently indicate read
  // or write CPU respectively, because although the read/write which caused
  // the Ack/Deactivate happened on the previous cycle, transactions cannot
  // be issued on the programming interface back to back, so the value will
  // still be valid.
  assign ack_src[7:0]         = 8'b00000001 << p_rcpu_i[2:0];
  assign deactivate_src[7:0]  = 8'b00000001 << p_wcpu_i[2:0];


  //----------------------------------------------------------------------------
  // Interrupt IDs 0 to 31
  //
  //   Handles SGI requests (IDs 0-15) and PPIs (IDs 16-31) for each processor
  //   interface.
  //----------------------------------------------------------------------------

  // Software Generated Interupt target list computation
  //   0b00: Send to CPUs in CPUTargetList field (bits 23:16 of write data)
  //   0b01: Send to all CPU interfaces except the requesting CPU
  //   0b10: Send only to the requesting CPU interface
  //   0b11: Reserved
  //
  // Selected targets based on TargetListFilter (bits 23:24) and
  // CPUTargetList (bits 23:16) of Software Generated Interrupt Register

  assign p_wcpu_onehot[7:0] = 8'h01 << p_wcpu_i;  // One-hot ID for requesting CPU

  always @ (*)
    case (p_wdata_i[25:24])
      2'b00:   p_sgi_wr_targets[7:0] =  p_wdata_i[23:16];
      2'b01:   p_sgi_wr_targets[7:0] = ~p_wcpu_onehot[7:0];
      2'b10:   p_sgi_wr_targets[7:0] =  p_wcpu_onehot[7:0];
      2'b11:   p_sgi_wr_targets[7:0] =  8'h00;
      default: p_sgi_wr_targets[7:0] = {8{1'bx}};
    endcase

  // Targets masked with valid write to SGI Register
  assign p_sgi_write[7:0] = p_sgi_wr_targets[7:0] & {8{p_write_i & p_sgir_wr}};
  assign p_sgi_onehot_id  = 16'h0001 << p_wdata_i[3:0];

  // The Low ID IRQs are banked per-CPU, so NUM_CPUS instances of the lowids
  // block are required.
  generate for (lowid_cpu=0; lowid_cpu<NUM_CPUS; lowid_cpu=lowid_cpu+1) begin : g_lowids

    // An Ack/Deactivate is only passed to a lowids block if the block and
    // the source CPU match.
    assign lowid_int_deactivate_req[lowid_cpu] = deactivate_req_blk[0] & deactivate_src[lowid_cpu];
    assign lowid_int_ack_req[lowid_cpu]        = ack_req_blk[0]        & ack_src[lowid_cpu];

    gic400_cpu_lowids #(.NUM_CPUS(NUM_CPUS), .CPU_ID(lowid_cpu)) u_lowid
      (
        .clk                          (clk),
        .clk_p                        (clk_p),
        .reset_n                      (reset_n),

        // Enables
        .enable_s_i                   (enable_s_q),
        .enable_ns_i                  (enable_ns_q),

        // IRQs
        .vinterface_maintenance_i     (cpu_vinterface_maintenance_i[lowid_cpu]),
        .tm_cnthp_nirq_i              (cpu_tm_cnthp_nirq_i[lowid_cpu]),
        .tm_cntv_nirq_i               (cpu_tm_cntv_nirq_i[lowid_cpu]),
        .tm_cntp_ns_nirq_i            (cpu_tm_cntp_ns_nirq_i[lowid_cpu]),
        .tm_cntp_s_nirq_i             (cpu_tm_cntp_s_nirq_i[lowid_cpu]),
        .legacy_nirq_i                (ppi_legacy_nirq_i[lowid_cpu]),
        .legacy_nfiq_i                (ppi_legacy_nfiq_i[lowid_cpu]),

        .lowids_changed_o             (lowids_changed[lowid_cpu]),

        // Programming Interface
        .p_blk_write_i                (p_block_write[0]),
        .p_write_i                    (p_write_i),
        .p_rnsecure_i                 (p_rnsecure_i),
        .p_wnsecure_i                 (p_wnsecure_i),
        .p_rindex_i                   (p_rindex_i[2:0]),
        .p_windex_i                   (p_windex_i[2:0]),
        .p_wcpu_i                     (p_wcpu_i[2:0]),
        .p_rdata_o                    (p_lowid_rdata_cpu[lowid_cpu]),
        .p_wdata_i                    (p_wdata_i[31:0]),
        .p_strb_i                     (p_strb_i[3:0]),
        .p_secure_rd_i                (p_secure_rd),
        .p_secure_wr_i                (p_secure_wr),
        .p_enable_set_rd_i            (p_enable_set_rd),
        .p_enable_set_wr_i            (p_enable_set_wr),
        .p_enable_clear_rd_i          (p_enable_clear_rd),
        .p_enable_clear_wr_i          (p_enable_clear_wr),
        .p_pend_set_rd_i              (p_pend_set_rd),
        .p_pend_set_wr_i              (p_pend_set_wr),
        .p_pend_clear_rd_i            (p_pend_clear_rd),
        .p_pend_clear_wr_i            (p_pend_clear_wr),
        .p_active_set_rd_i            (p_active_set_rd),
        .p_active_set_wr_i            (p_active_set_wr),
        .p_active_clear_rd_i          (p_active_clear_rd),
        .p_active_clear_wr_i          (p_active_clear_wr),
        .p_priority_rd_i              (p_priority_rd),
        .p_priority_wr_i              (p_priority_wr),
        .p_cpu_rd_i                   (p_cpu_rd),
        .p_conf_rd_i                  (p_conf_rd),
        .p_status_rd_i                (p_status_rd),
        .p_sgi_pend_set_rd_i          (p_sgi_pend_set_rd),
        .p_sgi_pend_set_wr_i          (p_sgi_pend_set_wr),
        .p_sgi_pend_clear_rd_i        (p_sgi_pend_clear_rd),
        .p_sgi_pend_clear_wr_i        (p_sgi_pend_clear_wr),
        .p_sgi_write_i                (p_sgi_write[lowid_cpu]),
        .p_sgi_onehot_id_i            (p_sgi_onehot_id[15:0]),

        // Ack/Deactivate
        .int_deactivate_req_i         (lowid_int_deactivate_req[lowid_cpu]),
        .int_ack_req_i                (lowid_int_ack_req[lowid_cpu]),
        .int_ack_cpu_i                (ack_cpu_q),
        .ack_sgi_onehot_id_i          (ack_onehot_id[15:0]),
        .ack_ppi_onehot_id_i          (ack_onehot_id[31:25]),
        .int_deactivate_is_vcpu_i     (deactivate_is_vcpu_q),
        .deactivate_sgi_onehot_id_i   (deactivate_onehot_id[15:0]),
        .deactivate_ppi_onehot_id_i   (deactivate_onehot_id[31:25]),

        // Ouptuts to Priority Logic
        .irqs_valid_o                 (irqs_valid[lowid_cpu][31:0]),
        .sgi_cpus_o                   (sgi_cpus[lowid_cpu][3*16-1:0]),
        .lowids_nsecurity_o           (lowids_nsecurity[lowid_cpu][31:0]),
        .lowid_priorities_o           (lowid_priorities[lowid_cpu][5*32-1:0])
      );

  end endgenerate

  // OR together rdata from each CPU to form complete rdata for all lowid
  // blocks.
  always @* begin : g_p_lowid_rdata_allcpu
    integer n;
    reg[31:0] p_lowid_rdata_allcpu_tmp;
    p_lowid_rdata_allcpu_tmp = 32'h00000000;

    for (n=0; n<NUM_CPUS; n=n+1)
      p_lowid_rdata_allcpu_tmp = p_lowid_rdata_allcpu_tmp | ({32{p_rcpu_i[2:0] == n[2:0]}} & p_lowid_rdata_cpu[n]);

    p_lowid_rdata_allcpu = p_lowid_rdata_allcpu_tmp;
  end

  assign p_rdata_block[0][31:0] = p_lowid_rdata_allcpu[31:0];

  //----------------------------------------------------------------------------
  // SPIs
  //
  //  IRQ IDs > 31 are SPIs. These are implemented in blocks of 32 interrupts.
  //----------------------------------------------------------------------------

  generate for (spi_blk=0; spi_blk<NUM_SPIS_DIV_32; spi_blk=spi_blk+1) begin : g_spis

    // CFGSDISABLE only applies to the first block of SPIs
    assign spi_cfgsdisable[spi_blk] = gic_cfgsdisable_q & (spi_blk == 0);

    gic400_spi_block #(.NUM_CPUS(NUM_CPUS)) u_spi
      (
        .clk                      (clk),
        .clk_p                    (clk_p),
        .reset_n                  (reset_n),

        // Enables
        .spi_cfgsdisable_i        (spi_cfgsdisable[spi_blk]),
        .enable_s_i               (enable_s_q),
        .enable_ns_i              (enable_ns_q),

        // IRQs
        .irqs_i                   (irqs_i[(spi_blk*32) +: 32]),
        .spis_changed_o           (spis_changed[spi_blk]),

        // Programming Interface
        .p_blk_write_i            (p_block_write[spi_blk+1]),
        .p_rnsecure_i             (p_rnsecure_i),
        .p_wnsecure_i             (p_wnsecure_i),
        .p_rindex_i               (p_rindex_i[2:0]),
        .p_windex_i               (p_windex_i[2:0]),
        .p_rdata_o                (p_rdata_block[spi_blk+1][31:0]),
        .p_wdata_i                (p_wdata_i[31:0]),
        .p_strobes_mask_i         (p_strobes_mask[31:0]),
        .p_strb_i                 (p_strb_i[3:0]),
        .p_secure_rd_i            (p_secure_rd),
        .p_secure_wr_i            (p_secure_wr),
        .p_enable_set_rd_i        (p_enable_set_rd),
        .p_enable_set_wr_i        (p_enable_set_wr),
        .p_enable_clear_rd_i      (p_enable_clear_rd),
        .p_enable_clear_wr_i      (p_enable_clear_wr),
        .p_pend_set_rd_i          (p_pend_set_rd),
        .p_pend_set_wr_i          (p_pend_set_wr),
        .p_pend_clear_rd_i        (p_pend_clear_rd),
        .p_pend_clear_wr_i        (p_pend_clear_wr),
        .p_active_set_rd_i        (p_active_set_rd),
        .p_active_set_wr_i        (p_active_set_wr),
        .p_active_clear_rd_i      (p_active_clear_rd),
        .p_active_clear_wr_i      (p_active_clear_wr),
        .p_priority_rd_i          (p_priority_rd),
        .p_priority_wr_i          (p_priority_wr),
        .p_cpu_rd_i               (p_cpu_rd),
        .p_cpu_wr_i               (p_cpu_wr),
        .p_conf_rd_i              (p_conf_rd),
        .p_conf_wr_i              (p_conf_wr),
        .p_status_rd_i            (p_status_rd),

        // Ack/Deactivate
        .int_ack_i                (ack_req_blk[spi_blk+1]),
        .int_deactivate_i         (deactivate_req_blk[spi_blk+1]),
        .ack_onehot_id_i          (ack_onehot_id[31:0]),
        .int_deactivate_is_vcpu_i (deactivate_is_vcpu_q),
        .deactivate_onehot_id_i   (deactivate_onehot_id[31:0]),

        // Outputs to Priority Logic
        .cpu0_irqs_valid_o        (irqs_valid[0][((spi_blk+1)*32) +: 32]),
        .cpu1_irqs_valid_o        (irqs_valid[1][((spi_blk+1)*32) +: 32]),
        .cpu2_irqs_valid_o        (irqs_valid[2][((spi_blk+1)*32) +: 32]),
        .cpu3_irqs_valid_o        (irqs_valid[3][((spi_blk+1)*32) +: 32]),
        .cpu4_irqs_valid_o        (irqs_valid[4][((spi_blk+1)*32) +: 32]),
        .cpu5_irqs_valid_o        (irqs_valid[5][((spi_blk+1)*32) +: 32]),
        .cpu6_irqs_valid_o        (irqs_valid[6][((spi_blk+1)*32) +: 32]),
        .cpu7_irqs_valid_o        (irqs_valid[7][((spi_blk+1)*32) +: 32]),
        .spis_nsecurity_o         (spis_nsecurity[(spi_blk*32) +: 32]),
        .spi_priorities_o         (spi_priorities[(spi_blk*5*32) +: (5*32)])
      );

  end endgenerate


  //----------------------------------------------------------------------------
  // Distributor Read Data
  //----------------------------------------------------------------------------

  // Select the read data from the block being read
  always @*
    begin : g_p_rdata_block_allblock
      integer n;
      reg[31:0] p_rdata_block_allblock_tmp;
      p_rdata_block_allblock_tmp = 32'd0;

      for (n=0; n<=NUM_SPIS_DIV_32; n=n+1)
        p_rdata_block_allblock_tmp = p_rdata_block_allblock_tmp | ({32{p_rd_block_i[3:0] == n[3:0]}} & p_rdata_block[n]);

      p_rdata_block_allblock = p_rdata_block_allblock_tmp;
    end

  // The distributor read data will either come from one of the blocks, or
  // from the common registers.
  assign p_rdata_o[31:0] = ({32{p_common_rd}} & p_rdata_common[31:0]) |
                                                p_rdata_block_allblock[31:0];  // Zero when op is COMMON


  //----------------------------------------------------------------------------
  // Priority Calculation
  //----------------------------------------------------------------------------

  // The priority calculation is performed separately for all CPUs. The
  // separate priority state machines all operate in lock step, and the state
  // is tracked here to generate the stall signals for the AXI interface and
  // the clock enable for the priority blocks, without adding fan out on the
  // critical priority state machines themselves.
  //
  // The priority blocks are only enabled when there may have been a change
  // to the inputs to the priority blocks and so the highest pending
  // interrupt needs to be recalculated. The enable applies to all blocks, so
  // a change in any interrupt causes all priority blocks to recalculated,
  // even if the change doesn't affect a particular priority block.

  // Note that priority_recalc_needed indicates that irqs_valid might change
  // on the next cycle.
  generate if (NUM_SPIS > 0) begin : g_priority_recalc_needed_spis

    assign priority_recalc_needed = (|lowids_changed) | // There has been a change in the external IRQ inputs
                                    (|spis_changed)   |
                                    int_ack_q         | // There has been an Ack (which can affect IRQs valid)
                                    int_deactivate_q  | // There has been an EOI/Deactivate (which can affect IRQs valid)
                                    p_write_i;          // A distributor register has been written (covers pending write, SGI, etc)

  end else begin : g_priority_recalc_needed_no_spis

    assign priority_recalc_needed = (|lowids_changed) | // There has been a change in the external IRQ inputs
                                    int_ack_q         | // There has been an Ack (which can affect IRQs valid)
                                    int_deactivate_q  | // There has been an EOI/Deactivate (which can affect IRQs valid)
                                    p_write_i;          // A distributor register has been written (covers pending write, SGI, etc)

  end endgenerate


  // Priority recalculation has two phases. First, the current iteration must
  // complete (if the priority logic is already active), so the priority logic
  // resamples the new input state, then another full iteration must complete
  // to recalculate the output based on the new state.
  //
  // - Track when waiting for current iteration to complete so can resample
  // inputs.
  assign nxt_priority_resample_pending = priority_recalc_needed |         // Set when change to priority inputs
                                         (priority_resample_pending_q &   // Maintain until inputs resampled
                                          (priority_state_q != 3'b000));  // Which happens in state 0

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      priority_resample_pending_q <= 1'b0;
    else
      priority_resample_pending_q <= nxt_priority_resample_pending;

  // - The priority state machine is restarted on an Ack, to reduce the
  // latency for the recalculated result to become available.
  // - On the last cycle of a recalculation, the state machine will be in
  // state 0. The priority logic must be clocked in this cycle, to enable
  // the output registers to capture the new value. The state machine is
  // disabled on this cycle however, so it will remain in state 0 ready
  // for the next recalculation.
  assign priority_state_en = nxt_clk_pri_en;

  assign nxt_priority_state = int_ack_q ? 3'b000 : (priority_state_q - 3'b001);

  always @(posedge clk_pri or negedge reset_n)
    if (!reset_n)
      priority_state_q <= 3'b000;
    else if (priority_state_en)
      priority_state_q <= nxt_priority_state;

  // The outputs from the priority logic to the CPU interfaces are
  // normally updated when the state machine is in state 0. However, on the
  // first cycle the logic is enabled after being idle, or after the state
  // machine is restarted because of an Ack, there will not have been a full
  // iteration, so the outputs should not be updated.
  assign nxt_suppress_high_en = ~clk_pri_en_q | int_ack_q;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      suppress_high_en_q <= 1'b1;
    else
      suppress_high_en_q <= nxt_suppress_high_en;

  // The priority clock is enabled once priority_recalc_needed has been
  // asserted, and remains enabled until the inputs have been resampled and
  // the new result driven to the CPU interfaces.
  assign nxt_clk_pri_en = priority_recalc_needed |
                          priority_resample_pending_q |
                          (clk_pri_en_q & ~((priority_state_q == 3'b000) & ~suppress_high_en_q));

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      clk_pri_en_q <= 1'b0;
    else
      clk_pri_en_q <= nxt_clk_pri_en;

  assign clk_pri_en_o = clk_pri_en_q;

  // When the priority needs to be recalculated because of a programming
  // interface access, subsequent accesses which could expose the result
  // of the calculation need to stall until it is available.

  assign p_priority_recalc_needed = p_write_i | int_ack_q | int_deactivate_q;  // Writes, Acks and EOIs result in recalculation

  // Note that the stall is used in the AXI interface to stall new requests
  // in P0, so the signal can be removed one cycle before the recalculated
  // result is available. Therefore the next priority state is used.

  assign nxt_p_priority_resample_pending = p_priority_recalc_needed |
                                           (p_priority_resample_pending_q &
                                            (priority_state_q != 3'b000));

  assign nxt_p_priority_recalc_in_progress = p_priority_recalc_needed |
                                             (p_priority_recalc_in_progress_q & // Clear when resampled and recalculated
                                              (p_priority_resample_pending_q |
                                               (nxt_priority_state != 3'b000)));

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      p_priority_recalc_in_progress_q <= 1'b0;
      p_priority_resample_pending_q   <= 1'b0;
    end else begin
      p_priority_recalc_in_progress_q <= nxt_p_priority_recalc_in_progress;
      p_priority_resample_pending_q   <= nxt_p_priority_resample_pending;
    end

  // Indicate to the AXI interface when recalculation in progress, so it can
  // stall appropriately.
  assign p_priority_recalc_stall_o = p_priority_recalc_in_progress_q | p_priority_recalc_needed;

  // The priority logic relies on certain distributor registers not changing
  // at certain points during an iteration. This is ensured by indicating to
  // the AXI interface when it should stall writes to these registers. The
  // stall is applied in P0, so the signal is asserted when the state machine
  // will not be in the correct window on the next cycle.

  // - Writes to the interrupt priority registers are only permitted when the
  // state machine is in states 3-1, or when the priority logic is disabled
  // and will remain disabled on the next cycle.
  assign pri_write_allowed_o = (((priority_state_q == 3'b100) |
                                 (priority_state_q == 3'b011) |
                                 (priority_state_q == 3'b010)) & ~int_ack_q) |
                               ~(clk_pri_en_q | priority_recalc_needed);

  // - Writes to the security and SGI registers are permitted when the state
  // machine is in state 1, or when the priority logic is disabled.
  assign ns_sgi_write_allowed_o = ((priority_state_q == 3'b010) & ~int_ack_q) |
                                  ~(clk_pri_en_q | priority_recalc_needed);

  // Instantiate the priority blocks, one per CPU interface.

  generate for (pri_cpu=0; pri_cpu<NUM_CPUS; pri_cpu=pri_cpu+1) begin : g_priorities

    // When SPIs are present, the upper nsecurity and priority information
    // for each CPU comes from the SPI block(s) and is common for all CPUs.
    // When no SPIs are present, only the SGI/PPI information is used.
    if (NUM_SPIS > 0) begin : g_priorities_with_spis
      assign irqs_nsecurity[pri_cpu][NUM_INTS-1:0]   = {spis_nsecurity[NUM_SPIS-1:0], lowids_nsecurity[pri_cpu][31:0]};
      assign irq_priorities[pri_cpu][5*NUM_INTS-1:0] = {spi_priorities[5*NUM_SPIS-1:0], lowid_priorities[pri_cpu][5*32-1:0]};
    end else begin : g_priorities_no_spis
      assign irqs_nsecurity[pri_cpu][NUM_INTS-1:0]   = lowids_nsecurity[pri_cpu][31:0];
      assign irq_priorities[pri_cpu][5*NUM_INTS-1:0] = lowid_priorities[pri_cpu][5*32-1:0];
    end


    gic400_priority #(.NUM_INTS(NUM_INTS), .NUM_CPUS(NUM_CPUS)) u_priority
      (
        .clk                  (clk),
        .clk_pri              (clk_pri),
        .reset_n              (reset_n),

        .irqs_valid_i         (irqs_valid[pri_cpu][NUM_INTS-1:0]),
        .irqs_nsecurity_i     (irqs_nsecurity[pri_cpu][NUM_INTS-1:0]),
        .irq_priorities_i     (irq_priorities[pri_cpu][5*NUM_INTS-1:0]),
        .sgi_cpus_i           (sgi_cpus[pri_cpu][3*16-1:0]),

        .int_ack_i            (int_ack_q),
        .priority_state_en_i  (priority_state_en),
        .suppress_high_en_i   (suppress_high_en_q),

        .high_valid_o         (cpu_high_valid_pre_enable[pri_cpu]),
        .high_priority_o      (cpu_high_priority[5*pri_cpu +: 5]),
        .high_id_o            (cpu_high_id[9*pri_cpu +: 9]),
        .high_nsecure_o       (cpu_high_nsecure[pri_cpu]),
        .high_cpu_o           (cpu_high_cpu[3*pri_cpu +: 3])
      );

  end endgenerate

  // Qualify each valid interrupt signal with relevant the Distributor enable.
  // This is done after the HPPI has been calculated, as per the GICv2 Arch Spec
  assign cpu_high_valid = cpu_high_valid_pre_enable &
                          ( cpu_high_nsecure & {NUM_CPUS{enable_ns_q}} |
                           ~cpu_high_nsecure & {NUM_CPUS{enable_s_q}} );

  // Outputs to CPU interfaces. Note that when more than one CPU is present,
  // vector outputs (ID, priority, etc) are packed into a 1D output, with the
  // data for CPU0 in the lowest bits, followed by CPU1, etc.

  assign cpu_high_valid_o    = cpu_high_valid[NUM_CPUS-1:0];
  assign cpu_high_nsecure_o  = cpu_high_nsecure[NUM_CPUS-1:0];
  assign cpu_high_priority_o = cpu_high_priority[5*NUM_CPUS-1:0];
  assign cpu_high_id_o       = cpu_high_id[9*NUM_CPUS-1:0];
  assign cpu_high_cpu_o      = cpu_high_cpu[3*NUM_CPUS-1:0];


  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // The Ack/EOI/Deactivate logic relies on programming interface inputs not
  // changing on the cycle after an Ack/EOI/Deactivate from a CPU/VCPU
  // interface.
  assert_unchange #(`OVL_FATAL,1,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT, "p_wnsecure changed after an EOI/Deactivate")
  ovl_wnsecure_unchange  (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (int_deactivate),
                          .test_expr        (p_wnsecure_i));

  assert_unchange #(`OVL_FATAL,3,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT, "p_wcpu changed after an EOI/Deactivate")
  ovl_wcpu_unchange      (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (int_deactivate),
                          .test_expr        (p_wcpu_i[2:0]));

  assert_unchange #(`OVL_FATAL,3,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT, "p_rcpu changed after an Ack")
  ovl_rcpu_unchange      (.clk              (clk),
                          .reset_n          (reset_n),
                          .start_event      (int_ack),
                          .test_expr        (p_rcpu_i[2:0]));

  // The priority state machines in each priority block operate in lock-step.
  wire [7:0] priority_blk_state [NUM_CPUS-1:0];
  reg [7:0] priority_state_allblk;
  genvar pri_ovl_cpu;

  generate for (pri_ovl_cpu=0; pri_ovl_cpu<NUM_CPUS; pri_ovl_cpu=pri_ovl_cpu+1) begin : g_priority_blk_state
    assign priority_blk_state[pri_ovl_cpu][7:0] = g_priorities[pri_ovl_cpu].u_priority.priority_state_q[7:0];
  end endgenerate

  always @* begin : g_priority_state_allblk
    integer i;
    reg [7:0] priority_state_allblk_tmp;

    priority_state_allblk_tmp = 8'b00000000;
    for (i=0; i<NUM_CPUS; i=i+1) begin : g_priority_state_allblk_loop
      priority_state_allblk_tmp[7:0] = priority_state_allblk_tmp[7:0] | priority_blk_state[i][7:0];
    end
    
    priority_state_allblk = priority_state_allblk_tmp;
  end
    
  assert_one_hot #(`OVL_FATAL,8,`OVL_ASSERT,"Priority state machines operate in lock step")
  ovl_priority_state_match   (.clk       (clk),
                              .reset_n   (reset_n),
                              .test_expr (priority_state_allblk));

  // The priority state machine follower should always match the state of the
  // individual priority blocks.
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"Distributor priority state does not match priority state of a block")
  ovl_dist_pri_state   (.clk       (clk),
                        .reset_n   (reset_n),
                        .test_expr ((8'b00000001 << priority_state_q[2:0]) == priority_state_allblk[7:0]));

  // The priority state machine should always be in state 0 when clk_pri is
  // disabled.
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Priority state machine not in state 0 when clk_pri disabled")
  ovl_clk_pri_state_0    (.clk              (clk),
                          .reset_n          (reset_n),
                          .antecedent_expr  (~clk_pri_en_q),
                          .consequent_expr  (priority_state_q[2:0] == 3'b000));


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_ns_en")
  u_ovl_x_enable_ns_en (.clk       (clk_p),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (enable_ns_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: enable_s_en")
  u_ovl_x_enable_s_en (.clk       (clk_p),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (enable_s_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: int_ack")
  u_ovl_x_int_ack (.clk       (clk_p),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (int_ack));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: int_deactivate")
  u_ovl_x_int_deactivate (.clk       (clk_p),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (int_deactivate));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: load_initial_i")
  u_ovl_x_load_initial_i (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (load_initial_i));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_state_en")
  u_ovl_x_priority_state_en (.clk       (clk_pri),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (priority_state_en));


`endif

endmodule

