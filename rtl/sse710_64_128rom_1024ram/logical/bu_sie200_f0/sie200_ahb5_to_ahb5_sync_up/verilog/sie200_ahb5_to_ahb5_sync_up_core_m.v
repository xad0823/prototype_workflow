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
//      Checked In          : Fri Sep 30 17:23:58 2016 +0200
//
//      Revision            : fb14a9f
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------

module sie200_ahb5_to_ahb5_sync_up_core_m #(

  parameter       AW    = 32,
  parameter       DW    = 32,
  parameter       MW    = 4,
  parameter       UW    = 1,
  parameter       BURST = 0)
 (
  input  wire          hclk_m,
  input  wire          hresetn_m,

  input  wire          hnonsecs_reg,
  input  wire [AW-1:0] haddrs_reg,
  input  wire    [1:0] htranss_reg,
  input  wire    [2:0] hsizes_reg,
  input  wire          hwrites_reg,
  input  wire    [6:0] hprots_reg,
  input  wire [MW-1:0] hmasters_reg,
  input  wire          hmastlocks_reg,
  input  wire          hexcls_reg,
  input  wire    [2:0] hbursts_reg,
  input  wire [UW-1:0] hausers_reg,
  input  wire [DW-1:0] hwdatas_reg,
  input  wire [UW-1:0] hwusers_reg,

  output reg           hrespm_reg,
  output reg           hexokaym_reg,
  output reg  [DW-1:0] hrdatam_reg,
  output reg  [UW-1:0] hruserm_reg,

  output reg           transm_done,
  input  wire          transs_req,
  input  wire          unlocks_req,
  input  wire          bursts_terminate,

  input  wire          brg_pwr_req_m,

  output wire          hnonsec_m,
  output wire [AW-1:0] haddr_m,
  output wire    [1:0] htrans_m,
  output wire    [2:0] hsize_m,
  output wire          hwrite_m,
  output wire    [6:0] hprot_m,
  output wire [MW-1:0] hmaster_m,
  output wire          hmastlock_m,
  output wire [DW-1:0] hwdata_m,
  output wire          hexcl_m,
  output wire    [2:0] hburst_m,
  output wire [UW-1:0] hauser_m,
  output wire [UW-1:0] hwuser_m,

  input  wire          hready_m,
  input  wire          hresp_m,
  input  wire          hexokay_m,
  input  wire [DW-1:0] hrdata_m,
  input  wire [UW-1:0] hruser_m
  );

localparam TRN_IDLE   = 2'b00;
localparam TRN_BUSY   = 2'b01;
localparam TRN_NONSEQ = 2'b10;
localparam TRN_SEQ    = 2'b11;

localparam SZ_BYTE    = 3'b000;
localparam SZ_HALF    = 3'b001;
localparam SZ_WORD    = 3'b010;
localparam SZ_DWORD   = 3'b011;
localparam SZ_QWORD   = 3'b100;
localparam SZ_UNUSED0 = 3'b101;
localparam SZ_UNUSED1 = 3'b110;
localparam SZ_UNUSED2 = 3'b111;

localparam BUR_SINGLE = 3'b000;
localparam BUR_INCR   = 3'b001;
localparam BUR_WRAP4  = 3'b010;
localparam BUR_INCR4  = 3'b011;
localparam BUR_WRAP8  = 3'b100;
localparam BUR_INCR8  = 3'b101;
localparam BUR_WRAP16 = 3'b110;
localparam BUR_INCR16 = 3'b111;

localparam RESP_OKAY  = 1'b0;
localparam RESP_ERR   = 1'b1;

localparam FSM_IDLE   = 3'b000;
localparam FSM_UNLOCK = 3'b001;
localparam FSM_ADDR   = 3'b010;
localparam FSM_WAIT   = 3'b011;
localparam FSM_ERR    = 3'b100;
localparam FSM_DONE   = 3'b101;

wire          addr_m_changeable;

reg  [DW-1:0] hwdatam_reg;
reg  [UW-1:0] hwuserm_reg;
reg  [1:0]    htransm_reg;
wire [1:0]    htransm_nxt;
reg  [AW-1:0] haddrm_reg;
wire [AW-1:0] haddrm_nxt;
reg           hmastlockm_reg;
wire          hmastlockm_nxt;
reg           hnonsecm_reg;
wire          hnonsecm_nxt;
reg  [2:0]    hsizem_reg;
wire [2:0]    hsizem_nxt;
reg           hwritem_reg;
wire          hwritem_nxt;
reg  [6:0]    hprotm_reg;
wire [6:0]    hprotm_nxt;
reg  [MW-1:0] hmasterm_reg;
wire [MW-1:0] hmasterm_nxt;
reg           hexclm_reg;
wire          hexclm_nxt;
reg  [UW-1:0] hauserm_reg;
wire [UW-1:0] hauserm_nxt;

wire          hreadyoutm_canc;
wire          hrespm_canc;

reg  [2:0]    master_state, master_state_nxt;
reg           transm_valid;
reg           unlockm_idle_valid;
reg           hwdatam_valid;
reg           hrdatam_valid;


assign  addr_m_changeable = (htransm_reg == TRN_IDLE) | hreadyoutm_canc;


always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    hwdatam_reg <= {DW{1'b0}};
    hwuserm_reg <= {UW{1'b0}};
  end
  else if (hwdatam_valid) begin
    hwdatam_reg <= hwdatas_reg;
    hwuserm_reg <= hwusers_reg;
  end
end

assign hwdata_m = hwdatam_reg;
assign hwuser_m = hwuserm_reg;


generate
  if (BURST == 1) begin: gen_burst_support

    reg [3:0]     next_burst_beat;
    reg [3:0]     burst_beat;
    wire          busy_override;
    wire          busy_addr_valid;

    wire   [2:0]  hburstm_nxt;
    reg    [2:0]  hburstm_reg;

    wire [31:0]   haddrs32_reg;

    reg  [7:0]    wrap_mask;
    reg  [4:0]    add_value;
    wire [31:0]   calc_addr;
    wire          wrapped;
    reg  [3:0]    offset_addr;
    reg  [3:0]    check_addr;
    wire          addr_at_boundary;
    wire [9:0]    incr_addr;

    if (AW < 32) begin: haddr_ext
      assign haddrs32_reg = {{(32-AW){1'b0}}, haddrs_reg};
    end
    else begin: haddr_no_ext
      assign haddrs32_reg = haddrs_reg;
    end

    always @* begin : p_offset_addrcomb
      case (hsizes_reg)
        SZ_BYTE : offset_addr = haddrs32_reg [3:0];
        SZ_HALF : offset_addr = haddrs32_reg [4:1];
        SZ_WORD : offset_addr = haddrs32_reg [5:2];
        SZ_DWORD: offset_addr = haddrs32_reg [6:3];
        SZ_QWORD: offset_addr = haddrs32_reg [7:4];
        SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: offset_addr = {4{1'b0}};
        default : offset_addr = {4{1'bx}};
      endcase
    end

    always @* begin : p_check_addrcomb
      case (hbursts_reg)

        BUR_WRAP4 : begin
          check_addr [1:0] = offset_addr [1:0];
          check_addr [3:2] = 2'b11;
        end

        BUR_WRAP8 : begin
          check_addr [2:0] = offset_addr [2:0];
          check_addr [3] = 1'b1;
        end

        BUR_WRAP16 :
          check_addr [3:0] = offset_addr [3:0];

        BUR_SINGLE, BUR_INCR, BUR_INCR4, BUR_INCR8, BUR_INCR16 :
            check_addr [3:0] = {4{1'b0}};

        default:
            check_addr [3:0] = {4{1'bx}};

      endcase

    end



    assign wrapped = (check_addr == {4{1'b1}}) ? 1'b1 : 1'b0;


    always @* begin : p_add_valuecomb
      case (hsizes_reg)
        SZ_BYTE : add_value = 5'b00001;
        SZ_HALF : add_value = 5'b00010;
        SZ_WORD : add_value = 5'b00100;
        SZ_DWORD: add_value = 5'b01000;
        SZ_QWORD: add_value = 5'b10000;
        SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: add_value = 5'b00000;
        default : add_value = {5{1'bx}};
      endcase
    end

    always @* begin : p_wrap_maskcomb
      case (hbursts_reg)
        BUR_WRAP4 :
          case (hsizes_reg)
            SZ_BYTE : wrap_mask = 8'b11111100;
            SZ_HALF : wrap_mask = 8'b11111000;
            SZ_WORD : wrap_mask = 8'b11110000;
            SZ_DWORD: wrap_mask = 8'b11100000;
            SZ_QWORD: wrap_mask = 8'b11000000;
            SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: wrap_mask = 8'b00000000;
            default : wrap_mask = {8{1'bx}};
          endcase

        BUR_WRAP8 :
          case (hsizes_reg)
            SZ_BYTE : wrap_mask = 8'b11111000;
            SZ_HALF : wrap_mask = 8'b11110000;
            SZ_WORD : wrap_mask = 8'b11100000;
            SZ_DWORD: wrap_mask = 8'b11000000;
            SZ_QWORD: wrap_mask = 8'b10000000;
            SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: wrap_mask = 8'b00000000;
            default : wrap_mask = {8{1'bx}};
          endcase

        BUR_WRAP16 :
          case (hsizes_reg)
            SZ_BYTE : wrap_mask = 8'b11110000;
            SZ_HALF : wrap_mask = 8'b11100000;
            SZ_WORD : wrap_mask = 8'b11000000;
            SZ_DWORD: wrap_mask = 8'b10000000;
            SZ_QWORD: wrap_mask = 8'b00000000;
            SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: wrap_mask = 8'b00000000;
            default : wrap_mask = {8{1'bx}};
          endcase

        BUR_SINGLE ,BUR_INCR ,BUR_INCR4 ,BUR_INCR8 ,BUR_INCR16 :
          wrap_mask = 8'b00000000;

        default :
          wrap_mask = 8'bxxxxxxxx;

      endcase

    end


    assign calc_addr[31:10] = haddrs32_reg[31:10];

    assign incr_addr[9:0] = (haddrs32_reg [9:0] + { {5{1'b0}}, add_value } );
    assign calc_addr[9:0] = wrapped ? {haddrs32_reg[9:8], (haddrs32_reg [7:0] & wrap_mask)} : incr_addr[9:0];


    assign addr_at_boundary = (
          ((haddrs32_reg[9:0] == {10{1'b1}}) |
          ((haddrs32_reg[9:1] ==  {9{1'b1}}) & (hsizes_reg == SZ_HALF)) |
          ((haddrs32_reg[9:2] ==  {8{1'b1}}) & (hsizes_reg == SZ_WORD)) |
          ((haddrs32_reg[9:3] ==  {7{1'b1}}) & (hsizes_reg == SZ_DWORD)) |
          ((haddrs32_reg[9:4] ==  {6{1'b1}}) & (hsizes_reg == SZ_QWORD)))) ;


    always @*
    begin
      case (htranss_reg & {2{~hexcls_reg}})
        TRN_IDLE : next_burst_beat = 4'b0000;

        TRN_BUSY : next_burst_beat = burst_beat;

        TRN_NONSEQ :
          case (hbursts_reg)
            BUR_SINGLE             : next_burst_beat = 4'b0000;
            BUR_INCR4,  BUR_WRAP4  : next_burst_beat = 4'b0011;
            BUR_INCR8,  BUR_WRAP8  : next_burst_beat = 4'b0111;
            BUR_INCR16, BUR_WRAP16 : next_burst_beat = 4'b1111;
            BUR_INCR :
                                     next_burst_beat = addr_at_boundary ? 4'b0000 : 4'b0001;
            default : next_burst_beat = {4{1'bx}};
          endcase

        TRN_SEQ :
          if (hbursts_reg != BUR_INCR) begin
             next_burst_beat = (burst_beat - 4'b0001);
          end
          else begin
             next_burst_beat = addr_at_boundary ? 4'b0000 : burst_beat;
          end

        default : next_burst_beat = {4{1'bx}};

      endcase
    end

    always @ (posedge hclk_m or negedge hresetn_m)
    begin
      if (!hresetn_m) begin
        burst_beat <= 4'b0000;
      end
      else if (transm_valid) begin
        burst_beat <= next_burst_beat;
      end
      else if (bursts_terminate) begin
        burst_beat <= 4'b0000;
      end
    end

    assign busy_override = |burst_beat & ~bursts_terminate;
    assign busy_addr_valid =  busy_override & hwdatam_valid;

    assign htransm_nxt = unlockm_idle_valid  ? TRN_IDLE :
                               transm_valid  ? htranss_reg :
                              busy_override  ? TRN_BUSY :
                                               TRN_IDLE;

    assign haddrm_nxt = unlockm_idle_valid ? haddrm_reg :
                              transm_valid ? haddrs_reg :
                           busy_addr_valid ? calc_addr[AW-1:0] :
                                             haddrm_reg;

    assign hburstm_nxt = transm_valid ? hbursts_reg :
                                        hburstm_reg;


    always @(posedge hclk_m or negedge hresetn_m)
    begin
      if (!hresetn_m)  begin
        hburstm_reg <= 3'h0;
      end
      else if (addr_m_changeable) begin
        hburstm_reg <= hburstm_nxt;
      end
    end

    assign hburst_m = hburstm_reg;

  end
  else begin: gen_burst_not_support

    assign htransm_nxt = unlockm_idle_valid ? TRN_IDLE :
                         transm_valid       ? {htranss_reg[1], 1'b0} :
                                              TRN_IDLE;

    assign haddrm_nxt = transm_valid  ? haddrs_reg :
                                        haddrm_reg;

    assign hburst_m = 3'b000;

  end

endgenerate


assign hmastlockm_nxt = unlockm_idle_valid ? 1'b0 :
                        transm_valid       ? hmastlocks_reg :
                                             hmastlockm_reg;

assign hnonsecm_nxt = transm_valid ? hnonsecs_reg :
                                     hnonsecm_reg;

assign hsizem_nxt = transm_valid ? hsizes_reg :
                                   hsizem_reg;

assign hwritem_nxt = transm_valid ? hwrites_reg :
                                    hwritem_reg;

assign hprotm_nxt = transm_valid ? hprots_reg :
                                   hprotm_reg;

assign hmasterm_nxt = transm_valid ? hmasters_reg :
                                     hmasterm_reg;

assign hexclm_nxt = transm_valid ? hexcls_reg :
                                   1'b0;

assign hauserm_nxt = transm_valid ? hausers_reg :
                                    hauserm_reg;


always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m)  begin
    hnonsecm_reg    <= 1'b0;
    haddrm_reg      <= {AW{1'b0}};
    htransm_reg     <= 2'h0;
    hsizem_reg      <= 3'h0;
    hwritem_reg     <= 1'b0;
    hprotm_reg      <= 7'h0;
    hmasterm_reg    <= {MW{1'b0}};
    hmastlockm_reg  <= 1'b0;
    hexclm_reg      <= 1'b0;
    hauserm_reg     <= {UW{1'b0}};
  end
  else if (addr_m_changeable) begin
    hnonsecm_reg    <= hnonsecm_nxt;
    haddrm_reg      <= haddrm_nxt;
    htransm_reg     <= htransm_nxt;
    hsizem_reg      <= hsizem_nxt;
    hwritem_reg     <= hwritem_nxt;
    hprotm_reg      <= hprotm_nxt;
    hmasterm_reg    <= hmasterm_nxt;
    hmastlockm_reg  <= hmastlockm_nxt;
    hexclm_reg      <= hexclm_nxt;
    hauserm_reg     <= hauserm_nxt;
  end
end


assign hnonsec_m    = hnonsecm_reg;
assign haddr_m      = haddrm_reg;
assign hsize_m      = hsizem_reg;
assign hwrite_m     = hwritem_reg;
assign hprot_m      = hprotm_reg;
assign hmaster_m    = hmasterm_reg;
assign hmastlock_m  = hmastlockm_reg;
assign hexcl_m      = hexclm_reg;
assign hauser_m     = hauserm_reg;



generate
  if (BURST == 1)  begin: gen_with_err_canc

    sie200_ahb5_error_canc
      u_ahb5_to_ahb5_sync_down_err_canc
      (
       .hclk       (hclk_m),
       .hresetn    (hresetn_m),
       .htrans_s   (htransm_reg),
       .hready_m   (hready_m),
       .hresp_m    (hresp_m),
       .hreadyout_s(hreadyoutm_canc),
       .hresp_s    (hrespm_canc),
       .htrans_m   (htrans_m)
      );
  end
   else begin: gen_no_err_canc
     assign  hrespm_canc     = hresp_m;
     assign  hreadyoutm_canc = hready_m;
     assign  htrans_m        = htransm_reg;
   end
endgenerate


always @ *
begin
  master_state_nxt = master_state;
  transm_valid = 1'b0;
  transm_done = 1'b0;
  unlockm_idle_valid = 1'b0;
  hwdatam_valid = 1'b0;
  hrdatam_valid = 1'b0;
  case (master_state)
    FSM_IDLE:
      begin
        unlockm_idle_valid = unlocks_req;
        if (transs_req) begin
          master_state_nxt = unlocks_req ? FSM_UNLOCK : FSM_ADDR;
          transm_valid = ~unlocks_req;
        end
      end

    FSM_UNLOCK:
      begin
        master_state_nxt = FSM_ADDR;
        transm_valid = 1'b1;
      end

    FSM_ADDR:
      begin
        if (hreadyoutm_canc) begin
          master_state_nxt = FSM_WAIT;
          hwdatam_valid = 1'b1;
        end
      end

    FSM_WAIT:
      begin
        if (hrespm_canc) begin
          master_state_nxt = FSM_ERR;
        end
        else if (hreadyoutm_canc) begin
          master_state_nxt = FSM_DONE;
          hrdatam_valid = 1'b1;
        end
      end

    FSM_ERR:
      begin
        if (hreadyoutm_canc) begin
          master_state_nxt = FSM_DONE;
          hrdatam_valid = 1'b1;
        end
      end

    FSM_DONE:
      begin
        master_state_nxt = transs_req ? FSM_DONE : FSM_IDLE;
        transm_done = 1'b1;
      end

    default:
      begin
        master_state_nxt = 3'bxxx;
        transm_valid = 1'bx;
        transm_done = 1'bx;
        unlockm_idle_valid = 1'bx;
        hwdatam_valid = 1'bx;
        hrdatam_valid = 1'bx;
      end
  endcase
end

always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    master_state <= FSM_IDLE;
  end
  else begin
    master_state <= master_state_nxt;
  end
end

always @(posedge hclk_m or negedge hresetn_m)
begin
  if (!hresetn_m) begin
    hrespm_reg <= RESP_OKAY;
    hexokaym_reg <= 1'b0;
    hrdatam_reg <= {DW{1'b0}};
    hruserm_reg <= {UW{1'b0}};
  end
  else if (brg_pwr_req_m) begin
    hrespm_reg <= RESP_OKAY;
    hexokaym_reg <= 1'b0;
    hrdatam_reg <= {DW{1'b0}};
    hruserm_reg <= {UW{1'b0}};
  end
  else if (hrdatam_valid) begin
    hrespm_reg <= hrespm_canc;
    hexokaym_reg <= hexokay_m;
    hrdatam_reg <= hrdata_m;
    hruserm_reg <= hruser_m;
  end
end



endmodule





