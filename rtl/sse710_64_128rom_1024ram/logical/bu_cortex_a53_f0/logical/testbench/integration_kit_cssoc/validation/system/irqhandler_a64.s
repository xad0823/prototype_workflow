//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2013-2014 ARM Limited.
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
//      Release Information : CORTEXA53-r0p4-00rel0
//
//-----------------------------------------------------------------------------

                .section irqhandler, "ax", %progbits 

                .global  curr_el_spx_irq_vector
                .global  curr_el_sp0_irq_vector
                .global  lower_el_aarch64_irq_vector
                .global  lower_el_aarch32_irq_vector
                .weak    IRQHandler_test


curr_el_spx_irq_vector:
     bl   IRQHandler_test
     eret

curr_el_sp0_irq_vector:
     bl   IRQHandler_test
     eret

lower_el_aarch64_irq_vector:
     bl   IRQHandler_test
     eret

lower_el_aarch32_irq_vector:
     bl   IRQHandler_test
     eret

