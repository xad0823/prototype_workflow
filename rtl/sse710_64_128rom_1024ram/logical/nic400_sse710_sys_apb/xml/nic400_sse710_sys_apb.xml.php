<?php $cfg = json_decode(file_get_contents($argv[1]), true);
$NUM_EXT_SYS = $cfg['NUM_EXT_SYS'];
$EXT_SYS0_TZ_SPT = $cfg['EXT_SYS0_TZ_SPT'];
$EXT_SYS1_TZ_SPT = $cfg['EXT_SYS1_TZ_SPT'];
$EXT_SYS2_TZ_SPT = $cfg['EXT_SYS2_TZ_SPT'];
$EXT_SYS3_TZ_SPT = $cfg['EXT_SYS3_TZ_SPT'];
$ID_WIDTH    = $cfg['ID_WIDTH'];
?>
<?xml version="1.0" encoding="iso-8859-1" ?>
<periph>
    <product_version_info minor_code="50000" minor_version="0" major_group="bu" minor_revision="2" major_revision="1" product_code="nic400" major_version="00" part_quality="rel"/>
    <validator_version_info minor_revision="2" major_revision="23"/>
    <global>
        <address0x0>top</address0x0>
        <aruser_width>10</aruser_width>
        <awuser_width>10</awuser_width>
        <buser_width>0</buser_width>
        <cc_type>async</cc_type>
        <default_protocol>axi4</default_protocol>
        <dpe_glb_enable>false</dpe_glb_enable>
        <dpe_status>false</dpe_status>
        <dpe_width>5</dpe_width>
        <gen_caps>true</gen_caps>
        <hcg_en>true</hcg_en>
        <license_status>licensed</license_status>
        <periph_id3>0</periph_id3>
        <pl_id_width><?php echo $ID_WIDTH?></pl_id_width>
        <qos_status>false</qos_status>
        <rsb_arch_central_ring>true</rsb_arch_central_ring>
        <ruser_width>0</ruser_width>
        <sas_visible>false</sas_visible>
        <start_iid>0</start_iid>
        <taxonomy>masterslave</taxonomy>
        <thin_links_status>false</thin_links_status>
        <uppercase_ext_sig>false</uppercase_ext_sig>
        <virtual_networks/>
        <virtual_networks_status>false</virtual_networks_status>
        <wuser_width>0</wuser_width>
    </global>
    <clocks>
        <domain freq="100">main</domain>
        <domain freq="100">a</domain>
        <domain freq="100">ctrl</domain>
        <relationship>
            <clock0>a</clock0>
            <clock1>ctrl</clock1>
            <clock_boundary>async</clock_boundary>
        </relationship>
    </clocks>
    <asib>
        <address_ranges>
            <name>default_map</name>
            <range>
                <addr_max>0x1BC4FFFF</addr_max>
                <addr_min>0x1BC00000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>ppu_cpu_apb</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1C010FFF</addr_max>
                <addr_min>0x1C010000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>gic_axim</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B830FFF</addr_max>
                <addr_min>0x1B830000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>seh_mhu1</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1DFFFFFF</addr_max>
                <addr_min>0x1D000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>stm_axim</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B900FFF</addr_max>
                <addr_min>0x1B900000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>sdc600_apb</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B000FFF</addr_max>
                <addr_min>0x1B000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes0_mhu0</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B800FFF</addr_max>
                <addr_min>0x1B800000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hse_mhu0</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B810FFF</addr_max>
                <addr_min>0x1B810000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>seh_mhu0</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B820FFF</addr_max>
                <addr_min>0x1B820000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hse_mhu1</target>
                </remap>
            </range>
            <range>
                <addr_max>0x11FFFFFF</addr_max>
                <addr_min>0x10000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hostsysdbg_apb</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1B010FFF</addr_max>
                <addr_min>0x1B010000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es0h_mhu0</target>
                </remap>
            </range>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
            <range>
                <addr_max>0x1B020FFF</addr_max>
                <addr_min>0x1B020000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes0_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
            <range>
                <addr_max>0x1B030FFF</addr_max>
                <addr_min>0x1B030000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es0h_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
            <range>
                <addr_max>0x1B040FFF</addr_max>
                <addr_min>0x1B040000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes1_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
            <range>
                <addr_max>0x1B050FFF</addr_max>
                <addr_min>0x1B050000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es1h_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B060FFF</addr_max>
                <addr_min>0x1B060000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes1_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B070FFF</addr_max>
                <addr_min>0x1B070000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es1h_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 2) {?>
            <range>
                <addr_max>0x1B080FFF</addr_max>
                <addr_min>0x1B080000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes2_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 2) {?>
            <range>
                <addr_max>0x1B090FFF</addr_max>
                <addr_min>0x1B090000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es2h_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B0A0FFF</addr_max>
                <addr_min>0x1B0A0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes2_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B0B0FFF</addr_max>
                <addr_min>0x1B0B0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es2h_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
            <range>
                <addr_max>0x1B0C0FFF</addr_max>
                <addr_min>0x1B0C0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes3_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
            <range>
                <addr_max>0x1B0D0FFF</addr_max>
                <addr_min>0x1B0D0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es3h_mhu0</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B0E0FFF</addr_max>
                <addr_min>0x1B0E0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hes3_mhu1</target>
                </remap>
            </range>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
            <range>
                <addr_max>0x1B0F0FFF</addr_max>
                <addr_min>0x1B0F0000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>es3h_mhu1</target>
                </remap>
            </range>
<?php }?>
            <range>
                <addr_max>0x1C030FFF</addr_max>
                <addr_min>0x1C02F000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>gic_axim</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1C050FFF</addr_max>
                <addr_min>0x1C04F000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>gic_axim</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1C070FFF</addr_max>
                <addr_min>0x1C06F000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>gic_axim</target>
                </remap>
            </range>
            <range>
                <addr_max>0x123FFFFF</addr_max>
                <addr_min>0x12000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hostsysdbg_apb</target>
                </remap>
            </range>
            <range>
                <addr_max>0x1E0FFFFF</addr_max>
                <addr_min>0x1E000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>gpvmain_ahb</target>
                </remap>
            </range>
            <range>
                <addr_max>0x133FFFFF</addr_max>
                <addr_min>0x13000000</addr_min>
                <remap>
                    <bit>default</bit>
                    <present>true</present>
                    <region>0</region>
                    <target>hostsysdbg_apb</target>
                </remap>
            </range>
        </address_ranges>
        <apb_config>false</apb_config>
        <apb_slave_no>2</apb_slave_no>
        <cds>slaveperid</cds>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>false</multi_region>
        <name>sysperi_axis</name>
        <protocol>axi4</protocol>
        <qos_config>
            <hard>disable</hard>
            <lqv>disable</lqv>
            <pot>disable</pot>
        </qos_config>
        <qv>
            <type>input</type>
            <value>0</value>
        </qv>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>6</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>aw</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>4</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>ar</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>4</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>r</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>6</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>6</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>b</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <slave_if_addr_width>32</slave_if_addr_width>
        <slave_if_data_width>32</slave_if_data_width>
        <tide>0</tide>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>input</trustzone>
        <vid_width><?php echo $ID_WIDTH?></vid_width>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>110</x>
        <y>60</y>
        <master_if_port_name>sysperi_axis_m</master_if_port_name>
        <slave_if_port_name>sysperi_axis_s</slave_if_port_name>
    </asib>
    <amib>
        <apb_config>false</apb_config>
        <apb_slave_no>65</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>true</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>false</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>false</multi_region>
        <name>gic_axim</name>
        <protocol>axi4</protocol>
        <qv_out>true</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>rev</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>aw</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>ar</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>r</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>r</name>
            <type>rev</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>b</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>b</name>
            <type>rev</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>660</y>
        <master_if_port_name>gic_axim_m</master_if_port_name>
        <slave_if_port_name>gic_axim_s</slave_if_port_name>
    </amib>
    <amib>
        <apb_config>false</apb_config>
        <apb_slave_no>64</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>true</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>false</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>64</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>false</multi_region>
        <name>stm_axim</name>
        <protocol>axi4</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>r</name>
            <type>rev</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>rev</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>b</name>
            <type>rev</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>rev</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>aw</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>rev</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>ar</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>r</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>b</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>706</y>
        <master_if_port_name>stm_axim_m</master_if_port_name>
        <slave_if_port_name>stm_axim_s</slave_if_port_name>
    </amib>
    <amib>
        <apb_config>false</apb_config>
        <apb_port>
            <clock_domain>ctrl</clock_domain>
            <name>ppu_cpu_apb</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>605</y>
        </apb_port>
        <apb_slave_no>59</apb_slave_no>
        <clock_boundary>async</clock_boundary>
        <clock_domain_name_master_if>ctrl</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>false</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>true</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>false</multi_region>
        <name>slave_9</name>
        <protocol>apb</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>a</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>d</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>a</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>d</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>present</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <tide>0</tide>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>605</y>
        <master_if_port_name>ppu_cpu_apb</master_if_port_name>
        <slave_if_port_name>slave_9_s</slave_if_port_name>
    </amib>
    <amib>
        <apb_config>false</apb_config>
        <apb_slave_no>63</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>false</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>false</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>false</multi_region>
        <name>gpvmain_ahb</name>
        <protocol>ahb_ms</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>a</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>d</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>a</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>d</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>sec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>752</y>
        <master_if_port_name>gpvmain_ahb_m</master_if_port_name>
        <slave_if_port_name>gpvmain_ahb_s</slave_if_port_name>
    </amib>
    <amib>
        <apb_config>false</apb_config>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hse_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>330</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>seh_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>350</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hse_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>370</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>seh_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>390</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes0_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>410</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es0h_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>430</y>
        </apb_port>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes0_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>450</y>
        </apb_port>
<?php }?>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es0h_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>470</y>
        </apb_port>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes1_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>490</y>
        </apb_port>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es1h_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>510</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes1_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>530</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es1h_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>550</y>
        </apb_port>
<?php }?>
        <apb_slave_no>60</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>false</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>true</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>true</multi_region>
        <name>slave_8</name>
        <protocol>apb</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>a</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>d</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>a</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>d</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>330</y>
<?php 
$master_if_port_name="hse_mhu0,seh_mhu0,hse_mhu1,seh_mhu1,hes0_mhu0,es0h_mhu0";
if ($EXT_SYS0_TZ_SPT == 1) { $master_if_port_name = $master_if_port_name.",hes0_mhu1,es0h_mhu1"; } 
if ($NUM_EXT_SYS > 1) {
  $master_if_port_name = $master_if_port_name.",hes1_mhu0,es1h_mhu0";
}
if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {
  $master_if_port_name = $master_if_port_name.",hes1_mhu1,es1h_mhu1";
}
?>
        <master_if_port_name><?php echo $master_if_port_name ?></master_if_port_name>
        <slave_if_port_name>slave_8_s</slave_if_port_name>
    </amib>
    <amib>
        <apb_config>false</apb_config>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hostsysdbg_apb</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>255</y>
        </apb_port>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>sdc600_apb</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>275</y>
        </apb_port>
        <apb_slave_no>62</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>false</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>true</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>true</multi_region>
        <name>slave_6</name>
        <protocol>apb</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>a</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>present</impl>
            <location>master_port</location>
            <name>d</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>a</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>d</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>255</y>
        <master_if_port_name>hostsysdbg_apb,sdc600_apb</master_if_port_name>
        <slave_if_port_name>slave_6_s</slave_if_port_name>
    </amib>
<?php if ($NUM_EXT_SYS > 2) {?>
    <amib>
        <apb_config>false</apb_config>
<?php if ($NUM_EXT_SYS > 2) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes2_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>87</y>
        </apb_port>
<?php }?>
<?php if ($NUM_EXT_SYS > 2) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es2h_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>107</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes2_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>127</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es2h_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>147</y>
        </apb_port>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes3_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>167</y>
        </apb_port>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es3h_mhu0</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>187</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>hes3_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>207</y>
        </apb_port>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
        <apb_port>
            <clock_domain>a</clock_domain>
            <name>es3h_mhu1</name>
            <trustzone>nsec</trustzone>
            <x>902</x>
            <y>227</y>
        </apb_port>
<?php }?>
        <apb_slave_no>61</apb_slave_no>
        <clock_boundary>none</clock_boundary>
        <clock_domain_name_master_if>a</clock_domain_name_master_if>
        <clock_domain_name_slave_if>a</clock_domain_name_slave_if>
        <compress_id>false</compress_id>
        <dest_type>peripheral</dest_type>
        <expanded>true</expanded>
        <master_if_addr_width>32</master_if_addr_width>
        <master_if_data_width>32</master_if_data_width>
        <multi_ported>false</multi_ported>
        <multi_region>true</multi_region>
        <name>slave_10</name>
        <protocol>apb</protocol>
        <qv_out>false</qv_out>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>aw</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>ar</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>r</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>slave_port</location>
            <name>b</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>a</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>d</name>
            <type>full</type>
        </reg>
        <reg>
            <impl>absent</impl>
            <location>master_port</location>
            <name>w</name>
            <type>full</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>a</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>d</name>
            <type>fifo</type>
        </reg>
        <reg>
            <depth>2</depth>
            <impl>absent</impl>
            <location>boundary</location>
            <name>w</name>
            <type>fifo</type>
        </reg>
        <slave_if_data_width>32</slave_if_data_width>
        <token_prerequest>false</token_prerequest>
        <token_prerequest_bridge>false</token_prerequest_bridge>
        <trustzone>nsec</trustzone>
        <vn_external>none</vn_external>
        <vn_external_bridge>none</vn_external_bridge>
        <x>890</x>
        <y>87</y>
<?php 
$master_if_port_name="";
if ($NUM_EXT_SYS > 2) {
  $master_if_port_name = $master_if_port_name."hes2_mhu0,es2h_mhu0";
}
if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {
  $master_if_port_name = $master_if_port_name.",hes2_mhu1,es2h_mhu1";
}
if ($NUM_EXT_SYS > 3) {
  $master_if_port_name = $master_if_port_name.",hes3_mhu0,es3h_mhu0";
}
if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {
  $master_if_port_name = $master_if_port_name.",hes3_mhu1,es3h_mhu1";
}
?>

        <master_if_port_name><?php echo $master_if_port_name ?></master_if_port_name>
        <slave_if_port_name>slave_10_s</slave_if_port_name>
    </amib>
<?php }?>
    <inter>
        <clock_domain>a</clock_domain>
        <data_width>32</data_width>
        <expanded>true</expanded>
        <height>727</height>
        <impl>singlelayer</impl>
        <master_if>
            <name>axi_m_0</name>
            <post_arb_reg>present</post_arb_reg>
            <x>547</x>
            <y>660</y>
        </master_if>
        <master_if>
            <name>axi_m_1</name>
            <post_arb_reg>present</post_arb_reg>
            <x>547</x>
            <y>706</y>
        </master_if>
        <master_if>
            <name>axi_m_3</name>
            <post_arb_reg>absent</post_arb_reg>
            <x>547</x>
            <y>605</y>
        </master_if>
        <master_if>
            <name>axi_m_5</name>
            <post_arb_reg>absent</post_arb_reg>
            <x>547</x>
            <y>752</y>
        </master_if>
        <master_if>
            <name>axi_m_2</name>
            <post_arb_reg>present</post_arb_reg>
            <x>547</x>
            <y>330</y>
        </master_if>
        <master_if>
            <name>axi_m_6</name>
            <post_arb_reg>present</post_arb_reg>
            <x>547</x>
            <y>255</y>
        </master_if>
        <master_if>
            <name>axi_m_4</name>
            <post_arb_reg def="true">absent</post_arb_reg>
            <x>547</x>
            <y>90</y>
        </master_if>
<?php if ($NUM_EXT_SYS > 2) {?>
        <master_if>
            <name>axi_m_7</name>
            <post_arb_reg>present</post_arb_reg>
            <x>547</x>
            <y>255</y>
        </master_if>
<?php }?>
        <name>switch0</name>
        <protocol>axi4</protocol>
        <slave_if>
            <name>axi_s_0</name>
            <x>454</x>
            <y>60</y>
        </slave_if>
        <sparse>
            <cds>slaveperid</cds>
            <sas def="true">false</sas>
            <slave_if_port>axi_s_0</slave_if_port>
            <master_if_port>
                <name>axi_m_6</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
<?php if ($NUM_EXT_SYS > 2) {?>
            <master_if_port>
                <name>axi_m_7</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
<?php }?>
            <master_if_port>
                <name>axi_m_2</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
            <master_if_port>
                <name>axi_m_3</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
            <master_if_port>
                <name>axi_m_0</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
            <master_if_port>
                <name>axi_m_1</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
            <master_if_port>
                <name>axi_m_5</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
            <master_if_port>
                <name>axi_m_4</name>
                <reg>
                    <impl def="true">absent</impl>
                    <name>aw</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>ar</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>r</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>w</name>
                    <type def="true">full</type>
                </reg>
                <reg>
                    <impl def="true">absent</impl>
                    <name>b</name>
                    <type def="true">full</type>
                </reg>
            </master_if_port>
        </sparse>
        <type>busmatrix</type>
        <width>94</width>
        <x>500</x>
        <y>406</y>
<?php if ($NUM_EXT_SYS > 2) {?>
        <master_if_port_name>axi_m_0,axi_m_1,axi_m_3,axi_m_5,axi_m_2,axi_m_6,axi_m_4,axi_m_7</master_if_port_name>
<?php } else {?>
        <master_if_port_name>axi_m_0,axi_m_1,axi_m_3,axi_m_5,axi_m_2,axi_m_6,axi_m_4</master_if_port_name>
<?php }?>
        <slave_if_port_name>axi_s_0</slave_if_port_name>
    </inter>
    <inter>
        <name>ds_0</name>
        <slave_if>
            <name>axi_s_0</name>
            <x>563</x>
            <y>100</y>
        </slave_if>
        <type>default_slave</type>
        <x>577</x>
        <y>100</y>
        <master_if_port_name></master_if_port_name>
        <slave_if_port_name>axi_s_0</slave_if_port_name>
    </inter>
    <connect>
        <dest>slave_9</dest>
        <dest_port>slave_9_s</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>2</out_trans>
        <out_writes>1</out_writes>
        <protocol>axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_3</src_port>
    </connect>
    <connect>
        <dest>slave_8</dest>
        <dest_port>slave_8_s</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>2</out_trans>
        <out_writes>1</out_writes>
        <protocol>axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_2</src_port>
    </connect>
    <connect>
        <dest>slave_6</dest>
        <dest_port>slave_6_s</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>2</out_trans>
        <out_writes>1</out_writes>
        <protocol>axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_6</src_port>
    </connect>
<?php if ($NUM_EXT_SYS > 2) {?>
    <connect>
        <dest>slave_10</dest>
        <dest_port>slave_10_s</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>2</out_trans>
        <out_writes>1</out_writes>
        <protocol>axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_7</src_port>
    </connect>
<?php }?>
    <connect>
        <aruser>true</aruser>
        <awuser>true</awuser>
        <buser>false</buser>
        <dest>sysperi_axis</dest>
        <dest_port>sysperi_axis_s</dest_port>
        <lock>false</lock>
        <out_reads>4</out_reads>
        <out_trans>10</out_trans>
        <out_writes>6</out_writes>
        <protocol>axi4</protocol>
        <ruser>false</ruser>
        <src>external</src>
        <src_port>sysperi_axis</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>true</aruser>
        <awuser>true</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>gic_axim</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>axi4</protocol>
        <ruser>false</ruser>
        <src>gic_axim</src>
        <src_port>gic_axim_m</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>true</aruser>
        <awuser>true</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>stm_axim</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>4</out_trans>
        <out_writes>3</out_writes>
        <protocol>axi4</protocol>
        <ruser>false</ruser>
        <src>stm_axim</src>
        <src_port>stm_axim_m</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>gpvmain_ahb</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>ahb_ms</protocol>
        <ruser>false</ruser>
        <src>gpvmain_ahb</src>
        <src_port>gpvmain_ahb_m</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hostsysdbg_apb</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_6</src>
        <src_port>hostsysdbg_apb</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>sdc600_apb</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_6</src>
        <src_port>sdc600_apb</src_port>
        <wuser>false</wuser>
    </connect>
<?php if ($NUM_EXT_SYS > 2) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes2_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>hes2_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($NUM_EXT_SYS > 2) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es2h_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>es2h_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes2_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>hes2_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 2) && ($EXT_SYS2_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es2h_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>es2h_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes3_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>hes3_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es3h_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>es3h_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes3_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>hes3_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 3) && ($EXT_SYS3_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es3h_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_10</src>
        <src_port>es3h_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hse_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hse_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>seh_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>seh_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hse_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hse_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>seh_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>seh_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes0_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hes0_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es0h_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>es0h_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes0_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hes0_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es0h_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>es0h_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes1_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hes1_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es1h_mhu0</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>es1h_mhu0</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>hes1_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>hes1_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
<?php if (($NUM_EXT_SYS > 1) && ($EXT_SYS1_TZ_SPT == 1)) {?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>es1h_mhu1</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_8</src>
        <src_port>es1h_mhu1</src_port>
        <wuser>false</wuser>
    </connect>
<?php }?>
    <connect>
        <aruser>false</aruser>
        <awuser>false</awuser>
        <buser>false</buser>
        <dest>external</dest>
        <dest_port>ppu_cpu_apb</dest_port>
        <lock>false</lock>
        <out_reads>1</out_reads>
        <out_trans>1</out_trans>
        <out_writes>1</out_writes>
        <protocol>apb4</protocol>
        <ruser>false</ruser>
        <src>slave_9</src>
        <src_port>ppu_cpu_apb</src_port>
        <wuser>false</wuser>
    </connect>
    <connect>
        <dest>switch0</dest>
        <dest_port>axi_s_0</dest_port>
        <lock>false</lock>
        <out_reads def="true">4</out_reads>
        <out_trans>10</out_trans>
        <out_writes def="true">6</out_writes>
        <protocol def="true">axi4</protocol>
        <src>sysperi_axis</src>
        <src_port>sysperi_axis_m</src_port>
    </connect>
    <connect>
        <dest>gic_axim</dest>
        <dest_port>gic_axim_s</dest_port>
        <lock>false</lock>
        <out_reads def="true">1</out_reads>
        <out_trans def="true">1</out_trans>
        <out_writes def="true">1</out_writes>
        <protocol def="true">axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_0</src_port>
    </connect>
    <connect>
        <dest>stm_axim</dest>
        <dest_port>stm_axim_s</dest_port>
        <lock>false</lock>
        <out_reads def="true">1</out_reads>
        <out_trans def="true">4</out_trans>
        <out_writes def="true">3</out_writes>
        <protocol def="true">axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_1</src_port>
    </connect>
    <connect>
        <dest>gpvmain_ahb</dest>
        <dest_port>gpvmain_ahb_s</dest_port>
        <lock>false</lock>
        <out_reads def="true">2</out_reads>
        <out_trans def="true">4</out_trans>
        <out_writes def="true">2</out_writes>
        <protocol def="true">axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_5</src_port>
    </connect>
    <connect>
        <dest>ds_0</dest>
        <dest_port>axi_s_0</dest_port>
        <lock>false</lock>
        <out_reads def="true">1</out_reads>
        <out_trans>2</out_trans>
        <out_writes def="true">1</out_writes>
        <protocol def="true">axi4</protocol>
        <src>switch0</src>
        <src_port>axi_m_4</src_port>
    </connect>
    <architecture>
        <link>
            <slave_if>
                <name>sysperi_axis</name>
                <master_if>gic_axim</master_if>
                <master_if>stm_axim</master_if>
                <master_if>slave_9</master_if>
                <master_if>ppu_cpu_apb<parent>slave_9</parent>
                </master_if>
                <master_if>gpvmain_ahb</master_if>
                <master_if>slave_8</master_if>
                <master_if>hse_mhu0<parent>slave_8</parent>
                </master_if>
                <master_if>seh_mhu0<parent>slave_8</parent>
                </master_if>
                <master_if>hse_mhu1<parent>slave_8</parent>
                </master_if>
                <master_if>seh_mhu1<parent>slave_8</parent>
                </master_if>
                <master_if>hes0_mhu0<parent>slave_8</parent>
                </master_if>
                <master_if>es0h_mhu0<parent>slave_8</parent>
                </master_if>
<?php if ($EXT_SYS0_TZ_SPT == 1) {?>
                <master_if>hes0_mhu1<parent>slave_8</parent>
                </master_if>
                <master_if>es0h_mhu1<parent>slave_8</parent>
                </master_if>
<?php }?>
<?php if ($NUM_EXT_SYS > 1) {?>
                <master_if>hes1_mhu0<parent>slave_8</parent>
                </master_if>
                <master_if>es1h_mhu0<parent>slave_8</parent>
                </master_if>
<?php if ($EXT_SYS1_TZ_SPT == 1) {?>
                <master_if>hes1_mhu1<parent>slave_8</parent>
                </master_if>
                <master_if>es1h_mhu1<parent>slave_8</parent>
                </master_if>
<?php }?>
<?php }?>
<?php if ($NUM_EXT_SYS > 2) {?>
                <master_if>es2h_mhu0<parent>slave_10</parent>
                </master_if>
                <master_if>hes2_mhu0<parent>slave_10</parent>
                </master_if>
<?php if ($EXT_SYS2_TZ_SPT == 1) {?>
                <master_if>hes2_mhu1<parent>slave_10</parent>
                </master_if>
                <master_if>es2h_mhu1<parent>slave_10</parent>
                </master_if>
<?php }?>
<?php }?>
<?php if ($NUM_EXT_SYS > 3) {?>
                <master_if>hes3_mhu0<parent>slave_10</parent>
                </master_if>
                <master_if>es3h_mhu0<parent>slave_10</parent>
                </master_if>
<?php if ($EXT_SYS3_TZ_SPT == 1) {?>
                <master_if>hes3_mhu1<parent>slave_10</parent>
                </master_if>
                <master_if>es3h_mhu1<parent>slave_10</parent>
                </master_if>
<?php }?>
<?php }?>
                <master_if>slave_6</master_if>
                <master_if>hostsysdbg_apb<parent>slave_6</parent>
                </master_if>
                <master_if>sdc600_apb<parent>slave_6</parent>
                </master_if>
<?php if ($NUM_EXT_SYS > 2) {?>
                <master_if>slave_10</master_if>
<?php }?>
            </slave_if>
        </link>
    </architecture>
</periph>
