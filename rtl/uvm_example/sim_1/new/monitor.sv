// Monitor:
// - Não gera estímulo.
// - Observa passivamente os sinais da interface.
// - Converte sinais para transações e envia para análise posterior (via analysis_port).

class alu_monitor extends uvm_monitor; // Declara a classe alu_monitor, que estende uvm_monitor.
  `uvm_component_utils(alu_monitor) // permite que o monitor seja registrado na fábrica UVM (para instanciá-lo com type_id::create() e permitir introspecção/reflexão).
  virtual alu_if vif; // vif: ponte para a interface virtual (alu_if), usada para acessar os sinais conectados ao DUT.
  uvm_analysis_port #(alu_txn) mon_ap; // mon_ap: é a porta de análise. Ele publica transações (alu_txn) para que outros componentes (como o scoreboard) possam receber e analisar.

// Constroi a classe. Além de chamar o super.new, instancia o mon_ap com um nome e contexto atual.
  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

// Durante o build_phase, a interface alu_if é recuperada do config DB.
// Se não for encontrada, o monitor emite um erro fatal — isso interrompe a simulação, pois sem a interface o monitor não pode funcionar.
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Interface não encontrada")
  endfunction

// - No run_phase, o monitor executa um laço infinito. A cada 10ns:
// - Cria uma nova transação alu_txn
// - Lê os sinais da interface (A, B, ALUControl, Result, Zero)
// - Preenche os campos da transação
  task run_phase(uvm_phase phase); //  No run_phase, o monitor executa um laço infinito. A cada periodo:
    forever begin
      alu_txn tx = new(); 
      #10;
      tx.A = vif.A;
      tx.B = vif.B;
      tx.ALUControl = vif.ALUControl;
      tx.expected_result = vif.Result;
      tx.expected_zero = vif.Zero;
      mon_ap.write(tx);
    end
  endtask
endclass
