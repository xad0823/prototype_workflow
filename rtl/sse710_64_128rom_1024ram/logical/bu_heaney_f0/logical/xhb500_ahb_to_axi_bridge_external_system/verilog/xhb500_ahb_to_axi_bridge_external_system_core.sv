//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_ahb_to_axi_bridge_external_system_core (

  input  wire logic                                         clk,
  input  wire logic                                         resetn,

  output      logic                                         buf_write_error_irq,
  input  wire logic                                         irq_en,

  input  wire logic                                         hsel,
  input  wire logic                                         hnonsec,
  input  wire logic [32-1:0]                                haddr,
  input  wire logic [1:0]                                   htrans,
  input  wire logic [1:0]                                   hsize,
  input  wire logic                                         hwrite,
  input  wire logic                                         hready,
  input  wire logic [6:0]                                   hprot,
  input  wire logic [2:0]                                   hburst,
  input  wire logic                                         hmastlock,
  input  wire logic [32-1:0]                                hwdata,
  input  wire logic                                         hexcl,
  input  wire logic [1-1:0]                                 hmaster,
  output      logic [32-1:0]                                hrdata,
  output      logic                                         hreadyout,
  output      logic                                         hresp,
  output      logic                                         hexokay,

  input  wire logic [3:0]                                   hqos,
  input  wire logic [3:0]                                   hregion,
  input  wire logic [3:0]                                   hnsaid,


  output      logic                                         awvalid,
  output      logic [32-1:0]                                awaddr,
  output      logic [1:0]                                   awdomain,
  output      logic [1:0]                                   awburst,
  output      logic [1-1:0]                                 awid,
  output      logic [7:0]                                   awlen,
  output      logic [1:0]                                   awsize,
  output      logic                                         awlock,
  output      logic [2:0]                                   awprot,
  input  wire logic                                         awready,
  output      logic [3:0]                                   awcache,
  output      logic [3:0]                                   awregion,
  output      logic [3:0]                                   awnsaid,
  output      logic [3:0]                                   awqos,

  output      logic                                         arvalid,
  output      logic [32-1:0]                                araddr,
  output      logic [1:0]                                   ardomain,
  output      logic [1:0]                                   arburst,
  output      logic [1-1:0]                                 arid,
  output      logic [7:0]                                   arlen,
  output      logic [1:0]                                   arsize,
  output      logic                                         arlock,
  output      logic [2:0]                                   arprot,
  input  wire logic                                         arready,
  output      logic [3:0]                                   arcache,
  output      logic [3:0]                                   arregion,
  output      logic [3:0]                                   arnsaid,
  output      logic [3:0]                                   arqos,

  output      logic                                         wvalid,
  output      logic                                         wlast,
  output      logic [4-1:0]                                 wstrb,
  output      logic [32-1:0]                                wdata,
  input  wire logic                                         wready,

  input  wire logic                                         rvalid,
  input  wire logic [32-1:0]                                rdata,
  input  wire logic [1:0]                                   rresp,
  output      logic                                         rready,

  input  wire logic                                         bvalid,
  input  wire logic [1-1:0]                                 bid,
  input  wire logic [1:0]                                   bresp,
  output      logic                                         bready,

  output      logic                                         awakeup,

  output      logic                                         clk_qactive,
  input  wire logic                                         clk_qreqn,
  output      logic                                         clk_qacceptn,
  output      logic                                         clk_qdeny,

  output      logic                                         pwr_qactive,
  input  wire logic                                         pwr_qreqn,
  input  wire logic                                         pwr_qreqn_async,
  output      logic                                         pwr_qacceptn,
  output      logic                                         pwr_qdeny

);






  wire logic                                                hazard;
  wire logic                                                hazard_empty;
  wire logic                                                hazard_full;
  wire logic                                                b_ewr;

  wire logic                                                pause_addr_submit;
  wire logic                                                address_readyout;
  wire logic [32-1:0]                                       chk_addr;
  wire logic                                                hazard_add;
  wire logic [1-1:0]                                        hazard_id;
  wire logic [32-1:0]                                       hazard_addr;

  wire logic                                                addr_idle;

  wire logic                                                write_data_phase;
  wire logic                                                write_readyout;
  wire logic                                                pending_broken_b_resp;
  wire logic                                                pending_broken_b_resp_next;
  wire logic [1-1:0]                                        pending_broken_b_resp_id;
  wire logic [1-1:0]                                        pending_broken_b_resp_id_next;

  wire logic                                                ignore_broken_b_resp;
  wire logic                                                beat_done_w;
  wire logic [4:0]                                          writes_remaining;
  wire logic                                                wdata_idle;

  wire logic                                                ready_for_read;

  wire logic                                                b_done;
  wire logic                                                wakeup_int;
  wire logic                                                pwr_change;




  xhb500_ahb_to_axi_bridge_external_system_hazard_list u_hazard_list (
    .clk                      ( clk ),
    .resetn                   ( resetn ),


    .add                      ( hazard_add ),
    .add_addr                 ( hazard_addr ),
    .add_id                   ( hazard_id ),

    .bid                      ( bid ),
    .b_done                   ( b_done ),
    .b_ewr                    ( b_ewr ),

    .empty                    ( hazard_empty ),
    .full                     ( hazard_full ),

    .chk_addr                 ( chk_addr ),
    .hazard                   ( hazard )
  );



  xhb500_ahb_to_axi_bridge_external_system_core_addr u_addr (
    .clk                      ( clk ),
    .resetn                   ( resetn ),

    .hsel                     ( hsel ),
    .hnonsec                  ( hnonsec ),
    .haddr                    ( haddr ),
    .htrans                   ( htrans ),
    .hsize                    ( hsize ),
    .hwrite                   ( hwrite ),
    .hready                   ( hready ),
    .hprot                    ( hprot ),
    .hburst                   ( hburst ),
    .hmastlock                ( hmastlock ),
    .hexcl                    ( hexcl ),
    .hmaster                  ( hmaster ),

    .hqos                     ( hqos ),
    .hregion                  ( hregion ),
    .hnsaid                   ( hnsaid ),

    .awvalid                  ( awvalid ),
    .awaddr                   ( awaddr ),
    .awdomain                 ( awdomain ),
    .awburst                  ( awburst ),
    .awid                     ( awid ),
    .awlen                    ( awlen ),
    .awsize                   ( awsize ),
    .awlock                   ( awlock ),
    .awprot                   ( awprot ),
    .awready                  ( awready ),
    .awcache                  ( awcache ),
    .awregion                 ( awregion ),
    .awnsaid                  ( awnsaid ),
    .awqos                    ( awqos ),

    .arvalid                  ( arvalid ),
    .araddr                   ( araddr ),
    .ardomain                 ( ardomain ),
    .arburst                  ( arburst ),
    .arid                     ( arid ),
    .arlen                    ( arlen ),
    .arsize                   ( arsize ),
    .arlock                   ( arlock ),
    .arprot                   ( arprot ),
    .arready                  ( arready ),
    .arcache                  ( arcache ),
    .arregion                 ( arregion ),
    .arnsaid                  ( arnsaid ),
    .arqos                    ( arqos ),

    .chk_addr                 ( chk_addr ),
    .hazard                   ( hazard ),
    .hazard_full              ( hazard_full ),
    .hazard_add               ( hazard_add ),
    .hazard_id                ( hazard_id ),
    .hazard_addr              ( hazard_addr ),

    .ready_for_read           ( ready_for_read ),
    .pause_addr_submit        ( pause_addr_submit ),

    .pending_broken_b_resp    ( pending_broken_b_resp ),
    .pending_broken_b_resp_next(pending_broken_b_resp_next),
    .pending_broken_b_resp_id ( pending_broken_b_resp_id ),
    .pending_broken_b_resp_id_next ( pending_broken_b_resp_id_next ),
    .ignore_broken_b_resp     ( ignore_broken_b_resp ),
    .address_readyout         ( address_readyout ),

    .addr_idle                ( addr_idle ),
    .clk_qacceptn             ( clk_qacceptn ),
    .pwr_qacceptn             ( pwr_qacceptn )
  );



  xhb500_ahb_to_axi_bridge_external_system_core_wdata u_wdata (
    .clk                      ( clk ),
    .resetn                   ( resetn ),

    .hsel                     ( hsel ),
    .hready                   ( hready ),
    .htrans                   ( htrans ),
    .hsize                    ( hsize ),
    .haddr                    ( haddr ),
    .hwrite                   ( hwrite ),
    .hprot                    ( hprot ),
    .hburst                   ( hburst ),
    .hmastlock                ( hmastlock ),
    .hexcl                    ( hexcl ),
    .hmaster                  ( hmaster),
    .hwdata                   ( hwdata ),
    .hreadyout                ( hreadyout ),

    .wvalid                   ( wvalid ),
    .wlast                    ( wlast ),
    .wstrb                    ( wstrb ),
    .wdata                    ( wdata ),
    .wready                   ( wready ),

    .bvalid                   ( bvalid ),
    .bready                   ( bready ),
    .bid                      ( bid ),

    .b_ewr                    ( b_ewr ),

    .write_data_phase         ( write_data_phase ),
    .address_readyout         ( address_readyout ),

    .pending_broken_b_resp    ( pending_broken_b_resp ),
    .pending_broken_b_resp_id (pending_broken_b_resp_id),
    .pending_broken_b_resp_next(pending_broken_b_resp_next),
    .pending_broken_b_resp_id_next ( pending_broken_b_resp_id_next ),
    .ignore_broken_b_resp     ( ignore_broken_b_resp ),

    .beat_done_w              ( beat_done_w ),
    .writes_remaining         ( writes_remaining ),
    .write_readyout           ( write_readyout ),

    .wdata_idle               ( wdata_idle ),
    .clk_qacceptn             ( clk_qacceptn ),
    .pwr_qacceptn             ( pwr_qacceptn )
  );



  xhb500_ahb_to_axi_bridge_external_system_core_resp u_resp (
    .clk                      ( clk ),
    .resetn                   ( resetn ),

    .hsel                     ( hsel ),
    .hready                   ( hready ),
    .htrans                   ( htrans ),
    .hwrite                   ( hwrite ),
    .hprot                    ( hprot ),
    .hburst                   ( hburst ),
    .hmastlock                ( hmastlock ),
    .hexcl                    ( hexcl ),
    .hrdata                   ( hrdata ),
    .hreadyout                ( hreadyout ),
    .hresp                    ( hresp ),
    .hexokay                  ( hexokay ),

    .arvalid                  ( arvalid ),
    .arready                  ( arready ),
    .arlen3_0                 ( arlen[3:0] ),

    .awvalid                  ( awvalid ),
    .awready                  ( awready ),

    .rvalid                   ( rvalid ),
    .rdata                    ( rdata ),
    .rresp                    ( rresp ),
    .rready                   ( rready ),

    .bvalid                   ( bvalid ),
    .bresp                    ( bresp ),
    .bready                   ( bready ),

    .b_ewr                    ( b_ewr ),

    .write_data_phase         ( write_data_phase ),
    .pending_broken_b_resp    ( pending_broken_b_resp ),
    .beat_done_w              ( beat_done_w ),
    .writes_remaining         ( writes_remaining ),
    .write_readyout           ( write_readyout ),

    .pause_addr_submit        ( pause_addr_submit ),
    .address_readyout         ( address_readyout ),
    .ready_for_read           ( ready_for_read ),

    .clk_qacceptn             ( clk_qacceptn ),
    .pwr_qacceptn             ( pwr_qacceptn )
    );




  assign b_done   =  bvalid &  bready;


  assign wakeup_int   = (hsel & hready & |htrans) | ~hreadyout | awvalid | arvalid | wvalid | rvalid | bvalid | (~ready_for_read) | (~wdata_idle) | (~addr_idle) | pending_broken_b_resp | ~hazard_empty;

  always_ff @ (posedge clk or negedge resetn)
  begin : awakeup_reg
      if (~resetn)
        awakeup <= 1'b0;
      else
        if (wakeup_int ^ awakeup)
          awakeup <= wakeup_int;
  end


  xhb500_xor u_pwr_change  (     .in_a(pwr_qreqn_async), .in_b(pwr_qacceptn), .out_y(pwr_change)   );
  xhb500_or  u_clk_qactive (     .in_a(awakeup),         .in_b(pwr_change),   .out_y(clk_qactive)  );

  always_ff @ (posedge clk or negedge resetn)
  begin : clkq_reg
      if (~resetn)
      begin
        clk_qacceptn <= 1'b0;
        clk_qdeny    <= 1'b0;
     end
      else
        if (clk_qreqn ^ clk_qacceptn ^ clk_qdeny)
        begin
          if (clk_qdeny)
            clk_qdeny <= 1'b0;
          else if (wakeup_int & clk_qacceptn)
            clk_qdeny <= 1'b1;
          else
            clk_qacceptn <= ~clk_qacceptn;
        end
  end

  assign pwr_qactive  = awakeup;

  always_ff @ (posedge clk or negedge resetn)
  begin : pwrq_reg
      if (~resetn)
      begin
        pwr_qacceptn <= 1'b0;
        pwr_qdeny <= 1'b0;
      end
      else
        if (pwr_qreqn ^ pwr_qacceptn ^ pwr_qdeny)
        begin
          if (pwr_qdeny)
            pwr_qdeny <= 1'b0;
          else if (wakeup_int & pwr_qacceptn)
            pwr_qdeny <= 1'b1;
          else
            pwr_qacceptn <= ~pwr_qacceptn;
        end
  end


  always_ff @ (posedge clk or negedge resetn)
  begin : buf_write_error_irq_ff
      if (~resetn)
        buf_write_error_irq <= 1'b0;
      else
        if (irq_en & b_done & (b_ewr | ignore_broken_b_resp) & (bresp != 2'b00))
          buf_write_error_irq <= 1'b1;
        else if (buf_write_error_irq)
          buf_write_error_irq <= 1'b0;
  end

endmodule
