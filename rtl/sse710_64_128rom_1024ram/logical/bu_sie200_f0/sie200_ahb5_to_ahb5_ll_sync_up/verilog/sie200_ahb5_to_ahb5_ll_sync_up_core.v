//-----------------------------------------------------------------------------
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
//      Checked In          : Mon Mar 6 17:17:13 2017 +0100
//
//      Revision            : 5038e91
//
//      Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
//-----------------------------------------------------------------------------


module sie200_ahb5_to_ahb5_ll_sync_up_core #(

 parameter ADDR_WIDTH    = 32,
 parameter DATA_WIDTH    = 32,
 parameter MASTER_WIDTH  = 4,
 parameter USER_WIDTH    = 1,
 parameter BURST         = 0
 )
(
  input  wire                    hclk,
  input  wire                    hresetn,
  input  wire                    hclk_en,

  input  wire                    hsel_s,
  input  wire                    hnonsec_s,
  input  wire [ADDR_WIDTH-1:0]   haddr_s,
  input  wire    [1:0]           htrans_s,
  input  wire    [2:0]           hsize_s,
  input  wire                    hwrite_s,
  input  wire                    hready_s,
  input  wire    [6:0]           hprot_s,
  input  wire    [2:0]           hburst_s,
  input  wire                    hmastlock_s,
  input  wire                    hexcl_s,
  input  wire [DATA_WIDTH-1:0]   hwdata_s,
  input  wire [MASTER_WIDTH-1:0] hmaster_s,
  input  wire [USER_WIDTH-1:0]   hauser_s,
  input  wire [USER_WIDTH-1:0]   hwuser_s,

  output wire [DATA_WIDTH-1:0]   hrdata_s,
  output wire                    hreadyout_s,
  output wire                    hresp_s,
  output wire                    hexokay_s,
  output wire [USER_WIDTH-1:0]   hruser_s,


  output wire                    hnonsec_m,
  output wire [ADDR_WIDTH-1:0]   haddr_m,
  output wire   [1:0]            htrans_m,
  output wire   [2:0]            hsize_m,
  output wire                    hwrite_m,
  output wire   [6:0]            hprot_m,
  output wire   [2:0]            hburst_m,
  output wire                    hmastlock_m,
  output wire [DATA_WIDTH-1:0]   hwdata_m,
  output wire                    hexcl_m,
  output wire [MASTER_WIDTH-1:0] hmaster_m,
  output wire [USER_WIDTH-1:0]   hauser_m,
  output wire [USER_WIDTH-1:0]   hwuser_m,

  input  wire [DATA_WIDTH-1:0]   hrdata_m,
  input  wire                    hready_m,
  input  wire                    hresp_m,
  input  wire                    hexokay_m,
  input  wire [USER_WIDTH-1:0]   hruser_m
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
  localparam FSM_IDLE       = 3'b000;
  localparam FSM_WAIT_WDATA = 3'b001;
  localparam FSM_UNLOCK     = 3'b010;
  localparam FSM_BUSY       = 3'b011;
  localparam FSM_ERR        = 3'b100;
  localparam FSM_SYNC       = 3'b101;


  reg                     hold_hnonsec_reg;
  reg  [ADDR_WIDTH-1:0]   hold_haddr_reg;
  reg                     hold_htransbit0_reg;
  reg                     hold_hwrite_reg;
  reg  [2:0]              hold_hsize_reg;
  reg  [6:0]              hold_hprot_reg;
  reg  [MASTER_WIDTH-1:0] hold_hmaster_reg;
  reg                     hold_hmastlock_reg;
  reg  [2:0]              hold_hburst_reg;
  reg                     hold_hexcl_reg;
  reg  [USER_WIDTH-1:0]   hold_hauser_reg;

  wire                    next_hnonsecm;
  wire [ADDR_WIDTH-1:0]   next_haddrm;
  wire                    next_hwritem;
  wire [2:0]              next_hsizem;
  wire [6:0]              next_hprotm;
  wire [MASTER_WIDTH-1:0] next_hmasterm;
  wire                    next_hmastlockm;
  wire [1:0]              next_htransm;
  wire                    next_hexclm;
  wire [USER_WIDTH-1:0]   next_hauserm;

  wire [1:0] htransm_reg = next_htransm;

  wire                   next_hresps;
  reg                    hresps_reg;
  wire                   next_hreadyouts;
  reg                    hreadyouts_reg;
  reg                    hexokays_reg;
  reg  [DATA_WIDTH-1:0]  hrdata_reg;
  reg  [USER_WIDTH-1:0]  hruser_reg;

  reg  [2:0]             reg_fsm_state;
  reg  [2:0]             next_fsm_state;
  wire                   trans_update;

  wire                   trans_req;
  wire                   rdtrans_req;
  wire                   wrtrans_req;
  wire                   trans_finish_addr;
  wire                   wrtrans_finish_addr;
  wire                   rdtrans_finish_addr;

  wire                   trans_req_m;
  wire                   rdtrans_req_m;
  wire                   wrtrans_req_m;
  reg                    trans_req_m_data;
  reg                    rdtrans_req_m_data;
  wire                   trans_finish_m_addr;
  wire                   trans_finish_m_data;
  wire                   rdtrans_finish_m_data;
  wire                   wrtrans_finish_m_addr;


  reg  [DATA_WIDTH-1:0]  hwdata_reg;
  reg  [USER_WIDTH-1:0]  hwuser_reg;
  wire                   data_update_write;

  reg                    addr_hold_reg;

  wire  [1:0]            htransm_canc;
  wire                   hreadyoutm_canc;
  wire                   hrespm_canc;

  reg                    lock_trans_valid;
  wire                   unlocks_idle_valid;
  wire                   unlockm_idle_valid;


  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       lock_trans_valid   <= 1'b0;
    end
    else if (hclk_en) begin
       if (trans_finish_addr & hmastlock_s) begin
          lock_trans_valid   <= 1'b1;
       end
       else if (hready_s &((hsel_s & (~hmastlock_s)) | (~hsel_s))) begin
          lock_trans_valid   <= 1'b0;
       end
    end
  end

  assign unlocks_idle_valid =  hready_s & lock_trans_valid & (((~hmastlock_s) & hsel_s)
                             | (~hsel_s));


  assign unlockm_idle_valid = (unlocks_idle_valid ) & hclk_en ;



  assign trans_req          = hsel_s & htrans_s[1];
  assign rdtrans_req        = trans_req & (~hwrite_s );
  assign wrtrans_req        = trans_req & (hwrite_s );

  assign trans_finish_addr  = trans_req & hready_s;

  assign rdtrans_finish_addr = rdtrans_req & hready_s;
  assign wrtrans_finish_addr = wrtrans_req & hready_s;


  assign trans_req_m   = htransm_reg[1];
  assign rdtrans_req_m = htransm_reg[1] & (~hwrite_m);
  assign wrtrans_req_m = htransm_reg[1] & hwrite_m;

  assign trans_finish_m_addr   = trans_req_m & hreadyoutm_canc;
  assign wrtrans_finish_m_addr = wrtrans_req_m & hreadyoutm_canc;

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       trans_req_m_data <= 1'b0;
       rdtrans_req_m_data <= 1'b0;
    end
    else if (hreadyoutm_canc)  begin
       trans_req_m_data <= trans_req_m;
       rdtrans_req_m_data <= rdtrans_req_m;
    end
  end

  assign trans_finish_m_data = trans_req_m_data & hreadyoutm_canc;
  assign rdtrans_finish_m_data = rdtrans_req_m_data & hreadyoutm_canc;


  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
        addr_hold_reg <= 1'b0;
    end
    else if (hclk_en) begin
      if ((trans_finish_addr) & (~trans_finish_m_addr)) begin
        addr_hold_reg <= 1'b1;
      end
      else if ((~trans_finish_addr) & (trans_finish_m_addr)) begin
        addr_hold_reg <= 1'b0;
      end
    end
    else if (trans_finish_m_addr) begin
        addr_hold_reg <= 1'b0;
    end
  end

 always @(posedge hclk or negedge hresetn) begin
   if (~hresetn) begin
       hold_hnonsec_reg    <= 1'b0;
       hold_haddr_reg      <= {ADDR_WIDTH{1'b0}};
       hold_htransbit0_reg <= 1'b0;
       hold_hsize_reg      <= {3{1'b0}};
       hold_hwrite_reg     <= 1'b0;
       hold_hprot_reg      <= {7{1'b0}};
       hold_hmaster_reg    <= {MASTER_WIDTH{1'b0}};
       hold_hburst_reg     <= BUR_SINGLE;
       hold_hmastlock_reg  <= 1'b0;
       hold_hexcl_reg      <= 1'b0;
       hold_hauser_reg     <= {USER_WIDTH{1'b0}};
   end
   else if (trans_finish_addr & hclk_en) begin
       hold_hnonsec_reg    <= hnonsec_s;
       hold_haddr_reg      <= haddr_s;
       hold_htransbit0_reg <= htrans_s[0];
       hold_hsize_reg      <= hsize_s;
       hold_hwrite_reg     <= hwrite_s;
       hold_hprot_reg      <= hprot_s;
       hold_hmaster_reg    <= hmaster_s;
       hold_hburst_reg     <= hburst_s;
       hold_hmastlock_reg  <= hmastlock_s;
       hold_hexcl_reg      <= hexcl_s;
       hold_hauser_reg     <= hauser_s;
   end
   else if (unlockm_idle_valid) begin
       hold_hnonsec_reg    <= 1'b0;
       hold_haddr_reg      <= {ADDR_WIDTH{1'b0}};
       hold_htransbit0_reg <= 1'b0;
       hold_hsize_reg      <= {3{1'b0}};
       hold_hwrite_reg     <= 1'b0;
       hold_hprot_reg      <= {7{1'b0}};
       hold_hmaster_reg    <= {MASTER_WIDTH{1'b0}};
       hold_hburst_reg     <= BUR_SINGLE;
       hold_hmastlock_reg  <= 1'b0;
       hold_hexcl_reg      <= 1'b0;
       hold_hauser_reg     <= {USER_WIDTH{1'b0}};
   end
 end




  assign data_update_write = (hclk_en & wrtrans_finish_m_addr);

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hwdata_reg <= {DATA_WIDTH{1'b0}};
      hwuser_reg <= {USER_WIDTH{1'b0}};
    end
    else if (data_update_write ) begin
      hwdata_reg <= hwdata_s;
      hwuser_reg <= hwuser_s;
    end
  end



  always @* begin
    case (reg_fsm_state)
      FSM_IDLE:begin
                    next_fsm_state = ~hclk_en  ? FSM_IDLE       :
                          wrtrans_finish_addr  ? FSM_WAIT_WDATA :
                          ~rdtrans_finish_addr ? FSM_IDLE       :
                          unlockm_idle_valid   ? FSM_UNLOCK     :
                                                 FSM_BUSY;
               end
      FSM_UNLOCK:begin
                     next_fsm_state = FSM_BUSY;
               end
      FSM_WAIT_WDATA:begin
                     next_fsm_state = hclk_en ? FSM_BUSY :
                                                FSM_WAIT_WDATA;

               end
      FSM_BUSY:begin
                     next_fsm_state = hrespm_canc      ?  FSM_ERR  :
                                      ~hreadyoutm_canc ?  FSM_BUSY :
                                      hclk_en          ?  FSM_IDLE :
                                                          FSM_SYNC;
               end
      FSM_SYNC:begin
                     next_fsm_state = hclk_en ? FSM_IDLE : FSM_SYNC;
               end
      FSM_ERR:begin
                     next_fsm_state = ~hclk_en ? FSM_ERR  :
                         (hresp_s == RESP_ERR) ? FSM_IDLE :
                                                 FSM_ERR;

               end
      default : next_fsm_state = 3'bxxx;
    endcase
  end

  always @(posedge hclk or negedge hresetn) begin
    if (~hresetn)
      reg_fsm_state <= FSM_IDLE;
    else
      reg_fsm_state <= next_fsm_state;
  end




generate
 if (BURST == 1) begin: gen_burst_support_addr


   reg [3:0]     next_burst_beat;
   reg [3:0]     burst_beat;
   wire          busy_override;

   wire   [2:0]  next_hburstm;


   wire [31:0]   hold_haddr32_reg;

   reg  [7:0]    wrap_mask;
   reg  [4:0]    add_value;
   wire [31:0]   calc_addr;
   wire          wrapped;
   reg  [3:0]    offset_addr;
   reg  [3:0]    check_addr;
   wire          addr_at_boundary;
   wire [9:0]    incr_addr;

   if (ADDR_WIDTH < 32) begin: haddr_ext
     assign hold_haddr32_reg = {{(32-ADDR_WIDTH){1'b0}}, hold_haddr_reg};
   end
   else begin: haddr_no_ext
     assign hold_haddr32_reg = hold_haddr_reg;
   end

   reg  [9:0]    next_calc_addr1k;
   reg  [9:0]    calc_addr1k_reg;

   always @* begin : p_offset_addrcomb
     case (hsize_m)
       SZ_BYTE : offset_addr = haddr_m [3:0];
       SZ_HALF : offset_addr = haddr_m [4:1];
       SZ_WORD : offset_addr = haddr_m [5:2];
       SZ_DWORD: offset_addr = haddr_m [6:3];
       SZ_QWORD: offset_addr = haddr_m [7:4];
       SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: offset_addr = {4{1'b0}};
       default : offset_addr = {4{1'bx}};
     endcase
   end

   always @* begin : p_check_addrcomb
     case (hburst_m)

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
      case (hsize_m)
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
      case (hburst_m)
        BUR_WRAP4 :
          case (hsize_m)
            SZ_BYTE : wrap_mask = 8'b11111100;
            SZ_HALF : wrap_mask = 8'b11111000;
            SZ_WORD : wrap_mask = 8'b11110000;
            SZ_DWORD: wrap_mask = 8'b11100000;
            SZ_QWORD: wrap_mask = 8'b11000000;
            SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: wrap_mask = 8'b00000000;
            default : wrap_mask = {8{1'bx}};
          endcase

        BUR_WRAP8 :
          case (hsize_m)
            SZ_BYTE : wrap_mask = 8'b11111000;
            SZ_HALF : wrap_mask = 8'b11110000;
            SZ_WORD : wrap_mask = 8'b11100000;
            SZ_DWORD: wrap_mask = 8'b11000000;
            SZ_QWORD: wrap_mask = 8'b10000000;
            SZ_UNUSED0, SZ_UNUSED1, SZ_UNUSED2: wrap_mask = 8'b00000000;
            default : wrap_mask = {8{1'bx}};
          endcase

        BUR_WRAP16 :
          case (hsize_m)
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

   assign calc_addr[31:10] = hold_haddr32_reg[31:10];

   assign calc_addr[9:0] = calc_addr1k_reg[9:0];
   assign incr_addr[9:0] = (haddr_m[9:0] + {{5{1'b0}}, add_value});

   always @ * begin : p_calc_addrcomb
     if (htransm_reg[1] & hreadyoutm_canc) begin
       if (wrapped) begin
         next_calc_addr1k[9:8] = haddr_m[9:8];
         next_calc_addr1k[7:0] = (haddr_m[7:0] & wrap_mask);
       end
       else begin
         next_calc_addr1k[9:0] = incr_addr[9:0];
       end
     end
     else begin
       next_calc_addr1k[9:0] = haddr_m[9:0];
     end
   end

   always @ (posedge hclk or negedge hresetn) begin
     if (~hresetn) begin
         calc_addr1k_reg <= {10{1'b0}};
     end
     else begin
         calc_addr1k_reg <= next_calc_addr1k;
     end
   end

   assign addr_at_boundary = (
         ((haddr_m[9:0] == {10{1'b1}}) |
         ((haddr_m[9:1] ==  {9{1'b1}}) & (hsize_m == SZ_HALF)) |
         ((haddr_m[9:2] ==  {8{1'b1}}) & (hsize_m == SZ_WORD)) |
         ((haddr_m[9:3] ==  {7{1'b1}}) & (hsize_m == SZ_DWORD))|
         ((haddr_m[9:4] ==  {6{1'b1}}) & (hsize_m == SZ_QWORD))));


   always @*  begin
     case (htransm_reg & {2{~next_hexclm}})

       TRN_IDLE : next_burst_beat = 4'b0000;

       TRN_BUSY : next_burst_beat = burst_beat;

       TRN_NONSEQ :
         case (hburst_m)
           BUR_SINGLE             : next_burst_beat = 4'b0000;
           BUR_INCR4,  BUR_WRAP4  : next_burst_beat = 4'b0011;
           BUR_INCR8,  BUR_WRAP8  : next_burst_beat = 4'b0111;
           BUR_INCR16, BUR_WRAP16 : next_burst_beat = 4'b1111;
           BUR_INCR :
                                    next_burst_beat = addr_at_boundary ? 4'b0000 : 4'b0001;
           default : next_burst_beat = 4'bxxxx;
         endcase


       TRN_SEQ :
         if (hreadyoutm_canc) begin
           if (hburst_m != BUR_INCR) begin
             next_burst_beat = (burst_beat - 4'b0001);
           end
           else begin
              next_burst_beat = addr_at_boundary ? 4'b0000 : burst_beat;
           end
         end
         else begin
           next_burst_beat = burst_beat;
         end

       default: next_burst_beat = 4'bxxxx;

     endcase
   end

   always @ (posedge hclk or negedge hresetn) begin
     if (~hresetn) begin
       burst_beat <= 4'b0000;
     end
     else begin
       burst_beat <= next_burst_beat;
     end
   end


   assign    busy_override = (hclk_en & ((~hsel_s | (htrans_s == TRN_IDLE) | (htrans_s == TRN_NONSEQ)) & hready_s)) ? 1'b0 :
                             ((|burst_beat) == 1'b1) ;


   assign    next_htransm =
                            unlockm_idle_valid ?  TRN_IDLE :
                            trans_update       ? (addr_hold_reg ? {1'b1, hold_htransbit0_reg} : htrans_s) :
                            busy_override      ?  TRN_BUSY :
                                                  TRN_IDLE;

   assign    next_haddrm  =
                            trans_update       ? (addr_hold_reg ? hold_haddr_reg : haddr_s ) :
                            busy_override      ?  calc_addr[ADDR_WIDTH-1:0] :
                                                  hold_haddr_reg;

   assign    next_hburstm =
                            trans_update       ? (addr_hold_reg ? hold_hburst_reg : hburst_s) :
                                                 hold_hburst_reg;

   assign    htrans_m      = htransm_canc;

   assign    hburst_m      = next_hburstm;

 end
 else  begin : gen_no_burst_support
   assign     next_haddrm = trans_update ? (addr_hold_reg ? hold_haddr_reg : haddr_s) :
                                            hold_haddr_reg ;

   assign    next_htransm = unlockm_idle_valid ? TRN_IDLE :
                            trans_update       ? TRN_NONSEQ :
                                                 TRN_IDLE;


   assign     htrans_m     = htransm_canc;

   assign     hburst_m     = 3'b000;

 end

endgenerate


  assign   trans_update =
                         (reg_fsm_state == FSM_UNLOCK) |
                         (rdtrans_finish_addr & hclk_en & (reg_fsm_state == FSM_IDLE )) |
                         (hclk_en & (reg_fsm_state == FSM_WAIT_WDATA));

  assign   next_hnonsecm   = ~trans_update ? hold_hnonsec_reg:
                             addr_hold_reg ? hold_hnonsec_reg:
                                             hnonsec_s;
  assign   next_hsizem     = ~trans_update ? hold_hsize_reg  :
                             addr_hold_reg ? hold_hsize_reg  :
                                             hsize_s;
  assign   next_hwritem    = ~trans_update ? hold_hwrite_reg :
                             addr_hold_reg ? hold_hwrite_reg :
                                             hwrite_s;
  assign   next_hprotm     = ~trans_update ? hold_hprot_reg  :
                             addr_hold_reg ? hold_hprot_reg  :
                                             hprot_s;
  assign   next_hmasterm   = ~trans_update ? hold_hmaster_reg:
                             addr_hold_reg ? hold_hmaster_reg:
                                             hmaster_s;
  assign   next_hexclm     = ~trans_update ? hold_hexcl_reg  :
                             addr_hold_reg ? hold_hexcl_reg  :
                                             hexcl_s;
  assign   next_hauserm    = ~trans_update ? hold_hauser_reg :
                             addr_hold_reg ? hold_hauser_reg :
                                             hauser_s;

  assign   next_hmastlockm = unlockm_idle_valid ? 1'b0               :
                             ~trans_update      ? hold_hmastlock_reg :
                             addr_hold_reg      ? hold_hmastlock_reg :
                                                 hmastlock_s ;

  assign  next_hreadyouts = (hclk_en == 1'b0) ? hreadyouts_reg :
                            ((next_fsm_state == FSM_BUSY)       |
                             (next_fsm_state == FSM_UNLOCK)     |
                             (next_fsm_state == FSM_WAIT_WDATA) |
                             ((next_fsm_state == FSM_ERR) & (hresp_s == RESP_OKAY))
                            )? 1'b0 :
                               1'b1;

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       hreadyouts_reg <= 1'b1;
    end
    else if (hclk_en) begin
       hreadyouts_reg <= next_hreadyouts;
    end
  end


  assign  next_hresps = (reg_fsm_state == FSM_ERR)? RESP_ERR : RESP_OKAY;

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       hresps_reg    <= RESP_OKAY;
    end
    else if (hclk_en) begin
       hresps_reg    <= next_hresps;
    end
  end

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
       hrdata_reg <= {DATA_WIDTH{1'b0}};
       hruser_reg <= {USER_WIDTH{1'b0}};
    end
    else if (rdtrans_finish_m_data) begin
       hrdata_reg <= hrdata_m;
       hruser_reg <= hruser_m;
    end
  end

  always @ (posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
      hexokays_reg <= 1'b0;
    end
    else if (hreadyouts_reg & hclk_en) begin
      hexokays_reg <= 1'b0;
    end
    else if (trans_finish_m_data) begin
      hexokays_reg <= hexokay_m;
    end
  end


  assign hreadyout_s   = hreadyouts_reg;
  assign hresp_s       = hresps_reg;
  assign hrdata_s      = hrdata_reg;
  assign hexokay_s     = hexokays_reg & hreadyouts_reg;
  assign hruser_s      = hruser_reg;

  assign hnonsec_m     = next_hnonsecm;
  assign haddr_m       = next_haddrm;
  assign hsize_m       = next_hsizem;
  assign hwrite_m      = next_hwritem;
  assign hprot_m       = next_hprotm;
  assign hmaster_m     = next_hmasterm;
  assign hmastlock_m   = next_hmastlockm;
  assign hexcl_m       = next_hexclm;
  assign hauser_m      = next_hauserm;
  assign hwdata_m      = hwdata_reg;
  assign hwuser_m      = hwuser_reg;


generate
  if (BURST == 1) begin: gen_with_error_canc

   sie200_ahb5_ll_error_canc
     u_ahb5_ll_error_canc
     (
      .hclk       (hclk),
      .hclk_en    (1'b1),
      .hresetn    (hresetn),
      .htrans_s   (htransm_reg),
      .hready_m   (hready_m),
      .hresp_m    (hresp_m),
      .hreadyout_s(hreadyoutm_canc),
      .hresp_s    (hrespm_canc),
      .htrans_m   (htransm_canc)
     );
  end
  else begin: gen_no_error_canc
     assign  hrespm_canc     = hresp_m;
     assign  hreadyoutm_canc = hready_m;
     assign  htransm_canc    = htransm_reg;
  end
endgenerate









































































endmodule



