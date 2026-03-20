`timescale 1ns/10ps

module cpu_tb;

    reg Clock;
    reg reset;
    reg stop;
    reg [31:0] InPortData;
    reg InPortStrobe;

    wire [31:0] OutPortData;
    wire Run;
    wire CONout;
    wire [31:0] IR_value;
    wire [7:0] state_dbg;

    integer cycles;
    integer error_count;

    localparam integer MAX_CYCLES = 800;

    cpu DUT (
        .clock(Clock),
        .reset(reset),
        .stop(stop),
        .InPortData(InPortData),
        .InPortStrobe(InPortStrobe),
        .OutPortData(OutPortData),
        .Run(Run),
        .CONout(CONout),
        .IR_value(IR_value),
        .state_dbg(state_dbg)
    );

    initial begin
        Clock = 0;
        forever #10 Clock = ~Clock;
    end

    task check_value;
        input [8*32-1:0] name;
        input [31:0] actual;
        input [31:0] expected;
        begin
            if (actual !== expected) begin
                error_count = error_count + 1;
                $display("cpu_tb FAILED: %0s = %h expected %h", name, actual, expected);
            end
            else begin
                $display("cpu_tb PASSED: %0s = %h", name, actual);
            end
        end
    endtask

    initial begin
        reset = 1'b1;
        stop = 1'b0;
        InPortData = 32'b0;
        InPortStrobe = 1'b0;
        cycles = 0;
        error_count = 0;

        
        #35;
        reset = 1'b0;
    end

    initial begin
        @(negedge reset);

        while ((Run !== 1'b0) && (cycles < MAX_CYCLES)) begin
            @(posedge Clock);
            cycles = cycles + 1;
        end

        if (Run !== 1'b0) begin
            $display("cpu_tb FAILED: CPU did not halt within %0d cycles", MAX_CYCLES);
            $display("cpu_tb INFO: state=%0d IR=%h PC=%h", state_dbg, IR_value, DUT.datapath_u.PC_data_out);
            $finish;
        end

        #1;
        $display("cpu_tb INFO: CPU halted after %0d cycles", cycles);
        $display("cpu_tb INFO: halt state=%0d IR=%h PC=%h", state_dbg, IR_value, DUT.datapath_u.PC_data_out);

        check_value("R0",  DUT.datapath_u.R0_data_out,  32'h00000614);
        check_value("R1",  DUT.datapath_u.R1_data_out,  32'h00000000);
        check_value("R2",  DUT.datapath_u.R2_data_out,  32'h00000004);
        check_value("R3",  DUT.datapath_u.R3_data_out,  32'h00000019);
        check_value("R4",  DUT.datapath_u.R4_data_out,  32'h00006800);
        check_value("R5",  DUT.datapath_u.R5_data_out,  32'h00000680);
        check_value("R6",  DUT.datapath_u.R6_data_out,  32'h000000AF);
        check_value("R7",  DUT.datapath_u.R7_data_out,  32'h00000007);
        check_value("R8",  DUT.datapath_u.R8_data_out,  32'h00000009);
        check_value("R9",  DUT.datapath_u.R9_data_out,  32'h00000015);
        check_value("R10", DUT.datapath_u.R10_data_out, 32'h000000B2);
        check_value("R11", DUT.datapath_u.R11_data_out, 32'h00000005);
        check_value("R12", DUT.datapath_u.R12_data_out, 32'h00000029);
        check_value("R13", DUT.datapath_u.R13_data_out, 32'h00000010);
        check_value("R14", DUT.datapath_u.R14_data_out, 32'h000000AB);
        check_value("HI",  DUT.datapath_u.HI_data_out,  32'h00000004);
        check_value("LO",  DUT.datapath_u.LO_data_out,  32'h00000003);

        check_value("M[0x89]", DUT.datapath_u.mem_sys.ram_inst.memory[9'h089], 32'h0000006C);
        check_value("M[0xA3]", DUT.datapath_u.mem_sys.ram_inst.memory[9'h0A3], 32'h00000008);

        if (error_count == 0)
            $display("cpu_tb PASSED: full Phase 3 program completed successfully");
        else
            $display("cpu_tb FAILED: %0d mismatches detected", error_count);

        $finish;
    end

endmodule
