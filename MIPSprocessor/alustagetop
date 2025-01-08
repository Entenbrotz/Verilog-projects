// Top module integrating ALU, ALU Multiplexer, and PC Target Calculation
module TopALU (
    input [31:0] PC,           // Program Counter
    input [31:0] rd1, rd2,    // Register values
    input [31:0] immExt,      // Sign-extended immediate value
    input [6:0] opcode,       // Opcode for operation type
    input [3:0] ALUControl,   // ALU control signals
    input ALUSrc,             // ALU Source selection signal
    output [31:0] ALUResult,  // Result of the ALU operation
    output zero,              // Zero flag for conditional operations
    output [31:0] PCtrg       // Target PC value
);

    // Internal wires
    wire [31:0] B; // ALUMux output

    // Instantiate ALUMux to select between immediate and register value
    alumux ALUMux (
        .B(B),
        .rd2(rd2),
        .immExt(immExt),
        .ALUSrc(ALUSrc)
    );

    // Instantiate ALU for arithmetic and logical operations
    ALU ALU_instance (
        .zero(zero),
        .ALUResult(ALUResult),
        .a(rd1),
        .b(B),
        .ALUControl(ALUControl),
        .opcode(opcode)
    );

    // Instantiate PC Target Calculation module
    PCtarget PC_target_instance (
        .PC(PC),
        .immExt(immExt),
        .PCtrg(PCtrg)
    );

endmodule
