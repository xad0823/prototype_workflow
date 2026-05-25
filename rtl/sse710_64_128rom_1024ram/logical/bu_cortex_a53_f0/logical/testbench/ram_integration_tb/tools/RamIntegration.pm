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

package RamIntegration;

use strict;
use Exporter;
use Data::Dumper;
use File::Basename;

use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(parsing_for_localparams generating_ram_harness finding_top_level_file);

#===========
# Prototypes
#===========

sub generating_ram_harness($$);
sub parsing_for_localparams($);
sub info_msg;
sub error_msg;

#==========
# Routines
#==========

#Generating Ram Top Level TB
#---------------------------

sub generating_ram_harness($$) {
  my $cfg_hash_ref         = shift;
  my $localparams_hash_ref = shift;

  #Local Variable
  my %cfg_hash =  %{$cfg_hash_ref};
  my $toplevelFile;
  my $toplevelTB;
  my %io_hash;
  my $local_debug = 0;
  my $state =  "Start";
  my $param_state = "Start";

  $toplevelFile = "$cfg_hash{design_dir}";
  $toplevelTB   = "$cfg_hash{tb_dir}$cfg_hash{tb_harness}.v";

  system("mv $toplevelTB $toplevelTB.bak");

  info_msg " Generation of Top Level RAM Integration harness file in progress.... \n";
  info_msg " - Top Level RTL File = $toplevelFile \n";
  info_msg " - Top Level TB File  = $toplevelTB \n";

  my $io_hash_ref = collecting_io($toplevelFile);
  %io_hash = %{$io_hash_ref};

  if ($local_debug) {
    for (my $i = 0; $i<= $#{$io_hash{input}}; $i++) {
      print "Dir = $io_hash{input}[$i]->{dir} Name = $io_hash{input}[$i]->{name} Width = $io_hash{input}[$i]->{width}\n";
    }
  }

  open(VF,"$toplevelTB.bak") or error_msg "Cannot open the file : $toplevelTB.bak";
  open(OUT,">$toplevelTB") or error_msg "Cannot open the file : $toplevelTB";

  my $exception_array_ref = input_exceptions(\%cfg_hash, "in_harness_to_1", "in_harness_to_other");

   if ($local_debug) {
    for (my $i = 0; $i<= $#{$exception_array_ref}; $i++) {
      foreach my $z (keys %{$exception_array_ref->[$i]}) {
        print "Var = $z , Val = $exception_array_ref->[$i]{$z} \n";
      }
    }
  }

  #Localparams printing which is taken from topfile
  while (<VF>) {

    if ($param_state eq "Start") {
      $param_state = "Insert" if ($_ =~ /Write automatically generated localparam/);
      print OUT; next;
    }

    if ($param_state eq "Insert") {

      print OUT "  // ------------------------------------------------------\n\n";

      foreach my $param (keys %{$localparams_hash_ref}) {
          print OUT "$localparams_hash_ref->{$param}\n";
      }

      print OUT "  // ------------------------------------------------------\n";

      $param_state = "PreEnd";
      next;
    }

    if ($param_state eq "PreEnd") {
      if ($_ =~ /(End automatically generated localparam)/) {
        print OUT "  // $1\n";
        $param_state = "End";
        next;
      }
    }

    if ($param_state eq "End") {
      #
      # print end of file unchanged
      #
      print OUT;
    }

  } #Printing Localparams

  #Closing and opening the filehandles again to print IO's
  close(OUT);
  close(VF);

  system("mv $toplevelTB $toplevelTB.bak");

  open(VFF,"$toplevelTB.bak") or error_msg "Cannot open the file : $toplevelTB.bak";
  open(OUTF,">$toplevelTB")   or error_msg "Cannot open the file : $toplevelTB";

  #Printing IO's
  while (<VFF>) {

    if ($state eq "Start") {
      $state = "Insert" if ($_ =~ /Start automatically generated logic/);
      print OUTF; next;
    }

    if ($state eq "Insert") {

      print OUTF "  // ------------------------------------------------------\n\n";
      print OUTF "  $cfg_hash{design_name} u_$cfg_hash{design_name} ( \n";
      print OUTF "    //Inputs \n";

      for (my $i = 0; $i<= $#{$io_hash{input}}; $i++) {
         my $var_match_found = 0;
         for (my $j = 0; $j<= $#{$exception_array_ref}; $j++) {
           if ($exception_array_ref->[$j]{var_name} eq $io_hash{input}[$i]->{name}) {
             $var_match_found = 1;
             if($exception_array_ref->[$j]{connect} eq 1) {
                print OUTF "         .$io_hash{input}[$i]->{name}\t({$io_hash{input}[$i]->{width} {1'b1}}),\n";
             } else {
                print OUTF "         .$io_hash{input}[$i]->{name}\t($exception_array_ref->[$j]{connect}),\n";
             }
           }
         }
         print OUTF "         .$io_hash{input}[$i]->{name}\t({$io_hash{input}[$i]->{width} {1'b0}}),\n" if ($var_match_found == 0);
      }

      print OUTF "    //Outputs \n";
      for (my $i = 0; $i<= $#{$io_hash{output}}; $i++) {
        if($i == $#{$io_hash{output}}){
          print OUTF "         .$io_hash{output}[$i]->{name}\t()\n";
        } else {
          print OUTF "         .$io_hash{output}[$i]->{name}\t(),\n";
        }
      }

      print OUTF "   ); \n";
      print OUTF "  // ------------------------------------------------------\n";

      $state = "PreEnd";
      next;
    }

    if ($state eq "PreEnd") {
      if ($_ =~ /(End automatically generated logic)/) {
        print OUTF "  // $1\n";
        $state = "End";
        next;
      }
    }

    if ($state eq "End") {
      #
      # print end of file unchanged
      #
      print OUTF;
    }

  } #Printing IO's

 close(OUTF);
 close(VFF);
}

#Collecting Io from Top Level RTL
#--------------------------------

sub collecting_io($) {
  my $toplevelFile = shift;

  #Local Variable
  my %io_hash;
  my @input_array;
  my @output_array;
  my $line;

  # open files
  open(IN,"$toplevelFile") or error_msg "Cannot open the file : $toplevelFile";

  while (<IN>) {

    $line = $_; chomp($line);

    my %info_hash;
    my $io_name;
    my $io_dir;
    my $io_width;

    if ($line =~ /^\s+(input)\s+wire\s+(\[\s*?(\d+):\s*?(\d+)\])?\s+(\w+)[,]?$/) {
      $io_name = $5;
      $io_dir  = $1;
      if(defined $2) {
        $io_width = $3 - $4 + 1;
      } else {
        $io_width = 1;
      }

      $info_hash{name}  = $io_name;
      $info_hash{width} = $io_width;
      $info_hash{dir}   = $io_dir;

      push(@input_array, \%info_hash);

    } elsif ($line =~ /^\s+(output)\s+wire\s+(\[\s*?(\d+):\s*?(\d+)\])?\s+(\w+)[,]?$/) {
      $io_name = $5;
      $io_dir  = $1;
      if(defined $2) {
        $io_width = $3 - $4 + 1;
      } else {
        $io_width = 1;
      }

      $info_hash{name}  = $io_name;
      $info_hash{width} = $io_width;
      $info_hash{dir}   = $io_dir;

      push(@output_array, \%info_hash);

    }
  } #while

  close(IN);

  $io_hash{input}  = \@input_array;
  $io_hash{output} = \@output_array;

  return \%io_hash;
}

#Dealing with Exceptional IO's
#-----------------------------

sub input_exceptions($$$) {
  my $cfg_hash_ref = shift;
  my $exception0   = shift;
  my $exception1   = shift;

  #Local Variable
  my @exception_array;
  my @split_array;


  for (my $i = 0; $i<=1; $i++) {
    if ($i == 0) {
      @split_array = split(/,/,$cfg_hash_ref->{$exception0});

      for (my $j = 0; $j<=$#split_array; $j++) {
        my %split_hash;
        $split_hash{var_name} = $split_array[$j];
        $split_hash{connect}  = 1;

        push(@exception_array, \%split_hash);
      }
    } elsif ($i == 1) {
      @split_array = split(/,/,$cfg_hash_ref->{$exception1});

      for (my $j = 0; $j<=$#split_array; $j++) {
        my %split_hash;
        my @local_array = split(/:/,$split_array[$j]);
        for (my $j = 0; $j<=$#local_array; $j++) {
          $split_hash{var_name} = $local_array[$j] if($j == 0);

          if($j == 1) {
            if ($split_hash{var_name} =~ /nCORERESET/ or $split_hash{var_name} =~ /nCPUPORESET/) {
              $split_hash{connect}  = $local_array[$j]."[NUM_CPUS - 1 : 0]";
            } else {
               $split_hash{connect}  = $local_array[$j];
            }
          }

        }
         push(@exception_array, \%split_hash);
      }
    }
  }

  return \@exception_array;
}

#Parsing Top Level File
#-----------------------

sub finding_top_level_file($) {
  my $File         = shift;

  #Local varibales
  my $state = "Start";
  my $top_level_file_name;
  my $top_level_module_name;
  my %cfg_hash;
  my $cfg_hash_ref;

  # open files
  open(IN,"$File") or error_msg "Cannot open $File for parsing name of top level file";

  while (<IN>) {
    if ($state eq "Start") {
      $state = "Find_File_Name" if ($_ =~ /Top level verilog file can be found \(Do not re-arrange or delete comment\)\./);
      next;
    }

    if ($state eq "Find_File_Name") {

      if ($_ =~ /^-v\s+(\S+)$/) {
        $state = "Find_Module_Name";
        $top_level_file_name = $1;
      } else {
        error_msg "Cannot find the Top Level file name in $File \n" if ($_ =~ /(\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\* DO NOT EDIT FOLLOWING PATHS \*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*)/);
        next;
      }

    }

    if ($state eq "Find_Module_Name") {
      open(TL,"$top_level_file_name") or error_msg "Cannot open $top_level_file_name for parsing name of module";
      while (<TL>) {
        if ($_ =~ /module\s+(\S+)\s*?\(/) {
        $top_level_module_name = $1;
        $state = "End";
       }
       next;
      }
      close(TL);
    }

   if ($state eq "End") {
     last;
   }

  } #while
   close(IN);

   %cfg_hash = (
                'design_dir'          => $top_level_file_name,
                'design_name'         => $top_level_module_name
               );

  $cfg_hash_ref = \%cfg_hash;
  return $cfg_hash_ref;
}

#Parsingfor Local Params in RTL
#------------------------------

sub parsing_for_localparams($) {
  my $cfg_hash_ref = shift;


  #Local Variable
  my $line;
  my %localparams_hash;
  my $debug   = 0;

 #File name from the hash reference
 my $File = "$cfg_hash_ref->{design_dir}";

 if ($debug == 1) {
    print "Debug parsing_for_localparams: Input file is - $File;\n"
  };

  # open files
  open(IN,"$File") or error_msg "Cannot open the Top level file for parsing Local Params : $File";

  while (<IN>) {

    $line = $_; chomp($line);

    if ($line =~ /^\s+localparam\s+(\[\s*?\d+:\s*?\d+\])?\s*?(\w+)\s+=\s+(\d+'b)?(\w+)[;]?$/) {
      my $key = $2;
      $localparams_hash{$key} = $line;
    }
  }

  close(IN);

  if ($debug == 1) {
    foreach my $z (keys %localparams_hash){
      print "Debug parsing_for_localparams: Local params hash keys = $z, Val = $localparams_hash{$z}\n";
    }
  }
  return \%localparams_hash;
}

#Info_msg
# -------

sub info_msg {
  print STDOUT "-I- GenerateRamTB: @_\n";
}

#Error_msg
# --------
sub error_msg {
  print STDOUT "-E- GenerateRamTB: (error) @_\n\n";
  exit 1;
}



1;
