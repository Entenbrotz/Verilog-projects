module top_module(
    input clk,
    input reset,
    input PCSrc,            // Control signal for PC multiplexer
    input [31:0] PCtrg,     // Target PC (e.g., for branch or jump)
    output [31:0] instruction_out // Instruction output from memory
);
    wire [31:0] PC, PC_next, PC4;
    wire [31:0] PC_next_mux;

    // Program Counter (PC) to hold the current instruction address
    Prgm_counter PC_counter (
        .clk(clk),
        .reset(reset),
        .PC_next(PC_next_mux),
        .PC(PC)
    );

    // Instruction Memory to fetch instructions based on PC
    instructionmem inst_mem (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .instruction_out(instruction_out)
    );

    // PC + 4 (for normal sequential address increment)
    PCplus4 pc_plus4 (
        .PC(PC),
        .const4(32'd4), // Constant value 4 to increment PC by 4
        .PC4(PC4)
    );

    // PC Multiplexer to choose between PC + 4 or Target PC (for branching)
    PCmux pc_mux (
        .PC4(PC4),
        .PCSrc(PCSrc),
        .PCtrg(PCtrg),
        .PC_next(PC_next_mux)
    );

endmodule
