//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//        (C) COPYRIGHT 2013-2016 ARM Limited or its affiliates.
//            ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
// Release Information : PL405-r3p0-01rel0
//
// Checked In          :  2016-01-21 15:26:03 +0000 (Thu, 21 Jan 2016)
// Revision            : 205793
//
//---------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//---------------------------------------------------------------------------
//
// Purpose :
//
// Common Sample At Reset block to register inputs on the first clock cycle
// after reset then hold the value
//----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Module Declaration
//------------------------------------------------------------------------------
module adb400_r3_sar

// -----------------------------------------------------------------------------
//  Parameters (for ports or related)
// -----------------------------------------------------------------------------
  #(parameter // These parameters can be overridden at instantiation.
              // new parameters should be added at end of these
              WIDTH = 3   // Number of bits to register
              )

  //----------------------------------------------------------------------------
  // Ports
  //----------------------------------------------------------------------------
  (
  input  wire                                 aclk,
  input  wire                                 aresetn,

// ACS_off start UNEQUAL_WIDTH_OP_ARGS SINGLE_BIT_BUS Inequality is in computing signal widths ; Parameterisable width is sometimes 1b
  input  wire [WIDTH-1:0]                     sample_i,
  output wire [WIDTH-1:0]                     sample_o
// ACS_off end UNEQUAL_WIDTH_OP_ARGS SINGLE_BIT_BUS
);

// ACS_off UNEQUAL_WIDTH_OP_ARGS Inequality is arithmetic of a param and a constant
  localparam SAMPLE_MSB = WIDTH-1;

  //---------------------------------------------------------------------------
  // Internal signals
  //---------------------------------------------------------------------------
  reg             first_cycle_q;  // First cycle detection
// ACS_off UNRESET_REGISTER SINGLE_BIT_BUS Never used before capture in first cycle ; Parameterisable width is sometimes 1b
  reg [SAMPLE_MSB:0] sample_q;       // Registered sample of the signal

  //---------------------------------------------------------------------------
  // Start of code
  //---------------------------------------------------------------------------

  // Detect the first cycle out of reset
  always @(posedge aclk or negedge aresetn)
  begin: p_first_cycle_detect
    if (!aresetn)
      first_cycle_q <= 1'b1;
    else if (first_cycle_q)
      first_cycle_q <= 1'b0;
  end

  // Capture sample at reset inputs
  always @(posedge aclk)
  begin: p_first_cycle_sample
    if (first_cycle_q)
// ACS_off UNRESETTABLE_REGISTER Is always written in first cycle
      sample_q <= sample_i;
  end

  // Drive the output
  assign sample_o = sample_q;

endmodule
