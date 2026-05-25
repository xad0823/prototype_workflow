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
module firewall_f0_axi_reg_slc #(
    parameter AW_DIR = 3,
    parameter W_DIR  = 3,
    parameter B_DIR  = 3,
    parameter AR_DIR = 3,
    parameter R_DIR  = 3,

    parameter FC_AXIID_WIDTH      = 2 ,
    parameter FC_ADDR_WIDTH       = 32,
    parameter FC_AXIUSER_AR_WIDTH = 2 ,
    parameter FC_AXIUSER_AW_WIDTH = 2 ,
    parameter FC_AXIUSER_W_WIDTH  = 2 ,
    parameter FC_AXIUSER_B_WIDTH  = 2 ,
    parameter FC_AXIUSER_R_WIDTH  = 2 ,
    parameter FC_MST_ID_WIDTH     = 2 ,
    parameter FC_AXIDATA_WIDTH    = 32
) (
    input  wire                                   clk       ,
    input  wire                                   reset_n   ,

    input  wire [FC_AXIID_WIDTH-1:0]              arid_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               araddr_i  ,
    input  wire [7:0]                             arlen_i   ,
    input  wire [2:0]                             arsize_i  ,
    input  wire [1:0]                             arburst_i ,
    input  wire                                   arlock_i  ,
    input  wire [3:0]                             arcache_i ,
    input  wire [2:0]                             arprot_i  ,
    input  wire [3:0]                             arqos_i   ,
    input  wire [3:0]                             arregion_i,
    input  wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_i  ,
    input  wire                                   arvalid_i ,
    output wire                                   arready_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             armmusid_i,

    input  wire [FC_AXIID_WIDTH-1:0]              awid_i    ,
    input  wire [FC_ADDR_WIDTH-1:0]               awaddr_i  ,
    input  wire [7:0]                             awlen_i   ,
    input  wire [2:0]                             awsize_i  ,
    input  wire [1:0]                             awburst_i ,
    input  wire                                   awlock_i  ,
    input  wire [3:0]                             awcache_i ,
    input  wire [2:0]                             awprot_i  ,
    input  wire [3:0]                             awqos_i   ,
    input  wire [3:0]                             awregion_i,
    input  wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_i  ,
    input  wire                                   awvalid_i ,
    output wire                                   awready_o ,
    input  wire [FC_MST_ID_WIDTH-1:0]             awmmusid_i,

    input  wire [FC_AXIDATA_WIDTH-1:0]            wdata_i   ,
    input  wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_i   ,
    input  wire                                   wlast_i   ,
    input  wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_i   ,
    input  wire                                   wvalid_i  ,
    output wire                                   wready_o  ,

    output wire [FC_AXIID_WIDTH-1:0]              bid_o     ,
    output wire [1:0]                             bresp_o   ,
    output wire [FC_AXIUSER_B_WIDTH-1:0]          buser_o   ,
    output wire                                   bvalid_o  ,
    input  wire                                   bready_i  ,

    output wire [FC_AXIID_WIDTH-1:0]              rid_o     ,
    output wire [FC_AXIDATA_WIDTH-1:0]            rdata_o   ,
    output wire [1:0]                             rresp_o   ,
    output wire                                   rlast_o   ,
    output wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_o   ,
    output wire                                   rvalid_o  ,
    input  wire                                   rready_i  ,

    input  wire                                   awakeup_i ,

    output wire [FC_AXIID_WIDTH-1:0]              arid_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               araddr_o  ,
    output wire [7:0]                             arlen_o   ,
    output wire [2:0]                             arsize_o  ,
    output wire [1:0]                             arburst_o ,
    output wire                                   arlock_o  ,
    output wire [3:0]                             arcache_o ,
    output wire [2:0]                             arprot_o  ,
    output wire [3:0]                             arqos_o   ,
    output wire [3:0]                             arregion_o,
    output wire [FC_AXIUSER_AR_WIDTH-1:0]         aruser_o  ,
    output wire                                   arvalid_o ,
    input  wire                                   arready_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             armmusid_o,

    output wire [FC_AXIID_WIDTH-1:0]              awid_o    ,
    output wire [FC_ADDR_WIDTH-1:0]               awaddr_o  ,
    output wire [7:0]                             awlen_o   ,
    output wire [2:0]                             awsize_o  ,
    output wire [1:0]                             awburst_o ,
    output wire                                   awlock_o  ,
    output wire [3:0]                             awcache_o ,
    output wire [2:0]                             awprot_o  ,
    output wire [3:0]                             awqos_o   ,
    output wire [3:0]                             awregion_o,
    output wire [FC_AXIUSER_AW_WIDTH-1:0]         awuser_o  ,
    output wire                                   awvalid_o ,
    input  wire                                   awready_i ,
    output wire [FC_MST_ID_WIDTH-1:0]             awmmusid_o,

    output wire [FC_AXIDATA_WIDTH-1:0]            wdata_o   ,
    output wire [FC_AXIDATA_WIDTH/8-1:0]          wstrb_o   ,
    output wire                                   wlast_o   ,
    output wire [FC_AXIUSER_W_WIDTH-1:0]          wuser_o   ,
    output wire                                   wvalid_o  ,
    input  wire                                   wready_i  ,

    input  wire [FC_AXIID_WIDTH-1:0]              bid_i     ,
    input  wire [1:0]                             bresp_i   ,
    input  wire [FC_AXIUSER_B_WIDTH-1:0]          buser_i   ,
    input  wire                                   bvalid_i  ,
    output wire                                   bready_o  ,

    input  wire [FC_AXIID_WIDTH-1:0]              rid_i     ,
    input  wire [FC_AXIDATA_WIDTH-1:0]            rdata_i   ,
    input  wire [1:0]                             rresp_i   ,
    input  wire                                   rlast_i   ,
    input  wire [FC_AXIUSER_R_WIDTH-1:0]          ruser_i   ,
    input  wire                                   rvalid_i  ,
    output wire                                   rready_o  ,

    output reg                                    awakeup_o ,

    output wire                                   axi_slc_busy_o,
    input  wire                                   gate_hold_req_i

);

wire awakeup_i_int ;

wire arvalid_i_int ;
wire awvalid_i_int ;
wire wvalid_i_int  ;


wire arready_o_int    ;
wire awready_o_int    ;
wire wready_o_int     ;


localparam AXLEN_WIDTH    = 8;
localparam AXSIZE_WIDTH   = 3;
localparam AXBURST_WIDTH  = 2;
localparam AXLOCK_WIDTH   = 1;
localparam AXCACHE_WIDTH  = 4;
localparam AXPROT_WIDTH   = 3;
localparam AXQOS_WIDTH    = 4;
localparam AXREGION_WIDTH = 4;

localparam WSTRB_WIDTH = FC_AXIDATA_WIDTH/8;
localparam WLAST_WIDTH = 1                 ;

localparam BRESP_WIDTH = 2;

localparam RRESP_WIDTH = 2;
localparam RLAST_WIDTH = 1;

localparam AX_PAYLOAD_WIDTH = FC_AXIID_WIDTH      + 
                              FC_ADDR_WIDTH       + 
                              AXLEN_WIDTH         + 
                              AXSIZE_WIDTH        + 
                              AXBURST_WIDTH       + 
                              AXLOCK_WIDTH        + 
                              AXCACHE_WIDTH       + 
                              AXPROT_WIDTH        + 
                              AXQOS_WIDTH         + 
                              AXREGION_WIDTH      + 
                              FC_AXIUSER_AW_WIDTH + 
                              FC_MST_ID_WIDTH;      

localparam W_PAYLOAD_WIDTH = FC_AXIDATA_WIDTH  + 
                             WSTRB_WIDTH       + 
                             WLAST_WIDTH       + 
                             FC_AXIUSER_W_WIDTH; 

localparam B_PAYLOAD_WIDTH = FC_AXIID_WIDTH    + 
                             BRESP_WIDTH       + 
                             FC_AXIUSER_B_WIDTH; 

localparam R_PAYLOAD_WIDTH = FC_AXIID_WIDTH    + 
                             FC_AXIDATA_WIDTH  + 
                             RRESP_WIDTH       + 
                             RLAST_WIDTH       + 
                             FC_AXIUSER_R_WIDTH; 



assign axi_slc_busy_o = arvalid_i | awvalid_i | wvalid_i |
                        arvalid_o | awvalid_o | wvalid_o |
                        rvalid_o  | bvalid_o;


assign awakeup_i_int = awakeup_i & ~gate_hold_req_i;

assign arvalid_i_int = arvalid_i & ~gate_hold_req_i;
assign awvalid_i_int = awvalid_i & ~gate_hold_req_i;
assign wvalid_i_int  = wvalid_i  & ~gate_hold_req_i;

assign arready_o = arready_o_int & ~gate_hold_req_i;
assign awready_o = awready_o_int & ~gate_hold_req_i;
assign wready_o  = wready_o_int  & ~gate_hold_req_i;


wire [AX_PAYLOAD_WIDTH-1:0] aw_payload_i;

wire [AX_PAYLOAD_WIDTH-1:0] aw_payload_o;


assign aw_payload_i = {
    awid_i    , 
    awaddr_i  , 
    awlen_i   , 
    awsize_i  , 
    awburst_i , 
    awlock_i  , 
    awcache_i , 
    awprot_i  , 
    awqos_i   , 
    awregion_i, 
    awuser_i  , 
    awmmusid_i 
};

assign {
    awid_o    , 
    awaddr_o  , 
    awlen_o   , 
    awsize_o  , 
    awburst_o , 
    awlock_o  , 
    awcache_o , 
    awprot_o  , 
    awqos_o   , 
    awregion_o, 
    awuser_o  , 
    awmmusid_o 
} = aw_payload_o;

firewall_f0_axi_ch_reg_slc #(
    .PAYLD_WIDTH(AX_PAYLOAD_WIDTH),
    .REG_DIR    (AW_DIR          )
) u_aw_regslice (
    .clk      (clk         ),
    .reset_n  (reset_n     ),

    .valid_i  (awvalid_i_int   ),
    .ready_i  (awready_i   ),
    .payload_i(aw_payload_i),

    .valid_o  (awvalid_o   ),
    .ready_o  (awready_o_int   ),
    .payload_o(aw_payload_o)
);


wire [W_PAYLOAD_WIDTH-1:0] w_payload_i;

wire [W_PAYLOAD_WIDTH-1:0] w_payload_o;

assign w_payload_i = {
    wdata_i , 
    wstrb_i , 
    wlast_i , 
    wuser_i   
};

assign {
    wdata_o, 
    wstrb_o, 
    wlast_o, 
    wuser_o  
} = w_payload_o;

firewall_f0_axi_ch_reg_slc #(
    .PAYLD_WIDTH(W_PAYLOAD_WIDTH),
    .REG_DIR    (W_DIR          )
) u_w_regslice (
    .clk      (clk        ),
    .reset_n  (reset_n    ),

    .valid_i  (wvalid_i_int   ),
    .ready_i  (wready_i   ),
    .payload_i(w_payload_i),

    .valid_o  (wvalid_o   ),
    .ready_o  (wready_o_int   ),
    .payload_o(w_payload_o)
);


wire [B_PAYLOAD_WIDTH-1:0] b_payload_i;

wire [B_PAYLOAD_WIDTH-1:0] b_payload_o;

assign b_payload_i = {
    bid_i  , 
    bresp_i, 
    buser_i  
};

assign {
    bid_o  , 
    bresp_o, 
    buser_o  
} = b_payload_o;

firewall_f0_axi_ch_reg_slc #(
    .PAYLD_WIDTH(B_PAYLOAD_WIDTH),
    .REG_DIR    (B_DIR          )
) u_b_regslice (
    .clk      (clk        ),
    .reset_n  (reset_n    ),

    .valid_i  (bvalid_i   ),
    .ready_i  (bready_i   ),
    .payload_i(b_payload_i),

    .valid_o  (bvalid_o   ),
    .ready_o  (bready_o   ),
    .payload_o(b_payload_o)
);


wire [AX_PAYLOAD_WIDTH-1:0] ar_payload_i;

wire [AX_PAYLOAD_WIDTH-1:0] ar_payload_o;


assign ar_payload_i = {
    arid_i    , 
    araddr_i  , 
    arlen_i   , 
    arsize_i  , 
    arburst_i , 
    arlock_i  , 
    arcache_i , 
    arprot_i  , 
    arqos_i   , 
    arregion_i, 
    aruser_i  , 
    armmusid_i 
};

assign {
    arid_o    , 
    araddr_o  , 
    arlen_o   , 
    arsize_o  , 
    arburst_o , 
    arlock_o  , 
    arcache_o , 
    arprot_o  , 
    arqos_o   , 
    arregion_o, 
    aruser_o  , 
    armmusid_o 
} = ar_payload_o;

firewall_f0_axi_ch_reg_slc #(
    .PAYLD_WIDTH(AX_PAYLOAD_WIDTH),
    .REG_DIR    (AR_DIR          )
) u_ar_regslice (
    .clk      (clk         ),
    .reset_n  (reset_n     ),

    .valid_i  (arvalid_i_int   ),
    .ready_i  (arready_i   ),
    .payload_i(ar_payload_i),

    .valid_o  (arvalid_o   ),
    .ready_o  (arready_o_int   ),
    .payload_o(ar_payload_o)
);


wire [R_PAYLOAD_WIDTH-1:0] r_payload_i;

wire [R_PAYLOAD_WIDTH-1:0] r_payload_o;

assign r_payload_i = {
    rid_i  , 
    rdata_i, 
    rresp_i, 
    rlast_i, 
    ruser_i  
};

assign {
    rid_o  , 
    rdata_o, 
    rresp_o, 
    rlast_o, 
    ruser_o  
} = r_payload_o;

firewall_f0_axi_ch_reg_slc #(
    .PAYLD_WIDTH(R_PAYLOAD_WIDTH),
    .REG_DIR    (R_DIR          )
) u_r_regslice (
    .clk      (clk        ),
    .reset_n  (reset_n    ),

    .valid_i  (rvalid_i   ),
    .ready_i  (rready_i   ),
    .payload_i(r_payload_i),

    .valid_o  (rvalid_o   ),
    .ready_o  (rready_o   ),
    .payload_o(r_payload_o)
);



generate
  if (AR_DIR == 3 && AW_DIR == 3 && W_DIR == 3) begin: AWAKEUP_PASSTHROUGH

      always @(*)
      begin
          awakeup_o = awakeup_i; 
      end


  end else begin: AWAKEUP_FROM_REG

      always @(posedge clk or negedge reset_n) begin: AWAKEUP_REG
        if (!reset_n) begin
          awakeup_o <= 1'b0;
        end else begin
          awakeup_o <= awakeup_i_int |                                
                       arvalid_i_int | awvalid_i_int | wvalid_i_int | 
                       arvalid_o | awvalid_o | wvalid_o ;             
        end
      end

end
endgenerate

endmodule
