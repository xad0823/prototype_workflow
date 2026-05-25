// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2016 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//      Version Information
//
//      Checked In          : Mon Sep 12 17:35:31 2016 +0100
//
//      Revision            : 88c2d84
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_write_buffer
  #(
   parameter       AW    = 32,
   parameter       DW    = 32,
   parameter       MW    = 4,
   parameter       UW    = 1
   )
  (
  input  wire           hclk,
  input  wire           hresetn,

  input  wire           hsel_s,
  input  wire           hnonsec_s,
  input  wire  [AW-1:0] haddr_s,
  input  wire     [1:0] htrans_s,
  input  wire     [2:0] hsize_s,
  input  wire           hwrite_s,
  input  wire           hready_s,
  input  wire     [6:0] hprot_s,
  input  wire  [MW-1:0] hmaster_s,
  input  wire           hmastlock_s,
  input  wire  [DW-1:0] hwdata_s,
  input  wire     [2:0] hburst_s,
  input  wire           hexcl_s,
  input  wire  [UW-1:0] hauser_s,
  input  wire  [UW-1:0] hwuser_s,

  output wire           hreadyout_s,
  output wire           hresp_s,
  output wire           hexokay_s,
  output wire  [DW-1:0] hrdata_s,
  output wire  [UW-1:0] hruser_s,

  output wire           hsel_m,
  output wire           hnonsec_m,
  output wire  [AW-1:0] haddr_m,
  output wire     [1:0] htrans_m,
  output wire     [2:0] hsize_m,
  output wire           hwrite_m,
  output wire           hready_m,
  output wire     [6:0] hprot_m,
  output wire  [MW-1:0] hmaster_m,
  output wire           hmastlock_m,
  output wire  [DW-1:0] hwdata_m,
  output wire     [2:0] hburst_m,
  output wire           hexcl_m,
  output wire  [UW-1:0] hauser_m,
  output wire  [UW-1:0] hwuser_m,

  input  wire           hreadyout_m,
  input  wire           hresp_m,
  input  wire           hexokay_m,
  input  wire  [DW-1:0] hrdata_m,
  input  wire  [UW-1:0] hruser_m,

  input  wire           wb_disable,

  input  wire           bwerr_clear,
  output wire           bwerr);


  localparam       HSIZE_W   = (DW > 64) ? 3 : 2;
  localparam       HSIZE_MAX = HSIZE_W - 1;

  reg              reg_hnonsec;
  reg     [AW-1:0] reg_haddr;
  reg        [1:0] reg_htrans;
  reg              reg_hwrite;
  reg [HSIZE_MAX:0] reg_hsize;
  reg     [MW-1:0] reg_hmasters;
  reg              reg_hmastlocks;
  reg        [2:0] reg_hburst;
  reg              reg_hexcl;
  reg        [6:0] reg_hprot;
  reg     [UW-1:0] reg_hauser;
  wire       [2:0] reg_hsize_padded;

  reg     [DW-1:0] reg_hwdata;
  reg     [UW-1:0] reg_hwuser;
  reg              reg_bufferable;
  wire             nxt_bufferable;
  wire             bufferable_m;
  reg              reg_bufferable_m;

  reg              reg_locked_trans;

  reg              reg_unlock_pend;
  wire             set_unlock_pend;
  wire             clr_unlock_pend;

  reg              reg_buf_pend;
  wire             set_buf_pend;
  wire             clr_buf_pend;

  reg              reg_bufwr_running;
  wire             nxt_bufwr_running;

  wire             idle_injection;

  wire             address_phase_output_sel;
  wire             trans_valid;
  wire             trans_valid_rdy;

  wire             hreadym_mux;
  reg              hreadouts_mux;

  reg              reg_bwerr;
  wire             reg_bwerr_set;


  assign    trans_valid     = hsel_s & htrans_s[1];
  assign    trans_valid_rdy = trans_valid & hready_s;

  assign    nxt_bufferable  = trans_valid & hwrite_s & hprot_s[2] & ~hexcl_s;

  assign    bufferable_m  = (address_phase_output_sel) ? reg_bufferable  : (nxt_bufferable & hready_s);

  always @(posedge hclk or negedge hresetn)
    begin : p_reg_bufferable_m
    if (!hresetn)
      reg_bufferable_m <= 1'b0;
    else
      reg_bufferable_m <= bufferable_m & hreadym_mux & ~wb_disable;
    end

  assign nxt_bufwr_running = (reg_bufferable_m  & (~hreadyout_m) & (~hresp_m)) |
                             (reg_bufwr_running & (~hreadyout_m));

  always @(posedge hclk or negedge hresetn)
    begin : p_reg_bufwr_running
    if (!hresetn)
      reg_bufwr_running <= 1'b0;
    else
      reg_bufwr_running <= nxt_bufwr_running;
    end


  always @(posedge hclk or negedge hresetn)
  begin : p_reg_locked_trans
    if (!hresetn) begin
      reg_locked_trans <= 1'b0;
    end
    else if (trans_valid_rdy & hmastlock_s) begin
      reg_locked_trans <= 1'b1;
    end
    else if (hready_s & ((hsel_s & (~hmastlock_s)) | (~hsel_s))) begin
      reg_locked_trans <= 1'b0;
    end
  end


  assign set_unlock_pend  = hready_s & ~hreadym_mux & ~trans_valid & reg_locked_trans & (((~hmastlock_s) & hsel_s) | (~hsel_s));

  assign clr_unlock_pend  = hreadym_mux;


  always @(posedge hclk or negedge hresetn)
  begin : p_reg_unlock_pend
    if (!hresetn) begin
      reg_unlock_pend <= 1'b0;
    end
    else if (clr_unlock_pend) begin
      reg_unlock_pend <= 1'b0;
    end
    else if (set_unlock_pend) begin
      reg_unlock_pend <= 1'b1;
    end
  end


  always @(posedge hclk or negedge hresetn)
    begin : p_address_phase_buffers
     if (!hresetn)
       begin
       reg_hnonsec     <= 1'b0;
       reg_haddr       <= {AW{1'b0}};
       reg_htrans      <= 2'b10;
       reg_hwrite      <= 1'b0;
       reg_hsize       <= {HSIZE_W{1'b0}};
       reg_hmasters    <= {MW{1'b0}};
       reg_hmastlocks  <= 1'b0;
       reg_hburst      <= {3{1'b0}};
       reg_hexcl       <= 1'b0;
       reg_hprot       <= {7{1'b0}};
       reg_hauser      <= {UW{1'b0}};
       reg_bufferable  <= 1'b0;
       end
     else if (set_buf_pend)
       begin
       reg_hnonsec     <= hnonsec_s;
       reg_haddr       <= haddr_s;
       reg_htrans      <= htrans_s;
       reg_hwrite      <= hwrite_s;
       reg_hsize       <= hsize_s[HSIZE_MAX:0];
       reg_hmasters    <= hmaster_s;
       reg_hmastlocks  <= hmastlock_s;
       reg_hburst      <= hburst_s;
       reg_hexcl       <= hexcl_s;
       reg_hprot       <= hprot_s;
       reg_hauser      <= hauser_s;
       reg_bufferable  <= nxt_bufferable;
       end
    end

  assign reg_hsize_padded[2]   = (DW > 64) ? reg_hsize[HSIZE_MAX] : 1'b0;
  assign reg_hsize_padded[1:0] = reg_hsize[1:0];

  assign set_buf_pend = trans_valid_rdy & (~hreadym_mux | (reg_bufwr_running & reg_unlock_pend));

  assign clr_buf_pend = hreadym_mux & ~reg_unlock_pend & (~(trans_valid_rdy & reg_bufwr_running));

  always @(posedge hclk or negedge hresetn)
    begin : p_reg_buf_pend
    if (!hresetn)
      reg_buf_pend <= 1'b0;
    else if (set_buf_pend | clr_buf_pend)
      reg_buf_pend <= ~clr_buf_pend;
    end

  assign address_phase_output_sel = reg_buf_pend;

  assign idle_injection = (reg_bufwr_running & ~reg_buf_pend & ~hready_s) | reg_unlock_pend;


  assign haddr_m      = address_phase_output_sel ? reg_haddr : haddr_s;
  assign hnonsec_m    = address_phase_output_sel ? reg_hnonsec : hnonsec_s;
  assign hprot_m      = address_phase_output_sel ? reg_hprot : hprot_s;
  assign hexcl_m      = address_phase_output_sel ? reg_hexcl : hexcl_s;
  assign hauser_m     = address_phase_output_sel ? reg_hauser : hauser_s;

  assign htrans_m     = (address_phase_output_sel ? reg_htrans : htrans_s) &
                        {(~idle_injection), 1'b1};

  assign hwrite_m     = address_phase_output_sel ? reg_hwrite : hwrite_s;
  assign hsize_m      = address_phase_output_sel ? reg_hsize_padded : hsize_s;
  assign hmaster_m    = address_phase_output_sel ? reg_hmasters : hmaster_s;

  assign hmastlock_m  = reg_unlock_pend          ? 1'b0 :
                        address_phase_output_sel ? reg_hmastlocks :
                                                   hmastlock_s;

  assign hburst_m     = address_phase_output_sel ? reg_hburst : hburst_s;
  assign hsel_m       = address_phase_output_sel ? reg_htrans[1] : hsel_s;


  always @(reg_buf_pend or reg_bufferable_m or hresp_m or reg_bufwr_running or hreadyout_m)
   begin : p_hreadouts_mux
   if (reg_buf_pend)
     hreadouts_mux = 1'b0;
   else if (reg_bufferable_m & hresp_m)
     hreadouts_mux = 1'b0;
   else if ((~reg_bufferable_m) & (~reg_bufwr_running))
     hreadouts_mux = hreadyout_m;
   else
     hreadouts_mux = 1'b1;
   end

  assign hreadyout_s  = hreadouts_mux;
  assign hrdata_s     = hrdata_m;
  assign hruser_s     = hruser_m;
  assign hexokay_s    = hexokay_m;
  assign hresp_s      = (~reg_bufwr_running) & hresp_m;

  assign hreadym_mux = (reg_bufferable_m | reg_bufwr_running | reg_buf_pend) ?
                        hreadyout_m : hready_s;

  assign hready_m     = hreadym_mux;

  always @(posedge hclk or negedge hresetn)
  begin : p_reg_hwdata
    if (!hresetn) begin
      reg_hwdata <= {DW{1'b0}};
      reg_hwuser <= {UW{1'b0}};
    end
    else if (reg_bufferable_m) begin
      reg_hwdata <= hwdata_s;
      reg_hwuser <= hwuser_s;
    end
  end
  assign hwdata_m = (reg_bufwr_running) ? reg_hwdata : hwdata_s;
  assign hwuser_m = (reg_bufwr_running) ? reg_hwuser : hwuser_s;



  assign reg_bwerr_set = reg_bufwr_running & hresp_m & ~hreadyout_m;

  always @(posedge hclk or negedge hresetn)
  begin : p_reg_bwerr
    if (!hresetn) begin
      reg_bwerr <= 1'b0;
    end
    else if (bwerr_clear) begin
       reg_bwerr <= 1'b0;
    end
    else if (reg_bwerr_set) begin
      reg_bwerr <= 1'b1;
    end
  end

  assign bwerr = reg_bwerr;


endmodule
