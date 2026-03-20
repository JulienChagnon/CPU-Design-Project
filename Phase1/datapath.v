module datapath(
	input  wire clock, clear,
	input  wire [31:0] A,
	input  wire [31:0] RegisterImmediate,
	input  wire Read,
    input  wire Write,
	input  wire [3:0] ALUop,
	
	
	input  wire [15:0] Rin,   // R0in ... R15in
	input  wire [15:0] Rout , // R0out ... R15out
	
	input  wire MARin,
	input  wire PCin, PCout,
	input  wire IRin, IRout,
	input  wire Yin,  Yout,
	input  wire MDRin, MDRout,
	input  wire HIin, HIout,
	input  wire LOin, LOout,
	input wire Zhighin, Zlowin, Zhighout, Zlowout,
    input wire BAout,      
    input wire IncPC,      

    //select encode controls
    input wire UseSelectEncode,
    input wire Gra, Grb, Grc,
    input wire Rin_ctrl, Rout_ctrl,
    input wire Cout,

    //i/o port controls
    input wire InPortout,
    input wire OutPortin,
    input wire InPortStrobe,
    input wire [31:0] InPortData,
    output wire [31:0] OutPortData,

    // CON FF: branch condition latch
    input wire CONin,
    output wire CONout,

    //used to send instruction register value to the control unit
    output wire [31:0] IR_value
);


wire [31:0] BusMuxOut, BusMuxInRZ, BusMuxInRA, BusMuxInRB, BusMuxIn_MDR, Mdatain;
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
wire [31:0] HI_data_out;
wire [31:0] LO_data_out;

wire [31:0] Zlow_data_out;
wire [31:0] Zhigh_data_out;
wire [31:0] InPort_data_out;
wire [31:0] OutPort_data_out;

//for revising register R0
wire [31:0] R0_bus_out;         //modified bus output 
wire [15:0] Rin_decoded;
wire [15:0] Rout_decoded;
wire [31:0] C_sign_extended;
wire        select_encode_enable;
wire [15:0] Rin_internal;
wire [15:0] Rout_internal;

//if BAout is 1 then output 0 onto the bus instead of R0's value
//then R0 can be used as a zero register
assign R0_bus_out = BAout ? 32'b0 : R0_data_out;
assign select_encode_enable = (UseSelectEncode === 1'b1);
assign Rin_internal  = select_encode_enable ? Rin_decoded  : Rin;
assign Rout_internal = select_encode_enable ? Rout_decoded : Rout;
assign OutPortData = OutPort_data_out;
assign IR_value = IR_data_out;

select_encode select_encode_u (
    .IR(IR_data_out),
    .Gra(Gra),
    .Grb(Grb),
    .Grc(Grc),
    .Rin(Rin_ctrl),
    .Rout(Rout_ctrl),
    .BAout(BAout),
    .Cout(Cout),
    .Rin_decoded(Rin_decoded),
    .Rout_decoded(Rout_decoded),
    .C_sign_extended(C_sign_extended)
);

// Devices

register R0(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[0]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R0_data_out)
);
register R1(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[1]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R1_data_out)
);
register R2(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[2]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R2_data_out)
);
register R3(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[3]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R3_data_out)
);
register R4(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[4]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R4_data_out)
);
register R5(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[5]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R5_data_out)
);
register R6(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[6]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R6_data_out)
);
register R7(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[7]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R7_data_out)
);
register R8(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[8]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R8_data_out)
);
register R9(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[9]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R9_data_out)
);
register R10(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[10]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R10_data_out)
);
register R11(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[11]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R11_data_out)
);
register R12(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[12]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R12_data_out)
);
register R13(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[13]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R13_data_out)
);
register R14(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[14]),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(R14_data_out)
);
register R15(
    .clear(clear),
    .clock(clock),
    .enable(Rin_internal[15]),
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

// output port register: captures bus when OutPortin is asserted
register OutPort(
    .clear(clear),
    .clock(clock),
    .enable(OutPortin),
    .BusMuxOut(BusMuxOut),
    .BusMuxIn(OutPort_data_out)
);


register InPort(
    .clear(clear),
    .clock(clock),
    .enable(InPortStrobe),
    .BusMuxOut(InPortData),
    .BusMuxIn(InPort_data_out)
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
memory_subsystem mem_sys (
    .clk(clock),
    .clear(clear),
    .MARin(MARin),
    .MDRin(MDRin),
    .MDRout(MDRout),
    .Read(Read),
    .Write(Write),
    .BusMuxOut(BusMuxOut),
    .Mdatain(Mdatain),
    .BusMuxIn_MDR(BusMuxIn_MDR)
);

// ALU wires
wire [63:0] alu_result;

wire [31:0] alu_A = IncPC ? 32'd1 : Y_data_out;

ALU alu (
    .A(alu_A),
    .B(BusMuxOut),
    .op(ALUop),
    .result(alu_result)
);

// ALU output to Z
assign zregin = alu_result;

// Bus
Bus bus(
    // Temp registers
//    .BusMuxInRZ(BusMuxInRZ),
//    .BusMuxInRA(BusMuxInRA),
//    .BusMuxInRB(BusMuxInRB),

    // General-purpose registers
    .BusMuxInR0(R0_bus_out),            //put modified R0 bus output here
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
	 
	.BusMuxInMDR(BusMuxIn_MDR),
    .BusMuxInIR(IR_data_out),
    .BusMuxInY(Y_data_out),
    .BusMuxInHI(HI_data_out),
    .BusMuxInLO(LO_data_out),
    .BusMuxInC(C_sign_extended),
    .BusMuxInInPort(InPort_data_out),
	 
	 
	 
	 .R0out(Rout_internal[0]),
    .R1out(Rout_internal[1]),
    .R2out(Rout_internal[2]),
    .R3out(Rout_internal[3]),
    .R4out(Rout_internal[4]),
    .R5out(Rout_internal[5]),
    .R6out(Rout_internal[6]),
    .R7out(Rout_internal[7]),
    .R8out(Rout_internal[8]),
    .R9out(Rout_internal[9]),
    .R10out(Rout_internal[10]),
    .R11out(Rout_internal[11]),
    .R12out(Rout_internal[12]),
    .R13out(Rout_internal[13]),
    .R14out(Rout_internal[14]),
    .R15out(Rout_internal[15]),
	 

	 .PCout(PCout),
    .MDRout(MDRout),
	 .IRout(IRout),
    .HIout(HIout),
    .LOout(LOout),
    .Yout (Yout),
    .Cout(select_encode_enable & Cout),
    .InPortout(InPortout),
	 
	 
	 .Zlowout(Zlowout),
	 .Zhighout(Zhighout),

	 
    // Output
	 
    .BusMuxOut(BusMuxOut)
);


conff conff_inst (
    .BusMuxOut(BusMuxOut),
    .IR_C2(IR_data_out[20:19]),
    .CONin(CONin),
    .clk(clock),
    .clear(clear),
    .CONout(CONout)
);

endmodule
