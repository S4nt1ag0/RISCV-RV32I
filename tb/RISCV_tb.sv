`timescale 1ns / 1ps

import riscv_definitions::*;

module RISCV_tb;

  // Clock and Reset
  logic clk = 0;
  logic rst_n = 0;

  // Internal signals for one-time instruction memory initialization
  logic [31:0] inst_wr;
  logic inst_wr_en;
  logic [3:0] inst_ctrl = 4'b1111;
  logic init_active = 1;  // Indica fase de inicialização
  logic [31:0] init_addr; // Endereço para inicialização

  // Instruction memory interface (to DUT)
  logic instr_ready;
  dataBus_t instr_data;

  // Data memory interface (to DUT)
  logic data_ready;
  dataBus_t data_rd;

  // Outputs from DUT
  logic inst_rd_en;
  logic [3:0] inst_ctrl_cpu;
  logic [31:0] inst_addr;
  dataBus_t data_wr;
  dataBus_t data_addr;
  logic [3:0] data_rd_en_ctrl;
  logic data_rd_en_ma;
  logic data_wr_en_ma;

  // Instruction Memory Instantiation
  memory #(
      .DATA_WIDTH(DATA_WIDTH),
      .RAM_AMOUNT(RAM_AMOUNT)
  ) memory_instruction (
      .clk(clk),
      .we(inst_wr_en),
      .rd(inst_rd_en),
      .ctrl(init_active ? inst_ctrl : inst_ctrl_cpu),
      .addr(init_active ? init_addr : inst_addr),
      .di(inst_wr),
      .dout(instr_data),
      .dout_ready(instr_ready)
  );

  // Data Memory Instantiation
  memory #(
      .DATA_WIDTH(DATA_WIDTH),
      .RAM_AMOUNT(RAM_AMOUNT)
  ) memory_data (
      .clk(clk),
      .we(data_wr_en_ma),
      .rd(data_rd_en_ma),
      .ctrl(data_rd_en_ctrl),
      .addr(data_addr),
      .di(data_wr),
      .dout(data_rd),
      .dout_ready(data_ready)
  );

  // DUT Instantiation
  RISCV dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_instr_ready(instr_ready),
    .i_instr_data(instr_data),
    .o_inst_rd_en(inst_ctrl_cpu),
    .o_inst_addr(inst_addr),
    .i_data_ready(data_ready),
    .i_data_rd(data_rd),
    .o_data_wr(data_wr),
    .o_data_addr(data_addr),
    .o_data_rd_en_ctrl(data_rd_en_ctrl),
    .o_data_rd_en_ma(data_rd_en_ma),
    .o_data_wr_en_ma(data_wr_en_ma)
  );

  // Clock Generation (100 MHz)
  always #5 clk = ~clk;

  // Temporary instruction memory for loading .dat
  logic [31:0] mem_array [0:31];

  // File path resolution
  string fullpath = `__FILE__;
  string dirname;

  initial begin
    automatic int idx = fullpath.len() - 1;
    while (idx >= 0 && fullpath[idx] != "/") begin
        idx--;
    end
    if (idx >= 0) begin
        dirname = fullpath.substr(0, idx);
    end else begin
        dirname = ".";
    end
  end

  // Timeout
  initial begin
    $timeformat(-9, 1, "ns", 9);
    #12000ns;
    $display("CPU TEST TIMEOUT");
    $finish;
  end

  // Instruction Memory Initialization
  initial begin
    rst_n = 0;
    init_active = 1;  // Estamos na fase de inicialização
    $display("Loading instructions from CPUtest.dat...");
    $readmemh({dirname, "/CPUtest.dat"}, mem_array);

    for (int i = 0; i < 32; i++) begin
      @(posedge clk);
      inst_wr     = mem_array[i];
      inst_wr_en  = 1;
      inst_ctrl   = 4'b1111;
      init_addr   = (4*i); 
    end

    @(posedge clk);
    inst_wr_en = 0;
    init_active = 0;
    inst_rd_en = 1'b1;
    $display("Instruction memory initialized.");

    repeat (2) @(negedge clk);
    rst_n = 1; // Release reset
  end

  // Monitor memory writes for success/failure
  initial begin
    $display("Starting RISCV core testbench");

    forever @(negedge clk) begin
      if (data_wr_en_ma) begin
        if ((data_addr === 100) && (data_rd === 25)) begin
          $display("\n=== Simulation Succeeded ===\n");
          $finish;;
        end else if (data_addr !== 96) begin
          $display("\n!!! Simulation Failed !!!\n");
          $finish;;
        end
      end
    end
  end
endmodule