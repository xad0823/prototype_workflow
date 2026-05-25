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
#     Checked In : Fri Feb 3 15:54:58 2017 +0000
#     Revision   : fd6a20f
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base

class DATA_IN(base.Register):
    def __init__(self):
        super(DATA_IN, self).__init__()
        self.name = "DATA_IN"
        self.offset = "0x000"
        self.access = "read-write"
        self.fields = [
            ( "DATA_VALUE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class DATA_OUT(base.Register):
    def __init__(self):
        super(DATA_OUT, self).__init__()
        self.name = "DATA_OUT"
        self.offset = "0x004"
        self.access = "read-write"
        self.fields = [
            ( "DATA_OUTPUT_VALUE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]

class OUT_EN_SET(base.Register):
    def __init__(self):
        super(OUT_EN_SET, self).__init__()
        self.name = "OUT_EN_SET"
        self.offset = "0x010"
        self.access = "read-write"
        self.fields = [
            ( "OUTPUT_ENABLE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class OUT_EN_CLR(base.Register):
    def __init__(self):
        super(OUT_EN_CLR, self).__init__()
        self.name = "OUT_EN_CLR"
        self.offset = "0x014"
        self.access = "read-write"
        self.fields = [
            ( "OUTPUT_ENABLE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class ALT_FUNC_SET(base.Register):
    def __init__(self):
        super(ALT_FUNC_SET, self).__init__()
        self.name = "ALT_FUNC_SET"
        self.offset = "0x018"
        self.access = "read-write"
        self.fields = [
            ( "ALTERNATE_FUNCTION", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class ALT_FUNC_CLR(base.Register):
    def __init__(self):
        super(ALT_FUNC_CLR, self).__init__()
        self.name = "ALT_FUNC_CLR"
        self.offset = "0x01C"
        self.access = "read-write"
        self.fields = [
            ( "ALTERNATE_FUNCTION", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]

class INT_EN_SET(base.Register):
    def __init__(self):
        super(INT_EN_SET, self).__init__()
        self.name = "INT_EN_SET"
        self.offset = "0x020"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_ENABLE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class INT_EN_CLR(base.Register):
    def __init__(self):
        super(INT_EN_CLR, self).__init__()
        self.name = "INT_EN_CLR"
        self.offset = "0x024"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_ENABLE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class INT_TYPE_SET(base.Register):
    def __init__(self):
        super(INT_TYPE_SET, self).__init__()
        self.name = "INT_TYPE_SET"
        self.offset = "0x028"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_TYPE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class INT_TYPE_CLR(base.Register):
    def __init__(self):
        super(INT_TYPE_CLR, self).__init__()
        self.name = "INT_TYPE_CLR"
        self.offset = "0x02C"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_TYPE", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class INT_POL_SET(base.Register):
    def __init__(self):
        super(INT_POL_SET, self).__init__()
        self.name = "INT_POL_SET"
        self.offset = "0x030"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_POLARITY", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]

class INT_POL_CLR(base.Register):
    def __init__(self):
        super(INT_POL_CLR, self).__init__()
        self.name = "INT_POL_CLR"
        self.offset = "0x034"
        self.access = "read-write"
        self.fields = [
            ( "INTERRUPT_POLARITY", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]

class INT_STATUS(base.Register):
    def __init__(self):
        super(INT_STATUS, self).__init__()
        self.name = "INT_STATUS"
        self.offset = "0x038"
        self.access = "read-write"
        self.fields = [
            ( "GPIO_IRQ_STATUS", "0", "16", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
        ]


class SEC_INT_STAT(base.Register):
    def __init__(self):
        super(SEC_INT_STAT, self).__init__()
        self.name = "SEC_INT_STAT"
        self.offset = "0x040"
        self.access = "read-only"
        self.fields = [
            ( "SEC_ACC_IRQ_Triggered", "0", "1", "read-only" ),
            ( "RESERVED_31_1",     "1", "31","read-only" ),
        ]


class SEC_INT_CLR(base.Register):
    def __init__(self):
        super(SEC_INT_CLR, self).__init__()
        self.name = "SEC_INT_CLR"
        self.offset = "0x044"
        self.access = "read-write"
        self.fields = [
            ( "SEC_ACC_IRQ_Clear", "0", "1", "write-only" ),
            ( "RESERVED_31_1", "1", "31","read-only" ),

        ]

class SEC_INT_MASK(base.Register):
    def __init__(self):
        super(SEC_INT_MASK, self).__init__()
        self.name = "SEC_INT_MASK"
        self.offset = "0x048"
        self.access = "read-write"
        self.fields = [
            ( "SEC_ACC_IRQ_Mask",     "0", "1", "read-write" ),
            ( "SEC_BITMASK_ERR_Mask", "1", "1", "read-write" ),
            ( "RESERVED_31_2",        "2", "30","read-only" ),

        ]

class SEC_INT_INFO1(base.Register):
    def __init__(self):
        super(SEC_INT_INFO1, self).__init__()
        self.name = "SEC_INT_INFO1"
        self.offset = "0x04C"
        self.access = "read-only"
        self.fields = [
            ( "HADDR_Field",      "0", "12",  "read-only" ),
            ( "BYTE_STROBE_Field","12","4",   "read-only" ),
            ( "NONSEC_Field",     "16","1",   "read-only" ),
            ( "WRITE_Field",      "17","1",   "read-only" ),
            ( "RESERVED_31_18",   "18","14",  "read-only" ),
        ]

class SEC_INT_INFO2(base.Register):
    def __init__(self):
        super(SEC_INT_INFO2, self).__init__()
        self.name = "SEC_INT_INFO2"
        self.offset = "0x050"
        self.access = "read-only"
        self.fields = [
            ( "HWDATA_Field", "0",   "32", "read-only" ),
        ]

class SEC_INT_SET(base.Register):
    def __init__(self):
        super(SEC_INT_SET, self).__init__()
        self.name = "SEC_INT_SET"
        self.offset = "0x054"
        self.access = "read-write"
        self.fields = [
            ( "SEC_ACC_IRQ_Set",  "0", "1", "write-only" ),
            ( "RESERVED_31_1","1", "31","read-only" ),
        ]

class PORT_NONSEC_MASK(base.Register):
    def __init__(self):
        super(PORT_NONSEC_MASK, self).__init__()
        self.name = "PORT_NONSEC_MASK"
        self.offset = "0x058"
        self.access = "read-only"
        self.fields = [
            ( "PORT_NONSEC_MASK_Parameter", "0",  "16", "read-only" ),
            ( "RESERVED_31_16",             "16", "16", "read-only" ),
        ]



class MASK_LOW_BYTE(base.Register):
    def __init__(self):
        super(MASK_LOW_BYTE, self).__init__()
        self.name = "MASK_LOW_BYTE"
        self.offset = "0x400"
        self.access = "read-write"
        self.dim    = "256"
        self.fields = [
            ( "LOW_BYTE_DATA", "0", "8", "read-write" ),
            ( "RESERVED_31_8","8","24", "read-only" ),
        ]

class MASK_HIGH_BYTE(base.Register):
    def __init__(self):
        super(MASK_HIGH_BYTE, self).__init__()
        self.name = "MASK_HIGH_BYTE"
        self.offset = "0x800"
        self.access = "read-write"
        self.dim    = "256"
        self.fields = [
            ( "RESERVED_0_8",   "0", "8", "read-only" ),
            ( "HIGH_BYTE_DATA", "8", "8", "read-write" ),
            ( "RESERVED_31_16","16","16", "read-only" ),
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
        self.reset = "0x00000062"
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




class sie200_ahb5_gpio(base.Component):
    def __init__(self):
        super(sie200_ahb5_gpio, self).__init__()

        self.name = "sie200_ahb5_gpio"
        self.version = "r0p0_0"
        self.description = "AHB5 GPIO Interface"

        parameter = base.Parameter("ALTERNATE_FUNC_MASK")
        parameter.description = "Alternate function bit mask. Indicates which ports can have an alternate function instead of GPIO logic. Default 16'hFFFF so all ports can have alternate functions"
        parameter.value = "65535"
        parameter.minimum = "0"
        parameter.maximum = "65535"
        self.parameters.append(parameter)

        parameter = base.Parameter("ALTERNATE_FUNC_DEFAULT")
        parameter.description = "Alternate function default value. Indicates which ports are used with alternate function. Default 16'h0000 so all pins are used as GPIO."
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "65535"
        self.parameters.append(parameter)

        parameter = base.Parameter("PORT_NONSEC_MASK")
        parameter.description = "Bitmask for selecting secure or non-secure PORTs. Default 16'h0000 so all ports are secure"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "65535"
        self.parameters.append(parameter)

        parameter = base.Parameter("ENDIANNESS")
        parameter.description = "Defines the endianness of the AHB interfaces: 0-little endian, 1:byte-invariant big endian, 2: word-invariant big endian"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "2"
        parameter.enumerations = ["0", "1", "2"]
        self.parameters.append(parameter)

        self.AddConstParam("ADDR_WIDTH","12")
        self.AddConstParam("DATA_WIDTH","32")
        self.AddConstParam("MASTER_WIDTH","0")
        self.AddConstParam("USER_WIDTH","0")

        ahbif= sie200_base.ahbif(mlock=0,excl=0, prot=0, burst=0)
        ahbif.addressBlocks.append(("0x00000000", "0x00001000", "register"))

        interfaces = [
            ahbif,
            sie200_base.dyncfgif("cfg_sec_resp","hclk"),
            sie200_base.irqif("sec_acc", "hclk"),
            sie200_base.internalInterrupt("sec_acc", sig_enable=1, clk_name="hclk"),
            sie200_base.irqif("comb_sec", "fclk"),
            sie200_base.irqif("comb_nonsec", "fclk"),
            sie200_base.gpioif("port_in", "in","fclk","hresetn", 16),
            sie200_base.gpioif("port_out","out","hclk","hresetn", 16),
            sie200_base.gpioif("port_en", "out","hclk","hresetn", 16),
            sie200_base.gpioif("port_func","out","hclk","hresetn", 16),
        ]

        for i in range(0,16):
            irq_ns = sie200_base.irqif("gpio_nonsec", "fclk", str(i), "15", "0"),
            interfaces += irq_ns
            irq_s  = sie200_base.irqif("gpio_sec", "fclk", str(i), "15", "0"),
            interfaces += irq_s

        self.interfaces.extend(interfaces)


        regs = [
            DATA_IN(),
            DATA_OUT(),
            OUT_EN_SET(),
            OUT_EN_CLR(),
            ALT_FUNC_SET(),
            ALT_FUNC_CLR(),
            INT_EN_SET(),
            INT_EN_CLR(),
            INT_TYPE_SET(),
            INT_TYPE_CLR(),
            INT_POL_SET(),
            INT_POL_CLR(),
            INT_STATUS(),
            SEC_INT_STAT(),
            SEC_INT_CLR(),
            SEC_INT_MASK(),
            SEC_INT_INFO1(),
            SEC_INT_INFO2(),
            SEC_INT_SET(),
            PORT_NONSEC_MASK(),
            MASK_LOW_BYTE(),
            MASK_HIGH_BYTE(),
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
            os.path.join("..","..","models","cells","generic","sie200_flop_en.v"),
            os.path.join("..","..","models","cells","generic","sie200_flop.v"),
            os.path.join("..","..","models","cells","generic","sie200_sync.v"),
            os.path.join("..","..","shared","verilog","sie200_static_reg","verilog","sie200_static_reg.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_if.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_reg.v"),
        ]
        self.files.extend(files)


    def Configure(self,uniquifier):
        if(super(sie200_ahb5_gpio, self).Configure(uniquifier)):

            # Set reset values of PORT_NONSEC_MASK
            self.ns_mask  = int(self.GetParameter("PORT_NONSEC_MASK").value, 0)
            self.GetRegister("PORT_NONSEC_MASK").reset=str(hex(self.ns_mask))

            return True
        return False
