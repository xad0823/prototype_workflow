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
//      Checked In          : Tue Sep 6 14:23:38 2016 +0100
//
//      Revision            : 623ff23
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

    output wire [<<idw_si>>:0] selected_port,
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

localparam                             BURST_COUNT_WIDTH = 3;
localparam     [BURST_COUNT_WIDTH-1:0] MAX_ALLOCATED     = 4;

    reg  [<<idw_si>>:0] selected_port_next;
    reg  [<<idw_si>>:0] i_selected_port;
    reg        no_port_next;
    reg  [3:0] next_burst_count;
    reg  [3:0] reg_burst_count;
    reg        next_burst_hold;
    reg        reg_burst_hold;

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  wire        req_port_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

    reg [1:0] htransm_int;
    reg [2:0] hburstm_int;
    reg       hmastlockm_int;
    always @(*)
    begin
       htransm_int    = htransm;
       hburstm_int    = hburstm;
       hmastlockm_int = hmastlockm;
    end




  always @ (hreadym or htransm_int or hselm or hburstm_int or reg_burst_count or reg_burst_hold)
    begin : p_next_burst_count_comb
      if (!hreadym)
        begin
          next_burst_count = reg_burst_count;
          next_burst_hold  = reg_burst_hold;
        end

      else if (!hselm)
        begin
          next_burst_count = 4'b0000;
          next_burst_hold  = 1'b0;
        end

      else
        case (htransm_int)

          TRN_NONSEQ : begin
            case (hburstm_int)
              BUR_INCR16, BUR_WRAP16 : begin
                next_burst_count = 4'b1111;
                next_burst_hold = 1'b1;
              end

              BUR_INCR8, BUR_WRAP8 : begin
                next_burst_count = 4'b0111;
                next_burst_hold = 1'b1;
              end

              BUR_INCR4, BUR_WRAP4 : begin
                next_burst_count = 4'b0011;
                next_burst_hold = 1'b1;
              end

              BUR_SINGLE, BUR_INCR : begin
                next_burst_count = 4'b0000;
                next_burst_hold = 1'b0;
              end

              default : begin
                next_burst_count = 4'bxxxx;
                next_burst_hold = 1'bx;
              end
            endcase

            if (reg_burst_count >4'd1)
              next_burst_hold = 1'b0;

          end

          TRN_SEQ : begin
            if (reg_burst_count != 4'b0000)
              next_burst_count = reg_burst_count - 1'b1;
            else
              next_burst_count = 4'b0000;
            if (reg_burst_count == 4'b0001)
              next_burst_hold = 1'b0;
            else
              next_burst_hold = reg_burst_hold;
          end

          TRN_BUSY : begin
            next_burst_count = reg_burst_count;
            next_burst_hold = reg_burst_hold;
          end

          TRN_IDLE : begin
            next_burst_count = 4'b0000;
            next_burst_hold = 1'b0;
          end

          default : begin
            next_burst_count = 4'bxxxx;
            next_burst_hold = 1'bx;
          end

        endcase
    end


  always @ (negedge hresetn or posedge hclk)
    begin : p_burst_seq
      if (!hresetn)
        begin
          reg_burst_count <= 4'b0000;
          reg_burst_hold  <= 1'b0;
        end
      else
        begin
          reg_burst_count <= next_burst_count;
          reg_burst_hold  <= next_burst_hold;
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
             req_port_<<si_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
             hselm or htransm_int or hmastlockm_int or next_burst_hold or i_selected_port
           )
    begin : p_sel_port_comb
      no_port_next = 1'b0;
      selected_port_next = i_selected_port;

      if ( hmastlockm_int | next_burst_hold )
        selected_port_next = i_selected_port;
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
      else if ( req_port_<<si_name>> | ( (i_selected_port == <<idw_si_v>>'b<<bin_in>>) & hselm &
                              (htransm_int != TRN_IDLE) ) )
        selected_port_next = <<idw_si_v>>'b<<bin_in>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
      else if (hselm)
        selected_port_next = i_selected_port;
      else
        no_port_next = 1'b1;
    end


  always @ (negedge hresetn or posedge hclk)
    begin : p_selected_port_reg
      if (!hresetn)
        begin
          no_port        <= 1'b1;
          i_selected_port <= {<<idw_si_v>>{1'b0}};
        end
      else
        if (hreadym)
          begin
            no_port        <= no_port_next;
            i_selected_port <= selected_port_next;
          end
    end

  assign selected_port = i_selected_port;



endmodule

