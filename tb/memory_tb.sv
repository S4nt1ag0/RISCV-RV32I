`timescale 1ns / 1ps

module memory_tb;

    // Parameters
    localparam DATA_WIDTH = 32;
    localparam RAM_AMOUNT = 4;

    // Testbench signals
    logic clk;
    logic we;
    logic rd;
    logic [RAM_AMOUNT-1:0] ctrl;
    logic [DATA_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] di;
    logic [DATA_WIDTH-1:0] dout;
    logic dout_ready;

    // Instantiate the memory module
    memory #(
        .DATA_WIDTH(DATA_WIDTH),
        .RAM_AMOUNT(RAM_AMOUNT)
    ) dut (
        .clk(clk),
        .we(we),
        .rd(rd),
        .ctrl(ctrl),
        .addr(addr),
        .di(di),
        .dout(dout),
        .dout_ready(dout_ready)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize
        we   = 0;
        rd   = 0;
        ctrl = 4'b0000;
        addr = 0;
        di   = 32'hDEADBEEF;  // Test data

        @(posedge clk);
        #1;

        // Write Operation
        $display("=== WRITE OPERATION ===");
        ctrl = 4'b1111;   // Enable all banks
        we   = 1;
        rd   = 0;
        addr = 32'h00000010;
        di   = 32'hCAFEBABE; // Write this data

        @(posedge clk);
        #1;

        we = 0;
        ctrl = 4'b0000;

        @(posedge clk); // wait for write to settle

        // Read Operation
        $display("=== READ OPERATION ===");
        rd   = 1;
        ctrl = 4'b1111;
        addr = 32'h00000010;

        @(posedge clk);
        #1;

        rd = 0;
        ctrl = 4'b0000;

        // Wait 1 cycle and check result
        @(posedge clk);
        #1;

        if (dout == 32'hCAFEBABE) begin
            $display("[PASS] Read data matched: %h", dout);
        end else begin
            $display("[FAIL] Read data mismatch. Got: %h | Expected: %h", dout, 32'hCAFEBABE);
        end

        // End simulation
        $finish;
    end

endmodule
