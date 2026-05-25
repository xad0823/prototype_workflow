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
#     Checked In : Thu Nov 17 07:39:38 2016 +0000
#     Revision   : 93944ce
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose : Project definition for rendering IPXACT and IPCatalog entries.
# ----------------------------------------------------------------------------

name = "sie200"

##
# \class    BusDef
# \brief    Bus definition description
#
class busDef(object):
    def __init__(self, vendor, library, busVersion = "r0p0_0", absVersion = "r0p0_0", ancestorBusdef = ""):
        self.vendor = vendor
        self.library = library
        self.busVersion = busVersion
        self.absVersion = absVersion
        self.ancestorBusdef = ancestorBusdef

busDefs = {
    "SRAM_sp_basic"     : busDef("arm.com", "generic"),
    "SRAM_sp_activehigh": busDef("arm.com", "generic"),
    "InternalInterrupt" : busDef("arm.com", "generic"),
    "DFTInterface"      : busDef("arm.com", "generic", "r0p0_1", "r0p0_1"),
    "HandShake"         : busDef("arm.com", "generic"),
    "interrupt"         : busDef("arm.com", "generic"),
    "AHB5Initiator"     : busDef("amba.com", "AMBA5"),
    "AHB5Target"        : busDef("amba.com", "AMBA5"),
    "APB4"              : busDef("amba.com", "AMBA4", ancestorBusdef="APB"),
    "APB"               : busDef("amba.com", "AMBA3", "r2p0_0", "r2p0_0"),
    "AHBLiteInitiator"  : busDef("amba.com", "AMBA3", "r2p0_0", "r2p0_0"),
    "AHBLiteTarget"     : busDef("amba.com", "AMBA3", "r2p0_0", "r2p0_0"),
    "Q-Channel"         : busDef("arm.com", "generic"),
    "Staticcfg"         : busDef("arm.com", "generic"),
    "DynamicConfig"     : busDef("arm.com", "generic"),
    "GPIO"              : busDef("arm.com", "generic"),
    "Status"            : busDef("arm.com", "generic"),
    "IDAU"              : busDef("arm.com", "CortexM_Cores"),
    "ahb5accessctrlInternal"     : busDef("arm.com", "sie200"),
    "ahb5toahb5apbasyncInternal" : busDef("arm.com", "sie200", "r1p0_0", "r1p0_0"),
    "ahb5toapbasyncInternal"     : busDef("arm.com", "sie200"),
    "ahb5toapbsyncInternal"      : busDef("arm.com", "sie200"),
    "ahb5toahb5syncupInternal"   : busDef("arm.com", "sie200"),
    "ahb5toahb5syncdownInternal" : busDef("arm.com", "sie200"),

}
