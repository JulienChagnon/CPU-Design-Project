`timescale 1ns/1ps

module and_or_tb;

	reg [31:0] A, B;
	reg selection;
	wire [31:0] result;

	and_or andor(
		.A(A),
      .B(B),
	   .selection(selection),
      .result(result)
   );

	initial begin
		$dumpfile("and_or_tb.vcd");
		$dumpvars(0, and_or_tb);

		A = 0;
      B = 0;
      selection = 0;
		#10;

      A = 7; //111
      B = 5; //110
      selection = 1;
      #10;

		A = 6; //101
      B = 2; //010
		selection = 0;
		#10;

    
		$display("Simulation complete.");
		$finish;
	end

endmodule