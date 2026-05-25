// ---------------------------------------------------------------------
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
// File Version     :        $Revision: #7 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/axi_dev_br/src/DW_axi_x2h_ahb_master.v#7 $ 
//
// -------------------------------------------------------------------------
// Filename    : DW_axi_x2h_ahb_master.v
//
// Description : AHB Master for DW_axi_x2h bridge.
//-----------------------------------------------------------------------------

`include "DW_axi_x2h_all_includes.vh"

module DW_axi_x2h_ahb_master (

// Inputs

   clk, 
                              rst_n,
                              hcmd_queue_wd_int, 
                              hcmd_rdy_int_n,
                              hwword_int, 
                              hwdata_rdy_int_n,
                              hresp_rdy_int_n, 
                              hrdata_push_cnt,
                              mhready, 
                              mhresp, 
                              mhrdata,
                              // Outputs
                              pop_hcmd_int_n, 
                              pop_wdata_int_n,
                              hwid_int, 
                              hwstatus_int, 
                              push_resp_int_n,
                              hrid_int, 
                              hrdata_int,
                              hrstatus_int, 
                              hrlast_int,
                              push_data_int_n,
                              mhlock, 
                              mhaddr, 
                              mhsize,
                              mhtrans, 
                              mhburst, 
                              mhwrite, 
                              mhprot, 
                              mhwdata
                              );


   input                              clk;
   input                              rst_n;

// Interface to Common CMD Queue

   input   [`X2H_CMD_QUEUE_WIDTH-1:0] hcmd_queue_wd_int;   // Contains several fields

   input                              hcmd_rdy_int_n;      // Low means not empty

   output                             pop_hcmd_int_n;      // Low-true POP


// Interface to Write Data FIFO

   input  [`X2H_AXI_WDFIFO_WIDTH-1:0] hwword_int;          // DATA, WSTRB, LAST

   input                              hwdata_rdy_int_n;    // Low means not empty

   output                             pop_wdata_int_n;     // Low-true POP


// Interface to Write Response FIFO

   input                              hresp_rdy_int_n;     // Low means: OK to push

   output     [`X2H_AXI_ID_WIDTH-1:0] hwid_int;
   output                       [1:0] hwstatus_int;

   output                             push_resp_int_n;     // Low-true PUSH


// Interface to the RDFIFO

   input                        [7:0] hrdata_push_cnt;

   output     [`X2H_AXI_ID_WIDTH-1:0] hrid_int;
   output   [`X2H_AXI_DATA_WIDTH-1:0] hrdata_int;
   output                       [1:0] hrstatus_int;
   output                             hrlast_int;

   output                             push_data_int_n;


// The AHB signals


   input                              mhready;
   input       [`X2H_HRESP_WIDTH-1:0] mhresp;
   input    [`X2H_AHB_DATA_WIDTH-1:0] mhrdata;


   output                             mhlock;

   output   [`X2H_AHB_ADDR_WIDTH-1:0] mhaddr;
   output                       [2:0] mhsize;
   output                       [1:0] mhtrans;
   output                       [2:0] mhburst;
   output                             mhwrite;

   output                       [3:0] mhprot;
   output   [`X2H_AHB_DATA_WIDTH-1:0] mhwdata;


   // Internal wires:

   wire     [`X2H_CMD_ADDR_WIDTH-1:0] cmdq_addr;
   wire       [`X2H_AXI_ID_WIDTH-1:0] cmdq_id;
   wire                         [2:0] cmdq_axi_size;
   wire                         [1:0] cmdq_cache;
   wire                               cmdq_prot_2;
   wire                               cmdq_prot_0;
   wire                               cmdq_rw;
   wire                         [2:0] cmdq_try_size;
   wire                         [4:0] cmdq_try_mask;
   wire                         [1:0] cmdq_ds_factor;
   wire                        [11:0] cmdq_wrapmask;
   wire                        [13:0] cmdq_axibytes;
   wire                        [13:0] cmdq_axibytes_2b;
   wire                               cmdq_2b_first;
   wire            [`X2H_AXI_BLW-1:0] cmdq_frepcount;

   wire                               cmdq_valid;
   wire                               pop_cmdq;

   wire     [`X2H_AXI_DATA_WIDTH-1:0] wdfifo_wdata;
   wire    [`X2H_AXI_WSTRB_WIDTH-1:0] wdfifo_wstrb;
   wire                               wdfifo_wlast;

   wire                               wdfifo_valid;
   wire                               pop_wdfifo;


   wire                               cgen_cpipe_valid;
   wire                               cpipe_cgen_ready;
   wire                               cpipe_cgen_xfr_pending;
   wire     [`X2H_CMD_ADDR_WIDTH-1:0] cgen_cpipe_ahb_haddr;
   wire                               cgen_cpipe_ahb_hwrite;
   wire                         [2:0] cgen_cpipe_ahb_hsize;
   wire                         [2:0] cgen_cpipe_ahb_hburst;
   wire                         [3:0] cgen_cpipe_ahb_hprot;
   wire     [`X2H_AHB_DATA_WIDTH-1:0] cgen_cpipe_ahb_hwdata;
   wire                               cgen_cpipe_axi_last;
   wire                         [4:0] cgen_cpipe_rdfifo_req;
   wire       [`X2H_AXI_ID_WIDTH-1:0] cgen_cpipe_axi_id;
   wire                         [2:0] cgen_cpipe_axi_size;


   wire                               cpipe_if_valid;
   wire                               if_cpipe_ready;
   wire                               if_cpipe_xfr_pending;
   wire     [`X2H_CMD_ADDR_WIDTH-1:0] cpipe_if_ahb_haddr;
   wire                               cpipe_if_ahb_hwrite;
   wire                         [2:0] cpipe_if_ahb_hsize;
   wire                         [2:0] cpipe_if_ahb_hburst;
   wire                         [3:0] cpipe_if_ahb_hprot;
   wire     [`X2H_AHB_DATA_WIDTH-1:0] cpipe_if_ahb_hwdata;
   wire                               cpipe_if_axi_last;
   wire                         [4:0] cpipe_if_rdfifo_req;
   wire       [`X2H_AXI_ID_WIDTH-1:0] cpipe_if_axi_id;
   wire                         [2:0] cpipe_if_axi_size;

   wire                               if_cgen_wr_err;






DW_axi_x2h_ahb_fpipe
 U_fpipe (

  // Description : AHB FIFO pipeline. OPTIONALLY provides banks of flip-flops
  //               to retime info coming from the Command Queue and Write
  //               Data buffer.

  // Inputs
                              .clk(clk),
                              .rst_n(rst_n),
                              .hcmd_queue_wd_int(hcmd_queue_wd_int),
                              .hcmd_rdy_int_n(hcmd_rdy_int_n),
                              .hwword_int(hwword_int),
                              .hwdata_rdy_int_n(hwdata_rdy_int_n),
                              .pop_cmdq(pop_cmdq),
                              .pop_wdfifo(pop_wdfifo),
                              // Outputs
                              .pop_hcmd_int_n(pop_hcmd_int_n),
                              .pop_wdata_int_n(pop_wdata_int_n),
                              .cmdq_addr(cmdq_addr),
                              .cmdq_id(cmdq_id),
                              .cmdq_axi_size(cmdq_axi_size),
                              .cmdq_cache(cmdq_cache),
                              .cmdq_prot_2(cmdq_prot_2),
                              .cmdq_prot_0(cmdq_prot_0),
                              .cmdq_rw(cmdq_rw),
                              .cmdq_try_size(cmdq_try_size),
                              .cmdq_try_mask(cmdq_try_mask),
                              .cmdq_ds_factor(cmdq_ds_factor),
                              .cmdq_wrapmask(cmdq_wrapmask),
                              .cmdq_axibytes(cmdq_axibytes),
                              .cmdq_axibytes_2b(cmdq_axibytes_2b),
                              .cmdq_2b_first(cmdq_2b_first),
                              .cmdq_frepcount(cmdq_frepcount),
                              .cmdq_valid(cmdq_valid),
                              .wdfifo_wdata(wdfifo_wdata),
                              .wdfifo_wstrb(wdfifo_wstrb),
                              .wdfifo_wlast(wdfifo_wlast),
                              .wdfifo_valid(wdfifo_valid)
                              );


  //The hwstatus_int[0] is always tied to zero (because the RESP_SLVERR is 2'b10 and RESP_OKAY is 2'b00)
DW_axi_x2h_ahb_cgen
 U_cgen (

  // Description : AHB Command generator. This "CGEN" module pulls AXI commands
  //               from the Common CMD Queue and turns them into one or more
  //               AHB commands, which are then passed to the "IF"
  //               (DW_axi_x2h_ahb_if) module.
  //
  //               This CGEN module also pulls and processes data from the
  //               WDFIFO. Skipping over sparse write data happens here.
  //
  //               DOWNSIZING happens here.
  //
  //               Write responses are sent from this CGEN module.


  // Inputs
    .clk(clk),
                            .rst_n(rst_n),
                            .cmdq_addr(cmdq_addr),
                            .cmdq_id(cmdq_id),
                            .cmdq_axi_size(cmdq_axi_size),
                            .cmdq_cache(cmdq_cache),
                            .cmdq_prot_2(cmdq_prot_2),
                            .cmdq_prot_0(cmdq_prot_0),
                            .cmdq_rw(cmdq_rw),
                            .cmdq_try_size(cmdq_try_size),
                            .cmdq_try_mask(cmdq_try_mask),
                            .cmdq_ds_factor(cmdq_ds_factor),
                            .cmdq_wrapmask(cmdq_wrapmask),
                            .cmdq_axibytes(cmdq_axibytes),
                            .cmdq_axibytes_2b(cmdq_axibytes_2b),
                            .cmdq_2b_first(cmdq_2b_first),
                            .cmdq_frepcount(cmdq_frepcount),
                            .cmdq_valid(cmdq_valid),
                            .wdfifo_wdata(wdfifo_wdata),
                            .wdfifo_wstrb(wdfifo_wstrb),
                            .wdfifo_wlast(wdfifo_wlast),
                            .wdfifo_valid(wdfifo_valid),
                            .hresp_rdy_int_n(hresp_rdy_int_n),
                            .cpipe_cgen_ready(cpipe_cgen_ready),
                            .cpipe_cgen_xfr_pending(cpipe_cgen_xfr_pending),
                            .if_cgen_wr_err(if_cgen_wr_err),
                            // Outputs
                            .pop_cmdq(pop_cmdq),
                            .pop_wdfifo(pop_wdfifo),
                            .hwid_int(hwid_int),
                            .hwstatus_int(hwstatus_int),
                            .push_resp_int_n(push_resp_int_n),
                            .cgen_cpipe_valid(cgen_cpipe_valid),
                            .cgen_cpipe_ahb_haddr(cgen_cpipe_ahb_haddr),
                            .cgen_cpipe_ahb_hwrite(cgen_cpipe_ahb_hwrite),
                            .cgen_cpipe_ahb_hsize(cgen_cpipe_ahb_hsize),
                            .cgen_cpipe_ahb_hburst(cgen_cpipe_ahb_hburst),
                            .cgen_cpipe_ahb_hprot(cgen_cpipe_ahb_hprot),
                            .cgen_cpipe_ahb_hwdata(cgen_cpipe_ahb_hwdata),
                            .cgen_cpipe_axi_last(cgen_cpipe_axi_last),
                            .cgen_cpipe_rdfifo_req(cgen_cpipe_rdfifo_req),
                            .cgen_cpipe_axi_id(cgen_cpipe_axi_id),
                            .cgen_cpipe_axi_size(cgen_cpipe_axi_size)
                            );

DW_axi_x2h_ahb_cpipe
 U_cpipe (

  // Description : Pipeline stage between AHB CGEN and AHB IF. This puts
  //               a register between the AHB HREADY signal and the POP signals
  //               of the CMD Queue and WDFIFO.
  //
  //               This module looks at X2H_AHB_BUFFER_POP_MODE.
  //               The pipelining is put in optionally according to this.

  // Inputs
                              .clk(clk),
                              .rst_n(rst_n),
                              .cgen_cpipe_valid(cgen_cpipe_valid),
                              .cgen_cpipe_ahb_haddr(cgen_cpipe_ahb_haddr),
                              .cgen_cpipe_ahb_hwrite(cgen_cpipe_ahb_hwrite),
                              .cgen_cpipe_ahb_hsize(cgen_cpipe_ahb_hsize),
                              .cgen_cpipe_ahb_hburst(cgen_cpipe_ahb_hburst),
                              .cgen_cpipe_ahb_hprot(cgen_cpipe_ahb_hprot),
                              .cgen_cpipe_ahb_hwdata(cgen_cpipe_ahb_hwdata),
                              .cgen_cpipe_axi_last(cgen_cpipe_axi_last),
                              .cgen_cpipe_rdfifo_req(cgen_cpipe_rdfifo_req),
                              .cgen_cpipe_axi_id(cgen_cpipe_axi_id),
                              .cgen_cpipe_axi_size(cgen_cpipe_axi_size),
                              .if_cpipe_ready(if_cpipe_ready),
                              .if_cpipe_xfr_pending(if_cpipe_xfr_pending),
                              // Outputs
                              .cpipe_cgen_ready(cpipe_cgen_ready),
                              .cpipe_cgen_xfr_pending(cpipe_cgen_xfr_pending),
                              .cpipe_if_valid(cpipe_if_valid),
                              .cpipe_if_ahb_haddr(cpipe_if_ahb_haddr),
                              .cpipe_if_ahb_hwrite(cpipe_if_ahb_hwrite),
                              .cpipe_if_ahb_hsize(cpipe_if_ahb_hsize),
                              .cpipe_if_ahb_hburst(cpipe_if_ahb_hburst),
                              .cpipe_if_ahb_hprot(cpipe_if_ahb_hprot),
                              .cpipe_if_ahb_hwdata(cpipe_if_ahb_hwdata),
                              .cpipe_if_axi_last(cpipe_if_axi_last),
                              .cpipe_if_rdfifo_req(cpipe_if_rdfifo_req),
                              .cpipe_if_axi_id(cpipe_if_axi_id),
                              .cpipe_if_axi_size(cpipe_if_axi_size)
                              );

    assign mhlock = 1'b0;

  //When AHB_ADDR_WIDTH > AXI_ADDR_WIDTH, the extra MSBs of the mhaddr signal are tied to zeros.
DW_axi_x2h_ahb_if
 U_if (

  // Description : Final interface to AHB. Gets told what to do by the CGEN
  //               (via the CPIPE, for timing), and deals with AHB.
  //
  //               This module can be configured for either full AHB or AHB-Lite
  //               operation (this is done by "ifdef X2H_AHB_LITE_TRUE"
  //               statements.)
  //
  //               This IF module writes to the RDFIFO.
  //
  //               However, this IF module does NOT interface to the WDFIFO or
  //               or the Write Response Buffer. (The CGEN module does instead.)

  // Inputs
    .clk(clk),
                        .rst_n(rst_n),
                        .cpipe_if_valid(cpipe_if_valid),
                        .cpipe_if_ahb_haddr(cpipe_if_ahb_haddr),
                        .cpipe_if_ahb_hwrite(cpipe_if_ahb_hwrite),
                        .cpipe_if_ahb_hsize(cpipe_if_ahb_hsize),
                        .cpipe_if_ahb_hburst(cpipe_if_ahb_hburst),
                        .cpipe_if_ahb_hprot(cpipe_if_ahb_hprot),
                        .cpipe_if_ahb_hwdata(cpipe_if_ahb_hwdata),
                        .cpipe_if_axi_last(cpipe_if_axi_last),
                        .cpipe_if_rdfifo_req(cpipe_if_rdfifo_req),
                        .cpipe_if_axi_id(cpipe_if_axi_id),
                        .cpipe_if_axi_size(cpipe_if_axi_size),
                        .mhready(mhready),
                        .mhresp(mhresp),
                        .mhrdata(mhrdata),
                        .hrdata_push_cnt(hrdata_push_cnt),
                        // Outputs
                        .if_cpipe_ready(if_cpipe_ready),
                        .if_cpipe_xfr_pending(if_cpipe_xfr_pending),
                        .if_cgen_wr_err(if_cgen_wr_err),
                        .mhaddr(mhaddr),
                        .mhsize(mhsize),
                        .mhtrans(mhtrans),
                        .mhburst(mhburst),
                        .mhwrite(mhwrite),
                        .mhprot(mhprot),
                        .mhwdata(mhwdata),
                        .hrid_int(hrid_int),
                        .hrdata_int(hrdata_int),
                        .hrstatus_int(hrstatus_int),
                        .hrlast_int(hrlast_int),
                        .push_data_int_n(push_data_int_n)
                        );


endmodule




