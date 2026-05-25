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

module daacg_f0 (
    
    input  wire           pclk,
    
    input  wire           presetn,
        
    input  wire [31:0]    paddr_s,
    input  wire [31:0]    pwdata_s,
    input  wire           pwrite_s,
    input  wire [3:0]     pstrb_s,
    input  wire [2:0]     pprot_s,
    input  wire           psel_s,
    input  wire           penable_s,
    output wire [31:0]    prdata_s,
    output wire           pready_s,    
    output wire           pslverr_s,    
    
    output wire [31:0]    paddr_m,
    output wire [31:0]    pwdata_m,
    output wire           pwrite_m,
    output wire [3:0]     pstrb_m,
    output wire [2:0]     pprot_m,
    output wire           psel_m,
    output wire           penable_m,
    input  wire [31:0]    prdata_m,
    input  wire           pready_m,    
    input  wire           pslverr_m,    
    
    input  wire           dbgen
  );


  localparam CLOSED      = 2'b00;
  localparam OPENED      = 2'b01;
  localparam APB_WAIT    = 2'b10;
  
  
  reg  [1:0]       state;
  reg  [1:0]       nxt_state;
  reg              state_en;
  
  wire        closed_to_opened;
  wire        opened_to_closed;
  wire        closed_to_apb_wait;
  wire        change_en;
  
  reg         pready_s_int;
  reg  [31:0] prdata_s_int;
  reg         pslverr_s_int;
  
  reg  [2:0]  pprot_m_int;
  reg  [3:0]  pstrb_m_int;
  reg         pwrite_m_int;  
  reg  [31:0] pwdata_m_int;
  reg  [31:0] paddr_m_int;
  reg         psel_m_int;
  reg         penable_m_int;
  
  reg         pslverr_closed_r;
  wire        nxt_pslverr_closed;
  wire        pslverr_closed_en;

  reg first_cycle_n;


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      first_cycle_n <= 1'b0;  
    end
    else
    begin
      first_cycle_n <= 1'b1;  
    end
  end


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      state <= CLOSED;  
    end
    else if (state_en)
    begin
      state <= nxt_state;
    end
  end
  
  always @(*)
  begin
    case(state)
      CLOSED:
      begin
        nxt_state = closed_to_opened ? OPENED : APB_WAIT;
        state_en  = closed_to_opened | closed_to_apb_wait;
      end
      OPENED:
      begin
        nxt_state = CLOSED;
        state_en  = opened_to_closed;
      end
      APB_WAIT:
      begin
        nxt_state = OPENED;
        state_en  = 1'b1;
      end      
      default:
      begin
        nxt_state = 2'bxx;
        state_en  = 1'bx;
      end
    endcase
  end  
  
  assign change_en        = ~psel_s | (psel_s & penable_s & pready_s_int);
  
  assign closed_to_opened = dbgen & change_en;
  
  assign opened_to_closed = ~dbgen & change_en;
  
  assign closed_to_apb_wait = dbgen & psel_s & ~first_cycle_n;


  always@(posedge pclk or negedge presetn)
  begin
    if(!presetn)
    begin
      pslverr_closed_r <= 1'b0;  
    end
    else if (pslverr_closed_en)
    begin
      pslverr_closed_r <= nxt_pslverr_closed;  
    end
  end
  
  assign nxt_pslverr_closed = psel_s & ~penable_s;
  
  assign pslverr_closed_en  = psel_s & (state == CLOSED);
  
  
  always @(*)
  begin
    case(state)
      CLOSED:
      begin
        prdata_s_int  = 32'h0000_0000;
        pready_s_int  = 1'b1;
        pslverr_s_int = pslverr_closed_r;
      end
      OPENED:
      begin
        prdata_s_int  = prdata_m;
        pready_s_int  = pready_m;
        pslverr_s_int = pslverr_m;
      end
      APB_WAIT:
      begin
        prdata_s_int  = prdata_m;
        pready_s_int  = 1'b0;
        pslverr_s_int = pslverr_m;
      end      
      default:
      begin
        prdata_s_int  = 32'hxxxx_xxxx;
        pready_s_int  = 1'bx;
        pslverr_s_int  = 1'bx;
      end
    endcase
  end
  

  always @(*)
  begin
    case(state)
      CLOSED:
      begin
        pprot_m_int   = 3'b000;
        pstrb_m_int   = 4'h0;
        pwrite_m_int  = 1'b0;
        pwdata_m_int  = 32'h0000_0000;
        paddr_m_int   = 32'h0000_0000;
        psel_m_int    = 1'b0;
        penable_m_int = 1'b0;
      end
      OPENED:
      begin
        pprot_m_int   = pprot_s;
        pstrb_m_int   = pstrb_s;
        pwrite_m_int  = pwrite_s;
        pwdata_m_int  = pwdata_s;
        paddr_m_int   = paddr_s;
        psel_m_int    = psel_s;
        penable_m_int = penable_s;
      end
      APB_WAIT:
      begin
        pprot_m_int   = pprot_s;
        pstrb_m_int   = pstrb_s;
        pwrite_m_int  = pwrite_s;
        pwdata_m_int  = pwdata_s;
        paddr_m_int   = paddr_s;
        psel_m_int    = 1'b1;
        penable_m_int = 1'b0;
       end      
      default:
      begin
        pprot_m_int   = 3'bxxx;
        pstrb_m_int   = 4'hx;
        pwrite_m_int  = 1'bx;
        pwdata_m_int  = 32'hxxxx_xxxx;
        paddr_m_int   = 32'hxxxx_xxxx;
        psel_m_int    = 1'bx;
        penable_m_int = 1'bx;
      end
    endcase
  end
  

  assign pready_s   = pready_s_int;
  assign prdata_s   = prdata_s_int;
  assign pslverr_s  = pslverr_s_int;
  
  assign pprot_m    = pprot_m_int;
  assign pstrb_m    = pstrb_m_int;
  assign pwrite_m   = pwrite_m_int;
  assign pwdata_m   = pwdata_m_int;
  assign paddr_m    = paddr_m_int;
  assign psel_m     = psel_m_int;
  assign penable_m  = penable_m_int; 
  
endmodule
