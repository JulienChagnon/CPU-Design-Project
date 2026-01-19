module Bus (
    input  [7:0] BusMuxInRZ,
    input  [7:0] BusMuxInRA,
    input  [7:0] BusMuxInRB,
    input  RZout,
    input  RAout,
    input  RBout,
    output wire [7:0] BusMuxOut
);

    reg [7:0] q;

    always @(*) begin
        if (RZout) q = BusMuxInRZ;
        if (RAout) q = BusMuxInRA;
        if (RBout) q = BusMuxInRB;
    end

    assign BusMuxOut = q;

endmodule
