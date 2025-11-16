`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2025 03:35:52 PM
// Design Name: 
// Module Name: traffic_lights
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


module traffic_lights(
    input clk,
    input reset,
    
    input [7:0] sw,
    input [3:0] btn,
    
    output [3:0] led,
    output [15:0] seg,

    output reg red0, green0, yellow0,
    output reg red1, green1, yellow1
);

    localparam [1:0] MODE_RUN = 2'b00;
    localparam [1:0] MODE_CONFIG = 2'b01;
    localparam [1:0] MODE_MANUAL = 2'b10;
    localparam [1:0] MODE_FLASH = 2'b11;
    
    localparam [1:0] G1_R2 = 2'b00;
    localparam [1:0] Y1_R2 = 2'b01;
    localparam [1:0] R1_G2 = 2'b10;
    localparam [1:0] R1_Y2 = 2'b11;
    
    reg [7:0] GREEN0_TIMER = 10;
    reg [7:0] YELLOW0_TIMER = 3;
    reg [7:0] GREEN1_TIMER = 10;
    reg [7:0] YELLOW1_TIMER = 3;
    
    reg [1:0] mode;
    reg [1:0] state, next_state;
    reg [7:0] timer_count;
    reg timer_load;
    
    wire one_sec;
    wire clk_1hz;
    wire btn_up;   // btn[0]
    wire btn_down; // btn[1]
    wire btn_manual; // btn[2]
    
    timer clk_gen(
        .clk(clk),
        .reset(reset),
        .one_sec(one_sec),
        .clk_1hz(clk_1hz)
    );
    
    debouncer db_up (.clk(clk), .button_press(btn[0]), .pulse_out(btn_up));
    debouncer db_down (.clk(clk), .button_press(btn[1]), .pulse_out(btn_down));
    debouncer db_manual (.clk(clk), .button_press(btn[2]), .pulse_out(btn_manual));
    
    wire [7:0] display_value;
    seven_seg ye (
        .number(display_value),
        .seg(seg)
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mode <= MODE_RUN;
            state <= G1_R2;
            timer_load <= 1;
            timer_count <= GREEN0_TIMER;
        end else begin
            mode <= sw[1:0]; // update mode
            
            if (mode == MODE_RUN) begin
                if (timer_load) begin
                    state <= next_state;
                    case (next_state)
                        G1_R2: timer_count <= GREEN0_TIMER;
                        Y1_R2: timer_count <= YELLOW0_TIMER;
                        R1_G2: timer_count <= GREEN1_TIMER;
                        R1_Y2: timer_count <= YELLOW1_TIMER;
                    endcase
                    timer_load <= 0; // turn off timer
                end
                else if (one_sec && timer_count > 0) begin
                    timer_count <= timer_count - 1;
                    if (timer_count == 1) begin
                        timer_load <= 1;
                    end
                end
            end
            else if (mode == MODE_CONFIG) begin
                timer_load <= 0;
                if (btn_up) begin
                    case (sw[3:2])
                        2'b00: if (GREEN0_TIMER < 99) GREEN0_TIMER <= GREEN0_TIMER + 1;
                        2'b01: if (YELLOW0_TIMER < 99) YELLOW0_TIMER <= YELLOW0_TIMER + 1;
                        2'b10: if (GREEN1_TIMER < 99) GREEN1_TIMER <= GREEN1_TIMER + 1;
                        2'b11: if (YELLOW1_TIMER < 99) YELLOW1_TIMER <= YELLOW1_TIMER + 1;
                    endcase
                end
                else if (btn_down) begin
                    case (sw[3:2])
                        2'b00: if (GREEN0_TIMER > 1) GREEN0_TIMER <= GREEN0_TIMER - 1;
                        2'b01: if (YELLOW0_TIMER > 1) YELLOW0_TIMER <= YELLOW0_TIMER - 1;
                        2'b10: if (GREEN1_TIMER > 1) GREEN1_TIMER <= GREEN1_TIMER - 1;
                        2'b11: if (YELLOW1_TIMER > 1) YELLOW1_TIMER <= YELLOW1_TIMER - 1;
                    endcase
                end
            end
            else if (mode == MODE_MANUAL) begin 
                if (btn_manual) begin // Dùng btn[2]
                    state <= next_state;
                end
                timer_load <= 0;
            end
            
            else if (mode == MODE_FLASH) begin
                timer_load <= 0;
            end
         end
     end
    
    reg [7:0] display_value_comb;
    reg [3:0] led_comb;
    always @(*) begin
        case (state)
            G1_R2: next_state = Y1_R2;
            Y1_R2: next_state = R1_G2;
            R1_G2: next_state = R1_Y2;
            R1_Y2: next_state = G1_R2;
            default: next_state = G1_R2;
        endcase
        
        red0 = 0; green0 = 0; yellow0 = 0;
        red1 = 0; green1 = 0; yellow1 = 0;
        display_value_comb = 0;
        led_comb = 4'b0000;
        
        case (mode)
            MODE_RUN: begin
                led_comb[0] = 1;
                display_value_comb = timer_count;
                case (state)
                    G1_R2: {green0, red1} = 2'b11;
                    Y1_R2: {yellow0, red1} = 2'b11;
                    R1_G2: {red0, green1} = 2'b11;
                    R1_Y2: {red0, yellow1} = 2'b11;
                endcase
            end
            
            MODE_CONFIG: begin
                led_comb[1] = 1;
                case (sw[3:2])
                    2'b00: display_value_comb = GREEN0_TIMER;
                    2'b01: display_value_comb = YELLOW0_TIMER;
                    2'b10: display_value_comb = GREEN1_TIMER;
                    2'b11: display_value_comb = YELLOW1_TIMER;
                endcase
            end
            
            MODE_MANUAL: begin
                led_comb[2] = 1;
                case (state)
                    G1_R2: {green0, red1, display_value_comb} = {1'b1, 1'b1, 1};
                    Y1_R2: {yellow0, red1, display_value_comb} = {1'b1, 1'b1, 2};
                    R1_G2: {red0, green1, display_value_comb} = {1'b1, 1'b1, 3};
                    R1_Y2: {red0, yellow1, display_value_comb} = {1'b1, 1'b1, 4};
                endcase
            end
            
            MODE_FLASH: begin
                led_comb[3] = 1;
                yellow0 = clk_1hz;
                red1 = 1;
            end
        endcase
    end
    
    assign display_value = display_value_comb;
    assign led = led_comb;
endmodule
