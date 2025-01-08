module top_module(
    input clk,
    input reset, 
    input zero,           // Control signal for PC multiplexer
    input [31:0] PCtrg,
    input [31:0] WD,     // Target PC (e.g., for branch or jump)
    output [31:0] rd1,           
output [31:0] rd2,
output [31:0] immExt,
output  ResultSrc,
output  MemWrite,
output  [3:0] ALUControl,
output  ALUSrc

 // Instruction output from memory
);
    wire  [2:0] ImmSrc;
    wire [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] PC4;
    wire PCSrc;
    wire [31:0]instruction;
    wire [4:0]rd;
    wire RegWrite;
wire [4:0]rs1;
wire [4:0]rs2;
wire [6:0]opcode;
wire [2:0]funct3;
wire [6:0]funct7;
wire [31:0]immv;
    // Program Counter (PC) to hold the current instruction address
    Prgm_counter PC_counter (
        .clk(clk),
        .reset(reset),
        .PC_next(PC_next),
        .PC(PC)
    );

    // Instruction Memory to fetch instructions based on PC
    instructionmem inst_mem (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .instruction_out(instruction)
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
        .PC_next(PC_next)
    );
    
 
InstDecoder instdecoder(
    .instruction(instruction),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .immv(immv)  // Sign-extended immediate (32-bits)
    );
    
registerfile regfile(
    .clk(clk),                // Clock signal
    .reset(reset),              // Reset signal (active high)
    .rs1(rs1),          // Read address 1
    .rs2(rs2),          // Read address 2
    .rd(rd),           // Write address
    .WD(WD),          // Write data
    .write_enable(RegWrite),       // Write enable signal
    .rd1(rd1),        // Read data 1
    .rd2(rd2)         // Read data 2
);
ControlUnit CU(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .zero(zero),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite)
    );
ImmExtender immextr(
    .instruction(immv),         // The 32-bit instruction
    .ImmSrc(ImmSrc),              // Control signal to specify the immediate type
    .immExt(immExt)         // Extended immediate output
);
  

endmodule
