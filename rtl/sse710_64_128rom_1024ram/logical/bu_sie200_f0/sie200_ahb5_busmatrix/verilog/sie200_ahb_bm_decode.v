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
module <<matrix_decode_name>> (

    input  wire         hclk,
    input  wire         hresetn,

//---------------------------- << start remap >> -------------------------------
    input  wire   [<<idw_remap>>:0] remapping_dec,

//----------------------------- << end remap >> --------------------------------
    input  wire         hreadys,
    input  wire         sel_dec,
    input  wire [<<addr>>:10] decode_addr_dec,
    input  wire   [1:0] trans_dec,

//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
    input  wire         active_dec_<<mi_name>>,
    input  wire         readyout_dec_<<mi_name>>,
    input  wire         resp_dec_<<mi_name>>,
    input  wire  [<<data>>:0] rdata_dec_<<mi_name>>,
    input  wire         exokay_dec_<<mi_name>>,
//---------------------------- << start user >> --------------------------------
    input  wire  [<<user>>:0] ruser_dec_<<mi_name>>,
//----------------------------- << end user >> ---------------------------------

//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
    output reg         sel_dec_<<mi_name>>,
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------

    output reg         active_dec,
    output reg         hreadyouts_addr,
    output reg         hreadyouts_data,
    output reg         hresps,
    output reg         hexokay,
//---------------------------- << start user >> --------------------------------
    output reg  [<<user>>:0] hrusers,
//----------------------------- << end user >> ---------------------------------
    output reg  [<<data>>:0] hrdatas

);



    reg     [<<idw_mi>>:0] addr_out_port;
    reg     [<<idw_mi>>:0] data_out_port;

    reg           sel_dft_slv;
    wire          readyout_dft_slv;
    wire          exokay_dft_slv;
    wire          resp_dft_slv;




  <<default_slave_name>> u_default_slave (

    .hclk        (hclk),
    .hresetn     (hresetn),

    .hsel        (sel_dft_slv),
    .htrans      (trans_dec),
    .hready      (hreadys),
    .hreadyout   (readyout_dft_slv),
    .hresp       (resp_dft_slv),
    .hexokay     (exokay_dft_slv)

    );




  always @ (
//----------------------------- << start map >> --------------------------------
             decode_addr_dec or data_out_port or trans_dec
//----------------------------- << end map >> ----------------------------------
//---------------------------- << start remap >> -------------------------------
             decode_addr_dec or data_out_port or trans_dec or remapping_dec
//----------------------------- << end remap >> --------------------------------
           )
    begin : p_addr_out_port_comb

      addr_out_port = data_out_port;

      if (trans_dec != 2'b00)

//----------------------------- << start addr_remap_all >> -------------------------
//----------------------------- << start remap_region >> -----------------------
        <<mdelse>>if ((decode_addr_dec >= <<mem_lo>>) & (decode_addr_dec <= <<mem_hi>>)<<active_cond>>)
           addr_out_port = <<idw_mi_v>>'b0<<bin_out>>;

//------------------------------ << end remap_region >> -------------------------
//----------------------------- << end addr_remap_all >> ---------------------------
//----------------------------- << start addr_map >> ---------------------------
//----------------------------- << start addr_region >> ------------------------
        <<mdelse>>if ((decode_addr_dec >= <<mem_lo>>) & (decode_addr_dec <= <<mem_hi>>)<<active_cond>>)
           addr_out_port = <<idw_mi_v>>'b0<<bin_out>>;

//------------------------------ << end addr_region >> -------------------------
//----------------------------- << end addr_map >> -----------------------------
        <<mdelse>>
          addr_out_port = <<idw_mi_v>>'b<<dsid_bin>>;

    end

  always @ (sel_dec or addr_out_port)
    begin : p_sel_comb
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      sel_dec_<<mi_name>> = 1'b0;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      sel_dft_slv = 1'b0;

      if (sel_dec)
        case (addr_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
          <<idw_mi_v>>'b0<<bin_out>> : sel_dec_<<mi_name>> = 1'b1;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
          <<idw_mi_v>>'b<<dsid_bin>> : sel_dft_slv = 1'b1;
          default : begin
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
            sel_dec_<<mi_name>> = 1'bx;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
            sel_dft_slv = 1'bx;
          end
        endcase
    end

  always @ (
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             active_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             addr_out_port
           )
    begin : p_active_comb
      case (addr_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
        <<idw_mi_v>>'b0<<bin_out>> : active_dec = active_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
        <<idw_mi_v>>'b<<dsid_bin>> : active_dec = 1'b1;
        default : active_dec = 1'bx;
      endcase
    end


  always @ (
             readyout_dft_slv or
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             readyout_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             addr_out_port
           )
  begin : p_ready_addr_comb
    case (addr_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hreadyouts_addr = readyout_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hreadyouts_addr = readyout_dft_slv;
      default : hreadyouts_addr = 1'bx;
    endcase
  end



  always @ (negedge hresetn or posedge hclk)
    begin : p_data_out_port_seq
      if (~hresetn)
        data_out_port <= <<idw_mi_v>>'b<<dsid_bin>>;
      else
        if (hreadys)
          data_out_port <= addr_out_port;
    end

  always @ (
             readyout_dft_slv or
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             readyout_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             data_out_port
           )
  begin : p_ready_data_comb
    case (data_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hreadyouts_data = readyout_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hreadyouts_data = readyout_dft_slv;
      default : hreadyouts_data = 1'bx;
    endcase
  end

  always @ (
             resp_dft_slv or
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             resp_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             data_out_port
           )
  begin : p_resp_comb
    case (data_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hresps = resp_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hresps = resp_dft_slv;
      default : hresps = 1'bx;
    endcase
  end

  always @ (
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             rdata_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             data_out_port
           )
  begin : p_rdata_comb
    case (data_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hrdatas = rdata_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hrdatas = {<<data_v>>{1'b0}};
      default : hrdatas = {<<data_v>>{1'bx}};
    endcase
  end

  always @ (
             exokay_dft_slv or
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             exokay_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             data_out_port
           )
  begin : p_exokay_comb
    case (data_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hexokay = exokay_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hexokay = exokay_dft_slv;
      default : hexokay = 1'bx;
    endcase
  end

//---------------------------- << start user >> --------------------------------
  always @ (
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
             ruser_dec_<<mi_name>> or
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
             data_out_port
           )
  begin : p_ruser_comb
    case (data_out_port)
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
      <<idw_mi_v>>'b0<<bin_out>> : hrusers = ruser_dec_<<mi_name>>;
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
      <<idw_mi_v>>'b<<dsid_bin>> : hrusers = {<<user_v>>{1'b0}};
      default : hrusers = {<<user_v>>{1'bx}};
    endcase
  end
//----------------------------- << end user >> ---------------------------------


endmodule

