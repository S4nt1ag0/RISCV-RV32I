// Esse alu_test: 
// - Cria o ambiente de teste (env)
// - Executa a sequência de estímulos (alu_sequence)
// - Permite a verificação por meio de scoreboard
// - Usa o protocolo de objection para controlar o tempo de simulação

class alu_test extends uvm_test;// Cria a classe alu_test, herdando de uvm_test. Será invocado pelo run_test("alu_test") no top_tb. 

  `uvm_component_utils(alu_test) // registra essa classe no factory do UVM.  Instancia automaticamente com run_test("alu_test")
  
  alu_env env;  // Declara o ambiente de teste, do tipo alu_env, que agrupa: (O agente UVM (driver, monitor, sequencer) e O scoreboard

// Chama o construtor da classe (uvm_test) com os mesmos parâmetros.
  function new(string name = "alu_test", uvm_component parent = null);  
    super.new(name, parent);
  endfunction

// O test instancia o ambiente UVM usando o factory.
// "env" é o nome hierárquico. this é o pai (no caso, alu_test).
  function void build_phase(uvm_phase phase);
    env = alu_env::type_id::create("env", this);
  endfunction

// run_phase é onde o teste realmente acontece.
// raise_objection diz ao UVM que o teste ainda está em execução (impede que a simulação acabe).
// seq = ...create(...): instancia uma sequência de estímulos.
// seq.start(...): inicia a execução da sequência no sequencer que está dentro do agente (env.agt.seqr).
// drop_objection informa que o teste terminou, permitindo que o UVM finalize.

  task run_phase(uvm_phase phase);
    alu_sequence seq;
    phase.raise_objection(this);

    seq = alu_sequence::type_id::create("seq");
    seq.start(env.agt.seqr);

    phase.drop_objection(this);
  endtask

endclass
