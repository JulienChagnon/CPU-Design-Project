`timescale 1ns/10ps

module sign_extend_tb;

    reg  [31:0] IR;
    reg         Cout;
    wire [31:0] C_sign_extended;

    // Instantiate only sign_extend
    sign_extend DUT (
        .IR(IR),
        .Cout(Cout),
        .C_sign_extended(C_sign_extended)
    );

    initial begin
        $dumpfile("sign_extend_tb.vcd");
        $dumpvars(0, sign_extend_tb);

        Cout = 1;

        // Test 1: positive constant IR[18] = 0
        IR = 32'b00000000000000000000000000000101; 
        #20;

        // Test 2: negative constant IR[18] = 1
        IR = 32'b00000000000001000000000000000001; 
        #20;

        //Test 3: Cout disabled
        Cout = 0;
        #20;

        $display("Sign extension test complete.");
        $finish;
    end

endmodule
