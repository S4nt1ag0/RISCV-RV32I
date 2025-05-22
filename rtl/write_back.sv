
module WriteBack (

    input  logic        i_ma_mem_to_reg, // i_ma_mem_to_reg: define se o dado vem da memória(0) ou da ALU/PC (1)
    input  logic [1:0]  i_ma_rw_sel,     // Seleção entre a saída do mux2 ou i_ma_pc_plus_4
    
    input  logic [31:0] i_ma_pc_plus_4,  // PC + 4
    input  logic [31:0] i_ma_read_data,  // Dado lido da memória
    input  logic [31:0] i_ma_result,     // Resultado da ALU

    output logic [31:0] o_wb_data        // Valor a ser escrito no banco de registradores
);

    logic [31:0] mux2_out;

    // Instância do MUX 2:1
    mux2to1 u_mux2to1 (
        .in0 (i_ma_result), //ALU result
        .in1 (i_ma_read_data), 
        .sel (i_ma_mem_to_reg),
        .out (mux2_out)
    );

    // Instância do MUX 4:1
    mux4to1 u_mux4to1 (
        .in0 (mux2_out),
        .in1 (i_ma_pc_plus_4),
        .in2 (32'b0),            // Caso seja necessário eu adiciono o sinal i_ma_imm
        .in3 (32'b0),            // Não usado, pode ser zero ou outro sinal, assim como o anterior
        .sel (i_ma_rw_sel),
        .out (o_wb_data)
    );

//Faz diferença estar em .in0 ou .in1, um vai ser selecionado com 0 e o outro com 1, conferir com a equipe se tá adequado essa lógica que coloquei
endmodule
