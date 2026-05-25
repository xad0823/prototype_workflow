// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary


module nds_dffsr (
		  dout,
		  din,
		  wen,
		  clk,
		  set_n,
		  reset_n

);
parameter DATA_WIDTH = 1;

output	[DATA_WIDTH-1:0]
		dout;

input	[DATA_WIDTH-1:0]
		din;
input		wen;

input		clk;
input		set_n;
input		reset_n;
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
l0R5sweNzKnlIzxavZwqoJeMG8d68Yg3Ak5aGjXeIti4ZhQSrnMtbroxTwzZTTudManEqLn0AWZA
F5f9bjQ7mg/h9sX5soo6qTgpXP3FvZvBH6AwHYef/csblIAMK78ztgVyoxbfW9t98RMMRi4VOvGc
ShbRe8CqOUuHOiq12ye8utzzfNZcVcqJ9bDK45A3gfy0PpwXDZg/3RFByAEVpggyfXcV6qhtXATR
uh3NjMsrMlIywvj+pMEsdkIIX6j0OwamtEzn39lX0TLur/Bd+o+GhOStuZnV9CkCZX9rg3yjZZAp
wjVcvzi0bKzYI2DTNpIzCk3K++MZ0UhHkuUhSw==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-VCS-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 128)
`pragma protect key_block
U1bGA5JgQwGrr7JDLafk4C5ppLfaDVSiN1Ioq7g0Pw9rnQ4eOEtdRGN0sEb/om5Th23+bHBUFlLF
av/8XMWEllxmVV4lJEKnhebYZ3Q/2D76kmoOsy5o4EghZ6x0ljJK7q8KcXvm9/GHM9MRlumslMmv
+j8WPiEZwdAeD9UbdME=

`pragma protect key_keyowner = "Xilinx"
`pragma protect key_keyname = "xilinxt_2020_08"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
TJ6zwwbmLXAIoKCoaLHhWXd+nmdt8LPBrxZE3UM2Tc6Dyr3CVB9q9C5LCjysskBuUFEMwpw9hJUE
vzH3qCyLBavmVSvUXARa2tQ8QcFeap+qtDZjJYI7/JYRUq6Tv3aJyDzSFlyI/9nReiEH5TwLKdUs
HpcT2in+LEXN4P78k/7qWH8Eef0p+JC8MqDPwjrXTZCoWtcX8pJMVMmcz+XbLzfoM5MYXgpKKmBI
KgfOTu20Frurh+V2wFY/ksOtMCsJEmkfdxcryPc5YvJa2pTNLQNac9/YYTWJUKW9+qL7cdNEI4xu
BysHuHs2Z7vvsk1+n7d6fYD/6g2gVpv6JEkdZA==

`pragma protect key_keyowner = "Mentor Graphics Corporation"
`pragma protect key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
FZybhfdtr95x61y0gmXuL9DPPej7EUVhBs9NK5XUxdhxz6eeUTYZ6c2R711LsaszufLFY5MMNGOf
r0w4tYj+Si309V2VF27/nlIe2TOgu7U3NGc6FR9KRpms+suJcv+r6dXffwlPWil7Vv82VO/NcfXZ
5VsGlyBkd18RS8l7s6b3Me3Qs/CvAdWgiFfykQqjI9XAS5TdrTBGoGkzW2XAHo9iE6f08Ik0lfa+
wyOwC8SLV5ZF2U1qWdRYr5RmC86JX8RGKrq6bQ8fbOXo64dNrij0Cy4ZJWsTshwwtfIVSs1PgLGj
Ionz/iXktX1cMR32OdCikam52z5RoRRFH/p6mQ==

`pragma protect key_keyowner = "Aldec"
`pragma protect key_keyname = "ALDEC15_001"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
SJG5g17+ec3G/ht7WkD3KLbeDFiA5rTP65vjCffxRB+XtaKzs96KzLdTByHIa+JZHo1HNbSmWA9l
gOYwX8aHZCFhEOoBjj368mgz6hWLtaOz8lSCNuJ9KJtYOdjoCtfB9hQo+y9j1ycxgbSuF976Z5fV
bVmUb2aIQ5nTTA2NN2jAm9I/4PtPqmGp13IVZsOf2eLtqss12DipCjU9vCKpuAnePKGwg+8OGR93
Mhg6ktZ0LGZt2BRuQPAtRo59KhMwRGCAieNfFQMWocwD4XfchCc1Nvl5VGe+6gxx7qfSmXlnuVL8
BXU6vPDuaDJCjxWxe0V0mDegEXNhAGery0Boog==

`pragma protect key_keyowner = "Synopsys"
`pragma protect key_keyname = "SNPS-SYN-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 256)
`pragma protect key_block
UZwA3meM+nAmH5rPpZzdp37IBBGhlBVwIfrzKjNMnCZUR6rDxck4txAL/GcneFk0xtkYu4c+KT0T
uioUTFkT1zAR8MC9Zj6teqyovo5wbb1u5BTzEVjm19xCDRyvwei23nFVgpm52dxesJsKpa+9E8o0
dHBNMF4ghZ2bEEaJgyWxscagRyd2F3A39ThUB/xckqqdwXkEDmCTUKn2PbUwizv/6eXQDoAMwCBW
EBxe6VAAmP6lR61q1QKU0RzZywSEV4HEGzz4Jqvdm6WvbdaRG0nQoyfyyBzOYocbhhD+baviEmrG
RaJJoKgYtIL/sLQn5ZohlV4y5xnhsLCPRIYSaw==

`pragma protect encoding = (enctype = "base64", line_length = 76, bytes = 416)
`pragma protect data_block
cSX6kra4x7ZSFIVSraBPSDF4Ec2k7Df9VxLgmcYQEsYX9XU1VbNWP2H9uRaX5iqWzR46n8rb1eBx
x8LYB/NqXjybe0Bw7JTJlikQhi4+ZZSpN+5123EpboLiWkJzsl2+MsrxApERc8kEUh84RgVPbuNR
HT1d+O/vC/Xt27nV8BaTJpCQJHXn4pSwczVC0anAy796r686gScd+ZO2dcIEhk+k87hsIjsBsSnV
8zw2QwJ2vMdi9eRTUOoHUHDexA8XyXao2XXpoJxvwlUlvRB40TbETxqHMP8parlBledV/9K50idD
Z6cuz3RORLz7nJKbi5y8hIfFW3GtawEiZCnGCUM7Jw9P+UXtYmJXInwizWUlLjWTovZyrZtIFvxx
6Jq5jJccYJzEAPoZn6JBIqr4ldXgzqGtgkNZaRNBip2XsurW+XGPnh4xYBXBk5YkmMABUC3EAcyC
IhQrM3js+vLiM1QSQbpCyniZ7cuu3QCIoArZ7GWLBtzn6KmgEFcYeMtubGyyWFm3aDAQrPFJZzF6
YjRo6u/2v/qjpF8OzwqAKn0=

`pragma protect end_protected
endmodule

