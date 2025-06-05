`include "uvm_macros.svh"
import uvm_pkg::*;

class alu_txn extends uvm_sequence_item;
  rand bit [31:0] A, B;
  rand bit [2:0] ALUControl;
  bit [31:0] expected_result;
  bit expected_zero;

  `uvm_object_utils(alu_txn)

  function new(string name = "alu_txn");
    super.new(name);
  endfunction
endclass
