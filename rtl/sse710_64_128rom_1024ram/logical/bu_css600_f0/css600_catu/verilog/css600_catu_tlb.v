//----------------------------------------------------------------------------
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//          (C) COPYRIGHT 2016-2017, 2019-2020 Arm Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from Arm Limited or its affiliates.
//----------------------------------------------------------------------------
//   Release information : TM200-MN-22110-r4p1-00rel0
//
//----------------------------------------------------------------------------
//   Description :
//   Sub-module of css600_catu
//
//----------------------------------------------------------------------------


module css600_catu_tlb
#(
  parameter DSIZE          = 2,
  parameter AXI_ADDR_WIDTH = 40,
  parameter VA_WIDTH       = 40,
  parameter PA_WIDTH       = 40,
  parameter PS_WIDTH       = 12,
  parameter TLB_RD_DEPTH   = 1,
  parameter TLB_WR_DEPTH   = 2,
  parameter INIT_BITS      = 1
)(
  input  wire                                     clk,
  input  wire                                     reset_n,
  input  wire [AXI_ADDR_WIDTH-1:0]                ctrl_inaddr,
  input  wire                                     init_tlbs,
  input  wire                                     clr_tlbs,
  input  wire                                     translate_arvalid,
  input  wire [VA_WIDTH-1:0]                      axislv_araddr,
  input  wire                                     translate_awvalid,
  input  wire [VA_WIDTH-1:0]                      axislv_awaddr,
  input  wire                                     translated_awready,
  input  wire                                     upd_awaddr_en,
  input  wire                                     trans_slw_awvalid,
  output wire [PA_WIDTH-PS_WIDTH:0]               tlb_rd_result,
  output wire [PA_WIDTH-PS_WIDTH:0]               tlb_wr_result,

  input  wire                                     slw_rd_tlb_valid,
  input  wire                                     slw_wr_tlb_valid,
  input  wire                                     slw_wr_tlb_upd,
  input  wire                                     slw_wr_tlb_inv,
  input  wire                                     slw_invalid_tlb_pftch,
  input  wire [PA_WIDTH-PS_WIDTH+INIT_BITS-1:0]   slw_tlb_data,

  output reg                                      wr_prefetch,
  output reg                                      wr_pre_addr_inc_ndec,
  output reg  [VA_WIDTH-PS_WIDTH-1:0]             wr_pre_addr
);

  genvar i;

  wire [VA_WIDTH-PS_WIDTH-1:0]  rd_tlb_lookuptag;
  wire                          rd_tlb_lookupen;

  wire [PA_WIDTH-PS_WIDTH-1:0]  rd_tlb_updatedata;
  wire                          rd_tlb_entry_valid;

  wire [PA_WIDTH-PS_WIDTH-1:0]  tlb_entry_rd_data [TLB_RD_DEPTH-1:0];
  wire [TLB_RD_DEPTH-1:0]       tlb_entry_rd_hit;

  wire [VA_WIDTH-PS_WIDTH-1:0]  wr_tlb_lookuptag;
  wire                          wr_tlb_lookupen;

  wire [PA_WIDTH-PS_WIDTH-1:0]  wr_tlb_updatedata;
  wire                          wr_tlb_entry_valid;

  wire [VA_WIDTH-PS_WIDTH-1:0]  tlb_entry_wr_tag  [TLB_WR_DEPTH-1:0];
  wire [PA_WIDTH-PS_WIDTH-1:0]  tlb_entry_wr_data [TLB_WR_DEPTH-1:0];
  wire [TLB_WR_DEPTH-1:0]       tlb_entry_wr_hit;

  reg [PA_WIDTH-PS_WIDTH:0]     lookup_res_rd_mux;
  reg [PA_WIDTH-PS_WIDTH:0]     lookup_res_wr_mux;

  reg                           wr_tlb_slot;
  reg                           curr_wr_slot;
  wire [VA_WIDTH-PS_WIDTH-1:0]  inc_addr;
  wire [VA_WIDTH-PS_WIDTH-1:0]  dec_addr;
  reg  [VA_WIDTH-PS_WIDTH-1:0]  upd_awaddr;


  assign rd_tlb_lookuptag    = axislv_araddr[ VA_WIDTH-1 : PS_WIDTH ];
  assign rd_tlb_lookupen     = translate_arvalid;

  assign rd_tlb_updatedata   = slw_tlb_data[PA_WIDTH-PS_WIDTH:INIT_BITS];
  assign rd_tlb_entry_valid  = ~clr_tlbs;

  generate
    for (i = 0; i < TLB_RD_DEPTH; i=i+1)
    begin : gen_rd_tlb_entries

      wire update_en;
      wire [VA_WIDTH-PS_WIDTH-1:0]  rd_tlb_updatetag;

      if (INIT_BITS > 0) begin : r_init_bits
        assign update_en = ((slw_tlb_data[INIT_BITS-1:0]==i[INIT_BITS-1:0]) & slw_rd_tlb_valid) | clr_tlbs;
        assign rd_tlb_updatetag = slw_rd_tlb_valid && init_tlbs ?
                                    {ctrl_inaddr[VA_WIDTH-1:PS_WIDTH+INIT_BITS], slw_tlb_data[INIT_BITS-1:0]}
                                : slw_rd_tlb_valid ?
                                    axislv_araddr[VA_WIDTH-1:PS_WIDTH]
                                : wr_pre_addr;
       end
      else begin : no_r_init_bits
        assign update_en = slw_rd_tlb_valid;
        assign rd_tlb_updatetag = slw_rd_tlb_valid ? ctrl_inaddr[VA_WIDTH-1:PS_WIDTH]
                                      : {VA_WIDTH-PS_WIDTH{1'b0}};
       end

      css600_catu_tlb_entry
      #(
        .TAG_WIDTH   ( VA_WIDTH-PS_WIDTH ),
        .DATA_WIDTH  ( PA_WIDTH-PS_WIDTH )
      )
      u_css600_catu_tlb_entry_rd
      (
        .clk            ( clk                          ),
        .reset_n        ( reset_n                      ),
        .lookup_tag     ( rd_tlb_lookuptag       ),
        .lookup_enable  ( rd_tlb_lookupen        ),
        .entry_tag      (                              ),
        .entry_data     ( tlb_entry_rd_data[i]         ),
        .entry_hit      ( tlb_entry_rd_hit[i]          ),
        .update_tag     ( rd_tlb_updatetag       ),
        .update_data    ( rd_tlb_updatedata      ),
        .update_valid   ( rd_tlb_entry_valid     ),
        .update_enable  ( update_en     )
      );

    end
  endgenerate


  assign wr_tlb_lookuptag    = axislv_awaddr[ VA_WIDTH-1 : PS_WIDTH ];
  assign wr_tlb_lookupen     = translate_awvalid;

  assign wr_tlb_updatedata   = slw_tlb_data[PA_WIDTH-PS_WIDTH:INIT_BITS];
  assign wr_tlb_entry_valid  = ~clr_tlbs;

  generate
    for (i = 0; i < TLB_WR_DEPTH; i=i+1)
    begin : gen_wr_tlb_entries

      wire update_en;
      wire [VA_WIDTH-PS_WIDTH-1:0]  wr_tlb_updatetag;
      wire [VA_WIDTH-PS_WIDTH-1:0]  tlb_va;

      if (INIT_BITS > 0) begin : w_init_bits

        assign tlb_va = slw_tlb_data[0] ? upd_awaddr + {{VA_WIDTH-PS_WIDTH-1{1'b0}}, 1'b1}
                                        : upd_awaddr;
        assign update_en = ((slw_tlb_data[INIT_BITS-1:0]==i[INIT_BITS-1:0]) & slw_wr_tlb_valid)
                           | (slw_wr_tlb_upd & (~curr_wr_slot==i[0]))
                           | clr_tlbs;
        assign wr_tlb_updatetag = slw_wr_tlb_valid && init_tlbs ?
                                    {ctrl_inaddr[VA_WIDTH-1:PS_WIDTH+INIT_BITS], slw_tlb_data[INIT_BITS-1:0]}
                                   : slw_wr_tlb_valid ? tlb_va : wr_pre_addr;
       end
      else begin : no_w_init_bits
        assign update_en = slw_wr_tlb_valid;
        assign wr_tlb_updatetag = slw_wr_tlb_valid ? ctrl_inaddr[VA_WIDTH-1:PS_WIDTH]
                                : axislv_awaddr[VA_WIDTH-1:PS_WIDTH];
       end

      css600_catu_tlb_entry
      #(
        .TAG_WIDTH   ( VA_WIDTH-PS_WIDTH ),
        .DATA_WIDTH  ( PA_WIDTH-PS_WIDTH )
      )
      u_css600_catu_tlb_entry_wr
      (
        .clk            ( clk                  ),
        .reset_n        ( reset_n              ),
        .lookup_tag     ( wr_tlb_lookuptag     ),
        .lookup_enable  ( wr_tlb_lookupen      ),
        .entry_tag      ( tlb_entry_wr_tag[i]  ),
        .entry_data     ( tlb_entry_wr_data[i] ),
        .entry_hit      ( tlb_entry_wr_hit[i]  ),
        .update_tag     ( wr_tlb_updatetag     ),
        .update_data    ( wr_tlb_updatedata    ),
        .update_valid   ( wr_tlb_entry_valid   ),
        .update_enable  ( update_en     )
      );

    end
  endgenerate

  generate
    if (TLB_WR_DEPTH > 1)
    begin : gen_wr_tlb_tracker

        wire    next_curr_wr_slot;
        reg     used_wr_slot;
        wire    wr_hit;
        wire    curr_slot_en;
        wire    wr_slot_en;
        wire    wr_pre_en;
        wire    next_wr_used;
        wire    wr_prefetch_set;
        wire    wr_prefetch_clr;
        wire    inc_ndec;
        wire [VA_WIDTH-PS_WIDTH-1:0] next_pre_addr;
        wire [VA_WIDTH-PS_WIDTH-1:0] inc_dec_no;
        reg     slw_invalid_tlb_pftch_q;

        assign inc_dec_no = {{VA_WIDTH-PS_WIDTH-1{1'b0}}, 1'b1};

        assign wr_hit = |(tlb_entry_wr_hit);
        assign next_curr_wr_slot = wr_tlb_slot & ~slw_wr_tlb_valid;
        assign curr_slot_en = (wr_hit & translated_awready);
        assign wr_slot_en = curr_slot_en | slw_wr_tlb_valid;
        assign next_wr_used = wr_hit | (used_wr_slot & trans_slw_awvalid);

        always @(posedge clk or negedge reset_n)
        begin
          if (!reset_n)
          begin
            slw_invalid_tlb_pftch_q <= 1'b0;
          end
          else
          begin
            slw_invalid_tlb_pftch_q <= slw_invalid_tlb_pftch;
          end
        end
        assign wr_prefetch_set = (wr_hit & translated_awready & used_wr_slot & inc_ndec
                               & (curr_wr_slot != next_curr_wr_slot))
                               | slw_invalid_tlb_pftch_q;
        assign wr_prefetch_clr = slw_wr_tlb_valid | slw_wr_tlb_upd | slw_wr_tlb_inv;
        assign wr_pre_en =  wr_prefetch_set | wr_prefetch_clr;

        always @(posedge clk or negedge reset_n)
        begin
          if (!reset_n)
           begin
             wr_prefetch  <= 1'b0;
           end
          else if (wr_pre_en)
           begin
             wr_prefetch  <= ~wr_prefetch_clr;
           end
        end

        always @(posedge clk or negedge reset_n)
        begin
          if (!reset_n)
           begin
             used_wr_slot <= 1'b0;
           end
          else if (wr_slot_en)
           begin
             used_wr_slot <= next_wr_used;
           end
        end

        always @(posedge clk or negedge reset_n)
        begin
          if (!reset_n)
           begin
             curr_wr_slot <= 1'b0;
           end
          else if (wr_slot_en)
           begin
             curr_wr_slot <= next_curr_wr_slot;
           end
        end

        assign inc_addr = tlb_entry_wr_tag[next_curr_wr_slot] + inc_dec_no;
        assign dec_addr = tlb_entry_wr_tag[next_curr_wr_slot] - inc_dec_no;
        assign inc_ndec = (tlb_entry_wr_tag[next_curr_wr_slot] > tlb_entry_wr_tag[curr_wr_slot]);
        assign next_pre_addr = slw_invalid_tlb_pftch_q
                               ? ctrl_inaddr[VA_WIDTH-1:PS_WIDTH]
                               : inc_ndec
                                 ? inc_addr
                                 : dec_addr;

        always @(posedge clk)
        begin
          if (wr_prefetch_set)
           begin
             wr_pre_addr_inc_ndec <= inc_ndec;
             wr_pre_addr  <= next_pre_addr;
           end
        end

        always @(posedge clk)
        begin
          if (upd_awaddr_en)
           begin
             upd_awaddr  <= axislv_awaddr[VA_WIDTH-1:PS_WIDTH];
           end
        end


    end
  endgenerate


  always @*
  begin : comb_lookup_res_rd_mux
    integer j;
    lookup_res_rd_mux[PA_WIDTH-PS_WIDTH:1] = {PA_WIDTH-PS_WIDTH{1'b0}};
    lookup_res_rd_mux[0] = 1'b0;
    for (j = 0; j < TLB_RD_DEPTH; j=j+1)
      begin : comb_lookup_res_rd_mux
        reg rd_hit;
        rd_hit = tlb_entry_rd_hit[j];
        if (rd_hit == 1'b1)
         begin
           lookup_res_rd_mux[PA_WIDTH-PS_WIDTH:1] = tlb_entry_rd_data[j];
           lookup_res_rd_mux[0] = tlb_entry_rd_hit[j];
         end
      end
  end


  always @*
  begin : comb_lookup_res_wr_mux
    integer j;
    wr_tlb_slot = 1'b0;
    lookup_res_wr_mux[PA_WIDTH-PS_WIDTH:1] = {PA_WIDTH-PS_WIDTH{1'b0}};
    lookup_res_wr_mux[0] = 1'b0;
    for (j = 0; j < TLB_WR_DEPTH; j=j+1)
      begin : comb_lookup_res_wr_mux
        reg mux_wr_hit;
        mux_wr_hit = tlb_entry_wr_hit[j];
        if (mux_wr_hit == 1'b1)
         begin
           lookup_res_wr_mux[PA_WIDTH-PS_WIDTH:1] = tlb_entry_wr_data[j];
           lookup_res_wr_mux[0] = tlb_entry_wr_hit[j];
           wr_tlb_slot = (j==1);
         end
      end
  end

  assign tlb_rd_result = lookup_res_rd_mux;
  assign tlb_wr_result = lookup_res_wr_mux;


endmodule

