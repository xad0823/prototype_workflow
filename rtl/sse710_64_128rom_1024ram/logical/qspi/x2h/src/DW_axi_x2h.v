//-----------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------
// 
// Copyright 2005 - 2022 Synopsys, INC.
// 
// This Synopsys IP and all associated documentation are proprietary to
// Synopsys, Inc. and may only be used pursuant to the terms and conditions of a
// written license agreement with Synopsys, Inc. All other use, reproduction,
// modification, or distribution of the Synopsys IP or the associated
// documentation is strictly prohibited.
// Inclusivity & Diversity - Visit SolvNetPlus to read the "Synopsys Statement on
//            Inclusivity and Diversity" (Refer to article 000036315 at
//                        https://solvnetplus.synopsys.com)
// 
// Component Name   : DW_axi_x2h
// Component Version: 2.05a
// Release Type     : GA
// Build ID         : 13.18.16.11
// ------------------------------------------------------------------------------

// 
// Release version :  2.05a
// File Version     :        $Revision: #27 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h.v#27 $
//
// -------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Filename    : DW_axi_x2h.v
// Created     : Tues Dec 21 20:00:00 GMT 2004
// Description : Top level AXI-to-AHB bridge.
//               A unidirectional bridge which is an AXI slave and
//               an AHB master.
//-----------------------------------------------------------------------------

  //    When PASS_LOCK is not enabled the mhlock signal is tied to zero.

  //    When PASS_LOCK is not enabled the mhlock signal is tied to zero.

//spyglass disable_block Topology_02
//SMD: No asynchronous pin to pin paths
//SJ: cactive is driven by the arvalid, awvalid asynchronously. There is desired behavior and will not cause any functional issue, hence waived.

//==============================================================================
// Start License Usage
//==============================================================================
// Key Used   : DWC-AMBA-Fabric-Source      (IP access)
// Key NotUsed: DWC-AMBA-AHB5-Fabric-Source (Add-on feature access: This license need to be present when X2H_AHB_INTERFACE_TYPE==1.  It gives access to the AHB5 features in the IP.)
//==============================================================================
// End License Usage
//==============================================================================

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h (/*AUTOARG*/
  // Outputs
  rdata, 
                   bresp, 
                   rresp, 
                   bid, 
                   rid, 
                   awready, 
                   wready, 
                   bvalid, 
                   arready,
                   rlast, 
                   rvalid, 
                   mhaddr, 
                   mhburst,
                   mhlock, 
                   mhprot, 
                   mhsize, 
                   mhtrans, 
                   mhwdata, 
                   mhwrite,
                   // Inputs
                   aclk, 
                   aresetn, 
                   awaddr, 
                   wdata, 
                   araddr, 
                   awvalid, 
                   wlast, 
                   wvalid,
                   bready, 
                   arvalid, 
                   rready, 
                   awburst, 
                   awlock, 
                   arburst, 
                   arlock, 
                   awsize,
                   awprot,
                   arsize, 
                   arprot, 
                   awid,
                   awlen, 
                   awcache,
                   wstrb,
                   arid,
                   arlen,
                   arcache,
                   mhclk,
                   mhresetn,
                   mhrdata, 
                   mhready, 
                   mhresp
                   );
//spyglass enable_block Topology_02
   // AXI slave inputs
  input                             aclk;

  input                             aresetn;
  //When AXB_ADDR_WIDTH > AHB_ADDR_WIDTH, the extra MSBs of the awaddr/araddr signal are unused.
  input   [`X2H_AXI_ADDR_WIDTH-1:0] awaddr;
  input   [`X2H_AXI_ADDR_WIDTH-1:0] araddr;
  input   [`X2H_AXI_DATA_WIDTH-1:0] wdata;
  input                             awvalid;
  input                             wlast;
  input                             wvalid;
  input                             bready;
  input                             arvalid;
  input                             rready;
  input                       [1:0] awburst;
  input          [`X2H_AXI_LTW-1:0] awlock;
  input                       [1:0] arburst;
  input          [`X2H_AXI_LTW-1:0] arlock;
  input                       [2:0] awsize;
  //The axprot(3bits) and axcache(4bits) are mapped to the hprot signal(4bits).
  //ar/wprot[1] (AXI secure/non-secure) is not mapped into the AHB signal.
  //ar/wcache[3:2] (AXI read/write allocate) is not mapped into the AHB signal.
  input                       [2:0] awprot;
  input                       [2:0] arprot;
  input                       [3:0] awcache;
  input                       [3:0] arcache;
  input                       [2:0] arsize;
  input     [`X2H_AXI_ID_WIDTH-1:0] awid;
  //This signal is unused. It is included for interface consistency only.
  input          [`X2H_AXI_BLW-1:0] awlen;
  input  [`X2H_AXI_WSTRB_WIDTH-1:0] wstrb;
  input     [`X2H_AXI_ID_WIDTH-1:0] arid;
  input          [`X2H_AXI_BLW-1:0] arlen;

  // AXI slave outputs
  output  [`X2H_AXI_DATA_WIDTH-1:0] rdata;
  output                      [1:0] bresp;
  output                      [1:0] rresp;
  output    [`X2H_AXI_ID_WIDTH-1:0] bid;
  output    [`X2H_AXI_ID_WIDTH-1:0] rid;
  output                            awready;
  output                            wready;
  output                            bvalid;
  output                            arready;
  output                            rlast;
  output                            rvalid;

  //The axprot(3bits) and axcache(4bits) are mapped to the hprot signal(4bits).
  //ar/wprot[1] (AXI secure/non-secure) is not mapped into the AHB signal.
  //ar/wcache[3:2] (AXI read/write allocate) is not mapped into the AHB signal.
  // AHB master inputs
  input                             mhclk;
  input                             mhresetn;
  input   [`X2H_AHB_DATA_WIDTH-1:0] mhrdata;
  input                             mhready;
  input                       [`X2H_HRESP_WIDTH-1:0] mhresp;

  // AHB master outputs
  output  [`X2H_AHB_ADDR_WIDTH-1:0] mhaddr;
  output                      [2:0] mhburst;
  output                            mhlock;
  output     [`X2H_HPROT_WIDTH-1:0] mhprot;
  output                      [2:0] mhsize;
  output                      [1:0] mhtrans;
  output  [`X2H_AHB_DATA_WIDTH-1:0] mhwdata;
  output                            mhwrite;



  // "Command" words
  wire      [`X2H_CMD_QUEUE_WIDTH-1:0] hcmd_queue_wd_int,
                                       cmd_queue_wd;

  // Write data (actually {WDATA,WSTRB,WLAST}
  wire     [`X2H_AXI_WDFIFO_WIDTH-1:0] awr_buff_wd,
                                       hwword_int;


  // Responses returned through write response, read data buffers
  wire                           [1:0] hwstatus_int,
                                       pop_resp_status_wd,
                                       hrstatus_int,
                                       arstatus_int;

  // IDs returned through write response, read data buffers
  wire         [`X2H_AXI_ID_WIDTH-1:0] hwid_int,
                                       pop_resp_id_wd,
                                       hrid_int,
                                       arid_int;

  // Read data
  wire      [`X2H_AXI_DATA_WIDTH-1:0] ardata_int,
                                       hrdata_int;

  // Amount of data (NOT SPACE!!) in read data buffer
  wire                           [7:0] hrdata_push_cnt;


  // Internal wires in the AXI-clock domain
  wire       awvalid_gtd,
//             awready_int,
             wvalid_gtd,
             wready_int,
             arvalid_gtd,
//             arready_int,
             resp_pop_rdy_n,
             pop_resp_n,
             wr_buff_push_rdy_n,
             push_write_buffer_n,
             arlast_int,
             pop_rdata_n,
             arvalid_int_n,
             cmd_push_af,
             cmd_queue_push_rdy_n;


  // Internal wires in the AHB-clock domain

  wire       hcmd_rdy_int_n,
             pop_hcmd_int_n,
             hwdata_rdy_int_n,
             pop_wdata_int_n,
             hresp_rdy_int_n,
             push_resp_int_n,
             hrlast_int,
             push_data_int_n,
             push_cmd_queue_n;



DW_axi_x2h_slave
  U_AXI_SLAVE(
                  .awid(awid),
                              .awaddr(awaddr),
                              .awlen(awlen),
                              .awsize(awsize),
                              .awburst(awburst),
                              .awlock(awlock),
                              .awcache(awcache[1:0]),
                              .awprot({awprot[2],awprot[0]}),
                              .awvalid(awvalid_gtd),
                              //                  .awready(awready_int),
                              //                  `ifdef X2H_AXI3_INTERFACE
                              //                  .wid(wid),
                              //                  `endif
                              .wdata(wdata),
                              .wstrb(wstrb),
                              .wlast(wlast),
                              .wvalid(wvalid_gtd),
                              .wready(wready_int),
                              .bid(bid),
                              .bresp(bresp),
                              .bvalid(bvalid),
                              .bready(bready),
                              // the response buffer
                              .response_avail_n(resp_pop_rdy_n),
                              .pop_resp_n(pop_resp_n),
                              .pop_resp_word({pop_resp_status_wd,pop_resp_id_wd}),
                              // the write data buffer
                              .write_buffer_wd(awr_buff_wd),
                              .push_write_buffer_n(push_write_buffer_n),
                              .write_buff_rdy_n(wr_buff_push_rdy_n),
                              // read side
                              .arid(arid),
                              .araddr(araddr),
                              .arlen(arlen),
                              .arsize(arsize),
                              .arburst(arburst),
                              .arlock(arlock),
                              .arcache(arcache[1:0]),
                              .arprot({arprot[2],arprot[0]}),
                              .arvalid(arvalid_gtd),
                              //                  .arready(arready_int),
                              .rid(rid),
                              .rdata(rdata),
                              .rresp(rresp),
                              .rlast(rlast),
                              .rvalid(rvalid),
                              .rready(rready),
                              // the read data buffer
                              .arstatus_int(arstatus_int),
                              .arid_int(arid_int),
                              .arlast_int(arlast_int),
                              .ardata_int(ardata_int),
                              .pop_data_int_n(pop_rdata_n),
                              .arvalid_int_n(arvalid_int_n),
                              .push_cmd_queue_n(push_cmd_queue_n),
                              .cmd_queue_wd(cmd_queue_wd),
                              .cmd_queue_rdy_n(cmd_queue_push_rdy_n)
                              );




DW_axi_x2h_arb
 U_X2H_ARB (
                  .aclk(aclk),
                  .aresetn(aresetn),
                  // Outputs
                  .wvalid_gtd(wvalid_gtd),
                  .wready(wready),
                  .awvalid_gtd(awvalid_gtd),
                  .arvalid_gtd(arvalid_gtd),
                  .awready(awready),
                  .arready(arready),
                  // Inputs
                  .wvalid(wvalid),
//                  .csysack(1'b1),
//                  .csysack_ns(1'b1),
                  .awvalid(awvalid),
                  .arvalid(arvalid),
                  .wready_int(wready_int),
                  .cmd_queue_rdy_n(cmd_queue_push_rdy_n),
                  .cmd_push_af(cmd_push_af));


// FIFOs

DW_axi_x2h_cmd_queue
 U_CMD_QUEUE (
               // the AXI slave side is pushing
               .clk_axi(aclk),
                                  .push_rst_n(aresetn),
                                  .acmd_queue_wd_int(cmd_queue_wd),
                                  .push_acmd_int_n(push_cmd_queue_n),
                                  .acmd_rdy_int_n(cmd_queue_push_rdy_n),
                                  .push_af(cmd_push_af),
                                  // the AHB Master Side is popping
                                  .clk_ahb(mhclk),
                                  .pop_rst_n(mhresetn),
                                  .pop_hcmd_int_n(pop_hcmd_int_n),
                                  .hcmd_queue_wd_int(hcmd_queue_wd_int),
                                  .hcmd_rdy_int_n(hcmd_rdy_int_n)
                                  );

DW_axi_x2h_write_data_buffer
 U_WR_DATA_BUFF (
             // AXI Slave Side is pushing
             .clk_axi(aclk),
                                             .push_rst_n(aresetn),
                                             .awword_int(awr_buff_wd),
                                             .push_awdata_int_n(push_write_buffer_n),
                                             .awdata_rdy_int_n(wr_buff_push_rdy_n),
                                             // the AHB Master Side is popping
                                             .clk_ahb(mhclk),
                                             .pop_rst_n(mhresetn),
                                             .hwword_int(hwword_int),
                                             .pop_wdata_int_n(pop_wdata_int_n),
                                             .hwdata_rdy_int_n(hwdata_rdy_int_n)
                                             );


DW_axi_x2h_resp_buffer
 U_RESP_BUFF (
               // the AXI slave side is popping
              .clk_axi(aclk),
                                    .pop_rst_n(aresetn),
                                    .awstatus_int(pop_resp_status_wd),
                                    .awid_int(pop_resp_id_wd),
                                    .pop_resp_int_n(pop_resp_n),
                                    .aresp_rdy_int_n(resp_pop_rdy_n),
                                    // the AHB Master Side is pushing
                                    .clk_ahb(mhclk),
                                    .push_rst_n(mhresetn),
                                    .hwstatus_int(hwstatus_int),
                                    .hwid_int(hwid_int),
                                    .push_resp_int_n(push_resp_int_n),
                                    .hresp_rdy_int_n(hresp_rdy_int_n)
                                    );

  // The hrdata_push_cnt signal bit width is configured for max read data buffer depth. The unused MSBs are tied to zeros.
DW_axi_x2h_read_data_buffer
 U_RD_DATA_BUFF (
             // AXI Slave Side is popping
             .clk_axi(aclk),
                                            .pop_rst_n(aresetn),
                                            .arstatus_int(arstatus_int),
                                            .arid_int(arid_int),
                                            .arlast_int(arlast_int),
                                            .ardata_int(ardata_int),
                                            .pop_data_int_n(pop_rdata_n),
                                            .arvalid_int_n(arvalid_int_n),
                                            // the AHB Master Side is pushing
                                            .clk_ahb(mhclk),
                                            .push_rst_n(mhresetn),
                                            .hrstatus_int(hrstatus_int),
                                            .hrid_int(hrid_int),
                                            .hrlast_int(hrlast_int),
                                            .hrdata_int(hrdata_int),
                                            .push_data_int_n(push_data_int_n),
                                            .hrdata_push_cnt(hrdata_push_cnt)
                                            );

// AHB Master interface

  //Depending on the configuration some signals may be tied to LOW/HIGH.
  //The hwstatus_int[0] is always tied to zero (because the RESP_SLVERR is 2'b10 and RESP_OKAY is 2'b00)
  //    When PASS_LOCK is not enabled the mhlock signal is tied to zero.

  //    When PASS_LOCK is not enabled the mhlock signal is tied to zero.
DW_axi_x2h_ahb_master
  U_ahb_master (
             // Inputs
             .clk(mhclk),
                                     .rst_n(mhresetn),
                                     .hcmd_queue_wd_int(hcmd_queue_wd_int),
                                     .hcmd_rdy_int_n(hcmd_rdy_int_n),
                                     .hwword_int(hwword_int),
                                     .hwdata_rdy_int_n(hwdata_rdy_int_n),
                                     .hresp_rdy_int_n(hresp_rdy_int_n),
                                     .hrdata_push_cnt(hrdata_push_cnt),
                                     .mhready(mhready),
                                     .mhresp(mhresp),
                                     .mhrdata(mhrdata),
                                     // Outputs
                                     .pop_hcmd_int_n(pop_hcmd_int_n),
                                     .pop_wdata_int_n(pop_wdata_int_n),
                                     .hwid_int(hwid_int),
                                     .hwstatus_int(hwstatus_int),
                                     .push_resp_int_n(push_resp_int_n),
                                     .hrid_int(hrid_int),
                                     .hrdata_int(hrdata_int),
                                     .hrstatus_int(hrstatus_int),
                                     .hrlast_int(hrlast_int),
                                     .push_data_int_n(push_data_int_n),
                                     .mhlock(mhlock),
                                     .mhaddr(mhaddr),
                                     .mhsize(mhsize),
                                     .mhtrans(mhtrans),
                                     .mhburst(mhburst),
                                     .mhwrite(mhwrite),
                                     .mhprot(mhprot),
                                     .mhwdata(mhwdata)
                                     );





endmodule // DW_axi_x2h








