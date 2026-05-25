//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2009-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Revision            : $Revision: 38886 $
//
//      Release Information : CoreSight STM-500 Global Bundle-r0p1-00rel0
//-----------------------------------------------------------------------------
//      Purpose:
//      STM APB Slave Interface
//-----------------------------------------------------------------------------

module cxstm500_apbslvif  (
  // Inputs
  input wire         CLK,            // clock
  input wire         STMRESETn,      // reset
  input wire         PSELDBG,        // APB slave select
  input wire         PENABLEDBG,     // APB enable
  input wire         PWRITEDBG,      // APB write
  input wire  [11:2] PADDRDBG,       // APB address
  input wire         PADDRDBG31,     // APB address bit 31
  input wire  [31:0] PWDATADBG,      // APB write data
  input wire  [31:0] read_data_i,    // read data

  // Outputs
  output wire        apb_clk_req_o,  // APB clock request
  output wire        PREADYDBG,      // APB ready
  output wire [31:0] PRDATADBG,      // APB read data
  output wire [11:2] paddrdbg_r_o,   // registered APB address
  output wire        paddrdbg31_r_o, // registered APB PADDRDBG31
  output wire [31:0] pwdatadbg_r_o,  // registered APD write data
  output wire        reg_write_en_o, // register file write enable

  // Authentication
  input wire         DBGEN,          // Debug Enable
  input wire         NIDEN,          // Non-invasive Debug Enable
  input wire         SPIDEN,         // Secure Debug Enable
  input wire         SPNIDEN,        // Secure Non-invasive Debug Enable
  input wire         NSGUAREN,       // Enable non-secure guaranteed stimulus port accesses
  output wire        dbgen_r_o,      // Debug Enable registred
  output wire        niden_r_o,      // Non-invasive Debug Enable registred
  output wire        spiden_r_o,     // Secure Debug Enable registred
  output wire        spniden_r_o,    // Secure Non-invasive Debug Enable registred
  output wire        nsguaren_r_o,   // Enable non-secure guaranteed stimulus port accesses registred
  output wire        auth_flush_o,   // Flush on DBGEN and NIDEN removed
  input wire         q_stopped_i,    // Q-Channel stopped
  input wire         q_stop_i        // Q-Channel stopping
  );

  //----------------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------------
  reg        nxt_apb_clk_req;
  reg        nxt_reg_write;
  reg        nxt_preadydbg;
  wire [31:0] nxt_prdatadbg;
  wire [11:2] nxt_paddrdbg;
  wire        reg_write_en;

  wire dbgen_we;
  wire niden_we;
  wire spiden_we;
  wire spniden_we;
  wire nsguaren_we;

  wire apb_we;
  wire apb_clk_req_reg_we;
  wire preadydbg_reg_we;

  //---------------------------------------------------------------------------
  // Registers
  //---------------------------------------------------------------------------
  reg         apb_clk_req_reg;
  reg         reg_write_reg;
  reg         reg_write2_reg;
  reg         preadydbg_reg;
  reg  [31:0] prdatadbg_reg;
  reg  [11:2] paddrdbg_reg;
  reg         paddrdbg31_reg;
  reg  [31:0] pwdatadbg_reg;

  reg         dbgen_reg;
  reg         niden_reg;
  reg         spiden_reg;
  reg         spniden_reg;
  reg         nsguaren_reg;

  reg [1:0]   state;
  reg [1:0]   nxt_state;

  //---------------------------------------------------------------------------
  //
  // Main body of code
  // =================
  //
  //---------------------------------------------------------------------------

  localparam APB_IDLE         = 2'b00;
  localparam APB_WRITE        = 2'b01;
  localparam APB_READ_ENABLE  = 2'b10;
  localparam APB_READ         = 2'b11;

  always @* begin : next_apb_state
    case (state)

      //APB IDLE STATE
      APB_IDLE : begin
        nxt_state       = (PSELDBG & PWRITEDBG & ~q_stop_i)  ? APB_WRITE :
                                      (PSELDBG & ~q_stop_i)  ? APB_READ_ENABLE :
                                                               APB_IDLE;
        nxt_preadydbg   = (PSELDBG & PWRITEDBG & ~q_stop_i)  ? 1'b1 : 1'b0;
        nxt_reg_write   = (PSELDBG & PWRITEDBG & ~q_stop_i)  ? 1'b1 : 1'b0;
        nxt_apb_clk_req =             (PSELDBG & ~q_stop_i)  ? 1'b1 : 1'b0;

      end

      //APB Write Transaction
      APB_WRITE : begin
        nxt_state       = APB_IDLE;
        nxt_preadydbg   = 1'b0;
        nxt_reg_write   = 1'b0;
        nxt_apb_clk_req = 1'b1;

      end

      //APB Read Transaction - PSEL/PENABLE/~PREADY Phase
      APB_READ_ENABLE : begin
        nxt_state       = APB_READ;
        nxt_preadydbg   = 1'b1;
        nxt_reg_write   = 1'b0;
        nxt_apb_clk_req = 1'b1;

      end

      //APB Read Transaction - PSEL/PENABLE/PREADY Phase
      APB_READ : begin
        nxt_state       = APB_IDLE;
        nxt_preadydbg   = 1'b0;
        nxt_reg_write   = 1'b0;
        nxt_apb_clk_req = 1'b1;

      end

      default : begin
        nxt_state       = APB_IDLE;
        nxt_preadydbg   = 1'b0;
        nxt_reg_write   = 1'b0;
        nxt_apb_clk_req = 1'b0;

      end
    endcase
  end

  assign apb_we = PSELDBG & ~q_stopped_i;

  //Clock APB FSM State - Reset to APB_IDLE
  always @(posedge CLK or negedge STMRESETn) begin
    if (!STMRESETn) begin
      state <= APB_IDLE;

    end else if (apb_we) begin
      state <= nxt_state;

    end
  end

  //Clock request
  assign apb_clk_req_reg_we = apb_we | apb_clk_req_reg;

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (!STMRESETn)
      apb_clk_req_reg  <= 1'b0;
    else if(apb_clk_req_reg_we)
      apb_clk_req_reg  <= nxt_apb_clk_req;
  end

  // APB registered address and write data
  assign nxt_paddrdbg[11:2] = PADDRDBG[11:2] & {10{PSELDBG}};

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (!STMRESETn) begin
        paddrdbg_reg[11:2]  <= {10{1'b0}};
        paddrdbg31_reg      <=     1'b0;
        pwdatadbg_reg[31:0] <= {32{1'b0}};
    end else begin
      if (apb_we) begin
        paddrdbg_reg[11:2]  <= nxt_paddrdbg[11:2];
        paddrdbg31_reg      <= PADDRDBG31;
        pwdatadbg_reg[31:0] <= PWDATADBG[31:0];
      end
    end
  end

  // Register file write enable
  // APB write request is registered with PSEL when not in Q_STOPPED
  // Register file write enable is generated on rising edge of registred APB write request i.e
  // it happens in the cycle after address and data are sampled
  always @(posedge CLK or negedge STMRESETn)
  begin
    if (!STMRESETn)
      reg_write_reg  <= 1'b0;
    else if(apb_we)
      reg_write_reg  <= nxt_reg_write;
  end

  // Delayed reg_write_reg for edge detection
  // Enabled with reg_write_reg ^ reg_write2_reg to minimise idle power by clocking
  // only when reg_write_reg is different from reg_write2_reg
  assign reg_write_en = reg_write_reg ^ reg_write2_reg;
  always @(posedge CLK or negedge STMRESETn)
  begin
    if (!STMRESETn)
      reg_write2_reg  <= 1'b0;
    else if (reg_write_en)
      reg_write2_reg  <= reg_write_reg;
  end

  // APB writes take 2 cycles of CLK qualified with PSEL
  // APB reads take 3 cycles of CLK qualified with PSEL
  //  - on reads APB ready is generated with one wait state due to registering of address
  assign preadydbg_reg_we = apb_we | preadydbg_reg;

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (!STMRESETn)
      preadydbg_reg  <= 1'b0;
    else if(preadydbg_reg_we)
      preadydbg_reg  <= nxt_preadydbg;
  end

  assign nxt_prdatadbg[31:0] = read_data_i[31:0];
  // APB read data
  always @(posedge CLK)
  begin
    if(apb_we)
      prdatadbg_reg[31:0]  <= nxt_prdatadbg[31:0];
  end

  // Authentication interface is registered for timing reasons
  // Independent enables based on previous value to minimise dynamic power
  assign dbgen_we     = dbgen_reg    ^ DBGEN;
  assign niden_we     = niden_reg    ^ NIDEN;
  assign spiden_we    = spiden_reg   ^ SPIDEN;
  assign spniden_we   = spniden_reg  ^ SPNIDEN;
  assign nsguaren_we  = nsguaren_reg ^ NSGUAREN;

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (~STMRESETn)
      dbgen_reg <= 1'b0;
    else if (dbgen_we)
      dbgen_reg <= DBGEN;
  end

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (~STMRESETn)
      niden_reg <= 1'b0;
    else if (niden_we)
      niden_reg <= NIDEN;
  end

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (~STMRESETn)
      spiden_reg <= 1'b0;
    else if (spiden_we)
      spiden_reg <= SPIDEN;
  end

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (~STMRESETn)
      spniden_reg <= 1'b0;
    else if (spniden_we)
      spniden_reg <= SPNIDEN;
  end

  always @(posedge CLK or negedge STMRESETn)
  begin
    if (~STMRESETn)
      nsguaren_reg <= 1'b0;
    else if (nsguaren_we)
      nsguaren_reg <= NSGUAREN;
  end

  //----------------------------------------------------------------------------
  // Output assignment
  //----------------------------------------------------------------------------
  assign apb_clk_req_o       = apb_clk_req_reg;
  assign reg_write_en_o      = reg_write_reg & ~reg_write2_reg;
  assign paddrdbg31_r_o      = paddrdbg31_reg;
  assign paddrdbg_r_o[11:2]  = paddrdbg_reg[11:2];
  assign PREADYDBG           = preadydbg_reg;
  assign PRDATADBG[31:0]     = prdatadbg_reg[31:0];
  assign pwdatadbg_r_o[31:0] = pwdatadbg_reg[31:0];

  assign dbgen_r_o           = dbgen_reg;
  assign niden_r_o           = niden_reg;
  assign spiden_r_o          = spiden_reg;
  assign spniden_r_o         = spniden_reg;
  assign nsguaren_r_o        = nsguaren_reg;

  // Flush is triggered when authentication is removed
  assign auth_flush_o        = ~(dbgen_reg | niden_reg);

  wire unused_ok;
  assign unused_ok = &{1'b0,PENABLEDBG};

`ifdef ARM_ASSERT_ON
  //----------------------------------------------------------------------------
  // OVL Assertions
  //----------------------------------------------------------------------------

  // X propagation
  assert_never_unknown #(`OVL_FATAL, 1, `OVL_ASSERT, "PSEL is X")
    ovl_never_unknown_pseldbg (
      .clk       (CLK),
      .reset_n   (STMRESETn),
      .qualifier (1'b1),
      .test_expr (PSELDBG)
    );

`endif
endmodule // cxstm500_apbslvif
