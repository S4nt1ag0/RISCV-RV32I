`timescale 1ns/1ps
import riscv_definitions::*;

/**
 * Module: alu_tb
 * Description:
 *     Testbench for the ALU module. Verifies functionality for all supported
 *     ALU operations using a predefined set of test vectors.
 */
module alu_tb;

    // Testbench signals
    logic [31:0] SrcA, SrcB;
    aluOpType    Operation;
    logic [31:0] ALUResult;

    // Instantiate the ALU
    alu dut (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Operation(Operation),
        .ALUResult(ALUResult)
    );

    // Task to display results
    task automatic check_result(string op_name, logic [31:0] expected);
        if (ALUResult !== expected) begin
            $display("FAILED: %s | SrcA = %0d, SrcB = %0d, Got = %0d, Expected = %0d", 
                     op_name, SrcA, SrcB, ALUResult, expected);
        end else begin
            $display("PASSED: %s | Result = %0d", op_name, ALUResult);
        end
    endtask

    initial begin
        $display("Starting ALU testbench...\n");

        // Test ALU_ADD
        SrcA = 10; SrcB = 15; Operation = ALU_ADD;
        #1 check_result("ADD", 25);

        // Test ALU_SUB
        SrcA = 20; SrcB = 5; Operation = ALU_SUB;
        #1 check_result("SUB", 15);

        // Test ALU_SLL
        SrcA = 4; SrcB = 1; Operation = ALU_SLL;
        #1 check_result("SLL", 8);

        // Test ALU_SRL
        SrcA = 16; SrcB = 2; Operation = ALU_SRL;
        #1 check_result("SRL", 4);

        // Test ALU_SRA
        SrcA = -32; SrcB = 2; Operation = ALU_SRA;
        #1 check_result("SRA", -8);

        // Test ALU_XOR
        SrcA = 8'hAA; SrcB = 8'h0F; Operation = ALU_XOR;
        #1 check_result("XOR", 8'hA5);

        // Test ALU_OR
        SrcA = 8'hA0; SrcB = 8'h0F; Operation = ALU_OR;
        #1 check_result("OR", 8'hAF);

        // Test ALU_AND
        SrcA = 8'hA5; SrcB = 8'h0F; Operation = ALU_AND;
        #1 check_result("AND", 8'h05);

        // Test ALU_EQUAL
        SrcA = 100; SrcB = 100; Operation = ALU_EQUAL;
        #1 check_result("EQUAL", 1);

        // Test ALU_NEQUAL
        SrcA = 100; SrcB = 99; Operation = ALU_NEQUAL;
        #1 check_result("NEQUAL", 1);

        // Test ALU_LT (signed)
        SrcA = -5; SrcB = 3; Operation = ALU_LT;
        #1 check_result("LT", 1);

        // Test ALU_GT (signed)
        SrcA = 3; SrcB = -5; Operation = ALU_GT;
        #1 check_result("GT", 1);

        // Test ALU_LTU (unsigned)
        SrcA = 32'h00000001; SrcB = 32'hFFFFFFFF; Operation = ALU_LTU;
        #1 check_result("LTU", 1);

        // Test ALU_GTU (unsigned)
        SrcA = 32'hFFFFFFFF; SrcB = 32'h00000001; Operation = ALU_GTU;
        #1 check_result("GTU", 1);

        // Test ALU_BPS2
        SrcA = 1234; SrcB = 5678; Operation = ALU_BPS2;
        #1 check_result("BPS2", 5678);

        $display("\nALU testbench completed.");
        $finish;
    end

endmodule