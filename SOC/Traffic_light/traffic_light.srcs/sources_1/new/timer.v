`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 03:43:30 PM
// Design Name: 
// Module Name: timer
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


module timer(
    input clk,
    input reset,
    output reg one_sec,
    output reg clk_1hz
);
    // one_sec logic (count 125M frequency)
    reg [26:0]  counter;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec <= 0;
        end else if (counter == 125_000_000 - 1) begin
            counter <= 0;
            one_sec <= 1;
        end else begin
            counter <= counter + 1;
            one_sec <= 0;
        end
    end
    
    // clk_1hz logic (count 62.5M frequency)
    reg [26:0] counter_1hz;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_1hz <= 0;
            clk_1hz <= 0;
        end else if (counter_1hz == 62_500_000 - 1) begin
            counter_1hz <= 0;
            clk_1hz <= ~clk_1hz;
        end else begin
            counter_1hz <= counter_1hz + 1;
        end
    end
endmodule
