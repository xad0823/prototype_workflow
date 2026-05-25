//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2011-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2012-05-23 16:00:38 +0100 (Wed, 23 May 2012) $
//
//      Revision            : $Revision: 209955 $
//
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------
//
// NOTE : The module is customize for CortexA53
//-----------------------------------------------------------------------------

module ca53_l2dataramtest_number2   #(parameter RAM_ID      = 4'b0000,  // Unique ID
                                      parameter ADDR_WIDTH  = 11,       // Addr bits
                                      parameter RAM_TYPE    = 2'b00  ,  // RAM type
                                      parameter NUM_BANKS   = 8,        // Number of Banks
                                      parameter BYTE_WIDTH  = 8,        // Byte or bit granularity
                                      parameter WORD_WIDTH  = 32,       // width of RAM to test
                                      parameter NUM_STRBS   = 4,       // Number of strbs
                                      parameter CHK_LATENCY = 1,
                                      parameter L2_DATARAM_WAYS = 1)
  (

   input wire                                    clk,
   input wire                                    reset_n,
   input wire                                    start_i,
   input wire [((WORD_WIDTH* NUM_BANKS) - 1):0]  rdata_i,           // Ram read data
   input wire [ADDR_WIDTH-1:0]                   max_range_i,
   input wire [((WORD_WIDTH* NUM_BANKS) - 1):0]  expected_data,
   input wire                                    l2_wr_latency_i,
   input wire                                    l2_rd_latency_i,

   output reg  [ADDR_WIDTH-1:0]                  addr_o,           // Ram address
   output wire [WORD_WIDTH -1:0]                 wdata_o,          // Ram write data
   output wire [WORD_WIDTH -1:0]                 wdata_check_o,      // Expected Word
   output wire [NUM_BANKS-1:0]                   enable_o,        // Even enables
   output wire                                   wr_en_o,         // Overall write enable
   output wire [NUM_BANKS-1:0]                   clk_en_o,
   output reg  [NUM_STRBS-1:0]                   wrbyte_en_o,     // Byte write enable.
   output wire [3:0]                             bank_cnt_o,
   output reg  [3:0]                             l2dataram_way_o,
   output wire                                   passed_o,
   output wire                                   done_o,
   output wire                                   in_progress_o,
   output wire                                   reset_data_word_o
   );

  // -----------------------------------------------------------------------------
  // Define states for word and walking ones tests
  // -----------------------------------------------------------------------------

  localparam RAM_ST_W = 3;
  localparam [RAM_ST_W-1:0] RAM_ST_IDLE       = 3'b000;
  localparam [RAM_ST_W-1:0] RAM_ST_WRITE      = 3'b001;
  localparam [RAM_ST_W-1:0] RAM_ST_WRITE_WAIT = 3'b010;
  localparam [RAM_ST_W-1:0] RAM_ST_READ       = 3'b011;
  localparam [RAM_ST_W-1:0] RAM_ST_READ_WAIT  = 3'b100;
  localparam [RAM_ST_W-1:0] RAM_ST_DONE       = 3'b101;

  //Wire Declaration
  //----------------
  wire    [ADDR_WIDTH-1:0]                   max_addr_range;
  wire    [3:0]                              bank_cnt_nxt;
  wire                                       bank_cnt_en;

  wire                                       word_cnt_en;
  wire    [7:0]                              word_cnt_nxt;
  wire                                       write_latency_reqd;
  wire                                       read_latency_reqd;
  
  //Reg Declaration
  //---------------
  reg     [2:0]                              next_state;
  reg     [2:0]                              prev_state;
  reg     [2:0]                              state;
  reg     [3:0]                              bank_cnt_end;
  reg     [3:0]                              l2dataram_way_cnt_end;
  reg     [3:0]                              bank_cnt;
  reg     [WORD_WIDTH-1:0]                   wdata_raw;
  reg     [1:0]                              latency_wr_cnt;
  reg     [1:0]                              latency_rd_cnt;
  reg     [1:0]                              latency_rd_clken_cnt;
  reg     [1:0]                              latency_wr_cnt_end;
  reg     [1:0]                              latency_rd_cnt_end;
  reg     [1:0]                              latency_rd_clken_cnt_end;
  reg     [2:0]                              checking_counter;
  reg     [2:0]                              checking_counter_end;
  reg     [2:0]                              init_checking_counter;  
  
  reg     [(NUM_BANKS -1) :0]                l2dataram_en;
  reg     [((WORD_WIDTH* NUM_BANKS) - 1):0]  expected_data_latency1;
  reg     [((WORD_WIDTH* NUM_BANKS) - 1):0]  expected_data_latency2;
  reg     [((WORD_WIDTH* NUM_BANKS) - 1):0]  expected_data_latency3;
  reg     [((WORD_WIDTH* NUM_BANKS) - 1):0]  expected_data_latency4;
  reg     [2:0]                              state_latency1;
  reg     [2:0]                              state_latency2;
  reg     [2:0]                              state_latency3;
  reg     [2:0]                              state_latency4;
  reg     [ADDR_WIDTH-1:0]                   addr_latency1;
  reg     [ADDR_WIDTH-1:0]                   addr_latency2;
  reg     [ADDR_WIDTH-1:0]                   addr_latency3;
  reg     [ADDR_WIDTH-1:0]                   addr_latency4;
  reg     [3:0]                              bank_cnt_latency1;
  reg     [3:0]                              bank_cnt_latency2;
  reg     [3:0]                              bank_cnt_latency3;
  reg     [3:0]                              bank_cnt_latency4;
  reg     [((WORD_WIDTH* NUM_BANKS) - 1):0]  selected_data;
  reg     [2:0]                              selected_state;
  reg     [ADDR_WIDTH-1:0]                   selected_addr;
  reg     [3:0]                              selected_bank_cnt;
  reg     [15 * 8 : 1]                       check_string;
  reg                                        debug;
  reg                                        seen_final_write;
  reg                                        seen_final_read;
  reg     [7:0]                              word_cnt;
  reg                                        failed_seen;
  reg                                        started_checking;
  reg                                        wr_en;
  reg     [WORD_WIDTH -1:0]                  rdata_i_chunk;
  reg     [WORD_WIDTH -1:0]                  selected_data_chunk;
    
  //Integer Declaration
  //-------------------
  integer                                   word_error;

 //Event
 //-----
 event checking;

 always @ (checking) begin

 end

  // Selection and Controlling of Bank Size
  //---------------------------------------
  //For Local Debug
  initial
    begin
      debug = 0;
    end

  always @(negedge reset_n)
    if (!reset_n)
      case(NUM_BANKS)
          1   : bank_cnt_end = 4'b0000;
          2   : bank_cnt_end = 4'b0001;
          3   : bank_cnt_end = 4'b0010;
          4   : bank_cnt_end = 4'b0011;
          5   : bank_cnt_end = 4'b0100;
          6   : bank_cnt_end = 4'b0101;
          7   : bank_cnt_end = 4'b0110;
          8   : bank_cnt_end = 4'b0111;
          9   : bank_cnt_end = 4'b1000;
          10  : bank_cnt_end = 4'b1001;
          11  : bank_cnt_end = 4'b1010;
          12  : bank_cnt_end = 4'b1011;
          13  : bank_cnt_end = 4'b1100;
          14  : bank_cnt_end = 4'b1101;
          15  : bank_cnt_end = 4'b1110;
        default : $display("!!! TESTBENCH FAILURE : Number of Banks outside Range |!!!");
      endcase

  always @(negedge reset_n)
    if (!reset_n)
      case(L2_DATARAM_WAYS)
          1   : l2dataram_way_cnt_end = 4'b0000;
          2   : l2dataram_way_cnt_end = 4'b0001;
          3   : l2dataram_way_cnt_end = 4'b0010;
          4   : l2dataram_way_cnt_end = 4'b0011;
          5   : l2dataram_way_cnt_end = 4'b0100;
          6   : l2dataram_way_cnt_end = 4'b0101;
          7   : l2dataram_way_cnt_end = 4'b0110;
          8   : l2dataram_way_cnt_end = 4'b0111;
          9   : l2dataram_way_cnt_end = 4'b1000;
          10  : l2dataram_way_cnt_end = 4'b1001;
          11  : l2dataram_way_cnt_end = 4'b1010;
          12  : l2dataram_way_cnt_end = 4'b1011;
          13  : l2dataram_way_cnt_end = 4'b1100;
          14  : l2dataram_way_cnt_end = 4'b1101;
          15  : l2dataram_way_cnt_end = 4'b1110;
        default : $display("!!! TESTBENCH FAILURE : Number of Banks outside Range |!!!");
      endcase

   // select test type
  always @(negedge reset_n)
    if (!reset_n)
      case(RAM_ID)
        4'b0000: check_string = "D-Cache Data   ";
        4'b0001: check_string = "D-Cache Tag    ";
        4'b0010: check_string = "D-Cache Dirty  ";
        4'b0011: check_string = "I-Cache Data   ";
        4'b0100: check_string = "I-Cache Tag    ";
        4'b0101: check_string = "TLBRam         ";
        4'b0110: check_string = "L1D TagRam     ";
        4'b0111: check_string = "L2  TagRam     ";
        4'b1000: check_string = "L2  DataRam    ";
        default : $display("!!! TESTBENCH FAILURE : RAM-ID outside Range|!!!");
      endcase

 always@(*)
   begin
     case(bank_cnt)
       4'b0000 : l2dataram_en = 8'b00000001;
       4'b0001 : l2dataram_en = 8'b00000010;
       4'b0010 : l2dataram_en = 8'b00000100;
       4'b0011 : l2dataram_en = 8'b00001000;
       4'b0100 : l2dataram_en = 8'b00010000;
       4'b0101 : l2dataram_en = 8'b00100000;
       4'b0110 : l2dataram_en = 8'b01000000;
       4'b0111 : l2dataram_en = 8'b10000000;
       default : l2dataram_en = {8{1'bx}};
     endcase
   end

   // Write Latency options are
   // 0: When 0, no latency is required and there is a signal to indicate this
   // 1: Requires two clock cycles but since there is a write and wait stage
   //    so the latency_wr_cnt_end is 00.
  always@(*)
   begin
     case(l2_wr_latency_i)
        0 : latency_wr_cnt_end = 2'b00;
        1 : latency_wr_cnt_end = 2'b00;
     endcase
   end

   // Read Latency options. This is used for data transaction
   // 00 : Requires two clock cycles but since there is a read and wait stage
   //      so the latency_rd_cnt_end is 00
   // 01 : As above and latency_rd_cnt_end should be 01 to wait for extra cycle.
   // 10 : It is 2'b00 cause read and read wait account for two cycles
   // 11 : It is 2'b00 as the enable in read state takes two cycle and then read 
   //      wait accounts for third.  
  always@(*)
   begin
     case({l2_wr_latency_i,l2_rd_latency_i})
        2'b00 : latency_rd_cnt_end = 2'b00;
        2'b01 : latency_rd_cnt_end = 2'b01;
	2'b10 : latency_rd_cnt_end = 2'b00;
        2'b11 : latency_rd_cnt_end = 2'b00;
     endcase
   end

  // This counter is there to add the number of cycles for input latency
  // while in the read stage, and the maximum is two cycles but dont have
  // the wait stage so needs two cycle.
  always@(*)
   begin
     case({l2_wr_latency_i,l2_rd_latency_i})
        2'b00 : latency_rd_clken_cnt_end = 2'b00;
 	2'b01 : latency_rd_clken_cnt_end = 2'b00;
        2'b10 : latency_rd_clken_cnt_end = 2'b00;
	2'b11 : latency_rd_clken_cnt_end = 2'b01;
     endcase
   end
  
  // This counter is added to check the data at the correct time, and need
  // initialization value as it depends on which cycle the clken comes   
  always@(*)
   begin
     case({l2_wr_latency_i,l2_rd_latency_i})
        2'b00 : begin checking_counter_end = 3'b100; init_checking_counter = 3'b001; end
 	2'b01 : begin checking_counter_end = 3'b101; init_checking_counter = 3'b001; end
        2'b10 : begin checking_counter_end = 3'b101; init_checking_counter = 3'b010; end
	2'b11 : begin checking_counter_end = 3'b110; init_checking_counter = 3'b010; end
     endcase
   end   

  //When l2_wr_latency_i is zero then no write latency required
  assign write_latency_reqd = ~(l2_wr_latency_i == 1'b0);
  assign read_latency_reqd  = ~(l2_rd_latency_i == 1'b0);
  
  //In Progress signal
  assign in_progress_o = state != RAM_ST_IDLE;

  // Bank Count
  //-----------
  assign bank_cnt_en  = ((state == RAM_ST_READ_WAIT) & (word_cnt == WORD_WIDTH) & (latency_rd_cnt == latency_rd_cnt_end)) | (state == RAM_ST_IDLE & addr_o == {ADDR_WIDTH{1'b0}});

  assign bank_cnt_nxt = ((state == RAM_ST_READ_WAIT) & (bank_cnt < bank_cnt_end)) ? bank_cnt + 4'h1 : 4'h0;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      bank_cnt <= 4'h0;
    else if (bank_cnt_en)
      bank_cnt <= bank_cnt_nxt;

  assign bank_cnt_o = bank_cnt;

  // Word Count
  //-----------
  assign word_cnt_en  = state == RAM_ST_READ_WAIT & (latency_rd_cnt == latency_rd_cnt_end);

  assign word_cnt_nxt = ((state == RAM_ST_READ_WAIT) & (word_cnt < WORD_WIDTH)) ? (latency_rd_cnt == latency_rd_cnt_end ? word_cnt + 8'h1 : word_cnt) : 8'h0;

   always @(posedge clk or negedge reset_n)
    if (~reset_n)
      word_cnt <= 8'h0;
    else if (word_cnt_en)
      word_cnt <= word_cnt_nxt;

  //Data Word Reset as all the RAM's are first written with zero when
  //this signal is high otherwise it is written with all 1's to catch
  //any misconnection
  assign reset_data_word_o = (|word_cnt == 1'b0);

  // Control for Word enable state machine
  //--------------------------------------

  always @*
    case (state)
      RAM_ST_IDLE       : next_state = start_i ? RAM_ST_WRITE : RAM_ST_IDLE;
      RAM_ST_WRITE      : next_state =  RAM_ST_WRITE_WAIT;
      RAM_ST_WRITE_WAIT : next_state = (latency_wr_cnt == latency_wr_cnt_end) ? RAM_ST_READ : RAM_ST_WRITE_WAIT;
      RAM_ST_READ       : next_state = (latency_rd_clken_cnt == latency_rd_clken_cnt_end) ? RAM_ST_READ_WAIT : RAM_ST_READ;
      RAM_ST_READ_WAIT  : next_state = (latency_rd_cnt == latency_rd_cnt_end) ? ( (bank_cnt == bank_cnt_end ) & (word_cnt == WORD_WIDTH) ? RAM_ST_DONE  : RAM_ST_WRITE ) : RAM_ST_READ_WAIT;
      RAM_ST_DONE       : next_state = RAM_ST_IDLE;
      default           : next_state = RAM_ST_IDLE;
    endcase


  //Registering the next stage
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      state      <= RAM_ST_IDLE;
      prev_state <= RAM_ST_IDLE;
    end else begin
      state      <= next_state;
      prev_state <= state;
    end

 //Selecting address bits
  assign max_addr_range = max_range_i;

 // Set the ADDR and WORD for each stage
  always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      addr_o               <= {ADDR_WIDTH{1'b0}};
      wdata_raw            <= {WORD_WIDTH{1'b0}};
      l2dataram_way_o      <= {4{1'b0}};
      latency_wr_cnt       <= {2{1'b0}};
      latency_rd_cnt       <= {2{1'b0}};
      latency_rd_clken_cnt <= {2{1'b0}};
      checking_counter     <= {3{1'b0}};
    end else if (state == RAM_ST_WRITE) begin
      addr_o               <= {ADDR_WIDTH{1'b0}};
      l2dataram_way_o      <= {4{1'b0}};
      wdata_raw            <= wdata_raw;
      checking_counter     <= (checking_counter == checking_counter_end) ? init_checking_counter : (checking_counter + 1);
    end else if (state == RAM_ST_WRITE_WAIT) begin
      latency_wr_cnt       <= (latency_wr_cnt == latency_wr_cnt_end) ? {2{1'b0}} : (latency_wr_cnt + 1);
      wdata_raw            <= wdata_raw;
      checking_counter     <= (checking_counter == checking_counter_end) ? init_checking_counter : (checking_counter + 1);
    end else if (state == RAM_ST_READ) begin
      addr_o               <= {ADDR_WIDTH{1'b0}};
      l2dataram_way_o      <= {4{1'b0}};
      wdata_raw            <= wdata_raw;
      latency_rd_clken_cnt <= (latency_rd_clken_cnt == latency_rd_clken_cnt_end) ? {2{1'b0}} : (latency_rd_clken_cnt + 1);
      checking_counter     <= (checking_counter == checking_counter_end) ? init_checking_counter : (checking_counter + 1);
    end else if (state == RAM_ST_READ_WAIT) begin
      latency_rd_cnt       <= (latency_rd_cnt == latency_rd_cnt_end) ? {2{1'b0}} : (latency_rd_cnt + 1);
      wdata_raw            <= (latency_rd_cnt == latency_rd_cnt_end) ? { {(WORD_WIDTH-1){1'b0}},1'b1 } << word_cnt : wdata_raw;
      checking_counter     <= (checking_counter == checking_counter_end) ? init_checking_counter : (checking_counter + 1);
    end  else if (state == RAM_ST_DONE) begin
      addr_o               <= {ADDR_WIDTH{1'b0}};
      wdata_raw            <= {WORD_WIDTH{1'b0}};
      l2dataram_way_o      <= {4{1'b0}};
      latency_wr_cnt       <= {2{1'b0}};
      latency_rd_cnt       <= {2{1'b0}};
      latency_rd_clken_cnt <= {2{1'b0}};
      checking_counter     <= {3{1'b0}};
    end
 end


// Set the Enable signals for each stage
  always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      wr_en       <= 1'b0;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end else if (next_state == RAM_ST_READ & (state == RAM_ST_WRITE) & !write_latency_reqd) begin
      wr_en       <= 1'b0;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end else if (next_state == RAM_ST_WRITE & (state == RAM_ST_IDLE | state == RAM_ST_READ_WAIT)) begin
      wr_en       <= 1'b1;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end else if (next_state == RAM_ST_WRITE_WAIT & (state == RAM_ST_WRITE | state == RAM_ST_WRITE_WAIT)) begin
      wr_en       <= 1'b1;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end else if (next_state ==  RAM_ST_READ & state == RAM_ST_WRITE_WAIT) begin
      wr_en       <= 1'b0;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end else if (next_state ==  RAM_ST_READ_WAIT & (state == RAM_ST_READ | state == RAM_ST_READ_WAIT)) begin
      wr_en       <= 1'b0;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end  else if (next_state ==  RAM_ST_DONE & state == RAM_ST_READ_WAIT) begin
      wr_en       <= 1'b0;
      wrbyte_en_o <= {NUM_STRBS{1'b0}};
    end
 end

 assign clk_en_o       = ( (state == RAM_ST_WRITE & !write_latency_reqd  & !reset_data_word_o) | (state == RAM_ST_WRITE_WAIT & latency_wr_cnt == latency_wr_cnt_end & !reset_data_word_o & write_latency_reqd) ) ? l2dataram_en :
                         ( (state == RAM_ST_WRITE & !write_latency_reqd  &  reset_data_word_o) | (state == RAM_ST_WRITE_WAIT & latency_wr_cnt == latency_wr_cnt_end &  reset_data_word_o & write_latency_reqd) |
                           (state == RAM_ST_READ  & !write_latency_reqd) | (state == RAM_ST_READ & latency_rd_clken_cnt == latency_rd_clken_cnt_end & write_latency_reqd & read_latency_reqd) 
			                                                 | (state == RAM_ST_READ_WAIT & latency_rd_clken_cnt == latency_rd_clken_cnt_end & write_latency_reqd & !read_latency_reqd) ) ? {NUM_BANKS{1'b1}} : {NUM_BANKS{1'b0}};

 assign enable_o       = ( ((state == RAM_ST_WRITE_WAIT & write_latency_reqd) | state == RAM_ST_WRITE) & !reset_data_word_o) ? l2dataram_en :
                         ( (state == RAM_ST_WRITE | state == RAM_ST_WRITE_WAIT) & reset_data_word_o) | ((state == RAM_ST_READ_WAIT & write_latency_reqd) | state == RAM_ST_READ) ? {NUM_BANKS{1'b1}} : {NUM_BANKS{1'b0}};
 
 
 assign wdata_o        = ( (state == RAM_ST_WRITE_WAIT & write_latency_reqd) | state == RAM_ST_WRITE) ? wdata_raw : {WORD_WIDTH{1'b0}};
 assign wdata_check_o  = (state == RAM_ST_READ  | state == RAM_ST_READ_WAIT)  ? wdata_raw : {WORD_WIDTH{1'b0}};
 assign wr_en_o        = ( (state == RAM_ST_WRITE_WAIT | state == RAM_ST_READ_WAIT ) & !write_latency_reqd) ? 1'b0 : wr_en;
 assign done_o         = (state == RAM_ST_DONE);

 //For Latency and Checking the Data coming back in after read
 always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      expected_data_latency1 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency2 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency3 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency4 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};

      addr_latency1          <= {ADDR_WIDTH{1'b0}};
      addr_latency2          <= {ADDR_WIDTH{1'b0}};
      addr_latency3          <= {ADDR_WIDTH{1'b0}};
      addr_latency4          <= {ADDR_WIDTH{1'b0}};

      bank_cnt_latency1      <= {4{1'b0}};
      bank_cnt_latency2      <= {4{1'b0}};
      bank_cnt_latency3      <= {4{1'b0}};
      bank_cnt_latency4      <= {4{1'b0}};

    end else
      expected_data_latency1 <= expected_data;
      expected_data_latency2 <= expected_data_latency1;
      expected_data_latency3 <= expected_data_latency2;
      expected_data_latency4 <= expected_data_latency3;

      addr_latency1          <= addr_o;
      addr_latency2          <= addr_latency1;
      addr_latency3          <= addr_latency2;
      addr_latency4          <= addr_latency3;

      bank_cnt_latency1      <= bank_cnt_o;
      bank_cnt_latency2      <= bank_cnt_latency1;
      bank_cnt_latency3      <= bank_cnt_latency2;
      bank_cnt_latency4      <= bank_cnt_latency3;
    end

 //Checking Data
 always @*
  case (l2_wr_latency_i + 2'b01)
        1    : begin
                selected_data     = expected_data_latency1;
                selected_addr     = addr_latency1;
                selected_bank_cnt = bank_cnt_latency1;
               end

        2    : begin
                selected_data     = expected_data_latency2;
                selected_addr     = addr_latency2;
                selected_bank_cnt = bank_cnt_latency2;
               end

        3    : begin
                selected_data     = expected_data_latency3;
                selected_addr     = addr_latency3;
                selected_bank_cnt = bank_cnt_latency3;
               end

        4    : begin
                selected_data     = expected_data_latency4;
                selected_addr     = addr_latency4;
                selected_bank_cnt = bank_cnt_latency4;
               end

    default  : begin
                $display("!!! TESTBENCH FAILURE : Checking Latency outside Range |!!!");
              end
  endcase

 //Passing decision on Test
 assign  passed_o = started_checking ? (failed_seen ? 1'b0 : 1'b1) : 1'b0;

 always @(negedge clk or negedge reset_n) begin
    if (!reset_n) begin
      word_error       = 0;
      failed_seen      = 1'b0;
      started_checking = 1'b0;
    end else if (word_error < 10  & checking_counter == checking_counter_end) begin
      started_checking = 1'b1;
      if ((rdata_i !=  selected_data) || (rdata_i !== selected_data)) begin
          word_error  = word_error + 1;
          failed_seen = 1'b1;
          $display ("%9dns Checking %0s [Addr0x%X] Word Error (Walking ones in wdata).", $time, check_string, 
                          {addr_o,l2dataram_way_o[2:0]});
			  
	  begin : CHUNK_SELECTION_GENERATE
	      integer count;
	      for (count = 1; count<= NUM_BANKS; count = count + 1) begin
	        selected_data_chunk = selected_data[(WORD_WIDTH * (count -1))  +: WORD_WIDTH];
	        rdata_i_chunk       = rdata_i[(WORD_WIDTH * (count - 1)) +: WORD_WIDTH];
	        if (selected_data_chunk !== rdata_i_chunk)
	          $display ("Mis-Matched Data on Bank %2d. Expected = 0x%X, Actual = 0x%X", (count - 1), selected_data_chunk, rdata_i_chunk);
	      end	
	    end
	    		  
      end else if (debug) begin
          $display ("%9dns Checking %0s  Bank %1d [Addr0x%X] Word Matched (Walking ones in wdata).\n Expected = 0x%X, \n Actual   = 0x%X", $time, check_string, selected_bank_cnt,
                          {addr_o,l2dataram_way_o[2:0]}, selected_data, rdata_i);
      end
      ->checking;
    end
 end

endmodule

