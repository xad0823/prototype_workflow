#!/usr/bin/perl -w

################################################################################
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM limited.
#
#            (C) COPYRIGHT 2013-2014 ARM Limited.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM limited.
#
#      Checked In          : $Date: 2010-08-16 11:27:15 +0100 (Mon, 16 Aug 2010) $
#      Revision            : $Revision: 145890 $
#      Release Information : CORTEXA53-r0p4-00rel0
#
################################################################################
#
# DESCRIPTION:
#
# Parses a file that contains formatted tokens, and creates a new file where
# these tokens are resolved based on a set of configurations options.  The main
# purpose of this script is to render an unconfigured Verilog HDL file.
#
# The unconfigured template file contains START CONFIG and END CONFIG markers
# which delimit code that only appears in the given configuration.  For example:
#
#   // START CONFIG (NUM_CPUS > 1)
#   ...
#   ...
#   // END CONFIG
#
# The expression after 'START CONFIG' can be any expression that Perl can
# interpret as either true or false.  Any tokens in the expression that match
# the name of a configuration option in the global configuration file will be
# substituted with their appropriate values before the expression is evaluated.
#
# A START GENPARAM block is also supported.  Any code within this block can
# contain formatted parameter substitution tokens which will be replaced by
# the actual parameter value in the rendered output.  For example:
#
#   // START GENPARAM
#   ...
#   localparam NUM_CPUS = <# NUM_CPUS : 1 #>
#   ...
#   // END GENPARAM
#
# The format of the GENPARAM substitution tokens is:
#   <# param_name #>
# or
#   <# param_name : default_value #>
#
# where
#   param_name is the name of the parameter from the global configuration file
#
#   default_value is the default that will be substituted if the parameter does
#     not exist in the global configuration file
#
# If an parameter does not exist in the global configuration file and no default
# value is provided then an error is reported.
#
# Finally, any lines between "START NOGENERATE" and "END NOGENERATE" directives
# never appears in the outputs.  It is equivalent to "START CONFIG 0" and is
# useful for adding comments to the template file that will not appear in the
# generated file.
#
# Rules:
#
#  1. CONFIG blocks must not nest
#  2. NOGENERATE blocks must not nest
#  3. CONFIG blocks must not contain any NOGENERATE blocks
#  4. NOGENERATE blocks must not contain any CONFIG blocks
#  5. GENPARAM blocks must not nest
#  6. CONFIG blocks may contain GENPARAM blocks
#
#
# ARGUMENTS:
#
#   generator.pl [-intkit] <input_template> <output_file>
#
# where:
#
#   intkit           specifies that an integration kit top-level should be created
#   <input_template> is the unconfigured template file
#   <output_file>    is the name of the new, configured file to create
#
################################################################################

use strict;
use FindBin;


################################################################################
# Global variables
################################################################################

# These variables must be set from command-line arguments and control generation
my $template;         # Input template file name
my $target;           # Output target file name
my %options = ();     # Command-line options

# Function prototypes
sub transform_line($$$);
sub check_scope($$);

# Supported command-line configs.  This is used for parameter substitution.
# Anything that appears as a key in this hash is a permitted command-line
# parameter (the value is arbitrary.)
my %clconfigs = (intkit => 1);


################################################################################
# Argument parsing
################################################################################

foreach my $arg (@ARGV)
{
  # Options all start with a single dash, followed by word characters.  The word
  # is added to the options hash.  If the option has a value, using the
  # -option=value notation, then the value is associated in the hash.
  if ($arg =~ /^-(\w+)(=(\w+))?/)
  {
    if (defined($2)) { $options{$1} = $3 }
    else             { $options{$1} = 1  } # Default to '1' (TRUE)
  }

  # Regular arguments: first argument is the input file, second one is the
  # output file.
  else
  {
    if    (!defined($template)) { $template = $arg }
    elsif (!defined($target))   { $target   = $arg }
    else                        { die "ERROR: too many arguments\n" }
  }
}

# Check both the input file and the output file were specified
die "ERROR: no input file specified\n"  if (!defined($template));
die "ERROR: no output file specified\n" if (!defined($target));

# The template file must exist
die "ERROR: template file $template does not exist\n" if (! -e $template);


################################################################################
# Read the global configuration file
################################################################################

# Provides the PARAM configuration hash
require "$FindBin::Bin/../../../../config/CORTEXA53.cfg";

if (exists ($options{intkit} )) {
  require "$FindBin::Bin/../../../integration_kit_cssoc/intkit_tb.cfg";
  $options{intkit} = 1;
}


# The configuration hash uses TRUE and FALSE strings to represent logical TRUE
# and FALSE.  We replace these values with numerical values 1 and 0,
# respectively, so that the parameters can be used directly in logical
# expressions.
foreach (keys %PARAM::parameter)
{
  $PARAM::parameter{$_} = 1 if ($PARAM::parameter{$_} eq "TRUE" );
  $PARAM::parameter{$_} = 0 if ($PARAM::parameter{$_} eq "FALSE");
}

if (($PARAM::parameter{CPU_CACHE_PROTECTION} == 1) or ($PARAM::parameter{SCU_CACHE_PROTECTION} == 1)) {
  $PARAM::parameter{CPU_OR_SCU_CACHE_PROTECTION} = 1;
} else {
  $PARAM::parameter{CPU_OR_SCU_CACHE_PROTECTION} = 0;
}

################################################################################
# Output generation
################################################################################

my $linenum = 0;        # Line number in input file
my $inline;             # Line read from input file
my $config_block = 0;   # In a CONFIG block
my $param_block = 0;    # In a GENPARAM block
my $in_scope = 1;       # Current input line is in scope (based on configuration)

open(TEMPLATE, $template) or die "ERROR: Unable to open generation template file $template\n";
open(TARGET, ">$target")  or die "ERROR: Unable to create generated file $target\n";

# Iterate over lines from the template file.  If a line is between CONFIG tags
# and the configuration doesn't match, then don't print that line.  Other lines
# are echoed to the output file, with any generated parameters replaced with
# their correct values.
while ($inline = <TEMPLATE>)
{
  $linenum++;

  # If the line is not in a processed block, then it is always printed to the
  # output file.  It might be transformed if the line is inside a GENPARAM block.
  unless ($inline =~ /\s*(\/\/|#)\s*(START|END)\s+(CONFIG|GENPARAM|NOGENERATE)\s+(.*)$/)
  {
    print TARGET &transform_line($param_block, $inline, $linenum) if $in_scope;
  }

  # Otherwise, if the line forms a valid START or END directive then change state
  # base on the directive
  elsif ($2 eq "START")
  {
    # CONFIG     : update the in_scope marker, set config_block
    # GENPARAM   : set the param_block marker
    # NOGENERATE : clear the in_scope marker, set config_block
    if    ($3 eq "CONFIG")     { $config_block++; $in_scope = &check_scope($4, $linenum); }
    elsif ($3 eq "GENPARAM")   { $param_block++;                                          }
    elsif ($3 eq "NOGENERATE") { $config_block++;   $in_scope = 0;                        }

    # Check for illegal nested directives
    die "ERROR: generate CONFIG/NOGENERATE directives must not nest, line $linenum\n" if ($config_block > 1);
    die "ERROR: generate GENPARAM directives must not nest, line $linenum\n" if ($param_block > 1);
  }
  elsif ($2 eq "END")
  {
    if    ($3 eq "CONFIG")     { $config_block--; $in_scope = 1; }
    elsif ($3 eq "GENPARAM")   { $param_block--;                 }
    elsif ($3 eq "NOGENERATE") { $config_block--; $in_scope = 1; }

    # Check for matching START directive
    die "ERROR: unmatched END directive on line $linenum\n" if ($config_block < 0 || $param_block < 0);
  }
}

# Close all files and exit
close(TEMPLATE) or warn "WARNING: Could not close template file $template\n";
close(TARGET)   or warn "WARNING: Could not close generated file $target\n";

exit 0;


################################################################################
# SUBROUTINE: transform_line
# Transforms the given string based on the global %parameter hash
################################################################################

sub transform_line($$$)
{
  my $gp      = $_[0]; # Inside a GENPARAM block
  my $line    = $_[1]; # The line to transform
  my $linenum = $_[2]; # The line number
  my $repl;            # Parameter replacement string

  # If we are in a GENPARAM block then replace parameter tokens with their
  # configured values
  if ($gp)
  {
    if ($line =~ /<#\s*(\w+)\s*(:\s*(\S+))*\s*#>/)
    {
      if    (exists($PARAM::parameter{$1})) { $repl = $PARAM::parameter{$1} }
      elsif (defined($3))                   { $repl = $3                    }
      else  {die "ERROR: No generation parameter for $1, line $linenum\n";  }

      # Perform the substitution
      $line =~ s/<#\s*(\w+)\s*(:\s*(\S+))*\s*#>/$repl/;
    }
  }

  return $line;
}


################################################################################
# SUBROUTINE: check_scope
# Takes a string containing a parameter expression, returns a number >0 if the
# expression evaluates to TRUE given the configuration options or 0 if it
# evaluates to FALSE.
#
# The parameters hash takes precedent over the options hash.  Any scope which
# can't be resolved in either hash evaluates to FALSE.
################################################################################

sub check_scope($$)
{
  my $expr = $_[0];
  my $line = $_[1];
  my $result;

  # Split the expression into a list, based on word boundaries.  This makes it
  # easier to go on to replace words in the expression with matching values from
  # the parameters or options hash.
  my @lexpr  = split(/\b/, $expr);
  my @lexprs = map {
                      exists($PARAM::parameter{$_}) ? $PARAM::parameter{$_} :
                      exists($clconfigs{$_})        ? (exists($options{$_}) ? $options{$_} : 0)
                                                    : $_
                   } @lexpr;

  # Resolved expression
  $expr = '$result = ' . join("", @lexprs) . ";";
  eval $expr;

  # Warn about expressions that can't be parsed
  if (!defined($result))
  {
    warn "WARNING: unknown parameter or incorrect directive, line $line. Evaluating as FALSE.\n";
    $result = 0;
  }

  return $result;
}

