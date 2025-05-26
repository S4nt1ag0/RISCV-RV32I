`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2025 03:42:48 PM
// Design Name: 
// Module Name: memory_access
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Modificado para integração com rams_sp_wf
// 
//////////////////////////////////////////////////////////////////////////////////

module memory_access(
    input  logic i_clk,
    input  logic i_rst_n,
    input logic        i_clk_en,

    //Entrada memory module
    input logic [31:0] i_data_rd,

    //Entradas Before Stage
    input logic        i_ex_mem_to_reg,
    input logic  [1:0] i_ex_rw_sel,
    input logic        i_ex_reg_wr,
    input logic        i_ex_mem_rd,
    input logic        i_ex_mem_wr,
    input logic [31:0] i_ex_pc_plus_4,
    input logic [31:0] i_ex_alu_result,
    input logic [31:0] i_ex_reg_read_data2,
    input logic  [4:0] i_ex_reg_dest,
    input logic  [2:0] i_ex_funct3,
    input logic  [6:0] i_ex_funct7,

    //Saídas  memory module
    output dataBus_t     o_data_wr,           // Data memory write data
    output dataBus_t     o_data_addr,         // Data memory address
    output logic [1:0]   o_data_rd_en_ctrl,   // Control for data memory read
    output logic         o_data_rd_en_ma,     // Enable data memory read (memory access)
    output logic         o_data_wr_en_ma,      // Enable data memory write (memory access)

    // Saídas next Stage
    output logic        o_ma_mem_to_reg,
    output logic  [1:0] o_ma_rw_sel,
    output logic [31:0] o_ma_pc_plus_4,
    output logic [31:0] o_ma_read_data,
    output logic [31:0] o_ma_result,
    output logic  [4:0] o_ma_reg_dest,
    output logic        o_ma_reg_wr
);
    
    assign o_data_wr = i_ex_reg_read_data2;
    assign o_data_addr = i_ex_alu_result;
    assign o_data_rd_en_ctrl = (i_ex_alu_result);
    assign o_data_rd_en_ma = i_ex_mem_rd;
    assign o_data_wr_en_ma = i_ex_mem_wr;

    case (i_ex_funct3)
                3'b000: assign o_data_rd_en_ctrl <= 2'b00; // byte
                3'b001: assign o_data_rd_en_ctrl <= 2'b01; // half-word
                3'b010: assign o_data_rd_en_ctrl <= 2'b10; // word
               default: assign o_data_rd_en_ctrl <= 2'b11; // reservado
    endcase

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
         
            o_ma_mem_to_reg    <= 0;
            o_ma_rw_sel        <= 0;
            o_ma_pc_plus_4     <= 0;
            o_ma_read_data     <= 0;
            o_ma_result        <= 0;
            o_ma_reg_dest      <= 0;
            o_ma_reg_wr        <= 0;
            o_data_rd_en_ctrl  <= 0;
        
        end else if (i_clk_en) begin         
                
            o_ma_mem_to_reg    <= i_ex_mem_to_reg;
            o_ma_rw_sel        <= i_ex_rw_sel;
            o_ma_pc_plus_4     <= i_ex_pc_plus_4;
            o_ma_read_data     <= i_data_rd;
            o_ma_result        <= i_ex_alu_result;
            o_ma_reg_dest      <= i_ex_reg_dest;
            o_ma_reg_wr        <= i_ex_reg_wr;
        end
    end
endmodule
