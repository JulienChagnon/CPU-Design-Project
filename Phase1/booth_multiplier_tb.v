`timescale 1ns/10ps

module booth_multiplier_tb;

    // clock and clear
    reg Clock;
    reg clear;

    // Control buses
    reg [15:0] Rin; // register write enable bus
    reg [15:0] Rout; //register output enable bus

    // Control signals
    reg PCin, PCout;
    reg MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin;
    reg Zlowin, Zlowout;
    reg Read;
    reg [3:0] ALUop;
 
    reg LOin;
    reg HIin;
    reg Zhighin, Zhighout;
    reg Zin;;

    reg IncPC;

    // ALU control
    reg ALU_DIV;   

    // Memory input
    reg [31:0] Mdatain;     //data read from memory


    // FSM states
    parameter Default  = 4'd0,  //reset state
              LoadR3a  = 4'd1,  //load R3 (memory read)
              LoadR3b  = 4'd2,  //load R3 (write)
              LoadR1a  = 4'd3,  //load R1 (memory read)
              LoadR1b  = 4'd4,  //load R1 (write)
              T0       = 4'd5,
              T1       = 4'd6,
              T2       = 4'd7,
              T3       = 4'd8,
              T4       = 4'd9,
              T5       = 4'd10,
              T6       = 4'd11;

    //current state
    reg [3:0] Present_state = Default;

    // datapath under test
    datapath DUT (
        .clock(Clock),
        .clear(clear),
        .A(32'b0),
        .RegisterImmediate(32'b0),
        .Read(Read),
        .Mdatain(Mdatain),
        .ALUop(ALUop),
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

        .HIin(HIin),          // connect testbench signal
        .HIout(),
        .LOin(LOin),          
        .LOout(),

        .Zhighin(Zhighin),      
        .Zlowin(Zlowin),
        .Zhighout(Zhighout),
        .Zlowout(Zlowout)

    );

    // GTKWave dump
    initial begin
        $dumpfile("booth_multiplier_tb.vcd");
        $dumpvars(0, booth_multiplier_tb);
    end

    // clock generator
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
                LoadR3b  : Present_state <= LoadR1a;
                LoadR1a  : Present_state <= LoadR1b;
                LoadR1b  : Present_state <= T0;
                T0       : Present_state <= T1;
                T1       : Present_state <= T2;
                T2       : Present_state <= T3;
                T3       : Present_state <= T4;
                T4       : Present_state <= T5;
                T5       : Present_state <= T6;
                T6       : Present_state <= T6;

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

        Zhighin  = 0;
        Zlowin   = 0;
        Zhighout = 0;
        Zlowout  = 0;
        LOin     = 0;
        HIin     = 0;

        Mdatain  = 32'b0;

        PCin     = 0;
        PCout    = 0;
        MARin    = 0;
        IRin     = 0;

        ALU_DIV  = 0;
        ALUop    = 4'b0000; 

        case (Present_state)

            // Load R3 = multiplicand
            LoadR3a: begin
                Mdatain = 32'h10010000; // 
                Read = 1;
                MDRin = 1;
            end
            LoadR3b: begin
                MDRout = 1;
                Rin[3] = 1;
            end

            // Load R1 = multiplier
            LoadR1a: begin
                Mdatain = 32'h00010001; //
                Read = 1;
                MDRin = 1;
            end
            LoadR1b: begin
                MDRout = 1;
                Rin[1] = 1;
            end

            // fetch cyckle
            T0: begin
                PCout = 1;
                MARin = 1;
                IncPC = 1;
            end

            T1: begin
                Zlowout = 1;
                PCin = 1;
                Read = 1;
                MDRin = 1;
            end

            T2: begin
                MDRout = 1;
                IRin = 1;
            end

            T3: begin
                Rout[3] = 1;  // R3 to Y
                Yin = 1;
            end

            T4: begin
                ALUop   = 4'd11;     // multiply opcode
                Rout[1] = 1;  // R1 to Bus
                Zin = 1;

            end

            T5: begin
                Zlowout = 1;
                LOin = 1;   

            end

            T6: begin
                Zhighout = 1;
                HIin = 1;
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
