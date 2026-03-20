`timescale 1ns/10ps

module control_unit (
    input  wire        clock,
    input  wire        reset,
    input  wire        stop,
    input  wire [31:0] IR,
    input  wire        CONout,

    output reg         Run,

    output reg         Read,
    output reg         Write,
    output reg [3:0]   ALUop,

    output reg [15:0]  Rin,
    output reg [15:0]  Rout,

    output reg         MARin,
    output reg         PCin,
    output reg         PCout,
    output reg         IRin,
    output reg         Yin,
    output reg         MDRin,
    output reg         MDRout,
    output reg         HIin,
    output reg         HIout,
    output reg         LOin,
    output reg         LOout,
    output reg         Zhighin,
    output reg         Zlowin,
    output reg         Zhighout,
    output reg         Zlowout,
    output reg         BAout,
    output reg         IncPC,

    output reg         UseSelectEncode,
    output reg         Gra,
    output reg         Grb,
    output reg         Grc,
    output reg         Rin_ctrl,
    output reg         Rout_ctrl,
    output reg         Cout,

    output reg         InPortout,
    output reg         OutPortin,
    output reg         CONin,

    output wire [7:0]  state_dbg
);

//opcode values for each instruction
localparam [4:0]
    OP_ADD  = 5'b00000,
    OP_SUB  = 5'b00001,
    OP_AND  = 5'b00010,
    OP_OR   = 5'b00011,
    OP_SHR  = 5'b00100,
    OP_SHRA = 5'b00101,
    OP_SHL  = 5'b00110,
    OP_ROR  = 5'b00111,
    OP_ROL  = 5'b01000,
    OP_ADDI = 5'b01001,
    OP_ANDI = 5'b01010,
    OP_ORI  = 5'b01011,
    OP_DIV  = 5'b01100,
    OP_MUL  = 5'b01101,
    OP_NEG  = 5'b01110,
    OP_NOT  = 5'b01111,
    OP_LD   = 5'b10000,
    OP_LDI  = 5'b10001,
    OP_ST   = 5'b10010,
    OP_JAL  = 5'b10011,
    OP_JR   = 5'b10100,
    OP_BR   = 5'b10101,
    OP_IN   = 5'b10110,
    OP_OUT  = 5'b10111,
    OP_MFHI = 5'b11000,
    OP_MFLO = 5'b11001,
    OP_NOP  = 5'b11010,
    OP_HALT = 5'b11011;


//control unit states, fetch/decode states are the same for all instructions
localparam [7:0]
    RESET_STATE = 8'd0,
    FETCH0      = 8'd1,
    FETCH1      = 8'd2,
    FETCH2      = 8'd3,
    FETCH3      = 8'd4,
    DECODE      = 8'd5,

    ADD4        = 8'd10,
    ADD5        = 8'd11,
    ADD6        = 8'd12,
    SUB4        = 8'd13,
    SUB5        = 8'd14,
    SUB6        = 8'd15,
    AND4        = 8'd16,
    AND5        = 8'd17,
    AND6        = 8'd18,
    OR4         = 8'd19,
    OR5         = 8'd20,
    OR6         = 8'd21,
    SHR4        = 8'd22,
    SHR5        = 8'd23,
    SHR6        = 8'd24,
    SHRA4       = 8'd25,
    SHRA5       = 8'd26,
    SHRA6       = 8'd27,
    SHL4        = 8'd28,
    SHL5        = 8'd29,
    SHL6        = 8'd30,
    ROR4        = 8'd31,
    ROR5        = 8'd32,
    ROR6        = 8'd33,
    ROL4        = 8'd34,
    ROL5        = 8'd35,
    ROL6        = 8'd36,

    ADDI4       = 8'd40,
    ADDI5       = 8'd41,
    ADDI6       = 8'd42,
    ANDI4       = 8'd43,
    ANDI5       = 8'd44,
    ANDI6       = 8'd45,
    ORI4        = 8'd46,
    ORI5        = 8'd47,
    ORI6        = 8'd48,

    NEG4        = 8'd50,
    NEG5        = 8'd51,
    NOT4        = 8'd52,
    NOT5        = 8'd53,

    LDI4        = 8'd60,
    LDI5        = 8'd61,
    LDI6        = 8'd62,
    LD4         = 8'd63,
    LD5         = 8'd64,
    LD6         = 8'd65,
    LD7         = 8'd66,
    LD8         = 8'd67,
    LD9         = 8'd68,
    ST4         = 8'd69,
    ST5         = 8'd70,
    ST6         = 8'd71,
    ST7         = 8'd72,
    ST8         = 8'd73,

    BR4         = 8'd80,
    BR5         = 8'd81,
    BR6         = 8'd82,
    BR7         = 8'd83,

    JR4         = 8'd90,
    JAL4        = 8'd91,
    JAL5        = 8'd92,

    MUL4        = 8'd100,
    MUL5        = 8'd101,
    MUL6        = 8'd102,
    MUL7        = 8'd103,
    DIV4        = 8'd104,
    DIV5        = 8'd105,
    DIV6        = 8'd106,
    DIV7        = 8'd107,

    MFHI4       = 8'd110,
    MFLO4       = 8'd111,
    IN4         = 8'd112,
    OUT4        = 8'd113,
    NOP4        = 8'd114,
    HALT_STATE  = 8'd115;

reg  [7:0] present_state = RESET_STATE;
reg  [7:0] next_state;
wire [4:0] opcode = IR[31:27];

assign state_dbg = present_state;

always @(posedge clock or posedge reset or posedge stop) begin
    if (reset)
        present_state <= RESET_STATE;
    else if (stop)
        present_state <= HALT_STATE;
    else
        present_state <= next_state;
end

always @(*) begin
    next_state = present_state;

    case (present_state)
        RESET_STATE: next_state = FETCH0;
        FETCH0:      next_state = FETCH1;
        FETCH1:      next_state = FETCH2;
        FETCH2:      next_state = FETCH3;
        FETCH3:      next_state = DECODE;

        DECODE: begin
            case (opcode)
                OP_ADD:  next_state = ADD4;
                OP_SUB:  next_state = SUB4;
                OP_AND:  next_state = AND4;
                OP_OR:   next_state = OR4;
                OP_SHR:  next_state = SHR4;
                OP_SHRA: next_state = SHRA4;
                OP_SHL:  next_state = SHL4;
                OP_ROR:  next_state = ROR4;
                OP_ROL:  next_state = ROL4;
                OP_ADDI: next_state = ADDI4;
                OP_ANDI: next_state = ANDI4;
                OP_ORI:  next_state = ORI4;
                OP_DIV:  next_state = DIV4;
                OP_MUL:  next_state = MUL4;
                OP_NEG:  next_state = NEG4;
                OP_NOT:  next_state = NOT4;
                OP_LD:   next_state = LD4;
                OP_LDI:  next_state = LDI4;
                OP_ST:   next_state = ST4;
                OP_JAL:  next_state = JAL4;
                OP_JR:   next_state = JR4;
                OP_BR:   next_state = BR4;
                OP_IN:   next_state = IN4;
                OP_OUT:  next_state = OUT4;
                OP_MFHI: next_state = MFHI4;
                OP_MFLO: next_state = MFLO4;
                OP_NOP:  next_state = NOP4;
                OP_HALT: next_state = HALT_STATE;
                default: next_state = HALT_STATE;
            endcase
        end

        ADD4:  next_state = ADD5;
        ADD5:  next_state = ADD6;
        ADD6:  next_state = FETCH0;
        SUB4:  next_state = SUB5;
        SUB5:  next_state = SUB6;
        SUB6:  next_state = FETCH0;
        AND4:  next_state = AND5;
        AND5:  next_state = AND6;
        AND6:  next_state = FETCH0;
        OR4:   next_state = OR5;
        OR5:   next_state = OR6;
        OR6:   next_state = FETCH0;
        SHR4:  next_state = SHR5;
        SHR5:  next_state = SHR6;
        SHR6:  next_state = FETCH0;
        SHRA4: next_state = SHRA5;
        SHRA5: next_state = SHRA6;
        SHRA6: next_state = FETCH0;
        SHL4:  next_state = SHL5;
        SHL5:  next_state = SHL6;
        SHL6:  next_state = FETCH0;
        ROR4:  next_state = ROR5;
        ROR5:  next_state = ROR6;
        ROR6:  next_state = FETCH0;
        ROL4:  next_state = ROL5;
        ROL5:  next_state = ROL6;
        ROL6:  next_state = FETCH0;

        ADDI4: next_state = ADDI5;
        ADDI5: next_state = ADDI6;
        ADDI6: next_state = FETCH0;
        ANDI4: next_state = ANDI5;
        ANDI5: next_state = ANDI6;
        ANDI6: next_state = FETCH0;
        ORI4:  next_state = ORI5;
        ORI5:  next_state = ORI6;
        ORI6:  next_state = FETCH0;

        NEG4:  next_state = NEG5;
        NEG5:  next_state = FETCH0;
        NOT4:  next_state = NOT5;
        NOT5:  next_state = FETCH0;

        LDI4:  next_state = LDI5;
        LDI5:  next_state = LDI6;
        LDI6:  next_state = FETCH0;
        LD4:   next_state = LD5;
        LD5:   next_state = LD6;
        LD6:   next_state = LD7;
        LD7:   next_state = LD8;
        LD8:   next_state = LD9;
        LD9:   next_state = FETCH0;
        ST4:   next_state = ST5;
        ST5:   next_state = ST6;
        ST6:   next_state = ST7;
        ST7:   next_state = ST8;
        ST8:   next_state = FETCH0;

        BR4:   next_state = BR5;
        BR5:   next_state = CONout ? BR6 : FETCH0;
        BR6:   next_state = BR7;
        BR7:   next_state = FETCH0;

        JR4:   next_state = FETCH0;
        JAL4:  next_state = JAL5;
        JAL5:  next_state = FETCH0;

        MUL4:  next_state = MUL5;
        MUL5:  next_state = MUL6;
        MUL6:  next_state = MUL7;
        MUL7:  next_state = FETCH0;
        DIV4:  next_state = DIV5;
        DIV5:  next_state = DIV6;
        DIV6:  next_state = DIV7;
        DIV7:  next_state = FETCH0;

        MFHI4: next_state = FETCH0;
        MFLO4: next_state = FETCH0;
        IN4:   next_state = FETCH0;
        OUT4:  next_state = FETCH0;
        NOP4:  next_state = FETCH0;
        HALT_STATE: next_state = HALT_STATE;

        default: next_state = HALT_STATE;
    endcase
end

always @(*) begin
    Run             = 1'b1;

    Read            = 1'b0;
    Write           = 1'b0;
    ALUop           = 4'd3;

    Rin             = 16'b0;
    Rout            = 16'b0;

    MARin           = 1'b0;
    PCin            = 1'b0;
    PCout           = 1'b0;
    IRin            = 1'b0;
    Yin             = 1'b0;
    MDRin           = 1'b0;
    MDRout          = 1'b0;
    HIin            = 1'b0;
    HIout           = 1'b0;
    LOin            = 1'b0;
    LOout           = 1'b0;
    Zhighin         = 1'b0;
    Zlowin          = 1'b0;
    Zhighout        = 1'b0;
    Zlowout         = 1'b0;
    BAout           = 1'b0;
    IncPC           = 1'b0;

    UseSelectEncode = 1'b1;
    Gra             = 1'b0;
    Grb             = 1'b0;
    Grc             = 1'b0;
    Rin_ctrl        = 1'b0;
    Rout_ctrl       = 1'b0;
    Cout            = 1'b0;

    InPortout       = 1'b0;
    OutPortin       = 1'b0;
    CONin           = 1'b0;

    case (present_state)
        RESET_STATE: begin
        end

        FETCH0: begin
            PCout   = 1'b1;
            MARin   = 1'b1;
            IncPC   = 1'b1;
            ALUop   = 4'd3;
            Zlowin  = 1'b1;
        end

        FETCH1: begin
            Zlowout = 1'b1;
            PCin    = 1'b1;
            Read    = 1'b1;
        end

        FETCH2: begin
            Read    = 1'b1;
            MDRin   = 1'b1;
        end

        FETCH3: begin
            MDRout  = 1'b1;
            IRin    = 1'b1;
        end

        DECODE: begin
        end

        ADD4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ADD5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd3; Zlowin = 1'b1; end
        ADD6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        SUB4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        SUB5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd4; Zlowin = 1'b1; end
        SUB6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        AND4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        AND5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd1; Zlowin = 1'b1; end
        AND6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        OR4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        OR5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd0; Zlowin = 1'b1; end
        OR6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        SHR4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        SHR5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd5; Zlowin = 1'b1; end
        SHR6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        SHRA4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        SHRA5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd6; Zlowin = 1'b1; end
        SHRA6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        SHL4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        SHL5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd7; Zlowin = 1'b1; end
        SHL6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ROR4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ROR5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd8; Zlowin = 1'b1; end
        ROR6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ROL4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ROL5: begin Grc = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd9; Zlowin = 1'b1; end
        ROL6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ADDI4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ADDI5: begin Cout = 1'b1; ALUop = 4'd3; Zlowin = 1'b1; end
        ADDI6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ANDI4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ANDI5: begin Cout = 1'b1; ALUop = 4'd1; Zlowin = 1'b1; end
        ANDI6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ORI4: begin Grb = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        ORI5: begin Cout = 1'b1; ALUop = 4'd0; Zlowin = 1'b1; end
        ORI6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        NEG4: begin Grb = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd10; Zlowin = 1'b1; end
        NEG5: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        NOT4: begin Grb = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd2; Zlowin = 1'b1; end
        NOT5: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        LDI4: begin Grb = 1'b1; BAout = 1'b1; Yin = 1'b1; end
        LDI5: begin Cout = 1'b1; ALUop = 4'd3; Zlowin = 1'b1; end
        LDI6: begin Zlowout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        LD4: begin Grb = 1'b1; BAout = 1'b1; Yin = 1'b1; end
        LD5: begin Cout = 1'b1; ALUop = 4'd3; Zlowin = 1'b1; end
        LD6: begin Zlowout = 1'b1; MARin = 1'b1; end
        LD7: begin Read = 1'b1; end
        LD8: begin Read = 1'b1; MDRin = 1'b1; end
        LD9: begin MDRout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end

        ST4: begin Grb = 1'b1; BAout = 1'b1; Yin = 1'b1; end
        ST5: begin Cout = 1'b1; ALUop = 4'd3; Zlowin = 1'b1; end
        ST6: begin Zlowout = 1'b1; MARin = 1'b1; end
        ST7: begin Gra = 1'b1; Rout_ctrl = 1'b1; MDRin = 1'b1; end
        ST8: begin Write = 1'b1; end

        BR4: begin
            Gra       = 1'b1;
            Rout_ctrl = 1'b1;
            CONin     = 1'b1;
        end
        BR5: begin
            if (CONout) begin
                PCout = 1'b1;
                Yin   = 1'b1;
            end
        end
        BR6: begin
            if (CONout) begin
                Cout   = 1'b1;
                ALUop  = 4'd3;
                Zlowin = 1'b1;
            end
        end
        BR7: begin
            if (CONout) begin
                Zlowout = 1'b1;
                PCin    = 1'b1;
            end
        end

        JR4: begin
            Gra       = 1'b1;
            Rout_ctrl = 1'b1;
            PCin      = 1'b1;
        end

        JAL4: begin
            UseSelectEncode = 1'b0;
            Rin             = 16'h1000;
            PCout           = 1'b1;
        end
        JAL5: begin
            Gra       = 1'b1;
            Rout_ctrl = 1'b1;
            PCin      = 1'b1;
        end

        MUL4: begin Gra = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        MUL5: begin Grb = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd11; Zlowin = 1'b1; Zhighin = 1'b1; end
        MUL6: begin Zhighout = 1'b1; HIin = 1'b1; end
        MUL7: begin Zlowout = 1'b1; LOin = 1'b1; end

        DIV4: begin Gra = 1'b1; Rout_ctrl = 1'b1; Yin = 1'b1; end
        DIV5: begin Grb = 1'b1; Rout_ctrl = 1'b1; ALUop = 4'd12; Zlowin = 1'b1; Zhighin = 1'b1; end
        DIV6: begin Zhighout = 1'b1; HIin = 1'b1; end
        DIV7: begin Zlowout = 1'b1; LOin = 1'b1; end

        MFHI4: begin HIout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end
        MFLO4: begin LOout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end
        IN4:   begin InPortout = 1'b1; Gra = 1'b1; Rin_ctrl = 1'b1; end
        OUT4:  begin Gra = 1'b1; Rout_ctrl = 1'b1; OutPortin = 1'b1; end

        NOP4: begin
        end

        HALT_STATE: begin
            Run = 1'b0;
        end

        default: begin
            Run = 1'b0;
        end
    endcase
end

endmodule
