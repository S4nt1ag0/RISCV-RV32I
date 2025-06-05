// O alu_env:
// - Instancia e organiza o sistema de verificação.
// - Cria o agente e o scoreboard.
// - Conecta o monitor ao scoreboard para análise automática.
// - Serve como “ambiente de testes” chamado pelo alu_test.

class alu_env extends uvm_env; // Define o ambiente de verificação. Herda de uvm_env, que é o tipo padrão de container em UVM para outros componentes.
 
  `uvm_component_utils(alu_env) // Registra alu_env no factory do UVM, permitindo sua criação via type_id::create(...).


  alu_agent        agt;  // agente -  componente responsável por gerar e aplicar os estímulos e monitorar o DUT.
  alu_scoreboard   sb;  // scoreboard - componente responsável por verificar se a saída do DUT está correta (comparação com modelo).


// Chama o construtor da superclasse uvm_env
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

//Instancia o alu_agent e o alu_scoreboard.
// "agt" e "sb" são os nomes hierárquicos dentro do ambiente.
// O this define que alu_env será o "pai" desses componentes.
  function void build_phase(uvm_phase phase);
    agt = alu_agent::type_id::create("agt", this);
    sb  = alu_scoreboard::type_id::create("sb", this);
  endfunction

// Conecta o monitor do agente (mon_ap) ao scoreboard (sb_ap) usando uma TLM (Transaction-Level Modeling) analysis port.
// Fazendo com que cada transação observada pelo monitor seja enviada automaticamente para o scoreboard.
  function void connect_phase(uvm_phase phase);
    agt.mon.mon_ap.connect(sb.sb_ap);
  endfunction

endclass
