import riscv_definitions::*; // Import package into $unit space
/**
 * Module: execution
 * Description:
 *     Implements the execution stage of a RISC-V pipeline. This stage handles ALU operations,
 *     jump and branch decision logic, and forwards data and control signals to the memory stage.
 *
 **/
module execution (
    input  logic                 clk,                   // Clock signal
    input  logic                 clk_en,                // Clock Enable
    input  logic                 rst_n,                 // Asynchronous reset (active low)

    input logic                  i_id_mem_to_reg,       // Select memory input as register write-back value
    input logic                  i_id_alu_src1,         // Selects source A for the ALU (0: RS1, 1: PC).
    input logic                  i_id_alu_src2,         // Selects source B for the ALU (0: RS2, 1: IMM).
    input logic                  i_id_reg_wr,           // Register write enable
    input logic                  i_id_mem_rd,           // Memory read enable
    input logic                  i_id_mem_wr,           // Memory write enable
    input logic                  i_id_result_src,       // Write-back result selector (PC+4, ALU result, or memory).
    input logic                  i_id_branch,           // Branch instruction flag
    input aluOpType              i_id_alu_op,           // ALU operation control
    input logic                  i_id_jump,             // Jump instruction flag
    input dataBus_t              i_id_pc,               // Program Counter value at ID stage
    input dataBus_t              i_id_reg_read_data1,   // RS1 value input
    input dataBus_t              i_id_reg_read_data2,   // RS2 value input
    input dataBus_t              i_id_imm,              // Sign-extended immediate value
    input logic [REG_ADDR-1:0]   i_id_reg_destination,  // Register destination address
    input logic [2:0]            i_id_funct3,           // funct3 field from instruction
    input logic [6:0]            i_id_funct7,           // funct7 field from instruction

    output logic                  o_ex_mem_to_reg,      // Forwarded control signal for memory to register path.
    output logic                  o_ex_reg_wr,          // Forwarded register write enable.
    output logic                  o_ex_mem_rd,          // Forwarded memory read enable.
    output logic                  o_ex_mem_wr,          // Forwarded memory write enable.
    output logic                  o_ex_result_src,      // Forwarded write-back result selector.
    output logic [REG_ADDR-1:0]   o_ex_reg_destination, // Forwarded Register destination address
    output logic [2:0]            o_ex_funct3,          // Forwarded funct3.
    output logic [6:0]            o_ex_funct7,          // Forwarded funct7.
    output logic                  o_ex_flush,           // Pipeline flush signal (for control transfer).
    output dataBus_t              o_ex_jump_addr,       // Computed jump or branch target address.
    output dataBus_t              o_ex_pc_plus_4,       // PC + 4 value.
    output dataBus_t              o_ex_alu_result,      // ALU result.
    output dataBus_t              o_ex_data2            // RS2 value output
    
);


   // Internal signals
    logic     flush;
    dataBus_t jump_addr;
    dataBus_t pc_plus_4;
    dataBus_t alu_result;
    dataBus_t SrcA;
    dataBus_t SrcB;

    // ALU source A mux: selects between register RS1 and PC
    mux2to1 select_SrcA (
        .in0(i_id_reg_read_data1),
        .in1(i_id_pc), 
        .sel(i_id_alu_src1),
        .out(SrcA)
    );

    // ALU source B mux: selects between register RS2 and immediate
    mux2to1 select_SrcB (
        .in0(i_id_reg_read_data2),
        .in1(i_id_imm), 
        .sel(i_id_alu_src2),
        .out(SrcB)
    );

    // ALU instance
    alu alu_instance (
        .SrcA(SrcA),
        .SrcB(SrcB),
        .Operation(i_id_alu_op),
        .ALUResult(alu_result)
    );

    // Branch Unit instance
    branch_unit branch_unit_instance (
        .current_PC(i_id_pc),
        .imm(i_id_imm),
        .jump(i_id_jump),
        .branch(i_id_branch),
        .aluResult(alu_result),
        .PC_plus_4(pc_plus_4),
        .jump_addr(jump_addr),
        .flush(flush)
    );

    assign o_ex_flush = flush;
    assign o_ex_jump_addr = jump_addr;

    // Pipeline register (EX stage outputs)
    always_ff @(posedge clk or negedge rst_n) begin : proc_id_ex
        if (!rst_n) begin
            o_ex_mem_to_reg      <= '0;
            o_ex_reg_wr          <= '0;
            o_ex_mem_rd          <= '0;
            o_ex_mem_wr          <= '0;
            o_ex_result_src      <= '0;
            o_ex_reg_destination <= '0;
            o_ex_funct3          <= '0;
            o_ex_funct7          <= '0;
            o_ex_pc_plus_4       <= '0;
            o_ex_alu_result      <= '0;
            o_ex_data2           <= '0;
        end else if (clk_en) begin
            o_ex_mem_to_reg      <= i_id_mem_to_reg;
            o_ex_reg_wr          <= i_id_reg_wr;
            o_ex_mem_rd          <= i_id_mem_rd;
            o_ex_mem_wr          <= i_id_mem_wr;
            o_ex_result_src      <= i_id_result_src;
            o_ex_reg_destination <= i_id_reg_destination;
            o_ex_funct3          <= i_id_funct3;
            o_ex_funct7          <= i_id_funct7;
            o_ex_pc_plus_4       <= pc_plus_4;
            o_ex_alu_result      <= alu_result;
            o_ex_data2           <= i_id_reg_read_data2;
        end
    end : proc_id_ex

endmodule