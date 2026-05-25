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

`ifndef CA53_UNDEFINE

`define CA53_ACE_AWSIZE_W    3
`define CA53_ACE_AWLEN_W     8
`define CA53_ACE_AWBURST_W   2
`define CA53_ACE_AWLOCK_W    1
`define CA53_ACE_AWCACHE_W   4
`define CA53_ACE_AWDOMAIN_W  2
`define CA53_ACE_AWPROT_W    3
`define CA53_ACE_AWQOS_W     4
`define CA53_ACE_AWSNOOP_W   3
`define CA53_ACE_AWBAR_W     2

`define CA53_ACE_BRESP_W     2

`define CA53_ACE_ARSIZE_W    3
`define CA53_ACE_ARLEN_W     8
`define CA53_ACE_ARBURST_W   2
`define CA53_ACE_ARLOCK_W    1
`define CA53_ACE_ARCACHE_W   4
`define CA53_ACE_ARDOMAIN_W  2
`define CA53_ACE_ARPROT_W    3
`define CA53_ACE_ARQOS_W     4
`define CA53_ACE_ARSNOOP_W   4
`define CA53_ACE_ARBAR_W     2

`define CA53_ACE_RRESP_W     4

`define CA53_ACE_ACLEN_W     4
`define CA53_ACE_ACBAR_W     1
`define CA53_ACE_ACPROT_W    3
`define CA53_ACE_ACSNOOP_W   4

`define CA53_ACE_CRRESP_W    5


`define CA53_ACE_SIZE_8BIT     3'b000
`define CA53_ACE_SIZE_16BIT    3'b001
`define CA53_ACE_SIZE_32BIT    3'b010
`define CA53_ACE_SIZE_64BIT    3'b011
`define CA53_ACE_SIZE_128BIT   3'b100
`define CA53_ACE_SIZE_256BIT   3'b101
`define CA53_ACE_SIZE_512BIT   3'b110
`define CA53_ACE_SIZE_1024BIT  3'b111

`define CA53_ACE_SIZE(sz)  ((sz <= 8)   ? `CA53_ACE_SIZE_8BIT   : \
                           (sz <= 16)  ? `CA53_ACE_SIZE_16BIT  : \
                           (sz <= 32)  ? `CA53_ACE_SIZE_32BIT  : \
                           (sz <= 64)  ? `CA53_ACE_SIZE_64BIT  : \
                           (sz <= 128) ? `CA53_ACE_SIZE_128BIT : \
                           (sz <= 256) ? `CA53_ACE_SIZE_256BIT : \
                           (sz <= 512) ? `CA53_ACE_SIZE_512BIT : \
                                         `CA53_ACE_SIZE_1024BIT)

`define CA53_ACE_BURST_FIXED 2'b00
`define CA53_ACE_BURST_INCR  2'b01
`define CA53_ACE_BURST_WRAP  2'b10

`define CA53_ACE_LOCK_EXCLUSIVE_B  0

`define CA53_ACE_CACHE_BUFFERABLE_B  0
`define CA53_ACE_CACHE_MODIFIABLE_B  1
`define CA53_ACE_CACHE_READ_ALLOC_B  2
`define CA53_ACE_CACHE_WRITE_ALLOC_B 3

`define CA53_ACE_MEMTYPE_SO      2'b00
`define CA53_ACE_MEMTYPE_DEVICE  2'b01
`define CA53_ACE_MEMTYPE_NORMAL  2'b10

`define CA53_ACE_MEMTYPE(cache) ((cache) == 4'b0000 ? `CA53_ACE_MEMTYPE_SO     : \
                                (cache) == 4'b0001 ? `CA53_ACE_MEMTYPE_DEVICE : \
                                                     `CA53_ACE_MEMTYPE_NORMAL)

`define CA53_ACE_CACHEABLE(cache) ((((cache) & 4'b0010) == 4'b0010) &           \
                                  (((cache) & 4'b0100) | ((cache) & 4'b1000)))

`define CA53_ACE_DOMAIN_NS     2'b00
`define CA53_ACE_DOMAIN_INNER  2'b01
`define CA53_ACE_DOMAIN_OUTER  2'b10
`define CA53_ACE_DOMAIN_SYSTEM 2'b11

`define CA53_ACE_PROT_PRIV_B 0
`define CA53_ACE_PROT_NS_B   1
`define CA53_ACE_PROT_INST_B 2

`define CA53_ACE_READ                4'b0000
`define CA53_ACE_READNOSNOOP         4'b0000
`define CA53_ACE_READONCE            4'b0000
`define CA53_ACE_READSHARED          4'b0001
`define CA53_ACE_READCLEAN           4'b0010
`define CA53_ACE_READNOTSHAREDDIRTY  4'b0011
`define CA53_ACE_READUNIQUE          4'b0111
`define CA53_ACE_CLEANSHARED         4'b1000
`define CA53_ACE_CLEANINVALID        4'b1001
`define CA53_ACE_CLEANUNIQUE         4'b1011
`define CA53_ACE_MAKEUNIQUE          4'b1100
`define CA53_ACE_MAKEINVALID         4'b1101
`define CA53_ACE_DVM_COMPLETE        4'b1110
`define CA53_ACE_DVM_MESSAGE         4'b1111

`define CA53_ACE_WRITENOSNOOP        3'b000
`define CA53_ACE_WRITEUNIQUE         3'b000
`define CA53_ACE_WRITELINEUNIQUE     3'b001
`define CA53_ACE_WRITECLEAN          3'b010
`define CA53_ACE_WRITEBACK           3'b011
`define CA53_ACE_EVICT               3'b100
`define CA53_ACE_WRITEBACKUC         3'b101

`define CA53_ACE_BAR_NORMAL  2'b00
`define CA53_ACE_BAR_MEM     2'b01
`define CA53_ACE_BAR_IGNORE  2'b10
`define CA53_ACE_BAR_SYNC    2'b11

`define CA53_ACE_RESP_OKAY   2'b00
`define CA53_ACE_RESP_EXOKAY 2'b01
`define CA53_ACE_RESP_SLVERR 2'b10
`define CA53_ACE_RESP_DECERR 2'b11

`define CA53_ACE_RRESP_RESP_B      1:0
`define CA53_ACE_RRESP_RESP_W      2
`define CA53_ACE_RRESP_PASSDIRTY_B 2
`define CA53_ACE_RRESP_ISSHARED_B  3

`define CA53_ACE_CRRESP_DATATRANSFER_B 0
`define CA53_ACE_CRRESP_ERROR_B        1
`define CA53_ACE_CRRESP_PASSDIRTY_B    2
`define CA53_ACE_CRRESP_ISSHARED_B     3
`define CA53_ACE_CRRESP_WASUNIQUE_B    4

`define CA53_ACE_DVM_TLBINV           3'b000
`define CA53_ACE_DVM_BPINV            3'b001
`define CA53_ACE_DVM_PHYSICINV        3'b010
`define CA53_ACE_DVM_VIRTICINV        3'b011
`define CA53_ACE_DVM_SYNC             3'b100
`define CA53_ACE_DVM_HINT             3'b110

`define CA53_ACE_DVM_OS_HYP    2'b11
`define CA53_ACE_DVM_OS_GUEST  2'b10
`define CA53_ACE_DVM_OS_EL3    2'b01
`define CA53_ACE_DVM_OS_BOTH   2'b00

`define CA53_ACE_DVM_SEC_SEC   2'b10
`define CA53_ACE_DVM_SEC_NSEC  2'b11
`define CA53_ACE_DVM_SEC_BOTH  2'b00

// Undefines
`else
/*ARMAUTO_UNDEF*/
`undef CA53_ACE_AWSIZE_W
`undef CA53_ACE_AWLEN_W
`undef CA53_ACE_AWBURST_W
`undef CA53_ACE_AWLOCK_W
`undef CA53_ACE_AWCACHE_W
`undef CA53_ACE_AWDOMAIN_W
`undef CA53_ACE_AWPROT_W
`undef CA53_ACE_AWQOS_W
`undef CA53_ACE_AWSNOOP_W
`undef CA53_ACE_AWBAR_W
`undef CA53_ACE_BRESP_W
`undef CA53_ACE_ARSIZE_W
`undef CA53_ACE_ARLEN_W
`undef CA53_ACE_ARBURST_W
`undef CA53_ACE_ARLOCK_W
`undef CA53_ACE_ARCACHE_W
`undef CA53_ACE_ARDOMAIN_W
`undef CA53_ACE_ARPROT_W
`undef CA53_ACE_ARQOS_W
`undef CA53_ACE_ARSNOOP_W
`undef CA53_ACE_ARBAR_W
`undef CA53_ACE_RRESP_W
`undef CA53_ACE_ACLEN_W
`undef CA53_ACE_ACBAR_W
`undef CA53_ACE_ACPROT_W
`undef CA53_ACE_ACSNOOP_W
`undef CA53_ACE_CRRESP_W
`undef CA53_ACE_SIZE_8BIT
`undef CA53_ACE_SIZE_16BIT
`undef CA53_ACE_SIZE_32BIT
`undef CA53_ACE_SIZE_64BIT
`undef CA53_ACE_SIZE_128BIT
`undef CA53_ACE_SIZE_256BIT
`undef CA53_ACE_SIZE_512BIT
`undef CA53_ACE_SIZE_1024BIT
`undef CA53_ACE_SIZE
`undef CA53_ACE_BURST_FIXED
`undef CA53_ACE_BURST_INCR
`undef CA53_ACE_BURST_WRAP
`undef CA53_ACE_LOCK_EXCLUSIVE_B
`undef CA53_ACE_CACHE_BUFFERABLE_B
`undef CA53_ACE_CACHE_MODIFIABLE_B
`undef CA53_ACE_CACHE_READ_ALLOC_B
`undef CA53_ACE_CACHE_WRITE_ALLOC_B
`undef CA53_ACE_MEMTYPE_SO
`undef CA53_ACE_MEMTYPE_DEVICE
`undef CA53_ACE_MEMTYPE_NORMAL
`undef CA53_ACE_MEMTYPE
`undef CA53_ACE_CACHEABLE
`undef CA53_ACE_DOMAIN_NS
`undef CA53_ACE_DOMAIN_INNER
`undef CA53_ACE_DOMAIN_OUTER
`undef CA53_ACE_DOMAIN_SYSTEM
`undef CA53_ACE_PROT_PRIV_B
`undef CA53_ACE_PROT_NS_B
`undef CA53_ACE_PROT_INST_B
`undef CA53_ACE_READ
`undef CA53_ACE_READNOSNOOP
`undef CA53_ACE_READONCE
`undef CA53_ACE_READSHARED
`undef CA53_ACE_READCLEAN
`undef CA53_ACE_READNOTSHAREDDIRTY
`undef CA53_ACE_READUNIQUE
`undef CA53_ACE_CLEANSHARED
`undef CA53_ACE_CLEANINVALID
`undef CA53_ACE_CLEANUNIQUE
`undef CA53_ACE_MAKEUNIQUE
`undef CA53_ACE_MAKEINVALID
`undef CA53_ACE_DVM_COMPLETE
`undef CA53_ACE_DVM_MESSAGE
`undef CA53_ACE_WRITENOSNOOP
`undef CA53_ACE_WRITEUNIQUE
`undef CA53_ACE_WRITELINEUNIQUE
`undef CA53_ACE_WRITECLEAN
`undef CA53_ACE_WRITEBACK
`undef CA53_ACE_EVICT
`undef CA53_ACE_WRITEBACKUC
`undef CA53_ACE_BAR_NORMAL
`undef CA53_ACE_BAR_MEM
`undef CA53_ACE_BAR_IGNORE
`undef CA53_ACE_BAR_SYNC
`undef CA53_ACE_RESP_OKAY
`undef CA53_ACE_RESP_EXOKAY
`undef CA53_ACE_RESP_SLVERR
`undef CA53_ACE_RESP_DECERR
`undef CA53_ACE_RRESP_RESP_B
`undef CA53_ACE_RRESP_RESP_W
`undef CA53_ACE_RRESP_PASSDIRTY_B
`undef CA53_ACE_RRESP_ISSHARED_B
`undef CA53_ACE_CRRESP_DATATRANSFER_B
`undef CA53_ACE_CRRESP_ERROR_B
`undef CA53_ACE_CRRESP_PASSDIRTY_B
`undef CA53_ACE_CRRESP_ISSHARED_B
`undef CA53_ACE_CRRESP_WASUNIQUE_B
`undef CA53_ACE_DVM_TLBINV
`undef CA53_ACE_DVM_BPINV
`undef CA53_ACE_DVM_PHYSICINV
`undef CA53_ACE_DVM_VIRTICINV
`undef CA53_ACE_DVM_SYNC
`undef CA53_ACE_DVM_HINT
`undef CA53_ACE_DVM_OS_HYP
`undef CA53_ACE_DVM_OS_GUEST
`undef CA53_ACE_DVM_OS_EL3
`undef CA53_ACE_DVM_OS_BOTH
`undef CA53_ACE_DVM_SEC_SEC
`undef CA53_ACE_DVM_SEC_NSEC
`undef CA53_ACE_DVM_SEC_BOTH
/*END*/

`endif
