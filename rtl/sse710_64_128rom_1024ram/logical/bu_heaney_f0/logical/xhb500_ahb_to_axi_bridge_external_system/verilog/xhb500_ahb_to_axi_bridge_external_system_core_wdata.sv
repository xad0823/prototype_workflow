//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2025 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//-----------------------------------------------------------------------------
//
//      Version Information
//
//      Checked In          : Fri Mar 29 11:15:40 2019 +0000
//
//      Revision            : 08e988e
//
//      Release Information : CoreLink XHB-500 Generic Global Bundle r0p0-00rel0
//

module xhb500_ahb_to_axi_bridge_external_system_core_wdata (

  input  wire logic                                         clk,
  input  wire logic                                         resetn,

  input  wire logic                                         hsel,
  input  wire logic                                         hready,
  input  wire logic [1:0]                                   htrans,
  input  wire logic [1:0]                                   hsize,
  input  wire logic [32-1:0]                                haddr,
  input  wire logic                                         hwrite,
  input  wire logic [6:0]                                   hprot,
  input  wire logic [2:0]                                   hburst,
  input  wire logic                                         hmastlock,
  input  wire logic                                         hexcl,
  input  wire logic [1-1:0]                                 hmaster,
  input  wire logic [32-1:0]                                hwdata,
  input       logic                                         hreadyout,

  output      logic                                         wvalid,
  output      logic                                         wlast,
  output      logic [4-1:0]                                 wstrb,
  output      logic [32-1:0]                                wdata,
  input  wire logic                                         wready,

  input  wire logic                                         bvalid,
  input  wire logic                                         bready,
  input  wire logic [1-1:0]                                 bid,

  input  wire logic                                         b_ewr,

  output      logic                                         write_data_phase,
  input  wire logic                                         address_readyout,

  output      logic                                         pending_broken_b_resp,
  output      logic                                         pending_broken_b_resp_next,
  output      logic [1-1:0]                                 pending_broken_b_resp_id,
  output      logic [1-1:0]                                 pending_broken_b_resp_id_next,
  output      logic                                         ignore_broken_b_resp,

  output      logic                                         beat_done_w,
  output      logic [4:0]                                   writes_remaining,
  output      logic                                         write_readyout,

  output      logic                                         wdata_idle,
  input  wire logic                                         clk_qacceptn,
  input  wire logic                                         pwr_qacceptn
  );

  import xhb500_ahb_to_axi_bridge_external_system_pkg::*;

  typedef struct packed {
    logic                                                  wlast;
    logic  [4-1:0]                                         wstrb;
    logic  [32-1:0]                                        wdata;
  } wdata_signals;


  logic                                                    wdata_empty;
  logic                                                    wdata_in_valid;
  wdata_signals                                            wdata_in;
  logic                                                    wdata_in_ready;
  logic                                                    wdata_out_valid;
  wdata_signals                                            wdata_out;
  logic                                                    wdata_out_ready;

  logic                                                    wdata_2_in_valid;
  wdata_signals                                            wdata_2_in;
  logic                                                    wdata_2_in_ready;
  logic                                                    wdata_2_out_valid;
  wdata_signals                                            wdata_2_out;
  logic                                                    wdata_2_out_ready;
  logic                                                    wdata_2_empty;

  logic [4:0]                                              write_counter;
  logic [4:0]                                              write_counter_reg;
  logic                                                    write_data_valid;

  logic                                                    wait_for_b;

  logic                                                    ewr;

  logic                                                    last;
  logic [4-1:0]                                            strb;

  logic [32-1:0]                                           write_address;
  logic [1:0]                                              write_size;
  logic                                                    write_mod;
  logic                                                    write_excl;
  ahb_burst_type                                           write_b_type;
  logic [1-1:0]                                            write_id;
  logic [3:0]                                              write_length;

  logic                                                    stall_writes;

  logic                                                    write_broken;
  logic                                                    write_broken_next;

  wire logic [3:0] unused = { hprot[0],hprot[1],hprot[4],hprot[5] };



  xhb500_ahb_to_axi_bridge_external_system_strb u_strb (
    .haddr            ( write_address ),
    .hsize            ( write_size ),

    .wstrb            ( strb )
  );

  assign wdata_in_valid = (write_data_valid & ~stall_writes) || write_broken;
  assign wdata_in = { last,   strb & {4{~(write_broken)}},   hwdata };

  xhb500_reverse_regd_slice_rst_empty
  #(
    .PAYLD_WIDTH($bits(wdata_signals))
  )
  u_wdata_st1_regslice
  (
    .clk                (clk),
    .resetn             (resetn),
    .empty              (wdata_empty),
    .valid_src          (wdata_in_valid),
    .payload_src        (wdata_in),
    .ready_src          (wdata_in_ready),
    .valid_dst          (wdata_out_valid),
    .payload_dst        (wdata_out),
    .ready_dst          (wdata_out_ready)
  );

  assign wdata_2_in_valid = wdata_out_valid;
  assign wdata_out_ready = wdata_2_in_ready;
  assign wdata_2_in = wdata_out;

  xhb500_bypass_regd_slice
  #(
    .PAYLD_WIDTH($bits(wdata_signals))
  )
  u_wdata_st2_regslice
  (
    .valid_src          (wdata_2_in_valid),
    .payload_src        (wdata_2_in),
    .ready_src          (wdata_2_in_ready),
    .valid_dst          (wdata_2_out_valid),
    .payload_dst        (wdata_2_out),
    .ready_dst          (wdata_2_out_ready)
  );

  assign wdata_2_empty = 1'b1;

  assign {wlast, wstrb, wdata} = wdata_2_out;
  assign wvalid = wdata_2_out_valid;
  assign wdata_2_out_ready = wready;


  always_ff @ (posedge clk or negedge resetn)
  begin : p_write_data_phase_reg
      if (~resetn)
      begin
        write_data_phase <= 1'b0;
        write_data_valid <= 1'b0;
      end
      else
        if (hsel & hready)
        begin
          write_data_phase <= htrans[1] & hwrite & ~hmastlock;
          write_data_valid <= htrans[1] & hwrite & ~hmastlock;
        end
        else if (write_data_valid && wdata_in_ready && ~stall_writes && ~write_broken)
          write_data_valid <= 1'b0;
  end

  always_ff @ (posedge clk or negedge resetn)
  begin : p_write_addr_strb_reg
    if (~resetn)
    begin
      write_address <= 32'b0;
      write_size    <= 2'b00;
      write_mod     <= 1'b0;
      write_excl    <= 1'b0;
      write_b_type  <= BUR_SINGLE;
      write_id      <= {1{1'b0}};
    end
    else
      if (hsel & hready & htrans[1] & hwrite & ~hmastlock)
      begin
        write_address <= haddr;
        write_size    <= hsize;
        write_mod     <= hprot[3];
        write_excl    <= hexcl;
        write_b_type  <= ahb_burst_type'(hburst);
        write_id      <= hmaster;
      end
  end

  assign write_length = calculate_burst_length(
                     write_mod,
                     write_excl,
                     write_b_type,
                     write_size,
                     write_address);

  assign last = write_counter == 5'd1;

  always_ff @ (posedge clk or negedge resetn)
  begin : write_counter_reg_ff
      if (~resetn)
        write_counter_reg <= 5'd0;
      else
      begin
        if (write_data_valid & wdata_in_ready && write_counter_reg == 5'd0)
          write_counter_reg <= {1'b0,write_length} + (wdata_in_valid? 5'd0 : 5'd1);
        else if (wdata_in_valid & wdata_in_ready)
          write_counter_reg <= write_counter_reg -5'd1;
      end
  end

  assign write_counter = (write_counter_reg == 5'd0 && write_data_valid) ? {1'b0,write_length}+5'd1 : write_counter_reg;

  always_ff @ (posedge clk or negedge resetn)
  begin : ewr_reg
      if (~resetn)
        ewr <= 1'd0;
      else
        if (hsel & htrans[1] & hwrite & hready)
          ewr <= hprot[2] & ~hprot[6];
  end

  assign stall_writes = ~address_readyout || pending_broken_b_resp || ~(clk_qacceptn && pwr_qacceptn);

  assign write_broken_next = ~write_broken &
                             hreadyout & (~hsel |  ~htrans[0]) & (|write_counter[4:1] ||
                                                                  (write_counter == 5'd1 && ~wdata_in_valid) );

  always_ff @ (posedge clk or negedge resetn)
  begin : write_broken_reg
      if (~resetn)
        write_broken <= 1'b0;
      else
        if (write_broken_next)
          write_broken <= 1'b1;
        else if (write_counter == 5'd1 & wdata_in_valid & wdata_in_ready)
          write_broken <= 1'b0;
  end


  always_ff @ (posedge clk or negedge resetn)
  begin : p_pending_broken_b_resp_reg
      if (~resetn)
        pending_broken_b_resp    <= 1'b0;
      else
      begin

        if (~pending_broken_b_resp & write_broken_next & ~ewr)
          pending_broken_b_resp    <= 1'b1;
        else if (bvalid & bready & ~b_ewr & ignore_broken_b_resp)
          pending_broken_b_resp    <= 1'b0;

      end
  end
  assign pending_broken_b_resp_next = write_broken_next & ~ewr;
  assign pending_broken_b_resp_id_next = write_id;

  always_ff @ (posedge clk or negedge resetn)
  begin : pending_broken_b_resp_id_reg
      if (~resetn)
        pending_broken_b_resp_id <= {1{1'b0}};
      else

        if (~ewr & write_broken_next)
          pending_broken_b_resp_id <= write_id;
  end

  always_ff @ (posedge clk or negedge resetn)
  begin : wait_for_b_reg
      if (~resetn)
        wait_for_b    <= 1'b0;
      else
      begin

        if (wdata_in_ready && wdata_in_valid && ~ewr && write_counter == 5'd1 && ~write_broken)
          wait_for_b    <= 1'b1;
        else if (bvalid & bready & ~b_ewr & ~ignore_broken_b_resp)
          wait_for_b    <= 1'b0;

      end
  end

  assign ignore_broken_b_resp = bvalid & ~b_ewr & pending_broken_b_resp & pending_broken_b_resp_id == bid;


  assign beat_done_w = !write_broken & !pending_broken_b_resp &
                       (clk_qacceptn && pwr_qacceptn) &
                       ((wdata_in_ready & ~stall_writes & (~last || ewr) & ~wait_for_b) ||
                        (~ewr & bvalid & bready & ~b_ewr & ~ignore_broken_b_resp));


  assign write_readyout = wdata_2_empty & ~stall_writes & ~(write_broken || write_broken_next);

  assign writes_remaining = write_counter;

  assign wdata_idle = wdata_empty & wdata_2_empty & write_counter == 5'd0 & ~wvalid & ~wdata_in_valid & ~wait_for_b;








endmodule
