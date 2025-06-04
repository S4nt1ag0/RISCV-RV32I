import riscv_definitions::*; // Import RISC-V parameter definitions

/**
 * Module: register_file
 *
 * A 32-register bank for a RISC-V processor (x0 to x31).
 * - Register x0 (index 0) is hardwired to zero.
 * - Supports 2 asynchronous reads and 1 synchronous write.
 */
module register_file (
    input  logic                  i_clk,                   // Clock signal
    input  logic                  i_rst_n,                 // Asynchronous reset (active low)
    input  logic [REG_ADDR-1:0]   i_read_register1_addr,   // Source register 1 address
    input  logic [REG_ADDR-1:0]   i_read_register2_addr,   // Source register 2 address
    input  logic [REG_ADDR-1:0]   i_write_register_addr,   // Destination register address
    input  logic                  i_wr_reg_en,             // Destination write enable
    input  logic [DATA_WIDTH-1:0] i_write_data,            // Data to write
    output logic [DATA_WIDTH-1:0] o_read_data1,            // Read data from source 1
    output logic [DATA_WIDTH-1:0] o_read_data2             // Read data from source 2
);

    /**
     * Register bank: 32 general-purpose registers (x0 to x31).
     * - Register x0 (regs[0]) is hardwired to 0 and cannot be written.
     */
    logic [DATA_WIDTH-1:0] regs [0:REG_COUNT-1];

    /**
     * Combinational read logic for rs1 and rs2.
     * - If read address is 0 (x0), return 0.
     * - Otherwise return value from corresponding register.
     */
    always_comb begin : comb_rs_read
        o_read_data1 = (i_read_register1_addr == '0) ? '0 : regs[i_read_register1_addr];
        o_read_data2 = (i_read_register2_addr == '0) ? '0 : regs[i_read_register2_addr];
    end : comb_rs_read

    /**
     * Synchronous write logic for rd.
     * - Only writes when write enable is asserted and address ≠ 0 (x0).
     * - Writes are only performed if clock enable is high.
     * - On reset, all registers are cleared.
     */
    always_ff @(posedge i_clk or negedge i_rst_n) begin : reg_write
        if (!i_rst_n) begin
            regs <= '{default: '0};
        end else if (i_wr_reg_en && i_write_register_addr != '0) begin
            regs[i_write_register_addr] <= i_write_data;
        end
    end : reg_write

endmodule : register_file
