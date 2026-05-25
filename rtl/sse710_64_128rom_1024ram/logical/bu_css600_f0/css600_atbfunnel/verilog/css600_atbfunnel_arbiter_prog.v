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


module css600_atbfunnel_arbiter_prog #
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

    syncreq_apb,
    syncreq_reg,

    min_hold_time,
    fl_normal,
    en_port,
    pri_port,
    atwakeup_s,
    atwakeup_m,

    itc_reg,
    it_atb_data_0_wr_reg,
    it_atb_ctr_0_wr_reg,
    it_atb_ctr_1_wr_reg,
    it_atb_ctr_2_wr_reg,

    it_atb_data_0_rd_reg,
    it_atb_ctr_1_rd_reg,
    it_atb_ctr_2_rd_reg,
    it_atb_ctr_0_rd_reg
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
  input wire                                      syncreq_apb;
  output wire                                     atvalid_m;
  output wire                                     afready_m;
  output wire [6:0]                               atid_m;
  output wire [ATB_DATA_WIDTH-1:0]                atdata_m;
  output wire [ATBYTES_WIDTH-1:0]                 atbytes_m;

  output wire [NUM_ATB_SLAVES-1:0]                atready_s;
  output wire [NUM_ATB_SLAVES-1:0]                afvalid_s;
  output wire [NUM_ATB_SLAVES-1:0]                syncreq_s;
  output wire                                     syncreq_reg;

  input  wire [NUM_ATB_SLAVES-1:0]                atwakeup_s;
  output wire                                     atwakeup_m;


  input wire                        [3:0]  min_hold_time;
  input wire                               fl_normal;


  input wire [NUM_ATB_SLAVES-1:0]   en_port;
  input wire [3*NUM_ATB_SLAVES-1:0] pri_port;

  input wire [ATB_DATA_WIDTH/8:0]  it_atb_data_0_wr_reg;

  output wire [ATB_DATA_WIDTH/8:0] it_atb_data_0_rd_reg;

  input wire  itc_reg;
  input wire  [1:0]  it_atb_ctr_2_wr_reg;
  input wire  [6:0]  it_atb_ctr_1_wr_reg;
  input wire  [3:0]  it_atb_ctr_0_wr_reg;

  output wire [1:0]   it_atb_ctr_2_rd_reg;
  output wire [6:0]   it_atb_ctr_1_rd_reg;
  output wire [3:0]   it_atb_ctr_0_rd_reg;

  wire          ctr_sel_1;
  wire          ctr_sel_2;
  wire          ctr_sel_3;
  wire          hold_time_rst;
  wire          funnel_flush;
  wire          switch_allowed;
  wire          sel_port_unchanged;

  wire [NUM_ATB_SLAVES-1 : 0] flush_ended;
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

  reg           itc_reg_del;
  wire          it_mode_start;
  wire  [ATB_DATA_WIDTH-1 :0] it_atdatam;

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

  reg           syncreq_q;
  reg           rst_state;
  reg           iatwakeup_m;

  wire [ATB_DATA_WIDTH-1 :0] iatdata_intreg;
  wire [ATBYTES_WIDTH-1:0]   iatbytes_intreg;
  wire [6:0]                 iatid_intreg;


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
        assign tmp_set_port_pre[run1] = ~ ( (val_port[run1] & ~comp[run1][main]) & (~fl_normal | ~fl_port[run1]) );
      end

      else if (run1 == main)
      begin: current_port
        assign tmp_set_port_pre[run1] = val_port[main] & switch_allowed & (~fl_normal | ~fl_port[main]);
      end

      else if (run1 > main)
      begin: ports_with_higher_idx_higher_prio
        assign tmp_set_port_pre[run1] = ~( (val_port[run1] & comp[main][run1]) & (~fl_normal | ~fl_port[run1]) ) ;
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
      if (i < h) begin: ports_larger_indx_pri
        assign eq_pri[i][h] = (pri_port[i*3 +: 3] == pri_port[h*3 +: 3]);
      end
      else begin: pri_else
        assign eq_pri[i][h] = 1'b0;
      end
    end
  end
  endgenerate


  genvar j, k;
  generate
  for (j=0; j< NUM_ATB_SLAVES; j=j+1) begin: clr_bws_mask_assign

    wire [NUM_ATB_SLAVES-1:0] tmp_clr_bws;

    for (k=0; k< NUM_ATB_SLAVES; k=k+1) begin: tmp_clr_bws_calc
      if (j>k) begin: bandwidth_clr_1
        assign tmp_clr_bws[k] = (eq_pri[k][j] & bws_mask_ctrl[k]);
      end
      else if (j<k) begin: bandwidth_clr_2
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
    assign atready_s[l] = ((iatreadym & (sel_port[l] | itc_reg)) | ~en_port[l]) & ~rst_state;
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


  assign flush_ended = (sel_port_reg & fl_port);

  assign switch_allowed = (hold_time_rst & atreadym_reg)  |
                         ((hold_ctr == 4'b0000) &
                          ((atreadym_reg & atvalidm_reg) | ~atvalidm_reg)) |
                         atid_changed | (fl_normal & |(flush_ended) & atreadym_reg);


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
    begin : p_atwakeup_m
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

  assign atvalid_m = itc_reg ? it_atb_ctr_0_wr_reg[0] : iatvalidm;
  assign it_atb_ctr_0_rd_reg[0] = iatvalidm;


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


 if (NUM_ATB_SLAVES == 1) begin: slave_num_1_integration
    assign iatdata_intreg = ({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]);
    assign iatid_intreg = ({7{en_port[0]}} & atid_s[0*7 +: 7]);
    assign iatbytes_intreg = ({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]);
 end

  if (NUM_ATB_SLAVES == 2) begin: slave_num_2_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end


  if (NUM_ATB_SLAVES == 3) begin: slave_num_3_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 4) begin: slave_num_4_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{en_port[3]}} & atid_s[3*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 5) begin: slave_num_5_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{en_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{en_port[4]}} & atid_s[4*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 6) begin: slave_num_6_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{en_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{en_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{en_port[5]}} & atid_s[5*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 7) begin: slave_num_7_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[6]}} & atdata_s[6*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{en_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{en_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{en_port[5]}} & atid_s[5*7 +: 7]) |
                    ({7{en_port[6]}} & atid_s[6*7 +: 7]));

    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[6]}} & atbytes_s[6*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  if (NUM_ATB_SLAVES == 8) begin: slave_num_8_integration
    assign iatdata_intreg = (({ATB_DATA_WIDTH{en_port[0]}} & atdata_s[0*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[1]}} & atdata_s[1*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[2]}} & atdata_s[2*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[3]}} & atdata_s[3*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[4]}} & atdata_s[4*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[5]}} & atdata_s[5*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[6]}} & atdata_s[6*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]) |
                    ({ATB_DATA_WIDTH{en_port[7]}} & atdata_s[7*ATB_DATA_WIDTH +: ATB_DATA_WIDTH]));

    assign iatid_intreg = (({7{en_port[0]}} & atid_s[0*7 +: 7]) |
                    ({7{en_port[1]}} & atid_s[1*7 +: 7]) |
                    ({7{en_port[2]}} & atid_s[2*7 +: 7]) |
                    ({7{en_port[3]}} & atid_s[3*7 +: 7]) |
                    ({7{en_port[4]}} & atid_s[4*7 +: 7]) |
                    ({7{en_port[5]}} & atid_s[5*7 +: 7]) |
                    ({7{en_port[6]}} & atid_s[6*7 +: 7]) |
                    ({7{en_port[7]}} & atid_s[7*7 +: 7]));


    assign iatbytes_intreg = (({ATBYTES_WIDTH{en_port[0]}} & atbytes_s[0*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[1]}} & atbytes_s[1*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[2]}} & atbytes_s[2*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[3]}} & atbytes_s[3*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[4]}} & atbytes_s[4*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[5]}} & atbytes_s[5*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[6]}} & atbytes_s[6*ATBYTES_WIDTH +: ATBYTES_WIDTH]) |
                    ({ATBYTES_WIDTH{en_port[7]}} & atbytes_s[7*ATBYTES_WIDTH +: ATBYTES_WIDTH]));
  end

  endgenerate


  generate
  if (ATBYTES_WIDTH > 2) begin: atbytes_intmode_gt_2
    assign atbytes_m = itc_reg ? { {(ATBYTES_WIDTH-2){1'b0}}, it_atb_ctr_0_wr_reg[3:2]} : iatbytes_m;
  end
  else if (ATBYTES_WIDTH == 2) begin: atbytes_intmode_eq_2
    assign atbytes_m = itc_reg ? it_atb_ctr_0_wr_reg[3:2] : iatbytes_m;
  end
  else begin: atbytes_intmode_lt_2
    assign atbytes_m = itc_reg ? it_atb_ctr_0_wr_reg[2] : iatbytes_m;
  end

  if (ATBYTES_WIDTH > 1) begin: ctr_reg_assign_larger_than_16_bits_data
    assign it_atb_ctr_0_rd_reg[3:2] = iatbytes_intreg[1:0];
  end
  else begin: ctr_reg_assign_larger_than_16_bits_data
    assign it_atb_ctr_0_rd_reg[3:2] = {1'b0, iatbytes_intreg};
  end
  endgenerate

  assign atid_m = itc_reg ? it_atb_ctr_1_wr_reg : iatid_m;
  assign it_atb_ctr_1_rd_reg = iatid_intreg;

  generate

  if (ATB_DATA_WIDTH > 64) begin: it_datam_64
    assign it_atdatam = {it_atb_data_0_wr_reg[16],iatdata_m[126:120],
                        it_atb_data_0_wr_reg[15],iatdata_m[118:112],
                        it_atb_data_0_wr_reg[14],iatdata_m[110:104],
                        it_atb_data_0_wr_reg[13],iatdata_m[102:96],
                        it_atb_data_0_wr_reg[12],iatdata_m[94:88],
                        it_atb_data_0_wr_reg[11],iatdata_m[86:80],
                        it_atb_data_0_wr_reg[10],iatdata_m[78:72],
                        it_atb_data_0_wr_reg[9],iatdata_m[70:64],
                        it_atb_data_0_wr_reg[8],iatdata_m[62:56],
                        it_atb_data_0_wr_reg[7],iatdata_m[54:48],
                        it_atb_data_0_wr_reg[6],iatdata_m[46:40],
                        it_atb_data_0_wr_reg[5],iatdata_m[38:32],
                        it_atb_data_0_wr_reg[4],iatdata_m[30:24],
                        it_atb_data_0_wr_reg[3],iatdata_m[22:16],
                        it_atb_data_0_wr_reg[2],iatdata_m[14:8],
                        it_atb_data_0_wr_reg[1],iatdata_m[6:1],it_atb_data_0_wr_reg[0]};
  end

  else if (ATB_DATA_WIDTH > 32) begin: it_datam_32
    assign it_atdatam = {it_atb_data_0_wr_reg[8],iatdata_m[62:56],
                        it_atb_data_0_wr_reg[7],iatdata_m[54:48],
                        it_atb_data_0_wr_reg[6],iatdata_m[46:40],
                        it_atb_data_0_wr_reg[5],iatdata_m[38:32],
                        it_atb_data_0_wr_reg[4],iatdata_m[30:24],
                        it_atb_data_0_wr_reg[3],iatdata_m[22:16],
                        it_atb_data_0_wr_reg[2],iatdata_m[14:8],
                        it_atb_data_0_wr_reg[1],iatdata_m[6:1],it_atb_data_0_wr_reg[0]};
  end

  else if (ATB_DATA_WIDTH > 16) begin: it_datam_16
    assign it_atdatam = {it_atb_data_0_wr_reg[4],iatdata_m[30:24],
                        it_atb_data_0_wr_reg[3],iatdata_m[22:16],
                        it_atb_data_0_wr_reg[2],iatdata_m[14:8],
                        it_atb_data_0_wr_reg[1],iatdata_m[6:1],it_atb_data_0_wr_reg[0]};
  end

  else if (ATB_DATA_WIDTH > 8) begin: it_datam_8
    assign it_atdatam = {it_atb_data_0_wr_reg[2],iatdata_m[14:8],
                        it_atb_data_0_wr_reg[1],iatdata_m[6:1],it_atb_data_0_wr_reg[0]};
  end

  else if (ATB_DATA_WIDTH == 8) begin: it_datam_eq_8
    assign it_atdatam = {it_atb_data_0_wr_reg[1],iatdata_m[6:1],it_atb_data_0_wr_reg[0]};
  end

  endgenerate

  assign atdata_m = itc_reg ? it_atdatam : iatdata_m;

generate

  if (ATB_DATA_WIDTH > 64) begin: it_atb_data_64
    assign it_atb_data_0_rd_reg = {iatdata_intreg [127],
                                 iatdata_intreg [119],
                                 iatdata_intreg [111],
                                 iatdata_intreg [103],
                                 iatdata_intreg [95],
                                 iatdata_intreg [87],
                                 iatdata_intreg [79],
                                 iatdata_intreg [71],
                                 iatdata_intreg [63],
                                 iatdata_intreg [55],
                                 iatdata_intreg [47],
                                 iatdata_intreg [39],
                                 iatdata_intreg [31],
                                 iatdata_intreg [23],
                                 iatdata_intreg [15],
                                 iatdata_intreg [7],
                                 iatdata_intreg [0]};
  end

  else if (ATB_DATA_WIDTH > 32) begin: it_atb_data_32
    assign it_atb_data_0_rd_reg = {iatdata_intreg [63],
                                 iatdata_intreg [55],
                                 iatdata_intreg [47],
                                 iatdata_intreg [39],
                                 iatdata_intreg [31],
                                 iatdata_intreg [23],
                                 iatdata_intreg [15],
                                 iatdata_intreg [7],
                                 iatdata_intreg [0]};

  end

  else if (ATB_DATA_WIDTH > 16) begin: it_atb_data_16
    assign it_atb_data_0_rd_reg = {iatdata_intreg [31],
                                 iatdata_intreg [23],
                                 iatdata_intreg [15],
                                 iatdata_intreg [7],
                                 iatdata_intreg [0]};
  end

  else if (ATB_DATA_WIDTH > 8) begin: it_atb_data_8
    assign it_atb_data_0_rd_reg = {iatdata_intreg [15],
                                 iatdata_intreg [7],
                                 iatdata_intreg [0]};
  end

  else if (ATB_DATA_WIDTH == 8) begin: it_atb_data_eq_8
    assign it_atb_data_0_rd_reg = {iatdata_intreg [7],
                                 iatdata_intreg [0]};
  end

  endgenerate

  assign it_atb_ctr_2_rd_reg[1] = afvalid_m;
  assign iafvalidm = itc_reg ? it_atb_ctr_2_wr_reg[1] : afvalid_m;


  genvar v;
  generate
  for (v=0; v< NUM_ATB_SLAVES; v=v+1) begin: valid_assigns
    assign iafvalids[v] = ~fl_port[v]  & iafvalidm & en_port[v];
    assign afvalid_s[v] = iafvalids[v];
  end
  endgenerate

  always @(posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        itc_reg_del <= 1'b0;
      else
        itc_reg_del <= itc_reg;
    end

  assign it_mode_start = itc_reg & ~itc_reg_del;


  genvar w;
  generate
  for (w=0; w< NUM_ATB_SLAVES; w=w+1) begin: fl_port_assign

    assign next_fl_port[w] = ~(funnel_flush | itc_reg);
    assign fl_port_en[w] = ((iafvalidm & (afready_s[w] | ~en_port[w])) | funnel_flush | it_mode_start);
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
    for (x=0; x< NUM_ATB_SLAVES; x=x+1) begin: fl_ack_assigns
      assign fl_ack[x] = iafvalidm & (afready_s[x] | ~en_port[x]);
    end
  endgenerate


  genvar y;
  generate

    wire [NUM_ATB_SLAVES-1:0] tmp_funnel_flush;
    wire [NUM_ATB_SLAVES-1:0] tmp_flush_atvalid;
    wire [NUM_ATB_SLAVES-1:0] tmp_funnel_flush_itc;

    for (y=0; y< NUM_ATB_SLAVES; y=y+1) begin: funnel_flush_assign
      assign tmp_funnel_flush[y] = fl_port[y]  | fl_ack[y];
      assign tmp_flush_atvalid[y] = (sel_port[y] & atvalid_s[y]) & ~tmp_funnel_flush[y];
      assign tmp_funnel_flush_itc[y] = afready_s[y] & en_port[y];
    end

    assign funnel_flush = itc_reg ? |(tmp_funnel_flush_itc) :  (&(tmp_funnel_flush) & ((iatvalidm & iatreadym) | ~(|tmp_flush_atvalid)));
  endgenerate


  always @(posedge clk or negedge reset_n)
    begin : p_rst_state
      if (!reset_n)
        rst_state <= 1'b1;
      else
        rst_state <= 1'b0;
    end

  assign it_atb_ctr_2_rd_reg[0] = atready_m;
  assign iatreadym = itc_reg ? it_atb_ctr_2_wr_reg[0] : atready_m;


  assign afready_m = rst_state | (itc_reg ? it_atb_ctr_0_wr_reg[1]: funnel_flush);

  assign it_atb_ctr_0_rd_reg[1] = funnel_flush;


  genvar z;
  generate
    for (z=0; z< NUM_ATB_SLAVES; z=z+1) begin: syncreq_assigns
      assign syncreq_s[z] = en_port[z] & (syncreq_m | (syncreq_apb & ~syncreq_q));
    end
  endgenerate

  always @(posedge clk or negedge reset_n)
    begin : syncreq_req
      if (!reset_n)
        syncreq_q <= 1'b0;
      else
        syncreq_q <= |(syncreq_s);
    end

  assign syncreq_reg = syncreq_m;


endmodule
