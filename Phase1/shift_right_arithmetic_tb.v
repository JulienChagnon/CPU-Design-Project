`timescale 1ns/1ps

module shift_right_arithmetic_tb;

    reg  signed [31:0] data_in;
    reg  signed [31:0]  shift_amount;
    wire signed [31:0] data_out;

    shift_right_arithmetic DUT (
        .data_in(data_in),
        .shift_amount(shift_amount),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("shift_right_arithmetic_tb.vcd");
        $dumpvars(0, shift_right_arithmetic_tb);

        data_in = 0;
        shift_amount = 0;
        #10;   

        data_in = 5;
        shift_amount = 3;
        #10;    //expected output = 0

        data_in = 6; //6 in binary is 00000000000000000000000000000110
        shift_amount = 1;  //1 in binary is 00000000000000000000000000000001
        #10; //expected output = 00000000000000000000000000000011

        data_in = -6;   //-6 in binary is 11111111111111111111111111111010
        shift_amount = 1;   //1 in binary is 00000000000000000000000000000001
        #10;   //expected output = 11111111111111111111111111111010 >>> 1 = 11111111111111111111111111111101

        $display("Simulation complete.");
        $finish;
    end

endmodule
