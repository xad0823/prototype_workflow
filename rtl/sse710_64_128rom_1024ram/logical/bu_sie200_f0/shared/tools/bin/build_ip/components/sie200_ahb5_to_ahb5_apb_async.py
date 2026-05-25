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

class ahb5_to_ahb5_apb_async_adhoc_if(base.Interface):
    def __init__(self):
        super(ahb5_to_ahb5_apb_async_adhoc_if, self).__init__()
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


class sie200_ahb5_to_ahb5_apb_async(sie200_base.AcgComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_apb_async, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_apb_async"
        self.version = "r0p0_1"
        self.description = "AHB5 to AHB5 and APB Asynchronous Bridge"

        self.GetParameter("DATA_WIDTH").usage = "constant"
        self.GetParameter("DATA_WIDTH").value = "32"

        ahb_multi_if = sie200_base.ahbif("_s","_s",0,1)

        multiPorts = [
            ("hsel_ahb_s", "in", 0 ),
            ("hsel_apb_s", "in", 1 )
        ]
        ahb_multi_if.multiPorts.extend(multiPorts)

        masterAHBInterface = sie200_base.ahbinitif("_m","_m",1,1)
        masterAPBInterface = sie200_base.apbif(1,"_m", "h","_m")

        interfaces = [
            ahb_multi_if,
            masterAHBInterface,
            masterAPBInterface,
            ahb5_to_ahb5_apb_async_adhoc_if()
        ]

        remapState = base.RemapState("hsel_m_RS", "hsel_ahb_s", "1")
        self.remapStates.append(remapState)
        remapState = base.RemapState("psel_m_RS", "hsel_apb_s", "1")
        self.remapStates.append(remapState)

        subspaceMap = base.SubspaceMap(masterAHBInterface.name)
        subspaceMap.baseAddress = "0"
        remap = base.MemoryRemap("hsel_m_MR", self.remapStates[0].name, ahb_multi_if.name)
        remap.subspaceMaps.append(subspaceMap)
        self.remaps.append(remap)
        subspaceMap = base.SubspaceMap(masterAPBInterface.name)
        subspaceMap.baseAddress = "0"
        remap = base.MemoryRemap("psel_m_MR", self.remapStates[1].name, ahb_multi_if.name)
        remap.subspaceMaps.append(subspaceMap)
        self.remaps.append(remap)

        ahb_multi_if.bridges.append((masterAHBInterface.name, "true"))
        ahb_multi_if.bridges.append((masterAPBInterface.name, "true"))

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_flop_en.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_sample_and_mask.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_core_s.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_core_m.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_s.v"),
            os.path.join("..","..",self.name,"verilog",self.name + "_m.v"),
        ]
        self.files.extend(files)
