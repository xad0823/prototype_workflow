//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2008-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 17:05:58 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283841 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : SCU block internal definitions
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

// Internal opcodes. These are similar to Skyros encodings, but not identical.
`define CA53_REQ_OPCODE_READSHARED       5'h01
`define CA53_REQ_OPCODE_READONCE         5'h03
`define CA53_REQ_OPCODE_READNOSNOOP      5'h04
`define CA53_REQ_OPCODE_DVM              5'h05
`define CA53_REQ_OPCODE_DVM_COMPLETE     5'h06
`define CA53_REQ_OPCODE_READUNIQUE       5'h07
`define CA53_REQ_OPCODE_CLEANSHARED      5'h08
`define CA53_REQ_OPCODE_CLEANINVALID     5'h09
`define CA53_REQ_OPCODE_MAKEINVALID      5'h0A
`define CA53_REQ_OPCODE_CLEANUNIQUE      5'h0B
`define CA53_REQ_OPCODE_MAKEUNIQUE       5'h0C
`define CA53_REQ_OPCODE_DMB              5'h0E
`define CA53_REQ_OPCODE_DSB              5'h0F
`define CA53_REQ_OPCODE_EVICT            5'h14
`define CA53_REQ_OPCODE_EVICTDATA        5'h15
`define CA53_REQ_OPCODE_WRITECLEAN       5'h17
`define CA53_REQ_OPCODE_WRITEUNIQUE      5'h18
`define CA53_REQ_OPCODE_WRITELINEUNIQUE  5'h19
`define CA53_REQ_OPCODE_WRITEBACKPTL     5'h1A
`define CA53_REQ_OPCODE_WRITEBACK        5'h1B
`define CA53_REQ_OPCODE_WRITENOSNOOP     5'h1C
`define CA53_REQ_OPCODE_WRITENOSNOOPFULL 5'h1D

`define CA53_REQ_OPCODE_IS_READ(op)  (~op[4])
`define CA53_REQ_OPCODE_IS_WRITE(op) (op[4])

`define CA53_DATA_OPCODE_SNOOPDATA    3'b000
`define CA53_DATA_OPCODE_INVALID      3'b001
`define CA53_DATA_OPCODE_WRITENOSNOOP 3'b010
`define CA53_DATA_OPCODE_WRITEUNIQUE  3'b011
`define CA53_DATA_OPCODE_WRITEBACK    3'b100
`define CA53_DATA_OPCODE_WRITECLEAN   3'b101
`define CA53_DATA_OPCODE_EVICT        3'b110
`define CA53_DATA_OPCODE_EVICTDATA    3'b111

`define CA53_SNP_CLEANINVSETWAY       4'b0100

`define CA53_AFB_REQ_READNOSNOOP        {1'b0, `CA53_REQ_READNOSNOOP}
`define CA53_AFB_REQ_READONCE           {1'b0, `CA53_REQ_READONCE}
`define CA53_AFB_REQ_READSHARED         {1'b0, `CA53_REQ_READSHARED}
`define CA53_AFB_REQ_READUNIQUE         {1'b0, `CA53_REQ_READUNIQUE}
`define CA53_AFB_REQ_CLEANUNIQUE        {1'b0, `CA53_REQ_CLEANUNIQUE}
`define CA53_AFB_REQ_CLEANSHARED        {1'b0, `CA53_REQ_CLEANSHARED}
`define CA53_AFB_REQ_CLEANINVALID       {1'b0, `CA53_REQ_CLEANINVALID}
`define CA53_AFB_REQ_MAKEINVALID        {1'b0, `CA53_REQ_MAKEINVALID}
`define CA53_AFB_REQ_READNONE           {1'b0, `CA53_REQ_READNONE}
`define CA53_AFB_REQ_DMB                {1'b0, `CA53_REQ_DMB}
`define CA53_AFB_REQ_DSB                {1'b0, `CA53_REQ_DSB}
`define CA53_AFB_REQ_CLEANSETWAY        {1'b0, `CA53_REQ_CLEANSETWAY}
`define CA53_AFB_REQ_CLEANINVSETWAY     {1'b0, `CA53_REQ_CLEANINVSETWAY}
`define CA53_AFB_REQ_ECCCLEAN           {1'b0, `CA53_REQ_ECCCLEAN}
`define CA53_AFB_REQ_WRITENOSNOOP       {1'b0, `CA53_REQ_WRITENOSNOOP}
`define CA53_AFB_REQ_WRITEUNIQUE        {1'b0, `CA53_REQ_WRITEUNIQUE}
`define CA53_AFB_REQ_DVM                {1'b0, `CA53_REQ_DVM}
`define CA53_AFB_SNP_READONCE           {2'b10, `CA53_ACE_READONCE}
`define CA53_AFB_SNP_READSHARED         {2'b10, `CA53_ACE_READSHARED}
`define CA53_AFB_SNP_READCLEAN          {2'b10, `CA53_ACE_READCLEAN}
`define CA53_AFB_SNP_READNOTSHAREDDIRTY {2'b10, `CA53_ACE_READNOTSHAREDDIRTY}
`define CA53_AFB_SNP_READUNIQUE         {2'b10, `CA53_ACE_READUNIQUE}
`define CA53_AFB_SNP_CLEANSHARED        {2'b10, `CA53_ACE_CLEANSHARED}
`define CA53_AFB_SNP_CLEANINVALID       {2'b10, `CA53_ACE_CLEANINVALID}
`define CA53_AFB_SNP_MAKEINVALID        {2'b10, `CA53_ACE_MAKEINVALID}
`define CA53_AFB_SNP_DVM_MESSAGE        {2'b10, `CA53_ACE_DVM_MESSAGE}
`define CA53_AFB_SNP_DVM_COMPLETE       {2'b10, `CA53_ACE_DVM_COMPLETE}
`define CA53_AFB_SNP_DSB                {2'b11, `CA53_ACE_DVM_COMPLETE}
`define CA53_AFB_SNP_CLEANINVSETWAY     {2'b10, `CA53_SNP_CLEANINVSETWAY}


`define CA53_SKYROS_REQ_LINKFLIT         5'h00
`define CA53_SKYROS_REQ_READSHARED       5'h01
`define CA53_SKYROS_REQ_READCLEAN        5'h02
`define CA53_SKYROS_REQ_READONCE         5'h03
`define CA53_SKYROS_REQ_READNOSNOOP      5'h04
`define CA53_SKYROS_REQ_PCRDRETURN       5'h05
`define CA53_SKYROS_REQ_READUNIQUE       5'h07
`define CA53_SKYROS_REQ_CLEANSHARED      5'h08
`define CA53_SKYROS_REQ_CLEANINVALID     5'h09
`define CA53_SKYROS_REQ_MAKEINVALID      5'h0A
`define CA53_SKYROS_REQ_CLEANUNIQUE      5'h0B
`define CA53_SKYROS_REQ_MAKEUNIQUE       5'h0C
`define CA53_SKYROS_REQ_EVICT            5'h0D
`define CA53_SKYROS_REQ_DMB              5'h0E
`define CA53_SKYROS_REQ_DSB              5'h0F
`define CA53_SKYROS_REQ_DVM              5'h14
`define CA53_SKYROS_REQ_WRITEEVICTFULL   5'h15
`define CA53_SKYROS_REQ_WRITECLEANPTL    5'h16
`define CA53_SKYROS_REQ_WRITECLEANFULL   5'h17
`define CA53_SKYROS_REQ_WRITEUNIQUEPTL   5'h18
`define CA53_SKYROS_REQ_WRITEUNIQUEFULL  5'h19
`define CA53_SKYROS_REQ_WRITEBACKPTL     5'h1A
`define CA53_SKYROS_REQ_WRITEBACKFULL    5'h1B
`define CA53_SKYROS_REQ_WRITENOSNOOPPTL  5'h1C
`define CA53_SKYROS_REQ_WRITENOSNOOPFULL 5'h1D

`define CA53_SKYROS_RSP_LINKFLIT     4'b0000
`define CA53_SKYROS_RSP_SNPRESP      4'b0001
`define CA53_SKYROS_RSP_COMPACK      4'b0010
`define CA53_SKYROS_RSP_RETRYACK     4'b0011
`define CA53_SKYROS_RSP_COMP         4'b0100
`define CA53_SKYROS_RSP_COMPDBIDRESP 4'b0101
`define CA53_SKYROS_RSP_DBIDRESP     4'b0110
`define CA53_SKYROS_RSP_PCRDGRANT    4'b0111
`define CA53_SKYROS_RSP_READRECEIPT  4'b1000

`define CA53_SKYROS_DAT_LINKFLIT     3'b000
`define CA53_SKYROS_DAT_SNPRESP      3'b001
`define CA53_SKYROS_DAT_COPYBACK     3'b010
`define CA53_SKYROS_DAT_NONCOPYBACK  3'b011
`define CA53_SKYROS_DAT_COMPDATA     3'b100
`define CA53_SKYROS_DAT_SNPRESPPTL   3'b101

`define CA53_SKYROS_SNP_LINKFLIT     4'b0000
`define CA53_SKYROS_SNP_SHARED       4'b0001
`define CA53_SKYROS_SNP_CLEAN        4'b0010
`define CA53_SKYROS_SNP_ONCE         4'b0011
`define CA53_SKYROS_SNP_UNIQUE       4'b0111
`define CA53_SKYROS_SNP_CLEANSHARED  4'b1000
`define CA53_SKYROS_SNP_CLEANINVALID 4'b1001
`define CA53_SKYROS_SNP_MAKEINVALID  4'b1010
`define CA53_SKYROS_SNP_DVMOP        4'b1101

`define CA53_SNPSLV_TXNID 7'h2e

// Transfer types that an L2DB can perform.
// These are encoded to roughly match the L2DB states.
`define CA53_L2DB_TRNSFR_L2DB_RAM     3'b000
`define CA53_L2DB_TRNSFR_RAM_SWAP     3'b001
`define CA53_L2DB_TRNSFR_MASTER_L2DB  3'b010
`define CA53_L2DB_TRNSFR_RAM_L2DB     3'b011
`define CA53_L2DB_TRNSFR_SLV_L2DB     3'b100
`define CA53_L2DB_TRNSFR_L2DB_MASTER  3'b101
`define CA53_L2DB_TRNSFR_RAM_SLV      3'b110
`define CA53_L2DB_TRNSFR_SLV_SLV      3'b111

// L2DB info encoding, which depends on the transfer type.
//
// RAM accesses:
// [24]    Single data beat (ACP only)
// [23]    Delay last beat until snoops completed
// [22:19] Way
// [18:8]  Index
// [7:6]   Critical chunk
// [5:0]   Destination reqbuf ID (if forwarding)
//
// Master writes
// [28:25] QoS (Skyros snoops only)
// [24]    Write is from an external snoop (snpslv only)
// [23]    Data is unique
// [22]    Write is a non-coherent strex
// [21]    prot[0] (writes)
// [20]    Release L2DB after data sent
// [19]    tgtid[6] (Skyros snoops)
// [18:16] Opcode (ACE or Skyros write) or snoop resp (Skyros snoop)
// [15:8]  Attrs (ACE), or DBID (Skyros snoops)
// [7:6]   Critical chunk (snoops)
// [5:0]   tgtid[5:0] (Skyros snoops), or reqbuf (Skyros writes), or {reqbuf[5:3], AFB} (ACE)
//
// Master reads
// [13:8]  Source reqbuf ID
// [7:6]   Critical chunk
//
// SLV data read/forward
// [25]    Send only beats from critical chunk upwards (ACP only)
// [24]    Single data beat (ACP only)
// [23]    Delay last beat until snoops completed
// [22]    Overwrite older data
// [18:14] BIU ID
// [13:8]  Source reqbuf ID
// [7:6]   Critical chunk
// [5:0]   Destination reqbuf ID (if forwarding)
`define CA53_L2DB_INFO_CRITICAL_CHUNK 7:6
`define CA53_L2DB_INFO_DEST_ID        5:0
`define CA53_L2DB_INFO_DEST_SLV       5:3
`define CA53_L2DB_INFO_MASTER_ID      5:0
`define CA53_L2DB_INFO_MASTER_ATTRS   15:8
`define CA53_L2DB_INFO_MASTER_DBID    15:8
`define CA53_L2DB_INFO_MASTER_OPCODE  18:16
`define CA53_L2DB_INFO_MASTER_RELEASE 20
`define CA53_L2DB_INFO_MASTER_PROT    21
`define CA53_L2DB_INFO_MASTER_STREX   22
`define CA53_L2DB_INFO_MASTER_UNIQUE  23
`define CA53_L2DB_INFO_MASTER_SNP     24
`define CA53_L2DB_INFO_MASTER_QOS     28:25
`define CA53_L2DB_INFO_DEST_BIU_ID    18:14
`define CA53_L2DB_INFO_RAM_INDEX      18:8
`define CA53_L2DB_INFO_RAM_WAY        22:19
`define CA53_L2DB_INFO_SRC_SLV        13:11
`define CA53_L2DB_INFO_SRC_REQBUF     13:8
`define CA53_L2DB_INFO_OVERWRITE      22
`define CA53_L2DB_INFO_DELAY_LAST     23
`define CA53_L2DB_INFO_SINGLE_BEAT    24
`define CA53_L2DB_INFO_BEAT_CTL       25:24

// Tagctl control
// The encodings of serialise and L2DB must differ by only one bit.
`define CA53_TAGCTL_PASS_SERIALISE     4'b0000 // Main L1 and L2 lookup and serialisation
`define CA53_TAGCTL_PASS_L2DB          4'b0001 // Allocate an L2DB for writes
`define CA53_TAGCTL_PASS_UPDATE        4'b0010 // Write L1 and L2 tags
`define CA53_TAGCTL_PASS_VICTIM_UPDATE 4'b0011 // Write L1 and L2 tags for a victim line
`define CA53_TAGCTL_PASS_VICTIM        4'b0100 // Read L1 tags for victim, write L2 tag or optionally L1 requestor
`define CA53_TAGCTL_PASS_L2_VICTIM     4'b0101 // Read L2 tags for L2 victim, write L1 tag
`define CA53_TAGCTL_PASS_MASTER_R      4'b0110 // Make a master read request
`define CA53_TAGCTL_PASS_MASTER_W      4'b0111 // Make a master write request
`define CA53_TAGCTL_PASS_LOOKUP        4'b1000 // Make a L1 and/or L2 tag lookup
`define CA53_TAGCTL_PASS_X             4'bxxxx

`define CA53_REQBUF_IS_SNOOP(req_id) ((req_id[5:3] == 3'b101) & (req_id[2:0] < 3'b101))
`define CA53_REQBUF_IS_TAGECC(req_id) (req_id[5:0] == 6'b111111)

// Convert to and from onehot encodings for L1 and L2 hit ways.
`define CA53_L1_WAY_ENC(wayonehot) {|wayonehot[3:2], wayonehot[3] | wayonehot[1]}
`define CA53_L2_WAY_ENC(wayonehot) {|wayonehot[15:8], \
                                  (|wayonehot[15:12]) | (|wayonehot[7:4]), \
                                  (|wayonehot[15:14]) | (|wayonehot[11:10]) | (|wayonehot[7:6]) | (|wayonehot[3:2]), \
                                  wayonehot[15] | wayonehot[13] | wayonehot[11] | wayonehot[9] | \
                                  wayonehot[7]  | wayonehot[5]  | wayonehot[3]  | wayonehot[1]}
`define CA53_L1_WAY_DEC(wayenc) {wayenc == 2'b11, wayenc == 2'b10, wayenc == 2'b01, wayenc == 2'b00}
`define CA53_L2_WAY_DEC(wayenc) {wayenc == 4'b1111, wayenc == 4'b1110, wayenc == 4'b1101, wayenc == 4'b1100, \
                               wayenc == 4'b1011, wayenc == 4'b1010, wayenc == 4'b1001, wayenc == 4'b1000, \
                               wayenc == 4'b0111, wayenc == 4'b0110, wayenc == 4'b0101, wayenc == 4'b0100, \
                               wayenc == 4'b0011, wayenc == 4'b0010, wayenc == 4'b0001, wayenc == 4'b0000}
`define CA53_CPU_ENC(cpuonehot) {|cpuonehot[3:2], cpuonehot[3] | cpuonehot[1]}

// Pick one way from a number of valid ways. It doesn't matter which, so pick the highest way set.
`define CA53_L2_WAY_PICK(ways) { |ways[15:8], \
                                 |ways[15:12] | (|ways[7:4] & ~|ways[11:8]), \
                                 |ways[15:14] | \
                                (|ways[11:10] & ~|ways[13:12]) | \
                                (|ways[7:6]   & ~|ways[13:12] & ~|ways[9:8]) | \
                                (|ways[3:2]   & ~|ways[13:12] & ~|ways[9:8] & ~|ways[5:4]), \
                                  ways[15] | \
                                 (ways[13] & ~ways[14]) | \
                                 (ways[11] & ~ways[14] & ~ways[12]) | \
                                 (ways[9]  & ~ways[14] & ~ways[12] & ~ways[10]) | \
                                 (ways[7]  & ~ways[14] & ~ways[12] & ~ways[10] & ~ways[8]) | \
                                 (ways[5]  & ~ways[14] & ~ways[12] & ~ways[10] & ~ways[8] & ~ways[6]) | \
                                 (ways[3]  & ~ways[14] & ~ways[12] & ~ways[10] & ~ways[8] & ~ways[6] & ~ways[4]) | \
                                 (ways[1]  & ~ways[14] & ~ways[12] & ~ways[10] & ~ways[8] & ~ways[6] & ~ways[4] & ~ways[2])}

`define CA53_L2_BANK_PICK(ways) {|ways[3:2], \
                                  ways[3] | \
                                 (ways[1] & ~ways[2])}

// Convert internal attributes to ACE AxDOMAIN
`define CA53_ATTRS_TO_DOMAIN(attrs, force_non_shareable, cachemaint) \
        (((~`CA53_MEM_COHERENT(attrs) & ~cachemaint) | \
          (attrs[1:0] == 2'b01))     ? `CA53_ACE_DOMAIN_SYSTEM : \
         (`CA53_MEM_O_SHAREABLE(attrs) & \
          ~force_non_shareable)      ? `CA53_ACE_DOMAIN_OUTER : \
         (`CA53_MEM_SHAREABLE(attrs) & \
          ~force_non_shareable)      ? `CA53_ACE_DOMAIN_INNER : \
                                       `CA53_ACE_DOMAIN_NS)

// Convert internal attributes to MAIR attrs format for *MEMATTR outputs
`define CA53_ATTRS_TO_MEMATTR(attrs) \
        (`CA53_MEM_DEVICE(attrs) ? {1'b1, attrs[3:2], 5'b00100} : \
         {attrs[1] & ~attrs[0], \
          `CA53_MEM_OUTER_NC(attrs) ? 4'b0100 : \
          {`CA53_MEM_OUTER_WT(attrs) ? 2'b10 : 2'b11, attrs[3:2]}, \
          attrs[1], \
          `CA53_MEM_NC(attrs) ? 2'b01 : \
          `CA53_MEM_WT(attrs) ? 2'b10 : \
                              2'b11})

// The ECC bits for writing an invalid tag
`define CA53_TAG_NULL_ECC 7'b0001100

// A onehot mux of an array of values
`define CA53_ONEHOT_MUX(dst, width, sel, src, depth, genlabel) \
  generate if (1) begin : genlabel \
    genvar mux_w; \
    genvar mux_d; \
\
    wire [(width*depth)-1:0] src_pkd; \
\
    for (mux_w = 0; mux_w < width; mux_w = mux_w + 1) begin : g_mux_w \
      for (mux_d = 0; mux_d < depth; mux_d = mux_d + 1) begin : g_mux_d \
        assign src_pkd[mux_w*depth+mux_d] = src[mux_d][mux_w]; \
      end \
\
      assign dst[mux_w] = |(sel & src_pkd[mux_w*depth+:depth]); \
    end \
  end endgenerate

`define CA53_SCU_INT_PARAM_DECL parameter NUM_CPUS = 4, parameter L2_CACHE = 0, parameter SCU_CACHE_PROTECTION = 1'b0, parameter CPU_CACHE_PROTECTION = 1'b0, parameter L2_INPUT_LATENCY = 1'b0, parameter L2_OUTPUT_LATENCY = 1'b0, parameter ACP = 0, parameter ACE = 1, parameter NUM_L2DBS = 1, parameter MAX_L2DBS = 1
`define CA53_SCU_INT_PARAM_INST .NUM_CPUS(NUM_CPUS), .L2_CACHE(L2_CACHE), .SCU_CACHE_PROTECTION(SCU_CACHE_PROTECTION), .CPU_CACHE_PROTECTION(CPU_CACHE_PROTECTION), .L2_INPUT_LATENCY(L2_INPUT_LATENCY), .L2_OUTPUT_LATENCY(L2_OUTPUT_LATENCY), .ACP(ACP), .ACE(ACE), .NUM_L2DBS(NUM_L2DBS), .MAX_L2DBS(MAX_L2DBS)

//-----------------------------------------------------------------------------
// RAM widths
//-----------------------------------------------------------------------------


`define CA53_L2_SIZE_W     4

`define CA53_SCU_L1D_ASSOC 4
`define CA53_SCU_L2_ASSOC  16

`define CA53_SCU_L1D_TAGRAM_ADDR_W 8
`define CA53_SCU_L1D_TAGRAM_DATA_W (CPU_CACHE_PROTECTION ? 40 : 33)

`define CA53_SCU_L2_TAGRAM_ADDR_W 11
`define CA53_SCU_L2_TAGRAM_DATA_W (SCU_CACHE_PROTECTION ? 40 : 33)

`define CA53_SCU_L2_VICTIMRAM_ADDR_W 11
`define CA53_SCU_L2_VICTIMRAM_DATA_W 32
`define CA53_SCU_L2_VICTIMRAM_STRB_W 16

`define CA53_SCU_L2_DATARAM_EN_W   8
`define CA53_SCU_L2_DATARAM_ADDR_W 15
`define CA53_SCU_L2_DATARAM_DATA_W (SCU_CACHE_PROTECTION ? 72 : 64)


//-----------------------------------------------------------------------------
// External ACE master widths
//-----------------------------------------------------------------------------

`define CA53_SCU_EXT_ADDR_W    44
`define CA53_SCU_EXT_DATA_W    128
`define CA53_SCU_EXT_STRB_W    16
`define CA53_SCU_EXT_RID_W     6
`define CA53_SCU_EXT_WID_W     5

//-----------------------------------------------------------------------------
// Undefines
//-----------------------------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_REQ_OPCODE_READSHARED
`undef CA53_REQ_OPCODE_READONCE
`undef CA53_REQ_OPCODE_READNOSNOOP
`undef CA53_REQ_OPCODE_DVM
`undef CA53_REQ_OPCODE_DVM_COMPLETE
`undef CA53_REQ_OPCODE_READUNIQUE
`undef CA53_REQ_OPCODE_CLEANSHARED
`undef CA53_REQ_OPCODE_CLEANINVALID
`undef CA53_REQ_OPCODE_MAKEINVALID
`undef CA53_REQ_OPCODE_CLEANUNIQUE
`undef CA53_REQ_OPCODE_MAKEUNIQUE
`undef CA53_REQ_OPCODE_DMB
`undef CA53_REQ_OPCODE_DSB
`undef CA53_REQ_OPCODE_EVICT
`undef CA53_REQ_OPCODE_EVICTDATA
`undef CA53_REQ_OPCODE_WRITECLEAN
`undef CA53_REQ_OPCODE_WRITEUNIQUE
`undef CA53_REQ_OPCODE_WRITELINEUNIQUE
`undef CA53_REQ_OPCODE_WRITEBACKPTL
`undef CA53_REQ_OPCODE_WRITEBACK
`undef CA53_REQ_OPCODE_WRITENOSNOOP
`undef CA53_REQ_OPCODE_WRITENOSNOOPFULL
`undef CA53_REQ_OPCODE_IS_READ
`undef CA53_REQ_OPCODE_IS_WRITE
`undef CA53_DATA_OPCODE_SNOOPDATA
`undef CA53_DATA_OPCODE_INVALID
`undef CA53_DATA_OPCODE_WRITENOSNOOP
`undef CA53_DATA_OPCODE_WRITEUNIQUE
`undef CA53_DATA_OPCODE_WRITEBACK
`undef CA53_DATA_OPCODE_WRITECLEAN
`undef CA53_DATA_OPCODE_EVICT
`undef CA53_DATA_OPCODE_EVICTDATA
`undef CA53_SNP_CLEANINVSETWAY
`undef CA53_AFB_REQ_READNOSNOOP
`undef CA53_AFB_REQ_READONCE
`undef CA53_AFB_REQ_READSHARED
`undef CA53_AFB_REQ_READUNIQUE
`undef CA53_AFB_REQ_CLEANUNIQUE
`undef CA53_AFB_REQ_CLEANSHARED
`undef CA53_AFB_REQ_CLEANINVALID
`undef CA53_AFB_REQ_MAKEINVALID
`undef CA53_AFB_REQ_READNONE
`undef CA53_AFB_REQ_DMB
`undef CA53_AFB_REQ_DSB
`undef CA53_AFB_REQ_CLEANSETWAY
`undef CA53_AFB_REQ_CLEANINVSETWAY
`undef CA53_AFB_REQ_ECCCLEAN
`undef CA53_AFB_REQ_WRITENOSNOOP
`undef CA53_AFB_REQ_WRITEUNIQUE
`undef CA53_AFB_REQ_DVM
`undef CA53_AFB_SNP_READONCE
`undef CA53_AFB_SNP_READSHARED
`undef CA53_AFB_SNP_READCLEAN
`undef CA53_AFB_SNP_READNOTSHAREDDIRTY
`undef CA53_AFB_SNP_READUNIQUE
`undef CA53_AFB_SNP_CLEANSHARED
`undef CA53_AFB_SNP_CLEANINVALID
`undef CA53_AFB_SNP_MAKEINVALID
`undef CA53_AFB_SNP_DVM_MESSAGE
`undef CA53_AFB_SNP_DVM_COMPLETE
`undef CA53_AFB_SNP_DSB
`undef CA53_AFB_SNP_CLEANINVSETWAY
`undef CA53_SKYROS_REQ_LINKFLIT
`undef CA53_SKYROS_REQ_READSHARED
`undef CA53_SKYROS_REQ_READCLEAN
`undef CA53_SKYROS_REQ_READONCE
`undef CA53_SKYROS_REQ_READNOSNOOP
`undef CA53_SKYROS_REQ_PCRDRETURN
`undef CA53_SKYROS_REQ_READUNIQUE
`undef CA53_SKYROS_REQ_CLEANSHARED
`undef CA53_SKYROS_REQ_CLEANINVALID
`undef CA53_SKYROS_REQ_MAKEINVALID
`undef CA53_SKYROS_REQ_CLEANUNIQUE
`undef CA53_SKYROS_REQ_MAKEUNIQUE
`undef CA53_SKYROS_REQ_EVICT
`undef CA53_SKYROS_REQ_DMB
`undef CA53_SKYROS_REQ_DSB
`undef CA53_SKYROS_REQ_DVM
`undef CA53_SKYROS_REQ_WRITEEVICTFULL
`undef CA53_SKYROS_REQ_WRITECLEANPTL
`undef CA53_SKYROS_REQ_WRITECLEANFULL
`undef CA53_SKYROS_REQ_WRITEUNIQUEPTL
`undef CA53_SKYROS_REQ_WRITEUNIQUEFULL
`undef CA53_SKYROS_REQ_WRITEBACKPTL
`undef CA53_SKYROS_REQ_WRITEBACKFULL
`undef CA53_SKYROS_REQ_WRITENOSNOOPPTL
`undef CA53_SKYROS_REQ_WRITENOSNOOPFULL
`undef CA53_SKYROS_RSP_LINKFLIT
`undef CA53_SKYROS_RSP_SNPRESP
`undef CA53_SKYROS_RSP_COMPACK
`undef CA53_SKYROS_RSP_RETRYACK
`undef CA53_SKYROS_RSP_COMP
`undef CA53_SKYROS_RSP_COMPDBIDRESP
`undef CA53_SKYROS_RSP_DBIDRESP
`undef CA53_SKYROS_RSP_PCRDGRANT
`undef CA53_SKYROS_RSP_READRECEIPT
`undef CA53_SKYROS_DAT_LINKFLIT
`undef CA53_SKYROS_DAT_SNPRESP
`undef CA53_SKYROS_DAT_COPYBACK
`undef CA53_SKYROS_DAT_NONCOPYBACK
`undef CA53_SKYROS_DAT_COMPDATA
`undef CA53_SKYROS_DAT_SNPRESPPTL
`undef CA53_SKYROS_SNP_LINKFLIT
`undef CA53_SKYROS_SNP_SHARED
`undef CA53_SKYROS_SNP_CLEAN
`undef CA53_SKYROS_SNP_ONCE
`undef CA53_SKYROS_SNP_UNIQUE
`undef CA53_SKYROS_SNP_CLEANSHARED
`undef CA53_SKYROS_SNP_CLEANINVALID
`undef CA53_SKYROS_SNP_MAKEINVALID
`undef CA53_SKYROS_SNP_DVMOP
`undef CA53_SNPSLV_TXNID
`undef CA53_L2DB_TRNSFR_L2DB_RAM
`undef CA53_L2DB_TRNSFR_RAM_SWAP
`undef CA53_L2DB_TRNSFR_MASTER_L2DB
`undef CA53_L2DB_TRNSFR_RAM_L2DB
`undef CA53_L2DB_TRNSFR_SLV_L2DB
`undef CA53_L2DB_TRNSFR_L2DB_MASTER
`undef CA53_L2DB_TRNSFR_RAM_SLV
`undef CA53_L2DB_TRNSFR_SLV_SLV
`undef CA53_L2DB_INFO_CRITICAL_CHUNK
`undef CA53_L2DB_INFO_DEST_ID
`undef CA53_L2DB_INFO_DEST_SLV
`undef CA53_L2DB_INFO_MASTER_ID
`undef CA53_L2DB_INFO_MASTER_ATTRS
`undef CA53_L2DB_INFO_MASTER_DBID
`undef CA53_L2DB_INFO_MASTER_OPCODE
`undef CA53_L2DB_INFO_MASTER_RELEASE
`undef CA53_L2DB_INFO_MASTER_PROT
`undef CA53_L2DB_INFO_MASTER_STREX
`undef CA53_L2DB_INFO_MASTER_UNIQUE
`undef CA53_L2DB_INFO_MASTER_SNP
`undef CA53_L2DB_INFO_MASTER_QOS
`undef CA53_L2DB_INFO_DEST_BIU_ID
`undef CA53_L2DB_INFO_RAM_INDEX
`undef CA53_L2DB_INFO_RAM_WAY
`undef CA53_L2DB_INFO_SRC_SLV
`undef CA53_L2DB_INFO_SRC_REQBUF
`undef CA53_L2DB_INFO_OVERWRITE
`undef CA53_L2DB_INFO_DELAY_LAST
`undef CA53_L2DB_INFO_SINGLE_BEAT
`undef CA53_L2DB_INFO_BEAT_CTL
`undef CA53_TAGCTL_PASS_SERIALISE
`undef CA53_TAGCTL_PASS_L2DB
`undef CA53_TAGCTL_PASS_UPDATE
`undef CA53_TAGCTL_PASS_VICTIM_UPDATE
`undef CA53_TAGCTL_PASS_VICTIM
`undef CA53_TAGCTL_PASS_L2_VICTIM
`undef CA53_TAGCTL_PASS_MASTER_R
`undef CA53_TAGCTL_PASS_MASTER_W
`undef CA53_TAGCTL_PASS_LOOKUP
`undef CA53_TAGCTL_PASS_X
`undef CA53_REQBUF_IS_SNOOP
`undef CA53_REQBUF_IS_TAGECC
`undef CA53_L1_WAY_ENC
`undef CA53_L2_WAY_ENC
`undef CA53_L1_WAY_DEC
`undef CA53_L2_WAY_DEC
`undef CA53_CPU_ENC
`undef CA53_L2_WAY_PICK
`undef CA53_L2_BANK_PICK
`undef CA53_ATTRS_TO_DOMAIN
`undef CA53_ATTRS_TO_MEMATTR
`undef CA53_TAG_NULL_ECC
`undef CA53_ONEHOT_MUX
`undef CA53_SCU_INT_PARAM_DECL
`undef CA53_SCU_INT_PARAM_INST
`undef CA53_L2_SIZE_W
`undef CA53_SCU_L1D_ASSOC
`undef CA53_SCU_L2_ASSOC
`undef CA53_SCU_L1D_TAGRAM_ADDR_W
`undef CA53_SCU_L1D_TAGRAM_DATA_W
`undef CA53_SCU_L2_TAGRAM_ADDR_W
`undef CA53_SCU_L2_TAGRAM_DATA_W
`undef CA53_SCU_L2_VICTIMRAM_ADDR_W
`undef CA53_SCU_L2_VICTIMRAM_DATA_W
`undef CA53_SCU_L2_VICTIMRAM_STRB_W
`undef CA53_SCU_L2_DATARAM_EN_W
`undef CA53_SCU_L2_DATARAM_ADDR_W
`undef CA53_SCU_L2_DATARAM_DATA_W
`undef CA53_SCU_EXT_ADDR_W
`undef CA53_SCU_EXT_DATA_W
`undef CA53_SCU_EXT_STRB_W
`undef CA53_SCU_EXT_RID_W
`undef CA53_SCU_EXT_WID_W
/*END*/
`endif
