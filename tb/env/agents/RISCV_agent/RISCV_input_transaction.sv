//------------------------------------------------------------------------------
// Transaction class for RISCV operations
//------------------------------------------------------------------------------
// This class defines the transaction fields and constraints for RISCV operations.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_INPUT_TRANSACTION 
`define RISCV_INPUT_TRANSACTION

class RISCV_input_transaction extends uvm_sequence_item;

// Input parameters (instruction and memory interface signals)
bit [`P_DATA_WIDTH-1:0] instr_data[];
rand bit [`P_DATA_WIDTH-1:0] data_rd[];

// Instruction type name, useful for debugging and logging
string instr_name[];

  `uvm_object_utils_begin(RISCV_input_transaction)
    `uvm_field_array_int(instr_data,        UVM_ALL_ON)
    `uvm_field_array_int(data_rd,           UVM_ALL_ON)
    `uvm_field_array_string(instr_name,     UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "RISCV_input_transaction");
    super.new(name);
  endfunction

  /*
   * Method: post_randomize
   */
  function void post_randomize();
  endfunction 

  function void unpack_transactions(ref RISCV_transaction transactions[$]);
  RISCV_transaction single_tr;
  for (int i = 0; i < instr_data.size(); i++) begin
    single_tr = RISCV_transaction::type_id::create($sformatf("tr_%0d", i));
    
    single_tr.instr_data    = instr_data[i];
    single_tr.data_rd       = data_rd[i];
    single_tr.instr_name    = instr_name[i];

    transactions.push_back(single_tr);
  end
endfunction

endclass

`endif