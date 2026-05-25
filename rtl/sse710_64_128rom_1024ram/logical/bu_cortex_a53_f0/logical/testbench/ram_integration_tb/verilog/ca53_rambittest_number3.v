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

module ca53_rambittest_number3     #(parameter RAM_ID      = 4'b0000,  // Unique ID
                                     parameter ADDR_WIDTH  = 11,       // Addr bits
                                     parameter RAM_TYPE    = 2'b00,   // RAM type
                                     parameter NUM_BANKS   = 8,       // Number of Banks
                                     parameter BYTE_WIDTH  = 8,       // Byte or bit granularity
                                     parameter WORD_WIDTH  = 32,      // width of RAM to test
                                     parameter NUM_STRBS   = 4,      // Number of strbs
                                     parameter CHK_LATENCY = 1)
  (

   input wire                                    clk,
   input wire                                    reset_n,
   input wire                                    start_i,
   input wire [((WORD_WIDTH* NUM_BANKS) - 1):0]  rdata_i,           // Ram read data
   input wire [ADDR_WIDTH-1:0]                   max_range_i,

   output reg  [ADDR_WIDTH-1:0]                  addr_o,            // Ram address
   output wire [WORD_WIDTH -1:0]                 wdata_o,           // Ram write data
   output reg  [NUM_BANKS-1:0]                   enable_o,          // Even enables
   output reg                                    wr_en_o,           // Overall write enable
   output wire [NUM_STRBS-1:0]                   wrbyte_en_o,       // Byte write enable.
   output wire [3:0]                             bank_cnt_o,
   output wire                                   passed_o,
   output wire                                   done_o,
   output wire                                   in_progress_o

   );

  // -----------------------------------------------------------------------------
  // Define states for word and walking ones tests
  // -----------------------------------------------------------------------------

  localparam RAM_ST_W = 3;
  localparam [RAM_ST_W-1:0] RAM_ST_IDLE       = 3'b000;
  localparam [RAM_ST_W-1:0] RAM_ST_WRITE      = 3'b001;
  localparam [RAM_ST_W-1:0] RAM_ST_READ       = 3'b010;
  localparam [RAM_ST_W-1:0] RAM_ST_DATA_RESET = 3'b011;
  localparam [RAM_ST_W-1:0] RAM_ST_DONE       = 3'b100;

  //Wire Declaration
  //----------------
  wire    [ADDR_WIDTH-1:0]                   max_addr_range;
  wire    [3:0]                              bank_cnt_nxt;
  wire                                       bank_cnt_en;

  wire                                       word_cnt_en;
  wire    [7:0]                              word_cnt_nxt;

  wire    [4:0]                              strb_cnt_nxt;
  wire                                       strb_cnt_en;
  wire    [((WORD_WIDTH* NUM_BANKS) - 1):0]  wdata_check;
  wire                                       start_word_cnt_en;
  wire                                       start_strb_cnt_en;

  //Reg Declaration
  //---------------
  reg     [2:0]                              next_state;
  reg     [2:0]                              state;
  reg     [2:0]                              prev_state;
  reg     [3:0]                              bank_cnt_end;
  reg     [3:0]                              bank_cnt;
  reg     [WORD_WIDTH-1:0]                   wdata_raw;
  reg     [4:0]                              strb_cnt;

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

  reg     [13 * 8 : 1]                       check_string;
  reg     [4  * 8 : 1]                       bank_string;
  reg                                        debug;
  reg     [7:0]                              word_cnt;
  reg                                        start_word_cnt;
  reg                                        start_strb_cnt;
  reg                                        failed_seen;
  reg                                        started_checking;
  reg     [WORD_WIDTH -1:0]                  rdata_i_chunk;
  reg     [WORD_WIDTH -1:0]                  selected_data_chunk;
  
  //Integer Declaration
  //-------------------
  integer                        word_error;

 //Event
 //-----

 event checking;

 always @ (checking) begin

 end

   //Checker for Bit-writable RAM
  function [31:0] wdata_bit;
    input [4:0] strb;
    begin
      case (strb)
           5'b00000 : wdata_bit = {{31{1'b0}} , 1'b1};
           5'b00001 : wdata_bit = {{30{1'b0}} , 1'b1, {1{1'b0}}};
           5'b00010 : wdata_bit = {{29{1'b0}} , 1'b1, {2{1'b0}}};
           5'b00011 : wdata_bit = {{28{1'b0}} , 1'b1, {3{1'b0}}};
           5'b00100 : wdata_bit = {{27{1'b0}} , 1'b1, {4{1'b0}}};
           5'b00101 : wdata_bit = {{26{1'b0}} , 1'b1, {5{1'b0}}};
           5'b00110 : wdata_bit = {{25{1'b0}} , 1'b1, {6{1'b0}}};
           5'b00111 : wdata_bit = {{24{1'b0}} , 1'b1, {7{1'b0}}};
           5'b01000 : wdata_bit = {{23{1'b0}} , 1'b1, {8{1'b0}}};
           5'b01001 : wdata_bit = {{22{1'b0}} , 1'b1, {9{1'b0}}};
           5'b01010 : wdata_bit = {{21{1'b0}} , 1'b1, {10{1'b0}}};
           5'b01011 : wdata_bit = {{20{1'b0}} , 1'b1, {11{1'b0}}};
           5'b01100 : wdata_bit = {{19{1'b0}} , 1'b1, {12{1'b0}}};
           5'b01101 : wdata_bit = {{18{1'b0}} , 1'b1, {13{1'b0}}};
           5'b01110 : wdata_bit = {{17{1'b0}} , 1'b1, {14{1'b0}}};
           5'b01111 : wdata_bit = {{16{1'b0}} , 1'b1, {15{1'b0}}};
           5'b10000 : wdata_bit = {{15{1'b0}} , 1'b1, {16{1'b0}}};
           5'b10001 : wdata_bit = {{14{1'b0}} , 1'b1, {17{1'b0}}};
           5'b10010 : wdata_bit = {{13{1'b0}} , 1'b1, {18{1'b0}}};
           5'b10011 : wdata_bit = {{12{1'b0}} , 1'b1, {19{1'b0}}};

           5'b10100 : wdata_bit = {{11{1'b0}} , 1'b1, {20{1'b0}}};
           5'b10101 : wdata_bit = {{10{1'b0}} , 1'b1, {21{1'b0}}};
           5'b10110 : wdata_bit = {{9{1'b0}}  , 1'b1, {22{1'b0}}};
           5'b10111 : wdata_bit = {{8{1'b0}}  , 1'b1, {23{1'b0}}};
           5'b11000 : wdata_bit = {{7{1'b0}}  , 1'b1, {24{1'b0}}};
           5'b11001 : wdata_bit = {{6{1'b0}}  , 1'b1, {25{1'b0}}};
           5'b11010 : wdata_bit = {{5{1'b0}}  , 1'b1, {26{1'b0}}};

           5'b11011 : wdata_bit = {{4{1'b0}}  , 1'b1, {27{1'b0}}};
           5'b11100 : wdata_bit = {{3{1'b0}}  , 1'b1, {28{1'b0}}};
           5'b11101 : wdata_bit = {{2{1'b0}}  , 1'b1, {29{1'b0}}};
           5'b11110 : wdata_bit = {{1{1'b0}}  , 1'b1, {30{1'b0}}};
           5'b11111 : wdata_bit = {{ {1'b0}}  , 1'b1, {31{1'b0}}};



           default :  wdata_bit = {32{1'bx}};
         endcase
    end
  endfunction


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

   // select test type
  always @(negedge reset_n)
    if (!reset_n)
      case(RAM_ID)
        4'b0000: begin check_string = "D-Cache Data "; bank_string = "Bank"; end
        4'b0001: begin check_string = "D-Cache Tag  "; bank_string = "Way "; end
        4'b0010: begin check_string = "D-Cache Dirty"; bank_string = "Bank"; end
        4'b0011: begin check_string = "I-Cache Data "; bank_string = "Bank"; end
        4'b0100: begin check_string = "I-Cache Tag  "; bank_string = "Way "; end
        4'b0101: begin check_string = "TLBRam	    "; bank_string = "Bank"; end
        4'b0110: begin check_string = "L1D TagRam   "; bank_string = "Way "; end
        4'b0111: begin check_string = "L2  TagRam   "; bank_string = "Way "; end
        4'b1000: begin check_string = "L2  DataRam  "; bank_string = "Bank"; end
        4'b1001: begin check_string = "BTAC STG0 Ram"; bank_string = "Bank"; end
        4'b1010: begin check_string = "BTAC STG1 Ram"; bank_string = "Bank"; end
        4'b1011: begin check_string = "L2 VictimRam "; bank_string = "Bank"; end
        default : $display("!!! TESTBENCH FAILURE : RAM-ID outside Range|!!!");
      endcase

  //In Progress signal
  assign in_progress_o = state != RAM_ST_IDLE;

  // Bank Count
  //-----------
  assign bank_cnt_en  = ((state == RAM_ST_READ) & (strb_cnt == NUM_STRBS - 1) & word_cnt == BYTE_WIDTH - 1) | (state == RAM_ST_IDLE & strb_cnt == {NUM_STRBS{1'b0}});

  assign bank_cnt_nxt = ((state == RAM_ST_READ) & (bank_cnt < bank_cnt_end)) ? bank_cnt + 4'h1 : 4'h0;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      bank_cnt <= 4'h0;
    else if (bank_cnt_en)
      bank_cnt <= bank_cnt_nxt;

  assign bank_cnt_o = bank_cnt;

  // Strb Count
  //-----------
  assign strb_cnt_en  = ((state == RAM_ST_READ)  & word_cnt == (BYTE_WIDTH - 1));

  assign strb_cnt_nxt = ((state == RAM_ST_READ) & (strb_cnt < (NUM_STRBS - 1)) & start_strb_cnt) ? strb_cnt + 5'h1 : 5'h0;

   always @(posedge clk or negedge reset_n)
    if (~reset_n) begin
      strb_cnt      <= 5'h0;
    end else if (strb_cnt_en) begin
      strb_cnt      <= strb_cnt_nxt;
    end

   //start_strb_cnt signal starts the word_cnt and is used when the state goes in Data reset and it resets the word_cnt to zero
  assign start_strb_cnt_en  = state == RAM_ST_DONE | state == RAM_ST_DATA_RESET;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      start_strb_cnt <= 1'b0;
    else if (start_strb_cnt_en)
      start_strb_cnt <= state == RAM_ST_DATA_RESET;

  // Word Count
  //-----------
  assign word_cnt_en  = state == RAM_ST_READ;

  assign word_cnt_nxt = (state == RAM_ST_READ & next_state == RAM_ST_WRITE) & (word_cnt < (BYTE_WIDTH - 1)) & start_word_cnt ? word_cnt + 8'h1 : 8'h0;

   always @(posedge clk or negedge reset_n)
    if (~reset_n)
      word_cnt <= 8'h0;
    else if (word_cnt_en)
      word_cnt <= word_cnt_nxt;

  //start_word_cnt signal starts the word_cnt and is used when the state goes in Data reset and it resets the word_cnt to zero
  assign start_word_cnt_en  = state == RAM_ST_READ | state == RAM_ST_DATA_RESET;

  always @(posedge clk or negedge reset_n)
    if (~reset_n)
      start_word_cnt <= 1'b0;
    else if (start_word_cnt_en)
      start_word_cnt <= state == RAM_ST_READ;


  // Control for Word enable state machine
  //--------------------------------------
  always @*
    case (state)
      RAM_ST_IDLE       : next_state = start_i ? RAM_ST_WRITE : RAM_ST_IDLE;
      RAM_ST_WRITE      : next_state = RAM_ST_READ;
      RAM_ST_READ       : next_state = (word_cnt == BYTE_WIDTH - 1) ? ((bank_cnt == bank_cnt_end)  &  (strb_cnt == NUM_STRBS - 1) ? RAM_ST_DONE : RAM_ST_DATA_RESET) : RAM_ST_WRITE;
      RAM_ST_DATA_RESET : next_state = RAM_ST_WRITE;
      RAM_ST_DONE       : next_state = RAM_ST_IDLE;
      default           : next_state = RAM_ST_IDLE;
    endcase

  //Registering the next stage
  always @(posedge clk or negedge reset_n)
    if (!reset_n) begin
      state      <= RAM_ST_IDLE;
      prev_state <= RAM_ST_IDLE;
    end else begin
      prev_state <= state;
      state      <= next_state;
    end

 //Selecting address bits
  assign max_addr_range = max_range_i;

 // Set the ADDR and WORD for each stage
  always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      addr_o      <= {ADDR_WIDTH{1'b0}};
      wdata_raw   <= {WORD_WIDTH{1'b0}};
    end else if (state == RAM_ST_DATA_RESET) begin
      addr_o      <= {ADDR_WIDTH{1'b0}};
      wdata_raw   <= {WORD_WIDTH{1'b1}};
    end else if (state == RAM_ST_WRITE) begin
      addr_o      <= {ADDR_WIDTH{1'b0}};
      wdata_raw   <= start_strb_cnt ? wdata_bit(strb_cnt) : {WORD_WIDTH{1'b0}};
    end else if (state == RAM_ST_READ) begin
      addr_o      <= {ADDR_WIDTH{1'b0}};
      wdata_raw   <= {WORD_WIDTH{1'b0}};
    end  else if (state == RAM_ST_DONE) begin
      addr_o      <= {ADDR_WIDTH{1'b0}};
      wdata_raw   <= {WORD_WIDTH{1'b0}};
    end
 end


// Set the Enable signals for each stage
  always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      enable_o    <= {NUM_BANKS{1'b0}};
      wr_en_o     <= 1'b0;
    end else if (next_state == RAM_ST_WRITE & state == RAM_ST_IDLE) begin
      enable_o    <= {NUM_BANKS{1'b1}};
      wr_en_o     <= 1'b1;
    end else if (next_state == RAM_ST_WRITE & state == RAM_ST_DATA_RESET) begin
      enable_o    <= {NUM_BANKS{1'b1}};
      wr_en_o     <= 1'b1;
    end else if (next_state ==  RAM_ST_READ & state == RAM_ST_WRITE) begin
      enable_o    <= {NUM_BANKS{1'b1}};
      wr_en_o     <= 1'b0;
    end else if (next_state ==  RAM_ST_WRITE & state == RAM_ST_READ) begin
      enable_o    <= {NUM_BANKS{1'b1}};
      wr_en_o     <= 1'b1;
    end else if (next_state ==  RAM_ST_DATA_RESET & state == RAM_ST_READ) begin
      enable_o    <= {NUM_BANKS{1'b1}};
      wr_en_o     <= 1'b1;
    end  else if (next_state ==  RAM_ST_DONE & state == RAM_ST_READ) begin
      enable_o    <= {NUM_BANKS{1'b0}};
      wr_en_o     <= 1'b0;
    end
 end

 assign wrbyte_en_o    = ( (state ==  RAM_ST_WRITE  & prev_state == RAM_ST_IDLE) | state ==  RAM_ST_DATA_RESET) ? {NUM_STRBS{1'b1}} : state ==  RAM_ST_WRITE ? { {(NUM_STRBS-1){1'b0}},1'b1 } << strb_cnt : {NUM_STRBS{1'b0}};
 assign wdata_o        = (state == RAM_ST_WRITE | state ==  RAM_ST_DATA_RESET) ? wdata_raw : {WORD_WIDTH{1'b0}};
 assign wdata_check    = (state == RAM_ST_READ)  ? wdata_raw : {WORD_WIDTH{1'b0}};
 assign done_o         = (state == RAM_ST_DONE);


 //For Latency and Checking the Data coming back in after read
 always @(posedge clk or negedge reset_n) begin
    if(~reset_n) begin
      expected_data_latency1 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency2 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency3 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};
      expected_data_latency4 <= {(WORD_WIDTH* NUM_BANKS){1'b0}};

      state_latency1         <= {RAM_ST_W{1'b0}};
      state_latency2         <= {RAM_ST_W{1'b0}};
      state_latency3         <= {RAM_ST_W{1'b0}};
      state_latency4         <= {RAM_ST_W{1'b0}};

      addr_latency1          <= {ADDR_WIDTH{1'b0}};
      addr_latency2          <= {ADDR_WIDTH{1'b0}};
      addr_latency3          <= {ADDR_WIDTH{1'b0}};
      addr_latency4          <= {ADDR_WIDTH{1'b0}};

      bank_cnt_latency1      <= {4{1'b0}};
      bank_cnt_latency2      <= {4{1'b0}};
      bank_cnt_latency3      <= {4{1'b0}};
      bank_cnt_latency4      <= {4{1'b0}};

    end else
      expected_data_latency1 <= wdata_check;
      expected_data_latency2 <= expected_data_latency1;
      expected_data_latency3 <= expected_data_latency2;
      expected_data_latency4 <= expected_data_latency3;

      state_latency1         <= state;
      state_latency2         <= state_latency1;
      state_latency3         <= state_latency2;
      state_latency4         <= state_latency3;

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
  case (CHK_LATENCY)
        1    : begin
                selected_data     = expected_data_latency1;
                selected_state    = state_latency1;
                selected_addr     = addr_latency1;
                selected_bank_cnt = bank_cnt_latency1;
               end

        2    : begin
                selected_data     = expected_data_latency2;
                selected_state    = state_latency2;
                selected_addr     = addr_latency2;
                selected_bank_cnt = bank_cnt_latency2;
               end

        3    : begin
                selected_data     = expected_data_latency3;
                selected_state    = state_latency3;
                selected_addr     = addr_latency3;
                selected_bank_cnt = bank_cnt_latency3;
               end

        4    : begin
                selected_data     = expected_data_latency4;
                selected_state    = state_latency4;
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
    end else if (word_error < 10 & selected_state == RAM_ST_READ) begin
      started_checking = 1'b1;
      if ((rdata_i !=  selected_data) || (rdata_i !== selected_data)) begin
          word_error  = word_error + 1;
          failed_seen = 1'b1;
          if(RAM_ID == 4'b0010 || RAM_ID == 4'b1011) begin
	    $display ("%9dns  Checking %0s [Addr0x%X] Bit Error.\n Expected = 0x%X, \n Actual   = 0x%X", $time, check_string, 
                            selected_addr, selected_data, rdata_i);
	  end else begin
	    $display ("%9dns  Checking %0s  %0s %1d [Addr0x%X] Bit Error.", $time, check_string, bank_string, selected_bank_cnt,
                            selected_addr);
			    
	    begin : CHUNK_SELECTION_GENERATE
	      integer count;
	      for (count = 1; count<= NUM_BANKS; count = count + 1) begin
	        selected_data_chunk = selected_data[(WORD_WIDTH * (count -1))  +: WORD_WIDTH];
	        rdata_i_chunk       = rdata_i[(WORD_WIDTH * (count - 1)) +: WORD_WIDTH];
	        if (selected_data_chunk !== rdata_i_chunk)
	          $display ("Mis-Matched Data on %0s %2d. Expected = 0x%X, Actual = 0x%X", bank_string, (count - 1), selected_data_chunk, rdata_i_chunk);
	      end	
	    end
	     		    
	  end		    
      end else if (debug) begin
          $display ("%9dns  Checking %0s  %0s %1d [Addr0x%X] Bit Matched.\n Expected = 0x%X, \n Actual   = 0x%X", $time, check_string, bank_string, selected_bank_cnt,
                          selected_addr, selected_data, rdata_i);
      end
     ->checking;
    end
 end

endmodule

