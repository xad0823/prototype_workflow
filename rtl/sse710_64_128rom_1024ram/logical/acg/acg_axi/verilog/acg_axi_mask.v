//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------

module acg_axi_mask
  #(parameter
      DATA_WIDTH          = 128,
      AWID_WIDTH          = 32'd8,
      ARID_WIDTH          = 32'd8
  )
  (

    input   wire                                        aclk,
    input   wire                                        aresetn,

    input   wire                                        inact,
    input   wire                                        clk_qacceptn,

    input   wire                                        awvalids,
    input   wire                                        awvalidm_acg,
    input   wire                                        awreadys_acg,
    input   wire                                        awreadym,
    input   wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]  awids,

    output  wire                                        awvalids_acg,
    output  wire                                        awvalidm,
    output  wire                                        awreadys,
    output  wire                                        awreadym_acg,
    output  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]  awidm,

    input   wire                                        wvalids,
    input   wire                                        wvalidm_acg,
    input   wire                                        wreadys_acg,
    input   wire                                        wreadym,
    input   wire                                        wlasts,
    
    output  wire                                        wvalids_acg,
    output  wire                                        wvalidm,
    output  wire                                        wreadys,
    output  wire                                        wreadym_acg,
    output  wire                                        wlastm,
    output  wire                                        wlasts_acg,

    input   wire                                        bvalidm,
    input   wire                                        breadys,
    input   wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]  bidm,
    input   wire [1:0]                                  brespm,

    output  wire                                        bvalids,
    output  wire                                        bvalids_acg,
    output  wire                                        breadym,
    output  wire                                        breadys_acg,
    output  wire [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0]  bids,
    output  wire [1:0]                                  bresps,

    input   wire                                        arvalids,
    input   wire                                        arvalidm_acg,
    input   wire                                        arreadys_acg,
    input   wire                                        arreadym,
    input   wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]  arids,
    input   wire [7:0]                                  arlens,

    output  wire                                        arvalids_acg,
    output  wire                                        arvalidm,
    output  wire                                        arreadys,
    output  wire                                        arreadym_acg,
    output  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]  aridm,
    output  wire [7:0]                                  arlenm,

    input   wire                                        rvalidm,
    input   wire                                        rreadys,
    input   wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]  ridm,
    input   wire [1:0]                                  rrespm,
    input   wire [DATA_WIDTH-1:0]                       rdatam,
    input   wire                                        rlastm,

    output  wire                                        rvalids,
    output  wire                                        rvalids_acg,
    output  wire                                        rreadym,
    output  wire                                        rreadys_acg,
    output  wire [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0]  rids,
    output  wire [1:0]                                  rresps,
    output  wire [DATA_WIDTH-1:0]                       rdatas,
    output  wire                                        rlasts,
    output  wire                                        rlasts_acg,
    
    input   wire                                        awakeups,
    output  wire                                        awakeups_acg,

    output  wire                                        ds_read_busy,
    output  wire                                        ds_write_busy
    );

    wire        acg_open;
   
    wire        clk_on;


    wire       [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] awid_ds;
    wire       awvalid_ds;
    wire       awready_ds;

    wire       wlast_ds;
    wire       wvalid_ds;
    wire       wready_ds;

    wire       [((AWID_WIDTH>0)?(AWID_WIDTH-1):0):0] bid_ds;
    wire       [1:0] bresp_ds;
    wire       bvalid_ds;
    wire       bready_ds;

    wire       [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] arid_ds;
    wire       [7:0] arlen_ds;
    wire       arvalid_ds;
    wire       arready_ds;

    wire       [((ARID_WIDTH>0)?(ARID_WIDTH-1):0):0] rid_ds;
    wire       [1:0] rresp_ds;
    wire       rlast_ds;
    wire       rvalid_ds;
    wire       rready_ds;
  


    
     acg_axi_default_slave#(
     .AWID_WIDTH(AWID_WIDTH),
     .ARID_WIDTH(ARID_WIDTH)
   ) u_default_slave (
    .awid(awid_ds),
    .awvalid(awvalid_ds),
    .awready(awready_ds),

    .wlast(wlast_ds),
    .wvalid(wvalid_ds),
    .wready(wready_ds),

    .bid(bid_ds),
    .bresp(bresp_ds),
    .bvalid(bvalid_ds),
    .bready(bready_ds),

    .arid(arid_ds),
    .arlen(arlen_ds),
    .arvalid(arvalid_ds),
    .arready(arready_ds),

    .rid(rid_ds),
    .rresp(rresp_ds),
    .rlast(rlast_ds),
    .rvalid(rvalid_ds),
    .rready(rready_ds),

    .aclk(aclk),
    .aresetn(aresetn),

    .ds_read_busy(ds_read_busy),
    .ds_write_busy(ds_write_busy)

    );


    

    assign acg_open = !inact;
    assign clk_on = clk_qacceptn;

    
    
    

    assign awvalid_ds       = awvalids && (!acg_open) && clk_on;
    assign awvalids_acg     = awvalids && acg_open && (!ds_write_busy);
    assign awvalidm         = awvalidm_acg && acg_open && (!ds_write_busy);

    assign awreadys         = (awready_ds && clk_on && (!acg_open)) || (awreadys_acg && acg_open && (!ds_write_busy));
    assign awreadym_acg     = awreadym;

    assign awid_ds          = awids & {((AWID_WIDTH>0)?AWID_WIDTH:1){(!acg_open)}};
    assign awidm            = awids & {((AWID_WIDTH>0)?AWID_WIDTH:1){acg_open && (!ds_write_busy)}};

    
    
    

    assign wvalid_ds        = wvalids && ((!acg_open) || ds_write_busy ) && clk_on;
    assign wvalids_acg      = wvalids && acg_open && (!ds_write_busy);
    assign wvalidm          = wvalidm_acg && acg_open && (!ds_write_busy);

    assign wreadys          = (wready_ds && clk_on && ((!acg_open) || ds_write_busy ) ) || (wreadys_acg && acg_open && (!ds_write_busy));
    assign wreadym_acg      = wreadym;
    
    assign wlast_ds         = wlasts && (!acg_open|| ds_write_busy) && clk_on;
    assign wlastm           = wlasts && acg_open && (!ds_write_busy);
    assign wlasts_acg       = wlasts && acg_open && (!ds_write_busy);        

    
    
    

    assign bvalids          = (bvalid_ds && ((!acg_open) || ds_write_busy ) ) || (bvalidm && (acg_open && (!ds_write_busy)));
    assign bvalids_acg      = bvalidm; 

    assign bready_ds        = breadys && ((!acg_open) || ds_write_busy );
    assign breadym          = breadys && acg_open && (!ds_write_busy);
    assign breadys_acg      = breadym; 

    assign bids             = (bid_ds & {((AWID_WIDTH>0)?AWID_WIDTH:1){((!acg_open) || ds_write_busy )}}) |
                              (bidm & {((AWID_WIDTH>0)?AWID_WIDTH:1){(acg_open && (!ds_write_busy))}}) ;

    assign bresps           = (bresp_ds & {2{((!acg_open) || ds_write_busy )}}) |
                              (brespm & {2{(acg_open && (!ds_write_busy))}}) ;

   
    
    
    

    assign arvalid_ds       = arvalids && (!acg_open) && clk_on;
    assign arvalids_acg     = arvalids && acg_open && (!ds_read_busy);
    assign arvalidm         = arvalidm_acg && acg_open && (!ds_read_busy);

    assign arreadys         = (arready_ds && clk_on && (!acg_open)) || (arreadys_acg && acg_open && (!ds_read_busy));
    assign arreadym_acg     = arreadym;

    assign arid_ds          = arids & {((ARID_WIDTH>0)?ARID_WIDTH:1){(!acg_open) && clk_on}};
    assign aridm            = arids & {((ARID_WIDTH>0)?ARID_WIDTH:1){acg_open && (!ds_read_busy)}};

    assign arlen_ds         = arlens & {8{(!acg_open) && clk_on}};
    assign arlenm           = arlens & {8{acg_open && (!ds_read_busy)}};

 
    
    
    

    assign rvalids          = (rvalid_ds && ((!acg_open) || ds_read_busy ) ) || (rvalidm && (acg_open && (!ds_read_busy)));
    assign rvalids_acg      = rvalidm; 

    assign rready_ds        = rreadys && ((!acg_open) || ds_read_busy );
    assign rreadym          = rreadys && acg_open && (!ds_read_busy);
    assign rreadys_acg      = rreadym; 

    assign rids             = (rid_ds & {((ARID_WIDTH>0)?ARID_WIDTH:1){((!acg_open) || ds_read_busy )}}) |
                              (ridm & {((ARID_WIDTH>0)?ARID_WIDTH:1){(acg_open && (!ds_read_busy))}}) ;

    assign rresps           = (rresp_ds & {2{((!acg_open) || ds_read_busy )}}) |
                              (rrespm & {2{(acg_open && (!ds_read_busy))}}) ;

    assign rdatas           = ({DATA_WIDTH{1'b0}}) |
                              (rdatam & {DATA_WIDTH{(acg_open && (!ds_read_busy))}}) ;
  
    assign rlasts           = (rlast_ds & {((!acg_open) || ds_read_busy )}) |
                              (rlastm & {(acg_open && (!ds_read_busy))}) ;
    assign rlasts_acg       = rlastm;

    
    assign awakeups_acg     = awakeups;
    

endmodule

