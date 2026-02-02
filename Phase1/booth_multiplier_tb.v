`timescale 1ns/1ps

module booth_multiplier_tb;

    reg  signed [31:0] multiplicand;
    reg  signed [31:0] multiplier;
    wire signed [63:0] product;

    booth_multiplier DUT (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );

    initial begin
        $dumpfile("booth_multiplier_tb.vcd");
        $dumpvars(0, booth_multiplier_tb);

        multiplicand = 0;
        multiplier   = 0;
        #10;

        multiplicand = 5;
        multiplier   = 3;
        #10;

        multiplicand = -4;
        multiplier   = 6;
        #10;

        multiplicand = 7;
        multiplier   = -2;
        #10;

        multiplicand = -8;
        multiplier   = -3;
        #10;

        $display("Simulation complete.");
        $finish;
    end

endmodule
