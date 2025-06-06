//------------------------------------------------------------------------------
// Reference model module for RISCV
//------------------------------------------------------------------------------
// This module defines the reference model for the RISCV verification.
//
// Author: Gustavo Santiago
// Date  : June 2025
//------------------------------------------------------------------------------

`ifndef RISCV_REF_MODEL 
`define RISCV_REF_MODEL

class RISCV_ref_model extends uvm_component;
  `uvm_component_utils(RISCV_ref_model)

  // Ports for input and output transactions
  uvm_analysis_export#(RISCV_transaction) rm_export;
  uvm_analysis_port#(RISCV_transaction) rm2sb_port;
  uvm_tlm_analysis_fifo#(RISCV_transaction) rm_exp_fifo;

  // Shadow register file (x0–x31, x0 always zero)
  logic [31:0] regfile[32];

  // Writeback pipeline entry
  typedef struct {
    logic [4:0]  rd;
    logic [31:0] value;
    bit          we;
  } wb_info_t;

  // 5-stage pipeline to model writeback delay
  wb_info_t writeback_queue[5];

  // Internal transaction handles
  RISCV_transaction rm_trans;
  RISCV_transaction exp_trans;

  function new(string name = "RISCV_ref_model", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rm_export    = new("rm_export", this);
    rm2sb_port   = new("rm2sb_port", this);
    rm_exp_fifo  = new("rm_exp_fifo", this);
    // Initialize regfile and pipeline
    foreach (regfile[i]) regfile[i] = 32'h0;
    foreach (writeback_queue[i]) writeback_queue[i] = '{rd: 0, value: 0, we: 0};
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rm_export.connect(rm_exp_fifo.analysis_export);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      // Apply writeback from the oldest entry in the queue
      if (writeback_queue[0].we && writeback_queue[0].rd != 0) begin
        regfile[writeback_queue[0].rd] = writeback_queue[0].value;
      end

      // Shift pipeline forward
      for (int i = 0; i < 4; i++) begin
        writeback_queue[i] = writeback_queue[i+1];
      end
      writeback_queue[4] = '{rd: 0, value: 0, we: 0};

      // Wait for a new transaction
      rm_exp_fifo.get(rm_trans);
      process_instruction(rm_trans);
    end
  endtask

  task process_instruction(RISCV_transaction input_trans);
    exp_trans = input_trans.clone();

    // Instruction decoding
    logic [6:0] opcode = input_trans.instr_data[6:0];
    logic [2:0] funct3 = input_trans.instr_data[14:12];
    logic [6:0] funct7 = input_trans.instr_data[31:25];

    // Read source operands from shadow regfile
    logic [31:0] rs1 = regfile[input_trans.rs1_id];
    logic [31:0] rs2 = regfile[input_trans.rs2_id];

    // Default: no writeback
    wb_info_t wb = '{rd: 0, value: 0, we: 0};

    // ADD instruction (R-type)
    if (opcode == 7'b0110011 && funct3 == 3'b000 && funct7 == 7'b0000000) begin
      exp_trans.alu_result = rs1 + rs2;
      exp_trans.valid_op = "ADD";
      wb = '{rd: input_trans.rd, value: exp_trans.alu_result, we: 1};
    end

    // LW instruction (I-type)
    else if (opcode == 7'b0000011 && funct3 == 3'b010) begin
      exp_trans.mem_addr = rs1 + input_trans.imm_i;
      exp_trans.data_rd  = input_trans.mem_data; // Assumed observed
      exp_trans.valid_op = "LW";
      wb = '{rd: input_trans.rd, value: input_trans.mem_data, we: 1};
    end

    // SW instruction (S-type)
    else if (opcode == 7'b0100011 && funct3 == 3'b010) begin
      exp_trans.mem_addr = rs1 + input_trans.imm_s;
      exp_trans.data_wr  = rs2;
      exp_trans.data_we  = 1;
      exp_trans.valid_op = "SW";
      // No writeback for store
    end

    else begin
      `uvm_warning(get_full_name(), $sformatf("Unsupported instruction: 0x%h", input_trans.instr_data));
    end

    // Insert result into pipeline queue (if writeback needed)
    writeback_queue[4] = wb;

    // Send expected transaction to scoreboard
    rm2sb_port.write(exp_trans);
  endtask

endclass

`endif
