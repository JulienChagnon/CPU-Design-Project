`timescale 1ns/10ps
// mul R3, R1, R3.
// R1 = 0x00000006, R3 = 0x00000054, Final R3 = 0x000001F8

module booth_multiplier_tb;

    reg Clock;
    reg clear;

    reg [15:0] Rin;     //register input 
    reg [15:0] Rout;    //register output

    reg PCin, PCout;    
    reg MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin;
    reg Zin, Zlowout;
    reg IncPC;
    reg Read;
    reg [3:0] ALUop;

    reg [31:0] Mdatain;     //memory data input bus

    //FSM state encoding
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

    //current FSM state
    reg [3:0] Present_state = Default;

    //instatiate device under test (DUT)
    datapath DUT (
        .clock(Clock),
        .clear(clear),
        .A(32'b0),
        .RegisterImmediate(32'b0),  //no immediate value
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
        .IRout(),       //unused IRout
        .Yin(Yin),
        .Yout(),        // unused Yout
        .MDRin(MDRin),
        .MDRout(MDRout),
        .HIin(1'b0),    // unused HIin
        .HIout(),       // unused HIout
        .LOin(1'b0),    // unused LOin
        .LOout(),       // unused LOout
        .Zhighin(1'b0), // unused Zhighin
        .Zlowin(Zin),   // load Zlowin
        .Zhighout(),
        .Zlowout(Zlowout)
    );

    // needed for simulation on MAC
    initial begin
        $dumpfile("booth_multiplier_tb.vcd");
        $dumpvars(0, booth_multiplier_tb);
    end

    //clock generator
    initial begin
        Clock = 0;                      //start clock low
        forever #10 Clock = ~Clock;     // toggle every 10 ns
    end

    //FSM state transitions
    always @(posedge Clock) begin
        if (clear)
            Present_state <= Default;               // on reset go to default state
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
                T5       : Present_state <= T5;     //stay in T5 after multiplication complete
            endcase
        end
    end

    //control signal logic (set all to default values and override in each state as needed)
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
            //load R3 = 0x54
            LoadR3a: begin
                Mdatain = 32'h00000054;     //put value on bus
                Read = 1;                   // memory read
                MDRin = 1;                  // load into MDR
            end
            LoadR3b: begin
                MDRout = 1;                 // output from MDR
                Rin[3] = 1;                 // load into R3
            end

            //load R1 = 0x06
            LoadR1a: begin
                Mdatain = 32'h00000006;     //put value on bus
                Read = 1;                   // memory read
                MDRin = 1;                  // load into MDR
            end
            LoadR1b: begin
                MDRout = 1;                 // output from MDR
                Rin[1] = 1;                 // load into R1
            end

            T0: begin
                PCout = 1;                  //output PC 
                MARin = 1;                  //load MAR
                IncPC = 1;                  // increment PC
                Zin = 1;                    // store result in Zin
            end

            T1: begin
                Zlowout = 1;                // Output Z low
                PCin = 1;                   // Load PC with incremented value
                Read = 1;                   // memory read
                MDRin = 1;                  // load MDR
                Mdatain = 32'h00000000;     // dummy instruction (not used in multiplication but simulates typical instruction fetch)
            end

            T2: begin
                MDRout = 1;                 //output from MDR
                IRin = 1;                   // load into IR 
            end

            T3: begin
                Rout[3] = 1;                // output R3 (multiplicand)
                Yin = 1;                    // load into Y
            end

            T4: begin
                Rout[1] = 1;                // output R1 (multiplier)
                ALUop = 4'd11;              // set ALU op code to multiplication
                Zin = 1;                    // store result in Zin
            end

            T5: begin
                Zlowout = 1;                //output result
                Rin[3] = 1;                 //write back to R3
            end
        endcase
    end

    //reset pulse 
    initial begin
        clear = 1;      //assert reset
        #20 clear = 0;  //release reset after 20 ns
    end

    // needed for simulation on MAC
    initial begin
        #500;
        $display("Simulation complete.");
        $finish;
    end

endmodule
