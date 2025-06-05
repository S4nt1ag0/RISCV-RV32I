//------------------------------------------------------------------------------
// Driver module for RISCV agent
//------------------------------------------------------------------------------
// This module handles transaction driving for the RISCV agent.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_DRIVER
`define RISCV_DRIVER

class RISCV_driver extends uvm_driver #(RISCV_transaction);
 
  /*
   * Declaration of transaction item 
   */
  RISCV_transaction trans;

  /*
   * Declaration of Virtual interface 
   */
  virtual RISCV_interface vif;

  /*
   * Declaration of component utils to register with factory 
   */
  `uvm_component_utils(RISCV_driver)
  uvm_analysis_port#(RISCV_transaction) drv2rm_port;

  /*
   * Constructor
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /*
   * Build phase: construct the components 
   * This phase retrieves the virtual interface from the UVM configuration database.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual RISCV_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
    drv2rm_port = new("drv2rm_port", this);
  endfunction: build_phase

  /*
   * Run phase: Drive the transaction info to DUT
   * This phase continuously drives transactions to the DUT.
   */
  virtual task run_phase(uvm_phase phase);
    reset();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM DRIVER"),UVM_LOW);
      req.print();
      @(vif.dr_cb);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      drv2rm_port.write(rsp);
      seq_item_port.item_done();
      seq_item_port.put(rsp);
    end
  endtask : run_phase

  /*
   * Task: drive
   * Drives the transaction signals to the DUT.
   */
  task drive();
    wait(!vif.reset);
    @(vif.dr_cb);
    vif.dr_cb.x <= req.x;
    vif.dr_cb.y <= req.y;
    vif.dr_cb.cin <= req.cin;
  endtask

  /*
   * Task: reset
   * Resets the transaction signals.
   */
  task reset();
    vif.dr_cb.x <= 0;
    vif.dr_cb.y <= 0;
    vif.dr_cb.cin <= 0;
  endtask

endclass : RISCV_driver

`endif





