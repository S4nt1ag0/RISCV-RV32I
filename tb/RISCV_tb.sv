`timescale 1ns / 1ps

module RISCV_tb;

  // Clock and reset
  logic clk;
  logic rst_n;

  // Instruction memory interface
  logic         i_instr_ready;
  dataBus_t     i_instr_data;
  logic         o_inst_rd_en;
  logic [31:0]  o_inst_addr;

  // Data memory interface
  logic         i_data_ready;
  dataBus_t     i_data_rd;
  dataBus_t     o_data_wr;
  dataBus_t     o_data_addr;
  logic [1:0]   o_data_rd_en_ctrl;
  logic         o_data_rd_en_ma;
  logic         o_data_wr_en_ma;

  // DUT instantiation
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

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset logic
  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  // Instruction memory mock
  initial begin
    i_instr_ready = 1;
    i_data_ready  = 1;

    i_instr_data = 32'h00A00093; // addi x1, x0, 10

    // Data memory dummy values
    i_data_rd = '0;

    // Wait for a few cycles
    #100;

    // Test another instruction
    i_instr_data = 32'h00108093; // addi x1, x1, 1

    #100;

    $finish;
  end

endmodule
