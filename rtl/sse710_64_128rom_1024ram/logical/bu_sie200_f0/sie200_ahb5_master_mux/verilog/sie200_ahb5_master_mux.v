//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Fri Nov 4 10:31:08 2016 +0000
//
//      Revision            : 80f92c3
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_master_mux #(
  parameter PORT0_ENABLE =  1,
  parameter PORT1_ENABLE =  1,
  parameter PORT2_ENABLE =  1,
  parameter ADDR_WIDTH   = 32,
  parameter DATA_WIDTH   = 32,
  parameter USER_WIDTH   =  1,
  parameter MASTER_WIDTH =  4
)
(
  input  wire                       hclk        ,
  input  wire                       hresetn     ,

  input  wire                       hsel_s0     ,
  input  wire                       hnonsec_s0  ,
  input  wire [ADDR_WIDTH-1:0]      haddr_s0    ,
  input  wire [1:0]                 htrans_s0   ,
  input  wire [2:0]                 hsize_s0    ,
  input  wire                       hwrite_s0   ,
  input  wire                       hready_s0   ,
  input  wire [6:0]                 hprot_s0    ,
  input  wire [2:0]                 hburst_s0   ,
  input  wire                       hmastlock_s0,
  input  wire [DATA_WIDTH-1:0]      hwdata_s0   ,
  input  wire                       hexcl_s0    ,
  input  wire [MASTER_WIDTH-1:0]    hmaster_s0  ,
  output wire [DATA_WIDTH-1:0]      hrdata_s0   ,
  output wire                       hreadyout_s0,
  output wire                       hresp_s0    ,
  output wire                       hexokay_s0  ,
  input  wire [USER_WIDTH-1:0]      hauser_s0   ,
  input  wire [USER_WIDTH-1:0]      hwuser_s0   ,
  output wire [USER_WIDTH-1:0]      hruser_s0   ,

  input  wire                       hsel_s1     ,
  input  wire                       hnonsec_s1  ,
  input  wire [ADDR_WIDTH-1:0]      haddr_s1    ,
  input  wire [1:0]                 htrans_s1   ,
  input  wire [2:0]                 hsize_s1    ,
  input  wire                       hwrite_s1   ,
  input  wire                       hready_s1   ,
  input  wire [6:0]                 hprot_s1    ,
  input  wire [2:0]                 hburst_s1   ,
  input  wire                       hmastlock_s1,
  input  wire [DATA_WIDTH-1:0]      hwdata_s1   ,
  input  wire                       hexcl_s1    ,
  input  wire [MASTER_WIDTH-1:0]    hmaster_s1  ,
  output wire [DATA_WIDTH-1:0]      hrdata_s1   ,
  output wire                       hreadyout_s1,
  output wire                       hresp_s1    ,
  output wire                       hexokay_s1  ,
  input  wire [USER_WIDTH-1:0]      hauser_s1   ,
  input  wire [USER_WIDTH-1:0]      hwuser_s1   ,
  output wire [USER_WIDTH-1:0]      hruser_s1   ,

  input  wire                       hsel_s2     ,
  input  wire                       hnonsec_s2  ,
  input  wire [ADDR_WIDTH-1:0]      haddr_s2    ,
  input  wire [1:0]                 htrans_s2   ,
  input  wire [2:0]                 hsize_s2    ,
  input  wire                       hwrite_s2   ,
  input  wire                       hready_s2   ,
  input  wire [6:0]                 hprot_s2    ,
  input  wire [2:0]                 hburst_s2   ,
  input  wire                       hmastlock_s2,
  input  wire [DATA_WIDTH-1:0]      hwdata_s2   ,
  input  wire                       hexcl_s2    ,
  input  wire [MASTER_WIDTH-1:0]    hmaster_s2  ,
  output wire [DATA_WIDTH-1:0]      hrdata_s2   ,
  output wire                       hreadyout_s2,
  output wire                       hresp_s2    ,
  output wire                       hexokay_s2  ,
  input  wire [USER_WIDTH-1:0]      hauser_s2   ,
  input  wire [USER_WIDTH-1:0]      hwuser_s2   ,
  output wire [USER_WIDTH-1:0]      hruser_s2   ,

  output wire                       hsel_m      ,
  output wire                       hnonsec_m   ,
  output wire [ADDR_WIDTH-1:0]      haddr_m     ,
  output wire [1:0]                 htrans_m    ,
  output wire [2:0]                 hsize_m     ,
  output wire                       hwrite_m    ,
  output wire                       hready_m    ,
  output wire [6:0]                 hprot_m     ,
  output wire [2:0]                 hburst_m    ,
  output wire                       hmastlock_m ,
  output wire [DATA_WIDTH-1:0]      hwdata_m    ,
  output wire                       hexcl_m     ,
  output wire [MASTER_WIDTH-1:0]    hmaster_m   ,
  input  wire                       hreadyout_m ,
  input  wire                       hresp_m     ,
  input  wire [DATA_WIDTH-1:0]      hrdata_m    ,
  input  wire                       hexokay_m   ,
  output wire [USER_WIDTH-1:0]      hauser_m    ,
  output wire [USER_WIDTH-1:0]      hwuser_m    ,
  input  wire [USER_WIDTH-1:0]      hruser_m
);


  localparam       HSIZE_W   = (DATA_WIDTH > 64) ? 3 : 2;
  localparam       HSIZE_MAX = HSIZE_W - 1;


localparam UNUSED_WIDTH            =    1          + 1          + 1;
wire [UNUSED_WIDTH-1:0]     unused = {hsize_s0[2], hsize_s1[2], hsize_s2[2]};
  reg     [2:0] mux_sel_addr_phase;
  reg     [2:0] mux_sel_data_phase;
  reg     [2:0] mux_sel_addr_phase_reg;
  wire    [2:0] bus_request;

  wire                  port_s0_trans_valid;
  wire                  port_s0_hold_clear;
  wire                  port_s0_input_hold;
  reg                   port_s0_hold_active;
  wire                  nxt_port_s0_hold_active;

  reg [ADDR_WIDTH-1:0]  haddr_s0_reg;
  reg                   htrans_s0_reg;
  reg                   hwrite_s0_reg;
  reg [MASTER_WIDTH-1:0]hmaster_s0_reg;
  reg    [HSIZE_MAX:0]  hsize_s0_reg;
  reg    [6:0]          hprot_s0_reg;
  reg    [2:0]          hburst_s0_reg;
  reg                   hmastlock_s0_reg;
  reg                   hnonsec_s0_reg;
  reg                   hexcl_s0_reg;
  reg [USER_WIDTH-1:0]  hauser_s0_reg;

  wire [ADDR_WIDTH-1:0] haddr_s0_ips;
  wire   [1:0]          htrans_s0_ips;
  wire                  hwrite_s0_ips;
  wire [MASTER_WIDTH-1:0] hmaster_s0_ips;
  wire   [HSIZE_MAX:0]  hsize_s0_ips;
  wire   [6:0]          hprot_s0_ips;
  wire   [2:0]          hburst_s0_ips;
  wire                  hmastlock_s0_ips;
  wire                  hready_s0_ips;
  wire                  hnonsec_s0_ips;
  wire                  hexcl_s0_ips;
  wire [USER_WIDTH-1:0] hauser_s0_ips;

  wire                  port_s1_trans_valid;
  wire                  port_s1_hold_clear;
  wire                  port_s1_input_hold;
  reg                   port_s1_hold_active;
  wire                  nxt_port_s1_hold_active;

  reg [ADDR_WIDTH-1:0]  haddr_s1_reg;
  reg                   htrans_s1_reg;
  reg                   hwrite_s1_reg;
  reg [MASTER_WIDTH-1:0]hmaster_s1_reg;
  reg    [HSIZE_MAX:0]  hsize_s1_reg;
  reg    [6:0]          hprot_s1_reg;
  reg    [2:0]          hburst_s1_reg;
  reg                   hmastlock_s1_reg;
  reg                   hnonsec_s1_reg;
  reg                   hexcl_s1_reg;
  reg [USER_WIDTH-1:0]  hauser_s1_reg;

  wire [ADDR_WIDTH-1:0] haddr_s1_ips;
  wire   [1:0]          htrans_s1_ips;
  wire                  hwrite_s1_ips;
  wire [MASTER_WIDTH-1:0] hmaster_s1_ips;
  wire   [HSIZE_MAX:0]  hsize_s1_ips;
  wire   [6:0]          hprot_s1_ips;
  wire   [2:0]          hburst_s1_ips;
  wire                  hmastlock_s1_ips;
  wire                  hready_s1_ips;
  wire                  hnonsec_s1_ips;
  wire                  hexcl_s1_ips;
  wire [USER_WIDTH-1:0] hauser_s1_ips;

  wire                  port_s2_trans_valid;
  wire                  port_s2_hold_clear;
  wire                  port_s2_input_hold;
  reg                   port_s2_hold_active;
  wire                  nxt_port_s2_hold_active;

  reg [ADDR_WIDTH-1:0]  haddr_s2_reg;
  reg                   htrans_s2_reg;
  reg                   hwrite_s2_reg;
  reg [MASTER_WIDTH-1:0]hmaster_s2_reg;
  reg    [HSIZE_MAX:0]  hsize_s2_reg;
  reg    [6:0]          hprot_s2_reg;
  reg    [2:0]          hburst_s2_reg;
  reg                   hmastlock_s2_reg;
  reg                   hnonsec_s2_reg;
  reg                   hexcl_s2_reg;
  reg [USER_WIDTH-1:0]  hauser_s2_reg;

  wire [ADDR_WIDTH-1:0] haddr_s2_ips;
  wire   [1:0]          htrans_s2_ips;
  wire                  hwrite_s2_ips;
  wire [MASTER_WIDTH-1:0] hmaster_s2_ips;
  wire   [HSIZE_MAX:0]  hsize_s2_ips;
  wire   [6:0]          hprot_s2_ips;
  wire   [2:0]          hburst_s2_ips;
  wire                  hmastlock_s2_ips;
  wire                  hready_s2_ips;
  wire                  hnonsec_s2_ips;
  wire                  hexcl_s2_ips;
  wire [USER_WIDTH-1:0] hauser_s2_ips;

  wire                    hsel_mux;
  wire [ADDR_WIDTH-1:0]   haddr_mux;
  wire   [1:0]            htrans_mux;
  wire                    hwrite_mux;
  wire [MASTER_WIDTH-1:0] hmaster_mux;
  wire   [HSIZE_MAX:0]    hsize_mux;
  wire   [6:0]            hprot_mux;
  wire   [2:0]            hburst_mux;
  wire                    hmastlock_mux;
  wire                    hready_mux;
  wire  [DATA_WIDTH-1:0]  hwdata_mux;
  wire                    hnonsec_mux;
  wire                    hexcl_mux;
  wire [USER_WIDTH-1:0]   hauser_mux;
  wire [USER_WIDTH-1:0]   hwuser_mux;

  wire   [2:0]            port_enable_mask;
  reg                     active_transfer_reg;
  wire                    nxt_active_transfer;

  assign port_enable_mask[0] = (PORT0_ENABLE!=1'b0) ? 1'b1 : 1'b0;
  assign port_enable_mask[1] = (PORT1_ENABLE!=1'b0) ? 1'b1 : 1'b0;
  assign port_enable_mask[2] = (PORT2_ENABLE!=1'b0) ? 1'b1 : 1'b0;

  assign port_s0_trans_valid = hsel_s0 & htrans_s0[1] & hready_s0;
  assign port_s0_hold_clear  = mux_sel_addr_phase[0] & hready_mux;
  assign port_s0_input_hold  = port_s0_trans_valid & (~port_s0_hold_clear);
  assign nxt_port_s0_hold_active = port_s0_input_hold | (port_s0_hold_active & (~port_s0_hold_clear));

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      port_s0_hold_active <= 1'b0;
    else if (port_enable_mask[0])
      port_s0_hold_active <= nxt_port_s0_hold_active;
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
      haddr_s0_reg     <= {ADDR_WIDTH{1'b0}};
      htrans_s0_reg    <= 1'b0;
      hwrite_s0_reg    <= 1'b0;
      hmaster_s0_reg   <= {MASTER_WIDTH{1'b0}};
      hsize_s0_reg     <= {HSIZE_W{1'b0}};
      hprot_s0_reg     <= {7{1'b0}};
      hburst_s0_reg    <= {3{1'b0}};
      hmastlock_s0_reg <= 1'b0;
      hnonsec_s0_reg   <= 1'b0;
      hexcl_s0_reg     <= 1'b0;
      hauser_s0_reg    <= {USER_WIDTH{1'b0}};
      end
    else if (port_s0_input_hold & port_enable_mask[0])
      begin
      haddr_s0_reg     <= haddr_s0;
      htrans_s0_reg    <= htrans_s0[0];
      hwrite_s0_reg    <= hwrite_s0;
      hmaster_s0_reg   <= hmaster_s0;
      hsize_s0_reg     <= hsize_s0[HSIZE_MAX:0];
      hprot_s0_reg     <= hprot_s0;
      hburst_s0_reg    <= hburst_s0;
      hmastlock_s0_reg <= hmastlock_s0;
      hnonsec_s0_reg   <= hnonsec_s0;
      hexcl_s0_reg     <= hexcl_s0;
      hauser_s0_reg    <= hauser_s0;
      end
  end

  assign haddr_s0_ips     = (port_s0_hold_active) ? haddr_s0_reg            : haddr_s0;
  assign htrans_s0_ips    = (port_s0_hold_active) ? {1'b1, htrans_s0_reg}   : htrans_s0;
  assign hwrite_s0_ips    = (port_s0_hold_active) ? hwrite_s0_reg           : hwrite_s0;
  assign hmaster_s0_ips   = (port_s0_hold_active) ? hmaster_s0_reg          : hmaster_s0;
  assign hsize_s0_ips     = (port_s0_hold_active) ? hsize_s0_reg            : hsize_s0[HSIZE_MAX:0];
  assign hprot_s0_ips     = (port_s0_hold_active) ? hprot_s0_reg            : hprot_s0;
  assign hburst_s0_ips    = (port_s0_hold_active) ? hburst_s0_reg           : hburst_s0;
  assign hmastlock_s0_ips = (port_s0_hold_active) ? hmastlock_s0_reg        : hmastlock_s0;
  assign hready_s0_ips    = (port_s0_hold_active) ? 1'b1                    : hready_s0;
  assign hnonsec_s0_ips   = (port_s0_hold_active) ? hnonsec_s0_reg          : hnonsec_s0;
  assign hexcl_s0_ips     = (port_s0_hold_active) ? hexcl_s0_reg            : hexcl_s0;
  assign hauser_s0_ips    = (port_s0_hold_active) ? hauser_s0_reg           : hauser_s0;

  assign hreadyout_s0 = mux_sel_data_phase[0] ? hreadyout_m : ~port_s0_hold_active;
  assign hresp_s0     = mux_sel_data_phase[0] ? hresp_m   : 1'b0;
  assign hrdata_s0    = hrdata_m;
  assign hruser_s0    = hruser_m;
  assign hexokay_s0   = mux_sel_data_phase[0] ? hexokay_m : 1'b0;

  assign port_s1_trans_valid = hsel_s1 & htrans_s1[1] & hready_s1;
  assign port_s1_hold_clear  = mux_sel_addr_phase[1] & hready_mux;
  assign port_s1_input_hold  = port_s1_trans_valid & (~port_s1_hold_clear);
  assign nxt_port_s1_hold_active = port_s1_input_hold | (port_s1_hold_active & (~port_s1_hold_clear));

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      port_s1_hold_active <= 1'b0;
    else if (port_enable_mask[1])
      port_s1_hold_active <= nxt_port_s1_hold_active;
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
      haddr_s1_reg     <= {ADDR_WIDTH{1'b0}};
      htrans_s1_reg    <= 1'b0;
      hwrite_s1_reg    <= 1'b0;
      hmaster_s1_reg   <= {MASTER_WIDTH{1'b0}};
      hsize_s1_reg     <= {HSIZE_W{1'b0}};
      hprot_s1_reg     <= {7{1'b0}};
      hburst_s1_reg    <= {3{1'b0}};
      hmastlock_s1_reg <= 1'b0;
      hnonsec_s1_reg   <= 1'b0;
      hexcl_s1_reg     <= 1'b0;
      hauser_s1_reg    <= {USER_WIDTH{1'b0}};
      end
    else if (port_s1_input_hold & port_enable_mask[1])
      begin
      haddr_s1_reg     <= haddr_s1;
      htrans_s1_reg    <= htrans_s1[0];
      hwrite_s1_reg    <= hwrite_s1;
      hmaster_s1_reg   <= hmaster_s1;
      hsize_s1_reg     <= hsize_s1[HSIZE_MAX:0];
      hprot_s1_reg     <= hprot_s1;
      hburst_s1_reg    <= hburst_s1;
      hmastlock_s1_reg <= hmastlock_s1;
      hnonsec_s1_reg   <= hnonsec_s1;
      hexcl_s1_reg     <= hexcl_s1;
      hauser_s1_reg    <= hauser_s1;
      end
  end

  assign haddr_s1_ips     = (port_s1_hold_active) ? haddr_s1_reg            : haddr_s1;
  assign htrans_s1_ips    = (port_s1_hold_active) ? {1'b1, htrans_s1_reg}   : htrans_s1;
  assign hwrite_s1_ips    = (port_s1_hold_active) ? hwrite_s1_reg           : hwrite_s1;
  assign hmaster_s1_ips   = (port_s1_hold_active) ? hmaster_s1_reg          : hmaster_s1;
  assign hsize_s1_ips     = (port_s1_hold_active) ? hsize_s1_reg            : hsize_s1[HSIZE_MAX:0];
  assign hprot_s1_ips     = (port_s1_hold_active) ? hprot_s1_reg            : hprot_s1;
  assign hburst_s1_ips    = (port_s1_hold_active) ? hburst_s1_reg           : hburst_s1;
  assign hmastlock_s1_ips = (port_s1_hold_active) ? hmastlock_s1_reg        : hmastlock_s1;
  assign hready_s1_ips    = (port_s1_hold_active) ? 1'b1                    : hready_s1;
  assign hnonsec_s1_ips   = (port_s1_hold_active) ? hnonsec_s1_reg          : hnonsec_s1;
  assign hexcl_s1_ips     = (port_s1_hold_active) ? hexcl_s1_reg            : hexcl_s1;
  assign hauser_s1_ips    = (port_s1_hold_active) ? hauser_s1_reg           : hauser_s1;

  assign hreadyout_s1 = mux_sel_data_phase[1] ? hreadyout_m : ~port_s1_hold_active;
  assign hresp_s1     = mux_sel_data_phase[1] ? hresp_m   : 1'b0;
  assign hrdata_s1    = hrdata_m;
  assign hruser_s1    = hruser_m;
  assign hexokay_s1   = mux_sel_data_phase[1] ? hexokay_m : 1'b0;


  assign port_s2_trans_valid = hsel_s2 & htrans_s2[1] & hready_s2;

  assign port_s2_hold_clear  = mux_sel_addr_phase[2] & hready_mux;

  assign port_s2_input_hold  = port_s2_trans_valid & (~port_s2_hold_clear);

  assign nxt_port_s2_hold_active = port_s2_input_hold | (port_s2_hold_active & (~port_s2_hold_clear));

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      port_s2_hold_active <= 1'b0;
    else if (port_enable_mask[2])
      port_s2_hold_active <= nxt_port_s2_hold_active;
  end

  always @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
      haddr_s2_reg     <= {ADDR_WIDTH{1'b0}};
      htrans_s2_reg    <= 1'b0;
      hwrite_s2_reg    <= 1'b0;
      hmaster_s2_reg   <= {MASTER_WIDTH{1'b0}};
      hsize_s2_reg     <= {HSIZE_W{1'b0}};
      hprot_s2_reg     <= {7{1'b0}};
      hburst_s2_reg    <= {3{1'b0}};
      hmastlock_s2_reg <= 1'b0;
      hnonsec_s2_reg   <= 1'b0;
      hexcl_s2_reg     <= 1'b0;
      hauser_s2_reg    <= {USER_WIDTH{1'b0}};
      end
    else if (port_s2_input_hold & port_enable_mask[2])
      begin
      haddr_s2_reg     <= haddr_s2;
      htrans_s2_reg    <= htrans_s2[0];
      hwrite_s2_reg    <= hwrite_s2;
      hmaster_s2_reg   <= hmaster_s2;
      hsize_s2_reg     <= hsize_s2[HSIZE_MAX:0];
      hprot_s2_reg     <= hprot_s2;
      hburst_s2_reg    <= hburst_s2;
      hmastlock_s2_reg <= hmastlock_s2;
      hnonsec_s2_reg   <= hnonsec_s2;
      hexcl_s2_reg     <= hexcl_s2;
      hauser_s2_reg    <= hauser_s2;
      end
  end

  assign haddr_s2_ips     = (port_s2_hold_active) ? haddr_s2_reg            : haddr_s2;
  assign htrans_s2_ips    = (port_s2_hold_active) ? {1'b1, htrans_s2_reg}   : htrans_s2;
  assign hwrite_s2_ips    = (port_s2_hold_active) ? hwrite_s2_reg           : hwrite_s2;
  assign hmaster_s2_ips   = (port_s2_hold_active) ? hmaster_s2_reg          : hmaster_s2;
  assign hsize_s2_ips     = (port_s2_hold_active) ? hsize_s2_reg            : hsize_s2[HSIZE_MAX:0];
  assign hprot_s2_ips     = (port_s2_hold_active) ? hprot_s2_reg            : hprot_s2;
  assign hburst_s2_ips    = (port_s2_hold_active) ? hburst_s2_reg           : hburst_s2;
  assign hmastlock_s2_ips = (port_s2_hold_active) ? hmastlock_s2_reg        : hmastlock_s2;
  assign hready_s2_ips    = (port_s2_hold_active) ? 1'b1                    : hready_s2;
  assign hnonsec_s2_ips   = (port_s2_hold_active) ? hnonsec_s2_reg          : hnonsec_s2;
  assign hexcl_s2_ips     = (port_s2_hold_active) ? hexcl_s2_reg            : hexcl_s2;
  assign hauser_s2_ips    = (port_s2_hold_active) ? hauser_s2_reg           : hauser_s2;

  assign hreadyout_s2 = mux_sel_data_phase[2] ? hreadyout_m : ~port_s2_hold_active;
  assign hresp_s2     = mux_sel_data_phase[2] ? hresp_m   : 1'b0;
  assign hrdata_s2    = hrdata_m;
  assign hruser_s2    = hruser_m;
  assign hexokay_s2   = mux_sel_data_phase[2] ? hexokay_m : 1'b0;


        wire   trans_announced_stalled = hsel_mux & htrans_mux[1] & (~hready_mux);
        reg    trans_announced_stalled_reg;

        always @(posedge hclk or negedge hresetn)
          begin
          if (~hresetn)
            trans_announced_stalled_reg <= 1'b0;
          else
            trans_announced_stalled_reg <= trans_announced_stalled;
          end

        wire   locked_active_trans = hsel_mux & hmastlock_mux;
        reg    locked_active_trans_reg;

        always @(posedge hclk or negedge hresetn)
          begin
          if (~hresetn)
            locked_active_trans_reg <= 1'b0;
          else if (hready_mux)
            locked_active_trans_reg <= locked_active_trans;
          end

        reg   reg_fixed_length_burst;
        wire  nxt_fixed_length_burst;
        reg   reg_fixed_length_burst_err;
        wire  nxt_fixed_length_burst_err;

        assign nxt_fixed_length_burst = (hburst_mux[2:1] != 2'b00) & (|htrans_mux);
        always @(posedge hclk or negedge hresetn)
          begin
          if (~hresetn)
            reg_fixed_length_burst <= 1'b0;
          else if (hready_mux)
            reg_fixed_length_burst <= nxt_fixed_length_burst;
          end

        assign nxt_fixed_length_burst_err = active_transfer_reg & reg_fixed_length_burst &
                                            (~hreadyout_m) & hresp_m;

        always @(posedge hclk or negedge hresetn)
          begin
          if (~hresetn)
            reg_fixed_length_burst_err <= 1'b0;
          else if (nxt_fixed_length_burst_err|reg_fixed_length_burst_err)
            reg_fixed_length_burst_err <= nxt_fixed_length_burst_err;
          end

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        mux_sel_addr_phase_reg <= 3'b000;
      else
        mux_sel_addr_phase_reg <= mux_sel_addr_phase;
    end

  reg  reg_round_robin_state;
  wire nxt_round_robin_state;
  assign nxt_round_robin_state = (mux_sel_addr_phase[1]) |
                                 (reg_round_robin_state & ((~mux_sel_addr_phase[0]) & port_enable_mask[0]));

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        reg_round_robin_state <= 1'b0;
      else if (hready_mux)
        reg_round_robin_state <= nxt_round_robin_state;
    end

  assign bus_request[0] = (port_s0_hold_active | port_s0_trans_valid) & port_enable_mask[0];
  assign bus_request[1] = (port_s1_hold_active | port_s1_trans_valid) & port_enable_mask[1];
  assign bus_request[2] = (port_s2_hold_active | port_s2_trans_valid) & port_enable_mask[2];

  wire [2:0] lock_request;

  assign lock_request   = bus_request & {hmastlock_s2_ips,hmastlock_s1_ips,hmastlock_s0_ips};

  wire locked_ongoing;
  wire locked_ongoing_clr;

  assign locked_ongoing_clr = ((mux_sel_addr_phase_reg[2] & (~hsel_s2 | ~hmastlock_s2) & (hready_s2 | htrans_s2[1])) ||
                               (mux_sel_addr_phase_reg[1] & (~hsel_s1 | ~hmastlock_s1) & (hready_s1 | htrans_s1[1])) ||
                               (mux_sel_addr_phase_reg[0] & (~hsel_s0 | ~hmastlock_s0) & (hready_s0 | htrans_s0[1])));
  assign locked_ongoing = locked_active_trans_reg & ~locked_ongoing_clr;

  always @(*)
    begin
      if (  (trans_announced_stalled_reg & |(bus_request & mux_sel_addr_phase_reg)) |
            locked_ongoing |
            (reg_fixed_length_burst & |({htrans_s2[0],htrans_s1[0],htrans_s0[0]} & mux_sel_addr_phase_reg)) |
            (reg_fixed_length_burst_err & |(bus_request & mux_sel_addr_phase_reg)))
        mux_sel_addr_phase = mux_sel_addr_phase_reg;
      else if (~|(bus_request & mux_sel_addr_phase_reg) & |mux_sel_addr_phase_reg & hresp_m) begin
         mux_sel_addr_phase = 3'b000;
      end
      else if (locked_ongoing_clr & |lock_request) begin
         mux_sel_addr_phase = 3'b000;
      end
      else if (bus_request[2])
        mux_sel_addr_phase = 3'b100;
      else if (bus_request[1:0]==2'b11)
        mux_sel_addr_phase = ({1'b0, ~reg_round_robin_state, reg_round_robin_state});
      else
        mux_sel_addr_phase = bus_request;
    end

  wire [2:0] nxt_mux_sel_data_phase;
  assign     nxt_mux_sel_data_phase = mux_sel_addr_phase;

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        mux_sel_data_phase <= 3'b000;
      else if (hready_mux)
        mux_sel_data_phase <= nxt_mux_sel_data_phase;
    end

  assign nxt_active_transfer = hsel_mux & htrans_mux[1];

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        active_transfer_reg <= 1'b0;
      else if (hready_mux)
        active_transfer_reg <= nxt_active_transfer;
    end


  assign   hsel_mux   =  ((   mux_sel_addr_phase[0]) & (port_s0_hold_active|hsel_s0)) |
                         ((   mux_sel_addr_phase[1]) & (port_s1_hold_active|hsel_s1)) |
                         ((   mux_sel_addr_phase[2]) & (port_s2_hold_active|hsel_s2)) ;
  assign   haddr_mux  =  ({ADDR_WIDTH{mux_sel_addr_phase[0]}} & haddr_s0_ips) |
                         ({ADDR_WIDTH{mux_sel_addr_phase[1]}} & haddr_s1_ips) |
                         ({ADDR_WIDTH{mux_sel_addr_phase[2]}} & haddr_s2_ips) ;
  assign   htrans_mux =  ({ 2{mux_sel_addr_phase[0]}} & htrans_s0_ips) |
                         ({ 2{mux_sel_addr_phase[1]}} & htrans_s1_ips) |
                         ({ 2{mux_sel_addr_phase[2]}} & htrans_s2_ips) ;
  assign   hwrite_mux =  (    mux_sel_addr_phase[0]   & hwrite_s0_ips) |
                         (    mux_sel_addr_phase[1]   & hwrite_s1_ips) |
                         (    mux_sel_addr_phase[2]   & hwrite_s2_ips) ;
  assign   hmaster_mux=  ({MASTER_WIDTH{mux_sel_addr_phase[0]}} & hmaster_s0_ips) |
                         ({MASTER_WIDTH{mux_sel_addr_phase[1]}} & hmaster_s1_ips) |
                         ({MASTER_WIDTH{mux_sel_addr_phase[2]}} & hmaster_s2_ips) ;
  assign   hsize_mux  =  ({ HSIZE_W{mux_sel_addr_phase[0]}} & hsize_s0_ips) |
                         ({ HSIZE_W{mux_sel_addr_phase[1]}} & hsize_s1_ips) |
                         ({ HSIZE_W{mux_sel_addr_phase[2]}} & hsize_s2_ips) ;
  assign   hprot_mux  =  ({ 7{mux_sel_addr_phase[0]}} & hprot_s0_ips) |
                         ({ 7{mux_sel_addr_phase[1]}} & hprot_s1_ips) |
                         ({ 7{mux_sel_addr_phase[2]}} & hprot_s2_ips) ;
  assign   hburst_mux =  ({ 3{mux_sel_addr_phase[0]}} & hburst_s0_ips) |
                         ({ 3{mux_sel_addr_phase[1]}} & hburst_s1_ips) |
                         ({ 3{mux_sel_addr_phase[2]}} & hburst_s2_ips) ;
  assign   hmastlock_mux=(    mux_sel_addr_phase[0]   & hmastlock_s0_ips) |
                         (    mux_sel_addr_phase[1]   & hmastlock_s1_ips) |
                         (    mux_sel_addr_phase[2]   & hmastlock_s2_ips) ;

  assign   hnonsec_mux=  (    mux_sel_addr_phase[0]   & hnonsec_s0_ips) |
                         (    mux_sel_addr_phase[1]   & hnonsec_s1_ips) |
                         (    mux_sel_addr_phase[2]   & hnonsec_s2_ips) ;

  assign   hexcl_mux  =  (    mux_sel_addr_phase[0]   & hexcl_s0_ips) |
                         (    mux_sel_addr_phase[1]   & hexcl_s1_ips) |
                         (    mux_sel_addr_phase[2]   & hexcl_s2_ips) ;

  assign   hauser_mux =  ({USER_WIDTH{mux_sel_addr_phase[0]}} & hauser_s0_ips) |
                         ({USER_WIDTH{mux_sel_addr_phase[1]}} & hauser_s1_ips) |
                         ({USER_WIDTH{mux_sel_addr_phase[2]}} & hauser_s2_ips) ;

  assign   hready_mux =  (active_transfer_reg) ?
                         hreadyout_m :
                         (
                          (    mux_sel_addr_phase[0]   & hready_s0_ips) |
                          (    mux_sel_addr_phase[1]   & hready_s1_ips) |
                          (    mux_sel_addr_phase[2]   & hready_s2_ips) |
                          (    mux_sel_addr_phase == 3'b000));

  assign   hwdata_mux =  ({DATA_WIDTH{mux_sel_data_phase[0]}} & hwdata_s0) |
                         ({DATA_WIDTH{mux_sel_data_phase[1]}} & hwdata_s1) |
                         ({DATA_WIDTH{mux_sel_data_phase[2]}} & hwdata_s2) ;

  assign   hwuser_mux =  ({USER_WIDTH{mux_sel_data_phase[0]}} & hwuser_s0) |
                         ({USER_WIDTH{mux_sel_data_phase[1]}} & hwuser_s1) |
                         ({USER_WIDTH{mux_sel_data_phase[2]}} & hwuser_s2) ;

  reg      reg_idle_flag;
  wire     nxt_idle_flag = (htrans_m==2'b00 | reg_idle_flag) & (~hready_m);

  always @(posedge hclk or negedge hresetn)
    begin
      if (~hresetn)
        reg_idle_flag <= 1'b0;
      else
        reg_idle_flag <= nxt_idle_flag;
    end

  wire    [1:0]  seq_tran_suppress = ((mux_sel_addr_phase != mux_sel_data_phase)|reg_idle_flag) ? 2'b10 : 2'b11;

  assign   hsel_m      = hsel_mux;
  assign   haddr_m     = haddr_mux;
  assign   htrans_m    = htrans_mux & seq_tran_suppress;
  assign   hwrite_m    = hwrite_mux;
  assign   hmaster_m   = hmaster_mux;
  assign   hready_m    = hready_mux;
  assign   hsize_m[1:0] = hsize_mux[1:0];
  assign   hsize_m[2]   = (DATA_WIDTH > 64) ? hsize_mux[HSIZE_MAX] : 1'b0;
  assign   hprot_m     = hprot_mux;
  assign   hburst_m    = hburst_mux;
  assign   hmastlock_m = hmastlock_mux;
  assign   hwdata_m    = hwdata_mux;
  assign   hnonsec_m   = hnonsec_mux;
  assign   hexcl_m     = hexcl_mux;
  assign   hauser_m    = hauser_mux;
  assign   hwuser_m    = hwuser_mux;



























endmodule
