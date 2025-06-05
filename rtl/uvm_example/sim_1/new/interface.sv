interface alu_if(input logic clk);
  logic [31:0] A;
  logic [31:0] B;
  logic [2:0]  ALUControl;
  logic [31:0] Result;
  logic        Zero;
endinterface

