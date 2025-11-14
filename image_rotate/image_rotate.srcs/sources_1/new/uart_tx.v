`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 04:17:26 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter clk_per_bit = 1085 // 125MHz clock / 115200 baud = 1085
)
(
    input clk,
    input [7:0] in_tx_byte, // byte can de gui
    input in_tx_dv, // lenh bat dau gui
    output reg out_tx_active,
    output reg out_tx_serial,
    output reg out_tx_done
);

    reg [3:0] state;
    reg [10:0] clk_count;
    reg [3:0] bit_index;
    reg [9:0] tx_data;
    
    localparam IDLE = 4'd0;
    localparam TX_START = 4'd1;
    localparam TX_DATA = 4'd2;
    localparam TX_STOP = 4'd3;
    localparam TX_CLEAN = 4'd4;
    
    always @(posedge clk) begin
        out_tx_done <= 0;
        
        case (state)
            IDLE: begin
                out_tx_serial <= 1;
                out_tx_active <= 0;
                clk_count <= 0;
                bit_index <= 0;
                
                if (in_tx_dv) begin
                    tx_data <= {1'b1, in_tx_byte, 1'b0};
                    state <= TX_START;
                    out_tx_active <= 1;
                end
            end
            
            TX_START: begin
                out_tx_serial <= tx_data[bit_index]; // start
                if (clk_count < clk_per_bit - 1) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                    bit_index <= bit_index + 1;
                    state <= TX_DATA;
                end
            end
            
            TX_STOP: begin
                out_tx_serial <= tx_data[bit_index]; // stop
                if (clk_count < clk_per_bit - 1) begin
                    clk_count <= clk_count + 1;
                end
                else begin
                    clk_count <= 0;
                    state <= TX_CLEAN;
                end
            end
            
            TX_CLEAN: begin
                out_tx_done <= 1; // done
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
     end
endmodule
