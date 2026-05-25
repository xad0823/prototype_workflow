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
//   This block implements the following registers:
//
//      ICR     CPU Interface Control Register
//      PMR     Priotity Mask Register
//      BPR     Binary Point Register
//      IAR     Interrupt Acknowledge Register
//      EOIR    End of Interrupt Register
//      RPR     Running Priority Register
//      HPIR    Highest Pending Interrupt Register
//      ABPR    Aliased Binary Point Register
//      APR0    Active Priorities Register
//      NSAPR0  Non-Secure Active Priorities Register
//      IIDR    CPU Interface Identification Register
//      DIR     Deactivate Interrupt Register
//-----------------------------------------------------------------------------


module gic400_cpu_interface
(

  input  wire         clk,
  input  wire         clk_p,
  input  wire         reset_n,
  input  wire         gic_cfgsdisable_i,

  input  wire         legacy_nirq_i,
  input  wire         legacy_nfiq_i,

  output wire         ppi_legacy_nirq_o,
  output wire         ppi_legacy_nfiq_o,

  input  wire         p_read_i,
  input  wire         p_write_i,

  input  wire         p_rnsecure_i,
  input  wire         p_wnsecure_i,
  input  wire [31:0]  p_wdata_i,
  output wire [31:0]  p_rdata_o,

  input  wire         p_rd_control_req_i,
  input  wire         p_wr_control_req_i,
  input  wire         p_rd_priority_mask_req_i,
  input  wire         p_wr_priority_mask_req_i,
  input  wire         p_rd_binary_point_req_i,
  input  wire         p_wr_binary_point_req_i,
  input  wire         p_rd_ack_req_i,
  input  wire         p_wr_eoi_req_i,
  input  wire         p_rd_running_priority_req_i,
  input  wire         p_rd_highest_pending_req_i,
  input  wire         p_rd_binary_point_ns_alias_req_i,
  input  wire         p_wr_binary_point_ns_alias_req_i,
  input  wire         p_rd_ack_ns_alias_req_i,
  input  wire         p_wr_eoi_ns_alias_req_i,
  input  wire         p_rd_hpi_ns_alias_req_i,
  input  wire         p_rd_active_priorities_req_i,
  input  wire         p_wr_active_priorities_req_i,
  input  wire         p_rd_active_priorities_ns_req_i,
  input  wire         p_wr_active_priorities_ns_req_i,
  input  wire         p_wr_deactivate_req_i,

  input  wire         high_valid_i,
  input  wire         high_nsecure_i,
  input  wire [4:0]   high_priority_i,
  input  wire [8:0]   high_id_i,
  input  wire [2:0]   high_cpu_i,

  output wire         nirq_o,
  output wire         nfiq_o,

  output wire         interface_ack_o,
  output wire         deactivate_o,

  output wire         nirq_out_o,
  output wire         nfiq_out_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  wire           ack_req;
  wire [  4:  0] active_irq_priority;
  wire           active_irq_valid;
  wire           active_priorities_ns_en;
  reg  [ 31:  0] active_priorities_ns_q;
  wire           active_priorities_s_en;
  wire [ 31:  0] active_priorities_s_or_ns;
  reg  [ 31:  0] active_priorities_s_q;
  wire [  4:  0] binary_point_decoded;
  reg  [  4:  0] binary_point_decoded_ns;
  reg  [  4:  0] binary_point_decoded_s;
  wire           binary_point_mask_ns_en;
  reg  [  2:  0] binary_point_mask_ns_q;
  wire           binary_point_mask_s_en;
  wire [  2:  0] binary_point_mask_s_for_ns;
  reg  [  2:  0] binary_point_mask_s_q;
  reg            enable_ns_q;
  reg            enable_s_q;
  reg            nfiq_cpu_q;
  reg            nirq_cpu_q;
  wire           fiq_passthrough;
  wire           cpu_fiq_valid;
  wire           wakeup_fiq_valid;
  wire [ 31:  0] highest_active_priority_mask;
  wire [ 31:  0] highest_active_priority_mask_ns;
  wire [ 31:  0] highest_active_priority_mask_s;
  wire [ 31:  0] hppi_priority_mask;
  wire           interrupt_valid;
  wire           irq_passthrough;
  wire           cpu_irq_valid;
  wire           wakeup_irq_valid;
  wire [  4:  0] masked_active_priority;
  reg            nfiq_wakeup_q;
  reg            nirq_wakeup_q;
  wire           nsecure_en;
  reg            nsecure_eoimode_q;
  reg            nsecure_fiqbypdis_q;
  reg            nsecure_irqbypdis_q;
  wire [ 31:  0] nxt_active_priorities_ns;
  wire [ 31:  0] nxt_active_priorities_s;
  wire           nxt_enable_ns;
  wire           nxt_nirq_cpu;
  wire           nxt_nfiq_cpu;
  wire           nxt_nsecure_eoimode;
  wire           nxt_nsecure_fiqbypdis;
  wire           nxt_nsecure_irqbypdis;
  wire [  4:  0] nxt_priority_mask;
  wire [ 31:  0] p_rdata_ns_control;
  wire [ 31:  0] p_rdata_ns_pri_mask;
  wire [ 31:  0] p_rdata_ns_rpr;
  wire [ 31:  0] p_rdata_ns_bpr;
  wire [ 31:  0] p_rdata_ns_apr;
  wire [ 31:  0] p_rdata_ns;
  wire [ 31:  0] p_rdata_s_control;
  wire [ 31:  0] p_rdata_s_pri_mask;
  wire [ 31:  0] p_rdata_s_bpr;
  wire [ 31:  0] p_rdata_s_rpr;
  wire [ 31:  0] p_rdata_s_bpr_ns;
  wire [ 31:  0] p_rdata_s_ack;
  wire [ 31:  0] p_rdata_s_hpi;
  wire [ 31:  0] p_rdata_ns_ack;
  wire [ 31:  0] p_rdata_ns_hpi;
  wire [ 31:  0] p_rdata_s;
  wire [  2:  0] p_wdata_for_ns_bp;
  wire [  2:  0] p_wdata_for_s_bp;
  wire           pending_can_be_sent;
  wire           priority_mask_en;
  reg  [  4:  0] priority_mask_q;
  reg            secure_ack_ctl_q;
  reg            secure_binary_point_q;
  wire           secure_en;
  reg            secure_eoimode_q;
  reg            secure_fiq_en_q;
  reg            secure_fiqbypdis_q;
  reg            secure_irqbypdis_q;
  reg            legacy_nirq_q;
  reg            legacy_nfiq_q;


  //----------------------------------------------------------------------------
  // Get mask for current hppi
  //----------------------------------------------------------------------------

  assign hppi_priority_mask[31:0] = 32'h00000001 << high_priority_i[4:0];

  assign highest_active_priority_mask_s[31:0]  = priority_filter(active_priorities_s_q[31:0]);
  assign highest_active_priority_mask_ns[31:0] = priority_filter(active_priorities_ns_q[31:0]);

  assign active_priorities_s_or_ns = active_priorities_s_q[31:0] | active_priorities_ns_q[31:0];

  assign highest_active_priority_mask[31:0] = priority_filter(active_priorities_s_or_ns[31:0]);
  assign active_irq_priority[4:0]           = priority_encode(active_priorities_s_or_ns[31:0]); // Binary form of highest_active_priority_mask
  assign active_irq_valid                   = |active_priorities_s_or_ns[31:0];


  //----------------------------------------------------------------------------
  // Active Priorities Register
  //----------------------------------------------------------------------------

  // Secure copy
  assign active_priorities_s_en = (ack_req & ~high_nsecure_i) |
                                  (p_write_i & ~p_wnsecure_i &
                                   (p_wr_active_priorities_req_i | p_wr_eoi_req_i));

  assign nxt_active_priorities_s[31:0]
     = p_write_i ? (({32{p_wr_active_priorities_req_i}} & p_wdata_i[31:0]) |
                    ({32{p_wr_eoi_req_i}}               & active_priorities_s_q[31:0] &
                                                          (secure_ack_ctl_q ? ~highest_active_priority_mask[31:0]
                                                                            : ~highest_active_priority_mask_s[31:0])))
                 : (active_priorities_s_q[31:0] | hppi_priority_mask[31:0]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      active_priorities_s_q[31:0] <= {32{1'b0}};
    else if (active_priorities_s_en)
      active_priorities_s_q[31:0] <= nxt_active_priorities_s[31:0];


  // Non-Secure copy
  assign active_priorities_ns_en = (ack_req & high_nsecure_i) |
                                   (p_write_i &
                                    ((p_wr_active_priorities_req_i    & p_wnsecure_i)   |
                                     (p_wr_active_priorities_ns_req_i & ~p_wnsecure_i)  |
                                     (p_wr_eoi_req_i                  & (p_wnsecure_i | secure_ack_ctl_q)) |
                                     (p_wr_eoi_ns_alias_req_i         & ~p_wnsecure_i)));

  assign nxt_active_priorities_ns[31:0]
     = p_write_i ? (({32{p_wr_active_priorities_req_i}}     & {p_wdata_i[15:0], active_priorities_ns_q[15:0]}) |
                    ({32{p_wr_active_priorities_ns_req_i}}  & p_wdata_i[31:0]) |
                    ({32{(p_wr_eoi_req_i & p_wnsecure_i) |
                         p_wr_eoi_ns_alias_req_i}}          & (active_priorities_ns_q[31:0] & ~highest_active_priority_mask_ns[31:0])) |
                    ({32{p_wr_eoi_req_i & ~p_wnsecure_i}}   & (active_priorities_ns_q[31:0] & ~highest_active_priority_mask[31:0])))
                 : (active_priorities_ns_q[31:0] | hppi_priority_mask[31:0]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      active_priorities_ns_q[31:0] <= {32{1'b0}};
    else if (active_priorities_ns_en)
      active_priorities_ns_q[31:0] <= nxt_active_priorities_ns[31:0];


  //----------------------------------------------------------------------------
  // Binary point dec
  //----------------------------------------------------------------------------

  // Check if an irq is currently pending, according to priorities and 
  // binary point.
  // - Note that the binary point registers can never be written to an
  // unsupported value, so these do not need to be decoded.

  always @*
    case(binary_point_mask_s_q[2:0])
      3'b010:  binary_point_decoded_s[4:0] = 5'b11111;
      3'b011:  binary_point_decoded_s[4:0] = 5'b11110;
      3'b100:  binary_point_decoded_s[4:0] = 5'b11100;
      3'b101:  binary_point_decoded_s[4:0] = 5'b11000;
      3'b110:  binary_point_decoded_s[4:0] = 5'b10000;
      3'b111:  binary_point_decoded_s[4:0] = 5'b00000;
      default: binary_point_decoded_s[4:0] = {5{1'bx}};
    endcase

  always @*
    case(binary_point_mask_ns_q[2:0])
      3'b011:  binary_point_decoded_ns[4:0] = 5'b11111;
      3'b100:  binary_point_decoded_ns[4:0] = 5'b11110;
      3'b101:  binary_point_decoded_ns[4:0] = 5'b11100;
      3'b110:  binary_point_decoded_ns[4:0] = 5'b11000;
      3'b111:  binary_point_decoded_ns[4:0] = 5'b10000;
      default: binary_point_decoded_ns[4:0] = {5{1'bx}};
    endcase

  assign binary_point_decoded[4:0] = (secure_binary_point_q | ~high_nsecure_i) ? binary_point_decoded_s[4:0] :
                                                                                 binary_point_decoded_ns[4:0];

  assign masked_active_priority[4:0] = active_irq_priority[4:0] & binary_point_decoded[4:0];


  //----------------------------------------------------------------------------
  // Interrupt generation
  //----------------------------------------------------------------------------

  assign pending_can_be_sent = high_valid_i & (high_priority_i[4:0] < priority_mask_q[4:0]) &
                               (~active_irq_valid   | (high_priority_i[4:0] < masked_active_priority[4:0]));

  assign interrupt_valid = pending_can_be_sent & (enable_s_q  & ~high_nsecure_i |
                                                  enable_ns_q &  high_nsecure_i);

  assign wakeup_irq_valid = pending_can_be_sent & (~secure_fiq_en_q | high_nsecure_i);
  assign wakeup_fiq_valid = pending_can_be_sent & ~high_nsecure_i & secure_fiq_en_q;

  assign cpu_irq_valid = wakeup_irq_valid & (high_nsecure_i ? enable_ns_q : enable_s_q);
  assign cpu_fiq_valid = wakeup_fiq_valid & enable_s_q;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      nirq_wakeup_q <= 1'b1;
      nfiq_wakeup_q <= 1'b1;
    end else begin
      nirq_wakeup_q <= ~wakeup_irq_valid;
      nfiq_wakeup_q <= ~wakeup_fiq_valid;
    end

  // Register external legacy IRQ inputs to use internally

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      legacy_nirq_q <= 1'b1;
      legacy_nfiq_q <= 1'b1;
    end else begin
      legacy_nirq_q <= legacy_nirq_i;
      legacy_nfiq_q <= legacy_nfiq_i;
    end

  assign irq_passthrough = ~((nsecure_irqbypdis_q & (secure_irqbypdis_q  |  ~secure_fiq_en_q)) | (enable_ns_q | (enable_s_q & ~secure_fiq_en_q)));
  assign fiq_passthrough = ~((secure_fiqbypdis_q  & (nsecure_fiqbypdis_q |   secure_fiq_en_q)) | (enable_s_q & secure_fiq_en_q));

  // Bypass logic
  assign nxt_nirq_cpu = irq_passthrough ? legacy_nirq_q : ~cpu_irq_valid;
  assign nxt_nfiq_cpu = fiq_passthrough ? legacy_nfiq_q : ~cpu_fiq_valid;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      nirq_cpu_q <= 1'b1;
      nfiq_cpu_q <= 1'b1;
    end else begin
      nirq_cpu_q <= nxt_nirq_cpu;
      nfiq_cpu_q <= nxt_nfiq_cpu;
    end

  // Registered legacy IRQs for distributor, to use in PPIs
  assign ppi_legacy_nirq_o = legacy_nirq_q;
  assign ppi_legacy_nfiq_o = legacy_nfiq_q;

  // Wakeup interrupt outputs
  assign nirq_out_o = nirq_wakeup_q;
  assign nfiq_out_o = nfiq_wakeup_q;

  // Interrupt outputs for CPU
  assign nirq_o = nirq_cpu_q;
  assign nfiq_o = nfiq_cpu_q;


  //----------------------------------------------------------------------------
  // Response to distributor
  //----------------------------------------------------------------------------

  assign ack_req = interrupt_valid & p_read_i &
                   ((p_rd_ack_req_i          & ((p_rnsecure_i == high_nsecure_i) |
                                                (~p_rnsecure_i & secure_ack_ctl_q))) |
                    (p_rd_ack_ns_alias_req_i & ~p_rnsecure_i & high_nsecure_i));

  assign interface_ack_o = ack_req;
  assign deactivate_o    = p_write_i &
                           ((p_wr_eoi_req_i          & (p_wnsecure_i ? ~nsecure_eoimode_q : ~secure_eoimode_q)) |
                            (p_wr_deactivate_req_i   & (p_wnsecure_i ? nsecure_eoimode_q  : secure_eoimode_q))  |
                            (p_wr_eoi_ns_alias_req_i & ~p_wnsecure_i & ~secure_eoimode_q));


  //----------------------------------------------------------------------------
  // Writes
  //----------------------------------------------------------------------------

  // Interface Control
  assign secure_en = p_write_i & ~p_wnsecure_i & p_wr_control_req_i & ~gic_cfgsdisable_i;

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      enable_s_q            <= 1'b0;
      secure_ack_ctl_q      <= 1'b0;
      secure_fiq_en_q       <= 1'b0;
      secure_binary_point_q <= 1'b0;
      secure_fiqbypdis_q    <= 1'b0;
      secure_irqbypdis_q    <= 1'b0;
      secure_eoimode_q      <= 1'b0;
    end else if (secure_en) begin
      enable_s_q            <= p_wdata_i[0];
      secure_ack_ctl_q      <= p_wdata_i[2];
      secure_fiq_en_q       <= p_wdata_i[3];
      secure_binary_point_q <= p_wdata_i[4];
      secure_fiqbypdis_q    <= p_wdata_i[5];
      secure_irqbypdis_q    <= p_wdata_i[6];
      secure_eoimode_q      <= p_wdata_i[9];
    end

  assign nsecure_en = p_write_i & p_wr_control_req_i;
  assign nxt_enable_ns         = p_wnsecure_i ? p_wdata_i[0] : p_wdata_i[1];
  assign nxt_nsecure_fiqbypdis = p_wnsecure_i ? p_wdata_i[5] : p_wdata_i[7];
  assign nxt_nsecure_irqbypdis = p_wnsecure_i ? p_wdata_i[6] : p_wdata_i[8];
  assign nxt_nsecure_eoimode   = p_wnsecure_i ? p_wdata_i[9] : p_wdata_i[10];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      enable_ns_q         <= 1'b0;
      nsecure_fiqbypdis_q <= 1'b0;
      nsecure_irqbypdis_q <= 1'b0;
      nsecure_eoimode_q   <= 1'b0;
    end else if (nsecure_en) begin
      enable_ns_q         <= nxt_enable_ns;
      nsecure_fiqbypdis_q <= nxt_nsecure_fiqbypdis;
      nsecure_irqbypdis_q <= nxt_nsecure_irqbypdis;
      nsecure_eoimode_q   <= nxt_nsecure_eoimode;
    end

  // Priority Mask
  assign nxt_priority_mask[4:0] = p_wnsecure_i ? {1'b1, p_wdata_i[7:4]}
                                               : p_wdata_i[7:3];

  assign priority_mask_en = p_write_i & (~p_wnsecure_i | priority_mask_q[4]) & p_wr_priority_mask_req_i;

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      priority_mask_q[4:0] <= {5{1'b0}};
    else if (priority_mask_en)
      priority_mask_q[4:0] <= nxt_priority_mask[4:0];

  // S  Binary point mask value is between 2 and 7 (included)
  // NS Binary point mask value is between 3 and 7 (included)

  // Minimum value is 2
  assign p_wdata_for_s_bp[2:0] = { p_wdata_i[2],
                                   p_wdata_i[1] |  ~p_wdata_i[2],
                                   p_wdata_i[0] & ~(p_wdata_i[2:1] == 2'b00) };

  assign binary_point_mask_s_en = p_write_i & ~p_wnsecure_i & p_wr_binary_point_req_i;

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      binary_point_mask_s_q[2:0] <= 3'b010;
    else if (binary_point_mask_s_en)
      binary_point_mask_s_q[2:0] <= p_wdata_for_s_bp[2:0];

  // Minimum value is 3
  assign p_wdata_for_ns_bp[2:0] = { p_wdata_i[2],
                                    p_wdata_i[1] | ~p_wdata_i[2],
                                    p_wdata_i[0] | ~p_wdata_i[2] };


  assign binary_point_mask_ns_en = p_write_i & (p_wnsecure_i ? (p_wr_binary_point_req_i & ~secure_binary_point_q)
                                                             : p_wr_binary_point_ns_alias_req_i);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      binary_point_mask_ns_q[2:0] <= 3'b011;
    else if (binary_point_mask_ns_en)
      binary_point_mask_ns_q[2:0] <= p_wdata_for_ns_bp[2:0];

  //----------------------------------------------------------------------------
  // Reads
  //----------------------------------------------------------------------------

  // Secure Reads

  assign p_rdata_s_control[31:0] = { {20{1'b0}}, {1{1'b0}},
                                     nsecure_eoimode_q, secure_eoimode_q,
                                     nsecure_irqbypdis_q, nsecure_fiqbypdis_q,
                                     secure_irqbypdis_q, secure_fiqbypdis_q,
                                     secure_binary_point_q, secure_fiq_en_q,
                                     secure_ack_ctl_q, enable_ns_q, enable_s_q };

  assign p_rdata_s_pri_mask[31:0] = { {20{1'b0}}, {4{1'b0}}, priority_mask_q[4:0], 3'b000 };

  assign p_rdata_s_bpr[31:0]      = { {20{1'b0}}, {9{1'b0}}, binary_point_mask_s_q[2:0] };

  assign p_rdata_s_rpr[31:0]      = { {20{1'b0}}, {4{1'b0}}, ({active_irq_priority[4:0], 3'b000} |
                                                              {8{~active_irq_valid}}) };  // Mask to 0xFF if not valid

  assign p_rdata_s_bpr_ns[31:0]   = { {20{1'b0}}, {9{1'b0}}, binary_point_mask_ns_q[2:0] };

  assign p_rdata_s_ack[31:0]      = interrupt_valid ? ((~high_nsecure_i |
                                                        secure_ack_ctl_q) ? { {19{1'b0}}, {high_cpu_i[2:0], 1'b0, high_id_i[8:0]} } // Secure IRQ or AckCtl set
                                                                          : { {20{1'b0}}, 12'h3fe })                                // nS IRQ when AckCtl not set
                                                    : { {20{1'b0}}, 12'h3ff };                                                      // No valid IRQ

  assign p_rdata_ns_ack[31:0]     = (interrupt_valid & high_nsecure_i) ? { {19{1'b0}}, {high_cpu_i[2:0], 1'b0, high_id_i[8:0]} }
                                                                       : { {20{1'b0}}, 12'h3ff };

  assign p_rdata_s_hpi[31:0]      = high_valid_i ? ((~high_nsecure_i |
                                                     secure_ack_ctl_q) ? { {19{1'b0}}, {high_cpu_i[2:0], 1'b0, high_id_i[8:0]} } // Secure IRQ or AckCtl set
                                                                       : { {20{1'b0}}, 12'h3fe })                                // nS IRQ when AckCtl not set
                                                 : { {20{1'b0}}, 12'h3ff };                                                      // No valid IRQ

  assign p_rdata_ns_hpi[31:0]     = (high_valid_i & high_nsecure_i) ? { {19{1'b0}}, {high_cpu_i[2:0], 1'b0, high_id_i[8:0]} }
                                                                    : { {20{1'b0}}, 12'h3ff };


  assign p_rdata_s[31:0] = ({32{p_rd_control_req_i}}                & p_rdata_s_control[31:0])      |
                           ({32{p_rd_priority_mask_req_i}}          & p_rdata_s_pri_mask[31:0])     |
                           ({32{p_rd_binary_point_req_i}}           & p_rdata_s_bpr[31:0])          |
                           ({32{p_rd_running_priority_req_i}}       & p_rdata_s_rpr[31:0])          |
                           ({32{p_rd_binary_point_ns_alias_req_i}}  & p_rdata_s_bpr_ns[31:0])       |
                           ({32{p_rd_ack_req_i}}                    & p_rdata_s_ack[31:0])          |
                           ({32{p_rd_ack_ns_alias_req_i}}           & p_rdata_ns_ack[31:0])         |
                           ({32{p_rd_highest_pending_req_i}}        & p_rdata_s_hpi[31:0])          |
                           ({32{p_rd_hpi_ns_alias_req_i}}           & p_rdata_ns_hpi[31:0])         |
                           ({32{p_rd_active_priorities_req_i}}      & active_priorities_s_q[31:0])  |
                           ({32{p_rd_active_priorities_ns_req_i}}   & active_priorities_ns_q[31:0]);

  // Non-Secure Reads

  assign p_rdata_ns_control[31:0]   = { {20{1'b0}}, {2{1'b0}},
                                        nsecure_eoimode_q, {2{1'b0}},
                                        nsecure_irqbypdis_q, nsecure_fiqbypdis_q,
                                        {4{1'b0}}, enable_ns_q };

  assign p_rdata_ns_pri_mask[31:0]  = { {20{1'b0}}, {4{1'b0}}, ({4{priority_mask_q[4]}} & priority_mask_q[3:0]), 4'b0000 };

  assign p_rdata_ns_rpr[31:0]       = { {20{1'b0}}, {4{1'b0}}, ( {({4{active_irq_priority[4]}} & active_irq_priority[3:0]), 4'b0000} |
                                                                 {8{~active_irq_valid}} ) }; // Mask to 0xFF if not valid

  // - Value read when secure_binary_point_q is set, saturating at 7
  assign binary_point_mask_s_for_ns[2:0] =   binary_point_mask_s_q[2:0] + 3'b001 |
                                          {3{binary_point_mask_s_q[2:0] == 3'b111}};

  assign p_rdata_ns_bpr[31:0]       = secure_binary_point_q ? { {20{1'b0}}, {9{1'b0}}, binary_point_mask_s_for_ns[2:0] }
                                                            : { {20{1'b0}}, {9{1'b0}}, binary_point_mask_ns_q[2:0] };

  assign p_rdata_ns_apr[31:0]       = { {16{1'b0}}, active_priorities_ns_q[31:16] };

  assign p_rdata_ns[31:0] = ({32{p_rd_control_req_i}}           & p_rdata_ns_control[31:0])   |
                            ({32{p_rd_priority_mask_req_i}}     & p_rdata_ns_pri_mask[31:0])  |
                            ({32{p_rd_running_priority_req_i}}  & p_rdata_ns_rpr[31:0])       |
                            ({32{p_rd_binary_point_req_i}}      & p_rdata_ns_bpr[31:0])       |
                            ({32{p_rd_active_priorities_req_i}} & p_rdata_ns_apr[31:0])       |
                            ({32{p_rd_ack_req_i}}               & p_rdata_ns_ack[31:0])       |
                            ({32{p_rd_highest_pending_req_i}}   & p_rdata_ns_hpi[31:0]);

  // Final read
  assign p_rdata_o[31:0] = p_rnsecure_i ? p_rdata_ns[31:0] : p_rdata_s[31:0];


  //------------------------------------------------------------------------------
  // OVL assertions
  //------------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // The binary point registers cannot be written to unsupported values, so
  // these do not need to be decoded.
  // - binary_point_mask_s_q
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"binary_point_mask_s_q was set to an unsupported value")
  ovl_binary_point_mask_s_valid   (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((binary_point_mask_s_q[2:0] == 3'b000) | 
                                               (binary_point_mask_s_q[2:0] == 3'b001)));

  // - binary_point_mask_ns_q
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"binary_point_mask_ns_q was set to an unsupported value")
  ovl_binary_point_mask_ns_valid  (.clk       (clk),
                                   .reset_n   (reset_n),
                                   .test_expr ((binary_point_mask_ns_q[2:0] == 3'b000) | 
                                               (binary_point_mask_ns_q[2:0] == 3'b001) | 
                                               (binary_point_mask_ns_q[2:0] == 3'b010)));

  // This means that the default branch of the binary point decoder case
  // statements should never be reached, and so should never assign X to the
  // decoded signal.
  // - binary_point_decoded_s
  assert_never_unknown #(`OVL_FATAL,5,`OVL_ASSERT, "binary_point_decoded_s never X")
  u_ovl_x_bp_decoded_s       (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (binary_point_decoded_s[4:0]));

  // - binary_point_decoded_ns
  assert_never_unknown #(`OVL_FATAL,5,`OVL_ASSERT, "binary_point_decoded_ns never X")
  u_ovl_x_bp_decoded_ns      (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (binary_point_decoded_ns[4:0]));

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_ns_en")
  u_ovl_x_active_priorities_ns_en (.clk       (clk_p),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (active_priorities_ns_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_s_en")
  u_ovl_x_active_priorities_s_en (.clk       (clk_p),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (active_priorities_s_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: binary_point_mask_ns_en")
  u_ovl_x_binary_point_mask_ns_en (.clk       (clk_p),
                                   .reset_n   (reset_n),
                                   .qualifier (1'b1),
                                   .test_expr (binary_point_mask_ns_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: binary_point_mask_s_en")
  u_ovl_x_binary_point_mask_s_en (.clk       (clk_p),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (binary_point_mask_s_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: nsecure_en")
  u_ovl_x_nsecure_en (.clk       (clk_p),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (nsecure_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: priority_mask_en")
  u_ovl_x_priority_mask_en (.clk       (clk_p),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (priority_mask_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: secure_en")
  u_ovl_x_secure_en (.clk       (clk_p),
                     .reset_n   (reset_n),
                     .qualifier (1'b1),
                     .test_expr (secure_en));


`endif

endmodule

