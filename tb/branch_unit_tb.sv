`timescale 1ns / 1ps

module branch_unit_tb;

    // Inputs
    logic [31:0] current_PC;
    logic [31:0] imm;
    logic        jump;
    logic        branch;
    logic [31:0] aluResult;

    // Outputs
    logic [31:0] PC_plus_4;
    logic [31:0] jump_addr;
    logic        flush;

    // Instantiate the Unit Under Test (UUT)
    branch_unit uut (
        .current_PC(current_PC),
        .imm(imm),
        .jump(jump),
        .branch(branch),
        .aluResult(aluResult),
        .PC_plus_4(PC_plus_4),
        .jump_addr(jump_addr),
        .flush(flush)
    );

    // Task to display current test case result
    task print_result(string desc);
        $display("---- %s ----", desc);
        $display("current_PC = 0x%08h, imm = 0x%08h, aluResult = 0x%08h", current_PC, imm, aluResult);
        $display("jump = %0b, branch = %0b", jump, branch);
        $display("-> PC_plus_4 = 0x%08h", PC_plus_4);
        $display("-> jump_addr = 0x%08h", jump_addr);
        $display("-> flush = %0b\n", flush);
    endtask

    initial begin
        // Test Case 1: Jump only
        current_PC = 32'h00000010;
        imm        = 32'h00000016;
        aluResult  = 32'h00000100; // jump target
        jump       = 1;
        branch     = 0;
        #1 print_result("Test 1: Jump only");

        // Test Case 2: Branch taken (aluResult[0] = 1)
        jump       = 0;
        branch     = 1;
        aluResult  = 32'h00000001; // LSB = 1, condition true
        #1 print_result("Test 2: Branch taken");

        // Test Case 3: Branch not taken (aluResult[0] = 0)
        aluResult  = 32'h00000000;
        #1 print_result("Test 3: Branch not taken");

        // Test Case 4: Neither jump nor branch
        branch     = 0;
        #1 print_result("Test 4: No jump or branch");

        $finish;
    end

endmodule
