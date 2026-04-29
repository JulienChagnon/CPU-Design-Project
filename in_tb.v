`timescale 1ns/10ps
// in r5
// preload input port, then execute control sequence: InPortout, Gra, Rin

module in_tb;

    reg Clock;
    reg clear;

    reg [15:0] Rin;
    reg [15:0] Rout;

    reg PCin, PCout;
    reg MARin;
    reg MDRin, MDRout;
    reg IRin;
    reg Yin, Yout;
    reg Read, Write;
    reg [3:0] ALUop;
    reg BAout;

    // phase 2 select/encode controls
    reg UseSelectEncode;
    reg Gra, Grb, Grc;
    reg Rin_ctrl, Rout_ctrl;
    reg Cout;

    // phase 2 i/o controls
    reg InPortout, OutPortin, InPortStrobe;
    reg [31:0] InPortData;
    wire [31:0] OutPortData;

    parameter Default   = 4'd0,
              LoadIn    = 4'd1,
              T0        = 4'd2,
              T1        = 4'd3,
              T2        = 4'd4,
              T3        = 4'd5,
              T4        = 4'd6;

    reg [3:0] Present_state = Default;

    localparam [31:0] IN_PRELOAD = 32'h00000071;

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
        .Zlowin(1'b0),
        .Zhighout(1'b0),
        .Zlowout(1'b0),
        .BAout(BAout),
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
        .OutPortData(OutPortData)
    );

    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    always @(posedge Clock) begin
        if (clear)
            Present_state <= Default;
        else begin
            case (Present_state)
                Default : Present_state <= LoadIn;
                LoadIn  : Present_state <= T0;
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
        Write    = 0;
        MDRin    = 0;
        MDRout   = 0;
        Yin      = 0;
        Yout     = 0;
        PCin     = 0;
        PCout    = 0;
        MARin    = 0;
        IRin     = 0;
        ALUop    = 4'b0000;
        BAout    = 0;

        UseSelectEncode = 1;
        Gra      = 0;
        Grb      = 0;
        Grc      = 0;
        Rin_ctrl = 0;
        Rout_ctrl= 0;
        Cout     = 0;

        InPortout = 0;
        OutPortin = 0;
        InPortStrobe = 0;
        InPortData = 32'b0;

        case (Present_state)
            // preload input port register
            LoadIn: begin
                InPortData = IN_PRELOAD;
                InPortStrobe = 1;
            end

            // fetch sequence placeholder
            T0: begin
                PCout = 1;
                MARin = 1;
            end

            T1: begin
                Read = 1;
                MDRin = 1;
            end

            T2: begin
                MDRout = 1;
                IRin = 1;
            end

            // in r5: InPortout, Gra, Rin
            T3: begin
                InPortout = 1;
                Gra = 1;
                Rin_ctrl = 1;
            end
        endcase
    end

    initial begin
        clear = 1;
        #20 clear = 0;
    end

    initial begin
        // set ra field to r5
        #25;
        force DUT.IR_data_out = 32'b0;
        force DUT.IR_data_out[26:23] = 4'd5;
    end

    initial begin
        #200;
        if (DUT.R5_data_out === IN_PRELOAD)
            $display("in_tb PASSED: R5 = %h", DUT.R5_data_out);
        else
            $display("in_tb FAILED: R5 = %h expected %h", DUT.R5_data_out, IN_PRELOAD);

        release DUT.IR_data_out;
        $finish;
    end

endmodule
