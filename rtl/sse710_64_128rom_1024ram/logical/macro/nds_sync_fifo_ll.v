// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_sync_fifo_ll(
w_reset_n,
r_reset_n,
w_clk,
r_clk,
wr,
wr_data,
rd,
rd_data,
w_clk_empty,
empty,
full
);

parameter DATA_WIDTH = 32;
parameter FIFO_DEPTH = 8;
parameter POINTER_INDEX_WIDTH = 4;

input  w_reset_n;
input  r_reset_n;
input  w_clk;
input  r_clk;
input  wr;
input  [DATA_WIDTH-1:0] wr_data;
input  rd;
output [DATA_WIDTH-1:0] rd_data;
wire   [DATA_WIDTH-1:0] rd_data;
output w_clk_empty;
reg w_clk_empty;
output empty;
output full;
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
KxAPgka1eZ2WIhXEk75tUXJoA6V/9bOxddBpcczj7UOg2+jJrerb8LudDwKRB/yUnqTzZIe8OFiG
YUIehPSV6bW+5ZInvB8E9ifAOH7xqrxlYqfH5dmf1D2fSeYhIHDd0oYjI1ZJBg9KYe6VVAWxSGh+
Vy8wEdrq6vDdjxbFjMNoVw1okOCklycKVVJh4Sq/eT2dG9OLNFfkQAb5zvkywfi/3W4LGeb4jVm/
qZzWfT9MXucRTXBymxw/aIWONOyL3yEgrsaCdwARS8KU/PAH/umG3bo3/Uj5xCxlHCR7LpAQuzZr
pyywdcD0YQd6toU2D9LZKOWXF8KkB/Nh4BpBsQ==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
4Fwq/ylJ+/Vtr6pqDO4R8uivezqkXElQ3WjgMvumWNsddZLs1TysCKbrTHTK4fxN5I+n+R0W8bu+
gCv8QieqWXxA9un053ogN5JrbXoJDbUcVqSmrbtjHTJIMdDtg4qW0ZJzt0iGH0o9D3CJjFuBB6MX
tDisBS1tLM/V0U7GYQI=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
JRVJhGKlVshZNFmU3iJ+aItJmkw3Lx0lxn8GhSlPrucUw1oBaNlkeFWaatUG40rRc0y0uPxary/H
FllztCp2JtuW+PjehnPL2M30Dtqyf77iEPuIUSiiFJF47/WsbEEJXoxw+Vit8bB7q4Kv3fLDljra
R33LzSq7oSo1RSzqq+qK0pmGkhyryqBzT4fycNW2q1Q1dCPAsn2FXKPLd5ICcTw+wqgiWvPyZGIX
N2rlyX/KON93riDm3RpIO1KreyozHtD3CqqExfipLq8XgbSumqpH1mvr1R7CIkMhO3IYna0mh3ve
g6E6KTO/RryJieZEO9EIHHjCdLvdkcc3Vd+mhw==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
C/F665RrRazur2aBFtk7K1G/K0eV9UsiZftIaGsbIe1UnvGEv3VYz+F9rBKo7rkO7px4qqm958sX
am65NZ4SiEwSBNUe6Eal2uoGfvC6pX5ObaqEm2UhMp4LY4iKRfc0KYX+0dc6ZJehDe4rPuuLD8mW
Sb153JLBUlEhDGP4/4iYk8dZY+CbEuAvdc8mZ6xxSlMck93+GRUCg8BS6cvlBEY6o1mVtfuWQch0
ba4pV4XaACho1bBgOKSsb1ne+z9hQGhPOQwdg1rLqnN9vP5626ofRfguZ9t6q6mGZJbb85Rc5Grb
B+SMi9XaSdAmf2jumtKaKSyvZGpfkNq09t/hoQ==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
m0MjoaosuOireQSKzPybcYLQqgpak//4Aa9qMwtX/R4Z7OT2hC/6sswQEDEMLFWZhjpHXAs1FF5d
dB7CVJoUBpvIVevQIL0fX1UG/5hMduoRxWapKtBdJqIRfw9yRoiBrbPUFNxmHiGSAvdPkixN1Q0o
/vTMGVSIJRC24rHO+hrgA6HqkghAN9GJiZvifZg+iJmXpdoUOSqpCg02yHO8b5iaiAdQFZtInzTb
l7OMHF2s18qC5/GzZ3HrAVdSi4td/IE6zyYd9Uk0iA12KY+ABWoyj1D43/abDLbMpLFec6ksFYQm
P8ntuNY+Noja9HJs7Emi6ZHxzsWF0NNylZ2QmQ==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
VUxbwtpgxg8EM+Qg7yy2a9VaP3PSHQtBgB31d9Wp3DdXQdFq449cXENjqxT4k03iz6//P8H8zmL5
J2WJkzkFwMuAYT18WBpxMD72OA5Ej7CSLquoClYHyG+DcY2jX+oLzWvxeqXNXDhKdu7GrrVLPH4E
YAD8/PmLoBXbsA95bxyCGuFSTKsFF7cRCkrg1tPV+yaEPc6y6qORmEb4uPaduKZFREpJkgB/6Dok
8yXq49qynWM0+NGm+h/u4pN+sfIS6sENxT9k4haYeSDnWkeagKcDpjYWeR0G3x2IZklbhShQqy8T
HBvfdfu4JawksZPRKc270CNvWlShfecfkXX0iw==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 1776)
`pragma protect data_block
enDBiovYIN8jnQwWywRt+pRk57E9Tn2tNI6oJu5F5HRjdvxee6dE030CTlK00U4YYhymmMWjrxcx
3y1jEZErLEM/cqvExGNIzSj5ad9rSt/dLPvWDwITZ1mo0JT+g0CmWQ3D9gjarYgWA7UduqAbPJzQ
mLK5Fr1dVFgYAwtk8LcEQpuArPYcSHOZOATvBlsrXYd8Wh2tvm4VXkgIPJt3SxiXIbgIRrV/PsIC
WflSbVYupKjF0SS+AnUvmREUCnqGIT9CGNYHwhkkXFs+tQliCkawj2B753z32bPwRj0LsgmnTg+t
0nKc8dGQ0dv5+xd1fr89h8H51Phytzc0s2aTgyvsKz7ztNZ2PAB8fEAs9dpUCFnrtBXYcdv3K1Zy
tddO3pxhzyS+R2shmpGoas+XwxzCITHuDOpDjuOqNCV+pVLf/bZSSOgdlHFNi9A7cegU7h04/lHA
yQXamdon276jYcSJKJHqns3Tjv3B+XiSEkBQP/6fVTr8790gttZJ6eEiTLXw/TLFFWuqbK6rWoW2
PQZQY1lHJLzBzg/xvAaHbx3P7mL5by3pLAYWP8IlCY+52uowCLm1gn1fr3zzcqhcm2UoHO3tbKxb
GlmA1gAUllyEUNBL+66/BfuQBjGqz19ksKoADSMoXHTDUb94rjd5rZUHTxBOKnD5ilFvBBFDJnJ7
UEI+wTk78OtJRUBnZPDJc2VqIpgb65dtqeO0FERlcKaSxw6uCquR7ODDx+/Ox87tFn5Vrlhv8VOF
n+5g4CFrrtwiYyM5wdg1ilY3nCQPuBsvG9tFMsxTPXg6B2QKoOTwETCv0L6ilmaw106q6zMzKhDf
H/kc6+iX8fe//nSneq9LPJFrcAdjHAqHzHElRxyxKns5gx5Ec+HmEERgRmnAR3Yy13KJxD7aWE12
b+cF8UiKzuKsHpIef/LlYss2mejGgaWt3bjM1Ws8MBuntuulEp1dEiLEhggQOsWLod/aJislqIKG
8bNcMXk8XW09JVF/9Z0wAZb6m2lO0dvzSaTXjSayHgNAA3r/stOCAzz2D5ujK33z6gXFwCt9RmVM
YxtkCzFrwYhKIZPK2FTAGVPQ1sAI1fiM9BlicmyVw/qDZYDiNHtd/EtajZW0qEGIfQM1Iv3+vdl6
XfQCr1Z+C5LSpp08Pmjg9ZvSIzc/MjzDGX9WrENZQcArBSUnFhn/wQuXuFtLfJqpTKxvDs3fSvV5
7465TjV6jVOsZQrORlBNaErrO0WT6Q1QBYt+CXrzY14cL7wh+iF6cgwZTyIDFTzxaH+LPLz6nPze
KrX6/XU5xaIabKidhJTkVu27qiONd6mMpxtJZtm9llm6Z6KVKyejFQ+DiSjMbiPgIMehQdCRp1Ar
+WLKEn27u/yKxQzO11VBGxI/klg9NXqKdYapZMSmdnmyeS1cTaYrsYVnd2xAIISNduNwm0fsDLzX
csi0smJZwykGHElHN5asR5w0kTv1yVWT03wWbhEIV0MrCoIIERDF3zQEAGYUb7GJzf9lO5wvfu/U
piwnDJcUrd3Ii6TLyb6pyqEDTPsMH3bpO8BZSJVcX+zO+lz95U5VhEvP0ZRT9low0XfM4Yiz3U9F
V85UX1OxP3SEfm9W3LeZk4GykUdiUdNgxtu2w38cM22VdaltQlROhVkwxWUc6UvRlnChRdgRcyXz
fDjCw4JhQZXwsiDLMQROIGWG4cwY2rLiAnM0n5CKA4aA9lJ0BFkB5835GFTQCh2p4zGFBdFXg23f
8z4yF+yL16EB/We1V2YzL5KeUAQ/74r51o5+9wgXK34YNLBBK2OoNOEHedT1hlK+Ab5d5GcJvU7/
lS/X7cS49QOUrSLZnDSMuXi6p7FCe1xIEybU3crw6bKbZnMbxAPKk+IT1/N90tilFHfgd5oNMONg
CJJKN/13WsX5JjjXp09omoSx4ElH43AO6ACXyoEqyM3M7hY+sPyNEr4T1rdTgl8gRw5n50OYQU+4
RXn9E4j+alq/s78bP+RN9zx45VpWbGf3CirZO/zLq1DBgtPC5DMisEH+dFNUKWPQbCcBmRKe+rth
nWqW3MJvQ/LVMVt6yxxkgZxLLYoFOmRdQkrEKqo3y21On0KVvEUudUlPtCR6hx7nBEuxpq5cptQb
XHCVz6DRr2ZAUvdfM2AkaecGQ7ybm0g11Dh3pqP59sHj6VOLwK1tOl2umV8P15kqa6/3Yws8aaA4
JozVYlsjrI2hm3adcpWbLVQwBVpTHr3cqVq8X4doYlxyxoFFti01pEWqplUV+NKALZl9DKqTDTqP
AeYSbgvtRE/ALhb+kbUpXu48nXQe+ueCoyMqNex0nrPR45K16Jvq/qqbATuqahswWnzIU0zDz1AI
aB+Ej5XmD5DD

`pragma protect end_protected
endmodule
