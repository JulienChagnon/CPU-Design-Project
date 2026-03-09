`timescale 1ns/10ps

module branching_tb;

reg Clock;
reg clear;

reg [15:0] Rin;
reg [15:0] Rout;

reg [1:0] IR_C2;

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
reg CONin;
reg Cout;
reg ADD;

wire CONout;

reg UseSelectEncode;
reg Grb, Grc;
reg Rin_ctrl, Rout_ctrl;
reg [31:0] RegisterImmediate;


reg [3:0] ALUop;
// reg [31:0] Mdatain;

// FSM states
parameter Default  = 4'd0,
          LoadR3a = 4'd1,
          LoadR3b   = 4'd2,
          LoadPC  = 4'd3,
           T0       = 4'd4,
           T1       = 4'd5,
           T2       = 4'd6,
           T3       = 4'd7,
           T4       = 4'd8,
           T5       = 4'd9,
           T6       = 4'd10;

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

    .UseSelectEncode(UseSelectEncode),
    .Gra(Gra),
    .Grb(Grb),
    .Grc(Grc),
    .Rin_ctrl(Rin_ctrl),
    .Rout_ctrl(Rout_ctrl),

    .Cout(Cout),

    .InPortout(1'b0),
    .OutPortin(1'b0),
    .InPortStrobe(1'b0),
    .InPortData(32'b0),
    .OutPortData(),
    .CONin(CONin),
    .CONout(CONout),
    .IR_C2(IR_C2)
);


// Clock
initial begin
    Clock = 0;
    forever #10 Clock = ~Clock;
end


// FSM state transitions
always @(posedge Clock) begin
    if (clear)
        Present_state <= Default;
    else begin
        case (Present_state)

            Default  : Present_state <= LoadR3a;
            LoadR3a  : Present_state <= LoadR3b;
            LoadR3b  : Present_state <= LoadPC;
            LoadPC   : Present_state <= T0;

            T0       : Present_state <= T1;
            T1       : Present_state <= T2;
            T2       : Present_state <= T3;
            T3       : Present_state <= T4;
            T4       : Present_state <= T5;
            T5       : Present_state <= T6;
            T6       : Present_state <= Default;

        endcase
    end
end


// Control signals
always @(*) begin

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
    CONin    = 0;
    Cout     = 0;
    ADD      = 0;
    //Mdatain  = 32'b0;
    RegisterImmediate = 32'b0;

    case (Present_state)

        
        
        // preload R3
        LoadR3a: begin
            UseSelectEncode = 0;
            RegisterImmediate = 32'h00000005;   //must change this value for different branch conditions (zero, positive, negative)
            Cout = 1;
        end

        LoadR3b: begin
            UseSelectEncode = 0;
            RegisterImmediate = 32'h00000005;   //must change this value for different branch conditions (zero, positive, negative)
            Cout = 1;
            Rin[3] = 1;

        end
        LoadPC: begin
            Rout[3] = 1;   // put R3 value on bus
            PCin = 1;      // load PC
        end

        // T0
        T0: begin
            PCout = 1;
            MARin = 1;
            IncPC = 1;
            Zin   = 1;
        end

        // T1
        T1: begin
            Zlowout = 1;
            PCin    = 1;
            Read    = 1;
            MDRin   = 1;
        end

        // T2
        T2: begin
            MDRout = 1;
            IRin   = 1;
        end

        // T3 (branch condition evaluation)
        T3: begin
            UseSelectEncode = 0;
            Rout[3] = 1;
            CONin   = 1;
        end

        // T4
        T4: begin
            PCout = 1;
            Yin   = 1;
        end

        // T5
        T5: begin
            ALUop = 4'b0000; // ADD
            Zin  = 1;
        end

        // T6
        T6: begin
            Zlowout = 1;
            if (CONout)
                PCin = 1;
        end

    endcase
end

always @(posedge Clock)
    $display("Bus=%h R3=%h CONout=%b PC=%h",
        DUT.BusMuxOut,
        DUT.R3_data_out,
        CONout,
        DUT.PC_data_out);

// Reset
initial begin
    clear = 1;
    #20 clear = 0;
end

initial begin
    IR_C2 = 2'b00;   // brzr (branch if zero)
    // IR_C2 = 2'b01;   // brnz (branch if not zero)
    // IR_C2 = 2'b10;   // brpl (branch if positive)
    // IR_C2 = 2'b11;   // brmi (branch if negative)
end


// Waveforms
initial begin
    $dumpfile("branching_tb.vcd");
    $dumpvars(0, branching_tb);
end


// Finish
initial begin
    #400;
    $display("Simulation complete.");
    $finish;
end

endmodule
