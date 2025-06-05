// Classe do scoreboard: responsável por verificar se os resultados da ALU estão corretos
class alu_scoreboard extends uvm_component;

  // Macro que registra esta classe no factory do UVM (permite instanciá-la dinamicamente)
  `uvm_component_utils(alu_scoreboard)

  // Porta de entrada para receber as transações (objetos alu_txn) do monitor
  uvm_analysis_imp #(alu_txn, alu_scoreboard) sb_ap;

  // Variável para manipular o arquivo de log
  integer log_file;

  // Contadores de estatísticas
  int pass = 0;   // Testes que passaram
  int fail = 0;   // Testes que falharam
  int total = 0;  // Total de testes

  // Construtor da classe, chama o construtor da classe base
  function new(string name, uvm_component parent);
    super.new(name, parent);
    // Cria a porta de análise que será conectada ao monitor
    sb_ap = new("sb_ap", this);
  endfunction

  // Fase de construção, chamada automaticamente pelo UVM
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Abre o arquivo para escrita do relatório
    log_file = $fopen("saida_scoreboard.txt", "w");

    // Verifica se o arquivo foi aberto com sucesso
    if (!log_file)
      `uvm_warning("SB", "Falha ao abrir arquivo de log")
    else
      $fdisplay(log_file, "==== INÍCIO DO RELATÓRIO DE VERIFICAÇÃO DA ULA ====\n");
  endfunction

  // Função chamada automaticamente sempre que o monitor envia uma transação
  function void write(alu_txn tx);
    bit [31:0] model;        // Armazena o resultado esperado (calculado aqui)
    bit result_ok;           // Flag para saber se o resultado foi correto

    // Modelo de referência: calcula o valor esperado com base no ALUControl
    case (tx.ALUControl)
      3'b000: model = tx.A + tx.B;                 // Soma
      3'b001: model = tx.A - tx.B;                 // Subtração
      3'b010: model = tx.A & tx.B;                 // AND
      3'b011: model = tx.A | tx.B;                 // OR
      3'b100: model = tx.A ^ tx.B;                 // XOR
      3'b101: model = (tx.A < tx.B) ? 1 : 0;       // Comparação menor
      default: model = 0;                          // Caso não reconhecido
    endcase

    // Verifica se o resultado obtido é igual ao esperado
    result_ok = (model === tx.expected_result);
    total++; // Atualiza o total de testes

    // Grava os dados do teste no arquivo de log
    $fdisplay(log_file,
      "Teste %0d: A=%0d B=%0d ALUCtrl=%b | Esperado=%0d Obtido=%0d | Resultado: %s",
      total, tx.A, tx.B, tx.ALUControl, model, tx.expected_result,
      (result_ok ? "OK" : "ERRO"));

    // Se o resultado estiver incorreto, incrementa falhas e exibe erro no log UVM
    if (!result_ok) begin
      fail++;
      `uvm_error("SB", $sformatf("Erro: esperado %0d, obteve %0d", model, tx.expected_result))
    end else begin
      pass++;
      `uvm_info("SB", "Resultado correto", UVM_LOW)
    end
  endfunction

  // Fase de relatório: chamada no final da simulação para imprimir as estatísticas
  function void report_phase(uvm_phase phase);
    real percentual = (total > 0) ? (100.0 * pass / total) : 0.0;

    // Escreve o resumo final no arquivo de log
    $fdisplay(log_file, "\n==== FIM DO RELATÓRIO ====");
    $fdisplay(log_file, "Total de testes: %0d", total);
    $fdisplay(log_file, "Passaram:         %0d", pass);
    $fdisplay(log_file, "Falharam:         %0d", fail);
    $fdisplay(log_file, "Percentual Pass:  %.2f%%", percentual);

    // Fecha o arquivo
    $fclose(log_file);

    // Também mostra o resumo no log do console UVM
    `uvm_info("SB", $sformatf("TOTAL → PASS: %0d | FAIL: %0d", pass, fail), UVM_NONE)
  endfunction

endclass
