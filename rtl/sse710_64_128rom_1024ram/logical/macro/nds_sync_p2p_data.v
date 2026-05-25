// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_sync_p2p_data (
	  a_reset_n,
	  a_clk,
	  a_pulse,
	  a_data,
	  b_reset_n,
	  b_clk,
	  b_pulse,
	  b_data,
	  b_level,
	  b_level_d1
);

parameter DATA_BIT = 32;
parameter RESET_VALUE = 1'b0;
parameter RESET_DATA_VALUE = {DATA_BIT{1'b0}};

input			a_reset_n;
input			a_clk;
input			a_pulse;
input	[DATA_BIT-1:0]	a_data;

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
moYAMj3Y65XC4sv7XSyBwca2hOLbdxlEmS3+gd+vBjlYCKI1iusO5z/V2nLWTJ8cmfjwgaemDndh
SbBw5W6Cs2Gbm2wmB9ANY46YiHEoEc1+cqKZc78vfSZUM6dhHQxhrIulCyTXiwKdMwcOYvN2OfKR
6T46uieOVGlhPfwNglxPx6rjg4CfF+NymOcFm9hH1Z69s7mhfmv9EZWTBtPcr8wTQNHl830RHQRl
7V7Q4iBkyaR187JJzQuzAJdLfHCEz02t7IaCVa0PN9lezhPx7PChxAft87hUceNM26Jpqkpg9a1Y
UmAPsCNEaAJP/Hb9CTNrIg7JcVAU+cK/0OuPdA==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
KpyeKaa2jnl4ddXJYylKwlM30iNuAF3Fn/Jk34zvQPCgfViV8LyLC7zAtW9ZcTYDOYiKJ+SmQMFV
ag88v5NOE3yHX/irB74+MNmnC1M9vhiQFpIBKoSgCEGnUVW3+FKxnZYP1egE9EIrus8D9Ip3J5tj
BBH2B5NT7qfkj38uI/c=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
gtCoddpNKtwmcF8X8RmAwDdeLcs0IKF/Na03eRq5pwoshyJsUCCZCnH5q6YfPj33ksgvp682esW1
WhrG2Y0Qlcr3WH0zEsdPYtvUeVAWrmddGrHDNA5VwrjUQMC7lAp6JUvG0jwqkGHImSNxzvSHuOtd
Qp0mFB5vSgGxvOvRKZ2hkdDCgEyvh29v4sJnHiuGhzzoVZ6BxTA782UdyvqyVuO4y7YsBWtsDtZZ
osA0yMj+BjOAkua9EbD+Vjg12V6JKoeR9H8LTh3Q/OyIS9YDFVXbvhl0WVhzbR81cxm7mUXkEqO6
FogNU8isFVjeawSphHJzvVX/civCbyhGyAddyQ==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
LNR/fgiBg/WV04MgTGz1oKKUgEKMQX2fD4DRyUBghFj9RYh4uUoimRqSsofTV4+eC+9YZffBX/dc
VF707Wwo3fxAm0A4AsaKkLpmEL2sr89uctM1ZaFQ/F/VJ+GgkfX7CFv+fiJktS+qGx3jkpZoXQfX
nywKFXZHHeVdHMSPxqi0xvFoAjqBpqobmdYjbttuw1on31mHksNR6PkVQy65fgJeEWDrbNEPBw/x
Cw/0fof2/8drH1NZ3R2DoLZxSzuaIeTdrCMIK5Y9TTNbQ2Tl/0+q8A1GQJOMDuV8U+hSHyNyIhjL
9lfSofqav8dTrsKu3PrRLOoqp9WQ6MpX1sMmiw==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
kv59zhoWPXAFTuSVWvyzOnwe7S6nKvKBp6KN3zpwxeTBiukJhWj1OJ94c5VphVZSw/faRY3jhOay
EbUs8t8JCXbyDC6F3521LcUAwk+ne4jbOD4bhZ9ctC8ewBdD+/IywgTZ1QtIegvqPntxxpVR6MYC
WPJHRU7UHAJAyV5ssPz67i3jRQ+I91m1xWRxuulhmvRrnkZK0o7op4armmVnEZB7rm45qHNMAtBh
DTe6a3+mTfVk949DBb7vtSWxQS1689nLTYCRZcexJ+rHo0bQ9pUGMd4XSZ58DtumOW8jCghBb7Vv
NkyaI4jtg19n0xHM65nUwzRhRbh/PAD9BOCZ8w==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
fS0tsFUAmS+tdm65SAcnIMqt+DBipgOwquNFgkninySt82lKptA7hYbV/aqLj1Rj2RsyKYWqi7yD
uQZR6W+L7U3W09wowWkluionrRanm8Jjw2eZTH8/Npc8aBI8FZgW4w/kaTP/nVd7ijfLLZJ96p48
tvkAWnnHD+eK4YYAwCKm9ql1N3xuBxAUCmBTWUyJrsK0R/on3W5yuAFTtmcImyX4BRjOjxqRkXEr
sJojT4rrdhD00LpgwuaxMBAd5bsNSyXsnQC5TctK3WDySAyn+T/bwNV8clOlV0UNb6CTA6+nkChM
OQffFcqToBDthnzEUO12RjOx4Y24WTWenOnsnQ==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 688)
`pragma protect data_block
mJy9MWVqFUr1BgaQQp1Nrr41nyFmEjhMjmov1PNLILmnjbEYOZQfX/oJpdmdfENNfp0askTJgGpC
KnH7/jmCFlA2gE5YM78vGU5ejtfs7NGHCH3KwE6o6efgsJnW6dApX2V53IDsHLhVw4AZkMAtnAMI
EWakuWrVDQcZbQH1KPYfTTltFBUOJqLN8SSw/f3fKAMsHeYR5+2SIWcKk4/LQEwAzPS+OtFVZqWw
WfVw94XVOYFTyU7zPxSCYyQRYdo4JT9/79Pq5OPs7ySzHM54+GnXUjozYzJLYRckAUW/aiYAILVU
28pGMpVvw05J3jc9eiiIjasT9GBTxcTsbtGiXg1kOqnQ/LJYKQvP0ny7yHO0udj7l5NuvD3PL0Qv
Rej7pmVEier268EQhI9lB7yvVeRbFxa6iy4Y3akjVXpoAbqjfW4BxcabgjJEGoR/aANYO6OuvYs0
1z9wkm/mBwpWLz3UIaD7DHYAYXvGCbAdtNT8YQNMaC44W8RRMb1CRsi/fA/oeUpe1w78wVGWsYwD
34bM2aElWbIqKfIfqUZ6tiPnKq7jpt99Um541ClYFzXdL6HoCYcNeqEoYeFsdqPLBsbUoldMMwXn
N9Dme0E20yXZajBuK2tl42ktiLlCEenMXeXSl/Q0zoBzZbS1dajrwtASyguo2At2/F/MXwz0w/Fk
649nyq3SiYmUb4PWnp1rVMG4w5ozSMJUu86Y7kAmAt5kCE9Lso+8JPpYatYl/LrOeYfLiZb1M2N/
sg0Z1NY6b93vILuyyVKQ5lceEfs3shjT1NZbYJpp3yhCDLUk1jdWPiJrrqdY1IJGX616/htYCI5H
+1PRdMwbPMwUyHcqqtKz6QJnRQrbT7vPtJ4UDJwyIeazYOJpc1VzHLUQ5kJCvWJlH190pb3i3U0e
d9UD2w==

`pragma protect end_protected
endmodule

