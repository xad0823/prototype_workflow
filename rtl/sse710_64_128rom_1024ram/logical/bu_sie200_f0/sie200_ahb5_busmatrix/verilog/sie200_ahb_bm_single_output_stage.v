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
    output wire        active_op_<<si_name>>,
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

    output wire        hselm,
    output wire[<<addr>>:0] haddrm,
//-------------------------------- << start user >> --------------------------------
    output wire[<<user>>:0] hauserm,
//--------------------------------- << end user >> ---------------------------------
    output wire  [1:0] htransm,
    output wire        hwritem,
    output wire  [2:0] hsizem,
    output wire  [2:0] hburstm,
    output wire  [<<prot>>:0] hprotm,
    output wire        hnonsecm,
    output wire        hexclm,
    output wire  [<<master_width>>:0] hmasterm,
    output wire        hmastlockm,
    output wire        hreadymuxm,
//-------------------------------- << start user >> --------------------------------
    output wire [<<user>>:0] hwuserm,
//--------------------------------- << end user >> ---------------------------------
    output wire [<<data>>:0] hwdatam,

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

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
    wire        req_port_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

    wire        no_port;

    reg         hsel_lock;
    wire        next_hsel_lock;
    wire        hlock_arb;

    reg         slave_sel;
    wire        i_hreadymuxm;

    reg         prev_no_port;

    reg         waiting;


//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign req_port_<<si_name>> = transfer_request_<<si_name>> & sel_op_<<si_name>>;

  always @ (posedge hclk or negedge hresetn)
  begin : p_waiting_reg
    if (~hresetn)
      waiting    <= 1'b0;
    else
      waiting    <= ~i_hreadymuxm && hselm && htransm != TRN_IDLE;
  end

  wire rearbitration_point = ~hlock_arb && ~waiting && (
                                          prev_no_port ||
                                          ~sel_op_<<si_name>> ||
                                          (trans_op_<<si_name>> == TRN_IDLE ) ||
                                          (trans_op_<<si_name>> == TRN_NONSEQ ));

  assign no_port       = rearbitration_point ? ~req_port_<<si_name>> : prev_no_port;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign active_op_<<si_name>> = !no_port;


  assign hselm = !no_port && sel_op_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------


//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign haddrm      = ( ~no_port && hselm ) ? addr_op_<<si_name>>   : {<<addr_v>>{1'b0}};
//---------------------------- << start user >> --------------------------------
  assign hauserm     = ( ~no_port && hselm ) ? auser_op_<<si_name>>  : {<<user_v>>{1'b0}};
//----------------------------- << end user >> ---------------------------------
  assign htransm     = ( ~no_port && hselm ) ? trans_op_<<si_name>>  : TRN_IDLE;
  assign hwritem     =   ~no_port && hselm & write_op_<<si_name>>;
  assign hnonsecm    = ( ~no_port && hselm ) ? nonsec_op_<<si_name>> : 1'b1;
  assign hexclm      =   ~no_port && hselm & excl_op_<<si_name>>;
  assign hsizem      = ( ~no_port && hselm ) ? size_op_<<si_name>>   : 3'b000;
  assign hburstm     = ( ~no_port && hselm ) ? burst_op_<<si_name>>  : 3'b000;
  assign hprotm      = ( ~no_port && hselm ) ? prot_op_<<si_name>>   : {<<prot_v>>{1'b0}};
  assign hmasterm    = ( ~no_port && hselm ) ? master_op_<<si_name>> : {<<master_width_v>>{1'b0}};
  assign hmastlockm  =   ~no_port && hselm & mastlock_op_<<si_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------


  always @ (negedge hresetn or posedge hclk)
    begin : p_prev_port
      if (~hresetn)
        prev_no_port <= 1'b1;
      else
        prev_no_port <= no_port;
    end


  assign next_hsel_lock = (hselm & htransm[1] & hmastlockm) ? 1'b1 :
                          (hmastlockm == 1'b0) ? 1'b0 :
                          hsel_lock;

  always @ (negedge hresetn or posedge hclk)
    begin : p_hsel_lock
      if (~hresetn)
        hsel_lock <= 1'b0;
      else
        if (i_hreadymuxm)
          hsel_lock <= next_hsel_lock;
    end

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign hlock_arb = hsel_lock;
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------


//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
  assign hwdatam  = wdata_op_<<si_name>>;
//---------------------------- << start user >> --------------------------------
  assign hwuserm  = wuser_op_<<si_name>>;
//----------------------------- << end user >> ---------------------------------
//------------------------------ << end connection >> --------------------------
//------------------------------- << end in >> ---------------------------------


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

