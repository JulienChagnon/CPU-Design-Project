module ram_512x32 (
    input clk,
    input read,
    input write,
    input [8:0] address,        // 9 bits adresses
    input [31:0] data_in,       // write RAM
    output reg [31:0] data_out  // read RAM
);

    reg [31:0] memory [0:511];      //512 words of 32 bits each
    integer i;

    //phase 4 sample program starting at mem location 0x0
    initial begin
        for (i = 0; i < 512; i = i + 1)
            memory[i] = 32'b0;

        memory[9'h000] = 32'h8A800043; // ldi  R5, 0x43
        memory[9'h001] = 32'h8AA80006; // ldi  R5, 6(R5)
        memory[9'h002] = 32'h82000089; // ld   R4, 0x89
        memory[9'h003] = 32'h8A200004; // ldi  R4, 4(R4)
        memory[9'h004] = 32'h8027FFF8; // ld   R0, -8(R4)
        memory[9'h005] = 32'h89000004; // ldi  R2, 4
        memory[9'h006] = 32'h8A800087; // ldi  R5, 0x87
        memory[9'h007] = 32'hAA980003; // brmi R5, 3
        memory[9'h008] = 32'h8AA80005; // ldi  R5, 5(R5)
        memory[9'h009] = 32'h80AFFFFD; // ld   R1, -3(R5)
        memory[9'h00A] = 32'hD0000000; // nop
        memory[9'h00B] = 32'hA8900002; // brpl R1, 2
        memory[9'h00C] = 32'h89A80007; // ldi  R3, 7(R5)
        memory[9'h00D] = 32'h8B9FFFFC; // ldi  R7, -4(R3)
        memory[9'h00E] = 32'h03A90000; // add  R7, R5, R2
        memory[9'h00F] = 32'h48880003; // addi R1, R1, 3
        memory[9'h010] = 32'h70880000; // neg  R1, R1
        memory[9'h011] = 32'h78880000; // not  R1, R1
        memory[9'h012] = 32'h5088000F; // andi R1, R1, 0xF
        memory[9'h013] = 32'h3A010000; // ror  R4, R0, R2
        memory[9'h014] = 32'h58A00005; // ori  R1, R4, 5
        memory[9'h015] = 32'h2A090000; // shra R4, R1, R2
        memory[9'h016] = 32'h22A90000; // shr  R5, R5, R2
        memory[9'h017] = 32'h928000A3; // st   0xA3, R5
        memory[9'h018] = 32'h42810000; // rol  R5, R0, R2
        memory[9'h019] = 32'h1B900000; // or   R7, R2, R0
        memory[9'h01A] = 32'h12280000; // and  R4, R5, R0
        memory[9'h01B] = 32'h93A00089; // st   0x89(R4), R7
        memory[9'h01C] = 32'h082B8000; // sub  R0, R5, R7
        memory[9'h01D] = 32'h32290000; // shl  R4, R5, R2
        memory[9'h01E] = 32'h8B800007; // ldi  R7, 7
        memory[9'h01F] = 32'h89800019; // ldi  R3, 0x19
        memory[9'h020] = 32'h69B80000; // mul  R3, R7
        memory[9'h021] = 32'hC0800000; // mfhi R1
        memory[9'h022] = 32'hCB000000; // mflo R6
        memory[9'h023] = 32'h61B80000; // div  R3, R7
        memory[9'h024] = 32'h8C380002; // ldi  R8, 2(R7)
        memory[9'h025] = 32'h8C9FFFFC; // ldi  R9, -4(R3)
        memory[9'h026] = 32'h8D300003; // ldi  R10, 3(R6)
        memory[9'h027] = 32'h8D880005; // ldi  R11, 5(R1)
        memory[9'h028] = 32'h9D000000; // jal  R10
        memory[9'h029] = 32'hB3000000; // in   R6
        memory[9'h02A] = 32'h93000077; // st   0x77, R6
        memory[9'h02B] = 32'h8980002E; // ldi  R3, 0x2E
        memory[9'h02C] = 32'h8A800001; // ldi  R5, 1
        memory[9'h02D] = 32'h89000028; // ldi  R2, 40
        memory[9'h02E] = 32'hBB000000; // out  R6
        memory[9'h02F] = 32'h8917FFFF; // ldi  R2, -1(R2)
        memory[9'h030] = 32'hA9000008; // brzr R2, 8
        memory[9'h031] = 32'h83800088; // ld   R7, 0x88
        memory[9'h032] = 32'h8BBFFFFF; // ldi  R7, -1(R7)
        memory[9'h033] = 32'hD0000000; // nop
        memory[9'h034] = 32'hAB8FFFFD; // brnz R7, -3
        memory[9'h035] = 32'h23328000; // shr  R6, R6, R5
        memory[9'h036] = 32'hAB0FFFF7; // brnz R6, -9
        memory[9'h037] = 32'h83000077; // ld   R6, 0x77
        memory[9'h038] = 32'hA1800000; // jr   R3
        memory[9'h039] = 32'h8B000063; // ldi  R6, 0x63
        memory[9'h03A] = 32'hBB000000; // out  R6
        memory[9'h03B] = 32'hD8000000; // halt
			
		  //Initialize memory locations 0x88, 0x89, and 0xA3
        memory[9'h089] = 32'h000000A7;
        memory[9'h0A3] = 32'h00000068;
        memory[9'h088] = 32'h0000FFFF;

        memory[9'h0B2] = 32'h07450000; // add  R14, R8, R10
        memory[9'h0B3] = 32'h0ECD8000; // sub  R13, R9, R11
        memory[9'h0B4] = 32'h0F768000; // sub  R14, R14, R13
        memory[9'h0B5] = 32'hA6000000; // jr   R12
    end

    always @(posedge clk) begin     
        if (write)
            memory[address] <= data_in;//write to RAM

        if (read)
            data_out <= memory[address];//read from RAM
    end

endmodule
