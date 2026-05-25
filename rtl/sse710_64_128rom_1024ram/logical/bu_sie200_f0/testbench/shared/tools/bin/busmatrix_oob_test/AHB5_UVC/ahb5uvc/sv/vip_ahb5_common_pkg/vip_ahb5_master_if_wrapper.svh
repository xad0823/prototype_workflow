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

`ifndef VIP_AHB5_MASTER_IF_WRAPPER_SVH
`define VIP_AHB5_MASTER_IF_WRAPPER_SVH


class vip_ahb5_master_if_wrapper #(type v_intf= int) extends vip_ahb5_if_wrapper;


    v_intf intf;

    static int unsigned transfer_count;


    function new(v_intf vif);
        intf = vif;
        transfer_count = 0;
        set_default_slave(1);
    endfunction:new



    virtual task drive_request_beat(vip_ahb5_types::request_beat_struct_t tx_request);
        intf.HADDR     <= tx_request.Address;
        intf.HTRANS    <= tx_request.Transfer;
        intf.HMASTLOCK <= tx_request.Lock;
        intf.HEXCL     <= tx_request.Exclusive;
    endtask:drive_request_beat

    virtual task start_transfer(vip_ahb5_types::request_beat_struct_t tx_request);

        if(tx_request.Transfer != vip_ahb5_types::TRANSFER_NONSEQ)
        begin
            `vip_ahb5_fatal(("First transfer of the burst should be of type TRANSFER_NONSEQ"))
        end
        intf.HADDR     <= tx_request.Address;
        intf.HBURST    <= tx_request.Burst;
        intf.HTRANS    <= tx_request.Transfer;
        intf.HMASTLOCK <= tx_request.Lock;
        intf.HPROT     <= tx_request.Prot;
        intf.HSIZE     <= tx_request.Size;
        intf.HWRITE    <= tx_request.Direction;
        intf.HSELX     <= 1 << ((tx_request.Select > 0) ?(tx_request.Select-1):(get_default_slave()-1));
        intf.HEXCL     <= tx_request.Exclusive;
        intf.HMASTER   <= tx_request.MasterId;
        intf.HNONSEC   <= tx_request.Secure;
        intf.HAUSER    <= tx_request.AUser;
    endtask:start_transfer

    virtual task drive_data_beat(bit[7:0]data[],
                                 vip_ahb5_types::hdatauser_t data_user);
        intf.HWDATA <= intf.byte_array_to_bit_stream(data);
        intf.HWUSER <= data_user;
    endtask : drive_data_beat


    virtual task drive_request_idle(vip_ahb5_types::idle_mode_t mode);
        vip_ahb5_types::idle_mode_t req_mode;
        intf.HTRANS   <= '0;

        case (mode)
            vip_ahb5_types::DRIVE_ZERO, vip_ahb5_types::DRIVE_X_ZERO:
            begin
                req_mode = vip_ahb5_types::DRIVE_ZERO;
            end
            vip_ahb5_types::MAINTAIN, vip_ahb5_types::DRIVE_X_MAINTAIN:
            begin
               req_mode = vip_ahb5_types::MAINTAIN;
            end
        endcase


        case (req_mode)
            vip_ahb5_types::DRIVE_ZERO:
            begin
                intf.HADDR     <= '0;
                intf.HBURST    <= '0;
                intf.HMASTLOCK <= '0;
                intf.HPROT     <= '0;
                intf.HSIZE     <= '0;
                intf.HWRITE    <= '0;
                intf.HSELX     <= 1'b1 << (get_default_slave()-1);
                intf.HEXCL     <= '0;
                intf.HMASTER   <= '0;
                intf.HNONSEC   <= '0;
                intf.HAUSER    <= '0;
                intf.HAUSER    <= '0;
            end
            vip_ahb5_types::MAINTAIN:
            begin
                intf.HADDR     <= intf.cb.HADDR;
                intf.HBURST    <= intf.cb.HBURST;
                intf.HMASTLOCK <= intf.cb.HMASTLOCK;
                intf.HPROT     <= intf.cb.HPROT;
                intf.HSIZE     <= intf.cb.HSIZE;
                intf.HWRITE    <= intf.cb.HWRITE;
                intf.HSELX     <= intf.cb.HSELX;
                intf.HEXCL     <= intf.cb.HEXCL;
                intf.HMASTER   <= intf.cb.HMASTER;
                intf.HNONSEC   <= intf.cb.HNONSEC;
                intf.HAUSER    <= intf.cb.HAUSER;
           end
       endcase
    endtask :drive_request_idle

    virtual task drive_bus_idle(vip_ahb5_types::idle_mode_t mode);
        drive_request_idle(mode);
        drive_data_idle(mode);
    endtask :drive_bus_idle

    virtual task drive_data_idle(vip_ahb5_types::idle_mode_t mode);
        case (mode)
            vip_ahb5_types::DRIVE_ZERO:
            begin
                intf.HWDATA <= '0;
                intf.HWUSER <= '0;
            end
            vip_ahb5_types::DRIVE_X_ZERO,
            vip_ahb5_types::DRIVE_X_MAINTAIN:
            begin
                intf.HWDATA <= 'x;
                intf.HWUSER <= 'x;
            end
            vip_ahb5_types::MAINTAIN:
            begin
                intf.HWDATA <= intf.cb.HWDATA;
                intf.HWUSER <= intf.cb.HWUSER;
            end
        endcase
    endtask :drive_data_idle

    virtual task sample_start_of_transfer(output vip_ahb5_types::request_beat_struct_t rx_req);
        @(intf.cb);
        while((intf.cb.HTRANS != vip_ahb5_types::TRANSFER_NONSEQ)||(!intf.cb.HSEL))
        begin
            @(intf.cb);
        end
        sample_transfer(rx_req);
    endtask: sample_start_of_transfer

    virtual task sample_transfer(output vip_ahb5_types::request_beat_struct_t rx_req);
        rx_req.Address   = intf.cb.HADDR;
        rx_req.Burst     = intf.cb.HBURST;
        rx_req.Transfer  = intf.cb.HTRANS;
        rx_req.Lock      = intf.cb.HMASTLOCK;
        rx_req.Prot      = intf.cb.HPROT;
        rx_req.Size      = intf.cb.HSIZE;
        rx_req.Direction = intf.cb.HWRITE;
        if($onehot0(intf.cb.HSELX))
            rx_req.Select    = ($clog2(intf.cb.HSELX)+1'b1);
        else begin
            `uvm_fatal("ONEHOT_HSELX",$sformatf("Multiple slaves selected. $onehot0(HSELx) failed."))
        end
        rx_req.Exclusive = intf.cb.HEXCL;
        rx_req.MasterId  = intf.cb.HMASTER;
        rx_req.Secure    = intf.cb.HNONSEC;
        rx_req.AUser     = intf.cb.HAUSER;
    endtask : sample_transfer


    virtual task sample_read_data(output bit[7:0]data[],
                                  output vip_ahb5_types::hdatauser_t user);
        intf.bitstream_to_byte_array(intf.cb.HRDATA,data);
        user = intf.cb.HRUSER;
    endtask:sample_read_data

    virtual task sample_write_data(output bit[7:0]data[],
                                   output vip_ahb5_types::hdatauser_t user);
        intf.bitstream_to_byte_array(intf.cb.HWDATA,data);
        user = intf.cb.HWUSER;
    endtask:sample_write_data

    virtual task sample_response(output vip_ahb5_types::response_beat_struct_t rx_resp);
        @(intf.cb);
        rx_resp.ReadyOut = intf.cb.HREADY;
        rx_resp.Response = intf.cb.HRESP;
        rx_resp.ExclResponse = intf.cb.HEXOKAY;
        rx_resp.State = vip_ahb5_types::slave_response_states_t'({rx_resp.ExclResponse,rx_resp.Response,rx_resp.ReadyOut});
    endtask: sample_response


    task wait_for_reset(output bit reset);
        @(negedge intf.HRESET_N);
        reset = 1'b1;
        transfer_count = 0;
    endtask:wait_for_reset

    task wait_for_reset_exit();
        while((!intf.HRESET_N)||($isunknown(intf.HRESET_N)))begin
            drive_bus_idle(vip_ahb5_types::DRIVE_X_ZERO);
            clk_sync(1);
        end
    endtask: wait_for_reset_exit

    task wait_for_ready();
        @(intf.cb);
        while(!intf.cb.HREADY)begin
            @(intf.cb);
        end
    endtask: wait_for_ready

    virtual function int unsigned get_data_byte_width();
        return intf.get_data_byte_width();
    endfunction : get_data_byte_width

    virtual function int unsigned get_number_of_slaves();
        return intf.get_number_of_slaves();
    endfunction : get_number_of_slaves

    virtual task clk_sync(int unsigned num_clocks);
        repeat(num_clocks) begin
            @(intf.cb);
        end
    endtask : clk_sync

    virtual task drive_response_beat(vip_ahb5_types::response_beat_struct_t tx_response);
    endtask : drive_response_beat

    virtual function void set_default_slave(int unsigned id_);
        default_slave = id_;
    endfunction: set_default_slave

    virtual function int unsigned get_default_slave();
        return default_slave;
    endfunction: get_default_slave

    virtual function
    void set_idle_mode(vip_ahb5_types::idle_mode_t idle_mode_);
        idle_mode = idle_mode_;
    endfunction : set_idle_mode

    virtual function
    vip_ahb5_types::idle_mode_t get_idle_mode();
        return idle_mode;
    endfunction : get_idle_mode

endclass : vip_ahb5_master_if_wrapper


`endif
