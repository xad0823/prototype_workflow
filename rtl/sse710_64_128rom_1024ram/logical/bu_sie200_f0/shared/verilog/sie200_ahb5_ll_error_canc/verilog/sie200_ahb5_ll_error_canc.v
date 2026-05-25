// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Thu Feb 2 16:33:29 2017 +0100
//
//      Revision            : 1cad404
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//
//------------------------------------------------------------------------------

module sie200_ahb5_ll_error_canc
  (

  input  wire        hclk,
  input  wire        hclk_en,
  input  wire        hresetn,

  input  wire  [1:0] htrans_s,

  output reg         hreadyout_s,
  output reg         hresp_s,

  output reg   [1:0] htrans_m,

  input  wire        hready_m,
  input  wire        hresp_m);



  localparam TRN_IDLE         = 2'b00;
  localparam TRN_BUSY         = 2'b01;
  localparam TRN_NONSEQ       = 2'b10;
  localparam TRN_SEQ          = 2'b11;

  localparam RSP_OKAY         = 1'b0;
  localparam RESP_ERR         = 1'b1;

  localparam ST_CONTROL_IDLE  = 1'b0;
  localparam ST_CONTROL_ERR   = 1'b1;

  localparam ST_GEN_IDLE      = 2'b01;
  localparam ST_GEN_ERR1      = 2'b10;
  localparam ST_GEN_ERR2      = 2'b11;


  reg            next_control_state;
  reg            control_state;

  reg    [1:0]   next_gen_state;
  reg    [1:0]   gen_state;

  wire           burst_transfer;

  wire           gen_hready_outs;
  wire           gen_hresps;





  assign burst_transfer = ((htrans_s ==TRN_BUSY) | (htrans_s ==TRN_SEQ));


  always @ (hresp_m or burst_transfer or control_state or gen_hready_outs)
    begin : p_control_state_comb
      case (control_state)
        ST_CONTROL_IDLE : begin
              next_control_state = ((hresp_m == RESP_ERR) & burst_transfer)?
                                   ST_CONTROL_ERR: ST_CONTROL_IDLE;
          end
        ST_CONTROL_ERR : begin
             next_control_state =   ((burst_transfer == 1'b0) & gen_hready_outs) ?
                                   ST_CONTROL_IDLE : ST_CONTROL_ERR;
          end
        default:
          next_control_state = 1'bx;

      endcase
    end


  always @ (hresp_m or htrans_s or gen_state or control_state)
    begin : p_gen_state_comb
      case (gen_state)

        ST_GEN_IDLE : begin
              next_gen_state = (hresp_m == RESP_ERR) ?
                                ST_GEN_ERR2 :
                                ((htrans_s == TRN_SEQ)  & (control_state == ST_CONTROL_ERR))?
                                ST_GEN_ERR1 :
                                ST_GEN_IDLE;
          end
        ST_GEN_ERR1 :
              next_gen_state = ST_GEN_ERR2;

        ST_GEN_ERR2 : begin
              next_gen_state =  (htrans_s == TRN_SEQ) ?
                                ST_GEN_ERR1:
                                ST_GEN_IDLE;
            end

        default:
          next_gen_state = 2'bxx;

      endcase
    end

  always @ (posedge hclk or negedge hresetn)
  begin : p_state_seq
    if  (!hresetn) begin
      control_state <= ST_CONTROL_IDLE;
      gen_state     <= ST_GEN_IDLE;
    end
    else if (hclk_en) begin
      control_state <= next_control_state;
      gen_state     <= next_gen_state;
    end
  end




  assign gen_hready_outs = ((gen_state == ST_GEN_IDLE) |
                          (gen_state == ST_GEN_ERR2));


  assign gen_hresps = ((gen_state == ST_GEN_ERR1) |
                      (gen_state == ST_GEN_ERR2)) ? RESP_ERR :
                      RSP_OKAY;


  always @ (control_state or hready_m or hresp_m or gen_hready_outs or gen_hresps)
    begin : p_ahb1_output_comb
      if  (control_state == ST_CONTROL_IDLE)
        begin
          hreadyout_s = hready_m;
          hresp_s     = hresp_m;
        end
      else
        begin
          hreadyout_s = gen_hready_outs;
          hresp_s     = gen_hresps;
        end
    end


  always @ (htrans_s or control_state)
    begin : p_ahb2_output_comb
      if  (control_state ==ST_CONTROL_IDLE)
        htrans_m = htrans_s;
      else
        if (htrans_s == TRN_NONSEQ)
          htrans_m = htrans_s;
        else
          htrans_m = TRN_IDLE;
    end


endmodule

