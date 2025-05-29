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
    input  logic        clk_en,           // Clock enable (stall control)

    input  logic        i_flush,          // Forces PC update (branch/jump)
    input  logic [31:0] i_jump_addr,      // New PC address in case of flush
    input  logic [31:0] i_inst_data,      // Instruction data from memory

    output logic        o_inst_rd_enable, // Enable signal to read instruction memory
    output logic [31:0] o_inst_addr,      // PC value used for instruction fetch
    output logic [31:0] o_if_inst,        // Output instruction to Decode stage
    output logic [31:0] o_if_pc           // Output PC to Decode stage
);

logic [31:0] pc_next;  // Next PC (calculated combinationally)

// Always enable instruction memory read
assign o_inst_rd_enable = 1'b1;

// Address to fetch instruction from is the current PC
assign o_inst_addr = pc_next;

// Sequential logic to update PC and outputs
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        o_if_inst <= 32'd0;
        o_if_pc   <= 32'd0;
    end else if (clk_en) begin
        o_if_inst <= i_inst_data;   // Capture fetched instruction
        o_if_pc   <= pc_next;            // Capture current PC (before update)
    end
end

always_ff @(posedge clk or negedge rst_n) begin: proc_next_pc
    if(!rst_n) begin
        pc_next <= 'b0;
    end else if(clk_en) begin
        if (i_flush) begin
            pc_next <= i_jump_addr;
        end else begin
            pc_next <= pc_next + 32'd4;
        end
    end
end: proc_next_pc

endmodule
