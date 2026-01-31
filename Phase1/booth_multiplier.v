module booth_multiplier (
    input  signed [31:0] multiplicand,
    input  signed [31:0] multiplier,
    output reg    signed [63:0] product // 64-bit product (32 x 32 bits)
);

    integer i;
    reg signed [33:0] pp;          // partial product (added 2 bits for shifts)
    reg signed [63:0] acc;         // accumulator (running sum of partial products)
    reg [33:0] m_ext;              // sign-extended multiplicand
    reg [33:0] mult_ext;           //multiplier with extra 0 bit appended

    always @(*) begin
        // Sign extend multiplicand
        m_ext = { {2{multiplicand[31]}}, multiplicand };

        // append extra 0 bit to multiplier
        mult_ext = { multiplier, 1'b0 };

        //initialize the accumulator (starting sum = 0)
        acc = 64'd0;

        //Booth loop (32/2 = 16 iterations)
        for (i = 0; i < 16; i = i + 1) begin
            case (mult_ext[2*i +: 3]) //examine 3 bits at a time
                3'b000,                         
                3'b111: pp = 34'd0;             //  no change add 0
                3'b001,
                3'b010: pp =  m_ext;            // multiply by +1
                3'b011: pp =  m_ext <<< 1;      // multiply by +2 (shift by one)
                3'b100: pp = -(m_ext <<< 1);    // multiply by -2 (2s complement and shift by one )
                3'b101,
                3'b110: pp = -m_ext;            // multiply by -1
                default: pp = 34'd0;            // default is no change
            endcase

            //Shift the partial product and add to accumulator
            acc = acc + (pp <<< (2*i));
        end

        product = acc;
    end

endmodule
