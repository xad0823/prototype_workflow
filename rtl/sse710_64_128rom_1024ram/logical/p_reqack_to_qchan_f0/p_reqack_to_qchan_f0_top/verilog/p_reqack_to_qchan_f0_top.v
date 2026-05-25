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


module p_reqack_to_qchan_f0_top(
  input wire     CLK,
  input wire     RESETn,

  input wire     PWRUPREQ,
  output wire    PWRUPACK,

  input wire     PWRQREQn,
  output wire    PWRQACCEPTn,
  output wire    PWRQDENY,
  output wire    PWRQACTIVE,
  output wire    CLKQACTIVE
  );

  localparam QSTOPPED    = 3'b000;
  localparam QRUN        = 3'b100;
  localparam QRUNACK     = 3'b101;
  localparam QDENY       = 3'b111;
  localparam ST_UNUSED_1 = 3'b001;
  localparam ST_UNUSED_2 = 3'b010;
  localparam ST_UNUSED_3 = 3'b011;
  localparam ST_UNUSED_6 = 3'b110;

  wire         pwrupreq_r;
  wire         pwrqreqn_r;

  reg  [2:0]   state;
  reg  [2:0]   next_state;

  wire         reqackactive;
  wire         qchanactive;


p_reqack_to_qchan_f0_cdc_capt_sync u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrupreq(
  .clk              ( CLK               ),  
  .nreset           ( RESETn            ),  
  .d_async          ( PWRUPREQ          ),  
  .q                ( pwrupreq_r        )   
  );


p_reqack_to_qchan_f0_cdc_capt_sync u_p_reqack_to_qchan_f0_cdc_capt_sync_pwrqreqn(
  .clk              ( CLK               ),  
  .nreset           ( RESETn            ),  
  .d_async          ( PWRQREQn          ),  
  .q                ( pwrqreqn_r        )   
  );


always @(*)
  case (state)
    QSTOPPED : if (pwrqreqn_r)
                 next_state = QRUN;
               else
                 next_state = QSTOPPED;

    QRUN     : case ({pwrupreq_r, pwrqreqn_r})
                 2'b00 : next_state = QSTOPPED;
                 2'b01 : next_state = QRUN;
                 2'b10 : next_state = QDENY;
                 2'b11 : next_state = QRUNACK;
                 default : next_state = 3'bxxx;
               endcase

    QRUNACK  : case ({pwrupreq_r, pwrqreqn_r})
                 2'b00 : next_state = QRUN;
                 2'b01 : next_state = QRUN;
                 2'b10 : next_state = QDENY;
                 2'b11 : next_state = QRUNACK;
                 default : next_state = 3'bxxx;
               endcase

    QDENY    : if (pwrqreqn_r)
                 next_state = QRUNACK;
               else
                 next_state = QDENY;

    ST_UNUSED_1, ST_UNUSED_2, ST_UNUSED_3, ST_UNUSED_6 :
               next_state = 3'b000;

    default  : next_state = 3'bxxx;
  endcase


always @(posedge CLK or negedge RESETn)
  if (~RESETn)
    state <= 3'b000;
  else
    state <= next_state;


assign {PWRQACCEPTn, PWRQDENY, PWRUPACK} = state;


p_reqack_to_qchan_f0_std_xor2 u_p_reqack_to_qchan_f0_std_xor2_pwrupreq(
  .A ( PWRUPREQ ),     
  .B ( PWRUPACK ),     
  .Y ( reqackactive )  
  );

p_reqack_to_qchan_f0_std_xor2 u_p_reqack_to_qchan_f0_std_xor2_pwrqreqn(
  .A ( PWRQREQn ),     
  .B ( PWRQACCEPTn ),  
  .Y ( qchanactive )   
  );

p_reqack_to_qchan_f0_std_or3  u_p_reqack_to_qchan_f0_std_or3(
  .A ( reqackactive ), 
  .B ( qchanactive ),  
  .C ( PWRQDENY ),     
  .Y ( CLKQACTIVE )    
  );


assign PWRQACTIVE = PWRUPREQ;

endmodule
