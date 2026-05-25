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
//      Checked In          : Wed Oct 12 10:54:01 2016 +0100
//
//      Revision            : 8d376ca
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
    output wire       no_port
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

    reg  [<<idw_si>>:0] next_selected_port;
    reg                 next_no_port;
    reg  [<<idw_si>>:0] i_selected_port;
    reg                 i_no_port;

    reg  [3:0] next_burst_remain;
    reg  [3:0] reg_burst_remain;
    reg        next_burst_hold;
    reg        reg_burst_hold;

    reg  [1:0] reg_early_incr_count;
    wire [1:0] next_early_incr_count;

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  wire        req_port_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

  reg         hsel_lock;
  wire        next_hsel_lock;
  wire        hlock_arb;

    reg [1:0] htransm_int;
    reg [2:0] hburstm_int;
    reg       hmastlockm_int;
    always @(*)
    begin
       htransm_int    = htransm;
       hburstm_int    = hburstm;
       hmastlockm_int = hmastlockm;
    end



  always @ (htransm_int or hselm or hburstm_int or reg_burst_remain or reg_burst_hold or
            reg_early_incr_count)
    begin : p_next_burst_remain_comb
      if (~hselm)
        begin
          next_burst_remain = 4'b0000;
          next_burst_hold  = 1'b0;
        end

      else
        case (htransm_int)

          TRN_NONSEQ : begin
            case (hburstm_int)
              BUR_INCR16, BUR_WRAP16 : begin
                next_burst_remain = 4'd15;
                next_burst_hold = 1'b1;
              end

              BUR_INCR8, BUR_WRAP8 : begin
                next_burst_remain = 4'd7;
                next_burst_hold = 1'b1;
              end

              BUR_INCR4, BUR_WRAP4 : begin
                next_burst_remain = 4'd3;
                next_burst_hold = 1'b1;
              end

              BUR_INCR : begin
                if (reg_early_incr_count == 2'b01)
                  begin
                    next_burst_remain = 4'd0;
                    next_burst_hold = 1'b0;
                  end
                else
                  begin
                    next_burst_remain = 4'd3;
                    next_burst_hold = 1'b1;
                  end
              end

              BUR_SINGLE : begin
                next_burst_remain = 4'd0;
                next_burst_hold  = 1'b0;
              end

              default : begin
                next_burst_remain = 4'bxxxx;
                next_burst_hold = 1'bx;
              end

            endcase

            if (reg_burst_remain > 4'd0)
              next_burst_hold = 1'b0;

          end

          TRN_SEQ : begin
            if (reg_burst_remain == 4'd1)
              begin
                next_burst_hold = 1'b0;
                next_burst_remain = 4'd0;
              end
            else
              begin
                next_burst_hold = reg_burst_hold;
                if (reg_burst_remain != 4'd0)
                   next_burst_remain = reg_burst_remain - 1'b1;
                else
                   next_burst_remain = 4'd0;
              end
          end

          TRN_BUSY : begin
            next_burst_remain = reg_burst_remain;
            next_burst_hold = reg_burst_hold;
          end

          TRN_IDLE : begin
            next_burst_remain = 4'd0;
            next_burst_hold = 1'b0;
          end

          default : begin
            next_burst_remain = 4'bxxxx;
            next_burst_hold = 1'bx;
          end

        endcase
    end



  assign next_early_incr_count = (!next_burst_hold) ? 2'b00 :
                               (reg_burst_hold & (htransm_int == TRN_NONSEQ)) ?
                                reg_early_incr_count + 1'b1 :
                                reg_early_incr_count;

  always @ (negedge hresetn or posedge hclk)
    begin : p_burst_seq
      if (~hresetn)
        begin
          reg_burst_remain     <= 4'b0000;
          reg_burst_hold       <= 1'b0;
          reg_early_incr_count <= 2'b00;
        end
      else
        if (hreadym)
          begin
            reg_burst_remain     <= next_burst_remain;
            reg_burst_hold       <= next_burst_hold;
            reg_early_incr_count <= next_early_incr_count;
          end
    end


//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign req_port_<<si_name>> = transfer_request_<<si_name>> & sel_op_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

  assign next_hsel_lock = (hselm & htransm_int[1] & hmastlockm_int) ? 1'b1 :
                          (hmastlockm_int == 1'b0) ? 1'b0 :
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



  always @ (
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             req_port_<<si_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
             hlock_arb or next_burst_hold or hselm or i_no_port or i_selected_port
           )
    begin : p_sel_port_comb
      next_no_port = 1'b0;
      next_selected_port = i_selected_port;

      if ( hlock_arb | next_burst_hold )
        next_selected_port = i_selected_port;
      else if (i_no_port)
        begin
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<rrelse>>if (req_port_<<si_name>>)
            next_selected_port = <<idw_si_v>>'b<<bin_in>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end in >> ----------------------------------
          else
            next_no_port = 1'b1;
        end
      else
        case (i_selected_port)
//------------------------------ << start rrin >> ------------------------------
          <<idw_si_v>>'b<<bin_rrin>> : begin
//------------------------------ << start rridx >> -----------------------------
            <<rrelse>>if (req_port_<<rridx_name>>)
              next_selected_port = <<idw_si_v>>'b<<bin_rridx>>;
//------------------------------ << end rridx >> -------------------------------
            else if (hselm)
              next_selected_port = <<idw_si_v>>'b<<bin_rrin>>;
            else
              next_no_port = 1'b1;
          end

//------------------------------ << end rrin >> --------------------------------
          default : begin
            next_selected_port = {<<idw_si_v>>{1'bx}};
            next_no_port = 1'bx;
          end
      endcase
    end

  always @ (negedge hresetn or posedge hclk)
    begin : p_selected_port_reg
      if (~hresetn)
        begin
          i_no_port      <= 1'b1;
          i_selected_port <= {<<idw_si_v>>{1'b0}};
        end
      else
        if (hreadym)
          begin
            i_no_port      <= next_no_port;
            i_selected_port <= next_selected_port;
          end
    end

  assign selected_port = i_selected_port;
  assign no_port       = i_no_port;


endmodule

