module hazard_control (
    input logic clk,

    // Pipeline stage status inputs
    input  logic        i_instr_ready,     // Instruction memory ready
    input  logic        i_data_ready,      // Data memory ready (for LOAD)

    // Source registers from ID stage
    input  logic [4:0]  i_if_reg_src1,     // rs1
    input  logic [4:0]  i_if_reg_src2,     // rs2

    // Destination register and write enable from ID stage
    input  logic [4:0]  i_id_reg_dest,
    input  logic        i_id_reg_wr,

    // Destination register and write enable from EX stage
    input  logic [4:0]  i_ex_reg_dest,
    input  logic        i_ex_reg_wr,

    // Destination register and write enable from MA stage
    input  logic [4:0]  i_ma_reg_dest,
    input  logic        i_ma_reg_wr,

    // Branch detection in ID stage
    input  logic        i_id_branch,

    // Outputs: clock enable signals
    output logic        o_if_clk_en,
    output logic        o_id_clk_en,
    output logic        o_ex_clk_en,
    output logic        o_ma_clk_en
);

    // Internal hazard flags
    logic data_hazard;
    logic structural_hazard;
    logic control_hazard;
    logic stall;

    // -----------------------------
    // Data Hazard (RAW) detection
    // -----------------------------
    assign data_hazard = (
        (i_if_reg_src1 != 5'd0) &&
        ((i_if_reg_src1 == i_id_reg_dest && i_id_reg_wr) ||
         (i_if_reg_src1 == i_ex_reg_dest && i_ex_reg_wr) ||
         (i_if_reg_src1 == i_ma_reg_dest && i_ma_reg_wr)
         )
    ) || (
        (i_if_reg_src2 != 5'd0) &&
        ((i_if_reg_src2 == i_id_reg_dest && i_id_reg_wr) ||
         (i_if_reg_src2 == i_ex_reg_dest && i_ex_reg_wr) ||
         (i_if_reg_src2 == i_ma_reg_dest && i_ma_reg_wr)
        )
    );

    // -----------------------------
    // Structural Hazard detection
    // -----------------------------
    assign structural_hazard = !i_instr_ready || !i_data_ready;

    // -----------------------------
    // Control Hazard (branch stall)
    // -----------------------------
    assign control_hazard = i_id_branch;

    // -----------------------------
    // Clock Enable Logic
    // -----------------------------
    always_comb begin
        stall = data_hazard || structural_hazard || control_hazard;

        o_if_clk_en = !stall;
        o_id_clk_en = !stall;

        // Execution and Memory stages always proceed
        o_ex_clk_en = 1;
        o_ma_clk_en = 1;
    end

endmodule