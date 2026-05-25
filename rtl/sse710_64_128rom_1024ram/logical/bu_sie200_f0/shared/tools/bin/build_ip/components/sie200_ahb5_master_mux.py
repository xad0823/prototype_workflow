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

import base
import sie200_base


class sie200_ahb5_master_mux(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_master_mux, self).__init__()

        self.name = "sie200_ahb5_master_mux"
        self.version = "r0p0_1"
        self.description = "AHB5 Master Multiplexer"

        masterInterface = sie200_base.ahbif("_m","")
        interfaces = [
            masterInterface
        ]

        for i in range(0,3):
            if_num = str(i)
            parameter = base.Parameter("PORT" + if_num + "_ENABLE")
            parameter.description = "Enable (1) or disable (0) port " + str(i)
            parameter.value = "1"
            parameter.minimum = "0"
            parameter.maximum = "1"
            parameter.enumerations = ["0", "1"]
            self.parameters.append(parameter)

            slaveInterface = sie200_base.ahbif("_s" + if_num,"")
            interfaces += [slaveInterface]

            subspaceMap = base.SubspaceMap(masterInterface.name)
            subspaceMap.baseAddress = "0"
            subspaceMap.interface = slaveInterface.name
            self.submaps.append(subspaceMap)

            slaveInterface.bridges.append((masterInterface.name, "true"))

        self.interfaces.extend(interfaces)


    def Configure(self, uniquifier):
        superOk = super(sie200_ahb5_master_mux, self).Configure(uniquifier)

        if superOk:
            for i in range(0,3):
                if_num = str(i)
                if self.GetParameter("PORT" + if_num + "_ENABLE").value != "1":
                    self.submaps = [submap for submap in self.submaps if not submap.interface.endswith("_s" + if_num)]
                    for interface in self.interfaces:
                        if isinstance(interface, sie200_base.ahbif) and interface.name.endswith("Slave_s" + if_num):
                            interface.bridges = []
                            break
            return True
        else:
            return False
