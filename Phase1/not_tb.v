`timescale 1ns/1ps

module not_tb;

    reg  [31:0] A;
    wire [31:0] result;

    not_32 not32(
        .A(A),
        .result(result)
    );

    initial begin
        $dumpfile("not_tb.vcd");
        $dumpvars(0, not_tb);

        A = 0;
        #10;

        A = 32'hFFFFFFFF;
        #10;

        A = 32'h0000000F;
        #10;

        A = 32'hAAAAAAAA;
        #10;

        $display("Simulation complete.");
        $finish;
    end

endmodule
