/**
 * Module: rams_sp_wf
 * Description:
 *     Implements a single-port RAM in write-first mode.
 *     When enabled:
 *         - On write (`we` = 1), the input data is written to memory and output immediately.
 *         - On read (`we` = 0), the data at the given address is returned.
 *     
 * Parameters:
 *     - RAM_SIZE: Size of each memory element in bits.
 *     - RAM_WIDE: Width of each data word.
 *     - ADDR_WIDTH: Width of address bus (default 32).
 **/

module rams_sp_wf #(
    parameter RAM_SIZE = 8,
    parameter RAM_WIDE = 8,
    parameter ADDR_WIDTH = 32
)(
    input                      clk,
    input                      we,
    input                      en,
    input  [ADDR_WIDTH-1:0]    addr,
    input  [RAM_WIDE-1:0]      di,
    output reg [RAM_WIDE-1:0]  dout
);

    // Internal RAM: 1024 words
    reg [RAM_SIZE-1:0] RAM [0:1023];

    always @(posedge clk) begin
        if (en) begin
            if (we) begin
                RAM[addr] <= di;
                dout <= di;
            end else begin
                dout <= RAM[addr];
            end
        end
    end

endmodule