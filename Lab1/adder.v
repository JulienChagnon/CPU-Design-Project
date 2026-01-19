// Ripple Carry Adder
module adder(A, B, Result);

    input  [7:0] A, B;
    output [7:0] Result;

    reg    [7:0] Result;
    reg    [8:0] Localcarry;

    integer i;

    always @(A or B) begin
        Localcarry = 9'd0;
        for (i = 0; i < 8; i = i + 1) begin
            Result[i]       = A[i] ^ B[i] ^ Localcarry[i];
            Localcarry[i+1] = (A[i] & B[i]) | (Localcarry[i] & (A[i] | B[i]));
        end
    end

endmodule
