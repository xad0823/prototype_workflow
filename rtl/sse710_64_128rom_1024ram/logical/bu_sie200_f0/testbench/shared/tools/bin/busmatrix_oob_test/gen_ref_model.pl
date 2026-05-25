#!/usr/bin/env perl
#-----------------------------------------------------------------------------
#   The confidential and proprietary information contained in this file may
#   only be used by a person authorised under and to the extent permitted
#   by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#          (C) COPYRIGHT 2015-2016 ARM Limited or its affiliates.
#              ALL RIGHTS RESERVED
#
#   This entire notice must be reproduced on all copies of this file
#   and copies of this file may only be made by a person if such person is
#   permitted to do so under the terms of a subsisting license agreement
#   from ARM Limited or its affiliates.
#
#     Checked In          : Fri Nov 25 15:35:47 2016 +0000
#     Revision            : 94095e2
#
#     Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
#
#-----------------------------------------------------------------------------
# README
#
#-----------------------------------------------------------------------------

use Getopt::Long;
use Data::Dumper;
use File::Basename;
use strict;
use warnings;
use Cwd;
#use File::Slurp qw/:edit/;
use File::Copy;

#--------------------------------------
# Usage
#--------------------------------------
my $usage = "

Usage:

multisim_update.pl -rgr <rgr_system>
 -help          : Print usage
 -xml           : top level busmatrix file name

Script must be run from trunk directory, just above regression dir
";

#--------------------------------------
# Parsing Command line arguments
#--------------------------------------
my $help;
my $parameter_xml;

if ( !GetOptions (
                    "h|help|?"        => \$help,
                    "xml=s"       => \$parameter_xml,
                  )
    or @ARGV ne 0
    or $help
   ) {
  print $usage;
  exit;
}

my $module_name = $ENV{"MODULE_NAME"};
my $tgtdir = $ENV{"TGTDIR"};
my $templates_dir = $tgtdir."/testbench/shared/tools/bin/busmatrix_oob_test/templates";
my $tbench_dir    = $tgtdir."/testbench/execution_tb/verilog/".$module_name;

my $file_in;
my $file_out;
my $indent      = "    ";

my $master_num = 0;
my $slave_num = 0;
my $cur_master;

my %masters;
my %slaves;

my %address_map;
my %con_matrix;
my %remap_matrix;

my $addr_width = 32;

my $name_pattern = '[a-zA-Z0-9_]+';
my $hexa_pattern = '[0-9a-fA-F]+';
my $number_pattern = '[0-9]+';

#----------------------------------
# Address Map extraction from XML |
#----------------------------------

#print $parameter_xml;
open $file_in, '<', "$parameter_xml" or die "Can't read input file: $!";

while ( my $line = <$file_in> )  {      # Goes through original file line by line

    if ($line =~ /<slave_interface\s*name=['"]($name_pattern)['"]/) {
        $masters{$1} = $master_num;
        $master_num ++;
        $cur_master = $1;

    }

    if ($line =~ /<sparse_connect\s*interface=['"]($name_pattern)['"]/) {

        push @{$con_matrix{$cur_master}}, $1;

    }

    if ($line =~ /<address_region\s*interface=['"]($name_pattern)['"]\s*mem_lo=['"]($hexa_pattern)['"]\s*mem_hi=['"]($hexa_pattern)['"]\s*remapping=['"](move|none|alias)['"]/) {

        if ($4 eq "move"){
            push @{$address_map{$cur_master}{$1}{temp_start_addresses}}, $2;
            push @{$address_map{$cur_master}{$1}{temp_end_addresses}}, $3;
        }
        else{
            push @{$address_map{$cur_master}{$1}{fix_start_addresses}}, $2;
            push @{$address_map{$cur_master}{$1}{fix_end_addresses}}, $3;
        }
    }
    if ($line =~ /<address_region\s*interface=['"]($name_pattern)['"]\s*mem_lo=['"]($hexa_pattern)['"]\s*mem_hi=['"]($hexa_pattern)['"]\s*remapping=['"]del[\s|,|_]*(([0-9]+[\s|,|_]*)*)['"]/) {
        push @{$address_map{$cur_master}{$1}{delete_remap}{del_start_addresses}}, $2;
        push @{$address_map{$cur_master}{$1}{delete_remap}{del_end_addresses}}, $3;
        push @{$address_map{$cur_master}{$1}{delete_remap}{del_bits}}, [split(/[,|\s|_]+/,$4)];
    }


    if ($line =~ /<remap_region\s*interface=['"]($name_pattern)['"]\s*mem_lo=['"]($hexa_pattern)['"]\s*mem_hi=['"]($hexa_pattern)['"]\s*bit=['"]($number_pattern)['"]/) {

        push @{$address_map{$cur_master}{$1}{remap_bits}{$4}{remap_start_addresses}}, $2;
        push @{$address_map{$cur_master}{$1}{remap_bits}{$4}{remap_end_addresses}}, $3;
        push @{$remap_matrix{$cur_master}{$1}}, $4;
    }

    if ($line =~ /<master_interface\s*name=['"]($name_pattern)['"]/) {
        $slaves{$1} = $slave_num;
        $slave_num ++;
    }

    if ($line =~ /address_width>([0-9]+)</) {
        $addr_width = $1;
    }

} # while ( my $line = <$file_in> )

close $file_in or die "can't close file: $!";



#--------------------------------------------
# Reference Model creation in systemverilog |
#--------------------------------------------

sub write_func {

    if ($_[0] eq "slv") {

    print $file_out
"\n    virtual function void write_from_$_[0]$_[2]\(vip_ahb5_transaction trans\);
            `uvm_info(get_type_name\(\),\"Analysis Import from AHB5 $_[1] $_[2] invoked\",UVM_MEDIUM\)
        \/\/  `uvm_info(get_type_name\(\),\$psprintf\(\"Collected transaction is \%s\",trans.convert2string\(\)\),UVM_MEDIUM\)
            aport_$_[0]_to_scbd\[$_[2]\].write\(trans\);
    endfunction\n";



    }
    elsif ($_[0] eq "mst") {

           print $file_out
"\n    virtual function void write_from_$_[0]$_[2]\(vip_ahb5_transaction trans\);
        int index = addr_map.$_[0]_decode_addr(trans.address, $_[2]);
        if (index != -1) begin
            `uvm_info(get_type_name\(\),\"Analysis Import from AHB5 $_[1] $_[2] invoked\",UVM_MEDIUM\)
        \/\/  `uvm_info(get_type_name\(\),\$psprintf\(\"Collected transaction is \%s\",trans.convert2string\(\)\),UVM_MEDIUM\)
            aport_$_[0]_to_scbd\[$_[2]\]\[index\].write\(trans\);
        end
        else begin
            `uvm_info(get_type_name\(\),\"Analysis Import from AHB5 $_[1] $_[2] NOT invoked, not mapped to any $_[1]s\",UVM_MEDIUM\)
            `uvm_info(get_type_name(),\$psprintf(\"Collected failing transaction is \%s\",trans.convert2string()),UVM_MEDIUM)
        end
    endfunction\n";


    }


}


open $file_in, '<', "$templates_dir/gbusm_ref_model.svh" or die "Can't read input file: $!";
open $file_out, '>', "$tbench_dir/gbusm_ref_model.svh" or die "Can't write output file: $!";



while ( my $line = <$file_in> )  {      # Goes through original file line by line

    if ($line =~ /<Master analysis ports declaration by macro>/) {
        print $file_out "\n \/\/Analysis port macro declarations coming from masters\n";
        for my $key (keys %address_map) {
            print $file_out "`uvm_analysis_imp_decl(_from_mst$masters{$key});\n";
        };
        $line = "";
        print $file_out "\n";
    }

    if ($line =~ /<Slave analysis ports declaration by macro>/) {
        print $file_out "\n \/\/Analysis port macro declarations coming from slaves\n";
        for my $key (keys %slaves) {
            print $file_out "`uvm_analysis_imp_decl(_from_slv$slaves{$key});\n";
        };
        $line = "";
        print $file_out "\n";
    }

    if ($line =~ /<master_aports_decl>/) {
        print $file_out "\n \/\/Analysis port declarations coming from masterts\n";
        for my $key (keys %address_map) {
            print $file_out "    uvm_analysis_imp_from_mst$masters{$key} #(vip_ahb5_transaction, busmtrx_ref_model) aport_from_mst$masters{$key};\n";
        };
        $line = "";
        print $file_out "\n";
    }

    if ($line =~ /<slave_aports_decl>/) {
        print $file_out "\n \/\/Analysis port declarations coming from masterts\n";
        for my $key (keys %slaves) {
            print $file_out "    uvm_analysis_imp_from_slv$slaves{$key} #(vip_ahb5_transaction, busmtrx_ref_model) aport_from_slv$slaves{$key};\n";
        };
        $line = "";
        print $file_out "\n";
    }


    if ($line =~ /<Build scoreboards, analysis ports>/) {
        print $file_out "\n \/\/Building analysis ports and scoreboards for reference model\n";

        print $file_out "\n    \/\/Building distributor analysis ports from masters \n";
        for my $key (keys %address_map) {
            print $file_out "${indent}${indent}aport_from_mst$masters{$key} = new\(\"aport_from_mst$masters{$key}\", this\);\n";
        };

        print $file_out "\n    \/\/Building distributor analysis ports from slaves \n";
        for my $key (keys %slaves) {
            print $file_out "${indent}${indent}aport_from_slv$slaves{$key} = new\(\"aport_from_slv$slaves{$key}\", this\);\n";
        };


        print $file_out "\n\n    \/\/ Analysis ports and scoreboard building for MASTER-SLAVE  address mapping";
        for my $slave_key (keys %slaves){
             my $slave_idx = $slaves{$slave_key};

             print $file_out "\n\n    \/\/ Analysis port and scoreboard for $slave_key (SLAVE $slaves{$slave_key}) ";
             print $file_out "\n        scbd\[$slaves{$slave_key}\] = scoreboard_basic::type_id::create\(\"scbd_$slave_idx\", this\);";
             print $file_out "\n        aport_slv_to_scbd\[$slaves{$slave_key}\] = new\(\"aport_slave_ahb_$slave_idx\", this\);";

             for my $master_key (keys %masters){
                 my $master_idx = $masters{$master_key};


                print $file_out "\n    \/\/ Analysis ports for $master_key (MASTER $masters{$master_key}) - $slave_key (SLAVE $slaves{$slave_key}) address mapping";
                print $file_out "\n        aport_mst_to_scbd\[$masters{$master_key}\]\[$slaves{$slave_key}\] = new\(\"aport_master_ahb_$master_idx\_$slave_idx\", this\);";



            }
        }


        $line = "\n";
    }

    if ($line =~ /<write functions for master and slave analysis ports>/) {
        print $file_out "\n \/\/Master analysis port write function definitions\n";
        for my $key (keys %address_map) {
            write_func("mst", "MASTER", $masters{$key});
            print $file_out "\n";
        };

        print $file_out "\n \/\/Slave analysis port write function definitions\n";
        for my $key (keys %slaves) {
            write_func("slv", "SLAVE", $slaves{$key});
            print $file_out "\n";
        };

        $line = "";
        print $file_out "\n";
    }

    print $file_out $line;
} # while ( my $line = <$file_in> )

close $file_in or die "can't close file: $!";
close $file_out or die "can't close file: $!";

#--------------------------------------
# Create Address Map in systemverilog |
#--------------------------------------

open $file_in, '<', "$templates_dir/gbusm_addr_map.svh" or die "Can't read input file: $!";
open $file_out, '>', "$tbench_dir/gbusm_addr_map.svh" or die "Can't write output file: $!";

while ( my $line = <$file_in> )  {      # Goes through original file line by line
    if ($line =~ /<Fill addr range arrays>/) {

        for my $master (keys %address_map) {
            for my $slave (keys %{$address_map{$master}}) {

                print $file_out "\n    \/\/ Address ranges of $master - $slave connection";
                print $file_out "\n        \/\/ FIX address ranges ";

                if (exists ${$address_map{$master}{$slave}}{fix_start_addresses}) {
                    my $num_of_fix_addr       =  scalar @{$address_map{$master}{$slave}{fix_start_addresses}};
                    print $file_out "\n        fix_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]                  = new\[$num_of_fix_addr\];";
                }

                my $addr_index = 0;
                foreach my $address ( @{$address_map{$master}{$slave}{fix_start_addresses}}) {
                    my $fix_start_address = $address;
                    my $fix_end_address   = ${$address_map{$master}{$slave}{fix_end_addresses}}[$addr_index];
                    print $file_out "\n        fix_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].start_addr    = $addr_width\'h$fix_start_address;";
                    print $file_out "\n        fix_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].end_addr      = $addr_width\'h$fix_end_address;";
                    $addr_index++;
                }


                print $file_out "\n";
                print $file_out "\n        \/\/ Remappable address ranges ";

                if (exists ${$address_map{$master}{$slave}}{temp_start_addresses}) {
                    my $num_of_tmp_addr       =  scalar @{$address_map{$master}{$slave}{temp_start_addresses}};
                    print $file_out "\n        temp_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]                 = new\[$num_of_tmp_addr\];";
                }

                $addr_index = 0;
                foreach my $address ( @{$address_map{$master}{$slave}{temp_start_addresses}}) {
                    my $tmp_start_address = $address;
                    my $tmp_end_address   = ${$address_map{$master}{$slave}{temp_end_addresses}}[$addr_index];
                    print $file_out "\n        temp_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].start_addr   = $addr_width\'h$tmp_start_address;";
                    print $file_out "\n        temp_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].end_addr     = $addr_width\'h$tmp_end_address;";
                    $addr_index++;
                }
                print $file_out "\n";
                print $file_out "\n";
                print $file_out "\n        \/\/ Remap bit influence ";

                if (exists ${$remap_matrix{$master}}{$slave}) {
                    my $num_of_rmp_bits       =  scalar @{$remap_matrix{$master}{$slave}};
                    print $file_out "\n        remap_inf\[$masters{$master}\]\[$slaves{$slave}\]        = new\[$num_of_rmp_bits\];";
                }

                $addr_index = 0;
                foreach my $bit ( @{$remap_matrix{$master}{$slave}}) {
                    print $file_out "\n        remap_inf\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\]     = $bit;";
                    $addr_index++;
                }
                print $file_out "\n";

                print $file_out "\n        \/\/ Remapped address ranges ";
                foreach my $rmp_bit ( keys %{$address_map{$master}{$slave}{remap_bits}}) {

                    my $num_of_rmp_addr       =  scalar @{$address_map{$master}{$slave}{remap_bits}{$rmp_bit}{remap_start_addresses}};
                    print $file_out "\n        rmp_addr_ranges\[$rmp_bit\]\[$masters{$master}\]\[$slaves{$slave}\]               = new\[$num_of_rmp_addr\];";

                      $addr_index = 0;
                    foreach my $address ( @{$address_map{$master}{$slave}{remap_bits}{$rmp_bit}{remap_start_addresses}}) {
                        my $rmp_start_address = $address;
                        my $rmp_end_address   = ${$address_map{$master}{$slave}{remap_bits}{$rmp_bit}{remap_end_addresses}}[$addr_index];
                        print $file_out "\n        rmp_addr_ranges\[$rmp_bit\]\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].start_addr = $addr_width\'h$rmp_start_address;";
                        print $file_out "\n        rmp_addr_ranges\[$rmp_bit\]\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].end_addr   = $addr_width\'h$rmp_end_address;";
                        $addr_index++;
                    }
                }
                print $file_out "\n";




                print $file_out "\n        \/\/ Remap bit delete influence ";


                if (exists ${$address_map{$master}{$slave}}{delete_remap}) {
                    my $num_of_del_addr       =  scalar @{$address_map{$master}{$slave}{delete_remap}{del_start_addresses}};
                    print $file_out "\n        del_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]                  = new\[$num_of_del_addr\];";
                }

                $addr_index = 0;
                foreach my $address ( @{$address_map{$master}{$slave}{delete_remap}{del_start_addresses}}) {
                    my $del_start_address = $address;
                    my $del_end_address   = ${$address_map{$master}{$slave}{delete_remap}{del_end_addresses}}[$addr_index];
                    print $file_out "\n        del_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].start_addr    = $addr_width\'h$del_start_address;";
                    print $file_out "\n        del_addr_ranges\[$masters{$master}\]\[$slaves{$slave}\]\[$addr_index\].end_addr      = $addr_width\'h$del_end_address;";
                    $addr_index++;
                }


                my $num_of_del_addr       =  scalar @{$address_map{$master}{$slave}{delete_remap}{del_start_addresses}};
                if ($num_of_del_addr) {
                    print $file_out "\n        del_bits\[$masters{$master}\]\[$slaves{$slave}\]                  = new\[$num_of_del_addr\];";
                }

                my $bit_counter =0;
                foreach my $bits ( @{$address_map{$master}{$slave}{delete_remap}{del_bits}}) {
                    my $num_of_bits        =  scalar @{$bits};
                    print $file_out "\n        del_bits\[$masters{$master}\]\[$slaves{$slave}\][$bit_counter]                  = new\[$num_of_bits\];";
                    my $del_bit_counter = 0;
                    foreach my $del_bit ( @{$bits}){
                        print $file_out "\n        del_bits\[$masters{$master}\]\[$slaves{$slave}\]\[$bit_counter\][$del_bit_counter]    = $del_bit;";
                        $del_bit_counter++;
                    }
                    $bit_counter++;
                }


                print $file_out "\n";

            }
        }
        $line = "";
    }

    print $file_out $line;
} # while ( my $line = <$file_in> )

close $file_in or die "can't close file: $!";
close $file_out or die "can't close file: $!";


#--------------------------------------------
# Create Address Map in systemverilog |
#--------------------------------------------

open $file_in, '<', "$templates_dir/gbusm_env.svh" or die "Can't read input file: $!";
open $file_out, '>', "$tbench_dir/gbusm_env.svh" or die "Can't write output file: $!";

while ( my $line = <$file_in> )  {      # Goes through original file line by line
    if ($line =~ /<Ref model connections>/) {
        $line = "";
        print $file_out "\n        \/\/Reference model analysis port connections from masters\n";
        for my $key (keys %address_map) {
            print $file_out "        ahb5_master_agent\[$masters{$key}\].item_collected_port.connect\(ref_model.aport_from_mst$masters{$key}\);\n";
        };
        print $file_out "\n";

        print $file_out "\n        \/\/Reference model analysis port connections from slaves\n";
        for my $key (keys %slaves) {
            print $file_out "        ahb5_slave_agent\[$slaves{$key}\].item_collected_port.connect\(ref_model.aport_from_slv$slaves{$key}\);\n";
        };
        print $file_out "\n";
    }
    print $file_out $line;
} # while ( my $line = <$file_in> )

close $file_in or die "can't close file: $!";
close $file_out or die "can't close file: $!";

#-----------------------------
# Copying Interface file
#-----------------------------

copy("$templates_dir/gbusm_rmp_if.svh", "$tbench_dir/gbusm_rmp_if.svh");

#-----------------------------
# Copying Sequence file
#-----------------------------

copy("$templates_dir/gbusm_vip_ahb5_master_sequence.sv", "$tbench_dir/gbusm_vip_ahb5_master_sequence.sv");

#------------------------------------
# Copying Addres range package file
#------------------------------------

copy("$templates_dir/gbusm_addr_range.svh", "$tbench_dir/gbusm_addr_range.svh");

copy("$templates_dir/gbusm_oob_pkg.svh", "$tbench_dir/gbusm_oob_pkg.svh");

copy("$templates_dir/scoreboard_basic_64.sv", "$tbench_dir/scoreboard_basic.sv");

copy("$templates_dir/uvm_data_64.svh", "$tbench_dir/uvm_data.svh");





#-----------------------------
# DEBUG XML parsing if needed
#-----------------------------

#print Dumper(\%address_map);
#print Dumper(\%con_matrix);
#print Dumper(\%remap_matrix);
#print Dumper(\%slaves);
#print Dumper(\%masters);
