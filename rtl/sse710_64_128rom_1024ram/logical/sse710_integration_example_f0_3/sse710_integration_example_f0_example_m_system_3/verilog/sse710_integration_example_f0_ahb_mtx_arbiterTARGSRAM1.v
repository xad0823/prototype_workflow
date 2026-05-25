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


`timescale 1ns/1ps


module sse710_integration_example_f0_ahb_mtx_arbiterTARGSRAM1 (

    HCLK ,
    HRESETn,

    req_port1,
    req_port2,
    req_port3,

    HREADYM,
    HSELM,
    HTRANSM,
    HBURSTM,
    HMASTLOCKM,

    addr_in_port,
    no_port

    );



    input        HCLK;         
    input        HRESETn;      
    input        req_port1;     
    input        req_port2;     
    input        req_port3;     
    input        HREADYM;      
    input        HSELM;        
    input  [1:0] HTRANSM;      
    input  [2:0] HBURSTM;      
    input        HMASTLOCKM;   
    output [1:0] addr_in_port;   
    output       no_port;      


`define TRN_IDLE   2'b00       
`define TRN_BUSY   2'b01       
`define TRN_NONSEQ 2'b10       
`define TRN_SEQ    2'b11       

`define BUR_SINGLE 3'b000       
`define BUR_INCR   3'b001       
`define BUR_WRAP4  3'b010       
`define BUR_INCR4  3'b011       
`define BUR_WRAP8  3'b100       
`define BUR_INCR8  3'b101       
`define BUR_WRAP16 3'b110       
`define BUR_INCR16 3'b111       


    wire       HCLK;           
    wire       HRESETn;        
    wire       req_port1;       
    wire       req_port2;       
    wire       req_port3;       
    wire       HREADYM;        
    wire       HSELM;          
    wire [1:0] HTRANSM;        
    wire [2:0] HBURSTM;        
    wire       HMASTLOCKM;     
    wire [1:0] addr_in_port;     
    wire       no_port;        


    reg  [1:0] next_addr_in_port; 
    reg                 next_no_port;      
    reg  [1:0] i_addr_in_port;    
    reg                 i_no_port;         

    reg  [3:0] next_burst_remain;    
    reg  [3:0] reg_burst_remain;     
    reg        next_burst_hold;      
    reg        reg_burst_hold;       

    reg  [1:0] reg_early_term_count; 
    wire [1:0] next_early_term_count; 




  always @ (HTRANSM or HSELM or HBURSTM or reg_burst_remain or reg_burst_hold or reg_early_term_count)
    begin : p_next_burst_remain_comb
      if (~HSELM)
        begin
          next_burst_remain = 4'b0000;
          next_burst_hold  = 1'b0;
        end

      else
        case (HTRANSM)

          `TRN_NONSEQ : begin
            case (HBURSTM)
              `BUR_INCR16, `BUR_WRAP16 : begin
                next_burst_remain = 4'd15;
                next_burst_hold = 1'b1;
              end 

              `BUR_INCR8, `BUR_WRAP8 : begin
                next_burst_remain = 4'd7;
                next_burst_hold = 1'b1;
              end 

              `BUR_INCR4, `BUR_WRAP4 : begin
                next_burst_remain = 4'd3;
                next_burst_hold = 1'b1;
              end 

              `BUR_INCR : begin
                    next_burst_remain = 4'd3;
                    next_burst_hold = 1'b1;
              end 

              `BUR_SINGLE : begin
                next_burst_remain = 4'd0;
                next_burst_hold  = 1'b0;
              end 

              default : begin
                next_burst_remain = 4'bxxxx;
                next_burst_hold = 1'bx;
              end 

            endcase 

            if (reg_early_term_count == 2'b10)
            begin
               next_burst_hold = 1'b0;
               next_burst_remain = 4'd0;
            end

          end 

          `TRN_SEQ : begin
            if (reg_burst_remain == 4'd1) 
              begin
                next_burst_hold = 1'b0;
                next_burst_remain = 4'd0;
              end
            else
              begin
                next_burst_hold = reg_burst_hold;
                if (reg_burst_remain != 4'd0)
                  next_burst_remain = reg_burst_remain - 4'b1;
                else
                  next_burst_remain = 4'd0;
              end
          end 

          `TRN_BUSY : begin
            next_burst_remain = reg_burst_remain;
            next_burst_hold = reg_burst_hold;
          end 

          `TRN_IDLE : begin
            next_burst_remain = 4'd0;
            next_burst_hold = 1'b0;
          end 

          default : begin
            next_burst_remain = 4'bxxxx;
            next_burst_hold = 1'bx;
          end 

        endcase 
    end 



  assign next_early_term_count = (!next_burst_hold) ? 2'b00 :
                               (reg_burst_hold & (HTRANSM == `TRN_NONSEQ)) ?
                                reg_early_term_count + 2'b1 :
                                reg_early_term_count;

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_burst_seq
      if (~HRESETn)
        begin
          reg_burst_remain     <= 4'b0000;
          reg_burst_hold       <= 1'b0;
          reg_early_term_count <= 2'b00;
        end 
      else
        if (HREADYM)
          begin
            reg_burst_remain     <= next_burst_remain;
            reg_burst_hold       <= next_burst_hold;
            reg_early_term_count <= next_early_term_count;
          end
    end 



  always @ (
             req_port1 or
             req_port2 or
             req_port3 or
             HMASTLOCKM or next_burst_hold or HSELM or i_no_port or i_addr_in_port
           )
    begin : p_sel_port_comb
      next_no_port = 1'b0;
      next_addr_in_port = i_addr_in_port;

      if ( HMASTLOCKM | next_burst_hold )
        next_addr_in_port = i_addr_in_port;
      else if (i_no_port)
        begin
          if (req_port1)
            next_addr_in_port = 2'b01;
          else if (req_port2)
            next_addr_in_port = 2'b10;
          else if (req_port3)
            next_addr_in_port = 2'b11;
          else
            next_no_port = 1'b1;
        end
      else
        case (i_addr_in_port)
          2'b01 : begin
            if (req_port2)
              next_addr_in_port = 2'b10;
            else if (req_port3)
              next_addr_in_port = 2'b11;
            else if (HSELM)
              next_addr_in_port = 2'b01;
            else
              next_no_port = 1'b1;
          end

          2'b10 : begin
            if (req_port3)
              next_addr_in_port = 2'b11;
            else if (req_port1)
              next_addr_in_port = 2'b01;
            else if (HSELM)
              next_addr_in_port = 2'b10;
            else
              next_no_port = 1'b1;
          end

          2'b11 : begin
            if (req_port1)
              next_addr_in_port = 2'b01;
            else if (req_port2)
              next_addr_in_port = 2'b10;
            else if (HSELM)
              next_addr_in_port = 2'b11;
            else
              next_no_port = 1'b1;
          end

          default : begin
            next_addr_in_port = {2{1'bx}};
            next_no_port = 1'bx;
          end
      endcase
    end

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_addr_in_port_reg
      if (~HRESETn)
        begin
          i_no_port      <= 1'b1;
          i_addr_in_port <= {2{1'b0}};
        end
      else
        if (HREADYM)
          begin
            i_no_port      <= next_no_port;
            i_addr_in_port <= next_addr_in_port;
          end
    end

  assign addr_in_port = i_addr_in_port;
  assign no_port      = i_no_port;


endmodule

