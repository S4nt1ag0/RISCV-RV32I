import riscv_definitions::*; // Import RISC-V parameter and type definitions

/**
 * Module: controller
 *
 * The controller decodes instruction fields to generate control signals
 * for the datapath components in a RISC-V processor.
 *
 * Inputs:
 * - i_opcode : Main opcode of the instruction
 * - i_funct3 : Function field (3 bits) for instruction subtype
 * - i_funct7 : Function field (7 bits) for instruction subtype
 *
 * Outputs:
 * - o_alu_control : ALU operation to perform
 * - o_reg_write   : Enable register write-back
 * - o_alu_src1    : Select source 1 for ALU (e.g., PC or rs1)
 * - o_alu_src2    : Select source 2 for ALU (e.g., immediate or rs2)
 * - o_mem_write   : Enable memory write
 * - o_mem_read    : Enable memory read
 * - o_mem_to_reg  : Select memory output as register write-back value
 * - o_branch      : Branch instruction flag
 * - o_jump        : Jump instruction flag
 * - o_imm_src     : Immediate type (I, S, B, U, J)
 * - o_result_src  : Select final result source
 */
module controller (
    input  opcodeType             i_opcode,
    input  logic [2:0]            i_funct3,
    input  logic [6:0]            i_funct7,

    output aluOpType              o_alu_control,
    output logic                  o_reg_write,
    output aluSrc1_e              o_alu_src1,
    output aluSrc2_e              o_alu_src2,
    output logic                  o_mem_write,
    output logic                  o_mem_read,
    output logic                  o_mem_to_reg,
    output logic                  o_branch,
    output logic                  o_jump,
    output imm_src_t              o_imm_src,
    output logic [1:0]            o_result_src
);

always_comb begin : proc_decode
    // Default control signal values
    o_alu_control = ALU_ADD;
    o_reg_write   = 1'b0;
    o_alu_src1    = RS1;
    o_alu_src2    = RS2;
    o_mem_write   = 1'b0;
    o_mem_read    = 1'b0;
    o_mem_to_reg  = 1'b0;
    o_branch      = 1'b0;
    o_jump        = 1'b0;
    o_imm_src     = IMM_I;
    o_result_src  = 2'b00;

    case (i_opcode)
        LUI: begin
            o_alu_control = ALU_BPS2;
            o_alu_src2    = IMM;
            o_reg_write   = 1'b1;
            o_imm_src     = IMM_U;
        end
        AUIPC: begin
            o_alu_control = ALU_ADD;
            o_alu_src1    = PC;
            o_alu_src2    = IMM;
            o_reg_write   = 1'b1;
            o_imm_src     = IMM_U;
        end
        JAL: begin
            o_jump        = 1'b1;
            o_reg_write   = 1'b1;
            o_imm_src     = IMM_J;
            o_result_src  = 2'b01;
        end
        JALR: begin
            o_jump        = 1'b1;
            o_reg_write   = 1'b1;
            o_alu_src1    = RS1;
            o_alu_src2    = IMM;
            o_alu_control = ALU_ADD;
            o_imm_src     = IMM_I;
            o_result_src  = 2'b01;
        end
        BRCH_S: begin
            o_branch      = 1'b1;
            o_alu_src1    = RS1;
            o_alu_src2    = RS2;
            o_imm_src     = IMM_B;
            o_alu_control = ALU_EQUAL; // Default comparison: equal

            case (i_funct3)
                3'b001: o_alu_control = ALU_NEQUAL; // Not equal
                3'b100: o_alu_control = ALU_LT;     // Signed less than
                3'b101: o_alu_control = ALU_GT;     // Signed greater than or equal
                3'b110: o_alu_control = ALU_LTU;    // Unsigned less than
                3'b111: o_alu_control = ALU_GTU;    // Unsigned greater than or equal
            endcase
        end
        LOAD_S: begin
            o_alu_control = ALU_ADD;
            o_alu_src1    = RS1;
            o_alu_src2    = IMM;
            o_mem_read    = 1'b1;
            o_reg_write   = 1'b1;
            o_mem_to_reg  = 1'b1;
            o_imm_src     = IMM_I;
            o_result_src  = 2'b10;
        end
        STORE_S: begin
            o_alu_control = ALU_ADD;
            o_alu_src1    = RS1;
            o_alu_src2    = IMM;
            o_mem_write   = 1'b1;
            o_imm_src     = IMM_S;
        end
        ALUI_S: begin
            o_alu_src1    = RS1;
            o_alu_src2    = IMM;
            o_reg_write   = 1'b1;
            o_imm_src     = IMM_I;
            if(i_funct3 == 3'b001 || i_funct3 == 3'b101 )
                o_imm_src     = IMM_IS;
            else if (i_funct3 == 3'b101 && i_funct7[5])
                o_alu_control = ALU_SRA;
            else
                o_alu_control = aluOpType'({1'b0, i_funct3});
        end
        ALU_S: begin
            if (i_funct3 == 3'b000 && i_funct7[5])
                o_alu_control = ALU_SUB;
            else if (i_funct3 == 3'b101 && i_funct7[5])
                o_alu_control = ALU_SRA;
            else
                o_alu_control = aluOpType'({1'b0, i_funct3});

            o_alu_src1    = RS1;
            o_alu_src2    = RS2;
            o_reg_write   = 1'b1;
        end
    endcase
end : proc_decode

endmodule
