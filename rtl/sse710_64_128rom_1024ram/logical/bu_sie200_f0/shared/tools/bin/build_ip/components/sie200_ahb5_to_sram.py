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
#     Checked In : Mon Dec 5 13:25:14 2016 +0000
#     Revision   : df733de
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import base
import sie200_base


class sie200_ahb5_to_sram(base.Component):
    def __init__(self):
        super(sie200_ahb5_to_sram, self).__init__()

        self.name = "sie200_ahb5_to_sram"
        self.version = "r0p0_0"
        self.description = "AHB5 to SRAM interface"

        parameter = base.Parameter("ADDR_WIDTH")
        parameter.description = "Address Bus Width"
        parameter.value = "16"
        parameter.minimum = "10"
        parameter.maximum = "32"
        self.parameters.append(parameter)

        parameter = base.Parameter("ENDIANNESS")
        parameter.description = "Defines the endianness of the AHB interfaces: 0-little endian, 1:byte-invariant big endian, 2: word-invariant big endian"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "2"
        parameter.enumerations = ["0", "1", "2"]
        self.parameters.append(parameter)

        self.AddConstParam("DATA_WIDTH","32")
        self.AddConstParam("MASTER_WIDTH","0")
        self.AddConstParam("USER_WIDTH","0")

        ahbif_s = sie200_base.ahbif(excl=0,mlock=0,nonsec=0,prot=0,burst=0)
        sramif_m = sie200_base.sramif("sram")
        ahbif_s.bridges.append((sramif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(sramif_m.name,"0",ahbif_s.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahbif_s,
            sramif_m,
            sie200_base.dftif()
        ]
        self.interfaces.extend(interfaces)

