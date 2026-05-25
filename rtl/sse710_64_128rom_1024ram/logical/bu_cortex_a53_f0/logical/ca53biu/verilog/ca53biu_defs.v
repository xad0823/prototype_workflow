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
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : BIU macros
//-----------------------------------------------------------------------------

`ifndef CA53_UNDEFINE

//-----------------------------------------------------------------------------
// BIU number of NC load IDs
//-----------------------------------------------------------------------------

`define CA53_BIU_DCU_NC_ID_NUM                          4
`define CA53_BIU_DCU_NC_ID_NUM_W                        (`CA53_LOG2((`CA53_BIU_DCU_NC_ID_NUM)))

//-----------------------------------------------------------------------------
// BIU's RBUF configuration
//-----------------------------------------------------------------------------

`define CA53_BIU_RBUFS_NUM                              4
`define CA53_BIU_RBUFS_NUM_W                            (`CA53_LOG2(`CA53_BIU_RBUFS_NUM))
`define CA53_BIU_RBUFS_NUM_W_INC                        3
`define CA53_BIU_IFU_RBUF_ID                            3
`define CA53_BIU_IFU_ONEHOT_RBUF                        4'b1000

//-----------------------------------------------------------------------------
// BIU DR response indexes of the age and ECC bits
//-----------------------------------------------------------------------------

`define CA53_BIU_DR_RESP_ECC_B                          4
`define CA53_BIU_DR_RESP_AGE_B                          5

//-----------------------------------------------------------------------------
// BIU number of LF descriptors
//-----------------------------------------------------------------------------

`define CA53_BIU_LF_DESCR_NUM                           8
`define CA53_BIU_LF_DESCR_NUM_W                         (`CA53_LOG2((`CA53_BIU_LF_DESCR_NUM)))

//-----------------------------------------------------------------------------
// BIU number of LF request streams
//-----------------------------------------------------------------------------

`define CA53_BIU_LF_MASTERS_NUM                         10

//-----------------------------------------------------------------------------
// BIU number of data prefetch streams
//-----------------------------------------------------------------------------

`define CA53_BIU_PF_STREAM_NUM                          4
`define CA53_BIU_PF_STREAM_NUM_W                        (`CA53_LOG2((`CA53_BIU_PF_STREAM_NUM)))
`define CA53_BIU_PF_STREAM_HZ_ADDR_MASK                 4
`define CA53_BIU_DC1_LF                                 4

//-----------------------------------------------------------------------------
// BIU index mapping of the LF request streams
//-----------------------------------------------------------------------------

`define CA53_BIU_CCB                                    0
`define CA53_BIU_DC3_LF                                 1
`define CA53_BIU_DC2_LF                                 2
`define CA53_BIU_TLB_LF                                 3
`define CA53_BIU_STB0_LF                                4
`define CA53_BIU_STB1_LF                                5
`define CA53_BIU_STB2_LF                                6
`define CA53_BIU_STB3_LF                                7
`define CA53_BIU_STB4_LF                                8
`define CA53_BIU_PF_LF                                  9

//-----------------------------------------------------------------------------
// BIU LF master qualifier
//-----------------------------------------------------------------------------

`define CA53_BIU_LF_MASTER_NONE                         3'b000
`define CA53_BIU_LF_MASTER_DCU                          3'b001
`define CA53_BIU_LF_MASTER_DCU_LDREX                    3'b010
`define CA53_BIU_LF_MASTER_DCU_PLDW                     3'b011
`define CA53_BIU_LF_MASTER_TLB                          3'b100
`define CA53_BIU_LF_MASTER_STB                          3'b101
`define CA53_BIU_LF_MASTER_PF                           3'b110
`define CA53_BIU_LF_MASTER_PF_PLDW                      3'b111

`define CA53_BIU_LF_MASTER_TLB_LD_PENDING               2'b01
`define CA53_BIU_LF_MASTER_TLB_LD_DONE                  2'b10

`define CA53_BIU_LF_MASTER_PF_ID0                       2'b00
`define CA53_BIU_LF_MASTER_PF_ID1                       2'b01
`define CA53_BIU_LF_MASTER_PF_ID2                       2'b10
`define CA53_BIU_LF_MASTER_PF_ID3                       2'b11

//-----------------------------------------------------------------------------
// BIU LF type qualifier
//-----------------------------------------------------------------------------

`define CA53_BIU_LF_FOR_TLB(master)                     (master[2:0] == `CA53_BIU_LF_MASTER_TLB)
`define CA53_BIU_LF_FOR_TLB_LD_PENDING(master)          (`CA53_BIU_LF_FOR_TLB(master) & \
                                                         (master[4:3] == `CA53_BIU_LF_MASTER_TLB_LD_PENDING))

`define CA53_BIU_LF_FOR_LDREX(master)                   (master[2:0] == `CA53_BIU_LF_MASTER_DCU_LDREX)
`define CA53_BIU_LF_FOR_WRITE(master)                   ((master[2:0] == `CA53_BIU_LF_MASTER_DCU_PLDW) | \
                                                         (master[2:0] == `CA53_BIU_LF_MASTER_STB) | \
                                                         (master[2:0] == `CA53_BIU_LF_MASTER_PF_PLDW))

`define CA53_BIU_LF_ELIGIBLE_FOR_RAMODE_LEAVE(master)   (master[2:0] == `CA53_BIU_LF_MASTER_STB)

`define CA53_BIU_LF_ELIGIBLE_FOR_PF(master, read_alloc_mode, disable_stb_pf) ((master[2:0] == `CA53_BIU_LF_MASTER_DCU) | \
                                                                              (~read_alloc_mode & (master[2:0] == `CA53_BIU_LF_MASTER_DCU_PLDW)) | \
                                                                              (~read_alloc_mode & ~disable_stb_pf & (master[2:0] == `CA53_BIU_LF_MASTER_STB)))

//-----------------------------------------------------------------------------
// BIU number of AR request streams
//-----------------------------------------------------------------------------

`define CA53_BIU_REQ_NUM                                7

//-----------------------------------------------------------------------------
// 4-bits one-hot to 2-bits binary encoding
//-----------------------------------------------------------------------------

`define CA53_BIU_ONEHOT2BIN(onehot)                     ({(onehot[3] | onehot[2]), (onehot[3] | onehot[1])})

//-----------------------------------------------------------------------------
// 5-bits one-hot to 3-bits binary encoding
//-----------------------------------------------------------------------------

`define CA53_BIU_ONEHOT2BIN_5_3(onehot)                 ({onehot[4], (onehot[3] | onehot[2]), (onehot[3] | onehot[1])})

//-----------------------------------------------------------------------------
// 8-bits one-hot to 3-bits binary encoding
//-----------------------------------------------------------------------------

`define CA53_BIU_ONEHOT2BIN_8_3(onehot)                 ({|onehot[7:4],                                \
                                                          (|onehot[7:6]) | (|onehot[3:2]),             \
                                                          onehot[7] | onehot[5] | onehot[3] | onehot[1]})

//-----------------------------------------------------------------------------
// BIU AR address req channel priorities
// 0 highest priority; 6 lowest priority
//-----------------------------------------------------------------------------

`define CA53_BIU_DC3_REQ                                0
`define CA53_BIU_DC2_REQ                                1
`define CA53_BIU_LF_REQ                                 2
`define CA53_BIU_TLB_REQ                                3
`define CA53_BIU_IFU_REQ                                4
`define CA53_BIU_ECC_REQ                                5
`define CA53_BIU_STB_REQ                                6

//-----------------------------------------------------------------------------
// Request ID masks
//-----------------------------------------------------------------------------

`define CA53_RID_IFU_MASK                               5'b10000
`define CA53_RID_STB_MASK                               5'b11000
`define CA53_RID_DCU_MASK                               5'b00000
`define CA53_RID_LF_MASK                                5'b01000

//-----------------------------------------------------------------------------
// BIU-SCU len encoding
//-----------------------------------------------------------------------------

`define CA53_REQ_LEN3                                   2'b11
`define CA53_REQ_LEN1                                   2'b01
`define CA53_REQ_LEN0                                   2'b00

//-----------------------------------------------------------------------------
// BIU-SCU wrap encoding
//-----------------------------------------------------------------------------

`define CA53_BIU_REQ_BURST_INCR                         1'b0
`define CA53_BIU_REQ_BURST_WRAP                         1'b1

//-----------------------------------------------------------------------------
// other defs
//-----------------------------------------------------------------------------

`define CA53_BIU_STB_IS_WRITE(ar_type)                  (ar_type[7:0] == `CA53_CPOP_8_WRITE)
`define CA53_BIU_STB_IS_WRITENOSNOOP(ar_type, ar_attrs) (`CA53_BIU_STB_IS_WRITE(ar_type) & ~`CA53_MEM_COHERENT(ar_attrs))
`define CA53_BIU_STB_IS_WRITEUNIQUE(ar_type, ar_attrs)  (`CA53_BIU_STB_IS_WRITE(ar_type) & `CA53_MEM_COHERENT(ar_attrs))
`define CA53_BIU_STB_IS_CLEANUNIQUE(ar_type)            (ar_type[7:0] == `CA53_CPOP_8_CLEANUNIQUE)
`define CA53_BIU_STB_IS_CLEANSHARED(ar_type)            ((ar_type[7:0] == `CA53_CPOP_8_DCCMVAC) | \
                                                         (ar_type[7:0] == `CA53_CPOP_8_DCCMVAU))
`define CA53_BIU_STB_IS_CLEANINVALID(ar_type)           (ar_type[7:0] == `CA53_CPOP_8_DCCIMVAC)
`define CA53_BIU_STB_IS_MAKEINVALID(ar_type)            (ar_type[7:0] == `CA53_CPOP_8_DCIMVAC)
`define CA53_BIU_STB_IS_CLEANSETWAY(ar_type)            (ar_type[7:0] == `CA53_CPOP_8_DCCSW)
`define CA53_BIU_STB_IS_CLEANINVSETWAY(ar_type)         ((ar_type[7:0] == `CA53_CPOP_8_DCCISW) | \
                                                         (ar_type[7:0] == `CA53_CPOP_8_DCISW))
`define CA53_BIU_STB_IS_DVM(ar_type)                    ((ar_type[7:6] == 2'b01) | (ar_type[5:4] == 2'b00))
`define CA53_BIU_STB_IS_DVM_FOR_IS(ar_type)             (ar_type[3])
`define CA53_BIU_STB_IS_ICINV(ar_type)                  ((ar_type == `CA53_CPOP_8_ICIVAU)  | \
                                                         (ar_type == `CA53_CPOP_8_ICIALLU) | \
                                                         (ar_type == `CA53_CPOP_8_ICIALLUIS))


`define CA53_BIU_RID_IS_FOR_IFU(dr_id)                  (dr_id[4:2] == 3'b100)
`define CA53_BIU_RID_IS_FOR_DCU(dr_id)                  (dr_id[4]   == 1'b0)
`define CA53_BIU_RID_IS_FOR_DCU_NC(dr_id)               (dr_id[4:3] == 2'b00)
`define CA53_BIU_RID_IS_FOR_PLD_L2(dr_id)               (dr_id[4:0] == 5'b10111)
`define CA53_BIU_RID_IS_FOR_TLB(dr_id)                  (dr_id[4:1] == 4'b1010)
`define CA53_BIU_RID_IS_FOR_ECC(dr_id)                  (dr_id[4:0] == 5'b10110)
`define CA53_BIU_RID_IS_FOR_STB(dr_id)                  (dr_id[4:3] == 2'b11)
`define CA53_BIU_RID_IS_FOR_READ(ar_id)                 ((ar_id[4:3] != 2'b11) & (ar_id[3:0] != 4'b0110))
`define CA53_BIU_RID_IS_FOR_WRITE(ar_id)                (ar_id[4:3] == 2'b11)
`define CA53_BIU_RID_IS_FOR_LF(ar_id)                   (ar_id[4:3] == 2'b01)

`define CA53_BIU_STB_TO_ARTYPE(ar_type, ar_attrs)       (`CA53_CPOP_8_IS_DSB(ar_type)                     ? `CA53_REQ_DSB : \
                                                         `CA53_CPOP_8_IS_DMB(ar_type)                     ? `CA53_REQ_DMB : \
                                                         `CA53_BIU_STB_IS_CLEANUNIQUE(ar_type)            ? `CA53_REQ_CLEANUNIQUE : \
                                                         `CA53_BIU_STB_IS_CLEANSHARED(ar_type)            ? `CA53_REQ_CLEANSHARED : \
                                                         `CA53_BIU_STB_IS_CLEANINVALID(ar_type)           ? `CA53_REQ_CLEANINVALID : \
                                                         `CA53_BIU_STB_IS_MAKEINVALID(ar_type)            ? `CA53_REQ_MAKEINVALID : \
                                                         `CA53_BIU_STB_IS_CLEANSETWAY(ar_type)            ? `CA53_REQ_CLEANSETWAY : \
                                                         `CA53_BIU_STB_IS_CLEANINVSETWAY(ar_type)         ? `CA53_REQ_CLEANINVSETWAY : \
                                                         `CA53_BIU_STB_IS_WRITENOSNOOP(ar_type, ar_attrs) ? `CA53_REQ_WRITENOSNOOP : \
                                                         `CA53_BIU_STB_IS_WRITEUNIQUE(ar_type, ar_attrs)  ? `CA53_REQ_WRITEUNIQUE : \
                                                                                                            `CA53_REQ_DVM)
`define CA53_BIU_DCU_TO_ARTYPE(ar_type, excl)           (excl ? `CA53_REQ_READUNIQUE : \
                                                                `CA53_REQ_READNOSNOOP)

`define CA53_BIU_ARTYPE_IS_CP15(ar_type)                ((ar_type == `CA53_REQ_CLEANUNIQUE)    | \
                                                         (ar_type == `CA53_REQ_CLEANSHARED)    | \
                                                         (ar_type == `CA53_REQ_CLEANINVALID)   | \
                                                         (ar_type == `CA53_REQ_MAKEINVALID)    | \
                                                         (ar_type == `CA53_REQ_CLEANSETWAY)    | \
                                                         (ar_type == `CA53_REQ_CLEANINVSETWAY) | \
                                                         (ar_type == `CA53_REQ_DVM))

`define CA53_BIU_ARTYPE_IS_BAR(ar_type)                 ((ar_type == `CA53_REQ_DSB) | \
                                                         (ar_type == `CA53_REQ_DMB))

`define CA53_ACE_LOCK_NORMAL                            1'b0

`define CA53_BIU_UPPER_DW                               3

//-----------------------------------------------------------------------------
// DVM ops defitions
//-----------------------------------------------------------------------------

`define CA53_BIU_DVM_EL3                                2'b01
`define CA53_BIU_DVM_OS_BOTH                            2'b00
`define CA53_BIU_DVM_OS_HYP                             2'b11
`define CA53_BIU_DVM_OS_GUEST                           2'b10
`define CA53_BIU_DVM_SEC_BOTH                           2'b00
`define CA53_BIU_DVM_SEC_SEC                            2'b10
`define CA53_BIU_DVM_SEC_NSEC                           2'b11

//-----------------------------------------------------------------------------
// MBIST related macros
//-----------------------------------------------------------------------------

`define DCU_MBIST_ARRAY_W                               6

`define CA53_BIU_MBIST_ARRAY_FOR_DCU_DATA(mbist_array)  (mbist_array[5:3] == 3'b000)
`define CA53_BIU_MBIST_ARRAY_FOR_DCU_TAG(mbist_array)   (mbist_array[5:2] == 4'b0010)
`define CA53_BIU_MBIST_ARRAY_FOR_DCU_DIRTY(mbist_array) (mbist_array[5:2] == 4'b0011)
`define CA53_BIU_MBIST_ARRAY_FOR_IFU(mbist_array)       (mbist_array[5:3] == 3'b010)
`define CA53_BIU_MBIST_ARRAY_FOR_TLB(mbist_array)       (mbist_array[5:3] == 3'b100)

`define CA53_BIU_MBIST_ARRAY_FOR_BANK0(mbist_array)     (mbist_array[2:0] == 3'b000)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK1(mbist_array)     (mbist_array[2:0] == 3'b001)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK2(mbist_array)     (mbist_array[2:0] == 3'b010)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK3(mbist_array)     (mbist_array[2:0] == 3'b011)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK4(mbist_array)     (mbist_array[2:0] == 3'b100)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK5(mbist_array)     (mbist_array[2:0] == 3'b101)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK6(mbist_array)     (mbist_array[2:0] == 3'b110)
`define CA53_BIU_MBIST_ARRAY_FOR_BANK7(mbist_array)     (mbist_array[2:0] == 3'b111)

//-----------------------------------------------------------------------------
// A onehot mux of an array of values
//-----------------------------------------------------------------------------

`define CA53_BIU_ONEHOT_MUX(dst, width, start_width, sel, src, depth, start_depth, genlabel) \
  generate if (1) begin : genlabel \
    genvar mux_w; \
    genvar mux_d; \
\
    wire [(width*depth)-1:0] src_pkd; \
\
    for (mux_w = start_width; mux_w < (width + start_width); mux_w = mux_w + 1) begin : g_mux_w \
      for (mux_d = start_depth; mux_d < (depth + start_depth); mux_d = mux_d + 1) begin : g_mux_d \
        assign src_pkd[(mux_w-start_width)*depth+(mux_d-start_depth)] = src[mux_d][mux_w]; \
      end \
\
      assign dst[mux_w] = |(sel[depth+start_depth-1:start_depth] & src_pkd[(mux_w-start_width)*depth+:depth]); \
    end \
  end endgenerate

//-----------------------------------------------------------------------------
// Undefs
//-----------------------------------------------------------------------------
`else

/*ARMAUTO_UNDEF*/
`undef CA53_BIU_DCU_NC_ID_NUM
`undef CA53_BIU_DCU_NC_ID_NUM_W
`undef CA53_BIU_RBUFS_NUM
`undef CA53_BIU_RBUFS_NUM_W
`undef CA53_BIU_RBUFS_NUM_W_INC
`undef CA53_BIU_IFU_RBUF_ID
`undef CA53_BIU_IFU_ONEHOT_RBUF
`undef CA53_BIU_DR_RESP_ECC_B
`undef CA53_BIU_DR_RESP_AGE_B
`undef CA53_BIU_LF_DESCR_NUM
`undef CA53_BIU_LF_DESCR_NUM_W
`undef CA53_BIU_LF_MASTERS_NUM
`undef CA53_BIU_PF_STREAM_NUM
`undef CA53_BIU_PF_STREAM_NUM_W
`undef CA53_BIU_PF_STREAM_HZ_ADDR_MASK
`undef CA53_BIU_DC1_LF
`undef CA53_BIU_CCB
`undef CA53_BIU_DC3_LF
`undef CA53_BIU_DC2_LF
`undef CA53_BIU_TLB_LF
`undef CA53_BIU_STB0_LF
`undef CA53_BIU_STB1_LF
`undef CA53_BIU_STB2_LF
`undef CA53_BIU_STB3_LF
`undef CA53_BIU_STB4_LF
`undef CA53_BIU_PF_LF
`undef CA53_BIU_LF_MASTER_NONE
`undef CA53_BIU_LF_MASTER_DCU
`undef CA53_BIU_LF_MASTER_DCU_LDREX
`undef CA53_BIU_LF_MASTER_DCU_PLDW
`undef CA53_BIU_LF_MASTER_TLB
`undef CA53_BIU_LF_MASTER_STB
`undef CA53_BIU_LF_MASTER_PF
`undef CA53_BIU_LF_MASTER_PF_PLDW
`undef CA53_BIU_LF_MASTER_TLB_LD_PENDING
`undef CA53_BIU_LF_MASTER_TLB_LD_DONE
`undef CA53_BIU_LF_MASTER_PF_ID0
`undef CA53_BIU_LF_MASTER_PF_ID1
`undef CA53_BIU_LF_MASTER_PF_ID2
`undef CA53_BIU_LF_MASTER_PF_ID3
`undef CA53_BIU_LF_FOR_TLB
`undef CA53_BIU_LF_FOR_TLB_LD_PENDING
`undef CA53_BIU_LF_FOR_LDREX
`undef CA53_BIU_LF_FOR_WRITE
`undef CA53_BIU_LF_ELIGIBLE_FOR_RAMODE_LEAVE
`undef CA53_BIU_LF_ELIGIBLE_FOR_PF
`undef CA53_BIU_REQ_NUM
`undef CA53_BIU_ONEHOT2BIN
`undef CA53_BIU_ONEHOT2BIN_5_3
`undef CA53_BIU_ONEHOT2BIN_8_3
`undef CA53_BIU_DC3_REQ
`undef CA53_BIU_DC2_REQ
`undef CA53_BIU_LF_REQ
`undef CA53_BIU_TLB_REQ
`undef CA53_BIU_IFU_REQ
`undef CA53_BIU_ECC_REQ
`undef CA53_BIU_STB_REQ
`undef CA53_RID_IFU_MASK
`undef CA53_RID_STB_MASK
`undef CA53_RID_DCU_MASK
`undef CA53_RID_LF_MASK
`undef CA53_REQ_LEN3
`undef CA53_REQ_LEN1
`undef CA53_REQ_LEN0
`undef CA53_BIU_REQ_BURST_INCR
`undef CA53_BIU_REQ_BURST_WRAP
`undef CA53_BIU_STB_IS_WRITE
`undef CA53_BIU_STB_IS_WRITENOSNOOP
`undef CA53_BIU_STB_IS_WRITEUNIQUE
`undef CA53_BIU_STB_IS_CLEANUNIQUE
`undef CA53_BIU_STB_IS_CLEANSHARED
`undef CA53_BIU_STB_IS_CLEANINVALID
`undef CA53_BIU_STB_IS_MAKEINVALID
`undef CA53_BIU_STB_IS_CLEANSETWAY
`undef CA53_BIU_STB_IS_CLEANINVSETWAY
`undef CA53_BIU_STB_IS_DVM
`undef CA53_BIU_STB_IS_DVM_FOR_IS
`undef CA53_BIU_STB_IS_ICINV
`undef CA53_BIU_RID_IS_FOR_IFU
`undef CA53_BIU_RID_IS_FOR_DCU
`undef CA53_BIU_RID_IS_FOR_DCU_NC
`undef CA53_BIU_RID_IS_FOR_PLD_L2
`undef CA53_BIU_RID_IS_FOR_TLB
`undef CA53_BIU_RID_IS_FOR_ECC
`undef CA53_BIU_RID_IS_FOR_STB
`undef CA53_BIU_RID_IS_FOR_READ
`undef CA53_BIU_RID_IS_FOR_WRITE
`undef CA53_BIU_RID_IS_FOR_LF
`undef CA53_BIU_STB_TO_ARTYPE
`undef CA53_BIU_DCU_TO_ARTYPE
`undef CA53_BIU_ARTYPE_IS_CP15
`undef CA53_BIU_ARTYPE_IS_BAR
`undef CA53_ACE_LOCK_NORMAL
`undef CA53_BIU_UPPER_DW
`undef CA53_BIU_DVM_EL3
`undef CA53_BIU_DVM_OS_BOTH
`undef CA53_BIU_DVM_OS_HYP
`undef CA53_BIU_DVM_OS_GUEST
`undef CA53_BIU_DVM_SEC_BOTH
`undef CA53_BIU_DVM_SEC_SEC
`undef CA53_BIU_DVM_SEC_NSEC
`undef DCU_MBIST_ARRAY_W
`undef CA53_BIU_MBIST_ARRAY_FOR_DCU_DATA
`undef CA53_BIU_MBIST_ARRAY_FOR_DCU_TAG
`undef CA53_BIU_MBIST_ARRAY_FOR_DCU_DIRTY
`undef CA53_BIU_MBIST_ARRAY_FOR_IFU
`undef CA53_BIU_MBIST_ARRAY_FOR_TLB
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK0
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK1
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK2
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK3
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK4
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK5
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK6
`undef CA53_BIU_MBIST_ARRAY_FOR_BANK7
`undef CA53_BIU_ONEHOT_MUX
/*END*/

`endif
