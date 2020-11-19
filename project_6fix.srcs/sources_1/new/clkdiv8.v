`timescale 1ns / 1ps


module clkdiv(
    input clk,
    output fsmclk 
    );
    reg [2:0] count = 0;
    
    assign fsmclk = count[1]; 
    
    always @(posedge clk) count = count + 1;

endmodule
