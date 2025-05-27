`timescale 1ns / 1ps

import riscv_definitions::*;

module RISCV_tb;

  logic clk;
  logic rst_n;

  // Inputs to DUT
  logic i_instr_ready;
  dataBus_t i_instr_data;
  logic i_data_ready;
  dataBus_t i_data_rd;

  // Outputs from DUT
  logic o_inst_rd_en;
  logic [31:0] o_inst_addr;
  dataBus_t o_data_wr;
  dataBus_t o_data_addr;
  logic [1:0] o_data_rd_en_ctrl;
  logic o_data_rd_en_ma;
  logic o_data_wr_en_ma;

  // Instantiate DUT
  RISCV dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_instr_ready(i_instr_ready),
    .i_instr_data(i_instr_data),
    .o_inst_rd_en(o_inst_rd_en),
    .o_inst_addr(o_inst_addr),
    .i_data_ready(i_data_ready),
    .i_data_rd(i_data_rd),
    .o_data_wr(o_data_wr),
    .o_data_addr(o_data_addr),
    .o_data_rd_en_ctrl(o_data_rd_en_ctrl),
    .o_data_rd_en_ma(o_data_rd_en_ma),
    .o_data_wr_en_ma(o_data_wr_en_ma)
  );

  // Clock generator
  always #5 clk = ~clk;

  logic [31:0] tests[37] = '{
    32'h0000a2b7,  // LUI x5, 0xa
    32'h00010317,  // AUIPC x6, 0x10
    32'h00a10093,  // ADDI x1, x2, 10
    32'h0ff24193,  // XORI x3, x4, 255
    32'h00f37293,  // ANDI x5, x6, 15
    32'h00341393,  // SLLI x7, x8, 3
    32'h00255493,  // SRLI x9, x10, 2
    32'h40265593,  // SRAI x11, x12, 2
    32'hffb72693,  // SLTI x13, x14, -5
    32'h06483793,  // SLTIU x15, x16, 100
    32'h0ff96893,  // ORI x17, x18, 255
    32'h004a09e7,  // JALR x19, x20, 4
    32'h000b2a83,  // LW x21, 0(x22)
    32'h001c0b83,  // LB x23, 1(x24)
    32'h002d1c83,  // LH x25, 2(x26)
    32'h003e4d83,  // LBU x27, 3(x28)
    32'h004f5e83,  // LHU x29, 4(x30)
    32'h003100b3,  // ADD x1, x2, x3
    32'h40628233,  // SUB x4, x5, x6
    32'h009413b3,  // SLL x7, x8, x9
    32'h00c5c533,  // XOR x10, x11, x12
    32'h00f756b3,  // SRL x13, x14, x15
    32'h4128d833,  // SRA x16, x17, x18
    32'h015a69b3,  // OR x19, x20, x21
    32'h018bfb33,  // AND x22, x23, x24
    32'h01bd2cb3,  // SLT x25, x26, x27
    32'h01eebe33,  // SLTU x28, x29, x30
    32'h00112023,  // SW x1, 0(x2)
    32'h00320223,  // SB x3, 4(x4)
    32'h00531323,  // SH x5, 6(x6)
    32'h06208c63,  // BEQ x1, x2, 120
    32'h06419a63,  // BNE x3, x4, 116
    32'h0662c863,  // BLT x5, x6, 112
    32'h0683d663,  // BGE x7, x8, 108
    32'h06a4e463,  // BLTU x9, x10, 104
    32'h06c5f263,  // BGEU x11, x12, 100
    32'h060000ef   // JAL x1, 96
};

  // Initialization
  initial begin
    $display("Starting RISCV core testbench");

    clk = 0;
    rst_n = 0;
    i_instr_ready = 1;
    i_data_ready = 1;
    i_data_rd = 32'd0;
    
    // Reset pulse
    #20;
    rst_n = 1;

    // Apply test instructions one by one
    foreach (tests[i]) begin
      i_instr_data = tests[i];
      @(posedge clk);
      $display("Cycle %0t: Applied instruction: 0x%08h", $time, tests[i]);
    end

    #50;
    $display("Testbench completed");
    $finish;
  end
endmodule