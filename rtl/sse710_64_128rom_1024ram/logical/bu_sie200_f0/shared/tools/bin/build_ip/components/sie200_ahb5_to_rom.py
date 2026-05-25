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

import base
import sie200_base

class rom_adhoc_if(base.Interface):
    def __init__(self):
        super(rom_adhoc_if, self).__init__()
        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"


    def Configure(self, parameters):
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)

        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)

        vectorPorts = [
            ("rom_addr",  "out", self.aw-self.dw/16-1, 0),
            ("rom_rdata", "in",  self.dw-1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

class sie200_ahb5_to_rom(base.Component):
    def __init__(self):
        super(sie200_ahb5_to_rom, self).__init__()

        self.name = "sie200_ahb5_to_rom"
        self.version = "r0p0_0"
        self.description = "AHB5 to ROM interface"

        parameter = base.Parameter("ADDR_WIDTH")
        parameter.description = "Address Bus Width"
        parameter.value = "16"
        parameter.minimum = "10"
        parameter.maximum = "32"
        self.parameters.append(parameter)

        parameter = base.Parameter("WAIT_STATES")
        parameter.description = "ROM access wait state (0 to 3)"
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "3"
        parameter.enumerations = ["0", "1", "2", "3"]
        self.parameters.append(parameter)

        parameter = base.Parameter("DATA_WIDTH")
        parameter.description = "Data Bus Width"
        parameter.value = "16"
        parameter.enumerations = ["16","32"]
        parameter.minimum = "16"
        parameter.maximum = "32"
        self.parameters.append(parameter)

        self.AddConstParam("MASTER_WIDTH","0")
        self.AddConstParam("USER_WIDTH","0")

        interfaces = [
            sie200_base.ahbif(mlock=0,excl=0, nonsec=0, prot=0,burst=0),
            rom_adhoc_if()
        ]
        self.interfaces.extend(interfaces)


    def Configure(self,uniquifier):
        if(super(sie200_ahb5_to_rom,self).Configure(uniquifier)):

            # Set address range
            self.aw       = int(self.GetParameter("ADDR_WIDTH").value, 0)
            self.interfaces[0].addressBlocks.append(("0x00000000", hex(1 << self.aw), "memory", "false", "read-only"))
            return True
        return False
