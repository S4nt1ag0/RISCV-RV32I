//------------------------------------------------------------------------------
// Store sequence for RISCV
//------------------------------------------------------------------------------
// This sequence generates randomized transactions for the RISCV UVM verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_STORE_SEQ 
`define RISCV_STORE_SEQ

class RISCV_store_seq extends uvm_sequence#(RISCV_transaction);
   
  /*
   * Declaration of sequence utilities
   */
  `uvm_object_utils(RISCV_store_seq)
 
  /*
   * Sequence constructor
   */
  function new(string name = "RISCV_store_seq");
    super.new(name);
  endfunction
 
  /*
   * Body method: Sends randomized transactions via the sequencer
   * This method generates a series of randomized transactions and sends them
   * to the driver through the sequencer. Each transaction is created, randomized,
   * and sent to the driver, which then drives the transaction to the DUT.
   */
  virtual task body();
    for (int i = 0; i < `NO_OF_TRANSACTIONS; i++) begin
      req = RISCV_transaction::type_id::create("req");
      start_item(req);
      assert(req.randomize());
      `uvm_info(get_full_name(), $sformatf("RANDOMIZED TRANSACTION FROM SEQUENCE"), UVM_LOW);
      req.print();
      finish_item(req);
      get_response(rsp);
    end
  endtask
   
endclass

`endif


