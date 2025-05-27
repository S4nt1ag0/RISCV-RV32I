/**
 * Module: WriteBack
 * Description:
 *     This module implements the Write Back (WB) stage of a 5-stage RISC-V pipeline.
 *     It selects the correct data to be written back to the register file, based on
 *     memory or ALU/PC results, according to control signals.
 *
 *     Two 2-to-1 multiplexers are used:
 *       - The first selects between the ALU result and the memory read data.
 *       - The second selects between the output of the first MUX and PC+4.
 */

module WriteBack (
    input  logic        i_ma_mem_to_reg, // Selects between ALU result and memory data
    input  logic        i_ma_rw_sel,     // Selects between mux2_out or PC+4
    input  logic [31:0] i_ma_pc_plus_4,  // PC + 4 (used for JAL/JALR)
    input  logic [31:0] i_ma_read_data,  // Data read from memory
    input  logic [31:0] i_ma_result,     // Result from ALU
    output logic [31:0] o_wb_data        // Data to write to register file
);

    logic [31:0] mux2_out;

    // MUX 2:1 - Selects between ALU result and memory read data
    mux2to1 mux_select_mem_or_alu (
        .in0 (i_ma_result),     // ALU result
        .in1 (i_ma_read_data),  // Memory data
        .sel (i_ma_mem_to_reg), // Select signal
        .out (mux2_out)         // Selected output
    );

    // MUX 2:1 - Selects between mux2_out and PC+4
    mux2to1 mux_select_final_data (
        .in0 (mux2_out),        // Output from previous MUX
        .in1 (i_ma_pc_plus_4),  // PC + 4
        .sel (i_ma_rw_sel),     // Select signal
        .out (o_wb_data)        // Final write-back data
    );

endmodule