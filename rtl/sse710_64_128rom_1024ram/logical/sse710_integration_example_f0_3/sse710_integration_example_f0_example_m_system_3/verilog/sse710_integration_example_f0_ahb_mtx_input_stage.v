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


module sse710_integration_example_f0_ahb_mtx_input_stage (

    HCLK,
    HRESETn,

    HSELS,
    HADDRS,
    HAUSERS,
    HTRANSS,
    HWRITES,
    HSIZES,
    HBURSTS,
    HPROTS,
    HMASTERS,
    HMASTLOCKS,
    HREADYS,

    active_ip,
    readyout_ip,
    resp_ip,

    HREADYOUTS,
    HRESPS,

    sel_ip,
    addr_ip,
    auser_ip,
    trans_ip,
    write_ip,
    size_ip,
    burst_ip,
    prot_ip,
    master_ip,
    mastlock_ip,
    held_tran_ip

    );



    input         HCLK;            
    input         HRESETn;         
    input         HSELS;           
    input  [31:0] HADDRS;          
    input  [3:0] HAUSERS;         
    input   [1:0] HTRANSS;         
    input         HWRITES;         
    input   [2:0] HSIZES;          
    input   [2:0] HBURSTS;         
    input   [3:0] HPROTS;          
    input   [3:0] HMASTERS;        
    input         HMASTLOCKS;      
    input         HREADYS;         
    input         active_ip;          
    input         readyout_ip;        
    input   [1:0] resp_ip;            

    output        HREADYOUTS;      
    output  [1:0] HRESPS;          
    output        sel_ip;             
    output [31:0] addr_ip;            
    output [3:0] auser_ip;           
    output  [1:0] trans_ip;           
    output        write_ip;           
    output  [2:0] size_ip;            
    output  [2:0] burst_ip;           
    output  [3:0] prot_ip;            
    output [3:0]  master_ip;          
    output        mastlock_ip;        
    output        held_tran_ip;        



`define TRN_IDLE    2'b00     
`define TRN_BUSY    2'b01     
`define TRN_NONSEQ  2'b10     
`define TRN_SEQ     2'b11     

`define BUR_SINGLE  3'b000    
`define BUR_INCR    3'b001    
`define BUR_WRAP4   3'b010    
`define BUR_INCR4   3'b011    
`define BUR_WRAP8   3'b100    
`define BUR_INCR8   3'b101    
`define BUR_WRAP16  3'b110    
`define BUR_INCR16  3'b111    

`define RSP_OKAY    2'b00      
`define RSP_ERROR   2'b01     
`define RSP_RETRY   2'b10     
`define RSP_SPLIT   2'b11     



    wire        HCLK;            
    wire        HRESETn;         
    wire        HSELS;           
    wire [31:0] HADDRS;          
    wire [3:0] HAUSERS;         
    wire  [1:0] HTRANSS;         
    wire        HWRITES;         
    wire  [2:0] HSIZES;          
    wire  [2:0] HBURSTS;         
    wire  [3:0] HPROTS;          
    wire  [3:0] HMASTERS;        
    wire        HMASTLOCKS;      
    wire        HREADYS;         
    reg         HREADYOUTS;      
    reg   [1:0] HRESPS;          
    reg         sel_ip;             
    reg  [31:0] addr_ip;            
    reg  [3:0] auser_ip;           
    wire  [1:0] trans_ip;           
    reg         write_ip;           
    reg   [2:0] size_ip;            
    wire  [2:0] burst_ip;           
    reg   [3:0] prot_ip;            
    reg   [3:0] master_ip;          
    reg         mastlock_ip;        
    wire        held_tran_ip;        
    wire        active_ip;          
    wire        readyout_ip;        
    wire  [1:0] resp_ip;            



    wire        load_reg;             
    wire        pend_tran;            
    reg         pend_tran_reg;         
    wire        addr_valid;           
    reg         data_valid;           
    reg   [1:0] reg_trans;            
    reg  [31:0] reg_addr;             
    reg  [3:0] reg_auser;
    reg         reg_write;            
    reg   [2:0] reg_size;             
    reg   [2:0] reg_burst;            
    reg   [3:0] reg_prot;             
    reg   [3:0] reg_master;           
    reg         reg_mastlock;         
    reg   [1:0] transb;               
    reg   [1:0] trans_int;            
    reg   [2:0] burst_int;            
    reg   [3:0] offset_addr;          
    reg   [3:0] check_addr;           
    reg         burst_override;       
    wire        burst_override_next;  
    reg         bound;                
    wire        bound_next;           
    wire        bound_en;             




  always @ (negedge HRESETn or posedge HCLK)
    begin : p_holding_reg_seq1
      if (~HRESETn)
        begin
          reg_trans    <= 2'b00;
          reg_addr     <= {32{1'b0}};
          reg_auser    <= {4{1'b0}};
          reg_write    <= 1'b0 ;
          reg_size     <= 3'b000;
          reg_burst    <= 3'b000;
          reg_prot     <= {4{1'b0}};
          reg_master   <= 4'b0000;
          reg_mastlock <= 1'b0 ;
        end
      else
        if (load_reg)
          begin
            reg_trans    <= HTRANSS;
            reg_addr     <= HADDRS;
            reg_auser    <= HAUSERS;
            reg_write    <= HWRITES;
            reg_size     <= HSIZES;
            reg_burst    <= HBURSTS;
            reg_prot     <= HPROTS;
            reg_master   <= HMASTERS;
            reg_mastlock <= HMASTLOCKS;
          end
    end

  assign addr_valid = ( HSELS & HTRANSS[1] );

  assign load_reg = ( addr_valid & HREADYS );

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_data_valid
      if (~HRESETn)
        data_valid <= 1'b0;
      else
       if (HREADYS)
        data_valid  <= addr_valid;
    end


  assign pend_tran = (load_reg & (~active_ip)) ? 1'b1 :
                    (active_ip & readyout_ip) ? 1'b0 : pend_tran_reg;

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_pend_tran_reg
      if (~HRESETn)
        pend_tran_reg <= 1'b0;
      else
        pend_tran_reg <= pend_tran;
    end

  assign  held_tran_ip  = (load_reg | pend_tran_reg);


  always @ ( pend_tran_reg or HSELS or HTRANSS or HADDRS or HWRITES or
             HSIZES or HBURSTS or HPROTS or HMASTERS or HMASTLOCKS or
             HAUSERS or reg_auser or
             reg_addr or reg_write or reg_size or reg_burst or reg_prot or
             reg_master or reg_mastlock
           )
    begin : p_mux_comb
      if (~pend_tran_reg)
        begin
          sel_ip      = HSELS;
          trans_int   = HTRANSS;
          addr_ip     = HADDRS;
          auser_ip    = HAUSERS;
          write_ip    = HWRITES;
          size_ip     = HSIZES;
          burst_int   = HBURSTS;
          prot_ip     = HPROTS;
          master_ip   = HMASTERS;
          mastlock_ip = HMASTLOCKS;
        end
      else
        begin
          sel_ip      = 1'b1;
          trans_int   = `TRN_NONSEQ;
          addr_ip     = reg_addr;
          auser_ip    = reg_auser;
          write_ip    = reg_write;
          size_ip     = reg_size;
          burst_int   = reg_burst;
          prot_ip     = reg_prot;
          master_ip   = reg_master;
          mastlock_ip = reg_mastlock;
        end
    end


  always @ (pend_tran_reg or HTRANSS or reg_trans)
    begin : p_transb_comb
      if (~pend_tran_reg)
        transb = HTRANSS;
      else
        transb = reg_trans;
    end 


  assign trans_ip = (burst_override & bound) ? {trans_int[1], 1'b0}
               : trans_int;

  assign burst_ip = (burst_override & (transb != `TRN_NONSEQ)) ? `BUR_INCR
               : burst_int;


  always @ (data_valid or pend_tran_reg or readyout_ip or resp_ip)
    begin : p_ready_comb
      if (~data_valid)
        begin
          HREADYOUTS = 1'b1;
          HRESPS     = `RSP_OKAY;
        end
      else if (pend_tran_reg)
        begin
          HREADYOUTS = 1'b0;
          HRESPS     = `RSP_OKAY;
        end
      else
        begin
          HREADYOUTS = readyout_ip;
          HRESPS     = resp_ip;
        end
    end 


  assign burst_override_next  = ( (HTRANSS == `TRN_NONSEQ) |
                                (HTRANSS == `TRN_IDLE) ) ? 1'b0
                              : ( (HTRANSS ==`TRN_SEQ) &
                                   load_reg &
                                   (~active_ip) ) ? 1'b1
                                  : burst_override;

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_burst_overrideseq
      if (~HRESETn)
        burst_override <= 1'b0;
      else
        if (HREADYS)
          burst_override <= burst_override_next;
    end 

  always @ (HADDRS or HSIZES)
    begin : p_offset_addr_comb
      case (HSIZES)
        3'b000 : offset_addr = HADDRS[3:0];
        3'b001 : offset_addr = HADDRS[4:1];
        3'b010 : offset_addr = HADDRS[5:2];
        3'b011 : offset_addr = HADDRS[6:3];

        3'b100, 3'b101, 3'b110, 3'b111 :
          offset_addr = HADDRS[3:0];      

        default : offset_addr = 4'bxxxx;
      endcase
    end

  always @ (offset_addr or HBURSTS)
    begin : p_check_addr_comb
      case (HBURSTS)
        `BUR_WRAP4 : begin
          check_addr[1:0] = offset_addr[1:0];
          check_addr[3:2] = 2'b11;
        end

        `BUR_WRAP8 : begin
          check_addr[2:0] = offset_addr[2:0];
          check_addr[3]   = 1'b1;
        end

        `BUR_WRAP16 :
          check_addr[3:0] = offset_addr[3:0];

        `BUR_SINGLE, `BUR_INCR, `BUR_INCR4, `BUR_INCR8, `BUR_INCR16 :
          check_addr[3:0] = 4'b0000;

        default : check_addr[3:0] = 4'bxxxx;
      endcase
    end

  assign bound_next = ( check_addr == 4'b1111 );

  assign bound_en = ( HTRANSS[1] & HREADYS );

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_bound_seq
      if (~HRESETn)
        bound <= 1'b0;
      else
        if (bound_en)
          bound <= bound_next;
    end


endmodule

