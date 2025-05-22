import riscv_definitions::*; // Import RISC-V parameter definitions

/**
 * Module: register_file
 *
 * A 32-register bank for a RISC-V processor (x0 to x31).
 * - Register x0 (index 0) is hardwired to zero.
 * - Supports 2 asynchronous reads and 1 synchronous write.
 */
module controller (
    input  opcodeType             i_opcode,                // function op code
    input logic[3:0]              i_funct3
    input logic[6:0]              i_funct7
    output aluOpType              o_alu_control,               // Read data from source 1
    output logic                  o_reg_write             // Read data from source 2
    output aluSrc1_e              o_alu_src1             
    output aluSrc2_e              o_alu_src2             
    output logic                  o_mem_write             // Read data from source 2
    output logic                  o_mem_read             // Read data from source 2
    output logic                  o_mem_to_reg             // Read data from source 2
    output logic                  o_branch            // Read data from source 2
    output logic                  o_jump             // Read data from source 2
    output imm_src_t              o_imm_src            // Read data from source 2
    output logic[1:0]             o_result_src             // Read data from source 2
    
);


endmodule


always_comb begin: proc_decode
    o_alu_control = '0;
    o_reg_write  = '0;
    o_alu_src1  = RS1;
    o_alu_src2  = RS2;
    o_mem_write  = '0;
    o_mem_read  = '0;
    o_mem_to_reg  = '0;
    o_branch = '0;
    o_jump  = '0;
    o_imm_src = IMM_I;
    o_result_src  = '0;

    case  (i_opcode) 
		LUI: begin
			o_alu_control = ALU_BPS2;
			o_alu_src2 = IMM;
			o_reg_write = '1;
            o_imm_src = IMM_U;
		end
        AUIPC: begin
			o_alu_control = ALU_ADD;
			o_alu_src1 = PC;
			o_alu_src2 = IMM;
			o_reg_write = '1;
            o_imm_src = IMM_U;
		end
		JAL: begin
			o_jump = '1;
			o_reg_write = '1;
            o_imm_src = IMM_J;
            o_result_src  = '1;
		end
		JALR: begin
			o_jump = '1;
			o_reg_write = '1;
			o_alu_src1 = RS1;
			o_alu_control = ALU_ADD;
			o_alu_src1 = IMM;
            o_imm_src = IMM_I;
            o_result_src  = '1;
		end
		BRCH_C:begin
			o_branch = '1;
            o_alu_src1 = RS1;
            o_alu_src2 = RS2;
            o_imm_src = IMM_B;
		end
		LOAD_C: begin
			o_alu_control = ALU_ADD;
			o_alu_src1 = RS1;
			o_alu_src2 = IMM;
			o_mem_read = '1;
            o_reg_write = '1;
            o_mem_to_reg = '1;
            o_imm_src = IMM_I;
            o_result_src  = 2'b10;
		end
        STORE_C: begin
			o_alu_control = ALU_ADD; 
			o_alu_src1 = RS1;
			o_alu_src2 = IMM;
            o_mem_write = '1;
            o_imm_src = IMM_S;
		end 
        ALUI_S: begin
            o_alu_control = aluOpType_e'({1'b0, i_funct3});
			if (i_funct3 == 3'b0 && i_funct7 == 6'b100000) begin
				o_alu_control = ALU_SUB;
			end
			if (i_funct3 == 3'b101 && i_funct7 == 6'b100000) begin
				o_alu_control = ALU_SRA;
			end
			o_alu_src1 = RS1;
			o_alu_src2 = IMM;
			o_reg_write = '1;
            o_imm_src = IMM_I;
		end
        ALU_C: begin
			 o_alu_control = aluOpType_e'({1'b0, i_funct3});
			if (i_funct3 == 3'b0 && i_funct7 == 6'b100000) begin
				o_alu_control = ALU_SUB;
			end
			if (i_funct3 == 3'b101 && i_funct7 == 6'b100000) begin
				o_alu_control = ALU_SRA;
			end
			o_alu_src1 = RS1; 
			o_alu_src2 = RS2; 
			o_reg_write = '1;
		end
		endcase
	end: proc_decode