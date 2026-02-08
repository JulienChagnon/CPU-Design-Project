`timescale 1ns/1ps

module shift_right_tb;

    reg  signed [31:0] data_in;
    reg  signed [31:0]  shift_amount;
    wire signed [31:0] data_out;

    shift_right DUT (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("shift_right_tb.vcd");
        $dumpvars(0, shift_right_tb);

        data_in = 0;
        shift_amount = 0;
        #10;   

        data_in = 5;
        shift_amount = 3;
        #10;    //expected output = 0

        data_in = 6;
        shift_amount = 1;
        #10;   //expected output = 3

    end

endmodule
