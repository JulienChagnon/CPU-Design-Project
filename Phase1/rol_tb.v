`timescale 1ns/1ps

module rol_tb;

	reg [31:0] RotateBits;
	reg [31:0] Ra;
	wire [31:0] Rz;

	rol rotate(
        .RotateBits(RotateBits),
        .Ra(Ra),
        .Rz(Rz)
   );

	initial begin
		$dumpfile("rol_tb.vcd");
		$dumpvars(0, rol_tb);

		RotateBits = 0;
		Ra   = 0;
		#10;

		Ra = 19; //10011
		RotateBits = 3;
		#10;


		$display("Simulation complete.");
		$finish;
	end

endmodule
