`timescale 1ns/10ps

module jump_tb;

reg Clock;
reg clear;

reg [15:0] Rin;
reg [15:0] Rout;

reg PCin, PCout, MARin;
reg MDRin, MDRout;
reg IRin;
reg Yin;
reg Zlowin, Zlowout;
reg Read, Write;
reg BAout;

reg IncPC;
reg Zin;
reg Gra;
reg Cout;
reg ADD;

reg [3:0] ALUop;
reg [31:0] Mdatain;

reg [31:0] RegisterImmediate;


// FSM states
parameter Default   = 4'd0,
          LoadR12a  = 4'd1,
          LoadR12b  = 4'd2,
          LoadR4a   = 4'd3,
          LoadR4b   = 4'd4,
          LoadPCa   = 4'd5,
          LoadPCb   = 4'd6,
          JR        = 4'd7,
          JAL1      = 4'd8,
          JAL2      = 4'd9;

reg [3:0] Present_state = Default;


// Datapath instance
datapath DUT (
    .clock(Clock),
    .clear(clear),

    .A(32'b0),
    .RegisterImmediate(RegisterImmediate),

    .Read(Read),
    .Write(Write),
    .ALUop(ALUop),

    .Rin(Rin),
    .Rout(Rout),

    .MARin(MARin),
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
    .Zlowout(Zlowout),

    .BAout(BAout),

    .CONin(1'b0),
    .CONout(),
    .IR_C2(2'b00),
    .Cout(Cout)
);


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

            Default  : Present_state <= LoadR12a;

            LoadR12a : Present_state <= LoadR12b;
            LoadR12b : Present_state <= LoadR4a;

            LoadR4a  : Present_state <= LoadR4b;
            LoadR4b  : Present_state <= LoadPCa;

            LoadPCa  : Present_state <= LoadPCb;
            LoadPCb  : Present_state <= JR;

            JR       : Present_state <= JAL1;
            JAL1     : Present_state <= JAL2;
            JAL2     : Present_state <= JAL2;

        endcase
    end
end


// Control signals
always @(Present_state) begin

    Rin      = 16'b0;
    Rout     = 16'b0;
    Read     = 0;
    Write    = 0;
    MDRin    = 0;
    MDRout   = 0;
    PCin     = 0;
    PCout    = 0;
    MARin    = 0;
    IRin     = 0;
    Yin      = 0;
    Zlowin   = 0;
    Zlowout  = 0;
    ALUop    = 0;
    BAout    = 0;
    IncPC    = 0;
    Zin      = 0;
    Gra      = 0;
    Cout     = 0;
    ADD      = 0;
    Mdatain  = 32'b0;

    case (Present_state)

        LoadR12a: begin
            RegisterImmediate = 32'h000000FF;
            Cout   = 1;
            Rin[12] = 1;
        end


        // Load R4 = 80
        LoadR4a: begin
            RegisterImmediate = 32'h00000080;
            Cout   = 1;
            Rin[4] = 1;
        end

        // Load PC = 10
        LoadPCa: begin
            RegisterImmediate = 32'h00000010;
            Cout   = 1;
            PCin = 1;
        end


        // JR  → PC ← R12
        JR: begin
            Rout[12] = 1;
            PCin     = 1;
        end


        // JAL step 1 → R12 ← PC
        JAL1: begin
            PCout    = 1;
            Rin[12]  = 1;
        end


        // JAL step 2 → PC ← R4
        JAL2: begin
            Rout[4]  = 1;
            PCin     = 1;
        end

    endcase
end

initial begin
    clear = 1;
    Rin = 0; Rout = 0; // Initialize control signals
    #15;
    clear = 0; 
end


// Waveforms
initial begin
    $dumpfile("jump_tb.vcd");
    $dumpvars(0, jump_tb);
end


// Finish
initial begin
    #400;
    $display("Simulation complete.");
    $finish;
end

endmodule
