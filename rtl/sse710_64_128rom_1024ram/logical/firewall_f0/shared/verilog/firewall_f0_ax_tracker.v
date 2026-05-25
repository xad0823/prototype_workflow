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

module firewall_f0_ax_tracker #(
    parameter PAYLOAD_WIDTH      = 1,
    parameter NUM_OUTSTAND       = 16,
    parameter FC_ME_LVL          = 0,
    parameter ID_WIDTH           = 1
) (
    input  wire                       clk,
    input  wire                       reset_n,

    input  wire                       load,      
    input  wire                       unload,    

    input  wire [ID_WIDTH-1:0]        trk_id_wr_i,
    input  wire [PAYLOAD_WIDTH-1:0]   trk_data_in_i,

    input  wire                       trk_rd_i,    
    input  wire [ID_WIDTH-1:0]        trk_id_rd_i,
    output wire [PAYLOAD_WIDTH-1:0]   trk_data_out_o,
    output wire                       trk_data_vld_o,

    output wire                       trk_full,
    output wire                       trk_empty,
    output wire                       trk_al_empty,
    output wire                       busy
);

`include "firewall_f0_log2.vh"

localparam OUTST_CTR_WIDTH = firewall_f0_log2(NUM_OUTSTAND);

generate
  if (NUM_OUTSTAND == 1) begin : SINGLE_OUTST
    reg outst_counter; 

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        outst_counter <= 1'b0;
      end
      else begin
        if (load && ~unload) begin
          outst_counter <= 1'b1;
        end
        else if (unload && ~load) begin
          outst_counter <= 1'b0;
        end
      end
    end
    assign busy = (outst_counter == 1'b1);
    assign trk_empty = (outst_counter == 0);
    assign trk_al_empty = 1'b0; 
    assign trk_full = (outst_counter == 1'b1);

  end else begin : MULT_OUTST
    reg [OUTST_CTR_WIDTH:0] outst_counter; 

    always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
        outst_counter <= {(OUTST_CTR_WIDTH+1){1'b0}};
      end
      else begin
        if (load && ~unload) begin
          outst_counter <= outst_counter + {{OUTST_CTR_WIDTH{1'b0}}, 1'b1};
        end
        else if (unload && ~load) begin
          outst_counter <= outst_counter - {{OUTST_CTR_WIDTH{1'b0}}, 1'b1};
        end
      end
    end

    assign busy = (outst_counter > 0);
    assign trk_al_empty = (outst_counter == 1);
    assign trk_empty = (outst_counter == 0);
    assign trk_full = (outst_counter == NUM_OUTSTAND);

  end
endgenerate

  generate
    if(FC_ME_LVL==0) begin : NO_MON
      assign trk_data_out_o = {PAYLOAD_WIDTH{1'b0}}; 
      assign trk_data_vld_o = 1'b0;

    end else begin : MON

      firewall_f0_mon_edr_trk #(
        .PAYLOAD_WIDTH (PAYLOAD_WIDTH),
        .NUM_OUTSTAND (NUM_OUTSTAND),
        .ID_WIDTH (ID_WIDTH)
      ) u_trk
      (
        .clk            (clk           ),
        .reset_n        (reset_n       ),
        .trk_wr_i       (load      ),
        .trk_id_wr_i    (trk_id_wr_i   ),
        .trk_data_in_i  (trk_data_in_i ),
        .trk_rd_i       (trk_rd_i      ),
        .trk_id_rd_i    (trk_id_rd_i   ),
        .trk_data_out_o (trk_data_out_o),
        .trk_data_vld_o (trk_data_vld_o)
      );

    end
  endgenerate
endmodule
