module datapath(
	input  wire clock, clear,
	input  wire [31:0] A,
	input  wire [31:0] RegisterImmediate,
	
	
	input  wire [15:0] Rin,   // R0in ... R15in
	input  wire [15:0] Rout , // R0out ... R15out
	
	input  wire PCin, PCout,
	input  wire IRin, IRout,
	input  wire Yin,  Yout,
	input  wire MDRin, MDRout,
	input  wire HIin, HIout,
	input  wire LOin, LOout,
	input wire Zhighin, Zlowin, Zhighout, Zlowout

);


wire [31:0] MDR_data_in, MDR_data_out;


wire [31:0] BusMuxOut, BusMuxInRZ, BusMuxInRA, BusMuxInRB;
wire [31:0] zregin;

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


register R0(clear, clock, Rin[0],  BusMuxOut, R0_data_out);
register R1(clear, clock, Rin[1],  BusMuxOut, R1_data_out);
register R2(clear, clock, Rin[2],  BusMuxOut, R2_data_out);
register R3(clear, clock, Rin[3],  BusMuxOut, R3_data_out);
register R4(clear, clock, Rin[4],  BusMuxOut, R4_data_out);
register R5(clear, clock, Rin[5],  BusMuxOut, R5_data_out);
register R6(clear, clock, Rin[6],  BusMuxOut, R6_data_out);
register R7(clear, clock, Rin[7],  BusMuxOut, R7_data_out);
register R8(clear, clock, Rin[8],  BusMuxOut, R8_data_out);
register R9 (clear, clock, Rin[9],  BusMuxOut, R9_data_out);
register R10(clear, clock, Rin[10], BusMuxOut, R10_data_out);
register R11(clear, clock, Rin[11], BusMuxOut, R11_data_out);
register R12(clear, clock, Rin[12], BusMuxOut, R12_data_out);
register R13(clear, clock, Rin[13], BusMuxOut, R13_data_out);
register R14(clear, clock, Rin[14], BusMuxOut, R14_data_out);
register R15(clear, clock, Rin[15], BusMuxOut, R15_data_out);


register PC(clear, clock, PCin, BusMuxOut, PC_data_out);
register IR(clear, clock, IRin, BusMuxOut, IR_data_out);
register Y(clear, clock, Yin, BusMuxOut, Y_data_out);
register MDR(clear, clock, MDRin, BusMuxOut, MDR_data_out);
register HI(clear, clock, HIin, BusMuxOut, HI_data_out);
register LO(clear, clock, LOin, BusMuxOut, LO_data_out);

register Zlow(clear, clock, Zlowin, zregin[31:0], Zlow_data_out);
register Zhigh(clear, clock, Zhighin, zregin[63:32], Zhigh_data_out);

// Adder and Z register
adder add(A, BusMuxOut, zregin);



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
    .MDRout(MDRout),
    .HIout(HIout),
    .LOout(LOout),
    .Yout (Yout),
	 
	 
	 .Zlowout(Zlowout),
	 .Zhighout(Zhighout),

	 
    // Output
	 
    .BusMuxOut(BusMuxOut)
);


endmodule


