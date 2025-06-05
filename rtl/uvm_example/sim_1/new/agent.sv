// O alu_agent (agent.sv):
// driver	Recebe estímulos e envia para DUT via vif
// monitor	Observa sinais da interface e envia transações para o scoreboard
// sequencer	Fornece as transações para o driver executar (se ativo)

class alu_agent extends uvm_agent; // Define um agente UVM, que representa um canal completo de comunicação com o DUT.
// Herdando de uvm_agent, ele pode ser ativo (gera estímulos) ou passivo (só monitora).

  `uvm_component_utils(alu_agent) // registra a classe no factory

  alu_driver     drv; // drv: envia estímulos para o DUT via interface.
  alu_monitor    mon;  // mon: observa os sinais e gera transações recebidas.
  uvm_sequencer#(alu_txn) seqr;  // seqr: fornece transações do tipo alu_txn para o driver (só é instanciado se is_active == UVM_ACTIVE).

// É o construtor da classe alu_agent
// name: nome hierárquico do componente 
// parent: componente que instanciou esse
  function new(string name, uvm_component parent);  // cria todos os componentes com type_id::create("nome", pai). new() encapsula essa criação e passa para o pai (super.new).
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // is_active é uma flag herdada de uvm_agent, que define se o agente deve instanciar um sequencer
    // UVM_ACTIVE: vai gerar estímulo (usa sequencer e driver).
    // UVM_PASSIVE: só monitora (não instancia sequencer).
    if (is_active == UVM_ACTIVE) 
      seqr = uvm_sequencer#(alu_txn)::type_id::create("seqr", this);

    drv = alu_driver::type_id::create("drv", this); // Sempre cria driver 
    mon = alu_monitor::type_id::create("mon", this); // Sempre cria O monitor

    uvm_config_db#(virtual alu_if)::set(this, "drv", "vif", null);  // Diz ao config_db que os dois subcomponentes (drv e mon) vão usar uma interface virtual, chamada vif, que será injetada depois no top_tb.
    uvm_config_db#(virtual alu_if)::set(this, "mon", "vif", null);
  endfunction

// Conecta o sequencer ao driver.
// Permite que a sequence envie transações para o driver por meio da UVM TLM (seq_item_port ↔ seq_item_export).
  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass
