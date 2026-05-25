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
//      Checked In          : $Date: 2012-05-03 16:52:24 +0100 (Thu, 03 May 2012) $
//
//      Revision            : $Revision: 192060 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : ECC Correction State Machine
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// When an ECC error is detected the correction state machine is started which
// handshakes with the BIU to correct the error.

module ca53dcu_ecc_correction (
  input  wire        clk,
  input  wire        reset_n,
  input  wire        ecc_err_i,           // ECC Error Detected
  input  wire        ecc_cinv_ack_i,      // BIU Clean/Invalidate acknowledge
  input  wire        ecc_cinv_complete_i, // BIU Clean/Invalidate complete
  input  wire [7:0]  ecc_err_index_i,
  input  wire [1:0]  ecc_err_way_i,

  output wire [7:0]  ecc_cinv_index_o,
  output wire        ecc_cinv_req_o,      // Clean/Invalidate request to the BIU
  output wire [1:0]  ecc_cinv_way_o,
  output wire        ecc_in_progress_o    // ECC state machine in progress
);

  //---------------------------------------------------------------------------
  // Local parameters
  //---------------------------------------------------------------------------
  localparam ECC_ST_IDLE      = 2'b00;
  localparam ECC_ST_BIU_REQ   = 2'b01;
  localparam ECC_ST_WAIT_CINV = 2'b10;
  localparam ECC_ST_X         = 2'bxx;


  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------
  reg  [1:0] ecc_state;
  reg  [7:0] err_index;
  reg  [1:0] err_way;
  reg  [1:0] next_ecc_state;
  wire       ecc_cinv_req;
  wire       ecc_en;


  //---------------------------------------------------------------------------
  // Correction state machine
  //---------------------------------------------------------------------------

  // Register the ECC information (way and index) whenever a new ECC error is detected.
  assign ecc_en = ecc_err_i & (ecc_state == ECC_ST_IDLE);

  always @(posedge clk)
    if (ecc_en) begin
      err_index <= ecc_err_index_i;
      err_way   <= ecc_err_way_i;
    end

  always @*
    case (ecc_state)
      ECC_ST_IDLE: begin
       next_ecc_state = ecc_err_i ? ECC_ST_BIU_REQ : ECC_ST_IDLE;
      end
      ECC_ST_BIU_REQ: begin
       next_ecc_state = ecc_cinv_ack_i  ? ECC_ST_WAIT_CINV : ECC_ST_BIU_REQ;
      end
      ECC_ST_WAIT_CINV: begin
       next_ecc_state = ecc_cinv_complete_i ? ECC_ST_IDLE : ECC_ST_WAIT_CINV;
      end
      default: begin
       next_ecc_state = ECC_ST_X;
      end
    endcase

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      ecc_state <= ECC_ST_IDLE;
    else
      ecc_state <= next_ecc_state;

  assign ecc_cinv_req = (ecc_state == ECC_ST_BIU_REQ);

  // Index and way of the data that had ECC error
  assign ecc_cinv_index_o = err_index;
  assign ecc_cinv_way_o   = err_way;

  // Send a request to BIU for clean/invalidate
  assign ecc_cinv_req_o = ecc_cinv_req;

  // ECC correction state machine in progress
  assign ecc_in_progress_o = (ecc_state != ECC_ST_IDLE);


  //---------------------------------------------------------------------------
  // OVLs
  //---------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON

  //-----------------------------------
  // Invalid State Machine Transitions
  //-----------------------------------
  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid ECC state machine state transition")
  u_ovl_ecc_transition_idle (.clk         (clk),
                             .reset_n     (reset_n),
                             .start_event (ecc_state == ECC_ST_IDLE),
                             .test_expr   (((ecc_state == ECC_ST_IDLE) |
                                            (ecc_state == ECC_ST_BIU_REQ))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid ECC state machine state transition")
  u_ovl_ecc_transition_biu_req (.clk         (clk),
                                .reset_n     (reset_n),
                                .start_event (ecc_state == ECC_ST_BIU_REQ),
                                .test_expr   (((ecc_state == ECC_ST_BIU_REQ) |
                                               (ecc_state == ECC_ST_WAIT_CINV))));

  assert_next #(`OVL_FATAL, 1, 1, 0, `OVL_ASSERT, "Invalid ECC state machine state transition")
  u_ovl_ecc_transition_wait_cinv (.clk         (clk),
                                  .reset_n     (reset_n),
                                  .start_event (ecc_state == ECC_ST_WAIT_CINV),
                                  .test_expr   (((ecc_state == ECC_ST_WAIT_CINV) |
                                                 (ecc_state == ECC_ST_IDLE))));

  // Not all possible state encodings are valid
  assert_always #(`OVL_FATAL,`OVL_ASSERT,"ECC state machine has reached an invalid state")
  u_ovl_ecc_current_state_ill (.clk       (clk),
                               .reset_n   (reset_n),
                               .test_expr ((ecc_state == ECC_ST_IDLE)    |
                                           (ecc_state == ECC_ST_BIU_REQ) |
                                           (ecc_state == ECC_ST_WAIT_CINV)));

  //----------
  // X-Checks
  //----------
  /* ARMAUTO_X */
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ecc_en")
  u_ovl_x_ecc_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ecc_en));


`endif

endmodule // ca53dcu_ecc_correction
