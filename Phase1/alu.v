module ALU(
	input wire [31:0] A, B, 
	input wire [3:0] op, 
	output reg[31:0] result
);
	
	wire [31:0] and_result, or_result;
	wire [31:0] not_result, add_result, sub_result;
	wire [31:0] shr_result, shra_result, shl_result;
	wire [31:0] neg_result;
	wire [31:0] ror_result, rol_result;

	and_or or_instance(A, B, 1'b0, or_result);
	and_or and_instance(A, B, 1'b1, and_result);
	not_32 not_instance(B, not_result);
	adder add_instance(A, B, add_result);
	subtractor sub_instance(A, B, sub_result);
	shift_right shr_instance(A, B, shr_result);
	shift_right_arithmetic shra_instance(A, B, shra_result);
	shift_left shl_instance(A, B, shl_result);
	neg neg_instance(neg_result, B);

	assign ror_result = (B[4:0] == 5'd0) ? A : ((A >> B[4:0]) | (A << (6'd32 - {1'b0, B[4:0]})));
	assign rol_result = (B[4:0] == 5'd0) ? A : ((A << B[4:0]) | (A >> (6'd32 - {1'b0, B[4:0]})));

	// op mapping used by datapath_tb:
	// 0: OR, 1: AND, 2: NOT(B), 3: ADD, 4: SUB,
	// 5: SHR, 6: SHRA, 7: SHL, 8: ROR, 9: ROL, 10: NEG(B)
	always @(*) begin
		case(op)
			0:	result = or_result;
			1:	result = and_result;
			2: result = not_result;
			3: result = add_result;
			4: result = sub_result;
			5: result = shr_result;
			6: result = shra_result;
			7: result = shl_result;
			8: result = ror_result;
			9: result = rol_result;
			10: result = neg_result;
			default: result = 32'b0;
		endcase
	end
	
endmodule
