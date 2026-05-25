#!/usr/bin/env python
#-----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#             (C) COPYRIGHT 2016 ARM Limited or its affiliates.
#                 ALL RIGHTS RESERVED
#
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from ARM Limited or its affiliates.
#
#     Checked In : Mon Dec 5 13:50:08 2016 +0000
#     Revision   : 47bc7f2
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base


class NS_DATA0(base.Register):
    def __init__(self):
        super(NS_DATA0, self).__init__()
        self.name = "NS_DATA0"
        self.offset = "0x000"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class NS_DATA1(base.Register):
    def __init__(self):
        super(NS_DATA1, self).__init__()
        self.name = "NS_DATA1"
        self.offset = "0x004"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class NS_DATA2(base.Register):
    def __init__(self):
        super(NS_DATA2, self).__init__()
        self.name = "NS_DATA2"
        self.offset = "0x008"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class NS_DATA3(base.Register):
    def __init__(self):
        super(NS_DATA3, self).__init__()
        self.name = "NS_DATA3"
        self.offset = "0x00C"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]


class S_DATA0(base.Register):
    def __init__(self):
        super(S_DATA0, self).__init__()
        self.name = "S_DATA0"
        self.offset = "0x010"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class S_DATA1(base.Register):
    def __init__(self):
        super(S_DATA1, self).__init__()
        self.name = "S_DATA1"
        self.offset = "0x014"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class S_DATA2(base.Register):
    def __init__(self):
        super(S_DATA2, self).__init__()
        self.name = "S_DATA2"
        self.offset = "0x018"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class S_DATA3(base.Register):
    def __init__(self):
        super(S_DATA3, self).__init__()
        self.name = "S_DATA3"
        self.offset = "0x01C"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class UNCHK_DATA0(base.Register):
    def __init__(self):
        super(UNCHK_DATA0, self).__init__()
        self.name = "UNCHK_DATA0"
        self.offset = "0x020"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class UNCHK_DATA1(base.Register):
    def __init__(self):
        super(UNCHK_DATA1, self).__init__()
        self.name = "UNCHK_DATA1"
        self.offset = "0x024"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class UNCHK_DATA2(base.Register):
    def __init__(self):
        super(UNCHK_DATA2, self).__init__()
        self.name = "UNCHK_DATA2"
        self.offset = "0x028"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class UNCHK_DATA3(base.Register):
    def __init__(self):
        super(UNCHK_DATA3, self).__init__()
        self.name = "UNCHK_DATA3"
        self.offset = "0x02C"
        self.access = "read-write"
        self.fields = [
            ( "DATA_REGISTER", "0",   "32", "read-write" ),
        ]

class INT_STAT(base.Register):
    def __init__(self):
        super(INT_STAT, self).__init__()
        self.name = "INT_STAT"
        self.offset = "0x030"
        self.access = "read-only"
        self.fields = [
            ( "EG_SLV_IRQ_Triggered", "0", "1", "read-only" ),
            ( "RESERVED_31_1",     "1", "31","read-only" ),
        ]


class INT_CLEAR(base.Register):
    def __init__(self):
        super(INT_CLEAR, self).__init__()
        self.name = "INT_CLEAR"
        self.offset = "0x034"
        self.access = "read-write"
        self.fields = [
            ( "EG_SLV_IRQ_Clear", "0", "1", "write-only" ),
            ( "RESERVED_31_1", "1", "31","read-only" ),

        ]

class INT_MASK(base.Register):
    def __init__(self):
        super(INT_MASK, self).__init__()
        self.name = "INT_MASK"
        self.offset = "0x038"
        self.access = "read-write"
        self.fields = [
            ( "EG_SLV_IRQ_Mask", "0", "1", "read-write" ),
            ( "RESERVED_31_1",  "1", "31","read-only" ),

        ]

class INT_SET(base.Register):
    def __init__(self):
        super(INT_SET, self).__init__()
        self.name = "INT_SET"
        self.offset = "0x03C"
        self.access = "read-write"
        self.fields = [
            ( "EG_SLV_IRQ_Set",  "0", "1", "write-only" ),
            ( "RESERVED_31_1","1", "31","read-only" ),
        ]

class PIDR4(base.Register):
    def __init__(self):
        super(PIDR4, self).__init__()
        self.name = "PIDR4"
        self.offset = "0xFD0"
        self.access = "read-only"
        self.reset = "0x00000004"
        self.fields = [
            ( "DES_2",        "0", "4", "read-only" ),
            ( "SIZE",         "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class PIDR5(base.Register):
    def __init__(self):
        super(PIDR5, self).__init__()
        self.name = "PIDR5"
        self.offset = "0xFD4"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR6(base.Register):
    def __init__(self):
        super(PIDR6, self).__init__()
        self.name = "PIDR6"
        self.offset = "0xFD8"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR7(base.Register):
    def __init__(self):
        super(PIDR7, self).__init__()
        self.name = "PIDR7"
        self.offset = "0xFDC"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR0(base.Register):
    def __init__(self):
        super(PIDR0, self).__init__()
        self.name = "PIDR0"
        self.offset = "0xFE0"
        self.access = "read-only"
        self.reset = "0x00000061"
        self.fields = [
            ( "PART_0",       "0", "8", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),

        ]

class PIDR1(base.Register):
    def __init__(self):
        super(PIDR1, self).__init__()
        self.name = "PIDR1"
        self.offset = "0xFE4"
        self.access = "read-only"
        self.reset = "0x000000B8"
        self.fields = [
            ( "PART_1",       "0", "4", "read-only" ),
            ( "DES_0",        "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class PIDR2(base.Register):
    def __init__(self):
        super(PIDR2, self).__init__()
        self.name = "PIDR2"
        self.offset = "0xFE8"
        self.access = "read-only"
        self.reset = "0x0000000B"
        self.fields = [
            ( "DES_1",        "0", "3", "read-only" ),
            ( "JEDEC",        "3", "1", "read-only" ),
            ( "REVISION",     "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class PIDR3(base.Register):
    def __init__(self):
        super(PIDR3, self).__init__()
        self.name = "PIDR3"
        self.offset = "0xFEC"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "CMOD",         "0", "4", "read-only" ),
            ( "REVAND",       "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class CIDR0(base.Register):
    def __init__(self):
        super(CIDR0, self).__init__()
        self.name = "CIDR0"
        self.offset = "0xFF0"
        self.access = "read-only"
        self.reset = "0x0000000D"
        self.fields = [
            ( "PRMBL_0",      "0", "8", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class CIDR1(base.Register):
    def __init__(self):
        super(CIDR1, self).__init__()
        self.name = "CIDR1"
        self.offset = "0xFF4"
        self.access = "read-only"
        self.reset = "0x000000F0"
        self.fields = [
            ( "PRMBL_1",      "0", "4", "read-only" ),
            ( "CLASS",        "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class CIDR2(base.Register):
    def __init__(self):
        super(CIDR2, self).__init__()
        self.name = "CIDR2"
        self.offset = "0xFF8"
        self.access = "read-only"
        self.reset = "0x00000005"
        self.fields = [
            ( "PRMBL_2",      "0", "4", "read-only" ),
            ( "RESERVED_31_4","4", "28","read-only" ),
        ]

class CIDR3(base.Register):
    def __init__(self):
        super(CIDR3, self).__init__()
        self.name = "CIDR3"
        self.offset = "0xFFC"
        self.access = "read-only"
        self.reset = "0x000000B1"
        self.fields = [
            ( "PRMBL_3",      "0", "4", "read-only" ),
            ( "RESERVED_31_4","4", "28","read-only" ),
        ]



class sie200_ahb5_eg_slave(base.Component):
    def __init__(self):
        super(sie200_ahb5_eg_slave, self).__init__()

        self.name = "sie200_ahb5_eg_slave"
        self.version = "r0p0_0"
        self.description = "AHB5 Example Slave Interface"

        ahbif= sie200_base.ahbif(mlock=0,excl=0,prot=0,burst=0)
        ahbif.addressBlocks.append(("0x00000000", "0x00001000", "register"))
        ahbif.awidth="12"
        ahbif.dwidth="32"
        ahbif.mwidth="0"
        ahbif.uwidth="0"


        interfaces = [
            ahbif,
            sie200_base.dyncfgif("cfg_sec_resp","hclk"),
            sie200_base.irqif("eg_slv", "hclk"),
            sie200_base.internalInterrupt("eg_slv", sig_enable=1, clk_name="hclk"),
        ]
        self.interfaces.extend(interfaces)

        regs = [
            NS_DATA0(),
            NS_DATA1(),
            NS_DATA2(),
            NS_DATA3(),
            S_DATA0(),
            S_DATA1(),
            S_DATA2(),
            S_DATA3(),
            UNCHK_DATA0(),
            UNCHK_DATA1(),
            UNCHK_DATA2(),
            UNCHK_DATA3(),
            INT_STAT(),
            INT_CLEAR(),
            INT_MASK(),
            INT_SET(),
            PIDR4(),
            PIDR5(),
            PIDR6(),
            PIDR7(),
            PIDR0(),
            PIDR1(),
            PIDR2(),
            PIDR3(),
            CIDR0(),
            CIDR1(),
            CIDR2(),
            CIDR3()
        ]

        self.registers.extend(regs)

        files = [
            os.path.join("..","..","shared","verilog","sie200_static_reg","verilog","sie200_static_reg.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_interface.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_reg.v")
        ]
        self.files.extend(files)
