// ez_cknand module - Clock NAND gate
// This module implements a NAND gate for clock signal processing
module ez_cknand (
    input I1,
    input I2,
    output O
);
    assign O = ~(I1 & I2);
endmodule 