#!/usr/bin/env perl
#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
#            (C) COPYRIGHT 2012-2014 ARM Limited.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#      SVN Information
#
#      Checked In          : $Date: 2013-01-21 13:29:21 +0000 (Mon, 21 Jan 2013) $
#
#      Revision            : $Revision: 234282 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# CONTENTS
# ========
#  47 . About this script
#  52 .   - Generic Setup
#  65 .   - Specific Setup
#  72 . Prototype
#  82 . Main
#  85 .   - Usage Checks
#  94 .   - Read Input File
#  98 .   - Check Config
# 104 . Subroutines
# 108 .   - check config
# 179 .   - read_input_file
# 206 .   - usage_msg
# 223 .   - print_start_msg
# 229 .   - get_flags
# 242 .   - info_msg
# 248 .   - error_msg
#----------------------------------------------------------------------------

# INDEX: About this script
# =====
# This scripts checks and prints out the configured RTL Parameters versus the configuration
# parameters.

# INDEX:   - Generic Setup
# =====
use File::Basename;
use strict;
use Getopt::Long;
use FindBin;

my $script_name  = basename($0);
my %options       = ();

$options{config} = "$FindBin::Bin/../../../config/CORTEXA53.cfg";
$options{input} = "$FindBin::Bin/../../../cortexa53/verilog/CORTEXA53.v";

# INDEX:   - Specific Setup
# =====
my %parameter;
my %localparams;
my $print_config = 1;
my ($param_name, $param_config, $param_verilog, $param_check, $param_end);

# INDEX: Prototype
# =====
sub usage_msg;
sub info_msg;
sub error_msg;
sub get_flags;
sub print_start_msg;
sub check_config;
sub read_input_file;

# INDEX: Main
# =====

# INDEX:   - Usage Checks
# =====
get_flags;

# INDEX:   - Read Config
# =====
unless(-e $options{config}) { error_msg "Cannot open file $options{config}" }
require $options{config};

# INDEX:   - Read Input File
# =====
read_input_file;

# INDEX:   - Check Config
# =====
check_config;

exit 0;

# INDEX: Subroutines
# =====

# INDEX:   - check_config
# =====
sub check_config {
 
  foreach my $parameter (sort keys %localparams){
    
    #Local variables
    my $result = 'NOT MATCHED';
    my $config = $PARAM::parameter{$parameter};
    
    if ($parameter eq 'ACE' or $parameter eq 'ACP' or 
        $parameter eq 'CPU_CACHE_PROTECTION' or $parameter eq 'CRYPTO' or
	$parameter eq 'L2_CACHE' or $parameter eq 'NEON_FP' or
	$parameter eq 'SCU_CACHE_PROTECTION' or $parameter eq 'LEGACY_V7_DEBUG_MAP'
       ) {
       if ( ($localparams{$parameter} eq '1' and $PARAM::parameter{$parameter} eq 'TRUE') or 
            ($localparams{$parameter} eq '0' and $PARAM::parameter{$parameter} eq 'FALSE') ) {
         $result = 'MATCHED';
       } 
       
       if($parameter eq 'CPU_CACHE_PROTECTION') {
         if ($localparams{CPU_CACHE_PROTECTION} eq '1' and $localparams{SCU_CACHE_PROTECTION} eq '0' and $localparams{L2_CACHE} eq '1') {
	   error_msg "Illegal Configuration as SCU_CACHE_PROTECTION = $localparams{SCU_CACHE_PROTECTION} and CPU_CACHE_PROTECTION = $localparams{CPU_CACHE_PROTECTION}. Refer to Configuration Sign-off guide";
	 } 
       }
    } elsif ($parameter eq 'NUM_CPUS') {
      if ($localparams{$parameter} eq $PARAM::parameter{$parameter} ){
        $result = 'MATCHED';
      } 
    } elsif ($parameter eq 'L1_DCACHE_SIZE' or $parameter eq 'L1_ICACHE_SIZE') {
      if ( ($localparams{$parameter} eq "3'b000" and uc($PARAM::parameter{$parameter}) eq '8KB')  or 
           ($localparams{$parameter} eq "3'b001" and uc($PARAM::parameter{$parameter}) eq '16KB') or
	   ($localparams{$parameter} eq "3'b011" and uc($PARAM::parameter{$parameter}) eq '32KB') or 
           ($localparams{$parameter} eq "3'b111" and uc($PARAM::parameter{$parameter}) eq '64KB') 
	   ) {
         $result = 'MATCHED';
       } 
    } elsif ($parameter eq 'L2_CACHE_SIZE') {
       if ( ($localparams{$parameter} eq "4'b0000" and uc($PARAM::parameter{$parameter}) eq '128KB')  or 
            ($localparams{$parameter} eq "4'b0001" and uc($PARAM::parameter{$parameter}) eq '256KB')  or
	    ($localparams{$parameter} eq "4'b0011" and uc($PARAM::parameter{$parameter}) eq '512KB')  or 
            ($localparams{$parameter} eq "4'b0111" and uc($PARAM::parameter{$parameter}) eq '1024KB') or
	    ($localparams{$parameter} eq "4'b1111" and uc($PARAM::parameter{$parameter}) eq '2048KB')
	   ) {
         $result = 'MATCHED';
       } 
    } elsif ($parameter eq 'L2_INPUT_LATENCY') {
       if ( ($localparams{$parameter} eq "1'b0" and $PARAM::parameter{$parameter} eq '1') or 
            ($localparams{$parameter} eq "1'b1" and $PARAM::parameter{$parameter} eq '2') ) {
         $result = 'MATCHED';
       }      
    } elsif ($parameter eq 'L2_OUTPUT_LATENCY') {
       if ( ($localparams{$parameter} eq "1'b0" and $PARAM::parameter{$parameter} eq '2') or 
            ($localparams{$parameter} eq "1'b1" and $PARAM::parameter{$parameter} eq '3') ) {
         $result = 'MATCHED';
       }    
    } else {
      $result = 'ERROR';
    }
    if ($print_config == 1) {
      #print "$param = $localparams{$param}\n";
      $param_name     = "$parameter";
      $param_config   = "| $config";
      $param_verilog  = "| $localparams{$parameter}";
      $param_check    = "| $result";
      $param_end      = "|";
      write STDOUT;
    }
    
    info_msg "Files Checked : $options{input} and $options{config}" if($result eq 'NOT MATCHED' or $result eq 'ERROR');
    error_msg "Configuration mismatch in parameter: $parameter. Please contact Support-Cores Team" if($result eq 'NOT MATCHED'); 
    error_msg "Parameter not found: $parameter. Please contact Support-Cores Team" if($result eq 'ERROR');
  
  } #Foreach parameter 
  
  info_msg "CHECKING COMPLETED : NO MISMATCHES FOUND";
			    
}

# INDEX:   - read_input_file
# =====
sub read_input_file {
  
  #Local Variable
  my $line;
  
  #File name from the hash reference  
  # open files
  open(IN,"$options{input}") or error_msg "Cannot open the Top level file: $options{input}";
    
  while (<IN>) {
   
    $line = $_; chomp($line);

    if ($line =~ /^\s+localparam\s+(\[\s*?\d+:\s*?\d+\])?\s*?(\w+)\s+=\s+(\d+'b)?(\w+)[;]?$/) {
      my $key = $2;
      my $val = "$3$4";
      $localparams{$key} = $val;
    }
  }
  
  close(IN);
  

}

# INDEX:   - usage_msg
# =====
sub usage_msg {
  print STDERR << "EOF";

    Modes:
      $script_name [-config <name>] [-input <name>]

    Options:
      -config  <name> Configuration file. Default $options{config}
      -input   <name> Unconfigured verilog. Default $options{input}
      -help    Help (prints this usage message)

EOF
  exit;
}

# INDEX:   - print_start_msg
# =====
sub print_start_msg {
  info_msg "Start Checking the configuration in $options{input} using $options{config}";
}

# INDEX:   - get_flags
# =====
sub get_flags {
  if (!GetOptions("help"     => \$options{help},
		  "verbose"  => \$options{verbose},
                  "config=s" => \$options{config},
		  "input=s"  => \$options{input})  || $options{help}) {
    usage_msg;
  }
   
  print_start_msg if ($options{verbose});
}

# INDEX:   - info_msg
# =====
sub info_msg {
  print STDOUT "\n-I- $script_name: @_\n";
}

# INDEX:   - error_msg
# =====
sub error_msg {
  print STDOUT "\n-E- $script_name: (error) @_\n\n";
  exit 1;
}

format STDOUT_TOP =

      Parameter      | Config  | Verilog | Result      |
---------------------+---------+---------+-------------+
.

format STDOUT =
@<<<<<<<<<<<<<<<<<<< @<<<<<<<< @<<<<<<<< @<<<<<<<<<<<< @
$param_name, $param_config, $param_verilog, $param_check, $param_end
.
