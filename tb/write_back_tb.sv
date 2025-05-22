`timescale 1ns/1ps

module write_back_tb;

  // Sinais
  logic        i_ma_mem_to_reg;
  logic [1:0]  i_ma_rw_sel;
  logic [31:0] i_ma_result;
  logic [31:0] i_ma_read_data;
  logic [31:0] i_ma_pc_plus_4;
  logic [31:0] o_wb_data;

  // Instancia o DUT (Design Under Test)
  WriteBack dut (
    .i_ma_mem_to_reg (i_ma_mem_to_reg),
    .i_ma_rw_sel     (i_ma_rw_sel),
    .i_ma_result     (i_ma_result),
    .i_ma_read_data  (i_ma_read_data),
    .i_ma_pc_plus_4  (i_ma_pc_plus_4),
    .o_wb_data       (o_wb_data)
  );

  // Estímulos de teste
  initial begin
    $display("=== Início da Simulação ===");
    $monitor("t=%0t | mem_to_reg=%b, rw_sel=%b | read_data=%h, result=%h, pc+4=%h => wb_data=%h",
             $time, i_ma_mem_to_reg, i_ma_rw_sel, i_ma_read_data, i_ma_result, i_ma_pc_plus_4, o_wb_data);

    i_ma_read_data  = 32'hAAAAAAAA;
    i_ma_result     = 32'hBBBBBBBB;
    i_ma_pc_plus_4  = 32'hCCCCCCCC;

    // Loop sobre todas as combinações dos sinais de controle
    for (int mem_sel = 0; mem_sel < 2; mem_sel++) begin
      for (int rw_sel = 0; rw_sel < 4; rw_sel++) begin
        i_ma_mem_to_reg = mem_sel;
        i_ma_rw_sel     = rw_sel[1:0];
        #10;
      end
    end

    $display("=== Fim da Simulação ===");
    $finish;
  end

endmodule
