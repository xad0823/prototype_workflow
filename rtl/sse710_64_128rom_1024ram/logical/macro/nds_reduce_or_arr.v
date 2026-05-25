// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_reduce_or_arr (
		  out,
		  in
);
parameter N = 1;
parameter W = 1;

output [  W-1:0] out;
input  [N*W-1:0] in ;
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
Ps5dgXcz+2JqL6OwSdiw+V/zL32M7M2I5Bu158M1snRup5/tUQYcHyDatFTCkAQjvDrOjx2cItEJ
glB348fq0ja8ubOk911iztK/HfA0FVGcwlqSTzFAezCFVFtSuzK8hizTECYm4a3dGTdu6WYkUnr6
4y62BPNJcMmpJZt1BXmdurPdOc9hLX8/PPF86XoXc/V1IEd0nRAlqpRVvSRB52STNpSP0vPnJG6U
aEd25SeNXr/Jv/T4TWg2jFbDDtrvylaNn4mJHqstSA47bJqz88pTMcRC9GngrYPbgV9p9ntuvQ4y
vbgmiu8yfCW8MG+w/M6sF+DaRHr63rvLh1vKFg==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
ioM3wIc0F67tYRQEf7i04MvrW6wXwdb3aAWfy8Yxinzxac7VHOofs8auQWZqqTvscqvtnqaULNV6
G3FjGGQ4xMqSHeL+7bt+eEjafu+BNtthgcgsyyt2HmH5FpaoAtuYes+nXF4VhV9neISUlwh30E+r
yLSrQfjSBjZJe/IaF9o=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
HziVaTakW4IMQAW0SQ2OlZwS6AoSUd+NVBvec6Al5G1B+OKeeEBQqgJIzmFNqCoijGaHyFtCyJii
jRdLcILxp4wkMBBPAeJBvQ/+FwwAYg9hcEl7tSCe2ASGmZupeWsigNrEkfMzWzJEh9ArtS2danMn
VY3YhfkZ08LABROxZSvJMbuNZtK43Ps+VFK4APHIDNlylrYzT/pSKCnR2aOk2WGGXbz+xCpVigyo
JgZvhYHWonYhp88ZfsKe2fCIvT58cU4/17knvLhQgTve0uvC9vpxuW8pGzHsEyFpOphbZzakWo2q
On3nHXZImprcyGPcFvYf8j1RvzwpykvJGQkFcQ==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
muNIOC+2PCIBdcWJE2FZmPA9PyR7KX9EZ3K7eIEGwLtvpyxub99zIxW0QRI5MMzvvYvis7R8ftoX
5Y3hONCo2yT+UpY6oHKYMFSaz4kvfkHszgdEtYdpmj8Y0AAyrKtPtAi8Kw5Kk1NII9S0cvSAIOWU
SMmN9uT0N0vnKrOkQ6y5swjOtyRaNzNedmV0UaxifMUY+CLZqhG1R0tI1GZhkMDmQbzpj0X/KIQH
26L6BLaE9HhvjWxv5Up/7TBrHWhfUYJ213y6/r3QsT2Tp9+UrSwP1kU5CNn5C4QRCaYxOLRIs39m
Vewerto0AS07Y/ybv6GyhbK/4mMCjI2RENYMsA==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
pd3lFSSRwpy6f3MszWqOpxqBu3kthHgXoarKbNii4oDEytusiCYSBuars3wR2SUvs7T6oDzudcyV
/NLa8JQMI+GsAma0RPxJI++LnoKb6qK3Nx/SAUdtSjxOG63dKkuV1auMc03JJWTGmTdFAlzPAX22
qxhH7ZHW0oYPokpHf0k4c08pvRSPOA1hmdWIxw4O8ECZSDSq2IcvD5ZkBjyemI/l1KqXeM18tfg2
npVLZU4tuz3omBBQHPM91vl/JIQlp//9HVbHdgW3tPSvCQPnF2Wf2b5HCUNxKuuIksPXyz92jQuy
5uf2uJSvxa9V5nzjH7mvL480vk9fHPV/w+UVLA==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
ojaOQreyLWZtZXegeGNq72YmOPH/jL8d0yc4ggSGag13cPoNpnKFmNLHHjqHWAGOAkQdGSUPAQSx
8GbaDQRrGiOcwXINDLu1+QbijTDtsvQpBdM63ZPU/yZYuC0HCu9QzF7opl8Zj0zvRCHlPcVPkKp7
S/knHt1Vj+SbrKVSBthktUK2iJtpfOEK9/cdUb6+IOfWz6nKho58fiBJkHzuhxBWFcvBEXt6ad23
fwxgThO6T1e52Jvg5yuuINQc9YwdGvbSSqNicGThF73L6IvTLvesHuV8JYrFWnJ/XhkZMrK/ug/o
64vjvOIUBt8k4BX3n1SxOFYsgzb9DpvwuYXzGA==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 368)
`pragma protect data_block
rjov3tsaOjz4zVDNIxI86jxlRgqaF52VvFpbD1sUtXh0aEnNb8FvwEf7yj0CFYrcJ+AF++msT1Dr
hrX7d5qKMZrzRNRLPQ1eAvRdzvLIYRREY/mgSexo7Zuf4nCZ2e3rUUhEyUgF0MVVdekqDjv1sOaf
bFmd+e4fftiWkmYCJa1cZ5k3p6fTpJ0HhDaxJoGC3sNOJHsz1Hn+FEfXWnL6v692vI2HE8ToEgsY
i/OLoRx0N81N8AhgkEYrecKRtFvXkMaOb3BRa0M6gq402oAdTVfzcrykESDrncchimLu85eaV2Ji
p8aOKeUgwvHCze5Sc/OBvB9bY99rqBelk/bemqLVSDuNyBWGQ0R6Akuiti+DhCJyo6dxH57MqEhg
RxqYnywUFpitc1F78tQQ6Ifb9WYbQRS6pCSnig55TBPTMT4vxY+EeVq3iHKb+xPiYQ0kkCoOhidU
0EPpnxGZz/hi2fK3USD3/W/hT2YEn/YKzaU=

`pragma protect end_protected
endmodule

