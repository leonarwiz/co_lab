`timescale 1ps/1ps
module Adder(
    input src1_i,
    input src2_i,
    output sum_o,
);
//IO
input [31:0] src1_i;
input [31:0] src2_i;
output [31:0] sum_o;

//Internal Signals
wire [31:0] sum_o;


assign sum_o = src1_i + src2_i;
endmodule