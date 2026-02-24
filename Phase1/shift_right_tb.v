`timescale 1ns/10ps
// shr R7, R0, R4. 
// R0 = 0b00110100, R4 = 0b00000010, Final R7 = 0b00001101

module shift_right_tb;

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

    reg [31:0] Mdatain;

    localparam ALU_SHR = 4'd5;

    parameter Default  = 4'd0,
              LoadR0a  = 4'd1,
              LoadR0b  = 4'd2,
              LoadR4a  = 4'd3,
              LoadR4b  = 4'd4,
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
        $dumpfile("shift_right_tb.vcd");
        $dumpvars(0, shift_right_tb);
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
                Default  : Present_state <= LoadR0a;
                LoadR0a  : Present_state <= LoadR0b;
                LoadR0b  : Present_state <= LoadR4a;
                LoadR4a  : Present_state <= LoadR4b;
                LoadR4b  : Present_state <= T0;
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

        case (Present_state)
            LoadR0a: begin
                Mdatain = 32'h00000034;
                Read = 1;
                MDRin = 1;
            end
            LoadR0b: begin
                MDRout = 1;
                Rin[0] = 1;
            end

            LoadR4a: begin
                Mdatain = 32'h00000002;
                Read = 1;
                MDRin = 1;
            end
            LoadR4b: begin
                MDRout = 1;
                Rin[4] = 1;
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
                Rout[0] = 1;
                Yin = 1;
            end

            T4: begin
                Rout[4] = 1;
                ALUop = ALU_SHR;
                Zin = 1;
            end

            T5: begin
                Zlowout = 1;
                Rin[7] = 1;
            end
        endcase
    end

    initial begin
        clear = 1;
        #20 clear = 0;
    end

    initial begin
        #500;
        $finish;
    end

endmodule
