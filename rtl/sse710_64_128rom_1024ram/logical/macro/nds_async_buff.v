// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_async_buff (
	w_reset_n,
	r_reset_n,
	w_clk,
	r_clk,
	wr,
	wr_data,
	rd,
	rd_data,
	empty,
	full
);

parameter DATA_WIDTH = 32;
parameter SYNC_STAGE = 2;

input				  w_reset_n;
input  				  r_reset_n;
input  				  w_clk;
input  				  r_clk;
input				  wr;
input	[DATA_WIDTH-1:0]	  wr_data;
input				  rd;
output	[DATA_WIDTH-1:0]	  rd_data;
output 				  empty;
output 				  full;
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
g0U3chww8KUPjn/+5l8iCCmr385lMxTebUDNb7BLRsJQKJQrWrgz8EYP3c2F9FRH6GF7cU9Q0ktC
EC58dx6mvS+RNFSQiwJgCxX8K3AtwNWlDxA+3cvWZsN6+BO1bzywxaoEQ3A6rJSPI2FRfLdInnzA
1P1KXfgCeE+Et+rkLtc9Zu3u+meXtHsBtGLgb54DCxW1w3e8qq3vDYh6WH1mMIdi4GbUELivVcu1
ACbdJHVFYuI2UmSEkavXaPSdE/q3PeVhZVanOpHQoLxaaHFRTxyiIVpfNHywfJfQeGkEqBmprwWG
XshAhQW5XtS5ZnCbm1/+chkx/Aeh3H2RI6XggA==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
LIgxdVwrsjdb7C0HJ08qmKjAA0HeYLNq8A0S7jPHbVV3Z7NGbNrZKLEqYanO9+mM3KuhEOMyW6Fj
5iOPnUPotGSzCOGQRvEzUbLRaJWAz9PV5dPm5dK9EntKzt0TnQO4HtFAE3QtDgB24HgHT9tkX9tV
pZQ2s3TMR0DDVU0mHCQ=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
AmnMLEyzcckcvz6LX/4Nb8kNiiLaNdaknjrNw8RIlznkBCRxJDfd8t7tcfz2nVJoKiOFfTyRqaSC
CwXYGqm48crDSW6NR+zNlwgm+T5YVbj8B3bHmmgZJ0p041lA/KFydva695Ek783R+fo5locRus3U
zImfQq/wP3E/UGVers3/sSzwGVOQzrQ2BkKBEYpCFOavNl3hNXSzbywElAdCqNJ1G0lPd9trU3OR
iK4sf/OEL27wWQGL1ZpePrQFs2UhovlMeVfuRa9rQsYUpuKUZOAeIjD9t2y/b4DuzwR8LFttjJXU
/1jNOlGXv6OwYTVWAWi4E5d21VHGkKz9Z6MvRw==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
ewePWESfudE3L5nH1zrr1kjtZAjyP2mCeCHuRiEVkveXFz6GmnnHTPFS7BdafJ/zn70tNrGEuEfY
pk2B/xprv+XuWi7h9IJco7tGt6rsXgbc87I/MAB1IQ95+Is1bfYV7SdfAZ7MPWX2znaCp+beQZ+P
wnfNDp/tl+xvtWupjgLo5Bhn1/pFky/x6OY5yAQ9nTW1NWN1tZb7mNEdJzopT1XQ0U6TMf+a3oGO
dAG83td1C0vu5YrZd2fx77bsyrqJEOsRN1vnG6HIeCBsuXO5ckP46y0OtvUI+uPvVVTxAMZ8m5Df
yMROBfsiDBWqqp3RSrVrCTerzMj0HsmSyQnu/Q==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
ErALA5w65S+TvryGfUo1gcaR5MwhSc7xK5rG9NQUe1Y+GeOdKXKutU4MsxmAFcWh73lNFqGyhvpm
QckB4s7YpykzSnOZN42Iy4B3Jt7HiLkvksxXLO6kHUeDSvPRletQL6w7IFb3ToIKwSw6Ef2q7VdZ
BiplNlZIS7hJgvYYA8F3QI0Td0KLKF/mrjksyltyM/W0IcSGqUo1c2zJltB1lyM6bvEW0VnMLON5
rLeoXIpL6R6I8ZA4NSBQ2yLgIW7IwBJ6pKiT872RqWO8OVNM2z12MGIJlO0ycjHzyaghgCteQgmP
aEDY964OsYo+gn3XRePFCeTt7c8Z5xmnTemsrA==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
JZUIdvYe02p5DZdExR9t3hUOhhUAiC3uUnp+xpRbS4PibnJ/n4p6k4vGRWvkXOI0wzyZfCNh63YU
5F9UuNZ/QUpfena9pg+VRjJUtcOiapkNFYveFOZ1T436ncdg9S2+3sFeBDQ0E6nUwg9thRXlxCWl
5t6n+Zjzj/Rgx5K/cJsNu679Ivdfb/Sm91bTOBClVo8dTtW+YGlmHxNusssX5jlF64Bg8+ddxhwm
GS6sdIyoU7HU07zM/StkL7rXP37jqHoO5xZVFEIan7cZKC6vBDuz1Bp5rmYWwI8/T0NEcPvahv62
9tOWCIW+d6r2d57Xc7NbgEM1jZs0AoRi8RS4ug==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 1664)
`pragma protect data_block
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
gqXfXZ7a+xq2n38=

`pragma protect end_protected
endmodule
