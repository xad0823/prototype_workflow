//    Copyright 2010 Andes Technology Corp. - All Rights Reserved.    //

module edm_tck_inv (edm_tck_n, edm_tck, test_mode);

output edm_tck_n;
input edm_tck;
input test_mode;
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
iYXv1BS4Q+cXqDLZEPo1dhszSiZGKn2Gk5/o12QYR/fQCQBSKU6xLtoAPgfSrVFqhBs/VGEzD6cH
ioutVn1gPD21dMG/tnWG0kE/KQo39Yzv/6wgRcF9pFRgANVlSTZfpwLcYUcair4vHXFsvCnYyQFi
nTpOH6zjGZwDZjfpd8IR2yQk5WiCzE38G4tk9T5hmVa9qxfwY7tF2KFtXd40F4dacleHZyEuj4iw
OeTUZRPJVCBj9yaA/9V35VfRrcl06Fh3bgeEJhFGQzh8kNV/b1TzWH2yk2XofwGZHzGQViHmq3ca
MTsN21txHkKh/uGlo1vPvTWy+/dN9V522SEL0w==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
P6lsTaBxPTfdazBY09t3KonHaPfjbqhE/8PeU9y/JBQ15qomtH+SO8XMzpu9nh3DA5cQRh2gfWsn
7B3/WEvDrl6H0selSlKH9I9mr8ZXco3CJvIGYXJ6XB8UOZUceHBV6iZNYYa9JKdhkoF+bF6h7tas
3Ps1Z1fiiQZbLtg1DV4=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
HoHkU+t1KYitWrUzrtSt9mgonpavEvJJM5/qWdEAWMGjWRSmsmzemKJGf1ivDibXv6CcARuOexww
3TKNaYfgilUIdHOLmpx+KZCvKb3p/RhHNXs7uBpUIdo3/C6s2VQmGEzezkHd0QX8ukAxGxoGze5E
gq7zXWk6bzmyiog7t0s/WrLnxic2VysfFCmfQASJ/E4+rcKlPRPv81PXw1kCoZ7KiUuLmt6itBz2
tpirYZP2SoDjjqGHV/kdRmiRLW0gC8yeDv0w3K/0sZcMklRyP/vBhWgjhvavUFfuxYSshzIBQ/8Z
fWyjPAVygZA10cag17ntXzXxnRL7BUw3nbNdJQ==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
gM31OMwqNSELwPPSdSt+VUqf1yPMT33vI6vl7KfVSNgM/ZMBbRFtJqn6U004sEzF5V/iP1fhOt74
DKjGVmxXAMsLmjXJjhxr7nqSMpOUqh6WgVOwkTLMlHWTjqWeCJj9tIPjDEpPLNEk/cV871JYo7hI
ASMJfXnQY0IyeeCokWIAvHZ/PhMmqAMmOZ32n5FSu+Z+vwc5ufcVOaBh6Zuc7wUqILIG4ZvrPzXD
SrJpelUzGq4P0AuBUb6mDDJaIe4gJvh+gDkkGHpxSabHw/K8zwSkOF+etBtorvFn5z4bnRsAnd3F
Yiq3P/4aJqz1/GgGDEHXzawFUsC+yEV3903UHg==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
fxvIYGR+9DgoleHu5m6DdqnygK98bTTHnZyvyv3pwPUrFKlfGnonWGbjGrFNygJb1d7PG/m1dzZE
o0N8uVd/ZpMyEf2btAYfIEEjkw2RpBogt3wlHtsR0kCM7LD8TvmXxopLcpLJ4B//Eee9YzAsAkgK
MVKzPkOVCyMI0Od/RV9tUtNEmcxdSaIju16FFlJpbKDTFbEu2D6DzeE1BHyrUiFBaVkLqqferEj/
ZRVFG6seE1H+RNxoTKsyE4bpcCxk74eQDUUGOOWBwPqB2M1MMsmbtBLGpvP5psn/uXCl1tsWyDOC
cDr91RR4u6yGU1DoyHDP8haRKxG2hzufAV6USQ==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
ZbGC8MgWsjagiVOgXpHjK/f+6RU768ZhsJD3VcVG3/Hiv/1pj7HpluUfDJDPkP0VAo6/pSFCx9t9
oUFF0U9F9BnOpzS+WfEUh5xrGYFnIraCamJZi7WZUNngz36DXJE4Sb+mAWvM8yXAe8AIerW2UTqT
2R0a0pfQ0px6blK8JmcFMFVH23Ttjg5VGjllWcSAaaGvm5Jnbl0DCXRBFHKoKNf6Tnr2rE6PwhWH
d8h2IM976EybQwQkeFfLVgZPeVpERbLI+QwuyixGDwUjFbAchQwrdo1LPRvNlvp4Lc0cwkpdRGUg
KTeOneTPHHstw99fMI+1D0/3uPl0bEJstGhhXQ==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 400)
`pragma protect data_block
5OVx44Yp6g6Z24gT3z9n2m6vUggAORFEG7UlM00gEdCr2lwrBZDo9EcEmuHp53j6kq97ahTqQFvH
43+LvfMdsNHmqMm4P4OVvwMHmDe7qZARsSMsYqVr72fxAAR1maAkquSCVsn1ibgrXn8wFK5uq1Rl
MDns6KJeMWbfUUGNe6GP3gEQcwdQkLIhfWKXSZMVkjIloMf3F1ROmtajw91oCnkRpz1uuw06NC5d
KowUtYk44KzhUOoZ6ItGPsGLtNB0Hq/zrNsfTHyS98kX3laR8UuwQn0Rk2a7+XJshqIYzbbYnSum
LzVHl8LogLKaO4CMVJpqM+dHot3vJmnEH7aXyUWryaMDvHvBQCSBQR9l6j87v0u7h0E4n0aB4R3N
Xq9v9jkHUHh9zH4sajmEMbs+iVYBQ+tBnGkDbw7z2NCPIt0DUn4qo8odediNxD41afhAGR6PxB0a
789AdXa2XzyEiUp1ivIHu18it1PuhLMwZnIWSVTR8OW/7M7rxWSW8StirBzZGt9MJTdGaKAUL6xU
zw==

`pragma protect end_protected
endmodule
