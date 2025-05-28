`timescale 1ns / 1ps

/**
 * Module: memory_access
 * Description:
 *     Implements the Memory Access (MEM) stage of a 5-stage RISC-V pipeline.
 *     This stage handles data memory reads and writes, and applies data alignment 
 *     and extension logic for various load instructions.
 **/

module memory_access(
    input  logic        clk,               // System clock
    input  logic        rst_n,             // Active-low reset
    input  logic        clk_en,            // Clock enable

    // Data read from memory
    input  logic [31:0] i_data_rd,           // Data read from memory

    // Signals from Execute stage
    input  logic        i_ex_mem_to_reg,     // Mem-to-reg signal from EX stage
    input  logic        i_ex_rw_sel,         // Write-back result selection
    input  logic        i_ex_reg_wr,         // Register write enable
    input  logic        i_ex_mem_rd,         // Memory read enable
    input  logic        i_ex_mem_wr,         // Memory write enable
    input  logic [31:0] i_ex_pc_plus_4,      // PC + 4
    input  logic [31:0] i_ex_alu_result,     // ALU result (memory address)
    input  logic [31:0] i_ex_reg_read_data2, // Value to write to memory
    input  logic  [4:0] i_ex_reg_dest,       // Destination register
    input  logic  [2:0] i_ex_funct3,         // funct3 field (determines load type)
    input  logic  [6:0] i_ex_funct7,         // funct7 (not used here)

    // Outputs to memory module
    output logic [31:0] o_data_wr,           // Data to write to memory
    output logic [31:0] o_data_addr,         // Address for memory access
    output logic  [3:0] o_data_rd_en_ctrl,   // Memory read size: 00=B, 01=H, 10=W
    output logic        o_data_rd_en_ma,     // Read enable for memory
    output logic        o_data_wr_en_ma,     // Write enable for memory

    // Outputs to Write Back stage
    output logic        o_ma_mem_to_reg,     // Forwarded mem-to-reg signal
    output logic        o_ma_rw_sel,         // Forwarded write-back result select
    output logic [31:0] o_ma_pc_plus_4,      // Forwarded PC + 4
    output logic [31:0] o_ma_read_data,      // Loaded data from memory (processed)
    output logic [31:0] o_ma_result,         // Forwarded ALU result
    output logic  [4:0] o_ma_reg_dest,       // Forwarded destination register
    output logic        o_ma_reg_wr          // Forwarded register write enable
);

    // Direct connections to memory
    assign o_data_wr       = i_ex_reg_read_data2;
    assign o_data_addr     = i_ex_alu_result;
    assign o_data_rd_en_ma = i_ex_mem_rd;
    assign o_data_wr_en_ma = i_ex_mem_wr;

    // Determine memory access type (byte, half-word, word)
    always_comb begin
        case (i_ex_funct3)
            3'b000: o_data_rd_en_ctrl = 4'b0001; // LB or LBU
            3'b001: o_data_rd_en_ctrl = 4'b00111; // LH or LHU
            3'b010: o_data_rd_en_ctrl = 4'b1111; // LW
            default: o_data_rd_en_ctrl = 4'b1111; // Reserved / invalid
        endcase
    end

    // Main pipeline register and read data logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            o_ma_mem_to_reg   <= 0;
            o_ma_rw_sel       <= 0;
            o_ma_pc_plus_4    <= 0;
            o_ma_read_data    <= 0;
            o_ma_result       <= 0;
            o_ma_reg_dest     <= 0;
            o_ma_reg_wr       <= 0;
        end else if (clk_en) begin
            o_ma_mem_to_reg   <= i_ex_mem_to_reg;
            o_ma_rw_sel       <= i_ex_rw_sel;
            o_ma_pc_plus_4    <= i_ex_pc_plus_4;
            o_ma_result       <= i_ex_alu_result;
            o_ma_reg_dest     <= i_ex_reg_dest;
            o_ma_reg_wr       <= i_ex_reg_wr;

            // Handle memory read data based on funct3
            case (i_ex_funct3)
                3'b000:  // LB (Load Byte, signed)
                    o_ma_read_data <= {{24{i_data_rd[7]}}, i_data_rd[7:0]};
                3'b001:  // LH (Load Half, signed)
                    o_ma_read_data <= {{16{i_data_rd[15]}}, i_data_rd[15:0]};
                3'b010:  // LW (Load Word)
                    o_ma_read_data <= i_data_rd;
                3'b100:  // LBU (Load Byte, unsigned)
                    o_ma_read_data <= {24'b0, i_data_rd[7:0]};
                3'b101:  // LHU (Load Half, unsigned)
                    o_ma_read_data <= {16'b0, i_data_rd[15:0]};
                default:
                    o_ma_read_data <= i_data_rd; // Default fallback
            endcase
        end
    end

endmodule