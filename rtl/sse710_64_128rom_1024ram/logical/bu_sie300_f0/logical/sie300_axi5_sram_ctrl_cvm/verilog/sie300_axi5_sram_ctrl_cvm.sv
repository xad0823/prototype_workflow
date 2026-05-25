//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Mon Jul 29 14:50:07 2019 +0100
//
//      Revision            : aec093fa
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm
(


  input  wire logic                                           aclk,
  input  wire logic                                           aresetn,


  input  wire logic                                           awvalid_s,
  output      logic                                           awready_s,
  input  wire logic [12-1       :0]                           awid_s,
  input  wire logic [22-1     :0]                             awaddr_s,
  input  wire logic [7                        :0]             awlen_s,
  input  wire logic [2                        :0]             awsize_s,
  input  wire logic [1                        :0]             awburst_s,
  input  wire logic                                           awlock_s,
  input  wire logic [2                        :0]             awprot_s,
  input  wire logic [3                        :0]             awqos_s,

  input  wire logic                                           wvalid_s,
  output      logic                                           wready_s,
  input  wire logic [64-1     :0]                             wdata_s,
  input  wire logic [8-1     :0]                              wstrb_s,
  input  wire logic                                           wlast_s,
  input  wire logic [1-1     :0]                              wpoison_s,

  output      logic                                           bvalid_s,
  input  wire logic                                           bready_s,
  output      logic [12-1       :0]                           bid_s,
  output      logic [1                        :0]             bresp_s,

  input  wire logic                                           arvalid_s,
  output      logic                                           arready_s,
  input  wire logic [12-1       :0]                           arid_s,
  input  wire logic [22-1     :0]                             araddr_s,
  input  wire logic [7                        :0]             arlen_s,
  input  wire logic [2                        :0]             arsize_s,
  input  wire logic [1                        :0]             arburst_s,
  input  wire logic                                           arlock_s,
  input  wire logic [2                        :0]             arprot_s,
  input  wire logic [3                        :0]             arqos_s,

  output      logic                                           rvalid_s,
  input  wire logic                                           rready_s,
  output      logic [12-1       :0]                           rid_s,
  output      logic [64-1     :0]                             rdata_s,
  output      logic [1                        :0]             rresp_s,
  output      logic                                           rlast_s,
  output      logic [1-1     :0]                              rpoison_s,

  input  wire logic                                           awakeup_s,


  input  wire logic                                           clk_qreqn,
  output      logic                                           clk_qacceptn,
  output      logic                                           clk_qdeny,
  output      logic                                           clk_qactive,


  input  wire logic                                           pwr_qreqn,
  output      logic                                           pwr_qacceptn,
  output      logic                                           pwr_qdeny,
  output      logic                                           pwr_qactive,


  input  wire logic                                           ext_gt_qreqn,
  output      logic                                           ext_gt_qacceptn,
  input  wire logic                                           cfg_gate_resp,

  output      logic [22-1     :0]                             memaddr,
  output      logic [64-1     :0]                             memd,
  input  wire logic [64-1     :0]                             memq,
  output      logic                                           memcen,
  output      logic [8-1     :0]                              memwen

);


  logic                                 awq_vld;
  logic                                 awq_rdy;
  logic [12-1       :0]                 awq_id;
  logic [22-1     :0]                   awq_addr;
  logic [7                        :0]   awq_len;
  logic [2                        :0]   awq_size;
  logic [1                        :0]   awq_burst;
  logic [3                        :0]   awq_qos;
  logic                                 awq_lock;
  logic                                 awq_prot;
  logic [2-1  :0]                       awq_cnt;
  logic                                 awq_full;
  logic                                 awq_empty;

  logic                                 wq_vld;
  logic                                 wq_rdy;
  logic [64-1     :0]                   wq_data;
  logic [8-1     :0]                    wq_strb;
  logic [2-1  :0]                       wlast_cnt;
  logic                                 wq_full;
  logic                                 wq_empty;

  logic                                 awready_bq;
  logic                                 bq_empty;
  logic                                 bq_full;
  logic                                 bq_exok_saved;
  logic                                 bq_exfail;
  logic                                 bq_lock;

  logic                                 arq_vld;
  logic                                 arq_rdy;
  logic [12-1       :0]                 arq_id;
  logic [22-1     :0]                   arq_addr;
  logic [7                        :0]   arq_len;
  logic [2                        :0]   arq_size;
  logic [1                        :0]   arq_burst;
  logic [3                        :0]   arq_qos;
  logic                                 arq_lock;
  logic                                 arq_prot;
  logic                                 arq_empty;

  logic                                 rq_vld;
  logic [64-1     :0]                   rq_data;
  logic [12-1       :0]                 rq_id;
  logic [1                        :0]   rq_resp;
  logic                                 rq_last;
  logic                                 rq_empty;

  logic                                 wbeat_vld;
  logic                                 wbeat_rdy;
  logic [22-1     :0]                   wbeat_addr;
  logic [8-1     :0]                    wbeat_strb;
  logic                                 wbeat_chk_exok;

  logic                                 rbeat_vld;
  logic                                 rbeat_rdy;
  logic [22-1     :0]                   rbeat_addr;

  logic                                 ext_stall;
  logic                                 stopped;
  logic                                 sel_resp_path;
  logic                                 resp_fsm_en;
  logic                                 resp_fsm_act;

  logic                                 raw_match_arb;
  logic                                 raw_match_stall;
  logic                                 arq_last;

  logic                                 arready_q;
  logic                                 rvalid_q;
  logic [12-1       :0]                 rid_q;
  logic [1                        :0]   rresp_q;
  logic                                 rlast_q;
  logic [64-1     :0]                   rdata_q;
  logic [1-1     :0]                    rpoison_q;
  logic                                 awready_q;
  logic                                 wready_q;
  logic                                 bvalid_q;
  logic [1                        :0]   bresp_q;
  logic [12-1       :0]                 bid_q;

  logic                                 arready_r;
  logic                                 rvalid_r;
  logic [12-1       :0]                 rid_r;
  logic [1                        :0]   rresp_r;
  logic                                 rlast_r;
  logic                                 awready_r;
  logic                                 wready_r;
  logic                                 bvalid_r;
  logic [1                        :0]   bresp_r;
  logic [12-1       :0]                 bid_r;

  logic                                 eam_exok;

  logic [22-1     :0]                   memaddr_arb;
  logic                                 memcen_arb;
  logic [8-1     :0]                    memwen_arb;
  logic                                 memrd_arb;
  logic [64-1     :0]                   memd_wbeat;
  logic [64-1     :0]                   memq_clamp;

  sie300_axi5_sram_ctrl_cvm_awq
    u_awq (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .awvalid        ( awvalid_s         ),
    .awready        ( awready_q         ),
    .awid           ( awid_s            ),
    .awaddr         ( awaddr_s          ),
    .awlen          ( awlen_s           ),
    .awsize         ( awsize_s          ),
    .awburst        ( awburst_s         ),
    .awqos          ( awqos_s           ),
    .awprot         ( awprot_s[1]       ),
    .awlock         ( awlock_s          ),
    .araddr         ( araddr_s          ),
    .arvalid        ( arvalid_s         ),
    .arready        ( arready_q         ),
    .bvalid         ( bvalid_q          ),
    .bready         ( bready_s          ),
    .wbeat_rdy      ( wbeat_rdy         ),
    .raw_match_arb  ( raw_match_arb     ),
    .raw_match_stall( raw_match_stall   ),
    .awq_vld        ( awq_vld           ),
    .awq_rdy        ( awq_rdy           ),
    .awq_id         ( awq_id            ),
    .awq_addr       ( awq_addr          ),
    .awq_len        ( awq_len           ),
    .awq_size       ( awq_size          ),
    .awq_burst      ( awq_burst         ),
    .awq_qos        ( awq_qos           ),
    .awq_prot       ( awq_prot          ),
    .awq_lock       ( awq_lock          ),
    .awready_bq     ( awready_bq        ),
    .awq_cnt        ( awq_cnt           ),
    .bq_exfail      ( bq_exfail         ),
    .awq_full       ( awq_full          ),
    .awq_empty      ( awq_empty         ),
    .wlast_cnt      ( wlast_cnt         ),
    .wq_empty       ( wq_empty          ),
    .ext_stall      ( ext_stall         )
  );

  sie300_axi5_sram_ctrl_cvm_wq
    u_wq (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .wvalid         ( wvalid_s          ),
    .wready         ( wready_q          ),
    .wdata          ( wdata_s           ),
    .wstrb          ( wstrb_s           ),
    .wlast          ( wlast_s           ),
    .wq_vld         ( wq_vld            ),
    .wq_rdy         ( wq_rdy            ),
    .wq_data        ( wq_data           ),
    .wq_strb        ( wq_strb           ),
    .wq_full        ( wq_full           ),
    .wq_empty       ( wq_empty          ),
    .awq_cnt        ( awq_cnt           ),
    .wlast_cnt      ( wlast_cnt         ),
    .awq_vld        ( awq_vld           ),
    .awq_rdy        ( awq_rdy           ),
    .ext_stall      ( ext_stall         )
  );

  sie300_axi5_sram_ctrl_cvm_bq
    u_bq (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .awvalid        ( awvalid_s         ),
    .awready        ( awready_q         ),
    .awid           ( awid_s            ),
    .awlock         ( awlock_s          ),
    .wvalid         ( wvalid_s          ),
    .wready         ( wready_q          ),
    .wlast          ( wlast_s           ),
    .bvalid         ( bvalid_q          ),
    .bready         ( bready_s          ),
    .bid            ( bid_q             ),
    .bresp          ( bresp_q           ),
    .wbeat_chk_exok ( wbeat_chk_exok    ),
    .eam_exok       ( eam_exok          ),
    .bq_lock        ( bq_lock           ),
    .bq_exok_saved  ( bq_exok_saved     ),
    .bq_exfail      ( bq_exfail         ),
    .bq_full        ( bq_full           ),
    .bq_empty       ( bq_empty          ),
    .awready_bq     ( awready_bq        )
  );

  sie300_axi5_sram_ctrl_cvm_arq
    u_arq (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .arvalid        ( arvalid_s         ),
    .arready        ( arready_q         ),
    .arid           ( arid_s            ),
    .araddr         ( araddr_s          ),
    .arlen          ( arlen_s           ),
    .arsize         ( arsize_s          ),
    .arburst        ( arburst_s         ),
    .arqos          ( arqos_s           ),
    .arprot         ( arprot_s[1]       ),
    .arlock         ( arlock_s          ),
    .raw_match      ( raw_match_stall   ),
    .arq_last       ( arq_last          ),
    .awq_empty      ( awq_empty         ),
    .arq_vld        ( arq_vld           ),
    .arq_rdy        ( arq_rdy           ),
    .arq_id         ( arq_id            ),
    .arq_addr       ( arq_addr          ),
    .arq_len        ( arq_len           ),
    .arq_size       ( arq_size          ),
    .arq_burst      ( arq_burst         ),
    .arq_qos        ( arq_qos           ),
    .arq_prot       ( arq_prot          ),
    .arq_lock       ( arq_lock          ),
    .arq_empty      ( arq_empty         ),
    .ext_stall      ( ext_stall         )
  );

  sie300_axi5_sram_ctrl_cvm_rq
    u_rq (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .rvalid         ( rvalid_q          ),
    .rready         ( rready_s          ),
    .rid            ( rid_q             ),
    .rdata          ( rdata_q           ),
    .rresp          ( rresp_q           ),
    .rlast          ( rlast_q           ),
    .rpoison        ( rpoison_q         ),
    .rq_vld         ( rq_vld            ),
    .rq_data        ( rq_data           ),
    .rq_id          ( rq_id             ),
    .rq_resp        ( rq_resp           ),
    .rq_last        ( rq_last           ),
    .rq_empty       ( rq_empty          )
  );

  sie300_axi5_sram_ctrl_cvm_wbeat
    u_wbeat (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .awq_vld        ( awq_vld           ),
    .awq_rdy        ( awq_rdy           ),
    .awq_addr       ( awq_addr          ),
    .awq_len        ( awq_len           ),
    .awq_size       ( awq_size          ),
    .awq_burst      ( awq_burst         ),
    .awq_lock       ( awq_lock          ),
    .wq_vld         ( wq_vld            ),
    .wq_rdy         ( wq_rdy            ),
    .wq_data        ( wq_data           ),
    .wq_strb        ( wq_strb           ),
    .wbeat_vld      ( wbeat_vld         ),
    .wbeat_rdy      ( wbeat_rdy         ),
    .wbeat_addr     ( wbeat_addr        ),
    .wbeat_strb     ( wbeat_strb        ),
    .eam_exok       ( eam_exok          ),
    .bq_exok_saved  ( bq_exok_saved     ),
    .wbeat_chk_exok ( wbeat_chk_exok    ),
    .memd_wbeat     ( memd_wbeat        )
  );

  sie300_axi5_sram_ctrl_cvm_rbeat
    u_rbeat (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .arq_vld        ( arq_vld           ),
    .arq_rdy        ( arq_rdy           ),
    .arq_id         ( arq_id            ),
    .arq_addr       ( arq_addr          ),
    .arq_len        ( arq_len           ),
    .arq_size       ( arq_size          ),
    .arq_burst      ( arq_burst         ),
    .arq_lock       ( arq_lock          ),
    .rq_vld         ( rq_vld            ),
    .rq_data        ( rq_data           ),
    .rq_id          ( rq_id             ),
    .rq_resp        ( rq_resp           ),
    .rq_last        ( rq_last           ),
    .rvalid         ( rvalid_q          ),
    .rready         ( rready_s          ),
    .rbeat_vld      ( rbeat_vld         ),
    .rbeat_rdy      ( rbeat_rdy         ),
    .rbeat_addr     ( rbeat_addr        ),
    .memq_clamp     ( memq_clamp        )
  );

  sie300_axi5_sram_ctrl_cvm_arb
    u_arb (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .wbeat_vld      ( wbeat_vld         ),
    .wbeat_rdy      ( wbeat_rdy         ),
    .wbeat_addr     ( wbeat_addr        ),
    .wbeat_strb     ( wbeat_strb        ),
    .rbeat_vld      ( rbeat_vld         ),
    .rbeat_rdy      ( rbeat_rdy         ),
    .rbeat_addr     ( rbeat_addr        ),
    .wbeat_chk_exok ( wbeat_chk_exok    ),
    .eam_exok       ( eam_exok          ),
    .awq_rdy        ( awq_rdy           ),
    .raw_match      ( raw_match_arb     ),
    .arq_last       ( arq_last          ),
    .awq_full       ( awq_full          ),
    .wq_full        ( wq_full           ),
    .bq_full        ( bq_full           ),
    .bq_lock        ( bq_lock           ),
    .bvalid         ( bvalid_s          ),
    .arq_rdy        ( arq_rdy           ),
    .arq_qos        ( arq_qos           ),
    .awq_qos        ( awq_qos           ),
    .memaddr_arb    ( memaddr_arb       ),
    .memcen_arb     ( memcen_arb        ),
    .memwen_arb     ( memwen_arb        ),
    .memrd_arb      ( memrd_arb         )
  );

  sie300_axi5_sram_ctrl_cvm_lpi_ctrl
    u_lpi_ctrl (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .clk_qactive    ( clk_qactive       ),
    .clk_qreqn      ( clk_qreqn         ),
    .clk_qacceptn   ( clk_qacceptn      ),
    .clk_qdeny      ( clk_qdeny         ),
    .pwr_qactive    ( pwr_qactive       ),
    .pwr_qreqn      ( pwr_qreqn         ),
    .pwr_qacceptn   ( pwr_qacceptn      ),
    .pwr_qdeny      ( pwr_qdeny         ),
    .ext_gt_qreqn   ( ext_gt_qreqn      ),
    .ext_gt_qacceptn( ext_gt_qacceptn   ),
    .arvalid        ( arvalid_s         ),
    .rvalid         ( rvalid_s          ),
    .awvalid        ( awvalid_s         ),
    .wvalid         ( wvalid_s          ),
    .bvalid         ( bvalid_s          ),
    .awakeup        ( awakeup_s         ),
    .awq_empty      ( awq_empty         ),
    .wq_empty       ( wq_empty          ),
    .bq_empty       ( bq_empty          ),
    .arq_empty      ( arq_empty         ),
    .rq_empty       ( rq_empty          ),
    .rq_vld         ( rq_vld            ),
    .resp_fsm_en    ( resp_fsm_en       ),
    .resp_fsm_act   ( resp_fsm_act      ),
    .ext_stall      ( ext_stall         ),
    .stopped        ( stopped           ),
    .sel_resp_path  ( sel_resp_path     )
  );

  sie300_axi5_sram_ctrl_cvm_resp_gen
    u_resp_gen (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .arvalid        ( arvalid_s         ),
    .arid           ( arid_s            ),
    .arlen          ( arlen_s           ),
    .rready         ( rready_s          ),
    .awvalid        ( awvalid_s         ),
    .awid           ( awid_s            ),
    .wvalid         ( wvalid_s          ),
    .wlast          ( wlast_s           ),
    .bready         ( bready_s          ),
    .arready        ( arready_s         ),
    .awready        ( awready_s         ),
    .arready_r      ( arready_r         ),
    .rvalid_r       ( rvalid_r          ),
    .rresp_r        ( rresp_r           ),
    .rlast_r        ( rlast_r           ),
    .rid_r          ( rid_r             ),
    .awready_r      ( awready_r         ),
    .wready_r       ( wready_r          ),
    .bvalid_r       ( bvalid_r          ),
    .bresp_r        ( bresp_r           ),
    .bid_r          ( bid_r             ),
    .cfg_gate_resp  ( cfg_gate_resp     ),
    .ext_gt_qacceptn( ext_gt_qacceptn   ),
    .resp_fsm_en    ( resp_fsm_en       ),
    .resp_fsm_act   ( resp_fsm_act      )

  );

  sie300_axi5_sram_ctrl_cvm_axi_mux
    u_axi_mux (
    .arready        ( arready_s         ),
    .rvalid         ( rvalid_s          ),
    .rresp          ( rresp_s           ),
    .rlast          ( rlast_s           ),
    .rid            ( rid_s             ),
    .rdata          ( rdata_s           ),
    .rpoison        ( rpoison_s         ),
    .awready        ( awready_s         ),
    .wready         ( wready_s          ),
    .bvalid         ( bvalid_s          ),
    .bresp          ( bresp_s           ),
    .bid            ( bid_s             ),
    .arready_q      ( arready_q         ),
    .rvalid_q       ( rvalid_q          ),
    .rresp_q        ( rresp_q           ),
    .rlast_q        ( rlast_q           ),
    .rid_q          ( rid_q             ),
    .rdata_q        ( rdata_q           ),
    .rpoison_q      ( rpoison_q         ),
    .awready_q      ( awready_q         ),
    .wready_q       ( wready_q          ),
    .bvalid_q       ( bvalid_q          ),
    .bresp_q        ( bresp_q           ),
    .bid_q          ( bid_q             ),
    .arready_r      ( arready_r         ),
    .rvalid_r       ( rvalid_r          ),
    .rresp_r        ( rresp_r           ),
    .rlast_r        ( rlast_r           ),
    .rid_r          ( rid_r             ),
    .awready_r      ( awready_r         ),
    .wready_r       ( wready_r          ),
    .bvalid_r       ( bvalid_r          ),
    .bresp_r        ( bresp_r           ),
    .bid_r          ( bid_r             ),
    .sel_resp_path  ( sel_resp_path     )
  );

  sie300_axi5_sram_ctrl_cvm_clamp
    u_clamp (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .memaddr_arb    ( memaddr_arb       ),
    .memcen_arb     ( memcen_arb        ),
    .memwen_arb     ( memwen_arb        ),
    .memrd_arb      ( memrd_arb         ),
    .memd_wbeat     ( memd_wbeat        ),
    .memq_clamp     ( memq_clamp        ),
    .memaddr        ( memaddr           ),
    .memcen         ( memcen            ),
    .memwen         ( memwen            ),
    .memd           ( memd              ),
    .memq           ( memq              ),
    .stopped        ( stopped           )
  );

  localparam IGNORE_LSB_EXCL=7;
  logic [22-1: IGNORE_LSB_EXCL]                 wbeat_addr_eam;
  assign wbeat_addr_eam   = wbeat_addr[22-1: IGNORE_LSB_EXCL]                ;

  sie300_axi5_sram_ctrl_cvm_eam
  #( .IGNORE_LSB_EXCL (IGNORE_LSB_EXCL))
    u_eam (
    .clk            ( aclk              ),
    .resetn         ( aresetn           ),
    .arq_id         ( arq_id            ),
    .arq_addr       ( arq_addr          ),
    .arq_prot       ( arq_prot          ),
    .arq_lock       ( arq_lock          ),
    .arq_vld        ( arq_vld           ),
    .arq_rdy        ( arq_rdy           ),
    .awq_id         ( awq_id            ),
    .awq_addr       ( awq_addr          ),
    .awq_prot       ( awq_prot          ),
    .wbeat_addr     ( wbeat_addr_eam    ),
    .wbeat_vld      ( wbeat_vld         ),
    .wbeat_rdy      ( wbeat_rdy         ),
    .wbeat_chk_exok ( wbeat_chk_exok    ),
    .eam_exok       ( eam_exok          )
);


  wire unused;

  assign unused = & {
                      wpoison_s,
                      awprot_s[2], awprot_s[0],
                      arprot_s[2], arprot_s[0]
                  };





endmodule

