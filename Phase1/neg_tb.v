`timescale 1ns/1ps

module neg_tb;

    reg  [31:0] Ra;
    wire [31:0] Rz;

    neg negative(
        .Ra(Ra),
        .Rz(Rz)
    );

    initial begin
        $dumpfile("neg_tb.vcd");
        $dumpvars(0, neg_tb);

        // Test 0
        Ra = 0;
        #10;

        //positive
        Ra = 5;      
        #10;


        //negative
        Ra = -8;     
        #10;

        $display("Simulation complete.");
        $finish;
    end

endmodule
