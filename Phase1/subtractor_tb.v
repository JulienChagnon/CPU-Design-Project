`timescale 1ns/1ps

module subtractor_tb;

	reg [31:0] A, B;
	wire [31:0] Result;

	subtractor dut(
		.A(A),
		.B(B),
		.Result(Result)
	);

	initial begin
		$dumpfile("subtractor_tb.vcd");
		$dumpvars(0, subtractor_tb);

		A = 32'h00000000; B = 32'h00000000; #10; // 0 - 0
		A = 32'h0000002D; B = 32'h00000022; #10; // 45 - 34 = 11
		A = 32'h00000022; B = 32'h0000002D; #10; // 34 - 45 = -11
		A = 32'h00000000; B = 32'h00000001; #10; // -1

		$finish;
	end

endmodule

