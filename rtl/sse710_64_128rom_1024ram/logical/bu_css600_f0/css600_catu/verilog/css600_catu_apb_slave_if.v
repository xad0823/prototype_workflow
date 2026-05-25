//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017 Arm Limited or its affiliates.
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


module css600_catu_apb_slave_if
#(
  parameter APB_ADDR_WIDTH = 12,
  parameter APB_DATA_WIDTH = 32
)(
  input  wire                       clk,
  input  wire                       reset_n,
  input  wire                       dev_run,
  input  wire                       apbslv_if_psel,
  input  wire                       apbslv_if_penable,
  input  wire                       apbslv_if_pwrite,
  input  wire [APB_ADDR_WIDTH-1:0]  apbslv_if_paddr,
  input  wire [APB_DATA_WIDTH-1:0]  apbslv_if_pwdata,
  output wire [APB_DATA_WIDTH-1:0]  apbslv_if_prdata,
  output wire                       apbslv_if_pready,
  output wire                       apbslv_if_pslverr,
  input  wire [APB_DATA_WIDTH-1:0]  reg_rdata,
  output wire                       reg_write,
  output wire                       reg_read,
  output wire [APB_ADDR_WIDTH-1:0]  reg_addr,
  output wire [APB_DATA_WIDTH-1:0]  reg_wdata
);

  wire                         apb_valid;
  wire                         pready;
  wire [APB_DATA_WIDTH-1:0]    prdata;

  reg                          dev_run_q;
  reg                          apb_valid_q;
  reg  [APB_DATA_WIDTH-1:0]    prdata_q;
  reg                          pready_q;


  assign prdata[APB_DATA_WIDTH-1:0] = (!apbslv_if_pwrite && apb_valid)
                                    ? reg_rdata[APB_DATA_WIDTH-1:0]
                                    : prdata_q;

  always @(posedge clk or negedge reset_n)
  begin : reg_prdata
    if (!reset_n)
      prdata_q <= {APB_DATA_WIDTH{1'b0}};
    else if (apb_valid==1'b1)
      prdata_q <= prdata;
  end

  assign apb_valid = (apbslv_if_psel & ~(apbslv_if_penable & dev_run_q) & dev_run);

  always @(posedge clk or negedge reset_n)
  begin : reg_valid
    if (!reset_n)
     begin
      apb_valid_q <= 1'b0;
      dev_run_q <= 1'b0;
     end
    else if (apbslv_if_psel==1'b1)
     begin
      apb_valid_q <= apb_valid;
      dev_run_q <= dev_run;
     end
  end

  assign pready = (!apbslv_if_psel) ? 1'b0 : apb_valid;

  always @(posedge clk or negedge reset_n)
  begin : reg_pready
    if (!reset_n)
      pready_q <= 1'b0;
    else if (apbslv_if_psel==1'b1)
      pready_q <= pready;
  end

  assign reg_write = apbslv_if_pwrite & (apb_valid & ~apb_valid_q);
  assign reg_read  = ~apbslv_if_pwrite & apb_valid;
  assign reg_wdata = apbslv_if_pwdata;
  assign reg_addr  = apbslv_if_paddr & {12{apbslv_if_psel}};

  assign apbslv_if_prdata  = prdata_q;
  assign apbslv_if_pready  = pready_q;
  assign apbslv_if_pslverr = 1'b0;


endmodule

