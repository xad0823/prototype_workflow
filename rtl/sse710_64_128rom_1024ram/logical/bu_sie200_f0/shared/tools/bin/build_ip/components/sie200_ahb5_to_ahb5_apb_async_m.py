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

class ahb5_to_ahb5_apb_async_adhoc_if_m(base.Interface):
    def __init__(self):
        super(ahb5_to_ahb5_apb_async_adhoc_if_m, self).__init__()
        self.mwidth = "$MASTER_WIDTH"

    def Configure(self, parameters):
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)

        scalarPorts = [
            ("hactive_m",  "out"),
            ("pactive_m",  "out")

        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("pmaster_m", "out",   int(self.mwidth, 0) - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)


class sie200_ahb5_to_ahb5_apb_async_m(sie200_base.AcgMasterComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_apb_async_m, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_apb_async_m"
        self.version = "r0p0_1"
        self.description = "AHB5 to AHB5 and APB Asynchronous Bridge Master"

        self.GetParameter("DATA_WIDTH").usage = "constant"
        self.GetParameter("DATA_WIDTH").value = "32"

        internalInterface = sie200_base.internal_sie200_ahb5_to_ahb5_apb_async_if(1)
        masterAHBInterface = sie200_base.ahbinitif("_m","_m",1,1)
        masterAPBInterface = sie200_base.apbif(1,"_m", "h","_m")

        interfaces = [
            internalInterface,
            masterAHBInterface,
            masterAPBInterface,
            ahb5_to_ahb5_apb_async_adhoc_if_m()
        ]

        remapState = base.RemapState("hsel_m_RS", "reg_hsel_apb_s", "0")
        self.remapStates.append(remapState)
        remapState = base.RemapState("psel_m_RS", "reg_hsel_apb_s", "1")
        self.remapStates.append(remapState)

        subspaceMap = base.SubspaceMap(masterAHBInterface.name)
        subspaceMap.baseAddress = "0"
        remap = base.MemoryRemap("hsel_m_MR", self.remapStates[0].name, internalInterface.name)
        remap.subspaceMaps.append(subspaceMap)
        self.remaps.append(remap)
        subspaceMap = base.SubspaceMap(masterAPBInterface.name)
        subspaceMap.baseAddress = "0"
        remap = base.MemoryRemap("psel_m_MR", self.remapStates[1].name, internalInterface.name)
        remap.subspaceMaps.append(subspaceMap)
        self.remaps.append(remap)

        internalInterface.bridges.append((masterAHBInterface.name, "true"))
        internalInterface.bridges.append((masterAPBInterface.name, "true"))

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_flop_en.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_sample_and_mask.v"),
            os.path.join("..","..",self.name[:-2],"verilog",self.name[:-2] + "_core_m.v"),
        ]
        self.files.extend(files)
