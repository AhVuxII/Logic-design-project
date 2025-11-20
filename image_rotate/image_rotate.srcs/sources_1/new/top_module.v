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
    input BTN1, // start button
    input [1:0] SW, // mode button
    input uart_rx,
    output uart_tx,
    output LD0
);
    
    localparam img_size = img_x * img_y;
    localparam addr_size = $clog2(img_size);
        
    wire clk = clk_125mhz;
    wire reset = BTN1; // active low (reset when pressed)
    reg [3:0] reset_counter = 0;
    reg reset = 1;
    // hold BTN1 for 16 clock cycles to reset
    /*always @(posedge clk) begin
        if (reset_counter < 15) begin
            reset_counter <= reset_counter + 1;
            reset <= 1;
        end else begin
            reset <= 0;
        end
    end*/
    
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
    reg [3:0] state;
    localparam IDLE = 4'd0;
    localparam RECEIVE = 4'd1;
    localparam WAIT_START = 4'd2;  // wait for BTN1 press
    localparam ROTATE_START = 4'd3;
    localparam ROTATE_WAIT = 4'd4;
    localparam SEND_ADDR = 4'd5;   
    localparam SEND_WAIT_BRAM = 4'd6; // Wait for BRAM latency
    localparam SEND_TX = 4'd7;     
    localparam WAIT_TX = 4'd8;
    
    reg [addr_size-1 :0] rx_counter;
    reg [addr_size-1 :0] tx_counter;
    reg rotate_start;
    
    wire [7:0] rx_byte;
    wire rx_dv;
    reg [7:0] tx_byte;
    reg tx_dv;
    wire tx_active;
    wire tx_done;
    
    // debouncer
    reg btn1_sync1, btn1_sync2, btn1_sync3;
    wire btn1_pressed;
    
    always @(posedge clk) begin
        btn1_sync1 <= BTN1;
        btn1_sync2 <= btn1_sync1;
        btn1_sync3 <= btn1_sync2;
    end
    assign btn1_pressed = btn1_sync2 && !btn1_sync3; // button pressed
    
    // FSM
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
                        rx_counter <= rx_counter + 1;
                        if (rx_counter == (img_size - 2)) begin
                            state <= ROTATE_START;   //WAIT_START;
                        end
                    end
                end
                
                WAIT_START: begin
                    if (btn1_pressed) begin
                        state <= ROTATE_START;
                    end
                end
                
                ROTATE_START: begin
                    rotate_start <= 1;
                    state <= ROTATE_WAIT;
                end
                
                ROTATE_WAIT: begin
                    if (rotate_done) begin
                        state <= SEND_ADDR;
                    end
                end
                
                SEND_ADDR: begin
                    rd_en_B_uart <= 1;
                    state <= SEND_WAIT_BRAM;
                end
                
                SEND_WAIT_BRAM: begin
                    state <= SEND_TX; // wait 1 cycle for BRAM read latency
                end
                
                SEND_TX: begin
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
                            //state <= SEND_ADDR;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
    
    assign LD0 = (state == WAIT_START) || rotate_done; // turn on LED after done rotating
    
    // IMAGE_ROTATE MODULE
    image_rotate #(
        .img_x(img_x), .img_y(img_y), .data(data)
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
    
    // BRAM_IN MODULE (original img)
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
    
    // BRAM_OUT MODULE (rotated img)
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
    uart_rx #(
        .clk_per_bit(1085)
    ) rx (
        .clk(clk),
        .in_rx_serial(uart_rx),
        .out_rx_byte(rx_byte),
        .out_rx_dv(rx_dv)
    );
    
    // UART_TX MODULE
    uart_tx #(
        .clk_per_bit(1085)
    ) tx (
        .clk(clk),
        .in_tx_byte(tx_byte),
        .in_tx_dv(tx_dv),
        .out_tx_active(tx_active),
        .out_tx_serial(uart_tx),
        .out_tx_done(tx_done)
    );
endmodule
