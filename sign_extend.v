module sign_extend (
    input  [31:0] IR,                // input instruction register (IR)
    input         Cout,              // control signal
    output [31:0] C_sign_extended    // output the sign-extended value of C
);

    wire [18:0] C;                   // Extract the 19-bit immediate value C from the instruction register (IR)

    assign C = IR[18:0];            // C is the lower 19 bits of the instruction register (IR)

    assign C_sign_extended = Cout ?                     // if Cout is selected do the sign extension
                             
                             {{13{C[18]}}, C} :         //repeat the sign bit (C[18]) 13 times and concatenate it with C (the 13 upper bits are the sign extension)
                             32'b0;                     // if Cout is not selected output 32 bits of 0

endmodule
