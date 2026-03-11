`timescale 1ns/10ps

// st 0x1F, R6 => M[R0 + 0x1F] = M[0x1F] <- R6
// R0 is used as base (BAout gates 0 onto bus regardless of R0 contents).
// Initialize: R6 = 0x63, RAM[0x1F] = 0xD4 (preloaded in datapath.v).
// Expected: RAM[0x1F] = 0x00000063 after store.

module st_tb;

    reg Clock, clear;

    reg [15:0] Rin, Rout;

    reg PCin, PCout, MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin, Yout;
    reg Read, Write;
    reg [3:0] ALUop;
    reg BAout;
    reg Zin, Zlowout;
    reg IncPC;

    // select/encode controls
    reg UseSelectEncode;
    reg Gra, Grb, Grc;
    reg Rin_ctrl, Rout_ctrl, Cout;

    // CON FF
    reg CONin;
    wire CONout;

    // I/O port controls
    reg InPortout, OutPortin, InPortStrobe;
    reg [31:0] InPortData;
    wire [31:0] OutPortData;

    // ALU opcodes (must match alu.v case statement)
    localparam ALU_ADD = 4'd3;

    // st 0x1F, R6: IR[26:23]=Ra=6, IR[22:19]=Rb=0, IR[18:0]=C=0x1F
    // Effective address: R0 + 0x1F = 0x1F
    localparam [31:0] ST_INSTR = 32'h1300001F;

    // Control Sequence: st (4-step fetch, no IR force)
    // T0: PCout, MARin, IncPC, Zin
    // T1: Zlowout, PCin, Read
    // T2: Read, MDRin
    // T3: MDRout, IRin
    // T4: Grb, BAout, Yin
    // T5: Cout, ADD, Zin
    // T6: Zlowout, MARin
    // T7: Gra, Rout_ctrl, MDRin
    // T8: Write
    parameter Default=4'd0, T0=4'd1, T1=4'd2, T2=4'd3, T3=4'd4,
              T4=4'd5, T5=4'd6, T6=4'd7, T7=4'd8, T8=4'd9;

    reg [3:0] Present_state = Default;

    datapath DUT (
        .clock(Clock),
        .clear(clear),
        .A(32'b0),
        .RegisterImmediate(32'b0),
        .Read(Read),
        .Write(Write),
        .ALUop(ALUop),
        .Rin(Rin),
        .Rout(Rout),
        .MARin(MARin),
        .PCin(PCin),
        .PCout(PCout),
        .IRin(IRin),
        .IRout(1'b0),
        .Yin(Yin),
        .Yout(Yout),
        .MDRin(MDRin),
        .MDRout(MDRout),
        .HIin(1'b0),
        .HIout(1'b0),
        .LOin(1'b0),
        .LOout(1'b0),
        .Zhighin(1'b0),
        .Zlowin(Zin),
        .Zhighout(1'b0),
        .Zlowout(Zlowout),
        .BAout(BAout),
        .IncPC(IncPC),
        .UseSelectEncode(UseSelectEncode),
        .Gra(Gra),
        .Grb(Grb),
        .Grc(Grc),
        .Rin_ctrl(Rin_ctrl),
        .Rout_ctrl(Rout_ctrl),
        .Cout(Cout),
        .InPortout(InPortout),
        .OutPortin(OutPortin),
        .InPortStrobe(InPortStrobe),
        .InPortData(InPortData),
        .OutPortData(OutPortData),
        .CONin(CONin),
        .CONout(CONout)
    );

    // Preload RAM[0] with st instruction; set R6 after clear deasserts.
    // RAM[0x1F] is preloaded in datapath.v.
    initial begin
        DUT.mem_sys.ram_inst.memory[9'h000] = ST_INSTR;
        #25;
        DUT.R6.q = 32'h00000063;
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
                Default : Present_state <= T0;
                T0      : Present_state <= T1;
                T1      : Present_state <= T2;
                T2      : Present_state <= T3;
                T3      : Present_state <= T4;
                T4      : Present_state <= T5;
                T5      : Present_state <= T6;
                T6      : Present_state <= T7;
                T7      : Present_state <= T8;
                T8      : Present_state <= T8; // hold
            endcase
        end
    end

    always @(*) begin
        Rin  = 16'b0; Rout = 16'b0;
        PCin = 0; PCout = 0; MARin = 0;
        MDRin = 0; MDRout = 0; IRin = 0;
        Yin = 0; Yout = 0;
        Zin = 0; Zlowout = 0;
        Read = 0; Write = 0; BAout = 0;
        ALUop = 4'b0; IncPC = 0;
        UseSelectEncode = 1;
        Gra = 0; Grb = 0; Grc = 0;
        Rin_ctrl = 0; Rout_ctrl = 0; Cout = 0;
        CONin = 0;
        InPortout = 0; OutPortin = 0;
        InPortStrobe = 0; InPortData = 32'b0;

        case (Present_state)
            T0: begin // PCout, MARin, IncPC, Zin
                PCout = 1; MARin = 1; IncPC = 1; ALUop = ALU_ADD; Zin = 1;
            end
            T1: begin // Zlowout, PCin, Read
                Zlowout = 1; PCin = 1; Read = 1;
            end
            T2: begin // Read, MDRin
                Read = 1; MDRin = 1;
            end
            T3: begin // MDRout, IRin
                MDRout = 1; IRin = 1;
            end
            T4: begin // Grb, BAout, Yin
                Grb = 1; BAout = 1; Yin = 1;
            end
            T5: begin // Cout, ADD, Zin
                Cout = 1; ALUop = ALU_ADD; Zin = 1;
            end
            T6: begin // Zlowout, MARin
                Zlowout = 1; MARin = 1;
            end
            T7: begin // Gra, Rout_ctrl, MDRin
                Gra = 1; Rout_ctrl = 1; MDRin = 1;
            end
            T8: begin // Write
                Write = 1;
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
