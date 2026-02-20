`timescale 1ns/10ps
// shl R7, R0, R4. 

module shift_left_tb;

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

    reg ALU_MUL, ALU_DIV;   // ALU multiply and divide enables

    reg [31:0] Mdatain;     //memory data input bus

    localparam ALU_SHL = 4'd7;      // ALU operation code for shift left

     //FSM state encoding
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

    //current FSM state
    reg [3:0] Present_state = Default;

    //instatiate device under test (DUT)
    datapath DUT (
        .clock(Clock),
        .clear(clear),
        .A(32'b0),
        .RegisterImmediate(32'b0),
        .Read(Read),
        .Mdatain(Mdatain),
        .ALUop(ALUop),
        .ALU_MUL(ALU_MUL),
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
        .HIin(1'b0),
        .HIout(),
        .LOin(1'b0),
        .LOout(),
        .Zhighin(1'b0),
        .Zlowin(Zin),
        .Zhighout(),
        .Zlowout(Zlowout)
    );

    // needed for simulation on MAC
    initial begin
        $dumpfile("shift_left_tb.vcd");
        $dumpvars(0, shift_left_tb);
    end

   //clock generator
    initial begin
        Clock = 0;                      //start clock low
        forever #10 Clock = ~Clock;     // toggle every 10 ns
    end

    always @(posedge Clock) begin
        if (clear)
            Present_state <= Default;               // on reset go to default state
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
                T5       : Present_state <= T5;     //stay in T5 after shift complete
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

        ALU_MUL  = 0;
        ALU_DIV  = 0;

        //load R0 with 0x34
        case (Present_state)
            LoadR0a: begin
                Mdatain = 32'h00000034;     //value onto bus
                Read = 1;                   // Memory read
                MDRin = 1;                  // load into MDR
            end
            LoadR0b: begin
                MDRout = 1;                 // output from MDR
                Rin[0] = 1;                 // load into R0
            end

            LoadR4a: begin
                Mdatain = 32'h00000002;     // put value onto bus
                Read = 1;                   // Memory read
                MDRin = 1;                  // load into MDR
            end
            LoadR4b: begin
                MDRout = 1;                 // output from MDR
                Rin[4] = 1;                 // load into R4
            end

            T0: begin
                PCout = 1;                  // output PC (not used in this test)
                MARin = 1;                  //load MAR
                IncPC = 1;                  //increment PC
                Zin = 1;                    //Store result in Zin
            end

            T1: begin
                Zlowout = 1;                // Output Z low
                PCin = 1;                   // Load PC with incremented value
                Read = 1;                   // memory read
                MDRin = 1;                  //load MDR with instruction
                Mdatain = 32'h00000000;     // dummy instruction (not used in shl but simulates typical instruction fetch)
            end

            T2: begin
                MDRout = 1;                 //output from MDR
                IRin = 1;                   // load into IR 
            end

            T3: begin
                Rout[0] = 1;                // output R0 (value to be shifted)
                Yin = 1;                    // load into Y 
            end

            T4: begin
                Rout[4] = 1;                // output R4 (shift amount)
                ALUop = ALU_SHL;            // set ALU to perform shift left
                Zin = 1;                    // store result in Zin
            end

            T5: begin
                Zlowout = 1;                //output result of shift
                Rin[7] = 1;                 // load into R7 (destination register for shl result)
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
