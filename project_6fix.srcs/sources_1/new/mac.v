`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2020 03:48:50 PM
// Design Name: 
// Module Name: mac
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


module mac(
    input clk, load, reset, //clk, btnC, btnU
    input [15:0] sw,
    output reg done, // dp 
    output [15:0] led,
    output [3:0] an,
    output [6:0] seg
    );
    
    reg overflow = 0;

    // Accumulation Register
    reg [14:0] accumulate;
    assign led[14:0] = accumulate;
    assign led[15] = overflow; //Overflow bit
        
       
    // Set up multiplier
    wire [7:0] product;
    reg multiply;
    wire stop;
    mult multprod(clk, multiply, sw[7:0], stop, product); 
        
    // Set i[ adder    
//    reg add;
//    reg [15:0] sum;
//    rca adder(clk, add, product, led[14:0], 1'b0, led[14:0]);
    
    // Binary to Decimal for seg display
    wire[15:0] seg_dig;
    assign seg_dig[15:12] = (accumulate >9999) ? 4'b1111 : (accumulate/1000) % 10;
    assign seg_dig[11:8] = (accumulate >9999) ? 4'b1111 : (accumulate/100) % 10;
    assign seg_dig[7:4] = (accumulate >9999) ? 4'b1111 : (accumulate/10) % 10;
    assign seg_dig[3:0] = (accumulate >9999) ? 4'b1111 : (accumulate) % 10;
    
    // Set up clock divider
    wire fsmclk;
    clkdiv clkdiv(clk, fsmclk);
    
    // Set up HLSM state register
    reg [2:0] cs, ns; // cs = current state, ns = next state
    
    // Display accumulation register on the sevenseg
    sevenseg segout(clk, seg_dig, reset, an, seg);
    
    // Initialize state and output variables
    initial begin
        cs = 0;
        ns = 0;
        done = 0;
        multiply = 0;
    end
    
    // HLSM combinational logic - Notice the use of non-blocking
    // In the sensitivity list, we now put the input variables (up, down) and register variables (state, count)
    always @(cs, load, reset, sw, stop) begin
        case(cs)
        0: begin // Init - Initialize accumulate register
            multiply <= 1;      // send multiply signal
            accumulate <= {8'b00000000, sw[15:8]}; 
            ns <= 1; // To Init2
            end
        1: begin // Init2 - Wait for mult to be done
            multiply <= 0;          // Turn off mult signal
            if (stop) ns <= 3;      // Multiplcation is done, move to wait
            else ns <= 1;           // To init2
            end 
        2: begin // Reset - Handle reset being pressed, reset accumulate reg
            overflow <= 0;
            done <= 0;
            accumulate[14:0] <= 15'b000000000000000;
            accumulate[5:0] <= sw[15:10];
            ns <= 3; // To wait
            end
        3: begin // Wait - Wait for load or reset to be pressed
            if (accumulate > 9999) begin
                overflow <= 1;
                end
            else overflow <= 0;
            
            if (load) ns <= 4; // To add
            else ns <= 3;
            end
        4: begin // Add - Add product to accu register, trigger done
            done <= 1;
            accumulate <= accumulate + product;
            ns <= 3; // Back to wait
            end
         default: begin
            cs = 0;
            ns = 0;
            done = 0;
            multiply = 0;
            end
        endcase
    end    
    
    // HLSM driver
    always @(posedge fsmclk) begin
        if (reset ~^ load) cs <= ns;
        else if (reset) cs <= 2; // Handle reset  being pressed
        else cs <= ns;
        end
endmodule
