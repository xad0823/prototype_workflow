#! /usr/bin/env perl
BEGIN { $^W = 1 }
#******************************************************************************
#   The confidential and proprietary information contained in this file may
#   only be used by a person authorised under and to the extent permitted
#   by a subsisting licensing agreement from Arm Limited or its affiliates.
#
#          (C) COPYRIGHT 2010-2018 Arm Limited or its affiliates.
#              ALL RIGHTS RESERVED
#
#   This entire notice must be reproduced on all copies of this file
#   and copies of this file may only be made by a person if such person is
#   permitted to do so under the terms of a subsisting license agreement
#   from Arm Limited or its affiliates.
#******************************************************************************
#
#               Library of IPXACT routines
#               ==========================
#
#******************************************************************************
#
#       RCS Information
#
#       RCS Filename        : IPXACT_lib.pm
#       Release             : $State$
#
#******************************************************************************
#
# This file contains a set of IP-XACT helper functions for use with ARM IP-XACT
# scripts
#
#******************************************************************************

######## KNOWN LIMITATIONS ########
# - null function for _spirit_containsToken
# - id() evaluation is not strictly correctly done

package IPXACT_lib;

use strict;
use warnings;
use bigint;

use XML::LibXML;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION = sprintf "%d", '$Revision: 4044 $'  =~ /(\d+)/;
  @ISA = qw(Exporter);
  @EXPORT = qw(&check_XML &debugMsg &print_error &print_warning &print_info &solve_dependency &check_configuration &check_type &XPathSolve &check_file &get_file &remove_TPmarkup &get_filelist &getVLNV &get_child_element &getVLNVType);
  %EXPORT_TAGS = ( );
  @EXPORT_OK = qw($desired_ext $svncmd $debug $wiki $html);
}
our @EXPORT_OK;
our $desired_ext = ".xml";
our $svncmd = "svn";
our $debug = 0;
our $wiki = 0;
our $html = 0;
# hash to be used as cache inside Xpath_Solve function
our %used_node_values;

#sub remove_TPmarkup($) {}
#sub solve_dependency ($) {}
#sub XPathSolve ($$) {}
#sub _spirit_containsToken {} ## do not export - use XPathSolve
#sub _spirit_decode {}        ## do not export - use XPathSolve
#sub _spirit_pow {}           ## do not export - use XPathSolve
#sub _spirit_log {}           ## do not export - use XPathSolve
#sub get_filelist($) {}
#sub getVLNV($) {}
#sub check_configuration($) {}
#sub check_type($$) {}
#sub remove_scaled($) {}
#sub check_XML($) {}
#sub check_file ($) {}
#sub get_file ($) {}
#sub print_error($) {}
#sub debugMsg($) {}
#sub get_child_element($$) {}

END { }

#################################################################################
# Routine : remove_TPmarkup
#    Given a string, remove any potential internal markup
#
# Arguments :
#    string to be tidied
#
# Returns :
#   string with no CDATA tags, <tags> or </tags>
#################################################################################
sub remove_TPmarkup($) {
  my $orig_string = shift;
  my $clean_string = $orig_string;

  $clean_string =~ s/\<!\[CDATA\[//g;  # remove of opening CDATA tags
  $clean_string =~ s/\]\]\>//g;        # remove of closing CDATA tags

  $clean_string =~ s/\<+?\>//g;     # remove of any tags (must be minimal to ensure it leaves bits between tags!)
                                    # this catches opening and closing tags
  return $clean_string;

}

#################################################################################
# Routine : solve_dependency
#    Given a XPath::Node, solve the XPath dependency
#
# Arguments :
#    node - the node which has a spirit:dependency that needs to be solved
#
# Returns :
#  either a new value (if dependency can be solved)
#      or current value (if no dependency)
#      or NULL (an error)
#################################################################################
sub solve_dependency ($) {
  my $node = shift;

  my $value; # actual value of element (current value if no dependency to solve

  my @attribute_list = ('spirit:format',         # check type (enumerated list) !
                        'spirit:resolve',        # check type (enumerated list) !
                        'spirit:id',             # check type (ID) !
                        'spirit:dependency',     # ? check valid expression
                        'spirit:choiceRef',      # check type (Name), check choice present, get values (use against value before format) ~
                        'spirit:order',          # check type (float)
                        'spirit:configGroups',   # check type (NMTOKENS)
                        'spirit:bitStringLength',# check type (nonNegativeInteger), check spirit:format (bitString), use against value
                        'spirit:minimum',        # check type (string), check spirit:format (bitString, float, long), check valid against spirit:rangeType, use against value
                        'spirit:maximum',        # check type (string), check spirit:format (bitString, float, long), check valid against spirit:rangeType, use against value
                        'spirit:rangeType',      # check type (enumerated list), check there is at least one of spirit:minimum/spirit:maximum
                        'spirit:prompt'          # check type (string - so nothing to check!)
                       );

  my %node_attributes; # contains all the attributes for faster referencing

  my $node_attributes;

  # get as many of the attributes as possible
  debugMsg("solve_dependency: Analysing node: ".$node->nodePath());
  foreach my $attribute (@attribute_list) {
    if ($node->hasAttribute($attribute)) {
      $node_attributes{$attribute} = $node->getAttribute( $attribute );
      debugMsg("solve_dependency: ... Found attribute $attribute = $node_attributes{$attribute}");
    }
  }

  my $solve_flag;
  if ($node_attributes{'spirit:resolve'} eq "dependent") {
    $solve_flag = 1;
  } else {
    $value = $node->findvalue(".");
    debugMsg("solve_dependency: not dependent spirit:dependency=".$value);
  }

  if ($solve_flag) {
    # solve the XPath!
    debugMsg("solve_dependency: trying to solve XPath");

    $value = IPXACT_lib::XPathSolve($node_attributes{'spirit:dependency'}, $node);

    debugMsg("solve_dependency: Now have a value of $value");

    # cast the value back to what is constrained in the attributes fetched above (if nothing defined then use it as-is)
    # - cheat and use XPath to solve them

    if (defined $node_attributes{'spirit:format'}) {
      if ($node_attributes{'spirit:format'} =~ /(bool|float|long|bitString)/ ) {
        # a number type is required
        my $xpc = XML::LibXML::XPathContext->new($node);


        # if quoted bitstring transform the number
        if ($node_attributes{'spirit:format'} =~ /bitString/s and $value =~ /\"([01]+)\"/) {
          $value = oct("0b$1");
        }
        my $xpath_cast;
        if ($node_attributes{'spirit:format'} =~ /(long|bitString)/s) {
          my $decimal_num = _spirit_decode($value);
          $xpath_cast = 'number(string('.$decimal_num.'))';
        } else {
          $xpath_cast = 'number(string("'.$value.'"))';
        }
        my $cast_num = $xpc->find($xpath_cast);

        debugMsg("solve_dependency: $xpath_cast gave value of $cast_num");

        if (defined $node_attributes{'spirit:minimum'}) {
          if ($cast_num !~ /(NaN|Inf)/ ) {
            $cast_num = $node_attributes{'spirit:minimum'} if ($cast_num < $node_attributes{'spirit:minimum'});
          }
        }

        debugMsg("solve_dependency: have value of $cast_num");

        if (defined $node_attributes{'spirit:maximum'}) {
          if ($cast_num !~ /(NaN|Inf)/ ) {
            $cast_num = $node_attributes{'spirit:maximum'} if ($cast_num > $node_attributes{'spirit:maximum'});
          }
        }

        debugMsg("solve_dependency: have value of $cast_num");

        if ($node_attributes{'spirit:format'} =~ /bool/) {
          $xpath_cast = 'boolean('.$cast_num.')';
          $value = $xpc->find($xpath_cast);
          debugMsg("solve_dependency: have bool value of $value");
          if ($value == 1) {
            $value = "true";
          } else {
            $value = "false";
          }
          debugMsg("solve_dependency: have bool value of $value");
        } elsif ($node_attributes{'spirit:format'} =~ /long/) {
          $xpath_cast = 'floor("'.$cast_num.'")';
          $value = $xpc->find($xpath_cast);
          debugMsg("solve_dependency: have long value of $value");
        } elsif ($node_attributes{'spirit:format'} =~ /bitString/) {
          if ($value =~ /\"([01]+)\"/) {$value = $cast_num;}
          debugMsg("solve_dependency: have bitString value of $value");
        } else {
          # assume float so leave is as number()
          $value = $cast_num;
          debugMsg("solve_dependency: have float value of $value");
        }

      } elsif ($node_attributes{'spirit:format'} =~ /string/) {
        # can't do anything with it so just pass it out (i.e. leave it)
      } else {
        # error - unexpected format type
        print_error("solve_dependency: unexpected spirit:format in depedency expression at node: ".$node->nodePath());
        $value = '';
      }
    } else {
      # spirit:format not defined - take a chance on what was passed
      debugMsg("solve_dependency: no spirit:format defined, taking a chance that XPath did what was expected");
    }
  }

  debugMsg("solve_dependency: returning with $value");
  return $value;
}

#################################################################################
# Routine : XPathSolve
#    Solves XPath expressions that may include the Spirit Consortium additional
# functions not present within the default XPath evaluation.
#
# Arguments :
#    XPath_expr - the XPath expression to evaluate
#    node       - the assumed context of a node in the containing document
#
# Returns :
#    result of XPath evaluation
#################################################################################
sub XPathSolve ($$) {
  my $XPath_expr = shift;
  my $node = shift;
  my $error = 0;

  debugMsg("XPathSolve: have: $XPath_expr for node: ".$node->nodePath());

  # create XPathContext using the node passed in
  my $xc = XML::LibXML::XPathContext->new($node);

  # register the extra functions needed
  $xc->registerNs('spirit', 'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4');
  $xc->registerFunctionNS('containsToken','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4', \&_spirit_containsToken);
  $xc->registerFunctionNS('decode','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4', \&_spirit_decode);
  $xc->registerFunctionNS('pow','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4', \&_spirit_pow);
  $xc->registerFunctionNS('log','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1.4', \&_spirit_log);

  # register the extra functions needed
  $xc->registerNs('spirit', 'http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009');
  $xc->registerFunctionNS('containsToken','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009', \&_spirit_containsToken);
  $xc->registerFunctionNS('decode','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009', \&_spirit_decode);
  $xc->registerFunctionNS('pow','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009', \&_spirit_pow);
  $xc->registerFunctionNS('log','http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009', \&_spirit_log);

  # sort out any id() calls as spirit:id does not get correctly trapped for id()
  # - search through $node (entire doc) for spirit:id
  # - substitute node result
  if ($XPath_expr =~ /id\('(.*)'\)/) {

    # setup things to run around for a bit
    my $partial = $XPath_expr;

    while ($partial =~ /id\('(.*?)'\)/) {
      # there is an id
      my $id_name = $1;
      my $id_xpath = '//spirit:value[@spirit:id="'.$id_name.'"]';
      my $alt_id;
      # try to find node value in %used_node_values
      if (defined $used_node_values{$id_xpath}) {
        debugMsg("XpathSolve will used previous calculated value for: ".$id_xpath);
        $alt_id = $used_node_values{$id_xpath};
        debugMsg("value is: ".$alt_id);
        $partial =~ s/id\('$id_name'\)/$alt_id/g;
      } else {
        # value not found in %used_node_values search IP-XACT file
        my $id_result = $node->findnodes($id_xpath);
        debugMsg("had ".$id_result->size());
        if ( $id_result->size() == 1) {
          # one result - good!
          debugMsg("XPathSolve - got one result: ".$id_result->get_node(1)->nodePath());
          $alt_id = $id_result->get_node(1)->nodePath();
          # fixup for spirit's use of storing booleans as "true" or "false"
          debugMsg("got ".$id_result->get_node(1)->string_value() );
          if ($id_result->get_node(1)->getAttribute('spirit:format') =~ /bool/) {
  
            $alt_id = "".$id_result->string_value()."()";
            debugMsg("inserting ".$alt_id);
          }
  
          # if it's a scaledNumber, cast it back to a normal number
          if ($id_result->get_node(1)->getAttribute('spirit:format') =~ /(float|long)/) {
  
            $alt_id = remove_scaled($id_result->string_value());
            debugMsg("inserting ".$alt_id);
          }

          if ($id_result->get_node(1)->getAttribute('spirit:format') =~ /string/) {
  
            $alt_id = "'".$id_result->string_value()."'";
            debugMsg("inserting ".$alt_id);
          }
  
          # cache value to %used_node_values
          $used_node_values{$id_xpath} = $alt_id;
          $partial =~ s/id\('$id_name'\)/$alt_id/g;

        } else {
          # 0 or >=2 - not good
          print_error("XPathSolve: Found ".$id_result->size()." nodes matching spirit:id=".$id_name." at node: ".$node->nodePath());
          $error = 1;
          # forcably break out by clearing $partial
          $partial = " ";
        }
      }
      debugMsg("XPathSolve: expression is now: ".$partial);
    }

    $XPath_expr = $partial;

  }

  my $result;

  if ($error == 0) {
    # evaluate XPath expression
    $result = $xc->find($XPath_expr);

    debugMsg("XPathSolve: got result = ".$result->to_literal);
  } else {
    # critical error
    $result = "** ERROR **";
  }

  return $result;

}

# Series of routines that are defined by Spirit Consortium to extend capabilities
# of XPath to include some useful extra features.
#
# These should not be exported outside of IPXACT_lib.pm as they are automatically
# registered when calling XPathSolve()
sub _spirit_containsToken {
  # input = (string1, string2) or (node, stringx)
  debugMsg ("          ... evaluating XPath expression with spirit:containsToken");

  print_error("spirit:containsToken function not implemented");

  # return = boolean success
  return 'false';
}

sub _spirit_decode {
  # input = (string) or (node)
  my $input = shift;
  my $in_num;
  my $result = "NaN";

  debugMsg ("          ... evaluating XPath expression with spirit:decode");

  if (check_type($input, "scaledInteger")) {
    # pure number so can evaluate directly
    $in_num = $input;
  } elsif ($input->isa("XML::LibXML::NodeList")) {
    # hope it's a single node:
    if ($input->size() == 1) {
      $in_num = $input->get_node(1)->nodeValue;
    } else {
      print_error("spirit:decode: Found ".$input->size()." nodes in expression: ".$input->to_literal);
    }
  } elsif ($input->isa("XML::LibXML::Node")) {
    # assume a node so find the value before evaluating
    $in_num = $input->nodeValue;
  } else {
    print_error("spirit:decode: unable to process: ".$input);
  }

  if (defined $in_num) {
    $result = remove_scaled($in_num);
  }

  # return = number or "NaN"
  return $result;
}

sub _spirit_pow {
  # input = (number, number) or (node, node) or (node, number) or (number, node)
  my $input_L = shift;
  my $input_R = shift;
  my $in_num_L;
  my $in_num_R;
  my $result = "NaN";

  debugMsg ("          ... evaluating XPath expression with spirit:pow");

  if ($input_L =~ /^[0-9]+\.?[0-9]*$/ ) {
    # pure number so can evaluate directly
    $in_num_L = $input_L;
  } elsif ($input_L->isa("XML::LibXML::NodeList")) {
    # hope it's a single node:
    if ($input_L->size() == 1) {
      $in_num_L = $input_L->get_node(1)->nodeValue;
    } else {
      print_error("spirit:pow Found ".$input_L->size()." nodes in expression: ".$input_L->to_literal);
    }
  } elsif ($input_L->isa("XML::LibXML::Node")) {
    # assume a node so find the value before evaluating
    $in_num_L = $input_L->nodeValue;
  } else {
    print_error("spirit:pow unable to process first operator: ".$input_L);
  }

  if ($input_R =~ /^[0-9]+\.?[0-9]*$/ ) {
    # pure number so can evaluate directly
    $in_num_R = $input_R;
  } elsif ($input_R->isa("XML::LibXML::NodeList")) {
    # hope it's a single node:
    if ($input_R->size() == 1) {
      $in_num_R = $input_R->get_node(1)->nodeValue;
    } else {
      print_error("spirit:pow Found ".$input_R->size()." nodes in expression: ".$input_R->to_literal);
    }
  } elsif ($input_R->isa("XML::LibXML::Node")) {
    # assume a node so find the value before evaluating
    $in_num_R = $input_R->nodeValue;
  } else {
    print_error("spirit:pow unable to process second operator: ".$input_R);
  }

  if ((defined $in_num_L) && (defined $in_num_R)) {
    $result = $in_num_L ** $in_num_R;
  }

  # return = number (or node???)
  return $result
}

sub _spirit_log {
  # input = (number, number) or (node, node) or (node, number) or (number, node)
  my $input_L = shift;
  my $input_R = shift;
  my $in_num_L;
  my $in_num_R;
  my $result = "NaN";

  debugMsg ("          ... evaluating XPath expression with spirit:log");

  if ($input_L =~ /^[0-9]+\.?[0-9]*$/ ) {
    # pure number so can evaluate directly
    $in_num_L = $input_L;
  } elsif ($input_L->isa("XML::LibXML::NodeList")) {
    # hope it's a single node:
    if ($input_L->size() == 1) {
      $in_num_L = $input_L->get_node(1)->nodeValue;
    } else {
      print_error("spirit:log Found ".$input_L->size()." nodes in expression: ".$input_L->to_literal);
    }
  } elsif ($input_L->isa("XML::LibXML::Node")) {
    # assume a node so find the value before evaluating
    $in_num_L = $input_L->nodeValue;
  } else {
    print_error("spirit:log unable to process first operator: ".$input_L);
  }

  if ($input_R =~ /^[0-9]+\.?[0-9]*$/ ) {
    # pure number so can evaluate directly
    $in_num_R = $input_R;
  } elsif ($input_R->isa("XML::LibXML::NodeList")) {
    # hope it's a single node:
    if ($input_R->size() == 1) {
      $in_num_R = $input_R->get_node(1)->nodeValue;
    } else {
      print_error("spirit:log Found ".$input_R->size()." nodes in expression: ".$input_R->to_literal);
    }
  } elsif ($input_R->isa("XML::LibXML::Node")) {
    # assume a node so find the value before evaluating
    $in_num_R = $input_R->nodeValue;
  } else {
    print_error("spirit:log unable to process second operator: ".$input_R);
  }

  if ((defined $in_num_L) && (defined $in_num_R)) {
    $result = log($in_num_R)/log($in_num_L);
  }

  # return = number (or node???)
  return $result
}


#################################################################################
# Routine : get_filelist
#    returns a list of files that are located at a specific location
#
# Arguments :
#    base location to search from (recursively)
#
# Vars needed:
#    $svncmd       SVN command
#    $desired_ext  extension to search for (discard files that do not match)
#
# Returns :
#  array of files (including passed base directory) or null
#################################################################################

sub get_filelist ($) {

  my $basedir = shift;
  my @filelist;
  my $okay = 1;
  my $all_files;

  if ($basedir =~ m#^http://# ) {
    # assume SVN
    debugMsg("get_filelist: Running from SVN");
    eval { $all_files = `$svncmd list -R $basedir`};
    if ( $@ ) {
      print_error("get_filelist: Error occured opening $basedir");
      # critical error
      $okay = 0;
    }

    if ($okay) {
      # extract lines from returned results
      debugMsg("get_filelist: found SVN: $all_files");
      foreach (split("\n", $all_files)) {
        if ($_ =~ m/\.xml$/) {
          push(@filelist, $basedir."/".$_);
        }
      }
    }
  } else {
    # assume file system
    eval {$all_files = `find $basedir -type f -name "*$desired_ext"`};
    if ( $@ ) {
      print_error("get_filelist: Error occured opening $basedir");
      # critical error
      $okay = 0;
    }

    if ($okay) {
      debugMsg("get_filelist: found file system: $all_files");
      @filelist = split("\n", $all_files);
    }
  }

  return @filelist;

}

#################################################################################
# Routine : getVLNV
#    opens the file specified for XML and IP-XACT validity before fetching the VLNV
#
# Arguments :
#    filepath   path to file
#
# Returns :
#    Array of VLNV or NULL
#################################################################################
sub getVLNV($) {

  my $filename = shift;
  my $status = 1;
  my @VLNV;

  # check file exists
  # check it is XML
  # read VLNV
  # join suitable elements and add to array

  if (check_file($filename)) {
    debugMsg("getVLNV: ...$filename exists");

    ### Check for XML
    my $XML_file = check_XML($filename);

    if (defined $XML_file) {
      # check top-level type (should be spirit:busDefinition or spirit:abstractionDefinition, etc)
      my $root = $XML_file->documentElement();
      my $basepath = "/".$root->nodeName;

      debugMsg("getVLNV: ...Type = $basepath");

      if ($basepath =~ m/spirit/) {
    
    # search and find values
    my $XML_vendor  = $XML_file->findvalue("$basepath/spirit:vendor");
    my $XML_library = $XML_file->findvalue("$basepath/spirit:library");
    my $XML_name    = $XML_file->findvalue("$basepath/spirit:name");
    my $XML_version = $XML_file->findvalue("$basepath/spirit:version");
    debugMsg("getVLNV:   Found: $XML_vendor / $XML_library / $XML_name / $XML_version");

    # if any element is missing then error
    if (!$XML_vendor  ) { $status = 0; }
    if (!$XML_library ) { $status = 0; }
    if (!$XML_name    ) { $status = 0; }
    if (!$XML_version ) { $status = 0; }

    @VLNV = ($XML_vendor, $XML_library, $XML_name, $XML_version);
    debugMsg("getVLNV: ...Got VLNV = ".join("/",@VLNV));
      } else {
    debugMsg("getVLNV:  Not IP-XACT formatted- $filename");
      }

    } else {
      debugMsg("getVLNV: could not find XML in $filename");
    }

  } else {
    print "getVLNV: File not found: $filename\n";
    $status = 0;
  }

  if ($status == 0) {
    # set to null if any errors had occured
    @VLNV = '';
  }
  return @VLNV;

}

#################################################################################
# Routine : getVLNVType
#    opens the file specified for XML and IP-XACT validity before fetching the VLNV
#
# Arguments :
#    filepath   path to file
#
# Returns :
#    Array of VLNV and type or NULL
#################################################################################
sub getVLNVType($) {

  my $filename = shift;
  my $status = 1;
  my @VLNVType;

  # check file exists
  # check it is XML
  # read VLNV
  # join suitable elements and add to array

  if (check_file($filename)) {
    debugMsg("getVLNVType: ...$filename exists");

    ### Check for XML
    my $XML_file = check_XML($filename);

    if (defined $XML_file) {
      # check top-level type (should be spirit:busDefinition or spirit:abstractionDefinition, etc)
      my $root = $XML_file->documentElement();
      my $basepath = "/".$root->nodeName;

      debugMsg("getVLNVType: ...Type = $basepath");

      if ($basepath =~ m/spirit\:/) {
        # search and find values
        my $XML_vendor  = $XML_file->findvalue("$basepath/spirit:vendor");
        my $XML_library = $XML_file->findvalue("$basepath/spirit:library");
        my $XML_name    = $XML_file->findvalue("$basepath/spirit:name");
        my $XML_version = $XML_file->findvalue("$basepath/spirit:version");
        debugMsg("getVLNVType:   Found: $XML_vendor / $XML_library / $XML_name / $XML_version");

        # if any element is missing then error
        if (!$XML_vendor  ) { $status = 0; }
        if (!$XML_library ) { $status = 0; }
        if (!$XML_name    ) { $status = 0; }
        if (!$XML_version ) { $status = 0; }

        (my $base = $basepath) =~ s/\/spirit\://;

        @VLNVType = ($XML_vendor, $XML_library, $XML_name, $XML_version, $base);
        debugMsg("getVLNVType: ...Got VLNVType = ".join("/",@VLNVType));
      } else {
        debugMsg("Not an IP-XACT file");
        
      }

    } else {
      debugMsg("getVLNVType: could not find XML in $filename");
    }

  } else {
    print "getVLNVType: File not found: $filename\n";
    $status = 0;
  }

  if ($status == 0) {
    # set to null if any errors had occured
    @VLNVType = '';
  }
  return @VLNVType;

}

#################################################################################
# Routine : check_configuration
#    Given a node, check that its value matches what is allowed for the attributes
#
# Arguments :
#    Node
#
# Returns : 0 on fail
#           1 for success if either no attributes (nothing to check against) or within
#               constraints
# - limitation: cannot check against any spirit:choice
#################################################################################
sub check_configuration($) {
  my $node = shift;
  my $pass = 1;

  # if the parameter existed in the new list - get the value else use golden value
  # get all the attributes for the parameter
  # check the value is within range
  # - first check its type: Boolean, integer, "option", etc
  # - integer - check it is within min/max range
  # - option - check it is a valid option

  my @attribute_list = ('spirit:format',         # check type (enumerated list) !
                        'spirit:resolve',        # check type (enumerated list) !
                        'spirit:id',             # check type (ID) !
                        'spirit:dependency',     # ? check valid expression
                        'spirit:choiceRef',      # check type (Name), check choice present, get values (use against value before format) ~
                        'spirit:order',          # check type (float)
                        'spirit:configGroups',   # check type (NMTOKENS)
                        'spirit:bitStringLength',# check type (nonNegativeInteger), check spirit:format (bitString), use against value
                        'spirit:minimum',        # check type (string), check spirit:format (bitString, float, long), check valid against spirit:rangeType, use against value
                        'spirit:maximum',        # check type (string), check spirit:format (bitString, float, long), check valid against spirit:rangeType, use against value
#                         'spirit:rangeType',      # check type (enumerated list), check there is at least one of spirit:minimum/spirit:maximum
                        'spirit:prompt'          # check type (string - so nothing to check!)
                       );
  my %param_attribute; # contains all the attributes for faster referencing

  my $param_value;

  # get as many of the attributes as possible
  debugMsg("check_configuration: Analysing node: ".$node->nodePath());
  foreach my $attribute (@attribute_list) {
    if ($node->hasAttribute($attribute)) {
      $param_attribute{$attribute} = $node->getAttribute( $attribute );
      debugMsg("check_configuration: ... Found attribute $attribute = $param_attribute{$attribute}");
    }
  }

  # don't forget to get the value!
  $param_value = $node->findvalue(".");
  debugMsg("check_configuration: ... got the value = $param_value");

  # By this point parameters should be checkable

  ## check resolve
  if (exists $param_attribute{'spirit:resolve'}) {
    if (defined $param_attribute{'spirit:resolve'}) {
      if (check_type($param_attribute{'spirit:resolve'},"resolve")) {
        # correct type
        #$pass = 1
        debugMsg("check_configuration: spirit:resolve okay");
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:resolve not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:resolve not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } else {
    # resolve not defined, check nothing else is as well
    if (%param_attribute) {
      print_error("check_configuration: spirit:resolve not defined but other attributes are on node: ".$node->nodePath());
      $pass = 0;
    } else {
      # meh, nothing else present, nothing to resolve, so this is fine
      #$pass = 1;
    }
  }

  ## ChoiceRef
  if (exists $param_attribute{'spirit:choiceRef'}) {
    if (defined $param_attribute{'spirit:choiceRef'}) {
      if (check_type($param_attribute{'spirit:choiceRef'},"Name")) {
        my $choice_name = $param_attribute{'spirit:choiceRef'};
        # find choices/choice/name that matches
        my $nodepath = '/spirit:component/spirit:choices/spirit:choice[spirit:name="'.$choice_name.'"]';
        my $choice_nodes = $node->ownerDocument->find($nodepath);

        if ( $choice_nodes->size() == 1) {
          # get all values and see if one matches
          my $choice_enums = $choice_nodes->get_node(1)->find('./spirit:enumeration');
          my $match = 0;
          debugMsg("check_configuration: checking Choice against ".$choice_enums->size()." enumerations");
          foreach my $enum ($choice_enums->get_nodelist()) {
            my $enum_val = $enum->to_literal();
            debugMsg("check_configuration: Comparing $enum_val");
            $match = 1 if ($enum_val eq $param_value);
            debugMsg("check_configuration: Found a matching spirit:choice/spirit:enumeration") if ($enum_val eq $param_value);
          }

          if ($match == 0) {
            print_error("check_configuration: Found no matching spirit:enumeration in spirit:choiceRef=$choice_name for node: ".$node->nodePath());
            $pass=0;
          }

        } else {
          # Error zero or many matches
          print_error("check_configuration: Found ".$choice_nodes->size()." nodes matching spirit:choiceRef=$choice_name for node: ".$node->nodePath());
          $pass = 0;
        }
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:choiceRef not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:choiceRef not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } # it's okay to not be defined

  ## format
  if (exists $param_attribute{'spirit:format'}) {
    if (defined $param_attribute{'spirit:format'}) {
      if (check_type($param_attribute{'spirit:format'},"format")) {
        debugMsg("check_configuration: spirit:format OKAY");
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:format not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:format not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } else {
    # format not defined, should it be?
    if ($pass) {
      # might be okay if only resolve and dependent defined but nothing else?
      print_error("check_configuration: spirit:format not defined but should be for node: ".$node->nodePath());
      $pass = 0;
    }
  }

  ## id
  if (exists $param_attribute{'spirit:id'}) {
    if (defined $param_attribute{'spirit:id'}) {
      if (check_type($param_attribute{'spirit:id'},"ID")) {
        # valid value
        debugMsg("check_configuration: spirit:id okay");
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:id not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:id not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } # it's okay to not be defined

  ## order
  if (exists $param_attribute{'spirit:order'}) {
    if (defined $param_attribute{'spirit:order'}) {
      if (check_type($param_attribute{'spirit:order'},"float")) {
        # valid value
        debugMsg("check_configuration: spirit:order okay");
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:order not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:order not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } else {
    # it's okay to not be defined if it isn't a user-resolve type
    if ($param_attribute{'spirit:resolve'} =~ /user/) {
      # Erorr - should be present!
      print_error("check_configuration: spirit:order not present for user-defined node: ".$node->nodePath());
      $pass = 0;
    }
  }

  ## configGroups
  if (exists $param_attribute{'spirit:configGroups'}) {
    if (defined $param_attribute{'spirit:configGroups'}) {
      if (check_type($param_attribute{'spirit:configGroups'},"NMTOKENS")) {
        # valid value
        debugMsg("check_configuration: spirit:configGroups okay");
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:configGroups not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:configGroups not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } # it's okay to not be defined

  ## bitStringLength
  if (exists $param_attribute{'spirit:bitStringLength'}) {
    if (defined $param_attribute{'spirit:bitStringLength'}) {
      if (check_type($param_attribute{'spirit:bitStringLength'},"nonNegativeInteger")) {
        # valid value
        if ($param_attribute{'spirit:format'} =~ /bitString/s) {
          # okay to be present
          debugMsg("check_configuration: spirit:bitString okay");
        } else {
          # Error - spirit:format is of the wrong type
          print_error("check_configuration: spirit:bitStringLength not valid for spirit:format chosen on node: ".$node->nodePath());
          $pass = 0;
        }
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:bitStringLength not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:bitStringLength not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } # it's okay to not be defined

#   ## rangeType
#   if (exists $param_attribute{'spirit:rangeType'}) {
#     if (defined $param_attribute{'spirit:rangeType'}) {
#       if (check_type($param_attribute{'spirit:rangeType'},"rangeType")) {
#         # valid value
#         if ((defined $param_attribute{'spirit:minimum'}) || (defined $param_attribute{'spirit:maximum'})) {
#           # okay to be present
#           debugMsg("check_configuration: spirit:rangeType okay");
#         } else {
#           # Error - spirit:format is of the wrong type
#           print_error("check_configuration: spirit:rangeType not valid for without one of spirit:maximum or spirit:minimum on node: ".$node->nodePath());
#           $pass = 0;
#         }
#       } else {
#         # Error - not valid type
#         print_error("check_configuration: spirit:rangeType not valid type for node: ".$node->nodePath());
#         $pass = 0;
#       }
#     } else {
#       # Error - present but empty
#       print_error("check_configuration: spirit:rangeType not defined for node: ".$node->nodePath());
#       $pass = 0;
#     }
#   } else { # it's okay to not be defined, but assume int if not
#     if ((defined $param_attribute{'spirit:minimum'}) || (defined $param_attribute{'spirit:maximum'})) {
#       print_warning("check_configuration: spirit:rangeType not defined for node: ".$node->nodePath().", assuming int");
#       $param_attribute{'spirit:rangeType'} = "int";
#     }
#   }
  
  ## minimum
  if (exists $param_attribute{'spirit:minimum'}) {
    if (defined $param_attribute{'spirit:minimum'}) {
      if ($param_attribute{'spirit:format'} =~ /(bitString|float|long)/s) {
        # okay to be present
    if (exists $param_attribute{'spirit:rangeType'}) {
        if (($param_attribute{'spirit:rangeType'} =~ /(int|long)/s ) && (check_type($param_attribute{'spirit:minimum'},"scaledInteger"))) {
          # valid value
          debugMsg("check_configuration: spirit:minimum okay");
        } elsif (($param_attribute{'spirit:rangeType'} =~ /unsigned (int|long)/s ) && (check_type($param_attribute{'spirit:minimum'},"scaledNonNegativeInteger"))) {
          # valid value
          debugMsg("check_configuration: spirit:minimum okay");
        } elsif (check_type($param_attribute{'spirit:minimum'},"float")) {
          # (default) valid value
          debugMsg("check_configuration: spirit:minimum okay");
        } else {
          # Error - not valid type
          print_error("check_configuration: spirit:minimum not valid type for node: ".$node->nodePath());
          $pass = 0;
        }
    }
      } else {
        # Error - spirit:format is of the wrong type
        print_error("check_configuration: spirit:minimum not valid for spirit:format chosen on node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:minimum not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } else {
    # it's okay to not be defined
    # but incase it's needed, we'll force it to the current value
    $param_attribute{'spirit:minimum'} = remove_scaled($param_value);
    # if quoted bitstring transform the number
    if ($param_attribute{'spirit:format'} =~ /bitString/s and $param_value =~ /\"([01]+)\"/) {
      $param_attribute{'spirit:minimum'} = oct("0b$1");
    }
  }

  ## maximum
  if (exists $param_attribute{'spirit:maximum'}) {
    if (defined $param_attribute{'spirit:maximum'}) {
      if ($param_attribute{'spirit:format'} =~ /(bitString|float|long)/s) {
        # okay to be present
    if (exists $param_attribute{'spirit:rangeType'}) {
        if (($param_attribute{'spirit:rangeType'} =~ /(int|long)/s ) && (check_type($param_attribute{'spirit:maximum'},"scaledInteger"))) {
          # valid value
          debugMsg("check_configuration: spirit:maximum okay");
        } elsif (($param_attribute{'spirit:rangeType'} =~ /unsigned (int|long)/s ) && (check_type($param_attribute{'spirit:maximum'},"scaledNonNegativeInteger"))) {
          # valid value
          debugMsg("check_configuration: spirit:maximum okay");
        } elsif (check_type($param_attribute{'spirit:maximum'},"float")) {
          # (default) valid value
          debugMsg("check_configuration: spirit:maximum okay");
        } else {
          # Error - not valid type
          print_error("check_configuration: spirit:maximum not valid type for node: ".$node->nodePath());
          $pass = 0;
        }
        }
      } else {
        # Error - spirit:format is of the wrong type
        print_error("check_configuration: spirit:maximum not valid for spirit:format chosen on node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:maximum not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } else {
    # it's okay to not be defined
    # but incase it's needed, we'll force it to the current value
    $param_attribute{'spirit:maximum'} = remove_scaled($param_value);
    # if quoted bitstring transform the number
    if ($param_attribute{'spirit:format'} =~ /bitString/s and $param_value =~ /\"([01]+)\"/) {
      $param_attribute{'spirit:maximum'} = oct("0b$1");
    }
  }

  ## prompt
  if (exists $param_attribute{'spirit:prompt'}) {
    if (defined $param_attribute{'spirit:prompt'}) {
      if (check_type($param_attribute{'spirit:prompt'},"string")) {
        # valid value
        if ($param_attribute{'spirit:resolve'} =~ /user/s) {
          # okay to be present
          debugMsg("check_configuration: spirit:prompt okay");
        } else {
          # Error - spirit:format is of the wrong type
          print_error("check_configuration: spirit:prompt not valid with chosen spirit:resolve on node: ".$node->nodePath());
          $pass = 0;
        }
      } else {
        # Error - not valid type
        print_error("check_configuration: spirit:prompt not valid type for node: ".$node->nodePath());
        $pass = 0;
      }
    } else {
      # Error - present but empty
      print_error("check_configuration: spirit:prompt not defined for node: ".$node->nodePath());
      $pass = 0;
    }
  } # it's okay to not be defined


  ## If everything is okay so far, check the value matches the constraints...
  # types of format= bitString, bool, float, long, string
  if ($pass) {
  SWITCH: {
      if ($param_attribute{'spirit:format'} =~ /bitString/) {
            print "...0 : " . $node->nodePath() . "\n";
        # needs to be either verilog (4'b0101010) or VHDL ("10101"), be within the minimum & maximum and of bitStringLength long
        # if ($param_value =~ /([0-9]+)b([01]+)/s ) {
        # if ($param_value =~ /([01]+)/s ) {
        #   # verilog
        #   $param_value = oct("0b$2"); # cast binary to decimal
        #   if (($param_value >= $param_attribute{'spirit:minimum'}) && ($param_value <= $param_attribute{'spirit:maximum'})) {
        #     # okay
        #     debugMsg("check_configuration: value okay");
        #   } else {
        #     # out of range
        #     print_error("check_configuration: \"".$param_value."\" is outside of minimum/maximum at node: ".$node->nodePath());
        #     $pass = 0;
        #   }
        # } elsif ($param_value =~ /\"([01]+)\"/s ) {
        if ($param_value =~ /\"([01]+)\"/s ) {
            print "...1\n";
          # VHDL
          $param_value = oct("0b$1"); # cast binary to decimal
          if (($param_value >= $param_attribute{'spirit:minimum'}) && ($param_value <= $param_attribute{'spirit:maximum'})) {
            # okay
            debugMsg("check_configuration: value okay");
          } else {
            # out of range
            print_error("check_configuration: \"".$param_value."\" is outside of minimum/maximum at node: ".$node->nodePath());
            $pass = 0;
          }
        } elsif (check_type($param_value,"scaledInteger")) {
            print "...2\n";
          # scaledInteger
          $param_value = remove_scaled($param_value); # cast to integer
          $param_attribute{'spirit:minimum'} = remove_scaled($param_attribute{'spirit:minimum'}); # cast to integer
          $param_attribute{'spirit:maximum'} = remove_scaled($param_attribute{'spirit:maximum'}); # cast to integer
          if (($param_value >= $param_attribute{'spirit:minimum'}) && ($param_value <= $param_attribute{'spirit:maximum'})) {
            # okay
            debugMsg("check_configuration: value okay");
          } else {
            # out of range
            print_error("check_configuration: \"".$param_value."\" is outside of minimum/maximum at node: ".$node->nodePath());
            $pass = 0;
          }
        } else {
            print "...3\n";
          # unknown
          print_error("check_configuration: unknown value format type for bitString at node: ".$node->nodePath());
          $pass = 0;
        }
        last SWITCH;
      }
      if ($param_attribute{'spirit:format'} =~ /bool/) {
        if ($param_value =~ /^(true|false)$/s ) {
          # okay
          debugMsg("check_configuration: value okay");
        } else {
          print_error("check_configuration: \"".$param_value."\" is not boolean at node: ".$node->nodePath());
          $pass = 0;
        }
        last SWITCH;
      }
      if ($param_attribute{'spirit:format'} =~ /float/) {
        # needs to be a float and be within the minimum & maximum
        if (check_type($param_value,"float")) {
          if (($param_value >= $param_attribute{'spirit:minimum'}) && ($param_value <= $param_attribute{'spirit:maximum'})) {
            # okay
            debugMsg("check_configuration: value okay");
          } else {
            # out of range
            print_error("check_configuration: \"".$param_value."\" is outside of minimum/maximum at node: ".$node->nodePath());
            $pass = 0;
          }
        } else {
          print_error("check_configuration: \"".$param_value."\" is not a valid float at node: ".$node->nodePath());
          $pass = 0;
        }
        last SWITCH;
      }
      if ($param_attribute{'spirit:format'} =~ /long/) {
        # needs to be a long and be within the minimum & maximum
        if (check_type($param_value,"scaledInteger")) {
          # cast to integer
          $param_value = remove_scaled($param_value);
          if (($param_value >= $param_attribute{'spirit:minimum'}) && ($param_value <= $param_attribute{'spirit:maximum'})) {
            # okay
            debugMsg("check_configuration: value okay");
          } else {
            # out of range
            print_error("check_configuration: \"".$param_value."\" is outside of minimum/maximum at node: ".$node->nodePath());
            $pass = 0;
          }
        } else {
          print_error("check_configuration: \"".$param_value."\" is not a valid long at node: ".$node->nodePath());
          $pass = 0;
        }
        last SWITCH;
      }
      if ($param_attribute{'spirit:format'} =~ /string/) {
        # anything passes string!
        last SWITCH;
      }
      $pass = 0;
      print_error("check_configuration: could not check value ".$node->nodePath());
    } # SWITCH
  } # ($pass)

  return $pass;

}

#################################################################################
# Routine : check_type
#    Check that a given value is permitted within the defined type
#
# Arguments :
#    var  - the variable to check
#    type - the defined type to check against
#           supported types:
#
# Returns : boolean result of test
#################################################################################
sub check_type($$) {
  my $var = shift;  # item to check
  my $type = shift; # type to check against
  my $result = 0;

  $type =~ tr/A-Z/a-z/; # just convert the case to allow a bit more flexibility

 SWITCH: {
    $result = 1, last SWITCH if (($type eq 'resolve') && ($var =~ /^(immediate|user|dependent|generated)$/s));
    $result = 1, last SWITCH if (($type eq 'rangetype') && ($var =~ /^(float|int|unsigned int|long|unsigned long)$/s ));
    $result = 1, last SWITCH if (($type eq 'format') && ($var =~ /^(bitString|bool|float|long|string)$/s ));

    $result = 1, last SWITCH if (($type eq 'id') && ($var =~ /^\s*([a-zA-Z:_]{1}[a-zA-Z0-9:_\-.]*)\s*$/s));
    $result = 1, last SWITCH if (($type eq 'name') && ($var =~ /^\s*[a-zA-Z_]{1}[a-zA-Z0-9_\-.]*\s*$/s ));

    $result = 1, last SWITCH if (($type eq 'nmtokens') && ($var =~ /^[a-zA-Z0-9:_\-. ]+$/s )); # collection of strings
    $result = 1, last SWITCH if (($type eq 'nmtoken') && ($var =~ /^[a-zA-Z0-9:_\-. ]+$/s )); # collection of strings

    $result = 1, last SWITCH if (($type eq 'float') && ($var =~ /^(NaN|INF|-INF|([+-]?((([0-9]+(\.)?)|([0-9]*\.[0-9]+))([eE][+-]?[0-9]+)?)))$/s ));
    $result = 1, last SWITCH if (($type eq 'nonnegativeinteger') && ($var =~ /^[0-9]+$/s ));
    $result = 1, last SWITCH if (($type eq 'positiveinteger') && ($var =~ /^[1-9]?[0-9]*$/s ));

    $result = 1, last SWITCH if (($type eq 'scaledinteger') && ($var =~ /^[-+]?(([0-9]+)|((0x|#)?([0-9a-fA-F]+)))[KMGTkgmt]?$/s ));
    $result = 1, last SWITCH if (($type eq 'scalednonnegativeinteger') && ($var =~ /^[+]?(([0-9]+)|((0x|#)?([0-9a-fA-F]+)))[KMGTkgmt]?$/s ));
    $result = 1, last SWITCH if (($type eq 'scaledpositiveinteger') && ($var =~ /^[+]?(([1-9]?[0-9]*)|((0x|#)?([1-9a-fA-F]?[0-9a-fA-F]*)))[KMGTkgmt]?$/s));

    $result = 1, last SWITCH if (($type eq 'string') && ($var =~ /^.*$/s ));
    $result = 1, last SWITCH if (($type eq 'token') && ($var =~ /^.*$/s )); # only used differently to string
  }

  return $result;

}


#################################################################################
# Routine : remove_scaled
#    Given a scaledInteger, scaledNonNegativeInteger or a scaledPositiveInteger
#    remove the scaling and simply pass back an integer
#
# Arguments :
#    scaled integer (decimal or hex values)
#
# Returns : integer
#################################################################################
sub remove_scaled($) {
  my $scaledInt = shift;
  my $int;
  my $mult;

  if ($scaledInt =~ /^([-+]?)([0-9]+)$/s) {
    # simple integer
    if ($1 eq "-") {
      $int = 0 - $2;
    } else {
      $int = $2
    }
  } elsif ($scaledInt =~ /^([-+]?)(0x|#)?([0-9a-fA-F]+)$/s) {
    # simple hex
    if ($1 =~ /-/ ) {
      $int = 0 - hex($3);
    } else {
      $int = hex($3)
    }
  } elsif ($scaledInt =~ /^([-+]?)([0-9]+)([KMGTkgmt])$/s) {
    # scaled integer
  SWITCH: {
      $mult = 1024, last SWITCH if ($3 =~ /[Kk]/);
      $mult = 1024*1024, last SWITCH if ($3 =~ /[Mm]/);
      $mult = 1024*1024*1024, last SWITCH if ($3 =~ /[Gg]/);
      $mult = 1024*1024*1024*1024, last SWITCH if ($3 =~ /[Tt]/);
    }
    if ($1 =~ /-/ ) {
      $int = 0 - ( $mult * $2 );
    } else {
      $int = $mult * $2;
    }
  } elsif ($scaledInt =~ /^([-+]?)(0x|#)?([0-9a-fA-F]+)([KMGTkgmt])$/s) {
    # scaled hex (sounds wrong but is technically legal!)
  SWITCH: {
      $mult = 1024, last SWITCH if ($4 =~ /[Kk]/);
      $mult = 1024*1024, last SWITCH if ($4 =~ /[Mm]/);
      $mult = 1024*1024*1024, last SWITCH if ($4 =~ /[Gg]/);
      $mult = 1024*1024*1024*1024, last SWITCH if ($4 =~ /[Tt]/);
    }
    if ($1 =~ /-/ ) {
      $int = 0 - ( $mult * hex($3) );
    } else {
      $int = $mult * hex($3);
    }
  } else {
    # if in doubt, just send it out!
    $int = $scaledInt;
  }

  debugMsg("remove_scaled: returning = $int");
  return $int;

}

#################################################################################
# Routine : get_child_element
#    Given an element (node), find the child(ren) with the defined name
#
# Arguments :
#    Element start point
#    XPath expression
#
# Returns :
#################################################################################
sub get_child_element($$) {
  my $start_node = shift; # XML::LibXML::Node
  my $find_node = shift; # string (psuedo Xpath expression)
  my $destination_node;

  my @starting_nodes = ($start_node);
  my @node_tree = split("/", $find_node);
  my @destination_nodes;

  foreach my $next_find_node (@node_tree) {

    @destination_nodes = ();

    foreach $start_node (@starting_nodes) {
      foreach my $child ($start_node->childNodes()) {

        # only check it if it's an element node
        if ( ($child->nodeType == XML::LibXML::XML_ELEMENT_NODE) &&
             ($child->nodeName eq $next_find_node)    ) {
          push (@destination_nodes, $child);
        }
      }
    }
    @starting_nodes = @destination_nodes;
  }

  if (scalar(@destination_nodes) == 1) {
    $destination_node = $destination_nodes[0];
  }

  if (scalar(@destination_nodes) > 1) {
    return @destination_nodes;
  }

  return $destination_node;
}

#################################################################################
# Routine : check_XML
#    Given a filename, check that it is a valid XML file
#
# Arguments :
#    filename - name of a file to open
#
# Returns :
#  pointer to a valid IP-XACT Doc object
#  (or null if failure)
#################################################################################
sub check_XML($) {

  my $filename = shift;
  my $XML_file;
  my $XML_text;
  my $parser = XML::LibXML->new();
  my $okay = 1;

  if (!$filename) {
    print_error("No file specified");
    # critical error
    $okay = 0;
  } else {
    # reference valid, check file is okay
    if (check_file($filename)) {
      # file exists, check it's XML
      # initialize parser object and parse the string
      $XML_text = get_file($filename);
      eval { $XML_file = $parser->parse_string( $XML_text ); };

      # report any error that stopped parsing, or announce success
      if( $@ ) {
        $@ =~ s/at \/.*?$//s;               # remove module line number
        debugMsg("Invalid XML in '$filename':\n$@\n");
        $okay = 0;
      }

    }
  }

  return $XML_file;
}

#################################################################################
# Routine : check_file
#    Checks that a file exists
#
# Arguments :
#    file   filename to look for
#
# Return : 1 on success else 0
#################################################################################
sub check_file ($) {

  my $file = shift;
  my $okay = 1;

  if ($file =~ m#^http://# ) {
    my $cmd_args;
    eval { $cmd_args = `$svncmd info $file`};
    if ( $@ ) {
      print_error("check_file: could not locate file in SVN: $file");
      # critical error
      $okay = '';
    }
  } else {
    # real file!
    if (!-e $file) {
      print_error("check_file: could not locate file in the file-system: $file");
      # critical error
      $okay = '';
    }
  }

  return $okay;
}

#################################################################################
# Routine : get_file
#    returns the contents of a file
#
# Arguments :
#    file   filename to open
#
# Return : file contents or null
#################################################################################
sub get_file ($) {

  my $file = shift;

  my $data;

  if ($file =~ m#^http://# ){
    $data = `svn cat --no-auth-cache $file`;
  } else {
    $data = `cat $file`;
  }

  return $data;

}

#################################################################################
# Routine : print_error
#    Prints a message to the screen as an error
#
# Arguments :
#    msg   string to print to screen
#
# Return : Nothing
#################################################################################
sub print_error($) {

  my $message = shift;

  if ($wiki) {
    # Display suitable for wiki pages
    print "%RED%".$message."%ENDCOLOR% </br>";
  } elsif ($html) {
    # Display suitable for HTML pages
    print "<font color=\"red\"><b>ERROR: </b>".$message."</font></br>\n";
  } else {
    # No formatting
    print "$0 ERROR: $message\n";
  }

  return 1;
}

#################################################################################
# Routine : print_warning
#    Prints a message to the screen as a warning
#
# Arguments :
#    msg   string to print to screen
#
# Return : 1
#################################################################################
sub print_warning($) {

  my $message = shift;

  if ($wiki) {
    # Display suitable for wiki pages
    print "%orange% WARNING: ".$message."%ENDCOLOR% </br>";
  } elsif ($html) {
    # Display suitable for HTML pages
    print "<font color=\"orange\">Warning: ".$message."</font></br>\n";
  } else {
    # No formatting
    print "$0 WARNING: $message\n";
  }

  return 1;
}

#################################################################################
# Routine : print_info
#    Prints a message to the screen as a info
#
# Arguments :
#    msg   string to print to screen
#
# Return : Nothing
#################################################################################
sub print_info($) {

  my $message = shift;

  if ($wiki) {
    # Display suitable for wiki pages
    print "%green% info: ".$message."%ENDCOLOR% </br>";
  } elsif ($html) {
    # Display suitable for HTML pages
    print "<font color=\"green\">info: ".$message."</font></br>\n";
  } else {
    # No formatting
    print "$0 INFO: $message\n";
  }

  return 1;
}

#################################################################################
# Routine : debugMsg
#    Prints a message to the screen for debug
#
# Arguments :
#    msg   string to print to screen
#
# Vars needed:
#    $debug   if in debug mode ($debug = 1) then the message is displayed.
#
# Return : Nothing
#################################################################################
sub debugMsg($) {

  my $debug_string = shift;

  if ($debug) {
    if ($wiki) {
      print "%GRAY% DEBUG: " . $debug_string . "%ENDCOLOR%\n";
    } elsif ($html) {
      print "<font size=\"1\" color=\"gray\"> DEBUG: " . $debug_string ."</font></br>\n";
    } else {
      print " DEBUG: " . $debug_string."\n";
    }
  }

  return 1;
}

#####################
1;
