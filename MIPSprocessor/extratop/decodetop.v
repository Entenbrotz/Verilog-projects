


module decodetop(
    input [31:0]instr,WD,
    input clk,zero,reset,
    wire [4:0]rd,rs1,rs2,
    wire[6:0]opcode,
    wire[2:0]funct3,
    wire[6:0]funct7,
    wire [24:0]immv,
    output PCSrc,
    output ResultSrc,
    output MemWrite,
    output [2:0]ALUControl,
    output ALUSrc,
    wire [2:0] ImmSrc,
    wire RegWrite,
    output [31:0]ImmExt,
    output [31:0] rd1,rd2);


InstDecoder instdecode(
    .instruction(instr),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .immv(immv));


ControlUnit cu(
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


ImmExtender imm (
    .instruction(immv),
    .ImmSrc(ImmSrc),
    .immExt(ImmExt)
);



registerfile regfile(.clk(clk),
.reset(reset),.rs1(rs1),.rs2(rs2),.rd(rd),.WD(WD),.write_enable(RegWrite),.rd1(rd1),.rd2(rd2));




endmodule
