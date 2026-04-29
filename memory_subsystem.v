module memory_subsystem (
    input clk,
    input clear,

    // Control signals
    input MARin,
    input MDRin,
    input MDRout,
    input Read,
    input Write,

    // CPU Bus input
    input [31:0] BusMuxOut,

    output [31:0] Mdatain,

    // Bus output from MDR
    output [31:0] BusMuxIn_MDR
);

    // Internal wires
    wire [8:0] address;
    wire [31:0] ram_out;

    wire [31:0] data_to_RAM;
    wire [31:0] mdmux_out;

    // MAR Instance
    MAR mar_inst (
        .clk(clk),
        .clear(clear),
        .MARin(MARin),
        .bus_mux_out(BusMuxOut),
        .address(address)
    );

    // MDMux logic selects between RAM output and BusMuxOut based on Read signal
    assign mdmux_out = Read ? Mdatain : BusMuxOut;

    // MDR Instance
    MDR mdr_inst (
        .clk(clk),
        .clear(clear),
        .MDRin(MDRin),
        .MDRout(MDRout),
        .bus_mux_out(BusMuxOut),
        .Mdatain(Mdatain),
        .Read(Read),
        .BusMuxIn_MDR(BusMuxIn_MDR),
        .data_to_RAM(data_to_RAM)
    );

    // RAM Instance
    ram_512x32 ram_inst (
        .clk(clk),
        .read(Read),
        .write(Write),
        .address(address),
        .data_in(data_to_RAM),
        .data_out(Mdatain)
    );
    
endmodule
