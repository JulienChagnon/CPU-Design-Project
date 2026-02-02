module shift_left
(
    input  wire [31:0] data_in,       // Data to be shifted
    input  wire [4:0]  shift_amount,  // Number of bits to shift
    output wire [31:0] data_out       // Shifted output
);

    assign data_out = data_in << shift_amount;
endmodule
