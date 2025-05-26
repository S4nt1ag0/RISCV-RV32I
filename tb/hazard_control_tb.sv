
module hazard_control_tb;

    // Declaration of inputs
    logic        i_instr_ready;
    logic        i_data_ready;
    logic [4:0]  i_id_reg_src1;
    logic [4:0]  i_id_reg_src2;
    //logic [4:0]  i_id_reg_dest; //I noticed from the tests that I am not using i_id_reg_dest, but I am not sure that its use will not be necessary.
    logic [4:0]  i_ex_reg_dest;
    logic [4:0]  i_ma_reg_dest;
    logic        i_id_branch;

    // Declaration of outputs
    logic        o_if_clk_en;
    logic        o_id_clk_en;
    logic        o_ex_clk_en;
    logic        o_ma_clk_en;

    // Instantiation of the unit under test
    hazard_control uut (
        .i_instr_ready(i_instr_ready),
        .i_data_ready(i_data_ready),
        .i_id_reg_src1(i_id_reg_src1),
        .i_id_reg_src2(i_id_reg_src2),
        //.i_id_reg_dest(i_id_reg_dest), // (Not used currently)
        .i_ex_reg_dest(i_ex_reg_dest),
        .i_ma_reg_dest(i_ma_reg_dest),
        .i_id_branch(i_id_branch),
        .o_if_clk_en(o_if_clk_en),
        .o_id_clk_en(o_id_clk_en),
        .o_ex_clk_en(o_ex_clk_en),
        .o_ma_clk_en(o_ma_clk_en)
    );

    int passed = 0;
    int failed = 0;

    // Task to apply a test with specific stimuli
    task automatic apply_test(
        input logic instr_ready,
        input logic data_ready,
        input logic [4:0] src1,
        input logic [4:0] src2,
        input logic [4:0] ex_dest,
        input logic [4:0] ma_dest,
        input logic branch,
        input string desc
    );
        logic expected_hazard;
        logic stall_detected;

        begin
            // Apply input stimuli
            i_instr_ready = instr_ready;
            i_data_ready  = data_ready;
            i_id_reg_src1 = src1;
            i_id_reg_src2 = src2;
            i_ex_reg_dest = ex_dest;
            i_ma_reg_dest = ma_dest;
            i_id_branch   = branch;

            #10; // Combinational propagation delay

            // Determine if a stall (hazard) should occur
            expected_hazard = 
                (!instr_ready || !data_ready) || 
                ((src1 != 5'd0) && ((src1 == ex_dest) || (src1 == ma_dest))) ||
                ((src2 != 5'd0) && ((src2 == ex_dest) || (src2 == ma_dest))) ||
                branch;

            // Check if the outputs match the expected behavior
            stall_detected = (o_if_clk_en === 0) && (o_id_clk_en === 0);

            if ((expected_hazard && stall_detected) ||
                (!expected_hazard && !stall_detected)) begin
                passed++;
            end else begin
                failed++;
                $display("** ERROR in test: %s", desc);
            end

            // Detailed log with explicit stall status
            $display("%t | instr_ready=%0d data_ready=%0d src1=%2d src2=%2d ex_dest=%2d ma_dest=%2d branch=%0d | o_if_clk_en=%0d o_id_clk_en=%0d | %s | %s",
                $time, instr_ready, data_ready, src1, src2, ex_dest, ma_dest, branch, 
                o_if_clk_en, o_id_clk_en,
                expected_hazard ? "Hazard Detected" : "No Hazard",
                stall_detected   ? "STALL Applied"   : "Pipeline Free");
        end
    endtask

    // Initial block with the test sequence
    initial begin
        $display("Start of Simulation");

        // Fixed test cases covering the main hazard types
        apply_test(1, 1, 0, 0, 0, 0, 0, "No hazard");
        apply_test(1, 1, 3, 0, 3, 0, 0, "Data hazard on src1 with EX");
        apply_test(1, 1, 0, 4, 0, 4, 0, "Data hazard on src2 with MA");
        apply_test(1, 1, 2, 3, 2, 3, 0, "Double data hazard with EX and MA");
        apply_test(1, 1, 0, 0, 10, 11, 0, "No hazard, different registers");
        apply_test(0, 1, 0, 0, 0, 0, 0, "Structural hazard - instr_ready = 0");
        apply_test(1, 0, 0, 0, 0, 0, 0, "Structural hazard - data_ready = 0");
        apply_test(1, 1, 0, 0, 0, 0, 1, "Control hazard - branch");
        apply_test(1, 1, 7, 0, 7, 0, 1, "Data and control hazard simultaneously");
        apply_test(1, 1, 1, 2, 3, 4, 0, "No hazard, non-conflicting registers");

        // Randomized tests for broader coverage
        for (int i = 0; i < 10; i++) begin
            apply_test(
                $urandom_range(0,1), 
                $urandom_range(0,1), 
                $urandom_range(0,31), 
                $urandom_range(0,31), 
                $urandom_range(0,31), 
                $urandom_range(0,31), 
                $urandom_range(0,1),
                $sformatf("Random test %0d", i+1)
            );
        end

        // Final simulation summary
        $display("End of Simulation");
        $display("Total: %0d tests | Passed: %0d | Failed: %0d", passed + failed, passed, failed);

        $finish;
    end

endmodule
