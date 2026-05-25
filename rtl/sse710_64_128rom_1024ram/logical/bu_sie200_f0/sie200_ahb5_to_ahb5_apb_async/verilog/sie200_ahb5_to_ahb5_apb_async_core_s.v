//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Nov 10 15:26:41 2016 +0000
//
//      Revision            : be200a3
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_ahb5_apb_async_core_s #(
      parameter ADDR_WIDTH      = 32,
      parameter MASTER_WIDTH    = 4,
      parameter USER_WIDTH      = 1
)
(

  input  wire                    hclk_s,
  input  wire                    hresetn_s,

  input  wire                    hsel_ahb_s,
  input  wire                    hsel_apb_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire [1:0]              htrans_s,
  input  wire [2:0]              hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire [6:0]              hprot_s,
  input  wire [2:0]              hburst_s,
  input  wire                    hmastlock_s,
  input  wire [31:0]             hwdata_s,
  input  wire                    hexcl_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  output wire [31:0]             hrdata_s,
  output reg                     hreadyout_s,
  output reg                     hresp_s,
  output wire                    hexokay_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,
  output wire [USER_WIDTH-1:0]   hruser_s,

  output wire                    s_semaphore,
  input  wire                    m_semaphore,

  output wire                    s_mask,
  input  wire                    m_mask,

  output wire                    reg_hsel_apb_s,
  output wire                    reg_hnonsec_s,
  output wire [ADDR_WIDTH-1:0]   reg_haddr_s,
  output wire [2:0]              reg_hsize_s,
  output wire                    reg_hwrite_s,
  output wire [6:0]              reg_hprot_s,
  output wire                    reg_hmastlock_s,
  output wire                    reg_unlock_s,
  output wire [31:0]             reg_hwdata_s,
  output wire                    reg_hexcl_s,
  output wire [MASTER_WIDTH-1:0] reg_hmaster_s,
  output wire [USER_WIDTH-1:0]   reg_hauser_s,
  output wire [USER_WIDTH-1:0]   reg_hwuser_s,


  output wire                    q_hmastlock_s,

  input  wire                    comb_hresp_m,
  input  wire [31:0]             comb_hrdata_m,
  input  wire                    comb_hexokay_m,
  input  wire [USER_WIDTH-1:0]   comb_hruser_m,

  input  wire                    hold_en,
  output wire                    pend_trans,
  output wire                    s_active,
  input  wire                    brg_pwr_req_s,
  output wire                    brg_pwr_ack_s,

  input  wire                    cfg_gate_resp

   );


  wire [ 4:0] unused = { hburst_s[2:0], hsize_s[2], htrans_s[0] };


  localparam [2:0] ST_IDLE    = 3'd0;
  localparam [2:0] ST_DATA    = 3'd1;
  localparam [2:0] ST_SYNC    = 3'd2;
  localparam [2:0] ST_RESP    = 3'd3;
  localparam [2:0] ST_ERR1    = 3'd4;
  localparam [2:0] ST_ERR2    = 3'd5;
  localparam [2:0] ST_BUSY    = 3'd6;
  localparam [2:0] ST_X       = 3'bxxx;

  localparam [1:0] TR_IDLE    = 2'b00;
  localparam [1:0] TR_BUSY    = 2'b01;
  localparam [1:0] TR_NONSEQ  = 2'b10;
  localparam [1:0] TR_SEQ     = 2'b11;

  reg        [2:0] s_state_q;
  reg        [2:0] s_state_nxt;

  reg         ad_en;
  reg         wd_en;

  reg         start_sync;

  wire        req_sel;
  wire        req_trans;
  wire        busy_trans;
  wire        m_semaphore_sync;
  wire        s_semaphore_match;

  reg         start_sync_hold;
  wire        start_sync_hold_start;
  wire        start_sync_hold_end;

  reg         err_resp_reg;
  wire        err_resp_i;

  reg         need_unlock;

  wire        s_semaphore_reg;
  wire        q_hmastlock_reg;


  sie200_sync u_sema_s_from_m (
     .clk(hclk_s), .reset_n(hresetn_s), .d(m_semaphore  ), .q(m_semaphore_sync)
  );


  assign req_sel   = hsel_ahb_s | hsel_apb_s;
  assign req_trans = htrans_s[1] & req_sel;
  assign busy_trans = htrans_s == TR_BUSY;


  assign s_semaphore_match = (m_semaphore_sync == s_semaphore_reg) & ~brg_pwr_req_s;



  always @(*)
  begin

     start_sync       = 1'b0;
     ad_en            = 1'b0;
     wd_en            = 1'b0;
     hreadyout_s      = 1'b0;
     hresp_s          = 1'b0;

     s_state_nxt = s_state_q;

     case (s_state_q)

       ST_IDLE,
       ST_ERR2,
       ST_BUSY: begin
         start_sync       = hready_s & req_trans & ~hwrite_s;
         ad_en            = hready_s & req_trans;
         hreadyout_s      = 1'b1;
         hresp_s          = s_state_q == ST_ERR2;

         if (req_trans && hready_s)
           if (err_resp_i)
           begin
             s_state_nxt = ST_ERR1;
             start_sync  = 1'b0;
             ad_en     = 1'b0;
           end
           else if (hwrite_s)
             s_state_nxt = ST_DATA;
           else
             s_state_nxt = ST_SYNC;
         else
           if (s_state_q == ST_ERR2)
             s_state_nxt = busy_trans ? ST_BUSY : ST_IDLE;
           else if (s_state_q == ST_BUSY && ~busy_trans)
             s_state_nxt = ST_IDLE;

       end

       ST_ERR1: begin
         hresp_s          = 1'b1;

         s_state_nxt = ST_ERR2;

       end

       ST_DATA: begin
         start_sync       = 1'b1;
         wd_en          = 1'b1;

         s_state_nxt = ST_SYNC;

       end

       ST_SYNC: begin
         start_sync       = s_semaphore_match & ~comb_hresp_m & req_trans & ~hwrite_s;
         hreadyout_s      = s_semaphore_match & ~comb_hresp_m & ~start_sync_hold;
         ad_en            = hreadyout_s & req_trans ;
         hresp_s          = comb_hresp_m;

           if (s_semaphore_match & ~start_sync_hold )
             if (comb_hresp_m)
               s_state_nxt = ST_RESP;
             else
               if (~(req_trans && hready_s))
                 s_state_nxt = busy_trans? ST_BUSY : ST_IDLE;
               else
                 if (err_resp_i)
                 begin
                   s_state_nxt = ST_ERR1;
                   start_sync  = 1'b0;
                   ad_en     = 1'b0;
                 end
                 else
                   if (hwrite_s)
                     s_state_nxt = ST_DATA;
       end

       ST_RESP: begin
         start_sync       = req_trans & ~hwrite_s;
         ad_en            = req_trans;
         hresp_s          = 1'b1;
         hreadyout_s      = 1'b1;

         if (req_trans && hready_s)
           if (err_resp_i)
           begin
             s_state_nxt = ST_ERR1;
             start_sync  = 1'b0;
             ad_en     = 1'b0;
           end
           else if (hwrite_s)
             s_state_nxt = ST_DATA;
           else
             s_state_nxt = ST_SYNC;
         else
           s_state_nxt = busy_trans ? ST_BUSY : ST_IDLE;
       end

       default: begin
         s_state_nxt = ST_X;
       end

    endcase

  end

  always @(posedge hclk_s or negedge hresetn_s)
     if(~hresetn_s)
        s_state_q <= ST_IDLE;
     else
        s_state_q <= s_state_nxt;


  assign start_sync_hold_start = start_sync & ( hold_en );
  assign start_sync_hold_end   = ~hold_en;

  always @(posedge hclk_s or negedge hresetn_s)
     if(~hresetn_s)
        start_sync_hold <= 1'b0;
     else
       if ( start_sync_hold_start )
         start_sync_hold <= 1'b1;
       else if ( start_sync_hold_end )
         start_sync_hold <= 1'b0;


  wire new_err_resp = (htrans_s == TR_NONSEQ && req_sel && hready_s) && (~hmastlock_s || ~q_hmastlock_reg);

  always @(posedge hclk_s or negedge hresetn_s)
    if(~hresetn_s)
      err_resp_reg <= 1'b0;
    else
      if (new_err_resp)
        err_resp_reg <= cfg_gate_resp && hold_en;

  assign err_resp_i = new_err_resp ? cfg_gate_resp && hold_en : err_resp_reg;


   assign pend_trans =   ( (s_state_q != ST_IDLE && ~hready_s) || (req_sel && htrans_s[0]) || q_hmastlock_reg || s_state_q == ST_BUSY) && ~err_resp_reg;
   assign s_active   = pend_trans || ( ((s_state_nxt != ST_IDLE) && (s_state_nxt != ST_ERR1)) && ~err_resp_i);

   assign brg_pwr_ack_s = brg_pwr_req_s && s_semaphore_reg == 1'b0;


   wire  s_semaphore_en  = (start_sync & ~start_sync_hold_start) | (brg_pwr_req_s && ~m_semaphore_sync) | (start_sync_hold & start_sync_hold_end);
   wire  s_semaphore_nxt = ~m_semaphore_sync & ~brg_pwr_req_s;


  wire hmastlock_i = hmastlock_s & req_sel;

  wire new_hmastlock = (( req_sel && htrans_s == TR_NONSEQ) || q_hmastlock_reg) & hready_s;

  always @(posedge hclk_s or negedge hresetn_s)
    if(~hresetn_s)
      need_unlock <= 1'b0;
    else
      if (new_hmastlock && ~hmastlock_i && q_hmastlock_reg && ~ad_en)
        need_unlock <= 1'b1;
      else if (ad_en && hsel_ahb_s)
        need_unlock <= 1'b0;



  sie200_flop_en #( .DATA_WIDTH(1) ) u_semaphore_s (     .clk(hclk_s), .reset_n(hresetn_s), .en(s_semaphore_en), .d(s_semaphore_nxt), .q(s_semaphore_reg)  );
  sie200_flop_en #( .DATA_WIDTH(1) ) u_hmastlock_s (     .clk(hclk_s), .reset_n(hresetn_s), .en( new_hmastlock), .d(hmastlock_i    ), .q(q_hmastlock_reg)  );

  assign s_semaphore   = s_semaphore_reg;
  assign q_hmastlock_s = q_hmastlock_reg;




  sie200_sample_and_mask #( .DATA_WIDTH(  ADDR_WIDTH) ) u_haddr      (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(haddr_s     ), .mask(m_mask), .q(reg_haddr_s     )  );
  sie200_sample_and_mask #( .DATA_WIDTH(MASTER_WIDTH) ) u_hmaster    (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hmaster_s   ), .mask(m_mask), .q(reg_hmaster_s   )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_hmastlock  (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hmastlock_i ), .mask(m_mask), .q(reg_hmastlock_s )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           7) ) u_hprot      (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hprot_s     ), .mask(m_mask), .q(reg_hprot_s     )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_hsel_apb   (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hsel_apb_s  ), .mask(m_mask), .q(reg_hsel_apb_s  )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           2) ) u_hsize_1to0 (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hsize_s[1:0]), .mask(m_mask), .q(reg_hsize_s[1:0])  );
  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_hwrite     (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hwrite_s    ), .mask(m_mask), .q(reg_hwrite_s    )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_hnonsec    (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hnonsec_s   ), .mask(m_mask), .q(reg_hnonsec_s   )  );
  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_hexcl      (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hexcl_s     ), .mask(m_mask), .q(reg_hexcl_s     )  );
  sie200_sample_and_mask #( .DATA_WIDTH(  USER_WIDTH) ) u_hauser     (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(hauser_s    ), .mask(m_mask), .q(reg_hauser_s    )  );

  sie200_sample_and_mask #( .DATA_WIDTH(           1) ) u_unlock     (     .clk(hclk_s), .reset_n(hresetn_s), .en(ad_en), .d(need_unlock ), .mask(m_mask), .q(reg_unlock_s    )  );


  sie200_sample_and_mask #( .DATA_WIDTH(          32) ) u_hwdata     (     .clk(hclk_s), .reset_n(hresetn_s), .en(wd_en), .d(hwdata_s    ), .mask(m_mask), .q(reg_hwdata_s    )  );
  sie200_sample_and_mask #( .DATA_WIDTH(  USER_WIDTH) ) u_hwuser     (     .clk(hclk_s), .reset_n(hresetn_s), .en(wd_en), .d(hwuser_s    ), .mask(m_mask), .q(reg_hwuser_s    )  );


  assign s_mask       = ~(s_semaphore_match && (s_state_q == ST_SYNC)) || start_sync_hold || brg_pwr_req_s;

  assign reg_hsize_s[2] = 1'b0;


  assign hrdata_s    = comb_hrdata_m;
  assign hexokay_s   = comb_hexokay_m;
  assign hruser_s    = comb_hruser_m;

endmodule
