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
//      Checked In          : Wed Nov 16 15:18:56 2016 +0000
//
//      Revision            : 2abe3df
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
<<template_begin>>
<<copyright_header>>
<<version_control_header>>
<<timescale_directive>>
module <<input_stage_name>> (


    input  wire           hclk,
    input  wire           hresetn,
    input  wire           hsels,
    input  wire    [<<addr>>:0] haddrs,
//---------------------------- << start user >> --------------------------------
    input  wire    [<<user>>:0] hausers,
//----------------------------- << end user >> ---------------------------------
    input  wire     [1:0] htranss,
    input  wire           hwrites,
    input  wire     [2:0] hsizes,
    input  wire     [2:0] hbursts,
    input  wire     [<<prot>>:0] hprots,
    input  wire           hnonsec,
    input  wire           hexcl,
    input  wire     [<<master_width>>:0] hmasters,
    input  wire           hmastlocks,
    input  wire           hreadys,
    output wire           hreadyouts,
    output wire           hresps,
    output wire           hexokays,

    output wire           transfer_request,

    output wire           sel_ip,
    output wire    [<<addr>>:0] addr_ip,
//---------------------------- << start user >> --------------------------------
    output wire    [<<user>>:0] auser_ip,
//----------------------------- << end user >> ---------------------------------
    output wire     [1:0] trans_ip,
    output wire           write_ip,
    output wire     [2:0] size_ip,
    output wire     [2:0] burst_ip,
    output wire     [<<prot>>:0] prot_ip,
    output wire           hnonsec_ip,
    output wire           hexcl_ip,
    output wire    [<<master_width>>:0]  master_ip,
    output wire           mastlock_ip,
    output wire           ready_ip,

    input  wire           active_ip,
    input  wire           readyout_ip_addr,
    input  wire           readyout_ip_data,
    input  wire           exokay_ip,
    input  wire           resp_ip

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

localparam RSP_OKAY  =  1'b0;
localparam RSP_ERR   =  1'b1;


    wire        load_reg;
    reg         pend_tran_reg;
    wire        addr_valid;

    reg  [<<addr>>:0] reg_addr;
//---------------------------- << start user >> --------------------------------
    reg  [<<user>>:0] reg_auser;
//----------------------------- << end user >> ---------------------------------
    reg         reg_write;
    reg   [2:0] reg_size;
    reg   [2:0] reg_burst;
    reg   [<<prot>>:0] reg_prot;
    reg         reg_hnonsec;
    reg         reg_hexcl;
    reg   [<<master_width>>:0] reg_master;
    reg         reg_mastlock;

    wire  [1:0] trans_int;
    wire  [2:0] burst_int;

    reg   [3:0] offset_addr;
    reg   [3:0] check_addr;
    reg         burst_override;
    wire        burst_override_next;
//---------------------------- << start nolat_arb >> --------------------------------
    reg         burst_override_prev;
//---------------------------- << end nolat_arb >> --------------------------------
    reg         bound;
    wire        bound_next;
    wire        bound_en;

    reg         data_phase;


  assign addr_valid = hsels & htranss[1];

  assign load_reg   = addr_valid & hreadys & ~(active_ip & readyout_ip_addr);



  always @ (negedge hresetn or posedge hclk)
    begin : p_pend_tran_reg
      if (~hresetn)
        pend_tran_reg <= 1'b0;
      else
        if (load_reg)
          pend_tran_reg <= 1'b1;
        else if (active_ip & readyout_ip_addr & readyout_ip_data)
          pend_tran_reg <= 1'b0;
    end

  assign  transfer_request  = (hsels && htranss[1] && hreadys) ||
                              pend_tran_reg;


  always @ (posedge hclk or negedge hresetn)
    begin : p_holding_reg_seq1
      if (~hresetn)
        begin
          reg_addr     <= {<<addr_v>>{1'b0}};
//---------------------------- << start user >> --------------------------------
          reg_auser    <= {<<user_v>>{1'b0}};
//----------------------------- << end user >> ---------------------------------
          reg_write    <= 1'b0 ;
          reg_size     <= 3'b000;
          reg_burst    <= 3'b000;
          reg_prot     <= {<<prot_v>>{1'b0}};
          reg_hnonsec  <= 1'b1;
          reg_hexcl    <= 1'b0;
          reg_master   <= {<<master_width_v>>{1'b0}};
          reg_mastlock <= 1'b0 ;
        end
      else
        if (load_reg)
          begin
            reg_addr     <= haddrs;
//---------------------------- << start user >> --------------------------------
            reg_auser    <= hausers;
//----------------------------- << end user >> ---------------------------------
            reg_write    <= hwrites;
            reg_size     <= hsizes;
            reg_burst    <= htranss == TRN_SEQ ? BUR_INCR : hbursts;
            reg_prot     <= hprots;
            reg_hnonsec  <= hnonsec;
            reg_hexcl    <= hexcl;
            reg_master   <= hmasters;
            reg_mastlock <= hmastlocks;
          end
    end




  assign  sel_ip         = pend_tran_reg ? 1'b1          : hsels;
  assign  addr_ip        = pend_tran_reg ? reg_addr      : haddrs;
//---------------------------- << start user >> --------------------------------
  assign  auser_ip       = pend_tran_reg ? reg_auser     : ~hreadys | ~htranss[1] ? {<<user_v>>{1'b0}} : hausers;
//----------------------------- << end user >> ---------------------------------
  assign  write_ip       = pend_tran_reg ? reg_write     : hwrites;
  assign  size_ip        = pend_tran_reg ? reg_size      : hsizes;
  assign  prot_ip        = pend_tran_reg ? reg_prot      : hprots;
  assign  hnonsec_ip     = pend_tran_reg ? reg_hnonsec   : hnonsec;
  assign  hexcl_ip       = pend_tran_reg ? reg_hexcl     : hexcl;
  assign  master_ip      = pend_tran_reg ? reg_master    : hmasters;
  assign  mastlock_ip    = pend_tran_reg ? reg_mastlock  : hmastlocks;
  assign  ready_ip       = pend_tran_reg ? 1'b1          : hreadys || ~data_phase;

  assign  trans_int      = pend_tran_reg ? TRN_NONSEQ    : ~hreadys ? {1'b0,htranss[0]} : htranss;
  assign  burst_int      = pend_tran_reg ? reg_burst     : hbursts;

//---------------------------- << start registered_arb >> --------------------------------
  assign trans_ip = (burst_override & bound) ? {trans_int[1], 1'b0}
                                             : trans_int;

  assign burst_ip = (burst_override & (trans_int != TRN_NONSEQ)) ? BUR_INCR
                                                                 : burst_int;
//---------------------------- << end registered_arb >> --------------------------------
//---------------------------- << start nolat_arb >> --------------------------------
  assign trans_ip = (burst_override & bound) |
                    (burst_override & ~burst_override_prev) ? {trans_int[1], 1'b0}
                                                            : trans_int;

  assign burst_ip = (burst_override & (trans_int != TRN_NONSEQ)) ? BUR_INCR
                                                                 : burst_int;
//---------------------------- << end nolat_arb >> --------------------------------


  always @ (negedge hresetn or posedge hclk)
    begin : p_data_valid
      if (~hresetn)
        data_phase <= 1'b0;
      else
       if (hreadys)
        data_phase  <= addr_valid;
    end


  assign hreadyouts = (data_phase) && ~pend_tran_reg ? readyout_ip_data
                                                     : ~pend_tran_reg;
  assign hresps     = (data_phase) && ~pend_tran_reg ? resp_ip
                                                     : RSP_OKAY;
  assign hexokays   = (data_phase) && ~pend_tran_reg ? exokay_ip && readyout_ip_data && ~resp_ip
                                                     : 1'b0;



//---------------------------- << start registered_arb >> --------------------------------
  assign burst_override_next  = ~htranss[0]            ? 1'b0
                              :  htranss[0] & load_reg ? 1'b1
                                                       : burst_override;
//---------------------------- << end registered_arb >> --------------------------------
//---------------------------- << start nolat_arb >> --------------------------------
  assign burst_override_next  = ~htranss[0]                                    ? 1'b0
                              :  htranss[0] && hsels && hreadys && ~active_ip  ? 1'b1
                                                                               : burst_override;
//---------------------------- << end nolat_arb >> --------------------------------

  always @ (negedge hresetn or posedge hclk)
    begin : p_burst_overrideseq
      if (~hresetn)
        burst_override <= 1'b0;
      else
        burst_override <= burst_override_next;
    end

//---------------------------- << start nolat_arb >> --------------------------------
  always @ (negedge hresetn or posedge hclk)
    begin : p_burst_override_prevseq
      if (~hresetn)
        burst_override_prev <= 1'b0;
      else
        if (active_ip | ~burst_override)
          burst_override_prev <= burst_override;
        else
          burst_override_prev <= 1'b0;
    end
//---------------------------- << end nolat_arb >> --------------------------------


  always @ (haddrs or hsizes)
    begin : p_offset_addr_comb
      case (hsizes)
        3'b000 : offset_addr = haddrs[3:0];
        3'b001 : offset_addr = haddrs[4:1];
        3'b010 : offset_addr = haddrs[5:2];
        3'b011 : offset_addr = haddrs[6:3];

        3'b100, 3'b101, 3'b110, 3'b111 :
          offset_addr = haddrs[3:0];

        default : offset_addr = 4'bxxxx;
      endcase
    end

  always @ (offset_addr or hbursts)
    begin : p_check_addr_comb
      case (hbursts)
        BUR_WRAP4 : begin
          check_addr[1:0] = offset_addr[1:0];
          check_addr[3:2] = 2'b11;
        end

        BUR_WRAP8 : begin
          check_addr[2:0] = offset_addr[2:0];
          check_addr[3]   = 1'b1;
        end

        BUR_WRAP16 :
          check_addr[3:0] = offset_addr[3:0];

        BUR_SINGLE, BUR_INCR, BUR_INCR4, BUR_INCR8, BUR_INCR16 :
          check_addr[3:0] = 4'b0000;

        default : check_addr[3:0] = 4'bxxxx;
      endcase
    end

  assign bound_next = ( check_addr == 4'b1111 );

  assign bound_en = ( htranss[1] & hreadys );

  always @ (negedge hresetn or posedge hclk)
    begin : p_bound_seq
      if (~hresetn)
        bound <= 1'b0;
      else
        if (bound_en)
          bound <= bound_next;
    end


endmodule

