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
// Description:
//  The RAM control block interfaces to the L2 data RAMs.
//-----------------------------------------------------------------------------
//
`include "ca53scu_defs.v"
`include "cortexa53params.v"


module ca53scu_ramctl #(`CA53_SCU_INT_PARAM_DECL)
 (
  input  wire                                   clk,
  input  wire                                   reset_n,
  input  wire                                   DFTSE,
  input  wire                                   DFTRAMHOLD,
  input  wire                                   DFTMCPHOLD,

  input  wire                                   gov_l2deien_i,

  input  wire                                   ram_idle_count_max_i,
  output wire                                   ramctl_active_o,
  output wire                                   ramctl_awake_o,

  output wire                                   l2_dataram_no_acc_next_cycle_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]   l2_dataram_clken_o,
  output wire [`CA53_SCU_L2_DATARAM_EN_W-1:0]   l2_dataram_en_o,
  output wire                                   l2_dataram_wr_o,
  output wire [`CA53_SCU_L2_DATARAM_ADDR_W-1:0] l2_dataram_addr_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata0_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata1_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata2_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata3_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata4_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata5_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata6_o,
  output wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_wdata7_o,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata0_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata1_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata2_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata3_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata4_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata5_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata6_i,
  input  wire [`CA53_SCU_L2_DATARAM_DATA_W-1:0] l2_dataram_rdata7_i,
  input  wire [`CA53_L2_SIZE_W-1:0]             config_l2_size_i,

  output wire                                   ramctl_l2dbs_valid_o,
  output wire [3:0]                             ramctl_l2dbs_id_o,
  output wire [255:0]                           ramctl_l2dbs_data_o,
  output wire [1:0]                             ramctl_l2dbs_chunk_o,
  output wire                                   ramctl_l2dbs_err_o,
  output wire                                   ramctl_l2dbs_last_o,
  output wire                                   ramctl_l2dbs_bypass_o,
  output wire [3:0]                             ramctl_l2dbs_bypass_id_o,

  output wire [127:0]                           ramctl_bypass_data_o,
  output wire                                   ramctl_bypass_err_o,
  output wire                                   ramctl_bypassed_err_o,

  input  wire                                   l2db0_ramctl_valid_i,
  input  wire [1:0]                             l2db0_ramctl_rw_i,
  input  wire [7:0]                             l2db0_ramctl_banks_i,
  input  wire [255:0]                           l2db0_ramctl_data_i,
  input  wire [3:0]                             l2db0_ramctl_way_i,
  input  wire [10:0]                            l2db0_ramctl_index_i,
  input  wire                                   l2db0_ramctl_err_i,
  output wire                                   ramctl_l2db0_ready_o,

  input  wire                                   l2db1_ramctl_valid_i,
  input  wire [1:0]                             l2db1_ramctl_rw_i,
  input  wire [7:0]                             l2db1_ramctl_banks_i,
  input  wire [255:0]                           l2db1_ramctl_data_i,
  input  wire [3:0]                             l2db1_ramctl_way_i,
  input  wire [10:0]                            l2db1_ramctl_index_i,
  input  wire                                   l2db1_ramctl_err_i,
  output wire                                   ramctl_l2db1_ready_o,

  input  wire                                   l2db2_ramctl_valid_i,
  input  wire [1:0]                             l2db2_ramctl_rw_i,
  input  wire [7:0]                             l2db2_ramctl_banks_i,
  input  wire [255:0]                           l2db2_ramctl_data_i,
  input  wire [3:0]                             l2db2_ramctl_way_i,
  input  wire [10:0]                            l2db2_ramctl_index_i,
  input  wire                                   l2db2_ramctl_err_i,
  output wire                                   ramctl_l2db2_ready_o,

  input  wire                                   l2db3_ramctl_valid_i,
  input  wire [1:0]                             l2db3_ramctl_rw_i,
  input  wire [7:0]                             l2db3_ramctl_banks_i,
  input  wire [255:0]                           l2db3_ramctl_data_i,
  input  wire [3:0]                             l2db3_ramctl_way_i,
  input  wire [10:0]                            l2db3_ramctl_index_i,
  input  wire                                   l2db3_ramctl_err_i,
  output wire                                   ramctl_l2db3_ready_o,

  input  wire                                   l2db4_ramctl_valid_i,
  input  wire [1:0]                             l2db4_ramctl_rw_i,
  input  wire [7:0]                             l2db4_ramctl_banks_i,
  input  wire [255:0]                           l2db4_ramctl_data_i,
  input  wire [3:0]                             l2db4_ramctl_way_i,
  input  wire [10:0]                            l2db4_ramctl_index_i,
  input  wire                                   l2db4_ramctl_err_i,
  output wire                                   ramctl_l2db4_ready_o,

  input  wire                                   l2db5_ramctl_valid_i,
  input  wire [1:0]                             l2db5_ramctl_rw_i,
  input  wire [7:0]                             l2db5_ramctl_banks_i,
  input  wire [255:0]                           l2db5_ramctl_data_i,
  input  wire [3:0]                             l2db5_ramctl_way_i,
  input  wire [10:0]                            l2db5_ramctl_index_i,
  input  wire                                   l2db5_ramctl_err_i,
  output wire                                   ramctl_l2db5_ready_o,

  input  wire                                   l2db6_ramctl_valid_i,
  input  wire [1:0]                             l2db6_ramctl_rw_i,
  input  wire [7:0]                             l2db6_ramctl_banks_i,
  input  wire [255:0]                           l2db6_ramctl_data_i,
  input  wire [3:0]                             l2db6_ramctl_way_i,
  input  wire [10:0]                            l2db6_ramctl_index_i,
  input  wire                                   l2db6_ramctl_err_i,
  output wire                                   ramctl_l2db6_ready_o,

  input  wire                                   l2db7_ramctl_valid_i,
  input  wire [1:0]                             l2db7_ramctl_rw_i,
  input  wire [7:0]                             l2db7_ramctl_banks_i,
  input  wire [255:0]                           l2db7_ramctl_data_i,
  input  wire [3:0]                             l2db7_ramctl_way_i,
  input  wire [10:0]                            l2db7_ramctl_index_i,
  input  wire                                   l2db7_ramctl_err_i,
  output wire                                   ramctl_l2db7_ready_o,

  input  wire                                   l2db8_ramctl_valid_i,
  input  wire [1:0]                             l2db8_ramctl_rw_i,
  input  wire [7:0]                             l2db8_ramctl_banks_i,
  input  wire [255:0]                           l2db8_ramctl_data_i,
  input  wire [3:0]                             l2db8_ramctl_way_i,
  input  wire [10:0]                            l2db8_ramctl_index_i,
  input  wire                                   l2db8_ramctl_err_i,
  output wire                                   ramctl_l2db8_ready_o,

  input  wire                                   l2db9_ramctl_valid_i,
  input  wire [1:0]                             l2db9_ramctl_rw_i,
  input  wire [7:0]                             l2db9_ramctl_banks_i,
  input  wire [255:0]                           l2db9_ramctl_data_i,
  input  wire [3:0]                             l2db9_ramctl_way_i,
  input  wire [10:0]                            l2db9_ramctl_index_i,
  input  wire                                   l2db9_ramctl_err_i,
  output wire                                   ramctl_l2db9_ready_o,

  input  wire                                   l2db10_ramctl_valid_i,
  input  wire [1:0]                             l2db10_ramctl_rw_i,
  input  wire [7:0]                             l2db10_ramctl_banks_i,
  input  wire [255:0]                           l2db10_ramctl_data_i,
  input  wire [3:0]                             l2db10_ramctl_way_i,
  input  wire [10:0]                            l2db10_ramctl_index_i,
  input  wire                                   l2db10_ramctl_err_i,
  output wire                                   ramctl_l2db10_ready_o,

  input  wire                                   master_ramctl_valid_i,
  input  wire [3:0]                             master_ramctl_chunks_i,
  input  wire [255:0]                           master_ramctl_data_i,
  input  wire [3:0]                             master_ramctl_way_i,
  input  wire [10:0]                            master_ramctl_index_i,
  output wire                                   ramctl_master_ready_o,
  output wire                                   ramctl_master_accepted_o,

  input  wire                                   tagctl_ramctl_valid_i,
  input  wire                                   tagctl_ramctl_cancel_i,
  input  wire [10:0]                            tagctl_ramctl_index_i,
  input  wire [3:0]                             tagctl_ramctl_way_i,
  input  wire [3:0]                             tagctl_ramctl_l2db_i,
  input  wire [1:0]                             tagctl_ramctl_crit_chunk_i,
  input  wire [7:0]                             tagctl_ramctl_banks_i,
  input  wire                                   tagctl_ramctl_flush_i,
  output wire                                   ramctl_tagctl_ready_o,

  output wire                                   ramctl_mask_tc2_o,
  input  wire                                   tagctl_l2dataram_req_tc2_i,
  input  wire [10:0]                            tagctl_l2dataram_index_i,
  input  wire [15:0]                            tagctl_l2dataram_way_i,
  input  wire [7:0]                             tagctl_l2dataram_banks_i,

  input  wire                                   master_ramctl_active_i,
  input  wire                                   tagctl_ramctl_active_i,
  input  wire                                   cpuslv0_ramctl_active_i,
  input  wire                                   cpuslv1_ramctl_active_i,
  input  wire                                   cpuslv2_ramctl_active_i,
  input  wire                                   cpuslv3_ramctl_active_i,
  input  wire                                   acpslv_ramctl_active_i,
  input  wire                                   snpslv_ramctl_active_i,

  output wire                                   ramctl_ecc_flush_req_o,
  output wire                                   ramctl_ecc_flush_active_o,
  output wire [10:0]                            ramctl_ecc_flush_index_o,
  output wire [3:0]                             ramctl_ecc_flush_way_o,

  output wire                                   ramctl_err_valid_o,
  output wire                                   ramctl_err_fatal_o,
  output wire [14:0]                            ramctl_err_index_o,
  output wire [2:0]                             ramctl_err_bank_o,

  input  wire                                   gov_mbistreq_i,
  input  wire [`CA53_MBIST1_RAMARRAY_W-1:0]     gov_mbistarray1_i,
  input  wire                                   gov_mbistwriteen1_i,
  input  wire                                   gov_mbistreaden1_i,
  input  wire [`CA53_MBIST1_ADDR_W-1:0]         gov_mbistaddr1_i,
  input  wire [`CA53_MBIST1_BE_W-1:0]           gov_mbistbe1_i,
  input  wire                                   gov_mbistcfg1_i,
  input  wire [`CA53_MBIST1_DATA_W-1:0]         gov_mbistindata1_i,
  output wire                                   scu_mbistack1_o,
  output wire [`CA53_MBIST1_DATA_W-1:0]         scu_mbistoutdata1_o
);

  localparam RR_WIDTH = NUM_L2DBS + 2;
  localparam RR_MAX_WIDTH = MAX_L2DBS + 2;

  // The logic relies on the top bit being set during a RAM write, and not set during a read.
  localparam INPUT_STATE_IDLE         = 3'b000;
  localparam INPUT_STATE_READ_FLUSHED = 3'b001;
  localparam INPUT_STATE_READ_ENABLE  = 3'b010;
  localparam INPUT_STATE_READ_HOLD    = 3'b011;
  localparam INPUT_STATE_READ_WAIT1   = 3'b100;
  localparam INPUT_STATE_READ_WAIT2   = 3'b101;
  localparam INPUT_STATE_WRITE_ENABLE = 3'b110;
  localparam INPUT_STATE_WRITE_HOLD   = 3'b111;

  localparam OUTPUT_STATE_IDLE = 2'b00;
  localparam OUTPUT_STATE_DATA = 2'b01;
  localparam OUTPUT_STATE_CYC0 = 2'b10;
  localparam OUTPUT_STATE_CYC1 = 2'b11;

  localparam WRITE_STATE_IDLE  = 2'b00;
  localparam WRITE_STATE_DATA1 = 2'b01;
  localparam WRITE_STATE_DATA2 = 2'b10;
  localparam WRITE_STATE_WAIT  = 2'b11;

generate if (L2_CACHE) begin : g_l2cc
  //----------------------------------------------------------------------------
  //  Declarations
  //----------------------------------------------------------------------------

  genvar i;

  reg [2:0]                       ram_input_state;
  reg [1:0]                       ram_output_state;
  reg [1:0]                       write_state;
  reg                             l2_dataram_no_acc_next_cycle;
  reg [2:0]                       next_ram_input_state;
  reg [1:0]                       next_ram_output_state;
  reg [1:0]                       next_write_state;
  reg [1:0]                       input_rw;
  reg [7:0]                       input_banks;
  reg [10:0]                      input_index;
  reg [15:0]                      input_way;
  reg [4:0]                       input_late_en;
  reg [3:0]                       input_l2db;
  reg [1:0]                       input_crit_chunk;
  reg                             input_err;
  reg [511:0]                     write_data;
  reg [7:0]                       l2_databank_en;
  reg [511:0]                     read_data;
  reg [7:0]                       output_banks;
  reg [3:0]                       output_l2db;
  reg [1:0]                       output_crit_chunk;
  reg                             read_data_valid;
  reg                             read_data_last;
  reg [3:0]                       read_data_l2db;
  reg                             read_data_crit_chunk;
  reg                             clk_enable;
  reg                             scu_mbistack1;
  reg                             halfline_sel;

  wire                            clk_ramctl;
  wire                            next_clk_enable;
  wire [RR_MAX_WIDTH-1:0]         data_req;
  wire [RR_MAX_WIDTH-1:0]         data_req_mask;
  wire [RR_MAX_WIDTH:0]           data_arb;
  wire [RR_MAX_WIDTH-1:0]         req_ready;
  wire [RR_MAX_WIDTH-1:0]         half_line;
  wire [1:0]                      data_rw    [RR_MAX_WIDTH:0];
  wire [7:0]                      data_banks [RR_MAX_WIDTH:0];
  wire                            l2_dataram_no_acc_in_2cycles;
  wire                            ram_output_en;
  wire                            ramctl_active;
  wire                            data_req_arb;
  wire                            data_req_early_arb;
  wire [255:0]                    muxed_data;
  wire [1:0]                      muxed_rw;
  wire [10:0]                     muxed_index;
  wire [3:0]                      muxed_way;
  wire [7:0]                      muxed_banks;
  wire [3:0]                      muxed_chunks;
  wire                            muxed_err;
  wire [1:0]                      next_input_rw;
  wire [7:0]                      next_input_banks;
  wire [15:0]                     next_input_way;
  wire [4:0]                      next_input_late_en;
  wire [10:0]                     next_input_index;
  wire [1:0]                      next_input_crit_chunk;
  wire [3:0]                      input_way_enc;
  wire                            next_halfline_sel;
  wire [3:0]                      mbist_way;
  wire [3:0]                      data_arb_l2db;
  wire [15:0]                     input_l2db_onehot;
  wire [7:0]                      write_data_en;
  wire [511:0]                    next_write_data;
  wire [7:0]                      next_l2_databank_en;
  wire                            l2_databank_en_en;
  wire [1:0]                      mbist_bank_sel;
  wire [7:0]                      mbist_bank_en;
  wire [7:0]                      l2_bank_en;
  wire                            start_access;
  wire [7:0]                      read_data_en;
  wire [511:0]                    next_read_data;
  wire                            ram_output_valid;
  wire                            next_read_data_valid;
  wire                            next_read_data_last;
  wire [255:0]                    ramctl_l2dbs_data;
  wire                            repair_in_progress;
  wire                            input_ready;
  wire                            start_input;
  wire                            start_write_part;
  wire                            data_change_allowed;
  wire                            input_l2db_en;
  wire                            write_data_ready;
  wire                            muxed_write_single;
  wire                            start_write;
  wire                            ramctl_mask_tc2;

  //----------------------------------------------------------------------------
  // Regional clock gate
  //----------------------------------------------------------------------------

  // Avoid clocking the ramctl logic if it is not in use and there are no
  // requests in the slvs or L2DBs that might allocate it in the next cycle.
  assign next_clk_enable = ((ram_input_state != INPUT_STATE_IDLE) |
                            (ram_output_state != OUTPUT_STATE_IDLE) |
                            (write_state != WRITE_STATE_IDLE) |
                            read_data_valid |
                            repair_in_progress |
                            data_req_early_arb |
                            tagctl_ramctl_active_i |
                            master_ramctl_active_i |
                            cpuslv0_ramctl_active_i |
                            cpuslv1_ramctl_active_i |
                            cpuslv2_ramctl_active_i |
                            cpuslv3_ramctl_active_i |
                            acpslv_ramctl_active_i |
                            snpslv_ramctl_active_i |
                            gov_mbistreq_i);

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    clk_enable <= 1'b0;
  end else begin
    clk_enable <= next_clk_enable;
  end

  ca53_cell_inter_clkgate u_inter_clkgate_ramctl (
    .clk_i         (clk),
    .clk_enable_i  (clk_enable),
    .clk_senable_i (DFTSE),
    .clk_gated_o   (clk_ramctl));

  assign ramctl_awake_o = clk_enable;

  //----------------------------------------------------------------------------
  //  Access sequencing
  //----------------------------------------------------------------------------

  // Allow at most one new request every two cycles. If there is an input
  // latency cycle then the clk enable is sent a cycle later than all other data.
  // Accesses may be reads, writes, or an atomic read and write of the same
  // location.
  always @*
  begin
    next_ram_input_state = ram_input_state;
    case (ram_input_state)
      INPUT_STATE_IDLE: begin
        if (start_input) begin
          next_ram_input_state = next_input_rw[1] ? INPUT_STATE_READ_ENABLE : INPUT_STATE_WRITE_ENABLE;
        end
      end
      INPUT_STATE_READ_ENABLE: begin
        if (L2_INPUT_LATENCY) begin
          if (tagctl_ramctl_flush_i) begin
            next_ram_input_state = INPUT_STATE_READ_FLUSHED;
          end else begin
            next_ram_input_state = INPUT_STATE_READ_HOLD;
          end
        end else if (tagctl_ramctl_flush_i) begin
          if (L2_OUTPUT_LATENCY) begin
            // The output state machine won't get started if we flush, but we
            // must still prevent a new access from starting in the following
            // cycle.
            next_ram_input_state = INPUT_STATE_READ_FLUSHED;
          end else begin
            next_ram_input_state = INPUT_STATE_IDLE;
          end
        end else if (input_rw[0]) begin
          // Wait for the read to progress before starting the write part.
          if (L2_OUTPUT_LATENCY) begin
            next_ram_input_state = INPUT_STATE_READ_WAIT1;
          end else begin
            next_ram_input_state = INPUT_STATE_READ_WAIT2;
          end
        end else begin
          next_ram_input_state = INPUT_STATE_IDLE;
        end
      end
      INPUT_STATE_READ_FLUSHED,
      INPUT_STATE_READ_HOLD: begin
        // Hold all signals to the RAM for a second cycle.
        if (input_rw[0]) begin
          // Wait for the read to progress before starting the write part.
          if (L2_OUTPUT_LATENCY) begin
            next_ram_input_state = INPUT_STATE_READ_WAIT2;
          end else begin
            next_ram_input_state = INPUT_STATE_WRITE_ENABLE;
          end
        end else if (start_input) begin
          next_ram_input_state = next_input_rw[1] ? INPUT_STATE_READ_ENABLE : INPUT_STATE_WRITE_ENABLE;
        end else begin
          next_ram_input_state = INPUT_STATE_IDLE;
        end
      end
      INPUT_STATE_READ_WAIT1: begin
        next_ram_input_state = INPUT_STATE_READ_WAIT2;
      end
      INPUT_STATE_READ_WAIT2: begin
        next_ram_input_state = INPUT_STATE_WRITE_ENABLE;
      end
      INPUT_STATE_WRITE_ENABLE: begin
        // Enable the RAM. We are then ready for a new request.
        if (L2_INPUT_LATENCY) begin
          next_ram_input_state = INPUT_STATE_WRITE_HOLD;
        end else begin
          next_ram_input_state = INPUT_STATE_IDLE;
        end
      end
      INPUT_STATE_WRITE_HOLD: begin
        // Hold all signals to the RAM for a second cycle.
        if (start_input) begin
          next_ram_input_state = next_input_rw[1] ? INPUT_STATE_READ_ENABLE : INPUT_STATE_WRITE_ENABLE;
        end else begin
          next_ram_input_state = INPUT_STATE_IDLE;
        end
      end
      default: next_ram_input_state = 3'bxxx;
    endcase
  end

  // Count the number of cycles after the RAM is enabled, to determine when the
  // output data can be sampled.
  always @*
  begin
    next_ram_output_state = ram_output_state;
    case (ram_output_state)
      OUTPUT_STATE_IDLE,
      OUTPUT_STATE_DATA: begin
        if (ram_output_en) begin
          next_ram_output_state = L2_OUTPUT_LATENCY ? OUTPUT_STATE_CYC0 : OUTPUT_STATE_CYC1;
        end else begin
          next_ram_output_state = OUTPUT_STATE_IDLE;
        end
      end
      OUTPUT_STATE_CYC0: begin
        if (tagctl_ramctl_flush_i) begin
          next_ram_output_state = OUTPUT_STATE_IDLE;
        end else begin
          next_ram_output_state = OUTPUT_STATE_CYC1;
        end
      end
      OUTPUT_STATE_CYC1: begin
        if ((L2_OUTPUT_LATENCY == 0) &
            (L2_INPUT_LATENCY == 0) &
            tagctl_ramctl_flush_i) begin
          next_ram_output_state = OUTPUT_STATE_IDLE;
        end else begin
          next_ram_output_state = OUTPUT_STATE_DATA;
        end
      end
      default: next_ram_output_state = 2'bxx;
    endcase
  end

  always @(posedge clk_ramctl or negedge reset_n)
  if (~reset_n) begin
    ram_input_state  <= INPUT_STATE_IDLE;
    ram_output_state <= OUTPUT_STATE_IDLE;
  end else if (ramctl_active) begin
    ram_input_state  <= next_ram_input_state;
    ram_output_state <= next_ram_output_state;
  end

  // The input state machine will be ready to start a new request in the following cycle.
  assign input_ready = (((ram_input_state == INPUT_STATE_IDLE) |
                         (ram_input_state == INPUT_STATE_WRITE_HOLD) |
                         (((ram_input_state == INPUT_STATE_READ_FLUSHED) |
                           (ram_input_state == INPUT_STATE_READ_HOLD)) &
                          (L2_OUTPUT_LATENCY == 0) & ~input_rw[0])) &
                        ~((L2_INPUT_LATENCY == 0) & (ram_output_state == OUTPUT_STATE_CYC0)) &
                        ~repair_in_progress);

  // We must not allow the data (or other) inputs to the RAMs to change on some
  // cycles if input latency is enable.
  assign data_change_allowed = ((L2_INPUT_LATENCY == 0) |
                                ~((ram_input_state == INPUT_STATE_READ_ENABLE) |
                                  (ram_input_state == INPUT_STATE_WRITE_ENABLE)));

  // Start a new input request if it is either a read, a write that only writes
  // half a line or less, or a read and write where the second half of the write
  // can happen after the read has started.
  assign start_input = input_ready & (scu_mbistack1 ? (gov_mbistreaden1_i | gov_mbistwriteen1_i) :
                                      ((data_req_arb & (muxed_rw[1] | write_data_ready)) |
                                       data_arb[13]));

  // Start the write part of a read and write operation when the read part has
  // finished with the input.
  assign start_write_part = ((ram_input_state == INPUT_STATE_READ_WAIT2) |
                             ((ram_input_state == INPUT_STATE_READ_HOLD) &
                              input_rw[0] & (L2_OUTPUT_LATENCY == 0)));

  // Start a new RAM access.
  assign start_access = start_input | start_write_part;

  // The output state machine is enabled whenever the RAMs are being read.
  assign ram_output_en = ((ram_input_state == (L2_INPUT_LATENCY ? INPUT_STATE_READ_HOLD : INPUT_STATE_READ_ENABLE)) &
                          ~tagctl_ramctl_flush_i);

  assign ramctl_active = (data_req_early_arb |
                          tagctl_l2dataram_req_tc2_i |
                          (ram_input_state != INPUT_STATE_IDLE) |
                          (ram_output_state != OUTPUT_STATE_IDLE) |
                          read_data_valid |
                          scu_mbistack1);

  assign ramctl_active_o = ((ram_input_state != INPUT_STATE_IDLE) |
                            (ram_output_state != OUTPUT_STATE_IDLE) |
                            read_data_valid);

  always @(posedge clk_ramctl or negedge reset_n)
  if (~reset_n) begin
    scu_mbistack1 <= 1'b0;
  end else begin
    scu_mbistack1 <= gov_mbistreq_i;
  end

  assign scu_mbistack1_o = scu_mbistack1;

  //----------------------------------------------------------------------------
  //  Arbitration and RAM input
  //----------------------------------------------------------------------------

  // Collate input requests. These are masked out if we arbitrated a write in
  // the previous cycle and so require to arbitrate the same source this cycle
  // to get the rest of the write data.
  assign data_req = {l2db10_ramctl_valid_i,
                     l2db9_ramctl_valid_i,
                     l2db8_ramctl_valid_i,
                     l2db7_ramctl_valid_i,
                     l2db6_ramctl_valid_i,
                     l2db5_ramctl_valid_i,
                     l2db4_ramctl_valid_i,
                     l2db3_ramctl_valid_i,
                     l2db2_ramctl_valid_i,
                     l2db1_ramctl_valid_i,
                     l2db0_ramctl_valid_i,
                     master_ramctl_valid_i,
                     tagctl_ramctl_valid_i} & ~data_req_mask;

  assign data_rw[13] = 2'b10;
  assign data_rw[12] = l2db10_ramctl_rw_i;
  assign data_rw[11] = l2db9_ramctl_rw_i;
  assign data_rw[10] = l2db8_ramctl_rw_i;
  assign data_rw[9]  = l2db7_ramctl_rw_i;
  assign data_rw[8]  = l2db6_ramctl_rw_i;
  assign data_rw[7]  = l2db5_ramctl_rw_i;
  assign data_rw[6]  = l2db4_ramctl_rw_i;
  assign data_rw[5]  = l2db3_ramctl_rw_i;
  assign data_rw[4]  = l2db2_ramctl_rw_i;
  assign data_rw[3]  = l2db1_ramctl_rw_i;
  assign data_rw[2]  = l2db0_ramctl_rw_i;
  assign data_rw[1]  = 2'b01;
  assign data_rw[0]  = 2'b10;

  assign data_banks[13] = tagctl_l2dataram_banks_i;
  assign data_banks[12] = l2db10_ramctl_banks_i;
  assign data_banks[11] = l2db9_ramctl_banks_i;
  assign data_banks[10] = l2db8_ramctl_banks_i;
  assign data_banks[9]  = l2db7_ramctl_banks_i;
  assign data_banks[8]  = l2db6_ramctl_banks_i;
  assign data_banks[7]  = l2db5_ramctl_banks_i;
  assign data_banks[6]  = l2db4_ramctl_banks_i;
  assign data_banks[5]  = l2db3_ramctl_banks_i;
  assign data_banks[4]  = l2db2_ramctl_banks_i;
  assign data_banks[3]  = l2db1_ramctl_banks_i;
  assign data_banks[2]  = l2db0_ramctl_banks_i;
  assign data_banks[1]  ={{2{master_ramctl_chunks_i[3]}},
                          {2{master_ramctl_chunks_i[2]}},
                          {2{master_ramctl_chunks_i[1]}},
                          {2{master_ramctl_chunks_i[0]}}};
  assign data_banks[0]  = tagctl_ramctl_banks_i;

  // Select between requests on a round robin basis.
  ca53_rr_reg_arb #(.WIDTH(RR_WIDTH)) u_data_arb (
    .clk        (clk_ramctl),
    .reset_n    (reset_n),
    .enable_i   (start_input),
    .requests_i (data_req[RR_WIDTH-1:0]),
    .arb_o      (data_arb[RR_WIDTH-1:0])
  );

  for (i = RR_WIDTH; i < RR_MAX_WIDTH; i = i + 1) begin : g_data_arb
    // Tie-offs for unused L2DBs
    assign data_arb[i] = 1'b0;
  end

  // If nothing else is requesting arbitration then grant access to any
  // speculative tc2 request.
  assign data_arb[RR_MAX_WIDTH] = tagctl_l2dataram_req_tc2_i & ~ramctl_mask_tc2;

  // If tagctl got arbitrated but it didn't really want to make an access then
  // nothing can make an access, otherwise if there is any request then one of
  // them will get arbitrated.
  assign data_req_arb = data_arb[0] ? ~tagctl_ramctl_cancel_i : |data_req[12:1];

  assign data_req_early_arb = |data_req;

  // The last (or only) part of a write can only be accepted when the input
  // state machine is ready, as we need to capture the information about the
  // request. If two halflines of data are provided, then the first can be
  // accepted before the RAMs are ready, provided that they are not holding
  // the inputs because of the latency configuration.
  // If doing a read and write, then the first half can only be accepted when
  // the input state machine is ready, and the second part will be accepted
  // after the read has started.

  for (i = 0; i < RR_MAX_WIDTH; i = i + 1) begin : g_arb_ready

    assign half_line[i] = ~|data_banks[i][7:4] | ~|data_banks[i][3:0];

    assign req_ready[i] = ((start_write_part |
                            (input_ready & (data_rw[i][1] |
                                            (write_state == WRITE_STATE_WAIT) |
                                            (write_state == WRITE_STATE_DATA2) |
                                            ((write_state == WRITE_STATE_DATA1) & ((SCU_CACHE_PROTECTION == 0) |
                                                                                   half_line[i])) |
                                            ((SCU_CACHE_PROTECTION == 0) & half_line[i]))) |
                            (data_change_allowed & ~data_rw[i][1] &
                             ~half_line[i] &
                             (write_state == WRITE_STATE_IDLE))) &
                           data_arb[i]);
  end

  assign ramctl_l2db10_ready_o = req_ready[12];
  assign ramctl_l2db9_ready_o  = req_ready[11];
  assign ramctl_l2db8_ready_o  = req_ready[10];
  assign ramctl_l2db7_ready_o  = req_ready[9];
  assign ramctl_l2db6_ready_o  = req_ready[8];
  assign ramctl_l2db5_ready_o  = req_ready[7];
  assign ramctl_l2db4_ready_o  = req_ready[6];
  assign ramctl_l2db3_ready_o  = req_ready[5];
  assign ramctl_l2db2_ready_o  = req_ready[4];
  assign ramctl_l2db1_ready_o  = req_ready[3];
  assign ramctl_l2db0_ready_o  = req_ready[2];
  assign ramctl_master_ready_o = req_ready[1];
  assign ramctl_tagctl_ready_o = req_ready[0];

  // If we have started processing the data, then tell the master that it is
  // not allowed to update the data or strobes in the following cycle (unless
  // this request was completed)
  assign ramctl_master_accepted_o = start_write & data_arb[1];

  // Select the data and other attibutes from the source that was arbitrated.
  assign muxed_data = (({256{data_arb[12]}} & l2db10_ramctl_data_i) |
                       ({256{data_arb[11]}} & l2db9_ramctl_data_i) |
                       ({256{data_arb[10]}} & l2db8_ramctl_data_i) |
                       ({256{data_arb[9]}}  & l2db7_ramctl_data_i) |
                       ({256{data_arb[8]}}  & l2db6_ramctl_data_i) |
                       ({256{data_arb[7]}}  & l2db5_ramctl_data_i) |
                       ({256{data_arb[6]}}  & l2db4_ramctl_data_i) |
                       ({256{data_arb[5]}}  & l2db3_ramctl_data_i) |
                       ({256{data_arb[4]}}  & l2db2_ramctl_data_i) |
                       ({256{data_arb[3]}}  & l2db1_ramctl_data_i) |
                       ({256{data_arb[2]}}  & l2db0_ramctl_data_i) |
                       ({256{data_arb[1]}}  & master_ramctl_data_i));

  assign muxed_rw = (({2{data_arb[13]}} & data_rw[13]) |
                     ({2{data_arb[12]}} & data_rw[12]) |
                     ({2{data_arb[11]}} & data_rw[11]) |
                     ({2{data_arb[10]}} & data_rw[10]) |
                     ({2{data_arb[9]}}  & data_rw[9]) |
                     ({2{data_arb[8]}}  & data_rw[8]) |
                     ({2{data_arb[7]}}  & data_rw[7]) |
                     ({2{data_arb[6]}}  & data_rw[6]) |
                     ({2{data_arb[5]}}  & data_rw[5]) |
                     ({2{data_arb[4]}}  & data_rw[4]) |
                     ({2{data_arb[3]}}  & data_rw[3]) |
                     ({2{data_arb[2]}}  & data_rw[2]) |
                     ({2{data_arb[1]}}  & data_rw[1]) |
                     ({2{data_arb[0]}}  & data_rw[0]));

  assign next_input_rw = scu_mbistack1 ? {gov_mbistreaden1_i, gov_mbistwriteen1_i} : muxed_rw;

  assign muxed_index = (({11{data_arb[12]}} & l2db10_ramctl_index_i) |
                        ({11{data_arb[11]}} & l2db9_ramctl_index_i) |
                        ({11{data_arb[10]}} & l2db8_ramctl_index_i) |
                        ({11{data_arb[9]}}  & l2db7_ramctl_index_i) |
                        ({11{data_arb[8]}}  & l2db6_ramctl_index_i) |
                        ({11{data_arb[7]}}  & l2db5_ramctl_index_i) |
                        ({11{data_arb[6]}}  & l2db4_ramctl_index_i) |
                        ({11{data_arb[5]}}  & l2db3_ramctl_index_i) |
                        ({11{data_arb[4]}}  & l2db2_ramctl_index_i) |
                        ({11{data_arb[3]}}  & l2db1_ramctl_index_i) |
                        ({11{data_arb[2]}}  & l2db0_ramctl_index_i) |
                        ({11{data_arb[1]}}  & master_ramctl_index_i) |
                        ({11{data_arb[0]}}  & tagctl_ramctl_index_i) |
                        tagctl_l2dataram_index_i);

  assign next_input_index = scu_mbistack1 ? gov_mbistaddr1_i[14:4] : muxed_index;

  assign muxed_way = (({4{data_arb[12]}} & l2db10_ramctl_way_i) |
                      ({4{data_arb[11]}} & l2db9_ramctl_way_i) |
                      ({4{data_arb[10]}} & l2db8_ramctl_way_i) |
                      ({4{data_arb[9]}}  & l2db7_ramctl_way_i) |
                      ({4{data_arb[8]}}  & l2db6_ramctl_way_i) |
                      ({4{data_arb[7]}}  & l2db5_ramctl_way_i) |
                      ({4{data_arb[6]}}  & l2db4_ramctl_way_i) |
                      ({4{data_arb[5]}}  & l2db3_ramctl_way_i) |
                      ({4{data_arb[4]}}  & l2db2_ramctl_way_i) |
                      ({4{data_arb[3]}}  & l2db1_ramctl_way_i) |
                      ({4{data_arb[2]}}  & l2db0_ramctl_way_i) |
                      ({4{data_arb[1]}}  & master_ramctl_way_i) |
                      ({4{data_arb[0]}}  & tagctl_ramctl_way_i));

  assign mbist_way = gov_mbistaddr1_i[3:0];

  assign next_input_way = ((scu_mbistack1 ? `CA53_L2_WAY_DEC(mbist_way) :
                                            ({16{data_req_early_arb}} & `CA53_L2_WAY_DEC(muxed_way))) |
                           tagctl_l2dataram_way_i);

  // We only enable the data RAM if both the bank enable is set and at least
  // one of these late enables is set. Some of the or tree for the critical
  // L2 hit calcuation is done in this cycle and the rest is done in the next.
  assign next_input_late_en = {data_req_arb | scu_mbistack1,
                               |tagctl_l2dataram_way_i[15:12],
                               |tagctl_l2dataram_way_i[11:8],
                               |tagctl_l2dataram_way_i[7:4],
                               |tagctl_l2dataram_way_i[3:0]};

  assign muxed_banks = (({8{data_arb[13]}} & data_banks[13]) |
                        ({8{data_arb[12]}} & data_banks[12]) |
                        ({8{data_arb[11]}} & data_banks[11]) |
                        ({8{data_arb[10]}} & data_banks[10]) |
                        ({8{data_arb[9]}}  & data_banks[9]) |
                        ({8{data_arb[8]}}  & data_banks[8]) |
                        ({8{data_arb[7]}}  & data_banks[7]) |
                        ({8{data_arb[6]}}  & data_banks[6]) |
                        ({8{data_arb[5]}}  & data_banks[5]) |
                        ({8{data_arb[4]}}  & data_banks[4]) |
                        ({8{data_arb[3]}}  & data_banks[3]) |
                        ({8{data_arb[2]}}  & data_banks[2]) |
                        ({8{data_arb[1]}}  & data_banks[1]) |
                        ({8{data_arb[0]}}  & data_banks[0]));

  assign muxed_chunks = {|muxed_banks[7:6], |muxed_banks[5:4], |muxed_banks[3:2], |muxed_banks[1:0]};

  assign next_input_banks = scu_mbistack1 ? (8'h03 << {gov_mbistarray1_i[1:0], 1'b0}) : muxed_banks;

  assign muxed_err = ((data_arb[12] & l2db10_ramctl_err_i) |
                      (data_arb[11] & l2db9_ramctl_err_i)  |
                      (data_arb[10] & l2db8_ramctl_err_i)  |
                      (data_arb[9]  & l2db7_ramctl_err_i)  |
                      (data_arb[8]  & l2db6_ramctl_err_i)  |
                      (data_arb[7]  & l2db5_ramctl_err_i)  |
                      (data_arb[6]  & l2db4_ramctl_err_i)  |
                      (data_arb[5]  & l2db3_ramctl_err_i)  |
                      (data_arb[4]  & l2db2_ramctl_err_i)  |
                      (data_arb[3]  & l2db1_ramctl_err_i)  |
                      (data_arb[2]  & l2db0_ramctl_err_i));

  // Encode the L2DB that will be sending or receiving any read data, or
  // 4'b1111 to indicate the master.
  assign data_arb_l2db = (({4{data_arb[13]}} & tagctl_ramctl_l2db_i) |
                          ({4{data_arb[12]}} & 4'b1010) |
                          ({4{data_arb[11]}} & 4'b1001) |
                          ({4{data_arb[10]}} & 4'b1000) |
                          ({4{data_arb[9]}}  & 4'b0111) |
                          ({4{data_arb[8]}}  & 4'b0110) |
                          ({4{data_arb[7]}}  & 4'b0101) |
                          ({4{data_arb[6]}}  & 4'b0100) |
                          ({4{data_arb[5]}}  & 4'b0011) |
                          ({4{data_arb[4]}}  & 4'b0010) |
                          ({4{data_arb[3]}}  & 4'b0001) |
                          ({4{data_arb[2]}}  & 4'b0000) |
                          ({4{data_arb[1]}}  & 4'b1111) |
                          ({4{data_arb[0]}}  & tagctl_ramctl_l2db_i));

  assign next_input_crit_chunk = {2{data_arb[13] | data_arb[0]}} & tagctl_ramctl_crit_chunk_i;

  // Store data associated with the input cycles to the RAM. This does not use
  // clk_ramctl at the critical way signals are going to be pulled towards
  // the RAMs.
  always @(posedge clk)
  if (start_input) begin
    input_rw         <= next_input_rw;
    input_banks      <= next_input_banks;
    input_index      <= next_input_index;
    input_way        <= next_input_way;
    input_late_en    <= next_input_late_en;
    input_crit_chunk <= next_input_crit_chunk;
  end

  if (SCU_CACHE_PROTECTION) begin : g_input_err

    always @(posedge clk)
    if (start_input) begin
      input_err <= muxed_err;
    end

  end else begin : g_n_input_err

    always @*
      input_err = muxed_err;

  end

  assign muxed_write_single = ~|muxed_chunks[3:2] | ~|muxed_chunks[1:0];

  assign start_write = (data_change_allowed & data_req_early_arb & muxed_rw[0] &
                        (input_ready | ~muxed_rw[1]) &
                        (~muxed_write_single |
                         (SCU_CACHE_PROTECTION != 0)));

  // For writes, we must store the write data before the RAM access can happen,
  // and also calculate the ECC bits. There can be one or two parts to the data,
  // and the ECC bits can only be calculated after the data has been registered.
  // This state machine keeps track of which parts of the data and ECC bits are
  // ready.
  always @*
  begin
    next_write_state = write_state;
    case (write_state)
      WRITE_STATE_IDLE: begin
        if (start_write) begin
          if (|muxed_chunks[1:0]) begin
            next_write_state = WRITE_STATE_DATA1;
          end else begin
            next_write_state = WRITE_STATE_DATA2;
          end
        end
      end
      WRITE_STATE_DATA1: begin
        if (start_input | start_write_part) begin
          next_write_state = WRITE_STATE_IDLE;
        end else if (data_change_allowed) begin
          next_write_state = WRITE_STATE_DATA2;
        end else begin
          next_write_state = WRITE_STATE_WAIT;
        end
      end
      WRITE_STATE_DATA2: begin
        if (start_input | start_write_part) begin
          next_write_state = WRITE_STATE_IDLE;
        end
      end
      WRITE_STATE_WAIT: begin
        if (start_input | start_write_part) begin
          next_write_state = WRITE_STATE_IDLE;
        end
      end
      default: next_write_state = 2'bxx;
    endcase
  end

  always @(posedge clk_ramctl or negedge reset_n)
  if (~reset_n) begin
    write_state <= WRITE_STATE_IDLE;
  end else if (ramctl_active) begin
    write_state <= next_write_state;
  end

  // Indicate when all but the last beat of write data or ECC bits are ready,
  // and so the input state machine can start.
  assign write_data_ready = (((write_state == WRITE_STATE_IDLE) & ((SCU_CACHE_PROTECTION == 0) &
                                                                   muxed_write_single)) |
                             ((write_state == WRITE_STATE_DATA1) & ((SCU_CACHE_PROTECTION == 0) |
                                                                    muxed_write_single)) |
                             (write_state == WRITE_STATE_DATA2) |
                             (write_state == WRITE_STATE_WAIT));

  // Store the L2DB as soon as we start arbitrating the request.
  assign input_l2db_en = |req_ready | data_arb[13] | start_write;

  always @(posedge clk_ramctl)
  if (input_l2db_en) begin
    input_l2db <= data_arb_l2db;
  end

  assign input_l2db_onehot = 16'h0001 << input_l2db;

  // If we want the second halfline of an already arbitrated request, then mask
  // out all other request sources so that the one we want is the only one
  // presented to the arbiter and hence is guaranteed to be selected.
  // Tagctl will never perform a write and therefore does not need factoring
  // in here.
  assign data_req_mask = ({RR_MAX_WIDTH{write_state != WRITE_STATE_IDLE}} &
                          ~{input_l2db_onehot[MAX_L2DBS-1:0], input_l2db_onehot[15], 1'b0});


  // Store the write data that is to be written to the RAMs.
  assign write_data_en = ({8{data_change_allowed}} &
                          (scu_mbistack1 ? (8'h03 << {gov_mbistarray1_i[1:0], 1'b0}) :
                                           ({8{data_req_early_arb & muxed_rw[0]}} &
                                            {{4{((write_state == WRITE_STATE_IDLE) & muxed_write_single) |
                                                (((write_state == WRITE_STATE_DATA1) |
                                                  (write_state == WRITE_STATE_WAIT)) & ~muxed_write_single)}},
                                                {4{write_state == WRITE_STATE_IDLE}}} &
                                            muxed_banks)));

  assign next_write_data = {2{scu_mbistack1 ? {2{{gov_mbistindata1_i[(SCU_CACHE_PROTECTION ? 135 : 127):
                                                                     (SCU_CACHE_PROTECTION ? 72 : 64)],
                                                  gov_mbistindata1_i[63:0]}}} :
                                              muxed_data}};

  for (i = 0; i < 8; i = i + 1) begin : g_write_data

    always @(posedge clk_ramctl)
    if (write_data_en[i]) begin
      write_data[64*i+:64] <= next_write_data[64*i+:64];
    end

  end


  if (SCU_CACHE_PROTECTION) begin : g_write_ecc

    reg  [63:0]  write_data_ecc;
    reg          write_data_err;
    wire [31:0]  ecc_output;
    wire [31:0]  ecc_forced_output;
    wire [63:0]  next_write_data_ecc;
    wire [255:0] ecc_input_data;
    wire [3:0]   write_data_ecc_en;

    if (L2_INPUT_LATENCY) begin : g_input

      // For ECC, there is not time to calculate the ECC bits after muxing
      // the data, so do the calculation on the registered data instead. For input
      // latency, this would reduce throughput whilst waiting for ECC to be
      // calculated, as we cannot put the second half of the data into the
      // write_data register on hold cycles. Store it here, allowing the ECC
      // bits to be put into write_data_ecc at the same time as the data.
      reg [255:0] write_buf;
      reg [31:0]  write_buf_ecc;
      wire [1:0]  write_buf_en;

      assign write_buf_en = {2{(write_state == WRITE_STATE_DATA1) |
                               (start_write & ~|muxed_chunks[1:0])}} & muxed_chunks[3:2];

      always @(posedge clk_ramctl)
      if (write_buf_en[0]) begin
        write_buf[127:0] <= muxed_data[127:0];
      end

      always @(posedge clk_ramctl)
      if (write_buf_en[1]) begin
        write_buf[255:128] <= muxed_data[255:128];
      end

      always @(posedge clk_ramctl)
      if (write_buf_en[0]) begin
        write_buf_ecc[15:0] <= next_write_data_ecc[15:0];
      end

      always @(posedge clk_ramctl)
      if (write_buf_en[1]) begin
        write_buf_ecc[31:16] <= next_write_data_ecc[31:16];
      end

      assign ecc_input_data = ((write_state == WRITE_STATE_WAIT) |
                               (write_state == WRITE_STATE_DATA2)) ? write_buf : write_data[255:0];

      assign next_write_data_ecc = (scu_mbistack1 ? {4{{gov_mbistindata1_i[143:136], gov_mbistindata1_i[71:64]}}} :
                                    {ecc_forced_output, (write_state == WRITE_STATE_WAIT) ? write_buf_ecc : ecc_forced_output});

    end else begin : g_n_input

      assign ecc_input_data = (write_state == WRITE_STATE_DATA1) ? write_data[255:0] : write_data[511:256];

      assign next_write_data_ecc = {2{scu_mbistack1 ? {2{{gov_mbistindata1_i[143:136], gov_mbistindata1_i[71:64]}}} : ecc_forced_output}};

    end

    always @(posedge clk_ramctl)
    if (ramctl_active) begin
      write_data_err <= muxed_err;
    end

    for (i = 0; i < 4; i = i + 1) begin : g_ecc_gen

      ca53_ecc_generate64 u_ecc_generate64 (
        .data_i (ecc_input_data[i*64+:64]),
        .ecc_o  (ecc_output[i*8+:8])
      );

      // Inject ECC fatal errors on the L2 data RAMs for the SCU_CACHE_PROTECTION
      // configurations when L2DEIEN is set and MBIST not enabled.
      // If the data we are writing into L2 already has a fatal error, then
      // force two bits of the ECC to ensure that the error remains.
      assign ecc_forced_output[i*8+:8] = ecc_output[i*8+:8] ^ {6'b000000, {2{gov_l2deien_i | write_data_err}}};

    end

    assign write_data_ecc_en = ({4{data_change_allowed}} &
                                (scu_mbistack1 ? (4'b0001 << gov_mbistarray1_i[1:0]) :
                                                 ({{2{(write_state == WRITE_STATE_DATA2) |
                                                      (write_state == WRITE_STATE_WAIT) |
                                                      ((write_state == WRITE_STATE_DATA1) &
                                                       muxed_write_single)}},
                                                   {2{(write_state == WRITE_STATE_DATA1) |
                                                      (write_state == WRITE_STATE_WAIT)}}} &
                                                  muxed_chunks)));

    always @(posedge clk_ramctl)
    if (write_data_ecc_en[0]) begin
      write_data_ecc[15:0] <= next_write_data_ecc[15:0];
    end

    always @(posedge clk_ramctl)
    if (write_data_ecc_en[1]) begin
      write_data_ecc[31:16] <= next_write_data_ecc[31:16];
    end

    always @(posedge clk_ramctl)
    if (write_data_ecc_en[2]) begin
      write_data_ecc[47:32] <= next_write_data_ecc[47:32];
    end

    always @(posedge clk_ramctl)
    if (write_data_ecc_en[3]) begin
      write_data_ecc[63:48] <= next_write_data_ecc[63:48];
    end

    assign l2_dataram_wdata0_o = {write_data_ecc[7:0],   write_data[63:0]};
    assign l2_dataram_wdata1_o = {write_data_ecc[15:8],  write_data[127:64]};
    assign l2_dataram_wdata2_o = {write_data_ecc[23:16], write_data[191:128]};
    assign l2_dataram_wdata3_o = {write_data_ecc[31:24], write_data[255:192]};
    assign l2_dataram_wdata4_o = {write_data_ecc[39:32], write_data[319:256]};
    assign l2_dataram_wdata5_o = {write_data_ecc[47:40], write_data[383:320]};
    assign l2_dataram_wdata6_o = {write_data_ecc[55:48], write_data[447:384]};
    assign l2_dataram_wdata7_o = {write_data_ecc[63:56], write_data[511:448]};

  end else begin : g_n_write_ecc

    assign l2_dataram_wdata0_o = write_data[63:0];
    assign l2_dataram_wdata1_o = write_data[127:64];
    assign l2_dataram_wdata2_o = write_data[191:128];
    assign l2_dataram_wdata3_o = write_data[255:192];
    assign l2_dataram_wdata4_o = write_data[319:256];
    assign l2_dataram_wdata5_o = write_data[383:320];
    assign l2_dataram_wdata6_o = write_data[447:384];
    assign l2_dataram_wdata7_o = write_data[511:448];

  end

  assign mbist_bank_sel = {2{gov_mbistreaden1_i}} | gov_mbistbe1_i[1:0];

  assign mbist_bank_en = {(gov_mbistarray1_i[1:0] == 2'b11) ? mbist_bank_sel : {2{gov_mbistcfg1_i}},
                          (gov_mbistarray1_i[1:0] == 2'b10) ? mbist_bank_sel : {2{gov_mbistcfg1_i}},
                          (gov_mbistarray1_i[1:0] == 2'b01) ? mbist_bank_sel : {2{gov_mbistcfg1_i}},
                          (gov_mbistarray1_i[1:0] == 2'b00) ? mbist_bank_sel : {2{gov_mbistcfg1_i}}};

  assign l2_bank_en = scu_mbistack1 ? mbist_bank_en :
                      start_input   ? muxed_banks : 
                                      input_banks;


  assign next_l2_databank_en = {8{start_access |
                                  ((L2_INPUT_LATENCY != 0) &
                                   ((ram_input_state == INPUT_STATE_READ_ENABLE) |
                                    (ram_input_state == INPUT_STATE_WRITE_ENABLE)) &
                                   ~tagctl_ramctl_flush_i)}} & l2_bank_en;

  assign l2_databank_en_en = (start_access |
                              (L2_INPUT_LATENCY ? ((ram_input_state == INPUT_STATE_READ_HOLD) |
                                                   (ram_input_state == INPUT_STATE_READ_FLUSHED) |
                                                   (ram_input_state == INPUT_STATE_WRITE_HOLD)) :
                                                  ((ram_input_state == INPUT_STATE_READ_ENABLE) |
                                                   (ram_input_state == INPUT_STATE_WRITE_ENABLE))));

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    l2_databank_en <= 8'b00000000;
  end else if (l2_databank_en_en) begin
    l2_databank_en <= next_l2_databank_en;
  end

  if (L2_INPUT_LATENCY) begin : g_latency
    reg       l2_dataram_setup;
    reg [7:0] l2_dataram_clken;

    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      l2_dataram_setup <= 1'b0;
    end else if (ramctl_active) begin
      l2_dataram_setup <= start_access;
    end

    // Keep the enables free running so that they can be placed physically
    // closer to the RAMs without requiring another signal to be routed along
    // as well.
    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      l2_dataram_clken <= {8{1'b0}};
    end else begin
      l2_dataram_clken <= {8{l2_dataram_setup}};
    end

    assign l2_dataram_clken_o = l2_dataram_clken & ~{8{DFTMCPHOLD}};

  end else begin : g_n_latency

    // With no latency, the RAM clock is enabled whenever there is a request.
    // This might be speculative if tagctl is accessing the RAMs.
    assign l2_dataram_clken_o = l2_databank_en & ~{8{DFTMCPHOLD}};

  end

  // Indicate that the L2 Data RAMs are not likely to be accessed in 2-cycles.
  // Once pipelined a registered signal can be provided to the RAM instances
  // that an access will not happen in the next cycle and a light-sleep mode
  // is possible.
  assign l2_dataram_no_acc_in_2cycles = ((ram_idle_count_max_i | l2_dataram_no_acc_next_cycle) &
                                         ~clk_enable & ~next_clk_enable);

  // This needs to be on the main SCU clock, because it will get asserted only
  // after all data RAM activity has finished.
  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    l2_dataram_no_acc_next_cycle <= 1'b0;
  end else begin
    l2_dataram_no_acc_next_cycle <= l2_dataram_no_acc_in_2cycles;
  end

  assign input_way_enc = `CA53_L2_WAY_ENC(input_way);

  assign l2_dataram_no_acc_next_cycle_o = l2_dataram_no_acc_next_cycle;
  assign l2_dataram_en_o = l2_databank_en & {8{|input_late_en}} & ~{8{DFTRAMHOLD}};
  assign l2_dataram_wr_o = ram_input_state[2];
  assign l2_dataram_addr_o = {input_index, input_way_enc};

  //----------------------------------------------------------------------------
  //  RAM Output
  //----------------------------------------------------------------------------


  // Store data associated with the output cycles to the RAM.
  always @(posedge clk_ramctl)
  if (ram_output_en) begin
    output_banks      <= input_banks;
    output_l2db       <= input_l2db;
    output_crit_chunk <= input_crit_chunk;
  end

  // Capture data from the RAMs when the output state machine indicates that it is valid.
  assign ram_output_valid = ram_output_state == OUTPUT_STATE_DATA;

  assign read_data_en = {8{ram_output_valid}} & output_banks;

  assign next_read_data = {l2_dataram_rdata7_i[63:0],
                           l2_dataram_rdata6_i[63:0],
                           l2_dataram_rdata5_i[63:0],
                           l2_dataram_rdata4_i[63:0],
                           l2_dataram_rdata3_i[63:0],
                           l2_dataram_rdata2_i[63:0],
                           l2_dataram_rdata1_i[63:0],
                           l2_dataram_rdata0_i[63:0]};

  for (i = 0; i < 8; i = i + 1) begin : g_read_data

    always @(posedge clk_ramctl)
    if (read_data_en[i]) begin
      read_data[64*i+:64] <= next_read_data[64*i+:64];
    end

  end

  assign ramctl_l2dbs_data = halfline_sel ? read_data[511:256] : read_data[255:0];

  // Data send to the L2DBs is valid for two cycles, one for each halfline.
  assign next_read_data_valid = (ram_output_valid |
                                 (read_data_valid & ~read_data_last));

  always @(posedge clk_ramctl or negedge reset_n)
  if (~reset_n) begin
    read_data_valid <= 1'b0;
  end else if (ramctl_active) begin
    read_data_valid <= next_read_data_valid;
  end

  assign next_read_data_last = read_data_valid & ~read_data_last;

  always @(posedge clk_ramctl or negedge reset_n)
  if (~reset_n) begin
    read_data_last <= 1'b0;
  end else if (ramctl_active) begin
    read_data_last <= next_read_data_last;
  end

  assign next_halfline_sel = next_read_data_last ? ~halfline_sel : output_crit_chunk[1];

  always @(posedge clk_ramctl)
  if (ramctl_active) begin
    halfline_sel <= next_halfline_sel;
  end

  // The L2DB information needs to be reregistered because there can be a new
  // read starting while this one is still sending the data.
  always @(posedge clk_ramctl)
  if (ram_output_valid) begin
    read_data_l2db       <= output_l2db;
    read_data_crit_chunk <= output_crit_chunk[0];
  end

  if (SCU_CACHE_PROTECTION) begin : g_read_ecc

    reg  [63:0]  read_data_ecc;
    reg          ramctl_ecc_correction;
    reg          repaired_valid;
    reg [255:0]  repaired_data;
    reg [3:0]    repaired_l2db;
    reg          repaired_halfline;
    reg          repaired_err_last;
    reg [10:0]   repaired_index;
    reg [3:0]    repaired_way;
    reg [31:0]   repaired_syndrome;
    reg          delayed_err;
    reg          delayed_fatal;
    reg [2:0]    delayed_bank;
    reg [10:0]   delayed_index;
    reg [3:0]    delayed_way;
    reg [10:0]   output_index;
    reg [3:0]    output_way;
    reg [10:0]   read_data_index;
    reg [3:0]    read_data_way;
    reg [7:0]    read_data_banks;

    wire [10:0]  next_output_index;
    wire [63:0]  read_data_syndrome;
    wire [7:0]   read_data_bank_err;
    wire [31:0]  ramctl_l2dbs_syndrome;
    wire [31:0]  ramctl_masked_syndrome;
    wire [255:0] ramctl_l2dbs_data_repaired;
    wire [3:0]   repaired_err;
    wire [3:0]   repaired_fatal;
    wire         repair_en;
    wire         read_data_err;
    wire [63:0]  next_read_data_ecc;
    wire         next_ramctl_ecc_correction;
    wire         next_repaired_err_last;
    wire         next_delayed_err;
    wire         next_delayed_fatal;
    wire [2:0]   next_delayed_bank;

    assign next_read_data_ecc = {l2_dataram_rdata7_i[71:64],
                                 l2_dataram_rdata6_i[71:64],
                                 l2_dataram_rdata5_i[71:64],
                                 l2_dataram_rdata4_i[71:64],
                                 l2_dataram_rdata3_i[71:64],
                                 l2_dataram_rdata2_i[71:64],
                                 l2_dataram_rdata1_i[71:64],
                                 l2_dataram_rdata0_i[71:64]};

    for (i = 0; i < 8; i = i + 1) begin : g_read_data_ecc

      always @(posedge clk_ramctl)
      if (read_data_en[i]) begin
        read_data_ecc[8*i+:8] <= next_read_data_ecc[8*i+:8];
      end

    end

    assign scu_mbistoutdata1_o = ({{72{output_banks[7]}} & {read_data_ecc[63:56], read_data[511:448]},
                                   {72{output_banks[6]}} & {read_data_ecc[55:48], read_data[447:384]}} |
                                  {{72{output_banks[5]}} & {read_data_ecc[47:40], read_data[383:320]},
                                   {72{output_banks[4]}} & {read_data_ecc[39:32], read_data[319:256]}} |
                                  {{72{output_banks[3]}} & {read_data_ecc[31:24], read_data[255:192]},
                                   {72{output_banks[2]}} & {read_data_ecc[23:16], read_data[191:128]}} |
                                  {{72{output_banks[1]}} & {read_data_ecc[15:8],  read_data[127:64]},
                                   {72{output_banks[0]}} & {read_data_ecc[7:0],   read_data[63:0]}});


    for (i = 0; i < 8; i = i + 1) begin : g_ecc_gen

      ca53_ecc_check64 u_ecc_check64 (
        .data_i     (read_data[i*64+:64]),
        .ecc_i      (read_data_ecc[i*8+:8]),
        .syndrome_o (read_data_syndrome[i*8+:8])
      );

      assign read_data_bank_err[i] = read_data_valid & ~scu_mbistack1 & read_data_banks[i] & |read_data_syndrome[i*8+:8];

    end

    assign ramctl_l2dbs_syndrome = halfline_sel ? read_data_syndrome[63:32] : read_data_syndrome[31:0];

    for (i = 0; i < 4; i = i + 1) begin : g_ecc_repair

      ca53_ecc_repair64 u_ecc_repair64 (
        .data_i     (ramctl_l2dbs_data[i*64+:64]),
        .syndrome_i (ramctl_l2dbs_syndrome[i*8+:8]),
        .data_o     (ramctl_l2dbs_data_repaired[i*64+:64])
      );

      // Mask the syndrome so fatal errors do not get reported on banks that are not enabled.
      assign ramctl_masked_syndrome[i*8+:8] = (ramctl_l2dbs_syndrome[i*8+:8] &
                                               {8{read_data_banks[halfline_sel ? (i+4) : i]}});

    end


    assign read_data_err = |read_data_bank_err;

    // Record when we have detected an error, and remain held until all accesses
    // in progress have completed. New access will be blocked during this period,
    // to ensure that it does not remain held indefinitely.
    assign next_ramctl_ecc_correction = read_data_valid | (ramctl_ecc_correction &
                                                           ((ram_input_state != INPUT_STATE_IDLE) |
                                                            (ram_output_state != OUTPUT_STATE_IDLE)));

    assign repair_en = read_data_err | ((ramctl_ecc_correction | delayed_err) & ~scu_mbistack1);

    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      ramctl_ecc_correction <= 1'b0;
    end else if (repair_en) begin
      ramctl_ecc_correction <= next_ramctl_ecc_correction;
    end

    assign repair_in_progress = ramctl_ecc_correction;

    // Start using the repaired data buffer once we detect an error, and then
    // continue until all reads in progress have completed.

    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      repaired_valid <= 1'b0;
    end else if (repair_en) begin
      repaired_valid <= read_data_valid;
    end

    always @(posedge clk_ramctl)
    if (repair_en) begin
      repaired_data     <= ramctl_l2dbs_data_repaired;
      repaired_syndrome <= ramctl_masked_syndrome;
      repaired_l2db     <= read_data_l2db;
      repaired_halfline <= halfline_sel;
      repaired_index    <= read_data_index;
      repaired_way      <= read_data_way;
    end

    // Output the data to the L2DBs
    assign ramctl_l2dbs_valid_o = ramctl_ecc_correction ? repaired_valid : read_data_valid;
    assign ramctl_l2dbs_id_o    = ramctl_ecc_correction ? repaired_l2db : read_data_l2db;
    assign ramctl_l2dbs_chunk_o = (ramctl_ecc_correction ? repaired_halfline : halfline_sel) ? 2'b10 : 2'b00;
    assign ramctl_l2dbs_last_o  = ramctl_ecc_correction ^ read_data_last;
    assign ramctl_l2dbs_data_o  = ramctl_ecc_correction ? repaired_data : ramctl_l2dbs_data;


    // To help timing, the fatal calculation is done on the cycle after the
    // error is detected, and sent to the L2DB a cycle after the corrected data.
    // The L2DB knows that there is an error of some kind, and so will wait for
    // the fatal indication before forwarding the data on.
    for (i = 0; i < 4; i = i + 1) begin : g_ecc_fatal

      ca53_ecc_fatal64 u_ecc_fatal64 (
        .syndrome_i (repaired_syndrome[i*8+:8]),
        .fatal_o    (repaired_fatal[i])
      );

      assign repaired_err[i] = |repaired_syndrome[i*8+:8];

    end

    assign next_delayed_err = ramctl_ecc_correction & repaired_valid & |repaired_err;

    assign next_delayed_fatal = ramctl_ecc_correction & |repaired_fatal;

    
    assign next_delayed_bank = {repaired_halfline, |repaired_fatal ? `CA53_L2_BANK_PICK(repaired_fatal) :
                                                                     `CA53_L2_BANK_PICK(repaired_err)};

    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      delayed_err <= 1'b0;
    end else if (repair_en) begin
      delayed_err <= next_delayed_err;
    end

    always @(posedge clk_ramctl)
    if (repair_en) begin
      delayed_fatal <= next_delayed_fatal;
      delayed_bank  <= next_delayed_bank;
      delayed_index <= repaired_index;
      delayed_way   <= repaired_way;
    end

    assign ramctl_l2dbs_err_o = delayed_fatal;

    // Indicate to the cpuslvs that there was an error detected, so that any
    // data using the bypass path can be cancelled before it reaches the CPU.
    // If the error was correctable the the corrected data will be sent again
    // later, via the L2DB.
    assign ramctl_bypass_err_o = read_data_err;

    // Tell the L2DB in the following cycle that there was an error, and so the
    // bypass didn't actually happen.
    assign ramctl_bypassed_err_o = ramctl_ecc_correction;

    // Store the index and way so that when there is an error we know where to
    // perform the scrub.
    assign next_output_index = {input_index[10:7] & config_l2_size_i, input_index[6:0]};

    always @(posedge clk_ramctl)
    if (ram_output_en) begin
      output_index <= next_output_index;
      output_way   <= input_way_enc;
    end

    always @(posedge clk_ramctl)
    if (ram_output_valid) begin
      read_data_index <= output_index;
      read_data_way   <= output_way;
      read_data_banks <= output_banks;
    end

    assign next_repaired_err_last = ramctl_ecc_correction & read_data_last & read_data_err;

    always @(posedge clk_ramctl or negedge reset_n)
    if (~reset_n) begin
      repaired_err_last <= 1'b0;
    end else if (repair_en) begin
      repaired_err_last <= next_repaired_err_last;
    end

    // Start a clean and invalidate of the line when an error is detected in
    // the output, or when data that already has a fatal error is written into
    // the RAMs.
    assign ramctl_ecc_flush_req_o    = (repaired_err_last |
                                        ((((ram_input_state == INPUT_STATE_WRITE_ENABLE) & ~input_rw[1]) |
                                          ((ram_input_state == INPUT_STATE_READ_ENABLE) & input_rw[0])) & input_err));
    assign ramctl_ecc_flush_active_o = ramctl_ecc_correction | (data_req_early_arb & muxed_err);
    assign ramctl_ecc_flush_index_o  = ramctl_ecc_correction ? repaired_index : input_index;
    assign ramctl_ecc_flush_way_o    = ramctl_ecc_correction ? repaired_way : input_way_enc;

    // Output information for the L2MERRSR update.
    assign ramctl_err_valid_o = delayed_err;
    assign ramctl_err_fatal_o = delayed_fatal;
    assign ramctl_err_bank_o  = delayed_bank;
    assign ramctl_err_index_o = {delayed_index, delayed_way};

  end else begin : g_n_read_ecc

    assign scu_mbistoutdata1_o = ({{64{output_banks[7]}} & read_data[511:448],
                                   {64{output_banks[6]}} & read_data[447:384]} |
                                  {{64{output_banks[5]}} & read_data[383:320],
                                   {64{output_banks[4]}} & read_data[319:256]} |
                                  {{64{output_banks[3]}} & read_data[255:192],
                                   {64{output_banks[2]}} & read_data[191:128]} |
                                  {{64{output_banks[1]}} & read_data[127:64],
                                   {64{output_banks[0]}} & read_data[63:0]});

    assign repair_in_progress = 1'b0;

    // Output the data to the L2DBs
    assign ramctl_l2dbs_valid_o = read_data_valid;
    assign ramctl_l2dbs_id_o    = read_data_l2db;
    assign ramctl_l2dbs_chunk_o = halfline_sel ? 2'b10 : 2'b00;
    assign ramctl_l2dbs_last_o  = read_data_last;
    assign ramctl_l2dbs_data_o  = ramctl_l2dbs_data;
    assign ramctl_l2dbs_err_o   = 1'b0;

    assign ramctl_bypass_err_o = 1'b0;
    assign ramctl_bypassed_err_o = 1'b0;

    assign ramctl_ecc_flush_req_o = 1'b0;
    assign ramctl_ecc_flush_active_o = 1'b0;
    assign ramctl_ecc_flush_index_o = {11{1'b0}};
    assign ramctl_ecc_flush_way_o = {4{1'b0}};

    assign ramctl_err_valid_o = 1'b0;
    assign ramctl_err_fatal_o = 1'b0;
    assign ramctl_err_bank_o  = 3'b000;
    assign ramctl_err_index_o = {15{1'b0}};
  end

  // The critical chunk can bypass the L2DB and be sent straight to the cpuslv
  // on some request types. We need to tell the L2DB the cycle before the data
  // is available, so that it can set up the bypass path if appropriate.
  assign ramctl_l2dbs_bypass_o = (ram_output_state == OUTPUT_STATE_DATA) & ~repair_in_progress;

  assign ramctl_l2dbs_bypass_id_o = output_l2db;

  // Send the critical chunk to the cpuslv using the bypass path. All other
  // chunks will go via the L2DB.
  assign ramctl_bypass_data_o = read_data_crit_chunk ? ramctl_l2dbs_data[255:128] : ramctl_l2dbs_data[127:0];

  // Tell tagctl if it cannot make a speculative request from tc2 and hence
  // must mask out the index and way.
  assign ramctl_mask_tc2 = ~input_ready | data_req_early_arb | scu_mbistack1;

  assign ramctl_mask_tc2_o = ramctl_mask_tc2;

  //----------------------------------------------------------------------------
  //  OVLs
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "RAMCtl clock must be enabled when a request arrives")
  u_ovl_clk_en (.clk             (clk),
                .reset_n         (reset_n),
                .antecedent_expr (|data_req | (|data_req_mask)),
                .consequent_expr (clk_enable));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "tagctl_l2dataram_way must be zero if we ask tagctl t0 mask it")
  u_ovl_tagctl_way_mask (.clk             (clk),
                         .reset_n         (reset_n),
                         .antecedent_expr (ramctl_mask_tc2_o),
                         .consequent_expr (~|tagctl_l2dataram_way_i));

  reg ovl_tagctl_arb_prev0;
  reg ovl_tagctl_arb_prev1;
  reg ovl_tagctl_arb_prev2;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_tagctl_arb_prev0 <= 1'b0;
    ovl_tagctl_arb_prev1 <= 1'b0;
    ovl_tagctl_arb_prev1 <= 1'b0;
  end else begin
    ovl_tagctl_arb_prev0 <= tagctl_l2dataram_req_tc2_i & ~ramctl_mask_tc2_o;
    ovl_tagctl_arb_prev1 <= ovl_tagctl_arb_prev0 | (tagctl_ramctl_valid_i & ramctl_tagctl_ready_o);
    ovl_tagctl_arb_prev2 <= ovl_tagctl_arb_prev1;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl may only flush a request that it made")
  u_ovl_tagctl_flush (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (tagctl_ramctl_flush_i),
                      .consequent_expr (ovl_tagctl_arb_prev0 | ovl_tagctl_arb_prev1 | ovl_tagctl_arb_prev2));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Tagctl may only flush a read request")
  u_ovl_tagctl_flush_read (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (tagctl_ramctl_flush_i),
                           .consequent_expr (input_rw == 2'b10));

  reg         ovl_prev_master_valid;
  reg [255:0] ovl_prev_master_ramctl_data;
  reg [3:0]   ovl_prev_master_ramctl_chunks;

  always @(posedge clk or negedge reset_n)
  if (~reset_n) begin
    ovl_prev_master_valid <= 1'b0;
    ovl_prev_master_ramctl_data <= {256{1'b0}};
    ovl_prev_master_ramctl_chunks <= 4'b0000;
  end else begin
    ovl_prev_master_valid <= master_ramctl_valid_i & ~req_ready[1];
    ovl_prev_master_ramctl_data <= master_ramctl_data_i;
    ovl_prev_master_ramctl_chunks <= master_ramctl_chunks_i;
  end

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once a request is made it must be held until accepted")
  u_ovl_master_req_stable (.clk             (clk),
                           .reset_n         (reset_n),
                           .antecedent_expr (ovl_prev_master_valid),
                           .consequent_expr (master_ramctl_valid_i));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once a request is made chunks may be addred but not removed")
  u_ovl_master_chunks_stable (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (ovl_prev_master_valid),
                              .consequent_expr (~|(ovl_prev_master_ramctl_chunks & ~master_ramctl_chunks_i)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once a request is made the data must not change until accepted")
  u_ovl_master_data_stable_lo (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (ovl_prev_master_valid & (ovl_prev_master_ramctl_chunks[0] | ovl_prev_master_ramctl_chunks[2])),
                               .consequent_expr (master_ramctl_data_i[127:0] == ovl_prev_master_ramctl_data[127:0]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "Once a request is made the data must not change until accepted")
  u_ovl_master_data_stable_hi (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (ovl_prev_master_valid & (ovl_prev_master_ramctl_chunks[1] | ovl_prev_master_ramctl_chunks[3])),
                               .consequent_expr (master_ramctl_data_i[255:128] == ovl_prev_master_ramctl_data[255:128]));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "The output state machine should only be enabled when it is ready")
  u_ovl_output_ready (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (ram_output_en),
                      .consequent_expr ((ram_output_state == OUTPUT_STATE_IDLE) |
                                        (ram_output_state == OUTPUT_STATE_DATA)));

  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "At least one RAM bank must be enabled when state machine in read enable states")
  u_ovl_ram_enable (.clk             (clk),
                    .reset_n         (reset_n),
                    .antecedent_expr ((ram_input_state == INPUT_STATE_READ_ENABLE) |
                                      (ram_input_state == INPUT_STATE_READ_HOLD)),
                    .consequent_expr (|l2_databank_en));


  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Back to back accesses must never be made")
  u_ovl_ram_backtoback (.clk         (clk),
                        .reset_n     (reset_n),
                        .start_event (|l2_dataram_clken_o),
                        .test_expr   (~|l2_dataram_clken_o));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
  u_ovl_l2db0_req (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (l2db0_ramctl_valid_i & ~req_ready[2]),
                   .test_expr   (l2db0_ramctl_valid_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
  u_ovl_l2db1_req (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (l2db1_ramctl_valid_i & ~req_ready[3]),
                   .test_expr   (l2db1_ramctl_valid_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
  u_ovl_l2db2_req (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (l2db2_ramctl_valid_i & ~req_ready[4]),
                   .test_expr   (l2db2_ramctl_valid_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
  u_ovl_l2db3_req (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (l2db3_ramctl_valid_i & ~req_ready[5]),
                   .test_expr   (l2db3_ramctl_valid_i));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
  u_ovl_l2db4_req (.clk         (clk),
                   .reset_n     (reset_n),
                   .start_event (l2db4_ramctl_valid_i & ~req_ready[6]),
                   .test_expr   (l2db4_ramctl_valid_i));

  if (NUM_L2DBS > 5) begin : g_ovl_l2db5
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db5_req (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db5_ramctl_valid_i & ~req_ready[7]),
                     .test_expr   (l2db5_ramctl_valid_i));
  end

  if (NUM_L2DBS > 6) begin : g_ovl_l2db6
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db6_req (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db6_ramctl_valid_i & ~req_ready[8]),
                     .test_expr   (l2db6_ramctl_valid_i));
  end

  if (NUM_L2DBS > 7) begin : g_ovl_l2db7
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db7_req (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db7_ramctl_valid_i & ~req_ready[9]),
                     .test_expr   (l2db7_ramctl_valid_i));
  end

  if (NUM_L2DBS > 8) begin : g_ovl_l2db8
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db8_req (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db8_ramctl_valid_i & ~req_ready[10]),
                     .test_expr   (l2db8_ramctl_valid_i));
  end

  if (NUM_L2DBS > 9) begin : g_ovl_l2db9
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db9_req (.clk         (clk),
                     .reset_n     (reset_n),
                     .start_event (l2db9_ramctl_valid_i & ~req_ready[11]),
                     .test_expr   (l2db9_ramctl_valid_i));
  end

  if (NUM_L2DBS > 10) begin : g_ovl_l2db10
    assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Once an L2DB request is made it must be held until ready")
    u_ovl_l2db10_req (.clk         (clk),
                      .reset_n     (reset_n),
                      .start_event (l2db10_ramctl_valid_i & ~req_ready[12]),
                      .test_expr   (l2db10_ramctl_valid_i));
  end

  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: input_l2db_en")
  u_ovl_x_input_l2db_en (.clk       (clk_ramctl),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (input_l2db_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: l2_databank_en_en")
  u_ovl_x_l2_databank_en_en (.clk       (clk_ramctl),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (l2_databank_en_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: start_input")
  u_ovl_x_start_input (.clk       (clk_ramctl),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (start_input));

  if (SCU_CACHE_PROTECTION) begin : g_ovl_ecc

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: repair_en")
    u_ovl_x_repair_en (.clk       (clk_ramctl),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (g_read_ecc.repair_en));

    if (L2_INPUT_LATENCY) begin : g_ovl_input

      assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_buf_en[0]")
      u_ovl_x_write_buf_en0 (.clk       (clk_ramctl),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (g_write_ecc.g_input.write_buf_en[0]));

      assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_buf_en[1]")
      u_ovl_x_write_buf_en1 (.clk       (clk_ramctl),
                             .reset_n   (reset_n),
                             .qualifier (1'b1),
                             .test_expr (g_write_ecc.g_input.write_buf_en[1]));
    end

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_data_ecc_en[0]")
    u_ovl_x_write_data_ecc_en0 (.clk       (clk_ramctl),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (g_write_ecc.write_data_ecc_en[0]));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_data_ecc_en[1]")
    u_ovl_x_write_data_ecc_en1 (.clk       (clk_ramctl),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (g_write_ecc.write_data_ecc_en[1]));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_data_ecc_en[2]")
    u_ovl_x_write_data_ecc_en2 (.clk       (clk_ramctl),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (g_write_ecc.write_data_ecc_en[2]));

    assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: write_data_ecc_en[3]")
    u_ovl_x_write_data_ecc_en3 (.clk       (clk_ramctl),
                                .reset_n   (reset_n),
                                .qualifier (1'b1),
                                .test_expr (g_write_ecc.write_data_ecc_en[3]));
  end

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: data_req_arb")
  u_ovl_x_data_req_arb (.clk       (clk),
                       .reset_n   (reset_n),
                       .qualifier (1'b1),
                       .test_expr (data_req_arb));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ram_output_en")
  u_ovl_x_ram_output_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (ram_output_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ram_output_valid")
  u_ovl_x_ram_output_valid (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (ram_output_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ramctl_active")
  u_ovl_x_ramctl_active (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (ramctl_active));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Register enable x-check: read_data_en")
  u_ovl_x_read_data_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (read_data_en));

  assert_never_unknown #(`OVL_FATAL, 8, `OVL_ASSERT, "Register enable x-check: write_data_en")
  u_ovl_x_write_data_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (write_data_en));

`endif

end else begin : g_no_l2cc
  // L2 not present, so tie off all outputs
  assign l2_dataram_clken_o = {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};
  assign l2_dataram_no_acc_next_cycle_o = 1'b1;
  assign l2_dataram_en_o = {`CA53_SCU_L2_DATARAM_EN_W{1'b0}};
  assign l2_dataram_wr_o = 1'b0;
  assign l2_dataram_addr_o = {`CA53_SCU_L2_DATARAM_ADDR_W{1'b0}};
  assign l2_dataram_wdata0_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata1_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata2_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata3_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata4_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata5_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata6_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign l2_dataram_wdata7_o = {`CA53_SCU_L2_DATARAM_DATA_W{1'b0}};
  assign ramctl_active_o = 1'b0;
  assign ramctl_awake_o = 1'b0;
  assign ramctl_l2dbs_valid_o = 1'b0;
  assign ramctl_l2dbs_id_o = {4{1'b0}};
  assign ramctl_l2dbs_data_o = {256{1'b0}};
  assign ramctl_l2dbs_chunk_o = {2{1'b0}};
  assign ramctl_l2dbs_err_o = 1'b0;
  assign ramctl_l2dbs_last_o = 1'b0;
  assign ramctl_l2dbs_bypass_o = 1'b0;
  assign ramctl_l2dbs_bypass_id_o = {4{1'b0}};
  assign ramctl_l2db0_ready_o = 1'b0;
  assign ramctl_l2db1_ready_o = 1'b0;
  assign ramctl_l2db2_ready_o = 1'b0;
  assign ramctl_l2db3_ready_o = 1'b0;
  assign ramctl_l2db4_ready_o = 1'b0;
  assign ramctl_l2db5_ready_o = 1'b0;
  assign ramctl_l2db6_ready_o = 1'b0;
  assign ramctl_l2db7_ready_o = 1'b0;
  assign ramctl_l2db8_ready_o = 1'b0;
  assign ramctl_l2db9_ready_o = 1'b0;
  assign ramctl_l2db10_ready_o = 1'b0;
  assign ramctl_master_ready_o = 1'b0;
  assign ramctl_tagctl_ready_o = 1'b0;
  assign ramctl_master_accepted_o = 1'b0;
  assign ramctl_mask_tc2_o = 1'b0;
  assign ramctl_ecc_flush_req_o = 1'b0;
  assign ramctl_ecc_flush_active_o = 1'b0;
  assign ramctl_ecc_flush_index_o = {11{1'b0}};
  assign ramctl_ecc_flush_way_o = {4{1'b0}};
  assign ramctl_bypass_data_o = {128{1'b0}};
  assign ramctl_bypass_err_o = 1'b0;
  assign ramctl_bypassed_err_o = 1'b0;
  assign ramctl_err_valid_o = 1'b0;
  assign ramctl_err_fatal_o = 1'b0;
  assign ramctl_err_bank_o  = 3'b000;
  assign ramctl_err_index_o = {15{1'b0}};
  assign scu_mbistack1_o = 1'b0;
  assign scu_mbistoutdata1_o = {128{1'b0}};
end endgenerate


endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
