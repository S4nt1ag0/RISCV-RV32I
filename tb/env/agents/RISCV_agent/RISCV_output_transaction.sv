//------------------------------------------------------------------------------
// Transaction class for RISCV operations
//------------------------------------------------------------------------------
// This class defines the transaction fields and constraints for RISCV operations.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_OUTPUT_TRANSACTION 
`define RISCV_OUTPUT_TRANSACTION

class RISCV_output_transaction extends uvm_sequence_item;

// Input parameters (instruction and memory interface signals)
bit [`P_DATA_WIDTH-1:0] data_register[31:0];

  `uvm_object_utils_begin(RISCV_output_transaction)
    `uvm_field_sarray_int(data_register,        UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "RISCV_output_transaction");
    super.new(name);
  endfunction

  /*
   * Method: post_randomize
   */
  function void post_randomize();
  endfunction 

endclass

`endif