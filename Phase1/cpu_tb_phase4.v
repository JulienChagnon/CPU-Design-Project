`timescale 1ns/10ps

module cpu_tb_phase4;

    reg Clock;

    // DE0-CV style controls (active-low pushbuttons)
    reg [3:0] KEY;
    reg [9:0] SW;

    wire reset = ~KEY[0]; // KEY0 -> Reset.In
    wire stop  = ~KEY[1]; // KEY1 -> Stop.In

    reg InPortStrobe;
    wire [31:0] InPortData = {24'b0, SW[7:0]}; // SW0..SW7 -> In.Port[7:0]

    wire [31:0] OutPortData;
    wire Run; // maps to LEDR5 on board top-level
    wire CONout;
    wire [31:0] IR_value;
    wire [7:0] state_dbg;

    integer cycles;
    integer error_count;

    // Phase 4 delay loop is long due to M[0x88] = 0xFFFF
    localparam integer MAX_CYCLES = 120000000;

    cpu DUT (
        .clock(Clock),
        .reset(reset),
        .stop(stop),
        .InPortData(InPortData),
        .InPortStrobe(InPortStrobe),
        .OutPortData(OutPortData),
        .Run(Run),
        .CONout(CONout),
        .IR_value(IR_value),
        .state_dbg(state_dbg)
    );

    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    task check_value;
        input [8*32-1:0] name;
        input [31:0] actual;
        input [31:0] expected;
        begin
            if (actual !== expected) begin
                error_count = error_count + 1;
            end
        end
    endtask

    initial begin
        KEY = 4'b1111;       // not pressed
        SW  = 10'b00_1110_0000; // SW7..0 = 0xE0
        InPortStrobe = 1'b0;
        cycles = 0;
        error_count = 0;

        // Apply reset via KEY0 press/release
        #5;
        KEY[0] = 1'b0;
        #35;
        KEY[0] = 1'b1;

        // Latch switch value into input port register
        #20;
        InPortStrobe = 1'b1;
        #20;
        InPortStrobe = 1'b0;
    end

    initial begin
        @(posedge KEY[0]); // wait until reset released
    end

endmodule
