import riscv_definitions::*; // Import package into $unit space

module instruction_decode (
    input  logic                  clk,                      // Clock
    input  logic                  clk_en,                   // Clock Enable
    input  logic                  rst_n,                    // Asynchronous reset (active low)
    input  logic [DATA_WIDTH-1:0] i_if_inst,                // Instruction from IF stage
    input  dataBus_t              i_if_pc,                  // Program Counter value from IF stage
    input  logic                  i_flush,                  // Flush signal
    input  logic                  i_insert_nop,             // Insert Nop

    input  logic [REG_ADDR-1:0]   i_ma_reg_destination,     // Forwarded register destination data from MA stage
    input  logic                  i_ma_reg_wr,              // Write enable signal from MA stage
    input  dataBus_t              i_wb_data,                // Write-back data from WB stage

    output logic                  o_id_mem_to_reg,          // Select memory output as register write-back value
    output logic                  o_id_alu_src1,            // ALU source 1 select (e.g., PC or RS1)
    output logic                  o_id_alu_src2,            // ALU source 2 select (e.g., IMM or RS2)
    output logic                  o_id_reg_wr,              // Register write enable
    output logic                  o_id_mem_rd,              // Memory read enable
    output logic                  o_id_mem_wr,              // Memory write enable
    output logic                  o_id_result_src,          // result source 1 select in write back (PC+4, alu_result, mem_read)

    output logic                  o_id_branch,              // Branch instruction flag
    output aluOpType              o_id_alu_op,              // ALU operation control
    output logic                  o_id_jump,                // Jump instruction flag
    output dataBus_t              o_id_pc,                  // Program Counter value to EX stage
    output dataBus_t              o_id_reg_read_data1,      // RS1 value output
    output dataBus_t              o_id_reg_read_data2,      // RS2 value output
    output dataBus_t              o_id_imm,                 // Sign-extended immediate value
    output logic [REG_ADDR-1:0]   o_id_reg_destination,     // Register destination address
    output logic [2:0]            o_id_funct3,              // funct3 field from instruction
    output logic [6:0]            o_id_funct7               // funct7 field from instruction
);

// Extract fields from instruction
 opcodeType  opcode;
 logic [4:0]  read_reg1_addr;
 logic [4:0]  read_reg2_addr;
 logic [4:0]  write_reg_addr;
 logic [2:0]  funct3;
 logic [6:0]  funct7;

 logic [31:0] id_instruction;

assign id_instruction = (i_insert_nop) ? 32'd0 : i_if_inst;

assign  opcode         = opcodeType'(id_instruction[6:0]);
assign read_reg1_addr = id_instruction[19:15];
assign read_reg2_addr = id_instruction[24:20];
assign write_reg_addr = id_instruction[11:7];
assign funct3         = id_instruction[14:12];
assign funct7         = id_instruction[31:25];

// Internal wires for controller outputs
aluOpType    alu_op;
aluSrc1_e    alu_src1;
aluSrc2_e    alu_src2;
logic        reg_write;
logic        mem_write;
logic        mem_read;
logic        mem_to_reg;
logic        branch;
logic        jump;
logic [1:0]  result_src;
imm_src_t    imm_src;
dataBus_t    rs1;
dataBus_t    rs2;
dataBus_t    immG;

// Instantiate Controller
controller id_controller (
    .i_opcode(opcode),
    .i_funct3(funct3),
    .i_funct7(funct7),
    .o_alu_control(alu_op),
    .o_reg_write(reg_write),
    .o_alu_src1(alu_src1),
    .o_alu_src2(alu_src2),
    .o_mem_write(mem_write),
    .o_mem_read(mem_read),
    .o_mem_to_reg(mem_to_reg),
    .o_branch(branch),
    .o_jump(jump),
    .o_imm_src(imm_src),
    .o_result_src(result_src)
);

// Register File
register_file id_reg_file (
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_read_register1_addr(read_reg1_addr),
    .i_read_register2_addr(read_reg2_addr),
    .i_write_register_addr(i_ma_reg_destination),
    .i_wr_reg_en(i_ma_reg_wr),
    .i_write_data(i_wb_data),
    .o_read_data1(rs1),
    .o_read_data2(rs2)
);

// Sign-Extend Immediate
sign_extend imm_extend (
    .i_instr(i_if_inst[31:7]),
    .i_imm_src(imm_src),
    .o_imm_out(immG)
);

// Pipeline Register (ID/EX)
always_ff @(posedge clk or negedge rst_n) begin : proc_id_ex
    if (!rst_n || i_flush) begin
        o_id_mem_rd           <= 1'b0;
        o_id_mem_wr           <= 1'b0;
        o_id_alu_src1         <= RS1;
        o_id_alu_src2         <= RS2;
        o_id_alu_op           <= ALU_ADD;
        o_id_pc               <= '0;
        o_id_reg_read_data1   <= '0;
        o_id_reg_read_data2   <= '0;
        o_id_imm              <= '0;
        o_id_reg_destination  <= '0;
        o_id_reg_wr           <= 1'b0;
        o_id_funct3           <= 3'b000;
        o_id_funct7           <= 7'b0000000;
        o_id_branch           <= 1'b0;
        o_id_mem_to_reg       <= 1'b0;
        o_id_jump             <= 1'b0;
        o_id_result_src       <= 1'b0;
    end else if (clk_en) begin
        o_id_mem_rd           <= mem_read;
        o_id_mem_wr           <= mem_write;
        o_id_alu_src1         <= alu_src1;
        o_id_alu_src2         <= alu_src2;
        o_id_alu_op           <= alu_op;
        o_id_pc               <= i_if_pc;
        o_id_reg_destination  <= write_reg_addr;
        o_id_reg_wr           <= reg_write;
        o_id_funct3           <= funct3;
        o_id_funct7           <= funct7;
        o_id_branch           <= branch;
        o_id_mem_to_reg       <= mem_to_reg;
        o_id_jump             <= jump;
        o_id_reg_read_data1   <= rs1;
        o_id_reg_read_data2   <= rs2;
        o_id_imm              <= immG;
        o_id_result_src       <= result_src;
    end
end : proc_id_ex

endmodule