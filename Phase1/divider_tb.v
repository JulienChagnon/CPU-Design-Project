`timescale 1ns/1ps
module divider_tb;
    reg  signed [31:0] dividend;
    reg  signed [31:0] divisor;
    wire [63:0] result;

    wire signed [31:0] rem = result[63:32];
    wire signed [31:0] quo = result[31:0];

    divider dut (
        .dividend(dividend),
        .divisor(divisor),
        .result(result)
    );

    initial begin
        //10 / 3 = 3 remainder 1
        dividend = 32'sd10;
        divisor  = 32'sd3;
        $finish;
    end
endmodule
