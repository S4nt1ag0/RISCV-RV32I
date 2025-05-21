`timescale 1ns / 1ps

module sign_extend_tb;

    import riscv_definitions::*;

    // Inputs
    logic [31:7] i_instr;
    imm_src_t i_imm_src;

    // Output
    logic [31:0] o_imm_out;

    // DUT instantiation
    sign_extend dut (
        .i_instr(i_instr),
        .i_imm_src(i_imm_src),
        .o_imm_out(o_imm_out)
    );

    // Test vector task
    task test_case(input imm_src_t imm_src, input [31:7] instr_bits, input [31:0] expected);
        begin
            i_imm_src = imm_src;
            i_instr   = instr_bits;
            #1; // Wait for combinational logic to settle

            if (o_imm_out !== expected) begin
                $display("FAIL: imm_src=%b i_instr=%h => o_imm_out=%h (Expected: %h)",
                          imm_src, instr_bits, o_imm_out, expected);
            end else begin
                $display("PASS: imm_src=%b i_instr=%h => o_imm_out=%h",
                          imm_src, instr_bits, o_imm_out);
            end
        end
    endtask

    // Test sequence
    initial begin
        $display("===== Starting sign_extend Testbench =====");

        // I-TYPE: instr[31:20] = 12'b111111111111 → imm[11:0] = 0xFFF
        test_case(IMM_I, 25'b111111111111_0000000000000, 32'hFFFFFFFF);

        // S-TYPE: imm[31:25]=7'b1111111, imm[11:7]=5'b11111 → total 12'b111111111111
        // instr[31:25]=imm[11:5], instr[11:7]=imm[4:0]
        test_case(IMM_S, {7'b1111111, 13'b0, 5'b11111}, 32'hFFFFFFFF);

        // B-TYPE: imm[31:25]=7'b1111111, imm[11:7]=5'b11111 → total 12'b111111111111
        // instr[31]=imm[12]=1, instr[7]=imm[11]=1, instr[30:25]=imm[10:5]=111110, instr[11:8]=imm[4:1]=1111
        test_case(IMM_B, {7'b1111111, 13'b0, 5'b11110}, 32'hFFFFF7FE);

        // J-TYPE: imm = -4 = 0b1_11111111_1_1111111111_0
        // instr[31]=imm[20]=1, instr[19:12]=00000000, instr[20]=1, instr[30:21]=0000000000
        test_case(IMM_J, 25'b1_0000000000_1_00000000_11111, 32'hFFF00800);

        // U-TYPE: immediate = 0xFFFFF000 → instr[31:12] = 20'b11111111111111111111
        // Bits [31:12] = 20-bit immediate, [11:7] = don't care
        test_case(IMM_U, 25'b11111111111111111111_00000, 32'hFFFFFFFF);

        $display("===== Finished sign_extend Testbench =====");
        $finish;
    end

endmodule
