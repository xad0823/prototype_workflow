//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2001-2013,2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Oct 17 09:37:56 2016 +0100
//
//      Revision            : 16e1228
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
<<template_begin>>
<<copyright_header>>
<<version_control_header>>
<<timescale_directive>>
module <<output_arb_name>> (


    input  wire       hclk,
    input  wire       hresetn,
//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    input  wire       transfer_request_<<si_name>>,
    input  wire       sel_op_<<si_name>>,
    input  wire [1:0] trans_op_<<si_name>>,
    input  wire [2:0] burst_op_<<si_name>>,
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
    input  wire       hreadym,
    input  wire       hselm,
    input  wire [1:0] htransm,
    input  wire [2:0] hburstm,
    input  wire       hmastlockm,

    output reg  [<<idw_si>>:0] selected_port,
    output reg        no_port
);


localparam TRN_IDLE   = 2'b00;
localparam TRN_BUSY   = 2'b01;
localparam TRN_NONSEQ = 2'b10;
localparam TRN_SEQ    = 2'b11;

localparam BUR_SINGLE = 3'b000;
localparam BUR_INCR   = 3'b001;
localparam BUR_WRAP4  = 3'b010;
localparam BUR_INCR4  = 3'b011;
localparam BUR_WRAP8  = 3'b100;
localparam BUR_INCR8  = 3'b101;
localparam BUR_WRAP16 = 3'b110;
localparam BUR_INCR16 = 3'b111;


  reg         lastport_hselm;
  reg   [1:0] lastport_htransm;
  reg   [2:0] lastport_hburstm;

  reg         hsel_lock;
  wire        next_hsel_lock;
  wire        hlock_arb;
  reg         waiting;

  reg   [<<idw_si>>:0] prev_port;
  reg         prev_no_port;

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  wire        req_port_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------




wire rearbitration_point = ~hlock_arb && ~waiting;



  always @ (
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             req_port_<<si_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
             lastport_hselm or prev_no_port or prev_port or rearbitration_point
           )
    begin : p_sel_port_comb
      no_port = prev_no_port;
      selected_port = prev_port;

      if ( rearbitration_point )
      begin
        no_port = 1'b0;
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
        <<rrelse>>if (req_port_<<si_name>>)
          selected_port = <<idw_si_v>>'b<<bin_in>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end in >> ----------------------------------
        else if (lastport_hselm)
          selected_port = prev_port;
      end
    end





//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign req_port_<<si_name>> = transfer_request_<<si_name>> & sel_op_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------



  always @ (
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             sel_op_<<si_name>> or trans_op_<<si_name>> or
             burst_op_<<si_name>> or
//----------------------------- << end connection >> ---------------------------
//------------------------------- << end in >> ---------------------------------
             prev_port or prev_no_port
           )
    begin : p_prev_mux
      lastport_hselm       = 1'b0;
      lastport_htransm     = 2'b00;
      lastport_hburstm     = 3'b000;

      if (~prev_no_port)
        case (prev_port)
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<idw_si_v>>'b<<bin_in>> :
            begin
              lastport_hselm       = sel_op_<<si_name>>;
              lastport_htransm     = trans_op_<<si_name>>;
              lastport_hburstm     = burst_op_<<si_name>>;
            end

//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
          default :
            begin
              lastport_hselm       = 1'bx;
              lastport_htransm     = 2'bxx;
              lastport_hburstm     = 3'bxxx;
            end
        endcase
    end


  always @ (posedge hclk or negedge hresetn)
  begin : p_waiting_reg
    if (~hresetn)
      waiting    <= 1'b0;
    else
      waiting    <= ~hreadym && hselm && htransm != TRN_IDLE;
  end


  always @ (negedge hresetn or posedge hclk)
    begin : p_prev_port
      if (~hresetn)
      begin
//------------------------------ << start rrin >> ------------------------------
//------------------------------ << end rrin >> ------------------------------
        prev_port    <= <<idw_si_v>>'b<<bin_rrin>>;
        prev_no_port <= 1'b1;
      end
      else
      begin
        prev_port <= selected_port;
        prev_no_port <= no_port;
      end
    end


  assign next_hsel_lock = (hselm & htransm[1] & hmastlockm) ? 1'b1 :
                          (hmastlockm == 1'b0) ? 1'b0 :
                          hsel_lock;

  always @ (negedge hresetn or posedge hclk)
    begin : p_hsel_lock
      if (~hresetn)
        hsel_lock <= 1'b0;
      else
        if (hreadym)
          hsel_lock <= next_hsel_lock;
    end

  assign hlock_arb = hsel_lock;



endmodule

