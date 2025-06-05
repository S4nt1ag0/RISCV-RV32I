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

  /*
   * Declaration of RISCV transaction fields  //isso aqui vai precisar mudar muito
   */
  rand bit [`RISCV_WIDTH-1:0] x, y;
  rand bit cin;
  bit [`RISCV_WIDTH-1:0] sum;
  bit cout;
  bit [2:0] carry_out; 


// Instruction memory interface (to DUT)
  bit instr_ready;
  bit [31:0] instr_data;

  // Data memory interface (to DUT)
  bit data_ready;
  bit [31:0] data_rd;

  // Outputs from DUT
  bit inst_rd_en;
  bit [3:0] inst_ctrl_cpu;
  bit [31:0] inst_addr;
  bit [31:0] data_wr;
  bit [31:0] data_addr;
  bit [3:0] data_rd_en_ctrl;
  bit data_rd_en_ma;
  bit data_wr_en_ma;
  /*
   * Declaration of Utility and Field macros
   */
  `uvm_object_utils_begin(RISCV_transaction)
    `uvm_field_int(x, UVM_ALL_ON)
    `uvm_field_int(y, UVM_ALL_ON)
    `uvm_field_int(cin, UVM_ALL_ON)
    `uvm_field_int(sum, UVM_ALL_ON)
    `uvm_field_int(cout, UVM_ALL_ON)
    `uvm_field_int(carry_out, UVM_ALL_ON)
  `uvm_object_utils_end
   
  /*
   * Constructor
   */
  function new(string name = "RISCV_transaction");
    super.new(name);
  endfunction

  /*
   * Declaration of Constraints
   */
  constraint x_c { x inside {[4'h0:4'hF]}; }			  
  constraint y_c { y inside {[4'h0:4'hF]}; }			  
  constraint cin_c { cin inside {0, 1}; }			  

  /*
   * Method: post_randomize
   */
  function void post_randomize();
  endfunction  
   
endclass

`endif