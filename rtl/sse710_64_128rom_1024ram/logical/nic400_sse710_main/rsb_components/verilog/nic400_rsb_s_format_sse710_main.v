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



module nic400_rsb_s_format_sse710_main
  (
   rclk,
   rresetn,

   rsb_data_apb,
   rsb_valid_apb,
   rsb_ready_apb,
  
   rsb_data_done,
   rsb_valid_done,
   rsb_ready_done,

   psel,
   penable,
   pwrite,
   paddr,
   pwdata,
   prdata,
   pready,
   pslverr,

   bcast_addr,

   apb_done);

`include "nic400_rsb_defs_sse710_main.v"


  input                   rclk;         
  input                   rresetn;      

  input             [7:0] rsb_data_apb;
  input                   rsb_valid_apb;
  output                  rsb_ready_apb;
  
  output            [7:0] rsb_data_done;
  output                  rsb_valid_done;
  input                   rsb_ready_done;

  output                  psel;
  output                  penable;
  output                  pwrite;
  output           [31:0] paddr;
  output           [31:0] pwdata;
  input            [31:0] prdata;
  input                   pready;
  input                   pslverr;

  input                   bcast_addr;

  output                  apb_done;

  reg                     apb_done_i;
  reg               [7:0] rsb_data_done;
  
  wire              [3:0] apb_state_nxt;
  reg                     apb_state_en;
  reg               [3:0] apb_state;

  wire                    rsb_outgoing_en;
  reg                     rsb_outgoing;

  wire                    apb_done_nxt;
  wire                    apb_done_en;

  wire                    apb_read;

  wire                    rsb_adn_en;
  wire                    rsb_mid_en;
  wire                    rsb_ctl_en;
  wire                    rsb_err_en;
  wire                    rsb_adr1_en;
  wire                    rsb_adr2_en;
  wire                    rsb_dat0_en;
  wire                    rsb_dat1_en;
  wire                    rsb_dat2_en;
  wire                    rsb_dat3_en;
  
  wire                    rsb_err_reg_nxt;
  wire              [7:0] rsb_dat0_reg_nxt;
  wire              [7:0] rsb_dat1_reg_nxt;
  wire              [7:0] rsb_dat2_reg_nxt;
  wire              [7:0] rsb_dat3_reg_nxt;
 
  reg               [7:0] rsb_adn_reg;
  reg               [7:0] rsb_mid_reg;
  reg               [5:0] rsb_ctl_reg;
  reg                     rsb_err_reg;
  reg               [7:0] rsb_adr1_reg;
  reg               [1:0] rsb_adr2_reg;
  reg               [7:0] rsb_dat0_reg;
  reg               [7:0] rsb_dat1_reg;
  reg               [7:0] rsb_dat2_reg;
  reg               [7:0] rsb_dat3_reg;
  reg                     bcast_addr_reg;




  assign apb_state_nxt = (((~rsb_outgoing & (apb_state == `STATE_PENABLE)) |
                           (rsb_outgoing & (apb_state == `STATE_DAT3))) ?
                          `STATE_ADN : (apb_state + 4'b0001));
  
  always @(apb_state or pready or rsb_outgoing or rsb_ready_done or
           rsb_valid_apb)
  begin : p_apb_state_en
    case (apb_state)
      `STATE_ADN,
        `STATE_MID,
        `STATE_CTL,
        `STATE_ADR1,
        `STATE_ADR2,
        `STATE_DAT0,
        `STATE_DAT1,
        `STATE_DAT2,
        `STATE_DAT3:
          apb_state_en = ((~rsb_outgoing & rsb_valid_apb) |
                          (rsb_outgoing & rsb_ready_done));
      `STATE_PSEL:
        apb_state_en = 1'b1;

      `STATE_PENABLE:
        apb_state_en = pready;

      `STATE_U4_B,
        `STATE_U4_C,
        `STATE_U4_D,
        `STATE_U4_E,
        `STATE_U4_F:
          apb_state_en = 1'b1;

      default:
        apb_state_en = 1'bX;
    endcase 
  end

  always @(posedge rclk or negedge rresetn)
  begin : p_apb_state
    if (~rresetn)
      apb_state <= `STATE_ADN;
    else if (apb_state_en)
      apb_state <= apb_state_nxt;
  end

  assign rsb_outgoing_en = (((apb_state == `STATE_PENABLE) & pready) |
                            ((apb_state == `STATE_DAT3) &
                             rsb_outgoing & rsb_ready_done));
  
  always @(posedge rclk or negedge rresetn)
  begin : p_rsb_state
    if (~rresetn)
      rsb_outgoing <= 1'b0;
    else if (rsb_outgoing_en)
      rsb_outgoing <= ~rsb_outgoing;
  end

  assign apb_done_nxt = ((apb_state == `STATE_PENABLE) & pready);
  assign apb_done_en = ((apb_state == `STATE_PENABLE) | apb_done_i);
  
  always @(posedge rclk or negedge rresetn)
  begin : p_apb_done
    if (~rresetn)
      apb_done_i <= 1'b0;
    else if (apb_done_en)
      apb_done_i <= apb_done_nxt;
  end

  assign apb_done = apb_done_i;


  assign apb_read = rsb_ctl_reg[0];

  assign rsb_adn_en = ((apb_state == `STATE_ADN) &
                       ~rsb_outgoing & rsb_valid_apb);
  assign rsb_mid_en = ((apb_state == `STATE_MID) &
                       ~rsb_outgoing & rsb_valid_apb);
  assign rsb_ctl_en = ((apb_state == `STATE_CTL) &
                       ~rsb_outgoing & rsb_valid_apb);
  assign rsb_err_en = (((apb_state == `STATE_CTL) &
                        ~rsb_outgoing & rsb_valid_apb) |
                       ((apb_state == `STATE_PENABLE) & pready));
  assign rsb_adr1_en = ((apb_state == `STATE_ADR1) &
                        ~rsb_outgoing & rsb_valid_apb);
  assign rsb_adr2_en = ((apb_state == `STATE_ADR2) &
                        ~rsb_outgoing & rsb_valid_apb);
  assign rsb_dat0_en = (((apb_state == `STATE_DAT0) &
                         ~rsb_outgoing & rsb_valid_apb & ~apb_read) | 
                        ((apb_state == `STATE_PENABLE) & pready & apb_read));
  assign rsb_dat1_en = (((apb_state == `STATE_DAT1) &
                         ~rsb_outgoing & rsb_valid_apb & ~apb_read) | 
                        ((apb_state == `STATE_PENABLE) & pready & apb_read));
  assign rsb_dat2_en = (((apb_state == `STATE_DAT2) &
                         ~rsb_outgoing & rsb_valid_apb & ~apb_read) | 
                        ((apb_state == `STATE_PENABLE) & pready & apb_read));
  assign rsb_dat3_en = (((apb_state == `STATE_DAT3) &
                         ~rsb_outgoing & rsb_valid_apb & ~apb_read) | 
                        ((apb_state == `STATE_PENABLE) & pready & apb_read));

  assign rsb_err_reg_nxt = ((apb_state == `STATE_CTL) ? rsb_data_apb[7]
                            : (rsb_err_reg | pslverr));
  assign rsb_dat0_reg_nxt = apb_read ? prdata[7:0]   : rsb_data_apb;
  assign rsb_dat1_reg_nxt = apb_read ? prdata[15:8]  : rsb_data_apb;
  assign rsb_dat2_reg_nxt = apb_read ? prdata[23:16] : rsb_data_apb;
  assign rsb_dat3_reg_nxt = apb_read ? prdata[31:24] : rsb_data_apb;

  always @(posedge rclk)
  begin : p_rsb_adn_reg
    if (rsb_adn_en)
    begin
      rsb_adn_reg <= rsb_data_apb;
      bcast_addr_reg <= bcast_addr;
    end
  end
  
  always @(posedge rclk)
  begin : p_rsb_mid_reg
    if (rsb_mid_en)
      rsb_mid_reg <= rsb_data_apb;
  end
  
  always @(posedge rclk)
  begin : p_rsb_ctl_reg
    if (rsb_ctl_en)
      rsb_ctl_reg <= {rsb_data_apb[6],rsb_data_apb[4:0]};
  end
  
  always @(posedge rclk)
  begin : p_rsb_err_reg
    if (rsb_err_en)
      rsb_err_reg <= rsb_err_reg_nxt;
  end
  
  always @(posedge rclk)
  begin : p_rsb_adr1_reg
    if (rsb_adr1_en)
      rsb_adr1_reg <= rsb_data_apb;
  end
  
  always @(posedge rclk)
  begin : p_rsb_adr2_reg
    if (rsb_adr2_en)
      rsb_adr2_reg <= rsb_data_apb[1:0];
  end
  
  always @(posedge rclk)
  begin : p_rsb_dat0_reg
    if (rsb_dat0_en)
      rsb_dat0_reg <= rsb_dat0_reg_nxt;
  end
  
  always @(posedge rclk)
  begin : p_rsb_dat1_reg
    if (rsb_dat1_en)
      rsb_dat1_reg <= rsb_dat1_reg_nxt;
  end
  
  always @(posedge rclk)
  begin : p_rsb_dat2_reg
    if (rsb_dat2_en)
      rsb_dat2_reg <= rsb_dat2_reg_nxt;
  end
  
  always @(posedge rclk)
  begin : p_rsb_dat3_reg
    if (rsb_dat3_en)
      rsb_dat3_reg <= rsb_dat3_reg_nxt;
  end
  


  assign rsb_ready_apb = ((apb_state != `STATE_PSEL)    &
                          (apb_state != `STATE_PENABLE) &
                          ~rsb_outgoing);

  assign rsb_valid_done = rsb_outgoing;

  always @(rsb_outgoing or apb_state or rsb_adn_reg or rsb_mid_reg or
           rsb_ctl_reg or rsb_adr1_reg or rsb_adr2_reg or
           rsb_dat0_reg or rsb_dat1_reg or rsb_dat2_reg or rsb_dat3_reg or
           rsb_err_reg)
  begin : p_rsb_data_out
    if (~rsb_outgoing)
      rsb_data_done = rsb_adn_reg;
    else
      case (apb_state)
        `STATE_ADN:
          rsb_data_done = rsb_adn_reg;
        `STATE_MID:
          rsb_data_done = rsb_mid_reg;
        `STATE_CTL:
          rsb_data_done = {rsb_err_reg,       
                           rsb_ctl_reg[5],    
                           1'b0,              
                           rsb_ctl_reg[4:0]}; 
        `STATE_ADR1:
          rsb_data_done = rsb_adr1_reg;
        `STATE_ADR2:
          rsb_data_done = {{6{1'b0}}, rsb_adr2_reg};
        `STATE_DAT0:
          rsb_data_done = rsb_dat0_reg;
        `STATE_DAT1:
          rsb_data_done = rsb_dat1_reg;
        `STATE_DAT2:
          rsb_data_done = rsb_dat2_reg;
        `STATE_DAT3:
          rsb_data_done = rsb_dat3_reg;

        `STATE_PSEL,
          `STATE_PENABLE:
            rsb_data_done = rsb_adn_reg;

        `STATE_U4_B,
          `STATE_U4_C,
          `STATE_U4_D,
          `STATE_U4_E,
          `STATE_U4_F:
            rsb_data_done = rsb_adn_reg;

        default:
          rsb_data_done = {8{1'bX}};
      endcase 
  end
  
  
  assign paddr = {{19{1'b0}},bcast_addr_reg,rsb_adr2_reg,rsb_adr1_reg,2'b00};
  assign pwrite = ~apb_read;
  assign pwdata = {rsb_dat3_reg,rsb_dat2_reg,rsb_dat1_reg,rsb_dat0_reg};
  assign psel = ((apb_state == `STATE_PSEL) | (apb_state == `STATE_PENABLE));
  assign penable = (apb_state == `STATE_PENABLE);

  
`ifdef ARM_ASSERT_ON

`include "std_ovl_defines.h"


  wire                    illegal_state;        

  assign illegal_state = (apb_state == `STATE_U4_B) |
                         (apb_state == `STATE_U4_C) |
                         (apb_state == `STATE_U4_D) |
                         (apb_state == `STATE_U4_E) |
                         (apb_state == `STATE_U4_F);

  assert_never #(`OVL_WARNING,
                 `OVL_ASSERT,
                 "RSB (Slave - Format): APB entered illegal state.")
  rsb_illegal_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .test_expr  (illegal_state)
  );


  assert_never_unknown #(`OVL_WARNING,
                         4, 
                         `OVL_ASSERT,
                         "RSB (Slave - Format): APB entered unreachable state.")
  rsb_unreachable_state
  (
    .clk        (rclk),
    .reset_n    (rresetn),
    .qualifier  (1'b1),
    .test_expr  (apb_state)
  );

`endif 

`include "nic400_rsb_undefs_sse710_main.v"


endmodule 


