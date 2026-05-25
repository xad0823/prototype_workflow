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
#      Checked In          : $Date: 2014-07-25 09:52:11 +0100 (Fri, 25 Jul 2014) $
#
#      Revision            : $Revision: 285788 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------

# Include user configuration file
include ../make.cfg


################################################################################
# Toolchains
################################################################################

# Toolchain names
ifeq ($(findstring +bigend, $(PLUSARGS) ), +bigend)
GCC_TOOLCHAIN_AARCH32 := armeb-none-eabi
GCC_TOOLCHAIN_AARCH64 := aarch64_be-none-elf
else 
GCC_TOOLCHAIN_AARCH32 := arm-none-eabi
GCC_TOOLCHAIN_AARCH64 := aarch64-none-elf
endif

# AArch32 toolchain executables
AS32      := $(GCC_TOOLCHAIN_AARCH32)-as
GCC32     := $(GCC_TOOLCHAIN_AARCH32)-gcc
LD32      := $(GCC_TOOLCHAIN_AARCH32)-ld
OBJCOPY32 := $(GCC_TOOLCHAIN_AARCH32)-objcopy

# AArch64 toolchain executables
AS64      := $(GCC_TOOLCHAIN_AARCH64)-as
GCC64     := $(GCC_TOOLCHAIN_AARCH64)-gcc
LD64      := $(GCC_TOOLCHAIN_AARCH64)-ld
OBJCOPY64 := $(GCC_TOOLCHAIN_AARCH64)-objcopy


################################################################################
# Processor options
################################################################################

# CPU and architecture
CPU  = cortex-a53
ARCH = armv8-a

# FPU types
FPU_NONE      :=
FPU_V8        := -mfpu=neon-fp-armv8
FPU_V8_CRYPTO := -mfpu=crypto-neon-fp-armv8

# Active FPU, can be overridden by tests
FPU = $(FPU_V8)


################################################################################
# Commands and command options
################################################################################

# Assembler setup
ASM32            = $(AS32)
ASM64            = $(AS64)
ifeq ($(findstring +bigend, $(PLUSARGS) ), +bigend)
ASM_OPTS_AARCH32 = -march=$(ARCH) $(FPU) --defsym BIGEND=1 -mbig-endian
ASM_OPTS_AARCH64 = -march=$(ARCH) --defsym BIGEND=1 -mbig-endian
else
ASM_OPTS_AARCH32 = -march=$(ARCH) $(FPU)
ASM_OPTS_AARCH64 = -march=$(ARCH)
endif

# C compiler setup
CC32             = $(GCC32)
CC64             = $(GCC64)
ifeq ($(findstring +bigend, $(PLUSARGS) ), +bigend)
CC_OPTS_AARCH32  = -march=$(ARCH) -mtune=$(CPU) $(FPU) -c -DGCC -falign-functions=16 -fno-common -falign-jumps=8 -falign-loops=8 -fomit-frame-pointer -funroll-loops -g -mbig-endian
CC_OPTS_AARCH64  = -march=$(ARCH) -mtune=$(CPU)        -c -DGCC -falign-functions=16 -falign-jumps=8 -falign-loops=8 -fomit-frame-pointer -funroll-loops -g -mbig-endian
else
CC_OPTS_AARCH32  = -march=$(ARCH) -mtune=$(CPU) $(FPU) -c -DGCC -falign-functions=16 -fno-common -falign-jumps=8 -falign-loops=8 -fomit-frame-pointer -funroll-loops -g
CC_OPTS_AARCH64  = -march=$(ARCH) -mtune=$(CPU)        -c -DGCC -falign-functions=16 -falign-jumps=8 -falign-loops=8 -fomit-frame-pointer -funroll-loops -g
endif

# Linker setup
LINK32           = $(LD32)
LINK64           = $(LD64)

ifeq ($(findstring +bigend, $(PLUSARGS) ), +bigend)
LINK_OPTS_32     = -EB --be8
LINK_OPTS_64     = -EB
else
LINK_OPTS_32     = 
LINK_OPTS_64     = 
endif  

LINK_OPTS_NOBOOT_AARCH32 = $(LINK_OPTS_32)               -T link_noboot.ld
LINK_OPTS_NOBOOT_AARCH64 = $(LINK_OPTS_64)               -T link_noboot.ld
LINK_OPTS_ASM_AARCH32    = $(LINK_OPTS_32)               -T link_asm_aarch32.ld  
LINK_OPTS_ASM_AARCH64    = $(LINK_OPTS_64)               -T link_asm_aarch64.ld

ifeq ($(findstring +bigend, $(PLUSARGS) ), +bigend)
LINK_OPTS_CSRC_AARCH32   = $(LINK_OPTS_32:-%=-Wl,-%) -Wl,-T link_csrc_aarch32.ld  -mbig-endian
LINK_OPTS_CSRC_AARCH64   = $(LINK_OPTS_64:-%=-Wl,-%) -Wl,-T link_csrc_aarch64.ld  -mbig-endian
else
LINK_OPTS_CSRC_AARCH32   = $(LINK_OPTS_32:-%=-Wl,-%) -Wl,-T link_csrc_aarch32.ld
LINK_OPTS_CSRC_AARCH64   = $(LINK_OPTS_64:-%=-Wl,-%) -Wl,-T link_csrc_aarch64.ld
endif

# Image file generation
ELF2BIN32 := $(OBJCOPY32)
ELF2BIN64 := $(OBJCOPY64)
BIN2HEX   := ../../shared/tools/bin/bin2vhx.pl


################################################################################
# Makefile variables
################################################################################

# Names of defined tests for AArch32 and AArch64
aarch32_tests = hello_world arm_ok wfi config_check max_power max_power_L2 cache_miss dhrystone
aarch64_tests = hello_world arm_ok wfi config_check max_power max_power_L2 cache_miss dhrystone

# Add in opional FPU and crypto tests where required
ifeq ($(strip $(CRYPTO_TESTS)), yes)
  aarch32_tests += crypto
  aarch64_tests += crypto
endif
ifeq ($(strip $(FPU_TESTS)), yes)
  aarch32_tests += saxpy
  aarch64_tests += saxpy
endif

# Directories for shared code
aarch32_shared := aarch32/shared
aarch64_shared := aarch64/shared
common_shared  := common/shared

# Shared sources and objects
aarch32_bootcode := $(wildcard $(aarch32_shared)/*.s)
aarch64_bootcode := $(wildcard $(aarch64_shared)/*.s)
aarch32_bootobj  := $(patsubst %.s,%.o,$(aarch32_bootcode))
aarch64_bootobj  := $(patsubst %.s,%.o,$(aarch64_bootcode))

# Each test has its own Makefile for compiling and linking
sub_makefiles = $(foreach test, $(aarch32_tests), aarch32/$(test)/Makefile.inc) \
                $(foreach test, $(aarch64_tests), aarch64/$(test)/Makefile.inc) \

# List of test directories and basenames for linked ELFs, binaries and objects.
# The basename for each test is <arch>/<test>/<test>
testdirs32  = $(foreach test, $(aarch32_tests), aarch32/$(test))
testdirs64  = $(foreach test, $(aarch64_tests), aarch64/$(test))
basenames32 = $(foreach test, $(aarch32_tests), aarch32/$(test)/$(test))
basenames64 = $(foreach test, $(aarch64_tests), aarch64/$(test)/$(test))

# Names of elfs, binaries and hex files
elfs32 = $(addsuffix .elf, $(basenames32))
elfs64 = $(addsuffix .elf, $(basenames64))
bins32 = $(addsuffix .bin, $(basenames32))
bins64 = $(addsuffix .bin, $(basenames64))
hexes  = $(addsuffix .vhx, $(basenames32) $(basenames64))


################################################################################
# Default target: make all
################################################################################

.PHONY: all
all: $(hexes)


################################################################################
# Include sub-Makefiles
#
#   Each sub-Makefile defines how to compile and link the test
################################################################################

include $(sub_makefiles)


################################################################################
# Rules for shared sources
################################################################################

# AArch32 shared ASM
$(aarch32_bootobj): %.o: %.s
	@echo " [ASM ] $<"
	@$(ASM32) $(ASM_OPTS_AARCH32) -I$(common_shared) $< -o $@

# AArch64 shared ASM
$(aarch64_bootobj): %.o: %.s
	@echo " [ASM ] $<"
	@$(ASM64) $(ASM_OPTS_AARCH64) -I$(common_shared) $< -o $@


################################################################################
# Create binary and hex images
################################################################################

$(bins32): %.bin: %.elf
	@echo " [BIN ] $<"
	@$(ELF2BIN32) -O binary $< $@

$(bins64): %.bin: %.elf
	@echo " [BIN ] $<"
	@$(ELF2BIN64) -O binary $< $@

$(hexes): %.vhx: %.bin
	@echo " [HEX ] $<"
	@$(BIN2HEX) --width=128 $< $@


################################################################################
# Symbolic test names
################################################################################

.PHONY: $(testdirs32) $(testdirs64)
$(foreach test, $(aarch32_tests), $(eval aarch32/$(test): aarch32/$(test)/$(test).vhx))
$(foreach test, $(aarch64_tests), $(eval aarch64/$(test): aarch64/$(test)/$(test).vhx))


################################################################################
# Clean and tidy
#
#   clean: removes everything that can be rebuilt
#   tidy:  preserves ELF and memory initialisation files, cleans everything else
################################################################################

.PHONY: tidy
tidy:
	@rm -f $(aarch32_bootobj)
	@rm -f $(aarch64_bootobj)
	@rm -f $(aarch64_shared_c_obj)
	@rm -f $(foreach test, $(aarch32_tests), aarch32/$(test)/*.o)
	@rm -f $(foreach test, $(aarch64_tests), aarch64/$(test)/*.o)
	@rm -f $(bins32) $(bins64)

.PHONY: clean
clean: tidy
	@rm -f $(elfs32) $(elfs64)
	@rm -f $(hexes)

