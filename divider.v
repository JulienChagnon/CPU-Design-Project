module divider(
    input wire [31:0] dividend,
    input wire [31:0] divisor,
    output wire [63:0] result
);
    wire dividend_neg = dividend[31];
    wire divisor_neg = divisor[31];
    wire sign_q = dividend_neg ^ divisor_neg;
    wire sign_r = dividend_neg;

    //Take 2s complement if negative
    wire [31:0] dividend_abs = dividend_neg ? (~dividend + 1'b1) : dividend;
    wire [31:0] divisor_abs = divisor_neg ? (~divisor + 1'b1) : divisor;

    reg [31:0] quotient;
    reg [31:0] remainder;
    reg [31:0] Q;
    reg signed [32:0] A;
    reg signed [32:0] M;
    integer i;

    //Non-restoring Division
    always @(*) begin
        quotient = 32'b0;
        remainder = 32'b0;
        Q = dividend_abs;
        A = 33'sd0;
        M = {1'b0, divisor_abs};

        if (divisor == 32'b0) begin
            quotient = 32'b0;
            remainder = dividend;
        end else begin
            for (i = 0; i < 32; i = i + 1) begin
                
                //Shift left
                A = {A[31:0], Q[31]};
                Q = {Q[30:0], 1'b0};

                //Add/Substract M
                if (A[32] == 0)
                    A = A - M;
                else
                    A = A + M;

                //Set quotient bit
                if (A[32] == 0)
                    Q[0] = 1'b1;
                else
                    Q[0] = 1'b0;
            end

            //Final check for remainder
            if (A[32] == 1)
                A = A + M;

            quotient = Q;
            remainder = A[31:0];

            if (sign_q)
                quotient = ~quotient + 1'b1;
            if (sign_r)
                remainder = ~remainder + 1'b1;
        end
    end

    assign result = {remainder, quotient};
endmodule
