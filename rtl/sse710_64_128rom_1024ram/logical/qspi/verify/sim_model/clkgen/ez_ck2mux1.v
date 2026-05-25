// ez_ck2mux1 module - Clock 2-to-1 multiplexer
// This module implements a 2-to-1 multiplexer for clock signal selection
module ez_ck2mux1 (
    input resetn,
    input clk0,
    input clk1,
    input sel,
    output out_clk
);
    reg out_clk_reg;
    
    always @(posedge clk0 or posedge clk1 or negedge resetn) begin
        if (!resetn) begin
            out_clk_reg <= 1'b0;
        end else begin
            if (sel) begin
                out_clk_reg <= clk1;
            end else begin
                out_clk_reg <= clk0;
            end
        end
    end
    
    assign out_clk = out_clk_reg;
endmodule 