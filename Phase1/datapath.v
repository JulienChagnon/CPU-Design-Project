module datapath(
	input  wire clock, clear,
	input  wire [31:0] A,
	input  wire [31:0] RegisterImmediate,
	
	input  wire RZout, RAout, RBout,
	input  wire RAin, RBin, RZin
	
	input  wire [15:0] Rin,   // R0in ... R15in
	input  wire [15:0] Rout   // R0out ... R15out
	
	input  wire PCin, PCout,
	input  wire IRin, IRout,
	input  wire Yin,  Yout,
	input  wire MDRin, MDRout,
	input  wire HIin, HIout,
	input  wire LOin, LOout

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

// Devices
register RA(clear, clock, RAin, RegisterImmediate, BusMuxInRA);
register RB(clear, clock, RBin, BusMuxOut, BusMuxInRB);
register RZ(clear, clock, RZin, zregin, BusMuxInRZ);


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

// Adder and Z register
adder add(A, BusMuxOut, zregin);



// Bus
Bus bus(
	R0_data_out, R1_data_out, R2_data_out, R3_data_out,
	R4_data_out, R5_data_out, R6_data_out, R7_data_out,
	R8_data_out, R9_data_out, R10_data_out, R11_data_out,
	R12_data_out, R13_data_out, R14_data_out, R15_data_out,
	MDR_data_out, PC_data_out, IR_data_out, Y_data_out, 
	HI_data_out, LO_data_out
	
	BusMuxInRA, BusMuxInRB, BusMuxInRZ,
	Rout, RAout, RBout, RZout,	BusMuxOut
);


endmodule


