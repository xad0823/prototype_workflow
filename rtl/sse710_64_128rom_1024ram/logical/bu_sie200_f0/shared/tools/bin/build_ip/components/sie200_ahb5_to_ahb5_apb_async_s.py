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
#     Checked In : Mon Dec 5 12:06:19 2016 +0000
#     Revision   : ff9674e
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base
import sie200_base

class sie200_ahb5_to_ahb5_apb_async_s(sie200_base.AcgSlaveComponent):
    def __init__(self):
        super(sie200_ahb5_to_ahb5_apb_async_s, self).__init__()

        self.name = "sie200_ahb5_to_ahb5_apb_async_s"
        self.version = "r0p0_1"
        self.description = "AHB5 to AHB5 and APB Asynchronous Bridge Slave"

        self.GetParameter("DATA_WIDTH").usage = "constant"
        self.GetParameter("DATA_WIDTH").value = "32"

        ahb_multi_if = sie200_base.ahbif("_s","_s",0,1)

        multiPorts = [
            ("hsel_ahb_s", "in", 0 ),
            ("hsel_apb_s", "in", 1 )
        ]
        ahb_multi_if.multiPorts.extend(multiPorts)

        intif_m = sie200_base.internal_sie200_ahb5_to_ahb5_apb_async_if(0)
        ahb_multi_if.bridges.append((intif_m.name, "true"))
        subspaceMaps = [
            base.SubspaceMap(intif_m.name,"0",ahb_multi_if.name),
        ]
        self.submaps.extend(subspaceMaps)

        interfaces = [
            ahb_multi_if,
            intif_m,
        ]

        self.interfaces.extend(interfaces)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_flop_en.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_sample_and_mask.v"),
            os.path.join("..","..",self.name[:-2],"verilog",self.name[:-2] + "_core_s.v"),
        ]
        self.files.extend(files)
