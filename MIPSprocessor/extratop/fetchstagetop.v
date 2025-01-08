module top_module(
    input clk,
    input reset,
    input PCSrc,                // Select for PC multiplexer
    output [31:0] instruction_out, // Fetched instruction from instruction memory
    output [31:0] PC            // Current PC
);

    // Internal signals
    wire [31:0] PC_plus4;       // PC + 4 value
    wire [31:0] PC_next;        // Final next PC value
    wire [31:0] PC_target;      // Target address from branch/jump

    // Instantiate Program Counter (Prgm_counter)
    Prgm_counter pc_inst(
        .clk(clk),
        .reset(reset),
        .PC_next(PC_next),
        .PC(PC)
    );

    // Instantiate Instruction Memory (instructionmem)
    instructionmem imem_inst(
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .instruction_out(instruction_out)
    );

    // Instantiate PC + 4 Adder (PCplus4)
    PCplus4 pcplus4_inst(
        .PC(PC),
        .const4(32'd4),          // Constant 4 to increment PC
        .PC4(PC_plus4)
    );

    // Instantiate PC MUX (PCmux) to select between PC + 4 and target address
    PCmux pcmux_inst(
        .PC4(PC_plus4),
        .PCSrc(PCSrc),
        .PC_next(PC_next),
        .PCtrg(PC_target)
    );


endmodule
