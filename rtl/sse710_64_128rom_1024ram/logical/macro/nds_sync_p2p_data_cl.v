// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_sync_p2p_data_cl (
	  a_reset_n,
	  a_clk,
	  a_pulse,
	  a_data,
	  a_ready,
	  b_reset_n,
	  b_clk,
	  b_pulse,
	  b_data,
	  b_level,
	  b_level_d1
);

parameter DATA_BIT = 32;
parameter RESET_VALUE = 1'b0;
parameter RESET_DATA_VALUE = 32'h0;

input			a_reset_n;
input			a_clk;
input			a_pulse;
input	[DATA_BIT-1:0]	a_data;
output			a_ready;

input			b_reset_n;
input			b_clk;
output			b_pulse;
output	[DATA_BIT-1:0]	b_data;
output			b_level;
output			b_level_d1;
`pragma protect begin_protected
`pragma protect version=1
`pragma protect data_method = "aes256-cbc"
`pragma protect encrypt_agent = "ANDES"
`pragma protect encrypt_agent_info = "Andes Encryption Tool 2018"
`pragma protect key_keyowner = "Cadence Design Systems."
`pragma protect key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
L+CdA9Y7daQXTPgYTwCtXa6JYri7opYwawqy1C0mPXhwsyI5NHdGN4SNct+jbjH7/XLsbZpaz3xP
9oVVSFhDnfWBP/LM39X9lo2H75elzaP8Vc6BNUtdnSoSBOkfXLwCV++Prz12rDZkmjNgnkSNLSx5
MhAOZlqViGZvP0uNSF3B7+TSAz4NzB9v+2D2hzZn910J0ILsyGBaxc0sTx+GIrKfGmzvelMQ/Taw
UiC2B5lHLBV1PLg49XgdGYcwoA5zoWcJl34IU1aQWAbAPrEcd1+mjhmd4RHXjkZ+CGrDjSj1UP5o
Im36ztzVuZfQlHtV+inZhf7RgauumC4+4TNiZA==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
wfVtHKwBOENGRjWvtPjDeMLO9pLIIeX2E0Xxk3Nz1mJ9djh+hS5gRbP04CGJLcIHlIc7/fit3dEa
ESO+fahkt4Tg2QEJB9Eqrm21cxKePy5J2ixqKJ7SbWPekJokwzy67Tm5jDwfXXO6wZeaXxuxpnDZ
xSTZ259gsIMnSkqN+dc=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
KqLBjO5no9tGReCNTvG49AFAkyVJjzM2avijYFwuIXCuxGSD4Ggc6YiMGqi0PMMR3RxA5frkOCK+
uTLj7ACquIY8oIesVS/j+VjXiP5Qc5Vb+/BdmMlxPkVlLRwNXa94h8NdhyvfxMo6lxE14JfGH4AC
MaAZ6i4+RvzQJALmYTZn03VXVmVHSUnjmXghJ9ZwEW7RQhft/dgpRTnes8yRl8Pkw7iY0yowhrj1
Dnz8VCspxnfbCYHYn6/zHxRRp8XookcLU+m2BmDoCvTDpdUJCcoFl/EmMgOQZ+Qtm51UkDEUVVDV
Yqb2UIHuyjdfpS8cRpwYoiZlN+VMSSmHmRp1Vg==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
Kd4TF9QF79f0ixPqdCWWCqFber907x26CSzgwzSLqJ5SzlMP6D7Ah13KZ+R5yFMtThs5LvUWI8My
N+IzC1nuiCqf6taHSgHhMxU1pGffio0Zc5ZVts+QkHT3q/q5oOHTd8ZMh9VP59H2Ieah8B5BsUK3
JgakgP/0CC+tvRQvQCXpx4lORrubS+cOYwKswS55eYfrYXrl7/5CR8iZzsy8oOV4ZbZyiiojzf9Q
5sqwuxTIEuqfPjKNdRMF3n8aGM1t5qocAlFYDurckrv0V2+kpYelxwb0hlkxw1MFx8EP/5bypl5w
ZCf+vejYapMHFTaFwrklv12ZwwhZENweYEFbPw==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
L6O2k3pc47fZ1BzTK2uHpitjBfIhB1Rhb1sNlmUYXQx0Hzyc8V7cf8jsaUIbBjCjozKYe3cBCmRL
xFaEnTqwL/XmghHMqXnYtFq5KkB6BvCP36H0RIrHsAX6F6h/+ton1gve45/jiV5/X4qpJ0AJwdSA
07z12d/lxPYHBLmjHQeQy33APu/QiVlfaxy9xdoGY/AKyl70f9ZcfcPP6a8bD4e2kF6+7aB8RgAI
B7XYFTgKPrJhDuRUSFkiRITJmaIQlnKP/WvLEBBWaCoCV9ct97wVaU+RLaXOIDV/0SRKB1mSB73G
8sUnvRmHDruzqtv57vpTLkmtPfuKaA3Cos7jKw==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
D1DtWWS5qqMd/ORiToC2n9drDAE1yD6uFU1e1W89Wwl+wg6LPfRDcrj/ylw8YI8kOXbuUTvM6Z3a
p5QBA5+VlrR6WB8/tZsRsJp1Sf/kJb1R9ubMpNolW39LUhJhyXTZnpy4CIAvPd7Pufh7Bfbq+xak
eHi9lXp6OGD852KYP9DoUeZnVOskPMVYesvXYNvUpFzXz6MpFy0WP/WLIgMoQvlQp4xU0mDqh3/B
7THvHhovFnbTztQcmjpqddjPYBcllg4BsAjcv3JnXVzbs0ZEfY1NREatJVybhHcbAJEIQ7rDEak/
oCmGIDaxTUkvHc4H5CVpkLsx/GgyiLaOXvEUcA==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 720)
`pragma protect data_block
5MOby1xJPaFKIeJmWSudyUIVSqJgtk/94XBXDccY9oZudIJ4tnjlbl7cZnb//NJNyhvP4hvtp/6I
dkmxEJwSzLGJsfvuUW6ZMM5TVyzunFIN0oDRU91Z/Nlb9qAzcpnC9itYlOq9jUZSqmuAGVeWLkmD
s0tepr9qVmMpz6wMDzQhPP2IIicJK/Hy3qiPWoDCjJk+3xO8keW0Pdkvem3CK/vg+aw9Tx9hHYtm
NcEmXJpQLsFmoAnQV3J2xKhpvZvIYr95VAcCim4UhvWrarmANAARjCkjZp5VDfEJ8uMUjLqUlZb1
C9WINFEOv3EQzcuuTLw8Wkz709lkml8vTZcJoa+PlR89fhxhfd7BL29f6PZoXG9LtaNHLcWU1BzJ
/Q13HbfOuvPKrAVTIIZ6DrsbLE89rgkn4kSIrEuJ86foX2wbpcuYJ6gEQmFdup31HksCbdBT+Jm4
WUEC+jXyCC0e2HnK3AhptvXUUxbGB1dcnjjKPb3Owdzlnndwr7iuQdPAE90tS7hyZs0PoYE71Sss
4HUHfm1L0lwUKFMk9JKaBwDNpAGlO86x40f5pdC43boHJks73KtyrQNiymM/AhVG2ZM8dPGMfPB5
a4pTs1RFPPm6fTt8K6Ll9wY/yk+I9Cbg4xa2sOYl+zDqsjQjGBFgohrtEXBZluL3WJlU/9ULlNH0
EPOLgHV2zg4D8fjhCwgdsq+QnarrupE/3FECOcMjNbH2+j5YQENr+E4HRev7k7Oz8lg5oQW5TffU
fuAJezb+PcuFVhNuGx4y54MCEAITYe2sUUgl1muiJ0govsBhST13DVU4NGMYJDhSVew2YaeqnOQ0
q2pmj6hN2BMsXIR7OBG5makF8Z/9FWWkUlncsK0oqas0FIo/g6tODT9ioDu6NC7uydPKoy1aL/En
+2Zx5yCCFP6McHb/o6PiTJaUyrc+k0838AlP4Cj5ZX2tfPma

`pragma protect end_protected
endmodule

