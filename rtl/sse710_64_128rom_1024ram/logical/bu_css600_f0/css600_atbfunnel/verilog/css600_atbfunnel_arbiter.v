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
//   Sub-module of css600_atbfunnel
//
//----------------------------------------------------------------------------


module css600_atbfunnel_arbiter#
  (
    parameter ATB_DATA_WIDTH = 32,
    parameter ATBYTES_WIDTH  = 2,
    parameter NUM_ATB_SLAVES = 8
  )
  (
    clk,
    reset_n,

    atvalid_s,
    afready_s,
    atid_s,
    atdata_s,
    atbytes_s,

    atready_m,
    afvalid_m,
    syncreq_m,

    atvalid_m,
    afready_m,
    atid_m,
    atdata_m,
    atbytes_m,

    atready_s,
    afvalid_s,
    syncreq_s,

    min_hold_time,
    en_port,
    pri_port,
    atwakeup_s,
    atwakeup_m
  );


  input wire         clk;
  input wire         reset_n;

  input wire [NUM_ATB_SLAVES-1:0]                 atvalid_s;
  input wire [NUM_ATB_SLAVES-1:0]                 afready_s;
  input wire [7*NUM_ATB_SLAVES-1:0]                 atid_s;
  input wire [NUM_ATB_SLAVES*ATB_DATA_WIDTH-1:0]  atdata_s;
  input wire [NUM_ATB_SLAVES*ATBYTES_WIDTH-1:0]   atbytes_s;

  input wire                                      atready_m;
  input wire                                      afvalid_m;
  input wire                                      syncreq_m;
  output wire                                     atvalid_m;
  output wire                                     afready_m;
  output wire [6:0]                               atid_m;
  output wire [ATB_DATA_WIDTH-1:0]                atdata_m;
  output wire [ATBYTES_WIDTH-1:0]                 atbytes_m;

  output wire [NUM_ATB_SLAVES-1:0]                atready_s;
  output wire [NUM_ATB_SLAVES-1:0]                afvalid_s;
  output wire [NUM_ATB_SLAVES-1:0]                syncreq_s;

  input  wire [NUM_ATB_SLAVES-1:0]                atwakeup_s;
  output wire                                     atwakeup_m;

  input wire                        [3:0]  min_hold_time;


  input wire [NUM_ATB_SLAVES-1:0]   en_port;
  input wire [3*NUM_ATB_SLAVES-1:0] pri_port;

  wire          ctr_sel_1;
  wire          ctr_sel_2;
  wire          ctr_sel_3;
  wire          hold_time_rst;
  wire          funnel_flush;
  wire          switch_allowed;
  wire          sel_port_unchanged;

  wire [NUM_ATB_SLAVES-1:0] set_port;
  wire [NUM_ATB_SLAVES-1:0] sel_port;
  reg  [NUM_ATB_SLAVES-1:0] sel_port_reg;
  wire [NUM_ATB_SLAVES-1:0] val_port;
  wire [NUM_ATB_SLAVES-1:0] next_fl_port;
  wire [NUM_ATB_SLAVES-1:0] fl_port_en;
  reg  [NUM_ATB_SLAVES-1:0] fl_port;
  wire [NUM_ATB_SLAVES-1:0] fl_ack;
  wire [5*NUM_ATB_SLAVES-1:0] e_pri_port;
  wire [NUM_ATB_SLAVES-1:0] port_flsed;
  wire [NUM_ATB_SLAVES-1:0] iafvalids;


  wire comp [NUM_ATB_SLAVES-2:0][NUM_ATB_SLAVES-1:1];
  wire eq_pri [NUM_ATB_SLAVES-2:0][NUM_ATB_SLAVES-1:1];


  wire  [NUM_ATB_SLAVES-1:0] next_bws_mask;
  wire  [NUM_ATB_SLAVES-1:0] clr_bws_mask;
  wire  [NUM_ATB_SLAVES-1:0] bws_mask_ctrl;
  reg   [NUM_ATB_SLAVES-1:0] bws_mask;

  wire          atid_changed;

  wire  [ATB_DATA_WIDTH-1 :0] iatdata_m;
  reg           atvalidm_reg;
  reg           atreadym_reg;
  reg [3:0]     next_hold_ctr;
  reg [3:0]     hold_ctr;

  reg [6:0]     atidm_reg;

  wire [6:0]    iatid_m;
  wire          iafvalidm;
  wire          iatreadym;
  wire          iatvalidm;

  wire  [ATBYTES_WIDTH-1:0]        iatbytes_m;

  reg           rst_state;
  reg           iatwakeup_m;


  genvar a;
  generate
  for (a=0; a< NUM_ATB_SLAVES; a=a+1) begin: e_pri_port_assign
    assign e_pri_port[a*5 +: 5] = {port_flsed[a], pri_port[a*3 +: 3], bws_mask[a]};
  end
  endgenerate


  genvar b,c;
  generate
  for (b=0; b< NUM_ATB_SLAVES; b=b+1) begin: comp_val_set_port_assign

      assign val_port[b] = en_port[b] & atvalid_s[b];

      for (c=0; c< NUM_ATB_SLAVES-1; c=c+1) begin: comp_set_port_assign
        if (b>c) begin: comp_b_larger_c
          assign comp[c][b] = e_pri_port[c*5 +: 5] > e_pri_port[b*5 +: 5];
        end
        else if (b > 0) begin: comp_else
          assign comp[c][b] = 1'b0;
        end
      end
  end
  endgenerate


  genvar main,run1;
  generate
  for (main=0; main< NUM_ATB_SLAVES; main=main+1) begin: set_port_assign

    wire [NUM_ATB_SLAVES-1 : 0] tmp_set_port_pre;

    for (run1=0; run1< NUM_ATB_SLAVES; run1=run1+1) begin:  tmp_set_port
      if (run1 < main)
      begin: ports_with_lower_idx_higher_prio
        assign tmp_set_port_pre[run1] = ~(val_port[run1] & ~comp[run1][main]);
      end

      else if (run1 == main)
      begin: current_port
        assign tmp_set_port_pre[run1] = (val_port[run1] & switch_allowed);
      end

      else if (run1 > main)
      begin: ports_with_higher_idx_higher_prio
        assign tmp_set_port_pre[run1] = ~(val_port[run1] & comp[main][run1]);
      end
    end

    assign set_port[main] = &(tmp_set_port_pre);
  end
  endgenerate


  genvar d;
  generate
  for (d=0; d< NUM_ATB_SLAVES; d=d+1) begin: sel_port_assign
    assign sel_port[d] = set_port[d] | (sel_port_reg[d] & ~switch_allowed);
  end
  endgenerate


  genvar e;
  generate
  for (e=0; e< NUM_ATB_SLAVES; e=e+1) begin: next_bws_mask_assign
    assign next_bws_mask[e] = set_port[e] | (bws_mask[e] & en_port[e] & ~clr_bws_mask[e]);
  end
  endgenerate


  genvar f;
  generate
  for (f=0; f< NUM_ATB_SLAVES; f=f+1) begin: bws_mask_always

    always @(posedge clk or negedge reset_n)
      begin : p_bws_mask
        if(!reset_n)
          begin
            bws_mask[f] <= 1'b0;
          end
        else if (iatvalidm)
          begin
            bws_mask[f] <= next_bws_mask[f];
          end
      end
  end
  endgenerate


  genvar g;
  generate
  for (g=0; g< NUM_ATB_SLAVES; g=g+1) begin: bws_mask_ctrl_assign
    assign bws_mask_ctrl[g] = bws_mask[g] & set_port[g];
  end
  endgenerate


  genvar h,i;
  generate
  for (h=1; h< NUM_ATB_SLAVES; h=h+1) begin: eq_pri_assign
    for (i=0; i< NUM_ATB_SLAVES-1; i=i+1) begin: eq_pri_int
      if (i < h) begin: eq_pri_first_idx_smaller
        assign eq_pri[i][h] = (pri_port[i*3 +: 3] == pri_port[h*3 +: 3]);
      end
      else begin: eq_pri_else
        assign eq_pri[i][h] = 1'b0;
      end
    end
  end
  endgenerate


  genvar j, k;
  generate
  for (j=0; j< NUM_ATB_SLAVES; j=j+1) begin: clr_bws_mask_assign

    wire [NUM_ATB_SLAVES-1:0] tmp_clr_bws;

    for (k=0; k< NUM_ATB_SLAVES; k=k+1) begin: bandwidth_clr
      if (j>k) begin: bandwidth_clr_1
        assign tmp_clr_bws[k] = (eq_pri[k][j] & bws_mask_ctrl[k]);
      end
      else if (k>j) begin: bandwidth_clr_2
        assign tmp_clr_bws[k] = (eq_pri[j][k] & bws_mask_ctrl[k]);
      end
      else begin: bandwidth_clr_3
        assign tmp_clr_bws[k] = 1'b0;
      end
    end

    assign clr_bws_mask[j] = |(tmp_clr_bws);
  end
  endgenerate


  genvar l;
  generate
  for (l=0; l< NUM_ATB_SLAVES; l=l+1) begin: atready_assign
    assign atready_s[l] = ((iatreadym & sel_port[l]) | ~en_port[l]) & ~rst_state;
  end
  endgenerate

  genvar m;
  generate
  for (m=0; m< NUM_ATB_SLAVES; m=m+1) begin: sel_port_reg_always

    always @(posedge clk or negedge reset_n)
      begin : p_sel_port
        if(!reset_n)
          begin
            sel_port_reg[m] <= 1'b0;
          end
        else
          begin
            sel_port_reg[m] <= sel_port[m];
          end
      end
  end
  endgenerate

  assign switch_allowed = (hold_time_rst & atreadym_reg)  |
                         ((hold_ctr == 4'b0000) &
                          ((atreadym_reg & atvalidm_reg) | ~atvalidm_reg)) |
                         atid_changed;


  genvar n;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_hold;

    for (n=0; n< NUM_ATB_SLAVES; n=n+1) begin: hold_time_rst_assign
      assign tmp_hold[n] = (sel_port_reg[n] & (~val_port[n] | (iafvalids[n] & afready_s[n])));
    end

    assign hold_time_rst = |(tmp_hold);
  endgenerate


  genvar o;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_atid_changed;

    for (o=0; o< NUM_ATB_SLAVES; o=o+1) begin: atid_changed_assign
      assign tmp_atid_changed[o] = (sel_port_reg[o] & (atid_s[7*o +:7] != atidm_reg) & atvalid_s[o]);
    end

    assign atid_changed = |(tmp_atid_changed);
  endgenerate


  genvar p;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_sel_port_unchanged;

    for (p=0; p< NUM_ATB_SLAVES; p=p+1) begin: sel_port_unchanged_assign
      assign tmp_sel_port_unchanged[p] = (sel_port[p] & sel_port_reg[p]);
    end

    assign sel_port_unchanged = |(tmp_sel_port_unchanged);
  endgenerate


  assign ctr_sel_1 = sel_port_unchanged | ~|(sel_port);

  assign ctr_sel_2 = ~(iatreadym & iatvalidm);
  assign ctr_sel_3 = (hold_ctr != 4'b0000);

  always @*
    begin : p_next_hold_ctr
      case(ctr_sel_1)
        1'b0 : next_hold_ctr = min_hold_time + {3'b000,ctr_sel_2};
        1'b1 :
          case(ctr_sel_2)
            1'b0    : next_hold_ctr = ({4{ctr_sel_3}} & (hold_ctr - 4'b0001));
            1'b1    : next_hold_ctr = {4{iatvalidm}} & hold_ctr;
            default : next_hold_ctr = 4'bxxxx;
          endcase
        default : next_hold_ctr = 4'bxxxx;
      endcase
    end

  always @(posedge clk or negedge reset_n)
    begin : p_hold_ctr
      if(!reset_n)
        hold_ctr  <= {4{1'b0}};
      else
        hold_ctr  <= next_hold_ctr;
    end

  always @(posedge clk or negedge reset_n)
    begin : p_atreadym_reg
      if(!reset_n)
        begin
          atreadym_reg <= 1'b0;
          atvalidm_reg <= 1'b0;
        end
      else
        begin
          atreadym_reg <= iatreadym;
          atvalidm_reg <= iatvalidm;
        end
    end

  always @(posedge clk or negedge reset_n)
    begin : p_atid
      if(!reset_n)
        atidm_reg <= 7'b0000000;
      else if (iatvalidm)
        atidm_reg <= iatid_m;
    end


  always @(posedge clk or negedge reset_n)
    begin : p_iatwakeup_m
      if(!reset_n)
        begin
          iatwakeup_m <= 1'b0;
        end
      else
        begin
          iatwakeup_m <= |(atwakeup_s);
        end
    end

  assign atwakeup_m = iatwakeup_m;

  genvar q;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_iatvalidm;

    for (q=0; q< NUM_ATB_SLAVES; q=q+1) begin: iatvalidm_assign
      assign tmp_iatvalidm[q] = (sel_port[q] & atvalid_s[q]);
    end

    assign iatvalidm = |(tmp_iatvalidm);
  endgenerate

  assign atvalid_m =  iatvalidm;


  assign iafvalidm = afvalid_m;

  genvar u;
  generate

 if (NUM_ATB_SLAVES == 1) begin: slave_num_1
    assign iatdata_m = ({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]);
    assign iatid_m = ({7{sel_port[0]}} & atid_s[0*7 +: 7]);
    assign iatbytes_m = ({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]);
 end

  if (NUM_ATB_SLAVES == 2) begin: slave_num_2
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end


  if (NUM_ATB_SLAVES == 3) begin: slave_num_3
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 4) begin: slave_num_4
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{sel_port[3]}} & atid_s[3*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 5) begin: slave_num_5
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{sel_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{sel_port[4]}} & atid_s[4*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 6) begin: slave_num_6
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{sel_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{sel_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{sel_port[5]}} & atid_s[5*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 7) begin: slave_num_7
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[6]}} & atdata_s[6*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{sel_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{sel_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{sel_port[5]}} & atid_s[5*7 +: 7]) |
                    ({7{sel_port[6]}} & atid_s[6*7 +: 7]));

    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[6]}} & atbytes_s[6*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 8) begin: slave_num_8
    assign iatdata_m = (({ATB_DATA_WIDTH{sel_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[6]}} & atdata_s[6*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{sel_port[7]}} & atdata_s[7*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_m = (({7{sel_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{sel_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{sel_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{sel_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{sel_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{sel_port[5]}} & atid_s[5*7 +: 7]) |
                    ({7{sel_port[6]}} & atid_s[6*7 +: 7]) |
                    ({7{sel_port[7]}} & atid_s[7*7 +: 7]));


    assign iatbytes_m = (({ATBYTES_WIDTH{sel_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[6]}} & atbytes_s[6*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{sel_port[7]}} & atbytes_s[7*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  endgenerate


  assign atbytes_m = iatbytes_m;
  assign atdata_m = iatdata_m;
  assign atid_m = iatid_m;

  genvar v;
  generate
  for (v=0; v< NUM_ATB_SLAVES; v=v+1) begin: valid_assigns
    assign iafvalids[v] = ~fl_port[v]  & iafvalidm & en_port[v];
    assign afvalid_s[v] = iafvalids[v];
  end
  endgenerate


  genvar w;
  generate
  for (w=0; w< NUM_ATB_SLAVES; w=w+1) begin: fl_port_assign

    assign next_fl_port[w] = ~(funnel_flush);
    assign fl_port_en[w] = ((iafvalidm & (afready_s[w] | ~en_port[w])) | funnel_flush);
    assign port_flsed[w] = fl_port[w] | (iafvalids[w] & afready_s[w]);
    always @(posedge clk or negedge reset_n)
      begin : p_fl_port
        if(!reset_n)
          fl_port[w] <= 1'b0;
        else
          if(fl_port_en[w])
            fl_port[w] <= next_fl_port[w];
      end
  end
  endgenerate


  genvar x;
  generate
    for (x=0; x< NUM_ATB_SLAVES; x=x+1) begin: fl_ack_assign
      assign fl_ack[x] = iafvalidm & (afready_s[x] | ~en_port[x]);
    end
  endgenerate


  genvar y;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_funnel_flush;
    wire [NUM_ATB_SLAVES-1:0] tmp_flush_atvalid;

    for (y=0; y< NUM_ATB_SLAVES; y=y+1) begin: funnel_flush_assign
      assign tmp_funnel_flush[y] = (fl_port[y]  | fl_ack[y] );
      assign tmp_flush_atvalid[y] = (sel_port[y] & atvalid_s[y]) & ~tmp_funnel_flush[y];
    end

    assign funnel_flush = &(tmp_funnel_flush) & ((iatvalidm & iatreadym) | ~(|tmp_flush_atvalid));
  endgenerate


  always @(posedge clk or negedge reset_n)
    begin : p_rst_state
      if (!reset_n)
        rst_state <= 1'b1;
      else
        rst_state <= 1'b0;
    end


  assign iatreadym = atready_m;
  assign afready_m = rst_state | funnel_flush;


  genvar z;
  generate
    for (z=0; z< NUM_ATB_SLAVES; z=z+1) begin: syncreq_assigns
      assign syncreq_s[z] = en_port[z] & syncreq_m;
    end
  endgenerate


endmodule
