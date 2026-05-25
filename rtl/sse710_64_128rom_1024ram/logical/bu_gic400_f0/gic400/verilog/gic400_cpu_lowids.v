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
//      Checked In          : $Date: 2011-12-02 13:39:59 +0000 (Fri, 02 Dec 2011) $
//
//      Revision            : $Revision: 193746 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//
//  This module implements the following registers:
//
//     ISRn         Interrupt Security Registers
//     ISERn        Interrupt Set-Enable Registers
//     ICERn        Interrupt Clear-Enable Registers
//     ISPRn        Interrupt Set-Pending Registers
//     ICPRn        Interrupt Clear-Pending Registers
//     ISACTIVERn   Interrupt Set-Active Registers
//     ICACTIVERn   Interrupt Clear-Active Registers
//     IPRn         Interrupt Priority Registers
//     IPTRn        Interrupt Processor Targets Registers
//     ICFRn        Interrupt Configuration Reigsters
//     PPISR        PPI Status Register
//     CPENDSGIRn   SGI Clear-Pending Registers
//     SPENDSGIRn   SGI Set-Pending Registers
//
// This block does the following operations:
//   - main distributor logic for interrupt IDs < 32
//   - calculates highest priority pending interupt
//
//-----------------------------------------------------------------------------

module gic400_cpu_lowids #(parameter NUM_CPUS = 4,
                           parameter CPU_ID = 0)
(
  // Clocks and resets
  input  wire             clk,
  input  wire             clk_p,
  input  wire             reset_n,

  // Configuration
  input  wire             enable_s_i,
  input  wire             enable_ns_i,

  // PPIs
  input  wire             vinterface_maintenance_i,
  input  wire             tm_cnthp_nirq_i,
  input  wire             tm_cntv_nirq_i,
  input  wire             tm_cntp_ns_nirq_i,
  input  wire             tm_cntp_s_nirq_i,
  input  wire             legacy_nirq_i,
  input  wire             legacy_nfiq_i,

  output wire             lowids_changed_o,

  // Programming Interface
  input  wire             p_write_i,      // Write of any distributor register
  input  wire             p_blk_write_i,  // Write of distributor register which maps to IRQs 0-31
  input  wire             p_rnsecure_i,
  input  wire             p_wnsecure_i,
  input  wire [2:0]       p_rindex_i,
  input  wire [2:0]       p_windex_i,
  input  wire [2:0]       p_wcpu_i,
  output wire [31:0]      p_rdata_o,
  input  wire [31:0]      p_wdata_i,
  input  wire [3:0]       p_strb_i,

  // - Request Type
  input  wire             p_secure_rd_i,
  input  wire             p_secure_wr_i,
  input  wire             p_enable_set_rd_i,
  input  wire             p_enable_set_wr_i,
  input  wire             p_enable_clear_rd_i,
  input  wire             p_enable_clear_wr_i,
  input  wire             p_pend_set_rd_i,
  input  wire             p_pend_set_wr_i,
  input  wire             p_pend_clear_rd_i,
  input  wire             p_pend_clear_wr_i,
  input  wire             p_active_set_rd_i,
  input  wire             p_active_set_wr_i,
  input  wire             p_active_clear_rd_i,
  input  wire             p_active_clear_wr_i,
  input  wire             p_priority_rd_i,
  input  wire             p_priority_wr_i,
  input  wire             p_cpu_rd_i,
  input  wire             p_conf_rd_i,
  input  wire             p_status_rd_i,
  input  wire             p_sgi_pend_set_wr_i,
  input  wire             p_sgi_pend_set_rd_i,
  input  wire             p_sgi_pend_clear_wr_i,
  input  wire             p_sgi_pend_clear_rd_i,
  input  wire             p_sgi_write_i,     // NB - write instead of wr as fully qualified externally
  input  wire [15:0]      p_sgi_onehot_id_i,

  // CPU/VCPU interface
  input  wire             int_deactivate_req_i,
  input  wire             int_deactivate_is_vcpu_i,
  input  wire             int_ack_req_i,
  input  wire [15:0]      ack_sgi_onehot_id_i,
  input  wire [15:0]      deactivate_sgi_onehot_id_i,
  input  wire [6:0]       ack_ppi_onehot_id_i,
  input  wire [6:0]       deactivate_ppi_onehot_id_i,
  input  wire [2:0]       int_ack_cpu_i,

  output wire [31:0]      irqs_valid_o,
  output wire [3*16-1:0]  sgi_cpus_o,
  output wire [31:0]      lowids_nsecurity_o,
  output wire [5*32-1:0]  lowid_priorities_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  localparam          CPU_ID_ONEHOT = 1 << CPU_ID;


  //----------------------------------------------------------------------------
  // Signal/wire declarations
  //----------------------------------------------------------------------------

  wire [  6:  0] ack_ppi;
  wire [ 15:  0] ack_sgi;
  wire [ 31:  0] allow_wr_access;
  wire [ 31:  0] allow_rd_access;
  wire [  6:  0] eoi_ppi;
  wire [ 15:  0] eoi_sgi;
  wire [  6:  0] ppi_active_clear;
  wire [  6:  0] ppi_active_set;
  wire           ppi_active_status_en;
  reg  [  6:  0] ppi_active_status_q;
  wire [  6:  0] ppi_can_be_set_pending;
  wire           ppi_eoi_nsecure;
  wire           ppi_eoi_taken;
  wire           ppi_irq_enable_en;
  reg  [  6:  0] ppi_irq_enable_q;
  wire           ppi_irq_nsecurity_en;
  reg  [  6:  0] ppi_irq_nsecurity_q;
  wire [  6:  0] ppi_pend_clear;
  wire [  6:  0] ppi_pend_set;
  wire [  6:  0] ppi_pending_status;
  wire           ppi_pending_status_en;
  reg  [  6:  0] ppi_pending_status_q;
  wire [  6:  0] ppi_valid;
  wire [  6:  0] nxt_ppi_active_status;
  wire [  6:  0] nxt_ppi_irq_enable;
  wire [  6:  0] nxt_ppi_pending_status;
  wire           p_active_rd;
  wire           p_active_wr;
  wire           p_enable_rd;
  wire           p_enable_wr;
  wire           p_pend_rd;
  wire           p_pend_wr;
  wire [ 31:  0] p_rdata_active_status;
  reg  [ 31:  0] p_rdata_conf;
  wire [ 31:  0] p_rdata_cpu_target;
  reg  [ 31:  0] p_rdata_cpu_target_mask;
  wire [ 31:  0] p_rdata_cpu_target_tmp;
  wire [ 31:  0] p_rdata_enable;
  wire [ 31:  0] p_rdata_nsecurity;
  wire [ 31:  0] p_rdata_pend_status;
  wire [ 31:  0] p_rdata_priority;
  wire [ 31:  0] p_rdata_priority_ns;
  reg  [ 31:  0] p_rdata_priority_s;
  reg  [ 31:  0] p_rdata_sgi_pend_status;
  wire [ 31:  0] p_rdata_status;
  wire           p_sgi_pend_rd;
  wire           p_sgi_pend_wr;
  wire           p_sgi_req_valid;
  wire [ 31:  0] p_wdata_priority;
  wire [ 31:  0] p_wdata_priority_ns;
  wire           p_write_mycpu;
  wire           p_write_sgi_mycpu;
  wire           core_sgi_active_status_en;
  reg  [ 15:  0] core_sgi_pending_status_allcpu;  // Elements of the array OR'd together
  reg  [ 15:  0] core_sgi_active_status_q;
  wire [ 15:  0] nxt_core_sgi_active_status;
  reg  [ 15:  0] sgi_valid;          // If an SGI is pending from any CPU and not active
  wire [ 15:  0] sgi_active_clear;
  wire [ 15:  0] sgi_active_set;
  wire           sgi_eoi_nsecure;
  wire           p_sgi_onehot_nsecure;
  wire           sgi_eoi_taken;
  wire           sgi_irq_nsecurity_en_0700;
  wire           sgi_irq_nsecurity_en_1508;
  reg  [ 15:  0] sgi_irq_nsecurity_q;
  wire [ 31:  0] priority_en;
  reg            tm_cnthp_nirq_q;
  reg            tm_cntv_nirq_q;
  reg            tm_cntp_ns_nirq_q;
  reg            tm_cntp_s_nirq_q;
  reg            legacy_irq_q;
  reg            legacy_fiq_q;
  reg            tm_cnthp_irq_q;
  reg            tm_cntv_irq_q;
  reg            tm_cntp_ns_irq_q;
  reg            tm_cntp_s_irq_q;
  reg            vinterface_maintenance_q;
  wire           nxt_legacy_irq;
  wire           nxt_legacy_fiq;
  wire           nxt_tm_cnthp_irq;
  wire           nxt_tm_cntv_irq;
  wire           nxt_tm_cntp_ns_irq;
  wire           nxt_tm_cntp_s_irq;
  wire [  6:  0] ppis_pending;
  wire           lowids_changed;

  reg  [    16*3-1:  0] sgi_pend_valid_cpu;                     // Binary encoded source CPU for each SGI, packed into 1d array
  reg  [         4:  0] sgi_priority_q          [15:0];
  reg  [         4:  0] ppi_priority_q          [6:0];
  wire [NUM_CPUS-1:  0] nxt_sgi_pending_status  [15:0];         // [Int ID][CPU ID]
  wire [        15:  0] set_sgi                 [NUM_CPUS-1:0]; // [CPU ID][Int ID]
  wire [        15:  0] sgi_pending_write_id_strb;              // [Int ID]
  wire [NUM_CPUS-1:  0] sgi_pending_clear       [15:0];         // [Int ID][CPU ID]
  wire [NUM_CPUS-1:  0] sgi_pending_set         [15:0];         // [Int ID][CPU ID]
  reg  [NUM_CPUS-1:  0] sgi_pending_status_q    [15:0];         // [Int ID][CPU ID]
  wire [        15:  0] sgi_pending_status_en;                  // [Int ID]
  wire [        15:  0] core_sgi_pending_status [NUM_CPUS-1:0]; // SGIs pending for each core, core-indexed

  genvar i, j, k, sgi;


  //----------------------------------------------------------------------------
  // PPIs
  //----------------------------------------------------------------------------

  // Private Peripheral Interrupt      PPI#    ID#     PPI Status Register bit#
  // ----------------------------      ---     ---     ------------------------
  // Legacy nFIQ pin                   PPI0    ID28    12
  // Physical Secure Timer event       PPI1    ID29    13
  // Physical Non-Secure Timer event   PPI2    ID30    14
  // Legacy nIRQ pin                   PPI3    ID31    15
  // Virtual Timer event               PPI4    ID27    11
  // Hypervisor Timer event            PPI5    ID26    10
  // Virtual Maintenance Interrupt     PPI6    ID25     9

  // Register the external timer interrupts
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      tm_cnthp_nirq_q   <= 1'b1;
      tm_cntv_nirq_q    <= 1'b1;
      tm_cntp_ns_nirq_q <= 1'b1;
      tm_cntp_s_nirq_q  <= 1'b1;
    end else begin
      tm_cnthp_nirq_q   <= tm_cnthp_nirq_i;
      tm_cntv_nirq_q    <= tm_cntv_nirq_i;
      tm_cntp_ns_nirq_q <= tm_cntp_ns_nirq_i;
      tm_cntp_s_nirq_q  <= tm_cntp_s_nirq_i;
    end

  // All PPI inputs are registered twice, so that changes in the inputs can
  // be detected. This is used at the distributor top level to only enable
  // the clock to the priority logic when the pending interrupts need to be
  // recalculated.
  //
  // The polarity of the inputs is changed so that all IRQs outputs from the
  // second register are active high. This means they do not need to be
  // inverted before being used.
  //
  // - Legacy nirq and nfiq are low-level sensitive, and are registered in
  //   the CPU interface.
  assign nxt_legacy_irq = ~legacy_nirq_i;
  assign nxt_legacy_fiq = ~legacy_nfiq_i;

  // - Timer irqs are low-level sensitive
  assign nxt_tm_cnthp_irq   = ~tm_cnthp_nirq_q;
  assign nxt_tm_cntv_irq    = ~tm_cntv_nirq_q;
  assign nxt_tm_cntp_ns_irq = ~tm_cntp_ns_nirq_q;
  assign nxt_tm_cntp_s_irq  = ~tm_cntp_s_nirq_q;

  // - The virtual maintenance interrupt is high-level sensitive, and
  // generated internally in the VCPU interface.

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      legacy_irq_q              <= 1'b0;
      legacy_fiq_q              <= 1'b0;
      tm_cnthp_irq_q            <= 1'b0;
      tm_cntv_irq_q             <= 1'b0;
      tm_cntp_ns_irq_q          <= 1'b0;
      tm_cntp_s_irq_q           <= 1'b0;
      vinterface_maintenance_q  <= 1'b0;
    end else if (lowids_changed) begin
      legacy_irq_q              <= nxt_legacy_irq;
      legacy_fiq_q              <= nxt_legacy_fiq;
      tm_cnthp_irq_q            <= nxt_tm_cnthp_irq;
      tm_cntv_irq_q             <= nxt_tm_cntv_irq;
      tm_cntp_ns_irq_q          <= nxt_tm_cntp_ns_irq;
      tm_cntp_s_irq_q           <= nxt_tm_cntp_s_irq;
      vinterface_maintenance_q  <= vinterface_maintenance_i;
    end

  assign ppis_pending[6:0] = {legacy_irq_q,              // ID31
                              tm_cntp_ns_irq_q,          // ID30
                              tm_cntp_s_irq_q,           // ID29
                              legacy_fiq_q,              // ID28
                              tm_cntv_irq_q,             // ID27
                              tm_cnthp_irq_q,            // ID26
                              vinterface_maintenance_q}; // ID25

  // Detect changes in the inputs
  assign lowids_changed = {nxt_legacy_irq,
                           nxt_tm_cntp_ns_irq,
                           nxt_tm_cntp_s_irq,
                           nxt_legacy_fiq,
                           nxt_tm_cntv_irq,
                           nxt_tm_cnthp_irq,
                           vinterface_maintenance_i} != ppis_pending;

  // Pass to distributor to use in clock gating
  assign lowids_changed_o = lowids_changed;

  // PPI Pending/Active Status

  assign ack_ppi[6:0]   = ack_ppi_onehot_id_i[6:0]        & {7{int_ack_req_i}};
  assign eoi_ppi[6:0]   = deactivate_ppi_onehot_id_i[6:0] & {7{int_deactivate_req_i}};

  // - Note the write which caused the deactivate happened on the previous
  // cycle, but it is safe to look at p_wnsecure as writes cannot issue back
  // to back, so the value will still be correct for the write on the previous
  // cycle.
  assign ppi_eoi_nsecure = |(deactivate_ppi_onehot_id_i[6:0] & ppi_irq_nsecurity_q[6:0]);

  assign ppi_eoi_taken = int_deactivate_req_i &
                         (ppi_eoi_nsecure |                             // nS Interrupt
                          (~p_wnsecure_i & ~int_deactivate_is_vcpu_i)); // Or secure CPUIF deactivate (VCPUIF deactivates are implicitly nS)

  assign p_pend_wr = p_pend_set_wr_i | p_pend_clear_wr_i;
  assign ppi_pending_status_en = int_ack_req_i | (p_strb_i[3] & p_write_mycpu & p_pend_wr);

  assign nxt_ppi_pending_status[6:0] = ppi_pend_set[6:0] |
                                       (ppi_pending_status_q[6:0] &             // Clear on Ack or write to Pend Clear register
                                        ~(ack_ppi[6:0] | ppi_pend_clear[6:0]));

  always @ (posedge clk_p or negedge reset_n)
    if (!reset_n)
      ppi_pending_status_q <= {7{1'b0}};
    else if (ppi_pending_status_en)
      ppi_pending_status_q <= nxt_ppi_pending_status[6:0];

  assign ppi_active_status_en = int_ack_req_i | ppi_eoi_taken | p_strb_i[3] & p_write_mycpu & p_active_wr;
  assign nxt_ppi_active_status[6:0] = ~(eoi_ppi[6:0] | ppi_active_clear[6:0]) & (ack_ppi[6:0] | ppi_active_set[6:0] | ppi_active_status_q[6:0]);

  always @ (posedge clk_p or negedge reset_n)
    if (!reset_n)
      ppi_active_status_q[6:0] <= {7{1'b0}};
    else if (ppi_active_status_en)
      ppi_active_status_q[6:0] <= nxt_ppi_active_status[6:0];


  //----------------------------------------------------------------------------
  // SGIs
  //----------------------------------------------------------------------------

  // SGI Active Status

  assign ack_sgi[15:0] = ack_sgi_onehot_id_i[15:0] & {16{int_ack_req_i}};
  assign eoi_sgi[15:0] = deactivate_sgi_onehot_id_i[15:0] & {16{(int_deactivate_req_i)}};

  // VCPU interface will send the deactivate request only if the LR HW bit is set,
  // i.e. for SPI & PPI, so a VCPU deactivate can never affect an SGI.
  assign sgi_eoi_nsecure = | (deactivate_sgi_onehot_id_i[15:0] & sgi_irq_nsecurity_q[15:0]);

  assign sgi_eoi_taken = int_deactivate_req_i & (~p_wnsecure_i & ~int_deactivate_is_vcpu_i | sgi_eoi_nsecure);

  // Each gic400_cpu_lowids instantiation corresponds to a target cpu.
  // Each core_sgi_pending_status[*] corresponds to a source cpu for these SGIs.
  // E.g. How is core_sgi_pending_status[3] in gic400_cpu_lowids ucpu0 different
  //      from core_sgi_pending_status[3] in gic400_cpu_lowids ucpu1?
  // The first  one is for SGIs with target cpu 0, and source cpu 3.
  // The second one is for SGIs with target cpu 1, and source cpu 3.

  // Note: There must not be separate active bits depending on the source CPU.
  generate
    for (i=0; i<NUM_CPUS; i=i+1) begin : g_sgi_status_outer
      for (j=0; j<16; j=j+1) begin : g_sgi_status_inner
        assign core_sgi_pending_status[i][j] = sgi_pending_status_q[j][i];
      end
    end
  endgenerate

  assign p_active_wr = p_active_set_wr_i | p_active_clear_wr_i;
  assign core_sgi_active_status_en  = int_ack_req_i | sgi_eoi_taken | (p_write_mycpu & p_active_wr);
  assign nxt_core_sgi_active_status = ~(eoi_sgi | sgi_active_clear[15:0]) & (ack_sgi[15:0] | sgi_active_set[15:0] | core_sgi_active_status_q);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      core_sgi_active_status_q <= {16{1'b0}};
    else if (core_sgi_active_status_en)
      core_sgi_active_status_q <= nxt_core_sgi_active_status;

  //----------------------------------------------------------------------------
  // Get SGI & PPI pending valid
  //----------------------------------------------------------------------------

  always @*
    begin : g_sgi_pend_valid_allcpu
      integer n;
      reg[15:0] sgi_valid_tmp;
      sgi_valid_tmp[15:0] = 16'd0;

      for (n = 0; n < NUM_CPUS; n = n+1)
        sgi_valid_tmp[15:0] = sgi_valid_tmp[15:0] |
                              (core_sgi_pending_status[n][15:0] & ~core_sgi_active_status_q[15:0]);

      sgi_valid = sgi_valid_tmp;
    end


  // When an SGI is pending from multiple CPUs, select the lowest numbered
  // CPU to indicate to the priority logic (the choice of which CPU is
  // arbitrary).
  always @* 
    begin : g_sgi_pend_valid_cpu_sgi
      integer cpu, sgi_id;
      reg [16*3-1:0] sgi_pend_valid_cpu_tmp;

      sgi_pend_valid_cpu_tmp = 48'd0;

      for (sgi_id=0; sgi_id<16; sgi_id=sgi_id+1) begin
        for (cpu=NUM_CPUS-1; cpu>=0; cpu=cpu-1) begin
          sgi_pend_valid_cpu_tmp[3*sgi_id +: 3] = core_sgi_pending_status[cpu][sgi_id] ? cpu[2:0] : sgi_pend_valid_cpu_tmp[3*sgi_id +: 3];
        end
      end

      sgi_pend_valid_cpu = sgi_pend_valid_cpu_tmp;
    end

  // Pending Status Register value for PPI
  assign ppi_can_be_set_pending[6:0] = {7{enable_s_i}} & ~ppi_irq_nsecurity_q[6:0] |
                                       {7{enable_ns_i}} & ppi_irq_nsecurity_q[6:0];

  assign ppi_valid[6:0] = ppi_pending_status[6:0] & ppi_irq_enable_q[6:0] & ~ppi_active_status_q[6:0];

  assign irqs_valid_o       = {ppi_valid, {9{1'b0}}, sgi_valid};
  assign sgi_cpus_o         = sgi_pend_valid_cpu;
  assign lowids_nsecurity_o = {ppi_irq_nsecurity_q, {9{1'b0}}, sgi_irq_nsecurity_q};
  assign lowid_priorities_o = {ppi_priority_q[6],
                               ppi_priority_q[5],
                               ppi_priority_q[4],
                               ppi_priority_q[3],
                               ppi_priority_q[2],
                               ppi_priority_q[1],
                               ppi_priority_q[0],
                               {9*5{1'b0}},
                               sgi_priority_q[15],
                               sgi_priority_q[14],
                               sgi_priority_q[13],
                               sgi_priority_q[12],
                               sgi_priority_q[11],
                               sgi_priority_q[10],
                               sgi_priority_q[9],
                               sgi_priority_q[8],
                               sgi_priority_q[7],
                               sgi_priority_q[6],
                               sgi_priority_q[5],
                               sgi_priority_q[4],
                               sgi_priority_q[3],
                               sgi_priority_q[2],
                               sgi_priority_q[1],
                               sgi_priority_q[0]};


  //------------------------------------------------------------------------------
  // Writes
  //------------------------------------------------------------------------------
  assign p_write_mycpu      = p_blk_write_i & (p_wcpu_i[2:0] == CPU_ID[2:0]);
  assign p_write_sgi_mycpu  = p_write_i     & (p_wcpu_i[2:0] == CPU_ID[2:0]);  // Used for writes to SGI registers, which do not have a block

  assign allow_rd_access[15:0]  = sgi_irq_nsecurity_q[15:0] | {16{~p_rnsecure_i}};
  assign allow_rd_access[24:16] = {9{1'b0}};
  assign allow_rd_access[31:25] = ppi_irq_nsecurity_q[6:0] | {7{~p_rnsecure_i}};

  assign allow_wr_access[15:0]  = sgi_irq_nsecurity_q[15:0] | {16{~p_wnsecure_i}};
  assign allow_wr_access[24:16] = {9{1'b0}};
  assign allow_wr_access[31:25] = ppi_irq_nsecurity_q[6:0] | {7{~p_wnsecure_i}};


  // Interrupt Security
  assign ppi_irq_nsecurity_en = p_write_mycpu & p_secure_wr_i & p_strb_i[3];

  always @ (posedge clk_p or negedge reset_n)
    if (!reset_n)
      ppi_irq_nsecurity_q[6:0] <= {7{1'b0}};
    else if (ppi_irq_nsecurity_en)
      ppi_irq_nsecurity_q[6:0] <= p_wdata_i[31:25];

  assign sgi_irq_nsecurity_en_0700 = p_write_mycpu & p_secure_wr_i & p_strb_i[0];
  assign sgi_irq_nsecurity_en_1508 = p_write_mycpu & p_secure_wr_i & p_strb_i[1];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      sgi_irq_nsecurity_q[7:0] <= {8{1'b0}};
    else if (sgi_irq_nsecurity_en_0700)
      sgi_irq_nsecurity_q[7:0] <= p_wdata_i[7:0];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      sgi_irq_nsecurity_q[15:8] <= {8{1'b0}};
    else if (sgi_irq_nsecurity_en_1508)
      sgi_irq_nsecurity_q[15:8] <= p_wdata_i[15:8];


  // Enable Set and Clear
  assign p_enable_rd = p_enable_set_rd_i | p_enable_clear_rd_i;
  assign p_enable_wr = p_enable_set_wr_i | p_enable_clear_wr_i;

  assign ppi_irq_enable_en = p_write_mycpu & p_enable_wr & p_strb_i[3];
  assign nxt_ppi_irq_enable[6:0] = ppi_irq_enable_q[6:0] & ({7{~p_enable_clear_wr_i}} |
                                                           ~p_wdata_i[31:25] | ~allow_wr_access[31:25]) |
                                  {7{p_enable_set_wr_i}} & p_wdata_i[31:25] &  allow_wr_access[31:25];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      ppi_irq_enable_q[6:0] <= {7{1'b0}};
    else if (ppi_irq_enable_en)
      ppi_irq_enable_q[6:0] <= nxt_ppi_irq_enable[6:0];


  // Pending Set and Clear
  assign ppi_pend_set[6:0]   = p_wdata_i[31:25] & allow_wr_access[31:25] & {7{p_strb_i[3] & p_write_mycpu & p_pend_set_wr_i}};
  assign ppi_pend_clear[6:0] = p_wdata_i[31:25] & allow_wr_access[31:25] & {7{p_strb_i[3] & p_write_mycpu & p_pend_clear_wr_i}};

  // Active Set and Clear
  assign ppi_active_set[6:0]     = p_wdata_i[31:25] & allow_wr_access[31:25] & {7{p_strb_i[3] & p_write_mycpu & p_active_set_wr_i}};
  assign ppi_active_clear[6:0]   = p_wdata_i[31:25] & allow_wr_access[31:25] & {7{p_strb_i[3] & p_write_mycpu & p_active_clear_wr_i}};

  assign sgi_active_set[15:8]   = p_wdata_i[15:8]  & allow_wr_access[15:8]  & {8{p_strb_i[1] & p_write_mycpu & p_active_set_wr_i}};
  assign sgi_active_clear[15:8] = p_wdata_i[15:8]  & allow_wr_access[15:8]  & {8{p_strb_i[1] & p_write_mycpu & p_active_clear_wr_i}};
  assign sgi_active_set[7:0]    = p_wdata_i[7:0]   & allow_wr_access[7:0]   & {8{p_strb_i[0] & p_write_mycpu & p_active_set_wr_i}};
  assign sgi_active_clear[7:0]  = p_wdata_i[7:0]   & allow_wr_access[7:0]   & {8{p_strb_i[0] & p_write_mycpu & p_active_clear_wr_i}};

  // Priority Level
  assign p_wdata_priority_ns[31:0] = { 1'b1, p_wdata_i[31:28], 3'b000,
                                       1'b1, p_wdata_i[23:20], 3'b000,
                                       1'b1, p_wdata_i[15:12], 3'b000,
                                       1'b1, p_wdata_i[7:4], 3'b000 };
  assign p_wdata_priority[31:0] = p_wnsecure_i ? p_wdata_priority_ns[31:0] : p_wdata_i[31:0];

  // For the Priority and Target registers, which have one byte per IRQ, and
  // therefore four IRQs per register, two loops are used. The inner loop
  // corresponds to each IRQ within a register, from 0-3, and the outer loop
  // corresponds to each of the eight registers within the 32 IRQ int_block.
  generate
    for (i=0; i<8; i=i+1) begin : g_byte_reg_outer
      for (j=0; j<4; j=j+1) begin : g_byte_reg_inner

        assign priority_en[4*i+j] = p_write_mycpu & p_priority_wr_i & (p_windex_i[2:0] == i[2:0]) & p_strb_i[j] & allow_wr_access[4*i+j];

        // Only generate priority registers for IRQ IDs 0-15 (SGIs) and 25-31 (PPIs)
        if ((4*i+j) < 16) begin : g_sgi_priority
          // - SGIs
          always @(posedge clk_p or negedge reset_n)
            if (!reset_n)
              sgi_priority_q[4*i+j][4:0] <= {5{1'b0}};
            else if (priority_en[4*i+j])
              sgi_priority_q[4*i+j][4:0] <= p_wdata_priority[8*j+3 +: 5];

        end else if ((4*i+j) >= 25) begin : g_ppi_priority
          // - PPIs
          always @(posedge clk_p or negedge reset_n)
            if (!reset_n)
              ppi_priority_q[(4*i+j)-25][4:0] <= {5{1'b0}};
            else if (priority_en[4*i+j])
              ppi_priority_q[(4*i+j)-25][4:0] <= p_wdata_priority[8*j+3 +: 5];

        end

      end
    end
  endgenerate

  // SGI Pending Set and Clear

  // (set_sgi[sourceCPU][destCPU one-hot])
  // p_wdata_i[15] is bit SATT, SGI is valid only if
  //  - Non-Secure write to SGIR and specified SGI is programmed as Non-Secure regardless of SATT
  //  - Secure write to SGIR and specified SGI is programmed as Secure     if SATT=0
  //  - Secure write to SGIR and specified SGI is programmed as Non-Secure if SATT=1
  assign p_sgi_onehot_nsecure = |(p_sgi_onehot_id_i[15:0] & sgi_irq_nsecurity_q);

  assign p_sgi_req_valid = p_sgi_write_i &
                (enable_s_i & ~p_sgi_onehot_nsecure & ~p_wnsecure_i & ~p_wdata_i[15] |
                 enable_ns_i & p_sgi_onehot_nsecure & (p_wnsecure_i |  p_wdata_i[15]));


  generate
    for (i = 0; i < NUM_CPUS; i = i+1)
      begin : g_sgi_eoi_id
        assign set_sgi[i] = p_sgi_onehot_id_i[15:0] & {16{p_sgi_req_valid & (p_wcpu_i[2:0] == i[2:0])}};
      end
  endgenerate

  assign p_sgi_pend_rd = p_sgi_pend_set_rd_i | p_sgi_pend_clear_rd_i;
  assign p_sgi_pend_wr = p_sgi_pend_set_wr_i | p_sgi_pend_clear_wr_i;

  generate
    for (i = 0; i < 4; i = i+1) begin : g_pending_update_1      // Register number
      for (j = 0; j < 4; j = j+1) begin : g_pending_update_2  // Offset
        assign sgi_pending_write_id_strb[4*i+j] = (p_windex_i[1:0] == i[1:0]) & p_strb_i[j] & p_write_sgi_mycpu;

        assign sgi_pending_set[4*i+j]           = p_wdata_i[NUM_CPUS-1+8*j : 8*j] &
                                              {NUM_CPUS{allow_wr_access[4*i+j] & sgi_pending_write_id_strb[4*i+j] & p_sgi_pend_set_wr_i}};

        assign sgi_pending_clear[4*i+j]         = p_wdata_i[NUM_CPUS-1+8*j : 8*j] &
                                              {NUM_CPUS{allow_wr_access[4*i+j] & sgi_pending_write_id_strb[4*i+j] & p_sgi_pend_clear_wr_i}};

        assign sgi_pending_status_en[4*i+j]     = (allow_wr_access[4*i+j] &
                                               (p_sgi_write_i | (sgi_pending_write_id_strb[4*i+j] & p_sgi_pend_wr))) |
                                              int_ack_req_i;

      end
    end
  endgenerate

  generate
    for (i = 0; i < 16; i = i+1) begin : g_sgi_pending_status             // SGI ID
      for (j = 0; j < NUM_CPUS; j = j+1) begin : g_sgi_pending_status_2 // CPU ID

        assign nxt_sgi_pending_status[i][j] = (sgi_pending_status_q[i][j] & ~((ack_sgi[i] & (int_ack_cpu_i[2:0] == j[2:0])) | sgi_pending_clear[i][j])) |
                                              set_sgi[j][i] | sgi_pending_set[i][j];

      end

      always @(posedge clk_p or negedge reset_n)
        if (!reset_n)
          sgi_pending_status_q[i] <= {NUM_CPUS{1'b0}};
        else if (sgi_pending_status_en[i])
          sgi_pending_status_q[i] <= nxt_sgi_pending_status[i][NUM_CPUS-1:0];
    end
  endgenerate


  //----------------------------------------------------------------------------
  // Reads
  //----------------------------------------------------------------------------

  always @*
    begin : g_core_sgi_pending_status_allcpu
      integer n;
      reg[15:0] core_sgi_pending_status_allcpu_tmp;
      core_sgi_pending_status_allcpu_tmp = 16'h0000;

      for ( n = 0; n < NUM_CPUS; n = n + 1 )
        core_sgi_pending_status_allcpu_tmp = core_sgi_pending_status_allcpu_tmp | core_sgi_pending_status[n];

      core_sgi_pending_status_allcpu = core_sgi_pending_status_allcpu_tmp;
    end

  // Interrupt Security
  assign p_rdata_nsecurity[15:0]  = {16{p_secure_rd_i}} & sgi_irq_nsecurity_q[15:0];
  assign p_rdata_nsecurity[24:16] = {9{1'b0}};
  assign p_rdata_nsecurity[31:25] = {7{p_secure_rd_i}} & ppi_irq_nsecurity_q[6:0];

  // Enable Set and Clear
  assign p_rdata_enable[15:0]  = {16{p_enable_rd}} & allow_rd_access[15:0];  // Value is 1 by default
  assign p_rdata_enable[24:16] = {9{1'b0}};
  assign p_rdata_enable[31:25] = {7{p_enable_rd}} & allow_rd_access[31:25] & ppi_irq_enable_q[6:0];

  // Pending Set and Clear
  assign p_pend_rd = p_pend_set_rd_i | p_pend_clear_rd_i;

  assign ppi_pending_status[6:0] = ppi_pending_status_q[6:0] |
                                   ppi_can_be_set_pending[6:0] & ppis_pending;

  assign p_rdata_pend_status[15:0]  = {16{p_pend_rd}} & allow_rd_access[15:0] & core_sgi_pending_status_allcpu[15:0];
  assign p_rdata_pend_status[24:16] = {9{1'b0}};
  assign p_rdata_pend_status[31:25] = {7{p_pend_rd}} & allow_rd_access[31:25] & ppi_pending_status[6:0];

  // Active Set and Clear
  assign p_active_rd = p_active_set_rd_i | p_active_clear_rd_i;

  assign p_rdata_active_status[15:0]  = {16{p_active_rd}} & allow_rd_access[15:0] & core_sgi_active_status_q[15:0];
  assign p_rdata_active_status[24:16] = {9{1'b0}};
  assign p_rdata_active_status[31:25] = {7{p_active_rd}} & allow_rd_access[31:25] & ppi_active_status_q[6:0];

  // Priority Level
  always @* begin: g_rdata_priority
    integer idx, irq;
    reg[31:0] p_rdata_priority_s_tmp;
    p_rdata_priority_s_tmp = 32'd0;

    for (idx=0; idx<8; idx=idx+1) begin
      for (irq=0; irq<4; irq=irq+1) begin

        // Priority registers are only implemented for IRQ IDs coresponding
        // to PPIs and SGIs. The unused entries are RAZ.
        if ((idx*4+irq) < 16) begin
          // SGIs
          p_rdata_priority_s_tmp[irq*8 +: 8] = p_rdata_priority_s_tmp[irq*8 +: 8] |
                                               { {5{p_priority_rd_i & (p_rindex_i[2:0] == idx[2:0]) & allow_rd_access[idx*4+irq]}} & sgi_priority_q[idx*4+irq][4:0],
                                                 3'b000 };
        end else if ((idx*4+irq) >= 25) begin
          // PPIs
          p_rdata_priority_s_tmp[irq*8 +: 8] = p_rdata_priority_s_tmp[irq*8 +: 8] |
                                               { {5{p_priority_rd_i & (p_rindex_i[2:0] == idx[2:0]) & allow_rd_access[idx*4+irq]}} & ppi_priority_q[(idx*4+irq)-25][4:0],
                                                 3'b000 };
        end
      end
    end

    p_rdata_priority_s = p_rdata_priority_s_tmp;
  end

  assign p_rdata_priority_ns[31:0] = {p_rdata_priority_s[30:27], 4'b0000,
                                      p_rdata_priority_s[22:19], 4'b0000,
                                      p_rdata_priority_s[14:11], 4'b0000,
                                      p_rdata_priority_s[6:3],   4'b0000 };

  assign p_rdata_priority[31:0] = p_rnsecure_i ? p_rdata_priority_ns[31:0] :
                                                 p_rdata_priority_s[31:0];


  // Interrupt Processor Target Register
  // For interrupts < 32, ICDIPTR0 to ICDIPTR7 are read-only, and
  // each field returns the cpu number that performs the read
  generate if (NUM_CPUS >= 2) begin : g_rdata_cpu_target_mp

    assign p_rdata_cpu_target_tmp[31:0] = {32{p_cpu_rd_i}} & {4{CPU_ID_ONEHOT[7:0]}};

    always @ (*)
      case(p_rindex_i[2:0])
        3'b000:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[3]}},
                                                  {8{allow_rd_access[2]}},
                                                  {8{allow_rd_access[1]}},
                                                  {8{allow_rd_access[0]}} };
        3'b001:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[7]}},
                                                  {8{allow_rd_access[6]}},
                                                  {8{allow_rd_access[5]}},
                                                  {8{allow_rd_access[4]}} };
        3'b010:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[11]}},
                                                  {8{allow_rd_access[10]}},
                                                  {8{allow_rd_access[9]}},
                                                  {8{allow_rd_access[8]}} };
        3'b011:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[15]}},
                                                  {8{allow_rd_access[14]}},
                                                  {8{allow_rd_access[13]}},
                                                  {8{allow_rd_access[12]}} };
        3'b100:  p_rdata_cpu_target_mask[31:0] =  32'h0000_0000;
        3'b101:  p_rdata_cpu_target_mask[31:0] =  32'h0000_0000;
        3'b110:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[27]}},
                                                  {8{allow_rd_access[26]}},
                                                  {8{allow_rd_access[25]}},
                                                  8'h00 };
        3'b111:  p_rdata_cpu_target_mask[31:0] = {{8{allow_rd_access[31]}},
                                                  {8{allow_rd_access[30]}},
                                                  {8{allow_rd_access[29]}},
                                                  {8{allow_rd_access[28]}} };
        default: p_rdata_cpu_target_mask[31:0] = {32{1'bx}};
      endcase

    assign p_rdata_cpu_target[31:0] = p_rdata_cpu_target_tmp[31:0] &
                                      p_rdata_cpu_target_mask[31:0];

  end else begin : g_rdata_cpu_target_up
    assign p_rdata_cpu_target[31:0] = 32'h00000000;
  end endgenerate

  // Form the Interrupt Configuration register read data. There are two
  // registers, each corresponding to 16 IRQs. The top register corresponds
  // to the PPIs, which should have encoding 2'b01 for valid interrupts.
  // The bottom register represetnts SGIs, which should have encoding 2'b10.
  // The allow_rd_access signal factors in which interrupts exist and can be
  // legally read back (due to security etc.)
  always @* begin : g_rdata_conf
    integer idx, irq; 
    reg[31:0] p_rdata_conf_tmp;

    p_rdata_conf_tmp = 32'd0;

    for (idx=0; idx<2; idx=idx+1) begin
      for (irq=0; irq<16; irq=irq+1) begin
        p_rdata_conf_tmp[irq*2 +: 2] = p_rdata_conf_tmp[irq*2 +: 2] | ({2{p_conf_rd_i & (p_rindex_i[0] == idx[0]) & allow_rd_access[idx*16+irq]}} & {~idx[0], idx[0]});
      end
    end

    p_rdata_conf = p_rdata_conf_tmp;
  end

  // PPI Status
  assign p_rdata_status[31:0] = { 16'h0000,
                                 {7{p_status_rd_i}} & allow_rd_access[31:25] & ppis_pending,
                                 {9{1'b0}} };

  // SGI Pending Set and Clear
  // Each interrupt occupies 8-bits, so the read data for a given index has data for 4 interrupts.
  // Note that there are only enough SGIs to need to inspect the bottom two bits of the index.
  always @*
    begin : g_p_rdata_sgi_pend_status
      integer n;
      reg [3:0] int_index;
      p_rdata_sgi_pend_status = 32'd0;
      for (n = 0; n < 4; n = n+1)
        begin
          int_index = {p_rindex_i[1:0], n[1:0]};
          p_rdata_sgi_pend_status[8*n +: NUM_CPUS] = {NUM_CPUS{p_sgi_pend_rd & allow_rd_access[int_index]}} &
                                                     sgi_pending_status_q[int_index];
        end
    end

  // Final read
  assign p_rdata_o[31:0] = p_rdata_nsecurity[31:0]     |
                           p_rdata_enable[31:0]        |
                           p_rdata_pend_status[31:0]   |
                           p_rdata_active_status[31:0] |
                           p_rdata_priority[31:0]      |
                           p_rdata_cpu_target[31:0]    |
                           p_rdata_conf[31:0]          |
                           p_rdata_status[31:0]        |
                           p_rdata_sgi_pend_status[31:0];

  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

  `ifdef ARM_ASSERT_ON
    `include "std_ovl_defines.h"

    assert_implication #(`OVL_FATAL,`OVL_ASSERT,"EOI signals had effect on SGI active bits when they should not have")
    ovl_sgis_active_eoi_en (.clk              (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (core_sgi_active_status_en & ~sgi_eoi_taken),
                            .consequent_expr  (~|eoi_sgi));

    assert_implication #(`OVL_FATAL,`OVL_ASSERT,"EOI signals had effect on PPI active bits when they should not have")
    ovl_ppis_active_eoi_en (.clk              (clk),
                            .reset_n          (reset_n),
                            .antecedent_expr  (ppi_active_status_en & ~ppi_eoi_taken),
                            .consequent_expr  (~|eoi_ppi));

    /* ARMAUTO_X */
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: core_sgi_active_status_en")
    u_ovl_x_core_sgi_active_status_en (.clk       (clk_p),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (core_sgi_active_status_en));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: lowids_changed")
    u_ovl_x_lowids_changed (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (lowids_changed));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ppi_active_status_en")
    u_ovl_x_ppi_active_status_en (.clk       (clk_p),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (ppi_active_status_en));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ppi_irq_enable_en")
    u_ovl_x_ppi_irq_enable_en (.clk       (clk_p),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (ppi_irq_enable_en));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ppi_irq_nsecurity_en")
    u_ovl_x_ppi_irq_nsecurity_en (.clk       (clk_p),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (ppi_irq_nsecurity_en));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ppi_pending_status_en")
    u_ovl_x_ppi_pending_status_en (.clk       (clk_p),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (ppi_pending_status_en));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sgi_irq_nsecurity_en_0700")
    u_ovl_x_sgi_irq_nsecurity_en_0700 (.clk       (clk_p),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (sgi_irq_nsecurity_en_0700));
  
    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: sgi_irq_nsecurity_en_1508")
    u_ovl_x_sgi_irq_nsecurity_en_1508 (.clk       (clk_p),
                                       .reset_n   (reset_n),
                                       .qualifier (1'b1),
                                       .test_expr (sgi_irq_nsecurity_en_1508));
  
    assert_never_unknown #(`OVL_FATAL, 16, `OVL_ASSERT, "Register enable x-check: sgi_pending_status_en")
    u_ovl_x_sgi_pending_status_eni (.clk       (clk_p),
                                    .reset_n   (reset_n),
                                    .qualifier (1'b1),
                                    .test_expr (sgi_pending_status_en));


  `endif

endmodule

