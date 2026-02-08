module datapath(
	input  wire clock, clear,
	input  wire [31:0] A,
	input  wire [31:0] RegisterImmediate,
	input  wire Read,
	input  wire [31:0] Mdatain,
	input  wire [3:0] ALUop,
	input  wire ALU_MUL,
	input  wire ALU_DIV,
	
	
	input  wire [15:0] Rin,   // R0in ... R15in
	input  wire [15:0] Rout , // R0out ... R15out
	
	input  wire MARin, MARout,
	input  wire PCin, PCout,
	input  wire IRin, IRout,
	input  wire Yin,  Yout,
	input  wire MDRin, MDRout,
	input  wire HIin, HIout,
	input  wire LOin, LOout,
	input wire Zhighin, Zlowin, Zhighout, Zlowout

);


wire [31:0] MDR_data_out;
wire [31:0] MDR_mux_out;


wire [31:0] BusMuxOut, BusMuxInRZ, BusMuxInRA, BusMuxInRB;
wire [63:0] zregin;

//General Purpose Registers
wire [31:0] R0_data_out;
wire [31:0] R1_data_out;
wire [31:0] R2_data_out;
wire [31:0] R3_data_out;
wire [31:0] R4_data_out;
wire [31:0] R5_data_out;
wire [31:0] R6_data_out;
wire [31:0] R7_data_out; 
wire [31:0] R8_data_out;
wire [31:0] R9_data_out;
wire [31:0] R10_data_out;
wire [31:0] R11_data_out;
wire [31:0] R12_data_out;
wire [31:0] R13_data_out;
wire [31:0] R14_data_out;
wire [31:0] R15_data_out;

//Special Registers
wire [31:0] PC_data_out;
wire [31:0] IR_data_out;
wire [31:0] Y_data_out;
wire [31:0] MAR_data_out;
wire [31:0] HI_data_out;
wire [31:0] LO_data_out;

wire [31:0] Zlow_data_out;
wire [31:0] Zhigh_data_out;

// Devices


register R0(
    .clear(clear),
    .clock(clock),
    .enable(Rin[0]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R0_data_out)
);
register R1(
    .clear(clear),
    .clock(clock),
    .enable(Rin[1]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R1_data_out)
);
register R2(
    .clear(clear),
    .clock(clock),
    .enable(Rin[2]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R2_data_out)
);
register R3(
    .clear(clear),
    .clock(clock),
    .enable(Rin[3]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R3_data_out)
);
register R4(
    .clear(clear),
    .clock(clock),
    .enable(Rin[4]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R4_data_out)
);
register R5(
    .clear(clear),
    .clock(clock),
    .enable(Rin[5]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R5_data_out)
);
register R6(
    .clear(clear),
    .clock(clock),
    .enable(Rin[6]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R6_data_out)
);
register R7(
    .clear(clear),
    .clock(clock),
    .enable(Rin[7]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R7_data_out)
);
register R8(
    .clear(clear),
    .clock(clock),
    .enable(Rin[8]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R8_data_out)
);
register R9(
    .clear(clear),
    .clock(clock),
    .enable(Rin[9]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R9_data_out)
);
register R10(
    .clear(clear),
    .clock(clock),
    .enable(Rin[10]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R10_data_out)
);
register R11(
    .clear(clear),
    .clock(clock),
    .enable(Rin[11]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R11_data_out)
);
register R12(
    .clear(clear),
    .clock(clock),
    .enable(Rin[12]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R12_data_out)
);
register R13(
    .clear(clear),
    .clock(clock),
    .enable(Rin[13]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R13_data_out)
);
register R14(
    .clear(clear),
    .clock(clock),
    .enable(Rin[14]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R14_data_out)
);
register R15(
    .clear(clear),
    .clock(clock),
    .enable(Rin[15]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R15_data_out)
);


register PC(
    .clear(clear),
    .clock(clock),
    .enable(PCin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(PC_data_out)
);
register MAR(
    .clear(clear),
    .clock(clock),
    .enable(MARin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(MAR_data_out)
);
register IR(
    .clear(clear),
    .clock(clock),
    .enable(IRin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(IR_data_out)
);
register Y(
    .clear(clear),
    .clock(clock),
    .enable(Yin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(Y_data_out)
);
register MDR(
    .clear(clear),
    .clock(clock),
    .enable(MDRin),
    .BusMuxOut(MDR_mux_out),
    .BusMuxIn(MDR_data_out)
);
register HI(
    .clear(clear),
    .clock(clock),
    .enable(HIin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(HI_data_out)
);
register LO(
    .clear(clear),
    .clock(clock),
    .enable(LOin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(LO_data_out)
);

register Zlow(
    .clear(clear),
    .clock(clock),
    .enable(Zlowin),
    .BusMuxOut(zregin[31:0]),
    .BusMuxIn(Zlow_data_out)
);
register Zhigh(
    .clear(clear),
    .clock(clock),
    .enable(Zhighin),
    .BusMuxOut(zregin[63:32]),
    .BusMuxIn(Zhigh_data_out)
);

// ALU wires
wire [31:0] alu_result;
wire [63:0] alu_out;
wire [63:0] mul_out;
wire [63:0] div_out;

ALU alu (
    .A(Y_data_out),
    .B(BusMuxOut),
    .op(ALUop),
    .result(alu_result)
);
assign alu_out = {32'b0, alu_result};

// multiplier unit (block A)
booth_multiplier mul (
    .multiplicand(Y_data_out),
    .multiplier(BusMuxOut),
    .product(mul_out)
);

divider div (
    .dividend(Y_data_out),
    .divisor(BusMuxOut),
    .result(div_out)
);

// ALU output MUX to Z 
assign zregin =
    (ALU_MUL) ? mul_out :
    (ALU_DIV) ? div_out :
                alu_out;

// MDR source select (Figure 4 in Phase 1 doc):
// Read=1 takes data from memory input, otherwise from internal bus.
assign MDR_mux_out = Read ? Mdatain : BusMuxOut;

// Bus
Bus bus(
    // Temp registers
//    .BusMuxInRZ(BusMuxInRZ),
//    .BusMuxInRA(BusMuxInRA),
//    .BusMuxInRB(BusMuxInRB),

    // General-purpose registers
    .BusMuxInR0(R0_data_out),
    .BusMuxInR1(R1_data_out),
    .BusMuxInR2(R2_data_out),
    .BusMuxInR3(R3_data_out),
    .BusMuxInR4(R4_data_out),
    .BusMuxInR5(R5_data_out),
    .BusMuxInR6(R6_data_out),
    .BusMuxInR7(R7_data_out),
    .BusMuxInR8(R8_data_out),
    .BusMuxInR9(R9_data_out),
    .BusMuxInR10(R10_data_out),
    .BusMuxInR11(R11_data_out),
    .BusMuxInR12(R12_data_out),
    .BusMuxInR13(R13_data_out),
    .BusMuxInR14(R14_data_out),
    .BusMuxInR15(R15_data_out),

    // Special registers
    .BusMuxInPC(PC_data_out),
    .BusMuxInMAR(MAR_data_out),
	 
	 .BusMuxInZlow(Zlow_data_out),
	 .BusMuxInZhigh(Zhigh_data_out),
	 
	 .BusMuxInMDR(MDR_data_out),
    .BusMuxInIR(IR_data_out),
    .BusMuxInY(Y_data_out),
    .BusMuxInHI(HI_data_out),
    .BusMuxInLO(LO_data_out),
	 
	 
	 
	 .R0out(Rout[0]),
    .R1out(Rout[1]),
    .R2out(Rout[2]),
    .R3out(Rout[3]),
    .R4out(Rout[4]),
    .R5out(Rout[5]),
    .R6out(Rout[6]),
    .R7out(Rout[7]),
    .R8out(Rout[8]),
    .R9out(Rout[9]),
    .R10out(Rout[10]),
    .R11out(Rout[11]),
    .R12out(Rout[12]),
    .R13out(Rout[13]),
    .R14out(Rout[14]),
    .R15out(Rout[15]),
	 

	 .PCout(PCout),
	 .MARout(MARout),
    .MDRout(MDRout),
	 .IRout(IRout),
    .HIout(HIout),
    .LOout(LOout),
    .Yout (Yout),
	 
	 
	 .Zlowout(Zlowout),
	 .Zhighout(Zhighout),

	 
    // Output
	 
    .BusMuxOut(BusMuxOut)
);


endmodule
