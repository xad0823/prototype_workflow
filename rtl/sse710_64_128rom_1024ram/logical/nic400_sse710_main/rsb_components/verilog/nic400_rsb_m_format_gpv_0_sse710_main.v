//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2019-2021 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//
//      Release Information : SSE710-r0p0-00eac0
//
//------------------------------------------------------------------------------
// Verilog-2001 (IEEE Std 1364-2001)
//------------------------------------------------------------------------------




module nic400_rsb_m_format_gpv_0_sse710_main
  (
   rclk,
   rresetn,

   awrite,
   aid,
   aaddr,
   alen,
   asize,
   aburst,
   alock,
   acache,
   aprot,
   avalid,
   aready,
   wdata,
   wstrb,
   wlast,
   wvalid,
   wready,

   rsb_data_new,
   rsb_valid_new,
   rsb_ready_new,

   tx_done,

   tx_last,

   tx_id,

   wlast_strbless
   );

`include "Axi.v"

`include "nic400_rsb_defs_sse710_main.v"

  parameter MID_VALUE = 0;
  parameter ID_WIDTH =  8;
  parameter ID_MAX   = ID_WIDTH - 1;

  input                   rclk;         
  input                   rresetn;      

  input                   awrite;      
  input        [ID_MAX:0] aid;         
  input        [31:0]     aaddr;       
  input        [7:0]      alen;        
  input        [2:0]      asize;       
  input        [1:0]      aburst;      
  input                   alock;       
  input        [3:0]      acache;      
  input        [2:0]      aprot;       
  input                   avalid;      
  output                  aready;      
  input        [31:0]     wdata;        
  input        [3:0]      wstrb;        
  input                   wlast;        
  input                   wvalid;       
  output                  wready;       

  output       [7:0]      rsb_data_new;
  output                  rsb_valid_new;
  input                   rsb_ready_new;

  input                   tx_done;

  input                   tx_last;
  
  output       [ID_MAX:0] tx_id;

  output                  wlast_strbless;

  reg          [ID_MAX:0] tx_id;
  reg               [7:0] rsb_data_new;
  

  wire             [31:0] mux_addr;
  wire                    mux_ready;

  wire                    reg_addr_en;
  wire                    reg_ctl_en;
  reg              [31:0] reg_addr;
  reg               [3:0] reg_len;
  reg               [2:0] reg_size;
  reg               [1:0] reg_burst;
  reg                     reg_addr_valid;
  wire                    reg_addr_valid_en;
  reg                     reg_r_n_w;
  wire             [11:0] reg_addr_incr;
  

  wire                    wstrbless_rx;
  reg                     dec_on_wstrbless;

  reg                     wlast_strbless_i;

  wire                    reg_wdata_en;
  reg [31:0]              reg_wdata;
  reg  [3:0]              reg_wstrb;
  reg                     reg_wlast;
  wire                    i_wready;
  reg                     reg_wdata_valid;
  wire                    reg_wdata_valid_en;

  wire                    reg_tx_valid;
  reg [3:0]               rsb_state;
  reg [3:0]               rsb_state_reg;
  wire                    rsb_state_reg_en;
  wire [7:0]              rsb_ctl_data;

  reg [7:0]                  burst_count;
  wire[7:0]                 burst_count_nxt;
  wire                    burst_count_en;

  


  assign mux_addr  = (mux_ready ? aaddr
                      : {reg_addr[31:12],reg_addr_incr[11:0]});

  assign aready = mux_ready;



  assign reg_ctl_en = avalid & mux_ready;

  always @(posedge rclk or negedge rresetn)
  begin : p_reg_ctl
    if (~rresetn)
    begin
      tx_id     <= {ID_WIDTH{1'b0}};
      reg_len   <= {4{1'b0}};
      reg_size  <= {3{1'b0}};
      reg_burst <= {2{1'b0}};
      reg_r_n_w <= 1'b0;
    end
    else if (reg_ctl_en)
    begin
      tx_id     <= aid;
      reg_len   <= alen[3:0];
      reg_size  <= asize;
      reg_burst <= aburst;
      reg_r_n_w <= ~awrite;
    end
  end

  assign reg_addr_valid_en = reg_ctl_en | tx_last;
  
  always @(posedge rclk or negedge rresetn)
  begin : p_addr_reg_addr_valid
    if (~rresetn)
      reg_addr_valid <= 1'b0;
    else if (reg_addr_valid_en)
      reg_addr_valid <= reg_ctl_en;
  end

  assign mux_ready = ~reg_addr_valid;

  assign reg_addr_en = (reg_ctl_en |
                        dec_on_wstrbless |
                        ((rsb_state_reg == `STATE_DAT0) & rsb_ready_new));
    
  always @(posedge rclk or negedge rresetn)
  begin : p_reg_addr
    if (~rresetn)
    begin
      reg_addr  <= {32{1'b0}};
    end
    else if (reg_addr_en)
    begin
      reg_addr  <= mux_addr;
    end
  end

  nic400_rsb_m_agen_sse710_main
  u_agen
    (
     .reg_addr      (reg_addr[11:0]),
     .reg_len       (reg_len),
     .reg_size      (reg_size),
     .reg_burst     (reg_burst),
     .reg_addr_incr (reg_addr_incr)
     );
  


  assign reg_wdata_en = wvalid & i_wready;

  always @(posedge rclk or negedge rresetn)
  begin : p_reg_w_ch_payload_rst
    if (~rresetn) begin
      reg_wlast <= 1'b0;
      reg_wdata <= 32'b0;
    end else if (reg_wdata_en) begin
      reg_wdata <= wdata;
      reg_wlast <= wlast;
    end
  end

  always @(posedge rclk)
  begin : p_reg_w_ch_payload_nrst
    if (reg_wdata_en) begin
      reg_wstrb <= wstrb;
    end
  end

  assign reg_wdata_valid_en = (reg_wdata_en |
                               (
                                (rsb_state == `STATE_DAT3) &
                                ~reg_r_n_w &
                                rsb_ready_new
                               ) |
                               dec_on_wstrbless | wlast_strbless_i
                              );
  
  always @(posedge rclk or negedge rresetn)
  begin : p_reg_wdata_valid
    if (~rresetn)
      reg_wdata_valid <= 1'b0;
    else if (reg_wdata_valid_en)
      reg_wdata_valid <= reg_wdata_en;
  end

  assign i_wready = ~reg_wdata_valid;
  assign wready = i_wready;

  assign wstrbless_rx = ~(|reg_wstrb);

  assign burst_count_en = reg_ctl_en |
                          dec_on_wstrbless |
                          tx_done;

  assign burst_count_nxt = (reg_ctl_en ? alen
                            : (burst_count - {{7{1'b0}},1'b1}));
  
  always @(posedge rclk or negedge rresetn)
  begin : p_burst_count
    if (~rresetn)
      burst_count <= {8{1'b0}};
    else if (burst_count_en)
      burst_count <= burst_count_nxt;
  end


  assign reg_tx_valid = reg_addr_valid & (reg_r_n_w | reg_wdata_valid);

  assign rsb_ctl_data = {1'b0,                         
                         (burst_count == {8{1'b0}}), 
                         1'b1,                         
                         3'b011,                       
                         1'b0,                         
                         reg_r_n_w                     
                        };

  always @(reg_tx_valid or reg_addr or
           rsb_ctl_data or reg_wdata or rsb_state_reg or tx_done or
           reg_r_n_w or wstrbless_rx or reg_wlast or tx_last)
  begin : p_state_machine_comb
    dec_on_wstrbless = 1'b0;
    wlast_strbless_i = 1'b0;
    rsb_data_new     = {8{1'b0}};
    case (rsb_state_reg)
      `STATE_IDLE:
        begin
          if (reg_tx_valid)
          begin
            if (!reg_r_n_w && wstrbless_rx)
            begin
              if (reg_wlast)
              begin
                wlast_strbless_i = 1'b1;
                rsb_state = `STATE_WAIT;
              end
              else
              begin
                dec_on_wstrbless = 1'b1;
                rsb_state = `STATE_IDLE;
              end
            end
            else
            begin
              rsb_state = `STATE_ADN;
              rsb_data_new = reg_addr[19:12];
            end
          end
          else
          begin
            rsb_state = `STATE_IDLE;
          end
        end
      `STATE_ADN:
        begin
          rsb_state = `STATE_MID;
          rsb_data_new = MID_VALUE;
        end
      `STATE_MID:
        begin
          rsb_state = `STATE_CTL;
          rsb_data_new = rsb_ctl_data;
        end
      `STATE_CTL:
        begin
          rsb_state = `STATE_ADR1;
          rsb_data_new = reg_addr[9:2];
        end
      `STATE_ADR1:
        begin
          rsb_state = `STATE_ADR2;
          rsb_data_new = {{6{1'b0}},reg_addr[11:10]};
        end
      `STATE_ADR2:
        begin
          rsb_state = `STATE_DAT0;
          rsb_data_new = reg_wdata[7:0] & {8{~reg_r_n_w}};
        end
      `STATE_DAT0:
        begin
          rsb_state = `STATE_DAT1;
          rsb_data_new = reg_wdata[15:8] & {8{~reg_r_n_w}};
        end
      `STATE_DAT1:
        begin
          rsb_state = `STATE_DAT2;
          rsb_data_new = reg_wdata[23:16] & {8{~reg_r_n_w}};
        end
      `STATE_DAT2:
        begin
          rsb_state = `STATE_DAT3;
          rsb_data_new = reg_wdata[31:24] & {8{~reg_r_n_w}};
        end
      `STATE_DAT3:
        begin
          rsb_state = `STATE_WAIT;
        end

      `STATE_WAIT:
        begin
          if (tx_done || tx_last)
            rsb_state = `STATE_IDLE;
          else
            rsb_state = `STATE_WAIT;
        end

      `STATE_U4_B,
        `STATE_U4_C,
        `STATE_U4_D,
        `STATE_U4_E,
        `STATE_U4_F:
          begin
            rsb_state = `STATE_IDLE;
          end

      default:
        begin
          rsb_state = `STATE_U4_X;
          rsb_data_new = {8{1'bX}};
        end
    endcase 
  end 

  assign rsb_state_reg_en = (rsb_ready_new                  |
                             (rsb_state     == `STATE_WAIT) |
                             (rsb_state_reg == `STATE_WAIT));

  always @(posedge rclk or negedge rresetn)
  begin : p_state_machine
    if (~rresetn)
      rsb_state_reg <= `STATE_IDLE;
    else if (rsb_state_reg_en)
      rsb_state_reg <= rsb_state;
  end

  assign rsb_valid_new = ((rsb_state != `STATE_IDLE) &
                          (rsb_state != `STATE_WAIT));

  assign wlast_strbless = wlast_strbless_i;  

`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  wire                    illegal_state;        

  assign illegal_state = (rsb_state_reg == `STATE_U4_B) |
                         (rsb_state_reg == `STATE_U4_C) |
                         (rsb_state_reg == `STATE_U4_D) |
                         (rsb_state_reg == `STATE_U4_E) |
                         (rsb_state_reg == `STATE_U4_F);

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Format): RSB entered illegal state.")
  rsb_illegal_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (illegal_state)
  );


  assert_never_unknown #(`OVL_WARNING,
                 4, 
                 `OVL_ASSERT,
                 "RSB (Master - Format): RSB entered unreachable state.")
  rsb_unreachable_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .qualifier  (1'b1),
    .test_expr  (rsb_state_reg)
  );


  wire                    nsec_trans_rx;        
  reg                     nsec_trans_rx_reg;    
  wire                    nsec_trans_rx_h;      
  reg                     nsec_trans_rx_h_reg;  

  wire                    nsec_trans_rx_once;   

  assign nsec_trans_rx = avalid & aready & aprot[1];

  always @ (posedge rclk or negedge rresetn)
  begin : p_nsec_trans_rx_reg_seq
    if (~rresetn) begin
      nsec_trans_rx_reg   <= 1'b0;
      nsec_trans_rx_h_reg <= 1'b0;
    end else begin
      nsec_trans_rx_reg   <= nsec_trans_rx;
      nsec_trans_rx_h_reg <= nsec_trans_rx_h;
    end
  end 

  assign nsec_trans_rx_h = nsec_trans_rx_reg ? 1'b1 :
                                   (~rresetn ? 1'b0 : nsec_trans_rx_h_reg);

  assign nsec_trans_rx_once = nsec_trans_rx & ~nsec_trans_rx_h;

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Format): Non-secure Transaction to RSB.")
  rsb_nsec_trans_rx
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (nsec_trans_rx_once)
  );

`ifdef ARM_OVL_IGNORE_UNALIGN

  initial
    begin : p_arm_ovl_ignore_unalign
      $display("ARM_OVL_IGNORE_UNALIGN: Unalignment OVLs are disabled in %m");
    end 

`else


  wire                    unaligned_addr;       
  wire                    unaligned_rsb;        

  assign unaligned_addr = |aaddr[1:0];

  assign unaligned_rsb = unaligned_addr & reg_ctl_en;

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Format): RSB has received an unaligned access.")
  rsb_unaligned
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (unaligned_rsb)
  );


  wire                    illegal_asize;        

  assign illegal_asize = reg_ctl_en & (asize != `AXI_ASIZE_32);

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Format): RSB has received an illegal AxSIZE")
  rsb_illegal_asize
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (illegal_asize)
  );


  wire                    illegal_wstrb;        

  assign illegal_wstrb = reg_wdata_en &
                         (wstrb != 4'b1111) &
                         (wstrb != 4'b0000);

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Master - Format): RSB has received a sparse write data beat.")
  rsb_illegal_wstrb
  (
    .clk            (rclk),
    .reset_n        (rresetn),
    .test_expr      (illegal_wstrb)
  );

`endif 

`endif 

`include "Axi_undefs.v"

`include "nic400_rsb_undefs_sse710_main.v"

endmodule 


