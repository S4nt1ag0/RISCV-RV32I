`include "uvm_macros.svh"  
import uvm_pkg::*; // importa o package

// subclasse do uvm_driver, especializada para transações do tipo alu_txn
// Recebe as transações do sequencer e aplica os valores no DUT via interface
class alu_driver extends uvm_driver #(alu_txn);
  `uvm_component_utils(alu_driver) // Registra o driver no factory do UVM, permitindo sua criação dinâmica.

  virtual alu_if vif; // A variável vif é uma interface virtual do tipo alu_if, que liga o testbench com os sinais reais da DUT.

// Construtor padrão, chamando o construtor da classe base.
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

// Busca no uvm_config_db a interface virtual vif, que foi registrada lá no top_tb.sv.
// Se não encontrar, dispara erro fatal.
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Interface não encontrada")
  endfunction


  task run_phase(uvm_phase phase);
    alu_txn tx;
    forever begin
      seq_item_port.get_next_item(tx); // get_next_item(tx)	Espera uma nova transação do sequencer (alu_sequence)
      vif.A = tx.A; // vif.A = tx.A; ...	Escreve os valores da transação nos sinais da DUT
      vif.B = tx.B;
      vif.ALUControl = tx.ALUControl;
      #10;
      seq_item_port.item_done(); // item_done()	Informa que a transação foi completada
    end
  endtask

endclass
