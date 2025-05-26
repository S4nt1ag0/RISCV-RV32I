`timescale 1ns/1ps
import riscv_definitions::*; // Import package into $unit space

module instruction_decode_tb;

    bit DEBUG_MODE = 0; // Set to 1 to display detailed output for every instruction; set to 0 to show only pass/fail and mismatches.

    // Clock and Reset
    logic clk = 0;
    logic rst_n = 0;
    logic clk_en = 1;
    logic flush = 0;

    // Inputs
    logic [DATA_WIDTH-1:0] i_if_inst;
    logic [DATA_WIDTH-1:0] i_if_pc = 32'h00000000;
    logic [REG_ADDR-1:0] i_ma_reg_destination = 0;
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
    logic signed [DATA_WIDTH-1:0] o_id_imm;
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

   typedef struct packed{
    logic [31:0] hexInstr;  // Instrução em hexadecimal
    logic       memToReg;   // Sinal de controle memToReg
    logic       alu_src1;   // Sinal de controle alu_src1
    logic       alu_src2;   // Sinal de controle alu_src2
    logic       RegWr;      // Sinal de controle RegWr
    logic       MemRd;      // Sinal de controle MemRd
    logic       MemWr;      // Sinal de controle MemWr
    logic       Branch;     // Sinal de controle Branch
    logic       Jump;       // Sinal de controle Jump
    logic [4:0] ALUOp;      // Sinal de controle ALUOp (5 bits)
    logic [31:0] rs1_data;  // Dados do registrador rs1
    logic [31:0] rs2_data;  // Dados do registrador rs2
    logic [31:0] Imm;       // Valor imediato (estendido para 32 bits)
    logic [4:0]  rd;        // Registrador de destino
} test_vector_t;

  test_vector_t tests[37] = '{
    // Instruction       memToReg, alu_src1, alu_src2, RegWr, MemRd,  MemWr,  Branch,   Jump,   ALUOp,   rs1_data,   rs2_data,   Imm,  rd
    '{hexInstr: 32'h0000a2b7,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2: 1'b1,    RegWr: 1'b1,  MemRd: 1'b0,   MemWr:1'b0,    Branch: 1'b0,    Jump: 1'b0, ALUOp: 4'b01010, rs1_data: 32'h0000000a, rs2_data: 32'h00000000, Imm: 32'd10,  rd: 5'b00101},  // LUI x5, 0xa
    '{hexInstr: 32'h00010317,        memToReg:1'b0,     alu_src1:1'b1,      alu_src2:1'b1,     RegWr:1'b1,  MemRd: 1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000014,rs2_data: 32'h00000000, Imm:32'd16, rd: 5'b00110}, // AUIPC x6, 0x10
    '{hexInstr: 32'h00a10093,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000014, rs2_data: 32'h00000000, Imm:32'd10,  rd: 5'b00001},  // ADDI x1, x2, 10
    '{hexInstr: 32'h0ff24193,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00100, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd255, rd: 5'b00011}, // XORI x3, x4, 255
    '{hexInstr: 32'h00f37293,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00111, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd15,  rd: 5'b00101}, // ANDI x5, x6, 15
    '{hexInstr: 32'h00341393,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00001, rs1_data: 32'h00000000, rs2_data: 32'h0000001e, Imm:32'd3,   rd: 5'b00111}, // SLLI x7, x8, 3
    '{hexInstr: 32'h00255493,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00101, rs1_data: 32'h00000000, rs2_data: 32'h00000014, Imm:32'd2,   rd: 5'b01001}, // SRLI x9, x10, 2
    '{hexInstr: 32'h40265593,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,   Branch:  'b0,    Jump:1'b0, ALUOp: 4'b01001, rs1_data: 32'h00000000, rs2_data: 32'h00000014, Imm:32'd2,   rd: 5'b01011}, // SRAI x11, x12, 2
    '{hexInstr: 32'hffb72693,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00010, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd5,  rd: 5'b01101}, // SLTI x13, x14, -5
    '{hexInstr: 32'h06483793,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00011, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd100, rd: 5'b01111}, // SLTIU x15, x16, 100
    '{hexInstr: 32'h0ff96893,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,   Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00110, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd255, rd: 5'b10001}, // ORI x17, x18, 255
    '{hexInstr: 32'h004a09e7,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b1, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd4,   rd: 5'b10011}, // JALR x19, x20, 4
    '{hexInstr: 32'h000b2a83,        memToReg:1'b1,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b1,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd0,   rd: 5'b10101}, // LW x21, 0(x22)
    '{hexInstr: 32'h001c0b83,        memToReg:1'b1,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b1,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h0000000a, Imm:32'd1,   rd: 5'b10111}, // LB x23, 1(x24)
    '{hexInstr: 32'h002d1c83,        memToReg:1'b1,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b1,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h00000014, Imm:32'd2,   rd: 5'b11001}, // LH x25, 2(x26)
    '{hexInstr: 32'h003e4d83,        memToReg:1'b1,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b1,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h0000001e, Imm:32'd3,   rd: 5'b11011}, // LBU x27, 3(x28)
    '{hexInstr: 32'h004f5e83,        memToReg:1'b1,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b1,  MemRd:1'b1,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd4,   rd: 5'b11101}, // LHU x29, 4(x30)
    '{hexInstr: 32'h003100b3,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000014, rs2_data: 32'h0000001e, Imm:32'd3,   rd: 5'b00001}, // ADD x1, x2, x3
    '{hexInstr: 32'h40628233,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b01000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd1030,rd: 5'b00100}, // SUB x4, x5, x6
    '{hexInstr: 32'h009413b3,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00001, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd9,   rd: 5'b00111}, // SLL x7, x8, x9
    '{hexInstr: 32'h00c5c533,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00100, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd12,  rd: 5'b01010}, // XOR x10, x11, x12
    '{hexInstr: 32'h00f756b3,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00101, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd15,  rd: 5'b01101}, // SRL x13, x14, x15
    '{hexInstr: 32'h4128d833,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b01001, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd1042,rd: 5'b10000}, // SRA x16, x17, x18
    '{hexInstr: 32'h015a69b3,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00110, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd21,  rd: 5'b10011}, // OR x19, x20, x21
    '{hexInstr: 32'h018bfb33,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00111, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd24,  rd: 5'b10110}, // AND x22, x23, x24
    '{hexInstr: 32'h01bd2cb3,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00010, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd30,  rd: 5'b11001}, // SLT x25, x26, x27
    '{hexInstr: 32'h01eebe33,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00011, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd30,  rd: 5'b11100}, // SLTU x28, x29, x30
    '{hexInstr: 32'h00112023,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b1,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000014, rs2_data: 32'h0000000a, Imm:32'd0,   rd: 5'b00000}, // SW x1, 0(x2)
    '{hexInstr: 32'h00320223,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b1,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h0000001e, Imm:32'd4,   rd: 5'b00100}, // SB x3, 4(x4)
    '{hexInstr: 32'h00531323,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b1,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b1,    Branch: 'b0,    Jump:1'b0, ALUOp: 4'b00000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd6,   rd: 5'b00110}, // SH x5, 6(x6)
    '{hexInstr: 32'h06208c63,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b01011, rs1_data: 32'h0000000a, rs2_data: 32'h00000014, Imm:32'd120, rd: 5'b11000}, // BEQ x1, x2, 120
    '{hexInstr: 32'h06419a63,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b01100, rs1_data: 32'h0000001e, rs2_data: 32'h00000000, Imm:32'd116, rd: 5'b10100}, // BNE x3, x4, 116
    '{hexInstr: 32'h0662c863,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b0010, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd112, rd: 5'b10000}, // BLT x5, x6, 112
    '{hexInstr: 32'h0683d663,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b1101, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd108, rd: 5'b01100}, // BGE x7, x8, 108
    '{hexInstr: 32'h06a4e463,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b0011, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd104, rd: 5'b01000}, // BLTU x9, x10, 104
    '{hexInstr: 32'h06c5f263,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b0,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b1,    Jump:1'b0, ALUOp: 4'b1111, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd100, rd: 5'b00100}, // BGEU x11, x12, 100
    '{hexInstr: 32'h060000ef,        memToReg:1'b0,     alu_src1:1'b0,      alu_src2:1'b0,    RegWr:1'b1,  MemRd:1'b0,   MemWr:1'b0,    Branch: 'b0,    Jump:1'b1, ALUOp: 4'b0000, rs1_data: 32'h00000000, rs2_data: 32'h00000000, Imm:32'd96,  rd: 5'b00001} // JAL x1, 96
};


string test_names[] = '{
    "LUI x5, 0xa",
    "AUIPC x6, 0x10",
    "ADDI x1, x2, 10",
    "XORI x3, x4, 255",
    "ANDI x5, x6, 15",
    "SLLI x7, x8, 3",
    "SRLI x9, x10, 2",
    "SRAI x11, x12, 2",
    "SLTI x13, x14, -5",
    "SLTIU x15, x16, 100",
    "ORI x17, x18, 255",
    "JALR x19, x20, 4",
    "LW x21, 0(x22)",
    "LB x23, 1(x24)",
    "LH x25, 2(x26)",
    "LBU x27, 3(x28)",
    "LHU x29, 4(x30)",
    "ADD x1, x2, x3",
    "SUB x4, x5, x6",
    "SLL x7, x8, x9",
    "XOR x10, x11, x12",
    "SRL x13, x14, x15",
    "SRA x16, x17, x18",
    "OR x19, x20, x21",
    "AND x22, x23, x24",
    "SLT x25, x26, x27",
    "SLTU x28, x29, x30",
    "SW x1, 0(x2)",
    "SB x3, 4(x4)",
    "SH x5, 6(x6)",
    "BEQ x1, x2, 120 <LABEL>",
    "BNE x3, x4, 116 <LABEL>",
    "BLT x5, x6, 112 <LABEL>",
    "BGE x7, x8, 108 <LABEL>",
    "BLTU x9, x10, 104 <LABEL>",
    "BGEU x11, x12, 100 <LABEL>",
    "JAL x1, 96 <LABEL>"
};


        
  // Test statistics
    int passed = 0;
    int failed = 0;
    int total = 0;

    // Task to apply instruction and check results
    task automatic apply_and_check(input test_vector_t test, string testName);begin
            // Apply instruction
            @(negedge clk);
            i_if_inst = test.hexInstr;
            i_if_pc = total * 4; // Increment PC by 4 for each instruction
            @(posedge clk);
            @(posedge clk); // Wait for pipeline
            
            // Check results
            if (o_id_mem_to_reg === test.memToReg &&
                o_id_alu_src1 === test.alu_src1 &&
                o_id_alu_src2 === test.alu_src2 &&
                o_id_reg_wr === test.RegWr &&
                o_id_mem_rd === test.MemRd &&
                o_id_mem_wr === test.MemWr &&
                o_id_branch === test.Branch &&
                o_id_jump === test.Jump &&
                o_id_alu_op === test.ALUOp &&
                o_id_reg_destination === test.rd) begin
                
                passed++;
                $display("PASS: %s => %h", testName, test.hexInstr);
                if(DEBUG_MODE) begin
                    $display("\n==============================================================");
                    $display("Instruction: %h (%s) | PC: %h", test.hexInstr, testName, i_if_pc);
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
            end else begin
                failed++;
                $display("FAIL: %s => %h", testName, test.hexInstr);
                $display("  Expected: memToReg=%b, alu_src1=%b, alu_src2=%b, RegWr=%b, MemRd=%b, MemWr=%b, Branch=%b, Jump=%b, ALUOp=%b, rd=%b",
                         test.memToReg, test.alu_src1, test.alu_src2, test.RegWr, test.MemRd, test.MemWr, 
                         test.Branch, test.Jump, test.ALUOp, test.rd);
                $display("  Got:      memToReg=%b, alu_src1=%b, alu_src2=%b, RegWr=%b, MemRd=%b, MemWr=%b, Branch=%b, Jump=%b, ALUOp=%b, rd=%b",
                         o_id_mem_to_reg, o_id_alu_src1, o_id_alu_src2, o_id_reg_wr, o_id_mem_rd, o_id_mem_wr,
                         o_id_branch, o_id_jump, o_id_alu_op, o_id_reg_destination);
            end
            
            total++;
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

        // Run all tests
        foreach (tests[i]) begin
            apply_and_check(tests[i], test_names[i]);
        end

        // Display summary
        $display("\n=== Testbench Finished ===");
        $display("  Total tests:  %0d", total);
        $display("  Passed:       %0d", passed);
        $display("  Failed:       %0d", failed);
        $display("  Success rate: %0.1f%%", (real'(passed)/real'(total))*100);
        
        repeat (3) @(posedge clk);
        $finish;
    end

endmodule
