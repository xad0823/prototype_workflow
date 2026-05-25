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

module firewall_f0_ctlr_cmp_pwr_hndsk #(
    parameter FW_SRE_LVL     = 1,
    parameter FW_NUM_FC      = 13,
    parameter LOG2_FW_NUM_FC = 5
) (
    input  wire                      clk,
    input  wire                      reset_n,

    input  wire [1:0]                cmp_pwr_con_req_i,
    input  wire                      cmp_pwr_discon_req_i,
    input  wire [LOG2_FW_NUM_FC-1:0] cmp_pwr_fw_id_i,
    input  wire                      cmp_pwr_req_valid_i,

    output wire                      cmp_pwr_prot_block_o,
    input  wire                      cmp_pwr_trkr_i,
    output wire                      cmp_pwr_hndshk_pend_o,
    input  wire                      cmp_pwr_cfg_pend_i,

    output wire                      cmp_pwr_restore_req_o,
    output wire [LOG2_FW_NUM_FC-1:0] cmp_pwr_restore_fw_id_o,
    output wire                      cmp_pwr_restore_valid_o,
    input  wire                      cmp_pwr_restore_done_i,
    input  wire                      cmp_pwr_shdw_init_done_i,
    input  wire [FW_NUM_FC-1:0]      cmp_pwr_wr_aft_dsc_i,
    input  wire [FW_NUM_FC-1:0]      cmp_pwr_wr_aft_rst_i,
    output wire                      cmp_pwr_shdw_con_valid_o,
    output wire [LOG2_FW_NUM_FC-1:0] cmp_pwr_shdw_con_fw_id_o,

    output wire [LOG2_FW_NUM_FC-1:0] cmp_pwr_con_fw_id_o,
    output wire                      cmp_pwr_con_valid_o,
    output wire                      cmp_pwr_discon_valid_o,

    output wire                      cmp_pwr_clk_busy_o,

    input  wire                      cmp_pwr_us_last_sent_i,

    output wire [FW_NUM_FC-1:0]      comp_pwr_st_o,
    output wire [FW_NUM_FC-1:0]      comp_pwr_st_en_o,
    input  wire [FW_NUM_FC-1:0]      comp_pwr_st_i
);


`include "firewall_f0_log2.vh"


localparam FIFO_WIDTH      = LOG2_FW_NUM_FC + 2;
localparam FIFO_DEPTH      = FW_NUM_FC;
localparam LOG2_FIFO_DEPTH = firewall_f0_log2(FIFO_DEPTH);

localparam SIZE    = 3;
localparam IDLE    = 3'b001;
localparam PWR_SRV = 3'b010;
localparam CFG_SRV = 3'b100;


reg                        fifo_pop;
wire [FIFO_WIDTH-1:0]      fifo_dataout;
wire                       fifo_empty;
reg                        fifo_push;
reg  [FIFO_WIDTH-1:0]      fifo_datain;
wire                       fifo_full;
wire [LOG2_FIFO_DEPTH-1:0] fifo_writeptr;
wire [LOG2_FIFO_DEPTH-1:0] fifo_readptr;

reg                      cmp_pwr_prot_block_o_int;
reg                      cmp_pwr_restore_req_o_int;
reg [LOG2_FW_NUM_FC-1:0] cmp_pwr_restore_fw_id_o_int;
reg                      cmp_pwr_restore_valid_o_int;
reg                      cmp_pwr_con_rsp_o_int;
reg [LOG2_FW_NUM_FC-1:0] cmp_pwr_con_fw_id_o_int;
reg                      cmp_pwr_con_valid_o_int;
reg                      cmp_pwr_discon_valid_o_int;
reg                      cmp_pwr_clk_busy_o_int;

reg [SIZE-1:0] state;
reg [SIZE-1:0] nxt_state;
reg [SIZE-1:0] last_state;

wire [2:0] idle_to_all_conds;
wire       idle_to_cfg_cond;
wire       idle_to_pwr_cond;
wire       idle_to_idle_cond;

wire [2:0] pwr_to_all_conds;
wire       pwr_to_cfg_cond;
wire       pwr_to_pwr_cond;
wire       pwr_to_idle_cond;

wire [2:0] cfg_to_all_conds;
wire       cfg_to_cfg_cond;
wire       cfg_to_pwr_cond;
wire       cfg_to_idle_cond;

reg curr_acc_done;

wire trkr_empty;

reg valid_pulse;

reg [FW_NUM_FC-1:0] comp_pwr_st_en_o_int;
reg [FW_NUM_FC-1:0] comp_pwr_st_o_int;

wire init_done;

integer i0, i1, i2;


firewall_f0_fifo #(
  .FIFO_WIDTH      (FIFO_WIDTH     ),
  .FIFO_DEPTH      (FIFO_DEPTH     ),
  .LOG2_FIFO_DEPTH (LOG2_FIFO_DEPTH)
) u_hndsk_fifo (
  .clk          (clk          ),
  .reset_n      (reset_n      ),

  .fifo_pop     (fifo_pop     ),
  .fifo_dataout (fifo_dataout ),
  .fifo_empty   (fifo_empty   ),
  .fifo_push    (fifo_push    ),
  .fifo_datain  (fifo_datain  ),
  .fifo_full    (fifo_full    ),
  .fifo_writeptr(fifo_writeptr),
  .fifo_readptr (fifo_readptr )
);


always @(posedge clk or negedge reset_n)
begin: PUSH_TO_FIFO
  if (!reset_n) begin
    fifo_push   <= 1'b0;
    fifo_datain <= {FIFO_WIDTH{1'b0}};
  end
  else begin
    fifo_push <= cmp_pwr_req_valid_i;
    if (cmp_pwr_con_req_i[0]) begin
      fifo_datain[1:0] <= cmp_pwr_con_req_i;
    end
    else begin
      fifo_datain[1:0] <= 2'b00;
    end
    fifo_datain[FIFO_WIDTH-1:2] <= cmp_pwr_fw_id_i;
  end
end


assign trkr_empty = ~cmp_pwr_trkr_i;


assign idle_to_pwr_cond  = (state==IDLE) && (!fifo_empty && !cmp_pwr_cfg_pend_i);

assign idle_to_cfg_cond  = (state==IDLE) && cmp_pwr_cfg_pend_i;

assign idle_to_idle_cond = (state==IDLE) && (fifo_empty && !cmp_pwr_cfg_pend_i);

assign idle_to_all_conds = {idle_to_pwr_cond, idle_to_cfg_cond,
                            idle_to_idle_cond};


assign pwr_to_pwr_cond  = (state==PWR_SRV) && (!curr_acc_done);

assign pwr_to_cfg_cond  = (state==PWR_SRV) && (cmp_pwr_cfg_pend_i && curr_acc_done);

assign pwr_to_idle_cond = (state==PWR_SRV) && (!cmp_pwr_cfg_pend_i && curr_acc_done);

assign pwr_to_all_conds = {pwr_to_pwr_cond, pwr_to_cfg_cond,
                           pwr_to_idle_cond};


assign cfg_to_pwr_cond  = (state==CFG_SRV) && (!fifo_empty && trkr_empty) &&
                          (last_state==CFG_SRV);

assign cfg_to_cfg_cond  = (state==CFG_SRV) && (!trkr_empty ||
                          (last_state!=CFG_SRV));

assign cfg_to_idle_cond = (state==CFG_SRV) && (fifo_empty && trkr_empty &&
                          (last_state==CFG_SRV));

assign cfg_to_all_conds = {cfg_to_pwr_cond, cfg_to_cfg_cond,
                           cfg_to_idle_cond};


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    valid_pulse <= 1'b0;
  end else begin
    if (idle_to_pwr_cond || cfg_to_pwr_cond) begin
      valid_pulse <= 1'b1;
    end
    else begin
      valid_pulse <= 1'b0;
    end
  end
end


generate
  if (FW_SRE_LVL == 1) begin : SRE_1

    reg init_done_r;

    always @ (posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        init_done_r <= 1'b0;
      end
      else begin
        if (cmp_pwr_shdw_init_done_i) begin
          init_done_r <= 1'b1;
        end
      end
    end

    assign init_done = init_done_r;

  end
  else begin: SRE_0
    assign init_done = 1'b0;
  end
endgenerate


always @(posedge clk or negedge reset_n)
begin
  if (!reset_n) begin
    state      <= IDLE;
    last_state <= IDLE;
  end else begin
    state      <= nxt_state;
    last_state <= state;
  end
end

always @(*)
begin: ROUND_ROBIN_ARBITER
  case (state)
    IDLE: begin
      case (idle_to_all_conds)
        3'b001 : nxt_state = IDLE;
        3'b010 : nxt_state = CFG_SRV;
        3'b100 : nxt_state = PWR_SRV;
        default: nxt_state = {SIZE{1'bx}};
      endcase
    end
    PWR_SRV: begin
      case (pwr_to_all_conds)
        3'b001 : nxt_state = IDLE;
        3'b010 : nxt_state = CFG_SRV;
        3'b100 : nxt_state = PWR_SRV;
        default: nxt_state = {SIZE{1'bx}};
      endcase
    end
    CFG_SRV: begin
      case (cfg_to_all_conds)
        3'b001 : nxt_state = IDLE;
        3'b010 : nxt_state = CFG_SRV;
        3'b100 : nxt_state = PWR_SRV;
        default: nxt_state = {SIZE{1'bx}};
      endcase
    end
    default: begin
      nxt_state = {SIZE{1'bx}};
    end
  endcase
end

always @(*)
begin:DRIVE_OUTPUTS

  case (state)

    IDLE   : begin
      cmp_pwr_prot_block_o_int    = 1'b0;

      cmp_pwr_restore_req_o_int   = 1'b0;
      cmp_pwr_restore_fw_id_o_int = {LOG2_FW_NUM_FC{1'b0}};
      cmp_pwr_restore_valid_o_int = 1'b0;

      cmp_pwr_con_rsp_o_int       = 1'b0;
      cmp_pwr_con_fw_id_o_int     = {LOG2_FW_NUM_FC{1'b0}};
      cmp_pwr_con_valid_o_int     = 1'b0;
      cmp_pwr_discon_valid_o_int  = 1'b0;

      cmp_pwr_clk_busy_o_int      = !fifo_empty | fifo_push;

      curr_acc_done               = 1'b0;
      fifo_pop                    = 1'b0;
      comp_pwr_st_o_int           = {FW_NUM_FC{1'b0}};
      comp_pwr_st_en_o_int        = {FW_NUM_FC{1'b0}};
    end

    CFG_SRV: begin
      cmp_pwr_prot_block_o_int    = 1'b0;

      cmp_pwr_restore_req_o_int   = 1'b0;
      cmp_pwr_restore_fw_id_o_int = {LOG2_FW_NUM_FC{1'b0}};
      cmp_pwr_restore_valid_o_int = 1'b0;

      cmp_pwr_con_rsp_o_int       = 1'b0;
      cmp_pwr_con_fw_id_o_int     = {LOG2_FW_NUM_FC{1'b0}};
      cmp_pwr_con_valid_o_int     = 1'b0;
      cmp_pwr_discon_valid_o_int  = 1'b0;

      cmp_pwr_clk_busy_o_int      = 1'b1;

      curr_acc_done               = cmp_pwr_us_last_sent_i;
      fifo_pop                    = 1'b0;
      comp_pwr_st_o_int           = {FW_NUM_FC{1'b0}};
      comp_pwr_st_en_o_int        = {FW_NUM_FC{1'b0}};
    end

    PWR_SRV: begin
      cmp_pwr_prot_block_o_int    = 1'b1;

      cmp_pwr_restore_req_o_int   = 1'b1;
      cmp_pwr_restore_fw_id_o_int = fifo_dataout[FIFO_WIDTH-1:2];
      cmp_pwr_restore_valid_o_int = 1'b0;

      cmp_pwr_con_rsp_o_int       = 1'b1;
      cmp_pwr_con_fw_id_o_int     = fifo_dataout[FIFO_WIDTH-1:2];

      cmp_pwr_clk_busy_o_int      = 1'b1;

      case (fifo_dataout[1:0])
        2'b00  : begin
          cmp_pwr_restore_valid_o_int = 1'b0;

          cmp_pwr_con_valid_o_int     = 1'b0;
          cmp_pwr_discon_valid_o_int  = valid_pulse && !fifo_empty;
          curr_acc_done               = cmp_pwr_us_last_sent_i;
          fifo_pop                    = cmp_pwr_us_last_sent_i;

          if (cmp_pwr_discon_valid_o_int) begin
            for (i0=0;i0<FW_NUM_FC;i0=i0+1) begin
              if (i0==fifo_dataout[FIFO_WIDTH-1:2]) begin
                comp_pwr_st_en_o_int[i0] = 1'b1;
              end
              else begin
                comp_pwr_st_en_o_int[i0] = 1'b0;
              end
            end
          end
          else begin
            comp_pwr_st_en_o_int = {FW_NUM_FC{1'b0}};
          end
          comp_pwr_st_o_int      = {FW_NUM_FC{1'b0}};

        end
        2'b01  : begin

          cmp_pwr_con_valid_o_int = 1'b0;

          if (FW_SRE_LVL==0) begin
            cmp_pwr_restore_valid_o_int = 1'b0;
            cmp_pwr_con_valid_o_int     = valid_pulse && !fifo_empty;
          end else begin
            cmp_pwr_restore_valid_o_int =
              init_done && cmp_pwr_wr_aft_dsc_i[fifo_dataout[FIFO_WIDTH-1:2]] &&
              valid_pulse && !fifo_empty;

            cmp_pwr_con_valid_o_int     =
              !cmp_pwr_restore_valid_o_int && valid_pulse && !fifo_empty;
          end

          cmp_pwr_discon_valid_o_int  = 1'b0;

          curr_acc_done =
            (!cmp_pwr_wr_aft_dsc_i[fifo_dataout[FIFO_WIDTH-1:2]]) ?
             cmp_pwr_us_last_sent_i :
               cmp_pwr_restore_done_i;

          fifo_pop =
            (!cmp_pwr_wr_aft_dsc_i[fifo_dataout[FIFO_WIDTH-1:2]]) ?
             cmp_pwr_us_last_sent_i :
               cmp_pwr_restore_done_i;

          if ((cmp_pwr_con_rsp_o_int && cmp_pwr_con_valid_o_int) ||
              (cmp_pwr_restore_req_o_int && cmp_pwr_restore_valid_o_int)) begin
            for (i1=0;i1<FW_NUM_FC;i1=i1+1) begin
              if (i1==fifo_dataout[FIFO_WIDTH-1:2]) begin
                comp_pwr_st_en_o_int[i1] = 1'b1;
              end
              else begin
                comp_pwr_st_en_o_int[i1] = 1'b0;
              end
            end
          end
          else begin
            comp_pwr_st_en_o_int = {FW_NUM_FC{1'b0}};
          end
          comp_pwr_st_o_int      = {FW_NUM_FC{1'b1}};
        end
        2'b11  : begin

          cmp_pwr_con_valid_o_int = 1'b0;

          if (FW_SRE_LVL==0) begin
            cmp_pwr_restore_valid_o_int = 1'b0;
            cmp_pwr_con_valid_o_int     = valid_pulse && !fifo_empty;
          end else begin
            cmp_pwr_restore_valid_o_int = (init_done &&
                                          cmp_pwr_wr_aft_rst_i[fifo_dataout[FIFO_WIDTH-1:2]]) &&
                                          valid_pulse && !fifo_empty;

            cmp_pwr_con_valid_o_int     = !cmp_pwr_restore_valid_o_int &&
                                          valid_pulse && !fifo_empty;
          end

          cmp_pwr_discon_valid_o_int  = 1'b0;

          curr_acc_done =
            (!cmp_pwr_wr_aft_rst_i[fifo_dataout[FIFO_WIDTH-1:2]]) ?
             cmp_pwr_us_last_sent_i :
               cmp_pwr_restore_done_i;

          fifo_pop =
            (!cmp_pwr_wr_aft_rst_i[fifo_dataout[FIFO_WIDTH-1:2]]) ?
             cmp_pwr_us_last_sent_i :
               cmp_pwr_restore_done_i;

          if ((cmp_pwr_con_rsp_o_int && cmp_pwr_con_valid_o_int) ||
              (cmp_pwr_restore_req_o_int && cmp_pwr_restore_valid_o_int)) begin
            for (i2=0;i2<FW_NUM_FC;i2=i2+1) begin
              if (i2==fifo_dataout[FIFO_WIDTH-1:2]) begin
                comp_pwr_st_en_o_int[i2] = 1'b1;
              end else begin
                comp_pwr_st_en_o_int[i2] = 1'b0;
              end
            end
          end else begin
            comp_pwr_st_en_o_int = {FW_NUM_FC{1'b0}};
          end
          comp_pwr_st_o_int      = {FW_NUM_FC{1'b1}};
        end

        default: begin
          cmp_pwr_restore_valid_o_int = 1'b0;
          cmp_pwr_con_valid_o_int     = 1'b0;
          cmp_pwr_discon_valid_o_int  = 1'b0;
          curr_acc_done               = 1'b1;
          fifo_pop                    = 1'b0;
          comp_pwr_st_o_int           = {FW_NUM_FC{1'b0}};
          comp_pwr_st_en_o_int        = {FW_NUM_FC{1'b0}};
        end
      endcase
    end

    default: begin
      cmp_pwr_prot_block_o_int    = 1'bx;

      cmp_pwr_restore_req_o_int   = 1'bx;
      cmp_pwr_restore_fw_id_o_int = {LOG2_FW_NUM_FC{1'bx}};
      cmp_pwr_restore_valid_o_int = 1'bx;

      cmp_pwr_con_rsp_o_int       = 1'bx;
      cmp_pwr_con_fw_id_o_int     = {LOG2_FW_NUM_FC{1'bx}};
      cmp_pwr_con_valid_o_int     = 1'bx;
      cmp_pwr_discon_valid_o_int  = 1'bx;

      cmp_pwr_clk_busy_o_int      = 1'bx;

      curr_acc_done               = 1'bx;
      fifo_pop                    = 1'bx;
      comp_pwr_st_o_int           = {FW_NUM_FC{1'bx}};
      comp_pwr_st_en_o_int        = {FW_NUM_FC{1'bx}};
    end
  endcase
end


assign cmp_pwr_hndshk_pend_o = !fifo_empty && (state == CFG_SRV) && (last_state == CFG_SRV);

assign cmp_pwr_prot_block_o     = cmp_pwr_prot_block_o_int;
assign cmp_pwr_restore_req_o    = cmp_pwr_restore_req_o_int;
assign cmp_pwr_restore_fw_id_o  = cmp_pwr_restore_fw_id_o_int;
assign cmp_pwr_restore_valid_o  = cmp_pwr_restore_valid_o_int;
assign cmp_pwr_con_fw_id_o      = cmp_pwr_con_fw_id_o_int;
assign cmp_pwr_con_valid_o      = cmp_pwr_con_valid_o_int;
assign cmp_pwr_shdw_con_valid_o = cmp_pwr_con_valid_o_int;
assign cmp_pwr_shdw_con_fw_id_o = cmp_pwr_con_fw_id_o_int;
assign cmp_pwr_discon_valid_o   = cmp_pwr_discon_valid_o_int;
assign cmp_pwr_clk_busy_o       = cmp_pwr_clk_busy_o_int;
assign comp_pwr_st_en_o         = comp_pwr_st_en_o_int;
assign comp_pwr_st_o            = comp_pwr_st_o_int;

endmodule
