`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2020 04:34:34 PM
// Design Name: 
// Module Name: tb_mac
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_mac(

    );
    reg clk = 0, load, reset; //clk, btnC, btnU
    reg [15:0] sw;
    wire done; // dp 
    wire [15:0] led;
    wire [3:0] an;
    wire [6:0] seg;

    
    mac uut(clk, load, reset, sw, done, led, an, seg); 
    
    always #5 clk = ~clk;
    
    initial begin
    sw = 16'hffff;

    reset = 0;
    load = 1;
    
    #4000;
    load = 0;
    reset = 1;
    
    #100;
    reset = 0;
    load = 1;
    
    
    end
    
endmodule
