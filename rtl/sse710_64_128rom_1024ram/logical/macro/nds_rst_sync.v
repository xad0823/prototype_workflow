// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary

module nds_rst_sync (
		  test_mode,
		  test_resetn_in,
		  resetn_in,
		  clk,
		  resetn_out
);

localparam RESET_VALUE      = 1'b0;
parameter  RESET_SYNC_STAGE = 2;

input   test_mode;
input   test_resetn_in;
input   resetn_in;
input   clk;

output  resetn_out;
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
eK8/KEj+GY1JymLvfdolNUZdwr/RLEueoPLzbPm3mNlykvG+tdSHIu4cMeLgxYPWMbevrAl1TqrJ
kawfHZeycewns//CeS0LFgFMDSChLibmjBzEU/ibXCaFaUU/zq3Qo1JKUvYCaqbrl1uw7mh8z8+6
9EmtBJps89JKKs3mcc8/ajJkCqFXtGlkOSkqEby5iNiG1gYl6PWM6TY5VIAVD6/iiOJYIIuf7qVl
3KbF3Rz6vc3ZGpoP0bj85e8LKvbAQf/txNPGbUCczjTG2h4PpgnY2QTEPV0YNwAHzr/lS/yJoUgb
OPxhIbnQ3XaGZ++ZH5YQuJNFYxrCJaiSWSs2Kw==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
x6JYO0dVrG8f3bnazC72122oC6bdDM0CQ7LTxbjZR7Sz3h+/pPf5AmRymXL166L9CMwKwGU9BZDS
NRmtF5xynrWN0GWq6Dsv0ETn07l4Pz3segmB/QWlGrc/HR+5qJny8zjnAI2zaVrhkBX9U4YHY32h
MNufdBG/tbAz9zJyHTQ=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
sH13aFmCcRp94Xrpy9masFYKC5cZbD7J+HmneJd+RPOqxJCR1oNMWg2XMuRFGN/I8KfV1QjOVh/u
/7JGkemO3iw1KK07x5H/uMcClD90mkEVRfToZdHDgiHYz1uwecS5GofJyU+L+rcIMnSjZnuX1Inx
FOYpTr3Ok2VJtUWIOzReitxub8fM1GAv34+Qml/C9QNqPTk+WQJMBPAJojrAMFQqgrXHHr9/phAF
+CzBYW8OVaj6oCGKGc6W0LPmIbLkCMqGS0Mb3KXd2ev1VYPJe3aRbygqKgcI/RUgdrunDVMFbWoV
UhQDircmSBh5YefuiizmISeHKqRQpkRPSqOFEA==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
jwD3IjwIOKiKdNldo5gEa0jDd8yicPT7CajkRNVvtlmqpA4pPA/wcNAdvAor42NEXMM5Zj1ggpqO
GkbC+QA94X0Bfw2jDXurZhYPMrmZt5XqTsondE7s5ShRH5gZeimY/WGYw5bcobr02upk6VmuiQBI
ssgKwKk86NtYOCt+OkyNJHQDPi07R98ZpKz98yFHbthyEZ5coHdFZFQZ3ov2Abt2CFzrsKg+kI+1
nPqY3jRnxwIdLS5ZzwShziUp4tWrCluar6IH7IZCZkmsKrRgEQcVX3/onE9W7QNQAw3/XvOxPKYQ
3tO+kZFC7XDLqg+0h+NJA+VaXsyu+l47STB+mw==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
OOKNPwmt3gy9Ekht7rhfTzgv0jVwm/XAVVtYlcWn2kKmqmm2IAD5lTy8u9IK1PGeb+1U5VIh6NNn
fYN9CYBMsR76ILPRJEMUZDjmG3AUgTvNrrcIiXm5gtAwrP/+VZQHvweXXqHreWujsJEkKC5jB5wb
jyVg1GW8zgTHvu1og6kzQFQCMioiToINpVQ6i0XuYJgwKw3XVTPljsO4fBRpjct0mWvyE2gABPr6
/4sTxOnJH8Hi092AnLOB+Pm0EbVgVuCkwKYsydES/bFNUTWkI6Bmo9B/WYQOsUfKUjar9Csaif18
nVHZh0ultC/wDfZVLm/BpOCF/SMo+mt25P1/Ag==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
pR5vg2QguZ0TyLMo2QDU+sy78ItG4EV8C2dPPQqHyMyHUHq6f04aV/qPYDhLkDKY8rC04eTrf+K7
1viUEGfyDNC3ahx3DTcjmrIgConWyHOPyoR9Gp5BYLL+PGfaLoeuECYb44KQ/hYXo0Qkt1eNAnij
LFo4MJwb+YO8moG2EYe3ZDUr0roOONiRwYngy3KzNFx+kSUbdxg0Kiow5rZtSDlRsAuXfiyd6m//
9mTebiLzCPed22qJfKS2qNFSl7/tOUB9UEkI1XWdBDqh2W91BvTkDxDv1SZm9bndVq+P+lyPqv/t
zxhnem+L5oRsTDWbjaS7f0WcFDLzgPT5+sroWg==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 720)
`pragma protect data_block
IIWjGzPsKax9WCiRx/5gG3HGxZWBrtdb7XOiFrp0V/88fXxdRtnCScRhig/WG//dcIx5Nln6FOIK
y8Tp/uKoDdQCJIHNH11uHlunjYy5DDJ7yblo0/9xjpDYdEltxC25QGTggwmLc+VDu0GbYBBJLVe9
QMhr1Tyw6Ae8na61A9yE0mYVRYGoBhsETZZpeDwPDNALZ04D5kllQriDntG4XxHzAIxGy6gzyNxK
nmINa0hlBVBcUMD2rSFwHEkKVdCFGRC6+HvgqQqP3L3y579bzJA9gA9Bt3Iow10ulLmi9jKBzJuP
Px3ZsdLRHaiI4r0huAORgellmNLD0cT3wS9eyMTvIgqC53hQJOa1k63iGD3cnFc1WDMGc1jbZyk8
h8Q+s7Km1gOApwve16V8hb80eE6JJ5GZGo5ldCvmE+ZRWA9AUy80rhJPs54JH/G6d8eEzh4qZOKL
fNErCjK4FnflZQs5DU3lN9Vgco485zVkqvi6euGySC3vSXAgJUuGVWWK2DkchUrNytxPPO4QuxPD
nJWyigYWUkcm//jQTgR0s0z5bWrRlnoTQcjGp/KabGmRhkGHrRXpv6hlwPmw5ek9GYSWMTpJFQSP
XSTRjyGJ1EHAGuena5quz7q3ClODWruW2Sq89XvoUouiC0zFkOCDNrk9NJOdq+3qpYFGABVYxU+w
l4UXD6uaS1VJ3nCr9gmiwrYIlfdVK8yNrk+bNog/gPrKYGtSNn06AH12r4jLYo6JrlBTJjLWGsgC
FL2bURJ0JAMWgJqF95fBaq2En9wOoY+4HhmEdaazJX53pZX5ACqBkUZuMMG1+K/dNcpKfnroV05n
/mF74e5p0OrvzbKXATyON6+xfwyTvpeUqwM2q6PGHA/yCpTxwivLd5KBRhzL7g52IIkBfeM3hcAM
Fm0glEbxAYIzERobZSqK6FYDmI8lDynKbYn/9i5NFwIutd47

`pragma protect end_protected
endmodule
