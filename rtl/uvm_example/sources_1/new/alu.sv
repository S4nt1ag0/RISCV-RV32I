module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [2:0]  ALUControl,
    output logic [31:0] Result,
    output logic        Zero
);

    always_comb begin
        case (ALUControl)
            3'b000: Result = A + B;                 // ADD
            3'b001: Result = A - B;                 // SUB
            3'b010: Result = A & B;                 // AND
            3'b011: Result = A | B;                 // OR
            3'b100: Result = A ^ B;                 // XOR
            3'b101: Result = (A < B) ? 32'd1 : 32'd0; // SLT
            default: Result = 32'd0;
        endcase
    end

    assign Zero = (Result == 32'd0);

endmodule
