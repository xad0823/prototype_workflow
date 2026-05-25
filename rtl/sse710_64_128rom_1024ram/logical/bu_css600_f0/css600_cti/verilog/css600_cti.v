//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Top level of css600_cti
//
//----------------------------------------------------------------------------


module css600_cti #( parameter
  NUM_EVENT_SLAVES  = 1,
  NUM_EVENT_MASTERS = 1,
  SW_HANDSHAKE      = 32'h0000_0000,
  EXT_MUX_NUM       = 0,
  FF_SYNC_DEPTH     = 2,
  REVAND            = 4'h0,
  EVENT_IN_LEVEL    = 32'h0000_0000
)
(
  clk,
  reset_n,
  clk_qreq_n,
  clk_qaccept_n,
  clk_qdeny,
  clk_qactive,
  pwakeup_s,
  psel_s,
  penable_s,
  pwrite_s,
  paddr_s,
  pwdata_s,
  prdata_s,
  pready_s,
  pslverr_s,
  event_in,
  event_out,
  channel_in,
  channel_out,
  dbgen,
  niden,
  asicctrl,
  tinidensel,
  todbgensel,
  devaff
);

  localparam L_NUM_EVENT_SLAVES  = ( (NUM_EVENT_SLAVES  >= 1) && (NUM_EVENT_SLAVES  <= 32) ) ? NUM_EVENT_SLAVES  : 1;
  localparam L_NUM_EVENT_MASTERS = ( (NUM_EVENT_MASTERS >= 1) && (NUM_EVENT_MASTERS <= 32) ) ? NUM_EVENT_MASTERS : 1;
  localparam L_SW_HANDSHAKE      = SW_HANDSHAKE;
  localparam L_EXT_MUX_NUM       = ( (EXT_MUX_NUM       >= 1) && (EXT_MUX_NUM       <= 31) ) ? EXT_MUX_NUM       : 0;
  localparam L_FF_SYNC_DEPTH     = ( (FF_SYNC_DEPTH     >= 2) && (FF_SYNC_DEPTH     <=  3) ) ? FF_SYNC_DEPTH     : 2;
  localparam L_EVENT_IN_LEVEL    = EVENT_IN_LEVEL;

  localparam L_CHANNEL_WIDTH   = 4;
  localparam L_APB_ADDR_WIDTH  = 12;
  localparam L_APB_DATA_WIDTH  = 32;

  input  wire                           clk;
  input  wire                           reset_n;

  input  wire                           clk_qreq_n;
  output wire                           clk_qaccept_n;
  output wire                           clk_qdeny;
  output wire                           clk_qactive;

  input  wire                           pwakeup_s;
  input  wire                           psel_s;
  input  wire                           penable_s;
  input  wire                           pwrite_s;
  input  wire [L_APB_ADDR_WIDTH-1:0]    paddr_s;
  input  wire [L_APB_DATA_WIDTH-1:0]    pwdata_s;
  output wire [L_APB_DATA_WIDTH-1:0]    prdata_s;
  output wire                           pready_s;
  output wire                           pslverr_s;

  input  wire [L_NUM_EVENT_SLAVES-1:0]  event_in;
  output wire [L_NUM_EVENT_MASTERS-1:0] event_out;

  input  wire [L_CHANNEL_WIDTH-1:0]     channel_in;
  output wire [L_CHANNEL_WIDTH-1:0]     channel_out;

  input  wire                           dbgen;
  input  wire                           niden;

  output wire [7:0]                     asicctrl;

  input  wire [L_NUM_EVENT_SLAVES-1:0]  tinidensel;
  input  wire [L_NUM_EVENT_MASTERS-1:0] todbgensel;
  input  wire [63:0]                    devaff;

  wire                                           clk_qreq_n_sync;
  wire                                           lp_request;
  wire                                           lp_done;
  wire                                           dev_active;
  wire                                           dev_run;
  wire [L_APB_DATA_WIDTH-1:0]                    apb_rdata;
  wire                                           apb_write;
  wire                                           apb_read;
  wire [L_NUM_EVENT_SLAVES-1:0]                  trig_in_status;
  wire [L_NUM_EVENT_MASTERS-1:0]                 trig_out_status;
  wire [L_CHANNEL_WIDTH-1:0]                     ch_in_status;
  wire [L_CHANNEL_WIDTH-1:0]                     ch_out_status;
  wire                                           cti_en;
  wire [L_CHANNEL_WIDTH-1:0]                     ch_out_enable;
  wire [L_CHANNEL_WIDTH*L_NUM_EVENT_SLAVES-1:0]  trig_in_en;
  wire [L_CHANNEL_WIDTH*L_NUM_EVENT_MASTERS-1:0] trig_out_en;
  wire [L_CHANNEL_WIDTH-1:0]                     app_trigger;
  wire [L_NUM_EVENT_MASTERS-1:0]                 cti_int_ack;
  wire                                           iten;
  wire [L_CHANNEL_WIDTH-1:0]                     it_ch_out;
  wire [L_NUM_EVENT_MASTERS-1:0]                 it_trig_out;
  wire [L_NUM_EVENT_SLAVES-1:0]                  map_trig_in;
  wire [L_NUM_EVENT_MASTERS-1:0]                 map_trig_out;
  wire [L_CHANNEL_WIDTH-1:0]                     map_ch_in;
  wire [L_CHANNEL_WIDTH-1:0]                     map_ch_out;

  wire [3:0]                                     w_revand;


  css600_cti_apb_if
  #(
    .APB_DATA_WIDTH        ( L_APB_DATA_WIDTH    )
  )
  u_css600_cti_apb_if
  (
    .clk                   ( clk                 ),
    .reset_n               ( reset_n             ),
    .dev_run               ( dev_run             ),
    .psel_s                ( psel_s              ),
    .penable_s             ( penable_s           ),
    .pwrite_s              ( pwrite_s            ),
    .prdata_s              ( prdata_s            ),
    .pready_s              ( pready_s            ),
    .pslverr_s             ( pslverr_s           ),
    .apb_rdata             ( apb_rdata           ),
    .apb_write             ( apb_write           ),
    .apb_read              ( apb_read            )
  );

  css600_cti_reg_block
  #(
    .NUM_EVENT_SLAVES      ( L_NUM_EVENT_SLAVES  ),
    .NUM_EVENT_MASTERS     ( L_NUM_EVENT_MASTERS ),
    .SW_HANDSHAKE          ( L_SW_HANDSHAKE      ),
    .CHANNEL_WIDTH         ( L_CHANNEL_WIDTH     ),
    .APB_ADDR_WIDTH        ( L_APB_ADDR_WIDTH    ),
    .APB_DATA_WIDTH        ( L_APB_DATA_WIDTH    ),
    .EXT_MUX_NUM           ( L_EXT_MUX_NUM       )
  )
  u_css600_cti_reg_block
  (
    .clk                   ( clk                 ),
    .reset_n               ( reset_n             ),
    .apb_write             ( apb_write           ),
    .apb_read              ( apb_read            ),
    .apb_addr              ( paddr_s             ),
    .apb_wdata             ( pwdata_s            ),
    .apb_rdata             ( apb_rdata           ),
    .trig_in_status        ( trig_in_status      ),
    .trig_out_status       ( trig_out_status     ),
    .ch_in_status          ( ch_in_status        ),
    .ch_out_status         ( ch_out_status       ),
    .niden_status          ( niden               ),
    .dbgen_status          ( dbgen               ),
    .devaff                ( devaff              ),
    .cti_en                ( cti_en              ),
    .ch_out_enable         ( ch_out_enable       ),
    .trig_in_en            ( trig_in_en          ),
    .trig_out_en           ( trig_out_en         ),
    .app_trigger           ( app_trigger         ),
    .cti_int_ack           ( cti_int_ack         ),
    .asicctrl              ( asicctrl            ),
    .iten                  ( iten                ),
    .it_ch_out             ( it_ch_out           ),
    .it_trig_out           ( it_trig_out         ),
    .revand                ( w_revand            )
  );

  css600_cti_ti
  #(
    .NUM_EVENT_SLAVES      ( L_NUM_EVENT_SLAVES  ),
    .NUM_EVENT_MASTERS     ( L_NUM_EVENT_MASTERS ),
    .SW_HANDSHAKE          ( L_SW_HANDSHAKE      ),
    .EVENT_IN_LEVEL        ( L_EVENT_IN_LEVEL    )
  )
  u_css600_cti_ti
  (
    .clk                   ( clk                 ),
    .reset_n               ( reset_n             ),
    .cti_en                ( cti_en              ),
    .cti_int_ack           ( cti_int_ack         ),
    .todbgensel            ( todbgensel          ),
    .tinidensel            ( tinidensel          ),
    .ctitrigin             ( event_in            ),
    .map_trig_in           ( map_trig_in         ),
    .trig_in_status        ( trig_in_status      ),
    .ctitrigout            ( event_out           ),
    .map_trig_out          ( map_trig_out        ),
    .trig_out_status       ( trig_out_status     ),
    .dbgen                 ( dbgen               ),
    .niden                 ( niden               ),
    .iten                  ( iten                ),
    .it_trig_out           ( it_trig_out         )
  );

  css600_cti_mapper
  #(
    .NUM_EVENT_SLAVES      ( L_NUM_EVENT_SLAVES  ),
    .NUM_EVENT_MASTERS     ( L_NUM_EVENT_MASTERS ),
    .CHANNEL_WIDTH         ( L_CHANNEL_WIDTH     )
  )
  u_css600_cti_mapper
  (
    .trig_in_en            ( trig_in_en          ),
    .trig_out_en           ( trig_out_en         ),
    .app_trigger           ( app_trigger         ),
    .map_trig_in           ( map_trig_in         ),
    .map_trig_out          ( map_trig_out        ),
    .map_ch_in             ( map_ch_in           ),
    .map_ch_out            ( map_ch_out          )
  );

  css600_cti_ci
  #(
    .CHANNEL_WIDTH         ( L_CHANNEL_WIDTH     )
  )
  u_css600_cti_ci
  (
    .clk                   ( clk                 ),
    .reset_n               ( reset_n             ),
    .cti_en                ( cti_en              ),
    .ch_out_enable         ( ch_out_enable       ),
    .ctichin               ( channel_in          ),
    .map_ch_in             ( map_ch_in           ),
    .ch_in_status          ( ch_in_status        ),
    .ctichout              ( channel_out         ),
    .map_ch_out            ( map_ch_out          ),
    .ch_out_status         ( ch_out_status       ),
    .iten                  ( iten                ),
    .it_ch_out             ( it_ch_out           )
  );

  css600_lpislave
  u_css600_lpislave
  (
    .clk                   ( clk                 ),
    .reset_n               ( reset_n             ),
    .qreq_sync_n           ( clk_qreq_n_sync     ),
    .qaccept_n             ( clk_qaccept_n       ),
    .qdeny                 ( clk_qdeny           ),
    .lp_request            ( lp_request          ),
    .lp_done               ( lp_done             ),
    .dev_active            ( dev_active          ),
    .dev_run               ( dev_run             ),
    .cg_en                 (                     )
  );

    css600_cdc_capt_sync
    #(
      .FF_SYNC_DEPTH (L_FF_SYNC_DEPTH)
    )
    u_css600_cdc_capt_sync_clk_qreq
    (
      .clk       ( clk              ),
      .reset_n   ( reset_n          ),
      .d_async_i ( clk_qreq_n       ),
      .q_sync_o  ( clk_qreq_n_sync  )
    );

  css600_cti_async
  u_qactive_async
  (
    .cti_en      ( cti_en      ),
    .iten        ( iten        ),
    .psel        ( psel_s      ),
    .pwakeup     ( pwakeup_s   ),
    .cti_active  ( dev_active  ),
    .clk_qactive ( clk_qactive )
  );

  assign lp_done = lp_request;

  css600_ecorevnum #(.WIDTH(4), .ECOREVVAL(REVAND))
    u_css600_ecorevnum (.ecorevnum(w_revand));


endmodule

