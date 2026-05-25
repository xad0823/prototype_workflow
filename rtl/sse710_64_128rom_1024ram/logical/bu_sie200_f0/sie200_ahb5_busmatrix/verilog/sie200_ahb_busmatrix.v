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
//----------------------------- << start user >> -------------------------------
//------------------------------ << end user >> --------------------------------
<<timescale_directive>>
module <<bus_matrix_name>> (


    input  wire        hclk,
    input  wire        hresetn,

//------------------------------ << start in >> --------------------------------
//------------------------------ << start m_hsel >> --------------------------------
    input  wire        hsel_<<si_name>>,
//------------------------------ << end m_hsel >> --------------------------------
    input  wire [<<addr>>:0] haddr_<<si_name>>,
    input  wire [1:0]  htrans_<<si_name>>,
    input  wire        hwrite_<<si_name>>,
    input  wire [2:0]  hsize_<<si_name>>,
    input  wire [2:0]  hburst_<<si_name>>,
    input  wire [<<prot>>:0]  hprot_<<si_name>>,
    input  wire [<<master_width>>:0]  hmaster_<<si_name>>,
    input  wire [<<data>>:0] hwdata_<<si_name>>,
    input  wire        hmastlock_<<si_name>>,
//----------------------------- << start target_slave >> ------------------------------
    input  wire        hready_<<si_name>>,
//----------------------------- << end target_slave >> ------------------------------
    input  wire        hnonsec_<<si_name>>,
    input  wire        hexcl_<<si_name>>,
//---------------------------- << start user >> --------------------------------
    input  wire [<<user>>:0] hauser_<<si_name>>,
    input  wire [<<user>>:0] hwuser_<<si_name>>,
//----------------------------- << end user >> ---------------------------------

//------------------------------- << end in >> ---------------------------------

//----------------------------- << start out >> --------------------------------
    input  wire [<<data>>:0] hrdata_<<mi_name>>,
    input  wire        hreadyout_<<mi_name>>,
    input  wire        hresp_<<mi_name>>,
    input  wire        hexokay_<<mi_name>>,
//---------------------------- << start user >> --------------------------------
    input  wire [<<user>>:0] hruser_<<mi_name>>,
//----------------------------- << end user >> ---------------------------------

//------------------------------ << end out >> ---------------------------------

//----------------------------- << start out >> --------------------------------
    output wire        hsel_<<mi_name>>,
    output wire [<<addr>>:0] haddr_<<mi_name>>,
    output wire [1:0]  htrans_<<mi_name>>,
    output wire        hwrite_<<mi_name>>,
    output wire [2:0]  hsize_<<mi_name>>,
    output wire [2:0]  hburst_<<mi_name>>,
    output wire [<<prot>>:0]  hprot_<<mi_name>>,
    output wire [<<master_width>>:0]  hmaster_<<mi_name>>,
    output wire [<<data>>:0] hwdata_<<mi_name>>,
    output wire        hmastlock_<<mi_name>>,
    output wire        hreadymux_<<mi_name>>,
    output wire        hnonsec_<<mi_name>>,
    output wire        hexcl_<<mi_name>>,
//---------------------------- << start user >> --------------------------------
    output wire [<<user>>:0] hauser_<<mi_name>>,
    output wire [<<user>>:0] hwuser_<<mi_name>>,
//----------------------------- << end user >> ---------------------------------

//------------------------------ << end out >> ---------------------------------

//------------------------------ << start in >> --------------------------------
    output wire [<<data>>:0] hrdata_<<si_name>>,
//----------------------------- << start target_slave >> ------------------------------
    output wire        hreadyout_<<si_name>>,
//----------------------------- << end target_slave >> ------------------------------
//----------------------------- << start initiator_slave >> ------------------------------
    output wire        hready_<<si_name>>,
//----------------------------- << end initiator_slave >> ------------------------------
    output wire        hresp_<<si_name>>,
    output wire        hexokay_<<si_name>><<colon_remap_user>>
//---------------------------- << start user >> --------------------------------
    output wire [<<user>>:0] hruser_<<si_name>><<colon_remap>>
//----------------------------- << end user >> ---------------------------------

//------------------------------- << end in >> ---------------------------------
//---------------------------- << start remap_port >> -------------------------------
    input  wire [<<remap_width>>:0] remap

//---------------------------- << end remap_port >> -------------------------------
);


//----------------------------- << start in >> ---------------------------------

    wire         i_sel_<<si_name>>;
    wire  [<<addr>>:0] i_addr_<<si_name>>;
    wire   [1:0] i_trans_<<si_name>>;
    wire         i_write_<<si_name>>;
    wire   [2:0] i_size_<<si_name>>;
    wire   [2:0] i_burst_<<si_name>>;
    wire   [<<prot>>:0] i_prot_<<si_name>>;
    wire         i_nonsec_<<si_name>>;
    wire         i_excl_<<si_name>>;
    wire   [<<master_width>>:0] i_master_<<si_name>>;
    wire         i_mastlock_<<si_name>>;
    wire         i_hready_<<si_name>>;
    wire         i_active_<<si_name>>;
    wire         i_transfer_request<<si_name>>;
    wire         i_readyout_addr_<<si_name>>;
    wire         i_readyout_data_<<si_name>>;
    wire         i_resp_<<si_name>>;
    wire         i_exokay_<<si_name>>;
//---------------------------- << start user >> --------------------------------
    wire  [<<user>>:0] i_auser_<<si_name>>;
//----------------------------- << end user >> ---------------------------------
//------------------------------ << end in >> ----------------------------------

//----------------------------- << start in >> ---------------------------------
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
    wire         i_sel_<<si_name>>_to_<<mi_name>>;
    wire         i_active_<<si_name>>_to_<<mi_name>>;

//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
//------------------------------ << end in >> ----------------------------------
//----------------------------- << start out >> --------------------------------
    wire         i_hready_mux_<<mi_name>>;
//------------------------------ << end out >> ---------------------------------



//----------------------------- << start in >> ---------------------------------
  <<input_stage_name>> u_input_stage_<<si_name>> (

    .hclk       (hclk),
    .hresetn    (hresetn),

//----------------------------- << start m_hsel >> ------------------------------
    .hsels              (hsel_<<si_name>>),
//----------------------------- << end m_hsel >> ------------------------------
//----------------------------- << start no_m_hsel >> ------------------------------
    .hsels              (1'b1),
//----------------------------- << end no_m_hsel >> ------------------------------
    .haddrs             (haddr_<<si_name>>),
    .htranss            (htrans_<<si_name>>),
    .hwrites            (hwrite_<<si_name>>),
    .hsizes             (hsize_<<si_name>>),
    .hbursts            (hburst_<<si_name>>),
    .hprots             (hprot_<<si_name>>),
    .hnonsec            (hnonsec_<<si_name>>),
    .hexcl              (hexcl_<<si_name>>),
    .hmasters           (hmaster_<<si_name>>),
    .hmastlocks         (hmastlock_<<si_name>>),
    .hreadys            (hready_<<si_name>>),
    .hexokays           (hexokay_<<si_name>>),
//---------------------------- << start user >> --------------------------------
    .hausers            (hauser_<<si_name>>),
//----------------------------- << end user >> ---------------------------------

    .active_ip          (i_active_<<si_name>>),
    .readyout_ip_addr   (i_readyout_addr_<<si_name>>),
    .readyout_ip_data   (i_readyout_data_<<si_name>>),
    .resp_ip            (i_resp_<<si_name>>),
    .exokay_ip          (i_exokay_<<si_name>>),

//----------------------------- << start target_slave >> ------------------------------
    .hreadyouts         (hreadyout_<<si_name>>),
//----------------------------- << end target_slave >> ------------------------------
//----------------------------- << start initiator_slave >> ------------------------------
    .hreadyouts         (hready_<<si_name>>),
//----------------------------- << end initiator_slave >> ------------------------------
    .hresps             (hresp_<<si_name>>),

    .sel_ip             (i_sel_<<si_name>>),
    .addr_ip            (i_addr_<<si_name>>),
//---------------------------- << start user >> --------------------------------
    .auser_ip           (i_auser_<<si_name>>),
//----------------------------- << end user >> ---------------------------------
    .trans_ip           (i_trans_<<si_name>>),
    .write_ip           (i_write_<<si_name>>),
    .size_ip            (i_size_<<si_name>>),
    .burst_ip           (i_burst_<<si_name>>),
    .prot_ip            (i_prot_<<si_name>>),
    .hnonsec_ip         (i_nonsec_<<si_name>>),
    .hexcl_ip           (i_excl_<<si_name>>),
    .master_ip          (i_master_<<si_name>>),
    .mastlock_ip        (i_mastlock_<<si_name>>),
    .ready_ip           (i_hready_<<si_name>>),
    .transfer_request   (i_transfer_request<<si_name>>)

    );


//------------------------------ << end in >> ----------------------------------
//------------------------------ << start in >> --------------------------------
  <<matrix_decode_name>> u_decode_<<si_name>> (

    .hclk               (hclk),
    .hresetn            (hresetn),

//---------------------------- << start remap >> -------------------------------
    .remapping_dec      ( <<remapping_vector>> ),

//----------------------------- << end remap >> --------------------------------
    .hreadys            (i_hready_<<si_name>>),
    .sel_dec            (i_sel_<<si_name>>),
    .decode_addr_dec    (i_addr_<<si_name>>[<<addr>>:10]),
    .trans_dec          (i_trans_<<si_name>>),

//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
    .active_dec_<<mi_name>>    (i_active_<<si_name>>_to_<<mi_name>>),
    .readyout_dec_<<mi_name>>  (i_hready_mux_<<mi_name>>),
    .resp_dec_<<mi_name>>      (hresp_<<mi_name>>),
    .rdata_dec_<<mi_name>>     (hrdata_<<mi_name>>),
    .exokay_dec_<<mi_name>>    (hexokay_<<mi_name>>),
//---------------------------- << start user >> --------------------------------
    .ruser_dec_<<mi_name>>     (hruser_<<mi_name>>),
//----------------------------- << end user >> ---------------------------------

//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------
//----------------------------- << start out >> --------------------------------
//----------------------------- << start connection >> -------------------------
    .sel_dec_<<mi_name>>       (i_sel_<<si_name>>_to_<<mi_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------ << end out >> ---------------------------------

    .active_dec         (i_active_<<si_name>>),
    .hreadyouts_addr    (i_readyout_addr_<<si_name>>),
    .hreadyouts_data    (i_readyout_data_<<si_name>>),
    .hresps             (i_resp_<<si_name>>),
    .hexokay            (i_exokay_<<si_name>>),
//---------------------------- << start user >> --------------------------------
    .hrusers            (hruser_<<si_name>>),
//----------------------------- << end user >> ---------------------------------
    .hrdatas            (hrdata_<<si_name>>)

    );


//------------------------------ << end in >> ----------------------------------
//----------------------------- << start out >> --------------------------------
  <<output_stage_name>> u_output_stage_<<mi_name>> (

    .hclk                     (hclk),
    .hresetn                  (hresetn),

//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
    .sel_op_<<si_name>>       (i_sel_<<si_name>>_to_<<mi_name>>),
    .addr_op_<<si_name>>      (i_addr_<<si_name>>),
//---------------------------- << start user >> --------------------------------
    .auser_op_<<si_name>>     (i_auser_<<si_name>>),
//----------------------------- << end user >> ---------------------------------
    .trans_op_<<si_name>>     (i_trans_<<si_name>>),
    .write_op_<<si_name>>     (i_write_<<si_name>>),
    .size_op_<<si_name>>      (i_size_<<si_name>>),
    .burst_op_<<si_name>>     (i_burst_<<si_name>>),
    .prot_op_<<si_name>>      (i_prot_<<si_name>>),
    .nonsec_op_<<si_name>>    (i_nonsec_<<si_name>>),
    .excl_op_<<si_name>>      (i_excl_<<si_name>>),
    .master_op_<<si_name>>    (i_master_<<si_name>>),
    .mastlock_op_<<si_name>>  (i_mastlock_<<si_name>>),
    .wdata_op_<<si_name>>     (hwdata_<<si_name>>),
//---------------------------- << start user >> --------------------------------
    .wuser_op_<<si_name>>     (hwuser_<<si_name>>),
//----------------------------- << end user >> ---------------------------------
    .transfer_request_<<si_name>> (i_transfer_request<<si_name>>),

//------------------------------ << end connection >> --------------------------
//------------------------------ << end in >> ----------------------------------
//------------------------------ << start in >> --------------------------------
//----------------------------- << start connection >> -------------------------
    .active_op_<<si_name>>    (i_active_<<si_name>>_to_<<mi_name>>),
//------------------------------ << end connection >> --------------------------
//------------------------------ << end in >> ----------------------------------

    .hselm                    (hsel_<<mi_name>>),
    .haddrm                   (haddr_<<mi_name>>),
//---------------------------- << start user >> --------------------------------
    .hauserm                  (hauser_<<mi_name>>),
//----------------------------- << end user >> ---------------------------------
    .htransm                  (htrans_<<mi_name>>),
    .hwritem                  (hwrite_<<mi_name>>),
    .hsizem                   (hsize_<<mi_name>>),
    .hburstm                  (hburst_<<mi_name>>),
    .hprotm                   (hprot_<<mi_name>>),
    .hnonsecm                 (hnonsec_<<mi_name>>),
    .hexclm                   (hexcl_<<mi_name>>),
    .hmasterm                 (hmaster_<<mi_name>>),
    .hmastlockm               (hmastlock_<<mi_name>>),
    .hreadymuxm               (i_hready_mux_<<mi_name>>),
//---------------------------- << start user >> --------------------------------
    .hwuserm                  (hwuser_<<mi_name>>),
//----------------------------- << end user >> ---------------------------------
    .hwdatam                  (hwdata_<<mi_name>>),
    .hreadyoutm               (hreadyout_<<mi_name>>),
    .hrespm                   (hresp_<<mi_name>>)

    );

  assign hreadymux_<<mi_name>> = i_hready_mux_<<mi_name>>;


//------------------------------ << end out >> ---------------------------------
endmodule

