module neg(
	output wire [31:0] Rz,
	input wire [31:0] Ra
	);
	
	wire [31:0] not_out;
	wire cout;
	
	not_32 not_32( //flip
		.A(Ra), 
		.result(not_out)
	); 
	
	adder adder( //add 1
		.A(not_out),
		.B(32'h00000001),
		.Result(Rz)
	); 
	
endmodule