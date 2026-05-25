//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module channel_gate_f0 (
            
    input  wire [3:0]     channel_pulse_slave_0,
    
    output wire [3:0]     channel_pulse_master_0,

    input  wire [3:0]     channel_pulse_slave_1,
    
    output wire [3:0]     channel_pulse_master_1,

    input  wire           chen
  );
  
  
  reg  [3:0]   channel_pulse_master_0_int;
  reg  [3:0]   channel_pulse_master_1_int;
  

  always @(*)
  begin
    case(chen)
      1'b1:    channel_pulse_master_1_int  = channel_pulse_slave_0;
      1'b0:    channel_pulse_master_1_int  = 4'b0000;
      default: channel_pulse_master_1_int  = 4'bxxxx;
    endcase
  end 
  
  always @(*)
  begin
    case(chen)
      1'b1:    channel_pulse_master_0_int  = channel_pulse_slave_1;
      1'b0:    channel_pulse_master_0_int  = 4'b0000;
      default: channel_pulse_master_0_int  = 4'bxxxx;
    endcase
  end  
  

  assign channel_pulse_master_0 = channel_pulse_master_0_int;
  assign channel_pulse_master_1 = channel_pulse_master_1_int;
  
endmodule