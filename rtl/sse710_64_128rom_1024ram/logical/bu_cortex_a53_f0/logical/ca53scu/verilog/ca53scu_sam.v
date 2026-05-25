//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Description:
//  RN SAM (system address map) - Combinatorial transaction address decode
//-----------------------------------------------------------------------------
`include "ca53scu_defs.v"
`include "cortexa53params.v"

module ca53scu_sam #(`CA53_SCU_INT_PARAM_DECL)
 (
  // True Inputs
  input  wire [39:6]   tagctl_sam_addr_tc2_i, // Physical Address
  input  wire          tagctl_mn_op_tc2_i,    // Whether opcode requires route to MN

  // Straps
  input  wire [39:24]  ext_sammnbase_i,       // Address offset of MN
  input  wire [1:0]    ext_samaddrmap0_i,     //     0 - 512MB  Region Mapping
  input  wire [1:0]    ext_samaddrmap1_i,     // 512MB - 1GB    Region Mapping
  input  wire [1:0]    ext_samaddrmap2_i,     //   1GB - 1.5GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap3_i,     // 1.5GB - 2GB    Region Mapping
  input  wire [1:0]    ext_samaddrmap4_i,     //   2GB - 2.5GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap5_i,     // 2.5GB - 3GB    Region Mapping
  input  wire [1:0]    ext_samaddrmap6_i,     //   3GB - 3.5GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap7_i,     // 3.5GB - 4GB    Region Mapping
  input  wire [1:0]    ext_samaddrmap8_i,     //   4GB - 8GB    Region Mapping
  input  wire [1:0]    ext_samaddrmap9_i,     //   8GB - 16GB   Region Mapping
  input  wire [1:0]    ext_samaddrmap10_i,    //  16GB - 32GB   Region Mapping
  input  wire [1:0]    ext_samaddrmap11_i,    //  32GB - 64GB   Region Mapping
  input  wire [1:0]    ext_samaddrmap12_i,    //  64GB - 128GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap13_i,    // 128GB - 256GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap14_i,    // 256GB - 512GB  Region Mapping
  input  wire [1:0]    ext_samaddrmap15_i,    // 512GB - 1TB    Region Mapping
  input  wire [6:0]    ext_sammnnodeid_i,     // TGTID of MN
  input  wire [6:0]    ext_samhni0nodeid_i,   // TGTID of HN-I 0
  input  wire [6:0]    ext_samhni1nodeid_i,   // TGTID of HN-I 1
  input  wire [6:0]    ext_samhnf0nodeid_i,   // TGTID of HN-F 0
  input  wire [6:0]    ext_samhnf1nodeid_i,   // TGTID of HN-F 1
  input  wire [6:0]    ext_samhnf2nodeid_i,   // TGTID of HN-F 2
  input  wire [6:0]    ext_samhnf3nodeid_i,   // TGTID of HN-F 3
  input  wire [6:0]    ext_samhnf4nodeid_i,   // TGTID of HN-F 4
  input  wire [6:0]    ext_samhnf5nodeid_i,   // TGTID of HN-F 5
  input  wire [6:0]    ext_samhnf6nodeid_i,   // TGTID of HN-F 6
  input  wire [6:0]    ext_samhnf7nodeid_i,   // TGTID of HN-F 7
  input  wire [2:0]    ext_samhnfmode_i,      // No. of HN-Fs, encoded

  // Outputs
  output wire [6:0]    sam_tgtid_tc2_o        // TGTID of transaction
);

generate if (ACE) begin : g_ace

  assign sam_tgtid_tc2_o = {7{1'b0}};

end else begin : g_skyros

  // Internal wire declarations
  wire   [15:0]   addr_region;    // 1h indicator of address range
  wire   [15:0]   addr_map [3:0]; // decoded address mapping
  wire            hnfs;
  wire            hni0;
  wire            hni1;
  wire            mn;
  wire    [6:0]   hnf_tgtid;
  wire    [7:0]   hnf_dec;
  wire    [2:0]   stripe_address;
  wire    [2:0]   stripe_address_8hn;
  wire    [1:0]   stripe_address_4hn;
  wire            stripe_address_2hn;

  // address to region decode
  assign addr_region[0]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000000);
  assign addr_region[1]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000001);
  assign addr_region[2]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000010);
  assign addr_region[3]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000011);
  assign addr_region[4]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000100);
  assign addr_region[5]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000101);
  assign addr_region[6]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000110);
  assign addr_region[7]  = (tagctl_sam_addr_tc2_i[39:29] == 11'b00000000111);
  assign addr_region[8]  = (tagctl_sam_addr_tc2_i[39:32] ==  8'b00000001);
  assign addr_region[9]  = (tagctl_sam_addr_tc2_i[39:33] ==  7'b0000001);
  assign addr_region[10] = (tagctl_sam_addr_tc2_i[39:34] ==  6'b000001);
  assign addr_region[11] = (tagctl_sam_addr_tc2_i[39:35] ==  5'b00001);
  assign addr_region[12] = (tagctl_sam_addr_tc2_i[39:36] ==  4'b0001);
  assign addr_region[13] = (tagctl_sam_addr_tc2_i[39:37] ==  3'b001);
  assign addr_region[14] = (tagctl_sam_addr_tc2_i[39:38] ==  2'b01);
  assign addr_region[15] = (tagctl_sam_addr_tc2_i[39:39] ==  1'b1);

  // Region to master mapping based on static addr_map inputs
  // 00 - HN(s)
  // 01 - HN-I 0
  // 10 - HN-I 1
  // 11 - RESERVED
  assign {addr_map[3][0], addr_map[2][0], addr_map[1][0], addr_map[0][0]}  = (4'b0001 << ext_samaddrmap0_i);
  assign {addr_map[3][1], addr_map[2][1], addr_map[1][1], addr_map[0][1]}  = (4'b0001 << ext_samaddrmap1_i);
  assign {addr_map[3][2], addr_map[2][2], addr_map[1][2], addr_map[0][2]}  = (4'b0001 << ext_samaddrmap2_i);
  assign {addr_map[3][3], addr_map[2][3], addr_map[1][3], addr_map[0][3]}  = (4'b0001 << ext_samaddrmap3_i);
  assign {addr_map[3][4], addr_map[2][4], addr_map[1][4], addr_map[0][4]}  = (4'b0001 << ext_samaddrmap4_i);
  assign {addr_map[3][5], addr_map[2][5], addr_map[1][5], addr_map[0][5]}  = (4'b0001 << ext_samaddrmap5_i);
  assign {addr_map[3][6], addr_map[2][6], addr_map[1][6], addr_map[0][6]}  = (4'b0001 << ext_samaddrmap6_i);
  assign {addr_map[3][7], addr_map[2][7], addr_map[1][7], addr_map[0][7]}  = (4'b0001 << ext_samaddrmap7_i);
  assign {addr_map[3][8], addr_map[2][8], addr_map[1][8], addr_map[0][8]}  = (4'b0001 << ext_samaddrmap8_i);
  assign {addr_map[3][9], addr_map[2][9], addr_map[1][9], addr_map[0][9]}  = (4'b0001 << ext_samaddrmap9_i);
  assign {addr_map[3][10],addr_map[2][10],addr_map[1][10],addr_map[0][10]} = (4'b0001 << ext_samaddrmap10_i);
  assign {addr_map[3][11],addr_map[2][11],addr_map[1][11],addr_map[0][11]} = (4'b0001 << ext_samaddrmap11_i);
  assign {addr_map[3][12],addr_map[2][12],addr_map[1][12],addr_map[0][12]} = (4'b0001 << ext_samaddrmap12_i);
  assign {addr_map[3][13],addr_map[2][13],addr_map[1][13],addr_map[0][13]} = (4'b0001 << ext_samaddrmap13_i);
  assign {addr_map[3][14],addr_map[2][14],addr_map[1][14],addr_map[0][14]} = (4'b0001 << ext_samaddrmap14_i);
  assign {addr_map[3][15],addr_map[2][15],addr_map[1][15],addr_map[0][15]} = (4'b0001 << ext_samaddrmap15_i);

  assign mn   =  tagctl_mn_op_tc2_i | (tagctl_sam_addr_tc2_i[39:24] == ext_sammnbase_i);
  assign hnfs = (|(addr_region & addr_map[0])) & ~mn; // address decodes to HN-F's
  assign hni0 = (|(addr_region & addr_map[1])) & ~mn;
  assign hni1 = (|(addr_region & addr_map[2])) & ~mn;
  // addr_map[3] is reserved

  // hnf_mode Encoding:
  //   3'b000: 1 HN-Fs
  //   3'b001: 2 HN-Fs
  //   3'b010: 4 HN-Fs
  //   3'b100: 8 HN-Fs
  //   else:   RESERVED
  assign stripe_address_8hn = {2'b00,tagctl_sam_addr_tc2_i[39]} ^ tagctl_sam_addr_tc2_i[38:36] ^ tagctl_sam_addr_tc2_i[35:33] ^
                                   tagctl_sam_addr_tc2_i[32:30] ^ tagctl_sam_addr_tc2_i[29:27] ^ tagctl_sam_addr_tc2_i[26:24] ^
                                   tagctl_sam_addr_tc2_i[23:21] ^ tagctl_sam_addr_tc2_i[20:18] ^ tagctl_sam_addr_tc2_i[17:15] ^
                                   tagctl_sam_addr_tc2_i[14:12] ^ tagctl_sam_addr_tc2_i[11:9]  ^ tagctl_sam_addr_tc2_i[8:6];

  assign stripe_address_4hn = tagctl_sam_addr_tc2_i[39:38] ^ tagctl_sam_addr_tc2_i[37:36] ^
                              tagctl_sam_addr_tc2_i[35:34] ^ tagctl_sam_addr_tc2_i[33:32] ^ tagctl_sam_addr_tc2_i[31:30] ^
                              tagctl_sam_addr_tc2_i[29:28] ^ tagctl_sam_addr_tc2_i[27:26] ^ tagctl_sam_addr_tc2_i[25:24] ^
                              tagctl_sam_addr_tc2_i[23:22] ^ tagctl_sam_addr_tc2_i[21:20] ^ tagctl_sam_addr_tc2_i[19:18] ^
                              tagctl_sam_addr_tc2_i[17:16] ^ tagctl_sam_addr_tc2_i[15:14] ^ tagctl_sam_addr_tc2_i[13:12] ^
                              tagctl_sam_addr_tc2_i[11:10] ^ tagctl_sam_addr_tc2_i[9:8]   ^ tagctl_sam_addr_tc2_i[7:6];

  assign stripe_address_2hn = ^tagctl_sam_addr_tc2_i[39:6];

  assign stripe_address =        stripe_address_8hn  & {3{ext_samhnfmode_i[2]}} |
                          { 1'b0,stripe_address_4hn} & {3{ext_samhnfmode_i[1]}} |
                          {2'b00,stripe_address_2hn} & {3{ext_samhnfmode_i[0]}};
                          // hnf_mode 3'b000 is implicit and decodes to 3'b000

  assign hnf_dec[0] = (stripe_address == 3'b000);
  assign hnf_dec[1] = (stripe_address == 3'b001);
  assign hnf_dec[2] = (stripe_address == 3'b010);
  assign hnf_dec[3] = (stripe_address == 3'b011);
  assign hnf_dec[4] = (stripe_address == 3'b100);
  assign hnf_dec[5] = (stripe_address == 3'b101);
  assign hnf_dec[6] = (stripe_address == 3'b110);
  assign hnf_dec[7] = (stripe_address == 3'b111);

  assign hnf_tgtid = (ext_samhnf0nodeid_i & {7{hnf_dec[0]}}) |
                     (ext_samhnf1nodeid_i & {7{hnf_dec[1]}}) |
                     (ext_samhnf2nodeid_i & {7{hnf_dec[2]}}) |
                     (ext_samhnf3nodeid_i & {7{hnf_dec[3]}}) |
                     (ext_samhnf4nodeid_i & {7{hnf_dec[4]}}) |
                     (ext_samhnf5nodeid_i & {7{hnf_dec[5]}}) |
                     (ext_samhnf6nodeid_i & {7{hnf_dec[6]}}) |
                     (ext_samhnf7nodeid_i & {7{hnf_dec[7]}});

  assign sam_tgtid_tc2_o = (hnf_tgtid           & {7{hnfs}}) |
                           (ext_samhni0nodeid_i & {7{hni0}}) |
                           (ext_samhni1nodeid_i & {7{hni1}}) |
                           (ext_sammnnodeid_i   & {7{mn}});

end endgenerate

endmodule

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53scu_defs.v"
`undef CA53_UNDEFINE
/*END*/
