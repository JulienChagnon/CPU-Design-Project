module ram_512x32 (
    input clk,
    input read,
    input write,
    input [8:0] address,        // 9 bits for 512 addresses
    input [31:0] data_in,       // data to be written to RAM
    output reg [31:0] data_out  // data read from RAM
);

    reg [31:0] memory [0:511];      // 512 words of 32 bits each
    integer i;

    // Shared Phase 2 data preloads. These entries are used by multiple tests.
    initial begin
        for (i = 0; i < 512; i = i + 1)
            memory[i] = 32'b0;
        memory[0] = 32'h000000FF;   // value for R12
        memory[1] = 32'h00000080;   // value for R4
        memory[2] = 32'h00000010;   // value for PC

        memory[9'h065] = 32'h00000084; // ld R7, 0x65
        memory[9'h0C9] = 32'h0000002B; // ld R0, 0x72(R2)
        memory[9'h01F] = 32'h000000D4; // st Case1
        memory[9'h082] = 32'h000000A7; // st Case2
    end

    always @(posedge clk) begin     // synchronous read/write
        if (write)
            memory[address] <= data_in;     // write data to RAM

        if (read)
            data_out <= memory[address];    // read data from RAM
    end

endmodule
