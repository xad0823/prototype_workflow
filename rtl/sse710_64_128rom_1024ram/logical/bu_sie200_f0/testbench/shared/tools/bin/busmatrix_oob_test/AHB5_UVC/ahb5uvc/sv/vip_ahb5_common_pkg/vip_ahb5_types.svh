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

`ifndef VIP_AHB5_TYPES_SVH
`define VIP_AHB5_TYPES_SVH




class vip_ahb5_types;



parameter VIP_AHB5_HMASTER_WIDTH     = 16;
parameter VIP_AHB5_HAUSER_WIDTH      = 32;
parameter VIP_AHB5_HDATA_USER_WIDTH  = 32;

    localparam VIP_AHB5_HADDR_WIDTH    = 64;
    localparam VIP_AHB5_HBURST_WIDTH   =  3;
    localparam VIP_AHB5_HTRANS_WIDTH   =  2;
    localparam VIP_AHB5_HSIZE_WIDTH    =  3;
    localparam VIP_AHB5_HPROT_WIDTH    =  7;
    localparam VIP_AHB5_HSELX_WIDTH    = 32;



    typedef bit[VIP_AHB5_HAUSER_WIDTH - 1 : 0] hauser_t;

    typedef bit[VIP_AHB5_HDATA_USER_WIDTH - 1 : 0] hdatauser_t;


    typedef bit[VIP_AHB5_HADDR_WIDTH - 1 : 0] address_t;

    typedef bit[VIP_AHB5_HADDR_WIDTH : 0] secure_address_t;

    typedef bit[(VIP_AHB5_HMASTER_WIDTH-1) : 0] master_id_t;

    typedef int unsigned int_queue_t[$];

    typedef bit bit_queue_t[$];

    typedef bit[7:0] dynamic_byte_array_t[];

    typedef dynamic_byte_array_t data_queue_t[$];


    typedef bit[7:0] data_word_t[4];

    static const int unsigned INFINITE = 64'hFFFFFFFFFFFFFFFF;

    typedef struct packed{
        int unsigned data_byte_width;
        int unsigned hselx_width;
        int unsigned HMASTER_WIDTH;
        int unsigned HAUSER_WIDTH;
        int unsigned HDATAUSER_WIDTH;
    } vip_ahb5_physical_properties_t;

    typedef struct
    {
        data_queue_t data;
        hdatauser_t  user[$];
    } vip_ahb5_data_struct_t;


    typedef enum bit
    {
        MASTER_NODE,
        SLAVE_NODE
    } node_t;

    typedef enum bit [VIP_AHB5_HTRANS_WIDTH-1:0]
    {
        TRANSFER_IDLE   = 0,
        TRANSFER_BUSY   = 1,
        TRANSFER_NONSEQ = 2,
        TRANSFER_SEQ    = 3
    } transfer_t;

    typedef enum bit [VIP_AHB5_HSIZE_WIDTH-1:0]
    {
        SIZE_0 = 0,
        SIZE_1 = 1,
        SIZE_2 = 2,
        SIZE_3 = 3,
        SIZE_4 = 4,
        SIZE_5 = 5,
        SIZE_6 = 6,
        SIZE_7 = 7
    } size_t;

    typedef enum bit [VIP_AHB5_HBURST_WIDTH-1:0]
    {
        BURST_SINGLE = 0,
        BURST_INCR   = 1,
        BURST_WRAP4  = 2,
        BURST_INCR4  = 3,
        BURST_WRAP8  = 4,
        BURST_INCR8  = 5,
        BURST_WRAP16 = 6,
        BURST_INCR16 = 7
    } burst_t;

    typedef enum bit
    {
        REQUEST_READ  = 'b0,
        REQUEST_WRITE = 'b1
    } request_t;

    typedef enum bit
    {
        RESP_OKAY  = 'b0,
        RESP_ERROR = 'b1
    } response_t;

    typedef enum bit
    {
        EXCL_FAIL = 'b0,
        EXCL_OKAY = 'b1
    } excl_response_t;

    typedef enum bit
    {
        SLAVE_READY = 'b1,
        SLAVE_WAIT  = 'b0
    } slave_status_t;

    typedef enum {
        RESP_MODE_RANDOM,
        RESP_MODE_OKAY,
        RESP_MODE_ERROR
    } resp_mode_t;

    typedef enum {
        USER_RANDOM,
        USER_ZERO
    } user_mode_t;

    typedef enum bit[VIP_AHB5_HPROT_WIDTH-3:0]
        {
        MEMORY_V8_DEVICE_nE    = 5'h00,
        MEMORY_V8_DEVICE_E     = 5'h01,
        MEMORY_V8_NORMAL_NC_nS = 5'h02,
        MEMORY_V8_WT_nA_nS     = 5'h06,
        MEMORY_V8_WT_A_nS      = 5'h0e,
        MEMORY_V8_WB_nA_nS     = 5'h07,
        MEMORY_V8_WB_A_nS      = 5'h0f,
        MEMORY_V8_NORMAL_NC_S  = 5'h12,
        MEMORY_V8_WT_nA_S      = 5'h16,
        MEMORY_V8_WT_A_S       = 5'h1e,
        MEMORY_V8_WB_nA_S      = 5'h17,
        MEMORY_V8_WB_A_S       = 5'h1f
    } memory_v8_t;

    typedef enum bit[1:0]
    {
        MEMORY_ACCESS_NPRIV_INSTR     = 2'b00,
        MEMORY_ACCESS_NPRIV_DATA      = 2'b01,
        MEMORY_ACCESS_PRIV_INSTR      = 2'b10,
        MEMORY_ACCESS_PRIV_DATA       = 2'b11
    } memory_access_t;

    typedef enum bit[VIP_AHB5_HPROT_WIDTH-1:0]
    {
        NC_NB_USR_OPC   = 'h0,
        NC_NB_USR_DATA  = 'h1,
        NC_NB_PRIV_OPC  = 'h2,
        NC_NB_PRIV_DATA = 'h3,
        NC_B_USR_OPC    = 'h4,
        NC_B_USR_DATA   = 'h5,
        NC_B_PRIV_OPC   = 'h6,
        NC_B_PRIV_DATA  = 'h7,
        C_NB_USR_OPC    = 'h8,
        C_NB_USR_DATA   = 'h9,
        C_NB_PRIV_OPC   = 'ha,
        C_NB_PRIV_DATA  = 'hb,
        C_B_USR_OPC     = 'hc,
        C_B_USR_DATA    = 'hd,
        C_B_PRIV_OPC    = 'he,
        C_B_PRIV_DATA   = 'hf
    } prot_t;

    typedef bit [VIP_AHB5_HPROT_WIDTH-1:0] ahb5_prot_t;

    typedef enum bit
    {
        ACCESS_NORMAL = 0,
        ACCESS_LOCKED = 1
    } lock_t;

    typedef enum bit[1:0]
    {
        TIMING_RANDOM,
        TIMING_ASAP
    } timing_mode_t;

    typedef enum bit[1:0]
    {
        ENDIAN_LITTLE,
        ENDIAN_BE8,
        ENDIAN_BE32
    } endianness_t;

    typedef enum bit
    {
        TRANS_ATTR_NONEXCL,
        TRANS_ATTR_EXCL
    } trans_attr_t;

    typedef enum bit
    {
        ACCESS_ATTR_SECURE,
        ACCESS_ATTR_NONSECURE
    } access_attr_t;


    typedef enum bit
    {
        MEMORY_MODE_RANDOM,
        MEMORY_MODE_DEFAULT
    } memory_mode_t;

    typedef enum bit [1:0]
    {
        ERROR_MODE_RANDOM,
        ERROR_MODE_OKAY,
        ERROR_MODE_ERROR
    } error_mode_t;

    typedef enum bit[1:0]
    {
        MAINTAIN,
        DRIVE_ZERO,
        DRIVE_X_ZERO,
        DRIVE_X_MAINTAIN
    } idle_mode_t;

    typedef enum bit[1:0]{
        ABORT    = 2'b00,
        ACTIVE   = 2'b01,
        COMPLETE = 2'b10,
        STOPPED  = 2'b11
    }states_t;

    typedef enum bit[2:0] {
        TRANS_PENDING        = 3'b000,
        TRANS_SUCCESS        = 3'b001,
        ERROR_RESP_1ST_CYCLE = 3'b010,
        ERROR_RESP_2ND_CYCLE = 3'b011,
        ERROR_RESP_EXCLUSIVE = 3'b101
    }slave_response_states_t;

    typedef struct {
        bit[VIP_AHB5_HADDR_WIDTH-1 : 0] start_address;
        bit[VIP_AHB5_HADDR_WIDTH-1 : 0] end_address;
        memory_v8_t                     memory_type;
        access_attr_t                   access_type;
    } address_range_struct_t;

    typedef struct packed{
        bit  [VIP_AHB5_HADDR_WIDTH-1 :0] Address;
        bit [VIP_AHB5_HBURST_WIDTH-1 :0] Burst;
        bit [VIP_AHB5_HTRANS_WIDTH-1 :0] Transfer;
        bit  [VIP_AHB5_HSIZE_WIDTH-1 :0] Size;
        bit  [VIP_AHB5_HPROT_WIDTH-1 :0] Prot;
        bit                              Lock;
        bit                              Direction;
        bit  [VIP_AHB5_HSELX_WIDTH-1 :0] Select;
        bit                              Exclusive;
        bit                              Secure;
        master_id_t                      MasterId;
        hauser_t                         AUser;

    }request_beat_struct_t;

    typedef struct packed {
        bit       ReadyOut;
        bit       Response;
        bit       ExclResponse;
        slave_response_states_t State;
    }response_beat_struct_t;

    typedef struct {
        bit [7:0] data;
        bit error;
    } mem_unit_struct_t;


    typedef enum{
        CG_TRANSACTION_COV,
        CG_TRANS_DELAY_COV,

        CG_TRANS_SEQ_COV
    } covergroups_t;


    typedef enum{
        CP_TRANSACTION_COV_BURST,
        CP_TRANSACTION_COV_REQUEST,
        CP_TRANSACTION_COV_TRANSFER_SIZE,
        CP_TRANSACTION_COV_ACCESS,
        CP_TRANSACTION_COV_PROTECTION_CONTROL,
        CP_TRANSACTION_COV_SECURE_TRANSFER,
        CP_TRANSACTION_COV_EXCLUSIVE_RESPONSE,
        CP_TRANSACTION_COV_EXCLUSIVE_TRANSFER,
        CP_TRANSACTION_COV_TRANS_RESPONSE,
        CP_TRANSACTION_COV_EARLY_BURST_TERMINATION,

        CP_TRANSACTION_COV_HNONSEC_X_BURST_X_REQUEST,
        CP_TRANSACTION_COV_EXCL_TRANS_X_REQUEST_X_EXCL_RESP,
        CP_TRANSACTION_COV_BURST_X_HPROT,
        CP_TRANSACTION_COV_BURST_X_REQUEST,
        CP_TRANSACTION_COV_BURST_X_TRANSFER_SIZE,
        CP_TRANSACTION_COV_BURST_X_TRANS_RESPONSE,
        CP_TRANSACTION_COV_BURST_X_ACCESS,
        CP_TRANSACTION_COV_REQUEST_X_TRANSFER_SIZE,
        CP_TRANSACTION_COV_REQUEST_X_ACCESS,
        CP_TRANSACTION_COV_REQUEST_X_TRANS_RESPONSE,
        CP_TRANSACTION_COV_REQUEST_X_PROTECTION_CONTROL,
        CP_TRANSACTION_COV_HNONSEC_X_REQUEST_X_PROTECTION_CONTROL,

        CP_TRANS_DELAY_COV_BUSY_CYCLES,
        CP_TRANS_DELAY_COV_SLAVE_WAIT_STATES,

        CP_TRANS_SEQ_TRANSFER,
        CP_TRANS_SEQ_RESPONSE,
        CP_TRANS_SEQ_RESPONSE_STATE,
        CP_TRANS_SEQ_TRANSFER_TRANSITION,
        CP_TRANS_SEQ_RESPONSE_TRANSITION,
        CP_TRANS_SEQ_TRANSFER_X_RESET,
        CP_TRANS_SEQ_RESPONSE_X_RESET

    } coverpoints_t;


    typedef enum {
        PARAM_SLAVE_WAIT_STATES_MIN,
        PARAM_MASTER_BUSY_CYCLES_MIN,
        PARAM_SLAVE_WAIT_STATES_MAX,
        PARAM_MASTER_BUSY_CYCLES_MAX,
        PARAM_HSIZE_MAX
    } cov_parameters_t;


    static function vip_ahb5_types::size_t get_hsize_from_data_width(int unsigned data_byte_width);
        vip_ahb5_types::size_t hsize;
        unique case(data_byte_width)
                  1 : hsize = vip_ahb5_types::SIZE_0;
                  2 : hsize = vip_ahb5_types::SIZE_1;
                  4 : hsize = vip_ahb5_types::SIZE_2;
                  8 : hsize = vip_ahb5_types::SIZE_3;
                 16 : hsize = vip_ahb5_types::SIZE_4;
                 32 : hsize = vip_ahb5_types::SIZE_5;
                 64 : hsize = vip_ahb5_types::SIZE_6;
                128 : hsize = vip_ahb5_types::SIZE_7;
            default : hsize = vip_ahb5_types::SIZE_2;
        endcase
        return hsize;
    endfunction : get_hsize_from_data_width

    static function int unsigned get_data_width_from_hsize (vip_ahb5_types::size_t hsize);
        int unsigned data_bytes;
        begin
            data_bytes = (1 << hsize);
            return data_bytes;
        end
    endfunction : get_data_width_from_hsize

    static function
    secure_address_t get_secure_address(access_attr_t secure = ACCESS_ATTR_NONSECURE,
                                        address_t addr);
        secure_address_t secure_addr;
        bit access_attr = (secure == ACCESS_ATTR_SECURE);

        secure_addr = {secure, addr};
        return secure_addr;
    endfunction : get_secure_address

endclass : vip_ahb5_types
`endif
