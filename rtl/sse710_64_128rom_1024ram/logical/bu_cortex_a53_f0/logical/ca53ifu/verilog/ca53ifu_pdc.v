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
//      Checked In          : $Date: 2012-07-27 16:33:28 +0100 (Fri, 27 Jul 2012) $
//
//      Revision            : $Revision: 216708 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------
// Abstract : Pre-decode correction
//-----------------------------------------------------------------------------

module ca53ifu_pdc
 (
  // Clocks and resets
  input wire          clk,
  input wire          reset_n,

  // Pre-decode PFB-ICB interface
  input wire          pfb_pdc_req_if3_i,
  input wire [28:0]   pfb_pdc_data_if3_i,
  input wire [14:1]   pfb_pdc_addr_if3_i,
  input wire [1:0]    pfb_pdc_way_low_if3_i,
  input wire [1:0]    pfb_pdc_way_high_if3_i,
  input wire [1:0]    pfb_valid_buffers_i,
  input wire          icb_pdc_hazard_if2_i,
  output wire         icb_pdc_valid_if2_o,

  // Arbitration
  input wire          ctl_stall_pdc_i,
  input wire          ctl_seq_miss_if3_i,
  input wire          ctl_stall_pfb_i,
  input wire          ctl_valid_if2_i,
  output wire [39:0]  pd_pdc_data_o,    //  cache way
  output wire         pdc_req_o,        //  PDC to ctl: request
  output wire [3:0]   pdc_en_if0_o,     //  cache way
  output wire [14:3]  pdc_addr0_if0_o,  //  virtual address
  output wire [14:3]  pdc_addr1_if0_o,  //  virtual address
  output wire [159:0] pdc_wdata_if0_o,  //  corrected data for cache
  output wire [7:0]   pdc_strb_if0_o    //  strobes

);

  //-------------------------------------------------------------------------
  // Local Parmameters
  //-------------------------------------------------------------------------
  localparam PDC_ST_W = 2;
  localparam [PDC_ST_W-1:0] PDC_ST_IDLE           = 2'b00;
  localparam [PDC_ST_W-1:0] PDC_ST_FIRST          = 2'b01;
  localparam [PDC_ST_W-1:0] PDC_ST_SECOND         = 2'b10;
  localparam [PDC_ST_W-1:0] PDC_ST_FIRST_NO_WRITE = 2'b11;

  //-------------------------------------------------------------------------
  // wire declaration
  //-------------------------------------------------------------------------

  wire [1:0]          pdc_valid_buffer_nxt;
  wire                pdc_valid_buffer_en;
  wire                pdc_clear_way_en;
  wire [39:0]         pdc_encoding;
  wire                pdc_req;
  wire                pdc_cache_first;
  wire                pdc_cache_second;
  wire [2:0]          pdc_selector;
  wire [14:3]         pdc_addr_p1;
  wire [14:3]         pdc_addr0;
  wire [14:3]         pdc_addr1;
  wire                pdc_eocl;
  wire                pdc_enable;
  wire [5:0]          t32_sideband;
  wire [2:0]          t16_sideband;
  wire                nxt_pdc_way_first;

  //-------------------------------------------------------------------------
  // reg declaration
  //-------------------------------------------------------------------------
  reg [28:0]          pdc_data;
  reg [14:1]          pdc_addr;
  reg                 pdc_way_first;
  reg [3:0]           pdc_en;
  reg [7:0]           pdc_strb;
  reg [159:0]         pdc_wdata;
  reg                 pdc_valid;
  reg                 pdc_write_first;
  reg                 pdc_write_second;
  reg                 pdc_will_write_second;

  reg [PDC_ST_W-1:0]  pdc_st;
  reg [PDC_ST_W-1:0]  pdc_st_next;

  reg [1:0]           pdc_valid_buffer;
  reg                 pdc_clear_way;

  //-------------------------------------------------------------------------
  // Main Code
  //-------------------------------------------------------------------------

  //
  // State machine
  //
  always @*
    case (pdc_st)
      // Go to first if a cacheable request is seen and both ways are matching and wayhigh !=0.
      // Go to first if we are at the top of the cache line and and wayhigh and waylow is !=0.
      // Otherwise we stay in IDLE

      PDC_ST_IDLE : pdc_st_next = (pfb_pdc_req_if3_i && pdc_write_first)   ? PDC_ST_FIRST :
                                  pfb_pdc_req_if3_i                        ? PDC_ST_FIRST_NO_WRITE :
                                                                             PDC_ST_IDLE;
      // when caches are not involved we go back to idle
      PDC_ST_FIRST_NO_WRITE : pdc_st_next = PDC_ST_IDLE;

      // Drop the request if during icu_valid the request drops
      // Don't move if we are stalling or
      // Go to second when two writes are required and both ways are different, non zero top of cache line
      // Go to idle when a single write to the RAM is sufficient
      PDC_ST_FIRST : pdc_st_next = ctl_stall_pdc_i  ? PDC_ST_FIRST  :
                                   pdc_write_second ? PDC_ST_SECOND :
                                                      PDC_ST_IDLE;
      // Don't move if we are stalling or
      // Go to first if a new PDC cacheable request is seen or
      // Go to first no write if a request that does not need cache write is seen
      // Go to idle
      PDC_ST_SECOND : pdc_st_next = ctl_stall_pdc_i                        ? PDC_ST_SECOND :
                                    (pfb_pdc_req_if3_i && pdc_write_first) ? PDC_ST_FIRST  :
                                     pfb_pdc_req_if3_i                     ? PDC_ST_FIRST_NO_WRITE :
                                                                             PDC_ST_IDLE;

      default : pdc_st_next = {PDC_ST_W{1'bx}};
    endcase // case (pdc_st)


  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pdc_st <= PDC_ST_IDLE;
    else
      pdc_st <= pdc_st_next;

  // If we see a sequential miss due to a CP15 maintanance operation we do not correct the
  // cache while fetch Q buffers are working through the old data
  //
  // update the counter
  // o at start: during a sequential miss set the counter to the number of buffers valid
  // o new buffer: while the fetch Q buffer are moving
  assign pdc_valid_buffer_nxt = ctl_seq_miss_if3_i ? pfb_valid_buffers_i : pdc_valid_buffer - 2'b01;
  assign pdc_valid_buffer_en  = ctl_seq_miss_if3_i | (~ctl_stall_pfb_i & ctl_valid_if2_i & pdc_valid_buffer != 2'b00);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pdc_valid_buffer <= 2'b00;
    else if (pdc_valid_buffer_en)
      pdc_valid_buffer <= pdc_valid_buffer_nxt;

  // set the way
  // o at start always as long the buffers are not empty
  // o at the end when the buffers are empty
  assign pdc_clear_way_en  = (ctl_seq_miss_if3_i & pfb_valid_buffers_i != 2'b00) | (pdc_clear_way & pdc_valid_buffer == 2'b00);

  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pdc_clear_way <= 1'b0;
    else if (pdc_clear_way_en)
      pdc_clear_way <= ctl_seq_miss_if3_i;

  // There are some cases when the WAYs given by the PF are different even if within the same cache line.
  // Usually this cannot happen but there are at least one corner case when this is possible.
  // case 1) When a T32A comes from the cache and before the PF gets the T32B the cache location in question
  //         gets overwritten with an allocation. The T32B then is grabbed from outside and it could actually
  //         be placed to a different way.
  // case 2) When a utlb flush causes one prefetch line to have the same va but different pa, again in that
  //         case the way could be different.
  //
  // In those cases we do not update the cache, if the PF makes a request again to the same entry it will be
  // fixed then.  Additionally we don't update the cache if the control logic signals a PDC hazard.

  // end of cache line recognition
  assign pdc_eocl = (pfb_pdc_addr_if3_i[5:1] == 5'b11111);
  // write to the cache conditions
  always @*
    case ({pfb_pdc_way_low_if3_i,pfb_pdc_way_high_if3_i} & {4{~pdc_clear_way}} & {4{~icb_pdc_hazard_if2_i}})
      4'b00_00 : begin pdc_write_first = 1'b0;     pdc_will_write_second = 1'b0;     end
      4'b00_01 : begin pdc_write_first = 1'b0;     pdc_will_write_second = 1'b0;     end
      4'b00_10 : begin pdc_write_first = 1'b0;     pdc_will_write_second = 1'b0;     end

      4'b01_00 : begin pdc_write_first = 1'b0;     pdc_will_write_second = 1'b0;     end
      4'b01_01 : begin pdc_write_first = 1'b1;     pdc_will_write_second = 1'b0;     end
      4'b01_10 : begin pdc_write_first = pdc_eocl; pdc_will_write_second = pdc_eocl; end

      4'b10_00 : begin pdc_write_first = 1'b0;     pdc_will_write_second = 1'b0;     end
      4'b10_01 : begin pdc_write_first = pdc_eocl; pdc_will_write_second = pdc_eocl; end
      4'b10_10 : begin pdc_write_first = 1'b1;     pdc_will_write_second = 1'b0;     end

      //Illegal case [0011, 0111, 1011, 1100, 1101, 1110] covered by assertion
      default :  begin pdc_write_first = 1'bx;     pdc_will_write_second = 1'bx;     end
    endcase

  // machine state flags
  assign pdc_cache_first  = pdc_st == PDC_ST_FIRST;
  assign pdc_cache_second = pdc_st == PDC_ST_SECOND;

  // Clock gating:
  // o a request during Idle
  // o a request during Second and we are not stalling
  assign pdc_enable      = ((pdc_st == PDC_ST_IDLE)   & pfb_pdc_req_if3_i) |
                           ((pdc_st == PDC_ST_SECOND) & pfb_pdc_req_if3_i & ~ctl_stall_pdc_i);

  //
  // Local Registers
  //
  always @(posedge clk)
    if (pdc_enable) begin
      pdc_way_first    <= nxt_pdc_way_first;
      pdc_write_second <= pdc_will_write_second;
      pdc_addr         <= pfb_pdc_addr_if3_i;
      pdc_data         <= pfb_pdc_data_if3_i;
    end

  assign nxt_pdc_way_first = pfb_pdc_way_low_if3_i[1] & pdc_write_first;

  // Two different cases when we are at the end of the cache line,
  // and when we are are at the end of the bank line, otherwise
  // just use the same address in addr1.
  assign pdc_addr_p1  = pdc_addr[14:3] + 12'h001;


  //T16 Sideband Calculation
  ca53ifu_pdc_t16 u_ca53ifu_pdc_t16_0(.raw_encoding_i    (pdc_data[15:0]),
                                      .sideband_o        (t16_sideband)
                                     );

  //T32 Sideband Calculation
  ca53ifu_pdc_t32 u_ca53ifu_pdc_t32_0 (.raw_encoding_i (pdc_data[28:0]),
                                       .sideband_o     (t32_sideband)
                                      );

  // Packing the corrected data for the cache even if eocl is high as the trusted decoder needs to know the correct
  // sideband to make a decision
  assign pdc_encoding = {1'b0,
                         t16_sideband,
                         pdc_data[15:0],
                         1'b1,
                         t32_sideband,
                         pdc_data[28:16]};

  // Output to the PFB
  assign pd_pdc_data_o = pdc_encoding;

  //
  // main selector
  //
  // way|addr[3]|bank
  //  0 |  0    | 0
  //  0 |  1    | 1
  //  1 |  0    | 1
  //  1 |  1    | 0
  assign pdc_selector[2]   = pdc_way_first ^ pdc_addr[3]; // bank selector
  assign pdc_selector[1:0] = pdc_addr[2:1]; // strobes and data selector

  // select address by bank. This works for all the single write cases
  // and the first of the two-write case
  assign pdc_addr0 = pdc_selector[2] ? pdc_addr_p1 : pdc_addr[14:3];
  assign pdc_addr1 = pdc_selector[2] ? pdc_addr[14:3] : pdc_addr_p1;

  // select enable strobes and data.This works for all the single write cases
  // and the first of the two-write case
  always @*
    case (pdc_selector[2:0])
      3'b000 : begin pdc_en = { {3{1'b0}},   pdc_cache_first             }; pdc_wdata = {{120{1'b0}},pdc_encoding[39:0]            }; pdc_strb = 8'h03; end
      3'b001 : begin pdc_en = { {2{1'b0}},{2{pdc_cache_first}}           }; pdc_wdata = {{100{1'b0}},pdc_encoding[39:0],{ 20{1'b0}}}; pdc_strb = 8'h06; end
      3'b010 : begin pdc_en = { {2{1'b0}},   pdc_cache_first  , 1'b0     }; pdc_wdata = {{ 80{1'b0}},pdc_encoding[39:0],{ 40{1'b0}}}; pdc_strb = 8'h0c; end
      3'b011 : begin pdc_en = {    1'b0  ,{2{pdc_cache_first}}, 1'b0     }; pdc_wdata = {{ 60{1'b0}},pdc_encoding[39:0],{ 60{1'b0}}}; pdc_strb = 8'h18; end
      3'b100 : begin pdc_en = {    1'b0  ,   pdc_cache_first  ,{2{1'b0}} }; pdc_wdata = {{ 40{1'b0}},pdc_encoding[39:0],{ 80{1'b0}}}; pdc_strb = 8'h30; end
      3'b101 : begin pdc_en = {           {2{pdc_cache_first}},{2{1'b0}} }; pdc_wdata = {{ 20{1'b0}},pdc_encoding[39:0],{100{1'b0}}}; pdc_strb = 8'h60; end
      3'b110 : begin pdc_en = {              pdc_cache_first  ,{3{1'b0}} }; pdc_wdata = {            pdc_encoding[39:0],{120{1'b0}}}; pdc_strb = 8'hc0; end
      3'b111 : begin pdc_en = { pdc_cache_first, 2'b00, pdc_cache_first  }; pdc_wdata = {pdc_encoding[19:0],{120{1'b0}},pdc_encoding[39:20]}; pdc_strb = 8'h81; end
      default: begin pdc_en = {4{1'bx}}; pdc_wdata  = {160{1'bx}}; pdc_strb   = {8{1'bx}}; end
    endcase

  // Output to CTL
  // special case for the enable when it is done with two separate requests
  // due to the cahce line crossing with different ways. It can be set at the start
  // because pdc_req will tell when to use such enables. In the two-write case the
  // enables are the same for both requests 9either banck 0 always or bank 1 always,
  // in the single both are set
  assign pdc_en_if0_o    = pdc_write_second ? {pdc_selector[2],2'b00,~pdc_selector[2]} : pdc_en;
  // on those occasions that we write the second the bank info must swap.
  // The second write it is always at the same bank as the first one therefore a simple swap
  // will work
  assign pdc_addr0_if0_o = pdc_cache_second ? pdc_addr1 : pdc_addr0;
  assign pdc_addr1_if0_o = pdc_cache_second ? pdc_addr0 : pdc_addr1;
  assign pdc_strb_if0_o  = pdc_cache_second ? {pdc_strb[3:0],pdc_strb[7:4]} : pdc_strb;
  assign pdc_wdata_if0_o = pdc_cache_second ? {pdc_wdata[79:0],pdc_wdata[159:80]} : pdc_wdata;

  //
  // Request
  //
  assign pdc_req    = pdc_cache_first | pdc_cache_second;
  assign pdc_req_o  = pdc_req;

  //
  // valid
  //
  // we always ack the cycle after we collect the necessary data
  always @(posedge clk or negedge reset_n)
    if (!reset_n)
      pdc_valid <= 1'b0;
    else
      pdc_valid <= pdc_enable;

  assign icb_pdc_valid_if2_o = pdc_valid;

  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------

`ifdef ARM_ASSERT_ON
  // ARMAUTO_X
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pdc_clear_way_en")
  u_ovl_x_pdc_clear_way_en (.clk       (clk),
                            .reset_n   (reset_n),
                            .qualifier (1'b1),
                            .test_expr (pdc_clear_way_en));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pdc_enable")
  u_ovl_x_pdc_enable (.clk       (clk),
                      .reset_n   (reset_n),
                      .qualifier (1'b1),
                      .test_expr (pdc_enable));

  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "Register enable x-check: pdc_valid_buffer_en")
  u_ovl_x_pdc_valid_buffer_en (.clk       (clk),
                               .reset_n   (reset_n),
                               .qualifier (1'b1),
                               .test_expr (pdc_valid_buffer_en));


  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Way low in PDC should never be 2'b11 as it is Non-Applicable")
  ovl_pfb_pdc_way_low_if3_i  (.clk             (clk),
                              .reset_n         (reset_n),
                              .antecedent_expr (pfb_pdc_req_if3_i),
                              .consequent_expr (pfb_pdc_way_low_if3_i != 2'b11));
  assert_implication #(`OVL_FATAL,`OVL_ASSERT,"Way high in PDC should never be 2'b11 as it is Non-Applicable")
  ovl_pfb_pdc_way_high_if3_i  (.clk             (clk),
                               .reset_n         (reset_n),
                               .antecedent_expr (pfb_pdc_req_if3_i),
                               .consequent_expr (pfb_pdc_way_high_if3_i != 2'b11));

  // pdc_st must be a valid state
  assert_always #(`OVL_FATAL, `OVL_ASSERT, "cp15_st value is not one of the valid states")
    ovl_pdc_st
      (.clk             (clk),
       .reset_n         (reset_n),
       .test_expr       ((pdc_st == PDC_ST_IDLE)   |
                         (pdc_st == PDC_ST_FIRST)  |
                         (pdc_st == PDC_ST_SECOND) |
                         (pdc_st == PDC_ST_FIRST_NO_WRITE)));

  // pdc_write_first case statement output should not hit the default case
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pdc_write_first case output X")
    ovl_pdc_write_first_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       ((pdc_st != PDC_ST_IDLE)),
       .test_expr       (pdc_write_first));

  // pdc_will_write_second case statement output should not hit the default case
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "pdc_will_write_second case output X")
    ovl_pdc_will_write_second_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       ((pdc_st != PDC_ST_IDLE)),
       .test_expr       (pdc_will_write_second));

  // pdc_en case statement output should not hit the default case
  assert_never_unknown #(`OVL_FATAL, 4, `OVL_ASSERT, "pdc_en case output X")
    ovl_pdc_en_x
      (.clk             (clk),
       .reset_n         (reset_n),
       .qualifier       ((pdc_st != PDC_ST_IDLE)),
       .test_expr       (pdc_en));

`endif

endmodule
