import riscv_definitions::*;

/**
 * Module: alu
 * Description:
 *     Implements the Arithmetic Logic Unit (ALU) operations for a RISC-V core.
 *     The ALU supports arithmetic, logical, shift, and comparison operations
 *     based on the `aluOpType` input.
 *
 * Inputs:
 *     SrcA     - First operand (source A).
 *     SrcB     - Second operand (source B).
 *     Operation - ALU operation selector (based on `aluOpType` enum).
 *
 * Output:
 *     ALUResult - Result of the selected ALU operation.
 */
module alu (
    input  dataBus_t   SrcA,
    input  dataBus_t   SrcB,
    input  aluOpType   Operation,
    output dataBus_t   ALUResult
);

    always_comb begin
        ALUResult = 0;
        case (Operation)
            // Arithmetic operations
            ALU_ADD   : ALUResult = $signed(SrcA) + $signed(SrcB);              // Signed addition
            ALU_SUB   : ALUResult = $signed(SrcA) - $signed(SrcB);              // Signed subtraction

            // Logical operations
            ALU_XOR   : ALUResult = SrcA ^ SrcB;                                // Bitwise XOR
            ALU_OR    : ALUResult = SrcA | SrcB;                                // Bitwise OR
            ALU_AND   : ALUResult = SrcA & SrcB;                                // Bitwise AND

            // Shift operations
            ALU_SLL   : ALUResult = SrcA << SrcB[4:0];                          // Logical left shift
            ALU_SRL   : ALUResult = SrcA >> SrcB[4:0];                          // Logical right shift
            ALU_SRA   : ALUResult = $signed(SrcA) >>> SrcB[4:0];                // Arithmetic right shift

            // Comparison operations
            ALU_EQUAL : ALUResult = (SrcA == SrcB) ? 1 : 0;                     // Equality comparison
            ALU_NEQUAL: ALUResult = (SrcA != SrcB) ? 1 : 0;                     // Inequality comparison
            ALU_LT    : ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;    // Signed less-than
            ALU_GT    : ALUResult = ($signed(SrcA) >= $signed(SrcB)) ? 1 : 0;   // Signed greater-or-equal
            ALU_LTU   : ALUResult = (SrcA < SrcB) ? 1 : 0;                      // Unsigned less-than
            ALU_GTU   : ALUResult = (SrcA >= SrcB) ? 1 : 0;                     // Unsigned greater-or-equal

            // Bypass operation
            ALU_BPS2  : ALUResult = SrcB;                                       // Bypass source operand B directly
        endcase
    end

endmodule