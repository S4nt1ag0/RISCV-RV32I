//------------------------------------------------------------------------------
// Reference model module for RISCV
//------------------------------------------------------------------------------
// This module defines the reference model for the RISCV verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_REF_MODEL 
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  /*
   * Declaration of Local Signals
   */
  uvm_analysis_export#(RISCV_transaction) rm_export;
  uvm_analysis_port#(RISCV_transaction) rm2sb_port;
  RISCV_transaction exp_trans, rm_trans;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

  /*
   * Constructor
   */
  function new(string name = "RISCV_ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  /*
   * Build phase: create internal objects
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export = new("rm_export", this);
    rm2sb_port = new("rm2sb_port", this);
    rm_exp_fifo = new("rm_exp_fifo", this);
  endfunction : build_phase

  /*
   * Connect phase: hook up TLM ports
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction : connect_phase

  /*
   * Run phase: process transactions
   */
  task run_phase(uvm_phase phase);
    forever begin
      rm_exp_fifo.get(rm_trans);
      get_expected_transaction(rm_trans);
    end
  endtask

  /*
   * Task: get_expected_transaction
   */
  task get_expected_transaction(RISCV_transaction rm_trans);
    this.exp_trans = rm_trans;
    `uvm_info(get_full_name(), $sformatf("EXPECTED TRANSACTION FROM REF MODEL"), UVM_LOW);
    exp_trans.print();
    {exp_trans.cout, exp_trans.sum} = exp_trans.x + exp_trans.y + exp_trans.cin;
    rm2sb_port.write(exp_trans);
  endtask

endclass

`endif