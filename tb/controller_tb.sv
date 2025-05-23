`timescale 1ns/1ps

module controller_tb;

    // Inputs
    opcodeType      i_opcode;
    logic [2:0]     i_funct3;
    logic [6:0]     i_funct7;

    // Outputs
    aluOpType       o_alu_control;
    logic           o_reg_write;
    aluSrc1_e       o_alu_src1;
    aluSrc2_e       o_alu_src2;
    logic           o_mem_write;
    logic           o_mem_read;
    logic           o_mem_to_reg;
    logic           o_branch;
    logic           o_jump;
    imm_src_t       o_imm_src;
    logic [1:0]     o_result_src;

    // Instantiate DUT (Device Under Test)
    controller dut (
        .i_opcode(i_opcode),
        .i_funct3(i_funct3),
        .i_funct7(i_funct7),
        .o_alu_control(o_alu_control),
        .o_reg_write(o_reg_write),
        .o_alu_src1(o_alu_src1),
        .o_alu_src2(o_alu_src2),
        .o_mem_write(o_mem_write),
        .o_mem_read(o_mem_read),
        .o_mem_to_reg(o_mem_to_reg),
        .o_branch(o_branch),
        .o_jump(o_jump),
        .o_imm_src(o_imm_src),
        .o_result_src(o_result_src)
    );

    // Task for displaying outputs
    task display_outputs;
        $display("opcode=%b funct3=%b funct7=%b => ALU=%0d REG_WR=%b MEM_RD=%b MEM_WR=%b BR=%b JMP=%b IMM=%0d RSRC=%0d",
            i_opcode, i_funct3, i_funct7,
            o_alu_control, o_reg_write,
            o_mem_read, o_mem_write, o_branch, o_jump,
            o_imm_src, o_result_src);
    endtask

    initial begin
        $display("=== Iniciando Testbench do Controller ===");

        // Teste: LUI
        i_opcode = LUI;
        i_funct3 = 3'b000;
        i_funct7 = 7'b0000000;
        #1 display_outputs();

        // Teste: AUIPC
        i_opcode = AUIPC;
        #1 display_outputs();

        // Teste: JAL
        i_opcode = JAL;
        #1 display_outputs();

        // Teste: JALR
        i_opcode = JALR;
        #1 display_outputs();

        // Teste: BEQ (Branch)
        i_opcode = BRCH_S;
        i_funct3 = 3'b000;
        #1 display_outputs();

        // Teste: LW (Load)
        i_opcode = LOAD_S;
        i_funct3 = 3'b010;
        #1 display_outputs();

        // Teste: SW (Store)
        i_opcode = STORE_S;
        i_funct3 = 3'b010;
        #1 display_outputs();

        // Teste: ADDI (ALUI_S)
        i_opcode = ALUI_S;
        i_funct3 = 3'b000;
        i_funct7 = 7'b0000000;
        #1 display_outputs();

        // Teste: SUB (ALU_S)
        i_opcode = ALU_S;
        i_funct3 = 3'b000;
        i_funct7 = 7'b0100000; // bit 5 = 1
        #1 display_outputs();

        // Teste: SRA (ALUI_S)
        i_opcode = ALUI_S;
        i_funct3 = 3'b101;
        i_funct7 = 7'b0100000;
        #1 display_outputs();

        $display("=== Testbench Finalizado ===");
        $finish;
    end

endmodule
