`timescale 1ns/10ps

// ori R7, R4, 0x71 => R7 <- R4 | sign_extend(0x71)
// Initialize: R4 = 0xF0
// Expected: R7 = 0xF0 | 0x71 = 1111_0001 = 0x000000F1
//
// Uses 4-step fetch: RAM[0] preloaded with ORI_INSTR so IR loads naturally.

module ori_tb;

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
    localparam ALU_OR  = 4'd0;

    // ori R7, R4, 0x71: IR[26:23]=Ra=7, IR[22:19]=Rb=4, IR[18:0]=C=0x71
    // opcode bits[31:27] = 00101
    localparam [31:0] ORI_INSTR = 32'h2BA00071;

    // Control Sequence: ori (4-step fetch)
    // T0: PCout, MARin, IncPC, Zin
    // T1: Zlowout, PCin, Read
    // T2: Read, MDRin
    // T3: MDRout, IRin
    // T4: Grb, Rout, Yin
    // T5: Cout, OR, Zin
    // T6: Zlowout, Gra, Rin
    parameter Default=3'd0, T0=3'd1, T1=3'd2, T2=3'd3,
              T3=3'd4, T4=3'd5, T5=3'd6, T6=3'd7;

    reg [2:0] Present_state = Default;

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

    // Preload RAM[0] with the ori instruction; set R4 after clear deasserts.
    initial begin
        DUT.mem_sys.ram_inst.memory[9'h000] = ORI_INSTR;
        #25;
        DUT.R4.q = 32'h000000F0;
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
                T6      : Present_state <= T6; // hold
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
            T4: begin // Grb, Rout, Yin
                Grb = 1; Rout_ctrl = 1; Yin = 1;
            end
            T5: begin // Cout, OR, Zin
                Cout = 1; ALUop = ALU_OR; Zin = 1;
            end
            T6: begin // Zlowout, Gra, Rin
                Zlowout = 1; Gra = 1; Rin_ctrl = 1;
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
