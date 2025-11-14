`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 05:19:52 PM
// Design Name: 
// Module Name: top_module
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


module top_module #(
    parameter img_x = 256,
    parameter img_y = 256,
    parameter data = 8
)
(
    input clk_125mhz,
    input BTN1, // reset button
    input [1:0] SW, // mode button
    input uart_rx,
    output uart_tx,
    output LD0
);
    
    localparam img_size = img_x * img_y;
    localparam addr_size = $clog2(img_size);
        
    wire clk = clk_125mhz;
    wire reset = !BTN1; // active low (reset when pressed)
    
    wire rotate_done;
    wire [7:0] data_in_A;
    wire [addr_size-1 :0] addr_A;
    wire rd_en_A;
    wire [7:0] data_out_B;
    wire [addr_size-1 :0] addr_B_write;
    wire wr_en_B;
    wire [7:0] data_in_B;
    wire [addr_size-1 :0] addr_B_read;
    
    reg rd_en_B_uart;
    reg [2:0] state;
    localparam IDLE = 3'd0;
    localparam RECEIVE = 3'd1;
    localparam ROTATE_START = 3'd2;
    localparam ROTATE_WAIT = 3'd3;
    localparam SEND = 3'd4;
    localparam WAIT_TX = 3'd5;
    
    reg [addr_size-1 :0] rx_counter;
    reg [addr_size-1 :0] tx_counter;
    reg rotate_start;
    
    wire [7:0] rx_byte;
    wire rx_dv;
    reg [7:0] tx_byte;
    reg tx_dv;
    wire tx_active;
    wire tx_done;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_counter <= 0;
            tx_counter <= 0;
            rotate_start <= 0;
            tx_dv <= 0;
            rd_en_B_uart <= 0;
        end
        else begin
            rotate_start <= 0;
            tx_dv <= 0;
            rd_en_B_uart <= 0;
            
            case (state)
                IDLE: begin
                    rx_counter <= 0;
                    tx_counter <= 0;
                    if (rx_dv) begin
                        state <= RECEIVE;
                    end
                end
                
                RECEIVE: begin
                    if (rx_dv) begin
                        if (rx_counter == 63) begin
                            state <= ROTATE_START;
                        end
                        else begin
                            rx_counter <= rx_counter + 1;
                        end
                    end
                end
            
                ROTATE_START: begin
                    rotate_start <= 1;
                    state <= ROTATE_WAIT;
                end
                
                ROTATE_WAIT: begin
                    if (rotate_done) begin
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    rd_en_B_uart <= 1;
                    tx_byte <= data_in_B;
                    tx_dv <= 1;
                    state <= WAIT_TX;
                end
                
                WAIT_TX: begin
                    if (tx_done) begin
                        if(tx_counter == (img_size - 1)) begin
                            state <= IDLE;
                        end
                        else begin
                            tx_counter <= tx_counter + 1;
                            state <= SEND;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    assign LD0 = rotate_done; // turn on LED after done rotating
    
    // IMAGE_ROTATE MODULE
    image_rotate #(
        .img_x(8), .img_y(8), .data(8)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start(rotate_start),
        .mode(SW),
        .done(rotate_done),
        .addr_A(addr_A),
        .addr_B(addr_B_write),
        .data_in(data_in_A),
        .data_out(data_out_B),
        .rd_en(rd_en_A),
        .wr_en(wr_en_B)
    );
    
    // BRAM_IN MODULE
    bram_in uuut (
        .clka(clk),
        .ena(rx_dv),
        .wea(rx_dv),
        .addra(rx_counter),
        .dina(rx_byte),
        
        .clkb(clk),
        .enb(rd_en_A),
        .addrb(addr_A),
        .doutb(data_in_A)
    );
    
    // BRAM_OUT MODULE
    bram_out uuuut (
        .clka(clk),
        .ena(wr_en_B),
        .wea(wr_en_B),
        .addra(addr_B_write),
        .dina(data_out_B),
        
        .clkb(clk),
        .enb(rd_en_B_uart),
        .addrb(tx_counter),
        .doutb(data_in_B)
    );
    
    // UART_RX MODULE
    uart_rx rx (
        .clk(clk),
        .in_rx_serial(uart_rx),
        .out_rx_byte(rx_byte),
        .out_rx_dv(rx_dv)
    );
    
    // UART_TX MODULE
    uart_tx tx(
        .clk(clk),
        .in_tx_byte(tx_byte),
        .in_tx_dv(tx_dv),
        .out_tx_active(tx_active),
        .out_tx_serial(uart_tx),
        .out_tx_done(tx_done)
    );
endmodule
