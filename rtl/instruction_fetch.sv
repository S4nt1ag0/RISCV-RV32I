import riscv_definitions::*; // Import package with types and constants

/**
 * Module: instruction_fetch
 * Description:
 *     Implements the Instruction Fetch (IF) stage of a 5-stage RISC-V pipeline processor.
 *     This module is responsible for generating the program counter (PC), issuing instruction fetch
 *     requests, handling control flow changes (branches/jumps), and passing the fetched instruction
 *     and corresponding PC to the next pipeline stage.
 */

 module instruction_fetch (
    input  logic        clk,              // Main clock
    input  logic        rst_n,            // Asynchronous active-low reset
    input  logic        clk_en_if_pc,     // Clock enable (stall control)
    input  logic        clk_en_if_reg,    // Clock enable (stall control)

    input  logic        i_flush,          // Forces PC update (branch/jump)
    input  logic [31:0] i_jump_addr,      // New PC address in case of flush
    input  logic [31:0] i_inst_data,      // Instruction data from memory

    output logic        o_inst_rd_enable, // Enable signal to read instruction memory
    output logic [31:0] o_inst_addr,      // PC value used for instruction fetch
    output logic [31:0] o_if_inst,        // Output instruction to Decode stage
    output logic [31:0] o_if_pc           // Output PC to Decode stage
);
logic [DATA_WIDTH-1:0] pc;
logic [DATA_WIDTH-1:0] pc_mux_data;
logic [DATA_WIDTH-1:0] pc_adder_data;

assign o_inst_addr = pc;
assign o_inst_rd_enable = 1'b1;
 

// -------------------------------------------------------------
// Program Counter adder
// -------------------------------------------------------------
always_comb begin
  pc_adder_data = pc + 32'd4;
end

// -------------------------------------------------------------
// Multiplex to select new PC value
// -------------------------------------------------------------
always_comb begin
  case(i_flush)
    0 : pc_mux_data = pc_adder_data;
    1 : pc_mux_data = i_jump_addr;
  endcase
end
 
// -------------------------------------------------------------
// Program Counter regireg [FUNCTION_WIDTH-1:0] inst_function,ster
// -------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        pc   <= 32'd0;
    end else if (clk_en_if_pc) begin
        pc   <= pc_mux_data;                 // Capture current PC (before update)
    end
end

// -------------------------------------------------------------
// IF_ID_REG
// -------------------------------------------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || i_flush) begin
        o_if_inst <= 32'd0;
        o_if_pc   <= 32'd0;
    end else if (clk_en_if_reg) begin
        o_if_inst <= i_inst_data;            // Capture fetched instruction
        o_if_pc   <= pc;             // Capture current PC (before update)
    end

end

endmodule