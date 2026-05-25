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
#     Checked In : Fri Jun 2 14:23:24 2017 +0100
#     Revision   : 316b755
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose : Render IP catalog entries and IP-XACT files for
#            specified components.
# ----------------------------------------------------------------------------

import optparse
import re
import os
import sys
from xml.dom import minidom

import project
import components           # For list
from components import *    # For modules
sys.path.append(os.path.join(sys.path[0], "..","..","lib"))
import configReader


##
# \class    _XMLFile
# \brief    XML file object.
class _XMLFile(object):
    header = """
<!--
//============================================================================
//   The confidential and proprietary information contained in this file may
//   only be used by a person authorised under and to the extent permitted
//   by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//          (C) COPYRIGHT %s ARM Limited or its affiliates.
//              ALL RIGHTS RESERVED
//
//   This entire notice must be reproduced on all copies of this file
//   and copies of this file may only be made by a person if such person is
//   permitted to do so under the terms of a subsisting license agreement
//   from ARM Limited or its affiliates.
//============================================================================
-->
"""
    nss = ""
    year = "2015-2017"

    def __init__(self):
        self.doc = None
        self.root = None

    ##
    # \fn           _createTree
    # \brief        Create a tree in the XML DOM.
    # \param[in]    tree - Leaf tuple, ("", "", *) or branch tuple ("", [], *) with optional attribute list *
    # \return       Root element
    def _createTree(self, tree):
        ele = self.doc.createElement(self.nss + tree[0])
        if len(tree) == 3:                                  # Has attribute(s)
            for attr in tree[2]:
                name, value = attr
                ele.setAttribute(self.nss + name, value)
        if type(tree[1]) is list:
            for e in tree[1]:
                ele.appendChild(self._createTree(e))            # Branch node
        elif tree[1]:
            ele.appendChild(self.doc.createTextNode(tree[1]))   # Leaf node

        return ele

    ##
    # \fn           _XMLToString
    # \brief        Convert the DOM to a formatted string.
    # \return       string
    def _XMLToString(self):
        s = self.doc.toprettyxml(indent = "  ", encoding = "UTF-8")
        text_re = re.compile(">\n\s+([^<>\s].*?)\n\s+</", re.DOTALL)
        return text_re.sub(">\g<1></", s)

    ##
    # \fn           writeXMLFile
    # \brief        Convert the DOM to a formatted string.
    # \return       string
    def writeXMLFile(self, filename):
        f = open(filename, "w")
        s = self._XMLToString()
        t, s = s.split("\n", 1)
        s = t + self.header % self.year + s
        f.write(s)


##
# \class    _EntryFile
# \brief    XML file object.
class _EntryFile(_XMLFile):

    def __init__(self):
        super(_EntryFile, self).__init__()
        self.doc = minidom.getDOMImplementation().createDocument(None, "CatalogEntry", None)

    ##
    # \fn           Generate
    # \brief        Generate a SocratesDE IP-Catalog entry.
    # \param[in]    Path, component
    # \return       None
    def Generate(self, filepath, component):
        # Create the DOM tree
        self.root = self.doc.documentElement
        self.root.appendChild(self._createTree(("Name", component.version)))
        self.root.appendChild(self._createTree(("Description", component.entry)))
        self.root.appendChild(self._createTree(("ConfigurableComponent", "")))

        #print self._XMLToString()
        self.writeXMLFile(os.path.join(filepath,"entry.xml"))


##
# \class    _ConfigurableFile
# \brief    SocratesDE IP-Catalog entry object.
#
class _ConfigurableFile(_XMLFile):

    def __init__(self):
        super(_ConfigurableFile, self).__init__()
        self.doc = minidom.getDOMImplementation().createDocument(None, "ConfigurableComponent", None)

    def PythonToXpath(self, exp):
        return exp.replace("==", "=")

    ##
    # \fn           Generate
    # \brief        Generate a SocratesDE IP-Catalog entry.
    # \param[in]    Path, component
    # \return       None
    def Generate(self, filepath, component):

        self.root = self.doc.documentElement
        self.root.appendChild(self._createTree(("Vendor", component.vendor)))
        self.root.appendChild(self._createTree(("Library", component.library)))
        self.root.appendChild(self._createTree(("Name", component.name)))
        self.root.appendChild(self._createTree(("Version", component.version)))

        locator = \
        ("Locator", [
            ("Name", "Locator"),
            ("FileLocationHint", "logical/shared/tools/bin/build_ip/components/%s.py" % component.name),
            ("RegularExpression", [
                ("Value", "self.version\s*=\s*\"%s\"" % component.version)]
            )]
        )
        self.root.appendChild(self._createTree(locator))

        operationReferences = \
        ("OperationReferences", [
            ("BuildOperationReference", "Build_IP")]
        )
        self.root.appendChild(self._createTree(operationReferences))

        arguments = [
            ("Argument", [
                ("Value", component.name),
                ("Type", "constant")]
            ),
            ("Argument", [
                ("Value", "${configured.component.build.dir}/../../"),
                ("Type", "constant")]
            ),
            ("Argument", [
                ("Value", "--ipxact"),
                ("Type", "constant")]
            ),
            ("Argument", [
                ("Value", "--uniquifier"),
                ("Type", "constant")]
            ),
            ("Argument", [
                ("Value", "${configured.component.name.suffix}"),
                ("Type", "constant")]
            )
        ]

        parameters = []
        for parameter in component.parameters:
            alist = [
                ("Name", parameter.name),
                ("Value", "$" + parameter.name)
            ]
            if parameter.presence != "True":                # Add presence if conditional
                alist.append(("Presence", self.PythonToXpath(parameter.presence)))
            arguments.append(("Argument", alist))

            plist = [
                ("Name", parameter.name),
                ("Prompt", parameter.description),
                ("Description", parameter.description)
            ]
            clist = [
                ("Type", parameter.type)
            ]
            if parameter.value:
                plist.append(("Value", parameter.value))
            plist.append(("Usage", parameter.usage))
            if parameter.enumerations:
                elist = []
                for enumeration in parameter.enumerations:
                    elist.append(("Enumeration", enumeration))
                clist.append(("Enumerations", elist))
            if parameter.minimum:
                clist.append(("Minimum", parameter.minimum))
            if parameter.maximum:
                clist.append(("Maximum", parameter.maximum))
            plist.append(("Constraint", clist))
            if parameter.presence != "True":                # Add presence if conditional
                plist.append(("Presence", self.PythonToXpath(parameter.presence)))
            parameters.append(("Parameter", plist))

        operations = \
        ("Operations", [
            ("Operation", [
                ("Name", "Build_IP"),
                ("WorkingDir", "file:${Locator}/.."),
                ("Executable", "file:${Locator}/../build_ip.py"),
                ("Arguments", arguments)]
            )]
        )
        self.root.appendChild(self._createTree(operations))

        dependencies = []
        interfaces = []
        protocols = []
        for interface in component.interfaces:
            if interface.name:
                name_list = interface.name.split("_")
                if(name_list[0] == "QChannel"):   # Dash present in official busdef
                    busdef = "Q-Channel"
                else:
                    busdef = name_list[0]
                for i in range(1,len(name_list)):
                  if("Master" in name_list[i] or "Slave" in name_list[i]):
                      mode = name_list[i]
                      index = name_list[i+1]
                      for j in range(i+2, len(name_list)):
                          index += "_" + name_list[j]
                      break;
                  else:
                      busdef += "_" + name_list[i]


                if busdef not in protocols:
                    protocols.append(busdef)  # Add dependency once for any given protocol
                    busDependency = \
                    ("BusDependency", [
                        ("Protocol", busdef),
                        ("BusType", [
                            ("Vendor", project.busDefs[busdef].vendor),
                            ("Library", project.busDefs[busdef].library),
                            ("Name", busdef),
                            ("Version", project.busDefs[busdef].busVersion)
                        ]),
                        ("AbstractionType", [
                            ("Vendor", project.busDefs[busdef].vendor),
                            ("Library", project.busDefs[busdef].library),
                            ("Name", busdef + "_rtl"),
                            ("Version", project.busDefs[busdef].absVersion)
                        ])
                    ])
                    dependencies.append(busDependency)


                    # Adding reference to ancestor busdefinition ( needed for APB4)
                    if project.busDefs[busdef].ancestorBusdef :
                        ancBusdef = project.busDefs[busdef].ancestorBusdef
                        if ancBusdef not in protocols:
                            protocols.append(ancBusdef)  # Add dependency once for any given protocol
                            busDependency = \
                            ("BusDependency", [
                                ("Protocol", ancBusdef),
                                ("BusType", [
                                    ("Vendor", project.busDefs[ancBusdef].vendor),
                                    ("Library", project.busDefs[ancBusdef].library),
                                    ("Name", ancBusdef),
                                    ("Version", project.busDefs[ancBusdef].busVersion)
                                ]),
                                ("AbstractionType", [
                                    ("Vendor", project.busDefs[ancBusdef].vendor),
                                    ("Library", project.busDefs[ancBusdef].library),
                                    ("Name", ancBusdef + "_rtl"),
                                    ("Version", project.busDefs[ancBusdef].absVersion)
                                ])
                            ])
                            dependencies.append(busDependency)



                if mode == "Master":
                    interMode = "MasterInterface"
                else:
                    interMode = "SlaveInterface"

                interElements = [
                    ("Name", "%s" % interface.name),
                    ("Protocol", busdef)
                ]

                if interface.clockRelation:      # Add clock relation if present
                    interElements.append(("ClockRef", interface.clockRelation))

                if interface.awidth and interface.dwidth:
                    attributes = \
                    ("Attributes", [
                        ("Attribute", [
                            ("Name", "AddressWidth"),
                            ("Value", interface.awidth),
                            ("Type", "integer")]
                        ),
                        ("Attribute", [
                            ("Name", "DataWidth"),
                            ("Value", interface.dwidth),
                            ("Type", "integer")]
                        )
                    ])
                    interElements.append(attributes)

                if interface.presence != "True":            # Add presence if conditional
                    interElements.append(("Presence", self.PythonToXpath(interface.presence)))

                interfaces.append((interMode, interElements))

        self.root.appendChild(self._createTree(("Dependencies", dependencies)))
        self.root.appendChild(self._createTree(("Parameters", parameters)))
        self.root.appendChild(self._createTree(("Interfaces", interfaces)))

        #print self._XMLToString()
        self.writeXMLFile(os.path.join(filepath,"configurable.xml"))


##
# \class    _IPCatalogEntry
# \brief    IP Catalog entry object.
class _IPCatalogEntry(object):

    def __init__(self):
        self.configurableFile = _ConfigurableFile()
        self.entryFile = _EntryFile()

    def Generate(self, filepath, component):
        filepath = os.path.join(filepath,component.name,component.version)
        if not os.path.exists(filepath):
            os.makedirs(filepath)
        self.configurableFile.Generate(filepath, component)
        self.entryFile.Generate(filepath, component)

##
# \class    _IPXACTFile
# \brief    IPXACT file object.
class _IPXACTFile(_XMLFile):

    nss = "spirit:"
    namespaceURI = "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009"

    ##
    # \fn           Generate
    # \brief        Generate an IPXACT component file.
    # \param[in]    CoreLink SIE-200 component
    # \return       None
    def Generate(self, component):

        self.root = self.doc.documentElement

        self.root.setAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        self.root.setAttribute("xsi:schemaLocation",
            "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009 http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009/index.xsd")
        self.root.setAttribute("xmlns:" + self.nss[:-1], self.namespaceURI)

        self.root.appendChild(self._createTree(("vendor", component.vendor)))
        self.root.appendChild(self._createTree(("library", component.library)))
        self.root.appendChild(self._createTree(("name", component.name)))
        self.root.appendChild(self._createTree(("version", component.version)))

##
# \class    _IPXACTComponent
# \brief    Component IPXACT object.
class _IPXACTComponent(_IPXACTFile):

    def __init__(self):
        super(_IPXACTComponent, self).__init__()
        self.doc = minidom.getDOMImplementation().createDocument(self.namespaceURI, self.nss + "component", None)
        self.busInterfaces = []
        self.addressSpaces = []
        self.memoryMaps = []
        self.model = []
        self.fileSets = []
        self.remapStates = []


    def GetMemoryMap(self, name):
        if self.memoryMaps:
            for memoryMap in self.memoryMaps:
                if memoryMap[1][0][1] == name:
                    return memoryMap[1]
        memoryMap = [
            ("name", name)
        ]
        self.memoryMaps.append(("memoryMap", memoryMap))
        return memoryMap


    ##
    # \fn           ProcInterfaces
    # \brief        Create IP-XACT nodes from component interface properties
    # \param[in]    interfaces - list of component interfaces
    # \return       None
    def ProcInterfaces(self, interfaces):
        ports = []
        for interface in interfaces:
            if eval(interface.presence):
                if interface.name:
                    portMaps = []
                    for vectorPort in interface.vectorPorts:
                        name, dir, left, right = vectorPort
                        portMap = [
                            ("logicalPort", [
                                ("name", interface.PhysicalToLogical(name)),
                                ("vector", [
                                    ("left", "%d" % (left - right)),
                                    ("right", "0")
                                ])
                            ]),
                            ("physicalPort", [
                                ("name", name),
                                ("vector", [
                                    ("left", "%d" % left),
                                    ("right", "%d" % right),
                                ])
                            ])
                        ]
                        portMaps.append(("portMap", portMap))
                    for scalarPort in interface.scalarPorts:
                        name, dir = scalarPort
                        portMap = [
                            ("logicalPort", [
                                ("name", interface.PhysicalToLogical(name)),
                            ]),
                            ("physicalPort", [
                                ("name", name)
                            ])
                        ]
                        portMaps.append(("portMap", portMap))

                    for multiPort in interface.multiPorts:
                        name, dir, idx = multiPort
                        portMap = [
                            ("logicalPort", [
                                ("name", interface.PhysicalToLogical(name)),
                                ("vector", [
                                    ("left",  "%d" % idx),
                                    ("right", "%d" % idx)
                                ])
                            ]),
                            ("physicalPort", [
                                ("name", name)
                            ])
                        ]
                        portMaps.append(("portMap", portMap))

                    for splitPort in interface.splitPorts:
                        name, dir, idx, left, right = splitPort
                        portMap = [
                            ("logicalPort", [
                                ("name", interface.PhysicalToLogical(name)),
                            ]),
                            ("physicalPort", [
                                ("name", name),
                                ("vector", [
                                    ("left",  "%d" % idx),
                                    ("right", "%d" % idx)
                                ])
                            ])
                        ]
                        portMaps.append(("portMap", portMap))

                    name_list = interface.name.split("_")
                    if(name_list[0] == "QChannel"):   # Dash present in official busdef
                        busdef = "Q-Channel"
                    else:
                        busdef = name_list[0]
                    for i in range(1,len(name_list)):
                      if("Master" in name_list[i] or "Slave" in name_list[i]):
                          mode = name_list[i]
                          index = name_list[i+1]
                          for j in range(i+2, len(name_list)):
                              index += "_" + name_list[j]
                          break;
                      else:
                          busdef += "_" + name_list[i]

                    if mode == "Master":
                        if interface.addressSpace:
                            interfaceMode = ("master", [])
                            interfaceMode[1].append(("addressSpaceRef", "", [("addressSpaceRef", interface.name + "_AS")]))
                            addressSpace = [
                                ("name", interface.name + "_AS"),
                                ("description", "Address space for " + interface.name),
                                ("range", interface.addressSpace),
                                ("width", interface.dwidth)
                            ]
                            self.addressSpaces.append(("addressSpace", addressSpace))
                        else:
                            interfaceMode = ("master", "")
                    else:
                        if interface.addressBlocks or interface.bridges:
                            interfaceMode = ("slave", [])
                            interfaceMode[1].append(("memoryMapRef", "", [("memoryMapRef", interface.name + "_MM")]))
                            if interface.addressBlocks:
                                memoryMap = self.GetMemoryMap(interface.name + "_MM")
                                n = 0
                                for addressBlock in interface.addressBlocks:
                                    ab = [
                                        ("name", "addressBlock%d" % n),
                                        ("baseAddress", addressBlock[0]),
                                        ("range", addressBlock[1]),
                                        ("width", interface.dwidth),
                                        ("usage", addressBlock[2])]
                                    if (addressBlock[2] == "memory"):
                                        ab += [("volatile", addressBlock[3]),
                                               ("access",   addressBlock[4])
                                              ]

                                    memoryMap.append(("addressBlock", ab))
                                    n = n + 1
                            if interface.bridges:
                                for bridge in interface.bridges:
                                    interfaceMode[1].append(("bridge", "", [("masterRef", bridge[0]), ("opaque", bridge[1])]))
                        else:
                            interfaceMode = ("slave", "")

                    busInterface = [
                        ("name", interface.name),
                        ("description", interface.description),
                        ("busType", "", [("vendor", project.busDefs[busdef].vendor), ("library", project.busDefs[busdef].library),
                                         ("name", busdef), ("version", project.busDefs[busdef].busVersion)]),
                        ("abstractionType", "", [("vendor", project.busDefs[busdef].vendor), ("library", project.busDefs[busdef].library),
                                                 ("name", busdef + "_rtl"), ("version", project.busDefs[busdef].absVersion)]),
                        interfaceMode,
                        ("portMaps", portMaps)
                    ]
                    self.busInterfaces.append(("busInterface", busInterface))

                for vectorPort in interface.vectorPorts:
                    name, dir, left, right = vectorPort
                    port = [
                        ("name", name),
                        ("wire", [
                            ("direction", dir),
                            ("vector", [
                                ("left", "%d" % left),
                                ("right", "%d" % right),
                            ])
                        ])
                    ]
                    if ("port", port) not in ports:
                        ports.append(("port", port))

                for scalarPort in interface.scalarPorts:
                    name, dir = scalarPort
                    port = [
                        ("name", name),
                        ("wire", [
                            ("direction", dir)
                        ])
                    ]
                    if ("port", port) not in ports:
                        ports.append(("port", port))

                for multiPort in interface.multiPorts:
                    name, dir, idx = multiPort
                    port = [
                        ("name", name),
                        ("wire", [
                            ("direction", dir)
                        ])
                    ]
                    if ("port", port) not in ports:
                        ports.append(("port", port))

                for splitPort in interface.splitPorts:
                    name, dir, idx, left, right = splitPort
                    port = [
                        ("name", name),
                        ("wire", [
                            ("direction", dir),
                            ("vector", [
                                ("left", "%d" % left),
                                ("right", "%d" % right),
                            ])
                        ])
                    ]
                    if ("port", port) not in ports:
                        ports.append(("port", port))

        self.model.append(("ports", ports))

    ##
    # \fn           ProcParameters
    # \brief        Create IP-XACT nodes from component parameters
    # \param[in]    parameters - list of component parameters
    # \return       None
    def ProcParameters(self, parameters):
        modelParameters = []
        for parameter in parameters:
            if parameter.usage != "constant" and eval(parameter.presence):
                if(parameter.type == "integer"):
                    param_format = "long"
                else:
                    param_format = parameter.type
                modelParameter = [
                    ("name", parameter.name),
                    ("description", parameter.description),
                    ("value", parameter.value, [("id",  parameter.name), ("format", param_format), ("resolve", "immediate")])
                ]
                modelParameters.append(("modelParameter", modelParameter))
        if modelParameters:
            self.model.append(("modelParameters", modelParameters))

    ##
    # \fn           ProcRegisters
    # \brief        Create IP-XACT nodes from component interface properties
    # \param[in]    Component
    # \return       None
    def ProcRegisters(self, registers):
        if self.memoryMaps:
            for n in range(1, len(self.memoryMaps[0][1])):
                addressBlock = self.memoryMaps[0][1][n][1]
                for reg in registers:
                    register = [
                        ("name", reg.name),
                        ("displayName", reg.displayName),
                        ("description", reg.description)
                    ]

                    if reg.dim:
                        register.append(("dim", reg.dim))

                    register += [
                        ("addressOffset", reg.offset),
                        ("size", "32"),
                        ("access", reg.access),
                    ]

                    if reg.reset:
                        register.append(("reset", [("value", reg.reset)]))


                    for fld in reg.fields:
                        field = [
                            ("name", fld[0]),
                            ("description", "description"),
                            ("bitOffset", fld[1]),
                            ("bitWidth", fld[2]),
                            ("access", fld[3])
                        ]
                        register.append(("field", field))
                    addressBlock.append(("register", register))

    ##
    # \fn           ProcFileSets
    # \brief        Create IP-XACT nodes from component interface properties
    # \param[in]    file list, component name
    # \return       None
    def ProcFileSets(self, component):
        files = component.files
        if files:
            fileSet = [
                ("name", "RTL"),
                ("displayName", ""),
                ("description", "This fileset describes the synthesizable RTL source files for this component"),
            ]
            for file in files:
                # This is the top level file
                if component.orig_name + ".v" in file :
                    fileSet.append(
                        ("file", [
                            ("name", file),
                            ("fileType", "verilogSource-2001"),
                            ("isIncludeFile", "false", [ ("externalDeclarations","true") ])
                        ])
                    )
                else :
                    fileSet.append(
                        ("file", [
                            ("name", file),
                            ("fileType", "verilogSource-2001")
                        ])
                    )

            self.fileSets.append(("fileSet", fileSet))

    ##
    # \fn           ProcReferences
    # \brief        Create IP-XACT nodes from component interface properties
    # \param[in]    CoreLink SIE-200 component
    # \return       None
    def ProcReferences(self, component):
        views = []
        if self.fileSets:
            views.append(
                ("view", [
                    ("name", "RTL"),
                    ("description", "RTL view"),
                    ("envIdentifier", "verilogSource:*Simulation:"),
                    ("envIdentifier", "verilogSource:*Synthesis:"),
                    ("language", "verilog"),
                    ("modelName", component.orig_name),
                    ("fileSetRef", [
                        ("localName", "RTL")
                    ])
                ])
            )
        if component.subcomps:
            views.append(
                ("view", [
                    ("name", "Design"),
                    ("description", "Design view"),
                    ("envIdentifier", "verilogSource:*Simulation:"),
                    ("envIdentifier", "verilogSource:*Synthesis:"),
                    ("hierarchyRef", [], [
                        ("vendor", component.vendor),
                        ("library", component.library),
                        ("name", component.name),
                        ("version", component.version)
                    ])
                ])
            )
        if views:
            self.model.append(("views", views))

    ##
    # \fn           ProcRemaps
    # \brief        Create IP-XACT nodes from component remap, remapstate properties
    # \param[in]    CoreLink SIE-200 component
    # \return       None
    def ProcRemaps(self, component):
        remaps = component.remaps
        if remaps:
            for remap in remaps:
                if remap.presence == "True":
                    ipRemap = [
                        ("name", remap.name),
                    ]
                    if remap.subspaceMaps:
                        for subspaceMap in remap.subspaceMaps:
                            ipRemap.append(
                                ("subspaceMap", [
                                    ("name", "subspaceMap_0_" + subspaceMap.baseAddress + "_" + subspaceMap.name + "_state_default"),
                                    ("baseAddress", subspaceMap.baseAddress)
                                ], [("masterRef", subspaceMap.name)])
                            )
                    # Add the remap to the memoryMap
                    memoryMap = self.GetMemoryMap(remap.interface + "_MM")
                    memoryMap.append(("memoryRemap", ipRemap, [("state", remap.state)]))
            # Add the remapstates necessary for the remaps
            remapStates = component.remapStates
            if remapStates:
                for remapState in remapStates:
                    if remapState.presence == "True":
                        ipRemapState = [
                            ("name", remapState.name),
                            ("remapPorts", [
                                ("remapPort", remapState.value, [("portNameRef", remapState.port), ("portIndex", remapState.portIndex)])
                            ])
                        ]
                        self.remapStates.append(("remapState", ipRemapState))

    ##
    # \fn           ProcSubmaps
    # \brief        Create IP-XACT nodes from component submap properties
    # \param[in]    CoreLink SIE-200 component
    # \return       None
    def ProcSubmaps(self, component):
        submaps = component.submaps
        if submaps:
            for submap in submaps:
                if submap.presence == "True":
                    ipSubmap = [
                        ("name", "subspaceMap_0_" + submap.baseAddress + "_" + submap.name + "_state_default"),
                        ("baseAddress", submap.baseAddress)
                    ]
                    # Add the submap to the memoryMap
                    memoryMap = self.GetMemoryMap(submap.interface + "_MM")
                    memoryMap.append(("subspaceMap", ipSubmap, [("masterRef", submap.name)]))

    ##
    # \fn           Generate
    # \brief        Generate an IPXACT component file.
    # \param[in]    CoreLink SIE-200 component
    # \return       None
    def Generate(self, filepath, component):
        super(_IPXACTComponent, self).Generate(component)

        self.ProcFileSets(component)
        self.ProcReferences(component)
        self.ProcInterfaces(component.interfaces)
        self.ProcParameters(component.parameters)
        self.ProcRegisters(component.registers)
        self.ProcRemaps(component)
        self.ProcSubmaps(component)

        if self.busInterfaces:
            self.root.appendChild(self._createTree(("busInterfaces", self.busInterfaces)))
        if self.remapStates:
            self.root.appendChild(self._createTree(("remapStates", self.remapStates)))
        if self.addressSpaces:
            self.root.appendChild(self._createTree(("addressSpaces", self.addressSpaces)))
        if self.memoryMaps:
            self.root.appendChild(self._createTree(("memoryMaps", self.memoryMaps)))
        if self.model:
            self.root.appendChild(self._createTree(("model", self.model)))
        if self.fileSets:
            self.root.appendChild(self._createTree(("fileSets", self.fileSets)))

        self.root.appendChild(self._createTree(("description", component.description)))

        #print self._XMLToString()

        filepath = os.path.join(filepath,"ipxact")
        if not os.path.exists(filepath):
            os.makedirs(filepath)
        self.writeXMLFile(os.path.join(filepath,component.name + ".xml"))

##
# \class    _IPXACTDesign
# \brief    Component IPXACT object.
class _IPXACTDesign(_IPXACTFile):

    def __init__(self):
        super(_IPXACTDesign, self).__init__()
        self.doc = minidom.getDOMImplementation().createDocument(self.namespaceURI, self.nss + "design", None)

    def Generate(self, filepath, component):
        super(_IPXACTDesign, self).Generate(component)

        componentInstances = []
        for subcomp in component.subcomps:
            componentInstances.append(
                ("componentInstance", [
                    ("instanceName", subcomp.name + "_0"),
                    ("componentRef", [], [
                        ("vendor", subcomp.vendor),
                        ("library", subcomp.library),
                        ("name", subcomp.name),
                        ("version", subcomp.version)
                    ])
                ])
            )

        self.root.appendChild(self._createTree(("componentInstances", componentInstances)))

        filepath = os.path.join(filepath, "ipxact")
        if not os.path.exists(filepath):
            os.makedirs(filepath)
        self.writeXMLFile(os.path.join(filepath,component.name + "_design.xml"))


def SetCompParameters(args, component, interactive, config = None, parent_component = None):
    success = True

    component_params = component.parameters
    # Iterate over component parameters.
    for parameter in component_params:
        if parameter.usage != "constant":
            if parent_component:
                parameter.SetValue(parent_component.GetParameter(parameter.name).value)
            elif interactive:
                valid = False
                while not valid:
                    print "Please enter a value for parameter %s " % parameter.name
                    if parameter.minimum and parameter.maximum:
                        print "Within the interval [%s, %s]" % (parameter.minimum, parameter.maximum)
                    elif parameter.enumerations:
                        print "From the choices "
                        for enumeration in parameter.enumerations:
                            print enumeration
                    value = raw_input()
                    valid = parameter.SetValue(value)
                    if not valid:
                        print "Invalid value"
            else:
                # Check command line for parameter.
                name, value = None, None
                for arg in args:
                    if parameter.name in arg:
                        name, value = arg.split("=", 1)
                        break
                if name == parameter.name:
                    if not parameter.SetValue(value):
                        if config != None and checkConfigParam(config, parameter):
                            pass
                        else:
                            print "Invalid value for parameter %s" % (parameter.name)
                elif parameter.usage == "required":
                    if config != None and checkConfigParam(config, parameter):
                        pass
                else:
                    if config != None:
                        checkConfigParam(config, parameter)

    component.RecalculateDefaultParameters()

    # Cycle through all the parameters and lis the ones left on default value
    if not parent_component:
        for parameter in component_params:
            if (parameter.default == "True") and (parameter.usage != "constant"):
                print "No valid value specified for required parameter %s, using default: %s" % (parameter.name, parameter.value)
    return success

# Check the values read in from the config file for the parameter, return true if found it and successfully set it
def checkConfigParam(config, parameter):
    if ("parameters" in config) and (parameter.name in config["parameters"]):
        if parameter.SetValue(config["parameters"][parameter.name]):
            return True
        else:
            print "Invalid value %s in config file for parameter %s, using default: %s" % (config["parameters"][parameter.name],parameter.name, parameter.value)
    return False


def main():

    parser = optparse.OptionParser(usage = "usage: %prog [options] component outdir")
    parser.add_option("-x", "--ipxact", action = "store_true", dest = "ipxact", default = False, help = "Generate IP-XACT file")
    parser.add_option("-c", "--ipcatalog", action = "store_true", dest = "ipcatalog", default = False, help = "Generate IP-Catalog entry (ARM Internal)")
    parser.add_option("-i", "--interactive", action = "store_true", dest = "interactive", default = False, help = "Prompt for component parameters")
    parser.add_option("-f", "--config", action = "store", dest = "configFile", default = "", help = "Configuration file to use")
    parser.add_option("--uniquifier", action = "store", dest = "uniquifier", default = "", help = "Component uniquifier")

    options, args = parser.parse_args()

    if (len(args) < 2) or (not options.ipxact and not options.ipcatalog):
        print parser.print_help()
        return -1

    # Read in the configuration file if one is specified
    config = None
    if options.configFile != "":
        config = configReader.readConfig(options.configFile)
        # Use config_name as uniquifier if none is specified on command line
        if options.uniquifier == "":
            options.uniquifier = config["config_name"]

    if args[0] in components.__comps__:
        component = eval("%s.%s()" % (args[0], args[0]))
        outdir = os.path.realpath(args[1])

        if os.access(outdir, os.W_OK):

            if options.ipcatalog:
                IPCatalogEntry = _IPCatalogEntry()
                IPCatalogEntry.Generate(outdir, component)

            if options.ipxact:
                if SetCompParameters(args, component, options.interactive, config, None):
                    if component.Configure(options.uniquifier):
                        IPXACTComponent = _IPXACTComponent()
                        IPXACTComponent.Generate(os.path.join(outdir,"logical",component.name), component)

                        if component.gen_bridge_halves:
                            component_s = eval("%s_s.%s_s()" % (args[0], args[0]))
                            if SetCompParameters(args, component_s, options.interactive, config, component):
                                if component_s.Configure(options.uniquifier):
                                    IPXACTComponent_s = _IPXACTComponent()
                                    IPXACTComponent_s.Generate(os.path.join(outdir,"logical",component.name), component_s)

                            component_m = eval("%s_m.%s_m()" % (args[0], args[0]))
                            if SetCompParameters(args, component_m, options.interactive, config, component):
                                if component_m.Configure(options.uniquifier):
                                    IPXACTComponent_m = _IPXACTComponent()
                                    IPXACTComponent_m.Generate(os.path.join(outdir,"logical",component.name), component_m)

                        if component.subcomps:
                            IPXACTDesign = _IPXACTDesign()
                            IPXACTDesign.Generate(os.path.join(outdir,"logical",component.name), component)

                            for subcomp in component.subcomps:
                                if SetCompParameters(args, subcomp, options.interactive, config, None):
                                    if subcomp.Configure(options.uniquifier):
                                        IPXACTComponent = _IPXACTComponent()
                                        IPXACTComponent.Generate(os.path.join(outdir,"logical",component.name), subcomp)




                    else:
                        print "Component configuration failure"
                        return -1

        else:
            print "ERROR: Output directory not writable"
            return -1

    else:
        print "Available components:"
        for name in components.__comps__:
            print name
        return -1


if __name__ == "__main__":
    main()
