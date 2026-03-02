module MAR (
    input clk,
    input clear,
    input MARin,                // enable signal
    input [31:0] bus_mux_out,   // data from bus
    output reg [8:0] address    // to RAM
);

    reg [31:0] MAR_reg;             // internal register to hold the value of MAR

    always @(posedge clk) begin 
        if (clear)                  // on clear set MAR to all zeros
            MAR_reg <= 32'b0;   
        else if (MARin)             //when MAR_in is enabled
            MAR_reg <= bus_mux_out; //load the value from the bus into MAR
    end

    // Only lower 9 bits go to RAM because RAM has 512 (2^9) addresses
    assign address = MAR_reg[8:0];

endmodule
