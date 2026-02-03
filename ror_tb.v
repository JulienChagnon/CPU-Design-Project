`timescale 1ns/1ps

module ror_tb;

	reg [31:0] RotateBits;
	reg [31:0] Ra;
	wire [31:0] Rz;

	ror rotate(
		.RotateBits(RotateBits),
      .Ra(Ra),
      .Rz(Rz)
   );

	initial begin
		$dumpfile("ror_tb.vcd");
		$dumpvars(0, ror_tb);

		RotateBits = 0;
		Ra   = 0;
		#10;

		Ra = 19; //10011
		RotateBits = 1;
		#10;


		$display("Simulation complete.");
		$finish;
	end

endmodule
