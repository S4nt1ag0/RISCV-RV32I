`timescale 1ns / 1ps

import riscv_definitions::*;

/**
 * Testbench: execution_tb
 * Description:
 *     Testbench for the 'execution' module of a RISC-V processor.
 *     Validates correct ALU operations, branching, and pipeline behavior.
 */
module execution_tb;

  // Clock and Reset
  logic clk;
  logic rst_n;
  logic clk_en;

  // Inputs to execution module
  logic                  i_id_mem_to_reg;
  logic                  i_id_alu_src1;
  logic                  i_id_alu_src2;
  logic                  i_id_reg_wr;
  logic                  i_id_mem_rd;
  logic                  i_id_mem_wr;
  logic                  i_id_result_src;
  logic                  i_id_branch;
  aluOpType              i_id_alu_op;
  logic                  i_id_jump;
  dataBus_t              i_id_pc;
  dataBus_t              i_id_reg_read_data1;
  dataBus_t              i_id_reg_read_data2;
  dataBus_t              i_id_imm;
  logic [REG_ADDR-1:0]   i_id_reg_destination;
  logic [2:0]            i_id_funct3;
  logic [6:0]            i_id_funct7;

  // Outputs from execution module
  logic                  o_ex_flush;
  dataBus_t              o_ex_jump_addr;
  logic                  o_ex_mem_to_reg;
  logic                  o_ex_reg_wr;
  logic                  o_ex_mem_rd;
  logic                  o_ex_mem_wr;
  logic                  o_ex_result_src;
  dataBus_t              o_ex_pc_plus_4;
  dataBus_t              o_ex_alu_result;
  dataBus_t              o_ex_data2;
  logic [REG_ADDR-1:0]   o_ex_reg_destination;
  logic [2:0]            o_ex_funct3;
  logic [6:0]            o_ex_funct7;

  // Instantiate the execution module
  execution uut (
    .clk(clk),
    .clk_en(clk_en),
    .rst_n(rst_n),
    .i_id_mem_to_reg(i_id_mem_to_reg),
    .i_id_alu_src1(i_id_alu_src1),
    .i_id_alu_src2(i_id_alu_src2),
    .i_id_reg_wr(i_id_reg_wr),
    .i_id_mem_rd(i_id_mem_rd),
    .i_id_mem_wr(i_id_mem_wr),
    .i_id_result_src(i_id_result_src),
    .i_id_branch(i_id_branch),
    .i_id_alu_op(i_id_alu_op),
    .i_id_jump(i_id_jump),
    .i_id_pc(i_id_pc),
    .i_id_reg_read_data1(i_id_reg_read_data1),
    .i_id_reg_read_data2(i_id_reg_read_data2),
    .i_id_imm(i_id_imm),
    .i_id_reg_destination(i_id_reg_destination),
    .i_id_funct3(i_id_funct3),
    .i_id_funct7(i_id_funct7),
    .o_ex_flush(o_ex_flush),
    .o_ex_jump_addr(o_ex_jump_addr),
    .o_ex_mem_to_reg(o_ex_mem_to_reg),
    .o_ex_reg_wr(o_ex_reg_wr),
    .o_ex_mem_rd(o_ex_mem_rd),
    .o_ex_mem_wr(o_ex_mem_wr),
    .o_ex_result_src(o_ex_result_src),
    .o_ex_pc_plus_4(o_ex_pc_plus_4),
    .o_ex_alu_result(o_ex_alu_result),
    .o_ex_data2(o_ex_data2),
    .o_ex_reg_destination(o_ex_reg_destination),
    .o_ex_funct3(o_ex_funct3),
    .o_ex_funct7(o_ex_funct7)
  );

  // Clock generator
  always #5 clk = ~clk;

  initial begin
    // Initialize inputs
    clk         = 0;
    clk_en      = 1;
    i_id_mem_to_reg = 0;
    i_id_alu_src1   = 0;
    i_id_alu_src2   = 0;
    i_id_reg_wr     = 0;
    i_id_mem_rd     = 0;
    i_id_mem_wr     = 0;
    i_id_result_src = 0;
    i_id_branch     = 0;
    i_id_alu_op     = ALU_ADD;
    i_id_jump       = 0;
    i_id_pc         = 32'h00000010;
    i_id_reg_read_data1 = 32'h00000005;
    i_id_reg_read_data2 = 32'h00000003;
    i_id_imm        = 32'h00000008;
    i_id_reg_destination = 5'd10;
    i_id_funct3     = 3'b000;
    i_id_funct7     = 7'b0000000;

    rst_n = 1;
    @(posedge clk);
    repeat (2) @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;

    // Test ALU operation ADD with SrcA = reg1, SrcB = reg2
    i_id_alu_src1 = 0; // reg1
    i_id_alu_src2 = 0; // reg2
    i_id_alu_op = ALU_ADD;
    @(posedge clk);

    $display("ALU ADD result: %h", o_ex_alu_result);

    // Test ALU operation SUB with SrcA = reg1, SrcB = imm
    i_id_alu_src2 = 1; // imm
    i_id_alu_op = ALU_SUB;
    @(posedge clk);

    $display("ALU SUB result (reg1 - imm): %h", o_ex_alu_result);

    // Test branch taken (BEQ, reg1 == imm) - not expected to take branch
    i_id_branch = 1;
    i_id_reg_read_data1 = 32'h00000010;
    i_id_imm = 32'h00000010;
    i_id_alu_src2 = 1;
    i_id_alu_op = ALU_SUB;
    @(posedge clk);

    $display("Branch flush: %b", o_ex_flush);

    $finish;
  end

endmodule
