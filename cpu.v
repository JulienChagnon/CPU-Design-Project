`timescale 1ns/10ps

module cpu (
    input  wire        clock,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] InPortData,
    input  wire        InPortStrobe,

    output wire [31:0] OutPortData,
    output wire        Run,
    output wire        CONout,
    output wire [31:0] IR_value,
    output wire [7:0]  state_dbg
);

wire        Read;
wire        Write;
wire [3:0]  ALUop;
wire [15:0] Rin;
wire [15:0] Rout;
wire        MARin;
wire        PCin;
wire        PCout;
wire        IRin;
wire        Yin;
wire        MDRin;
wire        MDRout;
wire        HIin;
wire        HIout;
wire        LOin;
wire        LOout;
wire        Zhighin;
wire        Zlowin;
wire        Zhighout;
wire        Zlowout;
wire        BAout;
wire        IncPC;
wire        UseSelectEncode;
wire        Gra;
wire        Grb;
wire        Grc;
wire        Rin_ctrl;
wire        Rout_ctrl;
wire        Cout;
wire        InPortout;
wire        OutPortin;
wire        CONin;

control_unit control_u (
    .clock(clock),
    .reset(reset),
    .stop(stop),
    .IR(IR_value),
    .CONout(CONout),
    .Run(Run),
    .Read(Read),
    .Write(Write),
    .ALUop(ALUop),
    .Rin(Rin),
    .Rout(Rout),
    .MARin(MARin),
    .PCin(PCin),
    .PCout(PCout),
    .IRin(IRin),
    .Yin(Yin),
    .MDRin(MDRin),
    .MDRout(MDRout),
    .HIin(HIin),
    .HIout(HIout),
    .LOin(LOin),
    .LOout(LOout),
    .Zhighin(Zhighin),
    .Zlowin(Zlowin),
    .Zhighout(Zhighout),
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
    .CONin(CONin),
    .state_dbg(state_dbg)
);

datapath datapath_u (
    .clock(clock),
    .clear(reset),
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
    .Yout(1'b0),
    .MDRin(MDRin),
    .MDRout(MDRout),
    .HIin(HIin),
    .HIout(HIout),
    .LOin(LOin),
    .LOout(LOout),
    .Zhighin(Zhighin),
    .Zlowin(Zlowin),
    .Zhighout(Zhighout),
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
    .CONout(CONout),
    .IR_value(IR_value)
);

endmodule
