#!/usr/bin/perl -w
#-------------------------------------------------------------------------------
#
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
#                 (C) COPYRIGHT 2013-2014 ARM Limited.
#                       ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#      SVN Information
#
#      Checked In          : $Date: 2009-04-29 15:08:26 +0100 (Wed, 29 Apr 2009) $
#
#      Revision            : $Revision: 107303 $
#
#      Release Information : CORTEXA53-r0p4-00rel0
#
#-------------------------------------------------------------------------------
# Description:
#
#   Converts a binary image into a Verilog memory initialisation file that can
#   be read using $readmemh.
#
# Usage:
#
#   bin2vhx <input_file> <output_file> [--be | --le] [--width=<data_width>]
#
#   Where
#
#     --le    : Image is in little-endian format (this is the default.)
#     --be    : Image is in big-endian format
#     --width : Width in bits of the target memory array, default 32
#
#   The memory width must be a multiple of 32, i.e. a whole number of words.
#-------------------------------------------------------------------------------

use strict;

################################################################################
# Global variables
################################################################################

# Arguments
my $infile;           # Input filename
my $outfile;          # Output filename
my $datawidth = 32;   # Data width
my $bigendian = 0;    # Big endian format

# Other variables
my $words_per_row;    # Number of words in one row of memory
my $unpack_template;  # Data template for the unpack function
my $word;             # A word of packed binary data
my @row = ();         # A row of packed binary data


################################################################################
# Argument parsing
################################################################################

foreach (@ARGV)
{
  if (/^--((\w+)(=(\d+))?)/)
  {
    # Options
    if    (lc($2) eq "be")                    { $bigendian = 1;  }
    elsif (lc($2) eq "le")                    { $bigendian = 0;  }
    elsif (lc($2) eq "width" and defined($4)) { $datawidth = $4; }
    else  { die("ERROR: Unknown argument: $1\n");                }
  }
  else
  {
    # The first non-optional argument is the input filename, the second is the
    # output filename.  Any additional arguments not prefixed with double-dash
    # are illegal.
    if    (!defined($infile )) { $infile  = $_;    }
    elsif (!defined($outfile)) { $outfile = $_;    }
    else  { die "ERROR: too many arguments: $_\n"; }
  }
}

# Check that the data width is valid
die "ERROR: Data width must be a multiple of 32 bits\n" if (($datawidth % 32) != 0);

# Check that input and output files have been given
die "ERROR: No input file specified\n"  if (!defined($infile));
die "ERROR: No output file specified\n" if (!defined($outfile));


################################################################################
# Data conversion
################################################################################

open(INFILE,  "$infile"  ) or die("ERROR: could not open $infile for reading\n");
open(OUTFILE, ">$outfile") or die("ERROR: could not open $outfile for writing\n");

# Ensure the input is treated as binary data, not text
binmode(INFILE);

# We'll read data one word at a time from the binary file, and buffer these
# words until there's enough data to write a whole row to the output file.
# The ASCII conversion is done using the unpack() function, which restricts us
# converting one word (4 bytes) at a time, assuming a 32-bit machine.
#
# Note that $datawidth was already checked to be divisible by 32.  The data
# will be treated as either big endian or little endian depending on the
# options chosen.
$words_per_row   = $datawidth / 32;
$unpack_template = $bigendian ? "N" : "V";


while (read(INFILE, $word, 4))  # 4 bytes = 1 word
{
  # Push an ASCII hexadecimal representation of each word into the row,
  # ensuring that the ASCII conversion does not truncate leading zeroes.
  unshift(@row, sprintf("%.8x", unpack($unpack_template, $word)));

  # When the row array equals the target size, print the conversion to file.
  # Note that row[0] must be printed last.
  if ($#row == $words_per_row - 1)
  {
    print OUTFILE @row;
    print OUTFILE "\n";
    @row = ();
  }
}

# Since the loop only prints lines when we have a full row, we might be left
# a part-full row at the end of the loop.  Pad this with zeroes and print it.
if ($#row > -1)
{
  unshift(@row, "00000000") while ($#row < $words_per_row - 1);
  print OUTFILE @row;
  print OUTFILE "\n";
}

# Close the files
close(INFILE);
close(OUTFILE);

