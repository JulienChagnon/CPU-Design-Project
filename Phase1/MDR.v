module MDR (
    input clk,
    input clear,
    input MDRin,                // load enable
    input MDRout,               // drive bus enable
    input [31:0] bus_mux_out,   //data from CPU bus
    input [31:0] Mdatain,       //data from RAM
    input Read,                 //selects RAM input
    output [31:0] BusMuxIn_MDR, //to Bus
    output [31:0] data_to_RAM   //to RAM
);

    reg [31:0] MDR_reg;

    // Load logic
    always @(posedge clk) begin
        if (clear)
            MDR_reg <= 32'b0;
        else if (MDRin) begin
            if (Read)
                MDR_reg <= Mdatain;      // load from RAM
            else
                MDR_reg <= bus_mux_out;  // load from bus
        end
    end

    // drive bus only when MDRout = 1 otherwise drive 0
    assign BusMuxIn_MDR = MDRout ? MDR_reg : 32'b0;

    //data going to RAM for write
    assign data_to_RAM = MDR_reg;

endmodule
