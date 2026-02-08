`timescale 1ns/1ps

module adder_tb;

	reg [31:0] A, B;
	wire [31:0] Result;

	adder dut(
		.A(A),
		.B(B),
		.Result(Result)
	);

	initial begin
		$dumpfile("adder_tb.vcd");
		$dumpvars(0, adder_tb);

		A = 32'h00000000; B = 32'h00000000; #10; // 0 + 0
		A = 32'h00000022; B = 32'h0000002D; #10; // 34 + 45 = 79
		A = 32'hFFFFFFFF; B = 32'h00000001; #10; // wrap to 0

		$finish;
	end

endmodule

