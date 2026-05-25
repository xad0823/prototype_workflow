#!/usr/bin/env perl
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
#      Checked In          : $Date: 2012-08-17 08:30:58 +0100 (Fri, 17 Aug 2012) $
#
#      Revision            : $Revision: 219201 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------

use strict;
use Getopt::Long;
use Cwd;
use Data::Dumper;
use File::Basename;

#For sub-functions
use lib "./tools";
use RamIntegration qw(parsing_for_localparams generating_ram_harness finding_top_level_file);

#Declare Sub-routines
sub making_cfg_hash();

#Cfg file for testbench
my $tb_cfg_file = "./CORTEXA53_RAMtestbench.vc";

#Parse the file to get all the config
my $cfg_hash_ref = making_cfg_hash();

#Parsing Localparams
my $localparams_hash_ref = parsing_for_localparams($cfg_hash_ref);

#Generating RAM-TB Top level
generating_ram_harness($cfg_hash_ref, $localparams_hash_ref);

sub making_cfg_hash( ) {

  #Local Variable
  my %cfg_hash;
  my $debug = 0;

  #Top level file and module name parsed from .vc file
  my $cfg_hash_ref = finding_top_level_file($tb_cfg_file);

  %cfg_hash = %{$cfg_hash_ref};

  $cfg_hash{tb_dir}              =  "./verilog/";
  $cfg_hash{tb_harness}          =  "CORTEXA53_RAMtestbench";
  $cfg_hash{in_harness_to_1}     =  "nIRQ,nFIQ,nVIRQ,nVFIQ,PCLKENDBG,nMBISTRESET,ACLKENM";
  $cfg_hash{in_harness_to_other} =  "CLKIN:CLKIN,IRQS:IRQS,nCORERESET:nCORERESET,nCPUPORESET:nCORERESET,nL2RESET:nL2RESET";

  if ($debug == 1) {
    foreach my $z (keys %cfg_hash){
      print "Debug parsing_ram_cfg: CFG hash keys = $z, Val = $cfg_hash{$z}\n";
    }
  }
  return \%cfg_hash;
}


1;
