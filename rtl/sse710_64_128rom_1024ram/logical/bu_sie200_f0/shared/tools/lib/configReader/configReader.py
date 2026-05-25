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
#     Checked In : Tue Dec 6 15:14:52 2016 +0000
#     Revision   : c61f93d
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import sys
import re
import os

class configReader:

    def __init__(self):
        self.line = ""
        self.fileHandle = None
        self.config = {}

    def parseConfig(self, configFile):
        # Open the config file
        try:
            self.fileHandle = open(configFile, "r")
        except IOError as err:
            print "Unable to open file: %s" % (err)
            sys.exit(1)
        # Get the first line of the file
        self.readNextLine()
        # Start with parsing the top group
        self.config = self.parseSubGroup(-1)
        # Close the file
        self.fileHandle.close()
        # Set config_name to the default value if it was not defined in the file
        if not "config_name" in self.config:
            config_name_default = os.path.splitext(os.path.basename(configFile))[0]
            self.config["config_name"] = config_name_default
        return self.config

    def parseKeyValue(self, expectedIndent, prevIndent):
        # Check indentation level
        indent = len(self.line) - len(self.line.lstrip(" "))
        if indent != expectedIndent:
            print "Indentation level not matching expected"
            if (prevIndent == -1):
                print "Expected: %s\tFound: %s" % (expectedIndent, indent)
            else:
                print "Expected: %s or %s\tFound: %s" % (expectedIndent, prevIndent, indent)
            print self.line
            sys.exit(1)
        # Strip indentation
        strippedLine = self.line.lstrip(" ")
        # If this line is a full key:value pair collect everything and return them
        match = re.match("(\w+)\s*:\s*(.+)", strippedLine)
        if match:
            # Get the next line as this key:value pair has been processed
            self.readNextLine()
            return match.group(1, 2)
        # If this line is only a key collect the whole section of key:value pairs
        match = re.match("(\w+)\s*:", strippedLine)
        if match:
            key = match.group(1)
            # Get the next line as this key: has been processed
            self.readNextLine()
            value = self.parseSubGroup(prevIndent = indent)
            return key, value
        # Wrong format
        print "Invalid config file format:"
        print self.line
        sys.exit(1)

    def parseSubGroup(self, prevIndent):
        subGroup = {};
        if prevIndent == -1:
            # Top level of the config file, expected indentation level is 0
            groupIndent = 0
        else:
            # First line in subgroup is used to determine the indentation level of the subgroup
            groupIndent = len(self.line) - len(self.line.lstrip(" "))
        # check the minimum indentation
        if (groupIndent < prevIndent + 1):
            print "Indentation level not matching expected"
            print "Expected minimum: %s\tFound: %s" % (prevIndent + 1, groupIndent)
            print self.line
            sys.exit(1)
        # Go through all the lines in the subgroup
        while True:
            # Reached the end of file
            if self.line == "":
                break
            # Check if the indentation to see if still in subgroup or reached the end of it
            curIndent = len(self.line) - len(self.line.lstrip(" "))
            if curIndent <= prevIndent:
                return subGroup
            else:
                newKey, newValue = self.parseKeyValue(groupIndent, prevIndent)
                # Check if the key is already defined
                self.checkKey(subGroup, newKey, newValue)
                # Store new key
                subGroup[newKey] = newValue
        # Reached end of file
        return subGroup

    def checkKey(self, inHash, key, value):
        if key in inHash:
            print "Warning: Key '%s' is already defined as: '%s'" % (key, inHash[key])
            print "         Overriding to: %s" % (value)

    def readNextLine(self):
        while True:
            self.line = self.fileHandle.readline()
            # Reached the end of file
            if self.line == "":
                break
            # Reached a non empty line
            if not (re.match("\s*#", self.line) or re.match("\s*$", self.line)):
                self.line = re.sub("\s*#.*", "",self.line)
                break
