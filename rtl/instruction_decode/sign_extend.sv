import riscv_definitions::*; // Import RISC-V parameter definitions


module sign_extend (
    input  logic [31:7] i_instr,        // Campo de bits de imediato (parcial da instrução)
    input  imm_src_t  i_imm_src,        // Tipo de imediato
    output logic [31:0] o_imm_out       // Imediato estendido com sinal
);

    always_comb begin
        o_imm_out = 32'b0; // Valor padrão, evita latch

        case (i_imm_src)
            // I-type (ex: LW, ADDI, ANDI, etc.)
            IMM_I: o_imm_out = {{20{i_instr[31]}}, i_instr[31:20]};
            
            IMM_IS: o_imm_out = {{27{i_instr[31]}}, i_instr[24:20]};
            // S-type (ex: SW, SH, SB)
            IMM_S: o_imm_out = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

            // B-type (ex: BEQ, BNE, etc.) com LSB 0 (instruções alinhadas)
            IMM_B: o_imm_out = {{20{i_instr[31]}}, i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};

            //U-type (ex: LUI AUIPC)
            IMM_U: o_imm_out = {{20{i_instr[31]}}, i_instr[31:12]};

            // J-type (ex: JAL), com LSB 0
            IMM_J: o_imm_out = {{12{i_instr[31]}}, i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
        endcase
    end

endmodule