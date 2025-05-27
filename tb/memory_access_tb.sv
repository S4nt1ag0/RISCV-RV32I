`timescale 1ns / 1ps

module memory_access_tb;

    // Clock and reset
    logic i_clk = 0;
    logic i_rst_n = 0;
    logic i_clk_en = 1;

    // Inputs
    logic [31:0] i_data_rd;
    logic        i_ex_mem_to_reg;
    logic  [1:0] i_ex_rw_sel;
    logic        i_ex_reg_wr;
    logic        i_ex_mem_rd;
    logic        i_ex_mem_wr;
    logic [31:0] i_ex_pc_plus_4;
    logic [31:0] i_ex_alu_result;
    logic [31:0] i_ex_reg_read_data2;
    logic  [4:0] i_ex_reg_dest;
    logic  [2:0] i_ex_funct3;
    logic  [6:0] i_ex_funct7;

    // Outputs
    logic [31:0] o_data_wr;
    logic [31:0] o_data_addr;
    logic  [1:0] o_data_rd_en_ctrl;
    logic        o_data_rd_en_ma;
    logic        o_data_wr_en_ma;

    logic        o_ma_mem_to_reg;
    logic  [1:0] o_ma_rw_sel;
    logic [31:0] o_ma_pc_plus_4;
    logic [31:0] o_ma_read_data;
    logic [31:0] o_ma_result;
    logic  [4:0] o_ma_reg_dest;
    logic        o_ma_reg_wr;

    // DUT
    memory_access dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_clk_en(i_clk_en),

        .i_data_rd(i_data_rd),
        .i_ex_mem_to_reg(i_ex_mem_to_reg),
        .i_ex_rw_sel(i_ex_rw_sel),
        .i_ex_reg_wr(i_ex_reg_wr),
        .i_ex_mem_rd(i_ex_mem_rd),
        .i_ex_mem_wr(i_ex_mem_wr),
        .i_ex_pc_plus_4(i_ex_pc_plus_4),
        .i_ex_alu_result(i_ex_alu_result),
        .i_ex_reg_read_data2(i_ex_reg_read_data2),
        .i_ex_reg_dest(i_ex_reg_dest),
        .i_ex_funct3(i_ex_funct3),
        .i_ex_funct7(i_ex_funct7),

        .o_data_wr(o_data_wr),
        .o_data_addr(o_data_addr),
        .o_data_rd_en_ctrl(o_data_rd_en_ctrl),
        .o_data_rd_en_ma(o_data_rd_en_ma),
        .o_data_wr_en_ma(o_data_wr_en_ma),
        .o_ma_mem_to_reg(o_ma_mem_to_reg),
        .o_ma_rw_sel(o_ma_rw_sel),
        .o_ma_pc_plus_4(o_ma_pc_plus_4),
        .o_ma_read_data(o_ma_read_data),
        .o_ma_result(o_ma_result),
        .o_ma_reg_dest(o_ma_reg_dest),
        .o_ma_reg_wr(o_ma_reg_wr)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    // Task to apply stimulus
    task automatic apply_inputs(
        input logic [2:0] funct3,
        input logic [31:0] data_from_mem
    );
        i_data_rd           = data_from_mem;
        i_ex_mem_to_reg     = 1;
        i_ex_rw_sel         = 2'b01;
        i_ex_reg_wr         = 1;
        i_ex_mem_rd         = 1;
        i_ex_mem_wr         = 0;
        i_ex_pc_plus_4      = 32'h00000004;
        i_ex_alu_result     = 32'h00000010;
        i_ex_reg_read_data2 = 32'hDEADBEEF;
        i_ex_reg_dest       = 5'd10;
        i_ex_funct3         = funct3;
        i_ex_funct7         = 7'd0;
    endtask

    initial begin
        // Init
        i_rst_n   = 1;
        i_data_rd = 0;

       // Reset sequence
        i_rst_n = 1;
        @(posedge i_clk);
        repeat (2) @(posedge i_clk);
        i_rst_n = 0;
        @(posedge i_clk);
        i_rst_n = 1;

        // === Test 1: Load Byte (LB)
        apply_inputs(3'b000, 32'hFFFFFF80); // Lower byte = 0x80 -> should sign-extend to 0xFFFFFF80
         @(posedge i_clk);

        // === Test 2: Load Half (LH)
        apply_inputs(3'b001, 32'hFFFF8000); // Lower half = 0x8000 -> should sign-extend to 0xFFFF8000
         @(posedge i_clk);

        // === Test 3: Load Word (LW)
        apply_inputs(3'b010, 32'h12345678);
         @(posedge i_clk);

        // === Test 4: Load Byte Unsigned (LBU)
        apply_inputs(3'b100, 32'h000000AB); // -> 0x000000AB
         @(posedge i_clk);

        // === Test 5: Load Half Unsigned (LHU)
        apply_inputs(3'b101, 32'h0000ABCD); // -> 0x0000ABCD
         @(posedge i_clk);

        // === Test 6: Store Word
        i_ex_mem_rd         = 0;
        i_ex_mem_wr         = 1;
        i_ex_reg_read_data2 = 32'hCAFEBABE;
        i_ex_alu_result     = 32'h1000_0000;
        @(posedge i_clk);

        // Finish
        $display("Simulation finished.");
        $finish;
    end

endmodule