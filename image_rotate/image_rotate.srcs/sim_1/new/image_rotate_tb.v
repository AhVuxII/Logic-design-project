`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 05:55:38 PM
// Design Name: 
// Module Name: image_rotate_tb
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

// Settings -> Simulation -> Simulation trong tab ben phai -> chuyen xsim.simulate.runtime tu 100ns thanh 100us de xem het testcase

module image_rotate_tb;
    parameter img_x = 6;
    parameter img_y = 3;
    parameter data = 8;
    
    localparam img_size = img_x * img_y;
    localparam addr_size = $clog2(img_size);
    
    // modes
    localparam rotate_cw = 2'b00;
    localparam rotate_ccw = 2'b01;
    localparam mirror_h = 2'b10;
    localparam mirror_v = 2'b11;
    
    reg clk;
    reg reset;
    reg start;
    reg[1:0] mode;
    wire done;
    
    reg [data-1 :0] data_in;
    wire [data-1 :0] data_out;
    wire [addr_size-1 :0] addr_A;
    wire [addr_size-1 :0] addr_B;
    
    wire wr_en;
    wire rd_en;
    
    reg [data-1 :0] memory_in [0: img_size-1]; // store original image
    reg [data-1 :0] memory_out [0: img_size-1]; // store new image
    
    image_rotate #(
        .img_x(img_x),
        .img_y(img_y),
        .data(data)
    )
    uut(
        .clk(clk),
        .reset(reset),
        .start(start),
        .mode(mode),
        .done(done),
        .data_in(data_in),
        .data_out(data_out),
        .addr_A(addr_A),
        .addr_B(addr_B),
        .rd_en(rd_en),
        .wr_en(wr_en)
    );
    
    always #5 clk = ~clk; // 10ns cycle
    
    always @(posedge clk) begin
        if (rd_en) begin
            data_in <= memory_in[addr_A];
        end
        if (wr_en) begin
            memory_out[addr_B] <= data_out;
        end
    end
    
    // test
    initial begin
        
        clk = 0;
        reset = 1;
        start = 0;
        mode = rotate_cw;
        data_in = 0;
        
        #20;
        reset = 0;
        #10;
        
        // rotate CW
        load_image;
        $display ("original:");
        print_memory_in(img_y, img_x);
        
        mode = rotate_cw;
        intermission;
        wait (done == 1);
        $display ("rotate CW result:");
        print_memory_out(img_x, img_y);
        
        // rotate CCW
        load_image;
        $display ("original:");
        print_memory_in(img_y, img_x);
        
        mode = rotate_ccw;
        intermission;
        wait (done == 1);
        $display ("rotate CCW result:");
        print_memory_out(img_x, img_y);
        
        // mirror H
        load_image;
        $display ("original:");
        print_memory_in(img_y, img_x);
        
        mode = mirror_h;
        intermission;
        wait (done == 1);
        $display ("mirror H result:");
        print_memory_out(img_y,img_x);
        
        // mirror V
        load_image;
        $display ("original:");
        print_memory_in(img_y, img_x);
        
        mode = mirror_v;
        intermission;
        wait (done == 1);
        $display ("mirror V result:");
        print_memory_out(img_y,img_x);
        
        #100;
        $finish;
   end
   
   // helper functions
task load_image;
    integer i;
    begin
        for (i = 0; i < img_size; i = i + 1) begin
            memory_in[i] = i + 1;
            memory_out[i] = 0;
        end
    end
endtask

task intermission;
    begin
    #200;
    start = 1;
    #10;
    start = 0;
    end
endtask
 
 // in ra tcl console cho de nhin
    task print_memory_in;
      input integer M;
      input integer N;
      integer i, j;
      begin
        $display("//////////////////");
        for (i = 0; i < N; i = i + 1) begin // row loop
          for (j = 0; j < M; j = j + 1) begin // column loop
            $write("%x ", memory_in[(i*M) + j]); // print the data
          end
            $display(""); // xuong hang
        end
        $display("//////////////////");
      end
    endtask
    
    task print_memory_out;
      input integer M;
      input integer N;
      integer i, j;
      begin
        $display("///////////");
        for (i = 0; i < N; i = i + 1) begin // row loop
          for (j = 0; j < M; j = j + 1) begin // column loop
            $write("%x ", memory_out[(i*M) + j]); // print the data
          end
            $display(""); // xuong hang
        end
        $display("///////////");
      end
    endtask
    
endmodule