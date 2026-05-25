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
#      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
#
#      Revision            : $Revision: 283836 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------

# Include user options from separate file
include make.cfg

# Tools
TB_GENERATOR  := ../shared/tools/bin/execution_tb_generator.pl

# Files
rtl_config    := ../../config/CORTEXA53.cfg
tb_unrendered := verilog/cortexa53_execution_tb_unconfigured.v
tb_rendered   := verilog/cortexa53_execution_tb.v
vcfiles       := execution_tb.vc

# Options (modified depending on configuration).  Note that where PLUSARGS and
# BUILDOPTS have been specified on the command line these assignments will
# not take place because they don't use 'override'.  Setting TEST_ARCH and
# TEST_CASE is not supported on the command line, so they use 'override'.
override TEST_ARCH :=
override TEST_CASE :=
BUILDOPTS :=
PLUSARGS  :=

################################################################################
# Option passing and checking
################################################################################

# If the TESTNAME variable is used is must be of the form "<arch>/<test>" where
# <arch> is either aarch32 or aarch64, and <test> is the name of a test that is
# available for that architecture.
ifdef TESTNAME
  # Use override to ensure the assignments don't have lower priority than
  # the default assignments above
  override TEST_ARCH = $(patsubst %/,%,$(dir $(TESTNAME)))
  override TEST_CASE = $(notdir $(TESTNAME))

  # Check for valid architecture
  ifneq ($(TEST_ARCH), aarch32)
  ifneq ($(TEST_ARCH), aarch64)
    $(error "TESTNAME must be aarch32/<test> or aarch64/<test>")
  endif
  endif

  # Check that test is defined (the wildcard function returns an empty
  # string if it does not)
  ifeq ($(wildcard tests/$(TEST_ARCH)/$(TEST_CASE)),)
    $(error "The test $(TESTNAME) does not exist")
  endif

  # Check that the test has been built
  ifeq ($(wildcard tests/$(TEST_ARCH)/$(TEST_CASE)/$(TEST_CASE).vhx),)
    $(error "The test $(TESTNAME) has not been built. Run 'make tests'.")
  endif

  # If the testcase is an AArch64 test we automatically add the plusarg to
  # start in AArch64.  Use 'override' so that command-line arguments are
  # honored but don't prevent internal modification.
  ifeq ($(TEST_ARCH), aarch64)
    override PLUSARGS += +arch64
  endif
endif

# If the INITFILE variable is set then always use that as the name of the
# memory initialization filename.  If it isn't, but the TESTNAME variable is
# set, then contruct INITFILE using the name of the given test.
ifndef INITFILE
ifdef TESTNAME
INITFILE := tests/$(TEST_ARCH)/$(TEST_CASE)/$(TEST_CASE).vhx
endif
endif

ifdef INITFILE
MEM_INIT = +mem_init=$(INITFILE)
else
MEM_INIT =
endif

# If tarmac is enabled define the shared object location, depending on whether
# the testbench is configured for 32-bit or 64-bit simulation, and add the
# necessary options to the environment.
ifeq ($(strip $(TARMAC)), yes)
  ifeq ($(strip $(SIM_64BIT)), yes)
    tarmac_so := ../../ca53univent/build_x86_64/lib/ca53_tarmac_dpi.so
  else
    tarmac_so := ../../ca53univent/build_x86_32/lib/ca53_tarmac_dpi.so
  endif

  # Always add the tarmac VC file when tarmac is selected
  override vcfiles += execution_tb_tarmac.vc

  # Export the tarmac location so that sub-processes can find it
  export CA53_TARMAC_EXECUTABLE = ../../ca53univent/build_x86_32/bin/ca53_tarmac_decode --plain

  # Set plusarg to enable tarmac
  override PLUSARGS += +ca53_tarmac_enable
endif

# If OVLs are enabled then we add the OVL defines to BUILDOPTS.  Use 'override'
# so that the assignment still works if BUILDOPTS were specified on the
# command-line.
ifeq ($(strip $(OVL_ASSERTIONS)), yes)
  override BUILDOPTS += +define+ARM_ASSERT_ON+ASSERT_ON+OVL_ASSERT_ON +define+OVL_VERILOG 
endif

# Construct sequence of '-f <vcfile>' for every VC file used. This is a
# recursively-expanded variable so that any additional VC files will be
# represented when the variable is used.
VC_OPTS = $(patsubst %,-f %,$(vcfiles))


################################################################################
# Simulator-specific setup
#
#   Construct simulator compile-time and run-time arguments based on the
#   configuration options
################################################################################

# Basic options
MTI_COMPILE_OPTS := -quiet +acc=blnr -noincr
MTI_RUN_OPTS     := -quiet -do "run -a; quit -f" -c cortexa53_execution_tb
VCS_COMPILE_OPTS := +v2k -noIncrComp -q
VCS_RUN_OPTS     :=
IUS_COMPILE_OPTS := -elaborate -q
IUS_RUN_OPTS     := -R

# Tarmac options
ifeq ($(strip $(TARMAC)), yes)
  MTI_RUN_OPTS     += -sv_lib $(basename $(tarmac_so))
  VCS_COMPILE_OPTS += -sverilog $(tarmac_so)
  IUS_COMPILE_OPTS += -sv $(tarmac_so)
endif

# 64-bit simulation
ifeq ($(strip $(SIM_64BIT)), yes)
  VCS_COMPILE_OPTS += -full64
  MTI_COMPILE_OPTS += -64
  MTI_RUN_OPTS     += -64
  IUS_COMPILE_OPTS += -64bit
  IUS_RUN_OPTS     += -64bit
endif


################################################################################
# Phony targets
################################################################################

.PHONY: mti_compile mti_run vcs_compile vcs_run ius_compile ius_run tests clean allclean clean_image

################################################################################
# Create testbench
################################################################################

# Render the testbench RTL. The dependency on the parameters file ensures that
# the testbench is re-rendered if the processor configuration changes.
#
# This is the default target if no targets are specified in the make command.
$(tb_rendered): $(tb_unrendered) $(rtl_config)
	@echo " >> Generating testbench"
	@$(TB_GENERATOR) $< $@

################################################################################
# User help menu
################################################################################
help:
	@echo "################################################################### "; \
	echo "This is the top Makefile for CA53 execution testbench"; \
	echo "make or make help shows this extra information"; \
	echo ""; \
	echo "Usage: make target [options]"; \
	echo "target is one of:"; \
	echo "<simulator>_compile       : compile the testbench (simulator can be vcs, mti, ius)"; \
	echo "<simulator>_run           : run the tests (simulator can be vcs, mti, ius)"; \
	echo "tests                     : compile the tests"; \
	echo "clean                     : clean the compiled testbench "; \
	echo "clean_image               : clean the compiled testbench "; \
	echo "allclean                  : clean the compiled testbench and tests and log files"; \
	echo "options can be:"; \
	echo "TESTNAME=<test>           : specify the test name using TEST_ARCH/TEST_CASE eg: TESTNAME=aarch32/arm_ok "; \
	echo "PLUSARGS=<plusargs_list>  : run time options"; \
	echo "                  	support options are +mem_init=<file>, +arch64, +dumpon=<time> +dumpoff=<time>, +bigend"; 

################################################################################
# MTI targets
################################################################################

# Compile
mti_compile: $(tb_rendered)
	@echo " >> Compiling testbench in MTI"
	@vlib work
	@vlog $(VC_OPTS) $(MTI_COMPILE_OPTS) $(BUILDOPTS)

# Run
mti_run:
	@echo " >> Running testbench in MTI"
	@vsim $(MTI_RUN_OPTS) $(MEM_INIT) $(PLUSARGS)


################################################################################
# VCS targets
################################################################################

# Compile
vcs_compile: $(tb_rendered)
	@echo " >> Compiling testbench in VCS"
	@vcs $(VC_OPTS) $(VCS_COMPILE_OPTS) $(BUILDOPTS)

# Run
vcs_run:
	@echo " >> Running testbench in VCS"
	@./simv $(MEM_INIT) $(VCS_RUN_OPTS) $(PLUSARGS)


################################################################################
# IUS targets
################################################################################

# Compile
ius_compile: $(tb_rendered)
	@echo " >> Compiling testbench in IUS"
	@irun $(VC_OPTS) $(IUS_COMPILE_OPTS) $(BUILDOPTS)

#Run
ius_run:
	@echo " >> Running testbench in IUS"
	@irun $(IUS_RUN_OPTS) $(MEM_INIT) $(PLUSARGS)


################################################################################
# Rebuild tests
################################################################################
export  PLUSARGS 
tests:
	@$(MAKE) --no-print-dir -C tests


################################################################################
# Clean
################################################################################

# Clean compiled testbench
clean:
	rm -f $(tb_rendered)
	rm -rf work
	rm -f simv
	rm -rf csrc
	rm -rf simv.daidir
	rm -f ucli.key
	rm -rf INCA_libs

# Clean the tests only
clean_image:
	$(MAKE) --no-print-dir -C tests clean

# Clean compiled testbench plus logs and tests
allclean: clean
	rm -f ca53_tarmac*.log
	rm -f dump.vcd
	$(MAKE) --no-print-dir -C tests clean

