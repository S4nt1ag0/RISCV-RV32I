package riscv_definitions;

localparam REG_ADDR = 5;
localparam DATA_WIDTH = 32;
localparam REG_COUNT = 32;





    /**
    * Enum: opcodeType
    * 
    * Represents the 7-bit opcodes for the base RV32I instruction set in RISC-V.
    * Each opcode value corresponds to a specific instruction type or functional group.
    * Grouped opcodes are represented with a generic alias (e.g., BRCH_S, LOAD_S).
    */
    typedef enum logic [6:0] {

        // ------------------------------------------------------------
        // U-Type Instructions (Upper Immediate)
        // ------------------------------------------------------------
        LUI    = 7'b0110111,  // Load Upper Immediate
        AUIPC  = 7'b0010111,  // Add Upper Immediate to PC

        // ------------------------------------------------------------
        // J-Type Instructions (Jumps)
        // ------------------------------------------------------------
        JAL    = 7'b1101111,  // Jump and Link

        // ------------------------------------------------------------
        // I-Type Instructions (Jumps and Immediate ALU)
        // ------------------------------------------------------------
        JALR   = 7'b1100111,  // Jump and Link Register

        // ------------------------------------------------------------
        // B-Type Instructions (Conditional Branches)
        // All branch instructions share the same opcode.
        // ------------------------------------------------------------
        BRCH_S = 7'b1100011,  // Branch instruction set (e.g., BEQ, BNE, BLT, BGE, etc.)

        // ------------------------------------------------------------
        // I-Type Instructions (Memory Load)
        // All load instructions share the same opcode.
        // ------------------------------------------------------------
        LOAD_S = 7'b0000011,  // Load instruction set (e.g., LB, LH, LW, LBU, LHU)

        // ------------------------------------------------------------
        // S-Type Instructions (Memory Store)
        // All store instructions share the same opcode.
        // ------------------------------------------------------------
        STORE_S = 7'b0100011, // Store instruction set (e.g., SB, SH, SW)

        // ------------------------------------------------------------
        // I-Type Instructions (ALU with Immediate)
        // All immediate ALU operations share the same opcode.
        // ------------------------------------------------------------
        ALUI_S = 7'b0010011,  // ALU operations with immediate (e.g., ADDI, ANDI, ORI, etc.)

        // ------------------------------------------------------------
        // R-Type Instructions (Register-Register ALU)
        // All register-based ALU operations share the same opcode.
        // ------------------------------------------------------------
        ALU_S  = 7'b0110011   // ALU operations with registers (e.g., ADD, SUB, AND, OR, etc.)

    } opcodeType;


   /**
 * Enum: funct3_Type_ALU
 *
 * funct3 field encoding for R-type ALU operations (opcode = 0110011).
 * These operations may be further specified by the funct7 field (e.g., ADD vs SUB).
 */
typedef enum logic [2:0] {
    ADD_SUB = 3'b000, // ADD: funct7 = 0000000, SUB: funct7 = 0100000
    SLL     = 3'b001, // Shift Left Logical (funct7 = 0000000)
    SLT     = 3'b010, // Set Less Than (signed)
    SLTU    = 3'b011, // Set Less Than Unsigned
    XOR     = 3'b100, // Bitwise XOR
    SRL_SRA = 3'b101, // SRL: funct7 = 0000000, SRA: funct7 = 0100000
    OR      = 3'b110, // Bitwise OR
    AND     = 3'b111  // Bitwise AND
} funct3_Type_ALU;


    /**
    * Enum: funct3_Type_LOAD
    *
    * funct3 field encoding for I-type load operations (opcode = 0000011).
    * Specifies memory access size and signedness.
    */
    typedef enum logic [2:0] {
        LB  = 3'b000, // Load Byte (signed)
        LH  = 3'b001, // Load Halfword (signed)
        LW  = 3'b010, // Load Word (signed)
        LBU = 3'b100, // Load Byte Unsigned
        LHU = 3'b101  // Load Halfword Unsigned
    } funct3_Type_LOAD;


    /**
    * Enum: funct3_Type_B
    *
    * funct3 field encoding for B-type conditional branch operations (opcode = 1100011).
    * Specifies comparison type for branch decision.
    */
    typedef enum logic [2:0] {
        BEQ  = 3'b000, // Branch if Equal
        BNE  = 3'b001, // Branch if Not Equal
        BLT  = 3'b100, // Branch if Less Than (signed)
        BGE  = 3'b101, // Branch if Greater or Equal (signed)
        BLTU = 3'b110, // Branch if Less Than (unsigned)
        BGEU = 3'b111  // Branch if Greater or Equal (unsigned)
    } funct3_Type_B;


    /**
    * Enum: funct3_Type_STORE
    *
    * funct3 field encoding for S-type store operations (opcode = 0100011).
    * Specifies the size of the data being stored.
    */
    typedef enum logic [2:0] {
        SB = 3'b000, // Store Byte
        SH = 3'b001, // Store Halfword
        SW = 3'b010  // Store Word
    } funct3_Type_STORE;

  
/**
Enum: imm_src_t
Description:
     Encodes the type of immediate field to be used for sign-extension,
     based on RISC-V instruction formats (I-type, S-type, B-type, J-type).
*/
    typedef enum logic [2:0] {
        IMM_I = 3'b000, // I-type immediate (e.g., ADDI, LW)
        IMM_S = 3'b001, // S-type immediate (e.g., SW)
        IMM_B = 3'b010, // B-type immediate (e.g., BEQ, BNE)
        IMM_U = 3'b011, // U-type immediate (e.g., LUI, AUIPC)
        IMM_J = 3'b100  // J-type immediate (e.g., JAL)
    } imm_src_t;

/**
Enum: aluOpType
Description:
     Encodes the type of immediate field to be used for sign-extension,
     based on RISC-V instruction formats (I-type, S-type, B-type, J-type).
*/

typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000, // funct7 0000000, funct3 ADD  = 3'b000
        ALU_SLL  = 4'b0001, // funct7 0000000, funct3 SLL  = 3'b001
        ALU_SLT  = 4'b0010, // funct7 0000000, funct3 SLT  = 3'b010
        ALU_SLTU = 4'b0011, // funct7 0000000, funct3 SLTU = 3'b011
        ALU_XOR  = 4'b0100, // funct7 0000000, funct3 XOR  = 3'b100
        ALU_SRL  = 4'b0101, // funct7 0000000, funct3 SRL  = 3'b101
        ALU_OR   = 4'b0110, // funct7 0000000, funct3 OR   = 3'b110
        ALU_AND  = 4'b0111, // funct7 0000000, funct3 AND  = 3'b111
        ALU_SUB  = 4'b1000, // funct7 0100000, funct3 SUB  = 3'b000
        ALU_SRA  = 4'b1101, // funct7 0100000, funct3 SRA  = 3'b101
        ALU_BPS2 = 4'b1010 // By pass source 2
    } aluOpType;

/* 
     * Type enum for select ALU source 2.
     */
    typedef enum logic {
        RS2 = 1'b0, 
        IMM = 1'b1
    } aluSrc2_e;

    /* 
     * Type enum for select ALU source 1 from control.
     */
    typedef enum logic [1:0] {
        PC_S1 = 2'b00, 
        RS1_S1 = 2'b01,
    }   aluSrc1_e;



endpackage: riscv_definitions