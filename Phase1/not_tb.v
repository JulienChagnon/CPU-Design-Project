`timescale 1ns/10ps
// not R4, R7
// R7 = 0x00000005, Final R4 = 0xFFFFFFFA

module not_tb;

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

    localparam ALU_NOT = 4'd2;

    parameter Default  = 4'd0,
              LoadR7a  = 4'd1,
              LoadR7b  = 4'd2,
              T0       = 4'd3,
              T1       = 4'd4,
              T2       = 4'd5,
              T3       = 4'd6,
              T4       = 4'd7;

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
        $dumpfile("not_tb.vcd");
        $dumpvars(0, not_tb);
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
                Default : Present_state <= LoadR7a;
                LoadR7a : Present_state <= LoadR7b;
                LoadR7b : Present_state <= T0;
                T0      : Present_state <= T1;
                T1      : Present_state <= T2;
                T2      : Present_state <= T3;
                T3      : Present_state <= T4;
                T4      : Present_state <= T4;
                
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
            LoadR7a: begin
                Mdatain = 32'h00000005;
                Read = 1;
                MDRin = 1;
            end
            LoadR7b: begin
                MDRout = 1;
                Rin[7] = 1;      
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
                Rout[7] = 1;
                ALUop = ALU_NOT;
                Zin = 1;
            end

            T4: begin
                Zlowout = 1;
                Rin[4] = 1;
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
