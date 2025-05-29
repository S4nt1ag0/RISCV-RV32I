module instruction_fetch (

    input  logic        clk,            // Clock principal
    input  logic        rst_n,          // Reset assíncrono ativo baixo
    input  logic        clk_en,         // Enable para avançar (stall)
    input  logic        flush,          // Força atualização do PC (branch/jump)
    input  logic [31:0] jump_addr,      // Novo endereço do PC para desvio
    input  logic [31:0] inst_data,      // Instrução vinda da memória de instruções

    output logic        inst_rd_enable, // Habilita a leitura da memória de instruções
    output logic [31:0] inst_addr,      // Endereço do PC para a busca de instrução
    output logic [31:0] if_inst,        // Instrução lida (para o Decode)
    output logic [31:0] if_pc           // PC correspondente à instrução (para o Decode)
);
    
    logic [31:0] pc_next;  // Registrador do PC

    assign inst_rd_enable = 1'b1;     // instr_ready sempre high

    assign inst_addr = pc_next;      // Endereço da instrução a ser buscada recebe o PC atual

    // Saída da instrução recebida e PC
    always_ff @(posedge clk or negedge rst_n) begin
    // Inicializa
        if (!rst_n) begin
            pc_next  <= 32'd0;         // Inicializa o PC em zero
            if_inst <= 32'd0;         // Inicializa a instrução como sendo zero 
            if_pc   <= 32'd0;
     // Execução
        end else if (clk_en) begin
            if (flush) begin
                pc_next  <= jump_addr; // Se flush, o PC vai para jump_addr
            end else begin
                pc_next  <= pc_next + 32'd4; // PC + 4, vai para próximo endereço
            end
            // Manda a instrução lida e PC para o Decode
            if_inst <= inst_data;
            if_pc   <= pc_next;
        end
        // Se clk_en == 0: mantem valor atual
    end

endmodule
