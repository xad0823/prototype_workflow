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
//      Checked In          : Tue Dec 6 14:46:12 2016 +0000
//
//      Revision            : fc66d0a
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------
module sie200_ahb5_to_ahb5_apb_async_core_m #(
      parameter ADDR_WIDTH      = 32,
      parameter MASTER_WIDTH    = 4,
      parameter USER_WIDTH      = 1
)
(

  input  wire                    hclk_m,
  input  wire                    hresetn_m,

  output wire                    m_semaphore,
  input  wire                    s_semaphore,

  output wire                    m_mask,
  input  wire                    s_mask,

  input  wire                    reg_hsel_apb_s,
  input  wire                    reg_hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   reg_haddr_s,
  input  wire [2:0]              reg_hsize_s,
  input  wire                    reg_hwrite_s,
  input  wire [6:0]              reg_hprot_s,
  input  wire                    reg_hmastlock_s,
  input  wire                    reg_unlock_s,
  input  wire [31:0]             reg_hwdata_s,
  input  wire                    reg_hexcl_s,
  input  wire [MASTER_WIDTH-1:0] reg_hmaster_s,
  input  wire [USER_WIDTH-1:0]   reg_hauser_s,
  input  wire [USER_WIDTH-1:0]   reg_hwuser_s,
  input  wire                    q_hmastlock_s,

  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire [1:0]              htrans_m,
  output wire [2:0]              hsize_m,
  output wire                    hwrite_m,
  input  wire                    hready_m,
  output wire [6:0]              hprot_m,
  output wire [2:0]              hburst_m,
  output wire                    hmastlock_m,
  output wire [31:0]             hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  input  wire                    hresp_m,
  input  wire [31:0]             hrdata_m,
  input  wire                    hexokay_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,
  input  wire [USER_WIDTH-1:0]   hruser_m,

  output wire [ADDR_WIDTH-1:0]   paddr_m,
  output wire [ 2:0]             pprot_m,
  output wire                    psel_m,
  output wire                    penable_m,
  output wire                    pwrite_m,
  output wire [31:0]             pwdata_m,
  output wire [ 3:0]             pstrb_m,
  input  wire                    pready_m,
  input  wire [31:0]             prdata_m,
  input  wire                    pslverr_m,
  output wire [MASTER_WIDTH-1:0] pmaster_m,

  output wire                    hactive_m,
  output wire                    pactive_m,

  output wire                    comb_hresp_m,
  output wire [31:0]             comb_hrdata_m,
  output wire                    comb_hexokay_m,
  output wire [USER_WIDTH-1:0]   comb_hruser_m,

  input  wire                    brg_pwr_req_m,
  output wire                    brg_pwr_ack_m
  );


  wire [ 0:0] unused = reg_hsize_s[2];


  localparam [1:0] ST_IDLE    = 2'd0;
  localparam [1:0] ST_UNLOCK  = 2'd1;
  localparam [1:0] ST_APHASE  = 2'd2;
  localparam [1:0] ST_DPHASE  = 2'd3;
  localparam [1:0] ST_X       = 2'bxx;


  wire        s_semaphore_sync;
  wire        q_mastlock_s_sync;
  wire        reg_mastlock_p_sync;

  wire        m_semaphore_match;

  wire        m_semaphore_reg;

  reg   [1:0] m_state_q;
  reg   [1:0] m_state_next;

  reg         hmastlock_m_reg;


  sie200_sync u_semaphore_m_from_s (
     .clk(hclk_m), .reset_n(hresetn_m), .d(s_semaphore  ), .q(s_semaphore_sync)
  );

  sie200_sync u_lock_m_from_s (
     .clk(hclk_m), .reset_n(hresetn_m), .d(q_hmastlock_s), .q(q_mastlock_s_sync)
  );


  assign m_semaphore_match = (s_semaphore_sync == m_semaphore_reg);


   wire        m_ready          = reg_hsel_apb_s ? pready_m : hready_m;


  always @(*)
  begin

     m_state_next = m_state_q;

     case (m_state_q)

       ST_IDLE: begin
         if (~m_semaphore_match & ~brg_pwr_req_m)
           if (reg_unlock_s & ~reg_hsel_apb_s & hmastlock_m_reg)
              m_state_next = ST_APHASE;
           else
              m_state_next = ST_DPHASE;

       end

       ST_UNLOCK: begin
       end

       ST_APHASE: begin
         m_state_next = ST_DPHASE;
       end

       ST_DPHASE: begin
         if (m_ready)
           m_state_next = ST_IDLE;
       end

       default: begin
         m_state_next = ST_X;
       end

    endcase

  end

  always @(posedge hclk_m or negedge hresetn_m)
     if(~hresetn_m)
        m_state_q <= ST_IDLE;
     else
        m_state_q <= m_state_next;

  always @(posedge hclk_m or negedge hresetn_m)
     if(~hresetn_m)
        hmastlock_m_reg <= 1'b0;
     else
        hmastlock_m_reg <= hmastlock_m;





   assign      hmastlock_m      = m_state_q == ST_IDLE & ~m_semaphore_match ? reg_unlock_s & ~reg_hsel_apb_s & hmastlock_m_reg ? 1'b0 :
                                                                                                                                 reg_hmastlock_s :
                                  m_state_q == ST_APHASE & ~reg_hsel_apb_s                                                     ? reg_hmastlock_s
                                                                                                                               : q_mastlock_s_sync;
   assign      htrans_m         = { ~reg_hsel_apb_s & m_state_next == ST_DPHASE & m_state_q != ST_DPHASE, 1'b0 };

   assign      psel_m           =  reg_hsel_apb_s & (m_state_next == ST_DPHASE || m_state_q != ST_IDLE);
   assign      penable_m        =  reg_hsel_apb_s & m_state_q == ST_DPHASE;

   wire [ 3:0] m_strb           = { ( reg_hsize_s[1] |
                                      reg_hsize_s[0] & reg_haddr_s[1] |
                                      ( (reg_hsize_s[1:0] == 2'b00) &
                                        (reg_haddr_s[1:0] == 2'b11) ) ),

                                    ( reg_hsize_s[1] |
                                      reg_hsize_s[0] & reg_haddr_s[1] |
                                      ( (reg_hsize_s[1:0] == 2'b00) &
                                        (reg_haddr_s[1:0] == 2'b10) ) ),

                                    ( reg_hsize_s[1] |
                                      reg_hsize_s[0] & ~reg_haddr_s[1] |
                                      ( (reg_hsize_s[1:0] == 2'b00) &
                                        (reg_haddr_s[1:0] == 2'b01) ) ),

                                    ( reg_hsize_s[1] |
                                      reg_hsize_s[0] & ~reg_haddr_s[1] |
                                      ( (reg_hsize_s[1:0] == 2'b00) &
                                        (reg_haddr_s[1:0] == 2'b00) ) )
                                    };
   assign      pstrb_m          = {4{reg_hwrite_s}} & m_strb[3:0];

   wire        m_rd_en          = m_state_q == ST_DPHASE & m_ready;


   assign      hactive_m        = (( m_state_next != ST_IDLE |  m_state_q != ST_IDLE) & ~reg_hsel_apb_s );

   assign      pactive_m        = (( m_state_next != ST_IDLE |  m_state_q != ST_IDLE) &  reg_hsel_apb_s );




   wire        m_semaphore_en     = (m_state_q == ST_DPHASE & m_ready) | brg_pwr_req_m;
   wire        m_semaphore_nxt    = s_semaphore_sync & ~brg_pwr_req_m;


   assign      m_mask             = m_semaphore_match | brg_pwr_req_m;

   assign      brg_pwr_ack_m      = brg_pwr_req_m && m_state_q == ST_IDLE && m_semaphore_reg == 1'b0;


  sie200_flop_en #( .DATA_WIDTH(1) ) u_semaphore_m       (     .clk(hclk_m), .reset_n(hresetn_m), .en(m_semaphore_en), .d(m_semaphore_nxt),   .q(m_semaphore_reg  ) );

  assign m_semaphore       = m_semaphore_reg;


  wire                  i_resp           = reg_hsel_apb_s ? pslverr_m          : hresp_m;
  wire [31:0]           i_rdata          = reg_hsel_apb_s ? prdata_m           : hrdata_m;
  wire [USER_WIDTH-1:0] i_hruser         = reg_hsel_apb_s ? {USER_WIDTH{1'b0}} : hruser_m;
  wire                  i_hexokay        = reg_hsel_apb_s ? 1'b0               : hexokay_m;

  sie200_sample_and_mask #( .DATA_WIDTH(         1) ) u_resp    (     .clk(hclk_m), .reset_n(hresetn_m), .en(m_rd_en), .d(i_resp   ), .mask(s_mask), .q(comb_hresp_m  ) );
  sie200_sample_and_mask #( .DATA_WIDTH(        32) ) u_rdata   (     .clk(hclk_m), .reset_n(hresetn_m), .en(m_rd_en), .d(i_rdata  ), .mask(s_mask), .q(comb_hrdata_m ) );
  sie200_sample_and_mask #( .DATA_WIDTH(         1) ) u_hexokay (     .clk(hclk_m), .reset_n(hresetn_m), .en(m_rd_en), .d(i_hexokay), .mask(s_mask), .q(comb_hexokay_m) );
  sie200_sample_and_mask #( .DATA_WIDTH(USER_WIDTH) ) u_hruser  (     .clk(hclk_m), .reset_n(hresetn_m), .en(m_rd_en), .d(i_hruser ), .mask(s_mask), .q(comb_hruser_m ) );



  assign hnonsec_m   = reg_hnonsec_s;
  assign haddr_m     = reg_haddr_s;
  assign hburst_m    = 3'b000;
  assign hmaster_m   = reg_hmaster_s;
  assign hprot_m     = reg_hprot_s;
  assign hsize_m     = reg_hsize_s;
  assign hwdata_m    = reg_hwdata_s;
  assign hexcl_m     = reg_hexcl_s;
  assign hwrite_m    = reg_hwrite_s;
  assign hauser_m    = reg_hauser_s;
  assign hwuser_m    = reg_hwuser_s;


  assign paddr_m     = { reg_haddr_s[ADDR_WIDTH-1:2] , 2'b00 };
  assign pmaster_m   = reg_hmaster_s;
  assign pprot_m     = { ~reg_hprot_s[0], reg_hnonsec_s, reg_hprot_s[1] };
  assign pwdata_m    = reg_hwdata_s;
  assign pwrite_m    = reg_hwrite_s;


endmodule
