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
    aluOpType o_id_alu_op;
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
        .o_id_alu_src2(o_id_alu_src2),
        .o_id_reg_wr(o_id_reg_wr),
        .o_id_mem_rd(o_id_mem_rd),
        .o_id_mem_wr(o_id_mem_wr),
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
    task apply_instruction(input [31:0] instr, input [31:0] pc_val, string label);
        begin
            @(negedge clk);
            i_if_inst = instr;
            i_if_pc = pc_val;
            @(posedge clk);
            @(posedge clk);
            $display("\n==============================================================");
            $display("Instruction: %h (%s) | PC: %h", instr, label, pc_val);
            $display("--------------------------------------------------------------");
            $display("memToReg   : %b",  o_id_mem_to_reg);
            $display("alu_src1   : %b",  o_id_alu_src1);
            $display("alu_src2   : %b",  o_id_alu_src2);
            $display("RegWr      : %b",  o_id_reg_wr);
            $display("MemRd      : %b",  o_id_mem_rd);
            $display("MemWr      : %b",  o_id_mem_wr);
            $display("Branch     : %b",  o_id_branch);
            $display("ALUOp      : %b", o_id_alu_op);
            $display("Jump       : %b",  o_id_jump);
            $display("pc_out     : %b",  o_id_pc);
            $display("rs1_data   : %h",  o_id_reg_read_data1);
            $display("rs2_data   : %h",  o_id_reg_read_data2);
            $display("imm        : %d",  o_id_imm);
            $display("rd         : %b", o_id_reg_destination);
            $display("funct3     : %b",  o_id_funct3);
            $display("funct7     : %b",  o_id_funct7);
            $display("==============================================================\n");
        end
    endtask

    initial begin
        $display("=== Starting Instruction Decode Testbench ===");

        // Reset sequence
        i_if_inst = 0;
        rst_n = 1;
        @(posedge clk);
        repeat (2) @(posedge clk);
        rst_n = 0;
        @(posedge clk);
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

        apply_instruction(32'h0000a2b7, 32'h00000000, "LUI x5, 0xa");
        apply_instruction(32'h00010317, 32'h00000004, "AUIPC x6, 0x10");
        apply_instruction(32'h00a10093, 32'h00000008, "ADDI x1, x2, 10");
        apply_instruction(32'h0ff24193, 32'h0000000c, "XORI x3, x4, 255");
        apply_instruction(32'h00f37293, 32'h00000010, "ANDI x5, x6, 15");
        apply_instruction(32'h00341393, 32'h00000014, "SLLI x7, x8, 3");
        apply_instruction(32'h00255493, 32'h00000018, "SRLI x9, x10, 2");
        apply_instruction(32'h40265593, 32'h0000001c, "SRAI x11, x12, 2");
        apply_instruction(32'hffb72693, 32'h00000020, "SLTI x13, x14, -5");
        apply_instruction(32'h06483793, 32'h00000024, "SLTIU x15, x16, 100");
        apply_instruction(32'h0ff96893, 32'h00000028, "ORI x17, x18, 255");
        apply_instruction(32'h004a09e7, 32'h0000002c, "JALR x19, x20, 4");
        apply_instruction(32'h000b2a83, 32'h00000030, "LW x21, 0(x22)");
        apply_instruction(32'h001c0b83, 32'h00000034, "LB x23, 1(x24)");
        apply_instruction(32'h002d1c83, 32'h00000038, "LH x25, 2(x26)");
        apply_instruction(32'h003e4d83, 32'h0000003c, "LBU x27, 3(x28)");
        apply_instruction(32'h004f5e83, 32'h00000040, "LHU x29, 4(x30)");
        apply_instruction(32'h003100b3, 32'h00000044, "ADD x1, x2, x3");
        apply_instruction(32'h40628233, 32'h00000048, "SUB x4, x5, x6");
        apply_instruction(32'h009413b3, 32'h0000004c, "SLL x7, x8, x9");
        apply_instruction(32'h00c5c533, 32'h00000050, "XOR x10, x11, x12");
        apply_instruction(32'h00f756b3, 32'h00000054, "SRL x13, x14, x15");
        apply_instruction(32'h4128d833, 32'h00000058, "SRA x16, x17, x18");
        apply_instruction(32'h015a69b3, 32'h0000005c, "OR x19, x20, x21");
        apply_instruction(32'h018bfb33, 32'h00000060, "AND x22, x23, x24");
        apply_instruction(32'h01bd2cb3, 32'h00000064, "SLT x25, x26, x27");
        apply_instruction(32'h01eebe33, 32'h00000068, "SLTU x28, x29, x30");
        apply_instruction(32'h00112023, 32'h0000006c, "SW x1, 0(x2)");
        apply_instruction(32'h00320223, 32'h00000070, "SB x3, 4(x4)");
        apply_instruction(32'h00531323, 32'h00000074, "SH x5, 6(x6)");
        apply_instruction(32'h06208c63, 32'h00000078, "BEQ x1, x2, 120 <LABEL>");
        apply_instruction(32'h06419a63, 32'h0000007c, "BNE x3, x4, 116 <LABEL>");
        apply_instruction(32'h0662c863, 32'h00000080, "BLT x5, x6, 112 <LABEL>");
        apply_instruction(32'h0683d663, 32'h00000084, "BGE x7, x8, 108 <LABEL>");
        apply_instruction(32'h06a4e463, 32'h00000088, "BLTU x9, x10, 104 <LABEL>");
        apply_instruction(32'h06c5f263, 32'h0000008c, "BGEU x11, x12, 100 <LABEL>");
        apply_instruction(32'h060000ef, 32'h00000090, "JAL x1, 96 <LABEL>");

        repeat (3) @(posedge clk);
        $display("=== Testbench Finished ===");
        $finish;
    end
endmodule
