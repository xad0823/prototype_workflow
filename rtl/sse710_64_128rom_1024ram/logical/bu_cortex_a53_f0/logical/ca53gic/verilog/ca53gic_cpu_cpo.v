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
// Abstract: CortexA53 GIC CPU Interface CP Governor Request Control logic
//-----------------------------------------------------------------------------


`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gic_gov_defs.v"
`include "ca53_gov_dcu_defs.v"


module ca53gic_cpu_cpo (
  // Inputs
  input   wire                              clk,
  input   wire                              reset_n,
  input   wire  [(`CA53_CPADDR_W-1):0]      cp_gov_addr_i,
  input   wire                              cp_gov_ns_i,
  input   wire                              cp_gov_req_i,
  input   wire  [(`CA53_CPSEL_W-1):0]       cp_gov_sel_i,
  input   wire  [(`CA53_CPDATA_W-1):0]      cp_gov_wdata_i,
  input   wire                              cp_gov_wenable_i,
  input   wire                              deactivate_pending_i,
  input   wire                              generate_sgi_pending_i,
  input   wire  [(`CA53_CPDATA_W-1):0]      pcpu_rdata_i,
  input   wire                              send_generate_sgi_i,
  input   wire                              sre_el1_ns_i,
  input   wire                              sre_el1_s_i,
  input   wire                              sre_el2_i,
  input   wire                              upstream_wr_pending_i,
  input   wire  [(`CA53_CPDATA_W-1):0]      vcpu_rdata_i,
  // Outputs
  output  wire  [(`CA53_GICCP_W-2):0]       cp_addr_o,
  output  reg                               cp_gov_ns_rs_o,
  output  wire                              cp_gov_req_gic_o,
  output  wire  [(`CA53_GIC_ID_W-1):0]      cp_gov_wdata_rs_o,
  output  wire                              cp_gov_wenable_rs_o,
  output  wire                              cp_last_valid_o,
  output  wire                              cp_sys_o,
  output  wire                              cp_valid_o,
  output  wire                              cp_virtual_o,
  output  wire                              cp_wdata_lpi_id_o,
  output  wire                              cp_wdata_spurious_id_o,
  output  wire  [(`CA53_CPDATA_W-1):0]      cpo_wdata_o,
  output  wire                              gic_cp_ack_o,
  output  reg   [(`CA53_CPDATA_W-1):0]      gic_cp_rdata_o
);

  // ------------------------------------------------------
  // Reg declarations
  // ------------------------------------------------------

  reg   [(`CA53_GICCP_W-2):0]       cp_addr;
  reg                               cp_gov_addr_rs;
  reg   [(`CA53_GIC_ID_W-1):0]      cp_gov_wdata_rs;
  reg                               cp_gov_wenable_rs;
  reg                               cp_last_valid;
  reg                               cp_sys;
  reg                               cp_valid;
  reg                               cp_virtual;
  reg                               gic_cp_ack;
  reg                               request_accepted;
  reg                               stall_cpu_request;


  // ------------------------------------------------------
  // Wire declarations
  // ------------------------------------------------------

  wire  [(`CA53_GICCP_W-1):0]       addr_gicc_0;
  wire  [(`CA53_GICCP_W-1):0]       addr_gicc_1;
  wire  [(`CA53_GICCP_W-1):0]       addr_gich_0;
  wire  [(`CA53_GICCP_W-1):0]       addr_gicv_0;
  wire  [(`CA53_GICCP_W-1):0]       addr_gicv_1;
  wire  [(`CA53_GICCP_W-1):0]       addr_mem;
  wire                              cp_gov_req_gic;
  wire                              cp_start_request;
  wire                              cp_start_write_request;
  wire                              cp_wdata_lpi_id;
  wire                              cp_wdata_spurious_id;
  wire                              gicc_page_0_valid;
  wire                              gicc_page_1_valid;
  wire                              gich_page_0_valid;
  wire                              gicv_page_0_valid;
  wire                              gicv_page_1_valid;
  wire                              ignore_requests;
  wire  [(`CA53_GICCP_W-2):0]       nxt_cp_addr;
  wire  [(`CA53_GIC_ID_W-1):0]      nxt_cp_gov_wdata_rs;
  wire                              nxt_cp_virtual;
  wire                              nxt_gic_cp_ack;
  wire  [(`CA53_CPDATA_W-1):0]      nxt_gic_cp_rdata;
  wire                              nxt_request_accepted;
  wire                              nxt_stall_cpu_request;
  wire                              rdata_low_en;
  wire                              rdata_high_en;
  wire                              sel_gic_memory_mapped;
  wire                              sel_gic_system_register;
  wire  [((`CA53_CPDATA_W>>1)-1):0] wdata_lower;


  // ------------------------------------------------------
  // Memory Mapped Address Compression
  // ------------------------------------------------------

  // Memory mapped physical addresses are compressed for accesses to either
  // the Phyiscal CPU or the Virtual CPU.  The address generation allows for
  // operations to be re-routed during encoding.  Additionally, depending on
  // SRE configurations, operations may become no-ops.  The encoding is
  // performed in two steps, 1. decode 4K page offsets, 2. verify the
  // selected 4K page is valid.

  assign addr_gicc_0  = ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_ABPR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_ABPR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_AEOIR}}  & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_AEOIR} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_AHPPIR}} & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_AHPPIR} )  |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_AIAR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_AIAR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_APR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_APR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_BPR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_BPR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_CTLR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_CTLR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_EOIR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_EOIR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_HPPIR}}  & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_HPPIR} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_IAR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_IAR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_IIDR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_IIDR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_PMR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_PMR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_RPR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_RPR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_NSAPR}}  & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_NSAPR} );

  assign addr_gicc_1  = ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICC_ADR_DIR}}    & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_DIR} );

  assign addr_gich_0  = ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_APR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_APR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_EISR0}}  & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_EISR0} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_ELSR0}}  & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_ELSR0} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_HCR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_HCR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_LR0}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_LR0} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_LR1}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_LR1} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_LR2}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_LR2} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_LR3}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_LR3} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_MISR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_MISR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_VMCR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_VMCR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICH_ADR_VTR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICH_OP_VTR} );

  assign addr_gicv_0  = ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_ABPR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_ABPR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_AEOIR}}  & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_AEOIR} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_AHPPIR}} & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_AHPPIR} )  |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_AIAR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_AIAR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_APR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_APR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_BPR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_BPR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_CTLR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_CTLR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_EOIR}}   & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_EOIR} )    |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_HPPIR}}  & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_HPPIR} )   |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_IAR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_IAR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_PMR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_PMR} )     |
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_RPR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_RPR} )     |
                        // Virtual CPU Interface IIDR accesses are routed to the Physical CPU Interface
                        ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_IIDR}}   & {`CA53_GICREG_PCPU,2'b00,`CA53_GICC_OP_IIDR} );

  assign addr_gicv_1  = ( {`CA53_GICCP_W{cp_gov_addr_i[11:2] == `CA53_GICV_ADR_DIR}}    & {`CA53_GICREG_VCPU,1'b0 ,`CA53_GICV_OP_DIR} );

  // Qualify memory mapped pages
  assign gicc_page_0_valid = ( cp_gov_addr_i[17:12] == `CA53_GICC_PAGE_0 ) & ~sre_el1_s_i;
  assign gicc_page_1_valid = ( cp_gov_addr_i[17:12] == `CA53_GICC_PAGE_1 ) & ~sre_el1_s_i;
  assign gich_page_0_valid = ( cp_gov_addr_i[17:12] == `CA53_GICH_PAGE_0 ) & ~sre_el2_i;
  assign gicv_page_0_valid = ( ( cp_gov_addr_i[17:12] == `CA53_GICV_PAGE_0 ) | ( cp_gov_addr_i[17:12] == `CA53_GICV_PAGE_0_ALIAS ) ) & ~sre_el1_ns_i;
  assign gicv_page_1_valid = ( ( cp_gov_addr_i[17:12] == `CA53_GICV_PAGE_1 ) | ( cp_gov_addr_i[17:12] == `CA53_GICV_PAGE_1_ALIAS ) ) & ~sre_el1_ns_i;

  // Encoded memory mapped address
  assign addr_mem = ( {`CA53_GICCP_W{gicc_page_0_valid}} & addr_gicc_0 ) |
                    ( {`CA53_GICCP_W{gicc_page_1_valid}} & addr_gicc_1 ) |
                    ( {`CA53_GICCP_W{gich_page_0_valid}} & addr_gich_0 ) |
                    ( {`CA53_GICCP_W{gicv_page_0_valid}} & addr_gicv_0 ) |
                    ( {`CA53_GICCP_W{gicv_page_1_valid}} & addr_gicv_1 );

  // Select line decoding
  assign sel_gic_memory_mapped    = ( cp_gov_sel_i == `CA53_GIC_DCU_MEM );
  assign sel_gic_system_register  = ( cp_gov_sel_i == `CA53_GIC_DCU_SYS );
  assign cp_gov_req_gic           = cp_gov_req_i & ( sel_gic_memory_mapped | sel_gic_system_register );

  // Select encoded memory mapped address or pre-encoded system register access
  assign { nxt_cp_virtual , nxt_cp_addr } = sel_gic_memory_mapped ? addr_mem : cp_gov_addr_i[(`CA53_GICCP_W-1):0];


  // ------------------------------------------------------
  // Request Control
  // ------------------------------------------------------

  // Some packets have a one-to-one relationship with CPU accesses and can be
  // sent after a request has completed.  If packets from the last request
  // are still being sent then the new request must be ignored.

  assign ignore_requests  = deactivate_pending_i |
                            upstream_wr_pending_i;

  assign cp_start_request =  cp_gov_req_gic &
                            ~request_accepted &
                            ~ignore_requests;


  assign cp_start_write_request = cp_start_request & cp_gov_wenable_i;

  assign nxt_request_accepted = cp_gov_req_gic & ( request_accepted | ~ignore_requests );

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      request_accepted <= 1'b0;
    end else begin
      request_accepted <= nxt_request_accepted;
    end

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      cp_valid      <= 1'b0;
      cp_last_valid <= 1'b0;
    end else if ( cp_gov_req_gic ) begin
      cp_valid      <= cp_start_request;
      cp_last_valid <= cp_valid;
    end

  // A request is considered complete on the same cycle as the read data is
  // available.  However, some operations require the request write data to be
  // sent in a packet payload.  In such cases a completed request is stalled
  // until the data can be registered in a packet payload.

  assign nxt_stall_cpu_request = generate_sgi_pending_i | send_generate_sgi_i;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      stall_cpu_request <= 1'b0;
    end else if ( cp_gov_req_gic ) begin
      stall_cpu_request <= nxt_stall_cpu_request;
    end

  assign nxt_gic_cp_ack = ( cp_valid | stall_cpu_request ) & ~nxt_stall_cpu_request;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      gic_cp_ack <= 1'b0;
    end else if ( cp_gov_req_gic ) begin
      gic_cp_ack <= nxt_gic_cp_ack;
    end


  // ------------------------------------------------------
  // Input Register Slice
  // ------------------------------------------------------

  // Write data alignment is required for memory mapped accesses
  assign nxt_cp_gov_wdata_rs = ( cp_gov_addr_i[2] & ~sel_gic_system_register ) ? cp_gov_wdata_i[47:32] : cp_gov_wdata_i[15:0];

  always @ ( posedge clk )
    if ( cp_start_request ) begin
      cp_addr           <= nxt_cp_addr;
      cp_gov_addr_rs    <= cp_gov_addr_i[2];
      cp_gov_ns_rs_o    <= cp_gov_ns_i;
      cp_gov_wenable_rs <= cp_gov_wenable_i;
      cp_sys            <= sel_gic_system_register;
      cp_virtual        <= nxt_cp_virtual;
    end

  always @ ( posedge clk )
    if ( cp_start_write_request ) begin
      cp_gov_wdata_rs <= nxt_cp_gov_wdata_rs;
    end

  // The CP write data contains an interrupt ID in the LPI Range, i.e. ID > 8191
  assign cp_wdata_lpi_id = |cp_gov_wdata_rs[15:13];

  // The CP write data contains an interrupt ID that is a Spurious ID.
  // - Spurious ID = { {3{1'b0} , {3{1'bx}} {8{1'b1}} , {2{1'bx}} }
  assign cp_wdata_spurious_id = ( ~|cp_gov_wdata_rs[15:13] ) & ( &cp_gov_wdata_rs[9:2] );

  assign wdata_lower = ( cp_gov_addr_rs & ~cp_sys ) ? cp_gov_wdata_i[63:32] : cp_gov_wdata_i[31:0];


  // ------------------------------------------------------
  // Output Register Slice
  // ------------------------------------------------------

  // The output register slice is used to register the request read data from
  // the selected interface.  The read data registers are only clocked when
  // the request operation is a read operation, and for memory mapped
  // operations only half (based on alignment) of the registers need to be
  // clocked at a time.  For system register operations the data needs to
  // zero extended and both the lower and upper 32-bits are clocked.

  assign nxt_gic_cp_rdata = cp_virtual ? vcpu_rdata_i : pcpu_rdata_i;

  assign rdata_low_en     = cp_valid & ~cp_gov_wenable_rs & ( cp_sys | ~cp_gov_addr_rs );
  assign rdata_high_en    = cp_valid & ~cp_gov_wenable_rs & ( cp_sys |  cp_gov_addr_rs );

  always @ ( posedge clk )
    if ( rdata_low_en ) begin
      gic_cp_rdata_o[31:0] <= nxt_gic_cp_rdata[31:0];
    end

  always @ ( posedge clk )
    if ( rdata_high_en ) begin
      gic_cp_rdata_o[63:32] <= nxt_gic_cp_rdata[63:32];
    end


  //-------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------

  assign cp_addr_o              = cp_addr;
  assign cp_gov_req_gic_o       = cp_gov_req_gic;
  assign cp_gov_wdata_rs_o      = cp_gov_wdata_rs;
  assign cp_gov_wenable_rs_o    = cp_gov_wenable_rs;
  assign cp_last_valid_o        = cp_last_valid;
  assign cp_sys_o               = cp_sys;
  assign cp_valid_o             = cp_valid;
  assign cp_virtual_o           = cp_virtual;
  assign cp_wdata_lpi_id_o      = cp_wdata_lpi_id;
  assign cp_wdata_spurious_id_o = cp_wdata_spurious_id;
  assign cpo_wdata_o            = { cp_gov_wdata_i[63:32] , wdata_lower };
  assign gic_cp_ack_o           = gic_cp_ack;


  // ------------------------------------------------------
  // OVL definitions
  // ------------------------------------------------------

`ifdef ARM_ASSERT_ON

  reg ovl_last_gic_cp_ack;

  always @ ( posedge clk or negedge reset_n )
    if ( !reset_n ) begin
      ovl_last_gic_cp_ack <= 1'b0;
    end else begin
      ovl_last_gic_cp_ack <= gic_cp_ack;
    end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC can not accept back-to-back CPU requests")
  u_ovl_implication_single_cycle_valid (.clk             (clk),
                                        .reset_n         (reset_n),
                                        .antecedent_expr (cp_last_valid),
                                        .consequent_expr (~cp_valid));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "GIC can not acknowledge back-to-back CPU requests")
  u_ovl_implication_single_cycle_ack (.clk             (clk),
                                      .reset_n         (reset_n),
                                      .antecedent_expr (ovl_last_gic_cp_ack),
                                      .consequent_expr (~gic_cp_ack));


  // ------------------------------------------------------
  // Register enable X-check
  // ------------------------------------------------------

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_gov_req_gic")
  u_ovl_x_cp_gov_req_gic (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (cp_gov_req_gic));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_start_request")
  u_ovl_x_cp_start_request (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (cp_start_request));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp_start_write_request")
  u_ovl_x_cp_start_write_request (.clk       (clk),
                                  .reset_n   (reset_n),
                                  .qualifier (1'b1),
                                  .test_expr (cp_start_write_request));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rdata_high_en")
  u_ovl_x_rdata_high_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (rdata_high_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: rdata_low_en")
  u_ovl_x_rdata_low_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (rdata_low_en));

  // OVL_ASSERT_END

`endif


endmodule // u_ca53gic_cpu_cpo


`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53gic_defs.v"
`include "ca53_gic_gov_defs.v"
`include "ca53_gov_dcu_defs.v"
`undef CA53_UNDEFINE

