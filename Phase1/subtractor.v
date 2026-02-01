module subtractor (
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] Result
);
    reg [32:0] Carry;
    wire [31:0] B_inv; //contains one's complement of B

    integer i;

    assign B_inv = ~B; // one's complement

    always @(*) begin
        Carry[0] = 1'b1; // +1 for two's complement

        for (i = 0; i < 32; i = i + 1) begin
            Result[i] = A[i] ^ B_inv[i] ^ Carry[i]; // calculates sum
            Carry[i+1] = (A[i] & B_inv[i]) | (Carry[i] & (A[i] ^ B_inv[i])); // calculates carry
        end
    end

endmodule
