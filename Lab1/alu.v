module ALU(
	input wire [31:0] A, B, 
	input wire [3:0] op, 
	output reg[31:0] result
);
	
	
	wire [31:0] and_result, or_result, not_result;
	
	and_or and_instance(A, B, 1, and_result);
	and_or or_instance(A, B, 0, or_result);
	not_32 not_instance(A, not_result);
	
	always @(*) begin
		case(op)
			0	:	result = or_result;
			1	:	result = and_result;
			2: result = not_result;
			// ... 
			default: result = 32'b0;
		endcase
	end
	
endmodule
