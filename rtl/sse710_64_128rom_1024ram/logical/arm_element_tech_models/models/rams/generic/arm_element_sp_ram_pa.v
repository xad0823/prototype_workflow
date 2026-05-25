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

module arm_element_sp_ram_pa  #(
  parameter DATA_WIDTH = 8,
  parameter MEMORY_DEPTH = 8,    
  parameter ADDR_WIDTH = 3,  
  parameter LANE_WIDTH = DATA_WIDTH, 
  parameter LANES = (DATA_WIDTH/LANE_WIDTH) 
)(
  input   wire                          CLK, 
  input   wire                          RESETn,

`ifdef ARM_PA_MODE_ENABLE
  input   wire                          VDDCE,
  input   wire                          VDDPE,
  input   wire                          VSSE,
  input   wire                          VSS,
  input   wire                          PGEN,
  input   wire                          RET1N,
  input   wire                          RET2N,
  output  wire                          PRDYN,
`endif

  input   wire  [ADDR_WIDTH-1:0]        A,
  input   wire                          CEN,
  input   wire  [LANES-1:0]             WEN,
  output  wire  [DATA_WIDTH-1:0]        Q, 
  input   wire  [DATA_WIDTH-1:0]        D

);


  reg [DATA_WIDTH-1:0] mem [MEMORY_DEPTH-1:0];
  reg [DATA_WIDTH-1:0]                Q_int;
  integer                i;


  initial 
      for (i = 0; i < MEMORY_DEPTH ; i = i+1)
        mem[i] = {DATA_WIDTH{1'b0}};

  


`ifdef ARM_PA_MODE_ENABLE

  localparam NON_RETENTION       = 3'b000;
  localparam SELECTIVE_PRECHARGE = 3'b010;
  localparam RETENTION_1         = 3'b011;
  localparam RETENTION_2         = 3'b100;
  localparam POWER_DOWN          = 3'b101;
  localparam INVALID_STATE       = 3'b110;

  wire VDDCE_internal;
  wire VDDPE_internal;
  wire VSSE_internal;
  wire VSS_internal;
  wire core_switch;

  assign core_switch = PGEN & RET1N & RET2N;
  

  function check_power;
    input vddce,vddpe,vsse,vss;
    reg power_status;
    begin
      case ({vddce,vddpe,vsse,vss})
          4'b1100: power_status = 1'b1;
          default: power_status = 1'b0;
      endcase
      check_power = power_status;
    end
  endfunction 

  wire corrupt_power;
`ifdef FUNCTIONAL_PASIM
  assign corrupt_power = 1'b0; 
`else
  assign corrupt_power = !check_power(VDDCE_internal,VDDPE_internal,VSSE_internal,VSS_internal);
`endif

  assign VDDCE_internal = VDDCE;
  assign VDDPE_internal = VDDPE;
  assign VSSE_internal  = VSSE; 
  assign VSS_internal   = VSS; 
 
  function [2:0] retentionMode;
    input pg, ret1, ret2;
    reg [2:0] retention_mode;
    begin
      case ({pg,ret1,ret2})
        3'b010: retention_mode = NON_RETENTION;
        3'b011: retention_mode = NON_RETENTION;
        3'b01x: retention_mode = NON_RETENTION;
        3'b000: retention_mode = SELECTIVE_PRECHARGE;
        3'b001: retention_mode = SELECTIVE_PRECHARGE;
        3'b00x: retention_mode = SELECTIVE_PRECHARGE;
        3'b100: retention_mode = RETENTION_1;
        3'b101: retention_mode = RETENTION_1;
        3'b10x: retention_mode = RETENTION_1;
        3'b110: retention_mode = RETENTION_2;
        3'b111: retention_mode = POWER_DOWN;                    
        default: retention_mode = INVALID_STATE;
      endcase
      retentionMode = retention_mode;
    end
  endfunction
 
  wire [2:0] ret_mode;
  assign ret_mode = retentionMode(PGEN,RET1N,RET2N);


`endif



`ifdef ARM_PA_MODE_ENABLE
  assign Q     = (ret_mode == INVALID_STATE | corrupt_power) ? {DATA_WIDTH{1'bx}} : ( (ret_mode == RETENTION_1 | ret_mode == RETENTION_2 | ret_mode == POWER_DOWN) ? {DATA_WIDTH{1'b1}} : Q_int);
  assign PRDYN = (ret_mode == INVALID_STATE | corrupt_power) ? 1'bx               : ( (ret_mode == RETENTION_1 | ret_mode == RETENTION_2 | ret_mode == POWER_DOWN) ? 1'b1               : PGEN);
`else
  assign Q     = Q_int;
`endif

`ifdef ARM_PA_MODE_ENABLE
  wire corrupt_output;
  assign corrupt_output = (ret_mode == RETENTION_1 | ret_mode == RETENTION_2 | ret_mode == POWER_DOWN);
  always @(PGEN or RET1N or RET2N) begin
    if (corrupt_output)
        Q_int  <= {DATA_WIDTH{1'bX}};
  end
`endif

  wire corrupt_content;

`ifdef ARM_PA_MODE_ENABLE
  assign corrupt_content = (ret_mode == POWER_DOWN) | (ret_mode == INVALID_STATE) | (!RESETn);
`else
  assign corrupt_content = !RESETn;
`endif

`ifdef ARM_PA_MODE_ENABLE
  always @(posedge CLK) begin
    if (corrupt_content)
      x_all;
  end
`endif

`ifdef ARM_PA_MODE_ENABLE
  always @(RESETn) begin
    if (~RESETn)
      begin
        x_all;
        Q_int <= {DATA_WIDTH{1'bX}};
      end
  end
`endif

  wire valid_read_write;
  
`ifdef ARM_PA_MODE_ENABLE
  assign valid_read_write = (CEN == 1'b0) && (ret_mode == NON_RETENTION);
`else
  assign valid_read_write = (CEN == 1'b0);
`endif

  always @(posedge CLK) begin
    if (valid_read_write & RESETn)
      begin
        if (!(&WEN)) begin
          write_mem(A,D,WEN);
        end 
        else begin
          Q_int <= mem[A];
        end
      end 
      else begin
        if (~RESETn)
          begin
            Q_int <= {DATA_WIDTH{1'bX}};
          end
      end
  end



`ifdef ARM_PA_MODE_ENABLE
  task x_all;
    integer                  i;
    begin
      for(i=0; i<MEMORY_DEPTH; i=i+1) begin
        mem[i] = {DATA_WIDTH{1'bx}};
      end
    end
  endtask 
`endif

  task write_mem;
    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] wdata;
    input [LANES-1:0]      wen;
    integer                i;
    begin
      if( (^addr) || !(^addr) ) begin
        for(i=0; i<LANES; i=i+1) begin
          case(wen[i])
            1'b1: ; 
            1'b0:    mem[addr][i*LANE_WIDTH+:LANE_WIDTH]
                       = wdata [i*LANE_WIDTH+:LANE_WIDTH];
            
            default: mem[addr][i*LANE_WIDTH+:LANE_WIDTH] = {LANE_WIDTH{1'bX}};
          endcase 
        end
      end
`ifdef ARM_PA_MODE_ENABLE      
      else begin
        x_all;
      end
`endif      
    end
  endtask


`ifdef ARM_MBIST_TEST
  mbist_checker
    #(
      .HEIGHT     (MEMORY_DEPTH),
      .WIDTH      (DATA_WIDTH),
      .LANEWIDTH  (LANE_WIDTH)
    )
    u_mbist_checker
      (
        .clk(CLK),
        .we(!(CEN || (&WEN))),
        .re(!(CEN || !(&WEN))),
        .gwe(~WEN),
        .raddr(A),
        .waddr(A),
        .din(D),
        .dout(Q)
      );

`endif



endmodule
