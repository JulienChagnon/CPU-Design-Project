`timescale 1ns/10ps

module adder_tb;

    // Clock and reset
    reg Clock;
    reg clear;

    // Control buses
    reg [15:0] Rin;
    reg [15:0] Rout;

    // Control signals
    reg PCin, PCout;
    reg MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin;
    reg Zlowin, Zlowout;
    reg Read;
    reg [3:0] ALUop;

    // ALU control
    reg ALU_MUL, ALU_DIV;

    //memory input
    reg [31:0] Mdatain;

    // ALU opcode mapping (from your ALU.v)
    localparam ALU_ADD = 4'd3;

    //finite state machine states
    parameter Default  = 4'd0,
              LoadR5a  = 4'd1,
              LoadR5b  = 4'd2,
              LoadR6a  = 4'd3,
              LoadR6b  = 4'd4,
              T0       = 4'd5,
              T1       = 4'd6,
              T2       = 4'd7,
              T3       = 4'd8,
              T4       = 4'd9,
              T5       = 4'd10;

    reg [3:0] Present_state = Default;

    // DUT
    datapath DUT (
        .clock(Clock),
        .clear(clear),
        .A(32'b0),
        .RegisterImmediate(32'b0),
        .Read(Read),
        .Mdatain(Mdatain),
        .ALUop(ALUop),
        .ALU_MUL(ALU_MUL),
        .ALU_DIV(ALU_DIV),
        .Rin(Rin),
        .Rout(Rout),
        .MARin(MARin),
        .MARout(),
        .PCin(PCin),
        .PCout(PCout),
        .IRin(IRin),
        .IRout(),
        .Yin(Yin),
        .Yout(),
        .MDRin(MDRin),
        .MDRout(MDRout),
        .HIin(1'b0),
        .HIout(),
        .LOin(1'b0),
        .LOout(),
        .Zhighin(1'b0),
        .Zlowin(Zlowin),
        .Zhighout(),
        .Zlowout(Zlowout)
    );

    // GTKWave dump
    initial begin
        $dumpfile("adder_tb.vcd");
        $dumpvars(0, adder_tb);
    end

    // Clock
    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    // FSM transitions
    always @(posedge Clock) begin
        if (clear)
            Present_state <= Default;
        else begin
            case (Present_state)
                Default  : Present_state <= LoadR5a;
                LoadR5a  : Present_state <= LoadR5b;
                LoadR5b  : Present_state <= LoadR6a;
                LoadR6a  : Present_state <= LoadR6b;
                LoadR6b  : Present_state <= T0;
                T0       : Present_state <= T1;
                T1       : Present_state <= T2;
                T2       : Present_state <= T3;
                T3       : Present_state <= T4;
                T4       : Present_state <= T5;
                T5       : Present_state <= T5;
            endcase
        end
    end

    // Control logic
    always @(*) begin
        // defaults
        Rin      = 16'b0;
        Rout     = 16'b0;
        Read     = 0;
        MDRin    = 0;
        MDRout   = 0;
        Yin      = 0;
        Zlowin   = 0;
        Zlowout  = 0;
        ALUop    = 4'b0000;
        Mdatain  = 32'b0;

        PCin     = 0;
        PCout    = 0;
        MARin    = 0;
        IRin     = 0;

        ALU_MUL  = 0;
        ALU_DIV  = 0;

        case (Present_state)

            // Load R5 = 0x34
            LoadR5a: begin
                Mdatain = 32'h00000034;
                Read = 1;
                MDRin = 1;
            end
            LoadR5b: begin
                MDRout = 1;
                Rin[5] = 1;
            end

            // Load R6 = 0x45
            LoadR6a: begin
                Mdatain = 32'h00000045;
                Read = 1;
                MDRin = 1;
            end
            LoadR6b: begin
                MDRout = 1;
                Rin[6] = 1;
            end

            // Fetch (minimal, just for sequencing)
            T0: begin
                PCout = 1;
                MARin = 1;
            end

            T1: begin
                Read = 1;
                MDRin = 1;
            end

            T2: begin
                MDRout = 1;
                IRin = 1;
            end

            // Execute ADD
            T3: begin
                Rout[5] = 1;   // R5 -> Y
                Yin = 1;
            end

            T4: begin
                Rout[6] = 1;   // R6 -> ALU
                ALUop = ALU_ADD;
                Zlowin = 1;
            end

            T5: begin
                Zlowout = 1;
                Rin[2] = 1;    // Result -> R2
            end
        endcase
    end

    // Reset
    initial begin
        clear = 1;
        #20 clear = 0;
    end

    // End simulation
    initial begin
        #500;
        $display("Simulation complete.");
        $finish;
    end

endmodule
