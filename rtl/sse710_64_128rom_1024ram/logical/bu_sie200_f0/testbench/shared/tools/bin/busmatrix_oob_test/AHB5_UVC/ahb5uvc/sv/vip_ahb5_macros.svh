// *********************************************************************
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited or its affiliates.
//
//             (C) COPYRIGHT 2012-2016 ARM Limited or its affiliates.
//                 ALL RIGHTS RESERVED
//
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited or its affiliates.
//
//   File Revision       :$Revision: $
//   File Date           :$Date: $
//
//   Release Information : CoreLink SIE-200 System IP for Embedded - Global Bundle r3p2-00rel0
//
// *********************************************************************

`ifndef VIP_AHB5_MACROS_SVH
`define VIP_AHB5_MACROS_SVH

    `define VIP_AHB5_SETTER(type, var) \
        virtual function void set_``var(type var``_); \
                var = var``_; \
        endfunction : set_``var

    `define VIP_AHB5_GETTER(type, var) \
        virtual function type get_``var (); \
            return var; \
        endfunction : get_``var \
        virtual function bit is_``var (type var``_); \
            return var == var``_; \
        endfunction : is_``var

    `define VIP_AHB5_FLAG_SETTER(var) \
         virtual function void set_``var(bit flag_ = 1); \
                 var = flag_; \
         endfunction : set_``var

    `define VIP_AHB5_FLAG_GETTER(var) \
        virtual function bit get_``var (); \
            return var; \
        endfunction : get_``var \
        virtual function bit is_``var (); \
            return var; \
        endfunction : is_``var

    `define VIP_AHB5_ACCESSOR(type, var) \
        `VIP_AHB5_SETTER(type, var) \
        `VIP_AHB5_GETTER(type, var)

    `define VIP_AHB5_FLAG_ACCESSOR(var) \
        `VIP_AHB5_FLAG_SETTER(var) \
        `VIP_AHB5_FLAG_GETTER(var)


    `define VIP_AHB5_RANDOMIZE_RANGE(variable, min, max) \
        begin \
            if (!std::randomize(variable)) \
            begin \
                `vip_ahb5_fatal(({ `"variable`", " randomize failed"})) \
            end \
            variable = (variable % (1 + (max) - (min))) + (min); \
        end


    `ifdef VCS

        `define VIP_AHB5_RAND_MODE(a) \
            virtual function void set_``a``_rand(bit enable_); \
                if (enable_) a.rand_mode(1); else a.rand_mode(0); \
            endfunction : set_``a``_rand \
            virtual function bit get_``a``_rand(); \
                return a.rand_mode(); \
            endfunction : get_``a``_rand

        `define VIP_AHB5_CONSTRAINT_MODE(a) \
            virtual function void set_``a``_cmode(bit enable_); \
                if (enable_) a.constraint_mode(1); else a.constraint_mode(0); \
            endfunction : set_``a``_cmode \
            virtual function bit get_``a``_cmode(); \
                return a.constraint_mode(); \
            endfunction : get_``a``_cmode

    `else

        `define VIP_AHB5_RAND_MODE(a) \
            virtual function void set_``a``_rand(bit enable_); \
                a.rand_mode(enable_); \
            endfunction : set_``a``_rand \
            virtual function bit get_``a``_rand(); \
                return a.rand_mode(); \
            endfunction : get_``a``_rand

        `define VIP_AHB5_CONSTRAINT_MODE(a) \
            virtual function void set_``a``_cmode(bit enable_); \
                a.constraint_mode(enable_); \
            endfunction : set_``a``_cmode \
            virtual function bit get_``a``_cmode(); \
                return a.constraint_mode(); \
            endfunction : get_``a``_cmode

    `endif

    `define VIP_AHB5_RAND_SETTER(type, var) \
        virtual function void set_``var(type var``_, bit disable_rand_ = 1); \
                var = var``_; \
                if (disable_rand_) set_``var``_rand(0); \
        endfunction : set_``var

    `define VIP_AHB5_RAND_ACCESSOR(type, var) \
        `VIP_AHB5_RAND_MODE(var) \
        `VIP_AHB5_RAND_SETTER(type, var) \
        `VIP_AHB5_GETTER(type, var)

    `define VIP_AHB5_RAND_MODE_ARRAY_OPTIMISED(a) \
        virtual function void set_``a``_rand(bit enable_, bit all_elements_ = 1, int i_ = 0); \
            a``_rand = enable_; \
        endfunction : set_``a``_rand \
        virtual function bit get_``a``_rand(); \
            return a``_rand; \
        endfunction : get_``a``_rand

    `define VIP_AHB5_STATIC_ARRAY_RAND_ACCESSOR(type, var) \
        function void set_``var(int unsigned i_, type var``_, bit disable_rand_ = 1); \
                var[i_] = var``_; \
                if (disable_rand_) set_``var``_rand(0, 0, i_); \
        endfunction : set_``var \
        function type get_``var (int unsigned index_); \
            return var[index_]; \
        endfunction : get_``var



    `define vip_ahb5_info(MSG, VERBOSITY) \
        begin \
            string vip_ahb5_info_id_; \
            vip_ahb5_info_id_ = get_type_name(); \
            if (uvm_report_enabled(VERBOSITY, UVM_INFO, vip_ahb5_info_id_)) \
            begin \
                uvm_report_info(vip_ahb5_info_id_, $sformatf MSG, VERBOSITY, `uvm_file, `uvm_line); \
            end \
        end

    `define vip_ahb5_error(MSG) \
        begin \
            string vip_ahb5_error_id_; \
            vip_ahb5_error_id_ = get_type_name(); \
            if (uvm_report_enabled(UVM_NONE, UVM_ERROR, vip_ahb5_error_id_)) \
                uvm_report_error(vip_ahb5_error_id_, $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
        end

    `define vip_ahb5_warning(MSG) \
        begin \
            string vip_ahb5_warning_id_; \
            vip_ahb5_warning_id_ = get_type_name(); \
            if (uvm_report_enabled(UVM_NONE, UVM_WARNING, vip_ahb5_warning_id_)) \
                uvm_report_warning(vip_ahb5_warning_id_, $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
        end

    `define vip_ahb5_fatal(MSG) \
        begin \
            string vip_ahb5_fatal_id_; \
            vip_ahb5_fatal_id_ = get_type_name(); \
            if (uvm_report_enabled(UVM_NONE, UVM_FATAL, vip_ahb5_fatal_id_)) \
                uvm_report_fatal(vip_ahb5_fatal_id_, $sformatf MSG, UVM_NONE, `uvm_file, `uvm_line); \
        end


    `ifdef MODEL_TECH
        `define CREATE_STREAM(a,b) b = $create_transaction_stream(a);
        `define BEGIN_TRANSACTION(a,b,c) $begin_transaction(a,b,c);
        `define BEGIN_CHILD_TRANSACTION(a,b,c,d) $begin_transaction(a,b,c,d);
        `define ADD_ATTRIBUTE(a,b,c) $add_attribute(a,b,c);
        `define ADD_RELATION(a,b,c) $add_relation(a,b,c);
        `ifndef END_TRANSACTION
            `define END_TRANSACTION(a) \
                 do begin \
                 $end_transaction(a); \
                 $free_transaction(a); \
             end while (0)
         `endif

        `ifndef END_EARLY_TRANSACTION
            `define END_EARLY_TRANSACTION(a,b) \
                 do begin \
                 $end_transaction(a,b); \
                 $free_transaction(a); \
                 end while (0)
        `endif

        `ifdef VIP_AHB5_STREAM_SUPPORT_COLOUR
            `define SET_COLOUR(a,b) $add_color(a,b);
        `else
            `define SET_COLOUR(a,b) ;
        `endif

    `endif

    `define VIP_AHB5_NEW(variable, constructor) \
    begin \
        process proc_new_; \
        string proc_state_new_; \
        string class_state_new_; \
        proc_new_ = process::self(); \
        proc_state_new_ = proc_new_.get_randstate(); \
        class_state_new_ = this.get_randstate(); \
        variable = new constructor ; \
        this.set_randstate(class_state_new_); \
        proc_new_.set_randstate(proc_state_new_); \
    end


`endif
