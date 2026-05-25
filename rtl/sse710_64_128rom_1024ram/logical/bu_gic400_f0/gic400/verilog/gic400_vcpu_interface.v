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
//      Checked In          : $Date: 2012-07-03 14:28:06 +0100 (Tue, 03 Jul 2012) $
//
//      Revision            : $Revision: 213777 $
//
//      Release Information : GIC-400-r0p1-00rel0
//
//-----------------------------------------------------------------------------
// Purpose:
//
//  This module implements the following registers:
//
//     GICH_HCR     Hypervisor Control Register
//     GICH_VTR     VGIC Type Register
//     GICH_APR0    Active Priorities Register
//     GICH_LR0     List Register 0
//     GICH_LR1     List Register 1
//     GICH_LR2     List Register 2
//     GICH_LR3     List Register 3
//
//     GICV_CTLR    VM Control Register
//     GICV_PMR     VM Priority Mask Register
//     GICV_BPR     VM Binary Point Register
//     GICV_IAR     VM Interrupt Acknowledge Register
//     GICV_EOIR    VM End of Interrupt Register
//     GICV_RPR     VM Running Priority Register
//     GICV_HPIR    VM Highest Pending Interrupt Register
//     GICV_ABPR    VM Aliased Binary Point Register
//     GICV_APR0    VM Active Priority Register
//     GICV_NSAPR0  VM Non-Secure Active Priority Register
//     GICV_IIDR    VM CPU Interface Identification Register
//     GICV_DIR     VM Deactivate Interrupt Register
//
//-----------------------------------------------------------------------------


module gic400_vcpu_interface
(
  input  wire        clk,
  input  wire        clk_p,
  input  wire        reset_n,

  // Programming Interface
  input  wire        p_read_i,
  input  wire        p_write_i,
  input  wire        p_rd_front_i,
  input  wire        p_wr_front_i,

  input  wire        p_rd_ack_front_i,
  input  wire        p_rd_ack_ns_alias_front_i,
  input  wire        p_rd_active_priorities_back_i,
  input  wire        p_wr_active_priorities_back_i,
  input  wire        p_rd_active_priorities_front_i,
  input  wire        p_wr_active_priorities_front_i,
  input  wire        p_rd_binary_point_front_i,
  input  wire        p_wr_binary_point_front_i,
  input  wire        p_rd_binary_point_ns_alias_front_i,
  input  wire        p_wr_binary_point_ns_alias_front_i,
  input  wire        p_wr_deactivate_front_i,
  input  wire        p_rd_empty_list_status_back_i,
  input  wire        p_wr_eoi_front_i,
  input  wire        p_rd_eoi_int_status_back_i,
  input  wire        p_wr_eoi_ns_alias_front_i,
  input  wire        p_rd_highest_pending_front_i,
  input  wire        p_rd_hpi_ns_alias_front_i,
  input  wire        p_rd_hyp_control_back_i,
  input  wire        p_wr_hyp_control_back_i,
  input  wire        p_rd_list_back_i,
  input  wire  [3:0] p_rd_list_sel_i,
  input  wire        p_wr_list_back_i,
  input  wire  [3:0] p_wr_list_sel_i,
  input  wire        p_rd_maint_int_status_back_i,
  input  wire        p_rd_priority_mask_front_i,
  input  wire        p_wr_priority_mask_front_i,
  input  wire        p_rd_running_priority_front_i,
  input  wire        p_rd_vgic_type_back_i,
  input  wire        p_rd_vm_control_alias_back_i,
  input  wire        p_wr_vm_control_alias_back_i,
  input  wire        p_rd_vm_control_front_i,
  input  wire        p_wr_vm_control_front_i,
  input  wire [31:0] p_wdata_i,
  output wire [31:0] p_rdata_o,

  // Virtual Interrupts
  output wire        nvirq_o,
  output wire        nvfiq_o,

  // Distributor Interface
  output wire        deactivate_o,
  output wire  [8:0] deactivate_id_o,
  output wire        maintenance_irq_o
);

  //----------------------------------------------------------------------------
  // Local constants
  //----------------------------------------------------------------------------

  `include "gic400_defs.v"


  //----------------------------------------------------------------------------
  // Signal declarations
  //----------------------------------------------------------------------------

  reg            hppi_valid_q;
  reg  [  9:  0] hppi_virt_id_q;
  reg  [  4:  0] hppi_priority_q;
  reg            hppi_ns_q;
  reg  [  3:  0] hppi_sel_q;
  wire [  4:  0] active_irq_priority;
  wire           active_irq_valid;
  wire           active_priorities_en;
  reg  [ 31:  0] active_priorities_q;
  wire           apr_not_empty;
  wire [  4:  0] binary_point_decoded;
  reg  [  4:  0] binary_point_decoded_ns;
  reg  [  4:  0] binary_point_decoded_s;
  wire [  2:  0] cpuid;
  wire           eoi_count_en;
  wire [  4:  0] eoi_count_plus_one;
  reg  [  4:  0] eoi_count_q;
  wire           fiq_valid;
  wire [ 31:  0] highest_active_priority_mask;
  wire           hppi_ns;
  wire [  4:  0] hppi_priority;
  wire [ 31:  0] hppi_priority_mask;
  wire [  3:  0] hppi_sel;
  wire           hppi_valid;
  wire [  9:  0] hppi_virt_id;
  wire [ 31:  0] hyp_control_reg;
  wire           interrupt_valid;
  wire           invalid_vm_bp_ns_back;
  wire           invalid_vm_bp_ns_front;
  wire           invalid_vm_bp_s_back;
  wire           invalid_vm_bp_s_front;
  wire           irq_valid;
  wire           deactivate_en;
  wire [  3:  0] eoi_virt_id_match;
  wire           list01_is0;
  wire           list01_is_pending;
  wire           list01_ns;
  wire [  4:  0] list01_priority;
  wire [  9:  0] list01_virt_id;
  wire [  3:  0] list_active;
  wire [  3:  0] list_pending;
  wire [  3:  0] list_send_deactivate;
  wire [  3:  0] list_hw;
  wire [  3:  0] list_ns;
  wire [  4:  0] list_priority [3:0];
  wire [  3:  0] list_ei;
  wire [  8:  0] list_phys_id  [3:0];
  wire [  9:  0] list_virt_id  [3:0];
  wire [ 31:  0] list_rdata    [3:0];
  wire [  3:  0] list_eoi_int_status_bits;
  wire [  3:  0] list_empty_status_bits;
  wire [  3:  0] list_pending_valid;
  reg  [ 31:  0] list_muxed_rdata;
  wire           list23_is2;
  wire           list23_is_pending;
  wire           list23_ns;
  wire [  4:  0] list23_priority;
  wire [  9:  0] list23_virt_id;
  wire           list_ei_and_invalid;
  wire           list_is01;
  wire [  3:  0] list_active_or_pending;
  wire [ 31:  0] maint_int_status_reg;
  wire [  4:  0] masked_active_priority;
  wire           misr_ei;
  wire           misr_npi;
  wire           misr_skidi;
  wire           misr_ui;
  wire           misr_vdnsi;
  wire           misr_vdsi;
  wire           misr_vensi;
  wire           misr_vesi;
  wire           no_idmatch_list;
  wire           no_pending_list;
  wire           no_valid_list;
  reg            nopend_irq_en_q;
  reg            nvfiq_q;
  reg            nvirq_q;
  wire [ 31:  0] nxt_active_priorities;
  wire [  4:  0] nxt_eoi_count;
  wire           nxt_nvfiq;
  wire           nxt_nvirq;
  wire [  2:  0] nxt_vm_bp_ns;
  wire [  2:  0] nxt_vm_bp_s;
  wire [  4:  0] nxt_vm_priority_mask;
  wire           only_one_valid_list;
  wire [ 12:  0] p_rdata_ack;
  wire [ 12:  0] p_rdata_ack_ns_alias;
  wire [ 31:  0] p_rdata_back;
  wire [ 31:  0] p_rdata_front;
  wire [ 12:  0] p_rdata_hpi_ns_alias;
  wire [ 12:  0] p_rdata_hppi;
  wire [  7:  0] p_rdata_priority;
  wire           pending_can_be_sent;
  reg            skid_irq_en_q;
  reg            underflow_irq_en_q;
  wire [ 31:  0] vgic_type_reg;
  wire           virt_en;
  reg            virt_en_q;
  reg            vm_ack_ctl_q;
  wire           vm_bp_ns_en;
  reg  [  2:  0] vm_bp_ns_q;
  wire           vm_bp_s_en;
  reg  [  2:  0] vm_bp_s_q;
  wire [ 31:  0] vm_control_alias_reg;
  wire [ 31:  0] vm_control_reg;
  wire           vm_en;
  reg            vm_en_ns_q;
  reg            vm_en_s_q;
  reg            vm_eoimode_q;
  reg            vm_fiq_en_q;
  wire           vm_priority_mask_en;
  reg  [  4:  0] vm_priority_mask_q;
  reg            vm_sbpr_q;
  reg            vmdis_ns_irq_en_q;
  reg            vmdis_s_irq_en_q;
  reg            vmen_ns_irq_en_q;
  reg            vmen_s_irq_en_q;
  wire [  3:  0] p_wr_list_back_sel;

  genvar list_num;


  //---------------------------------------------------------------------------
  // VM Control Register Enable Bits
  //---------------------------------------------------------------------------

  assign vm_en = p_write_i & (p_wr_front_i ? p_wr_vm_control_front_i : p_wr_vm_control_alias_back_i);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      vm_en_s_q     <= 1'b0;
      vm_en_ns_q    <= 1'b0;
      vm_ack_ctl_q  <= 1'b0;
      vm_fiq_en_q   <= 1'b0;
      vm_sbpr_q     <= 1'b0;
      vm_eoimode_q  <= 1'b0;
    end else if (vm_en) begin
      vm_en_s_q     <= p_wdata_i[0];
      vm_en_ns_q    <= p_wdata_i[1];
      vm_ack_ctl_q  <= p_wdata_i[2];
      vm_fiq_en_q   <= p_wdata_i[3];
      vm_sbpr_q     <= p_wdata_i[4];
      vm_eoimode_q  <= p_wdata_i[9];
    end

  assign vm_control_reg[31:0] = {{22{1'b0}}, vm_eoimode_q, 4'b0000, vm_sbpr_q, vm_fiq_en_q, vm_ack_ctl_q, vm_en_ns_q, vm_en_s_q};

  //-----------------------------------------------------------------------------
  // VM Priority Mask Register
  //-----------------------------------------------------------------------------

  assign vm_priority_mask_en = p_write_i & (p_wr_front_i ? p_wr_priority_mask_front_i : p_wr_vm_control_alias_back_i);

  assign nxt_vm_priority_mask[4:0] = p_wr_front_i ? p_wdata_i[7:3] : p_wdata_i[31:27];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      vm_priority_mask_q[4:0] <= {5{1'b0}};
    else if (vm_priority_mask_en)
      vm_priority_mask_q[4:0] <= nxt_vm_priority_mask[4:0];


  //---------------------------------------------------------------------------
  // VM Binary Point Register
  //---------------------------------------------------------------------------
  // Attempts to write 0 or 1 -> make 0x2 to be stored
  // Allowed range is from 0x2 - 0x7

  assign invalid_vm_bp_s_back  = ~(|p_wdata_i[23:22]);
  assign invalid_vm_bp_s_front = ~(|p_wdata_i[2:1]);

  assign vm_bp_s_en = p_write_i & (p_wr_front_i ? p_wr_binary_point_front_i : p_wr_vm_control_alias_back_i);

  assign nxt_vm_bp_s[2:0] = p_wr_front_i ? (invalid_vm_bp_s_front ? 3'b010 : p_wdata_i[2:0])
                                         : (invalid_vm_bp_s_back  ? 3'b010 : p_wdata_i[23:21]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      vm_bp_s_q[2:0] <= 3'b010;
    else if (vm_bp_s_en)
      vm_bp_s_q[2:0] <= nxt_vm_bp_s[2:0];

  //---------------------------------------------------------------------------
  // VM Aliased NS Binary Point Register
  //---------------------------------------------------------------------------
  // Attempts to write 0 or 1 or 2 -> make 0x3 to be stored
  // Allowed range is from 0x3 - 0x7

  assign invalid_vm_bp_ns_back  = ~(|p_wdata_i[20:19]) | (p_wdata_i[20:18] == 3'b010);
  assign invalid_vm_bp_ns_front = ~(|p_wdata_i[2:1])   | (p_wdata_i[2:0]   == 3'b010);

  assign vm_bp_ns_en = p_write_i & (p_wr_front_i ? p_wr_binary_point_ns_alias_front_i : p_wr_vm_control_alias_back_i);

  assign nxt_vm_bp_ns[2:0] = p_wr_front_i ? (invalid_vm_bp_ns_front ? 3'b011 : p_wdata_i[2:0])
                                          : (invalid_vm_bp_ns_back  ? 3'b011 : p_wdata_i[20:18]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      vm_bp_ns_q[2:0] <= 3'b011;
    else if (vm_bp_ns_en)
      vm_bp_ns_q[2:0] <= nxt_vm_bp_ns[2:0];

  //---------------------------------------------------------------------------
  // VM EOI Count
  //---------------------------------------------------------------------------
  // Increment EOICount if there is not a matching ID in the List registers
  // that is in ACTIVE or PENDING+ACTIVE

  assign no_idmatch_list = ~|(eoi_virt_id_match[3:0] & list_active[3:0]);

  // Don't increment EOICount if an EOI is received and no bits are set in the APR
  assign apr_not_empty = |(active_priorities_q[31:0]);

  assign eoi_count_en = p_write_i & ((~p_wr_front_i & p_wr_hyp_control_back_i) |
                                     (p_wr_front_i & no_idmatch_list &
                                     (vm_eoimode_q ? p_wr_deactivate_front_i
                                                   : ((p_wr_eoi_front_i | p_wr_eoi_ns_alias_front_i) & apr_not_empty))));

  assign eoi_count_plus_one[4:0] = eoi_count_q[4:0] + 5'b00001;

  assign nxt_eoi_count[4:0] = p_wr_front_i ? eoi_count_plus_one[4:0] : p_wdata_i[31:27];

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      eoi_count_q[4:0] <=  {5{1'b0}};
    else if (eoi_count_en)
      eoi_count_q[4:0] <=  nxt_eoi_count[4:0];

  //---------------------------------------------------------------------------
  // Hypervisor Control Register Enable bits
  //---------------------------------------------------------------------------

  assign virt_en = p_write_i & ~p_wr_front_i & p_wr_hyp_control_back_i;

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n) begin
      virt_en_q           <= 1'b0;
      underflow_irq_en_q  <= 1'b0;
      skid_irq_en_q       <= 1'b0;
      nopend_irq_en_q     <= 1'b0;
      vmen_s_irq_en_q     <= 1'b0;
      vmdis_s_irq_en_q    <= 1'b0;
      vmen_ns_irq_en_q    <= 1'b0;
      vmdis_ns_irq_en_q   <= 1'b0;
    end else if (virt_en) begin
      virt_en_q           <= p_wdata_i[0];
      underflow_irq_en_q  <= p_wdata_i[1];
      skid_irq_en_q       <= p_wdata_i[2];
      nopend_irq_en_q     <= p_wdata_i[3];
      vmen_s_irq_en_q     <= p_wdata_i[4];
      vmdis_s_irq_en_q    <= p_wdata_i[5];
      vmen_ns_irq_en_q    <= p_wdata_i[6];
      vmdis_ns_irq_en_q   <= p_wdata_i[7];
    end

  //---------------------------------------------------------------------------
  // LIST 0-3 State & Registers
  //---------------------------------------------------------------------------

  assign p_wr_list_back_sel[3:0] = {4{p_wr_list_back_i}} & p_wr_list_sel_i[3:0];

  generate for (list_num=0; list_num<4; list_num=list_num+1) begin : g_lists

    gic400_vcpu_interface_list_reg
      u_list_reg
        (
          .clk_p                      (clk_p),
          .reset_n                    (reset_n),

          .p_read_i                   (p_read_i),
          .p_rd_front_i               (p_rd_front_i),
          .p_write_i                  (p_write_i),
          .p_wr_front_i               (p_wr_front_i),
          .p_wdata_i                  (p_wdata_i),
          .p_rd_ack_front_i           (p_rd_ack_front_i),
          .p_rd_ack_ns_alias_front_i  (p_rd_ack_ns_alias_front_i),
          .p_wr_eoi_front_i           (p_wr_eoi_front_i),
          .p_wr_eoi_ns_alias_front_i  (p_wr_eoi_ns_alias_front_i),
          .p_wr_list_back_i           (p_wr_list_back_sel[list_num]),
          .p_wr_deactivate_front_i    (p_wr_deactivate_front_i),
          .eoi_virt_id_match_i        (eoi_virt_id_match[list_num]),
          .interrupt_valid_i          (interrupt_valid),
          .hppi_sel_i                 (hppi_sel_q[list_num]),
          .vm_ack_ctl_i               (vm_ack_ctl_q),
          .vm_eoimode_i               (vm_eoimode_q),

          .list_active_o              (list_active[list_num]),
          .list_pending_o             (list_pending[list_num]),
          .list_send_deactivate_o     (list_send_deactivate[list_num]),

          .list_hw_o                  (list_hw[list_num]),
          .list_ns_o                  (list_ns[list_num]),
          .list_priority_o            (list_priority[list_num][4:0]),
          .list_ei_o                  (list_ei[list_num]),
          .list_phys_id_o             (list_phys_id[list_num][8:0]),
          .list_virt_id_o             (list_virt_id[list_num][9:0])
        );

    // Form list read data
    assign list_rdata[list_num][31:0] = {list_hw[list_num],             // [31]    - HW
                                         list_ns[list_num],             // [30]    - Grp1 (non-secure)
                                         list_active[list_num],         // [29]    - State[1] (Active)
                                         list_pending[list_num],        // [28]    - State[0] (Pending)
                                         list_priority[list_num][4:0],  // [27:23] - Priority
                                         3'b000,                        // [22:20] - Reserved
                                         list_ei[list_num],             // [19]    - PhysicalID[9]/EOI
                                         list_phys_id[list_num][8:0],   // [18:10] - PhysicalID[8:0]  - PhysicalID/CPUID
                                         list_virt_id[list_num][9:0]};  // [9:0]   - VirtualID

  end endgenerate

  // Select the correct list read data.
  // - When the list registers are read, the bottom bits of the address specify
  //   which list register.
  always @* begin : g_list_rdata
    integer i;
    reg[31:0] list_muxed_rdata_tmp;
    list_muxed_rdata_tmp = 32'd0;

    for (i=0; i<4; i=i+1)
      list_muxed_rdata_tmp = list_muxed_rdata_tmp | ({32{p_rd_list_sel_i[i]}} & list_rdata[i][31:0]);

    list_muxed_rdata = list_muxed_rdata_tmp;
  end

  // These are the architectural definitions. Note: list_ei = EI & ~HW bits.
  assign list_eoi_int_status_bits = ~list_active[3:0] & ~list_pending[3:0] &  list_ei[3:0];
  assign list_empty_status_bits   = ~list_active[3:0] & ~list_pending[3:0] & ~list_ei[3:0];

  //---------------------------------------------------------------------------
  // Calculate Highest Priority Pending Interrupt -> HPPI
  //---------------------------------------------------------------------------

  // Select the highest priority pending interrupt. When multiple interrupts
  // have the highest priority, the one corresponding the largest numbered
  // list entry will be selected.

  assign list_pending_valid = list_pending[3:0] & ~list_active[3:0];

  // - Select the highest priority pending interrupt from the bottom pair 
  // of list registers
  assign list01_is0           = list_pending_valid[0] & (~list_pending_valid[1] | list_priority[0][4:0] < list_priority[1][4:0]);

  assign list01_virt_id[9:0]  = list01_is0 ? list_virt_id[0][9:0]  : list_virt_id[1][9:0];
  assign list01_priority[4:0] = list01_is0 ? list_priority[0][4:0] : list_priority[1][4:0];
  assign list01_ns            = list01_is0 ? list_ns[0]            : list_ns[1];

  // - Select the highest priority pending interrupt from the top pair of
  // list registers
  assign list23_is2           = list_pending_valid[2] & (~list_pending_valid[3] | list_priority[2][4:0] < list_priority[3][4:0]);

  assign list23_virt_id[9:0]  = list23_is2 ? list_virt_id[2][9:0]  : list_virt_id[3][9:0];
  assign list23_priority[4:0] = list23_is2 ? list_priority[2][4:0] : list_priority[3][4:0];
  assign list23_ns            = list23_is2 ? list_ns[2]            : list_ns[3];

  // - Select between the top and bottom pairs
  assign list01_is_pending    = |list_pending_valid[1:0];
  assign list23_is_pending    = |list_pending_valid[3:2];
  assign list_is01            = list01_is_pending & (~list23_is_pending | list01_priority[4:0] < list23_priority[4:0]);

  // - Select the highest priority pending interrupt data
  // Note: When a deactivate happens, it takes a cycle longer to feed through
  // this priority logic than other logic. So you can't see this on the
  // interrupt outputs, we suppress the valid bit. The stall logic prevents
  // this same problem from being apparent to AXI transactions.
  // For the int outputs, we don't care about ack, as it can only give rise to
  // old info, as opposed to deactivate, which can cause spurious info.
  assign hppi_valid           = |list_pending_valid[3:0] & ~deactivate_en;
  assign hppi_sel[3:0]        = {~list_is01 & ~list23_is2,
                                 ~list_is01 & list23_is2,
                                 list_is01 & ~list01_is0,
                                 list_is01 & list01_is0};
  assign hppi_virt_id[9:0]    = list_is01 ? list01_virt_id[9:0]  : list23_virt_id[9:0];
  assign hppi_priority[4:0]   = list_is01 ? list01_priority[4:0] : list23_priority[4:0];
  assign hppi_ns              = list_is01 ? list01_ns            : list23_ns;

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      hppi_valid_q <= 1'b0;
    else
      hppi_valid_q <= hppi_valid;

  always @(posedge clk_p)
    if (hppi_valid) begin
      hppi_virt_id_q  <= hppi_virt_id;
      hppi_priority_q <= hppi_priority;
      hppi_ns_q       <= hppi_ns;
      hppi_sel_q      <= hppi_sel;
    end


  //---------------------------------------------------------------------------
  // Maintenance interrupts logic
  //---------------------------------------------------------------------------

  assign list_active_or_pending[3:0] = list_active[3:0] | list_pending[3:0];

  // Only one list entry is active or pending or active+pending
  assign only_one_valid_list = (list_active_or_pending[3:0] == 4'b0001) |
                               (list_active_or_pending[3:0] == 4'b0010) |
                               (list_active_or_pending[3:0] == 4'b0100) |
                               (list_active_or_pending[3:0] == 4'b1000);

  // Underflow interrupt when no list entries are valid
  assign no_valid_list  = list_active_or_pending[3:0] == 4'b0000;

  // No Pending interrupt when no list entries are pending
  assign no_pending_list = list_pending_valid == 4'b0000;

  // If any list register has EI bit set and list entry is invalid
  assign list_ei_and_invalid = |(list_ei[3:0] & ~(list_active[3:0] | list_pending[3:0]));

  // Maintenance interrupt request
  assign maintenance_irq_o = (underflow_irq_en_q & (no_valid_list | only_one_valid_list)         |  // UIE
                              skid_irq_en_q      & (|eoi_count_q[4:0])                           |  // SKIDIE
                              nopend_irq_en_q    &  no_pending_list                              |  // NPIE
                              list_ei_and_invalid                                                |  // EI set & INVALID
                              vmen_s_irq_en_q    &  vm_en_s_q                                    |  // VESIE  &  VMEn
                              vmdis_s_irq_en_q   & ~vm_en_s_q                                    |  // VDSIE  & ~VMEn
                              vmen_ns_irq_en_q   &  vm_en_ns_q                                   |  // VENSIE &  VMNSEn
                              vmdis_ns_irq_en_q  & ~vm_en_ns_q                                      // VDNSIE & ~VMNSEn
                             ) & virt_en_q;

  // Maintenance Interrupt Status Register
  assign misr_vdnsi =  vmdis_ns_irq_en_q  & ~vm_en_ns_q;                           // VDNSIE set & VMNSEn clear
  assign misr_vensi =  vmen_ns_irq_en_q   &  vm_en_ns_q;                           // VENSIE set & VMNSEn set
  assign misr_vdsi  =  vmdis_s_irq_en_q   & ~vm_en_s_q;                            // VDSIE  set & VMSEn clear
  assign misr_vesi  =  vmen_s_irq_en_q    &  vm_en_s_q;                            // VESIE  set & VMSEn set
  assign misr_npi   =  nopend_irq_en_q    &  no_pending_list;                      // NPIE   set & no List Reg is in PENDING state
  assign misr_skidi =  skid_irq_en_q      & (|eoi_count_q[4:0]);                   // SKIDIE set & EOICount is non-zero
  assign misr_ui    =  underflow_irq_en_q & (no_valid_list | only_one_valid_list); // UIE    set & 0-1 List Reg contains a valid interrupt
  assign misr_ei    =                       |list_eoi_int_status_bits[3:0];        // at least one List Reg is asserting an EOI interrupt

  assign maint_int_status_reg[31:0] = {{24{1'b0}}, misr_vdnsi, misr_vensi, misr_vdsi, misr_vesi,
                                                   misr_npi, misr_skidi, misr_ui, misr_ei};


  //---------------------------------------------------------------------------
  // Get mask for current hppi
  //---------------------------------------------------------------------------

  assign hppi_priority_mask[31:0] = 32'h00000001 << hppi_priority_q[4:0];

  assign highest_active_priority_mask[31:0] = priority_filter(active_priorities_q[31:0]);
  assign active_irq_priority[4:0]           = priority_encode(active_priorities_q[31:0]);  // Binary version of highest_active_priority_mask
  assign active_irq_valid                   = |active_priorities_q[31:0];


  //---------------------------------------------------------------------------
  // Active Priorities Register
  //---------------------------------------------------------------------------

  // Note that the input to active_priorities depends on hppi_*_q signals,
  // which are only valid from one cycle after a read or write changes the
  // list state. This does not pose a problem however, because:
  // - When the active priorities register is updated on an Ack read, there
  //   cannot have been a change to the list state in the previous cycle,
  //   otherwise the Ack would be blocked.
  // - Although the active priorities register can be written on the cycle
  //   after the list state is updated by a read, the new value is not
  //   dependent on any hppi_*_q signals in this case.

  assign active_priorities_en = (p_read_i & p_rd_front_i & interrupt_valid &
                                 ((p_rd_ack_ns_alias_front_i & hppi_ns_q) |
                                  (p_rd_ack_front_i          & (~hppi_ns_q | vm_ack_ctl_q)))) |
                                (p_write_i &
                                 (p_wr_front_i ? (p_wr_active_priorities_front_i |
                                                  p_wr_eoi_front_i |
                                                  p_wr_eoi_ns_alias_front_i)
                                               : p_wr_active_priorities_back_i));

  assign nxt_active_priorities[31:0]
     = p_write_i ? ((~p_wr_front_i |
                     p_wr_active_priorities_front_i) ? p_wdata_i[31:0]
                                                     : (active_priorities_q[31:0] & ~highest_active_priority_mask[31:0]))
                 : (active_priorities_q[31:0] | hppi_priority_mask[31:0]);

  always @(posedge clk_p or negedge reset_n)
    if (!reset_n)
      active_priorities_q[31:0] <= {32{1'b0}};
    else if (active_priorities_en)
      active_priorities_q[31:0] <= nxt_active_priorities[31:0];


  //---------------------------------------------------------------------------
  // Binary point dec
  //---------------------------------------------------------------------------

  // Note that the binary point registers can never be written to an
  // unsupported value, so these do not need to be decoded.

  always @*
    case(vm_bp_s_q[2:0])
      3'b010:  binary_point_decoded_s[4:0] = 5'b11111;
      3'b011:  binary_point_decoded_s[4:0] = 5'b11110;
      3'b100:  binary_point_decoded_s[4:0] = 5'b11100;
      3'b101:  binary_point_decoded_s[4:0] = 5'b11000;
      3'b110:  binary_point_decoded_s[4:0] = 5'b10000;
      3'b111:  binary_point_decoded_s[4:0] = 5'b00000;
      default: binary_point_decoded_s[4:0] = {5{1'bx}};
    endcase

  always @*
    case(vm_bp_ns_q[2:0])
      3'b011:  binary_point_decoded_ns[4:0] = 5'b11111;
      3'b100:  binary_point_decoded_ns[4:0] = 5'b11110;
      3'b101:  binary_point_decoded_ns[4:0] = 5'b11100;
      3'b110:  binary_point_decoded_ns[4:0] = 5'b11000;
      3'b111:  binary_point_decoded_ns[4:0] = 5'b10000;
      default: binary_point_decoded_ns[4:0] = {5{1'bx}};
    endcase

  assign binary_point_decoded[4:0] = (vm_sbpr_q | ~hppi_ns_q) ? binary_point_decoded_s[4:0] :
                                                                binary_point_decoded_ns[4:0];

  assign masked_active_priority[4:0] = active_irq_priority[4:0] & binary_point_decoded[4:0];


  //---------------------------------------------------------------------------
  // Interrupt generation (Note: preemption only on 32 levels (5 high bits))
  //---------------------------------------------------------------------------

  assign pending_can_be_sent =   hppi_valid_q     & (hppi_priority_q[4:0] < vm_priority_mask_q[4:0]) &
                               (~active_irq_valid | (hppi_priority_q[4:0] < masked_active_priority[4:0])) &
                                 virt_en_q;

  assign interrupt_valid = pending_can_be_sent & (vm_en_s_q  & ~hppi_ns_q |
                                                  vm_en_ns_q &  hppi_ns_q);

  assign irq_valid = pending_can_be_sent & (vm_en_s_q  & ~hppi_ns_q & ~vm_fiq_en_q |
                                            vm_en_ns_q &  hppi_ns_q);

  assign fiq_valid = pending_can_be_sent &  vm_en_s_q  & ~hppi_ns_q &  vm_fiq_en_q;

  // VIRQ & VFIQ requests
  assign nxt_nvirq = ~irq_valid;
  assign nxt_nvfiq = ~fiq_valid;

  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      nvirq_q <= 1'b1;
      nvfiq_q <= 1'b1;
    end else begin
      nvirq_q <= nxt_nvirq;
      nvfiq_q <= nxt_nvfiq;
    end

  assign nvirq_o = nvirq_q;
  assign nvfiq_o = nvfiq_q;


  //----------------------------------------------------------------------------
  // Real EOI to distributor
  //----------------------------------------------------------------------------

  assign deactivate_en = p_write_i & p_wr_front_i &
                         (vm_eoimode_q ? p_wr_deactivate_front_i
                                       : (p_wr_eoi_front_i | p_wr_eoi_ns_alias_front_i));

  assign deactivate_o = deactivate_en & (|list_send_deactivate[3:0]);

  // Select the correct deactivate ID. Note that when the deactivate/EOI
  // registers are written, the list register is selected by the virtual ID
  // specified in the lower 10-bits of the write data. The ID between blocks
  // is muxed at the top level, so it doesn't matter if the output is unknown
  // when not valid.

  assign eoi_virt_id_match[3:0] = { (p_wdata_i[9:0] == list_virt_id[3]),
                                    (p_wdata_i[9:0] == list_virt_id[2]),
                                    (p_wdata_i[9:0] == list_virt_id[1]),
                                    (p_wdata_i[9:0] == list_virt_id[0]) };

  assign deactivate_id_o[8:0] = ({9{eoi_virt_id_match[0] & list_active[0]}} & list_phys_id[0][8:0]) |
                                ({9{eoi_virt_id_match[1] & list_active[1]}} & list_phys_id[1][8:0]) |
                                ({9{eoi_virt_id_match[2] & list_active[2]}} & list_phys_id[2][8:0]) |
                                ({9{eoi_virt_id_match[3] & list_active[3]}} & list_phys_id[3][8:0]);

  //----------------------------------------------------------------------------
  // Reads from back end
  //----------------------------------------------------------------------------

  assign hyp_control_reg[31:0] = {eoi_count_q[4:0], {19{1'b0}},
                                  vmdis_ns_irq_en_q, vmen_ns_irq_en_q, vmdis_s_irq_en_q, vmen_s_irq_en_q,
                                  nopend_irq_en_q, skid_irq_en_q, underflow_irq_en_q, virt_en_q};

  assign vm_control_alias_reg[31:0] = {vm_priority_mask_q[4:0], 3'b000, vm_bp_s_q[2:0], vm_bp_ns_q[2:0], {8{1'b0}},
                                       vm_eoimode_q, 4'b0000, vm_sbpr_q, vm_fiq_en_q, vm_ack_ctl_q,
                                       vm_en_ns_q, vm_en_s_q};

  assign vgic_type_reg[31:0] = {32'h90000003};   // [31:29] = PRIbits = 3'b100
                                                 // [28:26] = PREbits = 3'b100
                                                 // [25:6]  = Reserved
                                                 // [5:0]   = ListRegs = 6'b00_0011

  assign p_rdata_back[31:0] = ({32{p_rd_hyp_control_back_i}}       & hyp_control_reg[31:0])      |
                              ({32{p_rd_vgic_type_back_i}}         & vgic_type_reg[31:0])        |
                              ({32{p_rd_vm_control_alias_back_i}}  & vm_control_alias_reg[31:0]) |
                              ({32{p_rd_maint_int_status_back_i}}  & maint_int_status_reg[31:0]) |
                              ({32{p_rd_eoi_int_status_back_i}}    & {{28{1'b0}}, list_eoi_int_status_bits[3:0]}) |
                              ({32{p_rd_empty_list_status_back_i}} & {{28{1'b0}}, list_empty_status_bits[3:0]}) |
                              ({32{p_rd_active_priorities_back_i}} & active_priorities_q[31:0]) |
                              ({32{p_rd_list_back_i}}              & list_muxed_rdata[31:0]);

  //----------------------------------------------------------------------------
  // Reads from front end
  //----------------------------------------------------------------------------

  assign cpuid[2:0]  = {3{hppi_sel_q[0]  & ~list_hw[0]}} & list_phys_id[0][2:0] |
                       {3{hppi_sel_q[1]  & ~list_hw[1]}} & list_phys_id[1][2:0] |
                       {3{hppi_sel_q[2]  & ~list_hw[2]}} & list_phys_id[2][2:0] |
                       {3{hppi_sel_q[3]  & ~list_hw[3]}} & list_phys_id[3][2:0];

  assign p_rdata_ack[12:0] = {13{ interrupt_valid   & (~hppi_ns_q |  vm_ack_ctl_q)}} & {cpuid[2:0], hppi_virt_id_q[9:0]} |
                             {13{ interrupt_valid   & ( hppi_ns_q & ~vm_ack_ctl_q)}} & 13'h03fe |
                             {13{~interrupt_valid}} & 13'h03ff;

  assign p_rdata_ack_ns_alias[12:0]
                           = {13{ interrupt_valid &  hppi_ns_q}} & {cpuid[2:0], hppi_virt_id_q[9:0]} |
                             {13{~interrupt_valid | ~hppi_ns_q}} & 13'h03ff;

  assign p_rdata_priority[7:0] = {active_irq_priority[4:0], 3'b000} | {8{~active_irq_valid}};  // Mask to 0xFF if not valid

  assign p_rdata_hppi[12:0] = {13{ hppi_valid_q   & (~hppi_ns_q |  vm_ack_ctl_q)}} & {cpuid[2:0], hppi_virt_id_q[9:0]} |
                              {13{ hppi_valid_q   & ( hppi_ns_q & ~vm_ack_ctl_q)}} & 13'h03fe |
                              {13{~hppi_valid_q}} & 13'h03ff;

  assign p_rdata_hpi_ns_alias[12:0] = {13{ hppi_valid_q &  hppi_ns_q}} & {cpuid[2:0], hppi_virt_id_q[9:0]} |
                                      {13{~hppi_valid_q | ~hppi_ns_q}} & 13'h03ff;

  assign p_rdata_front[31:0] = ({32{p_rd_vm_control_front_i}}            & vm_control_reg[31:0])                          |
                               ({32{p_rd_priority_mask_front_i}}         & {{24{1'b0}}, vm_priority_mask_q[4:0], 3'b000}) |
                               ({32{p_rd_binary_point_front_i}}          & {{29{1'b0}}, vm_bp_s_q[2:0]})                  |
                               ({32{p_rd_ack_front_i}}                   & {{19{1'b0}}, p_rdata_ack[12:0]})               |
                               ({32{p_rd_running_priority_front_i}}      & {{24{1'b0}}, p_rdata_priority[7:0]})           |
                               ({32{p_rd_highest_pending_front_i}}       & {{19{1'b0}}, p_rdata_hppi[12:0]})              |
                               ({32{p_rd_binary_point_ns_alias_front_i}} & {{29{1'b0}}, vm_bp_ns_q[2:0]})                 |
                               ({32{p_rd_ack_ns_alias_front_i}}          & {{19{1'b0}}, p_rdata_ack_ns_alias[12:0]})      |
                               ({32{p_rd_hpi_ns_alias_front_i}}          & {{19{1'b0}}, p_rdata_hpi_ns_alias[12:0]})      |
                               ({32{p_rd_active_priorities_front_i}}     & active_priorities_q[31:0]);


  //----------------------------------------------------------------------------
  // Final read
  //----------------------------------------------------------------------------

  // - Needs qualifying with VCPU interface being selected, and source CPU at
  // top level
  assign p_rdata_o[31:0] = p_rd_front_i ? p_rdata_front[31:0] : p_rdata_back[31:0];


  //------------------------------------------------------------------------------
  // OVL assertions
  //------------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  `include "std_ovl_defines.h"

  // The binary point registers cannot be written to unsupported values, so
  // these do not need to be decoded.
  // - vm_bp_s_q
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"vm_bp_s_q was set to an unsupported value")
  ovl_vm_bp_s_valid   (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr ((vm_bp_s_q[2:0] == 3'b000) | 
                                   (vm_bp_s_q[2:0] == 3'b001)));

  // - vm_bp_ns_q
  assert_never #(`OVL_FATAL,`OVL_ASSERT,"vm_bp_ns_q was set to an unsupported value")
  ovl_vm_bp_ns_valid  (.clk       (clk),
                       .reset_n   (reset_n),
                       .test_expr ((vm_bp_ns_q[2:0] == 3'b000) | 
                                   (vm_bp_ns_q[2:0] == 3'b001) | 
                                   (vm_bp_ns_q[2:0] == 3'b010)));

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

  // When the active_priorities register is updated on an Ack, it looks at
  // the hppi_*_q signals. As updates to these signals take an extra cycle to
  // take effect from the list registers being updated, the registers must
  // not be out of date on the cycle the active_priorities register is
  // updated.
  // Note that this does not apply to updates to the active_priorities
  // register caused by writes, as these do not factor in the hppi signals.
  
  wire iar_read = p_read_i & p_rd_front_i & (p_rd_ack_ns_alias_front_i | p_rd_ack_front_i);

  assert_unchange #(`OVL_FATAL,1,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT,
                    "hppi_valid_q changed on the cycle after an active_priories write")
  ovl_hppi_valid_unchange  (.clk              (clk),
                            .reset_n          (reset_n),
                            .start_event      (iar_read),
                            .test_expr        (hppi_valid_q));

  assert_unchange #(`OVL_FATAL,10,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT,
                    "hppi_virt_id_q changed on the cycle after an active_priories write")
  ovl_hppi_id_unchange     (.clk              (clk),
                            .reset_n          (reset_n),
                            .start_event      (iar_read & hppi_valid_q),
                            .test_expr        (hppi_virt_id_q[9:0]));

  assert_unchange #(`OVL_FATAL,5,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT,
                    "hppi_priority_q changed on the cycle after an active_priories write")
  ovl_hppi_pri_unchange    (.clk              (clk),
                            .reset_n          (reset_n),
                            .start_event      (iar_read & hppi_valid_q),
                            .test_expr        (hppi_priority_q[4:0]));

  assert_unchange #(`OVL_FATAL,1,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT,
                    "hppi_ns_q changed on the cycle after an active_priories write")
  ovl_hppi_ns_unchange     (.clk              (clk),
                            .reset_n          (reset_n),
                            .start_event      (iar_read & hppi_valid_q),
                            .test_expr        (hppi_ns_q));

  assert_unchange #(`OVL_FATAL,4,1,`OVL_ERROR_ON_NEW_START,`OVL_ASSERT,
                    "hppi_sel_q changed on the cycle after an active_priories write")
  ovl_hppi_sel_unchange    (.clk              (clk),
                            .reset_n          (reset_n),
                            .start_event      (iar_read & hppi_valid_q),
                            .test_expr        (hppi_sel_q[3:0]));


  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: active_priorities_en")
  u_ovl_x_active_priorities_en (.clk       (clk_p),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (active_priorities_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: eoi_count_en")
  u_ovl_x_eoi_count_en (.clk       (clk_p),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (eoi_count_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: hppi_valid")
  u_ovl_x_hppi_valid (.clk       (clk_p),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (hppi_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: virt_en")
  u_ovl_x_virt_en (.clk       (clk_p),
                   .reset_n   (reset_n),
                   .qualifier (1'b1),
                   .test_expr (virt_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vm_bp_ns_en")
  u_ovl_x_vm_bp_ns_en (.clk       (clk_p),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (vm_bp_ns_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vm_bp_s_en")
  u_ovl_x_vm_bp_s_en (.clk       (clk_p),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (vm_bp_s_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vm_en")
  u_ovl_x_vm_en (.clk       (clk_p),
                 .reset_n   (reset_n),
                 .qualifier (1'b1),
                 .test_expr (vm_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: vm_priority_mask_en")
  u_ovl_x_vm_priority_mask_en (.clk       (clk_p),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (vm_priority_mask_en));


`endif

endmodule

