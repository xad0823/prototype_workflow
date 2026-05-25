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

module xhb500_ahb_to_axi_bridge_external_system_core_resp (

  input  wire logic                                         clk,
  input  wire logic                                         resetn,

  input  wire logic                                         hsel,
  input  wire logic                                         hready,
  input  wire logic [1:0]                                   htrans,
  input  wire logic                                         hwrite,
  input  wire logic [6:0]                                   hprot,
  input  wire logic [2:0]                                   hburst,
  input  wire logic                                         hmastlock,
  input  wire logic                                         hexcl,
  output      logic [32-1:0]                                hrdata,
  output      logic                                         hreadyout,
  output      logic                                         hresp,
  output      logic                                         hexokay,

  input  wire logic                                         arvalid,
  input  wire logic                                         arready,
  input  wire logic [3:0]                                   arlen3_0,

  input  wire logic                                         awvalid,
  input  wire logic                                         awready,

  input  wire logic                                         rvalid,
  input  wire logic [32-1:0]                                rdata,
  input  wire logic [1:0]                                   rresp,
  output      logic                                         rready,

  input  wire logic                                         bvalid,
  input  wire logic [1:0]                                   bresp,
  output      logic                                         bready,

  input  wire logic                                         b_ewr,

  input  wire logic                                         write_data_phase,
  input       logic                                         pending_broken_b_resp,
  input  wire logic                                         beat_done_w,
  input  wire logic [4:0]                                   writes_remaining,
  input  wire logic                                         write_readyout,

  input  wire logic                                         pause_addr_submit,
  input  wire logic                                         address_readyout,
  output      logic                                         ready_for_read,

  input  wire logic                                         clk_qacceptn,
  input  wire logic                                         pwr_qacceptn
);

  import xhb500_ahb_to_axi_bridge_external_system_pkg::*;

  typedef enum logic [1:0]  {RESP_FSM_IDLE_BUSY     = 2'b00,
                             RESP_FSM_SEQ_NSEQ      = 2'b01,
                             RESP_FSM_ERROR         = 2'b10,
                             RESP_FSM_LOCK_ERROR    = 2'b11, RESP_FSM_undef       = 2'bxx} resp_fsm_type;



  logic                                                    r_done;
  logic                                                    b_done;

  logic                                                    beat_done_r;
  logic                                                    beat_done;

  logic                                                    axi_err;

  logic [4:0]                                              read_counter;

  logic                                                    read_broken_next;
  logic                                                    read_broken;

  logic                                                    ignore_read_data;

  resp_fsm_type                                            resp_fsm_state;
  resp_fsm_type                                            resp_fsm_next;
  logic                                                    ahb_trans;
  logic                                                    bready_reg;


  assign r_done   =  rvalid &  rready;
  assign b_done   =  bvalid &  bready;

  assign beat_done_r = r_done & ~ignore_read_data;
  assign beat_done = write_data_phase ? beat_done_w :
                                        beat_done_r;

  assign axi_err = write_data_phase ? bvalid & bresp[1] & ~b_ewr & ~pending_broken_b_resp : rvalid & rresp[1] & ~ignore_read_data;


  always_ff @ (posedge clk or negedge resetn)
  begin : read_counter_reg
      if (~resetn)
        read_counter <= 5'd0;
      else
        if (arvalid & arready)
          read_counter <= {1'b0,arlen3_0} + 5'd1;
        else if (r_done)
          read_counter <= read_counter - 5'd1;
  end

  assign read_broken_next = (~hsel | (hready & ~htrans[0])) & (|read_counter[4:1] | read_counter == 5'd1 & ~r_done);
  always_ff @ (posedge clk or negedge resetn)
  begin : read_broken_reg
      if (~resetn)
        read_broken <= 1'b0;
      else
        if (read_counter == 5'd1 & r_done)
          read_broken <= 1'b0;
        else if (read_broken_next)
          read_broken <= 1'b1;
  end

  always_ff @ (posedge clk or negedge resetn)
  begin : ignore_read_data_reg
      if (~resetn)
        ignore_read_data <= 1'b0;
      else
        if (read_counter == 5'd1 & r_done)
          ignore_read_data <= 1'b0;
        else if ( (read_broken | read_broken_next) &
                ((|read_counter[4:1] & r_done) ||
                ( read_counter!= 5'd0 & resp_fsm_state == RESP_FSM_IDLE_BUSY & !ignore_read_data) ) )
          ignore_read_data <= 1'b1;
  end


  assign ahb_trans  = hsel & hready && htrans[1];

  always_ff @ (posedge clk or negedge resetn)
  begin : resp_fsm_reg
      if (~resetn)
          resp_fsm_state <= RESP_FSM_IDLE_BUSY;
      else
          resp_fsm_state <= resp_fsm_next;
  end


  always_comb
  begin : resp_fsm_comb

    resp_fsm_next = resp_fsm_state;

    case (resp_fsm_state)
      RESP_FSM_IDLE_BUSY : begin
        hreadyout = 1'b1;
        hresp     = RSP_OKAY;
        if (ahb_trans)
        begin
          if (hmastlock)
            resp_fsm_next = RESP_FSM_LOCK_ERROR;
          else
            resp_fsm_next = RESP_FSM_SEQ_NSEQ;
        end

      end
      RESP_FSM_SEQ_NSEQ : begin
        if (~address_readyout)
          begin
            hreadyout = 1'b0;
            hresp     = RSP_OKAY;
          end
        else
          begin
            hreadyout = beat_done & ~axi_err;
            hresp     = axi_err & ~(beat_done & ~axi_err);
          end
        if (axi_err && address_readyout)
          resp_fsm_next = RESP_FSM_ERROR;
        else if (ahb_trans & hmastlock)
          resp_fsm_next = RESP_FSM_LOCK_ERROR;
        else if (hreadyout & (~hsel | ~htrans[1]))
          resp_fsm_next = RESP_FSM_IDLE_BUSY;
      end

      RESP_FSM_ERROR : begin

        hreadyout = 1'b1;
        hresp     = RSP_ERR;

        if (ahb_trans)
          if (hmastlock)
            resp_fsm_next = RESP_FSM_LOCK_ERROR;
          else
            resp_fsm_next = RESP_FSM_SEQ_NSEQ;
        else
          resp_fsm_next = RESP_FSM_IDLE_BUSY;
      end
      RESP_FSM_LOCK_ERROR : begin
        hreadyout = 1'b0;
        hresp     = RSP_ERR;
        resp_fsm_next = RESP_FSM_ERROR;
      end
      default : begin
        hreadyout = 1'bx;
        hresp     = 1'bx;
        resp_fsm_next = RESP_FSM_undef;
      end
    endcase

  end

  assign rready = ~clk_qacceptn || ~pwr_qacceptn ||
                  resp_fsm_state == RESP_FSM_IDLE_BUSY |
                  resp_fsm_state == RESP_FSM_LOCK_ERROR |
                  (resp_fsm_state == RESP_FSM_SEQ_NSEQ & axi_err) ?
                                ignore_read_data :
                                ignore_read_data || address_readyout;

  assign  ready_for_read    = ( read_counter==5'd0 | (r_done &  read_counter == 5'd1));

  assign hrdata  = rdata;
  assign hexokay = write_data_phase ? b_done & bresp == 2'b01 & ~b_ewr & ~pending_broken_b_resp
                                    : r_done & rresp == 2'b01 & !ignore_read_data;



  always_ff @ (posedge clk or negedge resetn)
  begin : p_bready_reg
      if (~resetn)
        bready_reg <= 1'b0;
      else
        if (~address_readyout && ~pending_broken_b_resp)
        begin
          if (bvalid & b_ewr & ~bready)
            bready_reg <= 1'b1;
          else
            bready_reg <= 1'b0;
        end

        else if (~bready_reg)
          bready_reg <= 1'b1;
  end

  assign bready = bready_reg && (clk_qacceptn && pwr_qacceptn);







endmodule
