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
module <<output_stage_name>> (


    input wire         hclk,
    input wire         hresetn,

//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    input wire         sel_op_<<si_name>>,
    input wire [<<addr>>:0]  addr_op_<<si_name>>,
//--------------------------------- << start user >> --------------------------------
    input wire [<<user>>:0]  auser_op_<<si_name>>,
//---------------------------------- << end user >> ---------------------------------
    input wire  [1:0]  trans_op_<<si_name>>,
    input wire         write_op_<<si_name>>,
    input wire  [2:0]  size_op_<<si_name>>,
    input wire  [2:0]  burst_op_<<si_name>>,
    input wire  [<<prot>>:0]  prot_op_<<si_name>>,
    input wire         nonsec_op_<<si_name>>,
    input wire         excl_op_<<si_name>>,
    input wire  [<<master_width>>:0]  master_op_<<si_name>>,
    input wire         mastlock_op_<<si_name>>,
    input wire [<<data>>:0]  wdata_op_<<si_name>>,
//--------------------------------- << start user >> --------------------------------
    input wire [<<user>>:0]  wuser_op_<<si_name>>,
//---------------------------------- << end user >> ---------------------------------

    input wire         transfer_request_<<si_name>>,
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
    output reg         active_op_<<si_name>>,
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

    output reg         hselm,
    output reg  [<<addr>>:0] haddrm,
//-------------------------------- << start user >> --------------------------------
    output reg  [<<user>>:0] hauserm,
//--------------------------------- << end user >> ---------------------------------
    output reg   [1:0] htransm,
    output reg         hwritem,
    output reg   [2:0] hsizem,
    output reg   [2:0] hburstm,
    output reg   [<<prot>>:0] hprotm,
    output reg         hnonsecm,
    output reg         hexclm,
    output reg   [<<master_width>>:0] hmasterm,
    output reg         hmastlockm,
    output wire        hreadymuxm,
//-------------------------------- << start user >> --------------------------------
    output reg  [<<user>>:0] hwuserm,
//--------------------------------- << end user >> ---------------------------------
    output reg  [<<data>>:0] hwdatam,

    input wire         hreadyoutm,
    input wire         hrespm

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


  wire          unused = hrespm;


    wire  [<<idw_si>>:0] selected_port;
    wire        no_port;

    reg   [<<idw_si>>:0] data_port;
    reg         data_no_port;

    reg         slave_sel;
    wire        i_hreadymuxm;

    wire        active_port;



  <<output_arb_name>> u_output_arb (

    .hclk                         (hclk),
    .hresetn                      (hresetn),

//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    .transfer_request_<<si_name>>        (transfer_request_<<si_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    .sel_op_<<si_name>>                  (sel_op_<<si_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    .trans_op_<<si_name>>                (trans_op_<<si_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
//----------------------------------- << start in >> --------------------------------
//---------------------------------- << start connection >> -------------------------
    .burst_op_<<si_name>>                (burst_op_<<si_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

    .hreadym                      (i_hreadymuxm),
    .hselm                        (hselm),
    .htransm                      (htransm),
    .hburstm                      (hburstm),
    .hmastlockm                   (hmastlockm),

    .selected_port                (selected_port),
    .no_port                      (no_port)

    );


  always @ (selected_port or no_port)
    begin : p_active_comb
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
      active_op_<<si_name>> = 1'b0;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

      if (~no_port)
        case (selected_port)
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<idw_si_v>>'b<<bin_in>> : active_op_<<si_name>> = 1'b1;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
          default : begin
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
            active_op_<<si_name>> = 1'bx;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
          end
        endcase
    end


assign active_port =
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             ( sel_op_<<si_name>> && selected_port==<<idw_si_v>>'b<<bin_in>> ) ||
//----------------------------- << end connection >> -------------------------
//------------------------------ << end in >> --------------------------------
             1'b0;


  always @ (
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             sel_op_<<si_name>> or addr_op_<<si_name>> or trans_op_<<si_name>> or write_op_<<si_name>> or
             size_op_<<si_name>> or burst_op_<<si_name>> or prot_op_<<si_name>> or nonsec_op_<<si_name>> or excl_op_<<si_name>> or
//---------------------------- << start user >> --------------------------------
             auser_op_<<si_name>> or
//----------------------------- << end user >> ---------------------------------
             master_op_<<si_name>> or mastlock_op_<<si_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
             selected_port or no_port or active_port
           )
    begin : p_addr_mux
      hselm       = 1'b0;
      haddrm      = {<<addr_v>>{1'b0}};
//---------------------------- << start user >> --------------------------------
      hauserm     = {<<user_v>>{1'b0}};
//----------------------------- << end user >> ---------------------------------
      htransm     = 2'b00;
      hwritem     = 1'b0;
      hsizem      = 3'b000;
      hnonsecm    = 1'b1;
      hexclm      = 1'b0;
      hburstm     = 3'b000;
      hprotm      = {<<prot_v>>{1'b0}};
      hmasterm    = {<<master_width_v>>{1'b0}};
      hmastlockm  = 1'b0;

      if (~no_port && active_port)
        case (selected_port)
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<idw_si_v>>'b<<bin_in>> :
            begin
              hselm       = sel_op_<<si_name>>;
              haddrm      = addr_op_<<si_name>>;
//---------------------------- << start user >> --------------------------------
              hauserm     = auser_op_<<si_name>>;
//----------------------------- << end user >> ---------------------------------
              htransm     = trans_op_<<si_name>>;
              hwritem     = write_op_<<si_name>>;
              hsizem      = size_op_<<si_name>>;
              hnonsecm    = nonsec_op_<<si_name>>;
              hexclm      = excl_op_<<si_name>>;
              hburstm     = burst_op_<<si_name>>;
              hprotm      = prot_op_<<si_name>>;
              hmasterm    = master_op_<<si_name>>;
              hmastlockm  = mastlock_op_<<si_name>>;
            end

//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
          default :
            begin
              hselm       = 1'bx;
              haddrm      = {<<addr_v>>{1'bx}};
//---------------------------- << start user >> --------------------------------
              hauserm     = {<<user_v>>{1'bx}};
//----------------------------- << end user >> ---------------------------------
              htransm     = 2'bxx;
              hwritem     = 1'bx;
              hsizem      = 3'bxxx;
              hnonsecm    = 1'bx;
              hexclm      = 1'bx;
              hburstm     = 3'bxxx;
              hprotm      = {<<prot_v>>{1'bx}};
              hmasterm    = {<<master_width_v>>{1'bx}};
              hmastlockm  = 1'bx;
            end
        endcase
    end


  always @ (negedge hresetn or posedge hclk)
    begin : p_prev_port
      if (~hresetn)
      begin
//------------------------------ << start rrin >> ------------------------------
//------------------------------ << end rrin >> ------------------------------
        data_port    <= <<idw_si_v>>'b<<bin_rrin>>;
        data_no_port <= 1'b1;
      end
      else
      begin
        if (i_hreadymuxm)
        begin
          data_port <= selected_port;
          data_no_port <= no_port;
        end
      end
    end


  always @ (
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
             wdata_op_<<si_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
//---------------------------- << start user >> --------------------------------
             wuser_op_<<si_name>> or
//----------------------------- << end user >> ---------------------------------
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
             data_no_port or data_port
           )
    begin : p_data_mux
      hwdatam = {<<data_v>>{1'b0}};
//---------------------------- << start user >> --------------------------------
      hwuserm  = {<<user_v>>{1'b0}};
//----------------------------- << end user >> ---------------------------------

      if (~data_no_port)
        case (data_port)
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<idw_si_v>>'b<<bin_in>> :
//---------------------------- << start user >> --------------------------------
            begin
//----------------------------- << end user >> ---------------------------------
              hwdatam  = wdata_op_<<si_name>>;
//---------------------------- << start user >> --------------------------------
              hwuserm  = wuser_op_<<si_name>>;
            end
//----------------------------- << end user >> ---------------------------------
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------
          default :
//---------------------------- << start user >> --------------------------------
            begin
//----------------------------- << end user >> ---------------------------------
              hwdatam = {<<data_v>>{1'bx}};
//---------------------------- << start user >> --------------------------------
              hwuserm  = {<<user_v>>{1'bx}};
            end
//----------------------------- << end user >> ---------------------------------
        endcase
    end


  always @ (negedge hresetn or posedge hclk)
    begin : p_slave_sel_reg
      if (~hresetn)
        slave_sel <= 1'b0;
      else
        if (i_hreadymuxm)
          slave_sel  <= hselm;
    end

  assign i_hreadymuxm = slave_sel ? hreadyoutm : 1'b1;

  assign hreadymuxm = i_hreadymuxm;


endmodule

