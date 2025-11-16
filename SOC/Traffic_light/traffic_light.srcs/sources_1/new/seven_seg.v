`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 03:43:30 PM
// Design Name: 
// Module Name: seven_seg
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


module seven_seg(
    input [7:0] number,
    output [15:0] seg   
);

    wire [3:0] bcd_ones = number % 10; // hang don vi
    wire [3:0] bcd_tens = number / 10; // hang chuc
    
    assign seg[3:0] = bcd_ones; //7seg_0
    assign seg[7:4] = bcd_tens; // 7seg_1
    assign seg[11:8] = 4'b1111; // ko bat
    assign seg[15:12] = 4'b1111; // ko bat
endmodule
