// Sequence.sv:
// - create("tx")	Cria nova transação
// - randomize()	Preenche com dados aleatórios
// - start_item(tx)	Avisa que vai enviar para o driver
// - finish_item(tx)	Finaliza e realmente envia para o driver

class alu_sequence extends uvm_sequence #(alu_txn); // Uma sequência UVM, ou seja, uma lista de transações do tipo alu_txn. gera dados para o driver
  `uvm_object_utils(alu_sequence) //Registra a sequência no factory do UVM.

// Define um construtor padrão
  function new(string name = "alu_sequence");
    super.new(name);
  endfunction

  task body();
    repeat (10) begin // repeat(10): Vai gerar 10 transações.
      alu_txn tx = alu_txn::type_id::create("tx"); // alu_txn::type_id::create("tx"): Cria uma nova transação (do tipo alu_txn).
      assert(tx.randomize()); // randomize(): Gera valores aleatórios para os campos da transação (A, B, ALUControl).
      start_item(tx); // start_item(tx): Pede permissão ao sequencer para iniciar a transação.
      finish_item(tx); // finish_item(tx): Finaliza a transação e envia para o driver.
    end
  endtask
endclass
