`timescale 1ns/10ps

module revise_R0_tb;

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

reg [3:0] ALUop;

// FSM states
parameter Default   = 3'd0,
          LoadR1    = 3'd1,
          CopyR1R0  = 3'd2,
          NormalR0  = 3'd3,
          RevisedR0 = 3'd4;

reg [2:0] Present_state = Default;


// Datapath instance
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

    .BAout(BAout)
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
            Default   : Present_state <= LoadR1;
            LoadR1    : Present_state <= CopyR1R0;
            CopyR1R0  : Present_state <= NormalR0;
            NormalR0  : Present_state <= RevisedR0;
            RevisedR0 : Present_state <= RevisedR0;
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

    case (Present_state)

        // Load value into R1 
        LoadR1: begin
            Rin[1] = 1;
        end

        // Copy R1 to R0
        CopyR1R0: begin
            Rout[1] = 1;
            Rin[0]  = 1;
        end

        // Normal R0 output
        NormalR0: begin
            BAout   = 0;
            Rout[0] = 1;
        end

        // Revised R0 output
        RevisedR0: begin
            BAout   = 1;
            Rout[0] = 1;
        end

    endcase
end


// Reset
initial begin
    clear = 1;
    #20 clear = 0;
end


// Force value into R1 register
initial begin
    #25;
    force DUT.R1_data_out = 32'h00000005;
end


// Waveforms
initial begin
    $dumpfile("revise_R0_tb.vcd");
    $dumpvars(0, revise_R0_tb);
end


// Monitor values
initial begin
    $monitor("time=%0t BAout=%b R0=%h R0_bus=%h Bus=%h",
        $time,
        BAout,
        DUT.R0_data_out,
        DUT.R0_bus_out,
        DUT.BusMuxOut
    );
end


// Finish
initial begin
    #200;
    $display("Simulation complete.");
    $finish;
end

endmodule
