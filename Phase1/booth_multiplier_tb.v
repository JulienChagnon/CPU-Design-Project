`timescale 1ns/10ps
// mul R3, R1, R3.
// R1 = 0x00000006, R3 = 0x00000054, Final R3 = 0x000001F8

module booth_multiplier_tb;

    reg Clock;
    reg clear;

    reg [15:0] Rin;
    reg [15:0] Rout;

    reg PCin, PCout;
    reg MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin;
    reg Zin, Zlowout;
    reg IncPC;
    reg Read;
    reg [3:0] ALUop;

    reg ALU_MUL, ALU_DIV;

    reg [31:0] Mdatain;

    parameter Default  = 4'd0,
              LoadR3a  = 4'd1,
              LoadR3b  = 4'd2,
              LoadR1a  = 4'd3,
              LoadR1b  = 4'd4,
              T0       = 4'd5,
              T1       = 4'd6,
              T2       = 4'd7,
              T3       = 4'd8,
              T4       = 4'd9,
              T5       = 4'd10;

    reg [3:0] Present_state = Default;

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
        .Zlowin(Zin),
        .Zhighout(),
        .Zlowout(Zlowout)
    );

    initial begin
        $dumpfile("booth_multiplier_tb.vcd");
        $dumpvars(0, booth_multiplier_tb);
    end

    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    always @(posedge Clock) begin
        if (clear)
            Present_state <= Default;
        else begin
            case (Present_state)
                Default  : Present_state <= LoadR3a;
                LoadR3a  : Present_state <= LoadR3b;
                LoadR3b  : Present_state <= LoadR1a;
                LoadR1a  : Present_state <= LoadR1b;
                LoadR1b  : Present_state <= T0;
                T0       : Present_state <= T1;
                T1       : Present_state <= T2;
                T2       : Present_state <= T3;
                T3       : Present_state <= T4;
                T4       : Present_state <= T5;
                T5       : Present_state <= T5;
            endcase
        end
    end

    always @(*) begin
        Rin      = 16'b0;
        Rout     = 16'b0;
        Read     = 0;
        MDRin    = 0;
        MDRout   = 0;
        Yin      = 0;
        Zin      = 0;
        Zlowout  = 0;
        IncPC    = 0;
        ALUop    = 4'b0000;
        Mdatain  = 32'b0;

        PCin     = 0;
        PCout    = 0;
        MARin    = 0;
        IRin     = 0;

        ALU_MUL  = 0;
        ALU_DIV  = 0;

        case (Present_state)
            LoadR3a: begin
                Mdatain = 32'h00000054;
                Read = 1;
                MDRin = 1;
            end
            LoadR3b: begin
                MDRout = 1;
                Rin[3] = 1;
            end

            LoadR1a: begin
                Mdatain = 32'h00000006;
                Read = 1;
                MDRin = 1;
            end
            LoadR1b: begin
                MDRout = 1;
                Rin[1] = 1;
            end

            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
                Zin = 1;
            end

            T1: begin
                Zlowout = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
                Mdatain = 32'h00000000;
            end

            T2: begin
                MDRout = 1;
                IRin = 1;
            end

            T3: begin
                Rout[3] = 1;
                Yin = 1;
            end

            T4: begin
                Rout[1] = 1;
                ALU_MUL = 1;
                ALU_DIV = 0;
                ALUop = 4'd11;
                Zin = 1;
            end

            T5: begin
                Zlowout = 1;
                Rin[3] = 1;
            end
        endcase
    end

    initial begin
        clear = 1;
        #20 clear = 0;
    end

    initial begin
        #500;
        $display("Simulation complete.");
        $finish;
    end

endmodule
