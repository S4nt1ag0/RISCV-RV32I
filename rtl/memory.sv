/**
 * Module: memory
 * Description:
 *     Implements a 4-bank byte-wise memory block using four single-port RAMs with independent enable control.
 *     Each memory bank stores 8 bits and together they handle 32-bit input/output operations.
 *     
 *     Features:
 *       - Shared 32-bit address and data lines for write and read operations.
 *       - Independent control (`ctrl`) signals to enable each of the four RAM banks.
 *       - Read/Write logic with one clock signal.
 *       - Write-first behavior at the RAM level.
 *       - Simple ready signal indicating output is valid (always high in this version).
 *
 * Parameters:
 *       - DATA_WIDTH: Width of data (default 32 bits).
 *       - RAM_AMOUNT: Number of memory banks (default 4).
 **/

module memory 
#(
    parameter DATA_WIDTH = 32,
    parameter RAM_AMOUNT = 4
)
(
    input  logic                      clk,
    input  logic                      we,           // Global write enable
    input  logic                      rd,           // Global read enable
    input  logic [RAM_AMOUNT-1:0]     ctrl,         // Independent enable for each bank
    input  logic [DATA_WIDTH-1:0]     addr,         // Shared address
    input  logic [DATA_WIDTH-1:0]     di,           // 32-bit input data
    output logic [DATA_WIDTH-1:0]     dout,         // 32-bit output data
    output logic                      dout_ready    // Data ready flag
);

    // Internal wires for each 8-bit memory bank input and output
    logic [7:0] inS [0:3];
    logic [7:0] outS [0:3];

    // Assign 8-bit segments from 32-bit input
    assign inS[0] = di[7:0];
    assign inS[1] = di[15:8];
    assign inS[2] = di[23:16];
    assign inS[3] = di[31:24];

    // Assign 8-bit segments to 32-bit output
    assign dout[7:0]   = outS[0];
    assign dout[15:8]  = outS[1];
    assign dout[23:16] = outS[2];
    assign dout[31:24] = outS[3];

    // Output ready signal (always high in this version)
    assign dout_ready = 1'b1;

     // Normalize address to word-aligned index
    logic [DATA_WIDTH-3:0] word_addr;  // Drop 2 LSBs to align to word
    assign word_addr = addr[DATA_WIDTH-1:2];

    // Generate 4 memory banks (8-bit each)
    genvar i;
    generate
        for (i = 0; i < RAM_AMOUNT; i++) begin : ram_bank
            rams_sp_wf #(
                .RAM_SIZE(8),
                .RAM_WIDE(8),
                .ADDR_WIDTH(DATA_WIDTH-2)
            ) u_ram (
                .clk(clk),
                .we(we),
                .en(ctrl[i]),
                .addr(word_addr),
                .di(inS[i]),
                .dout(outS[i])
            );
        end
    endgenerate

endmodule