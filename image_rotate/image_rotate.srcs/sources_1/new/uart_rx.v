`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 04:17:26 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter clk_per_bit = 1085
)
(
    input clk,
    input in_rx_serial,
    output reg [7:0] out_rx_byte,
    output reg out_rx_dv
);
    
    reg [3:0] state;
    reg [10:0] clk_count;
    reg [3:0] bit_index;
    reg [7:0] rx_data;
    
    localparam IDLE = 4'd0;
    localparam RX_START = 4'd1;
    localparam RX_DATA = 4'd2;
    localparam RX_STOP = 4'd3;
    
    always @(posedge clk) begin
        out_rx_dv <= 0;
        
        case (state)
            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;
                
                if (in_rx_serial == 0) begin
                    state <= RX_START;
                end
            end
            
            RX_START: begin
                if (clk_count == (clk_per_bit / 2)) begin
                    if (in_rx_serial == 0) begin
                        clk_count <= 0;
                        state <= RX_DATA;
                    end else begin
                        state <= IDLE;
                    end
                end
            end
            
            RX_DATA: begin
                if (clk_count < clk_per_bit - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_data[bit_index] <= in_rx_serial;
                    bit_index <= bit_index + 1;
                    if (bit_index == 7) begin
                        state <= RX_STOP;
                    end
                end
            end
            
            RX_STOP: begin
                if (clk_count < clk_per_bit - 1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    out_rx_byte <= rx_data;
                    out_rx_dv <= 1;
                    state <= IDLE;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule
