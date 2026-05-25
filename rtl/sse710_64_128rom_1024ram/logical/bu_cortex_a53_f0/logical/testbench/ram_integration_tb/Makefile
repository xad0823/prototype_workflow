#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
#            (C) COPYRIGHT 2013-2014 ARM Limited.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#      SVN Information
#
#      Checked In          : $Date: 2012-06-22 08:55:17 +0100 (Wed, 22 Jun 2012) $
#
#      Revision            : $Revision: 176036 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------
.PHONY: mti vcs ius clean

#####################################
# MTI                               #
#####################################
mti: tb_wrapper
	vlib work
	vlog -f CORTEXA53_RAMtestbench.vc ../../testbench/ram_integration_tb/verilog/CORTEXA53_RAMtestbench.v
	vsim -do "run -a; quit -f" -c CORTEXA53_RAMtestbench +notimingchecks +nospecify

#####################################
# VCS                               #
#####################################
vcs: tb_wrapper
	vcs -R -O4 -debug -noIncrComp +vcs+lic+wait +verilog2001ext+.v -f CORTEXA53_RAMtestbench.vc ../../testbench/ram_integration_tb/verilog/CORTEXA53_RAMtestbench.v +notimingcheck +nospecify

#####################################
# IUS                               #
#####################################
ius: tb_wrapper
	irun -licqueue -notimingchecks -nospecify -f CORTEXA53_RAMtestbench.vc ../../testbench/ram_integration_tb/verilog/CORTEXA53_RAMtestbench.v

#####################################
# CLEAN                             #
#####################################
clean:
	@echo "Cleaning RAMtestbench ....."
	@/bin/rm -rf work* transcript vsim*
	@/bin/rm -rf simv* vcs* csrc .vcsmx_rebuild inter.vpd DVEfiles verilog/CORTEXA53_RAMtestbench.v.bak ucli.key .restartSimSession.tcl.old
	@/bin/rm -rf nc* INCA_libs RUN_NC cds.lib hdl.var irun*

tb_wrapper : 
	@echo "Generating RAMtestbench wrapper....."
	perl ./tools/GenerateRamTB.pl


