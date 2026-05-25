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

class sie200_ahb5_periph_prot(sie200_base.BridgeComponent):
    def __init__(self):
        super(sie200_ahb5_periph_prot, self).__init__()

        self.name = "sie200_ahb5_periph_prot"
        self.version = "r0p0_1"
        self.description = "AHB5 Peripheral Protection Controller"

        slaveInterface = sie200_base.ahbif("_s","",17)
        interfaces = [
            slaveInterface,
            sie200_base.ahbdefslvif("_ds"),
            sie200_base.irqif("ahb_ppc","hclk"),
            sie200_base.internalInterrupt("ahb_ppc",sig_enable=1,sig_clear=1,clk_name="hclk"),
            sie200_base.dyncfgif("cfg_sec_resp","hclk"),
            sie200_base.dyncfgif("cfg_ap","hclk", 16),
            sie200_base.dyncfgif("cfg_nonsec","hclk",16),
        ]

        for i in range(0,16):
            if_num = str(i)

            parameter = base.Parameter("PORT" + if_num + "_ENABLE")
            parameter.description = "Enable (1) or disable (0) port " + if_num
            parameter.value = "1"
            parameter.minimum = "0"
            parameter.maximum = "1"
            parameter.enumerations = ["0", "1"]
            self.parameters.append(parameter)

            masterInterface = sie200_base.ahbif("_m" + if_num,"")
            interfaces += [masterInterface]

            remapState = base.RemapState("hsel_m" + if_num + "_RS", "hsel_s", "1")
            remapState.portIndex = if_num
            self.remapStates.append(remapState)

            subspaceMap = base.SubspaceMap(masterInterface.name)
            subspaceMap.baseAddress = "0"

            remap = base.MemoryRemap("hsel_m" + if_num + "_MR", remapState.name, slaveInterface.name)
            remap.subspaceMaps.append(subspaceMap)
            self.remaps.append(remap)

            slaveInterface.bridges.append((masterInterface.name, "true"))

        self.interfaces.extend(interfaces)

        parameter = base.Parameter("NONSEC_MASK")
        parameter.description = "16-bit wide mask for security checking of ports"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = str(2**16 - 1)
        self.parameters.append(parameter)

    def Configure(self, uniquifier):
        superOk = super(sie200_ahb5_periph_prot, self).Configure(uniquifier)

        if superOk:
            slaveInterface = None
            for interface in self.interfaces:
                if isinstance(interface, sie200_base.ahbif) and "Slave" in interface.name:
                    slaveInterface = interface
                    break
            for i in range(0,16):
                if_num = str(i)
                if self.GetParameter("PORT" + if_num + "_ENABLE").value != "1":
                    remapState = self.GetRemapState("hsel_m" + if_num + "_RS")
                    if remapState != None:
                        remapState.presence = "False"
                    remap = self.GetRemap("hsel_m" + if_num + "_MR")
                    if remap != None:
                        remap.presence = "False"
                    if slaveInterface != None:
                        slaveInterface.bridges = [bridge for bridge in slaveInterface.bridges if not bridge[0].endswith("_m" + if_num)]
                    for interface in self.interfaces:
                        if isinstance(interface, sie200_base.ahbif) and interface.name.endswith("Master_m" + if_num):
                            interface.addressSpace = []
                            break
            return True
        else:
            return False
