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
#     Checked In : Mon May 29 09:21:00 2017 +0100
#     Revision   : 816cda9
#     Release    : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
# ----------------------------------------------------------------------------
#  Purpose :
# ----------------------------------------------------------------------------

import os
import base

class cfgif(base.Interface):
    def __init__(self, suffix, width=1):
        super(cfgif, self).__init__()
        self.name = "Staticcfg_Slave" + suffix
        self.width = width
        self.suffix = suffix

    def Configure(self, parameters):
        if(self.width > 1):
            vectorPorts = [
                ( "cfg" + self.suffix, "in", self.width-1, 0)
            ]
            self.vectorPorts.extend(vectorPorts)

        else:
            scalarPorts = [
                ( "cfg" + self.suffix, "in")
            ]
            self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        return "CONFIGURATION"


class sie200_qchanif(base.Interface):
    def __init__(self, prefix, suffix, clk_name):
        super(sie200_qchanif, self).__init__()
        self.name = "QChannel_Slave_" + prefix + suffix[1:]
        self.prefix = prefix
        self.suffix = suffix
        self.description = "Q-channel Slave interface for " + prefix + suffix

        self.clockRelation = clk_name

    def Configure(self, parameters):
        scalarPorts = [
            ( self.prefix + "_qreqn"     + self.suffix,"in"  ),
            ( self.prefix + "_qacceptn"  + self.suffix,"out" ),
            ( self.prefix + "_qactive"   + self.suffix,"out" ),
            ( self.prefix + "_qdeny"     + self.suffix,"out" )
        ]
        self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        name = super(sie200_qchanif, self).PhysicalToLogical(name)
        pref, n, suf = name.split("_",2)

        if n.endswith('N'):
            n=n[:-1] + "n"

        return n


class ahbdefslvif(base.Interface):
    def __init__(self, suffix=""):
        super(ahbdefslvif, self).__init__("hclk")

        if (suffix == "_ds"):   # Default slave prot of periph prot controller
          self.slv_in  = "out"
          self.slv_out = "in"
          if_name = "Master"
        else:
          self.slv_in  = "in"
          self.slv_out = "out"
          if_name = "Slave"

        self.name = "AHB5Target_" + if_name + "_0"
        self.description = "AHB5 Default Slave interface " + if_name + " side"

        self.suffix = suffix

    def Configure(self, parameters):

        scalarPorts = [
            ("hclk"       , "in"),
            ("hresetn"    , "in"),
            ("hsel"       + self.suffix, self.slv_in),
            ("hready"     + self.suffix, self.slv_in),
            ("hexokay"    + self.suffix, self.slv_out),
            ("hreadyout"  + self.suffix, self.slv_out),
            ("hresp"      + self.suffix, self.slv_out),

            ("hwrite",  "phantom")
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("htrans"     + self.suffix, self.slv_in,   1, 0),

            ("haddr",   "phantom",  31, 0),
            ("hsize",   "phantom",  2,  0),
            ("hwdata",  "phantom",  31, 0),
            ("hrdata",  "phantom",  31, 0),
        ]
        self.vectorPorts.extend(vectorPorts)


    def PhysicalToLogical(self, name):
        name = super(ahbdefslvif, self).PhysicalToLogical(name)
        n = name.split("_")
        name = n[0]
        if name == "HSEL":
            name += "x"
        if name == "HRESETN":
            name = "HRESETn"
        return name


class irqif(base.Interface):
    def __init__(self, prefix, clk_name="hclk_s", vec_idx="", vec_max="", vec_min="", suffix=""):
        super(irqif, self).__init__()

        self.name = "interrupt_Master_" + prefix + vec_idx + suffix
        self.description = "Interrupt interface for " + prefix + vec_idx + suffix
        self.prefix = prefix
        self.clk_name = clk_name
        self.clockRelation = self.clk_name
        self.vec_idx = vec_idx
        self.vec_max = vec_max
        self.vec_min = vec_min
        self.suffix = suffix

    def Configure(self, parameters):
        if self.vec_idx:
            scalarPorts = [
                (self.clk_name, "in"),
            ]
            self.scalarPorts.extend(scalarPorts)
            splitPorts = [
                (self.prefix + "_irq" + self.suffix, "out",  int(self.vec_idx, 0), int(self.vec_max, 0), int(self.vec_min, 0)),
            ]
            self.splitPorts.extend(splitPorts)

        else:
            scalarPorts = [
                (self.clk_name, "in"),
                (self.prefix + "_irq" + self.suffix, "out")
            ]
            self.scalarPorts.extend(scalarPorts)


    def PhysicalToLogical(self, name):
        name = super(irqif, self).PhysicalToLogical(name)
        if("CLK" in name):
            return "CLK"
        else:
            return "IRQ"

class internalInterrupt(base.Interface):
    def __init__(self, prefix, sig_mask=0, sig_enable=0, sig_clear=0, clk_name="hclk_s", suffix=""):
        super(internalInterrupt, self).__init__()

        self.name = "InternalInterrupt_Slave_" + prefix + suffix
        self.description = "Internal Interrupt interface for " + prefix + suffix
        self.prefix = prefix
        self.sig_clear = sig_clear
        self.sig_enable = sig_enable
        self.sig_mask = sig_mask
        self.clk_name = clk_name
        self.clockRelation = self.clk_name
        self.suffix = suffix

    def Configure(self, parameters):
        scalarPorts = [
            (self.clk_name, "in")
        ]
        if(self.sig_mask):
            scalarPorts += [(self.prefix + "_irq_mask" + self.suffix, "in")]
        if(self.sig_enable):
            scalarPorts += [(self.prefix + "_irq_enable" + self.suffix, "in")]
        if(self.sig_clear):
            scalarPorts += [(self.prefix + "_irq_clear" + self.suffix, "in")]
        if(scalarPorts != []):
            self.scalarPorts.extend(scalarPorts)


    def PhysicalToLogical(self, name):
        name = super(internalInterrupt, self).PhysicalToLogical(name)
        if("CLK" in name):
            return "CLK"
        else:
            sfx=len(self.suffix)
            if(sfx):
                name = name[:-(sfx)]

            n = name.split("_")
            return n[-2] + "_" + n[-1]

class extsramif(base.Interface):
    def __init__(self):
        super(extsramif, self).__init__("hclk")

        self.name = "SRAM_sp_basic_Master_0"
        self.description = " External SRAM interface with active low control signals"

        self.awidth = "$ADDR_WIDTH"

    def Configure(self, parameters):
        self.awidth = base.SubstituteParam(self.awidth, parameters)

        aw = int(self.awidth, 0)
        scalarPorts = [
            ("hclk", "in"),
            ("hresetn", "in"),
            ("we_n", "out"),
            ("oe_n", "out"),
            ("ce_n", "out"),
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("addr",    "out",  aw-1, 0 ),
            ("dataout", "out",  15,   0 ),
            ("datain",  "in",   15,   0 )
        ]
        self.vectorPorts.extend(vectorPorts)

        multiPorts = [
            ("lb_n", "out", 0),
            ("ub_n", "out", 1)
        ]
        self.multiPorts.extend(multiPorts)

        if ("Master" in self.name) :
            self.dwidth       = "16"
            self.addressSpace = "0x%X" % (1 << aw)


    def PhysicalToLogical(self, name):
        name = super(extsramif, self).PhysicalToLogical(name)
        if("CLK" in name):
            return "CLK"
        elif("RESET" in name):
            return "RESETn"
        else:
            ret_name=""
            if (name == "ADDR"):
                ret_name = "A"
            elif (name == "DATAOUT"):
                ret_name = "D"
            elif (name == "DATAIN"):
                ret_name = "Q"
            elif (name == "WE_N"):
                ret_name = "WEN"
            elif (name == "OE_N"):
                ret_name = "REN"
            elif (name == "CE_N"):
                ret_name = "CEN"
            elif (name == "LB_N"):
                ret_name = "BEN"
            elif (name == "UB_N"):
                ret_name = "BEN"
            return ret_name

class sramif(base.Interface):
    def __init__(self, prefix):
        super(sramif, self).__init__("hclk")
        self.busdef = "SRAM_sp_activehigh"
        self.name = "SRAM_sp_activehigh_Master_0"
        self.description = " Internal SRAM interface with active high control signals"

        self.awidth = "$ADDR_WIDTH"
        self.prefix = prefix

    def Configure(self, parameters):
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        aw = int(self.awidth, 0) - 2

        scalarPorts = [
            ("hclk", "in"),
            ("hresetn", "in"),

            (self.prefix + "_cs", "out")
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            (self.prefix + "_addr",   "out",  aw-1, 0 ),
            (self.prefix + "_wdata",  "out",  31,   0 ),
            (self.prefix + "_rdata",  "in",   31,   0 ),
            (self.prefix + "_wen",    "out",  3,    0 )
        ]
        self.vectorPorts.extend(vectorPorts)
        if ("Master" in self.name) :
            self.dwidth       = "32"
            self.addressSpace = "0x%X" % (1 << aw)

    def PhysicalToLogical(self, name):
        name = super(sramif, self).PhysicalToLogical(name)
        if("CLK" in name):
            return "CLK"
        elif("RESET" in name):
            return "RESETn"
        else:
            n = name.split("_")
            n = n[-1]
            if (n == "ADDR"):
                ret_name = "A"
            elif (n == "WDATA"):
                ret_name = "D"
            elif (n == "RDATA"):
                ret_name = "Q"
            elif (n == "WEN"):
                ret_name = "WE"
            elif (n == "CS"):
                ret_name = "CE"

            return ret_name



class dftif(base.Interface):
    def __init__(self):
        super(dftif, self).__init__("hclk")

        self.name = "DFTInterface_Slave_0"
        self.description = "DFT interface"

    def Configure(self, parameters):
        scalarPorts = [
            ("dftramhold", "in")
        ]
        self.scalarPorts.extend(scalarPorts)


class handshakeif(base.Interface):
    def __init__(self, prefix, master = 0):
        super(handshakeif, self).__init__()

        if (master):
          self.slv_in  = "out"
          self.slv_out = "in"
          if_name = "Master"
        else:
          self.slv_in  = "in"
          self.slv_out = "out"
          if_name = "Slave"

        self.prefix = prefix
        self.name = "HandShake_" + if_name + "_" + prefix
        self.description = "Request / Acknowledge " + if_name + " interface for " + prefix

    def Configure(self, parameters):
        scalarPorts = [
            (self.prefix + "_req", self.slv_in),
            (self.prefix + "_ack", self.slv_out)
        ]
        self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        name = super(handshakeif, self).PhysicalToLogical(name)
        if ("REQ" in name):
            return "REQ"
        else:
            return "ACK"


class apbif(base.Interface):
    def __init__(self, ismaster, suffix, clk_prefix="p", clk_suffix="", memrange=""):
        super(apbif, self).__init__()
        if ismaster:
          self.slv_in   = "out"
          self.slv_out  = "in"
          if_name       = "Master"
        else:
          self.slv_in   = "in"
          self.slv_out  = "out"
          if_name       = "Slave"

        self.suffix = suffix
        if (len(suffix) > 2):
            self.suf_short = ""
            for i in range(0, len(suffix)):
                if(suffix[i] == "_"):
                  i+=2  #Skip _s and _m parameters
                else:
                  self.suf_short += suffix[i]
        else :
            self.suf_short = "0"

        self.clk_prefix = clk_prefix
        self.clk_suffix = clk_suffix
        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"

        self.range  = memrange

        self.description = "APB4 interface " + if_name + " side " + self.suffix
        self.name = "APB4_" + if_name + "_" + self.suf_short

        self.clockRelation = self.clk_prefix + "clk"

    def Configure(self, parameters):
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)

        aw = int(self.awidth, 0)
        dw = int(self.dwidth, 0)

        vectorPorts = [
            ("paddr"   + self.suffix,    self.slv_in,   aw - 1,   0),
            ("pwdata"  + self.suffix,    self.slv_in,   dw - 1,   0),
            ("prdata"  + self.suffix,    self.slv_out,  dw - 1,   0),
            ("pprot"   + self.suffix,    self.slv_in,   2,        0),
            ("pstrb"   + self.suffix,    self.slv_in,   dw/8 - 1, 0),

        ]
        self.vectorPorts.extend(vectorPorts)

        scalarPorts = [
            (self.clk_prefix + "clk" + self.clk_suffix,    "in"),
            (self.clk_prefix + "resetn" + self.clk_suffix,   "in"),
            ("psel"    + self.suffix, self.slv_in),
            ("penable" + self.suffix, self.slv_in),
            ("pwrite"  + self.suffix, self.slv_in),
            ("pready"  + self.suffix, self.slv_out),
            ("pslverr" + self.suffix, self.slv_out)
        ]
        self.scalarPorts.extend(scalarPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << aw)

    def PhysicalToLogical(self, name):
        name = super(apbif, self).PhysicalToLogical(name)
        n = name.split("_")
        name = n[0]
        if name == "PSEL":
            name += "x"
        if (name[0] == "H"):    # In some module AHB clock/reset is common with APB clock
            name = "P" + name[1:]

        if name.endswith('N'):
            name=name[:-1] + "n"

        return name

class apbif_hsel(apbif):
    def __init__(self, ismaster, suffix, clk_prefix="p", memrange=""):
        super(apbif_hsel, self).__init__(ismaster, suffix, clk_prefix, memrange)


    def Configure(self, parameters):
        super(apbif_hsel, self).Configure(parameters)


        # Remove PSEL from scalarports and make it phantom wide
        del self.scalarPorts[2]
        psel_phantom = [
            ("psel_phantom", "phantom")
        ]
        self.scalarPorts.extend(psel_phantom)

# For APB interfaces that don't have their own clock, instead are synchronous with the AHB and use just a clock enable
class apbif_clken(apbif):
    def __init__(self, ismaster, suffix, clk_prefix="h", memrange=""):
        super(apbif_clken, self).__init__(ismaster, suffix, clk_prefix, memrange)


    def Configure(self, parameters):
        super(apbif_clken, self).Configure(parameters)


        # Add a PCLKEN instead
        pclken_port = [
            ("pclk_en" + self.clk_suffix,    "in")
        ]
        self.scalarPorts = pclken_port + self.scalarPorts

    def PhysicalToLogical(self, name):
        if name == "pclk_en":
          name = "PCLKEN"
        else:
          name = super(apbif_clken, self).PhysicalToLogical(name)

        return name

class ahbBaseIf(base.Interface):
    def __init__(self, suffix, clkrst_suffix, master=0, nonsec=1, excl=1, mlock=1, prot=7, burst=1, resp_vec=0, clken=0):
        super(ahbBaseIf, self).__init__()
        if ("_m" in suffix) or master:
          self.slv_in  = "out"
          self.slv_out = "in"
          self.if_name = "Master"
        else:
          self.slv_in  = "in"
          self.slv_out = "out"
          self.if_name = "Slave"

        self.suffix = suffix
        self.clkrst_suffix = clkrst_suffix

        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"
        self.mwidth = "$MASTER_WIDTH"
        self.uwidth = "$USER_WIDTH"

        self.excl = excl
        self.mlock = mlock
        self.nonsec = nonsec
        self.prot = prot
        self.burst = burst
        self.resp_vec = resp_vec
        self.clken = clken

        self.clockRelation = "hclk"       + self.clkrst_suffix

        if (len(suffix) > 2):
            self.suf_short = ""
            for i in range(0, len(suffix)):
                if(suffix[i] == "_"):
                  i+=2  #Skip _s and _m parameters
                else:
                  self.suf_short += suffix[i]
        else :
            self.suf_short = "0"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)
        self.mw = int(self.mwidth, 0)
        self.uw = int(self.uwidth, 0)

    def Configure(self, parameters):
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.uwidth = base.SubstituteParam(self.uwidth, parameters)

        self.SetSize()

        scalarPorts = [
            ("hclk"    + self.clkrst_suffix, "in"),
            ("hresetn"    + self.clkrst_suffix, "in"),
            ("hwrite"     + self.suffix, self.slv_in)
        ]

        if(self.clken):
            scalarPorts += [
              ("hclk_en" + self.clkrst_suffix, "in")
            ]

        if(self.resp_vec == 0):
            scalarPorts += [
                ("hresp"      + self.suffix, self.slv_out),
            ]

        if(self.nonsec):
            scalarPorts += [
              ("hnonsec"  + self.suffix, self.slv_in),
            ]

        if(self.mlock):
            scalarPorts += [
              ("hmastlock"  + self.suffix, self.slv_in),
            ]

        if(self.excl):
            scalarPorts += [
              ("hexcl"      + self.suffix, self.slv_in),
              ("hexokay"    + self.suffix, self.slv_out)
            ]

        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("haddr"      + self.suffix, self.slv_in,   self.aw - 1, 0),
            ("htrans"     + self.suffix, self.slv_in,   1, 0),
            ("hsize"      + self.suffix, self.slv_in,   2, 0),
            ("hwdata"     + self.suffix, self.slv_in,   self.dw - 1, 0),
            ("hrdata"     + self.suffix, self.slv_out,  self.dw - 1, 0)
        ]
        if(self.resp_vec):
            splitPorts = [
                ("hresp"      + self.suffix,  self.slv_out,  0, self.resp_vec, 0),
            ]
            self.splitPorts.extend(splitPorts)

        if(self.prot):
            vectorPorts += [
              ("hprot"      + self.suffix, self.slv_in, self.prot-1, 0),
            ]

        if(self.burst):
            vectorPorts += [
              ("hburst"     + self.suffix, self.slv_in,   2, 0),
            ]

        if(self.mw):
            vectorPorts += [
              ("hmaster"    + self.suffix, self.slv_in,   self.mw - 1, 0),
            ]

        if(self.uw):
            vectorPorts += [
              ("hauser"     + self.suffix, self.slv_in,   self.uw - 1, 0),
              ("hwuser"     + self.suffix, self.slv_in,   self.uw - 1, 0),
              ("hruser"     + self.suffix, self.slv_out,  self.uw - 1, 0)
            ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)


    def PhysicalToLogical(self, name):
        name = super(ahbBaseIf, self).PhysicalToLogical(name)
        if ("HCLK_EN" in name):
            name = "HCLKEN"
        elif ("HCLK" in name):
            name = "HCLK"
        elif ("HRESETN" in name):
            name = "HRESETn"
        elif ("HSEL" in name):
            name = "HSELx"
        else:
            sfx=len(self.suffix)
            if(sfx):
                name = name[:-(sfx)]

        return name


class ahbif(ahbBaseIf):
    def __init__(self, suffix="", clkrst_suffix="", hsel_width=1, hsel_multi=0, master=0, nonsec=1, excl=1, mlock=1, prot=7, burst=1, resp_vec=0, clken=0):
        super(ahbif, self).__init__(suffix, clkrst_suffix, master, nonsec, excl, mlock, prot, burst, resp_vec, clken)

        self.description = "AHB5 Target interface " + self.if_name + " side"
        self.name = "AHB5Target_" + self.if_name + "_" + self.suf_short
        self.description += " for port " + self.suf_short

        self.hsel_width = hsel_width
        self.hsel_multi = hsel_multi

    def Configure(self, parameters):
        super(ahbif, self).Configure(parameters)

        scalarPorts = [
            ("hready"     + self.suffix, self.slv_in),
            ("hreadyout"  + self.suffix, self.slv_out)
        ]
        self.scalarPorts.extend(scalarPorts)

        if(self.hsel_multi == 0):
            if(self.hsel_width == 0):
                hsel_port = [
                    ("hsel_phantom", "phantom")
                ]
                self.scalarPorts.extend(hsel_port)

            elif(self.hsel_width == 1):
                hsel_port = [
                    ("hsel"       + self.suffix, self.slv_in)
                ]
                self.scalarPorts.extend(hsel_port)

            else:
                hsel_port = [
                    ("hsel"       + self.suffix, self.slv_in, self.hsel_width - 1, 0)
                ]
                self.vectorPorts.extend(hsel_port)




class ahbif_us(ahbif):
    def __init__(self, suffix, clkrst_suffix):
        super(ahbif_us, self).__init__(suffix, clkrst_suffix)

    def SetSize(self):
        super(ahbif_us, self).SetSize()
        self.dw *= 2

class ahbif_ds(ahbif):
    def __init__(self, suffix, clkrst_suffix):
        super(ahbif_ds, self).__init__(suffix, clkrst_suffix)

    def SetSize(self):
        super(ahbif_ds, self).SetSize()
        self.dw /= 2


class ahbinitif(ahbBaseIf):
    def __init__(self, suffix, clkrst_suffix, master=0, nonsec=1, excl=1,mlock=1, prot=7, burst=1, resp_vec=0, clken=0):
        super(ahbinitif, self).__init__(suffix, clkrst_suffix, master, nonsec, excl, mlock, prot, burst, resp_vec, clken)

        self.description = "AHB5 Initiator interface " + self.if_name + " side"
        self.name = "AHB5Initiator_" + self.if_name + "_" + self.suf_short
        self.description += " for port " + self.suf_short

    def Configure(self, parameters):
        super(ahbinitif, self).Configure(parameters)

        scalarPorts = [
            ("hready"     + self.suffix, self.slv_out)
        ]

        self.scalarPorts.extend(scalarPorts)

class ahb3if(ahbif):
    def __init__(self, suffix="", clkrst_suffix="", master=0, mlock=1, prot=4, burst=1, resp_vec=0, clken=0):
        super(ahb3if, self).__init__(suffix, clkrst_suffix, 1, 0, master, 0, 0, mlock, prot, burst, resp_vec, clken)

        self.description = "AHBLite Target interface " + self.if_name + " side"
        self.name = "AHBLiteTarget_" + self.if_name + "_" + self.suf_short
        self.description += " for port " + self.suf_short
        self.mwidth = "0"

class ahb3initif(ahbinitif):
    def __init__(self, suffix, clkrst_suffix, master=0, mlock=1, prot=4, burst=1, resp_vec=0, clken=0):
        super(ahb3initif, self).__init__(suffix, clkrst_suffix, master, 0, 0, mlock, prot, burst, resp_vec, clken)

        self.description = "AHBLite Initiator interface " + self.if_name + " side"
        self.name = "AHBLiteInitiator_" + self.if_name + "_" + self.suf_short
        self.description += " for port " + self.suf_short
        self.mwidth = "0"

# cfg_gate_resp input considered as sideband

class acg_adhoc_if(base.Interface):
    def __init__(self):
        super(acg_adhoc_if, self).__init__()

        self.name=""

    def Configure(self, parameters):
        scalarPorts = [
            ("cfg_gate_resp", "in")
        ]
        self.scalarPorts.extend(scalarPorts)


class dyncfgif(base.Interface):
    def __init__(self, port_name, clk_name, width=1):
        super(dyncfgif, self).__init__(clk_name)
        self.name = "DynamicConfig_Slave_" + port_name
        self.width = width
        self.port_name = port_name
        self.clk_name = clk_name

    def Configure(self, parameters):
        if(self.width > 1):
            vectorPorts = [
                ( self.port_name, "in", self.width-1, 0)
            ]
            self.vectorPorts.extend(vectorPorts)

            scalarPorts = [
                ( self.clk_name, "in")
            ]
            self.scalarPorts.extend(scalarPorts)

        else:
            scalarPorts = [
                ( self.clk_name,        "in"),
                ( self.port_name,  "in")
            ]
            self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        if name == self.port_name :
            return "CONFIGURATION"
        else :
            return "CLK"

class statusif(base.Interface):
    def __init__(self, port_name, clk_name, rst_name, width=1):
        super(statusif, self).__init__(clk_name)
        self.name = "Status_Master_" + port_name
        self.width = width
        self.port_name = port_name
        self.clk_name = clk_name
        self.rst_name = rst_name

    def Configure(self, parameters):
        scalarPorts = [
            ( self.clk_name, "in"),
            ( self.rst_name, "in"),
        ]

        if(self.width > 1):
            vectorPorts = [
                ( self.port_name, "out", self.width-1, 0)
            ]
            self.vectorPorts.extend(vectorPorts)
        else:
            scalarPorts += [
                ( self.port_name,  "out")
            ]
        self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        if name == self.port_name :
            return "STATUS"
        elif name == self.clk_name :
            return "CLK"
        else :
            return "RESETn"


class gpioif(base.Interface):
    def __init__(self, port_name, direction, clk_name,rst_name, width=1):
        super(gpioif, self).__init__(clk_name)
        if (direction == "in"):
            self.name = "GPIO_Slave_" + port_name
        else:
            self.name = "GPIO_Master_" + port_name
        self.width = width
        self.port_name = port_name
        self.clk_name = clk_name
        self.rst_name = rst_name
        self.direction = direction

    def Configure(self, parameters):
        scalarPorts = [
            ( self.clk_name, "in"),
            ( self.rst_name, "in"),
        ]

        if(self.width > 1):
            vectorPorts = [
                ( self.port_name, self.direction, self.width-1, 0)
            ]
            self.vectorPorts.extend(vectorPorts)
        else:
            scalarPorts += [
                ( self.port_name,  self.direction)
            ]
        self.scalarPorts.extend(scalarPorts)

    def PhysicalToLogical(self, name):
        if name == self.port_name :
            return "GPIO_PORT"
        elif name == self.clk_name :
            return "CLK"
        else :
            return "RESETn"



class idauif(base.Interface):
    def __init__(self, awidth, suffix=""):
        super(idauif, self).__init__("hclk")

        self.aw = awidth
        self.name = "IDAU_Master_0" + suffix
        self.suffix = suffix

    def Configure(self, parameters):

        scalarPorts = [
            ("hclk"       , "in"),
            ("hresetn"    , "in"),
            ("idauns"   + self.suffix , "in"),
            ("idaunchk" + self.suffix , "in"),
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("idauaddr" + self.suffix   , "out",   self.aw - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

    def PhysicalToLogical(self, name):
        name = super(idauif, self).PhysicalToLogical(name)
        if ("IDAU" in name):
            n = name.split("_")
            name = n[0]
        return name

# Master and Slave sides of the busdef do not follow the master parameter here
class internal_sie200_acg_core_if(base.Interface):
    def __init__(self, master):
        super(internal_sie200_acg_core_if, self).__init__("")
        if master:
            self.slv_in  = "out"
            self.slv_out = "in"
            self.if_name = "Slave"
        else:
            self.slv_in  = "in"
            self.slv_out = "out"
            self.if_name = "Master"

    def Configure(self, parameters):
        scalarPorts = [
            ("s_active_reg",  self.slv_out),
            ("pwr_ext_wake",  self.slv_out),
            ("m_lp_done_n",   self.slv_out),
            ("pwr_lp_req_n",  self.slv_out),
            ("m_ext_wake",    self.slv_in),
            ("m_lp_req_n",    self.slv_in),
            ("pwr_lp_done_n", self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)


class internal_sie200_ahb5_to_apb_sync_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_to_apb_sync_if, self).__init__(master)

        self.name = "ahb5toapbsyncInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.mwidth = "$MASTER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.mw = int(self.mwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_to_apb_sync_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.dwidth = "32"
        self.SetSize()

        scalarPorts = [
            ("apb_trnf_req",    self.slv_out),
            ("pwrite_i",        self.slv_out),
            ("apb_trnf_ack",    self.slv_in),
            ("pslverr_i",       self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)


        vectorPorts = [
            ( "pmaster_i", self.slv_out, self.mw-1, 0),
            ( "paddr_i",   self.slv_out, self.aw-1, 0),
            ( "pstrb_i",   self.slv_out, 3, 0),
            ( "pprot_i",   self.slv_out, 2, 0),
            ( "pwdata_i",  self.slv_out, 31, 0),
            ( "prdata_r",  self.slv_in,  31, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)


class internal_sie200_ahb5_to_apb_async_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_to_apb_async_if, self).__init__(master)

        self.name = "ahb5toapbasyncInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.mwidth = "$MASTER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.mw = int(self.mwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_to_apb_async_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.dwidth = "32"
        self.SetSize()

        scalarPorts = [
            ("s_trans_valid", self.slv_out),
            ("s_write",       self.slv_out),
            ("s_req_h",       self.slv_out),
            ("s_resp",        self.slv_in),
            ("s_ack_p",       self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)


        vectorPorts = [
            ( "s_addr",  self.slv_out, self.aw-3, 0),
            ( "s_prot",  self.slv_out, 2, 0),
            ( "s_strb",  self.slv_out, 3, 0),
            ( "s_master",self.slv_out, self.mw-1, 0),
            ( "s_wdata", self.slv_out, 31, 0),
            ( "s_rdata", self.slv_in,  31, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)


class internal_sie200_ahb5_access_ctrl_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_access_ctrl_if, self).__init__(master)

        self.name = "ahb5accessctrlInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"
        self.mwidth = "$MASTER_WIDTH"
        self.uwidth = "$USER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)
        self.mw = int(self.mwidth, 0)
        self.uw = int(self.uwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_access_ctrl_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.uwidth = base.SubstituteParam(self.uwidth, parameters)

        self.SetSize()

        scalarPorts = [
            ("hsel_i"      , self.slv_out),
            ("hnonsec_i"   , self.slv_out),
            ("hwrite_i"    , self.slv_out),
            ("hready_i"    , self.slv_out),
            ("hmastlock_i" , self.slv_out),
            ("hexcl_i"     , self.slv_out),
            ("hreadyout_i" , self.slv_in),
            ("hresp_i"     , self.slv_in),
            ("hexokay_i"   , self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("haddr_i"     , self.slv_out,   self.aw - 1, 0),
            ("htrans_i"    , self.slv_out,   1, 0),
            ("hsize_i"     , self.slv_out,   2, 0),
            ("hprot_i"     , self.slv_out,   6, 0),
            ("hburst_i"    , self.slv_out,   2, 0),
            ("hwdata_i"    , self.slv_out,   self.dw - 1, 0),
            ("hmaster_i"   , self.slv_out,   self.mw - 1, 0),
            ("hauser_i"    , self.slv_out,   self.uw - 1, 0),
            ("hwuser_i"    , self.slv_out,   self.uw - 1, 0),
            ("hrdata_i"    , self.slv_in,    self.dw - 1, 0),
            ("hruser_i"    , self.slv_in,    self.uw - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)



class internal_sie200_ahb5_to_ahb5_sync_up_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_to_ahb5_sync_up_if, self).__init__(master)

        self.name = "ahb5toahb5syncupInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"
        self.mwidth = "$MASTER_WIDTH"
        self.uwidth = "$USER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)
        self.mw = int(self.mwidth, 0)
        self.uw = int(self.uwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_to_ahb5_sync_up_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.uwidth = base.SubstituteParam(self.uwidth, parameters)

        self.SetSize()

        scalarPorts = [
            ("hnonsecs_reg"   , self.slv_out),
            ("hwrites_reg"    , self.slv_out),
            ("hmastlocks_reg" , self.slv_out),
            ("hexcls_reg"     , self.slv_out),
            ("transs_req"     , self.slv_out),
            ("unlocks_req"    , self.slv_out),
            ("bursts_terminate", self.slv_out),
            ("hrespm_reg"     , self.slv_in),
            ("hexokaym_reg"   , self.slv_in),
            ("transm_done"    , self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("haddrs_reg"     , self.slv_out,   self.aw - 1, 0),
            ("htranss_reg"    , self.slv_out,   1, 0),
            ("hsizes_reg"     , self.slv_out,   2, 0),
            ("hprots_reg"     , self.slv_out,   6, 0),
            ("hbursts_reg"    , self.slv_out,   2, 0),
            ("hwdatas_reg"    , self.slv_out,   self.dw - 1, 0),
            ("hmasters_reg"   , self.slv_out,   self.mw - 1, 0),
            ("hausers_reg"    , self.slv_out,   self.uw - 1, 0),
            ("hwusers_reg"    , self.slv_out,   self.uw - 1, 0),
            ("hrdatam_reg"    , self.slv_in,    self.dw - 1, 0),
            ("hruserm_reg"    , self.slv_in,    self.uw - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)

class internal_sie200_ahb5_to_ahb5_sync_down_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_to_ahb5_sync_down_if, self).__init__(master)

        self.name = "ahb5toahb5syncdownInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"
        self.mwidth = "$MASTER_WIDTH"
        self.uwidth = "$USER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)
        self.mw = int(self.mwidth, 0)
        self.uw = int(self.uwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_to_ahb5_sync_down_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.uwidth = base.SubstituteParam(self.uwidth, parameters)

        self.SetSize()

        scalarPorts = [
            ("hnonsecs_reg"   , self.slv_out),
            ("hwrites_reg"    , self.slv_out),
            ("hmastlocks_reg" , self.slv_out),
            ("hexcls_reg"     , self.slv_out),
            ("hsels_i"        , self.slv_out),
            ("transs_req"     , self.slv_out),
            ("unlocks_req"    , self.slv_out),
            ("transs_hold"    , self.slv_out),
            ("hrespm_reg"     , self.slv_in),
            ("hexokaym_reg"   , self.slv_in),
            ("transm_done"    , self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("haddrs_reg"     , self.slv_out,   self.aw - 1, 0),
            ("htranss_reg"    , self.slv_out,   1, 0),
            ("hsizes_reg"     , self.slv_out,   2, 0),
            ("hprots_reg"     , self.slv_out,   6, 0),
            ("hbursts_reg"    , self.slv_out,   2, 0),
            ("haddrs_i"       , self.slv_out,   self.aw - 1, 0),
            ("htranss_i"      , self.slv_out,   1, 0),
            ("hwdatas_i"      , self.slv_out,   self.dw - 1, 0),
            ("hwusers_i"      , self.slv_out,   self.uw - 1, 0),
            ("hmasters_reg"   , self.slv_out,   self.mw - 1, 0),
            ("hausers_reg"    , self.slv_out,   self.uw - 1, 0),
            ("hrdatam_reg"    , self.slv_in,    self.dw - 1, 0),
            ("hruserm_reg"    , self.slv_in,    self.uw - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)


class internal_sie200_ahb5_to_ahb5_apb_async_if(internal_sie200_acg_core_if):
    def __init__(self, master):
        super(internal_sie200_ahb5_to_ahb5_apb_async_if, self).__init__(master)

        self.name = "ahb5toahb5apbasyncInternal_" + self.if_name + "_0"

        self.awidth = "$ADDR_WIDTH"
        self.dwidth = "$DATA_WIDTH"
        self.mwidth = "$MASTER_WIDTH"
        self.uwidth = "$USER_WIDTH"

    def SetSize(self):
        self.aw = int(self.awidth, 0)
        self.dw = int(self.dwidth, 0)
        self.mw = int(self.mwidth, 0)
        self.uw = int(self.uwidth, 0)

    def Configure(self, parameters):
        super(internal_sie200_ahb5_to_ahb5_apb_async_if, self).Configure(parameters)
        self.awidth = base.SubstituteParam(self.awidth, parameters)
        self.dwidth = base.SubstituteParam(self.dwidth, parameters)
        self.mwidth = base.SubstituteParam(self.mwidth, parameters)
        self.uwidth = base.SubstituteParam(self.uwidth, parameters)

        self.SetSize()

        scalarPorts = [
            ("reg_hnonsec_s"    , self.slv_out),
            ("reg_hwrite_s"     , self.slv_out),
            ("reg_hmastlock_s"  , self.slv_out),
            ("reg_hexcl_s"      , self.slv_out),
            ("reg_hsel_apb_s"   , self.slv_out),
            ("s_semaphore"      , self.slv_out),
            ("s_mask"           , self.slv_out),
            ("q_hmastlock_s"    , self.slv_out),
            ("reg_unlock_s"     , self.slv_out),
            ("comb_hresp_m"     , self.slv_in),
            ("comb_hexokay_m"   , self.slv_in),
            ("m_semaphore"      , self.slv_in),
            ("m_mask"           , self.slv_in)
        ]
        self.scalarPorts.extend(scalarPorts)

        vectorPorts = [
            ("reg_haddr_s"      , self.slv_out,   self.aw - 1, 0),
            ("reg_hsize_s"      , self.slv_out,   2, 0),
            ("reg_hprot_s"      , self.slv_out,   6, 0),
            ("reg_hwdata_s"     , self.slv_out,   self.dw - 1, 0),
            ("reg_hwuser_s"     , self.slv_out,   self.uw - 1, 0),
            ("reg_hmaster_s"    , self.slv_out,   self.mw - 1, 0),
            ("reg_hauser_s"     , self.slv_out,   self.uw - 1, 0),
            ("comb_hrdata_m"    , self.slv_in,    self.dw - 1, 0),
            ("comb_hruser_m"    , self.slv_in,    self.uw - 1, 0)
        ]
        self.vectorPorts.extend(vectorPorts)

        if ("Master" in self.name) :
            self.addressSpace = "0x%X" % (1 << self.aw)

##
# \class    Component
# \brief    Bridge Component base class
#
class BridgeComponent(base.Component):
    def __init__(self):
        super(BridgeComponent,self).__init__()

        parameter = base.Parameter("ADDR_WIDTH")
        parameter.description = "Address Bus Width"
        parameter.value = "32"
        parameter.minimum = "10"
        parameter.maximum = "32"
        self.parameters.append(parameter)

        parameter = base.Parameter("DATA_WIDTH")
        parameter.description = "Data Bus Width"
        parameter.value = "32"
        parameter.minimum = "32"
        parameter.maximum = "128"
        parameter.enumerations = ["32","64","128"]
        self.parameters.append(parameter)

        parameter = base.Parameter("MASTER_WIDTH")
        parameter.description = "Master Bus Width"
        parameter.value = "4"
        parameter.minimum = "1"
        parameter.maximum = "15"
        self.parameters.append(parameter)

        parameter = base.Parameter("USER_WIDTH")
        parameter.description = "User Extension Signal Width"
        parameter.value = "1"
        parameter.minimum = "1"
        parameter.maximum = "256"
        self.parameters.append(parameter)


class AcgBaseComponent(BridgeComponent):
    def __init__(self, us_clk_name="hclk"):
        super(AcgBaseComponent,self).__init__()

        parameter = base.Parameter("EXT_GATE_SYNC")
        parameter.description = "External Gating Request signal is synchronous"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_and.v"),
            os.path.join("..","..","models","cells","generic","sie200_or.v"),
            os.path.join("..","..","models","cells","generic","sie200_xor.v"),
            os.path.join("..","..","models","cells","generic","sie200_flop.v"),
            os.path.join("..","..","models","cells","generic","sie200_sync.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_launch.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_fsm.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_ds.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_ds_fsm.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core_m.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core_s.v")
        ]

        self.files.extend(files)

        self.vc_files.append(os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core.vc"))

        interfaces = [
            dyncfgif("cfg_gate_resp",us_clk_name),
            handshakeif("ext_gate")
        ]
        self.interfaces.extend(interfaces)

class AcgSlaveComponent(BridgeComponent):
    def __init__(self, us_clk_name="hclk_s"):
        super(AcgSlaveComponent,self).__init__()

        self.top_module = 0

        parameter = base.Parameter("QS_CLOCK_EN")
        parameter.description = "Upstream (Slave) side Q-channel is present for clock."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QM_CLOCK_EN")
        parameter.description = "Downstream (Master) side Q-channel is present for clock."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QS_POWER_EN")
        parameter.description = "Power Q-channel is present."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QS_SYNC")
        parameter.description = "Upstream (Slave) side Q-channel signals are synchronous to the upstream clock."
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("EXT_GATE_SYNC")
        parameter.description = "External Gating Request signal is synchronous"
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_and.v"),
            os.path.join("..","..","models","cells","generic","sie200_or.v"),
            os.path.join("..","..","models","cells","generic","sie200_xor.v"),
            os.path.join("..","..","models","cells","generic","sie200_flop.v"),
            os.path.join("..","..","models","cells","generic","sie200_sync.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_launch.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_fsm.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core_s.v")
        ]

        self.files.extend(files)

        us_clk_prefix = us_clk_name.split("_")
        interfaces = [
            dyncfgif("cfg_gate_resp",us_clk_name),
            handshakeif("ext_gate"),
            sie200_qchanif(us_clk_prefix[0], "_s", us_clk_name),
            sie200_qchanif("pwr",  "_s", us_clk_name)
        ]
        self.interfaces.extend(interfaces)

class AcgMasterComponent(BridgeComponent):
    def __init__(self, ds_clk_name="hclk_m"):
        super(AcgMasterComponent,self).__init__()

        self.top_module = 0

        parameter = base.Parameter("QM_CLOCK_EN")
        parameter.description = "Downstream (Master) side Q-channel is present for clock."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QS_POWER_EN")
        parameter.description = "Power Q-channel is present."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QM_SYNC")
        parameter.description = "Downstream (Master) side Q-channel signals are synchronous to the downstream clock."
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        files = [
            os.path.join("..","..","models","cells","generic","sie200_and.v"),
            os.path.join("..","..","models","cells","generic","sie200_or.v"),
            os.path.join("..","..","models","cells","generic","sie200_xor.v"),
            os.path.join("..","..","models","cells","generic","sie200_flop.v"),
            os.path.join("..","..","models","cells","generic","sie200_sync.v"),
            os.path.join("..","..","shared","verilog","sie200_cdc","verilog","sie200_launch.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_ds.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_lpislave_ds_fsm.v"),
            os.path.join("..","..","shared","verilog","sie200_ahb5_access_ctrl_core","verilog","sie200_ahb5_access_ctrl_core_m.v")
        ]
        self.files.extend(files)

        ds_clk_prefix = ds_clk_name.split("_")

        interfaces = [
            sie200_qchanif(ds_clk_prefix[0], "_m", ds_clk_name),
        ]
        self.interfaces.extend(interfaces)


class AcgComponent(AcgBaseComponent):
    def __init__(self, us_clk_name="hclk_s", ds_clk_name="hclk_m"):
        super(AcgComponent,self).__init__(us_clk_name)

        self.gen_bridge_halves = 1

        parameter = base.Parameter("QS_CLOCK_EN")
        parameter.description = "Upstream (Slave) side Q-channel is present for clock."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QM_CLOCK_EN")
        parameter.description = "Downstream (Master) side Q-channel is present for clock."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QS_POWER_EN")
        parameter.description = "Power Q-channel is present."
        parameter.value = "1"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QS_SYNC")
        parameter.description = "Upstream (Slave) side Q-channel signals are synchronous to the upstream clock."
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        parameter = base.Parameter("QM_SYNC")
        parameter.description = "Downstream (Master) side Q-channel signals are synchronous to the downstream clock."
        parameter.value = "0"
        parameter.minimum = "0"
        parameter.maximum = "1"
        parameter.enumerations = ["0", "1"]
        self.parameters.append(parameter)

        us_clk_prefix = us_clk_name.split("_")
        ds_clk_prefix = ds_clk_name.split("_")
        interfaces = [
            sie200_qchanif(us_clk_prefix[0], "_s", us_clk_name),
            sie200_qchanif(ds_clk_prefix[0], "_m", ds_clk_name),
            sie200_qchanif("pwr",  "_s", us_clk_name)
        ]
        self.interfaces.extend(interfaces)
