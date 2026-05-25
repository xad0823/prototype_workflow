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

module firewall_f0_mon_edr_trk #(
    parameter PAYLOAD_WIDTH      = 8,
    parameter NUM_OUTSTAND       = 16,
    parameter ID_WIDTH           = 4

) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       trk_wr_i,
    input  wire [ID_WIDTH-1:0]        trk_id_wr_i,
    input  wire [PAYLOAD_WIDTH-1:0]   trk_data_in_i,

    input  wire                       trk_rd_i,
    input  wire [ID_WIDTH-1:0]        trk_id_rd_i,
    output reg [PAYLOAD_WIDTH-1:0]    trk_data_out_o,
    output reg                        trk_data_vld_o
);

`include "firewall_f0_log2.vh"
localparam TRK_FILE_WIDTH = PAYLOAD_WIDTH + ID_WIDTH ;
localparam OUTST_PTR_WIDTH = firewall_f0_log2(NUM_OUTSTAND);

reg [TRK_FILE_WIDTH-1:0] trk_file[NUM_OUTSTAND-1:0];
reg [OUTST_PTR_WIDTH-1:0] wr_ptr;
reg match_found;
integer match_idx;


always @*
begin: match
  integer i;
  match_found = 1'b0;
  match_idx = 0;

  for (i=NUM_OUTSTAND-1; i>=0; i=i-1) begin  
    if ((trk_id_rd_i == trk_file[i][TRK_FILE_WIDTH-PAYLOAD_WIDTH-1 -: ID_WIDTH]) && trk_rd_i) begin 
      match_found = 1'b1;
      match_idx = i;
    end
  end

  if (match_found) begin
    trk_data_out_o = trk_file[match_idx[OUTST_PTR_WIDTH-1:0]][TRK_FILE_WIDTH-1 -: PAYLOAD_WIDTH]; 
    trk_data_vld_o = 1'b1;
  end else begin  
    trk_data_vld_o = 1'b0;  
    trk_data_out_o = {PAYLOAD_WIDTH{1'b0}};
  end
end

generate
  if (OUTST_PTR_WIDTH == 1) begin: OUTSTPTR_1
    always @(posedge clk or negedge reset_n)
    begin: data
    integer i;

      if (!reset_n) begin
        wr_ptr <= 1'b0; 
        for (i=0; i<NUM_OUTSTAND; i=i+1) begin
          trk_file[i] <= {TRK_FILE_WIDTH{1'b0}};
        end
      end else begin
        if (trk_wr_i && !trk_rd_i) begin  
          wr_ptr <= wr_ptr + 1'b1;        
          trk_file[wr_ptr] <= {trk_data_in_i, trk_id_wr_i};

        end else if (trk_rd_i && !trk_wr_i) begin  
          wr_ptr <= wr_ptr - 1'b1;

          for (i=0; i<NUM_OUTSTAND; i=i+1) begin
            if (match_found && (i<NUM_OUTSTAND-1) && i>= match_idx) begin
              trk_file[i] <= trk_file[i+1];
            end
          end
        end else if (trk_rd_i && trk_wr_i) begin 
          for (i=0; i<NUM_OUTSTAND-1; i=i+1) begin
            if (match_found && i>= match_idx && i != (wr_ptr-1) ) begin
              trk_file[i] <= trk_file[i+1];
            end else if (match_found && i>= match_idx && i == (wr_ptr-1)) begin
              trk_file[i] <= {trk_data_in_i, trk_id_wr_i};  
            end
          end
        end
      end
    end
  end else begin: OUTSTPTR_GRT_1
    always @(posedge clk or negedge reset_n)
    begin: data
    integer i;

      if (!reset_n) begin
        wr_ptr <= {OUTST_PTR_WIDTH{1'b0}}; 
        for (i=0; i<NUM_OUTSTAND; i=i+1) begin
          trk_file[i] <= {TRK_FILE_WIDTH{1'b0}};
        end
      end else begin
        if (trk_wr_i && !trk_rd_i) begin  
          wr_ptr <= wr_ptr + {{(OUTST_PTR_WIDTH-1){1'b0}}, 1'b1};        
          trk_file[wr_ptr] <= {trk_data_in_i, trk_id_wr_i};

        end else if (trk_rd_i && !trk_wr_i) begin  
          wr_ptr <= wr_ptr - {{(OUTST_PTR_WIDTH-1){1'b0}}, 1'b1};

          for (i=0; i<NUM_OUTSTAND; i=i+1) begin
            if (match_found && (i<NUM_OUTSTAND-1) && i>= match_idx) begin
              trk_file[i] <= trk_file[i+1];
            end
          end
        end else if (trk_rd_i && trk_wr_i) begin 
          for (i=0; i<NUM_OUTSTAND-1; i=i+1) begin
            if (match_found && i>= match_idx && i != (wr_ptr-1) ) begin
              trk_file[i] <= trk_file[i+1];
            end else if (match_found && i>= match_idx && i == (wr_ptr-1)) begin
              trk_file[i] <= {trk_data_in_i, trk_id_wr_i};  
            end
          end
        end
      end
    end
  end
endgenerate
endmodule
