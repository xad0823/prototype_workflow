//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2012,2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Fri Dec 9 09:57:44 2016 +0000
//
//      Revision            : b783292
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_apb_sync_core_m
 (
    input  wire                             pclk,
    input  wire                             presetn,

    input  wire                             pready,

    input  wire                             apb_trnf_req,
    output wire                             apb_trnf_ack,
    input  wire     [31:0]                  prdata,
    output reg      [31:0]                  prdata_r,
    input  wire                             pslverr,
    output reg                              pslverr_r,
    output wire                             psel,
    output wire                             penable,
    output wire                             apb_active
  );



  reg   [1:0] next_state_apb;
  reg   [1:0] state_reg_apb;



  reg         apb_trnf_ack_r;
  reg         apb_trnf_req_r;
  wire        start_apb_trnf;



   localparam [1:0]  APB_IDLE   = 2'b00;
   localparam [1:0]  APB_SETUP  = 2'b01;
   localparam [1:0]  APB_ACCESS = 2'b10;

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    apb_trnf_req_r <= 1'b0;
  else
    apb_trnf_req_r <= apb_trnf_req;
  end

  assign start_apb_trnf = apb_trnf_req & (~apb_trnf_req_r | apb_trnf_ack);

  always @(state_reg_apb or pready or start_apb_trnf)
    begin
    case (state_reg_apb)
     APB_IDLE  :
     begin
       if (start_apb_trnf) begin
         next_state_apb = APB_SETUP;
       end
       else begin
         next_state_apb = APB_IDLE;
       end
    end
     APB_SETUP :
     begin
       next_state_apb = APB_ACCESS;
     end
     APB_ACCESS :
     begin
       if (pready)
         next_state_apb = APB_IDLE;
       else
         next_state_apb = APB_ACCESS;
     end
     default :
     begin
       next_state_apb = 2'bxx;
     end
    endcase
  end

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    state_reg_apb <= APB_IDLE;
  else
    state_reg_apb <= next_state_apb;
  end

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    apb_trnf_ack_r  <= 1'b0;
  else
    if ((state_reg_apb == APB_ACCESS) & pready)
      apb_trnf_ack_r  <= 1'b1;
    else
      apb_trnf_ack_r  <= 1'b0;
  end

  always @(posedge pclk or negedge presetn)
  begin
  if (~presetn)
    prdata_r  <= {(32){1'b0}};
  else
    if ((state_reg_apb == APB_ACCESS) & pready)
      prdata_r  <= prdata;
  end

  always @(posedge pclk or negedge presetn)
  begin
    if (~presetn)
      pslverr_r <= 1'b0;
    else
      if (psel & penable & pready)
        pslverr_r <= pslverr;
    else
      pslverr_r <= 1'b0;
  end

  assign apb_trnf_ack  = apb_trnf_ack_r;

  assign psel          = (state_reg_apb==APB_SETUP)  | (state_reg_apb==APB_ACCESS);
  assign penable       = (state_reg_apb==APB_ACCESS);
  assign apb_active    = |state_reg_apb;



endmodule


