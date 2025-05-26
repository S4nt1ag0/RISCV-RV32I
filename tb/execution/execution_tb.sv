`timescale 1ns / 1ps

import riscv_definitions::*;

/**
 * Testbench: execution_tb
 * Description:
 *     Testbench for the 'execution' module of a RISC-V processor.
 *     Validates correct ALU operations, branching, and pipeline behavior.
 */
module execution_tb;

  localparam DEBUG_MODE = 0;

  // Clock and Reset
  logic clk = 0;
  logic rst_n = 1;
  logic clk_en = 1;

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

  // Estatísticas de testes
  int passed = 0;
  int failed = 0;
  int total = 0;

  // Tipo de vetor de teste
  typedef struct {
    string     name;
    logic      alu_src1;
    logic      alu_src2;
    aluOpType  alu_op;
    logic      jump;
    logic      branch;
    dataBus_t  pc;
    dataBus_t  reg1;
    dataBus_t  reg2;
    dataBus_t  imm;
    dataBus_t  expected_result;
    logic      expected_flush;
    dataBus_t  expected_jump_addr;
  } test_vector_t;

  // Instância do módulo
  execution dut (
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

  // Geração de clock
  always #5 clk = ~clk;

  // Vetor de testes
  test_vector_t tests[] = '{
  '{ 
        name: "ADD: reg1 + reg2",
        alu_src1: 1'b0,
        alu_src2: 1'b0,
        alu_op: ALU_ADD,
        jump: 1'b0,
        branch: 1'b0,
        pc: 32'h1000_0000,
        reg1: 32'd5,
        reg2: 32'd3,
        imm: 32'd0,
        expected_result: 32'd8,
        expected_flush: 1'b0,
        expected_jump_addr: 32'd8 
    },
  '{ 
        name: "ADDI: reg1 + imm",
        alu_src1: 1'b0,
        alu_src2: 1'b1,
        alu_op: ALU_ADD,
        jump: 1'b0,
        branch: 1'b0,
        pc: 32'h1000_0004,
        reg1: 32'd7,
        reg2: 32'd0,
        imm: 32'd4,
        expected_result: 32'd11,
        expected_flush: 1'b0,
        expected_jump_addr: 32'd11 
    },
  '{ 
        name: "SLT: reg1 < reg2",
        alu_src1: 1'b0,
        alu_src2: 1'b0,
        alu_op: ALU_LT,
        jump: 1'b0,
        branch: 1'b0,
        pc: 32'h1000_0008,
        reg1: 32'd2,
        reg2: 32'd5,
        imm: 32'd0,
        expected_result: 32'd1,
        expected_flush: 1'b0,
        expected_jump_addr: 32'd1
    },
    '{ name: "JAL: PC + imm",
        alu_src1: 1'b1,
        alu_src2: 1'b1, 
        alu_op: ALU_ADD,
        jump: 1'b1,
        branch: 1'b0,
        pc: 32'h1000_000C,
        reg1: 32'd0, 
        reg2: 32'd0, 
        imm: 32'd16,
        expected_result: 32'h1000_001C,
        expected_flush: 1'b1, 
        expected_jump_addr: 32'h1000_001C
    },
    '{ name: "BNE false",
        alu_src1: 1'b0,
        alu_src2: 1'b0,
        alu_op: ALU_NEQUAL,
        jump: 1'b0, 
        branch: 1'b1,
        pc: 32'h1000_0010, 
        reg1: 32'd4,
        reg2: 32'd4, 
        imm: 32'd8,
        expected_result: 32'd0, 
        expected_flush: 1'b0,
        expected_jump_addr: 32'd0 
    },
    '{ name: "BNE true",
        alu_src1: 1'b0, 
        alu_src2: 1'b0, 
        alu_op: ALU_NEQUAL,
        jump: 1'b0, 
        branch: 1'b1,
        pc: 32'h1000_0014,
        reg1: 32'd10, 
        reg2: 32'd4, 
        imm: 32'd8,
        expected_result: 32'd1,
        expected_flush: 1'b1,
        expected_jump_addr: 32'h1000_001C
    },
    '{ 
        name: "SLTU: reg1 < reg2 unsigned",
        alu_src1: 1'b0, 
        alu_src2: 1'b0, 
        alu_op: ALU_LTU,
        jump: 1'b0, 
        branch: 1'b0,
        pc: 32'h1000_0018, 
        reg1: 32'hFFFF_FFFF, 
        reg2: 32'h0000_0001, 
        imm: 32'd0,
        expected_result: 32'd0, 
        expected_flush: 1'b0, 
        expected_jump_addr: 32'd0
      }
};

  // Task de aplicação e checagem
  task automatic apply_and_check(input test_vector_t t); begin
    @(negedge clk);
    i_id_alu_src1        = t.alu_src1;
    i_id_alu_src2        = t.alu_src2;
    i_id_alu_op          = t.alu_op;
    i_id_jump            = t.jump;
    i_id_branch          = t.branch;
    i_id_pc              = t.pc;
    i_id_reg_read_data1  = t.reg1;
    i_id_reg_read_data2  = t.reg2;
    i_id_imm             = t.imm;
    
    @(posedge clk);
    @(posedge clk); // Espera 2 ciclos

    total++;

    if (o_ex_alu_result === t.expected_result &&
        o_ex_flush === t.expected_flush &&
        o_ex_jump_addr === t.expected_jump_addr) begin
      passed++;
      $display("PASS: %s", t.name);
      if (DEBUG_MODE) begin
        $display("  ALU Result: %h | Expected: %h", o_ex_alu_result, t.expected_result);
        $display("  Flush     : %b | Expected: %b", o_ex_flush, t.expected_flush);
        $display("  Jump Addr : %h | Expected: %h", o_ex_jump_addr, t.expected_jump_addr);
      end
    end else begin
      failed++;
      $display("FAIL: %s", t.name);
      $display("  Got: ALU=%h, Flush=%b, JumpAddr=%h", o_ex_alu_result, o_ex_flush, o_ex_jump_addr);
      $display("  Exp: ALU=%h, Flush=%b, JumpAddr=%h", t.expected_result, t.expected_flush, t.expected_jump_addr);
    end
  end endtask

  // Inicialização
  initial begin
    @(posedge clk);
    rst_n = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(2) @(posedge clk);

    // Executa todos os testes
    foreach (tests[i]) begin
      apply_and_check(tests[i]);
    end

    // Relatório
    $display("\n=== Testbench Finished ===");
    $display("  Total tests:  %0d", total);
    $display("  Passed:       %0d", passed);
    $display("  Failed:       %0d", failed);
    $display("  Success rate: %0.1f%%", 100.0 * real'(passed)/real'(total));

    repeat (3) @(posedge clk);
    $finish;
  end

endmodule
