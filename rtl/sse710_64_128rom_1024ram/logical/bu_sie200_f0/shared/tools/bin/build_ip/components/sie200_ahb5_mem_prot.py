#!/usr/bin/env python
#-----------------------------------------------------------------------------
#  The confidential and proprietary information contained in this file may
#  only be used by a person authorised under and to the extent permitted
#  by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#             (C) COPYRIGHT 2016-2017 ARM Limited or its affiliates.
#                 ALL RIGHTS RESERVED
#
#  This entire notice must be reproduced on all copies of this file
#  and copies of this file may only be made by a person if such person is
#  permitted to do so under the terms of a subsisting license agreement
#  from ARM Limited or its affiliates.
#
#     Checked In : Thu Jun 1 08:30:31 2017 +0100
#     Revision   : ff06b35
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base


class CTRL(base.Register):
    def __init__(self):
        super(CTRL, self).__init__()
        self.name = "CTRL"
        self.offset = "0x000"
        self.fields = [
            ( "RESERVED_3_0", "0", "4", "read-only" ),
            ( "CFG_SEC_RESP", "4", "1", "read-write" ),
            ( "RESERVED_5",   "5", "1", "read-only" ),
            ( "GATE_REQ",     "6", "1", "read-write" ),
            ( "GATE_ACK",     "7", "1", "read-only" ),
            ( "AUTOINC_EN",   "8", "1", "read-write" ),
            ( "RESERVED_30_9","9", "22","read-only" ),
            ( "SECCFGLOCK",   "31","1", "read-write" )
        ]
        self.reset = "0x00000100"


class BLK_MAX(base.Register):
    def __init__(self):
        super(BLK_MAX, self).__init__()
        self.name = "BLK_MAX"
        self.access = "read-only"
        self.offset = "0x010"
        self.fields = [
            ( "Block_Max", "0", "32", "read-only" )
        ]

class BLK_CFG(base.Register):
    def __init__(self):
        super(BLK_CFG, self).__init__()
        self.name = "BLK_CFG"
        self.access = "read-only"
        self.offset = "0x014"
        self.fields = [
            ( "BLK_CFG",          "0",  "4",  "read-only" ),
            ( "RESERVED_30_4",    "4", "27",  "read-only" ),
            ( "Init_in_progress", "31", "1",  "read-only" )

        ]

class BLK_IDX(base.Register):
    def __init__(self):
        super(BLK_IDX, self).__init__()
        self.name = "BLK_IDX"
        self.offset = "0x018"
        self.fields = [
            ( "Block_Index", "0", "32", "read-write" )
        ]

class BLK_LUT(base.Register):
    def __init__(self):
        super(BLK_LUT, self).__init__()
        self.name = "BLK_LUT"
        self.offset = "0x01C"
        self.fields = [
            ( "Block_LUT", "0", "32", "read-write" )
        ]

class INT_STAT(base.Register):
    def __init__(self):
        super(INT_STAT, self).__init__()
        self.name = "INT_STAT"
        self.offset = "0x020"
        self.access = "read-only"
        self.fields = [
            ( "MPC_IRQ_Triggered", "0", "1", "read-only" ),
            ( "RESERVED_31_1",     "1", "31","read-only" ),

        ]


class INT_CLEAR(base.Register):
    def __init__(self):
        super(INT_CLEAR, self).__init__()
        self.name = "INT_CLEAR"
        self.offset = "0x024"
        self.fields = [
            ( "MPC_IRQ_Clear", "0", "1", "write-only" ),
            ( "RESERVED_31_1", "1", "31","read-only" ),

        ]

class INT_EN(base.Register):
    def __init__(self):
        super(INT_EN, self).__init__()
        self.name = "INT_EN"
        self.offset = "0x028"
        self.reset = "0x00000001"
        self.fields = [
            ( "MPC_IRQ_Enable", "0", "1", "read-write" ),
            ( "RESERVED_31_1",  "1", "31","read-only" ),

        ]


class INT_INFO1(base.Register):
    def __init__(self):
        super(INT_INFO1, self).__init__()
        self.name = "INT_INFO1"
        self.offset = "0x02C"
        self.access = "read-only"
        self.fields = [
            ( "HADDR_Field", "0", "32", "read-only" )
        ]

class INT_INFO2(base.Register):
    def __init__(self):
        super(INT_INFO2, self).__init__()
        self.name = "INT_INFO2"
        self.offset = "0x030"
        self.access = "read-only"
        self.fields = [
            ( "HMASTER_Field", "0",   "16", "read-only" ),
            ( "HNONSEC_Field", "16",  "1", "read-only" ),
            ( "CFG_NS_Field",  "17",  "1", "read-only" ),
            ( "RESERVED_31_18","18",  "14","read-only" ),
        ]

class INT_SET(base.Register):
    def __init__(self):
        super(INT_SET, self).__init__()
        self.name = "INT_SET"
        self.offset = "0x034"
        self.fields = [
            ( "MPC_IRQ_Set",  "0", "1", "write-only" ),
            ( "RESERVED_31_1","1", "31","read-only" ),
        ]

class PIDR4(base.Register):
    def __init__(self):
        super(PIDR4, self).__init__()
        self.name = "PIDR4"
        self.offset = "0xfd0"
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
        self.offset = "0xfd4"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR6(base.Register):
    def __init__(self):
        super(PIDR6, self).__init__()
        self.name = "PIDR6"
        self.offset = "0xfd8"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR7(base.Register):
    def __init__(self):
        super(PIDR7, self).__init__()
        self.name = "PIDR7"
        self.offset = "0xfdc"
        self.access = "read-only"
        self.reset = "0x00000000"
        self.fields = [
            ( "RESERVED_31_0","0", "32","read-only" ),
        ]

class PIDR0(base.Register):
    def __init__(self):
        super(PIDR0, self).__init__()
        self.name = "PIDR0"
        self.offset = "0xfe0"
        self.access = "read-only"
        self.reset = "0x00000060"
        self.fields = [
            ( "PART_0",       "0", "8", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),

        ]

class PIDR1(base.Register):
    def __init__(self):
        super(PIDR1, self).__init__()
        self.name = "PIDR1"
        self.offset = "0xfe4"
        self.access = "read-only"
        self.reset = "0x000000b8"
        self.fields = [
            ( "PART_1",       "0", "4", "read-only" ),
            ( "DES_0",        "4", "4", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class PIDR2(base.Register):
    def __init__(self):
        super(PIDR2, self).__init__()
        self.name = "PIDR2"
        self.offset = "0xfe8"
        self.access = "read-only"
        self.reset = "0x0000001b"
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
        self.offset = "0xfec"
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
        self.offset = "0xff0"
        self.access = "read-only"
        self.reset = "0x0000000d"
        self.fields = [
            ( "PRMBL_0",      "0", "8", "read-only" ),
            ( "RESERVED_31_8","8", "24","read-only" ),
        ]

class CIDR1(base.Register):
    def __init__(self):
        super(CIDR1, self).__init__()
        self.name = "CIDR1"
        self.offset = "0xff4"
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
        self.offset = "0xff8"
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
        self.offset = "0xffc"
        self.access = "read-only"
        self.reset = "0x000000b1"
        self.fields = [
            ( "PRMBL_3",      "0", "4", "read-only" ),
            ( "RESERVED_31_4","4", "28","read-only" ),
        ]



class sie200_ahb5_mem_prot(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_mem_prot, self).__init__()

        self.name = "sie200_ahb5_mem_prot"
        self.version = "r0p1_1"
        self.description = "AHB5 Memory Protection Controller"

        self.GetParameter("ADDR_WIDTH").value = "18"
        self.GetParameter("ADDR_WIDTH").description = "Address Bus Width. Minimum width is BLK_SIZE + 1"

        parameter = base.Parameter("BLK_SIZE")
        parameter.description = "Block size: 1 << (BLK_SIZE + 5) bytes. Enables a minimum of 32 byte, maximum 1 MB large blocks"
        parameter.value = "3"
        parameter.minimum = "0"
        parameter.maximum = "15"
        self.parameters.append(parameter)

        parameter = base.Parameter("GATE_RESP")
        parameter.description = "Response on data AHB when accessed during programming lock"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("GATE_PRESENT")
        parameter.description = "Gating feature is present in MPC (0: disabled, 1:enabled (default))"
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("APB_ADDR_WIDTH")
        parameter.description = "Constant parameter for the APB Address width"
        parameter.value = "12"
        parameter.usage = "constant"
        self.parameters.append(parameter)

        parameter = base.Parameter("APB_DATA_WIDTH")
        parameter.description = "Constant parameter for the APB Data width"
        parameter.value = "32"
        parameter.usage = "constant"
        self.parameters.append(parameter)

        apb_if = sie200_base.apbif(0,"","h","","0x1000")
        apb_if.awidth = "$APB_ADDR_WIDTH"
        apb_if.dwidth = "$APB_DATA_WIDTH"
        apb_if.addressBlocks.append(("0x00000000", "0x00001000", "register"))

        ahbif_s = sie200_base.ahbif("_s", "")
        ahbif_m = sie200_base.ahbif("_m", "")
        ahbif_s.bridges.append((ahbif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(ahbif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            ahbif_m,
            apb_if,
            sie200_base.irqif("mpc", "hclk"),
            sie200_base.internalInterrupt("mpc", sig_enable=1, clk_name="hclk"),
            sie200_base.dyncfgif("cfg_init_value","hclk"),

        ]
        self.interfaces.extend(interfaces)

        regs = [
            CTRL(),
            BLK_MAX(),
            BLK_CFG(),
            BLK_IDX(),
            BLK_LUT(),
            INT_STAT(),
            INT_CLEAR(),
            INT_EN(),
            INT_INFO1(),
            INT_INFO2(),
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
            os.path.join("..","..",self.name,"verilog",self.name + "_lut.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_sec_gate.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_reg_bank.v")
        ]
        self.files.extend(files)


    def Configure(self,uniquifier):
        if(super(sie200_ahb5_mem_prot,self).Configure(uniquifier)):

            # Set reset values of BLK_MAX and BLK_CFG
            self.aw       = int(self.GetParameter("ADDR_WIDTH").value)
            self.blk_size = int(self.GetParameter("BLK_SIZE").value)

            if( self.aw < self.blk_size + 5):
                print "ERROR: ADDR_WIDTH (%d) shall be larger than BLK_SIZE (%d) + 5" % (self.aw, self.blk_size)
                return False

            if ((self.aw - self.blk_size - 10) > 0):
                lut_addr_width = self.aw - self.blk_size - 10
            else:
                lut_addr_width = 0

            if (lut_addr_width > 0):
                lut_data_width = 32
            else:
                lut_data_width = 1 << (self.aw - self.blk_size -5)

            self.registers[1].reset = str(hex((1 << lut_addr_width) - 1))
            self.registers[2].reset = str(hex(self.blk_size))


            if (int(self.GetParameter("GATE_PRESENT").value) == 0):
                self.registers[0].fields = [
                    ( "RESERVED_3_0", "0", "4", "read-only" ),
                    ( "CFG_SEC_RESP", "4", "1", "read-write" ),
                    ( "RESERVED_7_5", "5", "3", "read-only" ),
                    ( "AUTOINC_EN",   "8", "1", "read-write" ),
                    ( "RESERVED_30_9","9", "22","read-only" ),
                    ( "SECCFGLOCK",   "31","1", "read-write" )
                ]

            if (lut_addr_width == 0):
                # autoinc_en
                self.registers[0].fields = [("RESERVED_8", "8", "1", "read-only") if field[0] == "AUTOINC_EN" else field for field in self.registers[0].fields]
                # blk_idx
                self.registers[3].fields = [
                    ( "RESERVED", "0", "32", "read-only" )
                ]
                # blk_lut
                if (lut_data_width != 32):
                    self.registers[4].fields = [
                        ( "Block_LUT", "0",                 str(lut_data_width),    "read-write" ),
                        ( "RESERVED",  str(lut_data_width), str(32-lut_data_width), "read-only"  )
                    ]
            else:
                # blk_idx
                self.registers[3].fields = [
                    ( "Block_Index", "0",                 str(lut_addr_width),    "read-write" ),
                    ( "RESERVED",    str(lut_addr_width), str(32-lut_addr_width), "read-only"  )
                ]

            return True
        return False
