`timescale 1ns / 1ps

module register_file_tb;

    // Import definitions from your package
    import riscv_definitions::*;

    // Clock and reset
    logic clk = 0;
    logic clk_en = 1;
    logic rst_n;

    // Inputs to DUT
    logic [REG_ADDR-1:0] read_reg1_addr;
    logic [REG_ADDR-1:0] read_reg2_addr;
    logic [REG_ADDR-1:0] write_reg_addr;
    logic wr_en;
    logic [DATA_WIDTH-1:0] write_data;

    // Outputs from DUT
    logic [DATA_WIDTH-1:0] read_data1;
    logic [DATA_WIDTH-1:0] read_data2;

    // DUT instantiation
    register_file dut (
        .i_clk(clk),
        .i_clk_en(clk_en),
        .i_rst_n(rst_n),
        .i_read_register1_addr(read_reg1_addr),
        .i_read_register2_addr(read_reg2_addr),
        .i_write_register_addr(write_reg_addr),
        .i_wr_reg_en(wr_en),
        .i_write_data(write_data),
        .o_read_data1(read_data1),
        .o_read_data2(read_data2)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Task to write a value to a register
    task automatic write_register(input [REG_ADDR-1:0] addr, input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            wr_en = 1;
            write_reg_addr = addr;
            write_data = data;
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    // Task to read from two registers
    task automatic read_registers(input [REG_ADDR-1:0] addr1, input [REG_ADDR-1:0] addr2);
        begin
            read_reg1_addr = addr1;
            read_reg2_addr = addr2;
            @(posedge clk);
            $display("Read reg[%0d]=0x%h, reg[%0d]=0x%h", addr1, read_data1, addr2, read_data2);
        end
    endtask

    initial begin
        // Initial values
        rst_n = 1;
        wr_en = 0;
        write_reg_addr = 0;
        write_data = 0;
        read_reg1_addr = 0;
        read_reg2_addr = 0;

        // Reset pulse
        #12;
        rst_n = 0;
        #12;
        rst_n = 1;


        // Write values to registers
        write_register(1, 32'hDEADBEEF);
        write_register(2, 32'hCAFEBABE);
        write_register(3, 32'h12345678);

        // Attempt to write to x0 (should be ignored)
        write_register(0, 32'hFFFFFFFF);

        // Read and display values
        read_registers(1, 2); // Expected: DEADBEEF and CAFEBABE
        read_registers(3, 0); // Expected: 12345678 and 00000000

        // Assertions (optional)
        if (read_data2 !== 32'h0) begin
            $error("Register x0 is not zero! Value: 0x%h", read_data2);
        end

        $display("Register file test completed.");
        $finish;
    end

endmodule
