// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_sync_p2p_cl (
	  a_reset_n,
	  a_clk,
	  a_pulse,
	  a_ready,
	  b_reset_n,
	  b_clk,
	  b_pulse,
	  b_level,
	  b_level_d1
);

parameter RESET_VALUE = 1'b0;

input			a_reset_n;
input			a_clk;
input			a_pulse;
output			a_ready;

input			b_reset_n;
input			b_clk;
output			b_pulse;
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
gdSNaoFfUKfubPfcDJDM2nfQqyfikREdPQwiogxCSGQk4qk5zpLgPEgZsfoe71A+JyU7a7Cup0pw
hrNXmU4te1zASX2V5lHaCP4QzsaDVnpQIGCj/d7NMGcz7qxU/joc/j93BHJUoOb76W3scgvsvvaX
UCuHanRtVJy25o3f1WXCoTeg6AncoHxnh3DJhN3OD5QlJXgggFXL4Tsm8vtLiChKLJdP1m6Ksij2
e2IH6e2mfgfRK694dov/C3qyqwRLAuINa/sQkW36MivE2RBx/EG9jJRTjun7YrtNE/DJpD+VKtKB
CE/U7K/li8+DCXYeJD1WcmQn47uEyFrJQ540nw==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
QWf8JICere/v6B911axG9EPekPOuHjTrkiFnFO+oFM8TCRnrYS4JZQm2/fyglkMVKL0z6Eeyt562
LwcEsg9mFOgROW8+SnymdB8PvaeF0lzsxRrMu1BHLa3YNGlnpAAtA8lOCZx1Be+Aoy0ngUPXEu9a
ul/SO71ga2779vYn9LQ=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
c87EqZl7ESzz11EWwL5QCBUcHnHw0zsfoIJgem9Jum+v4a4LzKFf6yryyQgI9bZMLvuRwRjMmVsr
+11R3NJEGFzqs2xEGQ5RMGVgmeoZPwxHKgkBIChIwlOcULEsVYCH5N+vNJmZKphqr9G71+OC/ffU
Cg3CX5biZ/BImzPnU8EeoxJsrYBB6MSjGs1u5uyc1gBgFbabQSifcn3GnVy8QvctVJoE+w1kOjFD
JZKF1+m2GsN9QRwndrXnTOBA8VQXyuINSvld+BuPGohWHWQ8p/OrybUUc2NvHGXJZ3Kr6317YRHK
tnZRh5b8cq5jzgW0j58sZ5AZ53V4mY2ZPZjYxQ==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
gHRLI9tyFxGlwlZvfweHDkiYJipt2JSLQHueQzCBT0f1kcJGtYb1F3DB/9WByAxG3pmdQROWLCI/
xhRrPg4trIM10Dyq+o/tktAJzj6YQJ7j870LsnvQ5nsp0HfRRYwEDGC8jlThWXG0/ELl4/xPBgVQ
xmDfLL2wBpKn++VAVJ9AUR0eGScxmpT9zOqcV7O3mJQD9xc9G0OQoD/vSxYRGdMoZ66NOCoEcG4L
25XFa6zFlWncwImp+YTk4xCQP2maHeeH7xbCq64UAypddctU9i8QgHtWHI/bX+qykBghZE8lMwLs
NJsvpvswxz7QG1nY9b0su2EeTW0KzRXSLLX0qA==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
JTT9OyjkgOHFkJiWV0+b7BjKaGzGafxrYiHYtBK1YOMlDWnfLT8pu91HFzA45fQ2GtZTAUD42sfV
XrdsztyAbWNFXiJ2S/8/hxwiRWmmD2pHqRX68Ti8ilJOOxP9IaOZqoa3mWBEcW2tGKu45Lb7iwLL
RPgk5wy5x1tMPd/8HPDM+hXR/7HyS+N+5MuSQLuUYwhR+7/PYW3h+4+y64BRjA6tjD4lP0AG1AaL
nCpFlw3eAbknZdCxc7HbTwJ7T1azin7DCk759SC4E/iOppASPfLgiH02gGmT6R81xNKYJk9sDAZD
tzala57HwUcAAJThFYDMd60l+fMJMtWY4h1Kgg==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
K99VDzOxQRzZVv5czkZ70BuRlzqS0arx563sT5ecq2uRVKBKvY6Jjtr3aVTamkB09xtZul2EIw0J
o0e42GGlLMKTr+hJ0oq2AsxVx4VjNjLsFKGYfSUo+kd3fTACpfzmQ2yQMUX9+SJjShY8gGoWA9EX
bzKmiu7wiL5ocqsGjfhFXhvDlvejI2nqo8hPoFrlHYx0G9QBfjix4NIAtGV8JfJtlX0dRcqa+h2o
xTzLI9mBasBRSvYaXeL1fadD0yEhKpFmDNOEaotupWrjZxmzXavXXh299eTVGlIaw3btl9RVYJ8D
QH+7W2sIDQNgk6w+GYiJSv0mm7T9IUKt6kL/Mg==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 1296)
`pragma protect data_block
t/FIlTXq04+7eLBAXPTd3hKATys4y2n5YT4kcdxLUMBnwERxgxATuqdzH9ceoyg2nGa6/kgtJvmS
ZwGUZ3pIcV7zPnqxH/YJXXS5R/YFbmdGqUkR9PRb0EtkIFw5Ysy8QJo2Ir15jbtl9kubljapT4jS
giWKUfbGdD3htBxdMVLZX78QvFiw2PFEkBTpwT7cTVqSGK8yqZ/Hu5Qqg7S46u1dGTxVaUkd9zIA
XIzPpLrU3etbyN8Qu8kTWn2MCiCtoEa6w4ulb+zPNZsZ0xLYGCiOCCFIZK7xpxECxLAE5SN3clVh
UJjGPQaIOc6q8+sM7Q7SPyDXttFYj5zguCdF6jc6MuEDeYdmb9yqR2LqVc3TMttc9QVoZx363LWZ
70qJ10rI4lGqLI5Wsts7r5TtBw761FpusGQ10uAN2N7DjA9HharQzCs5ogAY3mzLrocNzo05XSQ3
kr8T+/W7AAZ0DKrVOLJWzyyC3cUrigBhflYjNI2ewTvL7yIPl6gQW5NFY28AhK/S+WjjjMeEdHae
UyaTjM6ISSBytP9PL6+DMYgOcm5VSTnlqUpfMNshy6ys5xNw7XOvR4AalvB+Tub1E5mEbY07IqZF
qm4Kz/fzfCDhA26IUBQlK2UZ1yamnWzUDp6QAnFbthGR2ZB2B9abldSGmzMEWO4NQEZg2Nwb6qyc
KAtE9474PobSVc8Rpt0mnOj8Qrj5vC8FRqDytzkYXD35DFuZKDnJEKuuk8E7ua70YX7FAYFqJCLB
+NJ9ofYkb50Z5XzSTbL0aEd5uZsV39PsNpd5ymwYMlImL7mD6ipq+uCaB71ZJNNLK+Ul49KjNHNX
we7ilPzTwUecLDhm/80ABb6S9zDIH/L9aQ3v6pjgBIAe/LVuO4zurkurPkqgIICe1aj9Wq7x6j3E
8hPhfyoQXNc1U5ebejX7etp1hFCwNnH2A2hNcw3KhrekBxxil3OvB52Vw1eY2kjNip+xDflD1don
gnBoG7flJVv7dStdM+6gJIbW6NVfS7zCti9BL1Q1EGrr8q5WJC5fAar9FszyfEXxr2+hoCoPtdAH
84UGpGL+rR6qTSloSrVZ02DVC9q1k14r2Hn+gWAL9gCsSDLWlKijUlUerDDSfwbdesQFDfhcZyGK
hqYJJq/WOdKJ/75/w8VkVgqSZdUtDwZneMgEm4iNtGfyJJ+Wdh+eABmMrCa/VESOcX2X88Y5+d3P
ZrOMjG1kqGGVDi6r4dYr3RwTdi0eINHPMrx0/MCmfFseyVrdAVJTzppWoWSTnOKo6tDa6YYhWRG1
bi7clIJcPxgAQ5e9SpsBc0oAfpTaicLa8W8c41ZZnnI73x41Ol1wv1R+DIgYEwzoWheV+6t+qsSL
ktze1K2lG1tEIg0mC0oRmPTHfpjh16JJCKs/2L+oW7h5A6fyTWBi0f7nRSEFE16L6pSgK38+svuP
TK76Y39uneIhU2MMtK1aT1sAE/nlS7fNuLshl0XNziXEh8Fq3Dl5E2HLWK/ZqN18S2lwNF5dZZlL
Gpn2iNFI1ZlJn2Rh+mGudeAdS+ec9fzLh5HWpa03O9J4Nt9FxHolF5U5Fd7AoJU2KGFj2MwhR0Tm
Y6Q6MlPEoIDfML4vnoMlDQYi/cTqM8aJxP0LaqCXSul/ZIV0g/rJNEmKZ60khT0WLn86VFvuAB5r
zvo6TOkN/U9v1TScqyEe/eOJYVy8D3IM6n7dO3ZemGyP/QP0uSTd1mhf

`pragma protect end_protected
endmodule

