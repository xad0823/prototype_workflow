//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Checked In          : Tue Nov 29 15:12:32 2016 +0000
//
//      Revision            : 2839fdb
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_master_sec #(

    parameter DATA_WIDTH   = 32,
    parameter MASTER_WIDTH = 4,
    parameter USER_WIDTH   = 1
)
(


  input  wire hclk                          ,
  input  wire hresetn                       ,


  input  wire             [31:0]  haddr_s   ,
  input  wire                     hwrite_s   ,
  input  wire [DATA_WIDTH  -1:0]  hwdata_s   ,
  output wire [DATA_WIDTH  -1:0]  hrdata_s   ,

  output wire                     hready_s   ,
  output wire                     hresp_s    ,
  input  wire                     hmastlock_s,
  input  wire              [6:0]  hprot_s    ,

  input  wire              [1:0]  htrans_s   ,
  input  wire              [2:0]  hsize_s    ,
  input  wire              [2:0]  hburst_s   ,
  input  wire [MASTER_WIDTH-1:0]  hmaster_s  ,

  input  wire                     hexcl_s    ,
  output wire                     hexokay_s  ,

  input  wire [USER_WIDTH  -1:0]  hauser_s   ,
  input  wire [USER_WIDTH  -1:0]  hwuser_s   ,
  output wire [USER_WIDTH  -1:0]  hruser_s   ,


  input  wire                     cfg_nonsec ,


  output wire             [31:0]  haddr_m    ,
  output wire                     hwrite_m   ,
  output wire [DATA_WIDTH  -1:0]  hwdata_m   ,
  input  wire [DATA_WIDTH  -1:0]  hrdata_m   ,

  input  wire                     hready_m   ,
  input  wire                     hresp_m    ,
  output wire                     hmastlock_m,

  output wire              [1:0]  htrans_m   ,
  output wire              [2:0]  hsize_m    ,
  output wire              [2:0]  hburst_m   ,
  output wire [MASTER_WIDTH-1:0]  hmaster_m  ,

  output wire                     hexcl_m    ,
  input  wire                     hexokay_m  ,

  output wire              [6:0]  hprot_m    ,
  output wire                     hnonsec_m  ,

  output wire [USER_WIDTH  -1:0]  hauser_m   ,
  output wire [USER_WIDTH  -1:0]  hwuser_m   ,
  input  wire [USER_WIDTH  -1:0]  hruser_m   ,

  output wire             [26:0]  idauaddr   ,
  input  wire                     idauns     ,
  input  wire                     idaunchk  ,

  input  wire                     cfg_sec_resp,
  output wire                     msc_irq,
  input  wire                     msc_irq_clear,
  input  wire                     msc_irq_enable
);

  localparam TRN_IDLE              = 2'b00;
  localparam TRN_NONSEQ            = 2'b10;
  localparam TRN_SEQ               = 2'b11;
  localparam AHB_RESP_ERR          = 1'b1;
  localparam FSM_IDLE      = 2'b00;
  localparam FSM_RAZWI     = 2'b01;
  localparam FSM_ERR1      = 2'b10;
  localparam FSM_ERR2      = 2'b11;


  wire         trn_nseq;
  wire         trn_sq;
  wire         trn;

  reg          hready_s_r;
  reg    [1:0] htrans_s_r;

  wire         trn_nseq_r;

  wire         store_cfg;
  reg          cfg_sec_resp_r;
  reg          cfg_nonsec_r;

  wire         sec_resp;
  wire         nonsec;

  wire         legal_trn;
  wire         illegal_trn;

  wire         single_trn;
  wire         start_burst;
  wire         trn_burst;

  wire         burst_fail;
  wire         burst_ok_new;

  reg          ignore_burst_r;
  wire         ignore_burst;

  wire         trn_blocked;

  reg    [1:0] next_state;
  reg    [1:0] current_state;

  reg          irq_s;

  wire         gate_addrph;
  wire         gate_dataph;

  wire         err_phase_1;
  wire         err_phase_2;


  assign trn_nseq     = htrans_s  == TRN_NONSEQ;
  assign trn_sq       = htrans_s  == TRN_SEQ;
  assign trn          = trn_nseq | trn_sq;

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hready_s_r <= 1'b0;
      htrans_s_r <= TRN_IDLE;
    end
    else begin
      hready_s_r <= hready_s;
      htrans_s_r <= htrans_s;
    end
  end
  assign trn_nseq_r  = (htrans_s_r  == TRN_NONSEQ)  ? 1'b1 : 1'b0;

  assign store_cfg   = trn_nseq & (hready_s_r | ~trn_nseq_r);

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      cfg_sec_resp_r <= 1'b0;
      cfg_nonsec_r   <= 1'b0;
    end
    else begin
      if (store_cfg) begin
        cfg_sec_resp_r <= cfg_sec_resp;
        cfg_nonsec_r   <= cfg_nonsec;
      end
    end
  end

  assign sec_resp       = store_cfg ? cfg_sec_resp : cfg_sec_resp_r;
  assign nonsec         = store_cfg ? cfg_nonsec   : cfg_nonsec_r;



  assign   legal_trn    = trn & (idaunchk | ~nonsec | idauns);
  assign illegal_trn    = trn & ~legal_trn;

  assign single_trn     = trn_nseq & (hburst_s == 3'b000);
  assign start_burst    = trn_nseq & ~single_trn;
  assign trn_burst      = start_burst | trn_sq;

  assign burst_fail     = hready_s &  illegal_trn & trn_burst;
  assign burst_ok_new   = hready_s &    legal_trn & trn_nseq;

  always @(posedge hclk or negedge hresetn) begin
   if (~hresetn) begin
       ignore_burst_r <= 1'b0;
    end
    else if (burst_fail) begin
        ignore_burst_r <= 1'b1;
    end
    else if (burst_ok_new)
       ignore_burst_r <= 1'b0;
    end
  assign ignore_burst   = burst_ok_new ? 1'b0 : ignore_burst_r;

  assign trn_blocked    = (illegal_trn  | (trn_sq  & ignore_burst)) & hready_s;

  always @(*) begin
    case ( current_state )
      FSM_IDLE    : begin
                      if (~sec_resp & trn_blocked)
                        next_state = FSM_RAZWI;
                      else if (sec_resp & trn_blocked)
                        next_state = FSM_ERR1;
                      else
                        next_state = FSM_IDLE;
                    end
      FSM_RAZWI    : begin
                       if (~sec_resp & trn_blocked)
                         next_state = FSM_RAZWI;
                       else if (sec_resp & trn_blocked)
                         next_state = FSM_ERR1;
                       else
                         next_state = FSM_IDLE;
                     end
      FSM_ERR1     : begin
                       next_state = FSM_ERR2;
                     end
      FSM_ERR2     : begin
                       if (~sec_resp & trn_blocked)
                         next_state = FSM_RAZWI;
                       else if (sec_resp & trn_blocked)
                         next_state = FSM_ERR1;
                       else
                         next_state = FSM_IDLE;
                      end
       default      : begin
                        next_state = 2'bxx;
                      end
    endcase
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      current_state <= FSM_IDLE;
    end
    else
      current_state <= next_state;
  end


  assign err_phase_1   = (current_state == FSM_ERR1);
  assign err_phase_2   = (current_state == FSM_ERR2);
  assign gate_addrph   = (nonsec & ~idaunchk & ~idauns) | err_phase_1   | ignore_burst;

  assign gate_dataph   = current_state != FSM_IDLE;



  assign haddr_m       = haddr_s;
  assign htrans_m      = gate_addrph ? TRN_IDLE               : htrans_s;
  assign hwrite_m      = gate_addrph ? 1'b0                   : hwrite_s;
  assign hburst_m      = gate_addrph ? {3{1'b0}}              : hburst_s;
  assign hprot_m       = gate_addrph ? {7{1'b0}}              : hprot_s;
  assign hauser_m      = gate_addrph ? {(USER_WIDTH){1'b0}}   : hauser_s;
  assign hsize_m       = gate_addrph ? {3{1'b0}}              : hsize_s;
  assign hexcl_m       = gate_addrph ? 1'b0                   : hexcl_s;
  assign hmaster_m     = gate_addrph ? {(MASTER_WIDTH){1'b0}} : hmaster_s;

  assign hmastlock_m   = hmastlock_s;

  assign hnonsec_m     = nonsec | ~idaunchk & idauns;


  assign hready_s      = err_phase_1 ? 1'b0 :
                         err_phase_2 ? 1'b1 :
                                       hready_m;
  assign hresp_s       = err_phase_1 | err_phase_2 ? AHB_RESP_ERR :
                                                     hresp_m;

  assign hwdata_m      = gate_dataph ? {(DATA_WIDTH){1'b0}} : hwdata_s;
  assign hrdata_s      = gate_dataph ? {(DATA_WIDTH){1'b0}} : hrdata_m;

  assign hwuser_m      = gate_dataph ? {(USER_WIDTH){1'b0}} : hwuser_s;

  assign hruser_s      = gate_dataph ? {(USER_WIDTH){1'b0}} : hruser_m;
  assign hexokay_s     = gate_dataph ? 1'b0                 : hexokay_m;

  assign idauaddr   = haddr_s[31:5];

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
       irq_s <= 1'b0;
    else begin
      if (msc_irq_clear)
        irq_s <= 1'b0;
      else
      if (illegal_trn & msc_irq_enable)
        irq_s <= 1'b1;
    end
  end
  assign msc_irq = irq_s;








endmodule


