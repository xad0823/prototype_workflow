// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2011,2015-2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Wed Feb 15 16:55:37 2017 +0000
//
//      Revision            : 18e107a
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_fileread_core #(
  parameter  MASTER_WIDTH        =  4,
  parameter  MASTER_VALUE        =  1,
  parameter  USER_WIDTH          =  1,
  parameter  STIMULUS_FILE_NAME  = "filestim.m3d",
  parameter  MESSAGE_TAG         = "FileReader:",
  parameter  STIMULUS_ARRAY_SIZE = 5000)
 (
  input  wire                    hclk,
  input  wire                    hresetn,

  output wire [1:0]              htrans,
  output wire [2:0]              hburst,
  output wire [6:0]              hprot,
  output wire [2:0]              hsize,
  output wire                    hwrite,
  output wire                    hmastlock,
  output wire [31:0]             haddr,
  output wire [63:0]             hwdata,
  output wire                    hunalign,
  output wire [7:0]              hbstrb,
  output wire                    hnonsec,
  output wire                    hexcl,
  output wire [MASTER_WIDTH-1:0] hmaster,
  output wire [USER_WIDTH-1:0]   hauser,
  output wire [USER_WIDTH-1:0]   hwuser,

  input  wire                    hready,
  input  wire [2:0]              hresp,
  input  wire [63:0]             hrdata,
  input  wire                    hexokay,
  input  wire [USER_WIDTH-1:0]   hruser,

  output wire [31:0]             linenum);


  `define ARM_FRBM_UNDEF4        4'hx
  `define ARM_FRBM_LOW32         {32{1'b0}}

  `define ARM_FRBM_SIGN_ON_MSG1  " ************************************************"
  `define ARM_FRBM_SIGN_ON_MSG2  " **** ARM SIE-200 File Reader Master"
  `define ARM_FRBM_SIGN_ON_MSG3  " **** (C) ARM Limited 2000-2016"
  `define ARM_FRBM_SIGN_ON_MSG4  " ************************************************"

  `define ARM_FRBM_OPENFILE_MSG  "%d %s Reading stimulus file %s"

  `define ARM_FRBM_SLAVE_ERR_MSG1 "%d %s #ERROR# Expected Okay response was not received from Slave."
  `define ARM_FRBM_SLAVE_ERR_MSG2 "%d %s #ERROR# Expected Error response was not received from Slave."
  `define ARM_FRBM_SLAVE_XFAIL_MSG1 "%d %s #ERROR# Slave responded with an unexpected XFAIL."
  `define ARM_FRBM_SLAVE_XFAIL_MSG2 "%d %s #ERROR# Expected XFAIL response was not received from Slave."
  `define ARM_FRBM_DATA_ERR_MSG "%d %s #ERROR# Data received did not match expectation."
  `define ARM_FRBM_POLL_ERR_MSG "%d %s #ERROR# Poll command timed out after %d repeats."
  `define ARM_FRBM_RUSER_ERR_MSG "%d %s #ERROR# Read User Signal received did not match expectation."
  `define ARM_FRBM_EXOKAY_ERR_MSG "%d %s #ERROR# Expected Exclusive Okay response was not received from Slave."
  `define ARM_FRBM_EXFAIL_ERR_MSG "%d %s #ERROR# Expected Exclusive Fail response was not received from Slave."
  `define ARM_FRBM_CMD_MSG "%d %s #ERROR# Unknown command value in file."

  `define ARM_FRBM_ADDRESS_MSG     " Address        = %h"
  `define ARM_FRBM_ACTUAL_DATA     " Actual data    = %h"
  `define ARM_FRBM_ACTUAL_RUSER    " Actual ruser   = %h"
  `define ARM_FRBM_EXPECTED_DATA   " Expected data  = %h"
  `define ARM_FRBM_EXPECTED_RUSER  " Expected ruser = %h"
  `define ARM_FRBM_DATA_MASK       " Mask           = %h"
  `define ARM_FRBM_LINE_NUM        " Stimulus Line: %d"

  `define ARM_FRBM_INDENT          "                     "

  `define ARM_FRBM_QUIT_MSG        "Simulation Quit requested."
  `define ARM_FRBM_END_MSG         "Stimulus completed."

  `define ARM_FRBM_SUMMARY_HEADER  " ******* SIMULATION SUMMARY *******"
  `define ARM_FRBM_SUMMARY_FOOTER  " **********************************"
  `define ARM_FRBM_SUMMARY_DATA    " ** Data Mismatches             :%d"
  `define ARM_FRBM_SUMMARY_POLL    " ** Poll timeouts               :%d"
  `define ARM_FRBM_SUMMARY_SLAVE   " ** Response Mismatches         :%d"
  `define ARM_FRBM_SUMMARY_RUSER   " ** Read User Signal Mismatches :%d"
  `define ARM_FRBM_SUMMARY_EXOKAY  " ** Exclusive Okay Mismatches   :%d"

  `define ARM_FRBM_TRN_IDLE      2'b00
  `define ARM_FRBM_TRN_BUSY      2'b01
  `define ARM_FRBM_TRN_NONSEQ    2'b10
  `define ARM_FRBM_TRN_SEQ       2'b11

  `define ARM_FRBM_SZ_BYTE       3'b000
  `define ARM_FRBM_SZ_HALF       3'b001
  `define ARM_FRBM_SZ_WORD       3'b010
  `define ARM_FRBM_SZ_DWORD      3'b011

  `define ARM_FRBM_BUR_SINGLE    3'b000
  `define ARM_FRBM_BUR_INCR      3'b001
  `define ARM_FRBM_BUR_WRAP4     3'b010
  `define ARM_FRBM_BUR_INCR4     3'b011
  `define ARM_FRBM_BUR_WRAP8     3'b100
  `define ARM_FRBM_BUR_INCR8     3'b101
  `define ARM_FRBM_BUR_WRAP16    3'b110
  `define ARM_FRBM_BUR_INCR16    3'b111

  `define ARM_FRBM_RSP_OKAY      3'b000
  `define ARM_FRBM_RSP_ERROR     3'b001
  `define ARM_FRBM_RSP_RETRY     3'b010
  `define ARM_FRBM_RSP_SPLIT     3'b011
  `define ARM_FRBM_RSP_XFAIL     3'b100

  `define ARM_FRBM_NOBOUND       3'b000
  `define ARM_FRBM_BOUND4        3'b001
  `define ARM_FRBM_BOUND8        3'b010
  `define ARM_FRBM_BOUND16       3'b011
  `define ARM_FRBM_BOUND32       3'b100
  `define ARM_FRBM_BOUND64       3'b101
  `define ARM_FRBM_BOUND128      3'b110

  `define ARM_FRBM_CMD_WRITE     4'b0000
  `define ARM_FRBM_CMD_READ      4'b0001
  `define ARM_FRBM_CMD_SEQ       4'b0010
  `define ARM_FRBM_CMD_BUSY      4'b0011
  `define ARM_FRBM_CMD_IDLE      4'b0100
  `define ARM_FRBM_CMD_POLL      4'b0101
  `define ARM_FRBM_CMD_LOOP      4'b0110
  `define ARM_FRBM_CMD_COMM      4'b0111
  `define ARM_FRBM_CMD_QUIT      4'b1000

  `define ARM_FRBM_ST_NO_POLL    2'b00
  `define ARM_FRBM_ST_POLL_READ  2'b01
  `define ARM_FRBM_ST_POLL_TEST  2'b10

  `define ARM_FRBM_ERR_OKAY      2'b00
  `define ARM_FRBM_ERR_CONT      2'b01
  `define ARM_FRBM_ERR_CANC      2'b10
  `define ARM_FRBM_ERR_XFAIL     2'b11


  wire        rd_next;

  reg  [3:0]  vec_cmd;
  reg  [31:0] vec_addr;
  reg  [63:0] vec_data;
  reg  [63:0] vec_data_mask;
  reg  [2:0]  vec_burst;
  reg  [2:0]  vec_size;
  reg         vec_lock;
  reg  [6:0]  vec_prot;
  reg         vec_dir;
  reg  [1:0]  err_resp;
  reg         wait_rdy;
  reg  [7:0]  vec_bstrb;
  reg         unalign;
  reg         use_bstrb_flag;
  reg         vec_nonsec;
  reg         vec_excl;
  reg         vec_exokay;
  reg  [31:0] vec_auser;
  reg  [31:0] vec_duser;

  reg  [3:0]  cmd_reg;
  reg  [63:0] data_reg;
  reg  [63:0] mask_reg;
  reg  [2:0]  size_reg;
  reg  [1:0]  err_resp_reg;
  reg         excl_reg;
  reg         exokay_reg;
  reg  [31:0] duser_reg;

  wire        non_zero;
  reg  [3:0]  add_value;
  reg  [2:0]  align_mask;
  reg  [2:0]  boundary;
  wire [31:0] incr_addr;
  reg  [31:0] wrapped_addr;
  wire [31:0] aligned_addr;
  wire [2:0]  aligned_addr_l;

  wire        data_err;
  wire        ruser_err;

  wire [31:0] i_haddr;
  wire [63:0] i_hwdata;
  reg  [1:0]  i_htrans;
  wire        i_hwrite;
  reg  [7:0]  i_hbstrb;
  wire [31:0] i_hwuser;

  reg  [31:0] haddr_reg;
  reg  [63:0] hwdata_reg;
  reg  [1:0]  htrans_reg;
  reg         hwrite_reg;
  reg  [31:0] hwuser_reg;
  reg  [31:0] hruser_reg;

  reg  [1:0]  next_poll_state;
  reg  [1:0]  poll_state;

  wire [63:0] mask;
  wire [63:0] bstrb_mask;
  reg  [63:0] data_compare;

  reg  [31:0] user_compare;

  reg  [31:0] timeout;
  reg  [31:0] timeout_reg;
  reg  [31:0] poll_count;
  reg  [31:0] next_poll_count;


  reg  [31:0] file_array [0:STIMULUS_ARRAY_SIZE];
  reg  [31:0] file_array_tmp;
  integer     array_ptr;

  integer     stim_line_num;
  integer     stim_line_reg;

  reg         stim_end;
  reg         stim_end_data;
  reg         stim_end_data_reg;

  reg         skip_seq;

  reg         banner_done;

  integer     data_err_cnt;
  integer     slave_resp_cnt;
  integer     poll_err_cnt;
  integer     ruser_err_cnt;
  integer     exokay_err_cnt;

  reg  [7:0]  comm_words_hex [0:79];
  reg  [4:0]  comm_word_num;



  task tsk_simulation_comment;
     integer c_index;
    begin
     $write   ("%d %s ", $time, MESSAGE_TAG);

      for (c_index = 0; c_index < (comm_word_num*4); c_index = c_index + 1)

        if (comm_words_hex[c_index] !== 8'b00000000)

          $write("%s", comm_words_hex[c_index]);

      $display("");
    end
  endtask


  initial
    begin : p_open_file_bhav

      $display (`ARM_FRBM_OPENFILE_MSG, $time, MESSAGE_TAG, STIMULUS_FILE_NAME);
      $readmemh(STIMULUS_FILE_NAME, file_array);

    end


  always @ (posedge hclk or negedge hresetn)
    begin : p_banner_bhav
      if (hresetn !== 1'b1)
       banner_done <= 1'b0;
      else
        if (banner_done !== 1'b1)
          begin
            banner_done <= 1'b1;
            $display ("%d %s", $time, MESSAGE_TAG);
            $write   (`ARM_FRBM_INDENT);
            $display (`ARM_FRBM_SIGN_ON_MSG1);
            $write   (`ARM_FRBM_INDENT);
            $display (`ARM_FRBM_SIGN_ON_MSG2);
            $write   (`ARM_FRBM_INDENT);
            $display (`ARM_FRBM_SIGN_ON_MSG3);
            $write   (`ARM_FRBM_INDENT);
            $display (`ARM_FRBM_SIGN_ON_MSG4);
          end
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_report_errors_bhav
      if (hresetn !== 1'b1)
        begin
          data_err_cnt   = 0;
          slave_resp_cnt = 0;
          poll_err_cnt   = 0;
          ruser_err_cnt  = 0;
          exokay_err_cnt = 0;
        end
      else
        if ((hready === 1'b1) && (skip_seq !== 1'b1))

          if  ((hresp === `ARM_FRBM_RSP_XFAIL) && (err_resp_reg !== `ARM_FRBM_ERR_XFAIL))
            begin
              $display (`ARM_FRBM_SLAVE_XFAIL_MSG1, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              slave_resp_cnt = slave_resp_cnt + 1;
            end

          else if ((hresp !== `ARM_FRBM_RSP_XFAIL) && (err_resp_reg === `ARM_FRBM_ERR_XFAIL))
            begin
              $display (`ARM_FRBM_SLAVE_XFAIL_MSG2, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              slave_resp_cnt = slave_resp_cnt + 1;
            end

          else if ((hresp !== `ARM_FRBM_RSP_OKAY) && (err_resp_reg === `ARM_FRBM_ERR_OKAY))
            begin
              $display (`ARM_FRBM_SLAVE_ERR_MSG1, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              slave_resp_cnt = slave_resp_cnt + 1;
            end

          else if ((hresp !== `ARM_FRBM_RSP_ERROR) &&
                   ((err_resp_reg === `ARM_FRBM_ERR_CONT) || (err_resp_reg === `ARM_FRBM_ERR_CANC)))
            begin
              $display (`ARM_FRBM_SLAVE_ERR_MSG2, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              slave_resp_cnt = slave_resp_cnt + 1;
            end

          else if ( (data_err === 1'b1) &&  (poll_count === 32'h00000001))
            begin
              $display (`ARM_FRBM_POLL_ERR_MSG, $time, MESSAGE_TAG, timeout_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);


              if (size_reg === `ARM_FRBM_SZ_DWORD)
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[63:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[63:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[63:0]);
                end
              else if (haddr_reg[2] === 1'b1)
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[63:32]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[63:32]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[63:32]);
                end
              else
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[31:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[31:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[31:0]);
                end

              poll_err_cnt = poll_err_cnt + 1;
            end

          else if ((data_err === 1'b1) && (poll_state === `ARM_FRBM_ST_NO_POLL))
            begin
              $display (`ARM_FRBM_DATA_ERR_MSG, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);


              if (size_reg === `ARM_FRBM_SZ_DWORD)
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[63:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[63:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[63:0]);
                end
              else if (haddr_reg[2] === 1'b1)
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[63:32]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[63:32]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[63:32]);
                end
              else
                begin
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_ACTUAL_DATA, hrdata[31:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_EXPECTED_DATA, data_reg[31:0]);
                  $write   (`ARM_FRBM_INDENT);
                  $display (`ARM_FRBM_DATA_MASK, mask_reg[31:0]);
                end

              data_err_cnt = data_err_cnt + 1;
            end

          else if (ruser_err === 1'b1)
            begin
              $display (`ARM_FRBM_RUSER_ERR_MSG, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ACTUAL_RUSER, hruser[USER_WIDTH-1:0]);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_EXPECTED_RUSER, duser_reg[USER_WIDTH-1:0]);

              ruser_err_cnt = ruser_err_cnt + 1;
            end

          else if ((excl_reg == 1'b1) && ((cmd_reg == `ARM_FRBM_CMD_READ) || (cmd_reg == `ARM_FRBM_CMD_WRITE)) && (hexokay === 1'b0) && (exokay_reg === 1'b1))
            begin
              $display (`ARM_FRBM_EXOKAY_ERR_MSG, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              exokay_err_cnt = exokay_err_cnt + 1;
            end

          else if ((excl_reg == 1'b1) && ((cmd_reg == `ARM_FRBM_CMD_READ) || (cmd_reg == `ARM_FRBM_CMD_WRITE)) && (hexokay === 1'b1) && (exokay_reg === 1'b0))
            begin
              $display (`ARM_FRBM_EXFAIL_ERR_MSG, $time, MESSAGE_TAG);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_LINE_NUM, stim_line_reg);
              $write   (`ARM_FRBM_INDENT);
              $display (`ARM_FRBM_ADDRESS_MSG, haddr_reg);
              exokay_err_cnt = exokay_err_cnt + 1;
            end

    end


  always @ (posedge hclk or negedge hresetn)
    begin : p_cmd_read_bhav

    reg         use_bstrb_tmp;
    integer     stim_line_tmp;
    reg [31:0]  loop_number;
    integer     i;

      if (hresetn !== 1'b1)
        begin
          vec_cmd           <= `ARM_FRBM_CMD_IDLE;
          vec_addr          <= {32{1'b0}};
          vec_data          <= {64{1'b0}};
          vec_data_mask     <= {64{1'b1}};
          vec_size          <= `ARM_FRBM_SZ_BYTE;
          vec_burst         <= `ARM_FRBM_BUR_SINGLE;
          vec_prot          <= 7'b0000000;
          vec_dir           <= 1'b0;
          vec_lock          <= 1'b0;
          wait_rdy          <= 1'b0;
          vec_bstrb         <= 8'b00000000;
          use_bstrb_flag    <= 1'b1;
          unalign           <= 1'b0;
          vec_nonsec        <= 1'b1;
          vec_excl          <= 1'b0;
          vec_exokay        <= 1'b0;
          vec_auser         <= {32{1'b0}};
          vec_duser         <= {32{1'b0}};

          err_resp       <= 2'b00;
          skip_seq       <= 1'b0;
          stim_end       <= 1'b0;

          loop_number     = {32{1'b0}};
          timeout         <= {32{1'b0}};
          stim_line_num   <= 0;
          stim_line_tmp    = 0;

          array_ptr         = 1'b0;
          file_array_tmp    = {32{1'b0}};
        end
      else
        begin

          skip_seq <= 1'b0;

          stim_line_tmp = stim_line_num;
          use_bstrb_tmp = use_bstrb_flag;

          if (rd_next === 1'b1)
            begin

              if ((hresp === `ARM_FRBM_RSP_ERROR) &&
                  (hready === 1'b1) &&
                  (err_resp_reg === `ARM_FRBM_ERR_CANC) &&
                  ((vec_cmd === `ARM_FRBM_CMD_SEQ) || (vec_cmd === `ARM_FRBM_CMD_BUSY)))
                begin

                  skip_seq <= 1'b1;

                  loop_number = {32{1'b0}};

                  file_array_tmp = file_array [array_ptr];

                  while ((file_array_tmp [31:28] === `ARM_FRBM_CMD_SEQ)  ||
                         (file_array_tmp [31:28] === `ARM_FRBM_CMD_BUSY) ||
                         (file_array_tmp [31:28] === `ARM_FRBM_CMD_LOOP) ||
                         (file_array_tmp [31:28] === `ARM_FRBM_CMD_COMM))
                    begin

                      stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];

                      if (file_array_tmp [31:28] === `ARM_FRBM_CMD_SEQ)
                        if (file_array_tmp [6] === 1'b1)
                          array_ptr = array_ptr + 8;
                        else
                          array_ptr = array_ptr + 7;

                      else if (file_array_tmp [31:28] === `ARM_FRBM_CMD_BUSY)
                        if (file_array_tmp [6] === 1'b1)
                          array_ptr = array_ptr + 2;
                        else
                          array_ptr = array_ptr + 1;

                      else if (file_array_tmp [31:28] === `ARM_FRBM_CMD_LOOP)
                        array_ptr = array_ptr + 2;

                      else
                        begin
                          array_ptr = array_ptr + 1;
                          file_array_tmp = file_array [array_ptr];
                          array_ptr = array_ptr + file_array_tmp [4:0];
                          array_ptr = array_ptr + 1;
                        end

                      file_array_tmp = file_array [array_ptr];

                    end
                end

              file_array_tmp = file_array [array_ptr];

              while ((file_array_tmp [31:28] === `ARM_FRBM_CMD_COMM) &&
                     (loop_number === `ARM_FRBM_LOW32))
                begin

                  stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];

                  array_ptr = array_ptr + 1;

                  file_array_tmp = file_array [array_ptr];
                  comm_word_num  = file_array_tmp [4:0];

                  array_ptr = array_ptr + 1;
                  file_array_tmp = file_array [array_ptr];

                  for (i = 0; i < comm_word_num; i = i + 1)
                    begin
                      comm_words_hex[((i * 4) + 0)] = file_array_tmp [31:24];
                      comm_words_hex[((i * 4) + 1)] = file_array_tmp [23:16];
                      comm_words_hex[((i * 4) + 2)] = file_array_tmp [15:8];
                      comm_words_hex[((i * 4) + 3)] = file_array_tmp [7:0];

                      array_ptr = array_ptr + 1;
                      file_array_tmp = file_array [array_ptr];
                    end

                  tsk_simulation_comment;

                end

                if (loop_number !== `ARM_FRBM_LOW32)
                  loop_number = (loop_number - 1'b1);


                else

                  begin

                    file_array_tmp = file_array [array_ptr];

                    case (file_array_tmp [31:28])

                      `ARM_FRBM_CMD_WRITE : begin
                        vec_cmd           <= file_array_tmp [31:28];
                        vec_nonsec        <= file_array_tmp [27];
                        vec_lock          <= file_array_tmp [26];
                        vec_excl          <= file_array_tmp [25];
                        vec_exokay        <= file_array_tmp [24];
                        vec_size          <= file_array_tmp [23:21];
                        vec_burst         <= file_array_tmp [20:18];
                        vec_prot          <= file_array_tmp [17:11];
                        err_resp          <= file_array_tmp [9:8];
                        unalign           <= file_array_tmp [7];
                        use_bstrb_tmp      = file_array_tmp [6];
                        stim_line_tmp      = stim_line_tmp + file_array_tmp [5:0];
                        array_ptr          = array_ptr + 1;
                        vec_addr          <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_data [63:32]  <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_data [31:0]   <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_auser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_duser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp   = file_array [array_ptr];
                          vec_bstrb       <= file_array_tmp [7:0];
                          array_ptr        = array_ptr + 1;
                        end

                      end

                      `ARM_FRBM_CMD_READ : begin
                        vec_cmd           <= file_array_tmp [31:28];
                        vec_nonsec        <= file_array_tmp [27];
                        vec_lock          <= file_array_tmp [26];
                        vec_excl          <= file_array_tmp [25];
                        vec_exokay        <= file_array_tmp [24];
                        vec_size          <= file_array_tmp [23:21];
                        vec_burst         <= file_array_tmp [20:18];
                        vec_prot          <= file_array_tmp [17:11];
                        err_resp          <= file_array_tmp [9:8];
                        unalign           <= file_array_tmp [7];
                        use_bstrb_tmp      = file_array_tmp [6];
                        stim_line_tmp      = stim_line_tmp + file_array_tmp [5:0];
                        array_ptr          = array_ptr + 1;
                        vec_addr          <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_data [63:32]  <= file_array [array_ptr];
                        array_ptr          = (array_ptr + 1);
                        vec_data [31:0]   <= file_array [array_ptr];
                        array_ptr          = (array_ptr + 1);
                        vec_data_mask [63:32] <= file_array [array_ptr];
                        array_ptr          = (array_ptr + 1);
                        vec_data_mask [31:0]  <= file_array [array_ptr];
                        array_ptr          = (array_ptr + 1);
                        vec_auser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_duser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp  = file_array [array_ptr];
                          vec_bstrb        <= file_array_tmp [7:0];
                          array_ptr       = (array_ptr + 1);
                        end
                      end

                      `ARM_FRBM_CMD_SEQ : begin
                        vec_cmd     <= file_array_tmp [31:28];
                        err_resp <= file_array_tmp [9:8];
                        use_bstrb_tmp = file_array_tmp [6];
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                        array_ptr  = array_ptr + 1;
                        vec_data [63:32] <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data [31:0]  <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data_mask [63:32] <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data_mask [31:0]  <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_auser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_duser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp  = file_array [array_ptr];
                          vec_bstrb        <= file_array_tmp [7:0];
                          array_ptr       = array_ptr + 1;
                        end
                      end

                      `ARM_FRBM_CMD_BUSY : begin
                        vec_cmd     <= file_array_tmp [31:28];
                        wait_rdy <= file_array_tmp [8];
                        use_bstrb_tmp = file_array_tmp [6];
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                        err_resp <= `ARM_FRBM_ERR_OKAY;
                        array_ptr  = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp  = file_array [array_ptr];
                          vec_bstrb        <= file_array_tmp [7:0];
                          array_ptr       = (array_ptr + 1);
                        end
                      end

                      `ARM_FRBM_CMD_IDLE : begin

                        vec_cmd     <= file_array_tmp [31:28];
                        vec_nonsec  <= file_array_tmp [27];
                        vec_lock    <= file_array_tmp [26];
                        vec_excl    <= 1'b0;
                        vec_exokay  <= 1'b0;
                        vec_size    <= file_array_tmp [23:21];
                        vec_burst   <= file_array_tmp [20:18];
                        vec_prot    <= file_array_tmp [17:11];
                        vec_dir     <= file_array_tmp [10];
                        wait_rdy <= file_array_tmp [8];
                        unalign <= file_array_tmp [7];
                        use_bstrb_tmp = file_array_tmp [6];
                        err_resp <= `ARM_FRBM_ERR_OKAY;
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                        array_ptr  = array_ptr + 1;
                        vec_addr    <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_auser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp  = file_array [array_ptr];
                          vec_bstrb        <= file_array_tmp  [7:0];
                          array_ptr       = array_ptr + 1;
                        end
                      end

                      `ARM_FRBM_CMD_POLL : begin
                        vec_cmd     <= file_array_tmp [31:28];
                        vec_nonsec  <= file_array_tmp [27];
                        vec_excl    <= 1'b0;
                        vec_exokay  <= 1'b0;
                        vec_size    <= file_array_tmp [23:21];
                        vec_burst   <= file_array_tmp [20:18];
                        vec_prot    <= file_array_tmp [17:11];
                        unalign <= file_array_tmp [7];
                        use_bstrb_tmp = file_array_tmp [6];
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                        vec_lock    <= 1'b0 ;
                        err_resp <= `ARM_FRBM_ERR_OKAY;
                        array_ptr  = array_ptr + 1;
                        file_array_tmp  = file_array [array_ptr];
                        timeout <= file_array_tmp [31:0];
                        array_ptr  = array_ptr + 1;
                        vec_addr    <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data [63:32] <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data [31:0]  <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data_mask [63:32] <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_data_mask [31:0]  <= file_array [array_ptr];
                        array_ptr  = array_ptr + 1;
                        vec_auser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        vec_duser         <= file_array [array_ptr];
                        array_ptr          = array_ptr + 1;
                        if (use_bstrb_tmp === 1'b1) begin
                          file_array_tmp  = file_array [array_ptr];
                          vec_bstrb        <= file_array_tmp [7:0];
                          array_ptr       = (array_ptr + 1);
                        end
                      end

                      `ARM_FRBM_CMD_LOOP : begin
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                        array_ptr  = array_ptr + 1;
                        file_array_tmp   = file_array [array_ptr];
                        loop_number = (file_array_tmp [31:0] - 1'b1);
                        array_ptr  = array_ptr + 1;
                      end

                      `ARM_FRBM_CMD_QUIT : begin
                        vec_cmd         <= file_array_tmp [31:28];
                        vec_addr        <= {32{1'b0}};
                        vec_data        <= {64{1'b0}};
                        vec_data_mask   <= {64{1'b1}};
                        vec_nonsec      <= 1'b1;
                        vec_excl        <= 1'b0;
                        vec_exokay      <= 1'b0;
                        vec_size        <= `ARM_FRBM_SZ_BYTE;
                        vec_burst       <= `ARM_FRBM_BUR_SINGLE;
                        vec_prot        <= 7'b0000000;
                        vec_dir         <= 1'b0;
                        vec_lock        <= 1'b0;
                        wait_rdy     <= 1'b0;
                        vec_bstrb       <= 8'b00000000;
                        vec_auser       <= {32{1'b0}};
                        vec_duser       <= {32{1'b0}};
                        unalign     <= 1'b0;
                        err_resp     <= `ARM_FRBM_ERR_OKAY;
                        use_bstrb_tmp = 1;
                        stim_line_tmp = stim_line_tmp + file_array_tmp [5:0];
                      end

                      `ARM_FRBM_UNDEF4 : begin
                        vec_cmd         <= `ARM_FRBM_CMD_IDLE;
                        vec_addr        <= {32{1'b0}};
                        vec_data        <= {64{1'b0}};
                        vec_data_mask    <= {64{1'b1}};
                        vec_size        <= `ARM_FRBM_SZ_BYTE;
                        vec_burst       <= `ARM_FRBM_BUR_SINGLE;
                        vec_prot        <= 7'b0000000;
                        vec_dir         <= 1'b0;
                        vec_lock        <= 1'b0;
                        vec_nonsec      <= 1'b1;
                        wait_rdy     <= 1'b0;
                        vec_bstrb       <= 8'b00000000;
                        unalign     <= 1'b0;
                        use_bstrb_tmp = 1;
                        err_resp     <= `ARM_FRBM_ERR_OKAY;
                        stim_end     <= 1'b1;
                      end

                      default : begin
                        $display (`ARM_FRBM_CMD_MSG, $time, MESSAGE_TAG);
                        $stop;
                      end

                    endcase

                    stim_line_num <= stim_line_tmp;

                  end

            use_bstrb_flag <= use_bstrb_tmp;

            end
        end
    end


  always @ (posedge hclk)
    begin : p_simulation_end
      if  ( (cmd_reg === `ARM_FRBM_CMD_QUIT) ||
            ((stim_end_data === 1'b1) && (stim_end_data_reg === 1'b0))
          )
        begin
          $display ("");
          $write   ("%d %s ", $time, MESSAGE_TAG);

          if  (cmd_reg === `ARM_FRBM_CMD_QUIT)
              $display (`ARM_FRBM_QUIT_MSG);
          else
              $display (`ARM_FRBM_END_MSG);

          $display ("");
          $display (`ARM_FRBM_SUMMARY_HEADER);
          $display (`ARM_FRBM_SUMMARY_DATA, data_err_cnt);
          $display (`ARM_FRBM_SUMMARY_SLAVE, slave_resp_cnt);
          $display (`ARM_FRBM_SUMMARY_POLL, poll_err_cnt);
          $display (`ARM_FRBM_SUMMARY_RUSER, ruser_err_cnt);
          $display (`ARM_FRBM_SUMMARY_EXOKAY, exokay_err_cnt);
          $display (`ARM_FRBM_SUMMARY_FOOTER);
          $display ("");

          if  ( cmd_reg ===`ARM_FRBM_CMD_QUIT )
            begin
              $display (" Simulation halted.");
              $stop;
            end
        end
    end



  always @ (posedge hclk or negedge hresetn)
    begin : p_reg_file_seq
      if (hresetn !== 1'b1)
        begin
          cmd_reg       <= 4'b0000;
          data_reg      <= {64{1'b0}};
          mask_reg      <= {64{1'b0}};
          size_reg      <= 3'b000;
          err_resp_reg  <= 2'b00;
          excl_reg      <= 1'b0;
          exokay_reg    <= 1'b0;
          duser_reg     <= {32{1'b0}};
          stim_end_data <= 1'b0;
          stim_line_reg <= 0;
          timeout_reg   <= {32{1'b0}};
        end
      else
        if (hready === 1'b1)
          begin
            cmd_reg       <= vec_cmd;
            data_reg      <= vec_data;
            mask_reg      <= mask;
            size_reg      <= vec_size;
            err_resp_reg  <= err_resp;
            excl_reg      <= vec_excl;
            exokay_reg    <= vec_exokay;
            duser_reg     <= vec_duser;
            stim_end_data <= stim_end;
            stim_line_reg <= stim_line_num;
            timeout_reg   <= timeout;
          end
    end



  always @ (posedge hclk or negedge hresetn)
    begin : p_stim_end_reg
      if  (hresetn !== 1'b1)
        stim_end_data_reg <= 1'b0;
      else
        stim_end_data_reg <= stim_end_data;
    end


  always @ (posedge hclk or negedge hresetn)
    begin : p_reg_outputs_seq
      if  (hresetn !== 1'b1)
        begin
          haddr_reg  <= {32{1'b0}};
          htrans_reg <= {2{1'b0}};
          hwrite_reg <= 1'b0;
        end
      else
        if (hready === 1'b1)
          begin
            htrans_reg <= i_htrans;
            haddr_reg  <= i_haddr;
            hwrite_reg <= i_hwrite;
          end
    end


  always @ (vec_size)
    begin : p_align_mask_comb
      case (vec_size )
        `ARM_FRBM_SZ_BYTE  : align_mask = 3'b111;
        `ARM_FRBM_SZ_HALF  : align_mask = 3'b110;
        `ARM_FRBM_SZ_WORD  : align_mask = 3'b100;
        `ARM_FRBM_SZ_DWORD : align_mask = 3'b000;
        default   : align_mask = 3'b111;
      endcase
  end



  assign aligned_addr_l   = (haddr_reg [2:0] & align_mask);
  assign aligned_addr    = {haddr_reg [31:3], aligned_addr_l};




  assign non_zero = (((vec_cmd === `ARM_FRBM_CMD_SEQ)  && (cmd_reg === `ARM_FRBM_CMD_SEQ))   ||
                    ((vec_cmd === `ARM_FRBM_CMD_SEQ)  && (cmd_reg === `ARM_FRBM_CMD_WRITE)) ||
                    ((vec_cmd === `ARM_FRBM_CMD_SEQ)  && (cmd_reg === `ARM_FRBM_CMD_READ))  ||
                    ((vec_cmd === `ARM_FRBM_CMD_BUSY) && (cmd_reg === `ARM_FRBM_CMD_SEQ))   ||
                    ((vec_cmd === `ARM_FRBM_CMD_BUSY) && (cmd_reg === `ARM_FRBM_CMD_WRITE)) ||
                    ((vec_cmd === `ARM_FRBM_CMD_BUSY) && (cmd_reg === `ARM_FRBM_CMD_READ))) ? 1'b1
                   : 1'b0;

  always @ (vec_size or non_zero)
    begin : p_calc_add_value_comb
      if (non_zero === 1'b1)
        begin
          case (vec_size)
            `ARM_FRBM_SZ_BYTE : add_value = 4'b0001;
            `ARM_FRBM_SZ_HALF : add_value = 4'b0010;
            `ARM_FRBM_SZ_WORD : add_value = 4'b0100;
            `ARM_FRBM_SZ_DWORD: add_value = 4'b1000;
            default  : add_value = 4'b0000;
          endcase
        end
      else
        add_value = 4'b0000;
    end


  assign  incr_addr = aligned_addr + { {28{1'b0}}, add_value };



  always @ (vec_size or vec_burst)
    begin : p_boundary_value_comb
      case (vec_size)

        `ARM_FRBM_SZ_BYTE :
          case (vec_burst)
            `ARM_FRBM_BUR_WRAP4  : boundary = `ARM_FRBM_BOUND4;
            `ARM_FRBM_BUR_WRAP8  : boundary = `ARM_FRBM_BOUND8;
            `ARM_FRBM_BUR_WRAP16 : boundary = `ARM_FRBM_BOUND16;
            `ARM_FRBM_BUR_SINGLE,
            `ARM_FRBM_BUR_INCR,
            `ARM_FRBM_BUR_INCR4,
            `ARM_FRBM_BUR_INCR8,
            `ARM_FRBM_BUR_INCR16 : boundary = `ARM_FRBM_NOBOUND;
            default     : boundary = `ARM_FRBM_NOBOUND;
          endcase

        `ARM_FRBM_SZ_HALF :
          case (vec_burst)
            `ARM_FRBM_BUR_WRAP4  : boundary = `ARM_FRBM_BOUND8;
            `ARM_FRBM_BUR_WRAP8  : boundary = `ARM_FRBM_BOUND16;
            `ARM_FRBM_BUR_WRAP16 : boundary = `ARM_FRBM_BOUND32;
            `ARM_FRBM_BUR_SINGLE,
            `ARM_FRBM_BUR_INCR,
            `ARM_FRBM_BUR_INCR4,
            `ARM_FRBM_BUR_INCR8,
            `ARM_FRBM_BUR_INCR16 : boundary = `ARM_FRBM_NOBOUND;
            default     : boundary = `ARM_FRBM_NOBOUND;
          endcase

        `ARM_FRBM_SZ_WORD :
          case (vec_burst)
            `ARM_FRBM_BUR_WRAP4  : boundary = `ARM_FRBM_BOUND16;
            `ARM_FRBM_BUR_WRAP8  : boundary = `ARM_FRBM_BOUND32;
            `ARM_FRBM_BUR_WRAP16 : boundary = `ARM_FRBM_BOUND64;
            `ARM_FRBM_BUR_SINGLE,
            `ARM_FRBM_BUR_INCR,
            `ARM_FRBM_BUR_INCR4,
            `ARM_FRBM_BUR_INCR8,
            `ARM_FRBM_BUR_INCR16 : boundary = `ARM_FRBM_NOBOUND;
            default     : boundary = `ARM_FRBM_NOBOUND;
          endcase

        `ARM_FRBM_SZ_DWORD :
          case (vec_burst)
            `ARM_FRBM_BUR_WRAP4  : boundary = `ARM_FRBM_BOUND32;
            `ARM_FRBM_BUR_WRAP8  : boundary = `ARM_FRBM_BOUND64;
            `ARM_FRBM_BUR_WRAP16 : boundary = `ARM_FRBM_BOUND128;
            `ARM_FRBM_BUR_SINGLE,
            `ARM_FRBM_BUR_INCR,
            `ARM_FRBM_BUR_INCR4,
            `ARM_FRBM_BUR_INCR8,
            `ARM_FRBM_BUR_INCR16 : boundary = `ARM_FRBM_NOBOUND;
            default     : boundary = `ARM_FRBM_NOBOUND;
          endcase

        default         : boundary = `ARM_FRBM_NOBOUND;
      endcase
    end


 always @ (boundary or incr_addr or aligned_addr)
   begin : p_wrapped_addr_comb

      case (boundary)

        `ARM_FRBM_NOBOUND :
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND4  :
          if  (incr_addr [1:0] === 2'b00)
            begin
              wrapped_addr [31:2] = aligned_addr [31:2];
              wrapped_addr [1:0] = 2'b00;
            end
          else
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND8 :
          if  (incr_addr [2:0] === 3'b000)
            begin
              wrapped_addr [31:3] = aligned_addr [31:3];
              wrapped_addr [2:0] = 3'b000;
            end
          else
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND16 :
          if  (incr_addr [3:0] === 4'b0000)
            begin
              wrapped_addr [31:4] = aligned_addr [31:4];
              wrapped_addr [3:0] = 4'b0000;
            end
          else
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND32 :
          if  (incr_addr [4:0] === 5'b00000)
            begin
              wrapped_addr [31:5] = aligned_addr [31:5];
              wrapped_addr [4:0] = 5'b00000;
            end
          else
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND64 :
          if  (incr_addr [5:0] === 6'b000000)
            begin
              wrapped_addr [31:6] = aligned_addr [31:6];
              wrapped_addr [5:0] = 6'b000000;
            end
          else
            wrapped_addr = incr_addr;

        `ARM_FRBM_BOUND128 :
          if  (incr_addr [6:0] === 7'b0000000)
            begin
              wrapped_addr [31:7] = aligned_addr [31:7];
              wrapped_addr [6:0] = 7'b0000000;
            end
          else
            wrapped_addr = incr_addr;

        default :
          wrapped_addr  = {32{1'b0}};

      endcase

    end


  assign i_haddr  = ((vec_cmd ===`ARM_FRBM_CMD_SEQ) || (vec_cmd ===`ARM_FRBM_CMD_BUSY)) ? wrapped_addr
                   : vec_addr;

  assign  haddr  = i_haddr;


  assign rd_next = (next_poll_state ===`ARM_FRBM_ST_NO_POLL) &&
                    ( (hready === 1'b1) ||
                      ( (wait_rdy === 1'b0) &&
                        ((vec_cmd ===`ARM_FRBM_CMD_BUSY ) || (vec_cmd ===`ARM_FRBM_CMD_IDLE ))
                      )
                    ) ? 1'b1

                  : 1'b0;


  always @ (vec_cmd or err_resp_reg or hresp or hready or next_poll_state)
    begin : p_htrans_control_comb
      if  (vec_cmd === `ARM_FRBM_CMD_POLL)
        begin
          if (next_poll_state === `ARM_FRBM_ST_POLL_TEST)
            i_htrans = `ARM_FRBM_TRN_NONSEQ;
          else
            i_htrans = `ARM_FRBM_TRN_IDLE;
        end
      else if ((hresp === `ARM_FRBM_RSP_ERROR) &&
               (err_resp_reg === `ARM_FRBM_ERR_CANC) &&
               (hready === 1'b1) &&
               ((vec_cmd === `ARM_FRBM_CMD_SEQ) || (vec_cmd === `ARM_FRBM_CMD_BUSY)))
        i_htrans = `ARM_FRBM_TRN_IDLE;
      else
        case (vec_cmd)
          `ARM_FRBM_CMD_WRITE : i_htrans = `ARM_FRBM_TRN_NONSEQ;
          `ARM_FRBM_CMD_READ  : i_htrans = `ARM_FRBM_TRN_NONSEQ;
          `ARM_FRBM_CMD_SEQ   : i_htrans = `ARM_FRBM_TRN_SEQ;
          `ARM_FRBM_CMD_BUSY  : i_htrans = `ARM_FRBM_TRN_BUSY;
          `ARM_FRBM_CMD_IDLE  : i_htrans = `ARM_FRBM_TRN_IDLE;
          `ARM_FRBM_CMD_QUIT  : i_htrans = `ARM_FRBM_TRN_IDLE;
          default    : i_htrans = `ARM_FRBM_TRN_IDLE;
        endcase
    end

  assign  htrans = i_htrans;


  assign i_hwrite = ((vec_cmd === `ARM_FRBM_CMD_BUSY) ||
                    (vec_cmd === `ARM_FRBM_CMD_SEQ)) ? hwrite_reg

                   : ((vec_cmd === `ARM_FRBM_CMD_WRITE) ||
                      ((vec_cmd === `ARM_FRBM_CMD_IDLE) && (vec_dir === 1'b1))) ? 1'b1

                   : 1'b0;

  assign  hwrite = i_hwrite;


  assign hmastlock  = vec_lock;
  assign hsize      = vec_size;
  assign hburst     = vec_burst;
  assign hprot      = vec_prot;
  assign hnonsec    = vec_nonsec;
  assign hexcl      = vec_excl;
  assign hauser     = vec_auser;
  assign hunalign   = unalign;
  assign hmaster    = MASTER_VALUE;

  assign linenum    = stim_line_num;


  always @ (i_haddr[2:0] or vec_size or use_bstrb_flag or vec_bstrb)
    begin : p_bstrb_comb
      if  (use_bstrb_flag === 1'b1)
       i_hbstrb  = vec_bstrb;
      else
        begin
        case (vec_size)
          `ARM_FRBM_SZ_BYTE : begin
            case (i_haddr [2:0])
              3'b000  : i_hbstrb = 8'b00000001;
              3'b001  : i_hbstrb = 8'b00000010;
              3'b010  : i_hbstrb = 8'b00000100;
              3'b011  : i_hbstrb = 8'b00001000;
              3'b100  : i_hbstrb = 8'b00010000;
              3'b101  : i_hbstrb = 8'b00100000;
              3'b110  : i_hbstrb = 8'b01000000;
              3'b111  : i_hbstrb = 8'b10000000;
              default : i_hbstrb = 8'b00000000;
            endcase
          end

          `ARM_FRBM_SZ_HALF : begin
            case (i_haddr [2:0])
              3'b000  : i_hbstrb = 8'b00000011;
              3'b010  : i_hbstrb = 8'b00001100;
              3'b100  : i_hbstrb = 8'b00110000;
              3'b110  : i_hbstrb = 8'b11000000;
              default : i_hbstrb = 8'b00000000;
            endcase
          end

          `ARM_FRBM_SZ_WORD : begin
            case (i_haddr [2:0])
              3'b000  : i_hbstrb = 8'b00001111;
              3'b100  : i_hbstrb = 8'b11110000;
              default : i_hbstrb = 8'b00000000;
            endcase
          end


          `ARM_FRBM_SZ_DWORD : begin
              case (i_haddr [2:0])
              3'b000  : i_hbstrb = 8'b11111111;
              default : i_hbstrb = 8'b00000000;
            endcase
          end

          default     : i_hbstrb  = 8'b00000000;
       endcase
      end
    end

  assign hbstrb = i_hbstrb;



  assign bstrb_mask [7:0]    = i_hbstrb [0] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [15:8]   = i_hbstrb [1] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [23:16]  = i_hbstrb [2] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [31:24]  = i_hbstrb [3] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [39:32]  = i_hbstrb [4] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [47:40]  = i_hbstrb [5] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [55:48]  = i_hbstrb [6] ? 8'b11111111 : 8'b00000000;
  assign bstrb_mask [63:56]  = i_hbstrb [7] ? 8'b11111111 : 8'b00000000;


  assign mask = (use_bstrb_flag === 1'b1) ? (vec_data_mask & bstrb_mask) : vec_data_mask;


  assign i_hwdata = (
                    (i_hwrite === 1'b1) &&
                    (hready === 1'b1) &&
                    ((i_htrans === `ARM_FRBM_TRN_NONSEQ) ||
                     (i_htrans === `ARM_FRBM_TRN_SEQ))
                   ) ? vec_data
                   : {64{1'b0}};
  assign i_hwuser = (
                    (i_hwrite === 1'b1) &&
                    (hready === 1'b1) &&
                    ((i_htrans === `ARM_FRBM_TRN_NONSEQ) ||
                     (i_htrans === `ARM_FRBM_TRN_SEQ))
                   ) ? vec_duser
                   : {32{1'b0}};

  always @ (posedge hclk or negedge hresetn)
    begin : p_reg_wdata_seq
      if (hresetn !== 1'b1)
        hwdata_reg <= {64{1'b0}};
      else if (hready === 1'b1)
        hwdata_reg <= i_hwdata;
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_reg_wuser_seq
      if (hresetn !== 1'b1)
        hwuser_reg <= {32{1'b0}};
      else if (hready === 1'b1)
        hwuser_reg <= i_hwuser;
    end

  assign  hwdata = hwdata_reg;
  assign  hwuser = hwuser_reg;

  always @ (data_reg or hresp or hrdata or mask_reg or htrans_reg or hwrite_reg)
    begin : p_data_compare_comb
      if  ((hwrite_reg === 1'b0) && (hresp === `ARM_FRBM_RSP_OKAY) &&
           ((htrans_reg ===`ARM_FRBM_TRN_NONSEQ) || (htrans_reg ===`ARM_FRBM_TRN_SEQ)))
        data_compare = ((data_reg & mask_reg) ^ (hrdata & mask_reg));
      else
        data_compare = {64{1'b0}};
    end

  always @ (duser_reg or hresp or hruser or htrans_reg or hwrite_reg)
    begin : p_user_compare_comb
      if  ((hwrite_reg === 1'b0) && (hresp === `ARM_FRBM_RSP_OKAY) &&
           ((htrans_reg ===`ARM_FRBM_TRN_NONSEQ) || (htrans_reg ===`ARM_FRBM_TRN_SEQ)))
        user_compare = (duser_reg ^ hruser);
      else
        user_compare = {32{1'b0}};
    end

  assign data_err = (data_compare !== {64{1'b0}}) ? 1'b1
                     : 1'b0;
  assign ruser_err = (user_compare !== {32{1'b0}}) ? 1'b1
                     : 1'b0;


  always @ (poll_state or vec_cmd or data_err or poll_count or timeout)
    begin : p_poll_state_comb
      case (poll_state)

        `ARM_FRBM_ST_NO_POLL : begin
          if (vec_cmd === `ARM_FRBM_CMD_POLL)
            begin
              next_poll_state = `ARM_FRBM_ST_POLL_TEST;
              next_poll_count = timeout;
            end
          else
            begin
              next_poll_state = `ARM_FRBM_ST_NO_POLL;
              next_poll_count = poll_count;
            end
        end

        `ARM_FRBM_ST_POLL_TEST : begin
          if ((data_err === 1'b0) ||
              (poll_count === 32'h00000001))
            begin
              next_poll_state = `ARM_FRBM_ST_NO_POLL;
              next_poll_count = 32'b00000000;
            end
          else
            begin
              next_poll_state = `ARM_FRBM_ST_POLL_READ;
              if (poll_count !== 32'b00000000)
                next_poll_count = poll_count - 1'b1;
              else
                next_poll_count = poll_count;
            end
        end

        `ARM_FRBM_ST_POLL_READ :
          begin
            next_poll_state = `ARM_FRBM_ST_POLL_TEST;
            next_poll_count = poll_count;
          end

        default:
          begin
            next_poll_state = `ARM_FRBM_ST_NO_POLL;
            next_poll_count = poll_count;
          end

      endcase
    end

  always @ (posedge hclk or negedge hresetn)
    begin : p_poll_state_seq
      if  (hresetn !== 1'b1)
        begin
          poll_state <= `ARM_FRBM_ST_NO_POLL;
          poll_count <= 32'b00000000;
        end
      else
        if (hready === 1'b1)
          begin
            poll_state <= next_poll_state;
            poll_count <= next_poll_count;
          end
    end

endmodule

