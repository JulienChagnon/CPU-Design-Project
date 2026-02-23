module ALU(
	input wire [31:0] A, B, 
	input wire [3:0] op, 
	output reg [63:0] result
);

	//wires to hold the output of each ALU operation
	wire [31:0] and_result, or_result;
	wire [31:0] not_result, add_result, sub_result;
	wire [31:0] shr_result, shra_result, shl_result;
	wire [31:0] neg_result;
	wire [31:0] ror_result, rol_result;
	wire signed [63:0] mul_result;
	wire [63:0] div_result;

	//instantiate each ALU operation module
	and_or or_instance(A, B, 1'b0, or_result);
	and_or and_instance(A, B, 1'b1, and_result);
	not_32 not_instance(B, not_result);
	adder add_instance(A, B, add_result);
	subtractor sub_instance(A, B, sub_result);
	shift_right shr_instance(A, B, shr_result);
	shift_right_arithmetic shra_instance(A, B, shra_result);
	shift_left shl_instance(A, B, shl_result);
	neg neg_instance(neg_result, B);
	booth_multiplier mul_instance(A, B, mul_result);
	divider div_instance(A, B, div_result);

	assign ror_result = (B[4:0] == 5'd0) ? A : ((A >> B[4:0]) | (A << (6'd32 - {1'b0, B[4:0]})));
	assign rol_result = (B[4:0] == 5'd0) ? A : ((A << B[4:0]) | (A >> (6'd32 - {1'b0, B[4:0]})));

	// op mapping used by datapath testbenches:
	// 0: OR, 1: AND, 2: NOT(B), 3: ADD, 4: SUB,
	// 5: SHR, 6: SHRA, 7: SHL, 8: ROR, 9: ROL, 10: NEG(B),
	// 11: MUL, 12: DIV({remainder, quotient})
	always @(*) begin
		case(op)
			0:	result = {32'b0, or_result};
			1:	result = {32'b0, and_result};
			2: result = {32'b0, not_result};
			3: result = {32'b0, add_result};
			4: result = {32'b0, sub_result};
			5: result = {32'b0, shr_result};
			6: result = {32'b0, shra_result};
			7: result = {32'b0, shl_result};
			8: result = {32'b0, ror_result};
			9: result = {32'b0, rol_result};
			10: result = {32'b0, neg_result};
			11: result = mul_result;
			12: result = div_result;
			default: result = 64'b0;
		endcase
	end
	
endmodule
