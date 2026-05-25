//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------
// Abstract : IFU CP15 operations
//-----------------------------------------------------------------------------

`include "cortexa53params.v"
`include "ca53_dcu_ifu_defs.v"

module ca53ifu_cp15 `CA53_IFU_PARAM_DECL
 (
  // Clocks and resets
  input wire                           clk,
  input wire                           reset_n,

  // DPU-IFU interface
  input wire                           dpu_kill_wr_i,

  // DCU-IFU interface
  input wire                           dcu_cp_valid_i,
  input wire                           dcu_dvm_valid_i,
  input wire [2:0]                     dcu_cp_op_i,
  input wire [39:0]                    dcu_cp_addr_ifu_i,
  input wire                           dcu_cp_ns_i,

  output wire                          ifu_cp_ack_o,

  // ICB parity error
  input wire                           ctl_pty_inv_req_i,
  input wire [14:6]                    ctl_pty_inv_addr_i,
  output wire                          cp15_pty_ack_o,

  // TLB-IFU interface
  output wire                          ifu_cp_dbg_valid_o,
  output wire [31:0]                   ifu_cp_dbg_1_o,
  output wire [31:0]                   ifu_cp_dbg_0_o,

  // RAM-IFU interface
  input wire [2:0]                     ic_size_i, // RAM: icache size mask

  input wire [(`CA53_ITAG_RAM_W-1):0]  ic_tagram_rdata0_i, // Tag read data 0
  input wire [(`CA53_ITAG_RAM_W-1):0]  ic_tagram_rdata1_i, // Tag read data 1

  input wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata0_i, // Data read data 0
  input wire [(`CA53_IDATA_RAM_W-1):0] ic_dataram_rdata1_i, // Data read data 1

  // Control
  input wire                           ctl_stall_tag_cp15_i, // CP15 op must hold in if0 if set
  input wire                           ctl_stall_tag_cp15_if1_i,
  input wire                           ctl_stall_data_cp15_i, // CP15 debug_data read op must hold in lookup_if0 if set
  input wire                           ctl_stall_data_cp15_if1_i,
  input wire                           ctl_mbist_req_i,

  output wire [1:0]                    cp15_busy_if1_o, // Tell Pre-Fetch to stop making requests
  output wire [1:0]                    cp15_active_o, // Tell control logic to turn every Pre-fetch request to non-cacheable
  output wire [1:0]                    cp15_hazard_ack_o,// Tell LFB to suppress hits if address match
  output wire [1:0]                    cp15_tag_en_o, // CP15: tag enable (for both ways)
  output wire                          cp15_tag_wr_o, // Tag read or write
  output wire [1:0]                    cp15_data_en_o, // Data enable (for both ways)
  output wire                          cp15_data_wr_o, // Data write enable (for both ways)
  output wire [11:0]                   cp15_addr_o       // VA
);


 //-------------------------------------------------------------------------
  // Local Parmameters
  //-------------------------------------------------------------------------
  localparam CP15_ST_WIDTH = 3;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_IDLE           = 3'b000;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_LOOKUP_IF0     = 3'b001;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_BUBBLE_IF1     = 3'b010;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_WRITE_IF0      = 3'b011;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_LOOKUP_P1_IF0  = 3'b100;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_WRITE_P1_IF0   = 3'b101;
  localparam [CP15_ST_WIDTH-1:0] CP15_ST_PTY_INVAL      = 3'b110;

  localparam INVAL_TYPE = 3;
  // CP15_ICACHE_INV_ALL_S is a special case as this entry is made to differentiate between INVAL_ALL_SECURE and INVAL_ALL_NONSECURE
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_ALL_S = 3'b000;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_ALL   = `CA53_CP_ICACHE_INV_ALL;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_VA    = `CA53_CP_ICACHE_INV_VA;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_PA    = `CA53_CP_ICACHE_INV_PA;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_MVA   = `CA53_CP_ICACHE_INV_MVA;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_DBG_TAG   = `CA53_CP_ICACHE_DBG_TAG;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_DBG_DATA  = `CA53_CP_ICACHE_DBG_DATA;
  localparam [INVAL_TYPE-1:0] CP15_ICACHE_INV_PTY   = 3'b001;

  // Wire Declaration
  wire [79:0] ic_dataram_rdata0;
  wire [79:0] ic_dataram_rdata1;
  wire        dcu_valid_present;
  wire        dcu_dbg_op;
  wire        dcu_short_req;
  wire        cp_inval_all;
  wire        cp_inval_by_addr;
  wire        cp_pa_mode;
  wire        cp_dbg_data;
  wire        last_inval_addr;
  wire [11:0] top_address;
  wire        last_pa_addr;
  wire        addr_op_store_en;
  wire        addr_op_store;
  wire        incr_inval_addr_en;
  wire [11:0] next_inval_addr;
  wire        incr_pa_addr_en;
  wire [2:0]  next_pa_addr;
  wire        nxt_cp_ack;
  wire        ack_en;
  wire        nxt_cp15_pty_ack;
  wire        cp15_pty_ack_en;
  wire [1:0]  cp15_hazard_ack;
  wire [ 1:0] cp_active;
  wire [5:0]  cp_op_mode;
  wire [1:0]  compare_ns;
  wire [1:0]  compare_pa;
  wire [1:0]  compare_pa_ns;
  wire [1:0]  compare_inval_even_ns;
  wire [1:0]  compare_inval_odd_ns;
  wire [1:0]  compare_inval_pa_ns;
  wire [8:0]  cp_addr_inval_reg_p1;
  wire [1:0]  cp_busy;
  wire        cp_dbg_op;

  wire        count_even_set;
  wire        count_odd_set;
  wire        count_even_en;
  wire        count_odd_en;
  wire [1:0]  count_even_nxt;
  wire [1:0]  count_odd_nxt;

  wire        lookup_stall;
  wire        bubble_stall;

  wire [2:0]  nxt_cp_op;
  wire [39:0] nxt_cp_addr;

  //Reg Declarations
  reg [2:0]   cp15_st;
  reg [2:0]   cp15_st_next;
  reg [2:0]   cp_op_reg;
  reg [39:0]  cp_addr_reg;
  reg         cp_ns_reg;
  reg [11:0]  cp_addr_inval_reg;
  reg [2:0]   cp_addr_pa_reg;
  reg         cp_ack;
  reg         cp15_pty_ack;
  reg [1:0]   cp_tag_en;
  reg         cp_tag_wr;
  reg [1:0]   cp_data_en;
  reg         cp_data_wr;
  reg [8:0]   cp_addr;

  reg [30:0]  cp_dbg_0;  // Tag or half data bank
  reg [19:0]  cp_dbg_1;  // Half data bank only

  reg [1:0]   count_even;
  reg [1:0]   count_odd;
  reg [1:0]   compare_even_ns;
  reg [1:0]   compare_odd_ns;
  reg [1:0]   compare_set_pa_ns;

  wire        nxt_cp_dbg_valid;
  wire        en_cp_dbg_valid;
  reg         cp_dbg_valid;
  reg [30:0]  cp_dbg_0_reg;
  reg [19:0]  cp_dbg_1_reg;

  wire        inval_data;
  wire [1:0]  inval_tag_en;
  wire [5:3]  nxt_cp_addr_inval_data;
  reg [5:3]   cp_addr_inval_data;

  // During a debug operation we pack the data in a particular order
  // Debug TAG Read
  // ifu_cp_dbg_0_o = { 1'b0 , <correct tag contents>[30:0] }
  // ifu_cp_dbg_1_o = {32{1'b0}};

  // Debug Data Read
  // ifu_cp_dbg_0_o = { {12{1'b0}} , <correct data contents>[19:0] }
  // ifu_cp_dbg_1_o = { {12{1'b0}} , <correct data contents>[39:0] }
  // <correct data contents> will depend on way address[3] to select correct 80 bits from the RAM
  // and address [2] to select correct half

  // CP busy: Short operation from Idle to Request
  //          to last write followed by Idle.

  // CP Active:
  // cp_active[0]: !idle
  // cp_active[1]: !idle & dcu_inval_op

  //-------------------------------------------------------------------------
  // Main Code
  //-------------------------------------------------------------------------

  //
  // State machine
  //
  always @*
    case (cp15_st)

      // Remain in idle state until and unless a request is recieved from the DCU and the valid signal is present.
      // Depending on the operation mode there could be two possibilities: - Invalidate_all_secure and all other
      // modes other than Invalidate_all_secure.
      CP15_ST_IDLE          : cp15_st_next = ctl_pty_inv_req_i                                                                             ? CP15_ST_PTY_INVAL    :
                                             dcu_valid_present & !ctl_mbist_req_i & ((dcu_cp_op_i == CP15_ICACHE_INV_ALL) & !dcu_cp_ns_i)  ? CP15_ST_WRITE_IF0    :
                                             dcu_valid_present & !ctl_mbist_req_i                                                          ? CP15_ST_LOOKUP_IF0   :
                                                                                                                                             CP15_ST_IDLE;

      // This state is for invalidating an entry following a parity error.  Only a write, no lookup, is required
      // because the lookup was already performed in the ICB ctl.
      CP15_ST_PTY_INVAL     : cp15_st_next = ctl_stall_tag_cp15_i                                                                          ? CP15_ST_PTY_INVAL    :
                                                                                                                                             CP15_ST_IDLE;

      // This is the first stage of sending data to invalidate in if0 stage. In Invalidation_all_mode there are two
      // two stages write_if0 and write_p1_if0 and in any other mode there is only one stage. if we have a request
      // for another short operation then we can move from write to lookup stage.
      // Note: we dont stall in WRITE_IF0 stage when in debug_data or debug_tag mode even when the stall_data_cp15 is high 
      CP15_ST_WRITE_IF0     : cp15_st_next =  ctl_stall_tag_cp15_i & (cp_inval_all | (!cp_dbg_op & cp_tag_en != 2'b00))                     ? CP15_ST_WRITE_IF0    :
                                              cp_inval_all                                                                                  ? CP15_ST_WRITE_P1_IF0 :
                                              dcu_short_req | (cp_pa_mode & !last_pa_addr)                                                  ? CP15_ST_LOOKUP_IF0   :
                                                                                                                                              CP15_ST_IDLE;
      // This stage is only possible for Invalidate all secure and non secure where in non secure mode if we
      // havent reached at the top of the address then we go back to Lookupstage.
      CP15_ST_WRITE_P1_IF0  : cp15_st_next =  ctl_stall_tag_cp15_i                                                                          ? CP15_ST_WRITE_P1_IF0 :
                                              (!cp_ns_reg) & (!last_inval_addr)                                                             ? CP15_ST_WRITE_IF0    :
                                              ( cp_ns_reg) & (!last_inval_addr)                                                             ? CP15_ST_LOOKUP_IF0   :
                                                                                                                                              CP15_ST_IDLE;
      // This is the stage where we send the enable, addr and tag_wr signal to the cache to read a particular entry.
      CP15_ST_LOOKUP_IF0    : cp15_st_next =  lookup_stall                                                                                  ? CP15_ST_LOOKUP_IF0   :
                                              !cp_inval_all                                                                                 ? CP15_ST_BUBBLE_IF1   :
                                                                                                                                              CP15_ST_LOOKUP_P1_IF0;
      // This stage is only possible for Invalidate all non secure as we try to access two addresses at one time to
      // cut down on number of cycles.
      CP15_ST_LOOKUP_P1_IF0 : cp15_st_next =  ctl_stall_tag_cp15_i                                                                          ? CP15_ST_LOOKUP_P1_IF0:
                                                                                                                                              CP15_ST_WRITE_IF0;
      // This stage is only possible in short operation and is there so we can have a stage between lookup to when
      // the data is available from the cache.
      CP15_ST_BUBBLE_IF1    : cp15_st_next =  bubble_stall                                                                                  ? CP15_ST_BUBBLE_IF1   :
                                                                                                                                              CP15_ST_WRITE_IF0;

      default : cp15_st_next = {CP15_ST_WIDTH{1'bx}};
    endcase

  // State Machine flop with reset
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cp15_st <= CP15_ST_IDLE;
    else
      cp15_st <= cp15_st_next;

  // Qualifying criteria for State machine
  assign dcu_valid_present = (dcu_cp_valid_i & !dpu_kill_wr_i) | dcu_dvm_valid_i;
  assign dcu_short_req     = dcu_valid_present &
                             ~(dcu_cp_op_i == CP15_ICACHE_INV_ALL | 
                               dcu_cp_op_i == CP15_ICACHE_INV_PA | 
                               dcu_cp_op_i == CP15_ICACHE_DBG_DATA | 
                               dcu_cp_op_i == CP15_ICACHE_DBG_TAG) &
                             ~(cp_inval_all | cp_pa_mode | cp_dbg_op | ctl_pty_inv_req_i);
  assign dcu_dbg_op        = (dcu_cp_op_i == CP15_ICACHE_DBG_DATA | dcu_cp_op_i == CP15_ICACHE_DBG_TAG);
  assign cp_inval_all      =  cp_op_reg == CP15_ICACHE_INV_ALL;
  assign cp_inval_by_addr  =  cp_op_reg == CP15_ICACHE_INV_PA | cp_op_reg == CP15_ICACHE_INV_VA | cp_op_reg == CP15_ICACHE_INV_MVA;
  assign cp_pa_mode        =  cp_op_reg == CP15_ICACHE_INV_PA;
  assign cp_dbg_data       =  cp_op_reg == CP15_ICACHE_DBG_DATA;
  assign cp_dbg_op         =  cp_op_reg == CP15_ICACHE_DBG_DATA | cp_op_reg == CP15_ICACHE_DBG_TAG;

  // We register the incoming signal on the first cycle of the request
  // o from Idle
  // o from WRITE_IFO as long as:
  //   o we are completing a short op and we are starting a short op
  //   o there are no tag stalls or we are completing a debug op
  //   o it is the last WRITE_IF0 (pa op will go through many times)
  assign addr_op_store = ((cp15_st == CP15_ST_IDLE) & dcu_valid_present & ~ctl_pty_inv_req_i) |
                         ((cp15_st == CP15_ST_WRITE_IF0) & dcu_short_req & ~(ctl_stall_tag_cp15_i & cp_tag_en != 2'b00));
  assign nxt_cp_op          = ctl_pty_inv_req_i ? CP15_ICACHE_INV_PTY : dcu_cp_op_i;
  assign nxt_cp_addr[39:15] =                                           dcu_cp_addr_ifu_i[39:15];
  assign nxt_cp_addr[14:6]  = ctl_pty_inv_req_i ? ctl_pty_inv_addr_i  : dcu_cp_addr_ifu_i[14:6];
  assign nxt_cp_addr[5:0]   =                                           dcu_cp_addr_ifu_i[5:0];

  assign addr_op_store_en = addr_op_store | ((cp15_st == CP15_ST_IDLE) & ctl_pty_inv_req_i);
  always @(posedge clk)
    if (addr_op_store_en) begin
      cp_op_reg   <= nxt_cp_op;
      cp_ns_reg   <= dcu_cp_ns_i;
      cp_addr_reg <= nxt_cp_addr;
    end

  assign nxt_cp_addr_inval_data = cp_addr_inval_data[5:3]+3'b001;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cp_addr_inval_data <= 3'b000;
    else if (inval_data)
      cp_addr_inval_data <= nxt_cp_addr_inval_data;

  assign lookup_stall = (~cp_dbg_data & ctl_stall_tag_cp15_i) |
                        ( cp_dbg_data & ctl_stall_data_cp15_i);
  assign bubble_stall = (~cp_dbg_data & ctl_stall_tag_cp15_if1_i) |
                        ( cp_dbg_data & ctl_stall_data_cp15_if1_i);

  // For Invalidation_all secure and non secure address
  //---------------------------------------------------
  assign last_inval_addr   = (top_address[11:3] == cp_addr_inval_reg[11:3]) & (~inval_data | (top_address[2:0] == cp_addr_inval_reg[2:0]));
  assign top_address       = { ic_size_i, {9{1'b1}} };

  //For counting till the top of the address for invalidation
  //but address incrementing only in the Write stages both
  //for invalidate all secure and non secure.
  assign incr_inval_addr_en = cp_inval_all & ~ctl_stall_tag_cp15_i & (cp15_st == CP15_ST_WRITE_IF0 | cp15_st == CP15_ST_WRITE_P1_IF0);
  assign next_inval_addr    = !last_inval_addr ? inval_data ? cp_addr_inval_reg + 12'h001 : cp_addr_inval_reg + 12'h008 : 12'h000;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cp_addr_inval_reg <= {12{1'b0}};
    else if (incr_inval_addr_en)
      cp_addr_inval_reg <= next_inval_addr;

  // For PA address by counting till the top of the address
  //-------------------------------------------------------
  assign last_pa_addr    = ic_size_i == cp_addr_pa_reg;

  // For counting till the top of the PA address for invalidation
  assign incr_pa_addr_en = cp_pa_mode & ~(ctl_stall_tag_cp15_i & cp_tag_en != 2'b00) & cp15_st == CP15_ST_WRITE_IF0;
  assign next_pa_addr    = !last_pa_addr ? cp_addr_pa_reg + 3'b001 : 3'b000;

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cp_addr_pa_reg <= 3'b000;
    else if (incr_pa_addr_en)
      cp_addr_pa_reg <= next_pa_addr;

  // Registered outputs for ifu_cp_ack signal which comes high in
  // look up state for one cycle which should give the ack only
  // when there is a change in op_reg register
  //--------------------------------------------------------------
  assign ack_en     = addr_op_store | // short ops but not debug and inval_all at teh start
                      (cp15_st == CP15_ST_BUBBLE_IF1 & ~bubble_stall) | // every bubble sequence to get dbg acking
                      cp_ack; // clear

  assign nxt_cp_ack = (cp15_st == CP15_ST_IDLE       & ~dcu_dbg_op & ~cp_ack)   | // all operations except debug, including dvm at start with mbist set
                      (cp15_st == CP15_ST_WRITE_IF0  & dcu_short_req) | // all back to back operations except debug, inv by pa or inval_all
                      (cp15_st == CP15_ST_BUBBLE_IF1 & cp_dbg_op);      // debug operations


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      cp_ack  <= 1'b0;
    else if (ack_en)
      cp_ack <= nxt_cp_ack;

  // Parity invalidate ack
  assign cp15_pty_ack_en  = ((cp15_st == CP15_ST_IDLE) & ctl_pty_inv_req_i) | cp15_pty_ack;
  assign nxt_cp15_pty_ack =  cp15_st == CP15_ST_IDLE;

  always @ (posedge clk or negedge reset_n)
    if (!reset_n)
      cp15_pty_ack <= 1'b0;
    else if (cp15_pty_ack_en)
      cp15_pty_ack <= nxt_cp15_pty_ack;


  // CP busy signal which should be high when in short op and not in idle mode
  //-------------------------------------------------------------------------
  assign cp_busy[1] = (cp15_st != CP15_ST_IDLE) & inval_data;
  assign cp_busy[0] = (cp15_st == CP15_ST_IDLE & ctl_pty_inv_req_i) |
                      (dcu_cp_op_i != CP15_ICACHE_INV_ALL & dcu_cp_op_i != CP15_ICACHE_INV_PA & cp15_st == CP15_ST_IDLE & dcu_valid_present) |
                      (cp15_st != CP15_ST_IDLE & ~cp_inval_all & ~cp_pa_mode);

  // Outputs for cp_active signal which comes high  when not in idle stage.
  assign cp_active[0] = cp15_st != CP15_ST_IDLE;
  assign cp_active[1] = cp15_st != CP15_ST_IDLE & cp_op_reg != CP15_ICACHE_DBG_TAG & cp_op_reg != CP15_ICACHE_DBG_DATA & cp_op_reg != CP15_ICACHE_INV_PTY;

  // Outputs for hazard logic
  assign cp15_hazard_ack[0] = cp_ack & ((cp_inval_all & ~cp_ns_reg) | cp_inval_by_addr);
  assign cp15_hazard_ack[1] = cp_ack & ((cp_inval_all &  cp_ns_reg) | cp_inval_by_addr);

  //
  // This section is only needed for inval all non-secure. This operation could stall between corresponding lookups
  // and writes becuase we do two lookups followed by two writes, the second one could stall while the first goes ahead
  // we need a mechanism to collect the results of the first lookup while stalling for the second one
  //
  // most important counter value:
  // o we collect the results from the comparison to possibly be used later
  // o we reset the counter
  // o when the time comes we use it to decide which comparison register to use
  assign count_even_set = count_even == 2'b00;
  assign count_odd_set  = count_odd  == 2'b00;

  // enable term for the counter
  // o during a lookup of an inval all non secure as long as we do not stall (if0)
  // o the following cycle as long as we do not stall due to a pre-fetch request (if1)
  // o the following cycle to reset the counter

  assign count_even_en  = (cp15_st == CP15_ST_LOOKUP_IF0 & ~ctl_stall_tag_cp15_i) |
                          (count_even == 2'b01 & ~bubble_stall)  |
                          count_even_set;
  assign count_odd_en   = (cp15_st == CP15_ST_LOOKUP_P1_IF0 & ~ctl_stall_tag_cp15_i) | // no need to qualify with inval all since only inval all can be here
                          (count_odd == 2'b01 & ~bubble_stall)      |
                          count_odd_set;
  // next counter value
  assign count_even_nxt = count_even_set ? 2'b10 : count_even - 2'b01;
  assign count_odd_nxt  = count_odd_set  ? 2'b10 : count_odd - 2'b01;
  // counter register
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      count_even <= 2'b10;
    else if (count_even_en)
      count_even <= count_even_nxt;
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      count_odd <= 2'b10;
    else if (count_odd_en)
      count_odd <= count_odd_nxt;
  // comparison register
  always @(posedge clk)
    if (count_even_set) begin
      compare_even_ns   <= compare_ns;
      compare_set_pa_ns <= compare_pa_ns;
    end
  always @(posedge clk)
    if (count_odd_set)
      compare_odd_ns <= compare_ns;

  // final selector:
  // counter == 0 it means no stall seen we can use the raw value
  // counter != 0 it means there must have been a stall use the register value
  assign compare_inval_even_ns = count_even_set ? compare_ns : compare_even_ns;
  assign compare_inval_odd_ns  = count_odd_set  ? compare_ns : compare_odd_ns;
  assign compare_inval_pa_ns   = count_even_set ? compare_pa_ns : compare_set_pa_ns;

  // Case statement to show what information is sent out to IFU in terms of TAG_en, DATA_en,
  // address and write.
  // We dont used cp_op_reg to differentiate between inval_all secure and non secure
  assign cp_op_mode[5:3] = ((cp_op_reg == CP15_ICACHE_INV_ALL) ? (cp_op_reg & {3{cp_ns_reg}}) : cp_op_reg) & {3{cp15_st != CP15_ST_BUBBLE_IF1}} & {3{cp15_st != CP15_ST_IDLE}};
  assign cp_op_mode[2:0] = cp15_st & {3{cp15_st != CP15_ST_BUBBLE_IF1}};
  // This is used for non secure invalidate all.
  assign cp_addr_inval_reg_p1 = cp_addr_inval_reg[11:3] + 9'h001;
  // special TAG enable
  assign inval_tag_en = ((inval_data & cp_addr_inval_data[5:3] == 3'b000) | !inval_data) ? 2'b11 : 2'b00;

  always @*
  begin
    cp_addr    = {9{1'b0}};
    cp_tag_en  = 2'b00;
    cp_tag_wr  = 1'b0;
    cp_data_en = 2'b00;
    cp_data_wr = 1'b0;
    case (cp_op_mode)

      {CP15_ICACHE_INV_ALL_S,CP15_ST_WRITE_IF0}    : begin cp_addr = cp_addr_inval_reg[11:3]; cp_data_en = {2{inval_data}}; cp_data_wr = inval_data; cp_tag_en = inval_tag_en; cp_tag_wr = 1'b1; end
      {CP15_ICACHE_INV_ALL_S,CP15_ST_WRITE_P1_IF0} : begin cp_addr = cp_addr_inval_reg[11:3]; cp_data_en = {2{inval_data}}; cp_data_wr = inval_data; cp_tag_en = inval_tag_en; cp_tag_wr = 1'b1; end

      {CP15_ICACHE_INV_ALL,CP15_ST_LOOKUP_IF0}     : begin cp_addr = cp_addr_inval_reg[11:3];            cp_tag_en = 2'b11;                                  end
      {CP15_ICACHE_INV_ALL,CP15_ST_LOOKUP_P1_IF0}  : begin cp_addr = cp_addr_inval_reg_p1;               cp_tag_en = 2'b11;                                  end
      {CP15_ICACHE_INV_ALL,CP15_ST_WRITE_IF0}      : begin cp_addr = cp_addr_inval_reg[11:3];            cp_tag_en = compare_inval_even_ns;cp_tag_wr = 1'b1; end
      {CP15_ICACHE_INV_ALL,CP15_ST_WRITE_P1_IF0}   : begin cp_addr = cp_addr_inval_reg[11:3];            cp_tag_en = compare_inval_odd_ns; cp_tag_wr = 1'b1; end

      {CP15_ICACHE_INV_PTY,CP15_ST_PTY_INVAL}      : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = 2'b11;                cp_tag_wr = 1'b1; end

      {CP15_ICACHE_INV_MVA,CP15_ST_LOOKUP_IF0}     : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = 2'b11;                                  end
      {CP15_ICACHE_INV_MVA,CP15_ST_WRITE_IF0}      : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = compare_inval_pa_ns;  cp_tag_wr = 1'b1; end

      {CP15_ICACHE_INV_VA,CP15_ST_LOOKUP_IF0}      : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = 2'b11;                                  end
      {CP15_ICACHE_INV_VA,CP15_ST_WRITE_IF0}       : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = compare_inval_even_ns;cp_tag_wr = 1'b1; end

      {CP15_ICACHE_INV_PA,CP15_ST_LOOKUP_IF0}      : begin cp_addr = {cp_addr_pa_reg,cp_addr_reg[11:6]}; cp_tag_en = 2'b11;                                  end
      {CP15_ICACHE_INV_PA,CP15_ST_WRITE_IF0}       : begin cp_addr = {cp_addr_pa_reg,cp_addr_reg[11:6]}; cp_tag_en = compare_inval_pa_ns;  cp_tag_wr = 1'b1; end

      {CP15_ICACHE_DBG_TAG,CP15_ST_LOOKUP_IF0}     : begin cp_addr = cp_addr_reg[14:6];                  cp_tag_en = {cp_addr_reg[31],~cp_addr_reg[31]};     end

      {CP15_ICACHE_DBG_DATA,CP15_ST_LOOKUP_IF0}    : begin cp_addr = cp_addr_reg[14:6];                  cp_data_en = {cp_addr_reg[31],~cp_addr_reg[31]};    end
      // defualt case where no activity is done
      {CP15_ICACHE_INV_ALL_S,CP15_ST_IDLE},        // This covers every IDLE and BUBBLE operation not only the inval all secure
      {CP15_ICACHE_DBG_TAG,CP15_ST_WRITE_IF0},     // Debug ops in write do nothing
      {CP15_ICACHE_DBG_DATA,CP15_ST_WRITE_IF0}     : begin cp_addr = {9{1'b0}}; cp_tag_en = 2'b00; cp_tag_wr = 1'b0; cp_data_en = 2'b00; end
      // Illegal cases
      default   : begin cp_addr = {9{1'bx}}; cp_tag_en = 2'bxx;   cp_tag_wr = 1'bx; cp_data_en = 2'bxx;   end
    endcase
  end

  generate if (CPU_CACHE_PROTECTION) begin : genif_cpu_cache_protection
    reg first_op;
    reg inval_data_q;
    wire nxt_inval_data;
    wire inval_data_en;

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        first_op <= 1'b1;
      else if (dcu_valid_present)
        first_op <= 1'b0;

    assign nxt_inval_data = (first_op     & (cp15_st == CP15_ST_IDLE) & dcu_valid_present) | // set
                            (inval_data_q & (cp15_st != CP15_ST_IDLE) ); // clear

    assign inval_data_en = inval_data_q ^ nxt_inval_data;

    always @ (posedge clk or negedge reset_n)
      if (!reset_n)
        inval_data_q  <= 1'b0;
      else if (inval_data_en)
        inval_data_q  <= nxt_inval_data;

    assign inval_data = inval_data_q;

    // Remove parity bits from data when CPU cache protection is configured.
    // Parity checking is not performed for debug accesses.
    assign ic_dataram_rdata0 = {ic_dataram_rdata0_i[82:63], ic_dataram_rdata0_i[61:42], ic_dataram_rdata0_i[40:21], ic_dataram_rdata0_i[19:0]};
    assign ic_dataram_rdata1 = {ic_dataram_rdata1_i[82:63], ic_dataram_rdata1_i[61:42], ic_dataram_rdata1_i[40:21], ic_dataram_rdata1_i[19:0]};

    // Comparison of TAG Data
    // if parity error present we always invalidate even if the tag is invalid since the error could be on the valid bits
    wire [1:0] tag_parity_err;
    assign tag_parity_err[0] = ic_tagram_rdata0_i[31] != (^ic_tagram_rdata0_i[30:0]);
    assign tag_parity_err[1] = ic_tagram_rdata1_i[31] != (^ic_tagram_rdata1_i[30:0]);
    assign compare_ns[0] = (ic_tagram_rdata0_i[30:29] != 2'b11 & ic_tagram_rdata0_i[28] == cp_ns_reg) | tag_parity_err[0];
    assign compare_ns[1] = (ic_tagram_rdata1_i[30:29] != 2'b11 & ic_tagram_rdata1_i[28] == cp_ns_reg) | tag_parity_err[1];
    assign compare_pa[0] = (ic_tagram_rdata0_i[27:0] == {cp_addr_reg[39:15],cp_addr_reg[2:0]}) | tag_parity_err[0];
    assign compare_pa[1] = (ic_tagram_rdata1_i[27:0] == {cp_addr_reg[39:15],cp_addr_reg[2:0]}) | tag_parity_err[1];
    assign compare_pa_ns = compare_ns & compare_pa;
  end else begin : genif_cpu_cache_protection_stubs

    assign inval_data = 1'b0;

    assign ic_dataram_rdata0 = ic_dataram_rdata0_i[79:0];
    assign ic_dataram_rdata1 = ic_dataram_rdata1_i[79:0];

    //Comparison of TAG Data
    assign compare_ns[0] = ic_tagram_rdata0_i[30:29] != 2'b11 & ic_tagram_rdata0_i[28] == cp_ns_reg;
    assign compare_ns[1] = ic_tagram_rdata1_i[30:29] != 2'b11 & ic_tagram_rdata1_i[28] == cp_ns_reg;
    assign compare_pa[0] = ic_tagram_rdata0_i[27:0] == {cp_addr_reg[39:15],cp_addr_reg[2:0]};
    assign compare_pa[1] = ic_tagram_rdata1_i[27:0] == {cp_addr_reg[39:15],cp_addr_reg[2:0]};
    assign compare_pa_ns = compare_ns & compare_pa;
  end endgenerate

  always @*
    case ({cp_op_reg == CP15_ICACHE_DBG_DATA,cp_addr_reg[31] ,cp_addr_reg[3:2]})
      4'b0000,
      4'b0001,
      4'b0010,
      4'b0011 : begin cp_dbg_0 =              ic_tagram_rdata0_i[30:0] ; cp_dbg_1 = {20{1'b0}};               end // TAG way 0
      4'b0100,
      4'b0101,
      4'b0110,
      4'b0111 : begin cp_dbg_0 =              ic_tagram_rdata1_i[30:0] ; cp_dbg_1 = {20{1'b0}};               end // TAG way 1
      4'b1000 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata0[19:0] }; cp_dbg_1 = ic_dataram_rdata0[39:20]; end // Data way 0 bank 0 bottom
      4'b1001 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata0[59:40]}; cp_dbg_1 = ic_dataram_rdata0[79:60]; end // Data way 0 bank 0 top
      4'b1010 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata1[19:0] }; cp_dbg_1 = ic_dataram_rdata1[39:20]; end // Data way 0 bank 1 bottom
      4'b1011 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata1[59:40]}; cp_dbg_1 = ic_dataram_rdata1[79:60]; end // Data way 0 bank 0 top
      4'b1100 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata1[19:0] }; cp_dbg_1 = ic_dataram_rdata1[39:20]; end // Data way 1 bank 1 bottom
      4'b1101 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata1[59:40]}; cp_dbg_1 = ic_dataram_rdata1[79:60]; end // Data way 1 bank 1 top
      4'b1110 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata0[19:0] }; cp_dbg_1 = ic_dataram_rdata0[39:20]; end // Data way 1 bank 0 bottom
      4'b1111 : begin cp_dbg_0 = {{11{1'b0}}, ic_dataram_rdata0[59:40]}; cp_dbg_1 = ic_dataram_rdata0[79:60]; end // Data way 1 bank 0 top
      default : begin cp_dbg_0 =  {31{1'bx}};                            cp_dbg_1 = {20{1'bx}};               end
    endcase

  //Outputs

  // register the data to the TLB for timing reason. Enabled for only two cycles
  // o when it is due to be send
  // o and the cycle after to clear it
  assign nxt_cp_dbg_valid = cp_dbg_op & cp15_st == CP15_ST_WRITE_IF0;
  assign en_cp_dbg_valid  = nxt_cp_dbg_valid | cp_dbg_valid;

  always @(posedge clk or negedge reset_n)
    if(!reset_n)
      cp_dbg_valid <= 1'b0;
    else if (en_cp_dbg_valid)
      cp_dbg_valid <= nxt_cp_dbg_valid;

  always @(posedge clk)
    if (en_cp_dbg_valid) begin
      cp_dbg_0_reg <= cp_dbg_0;
      cp_dbg_1_reg <= cp_dbg_1;
    end

  assign ifu_cp_dbg_0_o     = {1'b0,    cp_dbg_0_reg[30:0]};  // Expand to 32-bits
  assign ifu_cp_dbg_1_o     = {12'h000, cp_dbg_1_reg[19:0]};
  assign ifu_cp_dbg_valid_o = cp_dbg_valid;

  assign ifu_cp_ack_o       = cp_ack;

  assign cp15_pty_ack_o     = cp15_pty_ack;
  assign cp15_tag_en_o      = cp_tag_en;
  assign cp15_tag_wr_o      = cp_tag_wr;
  assign cp15_data_en_o     = cp_data_en;
  assign cp15_data_wr_o     = cp_data_wr;
  assign cp15_addr_o        = {cp_addr, inval_data ? cp_addr_inval_data[5:3] : cp_addr_reg[5:3]};
  assign cp15_busy_if1_o    = cp_busy;
  assign cp15_active_o      = cp_active;
  assign cp15_hazard_ack_o  = cp15_hazard_ack;

  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  reg                ovl_dtr;
  reg                ovl_ddr;
  always @(posedge clk or negedge reset_n)
    if(!reset_n) begin
      ovl_dtr <= 1'b0;
      ovl_ddr <= 1'b0;
    end else if (ifu_cp_ack_o) begin
      ovl_dtr <= dcu_cp_op_i == `CA53_CP_ICACHE_DBG_TAG;
      ovl_ddr <= dcu_cp_op_i == `CA53_CP_ICACHE_DBG_DATA;
    end

  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: cp15_pty_ack_en")
  u_ovl_x_cp15_pty_ack_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (cp15_pty_ack_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: en_cp_dbg_valid")
  u_ovl_x_en_cp_dbg_valid (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (en_cp_dbg_valid));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ack_en")
  u_ovl_x_ack_en (.clk       (clk),
                  .reset_n   (reset_n),
                  .qualifier (1'b1),
                  .test_expr (ack_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: addr_op_store_en")
  u_ovl_x_addr_op_store_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (addr_op_store_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: count_even_en")
  u_ovl_x_count_even_en (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (count_even_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: count_even_set")
  u_ovl_x_count_even_set (.clk       (clk),
                          .reset_n   (reset_n),
                          .qualifier (1'b1),
                          .test_expr (count_even_set));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: count_odd_en")
  u_ovl_x_count_odd_en (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (count_odd_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: count_odd_set")
  u_ovl_x_count_odd_set (.clk       (clk),
                         .reset_n   (reset_n),
                         .qualifier (1'b1),
                         .test_expr (count_odd_set));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: ifu_cp_ack_o")
  u_ovl_x_ifu_cp_ack_o (.clk       (clk),
                        .reset_n   (reset_n),
                        .qualifier (1'b1),
                        .test_expr (ifu_cp_ack_o));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: incr_inval_addr_en")
  u_ovl_x_incr_inval_addr_en (.clk       (clk),
                              .reset_n   (reset_n),
                              .qualifier (1'b1),
                              .test_expr (incr_inval_addr_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: incr_pa_addr_en")
  u_ovl_x_incr_pa_addr_en (.clk       (clk),
                           .reset_n   (reset_n),
                           .qualifier (1'b1),
                           .test_expr (incr_pa_addr_en));


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug Tag Read op incorrect ifu_cp_dbg_1_o[31]")
  ovl_dbgtag_read_0 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (ifu_cp_dbg_valid_o && ovl_dtr),
                     .consequent_expr (ifu_cp_dbg_0_o[31] == 1'b0));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug Tag Read op incorrect register")
  ovl_dbgtag_read_1 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (ifu_cp_dbg_valid_o && ovl_dtr),
                     .consequent_expr (ifu_cp_dbg_1_o == {32{1'b0}}));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug Tag Data op incorrect ifu_cp_dbg_0_o[31:20]")
  ovl_dbgdata_read_0 (.clk             (clk),
                      .reset_n         (reset_n),
                      .antecedent_expr (ifu_cp_dbg_valid_o && ovl_ddr),
                      .consequent_expr (ifu_cp_dbg_0_o[31:20] == {12{1'b0}}));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Debug Tag Read op incorrect register")
  ovl_dbgdata_read_1 (.clk             (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr (ifu_cp_dbg_valid_o && ovl_ddr),
                     .consequent_expr (ifu_cp_dbg_1_o[31:20] == {12{1'b0}}));

  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Counter even should never be 2'b01 in Write state")
  ovl_count_even_01 (.clk            (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr ((cp15_st == CP15_ST_WRITE_IF0)),
                     .consequent_expr (count_even != 2'b01));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Counter odd should never be 2'b01 in Write state")
  ovl_count_odd_01  (.clk            (clk),
                     .reset_n         (reset_n),
                     .antecedent_expr ((cp15_st == CP15_ST_WRITE_P1_IF0)),
                     .consequent_expr (count_odd != 2'b01));
  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Counter even should never be 2'b11 in CP15")
  ovl_count_even_11 (.clk         (clk),
                     .reset_n     (reset_n),
                     .test_expr   (count_even == 2'b11));
  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Counter odd should never be 2'b11 in CP15")
  ovl_count_odd_11 (.clk         (clk),
                    .reset_n     (reset_n),
                    .test_expr   (count_odd == 2'b11));

  assert_never #(`OVL_FATAL, `OVL_ASSERT,"Debug cp state should never be 3'b111 in CP15")
  ovl_cp_state_reg  (.clk         (clk),
                     .reset_n     (reset_n),
                     .test_expr   ((cp15_st == 3'b111)));

  // Check that cp_op_mode is a legal value
  //   - bits[5:3] should be a valid type of operation, even if that state
  //      machine is idle
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[5:3] has an illegal value")
    ovl_cp_op_mode_5_3
      (.clk       (clk),
       .reset_n   (reset_n),
       .test_expr ((cp_op_mode[5:3] == CP15_ICACHE_INV_ALL_S) |
                   (cp_op_mode[5:3] == CP15_ICACHE_INV_ALL)   |
                   (cp_op_mode[5:3] == CP15_ICACHE_INV_VA)    |
                   (cp_op_mode[5:3] == CP15_ICACHE_INV_PA)    |
                   (cp_op_mode[5:3] == CP15_ICACHE_INV_MVA)   |
                   (cp_op_mode[5:3] == CP15_ICACHE_DBG_TAG)   |
                   (cp_op_mode[5:3] == CP15_ICACHE_DBG_DATA)  |
                   (cp_op_mode[5:3] == CP15_ICACHE_INV_PTY)));

  //   - If the state in bits[2:0] are IDLE then the operation type must be
  //     INV_ALL_S
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] == IDLE => cp_op_mode[5:3] == INV_ALL_S")
    ovl_cp_op_mode_2_0a
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (cp_op_mode[2:0] == CP15_ST_IDLE),
       .consequent_expr (cp_op_mode[5:3] == CP15_ICACHE_INV_ALL_S));

  //   - If the state in bits[2:0] are LOOKUP_IF0 then the operation type must NOT
  //     be INV_ALL_S
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] == LOOKUP_IF0 => cp_op_mode[5:3] != INV_ALL_S")
    ovl_cp_op_mode_2_0b
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (cp_op_mode[2:0] == CP15_ST_LOOKUP_IF0),
       .consequent_expr (cp_op_mode[5:3] != CP15_ICACHE_INV_ALL_S));

  //   - Bits[2:0] of cp_op_mode must NOT be BUBBLE_IF1
  assert_never #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] != BUBBLE_IF1")
    ovl_cp_op_mode_2_0c
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       (cp_op_mode[2:0] == CP15_ST_BUBBLE_IF1));

  //   - If the state in bits[2:0] are LOOKUP_P1_IF0 then the operation type must
  //     be INV_ALL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] == LOOKUP_P1_IF0 => cp_op_mode[5:3] == INV_ALL")
    ovl_cp_op_mode_2_0d
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (cp_op_mode[2:0] == CP15_ST_LOOKUP_P1_IF0),
       .consequent_expr (cp_op_mode[5:3] == CP15_ICACHE_INV_ALL));

  //   - If the state in bits[2:0] are WRITE_P1_IF0 then the operation type must
  //     be INV_ALL_S or INV_ALL
  assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] == WRITE_P1_IF0 => cp_op_mode[5:3] == [ INV_ALL_S, INV_ALL ]")
    ovl_cp_op_mode_2_0e
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (cp_op_mode[2:0] == CP15_ST_WRITE_P1_IF0),
       .consequent_expr ((cp_op_mode[5:3] == CP15_ICACHE_INV_ALL) |
                         (cp_op_mode[5:3] == CP15_ICACHE_INV_ALL_S)));

  // cp15_st must be a valid state
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "cp15_st value is not one of the valid states")
    ovl_cp15_st
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       ((cp15_st == CP15_ST_IDLE)          |
                         (cp15_st == CP15_ST_LOOKUP_IF0)    |
                         (cp15_st == CP15_ST_BUBBLE_IF1)    |
                         (cp15_st == CP15_ST_WRITE_IF0)     |
                         (cp15_st == CP15_ST_LOOKUP_P1_IF0) |
                         (cp15_st == CP15_ST_WRITE_P1_IF0)  |
                         (cp15_st == CP15_ST_PTY_INVAL)));

  generate if (CPU_CACHE_PROTECTION) begin : ovl_pty

    // The prt_inval way must remain constant throughout the request.
    reg        ovl_ctl_pty_inv_req_reg;
    reg        ovl_cp15_pty_ack_reg;
    reg [14:6] ovl_ctl_pty_inv_addr_reg;
    always @(posedge clk or negedge reset_n)
      if(!reset_n) begin
        ovl_ctl_pty_inv_req_reg <= 1'b0;
        ovl_cp15_pty_ack_reg    <= 1'b0;
        ovl_ctl_pty_inv_addr_reg<= {9{1'b0}};
      end else begin
        ovl_ctl_pty_inv_req_reg <= ctl_pty_inv_req_i;
        ovl_cp15_pty_ack_reg    <= cp15_pty_ack_o;
        ovl_ctl_pty_inv_addr_reg<= ctl_pty_inv_addr_i;
      end

    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "ADDR must be constant through a parity request")
    u_ovl_pty_addr (
                    .clk       (clk),
                    .reset_n   (reset_n),
                    .antecedent_expr (ovl_ctl_pty_inv_req_reg & ~ovl_cp15_pty_ack_reg),
                    .consequent_expr (ctl_pty_inv_addr_i == ovl_ctl_pty_inv_addr_reg));

    //   - If the state in bits[2:0] are PTY_INVAL then the operation type must
    //     be INV_MVA
    assert_implication #(`OVL_FATAL, `OVL_ASSERT, "cp_op_mode[2:0] == PTY_INVAL => cp_op_mode[5:3] == INV_PTY")
    ovl_cp_op_mode_2_0f
      (.clk             (clk),
       .reset_n         (reset_n),
       .antecedent_expr (cp_op_mode[2:0] == CP15_ST_PTY_INVAL),
       .consequent_expr (cp_op_mode[5:3] == CP15_ICACHE_INV_PTY));

  end endgenerate
`endif

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "ca53_dcu_ifu_defs.v"
`include "cortexa53params.v"
`undef CA53_UNDEFINE
/*END*/

