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



module firewall_f0_bas_reg_slice
  (
    aresetn,
    aclk,

    tvalid_dti_dn_s,
    tready_dti_dn_s,
    tdata_dti_dn_s,
    tkeep_dti_dn_s,
    tid_dti_dn_s,
    tlast_dti_dn_s,
    tvalid_dti_up_s,
    tready_dti_up_s,
    tdata_dti_up_s,
    tkeep_dti_up_s,
    tdest_dti_up_s,
    tlast_dti_up_s,

    tvalid_dti_dn_m,
    tready_dti_dn_m,
    tdata_dti_dn_m,
    tkeep_dti_dn_m,
    tid_dti_dn_m,
    tlast_dti_dn_m,
    tvalid_dti_up_m,
    tready_dti_up_m,
    tdata_dti_up_m,
    tkeep_dti_up_m,
    tdest_dti_up_m,
    tlast_dti_up_m,

    twakeup_dti_dn_s,
    twakeup_dti_up_s,
    twakeup_dti_dn_m,
    twakeup_dti_up_m,

    qactive_cg,

    bas_gate
   );

`include "firewall_f0_reg_slice_localparams.v"

  parameter DATA_WIDTH = 160;           
  parameter ID_WIDTH = 6;               
  parameter MODE = RS_REGD;             

  localparam DATA_MSB    = (DATA_WIDTH - 1);
  localparam ID_MSB      = ID_WIDTH ? (ID_WIDTH - 1) : 0;
  localparam TKEEP_WIDTH = (DATA_WIDTH / 8);
  localparam TKEEP_MSB   = TKEEP_WIDTH - 1;
  localparam PAYLD_WIDTH = (ID_WIDTH + DATA_WIDTH + TKEEP_WIDTH + 1);
  localparam PAYLD_MSB   = (PAYLD_WIDTH - 1);

  localparam Q_SYNC_EN = 0;

  input   wire                        aresetn;
  input   wire                        aclk;

  input   wire                        tvalid_dti_dn_s;
  output  wire                        tready_dti_dn_s;
  input   wire [DATA_MSB:0]           tdata_dti_dn_s;
  input   wire [TKEEP_MSB:0]          tkeep_dti_dn_s;
  input   wire [ID_MSB:0]             tid_dti_dn_s;
  input   wire                        tlast_dti_dn_s;

  output  wire                        tvalid_dti_up_s;
  input   wire                        tready_dti_up_s;
  output  wire [DATA_MSB:0]           tdata_dti_up_s;
  output  wire [TKEEP_MSB:0]          tkeep_dti_up_s;
  output  wire [ID_MSB:0]             tdest_dti_up_s;
  output  wire                        tlast_dti_up_s;

  input   wire                        tvalid_dti_up_m;
  output  wire                        tready_dti_up_m;
  input   wire [DATA_MSB:0]           tdata_dti_up_m;
  input   wire [TKEEP_MSB:0]          tkeep_dti_up_m;
  input   wire [ID_MSB:0]             tdest_dti_up_m;
  input   wire                        tlast_dti_up_m;

  output  wire                        tvalid_dti_dn_m;
  input   wire                        tready_dti_dn_m;
  output  wire [DATA_MSB:0]           tdata_dti_dn_m;
  output  wire [TKEEP_MSB:0]          tkeep_dti_dn_m;
  output  wire [ID_MSB:0]             tid_dti_dn_m;
  output  wire                        tlast_dti_dn_m;

  input   wire                        twakeup_dti_dn_s;
  output  wire                        twakeup_dti_up_s;
  input   wire                        twakeup_dti_up_m;
  output  wire                        twakeup_dti_dn_m;

  output  wire                        qactive_cg;

  input   wire                        bas_gate;



  wire [PAYLD_MSB:0]                  tpayld_dti_dn_s;    
  wire [PAYLD_MSB:0]                  tpayld_dti_up_m;    
  wire [PAYLD_MSB:0]                  tpayld_dti_dn_m;    
  wire [PAYLD_MSB:0]                  tpayld_dti_up_s;    
  wire                                ivalid_dti_dn_s;    
  wire                                iready_dti_dn_s;    
  wire                                ivalid_dti_dn_m;    
  wire                                iready_dti_dn_m;    
  wire                                ivalid_dti_up_s;    
  wire                                iready_dti_up_s;    
  wire                                ivalid_dti_up_m;    
  wire                                iready_dti_up_m;    
  wire                                gate_dti;           

  wire                                qbusy_wakeup;       
  wire                                qbusy_valid;        
  wire                                qbusy_cg;           

  wire                                reg_busy_dn;
  wire                                reg_busy_up;

  reg                                 twakeup_dti_up;
  reg                                 twakeup_dti_dn;


  generate
    if (ID_WIDTH == 0)
    begin : g_id_tieoff
      assign {tdata_dti_dn_m,
              tkeep_dti_dn_m,
              tlast_dti_dn_m} = tpayld_dti_dn_m;

      assign {tdata_dti_up_s,
              tkeep_dti_up_s,
              tlast_dti_up_s} = tpayld_dti_up_s;


      assign tpayld_dti_dn_s = {tdata_dti_dn_s,
                                tkeep_dti_dn_s,
                                tlast_dti_dn_s};

      assign tpayld_dti_up_m = {tdata_dti_up_m,
                                tkeep_dti_up_m,
                                tlast_dti_up_m};

      assign tid_dti_dn_m = 1'b0;
      assign tdest_dti_up_s = 1'b0;

      wire [ID_MSB:0] unused_tid_dti_dn_s;
      wire [ID_MSB:0] unused_tdest_dti_up_m;

      assign unused_tid_dti_dn_s   = tid_dti_dn_s;
      assign unused_tdest_dti_up_m = tdest_dti_up_m;

    end
    else
    begin : g_tpayload
      assign tpayld_dti_dn_s = {tdata_dti_dn_s,
                                tkeep_dti_dn_s,
                                tid_dti_dn_s,
                                tlast_dti_dn_s};

      assign tpayld_dti_up_m = {tdata_dti_up_m,
                                tkeep_dti_up_m,
                                tdest_dti_up_m,
                                tlast_dti_up_m};

      assign {tdata_dti_dn_m,
              tkeep_dti_dn_m,
              tid_dti_dn_m,
              tlast_dti_dn_m} = tpayld_dti_dn_m;

      assign {tdata_dti_up_s,
              tkeep_dti_up_s,
              tdest_dti_up_s,
              tlast_dti_up_s} = tpayld_dti_up_s;
    end
  endgenerate

  assign ivalid_dti_dn_s = tvalid_dti_dn_s & ~gate_dti;
  assign tready_dti_dn_s = iready_dti_dn_s & ~gate_dti;

  assign tvalid_dti_dn_m = ivalid_dti_dn_m & ~gate_dti;     
  assign iready_dti_dn_m = tready_dti_dn_m & ~gate_dti;

  assign tvalid_dti_up_s = ivalid_dti_up_s & ~gate_dti;     
  assign iready_dti_up_s = tready_dti_up_s & ~gate_dti;

  assign ivalid_dti_up_m = tvalid_dti_up_m & ~gate_dti;
  assign tready_dti_up_m = iready_dti_up_m & ~gate_dti;



  firewall_f0_dti_reg_slice #(
    .PAYLD_WIDTH  (PAYLD_WIDTH),
    .MODE         (MODE)
  ) u_dti_reg_slice (
    .aresetn          (aresetn),
    .aclk             (aclk),
    .tvalid_dn_s      (ivalid_dti_dn_s),
    .tready_dn_s      (iready_dti_dn_s),
    .tpayld_dn_s      (tpayld_dti_dn_s),
    .tvalid_dn_m      (ivalid_dti_dn_m),
    .tready_dn_m      (iready_dti_dn_m),
    .tpayld_dn_m      (tpayld_dti_dn_m),
    .tvalid_up_s      (ivalid_dti_up_s),
    .tready_up_s      (iready_dti_up_s),
    .tpayld_up_s      (tpayld_dti_up_s),
    .tvalid_up_m      (ivalid_dti_up_m),
    .tready_up_m      (iready_dti_up_m),
    .tpayld_up_m      (tpayld_dti_up_m),

    .reg_busy_dn      (reg_busy_dn),
    .reg_busy_up      (reg_busy_up)
    );


    firewall_f0_or2 u_firewall_f0_bas_reg_slice_lpi_qbusy_cg_or2
    (
      .din0       (qbusy_cg),
      .din1       (qbusy_wakeup),
      .dout       (qactive_cg)
    );

    assign gate_dti = bas_gate;

    firewall_f0_or2 u_firewall_f0_bas_reg_slice_lpi_wakeup_or2
    (
      .din0       (twakeup_dti_dn_s),
      .din1       (twakeup_dti_up_m),
      .dout       (qbusy_wakeup)
    );

    firewall_f0_or2 u_firewall_f0_bas_reg_slice_lpi_valid_or2
    (
      .din0       (tvalid_dti_dn_s),
      .din1       (tvalid_dti_up_m),
      .dout       (qbusy_valid)
    );

    firewall_f0_or_tree #(
      .ACTIVE_WIDTH (2)
    ) u_firewall_f0_bas_reg_slice_busies_or2tree (
      .actives_i ({twakeup_dti_up_s, twakeup_dti_dn_m}),
      .active_o  (qbusy_cg)
    );

    always @(posedge aclk or negedge aresetn)
    begin : q_twakeup_up_bypass
      if(!aresetn) begin
        twakeup_dti_up <=  1'b0;
      end else begin
        twakeup_dti_up <= tvalid_dti_up_m;
      end
    end

    firewall_f0_or_tree #(
      .ACTIVE_WIDTH (2)
    ) u_firewall_f0_bas_reg_slice_up_s_wakeup_or2tree (
      .actives_i ({twakeup_dti_up, reg_busy_up}),
      .active_o  (twakeup_dti_up_s)
    );

    always @(posedge aclk or negedge aresetn)
    begin : q_twakeup_dn_bypass
      if(!aresetn) begin
        twakeup_dti_dn   <=  1'b0;
      end else begin
        twakeup_dti_dn   <= tvalid_dti_dn_s;
      end
    end

    firewall_f0_or_tree #(
      .ACTIVE_WIDTH (2)
    ) u_firewall_f0_bas_reg_slice_dn_m_wakeup_or2tree (
      .actives_i ({twakeup_dti_dn, reg_busy_dn}),
      .active_o  (twakeup_dti_dn_m)
    );

endmodule 

