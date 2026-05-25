//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2015 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2014-07-02 16:52:21 +0100 (Wed, 02 Jul 2014) $
//
//      Revision            : $Revision: 283836 $
//
//      Release Information : CORTEXA53-r0p4-51rel0
//
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : LDM/STM register list register extraction logic
//-----------------------------------------------------------------------------
//
// Overview
// --------
//
// Given a 16-bit mask representing programmer's register numbers to be accessed
// this module generates:
//
//  - A new register list
//  - A 4 bit value containing the first register removed from the list
//  - A 4 bit value containing the second register removed from the list
//
//-----------------------------------------------------------------------------

`include "ca53dpu_params.v"
`include "cortexa53params.v"

module ca53dpu_search_rl (
  // Inputs
  input  wire  [15:0] register_list_i,
  input  wire  [11:0] exp_cpsr_mode_de_i,
  // Outputs
  output wire  [13:0] nxt_lsm_state_ls_o,
  output wire   [4:0] ldm_1st_register_ls_o,
  output wire   [5:0] stm_1st_register_usr_ls_o,
  output wire   [5:0] stm_1st_register_all_ls_o,
  output wire   [4:0] ldm_2nd_register_ls_o,
  output wire   [5:0] stm_2nd_register_usr_ls_o,
  output wire   [5:0] stm_2nd_register_all_ls_o
);

  // -----------------------------
  // Wire declarations
  // -----------------------------

  wire  [5:0] nibble0_1st_register;
  wire  [5:0] nibble0_2nd_register;
  wire  [5:0] nibble1_1st_register;
  wire  [5:0] nibble1_2nd_register;
  wire  [4:0] nibble2_1st_register_vir;
  wire  [5:0] nibble2_1st_register_usr;
  wire  [5:0] nibble2_1st_register_all;
  wire  [4:0] nibble2_2nd_register_vir;
  wire  [5:0] nibble2_2nd_register_usr;
  wire  [5:0] nibble2_2nd_register_all;
  wire  [4:0] nibble3_1st_register_vir;
  wire  [5:0] nibble3_1st_register_usr;
  wire  [5:0] nibble3_1st_register_all;
  wire  [4:0] nibble3_2nd_register_vir;
  wire  [5:0] nibble3_2nd_register_usr;
  wire  [5:0] nibble3_2nd_register_all;
  wire  [3:0] found_1st_nibble;
  wire  [3:0] found_2nd_nibble;
  wire  [3:0] list_sel;
  wire  [2:0] nibble0_intermediate_list;
  wire  [1:0] nibble0_final_list;
  wire  [2:0] nibble1_intermediate_list;
  wire  [1:0] nibble1_final_list;
  wire  [2:0] nibble2_intermediate_list;
  wire  [1:0] nibble2_final_list;
  wire  [2:0] nibble3_intermediate_list;
  wire  [1:0] nibble3_final_list;
  wire        only_one_in_3to0;
  wire        only_one_in_7to0;
  wire        only_one_in_11to0;
  wire  [5:0] mode_adjusted_r08;
  wire  [5:0] mode_adjusted_r09;
  wire  [5:0] mode_adjusted_r10;
  wire  [5:0] mode_adjusted_r11;
  wire  [5:0] mode_adjusted_r12;
  wire  [5:0] mode_adjusted_r13;
  wire  [5:0] mode_adjusted_r14;

  //
  // ---------------------------------------------------------
  // Main Code
  // ---------------------------------------------------------
  //

  // ------------------------------------------------------
  // Parse first nibble
  // ------------------------------------------------------

  // Create an intermediate list assuming that there is a register in this nibble
  assign nibble0_intermediate_list = {((|register_list_i[2:0]) & register_list_i[3]),
                                      ((|register_list_i[1:0]) & register_list_i[2]),
                                      (( register_list_i[  0]) & register_list_i[1])};

  // Search the intermediate list for another register to create a final list
  assign nibble0_final_list = {((|nibble0_intermediate_list[1:0]) & nibble0_intermediate_list[2]),
                               (( nibble0_intermediate_list[  0]) & nibble0_intermediate_list[1])};

  // Extract first and second registers
  assign nibble0_1st_register[5:0] = register_list_i[0] ? `CA53_ADDR_R00 :
                                     register_list_i[1] ? `CA53_ADDR_R01 :
                                     register_list_i[2] ? `CA53_ADDR_R02 :
                                                          `CA53_ADDR_R03;

  assign nibble0_2nd_register[5:0] = nibble0_intermediate_list[0] ? `CA53_ADDR_R01 :
                                     nibble0_intermediate_list[1] ? `CA53_ADDR_R02 :
                                                                    `CA53_ADDR_R03;

  // Find out if either list contains a register
  assign found_1st_nibble[0] = |register_list_i[3:0];
  assign found_2nd_nibble[0] = |nibble0_intermediate_list[2:0];

  // ------------------------------------------------------
  // Parse second nibble
  // ------------------------------------------------------

  // Create an intermediate list assuming that there is a register in this nibble.
  // Search the intermediate list for another register to create a final list.
  assign nibble1_intermediate_list = {((|register_list_i[6:4]) & register_list_i[7]),
                                      ((|register_list_i[5:4]) & register_list_i[6]),
                                      (( register_list_i[  4]) & register_list_i[5])};

  assign nibble1_final_list = {((|nibble1_intermediate_list[1:0]) & nibble1_intermediate_list[2]),
                               (( nibble1_intermediate_list[  0]) & nibble1_intermediate_list[1])};

  // Extract first and second registers
  assign nibble1_1st_register[5:0] = register_list_i[4] ? `CA53_ADDR_R04 :
                                     register_list_i[5] ? `CA53_ADDR_R05 :
                                     register_list_i[6] ? `CA53_ADDR_R06 :
                                                          `CA53_ADDR_R07;

  assign nibble1_2nd_register[5:0] = nibble1_intermediate_list[0] ? `CA53_ADDR_R05 :
                                     nibble1_intermediate_list[1] ? `CA53_ADDR_R06 :
                                                                    `CA53_ADDR_R07;

  // Find out if either list contains a register
  assign found_1st_nibble[1] = |register_list_i[7:4];
  assign found_2nd_nibble[1] = |nibble1_intermediate_list[2:0];

  // ------------------------------------------------------
  // Parse third nibble
  // ------------------------------------------------------

  // Create an intermediate list assuming that there is a register in this nibble.
  // Search the intermediate list for another register to create a final list.
  assign nibble2_intermediate_list = {((|register_list_i[10:8]) & register_list_i[11]),
                                      ((|register_list_i[ 9:8]) & register_list_i[10]),
                                      (( register_list_i[   8]) & register_list_i[9])};

  assign nibble2_final_list = {((|nibble2_intermediate_list[1:0]) & nibble2_intermediate_list[2]),
                               (( nibble2_intermediate_list[  0]) & nibble2_intermediate_list[1])};

  // Adjust the source register depending on the mode
  assign mode_adjusted_r08 = exp_cpsr_mode_de_i[1] ? `CA53_ADDR_R08_FIQ : `CA53_ADDR_R08;
  assign mode_adjusted_r09 = exp_cpsr_mode_de_i[1] ? `CA53_ADDR_R09_FIQ : `CA53_ADDR_R09;
  assign mode_adjusted_r10 = exp_cpsr_mode_de_i[1] ? `CA53_ADDR_R10_FIQ : `CA53_ADDR_R10;
  assign mode_adjusted_r11 = exp_cpsr_mode_de_i[1] ? `CA53_ADDR_R11_FIQ : `CA53_ADDR_R11;

  // Extract first register, virtual address format
  assign nibble2_1st_register_vir[4:0] = register_list_i[ 8] ? `CA53_VADDR_R08 :
                                         register_list_i[ 9] ? `CA53_VADDR_R09 :
                                         register_list_i[10] ? `CA53_VADDR_R10 :
                                                               `CA53_VADDR_R11;

  // Extract first register, physical address format, user mode
  assign nibble2_1st_register_usr[5:0] = register_list_i[ 8] ? `CA53_ADDR_R08 :
                                         register_list_i[ 9] ? `CA53_ADDR_R09 :
                                         register_list_i[10] ? `CA53_ADDR_R10 :
                                                               `CA53_ADDR_R11;

  // Extract first register, physical address format, all modes
  assign nibble2_1st_register_all[5:0] = register_list_i[ 8] ? mode_adjusted_r08 :
                                         register_list_i[ 9] ? mode_adjusted_r09 :
                                         register_list_i[10] ? mode_adjusted_r10 :
                                                               mode_adjusted_r11;

  // Extract second register, virtual address format
  assign nibble2_2nd_register_vir[4:0] = nibble2_intermediate_list[0] ? `CA53_VADDR_R09 :
                                         nibble2_intermediate_list[1] ? `CA53_VADDR_R10 :
                                                                        `CA53_VADDR_R11;

  // Extract second register, physical address format, user mode
  assign nibble2_2nd_register_usr[5:0] = nibble2_intermediate_list[0] ? `CA53_ADDR_R09 :
                                         nibble2_intermediate_list[1] ? `CA53_ADDR_R10 :
                                                                        `CA53_ADDR_R11;

  // Extract second register, physical address format, all modes
  assign nibble2_2nd_register_all[5:0] = nibble2_intermediate_list[0] ? mode_adjusted_r09 :
                                         nibble2_intermediate_list[1] ? mode_adjusted_r10 :
                                                                        mode_adjusted_r11;

  // Find out if either list contains a register
  assign found_1st_nibble[2] = |register_list_i[11:8];
  assign found_2nd_nibble[2] = |nibble2_intermediate_list[2:0];

  // ------------------------------------------------------
  // Parse fourth nibble
  // ------------------------------------------------------

  // Create an intermediate list assuming that there is a register in this nibble.
  // Search the intermediate list for another register to create a final list.
  assign nibble3_intermediate_list = {((|register_list_i[14:12]) & register_list_i[15]),
                                      ((|register_list_i[13:12]) & register_list_i[14]),
                                      (( register_list_i[   12]) & register_list_i[13])};

  assign nibble3_final_list = {((|nibble3_intermediate_list[1:0]) & nibble3_intermediate_list[2]),
                               (( nibble3_intermediate_list[  0]) & nibble3_intermediate_list[1])};

  // Adjust the source register depending on the mode
  assign mode_adjusted_r12 =      exp_cpsr_mode_de_i[1]   ? `CA53_ADDR_R12_FIQ : `CA53_ADDR_R12;

  assign mode_adjusted_r13 = (({6{exp_cpsr_mode_de_i[0]}} & `CA53_ADDR_R13    ) |
                              ({6{exp_cpsr_mode_de_i[1]}} & `CA53_ADDR_R13_FIQ) |
                              ({6{exp_cpsr_mode_de_i[2]}} & `CA53_ADDR_R13_IRQ) |
                              ({6{exp_cpsr_mode_de_i[3]}} & `CA53_ADDR_R13_SVC) |
                              ({6{exp_cpsr_mode_de_i[4]}} & `CA53_ADDR_R13_ABT) |
                              ({6{exp_cpsr_mode_de_i[5]}} & `CA53_ADDR_R13_UND) |
                              ({6{exp_cpsr_mode_de_i[6]}} & `CA53_ADDR_R13_MON) |
                              ({6{exp_cpsr_mode_de_i[7]}} & `CA53_ADDR_R13_HYP));

  assign mode_adjusted_r14 = (({6{exp_cpsr_mode_de_i[0]}} & `CA53_ADDR_R14    ) |
                              ({6{exp_cpsr_mode_de_i[1]}} & `CA53_ADDR_R14_FIQ) |
                              ({6{exp_cpsr_mode_de_i[2]}} & `CA53_ADDR_R14_IRQ) |
                              ({6{exp_cpsr_mode_de_i[3]}} & `CA53_ADDR_R14_SVC) |
                              ({6{exp_cpsr_mode_de_i[4]}} & `CA53_ADDR_R14_ABT) |
                              ({6{exp_cpsr_mode_de_i[5]}} & `CA53_ADDR_R14_UND) |
                              ({6{exp_cpsr_mode_de_i[6]}} & `CA53_ADDR_R14_MON) |
                              ({6{exp_cpsr_mode_de_i[7]}} & `CA53_ADDR_R14    ));

  // Extract first register, virtual address format
  assign nibble3_1st_register_vir[4:0] = register_list_i[12] ? `CA53_VADDR_R12 :
                                         register_list_i[13] ? `CA53_VADDR_R13 :
                                         register_list_i[14] ? `CA53_VADDR_R14 :
                                                               `CA53_VADDR_R15;

  // Extract first register, physical address format, user mode
  assign nibble3_1st_register_usr[5:0] = register_list_i[12] ? `CA53_ADDR_R12 :
                                         register_list_i[13] ? `CA53_ADDR_R13 :
                                         register_list_i[14] ? `CA53_ADDR_R14 :
                                                               {6{1'b0}};

  // Extract first register, physical address format, all modes
  assign nibble3_1st_register_all[5:0] = register_list_i[12] ? mode_adjusted_r12 :
                                         register_list_i[13] ? mode_adjusted_r13 :
                                         register_list_i[14] ? mode_adjusted_r14 :
                                                               {6{1'b0}};

  // Extract second register, virtual address format
  assign nibble3_2nd_register_vir[4:0] = nibble3_intermediate_list[0] ? `CA53_VADDR_R13 :
                                         nibble3_intermediate_list[1] ? `CA53_VADDR_R14 :
                                                                        `CA53_VADDR_R15;

  // Extract second register, physical address format, user mode
  assign nibble3_2nd_register_usr[5:0] = nibble3_intermediate_list[0] ? `CA53_ADDR_R13 :
                                         nibble3_intermediate_list[1] ? `CA53_ADDR_R14 :
                                                                        {6{1'b0}};

  // Extract second register, physical address format, all modes
  assign nibble3_2nd_register_all[5:0] = nibble3_intermediate_list[0] ? mode_adjusted_r13 :
                                         nibble3_intermediate_list[1] ? mode_adjusted_r14 :
                                                                        {6{1'b0}};

  // Find out if either list contains a register
  assign found_1st_nibble[3] = |register_list_i[15:12];
  assign found_2nd_nibble[3] = |nibble3_intermediate_list[2:0];

  // ------------------------------------------------------
  // Distribution check
  // ------------------------------------------------------

  // Find out how registers are distributed in the list. This affects which list search
  // we use from subsequent nibbles (register_list_i or *_intermediate_list)

  // Find out if there is only a single register in register_list_i[11:0]
  assign only_one_in_11to0 = ((register_list_i[11:0] == 12'b1000_0000_0000) |
                              (register_list_i[11:0] == 12'b0100_0000_0000) |
                              (register_list_i[11:0] == 12'b0010_0000_0000) |
                              (register_list_i[11:0] == 12'b0001_0000_0000) |
                              (register_list_i[11:0] == 12'b0000_1000_0000) |
                              (register_list_i[11:0] == 12'b0000_0100_0000) |
                              (register_list_i[11:0] == 12'b0000_0010_0000) |
                              (register_list_i[11:0] == 12'b0000_0001_0000) |
                              (register_list_i[11:0] == 12'b0000_0000_1000) |
                              (register_list_i[11:0] == 12'b0000_0000_0100) |
                              (register_list_i[11:0] == 12'b0000_0000_0010) |
                              (register_list_i[11:0] == 12'b0000_0000_0001));

  // Find out if there is only a single register in register_list_i[7:0]
  assign only_one_in_7to0 = ((register_list_i[7:0] == 8'b1000_0000) |
                             (register_list_i[7:0] == 8'b0100_0000) |
                             (register_list_i[7:0] == 8'b0010_0000) |
                             (register_list_i[7:0] == 8'b0001_0000) |
                             (register_list_i[7:0] == 8'b0000_1000) |
                             (register_list_i[7:0] == 8'b0000_0100) |
                             (register_list_i[7:0] == 8'b0000_0010) |
                             (register_list_i[7:0] == 8'b0000_0001));

  // Find out if there is only a single register in register_list_i[3:0]
  assign only_one_in_3to0 = ((register_list_i[3:0] == 4'b1000) |
                             (register_list_i[3:0] == 4'b0100) |
                             (register_list_i[3:0] == 4'b0010) |
                             (register_list_i[3:0] == 4'b0001));

  // ------------------------------------------------------
  // Extract first register
  // ------------------------------------------------------

  // LDM, virtual address format
  assign ldm_1st_register_ls_o[4:0] = found_1st_nibble[0] ? nibble0_1st_register[4:0] :
                                      found_1st_nibble[1] ? nibble1_1st_register[4:0] :
                                      found_1st_nibble[2] ? nibble2_1st_register_vir[4:0] :
                                                            nibble3_1st_register_vir[4:0];

  // STM, physical address format, user mode
  assign stm_1st_register_usr_ls_o[5:0] = found_1st_nibble[0] ? nibble0_1st_register[5:0] :
                                          found_1st_nibble[1] ? nibble1_1st_register[5:0] :
                                          found_1st_nibble[2] ? nibble2_1st_register_usr[5:0] :
                                                                nibble3_1st_register_usr[5:0];

  // STM, physical address format, all modes
  assign stm_1st_register_all_ls_o[5:0] = found_1st_nibble[0] ? nibble0_1st_register[5:0] :
                                          found_1st_nibble[1] ? nibble1_1st_register[5:0] :
                                          found_1st_nibble[2] ? nibble2_1st_register_all[5:0] :
                                                                nibble3_1st_register_all[5:0];

  // ------------------------------------------------------
  // Extract second register
  // ------------------------------------------------------

  // Create selection signal to extract the second register and the next LSM state
  assign list_sel = {(only_one_in_11to0 ? found_1st_nibble[3] : found_2nd_nibble[3]),
                     (only_one_in_7to0  ? found_1st_nibble[2] : found_2nd_nibble[2]),
                     (only_one_in_3to0  ? found_1st_nibble[1] : found_2nd_nibble[1]),
                     (                                          found_2nd_nibble[0])};

  // LDM, virtual address format
  assign ldm_2nd_register_ls_o[4:0] = list_sel[0] ? (                                                    nibble0_2nd_register[4:0]    ) :
                                      list_sel[1] ? (only_one_in_3to0  ? nibble1_1st_register[4:0]     : nibble1_2nd_register[4:0]    ) :
                                      list_sel[2] ? (only_one_in_7to0  ? nibble2_1st_register_vir[4:0] : nibble2_2nd_register_vir[4:0]) :
                                                    (only_one_in_11to0 ? nibble3_1st_register_vir[4:0] : nibble3_2nd_register_vir[4:0]);

  // STM, physical address format, user mode
  assign stm_2nd_register_usr_ls_o[5:0] = list_sel[0] ? (                                                    nibble0_2nd_register[5:0]    ) :
                                          list_sel[1] ? (only_one_in_3to0  ? nibble1_1st_register[5:0]     : nibble1_2nd_register[5:0]    ) :
                                          list_sel[2] ? (only_one_in_7to0  ? nibble2_1st_register_usr[5:0] : nibble2_2nd_register_usr[5:0]) :
                                                        (only_one_in_11to0 ? nibble3_1st_register_usr[5:0] : nibble3_2nd_register_usr[5:0]);

  // STM, physical address format, all modes
  assign stm_2nd_register_all_ls_o[5:0] = list_sel[0] ? (                                                    nibble0_2nd_register[5:0]    ) :
                                          list_sel[1] ? (only_one_in_3to0  ? nibble1_1st_register[5:0]     : nibble1_2nd_register[5:0]    ) :
                                          list_sel[2] ? (only_one_in_7to0  ? nibble2_1st_register_all[5:0] : nibble2_2nd_register_all[5:0]) :
                                                        (only_one_in_11to0 ? nibble3_1st_register_all[5:0] : nibble3_2nd_register_all[5:0]);

  // ------------------------------------------------------
  // Create the new register list for the next cycle
  // ------------------------------------------------------

  assign nxt_lsm_state_ls_o[13:0]
          = list_sel[0] ? {register_list_i[15:4],                                                            nibble0_final_list                     } :
            list_sel[1] ? {register_list_i[15:8],  (only_one_in_3to0  ? {nibble1_intermediate_list, 1'b0} : {nibble1_final_list, 2'b00}),  {2{1'b0}}} :
            list_sel[2] ? {register_list_i[15:12], (only_one_in_7to0  ? {nibble2_intermediate_list, 1'b0} : {nibble2_final_list, 2'b00}),  {6{1'b0}}} :
                          {                        (only_one_in_11to0 ? {nibble3_intermediate_list, 1'b0} : {nibble3_final_list, 2'b00}), {10{1'b0}}};

endmodule // ca53dpu_search_rl

/*ARMAUTO_UNDEF*/
`define CA53_UNDEFINE
`include "cortexa53params.v"
`include "ca53dpu_params.v"
`undef CA53_UNDEFINE
/*END*/
