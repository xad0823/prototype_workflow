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

class apb_periph_prot_adhoc_if(base.Interface):
    def __init__(self):
        super(apb_periph_prot_adhoc_if, self).__init__()

    def Configure(self, parameters):

        vectorPorts = [
            ("psel_s", "in",   15, 0)
        ]
        self.vectorPorts.extend(vectorPorts)


class sie200_apb_periph_prot(base.Component):
    def __init__(self):
        super(sie200_apb_periph_prot, self).__init__()

        self.name = "sie200_apb_periph_prot"
        self.version = "r0p0_1"
        self.description = "APB Peripheral Protection Controller"

        parameter = base.Parameter("ADDR_WIDTH")
        parameter.description = "Address Bus Width"
        parameter.value = "32"
        parameter.minimum = "10"
        parameter.maximum = "32"
        self.parameters.append(parameter)

        parameter = base.Parameter("DATA_WIDTH")
        parameter.description = "Data Bus Width"
        parameter.value = "32"
        parameter.minimum = "8"
        parameter.maximum = "32"
        parameter.enumerations = ["8","16","32"]
        self.parameters.append(parameter)


        slaveInterface = sie200_base.apbif_hsel(0,"_s")
        interfaces = [
            slaveInterface,
            sie200_base.irqif("apb_ppc","pclk"),
            sie200_base.internalInterrupt("apb_ppc",sig_enable=1,sig_clear=1,clk_name="pclk"),
            apb_periph_prot_adhoc_if(),
            sie200_base.dyncfgif("cfg_sec_resp","pclk"),
            sie200_base.dyncfgif("cfg_ap","pclk", 16),
            sie200_base.dyncfgif("cfg_nonsec","pclk",16),

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

            masterInterface = sie200_base.apbif(1,"_m" + if_num)
            interfaces += [masterInterface]

            remapState = base.RemapState("psel_m" + if_num + "_RS", "psel_s", "1")
            remapState.portIndex = if_num
            self.remapStates.append(remapState)

            subspaceMap = base.SubspaceMap(masterInterface.name)
            subspaceMap.baseAddress = "0"

            remap = base.MemoryRemap("psel_m" + if_num + "_MR", remapState.name, slaveInterface.name)
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
        superOk = super(sie200_apb_periph_prot, self).Configure(uniquifier)

        if superOk:
            slaveInterface = None
            for interface in self.interfaces:
                if isinstance(interface, sie200_base.apbif) and "Slave" in interface.name:
                    slaveInterface = interface
                    break
            for i in range(0,16):
                if_num = str(i)
                if self.GetParameter("PORT" + if_num + "_ENABLE").value != "1":
                    remapState = self.GetRemapState("psel_m" + if_num + "_RS")
                    if remapState != None:
                        remapState.presence = "False"
                    remap = self.GetRemap("psel_m" + if_num + "_MR")
                    if remap != None:
                        remap.presence = "False"
                    if slaveInterface != None:
                        slaveInterface.bridges = [bridge for bridge in slaveInterface.bridges if not bridge[0].endswith("_m" + if_num)]
                    for interface in self.interfaces:
                        if isinstance(interface, sie200_base.apbif) and interface.name.endswith("Master_m" + if_num):
                            interface.addressSpace = []
                            break
            return True
        else:
            return False
