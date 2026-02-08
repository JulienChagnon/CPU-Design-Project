`timescale 1ns/1ps

module shift_left_tb;

    reg  signed [31:0] data_in;
    reg  signed [31:0]  shift_amount;
    wire signed [31:0] data_out;

    shift_left DUT (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("shift_left_tb.vcd");
        $dumpvars(0, shift_left_tb);

        data_in = 0;
        shift_amount = 0;
        #10;   

        data_in = 5; //5  in binary is 00000000000000000000000000000101
        shift_amount = 3; //3 in binary is 00000000000000000000000000011
        #10;    //expected output = 00000000000000000000000000101000 (40)

        data_in = 6; //6 in binary is 00000000000000000000000000000110
        shift_amount = 1; // 1 in binary is 00000000000000000000000000000001
        #10;   //expected output = 00000000000000000000000000001100 (12)

    end

endmodule
