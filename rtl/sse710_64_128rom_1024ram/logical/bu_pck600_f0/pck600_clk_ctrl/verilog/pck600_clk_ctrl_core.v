// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2018-2019  Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//  Release Information : PCK600-r0p4-00eac0
//
// -----------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
// -----------------------------------------------------------------------------


module pck600_clk_ctrl_core
#(
  parameter NUM_Q_CHL           = 1,
  parameter NUM_QACTIVE         = 1,
  parameter ACTIVE_DENY_EN      = 1
)
(
  input  wire                   clk,
  input  wire                   reset_n,

  input  wire                   dftcgen,

  input  wire                   hc_qreqn_i,
  output wire                   hc_qacceptn_o,
  output wire                   hc_qdeny_o,

  input  wire                   pwr_qreqn_i,
  output wire                   pwr_qacceptn_o,
  output wire                   pwr_qdeny_o,

  output wire [NUM_Q_CHL-1:0]   clk_qreqn_o,
  input  wire [NUM_Q_CHL-1:0]   clk_qacceptn_i,
  input  wire [NUM_Q_CHL-1:0]   clk_qdeny_i,
  input  wire [NUM_QACTIVE-1:0] clk_qactive_i,

  input  wire                   clk_force_i,

  input  wire [7:0]             entry_delay_i,

  output wire                   clk_en_o,

  output wire                   int_clk_en_o

);

localparam ALL_STOPPED  = 4'h0;
localparam PWR_STOPPED  = 4'h1;
localparam HC_STOPPED   = 4'h2;
localparam CLK_STOPPED  = 4'h3;
localparam CLK_EXIT     = 4'h4;
localparam CLK_RUN      = 4'h5;
localparam CLK_REQ      = 4'h6;
localparam CLK_CONTINUE = 4'h7;
localparam PWR_REQ      = 4'h8;
localparam PWR_CONTINUE = 4'h9;
localparam PWR_DENIED   = 4'hA;
localparam HC_REQ       = 4'hB;
localparam HC_CONTINUE  = 4'hC;
localparam HC_DENIED    = 4'hD;


  reg  [3:0]                  state;
  reg  [NUM_Q_CHL-1:0]        clk_qreqn_r;
  reg                         pwr_qacceptn_r;
  reg                         pwr_qdeny_r;
  reg                         hc_qacceptn_r;
  reg                         hc_qdeny_r;
  reg                         sm_clk_req;
  reg                         ack_log_clear;

  reg  [3:0]                  nxt_state;
  reg  [NUM_Q_CHL-1:0]        nxt_clk_qreqn;
  reg                         clken;
  reg                         nxt_pwr_qacceptn;
  reg                         nxt_pwr_qdeny;
  reg                         nxt_hc_qacceptn;
  reg                         nxt_hc_qdeny;
  reg                         state_en;

  wire                        clock_active_request;
  wire                        clock_request;
  wire                        clock_release;
  wire                        all_accept_exit;
  wire                        all_accept_entry;
  wire                        cont_exit;
  wire                        clock_entry_deny;
  wire                        hier_req_active_deny;

  reg  [NUM_Q_CHL-1:0]        dev_ack_log_r;
  wire [NUM_Q_CHL-1:0]        nxt_dev_ack_log;

  reg  [7:0]                  entry_delay_counter_r;
  reg  [7:0]                  nxt_entry_delay_counter;
  wire                        entry_delay_counter_en;
  wire                        entry_delay_dec;
  wire                        entry_delay_expired;
  wire                        entry_delay_reset;

  wire                        clken_int;

  wire                        clk_required;



  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      state          <= ALL_STOPPED;
      clk_qreqn_r    <= {NUM_Q_CHL{1'b0}};
      pwr_qacceptn_r <= 1'b0;
      pwr_qdeny_r    <= 1'b0;
      hc_qacceptn_r  <= 1'b0;
      hc_qdeny_r     <= 1'b0;
    end
    else if(state_en)
    begin
      state          <= nxt_state;
      clk_qreqn_r    <= nxt_clk_qreqn;
      pwr_qacceptn_r <= nxt_pwr_qacceptn;
      pwr_qdeny_r    <= nxt_pwr_qdeny;
      hc_qacceptn_r  <= nxt_hc_qacceptn;
      hc_qdeny_r     <= nxt_hc_qdeny;
    end
  end

  always@*
  begin
    case(state)
    ALL_STOPPED:
    begin
      nxt_state        = (pwr_qreqn_i)?
                         ((hc_qreqn_i)? CLK_STOPPED:HC_STOPPED):PWR_STOPPED;
      state_en         = pwr_qreqn_i | hc_qreqn_i;
      clken            = 1'b0;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b0}};
      nxt_pwr_qacceptn = pwr_qreqn_i;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = hc_qreqn_i;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = pwr_qreqn_i | hc_qreqn_i;
      ack_log_clear    = 1'b0;
    end
    PWR_STOPPED:
    begin
      nxt_state        = (~hc_qreqn_i)? ALL_STOPPED:CLK_STOPPED;
      state_en         = ~hc_qreqn_i | pwr_qreqn_i;
      clken            = 1'b0;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b0}};
      nxt_pwr_qacceptn = pwr_qreqn_i & hc_qreqn_i;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = hc_qreqn_i;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = ~hc_qreqn_i | pwr_qreqn_i;
      ack_log_clear    = 1'b0;
    end
    HC_STOPPED:
    begin
      nxt_state        = (~pwr_qreqn_i)? ALL_STOPPED:CLK_STOPPED;
      state_en         = ~pwr_qreqn_i | hc_qreqn_i;
      clken            = 1'b0;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b0}};
      nxt_pwr_qacceptn = pwr_qreqn_i;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = hc_qreqn_i & pwr_qreqn_i;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = ~pwr_qreqn_i | hc_qreqn_i;
      ack_log_clear    = 1'b0;
    end
    CLK_STOPPED:
    begin
      nxt_state        = (~pwr_qreqn_i & ~hc_qreqn_i)? ALL_STOPPED:
                         ((~pwr_qreqn_i)? PWR_STOPPED:
                         ((~hc_qreqn_i)? HC_STOPPED:CLK_EXIT));
      state_en         = ~pwr_qreqn_i | ~hc_qreqn_i | clock_request;
      clken            = pwr_qreqn_i & hc_qreqn_i & clock_request;
      nxt_clk_qreqn    = {NUM_Q_CHL{pwr_qreqn_i & hc_qreqn_i & clock_request}};
      nxt_pwr_qacceptn = pwr_qreqn_i;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = hc_qreqn_i;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = ~pwr_qreqn_i | ~hc_qreqn_i | clock_request;
      ack_log_clear    = 1'b0;
    end
    CLK_EXIT:
    begin
      nxt_state        = CLK_RUN;
      state_en         = all_accept_exit;
      clken            = 1'b1;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b1}};
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    CLK_RUN:
    begin
      nxt_state        = (clock_release)? CLK_REQ:
                         ((~hc_qreqn_i)?
                         ((hier_req_active_deny)? HC_DENIED:HC_REQ):
                         ((hier_req_active_deny)? PWR_DENIED:PWR_REQ));
      state_en         = ~pwr_qreqn_i | ~hc_qreqn_i | clock_release;
      clken            = 1'b1;
      nxt_clk_qreqn    = {NUM_Q_CHL{hier_req_active_deny}};
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = (~clock_release & hc_qreqn_i & hier_req_active_deny);
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = (~clock_release & ~hc_qreqn_i & hier_req_active_deny);
      sm_clk_req       = ~pwr_qreqn_i | ~hc_qreqn_i | clock_release;
      ack_log_clear    = 1'b0;
    end
    CLK_REQ:
    begin
      nxt_state        = (clock_entry_deny | clk_force_i)? CLK_CONTINUE:CLK_STOPPED;
      state_en         = clock_entry_deny | all_accept_entry | clk_force_i;
      clken            = clock_entry_deny | clk_force_i | ~all_accept_entry;
      nxt_clk_qreqn    = {NUM_Q_CHL{(clock_entry_deny | clk_force_i)}} &
                         (~clk_qacceptn_i | clk_qdeny_i);
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = clock_entry_deny | clk_force_i;
    end
    CLK_CONTINUE:
    begin
      nxt_state        = (cont_exit)? CLK_RUN:CLK_CONTINUE;
      state_en         = 1'b1;
      clken            = 1'b1;
      nxt_clk_qreqn    = nxt_dev_ack_log;
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    PWR_REQ:
    begin
      nxt_state        = (clock_entry_deny)? PWR_CONTINUE:PWR_STOPPED;
      state_en         = clock_entry_deny | all_accept_entry;
      clken            = clock_entry_deny | ~all_accept_entry;
      nxt_clk_qreqn    = {NUM_Q_CHL{clock_entry_deny}} & (~clk_qacceptn_i |
                                                           clk_qdeny_i);
      nxt_pwr_qacceptn = clock_entry_deny;
      nxt_pwr_qdeny    = clock_entry_deny;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = clock_entry_deny;
    end
    PWR_CONTINUE:
    begin
      nxt_state        = (cont_exit & pwr_qreqn_i)? CLK_RUN:PWR_CONTINUE;
      state_en         = 1'b1;
      clken            = 1'b1;
      nxt_clk_qreqn    = nxt_dev_ack_log;
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = ~(cont_exit & pwr_qreqn_i);
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    PWR_DENIED:
    begin
      nxt_state        = CLK_RUN;
      state_en         = pwr_qreqn_i;
      clken            = 1'b1;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b1}};
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    HC_REQ:
    begin
      nxt_state        = (clock_entry_deny)? HC_CONTINUE:HC_STOPPED;
      state_en         = clock_entry_deny | all_accept_entry;
      clken            = clock_entry_deny | ~all_accept_entry;
      nxt_clk_qreqn    = {NUM_Q_CHL{clock_entry_deny}} & (~clk_qacceptn_i |
                                                           clk_qdeny_i);
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = clock_entry_deny;
      nxt_hc_qdeny     = clock_entry_deny;
      sm_clk_req       = 1'b1;
      ack_log_clear    = clock_entry_deny;
    end
    HC_CONTINUE:
    begin
      nxt_state        = (cont_exit & hc_qreqn_i)? CLK_RUN:HC_CONTINUE;
      state_en         = 1'b1;
      clken            = 1'b1;
      nxt_clk_qreqn    = nxt_dev_ack_log;
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = ~(cont_exit & hc_qreqn_i);
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    HC_DENIED:
    begin
      nxt_state        = CLK_RUN;
      state_en         = hc_qreqn_i;
      clken            = 1'b1;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'b1}};
      nxt_pwr_qacceptn = 1'b1;
      nxt_pwr_qdeny    = 1'b0;
      nxt_hc_qacceptn  = 1'b1;
      nxt_hc_qdeny     = 1'b0;
      sm_clk_req       = 1'b1;
      ack_log_clear    = 1'b0;
    end
    default:
    begin
      nxt_state        = 4'hx;
      state_en         = 1'bx;
      clken            = 1'bx;
      nxt_clk_qreqn    = {NUM_Q_CHL{1'bx}};
      nxt_pwr_qacceptn = 1'bx;
      nxt_pwr_qdeny    = 1'bx;
      nxt_hc_qacceptn  = 1'bx;
      nxt_hc_qdeny     = 1'bx;
      sm_clk_req       = 1'bx;
      ack_log_clear    = 1'bx;
    end
    endcase
  end

  assign clock_active_request = (|clk_qactive_i);

  assign clock_request        = clk_force_i | clock_active_request;

  assign clock_release        = (~clk_force_i) & (~clock_active_request) & entry_delay_expired;

  assign all_accept_exit      = (&clk_qacceptn_i);

  assign all_accept_entry     = ~(|clk_qacceptn_i);

generate
if(ACTIVE_DENY_EN == 1)
begin:active_deny_enable

  assign clock_entry_deny     = (|clk_qdeny_i) | (|clk_qactive_i);
  assign hier_req_active_deny = clock_active_request;

end
else
begin:active_deny_disabled

  assign clock_entry_deny     = (|clk_qdeny_i);
  assign hier_req_active_deny = 1'b0;

end
endgenerate

  assign cont_exit = &(clk_qacceptn_i & ~clk_qdeny_i & nxt_dev_ack_log);


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      dev_ack_log_r <= {NUM_Q_CHL{1'b0}};
    end
    else if(state_en)
    begin
      dev_ack_log_r <= nxt_dev_ack_log;
    end
  end

  assign nxt_dev_ack_log = (~clk_qacceptn_i | clk_qdeny_i) |
                           ((ack_log_clear)? {NUM_Q_CHL{1'b0}} :
         dev_ack_log_r);


  always@(posedge clk or negedge reset_n)
  begin
    if(!reset_n)
    begin
      entry_delay_counter_r <= {8{1'b0}};
    end
    else if(entry_delay_counter_en)
    begin
      entry_delay_counter_r <= nxt_entry_delay_counter;
    end
  end

  always@*
  begin
    case({entry_delay_dec, entry_delay_reset})
    2'b00:   nxt_entry_delay_counter = entry_delay_counter_r;
    2'b01:   nxt_entry_delay_counter = entry_delay_i;
    2'b10:   nxt_entry_delay_counter = entry_delay_counter_r - 8'h01;
    2'b11:   nxt_entry_delay_counter = entry_delay_i;
    default: nxt_entry_delay_counter = 8'hxx;
    endcase
  end

  assign entry_delay_reset = (entry_delay_counter_r != entry_delay_i) &
                             ((clock_request & (state == CLK_RUN)) |
                              (nxt_state == CLK_RUN));

  assign entry_delay_counter_en = entry_delay_dec | entry_delay_reset;

  assign entry_delay_dec = ~clk_force_i & ~clock_active_request &
                           (state == CLK_RUN) & ~entry_delay_expired;

  assign entry_delay_expired = ~(|entry_delay_counter_r);


  pck600_std_or2
  u_pck600_or2_clkgen_dftcgen
  (
    .A(clken),
    .B(dftcgen),
    .Y(clken_int)
  );


  assign clk_required = sm_clk_req | entry_delay_reset | entry_delay_dec;


  assign clk_qreqn_o    = clk_qreqn_r;

  assign clk_en_o       = clken_int;

  assign int_clk_en_o   = clk_required;

  assign hc_qacceptn_o  = hc_qacceptn_r;
  assign hc_qdeny_o     = hc_qdeny_r;

  assign pwr_qacceptn_o = pwr_qacceptn_r;
  assign pwr_qdeny_o    = pwr_qdeny_r;

endmodule
