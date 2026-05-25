// Copyright (C) 2024, Andes Technology Corp. Confidential Proprietary

module nds_inout_pad (O, I, IO, E, PU, PD);
output  O;
input   I;
inout   IO;
input   E;
input   PU;
input   PD;
// b25b7022 rnd
`ifndef NDS_FPGA
// synthesis translate_off
`endif

`ifdef NDS_SYN

PRWDWUWHWSWDGE_H_G bipad (.PAD(IO),
                          .PE(1'b0),
                          .IE(~E),
                          .C(O),
                          .DS0(1'b0),
                          .DS1(1'b0),
                          .I(I),
                          .OEN(~E),
                          .PS(1'b0),
                          .SL(1'b0),
                          .ST0(1'b0),
                          .ST1(1'b0),
                          .HE(1'b0)
                         );
`elsif NDS_FPGA

assign  IO	= E ? I : 1'bz;
assign  O	= IO;

`else

assign  IO	= E ? I : 1'bz;
assign  O	= IO;
assign  (pull0, pull1) IO = PU ? 1'b1 :
                            PD ? 1'b0 : 1'bz;
`endif

`ifndef NDS_FPGA
// synthesis translate_on
`endif
endmodule

module nds_osc_pad (O, I, IO);
inout	IO;
input	I;
output	O;
// fd66f003 rnd
`ifndef NDS_FPGA
// synthesis translate_off
`endif

`ifdef NDS_SYN

PDXOEDG8E_H_G osc (.DS0(1'b0),
                   .DS1(1'b0),
                   .DS2(1'b0),
                   .XE(1'b1),
                   .XIN(I),
                   .XOUT(IO),
                   .XC(O));

`else

assign	O	= I;
assign	IO	= ~I;

`endif

`ifndef NDS_FPGA
// synthesis translate_on
`endif
endmodule
