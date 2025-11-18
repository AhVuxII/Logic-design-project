// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_6,Vivado 2023.1" *)
module bram_out(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb);
  input clka /* synthesis syn_isclock = 1 */;
  input ena;
  input [0:0]wea;
  input [15:0]addra;
  input [7:0]dina;
  input clkb /* synthesis syn_isclock = 1 */;
  input enb;
  input [15:0]addrb;
  output [7:0]doutb;
endmodule
