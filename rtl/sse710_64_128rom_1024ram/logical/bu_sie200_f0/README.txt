// -----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//            (C) COPYRIGHT 2015-2017 ARM Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited or its affiliates.
//
//-----------------------------------------------------------------------------
// Description : README File for SIE-200 IPXACT Flow
//-----------------------------------------------------------------------------

The IPXACT generation flow uses the "generate" python script to create configured
IPXACT description for each component. For information on how to use it, see the
help command for that script.
As for the RTL file generation the only component with generated RTL is the
ahb5_busmatrix, all other components have a simple copy of the RTL which can be
configured by top level parameters after instantiation.
User must take caution when not using a sticher tool with the configured IPXACT
definition to create a system as the parameter settings in the copied RTL files
need to be edited manually to match with the parameters in the configured IPXACT.
