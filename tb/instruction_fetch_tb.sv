`timescale 1ns/1ps

module instruction_fetch_tb;

    // Entradas
    logic clk;
    logic rst_n;
    logic clk_en;
    logic flush;
    logic [31:0] jump_addr;
    logic [31:0] inst_data;

    // Saídas
    logic inst_rd_enable;
    logic [31:0] inst_addr;
    logic [31:0] if_inst;
    logic [31:0] if_pc;

    // Instancia o DUT (Device Under Test)
    instruction_fetch dut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_en(clk_en),
        .flush(flush),
        .jump_addr(jump_addr),
        .inst_data(inst_data),
        .inst_rd_enable(inst_rd_enable),
        .inst_addr(inst_addr),
        .if_inst(if_inst),
        .if_pc(if_pc)
    );

    // Gera clock (10ns período)
    initial clk = 0;
    always #5 clk = ~clk;

    // Memória fictícia de instruções (vetor para simular instruções)
    logic [31:0] fake_instr_mem [0:15];

    // Sequência de teste
    initial begin
        // Preenche instruções simuladas (por exemplo, instrução = endereço + 100)
        for (int i = 0; i < 16; i++) fake_instr_mem[i] = 32'h100 + i;

        // Inicialização
        rst_n = 0;
        clk_en = 1;
        flush = 0;
        jump_addr = 32'd0;
        inst_data = 32'd0;

        // Aplica reset
        @(negedge clk);
        rst_n = 1;

        // 1) Testa fluxo sequencial normal (PC+4)
        repeat (3) begin
            @(negedge clk);
            // Fornece instrução baseada no PC
            inst_data = fake_instr_mem[inst_addr >> 2];
        end

        // 2) Testa flush (salto para outro endereço)
        @(negedge clk);
        flush = 1;
        jump_addr = 32'd8; // Salta para endereço 8
        inst_data = fake_instr_mem[2]; // PC=8 -> idx=2
        @(negedge clk);
        flush = 0;
        jump_addr = 32'd0;

        // Continua fluxo sequencial a partir do novo PC
        repeat (2) begin
            @(negedge clk);
            inst_data = fake_instr_mem[inst_addr >> 2];
        end

        // 3) Testa stall (clk_en=0)
        @(negedge clk);
        clk_en = 0;
        // Força instrução diferente, mas PC não deve avançar
        inst_data = 32'hABCD1234;
        repeat (2) @(negedge clk);

        // Retorna clk_en = 1 (PC avança normalmente)
        clk_en = 1;
        @(negedge clk);
        inst_data = fake_instr_mem[inst_addr >> 2];

        // 4) Teste completo: pode adicionar outros cenários se desejar

        // Fim do teste
        #20 $display("Fim do Testbench!");
        $finish;
    end

    // Monitoramento para depuração
    initial begin
        $display("clk | rst_n | clk_en | flush | jump_addr | inst_addr | inst_data | if_pc | if_inst");
        $monitor("%b  %b    %b      %b     0x%08h   0x%08h    0x%08h   0x%08h  0x%08h",
            clk, rst_n, clk_en, flush, jump_addr, inst_addr, inst_data, if_pc, if_inst);
    end

endmodule
