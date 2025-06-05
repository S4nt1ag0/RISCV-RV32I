`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

module top_tb;

  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  alu_if alu_if_inst(clk);

  // Instancia DUT
  alu dut (
    .A(alu_if_inst.A),
    .B(alu_if_inst.B),
    .ALUControl(alu_if_inst.ALUControl),
    .Result(alu_if_inst.Result),
    .Zero(alu_if_inst.Zero)
  );

  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif", alu_if_inst);
    run_test("alu_test");
  end

endmodule
