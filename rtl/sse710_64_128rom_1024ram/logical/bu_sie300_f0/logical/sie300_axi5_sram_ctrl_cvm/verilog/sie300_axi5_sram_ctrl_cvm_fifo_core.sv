//----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
// (C) COPYRIGHT 2012-2015,2019 Arm Limited or its affiliates.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Aug 2 16:09:54 2019 +0100
//
//      Revision            : 15b1fab4
//
//      Release Information : CoreLink SIE-300 Generic Global Bundle r1p2-00rel0
//
//----------------------------------------------------------------------------

module sie300_axi5_sram_ctrl_cvm_fifo_core #(
  parameter FIFO_WIDTH      = 10,

  parameter FIFO_DEPTH      = 6,

  parameter BINARY_POINTER  = 1,

  parameter PEEK_LOGIC      = 0
)
(
  input  wire logic                                 clk,
  input  wire logic                                 resetn,

  input  wire logic                                 push_i,
  input  wire logic [FIFO_WIDTH-1:0]                push_data_i,

  input  wire logic                                 pop_i,
  output      logic [FIFO_WIDTH-1:0]                pop_data_o,

  output      logic                                 empty_o,
  output      logic                                 full_o,

  output      logic [FIFO_DEPTH-1:0]                peek_data_valid_o,
  output      logic [(FIFO_WIDTH*FIFO_DEPTH)-1:0]   peek_data_o
);

  localparam PTR_WIDTH  = FIFO_DEPTH == 1 ? (BINARY_POINTER ? 1 : 2)
                                          : (BINARY_POINTER ? $clog2(FIFO_DEPTH) : FIFO_DEPTH);
  localparam FLAG_MAX   = FIFO_DEPTH == 1 ? 1 : FIFO_DEPTH-1;

  genvar g;
  genvar j;

  logic [(FIFO_DEPTH*FIFO_WIDTH)-1:0]   fifo;
  typedef logic [PTR_WIDTH-1:0] flag_t;

  flag_t                                wflag;
  flag_t                                rflag;
  flag_t                                wflag_shift;
  flag_t                                rflag_shift;

  logic                                 push_last;
  logic                                 pop_last;
  logic                                 empty_nxt;
  logic                                 full_nxt;

  logic [FIFO_DEPTH-1:0]                mux_sel;
  logic [FIFO_WIDTH-1:0]                pop_data_mux;

  logic [FIFO_DEPTH-1:0]                in_use;



  generate
    if (BINARY_POINTER == 1)
    begin : g_bin_ptr
      assign wflag_shift = (wflag >= flag_t'(FLAG_MAX) ) ? flag_t'(0) : wflag + flag_t'(1);
      assign rflag_shift = (rflag >= flag_t'(FLAG_MAX) ) ? flag_t'(0) : rflag + flag_t'(1);
    end
    else
    begin : g_oh_ptr
      assign wflag_shift = { wflag[FLAG_MAX-1:0], wflag[FLAG_MAX] };
      assign rflag_shift = { rflag[FLAG_MAX-1:0], rflag[FLAG_MAX] };
    end
  endgenerate

  always_ff @(posedge clk or negedge resetn)
  begin : p_wflag
    if (!resetn)
      wflag <= flag_t'(1);
    else
      wflag <= push_i ? wflag_shift : wflag;
  end

  always_ff @(posedge clk or negedge resetn)
  begin : p_rflag
    if (!resetn)
      rflag <= flag_t'(1);
    else
      rflag <= pop_i  ? rflag_shift : rflag;
  end



  assign pop_last   = (FIFO_DEPTH == 1) || (rflag_shift == wflag);

  assign empty_nxt  = (empty_o & ~(push_i & ~pop_i))
                    | (pop_i & ~push_i & pop_last);

  always_ff @(posedge clk or negedge resetn)
  begin : p_empty
    if (!resetn)
      empty_o <= 1'b1;
    else
      empty_o <= empty_nxt;
  end


  assign push_last = (FIFO_DEPTH == 1) || (wflag_shift == rflag);
  assign full_nxt  = (full_o & (~pop_i | push_i))
                   | (push_i & ~pop_i & push_last);

  always_ff @(posedge clk or negedge resetn)
  begin : p_full
    if (!resetn)
      full_o <= 1'b0;
    else
      full_o <= full_nxt;
  end




  generate
    for (j=0; j < FIFO_DEPTH; j=j+1)
    begin : g_fifo

      logic fifo_up_en;

      if (FIFO_DEPTH == 1)
      begin : g_one_deep_up

        assign fifo_up_en = push_i;

      end
      else if (BINARY_POINTER == 1)
      begin : g_bin_up

        assign fifo_up_en = (wflag == flag_t'(j)) & push_i;

      end
      else
      begin : g_oh_up

        assign fifo_up_en = wflag[j] & push_i;

      end

      always_ff @(posedge clk or negedge resetn)
      begin : p_fifo_push
        if (!resetn)
          fifo[(j*FIFO_WIDTH)+:FIFO_WIDTH] <= 'b0;
        else if (fifo_up_en)
          fifo[(j*FIFO_WIDTH)+:FIFO_WIDTH] <= push_data_i;
      end

      if (PEEK_LOGIC == 1)
      begin : g_peek_in_use

        logic in_use_r;
        logic in_use_nxt;
        logic pop_entry;
        logic push_entry;

        if (FIFO_DEPTH == 1)
        begin : g_one_deep_peek

          assign pop_entry  = pop_i;
          assign push_entry = push_i;

        end
        else if (BINARY_POINTER == 1)
        begin : g_binary_peek

          assign pop_entry  = pop_i  & (rflag == flag_t'(j));
          assign push_entry = push_i & (wflag == flag_t'(j));

        end
        else
        begin : g_oh_peek

          assign pop_entry  = pop_i  & rflag[j];
          assign push_entry = push_i & wflag[j];

        end

        assign in_use_nxt = in_use_r ? (~pop_entry | push_entry) : push_entry;

        always_ff @(posedge clk or negedge resetn)
        begin : p_fifo_in_use
          if (!resetn)
            in_use_r <= 1'b0;
          else if (in_use_r != in_use_nxt)
            in_use_r <= in_use_nxt;
        end

        assign in_use[j] = in_use_r;

      end
      else
      begin : g_no_peek_in_use

        assign in_use[j] = 1'b0;

      end

    end

  endgenerate


  generate
    if (FIFO_DEPTH == 1)
    begin: g_one_deep_mux

      assign mux_sel = 1'b1;

    end
    else if (BINARY_POINTER == 1)
    begin : g_bin_mux
      for (g=0; g < FIFO_DEPTH; g=g+1)
      begin : g_entry

        assign mux_sel[g] = (rflag_shift == flag_t'(g));

      end
    end
    else
    begin : g_oh

      assign mux_sel = rflag_shift;

    end

  endgenerate

  sie300_axi5_sram_ctrl_cvm_one_hot
  #(
    .SEL_WIDTH  (FIFO_DEPTH),
    .DATA_WIDTH (FIFO_WIDTH)
  )
  u_pop_data_mux
  (
    .inp_sel  (mux_sel),
    .inp_data (fifo),
    .out_data (pop_data_mux)
  );

  generate
    if (FIFO_DEPTH == 1)
    begin : g_comb_output

      assign pop_data_o = pop_data_mux;

    end
    else
    begin : g_reg_output

      logic [FIFO_WIDTH-1:0] pop_data_nxt;

      always_comb
      begin : p_pop_data_nxt_comb
        case ({ empty_o, pop_last, pop_i, push_i })

          4'b1001,
          4'b0111 : pop_data_nxt = push_data_i;

          4'b0010,
          4'b0011 : pop_data_nxt = pop_data_mux;

          4'b0000,
          4'b0001,
          4'b0100,
          4'b0101,
          4'b0110,
          4'b1000 : pop_data_nxt = pop_data_o;

          4'b1011,
          4'b1010,
          4'b1101,
          4'b1100,
          4'b1110,
          4'b1111 : pop_data_nxt = pop_data_o;

          default : pop_data_nxt = 'x;
        endcase
      end

      always_ff @(posedge clk or negedge resetn)
      begin : p_output_reg
        if (!resetn)
          pop_data_o <= 'b0;
        else
          pop_data_o <= pop_data_nxt;
      end

    end
  endgenerate


  generate
    if (PEEK_LOGIC == 1)
    begin : g_peek_outputs
      assign peek_data_valid_o  = in_use;
      assign peek_data_o        = fifo;
    end
    else
    begin : g_peek_tied_off
      assign peek_data_valid_o  = 'b0;
      assign peek_data_o        = 'b0;
    end
  endgenerate

endmodule

