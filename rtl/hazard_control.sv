
module hazard_control (
    // Pipeline stage status inputs
    input  logic        i_instr_ready,    // Indicates if the instruction is available in the Instruction Fetch stage
    input  logic        i_data_ready,     // Indicates if memory has returned the expected data (e.g., from a LOAD in the MA stage)

    // Registers used by the instruction in Instruction Decode
    input  logic [4:0]  i_id_reg_src1,    // Source register 1 (rs1)
    input  logic [4:0]  i_id_reg_src2,    // Source register 2 (rs2)
    // These are the register numbers the instruction in the ID stage wants to read


    //input  logic [4:0]  i_id_reg_dest,    // Destination register of the instruction in Instruction Decode
    //I noticed from the tests that I am not using i_id_reg_dest, but I am not sure that its use will not be necessary.


    // Destination registers of instructions in future pipeline stages
    input  logic [4:0]  i_ex_reg_dest,    // Destination register of the instruction in Execution stage
    input  logic [4:0]  i_ma_reg_dest,    // Destination register of the instruction in Memory Access stage
    // These two will be compared with i_id_reg_src1 and i_id_reg_src2 to avoid data hazards

    // Is the current instruction in ID a branch?
    input  logic        i_id_branch,      // Branch flag detected in ID

    // Outputs: clock enable signals for each pipeline stage
    output logic        o_if_clk_en,
    output logic        o_id_clk_en,
    output logic        o_ex_clk_en,
    output logic        o_ma_clk_en
);

    // Auxiliary signal to indicate if any type of hazard was detected
    logic hazard_detected;

    // Flag to indicate if the branch should cause a stall
    logic branch_stall;

    // Main combinational logic
    always_comb begin
        // Start by assuming no hazard
        hazard_detected = 0;
        branch_stall = 0;

        // Data hazard (RAW)
        // If a register being read in ID is yet to be written by EX or MA
        if ((i_id_reg_src1 != 5'd0) && ((i_id_reg_src1 == i_ex_reg_dest) || (i_id_reg_src1 == i_ma_reg_dest))) begin
            hazard_detected = 1;
        end // the condition i_id_reg_src1 != 5'd0 ensures we ignore register x0

        if ((i_id_reg_src2 != 5'd0) && ((i_id_reg_src2 == i_ex_reg_dest) || (i_id_reg_src2 == i_ma_reg_dest))) begin
            hazard_detected = 1;
        end

        // Structural hazard
        // If the instruction or data is not yet ready
        if (!i_instr_ready || !i_data_ready) begin
            hazard_detected = 1;
        end

        // Control hazard (branch)
        // If the current instruction is a branch, we stall for one cycle
        if (i_id_branch) begin
            branch_stall = 1;
        end

        // Clock enable signal generation
        // If any hazard is detected, freeze IF and ID stages
        if (hazard_detected || branch_stall) begin
            o_if_clk_en = 0;
            o_id_clk_en = 0;
        end else begin
            o_if_clk_en = 1;
            o_id_clk_en = 1;
        end

        // EX and MA stages proceed normally
        o_ex_clk_en = 1;
        o_ma_clk_en = 1;
    end

endmodule
