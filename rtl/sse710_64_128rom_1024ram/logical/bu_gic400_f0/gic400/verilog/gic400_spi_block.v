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
//      Checked In          : $Date: 2011-08-03 15:09:44 +0100 (Wed, 03 Aug 2011) $
//
//      Revision            : $Revision: 180427 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//
//  This block does the following operations:
//   - main distributor logic for block of 32 SPIs
//
//-----------------------------------------------------------------------------

module gic400_spi_block #(parameter NUM_CPUS = 4)
(
  input  wire             clk,
  input  wire             clk_p,
  input  wire             reset_n,

  // Configuration
  input  wire             spi_cfgsdisable_i,
  input  wire             enable_s_i,     // Global distributor enable
  input  wire             enable_ns_i,    // Global distributor enable

  // External SPI Inputs
  input  wire [31:0]      irqs_i,
  output wire             spis_changed_o, // Indicate change in inputs to distributor

  // Programming Interface
  input  wire             p_blk_write_i,  // Write of distributor register in this int block
  input  wire             p_rnsecure_i,
  input  wire             p_wnsecure_i,
  input  wire [2:0]       p_rindex_i,
  input  wire [2:0]       p_windex_i,
  output wire [31:0]      p_rdata_o,
  input  wire [31:0]      p_wdata_i,
  input  wire [3:0]       p_strb_i,
  input  wire [31:0]      p_strobes_mask_i,

  // - Request Type
  input  wire             p_secure_rd_i,
  input  wire             p_secure_wr_i,
  input  wire             p_enable_set_wr_i,
  input  wire             p_enable_set_rd_i,
  input  wire             p_enable_clear_wr_i,
  input  wire             p_enable_clear_rd_i,
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
  input  wire             p_cpu_wr_i,
  input  wire             p_conf_rd_i,
  input  wire             p_conf_wr_i,
  input  wire             p_status_rd_i,

  // CPU/VCPU interface
  input  wire             int_ack_i,
  input  wire             int_deactivate_i,
  input  wire             int_deactivate_is_vcpu_i,
  input  wire [31:0]      ack_onehot_id_i,
  input  wire [31:0]      deactivate_onehot_id_i,

  // Outputs to Priority logic
  output wire [31:0]      cpu0_irqs_valid_o,
  output wire [31:0]      cpu1_irqs_valid_o,
  output wire [31:0]      cpu2_irqs_valid_o,
  output wire [31:0]      cpu3_irqs_valid_o,
  output wire [31:0]      cpu4_irqs_valid_o,
  output wire [31:0]      cpu5_irqs_valid_o,
  output wire [31:0]      cpu6_irqs_valid_o,
  output wire [31:0]      cpu7_irqs_valid_o,
  output wire [31:0]      spis_nsecurity_o,
  output wire [32*5-1:0]  spi_priorities_o

);


  //----------------------------------------------------------------------------
  // Signal/wire declarations
  //----------------------------------------------------------------------------

  wire [ 31:  0] allow_read_access;
  wire [ 31:  0] allow_write_access;
  wire [ 31:  0] cpu_irqs_valid [7:0];
  wire           cpu_eoi_nsecure;
  wire           cpu_interface_eoi_taken;
  reg  [ 31:  0] edge_level_q;
  wire [ 31:  0] edge_set_irqs;
  wire [ 31:  0] irqs_active_clear;
  wire [ 31:  0] irqs_active_set;
  wire           irqs_active_status_en;
  reg  [ 31:  0] irqs_active_status_q;
  wire [ 31:  0] irqs_can_be_set_pending;
  wire           irqs_enable_en;
  reg  [ 31:  0] irqs_enable_q;
  wire [ 31:  0] irqs_interface_ack;
  wire [ 31:  0] irqs_interface_eoi;
  wire [ 31:  0] irqs_interface_eoi_taken;
  wire           irqs_nsecurity_en;
  reg  [ 31:  0] irqs_nsecurity_q;
  wire [ 31:  0] irqs_pend_clear;
  wire [ 31:  0] irqs_pend_set;
  wire [ 31:  0] irqs_pend_valid;
  wire [ 31:  0] irqs_pending_status;
  wire           irqs_pending_status_en;
  reg  [ 31:  0] irqs_pending_status_q;
  reg  [ 31:  0] irqs_q;
  reg  [ 31:  0] nirqs_q;
  wire [  7:  0] edge_level_byte_en;
  wire [ 31:  0] nxt_edge_level;
  wire [ 31:  0] nxt_irqs_active_status;
  wire [ 31:  0] nxt_irqs_enable;
  wire [ 31:  0] nxt_irqs_nsecurity;
  wire [ 31:  0] nxt_irqs_pending_status;
  wire [ 31:  0] nxt_nirqs;
  wire [ 31:  0] p_rdata_active;
  reg  [ 31:  0] p_rdata_conf;
  wire [ 31:  0] p_rdata_enable;
  wire [ 31:  0] p_rdata_nsecurity;
  wire [ 31:  0] p_rdata_pend;
  wire [ 31:  0] p_rdata_priority;
  wire [ 31:  0] p_rdata_priority_ns;
  reg  [ 31:  0] p_rdata_priority_s;
  wire [ 31:  0] p_rdata_status;
  reg  [ 31:  0] p_rdata_targets_mp;
  wire [ 31:  0] p_rdata_targets;
  wire [ 31:  0] p_secure_strobes_mask;
  wire [ 31:  0] p_wdata_priority;
  wire [ 31:  0] p_wdata_priority_ns;
  wire [ 31:  0] set_irqs;
  wire [ 31:  0] priority_en;
  reg  [  4:  0] priority_q [31:0];
  wire           spis_changed;
  wire [  31: 0] targets_en;

  reg  [NUM_CPUS-1:0] targets_q [31:0];

  genvar i, j, k;
  genvar irqs_valid_cpu, irqs_valid_id;


  //------------------------------------------------------------------------------
  // Interrupt Inputs
  //------------------------------------------------------------------------------

  // Register the external SPI inputs

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      irqs_q <= {32{1'b0}};
    else
      irqs_q <= irqs_i;

  // The SPIs need to be registered again to enable edge detection. To make
  // the detection simpler, the inputs to the second register are inverted.
  assign nxt_nirqs[31:0] = ~irqs_q[31:0];

  // The nirqs_q register only needs to be clocked when there has been
  // a change on the SPI inputs.
  assign spis_changed = (irqs_q != ~nirqs_q);

  // - This is also used by the top level of the distributor to clock gate
  // the priority calculation logic when the inputs are quiescent.
  assign spis_changed_o = spis_changed;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      nirqs_q <= {32{1'b1}};
    else if (spis_changed)
      nirqs_q <= nxt_nirqs[31:0];




  assign irqs_interface_ack[31:0] = {32{int_ack_i}}        & ack_onehot_id_i[31:0];
  assign irqs_interface_eoi[31:0] = {32{int_deactivate_i}} & deactivate_onehot_id_i[31:0];
  assign cpu_eoi_nsecure = |(irqs_interface_eoi[31:0] & irqs_nsecurity_q[31:0]);
  assign irqs_interface_eoi_taken[31:0] = {32{cpu_interface_eoi_taken}} & deactivate_onehot_id_i[31:0];


  //------------------------------------------------------------------------------
  // Update pending status
  //------------------------------------------------------------------------------

  // The arcbitectural pending bit for an IRQ is set on:
  //     * writes to pending_set register
  //     * an edge event when distributor is enabled and IRQ is configured as
  //       edge sensitive.
  // Level interrupts don't update the pending register, but are OR'd into the
  // output if the distributor is enabled.

  assign irqs_can_be_set_pending[31:0] = ({32{enable_s_i}}  & ~irqs_nsecurity_q[31:0]) |
                                         ({32{enable_ns_i}} &  irqs_nsecurity_q[31:0]);

  assign edge_set_irqs[31:0] = irqs_can_be_set_pending[31:0] &  // Enabled
                               edge_level_q[31:0] &             // Configured as edge sensitive
                               irqs_q[31:0] & nirqs_q[31:0];    // 0->1 edge

  assign set_irqs[31:0] = edge_set_irqs[31:0] | irqs_pend_set[31:0];

  assign irqs_pending_status_en = p_blk_write_i | int_ack_i | spis_changed;

  assign nxt_irqs_pending_status[31:0] = set_irqs[31:0] |
                                        (~(irqs_interface_ack[31:0] | irqs_pend_clear[31:0]) &  // Clear on ack or clear
                                         irqs_pending_status_q[31:0]);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      irqs_pending_status_q <= {32{1'b0}};
    else if (irqs_pending_status_en)
      irqs_pending_status_q <= nxt_irqs_pending_status[31:0];


  //----------------------------------------------------------------------------
  // Update active status
  //----------------------------------------------------------------------------
  // EOI Clear active on all CPUs.

  // EOI write from VCPUIF should not clear ACTIVE status of a Secure interrupt,
  // regardless of whether the EOI write to VCPUIF is Secure or Non-Secure access.
  // - Note the write which caused the deactivate happened on the previous
  // cycle, but it is safe to look at p_wnsecure as writes cannot issue back
  // to back, so the value will still be correct for the write on the previous
  // cycle.
  assign cpu_interface_eoi_taken = int_deactivate_i &
                                   (cpu_eoi_nsecure |
                                    (~p_wnsecure_i & ~int_deactivate_is_vcpu_i));

  assign irqs_active_status_en = int_ack_i | cpu_interface_eoi_taken | (p_blk_write_i & (p_active_set_wr_i | p_active_clear_wr_i));
  assign nxt_irqs_active_status[31:0] = ~(irqs_interface_eoi_taken[31:0] | irqs_active_clear[31:0]) &
                                         (irqs_interface_ack[31:0] | irqs_active_set[31:0] | irqs_active_status_q[31:0]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      irqs_active_status_q[31:0] <= {32{1'b0}};
    else if (irqs_active_status_en)
      irqs_active_status_q[31:0] <= nxt_irqs_active_status[31:0];

  //----------------------------------------------------------------------------
  // Get IRQ pending valid
  //----------------------------------------------------------------------------

  // Interrupts to be sent to highest priority pending interrupt logic
  assign irqs_pend_valid[31:0] = irqs_pending_status[31:0] & irqs_enable_q[31:0] & ~irqs_active_status_q[31:0];

  generate for (irqs_valid_cpu=0; irqs_valid_cpu<8; irqs_valid_cpu=irqs_valid_cpu+1) begin : g_irqs_valid_cpu

    if (irqs_valid_cpu < NUM_CPUS) begin : g_irqs_valid

      if (NUM_CPUS > 1) begin : g_irqs_valid_mp
        for (irqs_valid_id=0; irqs_valid_id<32; irqs_valid_id=irqs_valid_id+1) begin : g_irqs_valid_id
          // When multiple CPUs, per CPU valid bit is pending bit masked with
          // target register for that CPU.
          // NB: Nested loops to assign each valid bit for each CPU for each SPI
          // are required because of the different dimensions of cpu_irqs_valid
          // and targets_q.
          assign cpu_irqs_valid[irqs_valid_cpu][irqs_valid_id] = irqs_pend_valid[irqs_valid_id] & targets_q[irqs_valid_id][irqs_valid_cpu];
        end
      end else begin : g_irqs_valid_up
        // When single CPU, target registers not used.
        assign cpu_irqs_valid[0][31:0] = irqs_pend_valid[31:0];
      end

    end else begin : g_irqs_valid_tieoff
      // Tie off unused cpu_irqs_valid entries
      assign cpu_irqs_valid[irqs_valid_cpu][31:0] = 32'h00000000;
    end

  end endgenerate

  assign cpu0_irqs_valid_o = cpu_irqs_valid[0];
  assign cpu1_irqs_valid_o = cpu_irqs_valid[1];
  assign cpu2_irqs_valid_o = cpu_irqs_valid[2];
  assign cpu3_irqs_valid_o = cpu_irqs_valid[3];
  assign cpu4_irqs_valid_o = cpu_irqs_valid[4];
  assign cpu5_irqs_valid_o = cpu_irqs_valid[5];
  assign cpu6_irqs_valid_o = cpu_irqs_valid[6];
  assign cpu7_irqs_valid_o = cpu_irqs_valid[7];
  assign spis_nsecurity_o  = irqs_nsecurity_q;
  assign spi_priorities_o  = {priority_q[31],
                              priority_q[30],
                              priority_q[29],
                              priority_q[28],
                              priority_q[27],
                              priority_q[26],
                              priority_q[25],
                              priority_q[24],
                              priority_q[23],
                              priority_q[22],
                              priority_q[21],
                              priority_q[20],
                              priority_q[19],
                              priority_q[18],
                              priority_q[17],
                              priority_q[16],
                              priority_q[15],
                              priority_q[14],
                              priority_q[13],
                              priority_q[12],
                              priority_q[11],
                              priority_q[10],
                              priority_q[9],
                              priority_q[8],
                              priority_q[7],
                              priority_q[6],
                              priority_q[5],
                              priority_q[4],
                              priority_q[3],
                              priority_q[2],
                              priority_q[1],
                              priority_q[0]};

  //----------------------------------------------------------------------------
  // Writes
  //----------------------------------------------------------------------------

  assign allow_write_access[31:0] = irqs_nsecurity_q[31:0] | ({1'b1, {31{~spi_cfgsdisable_i}}} & {32{~p_wnsecure_i}});
  assign allow_read_access[31:0]  = irqs_nsecurity_q[31:0] | {32{~p_rnsecure_i}};

  assign p_secure_strobes_mask[31:0] = (irqs_nsecurity_q[31:0] | {1'b1, {31{~spi_cfgsdisable_i}}}) & p_strobes_mask_i[31:0];

  // Interrupt Security
  assign irqs_nsecurity_en = p_blk_write_i & p_secure_wr_i;
  assign nxt_irqs_nsecurity[31:0] = (p_wdata_i[31:0]        &  p_secure_strobes_mask[31:0]) |
                                    (irqs_nsecurity_q[31:0] & ~p_secure_strobes_mask[31:0]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      irqs_nsecurity_q[31:0] <= {32{1'b0}};
    else if (irqs_nsecurity_en)
      irqs_nsecurity_q[31:0] <= nxt_irqs_nsecurity[31:0];

  // Enable Set and Clear
  assign irqs_enable_en = p_blk_write_i & (p_enable_set_wr_i | p_enable_clear_wr_i);
  assign nxt_irqs_enable[31:0] = (irqs_enable_q[31:0] & ({32{~p_enable_clear_wr_i}} |
                                                         ~p_wdata_i | ~p_strobes_mask_i | ~allow_write_access)) |
                                 ({32{p_enable_set_wr_i}} & p_wdata_i &  p_strobes_mask_i &  allow_write_access);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      irqs_enable_q[31:0] <= {32{1'b0}};
    else if (irqs_enable_en)
      irqs_enable_q[31:0] <= nxt_irqs_enable[31:0];

  // Pending Set and Clear
  assign irqs_pend_set[31:0]   = {32{p_blk_write_i & p_pend_set_wr_i}}   & p_wdata_i & p_strobes_mask_i & allow_write_access;
  assign irqs_pend_clear[31:0] = {32{p_blk_write_i & p_pend_clear_wr_i}} & p_wdata_i & p_strobes_mask_i & allow_write_access;

  // Active Set and Clear
  assign irqs_active_set[31:0]   = {32{p_blk_write_i & p_active_set_wr_i}}   & p_wdata_i & p_strobes_mask_i & allow_write_access;
  assign irqs_active_clear[31:0] = {32{p_blk_write_i & p_active_clear_wr_i}} & p_wdata_i & p_strobes_mask_i & allow_write_access;

  // Priority Level
  assign p_wdata_priority_ns[31:0] = {1'b1, p_wdata_i[31:28], 3'b000,
                                      1'b1, p_wdata_i[23:20], 3'b000,
                                      1'b1, p_wdata_i[15:12], 3'b000,
                                      1'b1, p_wdata_i[7:4],   3'b000 };

  assign p_wdata_priority[31:0] = p_wnsecure_i ? p_wdata_priority_ns[31:0] : p_wdata_i[31:0];

  // For the Priority and Target registers, which have one byte per SPI, and
  // therefore four SPIs per register, two loops are used. The inner loop
  // corresponds to each SPI within a register, from 0-3, and the outer loop
  // corresponds to each of the eight registers within the 32 SPI int_block.
  generate
    for (i=0; i<8; i=i+1) begin : g_byte_reg_outer
      for (j=0; j<4; j=j+1) begin : g_byte_reg_inner

        assign priority_en[4*i+j] = p_blk_write_i & p_priority_wr_i & (p_windex_i[2:0] == i[2:0]) & p_strb_i[j] & allow_write_access[4*i+j];
        always @(posedge clk_p or negedge reset_n)
          if (!reset_n)
            priority_q[4*i+j][4:0] <= {5{1'b0}};
          else if (priority_en[4*i+j])
            priority_q[4*i+j][4:0] <= p_wdata_priority[8*j+3 +: 5];

        // IRQ Target registers are only created if there is more than one
        // CPU. Otherwise, all IRQs target the single CPU present.
        if (NUM_CPUS > 1) begin : g_targets
          assign targets_en[4*i+j]  = p_blk_write_i & p_cpu_wr_i & (p_windex_i[2:0] == i[2:0]) & p_strb_i[j] & allow_write_access[4*i+j];

          always @(posedge clk_p or negedge reset_n)
            if (!reset_n)
              targets_q[4*i+j][NUM_CPUS-1:0] <= {NUM_CPUS{1'b0}};
            else if (targets_en[4*i+j])
              targets_q[4*i+j][NUM_CPUS-1:0] <= p_wdata_i[8*j +: NUM_CPUS];
        end

      end
    end
  endgenerate

  // Interrupt Configuration
  // - Here there are two bits per SPI in each register. The outer loop
  // corresponds to each of the two registers in the 32 SPI int_block, and
  // two inner loops are used. The first corresponds to each byte within
  // a register, and is used to form the enable. The second corresponds to
  // each SPI.
  // - Note that only the edge level bit of the configuration register is
  // implemented, which corresponds to odd numbered bits in the registers.
  generate
    for (i=0; i<2; i=i+1) begin: g_edge_reg_outer
      for (j=0; j<4; j=j+1) begin: g_edge_reg_inner

        assign edge_level_byte_en[4*i+j] = p_blk_write_i & p_conf_wr_i & (p_windex_i[0] == i[0]) & p_strb_i[j];

        for (k=0; k<4; k=k+1) begin : g_edge_reg
          assign nxt_edge_level[16*i+4*j+k] = allow_write_access[16*i+4*j+k] ? p_wdata_i[(4*j+k)*2+1] : edge_level_q[16*i+4*j+k];

          always @(posedge clk_p or negedge reset_n)
            if (!reset_n)
              edge_level_q[16*i+4*j+k] <= 1'b0;
            else if (edge_level_byte_en[4*i+j])
              edge_level_q[16*i+4*j+k] <= nxt_edge_level[16*i+4*j+k];
        end
      end
    end
  endgenerate

  //----------------------------------------------------------------------------
  // Reads
  //----------------------------------------------------------------------------

  // Interrupt Security
  assign p_rdata_nsecurity[31:0] = {32{p_secure_rd_i}} & irqs_nsecurity_q[31:0];

  // Enable Set and Clear
  assign p_rdata_enable[31:0]    = {32{p_enable_set_rd_i | p_enable_clear_rd_i}}   & allow_read_access & irqs_enable_q[31:0];

  // Pending Set and Clear
  assign irqs_pending_status[31:0] = irqs_pending_status_q[31:0] |
                                     (~edge_level_q[31:0] & irqs_can_be_set_pending[31:0] & ~nirqs_q[31:0]);

  assign p_rdata_pend[31:0]      = {32{p_pend_set_rd_i | p_pend_clear_rd_i}} & allow_read_access & irqs_pending_status[31:0];

  // Active Set and Clear
  assign p_rdata_active[31:0]    = {32{p_active_set_rd_i | p_active_clear_rd_i}}   & allow_read_access & irqs_active_status_q[31:0];

  // Priority Level
  always @* begin : g_rdata_priority
    integer x, y;
    reg[31:0] p_rdata_priority_s_tmp;

    p_rdata_priority_s_tmp = 32'd0;

    for (x=0; x<8; x=x+1) begin
      for (y=0; y<4; y=y+1) begin

        p_rdata_priority_s_tmp[y*8 +: 8] = p_rdata_priority_s_tmp[y*8 +: 8] |
                                           { {5{p_priority_rd_i & (p_rindex_i[2:0] == x[2:0]) & allow_read_access[x*4+y]}} & priority_q[x*4+y][4:0],
                                             3'b000 };
      end
    end

    p_rdata_priority_s = p_rdata_priority_s_tmp;
  end

  assign p_rdata_priority_ns[31:0] = { p_rdata_priority_s[30:27], 4'b0000,
                                       p_rdata_priority_s[22:19], 4'b0000,
                                       p_rdata_priority_s[14:11], 4'b0000,
                                       p_rdata_priority_s[6:3],   4'b0000 };

  assign p_rdata_priority[31:0] = p_rnsecure_i ? p_rdata_priority_ns[31:0] :
                                                 p_rdata_priority_s[31:0];



  // SPI Target
  always @* begin : g_rdata_targets_mp
    integer x, y;
    reg[31:0] p_rdata_targets_mp_tmp;

    // Bits corresponding to CPUs not implemented are RAZ.
    p_rdata_targets_mp_tmp = 32'd0;

    for (x=0; x<8; x=x+1) begin
      for (y=0; y<4; y=y+1) begin

        p_rdata_targets_mp_tmp[y*8 +: NUM_CPUS] = p_rdata_targets_mp_tmp[y*8 +: NUM_CPUS] |
                                                  ({NUM_CPUS{p_cpu_rd_i & (p_rindex_i[2:0] == x[2:0]) & allow_read_access[x*4+y]}} &
                                                   targets_q[x*4+y][NUM_CPUS-1:0]);
      end
    end

    p_rdata_targets_mp = p_rdata_targets_mp_tmp;
  end

  // The SPI Targets register is RAZ in uniprocessor configurations.
  generate if (NUM_CPUS > 1) begin : g_rdata_targets_final_mp
    assign p_rdata_targets = p_rdata_targets_mp[31:0];
  end else begin : g_rdata_targets_final_up
    assign p_rdata_targets = {32{1'b0}};
  end endgenerate

  // Form the Interrupt Configuration register read data. There are two
  // registers, each corresponding to 16 IRQs. The format for each is:
  // {allow_rd_access[MSB], 1'b0, allow_rd_access[MSB-1], 1'b0, ...}, where
  // the MSB is 15 for the lower register and 31 for the upper register.
  always @* begin : g_rdata_conf
    integer x, y;
    reg[31:0] p_rdata_conf_tmp;

    p_rdata_conf_tmp = 32'd0;

    for (x=0; x<2; x=x+1) begin
      for (y=0; y<16; y=y+1) begin
        p_rdata_conf_tmp[y*2 +: 2] = p_rdata_conf_tmp[y*2 +: 2] | ({2{p_conf_rd_i & (p_rindex_i[0] == x[0]) & allow_read_access[x*16+y]}} & {edge_level_q[x*16+y], 1'b1});
      end
    end

    p_rdata_conf = p_rdata_conf_tmp;
  end

  // SPI Status
  assign p_rdata_status[31:0] = {32{p_status_rd_i}} & allow_read_access[31:0] & ~nirqs_q[31:0];


  // Final read
  assign p_rdata_o[31:0] = p_rdata_nsecurity[31:0] |
                           p_rdata_enable[31:0]    |
                           p_rdata_pend[31:0]      |
                           p_rdata_active[31:0]    |
                           p_rdata_priority[31:0]  |
                           p_rdata_targets[31:0]   |
                           p_rdata_conf[31:0]      |
                           p_rdata_status[31:0];


  // ------------------------------------------------------
  // OVL Assertions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: irqs_active_status_en")
  u_ovl_x_irqs_active_status_en (.clk       (clk_p),
                                 .reset_n   (reset_n),
                                 .qualifier (1'b1),
                                 .test_expr (irqs_active_status_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: irqs_enable_en")
  u_ovl_x_irqs_enable_en (.clk       (clk_p),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (irqs_enable_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: irqs_nsecurity_en")
  u_ovl_x_irqs_nsecurity_en (.clk       (clk_p),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (irqs_nsecurity_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: irqs_pending_status_en")
  u_ovl_x_irqs_pending_status_en (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (irqs_pending_status_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: spis_changed")
  u_ovl_x_spis_changed (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (spis_changed));


`endif

endmodule

