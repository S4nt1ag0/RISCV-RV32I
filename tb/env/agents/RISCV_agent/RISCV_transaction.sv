//------------------------------------------------------------------------------
// Transaction class for RISCV operations
//------------------------------------------------------------------------------
// This class defines the transaction fields and constraints for RISCV operations.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_TRANSACTION 
`define RISCV_TRANSACTION

class RISCV_transaction extends uvm_sequence_item;

// Input parameters (instruction and memory interface signals)
bit [`P_DATA_WIDTH-1:0] instr_data;
rand bit [`P_DATA_WIDTH-1:0] data_rd;

// Instruction type name, useful for debugging and logging
string instr_name;

  `uvm_object_utils_begin(RISCV_transaction)
    `uvm_field_int(instr_data,        UVM_ALL_ON)
    `uvm_field_int(data_rd,           UVM_ALL_ON)
    `uvm_field_string(instr_name,     UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "RISCV_transaction");
    super.new(name);
  endfunction

  /*
   * Method: post_randomize
   */
  function void post_randomize();
  endfunction 

endclass

`endif