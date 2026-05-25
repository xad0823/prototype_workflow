//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38583 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      RTL design for STM AXI Slave Interface for read transactions
//-----------------------------------------------------------------------------

module cxstm500_axislvif_read
 #(
  parameter AXI_ID_WIDTH = 2,
  parameter STM_DATA_WIDTH = 64
  )
  (
  input wire                       ACLK,        // AXI Clock
  input wire                       ARESETn,     // AXI Reset

  // AR channel
  input wire                       ARVALIDS,    // Read Address Valid
  input wire  [AXI_ID_WIDTH-1:0]   ARIDS,       // Read Address ID
  input wire  [7:0]                ARLENS,      // Read Burst length
  output wire                      ARREADYS,    // Read Address Ready

  // R channel
  input wire                       RREADYS,     // Read Data Ready
  output wire                      RVALIDS,     // Read Data Valid
  output wire [AXI_ID_WIDTH-1:0]   RIDS,        // Read Data ID
  output wire [STM_DATA_WIDTH-1:0] RDATAS,      // Read Data
  output wire [1:0]                RRESPS,      // Read Response
  output wire                      RLASTS,      // Read Data Last

  // Q-Channel
  input wire                       q_stop_i,    // Q-Channel stopping
  output wire                      axi_busy_o   // AXI Busy
  );


  //---------------------------------------------------------------------------
  // Constant definitions
  //---------------------------------------------------------------------------
  localparam  AXI_RESP_OKAY = 2'b00;              // AXI OKAY response

  //---------------------------------------------------------------------------
  // Wires
  //---------------------------------------------------------------------------
  wire                    nxt_rvalid;
  wire                    rvalid_we;
  wire                    nxt_rlast;
  wire                    rlast_we;
  wire [AXI_ID_WIDTH-1:0] nxt_rid;
  wire                    rid_we;
  wire [7:0]              nxt_transfer_count;
  wire                    transfer_count_we;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg                     rvalid_reg;
  reg                     rlast_reg;
  reg [AXI_ID_WIDTH-1:0]  rid_reg;
  reg [7:0]               transfer_count_reg;


  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  // RVALID should be asserted in response to a read address transfer, and
  // cleared when the last read data beat is transferred.
  assign nxt_rvalid =  ARVALIDS & ARREADYS;
  assign rvalid_we  = (ARVALIDS & ARREADYS) | (rlast_reg & RREADYS);
  always @(posedge ACLK or negedge ARESETn)
  begin
    if (!ARESETn)
      rvalid_reg <= 1'b0;
    else if (rvalid_we)
      rvalid_reg <= nxt_rvalid;
  end

  // Burst Transfer Logic
  assign nxt_rlast = (ARVALIDS & ARREADYS & (ARLENS[7:0] == {8{1'b0}})) |  // Single Transfer
                     (transfer_count_reg[7:0] == 8'b00000001);             // Last Transfer in Burst
  assign rlast_we  = (ARVALIDS & ARREADYS) | (rvalid_reg & RREADYS);
  always @(posedge ACLK or negedge ARESETn)
  begin
    if (!ARESETn)
      rlast_reg <= 1'b0;
    else if (rlast_we)
      rlast_reg <= nxt_rlast;
  end

  // The transfer counter is reset to the ARLEN value whenever a read address is
  // accepted. Otherwise the value to be loaded will be the current value
  // subtracted by 1.
  assign nxt_transfer_count[7:0] = (ARVALIDS & ARREADYS) ? ARLENS[7:0] : (transfer_count_reg[7:0] - 8'b00000001);
  assign transfer_count_we       = (ARVALIDS & ARREADYS) | (rvalid_reg & RREADYS);
  always @(posedge ACLK or negedge ARESETn)
  begin
    if (!ARESETn)
      transfer_count_reg[7:0] <= 8'b00000000;
    else if (transfer_count_we)
      transfer_count_reg[7:0] <= nxt_transfer_count[7:0];
  end

  // The Read ID is a copy of the read address ID. This registered output should
  // be loaded only when ARVALID is asserted.
  assign nxt_rid[AXI_ID_WIDTH-1:0] = ARIDS[AXI_ID_WIDTH-1:0];
  assign rid_we = ARVALIDS & ARREADYS;
  always @(posedge ACLK)
  begin
    if (rid_we)
      rid_reg[AXI_ID_WIDTH-1:0] <= nxt_rid[AXI_ID_WIDTH-1:0];
  end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------

  // The STM has read acceptance capability of one
  // Therefore when data is being transferred out, no address is accepted.
  assign ARREADYS    = ~rvalid_reg & ~q_stop_i;

  // The STM's AXI interface returns all zeroes
  assign RDATAS      = {STM_DATA_WIDTH{1'b0}};

  // Resopnse is always OK
  assign RRESPS[1:0] = AXI_RESP_OKAY[1:0];
  assign RIDS        = rid_reg;
  assign RLASTS      = rlast_reg;
  assign RVALIDS     = rvalid_reg;

  //AXI Busy for Q Channel Controller
  assign axi_busy_o =  rvalid_reg |
                      (ARVALIDS & ARREADYS);


`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  assert_next #(`OVL_FATAL,1,1,0,`OVL_ASSERT,"AXI read should be returned one cycle after read address is accepted")
    ovl_next_axislvif_read_return_one_cycle_after_accept (
      .clk         (ACLK),
      .reset_n     (ARESETn),
      .start_event (ARVALIDS & ARREADYS),
      .test_expr   (RVALIDS)
    );

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "rvalid_we is X")
    ovl_never_unknown_axislvif_read_rvalid_we (
      .clk       (ACLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (rvalid_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "rlast_we is X")
    ovl_never_unknown_axislvif_read_rlast_we (
      .clk       (ACLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (rlast_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "transfer_count_we is X")
    ovl_never_unknown_axislvif_read_transfer_count_we (
      .clk       (ACLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (transfer_count_we)
    );

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "rid_we is X")
    ovl_never_unknown_axislvif_read_rid_we (
      .clk       (ACLK),
      .reset_n   (ARESETn),
      .qualifier (1'b1),
      .test_expr (rid_we)
    );

`endif

endmodule
