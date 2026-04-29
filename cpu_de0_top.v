`timescale 1ns/10ps

module cpu_de0_top (
    input  wire        CLOCK_50,
    input  wire [3:0]  KEY,
    input  wire [9:0]  SW,
    output wire [9:0]  LEDR,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1
);

    wire        reset;
    wire        stop;
    wire        cpu_clock;
    wire [31:0] in_port_data;
    wire [31:0] out_port_data;
    wire        run;

    assign reset = ~KEY[0];               // KEY0 active-low
    assign stop  = ~KEY[1];               // KEY1 active-low
    assign in_port_data = {24'b0, SW[7:0]};

    // Divide 50 MHz board clock for more observable board behavior.
    // Fcpu = 50 MHz / (2 * DIVIDE_BY) = 1 MHz when DIVIDE_BY = 25.
    clock_divider #(
        .DIVIDE_BY(25)
    ) clkdiv_u (
        .clk_in(CLOCK_50),
        // Keep divided clock running during reset so synchronous clears
        // in the datapath can actually sample reset on a clock edge.
        .reset(1'b0),
        .clk_out(cpu_clock)
    );

    cpu cpu_u (
        .clock(cpu_clock),
        .reset(reset),
        .stop(stop),
        .InPortData(in_port_data),
        .InPortStrobe(1'b1),              // continuously capture switches
        .OutPortData(out_port_data),
        .Run(run),
        .CONout(),
        .IR_value(),
        .state_dbg()
    );

    // Drive LEDR with a single assignment to avoid multiple-driver conflicts.
    assign LEDR = {4'b0, run, 5'b0};      // LEDR[5] = Run.Out indicator

    // Display Out.Port[7:0] on HEX1 HEX0
    hex_to_7seg h0 (.nibble(out_port_data[3:0]), .seg(HEX0));
    hex_to_7seg h1 (.nibble(out_port_data[7:4]), .seg(HEX1));

endmodule

module clock_divider #(
    parameter integer DIVIDE_BY = 25
) (
    input  wire clk_in,
    input  wire reset,
    output reg  clk_out
);
    integer count;

    initial begin
        count = 0;
        clk_out = 1'b0;
    end

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            count <= 0;
            clk_out <= 1'b0;
        end
        else if (count == (DIVIDE_BY - 1)) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
        else begin
            count <= count + 1;
        end
    end
endmodule

module hex_to_7seg (
    input  wire [3:0] nibble,
    output reg  [6:0] seg
);
    always @(*) begin
        case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
