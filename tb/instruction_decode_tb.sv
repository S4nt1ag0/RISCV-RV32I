`timescale 1ns/1ps

module instruction_decode_tb;

    // Clock and Reset
    logic clk = 0;
    logic rst_n = 0;
    logic clk_en = 1;
    logic flush = 0;

    // Inputs
    logic [DATA_WIDTH-1:0] i_if_inst;
    logic [DATA_WIDTH-1:0] i_if_pc = 32'h00000000;
    logic [DATA_WIDTH-1:0] i_ma_reg_destination = 0;
    logic                  i_ma_reg_wr = 0;
    logic [DATA_WIDTH-1:0] i_wb_data = 0;

    // Outputs
    logic o_id_mem_to_reg;
    logic o_id_alu_src1;
    logic o_id_reg_wr;
    logic o_id_mem_rd;
    logic o_id_mem_wr;
    logic o_id_alu_src2;
    logic o_id_branch;
    logic o_id_alu_op;
    logic o_id_jump;
    logic [DATA_WIDTH-1:0] o_id_pc;
    logic [DATA_WIDTH-1:0] o_id_reg_read_data1;
    logic [DATA_WIDTH-1:0] o_id_reg_read_data2;
    logic [DATA_WIDTH-1:0] o_id_imm;
    logic [REG_ADDR-1:0]   o_id_reg_destination;
    logic [2:0]            o_id_funct3;
    logic [6:0]            o_id_funct7;

    // Clock Generation
    always #5 clk = ~clk;

    // DUT
    instruction_decode dut (
        .clk(clk),
        .clk_en(clk_en),
        .rst_n(rst_n),
        .i_if_inst(i_if_inst),
        .i_if_pc(i_if_pc),
        .i_flush(flush),
        .i_ma_reg_destination(i_ma_reg_destination),
        .i_ma_reg_wr(i_ma_reg_wr),
        .i_wb_data(i_wb_data),
        .o_id_mem_to_reg(o_id_mem_to_reg),
        .o_id_alu_src1(o_id_alu_src1),
        .o_id_reg_wr(o_id_reg_wr),
        .o_id_mem_rd(o_id_mem_rd),
        .o_id_mem_wr(o_id_mem_wr),
        .o_id_alu_src2(o_id_alu_src2),
        .o_id_branch(o_id_branch),
        .o_id_alu_op(o_id_alu_op),
        .o_id_jump(o_id_jump),
        .o_id_pc(o_id_pc),
        .o_id_reg_read_data1(o_id_reg_read_data1),
        .o_id_reg_read_data2(o_id_reg_read_data2),
        .o_id_imm(o_id_imm),
        .o_id_reg_destination(o_id_reg_destination),
        .o_id_funct3(o_id_funct3),
        .o_id_funct7(o_id_funct7)
    );

    // Task to apply instruction and display result
    task apply_instruction(input [31:0] instr, input [31:0] pc_val);
        begin
            @(negedge clk);
            i_if_inst = instr;
            i_if_pc = pc_val;
            @(posedge clk);
            #1;
            $display("Time: %0t | Instr: %h | PC: %h | rs1_data: %h | rs2_data: %h | imm: %h | rd: %0d | RegWr: %b | MemRd: %b | MemWr: %b | ALUOp: %0d",
                      $time, instr, i_if_pc, o_id_reg_read_data1, o_id_reg_read_data2, o_id_imm, o_id_reg_destination,
                      o_id_reg_wr, o_id_mem_rd, o_id_mem_wr, o_id_alu_op);
        end
    endtask

    initial begin
        $display("=== Starting Instruction Decode Testbench ===");

        // Reset sequence
        i_if_inst = 0;
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;

        // Simulated writeback: set x1 = 10, x2 = 20, x3 = 30
        i_ma_reg_wr = 1;
        i_wb_data = 10; i_ma_reg_destination = 1; @(posedge clk);
        i_wb_data = 20; i_ma_reg_destination = 2; @(posedge clk);
        i_wb_data = 30; i_ma_reg_destination = 3; @(posedge clk);
        i_ma_reg_wr = 0;

        // Wait 1 cycle
        repeat (1) @(posedge clk);

        // Test instructions
        // Format: opcode funct3 funct7
        // Encoding format reference: https://inst.eecs.berkeley.edu/~cs61c/fa17/img/riscvcard.pdf

        // ADD x5, x1, x2   => x5 = x1 + x2
        apply_instruction(32'b0000000_00010_00001_000_00101_0110011, 32'h00000010);

        // ADDI x6, x1, 10  => x6 = x1 + 10
        apply_instruction(32'b000000000010_00001_000_00110_0010011, 32'h00000014);

        // LW x7, 0(x2)     => x7 = Mem[x2 + 0]
        apply_instruction(32'b000000000000_00010_010_00111_0000011, 32'h00000018);

        // SW x3, 4(x2)     => Mem[x2 + 4] = x3
        apply_instruction(32'b0000000_00011_00010_010_00100_0100011, 32'h0000001C);

        // BEQ x1, x2, offset => if (x1 == x2) PC += offset
        apply_instruction(32'b0000000_00010_00001_000_00010_1100011, 32'h00000020);

        // JAL x1, 8 => x1 = PC+4, PC = PC+8
        apply_instruction(32'b00000000010000000000_00001_1101111, 32'h00000024);

        repeat (3) @(posedge clk);
        $display("=== Testbench Finished ===");
        $finish;
    end
endmodule
