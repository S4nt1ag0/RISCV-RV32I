`timescale 1ns/1ps

module write_back_tb;

  // Sinais
  logic        i_ma_mem_to_reg;
  logic [1:0]  i_ma_rw_sel;
  logic [31:0] i_ma_result;
  logic [31:0] i_ma_read_data;
  logic [31:0] i_ma_pc_plus_4;
  logic [31:0] o_wb_data;

  // Esperado
  logic [31:0] expected_mux2;
  logic [31:0] expected_wb_data;

  // Contadores de sucesso/erro
  int passed = 0;
  int failed = 0;

  // Instancia o DUT
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
    $display("=== Início da Simulação do WriteBack ===");
    $display("Testando todas as combinações de i_ma_mem_to_reg e i_ma_rw_sel");

    // Valores fixos para facilitar verificação
    i_ma_result     = 32'hAAAAAAAA;   // ALU result
    i_ma_read_data  = 32'hBBBBBBBB;   // Memória
    i_ma_pc_plus_4  = 32'hCCCCCCCC;

    // Loop de todas as combinações possíveis
    for (int mem_sel = 0; mem_sel < 2; mem_sel++) begin
      for (int rw_sel = 0; rw_sel < 4; rw_sel++) begin
        i_ma_mem_to_reg = mem_sel;
        i_ma_rw_sel     = rw_sel[1:0];
        #1;

        // Novo mapeamento do mux2 (ALU = in0, MEM = in1)
        expected_mux2 = (i_ma_mem_to_reg == 0) ? i_ma_result : i_ma_read_data;

        case (i_ma_rw_sel)
          2'b00: expected_wb_data = expected_mux2;
          2'b01: expected_wb_data = i_ma_pc_plus_4;
          2'b10,
          2'b11: expected_wb_data = 32'b0;
        endcase

        #9; // aguarda estabilização total

        if (o_wb_data === expected_wb_data) begin
          $display("PASSED | mem_to_reg=%0b rw_sel=%0b => wb_data=%h (OK)", 
                    i_ma_mem_to_reg, i_ma_rw_sel, o_wb_data);
          passed++;
        end else begin
          $display("FAILED | mem_to_reg=%0b rw_sel=%0b => wb_data=%h (esperado: %h)", 
                    i_ma_mem_to_reg, i_ma_rw_sel, o_wb_data, expected_wb_data);
          failed++;
        end
      end
    end

    $display("=== Fim da Simulação ===");
    $display("Total: %0d testes | Passaram: %0d | Falharam: %0d", passed + failed, passed, failed);

    if (failed == 0)
      $display("Todos os testes passaram!");
    else
      $display("Alguns testes falharam. Verificar a lógica.");

    $finish;
  end

endmodule
