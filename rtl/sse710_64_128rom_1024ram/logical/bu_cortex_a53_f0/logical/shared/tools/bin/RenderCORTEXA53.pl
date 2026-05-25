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
#      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
#
#      Revision            : $Revision: 283836 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# CONTENTS
# ========
#  48 . About this script
#  54 .   - Generic Setup
#  69 .   - Specific Setup
#  75 . Prototype
#  87 . Main
#  90 .   - Usage Checks
#  94 .   - Read Config
# 100 .   - Render
# 106 . Subroutines
# 109 .   - render
# 319 .   - check config
# 370 .   - upf_config
# 510 .   - ipxact_config
# 564 .   - usage_msg
# 586 .   - print_start_msg
# 594 .   - get_flags
# 612 .   - info_msg
# 618 .   - error_msg
#----------------------------------------------------------------------------

# INDEX: About this script
# =====
# This uses a module to select the parameters and it reads an unconfigured
# top level to create configured top level with all the correct IO in place
# based on the parameters. It also declares localparams in the configured file.

# INDEX:   - Generic Setup
# =====
use File::Basename;
use strict;
use Getopt::Long;
use FindBin;

my $script_name  = basename($0);
my %options       = ();

$options{config} = "$FindBin::Bin/../../../config/CORTEXA53.cfg";
$options{input}  = "$FindBin::Bin/../../../cortexa53/verilog/CORTEXA53_unconfigured.v";
$options{output} = "$FindBin::Bin/../../../cortexa53/verilog/CORTEXA53.v";
$options{module} = "CORTEXA53";

# INDEX:   - Specific Setup
# =====
my %parameter;
my %parameter_tf;
my %parameter_cs;

# INDEX: Prototype
# =====
sub usage_msg;
sub info_msg;
sub error_msg;
sub get_flags;
sub print_start_msg;
sub check_config;
sub render;
sub ipxact_config;
sub upf_config($);

# INDEX: Main
# =====

# INDEX:   - Usage Checks
# =====
get_flags;

# INDEX:   - Read Config
# =====
unless(-e $options{config}) { error_msg "Cannot open file $options{config}" }
require $options{config};
check_config;

# INDEX:   - Render
# =====
render;

exit 0;

# INDEX: Subroutines
# =====

# INDEX:   - render
# =====
sub render {
  my $msb = $PARAM::parameter{NUM_CPUS}-1;
  my %config;

  open(IN,"$options{input}") or error_msg "Cannot open $options{input}";
  open(OUT,">$options{output}") or error_msg "Cannot open $options{output}";
  while (<IN>) {
    #
    # Replace module name
    #
    s/(module\s+)CORTEXA53_\w+/$1$options{module}/;
    #
    # Replace CN with CPU_NUMS-1
    #
    s/\[\s?CN/[  $msb/;
    #
    # Take care of signals ending with 0,1,2,3
    #
    if ($_ =~ /CONFIG CPU COUNT START/) {
      $config{count_section} = 1;
      next;
    }
    if ($_ =~ /CONFIG CPU COUNT END/ and $config{count_section}) {
      $config{count_section}  = 0;
      next;
    }
    if ($config{count_section} ) {
      if ($_ =~ /(.*[A-Z]+([0-3]).*)/) {
	print OUT "$1\n" if ($2 <= $msb);
	next;
      }
    }
    #
    # decide what to do with crypto
    #
    if ($_ =~ /CONFIG CRYPTO START/) {
      $config{CRYPTO} = 1;
      next;
    }
    if ($_ =~ /CONFIG CRYPTO END/ and $config{CRYPTO}) {
      $config{CRYPTO} = 0;
      next;
    }
    next if ($config{CRYPTO} and $PARAM::parameter{CRYPTO} eq "FALSE");

    if ($_ =~ /CONFIG NO CRYPTO START/) {
      $config{NOCRYPTO} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO CRYPTO END/ and $config{NOCRYPTO}) {
      $config{NOCRYPTO} = 0;
      next;
    }
    next if ($config{NOCRYPTO} and $PARAM::parameter{CRYPTO} eq "TRUE");
    #
    # decide what to do with ACE
    #
    if ($_ =~ /CONFIG ACE START/) {
      $config{ACE} = 1;
      next;
    }
    if ($_ =~ /CONFIG ACE END/ and $config{ACE}) {
      $config{ACE} = 0;
      next;
    }
    next if ($config{ACE} and $PARAM::parameter{ACE} eq "FALSE");

    if ($_ =~ /CONFIG NO ACE START/) {
      $config{NOACE} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO ACE END/ and $config{NOACE}) {
      $config{NOACE} = 0;
      next;
    }
    next if ($config{NOACE} and $PARAM::parameter{ACE} eq "TRUE");
    #
    # decide what to do with ACP
    #
    if ($_ =~ /CONFIG ACP START/) {
      $config{ACP} = 1;
      next;
    }
    if ($_ =~ /CONFIG ACP END/ and $config{ACP}) {
      $config{ACP} = 0;
      next;
    }
    next if ($config{ACP} and $PARAM::parameter{ACP} eq "FALSE");

    if ($_ =~ /CONFIG NO ACP START/) {
      $config{NOACP} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO ACP END/ and $config{NOACP}) {
      $config{NOACP} = 0;
      next;
    }
    next if ($config{NOACP} and $PARAM::parameter{ACP} eq "TRUE");
    #
    # decide what to do with L2_CACHE
    #
    if ($_ =~ /CONFIG L2_CACHE START/) {
      $config{L2_CACHE} = 1;
      next;
    }
    if ($_ =~ /CONFIG L2_CACHE END/ and $config{L2_CACHE}) {
      $config{L2_CACHE} = 0;
      next;
    }
    next if ($config{L2_CACHE} and $PARAM::parameter{L2_CACHE} eq "FALSE");

    if ($_ =~ /CONFIG NO L2_CACHE START/) {
      $config{NO_L2_CACHE} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO L2_CACHE END/ and $config{NO_L2_CACHE}) {
      $config{NO_L2_CACHE} = 0;
      next;
    }
    next if ($config{NO_L2_CACHE} and $PARAM::parameter{L2_CACHE} eq "TRUE");
    #
    # decide what to do with NEON_FP
    #
    if ($_ =~ /CONFIG NEON_FP START/) {
      $config{NEON_FP} = 1;
      next;
    }
    if ($_ =~ /CONFIG NEON_FP END/ and $config{NEON_FP}) {
      $config{NEON_FP} = 0;
      next;
    }
    next if ($config{NEON_FP} and $PARAM::parameter{NEON_FP} eq "FALSE");

    if ($_ =~ /CONFIG NO NEON_FP START/) {
      $config{NO_NEON_FP} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO NEON_FP END/ and $config{NO_NEON_FP}) {
      $config{NO_NEON_FP} = 0;
      next;
    }
    next if ($config{NO_NEON_FP} and $PARAM::parameter{NEON_FP} eq "TRUE");
    #
    # decide what to do with SCU_CACHE_PROTECTION
    #
    if ($_ =~ /CONFIG SCU-L2 CACHE PROTECTION START/) {
      $config{SCU_CACHE_PROTECTION} = 1;
      next;
    }
    if ($_ =~ /CONFIG SCU-L2 CACHE PROTECTION END/ and $config{SCU_CACHE_PROTECTION}) {
      $config{SCU_CACHE_PROTECTION} = 0;
      next;
    }
    next if ($config{SCU_CACHE_PROTECTION} and $PARAM::parameter{SCU_CACHE_PROTECTION} eq "FALSE");

    #
    # decide what to do with CPU_CACHE_PROTECTION
    #
    if ($_ =~ /CONFIG CPU OR SCU-L2 CACHE PROTECTION START/) {
      $config{CACHE_PROTECTION} = 1;
      next;
    }
    if ($_ =~ /CONFIG CPU OR SCU-L2 CACHE PROTECTION END/ and $config{CACHE_PROTECTION}) {
      $config{CACHE_PROTECTION} = 0;
      next;
    }
    next if ($config{CACHE_PROTECTION} and $PARAM::parameter{CPU_CACHE_PROTECTION} eq "FALSE" and $PARAM::parameter{SCU_CACHE_PROTECTION} eq "FALSE");

    if ($_ =~ /CONFIG NO CPU OR SCU-L2 CACHE PROTECTION START/) {
      $config{NO_CACHE_PROTECTION} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO CPU OR SCU-L2 CACHE PROTECTION END/ and $config{NO_CACHE_PROTECTION}) {
      $config{NO_CACHE_PROTECTION} = 0;
      next;
    }
    next if ($config{NO_CACHE_PROTECTION} and ($PARAM::parameter{CPU_CACHE_PROTECTION} eq "TRUE" or $PARAM::parameter{SCU_CACHE_PROTECTION} eq "TRUE"));

    if ($_ =~ /CONFIG NO SCU-L2 CACHE PROTECTION START/) {
      $config{NO_SCU_CACHE_PROTECTION} = 1;
      next;
    }
    if ($_ =~ /CONFIG NO SCU-L2 CACHE PROTECTION END/ and $config{NO_SCU_CACHE_PROTECTION}) {
      $config{NO_SCU_CACHE_PROTECTION} = 0;
      next;
    }
    next if ($config{NO_SCU_CACHE_PROTECTION} and $PARAM::parameter{SCU_CACHE_PROTECTION} eq "TRUE");
    #
    # Write the local params
    if ($_ =~ /\s*\);/ and !$config{localparam_done}) {
      $config{localparam_done} = 1;
      print OUT $_;
      print OUT "\n";
      print OUT "  // -----------------------------\n";
      print OUT "  // Local Params declarations\n";
      print OUT "  // -----------------------------\n";
      print OUT "  localparam NUM_CPUS = $PARAM::parameter{NUM_CPUS};\n";
      foreach my $param (keys %parameter_tf) {
	print OUT "  localparam $param = 1;\n" if ($parameter_tf{$param} eq "TRUE");
	print OUT "  localparam $param = 0;\n" if ($parameter_tf{$param} eq "FALSE");
      }
      foreach my $param (keys %parameter_cs) {
	print OUT "  localparam [2:0] $param = 3'b000;\n" if ($parameter_cs{$param} eq "8KB");
	print OUT "  localparam [2:0] $param = 3'b001;\n" if ($parameter_cs{$param} eq "16KB");
	print OUT "  localparam [2:0] $param = 3'b011;\n" if ($parameter_cs{$param} eq "32KB");
	print OUT "  localparam [2:0] $param = 3'b111;\n" if ($parameter_cs{$param} eq "64KB");	
      }
      print OUT "  localparam [3:0] L2_CACHE_SIZE = 4'b0000;\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "128KB");
      print OUT "  localparam [3:0] L2_CACHE_SIZE = 4'b0001;\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "256KB");
      print OUT "  localparam [3:0] L2_CACHE_SIZE = 4'b0011;\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "512KB");
      print OUT "  localparam [3:0] L2_CACHE_SIZE = 4'b0111;\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "1024KB");
      print OUT "  localparam [3:0] L2_CACHE_SIZE = 4'b1111;\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "2048KB");
      print OUT "  localparam [0:0] L2_INPUT_LATENCY = 1'b0;\n" if ($PARAM::parameter{L2_INPUT_LATENCY} eq "1");
      print OUT "  localparam [0:0] L2_INPUT_LATENCY = 1'b1;\n" if ($PARAM::parameter{L2_INPUT_LATENCY} eq "2");
      print OUT "  localparam [0:0] L2_OUTPUT_LATENCY = 1'b0;\n" if ($PARAM::parameter{L2_OUTPUT_LATENCY} eq "2");
      print OUT "  localparam [0:0] L2_OUTPUT_LATENCY = 1'b1;\n" if ($PARAM::parameter{L2_OUTPUT_LATENCY} eq "3");
      next;
    }

    print OUT $_;
  }
  close(IN);
  close(OUT);

  # Printing out CortexA53 Xml
  ipxact_config if ($options{ipxact});

  # Render power aware constraints
  upf_config($msb) if ($options{upf});
}

# INDEX:   - check config
# =====
sub check_config {
  #
  # Add checker
  #
  error_msg "Configuration value $PARAM::parameter{NUM_CPUS} for NUM_CPUS not supported" if ($PARAM::parameter{NUM_CPUS} > 4 or $PARAM::parameter{NUM_CPUS} < 1);
  # TRUE or False Check
  %parameter_tf = (
		   NEON_FP              => uc($PARAM::parameter{NEON_FP}),
		   CRYPTO               => uc($PARAM::parameter{CRYPTO}),
		   CPU_CACHE_PROTECTION => uc($PARAM::parameter{CPU_CACHE_PROTECTION}),
		   ACE                  => uc($PARAM::parameter{ACE}),
		   L2_CACHE             => uc($PARAM::parameter{L2_CACHE}),
		   ACP                  => uc($PARAM::parameter{ACP}),
		   SCU_CACHE_PROTECTION => uc($PARAM::parameter{SCU_CACHE_PROTECTION}),
		   LEGACY_V7_DEBUG_MAP  => uc($PARAM::parameter{LEGACY_V7_DEBUG_MAP})
		  );
  foreach my $param (keys %parameter_tf) {
    error_msg "Configuration value $parameter_tf{$param} for $param not supported" if ($parameter_tf{$param} !~ m/^(TRUE|FALSE)$/);
  }
  # cache size check
  %parameter_cs = (
		   L1_ICACHE_SIZE => uc($PARAM::parameter{L1_ICACHE_SIZE}),
		   L1_DCACHE_SIZE => uc($PARAM::parameter{L1_DCACHE_SIZE})
		  );
  foreach my $param (keys %parameter_cs) {
    error_msg "Configuration value $parameter_cs{$param} for $param not supported" if ($parameter_cs{$param} !~ m/^(8|16|32|64)KB$/);
  }
  error_msg "Configuration value $PARAM::parameter{L2_CACHE_SIZE} for L2_CACHE_SIZE not supported" if ($PARAM::parameter{L2_CACHE_SIZE} !~ m/^(128|256|512|1024|2048)KB$/i);
  # latency
  error_msg "Configuration value $PARAM::parameter{L2_INPUT_LATENCY} for L2_INPUT_LATENCY not supported" if ($PARAM::parameter{L2_INPUT_LATENCY} !~ m/^(1|2)$/);
  error_msg "Configuration value $PARAM::parameter{L2_OUTPUT_LATENCY} for L2_OUTPUT_LATENCY not supported" if ($PARAM::parameter{L2_OUTPUT_LATENCY} !~ m/^(2|3)$/);
  # l2 scu/cpu protection combination
  if ($parameter_tf{L2_CACHE} eq "TRUE" and $parameter_tf{SCU_CACHE_PROTECTION} eq "FALSE" and $parameter_tf{CPU_CACHE_PROTECTION} eq "TRUE") {
    error_msg "If L2_CACHE == TRUE and SCU_CACHE_PROTECTION == FALSE then CPU_CACHE_PROTECTION cannot be TRUE";
  }
  # crypto/neon check
  if ($parameter_tf{CRYPTO} eq "TRUE" and $parameter_tf{NEON_FP} eq "FALSE") {
    error_msg "If CRYPTO == TRUE then NEON_FP cannot be FALSE";
  }
  #scuprotection/l2 cache check 
  if ($parameter_tf{L2_CACHE} eq "FALSE") {
    if ($parameter_tf{SCU_CACHE_PROTECTION} eq "TRUE") {
      error_msg "SCU_CACHE_PROTECTION == TRUE not possible when L2_CACHE == FALSE";
    }  
  }

  if ($options{verbose}) {
    info_msg "";
    info_msg "Read $options{config} with the following parameters:";
    foreach my $param (keys %PARAM::parameter) {
      info_msg "$param = $PARAM::parameter{$param}";
    }
    info_msg "\n";
  }
}

#  INDEX:   - upf_config
# ======
sub upf_config($) {
  my $cn = shift;

  my $upf_unconfigured = "$FindBin::Bin/../../../cortexa53/power_intent/upf/CORTEXA53_constraints_unconfigured.upf";
  my $upf              = "$FindBin::Bin/../../../cortexa53/power_intent/upf/CORTEXA53_constraints.upf";
  my $msb = $PARAM::parameter{NUM_CPUS}-1;
  my %config;
  my @line = ();
  open(IN,"$upf_unconfigured") or error_msg "Cannot open $upf_unconfigured";
  open(OUT,">$upf") or error_msg "Cannot open $upf";
  while (<IN>) {
    #
    # Take care of CORTEXA53 extensions
    #
    if ($_ =~ /CONFIG CORTEXA53 COUNT START/) {
      $config{CORTEXA53} = 1;
      next;
    }
    if ($config{CORTEXA53}) {
      if ($_ =~ /CONFIG CORTEXA53 COUNT END/) {
	# end: print
	for (my $i = 0; $i <= $#line; $i++) {
	  (my $p = $line[$i]) =~ s/<CN>/$msb/g;
	  print OUT "$p";
	}
	@line = ();
	$config{CORTEXA53} = 0;
      } else {
	# line: collect
	if ($_ =~ /(\s+AFREADYM([0-3]) \\)/) {
	  push @line,"$1\n" if ($2 <= $msb);
	} else {
	  push @line,$_;
	}
      }
      next;
    }
    #
    # Take care of CPU extensions
    #
    if ($_ =~ /CONFIG CPU COUNT START/) {
      $config{CPU} = 1;
      next;
    }
    if ($config{CPU}) {
      if ($_ =~ /CONFIG CPU COUNT END/) {
	# end: print
	for (my $k = 0; $k <= $cn; $k++) {
	  for (my $i = 0; $i <= $#line; $i++) {
	    (my $p = $line[$i]) =~ s/<CN>/$k/g;
	    print OUT "$p";
	  }
	}
	@line = ();
	$config{CPU} = 0;
      } else {
	# line: collect
	if ($_ =~ /(\s+-state.*)<(&& PDCPUADVSIMD<CN>\s.*)>(.*)$/) {
	  if ($PARAM::parameter{NEON_FP} eq "TRUE") {
	    push @line,"$1 $2$3\n";
	  } else {
	    push @line,"$1$3\n";
	  }
        } else {
	  push @line,$_;
	}
      }
      next;
    }
    #
    # Take care of NEON_FP extensions
    #
    if ($_ =~ /CONFIG NEON_FP START/) {
      $config{NEON_FP} = 1;
      next;
    }
    if ($config{NEON_FP}) {
      if ($_ =~ /CONFIG NEON_FP END/) {
	if ($PARAM::parameter{NEON_FP} eq "TRUE") {
	  # end: print
	  for (my $k = 0; $k <= $cn; $k++) {
	    for (my $i = 0; $i <= $#line; $i++) {
	      (my $p = $line[$i]) =~ s/<CN>/$k/g;
	      print OUT "$p";
	    }
	  }
	}
	@line = ();
	$config{NEON_FP} = 0;	
      } else {
	# line: collect
	push @line,$_;
      }
      next;
    }
    #
    # Take care of L2 extensions
    #
    if ($_ =~ /CONFIG L2_CACHE START/) {
      $config{L2_CACHE} = 1;
      next;
    }
    if ($_ =~ /CONFIG L2_CACHE END/ and $config{L2_CACHE}) {
      $config{L2_CACHE} = 0;
      next;
    }
    next if ($config{L2_CACHE} and $PARAM::parameter{L2_CACHE} eq "FALSE");
    #
    # Take care of PDCORTEXA53 power state
    #
    if ($_ =~ /CONFIG PDCORTEXA53 START/) {
      $config{PDCORTEXA53} = 1;
      # Because the top-level power domain will depend on L2 present and CPU present
      # it is simpler to encoding the logic in here
      my $p = "add_power_state PDCORTEXA53 \\\n";

      # state: RUN
      $p .= "  -state RUN         {-logic_expr {primary == ON";
      $p .= "  && PDL2 == RUN" if ($PARAM::parameter{L2_CACHE} eq "TRUE");
      #for (my $k = 0; $k <= $cn; $k++) {
      #	$p .= " && PDCPU$k == RUN";
      #}
      $p .= "}} \\\n";

      # state: CPU<CN>_RET
      #for (my $k = 0; $k <= $cn; $k++) {
      #	$p .= "  -state CPU${k}_RET    {-logic_expr {primary == ON";
      #	$p .= "  && PDL2 != SHD" if ($PARAM::parameter{L2_CACHE} eq "TRUE");
      #	$p .= " && PDCPU$k == RET";
      #	$p .= "}} \\\n";
      #}

      if ($PARAM::parameter{L2_CACHE} eq "TRUE") {

	# state: L2_RET
	$p .= "  -state L2_RET      {-logic_expr {primary == ON";
	$p .= "  && PDL2 == RET";
	#for (my $k = 0; $k <= $cn; $k++) {
	#  $p .= " && PDCPU$k != SHD";
	#}
	$p .= "}} \\\n";

	# state: DMT
	$p .= "  -state DMT         {-logic_expr {primary == OFF";
	$p .= " && PDL2 != SHD";
	for (my $k = 0; $k <= $cn; $k++) {
	  $p .= " && PDCPU$k == SHD";
	}
	$p .= "}} \\\n";

      }

      # state: SHD
      $p .= "  -state SHD         {-logic_expr {primary == OFF";
      $p .= " && PDL2 == SHD" if ($PARAM::parameter{L2_CACHE} eq "TRUE");
      for (my $k = 0; $k <= $cn; $k++) {
	$p .= " && PDCPU$k == SHD";
      }
      $p .= "}}";
      
      print OUT "$p";
    }
    
    if ($_ =~ /CONFIG PDCORTEXA53 END/ and $config{PDCORTEXA53}) {
      $config{PDCORTEXA53} = 0;
      next;
    }
    next if ($config{PDCORTEXA53});

    #
    # Take care of PDCORTEXA53 POWER STATE
    #
    if ($_ =~ /CONFIG PDCORTEXA53 POWER STATE START/) {
      $config{PDCORTEXA53_PS} = 1;
      next;
    }
    if ($_ =~ /CONFIG PDCORTEXA53 POWER STATE END/ and $config{PDCORTEXA53_PS}) {
      $config{PDCORTEXA53_PS} = 0;
      next;
    }
    
    print OUT $_;
  }
  close(IN);
  close(OUT);
}

#  INDEX:   - ipxact_config
# ======
sub ipxact_config {

  # Temporary output file
  my $ipxact_config_file = "$FindBin::Bin/../../../cortexa53/ipxact/ipxact_cfg_file.txt";
  # tool location
  my $Build_Component    = "$FindBin::Bin/../../../shared/tools/bin/Build_Component";
  # unconfigured location
  my $unconfigured_file  = "$FindBin::Bin/../../../cortexa53/ipxact/CortexA53_unconfigured.xml";
  # configured
  my $configured_file    = "$FindBin::Bin/../../../cortexa53/ipxact/CortexA53_configured.xml";

  # print function header for debug
  info_msg("Printing IP-Xact file $ipxact_config_file");

  # open files
  open(OUT,">$ipxact_config_file");

  # Print all the parameters for IpXact unconfigured file
  print OUT "NUM_CPUS = $PARAM::parameter{NUM_CPUS} \n";

  foreach my $param (keys %parameter_tf) {
    print OUT "$param = 1\n" if ($parameter_tf{$param} eq "TRUE");
    print OUT "$param = 0\n" if ($parameter_tf{$param} eq "FALSE");
  }
  foreach my $param (keys %parameter_cs) {
    print OUT "$param = 000\n" if ($parameter_cs{$param} eq "8KB");
    print OUT "$param = 001\n" if ($parameter_cs{$param} eq "16KB");
    print OUT "$param = 011\n" if ($parameter_cs{$param} eq "32KB");
    print OUT "$param = 111\n" if ($parameter_cs{$param} eq "64KB");
  }

  print OUT "L2_CACHE_SIZE = 0000\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "128KB");
  print OUT "L2_CACHE_SIZE = 0001\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "256KB");
  print OUT "L2_CACHE_SIZE = 0011\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "512KB");
  print OUT "L2_CACHE_SIZE = 0111\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "1024KB");
  print OUT "L2_CACHE_SIZE = 1111\n" if (uc($PARAM::parameter{L2_CACHE_SIZE}) eq "2048KB");
  print OUT "L2_INPUT_LATENCY = 0\n" if ($PARAM::parameter{L2_INPUT_LATENCY} eq "1");
  print OUT "L2_INPUT_LATENCY = 1\n" if ($PARAM::parameter{L2_INPUT_LATENCY} eq "2");
  print OUT "L2_OUTPUT_LATENCY = 0\n" if ($PARAM::parameter{L2_OUTPUT_LATENCY} eq "2");
  print OUT "L2_OUTPUT_LATENCY = 1\n" if ($PARAM::parameter{L2_OUTPUT_LATENCY} eq "3");

  close(OUT);

  # remove configure file if exists
  system("rm $configured_file") if (-e $configured_file);
  # Run BuildComponent with the config file
  system("$Build_Component $unconfigured_file configured -config $ipxact_config_file");

  # Remove config file
  system("rm $ipxact_config_file");
}

# INDEX:   - usage_msg
# =====
sub usage_msg {
  print STDERR << "EOF";

    Modes:
      $script_name [-config <name>] [-input <name>] [-output <name>] [-module <name>] [-verbose] [-ipxact] [-upf] [-help]

    Options:
      -config     <name> Configuration file. Default $options{config}
      -input      <name> Unconfigured verilog. Default $options{input}
      -output     <name> Configured verilog. Default $options{output}
      -module     <name> Module name. Default $options{module}
      -verbose           Add debug information
      -ipxact            Render CortexA53 into IPXact Xml format
      -upf               Render power aware constraint file
      -help              Help (prints this usage message)

EOF
  exit;
}

# INDEX:   - print_start_msg
# =====
sub print_start_msg {
  info_msg "";
  info_msg "Start render $options{input} using $options{config} into $options{output} with module name $options{module}";
  info_msg "\n";
}

# INDEX:   - get_flags
# =====
sub get_flags {
  if (!GetOptions("help"     => \$options{help},
		  "verbose"  => \$options{verbose},
                  "config=s" => \$options{config},
		  "input=s"  => \$options{input},
		  "output=s" => \$options{output},
		  "module=s" => \$options{module},
		  "ipxact"   => \$options{ipxact},
		  "upf"      => \$options{upf})
      || $options{help}) {
    usage_msg;
  }

  print_start_msg if ($options{verbose});
}

# INDEX:   - info_msg
# =====
sub info_msg {
  print STDOUT "-I- $script_name: @_\n";
}

# INDEX:   - error_msg
# =====
sub error_msg {
  print STDOUT "-E- $script_name: (error) @_\n\n";
  exit 1;
}
