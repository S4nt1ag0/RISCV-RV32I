import riscv_definitions::*;

/**
 * Module: branch_unit
 * Description:
 *     Determines the next PC (Program Counter) address based on jump and branch conditions.
 *     It computes whether a branch should be taken and the jump address accordingly.
 *
 * Inputs:
 *     current_PC - Current value of the program counter.
 *     imm        - Immediate offset used for branching.
 *     jump       - Jump control signal (e.g., JAL or JALR).
 *     branch     - Branch control signal (e.g., BEQ, BNE, etc.).
 *     aluResult  - ALU result used to determine branch condition (e.g., comparison result).
 *
 * Outputs:
 *     PC_plus_4  - The PC value incremented by 4 (default next instruction).
 *     jump_addr  - The next PC if branch or jump is taken.
 *     flush      - Control signal to flush the pipeline (if jump or branch is taken).
 */
module branch_unit (
    input  dataBus_t current_PC,
    input  dataBus_t imm,
    input  logic     jump,
    input  logic     branch,
    input  dataBus_t aluResult,

    output dataBus_t PC_plus_4,
    output dataBus_t jump_addr,
    output logic     flush
);
    dataBus_t    PC_imm;
    logic        branch_sel;

    // Compute PC + immediate (branch target address)
    assign PC_imm     = current_PC + imm;

    // Default PC increment (next sequential instruction)
    assign PC_plus_4  = current_PC + 32'd4;

    // Determine if branch condition is satisfied
    assign branch_sel = branch && aluResult[0]; // ALUResult[0] = true/false from comparison

    // Compute next PC (jump or branch target)
    assign jump_addr  = (branch_sel || jump) ? PC_imm : aluResult;

    // Flush pipeline if jump or branch is taken
    assign flush      = jump || branch_sel;

endmodule
