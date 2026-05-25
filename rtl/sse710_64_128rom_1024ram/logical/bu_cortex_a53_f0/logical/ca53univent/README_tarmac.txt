#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited.
#
#            (C) COPYRIGHT 2013-2015 ARM Limited.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited.
#
#      SVN Information
#
#      Checked In          : $Date: 2013-07-05 11:24:01 +0100 (Fri, 05 Jul 2013) $
#
#      Revision            : $Revision: 253311 $
#
#      Release Information : CORTEXA53-r0p4-51rel0
#
#-----------------------------------------------------------------------------

======================
Tarmac generation flow
======================


Overview
========

During simulation, information captured from internal design signals is processed
to produce text tarmac file(s). This involves following steps:
- Signal values are captured from the design 
- This information is encoded into an "event stream" and sent to a "decoder" sub-process
- The decoder processes the event stream and produces text tarmac file(s)

This relies on two independent pieces of software, released as binaries (Tested on
RHE4 and RHE5 Linux distributions).

The simulator module: ca53_tarmac_dpi.so

This is a module implementing the DPI functions called from the design to
collect information (as a consequence, tarmac relies on SystemVerilog DPI support).
This module needs to be loaded in the simulator and 32-bit and 64-bit versions are
provided. You need to select the right one for your simulator.
It doesn't require any external library (apart from usual glibc).

The decoder tool: ca53_tarmac_decode

This is a 32-bit only executable designed to decode the raw information and
produce tarmac file(s). Since it will always execute in it's own process, the same
ca53_tarmac_decode executable is used with both 64-bit and 32-bit simulations.


External dependencies
=====================

The ca53_tarmac_decode program needs external shared libraries to execute, in particular  
the Google Protocol Buffers runtime libprotobuf.so, as well as more standard ones
(libz.so, libpthread.so, libm.so, libstdc++.so, etc.)

Note that you need 32-bit version of these libraries (usually installed as
compatibility libraries on 64-bit Linux distributions).

If the protocol buffers library is not available on your system, you can download it
and install it yourself (e.g. to install in directory <prefix>):

$ wget http://protobuf.googlecode.com/files/protobuf-2.4.1.tar.gz

(You can use sha1sum to confirm the checksum of the download:
$ sha1sum  protobuf-2.4.1.tar.gz
efc84249525007b1e3105084ea27e3273f7cbfb0  protobuf-2.4.1.tar.gz)

$ tar xzf protobuf-2.4.1.tar.gz
$ cd protobuf-2.4.1
$ ./configure --with-zlib --prefix=<prefix> CXX='g++ -m32'
$ make install

Then add <prefix>/lib to your dynamic linker's search path (e.g. using the
LD_LIBRARY_PATH environment variable).

Building the protocol buffer library as required for the tarmac flow depends on
the zlib library and header files. In Red Hat Linux distributions, these
are provided as part of the zlib-devel package.


Running simulation
==================

The execution testbench can be used as a reference to demonstrate the tarmac flow. 
When integrating the tarmac flow into your simulations there are some points to note:

1) For tarmac generation, the ca53_follower module must be instantiated in the design.
This module collects together the signals required for tarmac reconstruction and performs
some initial reconstruction. It is responsible for calling the DPI functions in
ca53_tarmac_dpi.so. The required verilog file can be added and defines set by including 
the following in a .vc file similar to the execution testbench execution_tb_tarmac.vc file
(replacing <path_to_deliverable> with the path to the cortexa53 directory in your installation
of the Cortex A53 deliverable): 

+define+CORTEXA53_UNIVENT
+define+CORTEXA53_UNIVENT_DPI_CAPTURE

+incdir+<path_to_deliverable>/cortexa53/logical/ca53univent/verilog/
<path_to_deliverable>/cortexa53/logical/ca53univent/verilog/ca53_follower.sv


2) The (32-bit or 64-bit) ca53_tarmac_dpi.so object must be loaded by the simulator. Simulator
specific options are required at either compile or simulation time. In each of the cases
below, replace <32|64> with 32 if using 32-bit simulations or 64 if using 64-bit simulations.

For MTI, use this option when running the simulation:
-sv_lib <path_to_deliverable>/cortexa53/logical/ca53univent/build_x86_<32|64>/lib/ca53_tarmac_dpi 
(Note that no .so file extension is needed with this option)

For VCS, use this option when compiling the rtl: 
-sverilog <path_to_deliverable>/cortexa53/logical/ca53univent/build_x86_<32|64>/lib/ca53_tarmac_dpi.so

For IUS, use this option when compiling the rtl:
-sv <path_to_deliverable>/cortexa53/logical/ca53univent/build_x86_<32|64>/lib/ca53_tarmac_dpi.so


3) You need to ensure the tarmac decoder is available to the simulator module.
Either
3.1) Add the <path_to_deliverable>/cortexa53/logical/ca53_univent/build_x86_32/bin directory to
your PATH environment variable.

or
3.2) Set the CA53_TARMAC_EXECUTABLE environment variable giving the path to the 
ca53_tarmac_decode executable (either the full path or a relative path from the 
simulation directory) and using the --plain argument. I.e. set the  CA53_TARMAC_EXECUTABLE
environment variable to the following value:
<path_to_deliverable>/cortexa53/logical/ca53univent/build_x86_32/bin/ca53_tarmac_decode --plain 

(again replacing <path_to_deliverable> with the path to the cortexa53 directory in your installation
of the Cortex A53 deliverable)

4) When starting your simulation, set the +ca53_tarmac_enable plusarg to enable tarmac
generation.

5) The tarmac log files should be generated in your working directory. By default they
are called ca53_tarmac.<Aff2>.<Aff1>.<Aff0>.log
<Aff2>,<Aff1> and <Aff0> will identify the relevant CPU using the values of the MPIDR Aff fields.
