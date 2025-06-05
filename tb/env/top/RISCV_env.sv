//------------------------------------------------------------------------------
// Environment module for RISCV
//------------------------------------------------------------------------------
// This module instantiates agents, monitors, and other components for the RISCV environment.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_ENV
`define RISCV_ENV

class RISCV_environment extends uvm_env;
 
  /*
   * Declaration of components
   */
  adder_agent adder_agnt;
  adder_ref_model ref_model;
  adder_coverage#(adder_transaction) coverage;
  adder_scoreboard  sb;
   
  /*
   * Register with factory
   */
  `uvm_component_utils(adder_environment)
     
  /*
   * Constructor
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: instantiate components
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    adder_agnt = adder_agent::type_id::create("adder_agent", this);
    ref_model = adder_ref_model::type_id::create("ref_model", this);
    coverage = adder_coverage#(adder_transaction)::type_id::create("coverage", this);
    sb = adder_scoreboard::type_id::create("sb", this);
  endfunction : build_phase

  /*
   * Connect phase: hook up TLM ports
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    adder_agnt.driver.drv2rm_port.connect(ref_model.rm_export);
    adder_agnt.monitor.mon2sb_port.connect(sb.mon2sb_export);
    ref_model.rm2sb_port.connect(coverage.analysis_export);
    ref_model.rm2sb_port.connect(sb.rm2sb_export);
  endfunction : connect_phase

endclass : RISCV_environment

`endif




