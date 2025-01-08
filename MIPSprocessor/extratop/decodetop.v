module topmodule(
input clk,
input reset,
input zero,//imp
input [31:0]WD,
input [31:0] instruction,
output [31:0] rd1,        
output [31:0] rd2,
output [31:0] immExt,
output  PCSrc,
output  ResultSrc,
output  MemWrite,
output  [3:0] ALUControl,
output  ALUSrc,
output  [2:0] ImmSrc,
output  RegWrite
);
wire [4:0]rd;
wire [4:0]rs1;
wire [4:0]rs2;
wire [6:0]opcode;
wire [2:0]funct3;
wire [6:0]funct7;
wire [31:0]immv;

InstDecoder(
    .instruction(instruction),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .immv(immv)  // Sign-extended immediate (32-bits)
    );
    
registerfile (
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
ControlUnit(
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
ImmExtender(
    .instruction(immv),         // The 32-bit instruction
    .ImmSrc(ImmSrc),              // Control signal to specify the immediate type
    .immExt(immExt)         // Extended immediate output
);
  

endmodule
