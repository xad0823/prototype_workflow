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
#     Checked In : Fri Jun 2 14:23:24 2017 +0100
#     Revision   : 316b755
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os

def SubstituteParam(attribute, parameters):
    if attribute and attribute[0] == "$":
        words = attribute.split()
        name = words[0].strip("$")
        for parameter in parameters:
            if parameter.name == name:
                words[0] = parameter.value
        attribute = " ".join(words)
    return attribute


##
# \class    Interface
# \brief    Interface base class
#
class Interface(object):
    def __init__(self, clkrel = "clk"):
        self.name = ""
        self.description = "description"
        self.vectorPorts = []
        self.scalarPorts = []
        self.multiPorts = []
        self.splitPorts = []
        self.clockRelation = clkrel
        self.addressSpace = ""
        self.addressBlocks = []
        self.awidth = ""
        self.dwidth = ""
        self.presence = "True"
        self.tag = ""
        self.bridges = []

    def Configure(self, parameters):
        self.presence = SubstituteParam(self.presence, parameters)

    def PhysicalToLogical(self, name):
        return name.upper()


##
# \class    Register
# \brief    Register base class
#
class Register(object):
    def __init__(self):
        self.access = "read-write"
        self.reset = "0x00000000"
        self.displayName = "displayName"
        self.description = "description"
        self.dim = ""
        self.fields = []

    def Configure(self, parameters):
        pass



##
# \class    Component
# \brief    Component base class
#
class Component(object):
    def __init__(self):
        self.vendor = "arm.com"
        self.library = "CoreLink"
        self.name = ""
        self.orig_name = ""
        self.version = ""
        self.description = ""
        self.interfaces = []
        self.parameters = []
        self.registers = []
        self.files = []
        self.vc_files = []
        self.phantom = False
        self.subcomps = []
        self.gen_bridge_halves = 0
        self.top_module = 1
        self.remaps = []
        self.remapStates = []
        self.submaps = []
        self.entry = "SIE-200 Documentation: \n"\
                     "* https://developer.arm.com/products/system-ip/corelink-interconnect/corelink-sie-200\n\n"\
                     "Part Number for this IP Entry (downloadable from http://connect.arm.com)\n"\
                     "* BP300-BU-50000-r3p1-00rel0 CoreLink SIE-200 System IP for Embedded - Global Bundle\n\n"\
                     "It is necessary to install the above IP as per the installation instructions described in the IP's release notes"

    def Configure(self, uniquifier):
        if not self.phantom:
            if self.top_module:
                self.files.append(os.path.join("..","..",self.name,"verilog",self.name + ".v"))
            else:
                self.files.append(os.path.join("..","..",self.name[:-2],"verilog",self.name + ".v"))
        if self.top_module:
            self.vc_files.append(os.path.join("..","..",self.name,"verilog",self.name + ".vc"))

        self.orig_name = self.name

        if uniquifier:
            self.name = self.name + "_" + uniquifier


        if self.ValidateParameters():
            for parameter in self.parameters:
                parameter.Configure(self.parameters)
            for interface in self.interfaces:
                interface.Configure(self.parameters)
            for register in self.registers:
                register.Configure(self.parameters)
            for remap in self.remaps:
                remap.Configure(self.parameters)
            for submap in self.submaps:
                submap.Configure(self.parameters)
            return True

        return False

    # Overload to update calculated parameter default values
    def RecalculateDefaultParameters(self):
        return True

    # Overload to check parameter dependencies
    def ValidateParameters(self):
        return True

    # Add const parameter
    def AddConstParam(self, name, value):
        parameter = Parameter(name)
        parameter.value = value
        parameter.usage = "constant"
        self.parameters.append(parameter)
        return True


    def GetParameter(self, name):
        for parameter in self.parameters:
            if parameter.name == name:
                return parameter
        return None

    def GetRegister(self, name):
        for register in self.registers:
            if register.name == name:
                return register
        return None

    def GetRemap(self, name):
        for remap in self.remaps:
            if remap.name == name:
                return remap
        return None

    def GetRemapState(self, name):
        for remapState in self.remapStates:
            if remapState.name == name:
                return remapState
        return None

##
# \class    Parameter
# \brief    Parameter base class
#
class Parameter(object):
    def __init__(self, name, usage = "required", type = "integer"):
        self.name = name
        self.prompt = ""
        self.description = "description"
        self.value = ""
        self.usage = usage
        self.type = type
        self.enumerations = []
        self.minimum = ""
        self.maximum = ""
        self.presence = "True"
        self.default = "True"

    # Check parameter range and set if valid.
    def SetValue(self, value):
        if self.enumerations:
            if value not in self.enumerations:
                return False
        else:
            if self.minimum:
                if self.type == "integer":
                    if int(value, 0) < int(self.minimum, 0):
                        return False
                elif self.type == "double":
                    if float(value) < float(self.minimum):
                        return False
            if self.maximum:
                if self.type == "integer":
                    if int(value, 0) > int(self.maximum, 0):
                        return False
                elif self.type == "double":
                    if float(value) > float(self.maximum):
                        return False

        self.value = value
        self.default = "False"
        return True

    def Configure(self, parameters):
        self.presence = SubstituteParam(self.presence, parameters)

##
# \class    RemapState
# \brief    RemapState base class
#
class RemapState(object):
    def __init__(self, name, port, value):
        self.name = name
        self.port = port
        self.portIndex = "0"
        self.value = value
        self.presence = "True"

    def Configure(self, parameters):
        pass

##
# \class    SubspaceMap
# \brief    SubspaceMap base class
#
class SubspaceMap(object):
    def __init__(self, name, ba="", intf=""):
        self.name = name
        self.baseAddress = ba
        self.presence = "True"
        self.interface = intf

    def Configure(self, parameters):
        return self.interface

##
# \class    MemoryRemap
# \brief    MemoryRemap base class
#
class MemoryRemap(object):
    def __init__(self, name, state, interface):
        self.name = name
        self.state = state
        self.subspaceMaps = []
        self.presence = "True"
        self.interface = interface

    def Configure(self, parameters):
        return self.subspaceMaps
