//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2018 Arm Limited or its affiliates.
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
//   Sub-module of css600_tpiu
//
//----------------------------------------------------------------------------


module css600_tpiu_reg_t
(
  input  wire        traceclk_in,
  input  wire        treset_n,
  input  wire        tp_xfer_req_sync,
  input  wire        tp_xfer_type_sync,
  input  wire  [1:0] tp_addr_enc_sync,
  input  wire [31:0] tp_wdata_sync,
  output wire        tp_xfer_ack,
  output wire [31:0] tp_rdata,
  input  wire        pattern_done,
  output  reg        reg_update,
  output  reg        curr_psize_update,
  output wire [31:0] curr_psize_masked,
  output wire [31:0] port_bit_mask,
  output  reg  [1:0] curr_patt_mode,
  output  reg  [3:0] curr_patt_sel,
  output  reg  [7:0] tprcr_pattcount,
  output  reg [11:0] fscr_synccount
);

  wire          cspsr_wr_en;
  wire          cspsr_rd_en;
  wire          ctpmr_wr_en;
  wire          ctpmr_mode_wr_en;
  wire          ctpmr_rd_en;
  wire          tprcr_wr_en;
  wire          tprcr_rd_en;
  wire          fscr_wr_en;
  wire          fscr_rd_en;
  wire          fscr_unload;
  wire          fscr_reload;

  wire          reg_write;
  wire          reg_read;

  reg  [31:0]   curr_psize;

  wire [31:0]   cspsr_rd_data;
  wire [31:0]   ctpmr_rd_data;
  wire [31:0]   tprcr_rd_data;
  wire [31:0]   fscr_rd_data;

  wire          nxt_reg_update;
  wire [1:0]    nxt_patt_mode;
  wire [31:0]   nxt_rdata;
  reg  [31:0]   tp_rdata_cdc_chk;
  wire          tp_xfer_ack_cdc_chk;
  reg           tp_xfer_req_q1;
  reg           tp_xfer_req_q2;

  wire          patt_mode_bit0_sample;
  reg           patt_mode_bit0;


  always @ (posedge traceclk_in or negedge treset_n)
  begin : p_xferack
    if (!treset_n)
      begin
        tp_xfer_req_q1 <= 1'b0;
        tp_xfer_req_q2 <= 1'b0;
      end
    else
      begin
        tp_xfer_req_q1 <= tp_xfer_req_sync;
        tp_xfer_req_q2 <= tp_xfer_req_q1;
      end
  end

  assign tp_xfer_ack_cdc_chk = tp_xfer_req_q2;

  assign reg_write  = (tp_xfer_req_q1 & ~tp_xfer_req_q2 & tp_xfer_type_sync);
  assign reg_read   = (tp_xfer_req_q1 & ~tp_xfer_req_q2 & ~tp_xfer_type_sync);

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_cspsr
    if (!treset_n)
    begin
      curr_psize_update <= 1'b0;
      curr_psize <= 32'h00000001;
    end
    else
    begin
      curr_psize_update <= cspsr_wr_en;
      if (cspsr_wr_en)
        curr_psize <= tp_wdata_sync[31:0];
    end
  end

  assign cspsr_wr_en   = reg_write & (tp_addr_enc_sync == 2'b00);
  assign cspsr_rd_en   = reg_read & (tp_addr_enc_sync == 2'b00);

  assign cspsr_rd_data = curr_psize[31:0];

  assign port_bit_mask = {  curr_psize[31],
                         (| curr_psize[31:30]),
                         (| curr_psize[31:29]),
                         (| curr_psize[31:28]),
                         (| curr_psize[31:27]),
                         (| curr_psize[31:26]),
                         (| curr_psize[31:25]),
                         (| curr_psize[31:24]),
                         (| curr_psize[31:23]),
                         (| curr_psize[31:22]),
                         (| curr_psize[31:21]),
                         (| curr_psize[31:20]),
                         (| curr_psize[31:19]),
                         (| curr_psize[31:18]),
                         (| curr_psize[31:17]),
                         (| curr_psize[31:16]),
                         (| curr_psize[31:15]),
                         (| curr_psize[31:14]),
                         (| curr_psize[31:13]),
                         (| curr_psize[31:12]),
                         (| curr_psize[31:11]),
                         (| curr_psize[31:10]),
                         (| curr_psize[31: 9]),
                         (| curr_psize[31: 8]),
                         (| curr_psize[31: 7]),
                         (| curr_psize[31: 6]),
                         (| curr_psize[31: 5]),
                         (| curr_psize[31: 4]),
                         (| curr_psize[31: 3]),
                         (| curr_psize[31: 2]),
                         (| curr_psize[31: 1]),
                         (  1'b1             )};

  assign curr_psize_masked = {(port_bit_mask[31]                     ),
                              (port_bit_mask[30] & ~port_bit_mask[31]),
                              (port_bit_mask[29] & ~port_bit_mask[30]),
                              (port_bit_mask[28] & ~port_bit_mask[29]),
                              (port_bit_mask[27] & ~port_bit_mask[28]),
                              (port_bit_mask[26] & ~port_bit_mask[27]),
                              (port_bit_mask[25] & ~port_bit_mask[26]),
                              (port_bit_mask[24] & ~port_bit_mask[25]),
                              (port_bit_mask[23] & ~port_bit_mask[24]),
                              (port_bit_mask[22] & ~port_bit_mask[23]),
                              (port_bit_mask[21] & ~port_bit_mask[22]),
                              (port_bit_mask[20] & ~port_bit_mask[21]),
                              (port_bit_mask[19] & ~port_bit_mask[20]),
                              (port_bit_mask[18] & ~port_bit_mask[19]),
                              (port_bit_mask[17] & ~port_bit_mask[18]),
                              (port_bit_mask[16] & ~port_bit_mask[17]),
                              (port_bit_mask[15] & ~port_bit_mask[16]),
                              (port_bit_mask[14] & ~port_bit_mask[15]),
                              (port_bit_mask[13] & ~port_bit_mask[14]),
                              (port_bit_mask[12] & ~port_bit_mask[13]),
                              (port_bit_mask[11] & ~port_bit_mask[12]),
                              (port_bit_mask[10] & ~port_bit_mask[11]),
                              (port_bit_mask[ 9] & ~port_bit_mask[10]),
                              (port_bit_mask[ 8] & ~port_bit_mask[ 9]),
                              (port_bit_mask[ 7] & ~port_bit_mask[ 8]),
                              (port_bit_mask[ 6] & ~port_bit_mask[ 7]),
                              (port_bit_mask[ 5] & ~port_bit_mask[ 6]),
                              (port_bit_mask[ 4] & ~port_bit_mask[ 5]),
                              (port_bit_mask[ 3] & ~port_bit_mask[ 4]),
                              (port_bit_mask[ 2] & ~port_bit_mask[ 3]),
                              (port_bit_mask[ 1] & ~port_bit_mask[ 2]),
                              (port_bit_mask[ 0] & ~port_bit_mask[ 1])};


  always @ (posedge traceclk_in or negedge treset_n)
  begin : w_stpmr_pat
    if (!treset_n) begin
      curr_patt_sel  <= 4'b0;
      curr_patt_mode <= 2'b0;
    end else begin
      if (ctpmr_wr_en)
        curr_patt_sel <= tp_wdata_sync[3:0];
      if (ctpmr_mode_wr_en)
        curr_patt_mode[0] <= nxt_patt_mode[0];
      if (ctpmr_mode_wr_en)
        curr_patt_mode[1] <= nxt_patt_mode[1];
    end
  end

  assign patt_mode_bit0_sample = (tp_xfer_req_sync & ~tp_xfer_req_q1);

  always @ (posedge traceclk_in)
  begin : s_patt_mode_hold
    if (patt_mode_bit0_sample)
      patt_mode_bit0 <= curr_patt_mode[0];
  end


  assign ctpmr_wr_en      = reg_write & (tp_addr_enc_sync == 2'b01);
  assign ctpmr_mode_wr_en = ctpmr_wr_en | pattern_done;
  assign ctpmr_rd_en      = reg_read & (tp_addr_enc_sync == 2'b01);

  assign nxt_patt_mode    = (ctpmr_wr_en && tp_wdata_sync[17]) ? {1'b1,1'b0             }
                          : (ctpmr_wr_en                     ) ? {tp_wdata_sync[17:16]  }
                          :                                      {curr_patt_mode[1],1'b0}
                          ;

  assign ctpmr_rd_data    = {14'b0,
                             curr_patt_mode[1],
                             patt_mode_bit0,
                             12'b0,
                             curr_patt_sel};

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_tpattrpt
    if (!treset_n)
      tprcr_pattcount <= 8'b0;
    else if (tprcr_wr_en)
      tprcr_pattcount <= tp_wdata_sync[7:0];
  end

  assign tprcr_wr_en   = reg_write & (tp_addr_enc_sync == 2'b10);
  assign tprcr_rd_en   = reg_read & (tp_addr_enc_sync == 2'b10);

  assign tprcr_rd_data = {24'b0,
                          tprcr_pattcount};

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_formsync
    if (!treset_n)
      fscr_synccount <= 12'h040;
    else if (fscr_wr_en)
    begin
      if (tp_wdata_sync[11:0] == 12'd0)
        fscr_synccount <= 12'd0;
      else if (tp_wdata_sync[11:0] < 12'd8)
        fscr_synccount <= 12'd8;
      else
        fscr_synccount <= tp_wdata_sync[11:0];
    end
  end

  assign fscr_wr_en   = reg_write & (tp_addr_enc_sync == 2'b11);
  assign fscr_rd_en   = reg_read  & (tp_addr_enc_sync == 2'b11);

  assign fscr_rd_data = {20'b0,
                         fscr_synccount};

  assign nxt_rdata = (
                      ({32{cspsr_rd_en}} & cspsr_rd_data) |
                      ({32{ctpmr_rd_en}} & ctpmr_rd_data) |
                      ({32{tprcr_rd_en}} & tprcr_rd_data) |
                      ({32{fscr_rd_en}}  & fscr_rd_data)
                     );

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_tprdata
    if (!treset_n)
      tp_rdata_cdc_chk <= 32'b0;
    else if (reg_read)
      tp_rdata_cdc_chk <= nxt_rdata;
  end


  assign fscr_unload    =    ctpmr_wr_en & (nxt_patt_mode >2'd0) & (curr_patt_mode==2'd0);
  assign fscr_reload    =    ctpmr_wr_en & (nxt_patt_mode==2'd0) & (curr_patt_mode >2'd0);
  assign nxt_reg_update = ( (fscr_wr_en  & (curr_patt_mode==2'd0) )
                          | (fscr_unload                          )
                          | (fscr_reload                          )
                          );

  always @ (posedge traceclk_in or negedge treset_n)
  begin : s_regupdate
    if (!treset_n)
      reg_update <= 1'b0;
    else
      reg_update <= nxt_reg_update;
  end


    assign tp_xfer_ack = tp_xfer_ack_cdc_chk;
    assign tp_rdata = tp_rdata_cdc_chk;

endmodule

