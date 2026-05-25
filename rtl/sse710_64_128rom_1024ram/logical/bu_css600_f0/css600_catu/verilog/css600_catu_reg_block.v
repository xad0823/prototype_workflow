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
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_reg_block
#(
  parameter APB_ADDR_WIDTH = 12,
  parameter APB_DATA_WIDTH = 32,
  parameter AXI_ADDR_WIDTH = 40,
  parameter AXI_DATA_WIDTH = 64
)(
  input  wire                       clk,
  input  wire                       reset_n,
  input  wire                       reg_write,
  input  wire                       reg_read,
  input  wire [APB_ADDR_WIDTH-1:0]  reg_addr,
  input  wire [APB_DATA_WIDTH-1:0]  reg_wdata,
  output wire [APB_DATA_WIDTH-1:0]  reg_rdata,
  input  wire                       status_spiden,
  input  wire                       status_dbgen,
  input  wire                       status_axislv_busy,
  input  wire                       status_slw_busy,
  input  wire                       status_axi_autherr,
  input  wire                       status_axi_resperr,
  input  wire                       status_addrerr,
  output wire                       ctrl_enable,
  output wire                       ctrl_mode,
  output wire                       ctrl_addrerr,
  output wire [3:0]                 ctrl_arcache,
  output wire [1:0]                 ctrl_arprot,
  output wire [AXI_ADDR_WIDTH-1:0]  ctrl_sladdr,
  output wire [AXI_ADDR_WIDTH-1:0]  ctrl_inaddr,
  output wire                       clr_tlbs,
  input  wire [3:0]                 revand
);

`include "css600_catu_localparams.v"

  localparam       L_NUM_REGS  = 25;
  localparam       L_SIZE_REGS = 32;

  localparam [4:0] L_AXIDW     = (AXI_DATA_WIDTH == 32)  ? 5'h04 :
                                 (AXI_DATA_WIDTH == 64)  ? 5'h08 :
                                 (AXI_DATA_WIDTH == 128) ? 5'h10 :
                                 5'h08;
  localparam [6:0] L_AXIAW     = (AXI_ADDR_WIDTH == 32) ? 7'h20 :
                                 (AXI_ADDR_WIDTH == 40) ? 7'h28 :
                                 (AXI_ADDR_WIDTH == 44) ? 7'h2C :
                                 (AXI_ADDR_WIDTH == 48) ? 7'h30 :
                                 (AXI_ADDR_WIDTH == 52) ? 7'h34 :
                                 (AXI_ADDR_WIDTH == 56) ? 7'h38 :
                                 (AXI_ADDR_WIDTH == 64) ? 7'h40 :
                                 7'h20;
  localparam       L_ADDRHI     = AXI_ADDR_WIDTH-L_SIZE_REGS-1;
  localparam       L_SLADDR_WIDTH = L_SIZE_REGS-REG_SLADDRLO_SLADDRLO_LSB;
  localparam       L_INADDR_WIDTH = L_SIZE_REGS-REG_INADDRLO_INADDRLO_LSB;


  wire                             it_en;
  wire                             control_sel;
  wire                             mode_sel;
  wire                             axictrl_sel;
  wire                             irqen_sel;
  wire                             sladdrlo_sel;
  wire                             inaddrlo_sel;
  wire                             inaddrhi_sel;
  wire                             status_sel;
  wire                             itirq_sel;
  wire                             itctrl_sel;
  wire                             claimset_sel;
  wire                             claimclr_sel;
  wire                             authstatus_sel;
  wire                             devarch_sel;
  wire                             devid_sel;
  wire                             devtype_sel;
  wire                             pidr4_sel;
  wire                             pidr0_sel;
  wire                             pidr1_sel;
  wire                             pidr2_sel;
  wire                             pidr3_sel;
  wire                             cidr0_sel;
  wire                             cidr1_sel;
  wire                             cidr2_sel;
  wire                             cidr3_sel;

  wire                             control_wr_en;
  wire                             mode_wr_en;
  wire                             axictrl_wr_en;
  wire                             irqen_wr_en;
  wire                             sladdrlo_wr_en;
  wire                             inaddrlo_wr_en;
  wire                             itirq_wr_en;
  reg                              it_addrerr;
  wire                             itctrl_wr_en;
  wire                             claimset_wr_en;
  wire                             claimclr_wr_en;
  wire                             irq_wr_en;
  wire                             axierr_wr_en;
  wire                             addrerr_wr_en;

  wire [L_NUM_REGS-1:0]            rddata_sel;
  wire                             control_rd_en;
  wire                             mode_rd_en;
  wire                             axictrl_rd_en;
  wire                             irqen_rd_en;
  wire                             sladdrlo_rd_en;
  wire                             sladdrhi_rd_en;
  wire                             inaddrlo_rd_en;
  wire                             inaddrhi_rd_en;
  wire                             status_rd_en;
  wire                             itctrl_rd_en;
  wire                             claimset_rd_en;
  wire                             claimclr_rd_en;
  wire                             authstatus_rd_en;
  wire                             devarch_rd_en;
  wire                             devid_rd_en;
  wire                             devtype_rd_en;
  wire                             pidr4_rd_en;
  wire                             pidr0_rd_en;
  wire                             pidr1_rd_en;
  wire                             pidr2_rd_en;
  wire                             pidr3_rd_en;
  wire                             cidr0_rd_en;
  wire                             cidr1_rd_en;
  wire                             cidr2_rd_en;
  wire                             cidr3_rd_en;

  wire [(L_NUM_REGS*L_SIZE_REGS)-1:0]  rddata_array;
  reg  [L_SIZE_REGS-1:0]               control_rd_data;
  reg  [L_SIZE_REGS-1:0]               mode_rd_data;
  reg  [L_SIZE_REGS-1:0]               axictrl_rd_data;
  reg  [L_SIZE_REGS-1:0]               irqen_rd_data;
  reg  [L_SIZE_REGS-1:0]               sladdrlo_rd_data;
  wire [L_SIZE_REGS-1:0]               sladdrhi_rd_data;
  reg  [L_SIZE_REGS-1:0]               inaddrlo_rd_data;
  wire [L_SIZE_REGS-1:0]               inaddrhi_rd_data;
  reg  [L_SIZE_REGS-1:0]               status_rd_data;
  reg  [L_SIZE_REGS-1:0]               itctrl_rd_data;
  reg  [L_SIZE_REGS-1:0]               claimset_rd_data;
  reg  [L_SIZE_REGS-1:0]               claimclr_rd_data;
  reg  [L_SIZE_REGS-1:0]               authstatus_rd_data;
  reg  [L_SIZE_REGS-1:0]               devarch_rd_data;
  reg  [L_SIZE_REGS-1:0]               devid_rd_data;
  reg  [L_SIZE_REGS-1:0]               devtype_rd_data;
  reg  [L_SIZE_REGS-1:0]               pidr4_rd_data;
  reg  [L_SIZE_REGS-1:0]               pidr0_rd_data;
  reg  [L_SIZE_REGS-1:0]               pidr1_rd_data;
  reg  [L_SIZE_REGS-1:0]               pidr2_rd_data;
  reg  [L_SIZE_REGS-1:0]               pidr3_rd_data;
  reg  [L_SIZE_REGS-1:0]               cidr0_rd_data;
  reg  [L_SIZE_REGS-1:0]               cidr1_rd_data;
  reg  [L_SIZE_REGS-1:0]               cidr2_rd_data;
  reg  [L_SIZE_REGS-1:0]               cidr3_rd_data;

  reg                              control_q;
  wire                             control;
  reg                              mode_q;
  reg  [3:0]                       axictrl_arcache_q;
  wire [3:0]                       axictrl_arcache;
  reg  [1:0]                       axictrl_arprot_q;
  reg                              irqen_q;
  reg  [L_SLADDR_WIDTH-1:0]        sladdrlo_q;
  reg  [L_INADDR_WIDTH-1:0]        inaddrlo_q;
  reg                              itctrl_q;
  reg  [3:0]                       claim_tag_q;
  wire [3:0]                       claim_tag;

  reg                              ready_q;
  reg                              irq_q;
  wire                             irq;
  reg                              axierr_q;
  wire                             axierr;
  reg                              addrerr_q;
  wire                             addrerr;
  reg                              ctrl_enable_q;
  wire                             ctrl_enable_rise;
  wire                             ctrl_enable_fall;


  assign control_sel       = (reg_addr[11:2] == REG_CONTROL_ADDR);
  assign control_wr_en     = reg_write & control_sel;
  assign control_rd_en     = reg_read & control_sel;

  assign control = ( reg_wdata[REG_CONTROL_ENABLE_MSB : REG_CONTROL_ENABLE_LSB] && ~ready_q ) ?
                     control_q                                                                :
                     reg_wdata[REG_CONTROL_ENABLE_MSB : REG_CONTROL_ENABLE_LSB];
  always @(posedge clk or negedge reset_n)
  begin : reg_control
    if (!reset_n)
      control_q <= REG_CONTROL_ENABLE_INIT;
    else if (control_wr_en)
      control_q <= control;
  end

  always @*
  begin : comb_control_rddata
    control_rd_data = {L_SIZE_REGS{1'b0}};
    control_rd_data[REG_CONTROL_ENABLE_MSB : REG_CONTROL_ENABLE_LSB] = control_q;
  end

  assign ctrl_enable = ctrl_enable_q;

  assign mode_sel       = (reg_addr[11:2] == REG_MODE_ADDR);
  assign mode_wr_en     = reg_write & mode_sel & ready_q & ~ctrl_enable;
  assign mode_rd_en     = reg_read & mode_sel;

  always @(posedge clk)
  begin : reg_mode
    if (mode_wr_en)
      mode_q <= reg_wdata[REG_MODE_MODE_MSB : REG_MODE_MODE_LSB];
  end

  always @*
  begin : comb_mode_rddata
    mode_rd_data = {L_SIZE_REGS{1'b0}};
    mode_rd_data[REG_MODE_MODE_MSB : REG_MODE_MODE_LSB] = mode_q;
  end

  assign ctrl_mode = mode_q;

  assign axictrl_sel       = (reg_addr[11:2] == REG_AXICTRL_ADDR);
  assign axictrl_wr_en     = reg_write & axictrl_sel & ready_q & ~ctrl_enable;
  assign axictrl_rd_en     = reg_read & axictrl_sel;

  assign axictrl_arcache = ( (reg_wdata[REG_AXICTRL_ARCACHE_MSB:REG_AXICTRL_ARCACHE_LSB+2] == 2'b00)
                            || reg_wdata[REG_AXICTRL_ARCACHE_LSB+1] ) ?
                           reg_wdata[REG_AXICTRL_ARCACHE_MSB:REG_AXICTRL_ARCACHE_LSB]                                                          :
                           REG_AXICTRL_ARCACHE_INIT;
  always @(posedge clk)
  begin : reg_axictrl
    if (axictrl_wr_en) begin
      axictrl_arcache_q <= axictrl_arcache;
      axictrl_arprot_q  <= reg_wdata[ REG_AXICTRL_ARPROT_MSB : REG_AXICTRL_ARPROT_LSB ];
    end
  end

  always @*
  begin : comb_axictrl_rddata
    axictrl_rd_data = {L_SIZE_REGS{1'b0}};
    axictrl_rd_data[ REG_AXICTRL_ARCACHE_MSB : REG_AXICTRL_ARCACHE_LSB ] = axictrl_arcache_q;
    axictrl_rd_data[ REG_AXICTRL_ARPROT_MSB  : REG_AXICTRL_ARPROT_LSB  ] = axictrl_arprot_q;
  end

  assign ctrl_arcache = axictrl_arcache_q;
  assign ctrl_arprot  = axictrl_arprot_q;

  assign irqen_sel       = (reg_addr[11:2] == REG_IRQEN_ADDR);
  assign irqen_wr_en     = reg_write & irqen_sel & ready_q & ~ctrl_enable;
  assign irqen_rd_en     = reg_read & irqen_sel;

  always @(posedge clk)
  begin : reg_irqen
    if (irqen_wr_en)
      irqen_q <= reg_wdata[REG_IRQEN_IRQEN_MSB : REG_IRQEN_IRQEN_LSB];
  end

  always @*
  begin : comb_irqen_rddata
    irqen_rd_data = {L_SIZE_REGS{1'b0}};
    irqen_rd_data[REG_IRQEN_IRQEN_MSB : REG_IRQEN_IRQEN_LSB] = irqen_q;
  end

  assign sladdrlo_sel       = (reg_addr[11:2] == REG_SLADDRLO_ADDR);
  assign sladdrlo_wr_en     = reg_write & sladdrlo_sel & ready_q & ~ctrl_enable;
  assign sladdrlo_rd_en     = reg_read & sladdrlo_sel;

  always @(posedge clk)
  begin : reg_sladdrlo
    if (sladdrlo_wr_en)
    begin
      sladdrlo_q <= reg_wdata[REG_SLADDRLO_SLADDRLO_MSB : REG_SLADDRLO_SLADDRLO_LSB];
    end
  end

  always @*
  begin : comb_sladdrlo_rddata
    sladdrlo_rd_data = {L_SIZE_REGS{1'b0}};
    sladdrlo_rd_data[REG_SLADDRLO_SLADDRLO_MSB : REG_SLADDRLO_SLADDRLO_LSB] = sladdrlo_q;
  end

  generate
    if ( AXI_ADDR_WIDTH > 32 )
    begin : sladdr_reg_extension
      wire                   sladdrhi_wr_en;
      wire                   sladdrhi_sel;
      reg  [L_ADDRHI:0]      sladdrhi_q;
      reg  [L_SIZE_REGS-1:0] sladdrhi_rd_data_int;


      assign sladdrhi_sel       = (reg_addr[11:2] == REG_SLADDRHI_ADDR);
      assign sladdrhi_wr_en     = reg_write & sladdrhi_sel & ready_q & ~ctrl_enable;
      assign sladdrhi_rd_en     = reg_read & sladdrhi_sel;

      always @(posedge clk)
      begin : reg_sladdrhi
        if (sladdrhi_wr_en)
        begin
          sladdrhi_q <= reg_wdata[L_ADDRHI : REG_SLADDRHI_SLADDRHI_LSB];
        end
      end

      always @*
      begin : comb_sladdrhi_rddata
        sladdrhi_rd_data_int = {L_SIZE_REGS{1'b0}};
        sladdrhi_rd_data_int[L_ADDRHI : REG_SLADDRHI_SLADDRHI_LSB] = sladdrhi_q;
      end
      assign sladdrhi_rd_data = sladdrhi_rd_data_int;

      assign ctrl_sladdr = {sladdrhi_q, sladdrlo_rd_data};

    end
    else
    begin : no_sladdr_reg_extension
      assign sladdrhi_rd_en      = 1'b0;
      assign sladdrhi_rd_data    = {L_SIZE_REGS{1'b0}};
      assign ctrl_sladdr         = sladdrlo_rd_data;
    end
  endgenerate


  assign inaddrlo_sel       = (reg_addr[11:2] == REG_INADDRLO_ADDR);
  assign inaddrlo_wr_en     = reg_write & inaddrlo_sel & ready_q & ~ctrl_enable;
  assign inaddrlo_rd_en     = reg_read & inaddrlo_sel;

  always @(posedge clk)
  begin : reg_inaddrlo
    if (inaddrlo_wr_en)
    begin
      inaddrlo_q <= reg_wdata[REG_INADDRLO_INADDRLO_MSB : REG_INADDRLO_INADDRLO_LSB];
    end
  end

  always @*
  begin : comb_inaddrlo_rddata
    inaddrlo_rd_data = {L_SIZE_REGS{1'b0}};
    inaddrlo_rd_data[REG_INADDRLO_INADDRLO_MSB : REG_INADDRLO_INADDRLO_LSB] = inaddrlo_q;
  end

  generate
    if ( AXI_ADDR_WIDTH > 32 )
    begin : inaddr_reg_extension
      wire inaddrhi_wr_en;
      reg  [L_SIZE_REGS-1:0] inaddrhi_rd_data_int;
      reg  [L_ADDRHI:0]      inaddrhi_q;

      assign inaddrhi_sel       = (reg_addr[11:2] == REG_INADDRHI_ADDR);
      assign inaddrhi_wr_en     = reg_write & inaddrhi_sel & ready_q & ~ctrl_enable;
      assign inaddrhi_rd_en     = reg_read & inaddrhi_sel;

      always @(posedge clk)
      begin : reg_inaddrhi
        if (inaddrhi_wr_en)
        begin
          inaddrhi_q <= reg_wdata[L_ADDRHI : REG_INADDRHI_INADDRHI_LSB];
        end
      end

      always @*
      begin : comb_inaddrhi_rddata
        inaddrhi_rd_data_int = {L_SIZE_REGS{1'b0}};
        inaddrhi_rd_data_int[L_ADDRHI : REG_INADDRHI_INADDRHI_LSB] = inaddrhi_q;
      end
      assign inaddrhi_rd_data = inaddrhi_rd_data_int;

      assign ctrl_inaddr = {inaddrhi_q, inaddrlo_rd_data};

    end
    else
    begin : no_inaddr_reg_extension
      assign inaddrhi_rd_en     = 1'b0;
      assign ctrl_inaddr        = inaddrlo_rd_data;
      assign inaddrhi_rd_data   = {L_SIZE_REGS{1'b0}};

    end
  endgenerate


  assign status_sel      = (reg_addr[11:2] == REG_STATUS_ADDR);
  assign status_rd_en    = reg_read & status_sel;

  always @*
  begin : comb_status_rddata
    status_rd_data = {L_SIZE_REGS{1'b0}};
    status_rd_data[ REG_STATUS_READY_MSB     : REG_STATUS_READY_LSB   ] = ready_q;
    status_rd_data[ REG_STATUS_AXIERR_MSB    : REG_STATUS_AXIERR_LSB  ] = axierr_q;
    status_rd_data[ REG_STATUS_ADDRERR_MSB   : REG_STATUS_ADDRERR_LSB ] = addrerr_q;
  end


  assign itirq_sel       = (reg_addr[11:2] == REG_ITIRQ_ADDR);
  assign itirq_wr_en     = reg_write & itirq_sel & it_en;

  assign itctrl_sel       = (reg_addr[11:2] == REG_ITCTRL_ADDR);
  assign itctrl_wr_en     = reg_write & itctrl_sel;
  assign itctrl_rd_en     = reg_read & itctrl_sel;

  always @(posedge clk or negedge reset_n)
  begin : reg_itctrl
    if (!reset_n)
      itctrl_q <= REG_ITCTRL_IME_INIT;
    else if (itctrl_wr_en)
      itctrl_q <= reg_wdata[REG_ITCTRL_IME_MSB : REG_ITCTRL_IME_LSB];
  end

  always @*
  begin : comb_itctrl_rddata
    itctrl_rd_data = {L_SIZE_REGS{1'b0}};
    itctrl_rd_data[REG_ITCTRL_IME_MSB : REG_ITCTRL_IME_LSB] = itctrl_q;
  end

  assign it_en = itctrl_q;


  assign claimset_sel       = (reg_addr[11:2] == REG_CLAIMSET_ADDR);
  assign claimset_wr_en     = reg_write & claimset_sel;
  assign claimset_rd_en     = reg_read & claimset_sel;
  wire [REG_CLAIMSET_SET_MSB-REG_CLAIMSET_SET_LSB:0] claimset_set_init = REG_CLAIMSET_SET_INIT;
  always @*
  begin : comb_claimset_rddata
    claimset_rd_data = {L_SIZE_REGS{1'b0}};
    claimset_rd_data[REG_CLAIMSET_SET_MSB : REG_CLAIMSET_SET_LSB] = claimset_set_init;
  end

  assign claimclr_sel     = (reg_addr[11:2] == REG_CLAIMCLR_ADDR);
  assign claimclr_wr_en   = reg_write & claimclr_sel;
  assign claimclr_rd_en   = reg_read & claimclr_sel;
  always @*
  begin : comb_claimclr_rddata
    claimclr_rd_data = {L_SIZE_REGS{1'b0}};
    claimclr_rd_data[REG_CLAIMSET_CLR_MSB : REG_CLAIMSET_CLR_LSB] = claim_tag_q;
  end

  assign claim_tag = claimset_sel ? ( claim_tag_q |  reg_wdata[3:0])  :
                                    ( claim_tag_q & ~reg_wdata[3:0]);

  always @(posedge clk or negedge reset_n)
  begin : reg_claim_tag
    if (!reset_n)
       claim_tag_q <= REG_CLAIMSET_CLR_INIT;
    else if (claimset_wr_en || claimclr_wr_en)
       claim_tag_q <= claim_tag;
  end


  assign authstatus_sel       = (reg_addr[11:2] == REG_AUTHSTATUS_ADDR);
  assign authstatus_rd_en     = reg_read & authstatus_sel;

  always @*
  begin : comb_authstatus_rddata
    authstatus_rd_data = {L_SIZE_REGS{1'b0}};
    authstatus_rd_data[ REG_AUTHSTATUS_HNID_MSB  : REG_AUTHSTATUS_HNID_LSB  ] = REG_AUTHSTATUS_HNID_INIT;
    authstatus_rd_data[ REG_AUTHSTATUS_HID_MSB   : REG_AUTHSTATUS_HID_LSB   ] = REG_AUTHSTATUS_HID_INIT;
    authstatus_rd_data[ REG_AUTHSTATUS_SNID_MSB  : REG_AUTHSTATUS_SNID_LSB  ] = REG_AUTHSTATUS_SNID_INIT;
    authstatus_rd_data[ REG_AUTHSTATUS_SID_MSB   : REG_AUTHSTATUS_SID_LSB   ] = { REG_AUTHSTATUS_SID_INIT, status_spiden & status_dbgen };
    authstatus_rd_data[ REG_AUTHSTATUS_NSNID_MSB : REG_AUTHSTATUS_NSNID_LSB ] = REG_AUTHSTATUS_NSNID_INIT;
    authstatus_rd_data[ REG_AUTHSTATUS_NSID_MSB  : REG_AUTHSTATUS_NSID_LSB  ] = { REG_AUTHSTATUS_NSID_INIT, status_dbgen };
  end

  assign devarch_sel       = (reg_addr[11:2] == REG_DEVARCH_ADDR);
  assign devarch_rd_en     = reg_read & devarch_sel;

  wire [REG_DEVARCH_ARCHITECT_MSB-REG_DEVARCH_ARCHITECT_LSB:0] devarch_architect_init = REG_DEVARCH_ARCHITECT_INIT;
  wire [REG_DEVARCH_PRESENT_MSB-REG_DEVARCH_PRESENT_LSB:0]     devarch_present_init   = REG_DEVARCH_PRESENT_INIT;
  wire [REG_DEVARCH_REVISION_MSB-REG_DEVARCH_REVISION_LSB:0]   devarch_revision_init  = REG_DEVARCH_REVISION_INIT;
  wire [REG_DEVARCH_ARCHID_MSB-REG_DEVARCH_ARCHID_LSB:0]       devarch_archid_init    = REG_DEVARCH_ARCHID_INIT;
  always @*
  begin : comb_devarch_rddata
    devarch_rd_data = {L_SIZE_REGS{1'b0}};
    devarch_rd_data[ REG_DEVARCH_ARCHITECT_MSB : REG_DEVARCH_ARCHITECT_LSB ] = devarch_architect_init;
    devarch_rd_data[ REG_DEVARCH_PRESENT_MSB   : REG_DEVARCH_PRESENT_LSB   ] = devarch_present_init;
    devarch_rd_data[ REG_DEVARCH_REVISION_MSB  : REG_DEVARCH_REVISION_LSB  ] = devarch_revision_init;
    devarch_rd_data[ REG_DEVARCH_ARCHID_MSB    : REG_DEVARCH_ARCHID_LSB    ] = devarch_archid_init;
  end


  assign devid_sel       = (reg_addr[11:2] == REG_DEVID_ADDR);
  assign devid_rd_en     = reg_read & devid_sel;

  wire [REG_DEVID_AXIDW_MSB-REG_DEVID_AXIDW_LSB:0] devid_axidw_init = L_AXIDW;
  wire [REG_DEVID_AXIAW_MSB-REG_DEVID_AXIAW_LSB:0] devid_axiaw_init = L_AXIAW;
  always @*
  begin : comb_devid_rddata
    devid_rd_data = {L_SIZE_REGS{1'b0}};
    devid_rd_data[ REG_DEVID_AXIDW_MSB : REG_DEVID_AXIDW_LSB ] = devid_axidw_init;
    devid_rd_data[ REG_DEVID_AXIAW_MSB : REG_DEVID_AXIAW_LSB ] = devid_axiaw_init;
  end

  assign devtype_sel       = (reg_addr[11:2] == REG_DEVTYPE_ADDR);
  assign devtype_rd_en     = reg_read & devtype_sel;

  wire [REG_DEVTYPE_SUB_MSB-REG_DEVTYPE_SUB_LSB:0]     devtype_sub_init   = REG_DEVTYPE_SUB_INIT;
  wire [REG_DEVTYPE_MAJOR_MSB-REG_DEVTYPE_MAJOR_LSB:0] devtype_major_init = REG_DEVTYPE_MAJOR_INIT;
  always @*
  begin : comb_devtype_rddata
    devtype_rd_data = {L_SIZE_REGS{1'b0}};
    devtype_rd_data[ REG_DEVTYPE_SUB_MSB   : REG_DEVTYPE_SUB_LSB   ] = devtype_sub_init;
    devtype_rd_data[ REG_DEVTYPE_MAJOR_MSB : REG_DEVTYPE_MAJOR_LSB ] = devtype_major_init;
  end

  assign pidr4_sel       = (reg_addr[11:2] == REG_PIDR4_ADDR);
  assign pidr4_rd_en     = reg_read & pidr4_sel;

  wire [REG_PIDR4_SIZE_MSB-REG_PIDR4_SIZE_LSB:0] pidr4_size_init = REG_PIDR4_SIZE_INIT;
  wire [REG_PIDR4_DES2_MSB-REG_PIDR4_DES2_LSB:0] pidr4_des2_init = REG_PIDR4_DES2_INIT;
  always @*
  begin : comb_pidr4_rddata
    pidr4_rd_data = {L_SIZE_REGS{1'b0}};
    pidr4_rd_data[ REG_PIDR4_SIZE_MSB : REG_PIDR4_SIZE_LSB ] = pidr4_size_init;
    pidr4_rd_data[ REG_PIDR4_DES2_MSB : REG_PIDR4_DES2_LSB ] = pidr4_des2_init;
  end


  assign pidr0_sel       = (reg_addr[11:2] == REG_PIDR0_ADDR);
  assign pidr0_rd_en     = reg_read & pidr0_sel;

  wire [REG_PIDR0_PART0_MSB-REG_PIDR0_PART0_LSB:0] pidr0_part0_init = REG_PIDR0_PART0_INIT;
  always @*
  begin : comb_pidr0_rddata
    pidr0_rd_data = {L_SIZE_REGS{1'b0}};
    pidr0_rd_data[ REG_PIDR0_PART0_MSB : REG_PIDR0_PART0_LSB ] = pidr0_part0_init;
  end

  assign pidr1_sel       = (reg_addr[11:2] == REG_PIDR1_ADDR);
  assign pidr1_rd_en     = reg_read & pidr1_sel;

  wire [REG_PIDR1_DES0_MSB-REG_PIDR1_DES0_LSB:0]   pidr1_des0_init  = REG_PIDR1_DES0_INIT;
  wire [REG_PIDR1_PART1_MSB-REG_PIDR1_PART1_LSB:0] pidr1_part1_init = REG_PIDR1_PART1_INIT;
  always @*
  begin : comb_pidr1_rddata
    pidr1_rd_data = {L_SIZE_REGS{1'b0}};
    pidr1_rd_data[ REG_PIDR1_DES0_MSB  : REG_PIDR1_DES0_LSB  ] = pidr1_des0_init;
    pidr1_rd_data[ REG_PIDR1_PART1_MSB : REG_PIDR1_PART1_LSB ] = pidr1_part1_init;
  end

  assign pidr2_sel       = (reg_addr[11:2] == REG_PIDR2_ADDR);
  assign pidr2_rd_en     = reg_read & pidr2_sel;

  wire [REG_PIDR2_REVISION_MSB-REG_PIDR2_REVISION_LSB:0] pidr2_revision_init = REG_PIDR2_REVISION_INIT;
  wire [REG_PIDR2_JEDEC_MSB-REG_PIDR2_JEDEC_LSB:0]       pidr2_jedec_init    = REG_PIDR2_JEDEC_INIT;
  wire [REG_PIDR2_DES1_MSB-REG_PIDR2_DES1_LSB:0]         pidr2_des1_init     = REG_PIDR2_DES1_INIT;
  always @*
  begin : comb_pidr2_rddata
    pidr2_rd_data = {L_SIZE_REGS{1'b0}};
    pidr2_rd_data[ REG_PIDR2_REVISION_MSB : REG_PIDR2_REVISION_LSB ] = pidr2_revision_init;
    pidr2_rd_data[ REG_PIDR2_JEDEC_MSB    : REG_PIDR2_JEDEC_LSB    ] = pidr2_jedec_init;
    pidr2_rd_data[ REG_PIDR2_DES1_MSB     : REG_PIDR2_DES1_LSB     ] = pidr2_des1_init;
  end

  assign pidr3_sel       = (reg_addr[11:2] == REG_PIDR3_ADDR);
  assign pidr3_rd_en     = reg_read & pidr3_sel;

  wire [REG_PIDR3_CMOD_MSB-REG_PIDR3_CMOD_LSB:0]     pidr3_cmod_init   = REG_PIDR3_CMOD_INIT;
  always @*
  begin : comb_pidr3_rddata
    pidr3_rd_data = {L_SIZE_REGS{1'b0}};
    pidr3_rd_data[ REG_PIDR3_REVAND_MSB : REG_PIDR3_REVAND_LSB ] = revand;
    pidr3_rd_data[ REG_PIDR3_CMOD_MSB   : REG_PIDR3_CMOD_LSB   ] = pidr3_cmod_init;
  end

  assign cidr0_sel       = (reg_addr[11:2] == REG_CIDR0_ADDR);
  assign cidr0_rd_en     = reg_read & cidr0_sel;

  wire [REG_CIDR0_PRMBL_0_MSB-REG_CIDR0_PRMBL_0_LSB:0] cidr0_prmbl_0_init = REG_CIDR0_PRMBL_0_INIT;
  always @*
  begin : comb_cidr0_rddata
    cidr0_rd_data = {L_SIZE_REGS{1'b0}};
    cidr0_rd_data[ REG_CIDR0_PRMBL_0_MSB : REG_CIDR0_PRMBL_0_LSB ] = cidr0_prmbl_0_init;
  end

  assign cidr1_sel       = (reg_addr[11:2] == REG_CIDR1_ADDR);
  assign cidr1_rd_en     = reg_read & cidr1_sel;

  wire [REG_CIDR1_CLASS_MSB-REG_CIDR1_CLASS_LSB:0]     cidr1_class_init   = REG_CIDR1_CLASS_INIT;
  wire [REG_CIDR1_PRMBL_1_MSB-REG_CIDR1_PRMBL_1_LSB:0] cidr1_prmbl_1_init = REG_CIDR1_PRMBL_1_INIT;
  always @*
  begin : comb_cidr1_rddata
    cidr1_rd_data = {L_SIZE_REGS{1'b0}};
    cidr1_rd_data[ REG_CIDR1_CLASS_MSB   : REG_CIDR1_CLASS_LSB   ] = cidr1_class_init;
    cidr1_rd_data[ REG_CIDR1_PRMBL_1_MSB : REG_CIDR1_PRMBL_1_LSB ] = cidr1_prmbl_1_init;
  end

  assign cidr2_sel       = (reg_addr[11:2] == REG_CIDR2_ADDR);
  assign cidr2_rd_en     = reg_read & cidr2_sel;

  wire [REG_CIDR2_PRMBL_2_MSB-REG_CIDR2_PRMBL_2_LSB:0] cidr2_prmbl_2_init = REG_CIDR2_PRMBL_2_INIT;
  always @*
  begin : comb_cidr2_rddata
    cidr2_rd_data = {L_SIZE_REGS{1'b0}};
    cidr2_rd_data[ REG_CIDR2_PRMBL_2_MSB : REG_CIDR2_PRMBL_2_LSB ] = cidr2_prmbl_2_init;
  end

  assign cidr3_sel       = (reg_addr[11:2] == REG_CIDR3_ADDR);
  assign cidr3_rd_en     = reg_read & cidr3_sel;

  wire [REG_CIDR3_PRMBL_3_MSB-REG_CIDR3_PRMBL_3_LSB:0] cidr3_prmbl_3_init = REG_CIDR3_PRMBL_3_INIT;
  always @*
  begin : comb_cidr3_rddata
    cidr3_rd_data = {L_SIZE_REGS{1'b0}};
    cidr3_rd_data[ REG_CIDR3_PRMBL_3_MSB : REG_CIDR3_PRMBL_3_LSB ] = cidr3_prmbl_3_init;
  end


  always @(posedge clk or negedge reset_n)
  begin : reg_it_addrerr
    if (!reset_n)
      it_addrerr <= 1'b0;
    else if (itirq_wr_en)
      it_addrerr <= reg_wdata[REG_ITIRQ_ADDRERR_MSB:REG_ITIRQ_ADDRERR_LSB];
  end


  assign irq = ctrl_enable_fall ? 1'b0 : (status_addrerr | axierr);
  assign irq_wr_en = (ctrl_enable & irqen_q & (status_addrerr | axierr))
                   | ctrl_enable_fall;

  always @(posedge clk or negedge reset_n)
  begin : reg_irq
    if (!reset_n)
      irq_q <= 1'b0;
    else if (irq_wr_en)
      irq_q <= irq;
  end

  assign ctrl_addrerr = it_en ? it_addrerr : irq_q;

  assign axierr_wr_en = status_axi_resperr | status_axi_autherr | ctrl_enable_rise;

  assign axierr = ctrl_enable_rise ? 1'b0 : status_axi_resperr | status_axi_autherr;

  always @(posedge clk or negedge reset_n)
  begin : reg_axierr
    if (!reset_n)
      axierr_q <= 1'b0;
    else if (axierr_wr_en)
      axierr_q <= axierr;
  end

  assign addrerr_wr_en = (ctrl_enable & status_addrerr) | ctrl_enable_rise;

  assign addrerr = ctrl_enable_rise ? 1'b0 : status_addrerr;

  always @(posedge clk or negedge reset_n)
  begin : reg_addrerr
    if (!reset_n)
      addrerr_q <= 1'b0;
    else if (addrerr_wr_en)
      addrerr_q <= addrerr;
  end

  always @(posedge clk)
  begin : reg_ready
      ready_q <= ~status_axislv_busy &
                  ~status_slw_busy;
  end

  always @(posedge clk or negedge reset_n)
    begin : reg_ctrl_enable
      if (!reset_n)
        ctrl_enable_q <= REG_CONTROL_ENABLE_INIT;
      else
        ctrl_enable_q <= control_q;
    end

  assign ctrl_enable_rise = ~ctrl_enable_q & control_q;
  assign ctrl_enable_fall = ctrl_enable_q & ~control_q;
  assign clr_tlbs = ctrl_enable_rise;


  assign rddata_sel    = {
                           control_rd_en,
                           mode_rd_en,
                           axictrl_rd_en,
                           irqen_rd_en,
                           sladdrlo_rd_en,
                           sladdrhi_rd_en,
                           inaddrlo_rd_en,
                           inaddrhi_rd_en,
                           status_rd_en,
                           itctrl_rd_en,
                           claimset_rd_en,
                           claimclr_rd_en,
                           authstatus_rd_en,
                           devarch_rd_en,
                           devid_rd_en,
                           devtype_rd_en,
                           pidr4_rd_en,
                           pidr0_rd_en,
                           pidr1_rd_en,
                           pidr2_rd_en,
                           pidr3_rd_en,
                           cidr0_rd_en,
                           cidr1_rd_en,
                           cidr2_rd_en,
                           cidr3_rd_en
                         };

  assign rddata_array  = {
                           control_rd_data,
                           mode_rd_data,
                           axictrl_rd_data,
                           irqen_rd_data,
                           sladdrlo_rd_data,
                           sladdrhi_rd_data,
                           inaddrlo_rd_data,
                           inaddrhi_rd_data,
                           status_rd_data,
                           itctrl_rd_data,
                           claimset_rd_data,
                           claimclr_rd_data,
                           authstatus_rd_data,
                           devarch_rd_data,
                           devid_rd_data,
                           devtype_rd_data,
                           pidr4_rd_data,
                           pidr0_rd_data,
                           pidr1_rd_data,
                           pidr2_rd_data,
                           pidr3_rd_data,
                           cidr0_rd_data,
                           cidr1_rd_data,
                           cidr2_rd_data,
                           cidr3_rd_data
                         };

  css600_one_hot_mux
  #(
    .SEL_WIDTH   ( L_NUM_REGS  ),
    .DATA_WIDTH  ( L_SIZE_REGS )
  )
  u_rdata_mux
  (
    .inp_sel     ( rddata_sel   ),
    .inp_data    ( rddata_array ),
    .out_data    ( reg_rdata    )
  );


endmodule

