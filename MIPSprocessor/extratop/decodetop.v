
module decodetop(
    input wire clk,
    input wire reset,
    input wire [31:0] instrin,
    input wire [31:0] WD,
    input wire zero,
    output wire [31:0]rd1,
    output wire [31:0] rd2,
    output wire [31:0] ImmExt,
    output wire PCSrc,
    output wire ResultSrc,
    output wire MemWrite,
    output wire [4:0] ALUControl,
    output wire ALUSrc
        );
    wire RegWrite;
    wire [2:0] ImmSrc;
    wire [4:0] rd;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0]opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] immv;
    
 InstDecoder instdecode(
    .instruction(instrin),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .immv(immv)
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

ImmExtender immext(
    .instruction(immv),         // The 32-bit instruction
    .ImmSrc(ImmSrc),              // Control signal to specify the immediate type
    .immExt(ImmExt)    // Extended immediate output
);




    
endmodule
