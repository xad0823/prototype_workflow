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
import os

class m3_m4_adhoc_if(base.Interface):
    def __init__(self, suffix, excl=1):
        super(m3_m4_adhoc_if, self).__init__()
        self.suffix = suffix
        self.excl = excl

    def Configure(self, parameters):

        vectorPorts = []

        if (self.excl):
            vectorPorts += [
                ("hmaster"     + self.suffix, "in", 1, 0),
            ]

            scalarPorts = [
                ("exreq"       + self.suffix, "in"),
                ("exresp"      + self.suffix, "out"),
            ]
            self.scalarPorts.extend(scalarPorts)

        vectorPorts += [
            ("memattr"     + self.suffix, "in", 1, 0),
        ]
        self.vectorPorts.extend(vectorPorts)


class sie200_m3_m4_ahb5_adapter(base.Component):
    def __init__(self):
        super(sie200_m3_m4_ahb5_adapter, self).__init__()

        self.name = "sie200_m3_m4_ahb5_adapter"
        self.version = "r0p0_1"
        self.description = "M3/M4 AHB5 Adapter"

        parameter = base.Parameter("MSC_PRESENT")
        parameter.description = "Master Security Controller instantiation enabled, 1: Master Security Controller instantiated (default) 0: Master Security Controller not instantiated"
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("CODE_MUXED")
        parameter.description = "Code buses muxed: 0: System and data code buses are not muxed, all 3 interfaces are enabled, 1: System and data code buses are muxed, system code interfaces are not connected"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        self.AddConstParam("ADDR_WIDTH","32")
        self.AddConstParam("DATA_WIDTH","32")
        self.AddConstParam("MASTER_WIDTH","2")
        self.AddConstParam("USER_WIDTH","0")

        ahb3if_is = sie200_base.ahb3initif("i_s","",mlock=0,resp_vec=1)
        ahb3if_ds = sie200_base.ahb3initif("d_s","",mlock=0,resp_vec=1)
        ahb3if_ss = sie200_base.ahb3initif("s_s","",resp_vec=1)


        ahbif_im = sie200_base.ahbinitif("i_m","",master=1,excl=0,mlock=0)
        ahbif_im.mwidth="0" # instruction interface has no master port

        ahbif_dm = sie200_base.ahbinitif("d_m","",master=1,mlock=0)
        ahbif_sm = sie200_base.ahbinitif("s_m","",master=1)


        ahb3if_is.bridges.append((ahbif_im.name, "true"))
        ahb3if_ds.bridges.append((ahbif_dm.name, "true"))
        ahb3if_ss.bridges.append((ahbif_sm.name, "true"))

        subspaceMaps = [
            base.SubspaceMap(ahbif_im.name,"0",ahb3if_is.name),
            base.SubspaceMap(ahbif_dm.name,"0",ahb3if_ds.name),
            base.SubspaceMap(ahbif_sm.name,"0",ahb3if_ss.name),
        ]
        self.submaps.extend(subspaceMaps)

        intefaces = [
          sie200_base.idauif(27,"_i"),
          sie200_base.idauif(27,"_d"),
          sie200_base.idauif(27,"_s"),
          sie200_base.irqif("msc","hclk", suffix="_i"),
          sie200_base.internalInterrupt("msc",sig_clear=1,sig_enable=1,clk_name="hclk", suffix="_i"),
          sie200_base.irqif("msc","hclk", suffix="_d"),
          sie200_base.internalInterrupt("msc",sig_clear=1,sig_enable=1,clk_name="hclk", suffix="_d"),
          sie200_base.irqif("msc","hclk", suffix="_s"),
          sie200_base.internalInterrupt("msc",sig_clear=1,sig_enable=1,clk_name="hclk", suffix="_s"),
          sie200_base.dyncfgif("cfg_sec_resp","hclk"),
          sie200_base.dyncfgif("cfg_nonsec","hclk"),
          ahb3if_is,
          ahb3if_ds,
          ahb3if_ss,
          m3_m4_adhoc_if("i_s", excl=0),
          m3_m4_adhoc_if("d_s"),
          m3_m4_adhoc_if("s_s"),
          ahbif_im,
          ahbif_dm,
          ahbif_sm,
        ]
        self.interfaces.extend(intefaces)

        files = [
            os.path.join("..","..",self.name,"verilog",self.name + "_ex_conv.v"),
            os.path.join("..","..","sie200_ahb5_master_sec","verilog", "sie200_ahb5_master_sec.v"),
        ]
        self.files.extend(files)

        self.vc_files.append(os.path.join("..","..","sie200_ahb5_master_sec","verilog","sie200_ahb5_master_sec.vc"))

    def Configure(self, uniquifier):
        superOk = super(sie200_m3_m4_ahb5_adapter, self).Configure(uniquifier)

        if superOk:
            if self.GetParameter("CODE_MUXED").value == "1":
                for interface in self.interfaces:
                    if isinstance(interface, sie200_base.ahb3initif) and interface.name.endswith("Slave_is"):
                        interface.bridges = []
                    if isinstance(interface, sie200_base.ahbinitif) and interface.name.endswith("Master_im"):
                        interface.addressSpace = []
                self.submaps = [submap for submap in self.submaps if not submap.interface.endswith("_is")]
            return True
        else:
            return False
