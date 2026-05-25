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

module acg_axi_core #
(
  parameter INACT_CD_CONFIG = 3'b000,
  parameter AW_CNTR_SIZE = 8,
  parameter W_CNTR_SIZE = 8,
  parameter AR_CNTR_SIZE = 8
)(
  input   wire                          aclk,
  input   wire                          aresetn,

  input   wire                          arvalids,
  input   wire                          awvalids,
  input   wire                          wvalids,
  input   wire                          wlasts,

  input   wire                          bvalids,
  input   wire                          breadys,
  input   wire                          rvalids,
  input   wire                          rlasts,
  input   wire                          rreadys,

  input   wire                          arreadym,
  input   wire                          awreadym,
  input   wire                          wreadym,

  input   wire                          awakeups,
  
  output   wire                         arvalidm,
  output   wire                         awvalidm,
  output   wire                         wvalidm,

  output  wire                          arreadys,
  output  wire                          awreadys,
  output  wire                          wreadys,

 
  output  wire                          inact,


  input   wire                          pwr_qreqn,
  output  wire                          pwr_qacceptn,
  output  wire                          pwr_qdeny,
  output  wire                          pwr_qactive,

  input   wire                          clk_qreqn,
  output  wire                          clk_qacceptn,
  output  wire                          clk_qdeny,
  output  wire                          clk_qactive,

  input   wire                          ds_read_busy,
  input   wire                          ds_write_busy

);



  wire        incr_rd_ot_cntr;
  wire        dcrs_rd_ot_cntr;
  reg   [AR_CNTR_SIZE:0] rd_ot_cntr;
  wire   [AR_CNTR_SIZE:0] next_rd_ot_cntr;

  reg         rd_ot_cntr_non_zero;
  wire        next_rd_ot_cntr_non_zero;
  wire        rd_ot_cntr_full;


  wire        incr_aw_ot_cntr;
  wire        dcrs_aw_ot_cntr;
  reg   [AW_CNTR_SIZE:0] aw_ot_cntr;
  wire   [AW_CNTR_SIZE:0] next_aw_ot_cntr;

  reg         aw_ot_cntr_non_zero;
  wire        next_aw_ot_cntr_non_zero;

  wire        aw_ot_cntr_full;


  wire        incr_w_ot_cntr;
  wire        dcrs_w_ot_cntr;
  reg   [W_CNTR_SIZE:0] w_ot_cntr;
  wire   [W_CNTR_SIZE:0] next_w_ot_cntr;

  reg         wlast_cntr;
  wire        wlast_cntr_en;



  reg         w_ot_cntr_non_zero;
  wire        next_w_ot_cntr_non_zero;
  wire        w_ot_cntr_full;



  reg   [1:0] pwr_fsm_st;
  reg   [1:0] pwr_fsm_nxt_st;

  reg   [1:0] clk_fsm_st;
  reg   [1:0] clk_fsm_nxt_st;

  reg   [2:0] inact_cd;
  reg   [2:0] inact_nxt_cd; 


  wire        pending;
  wire        idle;

  wire        pwr_qreqn_sync;

  reg         next_pwr_qacceptn_r;
  reg         next_pwr_qdeny_r;
  reg         pwr_qacceptn_r;
  reg         pwr_qdeny_r;

  wire        clk_qreqn_sync;
  wire        clk_qactive_int;

  reg         next_clk_qacceptn_r;
  reg         next_clk_qdeny_r;
  reg         clk_qacceptn_r;
  reg         clk_qdeny_r;

  

  reg         inact_sync;
  reg         next_inact;

  wire        gate_open;
  wire        clk_on;
  
  
  acg_synchronizer u_acg_sync_pwr_qreqn(
    .clk                                (aclk),
    .nreset                             (aresetn),
    .d_async                            (pwr_qreqn),
    .q                                  (pwr_qreqn_sync)
  );  
  
  acg_synchronizer u_acg_sync_clk_qreqn(
    .clk                                (aclk),
    .nreset                             (aresetn),
    .d_async                            (clk_qreqn),
    .q                                  (clk_qreqn_sync)
  );  


  assign  incr_rd_ot_cntr = arvalids && arreadys; 
  assign  dcrs_rd_ot_cntr = rvalids && rreadys && rlasts; 

  assign  next_rd_ot_cntr = (  incr_rd_ot_cntr  && (!dcrs_rd_ot_cntr))  ? rd_ot_cntr+ {{(AR_CNTR_SIZE){1'b0}},1'b1}: 
                            ((!incr_rd_ot_cntr) &&   dcrs_rd_ot_cntr )  ? rd_ot_cntr- {{(AR_CNTR_SIZE){1'b0}},1'b1}: 
                                                                          rd_ot_cntr;

  assign  next_rd_ot_cntr_non_zero = !(next_rd_ot_cntr == {(AR_CNTR_SIZE+1){1'b0}});

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      rd_ot_cntr <= {(AR_CNTR_SIZE+1){1'b0}};  
    else if (gate_open) 
      rd_ot_cntr <= next_rd_ot_cntr;

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      rd_ot_cntr_non_zero <= 1'b0;  
    else if (gate_open) 
      rd_ot_cntr_non_zero <= next_rd_ot_cntr_non_zero;

  assign rd_ot_cntr_full = rd_ot_cntr[AR_CNTR_SIZE];

  assign  incr_aw_ot_cntr = awvalids && awreadys; 
  assign  dcrs_aw_ot_cntr = bvalids && breadys;

  assign  next_aw_ot_cntr = (  incr_aw_ot_cntr  && (!dcrs_aw_ot_cntr))  ? aw_ot_cntr+ {{(AW_CNTR_SIZE){1'b0}},1'b1}:
                            ((!incr_aw_ot_cntr) &&   dcrs_aw_ot_cntr )  ? aw_ot_cntr- {{(AW_CNTR_SIZE){1'b0}},1'b1}: 
                                                                          aw_ot_cntr;

  assign next_aw_ot_cntr_non_zero = !(next_aw_ot_cntr == {(AW_CNTR_SIZE+1){1'b0}});

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      aw_ot_cntr <= {(AW_CNTR_SIZE+1){1'b0}};  
    else if (gate_open) 
      aw_ot_cntr <= next_aw_ot_cntr;

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      aw_ot_cntr_non_zero <= 1'b0;  
    else if (gate_open) 
      aw_ot_cntr_non_zero <= next_aw_ot_cntr_non_zero;

  assign aw_ot_cntr_full = aw_ot_cntr[AW_CNTR_SIZE];

  assign wlast_cntr_en = wvalids & wreadys & gate_open;

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      wlast_cntr <= 1'b0; 
    else if (wlast_cntr_en) 
      wlast_cntr <= ~wlasts;


  assign  incr_w_ot_cntr = wvalids && wreadys && (!wlast_cntr);
  assign  dcrs_w_ot_cntr = bvalids && breadys;

  assign  next_w_ot_cntr = (  incr_w_ot_cntr  && (!dcrs_w_ot_cntr))  ? w_ot_cntr+ {{(W_CNTR_SIZE){1'b0}},1'b1}:
                           ((!incr_w_ot_cntr) &&   dcrs_w_ot_cntr )  ? w_ot_cntr- {{(W_CNTR_SIZE){1'b0}},1'b1}: 
                                                                       w_ot_cntr;

  assign  next_w_ot_cntr_non_zero = !(next_w_ot_cntr == {(W_CNTR_SIZE+1){1'b0}});

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      w_ot_cntr <= {(W_CNTR_SIZE+1){1'b0}};  
    else if (gate_open) 
      w_ot_cntr <= next_w_ot_cntr;

  always @(posedge aclk or negedge aresetn) 
    if (!aresetn) 
      w_ot_cntr_non_zero <= 1'b0;  
    else if (gate_open) 
      w_ot_cntr_non_zero <= next_w_ot_cntr_non_zero;
 
  assign w_ot_cntr_full = w_ot_cntr[W_CNTR_SIZE];



  assign idle    = !(rd_ot_cntr_non_zero || aw_ot_cntr_non_zero || w_ot_cntr_non_zero);
  assign pending = awakeups;



  localparam ACG_CLOSE       =  2'b00;    
  localparam ACG_WAIT_INACT  =  2'b01;    
  localparam ACG_OPEN        =  2'b11;    
  localparam ACG_REQ_DENIED  =  2'b10;    

  always @(*) begin

    case (pwr_fsm_st)
      ACG_CLOSE:
        begin
          pwr_fsm_nxt_st        = (pwr_qreqn_sync && ~|inact_cd        )  ? ACG_OPEN        : 
                                  (pwr_qreqn_sync)                        ? ACG_WAIT_INACT  :
                                  ACG_CLOSE;
          inact_nxt_cd          = (pwr_qreqn_sync && ~|inact_cd        )  ? INACT_CD_CONFIG  : 
                                  (pwr_qreqn_sync)                        ? inact_cd - 3'b1  :
                                  inact_cd;
          next_inact            = (pwr_qreqn_sync && ~|inact_cd        )  ? 1'b0            : 
                                  (pwr_qreqn_sync)                        ? 1'b0            :
                                  1'b1;
          next_pwr_qacceptn_r   = (pwr_qreqn_sync && ~|inact_cd        )  ? 1'b1 : 1'b0;
          next_pwr_qdeny_r      = 1'b0;
        end
      
      ACG_WAIT_INACT:
        begin
          pwr_fsm_nxt_st        = (~|inact_cd        )  ? ACG_OPEN         :
                                  ACG_WAIT_INACT; 
          inact_nxt_cd          = (~|inact_cd        )  ? INACT_CD_CONFIG  :
                                  inact_cd - 3'b1; 
          next_inact            = 1'b0;
          next_pwr_qacceptn_r   = (~|inact_cd        )  ? 1'b1             : 1'b0;
          next_pwr_qdeny_r      = 1'b0;
        end

      ACG_OPEN:
        begin
          pwr_fsm_nxt_st        = pwr_qreqn_sync    ?  ACG_OPEN   : 
                                  idle && (!pending)?  ACG_CLOSE : ACG_REQ_DENIED;
          inact_nxt_cd          = INACT_CD_CONFIG;
          next_inact            = pwr_qreqn_sync      ? 1'b0   : 
                                  idle && (!pending)  ? 1'b1   : 1'b0;
          next_pwr_qacceptn_r   = pwr_qreqn_sync      ? 1'b1   :
                                  idle && (!pending)  ? 1'b0   : 1'b1;
          next_pwr_qdeny_r      = pwr_qreqn_sync      ? 1'b0   :
                                  idle && (!pending)  ? 1'b0   : 1'b1;
        end
      
      ACG_REQ_DENIED:
        begin
          pwr_fsm_nxt_st        = pwr_qreqn_sync    ? ACG_OPEN        : ACG_REQ_DENIED;
          inact_nxt_cd          = INACT_CD_CONFIG;
          next_inact            = 1'b0;
          next_pwr_qacceptn_r   = 1'b1;
          next_pwr_qdeny_r      = pwr_qreqn_sync     ? 1'b0 : 1'b1;
        end

      default:      
        begin
          pwr_fsm_nxt_st        = 2'bxx;
          inact_nxt_cd          = INACT_CD_CONFIG;
          next_inact            = 1'bx;
          next_pwr_qacceptn_r   = 1'bx;
          next_pwr_qdeny_r      = 1'bx;
        end

    endcase
  end

   always @(posedge aclk or negedge aresetn) 
     if (!aresetn)
       inact_cd <= INACT_CD_CONFIG;
     else
       inact_cd <= inact_nxt_cd;
 

  always @(posedge aclk or negedge aresetn) 
     if (!aresetn)
       pwr_fsm_st <= ACG_CLOSE;
     else
       pwr_fsm_st <=  pwr_fsm_nxt_st;


  always @(posedge aclk or negedge aresetn) 
    if (!aresetn)
      begin
        pwr_qacceptn_r <= 1'b0;
        pwr_qdeny_r <= 1'b0;
      end
    else
      begin
        pwr_qacceptn_r <= next_pwr_qacceptn_r;
        pwr_qdeny_r <= next_pwr_qdeny_r;
      end


  always @(posedge aclk or negedge aresetn) 
    if (!aresetn)
      begin
        inact_sync <= 1'b1;
      end
    else
      begin
        inact_sync <= next_inact;
      end

  assign  clk_qactive_int      =  rd_ot_cntr_non_zero || aw_ot_cntr_non_zero || w_ot_cntr_non_zero || awakeups || pwr_qdeny_r || ds_read_busy || ds_write_busy;


  acg_axi_core_async 
  u_acg_axi_core_async
  (
    .awakeups_i(awakeups),
    .rd_ot_cntr_non_zero_i(rd_ot_cntr_non_zero),
    .aw_ot_cntr_non_zero_i(aw_ot_cntr_non_zero),
    .w_ot_cntr_non_zero_i(w_ot_cntr_non_zero),
    .pwr_qreqn_i(pwr_qreqn),
    .pwr_qacceptn_i(pwr_qacceptn_r),
    .pwr_qdeny_i(pwr_qdeny_r),
    .ds_read_busy_i(ds_read_busy),
    .ds_write_busy_i(ds_write_busy),
    .clk_qactive_o(clk_qactive),
    .pwr_qactive_o(pwr_qactive)
  );


  assign pwr_qacceptn      = pwr_qacceptn_r;   
  assign pwr_qdeny         = pwr_qdeny_r;       
  assign inact             = inact_sync;

  assign gate_open = (pwr_fsm_st == ACG_OPEN) || (pwr_fsm_st == ACG_REQ_DENIED);

  assign arvalidm    = arvalids && gate_open && (!rd_ot_cntr_full) && clk_on;
  assign arreadys    = arreadym && gate_open && (!rd_ot_cntr_full) && clk_on;

  assign awvalidm    = awvalids && gate_open && (!aw_ot_cntr_full) && clk_on;
  assign awreadys    = awreadym && gate_open && (!aw_ot_cntr_full) && clk_on;

  assign wvalidm     = wvalids  && gate_open && (!w_ot_cntr_full) && clk_on;
  assign wreadys     = wreadym  && gate_open && (!w_ot_cntr_full) && clk_on;



  localparam ACG_CLK_OFF        = 2'b00;    
  localparam ACG_CLK_ON         = 2'b11;    
  localparam ACG_CLK_REQ_DENIED = 2'b10;    

  assign clk_on = (!(clk_fsm_st == ACG_CLK_OFF));
  
  always @(*) begin

    case (clk_fsm_st)
      ACG_CLK_OFF:
        begin
          clk_fsm_nxt_st        = clk_qreqn_sync     ? ACG_CLK_ON        : ACG_CLK_OFF;
          next_clk_qacceptn_r   = clk_qreqn_sync     ? 1'b1              : 1'b0;
          next_clk_qdeny_r      = 1'b0;
        end
      ACG_CLK_ON:
        begin
          clk_fsm_nxt_st        = clk_qreqn_sync     ? ACG_CLK_ON        :
                                  clk_qactive_int    ? ACG_CLK_REQ_DENIED: ACG_CLK_OFF;
          next_clk_qacceptn_r   = clk_qreqn_sync     ? 1'b1              :
                                  clk_qactive_int    ? 1'b1              : 1'b0;
          next_clk_qdeny_r      = clk_qreqn_sync     ? 1'b0              :
                                  clk_qactive_int    ? 1'b1              : 1'b0;
        end
      ACG_CLK_REQ_DENIED:
        begin
          clk_fsm_nxt_st        = clk_qreqn_sync     ? ACG_CLK_ON        : ACG_CLK_REQ_DENIED;
          next_clk_qacceptn_r   = 1'b1;
          next_clk_qdeny_r      = clk_qreqn_sync     ? 1'b0              : 1'b1;          
        end
      default: 
        begin
          clk_fsm_nxt_st        = 2'bxx;
          next_clk_qacceptn_r   = 1'bx;
          next_clk_qdeny_r      = 1'bx;
        end
    endcase
  end


  always @(posedge aclk or negedge aresetn) 
     if (!aresetn)
       clk_fsm_st <= ACG_CLK_OFF;
     else
       clk_fsm_st <=  clk_fsm_nxt_st;


  always @(posedge aclk or negedge aresetn) 
    if (!aresetn)
      begin
        clk_qacceptn_r <= 1'b0;
        clk_qdeny_r <= 1'b0;
      end
    else
      begin
        clk_qacceptn_r <= next_clk_qacceptn_r;
        clk_qdeny_r <= next_clk_qdeny_r;
      end
  

  assign clk_qacceptn = clk_qacceptn_r;
  assign clk_qdeny    = clk_qdeny_r;
  

endmodule
