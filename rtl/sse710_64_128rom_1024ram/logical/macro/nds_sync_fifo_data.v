// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_sync_fifo_data(
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
qscKPD+G9KGfwgfRq6RcPq78PgNC0FU+bFP2ZdJpvctnpTk9x8ZZF2/ZqpZWnHgwLINneVP21pwK
bfzKdl6Wdy8/VqNdXS4xijBHCZN0sNvsNU+w4K+ydim6ALCdZk+gBEWAaG7Z2eXQZl4EABPt+q9i
u2kCDwVnfq+c6r5ANJuWbvTJddWrJov/MQpaUD5P9tdSOheNiYKBtAqZSZ7iEfPzlFNK/X16ELMQ
rsK9feBN8gqOUo1LjPiHOm+ueDHkQ6m1I7HdqeIChkBt0gW8yMn2PDlA4A57HpEIDXGbfpQg3Hfs
tXKecIIqnDsL0WGQ9QcFuzxmtJCTArOwi4sdRw==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
fZKurj0WinTaI5x3z2R/zRpdNO/iC0hwp12k34HihbkAaFdiYvDZFUQZdSHmp3zByclc2hn0Yh/B
ALSEbB2Rb2GATZlUJp7lRwFjDWpxVmmjJDO7xY3RCjyS0wSTsSmVtvmAJm/TajYy9d9FhfnxxJZX
j7Ae4mqms5thRKwQmMU=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
aYsASPrsmOf5l1Clg1/gNinj3yiVXxIZ0on+U5wJyTLDM1ziAnVT+66PXL+aL5BTKvem9kkGiNhh
y+p53UrI1euS3d7tckdjGPGuVkKq+lsSWOir1xd5lXkj5USiuvArXYPYxx3TDcPmPgnrIeKDaDYe
IvAxOcnY+VoyHSldGnjaQkVN/gj1YbnLU52GI49Of2LTTQD/mnuEMmL7LPAMPP8cRplflBToybwm
OuciwFUEvOzUiQE/OlpYygcA1Oc8eOEn56nPbybL+0mw6fHynuq+F5VCAMb/H+hDPQHRs1CEWGb9
1Jvl9wSoHOojTCySTGIoHF3Y6VvS03iDeQVIog==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
jnzFnyMJPq1eRyPPi03XZWFBTiLHa0jn81IIu9fmfGBJi0nPPWDN8O0C6FOQtFV5dgFXLXN7MGYC
WF0FW+RA227KLNMPsmREIb1snw7GgeDiErbVXHIZR8tJoQaEE2rhDP5yyAY/Q4NRX1A+E4l+pcBp
hYCtXoaKF3hO+SYwFs3KtSr7kH03iYfYFWNF5iY2kVvlsDyJ6bUdrU4FhrEt2edRARKxj+ekCqr4
aF+okr7uaMKbPuRo7rHYqfRBJ+7hc8JIDlKHS2n+OBt6nR5c8snfFLcvuN4N6JKw/eGjEGBTMbsR
X7xVrlI6roNJBj14OQvGZHmG/JvsIk3DC6eVPQ==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
Q92BQKkB64Wkcq+BUdSpAVnLPeOApXJk2Xlssx2zL++3QcwvNcSDv6jHUIASBTee50CjBCMF4EXS
YzDATWf5eea9Wu0rVps8hDzPSKAuc4XqdFZpq4knRQWEPai0XS2xzxOdaLpNdMpRt6l0rklNQDh5
KoYe0+k6XJrVNLvrbA7MB+JcWhdcS2XM2a3UtLkgfRJ8NAj3VM0ZcAQ2GS0ja1xPpjmM8tYz92Kk
DFHHzpva2evZ0nSEFBsaCM0qmWQdJaP2LrWLxCVih1AcxEBbJitaeF7pzabLrwxxmf/T3C8N9EY8
vnq11hyiI+m48ozfqX8pPNvbtbLd6RqMQv5uDg==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
liw4GjUcL4ec2zz4Pf6sxJ5hTEt4FmLBtQz4GCp8FDhz2Zm9ggmICBIUgMGPpQhhpt6OVHxQeAsa
1d/k+EkYf73hA+xpt3V2cKZlD6qn0YAzWL96VcBcAQQRojI5E7ohaKEgTRF1tuLJ5vPDZrf1zRHz
aDiKLod+e7HUU9OT0eW5NSAdNcenTgFcqa/m2arEcCfBlm+t2QafTi87VVTkqpp4+1evKZE3RizB
1ec1iSSGA842EWRH58gQrT1oTz6gqeoePuKLaJAvNl3Q5svRZw0F89Rx75tHlsm9Soo0tDaQXSpI
01wxoNmx/mAmp0fiPvjz3Fa73erZinjsNu8eeg==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 1904)
`pragma protect data_block
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
tqtjMgd5g2MzRG9t7mL5bMkRCG3FWI4=

`pragma protect end_protected
endmodule
