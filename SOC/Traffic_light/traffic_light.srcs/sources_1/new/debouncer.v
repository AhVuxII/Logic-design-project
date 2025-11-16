`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 03:43:30 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input button_press,
    output pulse_out
);

    reg [20:0] counter;
    reg btn1;
    reg btn2;
    reg pulse_reg;
    assign pulse_out = pulse_reg;
    
    always @(posedge clk) begin
        btn1 <= button_press;
        btn2 <= btn1;
        
        pulse_reg <= 0;
        
        if (counter == 0) begin
            if (btn1 == 1'b1 && btn2 == 1'b0) begin
                counter <= 1_250_000 - 1;
                pulse_reg <= 1; // create pulse
            end
        end else begin
            counter <= counter - 1;
        end
    end
endmodule
