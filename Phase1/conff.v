// CON FF: latches the branch condition result on posedge clk when CONin is asserted.
// IR_C2 = IR[20:19], the C2 condition field from the branch instruction.
module conff(
    input [31:0] BusMuxOut,  // Ra value on the bus \
    input [1:0]  IR_C2,      // branch condition 
    input        CONin,     
    input        clk,
    input        clear,
    output reg   CONout      // 1 = branch taken, held until next CONin
);

    always @(posedge clk, posedge clear) begin
        if (clear)
            CONout <= 0;
        else if (CONin) begin
            CONout <= 0; // default: condition not met
            case (IR_C2)
                2'b00: if (BusMuxOut == 0)        CONout <= 1; // brzr: branch if zero
                2'b01: if (BusMuxOut != 0)        CONout <= 1; // brnz: branch if nonzero
                2'b10: if (BusMuxOut[31] == 0)    CONout <= 1; // brpl: branch if positive
                2'b11: if (BusMuxOut[31] == 1)    CONout <= 1; // brmi: branch if negative
            endcase
        end
    end

endmodule