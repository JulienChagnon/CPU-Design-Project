module ram_512x32 (
    input clk,
    input read,
    input write,
    input [8:0] address,        // 9 bits for 512 addresses
    input [31:0] data_in,       // data to be written to RAM
    output reg [31:0] data_out  // data read from RAM
);

    reg [31:0] memory [0:511];      // 512 words of 32 bits each

    always @(posedge clk) begin     // synchronous read/write
        if (write)
            memory[address] <= data_in;     // write data to RAM

        if (read)
            data_out <= memory[address];    // read data from RAM
    end

endmodule
